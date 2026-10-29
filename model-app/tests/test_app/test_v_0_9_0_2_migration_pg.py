"""Real Postgres checks for ``v_0_9_0_2``: the run-tags server default and the install default.

Run by ``scripts/smoke/run_pg_branch_test.sh tests/test_app/test_v_0_9_0_2_migration_pg.py
V0902_PG_DATABASE`` on an ephemeral Lakebase branch; skipped unless ``V0902_PG_DATABASE`` is set.
Three new, empty databases on the branch (``<name>``, ``<name>_upgrade``, ``<name>_optout``), so
the cloned production data is never read or written:

- **fresh install**: ``reconcile_schema`` runs every migration; ``agent_config`` stays empty
  (the app creates the row later) and its column defaults to true;
- **upgrade**: a 0.9.0.1-shaped ``agent_config`` (column default false, a row set false), version
  row at 0.9.0.1, ``VIBE_MODELING_RUN_TAGS_DEFAULT`` unset; ``reconcile_schema`` on the registry
  cut at ``v_0_9_0_2`` turns the row on and the default to true; a second ``apply`` changes nothing;
- **opt-out upgrade**: the same with ``VIBE_MODELING_RUN_TAGS_DEFAULT=false`` and a row set true;
  the row ends false and the default is still true.

On all three a raw insert that leaves the column out reads true.
"""
from __future__ import annotations

import os
import sys
import uuid

import pytest
from sqlalchemy import text
from sqlmodel import SQLModel

sys.path.insert(0, os.path.dirname(__file__))

DATABASE = os.environ.get("V0902_PG_DATABASE", "")
pytestmark = pytest.mark.skipif(not DATABASE, reason="needs a Lakebase branch (set V0902_PG_DATABASE)")

from _pg_branch import fresh_database_engine  # noqa: E402

from vibe_modeling.backend import db_models  # noqa: E402,F401 - registers tables on metadata
from vibe_modeling.backend.migrations import MIGRATIONS, registry as reg  # noqa: E402
from vibe_modeling.backend.migrations.v_0_9_0_2 import MIGRATION, RUN_TAGS_ENV, apply  # noqa: E402

UP_TO_THIS = [m for m in MIGRATIONS if reg._vkey(m.version) <= reg._vkey(MIGRATION.version)]
_OLD_DEFAULT = "ALTER TABLE agent_config ALTER COLUMN collect_vibe_run_statistics SET DEFAULT false"


def _rows(engine) -> dict[str, bool]:
    with engine.connect() as conn:
        return dict(conn.execute(text("SELECT id, collect_vibe_run_statistics FROM agent_config")).fetchall())


def _column_default(engine) -> str:
    with engine.connect() as conn:
        return conn.execute(text(
            "SELECT column_default FROM information_schema.columns WHERE table_schema = current_schema() "
            "AND table_name = 'agent_config' AND column_name = 'collect_vibe_run_statistics'")).scalar()


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
            row[col.name] = datetime(2026, 10, 23, tzinfo=timezone.utc)
        elif isinstance(col.type, (Integer, Boolean)):
            row[col.name] = 0
        else:
            row[col.name] = ""
    conn.execute(insert(table).values(**row))


def _raw_insert_reads(engine) -> bool:
    row_id = f"raw-{uuid.uuid4()}"
    with engine.begin() as conn:
        _insert(conn, row_id)
        value = conn.execute(text("SELECT collect_vibe_run_statistics FROM agent_config WHERE id = :id"),
                             {"id": row_id}).scalar()
        conn.execute(text("DELETE FROM agent_config WHERE id = :id"), {"id": row_id})
    return value


def _upgraded(name: str, *, env: str | None, row_value: bool):
    engine = fresh_database_engine(name)
    SQLModel.metadata.create_all(engine)
    with engine.begin() as conn:
        conn.execute(text(_OLD_DEFAULT))
        _insert(conn, "cfg", collect_vibe_run_statistics=row_value)
    reg._write_installed_version(engine, "0.9.0.1")
    with pytest.MonkeyPatch.context() as mp:
        if env is None:
            mp.delenv(RUN_TAGS_ENV, raising=False)
        else:
            mp.setenv(RUN_TAGS_ENV, env)
        mp.setattr(reg, "PRE_PROD_DESTRUCTIVE_RESET", False)
        mp.setattr(reg, "MIGRATIONS", UP_TO_THIS)
        reg.reconcile_schema(engine)
        apply(engine)
    return engine


@pytest.fixture(scope="module")
def fresh_install():
    with pytest.MonkeyPatch.context() as mp:
        mp.delenv(RUN_TAGS_ENV, raising=False)
        engine = fresh_database_engine(DATABASE)
        reg.reconcile_schema(engine)
    yield engine
    engine.dispose()


@pytest.fixture(scope="module")
def upgraded():
    engine = _upgraded(f"{DATABASE}_upgrade", env=None, row_value=False)
    yield engine
    engine.dispose()


@pytest.fixture(scope="module")
def opted_out():
    engine = _upgraded(f"{DATABASE}_optout", env="false", row_value=True)
    yield engine
    engine.dispose()


@pytest.fixture(params=["fresh_install", "upgraded", "opted_out"])
def pg(request):
    return request.getfixturevalue(request.param)


def test_fresh_install_is_at_the_head_with_no_row(fresh_install):
    assert reg._read_installed_version(fresh_install) == MIGRATIONS[-1].version
    assert _rows(fresh_install) == {}


def test_upgrade_turns_the_row_on(upgraded):
    assert reg._read_installed_version(upgraded) == MIGRATION.version
    assert _rows(upgraded) == {"cfg": True}


def test_opt_out_upgrade_turns_the_row_off(opted_out):
    assert reg._read_installed_version(opted_out) == MIGRATION.version
    assert _rows(opted_out) == {"cfg": False}


def test_column_default_is_true(pg):
    assert _column_default(pg) == "true"


def test_raw_insert_without_the_column_reads_true(pg):
    assert _raw_insert_reads(pg) is True
