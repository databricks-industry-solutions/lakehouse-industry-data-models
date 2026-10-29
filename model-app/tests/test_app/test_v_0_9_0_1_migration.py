"""Tests for the ``v_0_9_0_1`` migration (install rows, cleanups, change decisions,
wizard state, link-run and taxonomy audit columns, industry dedup).

SQLite level: the columns land on existing rows, the five tables and their
indexes are created and converge from a partial state, re-runs change nothing,
the install-row backfill opens and closes exactly the rows the design names,
and the industry dedup repoints and deactivates (never deletes) with stubs and
ambiguous matches skipped. A 0.9.0-shaped database upgrades through
``reconcile_schema`` in one step and ends with the fresh-install columns. The
real Postgres path is in ``test_v_0_9_0_1_migration_pg.py``.
"""

from __future__ import annotations

import logging
import os
import sys
import time
from datetime import datetime, timezone

import pytest
from sqlalchemy import create_engine, event, inspect, text
from sqlalchemy.exc import IntegrityError
from sqlalchemy.pool import StaticPool
from sqlmodel import SQLModel

sys.path.insert(0, os.path.dirname(__file__))

from test_v_0_9_0_migration import metadata_without  # noqa: E402

from vibe_modeling.backend import db_models  # noqa: E402,F401 - registers tables on metadata
from vibe_modeling.backend import migrations as runtime_migrations  # noqa: E402
from vibe_modeling.backend.migrations import registry as reg  # noqa: E402
from vibe_modeling.backend.migrations.v_0_9_0_1 import (  # noqa: E402
    INDUSTRY_FK_COLUMNS,
    MIGRATION,
    NEW_COLUMNS,
    NEW_TABLES,
    _frozen_industry_slug,
    apply,
    plan_industry_dedup,
)


def _sqlite(*, foreign_keys: bool = False):
    engine = create_engine("sqlite://", connect_args={"check_same_thread": False}, poolclass=StaticPool)
    if foreign_keys:
        @event.listens_for(engine, "connect")
        def _fk_on(dbapi_conn, _record):
            dbapi_conn.execute("PRAGMA foreign_keys=ON")
    return engine


def _engine_at_0_9_0(*, foreign_keys: bool = False):
    """The final models minus everything v_0_9_0_1 adds, version row at 0.9.0."""
    engine = _sqlite(foreign_keys=foreign_keys)
    metadata_without(NEW_COLUMNS, NEW_TABLES).create_all(engine)
    reg._write_installed_version(engine, "0.9.0")
    return engine


def _cols(engine, table: str) -> set[str]:
    return {c["name"] for c in inspect(engine).get_columns(table)}


def _raw_insert(conn, table_name: str, **values) -> None:
    """Insert into a pre-0.9.0.1 table with every other NOT NULL column filled."""
    from sqlalchemy import Boolean, DateTime, Integer

    columns = conn.execute(text(f"PRAGMA table_info({table_name})")).mappings().all()
    row = dict(values)
    for col in columns:
        if col["name"] in row or not col["notnull"] or col["dflt_value"] is not None or col["pk"]:
            continue
        sa_type = SQLModel.metadata.tables[table_name].columns[col["name"]].type
        if isinstance(sa_type, DateTime):
            row[col["name"]] = "2026-10-22"
        elif isinstance(sa_type, (Integer, Boolean)):
            row[col["name"]] = 0
        else:
            row[col["name"]] = ""
    names = ", ".join(row)
    conn.execute(text(f"INSERT INTO {table_name} ({names}) VALUES ({', '.join(':' + n for n in row)})"), row)


def _indexes(engine, table: str) -> dict[str, dict]:
    return {i["name"]: i for i in inspect(engine).get_indexes(table)}


# --- step 1: columns ------------------------------------------------------------------------------


