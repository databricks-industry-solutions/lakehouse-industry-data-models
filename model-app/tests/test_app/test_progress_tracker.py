"""Tests for ProgressTracker — async per-run polling orchestration."""

import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "..", "src", "app", "src"))

import asyncio
import json
from contextlib import contextmanager
from datetime import datetime, timedelta, timezone
from unittest.mock import AsyncMock, MagicMock, patch

import pytest
from sqlalchemy.pool import StaticPool
from sqlmodel import Session, SQLModel, create_engine, select

from vibe_modeling.backend.core._config import AppConfig
from vibe_modeling.backend.db_models import (
    AgentConfig,
    Business,
    ModelVersion,
    Run,
    RunOperation,
    RunProgressEvent,
)
from vibe_modeling.backend.progress_tracker import (
    ProgressEvent,
    ProgressTracker,
    SessionStatus,
    STALE_THRESHOLD_MINUTES,
    WATCHDOG_WARM_UP_SECONDS,
    _normalize_status,
)


# ---------------------------------------------------------------------------
# Fixtures
# ---------------------------------------------------------------------------

@pytest.fixture
def engine():
    engine = create_engine(
        "sqlite://",
        connect_args={"check_same_thread": False},
        poolclass=StaticPool,
    )
    SQLModel.metadata.create_all(engine)
    return engine


@pytest.fixture
def session_factory(engine):
    """Returns a context-manager factory that yields SQLModel Sessions."""
    @contextmanager
    def _factory():
        with Session(engine) as session:
            yield session
    return _factory


@pytest.fixture
def mock_ws():
    ws = MagicMock()
    ws.config.host = "https://test-workspace.databricks.com"
    # Default the Jobs API to TERMINATED/SUCCESS so tests that don't care
    # about Jobs API state still pass. Production code now waits for the
    # Jobs API to report TERMINATED before firing post-run sync (the agent's
    # `completion_date` alone is not enough, see progress_tracker._poll_delta).
    # Tests that do care about Jobs API state (termination-fallback,
    # _poll_jobs_api) override this return_value explicitly.
    _default_job_run = MagicMock()
    _default_job_run.state.life_cycle_state.value = "TERMINATED"
    _default_job_run.state.result_state.value = "SUCCESS"
    _default_job_run.state.state_message = ""
    ws.jobs.get_run.return_value = _default_job_run
    return ws


@pytest.fixture
def config():
    return AppConfig(app_name="test", warehouse_id="test-warehouse-id", poll_interval_seconds=0)


@pytest.fixture
def tracker(mock_ws, config, session_factory):
    return ProgressTracker(ws=mock_ws, config=config, session_factory=session_factory)


@pytest.fixture
def seed_business(engine) -> str:
    with Session(engine) as s:
        b = Business(name="Test Corp", description="test", industry_alignment="Retail")
        s.add(b)
        s.commit()
        s.refresh(b)
        return b.id


_INTENT_FROM_RUN_TYPE = {
    "new base model": "new-base-model",
    "vibe modeling of version": "vibe-iterate",
    "install model": "install",
    "uninstall model": "uninstall",
    "uninstall model version": "uninstall",
    "generate samples": "generate-samples",
    "generate sample data": "generate-samples",
    "import from volume": "import-from-volume",
    "snapshot version": "snapshot",
    "shrink": "shrink",
    "enlarge": "enlarge",
    "revert model version": "revert",
}


def _make_run(business_id: str, **overrides) -> Run:
    """Helper to build a Run with sensible defaults."""
    # Back-compat shim: tests still pass `run_type=...`; translate to
    # `intent=...` for the post–Phase-5 schema.
    if "run_type" in overrides:
        legacy = overrides.pop("run_type")
        overrides.setdefault("intent", _INTENT_FROM_RUN_TYPE.get(legacy, legacy))
    defaults = dict(
        business_id=business_id,
        intent="new-base-model",
        status="running",
        databricks_run_id=12345,
        vibe_session_id="sid-1",
        vibe_session_id_bigint=99999,
        started_at=datetime.now(timezone.utc),
        parameters_json=json.dumps({
            "operation": "new base model",
            "deployment_catalog": "test_cat",
        }),
    )
    defaults.update(overrides)
    return Run(**defaults)


