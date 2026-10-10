"""v5.1.4 vibe_scope repair loop, scoreboard and next_vibes.

- VibeOrchestrator moves scope-rejected requirements out of verification and scoring.
- _v366_sa_findings_requeue drops findings that only touch frozen entities.
- run_metamodel_static_analysis emits the five vibe_scope gates; division balance is report-only
  for a scoped new-base roster of fewer than 4 domains.
- run_selffixer_or_skip drops out-of-scope reqs, fences every sandbox fix and rolls back any fix
  (including the in-place v410 path) that leaks past the fence.
- next_vibes: scope summary, in-scope priorities first, out-of-scope section with suggested links.
- In-scope quality breakdown, and parity of the refactored native confidence with 5.1.3.
Behavioral tests fail on pre-patch 5d386ed.
"""
import ast
import copy
import json
import logging
import sys
from pathlib import Path

import pytest

sys.path.insert(0, str(Path(__file__).resolve().parent))
import conftest  # noqa: F401,E402
import agent_helpers as ah  # noqa: E402

REPO = Path(__file__).resolve().parents[3]
NOTEBOOK = REPO / "model-agent" / "agent" / "dbx_vibe_modelling_agent.ipynb"
RAW = json.loads((REPO / "data-models" / "airlines" / "v1" / "mvm" / "model.json").read_text())
VOV = "vibe modeling of version"
LOG = logging.getLogger("test_v514_scoreboard")
_ENGINE = ah.widgets_flat_to_model(*ah.model_to_widgets_flat(RAW), agent_version=ah.__AGENT_VERSION__)
LEAKY_FIX = (
    "def mutator(model, data):\n"
    "    root = model.get('model', model)\n"
    "    for d in root['domains']:\n"
    "        for p in (d.get('products') or d.get('data_products') or []):\n"
    "            if d['name'] == 'crew' and p['name'] == 'member':\n"
    "                p['tags'] = 'owner=crew_control'\n"
    "            if d['name'] == 'fleet' and p['name'] == 'aircraft':\n"
    "                p['description'] = 'LEAK from SelfFixer'\n"
    "    return model\n"
)


@pytest.fixture(autouse=True)
def _reset_runtime(monkeypatch):
    monkeypatch.setattr(ah, "logger", LOG, raising=False)
    ah.set_vibe_scope_runtime(None)
    yield
    ah.set_vibe_scope_runtime(None)


def _fence(entries="crew", mode="Some Domains"):
    fence = ah.build_vibe_scope_fence(ah.parse_vibe_scope(mode, entries), RAW, VOV, LOG)
    ah.set_vibe_scope_runtime(fence)
    return fence


def _flat():
    return [copy.deepcopy(list(x)) for x in ah.model_to_widgets_flat(RAW)]


def _row(rows, domain, product, attribute=None):
    for row in rows:
        if row.get("domain") == domain and row.get("product") == product and (attribute is None or row.get("attribute") == attribute):
            return row
    raise KeyError((domain, product, attribute))


def _orchestrator():
    orch = ah.VibeOrchestrator({"logger": LOG, "config": {}, "vibe_modelling_instructions": "vibe"})
    orch.manifest = ah.VibeManifest(raw_text="vibe", requirements=[
        ah.VibeRequirement(id="REQ-1", original_text="rename fleet.engine to powerplant", intent="rename", scope="table"),
        ah.VibeRequirement(id="REQ-2", original_text="add nickname to crew.member", intent="add", scope="attribute"),
        ah.VibeRequirement(id="REQ-3", original_text="add audit columns to crew.member and fleet.aircraft", intent="add", scope="table"),
    ])
    return orch


