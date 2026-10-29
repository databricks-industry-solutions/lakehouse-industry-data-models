"""The app upgrades its own agent notebook on boot; Settings can switch an
admin-owned notebook to the bundled one; the Settings card reports the
configured notebook's identity.

Covers ``core/_bundled_agent_init`` (app-owned upgrade, admin-owned left
alone, the in-flight skip, the time budget, an atomic path + job change),
``POST /admin/agent/switch-to-bundled`` and the identity fields of
``GET /config/agent-compat``. The workspace and Jobs API are mocks.
"""

from __future__ import annotations

import asyncio
import logging
import threading
import time
from types import SimpleNamespace
from unittest.mock import MagicMock

import pytest
from _test_app import make_test_app
from fastapi.testclient import TestClient
from sqlalchemy.pool import StaticPool
from sqlmodel import Session, SQLModel, create_engine, select

from vibe_modeling.backend import bundled_agent, bundled_agent_install, job_launcher
from vibe_modeling.backend.bundled_agent import BundledAgent
from vibe_modeling.backend.core import _app_identity, _bundled_agent_init as boot
from vibe_modeling.backend.core._config import AppConfig
from vibe_modeling.backend.core._defaults import _ConfigDependency, _WorkspaceClientDependency
from vibe_modeling.backend.core._roles import UserRole, resolve_user_role
from vibe_modeling.backend.core.lakebase import _LakebaseDependency
from vibe_modeling.backend.db_models import AgentConfig, Business, Run
from vibe_modeling.backend.routes import _helpers
from vibe_modeling.backend.routes import config as config_routes
from vibe_modeling.backend.routes import platform as platform_routes

SP = "app-sp-id"
FOLDER = f"/Users/{SP}/vibe-modelling-agent"
OLD_PATH = f"{FOLDER}/vibe_modelling_agent_v4.9.9.ipynb"
NEW_PATH = f"{FOLDER}/vibe_modelling_agent_v5.3.3.ipynb"
CUSTOM_PATH = "/Users/admin@corp.example/agents/vibe_modelling_agent_v4.9.9.ipynb"


@pytest.fixture
def engine():
    eng = create_engine("sqlite://", connect_args={"check_same_thread": False}, poolclass=StaticPool)
    SQLModel.metadata.create_all(eng)
    return eng


@pytest.fixture
def agent(tmp_path, monkeypatch):
    """The bundled agent is 0.8.0 / 5.3.3, a local file; both resolvers see it."""
    nb = tmp_path / "vibe_modelling_agent_v5.3.3.ipynb"
    nb.write_bytes(b"{}")
    bundled = BundledAgent(
        file_path=nb, file_name=nb.name, pinned_tag="v0.8.0",
        supported_tags=["v0.8.0"], agent_version="5.3.3",
    )
    monkeypatch.setattr(bundled_agent, "resolve_bundled_agent", lambda: bundled)
    monkeypatch.setattr(bundled_agent_install, "resolve_bundled_agent", lambda: bundled)
    monkeypatch.setattr(config_routes, "resolve_bundled_agent", lambda: bundled)
    return bundled


@pytest.fixture
def ws():
    w = MagicMock()
    w.current_user.me.return_value.user_name = SP
    w.workspace.get_status.side_effect = Exception("not found")
    return w


@pytest.fixture
def job(monkeypatch, ws):
    """``setup_agent_job`` against a fake Jobs store (``job.notebooks``: job id ->
    notebook path), also readable through ``ws.jobs.get``. A reset keeps the
    job id; a create (no job id) makes job 777. ``job.before`` runs first and
    ``job.fail_after_apply`` raises after the store changed."""
    notebooks: dict[int, str] = {42: OLD_PATH}
    state = {"before": None, "after": None, "fail_after_apply": None}

    def setup(_ws, cfg):
        if state["before"] is not None:
            state["before"]()
        job_id = cfg.job_id or 777
        notebooks[job_id] = cfg.notebook_path
        if state["after"] is not None:
            after, state["after"] = state["after"], None
            after()
        if state["fail_after_apply"] is not None:
            raise state["fail_after_apply"]
        return job_id

    def get(job_id):
        if job_id not in notebooks:
            raise RuntimeError("no such job")
        return SimpleNamespace(settings=SimpleNamespace(tasks=[
            SimpleNamespace(notebook_task=SimpleNamespace(notebook_path=notebooks[job_id]))
        ]))

    mock = MagicMock(side_effect=setup)
    mock.notebooks = notebooks
    mock.state = state
    ws.jobs.get.side_effect = get
    monkeypatch.setattr(job_launcher, "setup_agent_job", mock)
    monkeypatch.setattr(config_routes, "setup_agent_job", mock)
    return mock


