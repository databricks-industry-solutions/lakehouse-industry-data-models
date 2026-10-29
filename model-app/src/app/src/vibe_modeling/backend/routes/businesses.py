"""Business CRUD + business-context + model-import endpoints (`/api/businesses/*`).

Covers the resource lifecycle for the `Business` table itself, the
business-context history we keep alongside it, and the
`/businesses/{id}/import/{analyze,execute}` flow that imports a model.json
from Volumes as a new ModelVersion. Model-version *versions* are split off
into `versions.py` since the read side is large.
"""

from __future__ import annotations

import json
import logging
from datetime import datetime, timezone
from typing import Optional

from fastapi import APIRouter, HTTPException, Request
from sqlalchemy.exc import IntegrityError
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
    next_version_for_scope,
    resolve_model_json_parent,
)
from ..core import Dependencies, resolve_import_registry_catalog
from ..core._runs import lock_business_for_write
from ..core._warehouse import get_warehouse_id
from ..db_models import (
    Business,
    BusinessContext,
    ModelVersion,
    Run,
    Sector,
)
from ..import_model import detect_schema, read_model_json_from_volume
from ..industry_resolve import resolve_industry_id
from ..models import (
    BusinessContextIn,
    BusinessContextOut,
    BusinessDeleteOut,
    BusinessDigestDiff,
    BusinessIn,
    BusinessKind,
    BusinessListOut,
    BusinessOut,
    ImportAnalyzeIn,
    ImportAnalyzeOut,
    ImportExecuteIn,
    ImportExecuteOut,
    MetamodelCleanupSummaryOut,
)
from ..run_link import link_after_import
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
from ..services.business_digest import (
    diff_business_digest,
    extract_business_digest,
)
from ..services.operations._version_lifecycle import (
    VersionDeleteRefused,
    delete_business as delete_business_rows,
)
from ._helpers import business_name_taken_error, resolve_warehouse_id

logger = logging.getLogger(__name__)

router = APIRouter(prefix=api_prefix)


def _validate_sector_id(session: Session, sector_id: Optional[str]) -> None:
    """Reject a non-existent ``sector_id`` with a structured 404.

    ``sector_id`` is a FK into ``sectors.id`` (ADR D-047). A ``None``/blank id
    is the normal "no sector picked" state and is allowed through. A
    non-empty id that matches no Sector row is a dangling reference — fail
    loudly so the create/update path never persists it silently.
    """
    if not sector_id:
        return
    if session.get(Sector, sector_id) is None:
        raise HTTPException(
            status_code=404,
            detail={
                "error": "sector_not_found",
                "sector_id": sector_id,
                "message": f"No sector exists with id '{sector_id}'.",
            },
        )


# --- Businesses ---


@router.get(
    "/businesses",
    response_model=list[BusinessListOut],
    operation_id="listBusinesses",
)
def list_businesses(
    session: Dependencies.Session,
    kind: Optional[BusinessKind] = None,
):
    statement = select(Business)
    if kind is not None:
        statement = statement.where(Business.kind == kind)
    businesses = session.exec(statement.order_by(Business.name)).all()
    return [
        BusinessListOut(
            id=b.id, name=b.name,
            industry_alignment=b.industry_alignment,
            kind=b.kind,
            sector_id=b.sector_id,
            source_industry_id=b.source_industry_id,
            source_version=b.source_version,
            model_count=len(b.versions),
            downloaded_scopes=sorted({v.scope for v in b.versions if v.scope}),
            created_at=b.created_at,
        )
        for b in businesses
    ]


@router.get(
    "/businesses/{business_id}",
    response_model=BusinessOut,
    operation_id="getBusiness",
)
def get_business(business_id: str, session: Dependencies.Session):
    business = session.get(Business, business_id)
    if not business:
        raise HTTPException(status_code=404, detail="Business not found")
    return business


