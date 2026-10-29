import os
import sys

from databricks.sdk.service.iam import ServicePrincipal, User

sys.path.insert(0, os.path.dirname(__file__))

from _assess_helpers import _eff  # noqa: E402


def _sp(ws, app_id="app-123", name="vibe-assess-reader"):
    ws.service_principals.list.return_value = [ServicePrincipal(application_id=app_id, display_name=name)]


def test_get_config_unconfigured(client):
    r = client.get("/api/assess/config")
    assert r.status_code == 200
    body = r.json()
    assert body["installed"] is True and body["ready"] is False and body["max_concurrent_runs"] == 2
    assert body["missing"] == ["No reader service principal"] and body["job_url"] == ""


def _sync_ok(ws, app_sp="app-sp"):
    """A workspace client on which the whole job sync succeeds (volume missing, no grants yet)."""
    from databricks.sdk.errors.platform import NotFound
    ws.current_user.me.return_value = User(user_name=app_sp)
    ws.workspace.get_status.return_value.object_id = 1
    ws.workspace.list.return_value = []
    ws.volumes.read.side_effect = NotFound("no volume")
    ws.grants.get_effective.side_effect = lambda *a, **k: _eff()
    ws.jobs.create.return_value.job_id = 77


def _row(engine):
    from sqlmodel import Session, select

    from vibe_modeling.backend.db_models import AssessConfig
    with Session(engine) as s:
        return s.exec(select(AssessConfig)).first()


def test_put_config_syncs_folder_volume_grants_and_job(client, mock_ws, engine):
    from vibe_modeling import __version__ as app_version
    _sp(mock_ws)
    _sync_ok(mock_ws)
    r = client.put("/api/assess/config", json={"reader_application_id": "app-123", "warehouse_id": "wh-1"})
    assert r.status_code == 200, r.text
    body = r.json()
    assert body["ready"] is True and body["missing"] == []
    assert body["job_id"] == 77 and body["job_url"].endswith("/jobs/77") and "job_setup_error" not in body
    assert body["reader_display_name"] == "vibe-assess-reader"
    assert body["workspace_path"] == f"/Users/app-sp/vibe-assess/{app_version}"
    assert [c.kwargs["name"] for c in mock_ws.volumes.create.call_args_list] == ["vol_root", "assess_runs"]
    granted = {c.args[0]: (c.args[1], [p.value for p in c.kwargs["changes"][0].add])
               for c in mock_ws.grants.update.call_args_list}
    assert granted == {"volume": ("test_deployment_catalog._metamodel.assess_runs", ["READ_VOLUME", "WRITE_VOLUME"]),
                       "schema": ("test_deployment_catalog._metamodel", ["USE_SCHEMA"])}
    row = _row(engine)
    assert (row.synced_version, row.job_reader, row.warehouse_id) == (app_version, "app-123", "wh-1")
    assert row.reader_display_name == "vibe-assess-reader"
    assert mock_ws.service_principals.list.call_count == 1  # Save hands its lookup to the sync


def test_get_config_shows_the_stored_reader_name_without_a_scim_call(client, mock_ws):
    _sp(mock_ws)
    _sync_ok(mock_ws)
    assert client.put("/api/assess/config", json={"reader_application_id": "app-123"}).status_code == 200
    mock_ws.service_principals.list.reset_mock()
    assert client.get("/api/assess/config").json()["reader_display_name"] == "vibe-assess-reader"
    mock_ws.service_principals.list.assert_not_called()


def test_put_config_reader_lookup_error_is_409_admin_help_and_writes_nothing(client, mock_ws, engine):
    from databricks.sdk.errors.platform import PermissionDenied
    mock_ws.service_principals.list.side_effect = PermissionDenied("SCIM denied for dana@example.com")
    r = client.put("/api/assess/config", json={"reader_application_id": "app-123"})
    assert r.status_code == 409, r.text
    assert r.json()["detail"] == {
        "error": "admin_help",
        "message": "Couldn't look up the reader service principal: SCIM denied for [REDACTED]"}
    mock_ws.workspace.upload.assert_not_called(); mock_ws.jobs.create.assert_not_called()
    assert _row(engine) is None


def test_put_config_unknown_reader_is_400_setting_refused(client, mock_ws, engine):
    mock_ws.service_principals.list.return_value = []
    r = client.put("/api/assess/config", json={"reader_application_id": "nope"})
    assert r.status_code == 400
    detail = r.json()["detail"]
    assert detail["error"] == "setting_refused" and detail["key"] == "reader_application_id"
    assert "not found" in detail["message"].lower()
    mock_ws.workspace.upload.assert_not_called(); mock_ws.jobs.create.assert_not_called()
    assert _row(engine) is None


