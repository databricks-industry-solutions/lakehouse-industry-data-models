"""Background poller for non-terminal assessment domain runs (separate from progress_tracker)."""
from __future__ import annotations

import asyncio
import logging
from datetime import datetime, timedelta, timezone
from typing import Callable

from databricks.sdk import WorkspaceClient
from databricks.sdk.errors.platform import DatabricksError, NotFound
from typing import cast

from sqlalchemy import CursorResult, update
from sqlmodel import Session, col, or_, select

from ..db_models import AssessDomainRun
from ..error_sanitization import recorded_error_text, sanitize_error_message
from .constants import INGEST_MAX_ATTEMPTS, INGEST_RETRY_WAITS, POLL_INTERVAL_S, TERMINAL_STATUSES
from .ingest import ingest_domain_run, read_volume_json
from .status import map_status

logger = logging.getLogger(__name__)

# A launch row that never got a Databricks run id (app died mid-launch) is failed after this long.
STALE_LAUNCH_AFTER = timedelta(minutes=10)


class AssessPoller:
    def __init__(self, ws: WorkspaceClient, session_factory: Callable[[], Session]):
        self.ws = ws
        self.session_factory = session_factory

    def tick(self) -> int:
        n = 0
        with self.session_factory() as session:
            n += self._fail_stale_launches(session)
            now = datetime.now(timezone.utc)
            # A run waiting out its ingest retry window is left alone until ``ingest_next_at``.
            rows = session.exec(select(AssessDomainRun).where(
                AssessDomainRun.status.not_in(TERMINAL_STATUSES),
                AssessDomainRun.databricks_run_id.is_not(None),
                or_(col(AssessDomainRun.ingest_next_at).is_(None), col(AssessDomainRun.ingest_next_at) <= now))).all()
            for dr in rows:
                dr_id = dr.id
                try:
                    n += self._poll_one(session, dr)
                except Exception:
                    logger.exception("assess poll failed for domain run %s", dr_id)
                    session.rollback()
        return n

    def _fail_stale_launches(self, session: Session) -> int:
        now = datetime.now(timezone.utc)
        stale = session.exec(select(AssessDomainRun).where(
            AssessDomainRun.status == "queued",
            AssessDomainRun.databricks_run_id.is_(None),
            AssessDomainRun.created_at < now - STALE_LAUNCH_AFTER)).all()
        for dr in stale:
            dr.status = "failed"
            dr.error_message = "Launch did not complete (no Databricks run was started)"
            dr.ended_at = now
            session.add(dr)
        if stale:
            session.commit()
        return len(stale)

    def _read_progress(self, dr: AssessDomainRun) -> dict | None:
        try:
            return read_volume_json(self.ws, f"{dr.out_dir}/progress.json")
        except DatabricksError:
            logger.warning("progress.json unreadable for domain run %s; using Jobs API state only", dr.id)
            return None

    def _poll_one(self, session: Session, dr: AssessDomainRun) -> int:
        now = datetime.now(timezone.utc)
        try:
            run = self.ws.jobs.get_run(dr.databricks_run_id)
        except NotFound:
            dr.status, dr.error_message, dr.ended_at = "failed", "Run not found in Databricks", now
            session.add(dr)
            session.commit()
            return 1
        u = map_status(run, self._read_progress(dr))
        dr.stage, dr.attempt, dr.resume_at, dr.last_message = u.stage, u.attempt, u.resume_at, u.last_message
        if dr.started_at is None and u.status != "queued":
            dr.started_at = now
        if u.terminal_success:
            dr_id = dr.id
            try:
                res = ingest_domain_run(session, self.ws, dr)
            except Exception as e:  # noqa: BLE001 — any ingest error counts against the attempt window
                session.rollback()
                self._ingest_failed(session, dr_id, e, now)
                return 1
            dr.status = "completed" if res.results_valid else "results_invalid"
            dr.error_message = sanitize_error_message(res.error) if res.error else ""
            dr.ingest_next_at = None
            dr.ended_at = now
        else:
            dr.status = u.status
            if u.error_message:
                dr.error_message = u.error_message
            if u.status in TERMINAL_STATUSES:
                dr.ended_at = now
        session.add(dr)
        session.commit()
        return 1

    def _ingest_failed(self, session: Session, dr_id: str, error: Exception, now: datetime) -> None:
        """Count a failed ingest: wait out the next retry window, or end the run once the window is spent.

        The count moves with a guarded ``UPDATE ... WHERE ingest_attempts = <seen>``, so two pollers
        can't both count one failure or both end the run; a run that turned terminal meanwhile (e.g.
        cancelled) is left alone. While waiting, ``last_message`` holds only "<ErrorType>: <error>";
        ``AssessDomainRunOut`` carries the attempt count, limit and next try. The final state is
        ``results_invalid`` with "Ingest failed N times: <error>", the run's links alongside.
        """
        dr = session.get(AssessDomainRun, dr_id)
        if dr is None or dr.status in TERMINAL_STATUSES:
            return
        seen = dr.ingest_attempts or 0
        attempts = seen + 1
        err = recorded_error_text(
            error, f"Ingest of domain run {dr_id}", sanitize_error_message(f"{type(error).__name__}: {error}"))
        if attempts >= INGEST_MAX_ATTEMPTS:
            values = dict(status="results_invalid", results_valid=False, ingest_next_at=None, ended_at=now,
                          error_message=f"Ingest failed {attempts} times: {err}"[:2000])
        else:
            # The job is done; its results aren't saved yet.
            values = dict(status="assessing", ingest_next_at=now + INGEST_RETRY_WAITS[attempts - 1],
                          started_at=dr.started_at or now, last_message=err[:300])
        moved = cast(CursorResult, session.execute(
            update(AssessDomainRun)
            .where(col(AssessDomainRun.id) == dr_id, col(AssessDomainRun.ingest_attempts) == seen,
                   col(AssessDomainRun.status).not_in(TERMINAL_STATUSES))
            .values(ingest_attempts=attempts, **values)
            .execution_options(synchronize_session=False)
        )).rowcount
        session.commit()
        if moved:
            logger.warning("assess ingest attempt %d/%d failed for domain run %s: %s",
                           attempts, INGEST_MAX_ATTEMPTS, dr_id, err)

    async def run_forever(self) -> None:
        while True:
            try:
                await asyncio.to_thread(self.tick)
            except Exception:
                logger.exception("assess poller tick crashed")
            await asyncio.sleep(POLL_INTERVAL_S)
