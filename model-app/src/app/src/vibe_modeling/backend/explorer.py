"""Model Explorer API - browse generated data model JSON by version/domain/product."""

import json
import os
from datetime import datetime, timezone
from pathlib import Path
from typing import Annotated, Optional

from databricks.sdk.errors.platform import NotFound
from fastapi import HTTPException, Path as PathParam
from fastapi.responses import StreamingResponse
from sqlalchemy import String, case, cast, func, literal, null, or_, union_all
from sqlmodel import select

from ._query_helpers import resolve_model_version
from .core import Dependencies, create_router, resolve_version_volume_catalog
from .fk import (
    count_fk_attributes,
    fk_target_keys as _fk_target_keys,
    is_fk_attribute,
    parse_fk_target,
    product_fqn,
)
from .core._names import agent_business_segment
from .core._paths import model_json_volume_candidates, version_dir_candidates
from . import evolution_metrics as _evo_metrics
from . import next_vibe_metrics as _nv_metrics
from . import report_export as _report_export
from . import review as _review
from .model_diff import compute_model_diff
from .services.operations.enlarge_to_ecm import EnlargeToEcm
from .services.operations.shrink_to_mvm import ShrinkToMvm
from .db_models import (
    Attribute as DbAttribute,
    Business,
    Domain as DbDomain,
    ModelVersion,
    Product as DbProduct,
    Run,
    RunArtifact,
    RunOperation,
    Subdomain as DbSubdomain,
)
from .models import (
    AttributeOut,
    ChangeStatus,
    DomainConnectivityOut,
    DomainDetailOut,
    DomainReviewProgressOut,
    DomainSummaryOut,
    EvolutionChangeOut,
    EvolutionEffortOut,
    EvolutionMetricsOut,
    EvolutionProvenanceOut,
    EvolutionQualityOut,
    EvolutionSizeOut,
    Intent,
    ModelSearchHitOut,
    ModelSummaryOut,
    NextVibeCategoryCountsOut,
    NextVibeMetricsOut,
    ProductDetailOut,
    ProductReviewOut,
    ProductSummaryOut,
    RelationshipAnalysisOut,
    ReviewProgressOut,
    SubdomainSummaryOut,
    VersionHistoryEntryOut,
    VersionTreeOut,
)

router = create_router()


_compute_diff = compute_model_diff

# In-memory cache: (business_id, version_int, scope) -> parsed JSON dict
_model_cache: dict[tuple[str, int, str], dict] = {}


def invalidate_model_cache(business_id: str, version_int: int | None = None) -> None:
    """Drop cached model dicts after a sync/resync/import writes new data.

    Without this, force-resync and import-from-volume appear to succeed
    (Lakebase updates correctly) but the Explorer keeps serving the
    pre-sync model dict until the process restarts - exactly the
    symptom we hit when v4 resync looked like a no-op.

    Pass `version_int=None` to drop all cached versions for a business
    (e.g. on cascade delete). When version_int is given, all scope
    variants for that version are removed (we can't know which scope was
    cached at this call site).
    """
    if version_int is None:
        for key in [k for k in _model_cache if k[0] == business_id]:
            _model_cache.pop(key, None)
    else:
        for key in [k for k in _model_cache if k[0] == business_id and k[1] == version_int]:
            _model_cache.pop(key, None)


def _load_model_from_lakebase(session, business_id: str, version_int: int, scope: str) -> dict | None:
    """Try to load model structure from Lakebase Domain/Product/Attribute tables.

    Returns a dict matching the model.json schema, or None if no data exists.
    """
    mv = resolve_model_version(session, business_id, version_int, scope)
    if not mv:
        return None

    db_domains = session.exec(
        select(DbDomain).where(DbDomain.version_id == mv.id)
    ).all()
    if not db_domains:
        return None

    business = session.get(Business, business_id)

    # Cross-view consistency (#185): when the upstream loader emits one
    # ``Domain`` row per (logical_domain × subdomain) - observed on MVM v=2
    # for biz 297ae488 where 5 logical domains were persisted as 15 rows,
    # one per subdomain - the Ontology tab surfaced 15 while every other
    # view (Overview / Relationships) reported 5. Collapse on ``name`` here
    # so every downstream surface (overview, ontology, relationships,
    # diagram) sees a single entry per logical domain, with all the
    # subdomains' products merged in.
    domains_by_name: dict[str, dict] = {}
    domain_order: list[str] = []
    for d in db_domains:
        products = []
        db_products = session.exec(
            select(DbProduct).where(DbProduct.domain_id == d.id)
        ).all()
        for p in db_products:
            attrs = []
            db_attrs = session.exec(
                select(DbAttribute).where(DbAttribute.product_id == p.id)
            ).all()
            for a in db_attrs:
                attrs.append({
                    "id": a.id,
                    "attribute": a.name,
                    "name": a.name,
                    "column_name": a.column_name,
                    "type": a.type,
                    "description": a.description,
                    "business_glossary_term": a.business_glossary_term,
                    "tags": a.tags,
                    "value_regex": a.value_regex,
                    "foreign_key_to": a.foreign_key_to,
                    "references": a.references,
                })
            products.append({
                "id": p.id,
                "product": p.name,
                "name": p.name,
                "table_name": p.table_name,
                "description": p.description,
                "type": p.type,
                "data_type": p.data_type,
                "primary_key": p.primary_key,
                "subdomain": p.subdomain,
                "reference": p.reference,
                "attributes": attrs,
            })
        existing = domains_by_name.get(d.name)
        if existing is None:
            domains_by_name[d.name] = {
                "id": d.id,
                "name": d.name,
                "division": d.division,
                "description": d.description,
                "database_name": d.database_name,
                "references": d.references,
                "products": products,
            }
            domain_order.append(d.name)
        else:
            # Same logical domain split across multiple DB rows. Merge
            # products; keep the first non-empty value for scalar fields
            # so downstream tabs see stable metadata regardless of which
            # subdomain row sorted first.
            existing["products"].extend(products)
            for field in ("division", "description", "database_name", "references"):
                if not existing.get(field) and getattr(d, field, ""):
                    existing[field] = getattr(d, field, "")

    domains = [domains_by_name[n] for n in domain_order]

    return {
        "business_name": business.name if business else "",
        "version": version_int,
        "domains": domains,
    }


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------