def test_orchestrator_moves_scope_rejected_requirements_out_of_verification_and_scoring():
    orch = _orchestrator()
    rejected = [ah.RawVREQ("V2", "rename fleet.engine", "fleet.engine", "rename fleet.engine to powerplant", "c"),
                ah.RawVREQ("V3#oos", "add audit columns", "fleet.aircraft", "add audit columns to crew.member and fleet.aircraft", "c")]
    kept = [ah.RawVREQ("V1", "add nickname", "crew.member", "add nickname to crew.member", "c"),
            ah.RawVREQ("V3", "add audit columns [vibe_scope: apply only to crew.member]", "crew.member",
                       "add audit columns to crew.member and fleet.aircraft", "c")]
    assert orch.mark_scope_rejected(rejected, kept) == {"moved": 1, "remaining": 2}
    assert [r.id for r in orch.manifest.requirements] == ["REQ-2", "REQ-3"]
    assert [(r.id, r.status) for r in orch.scope_rejected_requirements] == [("REQ-1", "scope_rejected")]
    for req in orch.manifest.requirements:
        req.mark_fulfilled("verified", "test")
    card = orch.score()
    assert card["total_requirements"] == 2 and card["precision"] == 1.0 and card["scope_rejected"] == 1
    checklist = {row["req_id"]: row["status"] for row in orch.widgets_values["vibe_requirements_checklist"]}
    assert checklist == {"REQ-2": "fulfilled", "REQ-3": "fulfilled", "REQ-1": "scope_rejected"}


def test_fold_still_matches_applied_outcomes_through_the_shared_matcher():
    orch = _orchestrator()
    summary = orch.fold_vov_outcomes({"outcomes": [{"vreq_ids": ["V1"], "status": "applied"}]},
                                     [{"vreq_id": "V1", "intent": "add nickname", "source_quote": "add nickname to crew.member"}])
    assert summary["folded"] == 1
    assert [r.status for r in orch.manifest.requirements] == ["pending", "fulfilled", "pending"]


def test_run_vov_2_marks_orchestrator_and_publishes_scope_outcomes(monkeypatch):
    fence = _fence()
    orch = _orchestrator()
    raw = [ah.RawVREQ("V1", "add nickname", "crew.member", "add nickname to crew.member", "c"),
           ah.RawVREQ("V2", "rename fleet.engine", "fleet.engine", "rename fleet.engine to powerplant", "c")]
    outcomes = [ah.VReqOutcome("b1", ("V1",), "applied", "", 1),
                ah._vibe_scope_triage_outcome("V2", "scope_rejected", "fleet.engine", "targets out-of-scope product fleet.engine")]

    def _fake_pipeline(**kwargs):
        return ah.PipelineResult(initial_model=kwargs["initial_model"], final_model=kwargs["initial_model"], outline=None,
                                 raw_vreqs=raw, batches=[], outcomes=outcomes, coverage_pct=100.0)

    monkeypatch.setattr(ah, "run_vov_pipeline", _fake_pipeline)
    d, p, a, mv = _flat()
    wv = {"ai_agent": object(), "domains": d, "products": p, "attributes": a, "metric_views": mv,
          "vibe_modelling_instructions": "rename fleet.engine", "vibe_orchestrator": orch, "operation": VOV}
    ah.run_vov_2_against_widgets(wv, LOG)
    got = wv["_vibe_scope_outcomes"]
    assert got["scope_rejected"] == [{"vreq_id": "V2", "target": "fleet.engine", "reason": "targets out-of-scope product fleet.engine"}]
    assert got["in_scope_vreq_count"] == 1 and got["adherence_in_scope_pct"] == 100.0
    assert [r.id for r in orch.scope_rejected_requirements] == ["REQ-1"]
    assert fence.report()["mode"] == "domains"


