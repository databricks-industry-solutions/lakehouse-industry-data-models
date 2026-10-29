"""Tests for initial_sync.py — discovering businesses from Delta metamodel tables."""

import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "..", "src", "app", "src"))

import json
from pathlib import Path

import pytest
from contextlib import contextmanager
from unittest.mock import MagicMock, patch

from sqlalchemy.pool import StaticPool
from sqlmodel import Session, SQLModel, create_engine, select

from vibe_modeling.backend.db_models import AgentConfig, Business, Industry, ModelVersion
from vibe_modeling.backend.initial_sync import NO_DOMAINS, NO_MODEL_DATA, InitialSyncService
from vibe_modeling.backend.core._paths import version_dir_candidates
from vibe_modeling.backend.model_sync import ModelSyncService
from vibe_modeling.backend.services.operations._version_lifecycle import installed_catalogs
from vibe_modeling.backend.routes.vibe_inputs import _resolve_head_version

from ._drift.consistency import check_lakebase_metamodel_consistency
from ._drift.fixtures import fake_uc, mock_model  # noqa: F401
from ._lifecycle_fixtures import require_files_catalog  # noqa: F401


@pytest.fixture
def engine():
    engine = create_engine(
        "sqlite://",
        connect_args={"check_same_thread": False},
        poolclass=StaticPool,
    )
    SQLModel.metadata.create_all(engine)
    return engine


@pytest.fixture
def mock_ws():
    return MagicMock()


def _make_sql_result(columns, rows):
    from _sql_fakes import response

    return response(rows, columns=columns)


def _make_empty_result():
    from _sql_fakes import response

    return response([], columns=[])


BUSINESS_COLS = ["business", "version", "model_scope", "processing_status",
                 "completed_percent", "completion_date"]


def _discover_on_fake(engine, fake_uc, model_json: bool) -> dict:
    """Initial sync of one agent version on the fake (its model.json, or the
    Delta fallback when there is none)."""
    fake_uc.add_agent_version(
        "test_catalog", "retail_corp", 1, "mvm", mock_model(), write_model_json=model_json,
    )
    if not model_json:
        fake_uc.ws.files.create_directory(
            "/Volumes/test_catalog/_metamodel/vol_root/business/retail_corp/v1/mvm"
        )
    with Session(engine) as session:
        summary = InitialSyncService(session, fake_uc.ws, "wh-123").discover_and_sync("test_catalog")
        session.commit()
    return summary


ON_BOTH_SOURCES = pytest.mark.parametrize("model_json", [True, False], ids=["volume", "delta_fallback"])


class TestDiscoverAndSyncOnFakeUC:
    """Initial sync against the recording UC fake, checked for drift."""

    @ON_BOTH_SOURCES
    def test_discovers_and_creates_business(self, engine, fake_uc, model_json, require_files_catalog):
        """Discovers a business from the metamodel business table, creates it
        in Lakebase and syncs its model; Lakebase and the UC side agree
        afterwards, apart from the install row (next test)."""
        with require_files_catalog:
            summary = _discover_on_fake(engine, fake_uc, model_json)
        assert require_files_catalog.checked == 1

        assert summary["businesses_discovered"] == 1
        assert summary["businesses_created"] == 1
        assert summary["versions_synced"] == 1
        assert summary["errors"] == []
        assert bool(fake_uc.calls_to("query_delta_table")) is not model_json

        with Session(engine) as session:
            businesses = session.exec(select(Business)).all()
            assert [b.name for b in businesses] == ["Retail_Corp"]
            report = check_lakebase_metamodel_consistency(session, fake_uc)
        assert [str(p) for p in report.problems] == []

    @ON_BOTH_SOURCES
    def test_deployed_version_gets_an_install_row(self, engine, fake_uc, model_json):
        _discover_on_fake(engine, fake_uc, model_json)
        with Session(engine) as session:
            report = check_lakebase_metamodel_consistency(session, fake_uc)
        assert [str(p) for p in report.problems if p.item == 3] == []


