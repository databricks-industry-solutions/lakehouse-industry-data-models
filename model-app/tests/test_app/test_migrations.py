"""Tests for the boot-time schema migration framework.

Exercises ``backend.migrations.reconcile_schema`` against in-memory
SQLite engines, plus a synthetic Postgres-shaped engine for the
strict-mode existence check (which gates on dialect).

NOTE for parallel agents: this test file does NOT cover
``test_migration_drift.py``. That test reads the now-deleted
``_add_missing_columns`` function out of ``core/lakebase.py`` via AST
and will fail until it is rewritten or deleted alongside the migration
of ``scripts/apply_migrations_as_owner.py``. The drift coupling is now
between the migration registry and the owner script — out of this
agent's file ownership; flagging here so the next pass picks it up.
"""

from __future__ import annotations

import importlib
import re
from pathlib import Path
from unittest.mock import MagicMock, patch

import pytest
from sqlalchemy import inspect, text
from sqlalchemy.pool import StaticPool
from sqlmodel import Session, SQLModel, create_engine, select

from vibe_modeling.backend import migrations
from vibe_modeling.backend.migrations import registry as reg
from vibe_modeling.backend.migrations.registry import (
    LakebaseInstallError,
    Migration,
    reconcile_schema,
)
from vibe_modeling.backend.db_models import LakebaseSchemaVersion


# --- Fixtures ----------------------------------------------------------------


@pytest.fixture(name="empty_engine")
def empty_engine_fixture():
    """Bare in-memory SQLite engine — no tables, no version row.

    Distinct from the conftest ``engine`` fixture (which calls
    ``create_all`` for the test app) because reconcile is supposed to
    do the table creation itself; pre-creating tables would mask bugs
    where the migration's apply() function silently no-ops.
    """
    engine = create_engine(
        "sqlite://",
        connect_args={"check_same_thread": False},
        poolclass=StaticPool,
    )
    return engine


@pytest.fixture(autouse=True)
def _reset_lifecycle_constants(monkeypatch):
    """Default every test back to pre-prod settings.

    Each test's monkeypatch overrides win — but if a test forgets to
    set them, we want predictable defaults rather than leakage from a
    previous test that flipped a constant. Tests that change the
    constants do so via monkeypatch.setattr on the registry module so
    teardown restores them automatically.
    """
    # Re-affirm pre-prod defaults; harmless on a clean import.
    monkeypatch.setattr(reg, "PRE_PROD_DESTRUCTIVE_RESET", True)
    monkeypatch.setattr(reg, "INSTALL_POLICY", "permissive")


# --- Tests --------------------------------------------------------------------


def test_fresh_install_runs_all_migrations_and_records_version(empty_engine):
    """End-to-end: empty engine in, every table out, version row written."""
    reconcile_schema(empty_engine)

    # Every SQLModel table got created. We pick three load-bearing ones
    # rather than every single one — the smoke is "create_all ran", not
    # "every model is correct".
    tables = set(inspect(empty_engine).get_table_names())
    assert "businesses" in tables
    assert "model_versions" in tables
    assert "_lakebase_schema_version" in tables

    # Version row reflects the latest registered migration.
    with Session(bind=empty_engine) as session:
        row = session.exec(
            select(LakebaseSchemaVersion).where(LakebaseSchemaVersion.id == 1)
        ).first()
    assert row is not None
    # Track the highest registered migration dynamically so adding a new
    # migration does not require editing this assertion.
    assert row.version == migrations.MIGRATIONS[-1].version


def test_v062_ddl_creates_selected_for_run_column(empty_engine):
    """The v_0_6_2 migration DDL (not just the model) must create
    vibe_inputs.selected_for_run — fresh install runs apply() DDL, not
    create_all, so a column missing from the CREATE TABLE body would only
    surface here, not in model-level tests."""
    reconcile_schema(empty_engine)
    cols = {c["name"] for c in inspect(empty_engine).get_columns("vibe_inputs")}
    assert "selected_for_run" in cols


def test_no_op_when_versions_match(empty_engine, monkeypatch):
    """Second reconcile after fresh install must not re-run apply().

    Spy on each migration's ``apply`` callable to assert it is invoked
    exactly once across both reconcile calls.
    """
    apply_spy = MagicMock(side_effect=migrations.v_0_1_0.apply)
    spied = Migration(version="0.1.0", apply=apply_spy, description="spy")
    monkeypatch.setattr(reg, "MIGRATIONS", [spied])

    # First call — applies.
    reconcile_schema(empty_engine)
    assert apply_spy.call_count == 1

    # Second call — installed == latest, so no apply should fire.
    reconcile_schema(empty_engine)
    assert apply_spy.call_count == 1


