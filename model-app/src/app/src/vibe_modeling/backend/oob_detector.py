"""Out-of-band versions: completed agent versions in ``_metamodel`` that the
app does not know, found on demand and cached in the process.

:class:`OobDetector` scans ``<catalog>._metamodel.business`` once and keys
each completed row on ``(agent_business_segment, version, normalize_scope)``,
the key the agent writes. :class:`OobRowRule` holds the row part of the
rule (the first, second and fourth items below), shared with the
orphan-schema drop. A row is not out-of-band when:

- its ``session_id`` is 0 or NULL (the app's own registry writes: imports
  and the Delta mirror of synced versions);
- its ``session_id`` is one the app minted for a Run or RunOperation
  (``session_id_to_bigint``), in any business, so a renamed business's runs
  still count as the app's. A repair of an app run in the Jobs UI keeps the
  run's session id, so a version only that repair finished is taken for the
  app's and not listed; an import from its Volume recovers it;
- Lakebase has the version for the business the segment resolves to;
- a ``metamodel_cleanups`` row for that key and catalog is ``pending`` or
  ``failed`` (the app deleted the version and its rows are still there);
- the business it resolves to has a run in flight.

A segment that resolves to no business is ``new``, to one business
``existing``, to several ``ambiguous`` (import is refused for it). A finished
row whose ``completed_percent`` is still NULL (the oldest registry tables) is
listed with a ``refused_reason``; so is a version an import refused for a
lasting reason, which the cache remembers for the catalog until it imports.

:class:`OobCheckCache` decides when the scan runs. There is no timer: a page
load asks for a refresh when the cached result is older than
:data:`CHECK_MAX_AGE`, and the refresh runs only when the warehouse is already
``RUNNING`` (``ws.warehouses.get`` does not start it). "Check now" may start
the warehouse and is limited to one per :data:`CHECK_NOW_INTERVAL`. Both run
on a daemon thread with their own database session. The cache is per process.
"""

from __future__ import annotations

import logging
import threading
from collections.abc import Callable
from dataclasses import dataclass, field
from datetime import datetime, timedelta, timezone
from typing import Any, Optional

from databricks.sdk import WorkspaceClient
from sqlalchemy.engine import Engine
from sqlmodel import Session, col, select

from ._query_helpers import businesses_by_segment, metamodel_row_key
from .core._ids import session_id_to_bigint
from .core._metamodel_cleanups import UNFINISHED_STATUSES
from .core._names import agent_business_segment, normalize_scope
from .core._runs import IN_FLIGHT_RUN_STATUSES
from .core._sql import rows
from .db_models import MetamodelCleanup, ModelVersion, Run, RunOperation
from .initial_sync import WAITING_FOR_MIGRATION
from .models import OobBusinessOut, OobSummaryOut, OobVersionOut

logger = logging.getLogger(__name__)

CHECK_MAX_AGE = timedelta(minutes=15)
"""A page load refreshes a cached result older than this."""

CHECK_NOW_INTERVAL = timedelta(minutes=1)
"""At most one "Check now" per this interval."""

IDLE_RETRY = timedelta(minutes=1)
"""After a page-load check was skipped (warehouse not running) or failed,
the next page load waits this long before asking the warehouse again."""

SCAN_TIMEOUT_S = 180.0
"""Bound of the scan query; covers a warehouse that "Check now" starts."""

SKIPPED_NOT_CONFIGURED = "not_configured"
SKIPPED_WAREHOUSE_NOT_RUNNING = "warehouse_not_running"
SKIPPED_CHECK_FAILED = "check_failed"

OobKey = tuple[str, int, str]
"""``(business_segment, version, scope)``."""


