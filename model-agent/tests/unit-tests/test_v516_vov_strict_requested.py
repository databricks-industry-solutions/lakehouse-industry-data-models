"""v5.1.6 — decision 1B: an unscoped 'vibe modeling of version' changes only what the vibe names.

Live run R2 (1079936862964808, agent 5.1.5, vs514 retail, unscoped VOV v1 -> v2) asked for one new product and
three column edits. v2 also renamed product.campaign to product_campaign (cross-domain collision autofix), renamed
29 attributes and dropped 16 on products nobody named (p016 role prefixes, p73i prefix strips, fk_name_fix, the
SelfFixer acting on static-analysis findings) and renamed the user's own new column sku.season_code to
sku_season_code. The user chose 1B: outside what the vibe names only FK dependencies may change, and every
static-analysis finding on a base entity goes to next_vibes instead of being applied.

The run now builds a "requested" fence from the user's requirement targets right after extraction, so the
existing vibe_scope machinery (engine gate, containment, checkpoints, serialize splice, deploy plan) freezes
every product the vibe does not name.
"""
import copy
import json
import logging
import sys
import types
from pathlib import Path

import pytest

sys.path.insert(0, str(Path(__file__).resolve().parent))
import conftest  # noqa: F401,E402
import agent_helpers as ah  # noqa: E402
from notebook_source_util import notebook_concat_source  # noqa: E402

FIXTURE = Path(__file__).resolve().parent / "fixtures" / "v516_r0p_campaign_subset.json"


class _Log:
    def __init__(self):
        self.infos, self.warnings = [], []

    def info(self, msg, *a, **k):
        self.infos.append(str(msg))

    def warning(self, msg, *a, **k):
        self.warnings.append(str(msg))

    error = warning

    def debug(self, *a, **k):
        pass

    def all(self):
        return self.infos + self.warnings


def _model():
    return copy.deepcopy(json.loads(FIXTURE.read_text())["model"])


def _keys(*pairs):
    return {tuple(ah._vov285_san(x) for x in pair) for pair in pairs}


def _vreq(vid, target, intent=""):
    return ah.RawVREQ(vreq_id=vid, intent=intent or f"change {target}", target=target, source_quote=intent or target,
                      source_chunk_id="c1", is_user_directive=True)


R2_VREQS = [
    _vreq("VREQ-001", "customer.gift_card", "add a new product gift_card with one row per issued gift card"),
    _vreq("VREQ-002", "order.order_promotion.gift_card_id", "add a foreign key column gift_card_id to order_promotion"),
    _vreq("VREQ-003", "product.digital_asset.season_code", "add a STRING attribute season_code to digital_asset"),
]


@pytest.fixture
def fence():
    log = _Log()
    built = ah._vibe_scope_start_requested(R2_VREQS, {"model": _model()}, log)
    assert built is not None
    yield built, log
    ah.set_vibe_scope_runtime(None)


def test_the_spec_lists_exactly_the_named_products():
    spec, wide = ah._vibe_scope_requested_spec(R2_VREQS, {"model": _model()})
    assert wide == []
    assert spec.mode == "requested" and spec.active
    assert spec.products == _keys(("customer", "gift_card"), ("order", "order_promotion"), ("product", "digital_asset"))
    assert spec.domains == {"customer", "order", "product"}
    assert spec.whole_domains == frozenset() and spec.new_names == frozenset()
    assert list(spec.entries) == ["customer.gift_card", "order.order_promotion", "product.digital_asset"]


def test_a_domain_level_target_puts_the_whole_domain_in_scope():
    spec, _ = ah._vibe_scope_requested_spec([_vreq("V1", "customer", "rewrite the customer domain description")], {"model": _model()})
    assert spec.whole_domains == {"customer"} and spec.products == frozenset()


def test_a_bare_name_resolves_to_every_product_that_carries_it():
    spec, _ = ah._vibe_scope_requested_spec([_vreq("V1", "campaign", "describe campaign better")], {"model": _model()})
    assert spec.products == _keys(("customer", "campaign"), ("product", "campaign"))