class TestSegmentResolutionOnFakeUC:
    """The agent stores the business segment; initial sync resolves an
    existing business by segment and never creates a second one for it."""

    def _agent(self, fake_uc, name, version, scope="mvm", **model_extra):
        model = mock_model()
        model.update(model_extra)
        fake_uc.add_agent_version("test_catalog", name, version, scope, model)

    def test_existing_business_gets_the_version(self, engine, fake_uc):
        with Session(engine) as session:
            business = Business(name="WT-Base")
            session.add(business)
            session.commit()
            bid = business.id
        self._agent(fake_uc, "WT-Base", 1)

        with Session(engine) as session:
            summary = InitialSyncService(session, fake_uc.ws, "wh-123").discover_and_sync("test_catalog")
            session.commit()

        assert summary["businesses_created"] == 0
        assert summary["businesses_existing"] == 1
        assert summary["versions_synced"] == 1
        assert summary["created_business_ids"] == []
        with Session(engine) as session:
            assert [b.id for b in session.exec(select(Business)).all()] == [bid]
            (mv,) = session.exec(select(ModelVersion)).all()
            assert (mv.business_id, mv.version, mv.scope) == (bid, 1, "mvm")
            report = check_lakebase_metamodel_consistency(session, fake_uc)
        assert [str(p) for p in report.problems] == []

    def test_ambiguous_segment_is_skipped(self, engine, fake_uc):
        with Session(engine) as session:
            session.add(Business(name="WT Base"))
            session.add(Business(name="WT-Base"))
            session.commit()
        self._agent(fake_uc, "WT-Base", 1)

        with Session(engine) as session:
            summary = InitialSyncService(session, fake_uc.ws, "wh-123").discover_and_sync("test_catalog")
            session.commit()

        assert summary["versions_synced"] == 0
        assert summary["businesses_created"] == 0
        assert "wt_base: several businesses share this name segment" in summary["errors"][0]
        with Session(engine) as session:
            assert len(session.exec(select(Business)).all()) == 2
            assert session.exec(select(ModelVersion)).all() == []

    def test_segment_and_version_filters(self, engine, fake_uc):
        self._agent(fake_uc, "Acme", 1)
        self._agent(fake_uc, "Acme", 2)
        self._agent(fake_uc, "Other", 1)

        with Session(engine) as session:
            summary = InitialSyncService(session, fake_uc.ws, "wh-123").discover_and_sync(
                "test_catalog", business_segments=["ACME"], only_versions={("acme", 2, "mvm")},
            )
            session.commit()

        assert summary["businesses_discovered"] == 1
        assert summary["versions_synced"] == 1
        with Session(engine) as session:
            (business,) = session.exec(select(Business)).all()
            assert summary["created_business_ids"] == [business.id]
            assert [(mv.version, mv.scope) for mv in session.exec(select(ModelVersion)).all()] == [(2, "mvm")]

    def test_lineage_parent_from_model_json(self, engine, fake_uc):
        """A version whose model.json names its parent links to it; one with
        no tag, or a tag naming a version Lakebase lacks, is a base."""
        self._agent(fake_uc, "Acme", 1)
        self._agent(fake_uc, "Acme", 2, generated_from_version="v1_mvm")
        self._agent(fake_uc, "Acme", 3, generated_from_version="v9_mvm")

        with Session(engine) as session:
            summary = InitialSyncService(session, fake_uc.ws, "wh-123").discover_and_sync("test_catalog")
            session.commit()

        assert summary["versions_synced"] == 3
        with Session(engine) as session:
            by_version = {mv.version: mv for mv in session.exec(select(ModelVersion)).all()}
        assert by_version[1].base_version_id is None
        assert by_version[2].base_version_id == by_version[1].id
        assert by_version[3].base_version_id is None


class TestDryRunsOnFakeUC:
    """A version the agent registered as a Dry Run created no UC objects."""

    def test_dry_run_is_synced_as_a_draft(self, engine, fake_uc):
        fake_uc.add_agent_version("test_catalog", "Acme", 1, "mvm", mock_model())
        fake_uc.add_agent_version("test_catalog", "Acme", 2, "mvm", mock_model())
        # The agent's registrar UPDATEs deploy_status on the version's business row.
        for row in fake_uc._registry["test_catalog"]["business"]:
            if row["version"] == "2":
                row["deploy_status"] = " Dry_Run "

        with Session(engine) as session:
            session.add(AgentConfig(deployment_catalog="test_catalog", warehouse_id="wh-123"))
            summary = InitialSyncService(session, fake_uc.ws, "wh-123").discover_and_sync("test_catalog")
            session.commit()

        assert summary["versions_synced"] == 2
        with Session(engine) as session:
            by_version = {mv.version: mv for mv in session.exec(select(ModelVersion)).all()}
            assert (by_version[1].deployment_status, by_version[1].uc_catalog) == ("deployed", "test_catalog")
            assert (by_version[2].status, by_version[2].dry_run, by_version[2].deployment_status) == (
                "draft", True, "draft",
            )
            assert by_version[1].status == "completed"
            assert by_version[2].files_catalog == "test_catalog"
            assert not by_version[2].uc_catalog
            assert installed_catalogs(session, by_version[2]) == []
            assert installed_catalogs(session, by_version[1]) == ["test_catalog"]
            assert _resolve_head_version(session, by_version[1].business_id).id == by_version[1].id
            report = check_lakebase_metamodel_consistency(session, fake_uc)
        assert [str(p) for p in report.problems] == []


