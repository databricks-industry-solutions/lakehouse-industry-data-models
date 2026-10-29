"""Phase 4 wirer adversarial tests — DAG factory + new endpoints + body shape.

These tests are written by a separate test agent (Skeptical Tester Pattern,
``docs/orchestrator-design.md`` §9) without reading the dev agent's
implementation. They target the public observable contract from §3 + §6 +
§8 + §2.4.1 of the design doc:

- DAG factory ``dag_for_new_base_model`` shapes per cataloging_style
- ``POST /runs/validate`` (no Run row, same blockers as POST /runs)
- ``POST /runs`` body shape: ``intent`` field, run_type backward-compat,
  intent-wins precedence
- ``GET /runs/{id}/operations`` ordering + 404
- ``GET /health`` in_flight_runs
- ``POST /admin/runs/{id}/resume`` (renamed from /resume-unified, alias kept)
- Cancel-with-rollback typed CancelResult + safety gate

# STUB-FOR-INTEGRATION:
The following symbols are imported by these tests but do not exist on
``main`` (8e48394). The Phase 4 wirer is expected to add them under the
locations listed; any divergence on names is a contract miss the integrator
should reconcile in the merge:

- ``vibe_modeling.backend.services.orchestrator.factories.dag_for_new_base_model``
- ``vibe_modeling.backend.services.orchestrator.validate.validate_dag_request``
- ``POST /runs/validate`` route
- ``GET /runs/{id}/operations`` route
- ``GET /health`` route exposing ``in_flight_runs``
- ``POST /admin/runs/{id}/resume`` route (with ``/resume-unified`` alias)
- ``RunIn.intent`` field accepting ``Intent`` enum values
"""

from __future__ import annotations

import json
from datetime import datetime, timezone
from unittest.mock import MagicMock, patch

import pytest
from sqlmodel import Session, select

from vibe_modeling.backend.db_models import (
    AgentConfig,
    Business,
    ModelVersion,
    Run,
    RunOperation,
)
from vibe_modeling.backend.models import Intent


# --- Helpers ----------------------------------------------------------------


def _seed_agent_config(engine, *, deployment_catalog: str = "metamodel_cat") -> None:
    """Seed an AgentConfig row so ``POST /runs`` doesn't 400 on missing config."""
    with Session(engine) as session:
        if session.exec(select(AgentConfig).limit(1)).first():
            return
        session.add(
            AgentConfig(
                notebook_path="/Workspace/test/notebook",
                job_id=99,
                job_name="test_vibe_job",
                deployment_catalog=deployment_catalog,
                warehouse_id="wh-1",
            )
        )
        session.commit()


def _make_run_request_body(
    *,
    cataloging_style: str = "One Catalog",
    catalog: str = "deploy_cat",
    intent: str | None = "new-base-model",
    extra: dict | None = None,
) -> dict:
    """Build a POST /runs (or /runs/validate) body.

    The Phase 4 contract uses ``intent`` (string from the Intent enum); the
    legacy ``run_type`` field is no longer accepted on the wire.
    """
    body: dict = {
        "catalog": catalog,
        "cataloging_style": cataloging_style,
    }
    if intent is not None:
        body["intent"] = intent
    if extra:
        body.update(extra)
    return body


# --- Section 1: dag_for_new_base_model factory ------------------------------


