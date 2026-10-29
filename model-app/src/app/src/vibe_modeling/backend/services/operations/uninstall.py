"""``uninstall`` deployment primitive.

Wraps the agent's ``uninstall model version`` notebook operation. No
rollback — uninstall IS the rollback in the inverse direction (see
``docs/orchestrator-design.md`` §2 + §10).

- ``produces_version=False``: uninstall does not write to ``ModelVersion``.
- ``is_idempotent=True``: re-uninstalling missing schemas is a no-op
  (the agent treats missing schemas as success).
- Polling: Jobs API only. See ``backend.job_launcher.LIFECYCLE_OPS``.
- Result: the agent's exit JSON is read once the job succeeds. Drops it could
  not do (``failed`` above zero) leave the version uninstalled and become a
  run warning (:data:`_protocol.RUN_WARNINGS_KEY`); an unreadable result is
  logged and changes nothing.
- Registry release: after every successful uninstall the version's rows in
  the uninstall catalog's ``_metamodel.business`` get ``deploy_status =
  'dry_run'`` (:func:`metamodel_registry.set_deploy_status`). The agent's
  uninstall writes nothing to its registry (``_run_undeploy_model``, nb
  104796-105060), so without it the uninstalled version stays an owner of
  its schema names (the ownership snapshot skips only ``dry_run`` rows,
  nb 7926-7927). A release that fails or is still running becomes a run
  warning with the exact UPDATE, and the step records it as pending
  (:data:`REGISTRY_RELEASE_PENDING_KEY`); :func:`retry_registry_releases`
  issues it again when the next run step into that catalog is dispatched.
  A release that goes through is recorded on the step
  (:data:`REGISTRY_RELEASED_KEY`): from then on the app no longer counts
  the version as installed in that catalog for the agent
  (``_version_lifecycle.released_from``).
- Rollback: not supported. The orchestrator never reverses an uninstall;
  to "undo" an uninstall the user must run a fresh ``install``.
"""

from __future__ import annotations

import json
import logging
import re
from typing import Any, Literal, Optional

from pydantic import BaseModel, Field
from sqlmodel import col, select

from ...core._intents import AGENT_OP_UNINSTALL
from ...core._json import json_object
from ...core._warehouse import get_warehouse_id
from ...db_models import AgentConfig, ModelVersion, RunOperation
from ...job_launcher import (
    build_job_tags_from_session,
    generate_session_id,
    launch_run,
    session_id_to_bigint,
)
from ..schema_names import (
    SurvivingSchemas,
    install_schema_names,
    recorded_schema_names,
    surviving_schemas,
)
from ._agent_result import agent_exit_result
from ._deployment_widgets import CATALOG_NAME_PATTERN, scope_label
from ..metamodel_registry import DRY_RUN_STATUS, deploy_status_statement, set_deploy_status
from ._version_lifecycle import (
    REGISTRY_RELEASE_PENDING_KEY,
    REGISTRY_RELEASED_KEY,
    installed_catalogs,
    mark_version_uninstalled,
)
from ._protocol import (
    RUN_WARNINGS_KEY,
    Operation,
    OperationContext,
    OperationDispatchHandle,
    OperationObservation,
    OperationResult,
)

logger = logging.getLogger(__name__)

_UNREADABLE = "The agent's result could not be read, so the schemas it could not drop, if any, are not known."

# The agent's uninstall exit JSON (nb 108480-108492): ``failed`` is the number
# of databases whose ``DROP DATABASE ... CASCADE`` raised (the `_metrics`
# database included, nb 108430-108444) and ``warnings`` carries "⚠️ N
# database(s) failed to drop" when it is above zero (nb 108463). It carries no
# database names; they are only in the job's stdout, so the survivors are read
# from Unity Catalog (``schema_names.surviving_schemas``). ``warnings`` also
# holds unrelated notes (nb 108248, progress tracking disabled), so the count
# is what decides.
_FAILED_TO_DROP = re.compile(r"(\d+) database\(s\) failed to drop")

