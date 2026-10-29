"""Active and in-flight runs: the one home for "is a run still going".

A run is in flight while its status is ``pending``, ``running`` or ``stale``
(a ``stale`` run lost its poller but has not reached a terminal state). The
health route reports the count so the deploy guard
(``install/in_flight_guard.sh``) can refuse to deploy, the boot agent upgrade
skips while the count is not zero, and :func:`lock_business_for_run` refuses
a second run (or a delete) while one is active.
"""

from __future__ import annotations

from typing import Optional

from fastapi import HTTPException
from sqlalchemy import func
from sqlalchemy.exc import OperationalError
from sqlmodel import Session, select

from ..db_models import Business, Run
from ._errors import business_locked_error

IN_FLIGHT_RUN_STATUSES: tuple[str, ...] = ("pending", "running", "stale")
# A run operation still open: a terminal run transition (or a rehearsal fork prep) closes these.
OPEN_OPERATION_STATUSES: frozenset[str] = frozenset({"pending", "running"})


def count_in_flight_runs(session: Session) -> int:
    """Number of runs, across all businesses, that are not terminal yet."""
    return int(
        session.exec(
            select(func.count()).select_from(Run).where(Run.status.in_(IN_FLIGHT_RUN_STATUSES))
        ).one()
    )


def active_run_message(run_id: str) -> str:
    """The refusal text for a business that has an active run (409)."""
    return f"Business already has an active run: {run_id}"


def active_run_for_business(session: Session, business_id: str) -> Optional[Run]:
    """One non-terminal run of ``business_id``, or None."""
    return session.exec(
        select(Run).where(
            Run.business_id == business_id,
            Run.status.in_(IN_FLIGHT_RUN_STATUSES),
        )
    ).first()


LOCK_BUSY_MESSAGE = "Another request for this business is in progress"
# Postgres SQLSTATE of a ``NOWAIT`` lock that another transaction holds.
_LOCK_NOT_AVAILABLE = "55P03"


class BusinessBusy(HTTPException):
    """409: another request holds the business lock, or a run is active.

    ``active_run_id`` is set when an active run refused, None when the lock
    itself did."""

    def __init__(self, message: str, *, active_run_id: Optional[str] = None) -> None:
        super().__init__(status_code=409, detail=message)
        self.message = message
        self.active_run_id = active_run_id


def _lock_not_available(exc: OperationalError) -> bool:
    orig = getattr(exc, "orig", None)
    code = getattr(orig, "sqlstate", None) or getattr(orig, "pgcode", None)
    return code == _LOCK_NOT_AVAILABLE


def lock_business_for_run(
    session: Session, business_id: str, *, allow_run_id: Optional[str] = None, rollback: bool = True,
) -> None:
    """Hold the business row for the rest of the caller's transaction, then
    refuse when a run is active.

    ``SELECT ... FOR NO KEY UPDATE NOWAIT`` on the ``businesses`` row (Postgres;
    SQLite ignores it). The ``NO KEY`` strength does not conflict with the
    ``KEY SHARE`` lock a foreign-key check takes, so inserting a row that
    references the business (feedback, a version) never waits on it; an
    ``UPDATE`` of the business row itself still does. A held lock fails at once: the failure aborts the
    Postgres transaction, so this rolls back before raising
    :class:`BusinessBusy` ("Another request for this business is in
    progress"). With the lock, an active run other than ``allow_run_id``
    rolls back (releasing the lock) and raises :class:`BusinessBusy` naming
    the run.

    The caller takes it before any write and commits nothing until its own
    write is done: a commit releases the lock.

    ``rollback=False`` raises without rolling back, for a caller that takes
    the lock inside its own savepoint (``session.begin_nested()``) so a
    refusal discards only that savepoint, not the work already in the
    transaction. A lock taken in a savepoint is held to the end of the
    transaction once the savepoint is released.
    """
    try:
        session.exec(
            select(Business.id).where(Business.id == business_id).with_for_update(nowait=True, key_share=True)
        ).first()
    except OperationalError as exc:
        if not _lock_not_available(exc):
            raise
        if rollback:
            session.rollback()
        raise BusinessBusy(LOCK_BUSY_MESSAGE) from exc
    active = active_run_for_business(session, business_id)
    if active is not None and active.id != allow_run_id:
        if rollback:
            session.rollback()
        raise BusinessBusy(active_run_message(active.id), active_run_id=active.id)


def lock_business_for_write(session: Session, business_id: str) -> None:
    """:func:`lock_business_for_run` for a route that writes a business's
    versions outside a run (the out-of-band import, the dialog import into an
    existing business). A refusal is the route's 409
    (``core._errors.business_locked_error``): an active run, or another
    request holding the lock. Nothing is written either way (the lock rolled
    back)."""
    try:
        lock_business_for_run(session, business_id)
    except BusinessBusy as exc:
        raise business_locked_error(exc.message, run_active=exc.active_run_id is not None) from exc
