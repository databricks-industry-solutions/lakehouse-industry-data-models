"""``v_0_9_0_4`` at SQLite level: the two ``model_versions`` import-prefix columns.

Both columns are added, nullable, when missing; an existing row reads NULL; a
re-run and a table that already has them change nothing; a missing table is a
no-op. The real Postgres path is in ``test_v_0_9_0_4_migration_pg.py``.
"""

from __future__ import annotations

from sqlalchemy import create_engine, inspect, text
from sqlalchemy.pool import StaticPool
from sqlmodel import SQLModel

from vibe_modeling.backend import migrations as runtime_migrations
from vibe_modeling.backend.migrations import registry as reg
from vibe_modeling.backend.migrations.v_0_9_0_4 import MIGRATION, NEW_COLUMNS, apply

# A 0.9.0.3-shaped model_versions, cut to the columns this test reads.
_OLD_MODEL_VERSIONS = "CREATE TABLE model_versions (id VARCHAR PRIMARY KEY, version INTEGER NOT NULL)"
_COLUMNS = ("import_schema_prefix_added", "import_view_prefix_added")


def _sqlite():
    return create_engine("sqlite://", connect_args={"check_same_thread": False}, poolclass=StaticPool)


def _engine_at_0_9_0_3(*row_ids: str):
    engine = _sqlite()
    with engine.begin() as conn:
        conn.execute(text(_OLD_MODEL_VERSIONS))
        for row_id in row_ids:
            conn.execute(text("INSERT INTO model_versions (id, version) VALUES (:id, 1)"), {"id": row_id})
    SQLModel.metadata.create_all(engine, tables=[SQLModel.metadata.tables["_lakebase_schema_version"]])
    reg._write_installed_version(engine, "0.9.0.3")
    return engine


def _rows(engine) -> dict:
    with engine.connect() as conn:
        return {
            r[0]: (r[1], r[2])
            for r in conn.execute(text(
                "SELECT id, import_schema_prefix_added, import_view_prefix_added FROM model_versions"
            )).fetchall()
        }


def test_adds_both_columns_nullable_and_an_existing_row_reads_null():
    engine = _engine_at_0_9_0_3("mv")
    apply(engine)
    cols = {c["name"]: c for c in inspect(engine).get_columns("model_versions")}
    for name in _COLUMNS:
        assert cols[name]["nullable"] is True
    assert _rows(engine) == {"mv": (None, None)}


def test_a_second_apply_keeps_saved_values():
    engine = _engine_at_0_9_0_3("mv")
    apply(engine)
    with engine.begin() as conn:
        conn.execute(text("UPDATE model_versions SET import_schema_prefix_added = 'ecm_', import_view_prefix_added = ''"))
    apply(engine)
    assert _rows(engine) == {"mv": ("ecm_", "")}


def test_a_table_that_has_the_columns_is_left_alone():
    engine = _sqlite()
    SQLModel.metadata.create_all(engine)
    before = [c["name"] for c in inspect(engine).get_columns("model_versions")]
    apply(engine)
    assert [c["name"] for c in inspect(engine).get_columns("model_versions")] == before


def test_missing_table_is_a_no_op():
    engine = _sqlite()
    apply(engine)
    assert not inspect(engine).has_table("model_versions")


def test_the_ddl_names_exactly_the_two_columns():
    assert set(NEW_COLUMNS) == set(_COLUMNS)


def test_registered_right_after_0_9_0_3():
    versions = [m.version for m in runtime_migrations.MIGRATIONS]
    at = versions.index("0.9.0.4")
    assert versions[at - 1] == "0.9.0.3"
    assert runtime_migrations.MIGRATIONS[at] is MIGRATION


def test_upgrade_from_0_9_0_3_through_the_registry(monkeypatch):
    monkeypatch.setattr(reg, "PRE_PROD_DESTRUCTIVE_RESET", False)
    up_to_this = [m for m in runtime_migrations.MIGRATIONS if reg._vkey(m.version) <= reg._vkey(MIGRATION.version)]
    monkeypatch.setattr(reg, "MIGRATIONS", up_to_this)
    engine = _engine_at_0_9_0_3("mv")
    reg.reconcile_schema(engine)
    assert reg._read_installed_version(engine) == "0.9.0.4"
    assert _rows(engine) == {"mv": (None, None)}
