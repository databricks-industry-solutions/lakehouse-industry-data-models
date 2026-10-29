"""The agent's run time budget: Settings default, per-run override, dispatch.

Create resolves the run's hours once (its override, else the Settings default
at that moment) and stores them in ``Run.parameters_json``; every agent job of
the run, and every retry or resume, sends ``runtime_budget_seconds`` from that
stored value. Runs created before the setting have no stored value and use
the current Settings default. Lifecycle ops (install, uninstall, rollback)
send no budget. ``runtime_budget_hours`` itself never reaches the agent.
"""
from __future__ import annotations

import json
from types import SimpleNamespace
from unittest.mock import MagicMock

import pytest
from sqlmodel import Session, select

from vibe_modeling.backend.db_models import AgentConfig, ModelVersion, Run, RunOperation
from vibe_modeling.backend.runtime_budget import (
    RUNTIME_BUDGET_DEFAULT_HOURS,
    RUNTIME_BUDGET_MAX_HOURS,
    RUNTIME_BUDGET_MIN_HOURS,
    resolve_runtime_budget_hours,
    runtime_budget_seconds,
    settings_runtime_budget_hours,
    stored_runtime_budget_hours,
)


def _mock_run_now(mock_ws, run_id: int = 5555):
    mock_run = MagicMock()
    mock_run.run_id = run_id
    mock_ws.jobs.run_now.return_value = mock_run


def _sent(mock_ws) -> list[dict]:
    """Every ``notebook_params`` map handed to ``run_now``, in order."""
    return [c.kwargs.get("notebook_params", {}) for c in mock_ws.jobs.run_now.call_args_list]


def _stored(engine, run_id: str) -> dict:
    with Session(engine) as session:
        return json.loads(session.get(Run, run_id).parameters_json or "{}")


def _assert_orchestrated(engine, run_id: str) -> None:
    """The run went through the orchestrator (it has op rows), not the legacy path."""
    with Session(engine) as session:
        assert session.exec(select(RunOperation).where(RunOperation.run_id == run_id)).all()


def _set_settings_hours(engine, hours: int) -> None:
    with Session(engine) as session:
        cfg = session.exec(select(AgentConfig)).one()
        cfg.runtime_budget_hours = hours
        session.add(cfg)
        session.commit()


# --------------------------------------------------------------------------- #
# The helpers
# --------------------------------------------------------------------------- #


def test_bounds_and_default():
    assert (RUNTIME_BUDGET_MIN_HOURS, RUNTIME_BUDGET_DEFAULT_HOURS, RUNTIME_BUDGET_MAX_HOURS) == (4, 6, 48)
    assert AgentConfig().runtime_budget_hours == RUNTIME_BUDGET_DEFAULT_HOURS


def test_resolve_prefers_the_override_then_settings():
    cfg = SimpleNamespace(runtime_budget_hours=9)
    assert resolve_runtime_budget_hours(12, cfg) == 12
    assert resolve_runtime_budget_hours(None, cfg) == 9
    assert resolve_runtime_budget_hours(None, None) == RUNTIME_BUDGET_DEFAULT_HOURS
    assert settings_runtime_budget_hours(None) == RUNTIME_BUDGET_DEFAULT_HOURS


@pytest.mark.parametrize("stored,expected", [
    ({"runtime_budget_hours": 10}, 10),
    # Not re-checked against today's bounds: an older run never fails on them.
    ({"runtime_budget_hours": 60}, 60),
    ({}, 9),
    (None, 9),
    ({"runtime_budget_hours": None}, 9),
    ({"runtime_budget_hours": True}, 9),
    ({"runtime_budget_hours": "10"}, 9),
    ({"runtime_budget_hours": 0}, 9),
])
def test_stored_hours_fall_back_to_the_settings_default(stored, expected):
    assert stored_runtime_budget_hours(stored, SimpleNamespace(runtime_budget_hours=9)) == expected


def test_seconds():
    assert runtime_budget_seconds(6) == 21600


# --------------------------------------------------------------------------- #
# Settings: GET / PUT /config/agent
# --------------------------------------------------------------------------- #