def test_static_analysis_reports_scope_gates_and_nothing_without_a_fence():
    fence = _fence()
    d, p, a, _mv = _flat()
    _row(p, "fleet", "aircraft")["description"] = "leaked out-of-scope edit"
    d.append(dict(d[0], domain="marketing"))
    _row(a, "crew", "member", "member_id")["type"] = "STRING"
    p[:] = [r for r in p if not (r["domain"] == "crew" and r["product"] == "absence")]
    a[:] = [r for r in a if not (r["domain"] == "crew" and r["product"] == "absence")]
    issues = ah.run_metamodel_static_analysis(d, p, a, {}, LOG)["issues"]
    gates = {i["category"]: i for i in issues if i["category"].startswith("vibe_scope_")}
    assert set(gates) == {"vibe_scope_out_of_scope_change", "vibe_scope_extra_domain", "vibe_scope_dependency_conflict"}
    assert gates["vibe_scope_out_of_scope_change"]["severity"] == "error" and "fleet.aircraft" in gates["vibe_scope_out_of_scope_change"]["details"]["paths"]
    assert gates["vibe_scope_extra_domain"]["details"]["paths"] == ["marketing"]
    assert "crew.member.member_id" in gates["vibe_scope_dependency_conflict"]["details"]["paths"]
    assert "crew.absence" in gates["vibe_scope_dependency_conflict"]["details"]["paths"]
    assert "unrequested_drop_of_referenced" in gates["vibe_scope_dependency_conflict"]["details"]["kinds"]
    fence.record_change("drop", "crew", "absence", "engine:V1")
    issues = ah.run_metamodel_static_analysis(d, p, a, {}, LOG)["issues"]
    gates = {i["category"]: i for i in issues if i["category"].startswith("vibe_scope_")}
    assert set(gates) == {"vibe_scope_out_of_scope_change", "vibe_scope_extra_domain",
                          "vibe_scope_dependency_conflict", "vibe_scope_dangling_boundary_fk"}
    assert "crew.absence" not in gates["vibe_scope_dependency_conflict"]["details"]["paths"]
    assert gates["vibe_scope_dangling_boundary_fk"]["severity"] == "info"
    ah.set_vibe_scope_runtime(None)
    issues = ah.run_metamodel_static_analysis(d, p, a, {}, LOG)["issues"]
    assert not [i for i in issues if i["category"].startswith("vibe_scope_")]


def test_static_analysis_reports_subdomain_violations():
    _fence("crew.crew_records", "Some Subdomains")
    d, p, a, _mv = _flat()
    _row(p, "crew", "absence")["subdomain"] = "not_listed_anywhere"
    _row(p, "crew", "member")["subdomain"] = "flight_scheduling"
    issues = {i["category"]: i for i in ah.run_metamodel_static_analysis(d, p, a, {}, LOG)["issues"]}
    assert "crew.absence" in issues["vibe_scope_out_of_scope_change"]["details"]["paths"]
    assert "crew.member" in issues["vibe_scope_dependency_conflict"]["details"]["paths"]
    assert "vibe_scope_subdomain_violation" not in issues
    new_row = dict(_row(p, "crew", "member"), product="fresh_thing", subdomain="unlisted")
    p.append(new_row)
    a.append(dict(_row(a, "crew", "member", "member_id"), product="fresh_thing", attribute="fresh_thing_id"))
    issues = ah.run_metamodel_static_analysis(d, p, a, {}, LOG)["issues"]
    sub = next(i for i in issues if i["category"] == "vibe_scope_subdomain_violation")
    assert "crew.fresh_thing" in sub["details"]["paths"]


def _division_rows():
    divisions = ["operations", "business", "corporate", "corporate", "operations", "business"]
    domains = [{"domain": f"d{i}", "division": div, "description": f"Domain number {i} description text"} for i, div in enumerate(divisions)]
    products = [{"domain": f"d{i}", "product": f"p{i}", "subdomain": "core", "description": f"Product {i} description text"} for i in range(6)]
    attributes = [{"domain": f"d{i}", "product": f"p{i}", "attribute": f"p{i}_id", "type": "BIGINT", "is_primary_key": True,
                   "description": f"Identifier of product {i}"} for i in range(6)]
    return domains, products, attributes


def _division_issue(issues):
    return next(i for i in issues if i["category"] == "division_imbalance")


def _queued_division_repairs():
    d, p, a = _division_rows()
    wv = {"domains": d, "products": p, "attributes": a}
    ah._v366_sa_findings_requeue(wv, {}, LOG)
    return [r for r in wv.get("_unfulfilled_for_next_vibe") or [] if "division_imbalance" in r["id"]]


