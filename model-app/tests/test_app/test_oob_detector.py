"""Tests for oob_detector.py: out-of-band version detection and the on-demand
check cache.

Detection runs on the recording UC fake (``_drift``), whose
``_query_completed_versions`` seam holds the agent's registry rows; the real
query is checked against a statement fake for its failure modes.
"""

import os
import sys
from datetime import datetime, timedelta, timezone

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "..", "src", "app", "src"))
sys.path.insert(0, os.path.dirname(__file__))

import pytest
from unittest.mock import MagicMock

from databricks.sdk.service.sql import State
from sqlalchemy.pool import StaticPool
from sqlmodel import Session, SQLModel, create_engine

from vibe_modeling.backend.core._ids import session_id_to_bigint
from vibe_modeling.backend.core._sql import SqlStatementError
from vibe_modeling.backend.db_models import Business, MetamodelCleanup, ModelVersion, Run, RunOperation
from vibe_modeling.backend.oob_detector import (
    CHECK_MAX_AGE,
    CHECK_NOW_INTERVAL,
    IDLE_RETRY,
    SKIPPED_CHECK_FAILED,
    SKIPPED_NOT_CONFIGURED,
    SKIPPED_WAREHOUSE_NOT_RUNNING,
    OobCheckCache,
    OobDetector,
    oob_keys,
)

from _sql_fakes import FakeClock, response, ws_returning  # noqa: E402
from ._drift.fixtures import fake_uc, mock_model  # noqa: F401

CAT = "test_catalog"


@pytest.fixture
def engine():
    engine = create_engine(
        "sqlite://",
        connect_args={"check_same_thread": False},
        poolclass=StaticPool,
    )
    SQLModel.metadata.create_all(engine)
    return engine


def _business(session, name: str) -> Business:
    b = Business(name=name)
    session.add(b)
    session.flush()
    return b


def _version(session, business: Business, version: int, scope: str) -> ModelVersion:
    mv = ModelVersion(business_id=business.id, version=version, scope=scope, status="completed")
    session.add(mv)
    session.flush()
    return mv


def _agent(fake, name: str, version: int, scope: str, *, session_id=99, completed=True):
    fake.add_agent_version(CAT, name, version, scope, mock_model(), session_id=session_id,
                           completed=completed, write_model_json=False)


def _detect(engine, fake) -> list:
    with Session(engine) as session:
        return OobDetector(session, fake.ws, "wh").detect(CAT)


def _keys(found) -> set:
    return oob_keys(found)


class TestKeying:

    def test_existing_business_matched_by_segment(self, engine, fake_uc):
        """"WT-Base" is stored by the agent as ``Wt_Base``; its known v1 is not
        reported, its unknown v2 is, on the business."""
        with Session(engine) as session:
            b = _business(session, "WT-Base")
            _version(session, b, 1, "mvm")
            session.commit()
            bid = b.id
        _agent(fake_uc, "WT-Base", 1, "mvm")
        _agent(fake_uc, "WT-Base", 2, "mvm")

        (found,) = _detect(engine, fake_uc)

        assert found.business_segment == "wt_base"
        assert found.status == "existing"
        assert found.business_id == bid
        assert [(v.version, v.scope) for v in found.versions] == [(2, "mvm")]

    def test_scope_is_part_of_the_key(self, engine, fake_uc):
        with Session(engine) as session:
            _version(session, _business(session, "Acme"), 4, "ecm")
            session.commit()
        _agent(fake_uc, "Acme", 4, "ecm")
        _agent(fake_uc, "Acme", 4, "mvm")

        assert _keys(_detect(engine, fake_uc)) == {("acme", 4, "mvm")}

    def test_prefixed_version_and_long_scope_rows(self, engine, fake_uc):
        fake_uc.add_rows(CAT, "business", [{
            "business": "Acme", "version": "v3", "model_scope": "Minimum Viable Model - MVM",
            "completion_date": "2024-01-01", "completed_percent": "100", "session_id": "5",
        }])
        assert _keys(_detect(engine, fake_uc)) == {("acme", 3, "mvm")}

    def test_new_and_ambiguous_segments(self, engine, fake_uc):
        with Session(engine) as session:
            a = _business(session, "WT Base")
            b = _business(session, "WT-Base")
            session.commit()
            ids = sorted([a.id, b.id])
        _agent(fake_uc, "WT-Base", 1, "mvm")
        _agent(fake_uc, "Brand New", 1, "ecm")

        found = {f.business_segment: f for f in _detect(engine, fake_uc)}

        assert found["brand_new"].status == "new"
        assert found["brand_new"].business_id is None
        assert found["wt_base"].status == "ambiguous"
        assert found["wt_base"].business_id is None
        assert sorted(found["wt_base"].candidate_business_ids) == ids

    def test_incomplete_rows_are_not_reported(self, engine, fake_uc):
        _agent(fake_uc, "Acme", 1, "mvm", completed=False)
        assert _detect(engine, fake_uc) == []

    def test_missing_registry_table_is_nothing_to_import(self, engine, fake_uc):
        assert _detect(engine, fake_uc) == []


