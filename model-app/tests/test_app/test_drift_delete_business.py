"""Drift tests for deleting a business (v0.9.0 addendum design 6.1, D1).

``DELETE /api/businesses/{id}?cascade=true`` goes through
``_version_lifecycle.delete_business``: under the business lock it refuses
an active run and any installed version, records one ``metamodel_cleanups``
row per version and catalog in the transaction that deletes the business,
then removes the agent's ``_metamodel`` rows. These tests drive the route
against the recording UC fake with the app's own install and uninstall
observers (``test_drift_deploy_delete``), and check the two sides agree
afterwards.

* Every version's registry rows go, in every catalog that holds them
  (home, a second and a third install catalog).
* Refusals (an installed version, an active run) write nothing.
* A failed cleanup stays recorded; a business created again with the same
  name lists it and can retry it, and inherits no registry rows once it is
  done.
* A starting warehouse: after the first timeout the rest of the batch stays
  pending for the boot sweep, and a check still running is a timeout, not
  "no rows".
"""
from __future__ import annotations

from unittest.mock import MagicMock

import pytest
from sqlmodel import Session, select

from vibe_modeling.backend.core._metamodel_cleanups import sweep_metamodel_cleanups
from vibe_modeling.backend.core._sql import SqlStatementError
from vibe_modeling.backend.model_sync import ModelSyncService

from vibe_modeling.backend.db_models import (
    AgentConfig, Business, BusinessContext, MetamodelCleanup, ModelVersion, Run, VibeInput,
)

from ._assess_helpers import changed_tables, table_digests
from ._drift.consistency import assert_lakebase_metamodel_consistent
from ._drift.fake_uc import FakeUC
from ._drift.fixtures import WAREHOUSE_ID, fake_uc  # noqa: F401
from .test_drift_deploy_delete import (
    BUSINESS, HOME, OTHER, SCOPE, SEGMENT, THIRD, install, registry_keys, seed_version, uninstall,
)


@pytest.fixture(name="mock_ws")
def mock_ws_on_the_fake(fake_uc):
    """The conftest clients talk to the fake's workspace."""
    return fake_uc.ws


@pytest.fixture(autouse=True)
def agent_config(fk_engine):
    """A configured agent whose metamodel catalog is ``HOME``."""
    with Session(fk_engine) as session:
        session.add(AgentConfig(
            notebook_path="/Workspace/test/notebook", job_id=99, deployment_catalog=HOME,
            warehouse_id=WAREHOUSE_ID,
        ))
        session.commit()


def business_id(engine) -> str:
    with Session(engine) as session:
        return session.exec(select(Business.id).where(Business.name == BUSINESS)).one()


def delete_business(client, engine):
    return client.delete(f"/api/businesses/{business_id(engine)}?cascade=true")


def _uninstalled_everywhere(engine, fake_uc: FakeUC) -> list[str]:
    """v1 and v2 of the business, written in ``HOME``. v1 was installed into
    ``OTHER`` and ``THIRD`` and uninstalled from both (the agent keeps its
    registry rows there); v2 is the head, never installed."""
    v1 = seed_version(engine, fake_uc, version=1, status="superseded")
    v2 = seed_version(engine, fake_uc, version=2)
    for catalog in (OTHER, THIRD):
        install(engine, fake_uc, v1, catalog)
        uninstall(engine, fake_uc, v1, catalog)
    return [v1, v2]


class TestDeleteBusinessCleansTheRegistry:

    def test_every_versions_rows_go_in_every_catalog(self, fk_engine, fake_uc, fk_client):
        _uninstalled_everywhere(fk_engine, fake_uc)
        assert registry_keys(fake_uc) == {(HOME, "1"), (HOME, "2"), (OTHER, "1"), (THIRD, "1")}
        response = delete_business(fk_client, fk_engine)
        assert response.status_code == 200, response.text
        assert response.json() == {
            "ok": True, "cascaded": True, "metamodel_cleanup": {"done": 4, "pending": 0, "failed": 0},
        }
        assert registry_keys(fake_uc) == set()
        assert sorted(
            (c.args["catalog"], c.args["version"]) for c in fake_uc.calls_to("delete_metamodel_rows")
        ) == [(HOME, "1"), (HOME, "2"), (OTHER, "1"), (THIRD, "1")]
        with Session(fk_engine) as session:
            assert session.exec(select(Business)).all() == []
            assert session.exec(select(ModelVersion)).all() == []
            assert_lakebase_metamodel_consistent(session, fake_uc)

    def test_the_cleanup_rows_are_recorded_as_a_business_delete(self, fk_engine, fake_uc, fk_client):
        _uninstalled_everywhere(fk_engine, fake_uc)
        response = delete_business(fk_client, fk_engine)
        assert response.status_code == 200, response.text
        with Session(fk_engine) as session:
            rows = session.exec(select(MetamodelCleanup)).all()
            assert sorted((r.catalog, r.version, r.scope, r.status, r.reason) for r in rows) == [
                (HOME, 1, SCOPE, "done", "business_delete"),
                (HOME, 2, SCOPE, "done", "business_delete"),
                (OTHER, 1, SCOPE, "done", "business_delete"),
                (THIRD, 1, SCOPE, "done", "business_delete"),
            ]
            assert {r.business_segment for r in rows} == {SEGMENT}

    def test_feedback_contexts_and_run_history_go_with_the_business(self, fk_engine, fake_uc, fk_client):
        seed_version(fk_engine, fake_uc)
        bid = business_id(fk_engine)
        with Session(fk_engine) as session:
            session.add(VibeInput(business_id=bid, text="Add a returns table"))
            session.add(BusinessContext(business_id=bid, version_label="seed"))
            session.add(Run(business_id=bid, intent="new-base-model", status="completed", parameters_json="{}"))
            session.commit()
        response = delete_business(fk_client, fk_engine)
        assert response.status_code == 200, response.text
        with Session(fk_engine) as session:
            for model in (VibeInput, BusinessContext, Run):
                assert session.exec(select(model)).all() == [], model.__name__

    def test_a_business_without_versions_writes_no_cleanup(self, fk_engine, fake_uc, fk_client):
        with Session(fk_engine) as session:
            session.add(Business(name=BUSINESS))
            session.commit()
        response = delete_business(fk_client, fk_engine)
        assert response.status_code == 200, response.text
        assert response.json()["metamodel_cleanup"] == {"done": 0, "pending": 0, "failed": 0}
        with Session(fk_engine) as session:
            assert session.exec(select(MetamodelCleanup)).all() == []
        assert fake_uc.calls_to("delete_metamodel_rows") == []


