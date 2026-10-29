"""Tests for the agent release-monitor surface.

Covers:
- `/api/config/agent-compat` endpoint shape and content
- `agent_compat.is_newer_tag` semver comparisons
- Known-upstream-changes table entries for v0.5.9 / v0.5.10 / v0.7.1
- The `build_report` / `render_body` helpers used by the CI workflow
"""

import json
import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "..", "src", "app", "src"))
sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", ".."))

import pytest  # noqa: E402

from vibe_modeling.backend import agent_compat as ac  # noqa: E402


# ---------------------------------------------------------------------------
# Pure helpers
# ---------------------------------------------------------------------------


class TestTagComparison:
    @pytest.mark.parametrize("a,b,expected", [
        ("v0.5.9", "v0.5.8", True),
        ("v0.5.10", "v0.5.9", True),
        ("v0.6.0", "v0.5.10", True),
        ("v0.5.8", "v0.5.8", False),
        ("v0.5.7", "v0.5.8", False),
        ("v0.5.10", "v0.6.0", False),
        ("0.5.9", "v0.5.8", True),  # auto-normalise
    ])
    def test_is_newer_tag(self, a, b, expected):
        assert ac.is_newer_tag(a, b) is expected


class TestKnownChanges:
    def test_v059_flagged_breaking(self):
        """v0.5.9 flipped volume folder naming — must be breaking."""
        assert ac.has_breaking_change("v0.5.9") is True
        entries = ac.known_changes_for_tag("v0.5.9")
        assert any(e["severity"] == "breaking" for e in entries)
        # Volume-layout entry should mention the old/new folder pattern so
        # the issue body carries enough signal without links.
        layout = [e for e in entries if e.get("area") == "volume-layout"]
        assert layout, "expected a volume-layout entry for v0.5.9"
        assert "scope" in layout[0]["summary"].lower()

    def test_v0510_non_breaking(self):
        assert ac.has_breaking_change("v0.5.10") is False
        entries = ac.known_changes_for_tag("v0.5.10")
        # At least one info entry, no breaking entries.
        assert entries
        assert all(e["severity"] != "breaking" for e in entries)

    def test_v071_non_breaking(self):
        assert ac.has_breaking_change("v0.7.1") is False
        entries = ac.known_changes_for_tag("v0.7.1")
        assert entries
        assert all(e["severity"] != "breaking" for e in entries)

    def test_v072_non_breaking(self):
        """v0.7.2 was promoted on a structural-diff finding (0 differences
        vs v0.7.1 across 8 samples). All entries must be `info` severity."""
        assert ac.has_breaking_change("v0.7.2") is False
        entries = ac.known_changes_for_tag("v0.7.2")
        assert entries
        assert all(e["severity"] != "breaking" for e in entries)

    def test_unknown_tag_returns_empty(self):
        assert ac.known_changes_for_tag("v99.99.99") == []
        assert ac.has_breaking_change("v99.99.99") is False

    def test_latest_known_upstream_is_v080(self):
        assert ac.latest_known_upstream_tag() == "v0.8.0"

    def test_pinned_now_v080(self):
        """Pinned to the v0.8.0 release, which split the version identities
        (`agent_version` becoming an independent 4.x agent-logic counter,
        the git tag moving to `release_version`) and shipped the
        nested-primary Volume layout with flat-read fallback. v0.6.0
        remains dropped from the compat matrix."""
        from vibe_modeling.backend.core._defaults import SUPPORTED_AGENT_VERSION

        assert SUPPORTED_AGENT_VERSION == "v0.8.0"

    def test_v071_compat_matrix_entry(self):
        """v0.7.1 is the currently pinned tag — the compat matrix MUST
        classify it as `compatible`. Drift in this entry would make the
        importer reject v0.7.1 model.json payloads we ourselves shipped."""
        assert ac.classify_tag("v0.7.1") == "compatible"
        assert "v0.7.1" in ac.SUPPORTED_TAGS

    def test_v072_compat_matrix_entry(self):
        """v0.7.2 outputs already exist in the wild (vibe-business-data-models
        repo: energy_utilities, education, legal, mining, ngo). Structural
        diff vs v0.7.1 found 0 differences across 27 JSON path slots, so
        the importer MUST accept v0.7.2 model.json payloads."""
        assert ac.classify_tag("v0.7.2") == "compatible"
        assert "v0.7.2" in ac.SUPPORTED_TAGS

    def test_v060_dropped_returns_unknown(self):
        """v0.6.0 was dropped entirely in the v0.7.1 fold — it must now
        classify as `unknown` and not be in SUPPORTED_TAGS. Tests in the
        fold-skeptical suite cover the same surface."""
        assert ac.classify_tag("v0.6.0") == "unknown"
        assert "v0.6.0" not in ac.SUPPORTED_TAGS