class TestExclusions:

    @pytest.mark.parametrize("where", ["run", "run_bigint", "operation"])
    def test_app_sessions_are_excluded(self, engine, fake_uc, where):
        """A row written by an app run (its session id as the agent's BIGINT)
        is the app's, also when Lakebase lost the version."""
        sid = "7d1c4f3e-0000-4000-8000-000000000001"
        with Session(engine) as session:
            b = _business(session, "Acme")
            run = Run(business_id=b.id, status="failed",
                      vibe_session_id=sid if where == "run" else None,
                      vibe_session_id_bigint=session_id_to_bigint(sid) if where == "run_bigint" else None)
            session.add(run)
            session.flush()
            if where == "operation":
                session.add(RunOperation(run_id=run.id, step_index=0, operation_name="vibe modeling of version",
                                         vibe_session_id=sid))
            session.commit()
        _agent(fake_uc, "Acme", 1, "mvm", session_id=session_id_to_bigint(sid))
        _agent(fake_uc, "Acme", 2, "mvm", session_id=12345)

        assert _keys(_detect(engine, fake_uc)) == {("acme", 2, "mvm")}

    @pytest.mark.parametrize("session_id", [0, None])
    def test_app_registry_writes_are_ignored(self, engine, fake_uc, session_id):
        """Imports write session 0; the Delta mirror of a synced version
        writes no session id."""
        _agent(fake_uc, "Acme", 1, "mvm", session_id=session_id)
        assert _detect(engine, fake_uc) == []

    @pytest.mark.parametrize("status,ignored", [("pending", True), ("failed", True), ("done", False)])
    def test_open_cleanups_are_ignored(self, engine, fake_uc, status, ignored):
        with Session(engine) as session:
            _business(session, "Acme")
            session.add(MetamodelCleanup(business_segment="acme", version=1, scope="mvm", catalog=CAT,
                                         reason="version_delete", status=status))
            session.add(MetamodelCleanup(business_segment="acme", version=2, scope="mvm", catalog="other",
                                         reason="version_delete", status="pending"))
            session.commit()
        _agent(fake_uc, "Acme", 1, "mvm")
        _agent(fake_uc, "Acme", 2, "mvm")

        expected = {("acme", 2, "mvm")} if ignored else {("acme", 1, "mvm"), ("acme", 2, "mvm")}
        assert _keys(_detect(engine, fake_uc)) == expected

    def test_business_with_a_run_in_flight_is_skipped(self, engine, fake_uc):
        with Session(engine) as session:
            b = _business(session, "Acme")
            session.add(Run(business_id=b.id, status="running"))
            session.commit()
        _agent(fake_uc, "Acme", 1, "mvm")
        _agent(fake_uc, "Other", 1, "mvm")

        assert _keys(_detect(engine, fake_uc)) == {("other", 1, "mvm")}


class TestRefusedAndCleanupKeys:

    def test_a_row_waiting_for_the_registry_migration_is_listed_refused(self, engine, fake_uc):
        _agent(fake_uc, "Acme", 1, "mvm")
        _agent(fake_uc, "Acme", 2, "mvm")
        for row in fake_uc._registry[CAT]["business"]:
            if row["version"] == "2":
                row["completed_percent"] = None

        (found,) = _detect(engine, fake_uc)

        reasons = {(v.version, v.scope): v.refused_reason for v in found.versions}
        assert reasons[(1, "mvm")] is None
        assert reasons[(2, "mvm")].startswith("Waiting for the agent's registry migration")

    @pytest.mark.parametrize("stored", ["Acme Co", "acme_co", "Acme_Co"])
    def test_cleanup_rows_match_on_the_agent_segment(self, engine, fake_uc, stored):
        """The cleanup writer (A2b) keys a row on the business's agent segment;
        the detector compares through the same ``agent_business_segment`` that
        ``metamodel_row_key`` applies to the agent's ``Acme_Co``."""
        from vibe_modeling.backend._query_helpers import metamodel_row_key
        from vibe_modeling.backend.core._names import agent_business_segment

        assert metamodel_row_key({"business": "Acme_Co", "version": "1", "model_scope": "mvm"}) == (
            agent_business_segment("Acme Co"), 1, "mvm",
        )
        with Session(engine) as session:
            _business(session, "Acme Co")
            session.add(MetamodelCleanup(business_segment=stored, version=1, scope="MVM", catalog=CAT,
                                         reason="business_delete", status="pending"))
            session.commit()
        _agent(fake_uc, "Acme Co", 1, "mvm")
        assert _detect(engine, fake_uc) == []


