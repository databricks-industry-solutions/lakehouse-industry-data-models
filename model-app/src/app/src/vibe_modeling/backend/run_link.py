"""Link an imported version to the Databricks run that produced it.

An imported version has no Run: the model was made outside the app (or the
app lost track of the run) and only its ``model.json`` came in
(:func:`import_sources` decides which versions count as imported, an
out-of-band import included). Linking
records that run after the fact, as the app would have recorded it, so the
version page, the run list and the reports can show where it came from.

:func:`preview_link` verifies the match and changes nothing; :func:`link`
verifies again, then writes. The verification ladder:

- **Hard rejects** (never overridable): the run succeeded; it ended before
  the version was imported; its ``operation`` produces a version.
- **Tier 1, definitive**: the run's own ``Vibe Session / Session Started``
  event in ``<registry catalog>._metamodel._vibe_progress``. Every
  model-producing run emits it once, keyed by its ``session_id``
  (``int(vibe_session_id widget)``, nb cell 124 lines 1452-1461), with
  ``operation``, ``business_name`` and the resolved output ``version`` in
  ``result_json`` (nb cell 124 lines 1492-1507); a session bookend is flushed
  at once (nb cell 116 lines 533-538). The event must name the run's
  operation, the version's business and the version's number. Then the
  version's ``_metamodel.business`` rows: install and uninstall stamp their own
  session on that row (nb cell 118 lines 288-305, cell 116 lines 447-457) or
  re-insert it with none (nb cell 118 lines 444-466), so only another session
  whose Session Started is a model-producing run of the same key, started
  later, refuses ("written again by a later run").
- **Tier 2, best effort** (no Session Started record: no session id, no
  warehouse, a failed read or no event): the import folder is the folder the
  run writes, and the business, scope and catalog agree with the run's
  parameters. The version is checked where the parameters fix it: a resize
  keeps its source's number (the agent picks another number when that one is
  taken, nb cell 124 lines 921-946, and this check then refuses), a vibe of
  ``vN`` writes ``vN+1`` (or the next free number, which this check refuses);
  a new base model or a vibe of the latest version is not checked, and the
  evidence says so.

The registry catalog is the agent's: the ``metamodel_catalog`` widget, else
``deployment_catalog``, else the business segment with the catalog prefix and
suffix (``cat_`` by default for a catalog-per-domain or per-division style),
``${business}`` / ``{business}`` substituted in each (nb cell 124 lines
201-250). Model files sit under it (nb cell 124 lines 637-638). ``shrink ecm``
writes MVM and ``enlarge mvm`` ECM; the other operations write the scope of
``data_model_scopes`` (nb cell 124 lines 905-951).

A New Base Model or a ``vibe-new-ecm-mvm`` is two agent runs (the ECM, then
``shrink ecm`` of that ECM's number), which the app records as one Run with
two RunOperations. When the other version of such a pair is already linked on
its own, the second link joins that Run instead of making another, and the
Run's intent becomes the pair's (``core/_intents.infer_intent``). Runs pair by
version number, run order and the shrink's source version; the evidence says
so. A resize with no partner links as ``vibe-iterate`` with a note.

The write is one transaction under ``core/_runs.lock_business_for_run``. A
refused link writes nothing. The run is recorded ``completed``, with
``linked_at`` and ``link_evidence``; its RunOperations carry the run's
parameters as ``dispatched_widgets_json``.
"""

from __future__ import annotations

import json
import logging
from dataclasses import dataclass, field
from datetime import datetime, timezone
from typing import NamedTuple, Optional, Sequence

from databricks.sdk import WorkspaceClient
from databricks.sdk.errors import NotFound, PermissionDenied
from fastapi import HTTPException
from databricks.sdk.service.jobs import Run as JobRun
from sqlmodel import Session, select

from .core._intents import (
    INTENT_KICKSTART_FROM_INDUSTRY,
    AGENT_OP_ENLARGE_MVM,
    AGENT_OP_NEW_BASE_MODEL,
    AGENT_OP_SHRINK_ECM,
    AGENT_OP_TO_PRIMITIVE,
    AGENT_OP_VIBE,
    MODEL_PRODUCING_AGENT_OPS,
    infer_intent,
)
from .core._app_identity import app_application_id
from .core._errors import admin_help_error
from .core._names import agent_business_segment, metamodel_display_business, normalize_scope
from .core._paths import VersionDirKey, model_json_volume_path, version_dir_candidates, version_dir_key
from .core._runs import BusinessBusy, lock_business_for_run
from .core._sql import SqlStatementError, rows, safe_identifier
from .core._time import as_utc
from .core._warehouse import get_warehouse_id
from .db_models import Business, ModelVersion, Run, RunOperation
from .error_sanitization import sanitize_error_message
from .routes._helpers import build_job_run_url
from .models import Intent, LinkRunPreviewOut