# ---------------------------------------------------------------------------
# /api/config/agent-compat endpoint
# ---------------------------------------------------------------------------


def _patch_upstream(monkeypatch, *, release, marker=None, raises=None):
    """Monkeypatch the endpoint's upstream-fetch seam so the route never hits
    GitHub. ``raises`` (an exception) simulates a fetch failure; otherwise the
    seam returns ``(release, marker)``."""
    from vibe_modeling.backend.routes import config as config_route

    calls = {"n": 0}

    def _fake(_config, _cfg, _ws):
        calls["n"] += 1
        if raises is not None:
            raise raises
        return (release, marker)

    monkeypatch.setattr(config_route, "_fetch_upstream_agent_identity", _fake)
    return calls


def _seed_agent_config(engine, **kwargs):
    from sqlmodel import Session

    from vibe_modeling.backend.db_models import AgentConfig

    with Session(engine) as session:
        cfg = AgentConfig(**kwargs)
        session.add(cfg)
        session.commit()


class TestAgentCompatEndpoint:
    """Endpoint tests for the three-way release/build verdict. The upstream
    fetch is always monkeypatched — no test makes a live GitHub call."""

    def test_endpoint_shape(self, client, monkeypatch):
        _patch_upstream(monkeypatch, release="v0.8.0", marker="5.3.3")
        response = client.get("/api/config/agent-compat")
        assert response.status_code == 200
        data = response.json()
        for key in (
            "pinned_version", "latest_known_upstream", "newer_available",
            "has_breaking_change", "known_breaking_changes", "repo_url",
            "repo_compare_url", "pinned_release", "pinned_agent_marker",
            "latest_upstream_release", "latest_upstream_marker", "verdict",
            "update_app_required", "install_offered", "checked_at", "check_error",
        ):
            assert key in data, f"missing {key!r} in response"
        assert isinstance(data["newer_available"], bool)
        assert isinstance(data["has_breaking_change"], bool)
        assert isinstance(data["known_breaking_changes"], list)
        # repo_url + compare repoint to the canonical repo.
        assert "databricks-industry-solutions" in data["repo_url"]
        assert data["install_offered"] is False

    def test_verdict_up_to_date_when_equal(self, client, monkeypatch):
        """Upstream == pinned release + marker → up_to_date, nothing to do."""
        _patch_upstream(monkeypatch, release="v0.8.0", marker="5.3.3")
        data = client.get("/api/config/agent-compat").json()
        assert data["pinned_release"] == "v0.8.0"
        assert data["pinned_agent_marker"] == "5.3.3"
        assert data["latest_upstream_release"] == "v0.8.0"
        assert data["latest_upstream_marker"] == "5.3.3"
        assert data["verdict"] == "up_to_date"
        assert data["newer_available"] is False
        assert data["update_app_required"] is False
        assert data["repo_compare_url"] == ""
        assert data["check_error"] is None

    def test_verdict_build_update_available(self, client, monkeypatch):
        """Same release, newer build marker → build_update_available (info only,
        no app update required, no install offered)."""
        _patch_upstream(monkeypatch, release="v0.8.0", marker="5.3.4")
        data = client.get("/api/config/agent-compat").json()
        assert data["verdict"] == "build_update_available"
        assert data["newer_available"] is True
        assert data["update_app_required"] is False
        assert data["install_offered"] is False
        assert data["latest_upstream_marker"] == "5.3.4"

    def test_verdict_release_incompatible(self, client, monkeypatch):
        """Newer upstream RELEASE → release_incompatible: the app must be
        updated; compare URL points at the canonical repo."""
        _patch_upstream(monkeypatch, release="v0.9.0", marker="5.0.0")
        data = client.get("/api/config/agent-compat").json()
        assert data["verdict"] == "release_incompatible"
        assert data["newer_available"] is True
        assert data["update_app_required"] is True
        assert data["install_offered"] is False
        assert data["latest_upstream_release"] == "v0.9.0"
        assert "databricks-industry-solutions/lakehouse-industry-data-models" in data["repo_compare_url"]
        assert "v0.8.0" in data["repo_compare_url"]
        assert "v0.9.0" in data["repo_compare_url"]

    def test_ttl_serves_fresh_cache_without_fetch(self, client, engine, monkeypatch):
        """A recent `upstream_checked_at` serves the cached row and does NOT
        call the fetch seam."""
        from datetime import datetime, timezone

        _seed_agent_config(
            engine,
            upstream_release_version="v0.8.0",
            upstream_agent_version="5.3.3",
            upstream_checked_at=datetime.now(timezone.utc),
        )
        calls = _patch_upstream(monkeypatch, release="v9.9.9", marker="9.9.9")
        data = client.get("/api/config/agent-compat").json()
        assert calls["n"] == 0, "fresh cache must not trigger a fetch"
        assert data["latest_upstream_release"] == "v0.8.0"
        assert data["verdict"] == "up_to_date"

    def test_ttl_refetches_when_stale(self, client, engine, monkeypatch):
        """A `upstream_checked_at` older than the 7-day TTL triggers a fetch and
        persists the new values."""
        from datetime import datetime, timedelta, timezone

        _seed_agent_config(
            engine,
            upstream_release_version="v0.8.0",
            upstream_agent_version="5.3.3",
            upstream_checked_at=datetime.now(timezone.utc) - timedelta(days=8),
        )
        calls = _patch_upstream(monkeypatch, release="v0.8.0", marker="5.3.4")
        data = client.get("/api/config/agent-compat").json()
        assert calls["n"] == 1, "stale cache must trigger a fetch"
        assert data["latest_upstream_marker"] == "5.3.4"
        assert data["verdict"] == "build_update_available"

    def test_fetch_error_keeps_cache_and_records_error(self, client, engine, monkeypatch):
        """A fetch failure keeps the previously cached version values and records
        the error text — no 500."""
        from datetime import datetime, timedelta, timezone

        _seed_agent_config(
            engine,
            upstream_release_version="v0.9.0",
            upstream_agent_version="5.0.0",
            upstream_checked_at=datetime.now(timezone.utc) - timedelta(days=8),
        )
        _patch_upstream(monkeypatch, release=None, raises=RuntimeError("github boom"))
        response = client.get("/api/config/agent-compat")
        assert response.status_code == 200
        data = response.json()
        # Cached values retained (not wiped by the failed fetch).
        assert data["latest_upstream_release"] == "v0.9.0"
        assert data["latest_upstream_marker"] == "5.0.0"
        assert data["check_error"] is not None
        assert "github boom" in data["check_error"]
        # Verdict still computed from the retained cache.
        assert data["verdict"] == "release_incompatible"

    def test_successful_empty_parse_keeps_cache(self, client, engine, monkeypatch):
        """A successful fetch that parses to (None, None) — e.g. the upstream
        notebook renamed/moved its markers — must NOT wipe a known-good cache;
        that would silently flip a cached release_incompatible to up_to_date for
        the whole TTL. Prior values + verdict are retained and a parse-miss error
        is recorded."""
        from datetime import datetime, timedelta, timezone

        _seed_agent_config(
            engine,
            upstream_release_version="v0.9.0",
            upstream_agent_version="5.0.0",
            upstream_checked_at=datetime.now(timezone.utc) - timedelta(days=8),
        )
        _patch_upstream(monkeypatch, release=None, marker=None)
        response = client.get("/api/config/agent-compat")
        assert response.status_code == 200
        data = response.json()
        # Cached values retained (not wiped by the empty parse).
        assert data["latest_upstream_release"] == "v0.9.0"
        assert data["latest_upstream_marker"] == "5.0.0"
        assert data["verdict"] == "release_incompatible"
        assert data["check_error"] is not None

    def test_cold_cache_fetch_error_is_up_to_date(self, client, monkeypatch):
        """A cold cache whose first fetch errors leaves versions NULL and
        degrades to up_to_date rather than 500-ing."""
        _patch_upstream(monkeypatch, release=None, raises=RuntimeError("offline"))
        response = client.get("/api/config/agent-compat")
        assert response.status_code == 200
        data = response.json()
        assert data["latest_upstream_release"] is None
        assert data["verdict"] == "up_to_date"
        assert data["check_error"] is not None


