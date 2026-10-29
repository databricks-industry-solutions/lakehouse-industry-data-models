"""Independent adversarial tests for the single-domain vibe scope launch.

Written by the pipeline TESTER (not the developers) against design
docs/superpowers/specs/2026-10-18-single-domain-vibe-scope-design.md
§5-§10 and Revision 1. Everything goes through the real HTTP API
(``POST /runs``, ``POST /runs/validate``, ``POST /vibe-inputs/compile``,
``POST /runs/{id}/retry``) with the conftest TestClient, then drives the
real ``VibeIterate.observe`` + ``progress_tracker._finalize_run_inputs``
terminal path to check consume semantics end to end.
"""

from __future__ import annotations

import json
import re
from types import SimpleNamespace
from typing import Optional
from unittest.mock import MagicMock, patch

import pytest
from sqlmodel import Session, select

from vibe_modeling.backend import progress_tracker as pt
from vibe_modeling.backend.core._paths import model_json_volume_candidates
from vibe_modeling.backend.core._names import agent_business_segment
from vibe_modeling.backend.db_models import (
    AgentConfig,
    Business,
    Domain,
    ModelVersion,
    Product,
    Run,
    RunAgentReport,
    RunInputLink,
    RunOperation,
    VibeInput,
    VibeInputContextLink,
)
from vibe_modeling.backend.model_sync import ModelSyncService
from vibe_modeling.backend.routes import _helpers as route_helpers
from vibe_modeling.backend.services.operations import (
    OperationContext,
    OperationDispatchHandle,
)
from vibe_modeling.backend.services.operations import _registry as _registry_module
from vibe_modeling.backend.services.operations.vibe_iterate import VibeIterate

# The agent's own K1 parser (5.3.3 ``_VIBE_INPUT_MARKER_RE``), design §3.
K1_RE = re.compile(r"<!--\s*vi:([A-Za-z0-9_.:-]+)\s+target=(.*?)\s*-->")
_VI_MOD = "vibe_modeling.backend.services.operations.vibe_iterate"
CATALOG = "test_metamodel_catalog"
BIZ_NAME = "Scope Co"
DOMAINS = ("meter_to_cash", "customer_service", "asset_management")


# --------------------------------------------------------------------------- #
# fixtures / helpers
# --------------------------------------------------------------------------- #


@pytest.fixture(autouse=True)
def _registry():
    _registry_module.reset_for_tests()
    _registry_module.register(VibeIterate())
    yield
    # Restore the production registry so later test files (which resolve
    # primitives such as ``vibe_iterate`` by name) never see an empty one.
    _registry_module.reset_for_tests()
    _registry_module.restore_production_for_tests()


@pytest.fixture(autouse=True)
def _no_sleep(monkeypatch):
    monkeypatch.setattr(f"{_VI_MOD}.time.sleep", lambda *_a, **_kw: None)


@pytest.fixture
def agent(monkeypatch, mock_ws):
    """Workspace stubs so a create passes every non-scope preflight, plus a
    5.3.3 agent marker. Returns the captured notebook_params of each run_now."""
    mock_ws.schemas.list.side_effect = lambda *a, **kw: iter(
        [SimpleNamespace(name="_metamodel"), SimpleNamespace(name="default")]
    )
    from _sql_fakes import response

    mock_ws.statement_execution.execute_statement.return_value = response([["1"]])
    sent: list[dict] = []
    counter = {"n": 5000}

    def _run_now(**kw):
        sent.append(dict(kw.get("notebook_params") or {}))
        counter["n"] += 1
        m = MagicMock()
        m.run_id = counter["n"]
        m.response.run_id = counter["n"]
        return m

    mock_ws.jobs.run_now.side_effect = _run_now
    identity = {"marker": "v5.3.3"}
    monkeypatch.setattr(
        route_helpers, "_detect_notebook_identity",
        lambda ws, path: ("v0.8.0", identity["marker"]),
    )
    return SimpleNamespace(sent=sent, identity=identity)


def _seed(engine, *, versions=((6, "completed"),), domains=DOMAINS, name=BIZ_NAME) -> dict:
    """Business + AgentConfig + ECM versions. Every version carries ``domains``
    (with one product per domain). The highest version gets the inputs."""
    with Session(engine) as s:
        if s.exec(select(AgentConfig)).first() is None:
            s.add(AgentConfig(
                notebook_path="/Workspace/agent.ipynb",
                deployment_catalog=CATALOG,
                warehouse_id="wh-1",
                job_id=7,
                job_name="vibe_job",
            ))
        biz = Business(name=name, description="Utility company")
        s.add(biz)
        s.flush()
        ids: dict = {"bid": biz.id, "domain": {}, "product": {}}
        for version, status in versions:
            mv = ModelVersion(
                business_id=biz.id, version=version, scope="ecm", status=status,
                uc_catalog=CATALOG,
            )
            s.add(mv)
            s.flush()
            ids[version] = mv.id
            for name in domains:
                d = Domain(version_id=mv.id, name=name)
                s.add(d)
                s.flush()
                p = Product(version_id=mv.id, domain_id=d.id, name=f"{name}_p")
                s.add(p)
                s.flush()
                ids["domain"][(version, name)] = d.id
                ids["product"][(version, name)] = p.id
        s.commit()
        return ids