class TestSyncOrchProgressEvents:
    """``_sync_orch_progress_events`` mirrors agent ``_vibe_progress``
    rows into Lakebase for orchestrator-routed runs and computes the
    overall progress bar by distributing each step's slice
    proportionally across the DAG.
    """

    def _seed(self, engine, seed_business, *, ops_status, with_event=True):
        """Create a Run + ``ops_status`` RunOperation rows.

        ``ops_status`` is a list of (operation_name, status) tuples;
        step_index is implicit from list order. By default also seeds
        a RunProgressEvent so the bar-gate is unlocked (the bar holds
        at 1% until at least one event exists in Lakebase). Tests that
        specifically validate the gate behaviour pass with_event=False.
        """
        with Session(engine) as s:
            run = _make_run(seed_business)
            s.add(run)
            s.flush()
            for idx, (name, status) in enumerate(ops_status):
                s.add(
                    RunOperation(
                        run_id=run.id,
                        step_index=idx,
                        operation_name=name,
                        params_json="{}",
                        status=status,
                    )
                )
            if with_event:
                s.add(RunProgressEvent(
                    run_id=run.id,
                    step_id=1,
                    event_seq=1,
                    stage_name="Vibe Session",
                    step_name="Session Started",
                    status="stage_in_progress",
                    message="seeded for bar-gate",
                    progress_increment=0.0,
                    result_json="{}",
                ))
            s.commit()
            return run.id

    def test_two_step_dag_running_in_step0_at_50pct(
        self, tracker, engine, seed_business
    ):
        """Phase 4.5 walkthrough finding: a 2-step pipeline (ECM +
        MVM) was reporting an overall ``progress_percent`` that was a
        1:1 copy of the agent's per-step %. End of ECM (agent 100%)
        shows 100% on the bar; start of MVM (agent 0%) drops the bar
        back to 0% (or, with the older indicator, back to 50%).

        Proportional distribution maps step 0's 50% → overall 25%.
        """
        run_id = self._seed(
            engine, seed_business,
            ops_status=[("generate_ecm", "running"), ("shrink_to_mvm", "pending")],
        )
        status = SessionStatus(
            session_id=99999,
            processing_status="ready",
            completed_percent=50.0,
            last_updated_at="2026-04-26T00:00:01Z",
            business="test", version="v1", model_scope="ecm",
        )
        with patch.object(tracker, "_poll_session_status_by_id", return_value=status), \
             patch.object(tracker, "_poll_progress_events", return_value=[]), \
             patch.object(tracker, "_acknowledge_batch"), \
             Session(engine) as s:
            run = s.get(Run, run_id)
            tracker._sync_orch_progress_events(run, s)
            s.commit()
            s.refresh(run)
        # 2 phases, phase 0 running at 50% → overall ≈ (0 + 0.5) / 2 = 25.
        assert run.progress_percent == 25, run.progress_percent
        assert "Phase 1/2" in run.progress_message, run.progress_message

    def test_two_step_dag_step0_done_step1_at_50pct(
        self, tracker, engine, seed_business
    ):
        """Step 0 done, step 1 running at 50% → overall = 75% (not 50%
        and not 100%)."""
        run_id = self._seed(
            engine, seed_business,
            ops_status=[("generate_ecm", "succeeded"), ("shrink_to_mvm", "running")],
        )
        status = SessionStatus(
            session_id=99999,
            processing_status="ready",
            completed_percent=50.0,
            last_updated_at="2026-04-26T00:00:01Z",
            business="test", version="v1", model_scope="mvm",
        )
        with patch.object(tracker, "_poll_session_status_by_id", return_value=status), \
             patch.object(tracker, "_poll_progress_events", return_value=[]), \
             patch.object(tracker, "_acknowledge_batch"), \
             Session(engine) as s:
            run = s.get(Run, run_id)
            tracker._sync_orch_progress_events(run, s)
            s.commit()
            s.refresh(run)
        assert run.progress_percent == 75, run.progress_percent
        assert "Phase 2/2" in run.progress_message

    def test_progress_never_decreases(
        self, tracker, engine, seed_business
    ):
        """Stale agent reports must not cause the bar to drop. If the
        Run already has a higher ``progress_percent`` than what the
        agent reports right now, hold steady."""
        run_id = self._seed(
            engine, seed_business,
            ops_status=[("generate_ecm", "running"), ("shrink_to_mvm", "pending")],
        )
        with Session(engine) as s:
            run = s.get(Run, run_id)
            run.progress_percent = 40
            s.add(run)
            s.commit()

        # Agent reports a stale 10% (lower than the persisted 40%).
        status = SessionStatus(
            session_id=99999,
            processing_status="ready",
            completed_percent=10.0,
            last_updated_at="2026-04-26T00:00:01Z",
            business="test", version="v1", model_scope="ecm",
        )
        with patch.object(tracker, "_poll_session_status_by_id", return_value=status), \
             patch.object(tracker, "_poll_progress_events", return_value=[]), \
             patch.object(tracker, "_acknowledge_batch"), \
             Session(engine) as s:
            run = s.get(Run, run_id)
            tracker._sync_orch_progress_events(run, s)
            s.commit()
            s.refresh(run)
        assert run.progress_percent == 40, run.progress_percent


