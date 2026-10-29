"""Real Postgres checks for ``v_0_9_0_3``: ``agent_config.runtime_budget_hours``.

Run by ``scripts/smoke/run_pg_branch_test.sh tests/test_app/test_v_0_9_0_3_migration_pg.py
V0903_PG_DATABASE`` on an ephemeral Lakebase branch; skipped unless ``V0903_PG_DATABASE`` is set.
Two new, empty databases on the branch (``<name>`` and ``<name>_upgrade``), so the cloned
production data is never read or written:

- **fresh install**: ``reconcile_schema`` runs every migration; the column exists, NOT NULL,
  default 6;
- **upgrade**: a 0.9.0.2-shaped ``agent_config`` (the column dropped) with a row, version row at
  0.9.0.2; ``reconcile_schema`` on the registry cut at ``v_0_9_0_3`` adds the column and the row
  reads 6; a second ``apply`` changes nothing and keeps a saved value.

On both a raw insert that leaves the column out reads 6.
"""
from __future__ import annotations

import os
import sys
import uuid

import pytest
from sqlalchemy import text
from sqlmodel import SQLModel

sys.path.insert(0, os.path.dirname(__file__))

DATABASE = os.environ.get("V0903_PG_DATABASE", "")
pytestmark = pytest.mark.skipif(not DATABASE, reason="needs a Lakebase branch (set V0903_PG_DATABASE)")

from _pg_branch import fresh_database_engine  # noqa: E402

from vibe_modeling.backend import db_models  # noqa: E402,F401 - registers tables on metadata
from vibe_modeling.backend.migrations import MIGRATIONS, registry as reg  # noqa: E402
from vibe_modeling.backend.migrations.v_0_9_0_3 import MIGRATION, apply  # noqa: E402

UP_TO_THIS = [m for m in MIGRATIONS if reg._vkey(m.version) <= reg._vkey(MIGRATION.version)]
_DROP_COLUMN = "ALTER TABLE agent_config DROP COLUMN runtime_budget_hours"


def _rows(engine) -> dict[str, int]:
    with engine.connect() as conn:
        return dict(conn.execute(text("SELECT id, runtime_budget_hours FROM agent_config")).fetchall())


def _column(engine) -> tuple[str, str]:
    with engine.connect() as conn:
        return tuple(conn.execute(text(
            "SELECT is_nullable, column_default FROM information_schema.columns "
            "WHERE table_schema = current_schema() AND table_name = 'agent_config' "
            "AND column_name = 'runtime_budget_hours'")).one())


def _insert(conn, row_id: str, **values) -> None:
    """Insert an ``agent_config`` row with every other NOT NULL column filled, so a column
    left out of ``values`` takes its server default."""
    from datetime import datetime, timezone

    from sqlalchemy import Boolean, DateTime, Integer, insert

    table = SQLModel.metadata.tables["agent_config"]
    row = {"id": row_id, **values}
    for col in table.columns:
        if col.name in row or col.nullable or col.server_default is not None:
            continue
        if isinstance(col.type, DateTime):
            row[col.name] = datetime(2026, 10, 25, tzinfo=timezone.utc)
        elif isinstance(col.type, (Integer, Boolean)):
            row[col.name] = 0
        else:
            row[col.name] = ""
    conn.execute(insert(table).values(**row))


def _raw_insert_reads(engine) -> int:
    row_id = f"raw-{uuid.uuid4()}"
    with engine.begin() as conn:
        _insert(conn, row_id)
        value = conn.execute(text("SELECT runtime_budget_hours FROM agent_config WHERE id = :id"),
                             {"id": row_id}).scalar()
        conn.execute(text("DELETE FROM agent_config WHERE id = :id"), {"id": row_id})
    return value


@pytest.fixture(scope="module")
def fresh_install():
    engine = fresh_database_engine(DATABASE)
    reg.reconcile_schema(engine)
    yield engine
    engine.dispose()


@pytest.fixture(scope="module")
def upgraded():
    engine = fresh_database_engine(f"{DATABASE}_upgrade")
    SQLModel.metadata.create_all(engine)
    with engine.begin() as conn:
        conn.execute(text(_DROP_COLUMN))
        _insert(conn, "cfg")
    reg._write_installed_version(engine, "0.9.0.2")
    with pytest.MonkeyPatch.context() as mp:
        mp.setattr(reg, "PRE_PROD_DESTRUCTIVE_RESET", False)
        mp.setattr(reg, "MIGRATIONS", UP_TO_THIS)
        reg.reconcile_schema(engine)
    yield engine
    engine.dispose()


@pytest.fixture(params=["fresh_install", "upgraded"])
def pg(request):
    return request.getfixturevalue(request.param)


def test_fresh_install_is_at_the_head(fresh_install):
    assert reg._read_installed_version(fresh_install) == MIGRATIONS[-1].version


def test_upgrade_adds_the_column_and_the_row_reads_6(upgraded):
    assert reg._read_installed_version(upgraded) == MIGRATION.version
    assert _rows(upgraded) == {"cfg": 6}


def test_a_second_apply_keeps_a_saved_value(upgraded):
    with upgraded.begin() as conn:
        conn.execute(text("UPDATE agent_config SET runtime_budget_hours = 12 WHERE id = 'cfg'"))
    apply(upgraded)
    assert _rows(upgraded) == {"cfg": 12}


def test_column_is_not_null_with_default_6(pg):
    assert _column(pg) == ("NO", "6")


def test_raw_insert_without_the_column_reads_6(pg):
    assert _raw_insert_reads(pg) == 6
