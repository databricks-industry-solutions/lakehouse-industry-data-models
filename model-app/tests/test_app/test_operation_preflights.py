"""Operation preflights: config-missing hard-fails with an actionable 422.

Track 4 (task 6gr28vmRrmQJWHRq): kickstart / download / import / resync / sync
and the initial-sync + OOB endpoints must 422 with a ``config_missing`` payload
BEFORE creating anything when the metamodel catalog or warehouse is unset,
instead of silently degrading (skeleton business, silent no-op seed).
"""

from __future__ import annotations

import pytest
from sqlmodel import Session

from vibe_modeling.backend.db_models import AgentConfig


def _seed_empty_agent(engine):
    """AgentConfig row with catalog + warehouse UNSET (source repo unset too)."""
    with Session(engine) as s:
        s.add(AgentConfig(notebook_path="/nb", job_id=1, deployment_catalog="", warehouse_id=""))
        s.commit()


def _assert_config_missing(resp):
    assert resp.status_code == 422, resp.text
    detail = resp.json()["detail"]
    assert detail["error"] == "config_missing"
    assert detail["missing"]
    for m in detail["missing"]:
        assert m["settings_url"].startswith("/settings?tab=")


def test_initial_sync_422_when_unconfigured(client, engine):
    _seed_empty_agent(engine)
    _assert_config_missing(client.post("/api/config/initial-sync"))


def test_oob_check_now_422_when_unconfigured(client, engine):
    _seed_empty_agent(engine)
    _assert_config_missing(client.post("/api/oob/check"))


def test_oob_import_new_businesses_422_when_unconfigured(client, engine):
    _seed_empty_agent(engine)
    _assert_config_missing(client.post("/api/oob/import-new-businesses"))


def test_download_422_when_unconfigured(client, engine):
    _seed_empty_agent(engine)
    resp = client.post(
        "/api/industry-models/download",
        json={"sector_id": "s", "industry_id": "i", "model_id": "m"},
    )
    _assert_config_missing(resp)


def test_download_missing_lists_catalog_and_warehouse(client, engine):
    _seed_empty_agent(engine)
    resp = client.post(
        "/api/industry-models/download",
        json={"sector_id": "s", "industry_id": "i", "model_id": "m"},
    )
    keys = {m["key"] for m in resp.json()["detail"]["missing"]}
    # metamodel catalog + warehouse are genuinely missing here.
    assert {"metamodel_catalog", "warehouse"} <= keys
    # source_repo is NOT missing: it is seeded on row creation, and the
    # connector falls back to the public repo, so it is effectively always
    # present (decision 27).
    assert "source_repo" not in keys


def test_import_create_business_422_when_unconfigured(client, engine):
    _seed_empty_agent(engine)
    resp = client.post(
        "/api/import/create-business-and-execute",
        json={"volume_path": "/Volumes/x/y/model.json"},
    )
    _assert_config_missing(resp)


@pytest.mark.parametrize(
    "seed",
    [
        dict(deployment_catalog="", warehouse_id="wh"),  # metamodel missing
        dict(deployment_catalog="cat", warehouse_id=""),  # warehouse missing
        dict(deployment_catalog="", warehouse_id=""),  # both missing
    ],
)
def test_initial_sync_gate_matrix_missing_keys(client, engine, seed):
    """Each missing config key on initial-sync yields a 422 config_missing."""
    with Session(engine) as s:
        s.add(AgentConfig(notebook_path="/nb", job_id=1, **seed))
        s.commit()
    _assert_config_missing(client.post("/api/config/initial-sync"))


def test_resync_no_catalog_returns_422_before_teardown(client, engine):
    """force-resync of a draft with no per-version catalog AND no installation
    metamodel catalog returns the structured 422 config_missing BEFORE any
    destructive clear (preflight-before-teardown)."""
    from vibe_modeling.backend.db_models import Business, ModelVersion

    with Session(engine) as s:
        # Warehouse set (so warehouse passes), metamodel catalog empty.
        s.add(AgentConfig(notebook_path="/nb", job_id=1, deployment_catalog="", warehouse_id="wh"))
        biz = Business(name="Resync Draft Co", kind="business")
        s.add(biz)
        s.flush()
        mv = ModelVersion(business_id=biz.id, version=1, scope="ecm", status="completed", uc_catalog="")
        s.add(mv)
        s.commit()
        bid, vid = biz.id, mv.id
    resp = client.post(f"/api/businesses/{bid}/versions/{vid}/resync")
    assert resp.status_code == 422, resp.text
    detail = resp.json()["detail"]
    assert detail["error"] == "config_missing"
    assert "metamodel_catalog" in {m["key"] for m in detail["missing"]}
