"""Scoped / Dry Run vibe-iterate (design 2026-10-18 single-domain vibe scope).

Covers track B5:

* dispatch maps ``vibe_scope`` / ``vibe_scope_domains`` / ``dry_run`` onto
  the agent widgets (``vibe_scope``, ``business_domains``, ``run_type``);
* a Dry Run saves a ``draft`` version flagged ``dry_run``, supersedes
  nothing, consumes nothing;
* the D13 fetch rules: the expected version is retried through every
  attempt before any fallback; a fallback or a ``lineage.output_version``
  mismatch fails the op with no version row (A2r);
* the agent's report is written as rows (``run_agent_reports`` and the
  ``run_input_links.outcome_*`` columns), read at the model.json root only;
* outcome-driven consume in ``progress_tracker._finalize_run_inputs`` from
  those rows (only ``applied`` consumes; a missing ``input_outcomes`` key,
  no report and a malformed ``input_outcomes`` consume nothing);
* an unscoped, non-dry run is unchanged.
"""

from __future__ import annotations

import json
from typing import Optional
from unittest.mock import MagicMock, patch

import pytest
from sqlmodel import Session, select

from vibe_modeling.backend import progress_tracker as pt
from vibe_modeling.backend.core._paths import model_json_volume_candidates
from vibe_modeling.backend.db_models import (
    Business,
    ModelVersion,
    Run,
    RunAgentReport,
    RunInputLink,
    RunOperation,
    VibeInput,
)
from vibe_modeling.backend.model_sync import ModelSyncService
from vibe_modeling.backend.run_report import build_run_report
from vibe_modeling.backend.services.operations import (
    OperationContext,
    OperationDispatchHandle,
)
from vibe_modeling.backend.services.operations.vibe_iterate import (
    VibeIterate,
    VibeIterateParams,
)
from vibe_modeling.backend.services.orchestrator import Orchestrator

_MOD = "vibe_modeling.backend.services.operations.vibe_iterate"
CATALOG = "test_catalog"
BIZ = "acme"


# --------------------------------------------------------------------------
# helpers
# --------------------------------------------------------------------------


@pytest.fixture(autouse=True)
def _no_sleep(monkeypatch):
    monkeypatch.setattr(f"{_MOD}.time.sleep", lambda *_a, **_kw: None)


def _seed(engine, *, versions=(1,), selected=True, n_inputs=0, dry_run=False):
    """Business 'Acme' + completed ECM versions + a run (+ linked inputs)."""
    with Session(engine) as s:
        biz = Business(name="Acme")
        s.add(biz)
        s.commit()
        mv_ids = []
        for v in versions:
            mv = ModelVersion(
                business_id=biz.id, version=v, status="completed",
                scope="ecm", uc_catalog=CATALOG,
            )
            s.add(mv)
            s.commit()
            mv_ids.append(mv.id)
        run = Run(
            business_id=biz.id, intent="vibe-iterate", status="running",
            parameters_json=json.dumps({"dry_run": dry_run}),
        )
        s.add(run)
        s.commit()
        input_ids = []
        for i in range(n_inputs):
            vi = VibeInput(business_id=biz.id, text=f"i{i}", selected_for_run=selected)
            s.add(vi)
            s.commit()
            s.add(RunInputLink(run_id=run.id, input_id=vi.id))
            input_ids.append(vi.id)
        s.commit()
        return biz.id, mv_ids, run.id, input_ids


def _ctx(run_id, biz_id, parent_id, **params) -> OperationContext:
    base = {"vibe_instructions": "tighten meter_to_cash", "deployment_catalog": CATALOG}
    base.update(params)
    return OperationContext(
        run_id=run_id, operation_id="op-scope-1", business_id=biz_id,
        parent_version_id=parent_id, params=base,
        inherited_params={"cataloging_style": "One Catalog"},
    )


def _handle(parent_int: int) -> OperationDispatchHandle:
    return OperationDispatchHandle(
        databricks_run_id=99, vibe_session_id="sess-scope",
        extra={
            "deployment_catalog": CATALOG,
            "business_name": BIZ,
            "parent_version_int": parent_int,
        },
    )


