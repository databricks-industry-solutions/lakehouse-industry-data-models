"""v3.2.1 behavioral tests.

Root-cause fixes for the gov_transport mvm_v2 stall (38.9% / 28-of-72 VREQs after 337min).
Every test proves the NEW behavior AND that the pre-patch behavior would have failed
(CLAUDE.md §8.3 anti-tautology, §8.10 behavioral-not-noop).

Fixes covered:
  (1) vov-perbatch-budget-raise          90->240 base, 300->480 cap  (27 time_budget_exceeded VREQs)
  (2) vov-batch-budget-narrower-revert   64000->48000 split budget
  (3) vov-lowprog-converge-window        oscillation-robust convergence guard
  (4) vov-allow-ast-nonlocal             sandbox accepts `nonlocal`, still rejects `global`
  (5) vov-mv-floor-user-override         user "exactly N MVs" beats the v204 preservation floor (§3c)
  (6) vov-model-meta-diff                model-level metadata changes are real diffs, not noops
"""
import ast
import json
import os
import re
import types

import pytest

NB = os.path.join(os.path.dirname(__file__), "..", "..", "agent", "dbx_vibe_modelling_agent.ipynb")


def _load_src():
    nb = json.load(open(NB))
    return "".join("".join(c.get("source", [])) for c in nb["cells"] if c.get("cell_type") == "code")


def _slice_module_def(full, def_name):
    start = full.index(f"def {def_name}")
    lines = full[start:].split("\n")
    out = [lines[0]]
    for ln in lines[1:]:
        if ln.strip() == "" or ln[:1] in (" ", "\t"):
            out.append(ln)
        else:
            break
    return "\n".join(out)


def _dummy_logger():
    lg = types.SimpleNamespace()
    for m in ("info", "warning", "error", "debug"):
        setattr(lg, m, lambda *a, **k: None)
    return lg


# --------------------------------------------------------------------------- #
# (4) vov-allow-ast-nonlocal
# --------------------------------------------------------------------------- #
def _load_validate_ast():
    full = _load_src()
    i = full.index("ALLOWED_AST_NODES = frozenset")
    end = full.index("def required_function_present")
    block = full[i:end]
    ns = {"ast": ast, "logger": _dummy_logger(), "frozenset": frozenset}
    exec(block, ns)
    return ns["validate_ast"], ns["UnsafeCodeError"]


def test_nonlocal_accepted_global_still_rejected():
    validate_ast, UnsafeCodeError = _load_validate_ast()
    # nonlocal: enclosing-scope rebind used by LLM helper closures (gov_transport VREQ-084 rejection)
    nonlocal_src = (
        "def f(model):\n"
        "    acc = 0\n"
        "    def bump():\n"
        "        nonlocal acc\n"
        "        acc = acc + 1\n"
        "    bump()\n"
        "    return acc\n"
    )
    validate_ast(nonlocal_src)  # must NOT raise post-patch

    # global stays banned (can rebind module-level names => higher risk)
    global_src = "def f(model):\n    global X\n    X = 1\n    return model\n"
    with pytest.raises(UnsafeCodeError):
        validate_ast(global_src)


def test_nonlocal_in_allowed_ast_nodes_source():
    full = _load_src()
    assert "ast.Nonlocal," in full, "ast.Nonlocal must be in ALLOWED_AST_NODES"
    # anti-regression: ast.Global must NOT be added to the allow-list
    i = full.index("ALLOWED_AST_NODES = frozenset")
    j = full.index("ALLOWED_BUILTINS = frozenset")
    # allow-list entries are `ast.<Node>,`; the comma form must be absent for Global
    assert "ast.Global," not in full[i:j], "ast.Global must remain banned"


# --------------------------------------------------------------------------- #
# (5) vov-mv-floor-user-override
# --------------------------------------------------------------------------- #
def _load_verify_invariants():
    full = _load_src()
    src = _slice_module_def(full, "verify_invariants")
    ns = {"logger": _dummy_logger()}
    exec(_slice_module_def(full, "verify_scope_invariants"), ns)
    exec(src, ns)
    return ns["verify_invariants"]


def _snap(**kw):
    base = dict(
        user_pinned_domains=frozenset(),
        user_pinned_products=frozenset(),
        agent_version="",
        locked_fields=(),
        initial_mv_count=12,
        initial_mv_names=tuple(f"mv_{i}" for i in range(12)),
        mv_floor_override=0,
    )
    base.update(kw)
    return types.SimpleNamespace(**base)


def _model_with_mvs(names):
    return {"model": {"domains": [], "metric_views": [{"view_name": n} for n in names]}}


def test_mv_override_lets_user_shrink_below_floor():
    verify_invariants = _load_verify_invariants()
    # User said "exactly 3 metric views" (Vacancy Rate / Retirement Eligibility / Total Positions),
    # none of which are baseline names. Baseline 12 => v204 floor 7 + 80% name check.
    target = _model_with_mvs(["Vacancy Rate", "Retirement Eligibility", "Total Positions"])

    # PRE-PATCH behavior (override unset): MUST reject (proves anti-tautology)
    ok_no_override, diag_no = verify_invariants(target, _snap(mv_floor_override=0))
    assert ok_no_override is False
    assert "metric_views collection deletion" in diag_no

    # POST-PATCH behavior (override=3): MUST accept
    ok_override, diag_ov = verify_invariants(target, _snap(mv_floor_override=3))
    assert ok_override is True, f"override should accept user-directed shrink, got: {diag_ov}"


