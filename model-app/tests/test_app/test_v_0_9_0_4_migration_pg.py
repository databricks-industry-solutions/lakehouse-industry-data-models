"""Real Postgres checks for ``v_0_9_0_4``: the ``model_versions`` import-prefix columns.

Run by ``scripts/smoke/run_pg_branch_test.sh tests/test_app/test_v_0_9_0_4_migration_pg.py
V0904_PG_DATABASE`` on an ephemeral Lakebase branch; skipped unless ``V0904_PG_DATABASE`` is set.
Two new, empty databases on the branch (``<name>`` and ``<name>_upgrade``), so the cloned
production data is never read or written:

- **fresh install**: ``reconcile_schema`` runs every migration; both columns exist, nullable;
- **upgrade**: a 0.9.0.3-shaped ``model_versions`` (both columns dropped) with a row, version
  row at 0.9.0.3; ``reconcile_schema`` on the registry cut at ``v_0_9_0_4`` adds them, the row
  reads NULL; a second ``apply`` changes nothing and keeps saved values.
"""
from __future__ import annotations

import os
import sys

import pytest
from sqlalchemy import text
from sqlmodel import SQLModel

sys.path.insert(0, os.path.dirname(__file__))

DATABASE = os.environ.get("V0904_PG_DATABASE", "")
pytestmark = pytest.mark.skipif(not DATABASE, reason="needs a Lakebase branch (set V0904_PG_DATABASE)")

from _pg_branch import fresh_database_engine  # noqa: E402

from vibe_modeling.backend import db_models  # noqa: E402,F401 - registers tables on metadata
from vibe_modeling.backend.migrations import MIGRATIONS, registry as reg  # noqa: E402
from vibe_modeling.backend.migrations.v_0_9_0_4 import MIGRATION, apply  # noqa: E402

UP_TO_THIS = [m for m in MIGRATIONS if reg._vkey(m.version) <= reg._vkey(MIGRATION.version)]
_COLUMNS = ("import_schema_prefix_added", "import_view_prefix_added")


def _insert(conn, row_id: str) -> None:
    """Insert a business and a ``model_versions`` row with every other NOT NULL column filled."""
    from datetime import datetime, timezone

    from sqlalchemy import Boolean, DateTime, Integer, insert

    def _row(table_name: str, **values):
        table = SQLModel.metadata.tables[table_name]
        row = dict(values)
        for col in table.columns:
            if col.name in row or col.nullable or col.server_default is not None:
                continue
            if isinstance(col.type, DateTime):
                row[col.name] = datetime(2026, 10, 27, tzinfo=timezone.utc)
            elif isinstance(col.type, (Integer, Boolean)):
                row[col.name] = 1
            else:
                row[col.name] = f"{table_name}-{col.name}"
        conn.execute(insert(table).values(**row))

    _row("businesses", id="biz", name=f"biz-{row_id}")
    _row("model_versions", id=row_id, business_id="biz", scope="ecm")


def _columns(engine) -> dict[str, str]:
    with engine.connect() as conn:
        return dict(conn.execute(text(
            "SELECT column_name, is_nullable FROM information_schema.columns "
            "WHERE table_schema = current_schema() AND table_name = 'model_versions' "
            "AND column_name IN ('import_schema_prefix_added', 'import_view_prefix_added')")).fetchall())


def _values(engine, row_id: str) -> tuple:
    with engine.connect() as conn:
        return tuple(conn.execute(text(
            "SELECT import_schema_prefix_added, import_view_prefix_added FROM model_versions WHERE id = :id"),
            {"id": row_id}).one())


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
        for column in _COLUMNS:
            conn.execute(text(f"ALTER TABLE model_versions DROP COLUMN {column}"))
        _insert(conn, "mv")
    reg._write_installed_version(engine, "0.9.0.3")
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


def test_both_columns_are_nullable(pg):
    assert _columns(pg) == {column: "YES" for column in _COLUMNS}


def test_upgrade_adds_the_columns_and_the_row_reads_null(upgraded):
    assert reg._read_installed_version(upgraded) == MIGRATION.version
    assert _values(upgraded, "mv") == (None, None)


def test_a_second_apply_keeps_saved_values(upgraded):
    with upgraded.begin() as conn:
        conn.execute(text(
            "UPDATE model_versions SET import_schema_prefix_added = 'ecm_', "
            "import_view_prefix_added = '' WHERE id = 'mv'"))
    apply(upgraded)
    assert _values(upgraded, "mv") == ("ecm_", "")