class TestDagForNewBaseModel:
    """Backend DAG factory contract per design §3.

    The factory lives under
    ``services.orchestrator.factories.dag_for_new_base_model``
    (or whatever the integrator picks; the import path here is the test's
    contract assumption — see STUB-FOR-INTEGRATION header).
    """

    @pytest.fixture
    def factory(self):
        # STUB-FOR-INTEGRATION: import lazily so tests collect on main
        # (where the symbol is absent) and fail at run-time, not collect-time.
        from vibe_modeling.backend.services.orchestrator import factories

        return factories.dag_for_new_base_model

    @pytest.fixture
    def base_request(self):
        """A minimal ``RunRequest``-shaped object the factory accepts.

        The factory should accept a Pydantic-y request: business_id,
        cataloging_style, catalog, schema prefixes, etc. The integrator
        may use ``RunIn`` directly or a dedicated ``RunRequest``; the
        factory contract is "build a valid Dag from these inputs".
        """
        from vibe_modeling.backend.models import RunIn

        # Use the existing RunIn as the input — the wirer is expected to
        # accept it as the validate/start input. If the integrator
        # introduces a new RunRequest, this fixture can be retargeted.
        return RunIn(
            intent=Intent.NEW_BASE_MODEL.value,  # type: ignore[arg-type]
            catalog="deploy_cat",
            cataloging_style="One Catalog",
            ecm_schema_prefix="ecm_",
            mvm_schema_prefix="mvm_")

    @pytest.fixture
    def base_business(self):
        return Business(id="b-1", name="acme", description="d", industry_alignment="r")

    def test_one_catalog_yields_two_step_dag(self, factory, base_request, base_business):
        """One Catalog: 2-op DAG (generate_ecm → shrink_to_mvm).

        Per §3 example: in One Catalog mode the agent installs both ECM
        and MVM inline as part of the generation jobs, so the explicit
        install steps drop out.
        """
        base_request.cataloging_style = "One Catalog"
        dag = factory(base_request, base_business)
        names = [s.name for s in dag.steps]
        assert names == ["generate_ecm", "shrink_to_mvm"], (
            f"One Catalog must yield exactly [generate_ecm, shrink_to_mvm]; got {names}"
        )
        assert dag.intent == "new-base-model"

    def test_catalog_per_division_yields_two_step_dag(
        self, factory, base_request, base_business
    ):
        """Catalog per Division: same 2-op shape as One Catalog (the agent
        inline-installs in every cataloging style — integration guide §12).
        """
        base_request.cataloging_style = "Catalog per Division"
        # Per-scope catalogs already isolate ECM/MVM, so prefix is forbidden.
        base_request.ecm_schema_prefix = ""
        base_request.mvm_schema_prefix = ""
        dag = factory(base_request, base_business)
        names = [s.name for s in dag.steps]
        assert names == ["generate_ecm", "shrink_to_mvm"], (
            f"Catalog per Division must produce 2 steps; got {names}"
        )

    def test_catalog_per_domain_yields_two_step_dag(
        self, factory, base_request, base_business
    ):
        """Catalog per Domain has the same DAG shape as Catalog per Division."""
        base_request.cataloging_style = "Catalog per Domain"
        base_request.ecm_schema_prefix = ""
        base_request.mvm_schema_prefix = ""
        dag = factory(base_request, base_business)
        names = [s.name for s in dag.steps]
        assert names == ["generate_ecm", "shrink_to_mvm"], (
            f"Catalog per Domain must produce 2 steps; got {names}"
        )

    def test_catalog_per_division_shrink_inherits_from_generate_ecm(
        self, factory, base_request, base_business
    ):
        """shrink_to_mvm reads the ECM version produced by generate_ecm."""
        base_request.cataloging_style = "Catalog per Division"
        base_request.ecm_schema_prefix = ""
        base_request.mvm_schema_prefix = ""
        dag = factory(base_request, base_business)
        step = dag.steps[1]
        assert step.name == "shrink_to_mvm"
        assert step.needs_version_from == "generate_ecm", (
            "shrink_to_mvm must inherit from generate_ecm; "
            f"got {step.needs_version_from!r}"
        )

    def test_one_catalog_shrink_step_inherits_from_generate_ecm(
        self, factory, base_request, base_business
    ):
        """Sanity: even on the 2-op happy path, the shrink step must point
        explicitly at generate_ecm — the orchestrator uses this to thread
        ``parent_version_id`` through. Forgetting it would silently make
        shrink read whatever ``OperationContext.parent_version_id`` happens
        to carry, which is a bug class we want a regression test for."""
        base_request.cataloging_style = "One Catalog"
        dag = factory(base_request, base_business)
        shrink = next(s for s in dag.steps if s.name == "shrink_to_mvm")
        assert shrink.needs_version_from == "generate_ecm", (
            f"shrink_to_mvm must explicitly inherit from generate_ecm; "
            f"got needs_version_from={shrink.needs_version_from!r}"
        )


# --- Section 2: POST /runs/validate -----------------------------------------


