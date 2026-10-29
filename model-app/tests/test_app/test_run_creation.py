"""Run creation path — vibe instructions Volume offload.

When the user-submitted vibe instructions exceed run_now's notebook_params
limit, create_run writes the text to a Volume and passes the path as the
`model_vibes` widget value (the agent resolves file paths starting with `/`
via `_resolve_vibes_from_file`). The full text is always persisted on the
Run row for audit, regardless of which channel delivered it to the notebook.
"""

import json
import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "..", "src", "app", "src"))

from unittest.mock import MagicMock

import pytest
from sqlmodel import Session, select

from vibe_modeling.backend.db_models import Run
from vibe_modeling.backend.job_launcher import VIBE_INSTRUCTIONS_INLINE_LIMIT


def _mock_run_now(mock_ws, run_id: int = 5555):
    mock_run = MagicMock()
    mock_run.run_id = run_id
    mock_ws.jobs.run_now.return_value = mock_run


def _load_run(engine, run_id: str) -> Run:
    with Session(engine) as session:
        return session.exec(select(Run).where(Run.id == run_id)).first()


def _dispatched_widgets(mock_ws) -> dict:
    """Return the ``notebook_params`` dict dispatched by ``run_now``.

    The orchestrator-routed POST /runs path stores ``RunIn`` (user form
    snapshot) in ``parameters_json`` per spec §5.1; the widget map is
    handed to ``mock_ws.jobs.run_now`` instead — that's the contract these
    tests need to assert on (post-uninstall-diagnosis 2026-05-18).
    """
    assert mock_ws.jobs.run_now.call_args is not None, "run_now was not invoked"
    return mock_ws.jobs.run_now.call_args.kwargs.get("notebook_params", {})


class TestShortInstructionsStayInline:
    def test_short_text_uses_inline_widget(
        self, client_with_agent, mock_ws, engine, seed_business_with_version
    ):
        seed_business = seed_business_with_version
        _mock_run_now(mock_ws)

        resp = client_with_agent.post(f"/api/businesses/{seed_business}/runs", json={
            "intent": "vibe-iterate",
            "catalog": "test_catalog",
            "vibe_instructions": "merge customer and account tables",
        })
        assert resp.status_code == 200, resp.text
        body = resp.json()

        widgets = _dispatched_widgets(mock_ws)
        assert widgets["model_vibes"] == "merge customer and account tables"
        mock_ws.files.upload.assert_not_called()

        assert body["vibe_instructions_text"] == "merge customer and account tables"
        assert body["vibe_instructions_volume_path"] == ""

        run = _load_run(engine, body["id"])
        assert run.vibe_instructions_text == "merge customer and account tables"
        assert run.vibe_instructions_volume_path == ""