def _feedback(engine, ids, version, domain, text, *, selected=True, product=False) -> str:
    with Session(engine) as s:
        vi = VibeInput(business_id=ids["bid"], text=text, origin="user",
                       priority="high", author="a@x.com", selected_for_run=selected)
        s.add(vi)
        s.flush()
        kw = {}
        if domain is not None:
            if product:
                kw["product_id"] = ids["product"][(version, domain)]
            else:
                kw["domain_id"] = ids["domain"][(version, domain)]
        s.add(VibeInputContextLink(input_id=vi.id, version_id=ids[version], **kw))
        s.commit()
        return vi.id


def _body(version_id, **kw) -> dict:
    body = {"intent": "vibe-iterate", "version_id": version_id}
    body.update(kw)
    return body


def _scoped(version_id, domains=("meter_to_cash",), **kw) -> dict:
    return _body(version_id, vibe_scope="some_domains",
                 vibe_scope_domains=list(domains), **kw)


def _create(client, ids, body):
    return client.post(f"/api/businesses/{ids['bid']}/runs", json=body)


def _validate(client, ids, body):
    return client.post(f"/api/businesses/{ids['bid']}/runs/validate", json=body)


def _links(engine, run_id) -> set[str]:
    with Session(engine) as s:
        return {lk.input_id for lk in s.exec(
            select(RunInputLink).where(RunInputLink.run_id == run_id)
        ).all()}


def _state(engine, iid) -> tuple[bool, bool]:
    with Session(engine) as s:
        vi = s.get(VibeInput, iid)
        return vi.consumed, vi.selected_for_run


def _run(engine, run_id) -> Run:
    with Session(engine) as s:
        return s.get(Run, run_id)


def _op(engine, run_id) -> RunOperation:
    with Session(engine) as s:
        return s.exec(
            select(RunOperation).where(RunOperation.run_id == run_id)
        ).first()


def _success_ws(files: dict[int, dict], fail_first: Optional[dict[int, int]] = None):
    """Jobs API SUCCESS; the Volume serves ``files`` (version -> model.json)."""
    ws = MagicMock()
    state = MagicMock()
    state.life_cycle_state.value = "TERMINATED"
    state.result_state.value = "SUCCESS"
    ws.jobs.get_run.return_value = MagicMock(state=state)
    seg = agent_business_segment(BIZ_NAME)
    by_path = {}
    for v in files:
        by_path[model_json_volume_candidates(CATALOG, seg, v, "ecm")[0]] = v
    remaining = dict(fail_first or {})

    def _download(path):
        v = by_path.get(path)
        if v is None:
            raise Exception(f"404 {path}")
        if remaining.get(v, 0) > 0:
            remaining[v] -= 1
            raise Exception(f"404 (lag) {path}")
        r = MagicMock()
        r.contents.read.return_value = json.dumps(files[v]).encode()
        return r

    ws.files.download.side_effect = _download
    return ws


def _complete(engine, run_id, ws, parent_int):
    """Drive the run's real vibe_iterate op to success the way the runner
    does: observe -> persist the terminal op state -> finalize inputs."""
    op = _op(engine, run_id)
    run = _run(engine, run_id)
    params = json.loads(op.params_json or "{}")
    ctx = OperationContext(
        run_id=run_id, operation_id=op.id, business_id=run.business_id,
        parent_version_id=op.parent_version_id, params=params,
        inherited_params={"cataloging_style": "One Catalog"},
    )
    handle = OperationDispatchHandle(
        databricks_run_id=1, vibe_session_id="sess",
        extra={"deployment_catalog": CATALOG,
               "business_name": agent_business_segment(BIZ_NAME),
               "parent_version_int": parent_int},
    )
    with patch.object(ModelSyncService, "sync_model", return_value=True):
        with Session(engine) as s:
            obs = VibeIterate().observe(handle, ctx, ws, s)
            s.commit()
    assert obs.is_terminal and obs.terminal_result.succeeded, obs.terminal_result
    result = obs.terminal_result
    with Session(engine) as s:
        row = s.get(RunOperation, op.id)
        row.status = "succeeded"
        row.rollback_state_json = json.dumps(result.rollback_state)
        s.add(row)
        s.commit()
        pt._finalize_run_inputs(run_id, s, success=True)
    return result


