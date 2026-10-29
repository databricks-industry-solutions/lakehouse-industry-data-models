"""Test job trigger, cancel, retry, and run status read against real router.py routes."""

import json
import pytest
from unittest.mock import MagicMock


class TestJobTrigger:
    def test_job_trigger_success(self, client_with_agent, mock_ws, seed_business):
        """When job triggers successfully, run becomes running with a databricks_run_id."""
        mock_run = MagicMock()
        mock_run.run_id = 12345
        mock_ws.jobs.run_now.return_value = mock_run

        resp = client_with_agent.post(f"/api/businesses/{seed_business}/runs", json={
            "catalog": "test_cat",
            "business_context_path": "/Volumes/test/ctx/vibes/ctx.json",
        })
        assert resp.status_code == 200
        data = resp.json()
        assert data["status"] == "running"
        assert data["databricks_run_id"] == 12345
        assert data["started_at"] is not None
        assert data["vibe_session_id"] is not None

        # Verify SDK called with notebook_params (not job_parameters)
        mock_ws.jobs.run_now.assert_called_once()
        call_kwargs = mock_ws.jobs.run_now.call_args.kwargs
        assert call_kwargs["job_id"] == 99
        assert "notebook_params" in call_kwargs
        assert call_kwargs["notebook_params"]["operation"] == "new base model"
        assert call_kwargs["notebook_params"]["deployment_catalog"] == "test_cat"

    def test_job_trigger_failure(self, client_with_agent, mock_ws, seed_business):
        """When job trigger fails, run becomes failed with error message."""
        mock_ws.jobs.run_now.side_effect = Exception("Connection refused")

        resp = client_with_agent.post(f"/api/businesses/{seed_business}/runs", json={
            "catalog": "test_catalog",
            "business_context_path": "/Volumes/test/ctx/vibes/ctx.json",
        })
        assert resp.status_code == 200
        data = resp.json()
        assert data["status"] == "failed"
        assert "Connection refused" in data["error_message"]

    def test_no_agent_config_returns_config_missing(self, client, seed_business):
        """When no AgentConfig exists, create_run answers the structured 422
        ``config_missing`` of the pre-flight's level 1."""
        resp = client.post(f"/api/businesses/{seed_business}/runs", json={
            "business_context_path": "/Volumes/test/ctx/vibes/ctx.json",
        })
        assert resp.status_code == 422, resp.text
        assert resp.json()["detail"]["error"] == "config_missing"
        assert "agent_job" in {m["key"] for m in resp.json()["detail"]["missing"]}

    def test_new_base_model_large_marks_unified_ecm_mvm(
        self, client_with_agent, mock_ws, seed_business
    ):
        """A `new-base-model` POST persists the run with the matching intent
        and routes through the orchestrator (no legacy unified phase keys
        in parameters_json)."""
        mock_run = MagicMock()
        mock_run.run_id = 4242
        mock_ws.jobs.run_now.return_value = mock_run

        resp = client_with_agent.post(f"/api/businesses/{seed_business}/runs", json={
            "intent": "new-base-model",
            "model_size": "large model",
            "catalog": "test_cat",
            "business_context_path": "/Volumes/test/ctx/vibes/ctx.json",
        })
        assert resp.status_code == 200
        stored = json.loads(resp.json()["parameters_json"])
        assert "ecm_mvm_unified" not in stored
        assert "ecm_mvm_phase" not in stored

    def test_new_base_model_intent_persists_regardless_of_model_size(
        self, client_with_agent, mock_ws, seed_business
    ):
        """`new-base-model` ignores any client-supplied model_size — the
        orchestrator's DAG hard-codes the ECM → shrink → MVM sequence."""
        mock_run = MagicMock()
        mock_run.run_id = 4343
        mock_ws.jobs.run_now.return_value = mock_run

        resp = client_with_agent.post(f"/api/businesses/{seed_business}/runs", json={
            "intent": "new-base-model",
            "model_size": "small model",  # client sends small — server should ignore
            "catalog": "test_cat",
            "business_context_path": "/Volumes/test/ctx/vibes/ctx.json",
        })
        assert resp.status_code == 200
        assert resp.json()["intent"] == "new-base-model"

    def test_new_base_model_one_catalog_persists_deployment_catalog(
        self, client_with_agent, mock_ws, seed_business
    ):
        """In ``One Catalog`` mode the user-picked target catalog IS the deploy
        target; parameters_json must record it so the run-detail audit trail
        shows where the model lives."""
        mock_run = MagicMock()
        mock_run.run_id = 4747
        mock_ws.jobs.run_now.return_value = mock_run

        resp = client_with_agent.post(f"/api/businesses/{seed_business}/runs", json={
            "intent": "new-base-model",
            "catalog": "user_picked_cat",
            "cataloging_style": "One Catalog",
            "business_context_path": "/Volumes/test/ctx/vibes/ctx.json",
        })
        assert resp.status_code == 200
        stored = json.loads(resp.json()["parameters_json"])
        assert stored.get("deployment_catalog") == "user_picked_cat"
        assert stored.get("cataloging_style") == "One Catalog"

    def test_new_base_model_catalog_per_domain_omits_deployment_catalog(
        self, client_with_agent, mock_ws, seed_business
    ):
        """In ``Catalog per Domain`` mode the agent derives per-domain
        catalogs and ignores the form's catalog field. ``parameters_json``
        must NOT serialise ``deployment_catalog`` to the agent-config
        default — that misleads operators tracing which catalog was
        actually written to."""
        mock_run = MagicMock()
        mock_run.run_id = 4848
        mock_ws.jobs.run_now.return_value = mock_run

        resp = client_with_agent.post(f"/api/businesses/{seed_business}/runs", json={
            "intent": "new-base-model",
            "catalog": "ignored_for_multi_catalog",
            "cataloging_style": "Catalog per Domain",
            "business_context_path": "/Volumes/test/ctx/vibes/ctx.json",
        })
        assert resp.status_code == 200
        stored = json.loads(resp.json()["parameters_json"])
        assert "deployment_catalog" not in stored, (
            f"parameters_json should not carry deployment_catalog in "
            f"multi-catalog mode; got keys={sorted(stored.keys())}"
        )
        assert stored.get("cataloging_style") == "Catalog per Domain"

    def test_new_base_model_catalog_per_division_omits_deployment_catalog(
        self, client_with_agent, mock_ws, seed_business
    ):
        """Same as Catalog per Domain — Catalog per Division is also a
        multi-catalog style where the form's catalog field is ignored."""
        mock_run = MagicMock()
        mock_run.run_id = 4949
        mock_ws.jobs.run_now.return_value = mock_run

        resp = client_with_agent.post(f"/api/businesses/{seed_business}/runs", json={
            "intent": "new-base-model",
            "catalog": "ignored_for_multi_catalog",
            "cataloging_style": "Catalog per Division",
            "business_context_path": "/Volumes/test/ctx/vibes/ctx.json",
        })
        assert resp.status_code == 200
        stored = json.loads(resp.json()["parameters_json"])
        assert "deployment_catalog" not in stored
        assert stored.get("cataloging_style") == "Catalog per Division"