@router.post(
    "/businesses",
    response_model=BusinessOut,
    operation_id="createBusiness",
)
def create_business(
    data: BusinessIn,
    session: Dependencies.Session,
    _role: Dependencies.BusinessAdminOnly,
):
    try:
        ensure_business_name_available(session, data.name)
    except BusinessNameConflict as exc:
        raise business_name_taken_error(data.name, str(exc)) from exc
    _validate_sector_id(session, data.sector_id)
    business = Business(
        name=data.name,
        description=data.description,
        business_vibes=data.business_vibes,
        industry_alignment=data.industry_alignment,
        industry_id=resolve_industry_id(session, data.industry_alignment),
        kind=data.kind,
        sector_id=data.sector_id,
        business_domains=data.business_domains,
        org_divisions=data.org_divisions,
    )
    session.add(business)
    try:
        session.flush()
    except IntegrityError as exc:
        # Usually a concurrent create that took the name between the check
        # above and this insert (``businesses.name`` is unique). Read the
        # state again; any other integrity failure (a sector deleted since
        # the validation) is not a name clash.
        session.rollback()
        try:
            ensure_business_name_available(session, data.name)
        except BusinessNameConflict as conflict:
            raise business_name_taken_error(data.name, str(conflict)) from exc
        raise

    # Seed a BusinessContext row from the create-time fields so the Explorer
    # context section has something to show before the first vibe run. The
    # agent overwrites this on the first run's sync via model.json's
    # `business_context` block; seeding it here avoids the empty-context
    # surprise on a brand-new business page. The business and its seed commit
    # together: a failed seed leaves no business behind to clash with the retry.
    seed_ctx = {
        "business_context": {
            "business_information": {
                "business": data.name,
                "industry_alignment": data.industry_alignment or "",
                "description": data.description or "",
            }
        }
    }
    session.add(BusinessContext(
        business_id=business.id,
        version_label="seed",
        context_json=json.dumps(seed_ctx),
        conventions_json="{}",
        is_active=True,
    ))
    session.commit()
    session.refresh(business)
    return business


@router.put(
    "/businesses/{business_id}",
    response_model=BusinessOut,
    operation_id="updateBusiness",
)
def update_business(
    business_id: str,
    data: BusinessIn,
    session: Dependencies.Session,
    _role: Dependencies.BusinessAdminOnly,
):
    business = session.get(Business, business_id)
    if not business:
        raise HTTPException(status_code=404, detail="Business not found")
    # Patch-style update: every client-writable field is applied only when the
    # caller actually sent it. ``BusinessIn`` gives each field a default, so an
    # unconditional assignment would clobber the stored value (and cascade-NULL
    # derived columns) on every edit form that omits the field. For example, an
    # edit dialog that drops ``industry_alignment`` would also NULL the derived
    # ``industry_id``, and a runs-detail inline edit that never sends
    # ``business_vibes`` would wipe it. ``model_fields_set`` distinguishes
    # "present in request body" from "absent, use default", so an omitted field
    # is preserved while an explicit ``null``/``""`` is applied.
    if "name" in data.model_fields_set and data.name != business.name:
        try:
            ensure_business_name_available(session, data.name, exclude_id=business.id)
        except BusinessNameConflict as exc:
            raise business_name_taken_error(data.name, str(exc)) from exc
        business.name = data.name
    if "description" in data.model_fields_set:
        business.description = data.description
    if "business_vibes" in data.model_fields_set:
        business.business_vibes = data.business_vibes
    if "industry_alignment" in data.model_fields_set:
        business.industry_alignment = data.industry_alignment
        # ``industry_id`` is derived from the alignment text, so it must move in
        # lockstep; recompute it inside this branch only.
        business.industry_id = resolve_industry_id(session, data.industry_alignment)
    if "sector_id" in data.model_fields_set:
        _validate_sector_id(session, data.sector_id)
        business.sector_id = data.sector_id
    if "business_domains" in data.model_fields_set:
        business.business_domains = data.business_domains
    if "org_divisions" in data.model_fields_set:
        business.org_divisions = data.org_divisions
    business.updated_at = datetime.now(timezone.utc)
    session.add(business)
    session.commit()
    session.refresh(business)
    return business


