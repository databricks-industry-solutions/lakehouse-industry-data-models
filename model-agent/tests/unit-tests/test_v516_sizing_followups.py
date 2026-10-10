"""v5.1.6 B3 sizing and stub-creation follow-ups.

Evidence: live run 161935925891676 (agent 5.1.4, 'new base model', business 'vs514 retail',
business_domains 'customer, order, product, inventory', EMPTY model_vibes, MVM) and the cancelled
run 99248567832927 (vibe 'Keep the model small: about 4 products per domain.'). Every behavioral
test drives production code through agent_helpers and fails on 2800131 (CLAUDE.md 8.10).
"""
import copy
import json
import logging
import sys
import textwrap
from pathlib import Path

import pytest

sys.path.insert(0, str(Path(__file__).resolve().parent))
import conftest  # noqa: F401,E402
import agent_helpers as ah  # noqa: E402
from notebook_source_util import notebook_concat_source  # noqa: E402

LIVE_DOMAINS = ["customer", "order", "product", "inventory"]
LIVE_VIBE = "Keep the model small: about 4 products per domain."
SOURCE = notebook_concat_source()
ALL_GATES = ("trust_in_production", "support_in_production",
             "recommend_to_industry_peers", "propose_for_global_standard")


class _Records(logging.Handler):
    def __init__(self):
        super().__init__()
        self.lines = []

    def emit(self, record):
        self.lines.append(record.getMessage())


def _logger(name):
    log = logging.getLogger(name)
    log.handlers = []
    log.propagate = False
    log.setLevel(logging.INFO)
    rec = _Records()
    log.addHandler(rec)
    return log, rec


def _block(start_marker, end_marker):
    start = SOURCE.index(start_marker)
    start = SOURCE.rindex("\n", 0, start) + 1
    end = SOURCE.index(end_marker, start) + len(end_marker)
    return textwrap.dedent(SOURCE[start:end])


@pytest.fixture(autouse=True)
def _isolate_runtime():
    bounds = dict(ah._USER_SIZING_BOUNDS_RUNTIME)
    pinned = set(ah._USER_PINNED_DOMAINS_RUNTIME)
    fence = ah.get_vibe_scope_runtime()
    ah._USER_SIZING_BOUNDS_RUNTIME.clear()
    yield
    ah._USER_SIZING_BOUNDS_RUNTIME.clear()
    ah._USER_SIZING_BOUNDS_RUNTIME.update(bounds)
    ah._USER_PINNED_DOMAINS_RUNTIME.clear()
    ah._USER_PINNED_DOMAINS_RUNTIME.update(pinned)
    ah.set_vibe_scope_runtime(fence)


def _widget_sizing_directives(domains=LIVE_DOMAINS):
    block = _block('    if _user_specified_domains and _vibe_scope_op != "vibe modeling of version":',
                   '        widgets_values["sizing_directives"] = _sd_existing\n')
    ns = {"_user_specified_domains": list(domains), "_vibe_scope_op": "new base model", "widgets_values": {}}
    exec(compile(block, "<widget-handler>", "exec"), ns)
    return ns["widgets_values"]["sizing_directives"]


_MVM_LIVE = {"min_business_domains": 9, "max_business_domains": 12, "min_data_products_per_domain": 8,
             "max_data_products_per_domain": 14, "min_attributes_per_product": 10, "max_attributes_per_product": 42,
             "min_business_subdomains": 2, "max_business_subdomains": 3, "min_products_per_subdomain": 2,
             "product_attributes_dedupe_threshold": 45, "min_honesty_score_threshold": 55}
_LIVE_NOTES = ("ECM validation: avg domains (13+17)/2 = 15 ... The 12 named data domains map cleanly to business "
               "functions ... MVM validation: avg domains (9+12)/2 = 10.5")


def _model_params(vibe, mvm_llm, sizing_directives=None, domains=LIVE_DOMAINS, user_sizing_override=False,
                  notes=_LIVE_NOTES):
    log, rec = _logger("test_v516_params")
    params = {"industry_complexity_tier": "tier_2", "tier_justification": "t", "sizing_notes": notes,
              "user_sizing_override": user_sizing_override, "mvm_model": dict(mvm_llm), "ecm_model": dict(mvm_llm),
              "estimated_total_tables_mvm": 138, "estimated_total_tables_ecm": 367}
    config = {"MODEL_SCOPE": "mvm", "PROMPT_KEYS": {},
              "PROMPT_VARIABLES": {"business_config": {"business": "vs514 retail", "description": "retailer"}}}
    widgets = {"vibe_modelling_instructions": vibe, "_user_specified_domains": list(domains or [])}
    if sizing_directives is not None:
        widgets["sizing_directives"] = sizing_directives
    seen = {}
    validator = type("_Validator", (), {"validate_model_generation_parameters": lambda *_a, **_k: (True, [])})()
    original = ah.smart_worker_loop

    def _fake_loop(**kwargs):
        seen["prompt_vars"] = dict(kwargs.get("prompt_vars") or {})
        return True, params, []

    ah.smart_worker_loop = _fake_loop
    try:
        ah._determine_model_parameters(None, {"data_domains": "Customer, Order, Product, Inventory, Fulfillment, "
                                                              "Store Ops, Pricing, Payments, Finance, Merchandising, "
                                                              "Marketing, Loyalty"},
                                       config, widgets, log, validator, None)
    finally:
        ah.smart_worker_loop = original
    return config["PROMPT_VARIABLES"], rec.lines, seen.get("prompt_vars", {})


