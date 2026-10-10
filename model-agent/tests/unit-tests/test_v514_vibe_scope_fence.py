"""v5.1.4 vibe_scope fence on the real data-models/airlines/v1/mvm/model.json.

That model was written by agent 0.7.1 (15 domains, 205 products, 140 metric views),
so these tests also prove the fence baseline is stable across agent versions.
Behavioral tests drive production code: the hooked _v337 appliers, check / restore /
reconcile / splice, and _preserve_baseline_metric_views_for_surgical. They fail on
pre-patch 5.1.3 (no fence, no hooks, no shared rewrite helper) and pass on 5.1.4.
"""
import copy
import json
import logging
import re
import sys
import types
from pathlib import Path

import pytest

sys.path.insert(0, str(Path(__file__).resolve().parent))
import conftest  # noqa: F401,E402
import agent_helpers as ah  # noqa: E402
from notebook_source_util import slice_function_source  # noqa: E402

REPO = Path(__file__).resolve().parents[3]
RAW = json.loads((REPO / "data-models" / "airlines" / "v1" / "mvm" / "model.json").read_text())
VOV = "vibe modeling of version"
LOG = logging.getLogger("test_v514_fence")


@pytest.fixture(autouse=True)
def _reset_runtime():
    ah.set_vibe_scope_runtime(None)
    yield
    ah.set_vibe_scope_runtime(None)


def _fence(entries="crew", mode="Some Domains", base=RAW, operation=VOV, install=True):
    fence = ah.build_vibe_scope_fence(ah.parse_vibe_scope(mode, entries), base, operation, LOG)
    if install:
        ah.set_vibe_scope_runtime(fence)
    return fence


def _model():
    return copy.deepcopy(RAW)


def _domain(root, name):
    return next(d for d in root["model"]["domains"] if d["name"] == name)


def _product(root, domain, product):
    return next(p for p in _domain(root, domain)["products"] if p["name"] == product)


def _kinds(result):
    return result.summary()["by_kind"]


def _flat(root):
    return [list(x) for x in ah.model_to_widgets_flat(root)]


def _with_frozen_mv_joining_crew_qualification(join_column):
    base = _model()
    mv = next(m for m in base["model"]["metric_views"] if m["view_name"] == "airport_baggage_irregularity")
    mv["sql"] = mv["sql"].replace(
        "  dimensions:",
        "  joins:\n    - name: qualification\n      source: \"`airlines_ecm`.`crew`.`qualification`\"\n"
        f"      'on': source.report_station_id = qualification.{join_column}\n"
        f"  dimensions:\n    - name: \"q\"\n      expr: qualification.{join_column}",
        1,
    )
    return base


def test_baseline_counts_on_airlines():
    rep = _fence().report()
    assert rep["baseline"] == {"domains": 15, "products": 205, "metric_views": 140}
    assert rep["frozen"] == {"domains": 14, "products": 192, "metric_views": 131, "boundary_fks": 24}
    assert rep["resolved"] == {"in_base": ["crew"], "new_containers": [], "closest": {}}


def test_unchanged_model_has_zero_deltas_in_every_input_shape():
    fence = _fence()
    d, p, a, mv = _flat(RAW)
    for result in (fence.check(RAW), fence.check(RAW["model"]), fence.check_flat(d, p, a, mv),
                   fence.check(ah.widgets_flat_to_model(d, p, a, mv))):
        assert result.ok and result.summary() == {"permitted": 0, "violations": 0, "conflicts": 0, "dangling": 0, "by_kind": {}}


def test_bind_matches_the_flattened_engine_start_model():
    fence = _fence()
    initial = ah.widgets_flat_to_model(*ah.model_to_widgets_flat(RAW), agent_version=ah.__AGENT_VERSION__)
    bind = fence.bind_engine_baseline(initial, LOG)
    assert bind == {"total": 360, "matched": 360, "differing": 0, "examples": [], "rebound_to_engine": False}


def test_bind_reports_drift_and_rebinds_to_the_engine_model():
    fence = _fence()
    engine = _model()
    _product(engine, "flight", "scheduled_flight")["description"] = "drifted in the metamodel"
    bind = fence.bind_engine_baseline(engine, LOG)
    assert bind["differing"] == 1 and bind["rebound_to_engine"] is True
    assert bind["examples"] == ["product:flight.scheduled_flight"]
    assert fence.check(engine).ok
    assert not fence.check(RAW).ok


