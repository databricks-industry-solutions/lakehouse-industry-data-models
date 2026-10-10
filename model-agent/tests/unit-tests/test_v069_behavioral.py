"""Behavioral tests for v0.6.9 — global __AGENT_VERSION__ traceability.

The v0.6.9 patch wires a single source-of-truth version constant into the
agent notebook (Cell 1, FIRST line of code) and mirrors it as the FIRST
top-level property of every generated model.json. CLAUDE.md §3a-bis codifies
the rule going forward.

Aliases tested:
  - agent-version-global   (constant + Cell 1 first-line position)
  - agent-version-mirror   (model.json `agent_version` first key + FIRED log)
"""

import json
import re
from pathlib import Path

AGENT = Path(__file__).resolve().parents[2] / "agent" / "dbx_vibe_modelling_agent.ipynb"
README = Path(__file__).resolve().parents[2] / "readme.md"
CLAUDE_MD = Path(__file__).resolve().parents[2] / "CLAUDE.md"

EXPECTED_VERSION_INTRODUCED = "0.6.9"


def _agent_cells():
    with AGENT.open() as f:
        nb = json.load(f)
    return nb.get("cells", [])


def _cell_source(cell):
    src = cell.get("source", "")
    return "".join(src) if isinstance(src, list) else src


def _agent_text():
    return "\n".join(
        _cell_source(c) for c in _agent_cells()
    )


def _first_code_cell_source():
    for c in _agent_cells():
        if c.get("cell_type") == "code":
            s = _cell_source(c)
            if s.strip():
                return s
    raise AssertionError("No non-empty code cell found in agent notebook")


def test_v069_constant_value_matches_expected():
    """The v0.6.9 contract: a single-digit-semver __AGENT_VERSION__ constant
    must exist. The exact value naturally bumps each release (v0.6.9 was the
    introducing version; v0.7.0 onward keep the contract). Any conformant
    single-digit semver passes; pinning to a specific value would force this
    test to break on every release bump, which is not the intent."""
    txt = _agent_text()
    pat = re.compile(r'__AGENT_VERSION__\s*=\s*"([^"]+)"')
    m = pat.search(txt)
    assert m is not None, "__AGENT_VERSION__ constant not found in agent notebook"
    val = m.group(1)
    assert re.fullmatch(r"\d\.\d\.\d", val), (
        f"__AGENT_VERSION__ value '{val}' must be single-digit semver "
        f"(introduced in v{EXPECTED_VERSION_INTRODUCED}, evolves per release)"
    )


def test_v069_constant_is_first_code_line_in_cell1():
    src = _first_code_cell_source()
    lines = [ln for ln in src.splitlines() if ln.strip()]
    code_lines = [ln for ln in lines if not ln.lstrip().startswith("#")]
    assert code_lines, "First code cell has no executable lines"
    first = code_lines[0]
    assert first.startswith("__AGENT_VERSION__"), (
        f"First non-comment statement in Cell 1 must be __AGENT_VERSION__; got: {first!r}"
    )


def test_v069_constant_is_single_digit_semver():
    txt = _agent_text()
    m = re.search(r'__AGENT_VERSION__\s*=\s*"([^"]+)"', txt)
    assert m and re.fullmatch(r"\d\.\d\.\d", m.group(1)), (
        "__AGENT_VERSION__ literal violates §3a single-digit semver"
    )


def test_v069_alias_global_present():
    txt = _agent_text()
    assert "agent-version-global" in txt, "alias 'agent-version-global' missing"


def test_v069_alias_mirror_present():
    txt = _agent_text()
    assert "agent-version-mirror" in txt, "alias 'agent-version-mirror' missing"


def test_v069_fired_marker_present():
    txt = _agent_text()
    assert "[agent-version-mirror FIRED]" in txt, (
        "[agent-version-mirror FIRED] log marker missing"
    )