class TestSessionEndedFinalization:
    """When the agent emits a terminal ``Vibe Session / Session Ended``
    event, ``_sync_orch_progress_events`` must call
    ``_finalize_session_completion`` to repair a sub-100
    ``completed_percent`` left by partial metric-view compile failures.
    On normal happy-path runs (no Session Ended event in this poll) the
    finalize call must NOT fire — regression coverage so the warning
    fix doesn't disrupt steady-state progress polling.
    """

    def _seed(self, engine, seed_business):
        with Session(engine) as s:
            run = _make_run(seed_business)
            s.add(run)
            s.flush()
            s.add(
                RunOperation(
                    run_id=run.id, step_index=0, operation_name="generate_ecm",
                    params_json="{}", status="running",
                )
            )
            s.add(RunProgressEvent(
                run_id=run.id, step_id=1, event_seq=1,
                stage_name="Vibe Session", step_name="Session Started",
                status="stage_in_progress", message="seeded",
                progress_increment=0.0, result_json="{}",
            ))
            s.commit()
            return run.id

    def test_session_ended_event_triggers_finalize(
        self, tracker, engine, seed_business
    ):
        run_id = self._seed(engine, seed_business)
        events = [
            ProgressEvent(step_id=100, event_seq=10, stage_name="Vibe Session",
                          step_name="Session Ended", status="completed",
                          message="Pipeline completed", progress_increment=1.0),
        ]
        status = SessionStatus(
            session_id=99999, processing_status="ready",
            completed_percent=99.0,
            last_updated_at="2026-04-27T00:00:01Z",
            business="Acme", version="1", model_scope="ecm",
        )
        with patch.object(tracker, "_poll_session_status_by_id", return_value=status), \
             patch.object(tracker, "_poll_progress_events", return_value=events), \
             patch.object(tracker, "_acknowledge_batch"), \
             patch.object(tracker, "_finalize_session_completion") as mock_finalize, \
             Session(engine) as s:
            run = s.get(Run, run_id)
            tracker._sync_orch_progress_events(run, s)
            s.commit()
        mock_finalize.assert_called_once()
        # Called with the catalog and session_id_bigint (positional).
        call_args = mock_finalize.call_args
        assert call_args.args[1] == 99999  # session_id_bigint

    def test_no_session_ended_event_does_not_finalize(
        self, tracker, engine, seed_business
    ):
        """Steady-state poll: in-progress events arrive, no Session Ended.
        ``_finalize_session_completion`` MUST NOT fire — regression so the
        fix doesn't disturb normal progress reporting."""
        run_id = self._seed(engine, seed_business)
        events = [
            ProgressEvent(step_id=100, event_seq=10,
                          stage_name="Designing Domains",
                          step_name="Domain Generation",
                          status="running", message="Working", progress_increment=2.0),
        ]
        status = SessionStatus(
            session_id=99999, processing_status="ready",
            completed_percent=40.0,
            last_updated_at="2026-04-27T00:00:01Z",
            business="Acme", version="1", model_scope="ecm",
        )
        with patch.object(tracker, "_poll_session_status_by_id", return_value=status), \
             patch.object(tracker, "_poll_progress_events", return_value=events), \
             patch.object(tracker, "_acknowledge_batch"), \
             patch.object(tracker, "_finalize_session_completion") as mock_finalize, \
             Session(engine) as s:
            run = s.get(Run, run_id)
            tracker._sync_orch_progress_events(run, s)
            s.commit()
        mock_finalize.assert_not_called()

    def test_warning_status_normalizes_to_warning(self):
        """``stage_warning`` must normalize to ``warning`` so the UI can
        render it distinctly. Regression: previously this status fell
        through to the unknown-status warned set and was passed verbatim."""
        from vibe_modeling.backend.progress_tracker import _normalize_status
        assert _normalize_status("stage_warning") == "warning"
        # Pre-existing mappings stay unchanged.
        assert _normalize_status("stage_started") == "running"
        assert _normalize_status("stage_succeeded") == "completed"
        assert _normalize_status("stage_failed") == "failed"

    def test_cursor_advances_on_event_seq_not_step_id(
        self, tracker, engine, seed_business
    ):
        """Two events with the SAME step_id but different event_seq must
        both be persisted, AND the cursor must advance to the highest
        event_seq (NOT the step_id). This is the regression for the
        2026-04-27 incident where ``Applying Metric Views`` had three
        events for one step_id (in_progress, stage_warning,
        stage_succeeded) and only the first reached Lakebase."""
        run_id = self._seed(engine, seed_business)
        # Three events sharing step_id=500, with ascending event_seq.
        events = [
            ProgressEvent(step_id=500, event_seq=20,
                          stage_name="Applying Metric Views",
                          step_name="Metric View Creation",
                          status="running",
                          message="Creating 22 metric views",
                          progress_increment=0.0),
            ProgressEvent(step_id=500, event_seq=21,
                          stage_name="Applying Metric Views",
                          step_name="Metric View Creation",
                          status="warning",
                          message="Created 15 metric views, 7 failed",
                          progress_increment=0.0,
                          result_json={"failed_views": 7, "succeeded_views": 15}),
            ProgressEvent(step_id=500, event_seq=22,
                          stage_name="Applying Metric Views",
                          step_name="Metric View Creation",
                          status="completed",
                          message="Step auto-completed during pipeline finalization",
                          progress_increment=0.0),
        ]
        status = SessionStatus(
            session_id=99999, processing_status="ready",
            completed_percent=99.0,
            last_updated_at="2026-04-27T00:00:01Z",
            business="Acme", version="1", model_scope="ecm",
        )
        with patch.object(tracker, "_poll_session_status_by_id", return_value=status), \
             patch.object(tracker, "_poll_progress_events", return_value=events), \
             patch.object(tracker, "_acknowledge_batch"), \
             patch.object(tracker, "_finalize_session_completion"), \
             Session(engine) as s:
            run = s.get(Run, run_id)
            tracker._sync_orch_progress_events(run, s)
            s.commit()
        with Session(engine) as s:
            pe_list = s.exec(
                select(RunProgressEvent)
                .where(RunProgressEvent.run_id == run_id)
                .where(RunProgressEvent.step_id == 500)
            ).all()
            assert len(pe_list) == 3, (
                "all three events for step_id=500 must be persisted; "
                "previously the cursor advanced past step_id and dropped events 21+22"
            )
            statuses = sorted(pe.status for pe in pe_list)
            assert statuses == ["completed", "running", "warning"]
            run = s.get(Run, run_id)
            # Cursor advances to highest event_seq (22), NOT step_id (500).
            assert run.last_consumed_step_id == 22


