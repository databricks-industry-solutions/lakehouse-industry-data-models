"""v3.1.0 behavioral test: rename-ledger redirect (alias=vov-rename-ledger-redirect).

ROOT CAUSE (gov_transport mvm_v2 ground-truth catalog audit 2026-06-03):
next_vibes carried a rename_product directive (VREQ-061: rename project.data_value
-> project_data_value) ALONGSIDE sibling directives that still referenced the old
name (VREQ-060/062/063: "On project.data_value, add column ..."). The rename applied
first and removed project.data_value; the stale-named siblings then failed the
deterministic pass and fell to the LLM residual, which re-materialized
project.data_value as an orphan stub carrying exactly the re-added columns
(install DDL log showed BOTH project_data_value AND a 7-col project.data_value stub).

FIX: _v310_apply_rename_ledger builds an old->new product-FQN ledger from all
rename_product directives and redirects every sibling priority's `target` and
free-text (reason/intent/text/description/title) to the NEW name BEFORE the
deterministic-vs-residual split, so post-rename adds land on the renamed product
and the residual never re-creates the old stub.

These tests exercise the REAL notebook function end-to-end and assert observable
state changes, plus an anti-tautology proof (pre-ledger the sibling target stays
on the old name; post-ledger it is redirected). Per CLAUDE.md 8.10.
"""
import logging
import re

import pytest

from notebook_source_util import exec_functions_namespace


@pytest.fixture(scope="module")
def ledger_fn():
    ns = exec_functions_namespace(["_vov_redirect_fqn", "_vov_redirect_text", "_v310_apply_rename_ledger"], extra_globals={"re": re})
    return ns["_v310_apply_rename_ledger"]


def _priorities():
    # mirrors gov_transport VREQ-061 (rename) + VREQ-060/062/063 (stale old-name adds)
    return [
        {
            "action": "rename_product",
            "target": "project.data_value",
            "new_name": "project_data_value",
            "reason": "Rename product project.data_value to project_data_value because the standalone name is a generic stub.",
        },
        {
            "action": "connect_table",
            "target": "project.data_value",
            "reason": "On project.data_value, add column saved_by_employee_id (BIGINT) with FK to hr.employee.employee_id.",
        },
        {
            "action": "surgical",
            "target": "project.data_value",
            "reason": "On project.data_value, add column decision_tree_category_id (BIGINT) with FK to project.decision_tree_category.decision_tree_category_id.",
        },
        {
            # an UNRELATED priority must be untouched
            "action": "connect_table",
            "target": "hr.employee",
            "reason": "On hr.employee, add column manager_id (BIGINT) with FK to hr.employee.employee_id.",
        },
    ]


def test_redirects_sibling_target_and_text(ledger_fn):
    prios = _priorities()
    n = ledger_fn(prios, logging.getLogger("t"))
    # 2 stale siblings redirected (the connect_table + the surgical)
    assert n == 2
    # rename directive itself unchanged (must still find the OLD product to rename it)
    assert prios[0]["target"] == "project.data_value"
    # siblings redirected to the NEW product
    assert prios[1]["target"] == "project_data_value" or prios[1]["target"] == "project.project_data_value"
    assert prios[2]["target"] == "project.project_data_value"
    # free-text rewritten so the LLM residual targets the NEW product
    assert "project.project_data_value" in prios[1]["reason"]
    assert "On project.data_value," not in prios[2]["reason"]
    # unrelated priority untouched
    assert prios[3]["target"] == "hr.employee"


def test_anti_tautology_no_ledger_no_redirect(ledger_fn):
    # priorities with NO rename_product -> ledger empty -> nothing redirected
    prios = [p for p in _priorities() if p["action"] != "rename_product"]
    before = [p["target"] for p in prios]
    n = ledger_fn(prios, logging.getLogger("t"))
    assert n == 0
    assert [p["target"] for p in prios] == before
    # the stale sibling target is NOT redirected when no rename exists
    assert prios[0]["target"] == "project.data_value"


def test_target_with_attribute_suffix_preserved(ledger_fn):
    prios = [
        {"action": "rename_product", "target": "sales.order", "new_name": "sales_order"},
        {"action": "modify_attribute_foreign_key", "target": "sales.order.customer_id", "reason": "fix fk"},
    ]
    ledger_fn(prios, logging.getLogger("t"))
    # the attribute suffix must be preserved through the redirect
    assert prios[1]["target"] == "sales.sales_order.customer_id"


def test_transitive_rename_chain(ledger_fn):
    prios = [
        {"action": "rename_product", "target": "d.a", "new_name": "b"},
        {"action": "rename_product", "target": "d.b", "new_name": "c"},
        {"action": "connect_table", "target": "d.a", "reason": "On d.a add col"},
    ]
    ledger_fn(prios, logging.getLogger("t"))
    # a -> b -> c resolves transitively to the final name
    assert prios[2]["target"] == "d.c"


def test_no_overmatch_on_longer_product_name(ledger_fn):
    # ledger old name 'project.data' must NOT redirect a sibling targeting
    # 'project.data_value' (different product, longer token)
    prios = [
        {"action": "rename_product", "target": "project.data", "new_name": "project_data"},
        {"action": "connect_table", "target": "project.data_value", "reason": "On project.data_value add col"},
    ]
    n = ledger_fn(prios, logging.getLogger("t"))
    assert prios[1]["target"] == "project.data_value"
    assert n == 0