def _success_ws(files: dict[int, dict], fail_first: Optional[dict[int, int]] = None):
    """ws whose Jobs API says SUCCESS and whose Volume serves ``files``
    (version -> model.json). ``fail_first[v]`` = number of downloads of
    that version that 404 before it becomes visible (Volume lag)."""
    ws = MagicMock()
    state = MagicMock()
    state.life_cycle_state.value = "TERMINATED"
    state.result_state.value = "SUCCESS"
    ws.jobs.get_run.return_value = MagicMock(state=state)

    by_path: dict[str, int] = {}
    for v in files:
        for p in model_json_volume_candidates(CATALOG, BIZ, v, "ecm"):
            by_path[p] = v
    remaining = dict(fail_first or {})
    calls: list[str] = []

    def _download(path):
        calls.append(path)
        v = by_path.get(path)
        if v is None:
            raise Exception(f"404 {path}")
        # Only the nested (first) candidate holds the file.
        if path != model_json_volume_candidates(CATALOG, BIZ, v, "ecm")[0]:
            raise Exception(f"404 {path}")
        if remaining.get(v, 0) > 0:
            remaining[v] -= 1
            raise Exception(f"404 (lag) {path}")
        resp = MagicMock()
        resp.contents.read.return_value = json.dumps(files[v]).encode()
        return resp

    ws.files.download.side_effect = _download
    ws._calls = calls
    return ws


def _terminal(engine, ws, ctx, parent_int):
    with patch.object(ModelSyncService, "sync_model", return_value=True):
        with Session(engine) as s:
            obs = VibeIterate().observe(_handle(parent_int), ctx, ws, s)
            s.commit()
    assert obs.is_terminal and obs.terminal_result is not None
    return obs, obs.terminal_result


def _observe(engine, ws, ctx, parent_int):
    _, result = _terminal(engine, ws, ctx, parent_int)
    assert result.succeeded, result.error
    return result


def _record_op(engine, run_id, result) -> None:
    """Persist the terminal op row the way the orchestrator runner does."""
    with Session(engine) as s:
        s.add(RunOperation(
            run_id=run_id, step_index=0, operation_name="vibe_iterate",
            params_json="{}", status="succeeded" if result.succeeded else "failed",
            output_version_id=result.output_version_id,
            rollback_state_json=json.dumps(result.rollback_state),
        ))
        s.commit()


def _finalize(engine, run_id):
    with Session(engine) as s:
        pt._finalize_run_inputs(run_id, s, success=True)


def _inputs(engine, ids):
    with Session(engine) as s:
        return {i: (s.get(VibeInput, i).consumed, s.get(VibeInput, i).selected_for_run)
                for i in ids}


def _report(engine, run_id) -> Optional[RunAgentReport]:
    with Session(engine) as s:
        report = s.get(RunAgentReport, run_id)
        if report is not None:
            s.expunge(report)
        return report


def _outcomes(engine, run_id) -> dict:
    """``{input_id: (outcome_status, outcome_reason, outcome_target)}``."""
    with Session(engine) as s:
        links = s.exec(select(RunInputLink).where(RunInputLink.run_id == run_id)).all()
        return {lk.input_id: (lk.outcome_status, lk.outcome_reason, lk.outcome_target)
                for lk in links}


def _model(**root) -> dict:
    doc = {"model": {"type": "business", "name": "acme", "domains": []}}
    doc.update(root)
    return doc


# --------------------------------------------------------------------------
# params + dispatch
# --------------------------------------------------------------------------


def test_params_defaults_preserve_unscoped_full_run():
    p = VibeIterateParams(vibe_instructions="x")
    assert p.vibe_scope == "all_domains"
    assert p.vibe_scope_domains == []
    assert p.dry_run is False


def test_params_reject_some_subdomains():
    with pytest.raises(Exception):
        VibeIterateParams(vibe_instructions="x", vibe_scope="some_subdomains")