def test_division_balance_is_report_only_for_a_small_scoped_new_base_roster():
    ah.set_vibe_scope_runtime(ah.build_vibe_scope_fence(ah.parse_vibe_scope("Some Domains", "d0, d1"), None, "new base model", LOG))
    d, p, a = _division_rows()
    assert _division_issue(ah.run_metamodel_static_analysis(d, p, a, {}, LOG)["issues"])["severity"] == "info"
    assert _queued_division_repairs() == []
    ah.set_vibe_scope_runtime(ah.build_vibe_scope_fence(ah.parse_vibe_scope("Some Domains", "d0, d1, d2, d3"), None, "new base model", LOG))
    d, p, a = _division_rows()
    assert _division_issue(ah.run_metamodel_static_analysis(d, p, a, {}, LOG)["issues"])["severity"] == "warning"
    ah.set_vibe_scope_runtime(None)
    d, p, a = _division_rows()
    assert _division_issue(ah.run_metamodel_static_analysis(d, p, a, {}, LOG)["issues"])["severity"] == "warning"
    assert len(_queued_division_repairs()) == 1


def _broken_fk_lists():
    d, p, a, _mv = _flat()
    fleet_attr = next(r for r in a if r["domain"] == "fleet" and r["product"] == "engine" and r.get("foreign_key_to"))
    crew_attr = next(r for r in a if r["domain"] == "crew" and r["product"] == "roster" and r.get("foreign_key_to"))
    fleet_attr["foreign_key_to"] = "fleet.ghost_table.ghost_id"
    crew_attr["foreign_key_to"] = "crew.ghost_table.ghost_id"
    return {"domains": d, "products": p, "attributes": a}


def test_requeue_drops_findings_that_only_touch_frozen_entities():
    _fence()
    wv = _broken_fk_lists()
    ah._v366_sa_findings_requeue(wv, {}, LOG)
    queued = {r["id"] for r in wv.get("_unfulfilled_for_next_vibe") or []}
    assert "sa-broken_fk-crew.ghost_table" in queued
    assert "sa-broken_fk-fleet.ghost_table" not in queued
    assert not [q for q in queued if "vibe_scope" in q]
    ah.set_vibe_scope_runtime(None)
    wv = _broken_fk_lists()
    ah._v366_sa_findings_requeue(wv, {}, LOG)
    queued = {r["id"] for r in wv.get("_unfulfilled_for_next_vibe") or []}
    assert {"sa-broken_fk-crew.ghost_table", "sa-broken_fk-fleet.ghost_table"} <= queued


def test_issue_verdict_classifies_details_and_messages():
    fence = _fence()
    known = {ah._vov285_san(d["name"]) for d in RAW["model"]["domains"]}
    verdict = ah._vibe_scope_issue_verdict
    assert verdict(fence, {"message": "x", "details": {"source": "fleet.engine", "target": "fleet.ghost"}}, known) == "out"
    assert verdict(fence, {"message": "x", "details": {"source": "crew.member"}}, known) == "in"
    assert verdict(fence, {"message": "e.g., crew.member, fleet.engine", "details": {}}, known) == "mixed"
    assert verdict(fence, {"message": "3 domains lack division", "details": {"domains": ["fleet", "cargo=ops"]}}, known) == "out"
    assert verdict(fence, {"message": "model has 4 cycles", "details": {"count": 4}}, known) == "global"


class _FakeAgent:
    def __init__(self, src):
        self.src = src
        self.prompts = []

    def _call_ai_query(self, prompt_name, prompt, response_schema, step_name, max_retries=None, **kwargs):
        self.prompts.append(prompt)
        return json.dumps({"mutator_src": self.src, "verifier_src": "def verifier(model, data):\n    return (True, '')\n", "rationale": "r"})


def _selffix_inputs():
    model = copy.deepcopy(_ENGINE)
    wv = {"_unfulfilled_for_next_vibe": [
        {"id": "REQ-1", "text": "tag crew.member with its owner", "evidence": "crew.member has no owner tag"},
        {"id": "REQ-2", "text": "fix fleet.engine description", "evidence": "fleet.engine description is short"},
    ]}
    return model, wv


def test_selffixer_drops_out_of_scope_reqs_and_fences_every_fix():
    fence = _fence()
    model, wv = _selffix_inputs()
    agent = _FakeAgent(LEAKY_FIX)
    summary = ah.run_selffixer_or_skip(model, wv, agent, LOG, max_rounds=1, per_req_retries=0)
    assert summary["vibe_scope"]["out_of_scope_dropped"] == 1
    assert summary["vibe_scope"]["post_run_violations"] == 0
    aircraft = next(p for d in model["model"]["domains"] if d["name"] == "fleet" for p in d["products"] if p["name"] == "aircraft")
    original = next(p for d in _ENGINE["model"]["domains"] if d["name"] == "fleet" for p in d["products"] if p["name"] == "aircraft")
    assert aircraft["description"] == original["description"]
    assert fence.check(model).ok
    assert len(agent.prompts) == 1 and "REQ ID: REQ-1" in agent.prompts[0] and "[FROZEN]" in agent.prompts[0]