def test_an_unknown_bare_name_is_allowed_as_a_new_entity_anywhere():
    spec, _ = ah._vibe_scope_requested_spec([_vreq("V1", "gift_card", "add a product gift_card")], {"model": _model()})
    assert spec.new_names == {ah._vov285_san("gift_card")} and spec.products == frozenset()


@pytest.mark.parametrize("target", ["every product", "Model-wide", "all HR products derived from DDL emp_history", ""])
def test_a_set_or_missing_target_turns_strict_mode_off(target):
    log = _Log()
    vreqs = R2_VREQS + [_vreq("VREQ-009", target, "add audit columns everywhere")]
    spec, wide = ah._vibe_scope_requested_spec(vreqs, {"model": _model()})
    assert spec is None and wide and wide[0].startswith("VREQ-009")
    assert ah._vibe_scope_start_requested(vreqs, {"model": _model()}, log) is None
    assert ah.get_vibe_scope_runtime() is None
    assert any("vov-strict-requested-off FIRED v5.1.6" in m for m in log.warnings)


def test_a_move_lets_the_destination_domain_receive_the_product():
    spec, _ = ah._vibe_scope_requested_spec([_vreq("V1", "order.order_promotion", "move product order.order_promotion to domain customer")],
                                             {"model": _model()})
    assert "customer" in spec.domains and _keys(("order", "order_promotion")) <= spec.products


def test_a_scoped_run_keeps_its_own_fence_and_narrows_it_to_what_the_vibe_names():
    scoped = ah.build_vibe_scope_fence(ah.parse_vibe_scope("Some Domains", "order"), {"model": _model()}, "vibe modeling of version", _Log())
    ah.set_vibe_scope_runtime(scoped)
    try:
        assert ah._vibe_scope_start_requested(R2_VREQS, {"model": _model()}, _Log()) is scoped
        assert ah.get_vibe_scope_runtime() is scoped and scoped.spec.mode == "domains" and scoped.spec.named_only
        assert scoped.spec.entries == ("order",)
    finally:
        ah.set_vibe_scope_runtime(None)


def test_a_named_rename_admits_the_new_name_and_nothing_else():
    spec, _ = ah._vibe_scope_requested_spec([_vreq("V1", "order.order_promotion", "Rename the order_promotion table to order_discount")],
                                             {"model": _model()})
    assert _keys(("order", "order_promotion"), ("order", "order_discount")) <= spec.products


def test_the_requested_fence_freezes_every_product_the_vibe_does_not_name(fence):
    f, log = fence
    assert ah.get_vibe_scope_runtime() is f
    assert any("vov-strict-requested FIRED v5.1.6" in m for m in log.all())
    assert not f.is_frozen_product("order", "order_promotion")
    assert not f.is_frozen_product("product", "digital_asset")
    assert f.is_frozen_product("product", "campaign") and f.is_frozen_product("customer", "campaign")
    assert f.is_frozen_product("customer", "session")
    assert not f.is_frozen_product("customer", "gift_card")
    assert f.is_frozen_product("product", "product_campaign"), "an unrequested new product (a renamed frozen copy) is not admitted"


def test_classification_matches_the_freeze(fence):
    f, _ = fence
    assert f.classify_target("order", "order_promotion") == "in"
    assert f.classify_target("customer", "campaign") == "out"
    assert f.classify_target("customer", "gift_card") == "new"
    assert f.classify_target("customer") == "out", "a domain record changes only when the vibe names the domain itself"
    assert f.is_frozen_domain_record("customer")


def _flat(model):
    d, p, a, mv = ah.model_to_widgets_flat({"model": model}, quiet=True)
    return d, p, a, mv