def test_rename_hook_feeds_the_ledger_and_relinks_are_p1():
    fence = _fence()
    m = _model()
    assert ah._v337_apply_rename_product(m["model"], "crew", "member", "crew_member") == "rename crew.member->crew_member"
    ledger = fence.report()["rename_ledger"]
    assert ledger == [{"kind": "product", "old": "crew.member", "new": "crew.crew_member"},
                      {"kind": "attribute", "old": "crew.crew_member.member_id", "new": "crew.crew_member.crew_member_id"}]
    result = fence.check(m)
    assert result.ok and _kinds(result) == {"P1": 19}
    assert all(item["new"] == "crew.crew_member.crew_member_id" for item in result.permitted)


def test_attribute_rename_hook_relinks_frozen_fks():
    fence = _fence()
    m = _model()
    ah._v337_apply_rename_attribute(m["model"], "crew", "member", "member_id", "member_key")
    assert fence.report()["rename_ledger"] == [{"kind": "attribute", "old": "crew.member.member_id", "new": "crew.member.member_key"}]
    result = fence.check(m)
    assert result.ok and _kinds(result) == {"P1": 19}


def test_move_hook_inside_the_scope_is_p1():
    fence = _fence("crew, safety")
    m = _model()
    assert ah._v337_apply_move_product(m["model"], "crew", "absence", "safety") == "move crew.absence->safety"
    assert fence.report()["rename_ledger"] == [{"kind": "move", "old": "crew.absence", "new": "safety.absence"}]
    result = fence.check(m)
    assert result.ok and _kinds(result) == {"P1": 2}


def test_hooks_are_noops_without_a_runtime():
    with_fence, without = _model(), _model()
    fence = _fence(install=True)
    ah._v337_apply_rename_product(with_fence["model"], "crew", "member", "crew_member")
    ah.set_vibe_scope_runtime(None)
    ah._v337_apply_rename_product(without["model"], "crew", "member", "crew_member")
    assert without == with_fence
    assert len(fence.report()["rename_ledger"]) == 2
    assert ah._vibe_scope_note_rename("product", "a.b", "a.c")["new_p"] == "c"
    assert {"kind": "product", "old": "a.b", "new": "a.c", "cause": ""} in ah.vov_rename_events()
    assert ah._vibe_scope_active() is False and ah.get_vibe_scope_runtime() is None


def test_drop_is_dangling_until_reconcile_applies_p2():
    fence = _fence()
    fence.record_change("drop", "crew", "absence", "engine:VREQ-1")
    m = _model()
    _domain(m, "crew")["products"] = [p for p in _domain(m, "crew")["products"] if p["name"] != "absence"]
    before = fence.check(m)
    assert before.ok and [d["fix"] for d in before.dangling] == ["P2", "P2"]
    applied = fence.reconcile_boundary(m, LOG)
    assert [a["kind"] for a in applied] == ["P2", "P2"]
    after = fence.check(m)
    assert after.ok and _kinds(after) == {"P2": 2} and not after.dangling


def test_new_in_scope_product_link_is_p3():
    fence = _fence()
    fence.record_change("create", "crew", "crew_shift", "engine:VREQ-2")
    m = _model()
    _domain(m, "crew")["products"].append({"name": "crew_shift", "primary_key": "crew_shift_id", "subdomain": "crew_records",
                                           "attributes": [{"name": "crew_shift_id", "type": "BIGINT"}]})
    column = next(a for a in _product(m, "flight", "scheduled_flight")["attributes"] if not a.get("foreign_key_to") and a["name"].endswith("_code"))
    column["foreign_key_to"] = "crew.crew_shift.crew_shift_id"
    result = fence.check(m)
    assert result.ok and _kinds(result) == {"P3": 1}


def test_new_fk_column_on_frozen_product_needs_p4_authorization():
    fence = _fence()
    m = _model()
    _product(m, "flight", "scheduled_flight")["attributes"].append(
        {"name": "duty_member_id", "type": "BIGINT", "foreign_key_to": "crew.member.member_id"})
    assert _kinds(fence.check(m)) == {"frozen_attr_added": 1}
    assert fence.authorize_oos_link("crew", "member", "flight.scheduled_flight") is False
    assert fence.authorize_oos_link("flight", "scheduled_flight", "fleet.aircraft_type") is False
    assert fence.authorize_oos_link("flight", "scheduled_flight", "crew.member", column="other_col") is True
    assert _kinds(fence.check(m)) == {"frozen_attr_added": 1}
    assert fence.authorize_oos_link("flight", "scheduled_flight", "crew.member.member_id", column="duty_member_id", vreq_id="VREQ-7") is True
    result = fence.check(m)
    assert result.ok and _kinds(result) == {"P4": 1}
    assert fence.report()["authorizations"][-1]["vreq_id"] == "VREQ-7"


