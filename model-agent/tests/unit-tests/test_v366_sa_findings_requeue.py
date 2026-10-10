"""v3.6.6 behavioral test: SA findings are fed into the SelfFixer closed loop.

alias=sa-findings-into-selffixer-loop

ROOT CAUSE under test: SA structural findings (denormalized_natural_key,
cross_domain_duplicate, unlinked_fk, ...) were surfaced ONLY to next_vibes.txt and
NEVER appended to widgets_values['_unfulfilled_for_next_vibe'], so the already-wired
SelfFixer (Opus+sandbox) closed loop never attempted them. _v366_sa_findings_requeue
recomputes SA fresh on the shipped flat lists and queues each SelfFixer-fixable
structural finding as a synthetic unfulfilled REQ.

These tests prove OBSERVABLE state change (the unfulfilled list grows with the right
reqs), not just that a log line fires (§8.10). Pre-patch the function does not exist,
so the slice/exec would raise LookupError — i.e. the behavior is genuinely new.
"""
from __future__ import annotations

import logging

import pytest

from notebook_source_util import exec_function_namespace, slice_function_source

_LOGGER = logging.getLogger("test_v366")

_FN = "_v366_sa_findings_requeue"


def _stub_sa(issues):
    """Return a stub run_metamodel_static_analysis that yields a fixed issue list."""
    def _run(domains_data, products_data, attributes_data, config, logger):
        return {
            "issues": issues,
            "severity_counts": {"error": 0, "warning": 0, "info": 0},
            "summary_by_category": {},
            "model_stats": {},
        }
    return _run


def _ns(issues):
    return exec_function_namespace(
        _FN,
        extra_globals={"run_metamodel_static_analysis": _stub_sa(issues), "_VIBE_SCOPE_RUNTIME": None},
    )


def _wv():
    return {
        "domains": [{"name": "finance"}],
        "products": [{"domain": "finance", "product": "invoice"}],
        "attributes": [{"domain": "finance", "product": "invoice", "attribute": "vendor_name"}],
        "_unfulfilled_for_next_vibe": [],
    }


def test_function_exists_in_notebook():
    # Pre-patch this would raise LookupError; presence proves the fix shipped.
    src = slice_function_source(_FN)
    assert "sa-findings-into-selffixer-loop" in src
    assert "run_metamodel_static_analysis" in src


def test_queues_fixable_structural_findings():
    issues = [
        {"category": "denormalized_natural_key", "severity": "warning",
         "message": "finance.invoice.vendor_name redundant with vendor FK",
         "details": {"entity": "finance.invoice.vendor_name"}, "remediation_actions": ["drop column"]},
        {"category": "fk_target_missing", "severity": "error",
         "message": "finance.invoice.customer_id -> missing target",
         "details": {"target": "finance.invoice.customer_id"}},
    ]
    ns = _ns(issues)
    wv = _wv()
    added = ns[_FN](wv, {}, _LOGGER)
    assert added == 2
    ids = {r["id"] for r in wv["_unfulfilled_for_next_vibe"]}
    assert any("denormalized_natural_key" in i for i in ids)
    assert any("fk_target_missing" in i for i in ids)
    # Every queued req has the SelfFixer-expected shape.
    for r in wv["_unfulfilled_for_next_vibe"]:
        assert set(r) >= {"id", "text", "evidence", "attempts"}
        assert r["attempts"] == 0


def test_excludes_non_fixable_and_info_severity():
    issues = [
        # info severity -> excluded
        {"category": "denormalized_natural_key", "severity": "info",
         "message": "cosmetic", "details": {}},
        # category not in fixable whitelist -> excluded
        {"category": "naming_uniformity", "severity": "warning",
         "message": "style", "details": {}},
        # fixable + warning -> included
        {"category": "unlinked_fk", "severity": "warning",
         "message": "finance.invoice.region_id unlinked",
         "details": {"attribute": "finance.invoice.region_id"}},
    ]
    ns = _ns(issues)
    wv = _wv()
    added = ns[_FN](wv, {}, _LOGGER)
    assert added == 1
    assert "unlinked_fk" in wv["_unfulfilled_for_next_vibe"][0]["id"]


def test_dedupes_against_existing_and_repeat_calls():
    issues = [
        {"category": "unlinked_fk", "severity": "warning",
         "message": "x", "details": {"attribute": "finance.invoice.region_id"}},
    ]
    ns = _ns(issues)
    wv = _wv()
    first = ns[_FN](wv, {}, _LOGGER)
    assert first == 1
    # Second call on the same model must NOT duplicate the same finding.
    second = ns[_FN](wv, {}, _LOGGER)
    assert second == 0
    assert len(wv["_unfulfilled_for_next_vibe"]) == 1


def test_skip_flag_disables_requeue():
    issues = [
        {"category": "unlinked_fk", "severity": "error",
         "message": "x", "details": {"attribute": "finance.invoice.region_id"}},
    ]
    ns = _ns(issues)
    wv = _wv()
    added = ns[_FN](wv, {"SKIP_SA_REQUEUE": "true"}, _LOGGER)
    assert added == 0
    assert wv["_unfulfilled_for_next_vibe"] == []


def test_no_products_returns_zero():
    ns = _ns([{"category": "unlinked_fk", "severity": "error", "message": "x", "details": {}}])
    wv = _wv()
    wv["products"] = []
    assert ns[_FN](wv, {}, _LOGGER) == 0
