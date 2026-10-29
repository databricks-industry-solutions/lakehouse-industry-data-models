import os
import sys
from unittest.mock import MagicMock

import pytest
from databricks.sdk.errors.platform import NotFound, PermissionDenied
from sqlmodel import Session

sys.path.insert(0, os.path.dirname(__file__))

from test_assess_handoff import WHO, ingested_completed_fixture  # noqa: E402,F401
from vibe_modeling.backend.assessment.schemas import SkillStatus  # noqa: E402
from vibe_modeling.backend.assessment.skill_install import plan_install  # noqa: E402
from vibe_modeling.backend.core._defaults import _get_user_ws_optional  # noqa: E402


def _s(n, st):
    return SkillStatus(name=n, state=st, location="none", bundled_version="0.4.0 x")


def test_default_installs_missing_only():
    assert plan_install([_s("a", "missing"), _s("b", "present"), _s("c", "update_available")], [], []) == (["a"], [], ["b", "c"])


def test_update_overwrites_only_listed():
    assert plan_install([_s("c", "update_available"), _s("d", "update_available")], [], ["c"]) == ([], ["c"], ["d"])


def test_unknown_name_is_skipped():
    assert plan_install([_s("a", "missing")], ["zzz"], []) == ([], [], ["zzz"])


@pytest.fixture(name="user_ws")
def user_ws_fixture(client):
    uw = MagicMock()
    client.app.dependency_overrides[_get_user_ws_optional] = lambda: uw
    yield uw
    client.app.dependency_overrides.pop(_get_user_ws_optional, None)


def _url(dr):
    return f"/api/assessment-domain-runs/{dr}/handoff/install-skills"


def test_no_obo_user_is_409(client, ingested_completed):
    r = client.post(_url(ingested_completed.dr_id), json={}, headers=WHO)
    assert r.status_code == 409 and "Sign in through the deployed app" in r.json()["detail"]["message"]


def test_installs_files_mkdirs_first_marker_last(client, mock_ws, user_ws, ingested_completed):
    mock_ws.workspace.get_status.side_effect = NotFound("none")  # every skill missing (workspace-wide probe)
    user_ws.workspace.get_status.side_effect = NotFound("none")
    r = client.post(_url(ingested_completed.dr_id), json={"names": ["domain-model-assessment"]}, headers=WHO)
    assert r.status_code == 200, r.text
    assert r.json()["installed"] == ["domain-model-assessment"] and r.json()["updated"] == []
    calls = user_ws.workspace.method_calls
    names = [c[0] for c in calls if c[0] in ("mkdirs", "import_")]
    assert names[0] == "mkdirs"
    imports = [c for c in calls if c[0] == "import_"]
    paths = [c.args[0] for c in imports]
    base = "/Workspace/Users/dana@example.com/.assistant/skills/domain-model-assessment/"
    assert all(p.startswith(base) for p in paths) and base + "SKILL.md" in paths
    assert paths[-1] == base + ".vibe-skill-version"
    assert all(c.kwargs["format"].value == "RAW" and c.kwargs["overwrite"] for c in imports)
    first_import = names.index("import_")
    assert "mkdirs" in names[:first_import]


def test_permission_denied_is_409_scope_message(client, mock_ws, user_ws, ingested_completed):
    mock_ws.workspace.get_status.side_effect = NotFound("none")
    user_ws.workspace.get_status.side_effect = NotFound("none")
    user_ws.workspace.mkdirs.side_effect = PermissionDenied("Provided OAuth token does not have required scopes")
    r = client.post(_url(ingested_completed.dr_id), json={"names": ["domain-model-assessment"]}, headers=WHO)
    assert r.status_code == 409 and "Reload the app and accept the permission prompt" in r.json()["detail"]["message"]


def test_no_email_is_401_identity_missing(client, user_ws, ingested_completed):
    r = client.post(_url(ingested_completed.dr_id), json={})
    assert r.status_code == 401
    assert r.json()["detail"]["error"] == "identity_missing"
    user_ws.workspace.import_.assert_not_called()


def test_missing_bundle_is_409_admin_help(client, mock_ws, user_ws, ingested_completed, monkeypatch):
    from vibe_modeling.backend.routes import assessments
    monkeypatch.setattr(assessments, "resolve_vendored_assessment", lambda: None)
    r = client.post(_url(ingested_completed.dr_id), json={"names": ["domain-model-assessment"]}, headers=WHO)
    assert r.status_code == 409 and r.json()["detail"]["error"] == "admin_help"
    assert r.json()["detail"]["message"] == "The app's bundled skills are missing — redeploy the app."


def test_unknown_listed_in_update_is_overwritten():
    assert plan_install([_s("a", "unknown"), _s("b", "unknown")], [], ["a"]) == ([], ["a"], ["b"])