class TestProgressCappedAt99UntilTerminal:
    """``_sync_orch_progress_events`` caps ``run.progress_percent`` at 99
    while the run is still in a non-terminal status, even when the agent
    reports ``completed_percent == 100``. The orchestrator owns the
    final 100 — the bar must not advertise success before the
    orchestrator has flipped the run terminal. Regression for the cap
    branch at progress_tracker.py L996-L1000.
    """

    def _seed(self, engine, seed_business, *, run_status: str = "running"):
        """Single running RunOperation (so the function reaches the
        progress-update branch instead of early-returning), plus a
        seed event so the bar-gate is unlocked."""
        with Session(engine) as s:
            run = _make_run(seed_business, status=run_status)
            s.add(run)
            s.flush()
            s.add(RunOperation(
                run_id=run.id, step_index=0, operation_name="generate_ecm",
                params_json="{}", status="running",
            ))
            s.add(RunProgressEvent(
                run_id=run.id, step_id=1, event_seq=1,
                stage_name="Vibe Session", step_name="Session Started",
                status="stage_in_progress", message="seeded",
                progress_increment=0.0, result_json="{}",
            ))
            s.commit()
            return run.id

    def test_capped_at_99_while_running(self, tracker, engine, seed_business):
        """Agent reports 100% but run.status is 'running' — bar caps at 99."""
        run_id = self._seed(engine, seed_business, run_status="running")
        status = SessionStatus(
            session_id=99999, processing_status="ready",
            completed_percent=100.0,
            last_updated_at="2026-04-27T00:00:01Z",
            business="Acme", version="1", model_scope="ecm",
        )
        with patch.object(tracker, "_poll_session_status_by_id", return_value=status), \
             patch.object(tracker, "_poll_progress_events", return_value=[]), \
             patch.object(tracker, "_acknowledge_batch"), \
             Session(engine) as s:
            run = s.get(Run, run_id)
            tracker._sync_orch_progress_events(run, s)
            s.commit()
            s.refresh(run)
        assert run.progress_percent == 99, (
            f"running run with agent_pct=100 must cap at 99; got "
            f"{run.progress_percent}"
        )

    def test_session_ended_event_caps_at_99_while_running(
        self, tracker, engine, seed_business
    ):
        """Even when the agent emits a Session Ended event the cap holds
        until the orchestrator flips the run terminal."""
        run_id = self._seed(engine, seed_business, run_status="running")
        events = [
            ProgressEvent(step_id=100, event_seq=10, stage_name="Vibe Session",
                          step_name="Session Ended", status="completed",
                          message="Pipeline completed", progress_increment=1.0),
        ]
        status = SessionStatus(
            session_id=99999, processing_status="ready",
            completed_percent=100.0,
            last_updated_at="2026-04-27T00:00:01Z",
            business="Acme", version="1", model_scope="ecm",
        )
        with patch.object(tracker, "_poll_session_status_by_id", return_value=status), \
             patch.object(tracker, "_poll_progress_events", return_value=events), \
             patch.object(tracker, "_acknowledge_batch"), \
             patch.object(tracker, "_finalize_session_completion"), \
             Session(engine) as s:
            run = s.get(Run, run_id)
            tracker._sync_orch_progress_events(run, s)
            s.commit()
            s.refresh(run)
        assert run.progress_percent == 99, (
            f"Session Ended alone must not advance bar past 99 while "
            f"run.status='running'; got {run.progress_percent}"
        )

    def test_reaches_100_when_run_is_terminal(
        self, tracker, engine, seed_business
    ):
        """Once the orchestrator has flipped the run to a terminal
        status, the cap branch falls through and the bar can read 100."""
        run_id = self._seed(engine, seed_business, run_status="completed")
        status = SessionStatus(
            session_id=99999, processing_status="ready",
            completed_percent=100.0,
            last_updated_at="2026-04-27T00:00:01Z",
            business="Acme", version="1", model_scope="ecm",
        )
        with patch.object(tracker, "_poll_session_status_by_id", return_value=status), \
             patch.object(tracker, "_poll_progress_events", return_value=[]), \
             patch.object(tracker, "_acknowledge_batch"), \
             Session(engine) as s:
            run = s.get(Run, run_id)
            tracker._sync_orch_progress_events(run, s)
            s.commit()
            s.refresh(run)
        assert run.progress_percent == 100, (
            f"terminal run.status must allow bar to read 100; got "
            f"{run.progress_percent}"
        )


# ---------------------------------------------------------------------------
# 1. start_tracking / stop_tracking
# ---------------------------------------------------------------------------

