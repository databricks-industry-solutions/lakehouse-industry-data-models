"""v5.1.4 vibe_scope in step_allocate_subdomains: new base model (6B) and scoped VOV.

New base model + Some Subdomains: the listed subdomains reach the allocation prompt as a
USER-KING mandate, a deterministic check requires at least one product per listed
subdomain (retry, then a clear failure that also stops the physical deploy), and products
outside the listed subdomains are pruned with remove_product_and_references.
Scoped VOV: only unassigned in-scope products are allocated, and only into in-scope
subdomain names; out-of-scope products are never touched.
The scoped tests fail on pre-patch 5.1.4 phase 1 (no mandate, no prune, every product of
every domain re-allocated). The unscoped test compares against the pre-patch output.
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

LOG = logging.getLogger("test_v514_new_base")
NEW_BASE = "new base model"
VOV = "vibe modeling of version"
GOLDEN = json.loads((Path(__file__).resolve().parent / "fixtures" / "v514_vibe_scope_subdomain_unscoped_golden.json").read_text())
CREW = ["member", "roster", "base", "qualification", "training_record", "duty_period", "pairing"]


@pytest.fixture(autouse=True)
def _reset_runtime():
    ah.set_vibe_scope_runtime(None)
    yield
    ah.set_vibe_scope_runtime(None)


class StubAgent:
    def __init__(self, responder):
        self.responder = responder
        self.calls = []

    def _call_ai_query(self, prompt_name=None, prompt=None, response_schema=None, step_name=None, timeout_seconds=None, max_retries=None):
        self.calls.append((step_name, prompt))
        return self.responder(step_name, prompt, len(self.calls))


def _products(names=CREW, domain="crew", subdomain=""):
    return [{"domain": domain, "product": n, "description": f"{n} desc", "type": "entity", "function": "core", "subdomain": subdomain}
            for n in names]


def _widgets(products, agent, attributes=None, domains=None):
    domains = domains or sorted({p["domain"] for p in products})
    return {"logger": LOG, "ai_agent": agent, "domains": [{"domain": d} for d in domains], "products": products,
            "attributes": attributes if attributes is not None else [], "business_name": "skyline_air",
            "config": {"PROMPT_VARIABLES": {"min_business_subdomains": 2, "max_business_subdomains": 5, "min_products_per_subdomain": 3},
                       "MODEL_CONVENTIONS": {"data_asset_naming_convention": "snake_case"}}}


def _new_base_fence(entries, mode="Some Subdomains"):
    return ah.set_vibe_scope_runtime(ah.build_vibe_scope_fence(ah.parse_vibe_scope(mode, entries), None, NEW_BASE, LOG))


def _alloc(mapping):
    return {"allocations": [{"product": p, "subdomain": s} for p, s in mapping.items()]}


def test_listed_subdomains_reach_the_prompt_and_a_retry_fixes_an_empty_one():
    _new_base_fence("crew.crew_records, crew.crew_scheduling")
    first = {"member": "crew_records", "roster": "crew_records", "base": "Crew Bases", "qualification": "crew_records",
             "training_record": "Crew Training", "duty_period": "crew_records", "pairing": "crew_records"}
    second = dict(first, roster="Crew Scheduling", duty_period="Crew Scheduling", pairing="crew_scheduling")
    agent = StubAgent(lambda step, prompt, n: _alloc(first if n == 1 else second))
    products = _products()
    wv = _widgets(products, agent)
    ah.step_allocate_subdomains(wv)
    assert len(agent.calls) == 2
    first_prompt, second_prompt = agent.calls[0][1], agent.calls[1][1]
    assert "USER-KING MANDATE" in first_prompt and "crew_records, crew_scheduling" in first_prompt
    assert "Listed subdomain 'crew_scheduling' received 0 products" in second_prompt
    kept = {p["product"]: p["subdomain"] for p in wv["products"]}
    assert kept == {"member": "crew_records", "roster": "crew_scheduling", "qualification": "crew_records",
                    "duty_period": "crew_scheduling", "pairing": "crew_scheduling"}
    assert wv["_vibe_scope_subdomain_mandate"] == {"required": {"crew": ["crew_records", "crew_scheduling"]}, "missing": [], "error": ""}
    assert ah._vibe_scope_deploy_preflight({"products": wv["products"]}, LOG)["changed_in_scope_products"]


def test_a_listed_subdomain_left_empty_after_retries_fails_with_a_clear_message():
    _new_base_fence("crew.crew_records, crew.crew_scheduling")
    agent = StubAgent(lambda step, prompt, n: _alloc({name: "crew_records" for name in CREW}))
    wv = _widgets(_products(), agent)
    with pytest.raises(ah.VibeScopeFenceError, match=r"\['crew.crew_scheduling'\] received no product after 3 allocation attempt"):
        ah.step_allocate_subdomains(wv)
    assert len(agent.calls) == 3
    assert wv["_vibe_scope_subdomain_mandate"]["missing"] == ["crew.crew_scheduling"]
    with pytest.raises(ah.VibeScopeFenceError, match="crew.crew_scheduling"):
        ah._vibe_scope_deploy_preflight(wv, LOG)


def test_products_outside_the_listed_subdomains_are_pruned_with_their_references():
    _new_base_fence("crew.crew_records")
    agent = StubAgent(lambda step, prompt, n: _alloc({"member": "crew_records", "roster": "Crew Scheduling", "base": "crew_records"}))
    products = _products(["member", "roster", "base"])
    attributes = [
        {"domain": "crew", "product": "member", "attribute": "member_id", "foreign_key_to": ""},
        {"domain": "crew", "product": "member", "attribute": "home_base_id", "foreign_key_to": "crew.base.base_id"},
        {"domain": "crew", "product": "member", "attribute": "roster_id", "foreign_key_to": "crew.roster.roster_id"},
        {"domain": "crew", "product": "roster", "attribute": "roster_id", "foreign_key_to": ""},
        {"domain": "crew", "product": "roster", "attribute": "member_id", "foreign_key_to": "crew.member.member_id"},
        {"domain": "crew", "product": "base", "attribute": "base_id", "foreign_key_to": ""},
    ]
    wv = _widgets(products, agent, attributes=attributes)
    ah.step_allocate_subdomains(wv)
    assert [p["product"] for p in wv["products"]] == ["member", "base"]
    assert [a["product"] for a in attributes] == ["member", "member", "member", "base"]
    assert next(a for a in attributes if a["attribute"] == "roster_id")["foreign_key_to"] == ""
    assert next(a for a in attributes if a["attribute"] == "home_base_id")["foreign_key_to"] == "crew.base.base_id"


def test_listed_subdomains_bypass_the_word_count_and_size_heuristics():
    _new_base_fence("crew.maintenance, crew.crew_records")
    mapping = {name: "crew_records" for name in CREW}
    mapping["base"] = "Maintenance"
    agent = StubAgent(lambda step, prompt, n: _alloc(mapping))
    wv = _widgets(_products(), agent)
    ah.step_allocate_subdomains(wv)
    assert len(agent.calls) == 1
    by_sub = {}
    for p in wv["products"]:
        by_sub.setdefault(p["subdomain"], []).append(p["product"])
    assert by_sub == {"maintenance": ["base"], "crew_records": [n for n in CREW if n != "base"]}


def test_new_base_some_domains_never_allocates_a_domain_outside_the_roster():
    _new_base_fence("crew", mode="Some Domains")
    agent = StubAgent(lambda step, prompt, n: _alloc({name: ("Crew Records" if i % 2 else "Duty Planning") for i, name in enumerate(CREW)}))
    products = _products() + _products(["leak_a", "leak_b", "leak_c", "leak_d", "leak_e", "leak_f"], domain="finance")
    wv = _widgets(products, agent)
    ah.step_allocate_subdomains(wv)
    assert [c[0] for c in agent.calls] == ["subdomain_allocate_crew"]
    assert {p["subdomain"] for p in wv["products"] if p["domain"] == "finance"} == {""}


def _vov_fence(entries, mode="Some Domains", base_products=None):
    base_products = base_products or {"crew": [("member", "crew_records"), ("roster", "crew_scheduling"), ("base", "crew_records")],
                                      "flight": [("scheduled_flight", "flight_ops")]}
    base = {"model": {"domains": [{"name": d, "products": [{"name": n, "subdomain": s, "attributes": [{"name": f"{n}_id"}]} for n, s in prods]}
                                  for d, prods in base_products.items()], "metric_views": []}}
    return ah.set_vibe_scope_runtime(ah.build_vibe_scope_fence(ah.parse_vibe_scope(mode, entries), base, VOV, LOG))


def _vov_products():
    return [
        {"domain": "crew", "product": "member", "subdomain": "crew_records", "description": "m"},
        {"domain": "crew", "product": "roster", "subdomain": "crew_scheduling", "description": "r"},
        {"domain": "crew", "product": "base", "subdomain": "crew_records", "description": "b"},
        {"domain": "crew", "product": "crew_shift", "subdomain": "", "description": "new in scope"},
        {"domain": "flight", "product": "scheduled_flight", "subdomain": "flight_ops", "description": "s"},
        {"domain": "flight", "product": "gate_slot", "subdomain": "", "description": "unassigned out of scope"},
    ]


def test_scoped_vov_assigns_only_unassigned_in_scope_products_from_in_scope_names():
    _vov_fence("crew")
    agent = StubAgent(lambda step, prompt, n: _alloc({"crew_shift": "Crew Scheduling"}))
    products = _vov_products()
    before = copy.deepcopy(products)
    wv = _widgets(products, agent)
    ah.step_allocate_subdomains(wv)
    assert [c[0] for c in agent.calls] == ["subdomain_allocate_crew"]
    prompt = agent.calls[0][1]
    assert "crew_shift" in prompt and "\"member\"" not in prompt and "crew_records, crew_scheduling" in prompt
    after = {p["product"]: p["subdomain"] for p in wv["products"]}
    assert after == dict({p["product"]: p["subdomain"] for p in before}, crew_shift="crew_scheduling")


def test_scoped_vov_single_in_scope_subdomain_is_assigned_without_an_llm_call():
    _vov_fence("crew.crew_records", mode="Some Subdomains")
    agent = StubAgent(lambda step, prompt, n: pytest.fail("no LLM call expected"))
    products = _vov_products()
    products.append({"domain": "crew", "product": "leave_request", "subdomain": "", "description": "new"})
    wv = _widgets(products, agent)
    ah.step_allocate_subdomains(wv)
    after = {p["product"]: p["subdomain"] for p in wv["products"]}
    assert after["crew_shift"] == "crew_records" and after["leave_request"] == "crew_records"
    assert after["gate_slot"] == "" and after["roster"] == "crew_scheduling"
    assert agent.calls == []


def test_scoped_vov_invalid_llm_choice_falls_back_to_the_largest_in_scope_subdomain():
    _vov_fence("crew")
    agent = StubAgent(lambda step, prompt, n: _alloc({"crew_shift": "Brand New Area"}))
    wv = _widgets(_vov_products(), agent)
    ah.step_allocate_subdomains(wv)
    assert len(agent.calls) == 3
    assert "must be assigned to one of: crew_records, crew_scheduling" in agent.calls[1][1]
    assert {p["product"]: p["subdomain"] for p in wv["products"]}["crew_shift"] == "crew_records"


def test_unscoped_allocation_matches_the_pre_patch_output():
    agent = StubAgent(lambda step, prompt, n: _alloc({name: ("Crew Records" if i % 2 == 0 else "Crew Scheduling") for i, name in enumerate(CREW)}))
    products = _products()
    wv = _widgets(products, agent)
    ah.step_allocate_subdomains(wv)
    assert {p["product"]: p["subdomain"] for p in products} == GOLDEN["assignments"]
    assert len(agent.calls) == GOLDEN["prompt_count"] and agent.calls[0][1] == GOLDEN["prompt_0"]
    assert "_vibe_scope_subdomain_mandate" not in wv
