"""Pre-flight catalog-clash check on POST /api/runs (#65).

A ``new-base-model`` run that would dispatch into a catalog already
containing user schemas — and without a schema/catalog prefix to isolate
the new schemas — used to fail deep inside the agent with a
"PHYSICAL DEPLOYMENT CLASH DETECTED" Phase-1 abort. The router now
catches this on submit (and surfaces it via ``/runs/validate``) so the
user gets a friendly inline blocker instead of a cryptic Jobs-API failure.

Coverage:
- Non-empty target catalog, no prefix → blocker on POST /api/runs
- Same body → blocker on POST /api/runs/validate (symmetric)
- Non-empty catalog WITH any prefix → no blocker (user-controlled isolation)
- Empty catalog (only system schemas) → no blocker
- Non-``new-base-model`` intent → check is skipped
- Listing failure → check is skipped (don't block on transient SDK errors)
"""
from __future__ import annotations

from types import SimpleNamespace
from uuid import uuid4

import pytest
from sqlmodel import Session

from vibe_modeling.backend.db_models import (
    AgentConfig,
    Business,
    Industry,
    ModelVersion,
)


def _seed_business(engine, *, name="overlap-biz") -> str:
    # The name must not contain "clash": a response that echoes the run's
    # parameters would match the assertions that no clash is reported.
    with Session(engine) as s:
        ind = Industry(name="Test", short_name="test", description="x")
        s.add(ind)
        s.flush()
        b = Business(name=name, description="t", industry_id=ind.id)
        s.add(b)
        s.flush()
        s.commit()
        return b.id


def _seed_agent_config(engine, *, deployment_catalog="metamodel_cat") -> None:
    with Session(engine) as s:
        existing = s.exec(
            __import__("sqlmodel").select(AgentConfig).limit(1)
        ).first()
        if existing is None:
            s.add(AgentConfig(
                notebook_path="/Workspace/agent.ipynb",
                deployment_catalog=deployment_catalog,
                warehouse_id="wh-1",
                job_id=1,
                job_name="dbx_test",
            ))
        else:
            existing.deployment_catalog = deployment_catalog
            s.add(existing)
        s.commit()


def _stub_schemas(mock_ws, names: list[str]) -> None:
    """Make ``mock_ws.schemas.list`` return SchemaInfo-shaped objects.

    Always injects ``_metamodel`` so the pre-flight metamodel-schema
    check passes; these tests exercise the clash branch downstream.
    """
    full = list(names)
    if "_metamodel" not in full:
        full.append("_metamodel")
    mock_ws.schemas.list.side_effect = lambda *a, **kw: iter(
        [SimpleNamespace(name=n) for n in full]
    )


@pytest.fixture
def biz_id(engine):
    return _seed_business(engine)


def test_clash_blocks_create_for_new_base_model(client, engine, biz_id, mock_ws):
    _seed_agent_config(engine)
    # Prefix-matching user schemas under the One Catalog default ``ecm_``
    # and ``mvm_`` prefixes. ``information_schema`` is bookkeeping and
    # never counts.
    _stub_schemas(mock_ws, ["ecm_plant", "ecm_product", "mvm_widget", "information_schema"])

    body = {
        "intent": "new-base-model",
        "catalog": "vibe_modeling_test",
        "cataloging_style": "One Catalog",
    }
    resp = client.post(f"/api/businesses/{biz_id}/runs", json=body)
    assert resp.status_code == 400, resp.text
    detail = resp.json().get("detail", "")
    assert "vibe_modeling_test" in detail
    assert "clash" in detail.lower() or "schema" in detail.lower()


