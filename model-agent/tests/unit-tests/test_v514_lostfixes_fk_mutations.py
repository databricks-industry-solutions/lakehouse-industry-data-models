import logging
import re
import sys
from pathlib import Path

import pytest

sys.path.insert(0, str(Path(__file__).resolve().parent))
import conftest  # noqa: F401,E402
import agent_helpers as ah  # noqa: E402
from notebook_source_util import cell_containing  # noqa: E402

LOG = logging.getLogger("test_v514_lostfixes_fk_mutations")


@pytest.fixture(autouse=True)
def _no_scope():
    ah.set_vibe_scope_runtime(None)
    yield
    ah.set_vibe_scope_runtime(None)


def _attr(domain, product, name, type_="BIGINT", fk="", pk=False):
    row = {"domain": domain, "product": product, "attribute": name, "type": type_, "tags": "primary_key" if pk else "",
           "foreign_key_to": fk, "description": ""}
    if pk:
        row["is_primary_key"] = True
    return row


def _data(pk_type="STRING"):
    domains = [{"domain": d, "description": "", "division": "", "database_name": d} for d in ("d1", "d2")]
    products = [{"domain": "d1", "product": "cust", "table_name": "cust", "subdomain": ""},
                {"domain": "d2", "product": "ord", "table_name": "ord", "subdomain": ""}]
    attributes = [_attr("d1", "cust", "cust_code", pk_type, pk=True), _attr("d2", "ord", "ord_id", pk=True),
                  _attr("d2", "ord", "buyer_code")]
    return domains, products, attributes


def _cycle_data():
    domains = [{"domain": d, "description": "", "division": "", "database_name": d} for d in ("a", "b")]
    products = [{"domain": "a", "product": "acc", "table_name": "acc", "subdomain": ""},
                {"domain": "b", "product": "txn", "table_name": "txn", "subdomain": ""}]
    attributes = [_attr("a", "acc", "acc_id", "STRING", pk=True), _attr("a", "acc", "txn_id", fk="b.txn.txn_id"),
                  _attr("b", "txn", "txn_id", pk=True), _attr("b", "txn", "acc_link")]
    return domains, products, attributes


def _apply(mutations, data, renames=None):
    domains, products, attributes = data
    return ah._llm_fallback_apply_mutations(mutations, domains, products, attributes, [], LOG, persistent_renames=renames)


def _row(attributes, domain, product, name):
    return next(a for a in attributes if (a["domain"], a["product"], a["attribute"]) == (domain, product, name))


def _summary(caplog):
    line = [r.getMessage() for r in caplog.records if "[MUTATION-SUMMARY]" in r.getMessage()][-1]
    return int(re.search(r"applied=(\d+)", line).group(1)), int(re.search(r"skipped=(\d+)", line).group(1)), line


def test_r5_new_fk_column_keeps_the_requested_name_and_takes_the_target_pk_type():
    data = _data("STRING")
    assert _apply([{"entity_type": "link", "operation": "add", "entity_ref": "d2.ord.customer_id",
                    "new_value": "d1.cust.cust_code"}], data) == 1
    created = _row(data[2], "d2", "ord", "customer_id")
    assert created["foreign_key_to"] == "d1.cust.cust_code"
    assert created["type"] == "STRING"
    assert not [a for a in data[2] if a["attribute"] in ("cust_code", "cust_cust_code") and a["product"] == "ord"]
    assert _apply([{"entity_type": "link", "operation": "add", "entity_ref": "d2.ord.ghost_id", "new_value": "d9.ghost.ghost_id"}], data) == 1
    assert _row(data[2], "d2", "ord", "ghost_id")["type"] == "BIGINT"


