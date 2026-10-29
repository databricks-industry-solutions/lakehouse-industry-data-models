"""Error message sanitization — strips sensitive information from API error responses."""

import logging
import re
import uuid
from collections.abc import Callable
from typing import Any

import psycopg
import requests
from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse
from sqlalchemy.exc import SQLAlchemyError
from starlette.exceptions import HTTPException as StarletteHTTPException
from starlette.responses import Response

logger = logging.getLogger(__name__)

# Maximum length for error messages returned to clients
MAX_ERROR_LENGTH = 500

# Maximum length for an :class:`AppMessage`.
MAX_APP_MESSAGE_LENGTH = 2000

# The body of a path to redact. It stops at whitespace and at ) : , ; " ' < >,
# so the separator after a path survives ("Could not read [REDACTED]: ...").
# It neither starts nor ends with a dot, so "/Volumes/." and a sentence-ending
# period stay text. A path that runs into a "<placeholder>" is a hint template
# (/Volumes/<catalog>/..., /Workspace/Users/<your email>/) and is kept whole:
# the atomic group stops the match from backtracking to a shorter path.
_STOP = r"\s,;\"'<>):"
_PATH_BODY = rf"(?>[^{_STOP}.](?:[^{_STOP}]*[^{_STOP}.])?)(?!<)"

# Patterns to strip from error messages
_PATTERNS = [
    # Workspace and Volume paths
    re.compile(rf"/Workspace/{_PATH_BODY}"),
    re.compile(rf"/Volumes/{_PATH_BODY}"),
    # DBFS paths
    re.compile(rf"dbfs:/{_PATH_BODY}"),
    # Email addresses
    re.compile(r"[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+"),
    # API tokens (dapi… or similar bearer tokens)
    re.compile(r"\bdapi[a-f0-9]{32,}\b"),
    re.compile(r"\bBearer\s+[A-Za-z0-9_\-.]+", re.IGNORECASE),
    # Generic long hex strings that may be tokens (40+ hex chars)
    re.compile(r"\b[a-f0-9]{40,}\b"),
]

_REDACTED = "[REDACTED]"

# The text of an unhandled database or connection error. The driver text of
# these carries the SQL statement, its bound parameters and the Lakebase or
# workspace host, so the client gets this sentence and the log keeps the error.
DB_ERROR_MESSAGE = "A database error stopped this request. Try again."
CONNECTION_ERROR_MESSAGE = "A connection to a service failed. Try again."

# SQLAlchemyError covers DBAPIError (IntegrityError, OperationalError, ...);
# psycopg.Error is the same family raised outside a SQLAlchemy session.
_DB_ERRORS = (SQLAlchemyError, psycopg.Error)
# Transport failures (the SDK and the GitHub client both use requests) name the host.
_CONNECTION_ERRORS = (requests.RequestException, ConnectionError, TimeoutError)

# Keys of a structured ``detail`` whose values are free text for the user.
# Every other key is structural (``error``, ``missing[].settings_url``,
# ``runs_path``, ``job_reader``, ...): the UI reads it verbatim, so it passes
# through unchanged.
MESSAGE_KEYS = frozenset({"message", "detail", "error_message"})

# Statuses whose response must not carry a body (Starlette's default handler
# makes the same exception).
_NO_BODY_STATUSES = frozenset({204, 304})

SpaFallback = Callable[[Request], Response | None]


class AppMessage(str):
    """Error text the app wrote itself, such as a run blocker with its "To proceed" steps.

    Its length grows with the names it quotes, and the steps the user needs come
    last, so the handler cuts it at :data:`MAX_APP_MESSAGE_LENGTH` instead of
    :data:`MAX_ERROR_LENGTH`. It is redacted like any other message. Wrap only
    text the app composes from bounded parts, never an SDK error.
    """


_OFFENDING_RELATION_RE = re.compile(
    r'(?:constraint|table)\s+"([^"]+)"', re.IGNORECASE
)


def offending_relation(exc: BaseException) -> str | None:
    """Parse the offending constraint/table name from a DB error.

    Reads ``str(exc.orig)`` (the driver-level error) and returns just the
    bare relation name (e.g. ``subdomains`` or ``subdomains_domain_id_fkey``)
    from a ``constraint "<name>"`` / ``table "<name>"`` clause. Returns
    ``None`` when the driver text doesn't carry a recognisable name. Never
    returns the full driver text: callers embed only this bare name in a
    user message, and :func:`sanitize_error_message` still runs on every
    detail as defense in depth.
    """
    orig = getattr(exc, "orig", None)
    text = str(orig) if orig is not None else str(exc)
    m = _OFFENDING_RELATION_RE.search(text)
    return m.group(1) if m else None


def sanitize_error_message(message: str, *, max_length: int = MAX_ERROR_LENGTH) -> str:
    """Remove sensitive information from an error message and cap its length."""
    for pattern in _PATTERNS:
        message = pattern.sub(_REDACTED, message)
    if len(message) > max_length:
        message = message[:max_length] + "..."
    return message