# ---------------------------------------------------------------------------
# Upstream notebook-identity fetch + parse (Surface 2)
# ---------------------------------------------------------------------------


def _ipynb(cells):
    """Build a minimal .ipynb JSON string from (cell_type, source) pairs."""
    import json

    return json.dumps({
        "cells": [
            {"cell_type": ct, "source": src if isinstance(src, list) else [src]}
            for ct, src in cells
        ],
        "metadata": {},
        "nbformat": 4,
        "nbformat_minor": 5,
    })


class _FakeConnector:
    """Stand-in for GithubSourceConnector.fetch_repo_file."""

    def __init__(self, *, text=None, raises=None):
        self._text = text
        self._raises = raises
        self.requested_path = None

    def fetch_repo_file(self, repo_path):
        self.requested_path = repo_path
        if self._raises is not None:
            raise self._raises
        return self._text


class TestUpstreamIdentityFetch:
    def _helpers(self):
        from vibe_modeling.backend.routes import _helpers

        return _helpers

    def test_parse_identity_from_ipynb_reads_both_markers(self):
        h = self._helpers()
        blob = _ipynb([
            ("markdown", "# Title"),
            ("code", '__AGENT_VERSION__ = "4.9.10"  # alias=agent-version-global\n'
                     '__RELEASE_VERSION__ = "0.8.0"  # alias=release-version-public\n'),
            ("code", "import os\n"),
        ])
        assert h.parse_identity_from_ipynb(blob) == ("v0.8.0", "4.9.10")

    def test_parse_identity_release_falls_back_to_marker(self):
        """Pre-split notebooks carry only __AGENT_VERSION__; release falls back."""
        h = self._helpers()
        blob = _ipynb([("code", '__AGENT_VERSION__ = "0.7.7"\n')])
        assert h.parse_identity_from_ipynb(blob) == ("v0.7.7", "0.7.7")

    def test_parse_identity_ignores_markdown_cells(self):
        """A marker mentioned in prose (markdown) must not be parsed."""
        h = self._helpers()
        blob = _ipynb([("markdown", '__RELEASE_VERSION__ = "9.9.9"')])
        assert h.parse_identity_from_ipynb(blob) == (None, None)

    def test_parse_identity_empty_input(self):
        h = self._helpers()
        assert h.parse_identity_from_ipynb("") == (None, None)

    def test_fetch_upstream_agent_identity_uses_connector(self):
        h = self._helpers()
        blob = _ipynb([("code", '__AGENT_VERSION__ = "5.3.3"\n__RELEASE_VERSION__ = "0.8.0"\n')])
        conn = _FakeConnector(text=blob)
        assert h.fetch_upstream_agent_identity(conn) == ("v0.8.0", "5.3.3")
        assert conn.requested_path == h.UPSTREAM_AGENT_NOTEBOOK_REPO_PATH

    def test_fetch_upstream_agent_identity_propagates_error(self):
        h = self._helpers()
        conn = _FakeConnector(raises=RuntimeError("404"))
        with pytest.raises(RuntimeError):
            h.fetch_upstream_agent_identity(conn)


