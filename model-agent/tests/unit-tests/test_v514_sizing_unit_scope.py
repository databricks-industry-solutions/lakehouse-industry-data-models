"""v5.1.4 sizing unit scope: a per-domain or per-product count never becomes a model total.

Live run 99248567832927: "Keep the model small: about 4 products per domain." with 4 domains
merged max_total_products=4 / min_total_products=4. Behavioral tests drive the production code
through agent_helpers and fail on 56ce1eb (CLAUDE.md 8.10).
"""
import json
import logging
import sys
from pathlib import Path

import pytest

sys.path.insert(0, str(Path(__file__).resolve().parent))
import conftest  # noqa: F401,E402
import agent_helpers as ah  # noqa: E402
from notebook_source_util import notebook_concat_source  # noqa: E402

LIVE_VIBE = "Keep the model small: about 4 products per domain."
LIVE_DOMAINS = ["customer", "order", "product", "inventory"]
ALIAS = "sizing-unit-scope-literal FIRED v5.1.4"
TOTAL_KEYS = ("max_total_products", "min_total_products")
PER_DOMAIN_KEYS = ("max_products_per_domain", "min_products_per_domain")
NULL_SD = {
    "max_domains": None, "min_domains": None, "max_total_products": None, "min_total_products": None,
    "max_products_per_domain": None, "min_products_per_domain": None, "single_domain_mode": False,
    "max_metric_views": None, "min_metric_views": None, "explicit_metric_views": [],
    "explicit_count_statements": [],
}
NULL_RECOVERY = {"domains_exact": None, "products_exact": None, "products_per_domain_exact": None,
                 "metric_views_exact": None, "metric_view_names": []}


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


class _StubLLM:
    def __init__(self, vibe, parse_sd, recovery):
        self.vibe = vibe
        self.parse_sd = parse_sd
        self.recovery = recovery

    def _call_ai_query(self, prompt_name=None, **_kw):
        if prompt_name == "VIBE_PARSE_PROMPT":
            return json.dumps({
                "requirements": [{
                    "original_text": self.vibe, "intent": "sizing", "scope": "model", "scope_targets": ["*"],
                    "mode": "holistic", "priority": "critical", "constraint_type": "hard",
                    "verification_strategy": "llm_verify"}],
                "sizing_directives": self.parse_sd,
                "model_conventions": {k: "" for k in ("tag_prefix", "tag_suffix", "schema_prefix",
                                                       "schema_suffix", "data_asset_naming_convention",
                                                       "cataloging_style")},
            })
        if prompt_name == "SIZING_DIRECTIVE_RECOVERY_PROMPT":
            return json.dumps(self.recovery)
        return "{}"


def _parse(vibe, llm_sd=None, recovery=None):
    log, rec = _logger("test_v514_sizing_parse")
    widgets = {"logger": log, "config": {}, "vibe_modelling_instructions": vibe,
               "operation": "new base model",
               "ai_agent": _StubLLM(vibe, dict(NULL_SD, **(llm_sd or {})), dict(NULL_RECOVERY, **(recovery or {})))}
    ah.VibeOrchestrator(widgets).parse()
    return widgets["sizing_directives"], rec.lines


def _regex(text):
    return ah._extract_sizing_directives_from_text(text)


@pytest.fixture(autouse=True)
def _isolate_sizing_runtime():
    saved = dict(ah._USER_SIZING_BOUNDS_RUNTIME)
    ah._USER_SIZING_BOUNDS_RUNTIME.clear()
    yield
    ah._USER_SIZING_BOUNDS_RUNTIME.clear()
    ah._USER_SIZING_BOUNDS_RUNTIME.update(saved)


# ---------------------------------------------------------------- the live vibe, end to end

def test_live_vibe_with_a_correct_llm_parse_has_no_total_cap():
    sd, _ = _parse(LIVE_VIBE, {"max_products_per_domain": 4, "min_products_per_domain": 4,
                               "explicit_count_statements": [LIVE_VIBE]},
                   {"products_per_domain_exact": 4})
    assert [sd.get(k) for k in TOTAL_KEYS] == [None, None], sd
    assert [sd.get(k) for k in PER_DOMAIN_KEYS] == [4, 4], sd


