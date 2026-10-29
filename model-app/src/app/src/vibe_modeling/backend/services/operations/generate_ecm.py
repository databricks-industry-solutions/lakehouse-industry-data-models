"""``generate_ecm`` — wrap the agent's ``new base model`` op (ECM scope).

This is the most-common entry point: a fresh ECM ModelVersion produced
by the agent from a business description + (optional) model_vibes hints.
The op produces a new ModelVersion and, in One Catalog mode, the agent
also installs the schema inline. ``rollback`` undoes both.

See ``docs/orchestrator-design.md`` §10 for the failure-mode table.
"""

from __future__ import annotations

from typing import Any, Literal

from pydantic import BaseModel, Field
from sqlmodel import select

from ...core._warehouse import get_warehouse_id
from ...db_models import Business
from ._generation_common import (
    AGENT_OP_NEW_BASE_MODEL,
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


class GenerateEcmParams(BaseModel):
    """Pydantic schema for ``generate_ecm`` step params.

    Field-level rules are baked into the regexes / defaults here. The
    DAG factory is responsible for any cross-step rules (e.g. "the MVM
    schema_prefix in the next step must differ from this step's").
    """

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


class GenerateEcm(Operation):
    """Generate a fresh ECM ModelVersion via the agent's
    ``new base model`` operation."""

    name = "generate_ecm"
    params_model = GenerateEcmParams
    is_idempotent = False  # creates a new ModelVersion each invocation
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
                "generate_ecm: AgentConfig missing or has no job_id; "
                "cannot launch a Databricks run."
            )
        warehouse_id = get_warehouse_id(session)
        # Look up the Business for widget projection (name, description,
        # industry_alignment). The orchestrator guarantees `business_id`
        # references a real row at validate time.
        business = session.get(Business, ctx.business_id)
        if business is None:
            raise RuntimeError(
                f"generate_ecm: business_id {ctx.business_id!r} not found"
            )
        # `new base model` widget semantics: model_version is the OUTPUT
        # ordinal the agent will write to, not an input. We always start
        # with v1 — the app's own ModelVersion ordinal is allocated at
        # observe-time success.
        return dispatch_generation_op(
            operation=AGENT_OP_NEW_BASE_MODEL,
            data_model_scopes=SCOPE_LABEL_ECM,
            ctx=ctx,
            ws=ws,
            session=session,
            business=business,
            job_id=job_id,
            warehouse_id=warehouse_id,
            model_version="1",
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
            agent_operation=AGENT_OP_NEW_BASE_MODEL,
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
