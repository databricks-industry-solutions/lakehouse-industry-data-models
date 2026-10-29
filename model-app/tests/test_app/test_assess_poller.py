import asyncio
import io
import json
import os
import sys
from datetime import datetime, timedelta, timezone
from types import SimpleNamespace as NS
from unittest.mock import MagicMock

import pytest
from databricks.sdk.errors.platform import DatabricksError, NotFound
from sqlmodel import Session, select

from vibe_modeling.backend.assessment import poller as poller_mod
from vibe_modeling.backend.assessment.ingest import IngestResult
from vibe_modeling.backend.assessment.poller import AssessPoller
from vibe_modeling.backend.assessment.status import map_status
from vibe_modeling.backend.db_models import (
    AssessBatch, AssessConfig, AssessDomainRun, Business, Domain, ModelVersion,
)

sys.path.insert(0, os.path.dirname(__file__))

from _assess_helpers import run, seed_domain_run

OUT = "/Volumes/c/_metamodel/assess_runs/b/d"


@pytest.mark.parametrize("lc,rs,progress,expected", [
    ("QUEUED", None, None, "queued"),
    ("PENDING", None, None, "starting"),
    ("RUNNING", None, None, "assessing"),
    ("RUNNING", None, {"stage": "installing"}, "starting"),
    ("RUNNING", None, {"stage": "rate_limited", "attempt": 3, "resume_at": 1700000000}, "rate_limited"),
    ("RUNNING", None, {"stage": "assessing", "attempt": 1}, "assessing"),
    ("TERMINATED", "CANCELED", None, "cancelled"),
    ("TERMINATED", "FAILED", {"stage": "preflight_failed", "last_message": "bronze:src_a: 0 tables"}, "failed"),
    ("TERMINATED", "TIMEDOUT", None, "failed"),
    ("INTERNAL_ERROR", None, None, "failed"),
])
def test_map_status(lc, rs, progress, expected):
    assert map_status(run(lc, rs), progress).status == expected


def test_success_is_terminal_success_not_status():
    u = map_status(run("TERMINATED", "SUCCESS"), {"stage": "done"})
    assert u.terminal_success and u.status == "assessing"  # final status decided by ingest


def test_preflight_failure_message_surfaces():
    u = map_status(run("TERMINATED", "FAILED", "Task failed"), {"stage": "preflight_failed",
                   "last_message": "bronze:src_a: permission denied"})
    assert "Pre-flight failed" in u.error_message and "src_a" in u.error_message


def test_rate_limited_carries_attempt_and_resume_at():
    u = map_status(run("RUNNING"), {"stage": "rate_limited", "attempt": 3, "resume_at": 1700000000})
    assert u.attempt == 3 and u.resume_at.year == 2023


# --- poller ---
def _progress_ws(files: dict[str, bytes] | None = None):
    files = files or {}
    ws = MagicMock()

    def dl(path):
        if path not in files:
            raise NotFound(path)
        return NS(contents=io.BytesIO(files[path]))

    ws.files.download.side_effect = dl
    return ws


def _poller(ws, engine):
    return AssessPoller(ws, lambda: Session(engine))


def _get(engine, dr_id):
    with Session(engine) as s:
        return s.get(AssessDomainRun, dr_id)


def test_tick_updates_running_and_ingests_success(engine, monkeypatch):
    d1 = seed_domain_run(engine, databricks_run_id=1, out_dir=OUT + "1")
    d2 = seed_domain_run(engine, databricks_run_id=2, out_dir=OUT + "2")
    ws = _progress_ws({OUT + "1/progress.json": json.dumps(
        {"stage": "rate_limited", "attempt": 2, "resume_at": 1700000000, "last_message": "429"}).encode()})
    ws.jobs.get_run.side_effect = lambda rid: run("RUNNING") if rid == 1 else run("TERMINATED", "SUCCESS")
    monkeypatch.setattr(poller_mod, "ingest_domain_run", lambda s, w, dr: IngestResult(True, ""))
    assert _poller(ws, engine).tick() == 2
    r1, r2 = _get(engine, d1), _get(engine, d2)
    assert (r1.status, r1.attempt, r1.last_message) == ("rate_limited", 2, "429")
    assert r1.resume_at is not None and r1.ended_at is None and r1.started_at is not None
    assert r2.status == "completed" and r2.ended_at is not None


