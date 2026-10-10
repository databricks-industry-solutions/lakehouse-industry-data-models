"""v5.1.4 decision 9A on the real airlines v1 model: P1-P3 only as consequences of an explicit,
ledger-recorded in-scope rename, drop or add.

- P2 needs a ledger drop and P3 needs a ledger create in the strict checks (checkpoints, splice).
- An in-scope table that out-of-scope FKs reference and that disappears or moves with no ledger
  entry is an unrequested_drop_of_referenced conflict: restored (or moved back), WARN, outcomes.
- Engine gates stay permissive for VREQ-driven drops; the post-engine attribution and the triage
  feed the ledger.
"""
import copy
import json
import logging
import sys
from pathlib import Path

import pytest

sys.path.insert(0, str(Path(__file__).resolve().parent))
import conftest  # noqa: F401,E402
import agent_helpers as ah  # noqa: E402
import v514_feedback_util as fu  # noqa: E402

REPO = Path(__file__).resolve().parents[3]
RAW = json.loads((REPO / "data-models" / "airlines" / "v1" / "mvm" / "model.json").read_text())
VOV = "vibe modeling of version"
LOG = logging.getLogger("test_v514_9a")
TARGET = ("crew", "absence")
REFERRERS = ("flight.cancellation.absence_id", "flight.delay_record.absence_id")


@pytest.fixture(autouse=True)
def _reset_runtime(monkeypatch):
    fu.inject_spark_types(monkeypatch)
    ah.set_vibe_scope_runtime(None)
    yield
    ah.set_vibe_scope_runtime(None)


def _fence(entries="crew", base=RAW):
    fence = ah.build_vibe_scope_fence(ah.parse_vibe_scope("Some Domains", entries), base, VOV, LOG)
    ah.set_vibe_scope_runtime(fence)
    return fence


def _model():
    return copy.deepcopy(RAW)


def _flat(root):
    return [list(x) for x in ah.model_to_widgets_flat(root)]


def _fk_of(attrs, domain, product, attribute):
    return next(a.get("foreign_key_to") for a in attrs
                if a.get("domain") == domain and a.get("product") == product and a.get("attribute") == attribute)


def _has_product(rows, domain, product):
    return any(r.get("domain") == domain and r.get("product") == product for r in rows)


def _drop_flat(products, attributes, domain, product):
    products[:] = [p for p in products if not (p.get("domain") == domain and p.get("product") == product)]
    attributes[:] = [a for a in attributes if not (a.get("domain") == domain and a.get("product") == product)]


def _nested_drop(root, domain, product):
    dom = next(d for d in root["model"]["domains"] if d["name"] == domain)
    dom["products"] = [p for p in dom["products"] if p["name"] != product]


def _nested_has(root, domain, product):
    dom = next(d for d in root["model"]["domains"] if d["name"] == domain)
    return any(p["name"] == product for p in dom["products"])


def test_target_is_referenced_but_not_read_by_a_frozen_metric_view():
    fence = _fence()
    referenced = {ah._v337_parse_fk_fqn(fk)[:2] for items in fence._active.boundary.values() for _a, fk, _p in items}
    assert TARGET in referenced
    assert all(TARGET not in [tuple(k) for k in reads] for reads in fence._active.mv_reads.values())


def test_unrequested_drop_is_restored_at_a_checkpoint_and_out_of_scope_fks_keep_their_target(caplog):
    fence = _fence()
    d, p, a, mv = _flat(_model())
    _drop_flat(p, a, *TARGET)
    with caplog.at_level(logging.WARNING):
        restored = fence.checkpoint("after_qa", d, p, a, mv, LOG)
    assert restored >= 1
    assert _has_product(p, *TARGET)
    assert any(x.get("domain") == "crew" and x.get("product") == "absence" for x in a)
    for ref in REFERRERS:
        dom, prod, col = ref.split(".")
        assert _fk_of(a, dom, prod, col).startswith("crew.absence.")
    entry = fence.report()["unrequested_drops"][0]
    assert entry["path"] == "crew.absence" and entry["repair"] == "restored" and entry["where"] == "after_qa"
    assert "[vibe-scope-unrequested-drop FIRED v5.1.4]" in caplog.text