def _model(**root) -> dict:
    doc = {"model": {"type": "business", "name": "scope_co", "domains": []}}
    doc.update(root)
    return doc


def _outcome(iid, status):
    return {"item_id": iid, "target": "meter_to_cash", "status": status, "reason": ""}



def _fail_run(engine, run_id):
    """Mark a run failed the way the tracker does (links deleted, re-pool)."""
    with Session(engine) as s:
        run = s.get(Run, run_id)
        run.status = "failed"
        s.add(run)
        for op in s.exec(select(RunOperation).where(RunOperation.run_id == run_id)).all():
            op.status = "failed"
            s.add(op)
        s.commit()
        pt._finalize_run_inputs(run_id, s, success=False)


# --------------------------------------------------------------------------- #
# 1. Validation: create 422 and validate share the exact message
# --------------------------------------------------------------------------- #


def _case_bodies(ids):
    return {
        "unknown_domain": (_scoped(ids[6], ["meter2cash"]), "vibe_scope_domains",
                           "Did you mean: meter_to_cash?"),
        "some_subdomains": (_body(ids[6], vibe_scope="some_subdomains",
                                  vibe_scope_domains=["meter_to_cash"]),
                            "vibe_scope", "Some Subdomains is not supported yet"),
        "empty_list": (_scoped(ids[6], []), "vibe_scope_domains", "Pick at least one domain"),
        "whitespace_list": (_scoped(ids[6], ["  ", ""]), "vibe_scope_domains",
                            "Pick at least one domain"),
        "dotted": (_scoped(ids[6], ["meter_to_cash.billing"]), "vibe_scope_domains",
                   "'meter_to_cash.billing' is not a domain name"),
        "domains_with_all": (_body(ids[6], vibe_scope_domains=["meter_to_cash"]),
                             "vibe_scope_domains", "only used with Some domains"),
        "behind_head": (_scoped(ids[5]), "vibe_scope_base", "v5 is behind v6"),
        "business_domains_too": (_scoped(ids[6], business_domains="billing"),
                                 "vibe_scope_domains", "can't both be set"),
    }


@pytest.mark.parametrize("case", [
    "unknown_domain", "some_subdomains", "empty_list", "whitespace_list", "dotted",
    "domains_with_all", "behind_head", "business_domains_too",
])
def test_scope_blocker_create_422_matches_validate(client, engine, agent, case):
    ids = _seed(engine, versions=((5, "completed"), (6, "completed")))
    body, path, needle = _case_bodies(ids)[case]
    body.setdefault("vibe_instructions", "tighten reads")
    v = _validate(client, ids, body)
    assert v.status_code == 200, v.text
    msgs = [b["message"] for b in v.json()["blockers"] if b["field_path"] == path]
    assert msgs and needle in msgs[0], v.json()["blockers"]
    c = _create(client, ids, body)
    assert c.status_code == 422, c.text
    assert c.json()["detail"] == msgs[0]
    assert agent.sent == []  # nothing dispatched


@pytest.mark.parametrize("intent", ["install", "uninstall", "new-base-model", "vibe-new-ecm-mvm"])
@pytest.mark.parametrize("extra", [
    {"vibe_scope": "some_domains", "vibe_scope_domains": ["meter_to_cash"]},
    {"dry_run": True},
])
def test_scope_or_dry_run_on_other_intent_is_refused(client, engine, agent, intent, extra):
    """Whatever other blocker the intent trips, the request must not launch,
    and validate must name the scope/dry_run field."""
    ids = _seed(engine)
    body = _body(ids[6], **extra)
    body["intent"] = intent
    v = _validate(client, ids, body)
    assert v.status_code == 200, v.text
    paths = {b["field_path"] for b in v.json()["blockers"]}
    assert paths & {"vibe_scope", "dry_run"}, v.json()["blockers"]
    c = _create(client, ids, body)
    assert c.status_code in (400, 409, 422), c.text
    assert agent.sent == []


def test_scope_with_next_vibe_ids_is_refused(client, engine, agent):
    ids = _seed(engine)
    c = _create(client, ids, _scoped(ids[6], next_vibe_ids=["nv-1"], vibe_instructions="x"))
    assert c.status_code == 422, c.text
    assert "Vibe iteration runs only" in c.json()["detail"]
    assert agent.sent == []


def test_dry_run_draft_base_is_refused(client, engine, agent):
    ids = _seed(engine, versions=((6, "completed"), (7, "draft")))
    body = _scoped(ids[7], vibe_instructions="tighten reads")
    v = _validate(client, ids, body)
    msgs = [b["message"] for b in v.json()["blockers"] if b["field_path"] == "vibe_scope_base"]
    assert msgs and "v7 is a Dry Run draft; the latest is v6" in msgs[0], v.json()
    c = _create(client, ids, body)
    assert c.status_code == 422, c.text
    assert c.json()["detail"] == msgs[0]
    assert agent.sent == []


