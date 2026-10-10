"""v5.1.4 decision 12A: the setup teardown and the deploy clash check are driven by schema ownership.

Rules under test (all runs, scoped or not):
- Dry Run never drops anything.
- A schema is owned when `_metamodel.domain` records it for a deployed (not dry_run) version of this
  business, with the catalog taken from the matching `_metamodel.business` row.
- An existing schema the run will deploy into that this business does not own is refused with a
  "SCHEMA OWNERSHIP CLASH" error that names it.
- Schemas unrelated to the model are never dropped and never refused.
- Only schemas owned by this business alone are dropped (with CASCADE), plus the base version's own
  metric views; the shared `_metrics` schema itself is never dropped.

The stub spark captures every SQL statement, so each test asserts the exact DROP list.
"""
import json
import logging
import sys
from pathlib import Path

import pytest

sys.path.insert(0, str(Path(__file__).resolve().parent))
import conftest  # noqa: F401,E402
import agent_helpers as ah  # noqa: E402
from v514_feedback_util import FakeSpark, Row, _Result  # noqa: E402

VOV = "vibe modeling of version"
NEW_BASE = "new base model"
CAT = "airlines_ecm"
MM = f"{CAT}._metamodel"
BIZ_COLS = ["business", "version", "model_scope", "catalog", "deploy_status", "model_conventions", "completed_percent"]
DOM_COLS = ["business", "version", "model_scope", "domain", "division", "description", "database_name", "catalog", "reference", "tags"]
CONVENTIONS = json.dumps({"data_asset_naming_convention": "snake_case", "schema_suffix": "", "primary_key_suffix": "_id"})
INTERNAL = ["_metamodel", "_metrics", "_install", "default", "information_schema"]


class _Log:
    def __init__(self):
        self.lines = []

    def _add(self, level, msg, *a, **k):
        self.lines.append((level, str(msg)))

    def info(self, msg, *a, **k):
        self._add("info", msg)

    def warning(self, msg, *a, **k):
        self._add("warning", msg)

    def error(self, msg, *a, **k):
        self._add("error", msg)

    def debug(self, msg, *a, **k):
        self._add("debug", msg)

    def text(self):
        return "\n".join(m for _, m in self.lines)


class _Spark(FakeSpark):
    def sql(self, sql):
        text = sql.strip()
        upper = text.upper()
        if upper.startswith("SHOW SCHEMAS IN"):
            self.statements.append(sql)
            return _Result([Row({"databaseName": s}) for s in self.schemata.get(text.split()[-1].strip("`").lower(), [])])
        if upper.startswith("DROP SCHEMA") or upper.startswith("DROP VIEW"):
            self.statements.append(sql)
            if upper.startswith("DROP SCHEMA"):
                parts = [p.strip("`").lower() for p in text.split()[4].split("`.`")]
                self.schemata[parts[0]] = [s for s in self.schemata.get(parts[0], []) if s != parts[1]]
            return _Result([])
        return super().sql(sql)

    def drops(self):
        return [s for s in self.statements if s.strip().upper().startswith("DROP")]


def _biz(business, version, status="installed", catalog=CAT, scope="mvm"):
    return {"business": business, "version": version, "model_scope": scope, "catalog": catalog,
            "deploy_status": status, "model_conventions": CONVENTIONS, "completed_percent": 100.0}


def _dom(business, version, domain, scope="mvm", catalog=None, database_name=None):
    return {"business": business, "version": version, "model_scope": scope, "domain": domain, "division": "business",
            "description": "", "database_name": database_name or domain, "catalog": catalog, "reference": "", "tags": ""}


def _spark(schemas, biz_rows, dom_rows, catalog=CAT):
    spark = _Spark(schemata={catalog: list(schemas)})
    spark.add_table(f"{MM}.business", BIZ_COLS, biz_rows)
    spark.add_table(f"{MM}.domain", DOM_COLS, dom_rows)
    return spark


def _config(style="one_catalog"):
    return {"TARGET_CATALOG": CAT, "TABLES": {"BUSINESS": f"{MM}.business", "DOMAIN": f"{MM}.domain", "PRODUCT": f"{MM}.product"},
            "CATALOGING_STYLE": style, "MODEL_SCOPE": "mvm", "SCHEMA_PREFIX": "", "SCHEMA_SUFFIX": "",
            "MODEL_CONVENTIONS": {"data_asset_naming_convention": "snake_case", "primary_key_suffix": "_id"}}


