"""Durable removal of a deleted version's ``_metamodel`` registry rows.

A delete (of a version, a business, or a version an install replaced) writes
one ``metamodel_cleanups`` row per catalog, ``pending``, in the transaction
that deletes the Lakebase rows (:func:`record_cleanups`). An orphan-schema
drop (``services/orphan_schemas.py``) writes one for each registry version
Lakebase does not know whose schemas it dropped. After that commit the
caller runs them (:func:`run_cleanups`); each attempt sets ``done`` or
``failed`` with a sanitized reason, in its own commit. The boot sweep
(:func:`sweep_metamodel_cleanups`) retries unfinished rows until
:data:`MAX_ATTEMPTS`; after that a ``failed`` row stays visible until Retry
cleanup (:func:`retry_cleanup`) succeeds.

While a row for ``(segment, scope, catalog)`` is unfinished, the agent still
holds the deleted version in that catalog's registry, so its "latest version"
there is the deleted one; the run pre-flight reads :func:`unfinished_cleanups`
for that reason.
"""

from __future__ import annotations

import logging
from dataclasses import dataclass
from datetime import datetime, timezone
from typing import Any, Iterable, Optional

from sqlmodel import col, func, select

from ..db_models import MetamodelCleanup
from ._sql import SqlStatementError

logger = logging.getLogger(__name__)

PENDING = "pending"
DONE = "done"
FAILED = "failed"
UNFINISHED_STATUSES: tuple[str, ...] = (PENDING, FAILED)
MAX_ATTEMPTS = 3
# Warehouse answers that mean "not finished in time", not a failed statement.
_TIMEOUT_STATES = ("TIMEOUT", "STILL_RUNNING")

REASON_VERSION_DELETE = "version_delete"
REASON_BUSINESS_DELETE = "business_delete"
REASON_POST_INSTALL_DELETE = "post_install_delete"
REASON_ORPHAN_DROP = "orphan_drop"

_NO_WAREHOUSE = "No SQL warehouse is configured, so the agent's registry rows were not removed"
_WAREHOUSE_TIMEOUT = (
    "The SQL warehouse did not answer in time (it may be starting). "
    "The app retries when it starts, or use Retry cleanup."
)


def _now() -> datetime:
    return datetime.now(timezone.utc)


@dataclass
class CleanupSummary:
    """How many rows ended in each state, and whether any attempt found and
    removed registry rows."""

    done: int = 0
    pending: int = 0
    failed: int = 0
    rows_removed: bool = False

    def add(self, row: MetamodelCleanup, removed: bool = False) -> None:
        if row.status == DONE:
            self.done += 1
        elif row.status == FAILED:
            self.failed += 1
        else:
            self.pending += 1
        self.rows_removed = self.rows_removed or removed


def record_cleanups(
    session: Any,
    *,
    business_segment: str,
    version: int,
    scope: str,
    catalogs: Iterable[str],
    reason: str,
) -> list[MetamodelCleanup]:
    """Add one ``pending`` row per catalog. Flushes; the caller commits it
    with the delete."""
    rows = [
        MetamodelCleanup(
            business_segment=business_segment, version=int(version), scope=scope or "",
            catalog=catalog, reason=reason,
        )
        for catalog in dict.fromkeys(c for c in catalogs if c)
    ]
    for row in rows:
        session.add(row)
    session.flush()
    return rows


def live_holder(session: Any, row: MetamodelCleanup) -> Optional[str]:
    """A version that exists now with the row's key (business segment,
    number, scope) and is recorded in the row's catalog, as ``vN SCOPE of
    <business>``, or None. Its registry rows carry the same key, so deleting
    by that key would remove them: the number was reused after the delete
    (installed there from elsewhere, or a business recreated with the same
    name)."""
    from ..db_models import Business, ModelVersion
    from ..services.operations._version_lifecycle import _recorded_in
    from ._names import agent_business_segment

    business_ids = {
        b.id: b.name for b in session.exec(select(Business)).all()
        if agent_business_segment(b.name) == row.business_segment
    }
    if not business_ids:
        return None
    mv = session.exec(
        select(ModelVersion).where(
            col(ModelVersion.business_id).in_(list(business_ids)),
            ModelVersion.version == int(row.version),
            func.lower(ModelVersion.scope) == (row.scope or "").lower(),
            _recorded_in(row.catalog),
        )
    ).first()
    if mv is None:
        return None
    return f"v{mv.version} {(mv.scope or '').upper()} of {business_ids[mv.business_id]}"


