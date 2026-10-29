"""Adversarial tests for the ``install`` deployment primitive.

These tests target *observable behavior* of the primitive contract (per
``docs/orchestrator-design.md`` §2 + §10), not any specific implementation
detail. They are written against the stub at
``services/operations/install.py`` — the production impl that lands on the
integration branch must satisfy the same assertions.

Categories covered (see Phase 2 Group B test slice):

1. Pydantic params validation (`InstallParams` model).
2. Widget shape assertions on `dispatch()`.
3. Idempotent re-dispatch when a `databricks_run_id` already exists for the
   same `(run_id, operation_id)`.
4. Job-state polling via `observe()`: PENDING/QUEUED → non-terminal,
   TERMINATED+SUCCESS → terminal+succeeded, TERMINATED+FAILED → terminal+
   succeeded=False with an error.
5. Rollback semantics: schema partially created + job FAILED → rollback
   drops the schema, idempotent on replay; safety gate refuses rollback
   when the job already TERMINATED with SUCCESS.
6. Permission-denied + unknown-catalog error propagation.

All tests run with a fresh registry (autouse fixture) so other primitive
modules' import side effects don't leak in.
"""

from __future__ import annotations

import logging
import os
import sys
from typing import Any
from unittest.mock import MagicMock

import pytest

sys.path.insert(
    0, os.path.join(os.path.dirname(__file__), "..", "..", "src", "app", "src")
)

from pydantic import ValidationError

from vibe_modeling.backend.services.operations import (
    OperationContext,
    OperationDispatchHandle,
    OperationObservation,
    OperationResult,
)
from vibe_modeling.backend.services.operations import _registry as _registry_module
from vibe_modeling.backend.services.operations.install import (
    Install,
    InstallParams,
    _build_install_widgets,
)
from vibe_modeling.backend.core._paths import model_json_volume_path

from ._lifecycle_fixtures import agent_exits_ok  # noqa: E402


# ---------------------------------------------------------------------------
# Fixtures
# ---------------------------------------------------------------------------


@pytest.fixture(autouse=True)
def _isolate_registry():
    _registry_module.reset_for_tests()
    yield
    # Restore the production registry so sibling test files that assume
    # primitives are name-resolvable (e.g. route-level tests calling
    # `validate_dag`) don't see a poisoned empty registry on test-order
    # interleave. Idempotent.
    _registry_module.reset_for_tests()
    _registry_module.restore_production_for_tests()


@pytest.fixture
def install_op() -> Install:
    return Install()


def _ctx(**overrides) -> OperationContext:
    base: dict[str, Any] = dict(
        run_id="run-1",
        operation_id="op-1",
        business_id="biz-1",
        parent_version_id="mv-1",
        params={
            "business_name": "test_corp",
            "deployment_catalog": "test_cat",
            "scope": "ecm",
            "cataloging_style": "One Catalog",
            "schema_prefix": "ecm_",
            "model_version": 1,
        },
        inherited_params={"cataloging_style": "One Catalog"},
    )
    base.update(overrides)
    return OperationContext(**base)


def _mock_ws_with_state(lcs: str, rs: str = "") -> MagicMock:
    ws = MagicMock()
    ws.config.host = "https://test.databricks.com"
    job_run = MagicMock()
    job_run.state.life_cycle_state.value = lcs
    job_run.state.result_state.value = rs
    job_run.state.state_message = ""
    ws.jobs.get_run.return_value = job_run
    agent_exits_ok(ws)
    file_resp = MagicMock()
    file_resp.contents.read.return_value = b'{"model": {}}'
    ws.files.download.return_value = file_resp
    return ws


# ---------------------------------------------------------------------------
# 1. Class attributes — contract surface
# ---------------------------------------------------------------------------


class TestInstallContract:
    def test_name_is_install(self, install_op):
        assert install_op.name == "install"

    def test_does_not_produce_version(self, install_op):
        # Per §10: install creates UC schemas, not ModelVersions.
        assert install_op.produces_version is False

    def test_params_model_is_install_params(self, install_op):
        assert install_op.params_model is InstallParams


# ---------------------------------------------------------------------------
# 2. Pydantic params validation
# ---------------------------------------------------------------------------