def test_live_vibe_with_four_domains_derives_a_total_of_sixteen_not_four():
    sd, _ = _parse(LIVE_VIBE, {"max_products_per_domain": 4, "min_products_per_domain": 4},
                   {"products_per_domain_exact": 4})
    published = ah.set_user_sizing_bounds_runtime(sd, domain_count=len(LIVE_DOMAINS))
    assert "max_total_products" not in published and "min_total_products" not in published, published
    ceiling, floor = ah._v490_user_product_bounds()
    assert (ceiling, floor) == (16, 16), (ceiling, floor)


def test_live_vibe_no_longer_licenses_shrinking_the_model_to_four_products():
    sd, _ = _parse(LIVE_VIBE, {"max_products_per_domain": 4, "min_products_per_domain": 4},
                   {"products_per_domain_exact": 4})
    ah.set_user_sizing_bounds_runtime(sd, domain_count=len(LIVE_DOMAINS))
    assert ah.shrink_is_user_requested(20, 4) is False
    assert ah.shrink_is_user_requested(20, 16) is True
    products = [{"domain": d, "product": f"{d}_{i}"} for d in LIVE_DOMAINS for i in range(5)]
    pruned = ah._v358_enforce_product_ceiling_flat([{"domain": d} for d in LIVE_DOMAINS], products, [], sd,
                                                   v1_products=[])
    assert pruned == 0 and len(products) == 20, (pruned, len(products))


def test_live_vibe_overrules_an_llm_that_copies_the_per_domain_count_into_the_totals():
    sd, lines = _parse(LIVE_VIBE, {"max_total_products": 4, "min_total_products": 4,
                                   "max_products_per_domain": 4, "min_products_per_domain": 4})
    assert [sd.get(k) for k in TOTAL_KEYS] == [None, None], sd
    assert [sd.get(k) for k in PER_DOMAIN_KEYS] == [4, 4], sd
    assert any(ALIAS in l and "disagree" in l and "max_total_products=4" in l for l in lines), lines


def test_focused_recovery_cannot_reintroduce_the_per_domain_count_as_a_total():
    sd, lines = _parse(LIVE_VIBE, {"max_products_per_domain": 4, "min_products_per_domain": 4},
                       {"products_exact": 4, "products_per_domain_exact": 4})
    assert [sd.get(k) for k in TOTAL_KEYS] == [None, None], sd
    assert any(ALIAS in l and "focused recovery fill refused" in l for l in lines), lines


def test_live_vibe_logs_the_literal_per_unit_reading():
    _, lines = _parse(LIVE_VIBE, {"max_products_per_domain": 4, "min_products_per_domain": 4})
    assert any(ALIAS in l and "about 4 products per domain" in l for l in lines), lines


# ---------------------------------------------------------------- per-domain vs total fields

def test_regex_reads_about_four_products_per_domain_as_per_domain_only():
    out = _regex("about 4 products per domain")
    assert [out[k] for k in TOTAL_KEYS] == [None, None], out
    assert [out[k] for k in PER_DOMAIN_KEYS] == [4, 4], out


def test_regex_reads_sixteen_products_in_total_as_a_total_only():
    out = _regex("16 products in total")
    assert [out[k] for k in TOTAL_KEYS] == [16, 16], out
    assert [out[k] for k in PER_DOMAIN_KEYS] == [None, None], out


def test_regex_reads_both_phrases_into_their_own_fields():
    out = _regex("about 4 products per domain and 16 products in total")
    assert [out[k] for k in TOTAL_KEYS] == [16, 16], out
    assert [out[k] for k in PER_DOMAIN_KEYS] == [4, 4], out


@pytest.mark.parametrize("vibe,per_domain", [
    ("approximately 4 products per domain", [4, 4]),
    ("~4 products per domain", [4, 4]),
    ("~4 products/domain", [4, 4]),
    ("exactly 4 tables per domain", [4, 4]),
    ("Exactly 4 data products per business domain.", [4, 4]),
    ("4 per domain", [4, 4]),
    ("keep it to 4 tables each", [4, 4]),
    ("Each domain should have about 4 tables.", [4, 4]),
    ("For each domain, generate about 4 tables.", [4, 4]),
    ("4 domains with about 4 tables in each", [4, 4]),
    ("up to 4 tables in each domain", [4, None]),
    ("no more than 4 products per domain", [4, None]),
    ("at least 4 products per domain", [None, 4]),
    ("5-7 tables per domain", [7, 5]),
])
def test_per_domain_phrasings_set_only_per_domain_bounds(vibe, per_domain):
    out = _regex(vibe)
    assert [out[k] for k in TOTAL_KEYS] == [None, None], (vibe, out)
    assert [out[k] for k in PER_DOMAIN_KEYS] == per_domain, (vibe, out)


