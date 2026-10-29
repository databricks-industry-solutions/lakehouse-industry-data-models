"""Regression tests for shipped hardening (PLAN #54).

Covers four recently-landed security fixes so subsequent refactors can't
silently re-open them:

  - C-02 — SQL injection via business name on the Delta read paths.
  - C-09 — ``POST /businesses/{id}/seed-model`` admin-only guard.
  - C-10 — ``volume_path`` traversal validation on
    ``POST /businesses/{id}/versions/import-from-volume``.
  - RBAC-on-all-routes — see ``test_rbac_coverage.py`` for the route
    walker; this file covers the per-fix behavioural assertions.

These tests deliberately call the FastAPI app via ``TestClient`` rather
than patching internals — the regression we want to catch is "an attacker
hitting the public endpoint" not "an internal helper".
"""

from __future__ import annotations

import json
import os
import sys
from unittest.mock import MagicMock

sys.path.insert(
    0, os.path.join(os.path.dirname(__file__), "..", "..", "src", "app", "src")
)

import pytest
from fastapi.testclient import TestClient
from sqlmodel import Session

import vibe_modeling.backend.core._roles as _roles_mod
from vibe_modeling.backend.core._roles import (
    UserRole,
    resolve_user_role,
)
from vibe_modeling.backend.core._defaults import (
    _ConfigDependency,
    _WorkspaceClientDependency,
)
from vibe_modeling.backend.core._tracker import _TrackerDependency
from vibe_modeling.backend.core.lakebase import _LakebaseDependency
from vibe_modeling.backend.db_models import Business

sys.path.insert(0, os.path.dirname(__file__))
from _test_app import make_test_app  # noqa: E402


def _make_test_client(
    engine,
    mock_ws,
    config,
    mock_tracker,
    role: UserRole = UserRole.APP_ADMIN,
) -> TestClient:
    """Build a FastAPI TestClient with all routers wired and the user role
    forced. Mirrors conftest.py's `client` fixture but parameterises the
    role so we can exercise the AdminOnly guards from a non-admin user.
    """
    app = make_test_app()

    def override_session():
        with Session(engine) as session:
            yield session

    app.dependency_overrides[_LakebaseDependency.__call__] = override_session
    app.dependency_overrides[_ConfigDependency.__call__] = lambda: config
    app.dependency_overrides[_WorkspaceClientDependency.__call__] = lambda: mock_ws
    app.dependency_overrides[_TrackerDependency.__call__] = lambda: mock_tracker
    # Pin the resolved role — bypasses SCIM lookup so the AdminOnly guard
    # sees exactly what we configured here.
    app.dependency_overrides[resolve_user_role] = lambda: role

    return TestClient(app)


# ---------------------------------------------------------------------------
# C-02 — SQL injection on business name + Delta read paths
# ---------------------------------------------------------------------------


_INJECTION_NAME = "foo'; DROP TABLE businesses;--"
# A name that passes the BusinessIn regex but still contains a single
# quote — the legitimate-but-quoted business case. The regex permits
# apostrophes for names like "Macy's", so this is the *real* injection
# surface for the Delta read paths: a name we accept that escape_sql_literal
# must defang.
_QUOTED_NAME = "O'Brien's Tools"


