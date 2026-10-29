"""Skeptical-Tester pass for validate-runs-merges-selections.

The ``POST /api/runs/validate`` endpoint is called by the New Run form on
every keystroke for inline error display. Before the fix the endpoint
raw-validated ``data.vibe_instructions`` against the leading op's
``min_length=1`` even when the user had selected ``next_vibe_ids`` /
``input_ids`` from the right-hand panel.

``/runs/validate`` applies the same selection logic ``POST /runs`` (create)
does:

  1. Resolve ``data.next_vibe_ids`` against the parent ECM's
     ``next_vibes_json``. Unknown ids are a blocker (create: 400).
  2. Set ``data.vibe_instructions`` to the compiled selected Vibe Inputs
     BEFORE calling ``validate_dag_request``. Next-vibe text is not folded
     into instructions - those IDs are validated + linked for audit only.

These tests are written WITHOUT reading either:

  - the selection handling of ``services/orchestrator/preflight.py``
    (``run_preflight``) or the body of ``validate_run``, or
  - ``tests/test_app/test_validate_runs_merges_selections.py`` (the
    dev-author tests).

They probe the public observable contract: HTTP request in, HTTP response
+ Lakebase row deltas out. Only the validate-side endpoint behaviour is
covered (per spec, ``validate_dag_request`` only routes the
``vibe-new-ecm-mvm`` factory at endpoint level today; ``vibe-iterate``
helper-level coverage lives in the dev's tests).
"""

from __future__ import annotations

import json
from typing import Any
from unittest.mock import MagicMock

import pytest
from sqlmodel import Session, select

from vibe_modeling.backend.db_models import (
    Run,
    RunNextVibeLink,
)


# ---------------------------------------------------------------------------
# Helpers (do not import implementation modules under test)
# ---------------------------------------------------------------------------


def _seed_parent_ecm_with_next_vibes(engine, business_id: str) -> tuple[str, list[str]]:
    """ECM-scope completed parent ModelVersion with three structured agent
    next-vibe VibeInput rows. Returns ``(version_id, nv_ids)`` — the durable
    VibeInput uuids the selection contract validates against."""
    from _next_vibes_seed import seed_version_with_next_vibe_inputs

    return seed_version_with_next_vibe_inputs(
        engine,
        business_id,
        titles=("Fix unlinked ids", "Connect disconnected tables", "Improve tags"),
        confidence=0.71,
    )


def _make_body(
    *,
    parent_version_id: str,
    vibe_instructions: str = "",
    next_vibe_ids: list[str] | None = None,
    input_ids: list[str] | None = None,
    cataloging_style: str = "One Catalog",
) -> dict:
    body: dict = {
        "intent": "vibe-new-ecm-mvm",
        "parent_version_id": parent_version_id,
        "vibe_instructions": vibe_instructions,
        "catalog": "test_catalog",
        "cataloging_style": cataloging_style,
        "business_context_path": "/Volumes/test/ctx/vibes/ctx.json",
    }
    if cataloging_style == "One Catalog":
        body["ecm_schema_prefix"] = "ecm_"
        body["mvm_schema_prefix"] = "mvm_"
    else:
        body["ecm_schema_prefix"] = ""
        body["mvm_schema_prefix"] = ""
    if next_vibe_ids is not None:
        body["next_vibe_ids"] = next_vibe_ids
    if input_ids is not None:
        body["input_ids"] = input_ids
    return body


def _seed_input(engine, business_id: str, version_id: str, text: str) -> str:
    """Create a model-wide VibeInput anchored to version_id; return its id."""
    from sqlmodel import Session as _S

    from vibe_modeling.backend.db_models import VibeInput, VibeInputContextLink

    with _S(engine) as session:
        vi = VibeInput(business_id=business_id, text=text)
        session.add(vi)
        session.commit()
        session.add(VibeInputContextLink(
            input_id=vi.id, version_id=version_id, is_origin=True,
        ))
        session.commit()
        return vi.id