def test_put_config_unknown_warehouse_is_400_and_writes_nothing(client, mock_ws, engine):
    from databricks.sdk.errors.platform import NotFound
    _sp(mock_ws)
    _sync_ok(mock_ws)
    mock_ws.warehouses.get.side_effect = NotFound("no warehouse visible to dana@example.com")
    r = client.put("/api/assess/config", json={"reader_application_id": "app-123", "warehouse_id": "gone"})
    assert r.status_code == 400
    detail = r.json()["detail"]
    assert detail["error"] == "setting_refused" and detail["key"] == "warehouse_id"
    assert "'gone'" in detail["message"]
    assert "[REDACTED]" in detail["message"] and "dana@example.com" not in r.text
    mock_ws.workspace.upload.assert_not_called(); mock_ws.grants.update.assert_not_called()
    mock_ws.jobs.create.assert_not_called()
    assert _row(engine) is None


def test_put_config_without_deployment_catalog_is_422_config_missing(client, mock_ws, config, engine):
    _sp(mock_ws)
    _sync_ok(mock_ws)
    config.deployment_catalog = ""
    r = client.put("/api/assess/config", json={"reader_application_id": "app-123"})
    assert r.status_code == 422
    detail = r.json()["detail"]
    assert detail["error"] == "config_missing"
    assert [m["key"] for m in detail["missing"]] == ["metamodel_catalog"]
    mock_ws.service_principals.list.assert_not_called()  # the unset setting answers before any workspace call
    mock_ws.workspace.upload.assert_not_called(); mock_ws.jobs.create.assert_not_called()
    assert _row(engine) is None


def test_put_config_sync_failure_rolls_back_records_error_and_is_409(client, mock_ws, engine):
    from databricks.sdk.errors.platform import PermissionDenied

    from vibe_modeling.backend.db_models import AssessConfig
    from sqlmodel import Session
    with Session(engine) as s:
        s.add(AssessConfig(reader_application_id="old-reader", warehouse_id="wh-old", job_id=5, job_reader="old-reader"))
        s.commit()
    _sp(mock_ws)
    _sync_ok(mock_ws)
    mock_ws.jobs.reset.side_effect = PermissionDenied("not servicePrincipal.user")
    mock_ws.jobs.get.return_value.settings.run_as.service_principal_name = "old-reader"
    mock_ws.jobs.get.return_value.settings.tasks = []
    r = client.put("/api/assess/config", json={"reader_application_id": "app-123", "warehouse_id": "wh-new"})
    assert r.status_code == 409, r.text
    detail = r.json()["detail"]
    assert detail["error"] == "admin_help"
    assert "servicePrincipal.user" in detail["message"] and detail["job_url"].endswith("/jobs/5")
    row = _row(engine)
    assert row.reader_application_id == "old-reader" and row.warehouse_id == "wh-old"  # the Save rolled back
    assert "servicePrincipal.user" in row.job_setup_error and row.job_id == 5 and row.job_reader == "old-reader"
    body = client.get("/api/assess/config").json()
    assert body["ready"] is False and body["missing"][0].startswith("Job sync failed: ")


def test_put_config_clean_sync_clears_a_recorded_error(client, mock_ws, engine):
    from vibe_modeling.backend.db_models import AssessConfig
    from sqlmodel import Session
    with Session(engine) as s:
        s.add(AssessConfig(reader_application_id="app-123", job_setup_error="old failure")); s.commit()
    _sp(mock_ws)
    _sync_ok(mock_ws)
    r = client.put("/api/assess/config", json={"reader_application_id": "app-123"})
    assert r.status_code == 200 and r.json()["ready"] is True and _row(engine).job_setup_error == ""


def test_new_row_is_seeded_from_the_install_reader(client, config, engine):
    config.assess_reader_sp = "install-reader"
    assert client.get("/api/assess/config").json()["reader_application_id"] == "install-reader"


def test_settings_reader_wins_over_the_install_reader(client, config, engine):
    from vibe_modeling.backend.db_models import AssessConfig
    from sqlmodel import Session
    with Session(engine) as s:
        s.add(AssessConfig(reader_application_id="settings-reader")); s.commit()
    config.assess_reader_sp = "install-reader"
    assert client.get("/api/assess/config").json()["reader_application_id"] == "settings-reader"


def test_get_config_exposes_app_application_id(client, mock_ws):
    from vibe_modeling.backend.core import _app_identity
    _app_identity._APP_ID_CACHE.clear()
    mock_ws.current_user.me.return_value = User(user_name="aeae7e5c-0000-0000-0000-000000000000")
    assert client.get("/api/assess/config").json()["app_application_id"] == "aeae7e5c-0000-0000-0000-000000000000"


def test_get_config_app_application_id_falls_back_to_user_name(client, mock_ws):
    from vibe_modeling.backend.core import _app_identity
    _app_identity._APP_ID_CACHE.clear()
    me = mock_ws.current_user.me.return_value
    me.application_id, me.user_name = None, "sp-user-name"
    assert client.get("/api/assess/config").json()["app_application_id"] == "sp-user-name"


