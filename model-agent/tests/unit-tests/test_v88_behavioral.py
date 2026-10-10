"""v0.8.8 behavioral tests — convert finalize hard-gates to soft-warn + record-to-next-vibes.

Patches under test:
  P63 fmfl-final-sanitize-drop-orphans
  P64 vov-validator-reject-reserved-domain-moves
  P66 attr-gen-timeout-raise (1800 -> 3600)
  P68 vov-sizing-soft-warn-record-to-next-vibes  (USER DIRECTIVE: never fail on vibe non-adherence)
  P69 next-vibes-collector-soft-warn
  P70 vov-finalize-auto-seed-missing-domains
  P71 vov-score-fail-loud-soft-convert
"""
from __future__ import annotations

import json
import re
from pathlib import Path

import pytest

from notebook_source_util import notebook_concat_source

AGENT_NB = Path(__file__).resolve().parents[2] / "agent" / "dbx_vibe_modelling_agent.ipynb"
assert AGENT_NB.exists(), f"agent notebook not found: {AGENT_NB}"


def _agent_source() -> str:
    nb = json.loads(AGENT_NB.read_text(encoding="utf-8"))
    parts = []
    for cell in nb.get("cells", []):
        if cell.get("cell_type") != "code":
            continue
        src = cell.get("source", "")
        if isinstance(src, list):
            parts.append("".join(src))
        else:
            parts.append(src)
    return "\n\n".join(parts)


def _cell_source(idx: int) -> str:
    nb = json.loads(AGENT_NB.read_text(encoding="utf-8"))
    src = nb["cells"][idx]["source"]
    return "".join(src) if isinstance(src, list) else src


@pytest.fixture(scope="module")
def agent_src() -> str:
    return _agent_source()


# ---------------------------------------------------------------------------
# Version guard
# ---------------------------------------------------------------------------
def test_agent_version_is_at_least_088(agent_src: str):
    m = re.search(r'__AGENT_VERSION__\s*=\s*"([^"]+)"', agent_src)
    assert m, "could not find __AGENT_VERSION__"
    parts = [int(x) for x in m.group(1).split(".")]
    assert parts >= [0, 8, 8], f"agent version {m.group(1)} < 0.8.8"


# ---------------------------------------------------------------------------
# P63: fmfl-final-sanitize-drop-orphans
# ---------------------------------------------------------------------------
def test_p63_drop_orphans_alias_present(agent_src: str):
    assert "fmfl-final-sanitize-drop-orphans FIRED" in agent_src, (
        "P63 alias not in deployed agent source"
    )


def test_p63_branches_on_fk_shape(agent_src: str):
    """P63 must DROP only FK-shaped columns (_id/_fk/_ref/_key); KEEP_AS_IS others."""
    src = _cell_source(13)
    # The DROP path must reference fk-shape detection AND a "DROP" decision
    assert "_p63_is_fk_shape" in src, "P63 must compute _p63_is_fk_shape"
    assert 'endswith(s) for s in ("_id", "_fk", "_ref", "_key")' in src, (
        "P63 must enumerate FK suffixes"
    )
    assert 'dec["decision"] = "DROP"' in src, "P63 must produce DROP decision"
    # Must NOT drop columns that are own PK
    assert "_p63_is_own_pk" in src, "P63 must guard against dropping own-PK columns"


# ---------------------------------------------------------------------------
# P64: vov-validator-reject-reserved-domain-moves
# ---------------------------------------------------------------------------
def test_p64_alias_present(agent_src: str):
    assert "vov-reject-reserved-domain-moves FIRED" in agent_src


def test_p64_blocklist_includes_known_bad_names(agent_src: str):
    """LG v87 had domains 'duplicate', 'ssot', 'ip_asset' — blocklist must include these."""
    src = _cell_source(15)
    for bad in ("duplicate", "ssot", "shared", "reference", "misc", "other"):
        assert f"'{bad}'" in src, f"P64 blocklist missing {bad!r}"


def test_p64_user_vibed_new_carveout(agent_src: str):
    """If a reserved name IS user-vibed-new, do NOT reject (user's directive overrides)."""
    src = _cell_source(15)
    assert "_p64_user_new" in src, "P64 must read _vov_user_new_entities"
    assert "_p64_tgt_lower not in _p64_user_new" in src, (
        "P64 reject must be SKIPPED when target is user-vibed-new"
    )


# ---------------------------------------------------------------------------
# P66: attr-gen-timeout-raise
# ---------------------------------------------------------------------------
def test_p66_default_future_timeout_is_3600(agent_src: str):
    # The new line is in cell 7
    src = _cell_source(7)
    m = re.search(r"_DEFAULT_FUTURE_TIMEOUT\s*=\s*(\d+)", src)
    assert m, "could not find _DEFAULT_FUTURE_TIMEOUT definition"
    assert int(m.group(1)) >= 3600, (
        f"_DEFAULT_FUTURE_TIMEOUT={m.group(1)} too low; must be >= 3600 (P66)"
    )