@pytest.mark.parametrize("progress_bytes", [None, b'{"stage": "assess', b"", b"[]"])
def test_tick_tolerates_missing_or_bad_progress_json(engine, progress_bytes):
    dr_id = seed_domain_run(engine, databricks_run_id=1, status="queued")
    ws = MagicMock()
    ws.jobs.get_run.return_value = run("RUNNING")

    def dl(path):
        if progress_bytes is None:
            raise NotFound(path)
        return NS(contents=io.BytesIO(progress_bytes))
    ws.files.download.side_effect = dl
    assert _poller(ws, engine).tick() == 1
    dr = _get(engine, dr_id)
    assert dr.status == "assessing" and dr.started_at is not None


def test_tick_transient_progress_read_error_uses_jobs_state(engine):
    dr_id = seed_domain_run(engine, databricks_run_id=1)
    ws = MagicMock()
    ws.jobs.get_run.return_value = run("RUNNING")
    ws.files.download.side_effect = DatabricksError("temporarily unavailable")
    assert _poller(ws, engine).tick() == 1
    assert _get(engine, dr_id).status == "assessing"


def test_tick_run_not_found_marks_failed(engine):
    dr_id = seed_domain_run(engine, databricks_run_id=7)
    ws = _progress_ws()
    ws.jobs.get_run.side_effect = NotFound("gone")
    assert _poller(ws, engine).tick() == 1
    dr = _get(engine, dr_id)
    assert dr.status == "failed" and dr.error_message == "Run not found in Databricks" and dr.ended_at is not None


def test_tick_skips_terminal_and_unlaunched_rows(engine):
    seed_domain_run(engine, databricks_run_id=1, status="completed")
    seed_domain_run(engine, databricks_run_id=None, status="queued")  # fresh, unlaunched
    ws = _progress_ws()
    assert _poller(ws, engine).tick() == 0
    ws.jobs.get_run.assert_not_called()


def test_tick_results_invalid(engine, monkeypatch):
    dr_id = seed_domain_run(engine, databricks_run_id=1)
    ws = _progress_ws()
    ws.jobs.get_run.return_value = run("TERMINATED", "SUCCESS")
    monkeypatch.setattr(poller_mod, "ingest_domain_run", lambda s, w, dr: IngestResult(False, "x"))
    assert _poller(ws, engine).tick() == 1
    dr = _get(engine, dr_id)
    assert dr.status == "results_invalid" and dr.error_message == "x" and dr.ended_at is not None


def test_tick_failed_run_surfaces_preflight_error(engine):
    dr_id = seed_domain_run(engine, databricks_run_id=1, out_dir=OUT)
    ws = _progress_ws({OUT + "/progress.json": json.dumps(
        {"stage": "preflight_failed", "last_message": "bronze:src_a: 0 tables"}).encode()})
    ws.jobs.get_run.return_value = run("TERMINATED", "FAILED", "Task failed")
    _poller(ws, engine).tick()
    dr = _get(engine, dr_id)
    assert dr.status == "failed" and "Pre-flight failed" in dr.error_message and dr.ended_at is not None


def test_tick_fails_stale_launch_rows_only(engine):
    old = seed_domain_run(engine, databricks_run_id=None,
                          created_at=datetime.now(timezone.utc) - timedelta(minutes=11))
    fresh = seed_domain_run(engine, databricks_run_id=None,
                            created_at=datetime.now(timezone.utc) - timedelta(minutes=1))
    ws = _progress_ws()
    assert _poller(ws, engine).tick() == 1
    o, f = _get(engine, old), _get(engine, fresh)
    assert o.status == "failed" and o.ended_at is not None
    assert o.error_message == "Launch did not complete (no Databricks run was started)"
    assert f.status == "queued" and f.ended_at is None
    ws.jobs.get_run.assert_not_called()


def _open_window(engine, dr_id):
    """Move a run's ingest retry time into the past, as if its wait had elapsed."""
    with Session(engine) as s:
        dr = s.get(AssessDomainRun, dr_id)
        dr.ingest_next_at = datetime.now(timezone.utc) - timedelta(seconds=1)
        s.add(dr); s.commit()