def test_adds_columns_null_on_existing_rows_idempotently():
    engine = _engine_at_0_9_0()
    with engine.begin() as conn:
        conn.execute(text("INSERT INTO businesses (id, name, description, business_vibes, industry_alignment, "
                          "kind, business_domains, org_divisions, created_at, updated_at) "
                          "VALUES ('b1', 'Acme', '', '', '', 'business', '', '', '2026-10-22', '2026-10-22')"))
        conn.execute(text("INSERT INTO runs (id, business_id, intent, status, last_consumed_step_id, progress_percent, "
                          "progress_message, error_message, parameters_json, vibe_instructions_text, "
                          "vibe_instructions_volume_path, business_context_text, last_jobs_api_state, "
                          "last_poll_error, created_at) VALUES ('r1', 'b1', '', 'completed', 0, 0, '', '', '{}', "
                          "'', '', '', '', '', '2026-10-22')"))
        _raw_insert(conn, "agent_config", id="cfg1")
    apply(engine)
    apply(engine)
    for table, column in NEW_COLUMNS:
        assert column in _cols(engine, table), (table, column)
    with engine.begin() as conn:
        assert tuple(conn.execute(text("SELECT linked_at, link_evidence FROM runs")).one()) == (None, None)
        assert tuple(conn.execute(text(
            "SELECT taxonomy_updated_by, taxonomy_updated_at FROM agent_config")).one()) == (None, None)


def test_missing_tables_are_skipped():
    engine = _sqlite()
    apply(engine)
    assert set(inspect(engine).get_table_names()) == set(NEW_TABLES)

    engine = _sqlite()
    with engine.begin() as conn:
        conn.execute(text("CREATE TABLE runs (id VARCHAR PRIMARY KEY)"))
    apply(engine)
    assert {"linked_at", "link_evidence"} <= _cols(engine, "runs")
    assert not inspect(engine).has_table("agent_config")


# --- step 2: tables and indexes -------------------------------------------------------------------


def test_creates_the_tables_from_the_final_models_with_their_indexes():
    engine = _engine_at_0_9_0()
    apply(engine)
    apply(engine)
    for name in NEW_TABLES:
        table = SQLModel.metadata.tables[name]
        assert _cols(engine, name) == set(table.columns.keys()), name
        assert {i.name for i in table.indexes} <= set(_indexes(engine, name)), name
    open_ix = _indexes(engine, "model_version_installs")["uq_model_version_installs_open"]
    assert open_ix["unique"] and open_ix["column_names"] == ["version_id", "catalog"]
    lookup = _indexes(engine, "metamodel_cleanups")["ix_metamodel_cleanups_lookup"]
    assert lookup["column_names"] == ["business_segment", "scope", "catalog", "status"]


def test_partially_applied_state_converges():
    """A column already added and a table created without its indexes: the
    migration adds the rest and the missing indexes."""
    engine = _engine_at_0_9_0()
    with engine.begin() as conn:
        conn.execute(text(NEW_COLUMNS[("runs", "linked_at")][1]))
        conn.execute(text(
            "CREATE TABLE metamodel_cleanups (id VARCHAR PRIMARY KEY, business_segment VARCHAR NOT NULL, "
            "version INTEGER NOT NULL, scope VARCHAR NOT NULL, catalog VARCHAR NOT NULL, reason VARCHAR NOT NULL, "
            "status VARCHAR NOT NULL, attempts INTEGER NOT NULL, last_error TEXT, created_at DATETIME NOT NULL, "
            "updated_at DATETIME NOT NULL)"
        ))
    apply(engine)
    for table, column in NEW_COLUMNS:
        assert column in _cols(engine, table), (table, column)
    assert "ix_metamodel_cleanups_lookup" in _indexes(engine, "metamodel_cleanups")
    assert set(NEW_TABLES) <= set(inspect(engine).get_table_names())


def test_set_null_fks_of_the_new_tables_are_indexed():
    for name in NEW_TABLES:
        table = SQLModel.metadata.tables[name]
        for fkc in table.foreign_key_constraints:
            if (fkc.ondelete or "").upper() == "SET NULL":
                (column,) = [c.name for c in fkc.columns]
                assert table.columns[column].index, (name, column)