@pytest.fixture
def installed(monkeypatch):
    """What the configured notebook declares, per path; a path missing from the map fails to export."""
    identities: dict[str, tuple] = {OLD_PATH: ("v0.8.0", "v4.9.9"), CUSTOM_PATH: ("v0.8.0", "v4.9.9")}

    def detect(_ws, path):
        if path not in identities:
            raise RuntimeError(f"cannot export {path}")
        return identities[path]

    monkeypatch.setattr(_helpers, "_detect_notebook_identity", detect)
    return identities


@pytest.fixture(autouse=True)
def _app_id_cache():
    _app_identity._APP_ID_CACHE.clear()
    yield
    _app_identity._APP_ID_CACHE.clear()


def _seed(engine, path: str, job_id: int | None = 42) -> None:
    with Session(engine) as s:
        s.add(AgentConfig(notebook_path=path, job_id=job_id))
        s.commit()


def _stored(engine) -> AgentConfig:
    with Session(engine) as s:
        return s.exec(select(AgentConfig)).one()


def _active_run(engine, status: str = "running") -> None:
    with Session(engine) as s:
        b = Business(name="B")
        s.add(b)
        s.commit()
        s.add(Run(business_id=b.id, status=status))
        s.commit()


def _boot(engine, ws) -> None:
    with Session(engine, expire_on_commit=False) as s:
        boot._ensure_bundled_agent_installed(s, ws, AppConfig())


# --- boot ----------------------------------------------------------------------


def test_app_owned_older_notebook_is_upgraded(engine, ws, agent, job, installed, caplog):
    _seed(engine, OLD_PATH)
    with caplog.at_level(logging.INFO):
        _boot(engine, ws)
    cfg = _stored(engine)
    assert cfg.notebook_path == NEW_PATH
    assert cfg.job_id == 42 and job.notebooks[42] == NEW_PATH
    job.assert_called_once()
    assert job.call_args.args[1].notebook_path == NEW_PATH
    assert (cfg.installed_release_version, cfg.installed_agent_version) == ("v0.8.0", "5.3.3")
    assert cfg.installed_checked_path == NEW_PATH
    assert any("upgraded 4.9.9 -> 5.3.3 at " + NEW_PATH in r.getMessage() for r in caplog.records)


def test_app_owned_notebook_with_unreadable_identity_is_upgraded(engine, ws, agent, job, installed):
    installed.pop(OLD_PATH)
    _seed(engine, OLD_PATH)
    _boot(engine, ws)
    assert _stored(engine).notebook_path == NEW_PATH


@pytest.mark.parametrize("declared", [("v0.8.0", "v5.3.3"), ("v0.8.0", "v5.4.0"), ("v0.9.0", "v1.0.0")])
def test_app_owned_notebook_not_older_is_left_alone(engine, ws, agent, job, installed, declared):
    installed[OLD_PATH] = declared
    _seed(engine, OLD_PATH)
    _boot(engine, ws)
    assert _stored(engine).notebook_path == OLD_PATH
    ws.workspace.upload.assert_not_called()
    job.assert_not_called()


@pytest.mark.parametrize("path", [CUSTOM_PATH, f"/Users/{SP}/vibe-modelling-agent-mine/nb.ipynb"])
def test_admin_owned_notebook_is_never_overwritten(engine, ws, agent, job, installed, path):
    _seed(engine, path)
    _boot(engine, ws)
    assert _stored(engine).notebook_path == path
    assert _stored(engine).job_id == 42
    ws.workspace.upload.assert_not_called()
    job.assert_not_called()


@pytest.mark.parametrize("status", ["pending", "running", "stale"])
def test_upgrade_skips_while_a_run_is_in_flight(engine, ws, agent, job, installed, caplog, status):
    _seed(engine, OLD_PATH)
    _active_run(engine, status)
    with caplog.at_level(logging.WARNING):
        _boot(engine, ws)
    assert _stored(engine).notebook_path == OLD_PATH
    ws.workspace.upload.assert_not_called()
    job.assert_not_called()
    assert any("upgrade skipped: 1 run(s) in flight" in r.getMessage() for r in caplog.records)


def test_upgrade_runs_once_the_run_has_ended(engine, ws, agent, job, installed):
    _seed(engine, OLD_PATH)
    _active_run(engine, "completed")
    _boot(engine, ws)
    assert _stored(engine).notebook_path == NEW_PATH


def test_a_job_failure_keeps_the_old_path_and_job(engine, ws, agent, job, installed):
    _seed(engine, OLD_PATH)
    job.side_effect = RuntimeError("jobs api down")
    with pytest.raises(boot.AgentJobSetupError, match="jobs api down"):
        _boot(engine, ws)
    cfg = _stored(engine)
    assert (cfg.notebook_path, cfg.job_id) == (OLD_PATH, 42)


