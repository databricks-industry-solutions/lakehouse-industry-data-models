"""Drift tests for concurrent runs on one business (v0.9.0 addendum design
§4.2, X-PRE-c, story E3; closes ``6gQjcgXrCJvmGqrq``).

One run per business. Create takes ``core._runs.lock_business_for_run`` after
the run pre-flight's level 1 and before its level-2 active-run check (the
lock's re-check); retry takes the same lock and gains the active-run check.
A held lock answers 409 "Another request for this business is in progress"
after a rollback; an active run keeps its own 409. A commit releases the
lock, so nothing commits between the lock and the Run row.

* **Lock and order.** A level-1 blocker refuses without the lock; a held lock
  refuses before any level-2 read, rolled back and writing nothing; an active
  run refuses create (E3 a, the sequential half) and retry (E3 d).
* **No commit in the lock window.** A spy on ``Session.commit`` over the four
  create branches (New Base Model, vibe-new-ecm-mvm, an orchestrated simple
  intent, the legacy single-job launch) and both retry branches fails on any
  commit between the lock and the Run row being written.
* **Out-of-app versions (E3 b, c).** An out-of-app run took the version the
  app expected; the app's own agent wrote the next one. The op fails
  ``version_mismatch`` and saves no version, or saves the version the agent
  reported, and the Lakebase/UC checker is clean with the out-of-app version
  named as out-of-band.

SQLite ignores ``FOR UPDATE``; the two-session races (E3 a and d) run on
Postgres in ``test_run_lock_pg.py``.
"""
from __future__ import annotations

import json
import traceback
import weakref
from pathlib import Path
from types import SimpleNamespace

import pytest
from databricks.sdk.errors import PermissionDenied
from sqlalchemy.exc import OperationalError
from sqlalchemy.orm import Session as OrmSession
from sqlmodel import Session, select

from vibe_modeling.backend import router as router_mod
from vibe_modeling.backend.core import _runs
from vibe_modeling.backend.core._names import agent_business_segment
from vibe_modeling.backend.db_models import ModelVersion, Run, RunAgentReport, RunOperation, RunProgressEvent
from vibe_modeling.backend.services.operations import vibe_iterate as vibe_iterate_mod
from vibe_modeling.backend.services.operations.vibe_iterate import VibeIterate
from vibe_modeling.backend.services.orchestrator import preflight as preflight_mod
from vibe_modeling.backend.version_resolution_parser import STAGE_NAME, STEP_NAME

from ._assess_helpers import changed_tables, table_digests
from ._drift.consistency import assert_lakebase_metamodel_consistent
from ._drift.fake_uc import RegistryKey
from ._drift.fixtures import fake_uc, mock_model, seed_synced_version  # noqa: F401
from .test_runtime_budget import _LEGACY_WIDGETS, _legacy_failed_run, _mock_run_now, _second_step_failed

REPO = Path(__file__).resolve().parents[2]
STALE_VIBE = REPO / "tests" / "fixtures" / "agent_shapes" / "model_json_5_3_3_vibe_stale.json"


# --------------------------------------------------------------------------- #
# Spies
# --------------------------------------------------------------------------- #


class CommitSpy:
    """Fails on a commit between the business lock and the Run row.

    Wraps the lock at both of its call sites (the pre-flight's create and
    retry) and ``Session.flush`` / ``Session.commit``. A session that took the
    lock has written its Run row once a flush or commit carries a ``Run`` in
    an in-flight status (the new row of a create, the re-dispatched row of a
    retry). A commit before that is recorded in ``violations`` with its stack.
    """

    def __init__(self, monkeypatch) -> None:
        self.lock_calls = 0
        self.runs_written = 0
        self.violations: list[str] = []
        self._locked: weakref.WeakSet = weakref.WeakSet()
        self._written: weakref.WeakSet = weakref.WeakSet()
        real_lock = _runs.lock_business_for_run
        real_flush, real_commit = OrmSession.flush, OrmSession.commit
        spy = self

        def lock(session, business_id, **kwargs):
            real_lock(session, business_id, **kwargs)
            spy.lock_calls += 1
            spy._locked.add(session)

        def flush(session, *args, **kwargs):
            spy._note_run(session)
            return real_flush(session, *args, **kwargs)

        def commit(session):
            if session in spy._locked and session not in spy._written:
                spy._note_run(session)
                if session not in spy._written:
                    spy.violations.append("".join(traceback.format_stack(limit=12)))
            return real_commit(session)

        monkeypatch.setattr(preflight_mod, "lock_business_for_run", lock)
        monkeypatch.setattr(router_mod, "lock_business_for_run", lock)
        monkeypatch.setattr(OrmSession, "flush", flush)
        monkeypatch.setattr(OrmSession, "commit", commit)

    def _note_run(self, session) -> None:
        if session not in self._locked or session in self._written:
            return
        pending = list(session.new) + list(session.dirty)
        if any(isinstance(o, Run) and o.status in _runs.IN_FLIGHT_RUN_STATUSES for o in pending):
            self._written.add(session)
            self.runs_written += 1


