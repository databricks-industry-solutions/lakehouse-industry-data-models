"""v3.8.0 behavioral test: the sandbox code-gen retry loop feeds failure classes back to the LLM.

Per CLAUDE.md 3d (search-first/DRY) the error->retry feedback loop ALREADY exists in the agent:
  execute_in_sandbox runs validate_ast (raises UnsafeCodeError on SyntaxError) -> result.ok=False
  -> _apply_handler_with_retry appends a trace to failure_traces for EVERY failure mode
  -> synthesize_handler(prior_failure_trace=...) injects the trace + _v204_ast_class_hints(...)
  -> the next attempt is regenerated with explicit "do NOT repeat" guidance.

This test guards the enrichment heart of that loop: _v204_ast_class_hints must translate a raw
sandbox/exec failure trace into class-specific, actionable hints (NOT a generic passthrough).
It is a real behavioral test (distinct input traces -> distinct, asserted hint text), not a tautology.
"""
import json
import os
import re

import pytest

from notebook_source_util import vov_ledger_globals

NB = os.path.join(os.path.dirname(__file__), "..", "..", "agent", "dbx_vibe_modelling_agent.ipynb")


def _extract_func(src_all, fname):
    start = src_all.find("def " + fname + "(")
    assert start != -1, f"{fname} not found in notebook"
    # slice to the next top-level 'def ' (column 0) after the body
    nxt = src_all.find("\ndef ", start + 1)
    return src_all[start:(nxt if nxt != -1 else len(src_all))]


def _load_hints_fn():
    nb = json.load(open(NB))
    src_all = "\n".join(
        "".join(c.get("source", [])) for c in nb.get("cells", []) if c.get("cell_type") == "code"
    )
    fn_src = _extract_func(src_all, "_v204_ast_class_hints")

    class _DummyLogger:
        def info(self, *a, **k):
            pass

        def warning(self, *a, **k):
            pass

    ns = {**vov_ledger_globals(), "re": re, "logger": _DummyLogger()}
    exec(fn_src, ns)
    return ns["_v204_ast_class_hints"]


HINTS = _load_hints_fn()


@pytest.mark.parametrize(
    "trace, must_contain",
    [
        # the AST/syntax-reject path (validate_ast -> UnsafeCodeError -> sandbox 'rejected')
        ("attempt 1: sandbox rejected (forbidden AST node: Import); stderr=", "auto-stripped"),
        # exec-time errors surfaced from the sandbox (mutator threw)
        ("attempt 2: name 'TARGET_SPECS' is not defined", "INLINE"),
        ("attempt 1: 'list' object has no attribute 'get'", "LIST/DICT SHAPE"),
        ("attempt 3: 'NoneType' object has no attribute 'lower'", "NONE-DEREF"),
        # deterministic-audit failure modes
        ("attempt 2: invariants violated: pinned domain removed", "INVARIANT VIOLATION"),
        ("attempt 1: scope mismatch: touched extra entity", "SCOPE MISMATCH"),
        ("attempt 1: noop_failed: mutator produced empty diff", "EMPTY-DIFF NOOP"),
        ("attempt 2: subprocess timeout after 30s", "TIMEOUT"),
    ],
)
def test_failure_class_produces_actionable_hint(trace, must_contain):
    out = HINTS(trace)
    assert out, f"no hint produced for trace: {trace!r}"
    assert "DO NOT REPEAT" in out, "enrichment header missing"
    assert must_contain in out, f"expected {must_contain!r} in hint for {trace!r}; got: {out[:300]}"


def test_clean_trace_yields_no_hint():
    # negative control: an unrecognised/benign trace must NOT fabricate hints
    assert HINTS("attempt 1: everything was fine, applied cleanly") == ""


def test_multiple_classes_are_all_surfaced():
    combo = (
        "attempt 1: 'list' object has no attribute 'get'\n"
        "attempt 2: name 'CONFIG' is not defined\n"
        "attempt 3: scope mismatch: x"
    )
    out = HINTS(combo)
    assert "LIST/DICT SHAPE" in out
    assert "INLINE" in out
    assert "SCOPE MISMATCH" in out


if __name__ == "__main__":
    import sys

    raise SystemExit(pytest.main([__file__, "-q"]))
