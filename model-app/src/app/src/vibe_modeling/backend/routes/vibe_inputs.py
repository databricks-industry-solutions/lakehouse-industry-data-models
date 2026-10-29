"""Vibe Inputs API: durable input content, anchoring, re-link + review queue.

Owns the input collection surface — create (materializes the origin context
link), list+filter, edit, soft-delete/restore, consume/unconsume, context-link
add/list, carry-forward, the resumable review queue, and the
product-canonical review-state write surface (per-product marks + domain /
subdomain cascade fan-out; ADR D-044). The review READ surface (effective
states + progress) lives in ``explorer.py``.

Identity is sourced from ``Dependencies.Headers``; every query is scoped by the
URL ``business_id`` (no per-row ACL - single-tenant-per-workspace).

Every route declares its role: ``Dependencies.ModelerDeclared`` on writes,
``Dependencies.ViewerDeclared`` on reads (including the read-only compile
preview). They do not refuse anyone until
``core/_roles.VIBE_INPUT_ROLE_GUARDS_ENFORCED`` is True.
"""

from __future__ import annotations

from datetime import datetime, timezone
from typing import Annotated

from fastapi import APIRouter, HTTPException, Path as PathParam, Query
from sqlmodel import select

from ..._metadata import api_prefix
from .._compile import build_anchor, compile_inputs
from .._query_helpers import resolve_model_version
from .._relink import (
    RelinkOutcome,
    TIER_MERGE_SURVIVOR,
    TIER_PARTIAL_ANCESTOR,
    relink_input,
)
from ..core import Dependencies
from ..core._vibe_input_create import create_vibe_input_with_anchor
from ..core._identity import actor_label
from ..core.anchor_resolve import fk_link_edge_ids
from ..explorer import product_fqn
from ..db_models import (
    Attribute,
    Business,
    Domain,
    ForeignKeyLink,
    ModelVersion,
    Product,
    ProductReview,
    RunElementLineage,
    Subdomain,
    VibeInput,
    VibeInputContextLink,
)
from ..models import (
    CarryForwardResultOut,
    CompileIn,
    CompileOut,
    ProductReviewOut,
    ReanchorIn,
    ReviewCascadeOut,
    ReviewMarkIn,
    ReviewProgressOut,
    ReviewQueueItemOut,
    ReviewQueueOut,
    ReviewState,
    VibeInputAnchorOut,
    NextVibeCategory,
    VibeInputContextLinkIn,
    VibeInputContextLinkOut,
    VibeInputIn,
    VibeInputOrigin,
    VibeInputOut,
    VibeInputPatchIn,
    VibeInputPriority,
    VibeInputSelectionIn,
    VibeInputStatus,
)

router = APIRouter(prefix=api_prefix)


def _now() -> datetime:
    return datetime.now(timezone.utc)


def _input_to_out(vi: VibeInput, anchor: VibeInputAnchorOut | None = None) -> VibeInputOut:
    return VibeInputOut(
        id=vi.id,
        business_id=vi.business_id,
        origin=VibeInputOrigin(vi.origin),
        author=vi.author,
        text=vi.text,
        category=NextVibeCategory(vi.category) if vi.category is not None else None,
        priority=VibeInputPriority(vi.priority),
        confidence_score=vi.confidence_score,
        consumed=vi.consumed,
        consumed_by_run_id=vi.consumed_by_run_id,
        selected_for_run=vi.selected_for_run,
        status=VibeInputStatus(vi.status),
        deprecated_by=vi.deprecated_by,
        created_at=vi.created_at,
        updated_at=vi.updated_at,
        anchor=anchor,
    )


def _anchor_out(
    link: VibeInputContextLink, anchor, fk_edge_ids: dict[str, str],
) -> VibeInputAnchorOut:
    """Adapt a _compile._Anchor (names + section_path) plus the link's element
    ids into the wire projection. Names come from the resolver (single source
    of truth); ids are read off the link; ``fk_edge_ids`` comes from
    ``anchor_resolve.fk_link_edge_ids``."""
    if anchor.kind == "model_wide":
        return VibeInputAnchorOut(level="model_wide", path=[])
    return VibeInputAnchorOut(
        level="element",
        domain_id=link.domain_id,
        domain_name=anchor.names.get("domain"),
        subdomain_id=link.subdomain_id,
        subdomain_name=anchor.names.get("subdomain"),
        product_id=link.product_id,
        product_name=anchor.names.get("product"),
        attribute_id=link.attribute_id,
        attribute_name=anchor.names.get("attribute"),
        fk_link_id=link.fk_link_id,
        fk_label=anchor.names.get("fk"),
        fk_edge_id=fk_edge_ids.get(link.fk_link_id) if link.fk_link_id else None,
        path=list(anchor.section_path),
    )


def _link_to_out(lk: VibeInputContextLink) -> VibeInputContextLinkOut:
    return VibeInputContextLinkOut(
        id=lk.id,
        input_id=lk.input_id,
        version_id=lk.version_id,
        domain_id=lk.domain_id,
        subdomain_id=lk.subdomain_id,
        product_id=lk.product_id,
        attribute_id=lk.attribute_id,
        fk_link_id=lk.fk_link_id,
        is_origin=lk.is_origin,
        needs_link_review=lk.needs_link_review,
        reviewed_by=lk.reviewed_by,
        reviewed_at=lk.reviewed_at,
        created_at=lk.created_at,
    )


def _require_business(session, business_id: str) -> Business:
    biz = session.exec(select(Business).where(Business.id == business_id)).first()
    if not biz:
        raise HTTPException(status_code=404, detail="Business not found")
    return biz