class TestDeleteBusinessRefusals:

    def test_an_installed_version_is_refused_naming_it_and_nothing_changes(self, fk_engine, fake_uc, fk_client):
        """v1 is uninstalled; v2 is installed into ``OTHER`` and ``THIRD``."""
        seed_version(fk_engine, fake_uc, version=1, status="superseded")
        v2 = seed_version(fk_engine, fake_uc, version=2)
        install(fk_engine, fake_uc, v2, OTHER)
        install(fk_engine, fake_uc, v2, THIRD)
        before, registry_before = table_digests(fk_engine), fake_uc.registry()
        response = delete_business(fk_client, fk_engine)
        assert response.status_code == 409, response.text
        detail = response.json()["detail"]
        assert detail["error"] == "installed"
        assert sorted(detail["catalogs"]) == sorted([OTHER, THIRD])
        assert [(v["version"], v["scope"], sorted(v["catalogs"])) for v in detail["versions"]] == [
            (2, SCOPE, sorted([OTHER, THIRD])),
        ]
        assert detail["message"].startswith("v2 MVM is installed in ")
        assert "Uninstall each one first" in detail["message"]
        assert changed_tables(before, table_digests(fk_engine)) == set()
        assert fake_uc.registry() == registry_before
        assert fake_uc.calls_to("delete_metamodel_rows") == []

    def test_an_active_run_is_refused_and_nothing_changes(self, fk_engine, fake_uc, fk_client):
        seed_version(fk_engine, fake_uc)
        with Session(fk_engine) as session:
            run = Run(business_id=business_id(fk_engine), intent="vibe-iterate", status="running",
                      parameters_json="{}")
            session.add(run)
            session.commit()
            run_id = run.id
        before, registry_before = table_digests(fk_engine), fake_uc.registry()
        response = delete_business(fk_client, fk_engine)
        assert response.status_code == 409, response.text
        assert run_id in response.json()["detail"]
        assert changed_tables(before, table_digests(fk_engine)) == set()
        assert fake_uc.registry() == registry_before

    def test_the_bare_delete_still_asks_for_cascade(self, fk_engine, fake_uc, fk_client):
        seed_version(fk_engine, fake_uc)
        before = table_digests(fk_engine)
        response = fk_client.delete(f"/api/businesses/{business_id(fk_engine)}")
        assert response.status_code == 409, response.text
        assert "cascade=true" in response.json()["detail"]
        assert changed_tables(before, table_digests(fk_engine)) == set()


