"""Adversarial tests for the ``shrink_to_mvm`` Operation primitive.

Phase 2 — Group A. Mirrors the structure of
``test_primitives_generate_ecm.py`` and shares helpers from
``_phase2_helpers.py``. See ``docs/orchestrator-design.md`` §10 row 2
for the failure-mode table.
"""

from __future__ import annotations

import json
import os
import sys
from pathlib import Path
from unittest.mock import MagicMock, patch

import pytest
from pydantic import ValidationError
from sqlmodel import Session, select

sys.path.insert(
    0, os.path.join(os.path.dirname(__file__), "..", "..", "src", "app", "src")
)
# Ensure tests/test_app/ is importable so the shared phase-2 helpers
# resolve as flat module names.
sys.path.insert(0, os.path.dirname(__file__))

from vibe_modeling.backend.db_models import (
    Domain,
    ModelVersion,
    Run,
    RunOperation,
    RunProgressEvent,
)
from vibe_modeling.backend.services.operations import (
    OperationDispatchHandle,
)

from _phase2_helpers import (
    SHRINK_TO_MVM_VALID_PARAMS,
    make_ctx,
    make_engine,
    make_ws,
    parent_version,
    seed_business_and_agent,
    seed_run_with_op,
)
from _phase2_stubs import load_primitive


@pytest.fixture
def engine():
    return make_engine()


@pytest.fixture
def primitive():
    op, params_model = load_primitive("shrink_to_mvm")
    return op, params_model


# --------------------------------------------------------------------------
# Pydantic params validation
# --------------------------------------------------------------------------


# --------------------------------------------------------------------------
# dispatch — widget contract
# --------------------------------------------------------------------------


def test_dispatch_launches_with_shrink_ecm_operation(engine, primitive):
    """``shrink_to_mvm`` must send ``operation='shrink ecm'`` and the MVM
    long-form scope to the agent notebook."""
    op, _ = primitive
    ws = make_ws()
    with Session(engine) as session:
        biz_id, _ = seed_business_and_agent(session)
        parent_id = parent_version(session, biz_id, scope="ecm", version=1)
        run_id, op_id = seed_run_with_op(
            session,
            business_id=biz_id,
            operation_name="shrink_to_mvm",
            parent_version_id=parent_id,
        )
        ctx = make_ctx(
            run_id=run_id, operation_id=op_id, business_id=biz_id,
            parent_version_id=parent_id,
            params=SHRINK_TO_MVM_VALID_PARAMS,
        )
        try:
            op.dispatch(ctx, ws, session)
        except NotImplementedError:
            pytest.skip("Stub primitive — dispatch not implemented")

    assert ws.jobs.run_now.called
    notebook_params = ws.jobs.run_now.call_args.kwargs.get("notebook_params") or {}
    assert notebook_params.get("operation") == "shrink ecm"
    assert "Minimum Viable Model - MVM" in notebook_params.get(
        "data_model_scopes", ""
    )


def test_dispatch_returns_handle_with_databricks_run_id(engine, primitive):
    op, _ = primitive
    ws = make_ws(run_now_run_id=778_001)
    with Session(engine) as session:
        biz_id, _ = seed_business_and_agent(session)
        parent_id = parent_version(session, biz_id)
        run_id, op_id = seed_run_with_op(
            session, business_id=biz_id, operation_name="shrink_to_mvm",
            parent_version_id=parent_id,
        )
        ctx = make_ctx(
            run_id=run_id, operation_id=op_id, business_id=biz_id,
            parent_version_id=parent_id,
            params=SHRINK_TO_MVM_VALID_PARAMS,
        )
        try:
            handle = op.dispatch(ctx, ws, session)
        except NotImplementedError:
            pytest.skip("Stub primitive — dispatch not implemented")

    assert isinstance(handle, OperationDispatchHandle)
    assert handle.databricks_run_id == 778_001


def test_dispatch_propagates_permission_denied(engine, primitive):
    op, _ = primitive
    ws = make_ws()
    ws.jobs.run_now.side_effect = PermissionError("not authorized")
    with Session(engine) as session:
        biz_id, _ = seed_business_and_agent(session)
        parent_id = parent_version(session, biz_id)
        run_id, op_id = seed_run_with_op(
            session, business_id=biz_id, operation_name="shrink_to_mvm",
            parent_version_id=parent_id,
        )
        ctx = make_ctx(
            run_id=run_id, operation_id=op_id, business_id=biz_id,
            parent_version_id=parent_id,
            params=SHRINK_TO_MVM_VALID_PARAMS,
        )
        with pytest.raises((PermissionError, RuntimeError, NotImplementedError)):
            op.dispatch(ctx, ws, session)
        try:
            session.commit()
        except Exception:
            session.rollback()

    with Session(engine) as session:
        ro = session.get(RunOperation, op_id)
        assert ro is not None
        assert ro.databricks_run_id is None


