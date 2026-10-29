"""Transactional safety of the run callers' promote-and-sync SAVEPOINT
(an internal tracker item).

On a sync failure the savepoint must revert the supersede flips AND the
partial element writes, so the prior good version stays active and
un-superseded while the freshly-flushed new version survives to carry the
``incomplete_metadata`` signal. Covers both run callers
(``observe_generation_op`` via GenerateEcm, and ``VibeIterate``) plus the
force-resync route's reliance on the Session dependency rollback.
"""

from __future__ import annotations

import json
import os
import sys
from unittest.mock import MagicMock, patch

import pytest
from sqlmodel import Session, select

sys.path.insert(
    0, os.path.join(os.path.dirname(__file__), "..", "..", "src", "app", "src")
)
sys.path.insert(0, os.path.dirname(__file__))

from vibe_modeling.backend.db_models import (
    Attribute,
    Domain,
    ModelVersion,
    Product,
)
from vibe_modeling.backend.model_sync import ModelSyncService

from _phase2_helpers import (
    GENERATE_ECM_VALID_PARAMS,
    make_ctx,
    make_engine,
    make_ws,
    seed_business_and_agent,
    seed_run_with_op,
)

PRIOR_MODEL = {
    "domains": [{
        "name": "sales", "division": "", "description": "",
        "database_name": "", "references": "",
        "products": [{
            "product": "customer", "description": "", "type": "",
            "data_type": "", "primary_key": "id", "subdomain": "", "reference": "",
            "attributes": [
                {"attribute": "id", "type": "BIGINT", "description": "",
                 "foreign_key_to": "", "business_glossary_term": "",
                 "tags": "", "value_regex": "", "references": ""},
            ],
        }],
    }],
}

_ENVELOPE_BYTES = json.dumps({"model": {
    "type": "business", "domains": [], "generated_from_version": "v1_ecm",
}}).encode()


def _seed_prior_version(session, business_id, *, scope, version):
    """Create a completed+deployed prior version with element rows."""
    mv = ModelVersion(
        business_id=business_id, version=version, scope=scope,
        status="completed", deployment_status="deployed", uc_catalog="deploy_cat",
    )
    session.add(mv)
    session.flush()
    ModelSyncService(session).sync_from_model_json(mv.id, PRIOR_MODEL)
    session.commit()
    return mv.id


def _prior_element_count(session, version_id):
    doms = session.exec(select(Domain).where(Domain.version_id == version_id)).all()
    prods = session.exec(select(Product).where(Product.version_id == version_id)).all()
    attrs = session.exec(
        select(Attribute).join(Product).where(Product.version_id == version_id)
    ).all()
    return len(doms), len(prods), len(attrs)


