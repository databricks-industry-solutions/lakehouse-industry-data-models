"""Phase 3 — Orchestrator (DAG walker) adversarial tests.

These tests exercise the public surface of the Orchestrator class —
the DAG walker that drives a Run through its primitive sequence — per
``docs/orchestrator-design.md`` §4 + §6 + §7.

The Orchestrator class itself is implemented in a parallel branch
(``phase3/orchestrator-runner``). To stay independent, this test file:

* DOES NOT import the implementation directly. Instead it imports
  ``Orchestrator`` from ``vibe_modeling.backend.services.orchestrator``;
  when that symbol does not exist (current ``main``), every test fails
  cleanly with ``ImportError`` at module-collection time.
* Replaces the 9 production primitives with ``FakePrimitive`` — a
  configurable test double — by patching
  ``services.operations._registry.get`` per test.

Adversarial surface covered (one ``Test...`` class per group):

* ``TestHappyPath`` — single-op DAG, multi-op DAG, conditional skip.
* ``TestMidDagFailure`` — terminal failure mid-walk, rollback chain,
  rollback-of-rollback, dispatch-time failure (no rollback).
* ``TestCancelWithRollback`` — user cancel, safety gate, idempotency,
  cancel-during-rollback race.
* ``TestResume`` — app-restart re-attach, admin retry on failed run,
  resume from rolled_back_failed.
* ``TestIdempotency`` — re-dispatch with persisted handle, re-call
  ``start`` on existing rows.
* ``TestPipelineWalks`` — One Catalog 2-op walk + multi-catalog 4-op
  walk.
"""

from __future__ import annotations

import json
import os
import sys
from contextlib import contextmanager
from datetime import datetime, timezone
from typing import Optional
from types import SimpleNamespace
from unittest.mock import MagicMock, patch

# Ensure the in-tree source wins over any installed wheel — same pattern
# as ``tests/test_app/conftest.py``. Belt and braces in case this file
# is collected without the conftest path injection (e.g. ``pytest -k``
# from the repo root).
sys.path.insert(
    0,
    os.path.join(os.path.dirname(__file__), "..", "..", "src", "app", "src"),
)

import pytest
from pydantic import BaseModel
from sqlalchemy.pool import StaticPool
from sqlmodel import Session, SQLModel, create_engine, select

from vibe_modeling.backend.db_models import (
    AgentConfig,
    Business,
    Domain,
    ModelVersion,
    Run,
    RunOperation,
)
from vibe_modeling.backend.services.operations._protocol import (
    Operation,
    OperationContext,
    OperationDispatchHandle,
    OperationObservation,
    OperationResult,
)
from vibe_modeling.backend.services.orchestrator.dag import (
    Dag,
    OperationStep,
)
from vibe_modeling.backend.services.orchestrator import CANCEL_REFUSED_PHASE_SUCCEEDED


# ---------------------------------------------------------------------------
# STUB-FOR-INTEGRATION: import the Orchestrator class from the orchestrator
# package. The implementation lands in `phase3/orchestrator-runner` and
# gets merged through Phase 3. Until that merge:
#
#   * On `main` (no Orchestrator yet) → this import fails with ImportError.
#     All tests in this file collection-error, which is the expected
#     "fails before implementation" signal per the test acceptance bar.
#
# After the integrator drops the class in, no change is required here —
# the symbol resolves and the tests run.
#
# The integrator should preserve the import path:
#   `vibe_modeling.backend.services.orchestrator.Orchestrator`
# (re-export from `__init__.py` is fine; the implementation module name
# doesn't matter to these tests).
# ---------------------------------------------------------------------------
try:
    from vibe_modeling.backend.services.orchestrator import (  # type: ignore[attr-defined]
        Orchestrator,
    )
except ImportError:
    Orchestrator = None  # type: ignore[assignment, misc]


# Per acceptance bar (Phase 3 spec): tests MUST fail on `main` (where
# Orchestrator does not yet exist) with ImportError/NotImplementedError —
# not skip. We enforce that here as an autouse fixture so every test in
# the module fails with a clear, single-line reason on `main` and runs
# normally once the integrator drops the class in.
@pytest.fixture(autouse=True)
def _require_orchestrator():
    if Orchestrator is None:
        raise ImportError(
            "Orchestrator class not yet importable from "
            "vibe_modeling.backend.services.orchestrator — "
            "STUB-FOR-INTEGRATION. Merge phase3/orchestrator-runner."
        )


# ---------------------------------------------------------------------------
# FakePrimitive — test double for any of the 9 registered primitives.
# ---------------------------------------------------------------------------


class _FakeParams(BaseModel):
    """Permissive params model — accepts any kwargs from OperationStep."""

    model_config = {"extra": "allow"}


class FakePrimitive(Operation):
    """Test-only ``Operation`` impl with configurable callbacks.

    Each callback is a callable invoked with the same args the real
    primitive would receive. Default callbacks return success-shaped
    values so tests only override the bits that drive their scenario.
    """

    def __init__(
        self,
        name: str,
        *,
        on_dispatch=None,
        on_observe=None,
        on_rollback=None,
        produces_version: bool = False,
        is_idempotent: bool = True,
    ):
        # Per Operation ABC contract — set the four required class
        # attributes on the instance (singleton-per-test).
        self.name = name
        self.params_model = _FakeParams
        self.is_idempotent = is_idempotent
        self.produces_version = produces_version

        # Default dispatch returns a unique handle so the orchestrator
        # can persist it on RunOperation.databricks_run_id.
        self._on_dispatch = on_dispatch or (
            lambda ctx, ws, session: OperationDispatchHandle(
                databricks_run_id=42,
                vibe_session_id=f"session-{name}",
            )
        )
        # Default observe returns a terminal SUCCESS — single-step DAGs
        # finish immediately under the orchestrator's first observe pass.
        self._on_observe = on_observe or (
            lambda handle, ctx, ws, session: OperationObservation(
                progress_percent=100,
                progress_message=f"{name} ok",
                is_terminal=True,
                terminal_result=OperationResult(
                    succeeded=True,
                    output_version_id=None,
                    output_artifacts=[],
                    rollback_state={"primitive": name},
                    error=None,
                ),
            )
        )
        # Default rollback is a no-op + records the call so tests can
        # assert reverse-order replay.
        self._on_rollback = on_rollback or (
            lambda ctx, rollback_state, ws, session: None
        )

        # Call counters for assertions.
        self.dispatch_calls: list[OperationContext] = []
        self.observe_calls: list[OperationDispatchHandle] = []
        self.rollback_calls: list[dict] = []

    # ------------------------------------------------------------------
    # Operation ABC implementation
    # ------------------------------------------------------------------

    def dispatch(self, ctx, ws, session) -> OperationDispatchHandle:
        self.dispatch_calls.append(ctx)
        return self._on_dispatch(ctx, ws, session)

    def observe(self, handle, ctx, ws, session) -> OperationObservation:
        self.observe_calls.append(handle)
        return self._on_observe(handle, ctx, ws, session)

    def rollback(self, ctx, rollback_state, ws, session) -> None:
        self.rollback_calls.append(rollback_state)
        return self._on_rollback(ctx, rollback_state, ws, session)


# ---------------------------------------------------------------------------
# Helpers — terminal-result factories used across multiple tests.
# ---------------------------------------------------------------------------


def _terminal_success(
    name: str,
    *,
    output_version_id: Optional[str] = None,
    rollback_state: Optional[dict] = None,
) -> OperationObservation:
    return OperationObservation(
        progress_percent=100,
        progress_message=f"{name} ok",
        is_terminal=True,
        terminal_result=OperationResult(
            succeeded=True,
            output_version_id=output_version_id,
            output_artifacts=[],
            rollback_state=rollback_state or {"primitive": name},
            error=None,
        ),
    )


def _terminal_failure(name: str, *, error: str) -> OperationObservation:
    return OperationObservation(
        progress_percent=100,
        progress_message=f"{name} failed",
        is_terminal=True,
        terminal_result=OperationResult(
            succeeded=False,
            output_version_id=None,
            output_artifacts=[],
            rollback_state={},
            error=error,
        ),
    )


def _running(name: str, percent: int = 50) -> OperationObservation:
    return OperationObservation(
        progress_percent=percent,
        progress_message=f"{name} running",
        is_terminal=False,
        terminal_result=None,
    )


# ---------------------------------------------------------------------------
# Fixtures — engine, session, run, ws, registry patcher.
# ---------------------------------------------------------------------------


@pytest.fixture
def engine():
    """In-memory SQLite, freshly migrated."""
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
        with Session(engine) as s:
            yield s

    return _factory


@pytest.fixture
def session(engine):
    """A single committed session for assertions across orchestrator
    calls. Tests that need a fresh transaction open their own."""
    with Session(engine) as s:
        yield s


@pytest.fixture
def mock_ws():
    """Mock WorkspaceClient. ``jobs.cancel_run`` is a MagicMock so tests
    can assert it was/wasn't called. ``jobs.get_run`` returns RUNNING by
    default so the cancel-with-rollback safety gate doesn't trip."""
    ws = MagicMock()
    ws.config.host = "https://test-workspace.databricks.com"
    state = MagicMock()
    state.life_cycle_state = MagicMock()
    state.life_cycle_state.value = "RUNNING"
    state.result_state = None
    job_run = MagicMock()
    job_run.state = state
    ws.jobs.get_run.return_value = job_run
    return ws


@pytest.fixture
def business(engine):
    """Seed a Business and return its id."""
    with Session(engine) as s:
        b = Business(name="Test Co", description="t", industry_alignment="x")
        s.add(b)
        s.commit()
        s.refresh(b)
        return b.id


