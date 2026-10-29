"""Tests for the ``v_0_9_0`` migration (lifecycle columns, report tables, backfills).

SQLite level: the columns land with their defaults on existing rows, the
three FK columns carry ON DELETE SET NULL and an index, the two tables are
created, re-runs and partially applied states converge, and both backfills
select exactly the rows the design names. A full 0.8.0-shaped database
upgrades through ``reconcile_schema`` in one step and ends with the same
columns as a fresh ``create_all``. The real Postgres path (inline
``REFERENCES`` on ``ADD COLUMN IF NOT EXISTS``, SET NULL on delete) is in
``test_v_0_9_0_migration_pg.py``.
"""

from __future__ import annotations

import json

from sqlalchemy import MetaData, Table, UniqueConstraint, create_engine, event, inspect, text
from sqlalchemy.pool import StaticPool
from sqlmodel import Session, SQLModel

from vibe_modeling.backend import db_models  # noqa: F401 - registers tables on metadata
from vibe_modeling.backend import migrations as runtime_migrations
from vibe_modeling.backend.migrations import registry as reg
from vibe_modeling.backend.migrations import v_0_9_0_1
from vibe_modeling.backend.migrations.v_0_9_0 import (
    FK_INDEX_COLUMNS,
    MIGRATION,
    NEW_COLUMNS,
    NEW_TABLES,
    SET_NULL_FKS,
    apply,
)

def _fresh_engine(*, foreign_keys: bool = False):
    engine = create_engine("sqlite://", connect_args={"check_same_thread": False}, poolclass=StaticPool)
    if foreign_keys:
        @event.listens_for(engine, "connect")
        def _fk_on(dbapi_conn, _record):
            dbapi_conn.execute("PRAGMA foreign_keys=ON")
    return engine


_MINIMAL_DDL = (
    "CREATE TABLE runs (id VARCHAR PRIMARY KEY, parameters_json VARCHAR DEFAULT '{}')",
    "CREATE TABLE model_versions (id VARCHAR PRIMARY KEY, status VARCHAR DEFAULT 'draft', "
    "uc_catalog VARCHAR DEFAULT '', import_source_path VARCHAR)",
    "CREATE TABLE run_operations (id VARCHAR PRIMARY KEY, run_id VARCHAR, operation_name VARCHAR, "
    "status VARCHAR, output_version_id VARCHAR)",
    "CREATE TABLE vibe_inputs (id VARCHAR PRIMARY KEY)",
    "CREATE TABLE run_input_links (run_id VARCHAR, input_id VARCHAR, PRIMARY KEY (run_id, input_id))",
    "CREATE TABLE agent_config (id VARCHAR PRIMARY KEY)",
)


def _minimal_engine(*, foreign_keys: bool = False, skip: tuple[str, ...] = ()):
    """The 0.8.0 columns the migration and its backfills read, one row per table."""
    engine = _fresh_engine(foreign_keys=foreign_keys)
    with engine.begin() as conn:
        for ddl in _MINIMAL_DDL:
            if ddl.split()[2] not in skip:
                conn.execute(text(ddl))
        seeds = {
            "runs": "INSERT INTO runs (id) VALUES ('r1')",
            "model_versions": "INSERT INTO model_versions (id) VALUES ('v1')",
            "vibe_inputs": "INSERT INTO vibe_inputs (id) VALUES ('i1')",
            "run_input_links": "INSERT INTO run_input_links (run_id, input_id) VALUES ('r1', 'i1')",
            "agent_config": "INSERT INTO agent_config (id) VALUES ('cfg1')",
        }
        for table, sql in seeds.items():
            if table not in skip:
                conn.execute(text(sql))
    return engine


def _cols(engine, table: str) -> set[str]:
    return {c["name"] for c in inspect(engine).get_columns(table)}


def metadata_without(new_columns, new_tables) -> MetaData:
    """The final models minus the given added columns and created tables."""
    md = MetaData()
    dropped = set(new_columns)
    for table in SQLModel.metadata.sorted_tables:
        if table.name in new_tables:
            continue
        columns = [c._copy() for c in table.columns if (table.name, c.name) not in dropped]
        uniques = [
            UniqueConstraint(*[c.name for c in u.columns], name=u.name)
            for u in table.constraints if isinstance(u, UniqueConstraint)
        ]
        Table(table.name, md, *columns, *uniques)
    return md


