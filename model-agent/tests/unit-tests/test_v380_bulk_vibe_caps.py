"""v3.8.0 behavioral test for deterministic bulk vibe-caps (items 15/16, core of 14).

Extracts the `_v371_*` helpers from the production notebook and proves:
- tag-EVERY-attribute: verify FAILS pre-apply, apply stamps 100%, verify PASSES post, idempotent.
- prefix-EVERY-attribute: apply renames every column AND rewires foreign_key_to (no orphan joins);
  verify FAILS pre, PASSES post; FK target component is rewritten.
- the directive parsers recognise the canonical vibe phrasings.
"""
import json
import os
import re

import pytest

from notebook_source_util import vov_ledger_globals

NB = os.path.join(os.path.dirname(__file__), "..", "..", "agent", "dbx_vibe_modelling_agent.ipynb")


def _load_v371_namespace():
    nb = json.load(open(NB))
    block = None
    for c in nb.get("cells", []):
        if c.get("cell_type") != "code":
            continue
        src = "".join(c.get("source", []))
        if "def _iter_flat_attributes" in src and "def _v371_apply_prefix_all" in src:
            start = src.index("def _iter_flat_attributes")
            end = src.index("def _apply_vibe_custom_tags")
            block = src[start:end]
            break
    assert block, "v371 helper block not found in notebook"

    def _vibe_set_entity_tag(entity, tag_key, tag_value):
        existing = (entity.get("tags") or "")
        full_tag = f"{tag_key}={tag_value}"
        if full_tag not in existing:
            entity["tags"] = f"{existing},{full_tag}".strip(",")
            return True
        return False

    ns = {
        **vov_ledger_globals(),
        "re": re,
        "_coerce_tags_to_string_v250": lambda v: "" if v is None else (v if isinstance(v, str) else str(v)),
        "_vibe_set_entity_tag": _vibe_set_entity_tag,
        "sanitize_name": lambda name, **k: name,
    }
    exec(compile(block, "<v371>", "exec"), ns)
    return ns


@pytest.fixture(scope="module")
def ns():
    return _load_v371_namespace()


def _attrs():
    return [
        {"domain": "hr", "product": "employee", "attribute": "employee_id", "tags": ""},
        {"domain": "hr", "product": "employee", "attribute": "name", "tags": ""},
        {"domain": "hr", "product": "salary", "attribute": "amount", "tags": "",
         "foreign_key_to": "hr.employee.employee_id"},
    ]


def test_tag_all_fail_pre_pass_post(ns):
    attrs = _attrs()
    ok_pre, _ = ns["_v371_verify_tag_all"](attrs, "source_system")
    assert ok_pre is False  # fail-pre proof

    n = ns["_v371_apply_tag_all"](attrs, "source_system", "DDL", config={})
    assert n == 3

    ok_post, diag = ns["_v371_verify_tag_all"](attrs, "source_system")
    assert ok_post is True, diag

    n2 = ns["_v371_apply_tag_all"](attrs, "source_system", "DDL", config={})
    assert n2 == 0  # idempotent


def test_prefix_all_rewires_fk(ns):
    attrs = _attrs()
    prods = [{"domain": "hr", "product": "employee", "primary_key": "employee_id"}]

    ok_pre, _ = ns["_v371_verify_prefix_all"](attrs, "ass_")
    assert ok_pre is False  # fail-pre proof

    n = ns["_v371_apply_prefix_all"](attrs, prods, "ass_")
    assert n == 3

    names = {a["attribute"] for a in attrs}
    assert names == {"ass_employee_id", "ass_name", "ass_amount"}
    fk = [a for a in attrs if a["attribute"] == "ass_amount"][0]["foreign_key_to"]
    assert fk == "hr.employee.ass_employee_id"  # FK rewired, no orphan
    assert prods[0]["primary_key"] == "ass_employee_id"  # PK rewired

    ok_post, diag = ns["_v371_verify_prefix_all"](attrs, "ass_")
    assert ok_post is True, diag


def test_prefix_all_idempotent(ns):
    attrs = _attrs()
    ns["_v371_apply_prefix_all"](attrs, [], "ass_")
    n2 = ns["_v371_apply_prefix_all"](attrs, [], "ass_")
    assert n2 == 0


def test_parsers(ns):
    assert ns["_v371_parse_bulk_prefix_directive"]("Prefix every column with ass_") == "ass_"
    assert ns["_v371_parse_bulk_prefix_directive"]("all attributes must be prefixed with src_") == "src_"
    assert ns["_v371_parse_bulk_prefix_directive"]("nothing here") is None

    got = ns["_v371_parse_bulk_tag_directives"]("tag source_system=DDL on every attribute")
    assert ("source_system", "DDL") in got
