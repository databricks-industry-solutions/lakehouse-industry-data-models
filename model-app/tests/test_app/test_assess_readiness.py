import os
import sys
from types import SimpleNamespace as NS
from unittest.mock import MagicMock

import pytest
from databricks.sdk.errors.platform import NotFound, PermissionDenied
from sqlmodel import Session, select

from vibe_modeling.backend.assessment.metamodel import MetamodelLocation, resolve_metamodel_location
from vibe_modeling.backend.assessment.reader_sp import reader_not_found_message
from vibe_modeling.backend.assessment.readiness import warehouse_state
from vibe_modeling.backend.core._uc_privileges import effective_privileges
from vibe_modeling.backend.db_models import AssessConfig, Business, Domain, ModelVersion

sys.path.insert(0, os.path.dirname(__file__))

from _assess_helpers import _eff, _tables, ready_config, ws_ok


def test_resolve_bare_metamodel_schema():
    ws = MagicMock()
    ws.tables.list.side_effect = lambda catalog_name, schema_name: (
        _tables("business", "product", "attribute", "domain") if schema_name == "_metamodel" else _tables("order"))
    assert resolve_metamodel_location(ws, "c", "sales_order") == MetamodelLocation("c", "_metamodel", "")


def test_resolve_colocated_prefixed():
    ws = MagicMock()

    def lst(catalog_name, schema_name):
        if schema_name == "_metamodel":
            raise NotFound("no schema")
        return _tables("order", "vibe_metamodel_business", "vibe_metamodel_product",
                       "vibe_metamodel_attribute", "vibe_metamodel_domain")
    ws.tables.list.side_effect = lst
    assert resolve_metamodel_location(ws, "c", "sales_order") == MetamodelLocation("c", "sales_order", "vibe_metamodel_")


def test_resolve_none_when_missing():
    ws = MagicMock()
    ws.tables.list.return_value = _tables("order")
    assert resolve_metamodel_location(ws, "c", "s") is None


def test_effective_privileges_includes_inherited():
    ws = MagicMock()
    ws.grants.get_effective.return_value = _eff("SELECT", "USE_SCHEMA", inherited="grp")
    assert effective_privileges(ws, "schema", "c.s", "app-1") == {"SELECT", "USE_SCHEMA"}


def test_effective_privileges_unverifiable_returns_none():
    ws = MagicMock()
    ws.grants.get_effective.side_effect = PermissionDenied("no")
    assert effective_privileges(ws, "schema", "c.s", "app-1") is None


def test_warehouse_state_via_group():
    ws = MagicMock()
    ws.warehouses.get_permissions.return_value = NS(access_control_list=[
        NS(service_principal_name=None, group_name="readers", user_name=None,
           all_permissions=[NS(permission_level=NS(value="CAN_USE"))])])
    assert warehouse_state(ws, "wh", "app-1", NS(groups=[NS(display="readers")])) == "ok"
    assert warehouse_state(ws, "wh", "app-1", NS(groups=[])) == "unverified"  # may be a nested group


@pytest.fixture
def seeded(engine):
    with Session(engine) as s:
        b = Business(name="Meridian", description="d")
        s.add(b); s.commit(); s.refresh(b)
        mv = ModelVersion(business_id=b.id, version=3, scope="mvm", status="completed",
                          deployment_status="deployed", uc_catalog="mvm_cat")
        s.add(mv); s.commit(); s.refresh(mv)
        d = Domain(version_id=mv.id, name="sales_order", database_name="sales_order")
        s.add(d)
        s.add(ready_config(job_id=1))
        s.commit(); s.refresh(d)
        return mv.id, d.id


def _body(vid, did):
    return {"version_id": vid, "domains": [{"domain_id": did, "sources": [
        {"source_name": "src_sap", "catalog_name": "bronze_cat", "schema_name": "sap"}]}]}


def test_readiness_route_blocks_missing_bronze(client, mock_ws, seeded):
    vid, did = seeded
    ws_ok(mock_ws)
    mock_ws.grants.get_effective.side_effect = (
        lambda securable_type, full_name, principal=None:
        _eff() if full_name.startswith("bronze_cat") else _eff("ALL_PRIVILEGES"))
    r = client.post("/api/assess/readiness", json=_body(vid, did))
    assert r.status_code == 200, r.text
    dom = r.json()["domains"][0]
    states = {c["key"]: c["state"] for c in dom["checks"]}
    assert states["model_read"] == "ok" and states["metamodel"] == "ok"
    assert states["bronze:src_sap"] == "blocked" and dom["blocked"] is True
    bronze = next(c for c in dom["checks"] if c["key"] == "bronze:src_sap")
    assert "GRANT SELECT ON SCHEMA `bronze_cat`.`sap` TO `app-1`" in bronze["fix_sql"]