def test_p4_authorization_follows_an_in_scope_rename():
    fence = _fence()
    assert fence.authorize_oos_link("flight", "scheduled_flight", "crew.member", vreq_id="VREQ-8")
    m = _model()
    ah._v337_apply_rename_product(m["model"], "crew", "member", "crew_member")
    _product(m, "flight", "scheduled_flight")["attributes"].append(
        {"name": "duty_member_id", "type": "BIGINT", "foreign_key_to": "crew.crew_member.crew_member_id"})
    assert _kinds(fence.check(m)) == {"P1": 19, "P4": 1}


LEAKS = {
    "frozen_domain_changed": lambda m: _domain(m, "flight").__setitem__("description", "leak"),
    "frozen_domain_removed": lambda m: m["model"]["domains"].remove(_domain(m, "route")),
    "extra_domain": lambda m: m["model"]["domains"].append({"name": "leak_domain", "products": []}),
    "frozen_product_changed": lambda m: _product(m, "flight", "scheduled_flight").__setitem__("description", "leak"),
    "frozen_product_removed": lambda m: _domain(m, "fleet")["products"].pop(0),
    "frozen_product_added": lambda m: _domain(m, "finance")["products"].append({"name": "leak_product", "attributes": []}),
    "frozen_attr_changed": lambda m: _product(m, "fleet", "aircraft_type")["attributes"][1].__setitem__("type", "LEAK_TYPE"),
    "frozen_attr_removed": lambda m: _product(m, "airport", "station")["attributes"].pop(),
    "frozen_attr_added": lambda m: _product(m, "cargo", _domain(m, "cargo")["products"][0]["name"])["attributes"].append({"name": "leak_col"}),
    "frozen_attr_order": lambda m: _product(m, "revenue", _domain(m, "revenue")["products"][0]["name"])["attributes"].reverse(),
    "frozen_mv_changed": lambda m: m["model"]["metric_views"][0].__setitem__("sql", "SELECT 1"),
    "frozen_mv_removed": lambda m: m["model"]["metric_views"].pop(1),
    "frozen_mv_added": lambda m: m["model"]["metric_views"].append({"view_name": "leak_mv", "owner_domain": "flight", "owner_product": "scheduled_flight"}),
    "model_metadata_changed": lambda m: m["model"].__setitem__("common_business_jargons", "leak"),
}


@pytest.mark.parametrize("kind", sorted(LEAKS))
def test_every_out_of_scope_leak_is_a_violation(kind):
    fence = _fence()
    m = _model()
    LEAKS[kind](m)
    result = fence.check(m)
    assert not result.ok and kind in _kinds(result), _kinds(result)


def test_in_scope_edits_are_not_violations():
    fence = _fence()
    m = _model()
    _domain(m, "crew")["description"] = "edited in scope"
    _product(m, "crew", "roster")["attributes"].append({"name": "new_in_scope_col", "type": "STRING"})
    _domain(m, "crew")["products"].append({"name": "brand_new", "attributes": []})
    m["model"]["metric_views"].append({"view_name": "crew_new_mv", "owner_domain": "crew", "owner_product": "roster", "sql": "x"})
    result = fence.check(m)
    assert result.ok and not result.permitted
    assert fence.changed_in_scope_products(m) == {("crew", "roster"), ("crew", "brand_new")}


def test_frozen_mv_reading_a_renamed_table_is_repointed_as_p5():
    read_column = _product(RAW, "crew", "qualification")["attributes"][2]["name"]
    fence = _fence(base=_with_frozen_mv_joining_crew_qualification(read_column))
    m = _with_frozen_mv_joining_crew_qualification(read_column)
    ah._v337_apply_rename_product(m["model"], "crew", "qualification", "crew_qualification")
    before = fence.check(m)
    assert before.ok and _kinds(before) == {"P1": 1, "metric_view": 1}
    assert [d["fix"] for d in before.dangling] == ["P5"]
    assert [a["kind"] for a in fence.reconcile_boundary(m, LOG)] == ["P5"]
    after = fence.check(m)
    assert after.ok and _kinds(after) == {"P1": 1, "P5": 1} and not after.dangling
    sql = next(x for x in m["model"]["metric_views"] if x["view_name"] == "airport_baggage_irregularity")["sql"]
    assert 'source: "`airlines_ecm`.`crew`.`crew_qualification`"' in sql


