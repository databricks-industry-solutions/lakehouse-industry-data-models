"""Tests for _roles.py — RBAC role resolution from workspace groups."""

import os
import subprocess
import sys

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "..", "src", "app", "src"))

import pytest
from unittest.mock import MagicMock, patch

from fastapi import HTTPException

import vibe_modeling.backend.core._roles as _roles_mod
from vibe_modeling.backend.core._roles import (
    UserRole,
    _resolve_from_scim,
    resolve_user_role,
    require_admin,
    require_business_admin,
    require_modeler,
    require_modeler_declared,
    require_viewer_declared,
)


# ---------------------------------------------------------------------------
# UserRole enum
# ---------------------------------------------------------------------------

# ---------------------------------------------------------------------------
# SCIM resolution
# ---------------------------------------------------------------------------

def _mock_user(user_id: str = "12345", groups: list[str] | None = None) -> MagicMock:
    """Mock SCIM user as returned by ws.users.list (with groups inline)."""
    u = MagicMock()
    u.id = user_id
    if groups is not None:
        u.groups = [MagicMock(display=name) for name in groups]
    else:
        u.groups = []
    return u


class TestResolveFromScim:
    def test_app_admin(self):
        ws = MagicMock()
        ws.users.list.return_value = [_mock_user(groups=["vibe-app-admins"])]
        assert _resolve_from_scim(ws, "alice") == UserRole.APP_ADMIN

    def test_business_admin(self):
        ws = MagicMock()
        ws.users.list.return_value = [_mock_user(groups=["vibe-business-admins"])]
        assert _resolve_from_scim(ws, "bob") == UserRole.BUSINESS_ADMIN

    def test_modeler(self):
        ws = MagicMock()
        ws.users.list.return_value = [_mock_user(groups=["vibe-modelers"])]
        assert _resolve_from_scim(ws, "carol") == UserRole.MODELER

    def test_no_matching_group_returns_viewer(self):
        ws = MagicMock()
        ws.users.list.return_value = [_mock_user(groups=["unrelated-group"])]
        assert _resolve_from_scim(ws, "dave") == UserRole.VIEWER

    def test_no_groups_returns_viewer(self):
        ws = MagicMock()
        ws.users.list.return_value = [_mock_user(groups=[])]
        assert _resolve_from_scim(ws, "eve") == UserRole.VIEWER

    def test_highest_privilege_wins(self):
        """When user is in multiple groups, highest-privilege role is returned."""
        ws = MagicMock()
        ws.users.list.return_value = [_mock_user(groups=["vibe-modelers", "vibe-app-admins"])]
        assert _resolve_from_scim(ws, "frank") == UserRole.APP_ADMIN

    def test_scim_error_returns_viewer(self):
        ws = MagicMock()
        ws.users.list.side_effect = RuntimeError("SCIM unavailable")
        assert _resolve_from_scim(ws, "grace") == UserRole.VIEWER

    def test_group_with_no_display_name_ignored(self):
        ws = MagicMock()
        user = _mock_user()
        user.groups = [MagicMock(display=None)]
        ws.users.list.return_value = [user]
        assert _resolve_from_scim(ws, "hank") == UserRole.VIEWER

    def test_user_not_found_returns_viewer(self):
        ws = MagicMock()
        ws.users.list.return_value = []
        assert _resolve_from_scim(ws, "unknown") == UserRole.VIEWER


# ---------------------------------------------------------------------------
# resolve_user_role dependency
# ---------------------------------------------------------------------------