def test_fenced_executor_passes_clean_results_through():
    _fence()
    clean = LEAKY_FIX.replace("                p['description'] = 'LEAK from SelfFixer'\n", "                pass\n")
    run = ah._vibe_scope_fenced_executor(ah.execute_in_sandbox, LOG)
    result = run(mutator_src=clean, verifier_src="def verifier(model, data):\n    return (True, '')\n", model=copy.deepcopy(_ENGINE), data=None, timeout=60.0)
    assert result.ok and result.new_model is not None
    leak = run(mutator_src=LEAKY_FIX, verifier_src="def verifier(model, data):\n    return (True, '')\n", model=copy.deepcopy(_ENGINE), data=None, timeout=60.0)
    assert not leak.ok and leak.new_model is None and leak.error.startswith("scope_fence_violation:") and "fleet.aircraft" in leak.error


def _edit_product(model, domain, product, key, value):
    for d in model["model"]["domains"]:
        for p in d["products"]:
            if d["name"] == domain and p["name"] == product:
                p[key] = value


def test_fix_gate_rolls_back_an_in_place_leak_and_passes_clean_fixes():
    fence = _fence()

    def leaky_fix(model, req, per_req_retries=2):
        _edit_product(model, "crew", "member", "tags", "owner=crew_control")
        _edit_product(model, "fleet", "aircraft", "description", "LEAK in place")
        return True, True, "v410"

    def clean_fix(model, req, per_req_retries=2):
        _edit_product(model, "crew", "member", "tags", "owner=crew_control")
        return True, True, "applied"

    model = copy.deepcopy(_ENGINE)
    snapshot = json.dumps(model, sort_keys=True)
    ok, applied, evidence = ah._vibe_scope_fence_fix_one(fence, leaky_fix, LOG)(model, {"id": "REQ-1"}, per_req_retries=0)
    assert (ok, applied) == (False, False)
    assert evidence.startswith("scope_fence_violation:") and "fleet.aircraft" in evidence
    assert json.dumps(model, sort_keys=True) == snapshot
    assert ah._vibe_scope_fence_fix_one(fence, clean_fix, LOG)(model, {"id": "REQ-1"}, per_req_retries=0) == (True, True, "applied")
    assert json.dumps(model, sort_keys=True) != snapshot and fence.check(model).ok


def test_selffixer_rolls_back_a_deterministic_v410_leak(monkeypatch):
    fence = _fence()

    def leaky_v410(model, req, logger):
        _edit_product(model, "fleet", "aircraft", "description", "LEAK from v410")
        return True, "v410 leaked"

    monkeypatch.setattr(ah, "_v410_deterministic_selffix", leaky_v410)
    model, wv = _selffix_inputs()
    agent = _FakeAgent(LEAKY_FIX)
    summary = ah.run_selffixer_or_skip(model, wv, agent, LOG, max_rounds=1, per_req_retries=0)
    assert summary["fixed_count"] == 0
    assert summary["vibe_scope"]["post_run_violations"] == 0
    assert fence.check(model).ok
    assert json.dumps(model, sort_keys=True) == json.dumps(_selffix_inputs()[0], sort_keys=True)
    assert agent.prompts == []


def _next_vibes_widgets():
    d, p, a, _mv = _flat()
    member = _row(p, "crew", "member")
    p.append(dict(member, product="pilot_skill", primary_key="pilot_skill_id"))
    a.append(dict(_row(a, "crew", "member", "member_id"), product="pilot_skill", attribute="pilot_skill_id"))
    a.append(dict(_row(a, "fleet", "aircraft", next(r["attribute"] for r in a if r["domain"] == "fleet" and r["product"] == "aircraft")),
                  attribute="pilot_skill_id", foreign_key_to=""))
    return {"domains": d, "products": p, "attributes": a,
            "_vibe_scope_outcomes": {"scope_rejected": [{"vreq_id": "V2", "target": "fleet.engine", "reason": "targets out-of-scope product fleet.engine"}],
                                     "scope_dependency_conflict": [], "scope_fence_violation": [], "authorized_oos_links": [],
                                     "in_scope_vreq_count": 4, "adherence_in_scope_pct": 75.0},
            "_vov_2_raw_vreqs": [{"vreq_id": "V2", "intent": "rename the engine table to powerplant"}]}