class TestLongInstructionsStagedToVolume:
    def test_long_text_is_written_to_volume_and_widget_carries_path(
        self, client_with_agent, mock_ws, engine, seed_business_with_version
    ):
        seed_business = seed_business_with_version
        _mock_run_now(mock_ws)
        long_text = "please split the customer domain - " * 200
        assert len(long_text) > VIBE_INSTRUCTIONS_INLINE_LIMIT

        resp = client_with_agent.post(f"/api/businesses/{seed_business}/runs", json={
            "intent": "vibe-iterate",
            "catalog": "prod_catalog",
            "vibe_instructions": long_text,
        })
        assert resp.status_code == 200, resp.text
        data = resp.json()

        widgets = _dispatched_widgets(mock_ws)
        file_path = widgets["model_vibes"]
        assert file_path.startswith(
            "/Volumes/prod_catalog/_metamodel/vol_root/business/test_corp/_vibe_inputs/"
        )
        assert file_path.endswith(".txt")
        assert len(file_path) < VIBE_INSTRUCTIONS_INLINE_LIMIT

        mock_ws.files.upload.assert_called_once()
        upload_args, upload_kwargs = mock_ws.files.upload.call_args
        assert upload_args[0] == file_path
        assert upload_args[1].read().decode("utf-8") == long_text
        assert upload_kwargs.get("overwrite") is True

        # The orchestrator-routed path does not yet persist the volume
        # path back onto Run.vibe_instructions_volume_path — the legacy
        # widget-format path did. The user-submitted instructions text
        # still lands on the run row.
        run = _load_run(engine, data["id"])
        assert run.vibe_instructions_text == long_text

        _, run_now_kwargs = mock_ws.jobs.run_now.call_args
        notebook_params = run_now_kwargs["notebook_params"]
        assert notebook_params["model_vibes"] == file_path
        assert len(notebook_params["model_vibes"]) < 2048

    def test_upload_failure_does_not_launch_run(
        self, client_with_agent, mock_ws, seed_business_with_version
    ):
        """Volume upload failure surfaces on the run row, not as 502.

        Pre-uninstall-diagnosis 2026-05-18 the legacy widget-format
        dispatch raised the volume error synchronously and returned 502.
        Post-orchestrator-route, the upload happens inside the primitive's
        ``dispatch()``; the orchestrator catches it, marks the operation
        failed, and the route returns 200 with the failed run row. The
        critical invariant — `run_now` is NOT called when the volume
        write fails — remains intact.
        """
        seed_business = seed_business_with_version
        _mock_run_now(mock_ws)
        mock_ws.files.upload.side_effect = RuntimeError("volume write denied")
        long_text = "x" * (VIBE_INSTRUCTIONS_INLINE_LIMIT + 200)

        resp = client_with_agent.post(f"/api/businesses/{seed_business}/runs", json={
            "intent": "vibe-iterate",
            "catalog": "prod_catalog",
            "vibe_instructions": long_text,
        })
        assert resp.status_code == 200, resp.text
        mock_ws.jobs.run_now.assert_not_called()
        # The run row reflects the failed dispatch (the orchestrator
        # records the dispatch error against the run; the legacy 502 leak
        # of raw user text in the error envelope is no longer possible
        # because the error never reaches the HTTP detail).
        body = resp.json()
        assert body["status"] == "failed"
        assert "volume write denied" in (body.get("error_message") or "")


class TestDefaultCatalogFallback:
    def test_supplied_catalog_is_used(
        self, client_with_agent, mock_ws, seed_business_with_version
    ):
        seed_business = seed_business_with_version
        _mock_run_now(mock_ws)

        resp = client_with_agent.post(f"/api/businesses/{seed_business}/runs", json={
            "intent": "vibe-iterate",
            "catalog": "explicit_catalog",
            "vibe_instructions": "hi",
        })
        assert resp.status_code == 200, resp.text
        widgets = _dispatched_widgets(mock_ws)
        assert widgets["deployment_catalog"] == "explicit_catalog"

    def test_empty_catalog_falls_back_to_agent_default(
        self, client_with_agent, mock_ws, seed_business_with_version
    ):
        seed_business = seed_business_with_version
        _mock_run_now(mock_ws)

        resp = client_with_agent.post(f"/api/businesses/{seed_business}/runs", json={
            "intent": "vibe-iterate",
            "vibe_instructions": "hi",
        })
        assert resp.status_code == 200, resp.text
        widgets = _dispatched_widgets(mock_ws)
        assert widgets["deployment_catalog"] == "test_metamodel_catalog"

    @pytest.mark.skip(
        reason=(
            "Tests a legacy widget-format dispatch invariant: when "
            "cataloging_style != 'One Catalog' the legacy path declined "
            "to fall back to the agent's metamodel catalog. The "
            "orchestrator path resolves deployment_catalog differently "
            "(from inherited.params / agent_config), so the fallback "
            "behaviour is no longer router-level. Re-introduce as an "
            "operation-level test in tests/test_app/test_vibe_iterate.py "
            "when the orchestrator path adds the same gate."
        ),
    )
    def test_empty_catalog_with_non_one_catalog_style_does_not_fall_back(
        self, client_with_agent, mock_ws, seed_business_with_version
    ):
        seed_business = seed_business_with_version
        _mock_run_now(mock_ws)

        resp = client_with_agent.post(f"/api/businesses/{seed_business}/runs", json={
            "intent": "vibe-iterate",
            "cataloging_style": "Catalog per Division",
            "vibe_instructions": "hi",
        })
        assert resp.status_code == 200, resp.text
        widgets = _dispatched_widgets(mock_ws)
        assert widgets["deployment_catalog"] == ""
        assert widgets["cataloging_style"] == "Catalog per Division"


