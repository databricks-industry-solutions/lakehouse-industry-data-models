"""Orphan schema routes: list a business's schemas in a catalog that no
installed version claims, and drop the ones the app service principal owns.

Listing and dropping are ``AdminOnly``; ``listRunSchemaDrops`` (what a drop
run did) is a run read open to every role. The rules live in ``services/orphan_schemas.py``.
The drop is checked first and changes nothing when refused: 422 for a bad
request; 422 ``config_missing`` without a SQL warehouse, or without a
metamodel catalog when no catalog is given; 422 ``needs_confirmation`` (with
the ``impact`` and the subject to send back in ``confirmed_issues``) when the
drop may delete data; 409 ``not_droppable`` when a selected schema is not an
orphan the app owns (checked again under the business lock); 409 when a run
of the business is active; 503 ``oob_scan_failed``
(``core/_errors.registry_scan_failed_error``) when the registry cannot be
read, 503 ``orphan_check_failed`` when the catalog cannot be listed or its
registry is too large.
"""

from __future__ import annotations

from typing import Optional

from fastapi import APIRouter, HTTPException, Query

from ..._metadata import api_prefix
from ..core import Dependencies
from ..core._catalogs import resolve_metamodel_catalog
from ..core._errors import config_missing_error, registry_scan_failed_error
from ..core._runs import lock_business_for_run
from ..db_models import Business
from ..models import DropOrphanSchemasIn, DropOrphanSchemasOut, OrphanSchemaDropOut, OrphanSchemasOut
from ..router import get_run_in_business
from ..services.orphan_schemas import (
    MAX_DROP_SCHEMAS,
    OrphanDiscoveryError,
    RegistryReadError,
    confirm_subject,
    discover_orphans,
    drop_orphan_schemas,
    needs_confirmation,
    orphan_impact,
    read_registry,
    schema_drops_of_run,
    subject_needed,
)
from ..services.uninstall_impact import ScanRateLimited, impact_needs_confirmation
from ._helpers import require_catalog_name, resolve_warehouse_id, scan_rate_limited

router = APIRouter(prefix=api_prefix)


def _business(session, business_id: str) -> Business:
    business = session.get(Business, business_id)
    if business is None:
        raise HTTPException(status_code=404, detail="Business not found")
    return business


def _target_catalog(session, config, catalog: Optional[str]) -> str:
    target = (catalog or "").strip().lower()
    if not target:
        target = resolve_metamodel_catalog(session, config).lower()
    if not target:
        raise config_missing_error("metamodel_catalog")
    return require_catalog_name(target)


def _warehouse(session, config) -> str:
    warehouse_id = resolve_warehouse_id(session, config)
    if not warehouse_id:
        raise config_missing_error("warehouse")
    return warehouse_id


def _selection(names: list[str]) -> list[str]:
    selected = sorted(dict.fromkeys(n.strip().lower() for n in names if n and n.strip()))
    if len(selected) > MAX_DROP_SCHEMAS:
        raise HTTPException(
            status_code=422,
            detail={"message": f"Drop at most {MAX_DROP_SCHEMAS} schemas at a time."},
        )
    return selected


def _check_failed(exc: OrphanDiscoveryError) -> HTTPException:
    if isinstance(exc, RegistryReadError):
        return registry_scan_failed_error(exc.sql_message)
    return HTTPException(
        status_code=503, detail={"error": "orphan_check_failed", "message": exc.message},
    )


def _not_droppable(catalog: str, names: list[str]) -> HTTPException:
    return HTTPException(
        status_code=409,
        detail={
            "error": "not_droppable",
            "message": (
                f"These schemas are not orphans of this business that the app owns in "
                f"{catalog}, so they were not dropped: {', '.join(names)}. Check the "
                "catalog again."
            ),
            "schemas": names,
        },
    )


