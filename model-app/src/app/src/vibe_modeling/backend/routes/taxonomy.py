"""Domain Taxonomy Builder endpoints (`/api/taxonomy/*`).

Drafting is asynchronous: POST returns a draft id at once and the work runs as
background tasks in this process; the UI polls GET /drafts/{id}. Drafts are
scoped to the calling user (``Dependencies.UserIdentity``, the same identity
as per-user preferences) and kept in memory only. A draft request may seed the
tree and sections the user already has; only the missing parts are drafted.

The wizard itself is saved per user in the database (GET / PUT / DELETE
/taxonomy/saved, ``taxonomy/saved_state.py``) so it can be resumed after a
reload or a restart.

Gating, checked before anything is created:
- every route answers 404 when the feature is not installed
  (``require_taxonomy_installed``); the router stays mounted so the OpenAPI
  spec does not change by deployment;
- the three LLM routes (create draft, retry part, condense) refuse with the
  structured 422 ``config_missing`` when no model service is set, and with
  400 ``model_service_refused`` when the service fails its test call
  (``ensure_model_service_usable``); both shapes come from ``core/_errors``.

Mutators (create / cancel / retry / condense) and the three saved-wizard
routes require BusinessAdminOnly - the same bar as createBusiness, which is
where the wizard ends. GET draft, compile, and example are read-only
(allow-listed in tests/test_app/test_rbac_coverage.py).
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import Annotated

from fastapi import APIRouter, Depends, HTTPException

from ..._metadata import api_prefix
from ..core import Dependencies
from ..core._errors import model_service_refused_error
from ..core._features import require_installed
from ..taxonomy.access import MODEL_SERVICE_ACCESS, REFUSED_CHECKS
from ..taxonomy import saved_state
from ..taxonomy.compile import compile_taxonomy
from ..taxonomy.drafts import DraftStore
from ..taxonomy.example import load_ridgeline_example
from ..taxonomy.llm import TaxonomyLLM, make_taxonomy_llm
from ..taxonomy.models import (
    TaxonomyCompileIn,
    TaxonomyCompileOut,
    TaxonomyCondenseIn,
    TaxonomyDraftCreated,
    TaxonomyDraftCreateIn,
    TaxonomyDraftOut,
    TaxonomyExampleOut,
    TaxonomySavedWizardOut,
    TaxonomyWizardDiscardOut,
    TaxonomyWizardStateIn,
    TaxonomyWizardStateOut,
)
from ..taxonomy.slots import TAXONOMY_SLOTS
from ._helpers import _get_or_create_agent_config, require_config

NOT_INSTALLED_DETAIL = "Domain Taxonomy Builder is not installed"

require_taxonomy_installed = require_installed("taxonomy_builder_enabled", NOT_INSTALLED_DETAIL)


router = APIRouter(prefix=api_prefix, dependencies=[Depends(require_taxonomy_installed)])
_STORE = DraftStore()

def get_draft_store() -> DraftStore:
    return _STORE


@dataclass(frozen=True)
class TaxonomyLLMSettings:
    model_service: str
    max_concurrency: int


def read_taxonomy_llm_settings(session: Dependencies.Session, config: Dependencies.Config) -> TaxonomyLLMSettings:
    """The stored settings, from the AgentConfig singleton. Plain ``def``:
    FastAPI runs it in its threadpool, so the DB read never blocks the loop."""
    cfg = _get_or_create_agent_config(session, config)
    return TaxonomyLLMSettings((cfg.taxonomy_model_service or "").strip(), cfg.taxonomy_llm_max_concurrency)


def get_taxonomy_llm_settings(session: Dependencies.Session, config: Dependencies.Config) -> TaxonomyLLMSettings:
    """``read_taxonomy_llm_settings``, or 422 ``config_missing`` when no model
    service is set."""
    require_config(session, config, {"taxonomy_llm"}, mode="raise")
    return read_taxonomy_llm_settings(session, config)


LLMSettings = Annotated[TaxonomyLLMSettings, Depends(get_taxonomy_llm_settings)]


def get_taxonomy_llm(settings: LLMSettings) -> TaxonomyLLM:
    return make_taxonomy_llm(settings.model_service)


Store = Annotated[DraftStore, Depends(get_draft_store)]
LLM = Annotated[TaxonomyLLM, Depends(get_taxonomy_llm)]


async def ensure_model_service_usable(llm: TaxonomyLLM) -> bool:
    """Probe the service unless it passed recently in this process. ``denied``,
    ``not_found`` and ``error`` refuse with 400 ``model_service_refused``
    before any draft exists.
    Returns False when the probe was ``busy``: the draft is still created, with
    the part reported busy (the client counts down and retries, which probes
    again)."""
    if MODEL_SERVICE_ACCESS.is_cached(llm.model_service):
        return True
    check = await MODEL_SERVICE_ACCESS.probe(llm, TAXONOMY_SLOTS)
    if check.status in REFUSED_CHECKS:
        raise model_service_refused_error("taxonomy_llm", check.status, check.message)
    return check.status != "busy"


def _get_or_404(store: DraftStore, draft_id: str, owner: str) -> TaxonomyDraftOut:
    out = store.get(draft_id, owner)
    if out is None:
        raise HTTPException(status_code=404, detail="Draft not found (it may have expired or the app restarted)")
    return out


async def require_draft_part(draft_id: str, part: str, store: Store, owner: Dependencies.UserIdentity) -> None:
    """404 for a missing draft, 400 for an unknown part. A dependency listed
    before the LLM settings, so these answer before the 422 config check and
    before any test call. ``async``: the store is touched on the event loop
    only."""
    if part not in _get_or_404(store, draft_id, owner).parts:
        raise HTTPException(status_code=400, detail=f"Unknown draft part '{part}'")


@router.post("/taxonomy/drafts", response_model=TaxonomyDraftCreated, operation_id="createTaxonomyDraft")
async def create_taxonomy_draft(
    data: TaxonomyDraftCreateIn, store: Store, owner: Dependencies.UserIdentity,
    _role: Dependencies.BusinessAdminOnly, settings: LLMSettings, llm: LLM,
):
    # Every part seeded: nothing is drafted, so no test call either.
    usable = data.fully_seeded() or await ensure_model_service_usable(llm)
    draft_id = store.create(
        owner, data.intake(), llm, capacity=settings.max_concurrency, busy=not usable,
        seed_tree=data.seed_tree, seed_sections=data.seed_sections,
    )
    return TaxonomyDraftCreated(draft_id=draft_id)


@router.get("/taxonomy/drafts/{draft_id}", response_model=TaxonomyDraftOut, operation_id="getTaxonomyDraft")
async def get_taxonomy_draft(draft_id: str, store: Store, owner: Dependencies.UserIdentity):
    return _get_or_404(store, draft_id, owner)


@router.post("/taxonomy/drafts/{draft_id}/cancel", response_model=TaxonomyDraftOut, operation_id="cancelTaxonomyDraft")
async def cancel_taxonomy_draft(
    draft_id: str, store: Store, owner: Dependencies.UserIdentity, _role: Dependencies.BusinessAdminOnly,
):
    if not store.cancel(draft_id, owner):
        raise HTTPException(status_code=404, detail="Draft not found")
    return _get_or_404(store, draft_id, owner)


@router.post(
    "/taxonomy/drafts/{draft_id}/parts/{part}/retry",
    response_model=TaxonomyDraftOut,
    operation_id="retryTaxonomyDraftPart",
)
async def retry_taxonomy_draft_part(
    draft_id: str, part: str, store: Store, owner: Dependencies.UserIdentity,
    _role: Dependencies.BusinessAdminOnly, _exists: Annotated[None, Depends(require_draft_part)],
    settings: LLMSettings, llm: LLM,
):
    usable = await ensure_model_service_usable(llm)
    result = store.retry_part(draft_id, owner, part, llm, capacity=settings.max_concurrency, busy=not usable)
    if result == "not_found":
        raise HTTPException(status_code=404, detail="Draft not found")
    if result == "bad_part":
        raise HTTPException(status_code=400, detail=f"Unknown draft part '{part}'")
    if result == "needs_tree":
        raise HTTPException(status_code=409, detail="Retry the domains first")
    if result == "in_progress":
        raise HTTPException(status_code=409, detail="That part is still drafting")
    if result == "not_retryable":
        raise HTTPException(status_code=409, detail="That part already finished; edit it instead")
    return _get_or_404(store, draft_id, owner)


@router.post("/taxonomy/condense", response_model=TaxonomyDraftCreated, operation_id="condenseTaxonomy")
async def condense_taxonomy(
    data: TaxonomyCondenseIn, store: Store, owner: Dependencies.UserIdentity,
    _role: Dependencies.BusinessAdminOnly, settings: LLMSettings, llm: LLM,
):
    usable = await ensure_model_service_usable(llm)
    draft_id = store.create_condense(owner, data, llm, capacity=settings.max_concurrency, busy=not usable)
    return TaxonomyDraftCreated(draft_id=draft_id)


@router.post("/taxonomy/compile", response_model=TaxonomyCompileOut, operation_id="compileTaxonomy")
def compile_taxonomy_route(data: TaxonomyCompileIn):
    return compile_taxonomy(data)


@router.get("/taxonomy/example", response_model=TaxonomyExampleOut, operation_id="getTaxonomyExample")
def get_taxonomy_example():
    return load_ridgeline_example()


STALE_REVISION_MESSAGE = "This wizard was saved more recently in another tab or window."
SAVE_CLEARED_MESSAGE = (
    "Your saved work was cleared: the business was created, or the wizard was started over, in another tab or window."
)


@router.get("/taxonomy/saved", response_model=TaxonomySavedWizardOut, operation_id="getSavedTaxonomyWizard")
def get_saved_taxonomy_wizard(
    session: Dependencies.Session, owner: Dependencies.UserIdentity, _role: Dependencies.BusinessAdminOnly,
):
    return TaxonomySavedWizardOut(saved=saved_state.load(session, owner))


@router.put("/taxonomy/saved", response_model=TaxonomyWizardStateOut, operation_id="saveTaxonomyWizard")
def save_taxonomy_wizard(
    data: TaxonomyWizardStateIn, session: Dependencies.Session, owner: Dependencies.UserIdentity,
    _role: Dependencies.BusinessAdminOnly,
):
    """409 ``{"error": "stale_revision", "revision": n}`` when ``data.revision``
    is not the stored revision ``n`` (another tab saved; n = 0 when the save
    was cleared). 413 when the document is over the size cap."""
    try:
        return saved_state.save(session, owner, data)
    except saved_state.StaleRevision as stale:
        message = SAVE_CLEARED_MESSAGE if stale.current == 0 else STALE_REVISION_MESSAGE
        raise HTTPException(
            status_code=409, detail={"error": "stale_revision", "revision": stale.current, "message": message},
        ) from None
    except saved_state.DocumentTooLarge:
        raise HTTPException(
            status_code=413,
            detail=f"This wizard is too large to save (over {saved_state.MAX_DOCUMENT_BYTES // 1_000_000} MB). "
                   "Shorten the pasted document or remove domains.",
        ) from None


@router.delete("/taxonomy/saved", response_model=TaxonomyWizardDiscardOut, operation_id="discardTaxonomyWizard")
def discard_taxonomy_wizard(
    session: Dependencies.Session, owner: Dependencies.UserIdentity, _role: Dependencies.BusinessAdminOnly,
):
    return TaxonomyWizardDiscardOut(discarded=saved_state.discard(session, owner))
