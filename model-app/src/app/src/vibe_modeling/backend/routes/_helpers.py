"""Shared dependencies, helpers, and small utilities lifted from the legacy
`router.py` during the per-resource module split (plan task #33).

These helpers are imported by both the runs endpoints (still in `router.py`)
and the new per-resource route modules under `routes/`. Keep them small and
side-effect-free — anything that is naturally a route handler belongs in a
specific route module, not here.
"""

from __future__ import annotations

import base64
import json
import re
import threading
import time
from dataclasses import dataclass
from datetime import datetime, timezone
from urllib.parse import urlsplit, urlunsplit

from databricks.sdk.service.workspace import ExportFormat
from fastapi import HTTPException
from sqlalchemy import func
from sqlmodel import select

from .._query_helpers import name_taken_message
from ..core._errors import CONFIG_REQUIREMENTS, config_missing_error
from ..core._intents import INTENT_KICKSTART_FROM_INDUSTRY
from ..core._json import json_object
from ..core._settings_seed import get_or_create_settings_row
from ..core._time import as_utc
from ..services.operations._deployment_widgets import CATALOG_NAME_PATTERN
from ..services.operations._protocol import RUN_WARNINGS_KEY
from ..db_models import (
    AgentConfig,
    ModelVersion,
    Run,
    RunOperation,
    RunProgressEvent,
    VibeInput,
    VibeInputContextLink,
)
from ..models import (
    IssueOut,
    NextVibeItem,
    NextVibesOut,
    RunOut,
    VersionResolutionOut,
    VibeInputOrigin,
    VibeInputPriority,
    VibeInputStatus,
)


# Cataloging styles where the run does NOT write to a single user-picked
# target catalog. In these modes the agent derives per-domain or
# per-division catalogs (see progress_tracker._catalog_and_prefix_for_scope),
# so the form's "Deployment Catalog" field is ignored — the UI disables
# the combobox with helper text "Ignored for multi-catalog styles." We
# strip ``deployment_catalog`` from ``Run.parameters_json`` here to keep
# the audit trail honest: operators tracing which catalog was written to
# in multi-catalog modes shouldn't see a misleading default value.
_MULTI_CATALOG_STYLES = frozenset({
    "Catalog per Division",
    "Catalog per Domain",
})


def params_json_omit_deployment_catalog_for_multi_catalog(
    params: dict, cataloging_style: str | None
) -> dict:
    """Strip ``deployment_catalog`` from ``params`` when the run uses a
    multi-catalog cataloging style.

    For ``One Catalog`` (the default), the user-picked deployment catalog
    is the deploy target and remains in ``parameters_json``. For
    ``Catalog per Division`` / ``Catalog per Domain`` the agent derives
    per-scope catalogs from the business + division/domain names, so the
    form's catalog field is unused and serialising it into the audit
    trail confuses operators.

    Mutates and returns ``params`` for fluent use at call sites that
    build the dict literal in place.
    """
    style = (cataloging_style or "One Catalog").strip()
    if style in _MULTI_CATALOG_STYLES:
        params.pop("deployment_catalog", None)
    return params


# Intent labels of app-only runs (zero DAG / RunOperation rows, no agent job):
# a kickstart and an industry download record a version, so they are deleted
# WITH that version rather than detached; an orphan-schema drop records no
# version (``version_id`` NULL), so the version GC never selects it. Cancel
# only marks such a run cancelled. A named constant so adding a future audit
# intent is a one-line, visible decision (locked by a test and
# ``tests/fixtures/setup_run_intents.json``).
AUDIT_INTENTS = frozenset({"download-industry", INTENT_KICKSTART_FROM_INDUSTRY, "uninstall-orphan-schemas"})


def gc_runs_for_deleted_version(session, candidate_run_ids: set[str]) -> None:
    """Delete operational runs whose ONLY output version was just deleted.

    Philosophy B (Decision Log D-B): a run is GC'd when no output version
    survives. Called AFTER the version delete has flushed, so the
    ``output_version_id`` CASCADE has already removed this version's
    RunOperation rows server-side. The survivor check is a scalar ``COUNT``
    re-query (never a stale identity-map read) of RunOperation rows still
    carrying an output version for the run; zero survivors means GC.
    """
    for rid in candidate_run_ids:
        survivors = session.scalar(
            select(func.count())
            .select_from(RunOperation)
            .where(
                RunOperation.run_id == rid,
                RunOperation.output_version_id.is_not(None),
            )
        )
        if not survivors:
            run = session.get(Run, rid)
            if run is not None:
                session.delete(run)