# The uninstall step waits up to 30 s for its release; a retry runs before a
# step is dispatched, so it waits 5 s and then leaves the UPDATE running.
_RETRY_WAIT = "5s"
_CAN_DROP = "Their owner, or someone with the right privileges, can drop them."


def failed_drop_count(result: dict) -> int:
    """How many databases the agent could not drop, from its exit JSON: the
    ``failed`` count, else the number in its "failed to drop" warning."""
    failed = result.get("failed")
    if isinstance(failed, int) and not isinstance(failed, bool):
        return max(failed, 0)
    for warning in result.get("warnings") or []:
        match = _FAILED_TO_DROP.search(str(warning))
        if match:
            return int(match.group(1))
    return 0


def _plural(n: int, word: str) -> str:
    return f"{n} {word}" if n == 1 else f"{n} {word}s"


def left_behind_warning(
    failed: int,
    catalog: str,
    version: int,
    scope: str,
    survivors: Optional[SurvivingSchemas] = None,
    reused_by: Optional[tuple[str, list[str]]] = None,
) -> str:
    """The run warning for ``failed`` databases the uninstall left behind.

    ``survivors`` is what Unity Catalog still holds of the version (None when
    it could not be read, or nothing was identified): the text then gives the
    count only. Else it lists the schema names, qualified with their catalog
    when it is not ``catalog``, notes the shared ``_metrics`` schema when it
    survived, and counts the failed drops it could not name.
    ``reused_by`` is ``(label, names)`` of a version this run installs next
    into some of those names.
    """
    lead = f"v{version} {scope.upper()} is uninstalled from {catalog}, but"
    named = [n if c.lower() == catalog.lower() else f"{c}.{n}" for c, n in (survivors.schemas if survivors else ())]
    metrics = list(survivors.metrics_catalogs) if survivors else []
    if not named and not metrics:
        return f"{lead} {_plural(failed, 'schema')} could not be dropped and {'is' if failed == 1 else 'are'} still there."
    parts = []
    if named:
        parts.append(f"{lead} these schemas could not be dropped and are still there: {', '.join(named)}.")
    if metrics:
        where = "in " + ", ".join(metrics)
        if named:
            parts.append(f"The shared _metrics schema {where} is also still there.")
        else:
            parts.append(f"{lead} the shared _metrics schema {where} could not be dropped and is still there.")
    unnamed = failed - len(named) - len(metrics)
    if unnamed > 0:
        parts.append(f"{_plural(unnamed, 'more schema')} could not be identified.")
    if reused_by:
        label, names = reused_by
        parts.append(f"{label} installs into {', '.join(names)} next, so their old tables may remain next to {label.split()[0]}'s.")
    else:
        parts.append(_CAN_DROP if named else "Its owner, or someone with the right privileges, can drop it.")
    return " ".join(parts)


def _next_install_reuse(
    session: Any, ctx: OperationContext, catalog: str, left: set[str],
) -> Optional[tuple[str, list[str]]]:
    """``(label, names)`` when this run installs a version into ``catalog``
    next and it takes some of the ``left`` schema names (an install over the
    occupant)."""
    this = session.get(RunOperation, ctx.operation_id) if ctx.operation_id else None
    after = this.step_index if this is not None else -1
    rows = session.exec(
        select(RunOperation).where(
            RunOperation.run_id == ctx.run_id,
            RunOperation.operation_name == "install",
            RunOperation.status.in_(("pending", "running")),
            RunOperation.step_index > after,
        ).order_by(RunOperation.step_index)
    ).all()
    for row in rows:
        params = json_object(row.params_json)
        if str(params.get("deployment_catalog") or "").strip().lower() != catalog.strip().lower():
            continue
        version_id = params.get("version_id") or row.parent_version_id
        mv = session.get(ModelVersion, version_id) if version_id else None
        if mv is None:
            continue
        scope = params.get("scope") or mv.scope
        takes = {n.lower() for n in recorded_schema_names(session, mv.id, scope, catalog)}
        takes |= {
            n.lower() for n in install_schema_names(
                session, mv.id, prefix=str(params.get("schema_prefix") or ""), suffix="",
            )
        }
        shared = sorted(left & takes)
        if shared:
            return f"v{mv.version} {str(scope or mv.scope).upper()}", shared
    return None