class TestRefusalsOnFakeUC:
    """Discovery refuses what it cannot import correctly and says why."""

    def test_agent_release_outside_the_compat_matrix_is_refused(self, engine, fake_uc):
        model = mock_model()
        model["release_version"] = "0.0.1"
        fake_uc.add_agent_version("test_catalog", "Acme", 1, "mvm", model)
        fake_uc.add_agent_version("test_catalog", "Acme", 2, "mvm", mock_model())

        with Session(engine) as session:
            summary = InitialSyncService(session, fake_uc.ws, "wh-123").discover_and_sync("test_catalog")
            session.commit()

        assert summary["versions_synced"] == 1
        (error,) = summary["errors"]
        assert error.startswith("Acme v1 MVM: not imported: Agent tag 'v0.0.1' is not in the compatibility matrix")
        with Session(engine) as session:
            assert [mv.version for mv in session.exec(select(ModelVersion)).all()] == [2]

    def test_a_row_the_registry_migration_has_not_filled_waits_for_it(self, engine, fake_uc):
        fake_uc.add_agent_version("test_catalog", "Acme", 1, "mvm", mock_model())
        for row in fake_uc._registry["test_catalog"]["business"]:
            row["completed_percent"] = None

        with Session(engine) as session:
            summary = InitialSyncService(session, fake_uc.ws, "wh-123").discover_and_sync("test_catalog")
            session.commit()

        assert summary["versions_synced"] == 0
        (error,) = summary["errors"]
        assert error.startswith("Acme v1 MVM: not imported: Waiting for the agent's registry migration")
        with Session(engine) as session:
            assert session.exec(select(ModelVersion)).all() == []


AGENT_SHAPES = Path(__file__).resolve().parents[1] / "fixtures" / "agent_shapes"


def _agent_shape(name: str) -> dict:
    """A model.json captured from the vendored agent (``fixtures/agent_shapes``)."""
    return json.loads((AGENT_SHAPES / name).read_text())


def _discover(engine, fake_uc, **kw) -> dict:
    with Session(engine) as session:
        summary = InitialSyncService(session, fake_uc.ws, "wh-123").discover_and_sync("test_catalog", **kw)
        session.commit()
    return summary


def _versions(engine) -> dict:
    with Session(engine) as session:
        return {(mv.version, mv.scope): mv for mv in session.exec(select(ModelVersion)).all()}


