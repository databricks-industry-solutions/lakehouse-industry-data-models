"""v2.9.1 FIX-6 behavioral test: SSOT cross-domain duplicate MERGE (real production code).

ROOT CAUSE (pre-patch): cross-domain duplicate products were RENAMED/qualified by P0.74 (kept
distinct) and true merges were stashed to next_vibes (which the VOV pass failed to land). There
was no atomic cross-domain merge + FK-repoint. FIX-6 adds _v291_ssot_cross_domain_merge, gated on
the same 60% business-attribute-overlap criterion the LLM dedup prompt uses.

This test EXECs the real function out of the notebook (not a mirror) per §8.10, and proves the
duplicate is removed, the SSOT kept, and the FK repointed.
"""
import ast
import json
import logging
import os

from notebook_source_util import pk_suffix_globals

NB = os.path.join(os.path.dirname(__file__), "..", "..", "agent", "dbx_vibe_modelling_agent.ipynb")


def _load_real_funcs():
    nb = json.load(open(NB))
    full = "\n\n".join("".join(c["source"]) for c in nb["cells"] if c.get("cell_type") == "code")
    tree = ast.parse(full)
    want_funcs = {"strip_domain_prefix", "_v291_user_protected_names", "_v291_ssot_cross_domain_merge"}
    want_assigns = {"_V291_BOILERPLATE_ATTRS"}
    ns = {"re": __import__("re"), "defaultdict": __import__("collections").defaultdict, **pk_suffix_globals()}
    segments = []
    for node in tree.body:
        if isinstance(node, ast.FunctionDef) and node.name in want_funcs:
            segments.append((node.lineno, ast.get_source_segment(full, node)))
        elif isinstance(node, ast.Assign):
            for t in node.targets:
                if isinstance(t, ast.Name) and t.id in want_assigns:
                    segments.append((node.lineno, ast.get_source_segment(full, node)))
    segments.sort()
    for _, seg in segments:
        exec(compile(seg, "<nb>", "exec"), ns)
    return ns


def _src():
    nb = json.load(open(NB))
    return "".join("".join(c["source"]) for c in nb["cells"] if c.get("cell_type") == "code")


LOG = logging.getLogger("v291test")


def test_fix6_present_in_source():
    src = _src()
    assert "ssot-cross-domain-merge FIRED v2.9.1" in src, "FIX-6 missing (pre-patch HEAD => FAIL)"
    assert "_v291_ssot_cross_domain_merge(domains_data, products_data, attributes_data, config, logger)" in src, \
        "FIX-6 call site missing in _pre_static_analysis_autofix"


def _model_with_dup():
    # customer.address and billing.address are the same entity (high biz-attr overlap).
    products = [
        {"domain": "customer", "product": "address", "primary_key": "address_id"},
        {"domain": "billing", "product": "address", "primary_key": "address_id"},
        {"domain": "orders", "product": "order", "primary_key": "order_id"},
    ]
    biz = ["street", "city", "postal_code", "country", "region"]
    attrs = []
    for dom in ("customer", "billing"):
        attrs.append({"domain": dom, "product": "address", "attribute": "address_id", "is_primary_key": True})
        for b in biz:
            attrs.append({"domain": dom, "product": "address", "attribute": b})
    # an order FK pointing at the DUPLICATE (billing.address) — must be repointed to keeper
    attrs.append({"domain": "orders", "product": "order", "attribute": "ship_address_id",
                  "foreign_key_to": "billing.address.address_id"})
    return products, attrs


def test_fix6_merges_and_repoints_fk():
    ns = _load_real_funcs()
    products, attrs = _model_with_dup()
    n = ns["_v291_ssot_cross_domain_merge"]([], products, attrs, {}, LOG)
    assert n == 1, f"expected 1 merge, got {n}"
    names = {(p["domain"], p["product"]) for p in products}
    assert ("billing", "address") not in names, "duplicate not removed"
    assert ("customer", "address") in names, "SSOT keeper removed"
    # FK must now point at the keeper
    fk = next(a for a in attrs if a.get("attribute") == "ship_address_id")["foreign_key_to"]
    assert fk == "customer.address.address_id", f"FK not repointed: {fk}"
    # no attrs left for the removed product
    assert not any(a["domain"] == "billing" and a["product"] == "address" for a in attrs)


def test_fix6_distinct_entities_not_merged():
    # §8.3 anti-tautology: low business-attribute overlap => MUST NOT merge.
    ns = _load_real_funcs()
    products = [
        {"domain": "hr", "product": "contract", "primary_key": "contract_id"},
        {"domain": "legal", "product": "contract", "primary_key": "contract_id"},
    ]
    attrs = []
    for a in ("salary", "start_date", "grade", "manager_id"):
        attrs.append({"domain": "hr", "product": "contract", "attribute": a})
    for a in ("clause", "jurisdiction", "counterparty", "expiry_terms"):
        attrs.append({"domain": "legal", "product": "contract", "attribute": a})
    n = ns["_v291_ssot_cross_domain_merge"]([], products, attrs, {}, LOG)
    assert n == 0, "distinct entities (no biz-attr overlap) must not be merged"
    assert len(products) == 2


def test_fix6_protected_duplicate_not_removed():
    # §3b/§3c: a must-have product must never be removed even if it is a duplicate.
    ns = _load_real_funcs()
    products, attrs = _model_with_dup()
    cfg = {"PROMPT_VARIABLES": {"business_config": {"business_context": {"must_have_data_products": "address"}}}}
    n = ns["_v291_ssot_cross_domain_merge"]([], products, attrs, cfg, LOG)
    assert n == 0, "protected duplicate must not be merged"
    assert len(products) == 3