def _installed_catalogs(session: Any, version_id: Optional[str]) -> list[str]:
    """The catalogs the version is installed in now; empty when unreadable."""
    try:
        mv = session.get(ModelVersion, version_id) if version_id else None
        return installed_catalogs(session, mv) if mv is not None else []
    except Exception as exc:  # noqa: BLE001 - only widens which catalogs are read
        logger.warning("uninstall: could not read the install catalogs of %s (%s)", version_id, type(exc).__name__)
        return []


def _left_behind(
    session: Any, ws: Any, ctx: OperationContext, params: "UninstallParams", failed: int, installed_before: list[str],
) -> str:
    """The warning for a partial uninstall. One Catalog keeps a version's
    schemas in the one catalog; Catalog per Division and Catalog per Domain
    spread them over the catalogs it is installed in (``installed_before``,
    read before the uninstall closes them). Reading the catalogs is best
    effort: when it fails the warning gives the count."""
    survivors: Optional[SurvivingSchemas] = None
    reused: Optional[tuple[str, list[str]]] = None
    try:
        if params.version_id:
            survivors = surviving_schemas(
                session, ws, params.version_id, params.scope,
                [params.deployment_catalog, *installed_before], prefix=params.schema_prefix,
            )
        if survivors is not None and survivors.schemas:
            left = {n for c, n in survivors.schemas if c.lower() == params.deployment_catalog.lower()}
            reused = _next_install_reuse(session, ctx, params.deployment_catalog, left) if left else None
    except Exception as exc:  # noqa: BLE001 - the count stands in for names
        logger.warning(
            "uninstall run %s: could not read the schemas left in %s (%s)",
            ctx.run_id, params.deployment_catalog, type(exc).__name__,
        )
        survivors = None
    return left_behind_warning(
        failed, params.deployment_catalog, params.model_version, params.scope, survivors, reused,
    )


def release_failed_warning(catalog: str, version: int, scope: str) -> str:
    return (
        f"v{version} {scope.upper()} is uninstalled from {catalog}, but the app may not have "
        f"marked it as not installed in {catalog}'s _metamodel. The agent may still treat it as "
        f"the owner of its schema names. The app tries again when the next install or run into "
        f"{catalog} starts; an admin can also run the statement below."
    )


def _release_registry_rows(ws: Any, session: Any, params: "UninstallParams", run_id: Optional[str]) -> Optional[dict]:
    """Mark the uninstalled version's registry rows ``dry_run`` in the
    uninstall catalog. ``None`` when done; else the pending release
    (:data:`REGISTRY_RELEASE_PENDING_KEY`) to record on the step."""
    statement = deploy_status_statement(
        params.deployment_catalog, params.business_name, params.model_version, params.scope, DRY_RUN_STATUS,
    )
    warehouse_id = get_warehouse_id(session)
    try:
        if not warehouse_id:
            raise RuntimeError("no SQL warehouse is configured")
        set_deploy_status(
            ws, warehouse_id, params.deployment_catalog, params.business_name,
            params.model_version, params.scope, DRY_RUN_STATUS,
        )
        return None
    except Exception as exc:  # noqa: BLE001 - the uninstall stands; the release is retried
        logger.warning(
            "uninstall run %s: could not release v%s %s in %s._metamodel (%s)",
            run_id, params.model_version, params.scope, params.deployment_catalog, exc,
        )
    return {
        "catalog": params.deployment_catalog,
        "business_name": params.business_name,
        "model_version": params.model_version,
        "scope": params.scope,
        "version_id": params.version_id,
        "sql": statement,
    }


def _pending_releases(session: Any) -> list[tuple[RunOperation, dict, dict]]:
    out = []
    for row in session.exec(
        select(RunOperation).where(
            RunOperation.operation_name == "uninstall",
            RunOperation.status == "succeeded",
            col(RunOperation.rollback_state_json).contains(REGISTRY_RELEASE_PENDING_KEY),
        )
    ).all():
        state = json_object(row.rollback_state_json)
        pending = state.get(REGISTRY_RELEASE_PENDING_KEY)
        if isinstance(pending, dict):
            out.append((row, state, pending))
    return out