def _make_run(session: Session, business_id: str, *, status: str = "pending") -> Run:
    """Create a Run row with sane defaults."""
    run = Run(
        business_id=business_id,
        intent="new-base-model",
        status=status,
        parameters_json="{}",
    )
    session.add(run)
    session.commit()
    session.refresh(run)
    return run


@pytest.fixture
def patched_registry():
    """Per-test registry override.

    Tests fill the dict with ``{name: FakePrimitive(name=...)}`` then
    patch ``services.operations._registry.get`` to look up against the
    dict. Returns the dict so the test can keep references for
    assertions.
    """
    fakes: dict[str, FakePrimitive] = {}

    def _get(name: str):
        try:
            return fakes[name]
        except KeyError as exc:
            raise KeyError(name) from exc

    with patch(
        "vibe_modeling.backend.services.operations._registry.get",
        side_effect=_get,
    ):
        yield fakes


# A second hook into the same patch — some orchestrator implementations
# may import `get` directly from the package (`from services.operations
# import get`). Patch both names so either binding resolves. Pytest
# allows nested context-manager fixtures via dependency.
@pytest.fixture
def patched_registry_full(patched_registry):
    """Patch every plausible import binding of `get` so the test's fake
    registry is honoured regardless of how the Orchestrator imports it."""
    targets = [
        "vibe_modeling.backend.services.operations.get",
    ]
    patches = []
    try:
        for tgt in targets:
            try:
                p = patch(tgt, side_effect=lambda name: patched_registry[name])
                patches.append(p)
                p.start()
            except (AttributeError, ModuleNotFoundError):
                # The orchestrator may not import `get` at this binding;
                # skip silently rather than fail the whole test.
                pass
        yield patched_registry
    finally:
        for p in patches:
            p.stop()


# Convenience: flatten "registry + run + dag + orchestrator" boilerplate
# into one helper so each test reads as scenario-spec, not setup-noise.


def _drive_to_terminal(
    orch,
    run: Run,
    session: Session,
    *,
    max_iters: int = 20,
):
    """Repeatedly call ``orch.advance(run, session)`` until the Run
    reaches a terminal status (``completed``/``failed``/``cancelled``/
    ``rolled_back_failed``) or the iteration cap blows.

    The orchestrator is asynchronous-ish — each `advance` invocation
    handles one observe-tick. Tests want to "run the DAG to completion"
    in a controlled, deterministic loop, so we drive it here. If the
    cap blows it almost certainly means an infinite-loop bug in the
    orchestrator and the test should fail with a clear message.
    """
    for _ in range(max_iters):
        session.refresh(run)
        if run.status in ("completed", "failed", "cancelled", "rolled_back_failed"):
            return
        orch.advance(run, session)
    session.refresh(run)
    pytest.fail(
        f"Orchestrator did not reach a terminal state in {max_iters} "
        f"advance iterations; last status={run.status!r}"
    )


# ===========================================================================
# Group 1 — Happy path
# ===========================================================================


class TestHappyPath:
    """Single-op, multi-op, and conditional-skip walks all reach
    ``completed`` with consistent RunOperation rows."""

    def test_single_op_dag_runs_to_completion(
        self, engine, session, business, mock_ws, patched_registry_full
    ):
        """A 1-step DAG: dispatch + observe → terminal SUCCESS → run
        ``completed``, RunOperation row ``succeeded``."""
        patched_registry_full["generate_ecm"] = FakePrimitive(
            "generate_ecm", produces_version=True
        )

        run = _make_run(session, business)
        dag = Dag(
            intent="new-base-model",
            steps=(OperationStep(name="generate_ecm", params={}),),
        )

        orch = Orchestrator()
        orch.start(run, dag, session)
        _drive_to_terminal(orch, run, session)

        session.refresh(run)
        assert run.status == "completed"

        ops = session.exec(
            select(RunOperation).where(RunOperation.run_id == run.id)
        ).all()
        assert len(ops) == 1
        assert ops[0].operation_name == "generate_ecm"
        assert ops[0].status == "succeeded"
        assert ops[0].step_index == 0

    def test_three_op_dag_walks_in_step_index_order(
        self, engine, session, business, mock_ws, patched_registry_full
    ):
        """3-step DAG; verify step_index ordering AND that every op
        terminates with status=succeeded AND that dispatch was called
        for each in DAG order."""
        order: list[str] = []

        def _record(name: str):
            def _dispatch(ctx, ws, session):
                order.append(name)
                return OperationDispatchHandle(
                    databricks_run_id=hash(name) & 0xFFFF,
                    vibe_session_id=f"sid-{name}",
                )

            return _dispatch

        patched_registry_full["generate_ecm"] = FakePrimitive(
            "generate_ecm", on_dispatch=_record("generate_ecm")
        )
        patched_registry_full["install"] = FakePrimitive(
            "install", on_dispatch=_record("install")
        )
        patched_registry_full["shrink_to_mvm"] = FakePrimitive(
            "shrink_to_mvm", on_dispatch=_record("shrink_to_mvm")
        )

        run = _make_run(session, business)
        dag = Dag(
            intent="new-base-model",
            steps=(
                OperationStep(name="generate_ecm", params={}),
                OperationStep(name="install", params={"scope": "ecm"}),
                OperationStep(name="shrink_to_mvm", params={}),
            ),
        )

        orch = Orchestrator()
        orch.start(run, dag, session)
        _drive_to_terminal(orch, run, session)

        session.refresh(run)
        assert run.status == "completed"

        ops = session.exec(
            select(RunOperation)
            .where(RunOperation.run_id == run.id)
            .order_by(RunOperation.step_index)
        ).all()
        assert [o.operation_name for o in ops] == [
            "generate_ecm",
            "install",
            "shrink_to_mvm",
        ]
        assert all(o.status == "succeeded" for o in ops)
        # Dispatch happened in DAG order — no out-of-order parallel walk.
        assert order == ["generate_ecm", "install", "shrink_to_mvm"]

    def test_dispatch_syncs_run_vibe_session_id_bigint(
        self, engine, session, business, mock_ws, patched_registry_full
    ):
        """Phase 4.5 walkthrough bug: the dispatcher's ``vibe_session_id``
        is a fresh UUID per dispatch, but the runner only updated
        ``Run.vibe_session_id`` (the UUID column) — leaving
        ``Run.vibe_session_id_bigint`` set to whatever stale value the
        router wrote at create time.

        The progress poller queries the agent's ``_vibe_progress`` Delta
        table by bigint session_id. With the bigint stale, the poller
        looks for events under the wrong session and the UI shows zero
        progress while the agent is actually writing rows to Delta.

        This test pins the contract: after dispatch, the Run's
        ``vibe_session_id_bigint`` must equal
        ``session_id_to_bigint(handle.vibe_session_id)``.
        """
        from vibe_modeling.backend.job_launcher import (
            session_id_to_bigint,
        )

        # Use a real UUID so the bigint conversion produces a stable
        # value (the FakePrimitive default ``"session-generate_ecm"`` is
        # not a UUID).
        dispatcher_sid = "feedfeed-aaaa-bbbb-cccc-1234567890ab"

        def _dispatch(ctx, ws, session):
            return OperationDispatchHandle(
                databricks_run_id=999,
                vibe_session_id=dispatcher_sid,
            )

        patched_registry_full["generate_ecm"] = FakePrimitive(
            "generate_ecm", on_dispatch=_dispatch, produces_version=True
        )

        run = _make_run(session, business)
        # Pre-populate vibe_session_id_bigint with a different value to
        # simulate the router having stamped its own UUID's bigint
        # before the orchestrator ran.
        run.vibe_session_id_bigint = 987654321
        session.add(run)
        session.commit()

        dag = Dag(
            intent="new-base-model",
            steps=(OperationStep(name="generate_ecm", params={}),),
        )

        orch = Orchestrator()
        orch.start(run, dag, session)
        # One advance is enough to hit the dispatch path.
        orch.advance(run, session)

        session.refresh(run)
        # The runner overwrote vibe_session_id with the dispatcher's UUID
        # (existing behaviour) AND now also recomputes the bigint.
        assert run.vibe_session_id == dispatcher_sid
        expected_bigint = session_id_to_bigint(dispatcher_sid)
        assert run.vibe_session_id_bigint == expected_bigint, (
            f"Run.vibe_session_id_bigint stayed stale at "
            f"{run.vibe_session_id_bigint!r}; expected "
            f"{expected_bigint!r} (bigint of {dispatcher_sid!r})."
        )

    def test_skip_if_predicate_marks_op_skipped_without_dispatch(
        self, engine, session, business, mock_ws, patched_registry_full
    ):
        """A step with a truthy ``skip_if`` predicate must:
        - never call ``dispatch()``;
        - end up with RunOperation.status == 'skipped';
        - NOT block the DAG from advancing.
        """
        always_skip = FakePrimitive("install")
        next_op = FakePrimitive("shrink_to_mvm")
        patched_registry_full["install"] = always_skip
        patched_registry_full["shrink_to_mvm"] = next_op

        run = _make_run(session, business)
        dag = Dag(
            intent="new-base-model",
            steps=(
                # `skip_if` is a string predicate the orchestrator
                # evaluates against the run context. "true" is the
                # canonical "always skip" form per spec §3.
                OperationStep(
                    name="install",
                    params={},
                    skip_if="true",
                ),
                OperationStep(name="shrink_to_mvm", params={}),
            ),
        )

        orch = Orchestrator()
        orch.start(run, dag, session)
        _drive_to_terminal(orch, run, session)

        session.refresh(run)
        assert run.status == "completed"

        ops = session.exec(
            select(RunOperation)
            .where(RunOperation.run_id == run.id)
            .order_by(RunOperation.step_index)
        ).all()
        assert ops[0].operation_name == "install"
        assert ops[0].status == "skipped"
        assert ops[1].operation_name == "shrink_to_mvm"
        assert ops[1].status == "succeeded"
        # The skipped op never had its dispatch invoked.
        assert always_skip.dispatch_calls == []
        # The next op did dispatch (and observe).
        assert len(next_op.dispatch_calls) == 1


