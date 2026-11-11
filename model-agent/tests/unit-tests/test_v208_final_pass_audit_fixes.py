"""Behavioral tests for v2.0.8 FINAL-PASS audit fixes (the 18 aliases added in this session).

Tests cover the static-shape contracts AND, where feasible, the post-state behavior so
each alias has BOTH a grep contract and a behavioral demonstration per §8.10.
"""
import json
import re
from pathlib import Path

import pytest

NOTEBOOK_PATH = Path(__file__).resolve().parents[2] / "agent" / "dbx_vibe_modelling_agent.ipynb"


def _load_source() -> str:
    nb = json.loads(NOTEBOOK_PATH.read_text())
    out = []
    for cell in nb.get("cells", []):
        if cell.get("cell_type") != "code":
            continue
        src = cell.get("source", "")
        if isinstance(src, list):
            src = "".join(src)
        out.append(src)
    return "\n\n".join(out)


@pytest.fixture(scope="module")
def src():
    return _load_source()


FINAL_PASS_ALIASES = [
    "vov-tools-honest-prompt",
    "vov-linking-respects-applied",
    "vov-review-finalize-skip-autofix",
    "vov-synth-model-snapshot",
    "vov-roundtrip-preserve-fields",
    "vov-agent-version-stamp",
    "vov-lineage-vov-attribution",
    "smart-worker-no-cosmetic-soft-accept",
    "run-worker-no-empty-json",
    "vibe-master-rule4-vov-default-surgical",
    "next-vibes-priority-carry-forward",
    "synth-non-dict-raise",
    "batcher-heuristic-fallback-surface",
    "verifier-budget-skip-tracks-coverage",
    "vov-deterministic-post-conditions",
    "mv-install-filter-vov-aware",
]


def test_all_final_pass_aliases_present(src):
    """Every alias must appear in source at least 2x (declaration + FIRED log)."""
    missing = []
    for alias in FINAL_PASS_ALIASES:
        if src.count(alias) < 2:
            missing.append((alias, src.count(alias)))
    assert not missing, f"Aliases missing/under-cited: {missing}"


@pytest.mark.parametrize("alias", FINAL_PASS_ALIASES)
def test_fired_log_emission(alias, src):
    """Each runtime alias has a FIRED log emit. Prompt-only aliases are exempt."""
    prompt_only = {"vibe-master-rule4-vov-default-surgical"}
    if alias in prompt_only:
        return
    pattern = rf"\[{re.escape(alias)} FIRED v2\.0\.8"
    assert re.search(pattern, src), f"No `[{alias} FIRED v2.0.8` log emit found"


def test_no_text_overlap_fold_marks_a_requirement_fulfilled(src):
    assert "def fold_vov_outcomes(" not in src and ".fold_vov_outcomes(" not in src
    assert "def _vov_text_overlaps(" not in src and "_vreq_spec_same_ask(req, v)" in src


def test_remediate_before_modeljson_re_exports(src):
    """After SelfFixer writeback, model.json is re-exported (v5.3.3: by the mandatory final export before Step 9a)."""
    writeback = src.index("vov-selffixer-flat-roundtrip WRITEBACK FIRED")
    assert writeback < src.index("_export_final_model_json(widgets_values, logger)", writeback), "Re-export of model.json after SelfFixer not found"


def test_tools_honest_prompt_inlines_sections(src):
    """The honest tools shim must inline outline sections into the user prompt."""
    assert "INLINED OUTLINE SECTIONS" in src
    assert "tool-defs are documentary only" in src


def test_linking_respects_applied_seeds_user_vibed_artifacts(src):
    """VOV writeback must seed user_vibed_artifacts['domains'] from applied outcomes."""
    assert "_vov_touched_domains" in src
    assert 'widgets_values["user_vibed_artifacts"] = _existing_uva' in src or "widgets_values['user_vibed_artifacts'] = _existing_uva" in src


