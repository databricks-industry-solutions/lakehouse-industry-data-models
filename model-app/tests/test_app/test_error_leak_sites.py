"""E-11 beyond the handler: a caught database or connection error is stored in
run and version columns and returned by routes, so the text must be cut where
it is built. Each test raises a real SQLAlchemy error (the SQLite driver's
text carries the statement and its bound parameters) or an OperationalError
that names a Lakebase host, and asserts the stored text, the API response and
the database row hold none of it while the log keeps the full error and the
reference the user sees.
"""
from __future__ import annotations

import json
import logging
import re
import uuid

import psycopg
import pytest
from sqlalchemy import create_engine
from sqlalchemy.exc import IntegrityError, OperationalError
from sqlmodel import Session, select

import test_sync_savepoint as sp
from _phase2_helpers import GENERATE_ECM_VALID_PARAMS, make_ctx, make_engine, make_ws, seed_business_and_agent, seed_run_with_op
from vibe_modeling.backend.core._tracker import _TrackerDependency
from vibe_modeling.backend.db_models import ModelVersion, Run, RunOperation
from vibe_modeling.backend.error_sanitization import (
    CONNECTION_ERROR_MESSAGE,
    DB_ERROR_MESSAGE,
    is_opaque_error,
    recorded_error_text,
)
from vibe_modeling.backend.model_sync import ModelSyncService

from .test_preflight_levels import BUSINESS, HOME, _nbm, _version, api, biz_id, fake  # noqa: F401 - fixtures

SECRET = "SECRET-" + uuid.uuid4().hex[:8]
HOST = "instance-1a2b3c4d.database.cloud.databricks.com"
LEAKS = ("INSERT", "[SQL", "[parameters", "UNIQUE constraint", SECRET, HOST)
REFERENCE = re.compile(r"Reference: ([0-9a-f-]{36})")


def real_integrity_error() -> IntegrityError:
    """A genuine driver error: its text holds the INSERT and the bound values."""
    eng = create_engine("sqlite://")
    with eng.connect() as conn:
        conn.exec_driver_sql("CREATE TABLE t (id TEXT PRIMARY KEY, name TEXT)")
        conn.exec_driver_sql("INSERT INTO t VALUES (?, ?)", ("a", SECRET))
        with pytest.raises(IntegrityError) as caught:
            conn.exec_driver_sql("INSERT INTO t VALUES (?, ?)", ("a", SECRET))
    return caught.value


def host_operational_error() -> OperationalError:
    return OperationalError(
        "SELECT 1", {"p": SECRET},
        psycopg.OperationalError(f'connection to server at "{HOST}" (10.0.0.7), port 5432 failed: Connection refused'),
    )


ERRORS = {"integrity": real_integrity_error, "operational": host_operational_error}


def assert_clean(text: str) -> None:
    for leaked in LEAKS:
        assert leaked not in text, f"{leaked!r} in {text[:300]!r}"


def assert_reference_logged(caplog, text: str) -> None:
    """The reference in ``text`` is on a log line that also carries the full error."""
    reference = REFERENCE.search(text)
    assert reference, text
    lines = [r for r in caplog.records if reference.group(1) in r.getMessage()]
    assert lines, "the reference is in no log line"
    assert any(SECRET in (str(r.exc_info[1]) if r.exc_info else "") or HOST in (str(r.exc_info[1]) if r.exc_info else "")
               for r in lines), "the log line does not carry the full error"


def test_the_fake_errors_can_leak():
    """Guard: if the fakes stopped carrying SQL and values the tests below would pass for nothing."""
    assert "INSERT" in str(real_integrity_error()) and SECRET in str(real_integrity_error())
    assert HOST in str(host_operational_error())


