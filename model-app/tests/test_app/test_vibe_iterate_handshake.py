"""Regression tests for the vibe-iterate ↔ agent handshake.

Both bugs were observed on a test workspace during the (version, scope) PR's e2e:

  1. ``_fetch_model_json`` raced ahead of the Volume FUSE write — Jobs
     API reported SUCCESS before the freshly-written ``model.json`` was
     visible through ``ws.files.download``. We now retry with bounded
     backoff before giving up.

  2. ``_sync_orch_progress_events`` early-returned when the agent had
     not yet written its ``_business`` session-status row, even though
     the agent had already written events to ``_vibe_progress``. We now
     drain events FIRST, then read the status row for percent/message
     updates.
"""

from __future__ import annotations

import json
from unittest.mock import MagicMock

import pytest
from sqlmodel import Session, SQLModel, create_engine, select

from vibe_modeling.backend.services.operations.vibe_iterate import VibeIterate
from vibe_modeling.backend.services.operations._protocol import OperationContext


def _make_handle_and_ctx(business_id: str = "biz-1"):
    handle = MagicMock()
    handle.extra = {
        "deployment_catalog": "cat",
        "business_name": "acme",
        "parent_version_int": 1,
    }
    handle.databricks_run_id = 12345
    ctx = OperationContext(
        run_id="run-1",
        operation_id="op-1",
        business_id=business_id,
        parent_version_id=None,
        params={},
        inherited_params={},
    )
    return handle, ctx


def _empty_session() -> Session:
    """A real in-memory session: the fetch computes the expected version
    from ModelVersion / RunProgressEvent rows, which a MagicMock can't."""
    from vibe_modeling.backend import db_models  # noqa: F401

    eng = create_engine("sqlite:///:memory:")
    SQLModel.metadata.create_all(eng)
    return Session(bind=eng)


def _make_resp(payload: dict) -> MagicMock:
    resp = MagicMock()
    resp.contents.read.return_value = json.dumps(payload).encode("utf-8")
    return resp


def test_fetch_model_json_retries_on_transient_404(monkeypatch):
    """First two passes through the candidate list fail (Volume FUSE
    eventual consistency after the agent's notebook reports SUCCESS),
    a later pass succeeds — we must NOT raise."""
    monkeypatch.setattr(
        "vibe_modeling.backend.services.operations.vibe_iterate.time.sleep",
        lambda *_a, **_kw: None,
    )
    handle, ctx = _make_handle_and_ctx()
    ws = MagicMock()
    payload = {"type": "business", "name": "acme", "domains": []}
    # Two candidates per attempt, two attempts fail (4 calls), then succeed.
    ws.files.download.side_effect = [
        Exception("404 Not Found"),
        Exception("404 Not Found"),
        Exception("404 Not Found"),
        Exception("404 Not Found"),
        _make_resp(payload),
    ]
    with _empty_session() as session:
        result, info = VibeIterate()._fetch_model_json(handle, ctx, ws, session)
    assert result == payload
    assert ws.files.download.call_count == 5
    # No versions exist yet, so the expected output is v1 and it was found.
    assert info["expected_version"] == 1
    assert info["fetched_version"] == 1
    assert info["version_mismatch"] is False


def test_fetch_model_json_eventually_raises_after_all_retries(monkeypatch):
    """If the file never becomes visible, raise so the run gets marked
    failed — the retry MUST NOT block forever."""
    monkeypatch.setattr(
        "vibe_modeling.backend.services.operations.vibe_iterate.time.sleep",
        lambda *_a, **_kw: None,
    )
    handle, ctx = _make_handle_and_ctx()
    ws = MagicMock()
    ws.files.download.side_effect = Exception("404 Not Found")
    with _empty_session() as session:
        with pytest.raises(RuntimeError, match="model.json not fetched"):
            VibeIterate()._fetch_model_json(handle, ctx, ws, session)


def test_sync_orch_progress_drains_events_when_session_row_missing(monkeypatch):
    """Agent writes events to _vibe_progress before the _business
    session row appears. The drain MUST happen even when the session
    row is None — reading partial event sequences is safe because we
    cursor on step_id."""
    from vibe_modeling.backend.progress_tracker import ProgressTracker, ProgressEvent
    from vibe_modeling.backend.db_models import Run, RunOperation, RunProgressEvent
    # Side-effect import so SQLModel.metadata covers every table.
    from vibe_modeling.backend import db_models  # noqa: F401

    eng = create_engine("sqlite:///:memory:")
    SQLModel.metadata.create_all(eng)

    def session_factory():
        return Session(bind=eng)

    with session_factory() as setup_session:
        run = Run(
            business_id="biz-1",
            intent="vibe-iterate",
            status="running",
            parameters_json=json.dumps({"deployment_catalog": "cat"}),
            vibe_session_id="sid",
            vibe_session_id_bigint=999,
            last_consumed_step_id=0,
        )
        setup_session.add(run)
        setup_session.flush()
        # Post–Phase-5 ``_sync_orch_progress_events`` requires a running
        # RunOperation row to know which scope/session to drain into.
        setup_session.add(
            RunOperation(
                run_id=run.id,
                step_index=0,
                operation_name="vibe_iterate",
                params_json="{}",
                status="running",
            )
        )
        setup_session.commit()
        setup_session.refresh(run)
        run_id = run.id

    tracker = ProgressTracker(
        ws=MagicMock(), config=MagicMock(), session_factory=session_factory,
    )
    monkeypatch.setattr(
        tracker, "_poll_session_status_by_id", lambda *a, **k: None
    )
    events = [
        ProgressEvent(
            step_id=1, event_seq=1, stage_name="Vibe Session",
            step_name="Session Started", status="stage_in_progress",
            message="hi", progress_increment=0.0, result_json={},
        ),
        ProgressEvent(
            step_id=2, event_seq=2, stage_name="Domains",
            step_name="Generation", status="stage_in_progress",
            message="hi", progress_increment=10.0, result_json={},
        ),
    ]
    monkeypatch.setattr(
        tracker, "_poll_progress_events", lambda *a, **k: events
    )

    with session_factory() as session:
        tracker._sync_orch_progress_events(
            session.get(Run, run_id), session,
        )
        session.commit()

    with session_factory() as verify_session:
        rows = verify_session.exec(
            select(RunProgressEvent).where(RunProgressEvent.run_id == run_id)
        ).all()
        assert {r.step_id for r in rows} == {1, 2}, (
            "events were NOT drained when session row was missing — "
            "this is the regression we're guarding"
        )
        run = verify_session.get(Run, run_id)
        assert run.last_consumed_step_id == 2