# ---------------------------------------------------------------- task 1: widget pins are not sizing

def test_widget_pins_are_recorded_as_pins_not_sizing():
    sd = _widget_sizing_directives()
    assert sd["max_domains"] == 4 and sd["min_domains"] == 4 and sd["user_domains_exhaustive"] is True
    view = ah._user_sizing_directives(sd)
    assert "max_domains" not in view and "min_domains" not in view, view
    assert ah._v488_sizing_override_from_directives(view) == (False, [])


def test_empty_vibe_with_the_domain_widget_keeps_the_tier_guardrails():
    llm = dict(_MVM_LIVE, min_attributes_per_product=4, max_attributes_per_product=20,
               min_data_products_per_domain=2, max_data_products_per_domain=5)
    pv, lines, _ = _model_params("", llm, sizing_directives=_widget_sizing_directives())
    assert not any("USER SIZING OVERRIDE ACTIVE" in l for l in lines), lines
    assert pv["max_attributes_per_product"] == 35 and pv["min_attributes_per_product"] == 8, pv
    assert pv["max_data_products_per_domain"] == 10 and pv["min_data_products_per_domain"] == 5, pv
    assert (pv["min_business_domains"], pv["max_business_domains"]) == (4, 4)
    assert any("sizing-override-explicit-only FIRED v5.1.6" in l and "business_domains widget" in l for l in lines), lines


def test_an_explicit_vibe_count_still_activates_the_override_for_its_own_axis():
    llm = dict(_MVM_LIVE, min_data_products_per_domain=4, max_data_products_per_domain=4,
               max_attributes_per_product=20)
    pv, lines, _ = _model_params(LIVE_VIBE, llm, sizing_directives=_widget_sizing_directives(),
                                 user_sizing_override=True)
    assert any("USER SIZING OVERRIDE ACTIVE" in l for l in lines), lines
    assert (pv["min_data_products_per_domain"], pv["max_data_products_per_domain"]) == (4, 4), pv
    assert pv["max_attributes_per_product"] == 35, pv


class _StubParseLLM:
    def __init__(self, vibe, sizing):
        self.vibe = vibe
        self.sizing = sizing

    def _call_ai_query(self, prompt_name=None, **_kw):
        if prompt_name == "VIBE_PARSE_PROMPT":
            return json.dumps({
                "requirements": [{"original_text": self.vibe, "intent": "sizing", "scope": "model",
                                  "scope_targets": ["*"], "mode": "holistic", "priority": "critical",
                                  "constraint_type": "hard", "verification_strategy": "llm_verify"}],
                "sizing_directives": self.sizing,
                "model_conventions": {k: "" for k in ("tag_prefix", "tag_suffix", "schema_prefix", "schema_suffix",
                                                       "data_asset_naming_convention", "cataloging_style")},
            })
        if prompt_name == "SIZING_DIRECTIVE_RECOVERY_PROMPT":
            return json.dumps({"domains_exact": None, "products_exact": None, "products_per_domain_exact": 4,
                               "metric_views_exact": None, "metric_view_names": []})
        return "{}"


_NULL_SD = {"max_domains": None, "min_domains": None, "max_total_products": None, "min_total_products": None,
            "max_products_per_domain": None, "min_products_per_domain": None, "single_domain_mode": False,
            "max_metric_views": None, "min_metric_views": None, "explicit_metric_views": [],
            "explicit_count_statements": []}


def test_the_llm_vibe_parse_keeps_the_widget_roster_pins():
    log, rec = _logger("test_v516_parse_pins")
    widgets = {"logger": log, "config": {}, "vibe_modelling_instructions": LIVE_VIBE, "operation": "new base model",
               "sizing_directives": _widget_sizing_directives(),
               "ai_agent": _StubParseLLM(LIVE_VIBE, dict(_NULL_SD, max_products_per_domain=4,
                                                         min_products_per_domain=4))}
    ah.VibeOrchestrator(widgets).parse()
    sd = widgets["sizing_directives"]
    assert (sd.get("max_domains"), sd.get("min_domains")) == (4, 4), sd
    assert sd.get("user_domains_exhaustive") is True, sd
    assert (sd.get("max_products_per_domain"), sd.get("min_products_per_domain")) == (4, 4), sd
    assert sd.get("max_total_products") is None and sd.get("min_total_products") is None, sd
    assert not any("disagree" in l and "max_domains" in l for l in rec.lines), rec.lines
    keys = ah._v488_sizing_override_from_directives(ah._user_sizing_directives(sd))[1]
    assert "max_domains=4" not in keys and "max_products_per_domain=4" in keys, keys


# ---------------------------------------------------------------- task 2: tiny only from an explicit size

