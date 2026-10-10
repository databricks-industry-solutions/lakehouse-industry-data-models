"""Behavioral tests for v2.8.5 — VOV performance fixes.

The v2.8.4 swarm sat in iteration 1 for >100 min because most synthesis batches
carried EITHER empty target_entities (LLM batcher emitted none -> blind synthesis
-> post-condition fail -> 3x retry) OR the global ("*","*") wildcard (heuristic /
orphan fallback). A global-target batch conflicts with EVERY other batch in
`plan_waves` (`_conflicts` short-circuits on global), so each one became its own
singleton wave -> the apply phase ran fully sequentially.

v2.8.5:
  FIX 1A [vov-deterministic-target-resolve] — resolve concrete (domain,product)
    targets from the VREQ text against the live model before synthesis. Concrete
    disjoint targets let plan_waves co-schedule them in ONE wave (parallel) and give
    the synthesizer the exact entities to mutate. Empty result -> keep global (no regression).
  FIX 2A [vov-prompt-cap-24-16] — cap data_payload 24KB + broader digest 16KB.
  FIX 3B [vov-perf-12workers] — synthesis pool reuses run_parallel_with_rate_limit_backoff
    start_workers=12 (429-aware ladder); apply waves min(12, len(wave)).

Each test exercises the REAL notebook source (sliced/execed) and asserts the
OBSERVABLE contrast (concrete -> 1 parallel wave vs global -> N serial waves),
which is exactly the behavior pre-patch lacked.
"""
import ast
import re

from notebook_source_util import notebook_concat_source, slice_function_source

SRC = notebook_concat_source()


# ---------- version + sentinel contract ----------

def test_version_285_and_aliases_present():
    m = re.search(r'__AGENT_VERSION__\s*=\s*"([^"]+)"', SRC)
    assert m and tuple(int(_x) for _x in m.group(1).split(".")) >= (2, 8, 5), f"expected 2.8.5, got {m and m.group(1)}"
    assert "vov-deterministic-target-resolve FIRED" in SRC
    assert "vov-perf-12workers FIRED" in SRC
    assert "vov-prompt-cap-24-16 FIRED" in SRC


# ---------- FIX 1A: deterministic target resolver ----------

def _exec_resolver_ns():
    ns = {"__name__": "_v285_ns", "_VIBE_SCOPE_RUNTIME": None}
    for name in ["_vov285_san", "_vov285_build_model_index", "_vov285_resolve_target_entities"]:
        exec(compile(slice_function_source(name, source=SRC), f"<{name}>", "exec"), ns)
    return ns


def _model():
    return {
        "model": {
            "domains": [
                {"name": "finance", "products": [
                    {"name": "invoice", "attributes": []},
                    {"name": "payment", "attributes": []},
                ]},
                {"name": "sales", "products": [
                    {"name": "order", "attributes": []},
                    {"name": "customer", "attributes": []},
                ]},
            ]
        }
    }


def test_resolver_dotted_reference():
    ns = _exec_resolver_ns()
    pairs, doms = ns["_vov285_build_model_index"](_model())
    assert ("sales", "order") in pairs and ("finance", "invoice") in pairs
    res = ns["_vov285_resolve_target_entities"](
        ["add a foreign key from sales.order to finance.invoice"], pairs, doms
    )
    assert ("sales", "order") in res
    assert ("finance", "invoice") in res


def test_resolver_bare_product_name():
    ns = _exec_resolver_ns()
    pairs, doms = ns["_vov285_build_model_index"](_model())
    res = ns["_vov285_resolve_target_entities"](
        ["apply the source-trace tag to the payment table"], pairs, doms
    )
    assert ("finance", "payment") in res
    # must NOT over-resolve the whole model from one product mention
    assert ("sales", "customer") not in res


def test_resolver_domain_expands_to_products():
    ns = _exec_resolver_ns()
    pairs, doms = ns["_vov285_build_model_index"](_model())
    res = ns["_vov285_resolve_target_entities"](
        ["rebuild every product in the finance domain"], pairs, doms
    )
    assert ("finance", "invoice") in res and ("finance", "payment") in res
    # finance-only mention should not pull sales products
    assert ("sales", "order") not in res


