"""Per-feedback run report (v0.9.0 design section 2).

Covers ``backend/run_report.py`` (``persist_agent_report`` per summary shape,
``consume_note``, ``build_run_report``), the two read routes in
``routes/run_report.py`` (``getRunReport``, ``getVersionReport``), the agent
status vocabulary pinned against the vendored notebook, and the model.json
helpers the report reads through (``agent_compat.model_json_block``,
``generated_from_version_tag``, ``_query_helpers.parse_version_number``).
"""

from __future__ import annotations

import json
import re
from datetime import datetime, timezone

import pytest
from sqlmodel import Session, select

from vibe_modeling.backend._query_helpers import parse_version_number
from vibe_modeling.backend.agent_compat import (
    generated_from_version_tag,
    model_json_block,
)
from vibe_modeling.backend.db_models import (
    Business,
    ModelVersion,
    Run,
    RunAgentReport,
    RunInputLink,
    RunOperation,
    VibeInput,
)
from vibe_modeling.backend.run_report import (
    AGENT_OUTCOME_STATUSES,
    build_run_report,
    persist_agent_report,
)

from ._source_scan import agent_notebook_source


# --------------------------------------------------------------------------
# helpers
# --------------------------------------------------------------------------


def _seed(engine, *, n_inputs=2, intent="vibe-iterate", status="completed",
          dry_run=False, with_op=True, name="Acme"):
    """Business + parent version + run (+ succeeded vibe op producing v2) + linked inputs."""
    with Session(engine) as s:
        biz = Business(name=name)
        s.add(biz)
        s.flush()
        parent = ModelVersion(business_id=biz.id, version=1, scope="ecm", status="completed")
        s.add(parent)
        s.flush()
        run = Run(business_id=biz.id, intent=intent, status=status,
                  parameters_json=json.dumps({"dry_run": dry_run}))
        s.add(run)
        s.flush()
        out_id = None
        if with_op:
            out = ModelVersion(business_id=biz.id, version=2, scope="ecm",
                               status="draft" if dry_run else "completed", dry_run=dry_run)
            s.add(out)
            s.flush()
            out_id = out.id
            s.add(RunOperation(run_id=run.id, step_index=0, operation_name="vibe_iterate",
                               params_json="{}", status="succeeded", output_version_id=out.id,
                               completed_at=datetime.now(timezone.utc)))
        ids = []
        for i in range(n_inputs):
            vi = VibeInput(business_id=biz.id, text=f"item {i}", selected_for_run=True)
            s.add(vi)
            s.flush()
            s.add(RunInputLink(run_id=run.id, input_id=vi.id))
            ids.append(vi.id)
        s.commit()
        return biz.id, run.id, out_id, ids


def _summary(outcomes=None, **kw) -> dict:
    base = {"expected_version": 2, "fetched_version": 2, "version_mismatch": False,
            "has_input_outcomes": outcomes is not None, "input_outcomes": outcomes or [],
            "input_outcomes_malformed": False, "lineage": {}}
    base.update(kw)
    return base


def _persist(engine, run_id, summary):
    with Session(engine) as s:
        persist_agent_report(s, run_id, summary)
        s.commit()


def _report(engine, run_id):
    with Session(engine) as s:
        return build_run_report(s, s.get(Run, run_id))


# --------------------------------------------------------------------------
# persist_agent_report per summary shape
# --------------------------------------------------------------------------


