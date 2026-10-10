"""v5.1.4 vibe_scope fence on the four VOV mutation paths, plus triage, target narrowing and merges.

Runs production code on the real data-models/airlines/v1/mvm/model.json (15 domains, 205 products)
with vibe_scope = Some Domains: crew. Canned MockLLM mutators leak into frozen products; every
path must reject the leak (scope_fence_violation / scope_rejected / scope_dependency_conflict) and
keep the out-of-scope records byte-identical. Every behavioral test fails on pre-patch 5d386ed.
"""
import copy
import json
import logging
import sys
from pathlib import Path
from types import SimpleNamespace

import pytest

sys.path.insert(0, str(Path(__file__).resolve().parent))
import conftest  # noqa: F401,E402
import agent_helpers as ah  # noqa: E402

REPO = Path(__file__).resolve().parents[3]
RAW = json.loads((REPO / "data-models" / "airlines" / "v1" / "mvm" / "model.json").read_text())
VOV = "vibe modeling of version"
LOG = logging.getLogger("test_v514_vov_engine")
_ENGINE = ah.widgets_flat_to_model(*ah.model_to_widgets_flat(RAW), agent_version=ah.__AGENT_VERSION__)

DESCRIBE_MUTATOR = (
    "def mutator(model, data):\n"
    "    root = model.get('model', model)\n"
    "    want = [str(row.get('target', '')).split('.') for row in data]\n"
    "    for d in root['domains']:\n"
    "        for p in (d.get('products') or d.get('data_products') or []):\n"
    "            for bits in want:\n"
    "                if len(bits) >= 2 and d['name'] == bits[0] and p['name'] == bits[1]:\n"
    "                    p['tags'] = 'owner=crew_control,curated_for=' + bits[1]\n"
    "    return model\n"
)
LEAKY_MUTATOR = DESCRIBE_MUTATOR.replace(
    "    return model\n",
    "    for d in root['domains']:\n"
    "        for p in (d.get('products') or d.get('data_products') or []):\n"
    "            if d['name'] == 'fleet' and p['name'] == 'aircraft':\n"
    "                p['description'] = 'LEAK: out-of-scope edit'\n"
    "    return model\n",
)


class _CannedLLM(ah.MockLLM):
    """MockLLM that accepts response_schema and records prompts; batches one VREQ per batch."""

    def __init__(self, mutator=DESCRIBE_MUTATOR, summary="update product description"):
        super().__init__(default={"mutator_source": mutator, "expected_changes_summary": summary})
        self.prompts = []

    def complete_json(self, system, user, temperature=0.0, response_schema=None):
        self.prompts.append((system, user))
        if "group VREQs into BATCHES" in system:
            vreqs = json.loads(user)["vreqs"]
            return {"batches": [{
                "vreq_ids": [v["vreq_id"]],
                "intent_summary": v["intent"],
                "target_entities": [str(v["target"]).split(".")[:2]],
                "data_payload": [{"intent": v["intent"], "target": v["target"], "source_quote": v["source_quote"]}],
            } for v in vreqs]}
        return super().complete_json(system, user, temperature)

    def complete_with_tools(self, system, user, tools, tool_handlers, max_iters=6, temperature=0.0, response_schema=None):
        return self.complete_json(system, user, temperature)


@pytest.fixture(autouse=True)
def _reset_runtime(monkeypatch):
    monkeypatch.setattr(ah, "logger", LOG, raising=False)
    ah.set_vibe_scope_runtime(None)
    yield
    ah.set_vibe_scope_runtime(None)


def _engine():
    return copy.deepcopy(_ENGINE)


def _fence(entries="crew", mode="Some Domains"):
    fence = ah.build_vibe_scope_fence(ah.parse_vibe_scope(mode, entries), RAW, VOV, LOG)
    ah.set_vibe_scope_runtime(fence)
    fence.bind_engine_baseline(_ENGINE, LOG)
    return fence


def _domain(model, name):
    return next(d for d in model.get("model", model)["domains"] if d["name"] == name)


def _products(model, domain):
    dom = _domain(model, domain)
    return dom.get("products") if dom.get("products") is not None else dom.get("data_products")


