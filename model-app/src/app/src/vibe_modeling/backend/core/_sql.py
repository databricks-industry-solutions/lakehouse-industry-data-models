"""Safe SQL construction and strict statement execution.

Use these instead of f-stringing values into Spark/Unity Catalog SQL or
calling ``ws.statement_execution`` directly. They sit alongside
:mod:`core._names` (which sanitizes/coerces unsafe inputs):

- :func:`safe_identifier` - assert a value already IS a UC identifier and
  backtick-quote it for embedding in SQL. Never sanitizes silently.
- :func:`like_pattern` - escape ``%`` / ``_`` / ``\\`` for safe inclusion
  in a ``LIKE`` clause. Caller adds the wildcards they actually want.
- :func:`execute` - run a statement through the Statement Execution API
  (named placeholders bound by the SDK), poll it to a terminal state within
  the caller's time bound (``timeout_s``, measured on ``time.monotonic``)
  and return the response only when it SUCCEEDED.
- :func:`rows`, :func:`scalar`, :func:`run` - the read, single-value and
  write shapes on top of :func:`execute`.

Every failure raises :class:`SqlStatementError`, so a failed query never
reads as zero rows. The only soft outcome is ``missing_table="none"``: a
``TABLE_OR_VIEW_NOT_FOUND`` error then returns ``None``. A caller that wants
to degrade catches :class:`SqlStatementError` and says so at its call site.
"""

from __future__ import annotations

import logging
import re
import time
from typing import Any, Literal, Mapping

from ..error_sanitization import sanitize_error_message

logger = logging.getLogger(__name__)

TABLE_OR_VIEW_NOT_FOUND = "TABLE_OR_VIEW_NOT_FOUND"
_SQL_ECHO = "== SQL =="

_NON_TERMINAL_STATES = ("PENDING", "RUNNING")

# A result never has this many chunks within the 25 MiB inline limit; the cap
# only stops a server that keeps returning a next_chunk_index.
_MAX_RESULT_CHUNKS = 10_000

_WAIT_RE = re.compile(r"^(\d+)s$")

# get_statement blocks about 5 s on a serverless warehouse (measured on the test workspace,
# 2026-10). Until a poll has measured it, a poll is assumed to cost this much.
_FIRST_READ_ESTIMATE_S = 5.0

MissingTable = Literal["raise", "none"]
OnTimeout = Literal["cancel", "detach", "server_cancel"]
ReadOnTimeout = Literal["cancel", "server_cancel"]

# Unity Catalog identifiers: a letter or underscore followed by letters,
# digits, or underscores. We backtick-quote on output but reject anything
# that wouldn't be a plain identifier - dots, semicolons, spaces, empty
# strings, etc. NEVER silently sanitize; sanitation belongs in
# :mod:`core._names`.
_IDENT_RE = re.compile(r"^[A-Za-z_][A-Za-z0-9_]*$")


class SqlStatementError(RuntimeError):
    """A SQL statement did not succeed.

    ``state`` is one of:

    - the statement state: ``FAILED``, ``CANCELED``, or ``CLOSED`` for a read
      (its result is gone);
    - ``TIMEOUT``: still running at the end of the caller's bound; it was
      cancelled when it had a statement id;
    - ``STILL_RUNNING``: the caller chose ``on_timeout="detach"``; it keeps
      running in the warehouse and the caller decides what that means;
    - ``TRUNCATED``: the result is incomplete or its chunk chain is broken;
    - ``NO_SCHEMA``: rows came back without a column schema;
    - ``UNKNOWN``: the response carries no recognisable state;
    - ``ERROR``: a request to the API raised (an in-flight statement is
      cancelled first, best-effort).

    ``message`` is sanitized for users and stops before the statement a
    warehouse error echoes after ``== SQL ==``.
    """

    def __init__(
        self,
        state: str,
        message: str,
        *,
        statement_id: str | None = None,
    ) -> None:
        raw = message or ""
        self.state = state
        # A warehouse error ends with "== SQL ==" and the statement it ran,
        # whose literals are the caller's data: the message keeps what precedes it.
        self.message = sanitize_error_message(raw.split(_SQL_ECHO, 1)[0].rstrip())
        self.statement_id = statement_id
        self.table_missing = TABLE_OR_VIEW_NOT_FOUND in raw
        super().__init__(f"SQL statement {state}: {self.message}")


def safe_identifier(name: str) -> str:
    """Validate and backtick-quote a UC identifier (catalog/schema/table/column).

    Raises :class:`ValueError` on anything that isn't a plain identifier.
    Use :func:`core._names.sanitize_catalog_segment` (or similar) if you
    need to MAKE a name safe; this function is for ASSERTING a name
    already is safe before embedding it in SQL.

    >>> safe_identifier("my_catalog")
    '`my_catalog`'
    """
    if not isinstance(name, str) or not _IDENT_RE.match(name):
        raise ValueError(f"unsafe SQL identifier: {name!r}")
    return f"`{name}`"