def _dispatch_widgets(engine, **params) -> dict:
    biz_id, (parent_id,), run_id, _ = _seed(engine)
    ws = MagicMock()
    captured: dict = {}

    def _run_now(**kw):
        captured.update(kw.get("notebook_params") or {})
        m = MagicMock()
        m.response.run_id = 4242
        return m

    ws.jobs.run_now.side_effect = _run_now
    with Session(engine) as s:
        handle = VibeIterate().dispatch(_ctx(run_id, biz_id, parent_id, **params), ws, s)
    assert handle.dispatched_widgets == captured
    return captured


def test_dispatch_maps_scope_and_dry_run(engine):
    w = _dispatch_widgets(
        engine,
        vibe_scope="some_domains",
        vibe_scope_domains=["meter_to_cash", "billing"],
        dry_run=True,
        business_domains="seed_a, seed_b",
    )
    assert w["vibe_scope"] == "Some Domains"
    assert w["business_domains"] == "meter_to_cash, billing"
    assert w["run_type"] == "Dry Run"


def test_dispatch_unscoped_full_run_unchanged(engine):
    w = _dispatch_widgets(engine, business_domains="seed_a, seed_b")
    assert w["vibe_scope"] == "All Domains"
    assert w["run_type"] == "Full Run"
    # The seed list still flows through when the run is unscoped.
    assert w["business_domains"] == "seed_a, seed_b"


# --------------------------------------------------------------------------
# Dry Run finalize
# --------------------------------------------------------------------------


def test_dry_run_saves_draft_without_supersede_or_consume(engine):
    biz_id, (parent_id,), run_id, ids = _seed(engine, n_inputs=2, dry_run=True)
    outcomes = [{"item_id": i, "target": "x", "status": "applied", "reason": ""} for i in ids]
    ws = _success_ws({2: _model(input_outcomes=outcomes)})
    result = _observe(engine, ws, _ctx(run_id, biz_id, parent_id, dry_run=True), 1)

    with Session(engine) as s:
        new_mv = s.get(ModelVersion, result.output_version_id)
        assert new_mv.status == "draft"
        assert new_mv.dry_run is True
        assert new_mv.version == 2
        # Never deployed: deployment_status stays "draft" as for every iterate.
        assert new_mv.deployment_status == "draft"
        assert s.get(ModelVersion, parent_id).status == "completed"
    assert result.rollback_state["auto_superseded_ids"] == []
    assert "agent_outcomes" not in result.rollback_state
    # The outcomes are recorded for the report even though nothing is consumed.
    assert _outcomes(engine, run_id) == {i: ("applied", None, "x") for i in ids}

    _record_op(engine, run_id, result)
    _finalize(engine, run_id)
    # Even the "applied" items stay open; links are kept as the audit record.
    assert _inputs(engine, ids) == {i: (False, True) for i in ids}
    with Session(engine) as s:
        links = s.exec(select(RunInputLink).where(RunInputLink.run_id == run_id)).all()
        assert len(links) == 2


def test_dry_run_detected_from_the_output_version(engine):
    """A run whose parameters do not record dry_run is still a Dry Run when
    the version it produced is flagged ``dry_run``."""
    biz_id, (parent_id,), run_id, ids = _seed(engine, n_inputs=1)
    ws = _success_ws({2: _model(input_outcomes=[{"item_id": ids[0], "status": "applied"}])})
    result = _observe(engine, ws, _ctx(run_id, biz_id, parent_id, dry_run=True), 1)
    with Session(engine) as s:
        run = s.get(Run, run_id)
        run.parameters_json = "{}"
        s.add(run)
        s.commit()
    _record_op(engine, run_id, result)
    _finalize(engine, run_id)
    assert _inputs(engine, ids) == {ids[0]: (False, True)}


def test_unscoped_full_run_supersedes_and_completes(engine):
    biz_id, (parent_id,), run_id, ids = _seed(engine, n_inputs=2)
    ws = _success_ws({2: _model()})
    result = _observe(engine, ws, _ctx(run_id, biz_id, parent_id), 1)
    with Session(engine) as s:
        new_mv = s.get(ModelVersion, result.output_version_id)
        assert new_mv.status == "completed"
        assert new_mv.dry_run is False
        assert new_mv.version == 2
        assert s.get(ModelVersion, parent_id).status == "superseded"
    report = _report(engine, run_id)
    assert report.version_mismatch is False
    assert report.has_input_outcomes is False
    assert report.expected_version == 2 and report.fetched_version == 2
    assert _outcomes(engine, run_id) == {i: (None, None, None) for i in ids}

    _record_op(engine, run_id, result)
    _finalize(engine, run_id)
    # No input_outcomes key: nothing is marked done; inputs stay selected.
    assert _inputs(engine, ids) == {i: (False, True) for i in ids}