def test_tick_ingest_exception_rolls_back_and_waits_out_the_window(engine, monkeypatch):
    bad = seed_domain_run(engine, databricks_run_id=1)
    ok = seed_domain_run(engine, databricks_run_id=2)
    ws = _progress_ws()
    ws.jobs.get_run.return_value = run("TERMINATED", "SUCCESS")
    calls = {"n": 0}

    def ingest(session, w, dr):
        calls["n"] += 1
        if calls["n"] == 1:
            dr.error_message = "half-written"  # dirty state that must be rolled back
            raise RuntimeError("boom")
        return IngestResult(True, "")
    monkeypatch.setattr(poller_mod, "ingest_domain_run", ingest)
    p = _poller(ws, engine)
    before = datetime.now(timezone.utc)
    assert p.tick() == 2  # first row raised and was counted; second row still processed
    b, o = _get(engine, bad), _get(engine, ok)
    assert b.status not in ("completed", "results_invalid", "failed", "cancelled") and b.error_message == ""
    assert b.ingest_attempts == 1 and b.last_message == "RuntimeError: boom"
    waited = b.ingest_next_at.replace(tzinfo=timezone.utc) - before
    assert timedelta(seconds=55) < waited < timedelta(seconds=65)
    assert o.status == "completed" and o.ingest_attempts == 0
    assert p.tick() == 0 and calls["n"] == 2  # inside the window: the run isn't polled or ingested
    _open_window(engine, bad)
    assert p.tick() == 1
    b = _get(engine, bad)
    assert b.status == "completed" and b.ingest_next_at is None and b.ended_at is not None


def test_ingest_window_backs_off_then_ends_results_invalid(client, engine, monkeypatch):
    dr_id = seed_domain_run(engine, databricks_run_id=1000)
    with Session(engine) as s:
        dr = s.get(AssessDomainRun, dr_id)
        dr.job_id, dr.job_reader = 99, "reader-1"
        s.add(dr); s.commit()
        batch_id = dr.batch_id
    ws = _progress_ws()
    ws.jobs.get_run.return_value = run("TERMINATED", "SUCCESS")

    def ingest(session, w, dr):
        raise DatabricksError("Volume temporarily unavailable: /Volumes/c/_metamodel/assess_runs/b/d/summary.json")
    monkeypatch.setattr(poller_mod, "ingest_domain_run", ingest)
    p = _poller(ws, engine)
    waits = []
    for attempt in range(1, 5):
        before = datetime.now(timezone.utc)
        p.tick()
        dr = _get(engine, dr_id)
        assert dr.ingest_attempts == attempt and dr.status == "assessing" and dr.ended_at is None
        waits.append(round((dr.ingest_next_at.replace(tzinfo=timezone.utc) - before).total_seconds() / 60))
        _open_window(engine, dr_id)
    assert waits == [1, 5, 15, 60]
    p.tick()
    dr = _get(engine, dr_id)
    assert dr.status == "results_invalid" and dr.results_valid is False and dr.ended_at is not None
    assert dr.ingest_attempts == 5 and dr.ingest_next_at is None
    assert dr.error_message.startswith("Ingest failed 5 times: DatabricksError: Volume temporarily unavailable")
    assert "/Volumes/" not in dr.error_message  # sanitized
    assert p.tick() == 0  # terminal: never polled again
    out = client.get(f"/api/assessments/{batch_id}").json()["domain_runs"][0]
    assert out["status"] == "results_invalid" and out["error_message"] == dr.error_message
    assert out["job_url"].endswith("/jobs/99") and out["run_url"].endswith("/jobs/99/runs/1000")
    assert out["job_reader"] == "reader-1" and out["runs_path"] == "/Volumes/c/_metamodel/assess_runs/b/d"
    assert (out["ingest_attempts"], out["ingest_max_attempts"], out["ingest_next_at"]) == (5, 5, None)