@pytest.mark.parametrize("mutation", [
    {"entity_type": "link", "operation": "modify", "entity_ref": "d2.ord.buyer_code", "new_value": "d1.cust.cust_code"},
    {"entity_type": "link", "operation": "add", "entity_ref": "d2.ord.buyer_code", "new_value": "d1.cust.cust_code"},
    {"entity_type": "attribute", "operation": "modify", "entity_ref": "d2.ord.buyer_code", "field": "foreign_key_to",
     "new_value": "d1.cust.cust_code"},
    {"entity_type": "attribute", "operation": "add", "entity_ref": "d2.ord.buyer_code", "field": "foreign_key_to",
     "new_value": "d1.cust.cust_code"},
])
def test_every_fk_write_site_takes_the_target_pk_type(mutation, caplog):
    data = _data("DECIMAL(18,2)")
    with caplog.at_level(logging.INFO, logger=LOG.name):
        assert _apply([mutation], data) == 1
    row = _row(data[2], "d2", "ord", "buyer_code")
    assert row["foreign_key_to"] == "d1.cust.cust_code"
    assert row["type"] == "DECIMAL(18,2)"
    assert any("[v503-fk-type-inherit FIRED v5.1.4]" in r.getMessage() for r in caplog.records)


def test_fk_that_closes_a_cycle_is_skipped_with_one_honest_reason(caplog):
    data = _cycle_data()
    with caplog.at_level(logging.INFO, logger=LOG.name):
        applied = _apply([{"entity_type": "link", "operation": "modify", "entity_ref": "b.txn.acc_link", "new_value": "a.acc.acc_id"}], data)
    assert applied == 0
    assert _row(data[2], "b", "txn", "acc_link")["foreign_key_to"] == ""
    n_applied, n_skipped, line = _summary(caplog)
    assert (n_applied, n_skipped) == (0, 1), line
    assert "'link_fk_would_create_cycle': 1" in line
    assert sum("[v503-fk-cycle-safe FIRED v5.1.4]" in r.getMessage() for r in caplog.records) == 2


def test_fk_reversal_inside_one_batch_lands_after_the_remove():
    data = _cycle_data()
    applied = _apply([
        {"entity_type": "link", "operation": "add", "entity_ref": "b.txn.acc_ref", "new_value": "a.acc.acc_id"},
        {"entity_type": "link", "operation": "remove", "entity_ref": "a.acc.txn_id"},
    ], data)
    assert applied == 2
    assert _row(data[2], "a", "acc", "txn_id")["foreign_key_to"] == ""
    created = _row(data[2], "b", "txn", "acc_ref")
    assert created["foreign_key_to"] == "a.acc.acc_id"
    assert created["type"] == "STRING"


def test_r11_cycle_check_builds_the_fk_adjacency_once_per_batch(monkeypatch, caplog):
    calls = []
    real = ah._build_fk_adjacency

    def counting(attributes_data):
        calls.append(len(attributes_data))
        return real(attributes_data)

    monkeypatch.setattr(ah, "_build_fk_adjacency", counting)
    domains = [{"domain": "d", "description": "", "division": "", "database_name": "d"}]
    names = ["p%d" % i for i in range(8)]
    products = [{"domain": "d", "product": n, "table_name": n, "subdomain": ""} for n in names]
    attributes = [_attr("d", n, n + "_id", pk=True) for n in names]
    mutations = [{"entity_type": "link", "operation": "add", "entity_ref": "d.%s.%s_ref" % (names[i], names[i + 1]),
                  "new_value": "d.%s.%s_id" % (names[i + 1], names[i + 1])} for i in range(7)]
    mutations.append({"entity_type": "link", "operation": "add", "entity_ref": "d.p7.p0_ref", "new_value": "d.p0.p0_id"})
    with caplog.at_level(logging.INFO, logger=LOG.name):
        applied = ah._llm_fallback_apply_mutations(mutations, domains, products, attributes, [], LOG)
    assert applied == 7
    assert not [a for a in attributes if a["attribute"] == "p0_ref"]
    assert len(calls) == 1, calls
    assert "'link_fk_would_create_cycle': 1" in _summary(caplog)[2]


def _claims_data():
    domains = [{"domain": d, "description": "", "division": "", "database_name": d} for d in ("claims", "other")]
    products = [{"domain": "claims", "product": "claim", "table_name": "claim", "subdomain": ""},
                {"domain": "claims", "product": "note", "table_name": "note", "subdomain": ""},
                {"domain": "other", "product": "misc", "table_name": "misc", "subdomain": ""}]
    attributes = [_attr("claims", "claim", "claim_id", pk=True), _attr("claims", "claim", "status", "STRING"),
                  _attr("claims", "note", "status", "STRING"), _attr("other", "misc", "misc_id", pk=True)]
    return domains, products, attributes