@pytest.mark.parametrize("vibe,totals", [
    ("16 products in total", [16, 16]),
    ("16 total products", [16, 16]),
    ("about 16 tables overall", [16, 16]),
    ("a total of 30 tables", [30, 30]),
    ("In total, about 30 tables.", [30, 30]),
    ("the whole model has 16 tables", [16, 16]),
    ("about 16 products across 4 domains", [16, 16]),
    ("at most 20 tables", [20, None]),
    ("no fewer than 20 tables", [None, 20]),
    ("around 20 tables", [20, 20]),
])
def test_explicit_totals_still_cap(vibe, totals):
    out = _regex(vibe)
    assert [out[k] for k in TOTAL_KEYS] == totals, (vibe, out)
    assert [out[k] for k in PER_DOMAIN_KEYS] == [None, None], (vibe, out)


def test_llm_that_reads_a_total_as_per_domain_is_overruled():
    sd, lines = _parse("16 products in total", {"max_products_per_domain": 16, "min_products_per_domain": 16})
    assert [sd.get(k) for k in PER_DOMAIN_KEYS] == [None, None], sd
    assert [sd.get(k) for k in TOTAL_KEYS] == [16, 16], sd
    assert any(ALIAS in l and "max_products_per_domain=16" in l for l in lines), lines


def test_an_explicit_total_still_caps_through_the_merge():
    sd, _ = _parse("Keep it to at most 20 tables in total.", {"max_total_products": 20})
    assert sd.get("max_total_products") == 20, sd
    ah.set_user_sizing_bounds_runtime(sd, domain_count=4)
    assert ah._v490_user_product_bounds()[0] == 20


@pytest.mark.parametrize("vibe,expected", [
    ("target 3 domains, ~18 products", {"max_domains": 3, "min_domains": 3,
                                        "max_total_products": 18, "min_total_products": 18}),
    ("3-5 domains", {"max_domains": 5, "min_domains": 3}),
    ("at most 10 domains and at least 2 domains", {"max_domains": 10, "min_domains": 2}),
    ("one big domain", {"max_domains": 1, "min_domains": 1, "single_domain_mode": True}),
    ("a tiny model", {"max_domains": 3, "max_total_products": 18, "max_products_per_domain": 6}),
])
def test_unchanged_readings_for_domain_and_total_phrasing(vibe, expected):
    out = _regex(vibe)
    got = {k: v for k, v in out.items() if k != "explicit_count_statements" and v not in (None, False)}
    assert got == expected, (vibe, out)


# ---------------------------------------------------------------- other sizing sites (§3e)

def test_domains_per_division_is_not_a_domain_total():
    out = _regex("about 4 domains per division")
    assert out["max_domains"] is None and out["min_domains"] is None, out
    sd, _ = _parse("about 4 domains per division", {"max_domains": 4, "min_domains": 4})
    assert sd.get("max_domains") is None and sd.get("min_domains") is None, sd


def test_unpunctuated_run_on_vibe_keeps_each_domain_per_domain():
    out = _regex("each domain should have about 4 tables and 30 columns per table with roughly 12 metric views " * 3)
    assert [out[k] for k in TOTAL_KEYS] == [None, None], out
    assert [out[k] for k in PER_DOMAIN_KEYS] == [4, 4], out


def test_tiny_word_does_not_invent_a_total_over_an_explicit_per_domain_count():
    out = _regex("a tiny model with about 10 products per domain")
    assert [out[k] for k in PER_DOMAIN_KEYS] == [10, 10], out
    assert out["max_total_products"] is None and out["max_domains"] is None, out


