"""Forwarded-header handling, with a startup gate to prevent local spoofing.

Databricks Apps runs every request through a reverse proxy that sets these
headers to identify the workspace user:
  - X-Forwarded-Host
  - X-Forwarded-Preferred-Username
  - X-Forwarded-User           (user id)
  - X-Forwarded-Email
  - X-Forwarded-Access-Token   (OBO token)
  - X-Request-Id

In production these come from a trusted proxy. Locally, anything can set them.
A user running the app on their laptop with `curl -H 'X-Forwarded-Email: ...'`
could otherwise impersonate any workspace user, which is exactly the C-08
finding from the recent code review.

The gate (`should_trust_forwarded_headers`) decides per-process at startup
whether to honour the headers:
  - TRUST_FORWARDED_HEADERS=1/true  → honour
  - TRUST_FORWARDED_HEADERS=0/false → ignore (treat user as anonymous, or
    substitute LOCAL_DEV_USER if set)
  - unset → auto-detect: trust ON when running as a Databricks App
    (DATABRICKS_APP_NAME present), OFF otherwise.

When the gate is OFF, the dependency strips every X-Forwarded-* value and
returns an empty `DatabricksAppsHeaders` (with the optional LOCAL_DEV_USER
substituted for user_email/user_name so admin pages still work in dev).
"""

from __future__ import annotations

import logging
import os
from typing import Annotated, TypeAlias
from uuid import UUID

from fastapi import Depends, Header
from pydantic import BaseModel, SecretStr


logger = logging.getLogger(__name__)


_TRUTHY = {"1", "true", "yes", "on"}
_FALSY = {"0", "false", "no", "off", ""}


def databricks_app_name() -> str:
    """The deployed App's resource name (``DATABRICKS_APP_NAME``), ``""`` outside the Apps runtime.

    Not ``AppConfig.app_name``, which is the package name.
    """
    return os.environ.get("DATABRICKS_APP_NAME", "")


def _is_databricks_app_runtime() -> bool:
    """Detect whether the process is running inside the Databricks Apps runtime.

    Databricks Apps injects DATABRICKS_APP_NAME (and DATABRICKS_APP_PORT) into
    the app process. Either is a sufficient signal — DATABRICKS_APP_NAME is
    the conventional one.
    """
    return bool(databricks_app_name())


def should_trust_forwarded_headers() -> bool:
    """Resolve the C-08 gate.

    Explicit TRUST_FORWARDED_HEADERS wins. If unset, default to True when
    running as a Databricks App (the trusted proxy is in front of us), False
    otherwise (local dev / tests).
    """
    raw = os.environ.get("TRUST_FORWARDED_HEADERS")
    if raw is not None:
        v = raw.strip().lower()
        if v in _TRUTHY:
            return True
        if v in _FALSY:
            return False
        logger.warning(
            "TRUST_FORWARDED_HEADERS=%r not recognised; defaulting to OFF.", raw
        )
        return False
    return _is_databricks_app_runtime()


def _local_dev_user() -> str | None:
    """Optional substitute identity used when the gate is OFF.

    Lets local devs run the app with a fake user identity without having to
    spoof headers (which would defeat the gate). Set LOCAL_DEV_USER in the
    process env, e.g. `LOCAL_DEV_USER=alice@example.com`.
    """
    val = os.environ.get("LOCAL_DEV_USER", "").strip()
    return val or None


class DatabricksAppsHeaders(BaseModel):
    """Structured model for Databricks Apps HTTP headers.

    See: https://docs.databricks.com/aws/en/dev-tools/databricks-apps/http-headers
    """

    host: str | None
    user_name: str | None
    user_id: str | None
    user_email: str | None
    request_id: UUID | None
    token: SecretStr | None


def get_databricks_headers(
    host: Annotated[str | None, Header(alias="X-Forwarded-Host")] = None,
    user_name: Annotated[
        str | None, Header(alias="X-Forwarded-Preferred-Username")
    ] = None,
    user_id: Annotated[str | None, Header(alias="X-Forwarded-User")] = None,
    user_email: Annotated[str | None, Header(alias="X-Forwarded-Email")] = None,
    request_id: Annotated[str | None, Header(alias="X-Request-Id")] = None,
    token: Annotated[str | None, Header(alias="X-Forwarded-Access-Token")] = None,
) -> DatabricksAppsHeaders:
    """Extract Databricks Apps headers from the incoming request.

    When `should_trust_forwarded_headers()` returns False the X-Forwarded-*
    headers are dropped — they may be attacker-controlled in non-production
    contexts. LOCAL_DEV_USER, if set, is substituted for user identity so
    local devs can still hit role-gated endpoints.
    """
    if not should_trust_forwarded_headers():
        dev_user = _local_dev_user()
        return DatabricksAppsHeaders(
            host=None,
            user_name=dev_user,
            user_id=None,
            user_email=dev_user,
            request_id=None,
            token=None,
        )

    return DatabricksAppsHeaders(
        host=host,
        user_name=user_name,
        user_id=user_id,
        user_email=user_email,
        request_id=UUID(request_id) if request_id else None,
        token=SecretStr(token) if token else None,
    )


HeadersDependency: TypeAlias = Annotated[
    DatabricksAppsHeaders, Depends(get_databricks_headers)
]
