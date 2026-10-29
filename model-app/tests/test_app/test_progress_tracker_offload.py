"""The advance tick runs off the event loop.

``_advance_tick``'s body blocks (Jobs API, warehouse SQL, an install
dispatch's bounded ``model.json`` read of up to 15 s), so it runs on the
tracker's own bounded executor. The loop stays free, a run's drain tick
never interleaves with its advance tick, and the run's tick lock is held
until the worker thread ends: through repeated cancels, through
``stop_tracking`` of the whole poll loop, and across a stop-then-resume.
"""

from __future__ import annotations

import asyncio
import contextvars
import os
import sys
import threading
import time
from contextlib import contextmanager
from unittest.mock import MagicMock, patch

import pytest
from sqlalchemy import create_engine
from sqlmodel import Session, SQLModel

sys.path.insert(
    0,
    os.path.join(os.path.dirname(__file__), "..", "..", "src", "app", "src"),
)

from vibe_modeling.backend import progress_tracker as pt  # noqa: E402
from vibe_modeling.backend.core._config import AppConfig  # noqa: E402
from vibe_modeling.backend.db_models import Business, Run  # noqa: E402
from vibe_modeling.backend.progress_tracker import ProgressTracker  # noqa: E402


class _Overlap:
    """Counts how many patched tick bodies run at the same time."""

    def __init__(self):
        self._lock = threading.Lock()
        self.active = 0
        self.max_active = 0

    def enter(self):
        with self._lock:
            self.active += 1
            self.max_active = max(self.max_active, self.active)

    def leave(self):
        with self._lock:
            self.active -= 1


@pytest.fixture
def file_engine(tmp_path):
    """A file-backed SQLite engine with a real pool: the worker thread and
    the loop thread each get their own connection."""
    eng = create_engine(
        f"sqlite:///{tmp_path}/tracker.db",
        connect_args={"check_same_thread": False, "timeout": 30},
    )
    SQLModel.metadata.create_all(eng)
    return eng


@pytest.fixture
def tracker(file_engine):
    @contextmanager
    def _factory():
        with Session(file_engine) as session:
            yield session

    config = AppConfig(
        app_name="test", warehouse_id="w",
        poll_interval_seconds=0, drain_interval_seconds=0,
    )
    t = ProgressTracker(ws=MagicMock(), config=config, session_factory=_factory)
    yield t
    t._tick_executor.shutdown(wait=False, cancel_futures=True)


@pytest.fixture
def running_run(file_engine) -> str:
    with Session(file_engine) as s:
        b = Business(name="Test Corp", description="t", industry_alignment="Retail")
        s.add(b)
        s.flush()
        run = Run(business_id=b.id, intent="install", status="running")
        s.add(run)
        s.commit()
        return run.id


def _patched(tracker, advance, drain=None):
    """Patch the tick bodies; the Jobs API fallback is a no-op."""
    return (
        patch.object(tracker.orchestrator, "advance", side_effect=advance),
        patch.object(tracker, "_fail_op_if_jobs_api_terminal"),
        patch.object(tracker, "_sync_orch_progress_events", side_effect=drain),
    )


async def _until(predicate, timeout: float = 5.0) -> None:
    deadline = time.monotonic() + timeout
    while not predicate():
        assert time.monotonic() < deadline, "condition not reached"
        await asyncio.sleep(0.01)


@pytest.mark.asyncio
async def test_advance_runs_on_the_trackers_executor(tracker, running_run):
    request_id = contextvars.ContextVar("request_id", default="")
    request_id.set("req-42")
    seen: dict = {}

    def _advance(run, session):
        seen["thread"] = threading.current_thread().name
        seen["request_id"] = request_id.get()
        return None

    a, b, c = _patched(tracker, _advance)
    with a, b, c:
        assert await tracker._advance_tick(running_run) is False
    assert seen["thread"].startswith("tracker-tick")
    assert seen["request_id"] == "req-42"


@pytest.mark.asyncio
async def test_blocking_advance_leaves_the_loop_free(tracker, running_run):
    release = threading.Event()

    def _advance(run, session):
        release.wait(5)
        return None

    a, b, c = _patched(tracker, _advance)
    with a, b, c:
        tick = asyncio.create_task(tracker._advance_tick(running_run))
        t0 = time.monotonic()
        for _ in range(5):
            await asyncio.sleep(0.01)
        assert time.monotonic() - t0 < 1.0
        assert not tick.done()
        release.set()
        assert await tick is False


@pytest.mark.asyncio
async def test_same_run_ticks_never_interleave(tracker, running_run):
    overlap = _Overlap()

    def _advance(run, session):
        overlap.enter()
        time.sleep(0.01)
        overlap.leave()
        return None

    def _drain(run, session):
        overlap.enter()
        time.sleep(0.003)
        overlap.leave()

    a, b, c = _patched(tracker, _advance, _drain)
    with a, b, c:
        ticks = []
        for _ in range(20):
            ticks += [
                tracker._advance_tick(running_run),
                tracker._drain_tick(running_run),
                tracker._drain_tick(running_run),
            ]
        await asyncio.gather(*ticks)
    assert overlap.max_active == 1