def test_a_reset_that_applied_then_failed_is_pointed_back(engine, ws, agent, job, installed):
    _seed(engine, OLD_PATH)
    job.state["fail_after_apply"] = TimeoutError("reset timed out")
    with pytest.raises(boot.AgentJobSetupError, match="reset timed out"):
        _boot(engine, ws)
    assert _stored(engine).notebook_path == OLD_PATH
    assert job.notebooks[42] == OLD_PATH


def test_a_failed_save_after_the_reset_points_the_job_back(engine, ws, agent, job, installed):
    _seed(engine, OLD_PATH)

    class FlakySession(Session):
        fail_next = False

        def commit(self):
            if FlakySession.fail_next:
                FlakySession.fail_next = False
                raise RuntimeError("connection lost")
            return super().commit()

    def arm():
        FlakySession.fail_next = True

    with FlakySession(engine, expire_on_commit=False) as s:
        cfg = s.exec(select(AgentConfig)).one()
        job.state["before"] = arm
        with pytest.raises(RuntimeError, match="connection lost"):
            boot.point_agent_at_bundled(s, ws, cfg, expected_path=OLD_PATH)
    assert _stored(engine).notebook_path == OLD_PATH
    assert job.notebooks[42] == OLD_PATH


def _settings_save(engine, path: str) -> None:
    with Session(engine) as s:
        row = s.exec(select(AgentConfig)).one()
        row.notebook_path = path
        s.add(row)
        s.commit()


def test_a_settings_save_during_the_upload_wins(engine, ws, agent, job, installed, caplog):
    _seed(engine, OLD_PATH)
    ws.workspace.upload.side_effect = lambda **_kw: _settings_save(engine, CUSTOM_PATH)
    with pytest.raises(boot.AgentChangeAborted, match="changed to " + CUSTOM_PATH):
        _boot(engine, ws)
    assert _stored(engine).notebook_path == CUSTOM_PATH
    job.assert_not_called()


def test_a_settings_save_during_the_job_reset_wins(engine, ws, agent, job, installed):
    _seed(engine, OLD_PATH)
    job.state["before"] = lambda: _settings_save(engine, CUSTOM_PATH)
    with pytest.raises(boot.AgentChangeAborted, match="changed meanwhile"):
        _boot(engine, ws)
    assert _stored(engine).notebook_path == CUSTOM_PATH
    assert job.notebooks[42] == CUSTOM_PATH


def test_a_run_started_during_the_upload_is_not_moved(engine, ws, agent, job, installed):
    _seed(engine, OLD_PATH)
    ws.workspace.upload.side_effect = lambda **_kw: _active_run(engine, "pending")
    with pytest.raises(boot.AgentChangeAborted, match="1 run\\(s\\) in flight"):
        _boot(engine, ws)
    assert _stored(engine).notebook_path == OLD_PATH
    job.assert_not_called()
    assert job.notebooks[42] == OLD_PATH


def test_a_passed_deadline_moves_nothing(engine, ws, agent, job, installed):
    _seed(engine, OLD_PATH)
    with Session(engine, expire_on_commit=False) as s:
        with pytest.raises(boot.AgentChangeAborted, match="time budget"):
            boot._ensure_bundled_agent_installed(s, ws, AppConfig(), deadline=time.monotonic() - 1)
    assert _stored(engine).notebook_path == OLD_PATH
    ws.workspace.upload.assert_not_called()
    job.assert_not_called()


def test_a_reset_that_runs_past_the_deadline_moves_nothing(engine, ws, agent, job, installed):
    _seed(engine, OLD_PATH)
    deadline = time.monotonic() + 0.2
    job.state["before"] = lambda: time.sleep(0.3)
    with Session(engine, expire_on_commit=False) as s:
        with pytest.raises(boot.AgentChangeAborted, match="budget passed while the job was updated"):
            boot._ensure_bundled_agent_installed(s, ws, AppConfig(), deadline=deadline)
    assert _stored(engine).notebook_path == OLD_PATH
    assert job.notebooks[42] == OLD_PATH


def test_a_run_started_during_the_reset_is_not_moved(engine, ws, agent, job, installed):
    _seed(engine, OLD_PATH)
    job.state["after"] = lambda: _active_run(engine, "pending")
    with pytest.raises(boot.AgentChangeAborted, match="started while the job was updated"):
        _boot(engine, ws)
    assert _stored(engine).notebook_path == OLD_PATH
    assert job.notebooks[42] == OLD_PATH


def test_the_identity_is_not_stored_when_the_path_changes_during_the_read(engine, ws, agent, job, monkeypatch):
    _seed(engine, OLD_PATH)

    def read_then_save(_ws, _path):
        _settings_save(engine, CUSTOM_PATH)
        return ("v0.8.0", "v4.9.9")

    monkeypatch.setattr(_helpers, "_detect_notebook_identity", read_then_save)
    with pytest.raises(boot.AgentChangeAborted, match="changed meanwhile"):
        _boot(engine, ws)
    cfg = _stored(engine)
    assert cfg.notebook_path == CUSTOM_PATH and cfg.installed_checked_path is None
    ws.workspace.upload.assert_not_called()