def test_open_install_rows_are_unique_per_version_and_catalog():
    engine = _engine_at_0_9_0()
    _seed_versions(engine, [("v1", "deployed", "cat_a")])
    apply(engine)
    insert = ("INSERT INTO model_version_installs (id, version_id, catalog, installed_at, uninstalled_at) "
              "VALUES (:id, 'v1', 'cat_a', '2026-10-22', :gone)")
    with engine.begin() as conn:
        conn.execute(text(insert), {"id": "closed-1", "gone": "2026-10-22"})
        conn.execute(text(insert), {"id": "closed-2", "gone": "2026-10-22"})
    with pytest.raises(IntegrityError):
        with engine.begin() as conn:
            conn.execute(text(insert), {"id": "open-2", "gone": None})


# --- step 3: install rows backfill ----------------------------------------------------------------


def _seed_versions(engine, rows, *, business_id="b1"):
    """rows: (id, deployment_status, uc_catalog[, promoted_at, completion_date, promoted_by_run_id])."""
    with engine.begin() as conn:
        if not conn.execute(text("SELECT 1 FROM businesses WHERE id = :b"), {"b": business_id}).first():
            conn.execute(text("INSERT INTO businesses (id, name, description, business_vibes, industry_alignment, "
                              "kind, business_domains, org_divisions, created_at, updated_at) "
                              "VALUES (:b, :b, '', '', '', 'business', '', '', '2026-10-01', '2026-10-01')"),
                         {"b": business_id})
        for n, row in enumerate(rows, start=1):
            vid, deployment, uc, promoted, completed, by_run = (*row, None, None, None)[:6]
            conn.execute(text(
                "INSERT INTO model_versions (id, business_id, version, status, deployment_status, "
                "vibe_instructions, scope, uc_catalog, completion_date, sync_state, dry_run, promoted_at, "
                "promoted_by_run_id, created_at) VALUES (:id, :b, :n, 'completed', :d, '', 'ecm', :uc, :c, 'ok', 0, "
                ":p, :r, '2026-10-01 08:00:00')"
            ), {"id": vid, "b": business_id, "n": n, "d": deployment, "uc": uc, "c": completed, "p": promoted,
                "r": by_run})


def _installs(engine) -> list[tuple]:
    with engine.begin() as conn:
        return sorted(tuple(r) for r in conn.execute(text(
            "SELECT version_id, catalog, installed_by_run_id, installed_at, uninstalled_at IS NOT NULL "
            "FROM model_version_installs"
        )))


def test_install_backfill_opens_deployed_and_closes_uninstalled_rows():
    engine = _engine_at_0_9_0()
    _seed_versions(engine, [
        ("deployed", "deployed", "cat_a", "2026-10-05 09:00:00", "2026-10-03 09:00:00", None),
        ("deployed_no_promo", "deployed", "cat_b", None, "2026-10-03 09:00:00"),
        ("deployed_bare", "deployed", "cat_c"),
        ("uninstalled", "uninstalled", "cat_d"),
        ("draft", "draft", "cat_e"),
        ("deployed_no_catalog", "deployed", ""),
        ("uninstalled_no_catalog", "uninstalled", ""),
    ])
    apply(engine)
    apply(engine)
    rows = _installs(engine)
    assert [(r[0], r[1], r[4]) for r in rows] == [
        ("deployed", "cat_a", 0), ("deployed_bare", "cat_c", 0), ("deployed_no_promo", "cat_b", 0),
        ("uninstalled", "cat_d", 1),
    ]
    installed_at = {r[0]: str(r[3]) for r in rows}
    assert installed_at["deployed"].startswith("2026-10-05 09:00:00")
    assert installed_at["deployed_no_promo"].startswith("2026-10-03 09:00:00")
    assert installed_at["deployed_bare"].startswith("2026-10-01 08:00:00")
    with engine.begin() as conn:
        ids = [r[0] for r in conn.execute(text("SELECT id FROM model_version_installs"))]
    assert len(set(ids)) == 4


