"""Unit tests for ``backend/bundled_agent_install.py`` and the lifespan
auto-install (``backend/core/_bundled_agent_init.py``).

The helper drives the wheel→workspace copy. Tests mock ``WorkspaceClient``
and ``resolve_bundled_agent`` so we exercise orchestration and error
paths without hitting Databricks. The lifespan tests use the same
mocking surface plus an in-memory SQLite session.
"""

from __future__ import annotations

from pathlib import Path
from unittest.mock import MagicMock

import pytest
from sqlmodel import Session, SQLModel, create_engine

from vibe_modeling.backend import bundled_agent_install
from vibe_modeling.backend.bundled_agent import BundledAgent
from vibe_modeling.backend.bundled_agent_install import (
    BundledAgentNotPackagedError,
    install_bundled_agent_into_workspace,
)
from vibe_modeling.backend.core._bundled_agent_init import (
    _ensure_bundled_agent_installed,
)
from vibe_modeling.backend.db_models import AgentConfig


# ---------- helper: install_bundled_agent_into_workspace ----------


def _fake_agent(tmp_path: Path) -> BundledAgent:
    nb = tmp_path / "vibe_modelling_agent_v0.7.1.ipynb"
    nb.write_bytes(b"{}")
    return BundledAgent(
        file_path=nb,
        file_name=nb.name,
        pinned_tag="v0.7.1",
        supported_tags=["v0.7.0", "v0.7.1"],
        agent_version="0.7.1",
    )


def _fake_ws(user_name: str = "app-sp@databricks.com") -> MagicMock:
    ws = MagicMock()
    ws.current_user.me.return_value.user_name = user_name
    return ws


def test_helper_uploads_to_user_folder(tmp_path, monkeypatch):
    agent = _fake_agent(tmp_path)
    monkeypatch.setattr(bundled_agent_install, "resolve_bundled_agent", lambda: agent)
    ws = _fake_ws("sp-uuid")
    # First-install path: get_status raises (not found).
    ws.workspace.get_status.side_effect = Exception("not found")

    result = install_bundled_agent_into_workspace(ws)

    assert result.path == "/Users/sp-uuid/vibe-modelling-agent/vibe_modelling_agent_v0.7.1.ipynb"
    assert result.version == "v0.7.1"
    assert result.overwritten is False
    ws.workspace.mkdirs.assert_called_once_with("/Users/sp-uuid/vibe-modelling-agent")
    ws.workspace.upload.assert_called_once()
    upload_kwargs = ws.workspace.upload.call_args.kwargs
    assert upload_kwargs["path"] == result.path
    assert upload_kwargs["overwrite"] is True


def test_helper_flags_overwritten_when_target_exists(tmp_path, monkeypatch):
    agent = _fake_agent(tmp_path)
    monkeypatch.setattr(bundled_agent_install, "resolve_bundled_agent", lambda: agent)
    ws = _fake_ws()
    ws.workspace.get_status.return_value = MagicMock()  # exists

    result = install_bundled_agent_into_workspace(ws)

    assert result.overwritten is True


def test_helper_raises_when_no_bundled_agent_packaged(monkeypatch):
    monkeypatch.setattr(bundled_agent_install, "resolve_bundled_agent", lambda: None)
    ws = _fake_ws()

    with pytest.raises(BundledAgentNotPackagedError):
        install_bundled_agent_into_workspace(ws)
    ws.workspace.upload.assert_not_called()


def test_helper_raises_when_user_name_missing(tmp_path, monkeypatch):
    agent = _fake_agent(tmp_path)
    monkeypatch.setattr(bundled_agent_install, "resolve_bundled_agent", lambda: agent)
    ws = MagicMock()
    ws.current_user.me.return_value.user_name = ""

    with pytest.raises(RuntimeError, match="user_name"):
        install_bundled_agent_into_workspace(ws)


def test_helper_raises_runtime_when_upload_fails(tmp_path, monkeypatch):
    agent = _fake_agent(tmp_path)
    monkeypatch.setattr(bundled_agent_install, "resolve_bundled_agent", lambda: agent)
    ws = _fake_ws()
    ws.workspace.get_status.side_effect = Exception("not found")
    ws.workspace.upload.side_effect = RuntimeError("disk full")

    with pytest.raises(RuntimeError, match="Failed to upload"):
        install_bundled_agent_into_workspace(ws)


# ---------- lifespan: _ensure_bundled_agent_installed ----------