class _LockNotAvailable(Exception):
    """A DB-API error with Postgres's SQLSTATE for a held ``NOWAIT`` lock."""

    sqlstate = "55P03"


def hold_the_lock(monkeypatch) -> list[str]:
    """Another request holds the business lock: the ``FOR UPDATE NOWAIT``
    select fails the way Postgres fails it (SQLite has no row locks). Returns
    the list ``Session.rollback`` calls are recorded in."""
    real_exec, real_rollback = Session.exec, OrmSession.rollback
    rollbacks: list[str] = []

    def exec_(session, statement, *args, **kwargs):
        if getattr(statement, "_for_update_arg", None) is not None:
            raise OperationalError("SELECT ... FOR UPDATE NOWAIT", {}, _LockNotAvailable())
        return real_exec(session, statement, *args, **kwargs)

    def rollback(session):
        rollbacks.append("rollback")
        return real_rollback(session)

    monkeypatch.setattr(Session, "exec", exec_)
    monkeypatch.setattr(OrmSession, "rollback", rollback)
    return rollbacks


# --------------------------------------------------------------------------- #
# Requests
# --------------------------------------------------------------------------- #


def _version_id(engine, business_id: str) -> str:
    with Session(engine) as s:
        return s.exec(select(ModelVersion).where(ModelVersion.business_id == business_id)).first().id


def _nbm(request, engine, mock_ws, monkeypatch) -> tuple[str, dict]:
    return request.getfixturevalue("seed_business"), {"intent": "new-base-model", "catalog": "test_catalog"}


def _vibe_new_ecm_mvm(request, engine, mock_ws, monkeypatch) -> tuple[str, dict]:
    bid = request.getfixturevalue("seed_business_with_version")
    client = request.getfixturevalue("client_with_agent")
    mv_id = _version_id(engine, bid)
    resp = client.post(f"/api/businesses/{bid}/inputs", json={"text": "Add a loyalty domain", "version_id": mv_id},
                       headers={"X-Forwarded-Email": "race@x.com"})
    assert resp.status_code == 200, resp.text
    return bid, {"intent": "vibe-new-ecm-mvm", "parent_version_id": mv_id, "catalog": "test_catalog",
                 "input_ids": [resp.json()["id"]]}


def _simple_install(request, engine, mock_ws, monkeypatch) -> tuple[str, dict]:
    return request.getfixturevalue("seed_business_with_version"), {"intent": "install", "catalog": "test_catalog"}


def _legacy_vibe(request, engine, mock_ws, monkeypatch) -> tuple[str, dict]:
    monkeypatch.setattr(preflight_mod, "_orchestrator_intent_registered", lambda intent: False)
    return request.getfixturevalue("seed_business_with_version"), {
        "intent": "vibe-iterate", "catalog": "test_catalog", "vibe_instructions": "merge customer and account",
    }


CREATE_BRANCHES = [
    pytest.param(_nbm, True, id="new-base-model"),
    pytest.param(_vibe_new_ecm_mvm, True, id="vibe-new-ecm-mvm"),
    pytest.param(_simple_install, True, id="simple-orchestrated"),
    pytest.param(_legacy_vibe, False, id="legacy-launch"),
]


