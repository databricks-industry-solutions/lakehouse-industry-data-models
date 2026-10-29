"""Vibe-scope and Dry Run preflight blockers (design §5.3, D5, D14).

``run_preflight`` is shared by ``POST /runs/validate`` and ``POST /runs``. The
scope checks run before the agent-not-configured early return and use their
own field paths, so ``create_run`` refuses exactly them with 422 while every
other blocker keeps its 400/409. The agent-marker gate runs on
the identity cache: validate reads only the stored identity, create reads the
notebook when the cache is stale; a failed read is a blocker.
"""

from __future__ import annotations

from types import SimpleNamespace
from unittest.mock import MagicMock

import pytest
from sqlmodel import Session, select

from vibe_modeling.backend.db_models import AgentConfig, Business, Domain, ModelVersion
from vibe_modeling.backend.models import CompileOut, Intent, RunIn, VibeScope
from vibe_modeling.backend.routes import _helpers as route_helpers
from vibe_modeling.backend.services.orchestrator import preflight as preflight_mod
from vibe_modeling.backend.services.orchestrator.preflight import (
    _VIBE_SCOPE_BLOCKER_FIELD_PATHS,
    _check_scope_agent_marker,
    run_preflight,
)

_SCOPE_PATHS = _VIBE_SCOPE_BLOCKER_FIELD_PATHS


def _seed(engine, *, versions=((6, "completed"),), with_agent=True) -> dict:
    """A business with ECM versions; the last listed one carries the domains.

    ``meter_to_cash`` is stored twice (split domain x subdomain rows) to check
    the de-duplication of base domain names.
    """
    with Session(engine) as s:
        if with_agent and s.exec(select(AgentConfig)).first() is None:
            s.add(AgentConfig(
                notebook_path="/Workspace/agent.ipynb",
                deployment_catalog="meta_cat",
                warehouse_id="wh-1",
                job_id=7,
                job_name="vibe_job",
            ))
        biz = Business(name="Scope Co", description="Utility company")
        s.add(biz)
        s.flush()
        ids = {"business_id": biz.id}
        for version, status in versions:
            mv = ModelVersion(business_id=biz.id, version=version, scope="ecm", status=status)
            s.add(mv)
            s.flush()
            ids[version] = mv.id
            for name in ("meter_to_cash", "meter_to_cash", "customer_service"):
                s.add(Domain(version_id=mv.id, name=name))
        s.commit()
        return ids


def _agent(engine):
    with Session(engine) as s:
        return s.exec(select(AgentConfig)).first()


def _run(version_id, **kw) -> RunIn:
    kw.setdefault("intent", Intent.VIBE_ITERATE)
    kw.setdefault("vibe_instructions", "Tighten meter reads")
    return RunIn(version_id=version_id, **kw)


def _scope_blockers(engine, biz_id, data, *, agent_config="seeded", create_path=False, ws=None):
    cfg = _agent(engine) if agent_config == "seeded" else agent_config
    with Session(engine) as s:
        out = run_preflight(
            biz_id, data, business=s.get(Business, biz_id), agent_config=cfg, session=s,
            ws=ws, config=None, user=None, create=create_path,
        ).issues
    return [b for b in out if b.field_path in _SCOPE_PATHS]


def _messages(blockers) -> str:
    return " | ".join(b.message for b in blockers)


# --- request-shape rows ---------------------------------------------------


def test_unscoped_full_run_has_no_scope_blockers(engine):
    ids = _seed(engine)
    assert _scope_blockers(engine, ids["business_id"], _run(ids[6])) == []


def test_unscoped_dry_run_on_vibe_iterate_is_allowed(engine):
    ids = _seed(engine)
    assert _scope_blockers(engine, ids["business_id"], _run(ids[6], dry_run=True)) == []


@pytest.mark.parametrize("intent", [Intent.INSTALL, Intent.UNINSTALL, Intent.VIBE_NEW_ECM_MVM])
def test_scope_on_other_intent_blocked(engine, intent):
    ids = _seed(engine)
    data = _run(ids[6], intent=intent, vibe_scope=VibeScope.SOME_DOMAINS,
                vibe_scope_domains=["meter_to_cash"])
    blockers = _scope_blockers(engine, ids["business_id"], data)
    assert [b.field_path for b in blockers] == ["vibe_scope"]
    assert "Vibe iteration runs only" in blockers[0].message


