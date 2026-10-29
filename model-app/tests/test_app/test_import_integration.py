"""End-to-end import integration test using a realistic model.json fixture.

Verifies the full import flow:
  1. Analyze picks up the real v0.5.x schema as valid
  2. Execute creates the ModelVersion with deployment_status='draft'
  3. ModelSyncService populates Domain/Product/Attribute/ForeignKeyLink tables
     correctly from the canned fixture
  4. The imported version is accessible via the standard list endpoints
"""

import json
from pathlib import Path
from unittest.mock import MagicMock

from ._fake_volume import FakeVolume

import pytest
from sqlmodel import select

from vibe_modeling.backend.core._paths import version_dir_in_volume
from vibe_modeling.backend.db_models import (
    Attribute,
    Domain,
    ForeignKeyLink,
    ModelVersion,
    Product,
    Run,
    RunArtifact,
)


FIXTURE_PATH = Path(__file__).parent.parent / "fixtures" / "mock_vibe_agent" / "canned_model_v0.5.json"


def _load_fixture() -> dict:
    return json.loads(FIXTURE_PATH.read_text())


def _mock_volume_download(mock_ws, content: dict):
    resp = MagicMock()
    resp.contents.read.return_value = json.dumps(content).encode("utf-8")
    mock_ws.files.download.return_value = resp