class TestVersionWritesOnFakeUC:

    def test_lineage_parent_from_the_5_3_3_lineage_block(self, engine, fake_uc):
        vibe = _agent_shape("model_json_5_3_3_vibe.json")
        assert (vibe["lineage"]["base_version"], vibe["lineage"]["base_scope"]) == (1, "mvm")
        assert "generated_from_version" not in vibe and "generated_from_version" not in vibe["model"]
        fake_uc.add_agent_version("test_catalog", "Acme Co", 1, "mvm", _agent_shape("model_json_5_3_3_base.json"))
        fake_uc.add_agent_version("test_catalog", "Acme Co", 2, "mvm", vibe)

        assert _discover(engine, fake_uc)["versions_synced"] == 2
        found = _versions(engine)
        assert found[(2, "mvm")].base_version_id == found[(1, "mvm")].id

    def test_a_failing_version_leaves_nothing_and_the_others_import(self, engine, fake_uc, monkeypatch):
        fake_uc.add_agent_version("test_catalog", "Acme", 1, "mvm", mock_model())
        fake_uc.add_agent_version("test_catalog", "Acme", 2, "mvm", mock_model())
        real = ModelSyncService.sync_model

        def boom(self, version_id, catalog, business_name, version_str, *a, **kw):
            if str(version_str) == "2":
                raise RuntimeError("boom on second version")
            return real(self, version_id, catalog, business_name, version_str, *a, **kw)

        monkeypatch.setattr(ModelSyncService, "sync_model", boom)
        summary = _discover(engine, fake_uc)

        assert summary["versions_synced"] == 1
        assert summary["imported"] == [["acme", 1, "mvm"]]
        assert summary["refused"] == [{
            "business_segment": "acme", "version": 2, "scope": "mvm",
            "reason": "boom on second version", "lasting": False,
        }]
        found = _versions(engine)
        assert list(found) == [(1, "mvm")]
        assert (found[(1, "mvm")].status, found[(1, "mvm")].deployment_status) == ("completed", "deployed")

    def test_no_business_is_created_when_every_version_is_refused(self, engine, fake_uc):
        model = mock_model()
        model["release_version"] = "0.0.1"
        fake_uc.add_agent_version("test_catalog", "Brand New", 1, "mvm", model)
        summary = _discover(engine, fake_uc)
        assert (summary["businesses_created"], summary["created_business_ids"]) == (0, [])
        with Session(engine) as session:
            assert session.exec(select(Business)).all() == []

    def test_no_business_is_kept_when_every_version_fails(self, engine, fake_uc, monkeypatch):
        fake_uc.add_agent_version("test_catalog", "Brand New", 1, "mvm", mock_model())

        def boom(self, *a, **kw):
            raise RuntimeError("boom")

        monkeypatch.setattr(ModelSyncService, "sync_model", boom)
        summary = _discover(engine, fake_uc)
        assert summary["businesses_created"] == 0 and summary["refused"]
        with Session(engine) as session:
            assert session.exec(select(Business)).all() == []
            assert session.exec(select(Industry)).all() == []

    def test_v10_comes_after_v9(self, engine, fake_uc):
        fake_uc.add_agent_version("test_catalog", "Acme", 10, "mvm", {**mock_model(), "lineage": {
            "base_version": 9, "base_scope": "mvm"}})
        fake_uc.add_agent_version("test_catalog", "Acme", 9, "mvm", mock_model())

        assert _discover(engine, fake_uc)["versions_synced"] == 2
        found = _versions(engine)
        assert (found[(10, "mvm")].status, found[(10, "mvm")].deployment_status) == ("completed", "deployed")
        assert (found[(9, "mvm")].status, found[(9, "mvm")].deployment_status) == ("superseded", "uninstalled")
        assert found[(10, "mvm")].base_version_id == found[(9, "mvm")].id

    def test_an_older_version_arrives_superseded_and_evicts_nothing(self, engine, fake_uc):
        fake_uc.add_agent_version("test_catalog", "Acme", 2, "mvm", mock_model())
        assert _discover(engine, fake_uc)["versions_synced"] == 1
        fake_uc.add_agent_version("test_catalog", "Acme", 1, "mvm", mock_model())

        assert _discover(engine, fake_uc)["versions_synced"] == 1
        found = _versions(engine)
        assert (found[(2, "mvm")].status, found[(2, "mvm")].deployment_status) == ("completed", "deployed")
        assert (found[(1, "mvm")].status, found[(1, "mvm")].deployment_status) == ("superseded", "uninstalled")
        with Session(engine) as session:
            assert installed_catalogs(session, found[(1, "mvm")]) == []
            assert installed_catalogs(session, found[(2, "mvm")]) == ["test_catalog"]

    def test_a_registry_row_without_a_scope_does_not_stop_the_business(self, engine, fake_uc):
        fake_uc.add_agent_version("test_catalog", "Acme", 1, "mvm", mock_model(), write_model_json=False)
        fake_uc.add_agent_version("test_catalog", "Acme", 2, "ecm", mock_model())
        for row in fake_uc._registry["test_catalog"]["business"]:
            if row["version"] == "1":
                row["model_scope"] = None
        flat = version_dir_candidates("test_catalog", "Acme", 1, "mvm")[1]
        fake_uc.put_file(f"{flat}/model.json", mock_model())

        summary = _discover(engine, fake_uc)

        assert (summary["versions_synced"], summary["errors"]) == (2, [])
        assert set(_versions(engine)) == {(1, ""), (2, "ecm")}
        assert _discover(engine, fake_uc)["versions_synced"] == 0


class TestRefusalOrderAndEvictionOnFakeUC:

    def test_an_empty_model_never_evicts_the_installed_version(self, engine, fake_uc):
        fake_uc.add_agent_version("test_catalog", "Acme", 1, "mvm", mock_model())
        assert _discover(engine, fake_uc)["versions_synced"] == 1
        fake_uc.add_agent_version("test_catalog", "Acme", 2, "mvm", {"model": {"domains": []}})

        summary = _discover(engine, fake_uc)

        assert summary["versions_synced"] == 0
        assert [(r["version"], r["reason"], r["lasting"]) for r in summary["refused"]] == [(2, NO_DOMAINS, True)]
        found = _versions(engine)
        assert list(found) == [(1, "mvm")]
        assert (found[(1, "mvm")].status, found[(1, "mvm")].deployment_status) == ("completed", "deployed")

    def test_a_version_lakebase_has_is_not_reported_waiting(self, engine, fake_uc):
        fake_uc.add_agent_version("test_catalog", "Acme", 1, "mvm", mock_model())
        assert _discover(engine, fake_uc)["versions_synced"] == 1
        for row in fake_uc._registry["test_catalog"]["business"]:
            row["completed_percent"] = None

        summary = _discover(engine, fake_uc)

        assert (summary["refused"], summary["errors"]) == ([], [])

    def test_a_completed_row_wins_over_a_waiting_row_of_the_same_key(self, engine, fake_uc):
        fake_uc.add_agent_version("test_catalog", "Acme", 1, "mvm", mock_model())
        (row,) = fake_uc.rows("test_catalog", "business")
        fake_uc.add_rows("test_catalog", "business", [{**row, "completed_percent": None, "session_id": None}])

        summary = _discover(engine, fake_uc)

        assert (summary["versions_synced"], summary["refused"]) == (1, [])

    @pytest.mark.parametrize("status", ["failed", "draft"])
    def test_a_newer_failed_or_draft_row_does_not_supersede_the_import(self, engine, fake_uc, status):
        with Session(engine) as session:
            business = Business(name="Acme")
            session.add(business)
            session.flush()
            session.add(ModelVersion(business_id=business.id, version=5, scope="mvm", status=status))
            session.commit()
        fake_uc.add_agent_version("test_catalog", "Acme", 1, "mvm", mock_model())

        assert _discover(engine, fake_uc)["versions_synced"] == 1
        mv = _versions(engine)[(1, "mvm")]
        assert (mv.status, mv.deployment_status) == ("completed", "deployed")

    def test_a_database_error_reads_short(self, engine, fake_uc, monkeypatch):
        from sqlalchemy.exc import IntegrityError

        fake_uc.add_agent_version("test_catalog", "Acme", 1, "mvm", mock_model())

        def race(self, *a, **kw):
            raise IntegrityError(
                "INSERT INTO model_versions (id, business_id, version) VALUES (?, ?, ?)", {},
                Exception("UNIQUE constraint failed: model_versions.business_id"),
            )

        monkeypatch.setattr(InitialSyncService, "_write_version", race)
        summary = _discover(engine, fake_uc)

        (refused,) = summary["refused"]
        assert refused["lasting"] is False
        assert refused["reason"].startswith("Another import saved this version at the same time")
        assert "[SQL" not in summary["errors"][0] and "INSERT" not in summary["errors"][0]


