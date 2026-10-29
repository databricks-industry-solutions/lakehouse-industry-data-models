"""POST /api/runs/validate resolves the same selections create does.

The form's live error panel calls ``POST /api/runs/validate`` on every
keystroke and shows any ``blockers`` returned. The pydantic
``OperationStep.params`` schema for the ``vibe_iterate`` primitive
requires ``vibe_instructions: min_length=1`` — so an empty textbox
produces a ``steps[0].params.vibe_instructions: String should have at
least 1 character`` blocker that disables the Submit button.

Both endpoints set ``data.vibe_instructions`` to the compiled selected
Vibe Inputs and validate ``next_vibe_ids`` (IDs are linked for audit, not
folded into instructions) BEFORE handing the request to
``validate_dag_request``. So when the user has selected
inputs that compile into a non-empty doc, the validator no longer sees an
empty payload — the live form and the hard submit agree on accept/reject.

The bulk of the public-contract coverage targets ``vibe-new-ecm-mvm``
because that's the intent whose ``validate_dag_request`` factory is wired
today; vibe-iterate's symmetry is exercised at the helper level through
the shared pre-flight entry point, ``preflight.run_preflight``.
"""
from __future__ import annotations

import os
import sys
from unittest.mock import MagicMock

import pytest
from sqlmodel import Session, select

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "..", "src", "app", "src"))

from vibe_modeling.backend.models import (  # noqa: E402
    Intent,
    RunIn,
)
from vibe_modeling.backend.services.orchestrator.preflight import run_preflight  # noqa: E402


def _run_validate_preflight(business_id, data, session) -> None:
    """What both endpoints do to ``data`` before the DAG: the pre-flight."""
    from vibe_modeling.backend.db_models import AgentConfig, Business

    run_preflight(
        business_id, data, business=session.get(Business, business_id),
        agent_config=session.exec(select(AgentConfig)).first(), session=session,
        ws=None, config=None, user=None, create=False,
    )


# --------------------------------------------------------------------------- #
# Fixtures                                                                    #
# --------------------------------------------------------------------------- #


@pytest.fixture
def parent_ecm_with_next_vibes(engine, seed_business) -> tuple[str, str]:
    """Seed a completed ECM ModelVersion with three structured agent next-vibe
    VibeInput rows.

    Used as the base version for both ``vibe-new-ecm-mvm`` (via
    ``parent_version_id``) and the helper-level vibe-iterate tests.
    """
    from _next_vibes_seed import seed_version_with_next_vibe_inputs

    version_id, _nv_ids = seed_version_with_next_vibe_inputs(
        engine,
        seed_business,
        titles=("Tag missing pks", "Fill descriptions", "Add fk to orders"),
        confidence=0.70,
    )
    return seed_business, version_id


def _vibe_iterate_runin(
    *,
    version_id: str | None = None,
    vibe_instructions: str = "",
    next_vibe_ids: list[str] | None = None,
    input_ids: list[str] | None = None,
) -> RunIn:
    """Build a ``RunIn`` for the ``vibe-iterate`` intent.

    Used to exercise the helper directly (validate_dag_request doesn't
    have a ``vibe-iterate`` branch wired in the live coordinator, so we
    target the route handler's resolve+merge step where the fix lives).

    ``business_id`` is no longer a body field — callers pass it through
    the helper signature as a separate argument (URL path on the wire).
    """
    return RunIn(
        intent=Intent.VIBE_ITERATE,
        version_id=version_id,
        vibe_instructions=vibe_instructions,
        next_vibe_ids=list(next_vibe_ids or []),
        input_ids=list(input_ids or []),
    )


def _vibe_new_ecm_mvm_body(
    *,
    parent_version_id: str,
    vibe_instructions: str = "",
    next_vibe_ids: list[str] | None = None,
    input_ids: list[str] | None = None,
) -> dict:
    """Build a POST /api/runs/validate body for the combined intent."""
    return {
        "intent": Intent.VIBE_NEW_ECM_MVM.value,
        "parent_version_id": parent_version_id,
        "catalog": "test_catalog",
        "cataloging_style": "One Catalog",
        "ecm_schema_prefix": "ecm_",
        "mvm_schema_prefix": "mvm_",
        "vibe_instructions": vibe_instructions,
        "next_vibe_ids": list(next_vibe_ids or []),
        "input_ids": list(input_ids or []),
    }


