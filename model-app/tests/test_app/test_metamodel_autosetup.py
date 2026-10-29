"""Level 3 of the run pre-flight: setting up ``<catalog>._metamodel``.

``metamodel_state`` probes the schema and each volume without creating
anything; validate reports what create will set up as ``prepare`` issues.
Create sets it up with the App SP client after every check, right before the
Run row, or refuses with a 400. A NEW_BASE_MODEL gets the schema and
``vol_root``; every other `_METAMODEL_REQUIRED_INTENTS` intent keeps the
missing-schema blocker and gets a missing ``vol_root`` created.
"""
from __future__ import annotations

import ast
import sys
from pathlib import Path
from types import SimpleNamespace
from unittest.mock import MagicMock, call

import pytest
from databricks.sdk.errors import (
    AlreadyExists,
    BadRequest,
    NotFound,
    PermissionDenied,
    ResourceAlreadyExists,
    ResourceConflict,
)
from databricks.sdk.service.catalog import VolumeType
from sqlmodel import Session, select

from vibe_modeling.backend.db_models import AgentConfig, Business, Industry, Run
from vibe_modeling.backend.models import Intent, RunIn
from vibe_modeling.backend.services import metamodel_setup
from vibe_modeling.backend.services.metamodel_setup import (
    MetamodelSetupError,
    MetamodelState,
    ensure_metamodel_schema_and_volume,
    metamodel_state,
)

from .conftest import stub_no_metamodel

CAT = "fresh_cat"


def _ws(schemas=("default",), client_id="sp-client-123"):
    ws = MagicMock()
    ws.schemas.list.return_value = iter([SimpleNamespace(name=n) for n in schemas])
    ws.schemas.get.side_effect = NotFound("no schema")
    ws.volumes.read.side_effect = NotFound("no volume")
    ws.config.client_id = client_id
    return ws


SCHEMA_GET = call(f"{CAT}._metamodel")
VOLUME_READ = call(f"{CAT}._metamodel.vol_root")


def _schema_exists_error(_message=None):
    # Live workspace shape: UC reports an existing schema as BadRequest, not a conflict.
    return BadRequest("Schema '_metamodel' already exists", error_code="SCHEMA_ALREADY_EXISTS")


def _run(intent=Intent.NEW_BASE_MODEL):
    return RunIn(intent=intent, catalog=CAT, cataloging_style="One Catalog")


# --- helper -----------------------------------------------------------------

def test_helper_creates_schema_and_managed_volume():
    ws = _ws()
    created = ensure_metamodel_schema_and_volume(ws, CAT)
    ws.schemas.create.assert_called_once_with(name="_metamodel", catalog_name=CAT)
    ws.volumes.create.assert_called_once_with(
        catalog_name=CAT, schema_name="_metamodel", name="vol_root",
        volume_type=VolumeType.MANAGED,
    )
    assert len(created) == 2


def test_helper_creates_each_requested_volume_and_names_it_on_failure():
    ws = _ws()
    ws.schemas.get.side_effect = None
    created = ensure_metamodel_schema_and_volume(ws, CAT, volumes=("assess_runs",))
    assert created == [f"managed volume {CAT}._metamodel.assess_runs"]
    assert ws.volumes.create.call_args.kwargs["name"] == "assess_runs"
    ws.volumes.create.side_effect = PermissionDenied("no CREATE VOLUME")
    with pytest.raises(MetamodelSetupError) as exc:
        ensure_metamodel_schema_and_volume(ws, CAT, volumes=("assess_runs",))
    assert exc.value.step == "volume" and "`assess_runs` volume" in str(exc.value)
    assert "vol_root" not in str(exc.value)


@pytest.mark.parametrize(
    "schema_error, volume_error",
    [
        (_schema_exists_error, ResourceAlreadyExists),
        (AlreadyExists, AlreadyExists),
        (ResourceConflict, ResourceConflict),
    ],
    ids=["live-shapes", "already-exists", "resource-conflict"],
)
def test_helper_already_exists_is_success(schema_error, volume_error):
    # Absent on the probe, present on the re-probe after the failed create.
    ws = _ws()
    ws.schemas.get.side_effect = [NotFound("no schema"), None]
    ws.volumes.read.side_effect = [NotFound("no volume"), None]
    ws.schemas.create.side_effect = schema_error("exists")
    ws.volumes.create.side_effect = volume_error("exists")
    assert ensure_metamodel_schema_and_volume(ws, CAT) == []
    ws.volumes.create.assert_called_once()  # still attempts the volume
    assert ws.schemas.get.call_args_list == [SCHEMA_GET] * 2
    assert ws.volumes.read.call_args_list == [VOLUME_READ] * 2