def test_next_vibes_orders_in_scope_priorities_first():
    text = ("Intro line\n"
            "**PRIORITY 1 — add_attribute: fleet.aircraft** — add tail colour\n"
            "  detail for fleet\n"
            "**PRIORITY 2 — add_attribute: crew.member** — add nickname\n"
            "**PRIORITY 3 — connect_table: crew.roster** — link roster\n")
    wv = _next_vibes_widgets()
    assert ah._vibe_scope_order_priority_blocks(wv, text) == text
    _fence()
    ordered = ah._vibe_scope_order_priority_blocks(wv, text).split("\n")
    assert ordered[0] == "Intro line"
    assert ordered.index("**PRIORITY 2 — add_attribute: crew.member** — add nickname") < ordered.index("## OUT-OF-SCOPE PRIORITIES (kept for a later run whose vibe_scope covers these domains)")
    assert ordered.index("## OUT-OF-SCOPE PRIORITIES (kept for a later run whose vibe_scope covers these domains)") < ordered.index("**PRIORITY 1 — add_attribute: fleet.aircraft** — add tail colour")
    assert ordered.index("**PRIORITY 1 — add_attribute: fleet.aircraft** — add tail colour") + 1 == ordered.index("  detail for fleet")


def test_next_vibes_summary_out_of_scope_section_and_suggested_links():
    wv = _next_vibes_widgets()
    assert ah._vibe_scope_next_vibes_lines(wv, []) == ([], [])
    missed = [{"interpretation": "add tail colour", "scope_targets": ["fleet.aircraft"], "reason": "vov_residual_unapplied"},
              {"interpretation": "add nickname", "scope_targets": ["crew.member"], "reason": "vov_residual_unapplied"}]
    assert ah._vibe_scope_partition_missed(wv, missed) == (missed, [])
    _fence()
    inside, outside = ah._vibe_scope_partition_missed(wv, missed)
    assert inside == [missed[1]] and outside == [missed[0]]
    summary, body = ah._vibe_scope_next_vibes_lines(wv, outside)
    assert summary[0] == "## VIBE SCOPE SUMMARY" and "- vibe_scope: Some Domains -> crew" in summary
    assert "- in-scope adherence: 75.0% over 4 in-scope VREQ(s)" in summary
    assert body[0].startswith("## OUT-OF-SCOPE VIBES")
    assert "- [V2] rename the engine table to powerplant (target: fleet.engine) [scope_rejected: targets out-of-scope product fleet.engine]" in body
    assert "- add tail colour (target: fleet.aircraft) [outside vibe_scope: vov_residual_unapplied]" in body
    link = next(line for line in body if line.startswith("**PRIORITY 901"))
    assert link.startswith("**PRIORITY 901 - connect_table: fleet.aircraft** - set column pilot_skill_id FK to crew.pilot_skill.pilot_skill_id")
    details = ah._v251_parse_priority_details({"action": "connect_table", "target": "fleet.aircraft", "reason": link.split("** - ", 1)[1]})
    assert details["column"] == "pilot_skill_id" and details["fk_target"] == "crew.pilot_skill.pilot_skill_id"