def _require_version(
    session, business_id: str, version_int: int, scope: str
) -> ModelVersion:
    """Resolve the MV by its natural ``(business, version, scope)`` key —
    the same contract the review READ endpoints use. 404 if not found."""
    mv = resolve_model_version(session, business_id, version_int, scope)
    if mv is None:
        raise HTTPException(status_code=404, detail="Model version not found")
    return mv


def _get_input(session, business_id: str, input_id: str) -> VibeInput:
    vi = session.exec(
        select(VibeInput).where(
            VibeInput.id == input_id,
            VibeInput.business_id == business_id,
        )
    ).first()
    if not vi:
        raise HTTPException(status_code=404, detail="Vibe input not found")
    return vi


@router.post(
    "/businesses/{business_id}/inputs",
    response_model=VibeInputOut,
    operation_id="createVibeInput",
)
def create_vibe_input(
    business_id: str,
    data: VibeInputIn,
    session: Dependencies.Session,
    _role: Dependencies.ModelerDeclared,
    headers: Dependencies.Headers,
):
    """Create a vibe input + materialize its origin context link."""
    _require_business(session, business_id)
    if not data.text.strip():
        raise HTTPException(status_code=400, detail="Vibe input text is required")
    if not data.version_id:
        raise HTTPException(
            status_code=400,
            detail="version_id is required to anchor the origin context link",
        )

    author = data.author or (
        actor_label(headers) if data.origin == VibeInputOrigin.USER else ""
    )
    vi = create_vibe_input_with_anchor(
        session=session,
        business_id=business_id,
        text=data.text,
        author=author,
        version_id=data.version_id,
        origin=data.origin,
        priority=data.priority,
        confidence_score=data.confidence_score,
        domain_id=data.domain_id,
        product_id=data.product_id,
        attribute_id=data.attribute_id,
        subdomain_id=data.subdomain_id,
        fk_link_id=data.fk_link_id,
        origin_context=data.origin_context,
    )
    session.commit()
    session.refresh(vi)
    return _input_to_out(vi)


@router.get(
    "/businesses/{business_id}/inputs",
    response_model=list[VibeInputOut],
    operation_id="listVibeInputs",
)
def list_vibe_inputs(
    business_id: str,
    session: Dependencies.Session,
    _role: Dependencies.ViewerDeclared,
    origin: VibeInputOrigin | None = None,
    status: VibeInputStatus | None = None,
    consumed: bool | None = None,
    needs_link_review: bool | None = None,
    priority: VibeInputPriority | None = None,
    q: str | None = None,
    version_id: str | None = None,
    domain_id: str | None = None,
    subdomain_id: str | None = None,
    product_id: str | None = None,
    attribute_id: str | None = None,
    fk_link_id: str | None = None,
    model_wide: bool | None = Query(default=None),
):
    """List + filter inputs for a business (AND-combined filters)."""
    _require_business(session, business_id)
    query = select(VibeInput).where(VibeInput.business_id == business_id)
    if origin is not None:
        query = query.where(VibeInput.origin == origin.value)
    if status is not None:
        query = query.where(VibeInput.status == status.value)
    if consumed is not None:
        query = query.where(VibeInput.consumed == consumed)
    if priority is not None:
        query = query.where(VibeInput.priority == priority.value)
    if q:
        query = query.where(VibeInput.text.ilike(f"%{q}%"))

    link_filters = any(
        v is not None
        for v in (version_id, domain_id, subdomain_id, product_id,
                  attribute_id, fk_link_id)
    ) or needs_link_review is not None or model_wide is not None
    if link_filters:
        query = query.join(
            VibeInputContextLink,
            VibeInputContextLink.input_id == VibeInput.id,
        )
        if version_id is not None:
            query = query.where(VibeInputContextLink.version_id == version_id)
        if needs_link_review is not None:
            query = query.where(
                VibeInputContextLink.needs_link_review == needs_link_review
            )
        if model_wide:
            query = query.where(
                VibeInputContextLink.domain_id.is_(None),
                VibeInputContextLink.subdomain_id.is_(None),
                VibeInputContextLink.product_id.is_(None),
                VibeInputContextLink.attribute_id.is_(None),
                VibeInputContextLink.fk_link_id.is_(None),
            )
        for col, val in (
            (VibeInputContextLink.domain_id, domain_id),
            (VibeInputContextLink.subdomain_id, subdomain_id),
            (VibeInputContextLink.product_id, product_id),
            (VibeInputContextLink.attribute_id, attribute_id),
            (VibeInputContextLink.fk_link_id, fk_link_id),
        ):
            if val is not None:
                query = query.where(col == val)
        query = query.distinct()

    query = query.order_by(VibeInput.updated_at.desc())
    rows = session.exec(query).all()

    # Hydrate each input's anchor on the version the caller is viewing so the FE
    # section tree can group cards by element name without an N+1 of /links
    # calls (CONFLICT-4). When the caller scopes the list to a version_id we MUST
    # hydrate against that same version — otherwise an input anchored to a
    # non-head version (e.g. added on the ECM page while the MVM is the latest
    # completed version) resolves to a null anchor and disappears from the tree
    # even though it is counted. Fall back to the head version only when the
    # caller didn't scope to a version. A null anchor means "no link on the
    # resolved version" (distinct from a model_wide anchor, which is a
    # present-but-unscoped link).
    anchor_version_id = version_id
    if anchor_version_id is None:
        head = _resolve_head_version(session, business_id)
        anchor_version_id = head.id if head is not None else None
    link_by_input: dict[str, VibeInputContextLink] = {}
    links: list[VibeInputContextLink] = []
    if anchor_version_id is not None and rows:
        input_ids = [vi.id for vi in rows]
        links = session.exec(
            select(VibeInputContextLink).where(
                VibeInputContextLink.version_id == anchor_version_id,
                VibeInputContextLink.input_id.in_(input_ids),
            )
        ).all()
        link_by_input = {lk.input_id: lk for lk in links}

    # Batch-resolve every anchored element type ONCE (one query per grain, on
    # the union of ids across all links) instead of a per-link ``session.get``
    # fan-out. ``build_anchor`` then assembles each anchor from these maps.
    elements = _prefetch_anchor_elements(session, links)
    edge_ids = fk_link_edge_ids(session, list(elements["fk"].values()))

    out: list[VibeInputOut] = []
    for vi in rows:
        link = link_by_input.get(vi.id)
        anchor = (
            _anchor_out(link, _build_anchor_from_maps(link, elements), edge_ids)
            if link else None
        )
        out.append(_input_to_out(vi, anchor))
    return out


