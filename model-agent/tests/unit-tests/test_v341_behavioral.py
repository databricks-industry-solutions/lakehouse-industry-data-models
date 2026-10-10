"""v3.4.1 behavioral tests.

Covers the root-cause fixes shipped in v3.4.1:
  RC-AGENTIC  selffixer-aiagent-resolve  -- run_selffixer_or_skip must resolve a usable AIAgent
              from widgets_values / globals when the caller passes ai_agent=None (the orchestrator
              captured a None ai_agent at construction time, leaving the closed-loop fixer inert
              with endpoint=None on every target).
  RC-2b       gt-tag-verify              -- the deterministic tag branch must credit glossary-term,
              prefix-rule, and classification tag VREQs against physically-grounded tags instead of
              returning a blanket 'inconclusive partial'.

Each test asserts behaviour that the PRE-patch code did NOT produce (the new evidence markers
"gt-tag-verify FIRED v3.4.1" / "selffixer-aiagent-resolve" do not exist on pre-patch HEAD).
"""
import json
import os
import re
import textwrap

REPO = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
NB = os.path.join(REPO, "agent", "dbx_vibe_modelling_agent.ipynb")


def _full_src(path=NB):
    nb = json.load(open(path))
    return "".join(
        "".join(c.get("source", [])) if isinstance(c.get("source"), list) else c.get("source", "")
        for c in nb["cells"]
        if c.get("cell_type") == "code"
    )


def _extract_method(src, name):
    """Extract a `    def name(self...` method body (dedented) up to the next sibling def."""
    m = re.search(rf"\n    def {name}\(self.*?\n    def ", src, re.S)
    assert m, f"method {name} not found"
    body = m.group(0)
    body = body[: body.rfind("\n    def ")]
    return textwrap.dedent(body)


def _extract_module_fn(src, name):
    """Extract a module-level `def name(...)` body up to the next top-level def/class."""
    m = re.search(rf"\ndef {name}\(.*?(?=\n(?:def |class )\w)", src, re.S)
    assert m, f"module fn {name} not found"
    return m.group(0)


class _Logger:
    def __init__(self):
        self.lines = []

    def info(self, *a, **k):
        self.lines.append(("INFO",) + a)

    def warning(self, *a, **k):
        self.lines.append(("WARN",) + a)

    def error(self, *a, **k):
        self.lines.append(("ERR",) + a)


class _Req:
    def __init__(self, text, rid="VREQ-T", scope="attribute"):
        self.original_text = text
        self.id = rid
        self.scope = scope
        self.scope_targets = []
        self.verification_strategy = "deterministic"


def _attrs(rows):
    # rows: (domain, product, attribute, foreign_key_to, tags)
    out = []
    for r in rows:
        d, p, a, fk = r[0], r[1], r[2], r[3]
        tags = r[4] if len(r) > 4 else ""
        out.append({"domain": d, "product": p, "attribute": a, "foreign_key_to": fk, "tags": tags})
    return out


# ---------------------------------------------------------------------------
# RC-2b  gt-tag-verify  (cell 9, _verify_deterministic tag branch)
# ---------------------------------------------------------------------------
def _bind_verify_deterministic():
    src = _full_src()
    method = _extract_method(src, "_verify_deterministic")
    import collections
    ns = {"re": re, "json": json, "defaultdict": collections.defaultdict, "collections": collections}
    exec(method, ns)
    # v3.6.8 g3: _verify_deterministic now calls self._verify_bulk_coverage(...) first, so the
    # isolation harness must bind that real method too or it AttributeErrors.
    exec(_extract_method(src, "_verify_bulk_coverage"), ns)

    class Dummy:
        logger = _Logger()

    Dummy._verify_deterministic = ns["_verify_deterministic"]
    Dummy._verify_bulk_coverage = ns["_verify_bulk_coverage"]
    return Dummy()


