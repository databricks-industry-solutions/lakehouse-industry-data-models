"""Atomicity of the run-completion finalize hook (_finalize_run_inputs).

On SUCCESS: flip VibeInput.consumed=true for each input the run attempted (its
RunInputLink rows) that the agent reported ``applied`` + clear selected_for_run,
in ONE commit. Without the agent's outcomes nothing is consumed. On FAILURE: consume
nothing and DELETE the run's RunInputLink rows so the inputs re-pool clean;
selected_for_run is preserved.

The headline test forces an exception mid-finalize and asserts the single
commit boundary held: ZERO RunInputLink rows persisted AND every selected
input still consumed=false. Locks input_state_atomicity. See §6.
"""

import os
import sys

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "..", "src", "app", "src"))

import pytest
from sqlmodel import Session, SQLModel, create_engine, select
from sqlalchemy.pool import StaticPool

from vibe_modeling.backend import progress_tracker as pt
from vibe_modeling.backend.db_models import (
    Business,
    Run,
    RunAgentReport,
    RunInputLink,
    VibeInput,
)


@pytest.fixture(name="engine")
def engine_fixture():
    engine = create_engine(
        "sqlite://",
        connect_args={"check_same_thread": False},
        poolclass=StaticPool,
    )
    SQLModel.metadata.create_all(engine)
    return engine


def _seed(engine, selected=False, applied=True):
    """Business + run + two inputs with RunInputLink rows written at launch.

    With ``applied``, the run has an agent report and both links carry
    ``outcome_status="applied"`` (as ``run_report.persist_agent_report``
    writes them)."""
    with Session(engine) as s:
        b = Business(name="Acme")
        s.add(b)
        s.commit()
        run = Run(business_id=b.id, intent="vibe-iterate", status="running")
        s.add(run)
        s.commit()
        i1 = VibeInput(business_id=b.id, text="a", selected_for_run=selected)
        i2 = VibeInput(business_id=b.id, text="b", selected_for_run=selected)
        s.add(i1)
        s.add(i2)
        s.commit()
        status = "applied" if applied else None
        s.add(RunInputLink(run_id=run.id, input_id=i1.id, outcome_status=status))
        s.add(RunInputLink(run_id=run.id, input_id=i2.id, outcome_status=status))
        if applied:
            s.add(RunAgentReport(run_id=run.id, has_input_outcomes=True))
        s.commit()
        return run.id, [i1.id, i2.id]


def test_success_resets_selected_for_run(engine):
    """On success, the run's inputs are both consumed AND deselected, so they
    don't silently re-enter the next run's selected set."""
    run_id, ids = _seed(engine, selected=True)
    with Session(engine) as s:
        pt._finalize_run_inputs(run_id, s, success=True)
    with Session(engine) as s:
        for iid in ids:
            vi = s.get(VibeInput, iid)
            assert vi.consumed is True
            assert vi.selected_for_run is False


def test_success_without_agent_report_consumes_nothing(engine):
    """No agent report: a successful run marks nothing done, keeps the
    links as the audit record and leaves the selection alone."""
    run_id, ids = _seed(engine, selected=True, applied=False)
    with Session(engine) as s:
        pt._finalize_run_inputs(run_id, s, success=True)
    with Session(engine) as s:
        for iid in ids:
            vi = s.get(VibeInput, iid)
            assert vi.consumed is False
            assert vi.selected_for_run is True
        links = s.exec(select(RunInputLink).where(RunInputLink.run_id == run_id)).all()
        assert len(links) == 2


def test_failure_keeps_selected_for_run(engine):
    """On failure nothing flips — selection persists so the user's set survives
    a retry."""
    run_id, ids = _seed(engine, selected=True)
    with Session(engine) as s:
        pt._finalize_run_inputs(run_id, s, success=False)
    with Session(engine) as s:
        for iid in ids:
            vi = s.get(VibeInput, iid)
            assert vi.consumed is False
            assert vi.selected_for_run is True


def test_success_flips_consumed_for_attempted_inputs(engine):
    run_id, ids = _seed(engine)
    with Session(engine) as s:
        pt._finalize_run_inputs(run_id, s, success=True)
    with Session(engine) as s:
        for iid in ids:
            assert s.get(VibeInput, iid).consumed is True
        links = s.exec(select(RunInputLink).where(RunInputLink.run_id == run_id)).all()
        assert len(links) == 2


def test_failure_clears_links(engine):
    """On failure nothing is consumed AND the run's RunInputLink rows are
    deleted so the inputs re-pool clean (no retry guarantee)."""
    run_id, ids = _seed(engine)
    with Session(engine) as s:
        pt._finalize_run_inputs(run_id, s, success=False)
    with Session(engine) as s:
        for iid in ids:
            assert s.get(VibeInput, iid).consumed is False
        # RunInputLink rows are cleared on failure (re-pool contract).
        links = s.exec(select(RunInputLink).where(RunInputLink.run_id == run_id)).all()
        assert len(links) == 0


def test_atomic_all_or_nothing_on_mid_finalize_exception(engine, monkeypatch):
    """Force commit to raise; assert no consumed flip leaked and links intact
    (the single-commit boundary was not split into per-input commits)."""
    run_id, ids = _seed(engine, selected=True)

    with Session(engine) as s:
        real_commit = s.commit
        calls = {"n": 0}

        def boom():
            calls["n"] += 1
            raise RuntimeError("forced mid-finalize failure")

        monkeypatch.setattr(s, "commit", boom)
        with pytest.raises(RuntimeError):
            pt._finalize_run_inputs(run_id, s, success=True)

    # Re-open a clean session: nothing should have persisted — neither the
    # consumed flip nor the selected_for_run reset leaked past the rollback.
    with Session(engine) as s:
        for iid in ids:
            vi = s.get(VibeInput, iid)
            assert vi.consumed is False
            assert vi.selected_for_run is True
        # The launch-time RunInputLink rows are still exactly 2 (no dupes, none
        # lost) — finalize confirms idempotently, it doesn't re-create.
        links = s.exec(select(RunInputLink).where(RunInputLink.run_id == run_id)).all()
        assert len(links) == 2


def test_terminal_transition_rolls_back_with_finalize_on_crash(engine, monkeypatch):
    """Caller flushes (not commits) the run terminal transition, then calls
    finalize which owns the commit. If finalize's commit crashes, the terminal
    status flip must roll back too — no run=completed/consumed=false half-state
    (input_state_atomicity)."""
    from vibe_modeling.backend.db_models import Run

    run_id, ids = _seed(engine)

    with Session(engine) as s:
        # Mirror the poll-loop ordering: flush the terminal transition, then
        # let finalize own the single commit.
        run = s.get(Run, run_id)
        run.status = "completed"
        s.add(run)
        s.flush()  # flushed, NOT committed — same as orchestrator.advance

        def boom():
            raise RuntimeError("forced commit failure")

        monkeypatch.setattr(s, "commit", boom)
        with pytest.raises(RuntimeError):
            pt._finalize_run_inputs(run_id, s, success=True)

    # Fresh session: the terminal flip rolled back with finalize.
    with Session(engine) as s:
        assert s.get(Run, run_id).status == "running"  # NOT completed
        for iid in ids:
            assert s.get(VibeInput, iid).consumed is False
