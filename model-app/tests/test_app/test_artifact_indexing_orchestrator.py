"""Tests for orchestrator-path artifact indexing (#55).

The Artifacts tab on a model-version page is populated from
``run_artifacts`` rows that bind ``(run_id, model_version_id, file_path)``.
Two callers must keep that table in sync after a model-producing run:

* Legacy ``progress_tracker._sync_model_on_completion`` — the old
  Delta-poll completion path. Already wired pre-#55.
* Orchestrator ``services/operations/_generation_common._terminal_success``
  — the new path used by ``new-base-model``, ``vibe-iterate``,
  ``shrink_to_mvm``, ``enlarge_to_ecm``. Was missing pre-#55, so the
  Artifacts tab was empty for every orchestrator-driven run.

Both call sites now invoke the same lifted free function
``progress_tracker.index_artifacts_for_version``. This module exercises
the orchestrator path end-to-end.
"""

from __future__ import annotations

import os
import sys
from unittest.mock import MagicMock

from sqlmodel import Session, select

sys.path.insert(
    0, os.path.join(os.path.dirname(__file__), "..", "..", "src", "app", "src")
)
sys.path.insert(0, os.path.dirname(__file__))

from vibe_modeling.backend.db_models import (
    ModelVersion,
    RunArtifact,
)

from _phase2_helpers import (
    make_ctx,
    make_engine,
    make_ws,
    seed_business_and_agent,
    seed_run_with_op,
)


def _stub_volume_listing(ws, layout: dict[str, list[tuple[str, bool]]]) -> None:
    """Drive ``ws.files.list_directory_contents`` from a directory layout.

    ``layout`` maps each directory absolute path to a list of
    ``(name, is_directory)`` tuples. The walker (``_walk_volume_dir``)
    recurses into entries whose ``is_directory`` is True; leaves end up
    in the indexed file list.
    """
    def _listing(path: str):
        kids = layout.get(path, [])
        out = []
        for name, is_dir in kids:
            e = MagicMock()
            e.name = name
            e.is_directory = is_dir
            out.append(e)
        return out

    ws.files.list_directory_contents.side_effect = _listing


