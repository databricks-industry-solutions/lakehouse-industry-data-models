"""Everything works from the app in a catalog the agent never ran in.

Maintainer decision (2026-10-26): "Create the tables. Everything should work
from the app without having to do a first agent run." A download, then a
kickstart from it, then the vibe pre-flight's parent check on either version,
all succeed in a fresh deployment catalog: the first registry seed creates
the agent's four tables (``metamodel_registry.ensure_metamodel_registry``) with
exactly the agent's columns, and the seed rows land. The out-of-band scan and
the cleanup sweep read a catalog with no tables as empty. Runs on the
recording UC fake and its SQL side.
"""
from __future__ import annotations

import pytest
from sqlmodel import Session, select

from vibe_modeling.backend.core._metamodel_cleanups import (
    REASON_VERSION_DELETE,
    record_cleanups,
    sweep_metamodel_cleanups,
)
from vibe_modeling.backend.db_models import AgentConfig, MetamodelCleanup, ModelVersion, Run, Sector
from vibe_modeling.backend.models import Intent, RunIn
from vibe_modeling.backend.oob_detector import OobDetector
from vibe_modeling.backend.services.industry_download import download_industry_model
from vibe_modeling.backend.services.industry_kickstart import kickstart_from_industry
from vibe_modeling.backend.services.orchestrator.preflight import _check_metamodel_parent_version_present

from ._drift.fake_uc import REGISTRY_TABLES, agent_registry_columns
from ._drift.fixtures import fake_uc  # noqa: F401
from .test_industry_models import _FakeConnector, _patch_connector

CAT = "test_deployment_catalog"
WH = "wh-fresh"


@pytest.fixture
def sector_id(engine):
    with Session(engine) as session:
        s = Sector(name="Retail", short_name="retail")
        session.add(s)
        session.add(AgentConfig(deployment_catalog=CAT, warehouse_id=WH))
        session.commit()
        return s.id


def _parent_gate(engine, fake, business_id, version_id):
    with Session(engine) as session:
        agent_config = session.exec(select(AgentConfig)).first()
        return _check_metamodel_parent_version_present(
            business_id, RunIn(intent=Intent.VIBE_ITERATE, version_id=version_id),
            agent_config, session, fake.ws, live=True,
        )


def test_download_kickstart_and_vibe_preflight_need_no_agent_run(engine, fake_uc, config, sector_id, monkeypatch):
    fake_uc.add_catalog(CAT)
    _patch_connector(monkeypatch, _FakeConnector())

    with Session(engine) as session:
        downloaded = download_industry_model(
            session, fake_uc.ws, config=config, sector_id=sector_id, industry_id="retail", model_id="v1_ecm",
        )

    assert downloaded.warnings == []
    for table in REGISTRY_TABLES:
        assert fake_uc.columns(CAT, table) == agent_registry_columns(table)
    industry_rows = fake_uc.registry_entry(CAT, "acme_retail_industry", 1, "ecm")
    assert industry_rows is not None and industry_rows.business_rows == 1 and industry_rows.domains > 0
    assert _parent_gate(engine, fake_uc, downloaded.business_id, downloaded.version_id) is None

    with Session(engine) as session:
        kicked = kickstart_from_industry(
            session, fake_uc.ws, source_industry_id=downloaded.business_id, source_version=1, new_name="Kick Co",
        )
        kicked_id = kicked.id
    with Session(engine) as session:
        run = session.exec(select(Run).where(Run.business_id == kicked_id)).one()
        assert run.status == "completed", run.error_message
        kicked_mv = session.exec(select(ModelVersion).where(ModelVersion.business_id == kicked_id)).one()
    kicked_rows = fake_uc.registry_entry(CAT, "kick_co", 1, "ecm")
    assert kicked_rows is not None and kicked_rows.domains == industry_rows.domains
    assert _parent_gate(engine, fake_uc, kicked_id, kicked_mv.id) is None

    ddl = [c.args["statement"] for c in fake_uc.calls_to("sql.ddl")]
    assert len(ddl) == len(REGISTRY_TABLES) and all(s.startswith("CREATE TABLE IF NOT EXISTS") for s in ddl)


