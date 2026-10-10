"""v5.3.0 decision 1A: inside a scoped run only what the vibe names changes.

Live R11 734677890153805 (Some Domains = campaign, vibe: rename campaign.trafficking_order) also changed 8 campaign
products nobody named: the SelfFixer and logical_schema_review retyped and re-tagged their columns, p016/p73i renamed
columns (campaign.ad.ad_language_code -> language_code), and the deploy replaced those tables. Live R12 170774838278706
and R14 196633448822859 showed the same pattern on order. The user chose 1A: a scoped run follows the All Domains rule
inside its scope. Products and whole domains the requirements name stay open, every other in-scope base product is
frozen with all its columns (its FK columns may only be re-pointed, P1), and static-analysis findings on base entities
go to next_vibes.
"""
import copy
import sys
from pathlib import Path

import pytest

sys.path.insert(0, str(Path(__file__).resolve().parent))
import conftest  # noqa: F401,E402
import agent_helpers as ah  # noqa: E402
import test_v514_vibe_scope_parse as PS  # noqa: E402

VOV = "vibe modeling of version"


class _Log:
    def __init__(self):
        self.lines = []

    def info(self, msg, *a, **k):
        self.lines.append(str(msg))

    warning = error = debug = info


def _vreq(vid, target, intent):
    return ah.RawVREQ(vreq_id=vid, intent=intent, target=target, source_quote=intent, source_chunk_id="c1", is_user_directive=True)


RENAME_MEMBER = _vreq("VREQ-0001", "crew.member", "Rename the product member to crew_member")


@pytest.fixture(autouse=True)
def _isolate():
    ah.set_vibe_scope_runtime(None)
    ah.vov_ledger_reset()
    yield
    ah.set_vibe_scope_runtime(None)
    ah.vov_ledger_reset()


def _scoped(vreqs, entries="crew"):
    log = _Log()
    raw = copy.deepcopy(PS.RAW)
    fence = ah.build_vibe_scope_fence(ah.parse_vibe_scope("Some Domains", entries), copy.deepcopy(raw), VOV, log)
    ah.set_vibe_scope_runtime(fence)
    returned = ah._vibe_scope_start_requested(vreqs, copy.deepcopy(raw), log, copy.deepcopy(raw))
    return fence, returned, log, raw


def test_unnamed_in_scope_products_freeze_once_the_vibe_is_read():
    fence, returned, log, _raw = _scoped([RENAME_MEMBER])
    assert returned is fence and fence.spec.named_only and fence.spec.mode == "domains"
    assert not fence.is_frozen_product("crew", "member")
    assert fence.is_frozen_product("crew", "pairing") and fence.is_frozen_product("crew", "base")
    assert fence.is_frozen_product("flight", "scheduled_flight")
    assert fence.is_frozen_domain_record("crew")
    assert any("[vibe-scope-named-only FIRED v5.3.0]" in m for m in log.lines)


def test_a_whole_named_domain_stays_open():
    fence, _returned, _log, _raw = _scoped([_vreq("VREQ-0001", "crew", "Add an audit_status column to every product in the crew domain")])
    assert fence.spec.named_only
    assert not fence.is_frozen_product("crew", "pairing") and not fence.is_frozen_domain_record("crew")
    assert fence.is_frozen_product("flight", "scheduled_flight")


def test_a_requirement_without_a_target_keeps_the_scope_open():
    fence, returned, log, _raw = _scoped([_vreq("VREQ-0001", "", "Improve the descriptions")])
    assert returned is None and not fence.spec.named_only
    assert not fence.is_frozen_product("crew", "pairing")
    assert any("[vibe-scope-named-off FIRED v5.3.0]" in m for m in log.lines)


def test_metric_views_of_unnamed_in_scope_products_are_frozen():
    fence, _returned, _log, _raw = _scoped([RENAME_MEMBER])
    frozen = fence._active.frozen_mvs
    assert ah._vov285_san("crew_pairing") in frozen and ah._vov285_san("crew_member") not in frozen