def _find_model_json_path(
    session, ws, business_id: str, version_int: int, scope: str
) -> str | None:
    """Resolve the file path for a model JSON artifact.

    Three strategies, in order:

    0. **Canonical path builder** (current agent layout, 4.9.8+).
       Asks ``model_json_volume_candidates`` for the nested
       ``v{N}/{scope}/model.json`` then the legacy flat
       ``{scope}_v{N}/model.json`` and probes each via
       ``ws.files.get_metadata`` (raises ``NotFound`` when the file is
       absent). Catches the case where the agent wrote the artifact but
       ``sync_model`` failed before a ``RunArtifact`` row was inserted, and
       the case where ``vibe_iterate`` produced a version without indexing
       artifacts at all.
    1. **RunArtifact lookup** by ``(business, version, scope)``. The
       ``artifact_type`` value MUST match what the writers emit - the
       canonical value is ``"model_json"`` (see vibe_iterate's
       ``_finalize_success`` and the post-success indexing in
       ``progress_tracker.index_artifacts_for_version``).
    2. **Convention docs path** where the agent wrote
       ``v{N}/{scope}/docs/{name}_data_model_v{N}.json`` (nested) or the
       legacy flat ``{scope}_v{N}/docs/...`` variant.
    """
    # Strategy 0: canonical path via the path builder. Covers the
    # "version exists, RunArtifact missing, model.json on disk" case
    # that broke v=2 ECM in the v0.7.1 walkthrough.
    mv = resolve_model_version(session, business_id, version_int, scope)
    business = session.get(Business, business_id)
    if mv and business:
        # Where the version's files are (resolve_version_volume_catalog:
        # files_catalog, else uc_catalog, else the installation metamodel
        # catalog by a session-only read, no seed).
        catalog = resolve_version_volume_catalog(mv, session)
        if catalog:
            try:
                canonical_candidates = model_json_volume_candidates(
                    catalog, business.name, version_int, scope
                )
            except ValueError:
                # ``_validate_scope`` rejects unknown scope tokens. That
                # would mean the ModelVersion row's scope is malformed,
                # not a path-not-found signal - but at this layer we
                # treat it the same: try the next strategy.
                canonical_candidates = []
            # Nested (agent 4.9.8+) first, legacy flat fallback.
            for canonical in canonical_candidates:
                try:
                    ws.files.get_metadata(canonical)
                    return canonical
                except NotFound:
                    # File doesn't exist at this candidate - try the next
                    # candidate, then Strategy 1. Any other Files API error
                    # (auth, transient, AttributeError on a wrong SDK
                    # call) propagates; that's how we caught the
                    # ``get_status`` typo this fix replaces.
                    continue

    # Strategy 1: find via RunArtifact for a completed run. The
    # writer emits ``artifact_type="model_json"``; the previous reader
    # queried ``"json"`` and silently never matched a vibe_iterate row.
    stmt = (
        select(RunArtifact)
        .join(Run, Run.id == RunArtifact.run_id)
        .join(ModelVersion, ModelVersion.id == Run.version_id)
        .where(
            Run.business_id == business_id,
            ModelVersion.version == version_int,
            ModelVersion.scope == scope,
            Run.status == "completed",
            RunArtifact.artifact_type == "model_json",
        )
        .order_by(RunArtifact.created_at.desc())
    )
    artifact = session.exec(stmt).first()
    if artifact and artifact.file_path:
        return artifact.file_path

    # Strategy 2: convention-based docs path. The agent nests docs under
    # ``v{N}/{scope}/docs`` (4.9.8+); the legacy flat ``{scope}_v{N}/docs``
    # is probed as a fallback for pre-upgrade rows.
    if mv and business:
        name = agent_business_segment(business.name)
        catalog = resolve_version_volume_catalog(mv, session)
        if catalog:
            try:
                docs_dirs = [
                    f"{root}/docs"
                    for root in version_dir_candidates(
                        catalog, business.name, version_int, scope
                    )
                ]
            except ValueError:
                docs_dirs = []
            suffix = f"_data_model_v{version_int}.json"
            for docs_dir in docs_dirs:
                candidate = f"{docs_dir}/{name}{suffix}"
                # Try convention path via SDK. Same NotFound-only discipline
                # as Strategy 0 - only "file doesn't exist" is a fall-through
                # signal; everything else propagates.
                try:
                    ws.files.get_metadata(candidate)
                    return candidate
                except NotFound:
                    pass
                # Fall back: list docs dir for *_data_model_v{version}.json
                # (handles old versions where the business name in filenames
                # differs). The directory itself missing is a NotFound; any
                # other listing error propagates.
                try:
                    for entry in ws.files.list_directory_contents(docs_dir):
                        if entry.name and entry.name.endswith(suffix):
                            return f"{docs_dir}/{entry.name}"
                except NotFound:
                    pass
    return None


def _load_model(
    session, ws, business_id: str, version_int: int, scope: str = ""
) -> dict:
    """Load and cache the model JSON for a business version.

    Tries Lakebase first (synced model data), then falls back to Volume JSON
    for legacy versions that predate the sync integration.
    """
    cache_key = (business_id, version_int, scope)
    if cache_key in _model_cache:
        return _model_cache[cache_key]

    # Try Lakebase first
    lakebase_model = _load_model_from_lakebase(session, business_id, version_int, scope)
    if lakebase_model:
        _model_cache[cache_key] = lakebase_model
        return lakebase_model

    # Fall back to Volume JSON
    file_path = _find_model_json_path(session, ws, business_id, version_int, scope)
    if not file_path:
        raise HTTPException(status_code=404, detail="Model JSON not found")

    model_data = _read_volume_json(ws, file_path)
    if model_data is None:
        raise HTTPException(status_code=404, detail="Model JSON not found")

    # Never cache a structureless load. The ModelVersion row is created
    # mid-run (before its domains are synced), so a read during that window
    # returns 0 domains; caching it would pin a stale-empty model that later
    # reads keep serving even after the sync lands (the cache is only busted by
    # manual version ops, not by run-completion sync). A real model always has
    # domains, so an empty result means "not synced yet" - leave it uncached so
    # the next read re-loads fresh.
    if model_data.get("domains"):
        _model_cache[cache_key] = model_data
    return model_data


def _read_volume_json(ws, file_path: str) -> dict | None:
    """Read and parse a model JSON file from a resolved path.

    Tries, in order: a local path (dev), a Volume FUSE mount, then the
    Databricks Files API. Returns the parsed dict or raises ``HTTPException``
    when the SDK download fails. Shared by ``_load_model`` (which then drops
    everything but the inner ``model`` block via Lakebase preference) and
    ``_load_model_json_envelope`` (which keeps the whole envelope)."""
    local = Path(file_path)
    if local.exists():
        return json.loads(local.read_text())
    if file_path.startswith("/Volumes") and Path(file_path).exists():
        return json.loads(Path(file_path).read_text())
    try:
        resp = ws.files.download(file_path)
        content = resp.contents.read()
        return json.loads(content)
    except Exception as e:
        raise HTTPException(
            status_code=404,
            detail=f"Could not read this version's model file: {e}",
        )


def _load_model_json_envelope(
    session, ws, business_id: str, version_int: int, scope: str
) -> dict | None:
    """Load the FULL Volume ``model.json`` envelope for a version.

    Unlike ``_load_model`` - which prefers the Lakebase-synced structure and
    therefore returns a metadata-less model dict - this reads the raw Volume
    artifact so the agent's top-level ``agent_version`` and the
    ``_vibe_session_metadata`` block survive. Used by the evolution-metrics
    endpoint, the only reader that needs the session metadata.

    Returns the envelope dict, or ``None`` when no Volume artifact exists
    (e.g. an import-only version that was never written to the Volume)."""
    file_path = _find_model_json_path(session, ws, business_id, version_int, scope)
    if not file_path:
        return None
    return _read_volume_json(ws, file_path)


def _find_domain(model: dict, domain_name: str) -> dict | None:
    for d in model.get("domains", []):
        if d.get("name") == domain_name:
            return d
    return None


def _find_product(domain: dict, product_name: str) -> dict | None:
    for p in domain.get("products", []):
        if p.get("name") == product_name:
            return p
    return None


def _load_prev_model(session, ws, business_id: str, version_int: int, scope: str = "") -> dict | None:
    """Try to load the model for the previous version of the same scope.

    The previous version is the row's lineage base (``base_version_id``) when
    that base has the same scope and is not a Dry Run ``draft``, so a Full Run
    made after a Dry Run diffs against the version it was built on. Otherwise
    (no base, a draft base, or the cross-scope base that shrink/enlarge stamp,
    an MVM built from an ECM) it is max(version) WHERE business_id=X AND
    scope=Y AND version < N AND status != "draft", so ECM and MVM diffs don't
    bleed across scopes and drafts are never the comparison point.
    """
    if version_int <= 1:
        return None
    try:
        current_mv = session.exec(
            select(ModelVersion).where(
                ModelVersion.business_id == business_id,
                ModelVersion.scope == scope,
                ModelVersion.version == version_int,
            )
        ).first()
        prev_mv = None
        if current_mv is not None and current_mv.base_version_id:
            base_mv = session.get(ModelVersion, current_mv.base_version_id)
            if (
                base_mv is not None
                and base_mv.business_id == business_id
                and (base_mv.scope or "") == (scope or "")
                and base_mv.status != "draft"
                and base_mv.version < version_int
            ):
                prev_mv = base_mv
        if prev_mv is None:
            prev_mv = session.exec(
                select(ModelVersion)
                .where(
                    ModelVersion.business_id == business_id,
                    ModelVersion.scope == scope,
                    ModelVersion.version < version_int,
                    ModelVersion.status != "draft",
                )
                .order_by(ModelVersion.version.desc())
            ).first()
        if not prev_mv:
            return None
        return _load_model(session, ws, business_id, prev_mv.version, scope)
    except HTTPException:
        return None


# ---------------------------------------------------------------------------
# Endpoints
# ---------------------------------------------------------------------------


