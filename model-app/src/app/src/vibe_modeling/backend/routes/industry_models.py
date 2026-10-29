"""Industry *model* lifecycle endpoints (`/api/industry-models/*`) — Wave 2.

DISTINCT from :mod:`routes.industries`, which owns plain CRUD over the
``industries`` reference table (the catalog of industry rows). This module
instead owns the lifecycle of ``kind='industry'`` *models* — the
download / materialize / conflict-reconcile / kickstart / publish flow that
later Wave 2 tracks append to this router. Keep that distinction in mind:
``industries.py`` is the legacy reference-data table; this file is the
model-lifecycle surface.

Per the convention set by :class:`routes.sources.ModelPreviewOut`, any
request/response Pydantic models for these endpoints are co-located in THIS
module rather than in ``models.py``.
"""

from __future__ import annotations

from typing import Optional

from fastapi import APIRouter, BackgroundTasks, Body, HTTPException
from pydantic import BaseModel, Field
from sqlmodel import Session, select

from ..._metadata import api_prefix
from ..core import Dependencies
from ..core._runs import lock_business_for_run
from ..db_models import AgentConfig
from ._helpers import business_name_taken_error, require_config, resolve_warehouse_id
from ..models import (
    BusinessOut,
    ChangeStatus,
    IndustryScopePrefixesIn,
    IndustryScopePrefixesOut,
    IndustryScopePrefixRowOut,
)
from ..services import industry_prefix_fix
from ..services.github_publish import publish_model_version
from ..services.industry_kickstart import (
    KickstartDescriptionRequired,
    KickstartError,
    KickstartNameConflict,
    KickstartSourceNotFound,
    kickstart_from_industry,
    run_kickstart_artifact_copy_bg,
)

router = APIRouter(prefix=api_prefix)


@router.get(
    "/industry-models/_health",
    response_model=dict,
    operation_id="industryModelsHealth",
)
def industry_models_health() -> dict:
    """Trivial liveness probe for the industry-model lifecycle router.

    Foundational endpoint so later Wave 2 tracks can append lifecycle
    routes without contending on ``app.py`` router registration.
    """
    return {"ok": True}


# Request/response models are co-located here per the convention set by
# :class:`routes.sources.ModelPreviewOut` (NOT in models.py).
class DownloadIndustryModelIn(BaseModel):
    """Request to download + materialize a GitHub industry model."""

    sector_id: str = Field(
        description=(
            "Target sector for a NEW industry. Ignored when an industry with "
            "the same name already exists (the model is added under it and the "
            "industry's sector is left unchanged)."
        )
    )
    industry_id: str = Field(description="Source-relative industry id (repo folder).")
    model_id: str = Field(description="Source-relative model id within the industry (e.g. 'ecm_v1').")


class DownloadIndustryModelOut(BaseModel):
    """Result of a synchronous industry-model download."""

    business_id: str
    business_name: str
    version_id: str
    version: int
    scope: str
    domains: int
    products: int
    attribute_count: int
    fk_count: int
    on_conflict_applied: str
    run_id: Optional[str] = None
    warnings: list[str] = Field(default_factory=list)


@router.post(
    "/industry-models/download",
    response_model=DownloadIndustryModelOut,
    operation_id="downloadIndustryModel",
)
def download_industry_model_route(
    data: DownloadIndustryModelIn,
    session: Dependencies.Session,
    ws: Dependencies.Client,
    config: Dependencies.Config,
    _role: Dependencies.ModelerOnly,
) -> DownloadIndustryModelOut:
    """Pull a published GitHub industry model into a ``kind='industry'``
    Business + a draft ModelVersion.

    Synchronous (the bytes already exist at rest in the source). The model
    envelope is routed through ``import_model.detect_schema`` so the business
    identity and synced domains come from the UNWRAPPED inner ``model``.

    The conflict unit is the model SCOPE within the industry: a new industry
    is created (``on_conflict_applied="none"``), a never-seen scope is added
    under an existing industry (``"added"``), or a same-scope re-download is
    blocked with a 409 ``industry_model_already_exists``."""
    from ..services.industry_download import download_industry_model

    # Hard-fail BEFORE any clone/create when config is missing (config-missing
    # only; runtime seed failures stay non-fatal). A download needs the
    # metamodel catalog + warehouse to seed _metamodel, and the source repo to
    # fetch from.
    require_config(
        session, config, ["metamodel_catalog", "warehouse", "source_repo"],
        mode="raise",
    )

    result = download_industry_model(
        session, ws, config=config,
        sector_id=data.sector_id,
        industry_id=data.industry_id,
        model_id=data.model_id,
    )
    return DownloadIndustryModelOut(
        business_id=result.business_id,
        business_name=result.business_name,
        version_id=result.version_id,
        version=result.version,
        scope=result.scope,
        domains=result.domains,
        products=result.products,
        attribute_count=result.attribute_count,
        fk_count=result.fk_count,
        on_conflict_applied=result.on_conflict_applied,
        run_id=result.run_id,
        warnings=result.warnings,
    )