def test_per_domain_metric_view_count_is_not_a_model_total():
    sd, lines = _parse("Build 2 metric views per domain.", {"max_metric_views": 2, "min_metric_views": 2})
    assert sd.get("max_metric_views") is None and sd.get("min_metric_views") is None, sd
    assert any(ALIAS in l and "max_metric_views=2" in l for l in lines), lines


def test_next_vibes_mv_directive_skips_a_per_domain_count():
    log, rec = _logger("test_v514_sizing_mv")
    assert ah._vibe_exact_metric_view_directive(
        {"logger": log}, vibe_text="Constrain model to exactly 2 metric views per domain") == (None, [])
    assert any(ALIAS in l for l in rec.lines), rec.lines
    count, names = ah._vibe_exact_metric_view_directive(
        {}, vibe_text="Constrain model to exactly 3 metric views (target: A, B, C)")
    assert count == 3 and names == ["A", "B", "C"]


def _model(n_domains, n_mvs):
    return {"model": {
        "domains": [{"name": f"d{i}", "products": [{"name": f"p{i}", "attributes": []}]} for i in range(n_domains)],
        "metric_views": [{"name": f"mv{i}"} for i in range(n_mvs)],
    }}


def test_completeness_requeue_multiplies_a_per_domain_mv_count_by_the_domain_count():
    log, rec = _logger("test_v514_sizing_requeue")
    widgets = {}
    added = ah._v320_vibe_completeness_requeue(_model(3, 2), "Build at least 2 metric views per domain.", widgets, log)
    assert added == 1, rec.lines
    req = widgets["_unfulfilled_for_next_vibe"][0]
    assert req["id"] == "COMPLETENESS-MV-COUNT" and "want=6" in req["evidence"], req


def test_completeness_requeue_still_reads_a_model_total():
    widgets = {}
    added = ah._v320_vibe_completeness_requeue(_model(3, 2), "Build at least 4 metric views.", widgets,
                                               logging.getLogger("x"))
    assert added == 1 and "want=4" in widgets["_unfulfilled_for_next_vibe"][0]["evidence"]


# ---------------------------------------------------------------- tier gate derives the total

def test_tier_gate_derives_the_total_from_per_domain_times_domain_count():
    log, rec = _logger("test_v514_sizing_gate")
    sd = {"max_products_per_domain": 4, "min_products_per_domain": 4}
    ah.set_user_sizing_bounds_runtime(sd, domain_count=4)
    active, skipped = ah._tier_aware_architect_gate_keys(sd, logger=log, alias="arch-gate-tier-aware")
    assert active == () and len(skipped) == 4, (active, skipped)
    assert any(ALIAS in l and "= 16" in l for l in rec.lines), rec.lines


def test_tier_gate_does_not_treat_the_per_domain_number_as_the_total():
    sd = {"max_products_per_domain": 10, "min_products_per_domain": 10}
    ah.set_user_sizing_bounds_runtime(sd, domain_count=4)
    active, skipped = ah._tier_aware_architect_gate_keys(sd)
    assert skipped == () and len(active) == 4, (active, skipped)


# ---------------------------------------------------------------- attributes per product

def test_live_vibe_attribute_analog_gives_no_product_or_total_cap():
    vibe = "Keep the model small: about 30 attributes per product."
    sd, lines = _parse(vibe, {"max_total_products": 30, "min_total_products": 30,
                              "max_products_per_domain": 30})
    assert [sd.get(k) for k in TOTAL_KEYS + PER_DOMAIN_KEYS] == [None, None, None, None], sd
    assert any(ALIAS in l and "max_total_products=30" in l for l in lines), lines
    ah.set_user_sizing_bounds_runtime(sd, domain_count=4)
    assert ah._v490_user_product_bounds() == (None, None)


def test_attribute_readings_keep_per_product_and_total_apart():
    per_product = ah._sizing_literal_readings("about 30 attributes per product")
    total = ah._sizing_literal_readings("300 attributes in total")
    assert [(r["unit"], r["scope"], r["per"], r["n"]) for r in per_product] == [("attribute", "per_unit", "product", 30)]
    assert [(r["unit"], r["scope"], r["n"]) for r in total] == [("attribute", "total", 300)]
    assert _regex("about 30 attributes per product")["max_total_products"] is None