def test_resolver_returns_empty_when_unresolvable():
    """No model entity referenced -> () so the caller keeps its global fallback (no regression)."""
    ns = _exec_resolver_ns()
    pairs, doms = ns["_vov285_build_model_index"](_model())
    res = ns["_vov285_resolve_target_entities"](
        ["do something vague with no entity reference at all"], pairs, doms
    )
    assert res == ()


# ---------- FIX 1A x 3B: concrete targets unlock plan_waves parallelism ----------

def _exec_planwaves_ns():
    ns = {"__name__": "_v285_pw"}
    for name in ["_entities_set", "_has_global", "_conflicts", "plan_waves"]:
        exec(compile(slice_function_source(name, source=SRC), f"<{name}>", "exec"), ns)
    return ns


class _H:
    def __init__(self, te):
        self.target_entities = tuple(te)


def test_concrete_disjoint_targets_share_one_parallel_wave():
    """The whole point of FIX 1A: two batches with concrete DISJOINT targets must be
    co-scheduled in a SINGLE wave so the apply ThreadPoolExecutor runs them in parallel."""
    ns = _exec_planwaves_ns()
    plan_waves = ns["plan_waves"]
    handlers = [_H([("sales", "order")]), _H([("finance", "invoice")])]
    waves = plan_waves(handlers)
    assert len(waves) == 1, f"disjoint concrete targets must be one parallel wave, got {len(waves)} waves"
    assert len(waves[0]) == 2


def test_global_targets_force_serial_singleton_waves():
    """Pre-patch behavior we are escaping: a global ('*','*') batch conflicts with every
    other batch and is forced into its own wave -> sequential apply."""
    ns = _exec_planwaves_ns()
    plan_waves = ns["plan_waves"]
    handlers = [_H([("*", "*")]), _H([("sales", "order")])]
    waves = plan_waves(handlers)
    assert len(waves) == 2, f"a global batch must serialize into its own wave, got {len(waves)}"


def test_resolution_then_planwaves_end_to_end():
    """End-to-end: two 'blind' batches resolve to concrete disjoint targets and then
    co-schedule into ONE parallel wave; without resolution (global) they'd be 2 serial waves."""
    rns = _exec_resolver_ns()
    pwns = _exec_planwaves_ns()
    pairs, doms = rns["_vov285_build_model_index"](_model())
    te1 = rns["_vov285_resolve_target_entities"](["tag the sales.order table"], pairs, doms)
    te2 = rns["_vov285_resolve_target_entities"](["tag the finance.invoice table"], pairs, doms)
    assert te1 and te2 and set(te1).isdisjoint(set(te2))
    waves_resolved = pwns["plan_waves"]([_H(te1), _H(te2)])
    waves_global = pwns["plan_waves"]([_H([("*", "*")]), _H([("*", "*")])])
    assert len(waves_resolved) == 1   # post-patch: parallel
    assert len(waves_global) == 2     # pre-patch: serial


# ---------- FIX 2A: prompt caps (regression guards) ----------

def test_prompt_caps_tightened():
    assert "> 24576" in SRC, "data_payload cap must be 24KB"
    assert "> 16384" in SRC, "broader digest cap must be 16KB"
    # the old loose caps for these two sites must be gone
    assert "_dp_full[:65536]" not in SRC
    assert "_digest_str[:32768]" not in SRC


# ---------- FIX 3B: 12-worker pool wiring (regression guards) ----------

def test_synthesis_uses_rate_limit_backoff_pool_with_12_workers():
    assert "run_parallel_with_rate_limit_backoff(list(batches), _synth_one, start_workers=max_workers" in SRC
    assert "max_workers=min(12, len(wave))" in SRC
    # default synthesis worker count is 12
    tree = ast.parse(SRC)
    fn = next(n for n in ast.walk(tree)
              if isinstance(n, ast.FunctionDef) and n.name == "synthesize_batch_handlers")
    defaults = {a.arg: d for a, d in zip(fn.args.args[-len(fn.args.defaults):], fn.args.defaults)}
    assert isinstance(defaults["max_workers"], ast.Constant) and defaults["max_workers"].value == 12
