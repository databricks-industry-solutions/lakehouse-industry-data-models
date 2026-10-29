"""Tests for lineage resolution from ``generated_from_version``.

The agent writes ``"v{N}_{scope}"`` into ``model.json`` to identify the
parent version a new run derived from. The post-refactor sync paths
parse this tag and set ``ModelVersion.base_version_id`` to the matching
parent row, so the UI can render the lineage tree without ambiguity.

Covered call sites:
* Generation primitives (``_generation_common._terminal_success``).
* Vibe-iterate primitive (``vibe_iterate._finalize_success``).
* Volume-import primitive (``import_from_volume.dispatch``).
* Volume-import route (``businesses.import_execute``).

The parent comes from ``_query_helpers.resolve_model_json_parent``: the
5.3.3 ``lineage`` block (``base_version``, ``base_scope``) first, else the tag.
"""

from __future__ import annotations

import json
import os
import sys
from unittest.mock import MagicMock

import pytest
from sqlmodel import Session, select

sys.path.insert(
    0, os.path.join(os.path.dirname(__file__), "..", "..", "src", "app", "src")
)
sys.path.insert(0, os.path.dirname(__file__))

from vibe_modeling.backend.db_models import (
    Business,
    ModelVersion,
)

from _phase2_helpers import (
    make_ctx,
    make_engine,
    make_ws,
    seed_business_and_agent,
    seed_run_with_op,
)


# ---------------------------------------------------------------------------
# Generation primitive: _terminal_success picks up generated_from_version
# ---------------------------------------------------------------------------


def test_terminal_success_sets_base_from_generated_from_version():
    """The shrink primitive's terminal-success path looks up the parent ECM
    row by parsing the agent's `generated_from_version` tag."""
    from vibe_modeling.backend.services.operations._generation_common import (
        AGENT_OP_NEW_BASE_MODEL,
        _terminal_success,
    )

    eng = make_engine()
    ws = make_ws()
    with Session(eng) as session:
        biz_id, _ = seed_business_and_agent(session)
        # Parent ECM at v=2 — only this row matches "v2_ecm".
        ecm = ModelVersion(
            business_id=biz_id, version=2, scope="ecm",
            status="completed", deployment_status="draft",
            uc_catalog="deploy_cat",
        )
        session.add(ecm)
        session.commit()
        session.refresh(ecm)

        # ctx.parent_version_id deliberately UNSET to prove the lineage
        # comes from the model.json tag, not the context.
        run_id, op_id = seed_run_with_op(
            session, business_id=biz_id, operation_name="shrink_to_mvm",
            parent_version_id=None,
        )
        ctx = make_ctx(
            run_id=run_id, operation_id=op_id, business_id=biz_id,
            parent_version_id=None,
            params={
                "deployment_catalog": "deploy_cat",
                "business_name": "test_corp",
                "model_vibes": "",
                "schema_prefix": "mvm_",
            },
        )

        obs = _terminal_success(
            agent_operation=AGENT_OP_NEW_BASE_MODEL,
            ctx=ctx, ws=ws, session=session, warehouse_id="",
            catalog="deploy_cat", business_name="test_corp",
            agent_business="test_corp", agent_version="",
            agent_model_scope="mvm", scope_short="mvm",
            model_json_payload={
                "model": {
                    "type": "business",
                    "domains": [],
                    "generated_from_version": "v2_ecm",
                }
            },
        )

        assert obs.is_terminal is True
        assert obs.terminal_result.succeeded is True
        new_mv = session.get(ModelVersion, obs.terminal_result.output_version_id)
        assert new_mv is not None
        assert new_mv.scope == "mvm"
        # Critical: lineage was resolved via the tag, not via ctx.parent_version_id.
        assert new_mv.base_version_id == ecm.id
        # And per spec §2: ECM v=2 → MVM v=2 (same version, opposite scope).
        assert new_mv.version == 2


def test_terminal_success_falls_back_to_ctx_parent_when_tag_missing():
    """When the agent didn't emit `generated_from_version`, the legacy
    ctx.parent_version_id path still works."""
    from vibe_modeling.backend.services.operations._generation_common import (
        AGENT_OP_NEW_BASE_MODEL,
        _terminal_success,
    )

    eng = make_engine()
    ws = make_ws()
    with Session(eng) as session:
        biz_id, _ = seed_business_and_agent(session)
        ecm = ModelVersion(
            business_id=biz_id, version=1, scope="ecm",
            status="completed", deployment_status="draft",
            uc_catalog="deploy_cat",
        )
        session.add(ecm)
        session.commit()
        session.refresh(ecm)

        run_id, op_id = seed_run_with_op(
            session, business_id=biz_id, operation_name="shrink_to_mvm",
            parent_version_id=ecm.id,
        )
        ctx = make_ctx(
            run_id=run_id, operation_id=op_id, business_id=biz_id,
            parent_version_id=ecm.id,
            params={
                "deployment_catalog": "deploy_cat",
                "business_name": "test_corp",
                "model_vibes": "",
                "schema_prefix": "mvm_",
            },
        )

        obs = _terminal_success(
            agent_operation=AGENT_OP_NEW_BASE_MODEL,
            ctx=ctx, ws=ws, session=session, warehouse_id="",
            catalog="deploy_cat", business_name="test_corp",
            agent_business="test_corp", agent_version="",
            agent_model_scope="mvm", scope_short="mvm",
            model_json_payload=None,  # No tag available.
        )

        assert obs.terminal_result.succeeded is True
        new_mv = session.get(ModelVersion, obs.terminal_result.output_version_id)
        assert new_mv.base_version_id == ecm.id


