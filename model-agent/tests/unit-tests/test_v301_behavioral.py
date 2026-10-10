"""Behavioral tests for v3.0.1 stub-merge routing fix (audit 2026-06-01).

ROOT CAUSE (ngo/travel/restaurants/construction <85% adherence): a directive
"stub table X must be renamed to existing Y" was classified action=table/surgical
(not rename_product), so it skipped the deterministic collision-aware rename
handler, fell to LLM synthesis, produced an empty diff (noop_failed) for 10 iters,
the stub survived, and DDL hit FK COLUMN_NOT_FOUND + fidelity precision drift ->
the gate rejected the model.

FIX (alias=v301-rename-merge-reclassify):
  - _v301_extract_rename_target() detects rename/merge/consolidate directives.
  - _v251_apply_pass1_priorities reclassifies such generic-action VREQs to
    rename_product (guarded: source product must exist and not be must_have/
    protected) so the existing handler collapses the stub deterministically.

These tests slice the REAL _v251 cluster from the notebook and exercise it
end-to-end, asserting OBSERVABLE state change (stub removed, inbound FK
redirected). test_control_no_rename_keyword_leaves_stub proves the reclassifier
is load-bearing (without a rename directive the stub survives = pre-patch
behaviour), so the suite is non-tautological per CLAUDE.md 8.10.
"""
import copy as _copy_mod
import re
import textwrap

import pytest

from notebook_source_util import notebook_concat_source, vov_ledger_globals

SRC = notebook_concat_source()


class _VReqOutcome:
    """Lightweight stand-in matching the kwargs _v251_apply_pass1_priorities uses."""

    def __init__(self, batch_id=None, vreq_ids=(), status="", diagnostic="", attempts=0):
        self.batch_id = batch_id
        self.vreq_ids = vreq_ids
        self.status = status
        self.diagnostic = diagnostic
        self.attempts = attempts


class _Log:
    def info(self, *a, **k):
        pass

    def warning(self, *a, **k):
        pass


def _load_cluster():
    m = re.search(r"def _v251_model_root\(.*?(?=\ndef _v260_diagnose_slip)", SRC, re.DOTALL)
    assert m, "v251 cluster not found in agent notebook"
    block = textwrap.dedent(m.group(0))
    ns = {**vov_ledger_globals(), "re": re, "copy": _copy_mod, "VReqOutcome": _VReqOutcome, "logger": _Log(), "_VIBE_SCOPE_RUNTIME": None}
    from notebook_source_util import slice_function_source
    exec(compile(slice_function_source("_vibe_scope_note_rename"), "<_vibe_scope_note_rename>", "exec"), ns)
    exec(compile(block, "agent_notebook_v251", "exec"), ns)
    return ns


NS = _load_cluster()
extract_target = NS["_v301_extract_rename_target"]
apply_pass1 = NS["_v251_apply_pass1_priorities"]


def _stub_model():
    return {
        "model": {
            "domains": [
                {
                    "name": "volunteer",
                    "products": [
                        {
                            "name": "volunteer_deployment2",
                            "attributes": [
                                {"name": "volunteer_deployment2_id", "is_primary_key": True},
                                {"name": "orig_site_id", "foreign_key_to": "field.project_site.project_site_id"},
                            ],
                        },
                        {
                            "name": "volunteer_redeployment",
                            "attributes": [{"name": "volunteer_redeployment_id", "is_primary_key": True}],
                        },
                    ],
                },
                {
                    "name": "field",
                    "products": [
                        {"name": "project_site", "attributes": [{"name": "project_site_id", "is_primary_key": True}]}
                    ],
                },
                {
                    "name": "workforce",
                    "products": [
                        {
                            "name": "timesheet",
                            "attributes": [
                                {"name": "timesheet_id", "is_primary_key": True},
                                {"name": "dep2_ref_id",
                                 "foreign_key_to": "volunteer.volunteer_deployment2.volunteer_deployment2_id"},
                            ],
                        }
                    ],
                },
            ]
        }
    }


def _product_names(model, domain):
    for d in model["model"]["domains"]:
        if d["name"] == domain:
            return [p["name"] for p in d["products"]]
    return []


def _find_attr(model, domain, product, attr):
    for d in model["model"]["domains"]:
        if d["name"] == domain:
            for p in d["products"]:
                if p["name"] == product:
                    for a in p["attributes"]:
                        if a["name"] == attr:
                            return a
    return None


# --- _v301_extract_rename_target unit behaviour ----------------------------