class TestSettings:
    @pytest.fixture
    def put(self, client, mock_ws):
        mock_job = MagicMock()
        mock_job.job_id = 42
        mock_ws.jobs.create.return_value = mock_job

        def _put(**extra):
            return client.put("/api/config/agent", json={
                "notebook_path": "/Workspace/my/notebook", "max_concurrent_runs": 3, **extra,
            })
        return _put

    def test_get_reads_the_default_and_the_bounds(self, client):
        resp = client.get("/api/config/agent")
        assert resp.status_code == 200
        body = resp.json()
        assert body["runtime_budget_hours"] == 6
        assert body["runtime_budget_min_hours"] == 4
        assert body["runtime_budget_max_hours"] == 48

    @pytest.mark.parametrize("hours", [4, 10, 48])
    def test_put_saves_a_value_in_range(self, put, client, hours):
        resp = put(runtime_budget_hours=hours)
        assert resp.status_code == 200, resp.text
        assert resp.json()["runtime_budget_hours"] == hours
        resp = client.get("/api/config/agent")
        assert resp.status_code == 200
        assert resp.json()["runtime_budget_hours"] == hours

    def test_put_without_the_field_keeps_the_stored_value(self, put, client):
        """A PUT may send only the fields it changes (the API allows it); the
        stored budget must survive one that leaves the budget out."""
        assert put(runtime_budget_hours=12).status_code == 200
        resp = put()
        assert resp.status_code == 200
        assert resp.json()["runtime_budget_hours"] == 12
        resp = put(runtime_budget_hours=None)
        assert resp.status_code == 200
        assert resp.json()["runtime_budget_hours"] == 12

    @pytest.mark.parametrize("hours", [3, 49, 0, -1])
    def test_put_out_of_range_is_422_and_writes_nothing(self, put, client, engine, hours):
        assert put(runtime_budget_hours=8).status_code == 200
        resp = put(runtime_budget_hours=hours)
        assert resp.status_code == 422
        assert "runtime_budget_hours" in resp.text
        with Session(engine) as session:
            assert session.exec(select(AgentConfig)).one().runtime_budget_hours == 8

    def test_put_fractional_hours_is_422(self, put):
        assert put(runtime_budget_hours=4.5).status_code == 422

    @pytest.mark.parametrize("role", ["MODELER", "VIEWER"])
    def test_non_admin_put_is_403_and_writes_nothing(self, client, engine, role):
        from vibe_modeling.backend.core._roles import UserRole, resolve_user_role

        client.app.dependency_overrides[resolve_user_role] = lambda: UserRole[role]
        try:
            resp = client.put(
                "/api/config/agent", json={"notebook_path": "/x", "runtime_budget_hours": 10},
            )
        finally:
            client.app.dependency_overrides.pop(resolve_user_role, None)
        assert resp.status_code == 403
        with Session(engine) as session:
            assert all(c.runtime_budget_hours == 6 for c in session.exec(select(AgentConfig)).all())


# --------------------------------------------------------------------------- #
# RunIn bounds: validate == create
# --------------------------------------------------------------------------- #


class TestRunInBounds:
    @pytest.mark.parametrize("hours", [3, 49])
    @pytest.mark.parametrize("path", ["runs", "runs/validate"])
    def test_out_of_range_is_422(self, client_with_agent, mock_ws, engine, seed_business, hours, path):
        _mock_run_now(mock_ws)
        resp = client_with_agent.post(
            f"/api/businesses/{seed_business}/{path}",
            json={"intent": "new-base-model", "catalog": "test_catalog", "runtime_budget_hours": hours},
        )
        assert resp.status_code == 422
        assert "runtime_budget_hours" in resp.text
        mock_ws.jobs.run_now.assert_not_called()
        with Session(engine) as session:
            assert session.exec(select(Run)).all() == []

    @pytest.mark.parametrize("extra", [{"runtime_budget_hours": 4}, {}])
    def test_in_range_or_absent_validates(self, client_with_agent, seed_business, extra):
        resp = client_with_agent.post(
            f"/api/businesses/{seed_business}/runs/validate",
            json={"intent": "new-base-model", "catalog": "test_catalog", **extra},
        )
        assert resp.status_code == 200, resp.text


# --------------------------------------------------------------------------- #
# Create stores the resolved hours; dispatch sends their seconds
# --------------------------------------------------------------------------- #