def _seed_input(engine, business_id: str, version_id: str, text: str) -> str:
    """Create a model-wide VibeInput anchored to version_id; return its id."""
    from vibe_modeling.backend.db_models import VibeInput, VibeInputContextLink

    with Session(engine) as session:
        vi = VibeInput(business_id=business_id, text=text)
        session.add(vi)
        session.commit()
        session.add(VibeInputContextLink(
            input_id=vi.id, version_id=version_id, is_origin=True,
        ))
        session.commit()
        return vi.id


def _has_min_length_blocker(blockers: list[dict]) -> bool:
    """True iff any blocker is the empty-vibe_instructions min_length error."""
    for b in blockers:
        msg = (b.get("message") or "").lower()
        path = (b.get("field_path") or "").lower()
        if "vibe_instructions" in path and (
            "at least 1 character" in msg or "min_length" in msg
        ):
            return True
    return False


# --------------------------------------------------------------------------- #
# Helper-level coverage for vibe-iterate                                      #
# --------------------------------------------------------------------------- #
#
# Both endpoints run ``run_preflight``, which compiles the selected inputs
# into ``data.vibe_instructions`` before the DAG is built, so the symmetric
# behaviour for vibe-iterate is exercised at that level here.


class TestVibeIterateSelectionHelper:
    """The pre-flight's selection handling for the ``vibe-iterate`` intent."""

    def test_selected_input_ids_compiled_into_instructions(
        self, engine, parent_ecm_with_next_vibes,
    ):
        """Task 5 contract: instructions are filled from compiled Vibe Inputs
        (input_ids), not from a next-vibe text merge."""
        from vibe_modeling.backend.db_models import (
            VibeInput,
            VibeInputContextLink,
        )

        biz_id, parent_vid = parent_ecm_with_next_vibes
        with Session(engine) as session:
            vi = VibeInput(business_id=biz_id, text="Add PKs to all tables")
            session.add(vi)
            session.commit()
            session.add(VibeInputContextLink(
                input_id=vi.id, version_id=parent_vid, is_origin=True,
            ))
            session.commit()
            input_id = vi.id
        data = _vibe_iterate_runin(
            version_id=parent_vid,
            vibe_instructions="",
            input_ids=[input_id],
        )
        with Session(engine) as session:
            _run_validate_preflight(biz_id, data, session)
        assert data.vibe_instructions.strip(), (
            f"compile produced empty instructions: {data.vibe_instructions!r}"
        )
        assert "Add PKs to all tables" in data.vibe_instructions

    def test_empty_everything_is_noop(self, engine, seed_business):
        """No selections + empty instructions: helper is a no-op (the
        downstream params-validator surfaces the min_length blocker
        because there's genuinely nothing to merge)."""
        data = _vibe_iterate_runin(
            vibe_instructions="",
        )
        with Session(engine) as session:
            _run_validate_preflight(seed_business, data, session)
        assert data.vibe_instructions == "", (
            f"helper should not synthesize text from nothing; got "
            f"{data.vibe_instructions!r}"
        )

    def test_populated_instructions_no_selections_is_noop(
        self, engine, seed_business,
    ):
        """Existing user-typed instructions and no selections: helper is
        a no-op (no merge needed)."""
        original = "Existing user-typed vibe instructions."
        data = _vibe_iterate_runin(
            vibe_instructions=original,
        )
        with Session(engine) as session:
            _run_validate_preflight(seed_business, data, session)
        assert data.vibe_instructions == original, (
            f"helper mutated instructions when nothing was selected; got "
            f"{data.vibe_instructions!r}"
        )

# --------------------------------------------------------------------------- #
# Endpoint-level coverage for vibe-new-ecm-mvm                                #
# --------------------------------------------------------------------------- #