def test_the_domain_widget_alone_does_not_make_the_scope_tiny():
    log, rec = _logger("test_v516_tier")
    active, report_only = ah._tier_aware_architect_gate_keys(_widget_sizing_directives(), logger=log,
                                                             alias="domain-arch-gate-tier-aware")
    assert set(active) == set(ALL_GATES) and report_only == (), (active, report_only)
    assert any("tiny-gate-explicit-report-only FIRED v5.1.6" in l for l in rec.lines), rec.lines
    ah.set_user_sizing_bounds_runtime({"max_products_per_domain": 4, "min_products_per_domain": 4}, domain_count=4)
    active, report_only = ah._tier_aware_architect_gate_keys({"max_products_per_domain": 4})
    assert active == () and set(report_only) == set(ALL_GATES)


def test_a_vibe_domain_count_alone_is_not_tiny_either():
    active, report_only = ah._tier_aware_architect_gate_keys({"max_domains": 3, "min_domains": 3})
    assert set(active) == set(ALL_GATES) and report_only == ()


def _domain_review(gates, sizing_directives):
    log, rec = _logger("test_v516_domain_review")
    queue = []
    stats = {k: 0 for k in ("products_added", "products_renamed", "products_removed", "products_merged",
                            "products_split", "descriptions_updated", "in_domain_links_queued",
                            "next_vibes_queued", "domain_gate_failures")}
    response = {"production_readiness_gates": {
        g: {"answer": gates.get(g, "yes"), "why": f"{g} why", "blockers": [f"{g} blocker"],
            "required_actions": [f"add more products for {g}"]} for g in ALL_GATES}}
    passed, record = ah._apply_single_domain_review_to_model(
        response_data=response, domain_name="customer", products_data=[], must_have_set=set(),
        next_vibes_queue=queue, in_domain_link_queue=[], applied_log=[], stats=stats, logger=log,
        sizing_directives=sizing_directives)
    return passed, record, queue, stats, rec.lines


def test_tiny_domain_review_reports_no_answers_instead_of_evaluating_nothing():
    passed, record, queue, stats, lines = _domain_review({g: "no" for g in ALL_GATES}, {"max_total_products": 16})
    assert passed and stats["domain_gate_failures"] == 0 and queue == [], (passed, stats, queue)
    assert record["report_only_no"] == list(ALL_GATES), record
    assert any("tiny-gate-explicit-report-only FIRED v5.1.6" in l and "trust_in_production" in l for l in lines), lines


def test_widget_only_domain_review_keeps_gates_blocking():
    passed, record, queue, stats, _ = _domain_review({g: "no" for g in ALL_GATES}, _widget_sizing_directives())
    assert not passed and stats["domain_gate_failures"] == 4, (passed, stats)
    assert any("trust_in_production" in item["gate"] for item in queue), queue


def _global_gate_report(gates_raw, sizing_directives):
    log, rec = _logger("test_v516_global_gates")
    block = _block('    _gate_sd = (widgets_values.get("sizing_directives") or {}) if widgets_values else {}',
                   '# \u2500\u2500 10c. Essential Links')
    block = block[:block.rindex("\n")]
    ns = dict(vars(ah))
    widgets = {"sizing_directives": sizing_directives, "_architect_gate_failures": []}
    ns.update({"widgets_values": widgets, "logger": log, "results": {}, "_gates_raw": gates_raw})
    exec(compile(block, "<global-gates>", "exec"), ns)
    return widgets, rec.lines


def test_tiny_global_report_lists_answers_and_is_not_a_hard_fail():
    gates = {g: {"answer": "No", "why": f"{g} why"} for g in ALL_GATES}
    widgets, lines = _global_gate_report(gates, {"max_total_products": 16})
    assert not any("did not return production_readiness_gates" in l for l in lines), lines
    assert not any("ALL EVALUATED GATES PASSED (0/4)" in l for l in lines), lines
    assert any("trust_in_production: NO (report-only, tiny scope)" in l for l in lines), lines
    assert widgets["_architect_gate_failures"] == [], widgets


# ---------------------------------------------------------------- tasks 3 + 4: stub creation

def _attr(domain, product, name, fk="", pk=False):
    a = {"business": "vs514 retail", "version": "1", "model_scope": "mvm", "domain": domain, "product": product,
         "attribute": name, "column_name": name, "type": "BIGINT" if name.endswith("_id") else "STRING",
         "description": f"{name} column", "tags": "primary_key" if pk else "", "foreign_key_to": fk}
    if pk:
        a["is_primary_key"] = True
    return a


def _retail_fixture(products_by_domain, extra_columns):
    domains = [{"domain": d, "description": f"{d} domain", "division": "business"} for d in products_by_domain]
    products, attrs = [], []
    for d, names in products_by_domain.items():
        for p in names:
            products.append({"domain": d, "product": p, "primary_key": f"{p}_id", "type": "entity",
                             "description": f"{p} table"})
            attrs.append(_attr(d, p, f"{p}_id", pk=True))
            attrs.append(_attr(d, p, f"{p}_name"))
    for d, p, col in extra_columns:
        attrs.append(_attr(d, p, col))
    return domains, products, attrs