def test_a_heuristic_drop_that_also_cleared_the_fks_is_undone_completely():
    fence = _fence()
    d, p, a, mv = _flat(_model())
    ah.remove_product_and_references(*TARGET, p, a)
    assert not _fk_of(a, "flight", "cancellation", "absence_id")
    fence.checkpoint("after_qa", d, p, a, mv, LOG)
    assert _has_product(p, *TARGET)
    assert _fk_of(a, "flight", "cancellation", "absence_id").startswith("crew.absence.")
    assert fence.check_flat(d, p, a, mv).ok


def test_a_ledger_drop_permits_p2_and_nothing_is_restored():
    fence = _fence()
    fence.record_change("drop", *TARGET, "engine:VREQ-9")
    d, p, a, mv = _flat(_model())
    _drop_flat(p, a, *TARGET)
    fence.checkpoint("after_qa", d, p, a, mv, LOG)
    assert not _has_product(p, *TARGET)
    for ref in REFERRERS:
        dom, prod, col = ref.split(".")
        assert not _fk_of(a, dom, prod, col)
    assert fence.report()["unrequested_drops"] == []
    assert fence.report()["change_ledger"] == [{"kind": "drop", "path": "crew.absence", "cause": "engine:VREQ-9"}]


def _base_with_unlinked_oos_column():
    base = _model()
    canc = next(p for p in next(d for d in base["model"]["domains"] if d["name"] == "flight")["products"] if p["name"] == "cancellation")
    canc["attributes"].append({"name": "standby_pool_id", "column_name": "standby_pool_id", "type": "BIGINT", "foreign_key_to": "",
                               "description": "Standby pool that covered the cancellation.", "tags": ""})
    return base


def _with_new_crew_product_and_p3_link(root):
    crew = next(d for d in root["model"]["domains"] if d["name"] == "crew")
    crew["products"].append({"name": "standby_pool", "table_name": "standby_pool", "primary_key": "standby_pool_id",
                             "description": "Pool of standby crew.", "attributes": [
                                 {"name": "standby_pool_id", "column_name": "standby_pool_id", "type": "BIGINT", "description": "Pool id."}]})
    canc = next(p for p in next(d for d in root["model"]["domains"] if d["name"] == "flight")["products"] if p["name"] == "cancellation")
    next(x for x in canc["attributes"] if x["name"] == "standby_pool_id")["foreign_key_to"] = "crew.standby_pool.standby_pool_id"
    return root


def test_p3_link_to_a_new_product_needs_a_ledger_create():
    base = _base_with_unlinked_oos_column()
    fence = _fence(base=base)
    d, p, a, mv = _flat(_with_new_crew_product_and_p3_link(copy.deepcopy(base)))
    fence.checkpoint("after_qa", d, p, a, mv, LOG)
    assert not _fk_of(a, "flight", "cancellation", "standby_pool_id")

    fence = _fence(base=base)
    fence.record_change("create", "crew", "standby_pool", "engine:VREQ-4")
    d, p, a, mv = _flat(_with_new_crew_product_and_p3_link(copy.deepcopy(base)))
    fence.checkpoint("after_qa", d, p, a, mv, LOG)
    assert _fk_of(a, "flight", "cancellation", "standby_pool_id") == "crew.standby_pool.standby_pool_id"
    assert fence.check_flat(d, p, a, mv).summary()["by_kind"].get("P3") == 1


def test_engine_gates_stay_permissive_for_a_requirement_drop_but_strict_checks_are_not():
    fence = _fence()
    before = _model()
    after = _model()
    _nested_drop(after, *TARGET)
    for d in after["model"]["domains"]:
        for prod in d["products"]:
            for attr in prod["attributes"]:
                if str(attr.get("foreign_key_to") or "").startswith("crew.absence."):
                    attr["foreign_key_to"] = ""
    assert ah._vibe_scope_new_problems(fence, after, before_model=before) == ([], [])
    strict = fence.check(after)
    assert not strict.ok
    assert "unrequested_drop_of_referenced" in strict.summary()["by_kind"] or "frozen_attr_changed" in strict.summary()["by_kind"]