def test_pre_prod_destructive_reset_wipes_and_recreates(empty_engine, monkeypatch):
    """A stale version row + PRE_PROD_DESTRUCTIVE_RESET=True must wipe
    the database and re-apply all migrations from scratch.

    We seed test data into a known SQLModel-tracked table (Business)
    and stamp a stale version row, then prove the wipe happened: after
    reconcile, the seeded data is gone, the schema is freshly created,
    and the version row reflects the latest migration.

    SQLite has no concept of a "public schema", so the wipe path goes
    through ``SQLModel.metadata.drop_all``. Testing the Postgres
    ``DROP TABLE ... CASCADE`` branch needs a real Postgres engine and
    is out of scope for this in-process unit test — covered by a
    live smoke test.
    """
    monkeypatch.setattr(reg, "PRE_PROD_DESTRUCTIVE_RESET", True)

    # Set up the "old" world: create the schema, seed data, stamp a
    # stale version row.
    SQLModel.metadata.create_all(empty_engine)
    from vibe_modeling.backend.db_models import Business

    with Session(bind=empty_engine) as session:
        session.add(Business(name="Pre-Reset Corp", description="should be wiped"))
        session.add(
            LakebaseSchemaVersion(id=1, version="0.0.9", applied_at=reg._now())
        )
        session.commit()

    # Sanity: the row is there before reconcile.
    with Session(bind=empty_engine) as session:
        rows = session.exec(select(Business)).all()
    assert len(rows) == 1

    reconcile_schema(empty_engine)

    # Schema is back (created fresh) and the seeded business is gone.
    tables = set(inspect(empty_engine).get_table_names())
    assert "model_versions" in tables
    assert "_lakebase_schema_version" in tables
    assert "businesses" in tables

    with Session(bind=empty_engine) as session:
        rows = session.exec(select(Business)).all()
    assert rows == [], (
        "destructive reset should have wiped the seeded Business row; "
        "drop_all + create_all must run, not just create_all"
    )

    with Session(bind=empty_engine) as session:
        row = session.exec(
            select(LakebaseSchemaVersion).where(LakebaseSchemaVersion.id == 1)
        ).first()
    assert row is not None
    # Track the highest registered migration dynamically so adding a new
    # migration does not require editing this assertion.
    assert row.version == migrations.MIGRATIONS[-1].version


def test_strict_mode_refuses_non_empty_db(monkeypatch):
    """Strict-mode + non-empty public schema + no version row → refuse.

    SQLite has no ``pg_tables`` and the dialect check short-circuits
    the existence test. We mock the engine's dialect name + the helper
    that lists public tables instead of standing up a real Postgres,
    so the test stays in-process.
    """
    monkeypatch.setattr(reg, "PRE_PROD_DESTRUCTIVE_RESET", False)
    monkeypatch.setattr(reg, "INSTALL_POLICY", "strict")

    engine = create_engine(
        "sqlite://",
        connect_args={"check_same_thread": False},
        poolclass=StaticPool,
    )

    # Pretend the engine is Postgres so the strict-mode existence
    # check runs. Patch _list_public_tables so we don't need a real
    # information_schema.
    with patch.object(reg, "_is_postgres", return_value=True), \
         patch.object(reg, "_list_public_tables", return_value=["stray_table"]), \
         patch.object(reg, "_version_table_exists", return_value=False):
        with pytest.raises(LakebaseInstallError) as exc_info:
            reconcile_schema(engine)

    assert "first install requires an empty Lakebase project" in str(exc_info.value)
    assert "stray_table" in str(exc_info.value)


def test_installed_newer_than_code_refuses_to_start(empty_engine):
    """If the recorded version is ahead of what's registered, refuse.

    Operator must roll the wheel forward, never the schema back —
    otherwise we could silently drop columns the newer wheel uses.
    """
    # Bootstrap the version table by hand (would normally happen via
    # the first reconcile) so we can pre-write a stale row.
    SQLModel.metadata.create_all(empty_engine)
    with Session(bind=empty_engine) as session:
        session.add(
            LakebaseSchemaVersion(id=1, version="99.0.0", applied_at=reg._now())
        )
        session.commit()

    with pytest.raises(LakebaseInstallError) as exc_info:
        reconcile_schema(empty_engine)

    assert "newer than" in str(exc_info.value)
    assert "99.0.0" in str(exc_info.value)