def _fmfl_config(cap=None, exhaustive=False, must_have=""):
    pv = {"business_config": {"business": "vs514 retail", "version": "1", "description": "retailer",
                              "must_have_data_products": must_have}}
    if cap is not None:
        pv["max_data_products_per_domain"] = cap
    return {"MODEL_CONVENTIONS": {"primary_key_suffix": "_id", "data_asset_naming_convention": "snake_case"},
            "PROMPT_VARIABLES": pv, "MODEL_SCOPE": "mvm", "MAX_CONCURRENT_BATCHES": 1,
            "USER_DOMAINS_EXHAUSTIVE": exhaustive}


def _run_fmfl(domains, products, attrs, config, decisions_by_domain):
    log, rec = _logger("test_v516_fmfl")
    original = ah.smart_worker_loop

    def _fake_loop(**kwargs):
        dom = str(kwargs.get("step_name", "")).replace("find_missing_fk_links_", "")
        return True, {"decisions": [dict(d) for d in decisions_by_domain.get(dom, [])], "summary": {}}, []

    ah.smart_worker_loop = _fake_loop
    try:
        pk_map = ah.build_pk_map(products, config, include_lowercase=True)
        totals = ah._run_find_missing_fk_links(domains, products, attrs, pk_map, log, object(), config)
    finally:
        ah.smart_worker_loop = original
    return totals, rec.lines


def _create(table, column, target, domain_hint):
    return {"table": table, "column": column, "decision": "CREATE", "create_table_name": target,
            "create_in_domain": domain_hint, "confidence": "HIGH", "reasoning": "core concept"}


_LIVE_PRODUCTS = {
    "customer": ["profile", "value", "interaction", "nps_response"],
    "order": ["sales_order", "order_promotion", "shipment", "line"],
    "product": ["sku", "digital_asset", "collection", "product_promotion"],
    "inventory": ["location", "asn", "grn", "stock_position"],
}
_LIVE_COLUMNS = [
    ("customer", "value", "acquisition_campaign_id"), ("customer", "interaction", "campaign_id"),
    ("customer", "nps_response", "campaign_id"), ("customer", "interaction", "session_id"),
    ("customer", "interaction", "agent_id"), ("order", "order_promotion", "campaign_id"),
    ("order", "shipment", "carrier_id"), ("product", "digital_asset", "campaign_id"),
    ("product", "collection", "campaign_id"), ("inventory", "asn", "vendor_id"),
    ("inventory", "grn", "vendor_id"), ("inventory", "asn", "po_id"),
]
_LIVE_DECISIONS = {
    "customer": [_create("value", "acquisition_campaign_id", "campaign", "customer"),
                 _create("interaction", "campaign_id", "campaign", "customer"),
                 _create("nps_response", "campaign_id", "campaign", "customer"),
                 _create("interaction", "session_id", "session", "customer"),
                 _create("interaction", "agent_id", "agent", "customer")],
    "order": [_create("order_promotion", "campaign_id", "campaign", "product"),
              _create("shipment", "carrier_id", "carrier", "order")],
    "product": [_create("digital_asset", "campaign_id", "campaign", "product"),
                _create("collection", "campaign_id", "campaign", "product")],
    "inventory": [_create("asn", "vendor_id", "vendor", "product"), _create("grn", "vendor_id", "vendor", "product"),
                  _create("asn", "po_id", "purchase_order", "inventory")],
}


def _count_by_domain(products):
    out = {}
    for p in products:
        out[p["domain"]] = out.get(p["domain"], 0) + 1
    return out


def test_finalize_stubs_respect_the_planned_per_domain_max():
    domains, products, attrs = _retail_fixture(_LIVE_PRODUCTS, _LIVE_COLUMNS)
    totals, lines = _run_fmfl(domains, products, attrs, _fmfl_config(cap=4), _LIVE_DECISIONS)
    assert _count_by_domain(products) == {d: 4 for d in LIVE_DOMAINS}, _count_by_domain(products)
    assert totals["created"] == 0, totals
    names = {(a["domain"], a["product"], a["attribute"]) for a in attrs}
    assert ("customer", "interaction", "campaign_code") in names and ("inventory", "asn", "vendor_code") in names
    assert not any(a["attribute"].endswith("_id") and not a.get("foreign_key_to") and not a.get("is_primary_key")
                   for a in attrs if a["product"] in ("interaction", "asn", "shipment")), attrs
    assert sum("stub-cap-planned-max FIRED v5.1.6" in l for l in lines) == 6, lines


def test_stubs_still_fill_the_room_under_the_planned_max_most_referenced_first():
    products_by_domain = dict(_LIVE_PRODUCTS, inventory=["location", "asn", "grn"])
    domains, products, attrs = _retail_fixture(products_by_domain, _LIVE_COLUMNS)
    _run_fmfl(domains, products, attrs, _fmfl_config(cap=4), _LIVE_DECISIONS)
    counts = _count_by_domain(products)
    assert counts == {"customer": 4, "order": 4, "product": 4, "inventory": 4}, counts
    assert any(p["domain"] == "inventory" and p["product"] == "purchase_order" for p in products), products


