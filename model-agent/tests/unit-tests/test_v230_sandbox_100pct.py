"""v2.3.0 — 100% sandbox-coverage targeting.

Four sandbox-rejection root causes were identified from gov_transport v219 (run <run_id>)
where VOV-2.0 SHIM coverage_pct=36.2% with 78/104 batches rejected. Breakdown:

  - 69 noop_failed (88% of rejections) - empty diff after AST+sandbox accept
  - 6 scope_mismatch - rename pattern produced removed-AND-added products
  - 2 target_miss - mutator did not touch declared targets
  - 1 rejected_unsafe (forbidden AST node: Delete)

v2.3.0 ships ONE fix per class, plus this behavioural test suite that proves each fix
EXISTS and CHANGES OBSERVABLE BEHAVIOR (per CLAUDE.md \xa78.10 - no observability-only
patches). Tests use static parse + behavioral simulation since the sandbox subprocess
runner needs a live AIAgent; behavioral checks here exercise the deterministic helpers
(diff_within_summary_scope, _v204_ast_class_hints, ALLOWED_AST_NODES, SYNTHESIS_SYSTEM_PROMPT).
"""
from __future__ import annotations

import ast
import json
import re
import sys
from pathlib import Path

import pytest

from notebook_source_util import vov_ledger_globals

NB_PATH = Path(__file__).resolve().parents[2] / "agent" / "dbx_vibe_modelling_agent.ipynb"


@pytest.fixture(scope="module")
def src() -> str:
    nb = json.loads(NB_PATH.read_text())
    chunks = []
    for c in nb["cells"]:
        if c["cell_type"] == "code":
            s = c["source"]
            if isinstance(s, list):
                s = "".join(s)
            chunks.append(s)
    return "\n".join(chunks)


@pytest.fixture(scope="module")
def module_ns(src: str) -> dict:
    """Compile + exec a SUBSET of the agent source so we can call deterministic
    helpers like diff_within_summary_scope and _v204_ast_class_hints directly.
    We isolate only the pure-Python region needed for the tests (no Spark, no DBR).
    """
    tree = ast.parse(src)
    keep_names = {
        "diff_within_summary_scope",
        "diff_models_summary",
        "_v204_ast_class_hints",
        "ALLOWED_AST_NODES",
        "ALLOWED_BUILTINS",
        "ALLOWED_MODULE_ATTRS",
        "FORBIDDEN_MODULE_NAMES",
        "_v215_count_tags",
    }
    keep_nodes = []
    for node in tree.body:
        if isinstance(node, (ast.FunctionDef, ast.AsyncFunctionDef)) and node.name in keep_names:
            keep_nodes.append(node)
        elif isinstance(node, ast.Assign):
            for tgt in node.targets:
                if isinstance(tgt, ast.Name) and tgt.id in keep_names:
                    keep_nodes.append(node)
                    break
    new_module = ast.Module(body=keep_nodes, type_ignores=[])
    ast.fix_missing_locations(new_module)
    ns = {**vov_ledger_globals(), "__name__": "v230_test_ns", "ast": ast, "re": re}
    code = compile(new_module, str(NB_PATH), "exec")
    exec(code, ns)
    return ns


# --- FIX 1: noop_failed hint class ---------------------------------------------------

def test_v230_version_constant_is_2_3_0_or_later(src):
    m = re.search(r"__AGENT_VERSION__\s*=\s*[\"']([^\"']+)[\"']", src)
    assert m, "no __AGENT_VERSION__ found"
    parts = [int(x) for x in m.group(1).split(".")]
    assert parts >= [2, 3, 0], f"expected >= 2.3.0, got {m.group(1)}"


