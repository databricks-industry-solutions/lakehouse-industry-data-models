"""v3.6.8 behavioral tests for the deterministic quality-gate suite + authoritative
verifier override (the "lying scoreboard" fix).

Covers:
  g1  new deterministic gates in run_metamodel_static_analysis
      (missing_division_tag, invalid_division, division_imbalance,
       missing_subdomain_tag, missing_glossary_tag, fk_pk_type_mismatch,
       low_quality_description)
  g2  new gate categories wired into the SelfFixer requeue whitelist
  g3  _verify_bulk_coverage authoritative deterministic override
      (glossary/subdomain/division coverage read from the real after-state)

These run the REAL shipped code (sliced from the notebook), assert OBSERVABLE
state (the issue list / verdict), and include NEGATIVE cases proving the gates
do not always-fire and the override does not hijack non-coverage VREQs (§8.3/§8.10).
"""
from __future__ import annotations

import ast
import json
import logging
import textwrap
from collections import defaultdict
import re as _re

import pytest

from notebook_source_util import (
    notebook_concat_source,
    slice_function_source,
    exec_function_namespace,
)

_LOGGER = logging.getLogger("test_v368")


# --------------------------------------------------------------------------- #
# Namespace builder: exec every top-level def / import / simple const so the
# huge run_metamodel_static_analysis has its real helpers, skipping any
# side-effectful top-level statement (spark/dbutils) via try/except.
# --------------------------------------------------------------------------- #
_NB_NS_CACHE: dict | None = None


def _build_nb_namespace() -> dict:
    global _NB_NS_CACHE
    if _NB_NS_CACHE is not None:
        return _NB_NS_CACHE
    src = notebook_concat_source()
    tree = ast.parse(src)
    lines = src.splitlines(keepends=True)
    ns: dict = {"__name__": "_nb_ns", "defaultdict": defaultdict, "json": json, "re": _re}
    for node in tree.body:
        if isinstance(node, (ast.FunctionDef, ast.AsyncFunctionDef, ast.Import,
                             ast.ImportFrom, ast.Assign, ast.ClassDef)):
            seg = "".join(lines[node.lineno - 1:node.end_lineno])
            try:
                exec(compile(seg, "nb", "exec"), ns)
            except Exception:
                pass
    _NB_NS_CACHE = ns
    return ns


def _run_sa(domains, products, attributes, config=None):
    ns = _build_nb_namespace()
    fn = ns.get("run_metamodel_static_analysis")
    assert fn is not None, "run_metamodel_static_analysis must build into the namespace"
    res = fn(domains, products, attributes, config or {}, _LOGGER)
    issues = res["issues"] if isinstance(res, dict) else res
    return {i.get("category") for i in issues if isinstance(i, dict)}, issues


# --------------------------------------------------------------------------- #
# g1 — new deterministic gates fire on a dirty model
# --------------------------------------------------------------------------- #
def _dirty_model():
    domains = [
        {"domain": "logistics", "division": "operations", "description": "Operational shipping and freight movement across the network."},
        {"domain": "sales", "division": "business", "description": "Commercial deals, quotes and revenue generation activity."},
        {"domain": "mystery", "description": "A domain deliberately left without any division classification at all."},
        {"domain": "weird", "division": "frobnicate", "description": "A domain carrying an out-of-taxonomy division value for testing."},
    ]
    products = [
        {"domain": "logistics", "product": "shipment", "subdomain": "freight", "description": "Individual freight shipments and their lifecycle states."},
        {"domain": "sales", "product": "deal", "description": "Sales deals; intentionally missing a subdomain tag for testing."},
    ]
    attributes = [
        {"domain": "sales", "product": "deal", "attribute": "id", "type": "BIGINT", "is_primary_key": True, "description": "Surrogate primary key for the sales deal record."},
        {"domain": "sales", "product": "deal", "attribute": "amount", "type": "DECIMAL(18,2)", "description": "Total monetary value of the deal in reporting currency."},
        {"domain": "logistics", "product": "shipment", "attribute": "id", "type": "BIGINT", "is_primary_key": True, "description": "Surrogate primary key for the shipment record."},
        {"domain": "logistics", "product": "shipment", "attribute": "deal_id", "type": "STRING", "foreign_key_to": "sales.deal.id", "description": "Reference to the originating sales deal for this shipment."},
        {"domain": "logistics", "product": "shipment", "attribute": "weight", "type": "DOUBLE", "tags": "logistics_business_glossary_term=gross_weight", "description": "w"},
    ]
    return domains, products, attributes