def test_dispatch_does_not_modify_parent_ecm_version(engine, primitive):
    """Per §10 row 2: a failed shrink leaves ECM untouched. Even on a
    *successful* dispatch we expect the parent ECM ``ModelVersion`` to be
    unaffected — shrink produces a new MVM row, never mutates the ECM."""
    op, _ = primitive
    ws = make_ws()
    with Session(engine) as session:
        biz_id, _ = seed_business_and_agent(session)
        parent_id = parent_version(session, biz_id, scope="ecm", version=1)
        run_id, op_id = seed_run_with_op(
            session, business_id=biz_id, operation_name="shrink_to_mvm",
            parent_version_id=parent_id,
        )
        ctx = make_ctx(
            run_id=run_id, operation_id=op_id, business_id=biz_id,
            parent_version_id=parent_id,
            params=SHRINK_TO_MVM_VALID_PARAMS,
        )
        try:
            op.dispatch(ctx, ws, session)
        except NotImplementedError:
            pytest.skip("Stub primitive — dispatch not implemented")
        session.commit()

    with Session(engine) as session:
        parent = session.get(ModelVersion, parent_id)
        assert parent is not None
        assert parent.scope == "ecm"
        assert parent.deployment_status == "draft"


# --------------------------------------------------------------------------
# observe — terminal failure / success modes
# --------------------------------------------------------------------------


def test_observe_reports_terminal_failed_when_job_failed(engine, primitive):
    op, _ = primitive
    ws = make_ws(lifecycle="TERMINATED", result_state="FAILED",
                 state_message="OOM in driver")
    with Session(engine) as session:
        biz_id, _ = seed_business_and_agent(session)
        parent_id = parent_version(session, biz_id)
        run_id, op_id = seed_run_with_op(
            session, business_id=biz_id, operation_name="shrink_to_mvm",
            parent_version_id=parent_id, op_status="running",
            databricks_run_id=22222,
        )
        ctx = make_ctx(
            run_id=run_id, operation_id=op_id, business_id=biz_id,
            parent_version_id=parent_id,
            params=SHRINK_TO_MVM_VALID_PARAMS,
        )
        handle = OperationDispatchHandle(databricks_run_id=22222, vibe_session_id=None)
        try:
            obs = op.observe(handle, ctx, ws, session)
        except NotImplementedError:
            pytest.skip("Stub primitive — observe not implemented")

    assert obs.is_terminal is True
    assert obs.terminal_result is not None
    assert obs.terminal_result.succeeded is False
    assert obs.terminal_result.error
    assert obs.terminal_result.output_version_id is None


def test_observe_succeeded_false_when_model_json_missing(
    monkeypatch, engine, primitive
):
    # observe_generation_op retries 5 times with backoff (15s total)
    # for Volume FUSE eventual consistency; mock sleep for fast tests.
    monkeypatch.setattr(
        "vibe_modeling.backend.services.operations._generation_common.time.sleep",
        lambda *_a, **_kw: None,
    )
    op, _ = primitive
    ws = make_ws(
        lifecycle="TERMINATED", result_state="SUCCESS",
        download_raises=FileNotFoundError("model.json"),
    )
    with Session(engine) as session:
        biz_id, _ = seed_business_and_agent(session)
        parent_id = parent_version(session, biz_id)
        run_id, op_id = seed_run_with_op(
            session, business_id=biz_id, operation_name="shrink_to_mvm",
            parent_version_id=parent_id, op_status="running",
            databricks_run_id=22222,
        )
        ctx = make_ctx(
            run_id=run_id, operation_id=op_id, business_id=biz_id,
            parent_version_id=parent_id,
            params=SHRINK_TO_MVM_VALID_PARAMS,
        )
        handle = OperationDispatchHandle(databricks_run_id=22222, vibe_session_id=None)
        try:
            obs = op.observe(handle, ctx, ws, session)
        except NotImplementedError:
            pytest.skip("Stub primitive — observe not implemented")

    assert obs.is_terminal is True
    assert obs.terminal_result is not None
    assert obs.terminal_result.succeeded is False
    err = (obs.terminal_result.error or "").lower()
    assert "model.json" in err or "artifact" in err or "missing" in err