logger = logging.getLogger(__name__)

REGISTRY_QUERY_TIMEOUT_S = 60.0
"""Bound of each ``_metamodel`` read."""

_PER_CATALOG_STYLES = ("catalog_per_domain", "catalog_per_division", "Catalog per Domain", "Catalog per Division")

_UNTRACKED_INTENTS = (Intent.IMPORT_FROM_VOLUME.value,)
"""Runs that record an import, not the run that made the model; a version
they output can still be linked."""

_OTHER_SCOPE = {"ecm": "mvm", "mvm": "ecm"}


class LinkRefused(Exception):
    """The link was refused; nothing was written. ``status`` is 409 when the
    version or the Databricks run is already recorded, else 422."""

    def __init__(self, status: int, problems: list[str]) -> None:
        super().__init__("; ".join(problems))
        self.status = status
        self.problems = problems


# --- What the Jobs API says about the run -----------------------------------


@dataclass(frozen=True)
class AgentRun:
    """A Databricks run of the agent notebook, from ``jobs.get_run``."""

    databricks_run_id: int
    params: dict[str, str]
    result_state: str
    start: Optional[datetime]
    end: Optional[datetime]

    @property
    def operation(self) -> str:
        return self.params.get("operation", "").strip().lower()

    @property
    def session_id(self) -> int:
        """``int(vibe_session_id)``, as the agent stores it; 0 when the
        widget is blank or not a number."""
        try:
            return int(self.params.get("vibe_session_id", "").strip())
        except ValueError:
            return 0

    @property
    def business_segment(self) -> str:
        return agent_business_segment(self.params.get("business_name", ""))

    @property
    def output_scope(self) -> str:
        if self.operation == AGENT_OP_SHRINK_ECM:
            return "mvm"
        if self.operation == AGENT_OP_ENLARGE_MVM:
            return "ecm"
        return normalize_scope(self.params.get("data_model_scopes", ""))

    @property
    def registry_catalog(self) -> str:
        """The catalog of the run's ``_metamodel`` and model files, derived as
        the agent derives it (nb cell 124 lines 201-250)."""
        seg = self.business_segment

        def sub(name: str) -> str:
            value = self.params.get(name, "").strip()
            return value.replace("${business}", seg).replace("{business}", seg)

        override = sub("metamodel_catalog") or sub("deployment_catalog")
        if override or not seg:
            return override
        prefix, suffix = sub("catalog_prefix"), sub("catalog_suffix")
        if self.params.get("cataloging_style", "").strip() in _PER_CATALOG_STYLES and not prefix and not suffix:
            prefix = "cat_"
        return f"{prefix}{seg}{suffix}"

    @property
    def model_version_param(self) -> Optional[int]:
        try:
            return int(float(self.params.get("model_version", "").strip()))
        except ValueError:
            return None


def run_parameters(run: JobRun) -> dict[str, str]:
    """The widget values a run got: its task's ``notebook_task.base_parameters``
    (a job the agent's own Job Launch Gate created, nb cell 5 lines 186 and
    223), then ``job_parameters``, then ``overriding_parameters.notebook_params``
    (an app ``run_now``, ``job_launcher.launch_run``); a later source wins."""
    params: dict[str, str] = {}
    for task in run.tasks or []:
        base = getattr(task.notebook_task, "base_parameters", None) if task.notebook_task else None
        params.update({k: str(v) for k, v in (base or {}).items()})
    for p in run.job_parameters or []:
        if p.name:
            value = p.value if p.value is not None else p.default
            params[p.name] = "" if value is None else str(value)
    overriding = run.overriding_parameters
    if overriding is not None and overriding.notebook_params:
        params.update({k: str(v) for k, v in overriding.notebook_params.items()})
    return params


def _ms_to_utc(ms: Optional[int]) -> Optional[datetime]:
    return datetime.fromtimestamp(ms / 1000, tz=timezone.utc) if ms else None


def agent_run_from(run: JobRun) -> AgentRun:
    state = run.state.result_state if run.state else None
    return AgentRun(
        databricks_run_id=int(run.run_id or 0),
        params=run_parameters(run),
        result_state=str(getattr(state, "value", state) or ""),
        start=_ms_to_utc(run.start_time),
        end=_ms_to_utc(run.end_time),
    )


# --- Plan ---------------------------------------------------------------------


@dataclass
class _Pair:
    """The linked Run of the other version of a two-run session. ``after``:
    this run is that Run's second step (the shrink)."""

    run: Run
    op: RunOperation
    agent_op: str
    after: bool


