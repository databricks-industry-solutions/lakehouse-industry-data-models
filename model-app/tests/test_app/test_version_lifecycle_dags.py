"""Install DAG shapes, and what their ops do to the version state.

Free catalog: one install step. Catalog held by another version of the scope
(confirmed): uninstall it with its dispatched prefix and id, then install the
whole file. That DAG ends with the old version ``uninstalled`` (X19) and the
installed one current (B11). An install away from the version's
``files_catalog`` reads the model.json there.
"""
from __future__ import annotations

from types import SimpleNamespace
from unittest.mock import MagicMock

import pytest
from sqlmodel import Session

from vibe_modeling.backend.core import resolve_install_target_catalog
from vibe_modeling.backend.db_models import Business, ModelVersion
from vibe_modeling.backend.services.operations import OperationContext, OperationDispatchHandle
from vibe_modeling.backend.services.operations.install import Install
from vibe_modeling.backend.services.operations.uninstall import Uninstall

from ._lifecycle_fixtures import agent_exits_ok, install_output
from vibe_modeling.backend.services.orchestrator.dag_factories import dag_for_install
from vibe_modeling.backend.services.version_files import version_model_json_candidates

CAT = "cat_a"
OTHER = "cat_b"


def _req(**kw):
    base = dict(
        catalog=None, deployment_catalog=None, cataloging_style="One Catalog",
        scope=None, schema_prefix=None, version_int=None, naming_convention=None,
        primary_key_suffix=None, table_id_type=None, schema_suffix=None, tag_prefix=None,
    )
    base.update(kw)
    return SimpleNamespace(**base)


def _mv(version, *, scope="ecm", uc=CAT, files=CAT, deployment="deployed", status="completed", **kw):
    return ModelVersion(
        id=f"mv-{version}", business_id="biz-1", version=version, scope=scope, status=status,
        deployment_status=deployment, uc_catalog=uc, files_catalog=files, **kw,
    )


BUSINESS = SimpleNamespace(name="Acme Co")
AGENT_CFG = SimpleNamespace(deployment_catalog="meta_cat")


def _install_ctx(mv):
    """The ``ctx`` the route builds: the version's own model.json candidates."""
    return SimpleNamespace(
        parent_mv=mv,
        context_file_candidates=version_model_json_candidates(MagicMock(), mv, BUSINESS.name),
    )


def _folders(catalog, version=3):
    root = f"/Volumes/{catalog}/_metamodel/vol_root/business/acme_co"
    return [f"{root}/v{version}/ecm/model.json", f"{root}/ecm_v{version}/model.json"]


class TestInstallTarget:
    def test_request_catalog_wins(self):
        assert resolve_install_target_catalog(_req(catalog=OTHER), _mv(3), AGENT_CFG) == OTHER

    def test_installed_version_defaults_to_its_install_catalog(self):
        mv = _mv(3, uc=OTHER, files=CAT)
        assert resolve_install_target_catalog(_req(), mv, AGENT_CFG) == OTHER

    def test_not_installed_defaults_to_its_files_catalog(self):
        mv = _mv(3, uc=OTHER, files=CAT, deployment="uninstalled")
        assert resolve_install_target_catalog(_req(), mv, AGENT_CFG) == CAT

    def test_neither_falls_back_to_the_run_default(self):
        mv = _mv(3, uc="", files=None, deployment="draft")
        assert resolve_install_target_catalog(_req(), mv, AGENT_CFG) == "meta_cat"


