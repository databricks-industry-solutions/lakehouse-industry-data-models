"""Tests for core/_sql.py: safe SQL construction and strict statement execution."""

import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "..", "src", "app", "src"))
sys.path.insert(0, os.path.dirname(__file__))

from unittest.mock import MagicMock

import pytest

from vibe_modeling.backend.core import _sql
from vibe_modeling.backend.core._sql import (
    SqlStatementError,
    execute,
    like_pattern,
    rows,
    run,
    safe_identifier,
    scalar,
)

from _sql_fakes import FakeClock, response, ws_returning  # noqa: E402


class TestSafeIdentifier:
    def test_accepts_plain_identifier(self):
        assert safe_identifier("my_catalog") == "`my_catalog`"

    def test_accepts_underscore_prefix(self):
        assert safe_identifier("_metamodel") == "`_metamodel`"

    def test_accepts_alphanumeric(self):
        assert safe_identifier("col1") == "`col1`"

    def test_rejects_dotted(self):
        with pytest.raises(ValueError, match="unsafe SQL identifier"):
            safe_identifier("catalog.schema")

    def test_rejects_semicolon(self):
        with pytest.raises(ValueError):
            safe_identifier("x;DROP TABLE y")

    def test_rejects_empty(self):
        with pytest.raises(ValueError):
            safe_identifier("")

    def test_rejects_none(self):
        with pytest.raises(ValueError):
            safe_identifier(None)  # type: ignore[arg-type]

    def test_rejects_leading_digit(self):
        with pytest.raises(ValueError):
            safe_identifier("1abc")

    def test_rejects_backtick(self):
        with pytest.raises(ValueError):
            safe_identifier("a`b")

    def test_rejects_space(self):
        with pytest.raises(ValueError):
            safe_identifier("my table")


class TestLikePattern:
    def test_escapes_percent(self):
        assert like_pattern("100% off") == r"100\% off"

    def test_escapes_underscore(self):
        assert like_pattern("a_b") == r"a\_b"

    def test_escapes_backslash(self):
        # Python literal "a\\b" is the 3-char string a, \, b.
        # Helper doubles the backslash, then leaves the b alone.
        assert like_pattern("a\\b") == "a\\\\b"

    def test_escapes_all_three(self):
        # "%_\\" -> escape backslash first, then % and _.
        assert like_pattern("%_\\") == "\\%\\_\\\\"

    def test_passes_through_plain_text(self):
        assert like_pattern("acme retail") == "acme retail"

    def test_empty_string(self):
        assert like_pattern("") == ""


class TestExecute:
    def _ws(self):
        ws = MagicMock()
        ws.statement_execution.execute_statement.return_value = response([])
        return ws

    def test_passes_sql_and_warehouse(self):
        ws = self._ws()
        execute(ws, "wh-123", "SELECT 1")
        ws.statement_execution.execute_statement.assert_called_once()
        kwargs = ws.statement_execution.execute_statement.call_args.kwargs
        assert kwargs["statement"] == "SELECT 1"
        assert kwargs["warehouse_id"] == "wh-123"
        assert kwargs["wait_timeout"] == "50s"
        assert kwargs["parameters"] is None

    def test_custom_wait_timeout(self):
        ws = self._ws()
        execute(ws, "wh-1", "SELECT 1", wait_timeout="10s")
        kwargs = ws.statement_execution.execute_statement.call_args.kwargs
        assert kwargs["wait_timeout"] == "10s"

    def test_named_parameters_become_sdk_items(self):
        from databricks.sdk.service.sql import StatementParameterListItem

        ws = self._ws()
        execute(
            ws,
            "wh-1",
            "SELECT * FROM t WHERE biz = :biz AND v = :v",
            params={"biz": "acme", "v": 3},
        )
        kwargs = ws.statement_execution.execute_statement.call_args.kwargs
        params = kwargs["parameters"]
        assert isinstance(params, list)
        assert len(params) == 2
        assert all(isinstance(p, StatementParameterListItem) for p in params)
        by_name = {p.name: p.value for p in params}
        assert by_name == {"biz": "acme", "v": "3"}  # int coerced to str

    def test_none_param_value_preserved(self):
        ws = self._ws()
        execute(ws, "wh-1", "SELECT :x", params={"x": None})
        kwargs = ws.statement_execution.execute_statement.call_args.kwargs
        assert kwargs["parameters"][0].value is None

    def test_returns_sdk_response(self):
        ws = self._ws()
        sentinel = ws.statement_execution.execute_statement.return_value
        result = execute(ws, "wh-1", "SELECT 1")
        assert result is sentinel

    def test_empty_params_mapping_yields_none(self):
        ws = self._ws()
        execute(ws, "wh-1", "SELECT 1", params={})
        kwargs = ws.statement_execution.execute_statement.call_args.kwargs
        # Empty mapping is falsy → no parameter list at all.
        assert kwargs["parameters"] is None


