"""Role-based access control — resolves user roles from Databricks workspace groups.

Three workspace groups define permissions:
  - vibe-app-admins: full access including settings and group management
  - vibe-business-admins: manage businesses, approve syncs, manage model versions
  - vibe-modelers: navigate, run vibes, provide feedback

With RBAC on, users in none of these groups resolve to ``VIEWER``: read-only,
except that the 16 ``vibe_inputs`` write routes still accept them until
``VIBE_INPUT_ROLE_GUARDS_ENFORCED`` is turned on (see the two switches below).

The role resolver queries SCIM group membership via the SP client on first
request and caches the result for the session duration (per-request scope
in FastAPI means per HTTP request, which is fine — no mid-request user switch).

Two kinds of guard:
  - Enforced guards (``require_admin``, ``require_business_admin``,
    ``require_modeler``) answer 403 when the caller's role is below theirs.
  - Declared guards (``declared_role``) name the role a route needs but answer
    403 only while ``VIBE_INPUT_ROLE_GUARDS_ENFORCED`` is True. While it is
    False they let every caller through and log at debug level when a caller
    would have been refused. The ``vibe_inputs`` routes use them until role
    assignment exists; setting the constant to True enforces them with no
    route change.

The two switches combine:
  - ``RBAC_ENABLED`` False (hard-off, see below): every caller resolves to
    ``APP_ADMIN``, so every guard passes whatever the constant says.
  - RBAC on, constant False: enforced guards refuse by group role; declared
    guards pass and log.
  - RBAC on, constant True: every guard refuses a caller whose group role
    is below its own.
  - RBAC on and the request carries no user identity header (local dev, no
    proxy): the caller resolves to ``APP_ADMIN``, so every guard passes
    whatever the constant says. Behind the Apps proxy the header is always set.
"""

from __future__ import annotations

import logging
from enum import Enum
from collections.abc import Callable
from typing import Annotated, TypeAlias

from databricks.sdk import WorkspaceClient
from fastapi import Depends, HTTPException, Request

from ._headers import DatabricksAppsHeaders, get_databricks_headers
from ._identity import current_user_identity

logger = logging.getLogger(__name__)

# Group-based roles are disabled pending a product redesign: every caller resolves to APP_ADMIN, and no
# environment variable turns them on. The role code below stays for that redesign.
RBAC_ENABLED = False

# Whether ``declared_role`` guards refuse callers below their role (see the
# module docstring). False until role assignment is implemented.
VIBE_INPUT_ROLE_GUARDS_ENFORCED = False


class UserRole(str, Enum):
    """Application roles, ordered by privilege level."""
    APP_ADMIN = "app_admin"
    BUSINESS_ADMIN = "business_admin"
    MODELER = "modeler"
    VIEWER = "viewer"


# Account-level group names → role mapping
_GROUP_ROLE_MAP = {
    "vibe-app-admins": UserRole.APP_ADMIN,
    "vibe-business-admins": UserRole.BUSINESS_ADMIN,
    "vibe-modelers": UserRole.MODELER,
}


def resolve_user_role(
    request: Request,
    headers: Annotated[DatabricksAppsHeaders, Depends(get_databricks_headers)],
) -> UserRole:
    """Resolve the current user's highest-privilege role.

    When RBAC is disabled (default), all users get APP_ADMIN.
    When enabled, queries SCIM group membership via the SP client.
    """
    if not RBAC_ENABLED:
        return UserRole.APP_ADMIN

    # Email first (matches SCIM userName), then preferred username
    user_name = current_user_identity(headers)
    if not user_name:
        logger.debug("No user identity in headers, defaulting to APP_ADMIN (dev mode)")
        return UserRole.APP_ADMIN

    # Check request-scoped cache
    cache_key = f"_user_role_{user_name}"
    cached = getattr(request.state, cache_key, None)
    if cached is not None:
        return cached

    # Query SCIM via SP client
    ws: WorkspaceClient = request.app.state.workspace_client
    role = _resolve_from_scim(ws, user_name)

    # Cache on request state
    setattr(request.state, cache_key, role)
    return role


