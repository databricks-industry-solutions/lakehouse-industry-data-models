"""Each X-SQL2 call site of ``core/_sql`` and the failure choice it makes.

One class per site. Each drives the site with the three failures the helper
tells apart (a FAILED statement, one still running at the end of the site's
bound, a missing table) on SDK-shaped responses (``_sql_fakes``), and pins
the bound the site keeps. Deployment verification and the parent-metamodel
pre-flight have their own files (``test_deployment_verifier.py``,
``test_preflight_metamodel_parent.py``).
"""

from __future__ import annotations

import os
import sys
from contextlib import contextmanager
from types import SimpleNamespace
from unittest.mock import MagicMock

import pytest
from sqlalchemy.pool import StaticPool
from sqlmodel import Session, SQLModel, create_engine, select

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "..", "src", "app", "src"))

from vibe_modeling.backend.core._config import AppConfig  # noqa: E402
from vibe_modeling.backend.core._sql import SqlStatementError  # noqa: E402
from vibe_modeling.backend.initial_sync import InitialSyncService  # noqa: E402
from vibe_modeling.backend.model_sync import ModelSyncService  # noqa: E402
from vibe_modeling.backend.progress_tracker import ProgressTracker  # noqa: E402

from _sql_fakes import FakeClock, response, ws_returning  # noqa: E402

FAILED = "[INSUFFICIENT_PERMISSIONS] User reader@example.com lacks SELECT on business"
MISSING = "[TABLE_OR_VIEW_NOT_FOUND] The table `cat`.`_metamodel`.`business` cannot be found"


def _failed():
    return response(error=FAILED, statement_id="f1")


def _running():
    return response(state="RUNNING", statement_id="r1")


def _missing():
    return response(error=MISSING, statement_id="m1")


@pytest.fixture
def clock(monkeypatch):
    return FakeClock().install(monkeypatch)


# ---------------------------------------------------------------------------
# progress_tracker: raise (fail loud), missing table reads as "not yet"
# ---------------------------------------------------------------------------