def test_g1_dirty_model_raises_new_gate_categories():
    cats, _ = _run_sa(*_dirty_model())
    assert "missing_division_tag" in cats          # 'mystery' has no division
    assert "invalid_division" in cats              # 'weird'=frobnicate
    assert "missing_subdomain_tag" in cats         # sales.deal no subdomain
    assert "missing_glossary_tag" in cats          # sales.deal.amount untagged while glossary in use
    assert "fk_pk_type_mismatch" in cats           # shipment.deal_id STRING -> deal.id BIGINT
    assert "low_quality_description" in cats        # shipment.weight desc='w'


def test_g1_qgate_fired_log_present_in_source():
    # The gate block self-reports; presence proves the patch shipped (smoke).
    src = slice_function_source("run_metamodel_static_analysis")
    assert "qgate-suite FIRED" in src
    assert "missing_glossary_tag" in src
    assert "division-canonical-3" in src


def _clean_model():
    domains = [
        {"domain": "logistics", "division": "operations", "description": "Operational shipping and freight movement across the network."},
        {"domain": "sales", "division": "business", "description": "Commercial deals, quotes and revenue generation activity."},
    ]
    products = [
        {"domain": "logistics", "product": "shipment", "subdomain": "freight", "description": "Individual freight shipments and their lifecycle states."},
        {"domain": "sales", "product": "deal", "subdomain": "pipeline", "description": "Sales deals progressing through the commercial pipeline."},
    ]
    attributes = [
        {"domain": "sales", "product": "deal", "attribute": "id", "type": "BIGINT", "is_primary_key": True, "description": "Surrogate primary key for the sales deal record."},
        {"domain": "sales", "product": "deal", "attribute": "amount", "type": "DECIMAL(18,2)", "tags": "sales_business_glossary_term=deal_value", "description": "Total monetary value of the deal in reporting currency."},
        {"domain": "logistics", "product": "shipment", "attribute": "id", "type": "BIGINT", "is_primary_key": True, "description": "Surrogate primary key for the shipment record."},
        {"domain": "logistics", "product": "shipment", "attribute": "deal_id", "type": "BIGINT", "foreign_key_to": "sales.deal.id", "description": "Reference to the originating sales deal for this shipment."},
        {"domain": "logistics", "product": "shipment", "attribute": "weight", "type": "DOUBLE", "tags": "logistics_business_glossary_term=gross_weight", "description": "Gross weight of the shipment in kilograms as measured at origin."},
    ]
    return domains, products, attributes


def test_g1_clean_model_has_no_new_gate_failures():
    cats, _ = _run_sa(*_clean_model())
    for c in ("missing_division_tag", "invalid_division", "division_imbalance",
              "missing_subdomain_tag", "missing_glossary_tag", "fk_pk_type_mismatch",
              "low_quality_description"):
        assert c not in cats, f"clean model should not raise {c}"


# --------------------------------------------------------------------------- #
# g2 — new categories are in the SelfFixer requeue whitelist (behavioral)
# --------------------------------------------------------------------------- #
def _requeue_ns(issues):
    def _stub_sa(domains_data, products_data, attributes_data, config, logger):
        return {"issues": issues, "severity_counts": {}, "summary_by_category": {}, "model_stats": {}}
    return exec_function_namespace(
        "_v366_sa_findings_requeue",
        extra_globals={"run_metamodel_static_analysis": _stub_sa, "_VIBE_SCOPE_RUNTIME": None},
    )


@pytest.mark.parametrize("cat,sev", [
    ("missing_glossary_tag", "warning"),
    ("missing_division_tag", "warning"),
    ("missing_subdomain_tag", "warning"),
    ("fk_pk_type_mismatch", "warning"),
    ("low_quality_description", "info"),       # curated info-level still queues
    ("missing_attribute_description", "info"),
])
def test_g2_new_categories_requeue_to_selffixer(cat, sev):
    issues = [{"category": cat, "severity": sev, "message": "x",
               "details": {"entity": "finance.invoice.vendor_name"}}]
    ns = _requeue_ns(issues)
    wv = {
        "domains": [{"name": "finance"}],
        "products": [{"domain": "finance", "product": "invoice"}],
        "attributes": [{"domain": "finance", "product": "invoice", "attribute": "vendor_name"}],
        "_unfulfilled_for_next_vibe": [],
    }
    added = ns["_v366_sa_findings_requeue"](wv, {}, _LOGGER)
    assert added == 1, f"{cat}/{sev} should requeue exactly one finding"
    assert any(cat in r["id"] for r in wv["_unfulfilled_for_next_vibe"])