class TestQuery:
    """The real scan against a statement fake."""

    def test_selects_session_id_and_completed_rows(self, engine):
        ws = ws_returning(response(
            [["Acme", "1", "mvm", "2024-01-01", "8"]],
            columns=["business", "version", "model_scope", "completion_date", "session_id"],
        ))
        with Session(engine) as session:
            found = OobDetector(session, ws, "wh").detect(CAT)
        assert _keys(found) == {("acme", 1, "mvm")}
        (sql,) = ws.statements
        assert "CAST(session_id AS STRING) as session_id" in sql
        assert f"FROM `{CAT}`.`_metamodel`.`business`" in sql

    def test_missing_table_status(self, engine):
        ws = ws_returning(response(
            error="[TABLE_OR_VIEW_NOT_FOUND] The table `c`.`_metamodel`.`business` cannot be found"
        ))
        with Session(engine) as session:
            assert OobDetector(session, ws, "wh").detect("c") == []

    def test_other_sql_error_raises(self, engine):
        ws = ws_returning(response(error="[INSUFFICIENT_PERMISSIONS] denied"))
        with Session(engine) as session:
            with pytest.raises(SqlStatementError) as ei:
                OobDetector(session, ws, "wh").detect("c")
        assert "INSUFFICIENT_PERMISSIONS" in ei.value.message

    def test_in_request_scan_fails_fast(self, engine):
        """``timeout_s=None`` (the import routes): one 30 s server wait, then
        an error, never "nothing missing"."""
        ws = ws_returning(response(state="PENDING", statement_id="s1"))
        with Session(engine) as session:
            with pytest.raises(SqlStatementError) as ei:
                OobDetector(session, ws, "wh", timeout_s=None).detect("c")
        assert ei.value.state == "TIMEOUT"
        assert ws.waits == ["30s"]

    def test_background_scan_is_bounded(self, engine, monkeypatch):
        clock = FakeClock().install(monkeypatch)
        ws = ws_returning(response(state="PENDING", statement_id="s1"), clock=clock, poll_cost_s=5.0)
        with Session(engine) as session:
            with pytest.raises(SqlStatementError) as ei:
                OobDetector(session, ws, "wh").detect("c")
        assert ei.value.state == "TIMEOUT"
        assert 150 < clock.elapsed < 190


class _Clock:
    def __init__(self):
        self.now = datetime(2026, 10, 1, 12, 0, tzinfo=timezone.utc)

    def __call__(self):
        return self.now

    def advance(self, delta: timedelta):
        self.now += delta


class _Deferred:
    """A spawn that keeps the check until the test runs it."""

    def __init__(self):
        self.pending: list = []

    def __call__(self, fn):
        self.pending.append(fn)

    def run_all(self):
        while self.pending:
            self.pending.pop(0)()


def _ws(state=State.RUNNING):
    ws = MagicMock()
    ws.warehouses.get.return_value.state = state
    return ws


@pytest.fixture
def scans(monkeypatch):
    """Replaces the scan with one that records the catalog and finds nothing."""
    calls: list[str] = []

    def detect(self, catalog):
        calls.append(catalog)
        return []

    monkeypatch.setattr(OobDetector, "detect", detect)
    return calls