def _model_params(vibe, mvm_llm, domains=None):
    log, rec = _logger("test_v514_sizing_params")
    params = {"industry_complexity_tier": "tier_3", "tier_justification": "t", "sizing_notes": "s",
              "user_sizing_override": True, "mvm_model": dict(mvm_llm), "ecm_model": dict(mvm_llm)}
    config = {"MODEL_SCOPE": "mvm", "PROMPT_KEYS": {},
              "PROMPT_VARIABLES": {"business_config": {"business": "b", "description": "d"}}}
    widgets = {"vibe_modelling_instructions": vibe, "_user_specified_domains": list(domains or [])}
    validator = type("_Validator", (), {"validate_model_generation_parameters": lambda *_a, **_k: (True, [])})()
    original = ah.smart_worker_loop
    ah.smart_worker_loop = lambda **_kw: (True, params, [])
    try:
        ah._determine_model_parameters(None, {}, config, widgets, log, validator, None)
    finally:
        ah.smart_worker_loop = original
    return config["PROMPT_VARIABLES"], rec.lines


_MVM_BASE = {"min_business_domains": 4, "max_business_domains": 4, "min_data_products_per_domain": 5,
             "max_data_products_per_domain": 10, "min_attributes_per_product": 10, "max_attributes_per_product": 40,
             "min_business_subdomains": 2, "max_business_subdomains": 3, "min_products_per_subdomain": 2,
             "product_attributes_dedupe_threshold": 45, "min_honesty_score_threshold": 50}


def test_model_params_rejects_an_attribute_total_copied_into_the_per_product_cap():
    pv, lines = _model_params("300 attributes in total", dict(_MVM_BASE, max_attributes_per_product=300),
                              LIVE_DOMAINS)
    assert pv["max_attributes_per_product"] == 50, pv["max_attributes_per_product"]
    assert any(ALIAS in l and "max_attributes_per_product 300 -> 50" in l for l in lines), lines


def test_model_params_keeps_an_explicit_per_product_attribute_cap():
    pv, lines = _model_params("at most 30 attributes per product", dict(_MVM_BASE, max_attributes_per_product=30),
                              LIVE_DOMAINS)
    assert pv["max_attributes_per_product"] == 30, pv["max_attributes_per_product"]
    assert not any(ALIAS in l for l in lines), lines


def test_model_params_divides_a_product_total_copied_into_the_per_domain_range():
    pv, lines = _model_params("16 products in total",
                              dict(_MVM_BASE, min_data_products_per_domain=16, max_data_products_per_domain=16),
                              LIVE_DOMAINS)
    assert (pv["min_data_products_per_domain"], pv["max_data_products_per_domain"]) == (4, 4), pv
    assert any(ALIAS in l and "max_data_products_per_domain 16 -> 4" in l for l in lines), lines


def test_model_params_leaves_the_live_vibe_to_the_per_domain_clamp():
    pv, lines = _model_params(LIVE_VIBE, _MVM_BASE, LIVE_DOMAINS)
    assert not any(ALIAS in l for l in lines), lines
    assert pv["max_attributes_per_product"] == 40 and pv["max_business_domains"] == 4


# ---------------------------------------------------------------- prompts + wiring smoke

def test_prompts_tell_the_llm_to_keep_per_unit_and_total_apart():
    parse = ah.PROMPT_TEMPLATES["VIBE_PARSE_PROMPT"]
    recovery = ah.PROMPT_TEMPLATES["SIZING_DIRECTIVE_RECOVERY_PROMPT"]
    params = ah.PROMPT_TEMPLATES["MODEL_GENERATION_PARAMETER_PROMPT"]
    assert "A per-domain count is NEVER a total" in parse
    assert "products_exact and metric_views_exact are WHOLE-MODEL totals" in recovery
    assert "**Per-unit vs total:**" in params
    assert "about 4 products per domain" in parse.format(vibe_text="v")
    assert "WHOLE-MODEL totals" in recovery.format(vibe_text="v")


def test_every_site_carries_the_fired_alias():
    src = notebook_concat_source()
    assert src.count("[sizing-unit-scope-literal FIRED v5.1.4]") >= 7
    assert "sizing_directives parsed by the LLM (VIBE_PARSE)" in src