def test_clash_surfaces_as_validate_blocker(client, engine, biz_id, mock_ws):
    _seed_agent_config(engine)
    _stub_schemas(mock_ws, ["ecm_plant", "ecm_product"])

    body = {
        "intent": "new-base-model",
        "catalog": "vibe_modeling_test",
        "cataloging_style": "One Catalog",
    }
    resp = client.post(f"/api/businesses/{biz_id}/runs/validate", json=body)
    assert resp.status_code == 200, resp.text
    blockers = resp.json().get("blockers", [])
    assert any(
        "vibe_modeling_test" in (b.get("message") or "")
        and "clash" in (b.get("message") or "").lower()
        for b in blockers
    ), blockers


@pytest.mark.parametrize("prefix_field", [
    "schema_prefix",
    "ecm_schema_prefix",
    "mvm_schema_prefix",
    "catalog_prefix",
])
def test_user_provided_prefix_disables_clash_check(
    client, engine, biz_id, mock_ws, prefix_field
):
    _seed_agent_config(engine)
    _stub_schemas(mock_ws, ["existing_a", "existing_b"])

    body = {
        "intent": "new-base-model",
        "catalog": "vibe_modeling_test",
        "cataloging_style": "One Catalog",
        prefix_field: "myrun_",
    }
    resp = client.post(f"/api/businesses/{biz_id}/runs/validate", json=body)
    assert resp.status_code == 200, resp.text
    blockers = resp.json().get("blockers", [])
    # No clash-related blocker (other gates may still fire — make this
    # assertion narrow to the clash-check message).
    assert not any(
        "clash" in (b.get("message") or "").lower()
        for b in blockers
    ), blockers


@pytest.mark.parametrize("system_schemas", [
    ["information_schema", "default"],
    # Agent's own bookkeeping — present in any catalog the agent has
    # ever deployed into. Surviving _metamodel must NOT be treated as a
    # user clash, otherwise the user can never re-use a catalog.
    ["_metamodel"],
    ["_metamodel", "_metrics"],
    ["information_schema", "_metamodel", "_metrics"],
])
def test_only_system_schemas_is_not_a_clash(
    client, engine, biz_id, mock_ws, system_schemas
):
    _seed_agent_config(engine)
    _stub_schemas(mock_ws, system_schemas)

    body = {
        "intent": "new-base-model",
        "catalog": "fresh_catalog",
        "cataloging_style": "One Catalog",
    }
    resp = client.post(f"/api/businesses/{biz_id}/runs/validate", json=body)
    assert resp.status_code == 200
    blockers = resp.json().get("blockers", [])
    assert not any(
        "clash" in (b.get("message") or "").lower()
        for b in blockers
    ), blockers


def test_check_skipped_for_non_new_base_model(
    client_with_agent, engine, biz_id, mock_ws
):
    """Other intents (vibe-iterate, install, …) operate on existing
    schemas — the clash check must NOT fire for them."""
    # Seed a parent ModelVersion so vibe-iterate has something to point at.
    parent_id = str(uuid4())
    with Session(engine) as s:
        s.add(ModelVersion(
            id=parent_id,
            business_id=biz_id,
            version=1,
            scope="ecm",
            status="completed",
            cataloging_style="One Catalog",
            target_catalog="vibe_modeling_test",
        ))
        s.commit()

    _stub_schemas(mock_ws, ["acme_ecm_v1", "acme_mvm_v1"])

    body = {
        "intent": "vibe-iterate",
        "version_id": parent_id,
        "catalog": "vibe_modeling_test",
        "cataloging_style": "One Catalog",
        "vibe_instructions": "tweak something",
    }
    resp = client_with_agent.post(f"/api/businesses/{biz_id}/runs/validate", json=body)
    assert resp.status_code == 200, resp.text
    blockers = resp.json().get("blockers", [])
    assert not any(
        "clash" in (b.get("message") or "").lower()
        for b in blockers
    ), blockers