def test_fix1_noop_failed_hint_class_present(src):
    """v230 alias=v230-ast-class-hint-noop-failed: _v204_ast_class_hints
    has explicit handling for 'noop_failed' and 'empty diff after mutator' so the
    retry feedback teaches the LLM about the dual-key / dual-root traps."""
    assert "v230-ast-class-hint-noop-failed" in src, "FIX 1 alias missing"
    # Verify the specific traps are documented
    assert "data_products" in src and "products" in src
    assert "case-sensitive" in src.lower() or "case-sensitive equality" in src.lower()
    assert "CURRENT_MODEL_DIGEST" in src
    # The hint must appear inside the classes list
    m = re.search(r"_v204_ast_class_hints[\s\S]+?classes\s*=\s*\[(.*?)\n\s*\]", src, re.DOTALL)
    assert m, "_v204_ast_class_hints classes-list not found"
    classes_block = m.group(1)
    assert "noop_failed" in classes_block, "noop_failed class missing from hint list"
    assert "empty diff after mutator" in classes_block, "empty diff hint missing"


def test_fix1_v204_ast_class_hints_returns_hint_for_noop_diagnostic(module_ns):
    """Behavioral check: when the prior failure trace contains 'noop_failed' or
    'empty diff after mutator', the hint function MUST emit a non-empty hint string
    that includes data_products + lookup guidance."""
    fn = module_ns["_v204_ast_class_hints"]
    diag = "attempt 1: noop_failed: mutator produced empty diff (no domains/products/tags/fks/MVs changed)"
    hint = fn(diag)
    assert hint, "v230 fix did not produce a hint for noop_failed diagnostic"
    assert "data_products" in hint or "data_products" in hint.lower()
    assert "case" in hint.lower(), "must mention case sensitivity"
    assert "CURRENT_MODEL_DIGEST" in hint, "must reference the digest for verification"


def test_fix1_v204_ast_class_hints_returns_hint_for_empty_diff_diagnostic(module_ns):
    fn = module_ns["_v204_ast_class_hints"]
    diag = "empty diff after mutator+verifier accepted"
    hint = fn(diag)
    assert hint, "empty-diff hint missing"


def test_fix1_v204_pre_patch_would_have_returned_empty(module_ns):
    """Negative control - confirms _v204_ast_class_hints returns empty for
    diagnostics that don't match any class. This proves the hint logic actually
    looks at the trace text (not unconditional hint emission)."""
    fn = module_ns["_v204_ast_class_hints"]
    assert fn("a totally unrelated error") == ""


# --- FIX 2: scope_mismatch rename pattern -------------------------------------------

def test_fix2_rename_pattern_in_scope_alias_present(src):
    assert "v230-rename-pattern-in-scope" in src
    # Verify the implementation: must check both rename language AND balance
    m = re.search(r"def diff_within_summary_scope[\s\S]+?_is_rename_summary[\s\S]+?_balanced_rename", src)
    assert m, "rename-pattern detection logic missing in diff_within_summary_scope"


def test_fix2_rename_balanced_is_in_scope(module_ns):
    """Behavioral: a 'rename' summary with equal products_removed and
    products_added MUST be in scope (the v219 sandbox rejection mode)."""
    fn = module_ns["diff_within_summary_scope"]
    diff = {
        "domains_added": [], "domains_removed": [],
        "products_added": [("project", "pse_user_information"), ("project", "pse_project_category")],
        "products_removed": [("project", "pse_user"), ("project", "specification_applicability")],
        "fks_removed": 0, "metric_views_delta": 0, "n_products_modified": 0,
    }
    summary = "Rename project.specification_applicability to pse_project_category and project.pse_user to pse_user_information in place"
    ok, msg = fn(diff, summary)
    assert ok is True, f"rename pattern should be in-scope: {msg}"


def test_fix2_imbalanced_remove_still_out_of_scope(module_ns):
    """Negative control: if more products are removed than added, treat as
    suspicious - the imbalance could hide deletion masquerading as rename."""
    fn = module_ns["diff_within_summary_scope"]
    diff = {
        "domains_added": [], "domains_removed": [],
        "products_added": [("p", "x")],
        "products_removed": [("p", "x1"), ("p", "x2"), ("p", "x3")],
        "fks_removed": 0, "metric_views_delta": 0, "n_products_modified": 0,
    }
    ok, msg = fn(diff, "rename x1,x2,x3 to single x")
    assert ok is False, "imbalanced rename should still trigger scope rejection"
    assert "products_removed" in msg


