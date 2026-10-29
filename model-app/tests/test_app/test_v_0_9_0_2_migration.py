"""The two places the run-tags install default applies, at SQLite level.

``VIBE_MODELING_RUN_TAGS_DEFAULT`` (``install.sh --no-run-tags`` renders ``false``)
reaches ``agent_config.collect_vibe_run_statistics`` twice at most:

- ``v_0_9_0_2`` applies it once to every existing row (unset means on), on the
  upgrade boot; a re-run gives the same state, an empty or missing table is a
  no-op, and a Settings change made after it survives later boots;
- ``_get_or_create_agent_config`` seeds a new row from ``AppConfig.run_tags_default``
  and leaves an existing row alone.

The migration's frozen parser agrees with ``AppConfig`` on every value pydantic
accepts. The real Postgres path (server default) is in ``test_v_0_9_0_2_migration_pg.py``.
"""

from __future__ import annotations

import pytest
from pydantic import ValidationError
from sqlalchemy import create_engine, inspect
from sqlalchemy.pool import StaticPool
from sqlmodel import Session, SQLModel, select

from vibe_modeling.backend import db_models as db
from vibe_modeling.backend import migrations as runtime_migrations
from vibe_modeling.backend.core._config import AppConfig
from vibe_modeling.backend.migrations import registry as reg
from vibe_modeling.backend.migrations.v_0_9_0_2 import (
    MIGRATION,
    RUN_TAGS_ENV,
    _frozen_run_tags_default,
    apply,
)
from vibe_modeling.backend.routes._helpers import _get_or_create_agent_config

# pydantic's bool words; the parity test also tries upper and title case.
PYDANTIC_BOOL_WORDS = ("0", "off", "f", "false", "n", "no", "1", "on", "t", "true", "y", "yes")


def _sqlite():
    return create_engine("sqlite://", connect_args={"check_same_thread": False}, poolclass=StaticPool)


def _engine_at_0_9_0_1(*rows: tuple[str, bool]):
    engine = _sqlite()
    SQLModel.metadata.create_all(engine)
    reg._write_installed_version(engine, "0.9.0.1")
    with Session(engine) as session:
        for row_id, value in rows:
            session.add(db.AgentConfig(id=row_id, collect_vibe_run_statistics=value))
        session.commit()
    return engine


def _values(engine) -> dict[str, bool]:
    with Session(engine) as session:
        return {c.id: c.collect_vibe_run_statistics for c in session.exec(select(db.AgentConfig)).all()}


# --- the migration ---------------------------------------------------------------------------


def test_env_unset_turns_an_existing_row_on():
    engine = _engine_at_0_9_0_1(("cfg", False))
    apply(engine)
    assert _values(engine) == {"cfg": True}


@pytest.mark.parametrize("raw", ["false", "FALSE", "0", "no", "off", "n", "f"])
def test_the_opt_out_turns_an_existing_row_off(raw, monkeypatch):
    monkeypatch.setenv(RUN_TAGS_ENV, raw)
    engine = _engine_at_0_9_0_1(("cfg", True))
    apply(engine)
    assert _values(engine) == {"cfg": False}


@pytest.mark.parametrize("raw", ["true", "1", "yes"])
def test_an_explicit_on_turns_an_existing_row_on(raw, monkeypatch):
    monkeypatch.setenv(RUN_TAGS_ENV, raw)
    engine = _engine_at_0_9_0_1(("cfg", False))
    apply(engine)
    assert _values(engine) == {"cfg": True}


def test_empty_table_is_a_no_op():
    engine = _engine_at_0_9_0_1()
    apply(engine)
    assert _values(engine) == {}


def test_missing_table_is_a_no_op():
    engine = _sqlite()
    apply(engine)
    assert not inspect(engine).has_table("agent_config")


def test_a_second_apply_leaves_the_same_state(monkeypatch):
    monkeypatch.setenv(RUN_TAGS_ENV, "false")
    engine = _engine_at_0_9_0_1(("a", True), ("b", False))
    apply(engine)
    apply(engine)
    assert _values(engine) == {"a": False, "b": False}