class TestC02SqlInjectionBusinessName:
    """Two layers of defence are in place against SQL injection via
    ``Business.name``:

      1. Input validation — :class:`BusinessIn` pins ``name`` to a
         regex that excludes the SQL metacharacters used by classic
         injection payloads (``;``, ``--``, ``"``, ``\\``).
      2. SQL escaping — the Delta read paths in ``model_sync.py`` call
         :func:`escape_sql_literal` so the *legitimate* apostrophes
         that the regex *does* permit (e.g. "Macy's") are doubled and
         can't terminate a ``'…'`` literal.

    These tests cover both layers so a future regression in either
    fails loudly.
    """

    def test_pydantic_rejects_classic_injection_payload(self, client):
        """Layer 1 — the pattern on ``BusinessIn.name`` rejects the
        ``foo'; DROP TABLE …;--`` shape outright with a 422."""
        resp = client.post(
            "/api/businesses",
            json={
                "name": _INJECTION_NAME,
                "description": "C-02 regression",
                "industry_alignment": "Retail",
            },
        )
        assert resp.status_code == 422, resp.text
        body = resp.json()
        # Pydantic surfaces the validation in `detail` — assert the
        # offending field is the name (not some unrelated 422).
        assert any(
            "name" in (err.get("loc") or [])
            for err in body.get("detail", [])
        ), body

    def test_pydantic_accepts_legitimate_apostrophe_name(self, client):
        """The pattern intentionally allows apostrophes so business
        names like ``Macy's`` work. This is the input that *exercises*
        the SQL escape — see the next test."""
        resp = client.post(
            "/api/businesses",
            json={
                "name": _QUOTED_NAME,
                "description": "Real-world apostrophe",
                "industry_alignment": "Retail",
            },
        )
        assert resp.status_code == 200, resp.text
        body = resp.json()
        assert body["name"] == _QUOTED_NAME

        # ORM round-trip preserves the bytes (proves the persisted row
        # is uncorrupted; injection of a `--` comment terminator would
        # silently truncate the string in the DB if the ORM weren't
        # using bound parameters).
        bid = body["id"]
        get_resp = client.get(f"/api/businesses/{bid}")
        assert get_resp.status_code == 200
        assert get_resp.json()["name"] == _QUOTED_NAME

    def test_escape_sql_literal_neutralises_apostrophe(self):
        """Layer 2 — the escape helper called on every Delta read path
        doubles embedded single quotes so a name like ``O'Brien's Tools``
        cannot terminate the surrounding ``'…'`` literal."""
        from vibe_modeling.backend.core._names import escape_sql_literal

        out = escape_sql_literal(_QUOTED_NAME)
        assert "''" in out
        # Round-trip: wrapping the escaped form in single quotes equals
        # the escaped form of the input wrapped the same way. (Implicitly
        # verifies the doubling is the only transform on apostrophes.)
        assert f"'{out}'" == "'" + _QUOTED_NAME.replace("'", "''") + "'"
        # Defence-in-depth: backslashes are escaped too (Databricks SQL
        # treats ``\\`` as an escape character inside string literals).
        assert escape_sql_literal("a\\b").count("\\") == 2
        # NUL bytes are stripped so they can't break parsing mid-literal.
        assert "\x00" not in escape_sql_literal("a\x00b")

    def test_model_sync_where_clause_escapes_apostrophes(
        self, engine, mock_ws
    ):
        """End-to-end: drive a Delta query with a name containing a
        legitimate apostrophe and assert the SQL handed to the SDK has
        the apostrophe doubled inside the WHERE clause's quoted literal."""
        from vibe_modeling.backend.model_sync import ModelSyncService

        executed: list[str] = []

        def capture(**kwargs):
            executed.append(kwargs.get("statement", ""))
            result = MagicMock()
            result.status = MagicMock()
            result.status.error = None
            result.status.state = MagicMock(value="SUCCEEDED")
            result.result = MagicMock()
            result.result.data_array = []
            result.manifest = MagicMock()
            result.manifest.schema = MagicMock()
            result.manifest.schema.columns = []
            return result

        mock_ws.statement_execution.execute_statement.side_effect = capture

        with Session(engine) as session:
            sync = ModelSyncService(
                session,
                ws=mock_ws,
                warehouse_id="test-wh",
            )
            sync._query_delta_table(
                catalog="test_catalog",
                schema="_metamodel",
                table="domain",
                business_name=_QUOTED_NAME,
                version="v1",
                model_scope="ecm",
            )

        assert executed, "expected at least one SQL statement"
        for sql in executed:
            escaped = _QUOTED_NAME.replace("'", "''")
            assert escaped in sql, f"escaped name missing from: {sql}"
            # The bare apostrophe form would terminate the WHERE clause
            # literal early. Assert it never appears unescaped — every
            # apostrophe in the SQL is part of a doubled `''` pair.
            #
            # `O'Brien` (single ') as a substring means a regression has
            # let the raw apostrophe through.
            assert "O'Brien's Tools" not in sql, (
                f"unescaped apostrophe leaked into SQL: {sql}"
            )


# ---------------------------------------------------------------------------
# C-09 — seed-model AdminOnly guard
# ---------------------------------------------------------------------------