def _has_min_length_blocker(validate_body: dict) -> bool:
    """Return True iff at least one blocker mentions the leading op's
    ``vibe_instructions`` min_length / empty-instructions failure.

    We do NOT pin to one phrasing — the underlying validator may surface
    "String should have at least 1 character", "vibe_instructions must
    not be empty", etc. We match a couple of generous substrings so the
    test is robust to validator wording changes.
    """
    blockers = validate_body.get("blockers") or []
    for b in blockers:
        msg = (b.get("message") or "").lower()
        field = (b.get("field_path") or "").lower()
        if "vibe_instructions" not in field and "vibe_instructions" not in msg:
            continue
        # Phrasings we expect from the validator / pydantic when the merged
        # vibe_instructions string is empty.
        for needle in (
            "at least 1 character",
            "min_length",
            "must not be empty",
            "empty",
            "cannot be empty",
            "required",
        ):
            if needle in msg:
                return True
    return False


def _mock_run_now(mock_ws: MagicMock, run_id: int = 90909) -> None:
    mock_run = MagicMock()
    mock_run.run_id = run_id
    mock_run.response = MagicMock()
    mock_run.response.run_id = run_id
    mock_ws.jobs.run_now.return_value = mock_run


# ---------------------------------------------------------------------------
# Endpoint-level tests against ``vibe-new-ecm-mvm`` (the only intent
# ``validate_dag_request`` routes today, per spec).
# ---------------------------------------------------------------------------


class TestValidateMergesSelections:
    """Each test posts a payload to ``/api/runs/validate`` and asserts the
    HTTP response shape. None of these tests should touch ``/api/runs``."""

    # 1) empty vibe_instructions + 1 selected input → 200 (no min_length error)
    def test_empty_instructions_plus_input_id_passes(
        self, client_with_agent, engine, seed_business
    ):
        parent_vid, nv_ids = _seed_parent_ecm_with_next_vibes(engine, seed_business)
        iid = _seed_input(engine, seed_business, parent_vid, "Add primary keys")

        body = _make_body(
            parent_version_id=parent_vid,
            vibe_instructions="",
            input_ids=[iid],
        )
        resp = client_with_agent.post(f"/api/businesses/{seed_business}/runs/validate", json=body)
        assert resp.status_code == 200, (
            f"validate with empty vibe_instructions + input_id should "
            f"return 200 (compile fills the instructions); got "
            f"{resp.status_code}: {resp.text}"
        )
        v = resp.json()
        assert not _has_min_length_blocker(v), (
            f"validate should NOT surface a min_length blocker on "
            f"vibe_instructions when input_ids compile fills it in. "
            f"Got blockers: {json.dumps(v.get('blockers'), indent=2)}"
        )

    # 2) empty everything → blocker for min_length on vibe_instructions
    def test_empty_everything_surfaces_min_length_blocker(
        self, client_with_agent, engine, seed_business
    ):
        parent_vid, nv_ids = _seed_parent_ecm_with_next_vibes(engine, seed_business)

        body = _make_body(
            parent_version_id=parent_vid,
            vibe_instructions="",
            next_vibe_ids=[],
        )
        resp = client_with_agent.post(f"/api/businesses/{seed_business}/runs/validate", json=body)
        # Validate endpoint's contract: it returns 200 + blockers, NOT 4xx,
        # for non-pydantic validation failures. (See the symmetry-with-create
        # contract in test_runs_validate_create_symmetry.py.)
        assert resp.status_code == 200, (
            f"validate should return 200 with blockers (not 4xx) for "
            f"non-pydantic failures; got {resp.status_code}: {resp.text}"
        )
        v = resp.json()
        assert _has_min_length_blocker(v), (
            f"validate must surface the empty-instructions blocker when "
            f"there is nothing to merge. Got blockers: "
            f"{json.dumps(v.get('blockers'), indent=2)}"
        )

    # 4) populated vibe_instructions, no selections → 200 (legacy path)
    def test_populated_instructions_no_selections_passes(
        self, client_with_agent, engine, seed_business
    ):
        parent_vid, nv_ids = _seed_parent_ecm_with_next_vibes(engine, seed_business)

        body = _make_body(
            parent_version_id=parent_vid,
            vibe_instructions="Add an HR domain with employees and roles.",
        )
        resp = client_with_agent.post(f"/api/businesses/{seed_business}/runs/validate", json=body)
        assert resp.status_code == 200, (
            f"validate with populated vibe_instructions should still 200; "
            f"got {resp.status_code}: {resp.text}"
        )
        v = resp.json()
        assert not _has_min_length_blocker(v), (
            f"populated vibe_instructions should not produce min_length "
            f"blocker. Got: {json.dumps(v.get('blockers'), indent=2)}"
        )

    # 5) unknown next_vibe_id → 400 with detail mentioning the bad id
    def test_unknown_next_vibe_id_is_a_blocker(
        self, client_with_agent, engine, seed_business
    ):
        parent_vid, nv_ids = _seed_parent_ecm_with_next_vibes(engine, seed_business)

        body = _make_body(
            parent_version_id=parent_vid,
            vibe_instructions="some text",
            next_vibe_ids=["nv-bogus"],
        )
        resp = client_with_agent.post(f"/api/businesses/{seed_business}/runs/validate", json=body)
        assert resp.status_code == 200, resp.text
        # The blocker names the bad id so the FE can surface it inline.
        messages = [b["message"] for b in resp.json()["blockers"] if b["field_path"] == "next_vibe_ids"]
        assert messages and "nv-bogus" in messages[0], resp.text