def test_normalized_typo_is_accepted_and_stored_canonical(client, engine, agent):
    ids = _seed(engine)
    c = _create(client, ids, _scoped(ids[6], ["Meter To Cash"], vibe_instructions="x"))
    assert c.status_code == 200, c.text
    params = json.loads(c.json()["parameters_json"])
    assert params["vibe_scope_domains"] == ["meter_to_cash"]
    assert agent.sent[-1]["business_domains"] == "meter_to_cash"
    assert agent.sent[-1]["vibe_scope"] == "Some Domains"
    op_params = json.loads(_op(engine, c.json()["id"]).params_json)
    assert op_params["vibe_scope_domains"] == ["meter_to_cash"]


def test_duplicate_and_mixed_case_scope_entries_collapse(client, engine, agent):
    ids = _seed(engine)
    c = _create(client, ids, _scoped(
        ids[6], ["METER_TO_CASH", "meter to cash", "Meter-To-Cash", "customer service"],
        vibe_instructions="x",
    ))
    assert c.status_code == 200, c.text
    assert agent.sent[-1]["business_domains"] == "meter_to_cash, customer_service"


# --------------------------------------------------------------------------- #
# 2. Contract: unscoped create unchanged
# --------------------------------------------------------------------------- #

# The widget keys an unscoped vibe-iterate sent before D3, less the retired
# ``generate_samples`` (X18). The test adds the two D3 widgets and the runtime
# budget (RB).
_PRE_CHANGE_KEYS = {
    "operation", "business_name", "business_description", "context_file",
    "deployment_catalog", "data_model_scopes", "model_vibes",
    "vibe_session_id", "industry_alignment", "business_domains", "org_divisions",
    "cataloging_style", "catalog_prefix", "catalog_suffix", "naming_convention",
    "primary_key_suffix", "schema_prefix", "schema_suffix", "tag_prefix",
    "tag_suffix", "table_id_type", "boolean_format", "date_format",
    "timestamp_format", "classification_levels", "housekeeping_columns",
    "history_tracking_columns", "model_version",
}


def test_unscoped_create_unchanged(client, engine, agent):
    ids = _seed(engine)
    agent.identity["marker"] = "v4.9.9"  # old agent: unscoped runs are never gated
    body = _body(ids[6], vibe_instructions="Free text, no inputs",
                 business_domains="seed_a, seed_b")
    c = _create(client, ids, body)
    assert c.status_code == 200, c.text
    w = agent.sent[-1]
    assert set(w) == _PRE_CHANGE_KEYS | {"vibe_scope", "run_type", "runtime_budget_seconds"}
    assert w["runtime_budget_seconds"] == "21600"  # the Settings default, 6 h
    assert w["vibe_scope"] == "All Domains" and w["run_type"] == "Full Run"
    assert w["business_domains"] == "seed_a, seed_b"
    assert w["model_vibes"] == "Free text, no inputs"  # free text untouched
    assert w["model_version"] == "6"
    # Same RunOut shape as a scoped create.
    agent.identity["marker"] = "v5.3.3"
    ids2 = _seed(engine, name="Other Co")
    s = _create(client, ids2, _scoped(ids2[6], vibe_instructions="x"))
    assert s.status_code == 200, s.text
    assert set(c.json()) == set(s.json())


# --------------------------------------------------------------------------- #
# 3. Feedback selection under a scope
# --------------------------------------------------------------------------- #


def _three(engine, ids):
    return (
        _feedback(engine, ids, 6, "meter_to_cash", "tighten meter reads"),
        _feedback(engine, ids, 6, "customer_service", "add case sla", product=True),
        _feedback(engine, ids, 6, "asset_management", "asset hierarchy"),
    )


def test_scoped_create_sends_links_and_consumes_only_in_scope(client, engine, agent):
    ids = _seed(engine)
    a, b, c = _three(engine, ids)
    r = _create(client, ids, _scoped(ids[6], input_ids=[a, b, c]))
    assert r.status_code == 200, r.text
    run_id = r.json()["id"]
    sent = agent.sent[-1]["model_vibes"]
    assert [m[0] for m in K1_RE.findall(sent)] == [a]
    assert "add case sla" not in sent and "asset hierarchy" not in sent
    assert _links(engine, run_id) == {a}
    assert json.loads(r.json()["parameters_json"])["included_input_ids"] == [a]
    # The agent even (wrongly) reports the unsent ones as applied.
    ws = _success_ws({7: _model(input_outcomes=[
        _outcome(a, "applied"), _outcome(b, "applied"), _outcome(c, "applied")])})
    _complete(engine, run_id, ws, 6)
    assert _state(engine, a) == (True, False)
    assert _state(engine, b) == (False, True)
    assert _state(engine, c) == (False, True)