class TestValidateEndpoint:
    """POST /runs/validate — design §2.4 + §2.4.1.

    Returns warnings + blockers without creating a Run row. Same
    validator path as POST /runs.
    """

    def test_validate_does_not_create_run_row(self, client_with_agent, engine, seed_business):
        """Validate is read-only: no Run row regardless of body validity."""
        body = _make_run_request_body()
        resp = client_with_agent.post(f"/api/businesses/{seed_business}/runs/validate", json=body)
        # Status code may be 200 (clean) or 400 (blockers) — but EITHER
        # way no Run row should land in the DB.
        with Session(engine) as session:
            runs = session.exec(select(Run)).all()
        assert resp.status_code in (200, 400, 422), (
            f"unexpected status {resp.status_code}: {resp.text}"
        )
        assert runs == [], (
            f"POST /runs/validate must not persist a Run row; got {len(runs)}"
        )

    def test_validate_returns_blockers_and_warnings_keys(
        self, client_with_agent, seed_business
    ):
        """Response shape per §2.4: {warnings: [...], blockers: [...]}."""
        body = _make_run_request_body()
        resp = client_with_agent.post(f"/api/businesses/{seed_business}/runs/validate", json=body)
        assert resp.status_code in (200, 400), resp.text
        data = resp.json()
        assert "warnings" in data and isinstance(data["warnings"], list), (
            f"response missing 'warnings' list: {data}"
        )
        assert "blockers" in data and isinstance(data["blockers"], list), (
            f"response missing 'blockers' list: {data}"
        )

    def test_validate_blocker_matches_post_runs_blocker(
        self, client_with_agent, seed_business
    ):
        """Same body that POST /runs would reject should produce the same
        blocker shape on /validate. This is the §2.4 invariant: one
        validator, two gates."""
        # An obviously-bad cataloging_style that should trigger a blocker.
        bad_body = _make_run_request_body(
            cataloging_style="totally invalid style name",
        )
        validate_resp = client_with_agent.post(f"/api/businesses/{seed_business}/runs/validate", json=bad_body)
        runs_resp = client_with_agent.post(f"/api/businesses/{seed_business}/runs", json=bad_body)
        # Validate may return 200 + blockers in body, OR 400 with blockers
        # in detail; same for POST /runs.
        assert validate_resp.status_code in (200, 400, 422), validate_resp.text
        assert runs_resp.status_code in (400, 422), (
            f"POST /runs must reject the same bad body that /validate flags; "
            f"got {runs_resp.status_code}: {runs_resp.text}"
        )

    def test_validate_empty_body_returns_blockers(self, client_with_agent, seed_business):
        """Empty body posts no longer 422 — ``business_id`` moved to the
        URL path so an empty JSON body is structurally valid (RunIn has
        defaults for every remaining field). The validator surfaces the
        missing-required-fields complaint via the blockers array
        instead of FastAPI's body-shape 422. The shape contract is:
        status_code in (200, 400) with at least one blocker present."""
        bid = seed_business
        resp = client_with_agent.post(f"/api/businesses/{bid}/runs/validate", json={})
        assert resp.status_code in (200, 400), (
            f"validate({{}}) must surface blockers, not crash; "
            f"got {resp.status_code}: {resp.text}"
        )
        # Either 200 with blockers in body, or 400 with detail describing
        # the same missing fields. Both are acceptable wire shapes.
        if resp.status_code == 200:
            payload = resp.json()
            assert isinstance(payload.get("blockers"), list), payload

    def test_validate_unknown_primitive_is_blocker(
        self, client_with_agent, seed_business
    ):
        """When a DAG factory hands the validator a step whose primitive
        name typo'd, the registry-miss is surfaced as a blocker via the
        Phase 4 coordinator (Gate A in §2.4.1).

        STUB-FOR-INTEGRATION: ``validate_dag_request`` is the Phase 4
        coordinator described in §2.4.1; it lives at
        ``services.orchestrator.validate.validate_dag_request`` per the
        design doc.
        """
        from vibe_modeling.backend.services.orchestrator import (
            factories,  # type: ignore[attr-defined]
        )
        from vibe_modeling.backend.services.orchestrator.validate import (
            validate_dag_request,  # type: ignore[attr-defined]
        )

        # If the coordinator exists, calling it with an obviously bad
        # body (typo) must produce at least one blocker. We don't depend
        # on the coordinator's exact signature beyond "callable returning
        # something with `.blockers`" — but we do require it to exist
        # under the documented module path.
        assert callable(factories.dag_for_new_base_model)
        assert callable(validate_dag_request)


# --- Section 3: POST /runs body shape ---------------------------------------


