"""``enlarge_to_ecm`` — wrap the agent's ``enlarge mvm`` op (ECM scope).

Less common than ``shrink_to_mvm``: take an MVM ModelVersion and expand
it back to a full Expanded Coverage Model. Useful when a team shipped
an MVM, gathered feedback / vibes, and now wants to grow the model into
the broader ECM scope without redoing the original generation.

See ``docs/orchestrator-design.md`` §10.
"""

from __future__ import annotations

from typing import Any, Literal, Optional

from pydantic import BaseModel, Field

from ...core._warehouse import get_warehouse_id
from ...db_models import Business, ModelVersion
from ._generation_common import (
    AGENT_OP_ENLARGE_MVM,
    DEFAULT_BOOLEAN_FORMAT,
    DEFAULT_DATE_FORMAT,
    DEFAULT_HISTORY_TRACKING_COLUMNS,
    DEFAULT_HOUSEKEEPING_COLUMNS,
    DEFAULT_NAMING_CONVENTION,
    DEFAULT_ORG_DIVISIONS,
    DEFAULT_PRIMARY_KEY_SUFFIX,
    DEFAULT_TABLE_ID_TYPE,
    DEFAULT_TAG_PREFIX,
    DEFAULT_TIMESTAMP_FORMAT,
    SCOPE_LABEL_ECM,
    _ShadowCtx,
    dispatch_generation_op,
    get_agent_job_id,
    observe_generation_op,
    rollback_generation_op,
)
from ._deployment_widgets import CATALOG_NAME_PATTERN, SCHEMA_PREFIX_PATTERN
from ._protocol import (
    Operation,
    OperationContext,
    OperationDispatchHandle,
    OperationObservation,
)


class EnlargeToEcmParams(BaseModel):
    """Params for ``enlarge_to_ecm``.

    ``parent_mvm_version_int`` is the version integer (1..N) of the MVM
    the agent reads from. The DAG factory threads this through from the
    prior ``shrink_to_mvm`` step's output (or a user-picked existing MVM).
    """

    # Optional: dispatch resolves from ``ctx.parent_version_id`` when
    # absent. See ``shrink_to_mvm`` for the same rationale.
    parent_mvm_version_int: Optional[int] = Field(default=None, ge=1)
    business_name: str = Field(pattern=r"^[a-z][a-z0-9_]+$")
    deployment_catalog: str = Field(pattern=CATALOG_NAME_PATTERN)
    cataloging_style: Literal[
        "One Catalog", "Catalog per Division", "Catalog per Domain",
    ]
    schema_prefix: str = Field(default="ecm_", pattern=SCHEMA_PREFIX_PATTERN, max_length=32)
    business_description: str = ""
    context_file: str = ""
    model_vibes: str = ""
    industry_alignment: str = ""
    business_domains: str = ""
    org_divisions: str = DEFAULT_ORG_DIVISIONS
    naming_convention: str = DEFAULT_NAMING_CONVENTION
    primary_key_suffix: str = DEFAULT_PRIMARY_KEY_SUFFIX
    schema_suffix: str = ""
    tag_prefix: str = DEFAULT_TAG_PREFIX
    tag_suffix: str = ""
    table_id_type: str = DEFAULT_TABLE_ID_TYPE
    boolean_format: str = DEFAULT_BOOLEAN_FORMAT
    date_format: str = DEFAULT_DATE_FORMAT
    timestamp_format: str = DEFAULT_TIMESTAMP_FORMAT
    classification_levels: str = ""
    housekeeping_columns: str = DEFAULT_HOUSEKEEPING_COLUMNS
    history_tracking_columns: str = DEFAULT_HISTORY_TRACKING_COLUMNS
    catalog_prefix: str = ""
    catalog_suffix: str = ""


class EnlargeToEcm(Operation):
    """Produce an ECM ModelVersion from a parent MVM via the agent's
    ``enlarge mvm`` operation."""

    name = "enlarge_to_ecm"
    params_model = EnlargeToEcmParams
    is_idempotent = False
    produces_version = True

    def dispatch(
        self,
        ctx: OperationContext,
        ws: Any,
        session: Any,
    ) -> OperationDispatchHandle:
        job_id = get_agent_job_id(session)
        if not job_id:
            raise RuntimeError(
                "enlarge_to_ecm: AgentConfig missing or has no job_id; "
                "cannot launch a Databricks run."
            )
        warehouse_id = get_warehouse_id(session)
        business = session.get(Business, ctx.business_id)
        if business is None:
            raise RuntimeError(
                f"enlarge_to_ecm: business_id {ctx.business_id!r} not found"
            )

        # `enlarge mvm` widget semantics: model_version is the BASE the
        # agent reads from (the MVM's version int). Resolve from params
        # if provided; otherwise from the parent ModelVersion row via
        # ``ctx.parent_version_id`` (canonical source per §2).
        parent_version_int = ctx.params.get("parent_mvm_version_int")
        if not parent_version_int and ctx.parent_version_id:
            parent_mv = session.get(ModelVersion, ctx.parent_version_id)
            if parent_mv is not None:
                parent_version_int = parent_mv.version
        if not parent_version_int:
            raise RuntimeError(
                "enlarge_to_ecm: cannot resolve parent MVM version int — "
                "neither params['parent_mvm_version_int'] nor "
                "ctx.parent_version_id were usable."
            )

        params_for_widgets = dict(ctx.params)
        params_for_widgets["model_version_int"] = parent_version_int
        return dispatch_generation_op(
            operation=AGENT_OP_ENLARGE_MVM,
            data_model_scopes=SCOPE_LABEL_ECM,
            ctx=_ShadowCtx(ctx, params_for_widgets),
            ws=ws,
            session=session,
            business=business,
            job_id=job_id,
            warehouse_id=warehouse_id,
            model_version=str(int(parent_version_int)),
        )

    def observe(
        self,
        handle: OperationDispatchHandle,
        ctx: OperationContext,
        ws: Any,
        session: Any,
    ) -> OperationObservation:
        return observe_generation_op(
            handle=handle,
            ctx=ctx,
            ws=ws,
            session=session,
            scope_short="ecm",
            agent_operation=AGENT_OP_ENLARGE_MVM,
        )

    def rollback(
        self,
        ctx: OperationContext,
        rollback_state: dict,
        ws: Any,
        session: Any,
    ) -> None:
        rollback_generation_op(
            ctx=ctx,
            rollback_state=rollback_state,
            ws=ws,
            session=session,
        )
