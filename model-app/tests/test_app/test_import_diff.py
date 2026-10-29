"""Story-2 coverage: per-business analyze surfaces digest_diff, and
per-business execute refuses to land an import with field mismatches
unless ``accept_business_mismatch=true`` is passed.
"""

from __future__ import annotations

import json
from unittest.mock import MagicMock

from sqlmodel import Session

from vibe_modeling.backend.db_models import Business, Industry


def _mock_download(mock_ws, content: str):
    resp = MagicMock()
    resp.contents.read.return_value = content.encode("utf-8")
    mock_ws.files.download.return_value = resp


def _payload(*, business_name: str = "Gaming", industry: str = "Gaming") -> dict:
    return {
        "model_requirements": {
            "business_name": business_name,
            "description": "",
        },
        "model": {
            "type": "business",
            "name": business_name,
            "version": "v1_ecm",
            "description": "",
            "industry_alignment": industry,
            "domains": [
                {
                    "name": "ops",
                    "products": [
                        {
                            "name": "matches",
                            "table_name": "matches",
                            "primary_key": "match_id",
                            "attributes": [
                                {
                                    "name": "match_id",
                                    "column_name": "match_id",
                                    "type": "BIGINT",
                                    "description": "",
                                },
                            ],
                        }
                    ],
                }
            ],
        },
    }


def _seed_target_business(engine, name: str, industry_alignment: str) -> str:
    with Session(engine) as s:
        b = Business(name=name, industry_alignment=industry_alignment)
        s.add(b)
        s.commit()
        s.refresh(b)
        return b.id


class TestAnalyzeDiff:
    def test_a_slug_alignment_matches_the_stored_catalog_name(
        self, client_with_agent, mock_ws, engine,
    ):
        """create-by-import stores "Energy - Utilities" for the agent's
        "energy-utilities"; a later per-business import is not a mismatch."""
        with Session(engine) as s:
            ind = Industry(name="Energy - Utilities", short_name="utilities")
            s.add(ind)
            s.flush()
            b = Business(name="Gaming", industry_alignment="Energy - Utilities", industry_id=ind.id)
            s.add(b)
            s.commit()
            biz_id = b.id
        _mock_download(mock_ws, json.dumps(_payload(industry="energy-utilities")))
        r = client_with_agent.post(
            f"/api/businesses/{biz_id}/import/analyze",
            json={"volume_path": "/Volumes/a/b/c.json"},
        )
        assert r.status_code == 200, r.text
        assert r.json()["business_digest_diff"]["mismatch_fields"] == []

    def test_an_alignment_resolving_to_the_business_industry_matches(
        self, client_with_agent, mock_ws, engine,
    ):
        with Session(engine) as s:
            ind = Industry(name="Energy - Utilities", short_name="utilities")
            s.add(ind)
            s.flush()
            b = Business(name="Gaming", industry_alignment="Energy - Utilities", industry_id=ind.id)
            s.add(b)
            s.commit()
            biz_id = b.id
        _mock_download(mock_ws, json.dumps(_payload(industry="UTILITIES")))
        r = client_with_agent.post(
            f"/api/businesses/{biz_id}/import/analyze",
            json={"volume_path": "/Volumes/a/b/c.json"},
        )
        assert r.status_code == 200, r.text
        assert r.json()["business_digest_diff"]["mismatch_fields"] == []

    def test_analyze_surfaces_mismatch_when_business_name_differs(
        self, client_with_agent, mock_ws, engine,
    ):
        biz_id = _seed_target_business(
            engine, "Gaming Reference Model", "Gaming",
        )
        _mock_download(mock_ws, json.dumps(_payload(business_name="Gaming")))
        r = client_with_agent.post(
            f"/api/businesses/{biz_id}/import/analyze",
            json={"volume_path": "/Volumes/a/b/c.json"},
        )
        assert r.status_code == 200, r.text
        data = r.json()
        diff = data["business_digest_diff"]
        assert diff is not None
        fields = {m["field"] for m in diff["mismatch_fields"]}
        assert "business_name" in fields
        # Industries match → no industry mismatch.
        assert "industry_alignment" not in fields

    def test_analyze_no_mismatch_returns_empty_list(
        self, client_with_agent, mock_ws, engine,
    ):
        biz_id = _seed_target_business(engine, "Gaming", "Gaming")
        _mock_download(mock_ws, json.dumps(_payload()))
        r = client_with_agent.post(
            f"/api/businesses/{biz_id}/import/analyze",
            json={"volume_path": "/Volumes/a/b/c.json"},
        )
        assert r.status_code == 200, r.text
        diff = r.json()["business_digest_diff"]
        assert diff is not None
        assert diff["mismatch_fields"] == []


class TestExecuteAcceptMismatch:
    def test_execute_409_when_mismatch_and_no_accept_flag(
        self, client_with_agent, mock_ws, engine,
    ):
        biz_id = _seed_target_business(
            engine, "Gaming Reference Model", "Gaming",
        )
        _mock_download(mock_ws, json.dumps(_payload(business_name="Gaming")))
        r = client_with_agent.post(
            f"/api/businesses/{biz_id}/import/execute",
            json={"volume_path": "/Volumes/a/b/c.json"},
        )
        assert r.status_code == 409, r.text
        detail = r.json()["detail"]
        assert detail["error"] == "business_identity_mismatch"
        fields = {m["field"] for m in detail["mismatch_fields"]}
        assert "business_name" in fields

    def test_execute_succeeds_with_accept_flag(
        self, client_with_agent, mock_ws, engine,
    ):
        biz_id = _seed_target_business(
            engine, "Gaming Reference Model", "Gaming",
        )
        _mock_download(mock_ws, json.dumps(_payload(business_name="Gaming")))
        r = client_with_agent.post(
            f"/api/businesses/{biz_id}/import/execute",
            json={
                "volume_path": "/Volumes/a/b/c.json",
                "accept_business_mismatch": True,
            },
        )
        assert r.status_code == 200, r.text
        assert r.json()["version"] == 1

    def test_execute_succeeds_when_no_mismatch(
        self, client_with_agent, mock_ws, engine,
    ):
        biz_id = _seed_target_business(engine, "Gaming", "Gaming")
        _mock_download(mock_ws, json.dumps(_payload()))
        r = client_with_agent.post(
            f"/api/businesses/{biz_id}/import/execute",
            json={"volume_path": "/Volumes/a/b/c.json"},
        )
        assert r.status_code == 200, r.text