@pytest.mark.asyncio
async def test_drain_waits_for_the_same_runs_advance(tracker, running_run):
    release = threading.Event()
    order: list[str] = []

    def _advance(run, session):
        order.append("advance-start")
        release.wait(5)
        order.append("advance-end")
        return None

    def _drain(run, session):
        order.append("drain")

    a, b, c = _patched(tracker, _advance, _drain)
    with a, b, c:
        advance = asyncio.create_task(tracker._advance_tick(running_run))
        await _until(lambda: "advance-start" in order)
        drain = asyncio.create_task(tracker._drain_tick(running_run))
        await asyncio.sleep(0.05)
        assert order == ["advance-start"]
        release.set()
        await asyncio.gather(advance, drain)
    assert order == ["advance-start", "advance-end", "drain"]


@pytest.mark.asyncio
@pytest.mark.parametrize("cancels", [1, 3])
async def test_cancels_keep_the_lock_until_the_thread_ends(tracker, running_run, cancels):
    release = threading.Event()
    in_thread = threading.Event()
    finished = threading.Event()

    def _advance(run, session):
        in_thread.set()
        release.wait(5)
        finished.set()
        return None

    a, b, c = _patched(tracker, _advance)
    with a, b, c:
        tick = asyncio.create_task(tracker._advance_tick(running_run))
        await _until(in_thread.is_set)
        for _ in range(cancels):
            tick.cancel()
            await asyncio.sleep(0.02)
        assert not tick.done()
        assert tracker._tick_lock(running_run).locked()
        release.set()
        with pytest.raises(asyncio.CancelledError):
            await tick
    assert finished.is_set()
    assert not tracker._tick_lock(running_run).locked()


@pytest.mark.asyncio
async def test_stopping_the_poll_loop_mid_tick_keeps_the_lock(tracker, running_run):
    """``stop_tracking`` cancels the whole poll loop. The loop waits for the
    advance thread, and the lock stays held and registered until it ends."""
    in_thread = threading.Event()
    release = threading.Event()

    def _advance(run, session):
        in_thread.set()
        release.wait(5)
        return None

    a, b, c = _patched(tracker, _advance)
    with a, b, c:
        tracker.start_tracking(running_run)
        poll = tracker._tasks[running_run]
        await _until(in_thread.is_set)
        old_lock = tracker._tick_locks[running_run]
        tracker.stop_tracking(running_run)
        await asyncio.sleep(0.05)
        assert not poll.done()
        assert old_lock.locked()
        assert tracker._tick_locks.get(running_run) is old_lock
        assert tracker._tick_lock(running_run) is old_lock
        release.set()
        await asyncio.wait({poll}, timeout=5)
    assert poll.done()
    assert running_run not in tracker._tick_locks


@pytest.mark.asyncio
async def test_stop_then_resume_never_runs_two_ticks(tracker, running_run):
    overlap = _Overlap()
    release = threading.Event()
    calls = {"n": 0}

    def _advance(run, session):
        calls["n"] += 1
        overlap.enter()
        if calls["n"] == 1:
            release.wait(5)
        else:
            time.sleep(0.02)
        overlap.leave()
        return None

    a, b, c = _patched(tracker, _advance)
    with a, b, c:
        tracker.start_tracking(running_run)
        await _until(lambda: calls["n"] == 1)
        tracker.stop_tracking(running_run)
        await asyncio.sleep(0.02)
        tracker.start_tracking(running_run)
        await asyncio.sleep(0.2)
        assert calls["n"] == 1, "a resumed loop advanced while the old tick ran"
        release.set()
        await _until(lambda: calls["n"] >= 2)
        tracker.stop_tracking(running_run)
        await asyncio.sleep(0.1)
    assert overlap.max_active == 1


@pytest.mark.asyncio
async def test_shutdown_waits_briefly_then_stops_the_executor(tracker, running_run):
    in_thread = threading.Event()
    release = threading.Event()

    def _advance(run, session):
        in_thread.set()
        release.wait(5)
        return None

    a, b, c = _patched(tracker, _advance)
    with a, b, c:
        tracker.start_tracking(running_run)
        await _until(in_thread.is_set)
        t0 = time.monotonic()
        await tracker.shutdown(wait_seconds=0.2)
        assert time.monotonic() - t0 < 2.0
        assert tracker._tick_executor._shutdown
        release.set()
        await asyncio.sleep(0.1)


def test_executor_is_bounded():
    assert 1 <= pt.TICK_EXECUTOR_WORKERS <= 32