def test_arbitrary_sql_change_on_a_frozen_mv_is_not_p5():
    read_column = _product(RAW, "crew", "qualification")["attributes"][2]["name"]
    fence = _fence(base=_with_frozen_mv_joining_crew_qualification(read_column))
    m = _with_frozen_mv_joining_crew_qualification(read_column)
    ah._v337_apply_rename_product(m["model"], "crew", "qualification", "crew_qualification")
    fence.reconcile_boundary(m, LOG)
    mv = next(x for x in m["model"]["metric_views"] if x["view_name"] == "airport_baggage_irregularity")
    mv["sql"] += "\n-- extra"
    assert "frozen_mv_changed" in _kinds(fence.check(m))


def test_blocked_dropping_a_table_or_column_a_frozen_mv_reads():
    read_column = _product(RAW, "crew", "qualification")["attributes"][2]["name"]
    base = _with_frozen_mv_joining_crew_qualification(read_column)
    fence = _fence(base=base)
    dropped_table = copy.deepcopy(base)
    _domain(dropped_table, "crew")["products"] = [p for p in _domain(dropped_table, "crew")["products"] if p["name"] != "qualification"]
    assert _kinds(fence.check(dropped_table)).get("dropped_read_by_frozen_mv") == 1
    dropped_column = copy.deepcopy(base)
    qual = _product(dropped_column, "crew", "qualification")
    qual["attributes"] = [a for a in qual["attributes"] if a["name"] != read_column]
    result = fence.check(dropped_column)
    assert _kinds(result) == {"dropped_read_by_frozen_mv": 1}
    assert result.conflicts[0]["path"] == f"crew.qualification.{read_column}"


def test_renaming_the_key_a_frozen_mv_joins_on_is_repointed_not_blocked():
    pk = _product(RAW, "crew", "qualification")["primary_key"]
    base = _with_frozen_mv_joining_crew_qualification(pk)
    fence = _fence(base=base)
    m = copy.deepcopy(base)
    ah._v337_apply_rename_product(m["model"], "crew", "qualification", "crew_qualification")
    before = fence.check(m)
    assert before.ok and "dropped_read_by_frozen_mv" not in _kinds(before)
    assert [d["fix"] for d in before.dangling] == ["P5"]
    assert [a["kind"] for a in fence.reconcile_boundary(m, LOG)] == ["P5"]
    after = fence.check(m)
    assert after.ok and _kinds(after) == {"P1": 1, "P5": 1} and not after.dangling
    sql = next(x for x in m["model"]["metric_views"] if x["view_name"] == "airport_baggage_irregularity")["sql"]
    assert "qualification.crew_qualification_id" in sql and f"qualification.{pk}" not in sql
    assert 'source: "`airlines_ecm`.`crew`.`crew_qualification`"' in sql


def test_blocked_changing_the_type_of_a_referenced_in_scope_key():
    fence = _fence()
    m = _model()
    next(a for a in _product(m, "crew", "member")["attributes"] if a["name"] == "member_id")["type"] = "STRING"
    result = fence.check(m)
    assert _kinds(result) == {"pk_type_change": 1}
    assert "breaks 19 out-of-scope FK(s)" in result.conflicts[0]["detail"]


def test_blocked_moving_a_product_across_the_fence_both_ways():
    fence = _fence()
    out_move = _model()
    ah._v337_apply_move_product(out_move["model"], "crew", "base", "flight")
    result = fence.check(out_move)
    assert _kinds(result).get("cross_fence_move") == 1 and _kinds(result).get("frozen_product_added") == 1
    assert result.conflicts[0]["direction"] == "in->out"
    in_move = _model()
    ah._v337_apply_move_product(in_move["model"], "flight", "scheduled_flight", "crew")
    result = fence.check(in_move)
    assert _kinds(result).get("cross_fence_move") == 1 and _kinds(result).get("frozen_product_removed") == 1
    assert result.conflicts[0]["direction"] == "out->in"


def _leaky_flat_with_rename(fence):
    m = _model()
    ah._v337_apply_rename_product(m["model"], "crew", "member", "crew_member")
    for kind in ("frozen_domain_changed", "frozen_product_changed", "frozen_attr_changed", "frozen_attr_removed",
                 "frozen_product_added", "extra_domain", "frozen_mv_changed", "frozen_mv_removed", "frozen_mv_added"):
        LEAKS[kind](m)
    m["model"]["domains"][-1]["products"] = [{"name": "lp", "attributes": [{"name": "lp_id"}]}]
    return m