def _product(model, domain, name):
    return next(p for p in _products(model, domain) if p["name"] == name)


def _has_product(model, domain, name):
    return any(p["name"] == name for p in _products(model, domain))


def _attr(model, domain, product, name):
    return next(a for a in _product(model, domain, product)["attributes"] if a["name"] == name)


def _all_fks(model):
    return [a.get("foreign_key_to") or "" for d in model.get("model", model)["domains"]
            for p in (d.get("products") or d.get("data_products") or []) for a in p.get("attributes") or []]


def _statuses(result):
    out = {}
    for outcome in result.outcomes:
        for vid in outcome.vreq_ids:
            out.setdefault(vid, []).append(outcome.status)
    return out


def _handler(src):
    return ah.Handler(batch_id="B1", mutator_src=src, verifier_src="", expected_changes_summary="update crew.member description",
                      target_entities=(("crew", "member"),))


def _describe_batch():
    intent = "Describe crew.member for crew control"
    return ah.Batch(batch_id="B1", vreq_ids=("V1",), intent_summary=intent, target_entities=(("crew", "member"),),
                    data_payload=({"intent": intent, "target": "crew.member", "source_quote": "describe the crew member table"},))


def _priority_batch(quote, target):
    return ah.Batch(batch_id="B9", vreq_ids=("P001",), intent_summary=quote, target_entities=(tuple(target.split(".")[:2]),),
                    data_payload=({"intent": quote, "target": target, "source_quote": quote},))


def test_llm_sandbox_leak_is_rejected_after_retries_with_exact_paths_in_the_trace():
    fence = _fence()
    model = _engine()
    llm = _CannedLLM(mutator=LEAKY_MUTATOR)
    invariants = ah.capture_invariants(model, [], [], scope_fence=fence)
    new_model, outcome = ah._apply_handler_with_retry(_handler(LEAKY_MUTATOR), _describe_batch(), model, invariants, llm, 3, (), (), 600.0)
    assert new_model is None
    assert outcome.status == "scope_fence_violation" and outcome.attempts == 3
    assert "frozen_product_changed fleet.aircraft" in outcome.diagnostic
    retries = [user for system, user in llm.prompts if "careful Python code generator" in system]
    assert len(retries) == 2
    assert all("PRIOR ATTEMPT FAILED" in user and "frozen_product_changed fleet.aircraft" in user for user in retries)
    assert _product(model, "fleet", "aircraft")["description"] == _product(_ENGINE, "fleet", "aircraft")["description"]


def test_llm_sandbox_clean_retry_lands_only_the_in_scope_change():
    fence = _fence()
    model = _engine()
    llm = _CannedLLM(mutator=DESCRIBE_MUTATOR)
    invariants = ah.capture_invariants(model, [], [], scope_fence=fence)
    new_model, outcome = ah._apply_handler_with_retry(_handler(LEAKY_MUTATOR), _describe_batch(), model, invariants, llm, 3, (), (), 600.0)
    assert outcome.status == "applied" and outcome.attempts == 2
    assert _product(new_model, "crew", "member")["tags"] == "owner=crew_control,curated_for=member"
    assert fence.check(new_model).ok


def test_invariants_without_a_fence_ignore_scope():
    model = _engine()
    invariants = ah.capture_invariants(model, [], [])
    assert invariants.scope_fence is None and invariants.scope_preexisting == frozenset()
    leaked = _engine()
    _product(leaked, "fleet", "aircraft")["description"] = "edit"
    assert ah.verify_invariants(leaked, invariants) == (True, "")
    assert ah.verify_scope_invariants(leaked, invariants) == (True, "", "")


def test_preexisting_problems_are_not_blamed_on_the_mutator():
    fence = _fence()
    model = _engine()
    _product(model, "fleet", "engine")["description"] = "pre-existing drift"
    invariants = ah.capture_invariants(model, [], [], scope_fence=fence)
    assert len(invariants.scope_preexisting) == 1
    candidate = copy.deepcopy(model)
    _product(candidate, "crew", "member")["description"] = "in-scope edit"
    assert ah.verify_invariants(candidate, invariants) == (True, "")
    _product(candidate, "fleet", "aircraft")["description"] = "new leak"
    ok, diag = ah.verify_invariants(candidate, invariants)
    assert not ok and diag.startswith("scope_fence_violation:") and "fleet.aircraft" in diag and "fleet.engine" not in diag