def test_dry_run_on_other_intent_blocked_on_dry_run_field(engine):
    ids = _seed(engine)
    data = _run(ids[6], intent=Intent.INSTALL, dry_run=True)
    blockers = _scope_blockers(engine, ids["business_id"], data)
    assert [b.field_path for b in blockers] == ["dry_run"]


def test_scope_with_legacy_next_vibe_ids_blocked(engine):
    ids = _seed(engine)
    data = _run(ids[6], vibe_scope=VibeScope.SOME_DOMAINS,
                vibe_scope_domains=["meter_to_cash"], next_vibe_ids=["nv-1"])
    blockers = _scope_blockers(engine, ids["business_id"], data)
    assert [b.field_path for b in blockers] == ["vibe_scope"]


def test_some_subdomains_blocked(engine):
    ids = _seed(engine)
    data = _run(ids[6], vibe_scope=VibeScope.SOME_SUBDOMAINS, vibe_scope_domains=["meter_to_cash"])
    blockers = _scope_blockers(engine, ids["business_id"], data)
    assert [b.field_path for b in blockers] == ["vibe_scope"]
    assert "Some Subdomains is not supported yet" in blockers[0].message


@pytest.mark.parametrize("domains", [[], ["", "   "]])
def test_empty_scope_list_blocked(engine, domains):
    ids = _seed(engine)
    data = _run(ids[6], vibe_scope=VibeScope.SOME_DOMAINS, vibe_scope_domains=domains)
    blockers = _scope_blockers(engine, ids["business_id"], data)
    assert [b.field_path for b in blockers] == ["vibe_scope_domains"]
    assert "Pick at least one domain" in blockers[0].message


@pytest.mark.parametrize("entry", ["meter_to_cash.billing", "___"])
def test_malformed_entry_blocked(engine, entry):
    ids = _seed(engine)
    data = _run(ids[6], vibe_scope=VibeScope.SOME_DOMAINS, vibe_scope_domains=[entry])
    blockers = _scope_blockers(engine, ids["business_id"], data)
    assert [b.field_path for b in blockers] == ["vibe_scope_domains"]
    assert f"'{entry}' is not a domain name" in blockers[0].message


def test_domains_with_all_domains_blocked(engine):
    ids = _seed(engine)
    data = _run(ids[6], vibe_scope_domains=["meter_to_cash"])
    blockers = _scope_blockers(engine, ids["business_id"], data)
    assert [b.field_path for b in blockers] == ["vibe_scope_domains"]
    assert "only used with Some domains" in blockers[0].message


def test_business_domains_conflict_blocked(engine):
    ids = _seed(engine)
    data = _run(ids[6], vibe_scope=VibeScope.SOME_DOMAINS,
                vibe_scope_domains=["meter_to_cash"], business_domains="billing")
    blockers = _scope_blockers(engine, ids["business_id"], data)
    assert [b.field_path for b in blockers] == ["vibe_scope_domains"]
    assert "Business domains and the vibe scope can't both be set" in blockers[0].message


# --- domain resolution ----------------------------------------------------


def test_unknown_domain_blocked_with_suggestion(engine):
    ids = _seed(engine)
    data = _run(ids[6], vibe_scope=VibeScope.SOME_DOMAINS, vibe_scope_domains=["meter2cash"])
    blockers = _scope_blockers(engine, ids["business_id"], data)
    assert [b.field_path for b in blockers] == ["vibe_scope_domains"]
    msg = blockers[0].message
    assert "'meter2cash' is not a domain of v6 ECM" in msg
    assert "Did you mean: meter_to_cash?" in msg
    assert "treat it as a new domain" in msg


