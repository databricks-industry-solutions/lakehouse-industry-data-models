"""v3.6.8 hc-bug3 behavioral test: when the non-bidirectional cycle count is LARGE,
_break_cycles_internal breaks the bulk with the deterministic heuristic breaker FIRST
(no LLM), instead of grinding every long cycle through slow per-round LLM escalation.

ROOT CAUSE (healthcare base-MVM 2026-06-17): 2062 cycles (only 13 simple A<->B; ~2049 longer)
all went through LLM escalation rounds -> ~2.5h to converge (04:06->06:45), with timeout /
fail-closed risk for the marathon's dense tier-1 industries.

FIX (alias=cyclebreak-deterministic-bulk-first): above a config-tunable threshold, call the
existing _break_cycles_heuristic_internal (betweenness + convenience-FK + cross-domain +
resilience scoring) to break the bulk instantly; the outer 7D-0 iteration re-detects and feeds
the small residual to the LLM.

Test A (fail-pre/pass-post): 70 long cycles + an ai_agent stub whose run_worker raises if
called -> post-patch the deterministic gate fires, breaks edges, and the LLM is NEVER called.
Test B (negative control, guards against an always-fire §8.3 tautology): with a high threshold,
the gate does NOT fire and the function proceeds to the LLM path.
"""
import textwrap
from collections import defaultdict
import pytest
from notebook_source_util import notebook_concat_source, exec_function_namespace, pk_predicate_globals


def _helper_namespace():
    """Exec the contiguous deterministic-breaker helper block (const + 4 fns) into one ns."""
    src = notebook_concat_source()
    start = src.index("_CONVENIENCE_FK_PREFIXES = (")
    end = src.index("def _break_cycles(", start)  # wrapper right after _break_cycles_heuristic_internal
    block = src[start:end]
    ns = {"defaultdict": defaultdict, "_vibe_scope_frozen_edges": exec_function_namespace(
        "_vibe_scope_frozen_edges", extra_globals={"_VIBE_SCOPE_RUNTIME": None}, source=src)["_vibe_scope_frozen_edges"]}
    ns["_v516_is_pk_attr"] = pk_predicate_globals(src)["_v516_is_pk_attr"]
    exec(compile(block, "<cyclebreak_helpers>", "exec"), ns)
    return ns


def _build_break_cycles_internal(extra=None):
    helpers = _helper_namespace()
    g = {"defaultdict": defaultdict}
    g.update(helpers)
    if extra:
        g.update(extra)
    ns = exec_function_namespace("_break_cycles_internal", extra_globals=g)
    return ns["_break_cycles_internal"]


class _Log:
    def __init__(self):
        self.infos, self.warnings, self.errors = [], [], []
    def info(self, m): self.infos.append(m)
    def warning(self, m): self.warnings.append(m)
    def error(self, m): self.errors.append(m)
    def debug(self, m): pass


class _AiAgentRaises:
    def __init__(self): self.calls = []
    def run_worker(self, *a, **k):
        self.calls.append((a, k))
        raise AssertionError("LLM run_worker called — deterministic bulk path should have handled it")


def _make_long_cycles(n, attrs):
    """Build n disjoint 3-node cycles (d.pA->d.pB->d.pC->d.pA) + matching FK attributes."""
    cycles = []
    for i in range(n):
        a, b, c = f"d.p{3*i}", f"d.p{3*i+1}", f"d.p{3*i+2}"
        cycles.append([(a, b), (b, c), (c, a)])
        for src, tgt in [(a, b), (b, c), (c, a)]:
            sd, sp = src.split(".")
            td, tp = tgt.split(".")
            attrs.append({
                "domain": sd, "product": sp, "attribute": f"{tp}_id",
                "foreign_key_to": f"{td}.{tp}.{tp}_id", "type": "BIGINT", "tags": "",
            })
    return cycles


def test_large_cycle_count_breaks_deterministically_no_llm():
    attrs = []
    cycles = _make_long_cycles(70, attrs)  # 70 > default threshold 60
    fn = _build_break_cycles_internal()
    log = _Log()
    agent = _AiAgentRaises()
    broken, removed = fn(cycles, attrs, log, ai_agent=agent, config={"model_scope": "mvm"}, business_name="x", industry_alignment="y")
    assert broken > 0, "deterministic bulk breaker should have broken cycle edges"
    assert agent.calls == [], "LLM must NOT be called for a large bulk of cycles"
    assert any("cyclebreak-deterministic-bulk-first FIRED" in m for m in log.infos)


def test_below_threshold_does_not_fire_gate():
    """Negative control: count below threshold -> gate does NOT fire, LLM path is entered."""
    attrs = []
    cycles = _make_long_cycles(70, attrs)
    heuristic_calls = []
    real_helpers = _helper_namespace()
    real_heuristic = real_helpers["_break_cycles_heuristic_internal"]
    def _spy_heuristic(*a, **k):
        heuristic_calls.append((a, k))
        return real_heuristic(*a, **k)
    fn = _build_break_cycles_internal(extra={"_break_cycles_heuristic_internal": _spy_heuristic})
    log = _Log()
    agent = _AiAgentRaises()
    # threshold above the cycle count -> bulk gate must NOT fire
    try:
        fn(cycles, attrs, log, ai_agent=agent, config={"CYCLE_BULK_DETERMINISTIC_THRESHOLD": 1000},
           business_name="x", industry_alignment="y")
    except Exception:
        pass  # LLM path will fail later on missing globals/stub-raise; we only assert the gate decision
    assert heuristic_calls == [], "bulk heuristic must NOT fire when count <= threshold"
    assert any("Using LLM-based cycle breaking" in m for m in log.infos), "should fall through to LLM path"