def _run_ops(engine, run_id: str) -> list[RunOperation]:
    with Session(engine) as s:
        return s.exec(select(RunOperation).where(RunOperation.run_id == run_id)).all()


# --------------------------------------------------------------------------- #
# No commit between the lock and the Run row
# --------------------------------------------------------------------------- #


@pytest.mark.parametrize("branch, orchestrated", CREATE_BRANCHES)
def test_create_commits_nothing_between_the_lock_and_the_run_row(
    request, client_with_agent, engine, mock_ws, monkeypatch, branch, orchestrated,
):
    bid, body = branch(request, engine, mock_ws, monkeypatch)
    _mock_run_now(mock_ws)
    spy = CommitSpy(monkeypatch)
    resp = client_with_agent.post(f"/api/businesses/{bid}/runs", json=body)
    assert resp.status_code == 200, resp.text
    assert bool(_run_ops(engine, resp.json()["id"])) is orchestrated
    assert spy.lock_calls == 1
    assert spy.runs_written == 1
    assert spy.violations == [], "\n---\n".join(spy.violations)


def _orchestrated_failed_run(request, client, engine, mock_ws, monkeypatch) -> tuple[str, str]:
    bid = request.getfixturevalue("seed_business")
    resp = client.post(f"/api/businesses/{bid}/runs", json={"intent": "new-base-model", "catalog": "test_catalog"})
    assert resp.status_code == 200, resp.text
    _second_step_failed(engine, resp.json()["id"])
    return bid, resp.json()["id"]


def _legacy_failed(request, client, engine, mock_ws, monkeypatch) -> tuple[str, str]:
    bid = request.getfixturevalue("seed_business")
    return bid, _legacy_failed_run(engine, bid, dict(_LEGACY_WIDGETS))


RETRY_BRANCHES = [
    pytest.param(_orchestrated_failed_run, id="orchestrated-resume"),
    pytest.param(_legacy_failed, id="legacy-replay"),
]


@pytest.mark.parametrize("failed_run", RETRY_BRANCHES)
def test_retry_commits_nothing_between_the_lock_and_the_rerun(
    request, client_with_agent, engine, mock_ws, monkeypatch, failed_run,
):
    _mock_run_now(mock_ws)
    bid, run_id = failed_run(request, client_with_agent, engine, mock_ws, monkeypatch)
    spy = CommitSpy(monkeypatch)
    resp = client_with_agent.post(f"/api/businesses/{bid}/runs/{run_id}/retry")
    assert resp.status_code == 200, resp.text
    assert resp.json()["status"] == "running"
    assert spy.lock_calls == 1
    assert spy.runs_written == 1
    assert spy.violations == [], "\n---\n".join(spy.violations)


def test_the_spy_catches_a_commit_in_the_lock_window(
    request, client_with_agent, engine, mock_ws, monkeypatch,
):
    """The spy itself: a commit after the lock (here a level-2 check that
    commits) is reported."""
    bid, body = _nbm(request, engine, mock_ws, monkeypatch)
    _mock_run_now(mock_ws)
    spy = CommitSpy(monkeypatch)
    real = preflight_mod._unfinished_cleanup_blockers

    def committing(business, data, agent_config, base, session):
        session.commit()
        return real(business, data, agent_config, base, session)

    monkeypatch.setattr(preflight_mod, "_unfinished_cleanup_blockers", committing)
    resp = client_with_agent.post(f"/api/businesses/{bid}/runs", json=body)
    assert resp.status_code == 200, resp.text
    assert len(spy.violations) == 1
    assert "committing" in spy.violations[0]


def test_create_reads_the_agent_config_row_before_the_lock(
    request, client, engine, mock_ws, monkeypatch, config,
):
    """With no AgentConfig row, create's bootstrap commits it before the
    pre-flight takes the lock (level 1 then refuses the unconfigured agent)."""
    bid = request.getfixturevalue("seed_business")
    spy = CommitSpy(monkeypatch)
    resp = client.post(f"/api/businesses/{bid}/runs", json={"intent": "new-base-model", "catalog": "test_catalog"})
    assert resp.status_code == 422, resp.text
    assert resp.json()["detail"]["error"] == "config_missing"
    assert spy.lock_calls == 0
    assert spy.violations == []
    with Session(engine) as s:
        from vibe_modeling.backend.db_models import AgentConfig

        assert s.exec(select(AgentConfig)).one().deployment_catalog == config.deployment_catalog