@pytest.fixture
def clock(monkeypatch):
    return FakeClock().install(monkeypatch)


class TestExecuteStrict:
    def test_failed_state_raises_with_message(self):
        ws = ws_returning(response(error="[PARSE_SYNTAX_ERROR] near SELEC"))
        with pytest.raises(SqlStatementError) as ei:
            execute(ws, "wh", "SELEC 1")
        assert ei.value.state == "FAILED"
        assert "PARSE_SYNTAX_ERROR" in ei.value.message
        assert ei.value.table_missing is False

    @pytest.mark.parametrize("state", ["CANCELED", "CLOSED", "FAILED"])
    def test_non_success_terminal_state_without_error_raises(self, state):
        ws = ws_returning(response(state=state))
        with pytest.raises(SqlStatementError) as ei:
            execute(ws, "wh", "SELECT 1")
        assert ei.value.state == state

    def test_response_without_state_raises_unknown(self):
        from databricks.sdk.service.sql import StatementResponse

        ws = ws_returning(StatementResponse(statement_id="s1"))
        with pytest.raises(SqlStatementError) as ei:
            execute(ws, "wh", "SELECT 1")
        assert ei.value.state == "UNKNOWN"

    def test_bare_mock_response_is_not_success(self):
        ws = MagicMock()
        ws.statement_execution.execute_statement.return_value = MagicMock()
        with pytest.raises(SqlStatementError):
            execute(ws, "wh", "SELECT 1")

    def test_sdk_exception_is_wrapped_and_chained(self):
        boom = ConnectionError("warehouse unreachable")
        ws = ws_returning(boom)
        with pytest.raises(SqlStatementError) as ei:
            execute(ws, "wh", "SELECT 1")
        assert ei.value.state == "ERROR"
        assert ei.value.__cause__ is boom

    def test_message_is_sanitized(self):
        ws = ws_returning(response(error="denied for someone@example.com on /Volumes/c/s/v/f"))
        with pytest.raises(SqlStatementError) as ei:
            execute(ws, "wh", "SELECT 1")
        assert "someone@example.com" not in str(ei.value)
        assert "/Volumes/c" not in str(ei.value)
        assert "[REDACTED]" in ei.value.message

    def test_table_missing_flag(self):
        ws = ws_returning(response(error="[TABLE_OR_VIEW_NOT_FOUND] The table `c`.`s`.`t` cannot be found"))
        with pytest.raises(SqlStatementError) as ei:
            execute(ws, "wh", "SELECT * FROM c.s.t")
        assert ei.value.table_missing is True


