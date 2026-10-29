"""``v_0_9_0_3`` at SQLite level: ``agent_config.runtime_budget_hours``.

The column is added with default 6 when missing, an existing row reads 6, a
re-run and a table that already has the column change nothing, and a missing
table is a no-op. The real Postgres path is in ``test_v_0_9_0_3_migration_pg.py``.
"""

from __future__ import annotations

from sqlalchemy import create_engine, inspect, text
from sqlalchemy.pool import StaticPool
from sqlmodel import Session, SQLModel

from vibe_modeling.backend import db_models as db
from vibe_modeling.backend import migrations as runtime_migrations
from vibe_modeling.backend.migrations import registry as reg
from vibe_modeling.backend.migrations.v_0_9_0_3 import MIGRATION, apply

# A 0.9.0.2-shaped agent_config, cut to the columns this test reads.
_OLD_AGENT_CONFIG = "CREATE TABLE agent_config (id VARCHAR PRIMARY KEY, notebook_path VARCHAR NOT NULL)"


def _sqlite():
    return create_engine("sqlite://", connect_args={"check_same_thread": False}, poolclass=StaticPool)


def _engine_at_0_9_0_2(*row_ids: str):
    engine = _sqlite()
    with engine.begin() as conn:
        conn.execute(text(_OLD_AGENT_CONFIG))
        for row_id in row_ids:
            conn.execute(text("INSERT INTO agent_config (id, notebook_path) VALUES (:id, '/nb')"), {"id": row_id})
    SQLModel.metadata.create_all(engine, tables=[SQLModel.metadata.tables["_lakebase_schema_version"]])
    reg._write_installed_version(engine, "0.9.0.2")
    return engine


def _values(engine) -> dict[str, int]:
    with engine.connect() as conn:
        return dict(conn.execute(text("SELECT id, runtime_budget_hours FROM agent_config")).fetchall())


def _column(engine) -> dict:
    (col,) = [c for c in inspect(engine).get_columns("agent_config") if c["name"] == "runtime_budget_hours"]
    return col


def test_adds_the_column_and_an_existing_row_reads_6():
    engine = _engine_at_0_9_0_2("cfg")
    apply(engine)
    assert _values(engine) == {"cfg": 6}
    col = _column(engine)
    assert col["nullable"] is False
    assert str(col["default"]).strip("'") == "6"


def test_a_raw_insert_without_the_column_reads_6():
    engine = _engine_at_0_9_0_2()
    apply(engine)
    with engine.begin() as conn:
        conn.execute(text("INSERT INTO agent_config (id, notebook_path) VALUES ('raw', '/nb')"))
    assert _values(engine) == {"raw": 6}


def test_a_second_apply_changes_nothing():
    engine = _engine_at_0_9_0_2("cfg")
    apply(engine)
    with engine.begin() as conn:
        conn.execute(text("UPDATE agent_config SET runtime_budget_hours = 12"))
    apply(engine)
    assert _values(engine) == {"cfg": 12}


def test_a_table_that_has_the_column_is_left_alone():
    engine = _sqlite()
    SQLModel.metadata.create_all(engine)
    with Session(engine) as session:
        session.add(db.AgentConfig(id="cfg", runtime_budget_hours=20))
        session.commit()
    apply(engine)
    assert _values(engine) == {"cfg": 20}


def test_missing_table_is_a_no_op():
    engine = _sqlite()
    apply(engine)
    assert not inspect(engine).has_table("agent_config")


def test_registered_right_after_0_9_0_2():
    versions = [m.version for m in runtime_migrations.MIGRATIONS]
    at = versions.index("0.9.0.3")
    assert versions[at - 1] == "0.9.0.2"
    assert runtime_migrations.MIGRATIONS[at] is MIGRATION


def test_upgrade_from_0_9_0_2_through_the_registry(monkeypatch):
    monkeypatch.setattr(reg, "PRE_PROD_DESTRUCTIVE_RESET", False)
    up_to_this = [m for m in runtime_migrations.MIGRATIONS if reg._vkey(m.version) <= reg._vkey(MIGRATION.version)]
    monkeypatch.setattr(reg, "MIGRATIONS", up_to_this)
    engine = _engine_at_0_9_0_2("cfg")
    reg.reconcile_schema(engine)
    assert reg._read_installed_version(engine) == "0.9.0.3"
    assert _values(engine) == {"cfg": 6}


def test_create_all_gives_a_fresh_install_the_same_server_default():
    from .test_db_models import TestBooleanServerDefaults

    engine = _sqlite()
    SQLModel.metadata.create_all(engine)
    with engine.begin() as conn:
        TestBooleanServerDefaults._raw_insert_omitting(conn, "agent_config", "runtime_budget_hours", "raw")
    assert _values(engine) == {"raw": 6}