def delete_model_version(session, mv: ModelVersion) -> None:
    """Delete one ``ModelVersion`` riding the DB ON DELETE rules, then run the
    intent-conditional run GC (Decision Log D-B).

    The element tree, context links, diagram / artifact / review rows, and the
    run DAG rows that OUTPUT this version all die via ON DELETE CASCADE;
    ``runs.version_id`` and ``run_operations.parent_version_id`` SET NULL. Two
    rules the FK graph cannot express run in app code here:
      * audit-intent runs (:data:`AUDIT_INTENTS`, zero RunOperation rows)
        recorded on this version are deleted WITH it - a detached
        "downloaded/kickstarted" row is noise.
      * operational runs whose ONLY output was this version are GC'd; a run with
        a surviving sibling output stays.

    Does NOT touch the agent's ``_metamodel.*`` Delta tables - that needs a
    workspace handle and stays the caller's job.
    """
    # Collect the operational-run GC candidates BEFORE the delete: runs that
    # produced THIS version. Audit runs have no RunOperation rows, so they are
    # never candidates here.
    candidate_run_ids: set[str] = set(session.exec(
        select(RunOperation.run_id).where(RunOperation.output_version_id == mv.id)
    ).all())

    # Audit-intent runs recorded on this version die with it (their events /
    # artifacts / links cascade via run_id).
    for run in session.exec(
        select(Run).where(Run.version_id == mv.id, Run.intent.in_(AUDIT_INTENTS))
    ).all():
        session.delete(run)

    session.delete(mv)
    session.flush()

    # The output_version_id CASCADE fired server-side; expire the identity map
    # so the survivor COUNT re-query reads post-cascade state.
    session.expire_all()
    gc_runs_for_deleted_version(session, candidate_run_ids)


# --- Agent config / warehouse resolution -----------------------------------


def _get_or_create_agent_config(session, config) -> AgentConfig:
    """Return the singleton AgentConfig row, lazily creating it from env defaults.

    Bootstrap behaviour: on the very first call against a fresh database
    we INSERT a row whose ``deployment_catalog`` and ``warehouse_id`` are
    seeded from ``AppConfig`` (i.e. the install-time env vars). Subsequent
    calls just return the existing row as-is — the env vars are never
    consulted again, and a user clearing a value in the UI does not get
    silently overridden.

    The row's ``notebook_path`` stays empty and ``job_id`` stays None
    until the user saves the agent configuration; ``_get_agent_config``
    still raises 400 in that interim state, so this lazy bootstrap does
    not bypass the agent-not-configured gate.

    Decision 27 (seeded default source): a fresh row is seeded with the
    public industry-models repo (``DEFAULT_REPO_OWNER``/``DEFAULT_REPO_NAME``)
    so the Settings page and the source explorer stop pretending nothing is
    configured. This is a ROW-CREATION seed only - there is NO read-path
    UPDATE (that would compound the pre-existing singleton race); pre-existing
    rows with empty github fields are handled at the OUTPUT layer, which falls
    back to the same defaults (see ``get_github_config`` and
    ``build_github_connector``).

    The run-tags setting (``collect_vibe_run_statistics``) is seeded from
    ``AppConfig.run_tags_default`` here only; ``v_0_9_0_2`` applied the same
    install default once to rows that existed before it.
    """
    from ..sources.github import DEFAULT_REPO_NAME, DEFAULT_REPO_OWNER

    return get_or_create_settings_row(session, AgentConfig, {
        "deployment_catalog": config.deployment_catalog,
        "warehouse_id": config.warehouse_id,
        "github_repo_owner": DEFAULT_REPO_OWNER,
        "github_repo_name": DEFAULT_REPO_NAME,
        "taxonomy_model_service": config.taxonomy_install_default_model_service,
        "collect_vibe_run_statistics": config.run_tags_default,
    })


_CATALOG_NAME_RE = re.compile(CATALOG_NAME_PATTERN)


CATALOG_NAME_RULE = "a letter, then letters, digits and underscores"


def is_catalog_name(catalog: str) -> bool:
    """Whether ``catalog`` is a Unity Catalog name an agent dispatch accepts
    (``CATALOG_NAME_PATTERN``, lower case, at most 255 characters)."""
    return len(catalog) <= 255 and bool(_CATALOG_NAME_RE.match(catalog))


def require_catalog_name(catalog: str) -> str:
    """``catalog`` when :func:`is_catalog_name`, else 422 with a message. For
    routes that scan or change a catalog the user names."""
    if not is_catalog_name(catalog):
        raise HTTPException(
            status_code=422,
            detail={
                "message": f"The catalog must be a Unity Catalog name: {CATALOG_NAME_RULE}.",
                "catalog": catalog[:255],
            },
        )
    return catalog


def scan_rate_limited(retry_after_s: int, what: str) -> HTTPException:
    """429 for a caller over the impact-scan limit
    (``services.uninstall_impact.ScanRateLimited``), with ``Retry-After``."""
    return HTTPException(
        status_code=429,
        detail={
            "message": f"Too many {what} in the last minute. Try again in {retry_after_s} s.",
            "retry_after_s": retry_after_s,
        },
        headers={"Retry-After": str(retry_after_s)},
    )


def resolve_warehouse_id(session, config) -> str:
    """Return the configured SQL warehouse id, ``""`` if unconfigured.

    Wraps ``_get_or_create_agent_config(session, config).warehouse_id``
    with a defensive ``try/except`` to handle the boot-time / partial-
    state window where the bootstrap can raise (for instance when the
    AgentConfig table doesn't exist yet, or when a write races with
    another worker's first ever read). The fallback is the empty string
    so call sites can short-circuit cleanly without having to
    differentiate "not configured" from "transient failure".

    Phase 4 of the drift-unification plan: 6 routes-layer call sites
    used to inline the same access pattern (``versions.py`` ×3,
    ``deployment.py`` ×3); see ``code-review-2026-05-07-drift-audit.md``.
    Consolidating here means the bootstrap behaviour can change in one
    place if the config-resolution contract evolves.
    """
    try:
        return _get_or_create_agent_config(session, config).warehouse_id or ""
    except Exception:  # pragma: no cover - boot-time race
        return ""