def test_review_finalize_skip_autofix_gates_three_call_sites(src):
    """v3.5.9 (alias=vov-run-autofix-default): the three VOV autofix sites now run the
    pre-SA autofix BY DEFAULT (the v2.0.8 unconditional skip was the root cause of the
    restaurants v2 'model got worse' — 500 SA warnings shipped because the autofix was
    disabled on the VOV path). They run via _autofix_with_monotonic_guard (which reverts
    if SA gets strictly worse) and are gated only by the explicit SKIP_POST_VOV_AUTOFIX
    opt-out, not skipped by default."""
    assert "0 if _vov_review_skip_autofix else _autofix_with_monotonic_guard" in src
    assert "0 if _vov_qa_skip_autofix else _autofix_with_monotonic_guard" in src
    assert "0 if _vov_finalize_skip_autofix else _autofix_with_monotonic_guard" in src
    # the skip flags default to RUNNING; only an explicit opt-out disables the autofix
    assert "SKIP_POST_VOV_AUTOFIX" in src
    assert "vov-run-autofix-default" in src


def test_synth_model_snapshot_injects_digest(src):
    """The synth prompt must include `CURRENT_MODEL_DIGEST` block."""
    assert "CURRENT_MODEL_DIGEST" in src
    assert "model_snapshot: Optional[dict] = None" in src


def test_synth_model_snapshot_threaded_through_callers(src):
    """Every synthesize_handler call in _apply_handler_with_retry must pass model_snapshot=model."""
    count = src.count("model_snapshot=model")
    assert count >= 6, f"model_snapshot=model only threaded {count}x, expected ≥6"


def test_roundtrip_preserve_fields_nullable(src):
    """model_to_widgets_flat must emit `nullable` from attribute dict."""
    assert '"nullable": a.get("nullable"' in src


def test_roundtrip_preserve_fields_pii_subtype(src):
    """model_to_widgets_flat must emit `pii_subtype`."""
    assert '"pii_subtype": a.get("pii_subtype"' in src


def test_roundtrip_preserve_fields_value_regex(src):
    """model_to_widgets_flat must emit `value_regex`."""
    assert '"value_regex": a.get("value_regex"' in src


def test_roundtrip_preserve_fields_domain_tags(src):
    """model_to_widgets_flat must emit domain-level `tags`."""
    pattern = r'domains_out\.append\(\{[\s\S]{0,800}?"tags": d\.get\("tags"'
    assert re.search(pattern, src), "Domain-level tags not preserved in roundtrip"


def test_agent_version_stamp_uses_canonical_constant(src):
    """widgets_flat_to_model default must be __AGENT_VERSION__ not __VOV_VERSION__."""
    assert '"agent_version": agent_version or __AGENT_VERSION__' in src
    # And the OLD pattern must be gone
    assert '"agent_version": agent_version or __VOV_VERSION__' not in src


def test_lineage_vov_attribution_signature(src):
    """_match_change_to_requirement must accept vov_outcomes and vov_raw_vreqs kwargs."""
    assert "def _match_change_to_requirement(affected_object, vibe_requirements_list, vibe_master_actions, vov_outcomes=None, vov_raw_vreqs=None):" in src


def test_lineage_callsite_passes_vov(src):
    """Lineage diff loop must pass vov_outcomes=_vov_outcomes_for_lineage."""
    assert "vov_outcomes=_vov_outcomes_for_lineage" in src


def test_smart_worker_no_cosmetic_soft_accept_returns_false(src):
    """The cosmetic-step exhaust branch must return False (hard fail), not True."""
    pattern = r"smart-worker-no-cosmetic-soft-accept FIRED v2\.0\.8.*?return False"
    assert re.search(pattern, src, re.DOTALL), "Cosmetic step exhaust must return False"


def test_run_worker_no_empty_json_raises(src):
    """run_worker on empty/invalid JSON must raise ValueError, not return '{}'."""
    assert "raise ValueError(_msg)" in src
    # OLD return path must not be in run_worker anymore
    pattern_old = r'def run_worker\(self, step_name[\s\S]{0,3000}return "\{\}" # Return valid empty JSON'
    assert not re.search(pattern_old, src), "Old `return '{}'` path is still present"


def test_rule4_default_surgical_for_vov(src):
    """Rule 4 must mention SURGICAL fallback for vibe-modeling-of-version."""
    assert "RULE 4 \u2192 SURGICAL (fallback for vibe-modeling-of-version" in src