class TestMarkerComparison:
    """`is_newer_tag` must handle the X.Y.Z build markers (4.9.9 vs 4.9.10)."""

    @pytest.mark.parametrize("a,b,expected", [
        ("4.9.10", "4.9.9", True),
        ("4.9.9", "4.9.9", False),
        ("4.9.9", "4.9.10", False),
        ("5.0.0", "4.9.99", True),
        ("v4.9.10", "4.9.9", True),  # leading v tolerated on either side
    ])
    def test_marker_comparison(self, a, b, expected):
        assert ac.is_newer_tag(a, b) is expected


# ---------------------------------------------------------------------------
# v0.7.0 interface-surface contract tests (per the v0.6.0→v0.7.0 audit at
# audit_report.md).
#
# v0.7.0's contract delta is small and append-only: the agent now writes
# `agent_version` as the first top-level key of every model.json (since
# v0.6.9), emits a new `Architect Review` stage with sub-events, and adds
# a `domain_architect_review` block to one stage_succeeded result_json.
# These tests pin the regression surface so a future agent version that
# breaks any of these silently is caught at the contract layer.
# ---------------------------------------------------------------------------


class TestV070ModelJsonContract:
    def test_agent_version_first_key_detection(self):
        """v0.6.9+ writes ``agent_version`` as the first top-level key.
        ``detect_tag_from_model_json`` must read it (already does — see
        ``agent_compat.py:284``)."""
        mj = {
            "agent_version": "v0.7.0",
            "business_name": "test_corp",
            "version": "v1",
            "domains": [],
        }
        assert ac.detect_tag_from_model_json(mj) == "v0.7.0"

    def test_agent_version_normalized_without_v_prefix(self):
        """If the agent ever emits a non-prefixed value (e.g. ``"0.7.0"``),
        ``_normalise`` adds the ``v`` prefix so callers get a canonical tag."""
        mj = {"agent_version": "0.7.0", "domains": []}
        assert ac.detect_tag_from_model_json(mj) == "v0.7.0"

    def test_v_0_7_0_classified_compatible(self):
        """The compat matrix must accept v0.7.0 (this PR's pin)."""
        assert ac.classify_tag("v0.7.0") == "compatible"

    def test_v_0_6_x_patch_releases_classified_compatible(self):
        """v0.6.1 - v0.6.9 are root-cause-fix patch releases on top of
        v0.6.0; the integration contract is unchanged across the series."""
        for n in range(1, 10):
            tag = f"v0.6.{n}"
            assert ac.classify_tag(tag) == "compatible", (
                f"{tag} must be compatible per the v0.6.0→v0.7.0 audit"
            )

    def test_v072_agent_version_field_detected(self):
        """v0.7.2 model.json outputs in the wild declare
        ``agent_version: 0.7.2`` (no v-prefix). The detector must
        normalise to ``v0.7.2`` and the importer must accept it."""
        mj = {
            "agent_version": "0.7.2",
            "model_requirements": {},
            "_vibe_session_metadata": {},
            "model": {
                "name": "Energy Utilities",
                "version": "v1_mvm",
                "domains": [],
            },
        }
        assert ac.detect_tag_from_model_json(mj) == "v0.7.2"
        assert ac.classify_tag("v0.7.2") == "compatible"

    def test_v080_release_version_precedes_agent_version(self):
        """v0.8.0 decoupled the fields: ``agent_version`` is now an
        independent 4.x logic counter (e.g. 4.3.2) while ``release_version``
        carries the git tag. The detector must read ``release_version``
        first, so these models classify as v0.8.0 — not the bogus
        "v4.3.2" that the old agent_version-first probe returned."""
        mj = {
            "agent_version": "4.3.2",
            "release_version": "0.8.0",
            "_vibe_session_metadata": {},
            "model": {"name": "Healthcare", "version": "v2_ecm", "domains": []},
        }
        assert ac.detect_tag_from_model_json(mj) == "v0.8.0"
        assert ac.classify_tag("v0.8.0") == "compatible"

    def test_legacy_agent_version_used_when_no_release_version(self):
        """Pre-v0.8.0 exports have no ``release_version`` and stamp
        ``agent_version`` == the release semver; the detector must still
        fall back to ``agent_version`` for them (back-compat)."""
        mj = {"agent_version": "0.7.2", "model": {"domains": []}}
        assert ac.detect_tag_from_model_json(mj) == "v0.7.2"

    def test_real_4_9_8_model_json_resolves_to_v080_compatible(self):
        """The pinned 4.9.8 agent stamps ``agent_version": "4.9.8"`` and
        ``release_version": "0.8.0"``. The detector must read the release
        field first (never the bogus "v4.9.8") and the compat matrix must
        classify the resulting v0.8.0 tag as compatible."""
        mj = {
            "agent_version": "4.9.8",
            "release_version": "0.8.0",
            "_vibe_session_metadata": {},
            "model": {"name": "Agriculture", "version": "v1_ecm", "domains": []},
        }
        assert ac.detect_tag_from_model_json(mj) == "v0.8.0"
        assert ac.classify_tag("v0.8.0") == "compatible"