# --- require_config: shared preflight for operations that need config -------

def _missing_config_keys(session, config, needs) -> list[str]:
    """Return the subset of ``needs`` that is NOT satisfied by current config.

    Reads the AgentConfig singleton (lazily created + env-seeded on first
    read) and evaluates each requirement. ``metamodel_catalog`` resolves
    through :func:`core._catalogs.resolve_metamodel_catalog` so it honours the
    same source-of-truth as every other catalog read.
    """
    from ..core import resolve_metamodel_catalog

    # ``config`` supplied -> get-or-create (env-seeds a fresh row). Omitted ->
    # session-only read (no seed), so read-path callers that don't thread
    # AppConfig can still evaluate requirements without a write.
    if config is not None:
        cfg = _get_or_create_agent_config(session, config)
    else:
        cfg = session.exec(select(AgentConfig).limit(1)).first()
    missing: list[str] = []
    for key in needs:
        if key == "agent_job":
            # Notebook path presence matches the original run-preflight gate;
            # create_run's _get_agent_config separately enforces job_id.
            ok = bool((getattr(cfg, "notebook_path", "") or "").strip())
        elif key == "metamodel_catalog":
            ok = bool(resolve_metamodel_catalog(session, config))
        elif key == "warehouse":
            ok = bool((getattr(cfg, "warehouse_id", "") or "").strip())
        elif key == "source_repo":
            # Effective value: seeded on row creation, and the connector falls
            # back to the public repo for pre-existing empty rows, so a source
            # repo is effectively always available. Evaluate against that
            # effective value so download never 422s on a state that works.
            from ..sources.github import DEFAULT_REPO_NAME, DEFAULT_REPO_OWNER

            owner = (getattr(cfg, "github_repo_owner", "") or "").strip() or DEFAULT_REPO_OWNER
            name = (getattr(cfg, "github_repo_name", "") or "").strip() or DEFAULT_REPO_NAME
            ok = bool(owner) and bool(name)
        elif key == "taxonomy_llm":
            ok = bool((getattr(cfg, "taxonomy_model_service", "") or "").strip())
        else:  # pragma: no cover - guards against a typo'd needs key
            raise ValueError(f"require_config: unknown requirement {key!r}")
        if not ok:
            missing.append(key)
    return missing


def require_config(session, config, needs, *, mode: str):
    """Assert that the installation config needed by an operation is present.

    ``needs`` is a subset of ``{"metamodel_catalog", "warehouse", "agent_job",
    "source_repo", "taxonomy_llm"}``. Two modes with a raise/collect duality:

    - ``mode="raise"`` raises ``HTTPException(422, detail={...})`` with a
      structured ``config_missing`` payload (``missing`` carries per-key
      ``label`` + ``settings_url`` deep-links; ``message`` is one actionable
      sentence). Used by operations that must hard-fail BEFORE creating
      anything (kickstart / download / import).
    - ``mode="collect"`` returns ``list[IssueOut]`` blockers in the exact
      shape the run pre-flight (``preflight.run_preflight``) emits, so run-shaped
      operations converge on that one mechanism instead of forking a parallel
      check. Returns ``[]`` when nothing is missing.

    This is config-missing ONLY: runtime failures (config present but a write
    errors) are the caller's concern and keep their own non-fatal semantics.
    """
    missing = _missing_config_keys(session, config, needs)
    if mode == "collect":
        return [
            IssueOut(
                field_path=CONFIG_REQUIREMENTS[k]["field_path"],
                step_index=-1,
                message=CONFIG_REQUIREMENTS[k]["message"],
                severity="blocker",
            )
            for k in missing
        ]
    if mode == "raise":
        if not missing:
            return None
        raise config_missing_error(missing)
    raise ValueError(f"require_config: unknown mode {mode!r}")


def business_name_taken_error(name: str, message: str | None = None) -> HTTPException:
    """The structured 409 ``business_name_taken`` error every business and
    industry create, rename, kickstart and download answers a name clash with."""
    return HTTPException(
        status_code=409,
        detail={
            "error": "business_name_taken",
            "name": name,
            "message": message or name_taken_message(name),
        },
    )


def _get_agent_config(session) -> AgentConfig:
    """Load the singleton AgentConfig row or raise 400 if not yet configured.

    Returns only when ``job_id`` is set — i.e. the user has saved a notebook
    path and the persistent Databricks job has been created. Read-only
    endpoints that need the bootstrapped catalog/warehouse but not the job
    should call ``_get_or_create_agent_config`` instead.
    """
    cfg = session.exec(select(AgentConfig).limit(1)).first()
    if not cfg or not cfg.job_id:
        raise HTTPException(
            status_code=400,
            detail=(
                "Agent not configured. Set up notebook path via "
                "PUT /config/agent first."
            ),
        )
    return cfg


# --- Databricks run URL builder ---------------------------------------------


