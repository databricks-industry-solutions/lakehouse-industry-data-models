"""A scoped deploy plan runs its constraint drops before the tables and its column adds
right after them, so a relinked FK lands on its new parent instead of being kept stale
("already exists") or deleted by a late DROP. Unscoped plans run exactly as before.
"""
import hashlib
from pathlib import Path

import pytest

from installer_harness import (BASE_V1_TABLES, FakeUC, find_cell, load_pipeline, pipeline_cfg,
                               scoped_folder)

REPO = Path(__file__).resolve().parents[3]
PRESERVED = "`demo`.`sales`.`order`"


def _install(spark, folder):
    ns = load_pipeline(spark)
    cfg = pipeline_cfg(folder)
    plan = ns["build_plan"](cfg)
    final, _, _ = ns["install"](cfg, plan)
    return final, plan, ns


def _categorize(stmt):
    ns = {"__name__": "core"}
    exec(compile(find_cell("def categorize"), "<core>", "exec"), ns)
    return ns["categorize"](stmt)


def _phases_run(plan, include_metrics=False):
    ran = []
    ns = load_pipeline(FakeUC())
    ns["run_phase"] = lambda name, stmts, *a, **k: ran.append(name) or []
    ns["_ensure_catalog"] = lambda catalog, log: None
    ns["_catalog_exists"] = lambda catalog: True
    cfg = dict(pipeline_cfg("."), include_metrics=include_metrics, target_catalogs=["demo"])
    ns["install"](cfg, plan)
    return ran, ns["_log_lines"]


# ------------------------------------------------------------------ routing

@pytest.mark.parametrize("stmt", [
    "ALTER TABLE `demo`.`sales`.`order` DROP CONSTRAINT IF EXISTS `fk_order_customer`",
    "alter table demo.sales.order drop constraint fk_order_customer",
    "ALTER TABLE `demo`.`sales`.`order`\n  DROP FOREIGN KEY IF EXISTS (`customer_id`)",
])
def test_constraint_drops_get_their_own_phase(stmt):
    assert _categorize(stmt) == "fk_drop"


@pytest.mark.parametrize("stmt", [
    "ALTER TABLE `demo`.`sales`.`order` ADD COLUMNS (`loyalty_id` BIGINT COMMENT 'x')",
    "ALTER TABLE `demo`.`sales`.`order` ADD COLUMNS(`loyalty_id` BIGINT)",
    "alter table demo.sales.`order` add column loyalty_id bigint",
])
def test_column_adds_get_their_own_phase(stmt):
    assert _categorize(stmt) == "column_add"


@pytest.mark.parametrize("stmt,phase", [
    ("CREATE TABLE IF NOT EXISTS `demo`.`sales`.`order` (order_id BIGINT)", "table"),
    ("CREATE OR REPLACE TABLE `demo`.`sales`.`order` (order_id BIGINT COMMENT "
     "'Drop constraint and add columns are words here')", "table"),
    ("ALTER TABLE `demo`.`sales`.`order` ADD CONSTRAINT `fk` FOREIGN KEY (`c`) "
     "REFERENCES `demo`.`sales`.`customer` (`c`)", "fk"),
    ("ALTER TABLE `demo`.`sales`.`order` ALTER COLUMN `c` SET TAGS "
     "('note' = 'add columns later, drop constraint never')", "tag"),
    ("ALTER TABLE `demo`.`sales`.`order` SET TAGS ('dbx_domain' = 'sales')", "tag"),
    ("ALTER TABLE `demo`.`sales`.`order` DROP COLUMN `legacy`", "other"),
])
def test_everything_else_keeps_its_phase(stmt, phase):
    assert _categorize(stmt) == phase


def test_build_plan_puts_the_scoped_statements_in_the_new_phases(tmp_path):
    ns = load_pipeline(FakeUC())
    plan = ns["build_plan"](pipeline_cfg(scoped_folder(tmp_path)))
    assert [s.split(" DROP ")[0] for s in plan["fk_drop"]] == ["ALTER TABLE " + PRESERVED]
    assert len(plan["column_add"]) == 1 and "ADD COLUMNS" in plan["column_add"][0]
    assert plan["other"] == []
    assert list(plan)[:6] == ["catalog", "schema", "fk_drop", "table", "column_add", "fk"]


# ------------------------------------------------------------------ execution order

def test_install_runs_drops_before_tables_and_column_adds_before_fks_and_tags():
    ran, lines = _phases_run({"catalog": [], "schema": ["s"], "fk_drop": ["d"], "table": ["t"],
                              "column_add": ["c"], "fk": ["f"], "tag": ["g"], "metric": [],
                              "other": []})
    assert ran == ["schema", "fk_drop", "table", "column_add", "fk", "tag"]
    assert any("[installer-scoped-phase-order FIRED] 1 constraint drop(s)" in line
               for line in lines)


