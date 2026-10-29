from __future__ import annotations

from typing import TypeAlias
from ._defaults import (
    ConfigDependency,
    ClientDependency,
    UserWorkspaceClientDependency,
    OptionalUserWorkspaceClientDependency,
)
from ._headers import HeadersDependency
from ._identity import UserIdentityDependency
from .lakebase import LakebaseDependency
from ._roles import (
    RequireAdmin,
    RequireBusinessAdmin,
    RequireModeler,
    RequireModelerDeclared,
    RequireViewerDeclared,
    UserRole,
    UserRoleDependency,
)
from ._tracker import TrackerDependency


class Dependencies:
    """FastAPI dependency injection shorthand for route handler parameters."""

    Client: TypeAlias = ClientDependency
    """Databricks WorkspaceClient using app-level service principal credentials.
    Recommended usage: `ws: Dependencies.Client`"""

    UserClient: TypeAlias = UserWorkspaceClientDependency
    """WorkspaceClient authenticated on behalf of the current user via OBO token.
    Requires the X-Forwarded-Access-Token header.
    Recommended usage: `user_ws: Dependencies.UserClient`"""

    OptionalUserClient: TypeAlias = OptionalUserWorkspaceClientDependency
    """OBO WorkspaceClient when an X-Forwarded-Access-Token is present, else None.
    For read-only endpoints that degrade gracefully (e.g. anonymous source
    browsing) instead of failing when no OBO token is forwarded.
    Recommended usage: `user_ws: Dependencies.OptionalUserClient`"""

    Config: TypeAlias = ConfigDependency
    """Application configuration loaded from environment variables.
    Recommended usage: `config: Dependencies.Config`"""

    Headers: TypeAlias = HeadersDependency
    """Databricks Apps HTTP headers for the current request.
    Recommended usage: `headers: Dependencies.Headers`"""

    UserIdentity: TypeAlias = UserIdentityDependency
    """Canonical caller identity (email first, then preferred username).
    `"local-dev"` without identity headers outside the Apps runtime; 401 inside it.
    Recommended usage: `user_id: Dependencies.UserIdentity`"""

    Session: TypeAlias = LakebaseDependency
    """Lakebase session dependency.
    Recommended usage: `session: Dependencies.Session`"""

    Tracker: TypeAlias = TrackerDependency
    """Progress tracker for managing per-run async polling tasks.
    Recommended usage: `tracker: Dependencies.Tracker`"""

    Role: TypeAlias = UserRoleDependency
    """Resolved user role for the current request.
    Recommended usage: `role: Dependencies.Role`"""

    AdminOnly: TypeAlias = RequireAdmin
    """Guard: requires APP_ADMIN role. Returns UserRole on success, 403 otherwise.
    Recommended usage: `_role: Dependencies.AdminOnly`"""

    BusinessAdminOnly: TypeAlias = RequireBusinessAdmin
    """Guard: requires APP_ADMIN or BUSINESS_ADMIN. Returns UserRole on success, 403 otherwise.
    Recommended usage: `_role: Dependencies.BusinessAdminOnly`"""

    ModelerOnly: TypeAlias = RequireModeler
    """Guard: requires APP_ADMIN, BUSINESS_ADMIN, or MODELER. Returns UserRole on success, 403 otherwise.
    Recommended usage: `_role: Dependencies.ModelerOnly`"""

    ModelerDeclared: TypeAlias = RequireModelerDeclared
    """Declared guard for MODELER: passes every caller while
    ``_roles.VIBE_INPUT_ROLE_GUARDS_ENFORCED`` is False, acts as ``ModelerOnly`` when it is True.
    Recommended usage: `_role: Dependencies.ModelerDeclared`"""

    ViewerDeclared: TypeAlias = RequireViewerDeclared
    """Declared guard for VIEWER (read routes): names the route's role for the RBAC
    coverage test; every role passes it.
    Recommended usage: `_role: Dependencies.ViewerDeclared`"""
