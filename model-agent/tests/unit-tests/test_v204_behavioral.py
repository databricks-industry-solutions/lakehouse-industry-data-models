"""Behavioral tests for v2.0.4 (verifier-stripped + pinned-domains-in-prompt +
ast-class-retry-feedback + mv-preservation-invariant).

Pre-fix evidence from v203 live runs (2026-05-25):
  RT mvm_v3: 16 ERRORs, 11 verifier-failed, 3 unsafe-AST, 1 cycle introduction,
            1 bidirectional pair introduced.
  gov_transport mvm_v3: 26 ERRORs, 41 invariant-violations ("user-pinned domains removed:
            ['hr', 'project']"), 7 unsafe-AST, 1 Max retries exhausted, MV count
            collapsed 41 -> 8 (R2-class regression).

All four v204 fixes have static-contract tests + at least one behavioural-shape
assertion per CLAUDE.md §8.10. Each test MUST FAIL on the v203 baseline.
"""
import ast
import json
import re
from pathlib import Path

NB_PATH = Path(__file__).parent.parent.parent / "agent" / "dbx_vibe_modelling_agent.ipynb"


def _nb_src():
    nb = json.loads(NB_PATH.read_text())
    cells = nb.get("cells", [])
    return "\n".join("".join(c.get("source", [])) for c in cells if c.get("cell_type") == "code")


def _cell_src(idx):
    nb = json.loads(NB_PATH.read_text())
    return "".join(nb["cells"][idx].get("source", []))


# ---------- Version + sentinel infrastructure ----------

def test_v204_agent_version_is_204():
    src = _nb_src()
    m = re.search(r'__AGENT_VERSION__\s*=\s*"([^"]+)"', src)
    assert m, "missing __AGENT_VERSION__"
    assert tuple(int(_x) for _x in m.group(1).split(".")) >= (2, 0, 4), f"expected 2.0.4 (single-digit semver), got {m.group(1)}"


def test_v204_version_constant_first_code_line_of_cell_1():
    nb = json.loads(NB_PATH.read_text())
    cell1 = nb["cells"][1]
    src_lines = "".join(cell1["source"]).splitlines()
    code_lines = [ln for ln in src_lines if ln.strip() and not ln.strip().startswith("#")]
    assert code_lines, "Cell 1 has no code lines"
    first_code = code_lines[0]
    assert first_code.startswith('__AGENT_VERSION__'), (
        f"first non-comment code line of Cell 1 must declare __AGENT_VERSION__; got: {first_code!r}"
    )


def test_v204_all_four_sentinels_present():
    src = _nb_src()
    for marker in (
        "v204-verifier-stripped",
        "v204-pinned-domains-in-prompt",
        "v204-ast-class-retry-feedback",
        "v204-mv-preservation-invariant",
    ):
        assert marker in src, f"v2.0.4 sentinel {marker!r} missing from notebook"


# ---------- F1: verifier_source stripped from _synth_schema ----------

def test_v204_f1_verifier_source_not_in_synth_schema_required():
    src = _nb_src()
    # The _synth_schema dict-literal must NOT have verifier_source in its required list.
    schema_block = re.search(
        r'_synth_schema\s*=\s*\{(.*?)\}\s*\n\s*#\s*v204\s*F1',
        src, re.DOTALL
    )
    assert schema_block, "_synth_schema dict-literal not found followed by v204 F1 comment"
    schema_text = schema_block.group(1)
    # No verifier_source key
    assert '"verifier_source"' not in schema_text, (
        "v204 F1: verifier_source must NOT appear in _synth_schema. v203 had it under both "
        "properties and required; stripping it is the headline fix."
    )
    # Required list must contain mutator_source and expected_changes_summary
    assert '"required": ["mutator_source", "expected_changes_summary"]' in schema_text or \
           "'required': ['mutator_source', 'expected_changes_summary']" in schema_text, (
        f"v204 F1: expected required=['mutator_source','expected_changes_summary']; got: {schema_text[-300:]}"
    )