def test_a_checkpoint_restores_unrequested_changes_and_keeps_requested_ones(fence):
    f, log = fence
    d, p, a, mv = _flat(_model())
    for row in a:
        if (row["domain"], row["product"], row["attribute"]) == ("customer", "session", "browser"):
            row["attribute"] = "session_browser"
    a[:] = [row for row in a if not (row["domain"] == "customer" and row["product"] == "journey" and row["attribute"] == "channel")]
    a.append({"domain": "order", "product": "order_promotion", "attribute": "gift_card_id", "type": "STRING",
              "foreign_key_to": "customer.gift_card.gift_card_id", "description": "gift card used"})
    session_before = [r["attribute"] for r in _flat(_model())[2] if r["product"] == "session"]
    journey_before = [r["attribute"] for r in _flat(_model())[2] if r["product"] == "journey"]
    restored = f.checkpoint("test", d, p, a, mv, log)
    assert restored >= 1
    assert [r["attribute"] for r in a if r["product"] == "session"] == session_before
    assert [r["attribute"] for r in a if r["product"] == "journey"] == journey_before
    assert any(r["attribute"] == "gift_card_id" for r in a if r["product"] == "order_promotion")


def test_an_autofix_pass_cannot_touch_any_base_product_but_shapes_new_ones(fence):
    f, log = fence
    d, p, a, mv = _flat(_model())
    p.append({"domain": "customer", "product": "gift_card", "primary_key": "gift_card_id", "subdomain": "loyalty_engagement"})
    a.append({"domain": "customer", "product": "gift_card", "attribute": "gift_card_code", "type": "STRING"})
    a.append({"domain": "product", "product": "digital_asset", "attribute": "season_code", "type": "STRING"})
    with ah._vibe_scope_contain(d, p, a, log, "autofix:pre_sa_naming_convention"):
        for row in a:
            if row["product"] == "digital_asset" and row["attribute"] == "season_code":
                row["attribute"] = "digital_asset_season_code"
            if row["product"] == "gift_card" and row["attribute"] == "gift_card_code":
                row["attribute"] = "code"
            if row["product"] == "campaign" and row["domain"] == "product":
                row["product"] = "product_campaign"
        for row in p:
            if row["product"] == "campaign" and row["domain"] == "product":
                row["product"] = "product_campaign"
    names = {(r["domain"], r["product"], r["attribute"]) for r in a}
    assert ("product", "digital_asset", "season_code") in names, "the user's own column name survives the naming pass"
    assert ("product", "digital_asset", "digital_asset_season_code") not in names
    assert ("customer", "gift_card", "code") in names, "a product created this run is still shaped by autofix passes"
    assert not any(r["product"] == "product_campaign" for r in a)


def test_a_user_operation_pass_may_still_change_a_named_product(fence):
    f, log = fence
    d, p, a, mv = _flat(_model())
    with ah._vibe_scope_contain(d, p, a, log, "queued_vibe_operations"):
        a.append({"domain": "product", "product": "digital_asset", "attribute": "season_code", "type": "STRING"})
    assert any(r["product"] == "digital_asset" and r["attribute"] == "season_code" for r in a)


def test_the_serialize_splice_restores_the_r2_campaign_rename(fence):
    f, log = fence
    model = _model()
    for dom in model["domains"]:
        if dom["name"] == "product":
            for prod in dom["products"]:
                if prod["name"] == "campaign":
                    prod["name"] = "product_campaign"
        if dom["name"] == "customer":
            dom["products"].append({"name": "gift_card", "primary_key": "gift_card_id", "subdomain": "loyalty_engagement",
                                    "description": "One row per issued gift card.",
                                    "attributes": [{"name": "gift_card_id", "type": "STRING", "description": "Gift card id."}]})
    f.splice_and_verify({"model": model}, log)
    names = {(d["name"], p["name"]) for d in model["domains"] for p in d["products"]}
    assert ("product", "campaign") in names and ("product", "product_campaign") not in names
    assert ("customer", "gift_card") in names


def _issue(message, **details):
    return {"category": "multi_fk_missing_label", "severity": "warning", "message": message, "details": details}


@pytest.mark.parametrize("issue,verdict", [
    (_issue("Table order.order_promotion has 2 FK columns pointing to product.digital_asset"), "out"),
    (_issue("Table customer.session has a generic column"), "out"),
    (_issue("customer.gift_card has no description"), "in"),
    (_issue("FK order.order_promotion.gift_card_id type differs from customer.gift_card.gift_card_id"), "in"),
    (_issue("division imbalance across the model"), "out"),
])
def test_static_analysis_findings_on_base_entities_go_to_next_vibes(fence, issue, verdict):
    f, _ = fence
    known = {"customer", "order", "product"}
    assert ah._vibe_scope_issue_verdict(f, issue, known) == verdict