def test_install_backfill_warns_about_deployed_versions_without_a_catalog(caplog):
    engine = _engine_at_0_9_0()
    _seed_versions(engine, [
        ("deployed", "deployed", "cat_a"),
        ("deployed_empty", "deployed", ""),
        ("deployed_empty_2", "deployed", ""),
        ("uninstalled_empty", "uninstalled", ""),
    ])
    with caplog.at_level(logging.WARNING, logger="vibe_modeling.backend.migrations.v_0_9_0_1"):
        apply(engine)
    warnings = [r.getMessage() for r in caplog.records if r.levelno == logging.WARNING]
    assert warnings == [
        "v_0_9_0_1: 2 deployed version(s) have no uc_catalog and get no install row: deployed_empty, deployed_empty_2"
    ]


def test_install_backfill_keeps_existing_rows():
    """An open row already there (written by the app) is not duplicated, and a
    version with any row for its catalog gets no closed row."""
    engine = _engine_at_0_9_0()
    _seed_versions(engine, [("deployed", "deployed", "cat_a"), ("uninstalled", "uninstalled", "cat_b")])
    apply(engine)
    with engine.begin() as conn:
        conn.execute(text("DELETE FROM model_version_installs"))
        conn.execute(text("INSERT INTO model_version_installs (id, version_id, catalog, installed_at) "
                          "VALUES ('app-open', 'deployed', 'cat_a', '2026-10-20')"))
        conn.execute(text("INSERT INTO model_version_installs (id, version_id, catalog, installed_at, "
                          "uninstalled_at) VALUES ('app-closed', 'uninstalled', 'cat_b', '2026-10-20', "
                          "'2026-10-21')"))
    apply(engine)
    with engine.begin() as conn:
        ids = sorted(r[0] for r in conn.execute(text("SELECT id FROM model_version_installs")))
    assert ids == ["app-closed", "app-open"]


def test_install_backfill_carries_the_promoting_run():
    engine = _engine_at_0_9_0()
    with engine.begin() as conn:
        conn.execute(text("INSERT INTO businesses (id, name, description, business_vibes, industry_alignment, "
                          "kind, business_domains, org_divisions, created_at, updated_at) "
                          "VALUES ('b1', 'b1', '', '', '', 'business', '', '', '2026-10-01', '2026-10-01')"))
        conn.execute(text("INSERT INTO runs (id, business_id, intent, status, last_consumed_step_id, "
                          "progress_percent, progress_message, error_message, parameters_json, "
                          "vibe_instructions_text, vibe_instructions_volume_path, business_context_text, "
                          "last_jobs_api_state, last_poll_error, created_at) VALUES ('run-1', 'b1', '', 'completed', "
                          "0, 0, '', '', '{}', '', '', '', '', '', '2026-10-01')"))
    _seed_versions(engine, [("deployed", "deployed", "cat_a", None, None, "run-1")])
    apply(engine)
    assert _installs(engine)[0][2] == "run-1"


# --- step 4: industry dedup -----------------------------------------------------------------------


def _industry(conn, ind_id, name, short_name, *, auto, active=True):
    conn.execute(text(
        "INSERT INTO industries (id, name, short_name, description, notable_businesses, display_order, "
        "is_active, is_auto_created, created_at, updated_at) "
        "VALUES (:id, :n, :s, '', '', 0, :a, :auto, '2026-10-01', '2026-10-01')"
    ), {"id": ind_id, "n": name, "s": short_name, "a": active, "auto": auto})


def _business(conn, bid, name, industry_id):
    conn.execute(text(
        "INSERT INTO businesses (id, name, description, business_vibes, industry_alignment, industry_id, kind, "
        "business_domains, org_divisions, created_at, updated_at) "
        "VALUES (:id, :n, '', '', 'x', :i, 'business', '', '', '2026-10-01', '2026-10-01')"
    ), {"id": bid, "n": name, "i": industry_id})


