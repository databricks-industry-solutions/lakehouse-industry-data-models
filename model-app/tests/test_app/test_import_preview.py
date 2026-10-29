"""Tests for the import preview endpoint + the unified next-vibes lookup.

Covers:

- ``GET /api/import/preview`` walks a Volume folder and reports
  model.json presence, next-vibes status, and companion artifacts.
- The unified :func:`load_next_vibes_from_root` is the single source
  of truth for the four-way lookup (.json + .txt × root + vibes/).
- Regression: the import flow now picks up ``next_vibes.txt`` (agent
  v0.6.1+), not just ``next_vibes.json`` — before unification, the
  inline lookup in ``businesses.py`` only tried .json so .txt-only
  imports silently dropped the next-vibes payload.
"""
import json
from unittest.mock import MagicMock

import pytest

from vibe_modeling.backend.model_sync import load_next_vibes_from_root

from ._fake_volume import FakeVolume


# --- Volume layout fixtures ---


def _entry(name: str, *, is_dir: bool = False, size: int | None = None):
    e = MagicMock()
    e.name = name
    e.is_directory = is_dir
    if size is not None:
        e.file_size = size
    else:
        # Drop the attribute so getattr returns None.
        del e.file_size
    return e


def _wire_volume(mock_ws, layout: dict[str, list]):
    """Wire ``mock_ws.files.list_directory_contents`` against a directory tree.

    ``layout`` maps absolute folder path → list of entry mocks. Folders
    not in the map raise (mirrors the SDK's behaviour for missing dirs).
    """
    def _list(path: str):
        if path in layout:
            return iter(layout[path])
        raise FileNotFoundError(path)
    mock_ws.files.list_directory_contents.side_effect = _list


def _wire_downloads(mock_ws, files: dict[str, bytes | str]):
    """Wire ``mock_ws.files.download`` against an absolute-path → content map.

    Missing paths raise (mirrors the SDK's 404).
    """
    def _dl(path: str):
        if path not in files:
            raise FileNotFoundError(path)
        body = files[path]
        if isinstance(body, str):
            body = body.encode("utf-8")
        resp = MagicMock()
        resp.contents.read.return_value = body
        return resp
    mock_ws.files.download.side_effect = _dl


# --- load_next_vibes_from_root unit tests ---


class TestLoadNextVibesFromRoot:
    """The free-function helper is the canonical 4-way lookup."""

    def test_prefers_vibes_subfolder_json(self):
        ws = MagicMock()
        _wire_downloads(ws, {
            "/V/root/vibes/next_vibes.json": '{"src": "vibes_json"}',
            "/V/root/next_vibes.json": '{"src": "root_json"}',
            "/V/root/vibes/next_vibes.txt": "Model Quality Score: 80/100",
        })
        payload, path = load_next_vibes_from_root(ws, "/V/root")
        assert payload == {"src": "vibes_json"}
        assert path == "/V/root/vibes/next_vibes.json"

    def test_falls_back_to_root_json(self):
        ws = MagicMock()
        _wire_downloads(ws, {
            "/V/root/next_vibes.json": '{"src": "root_json"}',
        })
        payload, path = load_next_vibes_from_root(ws, "/V/root")
        assert payload == {"src": "root_json"}
        assert path == "/V/root/next_vibes.json"

    def test_falls_back_to_vibes_txt(self):
        ws = MagicMock()
        _wire_downloads(ws, {
            "/V/root/vibes/next_vibes.txt": (
                "Model Quality Score: 80/100\n"
                "**PRIORITY 1 — remove_fk: a.b** — drop a.b.c"
            ),
        })
        payload, path = load_next_vibes_from_root(ws, "/V/root")
        assert payload is not None
        assert path == "/V/root/vibes/next_vibes.txt"
        # Parsed shape carries structured findings, no instructions blob.
        assert "business_context" not in payload
        findings = payload["_next_vibe_metadata"]["findings"]
        assert len(findings) == 1
        assert findings[0]["category"] == "priority_remediation"
        assert findings[0]["target"] == "a.b"

    def test_returns_none_when_missing(self):
        ws = MagicMock()
        _wire_downloads(ws, {})
        payload, path = load_next_vibes_from_root(ws, "/V/root")
        assert payload is None
        assert path is None

    def test_no_ws_returns_none(self):
        payload, path = load_next_vibes_from_root(None, "/V/root")
        assert payload is None and path is None

    def test_empty_root_returns_none(self):
        payload, path = load_next_vibes_from_root(MagicMock(), "")
        assert payload is None and path is None