def test_checkpoint_restores_leaks_and_keeps_permitted_deltas():
    fence = _fence()
    m = _leaky_flat_with_rename(fence)
    d, p, a, mv = _flat(m)
    assert len(fence.check_flat(d, p, a, mv).violations) == 9
    restored = fence.checkpoint("unit", d, p, a, mv, LOG)
    after = fence.check_flat(d, p, a, mv)
    assert restored == 10
    assert after.ok and _kinds(after) == {"P1": 19}
    assert fence.checkpoint("unit-again", d, p, a, mv, LOG) == 0
    assert fence.report()["restores"] == {"unit": 10, "unit-again": 0}


def test_restore_keeps_non_canonical_keys_on_frozen_rows():
    fence = _fence()
    d, p, a, mv = _flat(RAW)
    row = next(r for r in p if r["domain"] == "flight")
    row["_pipeline_extra"] = 7
    row["description"] = "leak"
    assert fence.restore_flat(d, p, a, mv, "extra") == 1
    assert row["_pipeline_extra"] == 7 and row["description"] == _product(RAW, "flight", row["product"])["description"]


@pytest.mark.parametrize("scenario", ["in->out", "out->in", "subdomain"])
def test_restore_rolls_back_cross_fence_moves(scenario):
    if scenario == "subdomain":
        fence = _fence("crew.crew_records", mode="Some Subdomains")
        m = _model()
        victim = next(p for p in _domain(m, "crew")["products"] if p["subdomain"] == "crew_records")
        victim["subdomain"] = "flight_scheduling"
    else:
        fence = _fence()
        m = _model()
        if scenario == "in->out":
            ah._v337_apply_move_product(m["model"], "crew", "base", "flight")
        else:
            ah._v337_apply_move_product(m["model"], "flight", "scheduled_flight", "crew")
    d, p, a, mv = _flat(m)
    assert fence.check_flat(d, p, a, mv).conflicts
    fence.checkpoint(scenario, d, p, a, mv, LOG)
    after = fence.check_flat(d, p, a, mv)
    assert after.ok and not after.conflicts and not after.violations
    if scenario == "in->out":
        assert [r["domain"] for r in p if r["product"] == "base"] == ["crew"]
    if scenario == "out->in":
        assert [r["domain"] for r in p if r["product"] == "scheduled_flight"] == ["flight"]


def test_splice_restores_out_of_scope_subtrees_byte_for_byte():
    fence = _fence()
    m = _leaky_flat_with_rename(fence)
    m["model"]["description"] = "leak"
    report = fence.splice_and_verify(m, LOG)
    assert report["post"]["violations"] == 0 and report["post"]["by_kind"] == {"P1": 19}
    assert report["removed_out_of_scope_products"] == ["finance.leak_product", "leak_domain.lp"]
    source = {d["name"]: d for d in RAW["model"]["domains"]}
    for dom in m["model"]["domains"]:
        if dom["name"] == "crew":
            continue
        expected = copy.deepcopy(source[dom["name"]])
        for prod in expected["products"]:
            for attr in prod["attributes"]:
                if str(attr.get("foreign_key_to") or "").startswith("crew.member."):
                    attr["foreign_key_to"] = "crew.crew_member.crew_member_id"
        assert dom == expected, dom["name"]
    assert [d["name"] for d in m["model"]["domains"]] == [d["name"] for d in RAW["model"]["domains"]]
    assert [v["view_name"] for v in m["model"]["metric_views"]] == [v["view_name"] for v in RAW["model"]["metric_views"]]
    assert m["model"]["description"] == RAW["model"]["description"]


def test_splice_reapplies_p3_and_p4_on_spliced_frozen_products():
    fence = _fence()
    assert fence.authorize_oos_link("flight", "scheduled_flight", "crew.member.member_id", column="duty_member_id")
    fence.record_change("create", "crew", "crew_shift", "engine:VREQ-3")
    m = _model()
    _domain(m, "crew")["products"].append({"name": "crew_shift", "primary_key": "crew_shift_id", "attributes": [{"name": "crew_shift_id", "type": "BIGINT"}]})
    sched = _product(m, "flight", "scheduled_flight")
    unlinked = next(a for a in sched["attributes"] if not a.get("foreign_key_to") and a["name"].endswith("_code"))
    unlinked["foreign_key_to"] = "crew.crew_shift.crew_shift_id"
    sched["attributes"].append({"name": "duty_member_id", "type": "BIGINT", "foreign_key_to": "crew.member.member_id"})
    sched["description"] = "leak"
    report = fence.splice_and_verify(m, LOG)
    assert report["reapplied_links"] == 2 and report["post"]["by_kind"] == {"P3": 1, "P4": 1}
    sched = _product(m, "flight", "scheduled_flight")
    assert sched["description"] == _product(RAW, "flight", "scheduled_flight")["description"]
    assert next(a for a in sched["attributes"] if a["name"] == unlinked["name"])["foreign_key_to"] == "crew.crew_shift.crew_shift_id"
    assert sched["attributes"][-1]["name"] == "duty_member_id"


