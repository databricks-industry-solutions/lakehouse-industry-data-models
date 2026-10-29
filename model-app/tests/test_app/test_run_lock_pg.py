"""Real Postgres races for X-PRE-c: one run per business through the API.

Run by ``scripts/smoke/run_pg_branch_test.sh tests/test_app/test_run_lock_pg.py
V090_RUNLOCK_PG_DATABASE`` on an ephemeral Lakebase branch; skipped unless
``V090_RUNLOCK_PG_DATABASE`` is set. Everything runs in a new, empty database on
that branch, built by ``reconcile_schema`` as a fresh install, so the cloned
production data is never read or written. SQLite ignores ``FOR UPDATE``, so these
run here (the SQLite halves are in ``test_drift_concurrent_runs.py``):

- **E3 (a)**, two concurrent creates on one business: the first holds the
  business lock inside the pre-flight's level 2; the second is refused at once
  with 409 "Another request for this business is in progress" and writes
  nothing; the first then answers 200, and a third create gets the active-run
  409 naming the first run.
- **E3 (d)**, retry while another run is active: 409 naming the active run;
  retry while a create holds the lock: 409 "Another request ..." at once, then
  the active-run 409 once the create has committed its run.
"""
from __future__ import annotations

import os
import sys
import threading
import time
from datetime import datetime, timezone
from unittest.mock import MagicMock

import pytest
from fastapi.testclient import TestClient
from sqlmodel import Session, select

sys.path.insert(0, os.path.dirname(__file__))

DATABASE = os.environ.get("V090_RUNLOCK_PG_DATABASE", "")
pytestmark = pytest.mark.skipif(not DATABASE, reason="needs a Lakebase branch (set V090_RUNLOCK_PG_DATABASE)")

from _assess_helpers import changed_tables, table_digests  # noqa: E402
from _pg_branch import fresh_database_engine  # noqa: E402
from _test_app import make_test_app  # noqa: E402

from vibe_modeling.backend.core._config import AppConfig  # noqa: E402
from vibe_modeling.backend.core._defaults import _ConfigDependency, _WorkspaceClientDependency  # noqa: E402
from vibe_modeling.backend.core._runs import LOCK_BUSY_MESSAGE, active_run_message  # noqa: E402
from vibe_modeling.backend.core._tracker import _TrackerDependency  # noqa: E402
from vibe_modeling.backend.core.lakebase import _LakebaseDependency  # noqa: E402
from vibe_modeling.backend.db_models import AgentConfig, Business, Run  # noqa: E402
from vibe_modeling.backend.services.orchestrator import Orchestrator  # noqa: E402
from vibe_modeling.backend.services.orchestrator import preflight as preflight_mod  # noqa: E402

from _drift.fake_uc import FakeUC  # noqa: E402

HOME = "runlock_home"
NOTEBOOK = "/Workspace/agent/runlock.ipynb"
# Remote Lakebase reads are slow (table_digests takes 6-7 s each): a generous bound.
WAIT = 120


@pytest.fixture(scope="module")
def pg_engine():
    from vibe_modeling.backend.migrations import reconcile_schema

    engine = fresh_database_engine(DATABASE)
    reconcile_schema(engine)
    with Session(engine) as s:
        s.add(AgentConfig(
            notebook_path=NOTEBOOK, job_id=7, job_name="runlock_job", deployment_catalog=HOME,
            warehouse_id="wh-1", installed_release_version="v0.9.0", installed_agent_version="5.3.3",
            installed_checked_path=NOTEBOOK, installed_checked_at=datetime.now(timezone.utc),
        ))
        s.commit()
    yield engine
    engine.dispose()


@pytest.fixture
def fake():
    uc = FakeUC()
    uc.add_metamodel(HOME)
    uc.ws._rest.jobs.run_now.return_value = MagicMock(run_id=4242)
    uc.ws._rest.config.client_id = "app-sp-id"
    return uc


@pytest.fixture
def app(pg_engine, fake):
    app = make_test_app()

    def session():
        with Session(pg_engine) as s:
            yield s

    tracker = MagicMock()
    tracker.orchestrator = Orchestrator(fake.ws, lambda: Session(bind=pg_engine))
    config = AppConfig(app_name="test", warehouse_id="wh-1", deployment_catalog=HOME, poll_interval_seconds=1)
    app.dependency_overrides[_LakebaseDependency.__call__] = session
    app.dependency_overrides[_ConfigDependency.__call__] = lambda: config
    app.dependency_overrides[_WorkspaceClientDependency.__call__] = lambda: fake.ws
    app.dependency_overrides[_TrackerDependency.__call__] = lambda: tracker
    return app


def _business(engine, name: str) -> str:
    with Session(engine) as s:
        b = Business(name=name, description="A utility", business_vibes="Model the meters.")
        s.add(b)
        s.commit()
        return b.id