def test_autofix_cannot_change_an_unnamed_in_scope_product_but_can_shape_a_named_new_one():
    add_shift = _vreq("VREQ-0002", "crew.crew_shift", "Add a new product crew_shift to the crew domain")
    fence, _returned, log, raw = _scoped([RENAME_MEMBER, add_shift])
    d, p, a, _mv = ah.model_to_widgets_flat(copy.deepcopy(raw))
    p.append({"domain": "crew", "product": "crew_shift", "subdomain": "", "primary_key": "crew_shift_id", "description": "new"})
    p.append({"domain": "crew", "product": "crew_unplanned", "subdomain": "", "primary_key": "crew_unplanned_id", "description": "new"})
    with ah._VibeScopeContainment(fence, "autofix:test", d, p, a, log):
        for row in p:
            if row["product"] in ("pairing", "crew_shift"):
                row["description"] = "rewritten by a pass"
    descriptions = {row["product"]: row["description"] for row in p if row["domain"] == "crew"}
    base = {row["product"]: row["description"] for row in ah.model_to_widgets_flat(copy.deepcopy(raw))[1] if row["domain"] == "crew"}
    assert descriptions["pairing"] == base["pairing"]
    assert descriptions["crew_shift"] == "rewritten by a pass"
    assert fence.is_frozen_product("crew", "crew_unplanned") and not fence.is_frozen_product("crew", "crew_shift")


def test_static_analysis_findings_on_base_products_go_to_next_vibes():
    fence, _returned, _log, raw = _scoped([RENAME_MEMBER])
    known = {ah._vov285_san(d["name"]) for d in raw["model"]["domains"]}
    on_base = {"category": "missing_attribute_description", "message": "crew.pairing.pairing_code has no description",
               "details": {"table": "crew.pairing"}}
    on_new = {"category": "missing_attribute_description", "message": "crew.crew_shift.shift_code has no description",
              "details": {"table": "crew.crew_shift"}}
    assert ah._vibe_scope_issue_verdict(fence, on_base, known) == "out"
    assert ah._vibe_scope_issue_verdict(fence, on_new, known) == "in"


def test_after_the_engine_the_named_product_freezes_too_and_a_created_product_stays_open():
    fence, _returned, log, raw = _scoped([RENAME_MEMBER])
    model = copy.deepcopy(raw)
    assert ah._v337_apply_rename_product(model["model"], "crew", "member", "crew_member") is not None
    d, p, a, mv = ah.model_to_widgets_flat(model)
    p.append({"domain": "crew", "product": "crew_shift", "subdomain": "", "primary_key": "crew_shift_id"})
    snapshot = fence.requested_snapshot(d, p, a, mv, log)
    assert snapshot is not None
    spec, baseline = snapshot
    assert spec.mode == "domains" and spec.named_only
    assert ah._vov285_san("crew_member") in {k[1] for k in baseline.frozen_products}
    assert (ah._vov285_san("crew"), ah._vov285_san("crew_shift")) not in baseline.frozen_products


def test_the_prompt_lists_what_the_vibe_names_inside_the_scope():
    fence, _returned, _log, _raw = _scoped([RENAME_MEMBER])
    block = fence.prompt_block()
    assert "Inside the scope, only what the user's vibe names may change: crew.member" in block


def test_an_all_domains_requested_fence_is_unchanged():
    raw = copy.deepcopy(PS.RAW)
    log = _Log()
    fence = ah._vibe_scope_start_requested([RENAME_MEMBER], raw, log, copy.deepcopy(raw))
    assert fence is not None and fence.spec.mode == "requested" and not fence.spec.named_only
    assert fence.is_frozen_product("crew", "pairing") and not fence.is_frozen_product("crew", "member")


def _product(model, domain, name):
    return next(p for d in model["model"]["domains"] if d["name"] == domain for p in d["products"] if p["name"] == name)


def test_the_model_json_check_ignores_working_fields_the_engine_baseline_carries():
    fence, _returned, log, raw = _scoped([RENAME_MEMBER])
    engine = copy.deepcopy(raw)
    pairing = _product(engine, "crew", "pairing")
    next(a for a in pairing["attributes"] if a["name"] == pairing["primary_key"])["is_primary_key"] = True
    assert fence.bind_engine_baseline(engine, log)["rebound_to_engine"]
    serialized = copy.deepcopy(raw)
    assert fence.check(serialized).ok, "live R18 710756936383949 failed closed on order.order_note.order_note_id (fields is_primary_key)"
    _product(serialized, "crew", "pairing")["description"] = "rewritten by a pass"
    assert [v["kind"] for v in fence.check(serialized).violations] == ["frozen_product_changed"]


