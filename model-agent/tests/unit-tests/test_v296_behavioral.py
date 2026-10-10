"""Behavioral tests for v2.9.6 VREQ severity-first prioritization + defer + merge-user-first.

Per CLAUDE.md 8.10 these are BEHAVIORAL (exercise the real extracted code paths and prove the
pre-patch failure mode), not static-grep tautologies. The three real helper functions
(_v296_norm_severity, _v296_sev_rank, _v296_sort_vreqs) are extracted verbatim from the deployed
notebook cell and exec'd against a stub RawVREQ, so the test runs THE PRODUCTION SORT, not a copy.
"""
import ast
import json
import os
import re
from dataclasses import dataclass

NB = os.path.join(os.path.dirname(__file__), "..", "..", "agent", "dbx_vibe_modelling_agent.ipynb")


def _code_src():
    nb = json.load(open(NB))
    return "\n".join("".join(c.get("source", [])) for c in nb.get("cells", []) if c.get("cell_type") == "code")


@dataclass
class _StubVREQ:
    vreq_id: str
    severity: str = "medium"
    is_user_directive: bool = False
    priority_id: int = 9999


def _extract_real_helpers():
    """Pull the actual v296 sort helpers out of the notebook and exec them."""
    src = _code_src()
    tree = ast.parse(src)
    wanted = {"_v296_norm_severity", "_v296_sev_rank", "_v296_sort_vreqs"}
    pieces = []
    for node in tree.body:
        if isinstance(node, ast.FunctionDef) and node.name in wanted:
            pieces.append(ast.get_source_segment(src, node))
        if isinstance(node, ast.Assign):
            for t in node.targets:
                if isinstance(t, ast.Name) and t.id == "_V296_SEV_RANK":
                    pieces.append(ast.get_source_segment(src, node))
    assert len(pieces) >= 4, f"expected 3 funcs + 1 const, got {len(pieces)}"
    ns = {}
    exec("\n\n".join(pieces), ns)
    return ns


# ---------------- static wiring (smoke) ----------------

def test_agent_version_is_296():
    m = re.search(r'__AGENT_VERSION__ = "(\d+)\.(\d+)\.(\d+)"', _code_src())
    assert m, "version constant not found"
    assert tuple(int(x) for x in m.groups()) >= (2, 9, 6)


def test_aliases_present():
    src = _code_src()
    for a in ("alias=vov-severity-first", "alias=vov-defer-low-severity", "alias=vov-merge-user-first"):
        assert a in src, "missing " + a


def test_rawvreq_carries_new_fields():
    src = _code_src()
    assert 'severity: str = "medium"' in src
    assert "is_user_directive: bool = False" in src
    assert "priority_id: int = 9999" in src


def test_sort_wired_into_both_branches():
    src = _code_src()
    # raw branch
    assert "_vs_work = list(deduped)" in src
    assert "_remaining_vreqs = _v296_sort_vreqs(list(_vs_work))" in src
    # priority branch
    assert "_v296_sort_vreqs([_v251_priority_to_vreq(_p) for _p in _parsed_priorities])" in src


def test_extraction_prompt_requests_severity():
    src = _code_src()
    assert "severity: how serious this requirement is" in src
    assert "is_user_directive: true if this requirement comes from text under" in src


def test_defer_writes_to_next_vibes():
    src = _code_src()
    assert "DEFERRED VIBES (carried from the previous run" in src
    assert 'widgets_values.get("_v296_deferred_vreqs")' in src
    assert "deferred_vreqs: list = field(default_factory=list)" in src


def test_merge_user_first_replaced_by_single_source_vibes():
    src = _code_src()
    assert "MERGED user vibes" not in src
    assert "def _vov_single_source_vibes(" in src
    assert "[vov-vibes-required FIRED v5.1.4]" in src


# ---------------- behavioral (real extracted code) ----------------

def test_severity_rank_order():
    ns = _extract_real_helpers()
    rk = ns["_v296_sev_rank"]
    assert rk("critical") < rk("high") < rk("medium") < rk("low")
    # normalisation
    norm = ns["_v296_norm_severity"]
    assert norm("BLOCKER") == "critical"
    assert norm("major") == "high"
    assert norm("cosmetic") == "low"
    assert norm("") == "medium"
    assert norm(None) == "medium"


def test_user_directive_always_first_regardless_of_severity():
    """The user's directive: USER VIBES ALWAYS FIRST, then auto critical->low."""
    ns = _extract_real_helpers()
    sort = ns["_v296_sort_vreqs"]
    vreqs = [
        _StubVREQ("auto-crit", severity="critical", is_user_directive=False),
        _StubVREQ("user-low", severity="low", is_user_directive=True),
        _StubVREQ("auto-high", severity="high", is_user_directive=False),
        _StubVREQ("user-med", severity="medium", is_user_directive=True),
    ]
    out = [v.vreq_id for v in sort(vreqs)]
    # both user VREQs must precede both auto VREQs, even though auto-crit is critical and user-low is low.
    assert out.index("user-low") < out.index("auto-crit")
    assert out.index("user-med") < out.index("auto-crit")
    # within user group, severity still orders (med before low)
    assert out.index("user-med") < out.index("user-low")
    # within auto group, critical before high
    assert out.index("auto-crit") < out.index("auto-high")
    assert out == ["user-med", "user-low", "auto-crit", "auto-high"]