class TestInstallParamsValidation:
    def _good(self, **overrides) -> dict:
        base = {
            "business_name": "test_corp",
            "deployment_catalog": "test_cat",
            "scope": "ecm",
            "cataloging_style": "One Catalog",
            "schema_prefix": "ecm_",
            "model_version": 1,
        }
        base.update(overrides)
        return base

    def test_happy_path_validates(self):
        InstallParams(**self._good())

    def test_one_catalog_requires_schema_prefix(self):
        with pytest.raises(ValidationError) as ei:
            InstallParams(**self._good(schema_prefix=""))
        # schema_prefix must be flagged as the offending field path.
        msg = str(ei.value)
        assert "One Catalog" in msg or "schema_prefix" in msg

    def test_catalog_per_domain_forbids_schema_prefix(self):
        with pytest.raises(ValidationError):
            InstallParams(
                **self._good(
                    cataloging_style="Catalog per Domain",
                    schema_prefix="ecm_",
                )
            )

    def test_catalog_per_domain_with_empty_prefix_validates(self):
        # Mirror image of the test above — Catalog per Domain WITH no prefix
        # is the legal happy path.
        InstallParams(
            **self._good(cataloging_style="Catalog per Domain", schema_prefix="")
        )

    def test_catalog_per_division_with_empty_prefix_validates(self):
        InstallParams(
            **self._good(cataloging_style="Catalog per Division", schema_prefix="")
        )

    def test_deployment_catalog_with_invalid_chars_rejected(self):
        # UC catalog names must match [a-zA-Z][a-zA-Z0-9_]* — spaces, dashes,
        # dots are rejected. Keep this one (real bug class — bad catalog
        # names crash uc create at dispatch time, not at validation).
        with pytest.raises(ValidationError):
            InstallParams(**self._good(deployment_catalog="bad catalog name"))
        with pytest.raises(ValidationError):
            InstallParams(**self._good(deployment_catalog="bad-catalog"))


class TestInstallContextFilePath:
    """The ``context_file`` (model.json path) is composed through the canonical
    :func:`model_json_volume_path` builder, so the business segment matches the
    folder the agent wrote - not a raw ``business_name``.
    """

    def _params(self, **overrides) -> InstallParams:
        base: dict[str, Any] = dict(
            business_name="test_corp",
            deployment_catalog="test_cat",
            scope="ecm",
            cataloging_style="One Catalog",
            schema_prefix="ecm_",
            model_version=3,
        )
        base.update(overrides)
        return InstallParams(**base)

    def test_context_file_matches_canonical_builder(self):
        p = self._params()
        widgets = _build_install_widgets(p, "999")
        assert widgets["context_file"] == model_json_volume_path(
            p.deployment_catalog, p.business_name, int(p.model_version), p.scope
        )
        assert widgets["context_file"] == (
            "/Volumes/test_cat/_metamodel/vol_root/business/"
            "test_corp/v3/ecm/model.json"
        )

    def test_context_file_normalizes_digit_prefixed_name(self):
        # A digit-prefixed raw name can't pass InstallParams validation, so
        # bypass it with model_construct to prove the builder still normalizes
        # (leading "_" for a legal UC segment) rather than leaking the raw name.
        p = InstallParams.model_construct(
            business_name="7-Eleven",
            deployment_catalog="test_cat",
            scope="ecm",
            cataloging_style="One Catalog",
            schema_prefix="ecm_",
            model_version=1,
            context_file_candidates=[],
        )
        widgets = _build_install_widgets(p, "999")
        assert "/business/_7_eleven/v1/ecm/model.json" in widgets["context_file"]
        assert "7-Eleven" not in widgets["context_file"]
        # The widget value stays the RAW business_name (agent re-sanitizes it).
        assert widgets["business_name"] == "7-Eleven"

    def test_the_chosen_candidate_is_the_context_file(self):
        chosen = "/Volumes/other/path/import_source/model.json"
        p = self._params(context_file_candidates=[chosen, "/Volumes/x/model.json"])
        assert _build_install_widgets(p, "999", chosen)["context_file"] == chosen

    def test_without_a_chosen_candidate_the_first_candidate_is_used(self):
        first = "/Volumes/other/path/import_source/model.json"
        p = self._params(context_file_candidates=[first, "/Volumes/x/model.json"])
        assert _build_install_widgets(p, "999")["context_file"] == first


# ---------------------------------------------------------------------------
# 3. Widget shape on dispatch
# ---------------------------------------------------------------------------


class TestInstallDispatchWidgets:
    """Generic widget-shape assertions per the test plan.

    The test plan requires:
      widgets["operation"] == "install model"
      widgets["model_version"] == str(version_int)
      widgets["data_model_scopes"] is scope-appropriate.

    Production impl wires this through ``map_run_params_to_widgets`` /
    ``launch_run``; we patch ``launch_run`` and capture the widget dict it
    receives.
    """

    def _capture_launch(self, install_op, ctx) -> dict:
        ws = _mock_ws_with_state("RUNNING")
        session = MagicMock()
        captured: dict = {}

        def _fake_launch_run(ws_, job_id, widget_params, *args, **kwargs):
            captured.update(widget_params)
            return 12345

        # Patch the symbol that the production impl is expected to call.
        # Module path is documented in the stub's dispatch() comment.
        from unittest.mock import patch

        with patch(
            "vibe_modeling.backend.services.operations.install.launch_run",
            _fake_launch_run,
            create=True,
        ):
            install_op.dispatch(ctx, ws, session)
        return captured

    def test_operation_widget_is_install_model(self, install_op):
        widgets = self._capture_launch(install_op, _ctx())
        assert widgets["operation"] == "install model"

    def test_model_version_widget_is_string_int(self, install_op):
        ctx = _ctx(
            params={
                "business_name": "test_corp",
                "deployment_catalog": "test_cat",
                "scope": "ecm",
                "cataloging_style": "One Catalog",
                "schema_prefix": "ecm_",
                "model_version": 7,
            },
        )
        widgets = self._capture_launch(install_op, ctx)
        assert widgets["model_version"] == "7"

    def test_data_model_scopes_for_ecm(self, install_op):
        widgets = self._capture_launch(install_op, _ctx())
        # The agent widget value mapping (job_launcher.map_run_params_to_widgets)
        # uses the long form for the ECM scope.
        assert "ECM" in widgets["data_model_scopes"]

    def test_data_model_scopes_for_mvm(self, install_op):
        ctx = _ctx(
            params={
                "business_name": "test_corp",
                "deployment_catalog": "test_cat",
                "scope": "mvm",
                "cataloging_style": "One Catalog",
                "schema_prefix": "mvm_",
                "model_version": 1,
            }
        )
        widgets = self._capture_launch(install_op, ctx)
        assert "MVM" in widgets["data_model_scopes"]