# ===========================================================================
# Group 2 — Mid-DAG failure → reverse rollback
# ===========================================================================


class TestMidDagFailure:
    """When an op terminates with ``succeeded=False``, the orchestrator
    rolls back prior succeeded ops in REVERSE step order. First
    rollback failure stops the chain and marks the run
    ``rolled_back_failed``."""

    def test_op2_fails_op1_rolls_back_run_marked_failed(
        self, engine, session, business, mock_ws, patched_registry_full
    ):
        """3-op DAG. Op0 succeeds, Op1 returns terminal failure.
        Expectation:
          - Op1 row -> 'failed'.
          - Op0's rollback() is called exactly once.
          - Op0 row -> 'rolled_back'.
          - Op2 NEVER dispatched.
          - Run -> 'failed' (per §6.2: rollback succeeded so it's
            'failed', not 'rolled_back_failed').
        """
        op0 = FakePrimitive("generate_ecm", produces_version=True)
        op1 = FakePrimitive(
            "install",
            on_observe=lambda h, c, w, s: _terminal_failure(
                "install", error="schema create failed"
            ),
        )
        op2 = FakePrimitive("shrink_to_mvm")
        patched_registry_full.update(
            {"generate_ecm": op0, "install": op1, "shrink_to_mvm": op2}
        )

        run = _make_run(session, business)
        dag = Dag(
            intent="new-base-model",
            steps=(
                OperationStep(name="generate_ecm", params={}),
                OperationStep(name="install", params={}),
                OperationStep(name="shrink_to_mvm", params={}),
            ),
        )

        orch = Orchestrator()
        orch.start(run, dag, session)
        _drive_to_terminal(orch, run, session)

        session.refresh(run)
        assert run.status == "failed"

        ops = session.exec(
            select(RunOperation)
            .where(RunOperation.run_id == run.id)
            .order_by(RunOperation.step_index)
        ).all()
        assert ops[0].status == "rolled_back"
        assert ops[1].status == "failed"
        # Op2 was never dispatched — its row is either pending or absent.
        # If present, it MUST NOT be 'succeeded' or 'running'.
        if len(ops) >= 3:
            assert ops[2].status in ("pending", "skipped")
        # Exactly one rollback call against op0.
        assert len(op0.rollback_calls) == 1
        # op2 never even saw a dispatch.
        assert op2.dispatch_calls == []

    def test_rollback_failure_halts_chain_and_marks_rolled_back_failed(
        self, engine, session, business, mock_ws, patched_registry_full
    ):
        """3-op DAG. Op2 fails. Op1's rollback() is fine, Op0's
        rollback() raises. Expectation:
          - Op1 row -> 'rolled_back' (its rollback succeeded).
          - Op0 row -> stays 'succeeded' — orchestrator MUST NOT touch
            it after its rollback raised, so the operator can see what
            still needs manual cleanup.
          - Run -> 'rolled_back_failed'.
          - Run.error_message mentions op0 / generate_ecm.
        """
        op0 = FakePrimitive(
            "generate_ecm",
            produces_version=True,
            on_rollback=lambda c, rb, w, s: (_ for _ in ()).throw(
                RuntimeError("delete_model_version failed: 500 internal")
            ),
        )
        op1 = FakePrimitive("install")
        op2 = FakePrimitive(
            "shrink_to_mvm",
            on_observe=lambda h, c, w, s: _terminal_failure(
                "shrink_to_mvm", error="agent timeout"
            ),
        )
        patched_registry_full.update(
            {"generate_ecm": op0, "install": op1, "shrink_to_mvm": op2}
        )

        run = _make_run(session, business)
        dag = Dag(
            intent="new-base-model",
            steps=(
                OperationStep(name="generate_ecm", params={}),
                OperationStep(name="install", params={}),
                OperationStep(name="shrink_to_mvm", params={}),
            ),
        )

        orch = Orchestrator()
        orch.start(run, dag, session)
        _drive_to_terminal(orch, run, session)

        session.refresh(run)
        assert run.status == "rolled_back_failed"
        # The error message names the failing primitive so the operator
        # can find the residual state.
        assert "generate_ecm" in run.error_message or "0" in run.error_message

        ops = session.exec(
            select(RunOperation)
            .where(RunOperation.run_id == run.id)
            .order_by(RunOperation.step_index)
        ).all()
        # Op0: rollback raised → row left 'succeeded' so the operator
        # sees there's still UC state to clean up.
        assert ops[0].status == "succeeded"
        # Op1: rolled back cleanly.
        assert ops[1].status == "rolled_back"
        # Op2: failed.
        assert ops[2].status == "failed"
        # Op0 was attempted exactly once — orchestrator did NOT retry it.
        assert len(op0.rollback_calls) == 1
        # Op1 rolled back exactly once.
        assert len(op1.rollback_calls) == 1

    def test_dispatch_time_failure_runs_no_rollback(
        self, engine, session, business, mock_ws, patched_registry_full
    ):
        """Op2 raises during dispatch (job didn't even launch — no
        databricks_run_id ever recorded). Per §6.1: no rollback runs
        because nothing happened to undo. Op1's rollback chain still
        replays prior succeeded ops, but Op2 itself has no rollback to
        do.

        Specifically: this test asserts that for an op whose dispatch
        FAILED, ``op.rollback()`` is NOT invoked — there's nothing to
        undo (no databricks_run_id, no schema, no version)."""
        op0 = FakePrimitive("generate_ecm", produces_version=True)
        op1 = FakePrimitive(
            "install",
            on_dispatch=lambda c, w, s: (_ for _ in ()).throw(
                RuntimeError("agent unconfigured — could not launch job")
            ),
        )
        patched_registry_full.update({"generate_ecm": op0, "install": op1})

        run = _make_run(session, business)
        dag = Dag(
            intent="new-base-model",
            steps=(
                OperationStep(name="generate_ecm", params={}),
                OperationStep(name="install", params={}),
            ),
        )

        orch = Orchestrator()
        orch.start(run, dag, session)
        _drive_to_terminal(orch, run, session)

        session.refresh(run)
        assert run.status == "failed"

        ops = session.exec(
            select(RunOperation)
            .where(RunOperation.run_id == run.id)
            .order_by(RunOperation.step_index)
        ).all()
        # Op0 succeeded then was rolled back.
        assert ops[0].status == "rolled_back"
        # Op1 dispatch raised → 'failed', no databricks_run_id.
        assert ops[1].status == "failed"
        assert ops[1].databricks_run_id is None
        # Critically: op1's rollback was NOT called — nothing to undo.
        assert op1.rollback_calls == []


# ===========================================================================
# Group 3 — Cancel-with-rollback
# ===========================================================================


