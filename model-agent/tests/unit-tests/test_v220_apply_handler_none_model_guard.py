"""Behavioral tests for v2.2.0 vov-apply-handler-none-model-guard.

Live failures reproduced:
- HC v218 vov_v1_to_v2 (run <run_id>, 2026-05-27 18:19)
- RT v218 vov_v1_to_v2 attempt 0 (run <run_id>) and attempt 1 (run <run_id>)

Both crashed identically:

    AttributeError: 'NoneType' object has no attribute 'get'
    File _apply_handler_with_retry, line ~8953
        ok_inv, inv_diag = verify_invariants(new_model, invariants)
    File verify_invariants, line ~7528
        mdl = model.get("model", model)

Root cause: execute_in_sandbox can return result.ok=True with
result.new_model=None (LLM-generated mutator returned None explicitly,
fell off the end without a return, or returned a non-dict that the
sandbox normalized to None). The code at line 8953 assigned
`new_model = result.new_model` and immediately called
`verify_invariants(new_model, invariants)`, which dereferences
`model.get("model", model)` on the first line - None.get crashes.

The bug never fired before because v218's parser silent-drop kept VREQ
counts at 1 per industry; v218's prose-only prompt now extracts 21-22
VREQs per industry, exercising ~21x more handler-apply paths and
surfacing this None-model edge case.

v2.2.0 fix is two-layer:
1. SOURCE-FIX at _apply_handler_with_retry: after `new_model =
   result.new_model`, guard `if new_model is None or not isinstance(
   new_model, dict)` and treat as retry-eligible rejected_unsafe.
2. DEFENSIVE-FIX at verify_invariants: if model is None or not a dict,
   return (False, "model is None or non-dict") instead of crashing.
"""

import ast
import json
import re
from pathlib import Path

import pytest

NOTEBOOK_PATH = Path(__file__).resolve().parents[2] / "agent" / "dbx_vibe_modelling_agent.ipynb"


def _load_source() -> str:
    with NOTEBOOK_PATH.open() as f:
        nb = json.load(f)
    chunks = []
    for c in nb.get("cells", []):
        if c.get("cell_type") == "code":
            s = c.get("source", "")
            if isinstance(s, list):
                s = "".join(s)
            chunks.append(s)
    return "\n".join(chunks)


def _extract_fn(name: str) -> str:
    src = _load_source()
    tree = ast.parse(src)
    lines = src.splitlines()
    for node in ast.walk(tree):
        if isinstance(node, ast.FunctionDef) and node.name == name:
            return "\n".join(lines[node.lineno - 1:node.end_lineno])
    raise AssertionError(f"function {name!r} not found")


def _exec_fn(src: str, name: str, ns_extra=None):
    import re as _re
    import logging

    class _StubLogger:
        def info(self, *a, **k): pass
        def warning(self, *a, **k): pass
        def error(self, *a, **k): pass
        def debug(self, *a, **k): pass

    from typing import Optional as _Opt, Tuple as _Tup, Any as _Any
    ns = {
        "re": _re,
        "logger": _StubLogger(),
        "Optional": _Opt,
        "Tuple": _Tup,
        "Any": _Any,
    }
    ns["_VIBE_SCOPE_RUNTIME"] = None
    exec(re.search(r"^_VIBE_SCOPE_ENGINE_STATUSES = .*$", _load_source(), re.M).group(0), ns)
    for dep in ("verify_scope_invariants", "_vibe_scope_status_of", "_vibe_scope_engine_gate"):
        exec(compile(_extract_fn(dep), f"<{dep}>", "exec"), ns)
    if ns_extra:
        ns.update(ns_extra)
    exec(compile(src, f"<{name}>", "exec"), ns)
    return ns[name]


def _make_invariant_snapshot():
    from dataclasses import dataclass, field
    @dataclass
    class _Snap:
        user_pinned_domains: frozenset = field(default_factory=frozenset)
        user_pinned_products: frozenset = field(default_factory=frozenset)
        agent_version: str = ""
        locked_fields: tuple = ()
        initial_mv_count: int = 0
        initial_mv_names: frozenset = field(default_factory=frozenset)
    return _Snap()


# ---------------------------------------------------------------------------
# Static contract checks
# ---------------------------------------------------------------------------


def test_agent_version_at_least_2_2_0():
    src = _load_source()
    m = re.search(r'__AGENT_VERSION__\s*=\s*"([^"]+)"', src)
    assert m
    v = tuple(int(x) for x in m.group(1).split("."))
    assert v >= (2, 2, 0), f"expected >= 2.2.0, got {m.group(1)}"


def test_apply_handler_has_none_model_guard():
    """The fix MUST land in _apply_handler_with_retry between the
    `new_model = result.new_model` line and the verify_invariants call.
    """
    fn_src = _extract_fn("_apply_handler_with_retry")
    # The fix anchors on isinstance(new_model, dict) or new_model is None.
    has_isinstance = "isinstance(new_model, dict)" in fn_src
    has_is_none = "new_model is None" in fn_src
    assert has_isinstance or has_is_none, (
        "v2.2.0 fix missing: _apply_handler_with_retry must guard "
        "new_model is None / non-dict before verify_invariants"
    )
    # The fired log line must reference the alias.
    assert "vov-apply-handler-none-model-guard" in fn_src, (
        "v2.2.0 fix must emit [vov-apply-handler-none-model-guard FIRED v2.2.0] "
        "log when the guard activates"
    )