def test_readiness_all_ok(client, mock_ws, seeded):
    vid, did = seeded
    ws_ok(mock_ws)
    r = client.post("/api/assess/readiness", json=_body(vid, did))
    assert r.status_code == 200, r.text
    body = r.json()
    assert all(c["state"] == "ok" for c in body["global_checks"])
    assert body["domains"][0]["blocked"] is False


def test_readiness_unverified_does_not_block(client, mock_ws, seeded):
    vid, did = seeded
    ws_ok(mock_ws)

    def eff(securable_type, full_name, principal=None):
        if full_name.startswith("bronze_cat"):
            raise PermissionDenied("no")
        return _eff("ALL_PRIVILEGES")
    mock_ws.grants.get_effective.side_effect = eff
    r = client.post("/api/assess/readiness", json=_body(vid, did))
    assert r.status_code == 200, r.text
    dom = r.json()["domains"][0]
    states = {c["key"]: c["state"] for c in dom["checks"]}
    assert states["bronze:src_sap"] == "unverified" and dom["blocked"] is False


def test_readiness_checks_metamodel_schema_when_different(client, mock_ws, seeded):
    vid, did = seeded
    ws_ok(mock_ws)  # bare _metamodel schema present
    mock_ws.grants.get_effective.side_effect = (
        lambda securable_type, full_name, principal=None:
        _eff() if full_name == "mvm_cat._metamodel" else _eff("ALL_PRIVILEGES"))
    r = client.post("/api/assess/readiness", json=_body(vid, did))
    checks = {c["key"]: c for c in r.json()["domains"][0]["checks"]}
    assert checks["model_read"]["state"] == "blocked"
    assert checks["model_read"]["fix_action"] == ""  # the app grants nothing on model schemas; the SQL is shown
    assert "GRANT SELECT ON SCHEMA `mvm_cat`.`_metamodel` TO `app-1`;" in checks["model_read"]["fix_sql"]


def test_readiness_job_ready_follows_assess_ready(client, mock_ws, engine, seeded):
    vid, did = seeded
    ws_ok(mock_ws)
    with Session(engine) as s:
        cfg = s.exec(select(AssessConfig)).first()
        cfg.synced_version = "0.0.1"
        s.add(cfg); s.commit()
    body = client.post("/api/assess/readiness", json=_body(vid, did)).json()
    job = next(c for c in body["global_checks"] if c["key"] == "job_ready")
    assert job["state"] == "blocked" and "has not been synced for app version" in job["detail"]
    assert job["fix_action"] == "open_settings" and body["domains"][0]["blocked"] is True


def test_readiness_app_managed_checks_offer_admin_help_not_sql(client, mock_ws, seeded):
    vid, did = seeded
    ws_ok(mock_ws)
    mock_ws.grants.get_effective.side_effect = (
        lambda securable_type, full_name, principal=None:
        _eff() if full_name.startswith("test_deployment_catalog._metamodel") else _eff("ALL_PRIVILEGES"))
    body = client.post("/api/assess/readiness", json=_body(vid, did)).json()
    checks = {c["key"]: c for c in body["global_checks"]}
    for key in ("runs_volume", "metamodel_access"):
        assert checks[key]["state"] == "blocked", key
        assert checks[key]["fix_action"] == "admin_help" and checks[key]["fix_sql"] == "", key
    assert "test_deployment_catalog._metamodel.assess_runs" in checks["runs_volume"]["detail"]
    assert body["domains"][0]["blocked"] is True


def test_readiness_unconfigured_reader_blocks(client, mock_ws, engine, seeded):
    vid, did = seeded
    with Session(engine) as s:
        cfg = s.exec(select(AssessConfig)).first()
        cfg.reader_application_id = ""
        s.add(cfg); s.commit()
    r = client.post("/api/assess/readiness", json=_body(vid, did))
    body = r.json()
    assert body["global_checks"][0]["key"] == "reader_configured"
    assert body["global_checks"][0]["state"] == "blocked" and body["domains"][0]["blocked"] is True


def test_readiness_rejects_uninstalled_version(client, engine, seeded):
    vid, did = seeded
    with Session(engine) as s:
        mv = s.get(ModelVersion, vid)
        mv.deployment_status = "pending"
        s.add(mv); s.commit()
    assert client.post("/api/assess/readiness", json=_body(vid, did)).status_code == 422
    assert client.post("/api/assess/readiness", json=_body("nope", did)).status_code == 404