class TestImportFullFixture:
    """Import the canned v0.5.x fixture and verify all entities land correctly."""

    def test_analyze_accepts_fixture(self, client_with_agent, mock_ws, seed_business):
        _mock_volume_download(mock_ws, _load_fixture())
        r = client_with_agent.post(
            f"/api/businesses/{seed_business}/import/analyze",
            json={"volume_path": "/Volumes/a/b/c.json"},
        )
        assert r.status_code == 200, r.text
        data = r.json()
        assert data["valid"]
        assert data["action"] == "import_as_is"
        assert data["inferred_version"] == "modern"
        assert data["domain_count"] == 2
        assert data["product_count"] == 4
        assert data["attribute_count"] == 10
        assert data["fk_count"] == 2
        # Fixture has no shape warnings
        assert data["warnings"] == []

    def test_execute_creates_full_model(
        self, client_with_agent, mock_ws, seed_business, engine
    ):
        """Every domain/product/attribute/FK from the fixture lands in Lakebase."""
        _mock_volume_download(mock_ws, _load_fixture())

        r = client_with_agent.post(
            f"/api/businesses/{seed_business}/import/execute",
            json={"volume_path": "/Volumes/a/b/c.json", "accept_business_mismatch": True},
        )
        assert r.status_code == 200, r.text
        data = r.json()
        assert data["domains"] == 2
        assert data["products"] == 4
        assert data["attributes"] == 10
        assert data["fk_links"] == 2

        # Dig into the actual tables — the counts API could lie if sync is
        # broken, so verify by querying directly.
        version_id = data["version_id"]
        from sqlmodel import Session
        with Session(engine) as session:
            mv = session.get(ModelVersion, version_id)
            assert mv is not None
            assert mv.status == "completed"
            assert mv.deployment_status == "draft"
            assert mv.scope == "mvm"

            domains = session.exec(
                select(Domain).where(Domain.version_id == version_id)
            ).all()
            assert {d.name for d in domains} == {"sales", "inventory"}
            sales = next(d for d in domains if d.name == "sales")
            inventory = next(d for d in domains if d.name == "inventory")
            assert sales.division == "Business"
            assert inventory.division == "Operations"

            # Products
            sales_products = session.exec(
                select(Product).where(Product.domain_id == sales.id)
            ).all()
            assert {p.name for p in sales_products} == {"customers", "orders"}

            orders = next(p for p in sales_products if p.name == "orders")
            assert orders.primary_key == "order_id"

            # Attributes
            order_attrs = session.exec(
                select(Attribute).where(Attribute.product_id == orders.id)
            ).all()
            assert {a.column_name for a in order_attrs} == {
                "order_id", "customer_id", "total_amount",
            }
            # FK attribute carries the reference
            fk_attr = next(a for a in order_attrs if a.column_name == "customer_id")
            assert fk_attr.foreign_key_to == "sales.customers.customer_id"

            # FK links table
            fks = session.exec(
                select(ForeignKeyLink).where(ForeignKeyLink.version_id == version_id)
            ).all()
            assert len(fks) == 2
            fk_tuples = {
                (f.source_domain, f.source_product, f.source_column,
                 f.target_domain, f.target_product, f.target_column) for f in fks
            }
            assert (
                "sales", "orders", "customer_id",
                "sales", "customers", "customer_id",
            ) in fk_tuples
            assert (
                "inventory", "stock_levels", "product_id",
                "inventory", "products", "product_id",
            ) in fk_tuples

    def test_imported_version_shows_in_version_list(
        self, client_with_agent, mock_ws, seed_business
    ):
        _mock_volume_download(mock_ws, _load_fixture())
        client_with_agent.post(
            f"/api/businesses/{seed_business}/import/execute",
            json={"volume_path": "/Volumes/a/b/c.json", "accept_business_mismatch": True},
        )
        r = client_with_agent.get(f"/api/businesses/{seed_business}/versions")
        assert r.status_code == 200
        versions = r.json()
        assert len(versions) == 1
        assert versions[0]["status"] == "completed"
        assert versions[0]["deployment_status"] == "draft"
        assert versions[0]["scope"] == "mvm"

    def test_execute_stores_provenance_on_model_version_without_run(
        self, client_with_agent, mock_ws, seed_business, engine
    ):
        """Import is a synchronous Volume → Lakebase sync. Provenance
        (``import_source_path`` + ``imported_at`` + version provenance
        ``agent_version`` / ``release_version``) lives on the ModelVersion
        directly; no Run row is created.

        The version provenance stamps the per-business import route
        (businesses.py) reads from the OUTER model.json envelope via
        ``agent_compat.extract_version_provenance`` — asserted here so a
        regression that drops the stamp can't pass silently."""
        # Inject a 4.9.8-style version envelope onto the canned fixture so
        # the top-level agent_version/release_version keys are present.
        payload = _load_fixture()
        payload["agent_version"] = "4.9.8"
        payload["release_version"] = "0.8.0"
        _mock_volume_download(mock_ws, payload)
        volume_path = "/Volumes/test/audit/path.json"

        r = client_with_agent.post(
            f"/api/businesses/{seed_business}/import/execute",
            json={"volume_path": volume_path, "accept_business_mismatch": True},
        )
        assert r.status_code == 200, r.text
        body = r.json()
        version_id = body["version_id"]
        # No run_id in the response anymore — imports don't create runs.
        assert "run_id" not in body

        from sqlmodel import Session
        with Session(engine) as session:
            mv = session.get(ModelVersion, version_id)
            assert mv is not None
            assert mv.import_source_path == volume_path
            assert mv.imported_at is not None
            # The import copies its files into the metamodel catalog.
            assert mv.files_catalog == "test_metamodel_catalog"
            # Version provenance stamped from the envelope (businesses.py path).
            assert mv.agent_version == "4.9.8"
            assert mv.release_version == "0.8.0"

            # No Run row was created for this business by the import.
            runs = session.exec(
                select(Run).where(Run.business_id == seed_business)
            ).all()
            assert runs == []

        # The mock workspace's jobs API was never invoked — no dispatch.
        assert mock_ws.jobs.run_now.call_count == 0

    def test_execute_indexes_volume_artifacts_and_loads_next_vibes(
        self, client_with_agent, mock_ws, seed_business, engine
    ):
        """Import indexes every file under the model.json's parent folder
        as a RunArtifact row, including vibes/next_vibes.json."""
        volume_path = "/Volumes/test_cat/landing/imports/mining/ecm_v1/model.json"
        source = "/Volumes/test_cat/landing/imports/mining/ecm_v1"
        next_vibes_payload = {"must_do": ["pick coal product"], "optional": []}
        volume = FakeVolume(mock_ws)
        volume.put(volume_path, _load_fixture())
        for rel in ("readme.md", "diagram/erd.dbml", "docs/model.xlsx", "docs/summary.md",
                    "ontology/model.ttl", "schemas/ddl.sql", "metrics/kpis.sql", "vibes/plan.md"):
            volume.put(f"{source}/{rel}", f"{rel} body")
        volume.put(f"{source}/vibes/next_vibes.json", next_vibes_payload)
        user_files = dict(volume.under(source))
        root = version_dir_in_volume("test_metamodel_catalog", "Test Corp", 1, "mvm")

        r = client_with_agent.post(
            f"/api/businesses/{seed_business}/import/execute",
            json={"volume_path": volume_path, "accept_business_mismatch": True},
        )
        assert r.status_code == 200, r.text
        body = r.json()
        version_id = body["version_id"]
        # Imports don't create Run rows; run_id is absent from the response.
        assert "run_id" not in body

        from sqlmodel import Session, select
        with Session(engine) as session:
            arts = session.exec(
                select(RunArtifact).where(
                    RunArtifact.model_version_id == version_id
                )
            ).all()
            # 9 files: model.json, readme.md, erd.dbml, model.xlsx,
            # summary.md, model.ttl, ddl.sql, kpis.sql, next_vibes.json,
            # plan.md = 10
            assert len(arts) == 10
            by_path = {a.file_path: a for a in arts}
            assert by_path[f"{root}/model.json"].artifact_type == "model_json"
            assert by_path[f"{root}/readme.md"].artifact_type == "readme"
            assert by_path[f"{root}/diagram/erd.dbml"].artifact_type == "dbml"
            assert by_path[f"{root}/docs/model.xlsx"].artifact_type == "excel"
            assert by_path[f"{root}/docs/summary.md"].artifact_type == "markdown"
            assert by_path[f"{root}/ontology/model.ttl"].artifact_type == "turtle"
            assert by_path[f"{root}/schemas/ddl.sql"].artifact_type == "sql_ddl"
            assert by_path[f"{root}/metrics/kpis.sql"].artifact_type == "metric_sql"
            assert by_path[f"{root}/vibes/next_vibes.json"].artifact_type == "next_vibes_json"
            assert by_path[f"{root}/vibes/plan.md"].artifact_type == "vibes_doc"
            # Every row is bound to the imported ModelVersion. Imports
            # have no parent Run, so run_id stays NULL — the artifact
            # tab keys off model_version_id.
            for a in arts:
                assert a.model_version_id == version_id
                assert a.run_id is None

            # The next_vibes.json file is indexed as a RunArtifact (asserted
            # above). Its non-structured shape ({"must_do": ...}) carries no
            # ``_next_vibe_metadata.findings``, so no agent VibeInput rows are
            # materialized — the blob is gone.
            from vibe_modeling.backend.db_models import VibeInput
            from vibe_modeling.backend.models import VibeInputOrigin
            agent_inputs = session.exec(
                select(VibeInput).where(
                    VibeInput.origin == VibeInputOrigin.AGENT_NEXT_VIBE.value,
                )
            ).all()
            assert agent_inputs == []

        # The user's folder is untouched; the app's copy is stamped and prefixed.
        assert volume.under(source) == user_files
        copied = volume.json(f"{root}/model.json")["model"]
        assert copied["version"] == "v1_mvm"
        assert all(d["database_name"].startswith("mvm_") for d in copied["domains"])

    def test_two_imports_increment_version(
        self, client_with_agent, mock_ws, seed_business
    ):
        _mock_volume_download(mock_ws, _load_fixture())
        r1 = client_with_agent.post(
            f"/api/businesses/{seed_business}/import/execute",
            json={"volume_path": "/Volumes/a/b/c.json", "accept_business_mismatch": True},
        )
        r2 = client_with_agent.post(
            f"/api/businesses/{seed_business}/import/execute",
            json={"volume_path": "/Volumes/a/b/c.json", "accept_business_mismatch": True},
        )
        assert r1.json()["version"] == 1
        assert r2.json()["version"] == 2

        # Both versions exist with separate entity sets (no cross-version pollution)
        r = client_with_agent.get(f"/api/businesses/{seed_business}/versions")
        assert len(r.json()) == 2
