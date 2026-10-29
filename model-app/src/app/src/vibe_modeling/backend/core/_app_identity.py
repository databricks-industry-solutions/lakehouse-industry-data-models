"""The app service principal's own identity and workspace home.

One home for "who is the app": the bundled agent notebook and the assessment
job's workspace folder both live under the app SP's home, Settings shows the
app's application id in the reader setup steps, and the catalog capability
check (``core/_uc_privileges``) reads privileges for that id and counts
ownership by the app's groups.
"""

from __future__ import annotations

import logging
import time

from databricks.sdk import WorkspaceClient

logger = logging.getLogger(__name__)

# Process-wide cache of the app's own application id (it cannot change while running).
_APP_ID_CACHE: dict[str, str] = {}
# The app's group names with their expiry (``time.monotonic()``): groups can
# change while the app runs, so they are read again after GROUPS_TTL_SECONDS,
# the same lifetime as the capability check's positive results.
GROUPS_TTL_SECONDS = 600.0
_APP_GROUPS_CACHE: dict[str, tuple[float, frozenset[str]]] = {}


def _user_name_of(me) -> str:
    user_name = getattr(me, "user_name", None) or ""
    if not isinstance(user_name, str) or not user_name:
        raise RuntimeError("Databricks returned a user with no user_name; cannot resolve the app's identity.")
    return user_name


def _remember_groups(me) -> frozenset[str]:
    groups = getattr(me, "groups", None) or []
    value = frozenset(g.display for g in groups if isinstance(getattr(g, "display", None), str) and g.display)
    _APP_GROUPS_CACHE["groups"] = (time.monotonic() + GROUPS_TTL_SECONDS, value)
    return value


def app_sp_user_name(ws: WorkspaceClient) -> str:
    """The app SP's ``user_name`` (its application id). Raises ``RuntimeError`` when empty."""
    return _user_name_of(ws.current_user.me())


def _home_of(user_name: str) -> str:
    return f"/Users/{user_name}"


def app_sp_home(ws: WorkspaceClient) -> str:
    """The app SP's workspace home, ``/Users/<user_name>``."""
    return _home_of(app_sp_user_name(ws))


def app_sp_home_for_display(ws: WorkspaceClient) -> str:
    """``app_sp_home`` from the process-cached application id; ``""`` on any error (display only)."""
    app_id = app_application_id(ws)
    return _home_of(app_id) if app_id else ""


def app_application_id(ws: WorkspaceClient) -> str:
    """``app_sp_user_name``, cached for the process; ``""`` on any error.

    For display, and as the principal of the read-only capability checks
    (which answer "couldn't check" on ``""``)."""
    if "id" in _APP_ID_CACHE:
        return _APP_ID_CACHE["id"]
    try:
        me = ws.current_user.me()
        value = _user_name_of(me)
    except Exception as e:  # fail-soft: display, or a "couldn't check" capability
        logger.warning("Could not resolve the app's application id: %s", e)
        return ""
    _APP_ID_CACHE["id"] = value
    try:
        _remember_groups(me)  # the same ``me()`` answer serves app_group_names
    except Exception:  # noqa: BLE001 - app_group_names reads them again
        logger.debug("Could not cache the app's groups", exc_info=True)
    return value


def app_group_names(ws: WorkspaceClient) -> frozenset[str] | None:
    """Display names of the app SP's direct groups, cached for ``GROUPS_TTL_SECONDS``
    (filled by ``app_application_id``'s ``me()`` call when it runs first); None
    on any error (the caller then treats a group owner as unknown)."""
    cached = _APP_GROUPS_CACHE.get("groups")
    if cached and cached[0] > time.monotonic():
        return cached[1]
    try:
        return _remember_groups(ws.current_user.me())
    except Exception as e:  # fail-soft: an unknown group set only makes group owners unchecked
        logger.warning("Could not read the app's groups: %s", e)
        return None
