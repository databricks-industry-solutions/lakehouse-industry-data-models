"""Tests for the ``v_0_8_0`` migration (taxonomy columns + the 18 headless-assessment tables).

``v_0_8_0`` is the release's only migration. Step 1 adds the four defaulted
Domain Taxonomy Builder columns to ``agent_config`` / ``businesses``; step 2 is
``create_all`` over ``db_models.ASSESS_TABLES``. SQLite covers the column-add,
defaults on existing rows, the missing-table guard, table creation,
idempotency, the final column sets, registry ordering and the one-step upgrade
from a 0.7.3 database. SQLite cannot ``ALTER TABLE ... ADD CONSTRAINT``, so the
two ``use_alter`` decision-option FKs are asserted on the model metadata here;
the real Postgres ``ADD COLUMN IF NOT EXISTS`` path and the FK emission are
checked on a Lakebase branch.
"""

from __future__ import annotations

from sqlalchemy import create_engine, inspect, text
from sqlalchemy.pool import StaticPool
from sqlmodel import Session, SQLModel, select

from vibe_modeling.backend import db_models as db
from vibe_modeling.backend import migrations as runtime_migrations
from vibe_modeling.backend.migrations import registry as reg
from vibe_modeling.backend.migrations.v_0_8_0 import MIGRATION, NEW_COLUMNS, apply

_ASSESS_TABLES = {
    "assess_config", "assess_source_map", "assess_batch", "assess_domain_run",
    "assess_domain_source", "assess_entity", "assess_column_mapping", "assess_column_source_profile",
    "assess_gap", "assess_pending_decision", "assess_decision_option", "assess_next_vibe",
    "assess_handoff", "assess_summary", "assess_summary_item", "assess_decision_option_point",
    "assess_decision_affected", "assess_next_vibe_entity",
}


def _fresh_engine():
    return create_engine("sqlite://", connect_args={"check_same_thread": False}, poolclass=StaticPool)


def _engine_without_assess_tables():
    engine = _fresh_engine()
    SQLModel.metadata.create_all(engine, tables=[
        t for name, t in SQLModel.metadata.tables.items() if not name.startswith("assess_")
    ])
    return engine


def _engine_at_0_7_3():
    """Every 0.7.3 table (no ``assess_*``), with the four taxonomy columns dropped,
    one seeded ``agent_config`` and ``businesses`` row, and the version row at 0.7.3."""
    engine = _engine_without_assess_tables()
    with Session(bind=engine) as session:
        session.add(db.AgentConfig(id="cfg1"))
        session.add(db.Business(id="b1", name="Acme"))
        session.commit()
    with engine.begin() as conn:
        for table, column in NEW_COLUMNS:
            conn.execute(text(f"ALTER TABLE {table} DROP COLUMN {column}"))
    assert not {c for (_t, c) in NEW_COLUMNS} & (_cols(engine, "agent_config") | _cols(engine, "businesses"))
    reg._write_installed_version(engine, "0.7.3")
    return engine


def _cols(engine, table: str) -> set[str]:
    return {c["name"] for c in inspect(engine).get_columns(table)}


def _seed_minimal(engine, *, agent_config: bool = True, businesses: bool = True) -> None:
    with engine.begin() as conn:
        if agent_config:
            conn.execute(text("CREATE TABLE agent_config (id VARCHAR PRIMARY KEY, notebook_path VARCHAR)"))
            conn.execute(text("INSERT INTO agent_config (id, notebook_path) VALUES ('cfg1', '')"))
        if businesses:
            conn.execute(text("CREATE TABLE businesses (id VARCHAR PRIMARY KEY, name VARCHAR)"))
            conn.execute(text("INSERT INTO businesses (id, name) VALUES ('b1', 'Acme')"))


# --- step 1: taxonomy columns on existing tables -------------------------------------------------


def test_adds_taxonomy_columns_with_defaults_on_existing_rows_idempotently():
    engine = _fresh_engine()
    _seed_minimal(engine)
    apply(engine)
    apply(engine)
    assert {"taxonomy_model_service", "taxonomy_llm_max_concurrency"} <= _cols(engine, "agent_config")
    assert {"business_domains", "org_divisions"} <= _cols(engine, "businesses")
    with engine.begin() as conn:
        cfg = conn.execute(text(
            "SELECT taxonomy_model_service, taxonomy_llm_max_concurrency FROM agent_config WHERE id='cfg1'"
        )).one()
        biz = conn.execute(text("SELECT business_domains, org_divisions FROM businesses WHERE id='b1'")).one()
    assert tuple(cfg) == ("", 6)
    assert tuple(biz) == ("", "")


def test_missing_tables_are_skipped_independently():
    engine = _fresh_engine()
    apply(engine)
    assert not inspect(engine).has_table("agent_config")
    assert not inspect(engine).has_table("businesses")

    engine = _fresh_engine()
    _seed_minimal(engine, agent_config=False)
    apply(engine)
    assert {"business_domains", "org_divisions"} <= _cols(engine, "businesses")
    assert not inspect(engine).has_table("agent_config")


def test_taxonomy_columns_match_db_models():
    """The migrated columns are exactly the ones db_models declares, so a fresh
    create_all install and an upgraded install end with the same shape."""
    engine = _engine_without_assess_tables()
    before = {t: _cols(engine, t) for t in ("agent_config", "businesses")}
    apply(engine)
    assert {t: _cols(engine, t) for t in before} == before
    for table, column in NEW_COLUMNS:
        assert column in before[table]


