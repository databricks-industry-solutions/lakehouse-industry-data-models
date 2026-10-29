"""The app's one ``HTTPException`` handler (``error_sanitization``).

Structured ``detail`` dicts keep their shape and their structural keys; only
message-like keys are sanitized. The behaviour is the same with and without
a built UI (``__dist__``), and the SPA fallback answers browser navigations.
"""

import copy
import os
import sys

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "..", "src", "app", "src"))

import pytest
from fastapi import APIRouter, FastAPI, HTTPException
from fastapi.testclient import TestClient

from vibe_modeling.backend.core import _factory, _static
from vibe_modeling.backend.error_sanitization import (
    MAX_APP_MESSAGE_LENGTH,
    MAX_ERROR_LENGTH,
    AppMessage,
    register_error_handlers,
    sanitize_error_detail,
)

_EMAIL = "admin" + "@" + "example.com"
_VOLUME_PATH = "/Volumes/main/_metamodel/assess/runs/2026-10-01"
_WS_HOST = "https://workspace.example.com"

# One entry per structured detail shape the app returns. Every value here is
# structural or a message without sensitive text, so each shape must come
# back byte-for-byte unchanged.
STRUCTURED_DETAILS = {
    "config_missing": {
        "error": "config_missing",
        "missing": [
            {
                "key": "metamodel_catalog",
                "label": "Metamodel catalog",
                "settings_url": "/settings?tab=platform",
            }
        ],
        "message": "Finish setup before running.",
    },
    "admin_help": {
        "error": "admin_help",
        "message": "The assessment job failed. Ask an admin to check the run.",
        "job_url": f"{_WS_HOST}/jobs/42?o=123",
        "run_url": f"{_WS_HOST}/jobs/42/runs/7?o=123",
        "runs_path": _VOLUME_PATH,
        "job_reader": _EMAIL,
    },
    "model_service_refused": {
        "error": "model_service_refused",
        "status": "permission_denied",
        "message": "The app cannot query this model service.",
    },
    "validate_blockers": {
        "blockers": [
            {
                "field_path": "catalog",
                "step_index": 0,
                "message": "Metamodel catalog not configured",
                "severity": "blocker",
            }
        ],
        "warnings": [],
    },
}


def _raising_app(*, spa_fallback=None) -> FastAPI:
    app = FastAPI()

    @app.get("/api/raise/{name}")
    def _raise(name: str):
        raise HTTPException(status_code=409, detail=copy.deepcopy(STRUCTURED_DETAILS[name]))

    @app.get("/api/raise-string")
    def _raise_string():
        raise HTTPException(status_code=400, detail=f"Owner {_EMAIL} cannot read {_VOLUME_PATH}")

    @app.get("/api/raise-message-dict")
    def _raise_message_dict():
        raise HTTPException(
            status_code=409,
            detail={
                "error": "admin_help",
                "message": f"Grant {_EMAIL} READ on {_VOLUME_PATH}",
                "runs_path": _VOLUME_PATH,
                "job_reader": _EMAIL,
                "issues": [{"subject": "s", "message": f"seen by {_EMAIL}"}],
            },
        )

    @app.get("/api/raise-with-headers")
    def _raise_with_headers():
        raise HTTPException(status_code=429, detail="busy", headers={"Retry-After": "30"})

    @app.get("/api/raise-no-body/{status}")
    def _raise_no_body(status: int):
        raise HTTPException(status_code=status, detail="ignored", headers={"ETag": '"v1"'})

    register_error_handlers(app, spa_fallback=spa_fallback)
    return app


class TestSanitizeErrorDetail:
    @pytest.mark.parametrize("name", sorted(STRUCTURED_DETAILS))
    def test_structured_shape_unchanged(self, name):
        detail = copy.deepcopy(STRUCTURED_DETAILS[name])
        assert sanitize_error_detail(detail) == STRUCTURED_DETAILS[name]

    def test_string_detail_is_sanitized(self):
        out = sanitize_error_detail(f"denied for {_EMAIL}")
        assert _EMAIL not in out
        assert "[REDACTED]" in out

    def test_only_message_keys_are_sanitized(self):
        out = sanitize_error_detail(
            {
                "error": "admin_help",
                "message": f"ask {_EMAIL}",
                "detail": f"read {_VOLUME_PATH}",
                "error_message": f"by {_EMAIL}",
                "runs_path": _VOLUME_PATH,
                "job_reader": _EMAIL,
            }
        )
        assert out["error"] == "admin_help"
        assert out["runs_path"] == _VOLUME_PATH
        assert out["job_reader"] == _EMAIL
        for key in ("message", "detail", "error_message"):
            assert "[REDACTED]" in out[key], key
            assert _EMAIL not in out[key] and _VOLUME_PATH not in out[key]

    def test_message_keys_inside_list_items(self):
        out = sanitize_error_detail(
            {"blockers": [{"field_path": _VOLUME_PATH, "message": f"owner {_EMAIL}"}]}
        )
        assert out["blockers"][0]["field_path"] == _VOLUME_PATH
        assert _EMAIL not in out["blockers"][0]["message"]

    def test_long_message_capped(self):
        out = sanitize_error_detail({"error": "x", "message": "m" * 2000})
        assert out["message"].endswith("...")
        assert len(out["message"]) < 2000

    def test_app_message_gets_the_larger_cap(self):
        text = "step " * 200 + f"ask {_EMAIL}"
        assert MAX_ERROR_LENGTH < len(text) < MAX_APP_MESSAGE_LENGTH
        out = sanitize_error_detail(AppMessage(text))
        assert out == "step " * 200 + "ask [REDACTED]"
        assert type(out) is str
        cut = sanitize_error_detail(AppMessage("m" * (MAX_APP_MESSAGE_LENGTH + 10)))
        assert cut == "m" * MAX_APP_MESSAGE_LENGTH + "..."

    def test_plain_string_keeps_the_default_cap(self):
        out = sanitize_error_detail("m" * (MAX_ERROR_LENGTH + 10))
        assert out == "m" * MAX_ERROR_LENGTH + "..."


