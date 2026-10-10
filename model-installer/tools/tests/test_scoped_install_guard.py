"""A model.json with a root `_vibe_scope` block installs only when the target catalog's
latest installed version equals its `base_version`, read from
`<catalog>._metamodel.business` (`deploy_status` 'installed', or NULL for legacy rows)
and from the installs this installer recorded. A catalog holding none of the model's
schemas is a fresh install and takes the artifact in full.
"""
import json

import pytest

from installer_harness import (REGISTRY_COLUMNS, FakeRegistry, load_handoff, redirect_volumes,
                               registry_row, run_main_cell)

CFG = {"catalog": "demo"}
PLAN = {"schema": ["CREATE DATABASE IF NOT EXISTS `demo`.`crew` COMMENT 'Crew'",
                   "CREATE DATABASE IF NOT EXISTS `demo`.`flight` COMMENT 'Flights'"]}
USED = {"demo": {"crew", "flight", "_install", "default"}}


def scoped_model(**overrides):
    model = {"source": "/Volumes/demo/_metamodel/vol_root/business/airlines/v2/mvm/model.json",
             "path": "/Volumes/demo/_metamodel/vol_root/business/airlines/v2/mvm/model.json",
             "bytes": b"{}", "business": "Airlines", "version": 2, "scope": "mvm",
             "vibe_scope": {"mode": "domains", "entries": ["crew"], "base_version": "1",
                            "operation": "vibe modeling of version"}}
    model.update(overrides)
    return model


def guard(spark, model, catalogs=("demo",), plan=PLAN):
    ns = load_handoff(spark, catalogs=catalogs)
    return ns["guard_scoped_install"](dict(CFG), plan, model), ns


def refused(spark, model, catalogs=("demo",)):
    with pytest.raises(Exception, match="Scoped install refused") as err:
        guard(spark, model, catalogs)
    return str(err.value)


# ------------------------------------------------------------------ unscoped is untouched

@pytest.mark.parametrize("block", [None, {}, ""])
def test_a_model_json_without_a_vibe_scope_block_is_not_checked(block):
    spark = FakeRegistry(USED, REGISTRY_COLUMNS, [registry_row(7)])
    result, _ = guard(spark, scoped_model(vibe_scope=block))
    assert result is None
    assert spark.queries == [], "an unscoped install must not probe the catalog at all"


def test_an_install_without_a_model_json_is_not_checked():
    spark = FakeRegistry(USED, REGISTRY_COLUMNS, [registry_row(7)])
    assert guard(spark, None)[0] is None
    assert spark.queries == []


# ------------------------------------------------------------------ the base must match

def test_a_scoped_artifact_on_a_newer_installed_version_is_refused():
    spark = FakeRegistry(USED, REGISTRY_COLUMNS, [registry_row(1), registry_row(2)])
    message = refused(spark, scoped_model())
    assert "base v1" in message and "latest installed version in `demo` is v2" in message
    assert "crew" in message, "the refusal must say which of the model's schemas are there"


def test_a_scoped_artifact_on_an_older_installed_version_is_refused():
    spark = FakeRegistry(USED, REGISTRY_COLUMNS, [registry_row(1)])
    message = refused(spark, scoped_model(vibe_scope={"base_version": "3"}))
    assert "base v3" in message and "is v1" in message


def test_a_scoped_artifact_on_its_base_installs():
    spark = FakeRegistry(USED, REGISTRY_COLUMNS, [registry_row(1)])
    result, ns = guard(spark, scoped_model())
    assert result == 1
    assert any("[installer-scope-precondition FIRED] base v1" in line for line in ns["_log_lines"])


def test_the_base_version_may_be_written_as_v1_or_as_a_number():
    for base in ("v1", 1, "1.0"):
        spark = FakeRegistry(USED, REGISTRY_COLUMNS, [registry_row(1)])
        assert guard(spark, scoped_model(vibe_scope={"base_version": base}))[0] == 1


# ------------------------------------------------------------------ what counts as installed

def test_a_dry_run_version_is_not_an_installed_version():
    rows = [registry_row(1), registry_row(2, deploy_status="dry_run")]
    message = refused(FakeRegistry(USED, REGISTRY_COLUMNS, rows),
                      scoped_model(vibe_scope={"base_version": "2"}))
    assert "is v1" in message
    assert guard(FakeRegistry(USED, REGISTRY_COLUMNS, rows), scoped_model())[0] == 1


