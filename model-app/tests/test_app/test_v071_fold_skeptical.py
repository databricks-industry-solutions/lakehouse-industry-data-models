"""Skeptical-tester pass for the App v0.4.0 fold of agent v0.7.1.

This file is written from `SPEC.md` ALONE, against
the public API surface of the modules under test. No mocking, no patching —
imports run against the live module state of the worktree, the way an
operator would.

Purpose: every assertion in here must FAIL on the pre-fold codebase (which
pinned v0.6.0) and PASS on the developer's final fold. If any assertion is
non-discriminating between the two states, it is a bug in this test.

Spec coverage map (SPEC §"Skeptical-tester deliverable"):

- File presence : `TestVendoredAgentFiles`
- VERSIONS.json shape : `TestVersionsJson`
- agent_compat verdict + helpers : `TestAgentCompatVerdicts`
- KNOWN_UPSTREAM_CHANGES table shape : `TestKnownUpstreamChanges`
- core._defaults pin : `TestSupportedAgentVersionPin`
- routes.config no-marker constant : `TestNoMarkerTagsConstant`
- model_sync token recognition : `TestNextVibesAutoRecoveryTokens`
"""

from __future__ import annotations

import json
import os
import sys

# Match the conftest path-injection idiom so the package imports resolve
# whether or not pytest is launched from the worktree root.
sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "..", "src", "app", "src"))
sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", ".."))


# Worktree-rooted path to the vendored agent directory — used by the
# file-presence and VERSIONS.json tests so they hit disk, not import state.
_VENDORED_AGENT_DIR = os.path.normpath(
    os.path.join(
        os.path.dirname(__file__),
        "..",
        "..",
        "src",
        "app",
        "vendored",
        "agent",
    )
)


# ---------------------------------------------------------------------------
# Vendored notebook files on disk
# ---------------------------------------------------------------------------


class TestVendoredAgentFiles:
    """SPEC §3, §2: the v5.3.3 ipynb ships, the v0.6.0 ipynb is gone."""

    def test_v533_notebook_present(self):
        path = os.path.join(_VENDORED_AGENT_DIR, "vibe_modelling_agent_v5.3.3.ipynb")
        assert os.path.isfile(path), (
            f"v5.3.3 notebook must be vendored at {path!r} — the new pinned "
            f"tag depends on this file existing on disk."
        )
        # Assert the 4.9.9 file is absent
        old_path = os.path.join(_VENDORED_AGENT_DIR, "vibe_modelling_agent_v4.9.9.ipynb")
        assert not os.path.exists(old_path), (
            f"v4.9.9 notebook must be removed but is still at {old_path!r}."
        )
        # Assert VERSIONS.json.agent_source.notebook_sha256 matches the file
        versions_path = os.path.join(_VENDORED_AGENT_DIR, "VERSIONS.json")
        with open(versions_path) as f:
            versions_data = json.load(f)
        expected_sha256 = versions_data.get("agent_source", {}).get("notebook_sha256")
        assert expected_sha256, "VERSIONS.json must have agent_source.notebook_sha256"
        # Verify the file's actual sha256
        import hashlib
        with open(path, "rb") as f:
            file_sha256 = hashlib.sha256(f.read()).hexdigest()
        assert file_sha256 == expected_sha256, (
            f"File sha256 {file_sha256!r} does not match VERSIONS.json agent_source.notebook_sha256 {expected_sha256!r}."
        )

    def test_v060_notebook_absent(self):
        path = os.path.join(_VENDORED_AGENT_DIR, "vibe_modelling_agent_v0.6.0.ipynb")
        assert not os.path.exists(path), (
            f"v0.6.0 notebook must be deleted (SPEC §2: drop v0.6.0 entirely) "
            f"but is still on disk at {path!r}."
        )


# ---------------------------------------------------------------------------
# VERSIONS.json
# ---------------------------------------------------------------------------


class TestVersionsJson:
    """SPEC §3: pinned_tag flips to v0.8.0, v0.6.0 is removed from supported_tags."""

    def _load(self) -> dict:
        path = os.path.join(_VENDORED_AGENT_DIR, "VERSIONS.json")
        assert os.path.isfile(path), f"VERSIONS.json missing at {path!r}"
        with open(path, "r", encoding="utf-8") as f:
            return json.load(f)

    def test_pinned_tag_is_v080(self):
        data = self._load()
        assert data.get("pinned_tag") == "v0.8.0", (
            f"VERSIONS.json pinned_tag must be 'v0.8.0' (was {data.get('pinned_tag')!r}). "
            f"This is the load-bearing source of truth for the App's pin."
        )

    def test_supported_tags_contains_v077(self):
        data = self._load()
        tags = data.get("supported_tags") or []
        assert "v0.7.7" in tags, (
            f"VERSIONS.json supported_tags must include 'v0.7.7' — got {tags!r}."
        )

    def test_supported_tags_does_not_contain_v060(self):
        data = self._load()
        tags = data.get("supported_tags") or []
        assert "v0.6.0" not in tags, (
            f"v0.6.0 must be dropped from supported_tags (SPEC §3) — got {tags!r}."
        )