# ---------------------------------------------------------------------------
# 4. Observe — job-state polling
# ---------------------------------------------------------------------------


class TestInstallObserve:
    def test_pending_is_not_terminal(self, install_op):
        ws = _mock_ws_with_state("PENDING")
        handle = OperationDispatchHandle(databricks_run_id=42, vibe_session_id=None)
        obs = install_op.observe(handle, _ctx(), ws, MagicMock())
        assert obs.is_terminal is False
        assert obs.terminal_result is None

    def test_queued_long_is_not_terminal(self, install_op):
        # Even with a very old started_at, QUEUED is non-terminal — this
        # verifies the primitive does NOT impose its own >5 min timeout
        # (orchestrator owns timeout policy).
        ws = _mock_ws_with_state("QUEUED")
        handle = OperationDispatchHandle(databricks_run_id=42, vibe_session_id=None)
        obs = install_op.observe(handle, _ctx(), ws, MagicMock())
        assert obs.is_terminal is False

    def test_running_is_not_terminal(self, install_op):
        ws = _mock_ws_with_state("RUNNING")
        handle = OperationDispatchHandle(databricks_run_id=42, vibe_session_id=None)
        obs = install_op.observe(handle, _ctx(), ws, MagicMock())
        assert obs.is_terminal is False

    def test_terminated_success_is_terminal_succeeded(self, install_op):
        ws = _mock_ws_with_state("TERMINATED", "SUCCESS")
        handle = OperationDispatchHandle(databricks_run_id=42, vibe_session_id=None)
        obs = install_op.observe(handle, _ctx(), ws, MagicMock())
        assert obs.is_terminal is True
        assert obs.terminal_result is not None
        assert obs.terminal_result.succeeded is True

    def test_terminated_failed_is_terminal_failed(self, install_op):
        ws = _mock_ws_with_state("TERMINATED", "FAILED")
        handle = OperationDispatchHandle(databricks_run_id=42, vibe_session_id=None)
        obs = install_op.observe(handle, _ctx(), ws, MagicMock())
        assert obs.is_terminal is True
        assert obs.terminal_result is not None
        assert obs.terminal_result.succeeded is False
        assert obs.terminal_result.error  # populated

    def test_internal_error_is_terminal_failed(self, install_op):
        ws = _mock_ws_with_state("INTERNAL_ERROR", "")
        handle = OperationDispatchHandle(databricks_run_id=42, vibe_session_id=None)
        obs = install_op.observe(handle, _ctx(), ws, MagicMock())
        assert obs.is_terminal is True
        assert obs.terminal_result.succeeded is False


# ---------------------------------------------------------------------------
# 6. Rollback — schema cleanup, idempotent, safety gate
# ---------------------------------------------------------------------------


