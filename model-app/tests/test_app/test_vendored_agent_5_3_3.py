"""Verification tests for the vendored agent 5.3.3.

This file verifies that the bundled 5.3.3 notebook meets the design requirements:
- The notebook's markers are extracted correctly (release 0.8.0, marker 5.3.3)
- The SHA256s recorded in VERSIONS.json match the vendored notebook and rules CSV
- The file resolves correctly via bundled_agent._find_notebook
"""

from __future__ import annotations

import hashlib
import json
import os
import re
from pathlib import Path

import pytest

from vibe_modeling.backend.routes._helpers import parse_identity_from_ipynb
from vibe_modeling.backend.bundled_agent import _find_notebook, resolve_bundled_agent


# The vendored agent directory is at src/app/vendored/agent/ relative to the
# worktree root. We compute it by going up from the test file location.
_TEST_DIR = Path(__file__).parent.resolve()
# From tests/test_app/ → tests/ → tests/../src/app/vendored/agent/
_VENDORED_AGENT_DIR = _TEST_DIR.parent.parent / "src" / "app" / "vendored" / "agent"


class TestVendoredAgent533:
    """Verify the 5.3.3 vendored notebook."""

    def test_notebook_file_exists(self):
        """The v5.3.3 notebook file must be present."""
        path = _VENDORED_AGENT_DIR / "vibe_modelling_agent_v5.3.3.ipynb"
        assert path.is_file(), f"Notebook must exist at {path}"

    def test_parse_identity_from_ipynb(self):
        """The notebook's markers must extract as release 0.8.0, marker 5.3.3."""
        path = _VENDORED_AGENT_DIR / "vibe_modelling_agent_v5.3.3.ipynb"
        content = path.read_text()
        release, marker = parse_identity_from_ipynb(content)
        assert release == "v0.8.0", f"Expected release v0.8.0, got {release}"
        assert marker == "5.3.3", f"Expected marker 5.3.3, got {marker}"

    def test_sha256_matches_versions_json(self):
        """The file's SHA256 must match the value recorded in VERSIONS.json."""
        path = _VENDORED_AGENT_DIR / "vibe_modelling_agent_v5.3.3.ipynb"
        versions_path = _VENDORED_AGENT_DIR / "VERSIONS.json"

        # Read VERSIONS.json
        with open(versions_path) as f:
            versions_data = json.load(f)

        recorded_sha256 = versions_data.get("agent_source", {}).get("notebook_sha256")
        assert recorded_sha256, "VERSIONS.json must have agent_source.notebook_sha256"

        # Compute the file's SHA256
        with open(path, "rb") as f:
            file_sha256 = hashlib.sha256(f.read()).hexdigest()

        assert (
            file_sha256 == recorded_sha256
        ), f"File SHA256 {file_sha256} does not match VERSIONS.json {recorded_sha256}"

    def test_find_notebook_resolves_v533(self):
        """The file must resolve via _find_notebook with the pinned tag v0.8.0."""
        versions_path = _VENDORED_AGENT_DIR / "VERSIONS.json"
        with open(versions_path) as f:
            versions_data = json.load(f)

        pinned_tag = versions_data.get("pinned_tag")
        assert pinned_tag == "v0.8.0", f"Expected pinned_tag v0.8.0, got {pinned_tag}"

        found = _find_notebook(_VENDORED_AGENT_DIR, pinned_tag)
        assert found is not None, f"_find_notebook must find a notebook with tag {pinned_tag}"
        assert (
            found.name == "vibe_modelling_agent_v5.3.3.ipynb"
        ), f"Expected v5.3.3 notebook, got {found.name}"

    def test_resolve_bundled_agent_returns_v533(self):
        """resolve_bundled_agent must return the v5.3.3 bundled agent."""
        agent = resolve_bundled_agent()
        assert agent is not None, "resolve_bundled_agent must return an agent"
        assert (
            agent.file_name == "vibe_modelling_agent_v5.3.3.ipynb"
        ), f"Expected v5.3.3 agent, got {agent.file_name}"
        assert agent.pinned_tag == "v0.8.0", f"Expected pinned_tag v0.8.0, got {agent.pinned_tag}"

    def test_versions_json_has_source_block(self):
        """VERSIONS.json records the upstream repo, commit and hashes of the vendored notebook and rules;
        the hashes are checked against the files, never pinned here."""
        versions_path = _VENDORED_AGENT_DIR / "VERSIONS.json"
        with open(versions_path) as f:
            versions_data = json.load(f)

        source = versions_data.get("agent_source")
        assert source is not None, "VERSIONS.json must have an agent_source block"
        assert re.fullmatch(r"[\w.-]+/[\w.-]+", source.get("repo", "")), source.get("repo")
        assert source.get("notebook_path", "").endswith(".ipynb"), source.get("notebook_path")
        assert re.fullmatch(r"[0-9a-f]{40}", source.get("commit", "")), source.get("commit")
        for key in ("notebook_sha256", "rules_sha256"):
            assert re.fullmatch(r"[0-9a-f]{64}", source.get(key, "")), f"{key}: {source.get(key)!r}"
        rules = _VENDORED_AGENT_DIR / source["rules_file"]
        assert hashlib.sha256(rules.read_bytes()).hexdigest() == source["rules_sha256"]