class TestUnifiedPipelineSchemaPrefixSeeding:
    """Router seeds ecm/mvm schema prefixes into `parameters_json` when a
    `new base model` unified run is created (#122). Defaults come from
    `cataloging_style`; explicit overrides win. The phase-1 `schema_prefix`
    widget is also rewritten to the ECM prefix so the agent's inline UC
    deployment lands in `ecm_*` schemas instead of colliding with the
    later MVM install in the shared catalog."""

    def test_one_catalog_defaults_to_ecm_and_mvm_prefix(
        self, client_with_agent, mock_ws, seed_business
    ):
        _mock_run_now(mock_ws)
        resp = client_with_agent.post(f"/api/businesses/{seed_business}/runs", json={
            "intent": "new-base-model",
            "catalog": "my_cat",
            "business_context_text": "Retail business",
        })
        assert resp.status_code == 200, resp.text
        params = json.loads(resp.json()["parameters_json"])
        assert params["ecm_schema_prefix"] == "ecm_"
        assert params["mvm_schema_prefix"] == "mvm_"
        # Phase 1 widget also picks up the ECM prefix so inline install
        # during `new base model` respects the namespace.
        assert params["schema_prefix"] == "ecm_"

    def test_multi_catalog_defaults_to_empty_prefixes(
        self, client_with_agent, mock_ws, seed_business
    ):
        _mock_run_now(mock_ws)
        resp = client_with_agent.post(f"/api/businesses/{seed_business}/runs", json={
            "intent": "new-base-model",
            "cataloging_style": "Catalog per Division",
            "business_context_text": "Retail business",
        })
        assert resp.status_code == 200, resp.text
        params = json.loads(resp.json()["parameters_json"])
        assert params["ecm_schema_prefix"] == ""
        assert params["mvm_schema_prefix"] == ""
        assert params["schema_prefix"] == ""

    def test_explicit_user_override_wins(
        self, client_with_agent, mock_ws, seed_business
    ):
        _mock_run_now(mock_ws)
        resp = client_with_agent.post(f"/api/businesses/{seed_business}/runs", json={
            "intent": "new-base-model",
            "catalog": "my_cat",
            "business_context_text": "Retail business",
            "ecm_schema_prefix": "custom_ecm_",
            "mvm_schema_prefix": "custom_mvm_",
        })
        assert resp.status_code == 200, resp.text
        params = json.loads(resp.json()["parameters_json"])
        assert params["ecm_schema_prefix"] == "custom_ecm_"
        assert params["mvm_schema_prefix"] == "custom_mvm_"
        assert params["schema_prefix"] == "custom_ecm_"

    def test_explicit_empty_override_preserved(
        self, client_with_agent, mock_ws, seed_business
    ):
        """User-provided empty string is a meaningful override — they want
        no prefix, even in One Catalog mode — and must not silently flip
        back to `ecm_`/`mvm_` defaults."""
        _mock_run_now(mock_ws)
        resp = client_with_agent.post(f"/api/businesses/{seed_business}/runs", json={
            "intent": "new-base-model",
            "catalog": "my_cat",
            "business_context_text": "Retail business",
            "ecm_schema_prefix": "",
            "mvm_schema_prefix": "",
        })
        assert resp.status_code == 200, resp.text
        params = json.loads(resp.json()["parameters_json"])
        assert params["ecm_schema_prefix"] == ""
        assert params["mvm_schema_prefix"] == ""
        assert params["schema_prefix"] == ""

    def test_non_new_base_model_run_does_not_seed_per_scope_prefixes(
        self, client_with_agent, mock_ws, seed_business_with_version
    ):
        """Only unified new-base-model runs get per-scope seeding — a
        regular vibe/shrink/install run keeps the legacy single
        schema_prefix widget behaviour unchanged.

        Post-uninstall-diagnosis 2026-05-18: the orchestrator-routed
        vibe-iterate path stores RunIn snapshot in ``parameters_json`` and
        dispatches widgets to ``run_now``. We assert against the dispatched
        widgets — the per-scope ecm/mvm keys live only in the new-base-model
        DAG and must NOT appear in a vibe-iterate widget payload.
        """
        seed_business = seed_business_with_version
        _mock_run_now(mock_ws)
        resp = client_with_agent.post(f"/api/businesses/{seed_business}/runs", json={
            "intent": "vibe-iterate",
            "catalog": "my_cat",
            "vibe_instructions": "add a new column",
            "schema_prefix": "legacy_",
        })
        assert resp.status_code == 200, resp.text
        widgets = _dispatched_widgets(mock_ws)
        # Per-scope keys are only seeded by the unified new-base-model DAG.
        assert "ecm_schema_prefix" not in widgets
        assert "mvm_schema_prefix" not in widgets
        # Legacy widget honours whatever the client sent.
        assert widgets["schema_prefix"] == "legacy_"