def test_one_entity_is_created_once_in_the_domain_with_most_referencing_fks():
    domains, products, attrs = _retail_fixture(_LIVE_PRODUCTS, _LIVE_COLUMNS)
    _run_fmfl(domains, products, attrs, _fmfl_config(cap=20), _LIVE_DECISIONS)
    campaigns = [p for p in products if p["product"] == "campaign"]
    assert [p["domain"] for p in campaigns] == ["customer"], campaigns
    refs = sorted((a["domain"], a["product"]) for a in attrs
                  if a.get("foreign_key_to") == "customer.campaign.campaign_id")
    assert refs == [("customer", "interaction"), ("customer", "nps_response"), ("customer", "value"),
                    ("order", "order_promotion"), ("product", "collection"), ("product", "digital_asset")], refs
    pk = [a for a in attrs if a["domain"] == "customer" and a["product"] == "campaign" and a["attribute"] == "campaign_id"]
    assert len(pk) == 1 and not pk[0].get("foreign_key_to"), pk


def test_an_entity_requested_in_two_domains_with_equal_references_goes_to_the_alphabetical_owner():
    cols = [("order", "sales_order", "voucher_id"), ("product", "sku", "voucher_id")]
    domains, products, attrs = _retail_fixture(_LIVE_PRODUCTS, cols)
    decisions = {"product": [_create("sku", "voucher_id", "voucher", "product")],
                 "order": [_create("sales_order", "voucher_id", "voucher", "order")]}
    _, lines = _run_fmfl(domains, products, attrs, _fmfl_config(cap=20), decisions)
    assert [p["domain"] for p in products if p["product"] == "voucher"] == ["order"], products
    assert any("stub-single-owner FIRED v5.1.6" in l and "voucher" in l for l in lines), lines


def test_a_stub_request_for_an_existing_entity_links_instead_of_duplicating():
    products_by_domain = dict(_LIVE_PRODUCTS, customer=["profile", "value", "interaction", "campaign"])
    domains, products, attrs = _retail_fixture(products_by_domain, [("product", "collection", "campaign_id")])
    decisions = {"product": [_create("collection", "campaign_id", "campaign", "product")]}
    _run_fmfl(domains, products, attrs, _fmfl_config(cap=20), decisions)
    assert [p["domain"] for p in products if p["product"] == "campaign"] == ["customer"], products
    col = next(a for a in attrs if a["product"] == "collection" and a["attribute"] == "campaign_id")
    assert col["foreign_key_to"] == "customer.campaign.campaign_id", col


def test_a_closed_roster_never_gets_a_new_domain_from_a_stub():
    domains, products, attrs = _retail_fixture(_LIVE_PRODUCTS, [("customer", "interaction", "journey_id"),
                                                                ("customer", "value", "journey_id")])
    decisions = {"customer": [_create("interaction", "journey_id", "journey", "marketing"),
                              _create("value", "journey_id", "journey", "marketing")]}
    _run_fmfl(domains, products, attrs, _fmfl_config(cap=20, exhaustive=True), decisions)
    assert sorted(d["domain"] for d in domains) == sorted(LIVE_DOMAINS), domains
    assert [p["domain"] for p in products if p["product"] == "journey"] == ["customer"], products


class _Fence:
    def __init__(self, in_scope):
        self.in_scope = set(in_scope)

    def is_frozen_pass_row(self, domain, product):
        return str(domain).lower() not in self.in_scope


def test_the_vibe_scope_fence_blocks_stubs_in_frozen_domains():
    domains, products, attrs = _retail_fixture(_LIVE_PRODUCTS, [("inventory", "asn", "po_id")])
    ah.set_vibe_scope_runtime(_Fence(["customer", "order", "product"]))
    _run_fmfl(domains, products, attrs, _fmfl_config(cap=20),
              {"inventory": [_create("asn", "po_id", "purchase_order", "inventory")]})
    assert not any(p["product"] == "purchase_order" for p in products), products


def test_a_must_have_product_is_created_even_at_the_planned_max():
    domains, products, attrs = _retail_fixture(_LIVE_PRODUCTS, [("customer", "interaction", "loyalty_program_id"),
                                                                ("customer", "interaction", "session_id")])
    decisions = {"customer": [_create("interaction", "loyalty_program_id", "loyalty_program", "customer"),
                              _create("interaction", "session_id", "session", "customer")]}
    config = _fmfl_config(cap=4, must_have="loyalty_program")
    _run_fmfl(domains, products, attrs, config, decisions)
    created = sorted(p["product"] for p in products if p["domain"] == "customer")
    assert "loyalty_program" in created and "session" not in created, created


def test_the_post_create_sweep_never_links_a_tables_own_primary_key():
    products_by_domain = dict(_LIVE_PRODUCTS, product=["sku", "digital_asset", "collection", "promotion"])
    domains, products, attrs = _retail_fixture(products_by_domain, [("order", "shipment", "carrier_id")])
    products.append({"domain": "customer", "product": "promotion", "primary_key": "promotion_id", "type": "entity",
                     "description": "legacy copy"})
    attrs.append(_attr("customer", "promotion", "promotion_id"))
    for p in products:
        if p["product"] == "promotion":
            p["_dynamically_created"] = True
    decisions = {"order": [_create("shipment", "carrier_id", "carrier", "order")]}
    totals, lines = _run_fmfl(domains, products, attrs, _fmfl_config(cap=20), decisions)
    assert totals["created"] == 1, totals
    own = next(a for a in attrs if a["domain"] == "customer" and a["product"] == "promotion")
    assert not own.get("foreign_key_to"), own
    assert any("create-sweep-own-pk-skip FIRED v5.1.6" in l and "customer.promotion.promotion_id" in l for l in lines), lines