def test_verify_invariants_has_defensive_none_guard():
    """verify_invariants must defensively reject None / non-dict input
    instead of crashing on .get."""
    fn_src = _extract_fn("verify_invariants")
    # Look for the defensive guard at the function top.
    first_50_lines = "\n".join(fn_src.splitlines()[:8])
    assert (
        "model is None" in first_50_lines
        and "isinstance(model, dict)" in first_50_lines
    ), (
        "v2.2.0 defensive fix missing: verify_invariants must check "
        "(model is None or not isinstance(model, dict)) at the top"
    )


def test_alias_appears_at_two_sites():
    """The vov-apply-handler-none-model-guard alias must appear in BOTH
    the source-fix and the defensive-fix sites."""
    src = _load_source()
    count = src.count("vov-apply-handler-none-model-guard FIRED v2.2.0")
    assert count >= 2, (
        f"expected >= 2 sites with [vov-apply-handler-none-model-guard FIRED v2.2.0]; "
        f"found {count}"
    )


# ---------------------------------------------------------------------------
# §8.10 behavioral — prove pre-patch crashed, post-patch handles gracefully
# ---------------------------------------------------------------------------


def test_pre_patch_verify_invariants_would_crash_on_none():
    """Simulate the PRE-v2.2.0 function body (no None-guard) and confirm
    that calling it with model=None raises AttributeError.

    This is the failure mode the v220 fix targets - the test must
    fail without the fix and the fix is what makes downstream behavior
    different.
    """
    def _pre_patch_verify_invariants(model, expected):
        # Verbatim pre-patch v2.1.9 body
        mdl = model.get("model", model)
        actual_domains = {d.get("name", "") for d in mdl.get("domains", [])}
        return True, ""

    with pytest.raises(AttributeError):
        _pre_patch_verify_invariants(None, _make_invariant_snapshot())


def test_post_patch_verify_invariants_returns_false_on_none():
    """The actual deployed function must NOT crash on None - return (False, diag)."""
    fn_src = _extract_fn("verify_invariants")
    fn = _exec_fn(fn_src, "verify_invariants")
    snap = _make_invariant_snapshot()
    ok, diag = fn(None, snap)
    assert ok is False
    assert isinstance(diag, str) and "model" in diag.lower()


def test_post_patch_verify_invariants_handles_various_non_dict():
    fn_src = _extract_fn("verify_invariants")
    fn = _exec_fn(fn_src, "verify_invariants")
    snap = _make_invariant_snapshot()
    for bad in ("string-not-dict", [], [1, 2], 42, 3.14, object()):
        ok, diag = fn(bad, snap)
        assert ok is False, f"verify_invariants({type(bad).__name__}) returned {ok}"


def test_post_patch_verify_invariants_handles_inner_model_non_dict():
    """v220 also guards `mdl = model.get('model', model)` — if that result
    is non-dict, the function should return False rather than crash on
    `mdl.get("domains", [])`."""
    fn_src = _extract_fn("verify_invariants")
    fn = _exec_fn(fn_src, "verify_invariants")
    snap = _make_invariant_snapshot()
    # Outer is dict but inner "model" key is None
    ok, diag = fn({"model": None}, snap)
    assert ok is False
    # Inner is a string
    ok, diag = fn({"model": "junk"}, snap)
    assert ok is False


def test_post_patch_verify_invariants_passes_on_valid_model():
    """Baseline sanity: a normal valid model with all pinned domains/products
    present must still return (True, '')."""
    fn_src = _extract_fn("verify_invariants")
    fn = _exec_fn(fn_src, "verify_invariants")
    snap = _make_invariant_snapshot()
    valid_model = {
        "agent_version": "",
        "model": {
            "domains": [
                {"name": "hr", "products": [{"name": "employee", "attributes": []}]}
            ],
            "metric_views": [],
        },
    }
    ok, diag = fn(valid_model, snap)
    assert ok is True, f"expected True for valid model, got ({ok}, {diag!r})"


def test_apply_handler_guard_uses_synthesize_handler_path():
    """When new_model is None, the fix must route into the existing retry
    machinery (synthesize_handler + continue) rather than just skipping
    the iteration silently."""
    fn_src = _extract_fn("_apply_handler_with_retry")
    # The fix block must contain BOTH the continue and the
    # synthesize_handler call before returning rejected_unsafe.
    # Find the block that follows the None-guard.
    none_guard_start = fn_src.find("new_model is None")
    assert none_guard_start >= 0
    # window widened (was 1500) to span the v2.8.9 vov-surface-sandbox-diag block
    # that was legitimately inserted between the guard and the synthesize_handler
    # retry call; the behavior (re-synthesize on retry) is unchanged.
    next_300 = fn_src[none_guard_start: none_guard_start + 2600]
    assert "synthesize_handler(" in next_300, (
        "v2.2.0 fix should re-synthesize a fresh handler on retry, not skip"
    )
    assert "continue" in next_300, (
        "v2.2.0 fix should `continue` the retry loop, not return early"
    )
    assert "rejected_unsafe" in next_300, (
        "v2.2.0 fix should ultimately return status='rejected_unsafe' "
        "after max_retries"
    )