@pytest.mark.parametrize("text,expected", [
    ("The stub table volunteer.volunteer_deployment2 must be renamed to volunteer_redeployment", "volunteer_redeployment"),
    ("merge customer into customer_master because duplicate", "customer_master"),
    ("This table should be consolidated into orders", "orders"),
    ("fold the legacy rows into shipment", "shipment"),
    ("rename to `clean_name`", "clean_name"),
    ("add a tracking column foo to the table", None),
    ("increase the attribute count", None),
    ("rename it appropriately", None),  # keyword but no resolvable target
    ("", None),
])
def test_extract_rename_target(text, expected):
    assert extract_target(text) == expected


# --- end-to-end reclassify + collapse (observable state change) ------------

def test_reclassify_collapses_stub_and_redirects_fk():
    model = _stub_model()
    priority = {
        "action": "table",  # generic action that pre-patch fell to LLM synthesis
        "target": "volunteer.volunteer_deployment2",
        "priority_id": 24,
        "vreq_id": "VREQ-024",
        "reason": "The stub table volunteer.volunteer_deployment2 must be renamed to "
                  "volunteer_redeployment because it duplicates the redeployment entity.",
    }
    new_model, outcomes, residual = apply_pass1([priority], model, _Log())

    # stub removed
    assert "volunteer_deployment2" not in _product_names(new_model, "volunteer"), \
        "stub volunteer_deployment2 must be collapsed/removed"
    assert "volunteer_redeployment" in _product_names(new_model, "volunteer")

    # inbound FK redirected to the merge target
    fk = _find_attr(new_model, "workforce", "timesheet", "dep2_ref_id")
    assert fk is not None
    assert fk["foreign_key_to"] == "volunteer.volunteer_redeployment.volunteer_deployment2_id", \
        f"inbound FK must be redirected to the target, got {fk.get('foreign_key_to')}"

    # it was applied deterministically, not dropped to residual
    assert not residual, "reclassified rename must not fall to LLM-synthesis residual"
    assert any(o.status == "applied" for o in outcomes), "VREQ-024 must be applied"


def test_control_no_rename_keyword_leaves_stub():
    """Non-tautology (CLAUDE.md 8.10): without a rename/merge directive the generic
    'table' VREQ is NOT reclassified, falls to residual, and the stub SURVIVES --
    exactly the pre-patch failure behaviour. Proves the reclassifier is load-bearing."""
    model = _stub_model()
    priority = {
        "action": "table",
        "target": "volunteer.volunteer_deployment2",
        "priority_id": 25,
        "vreq_id": "VREQ-025",
        "reason": "Add a redeployment_priority tracking column to volunteer_deployment2.",
    }
    new_model, outcomes, residual = apply_pass1([priority], model, _Log())

    assert "volunteer_deployment2" in _product_names(new_model, "volunteer"), \
        "without a rename directive the stub must survive (pre-patch behaviour)"
    assert priority["action"] == "table", "non-rename VREQ must not be reclassified"
    assert any("VREQ-025" in (o.vreq_ids or ()) for o in outcomes) or residual, \
        "the un-reclassified VREQ should be residual/skipped, not silently applied"


def test_must_have_source_not_reclassified():
    """3b guard: a rename directive whose SOURCE product is must_have/protected
    must NOT be reclassified away."""
    model = _stub_model()
    for d in model["model"]["domains"]:
        if d["name"] == "volunteer":
            for p in d["products"]:
                if p["name"] == "volunteer_deployment2":
                    p["must_have"] = True
    priority = {
        "action": "table",
        "target": "volunteer.volunteer_deployment2",
        "priority_id": 26,
        "vreq_id": "VREQ-026",
        "reason": "rename volunteer_deployment2 to volunteer_redeployment",
    }
    apply_pass1([priority], model, _Log())
    assert priority["action"] == "table", "must_have source product must not be reclassified/renamed"
    assert "volunteer_deployment2" in _product_names(model, "volunteer")


# --- static contracts ------------------------------------------------------

def test_fired_alias_present():
    assert "[v301-rename-merge-reclassify FIRED]" in SRC


def test_version_is_301():
    import re as _re
    m = _re.search(r'__AGENT_VERSION__\s*=\s*"(\d+)\.(\d+)\.(\d+)"', SRC)
    assert m, "version constant not found"
    assert tuple(int(x) for x in m.groups()) >= (3, 0, 1), f"version {m.groups()} < 3.0.1"