class TestProgressTracker:
    """Reads: one 30 s wait, no polls; a missing table is "the agent has not
    written yet" (None / []); anything else raises. Writes raise on every
    failure."""

    @pytest.fixture
    def engine(self):
        eng = create_engine("sqlite://", connect_args={"check_same_thread": False}, poolclass=StaticPool)
        SQLModel.metadata.create_all(eng)
        return eng

    def _tracker(self, engine, ws):
        @contextmanager
        def factory():
            with Session(engine) as s:
                yield s

        cfg = AppConfig(app_name="t", warehouse_id="wh-1", poll_interval_seconds=0)
        return ProgressTracker(ws=ws, config=cfg, session_factory=factory)

    def test_events_raise_on_a_failed_read(self, engine):
        ws = ws_returning(_failed())
        with pytest.raises(SqlStatementError) as exc:
            self._tracker(engine, ws)._poll_progress_events("cat", 7, 0)
        assert exc.value.state == "FAILED"
        assert "reader@example.com" not in exc.value.message

    def test_events_raise_on_a_read_still_running_after_30s(self, engine):
        ws = ws_returning(_running())
        with pytest.raises(SqlStatementError) as exc:
            self._tracker(engine, ws)._poll_progress_events("cat", 7, 0)
        assert exc.value.state == "TIMEOUT"
        assert ws.waits == ["30s"]
        ws.statement_execution.cancel_execution.assert_called_once_with("r1")

    def test_events_are_empty_while_the_table_is_missing(self, engine):
        assert self._tracker(engine, ws_returning(_missing()))._poll_progress_events("cat", 7, 0) == []

    @pytest.mark.parametrize("answer,state", [(_failed(), "FAILED"), (_running(), "TIMEOUT")])
    def test_session_row_raises(self, engine, answer, state):
        with pytest.raises(SqlStatementError) as exc:
            self._tracker(engine, ws_returning(answer))._poll_session_status_by_id("cat", 7)
        assert exc.value.state == state

    def test_session_row_is_none_while_the_table_is_missing(self, engine):
        assert self._tracker(engine, ws_returning(_missing()))._poll_session_status_by_id("cat", 7) is None

    @pytest.mark.parametrize("answer,state", [(_failed(), "FAILED"), (_running(), "TIMEOUT")])
    def test_handshake_ack_raises(self, engine, answer, state):
        ws = ws_returning(answer)
        with pytest.raises(SqlStatementError) as exc:
            self._tracker(engine, ws)._acknowledge_batch("cat", 7)
        assert exc.value.state == state
        assert ws.waits == ["30s"]

    def test_finalize_retries_a_concurrent_append_then_raises(self, engine, monkeypatch):
        monkeypatch.setattr("vibe_modeling.backend.progress_tracker.time.sleep", lambda _s: None)
        ws = ws_returning(response(error="[DELTA_CONCURRENT_APPEND.ROW_LEVEL_CHANGES] retry"))
        with pytest.raises(SqlStatementError):
            self._tracker(engine, ws)._finalize_session_completion("cat", 7)
        assert len(ws.statements) == 4

    @staticmethod
    def _seed_running_run(engine, *, consumed: int = 0) -> str:
        from vibe_modeling.backend.db_models import Business, Run, RunOperation

        with Session(engine) as s:
            b = Business(name="Acme")
            s.add(b)
            s.flush()
            run = Run(business_id=b.id, intent="new-base-model", status="running",
                      parameters_json='{"deployment_catalog": "cat"}', vibe_session_id="sess-1",
                      last_consumed_step_id=consumed)
            s.add(run)
            s.flush()
            s.add(RunOperation(run_id=run.id, step_index=0, operation_name="generate_ecm",
                               status="running", vibe_session_id="sess-1"))
            s.commit()
            return run.id

    @staticmethod
    def _ws_by_table(events, business):
        def answer(*_a, statement=None, **_kw):
            return events if "_vibe_progress" in statement else business

        ws = MagicMock()
        ws.statement_execution.execute_statement.side_effect = answer
        ws.statement_execution.get_statement.side_effect = (
            lambda sid: response(state="CANCELED", statement_id=sid)
        )
        return ws

    def test_a_failed_event_drain_shows_on_the_run(self, engine):
        """The drain's read failure is recorded on ``last_poll_error``, in
        words, even when the session-status read of the same tick succeeds,
        and the cursor does not move."""
        from vibe_modeling.backend.db_models import Run

        run_id = self._seed_running_run(engine)
        tracker = self._tracker(engine, self._ws_by_table(_failed(), response([])))
        with Session(engine) as s:
            tracker._sync_orch_progress_events(s.get(Run, run_id), s)
            s.commit()
        with Session(engine) as s:
            run = s.get(Run, run_id)
            assert run.last_poll_error.startswith("Could not read the agent's progress (FAILED): ")
            assert "reader@example.com" not in run.last_poll_error
            assert run.last_consumed_step_id == 0

    def test_a_timeout_before_the_first_event_reads_as_booting(self, engine):
        """A stopped warehouse waking up: no red note, the booting message."""
        from vibe_modeling.backend.db_models import Run

        run_id = self._seed_running_run(engine)
        tracker = self._tracker(engine, self._ws_by_table(_running(), _running()))
        with Session(engine) as s:
            tracker._sync_orch_progress_events(s.get(Run, run_id), s)
            s.commit()
        with Session(engine) as s:
            run = s.get(Run, run_id)
            assert run.last_poll_error == ""
            assert run.progress_message.startswith("Booting agent")

    @pytest.mark.parametrize("events,business,state", [
        (_failed(), _failed(), "FAILED"),
        (_running(), response([]), "TIMEOUT"),
    ], ids=["final_drain_fails", "blip_on_the_last_tick"])
    def test_the_final_drain_inside_the_sync_savepoint_never_breaks_it(self, engine, events, business, state):
        """End of a successful run: model sync runs the final drain inside its
        savepoint. A failed read there leaves the savepoint usable, so the
        version's sync is kept; the run carries a readable note at most."""
        from vibe_modeling.backend.db_models import Run

        run_id = self._seed_running_run(engine, consumed=4)
        tracker = self._tracker(engine, self._ws_by_table(events, business))
        # The test engine shares one connection, so the warehouse lookup's own
        # session would end the savepoint; in the app each session has its own.
        tracker._resolve_warehouse_id = lambda: "wh-1"
        with Session(engine) as s:
            sync = ModelSyncService(session=s, ws=MagicMock(), warehouse_id="wh-1")
            sync._drain_progress_fn = tracker._sync_orch_progress_events
            with s.begin_nested():
                sync._final_drain(run_id)
                s.get(Run, run_id).progress_message = "synced"
            s.commit()
        with Session(engine) as s:
            run = s.get(Run, run_id)
            assert run.progress_message == "synced"
            assert run.last_poll_error.startswith(f"Could not read the agent's progress ({state}): ")


# ---------------------------------------------------------------------------
# _generation_common: an unreadable session row fails the op
# ---------------------------------------------------------------------------