class PublishModelVersionIn(BaseModel):
    """Optional publish overrides. Back-compat: an empty body = today's
    behavior (the target path is resolved from source_repo_path / name)."""

    target_path: Optional[str] = None


class PublishModelVersionOut(BaseModel):
    """Result of publishing a model version to GitHub as a single PR.

    Co-located here per the convention set by ``routes.sources`` — the
    response model for a lifecycle endpoint lives next to its route, not in
    the shared ``models.py``.
    """

    branch: str
    pr_number: int
    pr_url: str
    files: list[str]
    # The bundle root actually published to (ADR D-049): the override when
    # supplied, else the round-tripped / name-derived root.
    target_path: str


@router.post(
    "/businesses/{business_id}/model-versions/{version_id}/publish",
    response_model=PublishModelVersionOut,
    operation_id="publishModelVersion",
)
def publish_model_version_endpoint(
    business_id: str,
    version_id: str,
    user_ws: Dependencies.UserClient,
    session: Dependencies.Session,
    _role: Dependencies.ModelerOnly,
    data: PublishModelVersionIn = Body(default=PublishModelVersionIn()),
) -> PublishModelVersionOut:
    """Publish a model version's bundle to GitHub as one pull request.

    Acts on behalf of the user (OBO ``UserClient``) so the commits are
    attributed to them. Reconstructs ``model.json`` + companion artifacts via
    the same single-source iterator the downloadable zip uses, PUTs each file
    to a fresh branch through the configured UC HTTP connection, and opens one
    PR.

    GUARDED at the service layer: returns ``422 github_connection_missing``
    when the OAuth U2M UC HTTP connection is not configured (the human-gated
    step), and ``422 github_pat_not_implemented`` for the deferred secret-PAT
    mode.
    """
    cfg = session.exec(select(AgentConfig).limit(1)).first() or AgentConfig()
    result = publish_model_version(
        user_ws,
        cfg,
        session=session,
        business_id=business_id,
        version_id=version_id,
        target_path=data.target_path,
    )
    return PublishModelVersionOut(
        branch=result.branch,
        pr_number=result.pr_number,
        pr_url=result.pr_url,
        files=result.files,
        target_path=result.target_path,
    )


# --- Prepublish diff-preview (Story 3, 0.6.4) ------------------------------
#
# Request/response models co-located here per the module convention (mirrors
# ``routes.sources.ModelPreviewOut`` + the publish In/Out above).


class DiffRowOut(BaseModel):
    """One changed-or-deleted element, flattened from the tuple-keyed diff maps.

    ``product`` / ``attribute`` are None at the level the row describes (a domain
    row has product=attribute=None; a product row has attribute=None).
    """

    domain: str
    product: Optional[str] = None
    attribute: Optional[str] = None
    status: ChangeStatus  # new | modified | deleted (unchanged rows are omitted)


class DiffOut(BaseModel):
    """Flat, JSON-safe projection of ``compute_model_diff()``. model.json ONLY.

    Rows are the union of the status maps (new/modified) and the ``deleted_*``
    lists (status=deleted). Unchanged elements are NOT emitted, so the FE renders
    only what changed and the empty-state is ``counts`` summing to 0.
    """

    domains: list[DiffRowOut] = Field(default_factory=list)
    products: list[DiffRowOut] = Field(default_factory=list)
    attributes: list[DiffRowOut] = Field(default_factory=list)
    counts: dict[str, int] = Field(default_factory=dict)  # {"new","modified","deleted"}


