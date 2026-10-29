"""Adversarial tests for the D-09 user-visible watchdog feature (#51).

The progress endpoint must surface enough state for the UI to render the
watchdog signals — warm-up, armed, tripped (stale / failed), disarmed,
last Jobs API state seen, last poll error, and elapsed seconds. None of
these signals exist on `main` today, so every test here is expected to
FAIL on `main` and PASS once the dev agent's PR lands.

Tests are derived purely from the contract:

* `watchdog_state`: one of "armed", "warming_up", "tripped_stale",
  "tripped_failed", "disarmed".
* `watchdog_warm_up_seconds_remaining`: int seconds left in warm-up
  (0 once armed / disarmed / tripped).
* `last_jobs_api_state`: last seen `life_cycle_state/result_state`
  (e.g. "RUNNING/", "TERMINATED/SUCCESS"). Empty until the tracker has
  polled at least once.
* `last_poll_error`: error message from the last poll attempt; empty
  string when the last poll succeeded.
* `elapsed_seconds`: seconds since started_at (fallback created_at).

The tests assert qualitative behaviour — they do not bind themselves to
the exact `STALE_THRESHOLD_MINUTES` / `WATCHDOG_WARM_UP_SECONDS` values
because those numbers are explicitly allowed to be relaxed.
"""

import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "..", "src", "app", "src"))

import json
from contextlib import contextmanager
from datetime import datetime, timedelta, timezone
from unittest.mock import MagicMock, patch

import pytest
from fastapi.testclient import TestClient
from sqlalchemy.pool import StaticPool
from sqlmodel import Session, SQLModel, create_engine

from _test_app import make_test_app
from vibe_modeling.backend.core._config import AppConfig
from vibe_modeling.backend.core._defaults import (
    _ConfigDependency,
    _WorkspaceClientDependency,
)
from vibe_modeling.backend.core._tracker import _TrackerDependency
from vibe_modeling.backend.core.lakebase import _LakebaseDependency
from vibe_modeling.backend.db_models import (
    Business,
    Run,
    RunOperation,
    RunProgressEvent,
)
from vibe_modeling.backend.progress_tracker import (
    ProgressTracker,
    SessionStatus,
    WATCHDOG_WARM_UP_SECONDS,
)
from vibe_modeling.backend.router import router


# ---------------------------------------------------------------------------
# Fixtures
# ---------------------------------------------------------------------------


@pytest.fixture
def engine():
    e = create_engine(
        "sqlite://",
        connect_args={"check_same_thread": False},
        poolclass=StaticPool,
    )
    SQLModel.metadata.create_all(e)
    return e


@pytest.fixture
def session_factory(engine):
    @contextmanager
    def _factory():
        with Session(engine) as s:
            yield s

    return _factory


@pytest.fixture
def mock_ws():
    ws = MagicMock()
    ws.config.host = "https://test-workspace.databricks.com"
    job_run = MagicMock()
    job_run.state.life_cycle_state.value = "RUNNING"
    job_run.state.result_state.value = ""
    job_run.state.state_message = ""
    job_run.tasks = []
    ws.jobs.get_run.return_value = job_run
    return ws


@pytest.fixture
def config():
    return AppConfig(
        app_name="test", warehouse_id="test-warehouse-id", poll_interval_seconds=0
    )


@pytest.fixture
def tracker(mock_ws, config, session_factory):
    return ProgressTracker(ws=mock_ws, config=config, session_factory=session_factory)


@pytest.fixture
def client(engine, mock_ws, config, tracker):
    """TestClient where the real ProgressTracker is wired in so the progress
    endpoint can ask it for the current watchdog signals. Tests that need a
    pure mock tracker can still use the conftest-level `client` fixture."""
    app = make_test_app(router)

    def override_session():
        with Session(engine) as s:
            yield s

    def override_config():
        return config

    def override_ws():
        return mock_ws

    def override_tracker():
        return tracker

    app.dependency_overrides[_LakebaseDependency.__call__] = override_session
    app.dependency_overrides[_ConfigDependency.__call__] = override_config
    app.dependency_overrides[_WorkspaceClientDependency.__call__] = override_ws
    app.dependency_overrides[_TrackerDependency.__call__] = override_tracker

    return TestClient(app)


@pytest.fixture
def seed_business(engine) -> str:
    with Session(engine) as s:
        b = Business(name="Test Corp", description="t", industry_alignment="Retail")
        s.add(b)
        s.commit()
        s.refresh(b)
        return b.id