def run_cleanup(session: Any, ws: Any, warehouse_id: Optional[str], row: MetamodelCleanup) -> bool:
    """One attempt at ``row``: delete the version's registry rows in its
    catalog, record ``done`` or ``failed`` and commit. Returns whether
    registry rows were found and removed.

    When a live version now holds the same key in the catalog
    (:func:`live_holder`), nothing is deleted: the rows are that version's,
    so the row is ``done`` with the reason in ``last_error``."""
    return _attempt(session, ws, warehouse_id, row)[0]


def _attempt(session: Any, ws: Any, warehouse_id: Optional[str], row: MetamodelCleanup) -> tuple[bool, bool]:
    """:func:`run_cleanup`, also returning whether the warehouse timed out."""
    from ..error_sanitization import sanitize_error_message
    from ..model_sync import ModelSyncService

    row.attempts = int(row.attempts or 0) + 1
    row.updated_at = _now()
    removed = False
    timed_out = False
    holder = live_holder(session, row)
    if holder is not None:
        row.status = DONE
        row.last_error = f"Not removed: {holder} now holds these registry rows in {row.catalog}"
    elif not warehouse_id:
        row.status, row.last_error = FAILED, _NO_WAREHOUSE
    else:
        try:
            removed = ModelSyncService(session, ws, warehouse_id=warehouse_id).delete_metamodel_rows(
                catalog=row.catalog, business_name=row.business_segment,
                version=str(row.version), model_scope=row.scope,
            )
            row.status, row.last_error = DONE, None
        except Exception as exc:  # noqa: BLE001 - recorded on the row
            logger.warning(
                "metamodel cleanup %s (%s v%s %s in %s) failed: %s",
                row.id, row.business_segment, row.version, row.scope, row.catalog, exc,
            )
            timed_out = isinstance(exc, SqlStatementError) and exc.state in _TIMEOUT_STATES
            row.status = FAILED
            row.last_error = _WAREHOUSE_TIMEOUT if timed_out else sanitize_error_message(str(exc))[:500]
    session.add(row)
    session.commit()
    return bool(removed), timed_out


def run_cleanups(session: Any, ws: Any, warehouse_id: Optional[str], ids: Iterable[str]) -> CleanupSummary:
    """Attempt each listed row once; the summary of where they ended.

    After the first warehouse timeout the remaining rows are left as they
    are (a new row stays ``pending``) for the boot sweep or Retry cleanup:
    each attempt on a starting warehouse would wait its full timeout, and a
    delete of several versions would hold the request for minutes."""
    summary = CleanupSummary()
    stalled = False
    for cid in ids:
        row = session.get(MetamodelCleanup, cid)
        if row is None:
            continue
        removed = False
        if row.status != DONE and not stalled:
            removed, stalled = _attempt(session, ws, warehouse_id, row)
        summary.add(row, removed)
    return summary


def sweep_metamodel_cleanups(session: Any, ws: Any, warehouse_id: Optional[str]) -> CleanupSummary:
    """The boot sweep: one more attempt for every unfinished row below
    :data:`MAX_ATTEMPTS`, oldest first."""
    rows = session.exec(
        select(MetamodelCleanup)
        .where(col(MetamodelCleanup.status).in_(UNFINISHED_STATUSES))
        .where(MetamodelCleanup.attempts < MAX_ATTEMPTS)
        .order_by(col(MetamodelCleanup.created_at))
    ).all()
    summary = run_cleanups(session, ws, warehouse_id, [r.id for r in rows])
    if rows:
        logger.info(
            "metamodel cleanup sweep: %d done, %d failed, %d pending",
            summary.done, summary.failed, summary.pending,
        )
    return summary


def retry_cleanup(session: Any, ws: Any, warehouse_id: Optional[str], row: MetamodelCleanup) -> MetamodelCleanup:
    """Retry cleanup: reset the attempt count and attempt once more. A
    ``done`` row is returned as it is."""
    if row.status != DONE:
        row.attempts = 0
        run_cleanup(session, ws, warehouse_id, row)
    return row


def unfinished_cleanups(
    session: Any, business_segment: str, *, scope: Optional[str] = None, catalog: Optional[str] = None,
) -> list[MetamodelCleanup]:
    """The ``pending`` and ``failed`` rows of a business segment, newest
    first, optionally for one scope and catalog."""
    stmt = select(MetamodelCleanup).where(
        MetamodelCleanup.business_segment == business_segment,
        col(MetamodelCleanup.status).in_(UNFINISHED_STATUSES),
    )
    if scope is not None:
        stmt = stmt.where(MetamodelCleanup.scope == scope)
    if catalog is not None:
        stmt = stmt.where(MetamodelCleanup.catalog == catalog)
    return list(session.exec(stmt.order_by(col(MetamodelCleanup.created_at).desc())).all())