class TestStartStopTracking:

    @pytest.mark.asyncio
    async def test_start_creates_task(self, tracker, engine, seed_business):
        with Session(engine) as s:
            run = _make_run(seed_business)
            s.add(run)
            s.commit()
            run_id = run.id

        with patch.object(tracker, "_poll_loop", new_callable=AsyncMock) as mock_poll:
            mock_poll.return_value = None
            tracker.start_tracking(run_id)

            assert run_id in tracker._tasks
            # Let the task actually start and finish
            await asyncio.sleep(0.05)

    @pytest.mark.asyncio
    async def test_start_idempotent(self, tracker, engine, seed_business):
        """Calling start_tracking twice doesn't duplicate."""
        with Session(engine) as s:
            run = _make_run(seed_business)
            s.add(run)
            s.commit()
            run_id = run.id

        with patch.object(tracker, "_poll_loop", new_callable=AsyncMock) as mock_poll:
            mock_poll.return_value = None
            tracker.start_tracking(run_id)
            first_task = tracker._tasks[run_id]
            tracker.start_tracking(run_id)
            assert tracker._tasks[run_id] is first_task
            await asyncio.sleep(0.05)

    @pytest.mark.asyncio
    async def test_stop_cancels_task(self, tracker, engine, seed_business):
        with Session(engine) as s:
            run = _make_run(seed_business)
            s.add(run)
            s.commit()
            run_id = run.id

        # Use a long-running coroutine so the task is still alive when we cancel
        async def hang_forever(rid):
            await asyncio.sleep(999)

        with patch.object(tracker, "_poll_loop", side_effect=hang_forever):
            tracker.start_tracking(run_id)
            await asyncio.sleep(0.05)
            tracker.stop_tracking(run_id)
            assert run_id not in tracker._tasks

    @pytest.mark.asyncio
    async def test_start_on_never_tracked_run_spawns_one(self, tracker):
        async def hang(rid):
            await asyncio.sleep(999)

        with patch.object(tracker, "_poll_loop", side_effect=hang) as mock_poll:
            tracker.start_tracking("never-tracked")
            assert mock_poll.call_count == 1
            assert not tracker._tasks["never-tracked"].done()
            tracker.stop_tracking("never-tracked")

    @pytest.mark.asyncio
    async def test_start_after_finished_loop_spawns_new_task(self, tracker):
        """Retry regression: a poll loop that returned (terminal run) leaves
        its done task in ``_tasks``; start_tracking must replace it."""
        with patch.object(tracker, "_poll_loop", new_callable=AsyncMock) as mock_poll:
            tracker.start_tracking("r1")
            first_task = tracker._tasks["r1"]
            await asyncio.sleep(0.05)
            assert first_task.done()

            tracker.start_tracking("r1")
            assert tracker._tasks["r1"] is not first_task
            assert mock_poll.call_count == 2
            await asyncio.sleep(0.05)

    @pytest.mark.asyncio
    async def test_start_while_loop_alive_does_not_double_poll(self, tracker):
        async def hang(rid):
            await asyncio.sleep(999)

        with patch.object(tracker, "_poll_loop", side_effect=hang) as mock_poll:
            tracker.start_tracking("r1")
            await asyncio.sleep(0.05)
            first_task = tracker._tasks["r1"]
            tracker.start_tracking("r1")
            assert tracker._tasks["r1"] is first_task
            assert mock_poll.call_count == 1
            tracker.stop_tracking("r1")

    @pytest.mark.asyncio
    async def test_start_after_cancelled_loop_spawns_new_task(self, tracker):
        async def hang(rid):
            await asyncio.sleep(999)

        with patch.object(tracker, "_poll_loop", side_effect=hang) as mock_poll:
            tracker.start_tracking("r1")
            first_task = tracker._tasks["r1"]
            await asyncio.sleep(0.05)
            # Cancelled without going through stop_tracking, so the entry stays.
            first_task.cancel()
            await asyncio.sleep(0.05)
            assert first_task.cancelled()

            tracker.start_tracking("r1")
            assert tracker._tasks["r1"] is not first_task
            assert mock_poll.call_count == 2
            tracker.stop_tracking("r1")

    @pytest.mark.asyncio
    async def test_resume_after_loop_ended_tracks_the_run_again(
        self, tracker, engine, seed_business,
    ):
        """Resume regression (``6hpx2hrXwcC4Wppq``): a run whose poll loop
        ended on its own (it failed) leaves a done task in ``_tasks``; the
        resume route must start a new poll loop for it."""
        from vibe_modeling.backend.router import _resume_run_impl

        with Session(engine) as s:
            run = _make_run(seed_business, status="running")
            s.add(run)
            s.commit()
            run_id = run.id

        def _resume(run, session):
            run.status = "running"
            session.add(run)

        with patch.object(tracker, "_poll_loop", new_callable=AsyncMock) as mock_poll:
            tracker.start_tracking(run_id)
            first_task = tracker._tasks[run_id]
            await asyncio.sleep(0.05)
            assert first_task.done()
            with Session(engine) as s:
                failed = s.get(Run, run_id)
                failed.status = "failed"
                s.add(failed)
                s.commit()

            with Session(engine) as s, patch.object(
                tracker.orchestrator, "resume", side_effect=_resume,
            ):
                out = _resume_run_impl(seed_business, run_id, s, tracker)

            assert out.status == "running"
            assert tracker._tasks[run_id] is not first_task
            assert mock_poll.call_count == 2
            await asyncio.sleep(0.05)

    @pytest.mark.asyncio
    async def test_watchdog_exit_keeps_newer_loop_entry(self, tracker):
        """The exiting loop's watchdog must not pop a replacement loop's
        entry registered for the same run."""
        newer = asyncio.get_running_loop().create_task(asyncio.sleep(999))

        async def exiting_loop():
            tracker._tasks["r1"] = newer
            tracker._handle_watchdog_exit("r1")

        await asyncio.get_running_loop().create_task(exiting_loop())
        assert tracker._tasks.get("r1") is newer
        newer.cancel()

    @pytest.mark.asyncio
    async def test_watchdog_exit_pops_own_entry(self, tracker):
        async def exiting_loop():
            tracker._tasks["r1"] = asyncio.current_task()
            tracker._handle_watchdog_exit("r1")

        await asyncio.get_running_loop().create_task(exiting_loop())
        assert "r1" not in tracker._tasks