def test_r7_applied_renames_resolve_carried_refs_in_the_next_batch_and_unapplied_ones_are_not_kept():
    data = _claims_data()
    renames = {"domain": {}, "product": {}, "attribute": {}}
    assert _apply([{"entity_type": "domain", "operation": "modify", "entity_ref": "claims", "field": "domain", "new_value": "claim"},
                   {"entity_type": "domain", "operation": "modify", "entity_ref": "ghost", "field": "domain", "new_value": "spirit"}],
                  data, renames) == 1
    assert renames["domain"] == {"claims": "claim"}
    assert _apply([{"entity_type": "attribute", "operation": "modify", "entity_ref": "claims.claim.status",
                    "field": "description", "new_value": "carried"}], data, renames) == 1
    assert _row(data[2], "claim", "claim", "status")["description"] == "carried"
    assert _row(data[2], "claim", "note", "status")["description"] == ""
    assert _apply([{"entity_type": "domain", "operation": "modify", "entity_ref": "claim", "field": "domain", "new_value": "claim_core"}],
                  data, renames) == 1
    assert renames["domain"] == {"claims": "claim_core", "claim": "claim_core"}


class _CannedAgent:
    def __init__(self, mutations):
        self.mutations = mutations

    def _call_ai_query(self, prompt_name=None, **_kwargs):
        if prompt_name == "LLM_FALLBACK_CLASSIFY_PROMPT":
            return {"scope": "model", "affected_entities": [], "batch_strategy": "single", "operation_type": "mutate",
                    "validation_hint": {"check_type": "none", "target_description": "", "expected_outcome": ""}}
        return {"mutations": self.mutations, "summary": "canned"}


def test_r7_corrective_actions_share_one_rename_map_across_actions():
    domains, products, attributes = _claims_data()
    shared = {"domain_renames": {}, "product_renames": {}, "attribute_renames": {}}

    def _ctx():
        return {"domains_data": domains, "products_data": products, "attributes_data": attributes, "config": {}, "logger": LOG,
                "dynamically_created_attributes": [], "domain_renames": shared["domain_renames"],
                "product_renames": shared["product_renames"], "attribute_renames": shared["attribute_renames"]}

    rename = _CannedAgent([{"entity_type": "domain", "operation": "modify", "entity_ref": "claims", "field": "domain", "new_value": "claim"}])
    carried = _CannedAgent([{"entity_type": "attribute", "operation": "modify", "entity_ref": "claims.claim.status",
                             "field": "description", "new_value": "carried"}])
    assert ah._llm_fallback_handler({"action": "rename_domain_x", "scope": "domain", "name": "claims"}, _ctx(), rename, "vibes") is True
    assert ah._llm_fallback_handler({"action": "describe_x", "scope": "attribute", "name": "claims.claim.status"}, _ctx(), carried, "vibes") is True
    assert shared["domain_renames"] == {"claims": "claim"}
    assert _row(attributes, "claim", "claim", "status")["description"] == "carried"


def test_r7_corrective_loop_creates_the_rename_maps_once_outside_the_per_action_loop():
    src = cell_containing("CORRECTIVE ACTION(S) FROM VERIFICATION SWEEP")
    loop = src[src.index("CORRECTIVE ACTION(S) FROM VERIFICATION SWEEP"):]
    loop = loop[:loop.index("Corrective actions complete")]
    assert loop.index("_vs_renames = {'domain_renames': {}, 'product_renames': {}, 'attribute_renames': {}}") < loop.index("for _vs_action in _vs_corrective:")
    assert "'domain_renames': {}" not in loop[loop.index("for _vs_action in _vs_corrective:"):]
    for key in ("domain_renames", "product_renames", "attribute_renames"):
        assert loop.count("'%s': _vs_renames['%s']" % (key, key)) == 2, key