# --- Preview endpoint tests ---


@pytest.fixture
def preview_layout_full(mock_ws):
    """A 'full' import folder: model.json + next_vibes.txt + companions."""
    _wire_volume(mock_ws, {
        "/Volumes/c/s/vol/imports/v1": [
            _entry("model.json", size=2048),
            _entry("readme.md", size=512),
            _entry("vibes", is_dir=True),
            _entry("diagram", is_dir=True),
            _entry("docs", is_dir=True),
        ],
        "/Volumes/c/s/vol/imports/v1/vibes": [
            _entry("next_vibes.txt", size=300),
            _entry("vibe_notes.md", size=100),
        ],
        "/Volumes/c/s/vol/imports/v1/diagram": [
            _entry("schema.dbml", size=400),
        ],
        "/Volumes/c/s/vol/imports/v1/docs": [
            _entry("glossary.xlsx", size=8192),
        ],
    })
    return mock_ws


@pytest.fixture
def preview_layout_json_only(mock_ws):
    """next_vibes.json present, no .txt."""
    _wire_volume(mock_ws, {
        "/Volumes/c/s/vol/imports/v1": [
            _entry("model.json", size=1000),
            _entry("vibes", is_dir=True),
        ],
        "/Volumes/c/s/vol/imports/v1/vibes": [
            _entry("next_vibes.json", size=200),
        ],
    })
    return mock_ws


@pytest.fixture
def preview_layout_missing_next_vibes(mock_ws):
    """model.json present but no next_vibes anywhere — warning case."""
    _wire_volume(mock_ws, {
        "/Volumes/c/s/vol/imports/v1": [
            _entry("model.json", size=1000),
            _entry("readme.md", size=200),
        ],
    })
    return mock_ws


@pytest.fixture
def preview_layout_no_model_json(mock_ws):
    """Folder exists but model.json missing — preview should block import."""
    _wire_volume(mock_ws, {
        "/Volumes/c/s/vol/imports/v1": [
            _entry("readme.md", size=200),
        ],
    })
    return mock_ws