def _base_model(*domains, metric_views=("crew_utilization_metrics",)):
    return {"model": {"domains": [{"name": d, "products": []} for d in domains],
                      "metric_views": [{"view_name": v} for v in metric_views]}}


def _vov_wv(base_version="1", dry_run=False, pins=None, domains=("crew", "flight"), **extra):
    wv = {"operation": VOV, "business_name": "Airlines", "current_version": "3", "base_version_for_review": base_version,
          "model_scope": "mvm", "_dry_run": dry_run, "business_context_raw": _base_model(*domains)}
    if pins is not None:
        wv["_user_specified_domains"] = list(pins)
    wv.update(extra)
    return wv


def _history():
    """Airlines v1 (installed: crew, flight), v2 (dry run: loyalty), OtherCo v1 (installed: partner_hub, cargo)."""
    biz = [_biz("Airlines", "1"), _biz("Airlines", "2", status="dry_run"), _biz("OtherCo", "1")]
    dom = [_dom("Airlines", "1", "crew"), _dom("Airlines", "1", "flight"), _dom("Airlines", "2", "crew"),
           _dom("Airlines", "2", "flight"), _dom("Airlines", "2", "loyalty"), _dom("OtherCo", "1", "partner_hub"),
           _dom("OtherCo", "1", "cargo")]
    return biz, dom


def _stale_history():
    """_history() plus an installed Airlines v3, so a VOV on base v1 is not on the installed head and still tears down."""
    biz, dom = _history()
    return biz + [_biz("Airlines", "3")], dom + [_dom("Airlines", "3", "crew"), _dom("Airlines", "3", "flight")]


ALL_SCHEMAS = INTERNAL + ["crew", "flight", "loyalty", "partner_hub", "cargo", "team_sandbox"]


@pytest.fixture(autouse=True)
def _reset_runtime():
    ah.set_vibe_scope_runtime(None)
    yield
    ah.set_vibe_scope_runtime(None)


# ---------------------------------------------------------------- Dry Run


def test_dry_run_drops_nothing_even_when_this_business_owns_schemas():
    spark = _spark(ALL_SCHEMAS, *_history())
    log = _Log()
    ah._early_clash_detection(spark, _config(), _vov_wv(dry_run=True), log)
    assert spark.drops() == []
    assert "[staging-teardown-dry-run FIRED v5.1.4]" in log.text()


def test_dry_run_with_an_unowned_predicted_schema_warns_instead_of_refusing():
    spark = _spark(ALL_SCHEMAS, *_history())
    log = _Log()
    ah._early_clash_detection(spark, _config(), _vov_wv(base_version="2", dry_run=True, domains=("crew", "flight", "loyalty")), log)
    assert spark.drops() == []
    assert "[schema-ownership-clash FIRED v5.1.4] Dry Run" in log.text()
    assert "`airlines_ecm`.`loyalty`" in log.text()


# ---------------------------------------------------------------- unowned clash


def test_unowned_schema_of_the_base_model_refuses_and_drops_nothing():
    spark = _spark(ALL_SCHEMAS, *_history())
    with pytest.raises(ValueError) as err:
        ah._early_clash_detection(spark, _config(), _vov_wv(base_version="2", domains=("crew", "flight", "loyalty")), _Log())
    assert "SCHEMA OWNERSHIP CLASH" in str(err.value)
    assert "`airlines_ecm`.`loyalty` (no business owns it)" in str(err.value)
    assert spark.drops() == []


def test_pinned_domain_that_another_business_owns_refuses_and_names_the_owner():
    spark = _spark(ALL_SCHEMAS, *_history())
    with pytest.raises(ValueError) as err:
        ah._early_clash_detection(spark, _config(), _vov_wv(pins=["crew", "partner_hub"]), _Log())
    assert "`airlines_ecm`.`partner_hub` (owned by OtherCo)" in str(err.value)
    assert spark.drops() == []


def test_schema_shared_with_another_business_is_never_dropped_and_refused_when_targeted():
    biz, dom = _history()
    dom.append(_dom("OtherCo", "1", "flight"))
    spark = _spark(ALL_SCHEMAS, biz, dom)
    with pytest.raises(ValueError) as err:
        ah._early_clash_detection(spark, _config(), _vov_wv(), _Log())
    assert "`airlines_ecm`.`flight` (owned by OtherCo and by this business)" in str(err.value)
    assert spark.drops() == []


