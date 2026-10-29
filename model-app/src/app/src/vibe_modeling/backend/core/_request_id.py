"""Request-ID correlation middleware (PLAN #53).

Threads a per-request correlation ID through every log record produced
inside the request lifecycle, plus any background asyncio tasks spawned
while the request is being handled.

How it works:
  - On each inbound HTTP request, ``RequestIdMiddleware`` reads the
    ``X-Request-Id`` header (case-insensitive) if the upstream proxy set
    one. Databricks Apps' reverse proxy supplies it; in dev / tests we
    generate a UUID4 fallback.
  - The id is bound to the ``current_request_id`` ``ContextVar`` for the
    duration of the request. ``ContextVar`` follows ``asyncio`` task
    boundaries, so any logger call from a route handler picks it up.
  - The same id is echoed back as the ``X-Request-Id`` response header so
    the client can correlate a server-side trace to its UI action without
    re-reading network logs.
  - Background asyncio tasks (e.g. ``ProgressTracker.start_tracking``)
    spawn off the request thread; without help they would inherit the
    ``ContextVar`` *snapshot* but not the request id from a *different*
    handler that fires later. Use ``copy_context_for_task`` to give the
    spawn site a chance to run the coroutine inside the same context.

Logging integration is in :mod:`vibe_modeling.backend.core._config` —
the ``request_id`` LogRecord attribute is populated by the
``RequestIdLogFilter`` registered on the root logger.
"""

from __future__ import annotations

import contextvars
import uuid
from collections.abc import Awaitable, Callable
from typing import Any

from fastapi import Request, Response
from starlette.middleware.base import BaseHTTPMiddleware

# Empty-string default keeps log formatting safe (no KeyError) when a
# log line is emitted outside any request scope (lifespan, tests, etc.).
current_request_id: contextvars.ContextVar[str] = contextvars.ContextVar(
    "current_request_id", default=""
)


def get_request_id() -> str:
    """Return the request-id bound to the current context, or empty string.

    Safe to call from anywhere — returns ``""`` when no request is active
    (e.g. during app startup, in a non-request-scoped task).
    """
    return current_request_id.get()


def _new_request_id() -> str:
    """Generate a fresh UUID4 string for use as a request id."""
    return str(uuid.uuid4())


class RequestIdMiddleware(BaseHTTPMiddleware):
    """Bind ``X-Request-Id`` to a ContextVar for the duration of the request.

    Reads an inbound ``X-Request-Id`` header; if absent, mints a UUID4.
    Sets the context variable, runs the rest of the request, echoes the
    id back in the response, then resets the context.
    """

    async def dispatch(
        self,
        request: Request,
        call_next: Callable[[Request], Awaitable[Response]],
    ) -> Response:
        rid = request.headers.get("x-request-id") or _new_request_id()
        # The unhandled-exception handler runs outside this middleware, after
        # the ContextVar is reset; it reads the id from here.
        request.state.request_id = rid
        token = current_request_id.set(rid)
        try:
            response = await call_next(request)
            # Echo back so clients can correlate; safe to do even when the
            # header was inbound (idempotent overwrite of the same value).
            response.headers["x-request-id"] = rid
            return response
        finally:
            current_request_id.reset(token)


def copy_context_for_task() -> contextvars.Context:
    """Capture the current ContextVar snapshot for a background task.

    Used by ``ProgressTracker.start_tracking`` to ensure the request id
    of the handler that triggered the spawn is preserved across the
    lifetime of the background poll loop. Returns a ``Context`` whose
    ``.run(fn, *args)`` replays the current vars in the spawned task.
    """
    return contextvars.copy_context()


class RequestIdLogFilter:
    """Logging filter that pulls the request id off the ContextVar.

    Attaches a ``request_id`` attribute to every ``LogRecord`` so format
    strings can include ``%(request_id)s`` without triggering a
    ``KeyError`` outside a request scope (the default is ``""``).

    Implemented as a plain class with ``filter`` rather than subclassing
    ``logging.Filter`` to keep imports cheap and avoid surprising callers
    that introspect filter chains.
    """

    def filter(self, record: Any) -> bool:  # noqa: D401 — logging API
        record.request_id = current_request_id.get()
        return True
