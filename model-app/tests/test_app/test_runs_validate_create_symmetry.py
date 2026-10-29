"""Cross-endpoint symmetry between POST /api/runs/validate and POST /api/runs.

The validate endpoint is meant to give live form feedback that's
EQUIVALENT to what the create endpoint will accept or reject. If validate
says "no blockers" but create rejects with 400, the user gets a confusing
"submit failed without warning" experience. Phase 4.5 surfaced this when
validate skipped the metamodel-catalog gate that create enforced.

This test runs every "rejection-inducing body" through both endpoints and
asserts:
- If create rejects (4xx), validate must surface ≥1 blocker.
- The blocker's message must be non-empty.

Pattern guard: any future create-time gate added to /api/runs MUST also
appear in /api/runs/validate. Adding a gate to one without the other
will fail this test on the first parametrized case.
"""
from __future__ import annotations

import json
from uuid import uuid4

import pytest
from sqlmodel import Session

from vibe_modeling.backend.services import metamodel_setup
from vibe_modeling.backend.db_models import (
    AgentConfig,
    Business,
    Industry,
    ModelVersion,
    Run,
)

from .conftest import stub_no_metamodel


def _seed_business(engine, *, name="symmetry-biz") -> str:
    with Session(engine) as s:
        ind = Industry(name="Test", short_name="test", description="x")
        s.add(ind)
        s.flush()
        b = Business(name=name, description="t", industry_id=ind.id)
        s.add(b)
        s.flush()
        s.commit()
        return b.id


def _seed_agent_config(engine, *,
                      notebook_path="/Workspace/agent.ipynb",
                      deployment_catalog="metamodel_cat") -> None:
    with Session(engine) as s:
        # Best-effort upsert: the table allows only one row per the existing
        # router behaviour, so we either insert or update the singleton.
        existing = s.exec(  # type: ignore[attr-defined]
            __import__("sqlmodel").select(AgentConfig).limit(1)
        ).first()
        if existing is None:
            s.add(AgentConfig(
                notebook_path=notebook_path,
                deployment_catalog=deployment_catalog,
                warehouse_id="wh-1",
                job_id=1,
                job_name="dbx_test",
            ))
        else:
            existing.notebook_path = notebook_path
            existing.deployment_catalog = deployment_catalog
            s.add(existing)
        s.commit()


@pytest.fixture
def biz_id(engine):
    return _seed_business(engine)


# Each case is (label, body_extras, set_agent_config). The body always
# includes a known business_id (biz_id fixture), the test runs both
# endpoints, asserts validate has ≥1 blocker iff create returns 4xx.
_USE_FIXTURE_BID = object()


SYMMETRY_CASES = [
    pytest.param(
        "no_agent_config",
        {"intent": "new-base-model", "catalog": "tgt", "cataloging_style": "One Catalog"},
        False,  # don't seed agent_config
        _USE_FIXTURE_BID,
        id="no-agent-config",
    ),
    pytest.param(
        "no_metamodel_catalog",
        {"intent": "new-base-model", "catalog": "tgt", "cataloging_style": "One Catalog"},
        "no_catalog",  # seed agent_config but with empty deployment_catalog
        _USE_FIXTURE_BID,
        id="no-metamodel-catalog",
    ),
    pytest.param(
        "one_catalog_no_target_no_fallback",
        {"intent": "new-base-model", "catalog": "", "cataloging_style": "One Catalog"},
        "no_catalog",
        _USE_FIXTURE_BID,
        id="one-catalog-mode-no-target-no-fallback",
    ),
    pytest.param(
        "missing_business_id",
        {"intent": "new-base-model", "catalog": "tgt", "cataloging_style": "One Catalog"},
        True,
        "nonexistent-uuid",
        id="missing-business",
    ),
]


@pytest.mark.parametrize("label,body_extras,seed_cfg,url_bid", SYMMETRY_CASES)
def test_create_rejection_appears_as_validate_blocker(
    client, engine, biz_id, label, body_extras, seed_cfg, url_bid
):
    """For every body that POST /api/runs rejects, POST /api/runs/validate
    must surface at least one blocker. Catches future gates added to
    create without a matching validate update."""
    if seed_cfg is True:
        _seed_agent_config(engine)
    elif seed_cfg == "no_catalog":
        _seed_agent_config(engine, deployment_catalog="")
    # else: don't seed at all

    target_bid = biz_id if url_bid is _USE_FIXTURE_BID else url_bid
    body = {**body_extras}

    # Hit validate first (no side effects).
    v_resp = client.post(f"/api/businesses/{target_bid}/runs/validate", json=body)
    create_resp = client.post(f"/api/businesses/{target_bid}/runs", json=body)

    if 400 <= create_resp.status_code < 500:
        # Validate MUST have surfaced a blocker.
        assert v_resp.status_code == 200, (
            f"[{label}] validate should be 200 with blockers, got "
            f"{v_resp.status_code}: {v_resp.text}"
        )
        v_body = v_resp.json()
        blockers = v_body.get("blockers", [])
        assert len(blockers) >= 1, (
            f"[{label}] validate returned no blockers but create rejected "
            f"with {create_resp.status_code}: {create_resp.text}"
        )
        for b in blockers:
            assert b.get("message", "").strip(), (
                f"[{label}] blocker has empty message: {b}"
            )