# A schema create answered SCHEMA_ALREADY_EXISTS with a denied re-probe is the
# existing schema the app can't see (test_helper_existing_invisible_schema_names_use_schema).
_UNCONFIRMED = [
    (step, create_error, reprobe_error)
    for step in ("schema", "volume")
    for create_error in (_schema_exists_error, ResourceConflict)
    for reprobe_error in (NotFound, PermissionDenied)
    if not (step == "schema" and create_error is _schema_exists_error and reprobe_error is PermissionDenied)
]


@pytest.mark.parametrize("step, create_error, reprobe_error", _UNCONFIRMED)
def test_helper_failed_create_unconfirmed_raises_generic(step, create_error, reprobe_error):
    ws = _ws()
    error = create_error("conflict")
    if step == "schema":
        ws.schemas.create.side_effect = error
        ws.schemas.get.side_effect = [NotFound("no schema"), reprobe_error("gone")]
    else:
        ws.volumes.create.side_effect = error
        ws.volumes.read.side_effect = [NotFound("no volume"), reprobe_error("gone")]
    with pytest.raises(MetamodelSetupError) as ei:
        ensure_metamodel_schema_and_volume(ws, CAT)
    msg = str(ei.value)
    assert msg.startswith("Couldn't set up `_metamodel`")
    assert "can't create" not in msg
    assert ei.value.step == step
    assert ei.value.__cause__ is error
    if step == "schema":
        assert ws.schemas.get.call_args_list == [SCHEMA_GET] * 2
        ws.volumes.create.assert_not_called()
    else:
        assert ws.volumes.read.call_args_list == [VOLUME_READ] * 2


@pytest.mark.parametrize(
    "volumes, named",
    [
        ((), f"`{CAT}._metamodel.vol_root`"),
        (("vol_root", "assess_runs"), f"`{CAT}._metamodel.vol_root` and `{CAT}._metamodel.assess_runs`"),
    ],
    ids=["run", "assessment-job"],
)
def test_helper_existing_invisible_schema_names_use_schema(volumes, named):
    """``SCHEMA_ALREADY_EXISTS`` on create and a denied re-probe: the schema is
    there but the app can't see it. The hint names USE SCHEMA and the volumes
    being set up, never CREATE_SCHEMA; nothing else is created."""
    ws = _ws()
    error = _schema_exists_error()
    ws.schemas.create.side_effect = error
    ws.schemas.get.side_effect = [PermissionDenied("no USE SCHEMA"), PermissionDenied("no USE SCHEMA")]
    with pytest.raises(MetamodelSetupError) as ei:
        ensure_metamodel_schema_and_volume(ws, CAT, *((volumes,) if volumes else ()))
    assert (ei.value.step, ei.value.invisible) == ("schema", True)
    assert str(ei.value) == (
        f"`_metamodel` exists in '{CAT}' but the app can't see it (needs USE SCHEMA on "
        f"`{CAT}._metamodel`, plus READ VOLUME and WRITE VOLUME on {named})."
    )
    assert str(ei.value) == metamodel_setup.invisible_metamodel_message(CAT, volumes or ("vol_root",))
    assert "CREATE_SCHEMA" not in str(ei.value)
    assert ei.value.__cause__ is error
    ws.volumes.create.assert_not_called()


@pytest.mark.parametrize(
    "create_error", [PermissionDenied, ResourceConflict, lambda m: BadRequest(m, error_code="INVALID_PARAMETER_VALUE")],
    ids=["permission-denied", "conflict", "other-bad-request"],
)
def test_helper_denied_reprobe_without_already_exists_keeps_its_message(create_error):
    """Only ``SCHEMA_ALREADY_EXISTS`` is evidence the schema exists."""
    ws = _ws()
    ws.schemas.create.side_effect = create_error("nope")
    ws.schemas.get.side_effect = [NotFound("no schema"), PermissionDenied("denied")]
    with pytest.raises(MetamodelSetupError) as ei:
        ensure_metamodel_schema_and_volume(ws, CAT)
    assert ei.value.invisible is False
    assert "can't see it" not in str(ei.value)


