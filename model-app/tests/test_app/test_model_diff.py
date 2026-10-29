"""Tests for the pure structural diff module (vibe_modeling.backend.model_diff).

Covers:
  (a) purity — the module source carries no DB/session/IO imports;
  (b) normalization regression — export-shaped models (keyed on
      "product"/"attribute", NO "name") must diff identically to name-keyed
      models, NOT as a spurious full delete + recreate;
  (c) return-shape smoke.
"""

import os
import sys

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "..", "src", "app", "src"))

from vibe_modeling.backend.model_diff import compute_model_diff
from vibe_modeling.backend.models import ChangeStatus

EXPORT_OLD = {
    "domains": [
        {
            "name": "sales",
            "products": [
                {"product": "customer", "attributes": [{"attribute": "id", "type": "BIGINT"}]},
            ],
        },
    ],
}


def _deep_copy_export():
    return {
        "domains": [
            {
                "name": "sales",
                "products": [
                    {"product": "customer", "attributes": [{"attribute": "id", "type": "BIGINT"}]},
                ],
            },
        ],
    }


def test_module_is_pure_no_db_imports():
    with open(compute_model_diff.__globals__["__file__"], encoding="utf-8") as fh:
        source = fh.read()
    forbidden = (
        "from .db_models",
        "from sqlmodel",
        "import select",
        "databricks",
        "import os",
        "import json",
        "from pathlib",
    )
    for needle in forbidden:
        assert needle not in source, f"impure import found: {needle!r}"


def test_export_shape_identity_no_spurious_diff():
    diff = compute_model_diff(EXPORT_OLD, _deep_copy_export())
    assert diff["products"] == {}
    assert diff["attributes"] == {}
    assert diff["deleted_products"] == {}
    assert diff["deleted_attributes"] == {}
    assert diff["domains"] == {}
    assert diff["deleted_domains"] == []


def test_export_shape_detects_real_new_product():
    new = _deep_copy_export()
    new["domains"][0]["products"].append(
        {"product": "order", "attributes": [{"attribute": "id", "type": "BIGINT"}]}
    )
    diff = compute_model_diff(EXPORT_OLD, new)
    assert diff["products"][("sales", "order")] == ChangeStatus.NEW
    assert diff["products"].get(("sales", "customer")) is None


def test_mixed_name_and_product_keys_compare_equal():
    old = {
        "domains": [
            {
                "name": "sales",
                "products": [
                    {"name": "customer", "attributes": [{"name": "id", "type": "BIGINT"}]},
                ],
            },
        ],
    }
    new = {
        "domains": [
            {
                "name": "sales",
                "products": [
                    {"product": "customer", "attributes": [{"attribute": "id", "type": "BIGINT"}]},
                ],
            },
        ],
    }
    diff = compute_model_diff(old, new)
    assert diff["products"] == {}
    assert diff["attributes"] == {}
    assert diff["deleted_products"] == {}
    assert diff["deleted_attributes"] == {}


def test_returns_full_diff_shape():
    diff = compute_model_diff(None, _deep_copy_export())
    assert set(diff) == {
        "domains",
        "products",
        "attributes",
        "deleted_domains",
        "deleted_products",
        "deleted_attributes",
    }


def test_case_only_type_change_is_modified_unless_case_insensitive():
    old = {"domains": [{"name": "d", "products": [{"name": "p", "attributes": [{"name": "a", "type": "string"}]}]}]}
    new = {"domains": [{"name": "d", "products": [{"name": "p", "attributes": [{"name": "a", "type": "STRING"}]}]}]}
    assert compute_model_diff(old, new)["attributes"] == {("d", "p", "a"): ChangeStatus.MODIFIED}
    assert compute_model_diff(old, new, type_case_sensitive=False)["attributes"] == {}
