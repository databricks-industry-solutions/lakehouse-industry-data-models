"""The app's writes of the agent's ``deploy_status`` (registry ownership).

- A seed (``import_metamodel_writer.write_metamodel``) is ``dry_run`` and
  records the version's folder as ``location``.
- Every successful uninstall marks the version's rows ``dry_run`` in the
  uninstall catalog (``metamodel_registry.set_deploy_status``). A release that
  fails or is left running is a run warning with the exact UPDATE under
  ``sql``; the run still succeeds, and the release is issued again when the
  next run step into that catalog is dispatched.
- Initial sync does not read an app seed as a Dry Run.

The agent facts behind it are pinned in ``test_registry_status_drift.py``.
"""
from __future__ import annotations

import json
import time
from types import SimpleNamespace
from unittest.mock import MagicMock

import pytest
from sqlmodel import Session, select

from vibe_modeling.backend.core._sql import SqlStatementError
from vibe_modeling.backend.db_models import AgentConfig, Business, Domain, ModelVersion, Run, RunOperation
from vibe_modeling.backend.initial_sync import InitialSyncService
from vibe_modeling.backend.routes._helpers import _build_run_out
from vibe_modeling.backend.services import import_metamodel_writer, metamodel_registry
from vibe_modeling.backend.services.operations import (
    OperationContext,
    OperationDispatchHandle,
    OperationObservation,
    OperationResult,
)
from vibe_modeling.backend.services.operations import uninstall as uninstall_op
from vibe_modeling.backend.services.operations._protocol import RUN_WARNINGS_KEY
from vibe_modeling.backend.services.operations._version_lifecycle import mark_version_deployed
from vibe_modeling.backend.services.orchestrator import Orchestrator
from vibe_modeling.backend.services.orchestrator.dag import Dag, OperationStep

from ._drift.fixtures import fake_uc, mock_model  # noqa: F401
from ._lifecycle_fixtures import UNINSTALL_EXIT_OK, install_output
from .test_agent_registry_schema_pin import _capturing_ws
from .test_drift_foundation import _capturing_ws as _capturing_reads
from .test_orchestrator_runner import FakePrimitive

CAT, OTHER, THIRD = "business_1", "other_cat", "third_cat"
FOLDER = "/Volumes/business_1/_metamodel/vol_root/business/acme/v1/mvm"


def _model(location="/Volumes/x/model.json"):
    return {"location": location, "domains": [{"name": "crop", "database_name": "mvm_crop", "products": []}]}


class TestSeed:
    def _business_insert(self, monkeypatch, **kw):
        monkeypatch.setattr(import_metamodel_writer, "ensure_metamodel_registry", lambda *a, **k: [])
        ws, statements = _capturing_ws()
        out = import_metamodel_writer.write_metamodel(
            ws, catalog=CAT, warehouse_id="wh", model_json=_model(), business_name="acme",
            scope="mvm", version=1, wait_mode="request", **kw,
        )
        assert out["errors"] == []
        [business] = [s for s in statements if "`_metamodel`.`business`" in s]
        columns = [c.strip().strip("`") for c in business.split("(", 1)[1].split(")", 1)[0].split(",")]
        return dict(zip(columns, _values(business)))

    def test_a_seed_is_dry_run_with_the_versions_folder(self, monkeypatch):
        row = self._business_insert(monkeypatch, location=FOLDER)
        assert row["deploy_status"] == "'dry_run'"
        assert row["location"] == f"'{FOLDER}'"
        assert row["session_id"] == "0"

    def test_without_a_folder_the_models_own_location_is_kept(self, monkeypatch):
        assert self._business_insert(monkeypatch)["location"] == "'/Volumes/x/model.json'"

    def test_seed_metamodel_one_passes_the_folder(self, monkeypatch):
        seen = {}
        monkeypatch.setattr(import_metamodel_writer, "write_metamodel", lambda ws, **kw: seen.update(kw) or {})
        import_metamodel_writer.seed_metamodel_one(
            MagicMock(), catalog=CAT, warehouse_id="wh", model_json=_model(), business_name="acme",
            scope="mvm", version=1, log_prefix="t", wait_mode="request", location=FOLDER,
        )
        assert seen["location"] == FOLDER