def test_readiness_rejects_foreign_and_duplicate_domains(client, seeded):
    vid, did = seeded
    assert client.post("/api/assess/readiness", json=_body(vid, "other")).status_code == 422
    body = _body(vid, did)
    body["domains"] = body["domains"] * 2
    assert client.post("/api/assess/readiness", json=body).status_code == 422


def test_grant_model_read_route_is_gone(client, mock_ws, seeded):
    vid, did = seeded
    r = client.post("/api/assess/grant-model-read", json={"version_id": vid, "domain_ids": [did]})
    assert r.status_code in (404, 405)
    mock_ws.grants.update.assert_not_called()


def test_readiness_never_grants(client, mock_ws, seeded):
    vid, did = seeded
    ws_ok(mock_ws)
    mock_ws.grants.get_effective.side_effect = lambda *a, **k: _eff()
    client.post("/api/assess/readiness", json=_body(vid, did))
    mock_ws.grants.update.assert_not_called()


def test_readiness_scim_error_is_unverified_not_500(client, mock_ws, seeded):
    vid, did = seeded
    ws_ok(mock_ws)
    mock_ws.service_principals.list.side_effect = PermissionDenied("scim")
    r = client.post("/api/assess/readiness", json=_body(vid, did))
    assert r.status_code == 200, r.text
    body = r.json()
    rc = next(c for c in body["global_checks"] if c["key"] == "reader_configured")
    assert rc["state"] == "unverified" and rc["detail"]
    assert body["domains"][0]["blocked"] is False


def test_readiness_reader_not_found_uses_the_save_message(client, mock_ws, seeded):
    vid, did = seeded
    ws_ok(mock_ws)
    mock_ws.service_principals.list.return_value = []
    body = client.post("/api/assess/readiness", json=_body(vid, did)).json()
    rc = next(c for c in body["global_checks"] if c["key"] == "reader_configured")
    assert rc["state"] == "blocked" and rc["detail"] == reader_not_found_message(ready_config().reader_application_id)


def _wh(*entries):
    return NS(access_control_list=[
        NS(service_principal_name=None, group_name=g, user_name=None,
           all_permissions=[NS(permission_level=NS(value=lvl))]) for g, lvl in entries])


def test_warehouse_nested_group_is_unverified():
    ws = MagicMock()
    ws.warehouses.get_permissions.return_value = _wh(("parent-grp", "CAN_USE"))
    assert warehouse_state(ws, "wh", "app-1", NS(groups=[NS(display="child")])) == "unverified"


def test_warehouse_unknown_sp_is_unverified_unless_direct():
    ws = MagicMock()
    ws.warehouses.get_permissions.return_value = _wh(("other", "CAN_VIEW"))
    assert warehouse_state(ws, "wh", "app-1", None) == "unverified"
    ws.warehouses.get_permissions.return_value = _wh(("users", "CAN_USE"))
    assert warehouse_state(ws, "wh", "app-1", None) == "ok"


def test_warehouse_no_applicable_grant_is_blocked():
    ws = MagicMock()
    ws.warehouses.get_permissions.return_value = _wh(("grp", "CAN_VIEW"))
    assert warehouse_state(ws, "wh", "app-1", NS(groups=[])) == "blocked"


def test_fix_sql_quotes_hyphenated_names(client, mock_ws, seeded):
    vid, did = seeded
    ws_ok(mock_ws)
    mock_ws.grants.get_effective.side_effect = lambda *a, **k: _eff()
    body = _body(vid, did)
    body["domains"][0]["sources"][0].update(catalog_name="my-cat", schema_name="my-sch")
    r = client.post("/api/assess/readiness", json=body)
    bronze = next(c for c in r.json()["domains"][0]["checks"] if c["key"] == "bronze:src_sap")
    assert "GRANT USE CATALOG ON CATALOG `my-cat` TO `app-1`;" in bronze["fix_sql"]
    assert "GRANT USE SCHEMA ON SCHEMA `my-cat`.`my-sch` TO `app-1`;" in bronze["fix_sql"]
    assert "GRANT SELECT ON SCHEMA `my-cat`.`my-sch` TO `app-1`;" in bronze["fix_sql"]


@pytest.mark.parametrize("field,value", [("source_name", "a b"), ("catalog_name", "c;drop"), ("schema_name", "s.t")])
def test_source_in_patterns_422(client, seeded, field, value):
    vid, did = seeded
    body = _body(vid, did)
    body["domains"][0]["sources"][0][field] = value
    assert client.post("/api/assess/readiness", json=body).status_code == 422