@dataclass
class LinkPlan:
    databricks_run_id: int
    agent_run: Optional[AgentRun] = None
    tier: Optional[int] = None
    intent: Optional[Intent] = None
    evidence: list[str] = field(default_factory=list)
    problems: list[str] = field(default_factory=list)
    conflict: bool = False
    pair: Optional[_Pair] = None

    @property
    def linkable(self) -> bool:
        return not self.problems and self.tier is not None and self.intent is not None

    def out(self) -> LinkRunPreviewOut:
        return LinkRunPreviewOut(
            databricks_run_id=self.databricks_run_id,
            linkable=self.linkable,
            tier=self.tier if self.linkable else None,
            intent=self.intent.value if self.linkable and self.intent else None,
            evidence=self.evidence,
            problems=self.problems,
        )


@dataclass(frozen=True)
class _ImportSource:
    path: str
    imported_at: Optional[datetime]


class _Producer(NamedTuple):
    """The columns of a Run that output a version that ``import_sources`` reads."""

    intent: str
    linked_at: Optional[datetime]
    parameters_json: Optional[str]
    started_at: Optional[datetime]


def import_sources(session: Session, versions: Sequence[ModelVersion]) -> dict[str, _ImportSource]:
    """``version id -> where and when it was imported``, for the imported
    versions among ``versions`` (a few queries however many there are).

    A version is imported when it has:

    - an ``import_source_path`` (the import dialogs, industry downloads), or
    - an ``import-from-volume`` Run that output it (the admin recovery
      import): the Run's ``volume_path`` and start, or
    - none of those, no Run that produced it, and a ``files_catalog``: an
      out-of-band import (``initial_sync``), which records neither a path nor
      an import time. Its path is the model.json of the agent's version
      folder in that catalog, built as the agent writes it, and its time the
      row's creation.

    A Run that produced the version is any Run with a RunOperation that
    output it, other than a link (``linked_at``) or an import record: a link
    is made after the import and does not make the version the app's own.
    ``Run.version_id`` is not used: install, uninstall, publish and a vibe
    point it at their target or parent, which an out-of-band import can be.
    Versions of a kickstarted business created before its kickstart finished
    are copies the app made, and not imported either.
    """
    found: dict[str, _ImportSource] = {}
    pending: list[ModelVersion] = []
    for mv in versions:
        if mv.import_source_path:
            found[mv.id] = _ImportSource(mv.import_source_path, as_utc(mv.imported_at))
        else:
            pending.append(mv)
    if not pending:
        return found

    ids = [mv.id for mv in pending]
    runs_of: dict[str, list[_Producer]] = {}
    for version_id, *columns in session.exec(
        select(RunOperation.output_version_id, Run.intent, Run.linked_at, Run.parameters_json, Run.started_at)
        .join(Run, Run.id == RunOperation.run_id)
        .where(RunOperation.output_version_id.in_(ids))
        .order_by(Run.created_at)
    ).all():
        runs_of.setdefault(version_id, []).append(_Producer(*columns))

    candidates: list[ModelVersion] = []
    for mv in pending:
        runs = runs_of.get(mv.id, [])
        recovery = next((r for r in runs if r.intent in _UNTRACKED_INTENTS), None)
        if recovery is not None:
            path = _volume_path(recovery.parameters_json)
            if path:
                found[mv.id] = _ImportSource(path, as_utc(recovery.started_at))
        elif not any(r.linked_at is None for r in runs) and mv.files_catalog and mv.scope in _OTHER_SCOPE:
            candidates.append(mv)
    if not candidates:
        return found

    businesses = {
        b.id: b for b in session.exec(select(Business).where(Business.id.in_(sorted({mv.business_id for mv in candidates}))))
    }
    kickstarts: dict[str, list[Optional[datetime]]] = {}
    for business_id, completed_at in session.exec(
        select(Run.business_id, Run.completed_at).where(
            Run.business_id.in_(sorted(businesses)), Run.intent == INTENT_KICKSTART_FROM_INDUSTRY
        )
    ).all():
        kickstarts.setdefault(business_id, []).append(as_utc(completed_at))
    for mv in candidates:
        created = as_utc(mv.created_at)
        if any(done is None or created <= done for done in kickstarts.get(mv.business_id, [])):
            continue
        try:
            path = model_json_volume_path(mv.files_catalog, businesses[mv.business_id].name, mv.version, mv.scope)
        except ValueError:
            continue
        found[mv.id] = _ImportSource(path, created)
    return found