class TestCancelWithRollback:
    """User-initiated cancel during a running DAG. Stops polling,
    cancels the live job, replays rollback in reverse."""

    def test_user_cancel_mid_flight_rolls_back_completed_ops(
        self, engine, session, business, mock_ws, patched_registry_full
    ):
        """3-op DAG. Op0 succeeds. Op1 is RUNNING (not terminal).
        User calls ``cancel_with_rollback``. Expectation:
          - ws.jobs.cancel_run called for op1's databricks_run_id.
          - op1's rollback() runs (it may have left partial state).
          - op0's rollback() runs.
          - Run -> 'cancelled'.
          - Op2 never dispatched.
        """
        op0 = FakePrimitive("generate_ecm", produces_version=True)
        # Op1 stays in 'running' forever — observe() is non-terminal.
        op1 = FakePrimitive(
            "install",
            on_observe=lambda h, c, w, s: _running("install", percent=33),
        )
        op2 = FakePrimitive("shrink_to_mvm")
        patched_registry_full.update(
            {"generate_ecm": op0, "install": op1, "shrink_to_mvm": op2}
        )

        run = _make_run(session, business)
        dag = Dag(
            intent="new-base-model",
            steps=(
                OperationStep(name="generate_ecm", params={}),
                OperationStep(name="install", params={}),
                OperationStep(name="shrink_to_mvm", params={}),
            ),
        )

        orch = Orchestrator()
        orch.start(run, dag, session)
        # Drive op0 to completion + op1 to 'running'. We can't use
        # _drive_to_terminal here because op1 never terminates — instead
        # advance once enough times that op0 is succeeded and op1 is
        # running.
        for _ in range(5):
            orch.advance(run, session)
            session.refresh(run)
            if run.status not in ("pending", "running"):
                break

        # Pre-condition: op0 succeeded, op1 running, op2 untouched.
        ops = session.exec(
            select(RunOperation)
            .where(RunOperation.run_id == run.id)
            .order_by(RunOperation.step_index)
        ).all()
        assert ops[0].status == "succeeded"
        assert ops[1].status == "running"

        # Now cancel.
        result = orch.cancel_with_rollback(run, session, mock_ws)
        # Implementations may return a dict or a small dataclass;
        # accept either as long as it indicates ok=True.
        assert (getattr(result, "ok", None) is True) or (result.get("ok") is True)

        session.refresh(run)
        assert run.status == "cancelled"

        # Databricks job cancel was attempted on op1's run id.
        mock_ws.jobs.cancel_run.assert_called()

        # op1 + op0 rolled back, in reverse order.
        assert len(op1.rollback_calls) == 1
        assert len(op0.rollback_calls) == 1
        # op2 never dispatched.
        assert op2.dispatch_calls == []

    def test_safety_gate_refuses_when_current_phase_terminated_success(
        self, engine, session, business, mock_ws, patched_registry_full
    ):
        """If the in-flight Databricks job has TERMINATED with SUCCESS
        at cancel-with-rollback time, ripping it apart would be a
        data-loss bug. Per §6.3 + the live router's behaviour: refuse,
        leave Run.status untouched, return ok=False with a reason."""
        op0 = FakePrimitive("generate_ecm", produces_version=True)
        op1 = FakePrimitive(
            "install",
            on_observe=lambda h, c, w, s: _running("install"),
        )
        op2 = FakePrimitive("shrink_to_mvm")
        patched_registry_full.update(
            {"generate_ecm": op0, "install": op1, "shrink_to_mvm": op2}
        )

        # Configure the WS mock so jobs.get_run reports
        # TERMINATED/SUCCESS — the safety gate condition.
        state = MagicMock()
        state.life_cycle_state = MagicMock()
        state.life_cycle_state.value = "TERMINATED"
        state.result_state = MagicMock()
        state.result_state.value = "SUCCESS"
        job_run = MagicMock()
        job_run.state = state
        mock_ws.jobs.get_run.return_value = job_run

        run = _make_run(session, business)
        dag = Dag(
            intent="new-base-model",
            steps=(
                OperationStep(name="generate_ecm", params={}),
                OperationStep(name="install", params={}),
                OperationStep(name="shrink_to_mvm", params={}),
            ),
        )

        orch = Orchestrator()
        orch.start(run, dag, session)
        for _ in range(5):
            orch.advance(run, session)
            session.refresh(run)
            if run.status not in ("pending", "running"):
                break

        prior_status = run.status

        result = orch.cancel_with_rollback(run, session, mock_ws)
        assert result.ok is False
        assert result.refusal_reason == CANCEL_REFUSED_PHASE_SUCCEEDED
        assert "finished successfully" in result.op_failures[0]["error"]

        session.refresh(run)
        # Run is untouched — same status as before the cancel call.
        assert run.status == prior_status
        # No rollback ops applied.
        assert op0.rollback_calls == []
        assert op1.rollback_calls == []

    def test_idempotent_cancel_on_already_cancelled_run_is_noop(
        self, engine, session, business, mock_ws, patched_registry_full
    ):
        """Re-calling cancel_with_rollback on a Run already in
        ``cancelled`` state must be a no-op: ok=True, no rollback ops
        invoked, no jobs.cancel_run call."""
        op0 = FakePrimitive("generate_ecm")
        patched_registry_full["generate_ecm"] = op0

        run = _make_run(session, business)
        # Manually flip the run to cancelled — simulating a prior cancel.
        run.status = "cancelled"
        session.add(run)
        session.commit()
        session.refresh(run)

        # Reset the cancel mock so the assertion below is unambiguous.
        mock_ws.jobs.cancel_run.reset_mock()

        orch = Orchestrator()
        result = orch.cancel_with_rollback(run, session, mock_ws)
        ok = getattr(result, "ok", result.get("ok") if hasattr(result, "get") else None)
        assert ok is True

        session.refresh(run)
        assert run.status == "cancelled"
        # No primitive rollback was applied.
        assert op0.rollback_calls == []
        # The orchestrator did not call jobs.cancel_run again.
        mock_ws.jobs.cancel_run.assert_not_called()

    def test_cancel_during_rollback_does_not_corrupt_state(
        self, engine, session, business, mock_ws, patched_registry_full
    ):
        """Edge case: a second cancel arrives while the first cancel is
        mid-rollback. The orchestrator MUST handle it cleanly:
          - Once the run reaches 'cancelled' OR 'rolled_back_failed',
            re-calling cancel returns ok=True and is a no-op.
          - No additional rollback() invocations on already-rolled-back ops.
        """
        op0 = FakePrimitive("generate_ecm", produces_version=True)
        op1 = FakePrimitive(
            "install",
            on_observe=lambda h, c, w, s: _running("install"),
        )
        patched_registry_full.update({"generate_ecm": op0, "install": op1})

        run = _make_run(session, business)
        dag = Dag(
            intent="new-base-model",
            steps=(
                OperationStep(name="generate_ecm", params={}),
                OperationStep(name="install", params={}),
            ),
        )

        orch = Orchestrator()
        orch.start(run, dag, session)
        for _ in range(5):
            orch.advance(run, session)
            session.refresh(run)
            if run.status not in ("pending", "running"):
                break

        # First cancel — completes normally.
        first = orch.cancel_with_rollback(run, session, mock_ws)
        first_ok = getattr(
            first, "ok", first.get("ok") if hasattr(first, "get") else None
        )
        assert first_ok is True

        op0_rollback_count_after_first = len(op0.rollback_calls)
        op1_rollback_count_after_first = len(op1.rollback_calls)

        # Second cancel — must not re-roll-back.
        second = orch.cancel_with_rollback(run, session, mock_ws)
        second_ok = getattr(
            second, "ok", second.get("ok") if hasattr(second, "get") else None
        )
        assert second_ok is True
        # No additional rollback calls.
        assert len(op0.rollback_calls) == op0_rollback_count_after_first
        assert len(op1.rollback_calls) == op1_rollback_count_after_first


# ===========================================================================
# Group 4 — Resume entry points
# ===========================================================================