def test_create_run_config_missing_returns_structured_422(client, engine, biz_id):
    """Run dispatch with the metamodel catalog cleared returns the SAME
    structured 422 config_missing payload the other operations emit - not a
    bare 400 string (tester finding #1)."""
    _seed_agent_config(engine, deployment_catalog="")  # notebook+job+warehouse set
    resp = client.post(
        f"/api/businesses/{biz_id}/runs",
        json={"intent": "new-base-model", "catalog": "tgt", "cataloging_style": "One Catalog"},
    )
    assert resp.status_code == 422, resp.text
    detail = resp.json()["detail"]
    assert detail["error"] == "config_missing"
    keys = {m["key"] for m in detail["missing"]}
    assert "metamodel_catalog" in keys
    for m in detail["missing"]:
        assert m["settings_url"].startswith("/settings?tab=")
        assert m["label"]


def test_create_run_warehouse_missing_returns_structured_422(client, engine, biz_id):
    """Same structured 422 when only the warehouse is unset."""
    with Session(engine) as s:
        s.add(AgentConfig(
            notebook_path="/Workspace/agent.ipynb", deployment_catalog="cat",
            warehouse_id="", job_id=1, job_name="dbx_test",
        ))
        s.commit()
    resp = client.post(
        f"/api/businesses/{biz_id}/runs",
        json={"intent": "new-base-model", "catalog": "tgt", "cataloging_style": "One Catalog"},
    )
    assert resp.status_code == 422, resp.text
    assert resp.json()["detail"]["error"] == "config_missing"
    assert "warehouse" in {m["key"] for m in resp.json()["detail"]["missing"]}


def test_missing_metamodel_schema_new_base_model_warns_then_autocreates(
    client, engine, biz_id, mock_ws
):
    """new-base-model with no ``_metamodel`` in the target catalog is NOT a
    blocker: validate warns (creating nothing); create sets it up itself and,
    when the app SP lacks CREATE_SCHEMA, rejects with a catalog-scoped 400.
    Other intents keep the symmetric blocker (see test_metamodel_autosetup)."""
    from databricks.sdk.errors import PermissionDenied

    _seed_agent_config(engine)
    stub_no_metamodel(mock_ws)
    body = {
        "intent": "new-base-model",
        "catalog": "tgt_no_metamodel",
        "cataloging_style": "One Catalog",
    }

    v_resp = client.post(f"/api/businesses/{biz_id}/runs/validate", json=body)
    assert v_resp.status_code == 200, v_resp.text
    assert not any(
        "_metamodel" in (b.get("message") or "") for b in v_resp.json()["blockers"]
    ), json.dumps(v_resp.json(), indent=2)
    assert any(
        w.get("field_path") == "catalog" and "_metamodel" in (w.get("message") or "")
        for w in v_resp.json()["warnings"]
    )
    mock_ws.schemas.create.assert_not_called()

    mock_ws.schemas.create.side_effect = PermissionDenied("denied")
    c_resp = client.post(f"/api/businesses/{biz_id}/runs", json=body)
    assert c_resp.status_code == 400, c_resp.text
    assert "_metamodel" in c_resp.text


def test_missing_metamodel_schema_install_rejects_on_both_endpoints(
    client, engine, biz_id, mock_ws
):
    """A gated intent (install) with no ``_metamodel`` in the target catalog
    is refused on BOTH endpoints: validate surfaces a catalog blocker, create
    400s mentioning ``_metamodel``, and nothing is created."""
    _seed_agent_config(engine)
    with Session(engine) as s:
        mv = ModelVersion(
            business_id=biz_id, version=1, status="completed",
            deployment_status="draft", scope="ecm", uc_catalog="tgt_no_metamodel",
        )
        s.add(mv)
        s.commit()
        s.refresh(mv)
        vid = mv.id
    stub_no_metamodel(mock_ws)
    body = {
        "intent": "install",
        "version_id": vid,
        "scope": "ecm",
        "version_int": 1,
        "catalog": "tgt_no_metamodel",
        "deployment_catalog": "tgt_no_metamodel",
        "schema_prefix": "ecm_",
        "cataloging_style": "One Catalog",
    }

    v_resp = client.post(f"/api/businesses/{biz_id}/runs/validate", json=body)
    assert v_resp.status_code == 200, v_resp.text
    assert any(
        b.get("field_path") == "catalog" and "_metamodel" in (b.get("message") or "")
        for b in v_resp.json()["blockers"]
    ), json.dumps(v_resp.json(), indent=2)

    c_resp = client.post(f"/api/businesses/{biz_id}/runs", json=body)
    assert c_resp.status_code == 400, c_resp.text
    assert "_metamodel" in c_resp.text
    mock_ws.schemas.create.assert_not_called()
    mock_ws.volumes.create.assert_not_called()