def test_observe_lakebase_sync_failure_keeps_succeeded_true(engine, primitive):
    """Per §10 row 1 column 3 (same pattern applies to MVM): artifact
    exists → succeeded=True; rollback deletes the version."""
    op, _ = primitive
    valid_model_json = b'{"domains": [], "products": [], "attributes": []}'
    ws = make_ws(
        lifecycle="TERMINATED", result_state="SUCCESS",
        download_payload=valid_model_json,
    )
    with Session(engine) as session:
        biz_id, _ = seed_business_and_agent(session)
        parent_id = parent_version(session, biz_id)
        run_id, op_id = seed_run_with_op(
            session, business_id=biz_id, operation_name="shrink_to_mvm",
            parent_version_id=parent_id, op_status="running",
            databricks_run_id=22222,
        )
        ctx = make_ctx(
            run_id=run_id, operation_id=op_id, business_id=biz_id,
            parent_version_id=parent_id,
            params=SHRINK_TO_MVM_VALID_PARAMS,
        )
        handle = OperationDispatchHandle(databricks_run_id=22222, vibe_session_id=None)
        with patch(
            "vibe_modeling.backend.model_sync.ModelSyncService.sync_model",
            side_effect=RuntimeError("lakebase down"),
        ):
            try:
                obs = op.observe(handle, ctx, ws, session)
            except NotImplementedError:
                pytest.skip("Stub primitive — observe not implemented")
        session.commit()

    assert obs.is_terminal is True
    assert obs.terminal_result is not None
    assert obs.terminal_result.succeeded is True
    # MVM version exists (so rollback can delete it).
    with Session(engine) as session:
        mvm_versions = session.exec(
            select(ModelVersion).where(
                ModelVersion.business_id == biz_id,
                ModelVersion.scope == "mvm",
            )
        ).all()
        assert len(mvm_versions) == 1


def test_observe_in_flight_returns_non_terminal(engine, primitive):
    op, _ = primitive
    ws = make_ws(lifecycle="RUNNING", result_state="")
    with Session(engine) as session:
        biz_id, _ = seed_business_and_agent(session)
        parent_id = parent_version(session, biz_id)
        run_id, op_id = seed_run_with_op(
            session, business_id=biz_id, operation_name="shrink_to_mvm",
            parent_version_id=parent_id, op_status="running",
            databricks_run_id=22222,
        )
        ctx = make_ctx(
            run_id=run_id, operation_id=op_id, business_id=biz_id,
            parent_version_id=parent_id,
            params=SHRINK_TO_MVM_VALID_PARAMS,
        )
        handle = OperationDispatchHandle(databricks_run_id=22222, vibe_session_id=None)
        try:
            obs = op.observe(handle, ctx, ws, session)
        except NotImplementedError:
            pytest.skip("Stub primitive — observe not implemented")

    assert obs.is_terminal is False
    assert obs.terminal_result is None


def test_observe_concurrent_calls_are_consistent(engine, primitive):
    op, _ = primitive
    ws = make_ws(lifecycle="RUNNING", result_state="")
    with Session(engine) as session:
        biz_id, _ = seed_business_and_agent(session)
        parent_id = parent_version(session, biz_id)
        run_id, op_id = seed_run_with_op(
            session, business_id=biz_id, operation_name="shrink_to_mvm",
            parent_version_id=parent_id, op_status="running",
            databricks_run_id=22222,
        )
        ctx = make_ctx(
            run_id=run_id, operation_id=op_id, business_id=biz_id,
            parent_version_id=parent_id,
            params=SHRINK_TO_MVM_VALID_PARAMS,
        )
        handle = OperationDispatchHandle(databricks_run_id=22222, vibe_session_id=None)
        try:
            obs1 = op.observe(handle, ctx, ws, session)
            obs2 = op.observe(handle, ctx, ws, session)
        except NotImplementedError:
            pytest.skip("Stub primitive — observe not implemented")

    assert obs1.is_terminal == obs2.is_terminal


# --------------------------------------------------------------------------
# rollback
# --------------------------------------------------------------------------