def _values(statement: str) -> list[str]:
    """The literals of the single VALUES tuple, split on top-level commas."""
    body = statement.split(" VALUES (", 1)[1].rsplit(")", 1)[0]
    out, cur, quoted = [], "", False
    for ch in body:
        if ch == "'":
            quoted = not quoted
        if ch == "," and not quoted:
            out.append(cur.strip())
            cur = ""
            continue
        cur += ch
    out.append(cur.strip())
    return out


class TestStatement:
    def test_the_release_statement(self):
        assert metamodel_registry.deploy_status_statement(CAT, "wt_kick", 3, "MVM", "dry_run") == (
            "UPDATE `business_1`.`_metamodel`.`business` SET deploy_status = 'dry_run' "
            "WHERE LOWER(business) = LOWER('Wt_Kick') AND version = '3' "
            "AND (model_scope = 'mvm' OR model_scope IS NULL) "
            "AND (LOWER(catalog) = LOWER('business_1') OR catalog IS NULL OR catalog = '')"
        )

    @pytest.mark.parametrize("catalog,status", [("bad-cat", "dry_run"), ("cat; DROP", "dry_run"), (CAT, "gone")])
    def test_it_refuses_what_it_cannot_write(self, catalog, status):
        with pytest.raises(ValueError):
            metamodel_registry.deploy_status_statement(catalog, "acme", 1, "ecm", status)

    def test_one_bounded_wait_left_running_on_timeout(self, monkeypatch):
        calls = []
        monkeypatch.setattr(metamodel_registry, "run", lambda *a, **kw: calls.append((a, kw)))
        metamodel_registry.set_deploy_status("ws", "wh", CAT, "acme", 1, "ecm", "dry_run")
        metamodel_registry.set_deploy_status("ws", "wh", CAT, "acme", 1, "ecm", "dry_run", wait="5s")
        [(args, kw), (_, short)] = calls
        assert args[:2] == ("ws", "wh") and args[2].startswith("UPDATE `business_1`")
        assert kw == {"wait_timeout": "30s", "on_timeout": "detach"}
        assert short == {"wait_timeout": "5s", "on_timeout": "detach"}


# --- Uninstall --------------------------------------------------------------


def _seed_versions(engine) -> dict[str, str]:
    """Acme v1 MVM installed in business_1 and other_cat; v2 MVM in business_1."""
    with Session(engine) as s:
        s.add(AgentConfig(job_id=1, job_name="j", warehouse_id="wh-1"))
        biz = Business(name="Acme", description="d")
        s.add(biz)
        s.flush()
        ids = {}
        for n in (1, 2):
            mv = ModelVersion(business_id=biz.id, version=n, scope="mvm", status="completed",
                              deployment_status="draft", files_catalog=CAT)
            s.add(mv)
            s.flush()
            s.add(Domain(version_id=mv.id, name="crop", database_name="mvm_crop"))
            ids[n] = mv.id
        mark_version_deployed(s, s.get(ModelVersion, ids[1]), OTHER)
        mark_version_deployed(s, s.get(ModelVersion, ids[1]), CAT)
        mark_version_deployed(s, s.get(ModelVersion, ids[2]), CAT)
        s.commit()
        return ids


def _registry(fake_uc):
    for catalog in (CAT, OTHER, THIRD):
        for n in (1, 2):
            fake_uc.add_agent_version(catalog, "Acme", n, "mvm", mock_model(), write_model_json=False)
            for row in fake_uc._registry[catalog]["business"]:
                row["catalog"] = catalog


def _statuses(fake_uc):
    return {
        (catalog, r["version"]): r["deploy_status"]
        for catalog in (CAT, OTHER, THIRD) for r in fake_uc.rows(catalog, "business")
    }


def _finished_job_ws(fake_uc):
    ws = fake_uc.ws
    job_run = MagicMock()
    job_run.state.life_cycle_state.value = "TERMINATED"
    job_run.state.result_state.value = "SUCCESS"
    job_run.state.state_message = ""
    job_run.tasks = [SimpleNamespace(run_id=4242)]
    job_run.end_time = int(time.time() * 1000)
    ws.jobs.get_run.return_value = job_run
    ws.jobs.get_run_output.return_value = install_output(UNINSTALL_EXIT_OK)
    return ws