# ---------------------------------------------------------------------------
# 7) Symmetry between /api/runs and /api/runs/validate
# ---------------------------------------------------------------------------


class TestSymmetryWithCreate:
    """For each representative payload, the create and validate endpoints
    must agree on accept-vs-reject. The create endpoint may produce 200
    (run created) or 4xx (rejected); validate must reflect the same
    decision (200 with no min_length / merge blockers, or 4xx, or 200
    with blockers — never the inconsistent "validate is happy / create
    rejects" combination this fix targets).
    """

    def _accepted_or_blocked(
        self,
        client,
        business_id: str,
        body: dict,
    ) -> tuple[bool, dict, int]:
        """Returns (validate_accepted, validate_body, create_status).

        ``validate_accepted`` is True iff /runs/validate returns 200 AND
        has no blockers in the response. /runs/validate currently does
        NOT mirror create's gate set 1:1 (e.g. it returns 200 with
        blockers for create-side 4xx cases — see
        test_runs_validate_create_symmetry.py). So we treat
        "200 with blockers" as the same outcome as "create returns 4xx".
        """
        v_resp = client.post(f"/api/businesses/{business_id}/runs/validate", json=body)
        c_resp = client.post(f"/api/businesses/{business_id}/runs", json=body)

        if v_resp.status_code == 200:
            v_body = v_resp.json()
            v_accepted = not (v_body.get("blockers") or [])
        else:
            v_accepted = False
            v_body = {"status_code": v_resp.status_code, "text": v_resp.text}

        return v_accepted, v_body, c_resp.status_code

    def test_payload_that_creates_also_validates(
        self, client_with_agent, mock_ws, engine, seed_business
    ):
        """Populated vibe_instructions, valid catalog/style — happy path.
        Create returns 200; validate must agree."""
        _mock_run_now(mock_ws, run_id=80001)
        parent_vid, nv_ids = _seed_parent_ecm_with_next_vibes(engine, seed_business)

        body = _make_body(
            parent_version_id=parent_vid,
            vibe_instructions="Add an HR domain.",
        )

        v_accepted, v_body, c_status = self._accepted_or_blocked(
            client_with_agent, seed_business, body
        )
        assert c_status == 200, (
            f"create should accept the happy-path payload; got {c_status}"
        )
        assert v_accepted, (
            f"validate must accept the same payload that create accepts. "
            f"Validate body: {json.dumps(v_body, indent=2)}"
        )

    def test_payload_with_only_input_id_symmetric(
        self, client_with_agent, mock_ws, engine, seed_business
    ):
        """Empty vibe_instructions + selected input_id — create accepts
        (compile fills the leading op's params). Validate must agree."""
        _mock_run_now(mock_ws, run_id=80002)
        parent_vid, nv_ids = _seed_parent_ecm_with_next_vibes(engine, seed_business)
        iid = _seed_input(engine, seed_business, parent_vid, "Add an HR domain")

        body = _make_body(
            parent_version_id=parent_vid,
            vibe_instructions="",
            input_ids=[iid],
        )

        v_accepted, v_body, c_status = self._accepted_or_blocked(
            client_with_agent, seed_business, body
        )
        # Create succeeds because compile fills vibe_instructions before
        # validate_dag_request runs.
        assert c_status == 200, (
            f"create should accept the empty-instructions + input_id "
            f"payload; got {c_status}"
        )
        assert v_accepted, (
            f"validate must accept the same payload create accepts; "
            f"validate body: {json.dumps(v_body, indent=2)}"
        )

    def test_unknown_next_vibe_id_rejects_on_both(
        self, client_with_agent, mock_ws, engine, seed_business
    ):
        """Unknown next_vibe_id: create rejects with 400, validate with a blocker."""
        _mock_run_now(mock_ws, run_id=80003)
        parent_vid, nv_ids = _seed_parent_ecm_with_next_vibes(engine, seed_business)

        body = _make_body(
            parent_version_id=parent_vid,
            vibe_instructions="anything",
            next_vibe_ids=["nv-totally-bogus"],
        )

        v_resp = client_with_agent.post(f"/api/businesses/{seed_business}/runs/validate", json=body)
        c_resp = client_with_agent.post(f"/api/businesses/{seed_business}/runs", json=body)
        assert c_resp.status_code == 400, (
            f"create should reject unknown next_vibe_id with 400; got "
            f"{c_resp.status_code}: {c_resp.text}"
        )
        assert v_resp.status_code == 200, v_resp.text
        assert [b["message"] for b in v_resp.json()["blockers"] if b["field_path"] == "next_vibe_ids"] == [
            c_resp.json()["detail"]
        ]