class OobDetector:
    """Finds completed ``_metamodel`` versions that the app does not know."""

    def __init__(
        self,
        session: Session,
        ws: WorkspaceClient,
        warehouse_id: str,
        *,
        timeout_s: Optional[float] = SCAN_TIMEOUT_S,
    ):
        self._session = session
        self._ws = ws
        self._warehouse_id = warehouse_id
        self._timeout_s = timeout_s

    def detect(self, catalog: str) -> list[OobBusinessOut]:
        """Out-of-band versions in ``catalog`` grouped by business segment,
        sorted by segment, versions by ``(version, scope)``. ``[]`` when the
        registry table does not exist. A failed query raises
        ``SqlStatementError``."""
        delta_rows = self._query_completed_versions(catalog)
        if not delta_rows:
            return []

        by_segment = businesses_by_segment(self._session)
        known = self._known_versions()
        rule = OobRowRule.load(self._session, catalog)
        busy = self._businesses_with_active_runs()

        found: dict[str, dict[tuple[int, str], Optional[str]]] = {}
        for row in delta_rows:
            key = metamodel_row_key(row)
            if key is None:
                continue
            segment, version, scope = key
            if not rule.outside_app(key, row.get("session_id")):
                continue
            candidates = [b.id for b in by_segment.get(segment, [])]
            if any(bid in busy or (bid, version, scope) in known for bid in candidates):
                continue
            waiting = row.get("completed_percent") is None
            versions = found.setdefault(segment, {})
            if versions.get((version, scope), WAITING_FOR_MIGRATION) is not None:
                versions[(version, scope)] = WAITING_FOR_MIGRATION if waiting else None

        out: list[OobBusinessOut] = []
        for segment in sorted(found):
            candidates = [b.id for b in by_segment.get(segment, [])]
            status = "new" if not candidates else "existing" if len(candidates) == 1 else "ambiguous"
            out.append(OobBusinessOut(
                business_segment=segment,
                status=status,
                business_id=candidates[0] if status == "existing" else None,
                candidate_business_ids=candidates if status == "ambiguous" else [],
                versions=[
                    OobVersionOut(version=v, scope=s, refused_reason=reason)
                    for (v, s), reason in sorted(found[segment].items())
                ],
            ))
        return out

    def _query_completed_versions(self, catalog: str) -> Optional[list[dict]]:
        """Completed rows of ``_metamodel.business`` with their session id,
        and finished rows of the oldest tables whose ``completed_percent`` is
        still NULL (reported as waiting for the agent's migration).

        ``None`` when the table does not exist; any other SQL failure raises
        ``SqlStatementError``.
        """
        sql = (
            f"SELECT DISTINCT business, version, model_scope, "
            f"CAST(completion_date AS STRING) as completion_date, "
            f"CAST(session_id AS STRING) as session_id, "
            f"CAST(completed_percent AS STRING) as completed_percent "
            f"FROM `{catalog}`.`_metamodel`.`business` "
            f"WHERE (CAST(completed_percent AS DOUBLE) >= 100 OR completed_percent IS NULL) "
            f"AND completion_date IS NOT NULL "
            f"ORDER BY business, version"
        )
        return rows(
            self._ws, self._warehouse_id, sql,
            wait_timeout="30s", timeout_s=self._timeout_s,
            missing_table="none", as_dicts=True,
        )

    def _known_versions(self) -> set[tuple[str, int, str]]:
        """``(business_id, version, scope)`` of every Lakebase version."""
        stmt = select(ModelVersion.business_id, ModelVersion.version, ModelVersion.scope)
        return {(bid, ver, normalize_scope(scope or "")) for bid, ver, scope in self._session.exec(stmt).all()}

    def _businesses_with_active_runs(self) -> set[str]:
        stmt = select(Run.business_id).where(Run.status.in_(IN_FLIGHT_RUN_STATUSES))
        return set(self._session.exec(stmt).all())


def app_session_ids(session: Session) -> frozenset[int]:
    """The BIGINT session ids of every app Run and RunOperation."""
    ids: set[int] = set()
    for sid, sid_bigint in session.exec(select(Run.vibe_session_id, Run.vibe_session_id_bigint)).all():
        if sid_bigint:
            ids.add(int(sid_bigint))
        if sid:
            ids.add(session_id_to_bigint(sid))
    for sid in session.exec(select(RunOperation.vibe_session_id)).all():
        if sid:
            ids.add(session_id_to_bigint(sid))
    return frozenset(ids)


def open_cleanup_keys(session: Session, catalog: str) -> frozenset[OobKey]:
    """Keys with a ``pending`` or ``failed`` ``metamodel_cleanups`` row in
    ``catalog``: versions the app deleted whose registry rows are still there."""
    stmt = select(MetamodelCleanup).where(
        MetamodelCleanup.catalog == catalog,
        col(MetamodelCleanup.status).in_(UNFINISHED_STATUSES),
    )
    return frozenset(
        (agent_business_segment(c.business_segment), c.version, normalize_scope(c.scope or ""))
        for c in session.exec(stmt).all()
    )


