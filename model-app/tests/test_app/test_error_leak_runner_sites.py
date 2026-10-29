"""E-11, the runner, poller and tracker sites: a real IntegrityError raised in
an operation's dispatch or observe, in the assessment ingest and in the
progress read leaves no SQL, parameter or driver detail in the stored run and
operation text or the assessment run text, while a non-database error keeps
its old text.
"""
from __future__ import annotations

import logging
import re
import uuid
from datetime import datetime, timezone
from unittest.mock import MagicMock

import pytest
from sqlalchemy import create_engine
from sqlalchemy.exc import IntegrityError
from sqlmodel import Session, select

from _lifecycle_fixtures import require_files_catalog  # noqa: F401
from test_assess_admin_help import seed_domain_run
from test_orchestrator_runner import (  # noqa: F401 - fixtures and builders
    Dag,
    FakePrimitive,
    OperationStep,
    Orchestrator,
    _drive_to_terminal,
    _make_run,
    business,
    engine,
    mock_ws,
    patched_registry,
    patched_registry_full,
    session,
    session_factory,
)
from vibe_modeling.backend.db_models import AssessDomainRun, RunOperation
from vibe_modeling.backend.error_sanitization import DB_ERROR_MESSAGE

SECRET = "SECRET-" + uuid.uuid4().hex[:8]
LEAKS = ("INSERT", "[SQL", "[parameters", "UNIQUE constraint", "IntegrityError", SECRET)
REFERENCE = re.compile(r"Reference: ([0-9a-f-]{36})")


def real_integrity_error() -> IntegrityError:
    eng = create_engine("sqlite://")
    with eng.connect() as conn:
        conn.exec_driver_sql("CREATE TABLE t (id TEXT PRIMARY KEY, name TEXT)")
        conn.exec_driver_sql("INSERT INTO t VALUES (?, ?)", ("a", SECRET))
        with pytest.raises(IntegrityError) as caught:
            conn.exec_driver_sql("INSERT INTO t VALUES (?, ?)", ("a", SECRET))
    return caught.value


def assert_clean(*texts: str | None) -> None:
    for text in texts:
        for leaked in LEAKS:
            assert leaked not in (text or ""), f"{leaked!r} in {text!r}"


def _dag(*names: str) -> Dag:
    return Dag(intent="new-base-model", steps=tuple(OperationStep(name=n, params={}) for n in names))


def _raising(exc: Exception):
    def raise_it(*args, **kwargs):
        raise exc
    return raise_it


def test_the_error_can_leak():
    error = real_integrity_error()
    assert "INSERT" in str(error) and SECRET in str(error)
    assert "UNIQUE constraint" in repr(error)


@pytest.mark.parametrize("db_error", [True, False])
def test_dispatch_failure_text(engine, session, business, mock_ws, patched_registry_full, db_error, caplog):
    exc = real_integrity_error() if db_error else RuntimeError("plain dispatch failure")
    patched_registry_full["generate_ecm"] = FakePrimitive("generate_ecm", on_dispatch=_raising(exc))
    run = _make_run(session, business)
    orchestrator = Orchestrator()
    with caplog.at_level(logging.ERROR):
        orchestrator.start(run, _dag("generate_ecm"), session)
        _drive_to_terminal(orchestrator, run, session)
    session.refresh(run)
    operations = session.exec(select(RunOperation).where(RunOperation.run_id == run.id)).all()
    texts = [run.error_message, *(op.error_message for op in operations)]
    if db_error:
        assert_clean(*texts)
        assert run.error_message.startswith("dispatch error: " + DB_ERROR_MESSAGE)
        reference = REFERENCE.search(run.error_message).group(1)
        assert any(reference in r.getMessage() and SECRET in str(r.exc_info[1]) for r in caplog.records if r.exc_info)
    else:
        assert "RuntimeError('plain dispatch failure')" in run.error_message
        assert "Reference:" not in run.error_message


@pytest.mark.parametrize("db_error", [True, False])
def test_observe_failure_last_poll_error(engine, session, business, mock_ws, patched_registry_full, db_error):
    exc = real_integrity_error() if db_error else RuntimeError("plain observe failure")
    patched_registry_full["generate_ecm"] = FakePrimitive("generate_ecm", on_observe=_raising(exc))
    run = _make_run(session, business)
    orchestrator = Orchestrator()
    orchestrator.start(run, _dag("generate_ecm"), session)
    for _ in range(3):
        orchestrator.advance(run, session)
    session.refresh(run)
    if db_error:
        assert_clean(run.last_poll_error)
        assert run.last_poll_error.startswith(DB_ERROR_MESSAGE) and REFERENCE.search(run.last_poll_error)
    else:
        assert run.last_poll_error == "RuntimeError('plain observe failure')"


@pytest.mark.parametrize("db_error", [True, False])
def test_assessment_ingest_failure_text(engine, db_error):
    from vibe_modeling.backend.assessment.poller import INGEST_MAX_ATTEMPTS, AssessPoller

    dr_id = seed_domain_run(engine, databricks_run_id=1000, status="assessing")
    poller = AssessPoller(MagicMock(), lambda: Session(engine))
    now = datetime.now(timezone.utc)
    make = real_integrity_error if db_error else (lambda: ValueError("results file is not valid"))
    with Session(engine) as s:
        poller._ingest_failed(s, dr_id, make(), now)
    with Session(engine) as s:
        dr = s.get(AssessDomainRun, dr_id)
        first = dr.last_message
        dr.ingest_attempts = INGEST_MAX_ATTEMPTS - 1
        s.add(dr)
        s.commit()
    with Session(engine) as s:
        poller._ingest_failed(s, dr_id, make(), now)
    with Session(engine) as s:
        dr = s.get(AssessDomainRun, dr_id)
        final = dr.error_message
    if db_error:
        assert_clean(first, final)
        assert DB_ERROR_MESSAGE in first and REFERENCE.search(first)
        assert final.startswith(f"Ingest failed {INGEST_MAX_ATTEMPTS} times: " + DB_ERROR_MESSAGE)
    else:
        assert first == "ValueError: results file is not valid"
        assert final.endswith("ValueError: results file is not valid")


def test_progress_read_note(engine):
    from vibe_modeling.backend.db_models import Run
    from vibe_modeling.backend.progress_tracker import _poll_error_note

    run = Run(business_id="b", intent="install", status="running")
    note = _poll_error_note(real_integrity_error(), run)
    assert_clean(note)
    assert note.startswith("Could not read the agent's progress: " + DB_ERROR_MESSAGE) and REFERENCE.search(note)
    assert _poll_error_note(ValueError("odd value"), run) == "Could not read the agent's progress: odd value"