def test_deterministic_rename_of_a_frozen_product_is_scope_rejected():
    fence = _fence()
    model = _engine()
    invariants = ah.capture_invariants(model, [], [], scope_fence=fence)
    batch = _priority_batch("**PRIORITY 1 — rename_product: fleet.aircraft** — rename to airframe", "fleet.aircraft")
    new_model, outcome = ah._apply_handler_with_retry(_handler(DESCRIBE_MUTATOR), batch, model, invariants, _CannedLLM(), 3, (), (), 60.0)
    assert new_model is None and outcome.status == "scope_rejected" and outcome.attempts == 0
    assert "fleet.aircraft" in outcome.diagnostic and outcome.diagnostic.startswith("deterministic: rename fleet.aircraft->airframe")
    assert _has_product(model, "fleet", "aircraft")


def test_deterministic_cross_fence_move_is_rejected_and_in_scope_rename_is_applied():
    fence = _fence()
    model = _engine()
    invariants = ah.capture_invariants(model, [], [], scope_fence=fence)
    move = _priority_batch("**PRIORITY 1 — move_product: crew.absence** — move to fleet domain", "crew.absence")
    new_model, outcome = ah._apply_handler_with_retry(_handler(DESCRIBE_MUTATOR), move, model, invariants, _CannedLLM(), 3, (), (), 60.0)
    assert new_model is None and outcome.status == "scope_rejected"
    assert "cross_fence_move" not in outcome.diagnostic and "fleet.absence" in outcome.diagnostic
    rename = _priority_batch("**PRIORITY 2 — rename_product: crew.member** — rename to crew_member", "crew.member")
    new_model, outcome = ah._apply_handler_with_retry(_handler(DESCRIBE_MUTATOR), rename, model, invariants, _CannedLLM(), 3, (), (), 60.0)
    assert outcome.status == "applied"
    result = fence.check(new_model)
    assert result.ok and result.summary()["by_kind"] == {"P1": 19}


def test_v413_preapply_cross_fence_move_is_blocked_and_leaves_the_model_untouched():
    fence = _fence()
    model = _engine()
    vibe = "**PRIORITY 1 — move_product: crew.absence** — move to fleet domain\n"
    result = ah.run_vov_pipeline(vibe, model, _CannedLLM(), [], [], parallel=False, priority_reapply_loops=2)
    assert "scope_rejected" in _statuses(result)["P001"] and "applied" not in _statuses(result)["P001"]
    assert _has_product(result.final_model, "crew", "absence") and not _has_product(result.final_model, "fleet", "absence")
    assert fence.check(result.final_model).ok


def test_out_of_scope_priority_is_triaged_and_in_scope_priority_lands():
    fence = _fence()
    vibe = ("**PRIORITY 1 — rename_product: fleet.aircraft** — rename to airframe\n"
            "**PRIORITY 2 — rename_product: crew.absence** — rename to crew_absence\n")
    result = ah.run_vov_pipeline(vibe, _engine(), _CannedLLM(), [], [], parallel=False, priority_reapply_loops=2)
    statuses = _statuses(result)
    assert statuses["P001"] == ["scope_rejected"]
    assert "applied" in statuses["P002"] and not set(statuses["P002"]) & {"scope_rejected", "scope_fence_violation", "scope_dependency_conflict"}
    assert _has_product(result.final_model, "fleet", "aircraft") and not _has_product(result.final_model, "fleet", "airframe")
    assert _has_product(result.final_model, "crew", "crew_absence")
    assert result.coverage_pct == 100.0
    assert [d["vreq_id"] for d in result.deferred_vreqs] == []
    assert fence.check(result.final_model).ok
    contract = ah._vibe_scope_collect_outcomes(fence, result)
    assert contract["in_scope_vreq_count"] == 1 and contract["adherence_in_scope_pct"] == 100.0
    assert [entry["vreq_id"] for entry in contract["scope_rejected"]] == ["P001"]