def test_mv_override_still_blocks_clobber_to_zero():
    verify_invariants = _load_verify_invariants()
    empty = _model_with_mvs([])
    ok, diag = verify_invariants(empty, _snap(mv_floor_override=3))
    assert ok is False
    assert "clobber-to-zero" in diag


def test_mv_silent_vibe_keeps_v204_invariant():
    verify_invariants = _load_verify_invariants()
    # No override => the original v204 floor must still protect against MV collapse
    collapsed = _model_with_mvs(["mv_0", "mv_1"])  # 2 < floor 7
    ok, diag = verify_invariants(collapsed, _snap(mv_floor_override=0))
    assert ok is False
    assert "metric_views collection deletion" in diag


# --------------------------------------------------------------------------- #
# (6) vov-model-meta-diff
# --------------------------------------------------------------------------- #
def _load_diff_summary():
    full = _load_src()
    src = _slice_module_def(full, "diff_models_summary")
    ns = {"json": json}
    exec(src, ns)
    return ns["diff_models_summary"]


def test_model_level_metadata_change_is_not_noop():
    diff = _load_diff_summary()
    before = {"model": {"domains": [], "metric_views": []}}
    after = {"model": {"domains": [], "metric_views": [],
                       "model_governance": {"systems_of_record": ["SAP"], "governing_bodies": ["gov_transport"]}}}
    d = diff(before, after)
    assert d["model_meta_changed"] is True
    assert "model_governance" in d["model_meta_keys_changed"]


def test_pure_noop_reports_no_model_meta_change():
    diff = _load_diff_summary()
    m = {"model": {"domains": [{"name": "x", "products": []}], "metric_views": []}}
    d = diff(json.loads(json.dumps(m)), json.loads(json.dumps(m)))
    assert d["model_meta_changed"] is False
    assert not d["model_meta_keys_changed"]


def test_agent_version_bump_alone_is_not_model_meta_change():
    # agent_version is re-stamped on every rewrite; it must NOT count as a real change
    diff = _load_diff_summary()
    before = {"model": {"domains": [], "agent_version": "3.2.0"}}
    after = {"model": {"domains": [], "agent_version": "3.2.1"}}
    d = diff(before, after)
    assert d["model_meta_changed"] is False


# --------------------------------------------------------------------------- #
# (3) vov-lowprog-converge-window
# --------------------------------------------------------------------------- #
def test_lowprog_window_fires_on_oscillating_sequence():
    """Replicate the EXACT gov_transport mvm_v2 coverage sequence and prove the new
    window predicate fires while the old consecutive-streak predicate never did."""
    seq = [36.1, 37.5, 37.5, 38.9, 38.9]  # observed gov_transport mvm_v2 cumulative_cov per iter

    # OLD predicate: streak of 2 consecutive <1% iters (never reached on oscillation)
    prev = -1.0
    streak = 0
    old_fired = False
    for idx, cov in enumerate(seq, start=1):
        if idx >= 3 and (cov - prev) < 1.0:
            streak += 1
        else:
            streak = 0
        prev = cov
        if streak >= 2:
            old_fired = True
    assert old_fired is False, "anti-tautology: old streak guard must NOT fire on the oscillating gov_transport seq"

    # NEW predicate: trailing 3-iter window gain < 1.5 (fires)
    hist = []
    new_fired = False
    for idx, cov in enumerate(seq, start=1):
        hist.append(cov)
        if idx >= 4 and len(hist) >= 4 and (hist[-1] - hist[-4]) < 1.5:
            new_fired = True
    assert new_fired is True, "new window guard must converge-stop on the oscillating gov_transport seq"


def test_lowprog_window_does_not_fire_on_healthy_climb():
    seq = [10.0, 15.0, 21.0, 28.0, 36.0]  # ~6%+/iter healthy climb
    hist = []
    fired = False
    for idx, cov in enumerate(seq, start=1):
        hist.append(cov)
        if idx >= 4 and len(hist) >= 4 and (hist[-1] - hist[-4]) < 1.5:
            fired = True
    assert fired is False, "must not premature-stop a healthy climbing run"


def test_lowprog_window_source_present():
    full = _load_src()
    assert "vov-lowprog-converge-window" in full
    assert "_v321_cov_history" in full
    assert "(_v321_cov_history[-1] - _v321_cov_history[-4]) < 1.5" in full


# --------------------------------------------------------------------------- #
# (1)(2) budget literals + version
# --------------------------------------------------------------------------- #
def test_perbatch_budget_literals():
    full = _load_src()
    assert "_handler_time_budget = 240.0" in full, "base per-batch budget must be 240s"
    assert "min(480.0, _handler_time_budget * 2.0)" in full, "escalation cap must be 480s"
    assert "min(300.0, _handler_time_budget * 2.0)" not in full, "old 300s cap must be gone"


def test_batch_split_budget_reverted():
    full = _load_src()
    assert "budget=48000)" in full, "batch split budget must be reverted to 48000"
    assert "budget=64000)" not in full, "v3.2.0 64000 budget must be gone"


def test_agent_version_is_321():
    full = _load_src()
    m = re.search(r'__AGENT_VERSION__\s*=\s*"([0-9.]+)"', full)
    assert m, "version constant not found"
    assert tuple(int(x) for x in m.group(1).split(".")) >= (3, 2, 1)