# Operations whose output copies its parent's brand instead of being a vibe
# iteration of it: New Base Model's shrink step gets the just-generated base
# ECM as parent and must read Base, not Vibed.
_BRAND_INHERITING_OPS = (ShrinkToMvm.name, EnlargeToEcm.name)


def _version_brands(
    session, versions: list[ModelVersion]
) -> dict[str, tuple[bool, bool]]:
    """Map version id -> ``(is_base, parent_deleted)`` for one business.

    Base: no lineage parent, or a shrink/enlarge output whose parent is Base.
    Vibed: everything else. ``base_version_id`` has no FK, so a deleted parent
    leaves the pointer behind. A shrink/enlarge output in that state is
    ``(False, True)``, except the shrink step of a New Base Model run, which
    is Base whatever happened to the ECM it was shrunk from. Any other output
    with a deleted parent is plain Vibed.
    """
    by_id = {v.id: v for v in versions}
    # version id -> intent of the run that produced it, for shrink/enlarge outputs.
    inheriting: dict[str, str] = {}
    if by_id:
        rows = session.exec(
            select(RunOperation.output_version_id, Run.intent)
            .join(Run, Run.id == RunOperation.run_id)
            .where(
                RunOperation.output_version_id.in_(list(by_id)),
                RunOperation.operation_name.in_(_BRAND_INHERITING_OPS),
            )
        ).all()
        for version_id, intent in rows:
            inheriting.setdefault(version_id, intent)

    brands: dict[str, tuple[bool, bool]] = {}

    def own_brand(v: ModelVersion) -> Optional[tuple[bool, bool]]:
        """The brand when it does not depend on the parent's, else None."""
        if v.base_version_id is None:
            return (True, False)
        if v.id not in inheriting:
            return (False, False)
        if v.base_version_id not in by_id:
            if inheriting[v.id] == Intent.NEW_BASE_MODEL.value:
                return (True, False)
            return (False, True)
        return None

    # Iterative so a long lineage chain cannot hit the recursion limit.
    for v in versions:
        path: list[ModelVersion] = []
        on_path: set[str] = set()
        cur = v
        while cur.id not in brands:
            result = own_brand(cur)
            if result is not None:
                brands[cur.id] = result
                break
            path.append(cur)
            on_path.add(cur.id)
            parent = by_id[cur.base_version_id]
            if parent.id in on_path:
                brands[cur.id] = (False, False)
                path.pop()
                break
            cur = parent
        for node in reversed(path):
            brands[node.id] = (brands[node.base_version_id][0], False)
    return brands


@router.get(
    "/businesses/{business_id}/explorer/versions",
    response_model=list[VersionTreeOut],
    operation_id="getExplorerVersions",
)
def get_explorer_versions(business_id: str, session: Dependencies.Session):
    """Return all model versions with lineage info."""
    versions = session.exec(
        select(ModelVersion)
        .where(ModelVersion.business_id == business_id)
        .order_by(ModelVersion.version.asc())
    ).all()
    brands = _version_brands(session, versions)

    return [
        VersionTreeOut(
            id=v.id,
            version=v.version,
            status=v.status,
            deployment_status=v.deployment_status or "draft",
            base_version_id=v.base_version_id,
            vibe_instructions=v.vibe_instructions or "",
            confidence_score=v.confidence_score,
            scope=v.scope or "",
            created_at=v.created_at,
            is_base=brands[v.id][0],
            parent_deleted=brands[v.id][1],
        )
        for v in versions
    ]


@router.get(
    "/businesses/{business_id}/versions/{version_int}/{scope}/model",
    response_model=ModelSummaryOut,
    operation_id="getModelSummary",
)
def get_model_summary(
    business_id: str,
    version_int: int,
    scope: Annotated[str, PathParam(pattern="^(ecm|mvm)$")],
    session: Dependencies.Session,
    ws: Dependencies.Client,
):
    """Return model overview with domain list and change indicators vs previous version."""
    model = _load_model(session, ws, business_id, version_int, scope)
    prev_model = _load_prev_model(session, ws, business_id, version_int, scope)
    diff = _compute_diff(prev_model, model)

    domains = model.get("domains", [])
    # Cross-view consistency: Overview/Diagram/Relationships/Ontology must all
    # report the SAME domain count.  ``_load_model_from_lakebase`` already
    # collapses split (domain × subdomain) Domain DB rows on ``name``, so the
    # Lakebase path arrives here with one entry per logical domain. The raw
    # ``len(domains)`` would still over-count for the Volume JSON fallback
    # path if the agent ever emits duplicate-named entries - keep the
    # set-based count as a defence-in-depth so every surface downstream
    # always agrees on the unique-domain count.
    unique_domain_count = len({d.get("name", "") for d in domains if d.get("name")})
    total_products = sum(len(d.get("products", [])) for d in domains)
    total_attributes = sum(
        len(p.get("attributes", []))
        for d in domains
        for p in d.get("products", [])
    )
    total_fks = sum(
        count_fk_attributes(p.get("attributes", []))
        for d in domains
        for p in d.get("products", [])
    )

    # Fetch confidence score from the ModelVersion record
    mv = resolve_model_version(session, business_id, version_int, scope)
    confidence = mv.confidence_score if mv else None
    review_pct, reviewed_count, review_needed_count, no_review_needed_count = (
        _compute_review_pct(session, mv, diff["products"], prev_model is not None)
    )

    # One read for the subdomain name -> id map (no per-subdomain query); the
    # rollup below is name-derived from the products' ``subdomain`` field.
    subdomain_id_by_name = {
        sd.name: sd.id
        for sd in session.exec(
            select(DbSubdomain).where(DbSubdomain.version_id == mv.id)
        ).all()
    } if mv else {}

    def _subdomains_for(products: list[dict]) -> list[SubdomainSummaryOut]:
        counts: dict[str, int] = {}
        for p in products:
            sd = p.get("subdomain", "")
            if sd:
                counts[sd] = counts.get(sd, 0) + 1
        return sorted(
            [
                SubdomainSummaryOut(
                    id=subdomain_id_by_name.get(k, ""), name=k, product_count=v
                )
                for k, v in counts.items()
            ],
            key=lambda s: s.name.lower(),
        )

    domain_list = sorted(
        [
            DomainSummaryOut(
                id=d.get("id", ""),
                name=d.get("name", ""),
                division=d.get("division", ""),
                description=d.get("description", ""),
                database_name=d.get("database_name", ""),
                references=d.get("references", ""),
                product_count=len(d.get("products", [])),
                subdomains=_subdomains_for(d.get("products", [])),
                change_status=diff["domains"].get(d.get("name", ""), ChangeStatus.UNCHANGED),
            )
            for d in domains
        ],
        key=lambda d: d.name.lower(),
    )
    # Append deleted domains from previous version
    domain_list.extend(diff["deleted_domains"])

    # Unique-subdomain count is derived at read-time from the in-memory
    # model dict (which itself was hydrated from Product.subdomain in
    # Lakebase via ``_load_model_from_lakebase``). No new column.
    unique_subdomain_names: set[str] = set()
    for d in domains:
        for p in d.get("products", []):
            sd = p.get("subdomain", "")
            if sd:
                unique_subdomain_names.add(sd)

    return ModelSummaryOut(
        name=model.get("name", ""),
        version=model.get("version", str(version_int)),
        description=model.get("description", ""),
        industry_alignment=model.get("industry_alignment", ""),
        core_business_processes=model.get("core_business_processes", ""),
        vibe_modeling_instructions=model.get("vibe_modeling_instructions", ""),
        domain_count=unique_domain_count,
        subdomain_count=len(unique_subdomain_names),
        product_count=total_products,
        attribute_count=total_attributes,
        fk_count=total_fks,
        confidence_score=confidence,
        review_pct=review_pct,
        reviewed_count=reviewed_count,
        review_needed_count=review_needed_count,
        no_review_needed_count=no_review_needed_count,
        domains=domain_list,
    )


_SEARCH_TYPE_PRIORITY = {"domain": 0, "product": 1, "attribute": 2}


def _escape_like(term: str) -> str:
    """Escape LIKE/ILIKE wildcards so user input is matched literally."""
    return term.replace("\\", "\\\\").replace("%", "\\%").replace("_", "\\_")


