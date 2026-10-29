"""Out-of-band routes (``routes/oob.py``) against the recording UC fake.

The check cache is replaced per test by one whose checks run inline, so a
summary or "Check now" finishes inside the request.
"""

from __future__ import annotations

import os
import sys

import pytest
from unittest.mock import patch
from databricks.sdk.service.sql import State
from fastapi.testclient import TestClient
from sqlalchemy import event
from sqlalchemy.pool import StaticPool
from sqlmodel import Session, SQLModel, create_engine, select

from vibe_modeling.backend.core._defaults import _ConfigDependency, _WorkspaceClientDependency
from vibe_modeling.backend.core._roles import UserRole, resolve_user_role
from vibe_modeling.backend.core.lakebase import _LakebaseDependency
from vibe_modeling.backend.db_models import AgentConfig, Business, MetamodelCleanup, ModelVersion, Run
from vibe_modeling.backend.oob_detector import OobCheckCache
from vibe_modeling.backend.routes import oob as oob_routes

from ._drift.consistency import check_lakebase_metamodel_consistency
from ._drift.fake_uc import RegistryKey
from ._drift.fixtures import fake_uc, mock_model  # noqa: F401

sys.path.insert(0, os.path.dirname(__file__))
from _assess_helpers import table_digests  # noqa: E402
from _test_app import make_test_app  # noqa: E402

CAT = "oob_cat"


@pytest.fixture
def checks(monkeypatch):
    cache = OobCheckCache(spawn=lambda fn: fn())
    monkeypatch.setattr(oob_routes, "OOB_CHECKS", cache)
    return cache


@pytest.fixture
def savepoint_engine():
    """SQLite with real transactions around savepoints, as on Postgres.

    pysqlite issues no BEGIN before a SAVEPOINT, so a RELEASE commits the
    work and a later rollback cannot undo it; SQLAlchemy's documented fix
    emits BEGIN itself."""
    eng = create_engine("sqlite://", connect_args={"check_same_thread": False}, poolclass=StaticPool)

    @event.listens_for(eng, "connect")
    def _no_driver_transactions(dbapi_connection, _record):
        dbapi_connection.isolation_level = None

    @event.listens_for(eng, "begin")
    def _begin(conn):
        conn.exec_driver_sql("BEGIN")

    SQLModel.metadata.create_all(eng)
    return eng


@pytest.fixture
def configured(engine):
    with Session(engine) as s:
        s.add(AgentConfig(notebook_path="/nb", job_id=1, deployment_catalog=CAT, warehouse_id="wh"))
        s.commit()


def _client(engine, ws, config, role: UserRole = UserRole.APP_ADMIN) -> TestClient:
    app = make_test_app()

    def override_session():
        with Session(engine) as session:
            yield session

    app.dependency_overrides[_LakebaseDependency.__call__] = override_session
    app.dependency_overrides[_ConfigDependency.__call__] = lambda: config
    app.dependency_overrides[_WorkspaceClientDependency.__call__] = lambda: ws
    app.dependency_overrides[resolve_user_role] = lambda: role
    return TestClient(app)


def _warehouse(fake, state=State.RUNNING):
    fake.ws.warehouses.get.return_value.state = state


def _agent(fake, name, version, scope="mvm", session_id=77):
    fake.add_agent_version(CAT, name, version, scope, mock_model(), session_id=session_id)


def _business(engine, name) -> str:
    with Session(engine) as s:
        b = Business(name=name)
        s.add(b)
        s.commit()
        return b.id


_ROUTES = [
    ("GET", "/api/oob/summary"),
    ("POST", "/api/oob/check"),
    ("POST", "/api/businesses/{bid}/oob/import"),
    ("POST", "/api/oob/import-new-businesses"),
]


class TestRoles:

    @pytest.mark.parametrize("method,path", _ROUTES)
    def test_viewer_is_refused(self, engine, fake_uc, config, checks, configured, method, path):
        client = _client(engine, fake_uc.ws, config, UserRole.VIEWER)
        resp = client.request(method, path.format(bid="x"))
        assert resp.status_code == 403, resp.text

    def test_modeler_reads_checks_and_imports_into_a_business(self, engine, fake_uc, config, checks, configured):
        _warehouse(fake_uc)
        bid = _business(engine, "Acme")
        client = _client(engine, fake_uc.ws, config, UserRole.MODELER)
        assert client.get("/api/oob/summary").status_code == 200
        assert client.post("/api/oob/check").status_code == 200
        assert client.post(f"/api/businesses/{bid}/oob/import").status_code == 200
        assert client.post("/api/oob/import-new-businesses").status_code == 403

    def test_business_admin_creates_businesses(self, engine, fake_uc, config, checks, configured):
        client = _client(engine, fake_uc.ws, config, UserRole.BUSINESS_ADMIN)
        assert client.post("/api/oob/import-new-businesses").status_code == 200