def test_create_missing_parents_respects_the_cap_and_alphabetical_owner():
    cols = [("order", "sales_order", "warranty_plan_id"), ("customer", "profile", "warranty_plan_id"),
            ("order", "line", "gift_card_id"), ("product", "sku", "gift_card_id")]
    products_by_domain = {"order": ["sales_order", "line"], "customer": ["profile"],
                          "product": ["sku", "digital_asset", "collection", "product_promotion"]}
    domains, products, attrs = _retail_fixture(products_by_domain, cols)
    log, rec = _logger("test_v516_create_parent")
    created = ah._create_missing_parent_tables_for_unlinked_fks(domains, products, attrs, _fmfl_config(cap=4), log)
    owners = {p["product"]: p["domain"] for p in products if p["product"] in ("warranty_plan", "gift_card")}
    assert owners.get("warranty_plan") == "customer", owners
    assert owners.get("gift_card") == "order", owners
    assert created == 2, created


def test_create_missing_parents_demotes_instead_of_growing_a_full_domain():
    cols = [("product", "sku", "fixture_id"), ("product", "digital_asset", "fixture_id")]
    domains, products, attrs = _retail_fixture({"product": _LIVE_PRODUCTS["product"]}, cols)
    log, rec = _logger("test_v516_create_parent_cap")
    created = ah._create_missing_parent_tables_for_unlinked_fks(domains, products, attrs, _fmfl_config(cap=4), log)
    assert created == 0 and len(products) == 4, (created, products)
    assert sorted(a["attribute"] for a in attrs if a["attribute"].startswith("fixture")) == ["fixture_code", "fixture_code"]
    assert any("stub-cap-planned-max FIRED v5.1.6" in l for l in rec.lines), rec.lines


def test_the_admission_rule_is_shared_by_every_stub_site():
    for fn in ("_run_find_missing_fk_links", "_create_missing_parent_tables_for_unlinked_fks",
               "run_normalization_integrity_check_parallel"):
        start = SOURCE.index(f"\ndef {fn}(")
        end = SOURCE.index("\ndef ", start + 10)
        assert "_stub_parent_admission(" in SOURCE[start:end], fn


# ---------------------------------------------------------------- task 5: sizing notes match the pinned domains

def test_the_sizing_prompt_is_told_the_widget_domain_roster():
    _, _, prompt_vars = _model_params("", _MVM_LIVE, sizing_directives=_widget_sizing_directives())
    assert "EXACTLY 4 domain(s)" in prompt_vars.get("data_domains", ""), prompt_vars.get("data_domains")
    assert all(d in prompt_vars["data_domains"] for d in LIVE_DOMAINS)
    assert "EXACTLY 4 domain(s)" in prompt_vars.get("user_sizing_directives", "")


def test_sizing_notes_for_a_different_domain_count_are_labelled_superseded():
    _, lines, _ = _model_params("", _MVM_LIVE, sizing_directives=_widget_sizing_directives())
    notes_at = next(i for i, l in enumerate(lines) if l.startswith("[MODEL-PARAMS] Sizing notes:"))
    label = [l for l in lines[:notes_at] if "model-params-pinned-domains FIRED v5.1.6" in l and "9-12 domains" in l]
    assert label, lines


# ---------------------------------------------------------------- task 6: count-shaped requirements are counted

def _orchestrator():
    log, rec = _logger("test_v516_verifier")
    orch = ah.VibeOrchestrator({"logger": log, "config": {"MODEL_CONVENTIONS": {"primary_key_suffix": "_id"}},
                                "vibe_modelling_instructions": LIVE_VIBE, "operation": "new base model"})
    orch._llm_verify_enabled = False
    orch.ai_agent = None
    return orch, rec


def _req(text, scope="model", targets=("*",), strategy="deterministic", rid="VREQ-001"):
    return ah.VibeRequirement(id=rid, original_text=text, intent="sizing", scope=scope,
                              scope_targets=list(targets), verification_strategy=strategy)


def _live_model_lists(per_domain):
    domains = [{"domain": d} for d in per_domain]
    products = [{"domain": d, "product": f"{d}_t{i}"} for d, n in per_domain.items() for i in range(n)]
    attrs = [{"domain": p["domain"], "product": p["product"], "attribute": f"c{j}"} for p in products for j in range(30)]
    return domains, products, attrs


def test_about_four_per_domain_is_counted_against_the_live_model():
    orch, rec = _orchestrator()
    d, p, a = _live_model_lists({"customer": 21, "order": 20, "product": 22, "inventory": 18})
    verdict = orch._verify_requirement(_req(LIVE_VIBE), d, p, a)
    assert verdict["status"] == "failed", verdict
    assert "0/4 domain(s) in 4 +/-20% = 3-5" in verdict["evidence"], verdict
    d, p, a = _live_model_lists({"customer": 4, "order": 5, "product": 3, "inventory": 4})
    verdict = orch._verify_requirement(_req(LIVE_VIBE), d, p, a)
    assert verdict["status"] == "fulfilled" and "4/4 domain(s)" in verdict["evidence"], verdict