def test_the_serialize_gate_restores_unnamed_in_scope_products_from_the_base():
    fence, _returned, log, raw = _scoped([RENAME_MEMBER])
    serialized = copy.deepcopy(raw)
    assert ah._v337_apply_rename_product(serialized["model"], "crew", "member", "crew_member") is not None
    pairing = _product(serialized, "crew", "pairing")
    pairing["description"] = "rewritten by a pass"
    next(a for a in pairing["attributes"] if a["name"] == pairing["primary_key"])["is_primary_key"] = True
    fence.splice_and_verify(serialized, log)
    assert _product(serialized, "crew", "pairing") == _product(raw, "crew", "pairing")
    crew = {p["name"] for d in serialized["model"]["domains"] if d["name"] == "crew" for p in d["products"]}
    assert "crew_member" in crew and "member" not in crew


def test_the_metric_view_oracle_freezes_views_of_unnamed_in_scope_products():
    fence, _returned, _log, _raw = _scoped([RENAME_MEMBER])
    assert fence.is_frozen_metric_view({"owner_domain": "crew", "owner_product": "pairing"})
    assert not fence.is_frozen_metric_view({"owner_domain": "crew", "owner_product": "member"})
    assert not fence.is_frozen_metric_view({"owner_domain": "crew", "owner_product": "crew_member"})
    wide, _returned, _log, _raw = _scoped([_vreq("VREQ-0001", "", "Improve the descriptions")])
    assert not wide.is_frozen_metric_view({"owner_domain": "crew", "owner_product": "pairing"})


def _crew_plan(raw):
    crew = [p["name"] for d in raw["model"]["domains"] if d["name"] == "crew" for p in d["products"]]
    plan = ah._scope_deploy_plan({"changed_in_scope_products": [], "preserved_products": [f"crew.{p}" for p in crew],
                                  "permitted_deltas": []}, raw, None)
    plan.bind({plan.key("crew", p): f"`cat`.`crew`.`{p}`" for p in crew})
    return plan


def test_schema_tags_follow_the_domain_record_rule():
    stmt = "ALTER SCHEMA `cat`.`crew` SET TAGS ('dbx_domain' = 'crew');"
    _fence, _returned, _log, raw = _scoped([RENAME_MEMBER])
    assert not _crew_plan(raw).keep_statement(stmt)
    _fence, _returned, _log, raw = _scoped([_vreq("VREQ-0001", "crew", "Add an audit_status column to every product in the crew domain")])
    assert _crew_plan(raw).keep_statement(stmt)
    _fence, _returned, _log, raw = _scoped([_vreq("VREQ-0001", "", "Improve the descriptions")])
    assert _crew_plan(raw).keep_statement(stmt)


def test_the_install_plan_oracle_keeps_the_named_only_rule():
    import json
    fence, _returned, _log, _raw = _scoped([RENAME_MEMBER])
    facts = json.loads(json.dumps(fence.report(), default=str))
    assert ["crew", "member"] in facts["named"]["products"]
    oracle = ah._vibe_scope_deploy_oracle(facts, use_runtime=False)
    assert oracle.spec.mode == "domains" and oracle.spec.named_only
    assert oracle.is_frozen_metric_view({"owner_domain": "crew", "owner_product": "pairing"})
    assert not oracle.is_frozen_metric_view({"owner_domain": "crew", "owner_product": "crew_member"})
    assert oracle.is_frozen_metric_view({"owner_domain": "flight", "owner_product": "scheduled_flight"})
    wide, _returned, _log, _raw = _scoped([_vreq("VREQ-0001", "", "Improve the descriptions")])
    plain = ah._vibe_scope_deploy_oracle(json.loads(json.dumps(wide.report(), default=str)), use_runtime=False)
    assert not plain.spec.named_only and not plain.is_frozen_metric_view({"owner_domain": "crew", "owner_product": "pairing"})


def test_entity_changes_ignore_working_fields_model_json_does_not_store():
    fence, _returned, _log, raw = _scoped([RENAME_MEMBER])
    cur = copy.deepcopy(raw)
    pairing = _product(cur, "crew", "pairing")
    next(a for a in pairing["attributes"] if a["name"] == pairing["primary_key"])["is_primary_key"] = True
    changed = [e for e in ah.vov_entity_changes(raw, cur, {"operation": VOV})["entries"] if e["status"] != "unchanged"]
    assert changed == [], "live R20 361205040527084 reported order.order_note.order_note_id modified ['is_primary_key']"
    _product(cur, "crew", "pairing")["description"] = "rewritten by a pass"
    changed = [e for e in ah.vov_entity_changes(raw, cur, {"operation": VOV})["entries"] if e["status"] != "unchanged"]
    assert [(e["kind"], e["path"], e["fields"]) for e in changed] == [("product", "crew.pairing", ["description"])]