def _prefetch_anchor_elements(
    session, links: list[VibeInputContextLink]
) -> dict[str, dict[str, object]]:
    """Resolve every anchored element id across ``links`` in one query per grain.

    Returns ``{"domain": {id: row}, "subdomain": ..., "product": ...,
    "attribute": ..., "fk": ...}``. The list anchor-hydration loop reads from
    these maps so there is no per-link element fetch (no N+1)."""
    ids: dict[str, set[str]] = {
        "domain": set(), "subdomain": set(), "product": set(),
        "attribute": set(), "fk": set(),
    }
    for lk in links:
        if lk.domain_id:
            ids["domain"].add(lk.domain_id)
        if lk.subdomain_id:
            ids["subdomain"].add(lk.subdomain_id)
        if lk.product_id:
            ids["product"].add(lk.product_id)
        if lk.attribute_id:
            ids["attribute"].add(lk.attribute_id)
        if lk.fk_link_id:
            ids["fk"].add(lk.fk_link_id)

    def _by_id(model, id_set: set[str]) -> dict[str, object]:
        if not id_set:
            return {}
        return {
            row.id: row
            for row in session.exec(
                select(model).where(model.id.in_(id_set))
            ).all()
        }

    return {
        "domain": _by_id(Domain, ids["domain"]),
        "subdomain": _by_id(Subdomain, ids["subdomain"]),
        "product": _by_id(Product, ids["product"]),
        "attribute": _by_id(Attribute, ids["attribute"]),
        "fk": _by_id(ForeignKeyLink, ids["fk"]),
    }


def _build_anchor_from_maps(
    link: VibeInputContextLink, elements: dict[str, dict[str, object]]
):
    """Build a ``_compile._Anchor`` from prefetched element maps (no queries)."""
    return build_anchor(
        link,
        domain=elements["domain"].get(link.domain_id) if link.domain_id else None,
        subdomain=elements["subdomain"].get(link.subdomain_id) if link.subdomain_id else None,
        product=elements["product"].get(link.product_id) if link.product_id else None,
        attribute=elements["attribute"].get(link.attribute_id) if link.attribute_id else None,
        fk=elements["fk"].get(link.fk_link_id) if link.fk_link_id else None,
    )


def _hydrate_single_anchor(session, vi: VibeInput) -> VibeInputAnchorOut | None:
    """Resolve one input's context-link anchor for the single-input read path.

    The list endpoint hydrates anchors (CONFLICT-4) but ``get_vibe_input`` did
    not, so the card-details page (and its "Open in model" focus) always saw a
    null anchor and fell back to all-domains. Mirror the list here for one
    input, reusing the same prefetch/build/serialize primitives: pick the link
    on the most-recently-created version the input is anchored on. Full
    version-scoped hydration (shared helper + ``version_id`` param) is the
    remaining unify work.
    """
    links = session.exec(
        select(VibeInputContextLink)
        .join(ModelVersion, ModelVersion.id == VibeInputContextLink.version_id)
        .where(VibeInputContextLink.input_id == vi.id)
        .order_by(ModelVersion.created_at.desc())
    ).all()
    if not links:
        return None
    # Prefer an element-scoped link over a model-wide one (an input can carry
    # both a model-wide origin link and element links on the same version);
    # fall back to the most-recent link when all are model-wide.
    link = next(
        (
            lk
            for lk in links
            if lk.domain_id or lk.subdomain_id or lk.product_id
            or lk.attribute_id or lk.fk_link_id
        ),
        links[0],
    )
    elements = _prefetch_anchor_elements(session, [link])
    edge_ids = fk_link_edge_ids(session, list(elements["fk"].values()))
    return _anchor_out(link, _build_anchor_from_maps(link, elements), edge_ids)


@router.get(
    "/businesses/{business_id}/inputs/{input_id}",
    response_model=VibeInputOut,
    operation_id="getVibeInput",
)
def get_vibe_input(
    business_id: str,
    input_id: str,
    session: Dependencies.Session,
    _role: Dependencies.ViewerDeclared,
):
    """Single input by id, scoped to the business (anchor hydrated)."""
    vi = _get_input(session, business_id, input_id)
    return _input_to_out(vi, _hydrate_single_anchor(session, vi))


@router.patch(
    "/businesses/{business_id}/inputs/{input_id}",
    response_model=VibeInputOut,
    operation_id="updateVibeInput",
)
def update_vibe_input(
    business_id: str,
    input_id: str,
    data: VibeInputPatchIn,
    session: Dependencies.Session,
    _role: Dependencies.ModelerDeclared,
):
    """Edit text/priority. Status + consumed are driven by dedicated endpoints."""
    vi = _get_input(session, business_id, input_id)
    if vi.status == VibeInputStatus.DEPRECATED.value:
        raise HTTPException(status_code=410, detail="Vibe input is deprecated")
    if data.text is not None:
        if not data.text.strip():
            raise HTTPException(status_code=400, detail="Vibe input text is required")
        vi.text = data.text.strip()
    if data.priority is not None:
        vi.priority = data.priority.value
    vi.updated_at = _now()
    session.add(vi)
    session.commit()
    session.refresh(vi)
    return _input_to_out(vi)