def test_exactly_means_zero_tolerance_and_partial_coverage_is_partial():
    orch, _ = _orchestrator()
    d, p, a = _live_model_lists({"customer": 4, "order": 5, "product": 4, "inventory": 4})
    verdict = orch._verify_requirement(_req("Exactly 4 products per domain."), d, p, a)
    assert verdict["status"] == "partial" and "3/4 domain(s)" in verdict["evidence"], verdict


def test_a_total_and_an_attribute_count_are_counted():
    orch, _ = _orchestrator()
    d, p, a = _live_model_lists({"customer": 5, "order": 5, "product": 5, "inventory": 5})
    assert orch._verify_deterministic(_req("about 16 products in total"), d, p, a)["status"] == "failed"
    assert orch._verify_deterministic(_req("about 20 tables in total"), d, p, a)["status"] == "fulfilled"
    assert orch._verify_deterministic(_req("at most 30 columns per table"), d, p, a)["status"] == "fulfilled"
    assert orch._verify_deterministic(_req("at most 25 columns per table"), d, p, a)["status"] == "failed"


def test_count_words_are_counted_too():
    orch, _ = _orchestrator()
    d, p, a = _live_model_lists({"customer": 4, "order": 4, "product": 4, "inventory": 4})
    assert orch._verify_requirement(_req("about four products per domain"), d, p, a)["status"] == "fulfilled"
    assert orch._verify_requirement(_req("about a dozen products per domain"), d, p, a)["status"] == "failed"


def test_additive_phrasing_is_not_mistaken_for_a_size_target():
    orch, _ = _orchestrator()
    d, p, a = _live_model_lists({"customer": 4})
    assert orch._verify_count_shape(_req("Add 3 more products per domain"), d, p, a) is None


class _AuditLLM:
    def __init__(self):
        self.calls = 0

    def _call_ai_query(self, **_kw):
        self.calls += 1
        return json.dumps({"verification_results": [{"requirement_id": "VREQ-001", "status": "fulfilled",
                                                     "evidence": "looks small"}], "remediation_actions": [],
                           "summary": {}})


def test_llm_verify_count_requirements_get_an_authoritative_deterministic_verdict():
    orch, _ = _orchestrator()
    d, p, a = _live_model_lists({"customer": 21, "order": 20, "product": 22, "inventory": 18})
    req = _req(LIVE_VIBE, strategy="llm_verify")
    orch.manifest = ah.VibeManifest(raw_text=LIVE_VIBE, requirements=[req])
    assert orch.is_enabled
    orch.ai_agent = _AuditLLM()
    orch._llm_verify_enabled = True
    orch.widgets_values.update({"domains": d, "products": p, "attributes": a})
    orch.validate()
    assert req.status == "failed", (req.status, req.evidence)
    assert "[verifier-count-deterministic FIRED v5.1.6]" in req.evidence
    orch.fold_vov_outcomes({"outcomes": [{"status": "applied", "vreq_ids": ["R1"]}]},
                           [{"vreq_id": "R1", "intent": "sizing", "source_quote": LIVE_VIBE.lower()}])
    assert req.status == "failed", req.status


# ---------------------------------------------------------------- task 7: relax only the sized axis

def test_a_product_only_vibe_keeps_the_attribute_guardrails():
    llm = dict(_MVM_LIVE, min_data_products_per_domain=4, max_data_products_per_domain=4,
               min_attributes_per_product=5, max_attributes_per_product=20)
    pv, lines, _ = _model_params(LIVE_VIBE, llm, user_sizing_override=True)
    assert (pv["min_data_products_per_domain"], pv["max_data_products_per_domain"]) == (4, 4), pv
    assert (pv["min_attributes_per_product"], pv["max_attributes_per_product"]) == (8, 35), pv
    assert any("sizing-override-per-axis FIRED v5.1.6" in l and "['products']" in l for l in lines), lines


def test_an_attribute_vibe_relaxes_only_the_attribute_axis():
    llm = dict(_MVM_LIVE, min_data_products_per_domain=2, max_data_products_per_domain=3,
               min_attributes_per_product=5, max_attributes_per_product=20)
    pv, _, _ = _model_params("Keep tables lean: between 5 and 20 columns per table.", llm, user_sizing_override=True)
    assert (pv["min_attributes_per_product"], pv["max_attributes_per_product"]) == (5, 20), pv
    assert (pv["min_data_products_per_domain"], pv["max_data_products_per_domain"]) == (5, 10), pv


def test_the_clamp_relaxes_only_the_named_axes():
    log, _ = _logger("test_v516_clamp")
    out = ah._clamp_and_validate_model_params("mvm_model", dict(_MVM_LIVE, max_attributes_per_product=20,
                                                                min_data_products_per_domain=4,
                                                                max_data_products_per_domain=4), log,
                                              user_sizing_override={"products"})
    assert out["max_data_products_per_domain"] == 4 and out["max_attributes_per_product"] == 35, out
    out_all = ah._clamp_and_validate_model_params("mvm_model", dict(_MVM_LIVE, max_attributes_per_product=20), log,
                                                  user_sizing_override=True)
    assert out_all["max_attributes_per_product"] == 20, out_all