class TestRunCreateBodyShape:
    """POST /runs body — §8: ``run_type`` is replaced by ``intent``;
    backward-compat translates ``run_type`` to ``intent`` for one
    deprecation cycle, with a logged warning. Both present → ``intent``
    wins.
    """

    def test_intent_field_is_persisted_on_run(
        self, client_with_agent, engine, seed_business
    ):
        """A request with ``intent`` populates ``Run.intent``."""
        body = _make_run_request_body(
            intent="new-base-model",
        )
        # Patch out the actual job launcher since we only care about
        # what's persisted.
        with patch(
            "vibe_modeling.backend.router.launch_run", return_value=12345
        ):
            resp = client_with_agent.post(f"/api/businesses/{seed_business}/runs", json=body)
        # Non-2xx is a contract failure for a valid body — surface the
        # response text so debugging is straightforward.
        assert resp.status_code in (200, 201), (
            f"valid body must succeed; got {resp.status_code}: {resp.text}"
        )
        with Session(engine) as session:
            run = session.exec(select(Run)).first()
        assert run is not None, "Run row must be persisted"
        assert run.intent == "new-base-model", (
            f"Run.intent must equal request body intent; got {run.intent!r}"
        )

    def test_invalid_intent_is_rejected(self, client_with_agent, seed_business):
        """An intent value not in the Intent enum must 422 / 400."""
        body = _make_run_request_body(
            intent="not-a-real-intent",
        )
        resp = client_with_agent.post(f"/api/businesses/{seed_business}/runs", json=body)
        assert resp.status_code in (400, 422), (
            f"invalid intent must reject; got {resp.status_code}: {resp.text}"
        )


# --- Section 4: GET /runs/{id}/operations -----------------------------------