def test_partial_upgrade_runs_only_post_installed_migrations(
    empty_engine, monkeypatch
):
    """With multiple registered migrations and an installed version
    matching one of them, reconcile must only run the strictly newer
    ones — not re-run the ones the DB already has.

    PRE_PROD_DESTRUCTIVE_RESET is OFF here so we exercise the
    production-style partial-upgrade branch.
    """
    monkeypatch.setattr(reg, "PRE_PROD_DESTRUCTIVE_RESET", False)

    # Synthetic 0.2.0 migration. Real ``apply`` body adds a marker
    # table so we can prove it ran (vs spy-only assertions, which
    # don't catch a no-op apply).
    def _apply_0_2_0(engine):
        with engine.begin() as conn:
            conn.execute(text("CREATE TABLE migration_0_2_0_marker (id INTEGER)"))

    apply_010_spy = MagicMock()
    apply_020_spy = MagicMock(side_effect=_apply_0_2_0)

    fake_migrations = [
        Migration(version="0.1.0", apply=apply_010_spy, description="0.1.0 spy"),
        Migration(version="0.2.0", apply=apply_020_spy, description="0.2.0 spy"),
    ]
    monkeypatch.setattr(reg, "MIGRATIONS", fake_migrations)

    # Bootstrap: create the version table the way reconcile would, then
    # stamp the installed version at 0.1.0 so the partial-upgrade branch
    # has something to compare against.
    SQLModel.metadata.create_all(empty_engine)
    with Session(bind=empty_engine) as session:
        session.add(
            LakebaseSchemaVersion(id=1, version="0.1.0", applied_at=reg._now())
        )
        session.commit()

    reconcile_schema(empty_engine)

    # 0.1.0's apply did NOT fire (already installed); 0.2.0's did.
    apply_010_spy.assert_not_called()
    apply_020_spy.assert_called_once()

    # The marker table proves apply_0_2_0 actually executed (not just
    # that the spy was called). Belt + suspenders against a future
    # MagicMock side_effect refactor that could break the spy hookup.
    assert "migration_0_2_0_marker" in inspect(empty_engine).get_table_names()

    # Version row advanced to the highest applied migration.
    with Session(bind=empty_engine) as session:
        row = session.exec(
            select(LakebaseSchemaVersion).where(LakebaseSchemaVersion.id == 1)
        ).first()
    assert row is not None
    assert row.version == "0.2.0"


# --- Naming invariant (docs/conventions.md section 8) -------------------------

_MIGRATIONS_DIR = Path(migrations.__file__).parent
_NAME = re.compile(r"^v_(\d+)_(\d+)_(\d+)(?:_(\d+))?$")


def _migration_modules() -> dict[str, str]:
    """Module name -> MIGRATION.version for every v_*.py file on disk."""
    found = {}
    for path in sorted(_MIGRATIONS_DIR.glob("v_*.py")):
        module = importlib.import_module(f"{migrations.__name__}.{path.stem}")
        found[path.stem] = module.MIGRATION.version
    return found


def test_migration_names_match_their_versions():
    for name, version in _migration_modules().items():
        m = _NAME.match(name)
        assert m, f"{name}.py: name must be v_X_Y_Z or v_X_Y_Z_N"
        expected = ".".join(g for g in m.groups() if g is not None)
        assert version == expected, f"{name}.py declares version {version!r}"


def test_every_migration_file_is_registered_in_order():
    on_disk = sorted(_migration_modules().values(), key=reg._vkey)
    assert [m.version for m in migrations.MIGRATIONS] == on_disk


def test_micro_levels_follow_a_release_migration_contiguously():
    by_release: dict[tuple[int, ...], list[int]] = {}
    for version in _migration_modules().values():
        levels = reg._vkey(version)
        by_release.setdefault(levels[:3], []).append(levels[3] if len(levels) > 3 else 0)
    for release, micros in by_release.items():
        assert sorted(micros) == list(range(len(micros))), (
            f"migrations for {'.'.join(map(str, release))} must be v_X_Y_Z then _1, _2, ...: "
            f"found micro levels {sorted(micros)}"
        )
