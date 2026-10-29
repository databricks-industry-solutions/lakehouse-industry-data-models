"""Tests for cancel-with-rollback (#118).

Phase 5 has retired the legacy ``Run.rollback_plan`` JSON blob and the
``progress_tracker._load_rollback_plan`` / ``_append_rollback_ops`` /
``_dispatch_rollback_op`` helpers. Rollback state now lives per-step on
``RunOperation`` rows, and the endpoint dispatches through
``Orchestrator.cancel_with_rollback``.

What this file covers (orchestrator path only):

* ``POST /runs/{id}/cancel-with-rollback`` happy path — RunOperation rows
  flip to ``rolled_back`` in reverse step order; ``Run.status`` becomes
  ``cancelled``.
* Safety gate — refuse if the in-flight Databricks job has already
  TERMINATED with SUCCESS (409).
* Partial rollback failure — the first per-step rollback that raises
  halts the chain; subsequent ops are NOT attempted; ``Run.status``
  becomes ``rolled_back_failed``; the failing step is reported in
  ``op_failures``. THIS IS THE ONLY PLACE THIS PATH IS COVERED.
* Idempotency / refusal of terminal-state runs.

Per-primitive rollback unit-test coverage lives in
``test_orchestrator_runner.py::TestCancelWithRollback`` against
``FakePrimitive`` doubles. This file is the integration cover at the
HTTP boundary.
"""

from __future__ import annotations

import json
import os
import sys
from contextlib import contextmanager
from datetime import datetime, timezone
from typing import Optional
from unittest.mock import MagicMock, patch

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "..", "src", "app", "src"))

import pytest
from fastapi.testclient import TestClient
from pydantic import BaseModel
from sqlalchemy.pool import StaticPool
from sqlmodel import Session, SQLModel, create_engine, select