class TestInstallCatalogOnFakeUC:
    """The agent writes its installation catalog in each registry row's
    ``catalog``; the registry may sit in another catalog (widget "10.
    Metamodel Catalog")."""

    def _set_catalog(self, fake_uc, version: str, value):
        """The agent writes its installation catalog on the version's
        business row and on its domain rows."""
        for table in ("business", "domain"):
            for row in fake_uc._registry["test_catalog"][table]:
                if row["version"] == version:
                    row["catalog"] = value

    def test_the_install_row_goes_where_the_agent_installed(self, engine, fake_uc):
        fake_uc.add_agent_version("test_catalog", "Acme", 1, "mvm", mock_model())
        assert _discover(engine, fake_uc)["versions_synced"] == 1
        fake_uc.add_agent_version("test_catalog", "Acme", 2, "mvm", mock_model())
        self._set_catalog(fake_uc, "2", "sandbox_cat")

        assert _discover(engine, fake_uc)["versions_synced"] == 1

        found = _versions(engine)
        with Session(engine) as session:
            v1, v2 = session.get(ModelVersion, found[(1, "mvm")].id), session.get(ModelVersion, found[(2, "mvm")].id)
            assert installed_catalogs(session, v2) == ["sandbox_cat"]
            assert (v2.uc_catalog, v2.files_catalog) == ("sandbox_cat", "test_catalog")
            # The app's install in the scanned catalog is not touched.
            assert installed_catalogs(session, v1) == ["test_catalog"]
            assert v1.deployment_status == "deployed"
            session.add(AgentConfig(deployment_catalog="test_catalog", warehouse_id="wh-123"))
            session.flush()
            report = check_lakebase_metamodel_consistency(session, fake_uc)
        assert [str(p) for p in report.problems] == []

    def test_several_install_catalogs_open_a_row_each(self, engine, fake_uc):
        fake_uc.add_agent_version("test_catalog", "Acme", 1, "mvm", mock_model())
        self._set_catalog(fake_uc, "1", "cat_x")
        # A second install adds its own business and domain rows (nb cell 118).
        (row,) = fake_uc.rows("test_catalog", "business")
        domains = fake_uc.rows("test_catalog", "domain")
        fake_uc.add_rows("test_catalog", "business", [{**row, "catalog": "cat_y", "session_id": None}])
        fake_uc.add_rows("test_catalog", "domain", [{**d, "catalog": "cat_y"} for d in domains])

        assert _discover(engine, fake_uc)["versions_synced"] == 1

        with Session(engine) as session:
            (mv,) = session.exec(select(ModelVersion)).all()
            assert sorted(installed_catalogs(session, mv)) == ["cat_x", "cat_y"]
            assert "test_catalog" not in installed_catalogs(session, mv)
            session.add(AgentConfig(deployment_catalog="test_catalog", warehouse_id="wh-123"))
            session.flush()
            report = check_lakebase_metamodel_consistency(session, fake_uc)
        assert [str(p) for p in report.problems] == []

    @pytest.mark.parametrize("value", [None, "", "  "])
    def test_no_catalog_in_the_row_means_the_scanned_catalog(self, engine, fake_uc, value):
        fake_uc.add_agent_version("test_catalog", "Acme", 1, "mvm", mock_model())
        self._set_catalog(fake_uc, "1", value)

        assert _discover(engine, fake_uc)["versions_synced"] == 1

        with Session(engine) as session:
            (mv,) = session.exec(select(ModelVersion)).all()
            assert installed_catalogs(session, mv) == ["test_catalog"]