def test_post_engine_attribution_records_targeted_drops_only():
    fence = _fence()
    initial = _model()
    final = _model()
    _nested_drop(final, *TARGET)
    _nested_drop(final, "crew", "training_event")
    result = ah.PipelineResult(
        initial_model=initial, final_model=final, outline=None, raw_vreqs=[],
        batches=[ah.Batch(batch_id="B1", vreq_ids=("VREQ-1",), intent_summary="drop absence",
                          target_entities=(("crew", "absence"),), data_payload=())],
        outcomes=[ah.VReqOutcome(batch_id="B1", vreq_ids=("VREQ-1",), status="applied", diagnostic="", attempts=1)],
        coverage_pct=100.0)
    recorded, unattributed = ah._vibe_scope_record_engine_changes(fence, result, LOG)
    assert recorded == {"drop": 1, "create": 0}
    assert unattributed["drop"] == ["crew.training_event"]
    assert fence._explicit("drop", ("crew", "absence"))
    assert not fence._explicit("drop", ("crew", "training_event"))


def test_rejected_batches_do_not_make_a_drop_explicit():
    fence = _fence()
    final = _model()
    _nested_drop(final, *TARGET)
    result = ah.PipelineResult(
        initial_model=_model(), final_model=final, outline=None, raw_vreqs=[],
        batches=[ah.Batch(batch_id="B1", vreq_ids=("VREQ-1",), intent_summary="drop absence",
                          target_entities=(("crew", "absence"),), data_payload=())],
        outcomes=[ah.VReqOutcome(batch_id="B1", vreq_ids=("VREQ-1",), status="scope_mismatch", diagnostic="", attempts=3)],
        coverage_pct=0.0)
    recorded, unattributed = ah._vibe_scope_record_engine_changes(fence, result, LOG)
    assert recorded == {"drop": 0, "create": 0} and unattributed["drop"] == ["crew.absence"]


def test_triage_registers_in_scope_targets_for_attribution():
    fence = _fence()
    vreqs = [ah.RawVREQ(vreq_id="VREQ-2", intent="drop the absence table", target="crew.absence", source_quote="", source_chunk_id="c0")]
    kept, rejected, _outcomes = ah._vibe_scope_triage_vreqs(fence, vreqs, _model(), LOG)
    assert [v.vreq_id for v in kept] == ["VREQ-2"] and not rejected
    assert fence.requested_by(["VREQ-2"], "crew", "absence") == "VREQ-2"
    assert fence.requested_by(["VREQ-2"], "crew", "member") is None


def test_splice_restores_an_unrequested_drop_instead_of_failing_or_unlinking():
    fence = _fence()
    root = _model()
    _nested_drop(root, *TARGET)
    fence.splice_and_verify(root, LOG)
    assert _nested_has(root, *TARGET)
    canc = next(p for p in next(d for d in root["model"]["domains"] if d["name"] == "flight")["products"] if p["name"] == "cancellation")
    assert next(x for x in canc["attributes"] if x["name"] == "absence_id")["foreign_key_to"].startswith("crew.absence.")
    assert fence.report()["last_splice"]["restored_unrequested_drops"] == 1


def test_an_unrecorded_move_of_a_referenced_product_is_moved_back():
    fence = _fence("crew, safety")
    d, p, a, mv = _flat(_model())
    for row in p + a:
        if row.get("domain") == "crew" and row.get("product") == "absence":
            row["domain"] = "safety"
    fence.checkpoint("after_qa", d, p, a, mv, LOG)
    assert _has_product(p, *TARGET) and not _has_product(p, "safety", "absence")
    entry = fence.report()["unrequested_drops"][0]
    assert entry["repair"] == "moved_back" and entry["moved_to"] == "safety.absence"