class TestResolveUserRole:
    def _make_request(self, cached_role=None, user_name="alice"):
        request = MagicMock()
        request.state = MagicMock(spec=[])  # empty spec = no pre-set attrs
        if cached_role is not None:
            setattr(request.state, f"_user_role_{user_name}", cached_role)
        ws = MagicMock()
        request.app.state.workspace_client = ws
        return request, ws

    def test_rbac_disabled_returns_app_admin(self):
        """When RBAC is disabled, all users get APP_ADMIN regardless of groups."""
        request, _ = self._make_request()
        headers = MagicMock()
        headers.user_email = "anyone@example.com"
        headers.user_name = "Anyone"
        with patch.object(_roles_mod, "RBAC_ENABLED", False):
            assert resolve_user_role(request, headers) == UserRole.APP_ADMIN

    def test_rbac_env_var_is_ignored(self):
        """Roles stay off even when VIBE_MODELING_RBAC_ENABLED is set true (fresh interpreter, real import)."""
        src = os.path.join(os.path.dirname(__file__), "..", "..", "src", "app", "src")
        probe = (
            "from unittest.mock import MagicMock\n"
            "import vibe_modeling.backend.core._roles as r\n"
            "h = MagicMock(user_email='anyone@example.com', user_name='Anyone')\n"
            "print(r.RBAC_ENABLED, r.resolve_user_role(MagicMock(), h).value)\n"
        )
        env = {**os.environ, "VIBE_MODELING_RBAC_ENABLED": "true", "PYTHONPATH": src}
        out = subprocess.run([sys.executable, "-c", probe], env=env, capture_output=True, text=True, check=True)
        assert out.stdout.split() == ["False", UserRole.APP_ADMIN.value]

    @patch.object(_roles_mod, "RBAC_ENABLED", True)
    def test_no_user_name_returns_app_admin(self):
        request, _ = self._make_request()
        headers = MagicMock()
        headers.user_email = None
        headers.user_name = None
        assert resolve_user_role(request, headers) == UserRole.APP_ADMIN

    @patch.object(_roles_mod, "RBAC_ENABLED", True)
    def test_empty_user_name_returns_app_admin(self):
        request, _ = self._make_request()
        headers = MagicMock()
        headers.user_email = ""
        headers.user_name = ""
        assert resolve_user_role(request, headers) == UserRole.APP_ADMIN

    @patch.object(_roles_mod, "RBAC_ENABLED", True)
    def test_returns_cached_role(self):
        request, _ = self._make_request(cached_role=UserRole.MODELER, user_name="alice@example.com")
        headers = MagicMock()
        headers.user_email = "alice@example.com"
        headers.user_name = "Alice"
        assert resolve_user_role(request, headers) == UserRole.MODELER

    @patch.object(_roles_mod, "RBAC_ENABLED", True)
    def test_queries_scim_and_caches(self):
        request, ws = self._make_request(user_name="alice@example.com")
        ws.users.list.return_value = [_mock_user(groups=["vibe-business-admins"])]
        headers = MagicMock()
        headers.user_email = "alice@example.com"
        headers.user_name = "Alice"

        role = resolve_user_role(request, headers)
        assert role == UserRole.BUSINESS_ADMIN
        assert getattr(request.state, "_user_role_alice@example.com") == UserRole.BUSINESS_ADMIN


# ---------------------------------------------------------------------------
# Permission guards
# ---------------------------------------------------------------------------

class TestPermissionGuards:
    """One test per guard, covering the privilege boundary in both directions."""

    def test_require_admin_boundary(self):
        assert require_admin(UserRole.APP_ADMIN) == UserRole.APP_ADMIN
        for role in (UserRole.BUSINESS_ADMIN, UserRole.MODELER, UserRole.VIEWER):
            with pytest.raises(HTTPException) as ei:
                require_admin(role)
            assert ei.value.status_code == 403

    def test_require_business_admin_boundary(self):
        for role in (UserRole.APP_ADMIN, UserRole.BUSINESS_ADMIN):
            assert require_business_admin(role) == role
        for role in (UserRole.MODELER, UserRole.VIEWER):
            with pytest.raises(HTTPException) as ei:
                require_business_admin(role)
            assert ei.value.status_code == 403

    def test_require_modeler_boundary(self):
        for role in (UserRole.APP_ADMIN, UserRole.BUSINESS_ADMIN, UserRole.MODELER):
            assert require_modeler(role) == role
        with pytest.raises(HTTPException) as ei:
            require_modeler(UserRole.VIEWER)
        assert ei.value.status_code == 403


class TestDeclaredGuards:
    """Declared guards pass everyone until VIBE_INPUT_ROLE_GUARDS_ENFORCED is True."""

    def test_modeler_declared_passes_viewer_and_logs_while_unenforced(self, caplog):
        with patch.object(_roles_mod, "VIBE_INPUT_ROLE_GUARDS_ENFORCED", False):
            with caplog.at_level("DEBUG", logger=_roles_mod.__name__):
                assert require_modeler_declared(UserRole.VIEWER) == UserRole.VIEWER
        assert "would refuse role viewer (needs modeler)" in caplog.text

    def test_modeler_declared_matches_require_modeler_when_enforced(self):
        with patch.object(_roles_mod, "VIBE_INPUT_ROLE_GUARDS_ENFORCED", True):
            for role in (UserRole.APP_ADMIN, UserRole.BUSINESS_ADMIN, UserRole.MODELER):
                assert require_modeler_declared(role) == role
            with pytest.raises(HTTPException) as ei:
                require_modeler_declared(UserRole.VIEWER)
        assert ei.value.status_code == 403
        assert ei.value.detail == "Modeler access required"

    def test_viewer_declared_passes_every_role_when_enforced(self):
        with patch.object(_roles_mod, "VIBE_INPUT_ROLE_GUARDS_ENFORCED", True):
            for role in UserRole:
                assert require_viewer_declared(role) == role

    def test_vibe_input_guards_are_not_enforced_in_this_release(self):
        """Turning enforcement on is a deliberate, reviewed change: update this
        test, INSTALL.md and docs/conventions.md with it."""
        assert _roles_mod.VIBE_INPUT_ROLE_GUARDS_ENFORCED is False

    def test_declared_guards_carry_their_role(self):
        assert require_modeler_declared.declared_min_role == UserRole.MODELER
        assert require_viewer_declared.declared_min_role == UserRole.VIEWER
        assert _roles_mod.declared_role(UserRole.BUSINESS_ADMIN).declared_min_role == UserRole.BUSINESS_ADMIN
