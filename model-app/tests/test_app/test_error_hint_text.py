"""User-facing error text survives the app's ``HTTPException`` handler.

The handler redacts paths and emails in messages. Static hint text (a
``/Volumes/<catalog>/...`` template, the home-folder rule) must reach the
user whole, and a separator after a redacted path must survive. Messages
that would name a path the user typed or must act on leave the path out.
Each case runs through the real handler: route-level where the route is
cheap to reach, handler-level for the rest.
"""

import os
import sys
from unittest.mock import MagicMock

import pytest
from databricks.sdk.errors import NotFound
from fastapi import FastAPI, HTTPException
from fastapi.testclient import TestClient

sys.path.insert(0, os.path.dirname(__file__))

from test_artifact_content import _seed_run_and_artifact  # noqa: E402
from vibe_modeling.backend.assessment.handoff import scope_message, user_home  # noqa: E402
from vibe_modeling.backend.error_sanitization import (  # noqa: E402
    register_error_handlers,
    sanitize_error_message,
)

_EMAIL = "jane.doe" + "@" + "corp.example.com"
_REDACTED = "[REDACTED]"

VOLUME_HINT = "Volume path must include /Volumes/<catalog>/<schema>/<volume>"
DRILL_HINT = "Drill into a volume using /Volumes/<catalog>/<schema>/<volume>"
IMPORT_PATH_HINT = (
    "volume_path must be an absolute UC Volume path ending in "
    "/model.json (e.g. /Volumes/<catalog>/_metamodel/vol_root/"
    "business/<name>/v<N>_<scope>/model.json) with no `..` segments."
)
HOME_HINT = (
    "Hand-off folder must be a subfolder of your own home folder "
    "(/Workspace/Users/<your email>/)."
)


def _raise_app(detail) -> TestClient:
    app = FastAPI()

    @app.get("/api/raise")
    def _raise():
        raise HTTPException(status_code=400, detail=detail)

    register_error_handlers(app)
    return TestClient(app)


def _round_trip(detail):
    resp = _raise_app(detail).get("/api/raise")
    assert resp.status_code == 400
    return resp.json()["detail"]


# (message as the route builds it, message the user must see)
HANDLER_CASES = {
    "volume_browse_short": (VOLUME_HINT, VOLUME_HINT),
    "volume_browse_drill": (DRILL_HINT, DRILL_HINT),
    "import_from_volume_hint": (IMPORT_PATH_HINT, IMPORT_PATH_HINT),
    "handoff_home_folder": (
        "Hand-off folder must be a subfolder of your own home folder "
        f"({user_home('<your email>')}/).",
        HOME_HINT,
    ),
    "handoff_write_failure": (
        "Hand-off failed writing to the chosen folder: PERMISSION_DENIED: no write access",
        "Hand-off failed writing to the chosen folder: PERMISSION_DENIED: no write access",
    ),
    "artifact_read": (
        "Could not read artifact file 'erd.md': volume unreachable",
        "Could not read artifact file 'erd.md': volume unreachable",
    ),
    "import_analyze_invalid_json": (
        "The file at volume_path is not valid JSON: Expecting value: line 1 column 1 (char 0). "
        "The import endpoint expects a model.json file produced by the vibe agent.",
        "The file at volume_path is not valid JSON: Expecting value: line 1 column 1 (char 0). "
        "The import endpoint expects a model.json file produced by the vibe agent.",
    ),
    "import_read_failure": (
        "Could not read the file at volume_path: 404 Not Found",
        "Could not read the file at volume_path: 404 Not Found",
    ),
    "volume_prefix_rule": (
        "Volume path must start with /Volumes/.",
        "Volume path must start with /Volumes/.",
    ),
}


class TestHandlerRoundTrip:
    @pytest.mark.parametrize("name", sorted(HANDLER_CASES))
    def test_string_detail_reaches_the_user_intact(self, name):
        built, shown = HANDLER_CASES[name]
        assert _round_trip(built) == shown

    @pytest.mark.parametrize("name", sorted(HANDLER_CASES))
    def test_message_key_reaches_the_user_intact(self, name):
        built, shown = HANDLER_CASES[name]
        detail = _round_trip({"error": "admin_help", "message": built})
        assert detail == {"error": "admin_help", "message": shown}

    def test_scope_message_keeps_its_hint_and_redacts_the_sdk_path(self):
        sdk_error = f"403 scope missing for /Workspace/Users/{_EMAIL}/handoff"
        built = scope_message("your workspace folder", sdk_error)
        detail = _round_trip({"error": "admin_help", "message": built})
        hint = built.split(" Error: ")[0]
        assert detail["message"] == f"{hint} Error: 403 scope missing for {_REDACTED}"
        assert "'workspace.workspace' scope." in detail["message"]