def test_rollback_deletes_mvm_version(engine, primitive):
    """Rollback deletes the produced MVM ``ModelVersion`` row but MUST
    NOT touch the parent ECM."""
    op, _ = primitive
    ws = make_ws()
    with Session(engine) as session:
        biz_id, _ = seed_business_and_agent(session)
        parent_id = parent_version(session, biz_id, scope="ecm", version=1)
        run_id, op_id = seed_run_with_op(
            session, business_id=biz_id, operation_name="shrink_to_mvm",
            parent_version_id=parent_id,
        )
        mvm = ModelVersion(
            business_id=biz_id, version=2, scope="mvm",
            status="completed", deployment_status="draft",
            uc_catalog="deploy_cat",
            base_version_id=parent_id,
        )
        session.add(mvm)
        session.commit()
        session.refresh(mvm)
        mvm_id = mvm.id

        ctx = make_ctx(
            run_id=run_id, operation_id=op_id, business_id=biz_id,
            parent_version_id=parent_id,
            params=SHRINK_TO_MVM_VALID_PARAMS,
        )
        rollback_state = {
            "version_id": mvm_id,
            "scope": "mvm",
            "catalog": "deploy_cat",
            "business_name": "test_corp",
            "schema_prefix": "mvm_",
            "model_version": "1",
            "installed_inline": False,
        }
        try:
            op.rollback(ctx, rollback_state, ws, session)
        except NotImplementedError:
            pytest.skip("Stub primitive — rollback not implemented")
        session.commit()

    with Session(engine) as session:
        assert session.get(ModelVersion, mvm_id) is None
        # ECM parent must remain.
        assert session.get(ModelVersion, parent_id) is not None


def test_rollback_uninstalls_mvm_schema_when_installed_inline(engine, primitive):
    """One-Catalog shrinks install MVM schema inline. Rollback must
    launch the uninstall job."""
    op, _ = primitive
    ws = make_ws()
    with Session(engine) as session:
        biz_id, _ = seed_business_and_agent(session)
        parent_id = parent_version(session, biz_id)
        run_id, op_id = seed_run_with_op(
            session, business_id=biz_id, operation_name="shrink_to_mvm",
            parent_version_id=parent_id,
        )
        mvm = ModelVersion(
            business_id=biz_id, version=2, scope="mvm",
            status="completed", deployment_status="deployed",
            uc_catalog="deploy_cat",
            base_version_id=parent_id,
        )
        session.add(mvm)
        session.commit()
        session.refresh(mvm)
        mvm_id = mvm.id

        ctx = make_ctx(
            run_id=run_id, operation_id=op_id, business_id=biz_id,
            parent_version_id=parent_id,
            params=SHRINK_TO_MVM_VALID_PARAMS,
            inherited_params={"cataloging_style": "One Catalog"},
        )
        rollback_state = {
            "version_id": mvm_id,
            "scope": "mvm",
            "catalog": "deploy_cat",
            "business_name": "test_corp",
            "schema_prefix": "mvm_",
            "model_version": "1",
            "installed_inline": True,
        }
        try:
            op.rollback(ctx, rollback_state, ws, session)
        except NotImplementedError:
            pytest.skip("Stub primitive — rollback not implemented")
        session.commit()

    assert ws.jobs.run_now.called, (
        "rollback for an inline-installed MVM must launch the uninstall job"
    )
    notebook_params = ws.jobs.run_now.call_args.kwargs.get("notebook_params") or {}
    op_widget = notebook_params.get("operation", "")
    assert "uninstall" in op_widget.lower()


def test_rollback_clears_lakebase_data_for_mvm_version(engine, primitive):
    op, _ = primitive
    ws = make_ws()
    with Session(engine) as session:
        biz_id, _ = seed_business_and_agent(session)
        parent_id = parent_version(session, biz_id)
        run_id, op_id = seed_run_with_op(
            session, business_id=biz_id, operation_name="shrink_to_mvm",
            parent_version_id=parent_id,
        )
        mvm = ModelVersion(
            business_id=biz_id, version=2, scope="mvm",
            status="completed", deployment_status="draft",
            uc_catalog="deploy_cat",
            base_version_id=parent_id,
        )
        session.add(mvm)
        session.commit()
        session.refresh(mvm)
        d = Domain(version_id=mvm.id, name="sales")
        session.add(d)
        session.commit()
        mvm_id = mvm.id

        ctx = make_ctx(
            run_id=run_id, operation_id=op_id, business_id=biz_id,
            parent_version_id=parent_id,
            params=SHRINK_TO_MVM_VALID_PARAMS,
        )
        rollback_state = {
            "version_id": mvm_id,
            "scope": "mvm",
            "catalog": "deploy_cat",
            "business_name": "test_corp",
            "schema_prefix": "mvm_",
            "model_version": "1",
            "installed_inline": False,
        }
        try:
            op.rollback(ctx, rollback_state, ws, session)
        except NotImplementedError:
            pytest.skip("Stub primitive — rollback not implemented")
        session.commit()

    with Session(engine) as session:
        assert session.exec(
            select(Domain).where(Domain.version_id == mvm_id)
        ).all() == []