class TestBusinessLockOnFakeUC:

    def test_a_business_with_a_run_in_flight_is_skipped_and_the_others_import(self, engine, fake_uc):
        from vibe_modeling.backend.db_models import Run

        with Session(engine) as session:
            busy = Business(name="Busy")
            session.add(busy)
            session.flush()
            session.add(Run(business_id=busy.id, status="running"))
            session.commit()
        fake_uc.add_agent_version("test_catalog", "Busy", 1, "mvm", mock_model())
        fake_uc.add_agent_version("test_catalog", "Other", 1, "mvm", mock_model())

        summary = _discover(engine, fake_uc)

        assert summary["versions_synced"] == 1
        assert [e.split(": not imported: ")[0] for e in summary["errors"]] == ["Busy"]
        assert "active run" in summary["errors"][0]
        with Session(engine) as session:
            names = {session.get(Business, mv.business_id).name for mv in session.exec(select(ModelVersion)).all()}
        assert names == {"Other"}

    def test_new_businesses_only_skips_a_business_created_meanwhile(self, engine, fake_uc):
        with Session(engine) as session:
            session.add(Business(name="Acme"))
            session.commit()
        fake_uc.add_agent_version("test_catalog", "Acme", 1, "mvm", mock_model())

        summary = _discover(engine, fake_uc, new_businesses_only=True)

        assert summary["versions_synced"] == 0
        assert summary["errors"] == [
            "Acme: this business was created after the check; import its versions from its own page"
        ]
        with Session(engine) as session:
            assert session.exec(select(ModelVersion)).all() == []


class TestWriteFailureText:

    def _integrity(self, message: str):
        from sqlalchemy.exc import IntegrityError

        return IntegrityError("INSERT INTO attributes (id, product_id) VALUES (?, ?)", {}, Exception(message))

    @pytest.mark.parametrize("message", [
        "UNIQUE constraint failed: model_versions.business_id, model_versions.version, model_versions.scope",
        'duplicate key value violates unique constraint "uq_model_versions_business_version_scope"',
    ])
    def test_a_duplicate_version_key_reads_as_a_concurrent_import(self, message):
        from vibe_modeling.backend.initial_sync import _write_failure_reason

        assert _write_failure_reason(self._integrity(message)).startswith(
            "Another import saved this version at the same time"
        )

    @pytest.mark.parametrize("message", [
        'insert or update on table "attributes" violates foreign key constraint "attributes_product_id_fkey"',
        'insert or update on table "model_versions" violates foreign key constraint "model_versions_base_version_id_fkey"',
        "NOT NULL constraint failed: attributes.name",
    ])
    def test_any_other_integrity_error_reads_generic(self, message):
        from vibe_modeling.backend.initial_sync import _write_failure_reason

        assert _write_failure_reason(self._integrity(message)) == "A database error stopped this import. Try again."

    def test_a_business_level_database_error_reads_short(self, engine, fake_uc, monkeypatch):
        from sqlalchemy.exc import IntegrityError

        fake_uc.add_agent_version("test_catalog", "Brand New", 1, "mvm", mock_model())

        def race(self, name, *_):
            raise IntegrityError(
                "INSERT INTO businesses (id, name) VALUES (?, ?)", {"name": name},
                Exception("UNIQUE constraint failed: businesses.name"),
            )

        monkeypatch.setattr(InitialSyncService, "_create_business", race)
        summary = _discover(engine, fake_uc)

        assert summary["errors"] == ["brand_new: A database error stopped this import. Try again."]


class TestDryRunQuery:
    """The real dry-run read against a statement fake."""

    def _svc(self, ws):
        return InitialSyncService(MagicMock(), ws, "wh")

    def test_reads_dry_run_keys(self):
        from _sql_fakes import response, ws_returning

        ws = ws_returning(response(
            [["Acme_Co", "3", "mvm"], ["Acme_Co", "v4", "Expanded Coverage Model - ECM"]],
            columns=["business", "version", "model_scope"],
        ))
        assert self._svc(ws)._query_dry_run_keys("c") == {("acme_co", 3, "mvm"), ("acme_co", 4, "ecm")}
        (sql,) = ws.statements
        assert "LOWER(TRIM(deploy_status)) = 'dry_run'" in sql

    @pytest.mark.parametrize("error", [
        "[UNRESOLVED_COLUMN.WITH_SUGGESTION] A column `deploy_status` cannot be resolved",
        "[TABLE_OR_VIEW_NOT_FOUND] The table `c`.`_metamodel`.`business` cannot be found",
    ])
    def test_older_registry_has_no_dry_runs(self, error):
        from _sql_fakes import response, ws_returning

        assert self._svc(ws_returning(response(error=error)))._query_dry_run_keys("c") == set()

    def test_other_errors_raise(self):
        from _sql_fakes import response, ws_returning
        from vibe_modeling.backend.core._sql import SqlStatementError

        with pytest.raises(SqlStatementError):
            self._svc(ws_returning(response(error="[INSUFFICIENT_PERMISSIONS] denied")))._query_dry_run_keys("c")