@router.get(
    "/businesses/{business_id}/versions/{version_int}/{scope}/search",
    response_model=list[ModelSearchHitOut],
    operation_id="searchModelElements",
)
def search_model_elements(
    business_id: str,
    version_int: int,
    scope: Annotated[str, PathParam(pattern="^(ecm|mvm)$")],
    session: Dependencies.Session,
    q: str = "",
    limit: int = 20,
):
    """Model-wide name search over domains, products/tables and attributes/columns.

    Runs as a SINGLE round-trip: the ``(business, version, scope)`` -> version-id
    lookup is a scalar subquery embedded in one ``UNION ALL`` across the three
    element kinds, each narrowed by the indexed ``version_id`` FK (attributes
    join via ``product_id``) and filtered by a case-insensitive substring match
    on the element name. On Postgres, ``attributes.name`` and
    ``attributes.column_name`` carry ``pg_trgm`` GIN indexes (v_0_6_6), which
    the planner uses for ILIKE substring matches of 3+ characters; shorter
    patterns can't use a trigram index and fall back to a sequential scan.
    SQLite/PGLite (tests, local dev) have no trigram support and always scan.
    Debounce + a client-side minimum query length + ``limit`` keep this cheap
    regardless of backend. Ranking is exact > prefix > substring, then
    domain > product > attribute within a tier, capped at ``limit``. An
    unknown version yields no rows -> [].
    """
    q = (q or "").strip()
    if not q:
        return []
    limit = max(1, min(limit, 50))

    q_lower = q.lower()
    escaped = _escape_like(q)
    pattern = f"%{escaped}%"
    prefix_lower = f"{_escape_like(q_lower)}%"

    # Version-id resolved inline so the whole search is one statement (no
    # separate resolve_model_version round-trip). A missing version makes the
    # subquery NULL, so every branch's ``version_id == NULL`` matches nothing.
    mv_id = (
        select(ModelVersion.id)
        .where(ModelVersion.business_id == business_id)
        .where(ModelVersion.version == version_int)
        .where(ModelVersion.scope == scope)
        .scalar_subquery()
    )

    def _tier(col):
        # Order each branch's DB fetch so the best matches survive the LIMIT.
        return case(
            (func.lower(col) == q_lower, 0),
            (func.lower(col).like(prefix_lower, escape="\\"), 1),
            else_=2,
        )

    _s = lambda: cast(null(), String)  # noqa: E731 - NULL placeholder, typed for UNION

    # Uniform column shape across branches: (type, domain, product, attribute,
    # extra) where ``extra`` carries the domain's division (domain rows only).
    domain_q = (
        select(
            literal("domain").label("type"),
            DbDomain.name.label("domain_name"),
            _s().label("product_name"),
            _s().label("attribute_name"),
            DbDomain.division.label("extra"),
        )
        .where(DbDomain.version_id == mv_id)
        .where(DbDomain.name.ilike(pattern, escape="\\"))
        .order_by(_tier(DbDomain.name), func.lower(DbDomain.name))
        .limit(limit)
    )
    product_q = (
        select(
            literal("product"),
            DbDomain.name,
            DbProduct.name,
            _s(),
            _s(),
        )
        .select_from(DbProduct)
        .join(DbDomain, DbProduct.domain_id == DbDomain.id)
        .where(DbProduct.version_id == mv_id)
        .where(
            or_(
                DbProduct.name.ilike(pattern, escape="\\"),
                DbProduct.table_name.ilike(pattern, escape="\\"),
            )
        )
        .order_by(_tier(DbProduct.name), func.lower(DbProduct.name))
        .limit(limit)
    )
    attribute_q = (
        select(
            literal("attribute"),
            DbDomain.name,
            DbProduct.name,
            DbAttribute.name,
            _s(),
        )
        .select_from(DbAttribute)
        .join(DbProduct, DbAttribute.product_id == DbProduct.id)
        .join(DbDomain, DbProduct.domain_id == DbDomain.id)
        .where(DbProduct.version_id == mv_id)
        .where(
            or_(
                DbAttribute.name.ilike(pattern, escape="\\"),
                DbAttribute.column_name.ilike(pattern, escape="\\"),
            )
        )
        .order_by(_tier(DbAttribute.name), func.lower(DbAttribute.name))
        .limit(limit)
    )

    # Wrap each branch as a derived table so the per-branch ORDER BY + LIMIT
    # survive the UNION ALL. SQLite rejects the parenthesized-compound form
    # SQLAlchemy would otherwise emit for `union_all(select.limit(), ...)`.
    union_q = union_all(
        select(domain_q.subquery()),
        select(product_q.subquery()),
        select(attribute_q.subquery()),
    )
    rows = session.exec(union_q).all()

    hits: list[ModelSearchHitOut] = []
    seen_domains: set[str] = set()
    for row in rows:
        row_type, domain_name, product_name, attribute_name, extra = row
        if row_type == "domain":
            # Split (domain × subdomain) rows share a name; one hit per domain.
            if domain_name in seen_domains:
                continue
            seen_domains.add(domain_name)
            hits.append(
                ModelSearchHitOut(
                    type="domain",
                    domain_name=domain_name,
                    label=domain_name,
                    sublabel=extra or "",
                )
            )
        elif row_type == "product":
            hits.append(
                ModelSearchHitOut(
                    type="product",
                    domain_name=domain_name,
                    product_name=product_name,
                    label=product_name,
                    sublabel=domain_name,
                )
            )
        else:
            hits.append(
                ModelSearchHitOut(
                    type="attribute",
                    domain_name=domain_name,
                    product_name=product_name,
                    attribute_name=attribute_name,
                    label=attribute_name,
                    sublabel=f"{domain_name} › {product_name}",
                )
            )

    def _rank(hit: ModelSearchHitOut) -> tuple[int, int, str]:
        label_lower = hit.label.lower()
        if label_lower == q_lower:
            match_tier = 0
        elif label_lower.startswith(q_lower):
            match_tier = 1
        else:
            match_tier = 2
        return (match_tier, _SEARCH_TYPE_PRIORITY[hit.type], label_lower)

    hits.sort(key=_rank)
    return hits[:limit]


@router.get(
    "/businesses/{business_id}/versions/{version_int}/{scope}/reviews",
    response_model=list[ProductReviewOut],
    operation_id="listProductReviews",
)
def list_product_reviews(
    business_id: str,
    version_int: int,
    scope: Annotated[str, PathParam(pattern="^(ecm|mvm)$")],
    session: Dependencies.Session,
    ws: Dependencies.Client,
):
    """Effective review state of every product on a version.

    Folds the sparse ``product_reviews`` marks together with the computed
    default (ADR D-044): an unmarked, unchanged product with no open issues is
    ``no_review_needed``; otherwise ``not_reviewed``. ``is_explicit`` flags the
    stored user marks. The change signal reuses the same per-product diff
    behind the UI change icons."""
    mv = resolve_model_version(session, business_id, version_int, scope)
    if mv is None:
        raise HTTPException(status_code=404, detail="Model version not found")
    model = _load_model(session, ws, business_id, version_int, scope)
    prev_model = _load_prev_model(session, ws, business_id, version_int, scope)
    diff = _compute_diff(prev_model, model)
    views = _review.effective_states(
        session, mv.id, diff["products"], prev_model is not None
    )
    # One joined read to make every review row self-describing (name + FQN)
    # without a per-product query: id -> (domain_name, product_name).
    name_by_pid: dict[str, tuple[str, str]] = {
        pid: (dname, pname)
        for pid, pname, dname in session.exec(
            select(DbProduct.id, DbProduct.name, DbDomain.name)
            .join(DbDomain, DbDomain.id == DbProduct.domain_id)
            .where(DbProduct.version_id == mv.id)
        ).all()
    }
    out: list[ProductReviewOut] = []
    for v in views:
        dname, pname = name_by_pid.get(v.product_id, ("", ""))
        out.append(
            ProductReviewOut(
                version_id=mv.id,
                product_id=v.product_id,
                product_name=pname,
                fqn=product_fqn(dname, pname),
                state=v.state,
                is_explicit=v.is_explicit,
            )
        )
    return out