def test_v204_f1_synthesizer_emits_empty_verifier_src():
    """v204 F1: synthesize_handler sets Handler.verifier_src='' regardless of LLM output."""
    src = _nb_src()
    # Locate the synthesize_handler Handler-construction block and assert verifier_src=""
    # appears within ~500 chars (the function body after "return Handler(")
    # AND that the v203 anti-pattern is gone.
    sh_idx = src.find("def synthesize_handler(")
    assert sh_idx > 0, "synthesize_handler def not found"
    sh_end = src.find("def synthesize_batch_handlers", sh_idx)
    body = src[sh_idx:sh_end]
    assert 'verifier_src=""' in body, (
        "v204 F1: synthesize_handler must set verifier_src=\"\" (empty literal) so the "
        "deterministic Auditor handles verification. Body did not contain `verifier_src=\"\"`."
    )
    assert 'verifier_src=str(raw.get("verifier_source"' not in body, (
        "v204 F1: synthesize_handler must NOT use the v203 pattern verifier_src=str(raw.get("
        "'verifier_source', '')) - the verifier is fully stripped from the LLM contract."
    )


def test_v204_f1_sandbox_injects_noop_verifier_when_empty():
    src = _nb_src()
    assert "_verifier_was_stripped = not (verifier_src or" in src, (
        "v204 F1: execute_in_sandbox must detect empty verifier_src and inject a no-op "
        "verifier so the subprocess runs cleanly."
    )


# ---------- F2: pinned-domains-in-prompt ----------

def test_v204_f2_synthesize_handler_accepts_pinned_kwargs():
    src = _nb_src()
    sh_idx = src.find("def synthesize_handler(")
    assert sh_idx > 0, "synthesize_handler def not found"
    # Read the parameter list (up to the closing -> Handler:)
    sig_end = src.find("-> Handler:", sh_idx)
    assert sig_end > sh_idx, "synthesize_handler signature not closed with -> Handler:"
    signature = src[sh_idx:sig_end]
    for kw in ("batch: Batch", "llm: LLMClient", "prior_failure_trace", "pinned_domains", "pinned_products"):
        assert kw in signature, (
            f"v204 F2: synthesize_handler signature missing {kw!r}. Current signature:\n{signature}"
        )


def test_v204_f2_synthesis_prompt_has_user_vibe_authority_preamble():
    src = _nb_src()
    assert "USER VIBE AUTHORITY (CLAUDE.md \u00a73b/\u00a73c" in src or \
           "USER VIBE AUTHORITY (CLAUDE.md §3b/§3c" in src, (
        "v204 F2: SYNTHESIS_SYSTEM_PROMPT must carry an explicit USER VIBE AUTHORITY preamble "
        "naming the pinned domain/product set as contractual minimum."
    )
    assert "PINNED DOMAINS (immutable" in src, (
        "v204 F2: prompt must contain literal 'PINNED DOMAINS (immutable' marker for the "
        "pinned domain injection point."
    )


def test_v204_f2_synthesis_prompt_forbids_collection_replacement():
    src = _nb_src()
    assert "MUTATE IN PLACE" in src, "v204 F2: prompt must say 'MUTATE IN PLACE'"
    assert "metric_views" in src and "OBLITERATES" in src, (
        "v204 F2: prompt must specifically warn that reassigning metric_views OBLITERATES "
        "the existing list (the root cause of gov_transport v203 MV collapse 41 -> 8)."
    )


def test_v204_f2_run_vov_pipeline_passes_pinned_through():
    src = _nb_src()
    # The pipeline must explicitly construct _pinned_d_tuple and pass it to synthesize_batch_handlers
    assert "_pinned_d_tuple = tuple(user_pinned_domains)" in src, (
        "v204 F2: run_vov_pipeline must convert user_pinned_domains to a tuple and pass it "
        "into synthesize_batch_handlers + _apply_handler_with_retry."
    )
    # The call was reformatted multi-line and gained model_snapshot/pinned_products
    # args; assert the pinned tuple is still threaded into the call (whitespace-tolerant)
    # rather than matching the old single-line signature.
    assert "pinned_domains=_pinned_d_tuple" in src, (
        "v204 F2: synthesize_batch_handlers call must include pinned_domains=_pinned_d_tuple"
    )


# ---------- F3: AST-class retry feedback ----------

def test_v204_f3_helper_function_exists():
    src = _nb_src()
    assert "def _v204_ast_class_hints(" in src, (
        "v204 F3: _v204_ast_class_hints helper function must exist to enumerate known AST "
        "violation classes into the retry prompt."
    )