def test_retry_relinks_only_sent_items(client, engine, agent):
    ids = _seed(engine)
    a, b, c = _three(engine, ids)
    r = _create(client, ids, _scoped(ids[6], input_ids=[a, b, c]))
    assert r.status_code == 200, r.text
    run_id = r.json()["id"]
    _fail_run(engine, run_id)
    assert _links(engine, run_id) == set()
    rr = client.post(f"/api/businesses/{ids['bid']}/runs/{run_id}/retry")
    assert rr.status_code == 200, rr.text
    assert _links(engine, run_id) == {a}
    # Retry re-dispatches the same scope.
    assert agent.sent[-1]["vibe_scope"] == "Some Domains"
    assert agent.sent[-1]["business_domains"] == "meter_to_cash"


def test_scope_with_only_out_of_scope_inputs_is_422(client, engine, agent):
    ids = _seed(engine)
    _, b, c = _three(engine, ids)
    body = _scoped(ids[6], input_ids=[b, c])
    v = _validate(client, ids, body)
    msgs = [x["message"] for x in v.json()["blockers"] if x["field_path"] == "vibe_scope_inputs"]
    assert msgs, v.json()
    r = _create(client, ids, body)
    assert r.status_code == 422 and r.json()["detail"] == msgs[0]


def test_model_wide_and_deleted_domain_anchor_excluded(client, engine, agent):
    """A model-wide item and an item whose anchor domain row was deleted are
    excluded from a scoped run (never a 500)."""
    ids = _seed(engine)
    a = _feedback(engine, ids, 6, "meter_to_cash", "tighten meter reads")
    mw = _feedback(engine, ids, 6, None, "use snake_case")
    gone = _feedback(engine, ids, 6, "meter_to_cash", "anchored to deleted domain")
    with Session(engine) as s:
        lk = s.exec(select(VibeInputContextLink).where(
            VibeInputContextLink.input_id == gone)).one()
        lk.domain_id = "deleted-domain-id"
        s.add(lk)
        s.commit()
    cmp = client.post(
        f"/api/businesses/{ids['bid']}/versions/{ids[6]}/inputs/compile",
        json={"input_ids": [a, mw, gone], "vibe_scope_domains": ["meter_to_cash"]},
    )
    assert cmp.status_code == 200, cmp.text
    out = cmp.json()
    assert out["included_input_ids"] == [a]
    assert out["excluded_reasons"][mw] == "model_wide_in_scoped_run"
    assert gone in out["excluded_input_ids"]
    r = _create(client, ids, _scoped(ids[6], input_ids=[a, mw, gone]))
    assert r.status_code == 200, r.text
    assert _links(engine, r.json()["id"]) == {a}


# --------------------------------------------------------------------------- #
# 4. Dry Run, then Full Run on the same base
# --------------------------------------------------------------------------- #


def test_dry_run_then_full_run(client, engine, agent, monkeypatch):
    from vibe_modeling.backend import explorer

    ids = _seed(engine)
    a, b, _c = _three(engine, ids)
    dry = _create(client, ids, _scoped(ids[6], input_ids=[a, b], dry_run=True))
    assert dry.status_code == 200, dry.text
    assert agent.sent[-1]["run_type"] == "Dry Run"
    dry_id = dry.json()["id"]
    _complete(engine, dry_id,
              _success_ws({7: _model(input_outcomes=[_outcome(a, "applied")])}), 6)
    with Session(engine) as s:
        v7 = s.exec(select(ModelVersion).where(
            ModelVersion.business_id == ids["bid"], ModelVersion.version == 7)).one()
        assert v7.status == "draft"
        assert s.get(ModelVersion, ids[6]).status == "completed"  # not superseded
    assert _state(engine, a) == (False, True)  # applied, but a Dry Run
    assert _links(engine, dry_id) == {a}       # audit kept

    # The run lock released? mark the dry run completed as the tracker does.
    with Session(engine) as s:
        run = s.get(Run, dry_id)
        run.status = "completed"
        s.add(run)
        s.commit()

    # The draft v7 is registered in the catalog with deploy_status NULL (P0),
    # which the agent counts as its latest completed version: a scoped run on
    # v6 is refused until the draft is deleted. An unscoped Full Run is not.
    scoped = _create(client, ids, _scoped(ids[6], input_ids=[a, b]))
    assert scoped.status_code == 422, scoped.text
    assert "v7 is in its registry" in scoped.json()["detail"]
    full = _create(client, ids, _body(ids[6], input_ids=[a, b], vibe_instructions="x"))
    assert full.status_code == 200, full.text
    assert agent.sent[-1]["run_type"] == "Full Run"
    assert agent.sent[-1]["model_version"] == "6"
    # Volume lag: v8 404s for 3 attempts while the draft v7 is readable.
    ws = _success_ws(
        {7: _model(input_outcomes=[_outcome(a, "failed")]),
         8: _model(input_outcomes=[_outcome(a, "applied")],
                   lineage={"output_version": 8, "base_version": 6})},
        fail_first={8: 3},
    )
    res = _complete(engine, full.json()["id"], ws, 6)
    with Session(engine) as s:
        report = s.get(RunAgentReport, full.json()["id"])
        assert report.expected_version == 8 and report.fetched_version == 8
        assert report.version_mismatch is False
    assert _state(engine, a) == (True, False)
    with Session(engine) as s:
        v8 = s.get(ModelVersion, res.output_version_id)
        assert v8.version == 8 and v8.status == "completed"
        assert v8.base_version_id == ids[6]
        assert s.get(ModelVersion, ids[6]).status == "superseded"
        # The draft is not superseded by the Full Run either? record it.
        draft_status = s.exec(select(ModelVersion).where(
            ModelVersion.business_id == ids["bid"], ModelVersion.version == 7)).one().status
    assert draft_status == "draft"

    loaded = []
    monkeypatch.setattr(explorer, "_load_model",
                        lambda session, ws, biz, v, scope: loaded.append(v) or {"v": v})
    with Session(engine) as s:
        prev = explorer._load_prev_model(s, MagicMock(), ids["bid"], 8, "ecm")
    assert prev == {"v": 6} and loaded == [6]