# ---------------------------------------------------------------------------
# Volume-import primitive: dispatch resolves lineage from the imported file
# ---------------------------------------------------------------------------


def test_import_from_volume_resolves_lineage_from_tag():
    """The volume-import primitive parses `generated_from_version` from the
    imported model.json and links the new MV to the matching parent row."""
    from vibe_modeling.backend.services.operations.import_from_volume import (
        ImportFromVolume,
    )

    eng = make_engine()
    ws = make_ws()
    payload = {"model": {
        "type": "business",
        "domains": [],
        "generated_from_version": "v1_ecm",
    }}
    resp = MagicMock()
    resp.contents.read.return_value = json.dumps(payload).encode()
    ws.files.download.side_effect = None
    ws.files.download.return_value = resp

    with Session(eng) as session:
        biz_id, _ = seed_business_and_agent(session)
        # Parent ECM at v=1.
        ecm = ModelVersion(
            business_id=biz_id, version=1, scope="ecm",
            status="completed", deployment_status="draft",
            uc_catalog="deploy_cat",
        )
        session.add(ecm)
        session.commit()
        session.refresh(ecm)

        run_id, op_id = seed_run_with_op(
            session, business_id=biz_id, operation_name="import_from_volume",
            parent_version_id=None,
        )
        ctx = make_ctx(
            run_id=run_id, operation_id=op_id, business_id=biz_id,
            parent_version_id=None,
            params={
                "volume_path": (
                    "/Volumes/deploy_cat/_metamodel/vol_root/business/"
                    "test_corp/v1/mvm/model.json"
                ),
                "business_name": "test_corp",
                "deployment_catalog": "deploy_cat",
            },
        )

        op = ImportFromVolume()
        handle = op.dispatch(ctx, ws, session)
        # The import is synchronous in dispatch; observe just surfaces the
        # already-completed handle.
        obs = op.observe(handle, ctx, ws, session)

        assert obs.is_terminal is True
        assert obs.terminal_result.succeeded is True
        new_mv = session.get(ModelVersion, obs.terminal_result.output_version_id)
        assert new_mv is not None
        # Lineage was resolved from the tag.
        assert new_mv.base_version_id == ecm.id
        assert new_mv.scope == "mvm"


# ---------------------------------------------------------------------------
# Volume-import primitive: per-scope ordinal allocation
# ---------------------------------------------------------------------------


def test_import_from_volume_uses_per_scope_ordinal():
    """Importing an MVM model.json into a business with one ECM (v=1) and
    no MVM lands at MVM v=1, NOT MVM v=2."""
    from vibe_modeling.backend.services.operations.import_from_volume import (
        ImportFromVolume,
    )

    eng = make_engine()
    ws = make_ws()
    payload = {"model": {
        "type": "business",
        "domains": [],
        # No generated_from_version — exercise the per-scope allocator
        # without lineage interference.
    }}
    resp = MagicMock()
    resp.contents.read.return_value = json.dumps(payload).encode()
    ws.files.download.side_effect = None
    ws.files.download.return_value = resp

    with Session(eng) as session:
        biz_id, _ = seed_business_and_agent(session)
        # Pre-existing ECM at v=1 — shouldn't bump MVM's counter.
        session.add(ModelVersion(
            business_id=biz_id, version=1, scope="ecm",
            status="completed", deployment_status="draft",
        ))
        session.commit()

        run_id, op_id = seed_run_with_op(
            session, business_id=biz_id, operation_name="import_from_volume",
        )
        ctx = make_ctx(
            run_id=run_id, operation_id=op_id, business_id=biz_id,
            params={
                "volume_path": (
                    "/Volumes/c/_metamodel/vol_root/business/"
                    "test_corp/v1/mvm/model.json"
                ),
                "business_name": "test_corp",
                "deployment_catalog": "c",
            },
        )

        op = ImportFromVolume()
        handle = op.dispatch(ctx, ws, session)
        new_mv = session.get(ModelVersion, handle.extra["version_id"])
        assert new_mv.scope == "mvm"
        # Critical: per-scope counter — MVM had no rows so v=1 is the next
        # ordinal. A global counter would have produced v=2.
        assert new_mv.version == 1


# ---------------------------------------------------------------------------
# Agent 5.3.3 writes the parent in its ``lineage`` block, not as a tag
# ---------------------------------------------------------------------------

_AGENT_SHAPES = os.path.join(os.path.dirname(__file__), "..", "fixtures", "agent_shapes")