class TestPipelineErrorCheck:
    """``_check_pipeline_error`` runs after the job succeeded and model.json
    was found. A missing table or no row means no pipeline error; a read that
    fails returns a failure message, so the op fails instead of syncing."""

    def _check(self, monkeypatch, ws):
        from vibe_modeling.backend.services.operations import _generation_common as gc

        monkeypatch.setattr(gc, "get_warehouse_id", lambda _s: "wh-1")
        ctx = SimpleNamespace(params={"deployment_catalog": "cat"})
        return gc._check_pipeline_error(ws, MagicMock(), ctx, "sess-1")

    def test_a_failed_read_fails_the_op(self, monkeypatch):
        msg = self._check(monkeypatch, ws_returning(_failed()))
        assert msg.startswith(
            "The agent finished and wrote the model, but the app could not read the agent's run "
            "record to check it for errors (FAILED): "
        )
        assert msg.endswith("Retry the run. If this happens again, ask an admin to check the SQL warehouse.")
        assert "reader@example.com" not in msg

    def test_a_read_still_running_after_about_110s_fails_the_op(self, monkeypatch, clock):
        ws = ws_returning(_running(), clock=clock, poll_cost_s=5.0)
        assert "(TIMEOUT)" in self._check(monkeypatch, ws)
        assert ws.waits == ["50s"]
        assert 100 <= clock.elapsed <= 116

    def test_a_cold_warehouse_that_answers_within_the_bound_is_read(self, monkeypatch, clock):
        row = ["100.0", "done", None, None, "acme", "1", "ecm"]
        answers = iter([response(state="RUNNING", statement_id="r1")] * 3)

        def polls(sid):
            return next(answers, response([row], statement_id=sid))

        ws = ws_returning(_running(), clock=clock, poll_cost_s=5.0, polls=polls)
        assert self._check(monkeypatch, ws) == ""

    def test_a_missing_table_is_no_pipeline_error(self, monkeypatch):
        assert self._check(monkeypatch, ws_returning(_missing())) == ""

    def test_a_recorded_pipeline_error_fails_the_op(self, monkeypatch):
        row = ["100.0", "done", None, '{"status": "pipeline_error", "error": "bad FK"}', "acme", "1", "ecm"]
        assert self._check(monkeypatch, ws_returning(response([row]))) == "bad FK"


# ---------------------------------------------------------------------------
# model_sync: every failure raises; reads wait ~110 s
# ---------------------------------------------------------------------------


class TestModelSync:
    """Registry reads during sync wait 50 s, then poll 2 s apart up to about
    110 s; writes wait 50 s. Every failure raises; a missing table is None for
    a read, and is skipped only by the version delete."""

    def _svc(self, ws):
        return ModelSyncService(session=MagicMock(), ws=ws, warehouse_id="wh-1")

    def test_a_failed_read_raises(self):
        with pytest.raises(SqlStatementError) as exc:
            self._svc(ws_returning(_failed()))._query_delta_table("cat", "_metamodel", "domain", "acme", "1")
        assert exc.value.state == "FAILED"

    def test_a_read_still_running_is_cancelled_after_about_110s(self, clock):
        ws = ws_returning(_running(), clock=clock, poll_cost_s=5.0)
        with pytest.raises(SqlStatementError) as exc:
            self._svc(ws)._query_delta_table("cat", "_metamodel", "domain", "acme", "1")
        assert exc.value.state == "TIMEOUT"
        assert ws.waits == ["50s"]
        assert 100 <= clock.elapsed <= 116
        ws.statement_execution.cancel_execution.assert_called_once_with("r1")

    def test_a_missing_table_reads_as_none(self):
        assert self._svc(ws_returning(_missing()))._query_delta_table(
            "cat", "_metamodel", "domain", "acme", "1",
        ) is None

    @pytest.mark.parametrize("answer,state", [(_failed(), "FAILED"), (_running(), "TIMEOUT")])
    def test_a_write_raises(self, answer, state, monkeypatch):
        # The registry setup before the write is covered in test_metamodel_registry_setup.py.
        monkeypatch.setattr("vibe_modeling.backend.model_sync.ensure_metamodel_registry", lambda *a, **k: [])
        ws = ws_returning(response([["0"]]), answer)
        with pytest.raises(SqlStatementError) as exc:
            self._svc(ws).write_model_to_delta("cat", "acme", "1", "ecm", "/v", {"domains": []})
        assert exc.value.state == state
        assert ws.waits == ["30s", "50s"]

    def test_a_failed_existence_check_raises_instead_of_reading_as_not_installed(self):
        with pytest.raises(SqlStatementError):
            self._svc(ws_returning(_failed())).delete_metamodel_rows("cat", "acme", "1", "ecm")

    def test_delete_skips_a_missing_table(self):
        ws = ws_returning(response([["1"]]), _missing())
        assert self._svc(ws).delete_metamodel_rows("cat", "acme", "1", "ecm") is True
        assert [s.split()[0] for s in ws.statements] == ["SELECT", "DELETE", "DELETE", "DELETE", "DELETE"]

    def test_delete_of_a_version_never_written_here(self):
        ws = ws_returning(_missing())
        assert self._svc(ws).delete_metamodel_rows("cat", "acme", "1", "ecm") is False
        assert len(ws.statements) == 1


