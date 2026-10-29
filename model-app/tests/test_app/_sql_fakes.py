"""Statement Execution API fakes built from the SDK's own dataclasses.

``core._sql`` reads the statement state strictly, so a bare ``MagicMock``
response (no recognisable state) is a failure. Tests that drive SQL build
responses here instead.

``FakeClock`` replaces ``time.monotonic`` and ``time.sleep``. With
``ws_returning(..., clock=clock)`` the server-side ``wait_timeout`` of a
statement that comes back unfinished and every ``get_statement`` call
(``poll_cost_s``, about 5 s on a real serverless warehouse) advance it, so
time bounds are checked against what a real warehouse costs.
"""
from __future__ import annotations

import time
from typing import Any, Callable, Iterable
from unittest.mock import MagicMock

from databricks.sdk.service.sql import (
    ColumnInfo,
    ResultData,
    ResultManifest,
    ResultSchema,
    ServiceError,
    StatementResponse,
    StatementState,
    StatementStatus,
)


def response(
    rows: list[list] | None = None,
    *,
    columns: Iterable[str] | None = None,
    state: str = "SUCCEEDED",
    error: str | None = None,
    statement_id: str = "stmt-1",
    next_chunk_index: int | None = None,
    truncated: bool | None = None,
    total_row_count: int | None = None,
) -> StatementResponse:
    """One ``StatementResponse``. ``error`` sets ``status.error.message``
    (and defaults the state to FAILED)."""
    if error is not None and state == "SUCCEEDED":
        state = "FAILED"
    manifest = None
    if columns is not None or truncated is not None or total_row_count is not None:
        manifest = ResultManifest(
            schema=ResultSchema(columns=[ColumnInfo(name=c) for c in (columns or [])]),
            truncated=truncated,
            total_row_count=total_row_count,
        )
    result = None
    if rows is not None:
        result = ResultData(data_array=rows, next_chunk_index=next_chunk_index)
    return StatementResponse(
        statement_id=statement_id,
        status=StatementStatus(
            state=StatementState(state),
            error=ServiceError(message=error) if error is not None else None,
        ),
        manifest=manifest,
        result=result,
    )


class FakeClock:
    def __init__(self, start: float = 1000.0) -> None:
        self.start = self.now = start
        self.sleeps: list[float] = []

    def advance(self, seconds: float) -> None:
        self.now += seconds

    def sleep(self, seconds: float) -> None:
        self.sleeps.append(seconds)
        self.advance(seconds)

    @property
    def elapsed(self) -> float:
        return self.now - self.start

    def install(self, monkeypatch) -> "FakeClock":
        monkeypatch.setattr(time, "monotonic", lambda: self.now)
        monkeypatch.setattr(time, "sleep", self.sleep)
        return self


def _wait_seconds(wait_timeout: str | None) -> int:
    return int((wait_timeout or "0s").rstrip("s") or 0)


def ws_returning(
    *responses: Any,
    clock: FakeClock | None = None,
    poll_cost_s: float = 0.0,
    polls: Callable[[str], Any] | None = None,
) -> MagicMock:
    """A ws whose ``execute_statement`` returns (or raises) ``responses`` in
    order, the last one for every further call. Submitted SQL is recorded on
    ``ws.statements`` and the server waits asked for on ``ws.waits``.

    ``get_statement(sid)`` returns ``polls(sid)`` when given; otherwise
    CANCELED once ``cancel_execution(sid)`` was called, else RUNNING. With a
    ``clock``, an unfinished submit advances it by its ``wait_timeout`` and
    each ``get_statement`` by ``poll_cost_s``.
    """
    ws = MagicMock()
    ws.statements = []
    ws.waits = []
    cancelled: set[str] = set()
    queue = list(responses)

    def _execute(*_a, statement=None, wait_timeout=None, **_kw):
        ws.statements.append(statement)
        ws.waits.append(wait_timeout)
        item = queue[0] if len(queue) == 1 else queue.pop(0)
        if isinstance(item, BaseException):
            raise item
        if clock is not None and getattr(getattr(item, "status", None), "state", None) in (
            StatementState.PENDING, StatementState.RUNNING,
        ):
            clock.advance(_wait_seconds(wait_timeout))
        return item

    def _get(sid):
        if clock is not None:
            clock.advance(poll_cost_s)
        if polls is not None:
            return polls(sid)
        state = "CANCELED" if sid in cancelled else "RUNNING"
        return response(state=state, statement_id=sid)

    ws.statement_execution.execute_statement.side_effect = _execute
    ws.statement_execution.get_statement.side_effect = _get
    ws.statement_execution.cancel_execution.side_effect = cancelled.add
    return ws