# ---------------------------------------------------------------- task 8: counts written as words

@pytest.mark.parametrize("vibe,per_domain,totals", [
    ("Keep the model small: about four products per domain.", [4, 4], [None, None]),
    ("roughly five to seven tables per domain", [7, 5], [None, None]),
    ("about a dozen tables per domain", [12, 12], [None, None]),
    ("half a dozen products per domain", [6, 6], [None, None]),
    ("twenty-five tables in total", [None, None], [25, 25]),
    ("at most thirty tables overall", [None, None], [30, None]),
    ("between ten and twelve products per domain", [12, 10], [None, None]),
])
def test_number_words_are_read_by_the_literal_reader(vibe, per_domain, totals):
    out = ah._extract_sizing_directives_from_text(vibe)
    assert [out["max_products_per_domain"], out["min_products_per_domain"]] == per_domain, (vibe, out)
    assert [out["max_total_products"], out["min_total_products"]] == totals, (vibe, out)


def test_a_word_count_copied_into_the_totals_is_overruled():
    log, rec = _logger("test_v516_word_parse")
    vibe = "Keep the model small: about four products per domain."
    widgets = {"logger": log, "config": {}, "vibe_modelling_instructions": vibe, "operation": "new base model",
               "ai_agent": _StubParseLLM(vibe, dict(_NULL_SD, max_total_products=4, min_total_products=4,
                                                    max_products_per_domain=4, min_products_per_domain=4))}
    ah.VibeOrchestrator(widgets).parse()
    sd = widgets["sizing_directives"]
    assert sd.get("max_total_products") is None and sd.get("min_total_products") is None, sd
    assert any("disagree" in l and "max_total_products=4" in l for l in rec.lines), rec.lines
    assert any("[sizing-number-words FIRED v5.1.6]" in l and "four products per domain" in l for l in rec.lines), rec.lines


@pytest.mark.parametrize("prose", [
    "each domain must have at least one product",
    "A silo whose domain has only one product cannot receive an inbound FK",
    "zero tables were dropped",
])
def test_one_and_zero_in_prose_are_not_sizing(prose):
    assert ah._sizing_literal_readings(prose) == [], prose
    out = ah._extract_sizing_directives_from_text(prose)
    assert out["max_total_products"] is None and out["min_total_products"] is None, (prose, out)
    assert out["max_products_per_domain"] is None and out["min_products_per_domain"] is None, (prose, out)


def test_compound_words_with_one_still_count():
    out = ah._extract_sizing_directives_from_text("twenty-one tables in total")
    assert [out["max_total_products"], out["min_total_products"]] == [21, 21], out
    assert ah._sizing_count_value("one hundred") == 100 and ah._sizing_count_value("one dozen") == 12


def test_ordinary_words_are_not_numbers():
    assert ah._sizing_literal_readings("someone added tables and the domain looks attentive") == []
    assert ah._sizing_count_value("twenty-five") == 25 and ah._sizing_count_value("three hundred and ten") == 310


# ---------------------------------------------------------------- task 9: attribute totals become per-product bounds

def test_an_attribute_total_is_divided_across_the_products():
    out = ah._attribute_total_per_product_bounds("about 300 attributes in total", 58, 10, 42)
    assert (out["min_attributes_per_product"], out["max_attributes_per_product"]) == (5, 6), out
    capped = ah._attribute_total_per_product_bounds("at most 300 attributes in total", 30, 10, 42)
    assert (capped["min_attributes_per_product"], capped["max_attributes_per_product"]) == (10, 10), capped
    assert ah._attribute_total_per_product_bounds("about 30 attributes per product", 58, 10, 42) is None


def test_step_four_applies_the_per_product_bounds_before_generating_attributes():
    marker = SOURCE.index("        _atb_pv = config.setdefault(\"PROMPT_VARIABLES\", {})")
    start = SOURCE.rindex("\n", 0, SOURCE.rindex("\n", 0, marker)) + 1
    end_marker = "        logger.warning(f\"[attr-total-per-product-cap] deriving the per-product attribute bounds failed: {_atb_e}\")\n"
    block = textwrap.dedent(SOURCE[start:SOURCE.index(end_marker, marker) + len(end_marker)])
    assert block.startswith("try:"), block[:40]
    log, rec = _logger("test_v516_step4")
    config = {"PROMPT_VARIABLES": {"min_attributes_per_product": 10, "max_attributes_per_product": 42}}
    ns = dict(vars(ah))
    ns.update({"config": config, "logger": log, "products_to_create": [{"product": f"p{i}"} for i in range(58)],
               "widgets_values": {"vibe_modelling_instructions": "about three hundred attributes in total"}})
    exec(compile(block, "<step4>", "exec"), ns)
    pv = config["PROMPT_VARIABLES"]
    assert (pv["min_attributes_per_product"], pv["max_attributes_per_product"]) == (5, 6), pv
    assert any("attr-total-per-product-cap FIRED v5.1.6" in l for l in rec.lines), rec.lines
