"""Real Postgres checks for the ``v_0_9_0`` FK columns and their ON DELETE SET NULL.

Run by ``scripts/smoke/run_pg_branch_test.sh tests/test_app/test_v_0_9_0_migration_pg.py
V090_PG_DATABASE`` on an ephemeral Lakebase branch; skipped unless ``V090_PG_DATABASE`` is set.
Two new, empty databases on the branch (``<name>`` and ``<name>_upgrade``), so the cloned
production data is never read or written:

- **fresh install**: ``reconcile_schema`` runs every migration; the FKs come from ``db_models``
  via ``create_all`` (``promoted_by_run_id`` as a ``use_alter`` constraint, since
  ``model_versions`` and ``runs`` reference each other);
- **upgrade**: a 0.8.0-shaped schema with the version row at 0.8.0, then ``reconcile_schema``
  applies ``v_0_9_0`` (then the later migrations), whose ``ADD COLUMN IF NOT EXISTS ...
  REFERENCES ... ON DELETE SET NULL`` adds the FKs; a second ``apply`` is a no-op.

On both: each FK exists with delete action SET NULL, its column is indexed, deleting the parent
NULLs the child column and keeps the row (``replaced_at`` survives), and the two new tables
cascade with their run.
"""
from __future__ import annotations

import os
import sys
from datetime import datetime, timezone

import pytest
from sqlalchemy import text
from sqlmodel import Session

sys.path.insert(0, os.path.dirname(__file__))

DATABASE = os.environ.get("V090_PG_DATABASE", "")
pytestmark = pytest.mark.skipif(not DATABASE, reason="needs a Lakebase branch (set V090_PG_DATABASE)")

from _pg_branch import fresh_database_engine  # noqa: E402
from test_v_0_9_0_migration import _metadata_at_0_8_0  # noqa: E402

from vibe_modeling.backend import db_models as db  # noqa: E402
from vibe_modeling.backend.migrations import MIGRATIONS, registry as reg  # noqa: E402
from vibe_modeling.backend.migrations.v_0_9_0 import FK_INDEX_COLUMNS, NEW_TABLES, SET_NULL_FKS, apply  # noqa: E402


@pytest.fixture(scope="module")
def fresh_install():
    engine = fresh_database_engine(DATABASE)
    reg.reconcile_schema(engine)
    yield engine
    engine.dispose()


@pytest.fixture(scope="module")
def upgraded():
    engine = fresh_database_engine(f"{DATABASE}_upgrade")
    _metadata_at_0_8_0().create_all(engine)
    reg._write_installed_version(engine, "0.8.0")
    with pytest.MonkeyPatch.context() as mp:
        mp.setattr(reg, "PRE_PROD_DESTRUCTIVE_RESET", False)
        reg.reconcile_schema(engine)
    apply(engine)
    yield engine
    engine.dispose()


@pytest.fixture(params=["fresh_install", "upgraded"])
def pg(request):
    return request.getfixturevalue(request.param)


def test_schema_is_at_the_head(pg):
    assert reg._read_installed_version(pg) == MIGRATIONS[-1].version


@pytest.mark.parametrize("child,column,parent", SET_NULL_FKS)
def test_fk_exists_with_set_null(pg, child, column, parent):
    with pg.connect() as conn:
        rows = conn.execute(text(
            """
            SELECT con.confdeltype, ref.relname
            FROM pg_constraint con
            JOIN pg_class rel ON rel.oid = con.conrelid
            JOIN pg_class ref ON ref.oid = con.confrelid
            JOIN pg_attribute att ON att.attrelid = con.conrelid AND att.attnum = ANY (con.conkey)
            WHERE con.contype = 'f' AND rel.relname = :child AND att.attname = :column
              AND array_length(con.conkey, 1) = 1
            """
        ), {"child": child, "column": column}).fetchall()
    assert [(r[0], r[1]) for r in rows] == [("n", parent)]  # 'n' = SET NULL


@pytest.mark.parametrize("table,column", FK_INDEX_COLUMNS)
def test_fk_column_is_indexed(pg, table, column):
    with pg.connect() as conn:
        names = {r[0] for r in conn.execute(
            text("SELECT indexname FROM pg_indexes WHERE tablename = :t"), {"t": table})}
    assert f"ix_{table}_{column}" in names


def test_deleting_parents_nulls_the_columns_and_keeps_the_rows(pg):
    now = datetime.now(timezone.utc)
    with Session(pg) as s:
        biz = db.Business(name=f"PG SetNull {now.timestamp()}")
        s.add(biz)
        s.flush()
        run = db.Run(business_id=biz.id, intent="install model")
        replacer = db.ModelVersion(business_id=biz.id, version=3, scope="ecm")
        s.add_all([run, replacer])
        s.flush()
        replaced = db.ModelVersion(business_id=biz.id, version=5, scope="ecm", promoted_by_run_id=run.id,
                                   replaced_by_version_id=replacer.id, replaced_at=now)
        vi = db.VibeInput(business_id=biz.id, consumed=True, consumed_by_run_id=run.id)
        s.add_all([replaced, vi,
                   db.RunAgentReport(run_id=run.id, expected_version=5),
                   db.RunPostInstallDelete(run_id=run.id, version_id="gone", version=4, scope="ecm")])
        s.commit()
        ids = (run.id, replacer.id, replaced.id, vi.id)

    run_id, replacer_id, replaced_id, vi_id = ids
    with pg.begin() as conn:
        conn.execute(text("DELETE FROM runs WHERE id = :id"), {"id": run_id})
        conn.execute(text("DELETE FROM model_versions WHERE id = :id"), {"id": replacer_id})

    with Session(pg) as s:
        mv = s.get(db.ModelVersion, replaced_id)
        assert mv is not None
        assert mv.promoted_by_run_id is None and mv.replaced_by_version_id is None
        assert mv.replaced_at is not None
        got = s.get(db.VibeInput, vi_id)
        assert got is not None and got.consumed_by_run_id is None
    with pg.connect() as conn:
        left = [conn.execute(text(f"SELECT COUNT(*) FROM {t} WHERE run_id = :r"), {"r": run_id}).scalar()
                for t in NEW_TABLES]
    assert left == [0, 0]