def test_a_second_download_runs_no_ddl(engine, fake_uc, config, sector_id, monkeypatch):
    fake_uc.add_metamodel(CAT)
    _patch_connector(monkeypatch, _FakeConnector())

    with Session(engine) as session:
        downloaded = download_industry_model(
            session, fake_uc.ws, config=config, sector_id=sector_id, industry_id="retail", model_id="v1_ecm",
        )

    assert downloaded.warnings == []
    assert fake_uc.calls_to("sql.ddl") == []
    assert [c.seam for c in fake_uc.calls if c.seam.endswith(".create")] == []
    assert fake_uc.registry_entry(CAT, "acme_retail_industry", 1, "ecm") is not None


def test_a_failed_registry_setup_is_a_download_warning(engine, fake_uc, config, sector_id, monkeypatch):
    fake_uc.add_catalog(CAT)
    fake_uc.ddl_error = "[INSUFFICIENT_PERMISSIONS] no CREATE TABLE"
    _patch_connector(monkeypatch, _FakeConnector())

    with Session(engine) as session:
        downloaded = download_industry_model(
            session, fake_uc.ws, config=config, sector_id=sector_id, industry_id="retail", model_id="v1_ecm",
        )

    assert len(downloaded.warnings) == 1
    assert "can't be the base of a vibe run" in downloaded.warnings[0]
    assert "CREATE_TABLE" in downloaded.warnings[0]
    assert "INSUFFICIENT_PERMISSIONS" not in downloaded.warnings[0]
    assert fake_uc.registry(CAT) == []


def test_a_failed_seed_still_copies_the_kickstart_artifacts(engine, fake_uc, config, sector_id, monkeypatch):
    fake_uc.add_catalog(CAT)
    _patch_connector(monkeypatch, _FakeConnector())
    with Session(engine) as session:
        downloaded = download_industry_model(
            session, fake_uc.ws, config=config, sector_id=sector_id, industry_id="retail", model_id="v1_ecm",
        )
    # The registry is gone again (dropped by hand) and the app can't recreate it.
    del fake_uc._registry[CAT]
    fake_uc._columns.pop(CAT)
    fake_uc.ddl_error = "[INSUFFICIENT_PERMISSIONS] no CREATE TABLE"

    with Session(engine) as session:
        kicked = kickstart_from_industry(
            session, fake_uc.ws, source_industry_id=downloaded.business_id, source_version=1, new_name="Kick Co",
        )
        kicked_id = kicked.id

    with Session(engine) as session:
        run = session.exec(select(Run).where(Run.business_id == kicked_id)).one()
    assert run.status == "failed"
    assert "_metamodel seed failed for ecm v1" in run.error_message
    assert "artifacts were copied" in run.progress_message
    copied = [c.args["file_path"] for c in fake_uc.calls_to("files.upload") if "/kick_co/" in c.args["file_path"]]
    assert copied, "phase 2 copied the artifacts after the failed seed"


def test_out_of_band_scan_of_a_catalog_with_no_registry_is_empty(engine, fake_uc):
    fake_uc.add_catalog(CAT)
    with Session(engine) as session:
        assert OobDetector(session, fake_uc.ws, WH).detect(CAT) == []
    assert [c.seam for c in fake_uc.calls] == ["query_completed_versions"]


def test_cleanup_sweep_of_a_catalog_with_no_registry_finishes_the_rows(engine, fake_uc):
    fake_uc.add_catalog(CAT)
    with Session(engine) as session:
        record_cleanups(session, business_segment="gone_co", version=1, scope="ecm",
                        catalogs=[CAT], reason=REASON_VERSION_DELETE)
        session.commit()
        summary = sweep_metamodel_cleanups(session, fake_uc.ws, WH)
        session.commit()
        rows = session.exec(select(MetamodelCleanup)).all()
    assert summary.failed == 0
    assert all(r.status == "done" for r in rows), [(r.status, r.last_error) for r in rows]
    assert fake_uc.calls_to("sql.ddl") == []