def test_the_identity_is_not_stored_after_the_deadline(engine, ws, agent, job, monkeypatch):
    _seed(engine, OLD_PATH)
    deadline = time.monotonic() + 0.1

    def slow_read(_ws, _path):
        time.sleep(0.2)
        return ("v0.8.0", "v4.9.9")

    monkeypatch.setattr(_helpers, "_detect_notebook_identity", slow_read)
    with Session(engine, expire_on_commit=False) as s:
        with pytest.raises(boot.AgentChangeAborted, match="time budget"):
            boot._ensure_bundled_agent_installed(s, ws, AppConfig(), deadline=deadline)
    assert _stored(engine).installed_checked_path is None


def test_repair_when_the_job_cannot_be_read_logs_and_the_original_error_surfaces(
    engine, ws, agent, job, installed, caplog
):
    _seed(engine, OLD_PATH)
    job.state["fail_after_apply"] = RuntimeError("reset failed")
    ws.jobs.get.side_effect = RuntimeError("jobs get down")
    with caplog.at_level(logging.ERROR):
        with pytest.raises(boot.AgentJobSetupError, match="reset failed"):
            _boot(engine, ws)
    assert any("Could not confirm the agent job" in r.getMessage() for r in caplog.records)
    assert _stored(engine).notebook_path == OLD_PATH


def test_repair_without_a_job_creates_one_and_saves_it(engine, ws, agent, job):
    _seed(engine, CUSTOM_PATH, job_id=None)
    with Session(engine) as s:
        boot.converge_agent_job_to_row(s, ws, _stored(engine).id)
    cfg = _stored(engine)
    assert cfg.job_id == 777 and job.notebooks[777] == CUSTOM_PATH


def test_repair_leaves_a_job_already_on_the_stored_notebook(engine, ws, agent, job):
    _seed(engine, OLD_PATH)
    with Session(engine) as s:
        boot.converge_agent_job_to_row(s, ws, _stored(engine).id)
    job.assert_not_called()


def test_fresh_install_records_the_bundled_identity(engine, ws, agent, job):
    _boot(engine, ws)
    cfg = _stored(engine)
    assert cfg.notebook_path == NEW_PATH and cfg.job_id == 777
    assert (cfg.installed_agent_version, cfg.installed_checked_path) == ("5.3.3", NEW_PATH)


def test_fresh_install_leaves_a_path_saved_meanwhile(engine, ws, agent, job):
    _seed(engine, "", job_id=None)
    ws.workspace.upload.side_effect = lambda **_kw: _settings_save(engine, CUSTOM_PATH)
    with pytest.raises(boot.AgentChangeAborted):
        _boot(engine, ws)
    assert _stored(engine).notebook_path == CUSTOM_PATH
    job.assert_not_called()


def test_fresh_install_past_the_deadline_saves_no_job(engine, ws, agent, job):
    _seed(engine, "", job_id=None)
    deadline = time.monotonic() + 0.2
    job.state["before"] = lambda: time.sleep(0.3)
    with Session(engine, expire_on_commit=False) as s:
        with pytest.raises(boot.AgentChangeAborted, match="budget passed"):
            boot._ensure_bundled_agent_installed(s, ws, AppConfig(), deadline=deadline)
    cfg = _stored(engine)
    assert cfg.notebook_path == NEW_PATH and cfg.job_id is None


def test_fresh_install_job_loses_to_a_save_during_job_creation(engine, ws, agent, job):
    _seed(engine, "", job_id=None)
    job.state["after"] = lambda: _settings_save(engine, CUSTOM_PATH)
    with pytest.raises(boot.AgentChangeAborted, match="changed meanwhile"):
        _boot(engine, ws)
    cfg = _stored(engine)
    assert cfg.notebook_path == CUSTOM_PATH
    assert job.notebooks[cfg.job_id or 777] == CUSTOM_PATH


def _wait_for_log(caplog, text: str, timeout: float = 5.0) -> bool:
    end = time.monotonic() + timeout
    while time.monotonic() < end:
        if any(text in r.getMessage() for r in caplog.records):
            return True
        time.sleep(0.02)
    return False