def test_splice_fails_closed_on_an_unrepairable_conflict():
    fence = _fence()
    m = _model()
    next(a for a in _product(m, "crew", "member")["attributes"] if a["name"] == "member_id")["type"] = "STRING"
    with pytest.raises(ah.VibeScopeFenceError) as exc:
        fence.splice_and_verify(m, LOG)
    assert exc.value.problems[0]["kind"] == "pk_type_change"


def test_splice_fails_closed_on_a_cross_fence_move():
    fence = _fence()
    m = _model()
    ah._v337_apply_move_product(m["model"], "crew", "base", "flight")
    with pytest.raises(ah.VibeScopeFenceError) as exc:
        fence.splice_and_verify(m, LOG)
    assert any(p["kind"] == "cross_fence_move" for p in exc.value.problems)


def test_some_subdomains_fence():
    fence = _fence("crew.crew_records", mode="Some Subdomains")
    rep = fence.report()
    assert rep["frozen"]["domains"] == 15 and rep["frozen"]["products"] == 200
    m = _model()
    crew = _domain(m, "crew")
    in_scope = [p for p in crew["products"] if p["subdomain"] == "crew_records"]
    frozen = [p for p in crew["products"] if p["subdomain"] != "crew_records"]
    crew["products"].append({"name": "new_ok", "subdomain": "crew_records", "attributes": []})
    crew["products"].append({"name": "new_bad", "subdomain": "flight_scheduling", "attributes": []})
    in_scope[0]["description"] = "in-scope edit"
    in_scope[1]["subdomain"] = "compliance_training"
    frozen[0]["description"] = "leak"
    crew["description"] = "leak"
    assert _kinds(fence.check(m)) == {"subdomain_violation": 1, "frozen_product_changed": 1, "frozen_domain_changed": 1, "cross_fence_move": 1}
    in_scope[1]["subdomain"] = "crew_records"
    fence.splice_and_verify(m, LOG)
    names = [p["name"] for p in _domain(m, "crew")["products"]]
    assert "new_ok" in names and "new_bad" not in names
    assert _domain(m, "crew")["description"] == _domain(RAW, "crew")["description"]


def test_new_base_fence_has_an_empty_baseline_and_drops_extra_domains():
    fence = ah.build_vibe_scope_fence(ah.parse_vibe_scope("Some Domains", "crew, flight"), RAW, "new base model", LOG)
    assert fence.report()["baseline"] == {"domains": 0, "products": 0, "metric_views": 0}
    generated = {"model": {"domains": [copy.deepcopy(_domain(RAW, n)) for n in ("crew", "flight", "finance")],
                           "metric_views": [copy.deepcopy(v) for v in RAW["model"]["metric_views"] if v["owner_domain"] in ("crew", "finance")]}}
    assert _kinds(fence.check(generated)) == {"extra_domain": 1, "frozen_mv_added": 9}
    fence.splice_and_verify(generated, LOG)
    assert [d["name"] for d in generated["model"]["domains"]] == ["crew", "flight"]
    assert {v["owner_domain"] for v in generated["model"]["metric_views"]} == {"crew"}


def test_new_base_subdomains_prunes_unlisted_subdomains_at_splice():
    fence = ah.build_vibe_scope_fence(ah.parse_vibe_scope("Some Subdomains", "crew.crew_records"), None, "new base model", LOG)
    generated = {"model": {"domains": [copy.deepcopy(_domain(RAW, "crew"))], "metric_views": []}}
    assert _kinds(fence.check(generated)) == {"subdomain_violation": 8}
    fence.splice_and_verify(generated, LOG)
    assert {p["subdomain"] for p in _domain(generated, "crew")["products"]} == {"crew_records"}


def test_all_domains_builds_no_fence():
    assert ah.build_vibe_scope_fence(ah.parse_vibe_scope("All Domains", "crew"), RAW, VOV, LOG) is None
    assert ah.build_vibe_scope_fence(None, RAW, VOV, LOG) is None


def test_build_rejects_invalid_specs_instead_of_running_unscoped():
    with pytest.raises(ValueError):
        ah.build_vibe_scope_fence(ah.parse_vibe_scope("Some Domains", ""), RAW, VOV, LOG)
    with pytest.raises(ValueError):
        ah.build_vibe_scope_fence(ah.parse_vibe_scope("Some Domains", "crew"), RAW, "shrink ecm", LOG)


