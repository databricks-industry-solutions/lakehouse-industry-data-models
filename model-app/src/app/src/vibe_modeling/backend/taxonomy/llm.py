"""JSON-only client for the drafting model, called through the Unity AI Gateway.

The model is a Unity Catalog model service (``catalog.schema.service``), called
at ``/ai-gateway/mlflow/v1/chat/completions`` (OpenAI-compatible) with the
app's service-principal client. Access is UC privileges: USE CATALOG,
USE SCHEMA and EXECUTE on the service.

Claude endpoints rejected ``response_format: json_schema`` and forced
``tool_choice`` (verified 2026-10-13), so structure is enforced by a JSON-only
prompt + Pydantic validation + one corrective retry.

Error classification. Shapes observed on a test workspace 2026-10-18: an unknown service
is HTTP 404 ``{"error_code":"NOT_FOUND","message":"'<name>' does not exist."}``
(SDK ``NotFound``); a malformed name is 400 ``BadRequest``. The caller's client
uses ``retry_timeout_seconds=1``, so a 429/503 sleeps once for ``Retry-After``
and then surfaces as a builtin ``TimeoutError`` whose ``__cause__`` is the
SDK's ``TooManyRequests`` / ``TemporarilyUnavailable``; an unparseable 429
body raises ``TooManyRequests`` directly. Both become ``TaxonomyLLMBusy``.
"""

from __future__ import annotations

import ast
import logging
import re
from dataclasses import dataclass
from typing import Any, TypeVar

from databricks.sdk import WorkspaceClient
from databricks.sdk.errors import (
    NotFound,
    PermissionDenied,
    TemporarilyUnavailable,
    TooManyRequests,
    Unauthenticated,
)
from pydantic import BaseModel, ValidationError

from .._workspace_clients import short_budget_workspace_client
from .models import ProbeStatus

log = logging.getLogger(__name__)
T = TypeVar("T", bound=BaseModel)
_FENCE = re.compile(r"```(?:json)?", re.IGNORECASE)

GATEWAY_CHAT_PATH = "/ai-gateway/mlflow/v1/chat/completions"
MODEL_SERVICE_GET_PATH = "/api/2.1/unity-catalog/model-services/{name}"
PROBE_MAX_TOKENS = 5
# The LLM's own WorkspaceClient (``llm_workspace_client``): a 90 s per-call HTTP
# timeout caps how long an abandoned call holds a slot, and a 1 s retry budget
# makes a 429/503 sleep once for Retry-After and then surface as busy.
LLM_HTTP_TIMEOUT_SECONDS = 90
LLM_RETRY_TIMEOUT_SECONDS = 1
# The SDK appends ". Config: host=..., auth_type=... [. Env: ...]" to 401/403
# messages (config.wrap_debug_info). Users only need the gateway's sentence.
_DEBUG_SUFFIX = re.compile(r"\.?\s*Config: .*$", re.DOTALL)


class TaxonomyLLMError(RuntimeError):
    """Any failure talking to, or parsing, the drafting model."""


class TaxonomyLLMBusy(TaxonomyLLMError):
    """The gateway rate-limited the call (429) or was unavailable (503)."""


class TaxonomyLLMDenied(TaxonomyLLMError):
    """The app SP may not use the model service (401/403)."""


class TaxonomyLLMNotFound(TaxonomyLLMError):
    """The model service does not exist (404)."""


@dataclass(frozen=True)
class ProbeResult:
    status: ProbeStatus
    message: str


def busy_message(model_service: str) -> str:
    return f"'{model_service}' is busy right now; try again in a minute."


def extract_json(text: str) -> str:
    t = _FENCE.sub("", text).strip()
    start, end = t.find("{"), t.rfind("}")
    if start == -1 or end < start:
        raise ValueError("no JSON object in the reply")
    return t[start : end + 1]


def _chain(exc: BaseException) -> list[BaseException]:
    """The exception itself, then its ``__cause__``/``__context__`` chain."""
    seen: list[BaseException] = []
    cur: BaseException | None = exc
    while cur is not None and cur not in seen:
        seen.append(cur)
        cur = cur.__cause__ or cur.__context__
    return seen


def error_text(exc: BaseException) -> str:
    """The gateway's own sentence for ``exc``: the ``message`` of an
    OpenAI-style ``{"error": {...}}`` body instead of a dict repr, and no SDK
    config debug suffix."""
    raw: Any = exc.args[0] if exc.args else str(exc)
    if isinstance(raw, str) and raw.startswith("{"):
        try:
            raw = ast.literal_eval(raw)
        except (ValueError, SyntaxError):
            pass
    if isinstance(raw, dict):
        inner = raw.get("error", raw)
        raw = inner.get("message", str(inner)) if isinstance(inner, dict) else inner
    text = str(raw)
    if isinstance(exc, (PermissionDenied, Unauthenticated)):
        text = _DEBUG_SUFFIX.sub("", text)
    return text.strip()