def test_persist_writes_report_and_link_outcomes(engine):
    _, run_id, _, ids = _seed(engine, n_inputs=3)
    _persist(engine, run_id, _summary(
        [{"item_id": ids[0], "status": "applied", "reason": None, "target": "sales"},
         {"item_id": ids[1], "status": "deferred", "reason": "later", "target": None},
         {"item_id": "elsewhere", "status": "applied"}],
        lineage={"base_version": 1, "head_at_write": 3, "stale": True},
    ))
    with Session(engine) as s:
        rep = s.get(RunAgentReport, run_id)
        assert (rep.has_input_outcomes, rep.outcomes_malformed, rep.version_mismatch) == (True, False, False)
        assert (rep.expected_version, rep.fetched_version) == (2, 2)
        assert (rep.lineage_base_version, rep.lineage_head_at_write, rep.lineage_stale) == (1, 3, True)
        assert rep.unmatched_outcome_count == 1
        links = {lk.input_id: lk for lk in s.exec(select(RunInputLink)).all()}
        assert (links[ids[0]].outcome_status, links[ids[0]].outcome_target) == ("applied", "sales")
        assert (links[ids[1]].outcome_status, links[ids[1]].outcome_reason) == ("deferred", "later")
        assert links[ids[2]].outcome_status == "not_reported"


@pytest.mark.parametrize("summary", [
    _summary(None),
    _summary([], has_input_outcomes=True, input_outcomes_malformed=True),
    _summary([{"item_id": "x", "status": "applied"}], version_mismatch=True),
], ids=["missing", "malformed", "version_mismatch"])
def test_persist_writes_no_outcomes_when_untrusted(engine, summary):
    _, run_id, _, ids = _seed(engine, n_inputs=1)
    with Session(engine) as s:
        link = s.get(RunInputLink, (run_id, ids[0]))
        link.outcome_status = "applied"
        s.add(link)
        s.commit()
    _persist(engine, run_id, summary)
    with Session(engine) as s:
        assert s.get(RunInputLink, (run_id, ids[0])).outcome_status is None
        assert s.get(RunAgentReport, run_id) is not None


def test_persist_replaces_an_earlier_report(engine):
    _, run_id, _, ids = _seed(engine, n_inputs=1)
    _persist(engine, run_id, _summary(None, version_mismatch=True))
    _persist(engine, run_id, _summary([{"item_id": ids[0], "status": "applied"}]))
    with Session(engine) as s:
        assert len(s.exec(select(RunAgentReport)).all()) == 1
        assert s.get(RunAgentReport, run_id).version_mismatch is False


# --------------------------------------------------------------------------
# consume_note
# --------------------------------------------------------------------------


def test_note_none_when_outcomes_applied_normally(engine):
    _, run_id, out_id, ids = _seed(engine)
    _persist(engine, run_id, _summary([{"item_id": ids[0], "status": "applied"}]))
    rep = _report(engine, run_id)
    assert rep.consume_note is None
    assert rep.has_agent_report and rep.has_input_outcomes
    assert rep.output_version_id == out_id
    assert [i.outcome_status for i in rep.items] == ["applied", "not_reported"]


def test_note_no_outcomes_reported(engine):
    _, run_id, _, _ = _seed(engine)
    _persist(engine, run_id, _summary(None))
    assert _report(engine, run_id).consume_note == "no_outcomes_reported"


def test_note_no_outcomes_reported_for_an_empty_list(engine):
    """The key is present but names none of the inputs the run sent."""
    _, run_id, _, ids = _seed(engine)
    _persist(engine, run_id, _summary([]))
    rep = _report(engine, run_id)
    assert rep.has_input_outcomes is True
    assert rep.consume_note == "no_outcomes_reported"
    _persist(engine, run_id, _summary([{"item_id": "not-sent", "status": "applied"}]))
    assert _report(engine, run_id).consume_note == "no_outcomes_reported"


@pytest.mark.parametrize("sync_state", ["sync_empty", "incomplete_metadata"])
def test_note_sync_failed_from_the_output_version(engine, sync_state):
    """A failed sync rolls the report back with it; the note says so instead
    of reading the run as older than reports."""
    _, run_id, out_id, _ = _seed(engine)
    with Session(engine) as s:
        mv = s.get(ModelVersion, out_id)
        mv.sync_state = sync_state
        s.add(mv)
        s.commit()
    rep = _report(engine, run_id)
    assert rep.consume_note == "sync_failed" and rep.has_agent_report is False


def test_note_malformed(engine):
    _, run_id, _, _ = _seed(engine)
    _persist(engine, run_id, _summary([], has_input_outcomes=True, input_outcomes_malformed=True))
    assert _report(engine, run_id).consume_note == "malformed"