class TestSummary:

    def test_unconfigured_runs_nothing(self, engine, fake_uc, config, checks):
        with Session(engine) as s:
            s.add(AgentConfig(notebook_path="/nb", job_id=1, deployment_catalog="", warehouse_id=""))
            s.commit()
        resp = _client(engine, fake_uc.ws, config).get("/api/oob/summary")
        assert resp.status_code == 200
        assert resp.json()["skipped_reason"] == "not_configured"
        assert fake_uc.calls_to("query_completed_versions") == []
        fake_uc.ws.warehouses.get.assert_not_called()

    def test_idle_warehouse_is_not_queried(self, engine, fake_uc, config, checks, configured):
        _warehouse(fake_uc, State.STOPPED)
        _agent(fake_uc, "Acme", 1)
        resp = _client(engine, fake_uc.ws, config).get("/api/oob/summary")
        assert resp.status_code == 200
        body = resp.json()
        assert body["skipped_reason"] == "warehouse_not_running"
        assert body["checked_at"] is None and body["businesses"] == []
        assert fake_uc.calls_to("query_completed_versions") == []

    def test_running_warehouse_reports_versions(self, engine, fake_uc, config, checks, configured):
        _warehouse(fake_uc)
        bid = _business(engine, "WT-Base")
        _agent(fake_uc, "WT-Base", 2)
        resp = _client(engine, fake_uc.ws, config).get("/api/oob/summary")
        assert resp.status_code == 200
        body = resp.json()
        assert body["catalog"] == CAT
        assert body["checked_at"].endswith("+00:00") or body["checked_at"].endswith("Z")
        assert body["businesses"] == [{
            "business_segment": "wt_base", "status": "existing", "business_id": bid,
            "candidate_business_ids": [], "versions": [{"version": 2, "scope": "mvm", "refused_reason": None}],
        }]
        assert body["checking"] is False

    def test_summary_writes_nothing(self, engine, fake_uc, config, checks, configured):
        _warehouse(fake_uc)
        _agent(fake_uc, "Acme", 1)
        before = table_digests(engine)
        assert _client(engine, fake_uc.ws, config).get("/api/oob/summary").status_code == 200
        assert table_digests(engine) == before


class TestCheckNow:

    def test_wakes_and_rate_limits(self, engine, fake_uc, config, checks, configured):
        _warehouse(fake_uc, State.STOPPED)
        _agent(fake_uc, "Acme", 1)
        client = _client(engine, fake_uc.ws, config)
        first = client.post("/api/oob/check")
        assert first.status_code == 200
        assert [b["business_segment"] for b in first.json()["businesses"]] == ["acme"]
        fake_uc.ws.warehouses.get.assert_not_called()
        second = client.post("/api/oob/check")
        assert second.status_code == 429
        detail = second.json()["detail"]
        assert detail["error"] == "rate_limited"
        assert 0 < detail["retry_after_s"] <= 60
        assert len(fake_uc.calls_to("query_completed_versions")) == 1

    def test_unconfigured_is_422(self, engine, fake_uc, config, checks):
        with Session(engine) as s:
            s.add(AgentConfig(notebook_path="/nb", job_id=1, deployment_catalog="", warehouse_id=""))
            s.commit()
        resp = _client(engine, fake_uc.ws, config).post("/api/oob/check")
        assert resp.status_code == 422
        assert resp.json()["detail"]["error"] == "config_missing"