class TestHandlerRoundTrip:
    """Route-level: the JSON body the browser sees."""

    @pytest.mark.parametrize("name", sorted(STRUCTURED_DETAILS))
    def test_structured_detail_round_trips(self, name):
        resp = TestClient(_raising_app()).get(f"/api/raise/{name}")
        assert resp.status_code == 409
        assert resp.json() == {"detail": STRUCTURED_DETAILS[name]}

    def test_string_detail_redacted(self):
        resp = TestClient(_raising_app()).get("/api/raise-string")
        assert resp.status_code == 400
        detail = resp.json()["detail"]
        assert isinstance(detail, str)
        assert _EMAIL not in detail and _VOLUME_PATH not in detail

    def test_message_in_dict_redacted_structural_kept(self):
        resp = TestClient(_raising_app()).get("/api/raise-message-dict")
        assert resp.status_code == 409
        detail = resp.json()["detail"]
        assert detail["error"] == "admin_help"
        assert detail["runs_path"] == _VOLUME_PATH
        assert detail["job_reader"] == _EMAIL
        assert _EMAIL not in detail["message"]
        assert _EMAIL not in detail["issues"][0]["message"]

    def test_exception_headers_kept(self):
        resp = TestClient(_raising_app()).get("/api/raise-with-headers")
        assert resp.status_code == 429
        assert resp.headers["retry-after"] == "30"
        assert resp.json() == {"detail": "busy"}

    @pytest.mark.parametrize("status", [204, 304])
    def test_no_body_statuses_send_headers_only(self, status):
        resp = TestClient(_raising_app()).get(f"/api/raise-no-body/{status}")
        assert resp.status_code == status
        assert resp.content == b""
        assert resp.headers["etag"] == '"v1"'
        assert "content-length" not in resp.headers


@pytest.fixture
def built_ui(tmp_path, monkeypatch):
    dist = tmp_path / "__dist__"
    dist.mkdir()
    (dist / "index.html").write_text("<html><body>spa</body></html>")
    monkeypatch.setattr(_factory, "dist_dir", dist)
    monkeypatch.setattr(_static, "dist_dir", dist)
    return dist


@pytest.fixture
def no_built_ui(tmp_path, monkeypatch):
    missing = tmp_path / "missing_dist"
    monkeypatch.setattr(_factory, "dist_dir", missing)
    monkeypatch.setattr(_static, "dist_dir", missing)
    return missing


def _factory_client() -> TestClient:
    api = APIRouter(prefix="/api")

    @api.get("/xerr/admin-help")
    def _admin_help():
        raise HTTPException(status_code=409, detail=copy.deepcopy(STRUCTURED_DETAILS["admin_help"]))

    @api.get("/xerr/config-missing")
    def _config_missing():
        raise HTTPException(
            status_code=422, detail=copy.deepcopy(STRUCTURED_DETAILS["config_missing"])
        )

    @api.get("/xerr/string")
    def _string():
        raise HTTPException(status_code=400, detail=f"denied for {_EMAIL}")

    return TestClient(_factory.create_app(routers=[api]))


class TestFactoryWiring:
    """``create_app`` installs the one handler with or without ``__dist__``,
    so the response does not depend on handler registration order."""

    @pytest.mark.parametrize("ui", ["built_ui", "no_built_ui"])
    def test_structured_details_round_trip(self, ui, request):
        request.getfixturevalue(ui)
        client = _factory_client()
        resp = client.get("/api/xerr/admin-help")
        assert resp.status_code == 409
        assert resp.json() == {"detail": STRUCTURED_DETAILS["admin_help"]}
        resp = client.get("/api/xerr/config-missing")
        assert resp.status_code == 422
        assert resp.json() == {"detail": STRUCTURED_DETAILS["config_missing"]}

    @pytest.mark.parametrize("ui", ["built_ui", "no_built_ui"])
    def test_string_detail_sanitized(self, ui, request):
        request.getfixturevalue(ui)
        resp = _factory_client().get("/api/xerr/string")
        assert resp.status_code == 400
        assert _EMAIL not in resp.json()["detail"]

    @pytest.mark.parametrize("ui", ["built_ui", "no_built_ui"])
    def test_unknown_api_path_is_json_404(self, ui, request):
        request.getfixturevalue(ui)
        resp = _factory_client().get("/api/xerr/nope", headers={"accept": "text/html"})
        assert resp.status_code == 404
        assert resp.json() == {"detail": "Not Found"}

    def test_page_navigation_serves_spa(self, built_ui):
        resp = _factory_client().get("/businesses/b1/runs", headers={"accept": "text/html"})
        assert resp.status_code == 200
        assert "spa" in resp.text

    def test_missing_asset_is_404_not_spa(self, built_ui):
        resp = _factory_client().get("/assets/missing.js", headers={"accept": "text/html"})
        assert resp.status_code == 404
        assert "spa" not in resp.text

    def test_non_html_request_is_404_not_spa(self, built_ui):
        resp = _factory_client().get("/businesses/b1", headers={"accept": "application/json"})
        assert resp.status_code == 404
        assert resp.json() == {"detail": "Not Found"}

    def test_no_spa_without_built_ui(self, no_built_ui):
        resp = _factory_client().get("/businesses/b1", headers={"accept": "text/html"})
        assert resp.status_code == 404
        assert resp.json() == {"detail": "Not Found"}