def test_active_run_lock_is_a_validate_blocker(client, engine, biz_id):
    """Specific case: the 409 'business already has an active run' lock
    must surface as a validate blocker too. Otherwise the user sees a
    clean validate, hits Submit, and gets a 409."""
    _seed_agent_config(engine)
    # Manually insert an in-flight run so the active-run lock fires.
    with Session(engine) as s:
        s.add(Run(
            id=str(uuid4()),
            business_id=biz_id,
            intent="new-base-model",
            status="running",
        ))
        s.commit()

    body = {
        "intent": "new-base-model",
        "catalog": "tgt",
        "cataloging_style": "One Catalog",
    }
    v_resp = client.post(f"/api/businesses/{biz_id}/runs/validate", json=body)
    create_resp = client.post(f"/api/businesses/{biz_id}/runs", json=body)

    assert create_resp.status_code in (400, 409), (
        f"create should reject with 400/409 due to active run; got "
        f"{create_resp.status_code}: {create_resp.text}"
    )
    v_body = v_resp.json()
    blockers = v_body.get("blockers", [])
    assert any(
        "active run" in (b.get("message") or "").lower()
        for b in blockers
    ), (
        f"validate did not surface the active-run lock as a blocker: "
        f"{json.dumps(blockers, indent=2)}"
    )


_NEW_BASE_MODEL_NEEDS_EMPTY_BUSINESS = (
    "New Base Model needs a business with no model versions. "
    "Delete its versions one by one from their pages (uninstall installed ones first), "
    "or create a new business."
)
_NEW_BASE_MODEL_BODY = {
    "intent": "new-base-model",
    "catalog": "tgt_no_metamodel",
    "cataloging_style": "One Catalog",
}


@pytest.mark.parametrize("status", ["completed", "superseded"])
def test_new_base_model_rejected_when_business_has_versions(
    client, engine, biz_id, mock_ws, monkeypatch, status
):
    """A business with any ModelVersion row (any scope, any status including
    superseded) cannot start a new base model: validate surfaces a blocker on
    ``intent``, create 400s with the same message, and no ``_metamodel`` setup
    runs."""
    from unittest.mock import MagicMock

    _seed_agent_config(engine)
    with Session(engine) as s:
        s.add(ModelVersion(
            business_id=biz_id, version=1, status=status,
            deployment_status="draft", scope="ecm", uc_catalog="tgt_no_metamodel",
        ))
        s.commit()
    stub_no_metamodel(mock_ws)
    spy = MagicMock()
    monkeypatch.setattr(metamodel_setup, "ensure_metamodel_schema_and_volume", spy)

    v_resp = client.post(f"/api/businesses/{biz_id}/runs/validate", json=_NEW_BASE_MODEL_BODY)
    assert v_resp.status_code == 200, v_resp.text
    assert any(
        b.get("field_path") == "intent" and b.get("message") == _NEW_BASE_MODEL_NEEDS_EMPTY_BUSINESS
        for b in v_resp.json()["blockers"]
    ), json.dumps(v_resp.json(), indent=2)

    c_resp = client.post(f"/api/businesses/{biz_id}/runs", json=_NEW_BASE_MODEL_BODY)
    assert c_resp.status_code == 400, c_resp.text
    assert c_resp.json()["detail"] == _NEW_BASE_MODEL_NEEDS_EMPTY_BUSINESS
    assert spy.call_count == 0


