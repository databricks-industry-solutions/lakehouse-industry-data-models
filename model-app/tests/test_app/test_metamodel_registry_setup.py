"""``metamodel_registry.ensure_metamodel_registry`` creates the agent's registry.

The agent's ``_ensure_metamodel_registry`` (vendored 5.3.3 notebook, flat
lines 51728-51745) creates ``<catalog>._metamodel``, ``vol_root`` and the
four registry tables, then adds ``_METAMODEL_BUSINESS_MIGRATION_COLUMNS``
(flat lines 51691-51695) that ``business`` lacks. The app does the same for a
catalog the agent never ran in. Runs on the recording UC fake, whose SQL side
executes the registry DDL against its stored tables.
"""
from __future__ import annotations

import re

import pytest
from databricks.sdk.errors import PermissionDenied

from vibe_modeling.backend.services.metamodel_registry import ensure_metamodel_registry, registry_schema
from vibe_modeling.backend.services.metamodel_setup import MetamodelSetupError

from ._drift.fake_uc import REGISTRY_TABLES, FakeUC, agent_registry_columns

CAT = "registry_cat"
WH = "wh-registry"
DB = f"`{CAT}`.`_metamodel`"


def _ddl(fake: FakeUC) -> list[str]:
    return [c.args["statement"] for c in fake.calls_to("sql.ddl")]


def _creates(fake: FakeUC) -> list[str]:
    return [c.seam for c in fake.calls if c.seam.endswith(".create")]


def _agent_create_statement(table: str) -> str:
    """The agent's CREATE for ``table``, columns as ``_ensure_metamodel_registry``
    spells them (business with the migration columns its ALTERs add)."""
    cols = ", ".join(f"`{c}` {t}" for c, t in agent_registry_columns(table))
    return f"CREATE TABLE IF NOT EXISTS {DB}.`{table}` ({cols})"


class TestFreshCatalog:
    def test_creates_schema_volume_and_the_four_tables_with_the_agents_columns(self):
        fake = FakeUC()
        fake.add_catalog(CAT)

        created = ensure_metamodel_registry(fake.ws, CAT, WH)

        assert _creates(fake) == ["schemas.create", "volumes.create"]
        assert _ddl(fake) == [_agent_create_statement(t) for t in REGISTRY_TABLES]
        for table in REGISTRY_TABLES:
            assert fake.columns(CAT, table) == agent_registry_columns(table)
        assert created == [
            f"schema {CAT}._metamodel", f"managed volume {CAT}._metamodel.vol_root",
            *(f"table {CAT}._metamodel.{t}" for t in REGISTRY_TABLES),
        ]
        fake.assert_no_unrecorded_sql()

    def test_business_ends_with_deploy_status_like_the_agents_create_then_alter(self):
        fake = FakeUC()
        fake.add_catalog(CAT)
        ensure_metamodel_registry(fake.ws, CAT, WH)
        base = [c for c, _ in registry_schema().tables["business"]]
        assert [c for c, _ in fake.columns(CAT, "business")] == base + ["deploy_status"]

    def test_no_warehouse_sets_up_only_the_schema_and_volume(self):
        fake = FakeUC()
        fake.add_catalog(CAT)
        ensure_metamodel_registry(fake.ws, CAT, "")
        assert _creates(fake) == ["schemas.create", "volumes.create"]
        assert _ddl(fake) == []
        assert fake.columns(CAT, "business") is None