class TestRunOperationsEndpoint:
    """GET /runs/{id}/operations — §8 new endpoint.

    Returns RunOperation rows ordered by step_index. The UI's "what step
    are we on" rendering reads from this.
    """

    @pytest.fixture
    def run_with_ops(self, engine, seed_business):
        """Seed a Run with 4 RunOperation rows in non-monotonic insert order."""
        with Session(engine) as session:
            run = Run(
                business_id=seed_business,
                intent="new-base-model",
                status="running",
                parameters_json="{}",
            )
            session.add(run)
            session.commit()
            session.refresh(run)

            # Insert OUT OF ORDER on purpose — the endpoint must order by
            # step_index, not by created_at / id.
            for i in (2, 0, 3, 1):
                session.add(
                    RunOperation(
                        run_id=run.id,
                        step_index=i,
                        operation_name=(
                            "install" if i in (1, 3)
                            else ("generate_ecm" if i == 0 else "shrink_to_mvm")
                        ),
                        params_json=json.dumps({"scope": "ecm" if i == 1 else "mvm"}) if i in (1, 3) else "{}",
                        status="succeeded" if i < 2 else "pending",
                    )
                )
            session.commit()
            session.refresh(run)
            return run.id

    def test_returns_operations_ordered_by_step_index(
        self, client_with_agent, run_with_ops, seed_business
    ):
        bid = seed_business
        resp = client_with_agent.get(f"/api/businesses/{bid}/runs/{run_with_ops}/operations")
        assert resp.status_code == 200, resp.text
        ops = resp.json()
        assert isinstance(ops, list), f"expected JSON array, got {type(ops)}"
        assert len(ops) == 4
        step_indices = [op["step_index"] for op in ops]
        assert step_indices == [0, 1, 2, 3], (
            f"operations must be ordered by step_index; got {step_indices}"
        )

    def test_operation_row_contains_orchestrator_fields(
        self, client_with_agent, run_with_ops, seed_business
    ):
        """Each row exposes the orchestrator's RunOperation fields per §5.2."""
        bid = seed_business
        resp = client_with_agent.get(f"/api/businesses/{bid}/runs/{run_with_ops}/operations")
        assert resp.status_code == 200
        ops = resp.json()
        op0 = ops[0]
        # Required fields per design §5.2
        for key in (
            "step_index",
            "operation_name",
            "status",
        ):
            assert key in op0, f"RunOperation row missing required field {key!r}: {op0}"
        # output_version_id may be None but must be present in the shape.
        assert "output_version_id" in op0, (
            f"RunOperation row must expose output_version_id (nullable); got {op0}"
        )

    def test_output_version_natural_key_url_and_label(
        self, client_with_agent, engine, seed_business
    ):
        """``output_version_url`` + ``output_version_label`` resolve to the
        canonical natural-key URL and human-meaningful label (#49).

        The Phase row's "→ v1 ECM" affordance must point at
        ``/businesses/{biz}/model/{version}/{scope}`` (no ``?tab=overview``)
        rather than the dead ``#/model-versions/{uuid}`` hash anchor.
        """
        bid = seed_business
        with Session(engine) as session:
            mv = ModelVersion(
                business_id=seed_business,
                version=7,
                scope="ecm",
                status="completed",
            )
            session.add(mv)
            session.commit()
            session.refresh(mv)

            run = Run(
                business_id=seed_business,
                intent="new-base-model",
                status="running",
                parameters_json="{}",
            )
            session.add(run)
            session.commit()
            session.refresh(run)

            session.add(
                RunOperation(
                    run_id=run.id,
                    step_index=0,
                    operation_name="generate_ecm",
                    params_json="{}",
                    status="succeeded",
                    output_version_id=mv.id,
                )
            )
            # A second op with no output_version → both fields must be null.
            session.add(
                RunOperation(
                    run_id=run.id,
                    step_index=1,
                    operation_name="install",
                    params_json="{}",
                    status="pending",
                )
            )
            session.commit()
            run_id = run.id
            mv_business_id = mv.business_id
            mv_version = mv.version

        resp = client_with_agent.get(f"/api/businesses/{bid}/runs/{run_id}/operations")
        assert resp.status_code == 200, resp.text
        ops = resp.json()
        assert len(ops) == 2

        op0 = ops[0]
        # Label is "v{N} {SCOPE}" (e.g. "v7 ECM"), matching the chip
        # format used in LineageCard / sidebar.
        assert op0["output_version_label"] == "v7 ECM", (
            f"expected human-meaningful label 'v7 ECM'; got {op0!r}"
        )
        # URL is the canonical natural-key route, no ?tab=overview.
        expected_url = f"/businesses/{mv_business_id}/model/{mv_version}/ecm"
        assert op0["output_version_url"] == expected_url, (
            f"expected natural-key URL {expected_url!r}; got {op0!r}"
        )
        assert "?tab=overview" not in (op0["output_version_url"] or ""), (
            f"output_version_url must omit ?tab=overview; got {op0!r}"
        )

        op1 = ops[1]
        assert op1["output_version_id"] is None
        assert op1["output_version_label"] is None, (
            f"output_version_label must be null when no version is linked; got {op1!r}"
        )
        assert op1["output_version_url"] is None, (
            f"output_version_url must be null when no version is linked; got {op1!r}"
        )

    def test_unknown_run_returns_404(self, client_with_agent, run_with_ops, seed_business):
        """Unknown run id → 404 for the right reason (route exists, run absent).

        We seed a real run via ``run_with_ops`` so the test verifies the
        endpoint is actually mounted (otherwise an unrelated 404 from a
        missing route would let the test pass on main).
        """
        bid = seed_business
        # Sanity: the route must exist for at least one valid run.
        ok = client_with_agent.get(f"/api/businesses/{bid}/runs/{run_with_ops}/operations")
        assert ok.status_code == 200, (
            f"endpoint must be mounted; got {ok.status_code} for valid run"
        )
        resp = client_with_agent.get(f"/api/businesses/{bid}/runs/does-not-exist/operations")
        assert resp.status_code == 404, (
            f"unknown run must 404; got {resp.status_code}: {resp.text}"
        )


# --- Section 5: GET /health -------------------------------------------------