def retry_registry_releases(session: Any, ws: Any, catalog: str) -> None:
    """Issue again the registry releases earlier uninstalls from ``catalog``
    could not complete. A version installed in ``catalog`` again since needs
    none (its install registered it as ``installed``). A release that goes
    through clears its pending record and records the release; one that
    fails stays for the next run. Never raises."""
    target = (catalog or "").strip().lower()
    if not target or ws is None:
        return
    try:
        pending = [p for p in _pending_releases(session) if str(p[2].get("catalog") or "").lower() == target]
        warehouse_id = get_warehouse_id(session) if pending else ""
        for row, state, release in pending:
            mv = session.get(ModelVersion, release.get("version_id")) if release.get("version_id") else None
            reinstalled = mv is not None and target in {c.lower() for c in installed_catalogs(session, mv)}
            if not reinstalled:
                if not warehouse_id:
                    continue
                try:
                    set_deploy_status(
                        ws, warehouse_id, str(release["catalog"]), str(release["business_name"]),
                        int(release["model_version"]), str(release["scope"]), DRY_RUN_STATUS,
                        wait=_RETRY_WAIT,
                    )
                except Exception as exc:  # noqa: BLE001 - kept for the next run
                    logger.warning(
                        "registry release retry for uninstall step %s in %s failed (%s)", row.id, catalog, exc,
                    )
                    continue
                state[REGISTRY_RELEASED_KEY] = True
            state.pop(REGISTRY_RELEASE_PENDING_KEY, None)
            row.rollback_state_json = json.dumps(state)
            session.add(row)
        session.flush()
    except Exception as exc:  # noqa: BLE001 - a retry never stops the run that triggered it
        logger.warning("registry release retry in %s skipped (%s)", catalog, type(exc).__name__)


class UninstallParams(BaseModel):
    """Parameters for the ``uninstall`` primitive."""

    business_name: str = Field(min_length=1, pattern=r"^[a-z][a-z0-9_]+$")
    deployment_catalog: str = Field(min_length=1, pattern=CATALOG_NAME_PATTERN)
    schema_prefix: str = ""
    scope: Literal["ecm", "mvm"]
    model_version: int = Field(gt=0)
    cataloging_style: Literal[
        "One Catalog", "Catalog per Division", "Catalog per Domain"
    ] = "One Catalog"
    # Lakebase ``ModelVersion.id`` of the version being uninstalled.
    # Carried so ``observe`` can flip ``deployment_status='uninstalled'``
    # the moment the agent reports terminal success — without it, the UI
    # keeps showing "Installed" after a successful uninstall (the agent
    # has no idea the app's Lakebase row exists).
    version_id: Optional[str] = None
    # No agent job: the version's install row in the catalog closes and its
    # registry rows are released. For a source-industry version the run's
    # business already replaced there (``orchestrator.source_industry``),
    # whose schemas are now the business's: the agent uninstall would drop
    # them.
    release_only: bool = False


def _build_uninstall_widgets(p: UninstallParams, session_id_bigint: str) -> dict[str, str]:
    """Compose the ``uninstall model version`` widget map.

    The agent's uninstall op is parameterised by (catalog, business_name,
    version) — schema_prefix + cataloging_style let it find the exact
    schemas the matching install laid down (One Catalog uses
    ``{prefix}{domain}`` schemas; Catalog-per-* uses dedicated catalogs
    and the prefix is empty).

    ``data_model_scopes`` is a universal agent widget (see the integration
    guide's "Widget values to pass as base_parameters" table), not an
    install-only one. Before this was added here, an uninstall dispatch
    omitted it entirely and the agent's Model Scope widget fell back to
    its own default (MVM) regardless of which scope was actually being
    uninstalled — verified live: an ECM uninstall (``schema_prefix=
    "ecm_"``) dropped all of the business's ``mvm_*`` schemas instead of
    the intended ``ecm_*`` ones. Must always be set, matching
    ``install``/``generate_samples``.
    """
    return {
        "operation": AGENT_OP_UNINSTALL,
        "business_name": p.business_name,
        "deployment_catalog": p.deployment_catalog,
        "data_model_scopes": scope_label(p.scope),
        "model_version": str(p.model_version),
        "schema_prefix": p.schema_prefix,
        "cataloging_style": p.cataloging_style,
        "vibe_session_id": session_id_bigint,
    }