def import_source(session: Session, mv: ModelVersion) -> Optional[_ImportSource]:
    """Where and when ``mv`` was imported; None for a version the app's own
    run produced (see :func:`import_sources` for the rule)."""
    return import_sources(session, [mv]).get(mv.id)


def _volume_path(parameters_json: Optional[str]) -> str:
    try:
        return json.loads(parameters_json or "{}").get("volume_path") or ""
    except (ValueError, AttributeError):
        return ""


def _version_key(business: Business, mv: ModelVersion, source_path: Optional[str]) -> VersionDirKey:
    """The agent's key of the version: from its import path when that is an
    agent version folder (the app numbers imports per scope on its own, so
    ``mv.version`` can differ from the agent's), else from the row."""
    parsed = version_dir_key(source_path)
    if parsed is not None:
        return parsed
    return VersionDirKey(
        mv.files_catalog or "", agent_business_segment(business.name), mv.version, normalize_scope(mv.scope or ""),
    )


def _label(key: VersionDirKey) -> str:
    return f"v{key.version} {key.scope.upper()}"


def recorded_problems(session: Session, mv: ModelVersion, databricks_run_id: int) -> list[str]:
    """Why the version or the Databricks run is already recorded, if it is."""
    problems: list[str] = []
    producer = session.exec(
        select(RunOperation.run_id)
        .join(Run, Run.id == RunOperation.run_id)
        .where(RunOperation.output_version_id == mv.id, Run.intent.not_in(_UNTRACKED_INTENTS))
    ).first()
    if producer:
        problems.append(f"This version is already recorded as the output of run {producer}.")
    tracked = session.exec(select(Run.id).where(Run.databricks_run_id == databricks_run_id)).first()
    if tracked is None:
        tracked = session.exec(
            select(RunOperation.run_id).where(RunOperation.databricks_run_id == databricks_run_id)
        ).first()
    if tracked:
        problems.append(f"Databricks run {databricks_run_id} is already recorded as run {tracked}.")
    return problems


def _hard_rejects(agent_run: AgentRun, source: _ImportSource) -> list[str]:
    problems: list[str] = []
    if agent_run.result_state != "SUCCESS":
        state = agent_run.result_state or "not finished"
        problems.append(f"The run did not succeed ({state}); its model.json may be partial.")
    imported_at = source.imported_at
    if agent_run.end is not None and imported_at is not None and agent_run.end > imported_at:
        problems.append("The run ended after this version was imported, so the import cannot be its output.")
    if agent_run.operation not in MODEL_PRODUCING_AGENT_OPS:
        problems.append(f"The run's operation '{agent_run.operation or 'none'}' does not produce a model version.")
    return problems


def _session_of(value) -> int:
    try:
        return int(str(value).strip())
    except (TypeError, ValueError):
        return 0


@dataclass(frozen=True)
class _SessionStart:
    """A run's ``Vibe Session / Session Started`` event."""

    session_id: int
    operation: str
    business_segment: str
    version: Optional[int]
    scope: str
    at: str


def _start_from(row: dict) -> Optional[_SessionStart]:
    try:
        body = json.loads(row.get("result_json") or "{}")
    except (TypeError, ValueError):
        return None
    if not isinstance(body, dict):
        return None
    operation = str(body.get("operation") or "").strip().lower()
    if operation == AGENT_OP_SHRINK_ECM:
        scope = "mvm"
    elif operation == AGENT_OP_ENLARGE_MVM:
        scope = "ecm"
    else:
        scope = normalize_scope(str(body.get("model_scope") or ""))
    try:
        version: Optional[int] = int(float(str(body.get("version")).strip()))
    except (TypeError, ValueError):
        version = None
    return _SessionStart(
        session_id=_session_of(row.get("session_id")),
        operation=operation,
        business_segment=agent_business_segment(str(body.get("business_name") or "")),
        version=version,
        scope=scope,
        at=str(row.get("at") or ""),
    )


def _query_session_starts(
    ws: WorkspaceClient, warehouse_id: str, catalog: str, session_ids: list[int],
) -> Optional[list[_SessionStart]]:
    """The Session Started events of ``session_ids`` in ``catalog`` (``None``
    when the table does not exist)."""
    ids = ", ".join(str(int(i)) for i in session_ids)
    sql = (
        "SELECT CAST(session_id AS STRING) AS session_id, CAST(last_updated AS STRING) AS at, "
        "CAST(result_json AS STRING) AS result_json "
        f"FROM {safe_identifier(catalog)}.`_metamodel`.`_vibe_progress` "
        f"WHERE stage_name = 'Vibe Session' AND step_name = 'Session Started' AND session_id IN ({ids})"
    )
    found = rows(
        ws, warehouse_id, sql,
        wait_timeout="30s", timeout_s=REGISTRY_QUERY_TIMEOUT_S, missing_table="none", as_dicts=True,
    )
    if found is None:
        return None
    return [s for s in (_start_from(r) for r in found) if s is not None]


