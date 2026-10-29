"""Headline multi-step flows for the Vibe Inputs redesign (Task 5).

create input → compile → launch run → assert dispatched markdown + structured
params round-trip via GET /api/runs/{id} → simulate success (consumed flips,
link kept) / failure (not consumed, links CLEARED so inputs re-pool clean).
"""

import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "..", "src", "app", "src"))

import json
from unittest.mock import MagicMock

import pytest
from sqlmodel import Session, select

from vibe_modeling.backend import progress_tracker as pt
from vibe_modeling.backend._compile import compile_inputs
from vibe_modeling.backend.run_report import persist_agent_report
from vibe_modeling.backend.db_models import (
    Business,
    Domain,
    ModelVersion,
    RunInputLink,
    RunOperation,
    VibeInput,
    VibeInputContextLink,
)

HEADERS = {"X-Forwarded-Email": "flow@x.com"}


@pytest.fixture
def parent_ecm(engine):
    """Business + completed ECM v1 with one domain. Returns (bid, vid)."""
    with Session(engine) as s:
        b = Business(name="Acme", description="A test co", industry_alignment="Retail")
        s.add(b)
        s.commit()
        mv = ModelVersion(
            business_id=b.id, version=1, status="completed",
            deployment_status="draft", scope="ecm", uc_catalog="test_catalog",
        )
        s.add(mv)
        s.commit()
        s.add(Domain(version_id=mv.id, name="Sales"))
        s.commit()
        return b.id, mv.id


def _create_input(client, bid, vid, text="Add primary keys to all tables"):
    r = client.post(f"/api/businesses/{bid}/inputs",
                    json={"text": text, "version_id": vid}, headers=HEADERS)
    assert r.status_code == 200, r.text
    return r.json()["id"]


def _vibe_new_body(parent_vid, input_ids):
    return {
        "intent": "vibe-new-ecm-mvm",
        "parent_version_id": parent_vid,
        "catalog": "test_catalog",
        "cataloging_style": "One Catalog",
        "ecm_schema_prefix": "ecm_",
        "mvm_schema_prefix": "mvm_",
        "vibe_instructions": "",
        "input_ids": input_ids,
    }


def _vibe_iterate_body(parent_vid, input_ids):
    return {
        "intent": "vibe-iterate",
        "parent_version_id": parent_vid,
        "version_id": parent_vid,
        "catalog": "test_catalog",
        "cataloging_style": "One Catalog",
        "ecm_schema_prefix": "ecm_",
        "mvm_schema_prefix": "mvm_",
        "vibe_instructions": "",
        "input_ids": input_ids,
    }


def _set_selected(engine, iid, value=True):
    with Session(engine) as s:
        vi = s.get(VibeInput, iid)
        vi.selected_for_run = value
        s.add(vi)
        s.commit()


def test_create_compile_launch_dispatches_compiled_markdown(
    client_with_agent, mock_ws, engine, parent_ecm
):
    bid, vid = parent_ecm
    mock_ws.jobs.run_now.return_value = MagicMock(run_id=70001)
    iid = _create_input(client_with_agent, bid, vid)

    # The launch dispatches the compile's agent_markdown (the preview's
    # markdown plus inline anchors and K1 markers).
    with Session(engine) as s:
        expected = compile_inputs(s, vid, [iid]).agent_markdown
    assert "Add primary keys to all tables" in expected
    assert f"<!-- vi:{iid} target=model -->" in expected

    r = client_with_agent.post(f"/api/businesses/{bid}/runs",
                               json=_vibe_new_body(vid, [iid]))
    assert r.status_code == 200, r.text
    run_id = r.json()["id"]

    # Dispatched markdown == compiled markdown (audit preserved).
    with Session(engine) as s:
        from vibe_modeling.backend.db_models import Run
        run = s.get(Run, run_id)
        assert run.vibe_instructions_text == expected

    # Structured params round-trip via GET (feedback_verify_run_params_structured).
    detail = client_with_agent.get(f"/api/businesses/{bid}/runs/{run_id}").json()
    params = json.loads(detail["parameters_json"])
    assert params["input_ids"] == [iid]

    # RunInputLink written at launch (intended set), input not yet consumed.
    with Session(engine) as s:
        links = s.exec(select(RunInputLink).where(RunInputLink.run_id == run_id)).all()
        assert [lk.input_id for lk in links] == [iid]
        assert s.get(VibeInput, iid).consumed is False


def test_vibe_iterate_orchestrator_links_selected_inputs(
    client_with_agent, mock_ws, engine, parent_ecm
):
    """Regression: the orchestrator simple-intent launch
    (``_create_run_via_orchestrator``, used by vibe-iterate) must
    ``RunInputLink`` the selected inputs at run creation. It previously
    compiled them into the instructions but never linked them, so finalize
    could never consume them."""
    bid, vid = parent_ecm
    mock_ws.jobs.run_now.return_value = MagicMock(run_id=70003)
    iid = _create_input(client_with_agent, bid, vid, text="vibe-iterate input")
    resp = client_with_agent.post(
        f"/api/businesses/{bid}/runs", json=_vibe_iterate_body(vid, [iid])
    )
    assert resp.status_code == 200, resp.text
    run_id = resp.json()["id"]
    with Session(engine) as s:
        links = s.exec(select(RunInputLink).where(RunInputLink.run_id == run_id)).all()
        assert [lk.input_id for lk in links] == [iid], (
            "vibe-iterate (orchestrator) launch must link the selected inputs"
        )


