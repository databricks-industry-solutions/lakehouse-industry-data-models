"""v2.9.2 behavioral tests: agentic EXTRACTION + APPLICATION guarantee (real production code).

Three root-cause fixes to the live VOV engine (cell 3), proven to FAIL on pre-patch HEAD:

  FIX-EXTRACT alias=vov-extract-completeness-audit
     A first-pass LLM extractor silently DROPS user instructions; coverage measured against the
     dropped set looks high while the user got less (the denominator lie). The auditor recovers the
     missing instructions so the denominator is the TRUE instruction count.

  FIX-APPLY alias=vov-residual-fixpoint
     The loop used STALE-BREAK to give up after ONE zero-progress iteration, abandoning 3-29 user
     requirements with budget to spare. Replaced with fixpoint detection + handler-time-budget
     escalation (90->300s) so residual VREQs (incl time_budget_exceeded) are re-planned, not dropped.

  FIX-MATH alias=vov-coverage-honest-v292
     Pre-patch divided applied-ids-from-ALL-outcomes by len(deduped) (raw-vibe only) -> >100%
     (observed 102.5%). Now same-population denominator (universe intersection) + clamp <=100.

  alias=vov-priority-completeness : priority-branch denominator guard (parsed vs PRIORITY markers).
"""
import ast
import json
import logging
import os

NB = os.path.join(os.path.dirname(__file__), "..", "..", "agent", "dbx_vibe_modelling_agent.ipynb")
LOG = logging.getLogger("v292test")

V292_ALIASES = [
    "vov-extract-completeness-audit",
    "vov-residual-fixpoint",
    "vov-coverage-honest-v292",
    "vov-priority-completeness",
]


def _src():
    nb = json.load(open(NB))
    return "".join("".join(c["source"]) for c in nb["cells"] if c.get("cell_type") == "code")


def _load_real():
    """EXEC the real v2.9.2 helper functions + RawVREQ out of the notebook (not a mirror)."""
    nb = json.load(open(NB))
    full = "\n\n".join("".join(c["source"]) for c in nb["cells"] if c.get("cell_type") == "code")
    tree = ast.parse(full)
    want_funcs = {"_v292_audit_extraction_completeness", "_v292_residual_signature", "_v292_duplicate_of"}
    want_assigns = {"_V292_EXTRACTION_AUDIT_PROMPT"}
    ns = {}
    # RawVREQ is a trivial data container (not the logic under test); inject a faithful stub with
    # the same fields so the real auditor function can mint recovered VREQs.
    from dataclasses import dataclass as _dc

    @_dc
    class RawVREQ:  # noqa: N801
        vreq_id: str
        intent: str
        target: str
        source_quote: str
        source_chunk_id: str
        severity: str = "medium"  # v2.9.6 alias=vov-severity-first
        is_user_directive: bool = False  # v2.9.6 alias=vov-merge-user-first
        priority_id: int = 9999  # v2.9.6 alias=vov-severity-first
    ns["RawVREQ"] = RawVREQ
    ns["re"] = __import__("re")
    segs = []
    for node in tree.body:
        if isinstance(node, ast.FunctionDef) and node.name in want_funcs:
            segs.append((node.lineno, ast.get_source_segment(full, node)))
        elif isinstance(node, ast.Assign):
            for t in node.targets:
                if isinstance(t, ast.Name) and t.id in want_assigns:
                    segs.append((node.lineno, ast.get_source_segment(full, node)))
    segs.sort()
    for _, seg in segs:
        exec(compile(seg, "<nb>", "exec"), ns)
    return ns


class _AuditLLM:
    """Stub LLM: returns a scripted sequence of auditor responses."""
    def __init__(self, responses):
        self._responses = list(responses)
        self.calls = 0

    def complete_json(self, system, user, temperature=0.0):
        self.calls += 1
        return self._responses.pop(0) if self._responses else {"missing": []}


# ---------------- version + sentinel ----------------

def test_v292_version_is_292():
    import re
    m = re.search(r'__AGENT_VERSION__\s*=\s*"([^"]+)"', _src())
    assert m, "version missing"
    # Relaxed to >= (matches test_v295 precedent): the v2.9.2 features under test persist
    # in all later versions; pinning an exact string broke spuriously on every bump.
    ver = tuple(int(x) for x in m.group(1).split("."))
    assert ver >= (2, 9, 2), f"expected >= 2.9.2, got {m.group(1)}"
    assert all(len(seg) == 1 for seg in m.group(1).split(".")), "single-digit semver violated"


def test_v292_all_aliases_have_fired_log_site():
    src = _src()
    for alias in V292_ALIASES:
        # each fix has a runtime FIRED emission and an alias= grep anchor (§8.10 sentinel)
        assert (f"[{alias} FIRED" in src) or (f"alias={alias}" in src), f"{alias} has no FIRED/alias emission site"
    # and there is a real FIRED verb for each fix's emission line
    assert "vov-extract-completeness-audit FIRED v2.9.2" in src
    assert "vov-residual-fixpoint FIRED v2.9.2" in src
    assert "vov-coverage-honest FIRED v2.9.2" in src
    assert "vov-priority-completeness FIRED v2.9.2" in src


# ---------------- FIX-EXTRACT (behavioral) ----------------