# --------------------------------------------------------------------------
# D13 fetch rules and A2r (a mismatch fails the op)
# --------------------------------------------------------------------------


def test_lag_expected_version_retried_before_draft_fallback(engine):
    """After a Dry Run draft at v2, the Full Run writes v3. v3 404s on the
    first attempts while v2 (the draft) is readable: the fetch must keep
    retrying v3 and never read v2."""
    biz_id, (v1_id,), run_id, ids = _seed(engine, n_inputs=1)
    with Session(engine) as s:
        s.add(ModelVersion(business_id=biz_id, version=2, status="draft",
                           scope="ecm", uc_catalog=CATALOG))
        s.commit()
    applied = [{"item_id": ids[0], "target": "x", "status": "applied", "reason": ""}]
    draft_doc = _model(input_outcomes=[{"item_id": ids[0], "status": "failed"}])
    full_doc = _model(input_outcomes=applied, lineage={"output_version": "3"})
    ws = _success_ws({2: draft_doc, 3: full_doc}, fail_first={3: 3})
    # parent_version_int=2 mirrors the worst case: parent+1 == the expected
    # folder, parent == the draft folder.
    result = _observe(engine, ws, _ctx(run_id, biz_id, v1_id), 2)

    draft_paths = set(model_json_volume_candidates(CATALOG, BIZ, 2, "ecm"))
    assert not draft_paths & set(ws._calls), "the draft's folder must not be read"
    report = _report(engine, run_id)
    assert report.version_mismatch is False
    assert report.fetched_version == 3
    with Session(engine) as s:
        assert s.get(ModelVersion, result.output_version_id).version == 3

    _record_op(engine, run_id, result)
    _finalize(engine, run_id)
    assert _inputs(engine, ids) == {ids[0]: (True, False)}
    with Session(engine) as s:
        assert s.get(VibeInput, ids[0]).consumed_by_run_id == run_id


def _version_count(engine, biz_id) -> int:
    with Session(engine) as s:
        return len(s.exec(select(ModelVersion).where(ModelVersion.business_id == biz_id)).all())


def test_lag_never_resolves_fails_the_op_without_a_version(engine):
    """v3 never becomes visible; the v2 draft is readable. The last-resort
    fallback reads it and flags version_mismatch: the op fails with a clear
    error, no version row is created and nothing is consumed (not even items
    the draft reported as applied)."""
    biz_id, (v1_id,), run_id, ids = _seed(engine, n_inputs=2)
    with Session(engine) as s:
        s.add(ModelVersion(business_id=biz_id, version=2, status="draft",
                           scope="ecm", uc_catalog=CATALOG))
        s.commit()
    before = _version_count(engine, biz_id)
    applied = [{"item_id": i, "status": "applied"} for i in ids]
    ws = _success_ws({2: _model(input_outcomes=applied)})
    sync = MagicMock(return_value=True)
    with patch.object(ModelSyncService, "sync_model", sync):
        with Session(engine) as s:
            obs = VibeIterate().observe(_handle(2), _ctx(run_id, biz_id, v1_id), ws, s)
            s.commit()

    expected_paths = model_json_volume_candidates(CATALOG, BIZ, 3, "ecm")
    # Every attempt (5) tried both expected candidates before the fallback.
    assert ws._calls[:10] == expected_paths * 5
    result = obs.terminal_result
    assert obs.is_terminal and result.succeeded is False
    assert result.output_version_id is None and result.rollback_state == {}
    assert "expected version v3 (ecm)" in result.error
    assert "the file is v2" in result.error
    assert "Failed" in obs.progress_message
    assert _version_count(engine, biz_id) == before
    sync.assert_not_called()
    report = _report(engine, run_id)
    assert report.version_mismatch is True
    assert report.expected_version == 3 and report.fetched_version == 2
    # The wrong version's outcomes are not recorded.
    assert _outcomes(engine, run_id) == {i: (None, None, None) for i in ids}
    assert _inputs(engine, ids) == {i: (False, True) for i in ids}


