"""Top-level import routes (no business prefix).

These power Story 1 — create-business-by-importing — where the user
picks a model.json off Volumes and the server creates the Business +
the first ModelVersion in a single round-trip.

Story 2 (import-into-existing-business) keeps living under
``/businesses/{id}/import/*`` in ``businesses.py``: the per-business
prefix makes sense when the business already exists and the import is
"just another version".
"""

from __future__ import annotations

import json
import logging
from datetime import datetime, timezone
from typing import Optional

from fastapi import APIRouter, HTTPException, Request
from sqlmodel import Session, select

from ..._metadata import api_prefix
from ..agent_compat import (
    extract_version_provenance,
    extract_vibe_scope_facts,
    gate_model_json,
    latest_supported_tag,
)
from .._query_helpers import (
    BusinessNameConflict,
    ensure_business_name_available,
    resolve_model_json_parent,
)
from ..core import Dependencies, resolve_import_registry_catalog
from ..core._warehouse import get_warehouse_id
from ..db_models import (
    Business,
    BusinessContext,
    Industry,
    ModelVersion,
)
from ..import_model import detect_schema, read_model_json_from_volume
from ..industry_resolve import (
    industry_ambiguous_detail,
    industry_candidates,
    industry_slug,
    resolve_industry,
)
from ..model_sync import (
    NEXT_VIBES_JSON_RELATIVE_PATHS,
    NEXT_VIBES_TXT_RELATIVE_PATHS,
)
from ..models import (
    ArtifactPreview,
    BusinessDigest,
    ImportAnalyzeIn,
    ImportAnalyzeOut,
    ImportCreateBusinessAndExecuteIn,
    ImportCreateBusinessAndExecuteOut,
    ImportPreviewOut,
)
from ..run_link import link_after_import
from ..services.artifact_indexer import (
    infer_artifact_type,
    walk_volume_dir_with_size,
)
from ..services.business_digest import extract_business_digest
from ..services.metamodel_registry import ensure_metamodel_or_refuse
from ..services.dialog_import import (
    ImportCopyFailed,
    analysis_fields,
    copy_import_files,
    finish_dialog_import,
    prepare_dialog_import,
    resolve_scope,
    sync_prepared,
    undo_import,
    version_fields,
)

logger = logging.getLogger(__name__)

router = APIRouter(prefix=api_prefix)


def _infer_lineage_parent_id(
    session: Session,
    business_id: str,
    scope: str,
    new_version_num: int,
) -> Optional[str]:
    """Heuristic: assume the imported version was vibed from ``version - 1``.

    Used when the explicit ``generated_from_version`` tag in the model.json
    didn't resolve (the agent currently stamps it with the OUTPUT label,
    not a parent pointer). When ``new_version_num > 1`` and a same-scope
    version with ``version = new_version_num - 1`` already exists for this
    business, link to it as the parent — that matches the dominant
    vibe-progression case (v1 → v2 → v3).

    Returns the parent's ``id`` or ``None`` when no suitable predecessor
    exists.
    """
    if new_version_num <= 1 or not scope:
        return None
    from .._query_helpers import resolve_model_version
    parent = resolve_model_version(session, business_id, new_version_num - 1, scope)
    return parent.id if parent is not None else None


def _with_resolved_industry(session: Session, digest: BusinessDigest) -> BusinessDigest:
    """Stamp the catalog industry the digest's ``industry_alignment`` resolves
    to, so the import dialog starts from the backend's match."""
    industry = resolve_industry(session, digest.industry_alignment)
    return digest.model_copy(update={"industry_id": industry.id if industry else None})