@pytest.mark.parametrize("create_error", [PermissionDenied, RuntimeError])
@pytest.mark.parametrize("step", ["schema", "volume"])
def test_helper_failed_create_but_object_exists_is_success(step, create_error):
    ws = _ws()
    if step == "schema":
        ws.schemas.create.side_effect = create_error("racing creator won")
        ws.schemas.get.side_effect = [NotFound("no schema"), None]
    else:
        ws.volumes.create.side_effect = create_error("racing creator won")
        ws.volumes.read.side_effect = [NotFound("no volume"), None]
    created = ensure_metamodel_schema_and_volume(ws, CAT)
    if step == "schema":
        assert created == [f"managed volume {CAT}._metamodel.vol_root"]
    else:
        assert created == [f"schema {CAT}._metamodel"]
    if step == "schema":
        assert ws.schemas.get.call_args_list == [SCHEMA_GET] * 2
        assert ws.volumes.read.call_args_list == [VOLUME_READ]
    else:
        assert ws.schemas.get.call_args_list == [SCHEMA_GET]
        assert ws.volumes.read.call_args_list == [VOLUME_READ] * 2
    ws.volumes.create.assert_called_once()


@pytest.mark.parametrize("step", ["schema", "volume"])
def test_helper_permission_denied_reprobe_error_keeps_permission_message(step):
    ws = _ws()
    error = PermissionDenied("denied")
    if step == "schema":
        ws.schemas.create.side_effect = error
        ws.schemas.get.side_effect = [NotFound("no schema"), RuntimeError("reprobe boom")]
    else:
        ws.volumes.create.side_effect = error
        ws.volumes.read.side_effect = [NotFound("no volume"), RuntimeError("reprobe boom")]
    with pytest.raises(MetamodelSetupError) as ei:
        ensure_metamodel_schema_and_volume(ws, CAT)
    assert ei.value.step == step
    assert str(ei.value).startswith("The app can't create")
    assert "reprobe boom" not in str(ei.value)
    assert ei.value.__cause__ is error
    if step == "schema":
        assert ws.schemas.get.call_args_list == [SCHEMA_GET] * 2
    else:
        assert ws.volumes.read.call_args_list == [VOLUME_READ] * 2


def test_helper_permission_denied_sanitized_and_names_sp():
    ws = _ws()
    error = PermissionDenied("User x@corp.com lacks CREATE SCHEMA on /Volumes/secret/path")
    ws.schemas.create.side_effect = error
    with pytest.raises(MetamodelSetupError) as ei:
        ensure_metamodel_schema_and_volume(ws, CAT)
    msg = str(ei.value)
    assert ei.value.step == "schema"
    assert ei.value.__cause__ is error
    assert ws.schemas.get.call_args_list == [SCHEMA_GET] * 2  # probe + re-probe
    assert "sp-client-123" in msg
    assert "USE_CATALOG" in msg and "CREATE_SCHEMA" in msg
    assert "install/grant_catalog.py" in msg
    assert "x@corp.com" not in msg and "/Volumes/secret" not in msg
    ws.volumes.create.assert_not_called()


def test_helper_other_error_sanitized():
    ws = _ws()
    ws.volumes.create.side_effect = RuntimeError("boom token Bearer abc.def internal")
    with pytest.raises(MetamodelSetupError) as ei:
        ensure_metamodel_schema_and_volume(ws, CAT)
    assert "boom" not in str(ei.value) and "Bearer" not in str(ei.value)


def test_helper_volume_permission_denied_names_volume_grants():
    ws = _ws()
    error = PermissionDenied("User x@corp.com lacks CREATE VOLUME")
    ws.volumes.create.side_effect = error
    with pytest.raises(MetamodelSetupError) as ei:
        ensure_metamodel_schema_and_volume(ws, CAT)
    msg = str(ei.value)
    assert ei.value.step == "volume"
    assert ei.value.__cause__ is error
    assert ws.volumes.read.call_args_list == [VOLUME_READ] * 2  # probe + re-probe
    assert msg == (
        f"The app can't create the `vol_root` volume in '{CAT}._metamodel' (needs "
        f"USE_SCHEMA + CREATE_VOLUME on that schema). Ask a catalog owner to grant "
        f"the app's service principal (sp-client-123) those privileges, or run "
        f"`install/grant_catalog.py`."
    )
    assert "x@corp.com" not in msg
    ws.schemas.create.assert_called_once()