# ---------------------------------------------------------------------------
# 2. get_active_runs
# ---------------------------------------------------------------------------

class TestGetActiveRuns:

    @pytest.mark.asyncio
    async def test_returns_active_ids(self, tracker, engine, seed_business):
        with Session(engine) as s:
            r1 = _make_run(seed_business)
            r2 = _make_run(seed_business)
            s.add(r1)
            s.add(r2)
            s.commit()
            id1, id2 = r1.id, r2.id

        async def hang(rid):
            await asyncio.sleep(999)

        with patch.object(tracker, "_poll_loop", side_effect=hang):
            tracker.start_tracking(id1)
            tracker.start_tracking(id2)
            await asyncio.sleep(0.05)
            active = tracker.get_active_runs()
            assert set(active) == {id1, id2}

            tracker.stop_tracking(id1)
            await asyncio.sleep(0.05)
            active = tracker.get_active_runs()
            assert active == [id2]
            tracker.stop_tracking(id2)


# ---------------------------------------------------------------------------
# 3. resume_running_runs
# ---------------------------------------------------------------------------

class TestResumeRunningRuns:

    @pytest.mark.asyncio
    async def test_resumes_running_and_stale(self, tracker, engine, seed_business):
        with Session(engine) as s:
            r_running = _make_run(seed_business, status="running")
            r_stale = _make_run(seed_business, status="stale")
            r_completed = _make_run(seed_business, status="completed")
            s.add_all([r_running, r_stale, r_completed])
            s.commit()
            running_id = r_running.id
            stale_id = r_stale.id
            completed_id = r_completed.id

        with patch.object(tracker, "_poll_loop", new_callable=AsyncMock) as mock_poll:
            mock_poll.return_value = None
            await tracker.resume_running_runs()
            await asyncio.sleep(0.05)

            tracked_ids = set(tracker._tasks.keys())
            assert running_id in tracked_ids
            assert stale_id in tracked_ids
            assert completed_id not in tracked_ids


    @pytest.mark.asyncio
    async def test_startup_does_not_wait_for_the_post_install_delete_sweep(self, tracker):
        """The boot sweep runs on the tick executor and startup returns
        before it ends (run on the loop, or awaited, this times out)."""
        import threading

        started, release = threading.Event(), threading.Event()
        threads: list[str] = []

        def slow_sweep():
            threads.append(threading.current_thread().name)
            started.set()
            release.wait(5)

        with patch.object(tracker, "_sweep_post_install_deletes", side_effect=slow_sweep):
            try:
                await asyncio.wait_for(tracker.resume_running_runs(), timeout=1)
                assert await asyncio.get_running_loop().run_in_executor(None, started.wait, 2)
                assert threads and threads[0].startswith("tracker-tick")
            finally:
                release.set()
            await tracker._boot_sweep

    @pytest.mark.asyncio
    async def test_a_boot_sweep_that_cannot_start_is_logged(self, tracker, caplog):
        with patch.object(tracker, "_sweep_post_install_deletes", side_effect=RuntimeError("no db")):
            with caplog.at_level("ERROR", logger="vibe_modeling.backend.progress_tracker"):
                await tracker.resume_running_runs()
                with pytest.raises(RuntimeError):
                    await tracker._boot_sweep
                await asyncio.sleep(0)
        assert "boot sweep failed" in caplog.text


# ---------------------------------------------------------------------------
# Status normalization
# ---------------------------------------------------------------------------

