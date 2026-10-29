"""Edge-case regression tests for the Phase 4 close-out progress-tracker
changes (auto-100%-on-Session-Ended + cursor on event_seq +
``stage_warning`` normalization + warning rendering).

Targets specific failure modes the existing 1326+333 tests don't cover:

1. Multi-phase unified-pipeline runs where each phase has its OWN
   ``session_id_bigint``. ``_finalize_session_completion`` must fire
   per-phase with the correct session id (no cross-pollution).
2. Out-of-order events in a single batch: ``stage_warning`` arrives
   BEFORE the terminal ``Session Ended`` event. ``saw_session_ended`` is
   computed during the loop and consumed afterwards, so order shouldn't
   matter — verify.
3. ``_finalize_session_completion`` is robust against SQL injection in
   ``business_name`` / ``version`` / ``model_scope``: ``escape_sql_literal``
   must double single quotes, escape backslashes, drop NULs.
4. NULL ``event_seq`` from a legacy progress row must not advance the
   cursor (preserves the upper-bound for new agent v0.6.0 events) AND
   must still be persisted.
5. ``_finalize_session_completion`` SQL is gated by ``completed_percent
   < 100``: passing the call when the agent already wrote 100 must be a
   no-op (verify the WHERE clause includes the gate).
"""

import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "..", "src", "app", "src"))

import json
from contextlib import contextmanager
from datetime import datetime, timezone
from unittest.mock import MagicMock, patch

import pytest
from sqlalchemy.pool import StaticPool
from sqlmodel import Session, SQLModel, create_engine, select

from vibe_modeling.backend.core._config import AppConfig
from vibe_modeling.backend.db_models import (
    Business,
    Run,
    RunOperation,
    RunProgressEvent,
)
from vibe_modeling.backend.progress_tracker import (
    ProgressEvent,
    ProgressTracker,
    SessionStatus,
)


# ---------------------------------------------------------------------------
# Fixtures (mirror test_progress_tracker.py — kept local to avoid import
# coupling and to make this file independently runnable).
# ---------------------------------------------------------------------------


@pytest.fixture
def engine():
    eng = create_engine(
        "sqlite://",
        connect_args={"check_same_thread": False},
        poolclass=StaticPool,
    )
    SQLModel.metadata.create_all(eng)
    return eng


@pytest.fixture
def session_factory(engine):
    @contextmanager
    def _factory():
        with Session(engine) as session:
            yield session
    return _factory


@pytest.fixture
def mock_ws():
    ws = MagicMock()
    ws.config.host = "https://test-workspace.databricks.com"
    default_run = MagicMock()
    default_run.state.life_cycle_state.value = "TERMINATED"
    default_run.state.result_state.value = "SUCCESS"
    default_run.state.state_message = ""
    ws.jobs.get_run.return_value = default_run
    return ws


@pytest.fixture
def config():
    return AppConfig(app_name="test", warehouse_id="wh", poll_interval_seconds=0)


@pytest.fixture
def tracker(mock_ws, config, session_factory):
    return ProgressTracker(ws=mock_ws, config=config, session_factory=session_factory)


@pytest.fixture
def seed_business(engine) -> str:
    with Session(engine) as s:
        b = Business(name="Acme", description="t", industry_alignment="Retail")
        s.add(b)
        s.commit()
        s.refresh(b)
        return b.id


def _seed_unified_run(engine, business_id: str, *,
                      ecm_session: int, mvm_session: int,
                      running_step_index: int) -> str:
    """Seed a unified-pipeline run with two RunOperations
    (generate_ecm + shrink_to_mvm), each with its own session_id stored
    on its rollback_state_json. ``running_step_index`` selects which is
    currently running."""
    with Session(engine) as s:
        run = Run(
            business_id=business_id,
            intent="new-base-model",
            status="running",
            databricks_run_id=12345,
            vibe_session_id=None,
            vibe_session_id_bigint=None,  # unified path uses per-op sids
            started_at=datetime.now(timezone.utc),
            parameters_json=json.dumps({
                "operation": "new base model",
                "deployment_catalog": "test_cat",
            }),
        )
        s.add(run)
        s.flush()
        for idx, (op_name, sid) in enumerate(
            [("generate_ecm", ecm_session), ("shrink_to_mvm", mvm_session)]
        ):
            status = "running" if idx == running_step_index else (
                "succeeded" if idx < running_step_index else "pending"
            )
            s.add(RunOperation(
                run_id=run.id,
                step_index=idx,
                operation_name=op_name,
                params_json="{}",
                status=status,
                rollback_state_json=json.dumps({"session_id_bigint": sid}),
            ))
        s.commit()
        return run.id