# ---------------------------------------------------------------------------
# agent_compat module-level verdicts and helpers
# ---------------------------------------------------------------------------


class TestAgentCompatVerdicts:
    """SPEC §4: classify_tag, latest_supported_tag, latest_known_upstream_tag."""

    def test_classify_v071_compatible(self):
        from vibe_modeling.backend import agent_compat as ac
        assert ac.classify_tag("v0.7.1") == "compatible", (
            "v0.7.1 must be in _COMPAT_MATRIX as 'compatible' — it's the new pin."
        )

    def test_classify_v060_unknown(self):
        from vibe_modeling.backend import agent_compat as ac
        assert ac.classify_tag("v0.6.0") == "unknown", (
            "v0.6.0 must be removed from _COMPAT_MATRIX (SPEC §4). "
            "Any model.json from v0.6.0 should now classify as 'unknown'."
        )

    def test_latest_supported_tag_is_v080(self):
        from vibe_modeling.backend import agent_compat as ac
        assert ac.latest_supported_tag() == "v0.8.0", (
            "_LATEST_SUPPORTED_TAG advances to 'v0.8.0' — the new pin "
            "and the latest tag in the compat matrix."
        )

    def test_latest_known_upstream_tag_is_v080(self):
        from vibe_modeling.backend import agent_compat as ac
        assert ac.latest_known_upstream_tag() == "v0.8.0", (
            "LATEST_KNOWN_UPSTREAM_TAG advances to 'v0.8.0' so the "
            "release-monitor card reflects the current pin; no newer "
            "upstream tag is known."
        )


# ---------------------------------------------------------------------------
# KNOWN_UPSTREAM_CHANGES table
# ---------------------------------------------------------------------------


class TestKnownUpstreamChanges:
    """SPEC §4: KNOWN_UPSTREAM_CHANGES['v0.7.1'] is non-empty + well-formed,
    and the v0.6.0 entry is removed."""

    def test_v071_entry_exists_and_non_empty(self):
        from vibe_modeling.backend import agent_compat as ac
        assert "v0.7.1" in ac.KNOWN_UPSTREAM_CHANGES, (
            "KNOWN_UPSTREAM_CHANGES must contain a 'v0.7.1' entry (SPEC §4)."
        )
        entries = ac.KNOWN_UPSTREAM_CHANGES["v0.7.1"]
        assert isinstance(entries, list) and len(entries) > 0, (
            f"KNOWN_UPSTREAM_CHANGES['v0.7.1'] must be a non-empty list — got {entries!r}."
        )

    def test_v071_entries_have_required_keys(self):
        from vibe_modeling.backend import agent_compat as ac
        entries = ac.KNOWN_UPSTREAM_CHANGES["v0.7.1"]
        for i, entry in enumerate(entries):
            assert isinstance(entry, dict), (
                f"KNOWN_UPSTREAM_CHANGES['v0.7.1'][{i}] must be a dict — got {type(entry).__name__}."
            )
            for key in ("severity", "area", "summary"):
                assert key in entry, (
                    f"KNOWN_UPSTREAM_CHANGES['v0.7.1'][{i}] missing {key!r} — "
                    f"the /api/config/agent-compat endpoint reads these fields verbatim."
                )

    def test_v071_mentions_shrink_headline_fix(self):
        """SPEC §4 calls out shrink-resilience as the headline fix; at least
        one summary must mention 'shrink' so an operator reading the Settings
        card sees why we bumped past v0.7.0."""
        from vibe_modeling.backend import agent_compat as ac
        entries = ac.KNOWN_UPSTREAM_CHANGES["v0.7.1"]
        summaries = [str(e.get("summary", "")) for e in entries]
        assert any("shrink" in s.lower() for s in summaries), (
            f"At least one v0.7.1 summary must mention 'shrink' (the headline "
            f"SHRINK-NEW-SILO auto-recovery fix) — got summaries: {summaries!r}."
        )

    def test_v060_entry_removed(self):
        from vibe_modeling.backend import agent_compat as ac
        assert "v0.6.0" not in ac.KNOWN_UPSTREAM_CHANGES, (
            "KNOWN_UPSTREAM_CHANGES['v0.6.0'] must be removed (SPEC §4 — drop v0.6.0 entirely)."
        )