def build_job_run_url(ws, job_id, run_id=None) -> str:
    """The Databricks UI URL for a job, or for one of its runs.

    ``/jobs/<job_id>`` without ``run_id``; ``/jobs/<job_id>/runs/<run_id>``
    with one (``/jobs/runs/<run_id>`` when the job id is unknown). The
    workspace host's query string (the ``?o=<workspace id>`` selector) is
    kept. Returns "" when ``ws`` is unavailable or there is neither id. The
    frontend can't construct this: the app is served from a Databricks Apps
    proxy origin and only the backend has the workspace host (SDK config).
    """
    if ws is None or not (job_id or run_id):
        return ""
    try:
        host = (ws.config.host or "").rstrip("/")
        split = urlsplit(host)
        base = urlunsplit((split.scheme, split.netloc, "", "", ""))
        suffix = f"?{split.query}" if split.query else ""
        if run_id:
            path = f"/jobs/{job_id}/runs/{run_id}" if job_id else f"/jobs/runs/{run_id}"
        else:
            path = f"/jobs/{job_id}"
        return f"{base}{path}{suffix}"
    except Exception:
        return ""


def _build_dbx_job_url(ws, job_id) -> str:
    """A persistent job's URL ("" when job_id is unset or ws is unavailable)."""
    if not job_id:
        return ""
    return build_job_run_url(ws, job_id)


def _build_dbx_run_url(databricks_run_id, ws, session, *, app_job: bool = True) -> str | None:
    """The agent run's URL under the stored agent job, or None without a run.

    Used for both the Run-level link and per-RunOperation links. Each
    Phase of a multi-phase Run dispatches its own job run, so per-Phase
    URLs use the Phase's own ``databricks_run_id``. ``app_job=False`` (a run
    recorded by linking, ``Run.linked_at``, which may belong to another job)
    builds the job-less ``/jobs/runs/<run_id>`` link.
    """
    if not databricks_run_id or ws is None:
        return None
    job_id = None
    if app_job and session is not None:
        try:
            cfg = session.exec(select(AgentConfig).limit(1)).first()
        except Exception:
            return None
        if cfg and cfg.job_id:
            job_id = cfg.job_id
    return build_job_run_url(ws, job_id, databricks_run_id) or None


# --- Run output shaping -----------------------------------------------------


def _build_run_out(
    run: Run,
    ws=None,
    session=None,
    *,
    warnings: list[dict] | None = None,
) -> RunOut:
    """Build RunOut from a Run, optionally adding run_page_url.

    The URL uses the canonical `/jobs/<job_id>/runs/<run_id>` shape rather
    than the deprecated `#job/0/run/<run_id>` anchor path — the latter
    hardcoded job id `0` and 404s for any non-legacy workspace. The job id
    comes from AgentConfig since every run in the app is launched against
    the single persistent agent job.

    Also derives the D-09 watchdog signals (watchdog_state, warm-up
    countdown, elapsed_seconds) so the UI can render the watchdog pill
    and elapsed time without the frontend having to know the contract.

    ``warnings`` (Phase 4 / spec §2.4 + §8) is the validator's warning
    list — empty by default on the legacy path so the field stays
    present in every ``RunOut`` regardless of which branch built it. The
    warnings its succeeded steps reported (:data:`RUN_WARNINGS_KEY`) follow.
    """
    from ..progress_tracker import WATCHDOG_WARM_UP_SECONDS  # avoid import cycle at module top
    d = {c.name: getattr(run, c.name) for c in run.__table__.columns}
    url = _build_dbx_run_url(run.databricks_run_id, ws, session, app_job=run.linked_at is None)
    if url:
        d["run_page_url"] = url

    # ----- D-09 watchdog derivation -----
    # `started_at` may be null on pre-launched runs; fall back to
    # `created_at` so elapsed_seconds is always non-negative. The end anchor
    # is `completed_at` once the run is terminal (so a finished run reports its
    # true duration and stops ticking) and `now` only while still in flight.
    # `stale` intentionally has no `completed_at` (its Databricks job may still
    # be running), so it keeps ticking live until it promotes to `failed`.
    started = run.started_at or run.created_at
    if started is not None:
        started = as_utc(started)
        end = as_utc(run.completed_at) or datetime.now(timezone.utc)
        elapsed = max(0, int((end - started).total_seconds()))
    else:
        elapsed = 0
    d["elapsed_seconds"] = elapsed

    # Watchdog state mirrors the contract spelled out on the
    # progress_tracker invariants: warming_up while running but inside
    # the warm-up grace period, armed once the agent has emitted any
    # event OR the warm-up has elapsed, tripped_* on terminal-not-success
    # statuses, disarmed otherwise (completed / cancelled / etc.).
    status = run.status
    if status == "running":
        # Mirror progress_tracker._watchdog_armed: armed once any event
        # has been seen OR the warm-up window has elapsed.
        agent_emitted = bool(run.last_consumed_step_id and run.last_consumed_step_id > 0)
        if agent_emitted or elapsed >= WATCHDOG_WARM_UP_SECONDS:
            d["watchdog_state"] = "armed"
            d["watchdog_warm_up_seconds_remaining"] = 0
        else:
            d["watchdog_state"] = "warming_up"
            d["watchdog_warm_up_seconds_remaining"] = max(0, WATCHDOG_WARM_UP_SECONDS - elapsed)
    elif status == "stale":
        d["watchdog_state"] = "tripped_stale"
        d["watchdog_warm_up_seconds_remaining"] = 0
    elif status == "failed":
        d["watchdog_state"] = "tripped_failed"
        d["watchdog_warm_up_seconds_remaining"] = 0
    else:
        # completed, cancelled, rolled_back_failed, pending — disarmed.
        # The contract calls out completed / cancelled / rolled_back_failed
        # explicitly; pending falls through here too since it has no
        # tracker activity yet.
        d["watchdog_state"] = "disarmed"
        d["watchdog_warm_up_seconds_remaining"] = 0

    d["warnings"] = [*(warnings or []), *_collect_operation_warnings(run, session)]
    d["version_resolutions"] = _collect_version_resolutions(run, session)
    return RunOut(**d)