def _resolve_from_scim(ws: WorkspaceClient, user_name: str) -> UserRole:
    """Query workspace groups to determine the user's role.

    Uses users.list with attributes="id,userName,groups" so group memberships
    are returned inline — avoids users.get() which requires workspace admin.
    """
    try:
        users = list(ws.users.list(
            filter=f'userName eq "{user_name}"',
            attributes="id,userName,groups",
        ))
        if not users:
            logger.warning(f"SCIM user not found: {user_name}")
            return UserRole.VIEWER

        user_groups = set()
        for g in users[0].groups or []:
            if g.display:
                user_groups.add(g.display)

        # Return highest-privilege matching role
        for group_name, role in _GROUP_ROLE_MAP.items():
            if group_name in user_groups:
                return role

        return UserRole.VIEWER
    except Exception as e:
        logger.warning(f"SCIM group lookup failed for {user_name}: {e}")
        return UserRole.VIEWER


UserRoleDependency: TypeAlias = Annotated[UserRole, Depends(resolve_user_role)]


# ---------------------------------------------------------------------------
# Permission guards — use as FastAPI dependencies
# ---------------------------------------------------------------------------

_ROLE_RANK = {
    UserRole.VIEWER: 0,
    UserRole.MODELER: 1,
    UserRole.BUSINESS_ADMIN: 2,
    UserRole.APP_ADMIN: 3,
}

_DENIED_DETAIL = {
    UserRole.APP_ADMIN: "App admin access required",
    UserRole.BUSINESS_ADMIN: "Business admin access required",
    UserRole.MODELER: "Modeler access required",
}


def _has_role(role: UserRole, min_role: UserRole) -> bool:
    return _ROLE_RANK[role] >= _ROLE_RANK[min_role]


def _deny(min_role: UserRole) -> HTTPException:
    return HTTPException(status_code=403, detail=_DENIED_DETAIL[min_role])


def require_admin(role: UserRoleDependency) -> UserRole:
    """Guard: only app admins."""
    if not _has_role(role, UserRole.APP_ADMIN):
        raise _deny(UserRole.APP_ADMIN)
    return role


def require_business_admin(role: UserRoleDependency) -> UserRole:
    """Guard: app admins or business admins."""
    if not _has_role(role, UserRole.BUSINESS_ADMIN):
        raise _deny(UserRole.BUSINESS_ADMIN)
    return role


def require_modeler(role: UserRoleDependency) -> UserRole:
    """Guard: app admins, business admins, or modelers."""
    if not _has_role(role, UserRole.MODELER):
        raise _deny(UserRole.MODELER)
    return role


def declared_role(min_role: UserRole) -> Callable[[UserRole], UserRole]:
    """Build a declared guard for ``min_role`` (see the module docstring).

    The guard resolves the caller's role through ``resolve_user_role`` and
    returns it. It refuses a caller below ``min_role`` only while
    ``VIBE_INPUT_ROLE_GUARDS_ENFORCED`` is True; otherwise it logs the would-be
    refusal at debug level. ``declared_min_role`` on the guard lets the RBAC
    coverage test tell declared guards from enforced ones.
    """

    def guard(role: UserRoleDependency) -> UserRole:
        if not _has_role(role, min_role):
            if VIBE_INPUT_ROLE_GUARDS_ENFORCED:
                raise _deny(min_role)
            logger.debug(
                "Declared guard would refuse role %s (needs %s); not enforced",
                role.value,
                min_role.value,
            )
        return role

    guard.__name__ = f"declared_{min_role.value}"
    guard.declared_min_role = min_role  # type: ignore[attr-defined]
    return guard


require_modeler_declared = declared_role(UserRole.MODELER)
require_viewer_declared = declared_role(UserRole.VIEWER)


# Dependency type aliases for use in route signatures
RequireAdmin: TypeAlias = Annotated[UserRole, Depends(require_admin)]
RequireBusinessAdmin: TypeAlias = Annotated[UserRole, Depends(require_business_admin)]
RequireModeler: TypeAlias = Annotated[UserRole, Depends(require_modeler)]
RequireModelerDeclared: TypeAlias = Annotated[UserRole, Depends(require_modeler_declared)]
RequireViewerDeclared: TypeAlias = Annotated[UserRole, Depends(require_viewer_declared)]