def test_a_failure_after_the_budget_is_logged(engine, monkeypatch, caplog):
    release = threading.Event()

    def slow_then_fail(*_a, **_kw):
        release.wait(5)
        raise RuntimeError("late failure")

    monkeypatch.setattr(boot, "_ensure_bundled_agent_installed", slow_then_fail)
    with caplog.at_level(logging.WARNING):
        asyncio.run(boot.run_boot_agent_install(engine, MagicMock(), AppConfig(), budget_seconds=0.05))
        release.set()
        assert _wait_for_log(caplog, "install/upgrade failed")
    assert any(r.exc_info and "late failure" in str(r.exc_info[1]) for r in caplog.records)


def test_an_upgrade_that_finishes_after_the_budget_moves_nothing(engine, ws, agent, job, installed, caplog):
    _seed(engine, OLD_PATH)

    def slow_upload(**_kw):
        time.sleep(0.3)

    ws.workspace.upload.side_effect = slow_upload
    with caplog.at_level(logging.WARNING):
        asyncio.run(boot.run_boot_agent_install(engine, ws, AppConfig(), budget_seconds=0.1))
        assert _wait_for_log(caplog, "install/upgrade stopped: the boot time budget has passed")
    assert _stored(engine).notebook_path == OLD_PATH
    job.assert_not_called()


def test_the_boot_thread_is_a_daemon(engine, monkeypatch):
    seen = {}
    release = threading.Event()

    def record(*_a, **_kw):
        seen["daemon"] = threading.current_thread().daemon
        release.wait(5)

    monkeypatch.setattr(boot, "_ensure_bundled_agent_installed", record)
    asyncio.run(boot.run_boot_agent_install(engine, MagicMock(), AppConfig(), budget_seconds=0.05))
    release.set()
    assert seen["daemon"] is True


def test_boot_budget_returns_while_the_step_is_stuck(engine, monkeypatch, caplog):
    release = threading.Event()
    monkeypatch.setattr(boot, "_ensure_bundled_agent_installed", lambda *_a, **_kw: release.wait(5))
    with caplog.at_level(logging.WARNING):
        asyncio.run(boot.run_boot_agent_install(engine, MagicMock(), AppConfig(), budget_seconds=0.05))
    release.set()
    assert any("did not finish within 0.05s" in r.getMessage() for r in caplog.records)


def test_boot_failure_is_logged_and_never_raised(engine, monkeypatch, caplog):
    def explode(*_a, **_kw):
        raise RuntimeError("boom")

    monkeypatch.setattr(boot, "_ensure_bundled_agent_installed", explode)
    with caplog.at_level(logging.ERROR):
        asyncio.run(boot.run_boot_agent_install(engine, MagicMock(), AppConfig()))
    assert any("install/upgrade failed" in r.getMessage() for r in caplog.records)


# --- routes --------------------------------------------------------------------


def _client(engine, ws, role=UserRole.APP_ADMIN) -> TestClient:
    app = make_test_app(platform_routes.router, config_routes.router)

    def _session():
        with Session(engine) as s:
            yield s

    app.dependency_overrides[_LakebaseDependency.__call__] = _session
    config = AppConfig()
    app.dependency_overrides[_ConfigDependency.__call__] = lambda: config
    app.dependency_overrides[_WorkspaceClientDependency.__call__] = lambda: ws
    app.dependency_overrides[resolve_user_role] = lambda: role
    return TestClient(app)


def test_switch_moves_an_admin_owned_notebook_to_the_bundled_one(engine, ws, agent, job, installed):
    _seed(engine, CUSTOM_PATH)
    r = _client(engine, ws).post("/api/admin/agent/switch-to-bundled")
    assert r.status_code == 200, r.text
    body = r.json()
    assert body["notebook_path"] == NEW_PATH and body["job_id"] == 42
    cfg = _stored(engine)
    assert (cfg.notebook_path, cfg.job_id, cfg.installed_agent_version) == (NEW_PATH, 42, "5.3.3")
    assert job.notebooks[42] == NEW_PATH
    ws.workspace.upload.assert_called_once()


def test_switch_is_refused_while_a_run_is_in_flight(engine, ws, agent, job, installed):
    _seed(engine, CUSTOM_PATH)
    _active_run(engine, "stale")
    r = _client(engine, ws).post("/api/admin/agent/switch-to-bundled")
    assert r.status_code == 409
    assert "1 run(s) in flight" in r.json()["detail"]
    assert _stored(engine).notebook_path == CUSTOM_PATH
    ws.workspace.upload.assert_not_called()
    job.assert_not_called()


def test_switch_job_failure_is_500_and_saves_nothing(engine, ws, agent, job, installed):
    _seed(engine, CUSTOM_PATH)
    job.side_effect = RuntimeError("jobs api down")
    r = _client(engine, ws).post("/api/admin/agent/switch-to-bundled")
    assert r.status_code == 500
    assert "Failed to update the Databricks job" in r.json()["detail"]
    cfg = _stored(engine)
    assert (cfg.notebook_path, cfg.job_id) == (CUSTOM_PATH, 42)


