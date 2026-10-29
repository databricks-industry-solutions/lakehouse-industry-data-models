"""Test the Delta table SQL methods on ProgressTracker (formerly delta_poller.py).

These tests verify SQL execution, session status parsing, progress event parsing,
and the handshake acknowledge SQL generation.
"""

import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "..", "src", "app", "src"))

import pytest
from contextlib import contextmanager
from unittest.mock import MagicMock, patch

from sqlalchemy.pool import StaticPool
from sqlmodel import Session, SQLModel, create_engine

from vibe_modeling.backend.core._config import AppConfig
from vibe_modeling.backend.progress_tracker import ProgressTracker, SessionStatus, ProgressEvent

from _sql_fakes import response


@pytest.fixture
def engine():
    engine = create_engine(
        "sqlite://",
        connect_args={"check_same_thread": False},
        poolclass=StaticPool,
    )
    SQLModel.metadata.create_all(engine)
    return engine


@pytest.fixture
def session_factory(engine):
    @contextmanager
    def _factory():
        with Session(engine) as session:
            yield session
    return _factory


@pytest.fixture
def mock_ws():
    return MagicMock()


@pytest.fixture
def tracker(mock_ws, session_factory):
    config = AppConfig(app_name="test", warehouse_id="test-warehouse-id", poll_interval_seconds=0)
    return ProgressTracker(ws=mock_ws, config=config, session_factory=session_factory)


class TestPollSessionStatus:
    def test_returns_none_when_table_missing(self, tracker, mock_ws):
        """TABLE_OR_VIEW_NOT_FOUND error returns None."""
        mock_ws.statement_execution.execute_statement.side_effect = RuntimeError(
            "TABLE_OR_VIEW_NOT_FOUND: Table `cat`._metamodel._business not found"
        )
        result = tracker._poll_session_status("cat", "test_biz", "v1", "MVM")
        assert result is None

    def test_returns_none_when_empty(self, tracker, mock_ws):
        """Empty result set returns None."""
        mock_ws.statement_execution.execute_statement.return_value = response([])

        result = tracker._poll_session_status("cat", "test_biz", "v1", "MVM")
        assert result is None

    def test_parses_row(self, tracker, mock_ws):
        """Successful result returns a SessionStatus."""
        row = ["12345", "running", "50.0", "2024-01-01T00:00:00", None, None, "test_biz", "v1", "MVM"]
        mock_ws.statement_execution.execute_statement.return_value = response([row])

        status = tracker._poll_session_status("cat", "test_biz", "v1", "MVM")
        assert status is not None
        assert isinstance(status, SessionStatus)
        assert status.session_id == 12345
        assert status.processing_status == "running"
        assert status.completed_percent == 50.0
        assert status.business == "test_biz"

    def test_parses_results_json(self, tracker, mock_ws):
        """Results JSON is parsed when present."""
        row = ["1", "done", "100.0", None, '{"model_path": "/path/to/model"}', "2024-01-01", "biz", "v1", "MVM"]
        mock_ws.statement_execution.execute_statement.return_value = response([row])

        status = tracker._poll_session_status("cat", "biz", "v1", "MVM")
        assert status.results_json == {"model_path": "/path/to/model"}


class TestPollProgressEvents:
    def test_empty_result(self, tracker, mock_ws):
        """Empty result returns empty list."""
        mock_ws.statement_execution.execute_statement.return_value = response([])

        events = tracker._poll_progress_events("cat", 12345, 0)
        assert events == []

    def test_parses_rows(self, tracker, mock_ws):
        """Multiple rows are parsed into ProgressEvent objects."""
        rows = [
            ["1", "0", "Phase 1", "Generate Schema", "completed", "Schema generated", "25.0", None],
            ["2", "1", "Phase 1", "Validate Schema", "running", "Validating...", "10.0", '{"valid": true}'],
        ]
        mock_ws.statement_execution.execute_statement.return_value = response(rows)

        events = tracker._poll_progress_events("cat", 12345, 0)
        assert len(events) == 2

        assert isinstance(events[0], ProgressEvent)
        assert events[0].step_id == 1
        assert events[0].stage_name == "Phase 1"
        assert events[0].step_name == "Generate Schema"
        assert events[0].progress_increment == 25.0

        assert events[1].step_id == 2
        assert events[1].result_json == {"valid": True}

    def test_table_not_found_returns_empty(self, tracker, mock_ws):
        """TABLE_OR_VIEW_NOT_FOUND returns empty list."""
        mock_ws.statement_execution.execute_statement.side_effect = RuntimeError(
            "TABLE_OR_VIEW_NOT_FOUND"
        )
        events = tracker._poll_progress_events("cat", 12345, 0)
        assert events == []


class TestAcknowledgeBatch:
    def test_sends_update_sql(self, tracker, mock_ws):
        """acknowledge_batch executes an UPDATE SQL statement."""
        mock_ws.statement_execution.execute_statement.return_value = response()

        tracker._acknowledge_batch("my_catalog", 12345)

        mock_ws.statement_execution.execute_statement.assert_called_once()
        call_kwargs = mock_ws.statement_execution.execute_statement.call_args.kwargs
        sql = call_kwargs["statement"]
        assert "UPDATE" in sql
        assert "processing_status = 'done'" in sql
        assert "12345" in sql

    def test_includes_identity_columns(self, tracker, mock_ws):
        """When business_name, version, model_scope are provided, WHERE includes all."""
        mock_ws.statement_execution.execute_statement.return_value = response()

        tracker._acknowledge_batch(
            "my_catalog", 12345,
            business_name="test_biz",
            version="v1",
            model_scope="Minimum Viable Model - MVM",
        )

        call_kwargs = mock_ws.statement_execution.execute_statement.call_args.kwargs
        sql = call_kwargs["statement"]
        assert "session_id = 12345" in sql
        assert "LOWER(business) = LOWER('test_biz')" in sql
        assert "version = 'v1'" in sql
        assert "model_scope = 'Minimum Viable Model - MVM'" in sql

    def test_session_id_only_without_identity(self, tracker, mock_ws):
        """When identity columns are not provided, WHERE only has session_id."""
        mock_ws.statement_execution.execute_statement.return_value = response()

        tracker._acknowledge_batch("my_catalog", 99999)

        call_kwargs = mock_ws.statement_execution.execute_statement.call_args.kwargs
        sql = call_kwargs["statement"]
        assert "session_id = 99999" in sql
        assert "business" not in sql.split("WHERE")[1].lower().replace("session_id", "")