def test_note_version_mismatch_on_the_failed_run(engine):
    _, run_id, _, _ = _seed(engine, status="failed", with_op=False)
    _persist(engine, run_id, _summary(None, version_mismatch=True, fetched_version=1))
    rep = _report(engine, run_id)
    assert rep.consume_note == "version_mismatch"
    assert (rep.expected_version, rep.fetched_version) == (2, 1)


def test_note_pre_0_9_0_for_a_completed_vibe_run_without_report(engine):
    _, run_id, _, _ = _seed(engine)
    rep = _report(engine, run_id)
    assert rep.consume_note == "pre_0_9_0" and rep.has_agent_report is False


def test_no_note_for_a_failed_run_without_report(engine):
    _, run_id, _, _ = _seed(engine, status="failed", with_op=False)
    assert _report(engine, run_id).consume_note is None


def test_note_dry_run_pending_then_installed(engine):
    _, run_id, out_id, ids = _seed(engine, dry_run=True)
    _persist(engine, run_id, _summary([{"item_id": ids[0], "status": "applied"}]))
    rep = _report(engine, run_id)
    assert rep.dry_run is True and rep.consume_note == "dry_run_pending_install"
    with Session(engine) as s:
        mv = s.get(ModelVersion, out_id)
        mv.promoted_at = datetime.now(timezone.utc)
        s.add(mv)
        s.commit()
    assert _report(engine, run_id).consume_note == "dry_run_installed"


def test_dry_run_without_outcomes_says_no_outcomes(engine):
    """Installing the draft would mark nothing done either, so that note wins."""
    _, run_id, _, _ = _seed(engine, dry_run=True)
    _persist(engine, run_id, _summary(None))
    assert _report(engine, run_id).consume_note == "no_outcomes_reported"


def test_note_install_consumed(engine):
    _, run_id, _, ids = _seed(engine, intent="install", with_op=False)
    assert _report(engine, run_id).consume_note is None
    with Session(engine) as s:
        link = s.get(RunInputLink, (run_id, ids[0]))
        link.outcome_status = "reopened"
        s.add(link)
        s.commit()
    assert _report(engine, run_id).consume_note == "install_consumed"


def test_items_carry_the_input_state_now(engine):
    _, run_id, _, ids = _seed(engine, n_inputs=1)
    with Session(engine) as s:
        vi = s.get(VibeInput, ids[0])
        vi.consumed, vi.consumed_by_run_id, vi.selected_for_run = True, run_id, False
        s.add(vi)
        s.commit()
    item = _report(engine, run_id).items[0]
    assert (item.text, item.consumed, item.consumed_by_run_id, item.selected_for_run) == (
        "item 0", True, run_id, False)
    assert item.created_at.tzinfo is not None


# --------------------------------------------------------------------------
# routes
# --------------------------------------------------------------------------


def test_get_run_report_route(client, engine):
    bid, run_id, _, ids = _seed(engine, n_inputs=1)
    _persist(engine, run_id, _summary([{"item_id": ids[0], "status": "partial",
                                        "reason": "half", "target": "sales"}]))
    resp = client.get(f"/api/businesses/{bid}/runs/{run_id}/report")
    assert resp.status_code == 200, resp.text
    body = resp.json()
    assert body["run_id"] == run_id and body["consume_note"] is None
    assert body["items"][0]["outcome_status"] == "partial"
    assert body["items"][0]["outcome_reason"] == "half"


def test_get_run_report_404_for_another_business(client, engine):
    _, run_id, _, _ = _seed(engine)
    other_bid, _, _, _ = _seed(engine, name="Other Co")
    resp = client.get(f"/api/businesses/{other_bid}/runs/{run_id}/report")
    assert resp.status_code == 404


def test_get_version_report_finds_the_producing_run(client, engine):
    bid, run_id, out_id, ids = _seed(engine, n_inputs=1)
    _persist(engine, run_id, _summary([{"item_id": ids[0], "status": "applied"}]))
    resp = client.get(f"/api/businesses/{bid}/versions/{out_id}/report")
    assert resp.status_code == 200, resp.text
    body = resp.json()
    assert body["version_id"] == out_id
    assert body["report"]["run_id"] == run_id