class TestExecuteTimeBound:
    """The bound is wall-clock time. get_statement blocks about 5 s per call on a
    real serverless warehouse; the fake charges that to the clock."""

    def test_polls_until_succeeded(self, clock):
        seq = iter([response(state="RUNNING", statement_id="s1"), response([["1"]], statement_id="s1")])
        ws = ws_returning(response(state="PENDING", statement_id="s1"),
                          clock=clock, poll_cost_s=5.2, polls=lambda sid: next(seq))
        resp = execute(ws, "wh", "SELECT 1", timeout_s=120, poll_interval_s=3)
        assert resp.result.data_array == [["1"]]
        assert ws.statement_execution.get_statement.call_count == 2
        assert clock.sleeps == [3, 3]
        ws.statement_execution.cancel_execution.assert_not_called()

    @pytest.mark.parametrize("budget", [20, 90, 600])
    def test_blocking_polls_stay_inside_the_bound_before_the_final_read(self, clock, budget):
        ws = ws_returning(response(state="PENDING", statement_id="s1"), clock=clock, poll_cost_s=5.3)
        with pytest.raises(SqlStatementError) as ei:
            execute(ws, "wh", "SELECT 1", timeout_s=budget, poll_interval_s=5, on_timeout="detach")
        assert ei.value.state == "STILL_RUNNING"
        assert clock.elapsed <= budget
        ws.statement_execution.cancel_execution.assert_not_called()

    def test_cancel_mode_overshoots_by_at_most_the_final_read(self, clock):
        ws = ws_returning(response(state="PENDING", statement_id="s1"), clock=clock, poll_cost_s=5.3)
        with pytest.raises(SqlStatementError) as ei:
            execute(ws, "wh", "SELECT 1", timeout_s=90, poll_interval_s=5)
        assert ei.value.state == "TIMEOUT"
        assert "cancelled" in ei.value.message
        assert clock.elapsed <= 90 + 5.3
        ws.statement_execution.cancel_execution.assert_called_once_with("s1")

    def test_server_wait_is_cut_to_the_time_bound(self, clock):
        ws = ws_returning(response(state="PENDING", statement_id="s1"), clock=clock, poll_cost_s=5)
        with pytest.raises(SqlStatementError):
            execute(ws, "wh", "SELECT 1", timeout_s=20, on_timeout="detach")
        assert ws.waits == ["20s"]

    def test_tiny_bound_submits_without_waiting(self, clock):
        ws = ws_returning(response(state="PENDING", statement_id="s1"), clock=clock)
        with pytest.raises(SqlStatementError) as ei:
            execute(ws, "wh", "SELECT 1", timeout_s=3, on_timeout="detach")
        assert ws.waits == ["0s"]
        assert ei.value.state == "STILL_RUNNING"
        ws.statement_execution.get_statement.assert_not_called()

    def test_no_time_bound_is_the_server_wait_only(self, clock):
        ws = ws_returning(response(state="RUNNING", statement_id="s1"), clock=clock)
        with pytest.raises(SqlStatementError) as ei:
            execute(ws, "wh", "INSERT INTO t VALUES (1)", wait_timeout="30s")
        assert ei.value.state == "TIMEOUT"
        assert ws.waits == ["30s"]
        assert clock.sleeps == []
        ws.statement_execution.cancel_execution.assert_called_once_with("s1")

    def test_finished_just_before_the_cancel_is_a_success(self, clock):
        """The state is read once more after the cancel; a statement that had
        finished is a success, not a TIMEOUT."""
        def polls(sid):
            if ws.statement_execution.cancel_execution.called:
                return response([["done"]], statement_id=sid)
            return response(state="RUNNING", statement_id=sid)

        ws = ws_returning(response(state="PENDING", statement_id="s1"),
                          clock=clock, poll_cost_s=5, polls=polls)
        resp = execute(ws, "wh", "SELECT 1", timeout_s=30, poll_interval_s=5)
        assert resp.result.data_array == [["done"]]
        ws.statement_execution.cancel_execution.assert_called_once_with("s1")

    def test_failed_just_before_the_cancel_is_that_failure(self, clock):
        def polls(sid):
            if ws.statement_execution.cancel_execution.called:
                return response(error="[DIVIDE_BY_ZERO] x", statement_id=sid)
            return response(state="RUNNING", statement_id=sid)

        ws = ws_returning(response(state="PENDING", statement_id="s1"), clock=clock, polls=polls)
        with pytest.raises(SqlStatementError) as ei:
            execute(ws, "wh", "SELECT 1", timeout_s=10, poll_interval_s=5)
        assert ei.value.state == "FAILED"
        assert "DIVIDE_BY_ZERO" in ei.value.message

    def test_timeout_without_statement_id_does_not_claim_a_cancel(self, clock):
        ws = ws_returning(response(state="PENDING", statement_id=None), clock=clock)
        with pytest.raises(SqlStatementError) as ei:
            execute(ws, "wh", "SELECT 1", timeout_s=60)
        assert ei.value.state == "TIMEOUT"
        assert "not cancelled" in ei.value.message
        ws.statement_execution.cancel_execution.assert_not_called()

    def test_detach_leaves_the_statement_running(self, clock):
        ws = ws_returning(response(state="PENDING", statement_id="s1"), clock=clock, poll_cost_s=1)
        with pytest.raises(SqlStatementError) as ei:
            run(ws, "wh", "INSERT INTO t VALUES (1)", timeout_s=60, on_timeout="detach")
        assert ei.value.state == "STILL_RUNNING"
        assert ei.value.statement_id == "s1"
        ws.statement_execution.cancel_execution.assert_not_called()

    def test_detach_still_raises_real_failures(self, clock):
        ws = ws_returning(response(state="PENDING", statement_id="s1"), clock=clock,
                          polls=lambda sid: response(error="boom", statement_id=sid))
        with pytest.raises(SqlStatementError) as ei:
            run(ws, "wh", "INSERT INTO t VALUES (1)", timeout_s=60, on_timeout="detach")
        assert ei.value.state == "FAILED"

    def test_cancel_failure_still_raises_timeout(self, clock):
        ws = ws_returning(response(state="PENDING", statement_id="s1"), clock=clock)
        ws.statement_execution.cancel_execution.side_effect = RuntimeError("cancel denied")
        with pytest.raises(SqlStatementError) as ei:
            execute(ws, "wh", "SELECT 1")
        assert ei.value.state == "TIMEOUT"

    @pytest.mark.parametrize("on_timeout", ["cancel", "detach"])
    def test_poll_error_cancels_and_keeps_the_statement_id(self, clock, on_timeout):
        boom = ConnectionError("reset by peer")

        def polls(sid):
            raise boom

        ws = ws_returning(response(state="PENDING", statement_id="s1"), clock=clock, polls=polls)
        with pytest.raises(SqlStatementError) as ei:
            execute(ws, "wh", "SELECT 1", timeout_s=60, on_timeout=on_timeout)
        assert ei.value.state == "ERROR"
        assert ei.value.statement_id == "s1"
        assert ei.value.__cause__ is boom
        ws.statement_execution.cancel_execution.assert_called_with("s1")