@router.get(
    "/businesses/{business_id}/orphan-schemas",
    response_model=OrphanSchemasOut,
    operation_id="listOrphanSchemas",
)
def list_orphan_schemas(
    business_id: str,
    session: Dependencies.Session,
    ws: Dependencies.Client,
    config: Dependencies.Config,
    user: Dependencies.UserIdentity,
    _role: Dependencies.AdminOnly,
    catalog: Optional[str] = None,
    schemas: list[str] = Query(default=[]),
):
    """The business's orphan schemas in ``catalog`` (default: the metamodel
    catalog), each with its owner and whether the app may drop it, and the
    impact of dropping ``schemas`` (default: every droppable one) with the
    confirm subject that drop needs. The impact goes through the
    uninstall-impact cache and scan limit (429 with ``Retry-After``)."""
    business = _business(session, business_id)
    target = _target_catalog(session, config, catalog)
    warehouse_id = _warehouse(session, config)
    try:
        discovery = discover_orphans(
            session, ws, business, target, read_registry(ws, warehouse_id, target),
        )
    except OrphanDiscoveryError as exc:
        raise _check_failed(exc) from exc
    droppable = discovery.droppable()
    selected = _selection(schemas) if schemas else sorted(droppable)
    refused = [n for n in selected if n not in droppable]
    if refused:
        raise _not_droppable(target, refused)
    out = OrphanSchemasOut(catalog=target, schemas=discovery.schemas)
    if not selected:
        return out
    try:
        impact = orphan_impact(ws, warehouse_id, target, selected, discovery.owners(), user=user)
    except ScanRateLimited as exc:
        raise scan_rate_limited(exc.retry_after_s, "orphan schema checks") from exc
    counts = {s.name: len(s.tables) for s in impact.schemas if s.objects_listed}
    for schema in out.schemas:
        schema.table_count = counts.get(schema.name)
    out.impact = impact
    out.confirm_subject = subject_needed(impact, target, selected)
    return out


@router.post(
    "/businesses/{business_id}/orphan-schemas/drop",
    response_model=DropOrphanSchemasOut,
    operation_id="dropOrphanSchemas",
)
def post_drop_orphan_schemas(
    business_id: str,
    data: DropOrphanSchemasIn,
    session: Dependencies.Session,
    ws: Dependencies.Client,
    config: Dependencies.Config,
    user: Dependencies.UserIdentity,
    _role: Dependencies.AdminOnly,
):
    """Drop the selected orphan schemas, under an audit run.

    Order: validate; read the registry and find the orphans; refuse a
    schema that is not a droppable orphan; read the impact (a fresh scan
    when the subject was not confirmed, else the cached one, which only
    fills the table counts) and refuse with 422 ``needs_confirmation`` when
    it may delete data and the subject was not confirmed; take the business lock
    (409 when a run is active); find the orphans again from
    a fresh catalog listing and the Lakebase state now, and refuse when the
    selection no longer qualifies; then drop (see
    ``services.orphan_schemas.drop_orphan_schemas``). Nothing is written
    before the lock is held and the second check passes."""
    business = _business(session, business_id)
    target = _target_catalog(session, config, data.catalog)
    selected = _selection(data.schemas)
    if not selected:
        raise HTTPException(status_code=422, detail={"message": "Choose at least one schema to drop."})
    warehouse_id = _warehouse(session, config)
    try:
        registry = read_registry(ws, warehouse_id, target)
        discovery = discover_orphans(session, ws, business, target, registry)
    except OrphanDiscoveryError as exc:
        raise _check_failed(exc) from exc
    refused = [n for n in selected if n not in discovery.droppable()]
    if refused:
        raise _not_droppable(target, refused)

    confirmed = confirm_subject(target, selected) in set(data.confirmed_issues or [])
    try:
        impact = orphan_impact(
            ws, warehouse_id, target, selected, discovery.owners(), user=user, fresh=not confirmed,
        )
    except ScanRateLimited as exc:
        if not confirmed:
            raise scan_rate_limited(exc.retry_after_s, "orphan schema checks") from exc
        impact = None
    if not confirmed and impact_needs_confirmation(impact):
        raise needs_confirmation(target, selected, impact)

    lock_business_for_run(session, business.id)
    try:
        current = discover_orphans(session, ws, business, target, registry)
    except OrphanDiscoveryError as exc:
        session.rollback()
        raise _check_failed(exc) from exc
    refused = [n for n in selected if n not in current.droppable()]
    if refused:
        session.rollback()
        raise _not_droppable(target, refused)
    return drop_orphan_schemas(
        session, ws, warehouse_id, business, target, selected, current, impact,
        requested_by=user,
    )


@router.get(
    "/businesses/{business_id}/runs/{run_id}/schema-drops",
    response_model=list[OrphanSchemaDropOut],
    operation_id="listRunSchemaDrops",
)
def list_run_schema_drops(business_id: str, run_id: str, session: Dependencies.Session):
    """What an orphan-schema drop run dropped: each schema with ``dropped`` or
    ``failed`` and its error. Empty for any other run. Open to every role,
    like the other run reads; 404 when the run is not in the business."""
    run = get_run_in_business(session, business_id, run_id)
    return schema_drops_of_run(session, run.id)