def _metadata_at_0_8_0() -> MetaData:
    """The final models minus everything v_0_9_0 and v_0_9_0_1 add."""
    return metadata_without(
        {*NEW_COLUMNS, *v_0_9_0_1.NEW_COLUMNS}, {*NEW_TABLES, *v_0_9_0_1.NEW_TABLES},
    )


def _engine_at_0_8_0():
    engine = _fresh_engine()
    _metadata_at_0_8_0().create_all(engine)
    reg._write_installed_version(engine, "0.8.0")
    return engine


# --- step 1: columns ------------------------------------------------------------------------------


def test_adds_columns_with_defaults_on_existing_rows_idempotently():
    engine = _minimal_engine()
    apply(engine)
    apply(engine)
    for table, column in NEW_COLUMNS:
        assert column in _cols(engine, table), (table, column)
    with engine.begin() as conn:
        mv = conn.execute(text(
            "SELECT dry_run, promoted_at, promoted_by_run_id, replaced_by_version_id, replaced_at, "
            "files_catalog, scope_fence_mode, scope_base_version, scope_base_scope "
            "FROM model_versions WHERE id='v1'"
        )).one()
        link = conn.execute(text(
            "SELECT outcome_status, outcome_reason, outcome_target FROM run_input_links"
        )).one()
        vi = conn.execute(text("SELECT consumed_by_run_id FROM vibe_inputs WHERE id='i1'")).one()
        cfg = conn.execute(text(
            "SELECT installed_release_version, installed_agent_version, installed_checked_at, "
            "installed_checked_path, installed_check_error FROM agent_config WHERE id='cfg1'"
        )).one()
    assert tuple(mv) == (0, None, None, None, None, None, None, None, None)
    assert tuple(link) == (None, None, None)
    assert tuple(vi) == (None,)
    assert tuple(cfg) == (None,) * 5


def test_missing_tables_are_skipped_independently():
    engine = _fresh_engine()
    apply(engine)
    assert set(inspect(engine).get_table_names()) == set(NEW_TABLES)

    engine = _minimal_engine(skip=("agent_config", "vibe_inputs"))
    apply(engine)
    assert "dry_run" in _cols(engine, "model_versions")
    assert "outcome_status" in _cols(engine, "run_input_links")
    assert not inspect(engine).has_table("agent_config")
    assert not inspect(engine).has_table("vibe_inputs")


def test_partially_applied_state_converges():
    """The owner script (or an aborted earlier attempt) may have added some
    columns already: the migration adds only the rest."""
    engine = _minimal_engine()
    with engine.begin() as conn:
        conn.execute(text(NEW_COLUMNS[("model_versions", "dry_run")][1]))
        conn.execute(text(NEW_COLUMNS[("vibe_inputs", "consumed_by_run_id")][1]))
        conn.execute(text("CREATE INDEX ix_vibe_inputs_consumed_by_run_id ON vibe_inputs (consumed_by_run_id)"))
        SQLModel.metadata.tables["run_agent_reports"].create(conn)
    apply(engine)
    for table, column in NEW_COLUMNS:
        assert column in _cols(engine, table), (table, column)
    assert set(NEW_TABLES) <= set(inspect(engine).get_table_names())


def test_fk_columns_reference_their_parent_with_set_null():
    """Read through ``PRAGMA foreign_key_list``: SQLAlchemy's reflection does not
    parse the ON DELETE action of a column-level REFERENCES added by ALTER."""
    engine = _minimal_engine()
    apply(engine)
    with engine.begin() as conn:
        for child, column, parent in SET_NULL_FKS:
            rows = [r for r in conn.execute(text(f"PRAGMA foreign_key_list({child})")).mappings()
                    if r["from"] == column]
            assert len(rows) == 1, (child, column)
            assert (rows[0]["table"], rows[0]["to"], rows[0]["on_delete"]) == (parent, "id", "SET NULL")