def test_lineage_output_version_mismatch_fails_the_op(engine):
    biz_id, (parent_id,), run_id, ids = _seed(engine, n_inputs=1)
    before = _version_count(engine, biz_id)
    doc = _model(
        input_outcomes=[{"item_id": ids[0], "status": "applied"}],
        lineage={"output_version": "v5"},
    )
    ws = _success_ws({2: doc})
    _, result = _terminal(engine, ws, _ctx(run_id, biz_id, parent_id), 1)
    assert result.succeeded is False
    assert "expected version v2 (ecm)" in result.error
    assert "the file is v5" in result.error
    assert _version_count(engine, biz_id) == before
    report = _report(engine, run_id)
    assert report.version_mismatch is True
    assert (report.expected_version, report.fetched_version) == (2, 5)
    assert _outcomes(engine, run_id) == {ids[0]: (None, None, None)}


def test_retry_after_mismatch_replaces_the_report(engine):
    """A retry reuses the run: the successful attempt rewrites its report."""
    biz_id, (parent_id,), run_id, ids = _seed(engine, n_inputs=1)
    bad = _model(input_outcomes=[{"item_id": ids[0], "status": "applied"}],
                 lineage={"output_version": "v5"})
    _terminal(engine, _success_ws({2: bad}), _ctx(run_id, biz_id, parent_id), 1)
    assert _report(engine, run_id).version_mismatch is True

    good = _model(input_outcomes=[{"item_id": ids[0], "status": "applied"}])
    result = _observe(engine, _success_ws({2: good}), _ctx(run_id, biz_id, parent_id), 1)
    report = _report(engine, run_id)
    assert report.version_mismatch is False and report.has_input_outcomes is True
    assert _outcomes(engine, run_id) == {ids[0]: ("applied", None, None)}
    _record_op(engine, run_id, result)
    _finalize(engine, run_id)
    assert _inputs(engine, ids) == {ids[0]: (True, False)}


def _job_failed_ws():
    ws = MagicMock()
    state = MagicMock()
    state.life_cycle_state.value = "TERMINATED"
    state.result_state.value = "FAILED"
    state.state_message = "notebook raised"
    ws.jobs.get_run.return_value = MagicMock(state=state)
    return ws


def test_retry_clears_the_previous_attempt_report_before_a_job_failure(engine):
    """Attempt 1 fails on a mismatch; the retry's dispatch clears that report,
    so a job-level failure of attempt 2 shows no stale mismatch."""
    biz_id, (parent_id,), run_id, ids = _seed(engine, n_inputs=1)
    ctx = _ctx(run_id, biz_id, parent_id)
    bad = _model(input_outcomes=[{"item_id": ids[0], "status": "applied"}],
                 lineage={"output_version": "v5"})
    _terminal(engine, _success_ws({2: bad}), ctx, 1)
    assert _report(engine, run_id).version_mismatch is True

    ws = MagicMock()
    ws.jobs.run_now.return_value.response.run_id = 4243
    with Session(engine) as s:
        VibeIterate().dispatch(ctx, ws, s)
        s.commit()
    assert _report(engine, run_id) is None

    _, result = _terminal(engine, _job_failed_ws(), ctx, 1)
    assert result.succeeded is False
    with Session(engine) as s:
        run = s.get(Run, run_id)
        run.status = "failed"
        s.add(run)
        s.commit()
        rep = build_run_report(s, run)
    assert rep.has_agent_report is False and rep.version_mismatch is False
    assert rep.consume_note is None


