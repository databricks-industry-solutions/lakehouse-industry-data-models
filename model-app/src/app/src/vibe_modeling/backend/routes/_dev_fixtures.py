"""Dev-only seed-model endpoint — NOT active production code; dev-only seeding.

The `/businesses/{id}/seed-model` endpoint accepts an arbitrary model_data
payload and writes ModelVersion / Domain / Product / Attribute / FK rows
directly into Lakebase, bypassing the normal agent-run + sync pipeline. It
exists for test fixtures and recovery scenarios — regular users should
either run a vibe pipeline or use ``importVersionFromVolume`` instead.

Plan task #34 split this out of `router.py` so production reviewers can
quickly recognise it as a dev-only surface; the file is still wired into
the FastAPI app via `app.include_router(_dev_fixtures.router)` so existing
fixtures keep working unchanged.
"""

from __future__ import annotations

import uuid
from datetime import datetime, timezone

from fastapi import APIRouter, HTTPException
from sqlmodel import select

from ..._metadata import api_prefix
from .._query_helpers import resolve_model_version
from ..core import Dependencies, resolve_metamodel_catalog
from ..db_models import Business, ModelVersion
from ..model_sync import ModelSyncService

router = APIRouter(prefix=api_prefix)


@router.post(
    "/businesses/{business_id}/seed-model",
    operation_id="seedModel",
)
def seed_model(
    business_id: str,
    body: dict,
    session: Dependencies.Session,
    _role: Dependencies.AdminOnly,
):
    """Dev-only: seed model version + data from a model.json payload.

    Admin-only: this endpoint accepts an arbitrary model_data dict and writes
    ModelVersion / Domain / Product / Attribute / ForeignKeyLink rows directly,
    bypassing the normal agent-run + sync pipeline. Useful for test fixtures
    and recovery. Regular users should use ``import_version_from_volume`` or
    launch a vibe run instead.
    """

    biz = session.get(Business, business_id)
    if not biz:
        raise HTTPException(status_code=404, detail="Business not found")

    version_num = body.get("version", 1)
    scope = body.get("scope", "ecm")
    model_data = body.get("model_data", {})

    # Check if version already exists. The natural key is now
    # (business, version, scope) so ECM v1 and MVM v1 don't collide.
    existing = resolve_model_version(session, business_id, version_num, scope)
    if existing:
        return {"status": "exists", "version_id": existing.id}

    mv = ModelVersion(
        id=str(uuid.uuid4()),
        business_id=business_id,
        version=version_num,
        status="completed",
        deployment_status="draft",
        scope=scope,
        confidence_score=0.85 if scope == "ecm" else 0.78,
        files_catalog=resolve_metamodel_catalog(session) or None,
        created_at=datetime.now(timezone.utc),
    )
    session.add(mv)
    session.flush()

    # Use ModelSyncService to insert domains/products/attributes/FKs
    # model.json files wrap the model under a "model" key — unwrap if needed
    inner = model_data.get("model", model_data) if "model" in model_data else model_data
    sync = ModelSyncService(session)
    sync.sync_from_model_json(mv.id, inner)
    session.commit()

    # Count what was inserted
    from ..db_models import Attribute, Domain, ForeignKeyLink, Product
    domains = session.exec(select(Domain).where(Domain.version_id == mv.id)).all()
    products = session.exec(select(Product).where(Product.version_id == mv.id)).all()
    attrs = sum(
        1
        for p in products
        for _ in session.exec(
            select(Attribute).where(Attribute.product_id == p.id)
        ).all()
    )
    fks = session.exec(
        select(ForeignKeyLink).where(ForeignKeyLink.version_id == mv.id)
    ).all()

    return {
        "status": "created",
        "version_id": mv.id,
        "domains": len(domains),
        "products": len(products),
        "attributes": attrs,
        "fk_links": len(fks),
    }