@router.delete(
    "/businesses/{business_id}",
    response_model=BusinessDeleteOut,
    operation_id="deleteBusiness",
)
def delete_business(
    business_id: str,
    session: Dependencies.Session,
    ws: Dependencies.Client,
    config: Dependencies.Config,
    _role: Dependencies.BusinessAdminOnly,
    cascade: bool = False,
):
    """Delete a business (``_version_lifecycle.delete_business``). By default
    rejects if the business has any model versions or runs. Pass
    ?cascade=true to remove it and all dependent data.

    Refused with 409 (nothing changed) while the business has an active run
    or another request holds it, and while any of its versions is installed
    (``{"error": "installed", "catalogs", "versions", "message"}``: uninstall
    them first). The delete rides the DB ON DELETE rules: model versions and
    their element tree, runs and their run-scoped rows, vibe inputs and their
    context/run links, diagram caches, and business contexts all die via
    ``business_id`` / ``version_id`` / ``run_id`` CASCADE;
    ``source_industry_id`` on any business kickstarted from this one SET
    NULLs so kickstarted children survive with their provenance cleared. The
    agent's ``_metamodel`` rows of every version are removed per catalog after
    the commit, recorded in ``metamodel_cleanup``; an unfinished one is
    retried by the boot sweep."""
    business = session.get(Business, business_id)
    if not business:
        raise HTTPException(status_code=404, detail="Business not found")

    # The 409 confirm gate: refuse a bare delete when the business carries model
    # versions or runs so the caller must opt into ?cascade=true. Run is checked
    # alongside ModelVersion because it FKs back to ``businesses.id`` and can
    # exist without ever producing a version (a failed new-base-model run).
    if not cascade:
        if len(business.versions) > 0:
            raise HTTPException(
                status_code=409,
                detail="Cannot delete a business that has model versions; pass ?cascade=true to force",
            )
        if session.exec(select(Run.id).where(Run.business_id == business_id).limit(1)).first():
            raise HTTPException(
                status_code=409,
                detail="Cannot delete a business that has runs; pass ?cascade=true to force",
            )

    try:
        outcome = delete_business_rows(session, ws, resolve_warehouse_id(session, config), business_id)
    except VersionDeleteRefused as refused:
        raise HTTPException(status_code=refused.status_code, detail=refused.detail)
    return BusinessDeleteOut(
        ok=True,
        cascaded=cascade,
        metamodel_cleanup=MetamodelCleanupSummaryOut(
            done=outcome.cleanup_done, pending=outcome.cleanup_pending, failed=outcome.cleanup_failed,
        ),
    )


# --- Business Contexts ---


@router.get(
    "/businesses/{business_id}/contexts",
    response_model=list[BusinessContextOut],
    operation_id="listContexts",
)
def list_contexts(business_id: str, session: Dependencies.Session):
    contexts = session.exec(
        select(BusinessContext)
        .where(BusinessContext.business_id == business_id)
        .order_by(BusinessContext.created_at.desc())
    ).all()
    return contexts


@router.post(
    "/businesses/{business_id}/contexts",
    response_model=BusinessContextOut,
    operation_id="createContext",
)
def create_context(
    business_id: str,
    data: BusinessContextIn,
    session: Dependencies.Session,
    _role: Dependencies.ModelerOnly,
):
    business = session.get(Business, business_id)
    if not business:
        raise HTTPException(status_code=404, detail="Business not found")
    context = BusinessContext(
        business_id=business_id,
        version_label=data.version_label,
        context_json=data.context_json,
        conventions_json=data.conventions_json,
        is_active=data.is_active,
    )
    session.add(context)
    session.commit()
    session.refresh(context)
    return context


# --- Model Import ---


@router.post(
    "/businesses/{business_id}/import/analyze",
    response_model=ImportAnalyzeOut,
    operation_id="analyzeImport",
)
def analyze_import(
    business_id: str,
    data: ImportAnalyzeIn,
    session: Dependencies.Session,
    ws: Dependencies.Client,
):
    """Analyze a model.json at the given Volume path without importing.

    Returns a structured report indicating whether the file matches a known
    vibe-modeling-agent schema, with counts and warnings so the user can confirm.
    """
    biz = session.exec(select(Business).where(Business.id == business_id)).first()
    if not biz:
        raise HTTPException(status_code=404, detail="Business not found")

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
    digest_diff: Optional[BusinessDigestDiff] = None
    if digest is not None:
        mismatches = diff_business_digest(
            digest,
            current_name=biz.name,
            current_industry_alignment=biz.industry_alignment,
            digest_industry_id=resolve_industry_id(session, digest.industry_alignment),
            current_industry_id=biz.industry_id,
        )
        digest_diff = BusinessDigestDiff(
            digest=digest, mismatch_fields=mismatches,
        )

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
        business_digest_diff=digest_diff,
        **(analysis_fields(model_json, data.volume_path) if analysis.valid else {}),
    )


