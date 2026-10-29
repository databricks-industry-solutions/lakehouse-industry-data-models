"""The one settings seeder (``core/_settings_seed``) and every caller of it.

Matrix: stored value (NULL, empty, whitespace, saved) x install default
(empty, whitespace, set, padded) x executor (``Connection``, ``Session``),
over the two settings boot seeds (``AgentConfig.taxonomy_model_service``,
``AssessConfig.reader_application_id``) and a nullable column. Then row
creation (``get_or_create_settings_row``) through its three callers.
"""

from __future__ import annotations

from typing import Optional

import pytest
from sqlalchemy import String, create_engine, select
from sqlalchemy.orm import DeclarativeBase, Mapped, mapped_column
from sqlalchemy.pool import StaticPool
from sqlmodel import Session, SQLModel

from vibe_modeling.backend.assessment.config_service import get_or_create_assess_config, seed_reader_from_install
from vibe_modeling.backend.core._config import AppConfig
from vibe_modeling.backend.core._settings_seed import get_or_create_settings_row, seed_blank
from vibe_modeling.backend.core._taxonomy_seed import seed_taxonomy_model_service
from vibe_modeling.backend.db_models import AgentConfig, AssessConfig
from vibe_modeling.backend.routes._helpers import _get_or_create_agent_config

DEFAULT = "system.ai.claude-sonnet-5-5"


class _Base(DeclarativeBase):
    pass


class _NullableSettings(_Base):
    """A settings row whose column allows NULL, as a column added by a migration does on Postgres."""

    __tablename__ = "nullable_settings"
    id: Mapped[int] = mapped_column(primary_key=True)
    value: Mapped[Optional[str]] = mapped_column(String, nullable=True)


@pytest.fixture
def engine():
    eng = create_engine("sqlite://", connect_args={"check_same_thread": False}, poolclass=StaticPool)
    SQLModel.metadata.create_all(eng)
    _Base.metadata.create_all(eng)
    return eng


STORED = ["", "   ", "saved.value"]
DEFAULTS = [("", None), ("   ", None), (DEFAULT, DEFAULT), (f"  {DEFAULT} ", DEFAULT)]
TARGETS = [
    pytest.param(AgentConfig, AgentConfig.taxonomy_model_service, id="agent_config.taxonomy_model_service"),
    pytest.param(AssessConfig, AssessConfig.reader_application_id, id="assess_config.reader_application_id"),
]


def _run(engine, executor_kind, column, value):
    if executor_kind == "connection":
        with engine.begin() as conn:
            return seed_blank(conn, column, value)
    with Session(engine) as s:
        n = seed_blank(s, column, value)
        s.commit()
        return n


def _read(engine, column):
    with engine.connect() as conn:
        return conn.execute(select(column)).scalar_one()


@pytest.mark.parametrize("executor_kind", ["connection", "session"])
@pytest.mark.parametrize("default,seeded", DEFAULTS)
@pytest.mark.parametrize("stored", STORED)
@pytest.mark.parametrize("model,column", TARGETS)
def test_seed_blank_matrix(engine, model, column, stored, default, seeded, executor_kind):
    with Session(engine) as s:
        s.add(model(**{column.key: stored}))
        s.commit()
    n = _run(engine, executor_kind, column, default)
    blank = not stored.strip()
    if blank and seeded:
        assert n == 1 and _read(engine, column) == seeded
    else:
        assert n == 0 and _read(engine, column) == stored
    assert _run(engine, executor_kind, column, default) == 0  # idempotent


@pytest.mark.parametrize("executor_kind", ["connection", "session"])
def test_seed_blank_fills_null(engine, executor_kind):
    with Session(engine) as s:
        s.add(_NullableSettings(id=1, value=None))
        s.commit()
    assert _run(engine, executor_kind, _NullableSettings.value, " v ") == 1
    assert _read(engine, _NullableSettings.value) == "v"


def test_seed_blank_on_an_empty_table_updates_nothing(engine):
    assert _run(engine, "connection", AgentConfig.taxonomy_model_service, DEFAULT) == 0
    with Session(engine) as s:
        assert s.exec(select(AgentConfig)).first() is None


# --- the two boot seeds go through seed_blank --------------------------------------


@pytest.mark.parametrize("stored", STORED)
@pytest.mark.parametrize("default,seeded", DEFAULTS)
def test_taxonomy_boot_seed(engine, stored, default, seeded):
    with Session(engine) as s:
        s.add(AgentConfig(taxonomy_model_service=stored))
        s.commit()
    n = seed_taxonomy_model_service(engine, AppConfig(taxonomy_builder_enabled=True, taxonomy_model_service=default))
    expected = seeded if (seeded and not stored.strip()) else stored
    assert n == (1 if expected != stored else 0)
    assert _read(engine, AgentConfig.taxonomy_model_service) == expected


@pytest.mark.parametrize("stored", STORED)
@pytest.mark.parametrize("default,seeded", DEFAULTS)
def test_assessment_reader_boot_seed(engine, stored, default, seeded):
    with Session(engine) as s:
        s.add(AssessConfig(reader_application_id=stored))
        s.commit()
        n = seed_reader_from_install(s, AppConfig(assess_reader_sp=default))
        s.commit()
    expected = seeded if (seeded and not stored.strip()) else stored
    assert n == (1 if expected != stored else 0)
    assert _read(engine, AssessConfig.reader_application_id) == expected


def test_taxonomy_boot_seed_is_a_no_op_when_not_installed(engine):
    with Session(engine) as s:
        s.add(AgentConfig(taxonomy_model_service=""))
        s.commit()
    assert seed_taxonomy_model_service(engine, AppConfig(taxonomy_builder_enabled=False, taxonomy_model_service=DEFAULT)) == 0
    assert _read(engine, AgentConfig.taxonomy_model_service) == ""


# --- row creation ---------------------------------------------------------------------


def test_get_or_create_creates_once_with_the_defaults(engine):
    with Session(engine) as s:
        first = get_or_create_settings_row(s, AssessConfig, {"reader_application_id": "r1"})
        again = get_or_create_settings_row(s, AssessConfig, {"reader_application_id": "r2"})
        assert first.id == again.id and again.reader_application_id == "r1"
        assert len(s.exec(select(AssessConfig)).all()) == 1


def test_agent_config_row_creation_seeds_the_install_defaults(engine):
    config = AppConfig(taxonomy_builder_enabled=True, taxonomy_model_service=DEFAULT,
                       deployment_catalog="cat", warehouse_id="wh")
    with Session(engine) as s:
        cfg = _get_or_create_agent_config(s, config)
        assert (cfg.taxonomy_model_service, cfg.deployment_catalog, cfg.warehouse_id) == (DEFAULT, "cat", "wh")
        assert cfg.github_repo_owner and cfg.github_repo_name
        cfg.taxonomy_model_service = "saved.in.settings"
        s.add(cfg)
        s.commit()
        assert _get_or_create_agent_config(s, config).taxonomy_model_service == "saved.in.settings"


@pytest.mark.parametrize("reader,expected", [("", ""), ("  app-1 ", "app-1")])
def test_assess_config_row_creation_seeds_the_reader(engine, reader, expected):
    with Session(engine) as s:
        assert get_or_create_assess_config(s, AppConfig(assess_reader_sp=reader)).reader_application_id == expected