class TestRows:
    def test_returns_rows(self):
        ws = ws_returning(response([["a", "1"], ["b", "2"]]))
        assert rows(ws, "wh", "SELECT x, y FROM t") == [["a", "1"], ["b", "2"]]

    def test_no_result_is_empty_list(self):
        ws = ws_returning(response(None))
        assert rows(ws, "wh", "SELECT x FROM t") == []

    def test_as_dicts(self):
        ws = ws_returning(response([["a", "1"]], columns=["x", "y"]))
        assert rows(ws, "wh", "SELECT x, y FROM t", as_dicts=True) == [{"x": "a", "y": "1"}]

    def test_as_dicts_without_schema_raises(self):
        ws = ws_returning(response([["a"]]))
        with pytest.raises(SqlStatementError) as ei:
            rows(ws, "wh", "SELECT x FROM t", as_dicts=True)
        assert ei.value.state == "NO_SCHEMA"

    def test_collects_every_chunk(self):
        ws = ws_returning(response([["1"]], next_chunk_index=1, total_row_count=3, columns=["n"]))
        from databricks.sdk.service.sql import ResultData

        ws.statement_execution.get_statement_result_chunk_n.side_effect = [
            ResultData(data_array=[["2"]], next_chunk_index=2),
            ResultData(data_array=[["3"]]),
        ]
        assert rows(ws, "wh", "SELECT n FROM t") == [["1"], ["2"], ["3"]]

    @pytest.mark.parametrize("cycle", [0, 1])
    def test_chunk_chain_that_does_not_advance_raises(self, cycle):
        from databricks.sdk.service.sql import ResultData

        ws = ws_returning(response([["1"]], next_chunk_index=1))
        # Hard stop so a missing guard fails fast instead of looping forever.
        ws.statement_execution.get_statement_result_chunk_n.side_effect = (
            [ResultData(data_array=[["x"]], next_chunk_index=cycle)] * 5
            + [AssertionError("chunk loop did not stop")]
        )
        with pytest.raises(SqlStatementError) as ei:
            rows(ws, "wh", "SELECT n FROM t")
        assert ei.value.state == "TRUNCATED"
        assert ws.statement_execution.get_statement_result_chunk_n.call_count == 1

    def test_chunk_count_is_capped(self, monkeypatch):
        from databricks.sdk.service.sql import ResultData

        monkeypatch.setattr(_sql, "_MAX_RESULT_CHUNKS", 3)
        ws = ws_returning(response([["0"]], next_chunk_index=1))
        def chunk(sid, i):
            if i > 50:
                raise AssertionError("chunk loop did not stop")
            return ResultData(data_array=[[str(i)]], next_chunk_index=i + 1)

        ws.statement_execution.get_statement_result_chunk_n.side_effect = chunk
        with pytest.raises(SqlStatementError) as ei:
            rows(ws, "wh", "SELECT n FROM t")
        assert ei.value.state == "TRUNCATED"
        assert ws.statement_execution.get_statement_result_chunk_n.call_count == 3

    def test_closed_read_is_an_error(self):
        ws = ws_returning(response(state="CLOSED"))
        with pytest.raises(SqlStatementError) as ei:
            rows(ws, "wh", "SELECT n FROM t")
        assert ei.value.state == "CLOSED"

    def test_truncated_manifest_raises(self):
        ws = ws_returning(response([["1"]], truncated=True))
        with pytest.raises(SqlStatementError) as ei:
            rows(ws, "wh", "SELECT n FROM t")
        assert ei.value.state == "TRUNCATED"

    def test_row_count_mismatch_raises(self):
        ws = ws_returning(response([["1"]], total_row_count=2))
        with pytest.raises(SqlStatementError) as ei:
            rows(ws, "wh", "SELECT n FROM t")
        assert ei.value.state == "TRUNCATED"

    def test_missing_table_raises_by_default(self):
        ws = ws_returning(response(error="[TABLE_OR_VIEW_NOT_FOUND] t"))
        with pytest.raises(SqlStatementError):
            rows(ws, "wh", "SELECT * FROM t")

    def test_missing_table_none(self):
        ws = ws_returning(response(error="[TABLE_OR_VIEW_NOT_FOUND] t"))
        assert rows(ws, "wh", "SELECT * FROM t", missing_table="none") is None

    def test_missing_table_none_from_sdk_exception(self):
        ws = ws_returning(RuntimeError("TABLE_OR_VIEW_NOT_FOUND"))
        assert rows(ws, "wh", "SELECT * FROM t", missing_table="none") is None

    def test_missing_table_none_still_raises_other_errors(self):
        ws = ws_returning(response(error="PERMISSION_DENIED"))
        with pytest.raises(SqlStatementError):
            rows(ws, "wh", "SELECT * FROM t", missing_table="none")

    def test_passes_wait_timeout(self):
        ws = ws_returning(response([]))
        rows(ws, "wh", "SELECT 1", wait_timeout="30s")
        assert ws.statement_execution.execute_statement.call_args.kwargs["wait_timeout"] == "30s"


