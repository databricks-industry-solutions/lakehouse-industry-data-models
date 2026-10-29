"""The admin-help error shape: run links from the run's own job id, sanitized run errors, feedback details."""
from __future__ import annotations

import os
import sys

from sqlmodel import Session, select

sys.path.insert(0, os.path.dirname(__file__))

from _assess_helpers import ready_config, run, seed_domain_run  # noqa: E402
from test_assess_next_vibe_feedback import WHO, assess_next_vibe_data  # noqa: E402,F401
from vibe_modeling.backend.assessment.status import map_status  # noqa: E402
from vibe_modeling.backend.db_models import AssessBatch, AssessDomainRun  # noqa: E402
from vibe_modeling.backend.error_sanitization import DB_ERROR_MESSAGE  # noqa: E402

HOST = "https://test-workspace.databricks.com"


def _pin(engine, dr_id, **kw):
    with Session(engine) as s:
        dr = s.get(AssessDomainRun, dr_id)
        for k, v in kw.items():
            setattr(dr, k, v)
        s.add(dr); s.commit()
        return dr.batch_id


def test_run_links_come_from_the_runs_own_job_id(client, engine):
    dr_id = seed_domain_run(engine, databricks_run_id=1000, status="failed")
    batch_id = _pin(engine, dr_id, job_id=99, job_reader="reader-1", error_message="FAILED: boom")
    with Session(engine) as s:
        s.add(ready_config(job_id=555)); s.commit()  # the job was recreated since the run launched
    out = client.get(f"/api/assessments/{batch_id}").json()["domain_runs"][0]
    assert out["run_url"] == f"{HOST}/jobs/99/runs/1000" and out["job_url"] == f"{HOST}/jobs/99"
    assert out["job_reader"] == "reader-1" and out["error_message"] == "FAILED: boom"


def test_run_links_keep_the_workspace_selector(client, engine, mock_ws):
    mock_ws.config.host = f"{HOST}/?o=123"
    dr_id = seed_domain_run(engine, databricks_run_id=7, status="assessing")
    batch_id = _pin(engine, dr_id, job_id=9)
    out = client.get(f"/api/assessments/{batch_id}").json()["domain_runs"][0]
    assert out["run_url"] == f"{HOST}/jobs/9/runs/7?o=123" and out["job_url"] == f"{HOST}/jobs/9?o=123"


def test_run_without_a_databricks_run_has_a_job_link_but_no_run_link(client, engine):
    dr_id = seed_domain_run(engine, databricks_run_id=None, status="failed")
    batch_id = _pin(engine, dr_id, job_id=9)
    out = client.get(f"/api/assessments/{batch_id}").json()["domain_runs"][0]
    assert out["run_url"] == "" and out["job_url"] == f"{HOST}/jobs/9"


def test_failed_run_error_text_is_the_jobs_text_sanitized():
    u = map_status(run("TERMINATED", "FAILED", "Task failed for dana@example.com at /Volumes/c/s/v/x"), None)
    assert u.status == "failed"
    assert u.error_message.startswith("FAILED: Task failed for [REDACTED] at [REDACTED]")


def test_preflight_failure_text_is_kept():
    u = map_status(run("TERMINATED", "FAILED"), {"stage": "preflight_failed", "last_message": "no EXECUTE on model"})
    assert u.error_message == "Pre-flight failed — no EXECUTE on model"


def test_launch_bundle_failure_is_409_with_job_url(client, mock_ws, engine, monkeypatch):
    from _assess_helpers import ws_ok
    from vibe_modeling.backend.assessment import launch
    from vibe_modeling.backend.db_models import Business, Domain, ModelVersion
    ws_ok(mock_ws)
    with Session(engine) as s:
        b = Business(name="B", description="d"); s.add(b); s.commit(); s.refresh(b)
        mv = ModelVersion(business_id=b.id, version=1, scope="mvm", status="completed",
                          deployment_status="deployed", uc_catalog="cat")
        s.add(mv); s.commit(); s.refresh(mv)
        d = Domain(version_id=mv.id, name="d1", database_name="d1"); s.add(d)
        s.add(ready_config()); s.commit(); s.refresh(d)
        bid, vid, did = b.id, mv.id, d.id

    def no_bundle():
        raise RuntimeError("Vendored assessment assets are not packaged with this build.")
    monkeypatch.setattr(launch, "read_versions", no_bundle)
    r = client.post(f"/api/businesses/{bid}/assessments", json={"version_id": vid, "domains": [
        {"domain_id": did, "sources": [{"source_name": "s", "catalog_name": "b", "schema_name": "x"}]}]})
    assert r.status_code == 409
    assert r.json()["detail"] == {"error": "admin_help",
                                  "message": "Launch failed: Vendored assessment assets are not packaged with this build.",
                                  "job_url": f"{HOST}/jobs/99"}
    mock_ws.jobs.run_now.assert_not_called()
    with Session(engine) as s:
        assert s.exec(select(AssessBatch)).all() == []


def test_feedback_caller_errors_are_a_plain_message(client, assess_next_vibe_data):
    """A missing next vibe or a bad bulk filter is the caller's error: a plain ``{message}``, no admin help."""
    dr_id = assess_next_vibe_data.dr_id
    r = client.post(f"/api/assessment-domain-runs/{dr_id}/next-vibes/nope/feedback", json={}, headers=WHO)
    assert r.status_code == 404 and r.json()["detail"] == {"message": "Next vibe not found"}
    r = client.post(f"/api/assessment-domain-runs/{dr_id}/next-vibes/feedback/bulk",
                    json={"urgency": "someday"}, headers=WHO)
    assert r.status_code == 422 and r.json()["detail"] == {"message": "Unknown urgency: someday"}