def test_retry_state_is_on_the_run_out_in_utc(client, engine, monkeypatch):
    dr_id = seed_domain_run(engine, databricks_run_id=1)
    ws = _progress_ws()
    ws.jobs.get_run.return_value = run("TERMINATED", "SUCCESS")

    def ingest(session, w, dr):
        raise DatabricksError("busy")
    monkeypatch.setattr(poller_mod, "ingest_domain_run", ingest)
    _poller(ws, engine).tick()
    batch_id = _get(engine, dr_id).batch_id
    out = client.get(f"/api/assessments/{batch_id}").json()["domain_runs"][0]
    assert (out["status"], out["last_message"], out["error_message"]) == ("assessing", "DatabricksError: busy", "")
    assert (out["ingest_attempts"], out["ingest_max_attempts"]) == (1, 5)
    next_at = datetime.fromisoformat(out["ingest_next_at"])
    assert next_at.utcoffset() == timedelta(0)
    assert timedelta(seconds=50) < next_at - datetime.now(timezone.utc) < timedelta(seconds=65)


def test_ingest_failure_leaves_a_run_that_turned_terminal_alone(engine):
    dr_id = seed_domain_run(engine, databricks_run_id=1, status="cancelled")
    p = _poller(_progress_ws(), engine)
    with Session(engine) as s:
        p._ingest_failed(s, dr_id, RuntimeError("boom"), datetime.now(timezone.utc))
    dr = _get(engine, dr_id)
    assert (dr.status, dr.ingest_attempts, dr.ingest_next_at, dr.last_message) == ("cancelled", 0, None, "")


def test_ingest_failure_skips_a_run_cancelled_between_the_read_and_the_update(engine, monkeypatch):
    """The fresh read sees a live run; a cancel commits from another session before the UPDATE runs.
    The SQL status guard keeps the cancel: no attempt counted, no retry window, still cancelled."""
    dr_id = seed_domain_run(engine, databricks_run_id=1, status="assessing")
    p = _poller(_progress_ws(), engine)
    real_get = Session.get

    def get_then_cancel(self, model, ident, *a, **k):
        obj = real_get(self, model, ident, *a, **k)
        if model is AssessDomainRun and ident == dr_id:
            with Session(engine) as other:
                row = real_get(other, AssessDomainRun, dr_id)
                row.status = "cancelled"
                other.add(row); other.commit()
        return obj
    monkeypatch.setattr(Session, "get", get_then_cancel)
    with Session(engine) as s:
        p._ingest_failed(s, dr_id, RuntimeError("boom"), datetime.now(timezone.utc))
    monkeypatch.undo()
    dr = _get(engine, dr_id)
    assert (dr.status, dr.ingest_attempts, dr.ingest_next_at, dr.last_message) == ("cancelled", 0, None, "")


def test_ingest_failure_count_is_guarded_against_a_concurrent_poller(engine, monkeypatch):
    """Another poller counted this failure between our read and our update: ours changes nothing."""
    dr_id = seed_domain_run(engine, databricks_run_id=1, status="assessing")
    p = _poller(_progress_ws(), engine)
    real_get = Session.get

    def get_then_race(self, model, ident, *a, **k):
        obj = real_get(self, model, ident, *a, **k)
        if model is AssessDomainRun and ident == dr_id:
            with Session(engine) as other:
                row = real_get(other, AssessDomainRun, dr_id)
                row.ingest_attempts, row.last_message = 1, "counted by the other poller"
                other.add(row); other.commit()
        return obj
    monkeypatch.setattr(Session, "get", get_then_race)
    with Session(engine) as s:
        p._ingest_failed(s, dr_id, RuntimeError("boom"), datetime.now(timezone.utc))
    monkeypatch.undo()
    dr = _get(engine, dr_id)
    assert (dr.ingest_attempts, dr.last_message, dr.ingest_next_at) == (1, "counted by the other poller", None)


def test_ingest_refusal_is_final_at_once(engine, monkeypatch):
    dr_id = seed_domain_run(engine, databricks_run_id=1)
    ws = _progress_ws()
    ws.jobs.get_run.return_value = run("TERMINATED", "SUCCESS")
    monkeypatch.setattr(poller_mod, "ingest_domain_run",
                        lambda s, w, dr: IngestResult(False, "Results refused: summary.json schema_version is 7"))
    _poller(ws, engine).tick()
    dr = _get(engine, dr_id)
    assert dr.status == "results_invalid" and dr.ingest_attempts == 0
    assert dr.error_message == "Results refused: summary.json schema_version is 7"