def test_all_out_of_scope_vibe_reports_zero_in_scope_adherence_like_the_pipeline_coverage():
    fence = _fence()
    vibe = "**PRIORITY 1 — rename_product: fleet.aircraft** — rename to airframe\n"
    result = ah.run_vov_pipeline(vibe, _engine(), _CannedLLM(), [], [], parallel=False, priority_reapply_loops=2)
    contract = ah._vibe_scope_collect_outcomes(fence, result)
    assert result.coverage_pct == 0.0
    assert contract["in_scope_vreq_count"] == 0 and contract["adherence_in_scope_pct"] == 0.0
    assert [entry["vreq_id"] for entry in contract["scope_rejected"]] == ["P001"]
    assert _has_product(result.final_model, "fleet", "aircraft")


def test_pass1_pk_retype_that_breaks_frozen_fks_is_blocked_as_dependency_conflict():
    fence = _fence()
    vibe = "**PRIORITY 1 — retype_attribute: crew.member.member_id** — retype to STRING\n"
    result = ah.run_vov_pipeline(vibe, _engine(), _CannedLLM(), [], [], parallel=False, priority_reapply_loops=2)
    assert "scope_dependency_conflict" in _statuses(result)["P001"] and "applied" not in _statuses(result)["P001"]
    assert _attr(result.final_model, "crew", "member", "member_id")["type"] == "BIGINT"
    assert fence.check(result.final_model).ok


def test_pass1_gate_keeps_clean_priorities_when_one_is_blocked():
    fence = _fence()
    model = _engine()
    priorities = [
        {"vreq_id": "P001", "action": "retype_attribute", "target": "crew.member.member_id", "reason": "retype to STRING"},
        {"vreq_id": "P002", "action": "rename_product", "target": "crew.absence", "reason": "rename to crew_absence"},
    ]
    new_model, outcomes, residual = ah._vibe_scope_apply_pass1(priorities, model, LOG)
    by_id = {o.vreq_ids[0]: o.status for o in outcomes}
    assert by_id == {"P001": "scope_dependency_conflict", "P002": "applied"}
    assert residual == []
    assert _has_product(new_model, "crew", "crew_absence") and _attr(new_model, "crew", "member", "member_id")["type"] == "BIGINT"
    assert _attr(model, "crew", "member", "member_id")["type"] == "BIGINT" and _has_product(model, "crew", "absence")
    assert fence.check(new_model).ok


def test_p4_link_on_an_out_of_scope_product_is_authorized_end_to_end():
    fence = _fence()
    base_pk = _product(_ENGINE, "crew", "base")["primary_key"]
    vibe = f"**PRIORITY 1 — connect_table: fleet.aircraft** — add column home_base_id FK to crew.base.{base_pk}\n"
    result = ah.run_vov_pipeline(vibe, _engine(), _CannedLLM(), [], [], parallel=False, priority_reapply_loops=2)
    assert "applied" in _statuses(result)["P001"]
    assert _attr(result.final_model, "fleet", "aircraft", "home_base_id")["foreign_key_to"] == f"crew.base.{base_pk}"
    check = fence.check(result.final_model)
    assert check.ok and [p["kind"] for p in check.permitted] == ["P4"]
    assert fence.report()["authorizations"] == [{"oos": "fleet.aircraft", "target": f"crew.base.{base_pk}", "column": "home_base_id", "vreq_id": "P001"}]


def test_apply_det_op_is_in_place_without_a_fence_and_gated_on_a_copy_with_one():
    model = _engine()
    out, result, verdict = ah._vibe_scope_apply_det_op(model, ("rename_product", "fleet", "engine", "powerplant"), "t")
    assert out is model and result and verdict == ("", "") and _has_product(model, "fleet", "powerplant")
    _fence()
    model = _engine()
    out, result, verdict = ah._vibe_scope_apply_det_op(model, ("rename_product", "fleet", "engine", "powerplant"), "t")
    assert out is model and result is None and verdict[0] == "scope_rejected"
    assert _has_product(model, "fleet", "engine") and not _has_product(model, "fleet", "powerplant")