# --------------------------------------------------------------------------- #
# 5. Outcomes
# --------------------------------------------------------------------------- #


def test_consume_only_applied_with_mixed_statuses(client, engine, agent):
    ids = _seed(engine)
    statuses = ["applied", "APPLIED", "partial", "failed", "deferred",
                "scope_rejected", "unmapped", None]
    iids = [_feedback(engine, ids, 6, "meter_to_cash", f"item {i}") for i in range(len(statuses))]
    r = _create(client, ids, _scoped(ids[6], input_ids=iids))
    assert r.status_code == 200, r.text
    outcomes = [_outcome(i, s) for i, s in zip(iids, statuses) if s is not None]
    _complete(engine, r.json()["id"], _success_ws({7: _model(input_outcomes=outcomes)}), 6)
    got = {s or "missing": _state(engine, i) for i, s in zip(iids, statuses)}
    assert got == {
        "applied": (True, False), "APPLIED": (True, False),
        "partial": (False, True), "failed": (False, True), "deferred": (False, True),
        "scope_rejected": (False, True), "unmapped": (False, True),
        "missing": (False, True),
    }


def test_version_mismatch_fails_the_op_and_consumes_nothing(client, engine, agent):
    ids = _seed(engine)
    a = _feedback(engine, ids, 6, "meter_to_cash", "tighten reads")
    r = _create(client, ids, _scoped(ids[6], input_ids=[a]))
    run_id = r.json()["id"]
    doc = _model(input_outcomes=[_outcome(a, "applied")], lineage={"output_version": "v6"})
    op = _op(engine, run_id)
    run = _run(engine, run_id)
    ctx = OperationContext(
        run_id=run_id, operation_id=op.id, business_id=run.business_id,
        parent_version_id=op.parent_version_id, params=json.loads(op.params_json or "{}"),
        inherited_params={"cataloging_style": "One Catalog"},
    )
    handle = OperationDispatchHandle(
        databricks_run_id=1, vibe_session_id="sess",
        extra={"deployment_catalog": CATALOG,
               "business_name": agent_business_segment(BIZ_NAME),
               "parent_version_int": 6},
    )
    with patch.object(ModelSyncService, "sync_model", return_value=True):
        with Session(engine) as s:
            obs = VibeIterate().observe(handle, ctx, _success_ws({7: doc}), s)
            s.commit()
    assert obs.is_terminal and obs.terminal_result.succeeded is False
    assert "expected version v7" in obs.terminal_result.error
    with Session(engine) as s:
        assert s.exec(select(ModelVersion).where(
            ModelVersion.business_id == ids["bid"], ModelVersion.version == 7)).first() is None
        assert s.get(RunAgentReport, run_id).version_mismatch is True
    _fail_run(engine, run_id)
    assert _state(engine, a) == (False, True)


# --------------------------------------------------------------------------- #
# 6. K1 markers
# --------------------------------------------------------------------------- #


def _strip_agent(md: str) -> str:
    out = []
    for line in md.split("\n"):
        if K1_RE.fullmatch(line.strip()):
            continue  # opener line
        line = re.sub(r" <!--\s*vi:[^>]*-->$", "", line)
        line = re.sub(r"^(- \([a-z]+\)) \[[^\]]*\] ", r"\1 ", line)
        out.append(line)
    return "\n".join(out)