# --------------------------------------------------------------------------- #
# Lock placement and refusals
# --------------------------------------------------------------------------- #


def test_a_level_one_blocker_refuses_without_the_lock(request, client_with_agent, engine, mock_ws, monkeypatch):
    bid, body = _nbm(request, engine, mock_ws, monkeypatch)
    mock_ws.workspace.get_status.side_effect = PermissionDenied("no notebook access")
    spy = CommitSpy(monkeypatch)
    resp = client_with_agent.post(f"/api/businesses/{bid}/runs", json=body)
    assert resp.status_code == 400, resp.text
    assert spy.lock_calls == 0


def _active_run(engine, business_id: str) -> str:
    with Session(engine) as s:
        run = Run(business_id=business_id, intent="install", status="running")
        s.add(run)
        s.commit()
        return run.id


@pytest.mark.parametrize("branch, orchestrated", CREATE_BRANCHES)
def test_a_held_lock_refuses_create_before_level_two_and_writes_nothing(
    request, client_with_agent, engine, mock_ws, monkeypatch, branch, orchestrated,
):
    """Another request holds the lock: 409 "Another request for this business
    is in progress" after a rollback, even with an active run (the lock comes
    first), with no level-2 read and nothing written."""
    bid, body = branch(request, engine, mock_ws, monkeypatch)
    _active_run(engine, bid)
    _mock_run_now(mock_ws)
    before = table_digests(engine)
    mock_ws.schemas.get.reset_mock()
    rollbacks = hold_the_lock(monkeypatch)
    resp = client_with_agent.post(f"/api/businesses/{bid}/runs", json=body)
    assert resp.status_code == 409, resp.text
    assert resp.json()["detail"] == _runs.LOCK_BUSY_MESSAGE
    assert rollbacks
    mock_ws.schemas.get.assert_not_called()
    mock_ws.jobs.run_now.assert_not_called()
    assert changed_tables(before, table_digests(engine)) == set()


def test_an_active_run_refuses_a_second_create(request, client_with_agent, engine, mock_ws, monkeypatch):
    """E3 (a), sequential: the first create's run is active, so the second
    gets the active-run 409 naming it, and writes nothing."""
    bid, body = _nbm(request, engine, mock_ws, monkeypatch)
    _mock_run_now(mock_ws)
    first = client_with_agent.post(f"/api/businesses/{bid}/runs", json=body)
    assert first.status_code == 200, first.text
    before = table_digests(engine)
    second = client_with_agent.post(f"/api/businesses/{bid}/runs", json=body)
    assert second.status_code == 409, second.text
    assert second.json()["detail"] == _runs.active_run_message(first.json()["id"])
    assert changed_tables(before, table_digests(engine)) == set()


@pytest.mark.parametrize("failed_run", RETRY_BRANCHES)
def test_retry_while_another_run_is_active_is_409(
    request, client_with_agent, engine, mock_ws, monkeypatch, failed_run,
):
    """E3 (d): retry gains the active-run check create has."""
    _mock_run_now(mock_ws)
    bid, run_id = failed_run(request, client_with_agent, engine, mock_ws, monkeypatch)
    active = _active_run(engine, bid)
    mock_ws.jobs.run_now.reset_mock()
    before = table_digests(engine)
    resp = client_with_agent.post(f"/api/businesses/{bid}/runs/{run_id}/retry")
    assert resp.status_code == 409, resp.text
    assert resp.json()["detail"] == _runs.active_run_message(active)
    mock_ws.jobs.run_now.assert_not_called()
    assert changed_tables(before, table_digests(engine)) == set()