def test_v069_model_json_root_has_agent_version_first_key():
    txt = _agent_text()
    # agent_version stays the FIRST key; release_version (public label, v0.8.0
    # decoupling) rides directly after it, before model_requirements.
    pat = re.compile(
        r'model_json_root\s*=\s*\{\s*"agent_version"\s*:\s*__AGENT_VERSION__\s*,'
        r'(?:\s*#[^\n]*)?\s*'
        r'(?:"release_version"\s*:\s*__RELEASE_VERSION__\s*,(?:\s*#[^\n]*)?\s*)?'
        r'(?:\*\*\(\{"_vibe_scope"\s*:\s*_vs_facts\}\s*if\s+_vs_facts\s+is\s+not\s+None\s+else\s*\{\}\)\s*,\s*)?'
        r'(?:\*\*\(\{"entity_changes"\s*:\s*_entity_changes\}\s*if\s+_entity_changes\s+is\s+not\s+None\s+else\s*\{\}\)\s*,\s*)?'
        r'(?:\*\*\(\{"input_outcomes"\s*:\s*_vi_outcomes\}\s*if\s+_vi_outcomes\s+is\s+not\s+None\s+else\s*\{\}\)\s*,\s*)?'
        r'(?:"lineage"\s*:\s*_run_lineage\s*,\s*)?'
        r'"model_requirements"',
        re.MULTILINE,
    )
    assert pat.search(txt), (
        "model_json_root dict literal must have 'agent_version' as the FIRST key, "
        "before 'model_requirements'"
    )


def test_v069_metric_view_writeback_refreshes_agent_version():
    txt = _agent_text()
    assert (
        '"agent_version" in _mj_root' in txt
        and '_mj_root["agent_version"] = __AGENT_VERSION__' in txt
        and '_mj_root = {"agent_version": __AGENT_VERSION__, **_mj_root}' in txt
    ), "metric-view writeback path must refresh/prepend agent_version"


def test_v069_install_metric_cleanup_refreshes_agent_version():
    txt = _agent_text()
    assert (
        '"agent_version" in _parsed_root' in txt
        and '_parsed_root["agent_version"] = __AGENT_VERSION__' in txt
        and '_parsed_root = {"agent_version": __AGENT_VERSION__, **_parsed_root}' in txt
    ), "install metric-view cleanup writeback must refresh/prepend agent_version"


def test_v069_install_location_writeback_refreshes_agent_version():
    txt = _agent_text()
    assert (
        '"agent_version" in _updated_root' in txt
        and '_updated_root["agent_version"] = __AGENT_VERSION__' in txt
        and '_updated_root = {"agent_version": __AGENT_VERSION__, **_updated_root}' in txt
    ), "install location writeback must refresh/prepend agent_version"


def test_v069_no_two_digit_semver_in_constant():
    txt = _agent_text()
    bad = re.search(r'__AGENT_VERSION__\s*=\s*"\d+\.\d{2,}', txt)
    assert bad is None, (
        "Two-digit segment in __AGENT_VERSION__ violates §3a single-digit semver"
    )
    bad2 = re.search(r'__AGENT_VERSION__\s*=\s*"\d{2,}\.', txt)
    assert bad2 is None, (
        "Two-digit major segment in __AGENT_VERSION__ violates §3a single-digit semver"
    )


def test_v069_readme_current_version_matches():
    """The readme 'Current version' line is the PUBLIC release label and must
    match __RELEASE_VERSION__ (v0.8.0 decoupling): the public line stays
    continuous (main 0.7.7 -> 0.8.0) while the engine build __AGENT_VERSION__
    iterates independently. model.json carries agent_version (engine build) for
    provenance and release_version (public) for the consumer-facing label."""
    text = README.read_text(encoding="utf-8")
    txt = _agent_text()
    m = re.search(r'__RELEASE_VERSION__\s*=\s*"([^"]+)"', txt)
    assert m is not None, "__RELEASE_VERSION__ constant not found in agent notebook"
    rel_version = m.group(1)
    assert f"Current version: **v{rel_version}**" in text, (
        f"readme.md 'Current version' line must match agent __RELEASE_VERSION__ "
        f"(expected v{rel_version})"
    )