def test_parallel_merge_gate_rejects_a_leaking_merge(monkeypatch):
    fence = _fence()
    real_merge = ah._merge_partial

    def _leaky_merge(base, candidate, targets, renames=()):
        merged = real_merge(base, candidate, targets, renames)
        _product(merged, "fleet", "aircraft")["description"] = "LEAK via merge"
        return merged

    monkeypatch.setattr(ah, "_merge_partial", _leaky_merge)
    vibe = ("**PRIORITY 1 — enrich_description: crew.member** — add a crew control description\n"
            "**PRIORITY 2 — enrich_description: crew.base** — add a crew base description\n")
    result = ah.run_vov_pipeline(vibe, _engine(), _CannedLLM(), [], [], parallel=True, priority_reapply_loops=1)
    statuses = _statuses(result)
    assert "scope_fence_violation" in statuses["P001"] and "scope_fence_violation" in statuses["P002"]
    assert "applied" not in statuses["P001"] + statuses["P002"]
    assert _product(result.final_model, "fleet", "aircraft")["description"] == _product(_ENGINE, "fleet", "aircraft")["description"]
    assert fence.check(result.final_model).ok


def test_parallel_merge_applies_clean_in_scope_handlers():
    _fence()
    vibe = ("**PRIORITY 1 — enrich_description: crew.member** — add a crew control description\n"
            "**PRIORITY 2 — enrich_description: crew.base** — add a crew base description\n")
    result = ah.run_vov_pipeline(vibe, _engine(), _CannedLLM(), [], [], parallel=True, priority_reapply_loops=1)
    statuses = _statuses(result)
    assert "applied" in statuses["P001"] and "applied" in statuses["P002"]
    assert _product(result.final_model, "crew", "base")["tags"] == "owner=crew_control,curated_for=base"
    assert _product(result.final_model, "crew", "member")["tags"] == "owner=crew_control,curated_for=member"


def test_merge_partial_carries_inbound_fk_rewires_without_a_fence():
    base = _engine()
    inbound = sum(1 for fk in _all_fks(base) if fk.startswith("crew.member."))
    assert inbound >= 19
    candidate = copy.deepcopy(base)
    assert ah._v337_apply_rename_product(candidate["model"], "crew", "member", "crew_member")
    merged = ah._merge_partial(base, candidate, (("crew", "member"),))
    fks = _all_fks(merged)
    assert not [fk for fk in fks if fk.startswith("crew.member.")]
    assert sum(1 for fk in fks if fk == "crew.crew_member.crew_member_id") == inbound
    assert _has_product(merged, "crew", "crew_member") and not _has_product(merged, "crew", "member")


def test_merge_partial_leaves_fks_into_other_entities_alone():
    base = _engine()
    candidate = copy.deepcopy(base)
    flight_plan = _product(candidate, "flight", "plan")
    victim = next(a for a in flight_plan["attributes"] if (a.get("foreign_key_to") or "") and not a["foreign_key_to"].startswith("crew.member."))
    victim["foreign_key_to"] = ""
    merged = ah._merge_partial(base, candidate, (("crew", "member"),))
    original = next(a for a in _product(base, "flight", "plan")["attributes"] if a["name"] == victim["name"])
    assert next(a for a in _product(merged, "flight", "plan")["attributes"] if a["name"] == victim["name"])["foreign_key_to"] == original["foreign_key_to"]


def test_merge_partial_keeps_candidate_metric_views_keyed_by_view_name():
    base = _engine()
    existing = base["model"]["metric_views"][0]
    assert "name" not in existing and existing["view_name"]
    candidate = copy.deepcopy(base)
    candidate["model"]["metric_views"].append(dict(existing, view_name="mv_crew_member_headcount", owner_domain="crew", owner_product="member"))
    candidate["model"]["metric_views"].append(dict(existing, view_name=existing["view_name"].upper(), sql="SELECT 1"))
    merged = ah._merge_partial(base, candidate, (("crew", "member"),))
    names = [mv["view_name"] for mv in merged["model"]["metric_views"]]
    assert names.count("mv_crew_member_headcount") == 1
    assert [n for n in names if n.lower() == existing["view_name"].lower()] == [existing["view_name"]]
    assert len(names) == len(base["model"]["metric_views"]) + 1