def test_unknown_domain_without_close_match_has_no_suggestion(engine):
    ids = _seed(engine)
    data = _run(ids[6], vibe_scope=VibeScope.SOME_DOMAINS, vibe_scope_domains=["zzzz"])
    blockers = _scope_blockers(engine, ids["business_id"], data)
    assert len(blockers) == 1
    assert "Did you mean" not in blockers[0].message


def test_known_domain_canonicalized_and_deduplicated(engine):
    ids = _seed(engine)
    data = _run(ids[6], vibe_scope=VibeScope.SOME_DOMAINS,
                vibe_scope_domains=["Meter To Cash", "meter_to_cash", " customer service "])
    assert _scope_blockers(engine, ids["business_id"], data) == []
    assert data.vibe_scope_domains == ["meter_to_cash", "customer_service"]


def test_unknown_domain_leaves_request_untouched(engine):
    ids = _seed(engine)
    data = _run(ids[6], vibe_scope=VibeScope.SOME_DOMAINS,
                vibe_scope_domains=["Meter To Cash", "meter2cash"])
    _scope_blockers(engine, ids["business_id"], data)
    assert data.vibe_scope_domains == ["Meter To Cash", "meter2cash"]


# --- base version (head rule) ---------------------------------------------


def test_base_is_head_passes(engine):
    ids = _seed(engine, versions=((5, "superseded"), (6, "completed")))
    data = _run(ids[6], vibe_scope=VibeScope.SOME_DOMAINS, vibe_scope_domains=["meter_to_cash"])
    assert _scope_blockers(engine, ids["business_id"], data) == []


def test_draft_base_blocked(engine):
    ids = _seed(engine, versions=((6, "completed"), (7, "draft")))
    data = _run(ids[7], vibe_scope=VibeScope.SOME_DOMAINS, vibe_scope_domains=["meter_to_cash"])
    blockers = _scope_blockers(engine, ids["business_id"], data)
    assert [b.field_path for b in blockers] == ["vibe_scope_base"]
    assert "v7 is a Dry Run draft; the latest is v6" in blockers[0].message


def test_superseded_base_blocked(engine):
    ids = _seed(engine, versions=((5, "superseded"), (6, "completed")))
    data = _run(ids[5], vibe_scope=VibeScope.SOME_DOMAINS, vibe_scope_domains=["meter_to_cash"])
    blockers = _scope_blockers(engine, ids["business_id"], data)
    assert [b.field_path for b in blockers] == ["vibe_scope_base"]
    assert "v5" in blockers[0].message and "v6" in blockers[0].message


def test_completed_base_behind_head_blocked(engine):
    ids = _seed(engine, versions=((5, "completed"), (6, "completed")))
    data = _run(ids[5], vibe_scope=VibeScope.SOME_DOMAINS, vibe_scope_domains=["meter_to_cash"])
    blockers = _scope_blockers(engine, ids["business_id"], data)
    assert [b.field_path for b in blockers] == ["vibe_scope_base"]
    assert "v5 is behind v6" in blockers[0].message


def test_unscoped_run_on_old_base_not_blocked(engine):
    ids = _seed(engine, versions=((5, "superseded"), (6, "completed")))
    assert _scope_blockers(engine, ids["business_id"], _run(ids[5])) == []


# --- in-scope inputs --------------------------------------------------------


def _patch_compile(monkeypatch, included):
    calls = []

    def fake_compile(session, version_id, input_ids, *, scope_domains=None):
        calls.append((version_id, list(input_ids), scope_domains))
        return CompileOut(included_input_ids=list(included))

    monkeypatch.setattr(preflight_mod, "compile_inputs", fake_compile)
    return calls


def test_zero_in_scope_inputs_blocked(engine, monkeypatch):
    ids = _seed(engine)
    calls = _patch_compile(monkeypatch, included=[])
    data = _run(ids[6], vibe_scope=VibeScope.SOME_DOMAINS,
                vibe_scope_domains=["Meter To Cash"], input_ids=["in-1"])
    blockers = _scope_blockers(engine, ids["business_id"], data)
    assert [b.field_path for b in blockers] == ["vibe_scope_inputs"]
    assert "None of the selected inputs are anchored in meter_to_cash" in blockers[0].message
    # The scoped compile receives the canonical names on the base version.
    assert calls == [(ids[6], ["in-1"], ["meter_to_cash"])]