class TestPathRedactionBoundaries:
    """A redacted path keeps the punctuation around it."""

    @pytest.mark.parametrize("text, expected", [
        ("Could not read /Volumes/c/s/v/a.json: NotFound", f"Could not read {_REDACTED}: NotFound"),
        ("folder (/Workspace/Users/x/y).", f"folder ({_REDACTED})."),
        ("at /Volumes/c/s/v/model.json.", f"at {_REDACTED}."),
        ("'/Workspace/Users/x/nb' is missing", f"'{_REDACTED}' is missing"),
        ("a /Volumes/c/s/v, then b", f"a {_REDACTED}, then b"),
        ("read dbfs:/tmp/x; retry", f"read {_REDACTED}; retry"),
        ("<a href=/Volumes/c/s/v>", f"<a href={_REDACTED}>"),
    ])
    def test_separator_survives(self, text, expected):
        assert sanitize_error_message(text) == expected

    @pytest.mark.parametrize("text", [
        "Use /Volumes/<catalog>/<schema>/<volume>",
        "Use /Workspace/Users/<your email>/vibe-assess",
        "must start with /Volumes/.",
        "starts with '/Volumes/'",
    ])
    def test_templates_are_not_paths(self, text):
        assert sanitize_error_message(text) == text


class TestRoutes:
    """The same strings, produced by the routes."""

    def test_volume_browse_short_path(self, client):
        resp = client.get("/api/uc/volumes/browse", params={"path": "/Volumes/main"})
        assert resp.status_code == 400
        assert resp.json() == {"detail": VOLUME_HINT}

    def test_volume_browse_catalog_schema_extra(self, client):
        resp = client.get("/api/uc/volumes/browse", params={"path": "main/sch/extra"})
        assert resp.status_code == 400
        assert resp.json() == {"detail": DRILL_HINT}

    def test_import_from_volume_bad_path(self, client, seed_business):
        resp = client.post(
            f"/api/businesses/{seed_business}/versions/import-from-volume",
            params={"volume_path": "/Volumes/c/s/v/notmodel.txt"},
        )
        assert resp.status_code == 422
        assert resp.json() == {"detail": IMPORT_PATH_HINT}

    def test_unreadable_notebook_names_no_path(self, client, mock_ws):
        mock_ws.workspace.get_status.side_effect = NotFound("not found")
        mock_ws.config.client_id = "1111-2222"
        notebook = f"/Workspace/Users/{_EMAIL}/agent/vibe_agent"
        resp = client.put("/api/config/agent", json={"notebook_path": notebook})
        assert resp.status_code == 400
        detail = resp.json()["detail"]
        assert detail.startswith(
            "The app service principal '1111-2222' cannot access the agent notebook "
            "at the configured path. Either the path is wrong,"
        )
        assert detail.endswith("Original error: not found")
        assert _REDACTED not in detail

    def test_artifact_read_failure_names_the_file(self, client_with_agent, mock_ws, seed_business, engine):
        run_id, artifact_id = _seed_run_and_artifact(engine, seed_business, "/Volumes/c/s/v/erd.md")
        mock_ws.files.download.side_effect = RuntimeError("volume unreachable")
        resp = client_with_agent.get(
            f"/api/businesses/{seed_business}/runs/{run_id}/artifacts/{artifact_id}/content"
        )
        assert resp.status_code == 502
        assert resp.json() == {"detail": "Could not read artifact file 'erd.md': volume unreachable"}

    def test_import_analyze_invalid_json(self, client, mock_ws):
        download = MagicMock()
        download.contents.read.return_value = b"{not json"
        mock_ws.files.download.return_value = download
        resp = client.post("/api/import/analyze", json={"volume_path": "/Volumes/c/s/v/model.json"})
        assert resp.status_code == 400
        detail = resp.json()["detail"]
        assert detail.startswith("The file at volume_path is not valid JSON: ")
        assert detail.endswith("The import endpoint expects a model.json file produced by the vibe agent.")
        assert _REDACTED not in detail

    def test_import_analyze_read_failure(self, client, mock_ws):
        mock_ws.files.download.side_effect = RuntimeError("404 Not Found")
        resp = client.post("/api/import/analyze", json={"volume_path": "/Volumes/c/s/v/model.json"})
        assert resp.status_code == 400
        assert resp.json() == {"detail": "Could not read the file at volume_path: 404 Not Found"}