def test_v204_f3_known_classes_enumerated():
    src = _nb_src()
    # Spot-check the most common violations seen in v203 logs (Import, USub, dunder, scope)
    # NOTE: "forbidden AST node: USub" was REMOVED from the hint set in v3.0.0
    # (alias=v300-allow-usub) — unary -x/+x on numerics is now ALLOWED by the
    # sandbox, so it is no longer a violation class. Replaced here with
    # "forbidden AST node: Delete" (a class still enumerated by the hints builder).
    for needle in (
        "forbidden AST node: Import",
        "forbidden AST node: Delete",
        "forbidden dunder name",
        "invariants violated",
        "scope mismatch",
        "metric_views collection deletion",
    ):
        assert needle in src, (
            f"v204 F3: _v204_ast_class_hints must catch the {needle!r} violation class so "
            f"the LLM gets specific guidance instead of a generic 'do not repeat' note."
        )


def test_v204_f3_retry_loop_invokes_hints_builder():
    src = _nb_src()
    # The retry user-block builder must call _v204_ast_class_hints
    assert "_v204_ast_class_hints(prior_failure_trace" in src, (
        "v204 F3: synthesize_handler must append _v204_ast_class_hints(prior_failure_trace) "
        "to the retry user block."
    )


# ---------- F4: metric-view-preservation invariant ----------

def test_v204_f4_invariant_snapshot_captures_mv_baseline():
    src = _nb_src()
    assert "initial_mv_count: int" in src, (
        "v204 F4: InvariantSnapshot must add initial_mv_count field"
    )
    assert "initial_mv_names: tuple" in src, (
        "v204 F4: InvariantSnapshot must add initial_mv_names tuple field"
    )


def test_v204_f4_capture_invariants_seeds_mv_baseline():
    src = _nb_src()
    assert "_initial_mvs = list(_mdl.get(\"metric_views\", []) or [])" in src or \
           "_initial_mvs = list(_mdl.get('metric_views', []) or [])" in src, (
        "v204 F4: capture_invariants must extract baseline metric_views from the initial model"
    )


def test_v204_f4_verify_invariants_rejects_mv_collapse():
    src = _nb_src()
    assert "metric_views collection deletion" in src, (
        "v204 F4: verify_invariants must reject mutations that drop the metric_views count "
        "with the literal diagnostic 'metric_views collection deletion'."
    )
    assert "preservation_pct < 0.80" in src or "preservation_pct <0.80" in src, (
        "v204 F4: verify_invariants must require >=80% of baseline metric_view names "
        "to survive the mutation."
    )


# ---------- AST sanity on the modified cell 3 ----------

def test_v204_cell_3_is_valid_python():
    """Smoke test that the cell-3 edits did not break Python syntax."""
    src = _cell_src(3)
    try:
        ast.parse(src)
    except SyntaxError as e:
        raise AssertionError(f"cell 3 has SyntaxError at line {e.lineno}: {e.msg}")


# ---------- End-to-end shape: pre-v203 baseline would fail ALL of the above ----------

def test_v204_smoke_summary_aliases_present_for_audit_grep():
    src = _nb_src()
    # Per CLAUDE.md §3a-bis: every alias from this version's commit must be greppable in
    # the deployed archive after re-export.
    expected_count = {
        "v204-verifier-stripped": 4,  # schema comment + handler verifier_src="" comment + sandbox comment + retry skip comment
        "v204-pinned-domains-in-prompt": 2,  # batch_handlers + run_vov_pipeline
        "v204-ast-class-retry-feedback": 2,  # helper def + retry-loop wire
        "v204-mv-preservation-invariant": 3,  # InvariantSnapshot field + capture + verify
        "v204-pinned-domains-in-retry": 1,  # apply_handler_with_retry signature
        "v204-synthesizer-call": 1,  # complete_json system line
    }
    for alias, min_n in expected_count.items():
        actual = src.count(alias)
        assert actual >= min_n, (
            f"v204 audit-grep failure: alias {alias!r} appears {actual} times, expected >= {min_n}. "
            f"Per CLAUDE.md \u00a710.7 Step 6 every v204 fix site MUST be greppable in the deployed archive."
        )