class TestResume:
    """Three resume scenarios per §6.4: app-restart, admin retry, and
    crash mid-rollback recovery."""

    def test_app_restart_reattaches_via_persisted_handle(
        self, engine, session, business, mock_ws, patched_registry_full
    ):
        """App was killed mid-run while op0 was running. On startup the
        lifespan scan finds the run with status='running' and calls
        ``Orchestrator.resume(run, session, ws)``. The orchestrator
        MUST:
          - NOT call dispatch() again (handle is already persisted).
          - Call observe() with the persisted handle.
          - Advance when observe() reports terminal SUCCESS.
        """
        observed_handles: list[OperationDispatchHandle] = []

        def _observe(handle, ctx, ws, sess):
            observed_handles.append(handle)
            return _terminal_success("generate_ecm")

        op0 = FakePrimitive(
            "generate_ecm",
            produces_version=True,
            on_observe=_observe,
        )
        patched_registry_full["generate_ecm"] = op0

        # Build the world AS IF the app had crashed: a Run row in
        # 'running' state with one RunOperation row already 'running'
        # and a databricks_run_id pre-persisted.
        run = _make_run(session, business, status="running")
        run.databricks_run_id = 99999
        session.add(run)
        op_row = RunOperation(
            run_id=run.id,
            step_index=0,
            operation_name="generate_ecm",
            params_json="{}",
            status="running",
            databricks_run_id=99999,
            vibe_session_id="persisted-sid",
            started_at=datetime.now(timezone.utc),
        )
        session.add(op_row)
        session.commit()
        session.refresh(run)

        orch = Orchestrator()
        orch.resume(run, session, mock_ws)
        _drive_to_terminal(orch, run, session)

        # dispatch was NOT re-called — only observe.
        assert op0.dispatch_calls == []
        assert len(observed_handles) >= 1
        # The handle came from the persisted RunOperation row.
        assert observed_handles[0].databricks_run_id == 99999
        assert observed_handles[0].vibe_session_id == "persisted-sid"

        session.refresh(run)
        assert run.status == "completed"

    def test_admin_resume_on_failed_run_re_dispatches_failed_op(
        self, engine, session, business, mock_ws, patched_registry_full
    ):
        """Run.status='failed' with an idempotent op that previously
        failed. Operator hits resume; the orchestrator either retries
        or resets the row to pending and re-dispatches. We assert the
        RUN reaches a terminal state again (not stuck) — the exact
        retry-vs-reset path is implementation choice per §6.4."""

        # Counter so the second observe() returns success this time.
        call_count = {"n": 0}

        def _observe_first_fail_then_succeed(handle, ctx, ws, sess):
            call_count["n"] += 1
            if call_count["n"] == 1:
                return _terminal_failure("generate_ecm", error="transient blip")
            return _terminal_success("generate_ecm")

        op0 = FakePrimitive(
            "generate_ecm",
            produces_version=True,
            is_idempotent=True,
            on_observe=_observe_first_fail_then_succeed,
        )
        patched_registry_full["generate_ecm"] = op0

        run = _make_run(session, business)
        dag = Dag(
            intent="new-base-model",
            steps=(OperationStep(name="generate_ecm", params={}),),
        )

        orch = Orchestrator()
        orch.start(run, dag, session)
        _drive_to_terminal(orch, run, session)

        session.refresh(run)
        assert run.status == "failed"

        # Now the operator triggers resume.
        orch.resume(run, session, mock_ws)
        _drive_to_terminal(orch, run, session)

        session.refresh(run)
        assert run.status == "completed"
        op0_row = session.exec(
            select(RunOperation).where(RunOperation.run_id == run.id)
        ).first()
        assert op0_row.status == "succeeded"

    def test_admin_resume_after_failed_op_clears_dbx_run_id_to_avoid_rollback(
        self, engine, session, business, mock_ws, patched_registry_full
    ):
        """REGRESSION (2026-04-27 incident): admin clicks resume on a
        failed run. The failed op's recorded ``databricks_run_id``
        points at a terminal-FAILED job. If resume sets the op back
        to ``running`` while keeping the stale handle, the next
        ``observe()`` re-discovers that failure and the orchestrator
        fires the rollback chain — which deletes the upstream succeeded
        op's ModelVersion (FK violation against ``runs.version_id``).

        The fix: resume MUST clear the failed op's ``databricks_run_id``
        and reset to ``pending`` so the advance loop dispatches a fresh
        job. This test seeds the post-failure DB state directly (matches
        the production case where op0 is ``succeeded`` and op1 is
        ``failed`` with a stale dbx handle) and checks that resume
        scrubs the handle and re-dispatches.
        """
        from vibe_modeling.backend.db_models import ModelVersion

        # Seed: run failed, op0 succeeded with output_version_id, op1
        # failed with a stale dbx_run_id pointing at a terminal job.
        run = _make_run(session, business)
        run.status = "failed"
        run.error_message = "Phase 2 failed"
        session.add(run)
        session.commit()

        mv = ModelVersion(
            business_id=business,
            version=1,
            scope="ecm",
            status="completed",
        )
        session.add(mv)
        session.commit()
        session.refresh(mv)
        op0_version_id = mv.id

        op0 = RunOperation(
            run_id=run.id,
            step_index=0,
            operation_name="generate_ecm",
            params_json="{}",
            status="succeeded",
            output_version_id=op0_version_id,
            databricks_run_id=111,
            vibe_session_id="sid-op0",
        )
        op1 = RunOperation(
            run_id=run.id,
            step_index=1,
            operation_name="shrink_to_mvm",
            params_json="{}",
            status="failed",
            databricks_run_id=999,
            vibe_session_id="sid-op1-stale",
            error_message="Workload failed",
        )
        session.add(op0)
        session.add(op1)
        session.commit()

        # Track dispatch calls so we can prove op1 was re-dispatched
        # fresh (not re-attached via observe).
        dispatch_calls = {"op0": 0, "op1": 0}

        def _make_dispatch(name):
            def _d(ctx, ws, sess):
                dispatch_calls[name] += 1
                return OperationDispatchHandle(
                    databricks_run_id=12345,
                    vibe_session_id=f"fresh-sid-{name}",
                )
            return _d

        patched_registry_full["generate_ecm"] = FakePrimitive(
            "generate_ecm",
            produces_version=True,
            on_dispatch=_make_dispatch("op0"),
        )
        patched_registry_full["shrink_to_mvm"] = FakePrimitive(
            "shrink_to_mvm",
            produces_version=True,
            is_idempotent=True,
            on_dispatch=_make_dispatch("op1"),
        )

        # Trigger admin resume.
        orch = Orchestrator()
        orch.resume(run, session, mock_ws)

        # Critical invariants (asserted before driving to terminal so
        # they isolate the resume() bookkeeping from later
        # advance/observe behaviour):
        session.refresh(op0)
        session.refresh(op1)
        assert op0.status == "succeeded", "op0 must remain succeeded"
        assert op0.output_version_id == op0_version_id, (
            "op0's output ModelVersion id must be preserved"
        )
        assert op0.databricks_run_id == 111, "op0's dbx_run_id must be untouched"
        # resume() ends with advance(), which sees the now-pending op1
        # and dispatches it fresh — so by the time we check, op1 is
        # 'running' with a NEW dbx_run_id (not the stale 999).
        assert op1.status == "running", "op1 must be re-dispatched, ending up running"
        assert op1.databricks_run_id != 999, (
            "op1's stale dbx_run_id (999) must NOT be reused — resume "
            "must clear it so a fresh dispatch records a new id"
        )
        assert op1.databricks_run_id is not None, (
            "op1 must have a NEW dbx_run_id after fresh dispatch"
        )
        assert op1.error_message == "", "op1's error must be cleared"

        # ModelVersion must still exist — no rollback fired.
        mv_after = session.get(ModelVersion, op0_version_id)
        assert mv_after is not None, (
            "op0's ModelVersion must NOT have been deleted by resume"
        )

        # Drive to completion to confirm op1 dispatches fresh.
        _drive_to_terminal(orch, run, session)
        session.refresh(run)
        assert run.status == "completed"
        assert dispatch_calls["op0"] == 0, "op0 must NOT be re-dispatched"
        assert dispatch_calls["op1"] == 1, "op1 must be dispatched fresh"

    def test_resume_from_rolled_back_failed_continues_chain(
        self, engine, session, business, mock_ws, patched_registry_full
    ):
        """A run is in 'rolled_back_failed' because mid-rollback a
        primitive raised. The operator manually triggers resume after
        cleaning up the residual state outside the app. The
        orchestrator MUST continue the rollback chain from the
        next-newer succeeded op (per §6.4 row 3) — not start over."""

        # 4-op DAG context:
        # op0 succeeded, op1 succeeded, op2 succeeded, op3 failed.
        # Initial rollback: op2 OK, op1 RAISED → run ends
        # 'rolled_back_failed'. On resume: op0's rollback should fire.

        # We seed the DB by hand to model the post-failed-rollback state.
        run = _make_run(session, business)
        run.status = "rolled_back_failed"
        run.error_message = "Rollback of step_index=1 (install) failed"
        session.add(run)
        session.commit()

        for i, (name, status) in enumerate(
            [
                ("generate_ecm", "succeeded"),
                ("install", "succeeded"),  # this one's rollback raised
                ("install", "rolled_back"),
                ("shrink_to_mvm", "failed"),
            ]
        ):
            session.add(
                RunOperation(
                    run_id=run.id,
                    step_index=i,
                    operation_name=name,
                    params_json="{}",
                    status=status,
                    rollback_state_json='{"primitive": "%s"}' % name,
                )
            )
        session.commit()

        op0 = FakePrimitive("generate_ecm", produces_version=True)
        op1 = FakePrimitive("install")
        op_shrink = FakePrimitive("shrink_to_mvm")
        patched_registry_full.update(
            {
                "generate_ecm": op0,
                "install": op1,
                "shrink_to_mvm": op_shrink,
            }
        )

        orch = Orchestrator()
        orch.resume(run, session, mock_ws)

        # Whatever the orchestrator does, the only NEW rollback that's
        # legitimate from this state is op0's (the next-newer succeeded
        # op below the one that previously raised). It is NOT
        # legitimate to call any primitive's dispatch() during a
        # rollback-resume.
        assert op0.dispatch_calls == []
        assert op1.dispatch_calls == []
        assert op_shrink.dispatch_calls == []
        # op0 is the only op that should be rolled back now.
        assert len(op0.rollback_calls) == 1


    def test_observe_handle_carries_dispatch_extras_from_rollback_state_json(
        self, engine, session, business, mock_ws, patched_registry_full
    ):
        """REGRESSION: ``advance()`` rebuilds the dispatch handle for an
        already-running op when calling ``observe()``. Previously the
        handle was constructed with ``extra={}`` — discarding the
        deployment_catalog / business_name / parent_version_int that
        ``vibe_iterate.dispatch()`` had persisted on
        ``RunOperation.rollback_state_json``. Net effect: the next
        ``observe()`` saw an empty ``handle.extra``, ``_fetch_model_json``
        couldn't construct a Volume path, and the run failed with
        "Path is missing a volume name".

        Captured from the 2026-04-27 vibe-iterate run
        (9b8c81c7-b623-4651-a57e-0d0c83e6f7a9).
        """
        captured_extras: list[dict] = []

        def _capture_observe(handle, ctx, ws, sess):
            captured_extras.append(dict(handle.extra or {}))
            return _terminal_success("vibe_iterate")

        op = FakePrimitive(
            "vibe_iterate",
            produces_version=True,
            on_observe=_capture_observe,
        )
        patched_registry_full["vibe_iterate"] = op

        # Seed: run has been dispatched and is observable. Persisted
        # rollback_state_json carries the dispatch-time extras.
        run = _make_run(session, business)
        run.status = "running"
        session.add(run)
        session.commit()

        persisted_extras = {
            "session_id_bigint": 12345,
            "deployment_catalog": "vibe_modeling_test",
            "business_name": "phase_4_validation_run",
            "parent_version_int": 1,
        }
        op_row = RunOperation(
            run_id=run.id,
            step_index=0,
            operation_name="vibe_iterate",
            params_json="{}",
            status="running",
            databricks_run_id=999999,
            vibe_session_id="sid-vibe",
            rollback_state_json=json.dumps(persisted_extras),
        )
        session.add(op_row)
        session.commit()

        orch = Orchestrator()
        _drive_to_terminal(orch, run, session)

        assert len(captured_extras) >= 1, "observe was never called"
        seen = captured_extras[0]
        for k, v in persisted_extras.items():
            assert seen.get(k) == v, (
                f"observe-time handle.extra[{k}] = {seen.get(k)!r}, "
                f"expected {v!r} from rollback_state_json"
            )


# ===========================================================================
# Group 5 — Idempotency
# ===========================================================================