def test_rollback_of_never_dispatched_op_is_noop(engine, primitive):
    op, _ = primitive
    ws = make_ws()
    with Session(engine) as session:
        biz_id, _ = seed_business_and_agent(session)
        parent_id = parent_version(session, biz_id)
        run_id, op_id = seed_run_with_op(
            session, business_id=biz_id, operation_name="shrink_to_mvm",
            parent_version_id=parent_id,
        )
        ctx = make_ctx(
            run_id=run_id, operation_id=op_id, business_id=biz_id,
            parent_version_id=parent_id,
            params=SHRINK_TO_MVM_VALID_PARAMS,
        )
        try:
            op.rollback(ctx, {}, ws, session)
        except NotImplementedError:
            pytest.skip("Stub primitive — rollback not implemented")


def test_rollback_is_idempotent(engine, primitive):
    op, _ = primitive
    ws = make_ws()
    with Session(engine) as session:
        biz_id, _ = seed_business_and_agent(session)
        parent_id = parent_version(session, biz_id)
        run_id, op_id = seed_run_with_op(
            session, business_id=biz_id, operation_name="shrink_to_mvm",
            parent_version_id=parent_id,
        )
        mvm = ModelVersion(
            business_id=biz_id, version=2, scope="mvm",
            status="completed", deployment_status="draft",
            uc_catalog="deploy_cat",
            base_version_id=parent_id,
        )
        session.add(mvm)
        session.commit()
        session.refresh(mvm)
        mvm_id = mvm.id
        ctx = make_ctx(
            run_id=run_id, operation_id=op_id, business_id=biz_id,
            parent_version_id=parent_id,
            params=SHRINK_TO_MVM_VALID_PARAMS,
        )
        rollback_state = {
            "version_id": mvm_id,
            "scope": "mvm",
            "catalog": "deploy_cat",
            "business_name": "test_corp",
            "schema_prefix": "mvm_",
            "model_version": "1",
            "installed_inline": False,
        }
        try:
            op.rollback(ctx, rollback_state, ws, session)
            session.commit()
            op.rollback(ctx, rollback_state, ws, session)
            session.commit()
        except NotImplementedError:
            pytest.skip("Stub primitive — rollback not implemented")


# --------------------------------------------------------------------------
# Class-level invariants
# --------------------------------------------------------------------------


def test_class_attributes_match_contract(primitive):
    op, _ = primitive
    assert op.name == "shrink_to_mvm"
    assert op.produces_version is True


# --------------------------------------------------------------------------
# dispatch: the parent ECM's conventions (agent 5.3.3 shapes, T2 J7 A2)
# --------------------------------------------------------------------------

_A2 = json.loads(
    (Path(__file__).resolve().parents[1] / "fixtures" / "vibe_conventions_a2.json").read_text()
)
_PARENT_ECM_PATH = "/Volumes/deploy_cat/_metamodel/vol_root/business/test_corp/v1/ecm/model.json"


def _ws_serving(path: str, root: dict):
    ws = make_ws()

    def _download(p):
        if p != path:
            raise FileNotFoundError(p)
        resp = MagicMock()
        resp.contents.read.return_value = json.dumps(root).encode()
        return resp

    ws.files.download.side_effect = _download
    return ws


def _dispatch_shrink(engine, op, ws, params=None):
    session = Session(engine)
    biz_id, _ = seed_business_and_agent(session)
    parent_id = parent_version(session, biz_id, scope="ecm", version=1)
    run_id, op_id = seed_run_with_op(
        session, business_id=biz_id, operation_name="shrink_to_mvm",
        parent_version_id=parent_id,
    )
    ctx = make_ctx(
        run_id=run_id, operation_id=op_id, business_id=biz_id,
        parent_version_id=parent_id,
        params=params or SHRINK_TO_MVM_VALID_PARAMS,
    )
    handle = op.dispatch(ctx, ws, session)
    return session, ctx, handle