def _pipeline_body():
    src = notebook_concat_source()
    start = src.index("def run_vov_pipeline(")
    return src[start:src.index("\ndef ", start + 10)]


def test_both_extraction_paths_start_the_requested_fence_before_triage():
    body = _pipeline_body()
    raw = body.index("_vibe_scope_start_requested(list(deduped) + list(_anchored_vreqs), scope_base_model or initial_model, logger, initial_model)")
    assert body.index("deduped = _vov_normalize_vreq_targets(deduped, model, logger)") < raw
    assert raw < body.index("_vibe_scope_triage_vreqs(_VIBE_SCOPE_RUNTIME, _vs_work, model, logger)")
    prio = body.index("_vibe_scope_start_requested(list(deduped) + list(_user_free) + list(_anchored_vreqs), scope_base_model or initial_model, logger, initial_model)")
    assert prio < body.index("_vibe_scope_triage_vreqs(_VIBE_SCOPE_RUNTIME, _user_free, model, logger)")
    assert prio < body.index("_vibe_scope_triage_priorities(_VIBE_SCOPE_RUNTIME, _parsed_priorities, model, logger)")


def test_the_widgets_runner_records_the_requested_spec_for_lineage():
    src = notebook_concat_source()
    start = src.index("def run_vov_2_against_widgets(")
    body = src[start:src.index("\ndef ", start + 10)]
    assert 'widgets_values["_vibe_scope_spec"] = _VIBE_SCOPE_RUNTIME.spec' in body
    assert "scope_base_model=_vibe_scope_raw_base(widgets_values)," in body
    assert body.index("result = run_vov_pipeline(") < body.index('widgets_values["_vibe_scope_spec"] = _VIBE_SCOPE_RUNTIME.spec')


def test_the_prompt_block_names_the_requested_entities(fence):
    f, _ = fence
    block = f.prompt_block()
    assert "changes only what the user's vibe names" in block
    assert "customer.gift_card" in block and "order.order_promotion" in block
    assert "Static-analysis findings on base entities go to next_vibes" in block


def _campaign_with_pk():
    model = _model()
    for dom in model["domains"]:
        for prod in dom["products"]:
            if dom["name"] == "customer" and prod["name"] == "campaign":
                prod["attributes"].insert(0, {"name": "campaign_id", "type": "STRING", "description": "Campaign id."})
    return model


def _renamed_campaign_model():
    model = _campaign_with_pk()
    for dom in model["domains"]:
        for prod in dom["products"]:
            if dom["name"] == "customer" and prod["name"] == "campaign":
                prod["name"] = "marketing_campaign"
            for attr in prod["attributes"]:
                if attr.get("foreign_key_to") == "customer.campaign.campaign_id":
                    attr["foreign_key_to"] = "customer.marketing_campaign.campaign_id"
    return {"model": model}


def test_an_llm_rename_lets_out_of_scope_fks_follow_while_its_batch_is_verified():
    scoped = ah.build_vibe_scope_fence(ah.parse_vibe_scope("Some Domains", "customer"), {"model": _campaign_with_pk()}, "vibe modeling of version", _Log())
    candidate = _renamed_campaign_model()
    blocked = scoped.check(candidate)
    assert any(v["kind"] == "frozen_attr_changed" and v["path"].startswith("product.") for v in blocked.violations), blocked.violations
    with scoped.expect_renames([("product", "customer.campaign", "customer.marketing_campaign")]) as n:
        assert n == 1
        allowed = scoped.check(candidate)
    assert not [v for v in allowed.violations if v["path"].startswith("product.")], allowed.violations
    assert any(p["kind"] == "P1" for p in allowed.permitted), allowed.permitted
    again = scoped.check(candidate)
    assert any(v["kind"] == "frozen_attr_changed" for v in again.violations), "the expectation ends with the batch"