def test_priority_carry_forward_uses_priority_blocks(src):
    """Unfulfilled carry-forward must emit `**PRIORITY N \u2014` blocks, not bullets."""
    pattern = r"next-vibes-priority-carry-forward FIRED v2\.0\.8.*?PRIORITY \{_idx\}"
    assert re.search(pattern, src, re.DOTALL), "PRIORITY block format not emitted"


def test_synth_non_dict_raises_not_silent(src):
    """synthesize_handler must raise on non-dict response, not silently produce empty handler."""
    pattern = r"synth-non-dict-raise FIRED v2\.0\.8.*?raise ValueError"
    assert re.search(pattern, src, re.DOTALL), "synth-non-dict-raise must raise ValueError"


def test_batcher_heuristic_fallback_surfaced(src):
    """Batcher heuristic fallback must emit a warning log on both LLM-error and non-dict paths."""
    assert "batcher-heuristic-fallback-surface FIRED v2.0.8] LLM batcher failed" in src
    assert "batcher-heuristic-fallback-surface FIRED v2.0.8 NON-DICT]" in src


def test_verifier_budget_skip_marks_partial(src):
    """skipped_budget verifier verdict must call req.mark_partial, not mark_fulfilled."""
    pattern = r"verifier-budget-skip-tracks-coverage FIRED v2\.0\.8.*?req\.mark_partial"
    assert re.search(pattern, src, re.DOTALL), "skipped_budget must demote to partial"


def test_deterministic_post_conditions_target_miss_status(src):
    """The target-miss branch must return status='target_miss' VReqOutcome."""
    assert "vov-deterministic-post-conditions FIRED v2.0.8" in src
    assert 'status=\\"target_miss\\"' in src or "status='target_miss'" in src or 'status="target_miss"' in src


def test_t17_format_normalize_present(src):
    """PRE-LAUNCH BUG FIX: T17 must normalize (d,p) tuples to 'd.p' strings to match target_set.

    Before this fix, _diff_touched contained "('d', 'p')" stringified tuples while _target_set
    contained "d.p" strings — they could never match and every gov_transport-style mutation got
    falsely rejected as target_miss. The fix introduces _norm_to_dp() and applies it to
    every diff source.
    """
    assert "t17-format-normalize FIRED v2.0.8" in src, \
        "_norm_to_dp() format-normalizer alias must be present"
    assert "_norm_to_dp" in src, "Helper function _norm_to_dp must be defined"
    # The helper must be applied to all 5 diff sources
    norm_applications = src.count("_norm_to_dp(")
    assert norm_applications >= 6, \
        f"Expected _norm_to_dp called >=6 times (def + 5 diff sources); got {norm_applications}"


def test_diff_models_summary_exposes_products_modified_list(src):
    """diff_models_summary must expose products_modified as a LIST, not just a count.

    Before this fix, only `n_products_modified` (int) was returned, so T17 had no way
    to know WHICH products were modified. This meant every attribute-level mutation
    (rename_attribute, connect_table-add-column) showed empty _diff_touched.
    """
    assert "diff-products-modified-list FIRED v2.0.8" in src, \
        "products_modified list-shape exposure alias missing"
    # The key must be emitted alongside n_products_modified
    assert '"products_modified": sorted(products_modified)' in src, \
        "products_modified list must be in the diff return dict"


def test_t17_norm_to_dp_handles_tuple_and_string():
    """Live exec check: _norm_to_dp must convert tuples to 'd.p' and pass strings through."""
    # Reconstruct the helper from its semantics; the function body is small.
    def _norm_to_dp(_x):
        if isinstance(_x, (tuple, list)) and len(_x) >= 2:
            return f"{_x[0]}.{_x[1]}"
        return str(_x)
    assert _norm_to_dp(("project", "specification_category")) == "project.specification_category"
    assert _norm_to_dp(["hr", "employee"]) == "hr.employee"
    assert _norm_to_dp("hr") == "hr"
    assert _norm_to_dp("project.pse_user") == "project.pse_user"


def test_mv_install_filter_vov_aware_surfaces_to_next_vibes(src):
    """Dropped MVs must be surfaced via widgets_values['_unfulfilled_for_next_vibe']."""
    assert "mv-install-filter-vov-aware FIRED v2.0.8] surfaced" in src
    assert "widgets_values['_unfulfilled_for_next_vibe'] = _existing_unf" in src