def test_cancel_failure_is_409_with_the_runs_links_and_a_sanitized_error(client, engine, mock_ws):
    from databricks.sdk.errors.platform import DatabricksError
    dr_id = seed_domain_run(engine, databricks_run_id=1000, status="assessing")
    _pin(engine, dr_id, job_id=99, job_reader="reader-1")
    mock_ws.jobs.cancel_run.side_effect = DatabricksError("denied for dana@example.com")
    r = client.post(f"/api/assessment-domain-runs/{dr_id}/cancel")
    assert r.status_code == 409
    assert r.json()["detail"] == {"error": "admin_help",
                                  "message": "Databricks could not cancel run 1000: denied for [REDACTED]",
                                  "job_url": f"{HOST}/jobs/99", "run_url": f"{HOST}/jobs/99/runs/1000",
                                  "job_reader": "reader-1"}
    with Session(engine) as s:
        assert s.get(AssessDomainRun, dr_id).status == "assessing"


def test_single_feedback_db_failure_is_409_admin_help(client, assess_next_vibe_data, monkeypatch):
    from sqlalchemy.exc import OperationalError

    import vibe_modeling.backend.routes.assessments as routes

    def boom(*a, **k):
        raise OperationalError("INSERT INTO vibe_inputs (a) VALUES (%(a)s)", {"a": "secret-value"}, Exception("db gone"))
    monkeypatch.setattr(routes, "create_vibe_input_with_anchor", boom)
    dr_id, nv = assess_next_vibe_data.dr_id, assess_next_vibe_data.vibe_ids[0]
    r = client.post(f"/api/assessment-domain-runs/{dr_id}/next-vibes/{nv}/feedback", json={}, headers=WHO)
    assert r.status_code == 409 and r.json()["detail"]["error"] == "admin_help"
    message = r.json()["detail"]["message"]
    assert message.startswith("Couldn't add the next vibe to feedback: " + DB_ERROR_MESSAGE)
    assert "Reference: " in message
    for leaked in ("INSERT", "secret-value", "db gone", "[SQL"):
        assert leaked not in message


def test_bulk_feedback_db_failure_lands_in_failures_and_the_rest_commit(client, engine, assess_next_vibe_data,
                                                                         monkeypatch):
    from sqlalchemy.exc import OperationalError

    import vibe_modeling.backend.routes.assessments as routes
    from vibe_modeling.backend.db_models import AssessNextVibe, VibeInput

    real = routes.create_vibe_input_with_anchor
    ids = sorted(assess_next_vibe_data.vibe_ids)
    bad = ids[1]  # items run in id order, so the second create is the second id's
    calls = {"n": 0}

    def flaky(*a, **k):
        calls["n"] += 1
        vi = real(*a, **k)
        if calls["n"] == 2:
            raise OperationalError("INSERT INTO vibe_inputs (a) VALUES (%(a)s)", {"a": "secret-value"}, Exception("db gone"))
        return vi

    monkeypatch.setattr(routes, "create_vibe_input_with_anchor", flaky)
    r = client.post(f"/api/assessment-domain-runs/{assess_next_vibe_data.dr_id}/next-vibes/feedback/bulk",
                    json={"ids": assess_next_vibe_data.vibe_ids}, headers=WHO)
    assert r.status_code == 200, r.text
    body = r.json()
    assert [f["next_vibe_id"] for f in body["failures"]] == [bad]
    assert body["failures"][0]["message"].startswith("Couldn't add this next vibe to feedback")
    assert body["failures"][0]["message"].endswith("Please contact your administrator with these details.")
    assert DB_ERROR_MESSAGE in body["failures"][0]["message"] and "Reference: " in body["failures"][0]["message"]
    for leaked in ("INSERT", "secret-value", "db gone", "[SQL"):
        assert leaked not in body["failures"][0]["message"]
    assert body["count_created"] == len(ids) - 1 and [i["next_vibe_id"] for i in body["items"]] == [i for i in ids if i != bad]
    with Session(engine) as s:
        links = {nv.id: nv.vibe_input_id for nv in s.exec(select(AssessNextVibe).where(AssessNextVibe.id.in_(ids)))}
        assert links[bad] is None and all(links[i] for i in ids if i != bad)
        assert len(s.exec(select(VibeInput)).all()) == len(ids) - 1  # the failed item's VibeInput rolled back


def test_bulk_reports_unknown_ids_and_adds_the_rest(client, assess_next_vibe_data):
    dr_id, ids = assess_next_vibe_data.dr_id, assess_next_vibe_data.vibe_ids
    r = client.post(f"/api/assessment-domain-runs/{dr_id}/next-vibes/feedback/bulk",
                    json={"ids": [ids[0], "ghost"]}, headers=WHO)
    assert r.status_code == 200, r.text
    body = r.json()
    assert body["count_created"] == 1 and [i["next_vibe_id"] for i in body["items"]] == [ids[0]]
    assert body["failures"] == [{"next_vibe_id": "ghost", "message": "Next vibe not found in this assessment"}]