def test_get_version_report_null_without_a_vibe_run(client, engine):
    bid, _, _, _ = _seed(engine)
    with Session(engine) as s:
        parent = s.exec(select(ModelVersion).where(ModelVersion.business_id == bid,
                                                   ModelVersion.version == 1)).one()
        parent_id = parent.id
    resp = client.get(f"/api/businesses/{bid}/versions/{parent_id}/report")
    assert resp.status_code == 200
    assert resp.json() == {"version_id": parent_id, "report": None}


def test_get_version_report_404_for_another_business(client, engine):
    _, _, out_id, _ = _seed(engine)
    other_bid, _, _, _ = _seed(engine, name="Other Co")
    resp = client.get(f"/api/businesses/{other_bid}/versions/{out_id}/report")
    assert resp.status_code == 404


def test_report_routes_write_nothing(client, engine):
    bid, run_id, out_id, _ = _seed(engine)

    def _digest():
        with Session(engine) as s:
            return (
                [(lk.run_id, lk.input_id, lk.outcome_status) for lk in s.exec(select(RunInputLink)).all()],
                len(s.exec(select(RunAgentReport)).all()),
                [(v.id, v.consumed, v.selected_for_run) for v in s.exec(select(VibeInput)).all()],
            )

    before = _digest()
    assert client.get(f"/api/businesses/{bid}/runs/{run_id}/report").status_code == 200
    assert client.get(f"/api/businesses/{bid}/versions/{out_id}/report").status_code == 200
    assert _digest() == before


# --------------------------------------------------------------------------
# agent vocabulary pin
# --------------------------------------------------------------------------


def test_outcome_status_vocabulary_matches_the_agent():
    """Every status the vendored agent can write is one the report knows."""
    src = agent_notebook_source()
    scope = re.search(r"_VIBE_INPUT_SCOPE_STATUSES = \(([^)]*)\)", src).group(1)
    open_order = re.search(r"_VIBE_INPUT_OPEN_ORDER = \(([^)]*)\)", src).group(1)
    agent = set(re.findall(r'"([a-z_]+)"', scope + open_order))
    fold = src[src.index("def _vibe_input_fold("):]
    fold = fold[: fold.index("\ndef ", 1)]
    agent |= set(re.findall(r'return "([a-z_]+)"', fold))
    assert agent == set(AGENT_OUTCOME_STATUSES)


# --------------------------------------------------------------------------
# model.json helpers (D1, D4)
# --------------------------------------------------------------------------


def test_model_json_block_reads_the_root_only():
    doc = {"lineage": {"a": 1}, "model": {"input_outcomes": []}}
    assert model_json_block(doc, "lineage") == {"a": 1}
    assert model_json_block(doc, "input_outcomes") is None
    sentinel = object()
    assert model_json_block(doc, "input_outcomes", sentinel) is sentinel
    assert model_json_block({"input_outcomes": None}, "input_outcomes", sentinel) is None
    assert model_json_block(["not", "a", "dict"], "lineage") is None


def test_generated_from_version_tag_root_then_envelope():
    assert generated_from_version_tag({"generated_from_version": "v1_ecm"}) == "v1_ecm"
    assert generated_from_version_tag({"model": {"generated_from_version": "v2_mvm"}}) == "v2_mvm"
    assert generated_from_version_tag(
        {"_vibe_session_metadata": {"generated_from_version": "v3_ecm"}}) == ""
    assert generated_from_version_tag(None) == ""


@pytest.mark.parametrize("value,expected", [
    (7, 7), ("7", 7), (" v7 ", 7), ("v7_ecm", 7), ("v12_mvm", 12),
    (True, None), (None, None), ("", None), ("unknown", None), ("7.1", None), ("v7_foo", None),
])
def test_parse_version_number(value, expected):
    assert parse_version_number(value) == expected