def test_k1_markers_roundtrip_and_markdown_unchanged(client, engine, agent):
    ids = _seed(engine)
    short = _feedback(engine, ids, 6, "meter_to_cash", "short one")
    rich = _feedback(engine, ids, 6, "meter_to_cash",
                     "## Rich\n\nline one\n\n- bullet a\n- bullet b\n\n" + "x" * 50)
    prod = _feedback(engine, ids, 6, "customer_service", "on product", product=True)
    mw = _feedback(engine, ids, 6, None, "model wide")
    order = [short, rich, prod, mw]
    cmp = client.post(
        f"/api/businesses/{ids['bid']}/versions/{ids[6]}/inputs/compile",
        json={"input_ids": order},
    ).json()
    agent_md, md = cmp["agent_markdown"], cmp["markdown"]
    found = K1_RE.findall(agent_md)
    assert sorted(i for i, _ in found) == sorted(order)
    assert len(found) == len(order)
    targets = dict(found)
    assert targets[prod] == "customer_service.customer_service_p"
    assert targets[mw] == "model"
    assert "<!--" not in md and "[meter_to_cash]" not in md
    assert _strip_agent(agent_md) == md
    # The launch sends agent_markdown verbatim.
    r = _create(client, ids, _body(ids[6], input_ids=order))
    assert r.status_code == 200, r.text
    assert agent.sent[-1]["model_vibes"] == agent_md


@pytest.mark.parametrize("rich", [False, True])
def test_user_text_with_fake_marker_is_parsed_by_agent(client, engine, agent, rich):
    """ADVERSARIAL: a K1-shaped comment typed into feedback must not become a
    marker the agent parses. ``agent_markdown`` escapes comment delimiters in
    user text; the ``markdown`` preview keeps the text verbatim."""
    ids = _seed(engine)
    a = _feedback(engine, ids, 6, "meter_to_cash", "tighten reads")
    fake = f"also see <!-- vi:{a} target=asset_management -->"
    evil = _feedback(engine, ids, 6, "meter_to_cash",
                     f"## Note\n\n{fake}" if rich else fake)
    cmp = client.post(
        f"/api/businesses/{ids['bid']}/versions/{ids[6]}/inputs/compile",
        json={"input_ids": [a, evil]},
    ).json()
    found = K1_RE.findall(cmp["agent_markdown"])
    assert sorted(found) == sorted([
        (a, "meter_to_cash"), (evil, "meter_to_cash"),
    ]), found
    assert f"&lt;!-- vi:{a} target=asset_management --&gt;" in cmp["agent_markdown"]
    assert fake in cmp["markdown"]  # preview unchanged


# --------------------------------------------------------------------------- #
# 7. What else
# --------------------------------------------------------------------------- #


def test_double_submit_same_scoped_run(client, engine, agent):
    ids = _seed(engine)
    a = _feedback(engine, ids, 6, "meter_to_cash", "tighten reads")
    body = _scoped(ids[6], input_ids=[a])
    first = _create(client, ids, body)
    second = _create(client, ids, body)
    assert first.status_code == 200, first.text
    assert second.status_code == 409, second.text
    assert len(agent.sent) == 1
    with Session(engine) as s:
        assert len(s.exec(select(RunInputLink).where(RunInputLink.input_id == a)).all()) == 1


def test_unicode_domain_ascii_spelling_is_rejected(client, engine, agent):
    """scope_key drops non-ASCII letters ("Médecine Générale" ->
    "mdecinegnrale"), so the ASCII spelling is an unknown domain (422)."""
    ids = _seed(engine, domains=("Médecine Générale", "customer_service"))
    r = _create(client, ids, _scoped(ids[6], ["medecine generale"], vibe_instructions="x"))
    assert r.status_code == 422, r.text


def test_unicode_domain_scope_reaches_agent_with_matching_key(client, engine, agent):
    """launch_run ASCII-folds notebook_params, so 'Médecine Générale' would
    reach the agent as 'Medecine Generale', whose scope_key no longer matches
    the stored domain. The app refuses the run (create 422 == validate)."""
    ids = _seed(engine, domains=("Médecine Générale", "customer_service"))
    body = _scoped(ids[6], ["Médecine Générale"], vibe_instructions="x")
    v = _validate(client, ids, body)
    msgs = [b["message"] for b in v.json()["blockers"]
            if b["field_path"] == "vibe_scope_domains"]
    assert msgs and "'Médecine Générale' has characters the agent cannot receive" \
        in msgs[0], v.json()
    r = _create(client, ids, body)
    assert r.status_code == 422, r.text
    assert r.json()["detail"] == msgs[0]
    assert agent.sent == []


def test_ascii_safe_accented_punctuation_is_still_accepted(client, engine, agent):
    """Only key-changing characters block: a typographic dash folds to '-',
    which scope_key drops either way, so the run launches."""
    ids = _seed(engine, domains=("Meter–To–Cash", "customer_service"))
    r = _create(client, ids, _scoped(ids[6], ["meter to cash"], vibe_instructions="x"))
    assert r.status_code == 200, r.text
    assert agent.sent[-1]["business_domains"] == "Meter-To-Cash"