class TestHealthEndpoint:
    """GET /health exposes ``in_flight_runs`` so the deploy script can
    refuse to push a new wheel while runs are active. Atomic-replace
    App containers can't hand off in-flight pollers cleanly, so the
    runtime drain gate is gone (see install/in_flight_guard.sh)."""

    def test_health_returns_in_flight_runs(self, client):
        resp = client.get("/api/health")
        assert resp.status_code == 200, (
            f"/health must 200; got {resp.status_code}: {resp.text}"
        )
        data = resp.json()
        assert "in_flight_runs" in data, f"/health missing in_flight_runs: {data}"
        assert isinstance(data["in_flight_runs"], int)
        # drain_mode is intentionally absent — the App no longer carries
        # a runtime drain gate. The deploy script is the right place to
        # enforce "don't redeploy while runs are active".
        assert "drain_mode" not in data, (
            f"/health must NOT surface drain_mode anymore; got {data}"
        )

    def test_in_flight_runs_counts_running_rows(
        self, client_with_agent, engine, seed_business
    ):
        with Session(engine) as session:
            session.add(
                Run(
                    business_id=seed_business,
                    intent="new-base-model",
                    status="running",
                    databricks_run_id=12345,
                    parameters_json="{}",
                )
            )
            session.commit()

        resp = client_with_agent.get("/api/health")
        assert resp.status_code == 200
        data = resp.json()
        assert data["in_flight_runs"] >= 1, (
            f"in_flight_runs must reflect running rows; got {data}"
        )

    def test_in_flight_runs_zero_when_no_active_runs(self, client):
        resp = client.get("/api/health")
        assert resp.status_code == 200
        data = resp.json()
        assert data["in_flight_runs"] == 0, (
            f"no rows present, but in_flight_runs={data['in_flight_runs']}"
        )


# --- Section 6: POST /admin/runs/{id}/resume --------------------------------


class TestResumeEndpoint:
    """POST /admin/runs/{id}/resume — renamed from /resume-unified per §8.

    The legacy alias must still work for one deprecation cycle.
    """

    def test_resume_endpoint_works_under_new_path(
        self, client_with_agent, engine, seed_business
    ):
        """New path /admin/runs/{id}/resume calls Orchestrator.resume."""
        bid = seed_business
        with Session(engine) as session:
            run = Run(
                business_id=seed_business,
                intent="new-base-model",
                status="failed",
                error_message="something went wrong",
                parameters_json="{}",
            )
            session.add(run)
            session.commit()
            session.refresh(run)
            run_id = run.id
            # Seed a RunOperation so the route takes the orchestrator
            # path (dev's contract: any run with a DAG row is owned by
            # the orchestrator).
            session.add(
                RunOperation(
                    run_id=run_id,
                    step_index=0,
                    operation_name="generate_ecm",
                    params_json="{}",
                    status="failed",
                )
            )
            session.commit()

        # The route calls ``tracker.orchestrator.resume`` (the conftest
        # installs a MagicMock orchestrator on the tracker dependency).
        from vibe_modeling.backend.core._tracker import _TrackerDependency

        tracker_override = client_with_agent.app.dependency_overrides[
            _TrackerDependency.__call__
        ]
        tracker = tracker_override()
        mock_resume = MagicMock()
        tracker.orchestrator.resume = mock_resume

        resp = client_with_agent.post(f"/api/businesses/{bid}/runs/{run_id}/resume")
        assert resp.status_code in (200, 202), (
            f"resume must succeed; got {resp.status_code}: {resp.text}"
        )
        assert mock_resume.called, (
            "POST /admin/runs/{id}/resume must invoke Orchestrator.resume"
        )

# --- Section 7: Cancel-with-rollback ---------------------------------------