class TestExistingRegistry:
    def test_agent_tables_are_left_alone_and_no_sql_runs(self):
        fake = FakeUC()
        fake.add_metamodel(CAT)

        assert ensure_metamodel_registry(fake.ws, CAT, WH) == []

        assert _creates(fake) == []
        assert _ddl(fake) == []
        assert sorted(c.args["full_name"] for c in fake.calls_to("tables.get")) == sorted(
            f"{CAT}._metamodel.{t}" for t in REGISTRY_TABLES
        )
        fake.assert_no_unrecorded_sql()

    def test_business_missing_a_migration_column_gets_only_that_column(self):
        fake = FakeUC()
        fake.add_metamodel(CAT, drop_business_columns=("deploy_status", "results_json"))

        created = ensure_metamodel_registry(fake.ws, CAT, WH)

        assert _ddl(fake) == [
            f"ALTER TABLE {DB}.`business` ADD COLUMN `results_json` STRING",
            f"ALTER TABLE {DB}.`business` ADD COLUMN `deploy_status` STRING",
        ]
        assert {c for c, _ in fake.columns(CAT, "business")} >= {"results_json", "deploy_status"}
        assert created == [
            f"column {CAT}._metamodel.business.results_json",
            f"column {CAT}._metamodel.business.deploy_status",
        ]

    def test_one_missing_table_is_created_and_the_others_untouched(self):
        fake = FakeUC()
        fake.add_metamodel(CAT)
        del fake._registry[CAT]["attribute"]
        del fake._columns[CAT]["attribute"]

        ensure_metamodel_registry(fake.ws, CAT, WH)

        assert _ddl(fake) == [_agent_create_statement("attribute")]

    def test_an_unreadable_business_gets_the_idempotent_create_then_describe(self, monkeypatch):
        fake = FakeUC()
        fake.add_metamodel(CAT, drop_business_columns=("deploy_status",))
        real_get = fake.ws.tables.get

        def get(full_name, **kw):
            if full_name.endswith(".business"):
                raise PermissionDenied("no SELECT")
            return real_get(full_name, **kw)

        monkeypatch.setattr(fake.ws.tables, "get", get)

        ensure_metamodel_registry(fake.ws, CAT, WH)

        base = ", ".join(f"`{c}` {t}" for c, t in registry_schema().tables["business"])
        assert _ddl(fake) == [
            f"CREATE TABLE IF NOT EXISTS {DB}.`business` ({base})",
            f"DESCRIBE TABLE {DB}.`business`",
            f"ALTER TABLE {DB}.`business` ADD COLUMN `deploy_status` STRING",
        ]


class TestRefusals:
    def test_failed_ddl_refuses_with_the_fixed_message_and_creates_no_table(self):
        fake = FakeUC()
        fake.add_catalog(CAT)
        fake.ddl_error = "[INSUFFICIENT_PERMISSIONS] User does not have CREATE TABLE on Schema 'x'"

        with pytest.raises(MetamodelSetupError) as refused:
            ensure_metamodel_registry(fake.ws, CAT, WH)

        assert refused.value.step == "tables"
        assert "CREATE_TABLE" in str(refused.value)
        assert "INSUFFICIENT_PERMISSIONS" not in str(refused.value)
        assert all(fake.columns(CAT, t) is None for t in REGISTRY_TABLES)

    def test_a_missing_catalog_refuses_before_any_sql(self):
        fake = FakeUC()

        with pytest.raises(MetamodelSetupError) as refused:
            ensure_metamodel_registry(fake.ws, CAT, WH)

        assert refused.value.step == "schema"
        assert _ddl(fake) == []

    def test_a_catalog_that_is_not_a_plain_identifier_never_reaches_sql(self):
        fake = FakeUC()
        fake.add_catalog("bad-name")

        with pytest.raises(MetamodelSetupError) as refused:
            ensure_metamodel_registry(fake.ws, "bad-name", WH)

        assert refused.value.step == "tables"
        assert str(refused.value) == (
            "The catalog name 'bad-name' isn't a plain identifier (letters, digits, underscores); "
            "the app can't write the agent's registry there."
        )
        assert _ddl(fake) == []
        assert _creates(fake) == []

    def test_a_spent_bound_runs_no_ddl(self):
        fake = FakeUC()
        fake.add_catalog(CAT)

        with pytest.raises(MetamodelSetupError):
            ensure_metamodel_registry(fake.ws, CAT, WH, timeout_s=0.0)

        assert _ddl(fake) == []


def test_every_statement_quotes_its_identifiers():
    fake = FakeUC()
    fake.add_catalog(CAT)
    ensure_metamodel_registry(fake.ws, CAT, WH)
    for statement in _ddl(fake):
        cols = re.search(r"\((.*)\)$", statement).group(1)
        assert all(re.fullmatch(r"`\w+` [A-Z]+", part) for part in cols.split(", ")), statement