def _resolve_agent_job_id(session: Any) -> Optional[int]:
    cfg = session.exec(select(AgentConfig).limit(1)).first()
    if not cfg or not cfg.job_id:
        return None
    return cfg.job_id


def _terminal_observation(
    *, succeeded: bool, error: Optional[str], rollback_state: dict
) -> OperationObservation:
    return OperationObservation(
        progress_percent=100,
        progress_message="completed" if succeeded else (error or "failed"),
        is_terminal=True,
        terminal_result=OperationResult(
            succeeded=succeeded,
            output_version_id=None,
            output_artifacts=[],
            rollback_state=rollback_state,
            error=error,
        ),
    )


def _mark_version_uninstalled(
    session: Any, version_id: Optional[str], catalog: str, run_id: Optional[str],
) -> None:
    """Record a successful uninstall from ``catalog`` on the version
    (:func:`_version_lifecycle.mark_version_uninstalled`): that catalog's
    install row closes; a version still installed elsewhere stays deployed.
    No-op without a ``version_id`` or row: uninstall is idempotent
    metadata-wise."""
    if not version_id:
        return
    mv = session.get(ModelVersion, version_id)
    if mv is not None:
        mark_version_uninstalled(session, mv, catalog, run_id=run_id)


class Uninstall(Operation):
    """``uninstall model version`` primitive (Group B — deployment)."""

    name = "uninstall"
    params_model = UninstallParams
    is_idempotent = True
    produces_version = False
    # Uninstall has no rollback (see ``rollback``).
    rollback_is_noop = True

    def dispatch(
        self,
        ctx: OperationContext,
        ws: Any,
        session: Any,
    ) -> OperationDispatchHandle:
        params = UninstallParams(**ctx.params)
        if params.release_only:
            return OperationDispatchHandle(
                databricks_run_id=None, vibe_session_id=None, extra={"release_only": True},
            )

        sid = generate_session_id()
        sid_bigint = str(session_id_to_bigint(sid))
        widgets = _build_uninstall_widgets(params, sid_bigint)

        job_id = _resolve_agent_job_id(session)
        if not job_id:
            raise RuntimeError(
                "Agent not configured — cannot dispatch `uninstall` primitive."
            )

        job_tags = build_job_tags_from_session(
            session,
            business_name=params.business_name,
            version=str(params.model_version),
            operation="uninstall",
            session_id=sid,
        )
        dbx_run_id = launch_run(ws, job_id, widgets, job_tags=job_tags)
        return OperationDispatchHandle(
            databricks_run_id=dbx_run_id,
            vibe_session_id=sid,
            extra={
                "deployment_catalog": params.deployment_catalog,
                "model_version": params.model_version,
                "business_name": params.business_name,
            },
            dispatched_widgets=widgets,
        )

    def observe(
        self,
        handle: OperationDispatchHandle,
        ctx: OperationContext,
        ws: Any,
        session: Any,
    ) -> OperationObservation:
        if ctx.params.get("release_only"):
            rollback_state: dict = {"release_only": True}
            self._finish(session, ws, ctx, UninstallParams(**ctx.params), rollback_state, [])
            return _terminal_observation(succeeded=True, error=None, rollback_state=rollback_state)
        if handle.databricks_run_id is None:
            return OperationObservation(
                progress_percent=0,
                progress_message="awaiting dispatch",
                is_terminal=False,
                terminal_result=None,
            )

        try:
            job_run = ws.jobs.get_run(handle.databricks_run_id)
        except Exception as e:  # noqa: BLE001 — surface the message
            return OperationObservation(
                progress_percent=0,
                progress_message=f"poll error: {e!r}",
                is_terminal=False,
                terminal_result=None,
            )

        state = getattr(job_run, "state", None)
        lcs = ""
        rs = ""
        state_message = ""
        if state is not None:
            lcs_obj = getattr(state, "life_cycle_state", None)
            rs_obj = getattr(state, "result_state", None)
            lcs = getattr(lcs_obj, "value", "") if lcs_obj is not None else ""
            rs = getattr(rs_obj, "value", "") if rs_obj is not None else ""
            state_message = getattr(state, "state_message", "") or ""

        rollback_state = {
            "databricks_run_id": handle.databricks_run_id,
            "jobs_terminal_result_state": rs,
        }

        if lcs == "TERMINATED":
            succeeded = rs == "SUCCESS"
            error = None if succeeded else (state_message or f"Job ended with {rs}")
            if succeeded:
                exit_result = agent_exit_result(
                    ws, job_run, handle.databricks_run_id, unreadable=_UNREADABLE,
                )
                if exit_result.retry:
                    return OperationObservation(
                        progress_percent=90,
                        progress_message="reading the agent's result",
                        is_terminal=False,
                        terminal_result=None,
                    )
                params = UninstallParams(**ctx.params)
                failed = 0 if exit_result.failure else failed_drop_count(exit_result.result or {})
                # Read before the install row closes: the catalogs it was in.
                installed_before = (
                    _installed_catalogs(session, params.version_id)
                    if failed > 0 and params.cataloging_style != "One Catalog" else []
                )
                # The agent reports "success" even when there was nothing
                # to drop (DROP SCHEMA IF EXISTS is a no-op on missing
                # schemas) or when some drops failed. The version is no
                # longer installed either way, so it is marked uninstalled
                # and the UI stops showing a phantom "Installed" badge; the
                # schemas the agent could not drop become a run warning.
                warnings: list = []
                if exit_result.failure:
                    logger.warning(
                        "uninstall run %s: %s The version is recorded as uninstalled without it.",
                        ctx.run_id, exit_result.failure,
                    )
                elif failed > 0:
                    warnings.append(_left_behind(session, ws, ctx, params, failed, installed_before))
                self._finish(session, ws, ctx, params, rollback_state, warnings)
            return _terminal_observation(
                succeeded=succeeded, error=error, rollback_state=rollback_state
            )
        if lcs in ("INTERNAL_ERROR", "SKIPPED"):
            return _terminal_observation(
                succeeded=False,
                error=state_message or lcs,
                rollback_state=rollback_state,
            )
        return OperationObservation(
            progress_percent=10,
            progress_message=f"{lcs}/{rs}" if lcs else "running",
            is_terminal=False,
            terminal_result=None,
        )

    @staticmethod
    def _finish(
        session: Any, ws: Any, ctx: OperationContext, params: "UninstallParams",
        rollback_state: dict, warnings: list,
    ) -> None:
        """A successful uninstall: the catalog's install row closes, the
        registry rows are released (recorded as released; a failed release
        becomes a warning and a pending record), and ``warnings`` go into
        ``rollback_state``."""
        _mark_version_uninstalled(session, params.version_id, params.deployment_catalog, ctx.run_id)
        pending = _release_registry_rows(ws, session, params, ctx.run_id)
        if pending is None:
            rollback_state[REGISTRY_RELEASED_KEY] = True
        else:
            rollback_state[REGISTRY_RELEASE_PENDING_KEY] = pending
            warnings.append({
                "message": release_failed_warning(params.deployment_catalog, params.model_version, params.scope),
                "sql": pending["sql"],
            })
        if warnings:
            rollback_state[RUN_WARNINGS_KEY] = warnings

    def rollback(
        self,
        ctx: OperationContext,
        rollback_state: dict,
        ws: Any,
        session: Any,
    ) -> None:
        """Uninstall has no rollback (uninstall IS the rollback).

        The orchestrator iterates ``RunOperation`` rows in reverse step
        order and calls ``rollback()`` on every succeeded op. For
        ``uninstall``, the only honest semantics is to do nothing:
        re-installing the schemas would require a fresh ModelVersion the
        orchestrator does not own. Operators who want to "undo" an
        uninstall must launch a new ``install`` run.
        """
        return None
