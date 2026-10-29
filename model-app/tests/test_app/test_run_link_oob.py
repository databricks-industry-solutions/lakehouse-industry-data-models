"""An out-of-band import, then Link to run, through the routes.

A run started by hand from the agent notebook (the captured ``get_run`` of
``tests/fixtures/jobs_get_run_5_3_3.json``, business ``wt_p0_grain_coop`` in
catalog ``business_3``) writes ECM v1 and MVM v1. The banner imports them
(``POST /businesses/{id}/oob/import``, the real ``initial_sync`` writer over
the recording UC fake), and the version page links each to its Databricks run.
"""

from __future__ import annotations

import os
import sys

import pytest
from databricks.sdk.service.sql import State
from sqlmodel import Session, select

from vibe_modeling.backend import run_link
from vibe_modeling.backend.core._roles import UserRole
from vibe_modeling.backend.db_models import AgentConfig, Business, ModelVersion
from vibe_modeling.backend.oob_detector import OobCheckCache
from vibe_modeling.backend.routes import oob as oob_routes

from ._drift.fixtures import fake_uc, mock_model  # noqa: F401
from .test_run_link import (
    BASE_ID, BASE_RUN, BASE_SID, CAT, SHRINK_ID, SHRINK_RUN, SHRINK_SID,
    FakeRegistry, both_written, client, job_run, link, preview, runs_of,
)

sys.path.insert(0, os.path.dirname(__file__))
from _assess_helpers import changed_tables, table_digests  # noqa: E402

BUSINESS = "WT P0 Grain Coop"


@pytest.fixture
def setup(engine, fake_uc, config, monkeypatch):
    monkeypatch.setattr(oob_routes, "OOB_CHECKS", OobCheckCache(spawn=lambda fn: fn()))
    registry = FakeRegistry()
    monkeypatch.setattr(run_link, "rows", registry.rows)
    with Session(engine) as s:
        s.add(AgentConfig(notebook_path="/nb", job_id=1, deployment_catalog=CAT, warehouse_id="wh"))
        business = Business(name=BUSINESS)
        s.add(business)
        s.commit()
        business_id = business.id
    fake_uc.ws.warehouses.get.return_value.state = State.RUNNING
    fake_uc.add_agent_version(CAT, BUSINESS, 1, "ecm", mock_model(), session_id=BASE_SID)
    fake_uc.add_agent_version(CAT, BUSINESS, 1, "mvm", mock_model(), session_id=SHRINK_SID)
    runs = {BASE_ID: job_run(BASE_RUN), SHRINK_ID: job_run(SHRINK_RUN)}
    fake_uc.ws.jobs.get_run.side_effect = lambda run_id: runs[run_id]
    both_written(registry)
    return business_id, registry


def _import(engine, fake_uc, config, business_id) -> dict[str, str]:
    resp = client(engine, fake_uc.ws, config, UserRole.MODELER).post(f"/api/businesses/{business_id}/oob/import")
    assert resp.status_code == 200, resp.text
    assert resp.json()["imported_versions"] == 2
    with Session(engine) as s:
        return {mv.scope: mv.id for mv in s.exec(select(ModelVersion)).all()}


def test_import_preview_and_link_a_hand_started_run(engine, fake_uc, config, setup):
    business_id, _registry = setup
    versions = _import(engine, fake_uc, config, business_id)
    with Session(engine) as s:
        row = s.get(ModelVersion, versions["ecm"])
        assert row.import_source_path is None and row.imported_at is None and row.files_catalog == CAT

    c = client(engine, fake_uc.ws, config)
    listed = {v["id"]: v for v in c.get(f"/api/businesses/{business_id}/versions").json()}
    assert listed[versions["ecm"]]["is_imported"] is True and listed[versions["mvm"]]["is_imported"] is True

    before = table_digests(engine)
    body = preview(c, business_id, versions["ecm"], BASE_ID).json()
    assert body["linkable"] is True and body["tier"] == 1 and body["intent"] == "new-base-model", body
    assert changed_tables(before, table_digests(engine)) == set()

    first = link(c, business_id, versions["ecm"], BASE_ID)
    assert first.status_code == 200, first.text
    second = link(c, business_id, versions["mvm"], SHRINK_ID)
    assert second.status_code == 200, second.text
    assert second.json()["id"] == first.json()["id"]

    ((run, ops),) = runs_of(engine, business_id)
    assert run.intent == "new-base-model" and run.link_evidence.startswith("Tier 1:")
    assert [(o.step_index, o.operation_name, o.output_version_id) for o in ops] == [
        (0, "generate_ecm", versions["ecm"]), (1, "shrink_to_mvm", versions["mvm"]),
    ]
    with Session(engine) as s:
        assert s.get(ModelVersion, versions["ecm"]).import_source_path is None
    listed = {v["id"]: v for v in c.get(f"/api/businesses/{business_id}/versions").json()}
    assert {listed[v]["linked_run_id"] for v in versions.values()} == {run.id}


def test_a_run_of_another_version_is_refused_and_writes_nothing(engine, fake_uc, config, setup):
    business_id, _registry = setup
    versions = _import(engine, fake_uc, config, business_id)
    c = client(engine, fake_uc.ws, config)
    before = table_digests(engine)
    resp = link(c, business_id, versions["mvm"], BASE_ID)
    assert resp.status_code == 422
    assert resp.json()["detail"]["problems"] == ["This run wrote v1 ECM of wt_p0_grain_coop, not v1 MVM of wt_p0_grain_coop."]
    assert changed_tables(before, table_digests(engine)) == set()