# ---------------------------------------------------------------------------
# Notebook version-marker parser (F2 regression — v0.6.9+ uses
# `__AGENT_VERSION__` with leading and trailing dunders, which the original
# regex `(?:__version__|AGENT_VERSION)` did not match. The deployed v0.7.0
# notebook contains `__AGENT_VERSION__ = "0.7.0"` and was reported as
# "no marker" by the App's check-notebook endpoint.)
# ---------------------------------------------------------------------------


class TestNotebookVersionParser:
    """Regression suite for `parse_version_from_notebook` (lifted out of
    `_detect_notebook_version` so it's unit-testable without a workspace
    client). Both the post-save preflight and the on-load check-notebook
    endpoint use this helper, so a single regression here pins the contract
    for both paths."""

    def _parser(self):
        from vibe_modeling.backend.routes._helpers import (
            parse_version_from_notebook,
        )
        return parse_version_from_notebook

    def test_detect_tag_recognises_double_underscore_AGENT_VERSION(self):
        """v0.6.9+ uses ``__AGENT_VERSION__ = "0.7.0"`` — must be recognised."""
        parser = self._parser()
        notebook_source = '__AGENT_VERSION__ = "0.7.0"  # comment'
        assert parser(notebook_source) == "v0.7.0"

    def test_detect_tag_recognises_real_v070_first_cell(self):
        """The actual first cell of the deployed v0.7.0 notebook."""
        parser = self._parser()
        cell = '__AGENT_VERSION__ = "0.7.0"  # alias=agent-version-global'
        assert parser(cell) == "v0.7.0"

    def test_detect_tag_recognises_legacy_dunder_version(self):
        """Pre-v0.6.9 notebooks used ``__version__`` — must still work."""
        parser = self._parser()
        assert parser('__version__ = "0.5.8"') == "v0.5.8"

    def test_detect_tag_recognises_bare_AGENT_VERSION(self):
        """Notebooks may also use ``AGENT_VERSION`` (no dunders)."""
        parser = self._parser()
        assert parser('AGENT_VERSION = "0.6.0"') == "v0.6.0"

    def test_detect_tag_strips_leading_v_inside_quotes(self):
        """If the notebook embeds ``"v0.7.0"`` (with prefix), the canonical
        return is still ``"v0.7.0"`` — not ``"vv0.7.0"``."""
        parser = self._parser()
        assert parser('__AGENT_VERSION__ = "v0.7.0"') == "v0.7.0"

    def test_detect_tag_returns_none_when_no_marker(self):
        parser = self._parser()
        assert parser("# just a comment\nimport os\n") is None

    def test_detect_tag_returns_none_for_empty_source(self):
        parser = self._parser()
        assert parser("") is None
        assert parser(None) is None  # type: ignore[arg-type]

    def test_detect_tag_ignores_unrelated_assignments(self):
        """A variable like ``NOT_AGENT_VERSION`` must not trigger a match."""
        parser = self._parser()
        assert parser('NOT_AGENT_VERSION = "9.9.9"') is None

    def test_detect_tag_ignores_commented_marker(self):
        """A leading ``#`` should disqualify the line — the regex requires
        the assignment at the start of the line modulo whitespace."""
        parser = self._parser()
        assert parser('#__version__ = "0.7.0"') is None

    def test_detect_tag_finds_marker_among_other_lines(self):
        """The marker is typically the first cell; it can also be buried in
        a multi-line notebook source export."""
        parser = self._parser()
        source = (
            "import json\n"
            'BUSINESS_NAME = "test"\n'
            '__AGENT_VERSION__ = "0.7.0"\n'
            "domains = []\n"
        )
        assert parser(source) == "v0.7.0"