class TestIdempotency:
    """The orchestrator's writes are idempotent against re-call —
    important because the asyncio loop may re-enter advance() across
    the same op multiple times."""

    def test_advance_with_persisted_databricks_run_id_does_not_relaunch(
        self, engine, session, business, mock_ws, patched_registry_full
    ):
        """The op already has a databricks_run_id on its RunOperation
        row. orch.advance() MUST observe via the persisted handle,
        never re-dispatch."""

        observed_calls = {"n": 0}

        def _observe(handle, ctx, ws, sess):
            observed_calls["n"] += 1
            return _terminal_success("generate_ecm")

        op0 = FakePrimitive(
            "generate_ecm",
            produces_version=True,
            on_observe=_observe,
        )
        patched_registry_full["generate_ecm"] = op0

        # Pre-populate state as if start() had already dispatched op0.
        run = _make_run(session, business, status="running")
        op_row = RunOperation(
            run_id=run.id,
            step_index=0,
            operation_name="generate_ecm",
            params_json="{}",
            status="running",
            databricks_run_id=12345,
            vibe_session_id="persisted",
            started_at=datetime.now(timezone.utc),
        )
        session.add(op_row)
        session.commit()
        session.refresh(run)

        orch = Orchestrator()
        # Advance — no new dispatch should happen.
        orch.advance(run, session)
        _drive_to_terminal(orch, run, session)

        assert op0.dispatch_calls == [], (
            "Orchestrator re-dispatched an op that already had a "
            "persisted databricks_run_id — would launch duplicate jobs."
        )
        assert observed_calls["n"] >= 1

    def test_dispatch_pending_with_prebaked_run_id_skips_dispatch_moves_to_running(
        self, engine, session, business, mock_ws, patched_registry_full
    ):
        """Crash-recovery guard at _runner.py:671-677: a RunOperation row
        with status='pending' but a pre-set databricks_run_id (process
        crashed between op.dispatch() returning and the status commit)
        MUST NOT be re-dispatched. orch.advance() must flip the row to
        'running' and leave dispatch untouched."""
        observed_calls = {"n": 0}

        def _observe(handle, ctx, ws, sess):
            observed_calls["n"] += 1
            return _terminal_success("generate_ecm")

        op0 = FakePrimitive(
            "generate_ecm",
            produces_version=True,
            on_observe=_observe,
        )
        patched_registry_full["generate_ecm"] = op0

        run = _make_run(session, business, status="pending")
        op_row = RunOperation(
            run_id=run.id,
            step_index=0,
            operation_name="generate_ecm",
            params_json="{}",
            status="pending",
            databricks_run_id=12345,
        )
        session.add(op_row)
        session.commit()
        session.refresh(run)

        orch = Orchestrator()
        orch.advance(run, session)

        assert op0.dispatch_calls == [], (
            "_dispatch_pending must skip re-dispatch when databricks_run_id "
            "is already set — only the orchestrator crash-recovery guard "
            "at _runner.py:671-677 stands between pending+run_id and a "
            "duplicate job launch."
        )
        session.refresh(op_row)
        assert op_row.status == "running", (
            "crash-recovery guard must flip the row to 'running' so the "
            "next advance tick calls _advance_running, not _dispatch_pending."
        )

    def test_re_calling_start_does_not_duplicate_run_operation_rows(
        self, engine, session, business, mock_ws, patched_registry_full
    ):
        """orch.start() with existing RunOperation rows must be
        idempotent — no UNIQUE constraint violation, no duplicate rows.
        It re-dispatches the first 'pending' op in the existing list.

        This is the recovery path used when the API call to start a run
        wins, but the in-process orchestrator hand-off is missed (e.g.
        a worker crash between insert+dispatch)."""
        op0 = FakePrimitive("generate_ecm", produces_version=True)
        patched_registry_full["generate_ecm"] = op0

        run = _make_run(session, business)
        dag = Dag(
            intent="new-base-model",
            steps=(OperationStep(name="generate_ecm", params={}),),
        )

        orch = Orchestrator()
        orch.start(run, dag, session)
        # Second call — must NOT raise UNIQUE constraint, must NOT
        # create duplicate rows.
        orch.start(run, dag, session)

        ops = session.exec(
            select(RunOperation).where(RunOperation.run_id == run.id)
        ).all()
        assert len(ops) == 1, (
            f"Re-calling start() created duplicate RunOperation rows: "
            f"got {len(ops)} for a 1-step DAG."
        )

        _drive_to_terminal(orch, run, session)
        session.refresh(run)
        assert run.status == "completed"


# ===========================================================================
# Group 6 — Pipeline walks (One Catalog 2-op + multi-catalog 4-op)
# ===========================================================================


class TestPipelineWalks:
    """End-to-end walks for the two real intents the orchestrator
    replaces in ``_advance_unified_pipeline``."""

    def test_one_catalog_two_op_walk_completes(
        self, engine, session, business, mock_ws, patched_registry_full
    ):
        """One Catalog (#121): 2-op DAG generate_ecm → shrink_to_mvm.
        Both produce versions. Run completes."""
        ecm_version_id = "ver-ecm-1"
        mvm_version_id = "ver-mvm-1"

        op_ecm = FakePrimitive(
            "generate_ecm",
            produces_version=True,
            on_observe=lambda h, c, w, s: _terminal_success(
                "generate_ecm", output_version_id=ecm_version_id
            ),
        )
        op_shrink = FakePrimitive(
            "shrink_to_mvm",
            produces_version=True,
            on_observe=lambda h, c, w, s: _terminal_success(
                "shrink_to_mvm", output_version_id=mvm_version_id
            ),
        )
        patched_registry_full.update(
            {"generate_ecm": op_ecm, "shrink_to_mvm": op_shrink}
        )

        run = _make_run(session, business)
        dag = Dag(
            intent="new-base-model",
            steps=(
                OperationStep(name="generate_ecm", params={}),
                OperationStep(
                    name="shrink_to_mvm",
                    params={},
                    needs_version_from="generate_ecm",
                ),
            ),
        )

        orch = Orchestrator()
        orch.start(run, dag, session)
        _drive_to_terminal(orch, run, session)

        session.refresh(run)
        assert run.status == "completed"
        ops = session.exec(
            select(RunOperation)
            .where(RunOperation.run_id == run.id)
            .order_by(RunOperation.step_index)
        ).all()
        assert [o.operation_name for o in ops] == ["generate_ecm", "shrink_to_mvm"]
        assert all(o.status == "succeeded" for o in ops)
        # Output versions are persisted onto the rows.
        assert ops[0].output_version_id == ecm_version_id
        assert ops[1].output_version_id == mvm_version_id

    def test_multi_catalog_four_op_walk_completes(
        self, engine, session, business, mock_ws, patched_registry_full
    ):
        """Catalog-per-Division / per-Domain: 4-op DAG
        generate_ecm → install(ecm) → shrink_to_mvm → install(mvm).
        Asserts dispatch called for each in DAG order, all succeeded."""
        order: list[str] = []

        def _record(name: str):
            def _dispatch(ctx, ws, session):
                # Build a unique handle per dispatch so we can sanity-
                # check the persisted handle is the one returned for
                # this step.
                order.append(name)
                return OperationDispatchHandle(
                    databricks_run_id=hash((name, len(order))) & 0xFFFF,
                    vibe_session_id=f"sid-{name}-{len(order)}",
                )

            return _dispatch

        op_ecm = FakePrimitive(
            "generate_ecm",
            produces_version=True,
            on_dispatch=_record("generate_ecm"),
        )
        op_install = FakePrimitive(
            "install",
            on_dispatch=_record("install"),
        )
        op_shrink = FakePrimitive(
            "shrink_to_mvm",
            produces_version=True,
            on_dispatch=_record("shrink_to_mvm"),
        )
        patched_registry_full.update(
            {
                "generate_ecm": op_ecm,
                "install": op_install,
                "shrink_to_mvm": op_shrink,
            }
        )

        run = _make_run(session, business)
        # Real 4-op multi-catalog DAG. Two `install` steps with
        # disambiguating params per scope; the orchestrator looks up
        # both via `services.operations.get('install')` and dispatches
        # each as a fresh RunOperation row.
        dag = Dag(
            intent="new-base-model",
            steps=(
                OperationStep(name="generate_ecm", params={}),
                OperationStep(
                    name="install",
                    params={"scope": "ecm"},
                    needs_version_from="generate_ecm",
                ),
                OperationStep(
                    name="shrink_to_mvm",
                    params={},
                    needs_version_from="generate_ecm",
                ),
                OperationStep(
                    name="install",
                    params={"scope": "mvm"},
                    needs_version_from="shrink_to_mvm",
                ),
            ),
        )

        orch = Orchestrator()
        orch.start(run, dag, session)
        _drive_to_terminal(orch, run, session)

        session.refresh(run)
        assert run.status == "completed"
        # Walked all 4 steps, in DAG order.
        assert order == [
            "generate_ecm",
            "install",
            "shrink_to_mvm",
            "install",
        ]

        ops = session.exec(
            select(RunOperation)
            .where(RunOperation.run_id == run.id)
            .order_by(RunOperation.step_index)
        ).all()
        assert len(ops) == 4
        assert [o.operation_name for o in ops] == [
            "generate_ecm",
            "install",
            "shrink_to_mvm",
            "install",
        ]
        assert all(o.status == "succeeded" for o in ops)


# ===========================================================================
# Group 7 — Tail of edge cases worth nailing down
# ===========================================================================