class TestInstallDagShape:
    def test_free_catalog_is_one_install_step(self):
        mv = _mv(3, deployment="uninstalled")
        dag = dag_for_install(_req(), BUSINESS, SimpleNamespace(parent_mv=mv), AGENT_CFG)
        assert [s.name for s in dag.steps] == ["install"]
        params = dag.steps[0].params
        assert params["deployment_catalog"] == CAT
        assert params["version_id"] == mv.id
        assert params["context_file_candidates"] == [
            f"/Volumes/{CAT}/_metamodel/vol_root/business/acme_co/v3/ecm/model.json",
            f"/Volumes/{CAT}/_metamodel/vol_root/business/acme_co/ecm_v3/model.json",
        ]

    def test_install_away_from_the_files_catalog_reads_the_file_there_first(self):
        mv = _mv(3, deployment="uninstalled")
        dag = dag_for_install(_req(catalog=OTHER), BUSINESS, _install_ctx(mv), AGENT_CFG)
        assert dag.steps[0].params["deployment_catalog"] == OTHER
        assert dag.steps[0].params["context_file_candidates"] == [*_folders(CAT), *_folders(OTHER)]

    def test_import_keeps_its_source_path_first(self):
        mv = _mv(3, deployment="draft", files="src", import_source_path="/Volumes/src/a/b/model.json")
        dag = dag_for_install(_req(catalog=OTHER), BUSINESS, _install_ctx(mv), AGENT_CFG)
        assert dag.steps[0].params["context_file_candidates"] == [
            "/Volumes/src/a/b/model.json", *_folders("src"), *_folders(OTHER),
        ]

    def test_a_downloaded_industry_version_never_sends_its_github_source(self):
        mv = _mv(3, deployment="draft", files="src", import_source_path="github://org/repo/v1/ecm/model.json")
        dag = dag_for_install(_req(catalog=OTHER), BUSINESS, _install_ctx(mv), AGENT_CFG)
        assert dag.steps[0].params["context_file_candidates"] == [*_folders("src"), *_folders(OTHER)]

    def test_occupied_catalog_is_uninstall_then_install(self):
        target = _mv(3, deployment="uninstalled")
        occupant = _mv(5)
        ctx = SimpleNamespace(
            parent_mv=target, occupant=occupant,
            occupant_install_widgets={"schema_prefix": "ecm_v5_", "cataloging_style": "One Catalog"},
        )
        dag = dag_for_install(_req(catalog=CAT, schema_prefix="ecm_"), BUSINESS, ctx, AGENT_CFG)
        assert dag.intent == "install"
        assert [s.name for s in dag.steps] == ["uninstall", "install"]
        uninstall, install = (s.params for s in dag.steps)
        assert uninstall["version_id"] == occupant.id
        assert uninstall["model_version"] == 5
        assert uninstall["schema_prefix"] == "ecm_v5_"
        assert uninstall["deployment_catalog"] == CAT
        assert install["version_id"] == target.id
        assert install["model_version"] == 3
        assert install["schema_prefix"] == "ecm_"


def _terminated_success_ws():
    ws = MagicMock()
    job_run = MagicMock()
    job_run.state.life_cycle_state.value = "TERMINATED"
    job_run.state.result_state.value = "SUCCESS"
    job_run.state.state_message = ""
    ws.jobs.get_run.return_value = job_run
    agent_exits_ok(ws)
    return ws


def _observe(op, params, session, parent_version_id=None, extra=None):
    ctx = OperationContext(
        run_id="run-1", operation_id="op-1", business_id="biz",
        parent_version_id=parent_version_id, params=params, inherited_params={},
    )
    handle = OperationDispatchHandle(databricks_run_id=1, vibe_session_id=None, extra=extra or {})
    return op.observe(handle, ctx, _terminated_success_ws(), session)


def test_install_over_occupant_ends_with_the_old_version_uninstalled(engine):
    with Session(engine) as s:
        biz = Business(name="Acme Co", description="d")
        s.add(biz)
        s.flush()
        v3 = ModelVersion(business_id=biz.id, version=3, scope="ecm", status="superseded",
                          deployment_status="uninstalled", uc_catalog=CAT, files_catalog=CAT)
        v5 = ModelVersion(business_id=biz.id, version=5, scope="ecm", status="completed",
                          deployment_status="deployed", uc_catalog=CAT, files_catalog=CAT)
        s.add(v3)
        s.add(v5)
        s.commit()
        ctx = SimpleNamespace(parent_mv=v3, occupant=v5, occupant_install_widgets=None)
        dag = dag_for_install(_req(catalog=CAT), biz, ctx, AGENT_CFG)
        uninstall_params, install_params = (step.params for step in dag.steps)

        _observe(Uninstall(), uninstall_params, s)
        assert v5.deployment_status == "uninstalled"
        obs = _observe(Install(), install_params, s, extra={"deployment_catalog": CAT})
        s.commit()

        assert obs.terminal_result.succeeded
        assert obs.terminal_result.rollback_state["promoted_version_id"] == v3.id
        assert obs.terminal_result.rollback_state["replaced_version_ids"] == [v5.id]
        s.refresh(v3)
        s.refresh(v5)
        assert (v3.status, v3.deployment_status, v3.uc_catalog) == ("completed", "deployed", CAT)
        assert (v5.status, v5.deployment_status) == ("superseded", "uninstalled")
        assert v5.replaced_by_version_id == v3.id and v5.replaced_at is not None