def like_pattern(literal: str) -> str:
    """Escape ``%``, ``_`` and ``\\`` so ``literal`` is safe in a LIKE clause.

    The caller is responsible for adding any leading/trailing ``%`` they
    actually intend (i.e. this function only escapes - it never wraps).

    >>> like_pattern("100% off_now")
    '100\\\\% off\\\\_now'
    """
    return (
        (literal or "")
        .replace("\\", "\\\\")
        .replace("%", "\\%")
        .replace("_", "\\_")
    )


def _state_of(resp: Any) -> str:
    """Upper-case statement state, or ``""`` when the response has none.

    Accepts the SDK's ``StatementState`` enum and plain strings.
    """
    status = getattr(resp, "status", None)
    state = getattr(status, "state", None) if status is not None else None
    val = getattr(state, "value", state)
    return val.upper() if isinstance(val, str) else ""


def _error_message_of(resp: Any) -> str | None:
    status = getattr(resp, "status", None)
    err = getattr(status, "error", None) if status is not None else None
    if err is None:
        return None
    msg = getattr(err, "message", None)
    return msg if isinstance(msg, str) and msg else str(err)


def _cancel(ws: Any, statement_id: str | None) -> None:
    if not statement_id:
        return
    try:
        ws.statement_execution.cancel_execution(statement_id)
    except Exception as exc:  # noqa: BLE001 - cancel is best-effort; the caller's error is raised either way
        logger.warning("core._sql: cancel of statement %s failed: %s", statement_id, exc)


def _server_wait(wait_timeout: str, timeout_s: float | None) -> str:
    """The server-side wait to ask for: ``wait_timeout``, cut to ``timeout_s``.

    The API accepts ``0s`` (return at once) or 5s to 50s.
    """
    if timeout_s is None:
        return wait_timeout
    m = _WAIT_RE.match(wait_timeout or "")
    requested = int(m.group(1)) if m else 50
    secs = int(min(requested, max(timeout_s, 0.0)))
    return f"{secs if secs >= 5 else 0}s"


def _read(ws: Any, statement_id: str) -> tuple[Any, float]:
    """One ``get_statement``; returns the response and how long the call took.

    On a raise the statement is cancelled (best-effort) before
    ``SqlStatementError("ERROR")`` is raised, so it does not run unobserved.
    """
    t0 = time.monotonic()
    try:
        resp = ws.statement_execution.get_statement(statement_id)
    except Exception as exc:
        _cancel(ws, statement_id)
        raise SqlStatementError("ERROR", str(exc), statement_id=statement_id) from exc
    return resp, time.monotonic() - t0


def _check_terminal(resp: Any, statement_id: str | None, *, closed_ok: bool) -> None:
    state = _state_of(resp)
    error = _error_message_of(resp)
    if error is not None:
        raise SqlStatementError(state or "FAILED", error, statement_id=statement_id)
    if state == "SUCCEEDED" or (closed_ok and state == "CLOSED"):
        return
    raise SqlStatementError(
        state or "UNKNOWN",
        f"statement ended in state {state or 'unknown'}",
        statement_id=statement_id,
    )


def _execute(
    ws: Any,
    warehouse_id: str,
    sql: str,
    params: Mapping[str, Any] | None,
    *,
    wait_timeout: str,
    timeout_s: float | None,
    poll_interval_s: float,
    on_timeout: OnTimeout,
    closed_ok: bool,
) -> Any:
    from databricks.sdk.service.sql import StatementParameterListItem

    started = time.monotonic()
    deadline = started + (timeout_s if timeout_s is not None else 0.0)
    sdk_params: list[StatementParameterListItem] | None = None
    if params:
        sdk_params = [
            StatementParameterListItem(
                name=k,
                value=str(v) if v is not None else None,
            )
            for k, v in params.items()
        ]
    extra: dict[str, Any] = {}
    if on_timeout == "server_cancel":
        from databricks.sdk.service.sql import ExecuteStatementRequestOnWaitTimeout

        extra["on_wait_timeout"] = ExecuteStatementRequestOnWaitTimeout.CANCEL
    try:
        resp = ws.statement_execution.execute_statement(
            statement=sql,
            warehouse_id=warehouse_id,
            wait_timeout=_server_wait(wait_timeout, timeout_s),
            parameters=sdk_params,
            **extra,
        )
    except Exception as exc:
        raise SqlStatementError("ERROR", str(exc)) from exc

    statement_id = getattr(resp, "statement_id", None)
    # A poll is started only when its sleep plus the last measured
    # get_statement round trip still fits before the deadline.
    read_cost = _FIRST_READ_ESTIMATE_S
    while _state_of(resp) in _NON_TERMINAL_STATES and statement_id:
        if deadline - time.monotonic() < poll_interval_s + read_cost:
            break
        time.sleep(poll_interval_s)
        resp, read_cost = _read(ws, statement_id)

    if on_timeout == "server_cancel" and _state_of(resp) == "CANCELED" and _error_message_of(resp) is None:
        raise SqlStatementError(
            "TIMEOUT",
            f"statement cancelled by the server after its {wait_timeout} wait",
            statement_id=statement_id,
        )
    if _state_of(resp) in _NON_TERMINAL_STATES:
        resp = _unfinished(
            ws, resp, statement_id,
            elapsed=time.monotonic() - started,
            on_timeout=on_timeout,
        )
    _check_terminal(resp, statement_id, closed_ok=closed_ok)
    return resp