class TestImportIntoBusiness:

    def test_imports_without_a_duplicate_business(self, engine, fake_uc, config, checks, configured):
        _warehouse(fake_uc)
        bid = _business(engine, "WT-Base")
        _agent(fake_uc, "WT-Base", 1)
        _agent(fake_uc, "WT-Base", 1, scope="ecm")
        _agent(fake_uc, "Other", 1)
        client = _client(engine, fake_uc.ws, config)

        resp = client.post(f"/api/businesses/{bid}/oob/import")

        assert resp.status_code == 200, resp.text
        assert resp.json() == {"imported_versions": 2, "created_business_ids": [], "warnings": []}
        with Session(engine) as s:
            assert [b.id for b in s.exec(select(Business)).all()] == [bid]
            assert sorted((m.version, m.scope) for m in s.exec(select(ModelVersion)).all()) == [(1, "ecm"), (1, "mvm")]
            report = check_lakebase_metamodel_consistency(
                s, fake_uc, catalogs=[CAT], allow_orphans=[RegistryKey(CAT, "other", "1", "mvm")],
            )
        assert [str(p) for p in report.problems] == []
        summary = client.get("/api/oob/summary").json()
        assert [b["business_segment"] for b in summary["businesses"]] == ["other"]

    def test_pending_cleanup_version_is_not_imported(self, engine, fake_uc, config, checks, configured):
        bid = _business(engine, "Acme")
        with Session(engine) as s:
            s.add(MetamodelCleanup(business_segment="acme", version=1, scope="mvm", catalog=CAT,
                                   reason="version_delete", status="pending"))
            s.commit()
        _agent(fake_uc, "Acme", 1)
        _agent(fake_uc, "Acme", 2)

        resp = _client(engine, fake_uc.ws, config).post(f"/api/businesses/{bid}/oob/import")

        assert resp.status_code == 200, resp.text
        assert resp.json()["imported_versions"] == 1
        with Session(engine) as s:
            assert [m.version for m in s.exec(select(ModelVersion)).all()] == [2]

    def test_nothing_to_import(self, engine, fake_uc, config, checks, configured):
        bid = _business(engine, "Acme")
        resp = _client(engine, fake_uc.ws, config).post(f"/api/businesses/{bid}/oob/import")
        assert resp.status_code == 200
        assert resp.json()["imported_versions"] == 0

    def test_ambiguous_segment_is_refused(self, engine, fake_uc, config, checks, configured):
        bid = _business(engine, "WT-Base")
        other = _business(engine, "WT Base")
        _agent(fake_uc, "WT-Base", 1)
        before = table_digests(engine)

        resp = _client(engine, fake_uc.ws, config).post(f"/api/businesses/{bid}/oob/import")

        assert resp.status_code == 409
        detail = resp.json()["detail"]
        assert detail["error"] == "ambiguous_business"
        assert sorted(detail["candidate_business_ids"]) == sorted([bid, other])
        assert table_digests(engine) == before
        assert fake_uc.calls_to("query_completed_versions") == []

    def test_run_in_flight_is_refused(self, engine, fake_uc, config, checks, configured):
        bid = _business(engine, "Acme")
        with Session(engine) as s:
            s.add(Run(business_id=bid, status="running"))
            s.commit()
        _agent(fake_uc, "Acme", 1)
        before = table_digests(engine)

        resp = _client(engine, fake_uc.ws, config).post(f"/api/businesses/{bid}/oob/import")

        assert resp.status_code == 409
        assert resp.json()["detail"]["error"] == "run_active"
        assert table_digests(engine) == before

    def test_a_run_that_starts_after_the_preflight_is_refused_by_the_lock(
        self, engine, fake_uc, config, checks, configured, monkeypatch,
    ):
        """The import locks the business (``lock_business_for_run``) before it
        writes: a run that started after the preflight check answers 409 and
        nothing is written."""
        bid = _business(engine, "Acme")
        _agent(fake_uc, "Acme", 1)
        real_detect = oob_routes._detect_now

        def detect_then_a_run_starts(session, ws, warehouse_id, catalog):
            found = real_detect(session, ws, warehouse_id, catalog)
            with Session(engine) as other:
                other.add(Run(business_id=bid, status="running"))
                other.commit()
            return found

        monkeypatch.setattr(oob_routes, "_detect_now", detect_then_a_run_starts)
        before_versions = len(Session(engine).exec(select(ModelVersion)).all())

        resp = _client(engine, fake_uc.ws, config).post(f"/api/businesses/{bid}/oob/import")

        assert resp.status_code == 409
        assert resp.json()["detail"]["error"] == "run_active"
        with Session(engine) as s:
            assert len(s.exec(select(ModelVersion)).all()) == before_versions == 0

    def test_a_held_business_lock_is_409_business_busy(self, engine, fake_uc, config, checks, configured, monkeypatch):
        """SQLite ignores ``FOR UPDATE``; the NOWAIT refusal itself is in
        ``test_install_rows_pg.py``. Here the route's mapping of it."""
        from vibe_modeling.backend.core import _runs
        from vibe_modeling.backend.core._runs import LOCK_BUSY_MESSAGE, BusinessBusy

        bid = _business(engine, "Acme")
        _agent(fake_uc, "Acme", 1)

        def held(session, business_id, **_kw):
            raise BusinessBusy(LOCK_BUSY_MESSAGE)

        monkeypatch.setattr(_runs, "lock_business_for_run", held)
        resp = _client(engine, fake_uc.ws, config).post(f"/api/businesses/{bid}/oob/import")

        assert resp.status_code == 409
        assert resp.json()["detail"] == {"error": "business_busy", "message": LOCK_BUSY_MESSAGE}
        with Session(engine) as s:
            assert s.exec(select(ModelVersion)).all() == []

    def test_unknown_business_is_404(self, engine, fake_uc, config, checks, configured):
        resp = _client(engine, fake_uc.ws, config).post("/api/businesses/nope/oob/import")
        assert resp.status_code == 404

    def test_unconfigured_is_422(self, engine, fake_uc, config, checks):
        with Session(engine) as s:
            s.add(AgentConfig(notebook_path="/nb", job_id=1, deployment_catalog="", warehouse_id=""))
            s.commit()
        bid = _business(engine, "Acme")
        resp = _client(engine, fake_uc.ws, config).post(f"/api/businesses/{bid}/oob/import")
        assert resp.status_code == 422
        assert resp.json()["detail"]["error"] == "config_missing"