def _collect_operation_warnings(run: Run, session) -> list[dict]:
    """The warnings the run's succeeded steps recorded in their rollback
    state (:data:`RUN_WARNINGS_KEY`), as ``IssueOut`` dicts. An entry is a
    text, or ``{"message", "sql"}`` when the warning comes with a statement
    to run by hand, kept under ``sql``. Empty for a run nothing warned
    about."""
    if session is None or not run.id:
        return []
    rows = session.exec(
        select(RunOperation)
        .where(RunOperation.run_id == run.id)
        .where(RunOperation.status == "succeeded")
        .order_by(RunOperation.step_index)
    ).all()
    out: list[dict] = []
    for row in rows:
        entries = json_object(row.rollback_state_json).get(RUN_WARNINGS_KEY)
        if not isinstance(entries, list):
            continue
        for entry in entries:
            text = entry.get("message") if isinstance(entry, dict) else entry
            if not isinstance(text, str) or not text:
                continue
            issue = IssueOut(
                field_path=f"({row.operation_name})", step_index=row.step_index, message=text, severity="warning",
            ).model_dump()
            sql = entry.get("sql") if isinstance(entry, dict) else None
            if isinstance(sql, str) and sql:
                issue["sql"] = sql
            out.append(issue)
    return out


def _collect_version_resolutions(run: Run, session) -> list[VersionResolutionOut]:
    """Return the agent's Version Resolution events for this run.

    Empty on the happy path (no collisions). Reads the durable
    RunProgressEvent rows the tracker mirrored from the agent; one row
    per (target_scope) pair. Predicate matches
    ``backend.version_resolution_parser.is_version_resolution_event``.
    """
    import json as _json
    if session is None or not run.id:
        return []
    from ..version_resolution_parser import STAGE_NAME, STEP_NAME, REQUIRED_KEYS
    rows = session.exec(
        select(RunProgressEvent)
        .where(RunProgressEvent.run_id == run.id)
        .where(RunProgressEvent.stage_name == STAGE_NAME)
        .where(RunProgressEvent.step_name == STEP_NAME)
        .order_by(RunProgressEvent.event_seq.asc())
    ).all()
    # Dedupe per target_scope — keep the LATEST (highest event_seq) since
    # the agent could in principle re-resolve. We iterated ascending so
    # the last write wins.
    by_scope: dict[str, VersionResolutionOut] = {}
    for r in rows:
        try:
            rj = _json.loads(r.result_json or "{}")
        except (TypeError, ValueError):
            continue
        if not REQUIRED_KEYS.issubset(rj.keys()):
            continue
        scope = (rj.get("target_scope") or "").strip().lower()
        try:
            original = int(rj.get("original_target"))
            new_target = int(rj.get("new_target"))
        except (TypeError, ValueError):
            continue
        if original == new_target:
            continue
        by_scope[scope] = VersionResolutionOut(
            target_scope=scope,
            original_target=original,
            new_target=new_target,
        )
    return list(by_scope.values())


# --- Notebook preflight checks (shared between config + run launch) --------


# Recognise any of the conventional version-marker names the agent has used
# across releases. Names accepted (with or without leading/trailing dunders):
#   - version, _version, __version__
#   - AGENT_VERSION, _AGENT_VERSION_, __AGENT_VERSION__   (v0.6.9+ uses this)
# The captured group is the version digits; an optional leading 'v' inside the
# quotes is stripped during capture so callers see canonical "X.Y.Z" digits.
_NOTEBOOK_VERSION_RE = re.compile(
    r"""^\s*(?:_{0,2}version_{0,2}|_{0,2}AGENT_VERSION_{0,2})\s*=\s*['"]v?([\d.]+)['"]""",
    re.MULTILINE,
)


def parse_version_from_notebook(source: str) -> str | None:
    """Pure helper: extract the agent version marker from notebook source text.

    Recognises ``__version__``, ``AGENT_VERSION``, and ``__AGENT_VERSION__``
    (the marker the agent has emitted since v0.6.9), with or without a leading
    ``v`` inside the quotes. Returns the canonical ``vX.Y.Z`` string, or
    ``None`` if no recognisable marker is found.

    Kept side-effect-free so it's easy to unit-test against a string fixture
    without standing up a workspace client.
    """
    if not source:
        return None
    m = _NOTEBOOK_VERSION_RE.search(source)
    if not m:
        return None
    digits = m.group(1).strip()
    return f"v{digits}" if digits else None