class TestUninstallTargetInTheFactory:
    """The factory's own default, for the styles the create path does not
    fill (Catalog per Division / Domain)."""

    @pytest.mark.parametrize("style", ["Catalog per Division", "Catalog per Domain"])
    def test_uninstall_targets_where_the_version_is_installed(self, style):
        from vibe_modeling.backend.services.orchestrator.dag_factories import dag_for_uninstall

        mv = _mv(3, uc="installed_cat", files=CAT)
        dag = dag_for_uninstall(_req(cataloging_style=style), BUSINESS, SimpleNamespace(parent_mv=mv), AGENT_CFG)
        assert dag.steps[0].params["deployment_catalog"] == "installed_cat"

    def test_never_installed_falls_back_to_the_run_default(self):
        from vibe_modeling.backend.services.orchestrator.dag_factories import dag_for_uninstall

        mv = _mv(3, uc="", files=None, deployment="draft")
        dag = dag_for_uninstall(_req(cataloging_style="Catalog per Division"), BUSINESS,
                                SimpleNamespace(parent_mv=mv), AGENT_CFG)
        assert dag.steps[0].params["deployment_catalog"] == "meta_cat"


# The agent's exit JSON of run 66eb577e's install step (P0 attempt 5, dbx
# 997593151839964): the job ended SUCCESS, the registration did not.
FAILED_REGISTRATION = {
    "status": "success_with_warnings", "operation": "install model", "business_name": "wt_p0_grain_coop",
    "version": "3", "catalog": "business_3", "scope": "mvm", "duration_seconds": 117.99,
    "physical": {"success": True, "domains": 3, "tables": 23, "fks": 82}, "metamodel": {"success": False},
    "warnings": [
        "[vibe-scope-deploy-plan FIRED v5.1.4] model.json _vibe_scope carries no mode/entries; metric views "
        "are scoped by changed owner products only alias=vibe-scope-deploy-plan",
        "  ⚠️ Metamodel: Failed - (io.delta.exceptions.ConcurrentAppendException) [DELTA_CONCURRENT_APPEND.ROW_LEV",
        "⚠️ INTEGRITY CHECK FAILED: expected 3 domain schemas in business_3, found 0. Physical install may "
        "have silently partial-failed.",
    ],
    "warning_count": 3,
}
# The same install that registered (dbx 807810182811012).
REGISTERED = {**FAILED_REGISTRATION, "metamodel": {"success": True}, "warnings": FAILED_REGISTRATION["warnings"][:1],
              "warning_count": 1}
# The agent's exit JSON of the T1-S rehearsal's failed v2 install (dbx
# 1030771147474369), verbatim: every table and registry row written, only the
# registrar's DELETE of its business row lost the race with a progress flush.
CONCURRENT_REGISTRY_WRITE = {
    "status": "success_with_warnings", "operation": "install model", "business_name": "t1s_corner_bakery",
    "version": "2", "catalog": "t1s_fresh", "scope": "mvm", "duration_seconds": 63.84,
    "physical": {"success": True, "domains": 3, "tables": 24, "fks": 2}, "metamodel": {"success": False},
    "warnings": [
        "[vibe-scope-deploy-plan FIRED v5.1.4] model.json _vibe_scope carries no mode/entries; metric views "
        "are scoped by changed owner products only alias=vibe-scope-deploy-plan",
        "[metamodel-registrar FIRED v5.1.4] t1s_corner_bakery v2 (mvm) -> `t1s_fresh`.`_metamodel`: domains 3/3, "
        "products 24/24, attributes 759/759, business_row=True, deploy_status=installed, errors=['delete business: "
        "(io.delta.exceptions.ConcurrentAppendException) [DELTA_CONCURRENT_APPEND.ROW_LEVEL_CHANGES] Transaction "
        "conflict detected. A concurrent UPDATE added data to table t1s_fresh._metamodel.business committ'] "
        "alias=metamodel-registrar",
        "  ⚠️ Metamodel: Failed - delete business: (io.delta.exceptions.ConcurrentAppendException) [DELTA_CONCURRE",
    ],
    "warning_count": 3,
}
CONCURRENT_REGISTRY_WRITE_TEXT = (
    "The agent created the tables but a concurrent write to its registry failed. "
    "Run the install again; it finishes the registration."
)


