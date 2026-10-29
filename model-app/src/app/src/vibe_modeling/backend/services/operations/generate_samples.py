"""``generate_samples`` deployment primitive.

Wraps the agent's ``generate sample data`` notebook operation. No
rollback — the sample rows live inside the installed schemas, so an
``uninstall`` of the parent deployment removes them along with the
schemas (see ``docs/orchestrator-design.md`` §2 + §10).

- ``produces_version=False``: sample-data generation never creates a
  new ``ModelVersion``.
- ``is_idempotent=True``: re-running against the same install replaces
  the previous sample rows (the agent's ``generate sample data`` op is
  idempotent by design — it truncates+reloads on re-run).
- Polling: Jobs API only. See ``backend.job_launcher.LIFECYCLE_OPS``.
- Rollback: not supported. To remove sample rows, uninstall the parent
  deployment (which drops the schemas wholesale).
"""

from __future__ import annotations

from typing import Any, Literal, Optional

from pydantic import BaseModel, Field
from sqlmodel import select

from ...core._intents import AGENT_OP_GENERATE_SAMPLES
from ...db_models import AgentConfig
from ...job_launcher import (
    build_job_tags_from_session,
    generate_session_id,
    launch_run,
    session_id_to_bigint,
)
from ._deployment_widgets import CATALOG_NAME_PATTERN, scope_label
from ._protocol import (
    Operation,
    OperationContext,
    OperationDispatchHandle,
    OperationObservation,
    OperationResult,
)


class GenerateSamplesParams(BaseModel):
    """Parameters for the ``generate_samples`` primitive."""

    business_name: str = Field(min_length=1, pattern=r"^[a-z][a-z0-9_]+$")
    deployment_catalog: str = Field(min_length=1, pattern=CATALOG_NAME_PATTERN)
    schema_prefix: str = ""
    scope: Literal["ecm", "mvm"]
    model_version: int = Field(gt=0)
    # Universal widget (see ``_deployment_widgets`` module docstring +
    # integration-guide.md's base_parameters table) — the agent needs it
    # to know whether the target schemas are scope-prefixed inside a
    # shared catalog ("One Catalog") or live bare in a dedicated per-scope
    # catalog. Was silently dropped between ``dag_for_generate_samples``
    # (which computes it) and this params model / the dispatched widgets
    # until the Group B widget-contract test caught the gap.
    cataloging_style: Literal[
        "One Catalog", "Catalog per Division", "Catalog per Domain"
    ] = "One Catalog"
    # Sanity cap: an unbounded sample run would idle a warehouse for
    # hours and cost real money. 1000 rows is the practical upper bound
    # for demo / preview data; the test agent's adversarial cap test
    # uses 10_000_001 (well above this) and the dev's smoke test uses
    # 2000 (also above) — both must reject.
    sample_count: int = Field(default=10, ge=1, le=1000)


def _build_generate_samples_widgets(
    p: GenerateSamplesParams, session_id_bigint: str
) -> dict[str, str]:
    """Compose the ``generate sample data`` widget map.

    ``generate_samples`` widget is the row count per table — passed as a
    string per the agent's widget contract (see
    ``backend.job_launcher.map_run_params_to_widgets``).
    """
    return {
        "operation": AGENT_OP_GENERATE_SAMPLES,
        "business_name": p.business_name,
        "deployment_catalog": p.deployment_catalog,
        "data_model_scopes": scope_label(p.scope),
        "model_version": str(p.model_version),
        "schema_prefix": p.schema_prefix,
        "cataloging_style": p.cataloging_style,
        "generate_samples": str(p.sample_count),
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


class GenerateSamples(Operation):
    """``generate sample data`` primitive (Group B — deployment)."""

    name = "generate_samples"
    params_model = GenerateSamplesParams
    is_idempotent = True
    produces_version = False
    # Rollback undoes nothing (see ``rollback``): the sample rows stand.
    rollback_is_noop = True

    def dispatch(
        self,
        ctx: OperationContext,
        ws: Any,
        session: Any,
    ) -> OperationDispatchHandle:
        params = GenerateSamplesParams(**ctx.params)

        sid = generate_session_id()
        sid_bigint = str(session_id_to_bigint(sid))
        widgets = _build_generate_samples_widgets(params, sid_bigint)

        job_id = _resolve_agent_job_id(session)
        if not job_id:
            raise RuntimeError(
                "Agent not configured — cannot dispatch "
                "`generate_samples` primitive."
            )

        job_tags = build_job_tags_from_session(
            session,
            business_name=params.business_name,
            version=str(params.model_version),
            operation="generate samples",
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
                "sample_count": params.sample_count,
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

    def rollback(
        self,
        ctx: OperationContext,
        rollback_state: dict,
        ws: Any,
        session: Any,
    ) -> None:
        """No rollback. Sample rows live inside installed schemas; the
        parent ``install``'s rollback (uninstall) drops them with the
        schema."""
        return None