class TestInstallRollback:
    def test_rollback_drops_schema_when_install_failed(self, install_op):
        """Spec §10: install partially-created + job FAILED → rollback drops
        the schema. We assert the rollback hits *some* schema-deletion
        primitive — either DROP SCHEMA via warehouse or a fire-and-forget
        uninstall job, depending on the impl. Either way, an observable
        side effect MUST be visible on `ws` or via `launch_run`.
        """
        from unittest.mock import patch

        ws = _mock_ws_with_state("TERMINATED", "FAILED")
        session = MagicMock()
        rollback_state = {
            "catalog": "test_cat",
            "schema_prefix": "ecm_",
            "scope": "ecm",
            "model_version": "1",
            "business_name": "test_corp",
        }

        launch_calls: list = []

        def _fake_launch_run(ws_, job_id, widget_params, *args, **kwargs):
            launch_calls.append(widget_params)
            return 22222

        with patch(
            "vibe_modeling.backend.services.operations.install.launch_run",
            _fake_launch_run,
            create=True,
        ):
            install_op.rollback(_ctx(), rollback_state, ws, session)

        # Either an uninstall job was launched OR a DROP SCHEMA SQL ran
        # against the warehouse — at least ONE of these signals must fire.
        ws_warehouse_calls = (
            ws.statement_execution.execute_statement.call_count
            + ws.statement_execution.execute.call_count
        )
        assert (
            len(launch_calls) > 0 or ws_warehouse_calls > 0
        ), "rollback must drop schema via uninstall job or DROP SCHEMA SQL"

        if launch_calls:
            # If an uninstall job was launched, it must use the right widget.
            assert launch_calls[0].get("operation") == "uninstall model version"

    def test_rollback_replay_is_idempotent(self, install_op):
        """Spec §2 invariant: replaying rollback against an already-rolled-back
        op MUST be a no-op (not raise). The state passed in is the SAME
        rollback_state from the first call — production impl detects "schema
        already gone" via NotFound / schema-not-found error and returns
        cleanly.
        """
        from unittest.mock import patch

        ws = MagicMock()
        ws.config.host = "https://t.databricks.com"
        # Simulate "schema already gone": the uninstall job gets a NotFound,
        # which the production impl catches and treats as a successful no-op.
        from databricks.sdk.errors import NotFound

        ws.statement_execution.execute_statement.side_effect = NotFound(
            "schema not found"
        )

        rollback_state = {
            "catalog": "test_cat",
            "schema_prefix": "ecm_",
            "scope": "ecm",
            "model_version": "1",
            "business_name": "test_corp",
            "_already_uninstalled": True,
        }

        def _fake_launch_run(ws_, job_id, widget_params, *args, **kwargs):
            return 33333

        with patch(
            "vibe_modeling.backend.services.operations.install.launch_run",
            _fake_launch_run,
            create=True,
        ):
            # First call — already-rolled-back state should not raise.
            install_op.rollback(_ctx(), rollback_state, ws, MagicMock())
            # Second call — replay must also not raise.
            install_op.rollback(_ctx(), rollback_state, ws, MagicMock())

    def test_rollback_safety_gate_refuses_when_job_terminated_success(
        self, install_op
    ):
        """Spec §6.3 + §10: the safety gate refuses rollback when the
        underlying Databricks job has TERMINATED with SUCCESS. We expect
        either a 409-equivalent exception or a clear refusal — the assertion
        is "rollback does not proceed to drop the schema."
        """
        from unittest.mock import patch

        ws = _mock_ws_with_state("TERMINATED", "SUCCESS")
        rollback_state = {
            "catalog": "test_cat",
            "schema_prefix": "ecm_",
            "scope": "ecm",
            "model_version": "1",
            "business_name": "test_corp",
            # The orchestrator passes this through when the in-flight job has
            # already succeeded — primitive checks it before tearing down.
            "job_terminated_success": True,
        }

        launch_calls: list = []

        def _fake_launch_run(ws_, job_id, widget_params, *args, **kwargs):
            launch_calls.append(widget_params)
            return 44444

        # The primitive should refuse — either by raising a specific exception
        # OR by returning without launching. Both behaviors satisfy the spec
        # (the safety gate's *effect* is what matters).
        raised = False
        try:
            with patch(
                "vibe_modeling.backend.services.operations.install.launch_run",
                _fake_launch_run,
                create=True,
            ):
                install_op.rollback(_ctx(), rollback_state, ws, MagicMock())
        except Exception:
            raised = True

        # Either an exception was raised (refusal) OR no launch happened.
        if not raised:
            assert (
                len(launch_calls) == 0
            ), "safety gate must prevent schema teardown when job terminated SUCCESS"


# ---------------------------------------------------------------------------
# 7. Error propagation — permission denied + unknown catalog
# ---------------------------------------------------------------------------


class _FakeSession:
    """Minimal in-memory stand-in for a SQLModel Session's ``.get`` +
    ``.add`` surface, enough to observe whether ``observe()`` actually
    mutates the target row (a bare ``MagicMock`` would happily accept any
    attribute assignment without letting us assert on it afterwards)."""

    def __init__(self, rows: dict):
        self._rows = rows
        self.added: list = []

    def get(self, model, id_):
        return self._rows.get(id_)

    def add(self, obj):
        self.added.append(obj)

    def exec(self, *args, **kwargs):
        # dispatch()'s idempotency lookup - not exercised by observe()
        # tests, but keep the surface callable defensively.
        m = MagicMock()
        m.first.return_value = None
        return m