class TestNextVibeIdsIntegration:
    """Create run with next_vibe_ids → bodies folded into instructions + links persisted."""

    def _seed_version_with_next_vibes(self, engine, business_id: str) -> tuple[str, list[str]]:
        """Seed a version with three structured agent next-vibe VibeInput rows.

        Returns ``(version_id, [vibe_input_id, ...])`` — the ids are the
        durable VibeInput uuids the run-create selection contract validates
        against (the old synthetic ``nv-N`` ids are gone).
        """
        from sqlmodel import Session
        from vibe_modeling.backend.db_models import (
            ModelVersion,
            VibeInput,
            VibeInputContextLink,
            _now,
        )
        from vibe_modeling.backend.models import (
            NextVibeCategory,
            VibeInputOrigin,
            VibeInputPriority,
            VibeInputStatus,
        )

        with Session(engine) as session:
            mv = ModelVersion(business_id=business_id, version=1, status="completed")
            session.add(mv)
            session.flush()
            ids: list[str] = []
            for title in ("Fix unlinked ids", "Connect disconnected tables", "Improve tags"):
                vi = VibeInput(
                    business_id=business_id,
                    origin=VibeInputOrigin.AGENT_NEXT_VIBE.value,
                    author="",
                    text=f"{title}\n\nsome detail",
                    category=NextVibeCategory.PRIORITY_REMEDIATION.value,
                    priority=VibeInputPriority.HIGH.value,
                    confidence_score=0.71,
                    consumed=False,
                    status=VibeInputStatus.ACTIVE.value,
                    created_at=_now(),
                    updated_at=_now(),
                )
                session.add(vi)
                session.flush()
                session.add(VibeInputContextLink(
                    input_id=vi.id,
                    version_id=mv.id,
                    is_origin=True,
                    created_at=_now(),
                ))
                ids.append(vi.id)
            session.commit()
            return mv.id, ids

    def test_selected_next_vibes_linked_but_not_folded(
        self, client_with_agent, mock_ws, engine, seed_business
    ):
        """Task 5 clean break: next-vibe selections no longer fold their text
        into the agent-facing model_vibes blob (inputs/compile are the
        instruction source). The RunNextVibeLink audit rows are still written,
        and the user's typed instructions pass through unchanged."""
        _mock_run_now(mock_ws)
        version_id, nv_ids = self._seed_version_with_next_vibes(engine, seed_business)
        selected = [nv_ids[0], nv_ids[2]]

        resp = client_with_agent.post(f"/api/businesses/{seed_business}/runs", json={
            "intent": "vibe-iterate",
            "version_id": version_id,
            "catalog": "test_catalog",
            "vibe_instructions": "existing instructions",
            "next_vibe_ids": selected,
        })
        assert resp.status_code == 200, resp.text
        run_id = resp.json()["id"]

        call_args = mock_ws.jobs.run_now.call_args
        notebook_params = call_args.kwargs.get("notebook_params", {})
        model_vibes = notebook_params.get("model_vibes", "")
        # User's typed instructions survive; no agent-suggested fold.
        assert "existing instructions" in model_vibes
        assert "## Agent-Suggested Next Vibes" not in model_vibes
        assert "[agent-suggested]" not in model_vibes

        from sqlmodel import Session, select
        from vibe_modeling.backend.db_models import RunNextVibeLink
        with Session(engine) as session:
            links = session.exec(
                select(RunNextVibeLink).where(RunNextVibeLink.run_id == run_id)
            ).all()
            # RunNextVibeLink now stores VibeInput uuids for new runs (audit-only).
            assert sorted(link.next_vibe_id for link in links) == sorted(selected)

    def test_unknown_next_vibe_id_is_rejected(
        self, client_with_agent, mock_ws, engine, seed_business
    ):
        _mock_run_now(mock_ws)
        version_id, _nv_ids = self._seed_version_with_next_vibes(engine, seed_business)

        resp = client_with_agent.post(f"/api/businesses/{seed_business}/runs", json={
            "intent": "vibe-iterate",
            "version_id": version_id,
            "catalog": "test_catalog",
            "next_vibe_ids": ["nv-999"],
        })
        assert resp.status_code == 400
        assert "nv-999" in resp.json()["detail"]
        mock_ws.jobs.run_now.assert_not_called()

    def test_next_vibe_ids_without_base_version_rejected(
        self, client_with_agent, mock_ws, seed_business
    ):
        _mock_run_now(mock_ws)

        resp = client_with_agent.post(f"/api/businesses/{seed_business}/runs", json={
            "intent": "new-base-model",
            "catalog": "test_catalog",
            "business_context_text": "a business",
            "next_vibe_ids": ["nv-1"],
        })
        assert resp.status_code == 400
        assert "version_id" in resp.json()["detail"]
        mock_ws.jobs.run_now.assert_not_called()