@router.post(
    "/import/analyze",
    response_model=ImportAnalyzeOut,
    operation_id="analyzeImportRoot",
)
def analyze_import_root(
    data: ImportAnalyzeIn,
    session: Dependencies.Session,
    ws: Dependencies.Client,
):
    """Analyze a model.json before creating a Business from it.

    Mirror of the per-business analyze endpoint but operates on a raw
    Volume path with no target Business. Returns the same envelope,
    plus a populated ``business_digest`` so the UI can pre-fill the
    confirmation form. ``business_digest_diff`` is always None on this
    path — there's no target business to diff against.
    """
    try:
        model_json = read_model_json_from_volume(ws, data.volume_path)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))

    analysis = detect_schema(model_json)
    from ..core._defaults import SUPPORTED_AGENT_VERSION
    gate = gate_model_json(model_json, fallback=SUPPORTED_AGENT_VERSION if analysis.valid else None)
    detected_tag = gate.tag
    warnings = list(analysis.warnings)
    if analysis.valid and gate.refused:
        warnings.append(gate.refusal_message)
    elif analysis.valid and gate.needs_adapter:
        warnings.append(gate.adapter_warning)

    digest = extract_business_digest(model_json) if analysis.valid else None
    if digest is not None:
        digest = _with_resolved_industry(session, digest)

    return ImportAnalyzeOut(
        valid=analysis.valid,
        inferred_version=analysis.inferred_version,
        action=analysis.action,
        message=analysis.message,
        domain_count=analysis.domain_count,
        product_count=analysis.product_count,
        attribute_count=analysis.attribute_count,
        fk_count=analysis.fk_count,
        warnings=warnings,
        detected_agent_tag=detected_tag,
        compat_verdict=gate.verdict,
        latest_supported_tag=latest_supported_tag(),
        business_digest=digest,
        business_digest_diff=None,
        **(analysis_fields(model_json, data.volume_path) if analysis.valid else {}),
    )


@router.get(
    "/import/preview",
    response_model=ImportPreviewOut,
    operation_id="getImportPreview",
)
def get_import_preview(
    volume_path: str,
    ws: Dependencies.Client,
):
    """Preview what an import will pull in BEFORE executing.

    Walks ``volume_path`` (the folder containing ``model.json`` — or the
    ``model.json`` path itself; we strip the trailing filename) and
    reports model.json presence, the next-vibes lookup status, and the
    typed companion artifacts. Read-only — no Lakebase writes.

    ``next_vibes_status`` mirrors :func:`load_next_vibes_from_root`'s
    priority order: ``"json"`` if any of the .json candidates resolves,
    ``"txt"`` if only a .txt does, ``"missing"`` otherwise. The UI
    surfaces a warning banner on ``"missing"`` so the user knows the
    agent's next-iteration suggestions cannot be reconstructed.
    """
    if not volume_path:
        raise HTTPException(status_code=400, detail="volume_path is required")
    # Accept either the model.json file path or the parent folder. We
    # always probe the parent — companion artifacts (vibes/, docs/,
    # diagram/, …) live as siblings of model.json.
    if volume_path.endswith("/model.json"):
        root = volume_path[: -len("/model.json")]
    else:
        root = volume_path.rstrip("/")

    files_with_size = walk_volume_dir_with_size(ws, root)

    model_json_found = False
    next_vibes_status = "missing"
    next_vibes_path: Optional[str] = None
    artifacts: list[ArtifactPreview] = []
    json_priority = tuple(f"{root}/{rel}" for rel in NEXT_VIBES_JSON_RELATIVE_PATHS)
    txt_priority = tuple(f"{root}/{rel}" for rel in NEXT_VIBES_TXT_RELATIVE_PATHS)
    by_path: dict[str, Optional[int]] = {p: s for p, s in files_with_size}
    for candidate in json_priority:
        if candidate in by_path:
            next_vibes_status = "json"
            next_vibes_path = candidate
            break
    if next_vibes_status == "missing":
        for candidate in txt_priority:
            if candidate in by_path:
                next_vibes_status = "txt"
                next_vibes_path = candidate
                break

    # The next-vibes file is reported separately via ``next_vibes_status``
    # / ``next_vibes_path``. Skip it in the companion list so the UI
    # doesn't double-count it.
    next_vibes_paths = set(json_priority) | set(txt_priority)

    for path, size in files_with_size:
        atype = infer_artifact_type(path, root=root)
        if atype == "model_json":
            model_json_found = True
            continue
        if path in next_vibes_paths:
            continue
        artifacts.append(
            ArtifactPreview(path=path, artifact_type=atype, size_bytes=size),
        )

    # Stable ordering for the UI: by type then path.
    artifacts.sort(key=lambda a: (a.artifact_type, a.path))

    return ImportPreviewOut(
        model_json_found=model_json_found,
        next_vibes_status=next_vibes_status,
        next_vibes_path=next_vibes_path,
        companion_artifacts=artifacts,
        total_artifact_count=len(artifacts),
    )