def _observe(engine, ws, version_id, *, op_id="op-1"):
    ctx = OperationContext(
        run_id="run-1", operation_id=op_id, business_id="b", parent_version_id=version_id,
        params={"version_id": version_id, "scope": "mvm", "business_name": "acme",
                "deployment_catalog": CAT, "schema_prefix": "mvm_", "model_version": 1},
        inherited_params={},
    )
    handle = OperationDispatchHandle(databricks_run_id=1, vibe_session_id=None, extra={})
    with Session(engine) as s:
        obs = uninstall_op.Uninstall().observe(handle, ctx, ws, s)
        s.commit()
    return obs


class TestUninstallRelease:
    def test_it_releases_that_version_in_that_catalog_only(self, engine, fake_uc):
        ids = _seed_versions(engine)
        _registry(fake_uc)
        obs = _observe(engine, _finished_job_ws(fake_uc), ids[1])
        assert obs.terminal_result.succeeded
        assert RUN_WARNINGS_KEY not in obs.terminal_result.rollback_state
        assert uninstall_op.REGISTRY_RELEASE_PENDING_KEY not in obs.terminal_result.rollback_state
        assert obs.terminal_result.rollback_state[uninstall_op.REGISTRY_RELEASED_KEY] is True
        assert _statuses(fake_uc) == {
            (CAT, "1"): "dry_run", (CAT, "2"): "installed",
            (OTHER, "1"): "installed", (OTHER, "2"): "installed",
            (THIRD, "1"): "installed", (THIRD, "2"): "installed",
        }

    @pytest.mark.parametrize("error", [
        SqlStatementError("STILL_RUNNING", "statement still RUNNING after 30s; left running", statement_id="s1"),
        SqlStatementError("FAILED", "PERMISSION_DENIED: MODIFY on business"),
    ])
    def test_a_failed_release_warns_and_the_uninstall_stands(self, engine, fake_uc, error):
        ids = _seed_versions(engine)
        _registry(fake_uc)
        fake_uc.release_error = error
        obs = _observe(engine, _finished_job_ws(fake_uc), ids[1])
        result = obs.terminal_result
        assert result.succeeded and result.error is None
        statement = metamodel_registry.deploy_status_statement(CAT, "acme", 1, "mvm", "dry_run")
        assert result.rollback_state[RUN_WARNINGS_KEY] == [{
            "message": (
                "v1 MVM is uninstalled from business_1, but the app may not have marked it as not "
                "installed in business_1's _metamodel. The agent may still treat it as the owner of "
                "its schema names. The app tries again when the next install or run into business_1 "
                "starts; an admin can also run the statement below."
            ),
            "sql": statement,
        }]
        assert uninstall_op.REGISTRY_RELEASED_KEY not in result.rollback_state
        assert result.rollback_state[uninstall_op.REGISTRY_RELEASE_PENDING_KEY] == {
            "catalog": CAT, "business_name": "acme", "model_version": 1, "scope": "mvm",
            "version_id": ids[1], "sql": statement,
        }
        with Session(engine) as s:
            assert s.get(ModelVersion, ids[1]).deployment_status == "deployed"  # still in other_cat

    def test_the_run_page_gets_the_statement_under_its_own_key(self, engine, fake_uc):
        ids = _seed_versions(engine)
        fake_uc.release_error = SqlStatementError("FAILED", "denied")
        obs = _observe(engine, _finished_job_ws(fake_uc), ids[1])
        with Session(engine) as s:
            run = Run(business_id=s.get(ModelVersion, ids[1]).business_id, intent="uninstall", status="completed")
            s.add(run)
            s.flush()
            s.add(RunOperation(run_id=run.id, step_index=0, operation_name="uninstall", status="succeeded",
                               rollback_state_json=json.dumps(obs.terminal_result.rollback_state)))
            s.commit()
            [warning] = _build_run_out(run, MagicMock(), s).warnings
        assert warning["message"].startswith("v1 MVM is uninstalled from business_1, but the app may not")
        assert warning["sql"].startswith("UPDATE `business_1`.`_metamodel`.`business` SET deploy_status")
        assert warning["severity"] == "warning"


