"""Shared next-vibes ingestion helper + industry-download parity
(an internal tracker item).

The industry download never materialized next_vibes.txt into structured
``VibeInput(agent_next_vibe)`` rows. The fix extracts a module-level
``ingest_next_vibes`` helper, migrates the two route siblings onto it, and adds
the download call site. These tests lock the behavior per entry point and add a
drift alarm so no site can silently drop the materialize call.
"""

from __future__ import annotations

import inspect
import os
import sys
from unittest.mock import MagicMock

from sqlmodel import Session, select

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "..", "src", "app", "src"))

from vibe_modeling.backend import model_sync as ms
from vibe_modeling.backend.db_models import (
    Business,
    ModelVersion,
    Sector,
    VibeInput,
)
from vibe_modeling.backend.model_sync import ModelSyncService, ingest_next_vibes
from vibe_modeling.backend.models import VibeInputOrigin
from vibe_modeling.backend.routes import businesses as businesses_route
from vibe_modeling.backend.routes import import_root as import_root_route
from vibe_modeling.backend.services import industry_download

# A real-shaped next_vibes.txt: one SA finding + one PRIORITY directive → 2
# structured findings.
NEXT_VIBES_TXT = (
    "**Model Quality Score: 76/100**\n\n"
    "**Static Analysis Findings (1 actionable):**\n"
    "  - [SA:denormalized_natural_key] Domain 'sales' table 'orders' drifts\n\n"
    "**PRIORITY 1 - remove_fk: sales.orders** - remove the stale FK on orders\n\n"
    "Deterministic score: 76/100\n"
)

MODEL = {"domains": [
    {"name": "sales", "division": "", "description": "", "database_name": "",
     "references": "", "products": [
        {"product": "orders", "primary_key": "order_id", "attributes": [
            {"attribute": "order_id", "type": "BIGINT", "description": "",
             "foreign_key_to": "", "business_glossary_term": "", "tags": "",
             "value_regex": "", "references": ""},
        ]},
     ]},
]}


def _ws_with_next_vibes(version_dir: str, txt: str = NEXT_VIBES_TXT) -> MagicMock:
    """Fake ws whose files.download serves next_vibes.txt at the real
    ``{version_dir}/vibes/next_vibes.txt`` source layout, else raises."""
    ws = MagicMock()

    def download(path):
        if path == f"{version_dir}/vibes/next_vibes.txt":
            resp = MagicMock()
            resp.contents.read.return_value = txt.encode()
            return resp
        raise FileNotFoundError(path)

    ws.files.download.side_effect = download
    return ws


def _seed_version(session) -> tuple[str, str]:
    b = Business(name="Ingest Corp")
    session.add(b)
    session.flush()
    mv = ModelVersion(business_id=b.id, version=1, status="completed", scope="ecm")
    session.add(mv)
    session.flush()
    ModelSyncService(session).sync_from_model_json(mv.id, MODEL)
    session.flush()
    return b.id, mv.id


class TestIngestNextVibesHelper:
    def test_materializes_rows_from_txt(self, engine):
        version_dir = "/Volumes/cat/_metamodel/vol_root/business/ingest_corp/ecm_v1"
        ws = _ws_with_next_vibes(version_dir)
        with Session(engine) as session:
            biz_id, vid = _seed_version(session)
            n = ingest_next_vibes(
                ws, session, version_dir=version_dir,
                version_id=vid, business_id=biz_id,
            )
            session.commit()
            assert n == 2
            rows = session.exec(
                select(VibeInput).where(
                    VibeInput.business_id == biz_id,
                    VibeInput.origin == VibeInputOrigin.AGENT_NEXT_VIBE.value,
                )
            ).all()
            assert len(rows) == 2

    def test_absent_artifact_returns_zero(self, engine):
        ws = MagicMock()
        ws.files.download.side_effect = FileNotFoundError("nope")
        with Session(engine) as session:
            biz_id, vid = _seed_version(session)
            assert ingest_next_vibes(
                ws, session, version_dir="/Volumes/x", version_id=vid, business_id=biz_id,
            ) == 0

    def test_idempotent_no_duplicate_rows(self, engine):
        version_dir = "/Volumes/cat/_metamodel/vol_root/business/ingest_corp/ecm_v1"
        ws = _ws_with_next_vibes(version_dir)
        with Session(engine) as session:
            biz_id, vid = _seed_version(session)
            first = ingest_next_vibes(
                ws, session, version_dir=version_dir, version_id=vid, business_id=biz_id)
            second = ingest_next_vibes(
                ws, session, version_dir=version_dir, version_id=vid, business_id=biz_id)
            session.commit()
            assert first == 2
            assert second == 0  # uuid5-keyed upsert: no new rows
            rows = session.exec(
                select(VibeInput).where(VibeInput.business_id == biz_id)
            ).all()
            assert len(rows) == 2

    def test_path_match_real_source_layout(self, engine):
        """The loader resolves next_vibes.txt at the source-relative
        ``vibes/next_vibes.txt`` layout the download materializes to."""
        version_dir = "/Volumes/cat/vol_root/biz/ecm_v1"
        ws = _ws_with_next_vibes(version_dir)
        payload, path = ms.load_next_vibes_from_root(ws, version_dir)
        assert payload is not None
        assert path == f"{version_dir}/vibes/next_vibes.txt"
        assert "vibes/next_vibes.txt" in ms.NEXT_VIBES_TXT_RELATIVE_PATHS[0]