def _query_key_sessions(
    ws: WorkspaceClient, warehouse_id: str, catalog: str, key: VersionDirKey,
) -> Optional[list[int]]:
    """The non-zero session ids on the ``_metamodel.business`` rows of ``key``
    (``None`` when the table does not exist). Matches the agent's own lookup:
    ``LOWER(business) = LOWER(<name>)``, the bare version, the short scope."""
    sql = (
        "SELECT CAST(session_id AS STRING) AS session_id "
        f"FROM {safe_identifier(catalog)}.`_metamodel`.`business` "
        "WHERE LOWER(business) = LOWER(:business) AND version = :version AND model_scope = :scope"
    )
    found = rows(
        ws, warehouse_id, sql,
        {"business": metamodel_display_business(key.business_segment), "version": str(key.version), "scope": key.scope},
        wait_timeout="30s", timeout_s=REGISTRY_QUERY_TIMEOUT_S, missing_table="none", as_dicts=True,
    )
    if found is None:
        return None
    return sorted({_session_of(r.get("session_id")) for r in found} - {0})


def _expected_folders(agent_run: AgentRun, key: VersionDirKey) -> list[str]:
    catalog, segment = agent_run.registry_catalog, agent_run.business_segment
    if not catalog or not segment or key.scope not in _OTHER_SCOPE:
        return []
    return version_dir_candidates(catalog, segment, key.version, key.scope)


def _tier1(
    plan: LinkPlan, ws: WorkspaceClient, warehouse_id: str, agent_run: AgentRun, key: VersionDirKey,
    import_folder: Optional[str],
) -> bool:
    """The Session Started check; True when it decided (matched or refused)."""
    catalog = agent_run.registry_catalog
    sid = agent_run.session_id
    if not sid:
        plan.evidence.append("The agent's registry was not read: the run has no session id.")
        return False
    if not warehouse_id:
        plan.evidence.append("The agent's registry was not read: no SQL warehouse is configured.")
        return False
    if not catalog:
        plan.evidence.append("The agent's registry was not read: the run names no catalog.")
        return False
    try:
        own = [s for s in (_query_session_starts(ws, warehouse_id, catalog, [sid]) or []) if s.session_id == sid]
    except (SqlStatementError, ValueError) as exc:
        plan.evidence.append(f"The agent's registry could not be read: {sanitize_error_message(str(exc))}")
        return False
    if not own:
        plan.evidence.append(f"The agent's registry in {catalog} has no start record of this run.")
        return False
    start = own[0]
    wrote = f"v{start.version} {agent_run.output_scope.upper()} of {start.business_segment or 'another business'}"
    if (
        start.operation != agent_run.operation
        or start.business_segment != key.business_segment
        or start.version != key.version
        or agent_run.output_scope != key.scope
    ):
        what = f" (a {start.operation} run)" if start.operation and start.operation != agent_run.operation else ""
        plan.problems.append(
            f"This run{what} wrote {wrote}, not {_label(key)} of {key.business_segment}."
        )
        return True
    if import_folder and import_folder not in _expected_folders(agent_run, key):
        plan.problems.append(
            f"The run wrote {_label(key)} under /Volumes/{catalog}/_metamodel/vol_root, "
            f"but this version was imported from {import_folder}."
        )
        return True
    plan.tier = 1
    plan.evidence.append(
        f"The agent's registry in {catalog} records that this run ({start.operation}) wrote "
        f"{_label(key)} of {start.business_segment}."
    )
    _later_writer(plan, ws, warehouse_id, catalog, key, start)
    return True


def _later_writer(
    plan: LinkPlan, ws: WorkspaceClient, warehouse_id: str, catalog: str, key: VersionDirKey, start: _SessionStart,
) -> None:
    """Refuse when another model-producing run wrote the same key later.
    Install and uninstall sessions on the row are not writers."""
    try:
        others = [s for s in (_query_key_sessions(ws, warehouse_id, catalog, key) or []) if s != start.session_id]
        starts = _query_session_starts(ws, warehouse_id, catalog, others) if others else []
    except (SqlStatementError, ValueError) as exc:
        plan.evidence.append(f"A later rewrite of {_label(key)} was not checked: {sanitize_error_message(str(exc))}")
        return
    for other in starts or []:
        if (
            other.operation in MODEL_PRODUCING_AGENT_OPS
            and (other.business_segment, other.version, other.scope) == (key.business_segment, key.version, key.scope)
            and other.at > start.at
        ):
            plan.tier = None
            plan.problems.append(
                f"This run didn't write the current {_label(key)} in {catalog}: a later run ({other.operation}) "
                "wrote it again, so this import may be that run's output."
            )
            return