class BaselineOut(BaseModel):
    """The repo baseline the diff was computed against (None when manual_needed)."""

    model_id: str
    industry_id: str
    scope: Optional[str] = None
    version: Optional[str] = None


class CandidateOut(BaseModel):
    """A pick-able repo model for manual baseline selection (Tier 3 / override)."""

    model_id: str
    name: str
    scope: Optional[str] = None
    version: Optional[str] = None


class PublishPreviewIn(BaseModel):
    """Optional preview inputs. ``target_path`` reshapes which repo industry
    folder is enumerated (same editable target as publish); ``baseline_model_id``
    is a manual pick that bypasses the tiered resolver."""

    target_path: Optional[str] = None
    baseline_model_id: Optional[str] = None


class PublishPreviewOut(BaseModel):
    """Tiered baseline diff of the model.json that WOULD be published.

    ``tier`` is one of ``same_scope_latest`` (highest same-scope version),
    ``fallback_unverified`` (no same-scope folder; lexically-newest used),
    ``none`` (no baseline -> ``manual_needed``), or ``manual`` (caller supplied
    ``baseline_model_id``). ``diff is None`` ONLY when ``manual_needed`` — a real
    all-unchanged diff is a populated ``DiffOut`` whose ``counts`` sum to 0.
    """

    baseline: Optional[BaselineOut] = None
    tier: str  # same_scope_latest | fallback_unverified | none | manual
    scope_mismatch: bool = False
    manual_needed: bool = False
    candidates: list[CandidateOut] = Field(default_factory=list)
    diff: Optional[DiffOut] = None


def _to_diff_out(diff: dict) -> DiffOut:
    """Flatten the (tuple-keyed, Pydantic-instance-bearing) ``compute_model_diff``
    dict into JSON-safe rows. Identity is read off the tuple keys and the
    deleted instances' ``.name`` — the deleted Pydantic instances are NEVER
    ``model_dump()``-ed (that would leak change_status / fqn / counts)."""
    domains: list[DiffRowOut] = []
    products: list[DiffRowOut] = []
    attributes: list[DiffRowOut] = []

    for dn, st in diff["domains"].items():
        domains.append(DiffRowOut(domain=dn, status=st))
    for (dn, pn), st in diff["products"].items():
        products.append(DiffRowOut(domain=dn, product=pn, status=st))
    for (dn, pn, an), st in diff["attributes"].items():
        attributes.append(DiffRowOut(domain=dn, product=pn, attribute=an, status=st))

    for d in diff["deleted_domains"]:
        domains.append(DiffRowOut(domain=d.name, status=ChangeStatus.DELETED))
    for dn, plist in diff["deleted_products"].items():
        for p in plist:
            products.append(DiffRowOut(domain=dn, product=p.name, status=ChangeStatus.DELETED))
    for (dn, pn), alist in diff["deleted_attributes"].items():
        for a in alist:
            attributes.append(
                DiffRowOut(domain=dn, product=pn, attribute=a.name, status=ChangeStatus.DELETED)
            )

    new = modified = deleted = 0
    for row in (*domains, *products, *attributes):
        if row.status == ChangeStatus.NEW:
            new += 1
        elif row.status == ChangeStatus.MODIFIED:
            modified += 1
        elif row.status == ChangeStatus.DELETED:
            deleted += 1
    return DiffOut(
        domains=domains, products=products, attributes=attributes,
        counts={"new": new, "modified": modified, "deleted": deleted},
    )


def _result_to_preview_out(result) -> PublishPreviewOut:
    baseline = (
        BaselineOut(
            model_id=result.baseline.model_id, industry_id=result.baseline.industry_id,
            scope=result.baseline.scope, version=result.baseline.version,
        )
        if result.baseline is not None
        else None
    )
    return PublishPreviewOut(
        baseline=baseline,
        tier=result.tier,
        scope_mismatch=result.scope_mismatch,
        manual_needed=result.manual_needed,
        candidates=[
            CandidateOut(model_id=c.id, name=c.name, scope=c.scope, version=c.version)
            for c in result.candidates
        ],
        diff=_to_diff_out(result.diff) if result.diff is not None else None,
    )