class TestRefusalsAndFailures:

    def test_a_refused_version_stays_listed_with_its_reason(self, engine, fake_uc, config, checks, configured):
        bid = _business(engine, "Acme")
        model = mock_model()
        model["release_version"] = "0.0.1"
        fake_uc.add_agent_version(CAT, "Acme", 1, "mvm", model, session_id=77)
        _agent(fake_uc, "Acme", 2)
        client = _client(engine, fake_uc.ws, config)

        resp = client.post(f"/api/businesses/{bid}/oob/import")

        assert resp.status_code == 200, resp.text
        body = resp.json()
        assert body["imported_versions"] == 1
        assert body["warnings"][0].startswith("Acme v1 MVM: not imported: Agent tag 'v0.0.1'")
        (entry,) = client.get("/api/oob/summary").json()["businesses"]
        (version,) = entry["versions"]
        assert (version["version"], version["scope"]) == (1, "mvm")
        assert version["refused_reason"].startswith("Agent tag 'v0.0.1'")

    def test_a_failing_version_rolls_back_alone(self, engine, fake_uc, config, checks, configured, monkeypatch):
        from vibe_modeling.backend.model_sync import ModelSyncService

        bid = _business(engine, "Acme")
        _agent(fake_uc, "Acme", 1)
        _agent(fake_uc, "Acme", 2)
        real = ModelSyncService.sync_model

        def boom(self, version_id, catalog, business_name, version_str, *a, **kw):
            if str(version_str) == "2":
                raise RuntimeError("boom on second version")
            return real(self, version_id, catalog, business_name, version_str, *a, **kw)

        monkeypatch.setattr(ModelSyncService, "sync_model", boom)
        resp = _client(engine, fake_uc.ws, config).post(f"/api/businesses/{bid}/oob/import")

        assert resp.status_code == 200, resp.text
        assert resp.json()["imported_versions"] == 1
        with Session(engine) as s:
            (mv,) = s.exec(select(ModelVersion)).all()
            assert (mv.version, mv.status, mv.deployment_status) == (1, "completed", "deployed")
            report = check_lakebase_metamodel_consistency(
                s, fake_uc, catalogs=[CAT], allow_orphans=[RegistryKey(CAT, "acme", "2", "mvm")],
            )
        assert [str(p) for p in report.problems] == []

    def test_a_transient_failure_is_a_warning_and_stays_importable(
        self, engine, fake_uc, config, checks, configured, monkeypatch,
    ):
        from vibe_modeling.backend.model_sync import ModelSyncService

        bid = _business(engine, "Acme")
        _agent(fake_uc, "Acme", 1)

        def boom(self, *a, **kw):
            raise RuntimeError("database connection reset")

        monkeypatch.setattr(ModelSyncService, "sync_model", boom)
        client = _client(engine, fake_uc.ws, config)
        resp = client.post(f"/api/businesses/{bid}/oob/import")

        assert resp.status_code == 200, resp.text
        assert resp.json()["warnings"] == ["Acme v1 MVM: not imported: database connection reset"]
        (entry,) = client.get("/api/oob/summary").json()["businesses"]
        assert [(v["version"], v["refused_reason"]) for v in entry["versions"]] == [(1, None)]

    def test_an_empty_model_is_refused_and_remembered(self, engine, fake_uc, config, checks, configured):
        bid = _business(engine, "Acme")
        fake_uc.add_agent_version(CAT, "Acme", 1, "mvm", {"model": {"domains": []}}, session_id=77)
        client = _client(engine, fake_uc.ws, config)

        resp = client.post(f"/api/businesses/{bid}/oob/import")

        assert resp.status_code == 200, resp.text
        assert resp.json()["imported_versions"] == 0
        (entry,) = client.get("/api/oob/summary").json()["businesses"]
        assert entry["versions"][0]["refused_reason"] == "The agent's model.json has no domains."

    def test_a_failed_registry_read_is_503_and_writes_nothing(self, engine, fake_uc, config, checks, configured):
        from vibe_modeling.backend.core._sql import SqlStatementError
        from vibe_modeling.backend.initial_sync import InitialSyncService

        bid = _business(engine, "Acme")
        _agent(fake_uc, "Acme", 1)

        def fail(self, catalog):
            raise SqlStatementError("FAILED", "[INSUFFICIENT_PERMISSIONS] denied")

        before = table_digests(engine)
        with patch.object(InitialSyncService, "_query_dry_run_keys", fail):
            resp = _client(engine, fake_uc.ws, config).post(f"/api/businesses/{bid}/oob/import")
        assert resp.status_code == 503
        assert resp.json()["detail"]["error"] == "oob_scan_failed"
        assert table_digests(engine) == before

    def test_a_failed_commit_is_503(self, savepoint_engine, fake_uc, config, checks, monkeypatch):
        from sqlalchemy.exc import OperationalError

        engine = savepoint_engine
        with Session(engine) as s:
            s.add(AgentConfig(notebook_path="/nb", job_id=1, deployment_catalog=CAT, warehouse_id="wh"))
            s.commit()
        bid = _business(engine, "Acme")
        _agent(fake_uc, "Acme", 1)
        real_commit = Session.commit

        def commit(self):
            if sys._getframe(1).f_code.co_name == "_import":
                raise OperationalError("COMMIT", {}, Exception("connection lost"))
            return real_commit(self)

        monkeypatch.setattr(Session, "commit", commit)
        resp = _client(engine, fake_uc.ws, config).post(f"/api/businesses/{bid}/oob/import")
        monkeypatch.undo()
        assert resp.status_code == 503
        assert resp.json()["detail"]["error"] == "oob_import_failed"
        with Session(engine) as s:
            assert s.exec(select(ModelVersion)).all() == []