def _tier2(plan: LinkPlan, agent_run: AgentRun, key: VersionDirKey, source_path: str) -> None:
    """The parameter checks; any failure refuses. The evidence names exactly
    what matched."""
    failed: list[str] = []
    if agent_run.business_segment != key.business_segment:
        failed.append(f"The run is for business '{agent_run.business_segment}', not '{key.business_segment}'.")
    if agent_run.output_scope != key.scope:
        failed.append(f"The run wrote a {agent_run.output_scope.upper() or 'unknown'} model, not {key.scope.upper()}.")
    catalog = agent_run.registry_catalog
    if catalog != key.catalog:
        failed.append(f"The run wrote into catalog '{catalog}', not '{key.catalog}'.")
    folder = source_path.rsplit("/", 1)[0]
    if folder not in _expected_folders(agent_run, key):
        failed.append("This version was not imported from the folder the run writes.")
    source = agent_run.model_version_param
    version_note = ""
    if agent_run.operation in (AGENT_OP_SHRINK_ECM, AGENT_OP_ENLARGE_MVM) and source is not None:
        if source != key.version:
            failed.append(f"The run resized v{source}, so it wrote v{source} (or another number if that was taken), not v{key.version}.")
        version_note = f", version v{key.version} (the resized version)"
    elif agent_run.operation == AGENT_OP_VIBE and source is not None:
        if key.version != source + 1:
            failed.append(f"The run vibed v{source}, so it would write v{source + 1}, not v{key.version}.")
        version_note = f", version v{key.version} (the version after its base v{source})"
    if failed:
        plan.problems.extend(failed)
        return
    plan.tier = 2
    plan.evidence.append(
        f"Best effort: matched the import folder {folder}, business {key.business_segment}, "
        f"scope {key.scope.upper()} and catalog {catalog}{version_note}."
    )
    if not version_note:
        plan.evidence.append(
            "The version is not checked: a new base model takes the next free number, and a vibe with no "
            "base version picks the latest one."
        )
    plan.evidence.append("A later run of the same version writes the same folder.")


def _widgets_of(op: RunOperation) -> dict:
    try:
        widgets = json.loads(op.dispatched_widgets_json or "{}")
    except ValueError:
        return {}
    return widgets if isinstance(widgets, dict) else {}


def _source_version(widgets: dict) -> Optional[int]:
    try:
        return int(float(str(widgets.get("model_version", "")).strip()))
    except ValueError:
        return None


def _find_pair(
    session: Session, business: Business, agent_run: AgentRun, key: VersionDirKey,
) -> Optional[_Pair]:
    """The linked single-step Run of the other version of this run's pair:
    same agent number, other scope, the shrink started after the first run
    ended, and the shrink's source version (when it names one) is the ECM's."""
    op = agent_run.operation
    if op == AGENT_OP_SHRINK_ECM:
        wanted, after = (AGENT_OP_NEW_BASE_MODEL, AGENT_OP_VIBE), True
        source = agent_run.model_version_param
        if source is not None and source != key.version:
            return None
    elif op in (AGENT_OP_NEW_BASE_MODEL, AGENT_OP_VIBE) and key.scope == "ecm":
        wanted, after = (AGENT_OP_SHRINK_ECM,), False
    else:
        return None
    linked = session.exec(
        select(Run).where(Run.business_id == business.id, Run.linked_at.is_not(None))
    ).all()
    for run in linked:
        ops = session.exec(select(RunOperation).where(RunOperation.run_id == run.id)).all()
        if len(ops) != 1 or not ops[0].output_version_id:
            continue
        widgets = _widgets_of(ops[0])
        other_op = str(widgets.get("operation", "")).strip().lower()
        other_mv = session.get(ModelVersion, ops[0].output_version_id)
        if other_op not in wanted or other_mv is None:
            continue
        if not after:
            shrink_source = _source_version(widgets)
            if shrink_source is not None and shrink_source != key.version:
                continue
        other_source = import_source(session, other_mv)
        other_key = _version_key(business, other_mv, other_source.path if other_source else None)
        if (other_key.version, other_key.scope) != (key.version, _OTHER_SCOPE[key.scope]):
            continue
        first_end = as_utc(ops[0].completed_at) if after else agent_run.end
        second_start = agent_run.start if after else as_utc(ops[0].started_at)
        if first_end is None or second_start is None or second_start < first_end:
            continue
        return _Pair(run=run, op=ops[0], agent_op=other_op, after=after)
    return None