def test_failure_clears_link_keeps_selection_success_consumes(
    client_with_agent, mock_ws, engine, parent_ecm
):
    """Lifecycle contract: a selected input is ``RunInputLink``-ed at launch;
    on FAILURE the link is cleared but ``selected_for_run`` is kept (durable
    selection survives a failed run — the user need not reselect); on SUCCESS
    the linked input the agent reports ``applied`` is consumed and selection
    clears."""
    bid, vid = parent_ecm
    mock_ws.jobs.run_now.return_value = MagicMock(run_id=70002)

    # FAILURE: link cleared, not consumed, selection remembered.
    iid_f = _create_input(client_with_agent, bid, vid, text="fail input")
    _set_selected(engine, iid_f, True)
    fail_run = client_with_agent.post(
        f"/api/businesses/{bid}/runs", json=_vibe_new_body(vid, [iid_f])
    ).json()["id"]
    with Session(engine) as s:
        assert s.exec(select(RunInputLink).where(RunInputLink.run_id == fail_run)).all()
        pt._finalize_run_inputs(fail_run, s, success=False)
    with Session(engine) as s:
        vi = s.get(VibeInput, iid_f)
        assert vi.consumed is False
        assert vi.selected_for_run is True  # remembered across the failed run
        assert s.exec(select(RunInputLink).where(RunInputLink.run_id == fail_run)).all() == []

    # Mark the failed run terminal so the single-run gate allows the next launch.
    with Session(engine) as s:
        from vibe_modeling.backend.db_models import Run
        fr = s.get(Run, fail_run)
        fr.status = "failed"
        s.add(fr)
        s.commit()

    # SUCCESS: consumed flips, selection clears, link kept as audit.
    iid_s = _create_input(client_with_agent, bid, vid, text="ok input")
    ok_run = client_with_agent.post(
        f"/api/businesses/{bid}/runs", json=_vibe_new_body(vid, [iid_s])
    ).json()["id"]
    with Session(engine) as s:
        op = s.exec(
            select(RunOperation)
            .where(RunOperation.run_id == ok_run)
            .where(RunOperation.operation_name == "vibe_iterate")
        ).one()
        op.status = "succeeded"
        s.add(op)
        persist_agent_report(s, ok_run, {
            "has_input_outcomes": True,
            "input_outcomes": [{"item_id": iid_s, "status": "applied"}],
        })
        s.commit()
        pt._finalize_run_inputs(ok_run, s, success=True)
    with Session(engine) as s:
        vi = s.get(VibeInput, iid_s)
        assert vi.consumed is True
        assert vi.selected_for_run is False
        assert len(s.exec(select(RunInputLink).where(RunInputLink.run_id == ok_run)).all()) == 1


def test_retry_relinks_inputs_after_failure(client_with_agent, mock_ws, engine, parent_ecm):
    """Failure deletes the run's RunInputLink rows (re-pool contract), so a
    retry must re-establish them from the recorded ``input_ids`` — otherwise a
    successful retry would find no links and consume nothing."""
    bid, vid = parent_ecm
    mock_ws.jobs.run_now.return_value = MagicMock(run_id=70004)
    iid = _create_input(client_with_agent, bid, vid, text="retry input")
    run_id = client_with_agent.post(
        f"/api/businesses/{bid}/runs", json=_vibe_new_body(vid, [iid])
    ).json()["id"]

    # Fail it: links deleted, run marked failed (retry requires a terminal state).
    with Session(engine) as s:
        pt._finalize_run_inputs(run_id, s, success=False)
        from vibe_modeling.backend.db_models import Run
        r = s.get(Run, run_id)
        r.status = "failed"
        s.add(r)
        s.commit()
    with Session(engine) as s:
        assert s.exec(select(RunInputLink).where(RunInputLink.run_id == run_id)).all() == []

    # Retry: links re-established from the recorded input_ids.
    resp = client_with_agent.post(f"/api/businesses/{bid}/runs/{run_id}/retry")
    assert resp.status_code == 200, resp.text
    with Session(engine) as s:
        links = s.exec(select(RunInputLink).where(RunInputLink.run_id == run_id)).all()
        assert [lk.input_id for lk in links] == [iid], "retry must re-link the recorded inputs"