def _seed_industries(engine):
    with engine.begin() as conn:
        _industry(conn, "cur_util", "Energy - Utilities", "Utilities", auto=False)
        _industry(conn, "cur_retail", "Retail", "retail", auto=False)
        _industry(conn, "cur_retail_ops", "Retail Ops", "Retail", auto=False)
        _industry(conn, "cur_old", "Mining", "Mining", auto=False, active=False)
        # Import-created duplicate of "Energy - Utilities" (slug of its name).
        _industry(conn, "auto_util", "energy-utilities", "energy-utilities", auto=True)
        # "_" is a slug separator, never a wildcard.
        _industry(conn, "auto_util_us", "Energy_Utilities", "energy-utilities", auto=True)
        # Initial-sync stub named after its business; its slug matches "Utilities".
        _industry(conn, "stub_util", "Utilities", "utilities", auto=True)
        # Matches two curated rows ("retail" short_name and "Retail Ops"' short_name).
        _industry(conn, "auto_retail", "RETAIL", "retail", auto=True)
        # Matches only an inactive curated row: nothing to merge into.
        _industry(conn, "auto_mining", "mining", "mining", auto=True)
        # No curated match at all.
        _industry(conn, "auto_space", "Space Tourism", "space-tourism", auto=True)
        _business(conn, "b_util1", "Grid Co", "auto_util")
        _business(conn, "b_util2", "Power Co", "auto_util")
        _business(conn, "b_util3", "Wires Co", "auto_util_us")
        _business(conn, "b_stub", "utilities", "stub_util")
        _business(conn, "b_retail", "Shop Co", "auto_retail")
        _business(conn, "b_mining", "Dig Co", "auto_mining")
        _business(conn, "b_space", "Orbit Co", "auto_space")
        _business(conn, "b_curated", "Lights Co", "cur_util")


def _industry_state(engine) -> tuple[dict, dict]:
    with engine.begin() as conn:
        businesses = dict(conn.execute(text("SELECT id, industry_id FROM businesses")).fetchall())
        industries = {r[0]: bool(r[1]) for r in conn.execute(text("SELECT id, is_active FROM industries"))}
    return businesses, industries


def test_frozen_slug():
    assert _frozen_industry_slug("Energy - Utilities") == "energy-utilities"
    assert _frozen_industry_slug("  Energy_Utilities  ") == "energy-utilities"
    assert _frozen_industry_slug("Oil & Gas") == "oil-gas"
    assert _frozen_industry_slug("%") == ""
    assert _frozen_industry_slug(None) == ""


def test_plan_lists_merges_and_skips():
    engine = _engine_at_0_9_0()
    _seed_industries(engine)
    with engine.connect() as conn:
        plan = plan_industry_dedup(conn)
    assert [(m.duplicate_id, m.target_id, m.business_names, m.business_ids) for m in plan.merges] == [
        ("auto_util", "cur_util", ("Grid Co", "Power Co"), ("b_util1", "b_util2")),
        ("auto_util_us", "cur_util", ("Wires Co",), ("b_util3",)),
    ]
    assert {(s.industry_id, s.reason, s.detail) for s in plan.skipped} == {
        ("stub_util", "stub", ("utilities",)),
        ("auto_retail", "ambiguous", ("Retail", "Retail Ops")),
    }


def test_dedup_repoints_and_deactivates_never_deletes():
    engine = _engine_at_0_9_0()
    _seed_industries(engine)
    with engine.begin() as conn:
        industries_before = conn.execute(text("SELECT COUNT(*) FROM industries")).scalar()
    apply(engine)
    businesses, industries = _industry_state(engine)
    assert len(industries) == industries_before
    assert businesses == {
        "b_util1": "cur_util", "b_util2": "cur_util", "b_util3": "cur_util",
        "b_stub": "stub_util", "b_retail": "auto_retail", "b_mining": "auto_mining",
        "b_space": "auto_space", "b_curated": "cur_util",
    }
    assert {k for k, active in industries.items() if not active} == {"auto_util", "auto_util_us", "cur_old"}