def _pending_op(engine, ids, *, catalog=CAT, version=1) -> str:
    with Session(engine) as s:
        run = Run(business_id=s.get(ModelVersion, ids[version]).business_id, intent="uninstall", status="completed")
        s.add(run)
        s.flush()
        statement = metamodel_registry.deploy_status_statement(catalog, "acme", version, "mvm", "dry_run")
        op = RunOperation(
            run_id=run.id, step_index=0, operation_name="uninstall", status="succeeded",
            rollback_state_json=json.dumps({
                RUN_WARNINGS_KEY: [{"message": "m", "sql": statement}],
                uninstall_op.REGISTRY_RELEASE_PENDING_KEY: {
                    "catalog": catalog, "business_name": "acme", "model_version": version, "scope": "mvm",
                    "version_id": ids[version], "sql": statement,
                },
            }),
        )
        s.add(op)
        s.commit()
        return op.id


def _state(engine, op_id) -> dict:
    with Session(engine) as s:
        return json.loads(s.get(RunOperation, op_id).rollback_state_json)


class TestReleaseOnly:
    """A source-industry version the run's business already replaced in the
    catalog: no agent job, the install row closes, the rows are released."""

    def _ctx(self, version_id):
        return OperationContext(
            run_id="run-1", operation_id="op-1", business_id="b", parent_version_id=version_id,
            params={"version_id": version_id, "scope": "mvm", "business_name": "acme", "deployment_catalog": CAT,
                    "schema_prefix": "mvm_", "model_version": 1, "release_only": True},
            inherited_params={},
        )

    def test_no_job_the_row_closes_and_the_rows_are_released(self, engine, fake_uc):
        ids = _seed_versions(engine)
        _registry(fake_uc)
        with Session(engine) as s:
            handle = uninstall_op.Uninstall().dispatch(self._ctx(ids[1]), fake_uc.ws, s)
            assert handle.databricks_run_id is None and handle.dispatched_widgets == {}
            obs = uninstall_op.Uninstall().observe(handle, self._ctx(ids[1]), fake_uc.ws, s)
            s.commit()
        fake_uc.ws.jobs.run_now.assert_not_called()
        assert obs.is_terminal and obs.terminal_result.succeeded
        assert RUN_WARNINGS_KEY not in obs.terminal_result.rollback_state
        with Session(engine) as s:
            from vibe_modeling.backend.services.operations._version_lifecycle import installed_catalogs

            assert installed_catalogs(s, s.get(ModelVersion, ids[1])) == [OTHER]
        assert _statuses(fake_uc)[(CAT, "1")] == "dry_run"
        assert _statuses(fake_uc)[(OTHER, "1")] == "installed"

    def test_a_failed_release_warns_the_same_way(self, engine, fake_uc):
        ids = _seed_versions(engine)
        fake_uc.release_error = SqlStatementError("FAILED", "denied")
        with Session(engine) as s:
            obs = uninstall_op.Uninstall().observe(
                OperationDispatchHandle(databricks_run_id=None, vibe_session_id=None, extra={}),
                self._ctx(ids[1]), fake_uc.ws, s,
            )
        state = obs.terminal_result.rollback_state
        assert obs.terminal_result.succeeded
        assert state[RUN_WARNINGS_KEY][0]["message"].startswith("v1 MVM is uninstalled from business_1, but the app may not")
        assert uninstall_op.REGISTRY_RELEASE_PENDING_KEY in state