def test_get_config_app_application_id_empty_when_me_fails(client, mock_ws):
    from vibe_modeling.backend.core import _app_identity
    _app_identity._APP_ID_CACHE.clear()
    mock_ws.current_user.me.side_effect = RuntimeError("boom")
    body = client.get("/api/assess/config").json()
    assert body["app_application_id"] == ""



def _assess_routes():
    from vibe_modeling.backend.routes import assessments
    return [(m, r.path) for r in assessments.router.routes for m in sorted(r.methods)]


def test_every_gated_route_is_404_when_not_installed(client, config):
    import re
    config.assessment_enabled = False
    routes = _assess_routes()
    assert len(routes) >= 20
    for method, path in routes:
        r = client.request(method, re.sub(r"\{[^}]+\}", "x", path), json={})
        assert r.status_code == 404, (method, path, r.status_code)
        assert r.json()["detail"] == "The bronze assessment skill is not installed", (method, path)


def test_get_config_answers_when_not_installed(client, config):
    config.assessment_enabled = False
    r = client.get("/api/assess/config")
    assert r.status_code == 200
    body = r.json()
    assert body["installed"] is False and body["ready"] is False
    assert body["missing"] == ["The bronze assessment skill is not installed"]


def test_get_config_when_not_installed_touches_neither_the_row_nor_the_identity(client, config, engine, mock_ws):
    from sqlmodel import Session, select

    from vibe_modeling.backend.db_models import AssessConfig
    config.assessment_enabled = False
    body = client.get("/api/assess/config").json()
    assert body["installed"] is False and body["app_application_id"] == "" and body["job_url"] == ""
    mock_ws.current_user.me.assert_not_called()
    with Session(engine) as s:
        assert s.exec(select(AssessConfig)).first() is None


def test_config_route_is_the_only_ungated_assessment_route():
    from vibe_modeling.backend.routes import assessments
    assert [(sorted(r.methods), r.path) for r in assessments.config_router.routes] == [(["GET"], "/api/assess/config")]
    assert ("GET", "/api/assess/config") not in _assess_routes()


def test_a_second_save_sees_the_job_the_first_one_created(client, mock_ws, engine):
    _sp(mock_ws)
    _sync_ok(mock_ws)
    assert client.put("/api/assess/config", json={"reader_application_id": "app-123"}).status_code == 200
    r = client.put("/api/assess/config", json={"reader_application_id": "app-123", "max_concurrent_runs": 3})
    assert r.status_code == 200 and r.json()["job_id"] == 77
    assert mock_ws.jobs.create.call_count == 1
    assert mock_ws.jobs.reset.call_args.kwargs["job_id"] == 77


def test_save_409_links_the_stored_job_when_it_cannot_be_reread(client, mock_ws, engine):
    from databricks.sdk.errors.platform import PermissionDenied
    from sqlmodel import Session

    from vibe_modeling.backend.db_models import AssessConfig
    with Session(engine) as s:
        s.add(AssessConfig(reader_application_id="app-123", job_id=5)); s.commit()
    _sp(mock_ws)
    _sync_ok(mock_ws)
    mock_ws.workspace.upload.side_effect = PermissionDenied("no write on home")
    mock_ws.jobs.get.side_effect = PermissionDenied("cannot read job")
    r = client.put("/api/assess/config", json={"reader_application_id": "app-123"})
    assert r.status_code == 409
    d = r.json()["detail"]
    assert d["error"] == "admin_help" and d["job_url"].endswith("/jobs/5")
    assert d["message"].startswith("The assessment job sync failed: Uploading the assessment notebook failed")


def test_get_config_serializes_a_naive_updated_at_as_utc(client, mock_ws, engine, monkeypatch):
    """Lakebase TIMESTAMPs read back naive; the route marks them UTC like its neighbours.

    Newer sqlmodel refuses to write a naive datetime and reads SQLite back
    as aware UTC, so the stored row can't produce the naive value on every
    version. The row read is wrapped to hand the route a detached row with
    a naive ``updated_at``, which is what Lakebase returns."""
    from datetime import datetime

    from vibe_modeling.backend.routes import assessments as assess_routes

    _sp(mock_ws)
    _sync_ok(mock_ws)
    assert client.put("/api/assess/config", json={"reader_application_id": "app-123"}).status_code == 200
    stored = _row(engine)
    assert stored is not None
    real_get = assess_routes.get_or_create_assess_config
    handed: list[datetime] = []

    def _naive_updated_at(session, config):
        row = real_get(session, config)
        session.expunge(row)
        row.updated_at = datetime(2026, 7, 1, 2, 30)
        handed.append(row.updated_at)
        return row

    monkeypatch.setattr(assess_routes, "get_or_create_assess_config", _naive_updated_at)
    resp = client.get("/api/assess/config")
    assert resp.status_code == 200
    assert handed and all(v.tzinfo is None for v in handed)
    assert resp.json()["updated_at"] == "2026-07-01T02:30:00Z"