class TestCreateStoresAndDispatches:
    @pytest.mark.parametrize("extra,hours", [({"runtime_budget_hours": 10}, 10), ({}, 7)])
    def test_new_base_model(self, client_with_agent, mock_ws, engine, seed_business, extra, hours):
        _set_settings_hours(engine, 7)
        _mock_run_now(mock_ws)
        resp = client_with_agent.post(
            f"/api/businesses/{seed_business}/runs",
            json={"intent": "new-base-model", "catalog": "test_catalog", **extra},
        )
        assert resp.status_code == 200, resp.text
        _assert_orchestrated(engine, resp.json()["id"])
        assert _stored(engine, resp.json()["id"])["runtime_budget_hours"] == hours
        sent = _sent(mock_ws)[-1]
        assert sent["runtime_budget_seconds"] == str(hours * 3600)
        assert "runtime_budget_hours" not in sent

    @pytest.mark.parametrize("extra,hours", [({"runtime_budget_hours": 10}, 10), ({}, 7)])
    def test_vibe_iterate(self, client_with_agent, mock_ws, engine, seed_business_with_version, extra, hours):
        _set_settings_hours(engine, 7)
        _mock_run_now(mock_ws)
        resp = client_with_agent.post(
            f"/api/businesses/{seed_business_with_version}/runs",
            json={"intent": "vibe-iterate", "catalog": "test_catalog",
                  "vibe_instructions": "merge customer and account tables", **extra},
        )
        assert resp.status_code == 200, resp.text
        _assert_orchestrated(engine, resp.json()["id"])
        assert _stored(engine, resp.json()["id"])["runtime_budget_hours"] == hours
        sent = _sent(mock_ws)[-1]
        assert sent["runtime_budget_seconds"] == str(hours * 3600)
        assert "runtime_budget_hours" not in sent

    def test_vibe_new_ecm_mvm(self, client_with_agent, mock_ws, engine, seed_business_with_version):
        bid = seed_business_with_version
        with Session(engine) as session:
            mv_id = session.exec(select(ModelVersion)).one().id
        resp = client_with_agent.post(
            f"/api/businesses/{bid}/inputs",
            json={"text": "Add a loyalty domain", "version_id": mv_id},
            headers={"X-Forwarded-Email": "flow@x.com"},
        )
        assert resp.status_code == 200, resp.text
        _mock_run_now(mock_ws)
        resp = client_with_agent.post(
            f"/api/businesses/{bid}/runs",
            json={"intent": "vibe-new-ecm-mvm", "parent_version_id": mv_id, "catalog": "test_catalog",
                  "input_ids": [resp.json()["id"]], "runtime_budget_hours": 11},
        )
        assert resp.status_code == 200, resp.text
        _assert_orchestrated(engine, resp.json()["id"])
        assert _stored(engine, resp.json()["id"])["runtime_budget_hours"] == 11
        sent = _sent(mock_ws)[-1]
        assert sent["runtime_budget_seconds"] == str(11 * 3600)
        assert "runtime_budget_hours" not in sent

    def test_install_stores_no_budget(self, client_with_agent, mock_ws, engine, seed_business_with_version):
        _mock_run_now(mock_ws)
        resp = client_with_agent.post(
            f"/api/businesses/{seed_business_with_version}/runs",
            json={"intent": "install", "catalog": "test_catalog", "runtime_budget_hours": 10},
        )
        assert resp.status_code == 200, resp.text
        _assert_orchestrated(engine, resp.json()["id"])
        assert "runtime_budget_hours" not in _stored(engine, resp.json()["id"])
        for sent in _sent(mock_ws):
            assert "runtime_budget_seconds" not in sent
            assert "runtime_budget_hours" not in sent


# --------------------------------------------------------------------------- #
# Retry and resume keep the stored hours on every step
# --------------------------------------------------------------------------- #


def _second_step_failed(engine, run_id: str) -> None:
    """Step 0 (generate ECM) succeeded with a version; step 1 (shrink) failed
    before it launched; the run failed."""
    with Session(engine) as session:
        run = session.get(Run, run_id)
        rows = session.exec(
            select(RunOperation).where(RunOperation.run_id == run_id).order_by(RunOperation.step_index)
        ).all()
        assert [r.operation_name for r in rows] == ["generate_ecm", "shrink_to_mvm"]
        mv = ModelVersion(business_id=run.business_id, version=1, status="completed", scope="ecm")
        session.add(mv)
        session.flush()
        rows[0].status = "succeeded"
        rows[0].output_version_id = mv.id
        rows[1].status = "failed"
        rows[1].databricks_run_id = None
        run.status = "failed"
        session.add_all([run, *rows])
        session.commit()


