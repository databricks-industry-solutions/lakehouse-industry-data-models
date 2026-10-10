"""build_plan, load_model_json, guard_scoped_install, install and register_model_json,
run in main()'s order through the real cells: the catalog holds v1 of "Demo Air" and the
artifact is a scoped v2 built on v1 whose DDL relinks an FK on a kept table.
"""
import json

import pytest

from installer_harness import (BASE_V1_TABLES, REGISTRY_COLUMNS, FakeFiles, FakeUC,
                               load_pipeline, pipeline_cfg, registry_row, scoped_folder)

MODEL_JSON = {"agent_version": "5.1.4", "model_requirements": {"business_name": "Demo Air"},
              "_vibe_scope": {"mode": "domains", "entries": ["sales"], "base_version": "1",
                              "operation": "vibe modeling of version"},
              "model": {"version": "v2_mvm", "domains": []}}
CANONICAL = "/Volumes/demo/_metamodel/vol_root/business/demo_air/v2/mvm/model.json"


def _run(tmp_path, rows):
    folder = scoped_folder(tmp_path, model_json=MODEL_JSON)
    spark = FakeUC(BASE_V1_TABLES, columns=REGISTRY_COLUMNS, rows=rows)
    files = FakeFiles()
    ns = load_pipeline(spark, extra_cells=("def uninstall(cfg)", "def guard_scoped_install"))
    ns["_files_client"] = lambda: files
    cfg = pipeline_cfg(folder)
    plan = ns["build_plan"](cfg)
    model = ns["load_model_json"](cfg)
    ns["guard_scoped_install"](cfg, plan, model)
    final, _, _ = ns["install"](cfg, plan)
    reg = ns["register_model_json"](cfg, model)
    return final, reg, spark, files, folder


def test_a_scoped_artifact_on_its_base_installs_relinks_and_is_handed_to_the_agent(tmp_path):
    final, reg, spark, files, folder = _run(tmp_path, [registry_row(1, business="Demo Air")])
    assert final == []
    assert spark.tables["demo.sales.order"]["fks"] == {
        "fk_order_customer": "demo.sales.customer_v2"}
    assert files.store[CANONICAL] == (folder / "model.json").read_bytes()
    assert (reg["business"], reg["version"], reg["scope"], reg["vibe_scope"]) == (
        "Demo Air", 2, "mvm", True)
    assert "demo" in spark.schemas and "_metamodel" in spark.schemas["demo"]


def test_a_scoped_artifact_on_the_wrong_base_changes_nothing(tmp_path):
    with pytest.raises(Exception, match=r"Scoped install refused.*base v1.*is v3"):
        _run(tmp_path, [registry_row(1, business="Demo Air"),
                        registry_row(3, business="Demo Air")])


def test_the_refusal_comes_before_any_table_ddl(tmp_path):
    folder = scoped_folder(tmp_path, model_json=MODEL_JSON)
    spark = FakeUC(BASE_V1_TABLES, columns=REGISTRY_COLUMNS,
                   rows=[registry_row(2, business="Demo Air")])
    ns = load_pipeline(spark, extra_cells=("def uninstall(cfg)", "def guard_scoped_install"))
    cfg = pipeline_cfg(folder)
    plan = ns["build_plan"](cfg)
    with pytest.raises(Exception, match="Scoped install refused"):
        ns["guard_scoped_install"](cfg, plan, ns["load_model_json"](cfg))
    assert spark.ddl_count() == 0
    assert spark.tables["demo.sales.order"]["fks"] == {"fk_order_customer": "demo.sales.customer"}
    assert json.loads((folder / "model.json").read_text()) == MODEL_JSON