@router.post(
    "/businesses/{business_id}/model-versions/{version_id}/publish-preview",
    response_model=PublishPreviewOut,
    operation_id="previewPublishModelVersion",
)
def preview_publish_model_version_endpoint(
    business_id: str,
    version_id: str,
    session: Dependencies.Session,
    config: Dependencies.Config,
    ws: Dependencies.Client,
    _role: Dependencies.ModelerOnly,
    data: PublishPreviewIn = Body(default=PublishPreviewIn()),
) -> PublishPreviewOut:
    """Diff the model.json that WOULD be published against the repo's latest
    same-scope version (tiered fallback + manual pick/skip). model.json only,
    never artifacts. Reads the repo with the installation's configured source
    read-auth (the browse/download resolver; secrets read by the app SP ``ws``).
    No UserClient, no UC connection, so the preview is smoke-testable and a
    missing baseline is normal (manual_needed), never a 500."""
    from ..services.publish_preview import compute_publish_preview

    cfg = session.exec(select(AgentConfig).limit(1)).first() or AgentConfig()
    result = compute_publish_preview(
        cfg, session=session, business_id=business_id, version_id=version_id,
        target_path=data.target_path, baseline_model_id=data.baseline_model_id,
        app_config=config, ws=ws,
    )
    return _result_to_preview_out(result)


# --- Kickstart (Story-8, ADR D-050) ----------------------------------------
#
# Request/response models co-located here per the module convention (mirrors
# ``routes.sources.ModelPreviewOut``).


class KickstartIn(BaseModel):
    """Kickstart request: clone an industry version into a new business.

    ``scope`` is intentionally absent — kickstart is whole-model only. A
    request that tries to narrow to a sub-scope (or any other sub-selection
    flag) is rejected with a 400 so the contract stays unambiguous; we surface
    the cap rather than silently widening a narrowed request.
    """

    source_version: int = Field(..., description="Industry version int to clone")
    new_name: str = Field(..., min_length=1, description="Name for the new business")
    new_description: str = Field(default="", description="Optional short summary")
    whole_model: bool = Field(
        default=True,
        description="Must be true — kickstart copies the whole model only",
    )
    copy_inputs: bool = Field(
        default=True,
        description=(
            "Copy the industry's Vibe Inputs (feedback + agent next-vibe "
            "backlog) into the new business, re-anchored to the cloned model. "
            "Default on - a kickstart inherits the industry's curation."
        ),
    )


class KickstartOut(BaseModel):
    """The newly-created business plus its kickstart provenance."""

    business: BusinessOut