class TestGetRunReadsFromLakebase:
    """GET /runs/{id} reads from Lakebase directly — no Jobs API polling."""

    def test_get_run_returns_stored_status(self, client, seed_running_run):
        """get_run reads from Lakebase, does not call Jobs API."""
        bid, run_id = seed_running_run
        resp = client.get(f"/api/businesses/{bid}/runs/{run_id}")
        assert resp.status_code == 200
        assert resp.json()["status"] == "running"
        # No jobs.get_run should be called

    def test_get_pending_run(self, client, seed_run):
        """Pending runs returned as-is from Lakebase."""
        bid, run_id = seed_run
        resp = client.get(f"/api/businesses/{bid}/runs/{run_id}")
        assert resp.status_code == 200
        assert resp.json()["status"] == "pending"

    def test_run_page_url_present(self, client, mock_ws, seed_running_run):
        """Running run with databricks_run_id gets a run_page_url."""
        bid, run_id = seed_running_run
        resp = client.get(f"/api/businesses/{bid}/runs/{run_id}")
        data = resp.json()
        assert data["run_page_url"] is not None
        assert "test-workspace.databricks.com" in data["run_page_url"]
        assert "12345" in data["run_page_url"]


class TestCancelRun:
    def test_cancel_running_run(self, client, mock_ws, seed_running_run):
        """Cancel a running run."""
        bid, run_id = seed_running_run
        resp = client.post(f"/api/businesses/{bid}/runs/{run_id}/cancel")
        assert resp.status_code == 200
        data = resp.json()
        assert data["status"] == "cancelled"
        assert data["completed_at"] is not None
        mock_ws.jobs.cancel_run.assert_called_once_with(12345)

    def test_cancel_stale_run(self, engine, client, mock_ws, seed_business):
        """Can also cancel a stale run."""
        bid = seed_business
        from sqlmodel import Session
        from vibe_modeling.backend.db_models import Run
        from datetime import datetime, timezone

        with Session(engine) as session:
            run = Run(
                business_id=seed_business,
                intent="new-base-model",
                status="stale",
                databricks_run_id=54321,
                started_at=datetime.now(timezone.utc),
                parameters_json='{}',
            )
            session.add(run)
            session.commit()
            session.refresh(run)
            run_id = run.id

        resp = client.post(f"/api/businesses/{bid}/runs/{run_id}/cancel")
        assert resp.status_code == 200
        assert resp.json()["status"] == "cancelled"

    def test_cancel_pending_run_fails(self, client, seed_run):
        """Cannot cancel a pending run."""
        bid, run_id = seed_run
        resp = client.post(f"/api/businesses/{bid}/runs/{run_id}/cancel")
        assert resp.status_code == 400
        assert "pending" in resp.json()["detail"]

    def test_cancel_nonexistent_run(self, client, seed_business):
        bid = seed_business
        resp = client.post(f"/api/businesses/{bid}/runs/fake/cancel")
        assert resp.status_code == 404

    def test_cancel_sdk_failure_is_best_effort(self, client, mock_ws, seed_running_run):
        """If Databricks SDK cancel fails, the run is still marked cancelled
        (best-effort behaviour) and the endpoint returns 200 with the error
        noted in the progress_message.

        The old contract raised HTTP 500 here; the new atomic helper treats
        Databricks cancel failure as best-effort — the run is cleaned up in
        the DB regardless, and the caller sees a 200 with the error note in
        the progress_message rather than a hard failure.
        """
        bid, run_id = seed_running_run
        mock_ws.jobs.cancel_run.side_effect = Exception("API error")
        resp = client.post(f"/api/businesses/{bid}/runs/{run_id}/cancel")
        # Best-effort: always 200; run is marked cancelled in the DB.
        assert resp.status_code == 200
        data = resp.json()
        assert data["status"] == "cancelled"
        # The helper notes the Databricks cancel failure in the progress message.
        assert "cancel failed" in data.get("progress_message", "").lower() or \
               "cancelled" in data.get("progress_message", "").lower()