class TestRecordedErrorText:
    @pytest.mark.parametrize("kind", ["integrity", "operational"])
    def test_database_error_is_fixed_text_with_a_logged_reference(self, kind, caplog):
        with caplog.at_level(logging.ERROR):
            text = recorded_error_text(ERRORS[kind](), "Some step", fallback="the old text")
        assert text.startswith(DB_ERROR_MESSAGE)
        assert_clean(text)
        assert_reference_logged(caplog, text)

    def test_connection_error_is_fixed_text(self):
        import requests

        text = recorded_error_text(requests.ConnectionError(f"host='{HOST}'"), "Some step")
        assert text.startswith(CONNECTION_ERROR_MESSAGE) and HOST not in text

    def test_other_errors_keep_their_text(self):
        assert recorded_error_text(ValueError("bad"), "Some step", fallback="the old text") == "the old text"
        assert recorded_error_text(ValueError("see /Workspace/Users/a@b.com/x"), "Some step") == "see [REDACTED]"
        assert not is_opaque_error(ValueError("bad"))


@pytest.mark.parametrize("kind", ["integrity", "operational"])
@pytest.mark.parametrize("intent", ["new-base-model", "vibe-new-ecm-mvm"])
def test_create_run_start_failure_stores_no_driver_text(api, engine, biz_id, fake, intent, kind, caplog):
    """POST /runs answers 200 failed; the stored error_message is what
    GET /runs/{id} shows, so it must be clean in the response, the row and the operation rows."""
    tracker = api.app.dependency_overrides[_TrackerDependency.__call__]()
    exc = ERRORS[kind]()

    def boom(*a, **k):
        raise exc

    tracker.orchestrator.start = boom
    if intent == "new-base-model":
        body = _nbm()
    else:
        # The pre-flight's parent check counts the parent's registry rows (the fake answers it).
        fake.add_agent_version(HOME, BUSINESS, 1, "ecm", {"domains": []}, write_model_json=False)
        body = {"intent": intent, "parent_version_id": _version(engine, biz_id), "catalog": HOME,
                "cataloging_style": "One Catalog", "vibe_instructions": "Add a customer domain."}
    with caplog.at_level(logging.ERROR):
        created = api.post(f"/api/businesses/{biz_id}/runs", json=body)
    assert created.status_code == 200, created.text
    assert created.json()["status"] == "failed"
    fetched = api.get(f"/api/businesses/{biz_id}/runs/{created.json()['id']}")
    assert fetched.status_code == 200, fetched.text
    for text in (created.text, fetched.text):
        assert_clean(text)
        assert REFERENCE.search(text)
    with Session(engine) as s:
        row = s.get(Run, created.json()["id"])
        assert_clean(row.error_message or "")
        for op in s.exec(select(RunOperation).where(RunOperation.run_id == row.id)):
            assert_clean(json.dumps(op.model_dump(mode="json"), default=str))
    assert_reference_logged(caplog, created.text)


def _failed_run(engine, biz_id, *, with_operation: bool) -> str:
    with Session(engine) as s:
        run = Run(business_id=biz_id, intent="install", status="failed")
        s.add(run)
        s.flush()
        if with_operation:
            s.add(RunOperation(run_id=run.id, step_index=0, operation_name="install", status="failed"))
        s.commit()
        return run.id


@pytest.mark.parametrize("kind", ["integrity", "operational"])
def test_retry_failure_response_has_no_driver_text(api, engine, biz_id, fake, kind, caplog):
    tracker = api.app.dependency_overrides[_TrackerDependency.__call__]()
    run_id = _failed_run(engine, biz_id, with_operation=True)
    exc = ERRORS[kind]()

    def boom(*a, **k):
        raise exc

    tracker.orchestrator.resume = boom
    with caplog.at_level(logging.ERROR):
        r = api.post(f"/api/businesses/{biz_id}/runs/{run_id}/retry")
    assert r.status_code == 500
    assert r.json()["detail"].startswith("Failed to retry: " + DB_ERROR_MESSAGE)
    assert_clean(r.text)
    assert_reference_logged(caplog, r.text)