def is_opaque_error(exc: BaseException) -> bool:
    """Whether the text of ``exc`` must not reach a client or a stored column:
    a database or connection error, whose text carries the SQL statement, its
    bound parameters or a host. The one predicate every catch site uses."""
    return isinstance(exc, _DB_ERRORS) or isinstance(exc, _CONNECTION_ERRORS)


def _fixed_text(exc: BaseException) -> str:
    return DB_ERROR_MESSAGE if isinstance(exc, _DB_ERRORS) else CONNECTION_ERROR_MESSAGE


def unhandled_error_detail(exc: BaseException, request_id: str = "") -> str:
    """The client text of an exception no route handled.

    A database or connection error gets a fixed sentence (never ``str(exc)``);
    any other error keeps its sanitized text. ``request_id`` is appended so a
    user can quote it and an operator finds the logged error.
    """
    if not is_opaque_error(exc):
        return sanitize_error_message(str(exc)) if str(exc) else "Internal server error"
    fixed = _fixed_text(exc)
    return f"{fixed} Reference: {request_id}" if request_id else fixed


def recorded_error_text(exc: BaseException, what: str, fallback: str | None = None) -> str:
    """The text of a caught error that is stored or returned.

    A database or connection error is logged here with a reference and gives
    the fixed sentence plus that reference (the request's id, else a new one:
    background work has none). Any other error gives ``fallback``, the text the
    caller stored before, else the sanitized ``str(exc)``. ``what`` names the
    failed step in the log line.
    """
    if not is_opaque_error(exc):
        return fallback if fallback is not None else sanitize_error_message(str(exc))
    # core/__init__ imports this module, so the import cannot sit at the top.
    from .core._request_id import get_request_id

    reference = get_request_id() or str(uuid.uuid4())
    logger.error("%s failed (reference %s)", what, reference, exc_info=exc)
    return f"{_fixed_text(exc)} Reference: {reference}"


def _sanitize_value(value: Any, is_message: bool) -> Any:
    if isinstance(value, dict):
        return {k: _sanitize_value(v, k in MESSAGE_KEYS) for k, v in value.items()}
    if isinstance(value, (list, tuple)):
        return [_sanitize_value(v, is_message) for v in value]
    if is_message and isinstance(value, str):
        cap = MAX_APP_MESSAGE_LENGTH if isinstance(value, AppMessage) else MAX_ERROR_LENGTH
        return sanitize_error_message(value, max_length=cap)
    return value


def sanitize_error_detail(detail: Any) -> Any:
    """Sanitize an ``HTTPException.detail`` while keeping its shape.

    A string detail is the message itself and is sanitized whole. A dict
    detail keeps every key; only string values under :data:`MESSAGE_KEYS`
    are sanitized, at any depth and inside list items. Structural values
    (discriminators, links, paths the admin must copy) pass through. A
    message is cut at :data:`MAX_ERROR_LENGTH`, an :class:`AppMessage` at
    :data:`MAX_APP_MESSAGE_LENGTH`.
    """
    return _sanitize_value(detail, True)


def register_error_handlers(app: FastAPI, *, spa_fallback: SpaFallback | None = None) -> None:
    """Register the app's global exception handlers.

    This is the only ``HTTPException`` handler of the app, so sanitization
    does not depend on registration order. ``spa_fallback`` is consulted for
    404s when the built UI is served (``core/_static.spa_fallback``); when it
    returns a response (the SPA page for a browser navigation), that wins.
    """

    @app.exception_handler(StarletteHTTPException)
    async def http_exception_handler(request: Request, exc: StarletteHTTPException):
        if exc.status_code == 404 and spa_fallback is not None:
            page = spa_fallback(request)
            if page is not None:
                return page
        # 4xx is expected behaviour — log at INFO, no stack trace. 5xx from
        # explicit HTTPException(status_code=5xx) is rare but worth a traceback.
        if exc.status_code >= 500:
            logger.exception(
                "HTTPException %s on %s %s", exc.status_code, request.method, request.url.path
            )
        else:
            logger.info(
                "HTTPException %s on %s %s: %s",
                exc.status_code, request.method, request.url.path, exc.detail,
            )
        headers = getattr(exc, "headers", None)
        if exc.status_code in _NO_BODY_STATUSES:
            return Response(status_code=exc.status_code, headers=headers)
        detail = exc.detail if exc.detail else "An error occurred"
        return JSONResponse(
            status_code=exc.status_code,
            content={"detail": sanitize_error_detail(detail)},
            headers=headers,
        )

    @app.exception_handler(Exception)
    async def unhandled_exception_handler(request: Request, exc: Exception):
        # Always log the full traceback server-side; the sanitized body hides
        # sensitive detail from the client but operators need the real error
        # to debug. Without this, every 500 in production is opaque.
        # ServerErrorMiddleware runs outside RequestIdMiddleware, whose
        # ContextVar is already reset here; the id travels on request.state.
        request_id = getattr(request.state, "request_id", "")
        logger.exception(
            "Unhandled %s on %s %s (request %s)",
            type(exc).__name__, request.method, request.url.path, request_id,
        )
        return JSONResponse(
            status_code=500,
            content={"detail": unhandled_error_detail(exc, request_id)},
            headers={"x-request-id": request_id} if request_id else None,
        )