def test_batching_index_and_batches_are_narrowed_to_the_scope():
    fence = _fence()
    model = _engine()
    pairs, doms = ah._vov285_build_model_index(model)
    assert doms == ["crew"] and {d for d, _p in pairs} == {"crew"} and len(pairs) == 13
    all_pairs, all_doms = ah._vov285_build_model_index(model, in_scope_only=False)
    assert len(all_doms) == 15 and len(all_pairs) == 205
    batches = [
        ah.Batch("B1", ("V1",), "global", (("*", "*"),), ()),
        ah.Batch("B2", ("V2",), "mixed", (("fleet", "aircraft"), ("crew", "member")), ()),
        ah.Batch("B3", ("V3",), "frozen only", (("fleet", "*"),), ()),
        ah.Batch("B4", ("V4",), "blind", (), ()),
    ]
    out = ah._vibe_scope_narrow_batches(fence, batches, model, LOG)
    assert [b.target_entities for b in out] == [(("crew", "*"),), (("crew", "member"),), (("crew", "*"),), (("crew", "*"),)]


def test_index_keeps_authorized_p4_products():
    fence = _fence()
    assert fence.authorize_oos_link("fleet", "aircraft", "crew.base", None, "P9")
    pairs, _doms = ah._vov285_build_model_index(_engine())
    assert ("fleet", "aircraft") in pairs and ("fleet", "engine") not in pairs


def test_index_is_unchanged_without_a_fence():
    pairs, doms = ah._vov285_build_model_index(_engine())
    assert len(doms) == 15 and len(pairs) == 205


def test_priority_triage_in_out_and_p4():
    fence = _fence()
    base_pk = _product(_ENGINE, "crew", "base")["primary_key"]
    priorities = [
        {"vreq_id": "P001", "action": "connect_table", "target": "fleet.aircraft", "reason": f"add column home_base_id FK to crew.base.{base_pk}"},
        {"vreq_id": "P002", "action": "rename_product", "target": "fleet.engine", "reason": "rename to powerplant"},
        {"vreq_id": "P003", "action": "add_attribute", "target": "crew.member", "reason": "add column nickname"},
        {"vreq_id": "P004", "action": "connect_table", "target": "fleet.seat_map", "reason": "add column cabin_id FK to fleet.cabin_configuration.cabin_configuration_id"},
    ]
    kept, rejected = ah._vibe_scope_triage_priorities(fence, priorities, _engine(), LOG)
    assert [p["vreq_id"] for p in kept] == ["P001", "P003"]
    assert [(o.vreq_ids[0], o.status) for o in rejected] == [("P002", "scope_rejected"), ("P004", "scope_rejected")]
    assert "refused" in rejected[1].diagnostic
    assert [a["vreq_id"] for a in fence.report()["authorizations"]] == ["P001"]


def test_vreq_triage_splits_mixed_and_rejects_out_of_scope():
    fence = _fence()
    vreqs = [
        ah.RawVREQ("V1", "add audit columns", "crew.member, fleet.aircraft", "add audit columns to crew.member and fleet.aircraft", "c1"),
        ah.RawVREQ("V2", "rename the engine table", "fleet.engine", "rename fleet.engine", "c1"),
        ah.RawVREQ("V3", "tag every table", "*", "tag every table with owner", "c1"),
        ah.RawVREQ("V4", "add a pilot skill table", "crew.pilot_skill", "add crew.pilot_skill", "c1"),
    ]
    kept, rejected, outcomes = ah._vibe_scope_triage_vreqs(fence, vreqs, _engine(), LOG)
    assert [(v.vreq_id, v.target) for v in kept] == [("V1", "crew.member"), ("V3", "*"), ("V4", "crew.pilot_skill")]
    assert "[vibe_scope: apply only to crew.member]" in kept[0].intent
    assert [(v.vreq_id, v.target) for v in rejected] == [("V1#oos", "fleet.aircraft"), ("V2", "fleet.engine")]
    assert [(o.vreq_ids[0], o.status) for o in outcomes] == [("V1#oos", "scope_rejected"), ("V2", "scope_rejected")]
    assert ah._vibe_scope_split_diag(outcomes[0].diagnostic)[0] == "fleet.aircraft"


