"""DAG factory for the ``vibe-new-ecm-mvm`` intent.

Internal authoring helper. Produces matched ECM/MVM versions in one run
by vibing an existing ECM and then automatically shrinking to MVM. Same
DAG shape as ``new-base-model`` but with ``vibe_iterate`` substituting
for ``generate_ecm`` as the leading version-producing step.

DAG shape (uniform across all ``cataloging_style`` values):

    ``vibe_iterate`` → ``shrink_to_mvm``

The agent inline-installs in every cataloging style (integration guide
§12 "Operational Modes"). See the Decision Log entry "Multi-catalog
new-base-model DAGs collapsed from 4 phases to 2".

Per the per-scope version counter invariant: the orchestrator's
``_terminal_success`` reads the agent's ``generated_from_version`` tag
on the produced ``model.json``. For shrink-with-parent-ECM, this mirrors
the ECM's version int onto the MVM, so a single run produces matched
ECM-v(N+1) + MVM-v(N+1) deterministically.

The factory is a pure function. Validation runs separately via
``services.orchestrator.validate.validate_dag``.
"""

from __future__ import annotations

from typing import Optional

from ....core._names import sanitize_catalog_segment
from ....db_models import AgentConfig, Business, BusinessContext
from ....models import RUN_CONVENTION_FIELDS, Intent, RunIn
from ..dag import Dag, OperationStep
from ....core import resolve_run_target_catalog
from ._unified import (
    _resolve_cataloging_style,
    _resolve_ecm_prefix,
    _resolve_mvm_prefix,
    _shrink_to_mvm_params,
)


_INTENT_NAME = Intent.VIBE_NEW_ECM_MVM.value


def _vibe_iterate_params(
    req: RunIn,
    business: Business,
    cataloging_style: str,
    deployment_catalog: str,
    ecm_prefix: str,
) -> dict:
    """Compose the params dict for the leading ``vibe_iterate`` step.

    Mirrors :func:`_generate_ecm_params` from the ``new-base-model``
    factory but matches ``VibeIterateParams`` — the agent's vibe op uses
    different widget names than ``generate_ecm`` for some carry-keys.

    ``parent_version_int`` is intentionally left unset (defaults to 0)
    so the primitive resolves it from ``ctx.parent_version_id`` at
    dispatch — the orchestrator threads ``parent_version_id`` from the
    persisted ``RunOperation.parent_version_id`` onto the
    ``OperationContext``. The route handler stamps that field from the
    user-supplied ``parent_version_id`` (or ``version_id``) before
    handing the DAG to ``orchestrator.start``.
    """
    out: dict = {
        # ``VibeIterateParams.business_name`` allows empty (resolved at
        # dispatch from ``ctx.business_id``); seed the sanitized form so
        # the DAG carries the durable label the agent's widget builder
        # expects.
        "business_name": sanitize_catalog_segment(getattr(business, "name", "") or ""),
        "deployment_catalog": deployment_catalog,
        "cataloging_style": cataloging_style,
        "schema_prefix": ecm_prefix,
        "vibe_instructions": (getattr(req, "vibe_instructions", "") or ""),
        "industry_alignment": getattr(business, "industry_alignment", "") or "",
    }

    # Inline business context override — flows to the agent's
    # business_description carry-key. Mirrors _simple.dag_for_vibe_iterate.
    biz_text = (getattr(req, "business_context_text", "") or "").strip()
    if biz_text:
        out["business_description_override"] = biz_text
    biz_path = (getattr(req, "business_context_path", "") or "").strip()
    if biz_path:
        out["business_context_path"] = biz_path

    # Optional convention overrides — forward only when explicitly set
    # so Pydantic defaults govern unset fields.
    for field in RUN_CONVENTION_FIELDS:
        v = getattr(req, field, None)
        if v is not None:
            out[field] = v

    # vibe-new-ecm-mvm always produces ECM in Phase 1 by intent contract;
    # the form's Model Size dropdown is irrelevant here. Phase 2
    # (shrink_to_mvm) hardcodes "small model" in _shrink_to_mvm_params,
    # so both scopes are pinned by the factory regardless of user input.
    out["model_size"] = "large model"
    return out


def dag_for_vibe_new_ecm_mvm(
    req: RunIn,
    business: Business,
    business_context: Optional[BusinessContext] = None,
    agent_config: Optional[AgentConfig] = None,
) -> Dag:
    """Build the ``vibe-new-ecm-mvm`` DAG for the supplied request.

    See module docstring for the uniform 2-op shape. Pure function —
    invalid params surface as Pydantic errors out of ``validate_dag``.
    The factory's job is to compose the steps; the route handler is
    responsible for stamping ``parent_version_id`` on the persisted
    ``RunOperation`` row(s) so the orchestrator can thread it onto
    each step's :class:`OperationContext`.
    """
    cataloging_style = _resolve_cataloging_style(req)
    deployment_catalog = resolve_run_target_catalog(req, agent_config)
    ecm_prefix = _resolve_ecm_prefix(req, cataloging_style)
    mvm_prefix = _resolve_mvm_prefix(req, cataloging_style)

    return Dag(
        intent=_INTENT_NAME,
        steps=(
            OperationStep(
                name="vibe_iterate",
                params=_vibe_iterate_params(
                    req,
                    business,
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
                needs_version_from="vibe_iterate",
            ),
        ),
    )


__all__ = ["dag_for_vibe_new_ecm_mvm"]
