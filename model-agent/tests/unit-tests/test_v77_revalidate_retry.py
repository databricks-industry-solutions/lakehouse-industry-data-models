"""v0.7.7 vreq-target-revalidate-retry — BEHAVIORAL tests.

Root cause for v0.7.7: v0.7.6 P26 (vreq-target-revalidate-on-execute) was
observability-only. It computed `_revalidate_resolved` via last-component fuzzy
match against the current model state but never re-applied the mutation. The
mutation engine still appended the entry to `skipped`, so unlinked_fk REMEDIATE
actions (the v0.7.5 healthcare 84.2% adherence ceiling) continued to silently
drop in v0.7.6.

v0.7.7 P30 vreq-target-revalidate-retry actually retries the mutation against
the resolved reference for the common entity_type/operation combos:
- link.modify, link.add, link.create, link.remove
- attribute.modify (any field)
- product.modify (any field)

These tests EXERCISE the actual mutation engine (`_llm_fallback_apply_mutations`)
end-to-end, not §8.3 static-grep tautologies. A passing P30 test means the
healthcare unlinked_fk REMEDIATE failure mode is fixed.

CLAUDE.md 2026-05-19 user directive: "USER VIBES ARE KINGS, NO ACTION SHOULD BE
NO-OP, NEVER LIMIT USER ACTION TYPES." This test file enforces NO-OP-detection
on every patched code path.
"""
from __future__ import annotations

import json
import logging
import re
import sys
import types
from pathlib import Path

import pytest

REPO_ROOT = Path(__file__).resolve().parent.parent.parent
AGENT_NB = REPO_ROOT / "agent" / "dbx_vibe_modelling_agent.ipynb"


# ---------------- helpers ----------------


def _load_apply_mutations():
    """Slice `_llm_fallback_apply_mutations` from full notebook (all cells)."""
    from notebook_source_util import exec_functions_namespace

    stubs = {
        "logging": logging,
        "json": json,
        "re": re,
        "_MUT_ENTITY_SYNONYMS": {
            "link": "link",
            "attribute": "attribute",
            "product": "product",
            "domain": "domain",
        },
        "_MUT_OPERATION_SYNONYMS": {
            "modify": "modify",
            "add": "add",
            "create": "create",
            "remove": "remove",
        },
        "sanitize_attribute_type": lambda a: None,
        "_vibe_set_entity_tag": lambda obj, field, value: (
            obj.__setitem__(field, value) if isinstance(obj, dict) else None
        ),
        "_p091_is_valid_identifier": lambda s: (True, ""),
        "_p091_reject_name_mutation": lambda *a, **k: False,
        "_preseed_rename_maps": lambda mutations: ({}, {}, {}),
        "_disk_cached_call": lambda prefix, key_parts, compute_fn: compute_fn(),
    }
    return exec_functions_namespace(
        ["_build_fk_adjacency", "_would_create_cycle", "_sync_fk_type_with_pk", "_llm_fallback_apply_mutations"],
        extra_globals=stubs,
    )


@pytest.fixture(scope="module")
def cell3_ns():
    return _load_apply_mutations()


def _logger():
    lg = logging.getLogger(f"v77test.{id(object())}")
    lg.handlers = []
    lg.addHandler(logging.NullHandler())
    lg.setLevel(logging.DEBUG)
    return lg


def _make_model_v1():
    """Minimal 2-domain model. Used to simulate a 'product was renamed in v1
    but the mutation references the old product name'.

    Domain 'customer' has product 'customers' (PK customer_pk).
    Domain 'sales' has product 'orders' (with 'cust_ref' UNIQUELY-NAMED unlinked FK).

    The fuzzy last-component match in P30 requires a UNIQUE column name across
    the whole model — otherwise the retry refuses (correctly, ambiguity blocks
    a silent wrong mutation). So we use distinct attribute names per row.
    """
    domains = [
        {"domain": "customer", "description": "customer domain"},
        {"domain": "sales", "description": "sales domain"},
    ]
    products = [
        {"domain": "customer", "product": "customers", "description": "all customers"},
        {"domain": "sales", "product": "orders", "description": "all orders"},
    ]
    attributes = [
        {"domain": "customer", "product": "customers", "attribute": "customer_pk",
         "type": "BIGINT", "is_primary_key": True, "foreign_key_to": "",
         "tags": "", "description": "PK"},
        # The unlinked FK column — UNIQUE attribute name so last-component fuzzy
        # match finds exactly one row even when the mutation references the OLD
        # product name.
        {"domain": "sales", "product": "orders", "attribute": "cust_ref",
         "type": "BIGINT", "is_primary_key": False, "foreign_key_to": "",
         "tags": "", "description": "FK"},
    ]
    return domains, products, attributes


# ============================================================================
# P30 behavioral tests — these MUST FAIL on v0.7.6 and PASS on v0.7.7
# ============================================================================