def test_run_forever_swallows_tick_errors_and_cancels_cleanly(engine, monkeypatch):
    monkeypatch.setattr(poller_mod, "POLL_INTERVAL_S", 0.01)
    p = _poller(MagicMock(), engine)
    calls = {"n": 0}

    def tick():
        calls["n"] += 1
        raise RuntimeError("tick boom")
    p.tick = tick

    async def main():
        t = asyncio.create_task(p.run_forever())
        while calls["n"] < 3:
            await asyncio.sleep(0.01)
        t.cancel()
        with pytest.raises(asyncio.CancelledError):
            await t
    asyncio.run(main())
    assert calls["n"] >= 3


def test_lifespan_starts_and_stops_poller(engine, monkeypatch):
    from fastapi import FastAPI

    from vibe_modeling.backend.core._assess_poller import _AssessPollerDependency
    from vibe_modeling.backend.core._config import AppConfig
    monkeypatch.setattr(poller_mod, "POLL_INTERVAL_S", 0.01)
    app = FastAPI()
    app.state.engine, app.state.workspace_client = engine, MagicMock()
    app.state.config = AppConfig(assessment_enabled=True)
    started = {"n": 0}
    real_run = poller_mod.AssessPoller.run_forever

    async def counting(self):
        started["n"] += 1
        await real_run(self)

    monkeypatch.setattr(poller_mod.AssessPoller, "run_forever", counting)

    async def main():
        async with _AssessPollerDependency().lifespan(app):
            await asyncio.sleep(0.05)
    asyncio.run(main())  # clean shutdown: no exception
    assert started["n"] == 1


def test_lifespan_does_not_start_the_poller_when_not_installed(monkeypatch):
    from fastapi import FastAPI

    from vibe_modeling.backend.core._assess_poller import _AssessPollerDependency
    from vibe_modeling.backend.core._config import AppConfig
    app = FastAPI()
    app.state.config = AppConfig(assessment_enabled=False)
    monkeypatch.setattr(poller_mod, "AssessPoller", MagicMock(side_effect=AssertionError("must not start")))

    async def main():
        async with _AssessPollerDependency().lifespan(app):
            pass
    asyncio.run(main())


def test_lifespan_survives_startup_failure():
    from fastapi import FastAPI

    from vibe_modeling.backend.core._assess_poller import _AssessPollerDependency
    from vibe_modeling.backend.core._config import AppConfig
    app = FastAPI()  # no engine/workspace_client on state -> start fails
    app.state.config = AppConfig(assessment_enabled=True)

    async def main():
        async with _AssessPollerDependency().lifespan(app):
            pass
    asyncio.run(main())


# --- routes ---
@pytest.fixture
def seeded_batch(engine):
    with Session(engine) as s:
        b = Business(name="B", description="d")
        s.add(b); s.commit(); s.refresh(b)
        mv = ModelVersion(business_id=b.id, version=1, scope="mvm", status="completed")
        s.add(mv); s.commit(); s.refresh(mv)
        d1 = Domain(version_id=mv.id, name="d1", database_name="d1")
        d2 = Domain(version_id=mv.id, name="d2", database_name="d2")
        batch = AssessBatch(business_id=b.id, version_id=mv.id)
        s.add(d1); s.add(d2); s.add(batch); s.add(AssessConfig(job_id=99))
        s.commit(); s.refresh(d1); s.refresh(d2); s.refresh(batch)
        ids = (b.id, batch.id, d1.id, d2.id)
    dr1 = seed_domain_run(engine, 1000, "assessing", batch_id=ids[1], domain_id=ids[2])
    dr2 = seed_domain_run(engine, 1001, "queued", batch_id=ids[1], domain_id=ids[3])
    return NS(bid=ids[0], batch_id=ids[1], dr1=dr1, dr2=dr2)


def test_cancel_domain_and_batch(client, mock_ws, engine, seeded_batch):
    r = client.post(f"/api/assessment-domain-runs/{seeded_batch.dr1}/cancel")
    assert r.status_code == 200 and mock_ws.jobs.cancel_run.call_args.kwargs == {"run_id": 1000}
    assert r.json()["status"] == "cancelled" and r.json()["ended_at"] is not None
    r = client.post(f"/api/assessments/{seeded_batch.batch_id}/cancel")
    assert r.status_code == 200
    # dr1 already terminal -> not cancelled again; dr2 cancelled
    assert [c.kwargs for c in mock_ws.jobs.cancel_run.call_args_list] == [{"run_id": 1000}, {"run_id": 1001}]
    assert {d["status"] for d in r.json()["domain_runs"]} == {"cancelled"} and r.json()["status"] == "cancelled"