def test_switch_500_detail_is_sanitized(engine, ws, agent, job, installed):
    _seed(engine, CUSTOM_PATH)
    token = "dapi" + "0123456789abcdef" * 2
    job.side_effect = RuntimeError(f"denied for {token}")
    r = _client(engine, ws).post("/api/admin/agent/switch-to-bundled")
    assert r.status_code == 500
    assert token not in r.json()["detail"]


def test_switch_loses_to_a_concurrent_settings_save(engine, ws, agent, job, installed):
    _seed(engine, CUSTOM_PATH)
    ws.workspace.upload.side_effect = lambda **_kw: _settings_save(engine, OLD_PATH)
    r = _client(engine, ws).post("/api/admin/agent/switch-to-bundled")
    assert r.status_code == 409
    assert "was not switched" in r.json()["detail"]
    assert _stored(engine).notebook_path == OLD_PATH
    job.assert_not_called()


def test_switch_without_a_bundled_notebook_is_500(engine, ws, monkeypatch, job):
    monkeypatch.setattr(bundled_agent_install, "resolve_bundled_agent", lambda: None)
    _seed(engine, CUSTOM_PATH)
    r = _client(engine, ws).post("/api/admin/agent/switch-to-bundled")
    assert r.status_code == 500
    assert "No bundled agent notebook" in r.json()["detail"]
    assert _stored(engine).notebook_path == CUSTOM_PATH


@pytest.mark.parametrize("role", [UserRole.BUSINESS_ADMIN, UserRole.MODELER, UserRole.VIEWER])
def test_switch_is_admin_only(engine, ws, agent, job, role):
    _seed(engine, CUSTOM_PATH)
    assert _client(engine, ws, role).post("/api/admin/agent/switch-to-bundled").status_code == 403
    assert _stored(engine).notebook_path == CUSTOM_PATH


def _compat(engine, ws, monkeypatch) -> dict:
    monkeypatch.setattr(config_routes, "_fetch_upstream_agent_identity", lambda *_a: ("v0.8.0", "5.3.3"))
    r = _client(engine, ws).get("/api/config/agent-compat")
    assert r.status_code == 200, r.text
    return r.json()


def _seed_cached(engine, path, *, read_from=None, release=None, marker=None, error=None) -> None:
    """A configured notebook whose identity was last read from ``read_from`` (default: ``path``)."""
    from datetime import datetime, timezone

    with Session(engine) as s:
        s.add(AgentConfig(
            notebook_path=path, job_id=42,
            installed_release_version=release, installed_agent_version=marker,
            installed_check_error=error, installed_checked_path=read_from or path,
            installed_checked_at=datetime(2026, 10, 22, tzinfo=timezone.utc),
        ))
        s.commit()


@pytest.fixture
def no_export(monkeypatch):
    def fail(*_a):
        raise AssertionError("GET /config/agent-compat must not export the notebook")

    monkeypatch.setattr(_helpers, "_detect_notebook_identity", fail)


def test_compat_reports_an_app_owned_notebook_from_the_cache(engine, ws, agent, no_export, monkeypatch):
    _seed_cached(engine, NEW_PATH, release="v0.8.0", marker="5.3.3")
    body = _compat(engine, ws, monkeypatch)
    assert body["installed_release_version"] == "v0.8.0"
    assert body["installed_agent_version"] == "5.3.3"
    assert body["installed_checked_path"] == NEW_PATH
    assert body["installed_checked_at"] is not None
    assert body["bundled_agent_marker"] == "5.3.3"
    assert body["installed_vs_bundled"] == "same"
    assert body["agent_owner"] == "app"
    assert body["scope_supported"] is True


def test_compat_reports_the_gap_on_an_admin_owned_notebook(engine, ws, agent, no_export, monkeypatch):
    _seed_cached(engine, CUSTOM_PATH, release="v0.8.0", marker="4.9.9")
    body = _compat(engine, ws, monkeypatch)
    assert body["installed_agent_version"] == "4.9.9"
    assert body["installed_vs_bundled"] == "older"
    assert body["agent_owner"] == "admin"
    assert body["scope_supported"] is False


def test_compat_reports_an_unreadable_notebook(engine, ws, agent, no_export, monkeypatch):
    _seed_cached(engine, CUSTOM_PATH, error="RuntimeError: cannot export")
    body = _compat(engine, ws, monkeypatch)
    assert body["installed_vs_bundled"] == "unknown"
    assert body["scope_supported"] is None
    assert "cannot export" in body["installed_check_error"]


def test_compat_ignores_values_read_from_another_path(engine, ws, agent, no_export, monkeypatch):
    _seed_cached(engine, CUSTOM_PATH, read_from=OLD_PATH, release="v0.8.0", marker="5.3.3")
    body = _compat(engine, ws, monkeypatch)
    assert body["installed_agent_version"] is None
    assert body["installed_vs_bundled"] == "unknown"
    assert body["scope_supported"] is None