def test_v292_audit_recovers_dropped_instructions():
    ns = _load_real()
    RawVREQ = ns["RawVREQ"]
    fn = ns["_v292_audit_extraction_completeness"]
    # first pass had ONE vreq; auditor says TWO instructions were dropped, then nothing more.
    deduped = [RawVREQ(vreq_id="V1", intent="tag PII columns", target="all", source_quote="tag pii", source_chunk_id="c1")]
    llm = _AuditLLM([
        {"missing": [
            {"intent": "use snake_case for all columns", "target": "every column", "source_quote": "use snake_case"},
            {"intent": "prefix tags with acme_", "target": "every tag", "source_quote": "tag prefix acme_"},
        ]},
        {"missing": []},
    ])
    out, recovered = fn("use snake_case ... tag prefix acme_ ... tag pii", deduped, llm, LOG, max_passes=3)
    assert recovered == 2, f"auditor must recover the 2 dropped instructions, got {recovered}"
    assert len(out) == 3, f"denominator must grow 1 -> 3, got {len(out)}"
    recovered_ids = {v.vreq_id for v in out if str(v.vreq_id).startswith("AUDIT-")}
    assert len(recovered_ids) == 2, "recovered VREQs must carry AUDIT- ids so the denominator is honest"


def test_v292_audit_noop_when_complete():
    ns = _load_real()
    RawVREQ = ns["RawVREQ"]
    fn = ns["_v292_audit_extraction_completeness"]
    deduped = [RawVREQ(vreq_id="V1", intent="x", target="y", source_quote="z", source_chunk_id="c1")]
    llm = _AuditLLM([{"missing": []}])
    out, recovered = fn("full vibe", deduped, llm, LOG, max_passes=2)
    assert recovered == 0 and len(out) == 1, "no recovery when auditor finds nothing missing"


def test_v292_audit_degrades_on_llm_error():
    ns = _load_real()
    RawVREQ = ns["RawVREQ"]
    fn = ns["_v292_audit_extraction_completeness"]

    class _Boom:
        def complete_json(self, system, user, temperature=0.0):
            raise RuntimeError("endpoint down")

    deduped = [RawVREQ(vreq_id="V1", intent="x", target="y", source_quote="z", source_chunk_id="c1")]
    out, recovered = fn("vibe", deduped, _Boom(), LOG, max_passes=2)
    assert recovered == 0 and len(out) == 1, "auditor failure must degrade gracefully, never crash pipeline"


# ---------------- FIX-APPLY (behavioral) ----------------

def test_v292_residual_signature_detects_true_fixpoint():
    ns = _load_real()
    sig = ns["_v292_residual_signature"]
    a = sig([("VREQ-1", "noop_failed"), ("VREQ-2", "rejected_unsafe")])
    b = sig([("VREQ-2", "rejected_unsafe"), ("VREQ-1", "noop_failed")])  # same set+classes, order-independent
    assert a == b, "same residual set + same failure classes must be equal (true fixpoint)"


def test_v292_residual_signature_changes_on_progress():
    ns = _load_real()
    sig = ns["_v292_residual_signature"]
    base = sig([("VREQ-1", "noop_failed"), ("VREQ-2", "time_budget_exceeded")])
    # a VREQ landed -> smaller residual set -> different signature -> loop must NOT treat as fixpoint
    fewer = sig([("VREQ-1", "noop_failed")])
    assert base != fewer, "shrinking residual must change signature so the loop keeps going"
    # same ids but the failure class shifted (time_budget -> rejected) -> still qualitative change
    shifted = sig([("VREQ-1", "noop_failed"), ("VREQ-2", "rejected_unsafe")])
    assert base != shifted, "changed failure class must change signature"


def test_v292_stalebreak_giveup_removed():
    src = _src()
    # the unconditional give-up log lines that aborted the loop are GONE
    assert "[v260-agentic-loop FIRED] STALE-BREAK iter=" not in src, "priority STALE-BREAK give-up still present"
    assert "[v261-vov-vreq-loop FIRED] STALE-BREAK iter=" not in src, "raw-vibe STALE-BREAK give-up still present"
    # replaced by fixpoint + escalation
    assert "vov-residual-fixpoint FIRED v2.9.2] TRUE-FIXPOINT" in src
    assert "_handler_time_budget * 2.0" in src, "budget escalation missing"


def test_v292_handler_budget_threaded_not_hardcoded_90():
    src = _src()
    # v3.2.1 SUPERSEDED: base per-batch budget raised 90.0 -> 240.0 (alias=vov-perbatch-budget-raise)
    # because large-model attempt-1 sandbox mutate+verify takes 240-360s; 90s blocked every retry.
    # The init must still be a single module-level assignment (threaded, not call-site hardcoded).
    assert "_handler_time_budget = 240.0" in src, "handler budget init missing/expected 240.0"
    # the two apply call-sites no longer pass the bare 90.0 literal
    assert "\n                                        90.0,\n" not in src, "parallel apply still hardcodes 90.0"
    assert "\n                            90.0,\n" not in src, "serial apply still hardcodes 90.0"


# ---------------- FIX-MATH (source contract) ----------------

def test_v292_coverage_same_population_and_clamped():
    src = _src()
    assert "_applied_in_universe = _applied_vreq_set & _universe_ids" in src, \
        "coverage numerator must intersect the committed universe (same population)"
    assert "coverage = min(100.0, 100.0 * n_applied_unique / n_extracted)" in src, \
        "coverage must be clamped <=100 (kills the 102.5% impossibility)"
    # the old cross-population unclamped formula is gone
    assert "    coverage = 100.0 * n_applied_unique / n_extracted\n" not in src, \
        "old unclamped cross-population coverage formula still present"