# ---------------------------------------------------------------------------
# vibe_iterate.observe: lenient percent poll
# ---------------------------------------------------------------------------


class TestVibeIterateObserve:
    """The in-flight percent poll is lenient: any SQL failure leaves the
    observation at 0 % "Running" (the progress tracker owns the visible
    mirror). One 5 s wait, then the read is cancelled."""

    def _observe(self, monkeypatch, ws):
        from vibe_modeling.backend.services.operations import vibe_iterate as vi
        from vibe_modeling.backend.services.operations._protocol import OperationDispatchHandle

        monkeypatch.setattr(vi, "get_warehouse_id", lambda _s: "wh-1")
        ws.jobs.get_run.return_value = SimpleNamespace(state=SimpleNamespace(
            life_cycle_state=SimpleNamespace(value="RUNNING"), result_state=None,
        ))
        handle = OperationDispatchHandle(
            databricks_run_id=11, vibe_session_id="s",
            extra={"session_id_bigint": 7, "deployment_catalog": "cat"},
        )
        return vi.VibeIterate().observe(handle, None, ws, MagicMock())

    @pytest.mark.parametrize("answer", [_failed(), _running(), _missing()],
                             ids=["failed", "timeout", "missing_table"])
    def test_a_failed_percent_poll_is_still_running(self, monkeypatch, answer):
        ws = ws_returning(answer)
        obs = self._observe(monkeypatch, ws)
        assert (obs.progress_percent, obs.progress_message, obs.is_terminal) == (0, "Running", False)
        assert ws.waits == ["5s"]

    def test_a_read_percent(self, monkeypatch):
        obs = self._observe(monkeypatch, ws_returning(response([["RUNNING", "42.0", None]])))
        assert (obs.progress_percent, obs.progress_message) == (42, "running")


# ---------------------------------------------------------------------------
# initial_sync: the registry scan raises; a missing table is reported
# ---------------------------------------------------------------------------


class TestInitialSyncScan:
    """One 30 s wait, no polls (it runs inside the import request). A missing
    table is the summary error the routes already show; any other failure
    raises ``SqlStatementError`` (the out-of-band route answers 503)."""

    def _svc(self, ws):
        return InitialSyncService(MagicMock(), ws, "wh-1")

    @pytest.mark.parametrize("answer,state", [(_failed(), "FAILED"), (_running(), "TIMEOUT")])
    def test_a_failed_scan_raises(self, answer, state):
        ws = ws_returning(answer)
        with pytest.raises(SqlStatementError) as exc:
            self._svc(ws).discover_and_sync("cat")
        assert exc.value.state == state
        assert ws.waits == ["30s"]

    def test_a_missing_registry_is_a_summary_error(self):
        summary = self._svc(ws_returning(_missing())).discover_and_sync("cat")
        assert summary["errors"] == ["Table `cat`._metamodel.business not found"]

    @pytest.mark.parametrize("answer", [_failed(), _running()], ids=["failed", "timeout"])
    def test_the_settings_initial_sync_route_answers_503(self, client, engine, mock_ws, answer):
        """Same shape as the out-of-band import: 503 ``oob_scan_failed``,
        sanitized, nothing imported."""
        from vibe_modeling.backend.db_models import AgentConfig, Business

        with Session(engine) as s:
            s.add(AgentConfig(notebook_path="/nb", job_id=1, deployment_catalog="cat", warehouse_id="wh-1"))
            s.commit()
        mock_ws.statement_execution = ws_returning(answer).statement_execution

        resp = client.post("/api/config/initial-sync")

        assert resp.status_code == 503, resp.text
        detail = resp.json()["detail"]
        assert detail["error"] == "oob_scan_failed"
        assert detail["message"].startswith("Could not read the agent's model registry: ")
        assert "reader@example.com" not in detail["message"]
        with Session(engine) as s:
            assert s.exec(select(Business)).all() == []