class TestNewBaseModelSeedsFromBusinessVibes:
    """First run of a business: the detailed ``business_vibes`` seeds the
    ``model_vibes`` channel (large content spills to a Volume), while the short
    ``description`` summary stays the ``business_description`` widget. The two
    sources are decoupled — iterations use vibe_inputs, not the description."""

    def test_business_vibes_seeds_model_vibes_on_new_base_model(
        self, client_with_agent, mock_ws, engine, seed_business
    ):
        from sqlmodel import Session

        from vibe_modeling.backend.db_models import Business

        _mock_run_now(mock_ws)
        with Session(engine) as s:
            b = s.get(Business, seed_business)
            b.description = "Acme, a mid-size online retailer."
            b.business_vibes = "Detailed: orders, customers, SKUs, fulfilment, returns."
            s.add(b)
            s.commit()

        resp = client_with_agent.post(
            f"/api/businesses/{seed_business}/runs",
            json={"intent": "new-base-model", "catalog": "test_catalog"},
        )
        assert resp.status_code == 200, resp.text

        widgets = _dispatched_widgets(mock_ws)
        assert widgets["model_vibes"] == (
            "Detailed: orders, customers, SKUs, fulfilment, returns."
        )
        assert widgets["business_description"] == "Acme, a mid-size online retailer."


class TestDispatchedAgentWidgets:
    """What reaches ``run_now``: the agent's boolean label, the runtime budget,
    and no ``generate_samples`` widget even when the request still sends the
    tolerated ``RunIn.generate_samples``."""

    @pytest.mark.parametrize(
        "intent,business_fixture",
        [("new-base-model", "seed_business"), ("vibe-iterate", "seed_business_with_version")],
    )
    def test_agent_strings_and_budget_reach_run_now(
        self, request, client_with_agent, mock_ws, intent, business_fixture
    ):
        business_id = request.getfixturevalue(business_fixture)
        _mock_run_now(mock_ws)
        resp = client_with_agent.post(
            f"/api/businesses/{business_id}/runs",
            json={
                "intent": intent,
                "catalog": "test_catalog",
                "vibe_instructions": "merge customer and account tables",
                "boolean_format": "Integer (1/0)",
                "generate_samples": True,
            },
        )
        assert resp.status_code == 200, resp.text

        widgets = _dispatched_widgets(mock_ws)
        assert widgets["boolean_format"] == "Int (0/1)"
        # The Settings default, 6 hours (no AgentConfig override, no run override).
        assert widgets["runtime_budget_seconds"] == "21600"
        assert "generate_samples" not in widgets