@pytest.mark.parametrize("failed_run", RETRY_BRANCHES)
def test_a_held_lock_refuses_retry(request, client_with_agent, engine, mock_ws, monkeypatch, failed_run):
    _mock_run_now(mock_ws)
    bid, run_id = failed_run(request, client_with_agent, engine, mock_ws, monkeypatch)
    mock_ws.jobs.run_now.reset_mock()
    before = table_digests(engine)
    rollbacks = hold_the_lock(monkeypatch)
    resp = client_with_agent.post(f"/api/businesses/{bid}/runs/{run_id}/retry")
    assert resp.status_code == 409, resp.text
    assert resp.json()["detail"] == _runs.LOCK_BUSY_MESSAGE
    assert rollbacks
    mock_ws.jobs.run_now.assert_not_called()
    assert changed_tables(before, table_digests(engine)) == set()


def test_a_legacy_retry_with_no_catalog_is_refused_before_launch(
    request, client_with_agent, engine, mock_ws, monkeypatch,
):
    """A stored map with an empty ``deployment_catalog`` (a model-producing
    op): ``launch_run`` refuses it, retry answers 422 and the run stays failed."""
    bid = request.getfixturevalue("seed_business")
    run_id = _legacy_failed_run(engine, bid, {**_LEGACY_WIDGETS, "deployment_catalog": ""})
    resp = client_with_agent.post(f"/api/businesses/{bid}/runs/{run_id}/retry")
    assert resp.status_code == 422, resp.text
    assert resp.json()["detail"] == (
        "Cannot retry this run: its stored parameters have no deployment catalog. Start a new run instead."
    )
    mock_ws.jobs.run_now.assert_not_called()
    mock_ws.jobs.update.assert_not_called()
    with Session(engine) as s:
        assert s.get(Run, run_id).status == "failed"


def test_validate_takes_no_lock(request, client_with_agent, engine, mock_ws, monkeypatch):
    """Validate reads; it neither locks nor refuses on a held lock, and it
    still reports the active run."""
    bid, body = _nbm(request, engine, mock_ws, monkeypatch)
    active = _active_run(engine, bid)
    spy = CommitSpy(monkeypatch)
    hold_the_lock(monkeypatch)
    resp = client_with_agent.post(f"/api/businesses/{bid}/runs/validate", json=body)
    assert resp.status_code == 200, resp.text
    assert spy.lock_calls == 0
    assert resp.json()["blockers"][0]["message"] == _runs.active_run_message(active)


# --------------------------------------------------------------------------- #
# Out-of-app versions (E3 b, c)
# --------------------------------------------------------------------------- #

HOME = "race_home"
BUSINESS = "Race Co"
SCOPE = "mvm"


def _registry_key(version: int) -> RegistryKey:
    return RegistryKey(HOME, agent_business_segment(BUSINESS), str(version), SCOPE)


def _stale_output() -> dict:
    """The 5.3.3 vibe output of a run that found v2 landed while it ran
    (captured shape): base v1, output v3, ``head_at_write`` 2."""
    doc = json.loads(STALE_VIBE.read_text())
    assert (doc["lineage"]["base_version"], doc["lineage"]["output_version"], doc["lineage"]["head_at_write"]) == (
        "1", "3", 2,
    )
    return doc


def _race(engine, fake_uc, *, out_of_app_file: bool) -> tuple[str, str]:
    """Lakebase has v1. An out-of-app run (started by hand on the agent job)
    registered v2 in ``HOME``; with ``out_of_app_file`` its model.json is
    readable in v2's folder, else not yet. The app's own vibe run, based on
    v1, found v2 at write time and wrote v3. Returns ``(run_id, parent_id)``."""
    with Session(engine) as session:
        parent = seed_synced_version(session, fake_uc, catalog=HOME, business_name=BUSINESS, version=1,
                                     scope=SCOPE, deployment_status="draft", uc_catalog="")
        fake_uc.add_agent_version(HOME, BUSINESS, 2, SCOPE, mock_model(), session_id=990002,
                                  write_model_json=out_of_app_file)
        fake_uc.add_agent_version(HOME, BUSINESS, 3, SCOPE, _stale_output(), session_id=990003)
        run = Run(business_id=parent.business_id, intent="vibe-iterate", status="running",
                  parameters_json=json.dumps({"dry_run": False}))
        session.add(run)
        session.commit()
        return run.id, parent.id