def plan_link(
    session: Session, ws: WorkspaceClient, business: Business, mv: ModelVersion, agent_run: AgentRun,
) -> LinkPlan:
    """Verify ``agent_run`` as the producer of ``mv``. Reads only."""
    plan = LinkPlan(databricks_run_id=agent_run.databricks_run_id, agent_run=agent_run)
    source = import_source(session, mv)
    if source is None:
        plan.problems.append("Only an imported version can be linked to a run.")
        return plan
    recorded = recorded_problems(session, mv, agent_run.databricks_run_id)
    if recorded:
        plan.problems.extend(recorded)
        plan.conflict = True
        return plan
    plan.problems.extend(_hard_rejects(agent_run, source))
    if plan.problems:
        return plan
    key = _version_key(business, mv, source.path)
    import_folder = source.path.rsplit("/", 1)[0] if version_dir_key(source.path) else None
    if not _tier1(plan, ws, get_warehouse_id(session), agent_run, key, import_folder):
        _tier2(plan, agent_run, key, source.path)
    if plan.problems:
        return plan
    plan.pair = _find_pair(session, business, agent_run, key)
    if plan.pair is not None:
        plan.intent = infer_intent(agent_run.operation, paired_agent_op=plan.pair.agent_op)
        plan.evidence.append(
            f"Joins run {plan.pair.run.id}, which produced {_OTHER_SCOPE[key.scope].upper()} v{key.version}: "
            "paired by version number, run order and the shrink's source version."
        )
    else:
        plan.intent = infer_intent(agent_run.operation)
        if agent_run.operation == AGENT_OP_SHRINK_ECM:
            plan.evidence.append("Produced by shrink to MVM.")
        elif agent_run.operation == AGENT_OP_ENLARGE_MVM:
            plan.evidence.append("Produced by enlarge to ECM.")
    return plan


def fetch_agent_run(ws: WorkspaceClient, databricks_run_id: int) -> tuple[Optional[AgentRun], Optional[str]]:
    """``(run, None)``, or ``(None, problem)`` when the Jobs API cannot give it.

    A run of a job the app service principal cannot see (one a user's Job
    Launch Gate created) raises the 409 admin-help naming the grant."""
    try:
        return agent_run_from(ws.jobs.get_run(databricks_run_id)), None
    except NotFound:
        return None, f"Databricks run {databricks_run_id} was not found."
    except PermissionDenied as exc:
        principal = app_application_id(ws) or "the app's service principal"
        raise admin_help_error(
            f"The app cannot read Databricks run {databricks_run_id}: its job does not grant the app's "
            f"service principal ({principal}) access. A workspace admin or the job's owner grants "
            f"CAN VIEW on that job to {principal}, then the link can be checked again.",
            run_url=build_job_run_url(ws, None, databricks_run_id),
            job_reader=principal,
        ) from exc
    except Exception as exc:  # noqa: BLE001 - any other Jobs API failure is a refusal the user reads
        logger.warning("run_link: get_run(%s) failed: %s", databricks_run_id, exc)
        return None, f"Databricks run {databricks_run_id} could not be read: {sanitize_error_message(str(exc))}"


def preview_link(
    session: Session, ws: WorkspaceClient, business: Business, mv: ModelVersion, databricks_run_id: int,
) -> LinkPlan:
    agent_run, problem = fetch_agent_run(ws, databricks_run_id)
    if agent_run is None:
        return LinkPlan(databricks_run_id=databricks_run_id, problems=[problem or ""])
    return plan_link(session, ws, business, mv, agent_run)


# --- Write ------------------------------------------------------------------


def _operation_row(
    run_id: str, step_index: int, agent_run: AgentRun, mv: ModelVersion, parent_version_id: Optional[str],
) -> RunOperation:
    return RunOperation(
        run_id=run_id,
        step_index=step_index,
        operation_name=AGENT_OP_TO_PRIMITIVE[agent_run.operation],
        status="succeeded",
        databricks_run_id=agent_run.databricks_run_id,
        parent_version_id=parent_version_id,
        output_version_id=mv.id,
        dispatched_widgets_json=json.dumps(agent_run.params, sort_keys=True),
        started_at=agent_run.start,
        completed_at=agent_run.end,
    )


def _parameters_json(intent: Intent, agent_run: AgentRun) -> str:
    return json.dumps({
        "intent": intent.value,
        "deployment_catalog": agent_run.params.get("deployment_catalog", ""),
        "source": "linked_run",
    })