@router.get(
    "/businesses/{business_id}/versions/{version_int}/{scope}/review-progress",
    response_model=ReviewProgressOut,
    operation_id="getReviewProgress",
)
def get_review_progress(
    business_id: str,
    version_int: int,
    scope: Annotated[str, PathParam(pattern="^(ecm|mvm)$")],
    session: Dependencies.Session,
    ws: Dependencies.Client,
):
    """Product-level review progress for the whole version (reviewed ÷
    review-needed; ``no_review_needed`` excluded from the denominator)."""
    mv = resolve_model_version(session, business_id, version_int, scope)
    if mv is None:
        raise HTTPException(status_code=404, detail="Model version not found")
    model = _load_model(session, ws, business_id, version_int, scope)
    prev_model = _load_prev_model(session, ws, business_id, version_int, scope)
    diff = _compute_diff(prev_model, model)
    has_pred = prev_model is not None
    pct, reviewed, review_needed, no_review_needed = _review.compute_progress(
        session, mv.id, diff["products"], has_pred
    )
    total = len(
        _review.effective_states(session, mv.id, diff["products"], has_pred)
    )
    return ReviewProgressOut(
        version_id=mv.id,
        review_pct=pct,
        reviewed=reviewed,
        review_needed=review_needed,
        no_review_needed=no_review_needed,
        total=total,
    )


@router.get(
    "/businesses/{business_id}/versions/{version_int}/{scope}/review-progress/by-domain",
    response_model=list[DomainReviewProgressOut],
    operation_id="getReviewProgressByDomain",
)
def get_review_progress_by_domain(
    business_id: str,
    version_int: int,
    scope: Annotated[str, PathParam(pattern="^(ecm|mvm)$")],
    session: Dependencies.Session,
    ws: Dependencies.Client,
):
    """Per-domain review rollup for a version (reviewed ÷ review-needed per
    domain; ``no_review_needed`` excluded). Derived from the same per-product
    effective states as the scope-level progress - no stored aggregate. Drives
    the scope tree + focus table per-domain %."""
    mv = resolve_model_version(session, business_id, version_int, scope)
    if mv is None:
        raise HTTPException(status_code=404, detail="Model version not found")
    model = _load_model(session, ws, business_id, version_int, scope)
    prev_model = _load_prev_model(session, ws, business_id, version_int, scope)
    diff = _compute_diff(prev_model, model)
    by_domain = _review.compute_progress_by_domain(
        session, mv.id, diff["products"], prev_model is not None
    )
    # One read for domain id -> name; no per-domain query.
    name_by_id = {
        d.id: d.name
        for d in session.exec(
            select(DbDomain).where(DbDomain.version_id == mv.id)
        ).all()
    }
    return [
        DomainReviewProgressOut(
            domain_id=did,
            domain=name_by_id.get(did, ""),
            review_pct=pct,
            reviewed=reviewed,
            review_needed=review_needed,
            no_review_needed=no_review_needed,
        )
        for did, (pct, reviewed, review_needed, no_review_needed) in by_domain.items()
    ]


def _compute_review_pct(
    session,
    mv,
    product_change_status: dict[tuple[str, str], ChangeStatus],
    has_predecessor: bool = True,
) -> tuple[float, int, int, int]:
    """Product-level review progress for this version.

    Delegates to ``review.compute_progress`` - the canonical product-canonical
    measure (ADR D-044): reviewed ÷ review-needed, where ``no_review_needed``
    products (sparse ``product_reviews`` row OR computed default) are excluded
    from the denominator. ``product_change_status`` is the
    ``(domain_name, product_name) -> ChangeStatus`` map from ``_compute_diff``;
    it feeds the computed-default rule for unmarked products. Resets per
    version (no carry-forward).

    Returns ``(review_pct, reviewed, review_needed, no_review_needed)``.
    """
    if mv is None:
        return 0.0, 0, 0, 0
    return _review.compute_progress(
        session, mv.id, product_change_status, has_predecessor
    )


def _metrics_out(
    version_id: str,
    domain_id: str | None,
    metrics: _nv_metrics.NextVibeMetrics,
) -> NextVibeMetricsOut:
    """Project the computed metrics dataclass onto the wire shape."""
    return NextVibeMetricsOut(
        version_id=version_id,
        domain_id=domain_id,
        quality_score=metrics.quality_score,
        counts=NextVibeCategoryCountsOut(
            static_analysis=metrics.counts.get("static_analysis", 0),
            priority_remediation=metrics.counts.get("priority_remediation", 0),
            other=metrics.counts.get("other", 0),
            total=metrics.total_open,
        ),
        total_open=metrics.total_open,
        has_data=metrics.has_data,
    )


@router.get(
    "/businesses/{business_id}/versions/{version_int}/{scope}/next-vibe-metrics",
    response_model=NextVibeMetricsOut,
    operation_id="getNextVibeMetrics",
)
def get_next_vibe_metrics(
    business_id: str,
    version_int: int,
    scope: Annotated[str, PathParam(pattern="^(ecm|mvm)$")],
    session: Dependencies.Session,
):
    """Model-scope next_vibes "expected work" metrics for a version (T13).

    Aggregates the open (active, non-consumed) ``agent_next_vibe`` VibeInputs
    anchored anywhere on the version: the Model Quality Score (mean of their
    ``confidence_score``), per-category open counts, and ``total_open``.
    Degrades to zeros/null with ``has_data=False`` when no agent inputs exist
    yet (the pre-ingestion default)."""
    mv = resolve_model_version(session, business_id, version_int, scope)
    if mv is None:
        raise HTTPException(status_code=404, detail="Model version not found")
    metrics = _nv_metrics.compute_metrics(session, mv.id)
    return _metrics_out(mv.id, None, metrics)


@router.get(
    "/businesses/{business_id}/versions/{version_int}/{scope}/domains/{domain_name}/next-vibe-metrics",
    response_model=NextVibeMetricsOut,
    operation_id="getDomainNextVibeMetrics",
)
def get_domain_next_vibe_metrics(
    business_id: str,
    version_int: int,
    scope: Annotated[str, PathParam(pattern="^(ecm|mvm)$")],
    domain_name: str,
    session: Dependencies.Session,
):
    """Domain-scope next_vibes "expected work" metrics for a version (T13).

    Same aggregation as the model scope, restricted to open agent inputs whose
    anchor resolves to ``domain_name`` - directly via the link's ``domain_id``
    or derived from the product/attribute anchor's product → domain map.
    Degrades to zeros/null with ``has_data=False`` when the domain has no open
    agent inputs."""
    mv = resolve_model_version(session, business_id, version_int, scope)
    if mv is None:
        raise HTTPException(status_code=404, detail="Model version not found")
    domain = session.exec(
        select(DbDomain).where(
            DbDomain.version_id == mv.id,
            DbDomain.name == domain_name,
        )
    ).first()
    if domain is None:
        raise HTTPException(status_code=404, detail="Domain not found")
    metrics = _nv_metrics.compute_metrics_for_domain(session, mv.id, domain.id)
    return _metrics_out(mv.id, domain.id, metrics)


def _load_evolution_metrics(
    session,
    ws,
    business_id: str,
    version_int: int,
    scope: str,
    *,
    model_fallback: dict | None = None,
) -> _evo_metrics.EvolutionMetrics:
    """Load + compute the version's evolution metrics off the Volume envelope.

    Canonical envelope-parse: pulls the agent's ``_vibe_session_metadata`` /
    top-level ``agent_version`` / inner ``model`` block out of the raw
    ``model.json`` envelope (the Lakebase sync drops the session metadata, so
    this reads the Volume artifact) and projects them via
    ``evolution_metrics.compute_metrics``. Shared by ``get_evolution_metrics``
    (the endpoint) and ``_assemble_report_data`` (the Excel export) so the two
    can't drift on envelope shape.

    When the envelope has no inner model block (import-only version), the size
    fallback comes from ``model_fallback`` if the caller already loaded the
    Lakebase-reconstructed structure, else from ``_load_model`` here (degrading
    to ``None`` if even that is unavailable).
    """
    envelope = _load_model_json_envelope(session, ws, business_id, version_int, scope)
    metadata = None
    agent_version = None
    model_block = None
    if isinstance(envelope, dict):
        metadata = envelope.get("_vibe_session_metadata")
        av = envelope.get("agent_version")
        agent_version = av if isinstance(av, str) and av else None
        inner = envelope.get("model")
        model_block = inner if isinstance(inner, dict) else envelope

    if model_block is None:
        if model_fallback is not None:
            model_block = model_fallback
        else:
            # No Volume artifact (e.g. import-only version). Fall back to the
            # Lakebase-reconstructed structure so the size block still degrades
            # to real counts rather than erroring.
            try:
                model_block = _load_model(session, ws, business_id, version_int, scope)
            except HTTPException:
                model_block = None

    return _evo_metrics.compute_metrics(
        metadata, model_block, agent_version=agent_version
    )