def _finish(engine, fake_uc, run_id: str, parent_id: str):
    """The vibe op's fetch and finalize, as its observe calls them."""
    with Session(engine) as session:
        parent = session.get(ModelVersion, parent_id)
        segment = agent_business_segment(BUSINESS)
        ctx = SimpleNamespace(
            run_id=run_id, business_id=parent.business_id, parent_version_id=parent.id,
            params={"vibe_instructions": "add loyalty", "deployment_catalog": HOME,
                    "business_name": segment, "parent_version_int": 1, "cataloging_style": "One Catalog"},
            inherited_params={},
        )
        handle = SimpleNamespace(extra={"deployment_catalog": HOME, "business_name": segment,
                                        "parent_version_int": 1})
        op = VibeIterate()
        model_json, info = op._fetch_model_json(handle, ctx, fake_uc.ws, session)
        result = op._finalize_success(handle, ctx, fake_uc.ws, session, model_json=model_json, fetch_info=info)
        session.commit()
        return info, result


def _versions(engine) -> list[int]:
    with Session(engine) as session:
        return sorted(mv.version for mv in session.exec(select(ModelVersion)).all())


def test_an_out_of_app_version_fails_the_op_with_version_mismatch(engine, fake_uc, monkeypatch):
    """E3 (b): the app expected v2; the out-of-app run holds v2 and its file
    is not readable yet, the app's agent wrote v3, and its Version Resolution
    event never reached the app. The fetch finds only v1's file: the op fails
    ``version_mismatch``, saves no version row, writes only the report row.
    (c): the checker is clean, v2 and v3 named as out-of-band (X-OOB imports them)."""
    monkeypatch.setattr(vibe_iterate_mod.time, "sleep", lambda s: None)
    run_id, parent_id = _race(engine, fake_uc, out_of_app_file=False)
    info, result = _finish(engine, fake_uc, run_id, parent_id)
    assert (info["expected_version"], info["fetched_version"], info["version_mismatch"]) == (2, 1, True)
    assert result.succeeded is False and result.output_version_id is None
    assert "not the expected version v2" in result.error
    assert _versions(engine) == [1]
    with Session(engine) as session:
        assert session.get(RunAgentReport, run_id) is not None
        assert_lakebase_metamodel_consistent(session, fake_uc, allow_orphans=[_registry_key(2), _registry_key(3)])


def test_the_version_the_agent_reports_is_the_one_saved(engine, fake_uc):
    """The same race with the agent's Version Resolution event mirrored
    (v2 taken, resolved to v3): the app saves v3 from v3's folder, never the
    out-of-app v2. (c): clean, v2 the one out-of-band version."""
    run_id, parent_id = _race(engine, fake_uc, out_of_app_file=True)
    with Session(engine) as session:
        session.add(RunProgressEvent(
            run_id=run_id, event_seq=1, stage_name=STAGE_NAME, step_name=STEP_NAME, status="stage_warning",
            result_json=json.dumps({"original_target": 2, "new_target": 3, "target_scope": SCOPE,
                                    "source_version": 1, "source_scope": SCOPE}),
        ))
        session.commit()
    info, result = _finish(engine, fake_uc, run_id, parent_id)
    assert (info["expected_version"], info["fetched_version"], info["version_mismatch"]) == (3, 3, False)
    assert result.succeeded is True
    assert _versions(engine) == [1, 3]
    with Session(engine) as session:
        assert_lakebase_metamodel_consistent(session, fake_uc, allow_orphans=[_registry_key(2)])


@pytest.mark.xfail(strict=True, reason=(
    "Known gap, no v0.9.0 unit: with the Version Resolution event missed and the out-of-app v2 "
    "readable, the app takes the out-of-app model.json as its run's v2 (its lineage names output "
    "v2). Telling them apart needs a check of the file's vibe_session_id against the run's."
))
def test_an_out_of_app_file_at_the_expected_version_is_not_taken(engine, fake_uc):
    run_id, parent_id = _race(engine, fake_uc, out_of_app_file=True)
    info, result = _finish(engine, fake_uc, run_id, parent_id)
    assert result.succeeded is False
    assert _versions(engine) == [1]