@router.post(
    "/import/create-business-and-execute",
    response_model=ImportCreateBusinessAndExecuteOut,
    operation_id="createBusinessAndExecuteImport",
)
def create_business_and_execute_import(
    request: Request,
    data: ImportCreateBusinessAndExecuteIn,
    session: Dependencies.Session,
    ws: Dependencies.Client,
    config: Dependencies.Config,
    _role: Dependencies.BusinessAdminOnly,
):
    """Create a Business from a model.json's business identity, then import.

    Story-1 entry point. Every check runs before the first write
    (``services/dialog_import.prepare_dialog_import``). The industry (when
    ``create_industry`` adds one), the business, its version and the Lakebase
    sync commit together before the Volume copy; a failed copy deletes all of
    them (``undo_import``).

    Conflict semantics: if a Business with the same (case-insensitive)
    name already exists, returns 409 pointing the user at the existing
    business and Story 2. Auto-using the existing business would be a
    silent overwrite — the user picked "create new" deliberately.
    """
    from ._helpers import require_config

    # Hard-fail before creating the business when config is missing: a business
    # imported without a metamodel catalog can't be seeded or iterated.
    require_config(session, config, ["metamodel_catalog", "warehouse"], mode="raise")

    try:
        model_json = read_model_json_from_volume(ws, data.volume_path)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))

    analysis = detect_schema(model_json)
    if not analysis.valid:
        raise HTTPException(status_code=400, detail=analysis.message)

    digest = extract_business_digest(model_json)
    if digest is None:
        raise HTTPException(
            status_code=400,
            detail=(
                "model.json carries no business name. Create the business "
                "manually first and use the per-business import endpoint."
            ),
        )

    # Override resolution: explicit override > digest > error.
    business_name = (
        (data.business_name_override or "").strip()
        or digest.business_name
    )
    if not business_name:
        raise HTTPException(
            status_code=400, detail="business_name is required",
        )
    industry_alignment = (
        data.industry_alignment_override
        if data.industry_alignment_override is not None
        else digest.industry_alignment
    ).strip()
    description = (
        data.description_override
        if data.description_override is not None
        else digest.description
    ).strip()
    business_vibes = (
        data.business_vibes_override
        if data.business_vibes_override is not None
        else digest.business_vibes
    ).strip()
    if not description:
        raise HTTPException(
            status_code=400,
            detail=(
                "description is required — provide an override or import "
                "a model.json that carries a business description."
            ),
        )

    # Skip-if-exists: 409 with a hint, not silent reuse. Sanitization-aware
    # (agent_business_segment): a name that normalizes to an existing
    # business/industry is rejected even without a raw-name clash. The import
    # dialog reads the ``business_already_exists`` detail (business_id +
    # business_name) to offer the per-business import, so that shape is kept.
    try:
        ensure_business_name_available(session, business_name)
    except BusinessNameConflict as exc:
        existing = exc.existing
        raise HTTPException(
            status_code=409,
            detail={
                "error": "business_already_exists",
                "business_id": existing.id,
                "business_name": existing.name,
                "message": (
                    f"A business named '{existing.name}' already exists. "
                    f"Use the per-business import to add this model.json "
                    f"as a new version, or rename the business first."
                ),
            },
        ) from exc

    from ..core._defaults import SUPPORTED_AGENT_VERSION
    gate = gate_model_json(model_json, fallback=SUPPORTED_AGENT_VERSION)
    detected_tag = gate.tag
    exec_warnings = list(analysis.warnings)
    if gate.refused:
        raise HTTPException(status_code=422, detail=gate.refusal_detail())
    if gate.needs_adapter:
        logger.warning("create_business_and_execute_import: %s", gate.adapter_warning)
        exec_warnings.append(gate.adapter_warning)

    # ECM or MVM, and the app's folder for the new business's v1 of that
    # scope, checked before the industry, the business or the version is
    # written. A new business has no versions, so this is its v1.
    scope = resolve_scope(model_json, data.volume_path, data.scope)
    new_version_num = 1
    catalog = resolve_import_registry_catalog(session)
    prepared = prepare_dialog_import(
        ws,
        model_json=model_json,
        volume_path=data.volume_path,
        scope=scope,
        version=new_version_num,
        catalog=catalog,
        business_name=business_name,
        databricks_run_id=data.databricks_run_id,
    )

    # The dialog's pick (``industry_id``) wins; otherwise the alignment
    # resolves. No match leaves the business without an industry. An industry
    # is added only when the dialog asks (``create_industry``) and no active
    # industry shares the alignment's slug: an ambiguous slug is the user's
    # pick to make, never a reason for another row.
    if data.industry_id:
        industry = session.get(Industry, data.industry_id)
        if industry is None or not industry.is_active:
            raise HTTPException(
                status_code=404,
                detail={
                    "error": "industry_not_found",
                    "industry_id": data.industry_id,
                    "message": "The selected industry is no longer in the catalog. Pick another one.",
                },
            )
    else:
        industry = resolve_industry(session, industry_alignment)
    created_industry_id: Optional[str] = None
    if industry is None and data.create_industry:
        short_name = industry_slug(industry_alignment)
        if not short_name:
            raise HTTPException(
                status_code=400,
                detail=f"'{industry_alignment}' cannot name an industry: it has no letters or digits.",
            )
        candidates = industry_candidates(session, industry_alignment)
        if candidates:
            raise HTTPException(status_code=409, detail=industry_ambiguous_detail(industry_alignment, candidates))
        industry = Industry(name=industry_alignment, short_name=short_name, description="")
        session.add(industry)
        session.flush()
        created_industry_id = industry.id
        exec_warnings.append(f"Added industry '{industry_alignment}' to the catalog.")
    industry_id = industry.id if industry is not None else None

    # Every refusal is behind us: the app's folder needs its _metamodel schema
    # and vol_root volume, which a catalog the agent never ran in lacks.
    ensure_metamodel_or_refuse(ws, catalog)

    # Create the Business. Single transaction with the ModelVersion +
    # sync below — failures roll back both.
    business = Business(
        name=business_name,
        description=description,
        business_vibes=business_vibes,
        industry_alignment=industry_alignment,
        industry_id=industry_id,
    )
    session.add(business)
    session.flush()

    # Seed BusinessContext from the digest. Mirrors what
    # ``businesses.create_business`` writes on the manual-create path so
    # the Explorer's context section has something before the first
    # vibe run. The model_sync that runs below will overlay the
    # business_context block carried in model.json's inner ``model``
    # dict (via the existing pipeline), but we still want a deterministic
    # seed row so context history isn't empty.
    seed_ctx = {
        "business_context": {
            "business_information": {
                "business": business_name,
                "industry_alignment": industry_alignment,
                "description": description,
            },
            "core_business_processes": digest.core_business_processes,
            "orgnaization_divisions": digest.orgnaization_divisions,
            "common_business_jargons": digest.common_business_jargons,
            "operational_systems_of_records": digest.operational_systems_of_records,
            "industry_governing_body": digest.industry_governing_body,
        }
    }
    session.add(BusinessContext(
        business_id=business.id,
        version_label="seed",
        context_json=json.dumps(seed_ctx),
        conventions_json="{}",
        is_active=True,
    ))

    # Lineage: the parent the model.json names (the 5.3.3 ``lineage`` block,
    # else the ``generated_from_version`` tag) when it exists; else the
    # heuristic "parent = (same scope, version - 1)".
    parent = resolve_model_json_parent(session, business.id, model_json)
    lineage_parent_id = parent.id if parent is not None else None
    if lineage_parent_id is None:
        lineage_parent_id = _infer_lineage_parent_id(
            session, business.id, scope, new_version_num,
        )

    # Version provenance from the model.json envelope. Read from the outer
    # ``model_json`` — ``analysis._model`` is the already-unwrapped inner model
    # and no longer carries the top-level agent_version / release_version keys.
    agent_version, release_version = extract_version_provenance(model_json)
    fence_mode, fence_base_version, fence_base_scope = extract_vibe_scope_facts(model_json)

    now_ts = datetime.now(timezone.utc)
    mv = ModelVersion(
        business_id=business.id,
        status="completed",
        deployment_status="draft",
        base_version_id=lineage_parent_id,
        completion_date=now_ts,
        imported_at=now_ts,
        agent_version=agent_version,
        release_version=release_version,
        scope_fence_mode=fence_mode,
        scope_base_version=fence_base_version,
        scope_base_scope=fence_base_scope,
        files_catalog=catalog,
        **version_fields(prepared, volume_path=data.volume_path),
    )
    session.add(mv)
    session.flush()
    sync_prepared(session, mv.id, prepared)
    # Lakebase durable before the Volume copy and the external _metamodel
    # write, neither of which holds a transaction.
    session.commit()

    business_id = business.id

    def _delete_business(s: Session) -> None:
        for ctx in s.exec(select(BusinessContext).where(BusinessContext.business_id == business_id)).all():
            s.delete(ctx)
        created = s.get(Business, business_id)
        if created is not None:
            s.delete(created)
        s.flush()
        added = s.get(Industry, created_industry_id) if created_industry_id else None
        if added is not None:
            s.delete(added)

    try:
        copy_import_files(ws, prepared)
    except ImportCopyFailed as exc:
        undo_import(session, ws, prepared, mv.id, also_delete=_delete_business)
        raise HTTPException(status_code=exc.status, detail=str(exc)) from exc

    exec_warnings.extend(finish_dialog_import(
        ws, session, prepared,
        version_id=mv.id,
        business_id=business.id,
        business_name=business.name,
        catalog=catalog,
        warehouse_id=get_warehouse_id(session),
        log_prefix="create_business_and_execute_import",
    ))

    linked_run_id = None
    if data.databricks_run_id is not None:
        linked_run_id, link_warning = link_after_import(session, ws, business, mv, data.databricks_run_id)
        if link_warning:
            exec_warnings.append(link_warning)

    # Post-import diagram pre-compute. Best-effort.
    try:
        from ..diagram import (
            _invalidate_business_layouts,
            queue_layout_prefetch_for_version,
        )

        _invalidate_business_layouts(session, business.id, mv.id)
        # expire_on_commit=False: this factory feeds the same background ELK
        # prefetch worker (_background_compute) as the diagram route's own
        # session_factory - see diagram.py's get_diagram_layout for why.
        post_import_session_factory = lambda: Session(
            bind=request.app.state.engine, expire_on_commit=False,
        )
        queue_layout_prefetch_for_version(
            session, post_import_session_factory, ws,
            business_id=business.id,
            version_int=new_version_num,
            scope=scope,
        )
    except Exception:
        logger.exception(
            "Failed to queue post-import pre-computes (non-fatal)"
        )

    # Count what was inserted.
    from ..db_models import (
        Attribute as DbAttr,
        Domain as DbDomain,
        ForeignKeyLink,
        Product as DbProduct,
    )
    domains = session.exec(select(DbDomain).where(DbDomain.version_id == mv.id)).all()
    products = session.exec(select(DbProduct).where(DbProduct.version_id == mv.id)).all()
    attr_count = sum(
        1 for p in products
        for _ in session.exec(select(DbAttr).where(DbAttr.product_id == p.id)).all()
    )
    fks = session.exec(
        select(ForeignKeyLink).where(ForeignKeyLink.version_id == mv.id)
    ).all()

    return ImportCreateBusinessAndExecuteOut(
        business_id=business.id,
        version_id=mv.id,
        version=new_version_num,
        domains=len(domains),
        products=len(products),
        attributes=attr_count,
        fk_links=len(fks),
        warnings=exec_warnings,
        detected_agent_tag=detected_tag,
        compat_verdict=gate.verdict,
        latest_supported_tag=latest_supported_tag(),
        linked_run_id=linked_run_id,
    )
