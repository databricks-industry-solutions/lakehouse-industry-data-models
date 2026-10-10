"""v5.3.0 decision 2B: an All Domains vibe modeling of version Full Run keeps the data of tables it did not change.

Live R13 841668813173367 (All Domains, rename client -> account) dropped and recreated every table of the business:
the setup teardown dropped each owned schema before the fence existed, so both sentinel rows in performance tables
nobody named were lost. The run now keeps the owned schemas when its base is the installed head, and the deploy plan
replaces only changed tables. With the requested fence on, the facts come from the serialize gate; with it off (a vibe
that names a set or the whole model), they come from a diff of the base and the new model.json. Tables of removed
products are dropped even when their schema left the model (a renamed or merged domain), and an owned schema that is
left empty is dropped too.
"""
import copy
import sys
from pathlib import Path

import pytest

sys.path.insert(0, str(Path(__file__).resolve().parent))
import conftest  # noqa: F401,E402
import agent_helpers as ah  # noqa: E402
import test_v514_vibe_scope_parse as PS  # noqa: E402


class _Log:
    def __init__(self):
        self.lines = []

    def info(self, msg, *a, **k):
        self.lines.append(str(msg))

    warning = error = debug = info

    def text(self):
        return "\n".join(self.lines)


class _Rows:
    def __init__(self, rows):
        self.rows = rows

    def collect(self):
        return list(self.rows)


class _Spark:
    def __init__(self, tables=None):
        self.statements = []
        self.tables = {k.lower(): set(v) for k, v in (tables or {}).items()}

    def sql(self, sql):
        text = " ".join(str(sql).split())
        self.statements.append(text)
        upper = text.upper()
        if upper.startswith("SHOW TABLES IN"):
            key = text.split()[3].replace("`", "").lower()
            return _Rows([("db", t, False) for t in sorted(self.tables.get(key, set()))])
        if upper.startswith("DROP TABLE IF EXISTS"):
            parts = text.split()[4].replace("`", "").lower().split(".")
            self.tables.get(".".join(parts[:2]), set()).discard(parts[2])
        return _Rows([])

    def drops(self):
        return [s for s in self.statements if s.upper().startswith("DROP")]


@pytest.fixture(autouse=True)
def _isolate():
    ah.set_vibe_scope_runtime(None)
    ah.vov_ledger_reset()
    yield
    ah.set_vibe_scope_runtime(None)
    ah.vov_ledger_reset()


def _product(model, domain, name):
    return next(p for d in model["model"]["domains"] if d["name"] == domain for p in d["products"] if p["name"] == name)


def _changed_model():
    new = copy.deepcopy(PS.RAW)
    _product(new, "flight", "scheduled_flight")["description"] = "rewritten by the vibe"
    crew = next(d for d in new["model"]["domains"] if d["name"] == "crew")
    crew["products"] = [p for p in crew["products"] if p["name"] != "absence"]
    crew["products"].append({"name": "crew_shift", "primary_key": "crew_shift_id", "attributes": [{"name": "crew_shift_id", "type": "BIGINT"}]})
    aircraft = _product(new, "fleet", "aircraft")
    next(a for a in aircraft["attributes"] if a["name"] == aircraft["primary_key"])["is_primary_key"] = True
    return new


def _facts(new=None):
    return ah._vov_unfenced_deploy_facts((new or _changed_model())["model"], {"business_context_raw": copy.deepcopy(PS.RAW)}, _Log())


def test_unfenced_facts_replace_only_what_changed_against_the_base():
    facts = _facts()
    assert "flight.scheduled_flight" in facts["changed_in_scope_products"] and "crew.crew_shift" in facts["changed_in_scope_products"]
    assert "fleet.aircraft" in facts["preserved_products"], "a working field model.json never stores is not a change"
    assert facts["removed_products"] == ["crew.absence"]
    assert len(facts["changed_in_scope_products"]) == 2


def test_an_untouched_model_keeps_every_table():
    facts = _facts(copy.deepcopy(PS.RAW))
    assert facts["changed_in_scope_products"] == [] and facts["removed_products"] == []