# The public release marker the agent stamps from v0.8.0 (alias
# `release-version-public`). This is the identity compatibility is gated on:
# the release version tracks the app-agent interface, while the agent marker
# (`__AGENT_VERSION__`) is a per-fix build counter that moves without changing
# the contract. Pre-v0.8.0 notebooks had no separate release marker (the agent
# marker doubled as the release semver).
_NOTEBOOK_RELEASE_RE = re.compile(
    r"""^\s*_{0,2}RELEASE_VERSION_{0,2}\s*=\s*['"]v?([\d.]+)['"]""",
    re.MULTILINE,
)


def parse_release_version_from_notebook(source: str) -> str | None:
    """Pure helper: extract the notebook's public release marker
    (``__RELEASE_VERSION__``), returning the canonical ``vX.Y.Z`` string or
    ``None`` when absent. Side-effect-free for string-fixture unit tests.
    """
    if not source:
        return None
    m = _NOTEBOOK_RELEASE_RE.search(source)
    if not m:
        return None
    digits = m.group(1).strip()
    return f"v{digits}" if digits else None


def _export_notebook_source(ws, notebook_path: str) -> str | None:
    """Export a notebook's SOURCE and return its decoded text, or ``None`` when
    the export is empty.

    Read failures (network, permission, malformed response) are NOT swallowed —
    they propagate as ``DatabricksError`` to the caller so the user sees the
    real reason (rather than a misleading "no marker found" warning). Permission
    is already checked separately by ``_preflight_notebook_access``.

    History: the detector used to wrap its whole body in a bare
    ``except: return None``. That hid an SDK API misuse (`format="SOURCE"`
    string vs ``ExportFormat.SOURCE`` enum) for many releases — every notebook
    returned None and the "no marker" warning fired even when the marker was
    present. Don't put the bare except back.
    """
    # SDK requires ExportFormat enum (it calls `.value` on the arg).
    export = ws.workspace.export(notebook_path, format=ExportFormat.SOURCE)
    raw = export.content
    if not raw:
        return None
    # `content` is base64-encoded notebook source; decode once. base64 is
    # well-defined so this shouldn't fail, but if it does fall back to the
    # str() of the raw bytes so we still try to find the markers.
    try:
        return base64.b64decode(raw).decode("utf-8", errors="replace")
    except (ValueError, TypeError, UnicodeDecodeError):
        return str(raw)


def _detect_notebook_identity(ws, notebook_path: str) -> tuple[str | None, str | None]:
    """Single export → ``(release_version, agent_marker)``.

    ``release_version`` is the notebook's ``__RELEASE_VERSION__``; for pre-v0.8.0
    notebooks that predate the split it falls back to the agent marker (which
    doubled as the release semver then). ``agent_marker`` is the
    ``__AGENT_VERSION__`` build counter, returned for display only. Either
    element is ``None`` when its marker is absent.
    """
    source = _export_notebook_source(ws, notebook_path)
    if source is None:
        return (None, None)
    marker = parse_version_from_notebook(source)
    release = parse_release_version_from_notebook(source) or marker
    return (release, marker)


# The canonical upstream agent notebook, addressed from the repo ROOT (it lives
# outside the `data-models/` model tree the GitHub connector's base_path scopes
# to). The agent-compat monitor (Surface 2) live-reads this file to learn the
# latest upstream release + build markers.
UPSTREAM_AGENT_NOTEBOOK_REPO_PATH = "model-agent/agent/dbx_vibe_modelling_agent.ipynb"


def _concat_ipynb_code_source(ipynb_text: str) -> str:
    """Concatenate the source of every code cell in a raw ``.ipynb`` JSON blob.

    A notebook's ``source`` is either a list of line strings or a single string;
    both are handled. Non-code cells (markdown/raw) are skipped so the version
    markers — which live in a top code cell — are the only thing the parsers see.
    Raises ``ValueError`` / ``TypeError`` on non-JSON input (the caller treats a
    fetch/parse failure as a best-effort miss).
    """
    nb = json.loads(ipynb_text)
    parts: list[str] = []
    for cell in nb.get("cells", []) or []:
        if not isinstance(cell, dict) or cell.get("cell_type") != "code":
            continue
        src = cell.get("source", "")
        if isinstance(src, list):
            src = "".join(str(s) for s in src)
        if src:
            parts.append(src)
    return "\n".join(parts)


def parse_identity_from_ipynb(ipynb_text: str) -> tuple[str | None, str | None]:
    """Parse ``(release_version, agent_marker)`` from a raw ``.ipynb`` JSON blob.

    Concatenates the code cells and reuses the two existing notebook parsers
    (:func:`parse_release_version_from_notebook`, :func:`parse_version_from_notebook`).
    ``release_version`` falls back to the agent marker for notebooks that predate
    the ``__RELEASE_VERSION__`` split — same rule as :func:`_detect_notebook_identity`
    for the workspace-notebook path.
    """
    if not ipynb_text:
        return (None, None)
    blob = _concat_ipynb_code_source(ipynb_text)
    # ``parse_version_from_notebook`` canonicalises to ``vX.Y.Z``. The release
    # identity keeps that ``v`` (it is the git release tag), but the agent build
    # marker is reported WITHOUT the ``v`` to match ``SUPPORTED_AGENT_MARKER`` and
    # the model.json ``agent_version`` convention (a bare counter, e.g. ``4.9.9``).
    raw_marker = parse_version_from_notebook(blob)
    release = parse_release_version_from_notebook(blob) or raw_marker
    marker = raw_marker.lstrip("v") if raw_marker else None
    return (release, marker)