class TestImportPreviewEndpoint:
    PATH_FILE = "/Volumes/c/s/vol/imports/v1/model.json"
    PATH_FOLDER = "/Volumes/c/s/vol/imports/v1"

    def test_full_layout_with_txt(self, client, preview_layout_full):
        r = client.get(
            f"/api/import/preview?volume_path={self.PATH_FILE}",
        )
        assert r.status_code == 200, r.text
        data = r.json()
        assert data["model_json_found"]
        assert data["next_vibes_status"] == "txt"
        assert data["next_vibes_path"] == (
            "/Volumes/c/s/vol/imports/v1/vibes/next_vibes.txt"
        )
        # readme + vibe_notes.md + dbml + xlsx = 4 companions (model.json is
        # NOT counted in the companion list).
        assert data["total_artifact_count"] == 4
        types = {a["artifact_type"] for a in data["companion_artifacts"]}
        # Path-specific typing fired for vibes_doc and dbml.
        assert "readme" in types
        assert "vibes_doc" in types
        assert "dbml" in types
        assert "excel" in types
        # next_vibes.txt is NOT surfaced as a companion artifact — it's
        # represented via next_vibes_status instead. Otherwise we'd
        # double-count it.
        paths = [a["path"] for a in data["companion_artifacts"]]
        assert "/Volumes/c/s/vol/imports/v1/vibes/next_vibes.txt" not in paths
        # Sizes propagate when SDK surfaces them.
        readme = next(
            a for a in data["companion_artifacts"]
            if a["artifact_type"] == "readme"
        )
        assert readme["size_bytes"] == 512

    def test_json_preferred_over_txt(self, client, preview_layout_json_only):
        r = client.get(
            f"/api/import/preview?volume_path={self.PATH_FOLDER}",
        )
        assert r.status_code == 200, r.text
        data = r.json()
        assert data["next_vibes_status"] == "json"
        assert data["next_vibes_path"].endswith("/vibes/next_vibes.json")

    def test_missing_next_vibes_renders_missing_status(
        self, client, preview_layout_missing_next_vibes,
    ):
        r = client.get(
            f"/api/import/preview?volume_path={self.PATH_FILE}",
        )
        assert r.status_code == 200, r.text
        data = r.json()
        assert data["model_json_found"]
        assert data["next_vibes_status"] == "missing"
        assert data["next_vibes_path"] is None

    def test_no_model_json_flagged(self, client, preview_layout_no_model_json):
        r = client.get(
            f"/api/import/preview?volume_path={self.PATH_FOLDER}",
        )
        assert r.status_code == 200, r.text
        data = r.json()
        assert data["model_json_found"] is False
        # next_vibes status still computed independently.
        assert data["next_vibes_status"] == "missing"

    def test_missing_volume_path_rejected(self, client):
        r = client.get("/api/import/preview?volume_path=")
        assert r.status_code == 400


# --- Regression: execute_import now picks up next_vibes.txt ---


class TestExecuteImportPicksUpNextVibesTxt:
    """Before the unify, businesses.py only tried .json — .txt was dropped.

    This test exercises ``POST /businesses/{id}/import/execute`` against
    a Volume layout where ONLY ``next_vibes.txt`` exists and asserts that
    structured agent next-vibe ``VibeInput`` rows are materialized after the
    import (the blob is gone).
    """

    def test_execute_import_materializes_next_vibes_from_txt(
        self, client_with_agent, mock_ws, seed_business, engine,
    ):
        from sqlmodel import Session, select
        from vibe_modeling.backend.db_models import (
            VibeInput,
            VibeInputContextLink,
        )
        from vibe_modeling.backend.models import VibeInputOrigin

        model_json = json.dumps({
            "type": "business",
            "name": "test corp",
            "industry_alignment": "Retail",
            "version": "v1_mvm",
            "description": "",
            "domains": [
                {
                    "name": "sales",
                    "products": [
                        {
                            "name": "orders",
                            "primary_key": "id",
                            "attributes": [
                                {"name": "id", "column_name": "id",
                                 "type": "BIGINT", "description": ""},
                            ],
                        }
                    ],
                }
            ],
        })
        next_vibes_txt = (
            "Model Quality Score: 76/100\n"
            "**PRIORITY 1 — remove_fk: customer.profile** — drop x"
        )
        # The import copies the folder into the app's folder and reads the
        # next vibes from the copy.
        volume = FakeVolume(mock_ws)
        volume.put("/Volumes/c/s/vol/v1/model.json", model_json)
        volume.put("/Volumes/c/s/vol/v1/vibes/next_vibes.txt", next_vibes_txt)

        r = client_with_agent.post(
            f"/api/businesses/{seed_business}/import/execute",
            json={
                "volume_path": "/Volumes/c/s/vol/v1/model.json",
                "accept_business_mismatch": True,
            },
        )
        assert r.status_code == 200, r.text
        version_id = r.json()["version_id"]

        with Session(engine) as s:
            rows = s.exec(
                select(VibeInput)
                .join(
                    VibeInputContextLink,
                    VibeInputContextLink.input_id == VibeInput.id,
                )
                .where(
                    VibeInputContextLink.version_id == version_id,
                    VibeInput.origin == VibeInputOrigin.AGENT_NEXT_VIBE.value,
                )
            ).all()
            assert len(rows) == 1
            assert rows[0].text.startswith("remove_fk for customer.profile")