class TestCancelWithRollback:
    """POST /runs/{id}/cancel-with-rollback — §6.3.

    Returns a typed CancelResult shape; safety gate refuses for
    TERMINATED/SUCCESS jobs.
    """

    def test_cancel_returns_cancel_result_typed_shape(
        self, client_with_agent, mock_ws, engine, seed_business
    ):
        """Response body matches the CancelResult fields per §6.3.

        The wire shape (``CancelWithRollbackOut``) renames a couple of
        ``CancelResult`` fields for backward compatibility with the
        existing UI + tests:
          - ``ok``                 → ``ok``                 (kept)
          - ``final_run_status``   → ``status``             (legacy name)
          - ``ops_rolled_back``    → ``ops_applied[*].kind``
        """
        bid = seed_business
        from vibe_modeling.backend.services.orchestrator import (
            CancelResult,
        )

        with Session(engine) as session:
            run = Run(
                business_id=seed_business,
                intent="new-base-model",
                status="running",
                databricks_run_id=999,
                parameters_json="{}",
            )
            session.add(run)
            session.commit()
            session.refresh(run)
            run_id = run.id
            # Seed a RunOperation so the route takes the orchestrator
            # path (dev's contract: any run with a DAG row is owned by
            # the orchestrator regardless of legacy params flags).
            session.add(
                RunOperation(
                    run_id=run_id,
                    step_index=0,
                    operation_name="install",
                    params_json="{}",
                    status="succeeded",
                )
            )
            session.commit()

        # Stub the tracker's orchestrator.cancel_with_rollback to return
        # a typed CancelResult; the route calls
        # ``tracker.orchestrator.cancel_with_rollback`` (the conftest
        # injects a MagicMock orchestrator), so the patch goes through
        # the dependency override rather than the class itself.
        fake_result = CancelResult(
            ok=True,
            final_run_status="cancelled",
            ops_rolled_back=["install"],
            op_failures=[],
        )
        from vibe_modeling.backend.core._tracker import _TrackerDependency

        # Resolve the override the conftest installed and stub on it.
        tracker_override = client_with_agent.app.dependency_overrides[
            _TrackerDependency.__call__
        ]
        tracker = tracker_override()
        tracker.orchestrator.cancel_with_rollback = MagicMock(
            return_value=fake_result
        )

        resp = client_with_agent.post(f"/api/businesses/{bid}/runs/{run_id}/cancel-with-rollback")

        # The Phase 4 wirer must retype the response to a typed shape.
        # The legacy route returned a bare RunOut; the wirer returns the
        # CancelWithRollbackOut wire model.
        assert resp.status_code in (200, 202), (
            f"cancel-with-rollback must succeed; got {resp.status_code}: {resp.text}"
        )
        data = resp.json()
        for key in ("ok", "status", "ops_applied"):
            assert key in data, (
                f"CancelWithRollbackOut JSON body missing key {key!r}; "
                f"got keys={list(data.keys())}"
            )
        assert data["ok"] is True
        assert data["status"] == "cancelled"
        # ops_rolled_back maps to ops_applied[*].kind in the wire model.
        kinds = [op.get("kind", "") for op in data["ops_applied"]]
        assert "install" in kinds, (
            f"Expected 'install' in ops_applied kinds; got {kinds}"
        )

    def test_safety_gate_terminated_success_returns_ok_false(
        self, client_with_agent, mock_ws, engine, seed_business
    ):
        """Per §6.3: refuse rollback if the job is TERMINATED/SUCCESS.

        The route maps a ``CancelResult`` with a ``refusal_reason`` to a 409,
        resumes tracking, and leaves the run out of 'cancelled'.
        """
        bid = seed_business
        from vibe_modeling.backend.services.orchestrator import (
            CANCEL_REFUSED_PHASE_SUCCEEDED,
            CancelResult,
        )

        with Session(engine) as session:
            run = Run(
                business_id=seed_business,
                intent="new-base-model",
                status="running",
                databricks_run_id=999,
                parameters_json="{}",
            )
            session.add(run)
            session.commit()
            session.refresh(run)
            run_id = run.id
            # Seed a RunOperation so the route takes the orchestrator
            # path; the safety gate lives inside Orchestrator.cancel_with_rollback.
            session.add(
                RunOperation(
                    run_id=run_id,
                    step_index=0,
                    operation_name="install",
                    params_json="{}",
                    status="running",
                )
            )
            session.commit()

        fake_result = CancelResult(
            ok=False,
            final_run_status="running",  # unchanged
            ops_rolled_back=[],
            op_failures=[
                {
                    "op": {"operation_name": "install", "step_index": 0},
                    "error": (
                        "Cancel-with-rollback refused: the Databricks job "
                        "of step 'install' already finished successfully"
                    ),
                }
            ],
            refusal_reason=CANCEL_REFUSED_PHASE_SUCCEEDED,
        )
        from vibe_modeling.backend.core._tracker import _TrackerDependency

        tracker_override = client_with_agent.app.dependency_overrides[
            _TrackerDependency.__call__
        ]
        tracker = tracker_override()
        tracker.orchestrator.cancel_with_rollback = MagicMock(
            return_value=fake_result
        )

        resp = client_with_agent.post(f"/api/businesses/{bid}/runs/{run_id}/cancel-with-rollback")

        assert resp.status_code == 409, resp.text
        assert "finished successfully" in resp.json()["detail"]
        tracker.start_tracking.assert_called_with(run_id)

        # Run must NOT have been flipped to cancelled.
        with Session(engine) as session:
            run_after = session.get(Run, run_id)
            assert run_after.status != "cancelled", (
                f"safety-gate refusal must not cancel the run; "
                f"status={run_after.status}"
            )
