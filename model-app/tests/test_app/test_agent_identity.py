"""``core/_agent_identity.py``: the configured notebook's identity cache, the
installed-vs-bundled verdict, ownership, and the one bundled-marker source."""

from __future__ import annotations

import json
from datetime import datetime, timedelta, timezone
from pathlib import Path
from unittest.mock import MagicMock

import pytest
from sqlmodel import Session, SQLModel, create_engine, select

from vibe_modeling.backend.agent_compat import is_newer_tag
from vibe_modeling.backend.bundled_agent import BundledAgent, resolve_bundled_agent
from vibe_modeling.backend.core import _agent_identity as ident
from vibe_modeling.backend.core._defaults import SUPPORTED_AGENT_MARKER, SUPPORTED_AGENT_VERSION
from vibe_modeling.backend.core._vibe_scope import MIN_AGENT_MARKER_FOR_SCOPE
from vibe_modeling.backend.db_models import AgentConfig
from vibe_modeling.backend.models import AgentCompatOut, InstalledVsBundled
from vibe_modeling.backend.routes import _helpers
from vibe_modeling.backend.routes._helpers import parse_identity_from_ipynb

VENDOR = Path(__file__).resolve().parents[2] / "src" / "app" / "vendored" / "agent"
HOME = "/Users/app-sp-id"
APP_PATH = f"{HOME}/vibe-modelling-agent/vibe_modelling_agent_v4.9.9.ipynb"
NOW = datetime(2026, 10, 22, 12, 0, tzinfo=timezone.utc)


def _bundled(release="v0.8.0", marker="5.3.3") -> BundledAgent:
    return BundledAgent(
        file_path=Path("/nowhere.ipynb"), file_name="nowhere.ipynb",
        pinned_tag=release, supported_tags=[release], agent_version=marker,
    )


@pytest.fixture
def session():
    engine = create_engine("sqlite://")
    SQLModel.metadata.create_all(engine)
    with Session(engine) as s:
        yield s


@pytest.fixture
def cfg(session):
    row = AgentConfig(notebook_path=APP_PATH)
    session.add(row)
    session.commit()
    return row


def _detector(monkeypatch, *, result=("v0.8.0", "v4.9.9"), raises=None):
    calls: list[str] = []

    def fake(_ws, path):
        calls.append(path)
        if raises is not None:
            raise raises
        return result

    monkeypatch.setattr(_helpers, "_detect_notebook_identity", fake)
    return calls


# --- one marker source ----------------------------------------------------------


def test_bundled_marker_comes_from_versions_json_and_matches_the_constants():
    manifest = json.loads((VENDOR / "VERSIONS.json").read_text())
    agent = resolve_bundled_agent()
    assert agent is not None
    assert agent.agent_version == manifest["pinned_agent_version"].lstrip("v")
    assert agent.agent_version == SUPPORTED_AGENT_MARKER
    assert agent.pinned_tag == SUPPORTED_AGENT_VERSION
    assert not is_newer_tag(MIN_AGENT_MARKER_FOR_SCOPE, agent.agent_version)
    assert agent.file_name == manifest["notebook_file"]


def test_bundled_notebook_declares_the_manifest_identity():
    agent = resolve_bundled_agent()
    release, marker = parse_identity_from_ipynb(agent.file_path.read_text())
    assert (release, marker) == (agent.pinned_tag, agent.agent_version)


# --- installed vs bundled -------------------------------------------------------


@pytest.mark.parametrize(
    "release,marker,expected",
    [
        ("v0.8.0", "5.3.3", "same"),
        ("v0.8.0", "4.9.9", "older"),  # same release, older marker: the test workspace 4.9.9 case
        ("v0.8.0", "5.4.0", "newer"),
        ("v0.7.7", "v0.7.7", "older"),  # pre-0.8.0: release falls back to the marker
        ("v0.9.0", "1.0.0", "newer"),  # newer release wins over an older marker
        ("v0.8.0", None, "unknown"),
        (None, None, "unknown"),
    ],
)
def test_compare_to_bundled(release, marker, expected):
    assert ident.compare_to_bundled(release, marker, _bundled()) == expected


def test_compare_without_a_bundled_agent_is_unknown():
    assert ident.compare_to_bundled("v0.8.0", "5.3.3", None) == "unknown"


def test_installed_vs_bundled_is_a_closed_vocabulary():
    from typing import get_args

    assert set(get_args(InstalledVsBundled)) == {"same", "older", "newer", "unknown"}
    with pytest.raises(ValueError):
        AgentCompatOut(
            pinned_version="v0.8.0", latest_known_upstream="v0.8.0", newer_available=False,
            has_breaking_change=False, installed_vs_bundled="release_mismatch",
        )


@pytest.mark.parametrize("marker,expected", [("5.3.3", True), ("5.4.0", True), ("4.9.9", False), (None, None)])
def test_supports_scope(marker, expected):
    assert ident.supports_scope(marker) is expected