def test_set_null_on_delete_keeps_the_child_rows():
    engine = _minimal_engine(foreign_keys=True)
    apply(engine)
    with engine.begin() as conn:
        conn.execute(text("INSERT INTO model_versions (id) VALUES ('v2')"))
        conn.execute(text(
            "UPDATE model_versions SET promoted_by_run_id='r1', replaced_by_version_id='v2', "
            "replaced_at='2026-10-22 10:00:00' WHERE id='v1'"
        ))
        conn.execute(text("UPDATE vibe_inputs SET consumed_by_run_id='r1' WHERE id='i1'"))
        conn.execute(text("DELETE FROM run_input_links"))
        conn.execute(text("DELETE FROM runs WHERE id='r1'"))
        conn.execute(text("DELETE FROM model_versions WHERE id='v2'"))
        v1 = conn.execute(text(
            "SELECT promoted_by_run_id, replaced_by_version_id, replaced_at FROM model_versions WHERE id='v1'"
        )).one()
        vi = conn.execute(text("SELECT consumed_by_run_id FROM vibe_inputs WHERE id='i1'")).one()
    assert v1[0] is None and v1[1] is None
    assert v1[2] is not None, "replaced_at is the flag and must survive the replacer's delete"
    assert vi[0] is None


# --- step 2: indexes ------------------------------------------------------------------------------


def test_fk_columns_are_indexed_like_db_models():
    engine = _minimal_engine()
    apply(engine)
    for table, column in FK_INDEX_COLUMNS:
        names = {i["name"] for i in inspect(engine).get_indexes(table)}
        assert f"ix_{table}_{column}" in names
        assert SQLModel.metadata.tables[table].columns[column].index, (table, column)


# --- step 3: tables -------------------------------------------------------------------------------


def test_creates_the_two_tables_from_the_final_models():
    engine = _minimal_engine()
    apply(engine)
    apply(engine)
    for name in NEW_TABLES:
        assert _cols(engine, name) == set(SQLModel.metadata.tables[name].columns.keys()), name


def test_new_tables_cascade_with_their_run():
    engine = _minimal_engine(foreign_keys=True)
    apply(engine)
    with engine.begin() as conn:
        conn.execute(text("INSERT INTO run_agent_reports (run_id, has_input_outcomes, outcomes_malformed, "
                          "version_mismatch, unmatched_outcome_count, created_at) "
                          "VALUES ('r1', 1, 0, 0, 0, '2026-10-22')"))
        conn.execute(text("INSERT INTO run_post_install_deletes (run_id, version_id, version, scope, status, "
                          "reason, created_at) VALUES ('r1', 'gone', 5, 'ecm', 'pending', '', '2026-10-22')"))
        conn.execute(text("DELETE FROM run_input_links"))
        conn.execute(text("DELETE FROM runs WHERE id='r1'"))
        left = [conn.execute(text(f"SELECT COUNT(*) FROM {t}")).scalar() for t in NEW_TABLES]
    assert left == [0, 0]


# --- step 4: backfills ----------------------------------------------------------------------------


def _seed_versions(conn, rows):
    for vid, status, uc, imported in rows:
        conn.execute(
            text("INSERT INTO model_versions (id, status, uc_catalog, import_source_path) "
                 "VALUES (:id, :s, :uc, :imp)"),
            {"id": vid, "s": status, "uc": uc, "imp": imported},
        )


def test_files_catalog_backfill_copies_uc_catalog_for_agent_rows_only():
    engine = _minimal_engine()
    with engine.begin() as conn:
        _seed_versions(conn, [
            ("agent", "completed", "cat_a", None),
            ("imported", "completed", "cat_b", "/Volumes/x/model.json"),
            ("never_installed", "completed", "", None),
            ("preset", "completed", "cat_c", None),
        ])
    with engine.begin() as conn:
        conn.execute(text(NEW_COLUMNS[("model_versions", "files_catalog")][1]))
        conn.execute(text("UPDATE model_versions SET files_catalog='cat_home' WHERE id='preset'"))
    apply(engine)
    apply(engine)
    with engine.begin() as conn:
        got = dict(conn.execute(text("SELECT id, files_catalog FROM model_versions")).fetchall())
    assert got == {
        "v1": None, "agent": "cat_a", "imported": None, "never_installed": None, "preset": "cat_home",
    }


def _seed_op(conn, *, op_id, run_id, version_id, params, op_name="vibe_iterate", op_status="succeeded"):
    conn.execute(text("INSERT INTO runs (id, parameters_json) VALUES (:id, :p)"), {"id": run_id, "p": params})
    conn.execute(
        text("INSERT INTO run_operations (id, run_id, operation_name, status, output_version_id) "
             "VALUES (:id, :r, :n, :s, :v)"),
        {"id": op_id, "r": run_id, "n": op_name, "s": op_status, "v": version_id},
    )