def test_the_sandbox_gate_verifies_with_the_batch_rename_pairs():
    src = notebook_concat_source()
    start = src.index("def _apply_handler_with_retry(")
    body = src[start:src.index("\ndef ", start + 10)]
    assert "with (_vs_fence_inv.expect_renames(_pairs) if _vs_fence_inv is not None and _pairs else contextlib.nullcontext()):" in body
    assert body.index("expect_renames(_pairs)") < body.index("ok_inv, inv_diag = verify_invariants(new_model, invariants)")


def test_a_new_product_the_text_names_is_admitted_even_under_a_misread_target():
    vreq = _vreq("V1", "customer.campaign", "In the customer domain's loyalty_engagement area, add a new product store_credit with one row per credit")
    spec, _ = ah._vibe_scope_requested_spec([vreq], {"model": _model()})
    assert _keys(("customer", "store_credit"), ("customer", "campaign")) <= spec.products


def _engine_result():
    model = _model()
    for dom in model["domains"]:
        for prod in dom["products"]:
            if dom["name"] == "product" and prod["name"] == "digital_asset":
                prod["attributes"].append({"name": "season_code", "type": "STRING", "description": "Merchandising season."})
        if dom["name"] == "customer":
            dom["products"].append({"name": "gift_card", "primary_key": "gift_card_id", "subdomain": "loyalty_engagement",
                                    "description": "One row per gift card.",
                                    "attributes": [{"name": "gift_card_id", "type": "STRING"}, {"name": "gift_card_code", "type": "STRING"}]})
    return model


def test_after_the_engine_no_pass_may_change_a_named_base_product_until_the_selffixer(fence):
    f, log = fence
    d, p, a, mv = _flat(_engine_result())
    f.requested_snapshot(d, p, a, mv, log)
    assert any("vov-strict-engine-snapshot FIRED v5.1.6" in m for m in log.all())
    named_before = [r["attribute"] for r in a if r["product"] == "digital_asset"]
    for row in a:
        if row["product"] == "digital_asset" and row["attribute"] == "season_code":
            row["attribute"] = "digital_asset_season_code"
        if row["product"] == "gift_card" and row["attribute"] == "gift_card_code":
            row["attribute"] = "code"
    a[:] = [r for r in a if not (r["product"] == "digital_asset" and r["attribute"] == "campaign_id")]
    a.append({"domain": "product", "product": "digital_asset", "attribute": "taxonomy_id", "type": "STRING",
              "foreign_key_to": "product.collection.collection_id"})
    restored = f.restore_to_engine_snapshot(d, p, a, mv, "after_subdomains")
    assert restored >= 1
    assert [r["attribute"] for r in a if r["product"] == "digital_asset"] == named_before
    assert ("customer", "gift_card", "code") in {(r["domain"], r["product"], r["attribute"]) for r in a}


def test_the_checkpoints_before_the_selffixer_apply_the_engine_snapshot():
    assert ah._VOV_STRICT_ENGINE_SNAPSHOT_LABELS == ("logical_schema_review", "after_subdomains", "after_metric_views")
    src = notebook_concat_source()
    start = src.index("def _vibe_scope_checkpoint_widgets(")
    body = src[start:src.index("\nclass ", start)]
    assert "fence.restore_to_engine_snapshot(domains, products, attributes, records, label)" in body
    start = src.index("def run_vov_2_against_widgets(")
    body = src[start:src.index("\ndef ", start + 10)]
    assert body.index('_vibe_scope_checkpoint("vov_writeback"') < body.index("_VIBE_SCOPE_RUNTIME.requested_snapshot(new_domains, new_products, new_attrs, new_mvs, logger)")


def test_a_scoped_fence_takes_no_engine_snapshot():
    scoped = ah.build_vibe_scope_fence(ah.parse_vibe_scope("Some Domains", "order"), {"model": _model()}, "vibe modeling of version", _Log())
    d, p, a, mv = _flat(_model())
    assert scoped.requested_snapshot(d, p, a, mv) is None
    assert scoped.restore_to_engine_snapshot(d, p, a, mv, "after_subdomains") == 0