# ---------------------------------------------------------------------------
# Version provenance extraction (ModelVersion.agent_version/release_version)
# ---------------------------------------------------------------------------


class TestExtractVersionProvenance:
    """`extract_version_provenance` pulls the agent-logic counter verbatim and
    the release identity (via detect_tag) with the leading `v` dropped."""

    def test_4_9_8_envelope(self):
        env = {"agent_version": "4.9.8", "release_version": "0.8.0", "type": "business"}
        assert ac.extract_version_provenance(env) == ("4.9.8", "0.8.0")

    def test_pre_0_8_0_only_agent_version(self):
        # Old exports stamped the release semver into agent_version; detect_tag
        # falls back to it, so both columns resolve to the same value.
        env = {"agent_version": "0.7.7"}
        assert ac.extract_version_provenance(env) == ("0.7.7", "0.7.7")

    def test_release_version_from_nested_metadata(self):
        env = {"_vibe_session_metadata": {"agent_version": "4.9.8", "release_version": "0.8.0"}}
        assert ac.extract_version_provenance(env) == ("4.9.8", "0.8.0")

    def test_empty_envelope_is_none(self):
        assert ac.extract_version_provenance({}) == (None, None)

    def test_non_dict_is_none(self):
        assert ac.extract_version_provenance(None) == (None, None)
        assert ac.extract_version_provenance("nope") == (None, None)