def _make_run(business_id: str, **overrides) -> Run:
    defaults = dict(
        business_id=business_id,
        intent="new-base-model",
        status="running",
        databricks_run_id=12345,
        vibe_session_id="sid-1",
        vibe_session_id_bigint=99999,
        started_at=datetime.now(timezone.utc),
        parameters_json=json.dumps(
            {"operation": "new base model", "deployment_catalog": "test_cat"}
        ),
    )
    defaults.update(overrides)
    return Run(**defaults)


def _get_run_payload(client, bid: str, run_id: str) -> dict:
    """Hit the canonical run endpoint. The contract calls this the
    "progress endpoint" — we accept either GET /runs/{id} or
    GET /runs/{id}/progress, whichever the dev agent surfaced the
    signals on. Today GET /runs/{id} returns the RunOut envelope and
    /runs/{id}/progress returns a list of progress events; we read
    /runs/{id} as the per-run state surface."""
    resp = client.get(f"/api/businesses/{bid}/runs/{run_id}")
    assert resp.status_code == 200, resp.text
    return resp.json()


# ---------------------------------------------------------------------------
# 1. Warming-up state visible
# ---------------------------------------------------------------------------


class TestWatchdogStateVisible:
    def test_warming_up_state_visible_for_fresh_run(
        self, client, engine, seed_business
    ):
        """A model-producing run inside the warm-up window: the API must
        report `watchdog_state="warming_up"` and a positive
        `watchdog_warm_up_seconds_remaining`."""
        with Session(engine) as s:
            run = _make_run(
                seed_business,
                started_at=datetime.now(timezone.utc),
                last_consumed_step_id=0,
            )
            s.add(run)
            s.commit()
            run_id = run.id

        body = _get_run_payload(client, seed_business, run_id)
        assert body.get("watchdog_state") == "warming_up", (
            f"Expected watchdog_state='warming_up' for a fresh run, got "
            f"{body.get('watchdog_state')!r}. Full body: {body}"
        )
        remaining = body.get("watchdog_warm_up_seconds_remaining")
        assert isinstance(remaining, int), (
            f"watchdog_warm_up_seconds_remaining must be int, got {type(remaining)}"
        )
        assert remaining > 0, (
            f"warm-up seconds remaining must be > 0 inside warm-up; got {remaining}"
        )

    def test_armed_state_visible_after_warmup(self, client, engine, seed_business):
        """A run that has elapsed past the warm-up window with no events yet
        should report `watchdog_state="armed"` and 0 seconds remaining."""
        with Session(engine) as s:
            run = _make_run(
                seed_business,
                started_at=datetime.now(timezone.utc)
                - timedelta(seconds=WATCHDOG_WARM_UP_SECONDS + 600),
                last_consumed_step_id=0,
            )
            s.add(run)
            s.commit()
            run_id = run.id

        body = _get_run_payload(client, seed_business, run_id)
        assert body.get("watchdog_state") == "armed", (
            f"Expected watchdog_state='armed', got {body.get('watchdog_state')!r}"
        )
        assert body.get("watchdog_warm_up_seconds_remaining") == 0, (
            f"warm-up seconds remaining must be 0 once armed; got "
            f"{body.get('watchdog_warm_up_seconds_remaining')!r}"
        )

    def test_armed_state_visible_after_first_event(
        self, client, engine, seed_business
    ):
        """A run that has consumed at least one progress event arms the
        watchdog immediately, regardless of warm-up window. Same response
        shape as the post-warmup case."""
        with Session(engine) as s:
            run = _make_run(
                seed_business,
                started_at=datetime.now(timezone.utc),
                last_consumed_step_id=42,
            )
            s.add(run)
            s.commit()
            run_id = run.id

        body = _get_run_payload(client, seed_business, run_id)
        assert body.get("watchdog_state") == "armed", (
            f"Run with last_consumed_step_id>0 must be armed, got "
            f"{body.get('watchdog_state')!r}"
        )
        assert body.get("watchdog_warm_up_seconds_remaining") == 0

    def test_stale_state_visible(self, client, engine, seed_business, mock_ws):
        """Once the watchdog has marked a run `stale`, the progress payload
        surfaces `watchdog_state="tripped_stale"` and a non-empty
        `last_jobs_api_state` so the user can see WHY the run is paused.

        `last_jobs_api_state` is persisted by the tracker on every Jobs API
        poll — by the time a run is `stale`, the tracker has populated it
        with the most recent (lcs/rs) pair. The test seeds it directly to
        mirror that production state.
        """
        # Mirror the production "watchdog set status=stale" path: app run is
        # in the stale lane, and the Databricks job is still running.
        with Session(engine) as s:
            run = _make_run(
                seed_business,
                status="stale",
                started_at=datetime.now(timezone.utc) - timedelta(minutes=30),
                last_consumed_step_id=99,
                last_jobs_api_state="RUNNING/",  # tracker captured this on last poll
                progress_message=(
                    "Tracker paused after repeated errors "
                    "(Databricks job state: RUNNING). "
                    "The run will resume on next app restart."
                ),
            )
            s.add(run)
            s.commit()
            run_id = run.id

        body = _get_run_payload(client, seed_business, run_id)
        assert body.get("watchdog_state") == "tripped_stale", (
            f"Stale-marked run must report watchdog_state='tripped_stale', "
            f"got {body.get('watchdog_state')!r}"
        )
        last_state = body.get("last_jobs_api_state")
        assert isinstance(last_state, str) and last_state.strip() != "", (
            f"last_jobs_api_state must be a non-empty string for a tripped "
            f"watchdog so the user knows what state Databricks reported; "
            f"got {last_state!r}"
        )

    def test_failed_state_visible(self, client, engine, seed_business):
        """A run the watchdog declared failed (status='failed' set by
        `_check_job_termination` / `_handle_watchdog_exit`) reports
        `watchdog_state="tripped_failed"`."""
        with Session(engine) as s:
            run = _make_run(
                seed_business,
                status="failed",
                started_at=datetime.now(timezone.utc) - timedelta(minutes=30),
                completed_at=datetime.now(timezone.utc),
                last_consumed_step_id=10,
                error_message="job ended with TERMINATED/FAILED",
            )
            s.add(run)
            s.commit()
            run_id = run.id

        body = _get_run_payload(client, seed_business, run_id)
        assert body.get("watchdog_state") == "tripped_failed", (
            f"Failed run must report watchdog_state='tripped_failed', "
            f"got {body.get('watchdog_state')!r}"
        )

    @pytest.mark.parametrize("terminal_status", ["completed", "cancelled"])
    def test_disarmed_for_terminal_runs(
        self, client, engine, seed_business, terminal_status
    ):
        """Runs that completed cleanly or were cancelled by the user are
        disarmed — there is nothing for the watchdog to do."""
        with Session(engine) as s:
            run = _make_run(
                seed_business,
                status=terminal_status,
                started_at=datetime.now(timezone.utc) - timedelta(minutes=15),
                completed_at=datetime.now(timezone.utc),
                last_consumed_step_id=999,
            )
            s.add(run)
            s.commit()
            run_id = run.id

        body = _get_run_payload(client, seed_business, run_id)
        assert body.get("watchdog_state") == "disarmed", (
            f"Terminal status={terminal_status!r} must report "
            f"watchdog_state='disarmed', got {body.get('watchdog_state')!r}"
        )