class TestDiscoverAndSync:
    """Initial sync on a mocked ``statement_execution`` that answers every
    statement with the business rows; the dry-run read has its own tests.
    Each version's model.json is ``mock_model.json`` unless a test says
    otherwise (discovery refuses a version with no model data)."""

    @pytest.fixture(autouse=True)
    def _no_dry_runs(self, monkeypatch):
        monkeypatch.setattr(InitialSyncService, "_query_dry_run_keys", lambda self, catalog: set())
        monkeypatch.setattr(ModelSyncService, "load_model_json_from_volumes", lambda self, *a, **kw: mock_model())

    @staticmethod
    def _one_business(mock_ws, rows):
        def mock_execute(**kwargs):
            if "DISTINCT" in kwargs["statement"]:
                return _make_sql_result(BUSINESS_COLS, rows)
            return _make_empty_result()

        mock_ws.statement_execution.execute_statement.side_effect = mock_execute

    def test_no_industry_when_nothing_matches(self, engine, mock_ws):
        """No catalog industry matches: the business has none, and no industry is minted."""
        self._one_business(mock_ws, [["fintech_startup", "v1", "MVM", "done", "100.0", "2024-01-01"]])

        with Session(engine) as session:
            svc = InitialSyncService(session, mock_ws, "wh-123")
            summary = svc.discover_and_sync("cat")
            session.commit()

        assert summary["businesses_created"] == 1
        assert "industries_auto_created" not in summary
        with Session(engine) as session:
            assert session.exec(select(Industry)).all() == []
            biz = session.exec(select(Business)).one()
            assert biz.industry_id is None
            assert biz.industry_alignment == ""

    def test_resolves_the_model_json_industry_alignment(self, engine, mock_ws, monkeypatch):
        """The model.json's industry alignment wins over the business name, by slug."""
        model = {**mock_model(), "industry_alignment": "energy_utilities"}
        monkeypatch.setattr(ModelSyncService, "load_model_json_from_volumes", lambda self, *a, **kw: model)
        self._one_business(mock_ws, [["fintech_startup", "v1", "MVM", "done", "100.0", "2024-01-01"]])
        with Session(engine) as session:
            session.add(Industry(name="Energy - Utilities", short_name="utilities"))
            session.add(Industry(name="Fintech Startup", short_name="fintech_startup"))
            session.commit()

        with Session(engine) as session:
            summary = InitialSyncService(session, mock_ws, "wh-123").discover_and_sync("cat")
            session.commit()

        assert summary["businesses_created"] == 1, summary
        with Session(engine) as session:
            biz = session.exec(select(Business)).one()
            energy = session.exec(select(Industry).where(Industry.short_name == "utilities")).one()
            assert biz.industry_id == energy.id
            assert biz.industry_alignment == "energy_utilities"

    def test_matches_existing_industry(self, engine, mock_ws):
        """When a matching industry exists by short_name, links to it without auto-creating."""
        rows = [
            ["banking", "v1", "MVM", "done", "100.0", "2024-01-01"],
        ]

        # Seed an industry
        with Session(engine) as session:
            session.add(Industry(name="Banking", short_name="banking"))
            session.commit()

        def mock_execute(**kwargs):
            sql = kwargs["statement"]
            if "DISTINCT" in sql:
                return _make_sql_result(BUSINESS_COLS, rows)
            return _make_empty_result()

        mock_ws.statement_execution.execute_statement.side_effect = mock_execute

        with Session(engine) as session:
            svc = InitialSyncService(session, mock_ws, "wh-123")
            summary = svc.discover_and_sync("cat")
            session.commit()

        assert summary["businesses_created"] == 1

        with Session(engine) as session:
            biz = session.exec(select(Business)).first()
            assert biz.industry_alignment == "Banking"
            ind = session.exec(select(Industry)).first()
            assert biz.industry_id == ind.id

    def test_skips_existing_business(self, engine, mock_ws):
        """Business that already exists in Lakebase is not duplicated."""
        with Session(engine) as session:
            session.add(Business(name="existing_biz"))
            session.commit()

        rows = [
            ["existing_biz", "v1", "MVM", "done", "100.0", "2024-01-01"],
        ]

        def mock_execute(**kwargs):
            sql = kwargs["statement"]
            if "DISTINCT" in sql:
                return _make_sql_result(BUSINESS_COLS, rows)
            return _make_empty_result()

        mock_ws.statement_execution.execute_statement.side_effect = mock_execute

        with Session(engine) as session:
            svc = InitialSyncService(session, mock_ws, "wh-123")
            summary = svc.discover_and_sync("cat")
            session.commit()

        assert summary["businesses_existing"] == 1
        assert summary["businesses_created"] == 0

    def test_skips_incomplete_versions(self, engine, mock_ws):
        """Versions with completed_percent < 100 or no completion_date are skipped."""
        rows = [
            ["test_biz", "v1", "MVM", "running", "50.0", None],
            ["test_biz", "v2", "MVM", "done", "100.0", "2024-06-01"],
        ]

        def mock_execute(**kwargs):
            sql = kwargs["statement"]
            if "DISTINCT" in sql:
                return _make_sql_result(BUSINESS_COLS, rows)
            return _make_empty_result()

        mock_ws.statement_execution.execute_statement.side_effect = mock_execute

        with Session(engine) as session:
            svc = InitialSyncService(session, mock_ws, "wh-123")
            summary = svc.discover_and_sync("cat")
            session.commit()

        # Only v2 should be synced
        assert summary["versions_synced"] == 1

        with Session(engine) as session:
            versions = session.exec(select(ModelVersion)).all()
            assert len(versions) == 1
            assert versions[0].version == 2

    def _discover_one(self, engine, mock_ws, name: str) -> dict:
        rows = [[name, "v1", "MVM", "done", "100.0", "2024-01-01"]]

        def mock_execute(**kwargs):
            if "DISTINCT" in kwargs["statement"]:
                return _make_sql_result(BUSINESS_COLS, rows)
            return _make_empty_result()

        mock_ws.statement_execution.execute_statement.side_effect = mock_execute
        with Session(engine) as session:
            summary = InitialSyncService(session, mock_ws, "wh-123").discover_and_sync("cat")
            session.commit()
        return summary

    def test_completed_version_without_model_data_is_refused(self, engine, mock_ws, monkeypatch):
        """No Volume model.json and no Delta rows: refused before any write,
        so it cannot evict the installed version, and not remembered (the
        Volume may be filled later)."""
        monkeypatch.setattr(ModelSyncService, "load_model_json_from_volumes", lambda self, *a, **kw: None)
        summary = self._discover_one(engine, mock_ws, "empty_biz")

        assert summary["versions_synced"] == 0
        (refused,) = summary["refused"]
        assert (refused["reason"], refused["lasting"]) == (NO_MODEL_DATA, False)
        with Session(engine) as session:
            assert session.exec(select(ModelVersion)).all() == []
            assert session.exec(select(Business)).all() == []

    def test_completed_version_with_zero_domains_is_refused(self, engine, mock_ws, monkeypatch):
        monkeypatch.setattr(
            ModelSyncService, "load_model_json_from_volumes", lambda self, *a, **kw: {"domains": []},
        )
        summary = self._discover_one(engine, mock_ws, "empty_g2_biz")

        assert summary["versions_synced"] == 0
        (refused,) = summary["refused"]
        assert (refused["reason"], refused["lasting"]) == (NO_DOMAINS, True)
        assert summary["errors"] == [f"empty_g2_biz v1 MVM: not imported: {NO_DOMAINS}"]
        with Session(engine) as session:
            assert session.exec(select(ModelVersion)).all() == []

    def test_table_not_found_returns_error(self, engine, mock_ws):
        """If business table doesn't exist, returns error in summary."""
        mock_ws.statement_execution.execute_statement.side_effect = RuntimeError(
            "TABLE_OR_VIEW_NOT_FOUND"
        )

        with Session(engine) as session:
            svc = InitialSyncService(session, mock_ws, "wh-123")
            summary = svc.discover_and_sync("nonexistent_catalog")

        assert len(summary["errors"]) == 1
        assert "not found" in summary["errors"][0]
        assert summary["businesses_discovered"] == 0

    def test_multiple_businesses_discovered(self, engine, mock_ws):
        """Discovers multiple businesses in one scan."""
        rows = [
            ["biz_a", "v1", "MVM", "done", "100.0", "2024-01-01"],
            ["biz_b", "v1", "ECM", "done", "100.0", "2024-02-01"],
            ["biz_b", "v2", "ECM", "done", "100.0", "2024-03-01"],
        ]

        def mock_execute(**kwargs):
            sql = kwargs["statement"]
            if "DISTINCT" in sql:
                return _make_sql_result(BUSINESS_COLS, rows)
            return _make_empty_result()

        mock_ws.statement_execution.execute_statement.side_effect = mock_execute

        with Session(engine) as session:
            svc = InitialSyncService(session, mock_ws, "wh-123")
            summary = svc.discover_and_sync("cat")
            session.commit()

        assert summary["businesses_discovered"] == 2
        assert summary["businesses_created"] == 2

        with Session(engine) as session:
            businesses = session.exec(select(Business)).all()
            assert len(businesses) == 2
            # biz_b should have 2 versions
            biz_b = session.exec(
                select(Business).where(Business.name == "biz_b")
            ).first()
            versions = session.exec(
                select(ModelVersion).where(ModelVersion.business_id == biz_b.id)
            ).all()
            assert len(versions) == 2