# ---------------------------------------------------------------------------
# 8) State purity — validate must NOT touch the DB or call run_now
# ---------------------------------------------------------------------------


class TestValidateIsSideEffectFree:
    """``/api/runs/validate`` is fired on every keystroke. It must NOT
    persist Run rows, RunNextVibeLink rows, and must NOT call
    ``ws.jobs.run_now``. Otherwise the form would launch a Databricks run
    as the user types.
    """

    def _count_rows(self, engine) -> dict[str, int]:
        with Session(engine) as session:
            return {
                "runs": len(session.exec(select(Run)).all()),
                "next_vibe_links": len(
                    session.exec(select(RunNextVibeLink)).all()
                ),
            }

    def test_validate_creates_no_rows_and_does_not_call_run_now(
        self, client_with_agent, mock_ws, engine, seed_business
    ):
        # Set up a parent so we have rich-but-valid input.
        parent_vid, nv_ids = _seed_parent_ecm_with_next_vibes(engine, seed_business)
        # Mock ``run_now`` so we can assert it was NEVER called from validate.
        _mock_run_now(mock_ws, run_id=80101)
        # Drain any incidental call_count that might have come from fixture
        # set-up in another order. (None expected, but be defensive.)
        mock_ws.jobs.run_now.reset_mock()

        before = self._count_rows(engine)

        body = _make_body(
            parent_version_id=parent_vid,
            vibe_instructions="",
            next_vibe_ids=[nv_ids[0]],
        )
        resp = client_with_agent.post(f"/api/businesses/{seed_business}/runs/validate", json=body)
        assert resp.status_code == 200, (
            f"validate happy-path must 200; got {resp.status_code}: {resp.text}"
        )

        after = self._count_rows(engine)
        assert after == before, (
            f"validate must be side-effect-free; row counts changed: "
            f"before={before}, after={after}"
        )
        assert mock_ws.jobs.run_now.call_count == 0, (
            f"validate must NOT call ws.jobs.run_now; got "
            f"{mock_ws.jobs.run_now.call_count} call(s) with args: "
            f"{mock_ws.jobs.run_now.call_args_list}"
        )

    def test_validate_with_unknown_next_vibe_id_creates_no_rows(
        self, client_with_agent, mock_ws, engine, seed_business
    ):
        """Even on the rejection path, validate must not write rows or
        call run_now. (A defensive check — yells loudly if a future
        refactor lifts persistence above the resolve step.)"""
        parent_vid, nv_ids = _seed_parent_ecm_with_next_vibes(engine, seed_business)
        _mock_run_now(mock_ws, run_id=80102)
        mock_ws.jobs.run_now.reset_mock()

        before = self._count_rows(engine)

        body = _make_body(
            parent_version_id=parent_vid,
            vibe_instructions="",
            next_vibe_ids=["nv-bogus"],
        )
        resp = client_with_agent.post(f"/api/businesses/{seed_business}/runs/validate", json=body)
        assert resp.status_code == 200, resp.text
        assert any(b["field_path"] == "next_vibe_ids" for b in resp.json()["blockers"]), resp.text

        after = self._count_rows(engine)
        assert after == before, (
            f"validate must not write rows on the rejection path; "
            f"before={before}, after={after}"
        )
        assert mock_ws.jobs.run_now.call_count == 0, (
            f"validate must not call run_now on the rejection path; "
            f"got {mock_ws.jobs.run_now.call_count} call(s)"
        )