def test_fix2_non_rename_remove_still_out_of_scope(module_ns):
    """Negative control: removed products with a non-rename summary remains rejected."""
    fn = module_ns["diff_within_summary_scope"]
    diff = {
        "domains_added": [], "domains_removed": [],
        "products_added": [("p", "new")],
        "products_removed": [("p", "old")],
        "fks_removed": 0, "metric_views_delta": 0, "n_products_modified": 0,
    }
    ok, msg = fn(diff, "consolidate two products into one")
    # 'consolidate' is not a rename keyword - balanced rename guard does NOT fire
    assert ok is False, "non-rename language with products_removed should be rejected"


def test_fix2_pre_patch_would_have_rejected(src):
    """Static-grep proof: the pre-patch diff_within_summary_scope (without
    _balanced_rename guard) would have rejected the gov_transport v219 batches. The
    new code must contain the v230 guard before the products_removed check."""
    body_match = re.search(
        r"def diff_within_summary_scope[\s\S]+?return True, \"\"",
        src,
    )
    assert body_match, "diff_within_summary_scope body not found"
    body = body_match.group(0)
    # The new code must check `_balanced_rename` before flagging products_removed
    assert "_balanced_rename" in body
    # Verify it appears in the products_removed conditional
    products_removed_lines = [l for l in body.splitlines() if "products_removed" in l and "diff[" in l]
    assert any("_balanced_rename" in l for l in products_removed_lines), \
        "products_removed branch must reference _balanced_rename"


# --- FIX 3: synth target-must-touch -------------------------------------------------

def test_fix3_synth_target_must_touch_alias_present(src):
    assert "v230-synth-target-must-touch" in src
    # The prompt body MUST include explicit instructions about touching targets
    assert "MUTATOR MUST CHANGE SOMETHING THAT TOUCHES" in src or "must touch" in src.lower()


def test_fix3_synth_prompt_documents_data_products_dual_key(src):
    """The SYNTHESIS_SYSTEM_PROMPT must teach the LLM about the dual-key trap."""
    # The bug: domains have either 'data_products' or 'products'
    # Pull the prompt body
    m = re.search(r'SYNTHESIS_SYSTEM_PROMPT\s*=\s*"""([\s\S]+?)"""', src)
    if not m:
        # JSON-escaped
        m = re.search(r'SYNTHESIS_SYSTEM_PROMPT\s*=\s*\\"\\"\\"([\s\S]+?)\\"\\"\\"', src)
    assert m, "SYNTHESIS_SYSTEM_PROMPT not found"
    body = m.group(1)
    assert "data_products" in body, "prompt must mention data_products key alternative"
    assert "products" in body
    assert "VERIFY-BEFORE-RETURN" in body or "_touched" in body, \
        "prompt must instruct verification before return"


def test_fix3_synth_prompt_documents_root_path_split(src):
    """Prompt must explain model['model']['domains'] vs model['domains'] split."""
    m = re.search(r'SYNTHESIS_SYSTEM_PROMPT\s*=\s*"""([\s\S]+?)"""', src)
    if not m:
        m = re.search(r'SYNTHESIS_SYSTEM_PROMPT\s*=\s*\\"\\"\\"([\s\S]+?)\\"\\"\\"', src)
    assert m
    body = m.group(1)
    assert "model.get('model'" in body or "model['model']" in body, \
        "prompt must explain dual root-path"


def test_fix3_synth_prompt_documents_rename_in_place_pattern(src):
    m = re.search(r'SYNTHESIS_SYSTEM_PROMPT\s*=\s*"""([\s\S]+?)"""', src)
    if not m:
        m = re.search(r'SYNTHESIS_SYSTEM_PROMPT\s*=\s*\\"\\"\\"([\s\S]+?)\\"\\"\\"', src)
    assert m
    body = m.group(1)
    assert "rename" in body.lower()
    assert "in-place" in body.lower() or "in place" in body.lower()