class TestC09SeedModelAdminGuard:
    """``POST /businesses/{id}/seed-model`` is a dev-only fixture endpoint
    that bypasses the agent pipeline. It must reject every non-admin
    role with 403 — never 200 (privilege escalation), never 401
    (auth-not-required misconfiguration)."""

    @pytest.mark.parametrize(
        "role",
        [UserRole.BUSINESS_ADMIN, UserRole.MODELER, UserRole.VIEWER],
    )
    def test_non_admin_rejected_403(
        self, role, engine, mock_ws, config, mock_tracker, seed_business
    ):
        client = _make_test_client(
            engine, mock_ws, config, mock_tracker, role=role
        )
        resp = client.post(
            f"/api/businesses/{seed_business}/seed-model",
            json={"version": 1, "scope": "ecm", "model_data": {}},
        )
        assert resp.status_code == 403, resp.text
        # 401 (Unauthorized) would mean the route is not behind RBAC at
        # all — assert against it explicitly so a future regression that
        # drops the guard but leaves an auth wall in place still fails.
        assert resp.status_code != 401
        assert resp.status_code != 200

    def test_admin_succeeds(
        self, engine, mock_ws, config, mock_tracker, seed_business
    ):
        client = _make_test_client(
            engine, mock_ws, config, mock_tracker, role=UserRole.APP_ADMIN
        )
        resp = client.post(
            f"/api/businesses/{seed_business}/seed-model",
            json={
                "version": 1,
                "scope": "ecm",
                "model_data": {
                    "domains": [],
                },
            },
        )
        # Either fresh-create (200) or already-exists (200 with status="exists").
        assert resp.status_code == 200, resp.text
        body = resp.json()
        assert body.get("status") in ("created", "exists")

    def test_anonymous_treated_as_admin_in_default_dev_mode(
        self, client, seed_business
    ):
        """Sanity: with the default test config (RBAC disabled), the same
        endpoint succeeds — proves the test harness reflects production
        defaults and isn't hiding a regression by mocking the guard out."""
        resp = client.post(
            f"/api/businesses/{seed_business}/seed-model",
            json={
                "version": 99,
                "scope": "ecm",
                "model_data": {"domains": []},
            },
        )
        assert resp.status_code == 200, resp.text


# ---------------------------------------------------------------------------
# C-10 — volume_path traversal on import-from-volume
# ---------------------------------------------------------------------------


class TestC10VolumePathTraversal:
    """``POST /businesses/{id}/versions/import-from-volume`` validates
    the user-supplied ``volume_path`` to defeat traversal payloads. The
    contract is:

      - Path must start with ``/Volumes/``.
      - Path must end with ``/model.json``.
      - Path must not contain a literal ``..`` segment.
    """

    @pytest.mark.parametrize(
        "bad_path",
        [
            "/Volumes/cat/schema/vol/../../../etc/passwd",
            "/Volumes/cat/../escape/model.json",
            # Trailing-slash variant
            "/Volumes/cat/schema/vol/../model.json",
            # Windows-style — `..\\` survives `.split("/")` as a single
            # segment that does NOT equal "..", so it slips past the
            # current `..` check; we still expect a 422 because the
            # Volume API rejects backslashes via the endswith check
            # (the path won't end in /model.json — it ends in
            # `\\model.json` after a `..\\` segment).
            "/Volumes/cat/schema/vol/..\\..\\etc/passwd",
        ],
    )
    def test_traversal_rejected(self, client, seed_business, bad_path):
        resp = client.post(
            f"/api/businesses/{seed_business}/versions/import-from-volume",
            params={"volume_path": bad_path},
        )
        # 422 — Pydantic-style validation error from the explicit shape
        # check in routes/versions.py. Some bad shapes might 400 if a
        # different layer rejects first; either is acceptable, just not
        # 200 (which would mean the path was honoured).
        assert resp.status_code in (400, 422), resp.text
        assert resp.status_code != 200

    def test_non_volumes_prefix_rejected(self, client, seed_business):
        resp = client.post(
            f"/api/businesses/{seed_business}/versions/import-from-volume",
            params={"volume_path": "/etc/passwd"},
        )
        assert resp.status_code in (400, 422), resp.text

    def test_wrong_extension_rejected(self, client, seed_business):
        resp = client.post(
            f"/api/businesses/{seed_business}/versions/import-from-volume",
            params={
                "volume_path": "/Volumes/cat/schema/vol/some_file.txt"
            },
        )
        assert resp.status_code in (400, 422), resp.text

    def test_valid_path_succeeds(
        self, client, mock_ws, seed_business
    ):
        """Sanity — a clean Volumes URI ending in /model.json is accepted
        by the validation layer (independent of whether the file actually
        exists, which we mock out)."""
        valid_path = (
            "/Volumes/cat/_metamodel/vol_root/business/test/v1_mvm/model.json"
        )
        payload = {
            "type": "business",
            "name": "test",
            "version": "v1_mvm",
            "domains": [
                {
                    "name": "d",
                    "division": "x",
                    "description": "",
                    "database_name": "db",
                    "products": [],
                }
            ],
        }
        resp_dl = MagicMock()
        resp_dl.contents.read.return_value = json.dumps(payload).encode("utf-8")
        mock_ws.files.download.return_value = resp_dl

        resp = client.post(
            f"/api/businesses/{seed_business}/versions/import-from-volume",
            params={"volume_path": valid_path},
        )
        assert resp.status_code == 200, resp.text