def test_some_in_scope_inputs_pass(engine, monkeypatch):
    ids = _seed(engine)
    _patch_compile(monkeypatch, included=["in-1"])
    data = _run(ids[6], vibe_scope=VibeScope.SOME_DOMAINS,
                vibe_scope_domains=["meter_to_cash"], input_ids=["in-1", "in-2"])
    assert _scope_blockers(engine, ids["business_id"], data) == []


def test_free_text_scoped_run_without_inputs_stays_valid(engine, monkeypatch):
    ids = _seed(engine)
    calls = _patch_compile(monkeypatch, included=[])
    data = _run(ids[6], vibe_scope=VibeScope.SOME_DOMAINS, vibe_scope_domains=["meter_to_cash"])
    assert _scope_blockers(engine, ids["business_id"], data) == []
    assert calls == []


def _seed_input_on(engine, version_id, business_id, domain_name) -> str:
    from vibe_modeling.backend.db_models import VibeInput, VibeInputContextLink

    with Session(engine) as s:
        domain = s.exec(
            select(Domain).where(Domain.version_id == version_id, Domain.name == domain_name)
        ).first()
        vi = VibeInput(business_id=business_id, text=f"Fix {domain_name}", origin="user")
        s.add(vi)
        s.flush()
        s.add(VibeInputContextLink(
            input_id=vi.id, version_id=version_id, domain_id=domain.id, is_origin=True,
        ))
        s.commit()
        return vi.id


def test_real_compile_out_of_scope_input_blocked(engine):
    ids = _seed(engine)
    iid = _seed_input_on(engine, ids[6], ids["business_id"], "customer_service")
    data = _run(ids[6], vibe_scope=VibeScope.SOME_DOMAINS,
                vibe_scope_domains=["meter_to_cash"], input_ids=[iid])
    blockers = _scope_blockers(engine, ids["business_id"], data)
    assert [b.field_path for b in blockers] == ["vibe_scope_inputs"]


def test_real_compile_in_scope_input_passes(engine):
    ids = _seed(engine)
    iid = _seed_input_on(engine, ids[6], ids["business_id"], "meter_to_cash")
    data = _run(ids[6], vibe_scope=VibeScope.SOME_DOMAINS,
                vibe_scope_domains=["meter_to_cash"], input_ids=[iid])
    assert _scope_blockers(engine, ids["business_id"], data) == []


# --- placement relative to the agent check ------------------------------------


def test_scope_blockers_present_without_agent(engine):
    ids = _seed(engine, with_agent=False)
    data = _run(ids[6], vibe_scope=VibeScope.SOME_DOMAINS, vibe_scope_domains=["meter2cash"])
    blockers = _scope_blockers(engine, ids["business_id"], data, agent_config=None)
    assert [b.field_path for b in blockers] == ["vibe_scope_domains"]


# --- agent-marker gate (create path) ----------------------------------------


def _patch_identity(monkeypatch, marker=None, exc=None):
    calls = []

    def fake_identity(ws, path):
        calls.append(path)
        if exc is not None:
            raise exc
        return ("v0.8.0", marker)

    monkeypatch.setattr(route_helpers, "_detect_notebook_identity", fake_identity)
    return calls


def _marker_gate(data, monkeypatch, *, engine, **kw):
    """The create-path gate: the identity cache is empty, so it reads live."""
    _patch_identity(monkeypatch, **kw)
    with Session(engine) as s:
        cfg = AgentConfig(notebook_path="/Workspace/agent.ipynb")
        s.add(cfg)
        s.commit()
        return _check_scope_agent_marker("biz", data, cfg, s, MagicMock(), live=True)


_SCOPED = dict(vibe_scope=VibeScope.SOME_DOMAINS, vibe_scope_domains=["meter_to_cash"])


