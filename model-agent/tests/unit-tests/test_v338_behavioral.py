import json, re, os, textwrap, pytest

from notebook_source_util import pk_suffix_globals

REPO = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
NB = os.path.join(REPO, "agent", "dbx_vibe_modelling_agent.ipynb")
NB_PRE = "/tmp/agent_pre_v338.ipynb"

SENTINEL = {"status": "SENTINEL_FELL_THROUGH", "evidence": "fell-through"}


def _full_src(path):
    nb = json.load(open(path))
    return "".join(
        "".join(c.get("source", [])) if isinstance(c.get("source"), list) else c.get("source", "")
        for c in nb["cells"]
    )


def _extract_fn(src, name):
    m = re.search(rf"\n    def {name}\(self.*?\n    def ", src, re.S)
    assert m, f"{name} not found"
    body = m.group(0)
    body = body[: body.rfind("\n    def ")]
    return textwrap.dedent(body)


class _Logger:
    def info(self, *a, **k): pass
    def warning(self, *a, **k): pass
    def error(self, *a, **k): pass


def _bind_verify_requirement(path):
    src = _full_src(path)
    ns = {"re": re, **pk_suffix_globals()}
    exec(_extract_fn(src, "_verify_requirement"), ns)
    if "def _verify_domain_structural_op(self" in src:
        for name in ("_v337_negated_before", "_v337_extract_domain_rename", "_v337_extract_domain_merge",
                     "_v337_extract_bulk_move", "_v407_resolve_dp"):
            exec(re.search(rf"(?ms)^def {name}\(.*?(?=^\S)", src).group(0), ns)
        exec(_extract_fn(src, "_verify_domain_structural_op"), ns)

    class Dummy:
        logger = _Logger()
        ai_agent = None
        _llm_verify_enabled = False
        _step_snapshots = {}
        widgets_values = {}
        config = {}

        def _verify_deterministic(self, *a, **k): return dict(SENTINEL)
        def _verify_state_diff(self, *a, **k): return dict(SENTINEL)
        def _verify_structural_target(self, *a, **k): return dict(SENTINEL)
        def _verify_via_llm(self, *a, **k): return dict(SENTINEL)
        def _verify_count_shape(self, *a, **k): return None

    Dummy._verify_requirement = ns["_verify_requirement"]
    if "_verify_domain_structural_op" in ns:
        Dummy._verify_domain_structural_op = ns["_verify_domain_structural_op"]
    return Dummy()


class _Req:
    def __init__(self, text, rid="VREQ-T", strategy="llm_verify"):
        self.original_text = text
        self.id = rid
        self.verification_strategy = strategy
        self.scope_targets = []


def _attrs(rows):
    # rows: (domain, product, attribute, foreign_key_to)
    return [{"domain": d, "product": p, "attribute": a, "foreign_key_to": fk} for d, p, a, fk in rows]


VERIFY_ONLY_TEXT = (
    "Verify only (no action needed): the FKs succession_plan.job_family_id, "
    "rif_group.job_family_id, and plan_inclusion.milestone_id are already correctly linked."
)


def test_verify_only_all_linked_returns_fulfilled():
    obj = _bind_verify_requirement(NB)
    req = _Req(VERIFY_ONLY_TEXT)
    attrs = _attrs([
        ("hr", "succession_plan", "job_family_id", "hr.job_family.job_family_id"),
        ("hr", "rif_group", "job_family_id", "hr.job_family.job_family_id"),
        ("project", "plan_inclusion", "milestone_id", "project.milestone.milestone_id"),
    ])
    res = obj._verify_requirement(req, [], [], attrs)
    assert res["status"] == "fulfilled", res
    assert "verifier-verify-only-no-change" in res["evidence"]


def test_verify_only_unlinked_falls_through():
    # asserted columns present but NOT linked -> genuine miss -> fall through (not my fulfilled)
    obj = _bind_verify_requirement(NB)
    req = _Req(VERIFY_ONLY_TEXT)
    attrs = _attrs([
        ("hr", "succession_plan", "job_family_id", ""),
        ("hr", "rif_group", "job_family_id", ""),
        ("project", "plan_inclusion", "milestone_id", ""),
    ])
    res = obj._verify_requirement(req, [], [], attrs)
    # contract: an unlinked verify-only directive must NOT be falsely marked fulfilled by our branch
    assert res["status"] != "fulfilled"
    assert "verifier-verify-only-no-change" not in res.get("evidence", "")


def test_verify_only_no_parseable_target_informational():
    obj = _bind_verify_requirement(NB)
    req = _Req("Verify only (no action needed): the model is internally consistent.")
    res = obj._verify_requirement(req, [], [], _attrs([]))
    assert res["status"] == "informational"
    assert "verifier-verify-only-no-change" in res["evidence"]


def test_non_verify_only_directive_unaffected():
    # a normal directive must NOT be caught by the verify-only branch
    obj = _bind_verify_requirement(NB)
    req = _Req("connect_table hr.position: add column salary_grade_id with FK to hr.salary_grade")
    attrs = _attrs([("hr", "position", "salary_grade_id", "hr.salary_grade.salary_grade_id")])
    res = obj._verify_requirement(req, [], [], attrs)
    # a normal connect_table directive must not be intercepted by the verify-only branch
    assert "verifier-verify-only-no-change" not in res.get("evidence", "")


@pytest.mark.skipif(not os.path.exists(NB_PRE), reason="pre-v338 backup not present")
def test_pre_patch_verify_only_not_fulfilled_by_branch():
    # NON-TAUTOLOGY proof: on pre-v338 code the same verify-only+linked input must NOT
    # return the verify-only fulfilled verdict (it falls through to state-diff -> sentinel).
    obj = _bind_verify_requirement(NB_PRE)
    req = _Req(VERIFY_ONLY_TEXT)
    attrs = _attrs([
        ("hr", "succession_plan", "job_family_id", "hr.job_family.job_family_id"),
        ("hr", "rif_group", "job_family_id", "hr.job_family.job_family_id"),
        ("project", "plan_inclusion", "milestone_id", "project.milestone.milestone_id"),
    ])
    res = obj._verify_requirement(req, [], [], attrs)
    assert "verifier-verify-only-no-change" not in res.get("evidence", "")