class TestRetryAndResumeKeepTheRunsHours:
    @pytest.mark.parametrize("route", ["retry", "resume"])
    def test_shrink_step_keeps_the_stored_hours_after_settings_change(
        self, client_with_agent, mock_ws, engine, seed_business, route
    ):
        _mock_run_now(mock_ws)
        resp = client_with_agent.post(
            f"/api/businesses/{seed_business}/runs",
            json={"intent": "new-base-model", "catalog": "test_catalog", "runtime_budget_hours": 10},
        )
        assert resp.status_code == 200, resp.text
        run_id = resp.json()["id"]
        assert _sent(mock_ws)[-1]["operation"] == "new base model"
        assert _sent(mock_ws)[-1]["runtime_budget_seconds"] == "36000"

        _second_step_failed(engine, run_id)
        _set_settings_hours(engine, 20)
        resp = client_with_agent.post(f"/api/businesses/{seed_business}/runs/{run_id}/{route}")
        assert resp.status_code == 200, resp.text
        shrink = _sent(mock_ws)[-1]
        assert shrink["operation"] == "shrink ecm"
        assert shrink["runtime_budget_seconds"] == "36000"
        assert "runtime_budget_hours" not in shrink

    def test_a_run_created_before_the_setting_uses_the_current_default(
        self, client_with_agent, mock_ws, engine, seed_business
    ):
        _mock_run_now(mock_ws)
        resp = client_with_agent.post(
            f"/api/businesses/{seed_business}/runs",
            json={"intent": "new-base-model", "catalog": "test_catalog"},
        )
        assert resp.status_code == 200, resp.text
        run_id = resp.json()["id"]
        with Session(engine) as session:
            run = session.get(Run, run_id)
            params = json.loads(run.parameters_json)
            del params["runtime_budget_hours"]
            run.parameters_json = json.dumps(params)
            session.add(run)
            session.commit()
        _second_step_failed(engine, run_id)
        _set_settings_hours(engine, 9)
        resp = client_with_agent.post(f"/api/businesses/{seed_business}/runs/{run_id}/retry")
        assert resp.status_code == 200, resp.text
        assert _sent(mock_ws)[-1]["runtime_budget_seconds"] == str(9 * 3600)


# --------------------------------------------------------------------------- #
# The legacy single-job path
# --------------------------------------------------------------------------- #


def _legacy_failed_run(engine, business_id: str, params: dict) -> str:
    with Session(engine) as session:
        run = Run(business_id=business_id, intent="new-base-model", status="failed",
                  error_message="boom", databricks_run_id=12345, parameters_json=json.dumps(params))
        session.add(run)
        session.commit()
        return run.id


_LEGACY_WIDGETS = {
    "operation": "new base model", "business_name": "test_corp", "deployment_catalog": "test_cat",
    "data_model_scopes": "Expanded Coverage Model - ECM", "model_vibes": "",
}