@dataclass(frozen=True)
class OobRowRule:
    """The one rule for whether a ``_metamodel.business`` row was written by
    an agent run the app did not launch: a non-zero ``session_id`` that is no
    app Run's or RunOperation's, for a key without an open cleanup in the
    catalog. Used by :class:`OobDetector` (such a version is importable) and
    by the orphan-schema drop (such a version's schemas are not orphans)."""

    app_sessions: frozenset[int]
    open_cleanups: frozenset[OobKey]

    @classmethod
    def load(cls, session: Session, catalog: str) -> "OobRowRule":
        return cls(app_session_ids(session), open_cleanup_keys(session, catalog))

    def outside_app(self, key: OobKey, session_id: Any) -> bool:
        sid = _session_id(session_id)
        return bool(sid) and sid not in self.app_sessions and key not in self.open_cleanups


def _session_id(value: Any) -> int:
    """The row's session id as an int; 0 for NULL or a non-numeric value."""
    try:
        return int(str(value).strip())
    except (TypeError, ValueError):
        return 0


def oob_keys(businesses: list[OobBusinessOut]) -> set[OobKey]:
    """The ``(segment, version, scope)`` keys of a detection result."""
    return {(b.business_segment, v.version, v.scope) for b in businesses for v in b.versions}


def warehouse_is_running(ws: WorkspaceClient, warehouse_id: str) -> bool:
    """Whether the warehouse is ``RUNNING`` now. Reading the state does not
    start it."""
    state = ws.warehouses.get(warehouse_id).state
    return getattr(state, "value", state) == "RUNNING"


def _spawn_daemon(target: Callable[[], None]) -> None:
    threading.Thread(target=target, name="oob-check", daemon=True).start()


def _utc_now() -> datetime:
    return datetime.now(timezone.utc)


@dataclass
class _CacheState:
    catalog: str = ""
    checked_at: Optional[datetime] = None
    businesses: list[OobBusinessOut] = field(default_factory=list)
    skipped_reason: Optional[str] = None
    attempted_at: Optional[datetime] = None
    manual_at: Optional[datetime] = None
    in_flight: bool = False
    wake_after: bool = False


