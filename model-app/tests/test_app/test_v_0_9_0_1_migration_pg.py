"""Real Postgres checks for ``v_0_9_0_1``: new tables, their FKs and indexes, the install-row
backfill and the industry dedup.

Run by ``scripts/smoke/run_pg_branch_test.sh tests/test_app/test_v_0_9_0_1_migration_pg.py
V0901_PG_DATABASE`` on an ephemeral Lakebase branch; skipped unless ``V0901_PG_DATABASE`` is set.
Two new, empty databases on the branch (``<name>`` and ``<name>_upgrade``), so the cloned
production data is never read or written:

- **fresh install**: ``reconcile_schema`` runs every migration; the new tables come from
  ``db_models`` via ``create_all``;
- **upgrade**: a 0.9.0-shaped schema with the version row at 0.9.0 and seeded versions and
  industries, then ``reconcile_schema`` applies only ``v_0_9_0_1`` (``ADD COLUMN IF NOT EXISTS``,
  the tables, the typed ``INSERT ... SELECT ... WHERE NOT EXISTS`` backfill, the dedup updates);
  a second ``apply`` changes nothing.

The upgrade runs on the registry cut at ``v_0_9_0_1``. On both: the four new columns exist and
are nullable, each new FK has its ON DELETE action, the partial unique index carries its
``WHERE uninstalled_at IS NULL`` predicate and refuses a second open row, and deleting a run
or version applies the actions. On the upgrade: the backfilled install rows and the dedup.
"""
from __future__ import annotations

import os
import sys
from datetime import datetime, timezone

import pytest
from sqlalchemy import text
from sqlalchemy.exc import IntegrityError
from sqlmodel import Session

sys.path.insert(0, os.path.dirname(__file__))

DATABASE = os.environ.get("V0901_PG_DATABASE", "")
pytestmark = pytest.mark.skipif(not DATABASE, reason="needs a Lakebase branch (set V0901_PG_DATABASE)")

from _pg_branch import fresh_database_engine  # noqa: E402
from test_v_0_9_0_migration import metadata_without  # noqa: E402

from vibe_modeling.backend import db_models as db  # noqa: E402
from vibe_modeling.backend.migrations import MIGRATIONS, registry as reg  # noqa: E402
from vibe_modeling.backend.migrations.v_0_9_0_1 import MIGRATION, NEW_COLUMNS, NEW_TABLES, apply  # noqa: E402

# The upgrade runs on the registry cut at this migration, so a later migration does not change it.
UP_TO_THIS = [m for m in MIGRATIONS if reg._vkey(m.version) <= reg._vkey(MIGRATION.version)]

FK_ACTIONS = {  # (child, column) -> (parent, pg confdeltype)
    ("model_version_installs", "version_id"): ("model_versions", "c"),
    ("model_version_installs", "installed_by_run_id"): ("runs", "n"),
    ("model_version_installs", "uninstalled_by_run_id"): ("runs", "n"),
    ("run_schema_drops", "run_id"): ("runs", "c"),
    ("run_change_decisions", "run_id"): ("runs", "c"),
    ("run_change_decisions", "version_id"): ("model_versions", "c"),
    ("run_change_decisions", "feedback_input_id"): ("vibe_inputs", "n"),
    ("taxonomy_wizard_states", "sector_id"): ("sectors", "n"),
}