def test_glossary_term_tag_grounds_fulfilled():
    """A glossary-term VREQ with the matching tag key physically present -> fulfilled."""
    d = _bind_verify_deterministic()
    req = _Req(
        "Attribute-level tag gov_transport_business_glossary_term must carry the CDE glossary term.",
        rid="VREQ-014",
    )
    attrs = _attrs([
        ("hr", "employee", "employee_id", "", "gov_transport_business_glossary_term=Employee Identifier"),
        ("hr", "employee", "tenure_years", "", "gov_transport_business_glossary_term=Tenure"),
    ])
    res = d._verify_deterministic(req, [{"domain": "hr"}], [{"domain": "hr", "product": "employee"}], attrs)
    assert res.get("status") == "fulfilled", res
    assert "gt-tag-verify FIRED v3.4.1" in res.get("evidence", "")


def test_tag_prefix_rule_clean_fulfilled_and_violation_partial():
    """Prefix rule fulfilled when all observed keys carry the prefix; partial when one violates."""
    d = _bind_verify_deterministic()
    req = _Req("All gov_transport-specific tags use the prefix gov_transport_ on every tag key.", rid="VREQ-004")
    clean = _attrs([
        ("hr", "employee", "employee_id", "", "gov_transport_source_attribute=EMP_ID"),
        ("hr", "employee", "salary", "", "gov_transport_source_attribute=SAL"),
    ])
    res_ok = d._verify_deterministic(req, [{"domain": "hr"}], [{"domain": "hr", "product": "employee"}], clean)
    assert res_ok.get("status") == "fulfilled", res_ok
    assert "gt-tag-verify FIRED v3.4.1" in res_ok.get("evidence", "")

    dirty = _attrs([
        ("hr", "employee", "employee_id", "", "gov_transport_source_attribute=EMP_ID"),
        ("hr", "employee", "salary", "", "cg_source_attribute=SAL"),  # violates gov_transport_ prefix
    ])
    res_bad = d._verify_deterministic(req, [{"domain": "hr"}], [{"domain": "hr", "product": "employee"}], dirty)
    assert res_bad.get("status") == "partial", res_bad
    assert "miss prefix" in res_bad.get("evidence", "")


# ---------------------------------------------------------------------------
# RC-AGENTIC  selffixer-aiagent-resolve  (cell 25, run_selffixer_or_skip)
# ---------------------------------------------------------------------------
class _FakeAIAgent:
    """Minimal usable agent: has _v207_call_llm_spark_free so _sf_usable() accepts it."""
    def _v207_call_llm_spark_free(self, *a, **k):
        return ""

    def _call_ai_query(self, *a, **k):
        return ""


def _bind_run_selffixer():
    src = _full_src()
    fn = _extract_module_fn(src, "run_selffixer_or_skip")
    captured = {}

    class _FakeSelfFixer:
        def __init__(self, ai_agent=None, logger=None, sandbox_executor=None, **k):
            captured["ai_agent"] = ai_agent

        def fix_all_unfulfilled(self, *a, **k):
            return {"fixed_count": 0, "remaining_count": 0, "rounds": 1}

    ns = {
        "SelfFixer": _FakeSelfFixer,
        "execute_in_sandbox": lambda *a, **k: None,
        "_VIBE_SCOPE_RUNTIME": None,
    }
    exec(fn, ns)
    return ns["run_selffixer_or_skip"], captured


def test_selffixer_resolves_aiagent_from_widgets_when_passed_none():
    """Caller passes ai_agent=None; resolver must pick up widgets_values['ai_agent']."""
    run_fn, captured = _bind_run_selffixer()
    fake = _FakeAIAgent()
    wv = {
        "_unfulfilled_for_next_vibe": [{"id": "VREQ-1", "text": "x", "attempts": 0}],
        "ai_agent": fake,
    }
    run_fn(model_dict={"domains": []}, widgets_values=wv, ai_agent=None, logger=_Logger())
    assert captured.get("ai_agent") is fake, (
        "SelfFixer received %r, expected the widgets_values ai_agent" % type(captured.get("ai_agent"))
    )


def test_selffixer_keeps_none_when_no_usable_agent_anywhere():
    """No usable agent anywhere -> stays None (honest: closed loop still inert, but no crash)."""
    run_fn, captured = _bind_run_selffixer()
    wv = {
        "_unfulfilled_for_next_vibe": [{"id": "VREQ-1", "text": "x", "attempts": 0}],
        "ai_agent": object(),  # not usable (no _v207/_call_ai_query)
    }
    run_fn(model_dict={"domains": []}, widgets_values=wv, ai_agent=None, logger=_Logger())
    assert captured.get("ai_agent") is None