def test_dispatch_takes_the_parent_ecm_file_conventions(engine, primitive):
    """A2: the vibed ECM kept SCREAMING_CASE, Int (0/1), dd/MM/yyyy and the
    tag suffix _wt; the run asked for the defaults. The MVM follows the ECM;
    its schema prefix stays mvm_."""
    op, params_model = primitive
    ws = _ws_serving(_PARENT_ECM_PATH, _A2["ecm"])
    params = params_model(**SHRINK_TO_MVM_VALID_PARAMS, housekeeping_columns="Yes").model_dump()
    session, _, handle = _dispatch_shrink(engine, op, ws, params)
    session.close()

    widgets = ws.jobs.run_now.call_args.kwargs["notebook_params"]
    assert widgets["naming_convention"] == "SCREAMING_CASE"
    assert widgets["boolean_format"] == "Int (0/1)"
    assert widgets["date_format"] == "dd/MM/yyyy"
    assert widgets["tag_suffix"] == "_wt"
    assert widgets["schema_prefix"] == "mvm_"
    assert widgets["housekeeping_columns"] == "Yes"
    assert handle.dispatched_widgets["naming_convention"] == "SCREAMING_CASE"
    assert handle.extra == {}


def test_dispatch_keeps_params_and_warns_when_the_parent_file_is_unreadable(engine, primitive):
    op, params_model = primitive
    ws = make_ws(download_raises=PermissionError("denied"))
    params = params_model(**SHRINK_TO_MVM_VALID_PARAMS, naming_convention="camelCase").model_dump()
    session, ctx, handle = _dispatch_shrink(engine, op, ws, params)

    widgets = ws.jobs.run_now.call_args.kwargs["notebook_params"]
    assert widgets["naming_convention"] == "camelCase"
    assert handle.extra["parent_conventions_warning"]

    # Not a progress event: the warning rides the step's rollback state to
    # the run page's warnings card, once the shrink succeeds.
    op.observe(handle, ctx, ws, session)
    session.commit()
    assert session.exec(select(RunProgressEvent).where(RunProgressEvent.run_id == ctx.run_id)).all() == []
    session.close()


def test_the_conventions_warning_reaches_run_out_warnings_on_success(engine, primitive):
    from vibe_modeling.backend.routes._helpers import _build_run_out
    from vibe_modeling.backend.services.operations._protocol import (
        RUN_WARNINGS_KEY,
        OperationObservation,
        OperationResult,
    )
    from vibe_modeling.backend.services.operations.shrink_to_mvm import PARENT_CONVENTIONS_UNREAD

    op, params_model = primitive
    ws = make_ws(download_raises=PermissionError("denied"))
    params = params_model(**SHRINK_TO_MVM_VALID_PARAMS).model_dump()
    session, ctx, handle = _dispatch_shrink(engine, op, ws, params)

    done = OperationObservation(
        progress_percent=100, progress_message="completed", is_terminal=True,
        terminal_result=OperationResult(True, None, [], {"databricks_run_id": 1}, None),
    )
    failed = OperationObservation(
        progress_percent=100, progress_message="failed", is_terminal=True,
        terminal_result=OperationResult(False, None, [], {}, "boom"),
    )
    with patch("vibe_modeling.backend.services.operations.shrink_to_mvm.observe_generation_op", return_value=done):
        obs = op.observe(handle, ctx, ws, session)
    assert obs.terminal_result.rollback_state == {"databricks_run_id": 1, RUN_WARNINGS_KEY: [PARENT_CONVENTIONS_UNREAD]}
    with patch("vibe_modeling.backend.services.operations.shrink_to_mvm.observe_generation_op", return_value=failed):
        assert RUN_WARNINGS_KEY not in op.observe(handle, ctx, ws, session).terminal_result.rollback_state

    run = session.get(Run, ctx.run_id)
    row = session.get(RunOperation, ctx.operation_id)
    row.status = "succeeded"
    row.rollback_state_json = json.dumps(obs.terminal_result.rollback_state)
    session.add(row)
    session.commit()
    out = _build_run_out(run, None, session)
    session.close()
    assert [(w["message"], w["severity"], w["field_path"]) for w in out.warnings] == [
        (PARENT_CONVENTIONS_UNREAD, "warning", "(shrink_to_mvm)")
    ]