def _unfinished(
    ws: Any, resp: Any, statement_id: str | None, *, elapsed: float, on_timeout: OnTimeout,
) -> Any:
    """The statement is still running at the end of the bound.

    ``detach``: raise ``STILL_RUNNING`` and leave it running. ``cancel``:
    cancel it, read the state once more and decide from that (a statement
    that finished just before the cancel is a success); otherwise raise
    ``TIMEOUT``. The final read is the one call made after the deadline.
    """
    state = _state_of(resp)
    if not statement_id:
        raise SqlStatementError(
            "TIMEOUT",
            f"statement still {state} after {elapsed:.0f}s; no statement id, so not cancelled",
        )
    if on_timeout == "detach":
        raise SqlStatementError(
            "STILL_RUNNING",
            f"statement still {state} after {elapsed:.0f}s; left running",
            statement_id=statement_id,
        )
    _cancel(ws, statement_id)
    try:
        final, _ = _read(ws, statement_id)
    except SqlStatementError:
        final = resp
    final_state = _state_of(final)
    if final_state in _NON_TERMINAL_STATES or (final_state == "CANCELED" and _error_message_of(final) is None):
        raise SqlStatementError(
            "TIMEOUT",
            f"statement still {state} after {elapsed:.0f}s; cancelled",
            statement_id=statement_id,
        )
    return final


def execute(
    ws: Any,
    warehouse_id: str,
    sql: str,
    params: Mapping[str, Any] | None = None,
    *,
    wait_timeout: str = "50s",
    timeout_s: float | None = None,
    poll_interval_s: float = 2.0,
    on_timeout: OnTimeout = "cancel",
) -> Any:
    """Run a statement and return its SDK ``StatementResponse`` once it SUCCEEDED.

    ``sql`` should use named placeholders (e.g. ``:biz``) and ``params``
    binds them as :class:`StatementParameterListItem`, so the server does
    the escaping - never f-string user-controlled values into the SQL text.

    The bound is the caller's, in wall-clock seconds on ``time.monotonic``:

    - ``timeout_s=None``: only the server-side ``wait_timeout`` (no polling).
    - ``timeout_s=N``: the whole call, server wait included, stops waiting
      after about N seconds. The server wait is cut to fit; polls run
      ``poll_interval_s`` apart while the next one still fits.

    A statement still running at the end is cancelled and raises
    ``SqlStatementError("TIMEOUT")`` unless one last read finds it finished;
    with ``on_timeout="detach"`` it is left running and raises
    ``SqlStatementError("STILL_RUNNING")``. ``on_timeout="server_cancel"``
    asks the server to cancel it at the end of ``wait_timeout``
    (``on_wait_timeout=CANCEL``, no client cancel or extra read) and raises
    ``TIMEOUT``; use it with ``timeout_s=None`` for a single bounded wait.
    Any other non-success raises :class:`SqlStatementError`.
    """
    return _execute(
        ws, warehouse_id, sql, params,
        wait_timeout=wait_timeout, timeout_s=timeout_s, poll_interval_s=poll_interval_s,
        on_timeout=on_timeout, closed_ok=False,
    )