def test_the_deploy_preflight_hands_the_unfenced_facts_to_the_plan():
    facts = _facts()
    assert ah._vibe_scope_deploy_preflight({"_vov_unfenced_facts": facts}, _Log()) is facts
    assert ah._vibe_scope_deploy_preflight({}, _Log()) is None
    plan = ah._scope_deploy_plan(facts, _changed_model()["model"], _Log())
    assert plan.state("flight", "scheduled_flight") == "replace" and plan.state("fleet", "aircraft") == "preserve"
    assert plan.oracle is None


def test_removed_tables_without_a_fence_come_from_the_base_model():
    plan = ah._scope_deploy_plan(_facts(), _changed_model()["model"], _Log())
    resolver = ah.CatalogResolver(style="one_catalog", base_catalog="cat")
    removed = ah._vibe_scope_removed_tables(None, plan, resolver, copy.deepcopy(PS.RAW))
    assert [info["key"] for info in removed.values()] == [(ah._vov285_san("crew"), ah._vov285_san("absence"))]


def test_removed_metric_views_without_a_fence_are_dropped():
    spark = _Spark()
    final = _changed_model()
    final["model"]["metric_views"] = [mv for mv in final["model"]["metric_views"] if mv["view_name"] != "crew_absence"]
    dropped = ah._vibe_scope_drop_removed_metric_views(spark, "cat", None, final, _Log(), base_model=copy.deepcopy(PS.RAW))
    assert dropped == ["crew_absence"] and spark.drops() == ["DROP VIEW IF EXISTS `cat`.`_metrics`.`crew_absence`"]


def _renamed_domain():
    new = copy.deepcopy(PS.RAW)
    assert ah._v337_apply_rename_domain(new["model"], "crew", "crew_ops") is not None
    return new


def _schemas(model, resolver):
    return {".".join(str(x).lower() for x in resolver.resolve_full(d, p)) for d in model["model"]["domains"] for p in (d["products"] or [None])}


def test_a_renamed_domain_drops_its_old_tables_and_the_emptied_schema():
    new = _renamed_domain()
    resolver = ah.CatalogResolver(style="one_catalog", base_catalog="cat")
    plan = ah._scope_deploy_plan(_facts(new), new["model"], _Log())
    crew_tables = {p.get("table_name") or p["name"] for p in next(d for d in PS.RAW["model"]["domains"] if d["name"] == "crew")["products"]}
    spark = _Spark({"cat.crew": crew_tables})
    log = _Log()
    wv = {"_schema_ownership": {"owned": {"cat.crew": ["v1"], "cat.flight": ["v1"]}}}
    tables, schemas = ah._vibe_scope_drop_removed_elsewhere(spark, plan, resolver, copy.deepcopy(PS.RAW), new, _schemas(new, resolver), wv, log)
    assert len(tables) == len(crew_tables) and all(t.startswith("cat.crew.") for t in tables)
    assert schemas == ["cat.crew"] and "DROP SCHEMA IF EXISTS `cat`.`crew`" in spark.drops()
    assert "[vibe-scope-removed-schema FIRED v5.3.0]" in log.text()


def test_a_schema_the_business_does_not_own_or_that_still_holds_a_table_is_kept():
    new = _renamed_domain()
    resolver = ah.CatalogResolver(style="one_catalog", base_catalog="cat")
    plan = ah._scope_deploy_plan(_facts(new), new["model"], _Log())
    crew_tables = {p.get("table_name") or p["name"] for p in next(d for d in PS.RAW["model"]["domains"] if d["name"] == "crew")["products"]}
    spark = _Spark({"cat.crew": crew_tables})
    assert ah._vibe_scope_drop_removed_elsewhere(spark, plan, resolver, copy.deepcopy(PS.RAW), new, _schemas(new, resolver),
                                                 {"_schema_ownership": {"owned": {}}}, _Log()) == ([], [])
    assert spark.drops() == []
    spark = _Spark({"cat.crew": crew_tables | {"team_extract"}})
    _tables, schemas = ah._vibe_scope_drop_removed_elsewhere(spark, plan, resolver, copy.deepcopy(PS.RAW), new, _schemas(new, resolver),
                                                             {"_schema_ownership": {"owned": {"cat.crew": ["v1"]}}}, _Log())
    assert schemas == [] and not any(s.startswith("DROP SCHEMA") for s in spark.drops())