def test_compat_without_a_notebook_leaves_the_identity_empty(engine, ws, agent, no_export, monkeypatch):
    _seed(engine, "", job_id=None)
    body = _compat(engine, ws, monkeypatch)
    for key in (
        "installed_release_version", "installed_agent_version", "installed_vs_bundled",
        "agent_owner", "scope_supported",
    ):
        assert body[key] is None
    assert body["bundled_agent_marker"] == "5.3.3"


def test_compat_never_writes_the_identity(engine, ws, agent, no_export, monkeypatch):
    _seed_cached(engine, CUSTOM_PATH, release="v0.8.0", marker="4.9.9")
    before = _stored(engine)
    _compat(engine, ws, monkeypatch)
    _compat(engine, ws, monkeypatch)
    after = _stored(engine)
    for col in ("installed_release_version", "installed_agent_version", "installed_checked_at",
                "installed_checked_path", "installed_check_error"):
        assert getattr(after, col) == getattr(before, col)


def test_boot_records_an_admin_owned_notebooks_identity(engine, ws, agent, job, installed):
    _seed(engine, CUSTOM_PATH)
    _boot(engine, ws)
    cfg = _stored(engine)
    assert (cfg.installed_agent_version, cfg.installed_checked_path) == ("4.9.9", CUSTOM_PATH)


def test_settings_save_records_the_identity_with_one_export(engine, ws, agent, job, monkeypatch):
    ws.workspace.get_status.side_effect = None
    exports: list[str] = []
    monkeypatch.setattr(
        _helpers, "_detect_notebook_identity", lambda _w, p: exports.append(p) or ("v0.8.0", "v4.9.9")
    )
    _seed(engine, OLD_PATH)
    r = _client(engine, ws).put("/api/config/agent", json={"notebook_path": CUSTOM_PATH, "max_concurrent_runs": 3})
    assert r.status_code == 200, r.text
    cfg = _stored(engine)
    assert (cfg.installed_agent_version, cfg.installed_checked_path) == ("4.9.9", CUSTOM_PATH)
    assert exports == [CUSTOM_PATH]


def test_settings_save_points_a_moved_job_back_at_the_saved_path(engine, ws, agent, job, monkeypatch):
    ws.workspace.get_status.side_effect = None
    monkeypatch.setattr(_helpers, "_detect_notebook_identity", lambda _w, _p: ("v0.8.0", "v4.9.9"))
    _seed(engine, OLD_PATH)

    def concurrent_boot_moves_the_job():
        job.notebooks[42] = NEW_PATH

    job.state["after"] = concurrent_boot_moves_the_job
    r = _client(engine, ws).put("/api/config/agent", json={"notebook_path": CUSTOM_PATH, "max_concurrent_runs": 3})
    assert r.status_code == 200, r.text
    assert _stored(engine).notebook_path == CUSTOM_PATH
    assert job.notebooks[42] == CUSTOM_PATH
    assert job.call_count == 2


def test_settings_save_still_refuses_another_release(engine, ws, agent, job, monkeypatch):
    ws.workspace.get_status.side_effect = None
    monkeypatch.setattr(_helpers, "_detect_notebook_identity", lambda _w, _p: ("v0.7.7", "v0.7.7"))
    _seed(engine, OLD_PATH)
    r = _client(engine, ws).put("/api/config/agent", json={"notebook_path": CUSTOM_PATH, "max_concurrent_runs": 3})
    assert r.status_code == 400
    assert "release mismatch" in r.json()["detail"]
    assert _stored(engine).notebook_path == OLD_PATH


# --- app identity tags on the agent job after an upgrade ----------------------------------------

APP_NAME = "vibe-modeling-test"


def _tag_ws(tags, session=None):
    """Jobs API whose get returns ``tags``; with ``session``, both calls record in
    ``w.open_transaction_calls`` when a database transaction is open (none may idle
    across a Jobs call). Recorded, not raised: the sync swallows its errors."""
    w = MagicMock()
    w.open_transaction_calls = []

    def no_open_transaction(call):
        if session is not None and session.in_transaction():
            w.open_transaction_calls.append(call)

    def get(**_kw):
        no_open_transaction("get")
        return SimpleNamespace(settings=SimpleNamespace(tags=tags))

    w.jobs.get.side_effect = get
    w.jobs.update.side_effect = lambda **_kw: no_open_transaction("update")
    return w


def _assert_tags_only_update(w, tags):
    calls = w.__dict__.get("open_transaction_calls", [])
    assert calls == [], f"a DB transaction was open across Jobs call(s): {calls}"
    kw = w.jobs.update.call_args.kwargs
    assert kw["new_settings"].as_dict() == {"tags": tags}
    assert "fields_to_remove" not in kw