def test_a_relinked_fk_lands_on_its_new_parent(tmp_path):
    spark = FakeUC(BASE_V1_TABLES)
    final, _, _ = _install(spark, scoped_folder(tmp_path))
    order = spark.tables["demo.sales.order"]
    assert order["fks"] == {"fk_order_customer": "demo.sales.customer_v2"}, \
        "the relinked FK must point at the new parent, not vanish or stay stale"
    assert "loyalty_id" in order["columns"]
    assert "loyalty_id" in order["tags"]
    assert final == []


def test_the_drop_runs_before_the_add_and_the_column_add_before_its_tag(tmp_path):
    spark = FakeUC(BASE_V1_TABLES)
    _install(spark, scoped_folder(tmp_path))
    drop = spark.position("DROP CONSTRAINT IF EXISTS `fk_order_customer`")
    add = spark.position("ADD CONSTRAINT `fk_order_customer`")
    create = spark.position("CREATE TABLE IF NOT EXISTS")
    column = spark.position("ADD COLUMNS")
    tag = spark.position("SET TAGS")
    assert len(drop) == 1 and len(add) == 1
    assert drop[0] < create[0] < column[0] < add[0] < tag[0]


def test_a_fresh_catalog_ignores_the_drop_of_a_table_that_does_not_exist_yet(tmp_path):
    spark = FakeUC()
    final, _, ns = _install(spark, scoped_folder(tmp_path))
    assert final == []
    assert spark.tables["demo.sales.order"]["fks"] == {
        "fk_order_customer": "demo.sales.customer_v2"}
    drop = spark.position("DROP CONSTRAINT IF EXISTS")
    assert len(drop) == 1 and drop[0] < spark.position("ADD CONSTRAINT")[0], \
        "the missing-table DROP must not be retried after the FK phase re-added the constraint"
    assert any("[fk_drop] DONE" in line and "ignored=1" in line for line in ns["_log_lines"])


def test_a_drop_that_fails_once_is_retried_before_the_tables_are_built(tmp_path):
    seen = {"n": 0}

    def flaky_drop(stmt):
        if "DROP CONSTRAINT" in stmt:
            seen["n"] += 1
            if seen["n"] == 1:
                raise RuntimeError("PERMISSION_DENIED: user lacks MODIFY on the table")

    spark = FakeUC(BASE_V1_TABLES, fail=flaky_drop)
    final, _, _ = _install(spark, scoped_folder(tmp_path))
    assert final == []
    assert spark.tables["demo.sales.order"]["fks"] == {
        "fk_order_customer": "demo.sales.customer_v2"}
    drops = spark.position("DROP CONSTRAINT IF EXISTS")
    assert len(drops) == 2 and max(drops) < spark.position("CREATE TABLE IF NOT EXISTS")[0]


def test_a_drop_that_keeps_failing_is_reported_and_never_runs_after_the_fk_phase(tmp_path):
    def broken_drop(stmt):
        if "DROP CONSTRAINT" in stmt:
            raise RuntimeError("PERMISSION_DENIED: user lacks MODIFY on the table")

    spark = FakeUC(BASE_V1_TABLES, fail=broken_drop)
    final, _, _ = _install(spark, scoped_folder(tmp_path))
    assert [f[0] for f in final] == ["fk_drop"], \
        "a stale constraint must fail the install loudly, not pass as 'already exists'"
    add = spark.position("ADD CONSTRAINT")[0]
    assert all(i < add for i in spark.position("DROP CONSTRAINT IF EXISTS"))


# ------------------------------------------------------------------ unscoped is unchanged

GOLDEN_RESTAURANTS_V2_MVM = {
    "catalog": [1, "707b5474bec5a5d4"], "schema": [9, "d7956eb3068a3de6"],
    "table": [87, "99d29bed8bc7cb1e"], "fk": [506, "19bdd4e758640e31"],
    "tag": [3102, "303360db8bef97bc"], "metric": [70, "3fd7dbe25afff694"],
}


def test_a_shipped_unscoped_model_plans_exactly_as_before():
    """The digest of the plan the installer builds for this folder; a change here is a
    change to every unscoped install."""
    folder = REPO / "data-models" / "restaurants" / "v2" / "mvm"
    ns = load_pipeline(FakeUC())
    cfg = dict(pipeline_cfg(folder), include_metrics=True, catalog="golden_cat")
    plan = ns["build_plan"](cfg)
    digest = {k: [len(v), hashlib.sha256("\n\0".join(v).encode()).hexdigest()[:16]]
              for k, v in plan.items() if v}
    assert digest == GOLDEN_RESTAURANTS_V2_MVM
    assert plan["fk_drop"] == [] and plan["column_add"] == []


def test_an_unscoped_plan_runs_exactly_the_legacy_phases():
    ran, lines = _phases_run({"catalog": [], "schema": ["s"], "fk_drop": [], "table": ["t"],
                              "column_add": [], "fk": ["f"], "tag": ["g"], "metric": ["m"],
                              "other": []}, include_metrics=True)
    assert ran == ["schema", "table", "fk", "tag", "metric"]
    assert not any("installer-scoped-phase-order" in line for line in lines)