def _seed_upgrade_data(engine) -> None:
    """0.9.0-era rows through plain SQL (the 0.9.0 shape has no v_0_9_0_1 columns)."""
    with engine.begin() as conn:
        for ind_id, name, short, auto in (
            ("cur_util", "Energy - Utilities", "Utilities", False),
            ("auto_util", "energy-utilities", "energy-utilities", True),
            ("stub_util", "Utilities", "utilities", True),
        ):
            conn.execute(text(
                "INSERT INTO industries (id, name, short_name, description, notable_businesses, display_order, "
                "is_active, is_auto_created, created_at, updated_at) VALUES (:id, :n, :s, '', '', 0, true, :a, "
                "now(), now())"), {"id": ind_id, "n": name, "s": short, "a": auto})
        for bid, name, industry in (("b1", "Grid Co", "auto_util"), ("b2", "utilities", "stub_util")):
            conn.execute(text(
                "INSERT INTO businesses (id, name, description, business_vibes, industry_alignment, industry_id, "
                "kind, business_domains, org_divisions, created_at, updated_at) VALUES (:id, :n, '', '', '', :i, "
                "'business', '', '', now(), now())"), {"id": bid, "n": name, "i": industry})
        for vid, n, deployment, uc in (("v_dep", 1, "deployed", "cat_a"), ("v_uninst", 2, "uninstalled", "cat_b"),
                                       ("v_draft", 3, "draft", "cat_c")):
            conn.execute(text(
                "INSERT INTO model_versions (id, business_id, version, status, deployment_status, vibe_instructions, "
                "scope, uc_catalog, sync_state, dry_run, created_at) VALUES (:id, 'b1', :n, 'completed', :d, '', "
                "'ecm', :uc, 'ok', false, TIMESTAMP '2026-10-01 08:00:00')"),
                {"id": vid, "n": n, "d": deployment, "uc": uc})


@pytest.fixture(scope="module")
def fresh_install():
    engine = fresh_database_engine(DATABASE)
    reg.reconcile_schema(engine)
    yield engine
    engine.dispose()


@pytest.fixture(scope="module")
def upgraded():
    engine = fresh_database_engine(f"{DATABASE}_upgrade")
    metadata_without(NEW_COLUMNS, NEW_TABLES).create_all(engine)
    reg._write_installed_version(engine, "0.9.0")
    _seed_upgrade_data(engine)
    with pytest.MonkeyPatch.context() as mp:
        mp.setattr(reg, "PRE_PROD_DESTRUCTIVE_RESET", False)
        mp.setattr(reg, "MIGRATIONS", UP_TO_THIS)
        reg.reconcile_schema(engine)
    apply(engine)
    yield engine
    engine.dispose()


@pytest.fixture(params=["fresh_install", "upgraded"])
def pg(request):
    return request.getfixturevalue(request.param)


def test_fresh_install_is_at_the_head(fresh_install):
    assert reg._read_installed_version(fresh_install) == MIGRATIONS[-1].version


def test_upgrade_is_at_this_migration(upgraded):
    assert reg._read_installed_version(upgraded) == MIGRATION.version


def test_new_columns_exist_and_are_nullable(pg):
    with pg.connect() as conn:
        got = {
            (r[0], r[1]): (r[2], r[3])
            for r in conn.execute(text(
                "SELECT table_name, column_name, data_type, is_nullable FROM information_schema.columns "
                "WHERE table_schema = current_schema() AND table_name IN ('runs', 'agent_config')")).fetchall()
        }
    expected = {
        ("runs", "linked_at"): "timestamp without time zone",
        ("runs", "link_evidence"): "character varying",
        ("agent_config", "taxonomy_updated_by"): "character varying",
        ("agent_config", "taxonomy_updated_at"): "timestamp without time zone",
    }
    assert set(expected) == set(NEW_COLUMNS)
    assert {key: got.get(key) for key in expected} == {key: (dtype, "YES") for key, dtype in expected.items()}


@pytest.mark.parametrize("child,column", sorted(FK_ACTIONS))
def test_fk_exists_with_its_action(pg, child, column):
    with pg.connect() as conn:
        rows = conn.execute(text(
            """
            SELECT con.confdeltype, ref.relname
            FROM pg_constraint con
            JOIN pg_class rel ON rel.oid = con.conrelid
            JOIN pg_class ref ON ref.oid = con.confrelid
            JOIN pg_attribute att ON att.attrelid = con.conrelid AND att.attnum = ANY (con.conkey)
            WHERE con.contype = 'f' AND rel.relname = :child AND att.attname = :column
            """
        ), {"child": child, "column": column}).fetchall()
    parent, action = FK_ACTIONS[(child, column)]
    assert [(r[0], r[1]) for r in rows] == [(action, parent)]