def test_helper_skips_existing_objects():
    ws = _ws()
    ws.schemas.get.side_effect = None
    ws.volumes.read.side_effect = None
    assert ensure_metamodel_schema_and_volume(ws, CAT) == []
    ws.schemas.create.assert_not_called()
    ws.volumes.create.assert_not_called()
    assert ws.schemas.get.call_args_list == [SCHEMA_GET]
    assert ws.volumes.read.call_args_list == [VOLUME_READ]


@pytest.mark.parametrize("step", ["schema", "volume"])
def test_helper_probe_unexpected_error_raises_generic(step):
    ws = _ws()
    error = RuntimeError("probe blew up Bearer abc.def")
    if step == "schema":
        ws.schemas.get.side_effect = error
    else:
        ws.volumes.read.side_effect = error
    with pytest.raises(MetamodelSetupError) as ei:
        ensure_metamodel_schema_and_volume(ws, CAT)
    msg = str(ei.value)
    assert ei.value.step == step
    assert ei.value.__cause__ is error
    assert msg.startswith("Couldn't set up `_metamodel`")
    assert "Bearer" not in msg
    if step == "schema":
        assert "USE_CATALOG + CREATE_SCHEMA" in msg
        ws.schemas.create.assert_not_called()
        ws.volumes.create.assert_not_called()
    else:
        assert f"USE_SCHEMA + CREATE_VOLUME on '{CAT}._metamodel'" in msg
        ws.schemas.create.assert_called_once()
        ws.volumes.create.assert_not_called()


def test_metamodel_setup_imports_only_stdlib_and_sdk():
    # install/grant_catalog.py loads this module by file path in an operator env
    # where only the stdlib and databricks.sdk are guaranteed.
    tree = ast.parse(Path(metamodel_setup.__file__).read_text())
    roots = set()
    for node in ast.walk(tree):
        if isinstance(node, ast.ImportFrom):
            assert node.level == 0, f"relative import: from {'.' * node.level}{node.module or ''}"
            roots.add(node.module.split(".")[0])
        elif isinstance(node, ast.Import):
            roots.update(alias.name.split(".")[0] for alias in node.names)
    allowed = set(sys.stdlib_module_names) | {"__future__", "databricks"}
    assert roots <= allowed, roots - allowed


# --- probe ------------------------------------------------------------------

def test_state_absent_schema_lists_every_volume_and_creates_nothing():
    ws = _ws()
    assert metamodel_state(ws, CAT, ("vol_root", "assess_runs")) == MetamodelState(
        schema=False, missing_volumes=("vol_root", "assess_runs"),
    )
    ws.volumes.read.assert_not_called()
    ws.schemas.create.assert_not_called()
    ws.volumes.create.assert_not_called()


def test_state_present_schema_missing_vol_root():
    ws = _ws()
    ws.schemas.get.side_effect = None
    assert metamodel_state(ws, CAT) == MetamodelState(schema=True, missing_volumes=("vol_root",))
    assert ws.volumes.read.call_args_list == [VOLUME_READ]


def test_state_present():
    ws = _ws()
    ws.schemas.get.side_effect = None
    ws.volumes.read.side_effect = None
    assert metamodel_state(ws, CAT) == MetamodelState(schema=True, missing_volumes=())


def test_state_denied_schema():
    ws = _ws()
    ws.schemas.get.side_effect = PermissionDenied("denied")
    assert metamodel_state(ws, CAT) == MetamodelState(schema=None, denied=True)


@pytest.mark.parametrize("error", [PermissionDenied("denied"), RuntimeError("auth")])
def test_state_unreadable_is_not_absent(error):
    ws = _ws()
    ws.schemas.get.side_effect = RuntimeError("auth")
    assert metamodel_state(ws, CAT) == MetamodelState(schema=None)
    ws.schemas.get.side_effect = None
    ws.volumes.read.side_effect = error
    assert metamodel_state(ws, CAT) == MetamodelState(schema=True, missing_volumes=())


# --- route preflight --------------------------------------------------------