class TestIngestContract:
    """Primary lock: the three module-level sites call ingest_next_vibes.
    Drift alarm: ingest_next_vibes and _capture_run_metadata both reference
    materialize_next_vibe_inputs, so no site can silently drop the call."""

    def test_module_sites_call_ingest_next_vibes(self):
        # download_industry_model is top-level; the two route sites live in
        # nested handler functions, so lock at module-source granularity.
        assert "ingest_next_vibes(" in inspect.getsource(
            industry_download.download_industry_model
        )
        from vibe_modeling.backend.services import dialog_import

        assert "ingest_next_vibes(" in inspect.getsource(dialog_import.finish_dialog_import)
        for mod in (import_root_route, businesses_route):
            assert "finish_dialog_import(" in inspect.getsource(mod), (
                f"{mod.__name__} must index through finish_dialog_import"
            )

    def test_drift_alarm_materialize_referenced(self):
        assert "materialize_next_vibe_inputs" in inspect.getsource(ms.ingest_next_vibes)
        assert "materialize_next_vibe_inputs" in inspect.getsource(
            ModelSyncService._capture_run_metadata
        )


class _FakeConnector:
    def __init__(self):
        self._model = {"model": {
            "type": "business", "name": "Retail Ind", "version": "v1_ecm",
            "description": "", "domains": MODEL["domains"],
        }}

    def fetch_model_json(self, industry_id, model_id):
        import json
        return json.dumps(self._model)

    def fetch_artifacts(self, industry_id, model_id):
        from vibe_modeling.backend.sources import ModelArtifact, TargetKind
        return [
            ModelArtifact(name="model.json", target_kind=TargetKind.MODEL_JSON,
                          path="retail/v1/ecm/model.json", size=10),
            ModelArtifact(name="next_vibes.txt", target_kind=TargetKind.VIBES,
                          path="retail/v1/ecm/vibes/next_vibes.txt", size=10),
        ]

    def _fetch_raw(self, path):
        return NEXT_VIBES_TXT if path.endswith("next_vibes.txt") else f"bytes::{path}"


class TestDownloadNextVibesParity:
    def test_download_materializes_next_vibe_inputs(self, engine, config, monkeypatch):
        from vibe_modeling.backend.services.industry_download import download_industry_model

        conn = _FakeConnector()
        monkeypatch.setattr(industry_download, "build_source_connector", lambda *a, **k: conn)

        with Session(engine) as session:
            sector = Sector(name="Retail", short_name="retail")
            session.add(sector)
            session.commit()
            session.refresh(sector)
            sid = sector.id

        # ws.files.download serves next_vibes.txt at whatever version_dir the
        # download computes (it ends in vibes/next_vibes.txt), else raises.
        ws = MagicMock()

        def download(path):
            if path.endswith("/vibes/next_vibes.txt"):
                resp = MagicMock()
                resp.contents.read.return_value = NEXT_VIBES_TXT.encode()
                return resp
            raise FileNotFoundError(path)

        ws.files.download.side_effect = download
        ws.files.upload.return_value = None
        ws.files.list_directory_contents.return_value = []

        with Session(engine) as session:
            result = download_industry_model(
                session, ws, config=config,
                sector_id=sid, industry_id="retail", model_id="v1_ecm",
            )
            rows = session.exec(
                select(VibeInput).where(
                    VibeInput.origin == VibeInputOrigin.AGENT_NEXT_VIBE.value,
                )
            ).all()
            assert len(rows) == 2, "download must materialize the next-vibe backlog"
            assert result.version_id is not None