def _evolution_metrics_out(
    version_id: str,
    metrics: _evo_metrics.EvolutionMetrics,
    model_touched_pct: float | None = None,
    products_added: int | None = None,
    products_modified: int | None = None,
    products_removed: int | None = None,
    has_predecessor: bool | None = None,
) -> EvolutionMetricsOut:
    """Project the computed evolution-metrics dataclass onto the wire shape.

    ``model_touched_pct`` is the % of the model touched vs the predecessor
    (``None`` on a baseline), and ``products_added`` / ``products_modified`` /
    ``products_removed`` are the change-count breakdown behind it - all
    computed by the caller from the SAME ``_compute_diff`` the change icons
    use, reused and never recomputed.

    ``has_predecessor`` is the resolved predecessor flag (structural OR
    agent-reported - see ``get_evolution_metrics``). When ``None`` it falls
    back to the agent-metadata-only flag the projector computed; the endpoint
    always passes the resolved value so the FE's Change section reflects a real
    version N-1 even when the agent stamped no usable trend."""
    return EvolutionMetricsOut(
        version_id=version_id,
        size=EvolutionSizeOut(
            domain_count=metrics.size.domain_count,
            product_count=metrics.size.product_count,
            attribute_count=metrics.size.attribute_count,
            fk_count=metrics.size.fk_count,
            unlinked_id_count=metrics.size.unlinked_id_count,
            siloed_count=metrics.size.siloed_count,
            avg_attributes_per_product=metrics.size.avg_attributes_per_product,
        ),
        quality=EvolutionQualityOut(
            confidence_score=metrics.quality.confidence_score,
            error_count=metrics.quality.error_count,
            warning_count=metrics.quality.warning_count,
            info_count=metrics.quality.info_count,
            issues_addressed=metrics.quality.issues_addressed,
            issues_not_addressed=metrics.quality.issues_not_addressed,
        ),
        change=EvolutionChangeOut(
            version_trend=metrics.change.version_trend,
            model_touched_pct=model_touched_pct,
            products_added=products_added,
            products_modified=products_modified,
            products_removed=products_removed,
            confidence_delta=metrics.change.confidence_delta,
            warnings_delta=metrics.change.warnings_delta,
            errors_delta=metrics.change.errors_delta,
            unlinked_delta=metrics.change.unlinked_delta,
            previous_confidence=metrics.change.previous_confidence,
            previous_warnings=metrics.change.previous_warnings,
            previous_errors=metrics.change.previous_errors,
            previous_unlinked=metrics.change.previous_unlinked,
            version_history=[
                VersionHistoryEntryOut(
                    version=e.version,
                    confidence=e.confidence,
                    errors=e.errors,
                    warnings=e.warnings,
                    unlinked=e.unlinked,
                    trend=e.trend,
                    products=e.products,
                    fks=e.fks,
                )
                for e in metrics.change.version_history
            ],
        ),
        effort=EvolutionEffortOut(
            total_ai_calls=metrics.effort.total_ai_calls,
            estimated_input_tokens=metrics.effort.estimated_input_tokens,
            estimated_output_tokens=metrics.effort.estimated_output_tokens,
            estimated_total_cost_usd=metrics.effort.estimated_total_cost_usd,
            per_model_cost_usd=metrics.effort.per_model_cost_usd,
            duration_hours=metrics.effort.duration_hours,
        ),
        provenance=EvolutionProvenanceOut(
            agent_version=metrics.provenance.agent_version,
            generated_from_version=metrics.provenance.generated_from_version,
            target_model_version=metrics.provenance.target_model_version,
            status=metrics.provenance.status,
        ),
        has_metadata=metrics.has_metadata,
        has_confidence=metrics.has_confidence,
        has_predecessor=(
            has_predecessor if has_predecessor is not None else metrics.has_predecessor
        ),
    )


@router.get(
    "/businesses/{business_id}/versions/{version_int}/{scope}/evolution-metrics",
    response_model=EvolutionMetricsOut,
    operation_id="getEvolutionMetrics",
)
def get_evolution_metrics(
    business_id: str,
    version_int: int,
    scope: Annotated[str, PathParam(pattern="^(ecm|mvm)$")],
    session: Dependencies.Session,
    ws: Dependencies.Client,
):
    """Model-scope evolution metrics for a version (T16).

    Surfaces the size / quality / change / effort / provenance areas the agent
    stamps into the Volume ``model.json`` ``_vibe_session_metadata`` block - which the Lakebase sync drops, so this reads the raw Volume artifact on
    demand (no migration). The model structure is loaded as the size fallback
    for metadata-less imports.

    Degrades cleanly via data-driven flags: ``has_metadata=False`` for
    pre-metadata imports (size still structure-derived), ``has_confidence``
    ``False`` for ECM / unjudged runs (confidence null), ``has_predecessor``
    ``False`` on a baseline version (change deltas null, trend ``"baseline"``).
    """
    mv = resolve_model_version(session, business_id, version_int, scope)
    if mv is None:
        raise HTTPException(status_code=404, detail="Model version not found")

    # "% model touched" reuses the same per-product diff behind the change
    # icons. Load the structure best-effort: a version with no loadable model
    # (no Lakebase rows + no Volume artifact) degrades the touched % to null
    # rather than 404-ing the metrics endpoint.
    try:
        model = _load_model(session, ws, business_id, version_int, scope)
    except HTTPException:
        model = None
    prev_model = (
        _load_prev_model(session, ws, business_id, version_int, scope)
        if model is not None
        else None
    )
    metrics = _load_evolution_metrics(
        session, ws, business_id, version_int, scope, model_fallback=model
    )
    # A version has a predecessor when EITHER a real version N-1 exists for
    # this scope (structural diff is computable) OR the agent classified this
    # run against one. A base version is one with neither. The structural
    # signal is the reliable one: the agent's ``version_trend`` is "baseline"
    # / "unknown" for many real vibed exports (see evolution_metrics docstring),
    # which previously collapsed the whole Change feature on every v2.
    has_predecessor = (prev_model is not None) or metrics.has_predecessor
    touched_pct = None
    added = modified = removed = None
    if model is not None:
        diff = _compute_diff(prev_model, model)
        touched_pct = _model_touched_pct(model, diff, has_predecessor)
        if has_predecessor:
            added, modified, removed, _ = _change_breakdown(model, diff)
    return _evolution_metrics_out(
        mv.id,
        metrics,
        model_touched_pct=touched_pct,
        products_added=added,
        products_modified=modified,
        products_removed=removed,
        has_predecessor=has_predecessor,
    )