@pytest.fixture
def biz_id(engine):
    with Session(engine) as s:
        ind = Industry(name="Test", short_name="test", description="x")
        s.add(ind)
        s.flush()
        b = Business(name="autosetup-biz", description="t", industry_id=ind.id)
        s.add(b)
        s.add(AgentConfig(
            notebook_path="/Workspace/agent.ipynb", deployment_catalog="metamodel_cat",
            warehouse_id="wh-1", job_id=1, job_name="dbx_test",
        ))
        s.commit()
        return b.id


_BODY = {"intent": "new-base-model", "catalog": CAT, "cataloging_style": "One Catalog"}


def test_validate_endpoint_reports_prepare_without_creating(client, biz_id, mock_ws):
    stub_no_metamodel(mock_ws)
    resp = client.post(f"/api/businesses/{biz_id}/runs/validate", json=_BODY)
    assert resp.status_code == 200, resp.text
    body = resp.json()
    assert not any("_metamodel" in b["message"] for b in body["blockers"]), body
    assert [w for w in body["warnings"] if w["severity"] == "prepare"] == [{
        "field_path": "catalog", "step_index": -1, "severity": "prepare", "subject": None,
        "versions": [], "message": f"`_metamodel` will be set up in '{CAT}' when you start the run.",
    }], body
    mock_ws.schemas.create.assert_not_called()
    mock_ws.volumes.create.assert_not_called()


def _install_version(engine, biz_id):
    from vibe_modeling.backend.db_models import ModelVersion

    with Session(engine) as s:
        mv = ModelVersion(business_id=biz_id, version=1, status="completed", scope="ecm", uc_catalog=CAT)
        s.add(mv)
        s.commit()
        return mv.id


def test_install_with_metamodel_but_no_vol_root_prepares_the_volume(client, engine, biz_id, mock_ws):
    """The probe reads each volume (a present schema used to end the check), so
    a missing ``vol_root`` is set up before the install's Run row."""
    vid = _install_version(engine, biz_id)
    mock_ws.schemas.get.side_effect = None
    mock_ws.volumes.read.side_effect = NotFound("no volume")
    body = {"intent": "install", "version_id": vid, "catalog": CAT, "cataloging_style": "One Catalog"}

    v = client.post(f"/api/businesses/{biz_id}/runs/validate", json=body)
    assert v.status_code == 200, v.text
    prepare = [w for w in v.json()["warnings"] if w["severity"] == "prepare"]
    assert [w["message"] for w in prepare] == [
        f"The `vol_root` volume will be created in '{CAT}._metamodel' when you start the run."
    ]
    mock_ws.volumes.create.assert_not_called()

    c = client.post(f"/api/businesses/{biz_id}/runs", json=body)
    assert c.status_code == 200, c.text
    mock_ws.schemas.create.assert_not_called()
    mock_ws.volumes.create.assert_called_once_with(
        catalog_name=CAT, schema_name="_metamodel", name="vol_root", volume_type=VolumeType.MANAGED,
    )


def test_install_without_metamodel_keeps_the_blocker(client, engine, biz_id, mock_ws):
    vid = _install_version(engine, biz_id)
    stub_no_metamodel(mock_ws)
    body = {"intent": "install", "version_id": vid, "catalog": CAT, "cataloging_style": "One Catalog"}
    v = client.post(f"/api/businesses/{biz_id}/runs/validate", json=body)
    assert v.status_code == 200, v.text
    assert any("has no `_metamodel` schema" in b["message"] for b in v.json()["blockers"])
    assert not [w for w in v.json()["warnings"] if w["severity"] == "prepare"]
    c = client.post(f"/api/businesses/{biz_id}/runs", json=body)
    assert c.status_code == 400, c.text
    assert "has no `_metamodel` schema" in c.json()["detail"]
    mock_ws.schemas.create.assert_not_called()
    mock_ws.volumes.create.assert_not_called()


def _run_count(engine, biz_id):
    with Session(engine) as s:
        return len(s.exec(select(Run).where(Run.business_id == biz_id)).all())


def test_create_endpoint_sets_up_metamodel(client, biz_id, mock_ws):
    stub_no_metamodel(mock_ws)
    resp = client.post(f"/api/businesses/{biz_id}/runs", json=_BODY)
    assert resp.status_code == 200, resp.text
    mock_ws.schemas.create.assert_called_once_with(name="_metamodel", catalog_name=CAT)
    mock_ws.volumes.create.assert_called_once()