class _KeepPlan:
    def __init__(self):
        self.fqns = []

    def bind_views(self, spark, fqns, logger=None):
        self.fqns = list(fqns)
        return self

    def metric_view_action(self, name, rec=None, fqn=None):
        return "materialize"


def test_frozen_metric_views_from_another_catalog_are_recreated_in_the_deploy_catalog():
    sql = ("CREATE OR REPLACE VIEW `advertising_ecm`.`_metrics`.`campaign_flight`\nWITH METRICS\nLANGUAGE YAML\nAS $$\n"
           "  version: 1.1\n  source: \"`advertising_ecm`.`campaign`.`flight`\"\n$$")
    plan, log = _KeepPlan(), _Log()
    deploy, kept, frozen = ah._vibe_scope_metric_view_deploy_set(plan, [], [{"view_name": "campaign_flight", "sql": sql}], None, log, "vibe_lane2")
    assert len(deploy) == 1 and "`vibe_lane2`.`_metrics`.`campaign_flight`" in deploy[0] and "advertising_ecm" not in deploy[0]
    assert any("vibe_lane2" in f for f in plan.fqns if f)
    assert any("vibe-scope-mv-retarget FIRED v5.1.6" in m for m in log.infos)


class _PresentPlan(_KeepPlan):
    def metric_view_action(self, name, rec=None, fqn=None):
        return "keep" if fqn and "vibe_lane2" in str(fqn) else "materialize"


def test_a_frozen_view_statement_from_another_catalog_is_kept_when_installed_in_the_deploy_catalog():
    sql = ("CREATE OR REPLACE VIEW `advertising_ecm`.`_metrics`.`campaign_flight`\nWITH METRICS\nLANGUAGE YAML\nAS $$\n"
           "  version: 1.1\n  source: \"`advertising_ecm`.`campaign`.`flight`\"\n$$")
    plan, log = _PresentPlan(), _Log()
    statements = [sql]
    deploy, kept, frozen = ah._vibe_scope_metric_view_deploy_set(plan, statements, [{"view_name": "campaign_flight", "sql": sql}], None, log, "vibe_lane2")
    assert deploy == [], "live R19/R21/R23 re-created 29-31 frozen views every run: the statement kept the base catalog"
    assert kept == ["campaign_flight"] and frozen == ["campaign_flight"]
    assert statements == [sql]
    assert all("advertising_ecm" not in f for f in plan.fqns if f)


class _MissingCatalogSpark:
    def sql(self, statement):
        raise RuntimeError("[TABLE_OR_VIEW_NOT_FOUND] The table or view `advertising_ecm`.`information_schema`.`tables` cannot be found.")


def test_a_missing_catalog_counts_as_absent_not_as_installed():
    plan = ah.VibeScopeDeployPlan({}, {"model": {"domains": []}})
    plan._probe(_MissingCatalogSpark(), ["advertising_ecm._metrics.campaign_flight"], _Log())
    assert "advertising_ecm" not in plan.unknown_catalogs
    assert not plan._present("advertising_ecm._metrics.campaign_flight")


def test_frozen_products_keep_the_base_tag_set_when_the_engine_model_has_none():
    raw = {"model": _model()}
    for dom in raw["model"]["domains"]:
        dom["tag_set"] = [{"key": "dbx_domain", "value": dom["name"], "kind": "key_value", "source": "derived"}]
        for prod in dom["products"]:
            prod["tag_set"] = [{"key": "dbx_subdomain", "value": prod.get("subdomain", ""), "kind": "key_value", "source": "derived"}]
    engine = {"model": _model()}
    log = _Log()
    f = ah._vibe_scope_start_requested(R2_VREQS, raw, log, engine)
    try:
        written = {"model": _model()}
        f.splice_and_verify(written, log)
        frozen = [p for d in written["model"]["domains"] for p in d["products"] if d["name"] == "customer" and p["name"] == "session"][0]
        assert frozen.get("tag_set"), "the splice copies the frozen product from the raw base model.json, tag_set included"
    finally:
        ah.set_vibe_scope_runtime(None)