@router.delete(
    "/businesses/{business_id}/inputs/{input_id}",
    response_model=dict,
    operation_id="deleteVibeInput",
)
def delete_vibe_input(
    business_id: str,
    input_id: str,
    session: Dependencies.Session,
    _role: Dependencies.ModelerDeclared,
    headers: Dependencies.Headers,
):
    """Soft-delete: status=deprecated, deprecated_by=<user> (manual)."""
    vi = _get_input(session, business_id, input_id)
    vi.status = VibeInputStatus.DEPRECATED.value
    vi.deprecated_by = actor_label(headers)
    vi.updated_at = _now()
    session.add(vi)
    session.commit()
    return {"status": "deprecated", "id": vi.id}


@router.post(
    "/businesses/{business_id}/inputs/{input_id}/restore",
    response_model=VibeInputOut,
    operation_id="restoreVibeInput",
)
def restore_vibe_input(
    business_id: str,
    input_id: str,
    session: Dependencies.Session,
    _role: Dependencies.ModelerDeclared,
):
    """Undo a manual soft-delete. 409 if the app deprecated it (deprecated_by None)."""
    vi = _get_input(session, business_id, input_id)
    if vi.status == VibeInputStatus.DEPRECATED.value and vi.deprecated_by is None:
        raise HTTPException(
            status_code=409,
            detail=(
                "Deprecated by the app: its model element was removed, or its link was "
                "dismissed in the review queue. It can't be restored; add it again as "
                "new feedback if you still need it."
            ),
        )
    vi.status = VibeInputStatus.ACTIVE.value
    vi.deprecated_by = None
    vi.updated_at = _now()
    session.add(vi)
    session.commit()
    session.refresh(vi)
    return _input_to_out(vi)


@router.post(
    "/businesses/{business_id}/inputs/{input_id}/consume",
    response_model=VibeInputOut,
    operation_id="consumeVibeInput",
)
def consume_vibe_input(
    business_id: str,
    input_id: str,
    session: Dependencies.Session,
    _role: Dependencies.ModelerDeclared,
):
    """Manually mark consumed (normally set by run completion)."""
    vi = _get_input(session, business_id, input_id)
    vi.consumed = True
    vi.updated_at = _now()
    session.add(vi)
    session.commit()
    session.refresh(vi)
    return _input_to_out(vi)


@router.post(
    "/businesses/{business_id}/inputs/{input_id}/unconsume",
    response_model=VibeInputOut,
    operation_id="unconsumeVibeInput",
)
def unconsume_vibe_input(
    business_id: str,
    input_id: str,
    session: Dependencies.Session,
    _role: Dependencies.ModelerDeclared,
):
    """Reset consumed=false + create ONE link to the current head version via
    the re-link tiers. 409 if no head version, or if head context is gone."""
    vi = _get_input(session, business_id, input_id)
    head = _resolve_head_version(session, business_id)
    if head is None:
        raise HTTPException(status_code=409, detail="No head version to re-link to")

    vi.consumed = False
    vi.consumed_by_run_id = None
    vi.updated_at = _now()
    session.add(vi)

    existing = session.exec(
        select(VibeInputContextLink).where(
            VibeInputContextLink.input_id == vi.id,
            VibeInputContextLink.version_id == head.id,
        )
    ).first()
    if existing is None:
        outcome = relink_input(session, vi, head.id)
        if outcome == RelinkOutcome.DEPRECATED:
            # Don't silently deprecate a just-un-consumed input.
            session.rollback()
            raise HTTPException(
                status_code=409,
                detail="Input's context no longer exists on the current model version",
            )
    session.commit()
    session.refresh(vi)
    return _input_to_out(vi)


@router.post(
    "/businesses/{business_id}/inputs/selection",
    response_model=list[VibeInputOut],
    operation_id="setVibeInputSelection",
)
def set_vibe_input_selection(
    business_id: str,
    data: VibeInputSelectionIn,
    session: Dependencies.Session,
    _role: Dependencies.ModelerDeclared,
):
    """Bulk set ``selected_for_run`` for a set of inputs (single-card toggle or
    select-all-under-a-branch). Business-scoped: ids not on this business are
    silently ignored (not 404). Consumed inputs are skipped — selection is moot
    once consumed. Returns the affected (non-consumed, in-business) inputs with
    their resulting state so the FE can reconcile its optimistic update."""
    _require_business(session, business_id)
    if not data.input_ids:
        return []
    rows = session.exec(
        select(VibeInput).where(
            VibeInput.business_id == business_id,
            VibeInput.id.in_(data.input_ids),
        )
    ).all()
    affected: list[VibeInput] = []
    for vi in rows:
        # Selection is meaningful only for active, non-consumed inputs — a
        # consumed or deprecated input is never dispatched, so don't let it
        # carry a stale selected_for_run that a count surface could over-count.
        if vi.consumed or vi.status != VibeInputStatus.ACTIVE.value:
            continue
        if vi.selected_for_run != data.selected:
            vi.selected_for_run = data.selected
            vi.updated_at = _now()
            session.add(vi)
        affected.append(vi)
    session.commit()
    out: list[VibeInputOut] = []
    for vi in affected:
        session.refresh(vi)
        out.append(_input_to_out(vi))
    return out


def _resolve_head_version(session, business_id: str) -> ModelVersion | None:
    """Latest completed ModelVersion for the business."""
    return session.exec(
        select(ModelVersion)
        .where(
            ModelVersion.business_id == business_id,
            ModelVersion.status == "completed",
        )
        .order_by(ModelVersion.created_at.desc())
    ).first()