def test_pre_patch_fifo_would_strand_critical_but_sort_rescues_it():
    """PRE-PATCH failure mode: a critical VREQ at the TAIL of FIFO extraction order stays at the tail,
    so on budget exhaustion it is dropped. POST-PATCH: the sort floats it to the front."""
    ns = _extract_real_helpers()
    sort = ns["_v296_sort_vreqs"]
    # extraction order: 100 trivial low-severity renames, then ONE critical missing-FK last.
    vreqs = [_StubVREQ(f"cosmetic-{i}", severity="low", is_user_directive=False) for i in range(100)]
    vreqs.append(_StubVREQ("critical-fk", severity="critical", is_user_directive=False))

    # pre-patch behaviour == FIFO: the critical is last; a budget that stops at N<101 never reaches it.
    fifo = [v.vreq_id for v in vreqs]
    assert fifo[-1] == "critical-fk", "pre-patch FIFO strands the critical at the tail"
    assert fifo.index("critical-fk") == 100

    # post-patch: severity-first sort puts the critical FIRST.
    out = [v.vreq_id for v in sort(vreqs)]
    assert out[0] == "critical-fk", "post-patch sort must float the critical to the front"
    assert out.index("critical-fk") < 1


def test_stable_within_equal_rank():
    ns = _extract_real_helpers()
    sort = ns["_v296_sort_vreqs"]
    vreqs = [_StubVREQ(f"m{i}", severity="medium", is_user_directive=False) for i in range(5)]
    out = [v.vreq_id for v in sort(vreqs)]
    assert out == ["m0", "m1", "m2", "m3", "m4"], "equal-rank VREQs must keep authoring order"


def test_priority_id_tiebreaker():
    ns = _extract_real_helpers()
    sort = ns["_v296_sort_vreqs"]
    vreqs = [
        _StubVREQ("p5", severity="high", is_user_directive=True, priority_id=5),
        _StubVREQ("p1", severity="high", is_user_directive=True, priority_id=1),
        _StubVREQ("p3", severity="high", is_user_directive=True, priority_id=3),
    ]
    out = [v.vreq_id for v in sort(vreqs)]
    assert out == ["p1", "p3", "p5"], "lower priority_id must sort earlier when severity+origin equal"


# ---------------- merge sentinel parse (real regex behaviour) ----------------

def test_parse_priorities_sentinel_marks_origin():
    """_v251_parse_priorities must mark PRIORITY lines after the AUTO sentinel is_user_directive=False."""
    src = _code_src()
    tree = ast.parse(src)
    # extract _V251_PRIORITY_LINE_RE assignment + _v251_parse_priorities
    re_assign = None
    fn = None
    for node in tree.body:
        if isinstance(node, ast.Assign):
            for t in node.targets:
                if isinstance(t, ast.Name) and t.id == "_V251_PRIORITY_LINE_RE":
                    re_assign = ast.get_source_segment(src, node)
        if isinstance(node, ast.FunctionDef) and node.name == "_v251_parse_priorities":
            fn = ast.get_source_segment(src, node)
    assert re_assign and fn, "could not extract priority parser"
    ns = {"re": __import__("re")}
    exec(re_assign + "\n\n" + fn, ns)
    parse = ns["_v251_parse_priorities"]

    text = (
        "=== USER VIBES (SUPREME AUTHORITY - APPLY FIRST) ===\n"
        "**PRIORITY 1 — connect_table: customer.order** — add FK to product because reason\n"
        "=== AUTO-GENERATED NEXT_VIBES (LOWER PRIORITY) ===\n"
        "**PRIORITY 2 — rename_attribute: customer.order** — rename col_a to col_b because reason\n"
    )
    pr = parse(text)
    by_id = {p["vreq_id"]: p for p in pr}
    assert by_id["P001"]["is_user_directive"] is True, "PRIORITY before AUTO sentinel = user"
    assert by_id["P002"]["is_user_directive"] is False, "PRIORITY after AUTO sentinel = auto"

    # no sentinel at all -> everything is the user's
    text2 = "**PRIORITY 1 — connect_table: a.b** — x because y\n"
    pr2 = parse(text2)
    assert pr2[0]["is_user_directive"] is True


if __name__ == "__main__":
    for fn in [v for k, v in sorted(globals().items()) if k.startswith("test_")]:
        fn()
        print("ok", fn.__name__)