class OobCheckCache:
    """The last out-of-band check of this process and when to run the next.

    ``spawn`` runs a check off the request thread (a daemon thread; tests pass
    a synchronous runner). ``now`` is the clock.
    """

    def __init__(
        self,
        *,
        spawn: Callable[[Callable[[], None]], None] = _spawn_daemon,
        now: Callable[[], datetime] = _utc_now,
    ) -> None:
        self._lock = threading.Lock()
        self._state = _CacheState()
        self._refusals: dict[str, dict[OobKey, str]] = {}
        self._spawn = spawn
        self._now = now

    def summary(self, catalog: str) -> OobSummaryOut:
        """The cached result, empty when it was taken on another catalog."""
        with self._lock:
            st = self._state
            same = st.catalog == catalog
            return OobSummaryOut(
                checked_at=st.checked_at if same else None,
                catalog=catalog,
                skipped_reason=st.skipped_reason if same else None,
                businesses=self._labelled_locked(catalog, st.businesses) if same else [],
                checking=st.in_flight,
            )

    def refresh_if_stale(self, engine: Engine, ws: WorkspaceClient, warehouse_id: str, catalog: str) -> None:
        """Start a background check when the cached result is older than
        :data:`CHECK_MAX_AGE`; the check runs only on a warehouse that is
        already running."""
        with self._lock:
            st = self._state
            if not catalog or not warehouse_id:
                self._reset_locked(catalog)
                st = self._state
                st.skipped_reason = SKIPPED_NOT_CONFIGURED
                return
            if st.in_flight:
                return
            now = self._now()
            if st.catalog == catalog:
                if st.checked_at is not None and now - st.checked_at < CHECK_MAX_AGE:
                    return
                if st.attempted_at is not None and now - st.attempted_at < IDLE_RETRY:
                    return
            else:
                self._reset_locked(catalog)
            self._start_locked(now)
        self._spawn(lambda: self._run(engine, ws, warehouse_id, catalog, wake=False))

    def check_now(self, engine: Engine, ws: WorkspaceClient, warehouse_id: str, catalog: str) -> Optional[int]:
        """Start a check that may start the warehouse. Returns ``None`` when
        accepted (also when one is already running), else the seconds until
        the next "Check now" is allowed."""
        with self._lock:
            st = self._state
            now = self._now()
            if st.manual_at is not None and now - st.manual_at < CHECK_NOW_INTERVAL:
                return max(1, int((CHECK_NOW_INTERVAL - (now - st.manual_at)).total_seconds()))
            if st.catalog != catalog:
                self._reset_locked(catalog)
                st = self._state
            st.manual_at = now
            if st.in_flight:
                # The running check may be a page-load one that skips an idle
                # warehouse; a waking check follows it.
                st.wake_after = True
                return None
            self._start_locked(now)
        self._spawn(lambda: self._run(engine, ws, warehouse_id, catalog, wake=True))
        return None

    def store(self, catalog: str, businesses: list[OobBusinessOut]) -> None:
        """Record a result taken outside the cache (an import's fresh scan)."""
        with self._lock:
            if self._state.catalog != catalog:
                self._reset_locked(catalog)
            st = self._state
            st.businesses = list(businesses)
            st.checked_at = self._now()
            st.skipped_reason = None

    def record_import(
        self,
        catalog: str,
        found: list[OobBusinessOut],
        imported: list,
        refused: list[dict],
    ) -> None:
        """Store an import's fresh scan without the versions it imported, and
        remember the lasting refusals with their reason (the same input is
        refused on every retry). A version that failed for a reason that may
        pass on retry stays importable; the import's warnings carry it."""
        done = {(seg, int(v), sc) for seg, v, sc in imported}
        with self._lock:
            reasons = self._refusals.setdefault(catalog, {})
            for key in done:
                reasons.pop(key, None)
            for r in refused:
                if r.get("lasting"):
                    reasons[(r["business_segment"], int(r["version"]), r["scope"])] = r["reason"]
        remaining = []
        for b in found:
            versions = [v for v in b.versions if (b.business_segment, v.version, v.scope) not in done]
            if versions:
                remaining.append(b.model_copy(update={"versions": versions}))
        self.store(catalog, remaining)

    def _labelled_locked(self, catalog: str, businesses: list[OobBusinessOut]) -> list[OobBusinessOut]:
        reasons = self._refusals.get(catalog, {})
        out = []
        for b in businesses:
            versions = [
                v if v.refused_reason or (b.business_segment, v.version, v.scope) not in reasons
                else v.model_copy(update={"refused_reason": reasons[(b.business_segment, v.version, v.scope)]})
                for v in b.versions
            ]
            out.append(b.model_copy(update={"versions": versions}))
        return out

    def _reset_locked(self, catalog: str) -> None:
        st = self._state
        self._state = _CacheState(
            catalog=catalog, manual_at=st.manual_at, in_flight=st.in_flight, wake_after=st.wake_after,
        )

    def _start_locked(self, now: datetime) -> None:
        self._state.in_flight = True
        self._state.attempted_at = now

    def _run(self, engine: Engine, ws: WorkspaceClient, warehouse_id: str, catalog: str, *, wake: bool) -> None:
        businesses: Optional[list[OobBusinessOut]] = None
        reason: Optional[str] = None
        try:
            if not wake and not warehouse_is_running(ws, warehouse_id):
                reason = SKIPPED_WAREHOUSE_NOT_RUNNING
            else:
                with Session(engine) as session:
                    businesses = OobDetector(session, ws, warehouse_id).detect(catalog)
        except Exception:
            logger.warning("Out-of-band check of catalog %s failed", catalog, exc_info=True)
            reason = SKIPPED_CHECK_FAILED
        with self._lock:
            st = self._state
            st.in_flight = False
            follow_up = st.wake_after and not wake
            st.wake_after = False
            if st.catalog != catalog:
                return
            st.skipped_reason = reason
            if businesses is not None:
                st.businesses = businesses
                st.checked_at = self._now()
            if follow_up:
                self._start_locked(self._now())
        if follow_up:
            self._spawn(lambda: self._run(engine, ws, warehouse_id, catalog, wake=True))


OOB_CHECKS = OobCheckCache()
"""The process-wide cache the routes use."""