@router.get(
    "/businesses/{business_id}/inputs/{input_id}/links",
    response_model=list[VibeInputContextLinkOut],
    operation_id="listVibeInputLinks",
)
def list_vibe_input_links(
    business_id: str,
    input_id: str,
    session: Dependencies.Session,
    _role: Dependencies.ViewerDeclared,
):
    """All accumulated links for an input (origin first, then by created_at)."""
    _get_input(session, business_id, input_id)
    links = session.exec(
        select(VibeInputContextLink)
        .where(VibeInputContextLink.input_id == input_id)
        .order_by(
            VibeInputContextLink.is_origin.desc(),
            VibeInputContextLink.created_at,
        )
    ).all()
    return [_link_to_out(lk) for lk in links]


@router.post(
    "/businesses/{business_id}/inputs/{input_id}/links",
    response_model=VibeInputContextLinkOut,
    operation_id="addVibeInputLink",
)
def add_vibe_input_link(
    business_id: str,
    input_id: str,
    data: VibeInputContextLinkIn,
    session: Dependencies.Session,
    _role: Dependencies.ModelerDeclared,
):
    """Explicit add/relink of a link for a version. Enforces UNIQUE(input,version);
    never sets is_origin (immutable)."""
    _get_input(session, business_id, input_id)
    dup = session.exec(
        select(VibeInputContextLink).where(
            VibeInputContextLink.input_id == input_id,
            VibeInputContextLink.version_id == data.version_id,
        )
    ).first()
    if dup is not None:
        raise HTTPException(
            status_code=409,
            detail="A link for this input + version already exists",
        )
    link = VibeInputContextLink(
        input_id=input_id,
        version_id=data.version_id,
        domain_id=data.domain_id,
        subdomain_id=data.subdomain_id,
        product_id=data.product_id,
        attribute_id=data.attribute_id,
        fk_link_id=data.fk_link_id,
        is_origin=False,
    )
    session.add(link)
    session.commit()
    session.refresh(link)
    return _link_to_out(link)


def _get_link(session, business_id: str, link_id: str) -> VibeInputContextLink:
    lk = session.get(VibeInputContextLink, link_id)
    if lk is None:
        raise HTTPException(status_code=404, detail="Context link not found")
    vi = session.get(VibeInput, lk.input_id)
    if vi is None or vi.business_id != business_id:
        raise HTTPException(status_code=404, detail="Context link not found")
    return lk


@router.post(
    "/businesses/{business_id}/versions/{version_id}/inputs/carry-forward",
    response_model=CarryForwardResultOut,
    operation_id="carryForwardInputs",
)
def carry_forward_inputs(
    business_id: str,
    version_id: str,
    session: Dependencies.Session,
    _role: Dependencies.ModelerDeclared,
):
    """Run the re-link tiers for every active input lacking a link to
    ``version_id``. Idempotent."""
    _require_business(session, business_id)
    result = CarryForwardResultOut(version_id=version_id)
    inputs = session.exec(
        select(VibeInput).where(
            VibeInput.business_id == business_id,
            VibeInput.status == VibeInputStatus.ACTIVE.value,
        )
    ).all()
    for vi in inputs:
        outcome = relink_input(session, vi, version_id)
        if outcome == RelinkOutcome.AUTO:
            result.auto_linked += 1
        elif outcome == RelinkOutcome.REVIEW:
            result.needs_review += 1
        elif outcome == RelinkOutcome.DEPRECATED:
            result.deprecated += 1
        elif outcome == RelinkOutcome.SKIPPED:
            result.skipped_existing += 1
    session.commit()
    # Collect the newly-flagged link ids for the review queue.
    flagged = session.exec(
        select(VibeInputContextLink)
        .where(
            VibeInputContextLink.version_id == version_id,
            VibeInputContextLink.needs_link_review == True,  # noqa: E712
        )
    ).all()
    result.link_ids_needing_review = [lk.id for lk in flagged]
    return result


def _anchor_label(session, lk: VibeInputContextLink) -> tuple[str, str]:
    """(label, tier) for a flagged link, hydrated from element rows."""
    parts: list[str] = []
    if lk.domain_id:
        d = session.get(Domain, lk.domain_id)
        if d:
            parts.append(f"Domain {d.name}")
    if lk.subdomain_id:
        sd = session.get(Subdomain, lk.subdomain_id)
        if sd:
            parts.append(f"Subdomain {sd.name}")
    if lk.product_id:
        p = session.get(Product, lk.product_id)
        if p:
            parts.append(f"Product {p.name}")
    if lk.attribute_id:
        a = session.get(Attribute, lk.attribute_id)
        if a:
            parts.append(f"Attribute {a.name}")
    if lk.fk_link_id:
        fk = session.get(ForeignKeyLink, lk.fk_link_id)
        if fk:
            parts.append(f"Relationship {fk.source_product}→{fk.target_product}")
    label = " › ".join(parts) if parts else "Model-wide"
    # A flagged link with a leaf == merge survivor; with only an ancestor anchor
    # (parent present, leaf absent) == partial. We can't perfectly reconstruct
    # the tier post-hoc, so infer: a merge edge into this anchor => merge.
    tier = TIER_PARTIAL_ANCESTOR
    leaf_id = (lk.attribute_id or lk.fk_link_id or lk.product_id
               or lk.subdomain_id or lk.domain_id)
    if leaf_id is not None:
        merged = session.exec(
            select(RunElementLineage).where(
                RunElementLineage.version_id == lk.version_id,
                RunElementLineage.new_element_id == leaf_id,
                RunElementLineage.change_kind == "merge",
            )
        ).first()
        if merged is not None:
            tier = TIER_MERGE_SURVIVOR
    return label, tier