class TestNormalizeStatus:
    """Normalization is the single translation boundary between the agent's
    raw vocabulary and the stable {running, completed, failed, skipped} enum
    that downstream code depends on. Tests document the full mapping so a
    vocabulary drift surfaces loudly."""

    def test_current_agent_vocabulary_maps_to_stable_enum(self):
        assert _normalize_status("stage_started") == "running"
        assert _normalize_status("stage_in_progress") == "running"
        assert _normalize_status("stage_succeeded") == "completed"
        assert _normalize_status("stage_ended") == "completed"
        assert _normalize_status("stage_failed") == "failed"
        assert _normalize_status("stage_skipped") == "skipped"
        assert _normalize_status("skipped") == "skipped"

    def test_legacy_vocabulary_still_maps_correctly(self):
        # Older progress rows written before normalization landed may still
        # carry these values — they must remain intelligible to the UI.
        assert _normalize_status("running") == "running"
        assert _normalize_status("in_progress") == "running"
        assert _normalize_status("completed") == "completed"
        assert _normalize_status("done") == "completed"
        assert _normalize_status("failed") == "failed"
        assert _normalize_status("error") == "failed"

    def test_empty_status_returns_empty(self):
        assert _normalize_status("") == ""

    def test_unknown_status_passes_through_with_warning(self, caplog):
        import logging
        from vibe_modeling.backend import progress_tracker

        # Clear the one-shot warning set so this test is independent of ordering
        progress_tracker._unknown_status_warned.clear()
        with caplog.at_level(logging.WARNING, logger=progress_tracker.logger.name):
            result = _normalize_status("phase_begin")
        assert result == "phase_begin"
        assert any("phase_begin" in r.message for r in caplog.records)

    def test_unknown_status_warning_is_emitted_once(self, caplog):
        import logging
        from vibe_modeling.backend import progress_tracker

        progress_tracker._unknown_status_warned.clear()
        with caplog.at_level(logging.WARNING, logger=progress_tracker.logger.name):
            _normalize_status("weird_new_status")
            _normalize_status("weird_new_status")
            _normalize_status("weird_new_status")
        matching = [r for r in caplog.records if "weird_new_status" in r.message]
        assert len(matching) == 1


# ---------------------------------------------------------------------------
# v0.7.0 contract: agent emits new "Architect Review" stage with sub-events,
# plus a new ``domain_architect_review`` block in result_json. Per the audit
# at audit_report.md these are
# append-only — the App persists events verbatim and tolerates unknown
# result_json keys. These tests pin the regression surface.
# ---------------------------------------------------------------------------


class TestV070AgentEvents:
    """Adversarial: a v0.7.0 agent emits these new event shapes; the
    app must persist them without parse errors or data loss."""

    def _seed(self, engine, seed_business):
        with Session(engine) as s:
            run = _make_run(seed_business)
            s.add(run)
            s.flush()
            s.add(RunOperation(
                run_id=run.id, step_index=0, operation_name="generate_ecm",
                params_json="{}", status="running",
            ))
            s.commit()
            return run.id

    def test_architect_review_stage_event_persisted_verbatim(
        self, tracker, engine, seed_business
    ):
        """v0.7.0 introduces ``stage_name="Architect Review"`` with Step 3.6
        / 3.7 sub-events. The app should mirror them into Lakebase as-is."""
        from vibe_modeling.backend.progress_tracker import ProgressEvent

        run_id = self._seed(engine, seed_business)
        events = [
            ProgressEvent(
                step_id=1001, event_seq=1,
                stage_name="Architect Review", step_name="Step 3.6 — per-domain review",
                status="stage_in_progress", message="Architect reviewing sales",
                progress_increment=0.0, result_json={},
            ),
            ProgressEvent(
                step_id=1002, event_seq=2,
                stage_name="Architect Review", step_name="Step 3.7 — global review",
                status="stage_succeeded", message="Architect global review complete",
                progress_increment=0.0, result_json={"domain_count": 3},
            ),
        ]
        status = SessionStatus(
            session_id=99999, processing_status="ready",
            completed_percent=50.0, last_updated_at="2026-04-26T00:00:01Z",
            business="test", version="v1", model_scope="ecm",
        )
        with patch.object(tracker, "_poll_session_status_by_id", return_value=status), \
             patch.object(tracker, "_poll_progress_events", return_value=events), \
             patch.object(tracker, "_acknowledge_batch"), \
             Session(engine) as s:
            run = s.get(Run, run_id)
            tracker._sync_orch_progress_events(run, s)
            s.commit()

        with Session(engine) as s:
            persisted = s.exec(
                select(RunProgressEvent).where(RunProgressEvent.run_id == run_id)
                .order_by(RunProgressEvent.event_seq)
            ).all()
        names = [(e.stage_name, e.step_name) for e in persisted]
        assert ("Architect Review", "Step 3.6 — per-domain review") in names
        assert ("Architect Review", "Step 3.7 — global review") in names

    def test_domain_architect_review_block_in_result_json_persisted(
        self, tracker, engine, seed_business
    ):
        """v0.7.0 adds ``domain_architect_review`` to the result_json of the
        ``Creating Data Products`` ``stage_succeeded`` event, alongside the
        existing ``architect_review_changes``. Both keys must round-trip."""
        from vibe_modeling.backend.progress_tracker import ProgressEvent

        run_id = self._seed(engine, seed_business)
        result_json = {
            "architect_review_changes": ["change1", "change2"],
            "domain_architect_review": {"sales": {"flagged": 0}},
        }
        events = [ProgressEvent(
            step_id=2001, event_seq=1,
            stage_name="Creating Data Products", step_name="Final review",
            status="stage_succeeded", message="ok",
            progress_increment=0.0, result_json=result_json,
        )]
        status = SessionStatus(
            session_id=99999, processing_status="ready",
            completed_percent=80.0, last_updated_at="2026-04-26T00:00:01Z",
            business="test", version="v1", model_scope="ecm",
        )
        with patch.object(tracker, "_poll_session_status_by_id", return_value=status), \
             patch.object(tracker, "_poll_progress_events", return_value=events), \
             patch.object(tracker, "_acknowledge_batch"), \
             Session(engine) as s:
            run = s.get(Run, run_id)
            tracker._sync_orch_progress_events(run, s)
            s.commit()

        with Session(engine) as s:
            persisted = s.exec(
                select(RunProgressEvent).where(RunProgressEvent.run_id == run_id)
            ).first()
        assert persisted is not None
        body = json.loads(persisted.result_json)
        assert body["architect_review_changes"] == ["change1", "change2"]
        assert body["domain_architect_review"] == {"sales": {"flagged": 0}}