# --- step 2: the assess_* tables ------------------------------------------------------------------


def test_creates_all_18_tables_idempotently():
    engine = _engine_without_assess_tables()
    assert not any(t.startswith("assess_") for t in inspect(engine).get_table_names())
    apply(engine)
    apply(engine)
    assert {t for t in inspect(engine).get_table_names() if t.startswith("assess_")} == _ASSESS_TABLES
    assert {t.__tablename__ for t in db.ASSESS_TABLES} == _ASSESS_TABLES


def test_columns_match_the_final_models():
    engine = _engine_without_assess_tables()
    apply(engine)
    for model in db.ASSESS_TABLES:
        assert _cols(engine, model.__tablename__) == set(model.__table__.columns.keys()), model.__tablename__


def test_design_columns_present_and_dropped_columns_absent():
    engine = _engine_without_assess_tables()
    apply(engine)
    config = _cols(engine, "assess_config")
    assert {"job_id", "synced_version", "job_reader", "reader_display_name"} <= config
    assert not {"genie_version", "skills_ref", "probe_job_id"} & config
    assert {"job_id", "notebook_folder", "job_reader", "ingest_attempts", "ingest_next_at", "schema_version"} <= _cols(
        engine, "assess_domain_run")
    assert {"kind", "recommended_option_id", "blocks_build"} <= _cols(engine, "assess_pending_decision")
    assert {"reported_structure", "core_sourced", "grade_reason"} <= _cols(engine, "assess_entity")
    assert {"vibe_input_id", "urgency"} <= _cols(engine, "assess_next_vibe")


def test_next_vibe_links_to_vibe_inputs_with_set_null_and_index():
    engine = _engine_without_assess_tables()
    apply(engine)
    insp = inspect(engine)
    fks = [fk for fk in insp.get_foreign_keys("assess_next_vibe") if fk["constrained_columns"] == ["vibe_input_id"]]
    assert len(fks) == 1 and fks[0]["referred_table"] == "vibe_inputs"
    assert fks[0]["options"].get("ondelete") == "SET NULL"
    assert "ix_assess_next_vibe_vibe_input_id" in {i["name"] for i in insp.get_indexes("assess_next_vibe")}


def test_decision_option_fks_are_use_alter_with_set_null():
    table = db.AssessPendingDecision.__table__
    by_name = {fk.name: fk for col in table.columns for fk in col.foreign_keys}
    for name, column in (("fk_assess_decision_answer_option", "answer_option_id"),
                         ("fk_assess_decision_recommended_option", "recommended_option_id")):
        fk = by_name[name]
        assert fk.parent.name == column and fk.target_fullname == "assess_decision_option.id"
        assert fk.use_alter and fk.ondelete == "SET NULL"


# --- registry and the upgrade from 0.7.3 ----------------------------------------------------------


def test_registered_right_after_0_7_3():
    versions = [m.version for m in runtime_migrations.MIGRATIONS]
    at = versions.index("0.8.0")
    assert versions[at - 1] == "0.7.3"
    assert runtime_migrations.MIGRATIONS[at] is MIGRATION
    assert not [v for v in versions if v.startswith("0.8.0.") or v.startswith("0.7.4")]


def test_a_0_7_3_database_upgrades_in_one_step(monkeypatch):
    """Production-style partial upgrade on the 0.8.0 registry: only 0.8.0 is pending, it runs once, rows survive
    with the column defaults, and the version row lands on 0.8.0."""
    monkeypatch.setattr(reg, "PRE_PROD_DESTRUCTIVE_RESET", False)
    up_to_0_8_0 = [m for m in runtime_migrations.MIGRATIONS if reg._vkey(m.version) <= reg._vkey("0.8.0")]
    monkeypatch.setattr(reg, "MIGRATIONS", up_to_0_8_0)
    engine = _engine_at_0_7_3()
    pending = [m.version for m in up_to_0_8_0 if reg._vkey(m.version) > reg._vkey("0.7.3")]
    assert pending == ["0.8.0"]

    reg.reconcile_schema(engine)

    with Session(bind=engine) as session:
        row = session.exec(select(db.LakebaseSchemaVersion).where(db.LakebaseSchemaVersion.id == 1)).one()
    assert row.version == "0.8.0"
    assert {t for t in inspect(engine).get_table_names() if t.startswith("assess_")} == _ASSESS_TABLES
    with engine.begin() as conn:
        cfg = conn.execute(text(
            "SELECT taxonomy_model_service, taxonomy_llm_max_concurrency FROM agent_config WHERE id='cfg1'"
        )).one()
        biz = conn.execute(text("SELECT name, business_domains, org_divisions FROM businesses WHERE id='b1'")).one()
    assert tuple(cfg) == ("", 6)
    assert tuple(biz) == ("Acme", "", "")


def test_vkey_orders_four_level_versions_numerically():
    assert reg._vkey("0.8.0") < reg._vkey("0.8.0.1") < reg._vkey("0.8.0.9") < reg._vkey("0.8.0.10")
    assert reg._vkey("0.7.3") < reg._vkey("0.8.0")
    assert reg._vkey("0.8.0.10") < reg._vkey("0.8.1") < reg._vkey("0.10.0")
    assert "0.8.0.10" < "0.8.0.9" and "0.10.0" < "0.9.0"