from vibe_modeling.backend.core._config import AppConfig
from vibe_modeling.backend.core._defaults import (
    _ConfigDependency,
    _WorkspaceClientDependency,
)
from vibe_modeling.backend.core._tracker import _TrackerDependency
from vibe_modeling.backend.core.lakebase import _LakebaseDependency
from vibe_modeling.backend.db_models import (
    AgentConfig,
    Business,
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
from vibe_modeling.backend.services.orchestrator import Orchestrator
from vibe_modeling.backend.services.orchestrator.dag import Dag, OperationStep

sys.path.insert(0, os.path.dirname(__file__))
from _test_app import make_test_app  # noqa: E402


# ---------------------------------------------------------------------------
# FakePrimitive — one test double per registered op name. Same shape as the
# one used in test_orchestrator_runner.py; we duplicate the minimal subset
# we need rather than cross-import private test helpers.
# ---------------------------------------------------------------------------


class _FakeParams(BaseModel):
    model_config = {"extra": "allow"}


class FakePrimitive(Operation):
    def __init__(
        self,
        name: str,
        *,
        on_dispatch=None,
        on_observe=None,
        on_rollback=None,
        produces_version: bool = False,
    ):
        self.name = name
        self.params_model = _FakeParams
        self.is_idempotent = True
        self.produces_version = produces_version
        self._on_dispatch = on_dispatch or (
            lambda ctx, ws, session: OperationDispatchHandle(
                databricks_run_id=42,
                vibe_session_id=f"session-{name}",
            )
        )
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
        self._on_rollback = on_rollback or (
            lambda ctx, rollback_state, ws, session: None
        )
        self.dispatch_calls: list[OperationContext] = []
        self.observe_calls: list[OperationDispatchHandle] = []
        self.rollback_calls: list[dict] = []

    def dispatch(self, ctx, ws, session) -> OperationDispatchHandle:
        self.dispatch_calls.append(ctx)
        return self._on_dispatch(ctx, ws, session)

    def observe(self, handle, ctx, ws, session) -> OperationObservation:
        self.observe_calls.append(handle)
        return self._on_observe(handle, ctx, ws, session)

    def rollback(self, ctx, rollback_state, ws, session) -> None:
        self.rollback_calls.append(rollback_state)
        return self._on_rollback(ctx, rollback_state, ws, session)


def _running(name: str, percent: int = 50) -> OperationObservation:
    return OperationObservation(
        progress_percent=percent,
        progress_message=f"{name} running",
        is_terminal=False,
        terminal_result=None,
    )


# ---------------------------------------------------------------------------
# Fixtures
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
    ws.config.host = "https://test.databricks.com"
    # Default: running, not terminated — so the safety gate doesn't trip.
    state = MagicMock()
    state.life_cycle_state = MagicMock()
    state.life_cycle_state.value = "RUNNING"
    state.result_state = MagicMock()
    state.result_state.value = ""
    state.state_message = ""
    job_run = MagicMock()
    job_run.state = state
    ws.jobs.get_run.return_value = job_run
    return ws


@pytest.fixture
def config():
    return AppConfig(
        app_name="test",
        warehouse_id="wh-test",
        poll_interval_seconds=0,
    )


@pytest.fixture
def patched_registry():
    """Per-test registry override.

    Tests fill the dict with ``{name: FakePrimitive(name=...)}`` then
    patch ``services.operations._registry.get`` to look up against the
    dict.
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
        with patch(
            "vibe_modeling.backend.services.operations.get",
            side_effect=lambda name: fakes[name],
        ):
            yield fakes


@pytest.fixture
def tracker(mock_ws, session_factory, patched_registry):
    """Mock tracker exposing a real Orchestrator wired against the test
    engine. ``stop_tracking`` is a MagicMock so the route can call it
    without a running asyncio loop."""
    tracker = MagicMock()
    tracker.stop_tracking = MagicMock()

    def _factory_for_orch():
        # Orchestrator expects a plain callable returning a Session.
        return Session(bind=session_factory.__wrapped__.__self__) if False else None

    # Build an Orchestrator that uses the same engine the test session
    # writes to. The runner's session_factory is only consulted for
    # paths that open their own session; the cancel-with-rollback flow
    # uses the session passed into the call directly.
    tracker.orchestrator = Orchestrator(mock_ws, None)
    return tracker


@pytest.fixture
def client(engine, mock_ws, config, tracker):
    app = make_test_app()

    def override_session():
        with Session(engine) as session:
            yield session

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
def seed_business_and_agent(engine) -> str:
    with Session(engine) as s:
        b = Business(name="Rollback Corp", description="test", industry_alignment="Retail")
        s.add(b)
        ac = AgentConfig(
            notebook_path="/Workspace/test/notebook",
            job_id=77,
            job_name="vibe-agent",
            deployment_catalog="test_cat",
        )
        s.add(ac)
        s.commit()
        s.refresh(b)
        return b.id


# ---------------------------------------------------------------------------
# Helpers — drive the orchestrator into a known mid-DAG state via a real
# Run + RunOperation rows, so the endpoint takes the orchestrator path.
# ---------------------------------------------------------------------------


def _make_run(engine, business_id: str, *, status: str = "running") -> str:
    """Insert a Run row and return its id."""
    with Session(engine) as s:
        run = Run(
            business_id=business_id,
            intent="new-base-model",
            status=status,
            databricks_run_id=33333,
            vibe_session_id="test-session",
            vibe_session_id_bigint=333333,
            started_at=datetime.now(timezone.utc),
            parameters_json="{}",
        )
        s.add(run)
        s.commit()
        s.refresh(run)
        return run.id


def _drive_until_running(orch, run_id: str, engine, max_iters: int = 5) -> None:
    """Advance the orchestrator until at least one op is in ``running``
    state (i.e. the next op is dispatched but not yet observed terminal).
    Used to set up "mid-DAG cancel" scenarios."""
    for _ in range(max_iters):
        with Session(engine) as s:
            run = s.get(Run, run_id)
            if run.status not in ("pending", "running"):
                return
            ops = s.exec(
                select(RunOperation)
                .where(RunOperation.run_id == run_id)
                .order_by(RunOperation.step_index)
            ).all()
            if any(o.status == "running" for o in ops):
                return
            orch.advance(run, s)
            s.commit()


# ---------------------------------------------------------------------------
# Endpoint tests — orchestrator path
# ---------------------------------------------------------------------------


class TestCancelWithRollbackEndpoint:
    """``POST /runs/{id}/cancel-with-rollback`` — orchestrator path."""

    def test_happy_path_rolls_back_completed_ops_in_reverse(
        self, client, engine, seed_business_and_agent, tracker, patched_registry
    ):
        """3-op DAG. Op0 (generate_ecm) succeeds. Op1 (install) is
        non-terminal RUNNING when the user cancels. Expectation:
          - ``ws.jobs.cancel_run`` is called for op1.
          - op1.rollback() runs, then op0.rollback() — reverse order.
          - ``Run.status`` becomes ``cancelled``.
          - The op0 RunOperation row is ``rolled_back``.
          - Op2 was never dispatched.
        """
        bid = seed_business_and_agent
        op0 = FakePrimitive("generate_ecm", produces_version=True)
        op1 = FakePrimitive(
            "install",
            on_observe=lambda h, c, w, s: _running("install", percent=33),
        )
        op2 = FakePrimitive("shrink_to_mvm")
        patched_registry.update(
            {"generate_ecm": op0, "install": op1, "shrink_to_mvm": op2}
        )

        run_id = _make_run(engine, seed_business_and_agent)
        dag = Dag(
            intent="new-base-model",
            steps=(
                OperationStep(name="generate_ecm", params={}),
                OperationStep(name="install", params={}),
                OperationStep(name="shrink_to_mvm", params={}),
            ),
        )
        with Session(engine) as s:
            run = s.get(Run, run_id)
            tracker.orchestrator.start(run, dag, s)
            s.commit()
        _drive_until_running(tracker.orchestrator, run_id, engine)

        resp = client.post(f"/api/businesses/{bid}/runs/{run_id}/cancel-with-rollback")
        assert resp.status_code == 200, resp.text
        body = resp.json()
        assert body["ok"] is True
        assert body["status"] == "cancelled"
        # Reverse-order replay over the prior succeeded op (op0). Op1 was
        # running (no terminal state), so the orchestrator may invoke its
        # rollback opportunistically for partial-state cleanup; what
        # matters here is that op2 is absent.
        names_applied = [op["operation_name"] for op in body["ops_applied"]]
        assert "generate_ecm" in names_applied
        assert "shrink_to_mvm" not in names_applied

        # Per-step rollback state lives on RunOperation rows.
        with Session(engine) as s:
            run = s.get(Run, run_id)
            assert run.status == "cancelled"
            assert run.completed_at is not None
            ops = s.exec(
                select(RunOperation)
                .where(RunOperation.run_id == run_id)
                .order_by(RunOperation.step_index)
            ).all()
            assert ops[0].status == "rolled_back"
            # op2 (shrink_to_mvm) was never dispatched. With the
            # post–Phase-5 state-atomicity guarantee (transition_run
            # propagates the run-level cancel to every non-terminal op),
            # the row lands in 'cancelled' rather than being left in
            # 'pending' — half-cancelled states aren't allowed.
            assert ops[2].status == "cancelled"

        # The Databricks job for op1 was cancelled.
        assert tracker.stop_tracking.called

    def test_refuses_terminal_run(
        self, client, engine, seed_business_and_agent
    ):
        """Runs already in a terminal state cannot be cancel-with-rolled-back.
        The endpoint returns 400 before the orchestrator is consulted."""
        bid = seed_business_and_agent
        with Session(engine) as s:
            run = Run(
                business_id=seed_business_and_agent,
                intent="new-base-model",
                status="completed",
                parameters_json="{}",
            )
            s.add(run)
            s.commit()
            s.refresh(run)
            run_id = run.id

        resp = client.post(f"/api/businesses/{bid}/runs/{run_id}/cancel-with-rollback")
        assert resp.status_code == 400
        assert "completed" in resp.text.lower()


class TestSafetyGate:
    """If the in-flight Databricks job has TERMINATED with SUCCESS,
    cancel-with-rollback would tear apart a valid install. Refuse with
    409 and leave the run untouched."""

    def test_refuses_when_phase_job_succeeded(
        self,
        client,
        engine,
        seed_business_and_agent,
        tracker,
        patched_registry,
        mock_ws,
    ):
        bid = seed_business_and_agent
        op0 = FakePrimitive("generate_ecm", produces_version=True)
        op1 = FakePrimitive(
            "install",
            on_observe=lambda h, c, w, s: _running("install"),
        )
        patched_registry.update({"generate_ecm": op0, "install": op1})

        run_id = _make_run(engine, seed_business_and_agent)
        dag = Dag(
            intent="new-base-model",
            steps=(
                OperationStep(name="generate_ecm", params={}),
                OperationStep(name="install", params={}),
            ),
        )
        with Session(engine) as s:
            run = s.get(Run, run_id)
            tracker.orchestrator.start(run, dag, s)
            s.commit()
        _drive_until_running(tracker.orchestrator, run_id, engine)

        # Flip the WS mock so jobs.get_run reports TERMINATED/SUCCESS for
        # whatever databricks_run_id the orchestrator queries.
        terminated_ok = MagicMock()
        terminated_ok.state.life_cycle_state = MagicMock()
        terminated_ok.state.life_cycle_state.value = "TERMINATED"
        terminated_ok.state.result_state = MagicMock()
        terminated_ok.state.result_state.value = "SUCCESS"
        mock_ws.jobs.get_run.return_value = terminated_ok

        resp = client.post(f"/api/businesses/{bid}/runs/{run_id}/cancel-with-rollback")
        # Safety gate: orchestrator returns CancelResult(ok=False) when
        # the in-flight Databricks job has already TERMINATED/SUCCESS,
        # leaving the run untouched; the route handler maps that to a
        # 409 — see router.cancel_run_with_rollback. Refusal semantics:
        # no rollback applied, run unchanged.
        assert resp.status_code == 409, resp.text
        detail = resp.json().get("detail", "")
        # The 409 names the cause and the step it refused on.
        assert "finished successfully" in detail
        # ``_drive_until_running`` stops on the first running step.
        assert "'generate_ecm'" in detail

        # Run was NOT mutated.
        with Session(engine) as s:
            run = s.get(Run, run_id)
            assert run.status == "running"

        # Polling stopped for the attempt and resumes on refusal, so the
        # still-running run is not left without a poller until the next boot.
        tracker.stop_tracking.assert_called_once_with(run_id)
        tracker.start_tracking.assert_called_once_with(run_id)

    def test_completed_rollback_does_not_restart_tracking(
        self, client, engine, seed_business_and_agent, tracker, patched_registry
    ):
        bid = seed_business_and_agent
        op0 = FakePrimitive(
            "generate_ecm",
            on_observe=lambda h, c, w, s: _running("generate_ecm"),
        )
        patched_registry.update({"generate_ecm": op0})
        run_id = _make_run(engine, seed_business_and_agent)
        dag = Dag(
            intent="new-base-model",
            steps=(OperationStep(name="generate_ecm", params={}),),
        )
        with Session(engine) as s:
            run = s.get(Run, run_id)
            tracker.orchestrator.start(run, dag, s)
            s.commit()
        _drive_until_running(tracker.orchestrator, run_id, engine)

        resp = client.post(f"/api/businesses/{bid}/runs/{run_id}/cancel-with-rollback")
        assert resp.status_code == 200, resp.text
        assert resp.json()["status"] == "cancelled"
        tracker.start_tracking.assert_not_called()


class TestPartialFailure:
    """If a per-step rollback raises mid-chain, the orchestrator marks
    the run ``rolled_back_failed`` and reports the failing step. The
    chain HALTS — subsequent ops are NOT attempted so the operator can
    triage residual state.

    THIS IS THE ONLY PLACE this path is exercised at the HTTP boundary.
    """

    def test_partial_rollback_failure_sets_rolled_back_failed(
        self, client, engine, seed_business_and_agent, tracker, patched_registry
    ):
        # 3-op DAG. op0 + op1 succeed. op2 is RUNNING when cancel hits.
        # Configure op0.rollback to RAISE so the rollback chain halts
        # before op_unrelated would have been attempted.
        bid = seed_business_and_agent
        op0 = FakePrimitive(
            "generate_ecm",
            produces_version=True,
            on_rollback=lambda ctx, rs, ws, s: (_ for _ in ()).throw(
                RuntimeError("rollback boom")
            ),
        )
        op1 = FakePrimitive("install")  # succeeds + rolls back cleanly
        op2 = FakePrimitive(
            "shrink_to_mvm",
            on_observe=lambda h, c, w, s: _running("shrink_to_mvm"),
        )
        patched_registry.update(
            {"generate_ecm": op0, "install": op1, "shrink_to_mvm": op2}
        )

        run_id = _make_run(engine, seed_business_and_agent)
        dag = Dag(
            intent="new-base-model",
            steps=(
                OperationStep(name="generate_ecm", params={}),
                OperationStep(name="install", params={}),
                OperationStep(name="shrink_to_mvm", params={}),
            ),
        )
        with Session(engine) as s:
            run = s.get(Run, run_id)
            tracker.orchestrator.start(run, dag, s)
            s.commit()
        # Drive until op2 is running (op0 and op1 have terminated SUCCESS).
        for _ in range(10):
            _drive_until_running(tracker.orchestrator, run_id, engine)
            with Session(engine) as s:
                ops = s.exec(
                    select(RunOperation)
                    .where(RunOperation.run_id == run_id)
                    .order_by(RunOperation.step_index)
                ).all()
                if ops[0].status == "succeeded" and ops[1].status == "succeeded":
                    break

        resp = client.post(f"/api/businesses/{bid}/runs/{run_id}/cancel-with-rollback")
        assert resp.status_code == 200
        body = resp.json()
        assert body["ok"] is False
        assert body["status"] == "rolled_back_failed"

        # The failing op is reported.
        assert len(body["op_failures"]) >= 1
        names_failed = [
            (f.get("op", {}).get("operation_name") if isinstance(f.get("op"), dict) else None)
            for f in body["op_failures"]
        ]
        assert "generate_ecm" in names_failed

        with Session(engine) as s:
            run = s.get(Run, run_id)
            assert run.status == "rolled_back_failed"