def test_new_base_model_versions_gate_precedes_description_gate(
    client, engine, biz_id, mock_ws
):
    """A business with versions AND an empty description reports the versions
    problem first: create's 400 detail is the first blocker, and the
    description gate must not mask it (an empty description is moot when the
    business cannot start a new base model at all)."""
    _seed_agent_config(engine)
    with Session(engine) as s:
        s.add(ModelVersion(
            business_id=biz_id, version=1, status="completed",
            deployment_status="draft", scope="ecm", uc_catalog="tgt_no_metamodel",
        ))
        business = s.get(Business, biz_id)
        business.description = ""
        s.add(business)
        s.commit()
    stub_no_metamodel(mock_ws)

    c_resp = client.post(f"/api/businesses/{biz_id}/runs", json=_NEW_BASE_MODEL_BODY)
    assert c_resp.status_code == 400, c_resp.text
    assert c_resp.json()["detail"] == _NEW_BASE_MODEL_NEEDS_EMPTY_BUSINESS


def test_new_base_model_allowed_after_failed_run_without_versions(
    client, engine, biz_id, mock_ws
):
    """Only ModelVersion rows trigger the gate. An earlier failed
    new-base-model Run that produced no version leaves the business empty, so
    a new base model is still accepted."""
    _seed_agent_config(engine)
    with Session(engine) as s:
        s.add(Run(
            id=str(uuid4()),
            business_id=biz_id,
            intent="new-base-model",
            status="failed",
        ))
        s.commit()
    stub_no_metamodel(mock_ws)

    v_resp = client.post(f"/api/businesses/{biz_id}/runs/validate", json=_NEW_BASE_MODEL_BODY)
    assert v_resp.status_code == 200, v_resp.text
    assert not any(b.get("field_path") == "intent" for b in v_resp.json()["blockers"]), (
        json.dumps(v_resp.json(), indent=2)
    )

    c_resp = client.post(f"/api/businesses/{biz_id}/runs", json=_NEW_BASE_MODEL_BODY)
    assert c_resp.status_code == 200, c_resp.text


# --- Registry ownership: M3, Rule 1, Rule 2 (orchestrator.source_industry) ---


def _ownership_state(name, engine, mock_ws):
    """``(business_id, body)`` of a request in one ownership state, from the
    world of ``test_source_industry_rules``."""
    from vibe_modeling.backend.services.operations._version_lifecycle import mark_version_deployed

    from .test_source_industry_rules import CAT, THIRD, TestSameBusinessOtherScope, _install_body, _listing, _world
    from .test_version_lifecycle_routes import _ws_with_run_now

    _ws_with_run_now(mock_ws)
    if name == "same_business_other_scope":
        _listing(mock_ws, "crop")
        biz, ecm = TestSameBusinessOtherScope()._bare(engine)
        return biz, _install_body(ecm)
    w = _world(engine)
    _listing(mock_ws, "ecm_crop", "ecm_land", "mvm_crop", "mvm_land", "ecm_sales")
    if name == "industry_where_its_business_is_installed":
        with Session(engine) as s:
            mark_version_deployed(s, s.get(ModelVersion, w.b_ecm), THIRD)
            s.commit()
        return w.industry, _install_body(w.i_ecm, THIRD)
    if name == "industry_run_in_progress":
        with Session(engine) as s:
            s.add(Run(business_id=w.industry, intent="vibe-iterate", status="running"))
            s.commit()
        return w.kick, _install_body(w.b_ecm)
    assert name == "business_over_its_industry"
    return w.kick, _install_body(w.b_ecm, CAT)


@pytest.mark.parametrize("state", [
    "same_business_other_scope", "industry_where_its_business_is_installed", "industry_run_in_progress",
])
def test_ownership_blockers_are_the_same_on_both_endpoints(client_with_agent, engine, mock_ws, state):
    biz, body = _ownership_state(state, engine, mock_ws)
    v_resp = client_with_agent.post(f"/api/businesses/{biz}/runs/validate", json=body)
    assert v_resp.status_code == 200, v_resp.text
    c_resp = client_with_agent.post(f"/api/businesses/{biz}/runs", json=body)
    assert c_resp.status_code == 400, c_resp.text
    assert c_resp.json()["detail"] in [b["message"] for b in v_resp.json()["blockers"]]


def test_the_business_over_industry_warning_is_the_same_on_both_endpoints(client_with_agent, engine, mock_ws):
    biz, body = _ownership_state("business_over_its_industry", engine, mock_ws)
    v_resp = client_with_agent.post(f"/api/businesses/{biz}/runs/validate", json=body)
    assert v_resp.status_code == 200, v_resp.text
    c_resp = client_with_agent.post(f"/api/businesses/{biz}/runs", json=body)
    assert c_resp.status_code == 200, c_resp.text

    def uninstalls_first(warnings):
        return [w["message"] for w in warnings if "This run uninstalls it first" in w["message"]]

    assert uninstalls_first(v_resp.json()["warnings"]) == uninstalls_first(c_resp.json()["warnings"])
    assert len(uninstalls_first(c_resp.json()["warnings"])) == 1