@pytest.mark.parametrize("label", ["5.0", "ecm_v2", 2.0])
def test_unparseable_lineage_output_version_warns(engine, caplog, label):
    """An output version that is not a version label skips the check, loudly."""
    biz_id, (parent_id,), run_id, _ = _seed(engine)
    doc = _model(input_outcomes=[], lineage={"output_version": label})
    with caplog.at_level("WARNING", logger=f"{_MOD}"):
        _observe(engine, _success_ws({2: doc}), _ctx(run_id, biz_id, parent_id), 1)
    assert any("is not a version label" in r.getMessage() for r in caplog.records)
    assert _report(engine, run_id).version_mismatch is False


def test_runner_keeps_the_mismatch_report_through_its_rollback(engine):
    """The failing vibe op returns an empty rollback_state, so the runner's
    failure rollback skips it and the mismatch report row survives the tick."""
    biz_id, (parent_id,), run_id, ids = _seed(engine, n_inputs=1)
    with Session(engine) as s:
        s.add(RunOperation(
            run_id=run_id, step_index=0, operation_name="vibe_iterate",
            params_json=json.dumps({"vibe_instructions": "tighten",
                                    "deployment_catalog": CATALOG}),
            parent_version_id=parent_id, status="running", databricks_run_id=99,
            vibe_session_id="sess-scope",
            rollback_state_json=json.dumps(_handle(1).extra),
        ))
        s.commit()
    bad = _model(input_outcomes=[{"item_id": ids[0], "status": "applied"}],
                 lineage={"output_version": "5"})
    orch = Orchestrator(_success_ws({2: bad}), lambda: Session(engine))
    with patch.object(ModelSyncService, "sync_model", return_value=True):
        with Session(engine) as s:
            orch.advance(s.get(Run, run_id), s)
            s.commit()
    with Session(engine) as s:
        run = s.get(Run, run_id)
        op = s.exec(select(RunOperation).where(RunOperation.run_id == run_id)).one()
        assert run.status == "failed" and op.status == "failed"
        assert op.rollback_state_json == "{}"
        assert "not the expected version v2" in run.error_message
        rep = build_run_report(s, run)
    report = _report(engine, run_id)
    assert report is not None and report.version_mismatch is True
    assert (report.expected_version, report.fetched_version) == (2, 5)
    assert rep.consume_note == "version_mismatch"


# --------------------------------------------------------------------------
# outcome-driven consume
# --------------------------------------------------------------------------


def test_outcome_driven_consume_only_applied(engine):
    biz_id, (parent_id,), run_id, ids = _seed(engine, n_inputs=6)
    statuses = ["applied", "partial", "failed", "scope_rejected", "unmapped"]
    outcomes = [
        {"item_id": i, "target": "meter_to_cash", "status": st, "reason": "r",
         "vreq_ids": ["VREQ-1"]}
        for i, st in zip(ids, statuses)
    ]  # ids[5] has no entry at all
    outcomes.append({"item_id": "not-sent", "status": "applied"})
    doc = _model(
        input_outcomes=outcomes,
        _vibe_scope={"mode": "domains", "entries": ["meter_to_cash"], "huge": "x" * 50},
        lineage={"output_version": "2", "base_version": "1", "head_at_write": "v1_ecm",
                 "stale": False, "intervening_versions": []},
    )
    ws = _success_ws({2: doc})
    result = _observe(
        engine, ws,
        _ctx(run_id, biz_id, parent_id, vibe_scope="some_domains",
             vibe_scope_domains=["meter_to_cash"]),
        1,
    )
    report = _report(engine, run_id)
    assert report.has_input_outcomes is True and report.version_mismatch is False
    assert (report.lineage_base_version, report.lineage_head_at_write,
            report.lineage_stale) == (1, 1, False)
    assert report.unmatched_outcome_count == 1
    got = _outcomes(engine, run_id)
    for i, st in zip(ids, statuses):
        assert got[i] == (st, "r", "meter_to_cash"), i
    assert got[ids[5]] == ("not_reported", None, None)

    _record_op(engine, run_id, result)
    _finalize(engine, run_id)
    state = _inputs(engine, ids)
    assert state[ids[0]] == (True, False)
    for i in ids[1:]:
        assert state[i] == (False, True), i