def test_all_non_ascii_domain_cannot_be_scoped(client, engine, agent):
    """A real domain whose name has no [a-z0-9] has an empty scope_key. The
    app refuses it saying the agent cannot receive the name (not the
    misleading 'not a domain name'); an unknown keyless entry still gets
    'not a domain name'."""
    ids = _seed(engine, domains=("顧客", "customer_service"))
    r = _create(client, ids, _scoped(ids[6], ["顧客"], vibe_instructions="x"))
    assert r.status_code == 422
    detail = r.json()["detail"]
    assert "'顧客' has characters the agent cannot receive" in detail, detail
    assert "is not a domain name" not in detail
    r = _create(client, ids, _scoped(ids[6], ["商品"], vibe_instructions="x"))
    assert r.status_code == 422
    assert "'商品' is not a domain name" in r.json()["detail"]
    assert agent.sent == []


def test_colliding_scope_keys_in_base(client, engine, agent):
    """Two base domains that normalize to the same key: the request resolves
    to only the first one, though the agent would fence both."""
    ids = _seed(engine, domains=("Customer Service", "customer_service", "meter_to_cash"))
    r = _create(client, ids, _scoped(ids[6], ["customer_service"], vibe_instructions="x"))
    assert r.status_code == 200, r.text
    assert agent.sent[-1]["business_domains"] in ("Customer Service", "customer_service")


def test_dry_run_all_domains_is_allowed_and_gated_on_agent(client, engine, agent):
    ids = _seed(engine)
    agent.identity["marker"] = "v4.9.9"
    r = _create(client, ids, _body(ids[6], dry_run=True, vibe_instructions="x"))
    assert r.status_code == 422 and "need agent 5.3.3" in r.json()["detail"]
    agent.identity["marker"] = "v5.3.3"
    # The switch to the bundled agent records the new identity in the cache.
    with Session(engine) as s:
        cfg = s.exec(select(AgentConfig)).first()
        cfg.installed_checked_at = None
        s.add(cfg)
        s.commit()
    r = _create(client, ids, _body(ids[6], dry_run=True, vibe_instructions="x"))
    assert r.status_code == 200, r.text
    assert agent.sent[-1]["run_type"] == "Dry Run"
    assert agent.sent[-1]["vibe_scope"] == "All Domains"


def test_long_scoped_vibe_text_is_offloaded(client, engine, agent, mock_ws):
    """>1800 chars of agent_markdown goes to a Volume file; the scoped widgets
    still ride inline."""
    ids = _seed(engine)
    iids = [_feedback(engine, ids, 6, "meter_to_cash", f"item {i} " + "y" * 150)
            for i in range(15)]
    r = _create(client, ids, _scoped(ids[6], input_ids=iids))
    assert r.status_code == 200, r.text
    w = agent.sent[-1]
    assert w["model_vibes"].startswith("/Volumes/"), w["model_vibes"][:200]
    assert w["vibe_scope"] == "Some Domains"
    uploaded = [c for c in mock_ws.files.upload.call_args_list]
    assert uploaded, "expected the agent markdown to be uploaded"
    body = uploaded[-1].kwargs.get("contents") or uploaded[-1].args[1]
    data = body.read() if hasattr(body, "read") else body
    if isinstance(data, bytes):
        data = data.decode()
    assert sorted(i for i, _ in K1_RE.findall(data)) == sorted(iids)


def test_single_huge_free_text_scoped_run(client, engine, agent):
    """A 10,000-char free-text scoped instruction (no inputs)."""
    ids = _seed(engine)
    r = _create(client, ids, _scoped(ids[6], vibe_instructions="z" * 10_000))
    assert r.status_code == 200, r.text
    assert agent.sent[-1]["model_vibes"].startswith("/Volumes/")


@pytest.mark.parametrize("name", ["Billing, Payments", "Billing; Payments",
                                  "Billing\nPayments"])
def test_domain_name_with_comma_survives_scope_list(client, engine, agent, name):
    """The agent splits business_domains on [,;\\n] (design §3), so a stored
    domain whose name contains one of those is refused, naming the domain
    (create 422 == validate)."""
    ids = _seed(engine, domains=(name, "customer_service"))
    body = _scoped(ids[6], [name], vibe_instructions="x")
    v = _validate(client, ids, body)
    msgs = [b["message"] for b in v.json()["blockers"]
            if b["field_path"] == "vibe_scope_domains"]
    assert msgs and f"The domain name '{name}' contains a comma, semicolon or " \
        "line break" in msgs[0], v.json()
    r = _create(client, ids, body)
    assert r.status_code == 422, r.text
    assert r.json()["detail"] == msgs[0]
    assert agent.sent == []
