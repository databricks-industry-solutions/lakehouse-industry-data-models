"""Out-of-band versions (`/api/oob/*`, `/api/businesses/{id}/oob/import`).

Versions the agent wrote to ``_metamodel`` outside the app (a hand-started
job run) are found by ``oob_detector`` and imported through
``InitialSyncService``. Each route takes the role of its closest existing
sibling: reads, "Check now" and the per-business import are ModelerOnly
(``executeImport``); the import that creates businesses is BusinessAdminOnly
(``createBusinessAndExecuteImport``).

The summary never wakes a warehouse: it returns the cached result and, when
that is older than 15 minutes, starts a background check that runs only on a
warehouse that is already running. "Check now" may start the warehouse.
"""

from __future__ import annotations

from typing import Optional

from fastapi import APIRouter, HTTPException
from sqlalchemy.exc import SQLAlchemyError
from sqlmodel import Session

from ..._metadata import api_prefix
from .._query_helpers import businesses_by_segment
from ..core import Dependencies, resolve_metamodel_catalog
from ..core._errors import business_locked_error, registry_scan_failed_error
from ..core._names import agent_business_segment
from ..core._runs import active_run_for_business, lock_business_for_write
from ..core._sql import SqlStatementError
from ..core._warehouse import get_warehouse_id
from ..db_models import Business
from ..initial_sync import InitialSyncService
from ..models import OobBusinessOut, OobImportOut, OobSummaryOut
from ..oob_detector import OOB_CHECKS, OobDetector, oob_keys
from ._helpers import require_config, resolve_warehouse_id

router = APIRouter(prefix=api_prefix)

_IMPORT_NEEDS = ["metamodel_catalog", "warehouse"]


@router.get("/oob/summary", response_model=OobSummaryOut, operation_id="getOobSummary")
def get_oob_summary(
    session: Dependencies.Session,
    ws: Dependencies.Client,
    _role: Dependencies.ModelerOnly,
):
    """The last out-of-band check. Starts a background check on a running
    warehouse when the cached result is older than 15 minutes; never writes
    and never starts the warehouse."""
    catalog = resolve_metamodel_catalog(session)
    warehouse_id = get_warehouse_id(session)
    OOB_CHECKS.refresh_if_stale(session.get_bind(), ws, warehouse_id, catalog)
    return OOB_CHECKS.summary(catalog)


@router.post("/oob/check", response_model=OobSummaryOut, operation_id="checkOobNow")
def check_oob_now(
    session: Dependencies.Session,
    ws: Dependencies.Client,
    config: Dependencies.Config,
    _role: Dependencies.ModelerOnly,
):
    """Start a check now, in the background; it may start the warehouse.
    429 within a minute of the previous one."""
    require_config(session, config, _IMPORT_NEEDS, mode="raise")
    catalog = resolve_metamodel_catalog(session, config)
    warehouse_id = resolve_warehouse_id(session, config)
    retry_after = OOB_CHECKS.check_now(session.get_bind(), ws, warehouse_id, catalog)
    if retry_after is not None:
        raise HTTPException(
            status_code=429,
            detail={
                "error": "rate_limited",
                "message": f"A check ran less than a minute ago. Try again in {retry_after} s.",
                "retry_after_s": retry_after,
            },
        )
    return OOB_CHECKS.summary(catalog)


def _detect_now(session: Session, ws, warehouse_id: str, catalog: str) -> list[OobBusinessOut]:
    """A fresh scan for an import. Fails fast (one 30 s server wait) because
    it runs inside the request. The preflight reads are committed first, so
    no transaction stays open across the scan."""
    session.commit()
    try:
        return OobDetector(session, ws, warehouse_id, timeout_s=None).detect(catalog)
    except SqlStatementError as exc:
        raise registry_scan_failed_error(exc.message) from exc