# --------------------------------------------------------------------------- #
# g3 — _verify_bulk_coverage authoritative override (extract class method)
# --------------------------------------------------------------------------- #
def _load_bulk_coverage():
    src = notebook_concat_source()
    tree = ast.parse(src)
    lines = src.splitlines(keepends=True)
    target = None
    for node in ast.walk(tree):
        if isinstance(node, ast.FunctionDef) and node.name == "_verify_bulk_coverage":
            target = node
    assert target is not None, "_verify_bulk_coverage method must exist (g3 shipped)"
    seg = textwrap.dedent("".join(lines[target.lineno - 1:target.end_lineno]))
    ns = {"re": _re}
    exec(compile(seg, "nb", "exec"), ns)
    return ns["_verify_bulk_coverage"]


class _FakeSelf:
    logger = _LOGGER


class _Req:
    def __init__(self, text, rid="VREQ-T"):
        self.original_text = text
        self.id = rid
        self.scope = "attribute"
        self.scope_targets = ["*"]


def test_g3_glossary_full_coverage_is_fulfilled():
    fn = _load_bulk_coverage()
    attrs = [
        {"domain": "d", "product": "p", "attribute": "a1", "tags": {"d_business_glossary_term": "x"}},
        {"domain": "d", "product": "p", "attribute": "a2", "tags": {"d_business_glossary_term": "y"}},
        {"domain": "d", "product": "p", "attribute": "id", "is_primary_key": True},   # excluded
        {"domain": "d", "product": "p", "attribute": "p_id", "foreign_key_to": "d.q.id"},  # excluded
    ]
    v = fn(_FakeSelf(), _Req("Tag every business attribute with a glossary term"), [], [], attrs)
    assert v is not None and v["status"] == "fulfilled"


def test_g3_glossary_zero_coverage_is_failed():
    fn = _load_bulk_coverage()
    attrs = [
        {"domain": "d", "product": "p", "attribute": "a1"},
        {"domain": "d", "product": "p", "attribute": "a2"},
    ]
    v = fn(_FakeSelf(), _Req("Tag every business attribute with a glossary term"), [], [], attrs)
    assert v is not None and v["status"] == "failed"


def test_g3_subdomain_partial():
    fn = _load_bulk_coverage()
    products = [
        {"domain": "d", "product": "p1", "subdomain": "s"},
        {"domain": "d", "product": "p2"},  # missing -> 50% coverage
    ]
    v = fn(_FakeSelf(), _Req("Every table must carry a subdomain tag"), [], products, [])
    assert v is not None and v["status"] == "partial"


def test_g3_division_full_coverage_fulfilled():
    fn = _load_bulk_coverage()
    domains = [
        {"domain": "ops", "division": "operations"},
        {"domain": "biz", "division": "business"},
    ]
    v = fn(_FakeSelf(), _Req("Classify every domain into a division"), domains, [], [])
    assert v is not None and v["status"] == "fulfilled"


def test_g3_does_not_hijack_rename_vreq():
    fn = _load_bulk_coverage()
    # mentions 'division' but is a rename op -> must defer (return None)
    v = fn(_FakeSelf(), _Req("Rename domain division_ops to operations"),
           [{"domain": "x"}], [], [])
    assert v is None


def test_g3_does_not_hijack_non_coverage_vreq():
    fn = _load_bulk_coverage()
    # no coverage property keyword present -> None
    v = fn(_FakeSelf(), _Req("Add a column order_total to finance.invoice"),
           [], [], [])
    assert v is None


# --------------------------------------------------------------------------- #
# g6 — fk_pk_type_mismatch is weighted MEDIUM in the deterministic score
# g5 — canonical 3-division fold shipped
# (closure-internal constants; source-grep smoke per §8.10 alongside g1/g2/g3 behavior)
# --------------------------------------------------------------------------- #
def test_g6_fk_pk_type_mismatch_weighted_medium():
    src = notebook_concat_source()
    assert "qgate-score-weight" in src
    # the MEDIUM weight set line must now contain fk_pk_type_mismatch
    assert "_MEDIUM_WEIGHT_CATS = {" in src
    medium_line = next(l for l in src.splitlines() if "_MEDIUM_WEIGHT_CATS = {" in l)
    assert "fk_pk_type_mismatch" in medium_line


def test_g5_division_canonical_fold_present():
    src = notebook_concat_source()
    assert "division-canonical-3" in src
    # the gate folds legacy 'supporting' into 'corporate'
    assert "supporting" in src and "corporate" in src