def test_outcome_without_status_is_not_reported(engine):
    """An entry for the input with no status is stored as not_reported, so NULL
    keeps meaning "no outcomes reported"."""
    biz_id, (parent_id,), run_id, ids = _seed(engine, n_inputs=2)
    doc = _model(input_outcomes=[{"item_id": ids[0], "reason": "?"},
                                 {"item_id": ids[1], "status": "  "}])
    result = _observe(engine, _success_ws({2: doc}), _ctx(run_id, biz_id, parent_id), 1)
    assert _outcomes(engine, run_id) == {ids[0]: ("not_reported", "?", None),
                                         ids[1]: ("not_reported", None, None)}
    _record_op(engine, run_id, result)
    _finalize(engine, run_id)
    assert _inputs(engine, ids) == {i: (False, True) for i in ids}


def test_outcome_reason_capped_and_status_normalized(engine):
    biz_id, (parent_id,), run_id, ids = _seed(engine, n_inputs=1)
    doc = _model(input_outcomes=[{"item_id": f" {ids[0]} ", "status": " APPLIED ",
                                  "reason": "x" * 900, "target": ""}])
    _observe(engine, _success_ws({2: doc}), _ctx(run_id, biz_id, parent_id), 1)
    status, reason, target = _outcomes(engine, run_id)[ids[0]]
    assert status == "applied" and len(reason) == 500 and target is None


def test_outcomes_in_the_model_envelope_are_not_read(engine):
    """The agent writes ``input_outcomes`` at the model.json root
    (nb 100448-100451); a copy inside ``model`` is not the agent's report."""
    biz_id, (parent_id,), run_id, ids = _seed(engine, n_inputs=2)
    doc = {"model": {
        "type": "business", "domains": [],
        "input_outcomes": [{"item_id": ids[0], "status": "applied"},
                           {"item_id": ids[1], "status": "partial"}],
    }}
    ws = _success_ws({2: doc})
    result = _observe(engine, ws, _ctx(run_id, biz_id, parent_id), 1)
    assert _report(engine, run_id).has_input_outcomes is False

    _record_op(engine, run_id, result)
    _finalize(engine, run_id)
    assert _inputs(engine, ids) == {ids[0]: (False, True), ids[1]: (False, True)}


def test_empty_input_outcomes_list_consumes_nothing(engine):
    """The key is present but lists no item (a VOV without markers): nothing
    is applied, so nothing is consumed — distinct from a missing key."""
    biz_id, (parent_id,), run_id, ids = _seed(engine, n_inputs=1)
    ws = _success_ws({2: _model(input_outcomes=[])})
    result = _observe(engine, ws, _ctx(run_id, biz_id, parent_id), 1)
    assert _report(engine, run_id).has_input_outcomes is True
    assert _outcomes(engine, run_id) == {ids[0]: ("not_reported", None, None)}
    _record_op(engine, run_id, result)
    _finalize(engine, run_id)
    assert _inputs(engine, ids) == {ids[0]: (False, True)}


@pytest.mark.parametrize("bad", ["oops", {"a": 1}, None])
def test_malformed_input_outcomes_consumes_nothing(engine, bad):
    """A present but non-list ``input_outcomes`` (null included) fails closed:
    nothing is recorded or consumed."""
    biz_id, (parent_id,), run_id, ids = _seed(engine, n_inputs=1)
    ws = _success_ws({2: _model(input_outcomes=bad)})
    result = _observe(engine, ws, _ctx(run_id, biz_id, parent_id), 1)
    report = _report(engine, run_id)
    assert report.has_input_outcomes is True
    assert report.outcomes_malformed is True
    assert _outcomes(engine, run_id) == {ids[0]: (None, None, None)}
    _record_op(engine, run_id, result)
    _finalize(engine, run_id)
    assert _inputs(engine, ids) == {ids[0]: (False, True)}