def _want():
    return job_launcher.app_job_tags()


def test_a_job_without_the_app_tags_gets_them_merged_in(engine, monkeypatch):
    monkeypatch.setenv("DATABRICKS_APP_NAME", APP_NAME)
    _seed(engine, CUSTOM_PATH)
    with Session(engine) as s:
        w = _tag_ws({"managed_by": "vibe_modeling_app", "dbx_vibe_modelling_domains": "7"}, session=s)
        boot.sync_agent_job_tags(s, w, _stored(engine).id)
    w.jobs.get.assert_called_once()
    w.jobs.update.assert_called_once()
    assert w.jobs.update.call_args.kwargs["job_id"] == 42
    _assert_tags_only_update(w, {"dbx_vibe_modelling_domains": "7", **_want()})
    assert w.jobs.update.call_args.kwargs["new_settings"].tags["dbx_vibe_modelling_app"] == APP_NAME


def test_a_job_with_the_app_tags_is_left_alone(engine, monkeypatch):
    monkeypatch.setenv("DATABRICKS_APP_NAME", APP_NAME)
    _seed(engine, CUSTOM_PATH)
    w = _tag_ws({**_want(), "dbx_vibe_modelling_domains": "7"})
    with Session(engine) as s:
        boot.sync_agent_job_tags(s, w, _stored(engine).id)
    w.jobs.update.assert_not_called()


def test_an_old_version_tag_is_updated(engine):
    _seed(engine, CUSTOM_PATH)
    with Session(engine) as s:
        w = _tag_ws({**_want(), "dbx_vibe_modelling_app_version": "0.0.1"}, session=s)
        boot.sync_agent_job_tags(s, w, _stored(engine).id)
    _assert_tags_only_update(w, _want())


def test_tags_are_not_touched_under_a_run(engine):
    _seed(engine, CUSTOM_PATH)
    _active_run(engine)
    w = _tag_ws({"managed_by": "vibe_modeling_app"})
    with Session(engine) as s:
        boot.sync_agent_job_tags(s, w, _stored(engine).id)
    w.jobs.update.assert_not_called()


def test_tags_are_not_touched_past_the_deadline(engine):
    _seed(engine, CUSTOM_PATH)
    w = _tag_ws({})
    with Session(engine) as s:
        boot.sync_agent_job_tags(s, w, _stored(engine).id, deadline=time.monotonic() - 1)
    w.jobs.update.assert_not_called()


def test_no_job_reads_nothing(engine):
    _seed(engine, CUSTOM_PATH, job_id=None)
    w = _tag_ws({})
    with Session(engine) as s:
        boot.sync_agent_job_tags(s, w, _stored(engine).id)
    w.jobs.get.assert_not_called()


def test_a_jobs_error_is_logged_not_raised(engine, caplog):
    _seed(engine, CUSTOM_PATH)
    w = MagicMock()
    w.jobs.get.side_effect = RuntimeError("jobs down")
    with Session(engine) as s, caplog.at_level(logging.ERROR):
        boot.sync_agent_job_tags(s, w, _stored(engine).id)
    assert any("app identity tags" in r.getMessage() for r in caplog.records)


def test_boot_tags_the_job_of_a_notebook_it_does_not_move(engine, ws, agent, job, installed):
    """An admin-owned notebook is never moved, but its job still gets the app identity tags."""
    _seed(engine, CUSTOM_PATH)
    _boot(engine, ws)
    job.assert_not_called()
    ws.jobs.update.assert_called_once()
    _assert_tags_only_update(ws, _want())


def test_a_failed_upgrade_still_tags_the_job_and_raises(engine, monkeypatch):
    def upload_fails(*_a, **_k):
        raise RuntimeError("upload failed")

    monkeypatch.setattr(boot, "_upgrade_app_owned", upload_fails)
    _seed(engine, OLD_PATH)
    with Session(engine, expire_on_commit=False) as s:
        w = _tag_ws({"managed_by": "vibe_modeling_app"}, session=s)
        with pytest.raises(RuntimeError, match="upload failed"):
            boot._ensure_bundled_agent_installed(s, w, AppConfig())
    _assert_tags_only_update(w, _want())


def test_an_aborted_upgrade_does_not_tag(engine, monkeypatch):
    def aborted(*_a, **_k):
        raise boot.AgentChangeAborted("a run is in flight")

    monkeypatch.setattr(boot, "_upgrade_app_owned", aborted)
    _seed(engine, OLD_PATH)
    with Session(engine, expire_on_commit=False) as s:
        w = _tag_ws({}, session=s)
        with pytest.raises(boot.AgentChangeAborted):
            boot._ensure_bundled_agent_installed(s, w, AppConfig())
    w.jobs.update.assert_not_called()