def test_dedup_rerun_is_a_no_op():
    engine = _engine_at_0_9_0()
    _seed_industries(engine)
    apply(engine)
    after_first = _industry_state(engine)
    with engine.connect() as conn:
        plan = plan_industry_dedup(conn)
    assert plan.merges == ()
    apply(engine)
    assert _industry_state(engine) == after_first


def test_dedup_deactivates_an_unused_duplicate_and_picks_up_a_late_business():
    engine = _engine_at_0_9_0()
    with engine.begin() as conn:
        _industry(conn, "cur_util", "Energy - Utilities", "Utilities", auto=False)
        _industry(conn, "auto_unused", "Energy Utilities", "energy-utilities", auto=True)
        _industry(conn, "auto_inactive", "energy utilities", "energy-utilities", auto=True, active=False)
        _business(conn, "b_late", "Late Co", "auto_inactive")
    apply(engine)
    businesses, industries = _industry_state(engine)
    assert businesses == {"b_late": "cur_util"}
    assert (industries["auto_unused"], industries["auto_inactive"], industries["cur_util"]) == (False, False, True)


def test_dedup_stamps_updated_at_on_deactivated_rows():
    engine = _engine_at_0_9_0()
    _seed_industries(engine)
    apply(engine)
    with engine.begin() as conn:
        stamps = dict(conn.execute(text("SELECT id, updated_at FROM industries")).fetchall())
    assert str(stamps["auto_util"]) > "2026-10-02"
    assert str(stamps["stub_util"]).startswith("2026-10-01")


def test_dedup_logs_each_merge_with_the_moved_businesses(caplog):
    engine = _engine_at_0_9_0()
    _seed_industries(engine)
    with caplog.at_level(logging.INFO, logger="vibe_modeling.backend.migrations.v_0_9_0_1"):
        apply(engine)
    merges = [r.getMessage() for r in caplog.records if "merged auto-created industry" in r.getMessage()]
    assert merges == [
        "v_0_9_0_1: merged auto-created industry 'energy-utilities' (auto_util) into 'Energy - Utilities' "
        "(cur_util) and deactivated it; 2 business(es) repointed: 'Grid Co' (b_util1), 'Power Co' (b_util2)",
        "v_0_9_0_1: merged auto-created industry 'Energy_Utilities' (auto_util_us) into 'Energy - Utilities' "
        "(cur_util) and deactivated it; 1 business(es) repointed: 'Wires Co' (b_util3)",
    ]


def test_industry_fk_columns_cover_every_fk_to_industries():
    found = {
        (table.name, list(fkc.columns)[0].name)
        for table in SQLModel.metadata.sorted_tables
        for fkc in table.foreign_key_constraints
        if fkc.referred_table.name == "industries"
    }
    assert found == set(INDUSTRY_FK_COLUMNS)


def test_dedup_respects_foreign_keys():
    engine = _engine_at_0_9_0(foreign_keys=True)
    _seed_industries(engine)
    apply(engine)
    assert _industry_state(engine)[0]["b_util1"] == "cur_util"


# --- registry and the upgrade from 0.9.0 ----------------------------------------------------------


def test_registered_right_after_0_9_0():
    versions = [m.version for m in runtime_migrations.MIGRATIONS]
    at = versions.index("0.9.0.1")
    assert versions[at - 1] == "0.9.0"
    assert runtime_migrations.MIGRATIONS[at] is MIGRATION