@router.get(
    "/businesses/{business_id}/versions/{version_int}/{scope}/domains/{domain_name}",
    response_model=DomainDetailOut,
    operation_id="getDomainDetail",
)
def get_domain_detail(
    business_id: str,
    version_int: int,
    scope: Annotated[str, PathParam(pattern="^(ecm|mvm)$")],
    domain_name: str,
    session: Dependencies.Session,
    ws: Dependencies.Client,
):
    """Return domain with products and change indicators vs previous version."""
    model = _load_model(session, ws, business_id, version_int, scope)
    prev_model = _load_prev_model(session, ws, business_id, version_int, scope)
    diff = _compute_diff(prev_model, model)

    domain = _find_domain(model, domain_name)
    if not domain:
        raise HTTPException(status_code=404, detail=f"Domain '{domain_name}' not found")

    dn = domain.get("name", "")
    product_list = sorted(
        [
            ProductSummaryOut(
                id=p.get("id", ""),
                fqn=product_fqn(dn, p.get("name", "")),
                name=p.get("name", ""),
                table_name=p.get("table_name", ""),
                description=p.get("description", ""),
                type=p.get("type", ""),
                data_type=p.get("data_type", ""),
                primary_key=p.get("primary_key", ""),
                subdomain=p.get("subdomain", ""),
                reference=p.get("reference", ""),
                attribute_count=len(p.get("attributes", [])),
                fk_count=count_fk_attributes(p.get("attributes", [])),
                fk_targets=sorted(_fk_target_keys(p.get("attributes", []))),
                change_status=diff["products"].get((dn, p.get("name", "")), ChangeStatus.UNCHANGED),
            )
            for p in domain.get("products", [])
        ],
        key=lambda p: p.name.lower(),
    )
    # Append deleted products from previous version
    product_list.extend(diff["deleted_products"].get(dn, []))

    return DomainDetailOut(
        name=dn,
        division=domain.get("division", ""),
        description=domain.get("description", ""),
        database_name=domain.get("database_name", ""),
        references=domain.get("references", ""),
        products=product_list,
    )


@router.get(
    "/businesses/{business_id}/versions/{version_int}/{scope}/domains/{domain_name}/products/{product_name}",
    response_model=ProductDetailOut,
    operation_id="getProductDetail",
)
def get_product_detail(
    business_id: str,
    version_int: int,
    scope: Annotated[str, PathParam(pattern="^(ecm|mvm)$")],
    domain_name: str,
    product_name: str,
    session: Dependencies.Session,
    ws: Dependencies.Client,
):
    """Return product/table with all attributes, PK/FK and change indicators."""
    model = _load_model(session, ws, business_id, version_int, scope)
    prev_model = _load_prev_model(session, ws, business_id, version_int, scope)
    diff = _compute_diff(prev_model, model)

    domain = _find_domain(model, domain_name)
    if not domain:
        raise HTTPException(status_code=404, detail=f"Domain '{domain_name}' not found")

    product = _find_product(domain, product_name)
    if not product:
        raise HTTPException(
            status_code=404,
            detail=f"Product '{product_name}' not found in domain '{domain_name}'",
        )

    pk = product.get("primary_key", "")
    pk_columns = {c.strip() for c in pk.split(",") if c.strip()} if pk else set()

    attributes = []
    for a in product.get("attributes", []):
        col_name = a.get("column_name", "") or a.get("name", "")
        attr_name = a.get("name", "")
        fk_to = a.get("foreign_key_to", "") or ""
        is_pk = col_name in pk_columns
        is_fk = is_fk_attribute(a)
        attributes.append(
            AttributeOut(
                id=a.get("id", ""),
                name=attr_name,
                column_name=col_name,
                type=a.get("type", ""),
                description=a.get("description", ""),
                business_glossary_term=a.get("business_glossary_term", ""),
                tags=a.get("tags", ""),
                value_regex=a.get("value_regex", ""),
                foreign_key_to=fk_to,
                references=a.get("references", ""),
                is_primary_key=is_pk,
                is_foreign_key=is_fk,
                change_status=diff["attributes"].get(
                    (domain_name, product_name, attr_name), ChangeStatus.UNCHANGED
                ),
            )
        )
    # Append deleted attributes from previous version
    attributes.extend(diff["deleted_attributes"].get((domain_name, product_name), []))

    # Sort: PKs first, then FKs, then deleted last, then the rest
    attributes.sort(key=lambda a: (
        a.change_status == ChangeStatus.DELETED,
        not a.is_primary_key,
        not a.is_foreign_key,
        a.name,
    ))

    return ProductDetailOut(
        id=product.get("id", ""),
        fqn=product_fqn(domain_name, product.get("name", "")),
        name=product.get("name", ""),
        table_name=product.get("table_name", ""),
        description=product.get("description", ""),
        type=product.get("type", ""),
        data_type=product.get("data_type", ""),
        primary_key=pk,
        reference=product.get("reference", ""),
        domain_name=domain_name,
        attributes=attributes,
    )


@router.get(
    "/businesses/{business_id}/versions/{version_int}/{scope}/relationships",
    response_model=RelationshipAnalysisOut,
    operation_id="getRelationshipAnalysis",
)
def get_relationship_analysis(
    business_id: str,
    version_int: int,
    scope: Annotated[str, PathParam(pattern="^(ecm|mvm)$")],
    session: Dependencies.Session,
    ws: Dependencies.Client,
):
    """Return FK statistics and domain connectivity for a model version."""
    model = _load_model(session, ws, business_id, version_int, scope)
    domains = model.get("domains", [])

    # Build a product→domain lookup
    product_domain: dict[str, str] = {}
    for d in domains:
        dn = d.get("name", "")
        for p in d.get("products", []):
            pn = p.get("name", "") or p.get("table_name", "")
            product_domain[pn] = dn

    total_fk = 0
    cross_domain = 0
    intra_domain = 0
    connectivity: dict[tuple[str, str], int] = {}

    for d in domains:
        dn = d.get("name", "")
        for p in d.get("products", []):
            for a in p.get("attributes", []):
                target = parse_fk_target(a.get("foreign_key_to", ""))
                if target is None:
                    continue
                total_fk += 1

                # ``parts[0]`` (the parsed domain for a 3-part target, else the
                # table) is the target domain only if it names a real domain;
                # otherwise treat it as a table and look up its owning domain.
                head = target.domain if target.domain is not None else target.table
                if head in {dd.get("name", "") for dd in domains}:
                    target_domain = head
                else:
                    target_domain = product_domain.get(head, dn)

                if target_domain == dn:
                    intra_domain += 1
                else:
                    cross_domain += 1
                    pair = tuple(sorted([dn, target_domain]))
                    connectivity[pair] = connectivity.get(pair, 0) + 1

    # Sort by FK count descending, take top 15
    top_connectivity = sorted(connectivity.items(), key=lambda x: -x[1])[:15]

    return RelationshipAnalysisOut(
        total_fk_count=total_fk,
        cross_domain_fk_count=cross_domain,
        intra_domain_fk_count=intra_domain,
        domain_connectivity=[
            DomainConnectivityOut(
                source_domain=pair[0], target_domain=pair[1], fk_count=count
            )
            for pair, count in top_connectivity
        ],
    )


# ---------------------------------------------------------------------------
# Statistics report Excel export (T15)
# ---------------------------------------------------------------------------


def _focus_score(
    review_needed: int,
    reviewed: int,
    open_inputs: int,
    change_pct: float | None,
    has_predecessor: bool,
) -> float:
    """Composite 0..100 triage rank blending the three signals the design names.

    Higher = more attention. ``review_gap`` (fraction of review-needed products
    still unreviewed), ``quality`` (open next_vibes inputs, saturating at 10),
    and ``change`` (percent of the domain touched; dropped on a base version
    where there is no predecessor to diff). Equal-weighted across the available
    signals so a single one can't dominate - the prototype authored this; here
    it is computed from normalized signals.
    """
    signals: list[float] = []
    if review_needed > 0:
        signals.append(1.0 - (reviewed / review_needed))
    signals.append(min(open_inputs, 10) / 10.0)
    if has_predecessor and change_pct is not None:
        signals.append(min(change_pct, 100.0) / 100.0)
    if not signals:
        return 0.0
    return round(100.0 * sum(signals) / len(signals), 1)


def _focus_reason(
    review_pct: float | None, open_inputs: int, change_label: str
) -> str:
    """One-line muted reason mirroring the design's example phrasing."""
    parts: list[str] = []
    if open_inputs > 0:
        parts.append(f"{open_inputs} inputs open")
    if review_pct is not None:
        parts.append(f"{round(review_pct)}% reviewed")
    if change_label and change_label != "unchanged":
        parts.append(f"{change_label}")
    return " · ".join(parts)


