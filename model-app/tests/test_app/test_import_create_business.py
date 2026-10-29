"""Story-1 coverage: ``POST /import/analyze`` (root) +
``POST /import/create-business-and-execute``.

Exercises the create-by-import flow end-to-end: digest extraction in
the analyze response, Business + ModelVersion creation in a single
transaction, industry resolution through ``industry_resolve`` (no
industry when the alignment matches none, a new one only on
``create_industry``), and the skip-if-exists 409.
"""

from __future__ import annotations

import json
from unittest.mock import MagicMock

from sqlmodel import Session, select

from ._assess_helpers import table_digests
from vibe_modeling.backend.db_models import (
    Business,
    BusinessContext,
    Industry,
    ModelVersion,
)


def _mock_download(mock_ws, content: str):
    resp = MagicMock()
    resp.contents.read.return_value = content.encode("utf-8")
    mock_ws.files.download.return_value = resp


def _payload(
    *,
    business_name: str = "Quantum Co",
    industry: str = "Quantum Computing",
    version: str = "v1_mvm",
    agent_version: str | None = None,
    release_version: str | None = None,
) -> dict:
    env: dict = {
        "model_requirements": {
            "business_name": business_name,
            "description": "Quantum business",
        },
        "model": {
            "type": "business",
            "name": business_name,
            "version": version,
            "description": "Quantum business",
            "industry_alignment": industry,
            "core_business_processes": "qubits",
            "orgnaization_divisions": "lab, ops",
            "common_business_jargons": "decoherence",
            "operational_systems_of_records": "JIRA",
            "industry_governing_body": "NIST",
            "domains": [
                {
                    "name": "ops",
                    "products": [
                        {
                            "name": "experiments",
                            "table_name": "experiments",
                            "primary_key": "experiment_id",
                            "attributes": [
                                {
                                    "name": "experiment_id",
                                    "column_name": "experiment_id",
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
    # Version provenance keys live at the ENVELOPE top level (Finding B) — the
    # inner ``model`` block does not carry them.
    if agent_version is not None:
        env["agent_version"] = agent_version
    if release_version is not None:
        env["release_version"] = release_version
    return env


class TestAnalyzeRoot:
    def test_returns_digest_without_industry_id_when_catalog_misses(
        self, client_with_agent, mock_ws,
    ):
        _mock_download(mock_ws, json.dumps(_payload()))
        r = client_with_agent.post(
            "/api/import/analyze",
            json={"volume_path": "/Volumes/a/b/c.json"},
        )
        assert r.status_code == 200, r.text
        data = r.json()
        assert data["valid"] is True
        assert data["business_digest"] is not None
        digest = data["business_digest"]
        assert digest["business_name"] == "Quantum Co"
        assert digest["industry_alignment"] == "Quantum Computing"
        assert digest["industry_id"] is None
        assert digest["core_business_processes"] == "qubits"
        # Story-1 path has no target business → no diff.
        assert data["business_digest_diff"] is None

    def test_returns_the_resolved_industry_id_for_a_slug(
        self, client_with_agent, mock_ws, engine,
    ):
        with Session(engine) as s:
            ind = Industry(name="Energy - Utilities", short_name="utilities")
            s.add(ind)
            s.commit()
            ind_id = ind.id

        _mock_download(
            mock_ws,
            json.dumps(_payload(business_name="Acme", industry="energy-utilities")),
        )
        r = client_with_agent.post(
            "/api/import/analyze",
            json={"volume_path": "/Volumes/a/b/c.json"},
        )
        assert r.status_code == 200, r.text
        digest = r.json()["business_digest"]
        assert digest["industry_alignment"] == "energy-utilities"
        assert digest["industry_id"] == ind_id

    def test_bad_path_rejected(self, client_with_agent):
        r = client_with_agent.post(
            "/api/import/analyze",
            json={"volume_path": "/not/a/volume.json"},
        )
        assert r.status_code == 400


class TestCreateBusinessAndExecute:
    def test_creates_business_with_versions_atomically(
        self, client_with_agent, mock_ws, engine,
    ):
        _mock_download(mock_ws, json.dumps(_payload()))
        r = client_with_agent.post(
            "/api/import/create-business-and-execute",
            json={"volume_path": "/Volumes/a/b/c.json"},
        )
        assert r.status_code == 200, r.text
        data = r.json()
        assert data["business_id"]
        assert data["version_id"]
        assert data["version"] == 1
        assert data["domains"] == 1
        assert data["products"] == 1
        assert data["attributes"] == 1

        # Verify the Business + Industry + Version landed.
        with Session(engine) as s:
            biz = s.exec(
                select(Business).where(Business.id == data["business_id"])
            ).first()
            assert biz is not None
            assert biz.name == "Quantum Co"
            assert biz.industry_alignment == "Quantum Computing"
            assert biz.industry_id is None
            assert s.exec(select(Industry)).all() == []

            mv = s.exec(
                select(ModelVersion).where(
                    ModelVersion.business_id == biz.id,
                )
            ).first()
            assert mv is not None
            assert mv.scope == "mvm"
            assert mv.deployment_status == "draft"
            assert mv.status == "completed"
            assert mv.import_source_path == "/Volumes/a/b/c.json"

            # Business context seeded from digest.
            ctx = s.exec(
                select(BusinessContext).where(
                    BusinessContext.business_id == biz.id,
                )
            ).first()
            assert ctx is not None
            ctx_payload = json.loads(ctx.context_json)
            assert ctx_payload["business_context"]["core_business_processes"] == "qubits"

    def test_stamps_version_provenance_from_envelope(
        self, client_with_agent, mock_ws, engine,
    ):
        """The create-business import route (import_root.py) stamps
        agent_version / release_version onto the new ModelVersion from the
        OUTER envelope via ``agent_compat.extract_version_provenance`` — a
        regression that drops the stamp fails here."""
        _mock_download(
            mock_ws,
            json.dumps(_payload(agent_version="4.9.8", release_version="0.8.0")),
        )
        r = client_with_agent.post(
            "/api/import/create-business-and-execute",
            json={"volume_path": "/Volumes/a/b/c.json"},
        )
        assert r.status_code == 200, r.text
        version_id = r.json()["version_id"]

        with Session(engine) as s:
            mv = s.get(ModelVersion, version_id)
            assert mv is not None
            assert mv.agent_version == "4.9.8"
            assert mv.release_version == "0.8.0"

    def test_unmatched_industry_leaves_the_business_unassigned(
        self, client_with_agent, mock_ws, engine,
    ):
        _mock_download(mock_ws, json.dumps(_payload(industry="Quantum Computing")))
        r = client_with_agent.post(
            "/api/import/create-business-and-execute",
            json={"volume_path": "/Volumes/a/b/c.json"},
        )
        assert r.status_code == 200, r.text
        with Session(engine) as s:
            biz = s.get(Business, r.json()["business_id"])
            assert biz.industry_id is None
            assert biz.industry_alignment == "Quantum Computing"
            assert s.exec(select(Industry)).all() == []

    def test_create_industry_adds_the_alignment_to_the_catalog(
        self, client_with_agent, mock_ws, engine,
    ):
        _mock_download(mock_ws, json.dumps(_payload(industry="Quantum Computing")))
        r = client_with_agent.post(
            "/api/import/create-business-and-execute",
            json={"volume_path": "/Volumes/a/b/c.json", "create_industry": True},
        )
        assert r.status_code == 200, r.text
        assert "Added industry 'Quantum Computing' to the catalog." in r.json()["warnings"]
        with Session(engine) as s:
            inds = s.exec(select(Industry)).all()
            assert len(inds) == 1
            assert inds[0].name == "Quantum Computing"
            assert inds[0].short_name == "quantum-computing"
            assert inds[0].is_auto_created is False
            assert s.get(Business, r.json()["business_id"]).industry_id == inds[0].id

    def test_create_industry_reuses_a_slug_match(
        self, client_with_agent, mock_ws, engine,
    ):
        with Session(engine) as s:
            ind = Industry(name="Energy - Utilities", short_name="energy-utilities")
            s.add(ind)
            s.commit()
            ind_id = ind.id
        _mock_download(mock_ws, json.dumps(_payload(industry="energy_utilities")))
        r = client_with_agent.post(
            "/api/import/create-business-and-execute",
            json={"volume_path": "/Volumes/a/b/c.json", "create_industry": True},
        )
        assert r.status_code == 200, r.text
        with Session(engine) as s:
            assert len(s.exec(select(Industry)).all()) == 1
            assert s.get(Business, r.json()["business_id"]).industry_id == ind_id

    def test_create_industry_refuses_an_alignment_without_letters_or_digits(
        self, client_with_agent, mock_ws, engine,
    ):
        _mock_download(mock_ws, json.dumps(_payload(industry="%_%")))
        r = client_with_agent.post(
            "/api/import/create-business-and-execute",
            json={"volume_path": "/Volumes/a/b/c.json", "create_industry": True},
        )
        assert r.status_code == 400, r.text
        with Session(engine) as s:
            assert s.exec(select(Industry)).all() == []
            assert s.exec(select(Business)).all() == []

    @staticmethod
    def _seed(engine, *rows):
        with Session(engine) as s:
            for name, short_name, auto in rows:
                s.add(Industry(id=short_name, name=name, short_name=short_name, is_auto_created=auto))
            s.commit()

    def _execute(self, client, mock_ws, industry, **extra):
        _mock_download(mock_ws, json.dumps(_payload(industry=industry)))
        return client.post(
            "/api/import/create-business-and-execute",
            json={"volume_path": "/Volumes/a/b/c.json", **extra},
        )

    def test_execute_prefers_a_curated_industry_over_an_auto_created_one(
        self, client_with_agent, mock_ws, engine,
    ):
        self._seed(engine, ("apparel-fashion", "apparel-fashion", True), ("Apparel & Fashion", "apparel", False))
        r = self._execute(client_with_agent, mock_ws, "apparel_fashion")
        assert r.status_code == 200, r.text
        with Session(engine) as s:
            assert s.get(Business, r.json()["business_id"]).industry_id == "apparel"

    def test_execute_leaves_an_ambiguous_alignment_unassigned(
        self, client_with_agent, mock_ws, engine,
    ):
        self._seed(engine, ("Health Care", "healthcare", False), ("Health-Care", "hc", False))
        r = self._execute(client_with_agent, mock_ws, "health care")
        assert r.status_code == 200, r.text
        with Session(engine) as s:
            biz = s.get(Business, r.json()["business_id"])
            assert biz.industry_id is None
            assert biz.industry_alignment == "health care"
            assert len(s.exec(select(Industry)).all()) == 2

    def test_create_industry_refuses_an_ambiguous_alignment(
        self, client_with_agent, mock_ws, engine,
    ):
        self._seed(engine, ("Health Care", "healthcare", False), ("Health-Care", "hc", False))
        before = table_digests(engine)
        r = self._execute(client_with_agent, mock_ws, "health care", create_industry=True)
        assert r.status_code == 409, r.text
        detail = r.json()["detail"]
        assert detail["error"] == "industry_ambiguous"
        assert detail["industries"] == [
            {"id": "healthcare", "name": "Health Care"},
            {"id": "hc", "name": "Health-Care"},
        ]
        assert "Pick one" in detail["message"]
        assert table_digests(engine) == before

    def test_an_explicit_industry_id_wins_over_an_ambiguous_name(
        self, client_with_agent, mock_ws, engine,
    ):
        """The dialog sends the id it resolved; the name alone is ambiguous."""
        self._seed(engine, ("Health Care", "healthcare", False), ("Health-Care", "hc", False))
        r = self._execute(client_with_agent, mock_ws, "Health Care", industry_id="hc", create_industry=True)
        assert r.status_code == 200, r.text
        with Session(engine) as s:
            assert s.get(Business, r.json()["business_id"]).industry_id == "hc"
            assert len(s.exec(select(Industry)).all()) == 2

    def test_an_unknown_or_inactive_industry_id_is_refused(
        self, client_with_agent, mock_ws, engine,
    ):
        with Session(engine) as s:
            s.add(Industry(id="old", name="Mining", short_name="mining", is_active=False))
            s.commit()
        before = table_digests(engine)
        for industry_id in ("missing", "old"):
            r = self._execute(client_with_agent, mock_ws, "Mining", industry_id=industry_id)
            assert r.status_code == 404, r.text
            assert r.json()["detail"]["error"] == "industry_not_found"
        assert table_digests(engine) == before

    def test_reuses_existing_industry_no_duplicate(
        self, client_with_agent, mock_ws, engine,
    ):
        with Session(engine) as s:
            s.add(Industry(
                name="Gaming",
                short_name="gaming",
                is_auto_created=False,
            ))
            s.commit()

        _mock_download(
            mock_ws,
            json.dumps(_payload(business_name="GameBiz", industry="Gaming")),
        )
        r = client_with_agent.post(
            "/api/import/create-business-and-execute",
            json={"volume_path": "/Volumes/a/b/c.json"},
        )
        assert r.status_code == 200, r.text
        with Session(engine) as s:
            inds = s.exec(
                select(Industry).where(Industry.name == "Gaming")
            ).all()
            assert len(inds) == 1
            # Did NOT flip the manually-created flag.
            assert inds[0].is_auto_created is False

    def test_409_when_business_name_already_exists(
        self, client_with_agent, mock_ws, engine,
    ):
        with Session(engine) as s:
            s.add(Business(name="Quantum Co"))
            s.commit()

        _mock_download(mock_ws, json.dumps(_payload(business_name="Quantum Co")))
        r = client_with_agent.post(
            "/api/import/create-business-and-execute",
            json={"volume_path": "/Volumes/a/b/c.json"},
        )
        assert r.status_code == 409, r.text
        detail = r.json()["detail"]
        assert detail["error"] == "business_already_exists"
        assert detail["business_name"] == "Quantum Co"

    def test_overrides_take_precedence_over_digest(
        self, client_with_agent, mock_ws, engine,
    ):
        _mock_download(mock_ws, json.dumps(_payload(business_name="DigestName")))
        r = client_with_agent.post(
            "/api/import/create-business-and-execute",
            json={
                "volume_path": "/Volumes/a/b/c.json",
                "business_name_override": "OverrideName",
                "industry_alignment_override": "Retail",
                "description_override": "Custom",
            },
        )
        assert r.status_code == 200, r.text
        with Session(engine) as s:
            biz = s.get(Business, r.json()["business_id"])
            assert biz.name == "OverrideName"
            assert biz.industry_alignment == "Retail"
            assert biz.description == "Custom"

    def test_400_when_model_json_lacks_business_name(
        self, client_with_agent, mock_ws,
    ):
        _mock_download(
            mock_ws,
            json.dumps({
                "type": "business",
                "name": "",  # blank!
                "version": "v1_mvm",
                "description": "",
                "domains": [],
            }),
        )
        r = client_with_agent.post(
            "/api/import/create-business-and-execute",
            json={"volume_path": "/Volumes/a/b/c.json"},
        )
        assert r.status_code == 400

    def test_400_when_schema_invalid(self, client_with_agent, mock_ws):
        _mock_download(mock_ws, json.dumps({"random": "junk"}))
        r = client_with_agent.post(
            "/api/import/create-business-and-execute",
            json={"volume_path": "/Volumes/a/b/c.json"},
        )
        assert r.status_code == 400

    def test_400_when_bad_volume_path(self, client_with_agent):
        r = client_with_agent.post(
            "/api/import/create-business-and-execute",
            json={"volume_path": "/not/a/volume.json"},
        )
        assert r.status_code == 400
