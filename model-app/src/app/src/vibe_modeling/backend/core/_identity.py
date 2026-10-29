"""Canonical user identity derived from the Databricks Apps forwarded headers.

This module is the only place that decides header precedence for "who is the
caller". Identity is email first (`DatabricksAppsHeaders.user_email`), then
the preferred username (`user_name`); usernames alone are not trusted to be
unique, so the email wins whenever both are present.

Every backend site that needs the caller's identity goes through these
helpers. Direct `headers.user_email` / `headers.user_name` reads elsewhere
under `backend/` are drift-locked by `tests/test_app/test_identity_drift_lock.py`.
"""

from __future__ import annotations

from typing import Annotated, TypeAlias

from fastapi import Depends

from ..models import CurrentUserEmailOut, CurrentUserOut
from ._errors import identity_missing_error
from ._headers import (
    DatabricksAppsHeaders,
    HeadersDependency,
    _is_databricks_app_runtime,
)

LOCAL_DEV_IDENTITY = "local-dev"
"""Fixed identity for requests without user headers outside the Apps runtime."""

ANONYMOUS_IDENTITY = "anonymous"
"""Display label for callers without identity (logs, actor fields, profile)."""

NO_IDENTITY_MESSAGE = "Your request carries no user identity. Open the app through its Databricks Apps URL."
NO_EMAIL_MESSAGE = (
    "This needs your workspace email, and your request carries none. "
    "Open the app through its Databricks Apps URL."
)


def _stripped(value: str | None) -> str:
    return (value or "").strip()


def current_user_identity(headers: DatabricksAppsHeaders) -> str | None:
    """Return the caller's identity: email, else preferred username, else None.

    Whitespace is stripped; case is preserved.
    """
    return _stripped(headers.user_email) or _stripped(headers.user_name) or None


def actor_label(headers: DatabricksAppsHeaders) -> str:
    """The caller's identity for logs and actor fields, or `"anonymous"`."""
    return current_user_identity(headers) or ANONYMOUS_IDENTITY


def require_user_identity(headers: HeadersDependency) -> str:
    """FastAPI dependency: the caller's identity, never a shared bucket.

    Inside the Databricks Apps runtime a request without identity headers is
    rejected with 401 ``identity_missing``. Outside it (local dev, tests) such a request maps to
    the fixed `"local-dev"` identity. With the forwarded-header gate off,
    `LOCAL_DEV_USER` is already substituted into the headers upstream, so it
    becomes the identity here.
    """
    identity = current_user_identity(headers)
    if identity:
        return identity
    if _is_databricks_app_runtime():
        raise identity_missing_error(NO_IDENTITY_MESSAGE)
    return LOCAL_DEV_IDENTITY


UserIdentityDependency: TypeAlias = Annotated[str, Depends(require_user_identity)]


def current_user_email(headers: DatabricksAppsHeaders) -> str | None:
    """Return the caller's workspace email, or None when the header is absent.

    For callers that need a workspace path (`/Workspace/Users/<email>/...`),
    where a preferred username is not a valid substitute.
    """
    return _stripped(headers.user_email) or None


def require_user_email(headers: DatabricksAppsHeaders) -> str:
    """The caller's workspace email, or 401 ``identity_missing`` when it is
    missing. There is no `"local-dev"` fallback outside the Apps runtime: it
    is not a workspace user."""
    email = current_user_email(headers)
    if email:
        return email
    raise identity_missing_error(NO_EMAIL_MESSAGE)


def current_user_profile(headers: DatabricksAppsHeaders) -> CurrentUserOut:
    """Build the `/current-user` payload, with an anonymous fallback."""
    identity = current_user_identity(headers)
    if not identity:
        return CurrentUserOut(
            user_name=ANONYMOUS_IDENTITY, display_name="Anonymous User", emails=[]
        )
    email = _stripped(headers.user_email)
    return CurrentUserOut(
        user_name=identity,
        display_name=_stripped(headers.user_name) or identity,
        emails=[CurrentUserEmailOut(value=email)] if email else [],
    )