def test_p66_default_pool_timeout_raised(agent_src: str):
    src = _cell_source(7)
    m = re.search(r"_DEFAULT_POOL_TIMEOUT\s*=\s*(\d+)", src)
    assert m, "could not find _DEFAULT_POOL_TIMEOUT"
    assert int(m.group(1)) >= 5400, (
        f"_DEFAULT_POOL_TIMEOUT={m.group(1)} too low; should grow with future timeout"
    )


def test_p66_alias_present(agent_src: str):
    assert "attr-gen-timeout-raise FIRED" in agent_src


# ---------------------------------------------------------------------------
# P68: vov-sizing-soft-warn-record-to-next-vibes (USER DIRECTIVE)
# ---------------------------------------------------------------------------
def test_p68_soft_warn_alias_present(agent_src: str):
    assert "vov-sizing-soft-warn-record-to-next-vibes FIRED" in agent_src


def test_p68_no_raise_runtime_in_sizing_gate(agent_src: str):
    """The vov-sizing-hard-gate block must NOT raise RuntimeError anymore."""
    src = _cell_source(21)
    # Locate the sizing-soft-warn alias and surrounding ~80 lines
    idx = src.find("vov-sizing-soft-warn-record-to-next-vibes FIRED")
    assert idx >= 0, "sizing-soft-warn alias missing"
    window = src[max(0, idx - 2000) : idx + 3000]
    # No raise RuntimeError directly inside the soft-warn window
    assert "raise RuntimeError(_msg)" not in window, (
        "P68 violation: sizing-gate window still raises RuntimeError"
    )


def test_p68_records_to_unfulfilled_for_next_vibe(agent_src: str):
    src = _cell_source(21)
    assert '"_unfulfilled_for_next_vibe"' in src
    assert "vov_missing_user_new_domain__" in src, (
        "P68 must use vov_missing_user_new_domain__<name> as unfulfilled id"
    )


# ---------------------------------------------------------------------------
# P69: next-vibes-collector-soft-warn
# ---------------------------------------------------------------------------
def test_p69_alias_present(agent_src: str):
    assert "next-vibes-collector-soft-warn FIRED" in agent_src


def test_p69_assert_no_blocking_does_not_raise(agent_src: str):
    """assert_no_blocking must not raise; must downgrade BLOCKING -> SAFE_IGNORE."""
    src = _cell_source(1)
    # Find the function body
    idx = src.find("def assert_no_blocking(self):")
    assert idx >= 0, "assert_no_blocking missing"
    # Window: from def until the next top-level def at same/lower indent
    body = src[idx : idx + 2500]
    assert "raise RuntimeError" not in body, (
        "P69 violation: assert_no_blocking still contains raise RuntimeError"
    )
    assert 'e["severity"] = "SAFE_IGNORE"' in body, (
        "P69 must downgrade BLOCKING entries to SAFE_IGNORE"
    )


# ---------------------------------------------------------------------------
# P70: vov-finalize-auto-seed-missing-domains
# ---------------------------------------------------------------------------
def test_p70_alias_present(agent_src: str):
    assert "vov-auto-seed-missing-domains FIRED" in agent_src


def test_p70_seeds_stubs_in_widgets_values_domains(agent_src: str):
    src = _cell_source(21)
    assert 'widgets_values.setdefault("domains", []).append(_stub)' in src, (
        "P70 must append stub domain into widgets_values['domains']"
    )
    assert '"auto_seeded": True' in src, "P70 stub must be flagged auto_seeded"


def test_p70_writes_unfulfilled_for_populated_domain(agent_src: str):
    src = _cell_source(21)
    assert "vov_populate_auto_seeded_domain__" in src, (
        "P70 must also record an unfulfilled entry so the next vov populates the stub"
    )


# ---------------------------------------------------------------------------
# P71: vov-score-fail-loud-soft-convert
# ---------------------------------------------------------------------------
def test_p71_alias_present(agent_src: str):
    assert "vov-score-soft-warn-record-to-next-vibes FIRED" in agent_src


def test_p71_no_raise_in_critical_vreq_path(agent_src: str):
    """The old vov-score-fail-loud raise RuntimeError must be removed; window must not raise."""
    src = _cell_source(7)
    idx = src.find("vov-score-soft-warn-record-to-next-vibes FIRED")
    assert idx >= 0, "P71 alias missing"
    window = src[max(0, idx - 200) : idx + 2500]
    assert "raise RuntimeError(_msg)" not in window, (
        "P71 violation: critical-VREQ block still raises RuntimeError"
    )
    # The old alias should be gone or replaced
    assert "vov-score-fail-loud" not in window or "soft-warn" in window


# ---------------------------------------------------------------------------
# Regression: prior-version aliases still present
# ---------------------------------------------------------------------------
@pytest.mark.parametrize(
    "alias",
    [
        # v0.8.4 P58
        "install-vov-handoff-allow-overwrite",
        # v0.8.5 P60
        "p58-relaxed-fallback",
        "install-clash-debug-logger-rescue",
        # v0.8.6 P61
        "install-clash-widget-fallback",
        "install-clash-unconditional-escape",
        # v0.8.7 P62
        "rdfs-business-row-asdict",
        # v0.8.2 P50
        "autofix-p016-user-vibe-skip",
    ],
)
def test_prior_aliases_still_present(alias: str, agent_src: str):
    assert alias in agent_src, f"regression: prior alias missing: {alias!r}"