@pytest.mark.parametrize("marker", ["v4.9.9", "4.9.9", "v5.3.2"])
def test_marker_below_minimum_blocked(engine, monkeypatch, marker):
    blocker = _marker_gate(_run("x", **_SCOPED), monkeypatch, engine=engine, marker=marker)
    assert blocker is not None and blocker.field_path == "vibe_scope_agent"
    assert "need agent 5.3.3 or later" in blocker.message
    assert f"reports {marker.lstrip('v')}." in blocker.message


@pytest.mark.parametrize("marker", ["v5.3.3", "5.3.3", "v5.3.10", "v6.0.0"])
def test_marker_at_or_above_minimum_passes(engine, monkeypatch, marker):
    assert _marker_gate(_run("x", **_SCOPED), monkeypatch, engine=engine, marker=marker) is None


def test_dry_run_alone_is_gated(engine, monkeypatch):
    blocker = _marker_gate(_run("x", dry_run=True), monkeypatch, engine=engine, marker="v4.9.9")
    assert blocker is not None and blocker.field_path == "vibe_scope_agent"


def test_missing_marker_blocked(engine, monkeypatch):
    blocker = _marker_gate(_run("x", **_SCOPED), monkeypatch, engine=engine, marker=None)
    assert blocker is not None and "reports no agent version" in blocker.message


def test_export_failure_becomes_blocker(engine, monkeypatch):
    blocker = _marker_gate(_run("x", **_SCOPED), monkeypatch, engine=engine, exc=RuntimeError("permission denied"))
    assert blocker is not None and blocker.field_path == "vibe_scope_agent"
    assert blocker.message == (
        "Could not read the configured agent notebook to check its version."
    )
    assert "permission denied" not in blocker.message


def test_unscoped_full_run_never_exports(engine, monkeypatch):
    calls = _patch_identity(monkeypatch, marker="v4.9.9")
    cfg = AgentConfig(notebook_path="/Workspace/agent.ipynb")
    with Session(engine) as s:
        assert _check_scope_agent_marker("biz", _run("x"), cfg, s, MagicMock(), live=True) is None
    assert calls == []


def test_validate_path_reads_only_the_stored_identity(engine, monkeypatch):
    calls = _patch_identity(monkeypatch, marker="v5.3.3")
    from datetime import datetime, timezone

    cfg = AgentConfig(
        notebook_path="/Workspace/agent.ipynb", installed_agent_version="4.9.9",
        installed_checked_path="/Workspace/agent.ipynb",
        installed_checked_at=datetime(2020, 1, 1, tzinfo=timezone.utc),
    )
    with Session(engine) as s:
        blocker = _check_scope_agent_marker("biz", _run("x", **_SCOPED), cfg, s, MagicMock(), live=False)
    assert blocker is not None and "reports 4.9.9" in blocker.message
    assert calls == []


def test_marker_gate_runs_on_create_path_only(engine, monkeypatch):
    ids = _seed(engine)
    calls = _patch_identity(monkeypatch, marker="v4.9.9")
    data = _run(ids[6], **_SCOPED)
    assert _scope_blockers(engine, ids["business_id"], data, ws=MagicMock()) == []
    assert calls == []
    blockers = _scope_blockers(engine, ids["business_id"], _run(ids[6], **_SCOPED),
                               create_path=True, ws=MagicMock())
    assert [b.field_path for b in blockers] == ["vibe_scope_agent"]
    assert calls == ["/Workspace/agent.ipynb"]


# --- HTTP: validate / create parity and status codes ------------------------


def _stub_workspace(mock_ws, *, parent_rows=1):
    mock_ws.schemas.list.side_effect = lambda *a, **kw: iter(
        [SimpleNamespace(name="_metamodel"), SimpleNamespace(name="default")]
    )
    from _sql_fakes import response

    mock_ws.statement_execution.execute_statement.return_value = response([[str(parent_rows)]])


def _body(version_id, **kw):
    body = {
        "intent": "vibe-iterate",
        "version_id": version_id,
        "vibe_instructions": "Tighten meter reads",
    }
    body.update(kw)
    return body