class TaxonomyLLM:
    def __init__(self, ws: Any, model_service: str, max_tokens: int = 8000) -> None:
        self._ws = ws
        self._model_service = model_service
        self._max_tokens = max_tokens

    @property
    def model_service(self) -> str:
        return self._model_service

    def _sp_label(self) -> str:
        client_id = getattr(getattr(self._ws, "config", None), "client_id", None)
        return client_id if isinstance(client_id, str) and client_id else "(unknown)"

    def _classify(self, exc: Exception) -> TaxonomyLLMError:
        name = self._model_service
        for e in _chain(exc):
            if isinstance(e, (TooManyRequests, TemporarilyUnavailable)):
                return TaxonomyLLMBusy(busy_message(name))
            if isinstance(e, (PermissionDenied, Unauthenticated)):
                return TaxonomyLLMDenied(
                    f"The app's service principal {self._sp_label()} may not use model service "
                    f"'{name}': {error_text(e).rstrip('.')}. An admin must grant USE CATALOG, USE SCHEMA and EXECUTE."
                )
            if isinstance(e, NotFound):
                return TaxonomyLLMNotFound(f"Model service '{name}' was not found.")
        return TaxonomyLLMError(f"'{name}' failed the call: {error_text(exc)}")

    def _post(self, messages: list[dict], max_tokens: int) -> dict:
        try:
            resp = self._ws.api_client.do(
                "POST",
                GATEWAY_CHAT_PATH,
                body={"model": self._model_service, "messages": messages, "max_tokens": max_tokens},
            )
        except Exception as e:  # SDK raises DatabricksError subclasses / TimeoutError; classify, keep the cause
            log.warning("taxonomy LLM call failed: %s", e)
            raise self._classify(e) from e
        if not isinstance(resp, dict) or not isinstance(resp.get("choices"), list):
            raise TaxonomyLLMError(f"unexpected response from model service '{self._model_service}'")
        return resp

    def _chat(self, messages: list[dict]) -> str:
        resp = self._post(messages, self._max_tokens)
        try:
            content = resp["choices"][0]["message"]["content"]
        except (KeyError, IndexError, TypeError) as e:
            raise TaxonomyLLMError(f"unexpected response from model service: {e}") from e
        if isinstance(content, list):
            # Reasoning models return a list of blocks; keep only the text blocks.
            content = "".join(
                b["text"]
                for b in content
                if isinstance(b, dict) and b.get("type") == "text" and isinstance(b.get("text"), str)
            )
        elif not isinstance(content, str):
            raise TaxonomyLLMError(f"unexpected response from model service: content type {type(content).__name__}")
        if not content:
            raise TaxonomyLLMError("model service returned an empty reply")
        return content

    def probe(self) -> ProbeResult:
        """One tiny call proving the app SP can use the service. Any 2xx with a
        ``choices`` array is ``ok`` even with no text (a reasoning model at
        ``max_tokens=5`` can legitimately return none). One attempt; blocking -
        the caller runs it on the taxonomy executor under a slot and a wait
        ceiling."""
        try:
            self._post([{"role": "user", "content": "Reply with OK"}], PROBE_MAX_TOKENS)
        except TaxonomyLLMBusy as e:
            return ProbeResult("busy", str(e))
        except TaxonomyLLMDenied as e:
            return ProbeResult("denied", str(e))
        except TaxonomyLLMNotFound as e:
            return ProbeResult("not_found", self._not_found_message(str(e)))
        except TaxonomyLLMError as e:
            cause = e.__cause__
            detail = error_text(cause) if cause is not None else str(e)
            return ProbeResult("error", f"'{self._model_service}' failed the test call: {detail}")
        return ProbeResult("ok", f"'{self._model_service}' answered the test call.")

    def _not_found_message(self, not_found_text: str) -> str:
        """The gateway also answers 404 for a minute or two after a grant
        (test workspace, 2026-10-18). Ask UC whether the service exists, as the same SP:
        say "not found" only when that GET 404s too."""
        name = self._model_service
        try:
            self._ws.api_client.do("GET", MODEL_SERVICE_GET_PATH.format(name=name))
        except NotFound:
            return not_found_text
        except Exception as e:  # can't tell; don't claim either way
            log.info("model service lookup for '%s' failed: %s", name, e)
            return (
                f"Model service '{name}' was not found, or the app can't use it yet. "
                "If access was just granted, wait a couple of minutes and test again."
            )
        return (
            f"Model service '{name}' exists but the app can't use it yet. If access was just "
            "granted, wait a couple of minutes and test again."
        )

    def complete_text(self, system: str, user: str) -> str:
        return self._chat([{"role": "system", "content": system}, {"role": "user", "content": user}]).strip()

    def complete_json(self, system: str, user: str, model: type[T]) -> T:
        messages = [{"role": "system", "content": system}, {"role": "user", "content": user}]
        last: Exception | None = None
        for _ in range(2):
            text = self._chat(messages)
            try:
                return model.model_validate_json(extract_json(text))
            except (ValueError, ValidationError) as e:
                last = e
                messages = messages + [
                    {"role": "assistant", "content": text},
                    {
                        "role": "user",
                        "content": (
                            f"That reply did not match the required JSON structure: {str(e)[:1500]}\n"
                            "Reply again with ONLY the corrected JSON object - no prose, no code fences."
                        ),
                    },
                ]
        raise TaxonomyLLMError(f"reply did not match the required structure after retry: {str(last)[:500]}")


# The LLM's own client (_workspace_clients.short_budget_workspace_client):
# the per-call timeout and retry budget above. Built lazily and cached, so
# importing this module never touches auth/network.
_LLM_WS: WorkspaceClient | None = None


def llm_workspace_client() -> WorkspaceClient:
    global _LLM_WS
    if _LLM_WS is None:
        _LLM_WS = short_budget_workspace_client(LLM_HTTP_TIMEOUT_SECONDS, LLM_RETRY_TIMEOUT_SECONDS)
    return _LLM_WS


def make_taxonomy_llm(model_service: str) -> TaxonomyLLM:
    """The drafting client for ``model_service`` on the shared LLM workspace client."""
    return TaxonomyLLM(llm_workspace_client(), model_service)