# ---------------------------------------------------------------- unrelated + owned


def test_a_vov_on_its_installed_head_keeps_the_owned_schemas():
    spark = _spark(ALL_SCHEMAS, *_history())
    log = _Log()
    wv = _vov_wv()
    ah._early_clash_detection(spark, _config(), wv, log)
    assert spark.drops() == [] and wv["_vov_keep_tables"] is True
    assert "[vov-keep-unchanged-tables FIRED v5.3.0] base v1 vs latest installed v1" in log.text()


def test_owned_schemas_are_dropped_and_unrelated_internal_and_foreign_schemas_are_untouched():
    spark = _spark(ALL_SCHEMAS, *_stale_history())
    log = _Log()
    ah._early_clash_detection(spark, _config(), _vov_wv(), log)
    assert "not the installed head" in log.text()
    assert spark.drops() == [
        f"DROP SCHEMA IF EXISTS `{CAT}`.`crew` CASCADE",
        f"DROP SCHEMA IF EXISTS `{CAT}`.`flight` CASCADE",
        f"DROP VIEW IF EXISTS `{CAT}`.`_metrics`.`crew_utilization_metrics`",
    ]
    assert set(spark.schemata[CAT]) == set(INTERNAL + ["loyalty", "partner_hub", "cargo", "team_sandbox"])
    assert "[vov-metrics-teardown FIRED]" in log.text() and "_metrics=1" in log.text()
    assert "untouched (unrelated or owned by another business)=['cargo', 'loyalty', 'partner_hub', 'team_sandbox']" in log.text()


def test_only_unrelated_schemas_means_no_drop_and_no_refusal():
    spark = _spark(INTERNAL + ["team_sandbox", "silver_sales"], [], [])
    ah._early_clash_detection(spark, _config(), _vov_wv(), _Log())
    assert spark.drops() == []


def test_shrink_reads_the_source_version_and_drops_only_its_owned_schemas():
    biz = [_biz("Airlines", "1", scope="ecm"), _biz("OtherCo", "1")]
    dom = [_dom("Airlines", "1", "crew", scope="ecm"), _dom("Airlines", "1", "flight", scope="ecm"), _dom("OtherCo", "1", "partner_hub")]
    spark = _spark(INTERNAL + ["crew", "flight", "partner_hub", "team_sandbox"], biz, dom)
    cfg = _config()
    wv = {"operation": "shrink ecm", "business_name": "Airlines", "current_version": "1", "source_version": "1",
          "source_model_scope": "ecm", "model_scope": "mvm", "_dry_run": False}
    ah._early_clash_detection(spark, cfg, wv, _Log())
    assert [s for s in spark.drops() if s.startswith("DROP SCHEMA")] == [
        f"DROP SCHEMA IF EXISTS `{CAT}`.`crew` CASCADE", f"DROP SCHEMA IF EXISTS `{CAT}`.`flight` CASCADE"]


def test_in_flight_version_rows_are_not_ownership_evidence():
    biz = [_biz("Airlines", "1"), _biz("Airlines", "3", status=None)]
    dom = [_dom("Airlines", "1", "crew"), _dom("Airlines", "3", "loyalty", scope=None)]
    spark = _spark(INTERNAL + ["crew", "loyalty"], biz, dom)
    snap = ah._schema_ownership_snapshot(spark, _config(), {"business_name": "Airlines", "current_version": "3"}, _Log())
    assert sorted(snap["owned"]) == [f"{CAT}.crew"]


def test_unreadable_ownership_fails_closed_no_drop_and_refusal_of_predicted_schemas():
    spark = _Spark(schemata={CAT: INTERNAL + ["crew", "flight"]})
    with pytest.raises(ValueError) as err:
        ah._early_clash_detection(spark, _config(), _vov_wv(pins=["crew"]), _Log())
    assert "ownership read failed" in str(err.value)
    assert spark.drops() == []


# ---------------------------------------------------------------- scoped runs