def test_cache_for_the_current_path_only(cfg):
    ident.record_installed_identity(cfg, path=APP_PATH, release="v0.8.0", marker="5.3.3", now=NOW)
    assert ident.cached_identity_for_current_path(cfg).marker == "5.3.3"
    cfg.notebook_path = "/Users/me/custom.ipynb"
    assert ident.cached_identity_for_current_path(cfg) == ident.NotebookIdentity(None, None, None, None, None)


# --- ownership ------------------------------------------------------------------


@pytest.mark.parametrize(
    "path,owner",
    [
        (APP_PATH, "app"),
        ("/Workspace" + APP_PATH, "app"),
        (f"{HOME}/vibe-modelling-agent-copy/nb.ipynb", "admin"),
        (f"{HOME}/other/nb.ipynb", "admin"),
        ("/Users/someone@corp.example/vibe-modelling-agent/nb.ipynb", "admin"),
        (f"{HOME}/vibe-modelling-agent/../../someone@corp.example/x.ipynb", "admin"),
        (f"{HOME}/vibe-modelling-agent/sub/../nb.ipynb", "app"),
        ("", None),
    ],
)
def test_agent_owner(path, owner):
    assert ident.agent_owner(path, HOME) == owner


def test_owner_unknown_without_a_home():
    assert ident.agent_owner(APP_PATH, "") is None
    assert ident.is_app_owned(APP_PATH, "") is False


# --- the identity cache ---------------------------------------------------------


def test_no_notebook_reads_and_writes_nothing(session, monkeypatch):
    calls = _detector(monkeypatch)
    row = AgentConfig(notebook_path="")
    session.add(row)
    session.commit()
    got = ident.installed_identity(session, MagicMock(), row, now=NOW)
    assert got == ident.NotebookIdentity(None, None, None, None, None)
    assert calls == [] and row.installed_checked_at is None


def test_live_read_is_stored_with_a_bare_marker(session, cfg, monkeypatch):
    calls = _detector(monkeypatch)
    got = ident.installed_identity(session, MagicMock(), cfg, now=NOW)
    assert calls == [APP_PATH]
    assert (got.release, got.marker, got.path, got.error) == ("v0.8.0", "4.9.9", APP_PATH, None)
    stored = session.exec(select(AgentConfig)).one()
    assert stored.installed_agent_version == "4.9.9"
    assert stored.installed_checked_path == APP_PATH


def test_fresh_cache_skips_the_export(session, cfg, monkeypatch):
    calls = _detector(monkeypatch)
    ident.installed_identity(session, MagicMock(), cfg, now=NOW)
    ident.installed_identity(session, MagicMock(), cfg, now=NOW + timedelta(minutes=9))
    assert len(calls) == 1


def test_stale_cache_reads_again(session, cfg, monkeypatch):
    calls = _detector(monkeypatch)
    ident.installed_identity(session, MagicMock(), cfg, now=NOW)
    ident.installed_identity(session, MagicMock(), cfg, now=NOW + ident.IDENTITY_TTL + timedelta(seconds=1))
    assert len(calls) == 2


def test_zero_max_age_forces_a_read(session, cfg, monkeypatch):
    calls = _detector(monkeypatch)
    ident.installed_identity(session, MagicMock(), cfg, now=NOW)
    ident.installed_identity(session, MagicMock(), cfg, max_age=timedelta(0), now=NOW)
    assert len(calls) == 2


def test_a_changed_path_invalidates_the_cache(session, cfg, monkeypatch):
    calls = _detector(monkeypatch)
    ident.installed_identity(session, MagicMock(), cfg, now=NOW)
    cfg.notebook_path = "/Users/me/custom.ipynb"
    ident.installed_identity(session, MagicMock(), cfg, now=NOW)
    assert calls == [APP_PATH, "/Users/me/custom.ipynb"]


def test_failed_read_keeps_last_good_for_the_same_path(session, cfg, monkeypatch):
    _detector(monkeypatch)
    ident.installed_identity(session, MagicMock(), cfg, now=NOW)
    _detector(monkeypatch, raises=RuntimeError("export failed"))
    got = ident.installed_identity(session, MagicMock(), cfg, max_age=timedelta(0), now=NOW)
    assert (got.release, got.marker) == ("v0.8.0", "4.9.9")
    assert "RuntimeError: export failed" in got.error


def test_failed_read_drops_another_paths_versions(session, cfg, monkeypatch):
    _detector(monkeypatch)
    ident.installed_identity(session, MagicMock(), cfg, now=NOW)
    cfg.notebook_path = "/Users/me/custom.ipynb"
    _detector(monkeypatch, raises=RuntimeError("no access"))
    got = ident.installed_identity(session, MagicMock(), cfg, now=NOW)
    assert (got.release, got.marker, got.path) == (None, None, "/Users/me/custom.ipynb")
    assert "no access" in got.error


def test_a_notebook_without_markers_records_why(session, cfg, monkeypatch):
    _detector(monkeypatch, result=(None, None))
    got = ident.installed_identity(session, MagicMock(), cfg, now=NOW)
    assert got.release is None and "no __RELEASE_VERSION__" in got.error