def test_dry_run_backfill_marks_only_drafts_of_succeeded_dry_vibe_runs():
    engine = _minimal_engine()
    dry, full = json.dumps({"dry_run": True}), json.dumps({"dry_run": False})
    with engine.begin() as conn:
        _seed_versions(conn, [
            ("draft_dry", "draft", "c", None),
            ("draft_full", "draft", "c", None),
            ("completed_dry", "completed", "c", None),
            ("draft_failed_op", "draft", "c", None),
            ("draft_other_op", "draft", "c", None),
            ("draft_bad_json", "draft", "c", None),
            ("draft_string_true", "draft", "c", None),
        ])
        _seed_op(conn, op_id="o1", run_id="r_dry", version_id="draft_dry", params=dry)
        _seed_op(conn, op_id="o2", run_id="r_full", version_id="draft_full", params=full)
        _seed_op(conn, op_id="o3", run_id="r_done", version_id="completed_dry", params=dry)
        _seed_op(conn, op_id="o4", run_id="r_fail", version_id="draft_failed_op", params=dry, op_status="failed")
        _seed_op(conn, op_id="o5", run_id="r_other", version_id="draft_other_op", params=dry,
                 op_name="new_base_model")
        _seed_op(conn, op_id="o6", run_id="r_bad", version_id="draft_bad_json", params="{not json")
        _seed_op(conn, op_id="o7", run_id="r_str", version_id="draft_string_true",
                 params=json.dumps({"dry_run": "true"}))
    apply(engine)
    apply(engine)
    with engine.begin() as conn:
        marked = {r[0] for r in conn.execute(text("SELECT id FROM model_versions WHERE dry_run = 1"))}
    assert marked == {"draft_dry"}


# --- registry, versions and the upgrade from 0.8.0 ------------------------------------------------


def test_registered_right_after_0_8_0():
    versions = [m.version for m in runtime_migrations.MIGRATIONS]
    at = versions.index("0.9.0")
    assert versions[at - 1] == "0.8.0"
    assert runtime_migrations.MIGRATIONS[at] is MIGRATION
    assert not [v for v in versions if v.startswith("0.8.0.") or v.startswith("0.8.1")]


def test_a_0_8_0_database_upgrades_in_one_step(monkeypatch):
    """On the registry cut at 0.9.0, only 0.9.0 is pending; it runs once, keeps the rows,
    backfills, and the upgraded tables end with exactly the columns a fresh install creates."""
    monkeypatch.setattr(reg, "PRE_PROD_DESTRUCTIVE_RESET", False)
    up_to_0_9_0 = [m for m in runtime_migrations.MIGRATIONS if reg._vkey(m.version) <= reg._vkey("0.9.0")]
    monkeypatch.setattr(reg, "MIGRATIONS", up_to_0_9_0)
    engine = _engine_at_0_8_0()
    with Session(bind=engine) as session:
        session.add(db_models.Business(id="b1", name="Acme"))
        session.commit()
    with engine.begin() as conn:
        conn.execute(text("INSERT INTO model_versions (id, business_id, version, status, deployment_status, "
                          "vibe_instructions, scope, uc_catalog, sync_state, created_at) "
                          "VALUES ('v1', 'b1', 1, 'completed', 'deployed', '', 'ecm', 'cat_a', 'ok', "
                          "'2026-10-22')"))
    pending = [m.version for m in up_to_0_9_0 if reg._vkey(m.version) > reg._vkey("0.8.0")]
    assert pending == ["0.9.0"]

    reg.reconcile_schema(engine)

    assert reg._read_installed_version(engine) == "0.9.0"
    later = set(v_0_9_0_1.NEW_COLUMNS)
    for table in {t for (t, _c) in NEW_COLUMNS} | set(NEW_TABLES):
        expected = {c for c in SQLModel.metadata.tables[table].columns.keys() if (table, c) not in later}
        assert _cols(engine, table) == expected, table
    with engine.begin() as conn:
        row = conn.execute(text("SELECT version, files_catalog, dry_run FROM model_versions WHERE id='v1'")).one()
    assert tuple(row) == (1, "cat_a", 0)