def test_in_scope_quality_breakdown_filters_out_of_scope_issues():
    wv = _next_vibes_widgets()
    issues = [{"category": "missing_tags", "severity": "warning", "message": "crew.member lacks tags", "details": {}},
              {"category": "missing_tags", "severity": "warning", "message": "fleet.engine lacks tags", "details": {}},
              {"category": "fk_cycle", "severity": "error", "message": "cycle detected", "details": {}}]
    seen = []

    def _native(issue_list, errors, unlinked_ratio, siloed_ratio):
        seen.append((len(issue_list), errors))
        return 90.0

    assert ah._vibe_scope_quality_breakdown(wv, issues, wv["domains"], wv["products"], wv["attributes"], 80.0, _native, LOG) == {}
    _fence()
    got = ah._vibe_scope_quality_breakdown(wv, issues, wv["domains"], wv["products"], wv["attributes"], 80.0, _native, LOG)
    assert seen == [(2, 1)]
    assert got["in_scope_issue_count"] == 2 and got["out_of_scope_issue_count"] == 1
    assert got["in_scope_quality_pct"] == 85.0 and got["in_scope_native_quality_pct"] == 90.0
    assert got["scope_rejected_count"] == 1 and got["in_scope_vreq_count"] == 4


def _native_confidence_from_notebook():
    notebook = json.loads(NOTEBOOK.read_text(encoding="utf-8"))
    for cell in notebook["cells"]:
        source = "".join(cell.get("source") or [])
        if cell.get("cell_type") != "code" or "def step_generate_next_vibes(" not in source:
            continue
        tree = ast.parse(source)
        step = next(n for n in tree.body if isinstance(n, ast.FunctionDef) and n.name == "step_generate_next_vibes")
        scorer = next(n for n in ast.walk(step) if isinstance(n, ast.FunctionDef) and n.name == "_compute_deterministic_confidence_and_status")
        body = [n for n in scorer.body if isinstance(n, ast.Assign) and getattr(n.targets[0], "id", "") in ("_HIGH_WEIGHT_CATS", "_MEDIUM_WEIGHT_CATS")]
        body += [n for n in scorer.body if isinstance(n, ast.FunctionDef) and n.name == "_native_confidence"]
        namespace = {}
        exec(compile(ast.Module(body=body, type_ignores=[]), "native", "exec"), namespace)
        return namespace["_native_confidence"]
    raise AssertionError("step_generate_next_vibes not found")


def _reference_5_1_3(all_issues, error_count, unlinked_ratio, siloed_ratio):
    high = {'self_fk_on_pk', 'silo_product', 'broken_fk', 'fk_cycle', 'siloed_table'}
    medium = {'unlinked_fk', 'duplicate_product_pair', 'duplicate_attributes', 'fk_namespace_mismatch', 'fk_pk_type_mismatch'}
    groups = {}
    for iss in all_issues:
        if iss.get('severity') not in ('error', 'warning') or iss.get('category', '') in ('unlinked_fk', 'siloed_table'):
            continue
        cat, det = iss.get('category', ''), iss.get('details', {})
        if cat in ('pk_mismatch', 'broken_fk'):
            key = f"{cat}:{str(det.get('target_product', det.get('product', '')))}"
        elif cat == 'self_fk_on_pk':
            key = 'self_fk_on_pk:all'
        else:
            key = f"{cat}:{iss.get('message', '')[:50]}"
        groups.setdefault(key, iss)
    weighted = sum(3.0 if i.get('category') in high else 2.0 if i.get('category') in medium else 1.0 for i in groups.values())
    conf = int(95.0 - (min(weighted, 150.0) / 150.0) * 45.0)
    if error_count > 0:
        conf -= min(error_count * 8, 40)
    conf -= min(int(unlinked_ratio * 50), 15)
    conf -= min(int(siloed_ratio * 30), 10)
    return max(50, min(99.99, conf))


def test_native_confidence_refactor_matches_5_1_3():
    native = _native_confidence_from_notebook()
    issues = ([{"category": "broken_fk", "severity": "error", "message": f"m{i}", "details": {"target_product": f"t{i % 3}"}} for i in range(9)]
              + [{"category": "fk_cycle", "severity": "warning", "message": "cycle a"}, {"category": "unlinked_fk", "severity": "warning", "message": "u"}]
              + [{"category": "missing_tags", "severity": "warning", "message": f"tag gap {i}"} for i in range(60)]
              + [{"category": "low_quality_description", "severity": "info", "message": "x"}])
    for args in ((issues, 9, 0.2, 0.05), (issues[:10], 0, 0.0, 0.0), ([], 0, 0.9, 0.9), (issues * 3, 2, 0.01, 0.4)):
        assert native(*args) == _reference_5_1_3(*args)