class TestCheckCache:

    def test_not_configured_starts_nothing(self, engine, scans):
        spawn = _Deferred()
        cache = OobCheckCache(spawn=spawn, now=_Clock())
        cache.refresh_if_stale(engine, _ws(), "", CAT)
        assert spawn.pending == []
        assert cache.summary(CAT).skipped_reason == SKIPPED_NOT_CONFIGURED

    def test_idle_warehouse_is_not_queried(self, engine, scans):
        ws = _ws(State.STOPPED)
        cache = OobCheckCache(spawn=lambda fn: fn(), now=_Clock())
        cache.refresh_if_stale(engine, ws, "wh", CAT)
        summary = cache.summary(CAT)
        assert summary.skipped_reason == SKIPPED_WAREHOUSE_NOT_RUNNING
        assert summary.checked_at is None
        assert scans == []
        ws.statement_execution.execute_statement.assert_not_called()

    def test_idle_retry_waits_a_minute(self, engine, scans):
        ws = _ws(State.STOPPED)
        clock = _Clock()
        cache = OobCheckCache(spawn=lambda fn: fn(), now=clock)
        cache.refresh_if_stale(engine, ws, "wh", CAT)
        clock.advance(IDLE_RETRY - timedelta(seconds=1))
        cache.refresh_if_stale(engine, ws, "wh", CAT)
        assert ws.warehouses.get.call_count == 1
        clock.advance(timedelta(seconds=2))
        cache.refresh_if_stale(engine, ws, "wh", CAT)
        assert ws.warehouses.get.call_count == 2

    def test_running_warehouse_checks_and_caches_for_15_minutes(self, engine, scans):
        clock = _Clock()
        cache = OobCheckCache(spawn=lambda fn: fn(), now=clock)
        cache.refresh_if_stale(engine, _ws(), "wh", CAT)
        assert scans == [CAT]
        assert cache.summary(CAT).checked_at == clock.now
        clock.advance(CHECK_MAX_AGE - timedelta(seconds=1))
        cache.refresh_if_stale(engine, _ws(), "wh", CAT)
        assert scans == [CAT]
        clock.advance(timedelta(seconds=2))
        cache.refresh_if_stale(engine, _ws(), "wh", CAT)
        assert scans == [CAT, CAT]

    def test_one_check_at_a_time_and_summary_says_checking(self, engine, scans):
        spawn = _Deferred()
        cache = OobCheckCache(spawn=spawn, now=_Clock())
        cache.refresh_if_stale(engine, _ws(), "wh", CAT)
        cache.refresh_if_stale(engine, _ws(), "wh", CAT)
        assert len(spawn.pending) == 1
        assert cache.summary(CAT).checking is True
        spawn.run_all()
        assert cache.summary(CAT).checking is False

    def test_check_now_may_wake_and_is_rate_limited(self, engine, scans):
        ws = _ws(State.STOPPED)
        clock = _Clock()
        cache = OobCheckCache(spawn=lambda fn: fn(), now=clock)
        assert cache.check_now(engine, ws, "wh", CAT) is None
        assert scans == [CAT]
        ws.warehouses.get.assert_not_called()
        clock.advance(timedelta(seconds=20))
        assert cache.check_now(engine, ws, "wh", CAT) == 40
        assert scans == [CAT]
        clock.advance(CHECK_NOW_INTERVAL)
        assert cache.check_now(engine, ws, "wh", CAT) is None
        assert scans == [CAT, CAT]

    def test_check_now_during_a_page_load_check_wakes_after_it(self, engine, scans):
        """A page-load check that finds the warehouse stopped is followed by
        the waking check the user asked for."""
        spawn = _Deferred()
        ws = _ws(State.STOPPED)
        cache = OobCheckCache(spawn=spawn, now=_Clock())
        cache.refresh_if_stale(engine, ws, "wh", CAT)
        assert cache.check_now(engine, ws, "wh", CAT) is None
        assert len(spawn.pending) == 1
        spawn.run_all()
        assert scans == [CAT]
        summary = cache.summary(CAT)
        assert summary.skipped_reason is None and summary.checked_at is not None
        assert summary.checking is False

    def test_failed_check_keeps_the_previous_result(self, engine, monkeypatch):
        clock = _Clock()
        cache = OobCheckCache(spawn=lambda fn: fn(), now=clock)
        cache.check_now(engine, _ws(), "wh", CAT)
        first = cache.summary(CAT).checked_at

        def boom(self, catalog):
            raise SqlStatementError("FAILED", "warehouse gone")

        monkeypatch.setattr(OobDetector, "detect", boom)
        clock.advance(CHECK_MAX_AGE * 2)
        cache.refresh_if_stale(engine, _ws(), "wh", CAT)
        summary = cache.summary(CAT)
        assert summary.skipped_reason == SKIPPED_CHECK_FAILED
        assert summary.checked_at == first

    def test_another_catalog_reads_as_never_checked(self, engine, scans):
        cache = OobCheckCache(spawn=lambda fn: fn(), now=_Clock())
        cache.refresh_if_stale(engine, _ws(), "wh", CAT)
        assert cache.summary("other").checked_at is None
        cache.refresh_if_stale(engine, _ws(), "wh", "other")
        assert scans == [CAT, "other"]