@pytest.fixture
def session():
    """In-memory SQLite session with all SQLModel tables."""
    engine = create_engine("sqlite://")
    SQLModel.metadata.create_all(engine)
    with Session(engine) as s:
        yield s


@pytest.fixture
def app_config():
    cfg = MagicMock()
    cfg.deployment_catalog = "test_catalog"
    cfg.warehouse_id = "test_warehouse"
    cfg.taxonomy_install_default_model_service = ""
    cfg.run_tags_default = True
    return cfg


def test_lifespan_installs_when_notebook_path_empty(
    tmp_path, monkeypatch, session, app_config
):
    agent = _fake_agent(tmp_path)
    monkeypatch.setattr(bundled_agent_install, "resolve_bundled_agent", lambda: agent)
    ws = _fake_ws("sp-uuid")
    ws.workspace.get_status.side_effect = Exception("not found")

    fake_setup_agent_job = MagicMock(return_value=12345)
    monkeypatch.setattr(
        "vibe_modeling.backend.job_launcher.setup_agent_job", fake_setup_agent_job
    )

    _ensure_bundled_agent_installed(session, ws, app_config)

    cfg = session.exec(__import__("sqlmodel").select(AgentConfig)).first()
    assert cfg is not None
    assert cfg.notebook_path == "/Users/sp-uuid/vibe-modelling-agent/vibe_modelling_agent_v0.7.1.ipynb"
    assert cfg.job_id == 12345
    fake_setup_agent_job.assert_called_once()


def test_lifespan_skips_when_notebook_path_already_set(
    tmp_path, monkeypatch, session, app_config
):
    # Pre-existing AgentConfig with a custom notebook_path.
    pre = AgentConfig(
        deployment_catalog="x",
        warehouse_id="y",
        notebook_path="/Users/me/custom.ipynb",
        job_id=99,
    )
    session.add(pre)
    session.commit()

    upload_called = []
    monkeypatch.setattr(
        bundled_agent_install,
        "resolve_bundled_agent",
        lambda: upload_called.append("called") or _fake_agent(tmp_path),
    )

    ws = _fake_ws()
    fake_setup_agent_job = MagicMock(return_value=999)
    monkeypatch.setattr(
        "vibe_modeling.backend.job_launcher.setup_agent_job", fake_setup_agent_job
    )

    _ensure_bundled_agent_installed(session, ws, app_config)

    # Helper never invoked, job never re-created.
    assert upload_called == []
    fake_setup_agent_job.assert_not_called()
    cfg = session.exec(__import__("sqlmodel").select(AgentConfig)).first()
    assert cfg.notebook_path == "/Users/me/custom.ipynb"
    assert cfg.job_id == 99


def test_lifespan_no_op_when_no_bundled_agent(monkeypatch, session, app_config):
    monkeypatch.setattr(bundled_agent_install, "resolve_bundled_agent", lambda: None)
    ws = _fake_ws()

    # Must not raise — best-effort.
    _ensure_bundled_agent_installed(session, ws, app_config)

    cfg = session.exec(__import__("sqlmodel").select(AgentConfig)).first()
    # AgentConfig was lazily created (catalog/warehouse seeded), but
    # notebook_path stays empty so the user can install via Settings.
    assert cfg is not None
    assert cfg.notebook_path == ""
    assert cfg.job_id is None


def test_lifespan_persists_path_even_if_job_creation_fails(
    tmp_path, monkeypatch, session, app_config
):
    """If the notebook upload succeeded but setup_agent_job blew up, we keep
    notebook_path so a manual Settings-page Save (which only re-runs the job
    creation against the existing notebook) can finish the wiring."""
    agent = _fake_agent(tmp_path)
    monkeypatch.setattr(bundled_agent_install, "resolve_bundled_agent", lambda: agent)
    ws = _fake_ws("sp-uuid")
    ws.workspace.get_status.side_effect = Exception("not found")

    monkeypatch.setattr(
        "vibe_modeling.backend.job_launcher.setup_agent_job",
        MagicMock(side_effect=RuntimeError("jobs api down")),
    )

    _ensure_bundled_agent_installed(session, ws, app_config)

    cfg = session.exec(__import__("sqlmodel").select(AgentConfig)).first()
    assert cfg is not None
    assert cfg.notebook_path == "/Users/sp-uuid/vibe-modelling-agent/vibe_modelling_agent_v0.7.1.ipynb"
    assert cfg.job_id is None