def _import(
    session: Session, ws, warehouse_id: str, catalog: str,
    found: list[OobBusinessOut], wanted: list[OobBusinessOut],
    *, business_id: Optional[str] = None, new_businesses_only: bool = False,
) -> dict:
    """Import ``wanted`` and commit. A version that fails rolls back alone
    (savepoints in ``InitialSyncService``); a failed commit writes nothing and
    answers 503.

    With ``business_id`` the business row is locked first
    (``core._runs.lock_business_for_write``) and held until the commit, so no run of it
    starts while its versions are written; a run that started since the
    preflight answers 409 and nothing is written. The lock window spans
    discovery's re-read of the registry and the Volume loads as well as the
    writes, a minute or more on a cold warehouse; a run started for the
    business meanwhile is refused at once ("another request is in
    progress"). The preflight check before the scan stays, so a busy
    business is refused before the scan runs.
    """
    if business_id is not None:
        lock_business_for_write(session, business_id)
    try:
        summary = InitialSyncService(session, ws, warehouse_id).discover_and_sync(
            catalog,
            business_segments=[b.business_segment for b in wanted],
            only_versions=oob_keys(wanted),
            new_businesses_only=new_businesses_only,
        )
    except SqlStatementError as exc:
        session.rollback()
        raise registry_scan_failed_error(exc.message) from exc
    try:
        session.commit()
    except SQLAlchemyError as exc:
        session.rollback()
        raise HTTPException(
            status_code=503,
            detail={
                "error": "oob_import_failed",
                "message": "The import could not be saved, and nothing was imported. Try again.",
            },
        ) from exc
    OOB_CHECKS.record_import(catalog, found, summary["imported"], summary["refused"])
    return summary


def _importable(entries: list[OobBusinessOut]) -> list[OobBusinessOut]:
    """``entries`` without the versions the detector already marks refused."""
    out = []
    for b in entries:
        versions = [v for v in b.versions if not v.refused_reason]
        if versions:
            out.append(b.model_copy(update={"versions": versions}))
    return out


@router.post(
    "/businesses/{business_id}/oob/import",
    response_model=OobImportOut,
    operation_id="importOobVersionsForBusiness",
)
def import_oob_versions_for_business(
    business_id: str,
    session: Dependencies.Session,
    ws: Dependencies.Client,
    config: Dependencies.Config,
    _role: Dependencies.ModelerOnly,
):
    """Import this business's out-of-band versions. 409 when several
    businesses share its agent segment or a run of it is in flight."""
    require_config(session, config, _IMPORT_NEEDS, mode="raise")
    business = session.get(Business, business_id)
    if business is None:
        raise HTTPException(status_code=404, detail="Business not found")
    segment = agent_business_segment(business.name)
    candidates = businesses_by_segment(session).get(segment, [])
    if len(candidates) > 1:
        raise HTTPException(
            status_code=409,
            detail={
                "error": "ambiguous_business",
                "message": (
                    "Several businesses have names that the agent stores the same way. "
                    "Rename one of them, then import again."
                ),
                "candidate_business_ids": [b.id for b in candidates],
            },
        )
    if active_run_for_business(session, business_id) is not None:
        raise business_locked_error(
            "A run of this business is in progress. Import after it finishes.", run_active=True,
        )

    catalog = resolve_metamodel_catalog(session, config)
    warehouse_id = resolve_warehouse_id(session, config)
    found = _detect_now(session, ws, warehouse_id, catalog)
    mine = _importable([b for b in found if b.business_segment == segment and b.status == "existing"])
    if not mine:
        OOB_CHECKS.record_import(catalog, found, [], [])
        return OobImportOut()

    summary = _import(session, ws, warehouse_id, catalog, found, mine, business_id=business_id)
    return OobImportOut(imported_versions=summary["versions_synced"], warnings=summary["errors"])


@router.post(
    "/oob/import-new-businesses",
    response_model=OobImportOut,
    operation_id="importOobNewBusinesses",
)
def import_oob_new_businesses(
    session: Dependencies.Session,
    ws: Dependencies.Client,
    config: Dependencies.Config,
    _role: Dependencies.BusinessAdminOnly,
):
    """Create a business for each out-of-band segment that has none, and
    import its versions."""
    require_config(session, config, _IMPORT_NEEDS, mode="raise")
    catalog = resolve_metamodel_catalog(session, config)
    warehouse_id = resolve_warehouse_id(session, config)
    found = _detect_now(session, ws, warehouse_id, catalog)
    new = _importable([b for b in found if b.status == "new"])
    if not new:
        OOB_CHECKS.record_import(catalog, found, [], [])
        return OobImportOut()

    summary = _import(session, ws, warehouse_id, catalog, found, new, new_businesses_only=True)
    return OobImportOut(
        imported_versions=summary["versions_synced"],
        created_business_ids=summary["created_business_ids"],
        warnings=summary["errors"],
    )