class TestRetryRun:
    def test_retry_failed_run(self, client_with_agent, mock_ws, seed_failed_run):
        """Retry a failed run — creates a new job execution with new session ID."""
        bid, run_id = seed_failed_run
        mock_run = MagicMock()
        mock_run.run_id = 99999
        mock_ws.jobs.run_now.return_value = mock_run

        resp = client_with_agent.post(f"/api/businesses/{bid}/runs/{run_id}/retry")
        assert resp.status_code == 200
        data = resp.json()
        assert data["status"] == "running"
        assert data["databricks_run_id"] == 99999
        assert data["error_message"] == ""
        assert data["progress_percent"] == 0
        # New session ID should be generated
        assert data["vibe_session_id"] is not None

    def test_retry_running_run_fails(self, client_with_agent, seed_running_run):
        """Cannot retry a running run."""
        bid, run_id = seed_running_run
        resp = client_with_agent.post(f"/api/businesses/{bid}/runs/{run_id}/retry")
        assert resp.status_code == 400
        assert "running" in resp.json()["detail"]

    def test_retry_without_agent_config(self, client, seed_failed_run):
        """Cannot retry when no AgentConfig exists."""
        bid, run_id = seed_failed_run
        resp = client.post(f"/api/businesses/{bid}/runs/{run_id}/retry")
        assert resp.status_code == 400
        assert "Agent not configured" in resp.json()["detail"]

    def test_retry_nonexistent_run(self, client_with_agent, seed_business):
        bid = seed_business
        resp = client_with_agent.post(f"/api/businesses/{bid}/runs/fake/retry")
        assert resp.status_code == 404

    def test_retry_sdk_failure(self, client_with_agent, mock_ws, seed_failed_run):
        """If Databricks SDK fails on retry, return 500."""
        bid, run_id = seed_failed_run
        mock_ws.jobs.run_now.side_effect = Exception("API error")
        resp = client_with_agent.post(f"/api/businesses/{bid}/runs/{run_id}/retry")
        assert resp.status_code == 500

    def test_retry_orchestrator_run_with_structured_parameters_json(
        self, client_with_agent, mock_ws, engine, seed_business
    ):
        """Regression (0.6.6 walkthrough): retrying an orchestrator-managed
        run whose ``parameters_json`` is a structured audit record (per the
        run-config disclosure work, it may hold lists / booleans / nested
        objects, not a flat string map) must NOT replay that blob straight
        into ``run_now``'s ``notebook_params``. Doing so previously 500'd
        with "Expected Scalar value for String field \"value\"" because
        Databricks Jobs `run_now` requires notebook_params to be a flat
        map of STRING values.

        Retry for a run with persisted ``RunOperation`` rows must go
        through the orchestrator's own re-dispatch (``Operation.dispatch``),
        which rebuilds notebook_params itself (exactly what a fresh
        launch would send) and must leave ``Run.parameters_json``
        untouched (it stays the structured audit record).
        """
        from sqlmodel import Session as _Session
        from vibe_modeling.backend.db_models import Run, RunOperation

        mock_run = MagicMock()
        mock_run.run_id = 424242
        mock_ws.jobs.run_now.return_value = mock_run

        structured_parameters_json = json.dumps({
            "operation": "uninstall model version",
            "intent": "uninstall",
            "input_ids": ["vi-1", "vi-2"],
            "next_vibe_ids": [],
            "nested": {"a": 1},
        })

        with _Session(engine) as session:
            run = Run(
                business_id=seed_business,
                intent="uninstall",
                status="failed",
                error_message="Something went wrong",
                parameters_json=structured_parameters_json,
            )
            session.add(run)
            session.flush()
            run_op = RunOperation(
                run_id=run.id,
                step_index=0,
                operation_name="uninstall",
                status="failed",
                params_json=json.dumps({
                    "business_name": "test_corp",
                    "deployment_catalog": "test_cat",
                    "scope": "ecm",
                    "model_version": 1,
                    "schema_prefix": "ecm_",
                }),
            )
            session.add(run_op)
            session.commit()
            run_id = run.id

        resp = client_with_agent.post(
            f"/api/businesses/{seed_business}/runs/{run_id}/retry"
        )
        assert resp.status_code == 200, resp.text
        data = resp.json()
        assert data["status"] == "running"
        assert data["databricks_run_id"] == 424242

        # The Jobs API call must have received a flat, string-only map,
        # not the structured parameters_json blob.
        mock_ws.jobs.run_now.assert_called_once()
        notebook_params = mock_ws.jobs.run_now.call_args.kwargs["notebook_params"]
        assert notebook_params, "expected non-empty notebook_params"
        for key, value in notebook_params.items():
            assert isinstance(value, str), f"{key!r} was {type(value)!r}, not str"

        # Run.parameters_json is untouched - it stays the structured audit
        # record, not overwritten with the flat dispatch map.
        with _Session(engine) as session:
            refreshed = session.get(Run, run_id)
            assert refreshed.parameters_json == structured_parameters_json

    def test_retry_cancelled_orchestrator_run_relaunches(
        self, client_with_agent, mock_ws, engine, seed_business
    ):
        """Regression: retrying a CANCELLED orchestrator-managed run must
        actually relaunch it, not silently mark it "completed".

        A full cancel-with-rollback leaves every ``RunOperation`` row
        terminal in a status "failed" never reaches ("rolled_back" for ops
        that had succeeded and were unwound, "cancelled" for ops that were
        pending/running when the cancel landed). Before this fix,
        ``Orchestrator.resume()`` only reset ``"failed"`` rows back to
        ``"pending"``, so re-calling it against a cancelled run found no
        row to (re)dispatch and fell through to its "all rows terminal"
        branch, incorrectly finalizing the run as "completed" without ever
        calling ``run_now`` again.
        """
        from sqlmodel import Session as _Session
        from vibe_modeling.backend.db_models import Run, RunOperation

        mock_run = MagicMock()
        mock_run.run_id = 555555
        mock_ws.jobs.run_now.return_value = mock_run

        with _Session(engine) as session:
            run = Run(
                business_id=seed_business,
                intent="uninstall",
                status="cancelled",
                parameters_json=json.dumps({"input_ids": []}),
            )
            session.add(run)
            session.flush()
            run_op = RunOperation(
                run_id=run.id,
                step_index=0,
                operation_name="uninstall",
                status="rolled_back",
                params_json=json.dumps({
                    "business_name": "test_corp",
                    "deployment_catalog": "test_cat",
                    "scope": "ecm",
                    "model_version": 1,
                    "schema_prefix": "ecm_",
                }),
            )
            session.add(run_op)
            session.commit()
            run_id = run.id

        resp = client_with_agent.post(
            f"/api/businesses/{seed_business}/runs/{run_id}/retry"
        )
        assert resp.status_code == 200, resp.text
        data = resp.json()
        assert data["status"] == "running"
        assert data["databricks_run_id"] == 555555
        mock_ws.jobs.run_now.assert_called_once()