@router.get(
    "/businesses/{business_id}/links/review-queue",
    response_model=ReviewQueueOut,
    operation_id="getReviewQueue",
)
def get_review_queue(
    business_id: str,
    session: Dependencies.Session,
    _role: Dependencies.ViewerDeclared,
    version_id: str | None = None,
):
    """Resumable queue of links needing review (oldest-first), hydrated."""
    _require_business(session, business_id)
    query = (
        select(VibeInputContextLink, VibeInput)
        .join(VibeInput, VibeInput.id == VibeInputContextLink.input_id)
        .where(
            VibeInput.business_id == business_id,
            VibeInputContextLink.needs_link_review == True,  # noqa: E712
        )
        .order_by(VibeInputContextLink.created_at)
    )
    if version_id is not None:
        query = query.where(VibeInputContextLink.version_id == version_id)
    rows = session.exec(query).all()
    items = []
    for lk, vi in rows:
        label, tier = _anchor_label(session, lk)
        items.append(ReviewQueueItemOut(
            link=_link_to_out(lk),
            input=_input_to_out(vi),
            proposed_anchor_label=label,
            tier=tier,
        ))
    return ReviewQueueOut(total=len(items), items=items)


@router.post(
    "/businesses/{business_id}/links/{link_id}/review/accept",
    response_model=VibeInputContextLinkOut,
    operation_id="acceptReviewLink",
)
def accept_review_link(
    business_id: str,
    link_id: str,
    session: Dependencies.Session,
    _role: Dependencies.ModelerDeclared,
    headers: Dependencies.Headers,
):
    """Confirm the auto-proposed anchor: clear needs_link_review, stamp reviewer."""
    lk = _get_link(session, business_id, link_id)
    lk.needs_link_review = False
    lk.reviewed_by = actor_label(headers)
    lk.reviewed_at = _now()
    session.add(lk)
    session.commit()
    session.refresh(lk)
    return _link_to_out(lk)


@router.post(
    "/businesses/{business_id}/links/{link_id}/review/reanchor",
    response_model=VibeInputContextLinkOut,
    operation_id="reanchorReviewLink",
)
def reanchor_review_link(
    business_id: str,
    link_id: str,
    data: ReanchorIn,
    session: Dependencies.Session,
    _role: Dependencies.ModelerDeclared,
    headers: Dependencies.Headers,
):
    """Move the link to a user-chosen element on the same version, clear review."""
    lk = _get_link(session, business_id, link_id)
    _validate_elements_on_version(session, lk.version_id, data)
    # Duplicate guard handled by us since UNIQUE isn't enforced in SQLite mock:
    # reanchor only changes the anchor, not version, so it cannot create a dup.
    lk.domain_id = data.domain_id
    lk.subdomain_id = data.subdomain_id
    lk.product_id = data.product_id
    lk.attribute_id = data.attribute_id
    lk.fk_link_id = data.fk_link_id
    lk.needs_link_review = False
    lk.reviewed_by = actor_label(headers)
    lk.reviewed_at = _now()
    session.add(lk)
    session.commit()
    session.refresh(lk)
    return _link_to_out(lk)


def _validate_elements_on_version(session, version_id: str, data) -> None:
    checks = [
        (Domain, data.domain_id), (Subdomain, data.subdomain_id),
        (Product, data.product_id), (Attribute, data.attribute_id),
        (ForeignKeyLink, data.fk_link_id),
    ]
    for model, eid in checks:
        if eid is None:
            continue
        row = session.get(model, eid)
        if row is None:
            raise HTTPException(status_code=400, detail="Element not found")
        if model is Attribute:
            prod = session.get(Product, row.product_id)
            ok = bool(prod and prod.version_id == version_id)
        else:
            ok = getattr(row, "version_id", None) == version_id
        if not ok:
            raise HTTPException(
                status_code=400, detail="Element not on this version"
            )


@router.post(
    "/businesses/{business_id}/links/{link_id}/review/dismiss",
    response_model=VibeInputOut,
    operation_id="dismissReviewLink",
)
def dismiss_review_link(
    business_id: str,
    link_id: str,
    session: Dependencies.Session,
    _role: Dependencies.ModelerDeclared,
):
    """Reject the carry. For a user input this deletes the flagged non-origin
    carry link (never its origin); if no active non-origin head link remains
    the input is system-deprecated. For an agent next-vibe the review target
    IS its origin link, so dismiss means "reject this proposed next-vibe":
    deprecate the input and clear the review flag, keeping the origin anchor
    for audit rather than 409-ing (E-06)."""
    lk = _get_link(session, business_id, link_id)
    vi = session.get(VibeInput, lk.input_id)
    if lk.is_origin:
        if vi is not None and vi.origin == VibeInputOrigin.AGENT_NEXT_VIBE.value:
            lk.needs_link_review = False
            session.add(lk)
            vi.status = VibeInputStatus.DEPRECATED.value
            vi.deprecated_by = None
            vi.updated_at = _now()
            session.add(vi)
            session.commit()
            session.refresh(vi)
            return _input_to_out(vi)
        raise HTTPException(status_code=409, detail="Cannot dismiss the origin link")
    head = _resolve_head_version(session, business_id)
    dismissed_version = lk.version_id
    session.delete(lk)
    session.flush()

    if head is not None and dismissed_version == head.id:
        remaining = session.exec(
            select(VibeInputContextLink).where(
                VibeInputContextLink.input_id == vi.id,
                VibeInputContextLink.version_id == head.id,
            )
        ).first()
        if remaining is None:
            vi.status = VibeInputStatus.DEPRECATED.value
            vi.deprecated_by = None
            vi.updated_at = _now()
            session.add(vi)
    session.commit()
    session.refresh(vi)
    return _input_to_out(vi)


# --- Product-canonical review state (ADR D-044) -----------------------------
#
# Storage is sparse: a ``product_reviews`` row exists only on an explicit user
# mark. These endpoints own the WRITE surface — set a single product (the
# entity/leaf grain), cascade-mark a domain or subdomain (a write fan-out onto
# the product rows beneath it), and clear an explicit mark (revert to the
# computed default). The READ surface — effective states + progress, which
# fold in the computed-default rule from the change diff — lives in
# ``explorer.py`` (it already has the model JSON + diff).