def test_cancel_terminal_row_is_noop(client, mock_ws, engine, seeded_batch):
    with Session(engine) as s:
        dr = s.get(AssessDomainRun, seeded_batch.dr1)
        dr.status = "completed"; s.add(dr); s.commit()
    r = client.post(f"/api/assessment-domain-runs/{seeded_batch.dr1}/cancel")
    assert r.status_code == 200 and r.json()["status"] == "completed"
    mock_ws.jobs.cancel_run.assert_not_called()


def test_cancel_row_without_run_id_just_marks_cancelled(client, mock_ws, engine, seeded_batch):
    with Session(engine) as s:
        dr = s.get(AssessDomainRun, seeded_batch.dr2)
        dr.databricks_run_id = None; s.add(dr); s.commit()
    r = client.post(f"/api/assessment-domain-runs/{seeded_batch.dr2}/cancel")
    assert r.status_code == 200 and r.json()["status"] == "cancelled"
    mock_ws.jobs.cancel_run.assert_not_called()


def test_a_run_saving_its_results_cant_be_cancelled_and_the_batch_skips_it(client, mock_ws, engine, seeded_batch):
    with Session(engine) as s:
        dr = s.get(AssessDomainRun, seeded_batch.dr1)
        dr.ingest_attempts, dr.ingest_next_at = 1, datetime.now(timezone.utc) + timedelta(minutes=1)
        s.add(dr); s.commit()
    r = client.post(f"/api/assessment-domain-runs/{seeded_batch.dr1}/cancel")
    assert r.status_code == 409
    assert r.json()["detail"] == {"message": "This domain's job has finished and its results are being saved; "
                                             "it can't be cancelled now."}
    mock_ws.jobs.cancel_run.assert_not_called()
    r = client.post(f"/api/assessments/{seeded_batch.batch_id}/cancel")
    assert r.status_code == 200
    assert [c.kwargs for c in mock_ws.jobs.cancel_run.call_args_list] == [{"run_id": 1001}]
    statuses = {d["id"]: d["status"] for d in r.json()["domain_runs"]}
    assert statuses == {seeded_batch.dr1: "assessing", seeded_batch.dr2: "cancelled"}


def test_cancel_unknown_ids_404(client):
    assert client.post("/api/assessment-domain-runs/nope/cancel").status_code == 404
    assert client.post("/api/assessments/nope/cancel").status_code == 404


def test_cancel_databricks_error_leaves_row_unchanged(client, mock_ws, engine, seeded_batch):
    mock_ws.jobs.cancel_run.side_effect = DatabricksError("nope")
    r = client.post(f"/api/assessment-domain-runs/{seeded_batch.dr1}/cancel")
    assert r.status_code == 409 and r.json()["detail"]["error"] == "admin_help"
    assert _get(engine, seeded_batch.dr1).status == "assessing"


def test_list_and_get(client, seeded_batch):
    lst = client.get(f"/api/businesses/{seeded_batch.bid}/assessments").json()
    assert lst[0]["id"] == seeded_batch.batch_id and lst[0]["status"] == "running"
    one = client.get(f"/api/assessments/{seeded_batch.batch_id}").json()
    assert len(one["domain_runs"]) == 2 and one["domain_runs"][0]["run_url"].startswith("https://test-workspace")


def test_list_get_404s_and_newest_first(client, engine, seeded_batch):
    assert client.get("/api/businesses/nope/assessments").status_code == 404
    assert client.get("/api/assessments/nope").status_code == 404
    with Session(engine) as s:
        old = s.get(AssessBatch, seeded_batch.batch_id)
        old.created_at = datetime(2020, 1, 1, tzinfo=timezone.utc); s.add(old)
        new = AssessBatch(business_id=old.business_id, version_id=old.version_id)
        s.add(new); s.commit(); s.refresh(new)
        new_id = new.id
    ids = [b["id"] for b in client.get(f"/api/businesses/{seeded_batch.bid}/assessments").json()]
    assert ids == [new_id, seeded_batch.batch_id]