@router.post(
    "/industry-models/{industry_business_id}/kickstart",
    response_model=KickstartOut,
    operation_id="kickstartFromIndustry",
)
def kickstart_industry_model(
    industry_business_id: str,
    data: KickstartIn,
    session: Dependencies.Session,
    ws: Dependencies.Client,
    config: Dependencies.Config,
    background_tasks: BackgroundTasks,
    _role: Dependencies.ModelerOnly,
) -> KickstartOut:
    """Stamp out a fresh business from a published industry version.

    Returns as soon as the model structure, VibeInputs and ``_metamodel`` seed
    are durable (the business is immediately usable + iterable). The source
    version's Volume artifacts are copied in the BACKGROUND, driving the audit
    ``Run`` (born ``status="running"``) to ``completed`` as scopes finish, so
    the user is not held behind a multi-minute spinner. Whole-model only.
    """
    if not data.whole_model:
        raise HTTPException(
            status_code=400,
            detail=(
                "kickstart is whole-model only; sub-scope copies are not "
                "supported (set whole_model=true)"
            ),
        )

    # Hard-fail BEFORE creating a skeleton business when config is missing:
    # a business that can never be iterated or hold artifacts is exactly the
    # silent degradation this preflight bans. Config-missing only; runtime
    # seed/copy errors keep the background flow's non-fatal semantics.
    require_config(
        session, config, ["metamodel_catalog", "warehouse"], mode="raise",
    )

    # The background copy opens its OWN session (the request session closes
    # when this returns) bound to the same engine.
    engine = session.get_bind()

    def _schedule(plan) -> None:
        # expire_on_commit=False: this session lives across all three
        # background phases (structure copy, metamodel seed, artifact copy),
        # each separated by a multi-minute external call. SQLAlchemy's
        # default expire_on_commit=True marks every attached ORM object
        # expired at each of the several commits `_run_kickstart_background`
        # makes; if any later code (a log/progress message, a plan field
        # read off an ORM row) touches one of those objects, the resulting
        # refresh SELECT autobegins a brand-new transaction that then sits
        # idle-in-transaction for the remainder of the slow call - exactly
        # the leak traced live via pg_stat_activity. This is a single-writer
        # background task, not a request-scoped session sharing state with
        # concurrent readers, so disabling the expire-on-commit refresh is
        # safe: anything that genuinely needs a fresh read gets one
        # explicitly (`_set_run`'s own `session.get`).
        background_tasks.add_task(
            run_kickstart_artifact_copy_bg,
            lambda: Session(bind=engine, expire_on_commit=False),
            ws,
            plan,
        )

    try:
        new_business = kickstart_from_industry(
            session, ws,
            source_industry_id=industry_business_id,
            source_version=data.source_version,
            new_name=data.new_name,
            new_description=data.new_description,
            config=config,
            copy_inputs=data.copy_inputs,
            schedule_copy=_schedule,
        )
    except KickstartNameConflict as e:
        raise business_name_taken_error(data.new_name, str(e)) from e
    except KickstartSourceNotFound as e:
        raise HTTPException(status_code=404, detail=str(e))
    except KickstartDescriptionRequired as e:
        # Same 422 contract as BusinessIn.description (validate_business_
        # description) - a business is never created with an empty
        # description, regardless of entry point.
        raise HTTPException(status_code=422, detail=str(e))
    except KickstartError as e:
        raise HTTPException(status_code=400, detail=e.detail)
    # kickstart_from_industry commits internally (Lakebase durable before the
    # external _metamodel seed) and refreshes new_business before scheduling
    # the background copy, so no further session I/O happens here - reading
    # new_business now is a plain in-memory attribute access.
    return KickstartOut(business=BusinessOut.model_validate(new_business, from_attributes=True))


# --- Scope prefixes for industries downloaded before 0.9.0 -----------------


@router.post(
    "/industries/{business_id}/scope-prefixes",
    response_model=IndustryScopePrefixesOut,
    operation_id="applyIndustryScopePrefixes",
)
def apply_industry_scope_prefixes(
    business_id: str,
    session: Dependencies.Session,
    ws: Dependencies.Client,
    config: Dependencies.Config,
    _role: Dependencies.AdminOnly,
    data: IndustryScopePrefixesIn = Body(default=IndustryScopePrefixesIn()),
) -> IndustryScopePrefixesOut:
    """Give the app's copies of an industry downloaded before 0.9.0 the scope
    prefixes a download adds now (``services/industry_prefix_fix``).

    ``business_id`` is the industry's ``businesses`` row (``kind='industry'``;
    a business is a 400). Without ``apply`` it reports what would change and
    writes nothing. With ``apply`` it refuses (409, nothing written) while a
    run is active or when a version changed since the plan, then rewrites
    every ``changed`` version on its own; a version that fails is ``failed``
    with what completed, and a rerun finishes it. Installed versions are
    ``skipped`` with the catalogs named. A rerun answers ``unchanged``."""
    needs = ["metamodel_catalog", "warehouse"] if data.apply else ["metamodel_catalog"]
    require_config(session, config, needs, mode="raise")
    business = industry_prefix_fix.industry_or_404(session, business_id)
    business_name = business.name
    plans = industry_prefix_fix.plan_prefix_fix(session, ws, business)
    if data.apply and any(row.action == industry_prefix_fix.CHANGED for row in plans):
        warehouse_id = resolve_warehouse_id(session, config)
        # Refuse a busy industry or a changed version before any write; the
        # lock is released again, and each version takes it for its own rows.
        lock_business_for_run(session, business_id)
        industry_prefix_fix.recheck(session, plans)
        session.commit()
        industry_prefix_fix.apply_prefix_fix(session, ws, business_id, plans, warehouse_id)
    return IndustryScopePrefixesOut(
        business_id=business_id,
        business_name=business_name,
        applied=data.apply,
        rows=[
            IndustryScopePrefixRowOut(
                version_id=row.version_id, version=row.version, scope=row.scope,
                action=row.action, reason=row.reason, warnings=row.warnings,
            )
            for row in plans
        ],
    )
