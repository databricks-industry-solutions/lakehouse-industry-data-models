"""Adversarial tests for the broadened pre-flight clash check (the model-versioning work).

The narrow clash check (test_runs_catalog_clash_preflight.py) was bypassed
the moment the user typed *any* schema/catalog prefix, even one that
itself collides with pre-existing schemas in the deployment catalog.

The broadened check inspects schemas under the deployment catalog whose
names match the configured ``ecm_schema_prefix`` / ``mvm_schema_prefix``
(or per-catalog prefix/suffix in Catalog-per-Division/Domain mode),
filters out preserved schemas (``_metamodel``, ``_metrics``, ``default``,
``information_schema``, anything starting with ``_``), then filters out
schemas that have a matching metamodel record (re-installs of the same
business+version+scope are fine). Anything left over surfaces as a
blocker on the appropriate ``ecm_schema_prefix`` / ``mvm_schema_prefix``
field.

These tests drive the public surface only — ``POST /api/runs/validate``
and ``POST /api/runs`` — and stub ``WorkspaceClient.schemas.list`` via
the ``mock_ws`` fixture.
"""
from __future__ import annotations

from types import SimpleNamespace
from uuid import uuid4

import pytest
from sqlmodel import Session, select

from vibe_modeling.backend.db_models import (
    AgentConfig,
    Business,
    Industry,
    ModelVersion,
    Run,
)


# ---------------------------------------------------------------------------
# Fixtures / helpers
# ---------------------------------------------------------------------------


def _seed_business(engine, *, name: str = "broadened-clash-biz") -> str:
    """Insert an Industry + Business and return the business id."""
    with Session(engine) as s:
        ind = Industry(name="Test", short_name="test", description="x")
        s.add(ind)
        s.flush()
        b = Business(name=name, description="t", industry_id=ind.id)
        s.add(b)
        s.flush()
        s.commit()
        return b.id


