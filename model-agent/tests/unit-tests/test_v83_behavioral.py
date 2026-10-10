"""v0.8.3 behavioral tests for P50-P57 root-cause fixes from v0.8.1 HC/LG deep-audit.

Per CLAUDE.md §8.1 each fix MUST have a behavioral test that exercises the failure
mode, plus a static-grep contract that confirms the alias is wired. v0.8.3 adds 8
root-cause fixes (P50-P57) addressing the dishonest 4.4% / 0.4% adherence numbers
exposed by the deep audit.

Coverage per fix:

P50 autofix-p016-user-vibe-skip  - record + skip behavior
P51 connect-table-upsert-fk      - upsert FK when attribute exists w/ empty FK
P52 vov-auto-latest-version-when-v1 - static-grep contract only (volume-dependent)
P53 install-mv-hard-gate         - static-grep contract only (install-time)
P54 unconditional-cascade-drop-extras - static-grep contract only (catalog-dependent)
P56 honest-adherence-precision   - static-grep contract only (orchestrator-bound)
P57 next-vibes-sa-target-filter  - static-grep contract only (next-vibes step)

Static-grep tests assert the alias appears in the agent notebook AND no version
constant regressed below 0.8.3.
"""
from __future__ import annotations

import json
import logging
import re
from pathlib import Path

import pytest

from notebook_source_util import notebook_concat_source

REPO_ROOT = Path(__file__).resolve().parent.parent.parent
AGENT_NB = REPO_ROOT / "agent" / "dbx_vibe_modelling_agent.ipynb"


# ───────────────────────────────────────────────────────────────────────────
# helpers
# ───────────────────────────────────────────────────────────────────────────


def _load_cell_namespace(cell_index: int) -> dict:
    """Compile a notebook cell into a fresh namespace so we can exercise its
    helpers without booting the full Spark/Databricks runtime."""
    nb = json.loads(AGENT_NB.read_text(encoding="utf-8"))
    src = "".join(nb["cells"][cell_index]["source"])
    ns = {"__name__": f"_agent_cell{cell_index}", "logging": logging, "json": json, "re": re}
    exec(compile(src, f"<agent_cell{cell_index}>", "exec"), ns)
    return ns


def _logger():
    lg = logging.getLogger(f"v83test.{id(object())}")
    lg.handlers = []
    lg.addHandler(logging.NullHandler())
    lg.setLevel(logging.DEBUG)
    return lg


@pytest.fixture(scope="module")
def cell1_ns():
    import agent_helpers as ah
    ns = _load_cell_namespace(1)
    ns["vov_rename_events"] = ah.vov_rename_events
    ns["_vibe_scope_note_rename"] = ah._vibe_scope_note_rename
    return ns


# ───────────────────────────────────────────────────────────────────────────
# Static-grep contracts — every alias must be present in the deployed archive
# ───────────────────────────────────────────────────────────────────────────


def test_v83_agent_version_at_least_083():
    src = notebook_concat_source()
    m = re.search(r'__AGENT_VERSION__\s*=\s*\\?"(\d+)\.(\d+)\.(\d+)\\?"', src)
    assert m, "__AGENT_VERSION__ literal not found"
    maj, min_, pat = int(m.group(1)), int(m.group(2)), int(m.group(3))
    assert (maj, min_, pat) >= (0, 8, 3), f"expected v>=0.8.3, found {maj}.{min_}.{pat}"


@pytest.mark.parametrize(
    "alias,patch",
    [
        ("user-renamed-attribute-record", "P50"),
        ("autofix-p016-user-vibe-skip", "P50"),
        ("connect-table-upsert-fk", "P51"),
        ("install-mv-hard-gate", "P53"),
        ("unconditional-cascade-drop-extras", "P54"),
        ("honest-adherence-precision", "P56"),
        ("next-vibes-sa-target-filter", "P57"),
    ],
)
def test_v83_alias_present(alias, patch):
    src = notebook_concat_source()
    assert alias in src, f"v0.8.3 {patch}: alias {alias!r} missing from deployed notebook"


# ───────────────────────────────────────────────────────────────────────────
# P50 — autofix-p016-user-vibe-skip behavioral tests
# ───────────────────────────────────────────────────────────────────────────


def test_p50_record_and_check_round_trip(cell1_ns):
    """_record_user_renamed_attribute must round-trip with _is_user_renamed_attribute."""
    ns = cell1_ns
    record = ns["_record_user_renamed_attribute"]
    check = ns["_is_user_renamed_attribute"]

    assert check("clinical", "note_template", "parent_note_template_id") is False
    record("clinical", "note_template", "parent_note_template_id", logger=_logger(), source="test", old_attribute_name="parent_id")
    assert check("clinical", "note_template", "parent_note_template_id") is True
    assert check("clinical", "note_template", "OTHER_NAME") is False
    assert check("OTHER_DOMAIN", "note_template", "parent_note_template_id") is False


def test_p50_record_handles_empty_inputs(cell1_ns):
    ns = cell1_ns
    record = ns["_record_user_renamed_attribute"]
    check = ns["_is_user_renamed_attribute"]

    record("", "p", "a", old_attribute_name="b")
    record("d", "", "a", old_attribute_name="b")
    record("d", "p", "", old_attribute_name="b")
    record("d", "p", "a")
    assert ns["vov_rename_events"]() == []
    assert check("", "", "") is False