def test_indexes(pg):
    with pg.connect() as conn:
        defs = dict(conn.execute(text(
            "SELECT indexname, indexdef FROM pg_indexes WHERE tablename IN "
            "('model_version_installs', 'metamodel_cleanups')")).fetchall())
    assert "UNIQUE" in defs["uq_model_version_installs_open"]
    assert "WHERE (uninstalled_at IS NULL)" in defs["uq_model_version_installs_open"]
    assert "(business_segment, scope, catalog, status)" in defs["ix_metamodel_cleanups_lookup"]


def test_one_open_row_per_version_and_catalog_and_on_delete(pg):
    now = datetime.now(timezone.utc)
    with Session(pg) as s:
        biz = db.Business(name=f"PG installs {now.timestamp()}")
        s.add(biz)
        s.flush()
        run = db.Run(business_id=biz.id, intent="install model")
        mv = db.ModelVersion(business_id=biz.id, version=7, scope="ecm")
        s.add_all([run, mv])
        s.flush()
        s.add_all([
            db.ModelVersionInstall(version_id=mv.id, catalog="cat_x", installed_by_run_id=run.id,
                                   uninstalled_at=now),
            db.ModelVersionInstall(version_id=mv.id, catalog="cat_x", installed_by_run_id=run.id),
            db.RunSchemaDrop(run_id=run.id, catalog="cat_x", schema_name="ecm_s"),
            db.RunChangeDecision(run_id=run.id, version_id=mv.id, element_kind="domain", element_path="sales",
                                 change_kind="added", decision="accepted"),
        ])
        s.commit()
        s.add(db.ModelVersionInstall(version_id=mv.id, catalog="cat_x"))
        with pytest.raises(IntegrityError):
            s.commit()
        s.rollback()
        run_id, mv_id = run.id, mv.id

    with pg.begin() as conn:
        conn.execute(text("DELETE FROM runs WHERE id = :id"), {"id": run_id})
        left = conn.execute(text(
            "SELECT count(*), count(installed_by_run_id) FROM model_version_installs WHERE version_id = :v"),
            {"v": mv_id}).one()
        assert tuple(left) == (2, 0)
        for table in ("run_schema_drops", "run_change_decisions"):
            assert conn.execute(text(f"SELECT count(*) FROM {table} WHERE run_id = :r"), {"r": run_id}).scalar() == 0
        conn.execute(text("DELETE FROM model_versions WHERE id = :id"), {"id": mv_id})
        assert conn.execute(text("SELECT count(*) FROM model_version_installs WHERE version_id = :v"),
                            {"v": mv_id}).scalar() == 0


def test_upgrade_backfilled_install_rows(upgraded):
    with upgraded.connect() as conn:
        rows = conn.execute(text(
            "SELECT version_id, catalog, installed_at, uninstalled_at IS NOT NULL FROM model_version_installs "
            "WHERE version_id IN ('v_dep', 'v_uninst', 'v_draft') ORDER BY version_id")).fetchall()
    assert [(r[0], r[1], r[3]) for r in rows] == [("v_dep", "cat_a", False), ("v_uninst", "cat_b", True)]
    assert rows[0][2] == datetime(2026, 10, 1, 8, 0)


def test_upgrade_dedup(upgraded):
    with upgraded.connect() as conn:
        businesses = dict(conn.execute(text(
            "SELECT id, industry_id FROM businesses WHERE id IN ('b1', 'b2')")).fetchall())
        active = dict(conn.execute(text("SELECT id, is_active FROM industries")).fetchall())
    assert businesses == {"b1": "cur_util", "b2": "stub_util"}
    assert active == {"cur_util": True, "auto_util": False, "stub_util": True}


def test_rerun_changes_nothing(upgraded):
    def snapshot():
        with upgraded.connect() as conn:
            return (
                sorted(conn.execute(text("SELECT id, version_id, catalog FROM model_version_installs")).fetchall()),
                sorted(conn.execute(text("SELECT id, industry_id FROM businesses")).fetchall()),
                sorted(conn.execute(text("SELECT id, is_active FROM industries")).fetchall()),
            )

    before = snapshot()
    apply(upgraded)
    assert snapshot() == before