def _vibe_5_3_3(base_scope: str) -> dict:
    """The captured 5.3.3 vibe model.json, its lineage pointing at v1 of
    ``base_scope``. It carries no ``generated_from_version`` tag."""
    with open(os.path.join(_AGENT_SHAPES, "model_json_5_3_3_vibe.json")) as fh:
        doc = json.load(fh)
    assert "generated_from_version" not in doc and "generated_from_version" not in doc["model"]
    doc["lineage"]["base_scope"] = base_scope
    return doc


def test_import_from_volume_resolves_lineage_from_the_5_3_3_block():
    from vibe_modeling.backend.services.operations.import_from_volume import (
        ImportFromVolume,
    )

    eng = make_engine()
    ws = make_ws()
    resp = MagicMock()
    resp.contents.read.return_value = json.dumps(_vibe_5_3_3("ecm")).encode()
    ws.files.download.side_effect = None
    ws.files.download.return_value = resp

    with Session(eng) as session:
        biz_id, _ = seed_business_and_agent(session)
        ecm = ModelVersion(business_id=biz_id, version=1, scope="ecm", status="completed",
                           deployment_status="draft", uc_catalog="deploy_cat")
        session.add(ecm)
        session.commit()
        session.refresh(ecm)
        run_id, op_id = seed_run_with_op(
            session, business_id=biz_id, operation_name="import_from_volume", parent_version_id=None,
        )
        ctx = make_ctx(
            run_id=run_id, operation_id=op_id, business_id=biz_id, parent_version_id=None,
            params={
                "volume_path": "/Volumes/deploy_cat/_metamodel/vol_root/business/test_corp/v2/mvm/model.json",
                "business_name": "test_corp",
                "deployment_catalog": "deploy_cat",
            },
        )
        op = ImportFromVolume()
        obs = op.observe(op.dispatch(ctx, ws, session), ctx, ws, session)

        assert obs.terminal_result.succeeded is True
        new_mv = session.get(ModelVersion, obs.terminal_result.output_version_id)
        assert new_mv.base_version_id == ecm.id


def test_import_execute_route_resolves_lineage_from_the_5_3_3_block(
    client_with_agent, mock_ws, seed_business, engine,
):
    """The upload import links to the parent the lineage block names (ECM v1),
    not to the version-decrement guess (MVM v1)."""
    with Session(engine) as session:
        ecm = ModelVersion(business_id=seed_business, version=1, scope="ecm", status="completed")
        mvm = ModelVersion(business_id=seed_business, version=1, scope="mvm", status="completed")
        session.add_all([ecm, mvm])
        session.commit()
        ecm_id = ecm.id
    resp = MagicMock()
    resp.contents.read.return_value = json.dumps(_vibe_5_3_3("ecm")).encode()
    mock_ws.files.download.return_value = resp

    r = client_with_agent.post(
        f"/api/businesses/{seed_business}/import/execute",
        json={"volume_path": "/Volumes/test/schema/vol/model.json", "accept_business_mismatch": True},
    )

    assert r.status_code == 200, r.text
    with Session(engine) as session:
        new_mv = session.get(ModelVersion, r.json()["version_id"])
        assert (new_mv.version, new_mv.scope, new_mv.base_version_id) == (2, "mvm", ecm_id)


def test_terminal_success_prefers_the_5_3_3_lineage_block_over_ctx_parent():
    """The generation finalize takes the parent the lineage block names (MVM
    v1) over ``ctx.parent_version_id`` (ECM v1)."""
    from vibe_modeling.backend.services.operations._generation_common import (
        AGENT_OP_NEW_BASE_MODEL,
        _terminal_success,
    )

    eng = make_engine()
    ws = make_ws()
    with Session(eng) as session:
        biz_id, _ = seed_business_and_agent(session)
        ecm = ModelVersion(business_id=biz_id, version=1, scope="ecm", status="completed",
                           deployment_status="draft", uc_catalog="deploy_cat")
        mvm = ModelVersion(business_id=biz_id, version=1, scope="mvm", status="completed",
                           deployment_status="draft", uc_catalog="deploy_cat")
        session.add_all([ecm, mvm])
        session.commit()
        run_id, op_id = seed_run_with_op(
            session, business_id=biz_id, operation_name="enlarge_to_ecm", parent_version_id=ecm.id,
        )
        ctx = make_ctx(
            run_id=run_id, operation_id=op_id, business_id=biz_id, parent_version_id=ecm.id,
            params={"deployment_catalog": "deploy_cat", "business_name": "test_corp",
                    "model_vibes": "", "schema_prefix": "mvm_"},
        )
        payload = _vibe_5_3_3("mvm")
        payload["model"]["domains"] = []

        obs = _terminal_success(
            agent_operation=AGENT_OP_NEW_BASE_MODEL,
            ctx=ctx, ws=ws, session=session, warehouse_id="",
            catalog="deploy_cat", business_name="test_corp",
            agent_business="test_corp", agent_version="",
            agent_model_scope="mvm", scope_short="mvm",
            model_json_payload=payload,
        )

        assert obs.terminal_result.succeeded is True
        new_mv = session.get(ModelVersion, obs.terminal_result.output_version_id)
        assert new_mv.base_version_id == mvm.id