class TestValidateRunFoldsForVibeNewEcmMvm:
    """End-to-end via POST /api/runs/validate — vibe-new-ecm-mvm intent."""

    def test_empty_instructions_with_input_selection_no_min_length(
        self,
        client_with_agent,
        engine,
        parent_ecm_with_next_vibes,
    ):
        """Empty vibe_instructions + a selected Vibe Input must NOT yield
        the ``vibe_instructions: at least 1 character`` blocker. The validate
        endpoint compiles the selected inputs before the params validator, so
        the doc is non-empty (Task 5 — inputs are the instructions)."""
        biz_id, parent_vid = parent_ecm_with_next_vibes
        iid = _seed_input(engine, biz_id, parent_vid, "Add primary keys")
        body = _vibe_new_ecm_mvm_body(
            parent_version_id=parent_vid,
            vibe_instructions="",
            input_ids=[iid],
        )
        resp = client_with_agent.post(f"/api/businesses/{biz_id}/runs/validate", json=body)
        assert resp.status_code == 200, resp.text
        blockers = resp.json().get("blockers", [])
        assert not _has_min_length_blocker(blockers), (
            f"min_length blocker should be suppressed once inputs are "
            f"compiled in; got blockers={blockers}"
        )

    def test_empty_instructions_no_selections_emits_min_length(
        self,
        client_with_agent,
        engine,
        parent_ecm_with_next_vibes,
    ):
        """Empty everything → the validator correctly surfaces the
        min_length blocker (there's genuinely nothing to merge)."""
        biz_id, parent_vid = parent_ecm_with_next_vibes
        body = _vibe_new_ecm_mvm_body(
            parent_version_id=parent_vid,
            vibe_instructions="",
        )
        resp = client_with_agent.post(f"/api/businesses/{biz_id}/runs/validate", json=body)
        assert resp.status_code == 200, resp.text
        blockers = resp.json().get("blockers", [])
        assert _has_min_length_blocker(blockers), (
            f"min_length blocker should fire when there is nothing to "
            f"merge; got blockers={blockers}"
        )

    def test_populated_instructions_no_selections_no_min_length(
        self,
        client_with_agent,
        engine,
        parent_ecm_with_next_vibes,
    ):
        """Legacy path: user typed instructions, picked nothing — must
        validate cleanly (no min_length blocker)."""
        biz_id, parent_vid = parent_ecm_with_next_vibes
        body = _vibe_new_ecm_mvm_body(
            parent_version_id=parent_vid,
            vibe_instructions="Re-vibe ECM, then shrink.",
        )
        resp = client_with_agent.post(f"/api/businesses/{biz_id}/runs/validate", json=body)
        assert resp.status_code == 200, resp.text
        blockers = resp.json().get("blockers", [])
        assert not _has_min_length_blocker(blockers), (
            f"min_length should not fire when user typed instructions; "
            f"got blockers={blockers}"
        )

    def test_empty_instructions_multiple_inputs_selected_no_min_length(
        self,
        client_with_agent,
        engine,
        parent_ecm_with_next_vibes,
    ):
        """User selected several Vibe Inputs and typed nothing — the compiled
        doc is non-empty so min_length must not fire."""
        biz_id, parent_vid = parent_ecm_with_next_vibes
        ids = [
            _seed_input(engine, biz_id, parent_vid, f"rule {i}") for i in range(3)
        ]
        body = _vibe_new_ecm_mvm_body(
            parent_version_id=parent_vid,
            vibe_instructions="",
            input_ids=ids,
        )
        resp = client_with_agent.post(f"/api/businesses/{biz_id}/runs/validate", json=body)
        assert resp.status_code == 200, resp.text
        blockers = resp.json().get("blockers", [])
        assert not _has_min_length_blocker(blockers), (
            f"compiled inputs block must satisfy min_length; got "
            f"blockers={blockers}"
        )

    def test_unknown_next_vibe_id_is_a_blocker_with_creates_400_text(
        self,
        client_with_agent,
        engine,
        parent_ecm_with_next_vibes,
    ):
        """Unknown next_vibe_id surfaces as a validate blocker with the text
        of create's 400: no silent drop on validate."""
        biz_id, parent_vid = parent_ecm_with_next_vibes
        body = _vibe_new_ecm_mvm_body(
            parent_version_id=parent_vid,
            vibe_instructions="",
            next_vibe_ids=["nv-999"],
        )
        resp = client_with_agent.post(f"/api/businesses/{biz_id}/runs/validate", json=body)
        assert resp.status_code == 200, resp.text
        [blocker] = [b for b in resp.json()["blockers"] if b["field_path"] == "next_vibe_ids"]
        assert "nv-999" in blocker["message"]
        created = client_with_agent.post(f"/api/businesses/{biz_id}/runs", json=body)
        assert created.status_code == 400, created.text
        assert created.json()["detail"] == blocker["message"]