def _accepted_by_pydantic(raw: str, monkeypatch) -> bool | None:
    monkeypatch.setenv(RUN_TAGS_ENV, raw)
    try:
        return AppConfig(_env_file=None).run_tags_default
    except ValidationError:
        return None


@pytest.mark.parametrize("raw", sorted({v for w in PYDANTIC_BOOL_WORDS for v in (w, w.upper(), w.title())}))
def test_frozen_parser_matches_app_config(raw, monkeypatch):
    parsed = _accepted_by_pydantic(raw, monkeypatch)
    if parsed is None:
        pytest.skip(f"pydantic rejects {raw!r}; the app would not boot, so the migration never sees it")
    assert _frozen_run_tags_default({RUN_TAGS_ENV: raw}) is parsed


def test_frozen_parser_matches_app_config_when_unset(monkeypatch):
    monkeypatch.delenv(RUN_TAGS_ENV, raising=False)
    assert AppConfig(_env_file=None).run_tags_default is True
    assert _frozen_run_tags_default({}) is True


def test_every_lowercase_bool_word_is_accepted_by_pydantic(monkeypatch):
    """The parity test above is only as wide as what pydantic accepts; pin that set."""
    for word in PYDANTIC_BOOL_WORDS:
        assert _accepted_by_pydantic(word, monkeypatch) is not None, word


# --- registry --------------------------------------------------------------------------------


def test_registered_right_after_0_9_0_1():
    versions = [m.version for m in runtime_migrations.MIGRATIONS]
    at = versions.index("0.9.0.2")
    assert versions[at - 1] == "0.9.0.1"
    assert runtime_migrations.MIGRATIONS[at] is MIGRATION


def test_upgrade_from_0_9_0_1_applies_once_and_settings_own_it_after(monkeypatch):
    monkeypatch.setattr(reg, "PRE_PROD_DESTRUCTIVE_RESET", False)
    up_to_this = [m for m in runtime_migrations.MIGRATIONS if reg._vkey(m.version) <= reg._vkey(MIGRATION.version)]
    monkeypatch.setattr(reg, "MIGRATIONS", up_to_this)
    engine = _engine_at_0_9_0_1(("cfg", False))

    reg.reconcile_schema(engine)
    assert reg._read_installed_version(engine) == "0.9.0.2"
    assert _values(engine) == {"cfg": True}

    with Session(engine) as session:
        session.get(db.AgentConfig, "cfg").collect_vibe_run_statistics = False
        session.commit()
    reg.reconcile_schema(engine)
    assert _values(engine) == {"cfg": False}


def test_fresh_install_leaves_agent_config_empty():
    engine = _sqlite()
    reg.reconcile_schema(engine)
    assert reg._read_installed_version(engine) == runtime_migrations.MIGRATIONS[-1].version
    assert _values(engine) == {}


# --- the row-creation seed -------------------------------------------------------------------


@pytest.mark.parametrize("seed", [True, False])
def test_a_new_row_is_seeded_from_the_install_default(seed):
    engine = _engine_at_0_9_0_1()
    with Session(engine) as session:
        cfg = _get_or_create_agent_config(session, AppConfig(_env_file=None, run_tags_default=seed))
        assert cfg.collect_vibe_run_statistics is seed


def test_the_default_seed_is_on():
    engine = _engine_at_0_9_0_1()
    with Session(engine) as session:
        assert _get_or_create_agent_config(session, AppConfig(_env_file=None)).collect_vibe_run_statistics is True


def test_an_existing_row_is_not_reseeded():
    engine = _engine_at_0_9_0_1(("cfg", True))
    with Session(engine) as session:
        cfg = _get_or_create_agent_config(session, AppConfig(_env_file=None, run_tags_default=False))
        assert (cfg.id, cfg.collect_vibe_run_statistics) == ("cfg", True)