class TestGenerateOpSavepoint:
    """observe_generation_op: sync failure reverts supersede flips + writes."""

    def _run(self, session, ws, biz_id, run_id, op_id):
        from vibe_modeling.backend.services.operations import OperationDispatchHandle
        from vibe_modeling.backend.services.operations._generation_common import (
            AGENT_OP_NEW_BASE_MODEL,
            observe_generation_op,
        )
        ctx = make_ctx(
            run_id=run_id, operation_id=op_id, business_id=biz_id,
            params=GENERATE_ECM_VALID_PARAMS,
        )
        handle = OperationDispatchHandle(
            databricks_run_id=777, vibe_session_id="sess-1",
        )
        return observe_generation_op(
            handle=handle, ctx=ctx, ws=ws, session=session, scope_short="ecm",
            agent_operation=AGENT_OP_NEW_BASE_MODEL,
        )

    def test_sync_failure_leaves_prior_active_and_unsuperseded(self):
        eng = make_engine()
        ws = make_ws(lifecycle="TERMINATED", result_state="SUCCESS",
                     download_payload=_ENVELOPE_BYTES)
        with Session(eng) as session:
            biz_id, _ = seed_business_and_agent(session)
            prior_id = _seed_prior_version(session, biz_id, scope="ecm", version=1)
            run_id, op_id = seed_run_with_op(
                session, business_id=biz_id, operation_name="generate_ecm",
                databricks_run_id=777,
            )
            before = _prior_element_count(session, prior_id)

            with patch.object(ModelSyncService, "sync_model",
                              side_effect=RuntimeError("post-sync sanity gate failed")):
                obs = self._run(session, ws, biz_id, run_id, op_id)

            # Op still terminal-succeeds (the agent's artifacts landed).
            assert obs.is_terminal is True
            assert obs.terminal_result is not None
            assert obs.terminal_result.succeeded is True

            new_id = obs.terminal_result.output_version_id
            new_mv = session.get(ModelVersion, new_id)
            assert new_mv is not None
            assert new_mv.sync_state == "incomplete_metadata"
            assert new_mv.sync_error_text

            # Prior version survives UN-SUPERSEDED and still deployed.
            prior = session.get(ModelVersion, prior_id)
            assert prior is not None
            assert prior.status == "completed"
            # The agent deployed the new version there whatever our sync did,
            # so the eviction stands outside the savepoint.
            assert prior.deployment_status == "uninstalled"

            # Prior element rows untouched.
            assert _prior_element_count(session, prior_id) == before

            # No auto-superseded ids recorded (the flip was reverted).
            assert obs.terminal_result.rollback_state.get("auto_superseded_ids") == []

    def test_sync_model_false_marks_sync_empty(self):
        """G1: sync_model returns False (no Volume, no Delta) → the version
        lands sync_state=sync_empty (distinct from incomplete_metadata), the op
        still succeeds, and the prior version stays active + un-superseded."""
        eng = make_engine()
        ws = make_ws(lifecycle="TERMINATED", result_state="SUCCESS",
                     download_payload=_ENVELOPE_BYTES)
        with Session(eng) as session:
            biz_id, _ = seed_business_and_agent(session)
            prior_id = _seed_prior_version(session, biz_id, scope="ecm", version=1)
            run_id, op_id = seed_run_with_op(
                session, business_id=biz_id, operation_name="generate_ecm",
                databricks_run_id=777,
            )
            before = _prior_element_count(session, prior_id)

            with patch.object(ModelSyncService, "sync_model", return_value=False):
                obs = self._run(session, ws, biz_id, run_id, op_id)

            assert obs.is_terminal is True
            assert obs.terminal_result is not None
            assert obs.terminal_result.succeeded is True

            new_mv = session.get(ModelVersion, obs.terminal_result.output_version_id)
            assert new_mv is not None
            assert new_mv.sync_state == "sync_empty"
            assert new_mv.sync_error_text

            prior = session.get(ModelVersion, prior_id)
            assert prior is not None
            assert prior.status == "completed"
            # The agent deployed the new version there whatever our sync did,
            # so the eviction stands outside the savepoint.
            assert prior.deployment_status == "uninstalled"
            assert _prior_element_count(session, prior_id) == before
            assert obs.terminal_result.rollback_state.get("auto_superseded_ids") == []

    def test_generic_exception_marks_incomplete_metadata(self):
        """A non-empty sync failure (generic exception) lands
        incomplete_metadata, NOT sync_empty."""
        eng = make_engine()
        ws = make_ws(lifecycle="TERMINATED", result_state="SUCCESS",
                     download_payload=_ENVELOPE_BYTES)
        with Session(eng) as session:
            biz_id, _ = seed_business_and_agent(session)
            _seed_prior_version(session, biz_id, scope="ecm", version=1)
            run_id, op_id = seed_run_with_op(
                session, business_id=biz_id, operation_name="generate_ecm",
                databricks_run_id=777,
            )
            with patch.object(ModelSyncService, "sync_model",
                              side_effect=ValueError("boom")):
                obs = self._run(session, ws, biz_id, run_id, op_id)

            assert obs.terminal_result is not None
            assert obs.terminal_result.succeeded is True
            new_mv = session.get(ModelVersion, obs.terminal_result.output_version_id)
            assert new_mv is not None
            assert new_mv.sync_state == "incomplete_metadata"

    def test_success_supersedes_prior(self):
        """Happy path: the savepoint releases, so the supersede flip persists."""
        eng = make_engine()
        ws = make_ws(lifecycle="TERMINATED", result_state="SUCCESS",
                     download_payload=_ENVELOPE_BYTES)
        with Session(eng) as session:
            biz_id, _ = seed_business_and_agent(session)
            prior_id = _seed_prior_version(session, biz_id, scope="ecm", version=1)
            run_id, op_id = seed_run_with_op(
                session, business_id=biz_id, operation_name="generate_ecm",
                databricks_run_id=777,
            )
            with patch.object(ModelSyncService, "sync_model", return_value=True):
                obs = self._run(session, ws, biz_id, run_id, op_id)

            assert obs.terminal_result is not None
            assert obs.terminal_result.succeeded is True
            prior = session.get(ModelVersion, prior_id)
            assert prior is not None
            # Flip persisted through savepoint release.
            assert prior.status == "superseded"
            # Happy path keeps sync_state ok with domains > 0.
            new_mv = session.get(ModelVersion, obs.terminal_result.output_version_id)
            assert new_mv is not None
            assert new_mv.sync_state == "ok"