class TestImportNewBusinesses:

    def test_creates_only_new_segments(self, engine, fake_uc, config, checks, configured):
        bid = _business(engine, "Acme")
        _agent(fake_uc, "Acme", 1)
        _agent(fake_uc, "Brand New", 1)
        _agent(fake_uc, "Brand New", 2)

        resp = _client(engine, fake_uc.ws, config).post("/api/oob/import-new-businesses")

        assert resp.status_code == 200, resp.text
        body = resp.json()
        assert body["imported_versions"] == 2
        with Session(engine) as s:
            created = s.exec(select(Business).where(Business.id != bid)).all()
            assert [b.id for b in created] == body["created_business_ids"]
            assert [b.name for b in created] == ["Brand_New"]
            assert s.exec(select(ModelVersion).where(ModelVersion.business_id == bid)).all() == []

    def test_a_business_created_after_the_scan_is_not_written_into(
        self, engine, fake_uc, config, checks, configured, monkeypatch,
    ):
        _agent(fake_uc, "Brand New", 1)
        real_detect = oob_routes._detect_now

        def detect_then_someone_creates_it(session, ws, warehouse_id, catalog):
            found = real_detect(session, ws, warehouse_id, catalog)
            _business(engine, "Brand_New")
            return found

        monkeypatch.setattr(oob_routes, "_detect_now", detect_then_someone_creates_it)
        resp = _client(engine, fake_uc.ws, config).post("/api/oob/import-new-businesses")

        assert resp.status_code == 200, resp.text
        body = resp.json()
        assert (body["imported_versions"], body["created_business_ids"]) == (0, [])
        assert body["warnings"] == [
            "Brand_New: this business was created after the check; import its versions from its own page"
        ]
        with Session(engine) as s:
            assert s.exec(select(ModelVersion)).all() == []

    def test_unconfigured_is_422(self, engine, fake_uc, config, checks):
        with Session(engine) as s:
            s.add(AgentConfig(notebook_path="/nb", job_id=1, deployment_catalog="", warehouse_id=""))
            s.commit()
        resp = _client(engine, fake_uc.ws, config).post("/api/oob/import-new-businesses")
        assert resp.status_code == 422