def test_unknown_entries_are_accepted_as_new_containers_with_closest_names():
    fence = _fence("crew, crw_scheduling, brand_new_domain")
    resolved = fence.report()["resolved"]
    assert resolved["in_base"] == ["crew"] and resolved["new_containers"] == ["crw_scheduling", "brand_new_domain"]
    assert fence.classify_target("brand_new_domain") == "new"
    m = _model()
    m["model"]["domains"].append({"name": "brand_new_domain", "products": [{"name": "x", "attributes": []}]})
    assert fence.check(m).ok


def test_predicates_and_target_classification():
    fence = _fence()
    assert fence.is_in_scope_domain("Crew") and not fence.is_in_scope_domain("flight")
    assert fence.is_frozen_domain_record("flight") and not fence.is_frozen_domain_record("crew")
    assert fence.is_frozen_product("flight", "scheduled_flight") and not fence.is_frozen_product("crew", "member")
    assert fence.is_frozen_attr("flight", "scheduled_flight", "scheduled_flight_id")
    assert fence.is_frozen_metric_view("airport_baggage_irregularity")
    assert not fence.is_frozen_metric_view({"view_name": "x", "owner_domain": "crew", "owner_product": "member"})
    assert fence.is_frozen_metric_view({"view_name": "x", "owner_domain": ""})
    assert [fence.classify_target(*t) for t in (("crew",), ("flight",), ("nope",), ("crew", "member"),
                                                  ("flight", "scheduled_flight"), ("crew", "brand_new"), ("flight", "brand_new"))] == \
        ["in", "out", "out", "in", "out", "new", "out"]
    sub = _fence("crew.crew_records", mode="Some Subdomains", install=False)
    member_sub = _product(RAW, "crew", "member")["subdomain"]
    assert sub.is_frozen_product("crew", "member") is (member_sub != "crew_records")
    assert sub.is_frozen_domain_record("crew")
    assert sub.is_frozen_product("crew", "brand_new") and not sub.is_frozen_product("crew", "brand_new", subdomain="crew_records")


def test_frozen_edge_keys_use_the_cycle_breaker_key_format():
    keys = _fence().frozen_edge_keys()
    assert "flight.scheduled_flight\u2192fleet.aircraft_type" in keys
    assert not any(k.startswith("crew.") for k in keys)
    assert len(keys) == 1286


def test_record_rename_validates_its_input():
    fence = _fence()
    with pytest.raises(ValueError):
        fence.record_rename("domain", "crew.member", "crew_ops")
    with pytest.raises(ValueError):
        fence.record_rename("subdomain", "crew", "crew_ops")
    with pytest.raises(ValueError):
        fence.record_rename("attribute", "crew.member", "crew.member2")
    assert ah._vibe_scope_note_rename("attribute", "crew.member", "crew.member2") is None
    assert fence.report()["rename_ledger"] == []


def test_prompt_block_is_bounded_and_idempotent_by_sentinel():
    block = _fence().prompt_block()
    assert block.startswith(ah._VIBE_SCOPE_PROMPT_SENTINEL) and block.count(ah._VIBE_SCOPE_PROMPT_SENTINEL) == 1
    assert len(block) <= ah._VIBE_SCOPE_PROMPT_MAX_CHARS
    for token in ("crew", "P1:", "P2:", "P3:", "P4:", "P5:", "Blocked:", "scope_rejected", "supreme user authority"):
        assert token in block
    huge = _fence(", ".join(f"domain_{i:04d}" for i in range(2000)), install=False).prompt_block()
    assert len(huge) <= ah._VIBE_SCOPE_PROMPT_MAX_CHARS and "more)" in huge


def test_report_is_json_serializable_after_a_full_cycle():
    fence = _fence()
    m = _leaky_flat_with_rename(fence)
    fence.splice_and_verify(m, LOG)
    fence.authorize_oos_link("flight", "scheduled_flight", "crew.crew_member")
    json.dumps(fence.report())


def _legacy_rewrite_sql_via_rename_map(sql_txt, rename_map):
    _mvp_re = re
    if not sql_txt or not rename_map:
        return sql_txt, 0
    _parts = _mvp_re.split(r"('[^'\n]*'|\"[^\"\n]*\")", sql_txt)
    _hits = 0
    for _i, _part in enumerate(_parts):
        if _i % 2 == 1:
            continue
        for _old_k, _new_v in rename_map.items():
            _od, _op = _old_k
            _nd, _np = _new_v
            _pat = _mvp_re.compile(
                r"(?i)(?<![A-Za-z0-9_])`?" + _mvp_re.escape(_od) + r"`?\s*\.\s*`?" + _mvp_re.escape(_op) + r"`?(?![A-Za-z0-9_])"
            )
            _new_part, _n = _pat.subn(f"{_nd}.{_np}", _part)
            if _n:
                _parts[_i] = _new_part
                _part = _new_part
                _hits += _n
    return "".join(_parts), _hits