@router.post(
    "/businesses/{business_id}/import/execute",
    response_model=ImportExecuteOut,
    operation_id="executeImport",
)
def execute_import(
    request: Request,
    business_id: str,
    data: ImportExecuteIn,
    session: Dependencies.Session,
    ws: Dependencies.Client,
    config: Dependencies.Config,
    _role: Dependencies.ModelerOnly,
):
    """Import a previously-vibed model.json from a Volume as a new ModelVersion.

    The imported version is marked deployment_status='draft' — user runs the
    install operation manually to push to UC. Refused with 409 (``run_active``
    / ``business_busy``, ``core._runs.lock_business_for_write``) while a run
    of the business is active, before anything is written.
    """
    from ._helpers import require_config

    # Hard-fail before importing when config is missing: an import that can't
    # seed _metamodel leaves a version that can't be iterated.
    require_config(session, config, ["metamodel_catalog", "warehouse"], mode="raise")

    biz = session.exec(select(Business).where(Business.id == business_id)).first()
    if not biz:
        raise HTTPException(status_code=404, detail="Business not found")

    try:
        model_json = read_model_json_from_volume(ws, data.volume_path)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))

    analysis = detect_schema(model_json)
    if not analysis.valid:
        raise HTTPException(status_code=400, detail=analysis.message)

    from ..core._defaults import SUPPORTED_AGENT_VERSION
    gate = gate_model_json(model_json, fallback=SUPPORTED_AGENT_VERSION)
    detected_tag = gate.tag
    exec_warnings = list(analysis.warnings)
    if gate.refused:
        raise HTTPException(status_code=422, detail=gate.refusal_detail())
    if gate.needs_adapter:
        logger.warning("import/execute: %s", gate.adapter_warning)
        exec_warnings.append(gate.adapter_warning)

    # Story-2: refuse the import when the model.json's business identity
    # disagrees with the target Business unless the user has explicitly
    # opted in (UI checkbox). The agent stamps both `business_name` and
    # `industry_alignment` into the file, so importing one business's
    # model into another's row is the kind of "looks right but isn't"
    # mistake the diff catches. Runs AFTER the compat check — a
    # structurally-incompatible file is the harder failure mode and we
    # want its 422 to surface even when names also disagree.
    digest = extract_business_digest(model_json)
    if digest is not None and not data.accept_business_mismatch:
        mismatches = diff_business_digest(
            digest,
            current_name=biz.name,
            current_industry_alignment=biz.industry_alignment,
            digest_industry_id=resolve_industry_id(session, digest.industry_alignment),
            current_industry_id=biz.industry_id,
        )
        if mismatches:
            raise HTTPException(
                status_code=409,
                detail={
                    "error": "business_identity_mismatch",
                    "message": (
                        f"model.json describes business "
                        f"'{digest.business_name}' (industry: "
                        f"'{digest.industry_alignment}') but the target "
                        f"business is '{biz.name}' (industry: "
                        f"'{biz.industry_alignment}'). Re-submit with "
                        f"accept_business_mismatch=true to import anyway."
                    ),
                    "mismatch_fields": [m.model_dump() for m in mismatches],
                },
            )

    # ECM or MVM: the file's version, else the user's choice, else the file's
    # requirements, else its folder. Nothing is written before every check.
    scope = resolve_scope(model_json, data.volume_path, data.scope)

    # The import numbers the version and writes into its folder, which is the
    # one a running vibe of this business produces: refuse while a run is
    # active, and hold the business until the version row commits.
    lock_business_for_write(session, business_id)

    # Per-scope ordinal: ECM and MVM number independently so the natural
    # key (business, version, scope) stays unique.
    new_version_num = next_version_for_scope(session, business_id, scope)
    catalog = resolve_import_registry_catalog(session)
    prepared = prepare_dialog_import(
        ws,
        model_json=model_json,
        volume_path=data.volume_path,
        scope=scope,
        version=new_version_num,
        catalog=catalog,
        business_name=biz.name,
        databricks_run_id=data.databricks_run_id,
    )

    # Lineage: the parent the model.json names, version-decrement heuristic second.
    from .import_root import _infer_lineage_parent_id
    parent = resolve_model_json_parent(session, business_id, model_json)
    lineage_parent_id = parent.id if parent is not None else None
    if lineage_parent_id is None:
        lineage_parent_id = _infer_lineage_parent_id(
            session, business_id, scope, new_version_num,
        )

    # Version provenance from the model.json envelope (the outer file: the
    # top-level agent_version / release_version keys live there).
    agent_version, release_version = extract_version_provenance(model_json)
    fence_mode, fence_base_version, fence_base_scope = extract_vibe_scope_facts(model_json)

    # Every refusal is behind us: the app's folder needs its _metamodel schema
    # and vol_root volume, which a catalog the agent never ran in lacks.
    ensure_metamodel_or_refuse(ws, catalog)

    now_ts = datetime.now(timezone.utc)
    mv = ModelVersion(
        business_id=business_id,
        status="completed",
        deployment_status="draft",  # Import does NOT write to UC; user installs manually
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
    session.flush()  # assigns mv.id
    sync_prepared(session, mv.id, prepared)
    # Lakebase durable before the Volume copy and the external _metamodel
    # write, neither of which holds a transaction.
    session.commit()

    try:
        copy_import_files(ws, prepared)
    except ImportCopyFailed as exc:
        undo_import(session, ws, prepared, mv.id)
        raise HTTPException(status_code=exc.status, detail=str(exc)) from exc

    exec_warnings.extend(finish_dialog_import(
        ws, session, prepared,
        version_id=mv.id,
        business_id=business_id,
        business_name=biz.name,
        catalog=catalog,
        warehouse_id=get_warehouse_id(session),
        log_prefix="execute_import",
    ))

    linked_run_id = None
    if data.databricks_run_id is not None:
        linked_run_id, link_warning = link_after_import(session, ws, biz, mv, data.databricks_run_id)
        if link_warning:
            exec_warnings.append(link_warning)

    # Invalidate stale layouts for prior versions and queue pre-computes
    # for the newly imported version so the first diagram view is fast.
    # Non-blocking — uses the ELK prefetch thread pool.
    try:
        from ..diagram import (
            _invalidate_business_layouts,
            queue_layout_prefetch_for_version,
        )

        _invalidate_business_layouts(session, business_id, mv.id)

        # Pre-compute runs asynchronously after this handler returns, so the
        # request-scoped `session` will already be closed by the time the
        # worker picks the job up. Hand the helper a factory that opens its
        # own session bound to the app engine. Lazy evaluation keeps tests
        # that stub _prefetch_pool.submit happy even if they don't set up
        # app.state.engine.
        # expire_on_commit=False: this factory feeds the same background ELK
        # prefetch worker (_background_compute) as the diagram route's own
        # session_factory - see diagram.py's get_diagram_layout for why.
        post_import_session_factory = lambda: Session(
            bind=request.app.state.engine, expire_on_commit=False,
        )
        queue_layout_prefetch_for_version(
            session, post_import_session_factory, ws,
            business_id=business_id,
            version_int=new_version_num,
            scope=scope,
        )
    except Exception:
        # Pre-compute is best-effort; never fail the import because of it
        logger.exception("Failed to queue post-import pre-computes (non-fatal)")

    # Count what was inserted for the response
    from ..db_models import Attribute as DbAttr, Domain as DbDomain, ForeignKeyLink, Product as DbProduct
    domains = session.exec(select(DbDomain).where(DbDomain.version_id == mv.id)).all()
    products = session.exec(select(DbProduct).where(DbProduct.version_id == mv.id)).all()
    attr_count = sum(
        1 for p in products
        for _ in session.exec(select(DbAttr).where(DbAttr.product_id == p.id)).all()
    )
    fks = session.exec(
        select(ForeignKeyLink).where(ForeignKeyLink.version_id == mv.id)
    ).all()

    return ImportExecuteOut(
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