# ---------------------------------------------------------------------------
# 1. Multi-phase finalize: each phase's Session Ended fires with its OWN sid
# ---------------------------------------------------------------------------


class TestMultiPhaseFinalize:
    """A unified-pipeline run dispatches generate_ecm then shrink_to_mvm
    sequentially. Each has its own ``session_id_bigint``. Each phase's
    Session Ended event must trigger finalize for THAT phase's sid only —
    never the other phase's sid (cross-pollution would zero-stamp the
    wrong row in ``_metamodel.business``)."""

    def test_phase1_finalize_uses_phase1_session_id(
        self, tracker, engine, seed_business
    ):
        run_id = _seed_unified_run(
            engine, seed_business,
            ecm_session=11111111111, mvm_session=22222222222,
            running_step_index=0,  # generate_ecm running
        )
        events = [
            ProgressEvent(step_id=100, event_seq=10, stage_name="Vibe Session",
                          step_name="Session Ended", status="completed",
                          message="ECM done", progress_increment=1.0),
        ]
        status = SessionStatus(
            session_id=11111111111, processing_status="ready",
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
        # Positional args: (catalog, session_id_bigint)
        assert mock_finalize.call_args.args[1] == 11111111111, (
            "Phase 1 finalize must target generate_ecm's session id, "
            "not shrink_to_mvm's"
        )

    def test_phase2_finalize_uses_phase2_session_id(
        self, tracker, engine, seed_business
    ):
        run_id = _seed_unified_run(
            engine, seed_business,
            ecm_session=11111111111, mvm_session=22222222222,
            running_step_index=1,  # shrink_to_mvm running, ecm done
        )
        events = [
            ProgressEvent(step_id=200, event_seq=10, stage_name="Vibe Session",
                          step_name="Session Ended", status="completed",
                          message="MVM done", progress_increment=1.0),
        ]
        status = SessionStatus(
            session_id=22222222222, processing_status="ready",
            completed_percent=99.0,
            last_updated_at="2026-04-27T00:00:01Z",
            business="Acme", version="1", model_scope="mvm",
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
        assert mock_finalize.call_args.args[1] == 22222222222, (
            "Phase 2 finalize must target shrink_to_mvm's session id"
        )


# ---------------------------------------------------------------------------
# 2. Out-of-order events in one poll batch
# ---------------------------------------------------------------------------


class TestOutOfOrderEvents:
    """``saw_session_ended`` is computed during the loop and consumed
    afterwards. Even if Delta returns the warning event BEFORE the
    Session Ended event in a single poll batch (event_seq order is
    monotonic but the agent may interleave stages), finalize must still
    fire."""

    def _seed(self, engine, business_id: str) -> str:
        return _seed_unified_run(
            engine, business_id,
            ecm_session=33333333333, mvm_session=44444444444,
            running_step_index=0,
        )

    def test_warning_then_session_ended_still_finalizes(
        self, tracker, engine, seed_business
    ):
        run_id = self._seed(engine, seed_business)
        events = [
            # Warning arrives first (lower event_seq)
            ProgressEvent(step_id=500, event_seq=20,
                          stage_name="Applying Metric Views",
                          step_name="Metric View Creation",
                          status="warning",
                          message="7 of 22 metric views failed",
                          progress_increment=0.0,
                          result_json={"failed_views": 7}),
            # Session Ended arrives second (higher event_seq)
            ProgressEvent(step_id=600, event_seq=30,
                          stage_name="Vibe Session",
                          step_name="Session Ended",
                          status="completed",
                          message="Pipeline completed",
                          progress_increment=1.0),
        ]
        status = SessionStatus(
            session_id=33333333333, processing_status="ready",
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

    def test_session_ended_then_warning_still_finalizes(
        self, tracker, engine, seed_business
    ):
        """Reverse order: Session Ended event_seq < warning event_seq.
        The agent shouldn't emit this in practice (Session Ended is
        always last), but the implementation must not depend on order."""
        run_id = self._seed(engine, seed_business)
        events = [
            ProgressEvent(step_id=600, event_seq=20,
                          stage_name="Vibe Session",
                          step_name="Session Ended",
                          status="completed",
                          message="Pipeline completed",
                          progress_increment=1.0),
            ProgressEvent(step_id=500, event_seq=30,
                          stage_name="Applying Metric Views",
                          step_name="Metric View Creation",
                          status="warning",
                          message="late warning",
                          progress_increment=0.0),
        ]
        status = SessionStatus(
            session_id=33333333333, processing_status="ready",
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


# ---------------------------------------------------------------------------
# 3. SQL injection / escaping in _finalize_session_completion
# ---------------------------------------------------------------------------


class TestFinalizeSqlEscaping:
    """``_finalize_session_completion`` builds raw SQL with string
    interpolation. ``escape_sql_literal`` must double single quotes,
    backslash-escape backslashes, and strip NUL bytes from
    ``business_name`` / ``version`` / ``model_scope``."""

    def test_finalize_escapes_single_quotes_in_business_name(self, tracker):
        captured = {}
        def _capture(sql, *_a, **_kw):
            captured["sql"] = sql
            return None
        with patch.object(tracker, "_write", side_effect=_capture):
            tracker._finalize_session_completion(
                catalog="my_cat",
                session_id_bigint=999,
                business_name="O'Brien's Co",
                version="1",
                model_scope="ecm",
            )
        sql = captured["sql"]
        # Embedded ' must be doubled, never raw — otherwise the SQL is
        # broken AND injectable.
        assert "O''Brien''s Co" in sql
        # The SQL must include the < 100 gate so completed runs aren't
        # touched (regression: dropping this clause would re-stamp
        # completion_date on every poll).
        assert "completed_percent < 100" in sql

    def test_finalize_escapes_backslash(self, tracker):
        captured = {}
        with patch.object(
            tracker, "_write",
            side_effect=lambda sql, *a, **k: captured.update({"sql": sql}) or None,
        ):
            tracker._finalize_session_completion(
                catalog="my_cat", session_id_bigint=999,
                business_name="evil\\name",
                version="1",
                model_scope="ecm",
            )
        # Backslash must be doubled.
        assert "evil\\\\name" in captured["sql"]

    def test_finalize_strips_nul_byte(self, tracker):
        captured = {}
        with patch.object(
            tracker, "_write",
            side_effect=lambda sql, *a, **k: captured.update({"sql": sql}) or None,
        ):
            tracker._finalize_session_completion(
                catalog="my_cat", session_id_bigint=999,
                business_name="bad\x00name",
                version="1",
                model_scope="ecm",
            )
        # NUL bytes are stripped; identifiers in the rendered SQL must
        # never contain a literal NUL (Databricks SQL parser hostile).
        assert "\x00" not in captured["sql"]
        assert "badname" in captured["sql"]

    def test_finalize_omits_optional_filters_when_blank(self, tracker):
        """When ``_sync_orch_progress_events`` calls finalize with only
        catalog + sid (no business/version/scope), the SQL must filter
        on session_id alone — not produce a malformed `LOWER(business)
        = LOWER('')` clause that matches the wrong row."""
        captured = {}
        with patch.object(
            tracker, "_write",
            side_effect=lambda sql, *a, **k: captured.update({"sql": sql}) or None,
        ):
            tracker._finalize_session_completion(
                catalog="my_cat", session_id_bigint=12345,
            )
        sql = captured["sql"]
        assert "session_id = 12345" in sql
        assert "completed_percent < 100" in sql
        # No business/version/scope filters when they were not provided.
        assert "business" not in sql.lower() or "LOWER(business)" not in sql
        assert "version =" not in sql
        assert "model_scope" not in sql


# ---------------------------------------------------------------------------
# 4. NULL event_seq cursor handling
# ---------------------------------------------------------------------------


class TestNullEventSeqCursor:
    """Legacy progress rows can have NULL ``event_seq``. The cursor
    advance check (``ev.event_seq is not None and ev.event_seq > X``)
    must safely skip the advance for NULL events. The event itself is
    still persisted (so it shows in the UI), but the cursor stays
    parked at the previous high-water-mark.

    In practice these events are filtered out by the SQL ``event_seq >
    last_event_seq`` predicate (NULL > N is NULL/false), so they're
    never re-fetched. But the in-loop None check is still required
    because the events list is mocked / could be hand-built."""

    def _seed(self, engine, business_id: str) -> str:
        with Session(engine) as s:
            run = Run(
                business_id=business_id,
                intent="new-base-model",
                status="running",
                databricks_run_id=12345,
                vibe_session_id_bigint=99999,
                started_at=datetime.now(timezone.utc),
                last_consumed_step_id=10,
                parameters_json=json.dumps({
                    "operation": "new base model",
                    "deployment_catalog": "test_cat",
                }),
            )
            s.add(run)
            s.flush()
            s.add(RunOperation(
                run_id=run.id, step_index=0, operation_name="generate_ecm",
                params_json="{}", status="running",
                rollback_state_json=json.dumps({"session_id_bigint": 99999}),
            ))
            s.commit()
            return run.id

    def test_null_event_seq_event_persists_but_does_not_advance_cursor(
        self, tracker, engine, seed_business
    ):
        run_id = self._seed(engine, seed_business)
        events = [
            ProgressEvent(step_id=200, event_seq=None,
                          stage_name="Legacy Stage",
                          step_name="Legacy Step",
                          status="running",
                          message="legacy event",
                          progress_increment=0.0),
        ]
        status = SessionStatus(
            session_id=99999, processing_status="ready",
            completed_percent=50.0,
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
            run = s.get(Run, run_id)
            assert run.last_consumed_step_id == 10, (
                "cursor must NOT advance on a NULL-event_seq event "
                "(cursor stays at the previous high-water-mark of 10)"
            )
            persisted = s.exec(
                select(RunProgressEvent)
                .where(RunProgressEvent.run_id == run_id)
            ).all()
            assert len(persisted) == 1, (
                "the event itself must still be persisted to Lakebase "
                "for UI rendering, even with NULL event_seq"
            )

    def test_mixed_null_and_real_event_seq_advances_to_max_real(
        self, tracker, engine, seed_business
    ):
        """Mixed batch: some events have event_seq, some don't. Cursor
        must advance to the max non-null event_seq seen."""
        run_id = self._seed(engine, seed_business)
        events = [
            ProgressEvent(step_id=200, event_seq=None,
                          stage_name="Legacy", step_name="Old",
                          status="running", message="", progress_increment=0.0),
            ProgressEvent(step_id=300, event_seq=42,
                          stage_name="New", step_name="Fresh",
                          status="running", message="", progress_increment=0.0),
            ProgressEvent(step_id=400, event_seq=None,
                          stage_name="Legacy2", step_name="Old2",
                          status="running", message="", progress_increment=0.0),
        ]
        status = SessionStatus(
            session_id=99999, processing_status="ready",
            completed_percent=50.0,
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
            run = s.get(Run, run_id)
            assert run.last_consumed_step_id == 42, (
                "cursor must track max non-null event_seq across the batch"
            )


# ---------------------------------------------------------------------------
# Bug C — Jobs API fallback in the orchestrator path
# ---------------------------------------------------------------------------


def _seed_unified_run_with_dbx(
    engine, business_id: str, *, dbx_run_id: int = 99001,
) -> str:
    """Seed a unified-pipeline run with two RunOperations where the
    second (shrink_to_mvm) is currently running, holds a
    ``databricks_run_id``, but has emitted ZERO progress events. This
    matches the run 273d137e shape from 2026-04-27 — Phase 2 dbx job
    failed at ``step_setup_and_clean`` before any agent events, so
    Delta drain produced no rows and the legacy watchdog was the only
    backstop.
    """
    with Session(engine) as s:
        run = Run(
            business_id=business_id,
            intent="shrink",  # is_model_producing=True
            status="running",
            databricks_run_id=dbx_run_id,
            vibe_session_id=None,
            vibe_session_id_bigint=None,
            started_at=datetime.now(timezone.utc),
            parameters_json=json.dumps({
                "operation": "shrink ecm",
                "deployment_catalog": "test_cat",
            }),
        )
        s.add(run)
        s.flush()
        s.add(RunOperation(
            run_id=run.id,
            step_index=0,
            operation_name="generate_ecm",
            params_json="{}",
            status="succeeded",
        ))
        s.add(RunOperation(
            run_id=run.id,
            step_index=1,
            operation_name="shrink_to_mvm",
            params_json="{}",
            status="running",
            databricks_run_id=dbx_run_id,
            rollback_state_json=json.dumps({"session_id_bigint": 22222222222}),
        ))
        s.commit()
        return run.id


class TestJobsApiFallbackOrchestratorPath:
    """When a model-producing op's Databricks job flips to
    TERMINATED-not-success BEFORE any progress events arrive, the
    orchestrator path must NOT wait on the legacy D-09 watchdog (6+
    minute delay observed on run 273d137e). ``_advance_tick``'s
    Jobs API fallback (``_fail_op_if_jobs_api_terminal``) force-fails
    the running op and routes through ``_initiate_rollback`` so the
    Run reaches a terminal state on the next tick.
    """

    def test_terminated_failed_no_events_transitions_op_to_failed(
        self, tracker, engine, seed_business, mock_ws
    ):
        run_id = _seed_unified_run_with_dbx(engine, seed_business)
        # Jobs API: TERMINATED + FAILED for the dbx_run_id we'll poll.
        failed_run = MagicMock()
        failed_run.state.life_cycle_state.value = "TERMINATED"
        failed_run.state.result_state.value = "FAILED"
        failed_run.state.state_message = "step_setup_and_clean failed"
        failed_run.tasks = []
        mock_ws.jobs.get_run.return_value = failed_run

        with Session(engine) as s:
            run = s.get(Run, run_id)
            tracker._fail_op_if_jobs_api_terminal(run, s)
            s.commit()

        with Session(engine) as s:
            run = s.get(Run, run_id)
            ops = list(s.exec(
                select(RunOperation)
                .where(RunOperation.run_id == run_id)
                .order_by(RunOperation.step_index)
            ).all())
            assert ops[1].status == "failed", (
                "running op must be force-failed when Jobs API reports "
                "TERMINATED/FAILED with zero Delta events"
            )
            assert "step_setup_and_clean" in (ops[1].error_message or "")
            # ``_initiate_rollback`` (called by the fallback) routes the
            # Run terminal via ``transition_run`` → ``failed``.
            assert run.status == "failed", (
                f"Run must reach terminal failed; got {run.status}"
            )

    def test_internal_error_no_events_transitions_op_to_failed(
        self, tracker, engine, seed_business, mock_ws
    ):
        run_id = _seed_unified_run_with_dbx(engine, seed_business)
        ie_run = MagicMock()
        ie_run.state.life_cycle_state.value = "INTERNAL_ERROR"
        ie_run.state.result_state.value = ""
        ie_run.state.state_message = "cluster init failed"
        ie_run.tasks = []
        mock_ws.jobs.get_run.return_value = ie_run

        with Session(engine) as s:
            run = s.get(Run, run_id)
            tracker._fail_op_if_jobs_api_terminal(run, s)
            s.commit()

        with Session(engine) as s:
            run = s.get(Run, run_id)
            ops = list(s.exec(
                select(RunOperation)
                .where(RunOperation.run_id == run_id)
                .order_by(RunOperation.step_index)
            ).all())
            assert ops[1].status == "failed"
            assert run.status == "failed"

    def test_terminated_success_does_not_force_fail(
        self, tracker, engine, seed_business, mock_ws
    ):
        """TERMINATED/SUCCESS must leave the row alone — the primitive's
        ``observe()`` runs the model.json verification before declaring
        success. Force-failing here would clobber a succeeding run.
        """
        run_id = _seed_unified_run_with_dbx(engine, seed_business)
        ok_run = MagicMock()
        ok_run.state.life_cycle_state.value = "TERMINATED"
        ok_run.state.result_state.value = "SUCCESS"
        ok_run.state.state_message = ""
        ok_run.tasks = []
        mock_ws.jobs.get_run.return_value = ok_run

        with Session(engine) as s:
            run = s.get(Run, run_id)
            tracker._fail_op_if_jobs_api_terminal(run, s)
            s.commit()

        with Session(engine) as s:
            run = s.get(Run, run_id)
            ops = list(s.exec(
                select(RunOperation)
                .where(RunOperation.run_id == run_id)
                .order_by(RunOperation.step_index)
            ).all())
            assert ops[1].status == "running"
            assert run.status == "running"

    def test_running_state_does_not_force_fail(
        self, tracker, engine, seed_business, mock_ws
    ):
        """Non-terminal Jobs API state (RUNNING / PENDING / QUEUED) must
        be a no-op — the agent may simply not have written events yet.
        """
        run_id = _seed_unified_run_with_dbx(engine, seed_business)
        running_run = MagicMock()
        running_run.state.life_cycle_state.value = "RUNNING"
        running_run.state.result_state.value = ""
        running_run.state.state_message = ""
        running_run.tasks = []
        mock_ws.jobs.get_run.return_value = running_run

        with Session(engine) as s:
            run = s.get(Run, run_id)
            tracker._fail_op_if_jobs_api_terminal(run, s)
            s.commit()

        with Session(engine) as s:
            run = s.get(Run, run_id)
            ops = list(s.exec(
                select(RunOperation)
                .where(RunOperation.run_id == run_id)
                .order_by(RunOperation.step_index)
            ).all())
            assert ops[1].status == "running"
            assert run.status == "running"

    def test_jobs_api_unavailable_does_not_force_fail(
        self, tracker, engine, seed_business, mock_ws
    ):
        """Jobs API intermittency (transient SDK error) must NOT mark
        the row failed — only an authoritative TERMINATED/<not-SUCCESS>
        response does. Mirrors the D-09 contract.
        """
        run_id = _seed_unified_run_with_dbx(engine, seed_business)
        mock_ws.jobs.get_run.side_effect = RuntimeError("connection refused")

        with Session(engine) as s:
            run = s.get(Run, run_id)
            tracker._fail_op_if_jobs_api_terminal(run, s)
            s.commit()

        with Session(engine) as s:
            run = s.get(Run, run_id)
            ops = list(s.exec(
                select(RunOperation)
                .where(RunOperation.run_id == run_id)
                .order_by(RunOperation.step_index)
            ).all())
            assert ops[1].status == "running"
            assert run.status == "running"

    def test_no_running_op_is_noop(
        self, tracker, engine, seed_business, mock_ws
    ):
        """If there's no running op, the fallback must do nothing
        (don't poll Jobs API, don't transition anything).
        """
        # Seed a run where every op has succeeded — no running rows.
        with Session(engine) as s:
            run = Run(
                business_id=seed_business,
                intent="shrink",
                status="running",
                started_at=datetime.now(timezone.utc),
                parameters_json="{}",
            )
            s.add(run)
            s.flush()
            s.add(RunOperation(
                run_id=run.id, step_index=0,
                operation_name="generate_ecm",
                params_json="{}", status="succeeded",
            ))
            s.commit()
            run_id = run.id

        with Session(engine) as s:
            run = s.get(Run, run_id)
            tracker._fail_op_if_jobs_api_terminal(run, s)

        # Jobs API should never have been queried.
        mock_ws.jobs.get_run.assert_not_called()
