"""v3.2.7 behavioral tests.

RC-F (vov-deterministic-plain-column): the deterministic connect_table /
add_attribute handler REQUIRED a parsed fk_target and returned "parse-failed"
for every PLAIN (no-FK) add-column directive ("add column quantity_assigned
(no FK; data attribute)") -- dumping it on the slow + unreliable LLM synthesis
path where it churned to rejected_unsafe / noop_failed and never landed
(Retail ecm_v4 ground-truth 2026-06-05: 43 of 51 missing connect_table were
plain no-FK data columns on EXISTING products; VOV logged 87.6% coverage,
physical ~20%).

POST-PATCH: plain add-column applies deterministically (column required,
fk_target optional) with generic name-suffix SQL-type inference. FK columns
still apply as BIGINT + foreign_key_to.
"""

from notebook_source_util import notebook_concat_source, pk_suffix_globals
from test_v251_vov_priority_landing import _exec_v251_namespace, _ListLogger
from version_test_util import assert_version_at_least

SRC = notebook_concat_source()


def _model():
    return {
        "model": {
            "domains": [
                {
                    "name": "inventory",
                    "products": [
                        {
                            "name": "location_assignment",
                            "attributes": [
                                {"name": "location_assignment_id", "type": "BIGINT"}
                            ],
                        }
                    ],
                },
                {
                    "name": "store",
                    "products": [
                        {
                            "name": "location",
                            "attributes": [{"name": "location_id", "type": "BIGINT"}],
                        }
                    ],
                },
            ]
        }
    }


def _attrs(model, dom, prod):
    for d in model["model"]["domains"]:
        if d["name"] == dom:
            for p in d["products"]:
                if p["name"] == prod:
                    return {a["name"]: a for a in p["attributes"]}
    return {}


def test_rcf_alias_and_version_present():
    assert "vov-deterministic-plain-column" in SRC
    assert_version_at_least("3.2.7", SRC)
    assert "_v327_infer_coltype" in SRC


def test_rcf_plain_no_fk_column_applies_deterministically():
    """The discriminating case: a no-FK add-column directive must now APPLY
    (pre-patch: parse-failed)."""
    ns = _exec_v251_namespace()
    ns.update(pk_suffix_globals())
    parse = ns["_v251_parse_priority_details"]
    apply_det = ns["_v251_apply_priority_deterministic"]
    model = _model()
    pr = {
        "action": "connect_table",
        "target": "inventory.location_assignment",
        "reason": "add column quantity_assigned (no FK; data attribute) — thin product needs WMS slot count",
    }
    details = parse(pr)
    ok, status = apply_det(pr, details, model, _ListLogger())
    assert ok is True, f"expected apply, got {status}"
    assert status == "applied"
    a = _attrs(model, "inventory", "location_assignment")
    assert "quantity_assigned" in a, "plain column must be added"
    assert a["quantity_assigned"]["type"] == "BIGINT"  # *_quantity -> BIGINT
    assert not a["quantity_assigned"].get("foreign_key_to")  # no FK


def test_rcf_type_inference_by_suffix():
    ns = _exec_v251_namespace()
    ns.update(pk_suffix_globals())
    infer = ns["_v327_infer_coltype"]
    assert infer("issuance_type_code") == "STRING"
    assert infer("relationship_type_code") == "STRING"
    assert infer("eligibility_priority") == "BIGINT"
    assert infer("allocation_quantity") == "BIGINT"
    assert infer("allocation_percentage") == "DECIMAL(18,2)"
    assert infer("household_id") == "BIGINT"
    assert infer("is_active") == "BOOLEAN"
    assert infer("created_date") == "DATE"
    assert infer("free_text_note") == "STRING"  # safe default
    assert infer("anything", explicit="DOUBLE") == "DOUBLE"  # explicit wins
    assert infer("anything", is_fk=True) == "BIGINT"  # fk forces bigint


def test_rcf_fk_column_still_applies_as_bigint_fk():
    """Negative/regression: an FK add-column must STILL apply with foreign_key_to."""
    ns = _exec_v251_namespace()
    ns.update(pk_suffix_globals())
    parse = ns["_v251_parse_priority_details"]
    apply_det = ns["_v251_apply_priority_deterministic"]
    model = _model()
    pr = {
        "action": "connect_table",
        "target": "inventory.location_assignment",
        "reason": "add column store_location_id (BIGINT) with FK to store.location.location_id",
    }
    details = parse(pr)
    ok, status = apply_det(pr, details, model, _ListLogger())
    assert ok is True and status == "applied"
    a = _attrs(model, "inventory", "location_assignment")
    assert a["store_location_id"]["type"] == "BIGINT"
    assert a["store_location_id"]["foreign_key_to"] == "store.location.location_id"


def test_rcf_explicit_type_token_wins():
    ns = _exec_v251_namespace()
    ns.update(pk_suffix_globals())
    parse = ns["_v251_parse_priority_details"]
    apply_det = ns["_v251_apply_priority_deterministic"]
    model = _model()
    pr = {
        "action": "connect_table",
        "target": "inventory.location_assignment",
        "reason": "add column allocation_percentage (DECIMAL(9,4)) (no FK; data attribute)",
    }
    details = parse(pr)
    ok, status = apply_det(pr, details, model, _ListLogger())
    assert ok is True and status == "applied"
    a = _attrs(model, "inventory", "location_assignment")
    assert a["allocation_percentage"]["type"] == "DECIMAL(9,4)"