def test_missing_input_outcomes_key_consumes_nothing(engine, caplog):
    """A successful run whose model.json has no ``input_outcomes`` key marks
    nothing done: inputs stay open and selected, links stay as the audit
    record, and the tracker logs it."""
    biz_id, (parent_id,), run_id, ids = _seed(engine, n_inputs=2)
    ws = _success_ws({2: _model(_vibe_scope={"mode": "domains"})})
    result = _observe(engine, ws, _ctx(run_id, biz_id, parent_id), 1)
    report = _report(engine, run_id)
    assert report.has_input_outcomes is False
    assert report.version_mismatch is False

    _record_op(engine, run_id, result)
    with caplog.at_level("WARNING", logger=pt.logger.name):
        _finalize(engine, run_id)
    assert _inputs(engine, ids) == {i: (False, True) for i in ids}
    with Session(engine) as s:
        links = s.exec(select(RunInputLink).where(RunInputLink.run_id == run_id)).all()
        assert sorted(lk.input_id for lk in links) == sorted(ids)
    assert any("reported no input_outcomes" in r.getMessage() for r in caplog.records)


def test_no_agent_report_consumes_nothing(engine, caplog):
    """Runs without a vibe_iterate op, or finished before reports existed,
    have no report rows, so nothing is consumed."""
    _, _, run_id, ids = _seed(engine, n_inputs=2)
    with caplog.at_level("WARNING", logger=pt.logger.name):
        _finalize(engine, run_id)
    assert _inputs(engine, ids) == {i: (False, True) for i in ids}
    assert any("recorded no agent report" in r.getMessage() for r in caplog.records)


def test_already_consumed_input_keeps_its_first_run(engine):
    biz_id, (parent_id,), run_id, ids = _seed(engine, n_inputs=1)
    with Session(engine) as s:
        other = Run(business_id=biz_id, intent="vibe-iterate", status="completed")
        s.add(other)
        s.commit()
        vi = s.get(VibeInput, ids[0])
        vi.consumed, vi.consumed_by_run_id = True, other.id
        s.add(vi)
        s.commit()
        other_id = other.id
    doc = _model(input_outcomes=[{"item_id": ids[0], "status": "applied"}])
    result = _observe(engine, _success_ws({2: doc}), _ctx(run_id, biz_id, parent_id), 1)
    _record_op(engine, run_id, result)
    _finalize(engine, run_id)
    with Session(engine) as s:
        vi = s.get(VibeInput, ids[0])
        assert vi.consumed_by_run_id == other_id
        assert vi.selected_for_run is False


def test_rollback_clears_the_report(engine):
    biz_id, (parent_id,), run_id, ids = _seed(engine, n_inputs=1)
    doc = _model(input_outcomes=[{"item_id": ids[0], "status": "applied"}])
    ctx = _ctx(run_id, biz_id, parent_id)
    result = _observe(engine, _success_ws({2: doc}), ctx, 1)
    with patch.object(ModelSyncService, "clear_version_data"):
        with Session(engine) as s:
            VibeIterate().rollback(ctx, result.rollback_state, MagicMock(), s)
            s.commit()
    assert _report(engine, run_id) is None
    assert _outcomes(engine, run_id) == {ids[0]: (None, None, None)}


def test_sync_failure_writes_no_report(engine):
    """The report is written inside the sync savepoint: a version that did not
    sync records no outcomes and consumes nothing."""
    biz_id, (parent_id,), run_id, ids = _seed(engine, n_inputs=1)
    doc = _model(input_outcomes=[{"item_id": ids[0], "status": "applied"}])
    with patch.object(ModelSyncService, "sync_model", return_value=False):
        with Session(engine) as s:
            obs = VibeIterate().observe(
                _handle(1), _ctx(run_id, biz_id, parent_id), _success_ws({2: doc}), s,
            )
            s.commit()
    assert obs.terminal_result.succeeded
    with Session(engine) as s:
        assert s.get(ModelVersion, obs.terminal_result.output_version_id).sync_state == "sync_empty"
    assert _report(engine, run_id) is None
    assert _outcomes(engine, run_id) == {ids[0]: (None, None, None)}


def test_failure_path_unchanged(engine):
    _, _, run_id, ids = _seed(engine, n_inputs=1)
    with Session(engine) as s:
        pt._finalize_run_inputs(run_id, s, success=False)
    with Session(engine) as s:
        assert s.exec(select(RunInputLink).where(RunInputLink.run_id == run_id)).all() == []
    assert _inputs(engine, ids) == {ids[0]: (False, True)}