def _with_registrar_summary(old: str, new: str) -> dict:
    """``CONCURRENT_REGISTRY_WRITE`` with ``old`` replaced in its registrar summary."""
    warnings = list(CONCURRENT_REGISTRY_WRITE["warnings"])
    assert old in warnings[1]
    warnings[1] = warnings[1].replace(old, new)
    return {**CONCURRENT_REGISTRY_WRITE, "warnings": warnings}


def _ws_with_exit(result, *, truncated=False, raises=False, ended_ago_s=0):
    import time as _time

    ws = _terminated_success_ws()
    ws.jobs.get_run.return_value.tasks = [SimpleNamespace(run_id=4242)]
    ws.jobs.get_run.return_value.end_time = int((_time.time() - ended_ago_s) * 1000)
    if raises:
        ws.jobs.get_run_output.side_effect = RuntimeError("temporarily unavailable")
    else:
        ws.jobs.get_run_output.return_value = install_output(result, truncated=truncated)
    return ws


class TestInstallRegistration:
    """``install model``'s exit JSON (nb 108138-108150): ``metamodel.success``
    false or the integrity check failing (nb 108093-108101) fails the step."""

    def _setup(self, engine):
        with Session(engine) as s:
            biz = Business(name="Acme Co", description="d")
            s.add(biz)
            s.flush()
            v3 = ModelVersion(business_id=biz.id, version=3, scope="mvm", status="superseded",
                              deployment_status="uninstalled", uc_catalog=CAT, files_catalog=CAT)
            v4 = ModelVersion(business_id=biz.id, version=4, scope="mvm", status="completed",
                              deployment_status="uninstalled", uc_catalog=CAT, files_catalog=CAT)
            s.add(v3)
            s.add(v4)
            s.commit()
            return biz.id, v3.id, v4.id

    def _observe(self, engine, result, v3_id, **ws_kw):
        ws = _ws_with_exit(result, **ws_kw)
        ctx = OperationContext(run_id="run-1", operation_id="op-1", business_id="b", parent_version_id=None,
                               params={"version_id": v3_id, "scope": "mvm", "business_name": "acme_co",
                                       "deployment_catalog": CAT, "schema_prefix": "mvm_", "model_version": 3},
                               inherited_params={})
        handle = OperationDispatchHandle(databricks_run_id=1, vibe_session_id=None, extra={"deployment_catalog": CAT})
        with Session(engine) as s:
            obs = Install().observe(handle, ctx, ws, s)
            s.commit()
        ws.jobs.get_run_output.assert_called_with(4242)
        return obs

    def test_a_failed_registration_fails_the_step_and_records_nothing(self, engine):
        biz, v3, v4 = self._setup(engine)
        obs = self._observe(engine, FAILED_REGISTRATION, v3)
        assert obs.terminal_result.succeeded is False
        assert "INTEGRITY CHECK FAILED" in obs.terminal_result.error
        assert "not recorded as installed" in obs.terminal_result.error
        # The failed row keeps the run diagnostics; the orchestrator never
        # rolls a failed row back.
        assert obs.terminal_result.rollback_state["jobs_terminal_result_state"] == "SUCCESS"
        with Session(engine) as s:
            assert s.get(ModelVersion, v3).deployment_status == "uninstalled"
            assert s.get(ModelVersion, v3).promoted_at is None
            assert s.get(ModelVersion, v4).status == "completed"

    def test_metamodel_failure_alone_fails_the_step(self, engine):
        biz, v3, v4 = self._setup(engine)
        result = {**FAILED_REGISTRATION, "warnings": []}
        assert self._observe(engine, result, v3).terminal_result.succeeded is False

    def test_a_lost_registry_write_race_says_so_and_still_fails(self, engine):
        biz, v3, v4 = self._setup(engine)
        obs = self._observe(engine, CONCURRENT_REGISTRY_WRITE, v3)
        assert obs.terminal_result.succeeded is False
        assert obs.terminal_result.error == CONCURRENT_REGISTRY_WRITE_TEXT
        with Session(engine) as s:
            assert s.get(ModelVersion, v3).deployment_status == "uninstalled"
            assert s.get(ModelVersion, v3).promoted_at is None

    @pytest.mark.parametrize(
        "result",
        [
            _with_registrar_summary("products 24/24", "products 20/24"),
            _with_registrar_summary("errors=['delete business: (io.delta.exceptions.ConcurrentAppendException)",
                                    "errors=['delete domain: (io.delta.exceptions.ConcurrentAppendException)"),
            _with_registrar_summary("errors=['delete business: (io.delta.exceptions.ConcurrentAppendException) "
                                    "[DELTA_CONCURRENT_APPEND.ROW_LEVEL_CHANGES]",
                                    "errors=['delete business: [TABLE_OR_VIEW_NOT_FOUND]"),
            _with_registrar_summary("'] alias=", "', 'product batch 0: [PARSE_SYNTAX_ERROR]'] alias="),
            {**CONCURRENT_REGISTRY_WRITE, "physical": {"success": False, "error": "x"}},
            {**CONCURRENT_REGISTRY_WRITE,
             "warnings": CONCURRENT_REGISTRY_WRITE["warnings"] + FAILED_REGISTRATION["warnings"][2:]},
        ],
        ids=["short_counts", "other_table", "not_concurrent", "second_error", "physical_failed", "integrity"],
    )
    def test_other_registration_failures_keep_the_generic_message(self, engine, result):
        biz, v3, v4 = self._setup(engine)
        obs = self._observe(engine, result, v3)
        assert obs.terminal_result.succeeded is False
        assert "did not register the version" in obs.terminal_result.error
        assert CONCURRENT_REGISTRY_WRITE_TEXT not in obs.terminal_result.error

    @pytest.mark.parametrize(
        "result", [REGISTERED, {k: v for k, v in REGISTERED.items() if k != "metamodel"}],
        ids=["registered", "no_metamodel_key"],
    )
    def test_a_registered_install_is_recorded(self, engine, result):
        biz, v3, v4 = self._setup(engine)
        assert self._observe(engine, result, v3).terminal_result.succeeded is True
        with Session(engine) as s:
            assert s.get(ModelVersion, v3).deployment_status == "deployed"