# --- Bilingual element-key resolvers (write boundary) ----------------------
#
# The single home for resolving a UUID-or-human-key to a row, used ONLY by the
# mark/clear handlers below. Each does at most two indexed lookups (by id,
# version-scoped; else by the natural name key within the version); no per-row
# scans, no loops.


def _resolve_product(session, version_id: str, key: str) -> Product | None:
    """Resolve a product within ``version_id`` from a UUID or its FQN
    ``"<domain>.<product>"`` (matching the FE ``selected_node_id``)."""
    if not key or not version_id:
        return None
    by_id = session.get(Product, key)
    if by_id is not None and by_id.version_id == version_id:
        return by_id
    domain_name, sep, product_name = key.partition(".")
    if not sep:
        return None
    domain_id = session.exec(
        select(Domain.id).where(
            Domain.version_id == version_id, Domain.name == domain_name
        )
    ).first()
    if domain_id is None:
        return None
    prod = session.exec(
        select(Product).where(
            Product.version_id == version_id,
            Product.domain_id == domain_id,
            Product.name == product_name,
        )
    ).first()
    if prod is not None:
        return prod
    # ``selected_node_id`` can carry the physical table name (mirrors
    # anchor_resolve's product lookup).
    return session.exec(
        select(Product).where(
            Product.version_id == version_id,
            Product.domain_id == domain_id,
            Product.table_name == product_name,
        )
    ).first()


def _resolve_domain(session, version_id: str, key: str) -> Domain | None:
    """Resolve a domain within ``version_id`` from a UUID or its name."""
    if not key or not version_id:
        return None
    by_id = session.get(Domain, key)
    if by_id is not None and by_id.version_id == version_id:
        return by_id
    return session.exec(
        select(Domain).where(
            Domain.version_id == version_id, Domain.name == key
        )
    ).first()


def _resolve_subdomain(session, version_id: str, key: str) -> Subdomain | None:
    """Resolve a subdomain within ``version_id`` from a UUID or its name."""
    if not key or not version_id:
        return None
    by_id = session.get(Subdomain, key)
    if by_id is not None and by_id.version_id == version_id:
        return by_id
    return session.exec(
        select(Subdomain).where(
            Subdomain.version_id == version_id, Subdomain.name == key
        )
    ).first()


def _product_review_out(
    row: ProductReview, product_name: str = "", fqn: str = ""
) -> ProductReviewOut:
    return ProductReviewOut(
        id=row.id,
        version_id=row.version_id,
        product_id=row.product_id,
        product_name=product_name,
        fqn=fqn,
        state=ReviewState(row.state),
        reviewer=row.reviewer,
        reviewed_at=row.reviewed_at,
        is_explicit=True,
    )


def _product_names(session, version_id: str, product_ids: list[str]) -> dict[str, tuple[str, str]]:
    """One joined read: ``product_id -> (product_name, fqn)`` for the given
    ids, so cascade/mark responses are self-describing without a per-row
    query. FQN is the canonical "<domain>.<product>" (``explorer.product_fqn``)."""
    if not product_ids:
        return {}
    rows = session.exec(
        select(Product.id, Product.name, Domain.name)
        .join(Domain, Domain.id == Product.domain_id)
        .where(
            Product.version_id == version_id,
            Product.id.in_(product_ids),
        )
    ).all()
    return {pid: (pname, product_fqn(dname, pname)) for pid, pname, dname in rows}


def _upsert_product_review(
    session, version_id: str, product_id: str, state: ReviewState, reviewer: str
) -> ProductReview:
    """Insert-or-update the sparse review row for one product (idempotent via
    UNIQUE(version_id, product_id))."""
    existing = session.exec(
        select(ProductReview).where(
            ProductReview.version_id == version_id,
            ProductReview.product_id == product_id,
        )
    ).first()
    if existing is not None:
        existing.state = state.value
        existing.reviewer = reviewer
        existing.reviewed_at = _now()
        session.add(existing)
        return existing
    row = ProductReview(
        version_id=version_id,
        product_id=product_id,
        state=state.value,
        reviewer=reviewer,
    )
    session.add(row)
    return row


@router.post(
    "/businesses/{business_id}/versions/{version_int}/{scope}/reviews/product/{product_id}",
    response_model=ProductReviewOut,
    operation_id="markProductReview",
)
def mark_product_review(
    business_id: str,
    version_int: int,
    scope: Annotated[str, PathParam(pattern="^(ecm|mvm)$")],
    product_id: str,
    data: ReviewMarkIn,
    session: Dependencies.Session,
    _role: Dependencies.ModelerDeclared,
    headers: Dependencies.Headers,
):
    """Set the review state of a single product (the entity/leaf grain).

    The version is addressed by its natural ``(business, version_int, scope)``
    key — the same shape as the review READ endpoints. ``product_id`` is
    bilingual: a product UUID OR its FQN "<domain>.<product>". Idempotent:
    re-marking updates the row's state + reviewer. An explicit row always
    overrides the computed default."""
    _require_business(session, business_id)
    mv = _require_version(session, business_id, version_int, scope)
    prod = _resolve_product(session, mv.id, product_id)
    if prod is None:
        raise HTTPException(status_code=400, detail="Product not in version")
    row = _upsert_product_review(
        session, mv.id, prod.id, data.state, actor_label(headers)
    )
    session.commit()
    session.refresh(row)
    product_name, fqn = _product_names(session, mv.id, [prod.id]).get(
        prod.id, (prod.name, "")
    )
    return _product_review_out(row, product_name=product_name, fqn=fqn)