def _write(session: Session, business: Business, mv: ModelVersion, plan: LinkPlan) -> Run:
    agent_run = plan.agent_run
    assert agent_run is not None and plan.intent is not None
    evidence = " ".join(plan.evidence)
    now = datetime.now(timezone.utc)
    pair = plan.pair
    if pair is None:
        run = Run(
            business_id=business.id,
            version_id=mv.id,
            intent=plan.intent.value,
            status="completed",
            databricks_run_id=agent_run.databricks_run_id,
            vibe_session_id_bigint=agent_run.session_id or None,
            progress_percent=100,
            progress_message="Linked to its Databricks run",
            parameters_json=_parameters_json(plan.intent, agent_run),
            started_at=agent_run.start,
            completed_at=agent_run.end,
            linked_at=now,
            link_evidence=f"Tier {plan.tier}: {evidence}",
        )
        session.add(run)
        session.flush()
        session.add(_operation_row(run.id, 0, agent_run, mv, mv.base_version_id))
        return run
    run = pair.run
    if pair.after:
        session.add(_operation_row(run.id, 1, agent_run, mv, pair.op.output_version_id))
        run.version_id = mv.id
        run.completed_at = agent_run.end
    else:
        pair.op.step_index = 1
        pair.op.parent_version_id = mv.id
        session.add(pair.op)
        session.flush()
        session.add(_operation_row(run.id, 0, agent_run, mv, mv.base_version_id))
        run.databricks_run_id = agent_run.databricks_run_id
        run.vibe_session_id_bigint = agent_run.session_id or run.vibe_session_id_bigint
        run.started_at = agent_run.start
        run.parameters_json = _parameters_json(plan.intent, agent_run)
    run.intent = plan.intent.value
    run.link_evidence = f"{run.link_evidence or ''} Step {1 if pair.after else 0}, tier {plan.tier}: {evidence}".strip()
    session.add(run)
    return run


def link(
    session: Session, ws: WorkspaceClient, business: Business, mv: ModelVersion, databricks_run_id: int,
) -> Run:
    """Verify, then record the run in one transaction under the business lock.

    The Jobs API and registry reads happen before the lock. Raises
    :class:`LinkRefused` (nothing written) or ``core._runs.BusinessBusy``."""
    plan = preview_link(session, ws, business, mv, databricks_run_id)
    if not plan.linkable:
        raise LinkRefused(409 if plan.conflict else 422, plan.problems or ["The run cannot be linked."])
    lock_business_for_run(session, business.id)
    recorded = recorded_problems(session, mv, databricks_run_id)
    if recorded:
        session.rollback()
        raise LinkRefused(409, recorded)
    try:
        run = _write(session, business, mv, plan)
        session.commit()
    except Exception:
        session.rollback()
        raise
    session.refresh(run)
    return run


def link_after_import(
    session: Session, ws: WorkspaceClient, business: Business, mv: ModelVersion, databricks_run_id: int,
) -> tuple[Optional[str], Optional[str]]:
    """Link right after an import committed: ``(run_id, None)``, or
    ``(None, warning)`` when the link was refused or failed. The import stands
    either way; the version page offers the link again."""
    prefix = f"The version was imported but not linked to Databricks run {databricks_run_id}"
    try:
        return link(session, ws, business, mv, databricks_run_id).id, None
    except LinkRefused as exc:
        return None, f"{prefix}: {exc}"
    except BusinessBusy as exc:
        return None, f"{prefix}: {exc.message}"
    except HTTPException as exc:
        detail = exc.detail.get("message", "") if isinstance(exc.detail, dict) else str(exc.detail)
        return None, f"{prefix}: {detail}"
    except Exception as exc:  # noqa: BLE001 - the import committed; a failed link must not answer 500
        logger.exception("run_link: link after import of %s failed", mv.id)
        session.rollback()
        return None, f"{prefix}: {sanitize_error_message(str(exc))}"


def linked_run_ids(session: Session, version_ids: list[str]) -> dict[str, str]:
    """``version_id -> run_id`` for the versions a linked run produced."""
    if not version_ids:
        return {}
    found = session.exec(
        select(RunOperation.output_version_id, RunOperation.run_id)
        .join(Run, Run.id == RunOperation.run_id)
        .where(RunOperation.output_version_id.in_(version_ids), Run.linked_at.is_not(None))
    ).all()
    return {vid: rid for vid, rid in found if vid}


__all__ = [
    "AgentRun",
    "LinkPlan",
    "LinkRefused",
    "agent_run_from",
    "fetch_agent_run",
    "import_source",
    "import_sources",
    "link",
    "link_after_import",
    "linked_run_ids",
    "plan_link",
    "preview_link",
    "recorded_problems",
    "run_parameters",
]

