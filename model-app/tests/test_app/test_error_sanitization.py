"""Tests for error_sanitization.py — sensitive data stripping from error messages."""

import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "..", "src", "app", "src"))

import pytest
from vibe_modeling.backend.error_sanitization import sanitize_error_message, MAX_ERROR_LENGTH


class TestSanitizeWorkspacePaths:
    def test_strips_workspace_path(self):
        msg = "File not found: /Workspace/Users/admin@company.com/notebook.py"
        result = sanitize_error_message(msg)
        assert "/Workspace/" not in result
        assert "@" not in result

    def test_strips_volumes_path(self):
        msg = "Cannot read /Volumes/catalog/_metamodel/vol_root/model.json"
        result = sanitize_error_message(msg)
        assert "/Volumes/" not in result

    def test_strips_dbfs_path(self):
        msg = "Error accessing dbfs:/mnt/data/secret_file.csv"
        result = sanitize_error_message(msg)
        assert "dbfs:/" not in result


class TestSanitizeCredentials:
    def test_strips_email(self):
        msg = "Permission denied for user admin@databricks.com on resource"
        result = sanitize_error_message(msg)
        assert "admin@databricks.com" not in result
        assert "[REDACTED]" in result

    def test_strips_dapi_token(self):
        # Build fake token dynamically to avoid tripping secret scanners
        fake_token = "dapi" + "1234567890abcdef" * 2 + "12"
        msg = f"Invalid token: {fake_token}"
        result = sanitize_error_message(msg)
        assert fake_token not in result

    def test_strips_bearer_token(self):
        msg = "Auth failed with Bearer eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.payload"
        result = sanitize_error_message(msg)
        assert "eyJhbGciOi" not in result

    def test_strips_long_hex_token(self):
        msg = f"Token {'a' * 48} is expired"
        result = sanitize_error_message(msg)
        assert "a" * 48 not in result


class TestMessageCap:
    def test_caps_at_max_length(self):
        msg = "x" * 1000
        result = sanitize_error_message(msg)
        assert len(result) == MAX_ERROR_LENGTH + 3  # +3 for "..."
        assert result.endswith("...")

    def test_short_message_unchanged(self):
        msg = "Simple error"
        result = sanitize_error_message(msg)
        assert result == "Simple error"


class TestPreservesNonSensitive:
    def test_preserves_sql_error(self):
        msg = "SQL error: TABLE_OR_VIEW_NOT_FOUND: Table `catalog`._metamodel._business"
        result = sanitize_error_message(msg)
        assert "TABLE_OR_VIEW_NOT_FOUND" in result

    def test_preserves_normal_path_text(self):
        msg = "Column 'name' is required but was not provided"
        result = sanitize_error_message(msg)
        assert result == msg


class TestMultiplePatterns:
    def test_strips_multiple_sensitive_items(self):
        fake_token = "dapi" + "0123456789abcdef" * 2 + "01"
        msg = (
            f"Error for user admin@corp.com accessing /Workspace/Users/admin/nb.py "
            f"with token {fake_token}"
        )
        result = sanitize_error_message(msg)
        assert "admin@corp.com" not in result
        assert "/Workspace/" not in result
        assert fake_token not in result
        assert result.count("[REDACTED]") >= 3


_HOST = "instance-1a2b3c4d.database.cloud.databricks.com"
_SQL = "INSERT INTO runs (id, business_id, version_id) VALUES (%(id)s, %(business_id)s, %(version_id)s)"
_PARAMS = {"id": "run-secret-1", "business_id": "biz-secret-2", "version_id": "ver-secret-3"}


def _leaky_errors():
    from psycopg import errors as pg_errors
    from requests.exceptions import ConnectionError as RequestsConnectionError
    from sqlalchemy.exc import IntegrityError, OperationalError

    return {
        "integrity": IntegrityError(
            _SQL, _PARAMS,
            pg_errors.ForeignKeyViolation('insert on table "runs" violates foreign key constraint "runs_version_id_fkey"'),
        ),
        "operational": OperationalError(
            "SELECT 1", None,
            Exception(f'connection to server at "{_HOST}" (10.0.0.7), port 5432 failed: Connection refused'),
        ),
        "psycopg": pg_errors.OperationalError(f'connection to server at "{_HOST}", port 5432 failed'),
        "requests": RequestsConnectionError(f"HTTPSConnectionPool(host='{_HOST}', port=443): Max retries exceeded"),
    }


def _error_client(exc):
    from fastapi import FastAPI
    from fastapi.testclient import TestClient

    from vibe_modeling.backend.core._request_id import RequestIdMiddleware
    from vibe_modeling.backend.error_sanitization import register_error_handlers

    app = FastAPI()
    app.add_middleware(RequestIdMiddleware)
    register_error_handlers(app)

    @app.get("/boom")
    def boom():
        raise exc

    return TestClient(app, raise_server_exceptions=False)


class TestUnhandledDatabaseErrors:
    """E-11: an unhandled database or connection error reached the client with
    the driver text, the SQL statement, its bound parameters and the host."""

    @pytest.mark.parametrize("kind", ["integrity", "operational", "psycopg", "requests"])
    def test_body_has_a_fixed_text_and_no_driver_detail(self, kind):
        from vibe_modeling.backend.error_sanitization import CONNECTION_ERROR_MESSAGE, DB_ERROR_MESSAGE

        resp = _error_client(_leaky_errors()[kind]).get("/boom", headers={"x-request-id": "req-abc-123"})
        assert resp.status_code == 500
        fixed = CONNECTION_ERROR_MESSAGE if kind == "requests" else DB_ERROR_MESSAGE
        assert resp.json() == {"detail": f"{fixed} Reference: req-abc-123"}
        assert resp.headers["x-request-id"] == "req-abc-123"
        for leaked in (_HOST, "INSERT", "[SQL", "[parameters", "run-secret-1", "biz-secret-2", "runs_version_id_fkey"):
            assert leaked not in resp.text

    def test_reference_is_the_minted_id_when_the_client_sent_none(self):
        resp = _error_client(_leaky_errors()["integrity"]).get("/boom")
        reference = resp.headers["x-request-id"]
        assert reference and resp.json()["detail"].endswith(f"Reference: {reference}")

    def test_full_error_is_logged_server_side(self, caplog):
        with caplog.at_level("ERROR"):
            resp = _error_client(_leaky_errors()["integrity"]).get("/boom", headers={"x-request-id": "req-abc-123"})
        assert resp.json()["detail"].endswith("Reference: req-abc-123")
        unhandled = [r for r in caplog.records if r.getMessage().startswith("Unhandled IntegrityError")]
        assert len(unhandled) == 1
        assert "req-abc-123" in unhandled[0].getMessage()
        assert "run-secret-1" in str(unhandled[0].exc_info[1])

    def test_other_unhandled_errors_keep_their_sanitized_text(self):
        resp = _error_client(ValueError("bad value for /Workspace/Users/a@b.com/x")).get("/boom")
        assert resp.status_code == 500
        assert resp.json() == {"detail": "bad value for [REDACTED]"}
        assert _error_client(RuntimeError()).get("/boom").json() == {"detail": "Internal server error"}

    def test_detail_helper_returns_the_fixed_text_without_a_request(self):
        from vibe_modeling.backend.error_sanitization import DB_ERROR_MESSAGE, unhandled_error_detail

        assert unhandled_error_detail(_leaky_errors()["integrity"]) == DB_ERROR_MESSAGE