class TestAFailedCleanupOutlivesTheBusiness:

    def _delete_with_other_failing(self, fk_engine, fake_uc, fk_client, monkeypatch):
        v1 = seed_version(fk_engine, fake_uc)
        install(fk_engine, fake_uc, v1, OTHER)
        uninstall(fk_engine, fake_uc, v1, OTHER)
        real = fake_uc._delete_metamodel_rows

        def fail_in_other(svc, catalog, *args, **kwargs):
            if catalog == OTHER:
                raise RuntimeError("warehouse unavailable")
            return real(svc, catalog, *args, **kwargs)

        monkeypatch.setattr(fake_uc, "_delete_metamodel_rows", fail_in_other)
        response = delete_business(fk_client, fk_engine)
        monkeypatch.setattr(fake_uc, "_delete_metamodel_rows", real)
        return response

    def test_the_failure_is_recorded_and_reported(self, fk_engine, fake_uc, fk_client, monkeypatch):
        response = self._delete_with_other_failing(fk_engine, fake_uc, fk_client, monkeypatch)
        assert response.status_code == 200, response.text
        assert response.json()["metamodel_cleanup"] == {"done": 1, "pending": 0, "failed": 1}
        assert registry_keys(fake_uc) == {(OTHER, "1")}
        with Session(fk_engine) as session:
            failed = session.exec(select(MetamodelCleanup).where(MetamodelCleanup.status == "failed")).one()
            assert (failed.catalog, failed.reason, failed.attempts) == (OTHER, "business_delete", 1)
            assert "warehouse unavailable" in (failed.last_error or "")
            assert session.exec(select(Business)).all() == []

    def test_a_business_created_again_lists_it_retries_it_and_inherits_nothing(
        self, fk_engine, fake_uc, fk_client, monkeypatch,
    ):
        response = self._delete_with_other_failing(fk_engine, fake_uc, fk_client, monkeypatch)
        assert response.status_code == 200, response.text
        created = fk_client.post("/api/businesses", json={
            "name": BUSINESS, "description": "Recreated", "industry_alignment": "Retail",
        })
        assert created.status_code == 200, created.text
        new_id = created.json()["id"]

        listed = fk_client.get(f"/api/businesses/{new_id}/metamodel-cleanups")
        assert listed.status_code == 200, listed.text
        (row,) = listed.json()
        assert (row["catalog"], row["version"], row["status"]) == (OTHER, 1, "failed")

        retried = fk_client.post(f"/api/businesses/{new_id}/metamodel-cleanups/{row['id']}/retry")
        assert retried.status_code == 200, retried.text
        assert retried.json()["status"] == "done"
        assert registry_keys(fake_uc) == set()
        listed = fk_client.get(f"/api/businesses/{new_id}/metamodel-cleanups")
        assert (listed.status_code, listed.json()) == (200, [])
        with Session(fk_engine) as session:
            assert_lakebase_metamodel_consistent(session, fake_uc)


class TestAStartingWarehouse:
    """A warehouse that does not answer within the statement wait (a classic
    warehouse starting): the first cleanup that times out is ``failed`` with
    the reason, the rest stay ``pending`` for the boot sweep or Retry
    cleanup, so the request returns after one wait."""

    def test_the_rest_of_the_batch_stays_pending_after_the_first_timeout(
        self, fk_engine, fake_uc, fk_client, monkeypatch,
    ):
        _uninstalled_everywhere(fk_engine, fake_uc)
        calls: list[str] = []

        def warehouse_starting(svc, catalog, *args, **kwargs):
            calls.append(catalog)
            raise SqlStatementError("TIMEOUT", "statement still running after 30s")

        monkeypatch.setattr(fake_uc, "_delete_metamodel_rows", warehouse_starting)
        response = delete_business(fk_client, fk_engine)
        assert response.status_code == 200, response.text
        assert response.json()["metamodel_cleanup"] == {"done": 0, "pending": 3, "failed": 1}
        assert len(calls) == 1
        with Session(fk_engine) as session:
            rows = session.exec(select(MetamodelCleanup)).all()
            assert sorted((r.status, r.attempts) for r in rows) == [
                ("failed", 1), ("pending", 0), ("pending", 0), ("pending", 0),
            ]
            (failed,) = [r for r in rows if r.status == "failed"]
            assert "did not answer in time" in failed.last_error

    def test_the_boot_sweep_finishes_them_once_the_warehouse_answers(
        self, fk_engine, fake_uc, fk_client, monkeypatch,
    ):
        _uninstalled_everywhere(fk_engine, fake_uc)
        real = fake_uc._delete_metamodel_rows

        def warehouse_starting(svc, catalog, *args, **kwargs):
            raise SqlStatementError("TIMEOUT", "statement still running after 30s")

        monkeypatch.setattr(fake_uc, "_delete_metamodel_rows", warehouse_starting)
        assert delete_business(fk_client, fk_engine).status_code == 200
        monkeypatch.setattr(fake_uc, "_delete_metamodel_rows", real)
        with Session(fk_engine) as session:
            summary = sweep_metamodel_cleanups(session, fake_uc.ws, WAREHOUSE_ID)
        assert (summary.done, summary.pending, summary.failed) == (4, 0, 0)
        assert registry_keys(fake_uc) == set()

    def test_a_check_still_running_raises_instead_of_reading_as_no_rows(self):
        """The existence check of ``delete_metamodel_rows`` is still PENDING
        after its 30 s wait (``core/_sql.scalar``): that is a timeout, not
        "the version has no rows" (which would mark the cleanup done and
        leave the rows)."""
        ws = MagicMock()
        pending = MagicMock()
        pending.status.state.value = "PENDING"
        pending.statement_id = "st-1"
        pending.result = None
        ws.statement_execution.execute_statement.return_value = pending
        ws.statement_execution.get_statement.return_value = pending
        with pytest.raises(SqlStatementError) as raised:
            ModelSyncService(None, ws, WAREHOUSE_ID).delete_metamodel_rows(HOME, SEGMENT, "1", SCOPE)
        assert raised.value.state == "TIMEOUT"
        assert ws.statement_execution.execute_statement.call_count == 1