def test_get_handoff_reports_a_scope_error_plainly(client, mock_ws, user_ws, ingested_completed):
    mock_ws.workspace.get_status.return_value = MagicMock()
    mock_ws.workspace.download.return_value.read.return_value = b"old"
    user_ws.workspace.get_status.side_effect = PermissionDenied("missing scopes")
    r = client.get(f"/api/assessment-domain-runs/{ingested_completed.dr_id}/handoff", headers=WHO)
    assert r.status_code == 200, r.text
    assert r.json()["skills_note"].startswith("The app needs one more permission to read your skills folder.")
    assert {(s["state"], s["location"]) for s in r.json()["skills"]} == {("update_available", "workspace")}
    assert not any(c.args[0].startswith("/Workspace/Users/") for c in mock_ws.workspace.get_status.call_args_list)


def _jwt(claims):
    import base64, json
    b = lambda d: base64.urlsafe_b64encode(json.dumps(d).encode()).rstrip(b"=").decode()
    return f"{b({'alg': 'none'})}.{b(claims)}.secretsig"


def test_get_handoff_logs_scopes_never_token(client, mock_ws, user_ws, ingested_completed, caplog):
    tok = _jwt({"scope": "sql workspace.workspace", "sub": "someone"})
    mock_ws.workspace.get_status.side_effect = NotFound("none")
    user_ws.workspace.get_status.side_effect = NotFound("none")
    with caplog.at_level("INFO"):
        r = client.get(f"/api/assessment-domain-runs/{ingested_completed.dr_id}/handoff",
                       headers={**WHO, "X-Forwarded-Access-Token": tok})
    assert r.status_code == 200, r.text
    msgs = [rec.getMessage() for rec in caplog.records]
    assert any("sql workspace.workspace" in m for m in msgs)
    assert not any(tok in m or "secretsig" in m or "someone" in m for m in msgs)


# --- type-mismatch replacement -------------------------------------------------------------------------------
from databricks.sdk.errors import DatabricksError  # noqa: E402

_MISMATCH = "Cannot overwrite the asset at /x due to type mismatch (asked: FILE, actual: DASHBOARD)."


def _install_with(user_ws, side_effect):
    from vibe_modeling.backend.assessment.skill_install import install_skill
    user_ws.workspace.import_.side_effect = side_effect
    install_skill(user_ws, "domain-model-assessment", "dana@example.com")


def test_type_mismatch_deletes_exact_path_and_retries():
    uw = MagicMock()
    state = {"n": 0}

    def imp(path, **kw):
        state["n"] += 1
        if state["n"] == 1:
            raise DatabricksError(_MISMATCH)

    _install_with(uw, imp)
    first = uw.workspace.import_.call_args_list[0].args[0]
    uw.workspace.delete.assert_called_once_with(first, recursive=False)
    assert uw.workspace.import_.call_args_list[1].args[0] == first
    assert first.startswith("/Workspace/Users/dana@example.com/.assistant/skills/domain-model-assessment/")


def test_second_failure_on_retry_propagates():
    uw = MagicMock()
    with pytest.raises(DatabricksError):
        _install_with(uw, DatabricksError(_MISMATCH))
    assert uw.workspace.delete.call_count == 1


def test_unrelated_error_no_delete():
    uw = MagicMock()
    with pytest.raises(DatabricksError):
        _install_with(uw, DatabricksError("boom"))
    uw.workspace.delete.assert_not_called()


def test_409_names_failing_skill(client, mock_ws, user_ws, ingested_completed):
    mock_ws.workspace.get_status.side_effect = NotFound("none")
    user_ws.workspace.get_status.side_effect = NotFound("none")
    user_ws.workspace.import_.side_effect = DatabricksError("boom")
    r = client.post(_url(ingested_completed.dr_id), json={"names": ["domain-model-assessment"]}, headers=WHO)
    assert r.status_code == 409
    d = r.json()["detail"]
    assert "Updating domain-model-assessment failed" in d["message"] and "Other skills may already be updated" in d["message"]
    assert set(d) == {"error", "message"}  # this run has no job or run id yet, so no links


def test_scope_409_carries_the_run_links(client, mock_ws, engine, user_ws, ingested_completed):
    from vibe_modeling.backend.db_models import AssessDomainRun
    with Session(engine) as s:
        dr = s.get(AssessDomainRun, ingested_completed.dr_id)
        dr.job_id, dr.databricks_run_id, dr.job_reader = 99, 1234, "reader-1"
        s.add(dr); s.commit()
    mock_ws.workspace.get_status.side_effect = NotFound("none")
    user_ws.workspace.get_status.side_effect = NotFound("none")
    user_ws.workspace.mkdirs.side_effect = PermissionDenied("Provided OAuth token does not have required scopes")
    r = client.post(_url(ingested_completed.dr_id), json={"names": ["domain-model-assessment"]}, headers=WHO)
    assert r.status_code == 409
    d = r.json()["detail"]
    assert "your skills folder" in d["message"] and d["message"].endswith("Error: Provided OAuth token does not have required scopes")
    assert d["job_url"] == "https://test-workspace.databricks.com/jobs/99"
    assert d["run_url"] == "https://test-workspace.databricks.com/jobs/99/runs/1234" and d["job_reader"] == "reader-1"