def test_a_legacy_row_with_a_null_deploy_status_counts_as_installed():
    rows = [registry_row(1, deploy_status=None)]
    assert guard(FakeRegistry(USED, REGISTRY_COLUMNS, rows), scoped_model())[0] == 1


def test_a_registry_from_before_deploy_status_counts_every_completed_row():
    columns = [c for c in REGISTRY_COLUMNS if c != "deploy_status"]
    rows = [dict((k, v) for k, v in registry_row(n).items() if k != "deploy_status")
            for n in (1, 2)]
    spark = FakeRegistry(USED, columns, rows)
    assert guard(spark, scoped_model(vibe_scope={"base_version": "2"}))[0] == 2
    assert not any("deploy_status" in q for q in spark.queries)


def test_a_failed_run_that_registered_no_domains_is_not_an_installed_version():
    rows = [registry_row(1), registry_row(2, deploy_status=None)]
    spark = FakeRegistry(USED, REGISTRY_COLUMNS, rows, domain_rows=[registry_row(1)])
    result, ns = guard(spark, scoped_model())
    assert result == 1
    assert any("[installer-unregistered-skip FIRED] 'Airlines' (mvm) versions ['2']" in line
               for line in ns["_log_lines"])


def test_a_registry_with_no_registered_domains_has_no_installed_version():
    spark = FakeRegistry(USED, REGISTRY_COLUMNS, [registry_row(1)], domain_rows=[])
    assert "not recorded" in refused(spark, scoped_model())


def test_a_registry_without_a_domain_table_has_no_installed_version():
    spark = FakeRegistry(USED, REGISTRY_COLUMNS, [registry_row(1)], domain_columns=())
    assert "not recorded" in refused(spark, scoped_model())
    assert not any("`domain` WHERE" in q for q in spark.queries)


def test_an_incomplete_run_is_not_an_installed_version():
    rows = [registry_row(1), registry_row(2, completed_percent=40.0)]
    assert guard(FakeRegistry(USED, REGISTRY_COLUMNS, rows), scoped_model())[0] == 1


def test_a_version_deployed_to_another_catalog_does_not_count():
    rows = [registry_row(1), registry_row(2, catalog="prod_catalog")]
    assert guard(FakeRegistry(USED, REGISTRY_COLUMNS, rows), scoped_model())[0] == 1


def test_only_the_same_model_scope_counts_and_a_legacy_null_scope_does():
    rows = [registry_row(1, model_scope=None), registry_row(4, model_scope="ecm")]
    assert guard(FakeRegistry(USED, REGISTRY_COLUMNS, rows), scoped_model())[0] == 1


def test_the_business_name_matches_case_insensitively():
    rows = [registry_row(1, business="AIRLINES")]
    assert guard(FakeRegistry(USED, REGISTRY_COLUMNS, rows),
                 scoped_model(business="airlines"))[0] == 1


def test_another_business_in_the_same_registry_does_not_count():
    rows = [registry_row(1, business="Banking")]
    assert "not recorded" in refused(FakeRegistry(USED, REGISTRY_COLUMNS, rows), scoped_model())


def test_a_version_this_installer_installed_counts(tmp_path, monkeypatch):
    """v2 is a dry run the installer deployed, so only its manifest says it is installed."""
    to_real = redirect_volumes(monkeypatch, tmp_path)
    manifest = to_real("/Volumes/demo/_install/logs/manifest_mvm_mvm.json")
    manifest.parent.mkdir(parents=True)
    manifest.write_text(json.dumps({"catalogs": [], "schemas": [], "model_registration": {
        "business": "Airlines", "version": 2, "scope": "mvm",
        "path": "/Volumes/demo/_metamodel/vol_root/business/airlines/v2/mvm/model.json"}}))
    rows = [registry_row(1), registry_row(2, deploy_status="dry_run")]
    result, ns = guard(FakeRegistry(USED, REGISTRY_COLUMNS, rows),
                       scoped_model(version=3, vibe_scope={"base_version": "2"}))
    assert result == 2
    assert any("manifest_mvm_mvm.json" in line for line in ns["_log_lines"])
    assert "is v2" in refused(FakeRegistry(USED, REGISTRY_COLUMNS, rows), scoped_model())


def test_model_schemas_with_no_recorded_version_are_refused():
    message = refused(FakeRegistry(USED), scoped_model())
    assert "not recorded in `demo`.`_metamodel`.business or in any installer manifest" in message


# ------------------------------------------------------------------ fresh installs