class TestEdgeCases:
    """Catch-all: zero-step DAG, observe-before-dispatch, polling
    multiple ticks against a long-running op."""

    def test_zero_step_dag_completes_immediately(
        self, engine, session, business, mock_ws, patched_registry_full
    ):
        """An empty DAG is degenerate but legal — the orchestrator
        should mark the run completed without any RunOperation rows.
        (Validators reject zero-step DAGs at create time, but the
        orchestrator MUST be defensive: no IndexError on an empty
        steps tuple.)"""
        run = _make_run(session, business)
        dag = Dag(intent="new-base-model", steps=())

        orch = Orchestrator()
        orch.start(run, dag, session)
        _drive_to_terminal(orch, run, session, max_iters=5)

        session.refresh(run)
        assert run.status == "completed"
        ops = session.exec(
            select(RunOperation).where(RunOperation.run_id == run.id)
        ).all()
        assert ops == []

    def test_observe_returns_running_then_terminal_advances_only_after_terminal(
        self, engine, session, business, mock_ws, patched_registry_full
    ):
        """observe() returns 'running' on tick 1+2, terminal SUCCESS
        on tick 3. The orchestrator must not advance the run or
        dispatch op[1] until observe() reports terminal."""
        ticks = {"n": 0}

        def _observe(handle, ctx, ws, sess):
            ticks["n"] += 1
            if ticks["n"] < 3:
                return _running("generate_ecm", percent=ticks["n"] * 25)
            return _terminal_success("generate_ecm")

        op0 = FakePrimitive(
            "generate_ecm", produces_version=True, on_observe=_observe
        )
        op1 = FakePrimitive("install")
        patched_registry_full.update({"generate_ecm": op0, "install": op1})

        run = _make_run(session, business)
        dag = Dag(
            intent="new-base-model",
            steps=(
                OperationStep(name="generate_ecm", params={}),
                OperationStep(name="install", params={}),
            ),
        )

        orch = Orchestrator()
        orch.start(run, dag, session)

        # First two advance() ticks — observe says 'running'. op1 must
        # NOT have dispatched yet.
        orch.advance(run, session)
        orch.advance(run, session)
        assert op1.dispatch_calls == [], (
            "Orchestrator advanced to op1 before op0 reported terminal."
        )
        ops = session.exec(
            select(RunOperation)
            .where(RunOperation.run_id == run.id)
            .order_by(RunOperation.step_index)
        ).all()
        assert ops[0].status == "running"

        # Third+ ticks — observe terminal SUCCESS, op1 dispatches.
        _drive_to_terminal(orch, run, session)
        session.refresh(run)
        assert run.status == "completed"
        assert len(op1.dispatch_calls) == 1

    def test_unknown_operation_name_in_dag_is_dispatch_time_failure(
        self, engine, session, business, mock_ws, patched_registry_full
    ):
        """A DAG referencing an operation name that's not in the
        registry MUST surface as a clean dispatch-time failure on that
        op (not a process crash). The validator catches this at create
        time, but defence in depth: the orchestrator should mark the
        op failed and the run failed.

        We populate the fake registry with ONLY op0; op1 is referenced
        in the DAG but absent from the registry."""
        op0 = FakePrimitive("generate_ecm", produces_version=True)
        patched_registry_full["generate_ecm"] = op0
        # NB: 'install' deliberately NOT in patched_registry_full.

        run = _make_run(session, business)
        dag = Dag(
            intent="new-base-model",
            steps=(
                OperationStep(name="generate_ecm", params={}),
                OperationStep(name="install", params={}),
            ),
        )

        orch = Orchestrator()
        orch.start(run, dag, session)
        _drive_to_terminal(orch, run, session)

        session.refresh(run)
        assert run.status == "failed"
        ops = session.exec(
            select(RunOperation)
            .where(RunOperation.run_id == run.id)
            .order_by(RunOperation.step_index)
        ).all()
        # op0 was rolled back when op1 (unknown) failed at dispatch.
        assert ops[0].status == "rolled_back"
        assert ops[1].status == "failed"

    def test_failed_op_with_no_databricks_run_id_skips_rollback_for_self(
        self, engine, session, business, mock_ws, patched_registry_full
    ):
        """Per the per-primitive failure mode table (§10), if a job
        never launched (databricks_run_id is None on the failed op),
        there's nothing for that op's rollback to do — so the
        orchestrator MUST NOT call rollback() on it.

        (Prior succeeded ops still get rolled back as usual.)"""
        op0 = FakePrimitive("generate_ecm", produces_version=True)
        # op1 fails at dispatch — no databricks_run_id ever set.
        op1 = FakePrimitive(
            "install",
            on_dispatch=lambda c, w, s: (_ for _ in ()).throw(
                RuntimeError("could not launch")
            ),
        )
        patched_registry_full.update({"generate_ecm": op0, "install": op1})

        run = _make_run(session, business)
        dag = Dag(
            intent="new-base-model",
            steps=(
                OperationStep(name="generate_ecm", params={}),
                OperationStep(name="install", params={}),
            ),
        )

        orch = Orchestrator()
        orch.start(run, dag, session)
        _drive_to_terminal(orch, run, session)

        session.refresh(run)
        assert run.status == "failed"
        # op1 was failed but its rollback was NOT called (nothing to undo).
        assert op1.rollback_calls == []
        # op0's rollback was called once.
        assert len(op0.rollback_calls) == 1

    def test_rollback_replays_in_strict_reverse_step_index_order(
        self, engine, session, business, mock_ws, patched_registry_full
    ):
        """4-op DAG. op[3] fails. Verify op[2], op[1], op[0] roll back
        IN THAT ORDER (newest-first) — not in any other order."""
        rollback_order: list[str] = []

        def _record_rollback(name: str):
            def _rb(ctx, rb_state, ws, sess):
                rollback_order.append(name)

            return _rb

        op0 = FakePrimitive(
            "generate_ecm",
            produces_version=True,
            on_rollback=_record_rollback("generate_ecm"),
        )
        op1 = FakePrimitive("install", on_rollback=_record_rollback("install_ecm"))
        op2 = FakePrimitive(
            "shrink_to_mvm",
            produces_version=True,
            on_rollback=_record_rollback("shrink_to_mvm"),
        )
        op3 = FakePrimitive(
            "install",
            on_observe=lambda h, c, w, s: _terminal_failure(
                "install_mvm", error="schema collision"
            ),
        )
        # Two 'install' rows in the DAG share the registry name. We
        # mutate per-position behaviour by attaching different
        # on_rollback closures via a stateful counter on a single
        # registered FakePrimitive.
        installs_seen = {"n": 0}

        def _install_dispatch(ctx, ws, sess):
            installs_seen["n"] += 1
            return OperationDispatchHandle(
                databricks_run_id=200 + installs_seen["n"],
                vibe_session_id=f"install-{installs_seen['n']}",
            )

        # First install observes success, second observes failure.
        def _install_observe(handle, ctx, ws, sess):
            if handle.databricks_run_id == 201:
                return _terminal_success("install_ecm")
            return _terminal_failure("install_mvm", error="schema collision")

        # Single FakePrimitive shared by both 'install' rows.
        op_install = FakePrimitive(
            "install",
            on_dispatch=_install_dispatch,
            on_observe=_install_observe,
            on_rollback=_record_rollback("install"),  # records on every rollback
        )
        patched_registry_full.update(
            {
                "generate_ecm": op0,
                "install": op_install,
                "shrink_to_mvm": op2,
            }
        )

        run = _make_run(session, business)
        dag = Dag(
            intent="new-base-model",
            steps=(
                OperationStep(name="generate_ecm", params={}),
                OperationStep(
                    name="install",
                    params={"scope": "ecm"},
                    needs_version_from="generate_ecm",
                ),
                OperationStep(
                    name="shrink_to_mvm",
                    params={},
                    needs_version_from="generate_ecm",
                ),
                OperationStep(
                    name="install",
                    params={"scope": "mvm"},
                    needs_version_from="shrink_to_mvm",
                ),
            ),
        )

        orch = Orchestrator()
        orch.start(run, dag, session)
        _drive_to_terminal(orch, run, session)

        session.refresh(run)
        assert run.status == "failed"

        # The second 'install' (mvm) failed; rollback chain is over
        # step indexes 2 (shrink), 1 (install ecm), 0 (generate_ecm).
        # The exact label string depends on which closure recorded —
        # we registered _record_rollback("install") on op_install,
        # so both installs record as 'install'. The crucial check is
        # the ORDER: shrink first (step_index=2), then install (step
        # index=1), then generate_ecm (step_index=0).
        assert rollback_order == [
            "shrink_to_mvm",
            "install",
            "generate_ecm",
        ], (
            f"Rollback order was {rollback_order!r}; "
            "expected strict reverse step_index order."
        )


# ===========================================================================
# Group N — dispatch-time extras must round-trip through the DB
# ===========================================================================