def test_listing_failure_does_not_block(client, engine, biz_id, mock_ws):
    """If the SDK call to list schemas fails, the check is skipped (the
    agent's own clash detection is the backstop)."""
    _seed_agent_config(engine)
    mock_ws.schemas.list.side_effect = RuntimeError("simulated SDK error")

    body = {
        "intent": "new-base-model",
        "catalog": "vibe_modeling_test",
        "cataloging_style": "One Catalog",
    }
    resp = client.post(f"/api/businesses/{biz_id}/runs/validate", json=body)
    assert resp.status_code == 200
    blockers = resp.json().get("blockers", [])
    assert not any(
        "clash" in (b.get("message") or "").lower()
        for b in blockers
    ), blockers


def _seed_mvm_lineage(engine, biz_id: str) -> str:
    """ECM v1 -> MVM v1 -> MVM v2, as agent 5.3.3 names their schemas; v2's
    vibe added a domain that maps from no ECM domain. Returns MVM v2's id."""
    from vibe_modeling.backend.db_models import Domain, Run

    with Session(engine) as s:
        ecm1 = ModelVersion(business_id=biz_id, version=1, scope="ecm", status="completed")
        mvm1 = ModelVersion(business_id=biz_id, version=1, scope="mvm", status="completed")
        mvm2 = ModelVersion(business_id=biz_id, version=2, scope="mvm", status="completed")
        s.add_all([ecm1, mvm1, mvm2])
        s.flush()
        s.add(Domain(version_id=ecm1.id, name="Sales", database_name="ecm_sales"))
        s.add(Domain(version_id=mvm1.id, name="Sales", database_name="mvm_ecm_sales"))
        s.add(Domain(version_id=mvm2.id, name="Sales", database_name="mvm_ecm_sales"))
        s.add(Domain(version_id=mvm2.id, name="Logistics", database_name="mvm_logistics"))
        s.add(Run(business_id=biz_id, intent="new-base-model", status="completed",
                  parameters_json='{"deployment_catalog": "vibe_modeling_test"}'))
        s.commit()
        return mvm2.id


def test_vibe_of_an_mvm_with_its_own_mvm_schemas_is_not_a_clash(
    client_with_agent, engine, biz_id, mock_ws
):
    """The run form sends the base's locked ``schema_prefix`` ``mvm_``. The
    schemas under it are the MVM's own (one from a vibe-added domain), so
    neither validate nor create refuses: ownership is read on the base's
    scope, and the agent skips early clash detection for a vibe (nb
    8117-8125)."""
    mvm2 = _seed_mvm_lineage(engine, biz_id)
    _stub_schemas(mock_ws, ["mvm_ecm_sales", "mvm_logistics"])
    body = {
        "intent": "vibe-iterate",
        "version_id": mvm2,
        "catalog": "vibe_modeling_test",
        "cataloging_style": "One Catalog",
        "schema_prefix": "mvm_",
        "vibe_instructions": "tweak something",
    }
    validated = client_with_agent.post(f"/api/businesses/{biz_id}/runs/validate", json=body)
    assert validated.status_code == 200, validated.text
    assert not any("clash" in (b.get("message") or "").lower() for b in validated.json()["blockers"])
    created = client_with_agent.post(f"/api/businesses/{biz_id}/runs", json=body)
    assert created.status_code == 200, created.text
    assert "clash" not in created.text.lower(), created.text


def test_vibe_of_an_mvm_still_blocks_on_a_schema_it_does_not_own(
    client_with_agent, engine, biz_id, mock_ws
):
    mvm2 = _seed_mvm_lineage(engine, biz_id)
    _stub_schemas(mock_ws, ["mvm_ecm_sales", "mvm_someone_elses"])
    body = {
        "intent": "vibe-iterate",
        "version_id": mvm2,
        "catalog": "vibe_modeling_test",
        "cataloging_style": "One Catalog",
        "schema_prefix": "mvm_",
        "vibe_instructions": "tweak something",
    }
    resp = client_with_agent.post(f"/api/businesses/{biz_id}/runs/validate", json=body)
    assert resp.status_code == 200, resp.text
    assert any("mvm_someone_elses" in (b.get("message") or "") for b in resp.json()["blockers"])