class TestVibeIterateSavepoint:
    """VibeIterate._finalize_success: sync failure reverts the supersede flip."""

    def _finalize(self, session, ws, biz_id, parent):
        from vibe_modeling.backend.services.operations import OperationDispatchHandle
        from vibe_modeling.backend.services.operations.vibe_iterate import VibeIterate
        run_id, op_id = seed_run_with_op(
            session, business_id=biz_id, operation_name="vibe_iterate",
            parent_version_id=parent.id,
        )
        ctx = make_ctx(
            run_id=run_id, operation_id=op_id, business_id=biz_id,
            parent_version_id=parent.id,
            params={
                "vibe_instructions": "shrink the customer domain",
                "deployment_catalog": "deploy_cat",
                "business_name": "test_corp",
                "parent_version_int": 1,
            },
        )
        handle = OperationDispatchHandle(
            databricks_run_id=99, vibe_session_id="zzz",
            extra={
                "deployment_catalog": "deploy_cat",
                "business_name": "test_corp",
                "parent_version_int": 1,
            },
        )
        return VibeIterate()._finalize_success(
            handle, ctx, ws, session,
            model_json={"model": {"type": "business", "domains": [],
                                  "generated_from_version": "v1_mvm"}},
        )

    def test_sync_failure_leaves_parent_active_and_unsuperseded(self):
        eng = make_engine()
        ws = make_ws()
        with Session(eng) as session:
            biz_id, _ = seed_business_and_agent(session)
            prior_id = _seed_prior_version(session, biz_id, scope="mvm", version=1)
            parent = session.get(ModelVersion, prior_id)
            before = _prior_element_count(session, prior_id)

            with patch.object(ModelSyncService, "sync_model",
                              side_effect=RuntimeError("post-sync sanity gate failed")):
                result = self._finalize(session, ws, biz_id, parent)

            assert result.succeeded is True
            new_mv = session.get(ModelVersion, result.output_version_id)
            assert new_mv is not None
            assert new_mv.sync_state == "incomplete_metadata"

            prior = session.get(ModelVersion, prior_id)
            assert prior is not None
            assert prior.status == "completed"
            assert _prior_element_count(session, prior_id) == before
            assert result.rollback_state.get("auto_superseded_ids") == []

    def test_sync_model_false_marks_sync_empty(self):
        """G1 mirror for vibe_iterate: sync_model returns False → the version
        lands sync_state=sync_empty, the op still succeeds (succeeded=True),
        and the parent stays active + un-superseded."""
        eng = make_engine()
        ws = make_ws()
        with Session(eng) as session:
            biz_id, _ = seed_business_and_agent(session)
            prior_id = _seed_prior_version(session, biz_id, scope="mvm", version=1)
            parent = session.get(ModelVersion, prior_id)
            before = _prior_element_count(session, prior_id)

            with patch.object(ModelSyncService, "sync_model", return_value=False):
                result = self._finalize(session, ws, biz_id, parent)

            assert result.succeeded is True
            new_mv = session.get(ModelVersion, result.output_version_id)
            assert new_mv is not None
            assert new_mv.sync_state == "sync_empty"
            assert new_mv.sync_error_text

            prior = session.get(ModelVersion, prior_id)
            assert prior is not None
            assert prior.status == "completed"
            assert _prior_element_count(session, prior_id) == before
            assert result.rollback_state.get("auto_superseded_ids") == []

    def test_generic_exception_marks_incomplete_metadata(self):
        """vibe_iterate: a generic sync failure lands incomplete_metadata, not
        sync_empty, and the op still succeeds."""
        eng = make_engine()
        ws = make_ws()
        with Session(eng) as session:
            biz_id, _ = seed_business_and_agent(session)
            prior_id = _seed_prior_version(session, biz_id, scope="mvm", version=1)
            parent = session.get(ModelVersion, prior_id)
            with patch.object(ModelSyncService, "sync_model",
                              side_effect=ValueError("boom")):
                result = self._finalize(session, ws, biz_id, parent)
            assert result.succeeded is True
            new_mv = session.get(ModelVersion, result.output_version_id)
            assert new_mv is not None
            assert new_mv.sync_state == "incomplete_metadata"

    def test_success_supersedes_parent(self):
        eng = make_engine()
        ws = make_ws()
        with Session(eng) as session:
            biz_id, _ = seed_business_and_agent(session)
            prior_id = _seed_prior_version(session, biz_id, scope="mvm", version=1)
            parent = session.get(ModelVersion, prior_id)
            with patch.object(ModelSyncService, "sync_model", return_value=True):
                result = self._finalize(session, ws, biz_id, parent)
            assert result.succeeded is True
            prior = session.get(ModelVersion, prior_id)
            assert prior is not None
            assert prior.status == "superseded"
            new_mv = session.get(ModelVersion, result.output_version_id)
            assert new_mv is not None
            assert new_mv.sync_state == "ok"