# ---------------------------------------------------------------------------
# Split-loop architecture: drain runs independently of advance
# ---------------------------------------------------------------------------

class TestSplitLoops:
    """The poll loop spawns ``_drain_loop_inner`` and ``_advance_loop_inner``
    on independent cadences. A slow advance must not block event mirroring."""

    @pytest.mark.asyncio
    async def test_drain_runs_more_often_than_advance_when_advance_is_slow(
        self, mock_ws, session_factory, engine, seed_business
    ):
        """When advance ticks take much longer than the drain interval,
        drain should still tick on its own cadence."""
        with Session(engine) as s:
            run = _make_run(seed_business)
            s.add(run)
            s.commit()
            run_id = run.id

        # drain every 0.01s, advance every 0.05s — and make advance "slow"
        # by sleeping 0.1s per call so it lags behind its own interval.
        config = AppConfig(
            app_name="test",
            warehouse_id="w",
            poll_interval_seconds=0,  # asyncio.sleep(0) yields once
            drain_interval_seconds=0,
        )
        tracker = ProgressTracker(ws=mock_ws, config=config, session_factory=session_factory)

        drain_calls = 0
        advance_calls = 0

        async def fake_drain(rid):
            nonlocal drain_calls
            drain_calls += 1
            return False

        async def fake_advance(rid):
            nonlocal advance_calls
            advance_calls += 1
            await asyncio.sleep(0.05)  # simulate slow advance tick
            # Terminate after 2 advance calls so the test finishes.
            return advance_calls >= 2

        with patch.object(tracker, "_drain_tick", side_effect=fake_drain), \
             patch.object(tracker, "_advance_tick", side_effect=fake_advance):
            await tracker._run_split_loops(run_id)

        # During the 2 × 50ms advance windows, the drain (with interval=0)
        # should have ticked many more times than advance.
        assert advance_calls == 2, advance_calls
        assert drain_calls > advance_calls, f"drain={drain_calls} advance={advance_calls}"

    @pytest.mark.asyncio
    async def test_advance_terminal_cancels_drain(
        self, mock_ws, session_factory, engine, seed_business
    ):
        """If the advance loop returns terminal=True, the split orchestrator
        cancels the still-running drain task and exits cleanly."""
        with Session(engine) as s:
            run = _make_run(seed_business)
            s.add(run)
            s.commit()
            run_id = run.id

        config = AppConfig(
            app_name="t", warehouse_id="w",
            poll_interval_seconds=0, drain_interval_seconds=0,
        )
        tracker = ProgressTracker(ws=mock_ws, config=config, session_factory=session_factory)

        drain_was_cancelled = False

        async def fake_drain(rid):
            return False  # never terminates on its own

        async def fake_advance(rid):
            return True  # terminal on first call

        # Patch sleep on the drain side so it loops forever until cancelled.
        original_sleep = asyncio.sleep

        async def patched_sleep(delay):
            nonlocal drain_was_cancelled
            try:
                await original_sleep(delay)
            except asyncio.CancelledError:
                drain_was_cancelled = True
                raise

        with patch.object(tracker, "_drain_tick", side_effect=fake_drain), \
             patch.object(tracker, "_advance_tick", side_effect=fake_advance), \
             patch("vibe_modeling.backend.progress_tracker.asyncio.sleep",
                   side_effect=patched_sleep):
            await tracker._run_split_loops(run_id)

        assert drain_was_cancelled is True

    @pytest.mark.asyncio
    async def test_drain_terminal_cancels_advance(
        self, mock_ws, session_factory, engine, seed_business
    ):
        """Symmetric: if drain returns True (e.g., Run row gone), advance
        loop is cancelled."""
        with Session(engine) as s:
            run = _make_run(seed_business)
            s.add(run)
            s.commit()
            run_id = run.id

        config = AppConfig(
            app_name="t", warehouse_id="w",
            poll_interval_seconds=0, drain_interval_seconds=0,
        )
        tracker = ProgressTracker(ws=mock_ws, config=config, session_factory=session_factory)

        advance_started = asyncio.Event()
        advance_cancelled = False

        async def fake_drain(rid):
            return True  # terminal first call

        async def fake_advance(rid):
            advance_started.set()
            try:
                await asyncio.sleep(10)  # would block forever absent cancellation
            except asyncio.CancelledError:
                nonlocal advance_cancelled
                advance_cancelled = True
                raise
            return False

        with patch.object(tracker, "_drain_tick", side_effect=fake_drain), \
             patch.object(tracker, "_advance_tick", side_effect=fake_advance):
            await tracker._run_split_loops(run_id)

        # advance may not have started yet (drain finished first) — so this
        # assertion is best-effort: either it never ran, or it ran and was
        # cancelled. What matters is the loop returned cleanly without hanging.
        assert advance_cancelled or not advance_started.is_set()