def test_the_raw_base_is_the_business_context_model_json():
    raw = {"model": _model()}
    assert ah._vibe_scope_raw_base({"business_context_raw": raw}) is raw
    assert ah._vibe_scope_raw_base({"business_context_raw": {"business_information": {}}}) is None
    assert ah._vibe_scope_raw_base({}) is None


def _removal_diff(*removed):
    return {"domains_removed": [], "domains_added": [], "products_removed": list(removed), "products_added": [], "n_products_modified": 0,
            "attributes_removed": [], "attributes_added": [], "fks_removed": 0, "fks_added": 0, "metric_views_delta": 0, "tags_added_estimate": 0}


@pytest.mark.parametrize("summary,ok", [
    ("Drops the order.return_line product from the order domain; returns are tracked at return_request level", True),
    ("Removes the order.return_line product from the order domain", True),
    ("drop product return_line", True),
    ("Drops obsolete products from the order domain", False),
    ("Adds a column to order.sales_order", False),
])
def test_a_drop_the_summary_names_is_in_scope_and_an_unnamed_one_is_not(summary, ok):
    in_scope, _diag = ah.diff_within_summary_scope(_removal_diff(("order", "return_line")), summary)
    assert in_scope is ok


def test_a_corrective_drop_of_an_in_scope_product_is_an_explicit_change():
    ah.vov_ledger_reset()
    scoped = ah.build_vibe_scope_fence(ah.parse_vibe_scope("Some Domains", "order"), {"model": _model()}, "vibe modeling of version", _Log())
    _d, p, _a, _mv = _flat(_model())
    before = ah._vibe_scope_product_keys(p)
    after_rows = [r for r in p if not (r["domain"] == "order" and r["product"] == "order_promotion") and not (r["domain"] == "customer" and r["product"] == "session")]
    log = _Log()
    noted = ah._vibe_scope_note_corrective_changes(scoped, before, after_rows, "corrective:drop:order_promotion", log)
    assert noted == ["drop order.order_promotion"]
    assert ah._vov_change_recorded("drop", (ah._vov285_san("order"), ah._vov285_san("order_promotion")))
    assert not ah._vov_change_recorded("drop", (ah._vov285_san("customer"), ah._vov285_san("session")))
    assert any("vibe-scope-corrective-ledger FIRED v5.1.8" in m for m in log.infos)


def test_the_corrective_loop_records_its_changes_with_the_fence():
    src = notebook_concat_source()
    i = src.index("_vs_handled = _dispatch_generic_action(_vs_at, _vs_sc, _vs_nm, _vs_ts, _vs_rs, _vs_action, _vs_ctx)")
    window = src[i - 400:i + 2600]
    assert "_vs_before_keys = _vibe_scope_product_keys(products_data) if _VIBE_SCOPE_RUNTIME is not None else None" in window
    assert "_vibe_scope_note_corrective_changes(_VIBE_SCOPE_RUNTIME, _vs_before_keys, products_data" in window


def _model_with_namesake_product():
    model = _model()
    customer = next(d for d in model["domains"] if d["name"] == "customer")
    attrs = [{"name": n, "column_name": n, "type": t, "description": n, "foreign_key_to": ""}
             for n, t in (("customer_id", "BIGINT"), ("loyalty_tier", "STRING"))]
    customer["products"].append({"name": "customer", "table_name": "customer", "primary_key": "customer_id",
                                 "subdomain": "loyalty_engagement", "description": "customer master", "attributes": attrs})
    customer["products"].append({"name": "tier_rule", "table_name": "tier_rule", "primary_key": "tier_rule_id",
                                 "subdomain": "loyalty_engagement", "description": "tier rules",
                                 "attributes": [{"name": "tier_rule_id", "column_name": "tier_rule_id", "type": "BIGINT",
                                                 "description": "id", "foreign_key_to": ""}]})
    return model


@pytest.mark.parametrize("text,refs", [
    ("customer.customer.loyalty_tier", [("customer", "customer", "loyalty_tier")]),
    ("vibe_scope_v514_live.order.order_promotion", [("order", "order_promotion", None)]),
    ("customer.campaign, order.order_promotion.campaign_id", [("customer", "campaign", None), ("order", "order_promotion", "campaign_id")]),
    ("see v5.1.6, e.g. the order domain.", []),
])
def test_a_dotted_chain_yields_one_domain_product_reference(text, refs):
    assert ah._vibe_scope_dotted_refs(text, {"customer", "order", "product"}) == refs