def _runs(engine, business_id: str) -> list[Run]:
    with Session(engine) as s:
        return s.exec(select(Run).where(Run.business_id == business_id)).all()


_NBM = {"intent": "new-base-model", "catalog": HOME, "cataloging_style": "One Catalog"}


class _Held:
    """Holds the first create inside the lock window (level 2's target-catalog
    clash check, which runs under the lock) until ``release``."""

    def __init__(self, monkeypatch) -> None:
        self.inside = threading.Event()
        self.release = threading.Event()
        self.released: list[bool] = []
        real = preflight_mod._check_target_catalog_clash
        held = self

        def clash(*args, **kwargs):
            if not held.inside.is_set():
                held.inside.set()
                held.released.append(held.release.wait(WAIT))
            return real(*args, **kwargs)

        monkeypatch.setattr(preflight_mod, "_check_target_catalog_clash", clash)

    def start_create(self, app, business_id: str) -> tuple[threading.Thread, dict]:
        out: dict = {}

        def create() -> None:
            resp = TestClient(app).post(f"/api/businesses/{business_id}/runs", json=_NBM)
            out["status"], out["body"] = resp.status_code, resp.json()

        thread = threading.Thread(target=create)
        thread.start()
        assert self.inside.wait(WAIT), "the first create never reached the lock window"
        return thread, out


def test_two_concurrent_creates_give_one_run_and_one_409(app, pg_engine, monkeypatch):
    biz = _business(pg_engine, "Race Create")
    held = _Held(monkeypatch)
    thread, first = held.start_create(app, biz)
    try:
        before = table_digests(pg_engine)
        started = time.monotonic()
        second = TestClient(app).post(f"/api/businesses/{biz}/runs", json=_NBM)
        assert time.monotonic() - started < 5
        assert second.status_code == 409, second.text
        assert second.json()["detail"] == LOCK_BUSY_MESSAGE
        assert changed_tables(before, table_digests(pg_engine)) == set()
    finally:
        held.release.set()
        thread.join(WAIT)
    assert not thread.is_alive(), "the first create did not finish"
    assert held.released == [True], "the hold timed out before the second request was checked"
    assert first["status"] == 200, first
    runs = _runs(pg_engine, biz)
    assert [r.id for r in runs] == [first["body"]["id"]]

    third = TestClient(app).post(f"/api/businesses/{biz}/runs", json=_NBM)
    assert third.status_code == 409, third.text
    assert third.json()["detail"] == active_run_message(first["body"]["id"])
    assert len(_runs(pg_engine, biz)) == 1


def _failed_run(engine, business_id: str) -> str:
    with Session(engine) as s:
        run = Run(business_id=business_id, intent="new-base-model", status="failed", error_message="boom",
                  databricks_run_id=12345, parameters_json='{"operation": "new base model", '
                  f'"deployment_catalog": "{HOME}", "business_name": "race_retry"}}')
        s.add(run)
        s.commit()
        return run.id


def test_retry_while_another_run_is_active_is_409(app, pg_engine, fake):
    biz = _business(pg_engine, "Race Retry Active")
    failed = _failed_run(pg_engine, biz)
    with Session(pg_engine) as s:
        active = Run(business_id=biz, intent="install", status="running")
        s.add(active)
        s.commit()
        active_id = active.id
    before = table_digests(pg_engine)
    resp = TestClient(app).post(f"/api/businesses/{biz}/runs/{failed}/retry")
    assert resp.status_code == 409, resp.text
    assert resp.json()["detail"] == active_run_message(active_id)
    assert changed_tables(before, table_digests(pg_engine)) == set()
    fake.ws._rest.jobs.run_now.assert_not_called()


def test_retry_while_a_create_holds_the_lock_is_409(app, pg_engine, fake, monkeypatch):
    biz = _business(pg_engine, "Race Retry Lock")
    failed = _failed_run(pg_engine, biz)
    held = _Held(monkeypatch)
    thread, first = held.start_create(app, biz)
    try:
        started = time.monotonic()
        retry = TestClient(app).post(f"/api/businesses/{biz}/runs/{failed}/retry")
        assert time.monotonic() - started < 5
        assert retry.status_code == 409, retry.text
        assert retry.json()["detail"] == LOCK_BUSY_MESSAGE
    finally:
        held.release.set()
        thread.join(WAIT)
    assert not thread.is_alive(), "the first create did not finish"
    assert held.released == [True], "the hold timed out before the second request was checked"
    assert first["status"] == 200, first
    retry = TestClient(app).post(f"/api/businesses/{biz}/runs/{failed}/retry")
    assert retry.status_code == 409, retry.text
    assert retry.json()["detail"] == active_run_message(first["body"]["id"])
    with Session(pg_engine) as s:
        assert s.get(Run, failed).status == "failed"
