"""v0.8.0 public-release-label decoupling — behavioral + static contract.

Context: main was last released at v0.7.7. Internal dev iterated on single-digit
semver to engine build 4.2.5 (~90 monotonic version-floor tests hard-pin the
build up to (4,1,5), so the build constant CANNOT be renumbered down without
gutting them). To give consumers a continuous public line (0.7.7 -> 0.8.0)
without a scary 4.x jump, the PUBLIC release label is carried by a dedicated
__RELEASE_VERSION__ constant and stamped as model.json `release_version`, while
__AGENT_VERSION__ (engine build) advances forward-only (now 4.2.7 for the verifier
lying-scoreboard fixes) — monotonic floors are `>=` so a forward bump satisfies them;
only renumbering DOWN (to 0.8.x) would gut them, which is why the public line is carried
separately by __RELEASE_VERSION__.

This test proves the decoupling is real and wired through the model build path
(not a static-grep tautology per S8.10): it CALLS widgets_flat_to_model and
asserts the produced root dict carries release_version == 0.8.0 with agent_version
kept first. It also asserts every model.json re-stamp path refreshes release_version.
"""
import re
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import conftest  # noqa: F401,E402
import agent_helpers as ah  # noqa: E402

SRC = conftest._extract_source_from_notebook()


def test_release_and_build_constants():
    assert ah.__AGENT_VERSION__ == "5.1.3", (
        f"engine build advances forward-only (now 5.1.3); renumbering DOWN breaks ~90 floor tests; got {ah.__AGENT_VERSION__}"
    )
    assert ah.__RELEASE_VERSION__ == "0.8.0", (
        f"public release label must be 0.8.0 (continues main 0.7.7); got {ah.__RELEASE_VERSION__}"
    )
    assert '__RELEASE_VERSION__ = "0.8.0"' in SRC


def test_agent_version_still_first_code_line():
    # S3a-bis: __AGENT_VERSION__ stays the FIRST non-comment code statement;
    # __RELEASE_VERSION__ rides directly after it, never before.
    code_lines = [
        ln.strip()
        for ln in SRC.splitlines()
        if ln.strip() and not ln.strip().startswith("#")
    ]
    assert code_lines[0].startswith("__AGENT_VERSION__ ="), code_lines[0]
    assert code_lines[1].startswith("__RELEASE_VERSION__ ="), code_lines[1]


def test_model_build_stamps_release_version():
    out = ah.widgets_flat_to_model([], [], [], [])
    keys = list(out.keys())
    assert keys[0] == "agent_version", f"agent_version must remain first key, got {keys}"
    assert out["agent_version"] == "5.1.3"
    assert out["release_version"] == "0.8.0", f"model root must carry release_version 0.8.0, got {out.get('release_version')!r}"


def test_agent_version_override_keeps_release_version():
    # Even when a caller overrides agent_version (roundtrip stamping), the public
    # release label is sourced from __RELEASE_VERSION__, not the override.
    out = ah.widgets_flat_to_model([], [], [], [], agent_version="9.9.9")
    assert out["agent_version"] == "9.9.9"
    assert out["release_version"] == "0.8.0"


def test_all_restamp_paths_refresh_release_version():
    # The three model.json re-stamp paths (_mj_root deploy-copy, _parsed_root
    # source-writeback, _updated_root location-update) must each refresh
    # release_version so a rewritten model.json never keeps a stale/absent label.
    for var in ("_mj_root", "_parsed_root", "_updated_root"):
        assert re.search(rf'{var}\["release_version"\]\s*=\s*__RELEASE_VERSION__', SRC), (
            f"{var} re-stamp path must refresh release_version"
        )
    # Authoritative persisted model.json root builder carries it too.
    assert re.search(r'"release_version":\s*__RELEASE_VERSION__', SRC)