class TestRetryStoredWidgetRefresh:
    """Retrying or resuming a run stored by an older app sends today's widget
    shape (A4): the agent's boolean label, the runtime budget, no
    ``generate_samples``. An unknown stored boolean refuses the dispatch with
    no ``run_now`` and no Volume write."""

    @staticmethod
    def _legacy_run(engine, business_id, widgets: dict) -> str:
        """A failed run from the pre-orchestrator path: no RunOperation rows and
        a flat widget map in ``parameters_json``, as a pre-0.9.0 app stored it."""
        from sqlmodel import Session as _Session
        from vibe_modeling.backend.db_models import Run

        with _Session(engine) as session:
            run = Run(
                business_id=business_id,
                intent="new-base-model",
                status="failed",
                error_message="Something went wrong",
                databricks_run_id=12345,
                parameters_json=json.dumps(widgets),
            )
            session.add(run)
            session.commit()
            return run.id

    _PRE_090_WIDGETS = {
        "operation": "new base model",
        "business_name": "test_corp",
        "deployment_catalog": "test_cat",
        "data_model_scopes": "Expanded Coverage Model - ECM",
        "generate_samples": "10",
        "model_vibes": "",
        "boolean_format": "Integer (1/0)",
        "date_format": "yyyy-MM-dd",
    }

    def test_legacy_retry_sends_the_current_widget_shape(
        self, client_with_agent, mock_ws, engine, seed_business
    ):
        mock_run = MagicMock()
        mock_run.run_id = 777
        mock_ws.jobs.run_now.return_value = mock_run
        run_id = self._legacy_run(engine, seed_business, self._PRE_090_WIDGETS)

        resp = client_with_agent.post(f"/api/businesses/{seed_business}/runs/{run_id}/retry")
        assert resp.status_code == 200, resp.text

        sent = mock_ws.jobs.run_now.call_args.kwargs["notebook_params"]
        assert sent["boolean_format"] == "Int (0/1)"
        # Stored before the setting existed: the current Settings default, 6 h.
        assert sent["runtime_budget_seconds"] == "21600"
        assert "generate_samples" not in sent
        assert sent["date_format"] == "yyyy-MM-dd"
        stored = json.loads(resp.json()["parameters_json"])
        assert stored["boolean_format"] == "Int (0/1)"
        assert "generate_samples" not in stored

    def test_legacy_retry_with_unknown_boolean_is_refused(
        self, client_with_agent, mock_ws, engine, seed_business
    ):
        from sqlmodel import Session as _Session
        from vibe_modeling.backend.db_models import Run

        widgets = {**self._PRE_090_WIDGETS, "boolean_format": "Maybe"}
        run_id = self._legacy_run(engine, seed_business, widgets)

        resp = client_with_agent.post(f"/api/businesses/{seed_business}/runs/{run_id}/retry")
        assert resp.status_code == 422, resp.text
        assert "boolean_format" in resp.json()["detail"]
        mock_ws.jobs.run_now.assert_not_called()
        mock_ws.files.upload.assert_not_called()
        with _Session(engine) as session:
            run = session.get(Run, run_id)
            assert run.status == "failed"
            assert run.databricks_run_id == 12345
            assert json.loads(run.parameters_json) == widgets

    @pytest.mark.parametrize("route", ["retry", "resume"])
    def test_orchestrator_run_with_unknown_boolean_fails_without_dispatch(
        self, client_with_agent, mock_ws, engine, seed_business, route
    ):
        from sqlmodel import Session as _Session, select
        from vibe_modeling.backend.db_models import Run, RunOperation

        # Long vibes would be written to a Volume if the dispatch got that far.
        with _Session(engine) as session:
            run = Run(
                business_id=seed_business,
                intent="new-base-model",
                status="failed",
                error_message="Something went wrong",
                parameters_json=json.dumps({"intent": "new-base-model"}),
            )
            session.add(run)
            session.flush()
            session.add(RunOperation(
                run_id=run.id,
                step_index=0,
                operation_name="generate_ecm",
                status="failed",
                params_json=json.dumps({
                    "business_name": "test_corp",
                    "deployment_catalog": "test_cat",
                    "schema_prefix": "ecm_",
                    "cataloging_style": "One Catalog",
                    "model_vibes": "x" * 5000,
                    "boolean_format": "Maybe",
                }),
            ))
            session.commit()
            run_id = run.id

        resp = client_with_agent.post(f"/api/businesses/{seed_business}/runs/{run_id}/{route}")
        assert resp.status_code == 200, resp.text

        mock_ws.jobs.run_now.assert_not_called()
        mock_ws.files.upload.assert_not_called()
        with _Session(engine) as session:
            run = session.get(Run, run_id)
            op = session.exec(select(RunOperation).where(RunOperation.run_id == run_id)).one()
            assert run.status == "failed"
            assert "boolean_format" in (run.error_message or "")
            assert op.status == "failed"
            assert op.dispatched_widgets_json in (None, "", "{}")