def test_carry_forward_then_review_reset_on_new_version(
    client_with_agent, mock_ws, engine, parent_ecm
):
    """Rename a product (Task 4 fixture) → carry → auto-relink no review;
    delete a product → input deprecated; new version review % resets to 0."""
    bid, v1 = parent_ecm
    # Anchor an input at Sales.Orders on v1.
    with Session(engine) as s:
        d1 = s.exec(select(Domain).where(Domain.version_id == v1)).first()
        from vibe_modeling.backend.db_models import Product
        p1 = Product(version_id=v1, domain_id=d1.id, name="Orders")
        s.add(p1)
        s.commit()
        d1_id, p1_id = d1.id, p1.id
    iid = _create_input(client_with_agent, bid, v1, text="orders rule")
    # Re-anchor the origin link to Sales.Orders (create made it model-wide).
    with Session(engine) as s:
        link = s.exec(
            select(VibeInputContextLink).where(VibeInputContextLink.input_id == iid)
        ).first()
        link.domain_id = d1_id
        link.product_id = p1_id
        s.add(link)
        s.commit()

    # New version W: Orders renamed to SalesOrders (pointer set) → auto-relink.
    with Session(engine) as s:
        from vibe_modeling.backend.db_models import Product
        w = ModelVersion(business_id=bid, version=2, status="completed",
                         scope="ecm", base_version_id=v1)
        s.add(w)
        s.commit()
        d2 = Domain(version_id=w.id, name="Sales", previous_element_id=d1_id)
        s.add(d2)
        s.commit()
        p2 = Product(version_id=w.id, domain_id=d2.id, name="SalesOrders",
                     previous_element_id=p1_id)
        s.add(p2)
        s.commit()
        w_id, p2_id = w.id, p2.id

    r = client_with_agent.post(f"/api/businesses/{bid}/versions/{w_id}/inputs/carry-forward")
    assert r.status_code == 200
    body = r.json()
    assert body["auto_linked"] == 1
    assert body["needs_review"] == 0

    # New version review % resets to 0 (no ProductReview rows on W).
    summary = client_with_agent.get(f"/api/businesses/{bid}/versions/2/ecm/model").json()
    assert summary["review_pct"] == 0.0


def test_list_inputs_hydrates_mixed_anchors_in_one_call(client, engine, parent_ecm):
    """Mixed-anchor inputs → a single listVibeInputs call hydrates every
    card's anchor with resolved element names; no /links call needed to build
    section headers (CONFLICT-4)."""
    bid, v1 = parent_ecm
    with Session(engine) as s:
        d1 = s.exec(select(Domain).where(Domain.version_id == v1)).first()
        from vibe_modeling.backend.db_models import Product
        p1 = Product(version_id=v1, domain_id=d1.id, name="Orders")
        s.add(p1)
        s.commit()
        d1_id, d1_name, p1_id, p1_name = d1.id, d1.name, p1.id, p1.name

    # Element-anchored input (re-anchor the model-wide origin link).
    elem_id = _create_input(client, bid, v1, text="orders rule")
    with Session(engine) as s:
        link = s.exec(
            select(VibeInputContextLink).where(VibeInputContextLink.input_id == elem_id)
        ).first()
        link.domain_id = d1_id
        link.product_id = p1_id
        s.add(link)
        s.commit()

    # Model-wide input (left as created — all-null link).
    wide_id = _create_input(client, bid, v1, text="model-wide rule")

    items = client.get(f"/api/businesses/{bid}/inputs", headers=HEADERS).json()
    by_id = {it["id"]: it for it in items}

    a_elem = by_id[elem_id]["anchor"]
    assert a_elem["level"] == "element"
    assert a_elem["domain_id"] == d1_id and a_elem["domain_name"] == d1_name
    assert a_elem["product_id"] == p1_id and a_elem["product_name"] == p1_name
    assert f"Domain: {d1_name}" in a_elem["path"]
    assert f"Product: {p1_name}" in a_elem["path"]

    a_wide = by_id[wide_id]["anchor"]
    assert a_wide["level"] == "model_wide"
    assert a_wide["path"] == []


def test_business_proposed_domains_round_trip(client):
    """v_0_8_0: Create stores the wizard's proposed domains + coverage in the
    first commit; GET returns them; an update that omits them keeps them; an
    explicit empty update clears them; a non-preset coverage is refused."""
    body = {
        "name": "Proposal Co", "description": "d",
        "business_domains": "customer, billing,  ,customer", "org_divisions": "Operations and Business",
    }
    created = client.post("/api/businesses", json=body, headers=HEADERS)
    assert created.status_code == 200, created.text
    bid = created.json()["id"]
    assert created.json()["business_domains"] == "customer, billing"

    got = client.get(f"/api/businesses/{bid}", headers=HEADERS).json()
    assert (got["business_domains"], got["org_divisions"]) == ("customer, billing", "Operations and Business")

    kept = client.put(f"/api/businesses/{bid}", json={"name": "Proposal Co", "description": "d2"}, headers=HEADERS)
    assert (kept.json()["business_domains"], kept.json()["org_divisions"]) == ("customer, billing", "Operations and Business")

    cleared = client.put(
        f"/api/businesses/{bid}",
        json={"name": "Proposal Co", "description": "d2", "business_domains": "", "org_divisions": ""},
        headers=HEADERS,
    )
    assert (cleared.json()["business_domains"], cleared.json()["org_divisions"]) == ("", "")

    bad = client.put(
        f"/api/businesses/{bid}", json={"name": "Proposal Co", "description": "d2", "org_divisions": "All"},
        headers=HEADERS,
    )
    assert bad.status_code == 422