# ---------------------------------------------------------------------------
# 3. elapsed_seconds monotonic
# ---------------------------------------------------------------------------


class TestElapsedSeconds:
    def test_elapsed_seconds_increases_between_reads(
        self, client, engine, seed_business
    ):
        """Two reads of the progress endpoint, with `datetime.now`
        advanced by 5 s in between, must report a strictly increasing
        `elapsed_seconds` value."""
        # We anchor started_at well before NOW so any clamp to >= 0
        # still produces a meaningful number.
        anchor = datetime(2026, 4, 25, 12, 0, 0, tzinfo=timezone.utc)
        with Session(engine) as s:
            run = _make_run(
                seed_business,
                started_at=anchor,
                last_consumed_step_id=0,
            )
            s.add(run)
            s.commit()
            run_id = run.id

        # The router/tracker may compute elapsed via either
        # `datetime.now` (utcnow path) or `time.time` — patch both to
        # be safe so this test doesn't depend on which the dev agent
        # picked. Returning a fixed monotonically-advancing instant
        # avoids the flakiness of relying on the wall clock.
        first_now = anchor + timedelta(seconds=30)
        second_now = anchor + timedelta(seconds=35)

        def _read(now_value):
            # `_build_run_out` (where elapsed_seconds is computed) lives in
            # `routes/_helpers.py` after task #33's route split. Patch BOTH
            # that path and the tracker's so the test doesn't depend on
            # which side computes elapsed.
            with patch(
                "vibe_modeling.backend.routes._helpers.datetime"
            ) as helpers_dt, patch(
                "vibe_modeling.backend.progress_tracker.datetime"
            ) as tracker_dt:
                helpers_dt.now = MagicMock(return_value=now_value)
                tracker_dt.now = MagicMock(return_value=now_value)
                # Keep .timezone attribute reachable since code does
                # `datetime.now(timezone.utc)`.
                helpers_dt.timezone = timezone
                tracker_dt.timezone = timezone
                # Also keep timedelta + datetime constructors usable.
                helpers_dt.timedelta = timedelta
                tracker_dt.timedelta = timedelta
                return _get_run_payload(client, seed_business, run_id)

        first = _read(first_now)
        second = _read(second_now)

        e1 = first.get("elapsed_seconds", None)
        e2 = second.get("elapsed_seconds", None)
        assert isinstance(e1, int) and isinstance(e2, int), (
            f"elapsed_seconds must be int on both reads; got first={e1!r} "
            f"second={e2!r}"
        )
        assert e2 > e1, (
            f"elapsed_seconds must increase across two reads; "
            f"first={e1}, second={e2}"
        )