class TestLegacyPath:
    def test_retry_sends_the_stored_hours_as_seconds_and_keeps_them(
        self, client_with_agent, mock_ws, engine, seed_business
    ):
        _mock_run_now(mock_ws)
        run_id = _legacy_failed_run(engine, seed_business, {
            **_LEGACY_WIDGETS, "runtime_budget_seconds": "36000", "runtime_budget_hours": 10,
        })
        _set_settings_hours(engine, 20)
        resp = client_with_agent.post(f"/api/businesses/{seed_business}/runs/{run_id}/retry")
        assert resp.status_code == 200, resp.text
        sent = _sent(mock_ws)[-1]
        assert sent["runtime_budget_seconds"] == "36000"
        assert "runtime_budget_hours" not in sent
        assert _stored(engine, run_id)["runtime_budget_hours"] == 10

    @pytest.mark.parametrize("stored_seconds", [{"runtime_budget_seconds": "14400"}, {}])
    def test_retry_of_a_run_created_before_the_setting_uses_the_current_default(
        self, client_with_agent, mock_ws, engine, seed_business, stored_seconds
    ):
        _mock_run_now(mock_ws)
        run_id = _legacy_failed_run(engine, seed_business, {**_LEGACY_WIDGETS, **stored_seconds})
        _set_settings_hours(engine, 9)
        resp = client_with_agent.post(f"/api/businesses/{seed_business}/runs/{run_id}/retry")
        assert resp.status_code == 200, resp.text
        assert _sent(mock_ws)[-1]["runtime_budget_seconds"] == str(9 * 3600)
        assert _stored(engine, run_id)["runtime_budget_hours"] == 9

    def test_legacy_create_stores_the_hours_next_to_the_widgets(
        self, client_with_agent, mock_ws, engine, seed_business_with_version, monkeypatch
    ):
        """A vibe-iterate whose intent has no registered orchestrator op goes
        down the legacy single-job path; its stored map carries the seconds it
        sent and the hours, which the retry replays as seconds only."""
        from vibe_modeling.backend.services.orchestrator import preflight as preflight_mod

        monkeypatch.setattr(preflight_mod, "_orchestrator_intent_registered", lambda intent: False)
        _mock_run_now(mock_ws)
        resp = client_with_agent.post(
            f"/api/businesses/{seed_business_with_version}/runs",
            json={"intent": "vibe-iterate", "catalog": "test_catalog",
                  "vibe_instructions": "merge customer and account tables", "runtime_budget_hours": 5},
        )
        assert resp.status_code == 200, resp.text
        run_id = resp.json()["id"]
        with Session(engine) as session:
            assert session.exec(select(RunOperation).where(RunOperation.run_id == run_id)).all() == []
        stored = _stored(engine, run_id)
        assert stored["runtime_budget_hours"] == 5
        assert stored["runtime_budget_seconds"] == "18000"
        sent = _sent(mock_ws)[-1]
        assert sent["runtime_budget_seconds"] == "18000"
        assert "runtime_budget_hours" not in sent


    @pytest.mark.parametrize("intent", ["install", "uninstall"])
    def test_legacy_lifecycle_create_stores_no_hours(
        self, client_with_agent, mock_ws, engine, seed_business_with_version, monkeypatch, intent
    ):
        """Install and uninstall runs on the legacy path store no budget hours
        (their map still carries the seconds build_widget_map always sends,
        which the agent never reads there), and a retry adds none."""
        from vibe_modeling.backend.services.orchestrator import preflight as preflight_mod

        monkeypatch.setattr(preflight_mod, "_orchestrator_intent_registered", lambda intent: False)
        monkeypatch.setattr(preflight_mod, "_raise_needs_confirmation", lambda *a, **k: None)
        _mock_run_now(mock_ws)
        resp = client_with_agent.post(
            f"/api/businesses/{seed_business_with_version}/runs",
            json={"intent": intent, "catalog": "test_catalog", "runtime_budget_hours": 10},
        )
        assert resp.status_code == 200, resp.text
        run_id = resp.json()["id"]
        assert "runtime_budget_hours" not in _stored(engine, run_id)
        with Session(engine) as session:
            assert session.exec(select(RunOperation).where(RunOperation.run_id == run_id)).all() == []
            run = session.get(Run, run_id)
            run.status = "failed"
            session.add(run)
            session.commit()
        resp = client_with_agent.post(f"/api/businesses/{seed_business_with_version}/runs/{run_id}/retry")
        assert resp.status_code == 200, resp.text
        assert "runtime_budget_hours" not in _stored(engine, run_id)
        assert "runtime_budget_hours" not in _sent(mock_ws)[-1]


# --------------------------------------------------------------------------- #
# Lifecycle ops send no budget
# --------------------------------------------------------------------------- #


def test_lifecycle_primitives_do_not_build_the_generation_widget_map():
    """Install, uninstall, samples and the rollback uninstall build their own
    maps, which carry no budget (the agent never reads it there)."""
    import inspect

    from vibe_modeling.backend.services.operations import (
        _generation_common,
        generate_samples,
        install,
        uninstall,
    )

    for module in (install, uninstall, generate_samples):
        src = inspect.getsource(module)
        assert "runtime_budget" not in src, module.__name__
        assert "build_widget_map" not in src and "map_run_params_to_widgets(" not in src, module.__name__
    assert "runtime_budget" not in inspect.getsource(_generation_common.rollback_generation_op)