def test_a_requirement_on_a_product_named_like_its_domain_is_not_split():
    model = _model_with_namesake_product()
    vreqs = [_vreq("VREQ-0001", "customer.customer.loyalty_tier", "change loyalty_tier on the customer table to an INT code")]
    log = _Log()
    fence = ah._vibe_scope_start_requested(vreqs, {"model": model}, log)
    try:
        kept, rejected, outcomes = ah._vibe_scope_triage_vreqs(fence, vreqs, {"model": model}, log)
        assert [(v.vreq_id, v.target) for v in kept] == [("VREQ-0001", "customer.customer.loyalty_tier")]
        assert rejected == [] and outcomes == []
    finally:
        ah.set_vibe_scope_runtime(None)


def test_a_finding_on_a_new_attribute_is_not_read_as_a_base_product():
    model = _model_with_namesake_product()
    vreqs = [_vreq("VREQ-0001", "customer.customer.tier_rule", "add a column tier_rule to the customer table")]
    fence = ah._vibe_scope_start_requested(vreqs, {"model": model}, _Log())
    try:
        issue = _issue("customer.customer.tier_rule has no description")
        assert ah._vibe_scope_issue_verdict(fence, issue, {"customer", "order", "product"}) == "in"
        base = _issue("customer.customer.loyalty_tier has no description")
        assert ah._vibe_scope_issue_verdict(fence, base, {"customer", "order", "product"}) == "out"
    finally:
        ah.set_vibe_scope_runtime(None)


@pytest.mark.parametrize("target,text,qualified", [
    ("session.browser", "", "customer.session.browser"),
    ("customer.session", "", "customer.session"),
    ("campaign.campaign_id", "", "campaign.campaign_id"),
    ("loyalty_engagement.campaign", "", "loyalty_engagement.campaign"),
    ("session.session_note", "create a new domain session with a product session_note", "session.session_note"),
    ("session", "", "customer.session"),
])
def test_a_target_without_its_domain_is_qualified_from_its_unique_product(target, text, qualified):
    assert ah._vov_qualify_target(target, {"model": _model()}, text=text) == qualified


def test_a_one_part_target_that_names_a_domain_stays_a_domain_for_the_spec_only():
    model = {"model": _model_with_namesake_product()}
    assert ah._vov_qualify_target("customer", model) == "customer.customer"
    assert ah._vov_qualify_target("customer", model, prefer_domain=True) == "customer"
    spec, _ = ah._vibe_scope_requested_spec([_vreq("V1", "customer", "rewrite the customer domain description")], model)
    assert spec.whole_domains == {"customer"}


def test_a_product_attribute_target_admits_the_product_and_no_phantom_domain():
    vreqs = [_vreq("VREQ-0001", "session.browser", "rewrite the description of browser so it lists the allowed values"),
             _vreq("VREQ-0002", "customer.session.browser", "rewrite the description of browser so it lists the allowed values")]
    spec, wide = ah._vibe_scope_requested_spec(vreqs, {"model": _model()})
    assert wide == []
    assert spec.products == _keys(("customer", "session"))
    assert spec.domains == {"customer"} and spec.whole_domains == frozenset() and spec.new_names == frozenset()
    log = _Log()
    fence = ah._vibe_scope_start_requested(vreqs, {"model": _model()}, log)
    try:
        kept, rejected, outcomes = ah._vibe_scope_triage_vreqs(fence, vreqs, {"model": _model()}, log)
        assert [v.vreq_id for v in kept] == ["VREQ-0001", "VREQ-0002"] and rejected == [] and outcomes == []
        assert fence.is_frozen_product("session", "browser"), "a product.attribute target never admits a new domain named after the product"
        assert not fence.is_frozen_product("customer", "session")
    finally:
        ah.set_vibe_scope_runtime(None)