@router.delete(
    "/businesses/{business_id}/versions/{version_int}/{scope}/reviews/product/{product_id}",
    response_model=dict,
    operation_id="clearProductReview",
)
def clear_product_review(
    business_id: str,
    version_int: int,
    scope: Annotated[str, PathParam(pattern="^(ecm|mvm)$")],
    product_id: str,
    session: Dependencies.Session,
    _role: Dependencies.ModelerDeclared,
):
    """Clear an explicit mark, reverting the product to its computed default.
    The version is addressed by its natural ``(business, version_int, scope)``
    key. ``product_id`` is a UUID or the FQN "<domain>.<product>". 404 if no
    explicit row exists."""
    _require_business(session, business_id)
    mv = _require_version(session, business_id, version_int, scope)
    # Resolve the key to a product id when possible (UUID or FQN); if it
    # doesn't resolve to a current product, fall back to treating it as a raw
    # product_id so a stale-but-present review row can still be cleared (the
    # mark lookup, not product existence, owns the 404 here).
    prod = _resolve_product(session, mv.id, product_id)
    resolved_id = prod.id if prod is not None else product_id
    row = session.exec(
        select(ProductReview).where(
            ProductReview.version_id == mv.id,
            ProductReview.product_id == resolved_id,
        )
    ).first()
    if row is None:
        raise HTTPException(status_code=404, detail="Product review mark not found")
    session.delete(row)
    session.commit()
    return {"status": "cleared", "product_id": resolved_id}


def _cascade_mark(
    session,
    version_id: str,
    product_ids: list[str],
    state: ReviewState,
    reviewer: str,
) -> ReviewCascadeOut:
    """Fan out a mark onto a set of product rows (the cascade write semantics).

    The confirmation dialog ("this will mark N items / are you sure") is the
    frontend's responsibility (T4); this is the server-side write it confirms.
    """
    rows = [
        _upsert_product_review(session, version_id, pid, state, reviewer)
        for pid in product_ids
    ]
    session.commit()
    for r in rows:
        session.refresh(r)
    names = _product_names(session, version_id, [r.product_id for r in rows])
    return ReviewCascadeOut(
        version_id=version_id,
        affected=len(rows),
        products=[
            _product_review_out(r, *names.get(r.product_id, ("", "")))
            for r in rows
        ],
    )


@router.post(
    "/businesses/{business_id}/versions/{version_int}/{scope}/reviews/domain/{domain_id}",
    response_model=ReviewCascadeOut,
    operation_id="markDomainReview",
)
def mark_domain_review(
    business_id: str,
    version_int: int,
    scope: Annotated[str, PathParam(pattern="^(ecm|mvm)$")],
    domain_id: str,
    data: ReviewMarkIn,
    session: Dependencies.Session,
    _role: Dependencies.ModelerDeclared,
    headers: Dependencies.Headers,
):
    """Cascade a review state onto every product in a domain.

    The version is addressed by its natural ``(business, version_int, scope)``
    key. ``domain_id`` is bilingual: a domain UUID or its name."""
    _require_business(session, business_id)
    mv = _require_version(session, business_id, version_int, scope)
    dom = _resolve_domain(session, mv.id, domain_id)
    if dom is None:
        raise HTTPException(status_code=400, detail="Domain not in version")
    product_ids = [
        p.id
        for p in session.exec(
            select(Product).where(
                Product.version_id == mv.id,
                Product.domain_id == dom.id,
            )
        ).all()
    ]
    return _cascade_mark(session, mv.id, product_ids, data.state, actor_label(headers))


@router.post(
    "/businesses/{business_id}/versions/{version_int}/{scope}/reviews/subdomain/{subdomain_id}",
    response_model=ReviewCascadeOut,
    operation_id="markSubdomainReview",
)
def mark_subdomain_review(
    business_id: str,
    version_int: int,
    scope: Annotated[str, PathParam(pattern="^(ecm|mvm)$")],
    subdomain_id: str,
    data: ReviewMarkIn,
    session: Dependencies.Session,
    _role: Dependencies.ModelerDeclared,
    headers: Dependencies.Headers,
):
    """Cascade a review state onto every product in a subdomain.

    The version is addressed by its natural ``(business, version_int, scope)``
    key. ``subdomain_id`` is bilingual: a subdomain UUID or its name."""
    _require_business(session, business_id)
    mv = _require_version(session, business_id, version_int, scope)
    sub = _resolve_subdomain(session, mv.id, subdomain_id)
    if sub is None:
        raise HTTPException(status_code=400, detail="Subdomain not in version")
    product_ids = [
        p.id
        for p in session.exec(
            select(Product).where(
                Product.version_id == mv.id,
                Product.subdomain_id == sub.id,
            )
        ).all()
    ]
    return _cascade_mark(session, mv.id, product_ids, data.state, actor_label(headers))


# --- Compile (read-only; records nothing) -----------------------------------


@router.post(
    "/businesses/{business_id}/versions/{version_id}/inputs/compile",
    response_model=CompileOut,
    operation_id="compileVibeInputs",
)
def compile_vibe_inputs(
    business_id: str,
    version_id: str,
    data: CompileIn,
    session: Dependencies.Session,
    _role: Dependencies.ViewerDeclared,
):
    """Serialize the selected inputs anchored to ``version_id`` into one
    markdown doc + provenance blocks. Read-only."""
    _require_business(session, business_id)
    # Scope the selection to inputs in this business.
    ids = [
        vi.id
        for vi in session.exec(
            select(VibeInput).where(
                VibeInput.id.in_(data.input_ids),
                VibeInput.business_id == business_id,
            )
        ).all()
    ] if data.input_ids else []
    # Preserve the caller's order among the in-business ids.
    in_biz = set(ids)
    ordered = [i for i in data.input_ids if i in in_biz]
    return compile_inputs(
        session, version_id, ordered, scope_domains=data.vibe_scope_domains
    )
