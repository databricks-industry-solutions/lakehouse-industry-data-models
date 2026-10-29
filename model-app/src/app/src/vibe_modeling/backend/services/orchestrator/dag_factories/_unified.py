"""DAG factory for the ``new-base-model`` intent (group C).

DAG shape (uniform across all ``cataloging_style`` values):

    ``generate_ecm`` → ``shrink_to_mvm``

The agent inline-installs in every cataloging style (integration guide
§12 "Operational Modes" — Stage 12 Physical Schema Construction runs
inside both ``generate_ecm`` and ``shrink_to_mvm`` regardless of style).
A separate explicit ``install`` op would re-run the install pointing at
the same place the agent already wrote to. See the Decision Log entry
"Multi-catalog new-base-model DAGs collapsed from 4 phases to 2".

The factory is a pure function: it consults the request, the business,
the agent config, and any business context, but does not touch the DB
or the workspace. The validator (``services.orchestrator.validate``)
takes the produced :class:`Dag` and runs each step's
``params_model`` plus the cross-step rules.
"""

from __future__ import annotations

from typing import Optional

from ....core import resolve_run_target_catalog
from ....core._names import sanitize_catalog_segment
from ....db_models import AgentConfig, Business, BusinessContext
from ....models import RUN_CONVENTION_FIELDS, Intent, RunIn
from ..dag import Dag, OperationStep


_INTENT_NAME = Intent.NEW_BASE_MODEL.value


def _resolve_cataloging_style(req: RunIn) -> str:
    """Default to ``One Catalog`` when the caller didn't specify one.

    Mirrors the legacy ``router.create_run`` behaviour so existing tests
    that omit ``cataloging_style`` continue to land on the same DAG
    shape.
    """
    style = (req.cataloging_style or "One Catalog").strip()
    return style or "One Catalog"


def _resolve_ecm_prefix(req: RunIn, cataloging_style: str) -> str:
    """Default ECM prefix mirrors ``router.create_run`` (#122)."""
    if req.ecm_schema_prefix is not None:
        return req.ecm_schema_prefix
    return "ecm_" if cataloging_style == "One Catalog" else ""


def _resolve_mvm_prefix(req: RunIn, cataloging_style: str) -> str:
    """Default MVM prefix mirrors ``router.create_run`` (#122)."""
    if req.mvm_schema_prefix is not None:
        return req.mvm_schema_prefix
    return "mvm_" if cataloging_style == "One Catalog" else ""


def _shared_params(
    req: RunIn,
    business: Business,
    cataloging_style: str,
    deployment_catalog: str,
) -> dict:
    """Convention overrides that flow into both ECM and MVM ops.

    Mirrors the ``_convention_fields`` list the legacy ``create_run``
    folded into widget params. The orchestrator persists this dict as
    ``RunOperation.params_json`` so dispatch-time validation can replay
    against the registered ``params_model`` without rebuilding it.
    """
    # The primitive's params_model enforces a lowercase identifier
    # regex on ``business_name``, so sanitize the human display name
    # here. The agent receives the sanitized form in widgets.
    out = {
        "business_name": sanitize_catalog_segment(business.name),
        "deployment_catalog": deployment_catalog,
        "cataloging_style": cataloging_style,
    }
    # Pass through any optional convention overrides verbatim. The op's
    # Pydantic model owns field-level rules and defaults.
    for field in RUN_CONVENTION_FIELDS:
        v = getattr(req, field, None)
        if v is not None:
            out[field] = v
    return out


def _generate_ecm_params(
    req: RunIn,
    business: Business,
    business_context: Optional[BusinessContext],
    cataloging_style: str,
    deployment_catalog: str,
    ecm_prefix: str,
) -> dict:
    """Compose the params dict for the leading ``generate_ecm`` step.

    ``business_description`` carries only the durable business context (the
    business's own description or ``req.business_context_text`` override).
    Per-run instructions (``req.vibe_instructions``) flow exclusively through
    the ``model_vibes`` widget — they must not be duplicated into
    ``business_description``, which would waste prompt budget by handing the
    agent the same text twice in different widgets.
    """
    params = _shared_params(req, business, cataloging_style, deployment_catalog)
    params["schema_prefix"] = ecm_prefix

    # Build the business_description widget value.  Start from inline text
    # (highest precedence), then fall back to the business's own description.
    base_context = (req.business_context_text or "").strip() or (business.description or "").strip()
    if base_context:
        params["business_description"] = base_context

    if req.business_context_path:
        params["context_file"] = req.business_context_path
    if req.vibe_instructions:
        params["model_vibes"] = req.vibe_instructions
    params["industry_alignment"] = business.industry_alignment or ""
    return params


def _shrink_to_mvm_params(
    req: RunIn,
    business: Business,
    cataloging_style: str,
    deployment_catalog: str,
    mvm_prefix: str,
) -> dict:
    """Compose the params dict for the ``shrink_to_mvm`` step.

    ``parent_ecm_version_int`` is intentionally left unset — the
    orchestrator threads ``parent_version_id`` from the prior
    ``generate_ecm`` step (via ``needs_version_from``), and the
    primitive resolves the int from the ModelVersion row. DAG factories
    that want to pin a specific int can set it explicitly; the linear
    new-base-model flow always uses whatever ``generate_ecm`` produced.
    """
    params = _shared_params(req, business, cataloging_style, deployment_catalog)
    params["schema_prefix"] = mvm_prefix
    params["mvm_schema_prefix"] = mvm_prefix
    params["industry_alignment"] = business.industry_alignment or ""
    return params


def dag_for_new_base_model(
    req: RunIn,
    business: Business,
    business_context: Optional[BusinessContext] = None,
    agent_config: Optional[AgentConfig] = None,
) -> Dag:
    """Build the ``new-base-model`` DAG for the supplied request.

    See module docstring for the uniform 2-op shape. This function never
    raises — invalid params surface as Pydantic errors out of
    ``validate_dag`` (the validator owns Gate B). The factory's job is
    purely to compose the steps.
    """
    cataloging_style = _resolve_cataloging_style(req)
    deployment_catalog = resolve_run_target_catalog(req, agent_config)
    ecm_prefix = _resolve_ecm_prefix(req, cataloging_style)
    mvm_prefix = _resolve_mvm_prefix(req, cataloging_style)

    return Dag(
        intent=_INTENT_NAME,
        steps=(
            OperationStep(
                name="generate_ecm",
                params=_generate_ecm_params(
                    req,
                    business,
                    business_context,
                    cataloging_style,
                    deployment_catalog,
                    ecm_prefix,
                ),
            ),
            OperationStep(
                name="shrink_to_mvm",
                params=_shrink_to_mvm_params(
                    req,
                    business,
                    cataloging_style,
                    deployment_catalog,
                    mvm_prefix,
                ),
                needs_version_from="generate_ecm",
            ),
        ),
    )