def test_unknown_domain_validate_and_create_share_message(client, engine, mock_ws):
    ids = _seed(engine)
    _stub_workspace(mock_ws)
    body = _body(ids[6], vibe_scope="some_domains", vibe_scope_domains=["meter2cash"])
    biz = ids["business_id"]

    v = client.post(f"/api/businesses/{biz}/runs/validate", json=body)
    assert v.status_code == 200, v.text
    scope_msgs = [b["message"] for b in v.json()["blockers"] if b["field_path"] == "vibe_scope_domains"]
    assert len(scope_msgs) == 1

    c = client.post(f"/api/businesses/{biz}/runs", json=body)
    assert c.status_code == 422, c.text
    assert c.json()["detail"] == scope_msgs[0]


@pytest.mark.parametrize("extra, expected", [
    ({"vibe_scope": "some_subdomains", "vibe_scope_domains": ["meter_to_cash"]}, "Some Subdomains"),
    ({"vibe_scope": "some_domains", "vibe_scope_domains": []}, "Pick at least one domain"),
    ({"intent": "install", "dry_run": True}, "Vibe iteration runs only"),
])
def test_scope_blockers_create_422(client, engine, mock_ws, extra, expected):
    ids = _seed(engine)
    _stub_workspace(mock_ws)
    resp = client.post(f"/api/businesses/{ids['business_id']}/runs", json=_body(ids[6], **extra))
    assert resp.status_code == 422, resp.text
    assert expected in resp.json()["detail"]


def test_stale_base_create_422(client, engine, mock_ws):
    ids = _seed(engine, versions=((5, "completed"), (6, "completed")))
    _stub_workspace(mock_ws)
    body = _body(ids[5], vibe_scope="some_domains", vibe_scope_domains=["meter_to_cash"])
    resp = client.post(f"/api/businesses/{ids['business_id']}/runs", json=body)
    assert resp.status_code == 422, resp.text
    assert "v5 is behind v6" in resp.json()["detail"]


def test_old_agent_marker_create_422(client, engine, mock_ws, monkeypatch):
    ids = _seed(engine)
    _stub_workspace(mock_ws)
    _patch_identity(monkeypatch, marker="v4.9.9")
    body = _body(ids[6], vibe_scope="some_domains", vibe_scope_domains=["meter_to_cash"])
    resp = client.post(f"/api/businesses/{ids['business_id']}/runs", json=body)
    assert resp.status_code == 422, resp.text
    assert "reports 4.9.9" in resp.json()["detail"]


def test_export_failure_create_is_422_not_500(client, engine, mock_ws, monkeypatch):
    ids = _seed(engine)
    _stub_workspace(mock_ws)
    _patch_identity(monkeypatch, exc=RuntimeError("export boom"))
    body = _body(ids[6], dry_run=True)
    resp = client.post(f"/api/businesses/{ids['business_id']}/runs", json=body)
    assert resp.status_code == 422, resp.text
    assert "Could not read the configured agent notebook" in resp.json()["detail"]
    assert "export boom" not in resp.json()["detail"]


def test_validate_never_exports_notebook(client, engine, mock_ws, monkeypatch):
    ids = _seed(engine)
    _stub_workspace(mock_ws)
    calls = _patch_identity(monkeypatch, marker="v4.9.9")
    body = _body(ids[6], vibe_scope="some_domains", vibe_scope_domains=["meter_to_cash"])
    resp = client.post(f"/api/businesses/{ids['business_id']}/runs/validate", json=body)
    assert resp.status_code == 200, resp.text
    assert not [b for b in resp.json()["blockers"] if b["field_path"] in _SCOPE_PATHS]
    assert calls == []


def test_metamodel_parent_blocker_stays_400(client, engine, mock_ws):
    """The existing ``version_id`` blocker is not a scope path, so it keeps 400."""
    ids = _seed(engine)
    _stub_workspace(mock_ws, parent_rows=0)
    resp = client.post(f"/api/businesses/{ids['business_id']}/runs", json=_body(ids[6]))
    assert resp.status_code == 400, resp.text
    assert "no agent metamodel data" in resp.json()["detail"]


def test_scope_paths_exclude_existing_paths():
    assert {"version_id", "business_id", "catalog", "intent"}.isdisjoint(_SCOPE_PATHS)