def _domain_change(
    domain_name: str,
    model: dict,
    diff: dict,
    has_predecessor: bool,
) -> tuple[float | None, str]:
    """Per-domain change: (percent of the domain's products touched, label).

    ``None`` percent on a base version. The label is ``new`` for a NEW domain,
    ``changed`` for a MODIFIED one, else ``unchanged``. The percent is the
    share of the domain's products with a NEW/MODIFIED status in the diff.
    """
    if not has_predecessor:
        return None, ""
    domain = _find_domain(model, domain_name) or {}
    products = domain.get("products", []) or []
    domain_status = diff["domains"].get(domain_name, ChangeStatus.UNCHANGED)
    label = (
        "new"
        if domain_status == ChangeStatus.NEW
        else "changed"
        if domain_status == ChangeStatus.MODIFIED
        else "unchanged"
    )
    if not products:
        return (0.0, label)
    touched = sum(
        1
        for p in products
        if diff["products"].get((domain_name, p.get("name", "")), ChangeStatus.UNCHANGED)
        != ChangeStatus.UNCHANGED
    )
    return (100.0 * touched / len(products), label)


def _assemble_report_data(
    session, ws, business_id: str, version_int: int, scope: str
) -> _report_export.ReportData:
    """Build the export DTO from the SAME readers the live Statistics surfaces
    use - review progress, next_vibes metrics, evolution metrics, domains - so the workbook can't drift from the on-screen report."""
    mv = resolve_model_version(session, business_id, version_int, scope)
    if mv is None:
        raise HTTPException(status_code=404, detail="Model version not found")

    model = _load_model(session, ws, business_id, version_int, scope)
    prev_model = _load_prev_model(session, ws, business_id, version_int, scope)
    diff = _compute_diff(prev_model, model)
    has_pred = prev_model is not None

    # Evolution metrics (size / quality / change / confidence) off the Volume
    # envelope, with its own degradation flags (ECM → no confidence, baseline →
    # no predecessor). Shares the canonical envelope-parse with
    # ``get_evolution_metrics`` so the export can't drift; the already-loaded
    # ``model`` is the size fallback for import-only versions.
    evo = _load_evolution_metrics(
        session, ws, business_id, version_int, scope, model_fallback=model
    )

    # A version has a predecessor when EITHER a real version N-1 exists
    # (structural diff is computable) OR the agent classified this run against
    # one; a base version is one with neither. Mirrors ``get_evolution_metrics``
    # - the structural signal is authoritative because the agent's
    # ``version_trend`` is unreliable on many real exports.
    has_predecessor = has_pred or evo.has_predecessor

    # Model-scope review + next_vibes.
    pct, reviewed, review_needed, no_review_needed = _review.compute_progress(
        session, mv.id, diff["products"], has_pred
    )
    nv = _nv_metrics.compute_metrics(session, mv.id)

    # Per-domain rollups: review split (by domain id) + next_vibes (by domain).
    review_by_domain = _review.compute_progress_by_domain(
        session, mv.id, diff["products"], has_pred
    )
    domain_rows = session.exec(
        select(DbDomain).where(DbDomain.version_id == mv.id)
    ).all()
    id_by_name = {d.name: d.id for d in domain_rows}

    domains: list[_report_export.DomainReport] = []
    for d in model.get("domains", []):
        dn = d.get("name", "")
        if not dn:
            continue
        did = id_by_name.get(dn)
        d_pct, d_reviewed, d_needed, d_no_need = (
            review_by_domain.get(did, (0.0, 0, 0, 0)) if did else (0.0, 0, 0, 0)
        )
        d_nv = (
            _nv_metrics.compute_metrics_for_domain(session, mv.id, did)
            if did
            else _nv_metrics.NextVibeMetrics()
        )
        change_pct, change_label = _domain_change(dn, model, diff, has_predecessor)
        d_review_pct = (100.0 * d_reviewed / d_needed) if d_needed else None
        domains.append(
            _report_export.DomainReport(
                name=dn,
                product_count=len(d.get("products", []) or []),
                reviewed=d_reviewed,
                review_needed=d_needed,
                no_review_needed=d_no_need,
                open_inputs=d_nv.total_open,
                quality_score=d_nv.quality_score,
                change_pct=change_pct,
                change_label=change_label,
                focus_score=_focus_score(
                    d_needed, d_reviewed, d_nv.total_open, change_pct, has_predecessor
                ),
                reason=_focus_reason(d_review_pct, d_nv.total_open, change_label),
            )
        )

    size = evo.size
    business = session.get(Business, business_id)
    return _report_export.ReportData(
        model_name=model.get("name", "") or (business.name if business else ""),
        model_version=model.get("version", "") or f"v{version_int}",
        scope=scope,
        generated_at=datetime.now(timezone.utc).strftime("%Y-%m-%d %H:%M UTC"),
        domain_count=size.domain_count or len(model.get("domains", []) or []),
        product_count=size.product_count
        or sum(len(d.get("products", []) or []) for d in model.get("domains", []) or []),
        attribute_count=size.attribute_count or 0,
        fk_count=size.fk_count or 0,
        reviewed=reviewed,
        review_needed=review_needed,
        no_review_needed=no_review_needed,
        confidence_score=evo.quality.confidence_score,
        quality_score=nv.quality_score,
        open_inputs=nv.total_open,
        error_count=evo.quality.error_count,
        warning_count=evo.quality.warning_count,
        has_confidence=evo.has_confidence,
        has_predecessor=has_predecessor,
        change_pct=_model_touched_pct(model, diff, has_predecessor),
        domains=domains,
    )


def _change_breakdown(model: dict, diff: dict) -> tuple[int, int, int, int]:
    """Per-version product change counts from the canonical ``_compute_diff``.

    Returns ``(added, modified, removed, current_product_count)``:
      * ``added`` - products with ``ChangeStatus.NEW`` in ``diff["products"]``
      * ``modified`` - products with ``ChangeStatus.MODIFIED``
      * ``removed`` - products across every per-domain list in
        ``diff["deleted_products"]``
      * ``current_product_count`` - products in the current model

    Reuses the existing diff; never recomputes it."""
    status = diff.get("products", {})
    added = sum(1 for s in status.values() if s == ChangeStatus.NEW)
    modified = sum(1 for s in status.values() if s == ChangeStatus.MODIFIED)
    removed = sum(len(v) for v in diff.get("deleted_products", {}).values())
    current_product_count = sum(
        len(d.get("products", []) or []) for d in model.get("domains", []) or []
    )
    return added, modified, removed, current_product_count


def _model_touched_pct(model: dict, diff: dict, has_predecessor: bool) -> float | None:
    """Percent of the model touched this version, bounded to 0..100.

    Normalized by the UNION of both versions so a deletion-only version reads
    above 0 and a heavy-deletion version never exceeds 100::

        touched = added + modified + removed
        denom   = current_product_count + removed   (= |prev ∪ current|)
        pct     = round(100 * touched / denom)

    ``None`` on a base version (no predecessor to diff against) or when the
    union is empty."""
    if not has_predecessor:
        return None
    added, modified, removed, current = _change_breakdown(model, diff)
    denom = current + removed
    if denom == 0:
        return None
    touched = added + modified + removed
    return float(round(100 * touched / denom))


@router.get(
    "/businesses/{business_id}/versions/{version_int}/{scope}/statistics-report.xlsx",
    operation_id="getStatisticsReportXlsx",
)
def get_statistics_report_xlsx(
    business_id: str,
    version_int: int,
    scope: Annotated[str, PathParam(pattern="^(ecm|mvm)$")],
    session: Dependencies.Session,
    ws: Dependencies.Client,
):
    """Download the Statistics report for a version as an ``.xlsx`` workbook (T15).

    Assembles the report from the live readers (review progress, next_vibes
    metrics, evolution metrics, domains) and renders it via
    ``report_export.build_report_workbook`` - native recomputing charts, a
    hidden Data sheet, a Where-to-focus ranked table with autofilter + data
    bars + per-row drill hyperlinks, and one tab per domain. Baseline / ECM
    measures degrade to ``"n/a"`` with their chart omitted."""
    report = _assemble_report_data(session, ws, business_id, version_int, scope)
    body = _report_export.build_report_workbook(report)
    filename = f"statistics-report-v{version_int}-{scope}.xlsx"
    return StreamingResponse(
        iter([body]),
        media_type="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
        headers={"Content-Disposition": f'attachment; filename="{filename}"'},
    )