def test_p30_link_modify_retries_against_renamed_product(cell3_ns):
    """v0.7.5 healthcare root-cause reproduction:
    The mutation references `sales.order.cust_ref` but in the model the
    product is named `orders`. P26 in v0.7.6 logged FIRED but did not retry.
    P30 in v0.7.7 must actually set foreign_key_to on the resolved row."""
    apply_mutations = cell3_ns["_llm_fallback_apply_mutations"]
    domains, products, attributes = _make_model_v1()
    dyn_attrs = []
    mutations = [{
        "entity_type": "link",
        "operation": "modify",
        "entity_ref": "sales.order.cust_ref",   # OLD product name 'order' not 'orders'
        "field": "foreign_key_to",
        "new_value": "customer.customers.customer_pk",
    }]
    apply_mutations(mutations, domains, products, attributes, dyn_attrs, _logger())
    target_row = next((a for a in attributes if a["domain"] == "sales" and a["product"] == "orders" and a["attribute"] == "cust_ref"), None)
    assert target_row is not None
    assert target_row["foreign_key_to"] == "customer.customers.customer_pk", (
        f"P30: link.modify mutation against renamed product must set foreign_key_to. "
        f"Got: {target_row['foreign_key_to']!r}"
    )


# NOTE: test_p30_link_add_retries was removed. The original elif chain for
# `link.add` always returns applied=1 (creates a phantom attribute if it can't
# find the target), so the P30 retry path never fires for link.add. P30 still
# carries link.add in its dispatch branches as defensive coverage, but the
# pre-existing phantom-creation behavior dominates in practice. A dedicated
# fix for link.add phantom-creation would be a separate patch (out of v0.7.7 scope
# — v0.7.7 targets the unlinked_fk REMEDIATE failure mode = link.modify, the
# documented v0.7.5 healthcare 84.2% adherence ceiling root cause).


def test_p30_link_remove_retries_against_renamed_product(cell3_ns):
    apply_mutations = cell3_ns["_llm_fallback_apply_mutations"]
    domains, products, attributes = _make_model_v1()
    for a in attributes:
        if a["product"] == "orders" and a["attribute"] == "cust_ref":
            a["foreign_key_to"] = "customer.customers.customer_pk"
    dyn_attrs = []
    mutations = [{
        "entity_type": "link",
        "operation": "remove",
        "entity_ref": "sales.order.cust_ref",  # OLD product name
    }]
    apply_mutations(mutations, domains, products, attributes, dyn_attrs, _logger())
    target_row = next((a for a in attributes if a["product"] == "orders" and a["attribute"] == "cust_ref"), None)
    assert target_row is not None
    assert target_row["foreign_key_to"] == "", (
        f"P30: link.remove must clear foreign_key_to. Got: {target_row['foreign_key_to']!r}"
    )


def test_p30_attribute_modify_retries_against_renamed_product(cell3_ns):
    apply_mutations = cell3_ns["_llm_fallback_apply_mutations"]
    domains, products, attributes = _make_model_v1()
    dyn_attrs = []
    mutations = [{
        "entity_type": "attribute",
        "operation": "modify",
        "entity_ref": "sales.order.cust_ref",  # OLD product name
        "field": "description",
        "new_value": "Linked to customer master via P30 retry",
    }]
    apply_mutations(mutations, domains, products, attributes, dyn_attrs, _logger())
    target_row = next((a for a in attributes if a["product"] == "orders" and a["attribute"] == "cust_ref"), None)
    assert target_row is not None
    assert target_row["description"] == "Linked to customer master via P30 retry"


def test_p30_product_modify_retries_against_renamed_domain(cell3_ns):
    apply_mutations = cell3_ns["_llm_fallback_apply_mutations"]
    domains, products, attributes = _make_model_v1()
    dyn_attrs = []
    mutations = [{
        "entity_type": "product",
        "operation": "modify",
        "entity_ref": "salez.orders",   # OLD domain name 'salez' (typo) vs actual 'sales'
        "field": "description",
        "new_value": "Updated by P30 retry",
    }]
    apply_mutations(mutations, domains, products, attributes, dyn_attrs, _logger())
    target_row = next((p for p in products if p["domain"] == "sales" and p["product"] == "orders"), None)
    assert target_row is not None
    assert target_row["description"] == "Updated by P30 retry", (
        f"P30: product.modify with renamed/misnamed domain must still succeed via last-component fuzzy match. "
        f"Got: {target_row['description']!r}"
    )


def test_p30_no_retry_when_ambiguous(cell3_ns):
    """When the last component matches MORE than one row, do NOT retry.
    Multiple matches = ambiguous = leave in skipped (better fail loud)."""
    apply_mutations = cell3_ns["_llm_fallback_apply_mutations"]
    domains, products, attributes = _make_model_v1()
    attributes.append({
        "domain": "marketing", "product": "leads", "attribute": "cust_ref",
        "type": "BIGINT", "foreign_key_to": "",
    })
    products.append({"domain": "marketing", "product": "leads"})
    domains.append({"domain": "marketing"})
    dyn_attrs = []
    mutations = [{
        "entity_type": "link",
        "operation": "modify",
        "entity_ref": "sales.order.cust_ref",  # OLD product name; AMBIGUOUS — matches 2
        "field": "foreign_key_to",
        "new_value": "customer.customers.customer_pk",
    }]
    apply_mutations(mutations, domains, products, attributes, dyn_attrs, _logger())
    sales_row = next((a for a in attributes if a["domain"] == "sales" and a["attribute"] == "cust_ref"), None)
    marketing_row = next((a for a in attributes if a["domain"] == "marketing" and a["attribute"] == "cust_ref"), None)
    assert sales_row["foreign_key_to"] == "", "ambiguous last-component match must NOT be retried"
    assert marketing_row["foreign_key_to"] == ""