def test_serialize_gate_records_unrequested_drops_in_outcomes_and_the_block():
    fence = _fence()
    root = _model()
    _nested_drop(root, *TARGET)
    wv = {"_vibe_scope_outcomes": {"scope_rejected": []}, "base_version_for_review": "1", "model_scope": "mvm",
          "business_catalog": "airlines_ecm"}
    facts = ah._vibe_scope_serialize_gate(root, wv, LOG)
    assert [e["path"] for e in wv["_vibe_scope_outcomes"]["unrequested_drop_of_referenced"]] == ["crew.absence"]
    assert [e["path"] for e in facts["unrequested_drops"]] == ["crew.absence"]
    assert _nested_has(root, *TARGET)


def _architect_response(free):
    return {
        "products_to_remove": [{"domain_product_key": "crew.absence", "reason": "x"}, {"domain_product_key": f"crew.{free}", "reason": "x"}],
        "products_to_rename": [{"domain": "crew", "old_name": "absence", "new_name": "leave_absence", "reason": "x"},
                               {"domain": "crew", "old_name": free, "new_name": f"{free}_renamed", "reason": "x"}],
        "products_to_merge": [{"domain": "crew", "source_products": ["absence", free], "target_product": "absence_merged", "reason": "x"},
                              {"domain": "crew", "source_products": ["absence", "absence"], "target_product": "absence", "reason": "x"}],
        "products_to_split": [{"domain": "crew", "source_product": "absence", "new_products": [], "reason": "x"},
                              {"domain": "crew", "source_product": free, "new_products": [], "reason": "x"}],
        "products_to_move": [{"product": "absence", "source_domain": "crew", "target_domain": "fleet", "reason": "x"},
                             {"product": free, "source_domain": "crew", "target_domain": "fleet", "reason": "x"}],
        "domains_to_remove": [{"name": "crew", "reason": "x"}],
        "domains_to_split": [{"source_domain": "crew", "new_domains": [], "reason": "x"}],
    }


def test_architect_proposals_that_drop_a_referenced_in_scope_product_need_a_ledger_drop(caplog):
    fence = _fence("crew, fleet")
    _d, products, _a, _mv = _flat(_model())
    free = "pairing"
    assert fence.referenced_from_outside(*TARGET) and not fence.referenced_from_outside("crew", free)
    with caplog.at_level(logging.INFO):
        out = ah._vibe_scope_filter_architect_response(_architect_response(free), products, LOG)
    assert [e["domain_product_key"] for e in out["products_to_remove"]] == [f"crew.{free}"]
    assert [e["old_name"] for e in out["products_to_rename"]] == [free]
    assert [e["target_product"] for e in out["products_to_merge"]] == ["absence"]
    assert [e["source_product"] for e in out["products_to_split"]] == [free]
    assert [e["product"] for e in out["products_to_move"]] == [free]
    assert out["domains_to_remove"] == [] and out["domains_to_split"] == []
    assert "[vibe-scope-architect-referenced-guard FIRED v5.1.4] dropped 7 architect proposal(s)" in caplog.text
    fence.record_change("drop", "crew", "absence", "engine:V1")
    out = ah._vibe_scope_filter_architect_response(_architect_response(free), products, LOG)
    assert [e["domain_product_key"] for e in out["products_to_remove"]] == ["crew.absence", f"crew.{free}"]
    assert len(out["products_to_rename"]) == 2 and len(out["products_to_move"]) == 2
    assert out["domains_to_remove"] == [], "other crew products are still referenced from outside"


def test_the_architect_guard_follows_a_ledger_rename_of_a_referenced_product():
    fence = _fence()
    _d, products, _a, _mv = _flat(_model())
    fence.record_rename("product", "crew.absence", "crew.leave_of_absence")
    assert fence.referenced_from_outside("crew", "leave_of_absence")
    out = ah._vibe_scope_filter_architect_response(
        {"products_to_remove": [{"domain_product_key": "crew.leave_of_absence", "reason": "x"}]}, products, LOG)
    assert out["products_to_remove"] == []