class TestInstallExitResultRead:
    """The app-agent boundary fails hard: the exit result is re-read while
    ``get_run_output`` raises, until 5 minutes after the job's end, then the
    step fails; an output that is read but unusable fails at once."""

    _setup = TestInstallRegistration._setup
    _observe = TestInstallRegistration._observe

    def test_a_raising_read_is_retried_before_the_deadline(self, engine):
        biz, v3, v4 = self._setup(engine)
        obs = self._observe(engine, None, v3, raises=True, ended_ago_s=10)
        assert obs.is_terminal is False and "reading the agent's result" in obs.progress_message
        with Session(engine) as s:
            assert s.get(ModelVersion, v3).deployment_status == "uninstalled"

    def test_a_raising_read_fails_after_the_deadline(self, engine):
        from vibe_modeling.backend.services.operations._agent_result import EXIT_RESULT_READ_DEADLINE_S

        biz, v3, v4 = self._setup(engine)
        obs = self._observe(engine, None, v3, raises=True, ended_ago_s=EXIT_RESULT_READ_DEADLINE_S + 5)
        assert obs.terminal_result.succeeded is False
        assert "could not be read" in obs.terminal_result.error

    @pytest.mark.parametrize(
        ("result", "truncated", "why"),
        [
            (None, False, "empty"),
            ("", False, "empty"),
            ("not json", False, "not JSON"),
            ("[1, 2]", False, "not an object"),
            (REGISTERED, True, "truncated"),
        ],
        ids=["none", "blank", "not_json", "not_object", "truncated"],
    )
    def test_an_unusable_result_fails_at_once(self, engine, result, truncated, why):
        biz, v3, v4 = self._setup(engine)
        obs = self._observe(engine, result, v3, truncated=truncated)
        assert obs.terminal_result.succeeded is False
        assert why in obs.terminal_result.error
        with Session(engine) as s:
            assert s.get(ModelVersion, v3).deployment_status == "uninstalled"
