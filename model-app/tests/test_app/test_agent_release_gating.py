"""Unit tests for release-version-gated agent notebook preflight (the model-versioning work).

Compatibility is gated on the notebook's public release version
(``__RELEASE_VERSION__``), not the per-fix agent-logic marker
(``__AGENT_VERSION__``). A patch bump of the marker within the same release
must pass; a release mismatch must fail. Pre-v0.8.0 notebooks that predate the
split have no release marker, so the identity falls back to the agent marker
(which doubled as the release semver then).
"""

from __future__ import annotations

import base64

import pytest
from fastapi import HTTPException

from vibe_modeling.backend.core._defaults import SUPPORTED_AGENT_VERSION
from vibe_modeling.backend.routes._helpers import (
    _check_notebook_release,
    _detect_notebook_identity,
    parse_release_version_from_notebook,
    parse_version_from_notebook,
)
from vibe_modeling.backend.routes.config import check_agent_notebook

_PINNED = SUPPORTED_AGENT_VERSION.lstrip("v")


def _nb(release: str | None = None, marker: str | None = None) -> str:
    lines: list[str] = []
    if marker is not None:
        lines.append(f'__AGENT_VERSION__ = "{marker}"  # alias=agent-version-global')
    if release is not None:
        lines.append(
            f'__RELEASE_VERSION__ = "{release}"  # alias=release-version-public'
        )
    lines.append("print('hello')")
    return "\n".join(lines)


class _FakeExport:
    def __init__(self, source: str):
        self.content = base64.b64encode(source.encode("utf-8")).decode("ascii")


class _FakeWorkspaceApi:
    def __init__(self, source: str):
        self._source = source

    def get_status(self, path):  # noqa: ARG002 - path unused in the fake
        return object()

    def export(self, path, format=None):  # noqa: A002,ARG002 - mirror SDK signature
        return _FakeExport(self._source)


class _FakeWs:
    def __init__(self, source: str):
        self.workspace = _FakeWorkspaceApi(source)


# --- pure parsers ----------------------------------------------------------


def test_release_and_agent_markers_parse_independently():
    src = _nb(release="0.8.0", marker="4.9.9")
    assert parse_release_version_from_notebook(src) == "v0.8.0"
    assert parse_version_from_notebook(src) == "v4.9.9"


def test_release_marker_absent_returns_none():
    assert parse_release_version_from_notebook(_nb(marker="0.7.7")) is None


# --- identity (single export → release, marker) ----------------------------


def test_identity_prefers_release_over_marker():
    ws = _FakeWs(_nb(release="0.8.0", marker="4.9.9"))
    assert _detect_notebook_identity(ws, "/nb") == ("v0.8.0", "v4.9.9")


def test_identity_falls_back_to_marker_when_no_release():
    # Pre-split notebook: the agent marker doubled as the release semver.
    ws = _FakeWs(_nb(marker="0.7.7"))
    assert _detect_notebook_identity(ws, "/nb") == ("v0.7.7", "v0.7.7")


# --- save-time preflight gating --------------------------------------------


def test_preflight_passes_on_matching_release():
    ws = _FakeWs(_nb(release=_PINNED, marker="4.9.9"))
    assert _check_notebook_release(_detect_notebook_identity(ws, "/nb")[0]) is None


def test_preflight_tolerates_agent_marker_patch_drift():
    # Same release, agent build moved 4.9.9 -> 4.9.10: must still pass.
    ws = _FakeWs(_nb(release=_PINNED, marker="4.9.10"))
    assert _check_notebook_release(_detect_notebook_identity(ws, "/nb")[0]) is None


def test_preflight_fails_on_release_mismatch():
    ws = _FakeWs(_nb(release="0.7.7", marker="4.9.9"))
    with pytest.raises(HTTPException) as exc:
        _check_notebook_release(_detect_notebook_identity(ws, "/nb")[0])
    assert exc.value.status_code == 400
    assert "release" in str(exc.value.detail).lower()


def test_preflight_no_marker_is_advisory_only():
    ws = _FakeWs("print('no markers here')")
    assert _check_notebook_release(_detect_notebook_identity(ws, "/nb")[0]) is None


# --- live check endpoint ----------------------------------------------------


def test_check_ok_on_matching_release_reports_agent_build():
    ws = _FakeWs(_nb(release=_PINNED, marker="4.9.9"))
    out = check_agent_notebook(path="/nb", ws=ws)
    assert out["ok"] is True
    assert out["marker"] == "v4.9.9"


def test_check_ok_tolerates_agent_marker_patch_drift():
    ws = _FakeWs(_nb(release=_PINNED, marker="4.9.10"))
    out = check_agent_notebook(path="/nb", ws=ws)
    assert out["ok"] is True


def test_check_fails_on_release_mismatch():
    ws = _FakeWs(_nb(release="0.7.7", marker="4.9.9"))
    out = check_agent_notebook(path="/nb", ws=ws)
    assert out["ok"] is False
    assert "release" in out["reason"].lower()