class TestScalar:
    def test_first_cell(self):
        ws = ws_returning(response([["VARIANT", "x"], ["STRING", "y"]]))
        assert scalar(ws, "wh", "SELECT t") == "VARIANT"

    def test_no_rows_is_none(self):
        ws = ws_returning(response([]))
        assert scalar(ws, "wh", "SELECT t") is None

    def test_failure_raises(self):
        ws = ws_returning(response(error="boom"))
        with pytest.raises(SqlStatementError):
            scalar(ws, "wh", "SELECT t")


class TestRun:
    def test_success_returns_none(self):
        ws = ws_returning(response(None))
        assert run(ws, "wh", "INSERT INTO t VALUES (1)") is None
        assert ws.statements == ["INSERT INTO t VALUES (1)"]

    def test_failure_raises(self):
        ws = ws_returning(response(error="[DELTA_CONCURRENT_APPEND] conflict"))
        with pytest.raises(SqlStatementError) as ei:
            run(ws, "wh", "INSERT INTO t VALUES (1)")
        assert "DELTA_CONCURRENT_APPEND" in ei.value.message

    def test_closed_write_is_done(self):
        """CLOSED is reached only after a successful execution (its result is gone),
        and a write reads no result."""
        ws = ws_returning(response(state="CLOSED"))
        assert run(ws, "wh", "INSERT INTO t VALUES (1)") is None

    def test_pending_write_is_not_success(self, clock):
        ws = ws_returning(response(state="PENDING", statement_id="s9"))
        with pytest.raises(SqlStatementError) as ei:
            run(ws, "wh", "INSERT INTO t VALUES (1)")
        assert ei.value.state == "TIMEOUT"
        ws.statement_execution.cancel_execution.assert_called_once_with("s9")

    def test_missing_table_skipped_with_none(self):
        ws = ws_returning(response(error="[TABLE_OR_VIEW_NOT_FOUND] t"))
        assert run(ws, "wh", "DELETE FROM t", missing_table="none") is None

    def test_missing_table_raises_by_default(self):
        ws = ws_returning(response(error="[TABLE_OR_VIEW_NOT_FOUND] t"))
        with pytest.raises(SqlStatementError):
            run(ws, "wh", "DELETE FROM t")