# ---------------------------------------------------------------------------
# 4. last_poll_error round-trip (populated on poll failure, cleared on success)
# ---------------------------------------------------------------------------


class TestLastPollError:
    """``Run.last_poll_error`` carries the ``repr`` of the most recent
    poll exception so the UI can surface WHY the watchdog is unhappy.
    Production write path lives in ``_record_poll_signals``; the
    populating callsite is ``_sync_orch_progress_events`` when
    ``_poll_session_status_by_id`` raises.

    Restored from the legacy ``test_watchdog_ui_signals.TestLastPollError``
    that was deleted during the Stage 1 cleanup but whose covered
    behaviour is still alive in progress_tracker.py L1242-L1243.
    """

    def _seed_orch_run(self, engine, business_id: str) -> str:
        """Run + one running RunOperation + one progress event so
        ``_sync_orch_progress_events`` reaches the
        ``_poll_session_status_by_id`` call (rather than early-returning
        on no-running-op or no-events-drained)."""
        with Session(engine) as s:
            run = Run(
                business_id=business_id,
                intent="new-base-model",
                status="running",
                databricks_run_id=12345,
                vibe_session_id_bigint=99999,
                started_at=datetime.now(timezone.utc),
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
            ))
            s.add(RunProgressEvent(
                run_id=run.id, step_id=1, event_seq=1,
                stage_name="Vibe Session", step_name="Session Started",
                status="stage_in_progress", message="seeded",
                progress_increment=0.0, result_json="{}",
            ))
            s.commit()
            return run.id

    def test_poll_failure_populates_last_poll_error(
        self, tracker, engine, seed_business
    ):
        """When ``_poll_session_status_by_id`` raises an SDK-style error
        the tracker persists a sanitized sentence naming it to
        ``Run.last_poll_error`` so the UI can render it."""
        run_id = self._seed_orch_run(engine, seed_business)
        boom = RuntimeError("transient SDK timeout")
        with patch.object(
            tracker, "_poll_session_status_by_id", side_effect=boom
        ), patch.object(
            tracker, "_poll_progress_events", return_value=[]
        ), Session(engine) as s:
            run = s.get(Run, run_id)
            tracker._sync_orch_progress_events(run, s)
            s.commit()

        with Session(engine) as s:
            run = s.get(Run, run_id)
            assert run.last_poll_error == (
                "Could not read the agent's progress: transient SDK timeout"
            ), run.last_poll_error

    def test_successful_poll_clears_last_poll_error(
        self, tracker, engine, seed_business
    ):
        """A subsequent ``_record_poll_signals(poll_error="")`` after the
        next successful poll must clear ``Run.last_poll_error`` back to
        the empty string. Validates the write-path contract documented
        on ``_record_poll_signals`` (progress_tracker.py L1234)."""
        run_id = self._seed_orch_run(engine, seed_business)
        # First: simulate a transient failure that populates the field.
        with patch.object(
            tracker, "_poll_session_status_by_id",
            side_effect=RuntimeError("boom"),
        ), patch.object(
            tracker, "_poll_progress_events", return_value=[],
        ), Session(engine) as s:
            run = s.get(Run, run_id)
            tracker._sync_orch_progress_events(run, s)
            s.commit()

        with Session(engine) as s:
            run = s.get(Run, run_id)
            assert run.last_poll_error, (
                "precondition: last_poll_error must be populated before "
                "we test the clear path"
            )

        # Second: invoke the production write path with poll_error=""
        # — this is the contract callers use to clear after a successful
        # poll.
        with Session(engine) as s:
            run = s.get(Run, run_id)
            tracker._record_poll_signals(
                run, s, jobs_api_state=None, poll_error="",
            )
            s.commit()

        with Session(engine) as s:
            run = s.get(Run, run_id)
            assert run.last_poll_error == "", (
                f"successful poll must clear last_poll_error; got "
                f"{run.last_poll_error!r}"
            )