class TestInstallDeploymentWriteback:
    """Locks the live-walkthrough fix: a successful install run MUST stamp
    the target ModelVersion as deployed with the catalog it actually
    targeted. Before this fix, `observe()` never touched the ModelVersion
    row at all on TERMINATED/SUCCESS, so a real install stayed
    deployment_status="draft" / uc_catalog="" forever (Todoist mirror of
    the vibe-iterate "born deployed" bug - this one is "never earns
    deployed")."""

    def test_terminated_success_stamps_deployed_and_uc_catalog(self, install_op, engine):
        from sqlmodel import Session, select

        from vibe_modeling.backend.db_models import Business, ModelVersion, ModelVersionInstall

        with Session(engine) as session:
            biz = Business(name="writeback", description="t")
            session.add(biz)
            session.flush()
            mv = ModelVersion(
                id="mv-1", business_id=biz.id, version=1, scope="ecm",
                status="completed", deployment_status="draft",
            )
            session.add(mv)
            session.commit()
            ws = _mock_ws_with_state("TERMINATED", "SUCCESS")
            handle = OperationDispatchHandle(
                databricks_run_id=42,
                vibe_session_id=None,
                extra={"deployment_catalog": "test_cat"},
            )

            obs = install_op.observe(handle, _ctx(parent_version_id="mv-1"), ws, session)

            assert obs.terminal_result.succeeded is True
            assert mv.deployment_status == "deployed"
            assert mv.uc_catalog == "test_cat"
            rows = session.exec(select(ModelVersionInstall).where(ModelVersionInstall.version_id == "mv-1")).all()
            assert [(r.catalog, r.uninstalled_at) for r in rows] == [("test_cat", None)]

    def test_terminated_failed_does_not_touch_version(self, install_op):
        from vibe_modeling.backend.db_models import ModelVersion

        mv = ModelVersion(
            id="mv-1",
            business_id="biz-1",
            version=1,
            scope="ecm",
            status="completed",
            deployment_status="draft",
            uc_catalog="",
        )
        session = _FakeSession({"mv-1": mv})
        ws = _mock_ws_with_state("TERMINATED", "FAILED")
        handle = OperationDispatchHandle(
            databricks_run_id=42,
            vibe_session_id=None,
            extra={"deployment_catalog": "test_cat"},
        )

        obs = install_op.observe(handle, _ctx(parent_version_id="mv-1"), ws, session)

        assert obs.terminal_result.succeeded is False
        assert mv.deployment_status == "draft"
        assert mv.uc_catalog == ""

    def test_missing_parent_version_id_is_a_noop_not_a_crash(self, install_op):
        # Defensive: a hand-built/legacy context without a parent_version_id
        # must not blow up the terminal observation.
        session = _FakeSession({})
        ws = _mock_ws_with_state("TERMINATED", "SUCCESS")
        handle = OperationDispatchHandle(
            databricks_run_id=42,
            vibe_session_id=None,
            extra={"deployment_catalog": "test_cat"},
        )

        obs = install_op.observe(handle, _ctx(parent_version_id=None), ws, session)

        assert obs.terminal_result.succeeded is True
        assert session.added == []


class TestInstallErrorPropagation:
    def test_permission_denied_propagates_clean(self, install_op):
        from unittest.mock import patch

        from databricks.sdk.errors import PermissionDenied

        ws = _mock_ws_with_state("RUNNING")
        session = MagicMock()

        def _fake_launch_run(*args, **kwargs):
            raise PermissionDenied("user lacks USE CATALOG on test_cat")

        with patch(
            "vibe_modeling.backend.services.operations.install.launch_run",
            _fake_launch_run,
            create=True,
        ):
            with pytest.raises(PermissionDenied):
                install_op.dispatch(_ctx(), ws, session)

    def test_unknown_catalog_terminal_failed(self, install_op):
        """Unknown catalog should surface as either:
          (a) a params validation error caught upstream by the validator, OR
          (b) a job that terminates with FAILED + an error message.

        This test exercises path (b) — the user submitted a syntactically
        valid catalog name but it doesn't exist in UC.
        """
        ws = _mock_ws_with_state("TERMINATED", "FAILED")
        # Inject a state_message the impl can surface via OperationResult.error.
        ws.jobs.get_run.return_value.state.state_message = (
            "Catalog 'ghost_cat' does not exist"
        )

        handle = OperationDispatchHandle(databricks_run_id=42, vibe_session_id=None)
        obs = install_op.observe(handle, _ctx(), ws, MagicMock())
        assert obs.is_terminal is True
        assert obs.terminal_result.succeeded is False
        assert obs.terminal_result.error  # non-empty


# ---------------------------------------------------------------------------
# context_file routing — imported and reference-seeded ModelVersions
# ---------------------------------------------------------------------------