class TestServerCancel:
    """``on_timeout="server_cancel"``: the server cancels at the end of its
    wait; the client makes no cancel call and no extra read."""

    def test_asks_the_server_to_cancel_at_the_wait_end(self):
        ws = ws_returning(response([["3"]]))
        assert scalar(ws, "wh", "SELECT 1", wait_timeout="10s", on_timeout="server_cancel") == "3"
        kwargs = ws.statement_execution.execute_statement.call_args.kwargs
        assert kwargs["wait_timeout"] == "10s"
        assert kwargs["on_wait_timeout"].value == "CANCEL"

    def test_a_server_cancelled_read_is_a_timeout_with_no_further_call(self):
        ws = ws_returning(response(state="CANCELED", statement_id="s1"))
        with pytest.raises(SqlStatementError) as exc:
            rows(ws, "wh", "SELECT 1", wait_timeout="10s", on_timeout="server_cancel")
        assert exc.value.state == "TIMEOUT"
        ws.statement_execution.cancel_execution.assert_not_called()
        ws.statement_execution.get_statement.assert_not_called()

    def test_the_default_does_not_ask_the_server_to_cancel(self):
        ws = ws_returning(response([]))
        rows(ws, "wh", "SELECT 1")
        assert "on_wait_timeout" not in ws.statement_execution.execute_statement.call_args.kwargs