def _seed_agent_config(engine, *, deployment_catalog: str = "metamodel_cat") -> None:
    """Ensure an AgentConfig row exists with the requested deployment catalog."""
    with Session(engine) as s:
        existing = s.exec(select(AgentConfig).limit(1)).first()
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

    Always injects ``_metamodel`` into the result so the pre-flight
    metamodel-schema check passes; tests here exercise the clash-check
    branch downstream, not catalog-setup.

    Fresh iterator per call so the broadened check can call
    ``schemas.list`` more than once.
    """
    full = list(names)
    if "_metamodel" not in full:
        full.append("_metamodel")
    def _fake_list(*args, **kwargs):
        return iter([SimpleNamespace(name=n) for n in full])
    mock_ws.schemas.list.side_effect = _fake_list


def _seed_completed_ecm_version(
    engine,
    *,
    business_id: str,
    version: int = 1,
    target_catalog: str = "vibe_modeling_test",
    cataloging_style: str = "One Catalog",
) -> str:
    """Seed a completed ECM ModelVersion for re-install / parent tests."""
    mv_id = str(uuid4())
    with Session(engine) as s:
        s.add(ModelVersion(
            id=mv_id,
            business_id=business_id,
            version=version,
            scope="ecm",
            status="completed",
            cataloging_style=cataloging_style,
            target_catalog=target_catalog,
        ))
        s.commit()
    return mv_id


def _has_clash_blocker(
    blockers: list[dict], *, field_path: str | None = None
) -> bool:
    """True iff at least one blocker looks like a clash blocker.

    We accept either the legacy ``field_path="catalog"`` (narrow check) or
    the broadened ``ecm_schema_prefix`` / ``mvm_schema_prefix`` /
    ``catalog_prefix``. ``field_path=None`` matches any field.
    """
    for b in blockers:
        msg = (b.get("message") or "").lower()
        fp = b.get("field_path") or ""
        if "clash" not in msg and "already exist" not in msg \
                and "already contain" not in msg:
            continue
        if field_path is None:
            return True
        if fp == field_path:
            return True
    return False


def _clash_blockers_for(
    blockers: list[dict], *, field_path: str
) -> list[dict]:
    """Return all clash-flavoured blockers attached to ``field_path``."""
    out = []
    for b in blockers:
        msg = (b.get("message") or "").lower()
        if "clash" not in msg and "already exist" not in msg \
                and "already contain" not in msg:
            continue
        if (b.get("field_path") or "") == field_path:
            out.append(b)
    return out


@pytest.fixture
def biz_id(engine):
    return _seed_business(engine)


# ---------------------------------------------------------------------------
# Tests
# ---------------------------------------------------------------------------


def test_empty_catalog_no_blocker(client, engine, biz_id, mock_ws):
    """No schemas in the catalog → no clash blocker on either prefix."""
    _seed_agent_config(engine)
    _stub_schemas(mock_ws, [])

    body = {
        "intent": "new-base-model",
        "catalog": "vibe_modeling_test",
        "cataloging_style": "One Catalog",
        "ecm_schema_prefix": "ecm_",
        "mvm_schema_prefix": "mvm_",
    }
    resp = client.post(f"/api/businesses/{biz_id}/runs/validate", json=body)
    assert resp.status_code == 200, resp.text
    blockers = resp.json().get("blockers", [])
    assert not _has_clash_blocker(blockers), blockers


def test_preexisting_unrelated_schemas_block_with_field_path(
    client, engine, biz_id, mock_ws
):
    """Pre-existing ``ecm_*`` schemas with no metamodel records → blocker
    on ``ecm_schema_prefix`` listing both schemas."""
    _seed_agent_config(engine)
    _stub_schemas(mock_ws, ["ecm_plant", "ecm_supplier", "information_schema"])

    body = {
        "intent": "new-base-model",
        "catalog": "vibe_modeling_test",
        "cataloging_style": "One Catalog",
        "ecm_schema_prefix": "ecm_",
        "mvm_schema_prefix": "mvm_",
    }
    resp = client.post(f"/api/businesses/{biz_id}/runs/validate", json=body)
    assert resp.status_code == 200, resp.text
    blockers = resp.json().get("blockers", [])
    relevant = _clash_blockers_for(blockers, field_path="ecm_schema_prefix")
    assert relevant, f"expected ecm_schema_prefix clash blocker, got {blockers}"
    msg = relevant[0]["message"]
    assert "ecm_plant" in msg, msg
    assert "ecm_supplier" in msg, msg


def test_matching_metamodel_records_skip_blocker(
    client, engine, biz_id, mock_ws
):
    """Pre-existing ``ecm_customer`` is fine if a matching ModelVersion +
    Run row record this exact business+version+ECM scope (re-install)."""
    _seed_agent_config(engine)
    _stub_schemas(mock_ws, ["ecm_customer"])

    # Seed a completed ECM ModelVersion that "owns" the ecm_customer schema.
    mv_id = _seed_completed_ecm_version(
        engine, business_id=biz_id, version=1,
        target_catalog="vibe_modeling_test",
    )
    # Add a Run record that points at this version so the clash check has
    # something to triangulate against (the dev agent may use either Run
    # or ModelVersion to detect a re-install — seed both to be robust).
    with Session(engine) as s:
        s.add(Run(
            business_id=biz_id,
            version_id=mv_id,
            intent="new-base-model",
            status="completed",
            parameters_json='{"deployment_catalog": "vibe_modeling_test", "ecm_schema_prefix": "ecm_"}',
        ))
        s.commit()

    body = {
        "intent": "new-base-model",
        "catalog": "vibe_modeling_test",
        "cataloging_style": "One Catalog",
        "ecm_schema_prefix": "ecm_",
        "mvm_schema_prefix": "mvm_",
    }
    resp = client.post(f"/api/businesses/{biz_id}/runs/validate", json=body)
    assert resp.status_code == 200, resp.text
    blockers = resp.json().get("blockers", [])
    # The ecm_customer schema is "owned" by this business's prior run, so
    # it is not a clash. (The active-run lock fires only for pending /
    # running / stale runs — completed is fine.)
    assert not _clash_blockers_for(blockers, field_path="ecm_schema_prefix"), \
        blockers


@pytest.mark.parametrize("preserved", [
    ["_metamodel", "_metrics", "default", "information_schema"],
    ["_metamodel"],
    ["default", "information_schema"],
])
def test_preserved_schemas_do_not_trigger(
    client, engine, biz_id, mock_ws, preserved
):
    """The four preserved schema names never trigger the clash blocker."""
    _seed_agent_config(engine)
    _stub_schemas(mock_ws, preserved)

    body = {
        "intent": "new-base-model",
        "catalog": "vibe_modeling_test",
        "cataloging_style": "One Catalog",
        "ecm_schema_prefix": "ecm_",
        "mvm_schema_prefix": "mvm_",
    }
    resp = client.post(f"/api/businesses/{biz_id}/runs/validate", json=body)
    assert resp.status_code == 200, resp.text
    blockers = resp.json().get("blockers", [])
    assert not _has_clash_blocker(blockers), blockers


def test_underscore_prefixed_schemas_do_not_trigger(
    client, engine, biz_id, mock_ws
):
    """Any schema name starting with ``_`` is treated as system-owned."""
    _seed_agent_config(engine)
    _stub_schemas(mock_ws, ["_my_internal_schema", "_some_legacy_blob"])

    body = {
        "intent": "new-base-model",
        "catalog": "vibe_modeling_test",
        "cataloging_style": "One Catalog",
        "ecm_schema_prefix": "ecm_",
        "mvm_schema_prefix": "mvm_",
    }
    resp = client.post(f"/api/businesses/{biz_id}/runs/validate", json=body)
    assert resp.status_code == 200, resp.text
    blockers = resp.json().get("blockers", [])
    assert not _has_clash_blocker(blockers), blockers


def test_message_caps_at_5_then_more(client, engine, biz_id, mock_ws):
    """Seven conflicting schemas → message names 5 by example, then "+2 more"."""
    _seed_agent_config(engine)
    names = [
        "ecm_a", "ecm_b", "ecm_c", "ecm_d", "ecm_e", "ecm_f", "ecm_g",
    ]
    _stub_schemas(mock_ws, names)

    body = {
        "intent": "new-base-model",
        "catalog": "vibe_modeling_test",
        "cataloging_style": "One Catalog",
        "ecm_schema_prefix": "ecm_",
        "mvm_schema_prefix": "mvm_",
    }
    resp = client.post(f"/api/businesses/{biz_id}/runs/validate", json=body)
    assert resp.status_code == 200, resp.text
    blockers = resp.json().get("blockers", [])
    relevant = _clash_blockers_for(blockers, field_path="ecm_schema_prefix")
    assert relevant, blockers
    msg = relevant[0]["message"]
    # 5 names show; "2 more" hint appears in some form.
    shown = sum(1 for n in names if n in msg)
    assert shown == 5, f"expected exactly 5 schema names in {msg!r}"
    assert "2" in msg and "more" in msg.lower(), \
        f"expected '+2 more'-style hint in {msg!r}"


def test_mvm_side_only_clash_attaches_to_mvm_field(
    client, engine, biz_id, mock_ws
):
    """Only ``mvm_*`` pre-existing schemas → blocker on
    ``mvm_schema_prefix`` only, NOT on ``ecm_schema_prefix``."""
    _seed_agent_config(engine)
    _stub_schemas(mock_ws, ["mvm_orders", "mvm_customers"])

    body = {
        "intent": "new-base-model",
        "catalog": "vibe_modeling_test",
        "cataloging_style": "One Catalog",
        "ecm_schema_prefix": "ecm_",
        "mvm_schema_prefix": "mvm_",
    }
    resp = client.post(f"/api/businesses/{biz_id}/runs/validate", json=body)
    assert resp.status_code == 200, resp.text
    blockers = resp.json().get("blockers", [])
    assert _clash_blockers_for(blockers, field_path="mvm_schema_prefix"), blockers
    assert not _clash_blockers_for(blockers, field_path="ecm_schema_prefix"), \
        blockers


def test_both_sides_clash_emit_two_blockers(
    client, engine, biz_id, mock_ws
):
    """ECM and MVM both pre-existing → two distinct blockers."""
    _seed_agent_config(engine)
    _stub_schemas(mock_ws, ["ecm_a", "mvm_b"])

    body = {
        "intent": "new-base-model",
        "catalog": "vibe_modeling_test",
        "cataloging_style": "One Catalog",
        "ecm_schema_prefix": "ecm_",
        "mvm_schema_prefix": "mvm_",
    }
    resp = client.post(f"/api/businesses/{biz_id}/runs/validate", json=body)
    assert resp.status_code == 200, resp.text
    blockers = resp.json().get("blockers", [])
    assert _clash_blockers_for(blockers, field_path="ecm_schema_prefix"), blockers
    assert _clash_blockers_for(blockers, field_path="mvm_schema_prefix"), blockers


def test_post_runs_returns_400_and_no_run_row(
    client, engine, biz_id, mock_ws
):
    """``POST /api/runs`` rejects with 400 and writes no Run row."""
    _seed_agent_config(engine)
    _stub_schemas(mock_ws, ["ecm_plant", "ecm_supplier"])

    body = {
        "intent": "new-base-model",
        "catalog": "vibe_modeling_test",
        "cataloging_style": "One Catalog",
        "ecm_schema_prefix": "ecm_",
        "mvm_schema_prefix": "mvm_",
    }
    resp = client.post(f"/api/businesses/{biz_id}/runs", json=body)
    assert resp.status_code == 400, resp.text
    detail = resp.json().get("detail")
    # detail can be a string or a dict-with-blockers — accept either shape.
    if isinstance(detail, dict):
        echoed_blockers = detail.get("blockers", [])
        assert _clash_blockers_for(
            echoed_blockers, field_path="ecm_schema_prefix"
        ), detail
    else:
        assert "ecm_plant" in str(detail) or "clash" in str(detail).lower(), detail

    with Session(engine) as s:
        runs = s.exec(select(Run).where(Run.business_id == biz_id)).all()
    assert runs == [], f"expected no Run rows, found {[r.id for r in runs]}"


def test_post_runs_long_clash_message_keeps_its_steps(
    client, engine, biz_id, mock_ws
):
    """A clash message past the 500-character cap keeps its "To proceed"
    steps on the create path (it is an ``AppMessage``)."""
    from vibe_modeling.backend.error_sanitization import MAX_ERROR_LENGTH

    _seed_agent_config(engine)
    names = [f"ecm_{c * 120}" for c in "abcdef"]
    _stub_schemas(mock_ws, names)
    body = {
        "intent": "new-base-model",
        "catalog": "vibe_modeling_test",
        "cataloging_style": "One Catalog",
        "ecm_schema_prefix": "ecm_",
        "mvm_schema_prefix": "mvm_",
    }
    resp = client.post(f"/api/businesses/{biz_id}/runs", json=body)
    assert resp.status_code == 400, resp.text
    detail = resp.json()["detail"]
    assert len(detail) > MAX_ERROR_LENGTH
    assert "To proceed, either:" in detail
    assert detail.endswith("  - target a different deployment catalog.")
    with Session(engine) as s:
        assert s.exec(select(Run).where(Run.business_id == biz_id)).all() == []


def test_post_validate_does_not_create_run_row(
    client, engine, biz_id, mock_ws
):
    """``POST /api/runs/validate`` echoes blockers and does NOT persist."""
    _seed_agent_config(engine)
    _stub_schemas(mock_ws, ["ecm_plant", "ecm_supplier"])

    body = {
        "intent": "new-base-model",
        "catalog": "vibe_modeling_test",
        "cataloging_style": "One Catalog",
        "ecm_schema_prefix": "ecm_",
        "mvm_schema_prefix": "mvm_",
    }
    resp = client.post(f"/api/businesses/{biz_id}/runs/validate", json=body)
    assert resp.status_code == 200, resp.text
    blockers = resp.json().get("blockers", [])
    assert _clash_blockers_for(blockers, field_path="ecm_schema_prefix"), \
        blockers

    with Session(engine) as s:
        runs = s.exec(select(Run).where(Run.business_id == biz_id)).all()
    assert runs == [], f"validate must not write Run rows, found {[r.id for r in runs]}"


def test_vibe_new_ecm_mvm_intent_is_gated(
    client, engine, biz_id, mock_ws
):
    """``vibe-new-ecm-mvm`` (parent ECM exists, growing into MVM) is gated
    by the same broadened check."""
    _seed_agent_config(engine)
    parent_id = _seed_completed_ecm_version(
        engine, business_id=biz_id, version=1,
        target_catalog="vibe_modeling_test",
    )
    # An UNRELATED schema exists under the ecm_ prefix that doesn't
    # belong to this business / version.
    _stub_schemas(mock_ws, ["ecm_other"])

    body = {
        "intent": "vibe-new-ecm-mvm",
        "version_id": parent_id,
        "catalog": "vibe_modeling_test",
        "cataloging_style": "One Catalog",
        "ecm_schema_prefix": "ecm_",
        "mvm_schema_prefix": "mvm_",
        "vibe_instructions": "grow MVM from current ECM",
    }
    resp = client.post(f"/api/businesses/{biz_id}/runs/validate", json=body)
    assert resp.status_code == 200, resp.text
    blockers = resp.json().get("blockers", [])
    assert _clash_blockers_for(blockers, field_path="ecm_schema_prefix") \
        or _clash_blockers_for(blockers, field_path="mvm_schema_prefix"), \
        blockers


def test_vibe_iterate_intent_is_gated(client, engine, biz_id, mock_ws):
    """``vibe-iterate`` plans new schemas (next version), so the same
    broadened check fires for unrelated pre-existing prefixed schemas."""
    _seed_agent_config(engine)
    parent_id = _seed_completed_ecm_version(
        engine, business_id=biz_id, version=1,
        target_catalog="vibe_modeling_test",
    )
    # `ecm_foreign_biz` belongs to some OTHER business (no matching
    # metamodel record on this business), so it must trip the gate.
    _stub_schemas(mock_ws, ["ecm_foreign_biz"])

    # vibe-iterate carries the single legacy ``schema_prefix``
    # (``_resolve_clash_check_prefixes``); the per-scope prefixes are not read.
    body = {
        "intent": "vibe-iterate",
        "version_id": parent_id,
        "catalog": "vibe_modeling_test",
        "cataloging_style": "One Catalog",
        "schema_prefix": "ecm_",
        "vibe_instructions": "tweak something",
    }
    resp = client.post(f"/api/businesses/{biz_id}/runs/validate", json=body)
    assert resp.status_code == 200, resp.text
    payload = resp.json()
    blockers = payload.get("blockers", [])
    # If the intent has no DAG factory wired in this build, the validator
    # emits a non-blocking "run-plan preview unavailable" warning instead
    # of building a Dag, so the broadened clash gate (which walks the Dag)
    # never runs; skip rather than false-positive.
    warnings = payload.get("warnings", [])
    if any(
        "run-plan preview is not available" in (w.get("message") or "").lower()
        for w in warnings
    ):
        pytest.skip("vibe-iterate DAG factory not wired in this build")
    assert _has_clash_blocker(blockers), blockers


def test_catalog_per_division_catalog_level_clash(
    client, engine, biz_id, mock_ws
):
    """In Catalog-per-Division mode the gate generalises to per-catalog
    name prefixes. Pre-existing ``proj_acme_*`` catalogs/schemas (not
    owned by this business) → blocker on ``catalog_prefix``."""
    _seed_agent_config(engine)
    # In Catalog-per-Division mode the agent enumerates catalogs (not just
    # schemas) — but the broadened check we mock here goes through the
    # same `schemas.list` surface used by the One Catalog path. The dev
    # agent's implementation may instead use `ws.catalogs.list`; if so,
    # this test will need realignment. Stub both surfaces conservatively.
    _stub_schemas(mock_ws, ["proj_acme_orders", "proj_acme_customers"])
    if hasattr(mock_ws, "catalogs"):
        def _fake_catalogs_list(*a, **kw):
            return iter([
                SimpleNamespace(name="proj_acme_orders"),
                SimpleNamespace(name="proj_acme_customers"),
            ])
        mock_ws.catalogs.list.side_effect = _fake_catalogs_list

    body = {
        "intent": "new-base-model",
        "catalog": "vibe_modeling_test",
        "cataloging_style": "Catalog per Division",
        "catalog_prefix": "proj_acme_",
        "ecm_schema_prefix": "",
        "mvm_schema_prefix": "",
    }
    resp = client.post(f"/api/businesses/{biz_id}/runs/validate", json=body)
    assert resp.status_code == 200, resp.text
    blockers = resp.json().get("blockers", [])
    # Accept the blocker on either ``catalog_prefix`` or the legacy
    # ``catalog`` field — the dev agent may pin it to either.
    assert _has_clash_blocker(blockers), blockers


def test_run_config_respects_updated_prefix(client, engine, biz_id, mock_ws):
    """Setting ``ecm_schema_prefix="ecm2_"`` enumerates ``ecm2_*`` only.
    A pre-existing ``ecm_plant`` (under the DEFAULT prefix) does NOT
    trigger; ``ecm2_other`` DOES."""
    _seed_agent_config(engine)
    # Both schemas exist; only the one matching the configured prefix
    # should produce a blocker.
    _stub_schemas(mock_ws, ["ecm_plant", "ecm2_other"])

    body = {
        "intent": "new-base-model",
        "catalog": "vibe_modeling_test",
        "cataloging_style": "One Catalog",
        "ecm_schema_prefix": "ecm2_",
        "mvm_schema_prefix": "mvm_",
    }
    resp = client.post(f"/api/businesses/{biz_id}/runs/validate", json=body)
    assert resp.status_code == 200, resp.text
    blockers = resp.json().get("blockers", [])
    relevant = _clash_blockers_for(blockers, field_path="ecm_schema_prefix")
    assert relevant, blockers
    msg = relevant[0]["message"]
    assert "ecm2_other" in msg, msg
    # The non-matching ``ecm_plant`` must NOT appear (different prefix).
    assert "ecm_plant" not in msg, msg


def test_empty_ecm_schema_prefix_one_catalog_blocks_or_enumerates_all(
    client, engine, biz_id, mock_ws
):
    """Empty ``ecm_schema_prefix=""`` in One Catalog mode: pin a sensible
    behaviour. Either (a) the request is rejected for missing the
    required prefix, or (b) the check enumerates ALL non-preserved
    schemas in the catalog and blocks because at least one exists.

    Either outcome is correct — what's NOT correct is silently allowing
    a One Catalog run with no prefix into a non-empty catalog (the bug
    that prompted the broadened check)."""
    _seed_agent_config(engine)
    _stub_schemas(mock_ws, ["foo", "bar"])

    body = {
        "intent": "new-base-model",
        "catalog": "vibe_modeling_test",
        "cataloging_style": "One Catalog",
        "ecm_schema_prefix": "",
        "mvm_schema_prefix": "",
    }
    resp = client.post(f"/api/businesses/{biz_id}/runs/validate", json=body)
    assert resp.status_code == 200, resp.text
    blockers = resp.json().get("blockers", [])
    # We assert SOME blocker fires — either a clash blocker or a
    # "prefix is required for One Catalog" blocker.
    assert blockers, "expected at least one blocker for empty One-Catalog prefix"


def test_listing_failure_does_not_block(client, engine, biz_id, mock_ws):
    """Symmetry with the narrow check: an SDK error listing schemas
    must not block the run (the agent's own clash detection is the
    backstop)."""
    _seed_agent_config(engine)
    mock_ws.schemas.list.side_effect = RuntimeError("simulated SDK error")

    body = {
        "intent": "new-base-model",
        "catalog": "vibe_modeling_test",
        "cataloging_style": "One Catalog",
        "ecm_schema_prefix": "ecm_",
        "mvm_schema_prefix": "mvm_",
    }
    resp = client.post(f"/api/businesses/{biz_id}/runs/validate", json=body)
    assert resp.status_code == 200, resp.text
    blockers = resp.json().get("blockers", [])
    assert not _has_clash_blocker(blockers), blockers


def test_vibe_iterate_legacy_prefix_matches_the_install_by_any_form_of_the_scope(
    engine, biz_id, mock_ws
):
    """A legacy ``schema_prefix`` run carrying the widget label of the scope
    finds the ECM install that owns the prefixed schema (``normalize_scope``)
    and raises no clash. No completed Run row is seeded, so the Domain match
    is the only ownership signal."""
    from vibe_modeling.backend.services.orchestrator import preflight
    from vibe_modeling.backend.db_models import Domain
    from vibe_modeling.backend.models import RunIn

    _seed_agent_config(engine)
    mv_id = _seed_completed_ecm_version(engine, business_id=biz_id, version=1)
    with Session(engine) as s:
        s.add(Domain(version_id=mv_id, name="Customer", database_name="ecm_customer"))
        s.commit()
    _stub_schemas(mock_ws, ["ecm_customer"])
    body = RunIn(
        intent="vibe-iterate", version_id=mv_id, catalog="vibe_modeling_test",
        schema_prefix="ecm_", scope="Expanded Coverage Model - ECM",
    )

    with Session(engine) as s:
        agent_config = s.exec(select(AgentConfig)).first()
        issues = preflight._check_target_catalog_clash(biz_id, body, agent_config, s, mock_ws)

    assert [i.message for i in issues] == []