class TestInstallContextFileOverride:
    """When ``ModelVersion.import_source_path`` is set on the version being
    installed (true for both user-imported and reference-seeded versions),
    the install widget builder MUST consult it instead of constructing the
    default ``business/<biz>/<scope>_v<N>/model.json`` path.

    The bug this test locks: the 2026-05-18 walkthrough surfaced installs
    crashing on both imported (energy_utilities) and reference-seeded
    (Ecommerce Reference Model) ModelVersions with
    ``ValueError: Model JSON File not found`` because the install op
    constructed the wrong path and ignored the version's actual file
    location stored on ``import_source_path``.
    """

    def _capture_launch(self, install_op, ctx) -> dict:
        ws = _mock_ws_with_state("RUNNING")
        session = MagicMock()
        captured: dict = {}

        def _fake_launch_run(ws_, job_id, widget_params, *args, **kwargs):
            captured.update(widget_params)
            return 12345

        from unittest.mock import patch
        with patch(
            "vibe_modeling.backend.services.operations.install.launch_run",
            _fake_launch_run, create=True,
        ):
            install_op.dispatch(ctx, ws, session)
        return captured

    def test_default_context_file_is_constructed_when_no_candidates(self, install_op):
        """Agent-produced versions have ``import_source_path=NULL`` because
        the agent wrote ``model.json`` at the convention path. Backwards-
        compatible: when no override is passed, the widget builder
        constructs the legacy default."""
        widgets = self._capture_launch(install_op, _ctx())
        assert widgets["context_file"] == (
            "/Volumes/test_cat/_metamodel/vol_root/business/"
            "test_corp/v1/ecm/model.json"
        )

    def test_candidate_wins_over_constructed_default(self, install_op):
        """User-imported / reference-seeded path: the version's
        ``import_source_path`` flows in via ``context_file_candidates``
        and the install sends it verbatim."""
        ctx = _ctx(
            params={
                "business_name": "energy_utilities_import",
                "deployment_catalog": "vibe_modeling_test",
                "scope": "mvm",
                "cataloging_style": "One Catalog",
                "schema_prefix": "mvm_",
                "model_version": 1,
                "context_file_candidates": [
                    "/Volumes/vibe_modeling_test/_metamodel/vol_root/"
                    "walkthrough_2026_05_18/import_test/model.json"
                ],
            }
        )
        widgets = self._capture_launch(install_op, ctx)
        assert widgets["context_file"] == (
            "/Volumes/vibe_modeling_test/_metamodel/vol_root/"
            "walkthrough_2026_05_18/import_test/model.json"
        )

    def test_override_for_reference_seed_path(self, install_op):
        """Reference seeds live at ``imports/<industry>/<scope>_v<N>/``
        in the metamodel catalog. Same override mechanism."""
        ctx = _ctx(
            params={
                "business_name": "banking_reference_model",
                "deployment_catalog": "vibe_modeling_test",
                "scope": "ecm",
                "cataloging_style": "One Catalog",
                "schema_prefix": "ecm_",
                "model_version": 1,
                "context_file_candidates": [
                    "/Volumes/vibe_modeling_test/_metamodel/vol_root/"
                    "imports/banking/ecm_v1/model.json"
                ],
            }
        )
        widgets = self._capture_launch(install_op, ctx)
        assert "imports/banking/ecm_v1/model.json" in widgets["context_file"]

    def test_empty_candidates_fall_back_to_default(self, install_op):
        """No candidates (a hand-built context): the canonical folders
        under the deployment catalog, never ``""``."""
        ctx = _ctx(
            params={
                "business_name": "test_corp",
                "deployment_catalog": "test_cat",
                "scope": "ecm",
                "cataloging_style": "One Catalog",
                "schema_prefix": "ecm_",
                "model_version": 1,
                "context_file_candidates": [],
            }
        )
        widgets = self._capture_launch(install_op, ctx)
        assert widgets["context_file"] == (
            "/Volumes/test_cat/_metamodel/vol_root/business/"
            "test_corp/v1/ecm/model.json"
        )

    # an internal tracker item — explicit walkthrough-2026-05-18 regression
    def test_imported_model_install_does_not_use_business_convention_path(
        self, install_op
    ):
        """Pin the 2026-05-18 reproduction: energy_utilities imported MVM
        (9f26cba1) and Ecommerce Reference Model MVM (21391403) both
        crashed on install because the widget builder synthesised the
        ``business/<biz>/<scope>_v<N>/model.json`` path and ignored the
        ``import_source_path`` where the file actually lived. The widget
        builder MUST honour the override and the synthesised legacy path
        MUST NOT appear in the widget map for an imported version."""
        override = (
            "/Volumes/vibe_modeling_test/_metamodel/vol_root/"
            "imports/energy_utilities/mvm_v1/model.json"
        )
        ctx = _ctx(
            params={
                "business_name": "energy_utilities_import",
                "deployment_catalog": "vibe_modeling_test",
                "scope": "mvm",
                "cataloging_style": "One Catalog",
                "schema_prefix": "mvm_",
                "model_version": 1,
                "context_file_candidates": [override],
            }
        )
        widgets = self._capture_launch(install_op, ctx)
        assert widgets["context_file"] == override
        # Negative guard: the synthesised default path must not slip in.
        synthesised = (
            "/Volumes/vibe_modeling_test/_metamodel/vol_root/business/"
            "energy_utilities_import/v1/mvm/model.json"
        )
        assert widgets["context_file"] != synthesised, (
            f"regression: imported-model install fell through to the "
            f"business-convention path instead of using the override: "
            f"got {widgets['context_file']!r}"
        )


# ---------------------------------------------------------------------------
# 9. Scoped (``_vibe_scope``) model.json — install sends the file's conventions
# ---------------------------------------------------------------------------

_V3_MC = {
    "data_asset_naming_convention": "snake_case",
    "primary_key_suffix": "_id",
    "schema_prefix": "mvm_v2_",
    "schema_suffix": "",
    "tag_prefix": "dbx_",
    "tag_suffix": "",
    "table_id_type": "BIGINT",
}