def _all_rows(ws: Any, resp: Any) -> list[list]:
    """Every row of a SUCCEEDED response, across all INLINE chunks.

    Raises ``SqlStatementError("TRUNCATED")`` when the manifest says the
    result was cut, the fetched count differs from ``total_row_count``, or
    the chunk chain does not move forward.
    """
    statement_id = getattr(resp, "statement_id", None)
    manifest = getattr(resp, "manifest", None)
    first = getattr(resp, "result", None)
    out: list[list] = list(getattr(first, "data_array", None) or [])
    current = getattr(first, "chunk_index", None)
    current = current if isinstance(current, int) else 0
    next_idx = getattr(first, "next_chunk_index", None)
    fetched = 0
    while isinstance(next_idx, int) and statement_id:
        if next_idx <= current or fetched >= _MAX_RESULT_CHUNKS:
            raise SqlStatementError(
                "TRUNCATED",
                f"result chunk chain does not advance (chunk {current} -> {next_idx}, "
                f"{fetched} fetched)",
                statement_id=statement_id,
            )
        try:
            chunk = ws.statement_execution.get_statement_result_chunk_n(statement_id, next_idx)
        except Exception as exc:
            raise SqlStatementError("ERROR", str(exc), statement_id=statement_id) from exc
        fetched += 1
        current = next_idx
        out.extend(getattr(chunk, "data_array", None) or [])
        next_idx = getattr(chunk, "next_chunk_index", None)

    if getattr(manifest, "truncated", None) is True:
        raise SqlStatementError(
            "TRUNCATED", "result is truncated (manifest.truncated)", statement_id=statement_id,
        )
    total = getattr(manifest, "total_row_count", None)
    if isinstance(total, int) and len(out) != total:
        raise SqlStatementError(
            "TRUNCATED",
            f"fetched {len(out)} row(s) but manifest.total_row_count={total}",
            statement_id=statement_id,
        )
    return out


def rows(
    ws: Any,
    warehouse_id: str,
    sql: str,
    params: Mapping[str, Any] | None = None,
    *,
    wait_timeout: str = "50s",
    timeout_s: float | None = None,
    poll_interval_s: float = 2.0,
    missing_table: MissingTable = "raise",
    as_dicts: bool = False,
    on_timeout: ReadOnTimeout = "cancel",
) -> list[list] | list[dict] | None:
    """All result rows of a query (lists, or dicts keyed by column with ``as_dicts``).

    ``[]`` means the query succeeded with no rows. ``None`` is returned only
    with ``missing_table="none"`` when the table or view does not exist.
    The bound is as in :func:`execute`; a read is always cancelled on timeout,
    by the client (``"cancel"``) or by the server (``"server_cancel"``).
    """
    try:
        resp = execute(
            ws, warehouse_id, sql, params,
            wait_timeout=wait_timeout, timeout_s=timeout_s, poll_interval_s=poll_interval_s,
            on_timeout=on_timeout,
        )
    except SqlStatementError as exc:
        if missing_table == "none" and exc.table_missing:
            return None
        raise
    data = _all_rows(ws, resp)
    if not as_dicts:
        return data
    manifest = getattr(resp, "manifest", None)
    schema = getattr(manifest, "schema", None)
    columns = [c.name for c in (getattr(schema, "columns", None) or [])]
    if data and not columns:
        raise SqlStatementError(
            "NO_SCHEMA", "result has rows but no column schema",
            statement_id=getattr(resp, "statement_id", None),
        )
    return [dict(zip(columns, r)) for r in data]


def scalar(
    ws: Any,
    warehouse_id: str,
    sql: str,
    params: Mapping[str, Any] | None = None,
    *,
    wait_timeout: str = "50s",
    timeout_s: float | None = None,
    poll_interval_s: float = 2.0,
    missing_table: MissingTable = "raise",
    on_timeout: ReadOnTimeout = "cancel",
) -> Any:
    """The first column of the first row, or ``None`` when there is no row.

    Also ``None`` with ``missing_table="none"`` when the table does not exist;
    keep the default ``"raise"`` when the caller must tell those apart.
    """
    data = rows(
        ws, warehouse_id, sql, params,
        wait_timeout=wait_timeout, timeout_s=timeout_s, poll_interval_s=poll_interval_s,
        missing_table=missing_table, on_timeout=on_timeout,
    )
    if not data or not data[0]:
        return None
    return data[0][0]


def run(
    ws: Any,
    warehouse_id: str,
    sql: str,
    params: Mapping[str, Any] | None = None,
    *,
    wait_timeout: str = "50s",
    timeout_s: float | None = None,
    poll_interval_s: float = 2.0,
    missing_table: MissingTable = "raise",
    on_timeout: OnTimeout = "cancel",
) -> None:
    """Run a write (INSERT, DELETE, DDL) and return once it SUCCEEDED.

    ``CLOSED`` also counts as done here: the API reaches it only after a
    successful execution whose result is no longer available, and a write
    reads no result. With ``missing_table="none"`` a
    ``TABLE_OR_VIEW_NOT_FOUND`` is skipped. The bound and ``on_timeout`` are
    as in :func:`execute`.
    """
    try:
        _execute(
            ws, warehouse_id, sql, params,
            wait_timeout=wait_timeout, timeout_s=timeout_s, poll_interval_s=poll_interval_s,
            on_timeout=on_timeout, closed_ok=True,
        )
    except SqlStatementError as exc:
        if missing_table == "none" and exc.table_missing:
            return
        raise