def test_collect_outcomes_reports_the_cross_stream_contract():
    fence = _fence()
    vreqs = [ah.RawVREQ(v, "x", t, "q", "c") for v, t in (("V1", "crew.member"), ("V2", "fleet.engine"), ("V3", "crew.base"), ("V4", "crew.roster"))]
    outcomes = [
        ah.VReqOutcome("b1", ("V1",), "applied", "", 1),
        ah._vibe_scope_triage_outcome("V2", "scope_rejected", "fleet.engine", "targets out-of-scope product fleet.engine"),
        ah.VReqOutcome("b3", ("V3",), "scope_dependency_conflict", "1 blocked change(s)", 1),
        ah.VReqOutcome("b4", ("V4",), "scope_fence_violation", "1 change(s) outside vibe_scope", 3),
    ]
    result = ah.PipelineResult(initial_model={}, final_model={}, outline=None, raw_vreqs=vreqs, batches=[], outcomes=outcomes, coverage_pct=33.333)
    got = ah._vibe_scope_collect_outcomes(fence, result)
    assert set(got) == {"scope_rejected", "scope_dependency_conflict", "scope_fence_violation", "authorized_oos_links", "in_scope_vreq_count", "adherence_in_scope_pct"}
    assert got["scope_rejected"] == [{"vreq_id": "V2", "target": "fleet.engine", "reason": "targets out-of-scope product fleet.engine"}]
    assert got["scope_dependency_conflict"] == [{"vreq_id": "V3", "target": "crew.base", "reason": "1 blocked change(s)"}]
    assert got["scope_fence_violation"][0]["vreq_id"] == "V4"
    assert got["in_scope_vreq_count"] == 3 and got["adherence_in_scope_pct"] == 33.33
    assert got["authorized_oos_links"] == []


def _contract(forbidden=()):
    return SimpleNamespace(forbidden_ops=set(forbidden), mode="HOLISTIC", scope="model", mutation_budget={}, explicit_requests={})


def test_legacy_action_gate_runs_first_and_user_authority_cannot_bypass_it():
    _fence()
    wv = {"operation": VOV}
    evaluate = ah.evaluate_action_against_contract
    assert evaluate({"action": "add_attribute", "scope": "attribute", "name": "fleet.aircraft.paint_code"}, _contract(), wv) == (False, "vibe_scope_out_of_scope:fleet.aircraft")
    assert evaluate({"action": "add_attribute", "scope": "attribute", "name": "crew.member.nickname"}, _contract(), wv) == (True, "allowed")
    assert evaluate({"action": "remove_product", "scope": "product", "name": "fleet.engine"}, _contract({"remove_product"}), wv) == (False, "vibe_scope_out_of_scope:fleet.engine")
    assert evaluate({"action": "standardize_naming", "scope": "model", "name": "*"}, _contract(), wv) == (False, "vibe_scope_global_rewrite_blocked:standardize_naming")
    assert evaluate({"action": "remove_domain", "scope": "domain", "name": "finance"}, _contract(), wv) == (False, "vibe_scope_out_of_scope:finance")


def test_legacy_action_gate_is_a_noop_without_a_fence():
    wv = {"operation": VOV}
    evaluate = ah.evaluate_action_against_contract
    assert evaluate({"action": "add_attribute", "scope": "attribute", "name": "fleet.aircraft.paint_code"}, _contract(), wv) == (True, "allowed")
    assert evaluate({"action": "remove_product", "scope": "product", "name": "fleet.engine"}, _contract({"remove_product"}), wv) == (True, "vov_user_authority_override:forbidden_op:remove_product")


def test_filter_actions_reports_scope_rejections(caplog):
    _fence()
    actions = [{"action": "add_attribute", "scope": "attribute", "name": "fleet.aircraft.paint_code"},
               {"action": "add_attribute", "scope": "attribute", "name": "crew.member.nickname"}]
    with caplog.at_level(logging.INFO):
        allowed, rejected = ah.filter_actions_by_contract(actions, _contract(), logging.getLogger("t514"), {"operation": VOV})[:2]
    assert [a["name"] for a in allowed] == ["crew.member.nickname"]
    assert rejected[0]["_contract_reject_reason"] == "vibe_scope_out_of_scope:fleet.aircraft"
    assert "[vibe-scope-action-gate FIRED v5.1.4]" in caplog.text