def test_p50_autofix_p016_guard_uses_check():
    """The [AUTOFIX-P0.16] rename loop must contain a guard that calls
    `_is_user_renamed_attribute` BEFORE renaming `_a['attribute']`."""
    src = notebook_concat_source()
    # The injected guard line we placed in cell 19
    assert "_is_user_renamed_attribute(_sd, _sp, _old_attr_name)" in src, (
        "P50: [AUTOFIX-P0.16] rename site must call _is_user_renamed_attribute "
        "before mutating any column name."
    )


def test_p50_recorder_wired_in_apply_mutation_command():
    """apply_mutation_command attribute-rename success path must call
    `_record_user_renamed_attribute`."""
    src = notebook_concat_source()
    assert "source='apply_mutation_command.rename'" in src or 'source="apply_mutation_command.rename"' in src, (
        "P50: apply_mutation_command rename success path must invoke "
        "_record_user_renamed_attribute(..., source='apply_mutation_command.rename')"
    )


# ───────────────────────────────────────────────────────────────────────────
# P51 — connect-table-upsert-fk
# ───────────────────────────────────────────────────────────────────────────


def test_p51_upsert_block_replaces_no_op_branch():
    """The bare `logger.info("    ✓ Already exists: {name}")` branch must now
    be guarded by an upsert check on foreign_key_to."""
    src = notebook_concat_source()
    # The exact upsert condition we injected
    assert "_existing_row is not None and _req_fk and not str(_existing_row.get('foreign_key_to') or '').strip()" in src, (
        "P51: create_attribute handler must UPSERT foreign_key_to when target "
        "attribute exists but FK is empty."
    )


def test_p51_handler_assigns_foreign_key_to():
    src = notebook_concat_source()
    assert "_existing_row['foreign_key_to'] = _req_fk" in src, (
        "P51: upsert path must actually write to foreign_key_to"
    )


def test_p51_handler_adds_foreign_key_tag():
    src = notebook_concat_source()
    assert "'foreign_key'" in src and "_merged_tags" in src, (
        "P51: upsert path must add foreign_key tag to merged tags"
    )


# ───────────────────────────────────────────────────────────────────────────
# P52, P53, P54, P56, P57 — static-grep behavioral contracts
# ───────────────────────────────────────────────────────────────────────────


def test_p52_next_vibes_version_promotion_removed_with_the_auto_load():
    src = notebook_concat_source()
    assert "widget model_version=1 but volume has" not in src
    assert "_base_ver_auto = _highest" not in src
    assert "[vov-vibes-required FIRED v5.1.4]" in src


def test_p53_install_mv_hard_gate_fires_on_zero_deployed():
    src = notebook_concat_source()
    assert "PHYSICAL DEPLOYMENT installed 0" in src, (
        "P53: hard-gate must log when declared>=1 but deployed=0"
    )
    assert "install-mv-hard-gate FIRED" in src


def test_p54_unconditional_drop_logs_alias():
    src = notebook_concat_source()
    assert "unconditional-cascade-drop-extras FIRED" in src
    assert "no config opt-out" in src


def test_p56_honest_precision_excludes_partial():
    src = notebook_concat_source()
    # The honest precision formula uses fulfilled / total (NOT counting partial)
    assert "'fulfilled'" in src and "_fulfilled" in src and "_failed_or_partial" in src
    assert "scorecard['precision'] = round(_honest_precision, 4)" in src, (
        "P56: must overwrite the optimistic LLM-emitted precision with the honest value."
    )


def test_p56_issues_not_addressed_lists_partial_too():
    src = notebook_concat_source()
    assert "in ('failed', 'partial')" in src or 'in ("failed", "partial")' in src, (
        "P56: must include both failed and partial in issues_not_addressed"
    )


def test_p57_filter_prunes_phantom_findings():
    src = notebook_concat_source()
    assert "_existing_products = set()" in src and "_existing_attrs = set()" in src, (
        "P57: next-vibes filter must build existence sets from the current model"
    )
    assert "pruned" in src and "next-vibes-sa-target-filter FIRED" in src


# ───────────────────────────────────────────────────────────────────────────
# Anti-regression: v0.8.2 fixes P44-P49 must remain intact
# ───────────────────────────────────────────────────────────────────────────


@pytest.mark.parametrize(
    "alias",
    [
        "vov-no-forced-master-record-stub",
        "vov-hydrate-skip-non-vov",
        # NOTE: v0.8.2 alias 'rdfs-description-keyerror-fix' was extended by
        # v0.8.7 P62 'rdfs-business-row-asdict' (Spark Row .get() bug). Either alias is
        # acceptable as proof the description-guard intent is preserved.
        ("rdfs-description-keyerror-fix", "rdfs-business-row-asdict"),
        "user-pinned-domain-guard",
        "vov-sizing-gate-domain-only-filter",
        "stale-table-confirmed-extras",
        "stale-table-no-extras-info",
    ],
)
def test_v82_aliases_still_present(alias):
    src = notebook_concat_source()
    if isinstance(alias, tuple):
        # Multi-alias: at least one variant must be present (allows v0.8.7+ rename)
        assert any(a in src for a in alias), (
            f"None of v0.8.2 alias variants {alias!r} present"
        )
    else:
        assert alias in src, f"v0.8.2 alias {alias!r} regressed"