def test_v069_readme_history_row_present():
    """The readme version-history table must have a row for the introducing
    version (v0.6.9) AND for the current version. The introducing-version
    row preserves the historical record; the current-version row proves the
    bump-and-document discipline is honoured."""
    text = README.read_text(encoding="utf-8")
    assert f"| **v{EXPECTED_VERSION_INTRODUCED}** |" in text, (
        f"readme.md must preserve the v{EXPECTED_VERSION_INTRODUCED} history row "
        "(version that introduced the __AGENT_VERSION__ contract)"
    )
    txt = _agent_text()
    m = re.search(r'__RELEASE_VERSION__\s*=\s*"([^"]+)"', txt)
    cur_version = m.group(1) if m else None
    assert cur_version, "__RELEASE_VERSION__ not found"
    assert f"| **v{cur_version}** |" in text, (
        f"readme.md must have a Version-history row for current public release v{cur_version}"
    )


def test_v069_claude_md_documents_rule():
    text = CLAUDE_MD.read_text(encoding="utf-8")
    assert "## 3a-bis. Global `__AGENT_VERSION__` constant" in text, (
        "CLAUDE.md must document §3a-bis __AGENT_VERSION__ rule"
    )
    assert "agent-version-global" in text, (
        "CLAUDE.md §3a-bis must reference agent-version-global alias"
    )


def test_v069_simulated_model_json_serializes_agent_version_first():
    """Simulate the model_json_root assembly and confirm json.dump preserves
    insertion order with agent_version first."""
    cur = _current_agent_version()
    model_json_root = {
        "agent_version": cur,
        "model_requirements": {"business_name": "test"},
        "_vibe_session_metadata": {"status": "test"},
        "model": {"type": "business", "name": "test", "domains": []},
    }
    s = json.dumps(model_json_root, indent=2)
    parsed = json.loads(s)
    keys = list(parsed.keys())
    assert keys[0] == "agent_version", (
        f"agent_version must be the FIRST top-level key; got {keys}"
    )
    assert parsed["agent_version"] == _current_agent_version()


def _current_agent_version():
    """Read __AGENT_VERSION__ value from the agent notebook."""
    txt = _agent_text()
    m = re.search(r'__AGENT_VERSION__\s*=\s*"([^"]+)"', txt)
    assert m, "__AGENT_VERSION__ constant not found in agent notebook"
    return m.group(1)


def test_v069_simulated_rewrite_path_refreshes_stale_agent_version():
    """Simulate the rewrite-path logic that an older model.json gets re-stamped."""
    cur = _current_agent_version()
    stale = {
        "agent_version": "0.6.5",
        "model_requirements": {},
        "model": {},
    }
    if "agent_version" in stale:
        stale["agent_version"] = cur
    else:
        stale = {"agent_version": cur, **stale}
    assert stale["agent_version"] == cur
    keys = list(stale.keys())
    assert keys[0] == "agent_version"


def test_v069_simulated_rewrite_path_prepends_when_missing():
    cur = _current_agent_version()
    legacy = {"model_requirements": {}, "model": {}}
    if "agent_version" in legacy:
        legacy["agent_version"] = cur
    else:
        legacy = {"agent_version": cur, **legacy}
    assert list(legacy.keys())[0] == "agent_version"
    assert legacy["agent_version"] == cur


def test_v069_prior_aliases_preserved():
    """Regression — every v0.6.x alias from prior fixes must still be present."""
    txt = _agent_text()
    prior_aliases = [
        "vibe-version-must-advance",
        "perf-cap-16",
        "perf-llm-throttle-16",
        "perf-mv15-parallel",
        "immutable-early-exit",
        "ssot-stem-autofix",
        "llm-json-recoverable",
        "collision-naming-canonical",
        "fmfl-canonical-target",
        "surgical-mv-preserve",
        "surgical-mv-rewrite",
        "fmfl-auto-coerce-keep",
        "log-append-on-retry",
    ]
    missing = [a for a in prior_aliases if a not in txt]
    assert not missing, f"Prior v0.6.x aliases missing from notebook: {missing}"