class TestForceResyncRollbackSafety:
    """force_resync clears version data then re-syncs; a gate failure must not
    leave the version stripped - the Session dependency rolls back the
    uncommitted clear_version_data on the propagated exception."""

    def test_gate_failure_rollback_preserves_rows(self):
        from vibe_modeling.backend.routes.versions import force_resync_version
        eng = make_engine()
        with Session(eng) as session:
            biz_id, _ = seed_business_and_agent(session)
            vid = _seed_prior_version(session, biz_id, scope="ecm", version=1)
            before = _prior_element_count(session, vid)
            assert before[0] >= 1

            ws = MagicMock()
            config = MagicMock()
            with patch.object(ModelSyncService, "sync_model",
                              side_effect=RuntimeError("post-sync sanity gate failed")), \
                 patch("vibe_modeling.backend.routes.versions.resolve_warehouse_id",
                       return_value="wh-1"):
                with pytest.raises(RuntimeError):
                    force_resync_version(
                        business_id=biz_id, version_id=vid,
                        session=session, ws=ws, config=config,
                        _role=None,  # type: ignore[arg-type]
                    )
            # The route left the clear uncommitted; the dependency would roll
            # back. Emulate that rollback and assert the rows are intact.
            session.rollback()
            assert _prior_element_count(session, vid) == before


class TestManualSyncRoutesEmptyModel:
    """ADV-2: /sync and /resync return a clean 404 (not a 500) when the model
    output parses to 0 domains (G2) — the same status as the G1 no-data case —
    and the uncommitted teardown is rolled back so no rows are lost."""

    def test_sync_route_zero_domain_returns_404_preserves_rows(self):
        from fastapi import HTTPException
        from vibe_modeling.backend.routes.versions import sync_model_version
        eng = make_engine()
        with Session(eng) as session:
            biz_id, _ = seed_business_and_agent(session)
            vid = _seed_prior_version(session, biz_id, scope="ecm", version=1)
            before = _prior_element_count(session, vid)
            assert before[0] >= 1

            ws = MagicMock()
            config = MagicMock()
            with patch.object(ModelSyncService, "load_model_json_from_volumes",
                              return_value={"domains": []}), \
                 patch.object(ModelSyncService, "load_model_from_delta_tables",
                              return_value=None), \
                 patch("vibe_modeling.backend.routes.versions.resolve_warehouse_id",
                       return_value="wh-1"):
                with pytest.raises(HTTPException) as exc_info:
                    sync_model_version(
                        business_id=biz_id, version_id=vid,
                        session=session, ws=ws, config=config,
                        _role=None,  # type: ignore[arg-type]
                    )
            assert exc_info.value.status_code == 404
            # sync_from_model_json deletes the version's rows before the gate
            # raises; the route rolled back, so the existing rows survive.
            assert _prior_element_count(session, vid) == before

    def test_resync_route_zero_domain_returns_404_preserves_rows(self):
        from fastapi import HTTPException
        from vibe_modeling.backend.routes.versions import force_resync_version
        eng = make_engine()
        with Session(eng) as session:
            biz_id, _ = seed_business_and_agent(session)
            vid = _seed_prior_version(session, biz_id, scope="ecm", version=1)
            before = _prior_element_count(session, vid)
            assert before[0] >= 1

            ws = MagicMock()
            config = MagicMock()
            with patch.object(ModelSyncService, "load_resync_sources",
                              return_value=({"domains": []}, None, None)), \
                 patch("vibe_modeling.backend.routes.versions.resolve_warehouse_id",
                       return_value="wh-1"):
                with pytest.raises(HTTPException) as exc_info:
                    force_resync_version(
                        business_id=biz_id, version_id=vid,
                        session=session, ws=ws, config=config,
                        _role=None,  # type: ignore[arg-type]
                    )
            assert exc_info.value.status_code == 404
            # clear_version_data ran for real before the gate raised; the route
            # rolled back, so the rows survive (no data loss).
            assert _prior_element_count(session, vid) == before