def test_scoped_run_drops_nothing_but_still_refuses_an_unowned_target():
    spark = _spark(ALL_SCHEMAS, *_history())
    wv = _vov_wv(pins=["crew", "team_sandbox"], _vibe_scope_spec=ah.parse_vibe_scope("Some Domains", "crew"))
    with pytest.raises(ValueError):
        ah._early_clash_detection(spark, _config(), wv, _Log())
    spark = _spark(ALL_SCHEMAS, *_history())
    log = _Log()
    ah._early_clash_detection(spark, _config(), _vov_wv(_vibe_scope_spec=ah.parse_vibe_scope("Some Domains", "crew")), log)
    assert spark.drops() == []
    assert "[vibe-scope-no-schema-drop FIRED v5.1.4]" in log.text()


# ---------------------------------------------------------------- deploy-time gate


def _clash_wv(**extra):
    wv = {"operation": VOV, "business_name": "Airlines", "model_version": "1", "current_version": "3", "model_scope": "mvm",
          "deployment_catalog": CAT, "_dry_run": False}
    wv.update(extra)
    return wv


def test_deploy_gate_refuses_a_new_domain_schema_that_exists_but_is_not_owned():
    spark = _spark(ALL_SCHEMAS, *_history())
    wv = _clash_wv()
    ah._schema_ownership_snapshot(spark, _config(), wv, _Log())
    with pytest.raises(ValueError) as err:
        ah._check_physical_deployment_clash(spark, [(CAT, "crew"), (CAT, "team_sandbox"), (CAT, "_metrics")], wv, _Log())
    assert "`airlines_ecm`.`team_sandbox` (no business owns it)" in str(err.value)
    assert "crew" not in str(err.value).split("own:")[1]


def test_deploy_gate_lets_owned_schemas_through_to_the_soft_replace_path():
    spark = _spark(ALL_SCHEMAS, *_history())
    wv = _clash_wv()
    ah._schema_ownership_snapshot(spark, _config(), wv, _Log())
    ah._check_physical_deployment_clash(spark, [(CAT, "crew"), (CAT, "flight")], wv, _Log())
    assert wv.get("_soft_replace_prior_install") is True


def test_deploy_gate_on_dry_run_warns_and_never_raises():
    spark = _spark(ALL_SCHEMAS, *_history())
    wv = _clash_wv(_dry_run=True)
    ah._schema_ownership_snapshot(spark, _config(), wv, _Log())
    log = _Log()
    ah._check_physical_deployment_clash(spark, [(CAT, "team_sandbox")], wv, log)
    assert "[schema-ownership-clash FIRED v5.1.4] Dry Run" in log.text()


def test_catalog_per_domain_subdomain_schema_in_an_owned_domain_catalog_is_owned():
    biz = [_biz("Airlines", "1")]
    dom = [_dom("Airlines", "1", "crew", catalog="cat_crew")]
    spark = _spark(INTERNAL, biz, dom)
    spark.schemata["cat_crew"] = ["crew", "crew_scheduling", "default", "information_schema"]
    snap = ah._schema_ownership_snapshot(spark, _config(style="catalog_per_domain"), _clash_wv(), _Log())
    assert ah._schema_ownership_state(snap, "cat_crew.crew_scheduling") == "owned"
    assert ah._schema_ownership_state(snap, "cat_other.crew_scheduling") == "none"


# ---------------------------------------------------------------- new base model


def _new_base_wv(**extra):
    wv = {"operation": NEW_BASE, "business_name": "Retail", "model_version": "", "current_version": "1", "model_scope": "mvm",
          "deployment_catalog": CAT, "_dry_run": False}
    wv.update(extra)
    return wv


def test_new_base_model_into_a_catalog_with_only_unrelated_schemas_is_not_refused():
    spark = _spark(INTERNAL + ["silver_sales", "silver_finance"], [], [])
    log = _Log()
    ah._early_clash_detection(spark, _config(), _new_base_wv(), log)
    assert spark.drops() == []
    assert "[schema-ownership-untouched FIRED v5.1.4]" in log.text()


def test_new_base_model_refuses_a_pinned_domain_schema_it_does_not_own():
    spark = _spark(INTERNAL + ["silver_sales", "customer"], [], [])
    with pytest.raises(ValueError) as err:
        ah._early_clash_detection(spark, _config(), _new_base_wv(_user_specified_domains=["customer", "order"]), _Log())
    assert "`airlines_ecm`.`customer` (no business owns it)" in str(err.value)