class TestRetry:
    def _uninstalled(self, engine, ids):
        from vibe_modeling.backend.services.operations._version_lifecycle import mark_version_uninstalled

        with Session(engine) as s:
            mark_version_uninstalled(s, s.get(ModelVersion, ids[1]), CAT)
            s.commit()

    def test_the_next_run_into_the_catalog_issues_it_and_clears_it(self, engine, fake_uc):
        ids = _seed_versions(engine)
        _registry(fake_uc)
        self._uninstalled(engine, ids)
        op_id = _pending_op(engine, ids)
        with Session(engine) as s:
            uninstall_op.retry_registry_releases(s, fake_uc.ws, OTHER)
            s.commit()
        assert uninstall_op.REGISTRY_RELEASE_PENDING_KEY in _state(engine, op_id)
        assert _statuses(fake_uc)[(CAT, "1")] == "installed"
        with Session(engine) as s:
            uninstall_op.retry_registry_releases(s, fake_uc.ws, "BUSINESS_1")
            s.commit()
        state = _state(engine, op_id)
        assert uninstall_op.REGISTRY_RELEASE_PENDING_KEY not in state
        assert state[uninstall_op.REGISTRY_RELEASED_KEY] is True
        assert state[RUN_WARNINGS_KEY] == [{"message": "m", "sql": state[RUN_WARNINGS_KEY][0]["sql"]}]
        assert _statuses(fake_uc)[(CAT, "1")] == "dry_run"
        assert _statuses(fake_uc)[(OTHER, "1")] == "installed"
        # A retry runs before a step is dispatched: a short wait, then left running.
        assert [c.args["wait"] for c in fake_uc.calls if c.seam == "set_deploy_status"] == ["5s"]

    def test_a_failing_retry_stays_pending(self, engine, fake_uc):
        ids = _seed_versions(engine)
        _registry(fake_uc)
        self._uninstalled(engine, ids)
        op_id = _pending_op(engine, ids)
        fake_uc.release_error = SqlStatementError("FAILED", "denied")
        with Session(engine) as s:
            uninstall_op.retry_registry_releases(s, fake_uc.ws, CAT)
            s.commit()
        assert uninstall_op.REGISTRY_RELEASE_PENDING_KEY in _state(engine, op_id)
        assert uninstall_op.REGISTRY_RELEASED_KEY not in _state(engine, op_id)

    def test_a_version_installed_there_again_needs_no_release(self, engine, fake_uc):
        """Its install registered it ``installed``; a release now would undo that."""
        ids = _seed_versions(engine)
        _registry(fake_uc)
        op_id = _pending_op(engine, ids)
        with Session(engine) as s:
            uninstall_op.retry_registry_releases(s, fake_uc.ws, CAT)
            s.commit()
        state = _state(engine, op_id)
        assert uninstall_op.REGISTRY_RELEASE_PENDING_KEY not in state
        assert uninstall_op.REGISTRY_RELEASED_KEY not in state
        assert [c for c in fake_uc.calls if c.seam == "set_deploy_status"] == []
        assert _statuses(fake_uc)[(CAT, "1")] == "installed"

    def test_the_orchestrator_retries_before_it_dispatches_a_step_there(self, engine, fake_uc, monkeypatch):
        ids = _seed_versions(engine)
        retried = []
        monkeypatch.setattr(uninstall_op, "retry_registry_releases", lambda s, ws, catalog: retried.append(catalog))
        dispatched = []

        def on_dispatch(ctx, ws, session):
            dispatched.append(list(retried))
            return OperationDispatchHandle(databricks_run_id=7, vibe_session_id="s")

        install = FakePrimitive("install", on_dispatch=on_dispatch, on_observe=lambda *a: OperationObservation(
            progress_percent=0, progress_message="running", is_terminal=False, terminal_result=None))
        with Session(engine) as s:
            run = Run(business_id=s.get(ModelVersion, ids[1]).business_id, intent="install", status="pending",
                      parameters_json="{}")
            s.add(run)
            s.commit()
            s.refresh(run)
            Orchestrator(ws=fake_uc.ws, registry_get=lambda name: install).start(
                run, Dag(intent="install", steps=(OperationStep(name="install", params={"deployment_catalog": THIRD}),)),
                s,
            )
        assert dispatched == [[THIRD]]


class TestInitialSync:
    def test_the_dry_run_scan_leaves_out_app_seeds(self):
        ws, statements = _capturing_reads(with_result=False)
        InitialSyncService(None, ws, "wh")._query_dry_run_keys(CAT)
        assert statements[0].endswith("WHERE LOWER(TRIM(deploy_status)) = 'dry_run' AND COALESCE(session_id, -1) <> 0")

    def test_an_app_seed_is_not_synced_as_a_dry_run(self, engine, fake_uc):
        fake_uc.add_metamodel(CAT)
        import_metamodel_writer.seed_metamodel_one(
            fake_uc.ws, catalog=CAT, warehouse_id="wh", model_json=mock_model(), business_name="Acme",
            scope="mvm", version=1, log_prefix="t", wait_mode="request",
        )
        fake_uc.add_agent_version(CAT, "Acme", 2, "mvm", mock_model(), deploy_status="dry_run", session_id=42)
        assert [r["deploy_status"] for r in fake_uc.rows(CAT, "business")] == ["dry_run", "dry_run"]
        assert fake_uc._query_dry_run_keys(CAT) == {("acme", 2, "mvm")}