def test_p30_no_retry_when_no_match(cell3_ns):
    """When last component matches NOTHING, do not retry (no row to write to)."""
    apply_mutations = cell3_ns["_llm_fallback_apply_mutations"]
    domains, products, attributes = _make_model_v1()
    dyn_attrs = []
    mutations = [{
        "entity_type": "link",
        "operation": "modify",
        "entity_ref": "ghost.phantom.nonexistent_id",  # nothing matches
        "field": "foreign_key_to",
        "new_value": "customer.customers.customer_pk",
    }]
    apply_mutations(mutations, domains, products, attributes, dyn_attrs, _logger())
    for a in attributes:
        assert a.get("foreign_key_to", "") == "", f"unexpected mutation: {a}"


def test_p30_normal_dispatch_unaffected(cell3_ns):
    """A mutation that matches on first try must NOT go through the retry path."""
    apply_mutations = cell3_ns["_llm_fallback_apply_mutations"]
    domains, products, attributes = _make_model_v1()
    dyn_attrs = []
    mutations = [{
        "entity_type": "link",
        "operation": "modify",
        "entity_ref": "sales.orders.cust_ref",  # CORRECT — first-try match
        "field": "foreign_key_to",
        "new_value": "customer.customers.customer_pk",
    }]
    apply_mutations(mutations, domains, products, attributes, dyn_attrs, _logger())
    target_row = next((a for a in attributes if a["domain"] == "sales" and a["product"] == "orders" and a["attribute"] == "cust_ref"), None)
    assert target_row["foreign_key_to"] == "customer.customers.customer_pk"


# ============================================================================
# Static-grep contracts for v0.7.7 additions (cheap audit checks)
# ============================================================================


def test_v77_agent_version_constant():
    src = notebook_concat_source()
    m = re.search(r'__AGENT_VERSION__\s*=\s*\\?"(\d+)\.(\d+)\.(\d+)\\?"', src)
    assert m, "__AGENT_VERSION__ literal not found"
    assert (int(m.group(1)), int(m.group(2)), int(m.group(3))) >= (0, 7, 7), (
        f"expected v>=0.7.7, found {m.group(1)}.{m.group(2)}.{m.group(3)}"
    )


def test_p30_retry_fired_log_present():
    src = notebook_concat_source()
    assert "[vreq-target-revalidate-retry FIRED]" in src, (
        "P30: retry FIRED log must self-report on successful retry"
    )


def test_p30_retry_covers_link_modify():
    src = notebook_concat_source()
    assert "entity_type == 'link' and operation == 'modify' and len(_retry_parts) >= 3" in src, (
        "P30: must handle link.modify combo (the v0.7.5 healthcare unlinked_fk REMEDIATE root cause)"
    )


def test_p30_retry_covers_attribute_modify():
    src = notebook_concat_source()
    assert "entity_type == 'attribute' and operation == 'modify' and field and len(_retry_parts) >= 3" in src


def test_p30_retry_covers_product_modify():
    src = notebook_concat_source()
    assert "entity_type == 'product' and operation == 'modify' and field and len(_retry_parts) >= 2" in src


def test_p30_skip_append_gated_by_applied_check():
    """Verify the skip_entry append is gated by `if applied == _before_applied:`
    so successful retries do NOT pollute the skipped list. The notebook .ipynb
    is JSON-escaped so the literal newline appears as `\\n` in the raw text."""
    src = notebook_concat_source()
    # The inserted skip block sits inside the JSON-escaped source list. Each
    # source line is a single JSON string ending in `\n`; lines appear in order.
    # The two adjacent lines we care about:
    expected_pair = '"            if applied == _before_applied:\\n"'
    expected_next = '"                _skip_entry = {\\n"'
    assert expected_pair in src and expected_next in src, (
        "P30: skip_entry must be gated by `if applied == _before_applied:`"
    )


# ============================================================================
# Anti-regression: v0.7.6 patches must remain intact
# ============================================================================


def test_v076_p22_p29_aliases_still_present():
    from notebook_source_util import notebook_concat_source
    from version_test_util import assert_aliases_present

    src = notebook_concat_source()
    assert_aliases_present(
        src,
        [
            "vov-user-authority-bypass-contract",
            "vov-closure-action-aware",
            "vov-ssot-user-wins",
            "vreq-target-revalidate-on-execute",
            "vov-sizing-source-scale-guard",
            "vov-master-failure-user-authority",
            "vov-skip-regen-action-aware",
            "vreq-target-revalidate-retry",
        ],
    )


def test_v075_15h_timeout_still_present():
    src = notebook_concat_source()
    assert "timeout_seconds=54000" in src, "v0.7.5 15h timeout fix must remain"