REWRITE_CASES = [
    ("SELECT * FROM customer.case WHERE id = 1", {("customer", "case"): ("customer", "customer_case")}),
    ("SELECT * FROM `billing`.`account` a JOIN `billing`.`account` b", {("billing", "account"): ("billing", "billing_account")}),
    ("SELECT * FROM Customer.CASE", {("customer", "case"): ("customer", "customer_case")}),
    ("SELECT * FROM customer.case WHERE label = 'old customer.case'", {("customer", "case"): ("customer", "customer_case")}),
    ("SELECT * FROM customer.case_history", {("customer", "case"): ("customer", "customer_case")}),
    ("SELECT * FROM customer.case", {}),
    ("SELECT * FROM customer.case c JOIN billing.account b", {("customer", "case"): ("customer", "x"), ("billing", "account"): ("b2", "y")}),
    ('source: "`cat`.`customer`.`case`"\nexpr: customer.case', {("customer", "case"): ("customer", "customer_case")}),
    ("", {("a", "b"): ("c", "d")}),
]


@pytest.mark.parametrize("sql,rename_map", REWRITE_CASES)
def test_shared_rewrite_helper_matches_the_pre_extraction_code(sql, rename_map):
    assert ah._mv_sql_apply_rename_map(sql, rename_map) == _legacy_rewrite_sql_via_rename_map(sql, rename_map)


def test_shared_rewrite_helper_can_rewrite_quoted_yaml_sources_for_the_fence():
    sql = 'source: "`cat`.`customer`.`case`"'
    assert ah._mv_sql_apply_rename_map(sql, {("customer", "case"): ("customer", "x")}) == (sql, 0)
    assert ah._mv_sql_apply_rename_map(sql, {("customer", "case"): ("`customer`", "`x`")}, skip_quoted=False) == \
        ('source: "`cat`.`customer`.`x`"', 1)


def test_surgical_preserve_uses_the_shared_helper_before_validation():
    body = slice_function_source("_preserve_baseline_metric_views_for_surgical")
    assert "def _rewrite_sql_via_rename_map" not in body
    assert body.index("_mv_sql_apply_rename_map(_sql, _rename_map)") < body.index("_ok, _reason = _all_refs_valid(_sql)")


def test_surgical_preserve_behavior_is_unchanged_by_the_extraction(monkeypatch):
    baseline = {"model": {
        "products": [{"domain": "customer", "product": "case"}, {"domain": "billing", "product": "account"}],
        "metric_views": [
            {"view_name": "customer_case_kpis", "owner_domain": "customer", "owner_product": "case",
             "sql": "CREATE VIEW m AS SELECT COUNT(1) FROM customer.case WHERE note = 'customer.case'"},
            {"view_name": "billing_account_kpis", "owner_domain": "billing", "owner_product": "account",
             "sql": 'source: "`cat`.`customer`.`case`"\nexpr: amount'},
        ],
    }}
    fake_sdk = types.ModuleType("databricks.sdk")
    fake_sdk.WorkspaceClient = lambda *a, **k: object()
    monkeypatch.setitem(sys.modules, "databricks", types.ModuleType("databricks"))
    monkeypatch.setitem(sys.modules, "databricks.sdk", fake_sdk)
    monkeypatch.setitem(ah.__dict__, "read_file_for_ddl", lambda path, w: json.dumps(baseline))
    widgets = {"operation": VOV, "base_version_for_review": "1", "model_scope": "mvm", "current_version": "2",
               "products": [{"domain": "customer", "product": "customer_case"}, {"domain": "billing", "product": "account"}]}
    config = {"TARGET_VOLUME": "/Volumes/c/_metamodel/vol_root/business/biz/v2/mvm"}
    ah._preserve_baseline_metric_views_for_surgical(widgets, config, LOG)
    records = {r["view_name"]: r for r in widgets["_metric_view_records"]}
    assert records["customer_case_kpis"]["owner_product"] == "customer_case"
    assert records["customer_case_kpis"]["sql"] == "CREATE VIEW m AS SELECT COUNT(1) FROM customer.customer_case WHERE note = 'customer.case'"
    assert records["billing_account_kpis"]["sql"] == baseline["model"]["metric_views"][1]["sql"]
    assert widgets["metric_view_count"] == 2