class TestDispatchExtrasRoundTrip:
    """Locks the live-walkthrough gap behind ``deployment_status`` stamping
    correctly but ``uc_catalog`` staying "" on real installs (TerraNova ECM
    install, run 771d6b7d).

    The prior regression test for this
    (``test_primitives_install.py::TestInstallDeploymentWriteback``) called
    ``install_op.observe()`` directly with a hand-built
    ``OperationDispatchHandle(extra={"deployment_catalog": "test_cat"})``.
    That passes even with the bug present, because it never goes through
    the ORCHESTRATOR's real observe path: ``_advance_running`` rebuilds
    the handle from ``RunOperation.rollback_state_json`` on every poll
    tick (a later process tick than ``dispatch()``, per
    ``docs/orchestrator-design.md`` §4), not from the in-memory handle
    ``dispatch()`` returned. ``_dispatch_pending`` used to persist
    ``databricks_run_id`` / ``vibe_session_id`` / ``parent_version_id``
    onto the row but never wrote ``handle.extra`` anywhere — the column
    stayed ``"{}"`` until a TERMINAL observation overwrote it with
    ``result.rollback_state`` (too late: by then ``observe()`` had
    already run once with empty extras). This test drives the REAL
    ``Install`` primitive through ``Orchestrator.start`` + repeated
    ``Orchestrator.advance`` calls — the actual re-entrant path — so it
    fails on the bug and passes once ``dispatch()``'s extras are
    persisted immediately.
    """

    def test_install_stamps_uc_catalog_across_separate_poll_ticks(
        self, engine, session, business, mock_ws, patched_registry_full
    ):
        from vibe_modeling.backend.services.operations.install import Install

        patched_registry_full["install"] = Install()

        # Agent job configured — Install.dispatch() needs a job_id.
        cfg = AgentConfig(job_id=999, job_name="dbx_vibe_modelling")
        session.add(cfg)

        mv = ModelVersion(
            business_id=business,
            version=1,
            scope="ecm",
            status="completed",
            deployment_status="draft",
            uc_catalog="",
        )
        session.add(mv)
        session.commit()
        session.refresh(mv)

        # ws.jobs.run_now → databricks_run_id 555.
        mock_run = MagicMock()
        mock_run.run_id = 555
        mock_run.response = MagicMock()
        mock_run.response.run_id = 555
        mock_ws.jobs.run_now.return_value = mock_run
        from ._lifecycle_fixtures import agent_exits_ok, model_json_readable

        agent_exits_ok(mock_ws)
        model_json_readable(mock_ws)

        # First poll tick observes RUNNING (non-terminal); second poll
        # tick observes TERMINATED/SUCCESS. Two distinct ``get_run``
        # responses simulate the two separate process ticks the real
        # poll loop performs.
        running_state = MagicMock()
        running_state.life_cycle_state.value = "RUNNING"
        running_state.result_state = None
        running_state.state_message = ""
        running_run = MagicMock()
        running_run.state = running_state

        done_state = MagicMock()
        done_state.life_cycle_state.value = "TERMINATED"
        done_state.result_state.value = "SUCCESS"
        done_state.state_message = ""
        done_run = MagicMock()
        done_run.state = done_state

        mock_ws.jobs.get_run.side_effect = [running_run, done_run]

        run = _make_run(session, business)
        dag = Dag(
            intent="install",
            steps=(
                OperationStep(
                    name="install",
                    params={
                        "scope": "ecm",
                        "business_name": "terra_nova",
                        "deployment_catalog": "vibe_modeling_test",
                        "schema_prefix": "ecm_",
                        "cataloging_style": "One Catalog",
                        "model_version": 1,
                    },
                ),
            ),
        )

        orch = Orchestrator(ws=mock_ws)
        orch.start(run, dag, session)

        # The DAG factory would normally stamp parent_version_id when
        # constructing the step; this test sets it directly on the
        # persisted row to isolate the extras round-trip from DAG-
        # factory concerns.
        row = session.exec(
            select(RunOperation).where(RunOperation.run_id == run.id)
        ).one()
        row.parent_version_id = mv.id
        session.add(row)
        session.commit()

        # Tick 1: RUNNING — non-terminal, no ModelVersion writeback yet.
        orch.advance(run, session)
        session.refresh(mv)
        assert mv.uc_catalog == ""
        assert mv.deployment_status == "draft"

        # Tick 2: TERMINATED/SUCCESS — this is the tick that must see the
        # REAL deployment_catalog, not an empty string, because the
        # handle is rebuilt fresh from the DB on every tick.
        orch.advance(run, session)
        session.refresh(mv)
        session.refresh(run)

        assert mv.deployment_status == "deployed"
        assert mv.uc_catalog == "vibe_modeling_test", (
            "uc_catalog was not stamped from the real dispatch-time "
            "deployment_catalog — dispatch()'s handle.extra never made "
            "it into rollback_state_json for _advance_running to "
            "rehydrate on the terminal poll tick."
        )
        assert run.status == "completed"

    def test_vibe_iterate_dispatch_extras_land_on_row_exactly_once(
        self, engine, session, business, mock_ws, patched_registry_full
    ):
        """``VibeIterate.dispatch()`` no longer writes ``rollback_state_json``
        itself (see ``_upsert_run_op_dispatch`` in ``vibe_iterate.py``) -
        that write is the orchestrator's generic ``_dispatch_pending``
        responsibility, applied identically to every primitive. This test
        drives the REAL ``VibeIterate`` primitive through
        ``Orchestrator.start`` (the actual dispatch path, not a hand-built
        handle) and proves the row still ends up with the exact same
        dispatch-time extras as before the primitive stopped writing them
        itself.
        """
        from vibe_modeling.backend.services.operations.vibe_iterate import (
            VibeIterate,
        )

        patched_registry_full["vibe_iterate"] = VibeIterate()

        parent = ModelVersion(
            business_id=business,
            version=1,
            scope="ecm",
            status="completed",
            uc_catalog="vibe_modeling_test",
        )
        session.add(parent)
        session.commit()
        session.refresh(parent)

        mock_run = MagicMock()
        mock_run.response = MagicMock()
        mock_run.response.run_id = 4242
        mock_ws.jobs.run_now.return_value = mock_run

        run = _make_run(session, business)
        dag = Dag(
            intent="vibe-iterate",
            steps=(
                OperationStep(
                    name="vibe_iterate",
                    params={
                        "vibe_instructions": "rename customer to client",
                        "deployment_catalog": "vibe_modeling_test",
                    },
                ),
            ),
        )

        # vibe_iterate.dispatch() raises immediately if
        # ctx.parent_version_id is unset, and ``Orchestrator.start``
        # dispatches step 0 synchronously - so the row must carry
        # ``parent_version_id`` from creation, exactly as the real
        # router pre-creates the row before calling ``start`` (see
        # ``router.py``'s "Pre-create the RunOperation row(s) so we can
        # stamp parent_version_id before the orchestrator dispatches").
        row = RunOperation(
            run_id=run.id,
            step_index=0,
            operation_name="vibe_iterate",
            params_json=json.dumps(dag.steps[0].params),
            status="pending",
            parent_version_id=parent.id,
        )
        session.add(row)
        session.commit()

        orch = Orchestrator(ws=mock_ws)
        orch.start(run, dag, session)

        row = session.exec(
            select(RunOperation).where(RunOperation.run_id == run.id)
        ).one()
        assert row.databricks_run_id == 4242
        persisted = json.loads(row.rollback_state_json or "{}")
        assert persisted.get("deployment_catalog") == "vibe_modeling_test"
        assert persisted.get("business_name") == "test_co"
        assert persisted.get("parent_version_int") == 1
        assert isinstance(persisted.get("session_id_bigint"), int)


class TestUninstallWarningThroughRunner:
    """E-14: an uninstall whose agent could not drop every schema ends the
    run ``completed`` with the version uninstalled, and the run returns the
    warning."""

    def test_partial_drop_completes_the_run_with_a_warning(
        self, engine, session, business, mock_ws, patched_registry_full, monkeypatch
    ):
        from vibe_modeling.backend.routes._helpers import _build_run_out
        from vibe_modeling.backend.services.operations import uninstall as uninstall_op
        from vibe_modeling.backend.services.operations.uninstall import Uninstall

        from ._lifecycle_fixtures import UNINSTALL_EXIT_PARTIAL, install_output

        released = []
        monkeypatch.setattr(uninstall_op, "set_deploy_status", lambda *a: released.append(a))
        patched_registry_full["uninstall"] = Uninstall()
        session.add(AgentConfig(job_id=999, job_name="dbx_vibe_modelling", warehouse_id="wh-1"))
        mv = ModelVersion(
            business_id=business, version=1, scope="ecm", status="completed",
            deployment_status="deployed", uc_catalog="business_1", files_catalog="business_1",
        )
        session.add(mv)
        session.flush()
        for db in ("ecm_sales", "ecm_intake"):
            session.add(Domain(version_id=mv.id, name=db, database_name=db))
        session.commit()
        session.refresh(mv)
        mock_ws.schemas.list.side_effect = lambda catalog_name: [
            SimpleNamespace(name=n) for n in ("ecm_sales", "ecm_intake", "_metamodel")
        ]

        started = MagicMock()
        started.run_id = 555
        started.response = MagicMock()
        started.response.run_id = 555
        mock_ws.jobs.run_now.return_value = started
        mock_ws.jobs.get_run_output.return_value = install_output(UNINSTALL_EXIT_PARTIAL)
        done = MagicMock()
        done.state.life_cycle_state.value = "TERMINATED"
        done.state.result_state.value = "SUCCESS"
        done.state.state_message = ""
        mock_ws.jobs.get_run.return_value = done

        run = _make_run(session, business)
        dag = Dag(
            intent="uninstall",
            steps=(
                OperationStep(
                    name="uninstall",
                    params={
                        "scope": "ecm", "business_name": "terra_nova", "deployment_catalog": "business_1",
                        "schema_prefix": "ecm_", "model_version": 1, "version_id": mv.id,
                    },
                ),
            ),
        )
        orch = Orchestrator(ws=mock_ws)
        orch.start(run, dag, session)
        orch.advance(run, session)
        session.commit()
        session.refresh(run)
        session.refresh(mv)

        assert run.status == "completed" and run.error_message == ""
        assert mv.deployment_status == "uninstalled"
        out = _build_run_out(run, mock_ws, session)
        [warning] = out.warnings
        assert "still there: ecm_intake, ecm_sales." in warning["message"]
        assert "2 more schemas could not be identified." in warning["message"]
        assert warning["severity"] == "warning" and warning["step_index"] == 0
        # A partial uninstall releases the version's registry rows too.
        assert released == [(mock_ws, "wh-1", "business_1", "terra_nova", 1, "ecm", "dry_run")]