def test_create_endpoint_metamodel_already_exists_ok(client, biz_id, mock_ws):
    stub_no_metamodel(mock_ws)
    # Live workspace shapes; absent on the probe, present on the re-probe.
    mock_ws.schemas.get.side_effect = [NotFound("no schema"), None]
    mock_ws.volumes.read.side_effect = [NotFound("no volume"), None]
    mock_ws.schemas.create.side_effect = _schema_exists_error()
    mock_ws.volumes.create.side_effect = ResourceAlreadyExists("exists")
    resp = client.post(f"/api/businesses/{biz_id}/runs", json=_BODY)
    assert resp.status_code == 200, resp.text
    assert mock_ws.schemas.get.call_args_list == [SCHEMA_GET] * 2
    assert mock_ws.volumes.read.call_args_list == [VOLUME_READ] * 2


def test_create_endpoint_permission_denied_is_400(client, engine, biz_id, mock_ws):
    stub_no_metamodel(mock_ws)
    mock_ws.config.client_id = "sp-client-123"
    mock_ws.schemas.create.side_effect = PermissionDenied("nope at /Workspace/a/b")
    resp = client.post(f"/api/businesses/{biz_id}/runs", json=_BODY)
    assert resp.status_code == 400, resp.text
    detail = resp.json()["detail"]
    assert "can't create `_metamodel`" in detail
    assert "sp-client-123" in detail
    assert "/Workspace" not in detail
    assert _run_count(engine, biz_id) == 0


def test_create_endpoint_invisible_schema_answers_the_denied_blocker(client, engine, biz_id, mock_ws, monkeypatch):
    """Level 3 meets an existing ``_metamodel`` the app can't see (the probe
    read NotFound, the create answered ``SCHEMA_ALREADY_EXISTS``, the re-probe
    was denied): create answers the pre-flight's denied-schema blocker, one
    wording with the GRANTs, and writes no Run row."""
    from vibe_modeling.backend.core import _app_identity
    from vibe_modeling.backend.services.orchestrator.preflight import _metamodel_denied_blocker

    monkeypatch.setattr(_app_identity, "app_application_id", lambda ws: "app-sp-id")
    stub_no_metamodel(mock_ws)
    # The pre-flight's read, the setup's probe, then its re-probe.
    mock_ws.schemas.get.side_effect = [NotFound("no schema"), NotFound("no schema"), PermissionDenied("no USE SCHEMA")]
    mock_ws.schemas.create.side_effect = _schema_exists_error()
    resp = client.post(f"/api/businesses/{biz_id}/runs", json=_BODY)
    assert resp.status_code == 400, resp.text
    detail = resp.json()["detail"]
    assert detail == _metamodel_denied_blocker(mock_ws, CAT).message
    assert detail.startswith(metamodel_setup.invisible_metamodel_message(CAT))
    assert "GRANT USE SCHEMA ON SCHEMA `fresh_cat`.`_metamodel` TO `app-sp-id`;" in detail
    assert "GRANT READ VOLUME, WRITE VOLUME ON VOLUME `fresh_cat`.`_metamodel`.`vol_root` TO `app-sp-id`;" in detail
    mock_ws.volumes.create.assert_not_called()
    assert _run_count(engine, biz_id) == 0


def _empty_description(engine, biz_id, mock_ws):
    with Session(engine) as s:
        b = s.get(Business, biz_id)
        b.description = ""
        s.add(b)
        s.commit()
    return _BODY


def _notebook_unreadable(engine, biz_id, mock_ws):
    mock_ws.workspace.get_status.side_effect = PermissionDenied("no notebook access")
    return _BODY


def _next_vibe_ids_without_version(engine, biz_id, mock_ws):
    return {**_BODY, "next_vibe_ids": ["vibe-1"]}


@pytest.mark.parametrize(
    "refuse",
    [_empty_description, _notebook_unreadable, _next_vibe_ids_without_version],
    ids=["empty-description", "notebook-access", "next-vibe-ids-without-version"],
)
def test_create_endpoint_refused_run_does_not_set_up_metamodel(
    client, engine, biz_id, mock_ws, monkeypatch, refuse
):
    stub_no_metamodel(mock_ws)
    spy = MagicMock()
    monkeypatch.setattr(metamodel_setup, "ensure_metamodel_schema_and_volume", spy)
    body = refuse(engine, biz_id, mock_ws)
    resp = client.post(f"/api/businesses/{biz_id}/runs", json=body)
    assert resp.status_code == 400, resp.text
    assert spy.call_count == 0