# ---------------------------------------------------------------------------
# core._defaults pinned constant
# ---------------------------------------------------------------------------


class TestSupportedAgentVersionPin:
    """SPEC §5: SUPPORTED_AGENT_VERSION flips to 'v0.8.0'."""

    def test_supported_agent_version_is_v080(self):
        from vibe_modeling.backend.core._defaults import SUPPORTED_AGENT_VERSION
        assert SUPPORTED_AGENT_VERSION == "v0.8.0", (
            f"SUPPORTED_AGENT_VERSION must be 'v0.8.0' — got {SUPPORTED_AGENT_VERSION!r}. "
            f"This constant is the release identity every importer records and "
            f"displays, and the value the notebook-version preflight gates on."
        )


# ---------------------------------------------------------------------------
# routes/config _NO_MARKER_TAGS
# ---------------------------------------------------------------------------


class TestNoMarkerTagsConstant:
    """SPEC §6: _NO_MARKER_TAGS is empty (or the constant is removed). v0.7.1
    stamps __AGENT_VERSION__ so the no-marker fallback isn't needed.

    Either shape is valid per the spec — only the *behaviour* must hold:
    the constant, if present, must not contain v0.6.0 or any other tag.
    """

    def test_no_marker_tags_absent_or_empty(self):
        from vibe_modeling.backend.routes import config as config_route
        if not hasattr(config_route, "_NO_MARKER_TAGS"):
            # SPEC §6 explicitly allows deletion if no other consumer refs it.
            return
        value = config_route._NO_MARKER_TAGS
        # Accept set / frozenset — either form is consistent with the spec.
        assert len(value) == 0, (
            f"_NO_MARKER_TAGS must be empty (or the constant deleted) per SPEC §6. "
            f"Got {value!r}. v0.7.1 has an embedded __AGENT_VERSION__ marker so the "
            f"no-marker fallback is no longer needed."
        )

    def test_no_marker_tags_does_not_contain_v060(self):
        """Belt-and-suspenders: even if a future change re-adds the constant,
        v0.6.0 must never reappear there."""
        from vibe_modeling.backend.routes import config as config_route
        value = getattr(config_route, "_NO_MARKER_TAGS", frozenset())
        assert "v0.6.0" not in value, (
            f"_NO_MARKER_TAGS must not contain 'v0.6.0' (SPEC §6 — drop v0.6.0). "
            f"Got {value!r}."
        )


# ---------------------------------------------------------------------------
# model_sync._convert_next_vibes_txt_to_payload — auto-recovery flag tokens
# ---------------------------------------------------------------------------


_AUTO_RECOVERY_TOKENS = (
    "SHRINK_ORPHAN_DROPPED",
    "SHRINK_FK_DENSEST_FALLBACK_USED",
    "SHRINK_CASCADE_AUTO_RECOVERED",
    "ENSEMBLE_SINGLESHOT_FALLBACK_USED",
)


class TestNextVibesAutoRecoveryTokensDropped:
    """The structured sync-time parser deliberately does NOT surface the four
    v0.7.1 auto-recovery flag tokens — they are operational telemetry, not
    actionable next-vibe findings (user-confirmed drop). Only static-analysis
    / PRIORITY / other-known-issue findings become structured inputs.
    """

    def _parse(self, text: str) -> dict:
        from vibe_modeling.backend.model_sync import _next_vibes_payload_from_txt
        return _next_vibes_payload_from_txt(text)

    def test_bare_token_yields_no_findings(self):
        for token in _AUTO_RECOVERY_TOKENS:
            payload = self._parse(f"{token} some trailing description")
            assert payload["_next_vibe_metadata"]["findings"] == [], (
                f"{token} must not become a structured finding"
            )

    def test_tokens_dropped_but_priorities_kept(self):
        text = (
            "**Model Quality Score: 72/100**\n\n"
            "**PRIORITY 1 — remove_fk: customer.profile** — drop fulfillment_location_id\n"
            "SHRINK_ORPHAN_DROPPED removed dangling product\n"
            "SHRINK_FK_DENSEST_FALLBACK_USED rerouted via densest FK\n"
        )
        payload = self._parse(text)
        findings = payload["_next_vibe_metadata"]["findings"]
        # Only the PRIORITY finding survives; the two tokens are dropped.
        assert len(findings) == 1
        assert findings[0]["category"] == "priority_remediation"
        assert findings[0]["target"] == "customer.profile"
        serialized = repr(payload).lower()
        for token in ("shrink_orphan_dropped", "shrink_fk_densest_fallback_used"):
            assert token not in serialized