def fetch_upstream_agent_identity(connector) -> tuple[str | None, str | None]:
    """Fetch the canonical upstream agent notebook via a GitHub connector and
    return its ``(release_version, agent_marker)``.

    ``connector`` is a :class:`sources.github.GithubSourceConnector`; the read
    uses :meth:`~sources.github.GithubSourceConnector.fetch_repo_file` (repo-root
    addressing, bypassing the model-tree base_path). Any transport error
    propagates as a ``SourceError`` for the caller's best-effort handling.
    """
    raw = connector.fetch_repo_file(UPSTREAM_AGENT_NOTEBOOK_REPO_PATH)
    return parse_identity_from_ipynb(raw)


def _detect_notebook_version(ws, notebook_path: str) -> str | None:
    """Return the notebook's declared agent-logic marker (``__AGENT_VERSION__``
    / ``AGENT_VERSION`` / ``__version__``), or ``None`` if absent. Retained for
    display and callers that want the build counter; compatibility gating uses
    the release version via :func:`_detect_notebook_identity`.
    """
    return _detect_notebook_identity(ws, notebook_path)[1]


NOTEBOOK_ACCESS_TTL_SECONDS = 60.0
_notebook_access: dict[str, tuple[float, str | None]] = {}
_notebook_access_lock = threading.Lock()


@dataclass(frozen=True)
class NotebookAccess:
    """One read of the agent notebook by the app service principal.

    ``refused``: the path does not exist or the app can't read it (the run
    is refused). ``unchecked``: the read failed for another reason (a
    timeout, a 5xx), so nothing is known. Both None: the app can read it.
    """

    refused: str | None = None
    unchecked: str | None = None


def _sp_label(ws) -> str:
    try:
        return ws.config.client_id or "<unknown>"
    except Exception:
        return "<unknown>"


def notebook_access(ws, notebook_path: str, *, fresh: bool = False) -> NotebookAccess:
    """Whether the app service principal can read the agent notebook.

    One read of ``ws.workspace.get_status``. Only ``NotFound`` and
    ``PermissionDenied`` refuse; a readable path and a refusal are kept
    ``NOTEBOOK_ACCESS_TTL_SECONDS`` per path, so the run pre-flight (validate
    on every form change, then create) reads the workspace at most once a
    minute. Any other error is ``unchecked`` and is not kept, so the next
    check reads again. ``fresh`` reads now and replaces what is kept.
    """
    from databricks.sdk.errors import NotFound, PermissionDenied

    from ..error_sanitization import sanitize_error_message

    now = time.monotonic()
    if not fresh:
        with _notebook_access_lock:
            kept = _notebook_access.get(notebook_path)
        if kept is not None and kept[0] > now:
            return NotebookAccess(refused=kept[1])
    try:
        ws.workspace.get_status(notebook_path)
        refused = None
    except (NotFound, PermissionDenied) as e:
        refused = (
            f"The app service principal '{_sp_label(ws)}' cannot access the agent "
            f"notebook at the configured path. Either the path is wrong, or the SP needs "
            f"'Can Read' + 'Can Run' permission on the notebook (or a parent "
            f"workspace folder). Original error: {sanitize_error_message(str(e))}"
        )
    except Exception as e:  # noqa: BLE001 - not a refusal: nothing is known
        return NotebookAccess(unchecked=(
            "Couldn't check that the app service principal can read the agent notebook "
            f"({sanitize_error_message(str(e))}). The run checks again when it starts."
        ))
    with _notebook_access_lock:
        _notebook_access[notebook_path] = (now + NOTEBOOK_ACCESS_TTL_SECONDS, refused)
    return NotebookAccess(refused=refused)


def clear_notebook_access_cache() -> None:
    with _notebook_access_lock:
        _notebook_access.clear()


def _preflight_notebook_access(ws, notebook_path: str) -> None:
    """Check, now, that the app service principal can read the notebook.

    Raises HTTPException(400) with a clear message if the SP cannot see the path
    (the common failure mode is a notebook under a user's `/Workspace/Users/<email>/`
    tree that the SP has not been granted access to), or when the read fails:
    a config save stores only a path it could read. The run pre-flight reads
    the same check through its cache (:func:`notebook_access`).
    """
    access = notebook_access(ws, notebook_path, fresh=True)
    if access.refused is not None or access.unchecked is not None:
        raise HTTPException(status_code=400, detail=access.refused or access.unchecked)


def _check_notebook_release(release: str | None) -> None:
    """Fail the save if the notebook's public release version doesn't match the
    pinned ``SUPPORTED_AGENT_VERSION``, for an identity the caller already
    read (``PUT /config/agent`` exports the notebook once).

    Compatibility is gated on the release version, which tracks the app-agent
    interface. The agent-logic marker (``__AGENT_VERSION__``) is a per-fix build
    counter that moves without changing the contract, so a patch bump on the
    same release (e.g. 4.9.9 → 4.9.10 under release 0.8.0) is accepted. A
    notebook with no version marker at all is advisory-only (no hard block).
    """
    from ..core._defaults import SUPPORTED_AGENT_VERSION
    if release is None:
        return  # no marker — advisory only, not a hard block
    if release.lstrip("v") != SUPPORTED_AGENT_VERSION.lstrip("v"):
        raise HTTPException(
            status_code=400,
            detail=(
                f"Notebook release mismatch: the notebook declares release "
                f"'{release}', but this app targets agent release "
                f"'{SUPPORTED_AGENT_VERSION}'. Point at a checkout of that "
                f"release or upgrade the app."
            ),
        )