def test_a_0_9_0_database_upgrades_in_one_step(monkeypatch):
    """On the registry cut at 0.9.0.1, only 0.9.0.1 is pending; it runs once, keeps the
    rows, backfills, and the upgraded tables end with exactly the columns a fresh install
    creates."""
    monkeypatch.setattr(reg, "PRE_PROD_DESTRUCTIVE_RESET", False)
    up_to_0_9_0_1 = [m for m in runtime_migrations.MIGRATIONS if reg._vkey(m.version) <= reg._vkey("0.9.0.1")]
    monkeypatch.setattr(reg, "MIGRATIONS", up_to_0_9_0_1)
    engine = _engine_at_0_9_0()
    _seed_versions(engine, [("v1", "deployed", "cat_a")])
    pending = [m.version for m in up_to_0_9_0_1 if reg._vkey(m.version) > reg._vkey("0.9.0")]
    assert pending == ["0.9.0.1"]

    reg.reconcile_schema(engine)

    assert reg._read_installed_version(engine) == "0.9.0.1"
    for table in {t for (t, _c) in NEW_COLUMNS} | set(NEW_TABLES):
        assert _cols(engine, table) == set(SQLModel.metadata.tables[table].columns.keys()), table
    assert [(r[0], r[1], r[4]) for r in _installs(engine)] == [("v1", "cat_a", 0)]


def test_fresh_install_reaches_the_head():
    engine = _sqlite()
    reg.reconcile_schema(engine)
    assert reg._read_installed_version(engine) == runtime_migrations.MIGRATIONS[-1].version
    for name in NEW_TABLES:
        assert inspect(engine).has_table(name)
    assert "uq_model_version_installs_open" in _indexes(engine, "model_version_installs")


def test_migration_stamps_utc_times():
    """The closed install row's ``uninstalled_at`` and the deactivated industry's
    ``updated_at`` hold UTC wall-clock time, also when the process runs in a zone
    14 hours ahead of UTC (a local-time stamp would land 14 hours late)."""
    engine = _engine_at_0_9_0()
    _seed_versions(engine, [("uninstalled", "uninstalled", "cat_d")])
    _seed_industries(engine)
    saved_tz = os.environ.get("TZ")
    os.environ["TZ"] = "Etc/GMT-14"
    time.tzset()
    try:
        before = datetime.now(timezone.utc).replace(tzinfo=None)
        apply(engine)
        after = datetime.now(timezone.utc).replace(tzinfo=None)
    finally:
        if saved_tz is None:
            os.environ.pop("TZ", None)
        else:
            os.environ["TZ"] = saved_tz
        time.tzset()
    with engine.begin() as conn:
        uninstalled_at = conn.execute(text(
            "SELECT uninstalled_at FROM model_version_installs WHERE version_id = 'uninstalled'")).scalar()
        updated_at = conn.execute(text("SELECT updated_at FROM industries WHERE id = 'auto_util'")).scalar()
    for stamped in (uninstalled_at, updated_at):
        assert before <= datetime.fromisoformat(str(stamped)) <= after


# --- the read-only dry run (scripts/smoke/industry_dedup_dry_run.py) ------------------------------


def _load_dry_run_script():
    import importlib.util
    from pathlib import Path

    path = Path(__file__).resolve().parents[2] / "scripts" / "smoke" / "industry_dedup_dry_run.py"
    spec = importlib.util.spec_from_file_location("industry_dedup_dry_run", str(path))
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def test_dry_run_prints_the_plan_and_writes_nothing(tmp_path):
    script = _load_dry_run_script()
    engine = create_engine(f"sqlite:///{tmp_path / 'app.db'}")
    metadata_without(NEW_COLUMNS, NEW_TABLES).create_all(engine)
    _seed_industries(engine)
    before = _industry_state(engine)

    plan = script.read_plan(engine)

    assert _industry_state(engine) == before
    out = script.render(plan)
    assert "merges (2):" in out and "'energy-utilities' [auto_util] -> 'Energy - Utilities' [cur_util]" in out
    assert "skipped (2):" in out and "[stub_util] stub: utilities" in out
    with engine.connect() as conn:
        conn.execute(text("PRAGMA query_only = ON"))
        with pytest.raises(Exception):
            conn.execute(text("UPDATE industries SET is_active = 0"))