def _mvm_params(**overrides) -> dict:
    base = {
        "business_name": "ridgeline_energy",
        "deployment_catalog": "ridgeline_energy_vibe_model",
        "scope": "mvm",
        "cataloging_style": "One Catalog",
        "schema_prefix": "mvm_",
        "model_version": 3,
    }
    base.update(overrides)
    return base


def _ws_with_file(root: Any) -> MagicMock:
    import json as _json

    ws = _mock_ws_with_state("RUNNING")
    resp = MagicMock()
    resp.contents.read.return_value = _json.dumps(root).encode()
    ws.files.download.return_value = resp
    return ws


class TestInstallDispatchScopedConventions:
    """``Install.dispatch`` reads the dispatched ``context_file`` on every
    install; only a root ``_vibe_scope`` block changes the widgets."""

    def _dispatch(self, ctx, ws) -> tuple[dict, OperationDispatchHandle]:
        from unittest.mock import patch

        captured: dict = {}

        def _fake_launch_run(ws_, job_id, widget_params, *args, **kwargs):
            captured.update(widget_params)
            return 12345

        with patch(
            "vibe_modeling.backend.services.operations.install.launch_run",
            _fake_launch_run,
        ):
            handle = Install().dispatch(ctx, ws, MagicMock())
        return captured, handle

    def _todays(self, ctx) -> tuple[dict, OperationDispatchHandle]:
        """Today's widgets: a ws whose file carries no conventions."""
        return self._dispatch(ctx, _ws_with_file({"model": {}}))

    @staticmethod
    def _no_sid(widgets: dict) -> dict:
        return {k: v for k, v in widgets.items() if k != "vibe_session_id"}

    def test_ordinary_file_is_read_but_widgets_unchanged(self):
        ctx = _ctx(params=_mvm_params())
        ws = _ws_with_file({"model": {"model_conventions": dict(_V3_MC)}})
        widgets, handle = self._dispatch(ctx, ws)
        base_widgets, base_handle = self._todays(ctx)

        ws.files.download.assert_called_once_with(widgets["context_file"])
        assert self._no_sid(widgets) == self._no_sid(base_widgets)
        assert set(widgets) == set(base_widgets)
        assert widgets["schema_prefix"] == "mvm_"
        assert handle.extra == base_handle.extra
        assert "conventions_source" not in handle.extra

    def test_no_lineage_scoped_file_uses_file_values(self):
        ctx = _ctx(parent_version_id=None, params=_mvm_params())
        ws = _ws_with_file(
            {"_vibe_scope": {"mode": "domains"}, "model": {"model_conventions": _V3_MC}}
        )
        widgets, handle = self._dispatch(ctx, ws)

        assert widgets["schema_prefix"] == "mvm_v2_"
        assert widgets["naming_convention"] == "snake_case"
        assert widgets["primary_key_suffix"] == "_id"
        assert widgets["table_id_type"] == "BIGINT"
        assert widgets["schema_suffix"] == ""
        assert widgets["tag_prefix"] == "dbx_"
        assert "tag_suffix" not in widgets
        assert handle.extra["schema_prefix"] == "mvm_v2_"
        assert handle.extra["conventions_source"] == "file"
        # dispatched_widgets (persisted as dispatched_widgets_json) carries
        # the effective values.
        assert handle.dispatched_widgets["schema_prefix"] == "mvm_v2_"
        assert handle.dispatched_widgets["tag_prefix"] == "dbx_"

    def test_scoped_file_read_from_the_context_file_candidate(self):
        override = "/Volumes/c/_metamodel/vol_root/imports/x/mvm_v3/model.json"
        ctx = _ctx(params=_mvm_params(context_file_candidates=[override]))
        ws = _ws_with_file(
            {"_vibe_scope": {"mode": "domains"}, "model_conventions": _V3_MC}
        )
        widgets, _ = self._dispatch(ctx, ws)
        ws.files.download.assert_called_once_with(override)
        assert widgets["schema_prefix"] == "mvm_v2_"

    def test_an_unreadable_file_fails_the_step_naming_the_catalog(self, caplog):
        from databricks.sdk.errors import NotFound

        ctx = _ctx(params=_mvm_params())
        ws = _mock_ws_with_state("RUNNING")
        ws.files.download.side_effect = NotFound("missing")
        with caplog.at_level(logging.ERROR):
            with pytest.raises(RuntimeError) as ei:
                self._dispatch(ctx, ws)
        assert str(ei.value) == (
            "install: couldn't read the model.json of MVM version 3 from its folders "
            "in catalog ridgeline_energy_vibe_model"
        )
        assert "/Volumes/ridgeline_energy_vibe_model/_metamodel/vol_root/business/ridgeline_energy/v3/mvm/model.json" in caplog.text
        assert "/Volumes/ridgeline_energy_vibe_model/_metamodel/vol_root/business/ridgeline_energy/mvm_v3/model.json" in caplog.text

    def test_a_timed_out_read_fails_the_step(self, monkeypatch):
        import threading

        from vibe_modeling.backend.services.operations import install as install_mod

        monkeypatch.setattr(install_mod, "REQUIRED_READ_TIMEOUT_S", 0.1)
        release = threading.Event()

        def _hang(path):
            release.wait(5)
            raise RuntimeError("released")

        ctx = _ctx(params=_mvm_params())
        ws = _mock_ws_with_state("RUNNING")
        ws.files.download.side_effect = _hang
        try:
            with pytest.raises(RuntimeError, match="couldn't read the model.json"):
                self._dispatch(ctx, ws)
        finally:
            release.set()

    def test_the_first_candidate_that_parses_is_sent(self):
        import json as _json

        first, second, third = (f"/Volumes/c/{n}/model.json" for n in ("a", "b", "c"))
        files = {second: b"not json", third: _json.dumps({"model": {}}).encode()}

        def _download(path):
            if path not in files:
                raise FileNotFoundError(path)
            resp = MagicMock()
            resp.contents.read.return_value = files[path]
            return resp

        ctx = _ctx(params=_mvm_params(context_file_candidates=[first, second, third]))
        ws = _mock_ws_with_state("RUNNING")
        ws.files.download.side_effect = _download
        widgets, _ = self._dispatch(ctx, ws)
        assert widgets["context_file"] == third
        assert [c.args[0] for c in ws.files.download.call_args_list] == [first, second, third]

    def test_a_readable_first_candidate_stops_the_search(self):
        first, second = "/Volumes/c/a/model.json", "/Volumes/c/b/model.json"
        ctx = _ctx(params=_mvm_params(context_file_candidates=[first, second]))
        ws = _ws_with_file({"model": {}})
        widgets, _ = self._dispatch(ctx, ws)
        assert widgets["context_file"] == first
        ws.files.download.assert_called_once_with(first)

    def test_explicit_request_key_wins_at_dispatch(self):
        ctx = _ctx(
            params=_mvm_params(
                naming_convention="PascalCase",
                explicit_convention_keys=["naming_convention"],
            )
        )
        ws = _ws_with_file(
            {"_vibe_scope": {"mode": "domains"}, "model": {"model_conventions": _V3_MC}}
        )
        widgets, handle = self._dispatch(ctx, ws)
        assert widgets["naming_convention"] == "PascalCase"
        assert widgets["schema_prefix"] == _V3_MC["schema_prefix"]
        assert widgets["tag_prefix"] == "dbx_"
        assert handle.extra["conventions_source"] == "partial"

    def test_a_typed_prefix_other_than_the_files_fails_the_step(self):
        ctx = _ctx(params=_mvm_params(schema_prefix="custom_", explicit_convention_keys=["schema_prefix"]))
        ws = _ws_with_file({"_vibe_scope": {"mode": "domains"}, "model": {"model_conventions": _V3_MC}})
        with pytest.raises(RuntimeError, match="Leave Schema Prefix empty"):
            self._dispatch(ctx, ws)
        ws.jobs.run_now.assert_not_called()

    def test_ordinary_file_drops_explicit_suffix_and_tag_prefix(self):
        """An explicit ``schema_suffix``/``tag_prefix`` changes only a
        scoped install. For an ordinary file (or a failed read) the widget
        map stays the ordinary 13-key set, so the request cannot rename an
        ordinary install's schemas."""
        explicit = _mvm_params(
            schema_suffix="_wt",
            tag_prefix="acme_",
            explicit_convention_keys=["schema_suffix", "tag_prefix"],
        )
        base_widgets, _ = self._todays(_ctx(params=_mvm_params()))
        for ws in (
            _ws_with_file({"model": {"model_conventions": dict(_V3_MC)}}),
            _mock_ws_with_state("RUNNING"),
        ):
            widgets, handle = self._dispatch(_ctx(params=explicit), ws)
            assert "schema_suffix" not in widgets
            assert "tag_prefix" not in widgets
            assert self._no_sid(widgets) == self._no_sid(base_widgets)
            assert "conventions_source" not in handle.extra

        scoped = _ws_with_file(
            {"_vibe_scope": {"mode": "domains"}, "model": {"model_conventions": _V3_MC}}
        )
        widgets, _ = self._dispatch(_ctx(params=explicit), scoped)
        assert widgets["schema_suffix"] == "_wt"
        assert widgets["tag_prefix"] == "acme_"

    def test_tag_suffix_never_sent(self):
        ctx = _ctx(params=_mvm_params())
        for root in (
            {"model": {"model_conventions": {**_V3_MC, "tag_suffix": "_t"}}},
            {
                "_vibe_scope": {"mode": "domains"},
                "model": {"model_conventions": {**_V3_MC, "tag_suffix": "_t"}},
            },
        ):
            widgets, _ = self._dispatch(ctx, _ws_with_file(root))
            assert "tag_suffix" not in widgets

    def test_ordinary_build_has_no_optional_widgets(self):
        p = InstallParams(**_mvm_params())
        widgets = _build_install_widgets(p, "1")
        assert "schema_suffix" not in widgets
        assert "tag_prefix" not in widgets
