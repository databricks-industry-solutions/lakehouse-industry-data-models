"""Shared helpers for Phase 2 generation primitive adversarial tests.

Test code that touches multiple primitives reuses these builders.
Implementation-agnostic — every helper here is keyed on the public
contract from ``docs/orchestrator-design.md`` §2 and §10, not on the
dev agent's implementation under ``services/operations/``.
"""

from __future__ import annotations

import os
import sys
from typing import Optional
from unittest.mock import MagicMock

# Ensure the app's `src` directory is on sys.path before any imports of
# vibe_modeling.* run. Mirrors tests/test_app/conftest.py.
sys.path.insert(
    0,
    os.path.join(os.path.dirname(__file__), "..", "..", "src", "app", "src"),
)

from sqlalchemy.pool import StaticPool
from sqlmodel import Session, SQLModel, create_engine

from vibe_modeling.backend.db_models import (
    AgentConfig,
    Business,
    BusinessContext,
    ModelVersion,
    Run,
    RunOperation,
)
from vibe_modeling.backend.services.operations import (
    OperationContext,
)


def make_engine():
    eng = create_engine(
        "sqlite://",
        connect_args={"check_same_thread": False},
        poolclass=StaticPool,
    )
    SQLModel.metadata.create_all(eng)
    return eng


def make_ws(
    *,
    lifecycle: str = "RUNNING",
    result_state: str = "",
    state_message: str = "",
    run_now_run_id: int = 555_001,
    download_payload: Optional[bytes] = None,
    download_raises: Optional[Exception] = None,
) -> MagicMock:
    """Build a ``WorkspaceClient`` mock parameterized for the failure
    mode under test. Defaults match the "still in flight" job state.

    ``download_payload`` is the bytes returned by ``ws.files.download``;
    set ``download_raises`` to simulate model.json missing.
    """
    ws = MagicMock()
    ws.config.host = "https://test-workspace.databricks.com"

    job_state = MagicMock()
    job_state.state.life_cycle_state.value = lifecycle
    job_state.state.result_state.value = result_state
    job_state.state.state_message = state_message
    ws.jobs.get_run.return_value = job_state

    run_now_resp = MagicMock()
    run_now_resp.response.run_id = run_now_run_id
    run_now_resp.run_id = run_now_run_id
    ws.jobs.run_now.return_value = run_now_resp

    if download_raises is not None:
        ws.files.download.side_effect = download_raises
    elif download_payload is not None:
        download_resp = MagicMock()
        download_resp.contents.read.return_value = download_payload
        ws.files.download.return_value = download_resp
    else:
        ws.files.download.side_effect = FileNotFoundError(
            "default helper: configure download_payload or download_raises"
        )

    ws.files.list_directory_contents.return_value = []
    ws.files.upload.return_value = None
    # SQL reads succeed with no rows (no agent session row, no registry rows)
    # unless a test sets its own answer.
    from _sql_fakes import response

    ws.statement_execution.execute_statement.return_value = response([])
    return ws


def seed_business_and_agent(
    session: Session,
    *,
    business_name: str = "test_corp",
    industry: str = "Retail",
    job_id: int = 99,
    catalog: str = "deploy_cat",
) -> tuple[str, str]:
    """Create a Business and AgentConfig; return (business_id, agent_id)."""
    biz = Business(
        name=business_name,
        description="Adversarial test corp",
        industry_alignment=industry,
    )
    session.add(biz)
    session.commit()
    session.refresh(biz)

    ac = AgentConfig(
        notebook_path="/Workspace/test/notebook",
        job_id=job_id,
        job_name="test_vibe_job",
        deployment_catalog=catalog,
        # Warehouse is a run/resync preflight requirement (Track 4); a fully
        # configured agent carries one.
        warehouse_id="test-warehouse-id",
    )
    session.add(ac)
    session.commit()
    session.refresh(ac)

    ctx = BusinessContext(
        business_id=biz.id,
        version_label="v1.0",
        context_json='{"business": "test"}',
        conventions_json='{"pk_suffix": "_id"}',
    )
    session.add(ctx)
    session.commit()
    return biz.id, ac.id


def seed_run_with_op(
    session: Session,
    *,
    business_id: str,
    operation_name: str,
    step_index: int = 0,
    parent_version_id: Optional[str] = None,
    run_status: str = "running",
    op_status: str = "pending",
    databricks_run_id: Optional[int] = None,
    intent: str = "new-base-model",
) -> tuple[str, str]:
    """Persist a Run + RunOperation row; return (run_id, op_id)."""
    run = Run(
        business_id=business_id,
        intent=intent,
        status=run_status,
        parameters_json="{}",
    )
    session.add(run)
    session.commit()
    session.refresh(run)

    ro = RunOperation(
        run_id=run.id,
        step_index=step_index,
        operation_name=operation_name,
        params_json="{}",
        parent_version_id=parent_version_id,
        status=op_status,
        databricks_run_id=databricks_run_id,
    )
    session.add(ro)
    session.commit()
    session.refresh(ro)
    return run.id, ro.id


def make_ctx(
    *,
    run_id: str,
    operation_id: str,
    business_id: str,
    parent_version_id: Optional[str] = None,
    params: Optional[dict] = None,
    inherited_params: Optional[dict] = None,
) -> OperationContext:
    return OperationContext(
        run_id=run_id,
        operation_id=operation_id,
        business_id=business_id,
        parent_version_id=parent_version_id,
        params=dict(params or {}),
        inherited_params=dict(inherited_params or {}),
    )


# Default param dicts that are valid against any reasonable Pydantic
# schema for these primitives (per design doc §2.4 examples).

GENERATE_ECM_VALID_PARAMS: dict = {
    "business_name": "test_corp",
    "deployment_catalog": "deploy_cat",
    "schema_prefix": "ecm_",
    "cataloging_style": "One Catalog",
}

SHRINK_TO_MVM_VALID_PARAMS: dict = {
    "business_name": "test_corp",
    "deployment_catalog": "deploy_cat",
    "schema_prefix": "mvm_",
    "cataloging_style": "One Catalog",
}

ENLARGE_TO_ECM_VALID_PARAMS: dict = {
    "business_name": "test_corp",
    "deployment_catalog": "deploy_cat",
    "schema_prefix": "ecm_",
    "cataloging_style": "One Catalog",
}


def parent_version(
    session: Session, business_id: str, *, scope: str = "ecm", version: int = 1
) -> str:
    """Insert a draft ModelVersion to act as a parent for shrink / enlarge ops.
    Returns the new version's id."""
    mv = ModelVersion(
        business_id=business_id,
        version=version,
        scope=scope,
        status="completed",
        deployment_status="draft",
        uc_catalog="deploy_cat",
    )
    session.add(mv)
    session.commit()
    session.refresh(mv)
    return mv.id