def test_retry_of_a_launch_run_run_has_no_driver_text(api, engine, biz_id, fake, monkeypatch, caplog):
    """The retry of a run without operation rows relaunches the stored job map."""
    import vibe_modeling.backend.router as router

    run_id = _failed_run(engine, biz_id, with_operation=False)
    with Session(engine) as s:
        run = s.get(Run, run_id)
        run.intent = "new-base-model"
        run.parameters_json = json.dumps({"deployment_catalog": HOME, "data_model_scopes": "ecm"})
        s.add(run)
        s.commit()
    exc = real_integrity_error()

    def boom(*a, **k):
        raise exc

    monkeypatch.setattr(router, "launch_run", boom)
    with caplog.at_level(logging.ERROR):
        r = api.post(f"/api/businesses/{biz_id}/runs/{run_id}/retry")
    assert r.status_code == 500, r.text
    assert r.json()["detail"].startswith("Failed to retry: " + DB_ERROR_MESSAGE)
    assert_clean(r.text)
    assert_reference_logged(caplog, r.text)


class TestStoredSyncErrorText:
    """``ModelVersionOut.sync_error_text`` and the op's progress message."""

    @pytest.mark.parametrize("kind", ["integrity", "operational"])
    def test_generation_op(self, kind, caplog):
        eng = make_engine()
        ws = make_ws(lifecycle="TERMINATED", result_state="SUCCESS", download_payload=sp._ENVELOPE_BYTES)
        with Session(eng) as session:
            biz_id, _ = seed_business_and_agent(session)
            run_id, op_id = seed_run_with_op(
                session, business_id=biz_id, operation_name="generate_ecm", databricks_run_id=777)
            exc = ERRORS[kind]()
            from unittest.mock import patch
            with caplog.at_level(logging.ERROR), patch.object(ModelSyncService, "sync_model", side_effect=exc):
                obs = sp.TestGenerateOpSavepoint()._run(session, ws, biz_id, run_id, op_id)
            mv = session.get(ModelVersion, obs.terminal_result.output_version_id)
            assert mv.sync_state == "incomplete_metadata"
            for text in (mv.sync_error_text, obs.progress_message, json.dumps(obs.terminal_result.rollback_state, default=str)):
                assert_clean(text)
            assert REFERENCE.search(mv.sync_error_text)
            assert_reference_logged(caplog, mv.sync_error_text)

    @pytest.mark.parametrize("kind", ["integrity", "operational"])
    def test_vibe_iterate(self, kind, caplog):
        from unittest.mock import patch

        eng = make_engine()
        with Session(eng) as session:
            biz_id, _ = seed_business_and_agent(session)
            parent = session.get(ModelVersion, sp._seed_prior_version(session, biz_id, scope="mvm", version=1))
            exc = ERRORS[kind]()
            with caplog.at_level(logging.ERROR), patch.object(ModelSyncService, "sync_model", side_effect=exc):
                result = sp.TestVibeIterateSavepoint()._finalize(session, make_ws(), biz_id, parent)
            mv = session.get(ModelVersion, result.output_version_id)
            assert mv.sync_state == "incomplete_metadata"
            assert_clean(mv.sync_error_text)
            assert_reference_logged(caplog, mv.sync_error_text)

    def test_other_sync_errors_keep_their_text(self):
        from unittest.mock import patch

        eng = make_engine()
        ws = make_ws(lifecycle="TERMINATED", result_state="SUCCESS", download_payload=sp._ENVELOPE_BYTES)
        with Session(eng) as session:
            biz_id, _ = seed_business_and_agent(session)
            run_id, op_id = seed_run_with_op(
                session, business_id=biz_id, operation_name="generate_ecm", databricks_run_id=777)
            with patch.object(ModelSyncService, "sync_model", side_effect=RuntimeError("post-sync sanity gate failed")):
                obs = sp.TestGenerateOpSavepoint()._run(session, ws, biz_id, run_id, op_id)
            mv = session.get(ModelVersion, obs.terminal_result.output_version_id)
            assert mv.sync_error_text == "post-sync sanity gate failed"