def test_terminal_success_indexes_volume_artifacts_onto_new_version():
    """After ``_terminal_success`` creates the new ModelVersion and runs
    ``ModelSyncService.sync_model``, it must walk the agent's Volume folder
    and insert ``RunArtifact`` rows linked to both the run AND the new
    model version. Without this wiring the Artifacts tab is empty for
    orchestrator-driven runs (#55).
    """
    from vibe_modeling.backend.services.operations._generation_common import (
        AGENT_OP_NEW_BASE_MODEL,
        _terminal_success,
    )

    eng = make_engine()
    ws = make_ws()

    catalog = "deploy_cat"
    business_name = "test_corp"
    # Match agent_business_segment (lower → space→_ → strip non-[a-z0-9_]).
    sanitized = "test_corp"
    # Fresh ECM at v=1 — `next_version_for_scope` will allocate this.
    expected_version = 1
    expected_scope = "ecm"
    root = (
        f"/Volumes/{catalog}/_metamodel/vol_root/business/"
        f"{sanitized}/{expected_scope}_v{expected_version}"
    )
    expected_files = [
        f"{root}/docs/model.json",
        f"{root}/schemas/erd.dbml",
        f"{root}/diagram/erd.svg",
        f"{root}/metrics/quality.csv",
    ]
    layout = {
        root: [
            ("docs", True),
            ("schemas", True),
            ("diagram", True),
            ("metrics", True),
        ],
        f"{root}/docs": [("model.json", False)],
        f"{root}/schemas": [("erd.dbml", False)],
        f"{root}/diagram": [("erd.svg", False)],
        f"{root}/metrics": [("quality.csv", False)],
    }
    _stub_volume_listing(ws, layout)

    with Session(eng) as session:
        biz_id, _ = seed_business_and_agent(session, business_name=business_name)
        run_id, op_id = seed_run_with_op(
            session, business_id=biz_id, operation_name="generate_ecm",
            parent_version_id=None,
        )
        ctx = make_ctx(
            run_id=run_id, operation_id=op_id, business_id=biz_id,
            parent_version_id=None,
            params={
                "deployment_catalog": catalog,
                "business_name": business_name,
                "model_vibes": "",
                "schema_prefix": "ecm_",
            },
        )

        obs = _terminal_success(
            agent_operation=AGENT_OP_NEW_BASE_MODEL,
            ctx=ctx, ws=ws, session=session, warehouse_id="",
            catalog=catalog, business_name=business_name,
            agent_business=business_name, agent_version="",
            agent_model_scope=expected_scope, scope_short=expected_scope,
            model_json_payload=None,
        )
        session.commit()

        assert obs.is_terminal is True
        assert obs.terminal_result.succeeded is True
        new_mv_id = obs.terminal_result.output_version_id
        assert new_mv_id

        new_mv = session.get(ModelVersion, new_mv_id)
        assert new_mv is not None
        assert new_mv.scope == expected_scope
        assert new_mv.version == expected_version

        # The walker should have been invoked with the agent's volume root.
        ws.files.list_directory_contents.assert_any_call(root)

        # Every file the walker found becomes a RunArtifact row bound to
        # both the run AND the new ModelVersion.
        rows = session.exec(
            select(RunArtifact).where(
                RunArtifact.run_id == run_id,
                RunArtifact.model_version_id == new_mv_id,
            )
        ).all()
        actual_paths = sorted(r.file_path for r in rows)
        assert actual_paths == sorted(expected_files), (
            f"orchestrator path must index every Volume file as a "
            f"RunArtifact bound to the new ModelVersion; "
            f"expected={sorted(expected_files)} actual={actual_paths}"
        )

        # `artifact_type` is inferred from the extension — sanity check
        # one of each so the indexer's mapping table is wired correctly.
        by_path = {r.file_path: r for r in rows}
        # `model.json` files get the canonical `model_json` artifact_type
        # (not the bare `.json` mapping) so `_find_model_json_path`
        # Strategy 1 in explorer.py finds them. See SPEC_FIX1 Bug 1.
        assert by_path[f"{root}/docs/model.json"].artifact_type == "model_json"
        assert by_path[f"{root}/schemas/erd.dbml"].artifact_type == "dbml"
        assert by_path[f"{root}/diagram/erd.svg"].artifact_type == "svg"
        assert by_path[f"{root}/metrics/quality.csv"].artifact_type == "csv"


def test_terminal_success_artifact_indexing_does_not_fail_run():
    """Indexing is best-effort. If the Volume walker raises, the op must
    still terminate as successful — the agent's artifacts landed even if
    we can't read the directory listing right now."""
    from vibe_modeling.backend.services.operations._generation_common import (
        AGENT_OP_NEW_BASE_MODEL,
        _terminal_success,
    )

    eng = make_engine()
    ws = make_ws()
    # Make the listing raise unconditionally — _walk_volume_dir swallows
    # the exception, but we also want to prove the surrounding _terminal_success
    # try/except guard is in place if the helper itself were to bubble.
    ws.files.list_directory_contents.side_effect = RuntimeError(
        "simulated permission error"
    )

    with Session(eng) as session:
        biz_id, _ = seed_business_and_agent(session)
        run_id, op_id = seed_run_with_op(
            session, business_id=biz_id, operation_name="generate_ecm",
        )
        ctx = make_ctx(
            run_id=run_id, operation_id=op_id, business_id=biz_id,
            params={
                "deployment_catalog": "deploy_cat",
                "business_name": "test_corp",
                "model_vibes": "",
                "schema_prefix": "ecm_",
            },
        )

        obs = _terminal_success(
            agent_operation=AGENT_OP_NEW_BASE_MODEL,
            ctx=ctx, ws=ws, session=session, warehouse_id="",
            catalog="deploy_cat", business_name="test_corp",
            agent_business="test_corp", agent_version="",
            agent_model_scope="ecm", scope_short="ecm",
            model_json_payload=None,
        )
        session.commit()

        assert obs.terminal_result.succeeded is True
        # No artifacts indexed (walker failed) but the op still terminated
        # cleanly with a created ModelVersion.
        rows = session.exec(
            select(RunArtifact).where(RunArtifact.run_id == run_id)
        ).all()
        assert rows == []