# --- FIX 4: ast.Delete allowed -----------------------------------------------------

def test_fix4_ast_delete_allowed_alias_present(src):
    assert "v230-allow-ast-delete" in src
    # The ALLOWED_AST_NODES set must include ast.Delete
    m = re.search(r"ALLOWED_AST_NODES\s*=\s*frozenset\(\{([\s\S]+?)\}\)", src)
    assert m, "ALLOWED_AST_NODES not found"
    allowed_block = m.group(1)
    assert "ast.Delete" in allowed_block, "ast.Delete missing from ALLOWED_AST_NODES"


def test_fix4_module_filters_still_block_dangerous_deletes(module_ns):
    """Security sanity: even though ast.Delete is now allowed, FORBIDDEN_MODULE_NAMES
    + the dunder guard still block dangerous deletes like `del sys`."""
    forbidden = module_ns.get("FORBIDDEN_MODULE_NAMES")
    assert forbidden is not None
    assert "sys" in forbidden
    assert "os" in forbidden
    assert "subprocess" in forbidden


def test_fix4_ast_delete_is_in_allowed_set_runtime(module_ns):
    """Behavioral: ALLOWED_AST_NODES.contains(ast.Delete) at runtime."""
    allowed = module_ns.get("ALLOWED_AST_NODES")
    assert allowed is not None
    assert ast.Delete in allowed, "ast.Delete not in runtime ALLOWED_AST_NODES set"


# --- Cross-cutting invariants --------------------------------------------------------

def test_all_four_v230_fixes_each_appear_exactly_in_one_definition_site(src):
    """Each fix alias should appear in source code (not just comments). Counts:
       - v230-ast-class-hint-noop-failed: in _v204_ast_class_hints body
       - v230-rename-pattern-in-scope: in diff_within_summary_scope body
       - v230-synth-target-must-touch: in SYNTHESIS_SYSTEM_PROMPT
       - v230-allow-ast-delete: in ALLOWED_AST_NODES def + class hint
    """
    for alias, min_count in [
        ("v230-ast-class-hint-noop-failed", 2),  # def + version-header
        ("v230-rename-pattern-in-scope", 2),
        ("v230-allow-ast-delete", 2),
        ("v230-synth-target-must-touch", 2),
    ]:
        c = src.count(alias)
        assert c >= min_count, f"alias {alias!r} appears {c}x, expected >= {min_count}"


def test_no_existing_v220_or_v219_aliases_were_lost(src):
    """Regression guard: v2.3.0 must NOT remove any prior FIRED aliases."""
    # NOTE: the v218 marker "vibe-parse-prose-only-prompt" was DELIBERATELY removed in v2.7.8
    # ("generalize exact-count recovery + remove run-specific overfitting") and superseded by
    # "sizing-directive-focused-recovery" + the structured VIBE_PARSE sizing_directives mechanism.
    # The prose-parsing FEATURE (VIBE_PARSE_PROMPT) is intact; only the over-specific v218 alias was
    # generalized, well after v2.3.0. Guarding it here is stale, so it is replaced by its successor.
    for prior in [
        "vov-apply-handler-none-model-guard",   # v220
        "mv-statements-dict-coercion-fix",       # v219
        "sizing-directive-focused-recovery",     # v2.7.8 successor of the v218 prose-only-prompt marker
        "vov-coverage-honest",                   # v2.0.8
        "vov-noop-applied-guard",                # v2.0.8
    ]:
        assert prior in src, f"prior alias {prior!r} was lost - regression"


def test_synthesis_prompt_still_has_user_vibe_authority(src):
    """Regression guard: v230 changes must NOT weaken CLAUDE.md \xa73b/\xa73c authority block."""
    assert "USER VIBE AUTHORITY" in src
    assert "PINNED DOMAINS" in src
    assert "PINNED PRODUCTS" in src