def test_a_catalog_holding_none_of_the_model_schemas_takes_the_artifact_in_full():
    spark = FakeRegistry({"demo": {"_install", "default", "unrelated"}}, REGISTRY_COLUMNS,
                         [registry_row(9)])
    result, ns = guard(spark, scoped_model())
    assert result is None
    assert not any("_metamodel" in q for q in spark.queries), "fresh needs no registry lookup"
    assert any("fresh install" in line for line in ns["_log_lines"])


def test_a_catalog_that_does_not_exist_yet_is_a_fresh_install():
    spark = FakeRegistry({})
    assert guard(spark, scoped_model(), catalogs=())[0] is None
    assert spark.queries == []


def test_a_kept_table_counts_even_when_its_schema_is_not_recreated_by_the_plan():
    plan = {"schema": ["CREATE DATABASE IF NOT EXISTS `demo`.`crew`"],
            "table": ["CREATE TABLE IF NOT EXISTS `demo`.`flight`.`leg` (leg_id BIGINT)",
                      "CREATE OR REPLACE TABLE `demo`.`crew`.`member` (member_id BIGINT)"]}
    spark = FakeRegistry({"demo": {"flight", "_install"}}, REGISTRY_COLUMNS, [registry_row(2)])
    with pytest.raises(Exception, match=r"Scoped install refused.*demo\.flight"):
        guard(spark, scoped_model(), plan=plan)


def test_schema_names_compare_case_insensitively():
    plan = {"schema": ["CREATE DATABASE IF NOT EXISTS `demo`.`Crew`"]}
    spark = FakeRegistry({"demo": {"crew"}}, REGISTRY_COLUMNS, [registry_row(2)])
    with pytest.raises(Exception, match="Scoped install refused"):
        guard(spark, scoped_model(), plan=plan)


def test_a_failed_schema_probe_refuses_instead_of_assuming_a_fresh_catalog():
    spark = FakeRegistry(USED, fail_on=["information_schema.schemata"])
    with pytest.raises(RuntimeError, match="simulated failure"):
        guard(spark, scoped_model())


# ------------------------------------------------------------------ malformed blocks

def test_a_vibe_scope_block_without_a_base_version_is_refused_on_a_used_catalog():
    message = refused(FakeRegistry(USED, REGISTRY_COLUMNS, [registry_row(1)]),
                      scoped_model(vibe_scope={"mode": "domains", "entries": ["crew"]}))
    assert "without a base_version" in message


def test_a_vibe_scope_block_without_a_base_version_still_installs_fresh():
    spark = FakeRegistry({"demo": {"_install"}})
    assert guard(spark, scoped_model(vibe_scope={"mode": "domains"}))[0] is None


def test_a_scoped_new_base_model_needs_no_base_version():
    spark = FakeRegistry(USED, REGISTRY_COLUMNS, [registry_row(4)])
    result, ns = guard(spark, scoped_model(vibe_scope={"mode": "domains",
                                                       "operation": "new base model"}))
    assert result is None
    assert spark.queries == []
    assert any("scoped new base model" in line for line in ns["_log_lines"])


def test_a_scoped_model_json_without_a_business_name_is_refused():
    message = refused(FakeRegistry(USED, REGISTRY_COLUMNS, [registry_row(1)]),
                      scoped_model(business=""))
    assert "names no model_requirements.business_name" in message


def test_a_business_name_with_a_quote_is_escaped_in_the_lookup():
    rows = [registry_row(1, business="O'Hare Air")]
    assert guard(FakeRegistry(USED, REGISTRY_COLUMNS, rows),
                 scoped_model(business="O'Hare Air"))[0] == 1


# ------------------------------------------------------------------ wiring in main()

def test_main_guards_the_built_plan_before_any_install_ddl():
    calls = {}
    run_main_cell({"enabled": False, "rows": 10}, calls=calls)
    order = calls["order"]
    assert order.index("load_model_json") < order.index("guard_scoped_install") \
        < order.index("install")
    assert calls["args"]["guard_scoped_install"][1] == {"table": ["CREATE TABLE t"]}


def test_a_refusal_stops_main_before_the_install_and_the_manifest():
    def refuse(cfg, plan, model):
        raise Exception("Scoped install refused: test")

    calls = {}
    with pytest.raises(Exception, match="Scoped install refused"):
        run_main_cell({"enabled": False, "rows": 10}, calls=calls,
                      hooks={"guard_scoped_install": refuse})
    assert "install" not in calls["order"]
    assert "write_install_manifest" not in calls["order"]