# --- Next-vibes parsing (shared between versions read + run create) --------


def _validate_next_vibe_ids(
    session, version_id: str, next_vibe_ids: list[str]
) -> list[NextVibeItem]:
    """Validate run-create ``next_vibe_ids`` against the structured agent
    ``VibeInput`` rows on the base version and return the selected items.

    Ids are the durable ``VibeInput.id`` uuids (not the old synthetic
    ``nv-N``). Unknown ids raise a 400. The returned ``NextVibeItem``s carry
    ``id == VibeInput.id``, so downstream ``RunNextVibeLink.next_vibe_id`` rows
    store uuids for new runs (audit-only). The live FE sends ``[]``, so this is
    a safe forward contract migration.
    """
    by_id = {
        it.id: it
        for it in _next_vibes_from_inputs(session, version_id).items
    }
    missing = [nid for nid in next_vibe_ids if nid not in by_id]
    if missing:
        raise HTTPException(
            status_code=400,
            detail=f"next_vibe ids not found on base version: {sorted(missing)}",
        )
    return [by_id[nid] for nid in next_vibe_ids]


def _next_vibe_item_from_input(vi: VibeInput) -> NextVibeItem:
    """Shape a single agent ``VibeInput`` row into a UI ``NextVibeItem``.

    The materializer stores the finding as ``title\\n\\ndescription`` (the
    ``_finding_text`` convention in ``model_sync``); split it back apart for
    display. ``id`` is the durable ``VibeInput.id`` uuid (the same id the run
    selection contract validates against), not the old synthetic ``nv-N``.
    """
    text = vi.text or ""
    title, _, description = text.partition("\n\n")
    title = title.strip() or "Suggested next vibe"
    try:
        priority = VibeInputPriority(vi.priority)
    except ValueError:
        priority = VibeInputPriority.HIGH
    return NextVibeItem(
        id=vi.id,
        title=title,
        description=description.strip(),
        priority=priority,
    )


def _next_vibes_from_inputs(session, model_version_id: str) -> NextVibesOut:
    """Shape a :class:`NextVibesOut` from structured agent ``VibeInput`` rows.

    Reads every active, anchored ``VibeInput(origin=agent_next_vibe)`` for the
    version (the same structured rows the Model Evolution Metrics count) and
    surfaces ALL findings — static-analysis, priority-remediation, and other
    — as cards. This unifies the card and the metrics onto one producer.
    The card-level ``confidence_score`` / ``status`` derive from the rows'
    Quality Score (``confidence_score``, a 0..1 fraction; the UI renders it as
    a "%" label).
    """
    rows = session.exec(
        select(VibeInput)
        .join(
            VibeInputContextLink,
            VibeInputContextLink.input_id == VibeInput.id,
        )
        .where(
            VibeInputContextLink.version_id == model_version_id,
            VibeInput.origin == VibeInputOrigin.AGENT_NEXT_VIBE.value,
            VibeInput.status == VibeInputStatus.ACTIVE.value,
        )
        .order_by(VibeInput.created_at)
    ).all()

    seen: set[str] = set()
    items: list[NextVibeItem] = []
    confidence: float | None = None
    for vi in rows:
        if vi.id in seen:
            continue
        seen.add(vi.id)
        items.append(_next_vibe_item_from_input(vi))
        if confidence is None and isinstance(vi.confidence_score, (int, float)):
            confidence = float(vi.confidence_score)

    status = ""
    if confidence is not None:
        status = "needs_work" if confidence < 0.8 else "healthy"

    return NextVibesOut(
        model_version_id=model_version_id,
        items=items,
        summary="",
        confidence_score=confidence,
        status=status,
    )


# Public re-export surface — these names are imported by both the legacy
# `router.py` (for the runs endpoints that still live there) and by the new
# per-resource modules.
__all__ = [
    "_get_agent_config",
    "_get_or_create_agent_config",
    "require_config",
    "resolve_warehouse_id",
    "build_job_run_url",
    "_build_dbx_job_url",
    "_build_run_out",
    "_NOTEBOOK_VERSION_RE",
    "parse_release_version_from_notebook",
    "parse_identity_from_ipynb",
    "fetch_upstream_agent_identity",
    "UPSTREAM_AGENT_NOTEBOOK_REPO_PATH",
    "_detect_notebook_version",
    "_detect_notebook_identity",
    "_preflight_notebook_access",
    "notebook_access",
    "NotebookAccess",
    "clear_notebook_access_cache",
    "_check_notebook_release",
    "_next_vibes_from_inputs",
    "_validate_next_vibe_ids",
    "delete_model_version",
    "gc_runs_for_deleted_version",
    "AUDIT_INTENTS",
    "require_catalog_name",
    "scan_rate_limited",
]
