"""Run gates the router wires (v0.9.0 A3).

* Subject-bound confirmations (B4): validate returns the ``confirm`` issues
  in ``warnings``; create refuses any subject not in ``confirmed_issues``
  with 422 ``needs_confirmation``, including one that appeared after
  validate. A plain uninstall whose tables hold rows needs
  ``uninstall_destroys_data:<version>:<catalog>`` (add §6.2).
* The dispatch catalog's registry for vibes (B10, P0 F6), the install clash
  check, the agent-marker gate on the identity cache.
* The legacy next-vibe path runs through the orchestrator (D3), run delete
  removes the run's instruction files (X10), Generate Samples is retired
  (X18).
* Validate and create return the same issues across a matrix of states.
  Allowed asymmetries, by design: (a) with no identity cached, or a stale
  one, validate shows no marker blocker and create reads the notebook;
  (b) the parent-metamodel SQL gate runs on create only; (c) validate
  returns a catalog clash before anything else, so with an active run it
  shows the clash where create answers 409.
"""
from __future__ import annotations

import importlib
import json
from datetime import datetime, timezone
from types import SimpleNamespace
from unittest.mock import MagicMock

import pytest
from sqlmodel import Session, select

from vibe_modeling.backend.db_models import (
    AgentConfig,
    Business,
    Domain,
    ModelVersion,
    ModelVersionInstall,
    Run,
    RunNextVibeLink,
    RunOperation,
)
from vibe_modeling.backend.routes import _helpers as route_helpers
from vibe_modeling.backend.services.operations._version_lifecycle import (
    REGISTRY_RELEASE_PENDING_KEY,
    REGISTRY_RELEASED_KEY,
    mark_version_deployed,
    mark_version_uninstalled,
)

from vibe_modeling.backend.services.orchestrator.validate import (
    install_over_newer_subject,
    install_overwrites_subject,
    install_replaces_subject,
)
from vibe_modeling.backend.services.uninstall_impact import uninstall_confirm_subject

from ._next_vibes_seed import seed_version_with_next_vibe_inputs
from .test_version_lifecycle_routes import _install, _ladder, _ops, _ws_with_run_now

_IMPACT_MODULE = "vibe_modeling.backend.services.uninstall_impact"


def _runs(engine, biz):
    with Session(engine) as s:
        return list(s.exec(select(Run).where(Run.business_id == biz)).all())


def _validate(client, biz, body):
    r = client.post(f"/api/businesses/{biz}/runs/validate", json=body)
    assert r.status_code == 200, r.text
    return r.json()


def _confirms(validate_json):
    return [w for w in validate_json["warnings"] if w["severity"] == "confirm"]


def _install_body(vid, **extra):
    body = {"intent": "install", "version_id": vid, "scope": "ecm", "cataloging_style": "One Catalog"}
    body.update(extra)
    return body


def _seed_identity(engine, marker, *, release="v0.9.0", path=None, error=None):
    with Session(engine) as s:
        cfg = s.exec(select(AgentConfig)).first()
        cfg.installed_agent_version = marker
        cfg.installed_release_version = release
        cfg.installed_checked_path = path or cfg.notebook_path
        cfg.installed_checked_at = datetime.now(timezone.utc)
        cfg.installed_check_error = error
        s.add(cfg)
        s.commit()


def _patch_export(monkeypatch, marker="5.3.3"):
    calls = []

    def fake(ws, path):
        calls.append(path)
        return ("v0.9.0", marker)

    monkeypatch.setattr(route_helpers, "_detect_notebook_identity", fake)
    return calls


@pytest.fixture
def impact(monkeypatch):
    """The uninstall impact service (``services.uninstall_impact``), its scan faked."""
    mod = importlib.import_module(_IMPACT_MODULE)

    state = SimpleNamespace(has_data="yes", limited=False, calls=[])

    def fake(session, ws, warehouse_id, version, catalog, *, cataloging_style=None, user=None, fresh=False):
        state.calls.append(SimpleNamespace(version_id=version.id, catalog=catalog, fresh=fresh, user=user))
        if state.limited:
            raise mod.ScanRateLimited(30)
        tables = [SimpleNamespace(name="orders", kind="TABLE", has_data=state.has_data == "yes")]
        return SimpleNamespace(
            has_data=state.has_data,
            schemas=[SimpleNamespace(name="ecm_sales", tables=tables)],
            reasons=[],
        )

    monkeypatch.setattr(mod, "uninstall_impact", fake, raising=False)
    return state


# --- B4: install confirmations ----------------------------------------------


class TestInstallConfirmations:
    def test_validate_returns_them_and_create_refuses_until_confirmed(
        self, engine, client_with_agent, mock_ws,
    ):
        biz, ids = _ladder(engine)
        _ws_with_run_now(mock_ws)
        body = _install_body(ids[3], catalog="test_catalog")
        expected = {install_over_newer_subject(ids[5]), install_replaces_subject(ids[5])}

        assert {c["subject"] for c in _confirms(_validate(client_with_agent, biz, body))} == expected

        r = client_with_agent.post(f"/api/businesses/{biz}/runs", json=body)
        assert r.status_code == 422, r.text
        detail = r.json()["detail"]
        assert detail["error"] == "needs_confirmation"
        assert "missing" not in detail
        assert {i["subject"] for i in detail["issues"]} == expected
        assert all(i["severity"] == "confirm" for i in detail["issues"])
        assert _runs(engine, biz) == []
        # The UI reads the replaced versions from ``versions``, not the message.
        over = [i for i in detail["issues"] if i["subject"] == install_over_newer_subject(ids[5])]
        assert over[0]["versions"] == [5]
        assert [c["versions"] for c in _confirms(_validate(client_with_agent, biz, body))
                if c["subject"] == install_replaces_subject(ids[5])] == [[]]

        r = _install(client_with_agent, biz, ids[3], catalog="test_catalog", confirmed_issues=sorted(expected))
        assert r.status_code == 200, r.text
        assert [op.operation_name for op in _ops(engine, r.json()["id"])] == ["uninstall", "install"]

    def test_a_partial_confirmation_is_refused(self, engine, client_with_agent, mock_ws):
        biz, ids = _ladder(engine)
        _ws_with_run_now(mock_ws)
        r = _install(
            client_with_agent, biz, ids[3], catalog="test_catalog",
            confirmed_issues=[install_replaces_subject(ids[5])],
        )
        assert r.status_code == 422, r.text
        detail = r.json()["detail"]
        assert len(detail["issues"]) == 2
        assert "v5 is the latest ECM version" in detail["message"]
        assert _runs(engine, biz) == []

    def test_a_confirmation_names_one_version_only(self, engine, client_with_agent, mock_ws):
        biz, ids = _ladder(engine)
        _ws_with_run_now(mock_ws)
        r = _install(
            client_with_agent, biz, ids[3], catalog="test_catalog",
            confirmed_issues=[install_replaces_subject(ids[3]), install_over_newer_subject(ids[3])],
        )
        assert r.status_code == 422, r.text
        assert _runs(engine, biz) == []

    def test_a_subject_that_appears_after_validate_is_refused(self, engine, client_with_agent, mock_ws):
        """Validate saw a free catalog; another run installed v5 there before
        the create: the create needs the new subject."""
        biz, ids = _ladder(engine)
        _ws_with_run_now(mock_ws)
        body = _install_body(ids[3], catalog="sandbox_cat")
        assert _confirms(_validate(client_with_agent, biz, body)) == []

        with Session(engine) as s:
            v5 = s.get(ModelVersion, ids[5])
            v5.uc_catalog = "sandbox_cat"
            s.add(v5)
            s.commit()

        r = client_with_agent.post(f"/api/businesses/{biz}/runs", json=body)
        assert r.status_code == 422, r.text
        subjects = {i["subject"] for i in r.json()["detail"]["issues"]}
        assert install_replaces_subject(ids[5]) in subjects
        assert _runs(engine, biz) == []

    def test_install_over_its_base_needs_no_confirmation(self, engine, client_with_agent, mock_ws):
        """The draft v6 on head v5 with facts naming v5: the agent's base_match
        path, one install step, nothing to confirm (P0 item 2)."""
        biz, ids = _ladder(engine)
        _seed_identity(engine, "5.3.3")
        with Session(engine) as s:
            v6 = s.get(ModelVersion, ids[6])
            v6.scope_fence_mode, v6.scope_base_version, v6.scope_base_scope = "all", 5, "ecm"
            s.add(v6)
            s.commit()
        _ws_with_run_now(mock_ws)
        body = _install_body(ids[6], catalog="test_catalog")
        assert _confirms(_validate(client_with_agent, biz, body)) == []
        r = client_with_agent.post(f"/api/businesses/{biz}/runs", json=body)
        assert r.status_code == 200, r.text


# --- add §6.2: plain uninstall ----------------------------------------------


def _uninstall_body(vid, **extra):
    body = {"intent": "uninstall", "version_id": vid, "scope": "ecm", "cataloging_style": "One Catalog"}
    body.update(extra)
    return body


class TestUninstallDataLoss:
    def test_rows_need_the_subject(self, engine, client_with_agent, mock_ws, impact):
        biz, ids = _ladder(engine)
        _ws_with_run_now(mock_ws)
        subject = uninstall_confirm_subject(ids[5], "test_catalog")

        confirms = _confirms(_validate(client_with_agent, biz, _uninstall_body(ids[5])))
        assert [c["subject"] for c in confirms] == [subject]
        assert "1 of 1 tables hold data" in confirms[0]["message"]
        assert impact.calls[-1].fresh is False

        r = client_with_agent.post(f"/api/businesses/{biz}/runs", json=_uninstall_body(ids[5]))
        assert r.status_code == 422, r.text
        assert r.json()["detail"]["error"] == "needs_confirmation"
        assert [i["subject"] for i in r.json()["detail"]["issues"]] == [subject]
        assert impact.calls[-1].fresh is True
        assert _runs(engine, biz) == []

    def test_a_confirmed_uninstall_runs_no_scan(self, engine, client_with_agent, mock_ws, impact):
        biz, ids = _ladder(engine)
        _ws_with_run_now(mock_ws)
        subject = uninstall_confirm_subject(ids[5], "test_catalog")
        r = client_with_agent.post(
            f"/api/businesses/{biz}/runs", json=_uninstall_body(ids[5], confirmed_issues=[subject]),
        )
        assert r.status_code == 200, r.text
        assert impact.calls == []
        assert [op.operation_name for op in _ops(engine, r.json()["id"])] == ["uninstall"]

    def test_empty_tables_need_nothing(self, engine, client_with_agent, mock_ws, impact):
        biz, ids = _ladder(engine)
        _ws_with_run_now(mock_ws)
        impact.has_data = "no"
        assert _confirms(_validate(client_with_agent, biz, _uninstall_body(ids[5]))) == []
        r = client_with_agent.post(f"/api/businesses/{biz}/runs", json=_uninstall_body(ids[5]))
        assert r.status_code == 200, r.text

    @pytest.mark.parametrize("state", ["unknown", "limited"])
    def test_what_was_not_checked_counts_as_data(self, engine, client_with_agent, mock_ws, impact, state):
        biz, ids = _ladder(engine)
        _ws_with_run_now(mock_ws)
        if state == "limited":
            impact.limited = True
        else:
            impact.has_data = "unknown"
        r = client_with_agent.post(f"/api/businesses/{biz}/runs", json=_uninstall_body(ids[5]))
        assert r.status_code == 422, r.text
        assert r.json()["detail"]["issues"][0]["subject"] == uninstall_confirm_subject(ids[5], "test_catalog")

    def test_a_blocked_uninstall_runs_no_scan(self, engine, client_with_agent, mock_ws, impact):
        biz, ids = _ladder(engine)
        with Session(engine) as s:
            s.add(Run(business_id=biz, intent="vibe-iterate", status="running"))
            s.commit()
        r = client_with_agent.post(f"/api/businesses/{biz}/runs", json=_uninstall_body(ids[5]))
        assert r.status_code == 409, r.text
        assert impact.calls == []

    def test_uninstall_then_install_asks_one_subject(self, engine, client_with_agent, mock_ws, impact):
        """The occupant's loss is the ``install_replaces_in_catalog`` subject:
        no uninstall scan, no second checkbox (R8)."""
        biz, ids = _ladder(engine)
        _ws_with_run_now(mock_ws)
        subjects = {c["subject"] for c in _confirms(
            _validate(client_with_agent, biz, _install_body(ids[3], catalog="test_catalog"))
        )}
        assert not any(s.startswith("uninstall_destroys_data") for s in subjects)
        assert impact.calls == []


# --- B10 and F6: the dispatch catalog's registry -----------------------------


def _vibe_body(vid, **extra):
    body = {"intent": "vibe-iterate", "version_id": vid, "vibe_instructions": "Tighten the sales domain"}
    body.update(extra)
    return body


def _replaced_ladder(engine, *, catalog="test_catalog"):
    """v3 the head (made current over v4 and v5, both replaced), all with
    files in ``catalog``; v3 has the domain ``sales``."""
    with Session(engine) as s:
        b = Business(name="Registry Co", description="d", industry_alignment="Retail")
        s.add(b)
        s.flush()
        ids = {}
        for n, status in ((3, "completed"), (4, "superseded"), (5, "superseded")):
            mv = ModelVersion(
                business_id=b.id, version=n, scope="ecm", status=status,
                deployment_status="deployed" if n == 3 else "uninstalled",
                uc_catalog=catalog, files_catalog=catalog,
                replaced_at=None if n == 3 else datetime.now(timezone.utc),
            )
            s.add(mv)
            s.flush()
            ids[n] = mv.id
            s.add(Domain(version_id=mv.id, name="sales", database_name="ecm_sales"))
        s.commit()
        return b.id, ids


class TestVibeCatalogChecks:
    def test_a_base_not_registered_in_the_catalog_is_refused(self, engine, client_with_agent, mock_ws):
        """P0 F6: v5's files and registry rows are in test_catalog; the agent
        would fail "Version '5' does not exist" in legacy_cat."""
        biz, ids = _ladder(engine)
        _ws_with_run_now(mock_ws)
        body = _vibe_body(ids[5], catalog="legacy_cat")
        blockers = [b for b in _validate(client_with_agent, biz, body)["blockers"] if b["field_path"] == "catalog"]
        assert len(blockers) == 1 and "cannot find v5 in legacy_cat" in blockers[0]["message"]
        r = client_with_agent.post(f"/api/businesses/{biz}/runs", json=body)
        assert r.status_code == 400, r.text
        assert r.json()["detail"] == blockers[0]["message"]
        assert _runs(engine, biz) == []

    def test_scoped_run_while_replaced_versions_are_registered(self, engine, client_with_agent, mock_ws):
        biz, ids = _replaced_ladder(engine)
        _seed_identity(engine, "5.3.3")
        _ws_with_run_now(mock_ws)
        body = _vibe_body(ids[3], catalog="test_catalog", vibe_scope="some_domains",
                          vibe_scope_domains=["sales"])
        blockers = [b for b in _validate(client_with_agent, biz, body)["blockers"]
                    if b["field_path"] == "vibe_scope_base"]
        assert [b["message"] for b in blockers] == [
            "The agent refuses scoped runs on v3 while v4 and v5 are in its registry in "
            "test_catalog. Delete them (replaced), then retry."
        ]
        assert blockers[0]["versions"] == [4, 5]
        r = client_with_agent.post(f"/api/businesses/{biz}/runs", json=body)
        assert r.status_code == 422, r.text
        assert r.json()["detail"] == blockers[0]["message"]

        # Registered elsewhere, the replaced versions do not count here.
        with Session(engine) as s:
            for n in (4, 5):
                mv = s.get(ModelVersion, ids[n])
                mv.uc_catalog = mv.files_catalog = "other_cat"
                s.add(mv)
            s.commit()
        assert not [b for b in _validate(client_with_agent, biz, body)["blockers"]
                    if b["field_path"] == "vibe_scope_base"]
        r = client_with_agent.post(f"/api/businesses/{biz}/runs", json=body)
        assert r.status_code == 200, r.text

    def test_scoped_run_after_the_replaced_versions_were_released(self, engine, client_with_agent, mock_ws):
        """J10: "Make this version current" on v3 uninstalled v4 and v5 from
        test_catalog and released their registry rows (``dry_run``), which the
        agent's stale-base probe skips. Validate and create allow the scoped
        run; while v5's release is pending, both refuse it, naming v5 only."""
        biz, ids = _replaced_ladder(engine)
        _seed_identity(engine, "5.3.3")
        _ws_with_run_now(mock_ws)
        with Session(engine) as s:
            run = Run(business_id=biz, intent="install", status="completed")
            s.add(run)
            s.flush()
            for step, n in enumerate((4, 5)):
                mv = s.get(ModelVersion, ids[n])
                mark_version_deployed(s, mv, "test_catalog")
                op = RunOperation(
                    run_id=run.id, step_index=step, operation_name="uninstall", status="succeeded",
                    params_json=json.dumps({"version_id": mv.id, "deployment_catalog": "test_catalog"}),
                    rollback_state_json=json.dumps({REGISTRY_RELEASED_KEY: True}),
                )
                s.add(op)
                mark_version_uninstalled(s, mv, "test_catalog", run_id=run.id)
            s.commit()
            v5_op = s.exec(select(RunOperation).where(RunOperation.step_index == 1,
                                                       RunOperation.run_id == run.id)).one().id
        body = _vibe_body(ids[3], catalog="test_catalog", vibe_scope="some_domains",
                          vibe_scope_domains=["sales"])
        assert not [b for b in _validate(client_with_agent, biz, body)["blockers"]
                    if b["field_path"] == "vibe_scope_base"]
        r = client_with_agent.post(f"/api/businesses/{biz}/runs", json=body)
        assert r.status_code == 200, r.text
        with Session(engine) as s:
            for created in s.exec(select(Run).where(Run.id == r.json()["id"])).all():
                s.delete(created)
            op = s.get(RunOperation, v5_op)
            op.rollback_state_json = json.dumps({REGISTRY_RELEASE_PENDING_KEY: {"catalog": "test_catalog"}})
            s.add(op)
            s.commit()
        blockers = [b for b in _validate(client_with_agent, biz, body)["blockers"]
                    if b["field_path"] == "vibe_scope_base"]
        assert [b["message"] for b in blockers] == [
            "The agent refuses scoped runs on v3 while v5 is in its registry in "
            "test_catalog. Delete it (replaced), then retry."
        ]
        r = client_with_agent.post(f"/api/businesses/{biz}/runs", json=body)
        assert r.status_code == 422, r.text
        assert r.json()["detail"] == blockers[0]["message"]

    def test_scoped_run_while_a_newer_dry_run_draft_is_registered(self, engine, client_with_agent, mock_ws):
        """The agent counts a Dry Run draft (registered with deploy_status
        NULL) in its latest completed version, so a scoped run on its base
        is refused until the draft is deleted (nb 54994, 56145)."""
        biz, ids = _replaced_ladder(engine)
        with Session(engine) as s:
            for n in (4, 5):
                mv = s.get(ModelVersion, ids[n])
                mv.uc_catalog = mv.files_catalog = "other_cat"
                s.add(mv)
            draft = ModelVersion(business_id=biz, version=6, scope="ecm", status="draft", dry_run=True,
                                 deployment_status="draft", files_catalog="test_catalog",
                                 base_version_id=ids[3])
            s.add(draft)
            s.commit()
        _ws_with_run_now(mock_ws)
        body = _vibe_body(ids[3], catalog="test_catalog", vibe_scope="some_domains",
                          vibe_scope_domains=["sales"])
        blockers = [b for b in _validate(client_with_agent, biz, body)["blockers"]
                    if b["field_path"] == "vibe_scope_base"]
        assert [b["message"] for b in blockers] == [
            "The agent refuses scoped runs on v3 while v6 is in its registry in "
            "test_catalog. Delete it (Dry Run draft), then retry."
        ]
        assert blockers[0]["versions"] == [6]
        r = client_with_agent.post(f"/api/businesses/{biz}/runs", json=body)
        assert r.status_code == 422, r.text

    def test_a_base_installed_in_the_catalog_is_registered_there(self, engine, client_with_agent, mock_ws):
        """``_recorded_in`` decides: files elsewhere, installed here."""
        biz, ids = _ladder(engine)
        with Session(engine) as s:
            v5 = s.get(ModelVersion, ids[5])
            v5.uc_catalog = "legacy_cat"
            s.add(v5)
            s.commit()
        body = _vibe_body(ids[5], catalog="legacy_cat")
        assert not [b for b in _validate(client_with_agent, biz, body)["blockers"] if b["field_path"] == "catalog"]

    def test_unscoped_dry_run_on_an_older_base_warns(self, engine, client_with_agent, mock_ws):
        biz, ids = _ladder(engine)
        _seed_identity(engine, "5.3.3")
        _ws_with_run_now(mock_ws)
        body = _vibe_body(ids[3], catalog="test_catalog", dry_run=True)
        out = _validate(client_with_agent, biz, body)
        assert out["blockers"] == []
        assert [w["message"] for w in out["warnings"] if w["field_path"] == "dry_run"] == [
            "v5 is newer than v3. You can still install this Dry Run later; that would replace v5."
        ]
        r = client_with_agent.post(f"/api/businesses/{biz}/runs", json=body)
        assert r.status_code == 200, r.text


    def _base_version_warnings(self, out):
        return [w for w in out["warnings"] if w["field_path"] == "base_version"]

    def test_unscoped_full_run_on_an_older_base_warns_before_launch(self, engine, client_with_agent, mock_ws):
        """The agent rebuilds the business's schemas when the base is not the
        installed latest, so v5's tables go and its changes are left out."""
        biz, ids = _ladder(engine)
        _seed_identity(engine, "5.3.3")
        _ws_with_run_now(mock_ws)
        body = _vibe_body(ids[3], catalog="test_catalog")
        out = _validate(client_with_agent, biz, body)
        assert out["blockers"] == []
        warnings = self._base_version_warnings(out)
        assert [w["message"] for w in warnings] == [
            "v5 is installed in test_catalog. This Full Run builds from v3, drops v5's tables "
            "and leaves v5's changes out of the new version."
        ]
        assert warnings[0]["severity"] == "warning"
        r = client_with_agent.post(f"/api/businesses/{biz}/runs", json=body)
        assert r.status_code == 200, r.text
        assert self._base_version_warnings(r.json()) == warnings

    def test_it_names_every_newer_installed_version(self, engine, client_with_agent, mock_ws):
        biz, ids = _ladder(engine)
        with Session(engine) as s:
            s.add(ModelVersion(business_id=biz, version=8, scope="ecm", status="completed",
                               deployment_status="deployed", uc_catalog="test_catalog",
                               files_catalog="test_catalog", base_version_id=ids[5]))
            s.commit()
        _seed_identity(engine, "5.3.3")
        _ws_with_run_now(mock_ws)
        out = _validate(client_with_agent, biz, _vibe_body(ids[3], catalog="test_catalog"))
        assert [w["message"] for w in self._base_version_warnings(out)] == [
            "v5 and v8 are installed in test_catalog. This Full Run builds from v3, drops their "
            "tables and leaves their changes out of the new version."
        ]

    def test_the_open_install_rows_of_a_real_install_count(self, engine, client_with_agent, mock_ws):
        """Installed through ``mark_version_deployed``: v5 is also installed in
        second_cat, so ``uc_catalog`` says second_cat and only its open install
        row says test_catalog."""
        biz, ids = _ladder(engine)
        with Session(engine) as s:
            v5 = s.get(ModelVersion, ids[5])
            mark_version_deployed(s, v5, "second_cat")
            s.commit()
            assert v5.uc_catalog == "second_cat"
            open_rows = s.exec(select(ModelVersionInstall).where(
                ModelVersionInstall.version_id == ids[5],
                ModelVersionInstall.uninstalled_at.is_(None),
            )).all()
            assert {r.catalog for r in open_rows} == {"test_catalog", "second_cat"}
        _seed_identity(engine, "5.3.3")
        _ws_with_run_now(mock_ws)
        out = _validate(client_with_agent, biz, _vibe_body(ids[3], catalog="test_catalog"))
        assert [w["message"] for w in self._base_version_warnings(out)] == [
            "v5 is installed in test_catalog. This Full Run builds from v3, drops v5's tables "
            "and leaves v5's changes out of the new version."
        ]
        with Session(engine) as s:
            mark_version_uninstalled(s, s.get(ModelVersion, ids[5]), "test_catalog")
            s.commit()
        out = _validate(client_with_agent, biz, _vibe_body(ids[3], catalog="test_catalog"))
        assert self._base_version_warnings(out) == []

    def test_vibe_ecm_mvm_on_an_older_ecm_warns_before_launch(self, engine, client_with_agent, mock_ws):
        """The shrink step drops the business's schemas there, whatever the base."""
        biz, ids = _ladder(engine)
        _seed_identity(engine, "5.3.3")
        _ws_with_run_now(mock_ws)
        body = {**_vibe_body(ids[3], catalog="test_catalog"), "intent": "vibe-new-ecm-mvm"}
        out = _validate(client_with_agent, biz, body)
        assert out["blockers"] == []
        warnings = self._base_version_warnings(out)
        assert [w["message"] for w in warnings] == [
            "v5 ECM is installed in test_catalog. This run builds from v3, replaces v5's tables "
            "and leaves v5's changes out of the new versions."
        ]
        assert warnings[0]["severity"] == "warning"
        r = client_with_agent.post(f"/api/businesses/{biz}/runs", json=body)
        assert r.status_code == 200, r.text
        assert self._base_version_warnings(r.json()) == warnings

    def test_vibe_ecm_mvm_names_every_newer_installed_ecm(self, engine, client_with_agent, mock_ws):
        biz, ids = _ladder(engine)
        with Session(engine) as s:
            s.add(ModelVersion(business_id=biz, version=8, scope="ecm", status="completed",
                               deployment_status="deployed", uc_catalog="test_catalog",
                               files_catalog="test_catalog", base_version_id=ids[5]))
            s.commit()
        _seed_identity(engine, "5.3.3")
        _ws_with_run_now(mock_ws)
        body = {**_vibe_body(ids[3], catalog="test_catalog"), "intent": "vibe-new-ecm-mvm"}
        out = _validate(client_with_agent, biz, body)
        assert [w["message"] for w in self._base_version_warnings(out)] == [
            "v5 and v8 ECM are installed in test_catalog. This run builds from v3, replaces their "
            "tables and leaves their changes out of the new versions."
        ]

    def test_a_newer_version_installed_elsewhere_or_not_installed_is_no_warning(
        self, engine, client_with_agent, mock_ws,
    ):
        biz, ids = _ladder(engine)
        with Session(engine) as s:
            v5 = s.get(ModelVersion, ids[5])
            v5.deployment_status = "uninstalled"
            s.add(v5)
            s.commit()
        _seed_identity(engine, "5.3.3")
        _ws_with_run_now(mock_ws)
        out = _validate(client_with_agent, biz, _vibe_body(ids[3], catalog="test_catalog"))
        assert self._base_version_warnings(out) == []
        with Session(engine) as s:
            v5 = s.get(ModelVersion, ids[5])
            v5.deployment_status = "deployed"
            v5.uc_catalog = "other_cat"
            s.add(v5)
            s.commit()
        out = _validate(client_with_agent, biz, _vibe_body(ids[3], catalog="test_catalog"))
        assert self._base_version_warnings(out) == []

    def test_no_older_base_warning_for_dry_run_scoped_or_a_latest_base(
        self, engine, client_with_agent, mock_ws,
    ):
        biz, ids = _ladder(engine)
        _seed_identity(engine, "5.3.3")
        _ws_with_run_now(mock_ws)
        bodies = {
            "dry run": _vibe_body(ids[3], catalog="test_catalog", dry_run=True),
            "scoped": _vibe_body(ids[3], catalog="test_catalog", vibe_scope="some_domains",
                                 vibe_scope_domains=["sales"]),
            "base is the installed latest": _vibe_body(ids[5], catalog="test_catalog"),
            "combined, base is the installed latest": {
                **_vibe_body(ids[5], catalog="test_catalog"), "intent": "vibe-new-ecm-mvm",
            },
        }
        for name, body in bodies.items():
            assert self._base_version_warnings(_validate(client_with_agent, biz, body)) == [], name


# --- Install clash ----------------------------------------------------------


def _catalog_lists(mock_ws, *names):
    mock_ws.schemas.list.side_effect = lambda *a, **kw: iter(
        [SimpleNamespace(name=n) for n in ("_metamodel", "default", *names)]
    )


class TestInstallClash:
    """Existing schemas an install writes into that this business does not
    own there. Names follow ``services.schema_names.physical_schema_name``:
    5.3.3 stores ``database_name`` with its prefix (``ecm_sales``); one case
    keeps an older logical name (``sales``)."""

    def _seed(self, engine, *, other_owner: bool, ours_there: bool, suffix: str = "",
              db_name: str = "ecm_sales", scoped: bool = False, ours_files_only: bool = False):
        biz, ids = _ladder(engine)
        with Session(engine) as s:
            s.add(Domain(version_id=ids[3], name="sales", database_name=db_name))
            if scoped:
                v3 = s.get(ModelVersion, ids[3])
                v3.scope_fence_mode, v3.scope_base_version, v3.scope_base_scope = "domains", 2, "ecm"
                s.add(v3)
            if suffix:
                s.add(RunOperation(
                    run_id=_a_run(s, biz), step_index=0,
                    operation_name="vibe_iterate", status="succeeded", output_version_id=ids[3],
                    dispatched_widgets_json=json.dumps({"schema_prefix": "ecm_", "schema_suffix": suffix}),
                ))
            if other_owner:
                other = Business(name="Other Co", description="d")
                s.add(other)
                s.flush()
                omv = ModelVersion(business_id=other.id, version=1, scope="ecm", status="completed",
                                   deployment_status="deployed", uc_catalog="sandbox_cat",
                                   files_catalog="sandbox_cat")
                s.add(omv)
                s.flush()
                s.add(Domain(version_id=omv.id, name="sales", database_name="ecm_sales"))
            if ours_there or ours_files_only:
                # v7 was installed in sandbox_cat before (a closed install
                # row), or only has its files and seeded rows there.
                v7 = s.get(ModelVersion, ids[7])
                v7.files_catalog = "sandbox_cat"
                v7.status = "superseded"
                s.add(v7)
                s.add(Domain(version_id=ids[7], name="sales", database_name="ecm_sales"))
                if ours_there:
                    now = datetime.now(timezone.utc)
                    s.add(ModelVersionInstall(version_id=ids[7], catalog="sandbox_cat",
                                              installed_at=now, uninstalled_at=now))
            s.commit()
        return biz, ids

    def _confirms(self, client, biz, ids, **extra):
        return _confirms(_validate(client, biz, _install_body(ids[3], catalog="sandbox_cat", **extra)))

    def test_another_business_holds_the_schema(self, engine, client_with_agent, mock_ws):
        """Review 3 probe: the real 5.3.3 ``ecm_sales`` of Other Co is found;
        an unscoped install is asked, not refused."""
        biz, ids = self._seed(engine, other_owner=True, ours_there=False)
        _catalog_lists(mock_ws, "ecm_sales")
        _ws_with_run_now(mock_ws)
        body = _install_body(ids[3], catalog="sandbox_cat")
        out = _validate(client_with_agent, biz, body)
        assert out["blockers"] == []
        subject = install_overwrites_subject(ids[3], "sandbox_cat")
        confirms = [c for c in _confirms(out) if c["subject"] == subject]
        assert len(confirms) == 1
        assert "ecm_sales (owned by Other Co)" in confirms[0]["message"]
        assert "CREATE OR REPLACE TABLE" in confirms[0]["message"]

        r = client_with_agent.post(f"/api/businesses/{biz}/runs", json=body)
        assert r.status_code == 422, r.text
        assert subject in {i["subject"] for i in r.json()["detail"]["issues"]}
        assert _runs(engine, biz) == []

        body["confirmed_issues"] = [c["subject"] for c in _confirms(out)]
        r = client_with_agent.post(f"/api/businesses/{biz}/runs", json=body)
        assert r.status_code == 200, r.text

    def test_a_schema_both_own_is_asked(self, engine, client_with_agent, mock_ws):
        biz, ids = self._seed(engine, other_owner=True, ours_there=True)
        _catalog_lists(mock_ws, "ecm_sales")
        messages = [c["message"] for c in self._confirms(client_with_agent, biz, ids)]
        assert any("ecm_sales (owned by Other Co and by this business)" in m for m in messages)

    def test_an_unowned_schema_is_asked(self, engine, client_with_agent, mock_ws):
        biz, ids = self._seed(engine, other_owner=False, ours_there=False)
        _catalog_lists(mock_ws, "ecm_sales")
        messages = [c["message"] for c in self._confirms(client_with_agent, biz, ids)]
        assert any("ecm_sales (not recorded by any business)" in m for m in messages)

    def test_this_models_own_schema_is_no_clash(self, engine, client_with_agent, mock_ws):
        biz, ids = self._seed(engine, other_owner=False, ours_there=True)
        _catalog_lists(mock_ws, "ecm_sales")
        _ws_with_run_now(mock_ws)
        body = _install_body(ids[3], catalog="sandbox_cat")
        out = _validate(client_with_agent, biz, body)
        assert out["blockers"] == [] and _confirms(out) == []
        r = client_with_agent.post(f"/api/businesses/{biz}/runs", json=body)
        assert r.status_code == 200, r.text

    def test_a_version_with_only_files_there_owns_nothing(self, engine, client_with_agent, mock_ws):
        """9b: a version whose files and seeded registry rows are in the
        catalog, never installed there, is no owner (its seed is ``dry_run``,
        which the agent's ownership snapshot skips, nb 7926-7927)."""
        biz, ids = self._seed(engine, other_owner=False, ours_there=False, ours_files_only=True)
        _catalog_lists(mock_ws, "ecm_sales")
        messages = [c["message"] for c in self._confirms(client_with_agent, biz, ids)]
        assert any("ecm_sales (not recorded by any business)" in m for m in messages)

    def test_another_business_with_only_files_there_owns_nothing(self, engine, client_with_agent, mock_ws):
        biz, ids = self._seed(engine, other_owner=True, ours_there=True)
        with Session(engine) as s:
            other = s.exec(select(ModelVersion).where(ModelVersion.business_id != biz)).one()
            other.deployment_status, other.uc_catalog = "draft", ""
            s.add(other)
            s.commit()
        _catalog_lists(mock_ws, "ecm_sales")
        _ws_with_run_now(mock_ws)
        out = _validate(client_with_agent, biz, _install_body(ids[3], catalog="sandbox_cat"))
        assert out["blockers"] == [] and _confirms(out) == []

    def test_without_a_typed_prefix_the_versions_own_names_are_written(
        self, engine, client_with_agent, mock_ws,
    ):
        """No prefix in the request and no recorded install; the version was
        generated with ``acme_``: the install sends it, the stored names
        carry it, so it writes ``acme_sales`` and not ``ecm_sales``."""
        biz, ids = self._seed(engine, other_owner=True, ours_there=False, db_name="acme_sales")
        with Session(engine) as s:
            s.add(RunOperation(
                run_id=_a_run(s, biz), step_index=0, operation_name="vibe_iterate", status="succeeded",
                output_version_id=ids[3], dispatched_widgets_json=json.dumps({"schema_prefix": "acme_"}),
            ))
            s.commit()
        _catalog_lists(mock_ws, "ecm_sales")
        assert self._confirms(client_with_agent, biz, ids) == []
        _catalog_lists(mock_ws, "acme_sales")
        messages = [c["message"] for c in self._confirms(client_with_agent, biz, ids)]
        assert any("acme_sales (not recorded by any business)" in m for m in messages)

    def test_a_bare_legacy_name_is_not_what_the_install_writes(self, engine, client_with_agent, mock_ws):
        """Probe B: only another model's bare ``sales`` exists; the install
        writes ``ecm_sales``."""
        biz, ids = self._seed(engine, other_owner=True, ours_there=False)
        _catalog_lists(mock_ws, "sales")
        assert self._confirms(client_with_agent, biz, ids) == []

    def test_an_ordinary_install_sends_no_suffix(self, engine, client_with_agent, mock_ws):
        """Generation was dispatched ``_wt``, but an ordinary install sends
        no ``schema_suffix`` (``effective_install_params``), so the agent
        writes ``ecm_sales``: the generation suffix is not in
        ``database_name`` (nb 81765-81782)."""
        biz, ids = self._seed(engine, other_owner=False, ours_there=False, suffix="_wt")
        _catalog_lists(mock_ws, "ecm_sales_wt")
        assert self._confirms(client_with_agent, biz, ids) == []
        _catalog_lists(mock_ws, "ecm_sales")
        messages = [c["message"] for c in self._confirms(client_with_agent, biz, ids)]
        assert any("ecm_sales (not recorded by any business)" in m for m in messages)

    def test_a_scoped_file_keeps_its_suffix(self, engine, client_with_agent, mock_ws):
        """A ``_vibe_scope`` file is installed with its own conventions, so
        its generation suffix is deployed."""
        biz, ids = self._seed(engine, other_owner=False, ours_there=False, suffix="_wt", scoped=True)
        _catalog_lists(mock_ws, "ecm_sales_wt")
        blockers = _validate(client_with_agent, biz, _install_body(ids[3], catalog="sandbox_cat"))["blockers"]
        assert "ecm_sales_wt (not recorded by any business)" in blockers[0]["message"]

    def test_another_prefix_than_the_files_is_refused(self, engine, client_with_agent, mock_ws):
        """Generated with ``acme_`` (stored ``acme_sales``, the file says
        ``acme_``), the user types ``ecm_``: the agent would rebuild the names
        (nb 103545-103576) and drop the metric views, so validate refuses it;
        the clash check predicts the stored names."""
        biz, ids = self._seed(engine, other_owner=True, ours_there=False, db_name="acme_sales")
        TestUnprefixedDraftInstall._serve_file(mock_ws, "acme_")
        _catalog_lists(mock_ws, "ecm_sales", "acme_sales")
        out = _validate(client_with_agent, biz, _install_body(ids[3], catalog="sandbox_cat", schema_prefix="ecm_"))
        assert [b["message"] for b in out["blockers"]] == [
            "This version's model file uses the schema prefix 'acme_'. Installing with 'ecm_' renames "
            "its schemas and the agent drops its metric views. Leave Schema Prefix empty."
        ]
        messages = [c["message"] for c in _confirms(out)]
        assert any("acme_sales (not recorded by any business)" in m for m in messages)
        assert not any("ecm_sales" in m for m in messages)

    def test_a_dry_run_draft_owns_nothing(self, engine, client_with_agent, mock_ws):
        """Review 4 m3: this business's draft has files in the catalog; it
        deployed nothing, so the schema is still unrecorded."""
        biz, ids = self._seed(engine, other_owner=False, ours_there=False)
        with Session(engine) as s:
            v6 = s.get(ModelVersion, ids[6])
            v6.files_catalog = "sandbox_cat"
            s.add(v6)
            s.add(Domain(version_id=ids[6], name="sales", database_name="ecm_sales"))
            s.commit()
        _catalog_lists(mock_ws, "ecm_sales")
        messages = [c["message"] for c in self._confirms(client_with_agent, biz, ids)]
        assert any("ecm_sales (not recorded by any business)" in m for m in messages)

    def test_a_scoped_install_over_its_installed_base_is_no_clash(self, engine, client_with_agent, mock_ws):
        """The agent's base_match path: the installed base owns the schemas."""
        biz, ids = self._seed(engine, other_owner=False, ours_there=False, scoped=True)
        with Session(engine) as s:
            v5 = s.get(ModelVersion, ids[5])
            v5.uc_catalog = v5.files_catalog = "sandbox_cat"
            s.add(v5)
            s.add(Domain(version_id=ids[5], name="sales", database_name="ecm_sales"))
            s.commit()
        _catalog_lists(mock_ws, "ecm_sales")
        out = _validate(client_with_agent, biz, _install_body(ids[3], catalog="sandbox_cat"))
        assert not [b for b in out["blockers"] if b["field_path"] == "catalog"]

    def test_a_scoped_install_is_refused_as_the_agent_refuses(self, engine, client_with_agent, mock_ws):
        """A ``_vibe_scope`` file runs the agent's ownership gate, which
        counts neither Dry Run drafts nor the installed version itself."""
        biz, ids = self._seed(engine, other_owner=False, ours_there=False, scoped=True)
        with Session(engine) as s:
            v6 = s.get(ModelVersion, ids[6])
            v6.files_catalog = "sandbox_cat"
            s.add(v6)
            s.add(Domain(version_id=ids[6], name="sales", database_name="ecm_sales"))
            v3 = s.get(ModelVersion, ids[3])
            v3.files_catalog = "sandbox_cat"
            s.add(v3)
            s.commit()
        _catalog_lists(mock_ws, "ecm_sales")
        body = _install_body(ids[3], catalog="sandbox_cat")
        blockers = _validate(client_with_agent, biz, body)["blockers"]
        assert [b["field_path"] for b in blockers] == ["catalog"]
        assert blockers[0]["message"].startswith("The agent refuses this install")
        assert "ecm_sales (not recorded by any business)" in blockers[0]["message"]
        r = client_with_agent.post(f"/api/businesses/{biz}/runs", json=body)
        assert r.status_code == 400, r.text

    def test_a_free_catalog_is_no_clash(self, engine, client_with_agent, mock_ws):
        biz, ids = self._seed(engine, other_owner=True, ours_there=False)
        _catalog_lists(mock_ws, "unrelated")
        assert self._confirms(client_with_agent, biz, ids) == []



class TestUnprefixedDraftInstall:
    """E-12: a kickstarted business (agriculture domains ``crop``/``land``,
    lakehouse-industry-data-models data-models/agriculture/v1/mvm) whose v2
    a vibe deployed with prefix "" (T2 run C, j8_dispatch_c.json) and no
    install record. Its Dry Run draft v3 installs into the same catalog."""

    def _seed(self, engine):
        with Session(engine) as s:
            b = Business(name="WT Kick", description="d", industry_alignment="Agriculture")
            s.add(b)
            s.flush()
            v2 = ModelVersion(business_id=b.id, version=2, scope="mvm", status="completed",
                              deployment_status="deployed", uc_catalog="business_1",
                              files_catalog="business_1")
            s.add(v2)
            s.flush()
            v3 = ModelVersion(business_id=b.id, version=3, scope="mvm", status="draft", dry_run=True,
                              deployment_status="draft", uc_catalog="business_1",
                              files_catalog="business_1", base_version_id=v2.id)
            s.add(v3)
            s.flush()
            for mv in (v2, v3):
                for name in ("crop", "land"):
                    s.add(Domain(version_id=mv.id, name=name, database_name=name))
            s.add(RunOperation(
                run_id=_a_run(s, b.id), step_index=0, operation_name="vibe_iterate",
                status="succeeded", output_version_id=v2.id,
                dispatched_widgets_json=json.dumps({
                    "cataloging_style": "One Catalog", "deployment_catalog": "business_1",
                    "schema_prefix": "", "schema_suffix": "",
                }),
            ))
            s.commit()
            return b.id, v3.id

    def test_its_own_schemas_are_no_clash(self, engine, client_with_agent, mock_ws):
        biz, v3 = self._seed(engine)
        _catalog_lists(mock_ws, "crop", "land")
        _ws_with_run_now(mock_ws)
        body = _install_body(v3, scope="mvm", catalog="business_1")
        out = _validate(client_with_agent, biz, body)
        issues = out["blockers"] + out["warnings"]
        assert not [i for i in issues if "not recorded by any business" in i["message"]], issues
        assert not [i for i in issues if "crop (" in i["message"] or "land (" in i["message"]], issues
        assert out["blockers"] == []
        body["confirmed_issues"] = [c["subject"] for c in _confirms(out)]
        r = client_with_agent.post(f"/api/businesses/{biz}/runs", json=body)
        assert r.status_code == 200, r.text

    def _seed_v1(self, engine):
        """An unprefixed v1 shaped as ``industry_kickstart`` phase 0 creates
        one (completed, deployment_status ``draft``, files in the metamodel
        catalog, not a Dry Run, no scope block, never installed), with the
        industry's blank prefix and bare names (a downloaded industry, or a
        copy made before kickstart prefixed it)."""
        with Session(engine) as s:
            b = Business(name="WT Kick", description="d", industry_alignment="Agriculture")
            s.add(b)
            s.flush()
            v1 = ModelVersion(business_id=b.id, version=1, scope="mvm", status="completed",
                              deployment_status="draft", files_catalog="business_1")
            s.add(v1)
            s.flush()
            for name in ("crop", "land"):
                s.add(Domain(version_id=v1.id, name=name, database_name=name))
            s.commit()
            return b.id, v1.id

    @staticmethod
    def _serve_file(mock_ws, prefix):
        import io

        root = {"model": {"model_conventions": {
            "data_asset_naming_convention": "snake_case", "primary_key_suffix": "_id",
            "schema_prefix": prefix, "schema_suffix": "", "tag_prefix": "dbx_", "table_id_type": "BIGINT",
        }, "domains": []}}
        mock_ws.files.download.side_effect = lambda path: SimpleNamespace(
            contents=io.BytesIO(json.dumps(root).encode()))

    def _install_op(self, engine, run_id):
        with Session(engine) as s:
            return s.exec(select(RunOperation).where(
                RunOperation.run_id == run_id, RunOperation.operation_name == "install")).one()

    def test_a_blank_file_prefix_is_sent(self, engine, client_with_agent, mock_ws):
        """A seed version from before 0.9.0 (its file unprefixed): the file
        decides."""
        biz, v1 = self._seed_v1(engine)
        _catalog_lists(mock_ws)
        _ws_with_run_now(mock_ws)
        self._serve_file(mock_ws, "")
        r = client_with_agent.post(f"/api/businesses/{biz}/runs",
                                   json=_install_body(v1, scope="mvm", catalog="business_1"))
        assert r.status_code == 200, r.text
        op = self._install_op(engine, r.json()["id"])
        assert json.loads(op.dispatched_widgets_json)["schema_prefix"] == ""

    def test_a_typed_prefix_other_than_the_seed_files_is_refused(self, engine, client_with_agent, mock_ws):
        biz, v1 = self._seed_v1(engine)
        _catalog_lists(mock_ws)
        _ws_with_run_now(mock_ws)
        self._serve_file(mock_ws, "")
        r = client_with_agent.post(f"/api/businesses/{biz}/runs",
                                   json=_install_body(v1, scope="mvm", catalog="business_1", schema_prefix="mvm_"))
        assert r.status_code == 400, r.text
        assert "uses no schema prefix. Installing with 'mvm_'" in r.text
        assert _runs(engine, biz) == []
        mock_ws.jobs.run_now.assert_not_called()

    def test_a_typed_blank_is_refused_for_the_seed_version(self, engine, client_with_agent, mock_ws):
        biz, v1 = self._seed_v1(engine)
        _catalog_lists(mock_ws)
        _ws_with_run_now(mock_ws)
        r = client_with_agent.post(f"/api/businesses/{biz}/runs",
                                   json=_install_body(v1, scope="mvm", catalog="business_1", schema_prefix=""))
        assert r.status_code == 400, r.text
        assert _runs(engine, biz) == []
        mock_ws.jobs.run_now.assert_not_called()

    def test_a_typed_blank_prefix_is_still_refused(self, engine, client_with_agent, mock_ws):
        biz, v3 = self._seed(engine)
        _catalog_lists(mock_ws)
        _ws_with_run_now(mock_ws)
        r = client_with_agent.post(
            f"/api/businesses/{biz}/runs",
            json=_install_body(v3, scope="mvm", catalog="business_1", schema_prefix=""),
        )
        assert r.status_code == 400, r.text
        assert "non-empty schema_prefix" in r.text
        assert [r_ for r_ in _runs(engine, biz) if r_.intent == "install"] == []
        mock_ws.jobs.run_now.assert_not_called()


def _a_run(s, biz):
    run = Run(business_id=biz, intent="vibe-iterate", status="completed")
    s.add(run)
    s.flush()
    return run.id


# --- The marker gate on the identity cache ------------------------------------


class TestMarkerGateCache:
    def _scoped(self, engine):
        biz, ids = _replaced_ladder(engine)
        with Session(engine) as s:
            for n in (4, 5):
                mv = s.get(ModelVersion, ids[n])
                mv.uc_catalog = mv.files_catalog = "other_cat"
                s.add(mv)
            s.commit()
        return biz, _vibe_body(ids[3], catalog="test_catalog", vibe_scope="some_domains",
                               vibe_scope_domains=["sales"])

    def test_validate_reports_the_cached_old_agent_like_create(
        self, engine, client_with_agent, mock_ws, monkeypatch,
    ):
        biz, body = self._scoped(engine)
        _seed_identity(engine, "4.9.9")
        calls = _patch_export(monkeypatch)
        blockers = [b for b in _validate(client_with_agent, biz, body)["blockers"]
                    if b["field_path"] == "vibe_scope_agent"]
        assert len(blockers) == 1 and "reports 4.9.9" in blockers[0]["message"]
        r = client_with_agent.post(f"/api/businesses/{biz}/runs", json=body)
        assert r.status_code == 422, r.text
        assert r.json()["detail"] == blockers[0]["message"]
        assert calls == []

    def test_no_identity_yet_validate_waits_create_reads_once(
        self, engine, client_with_agent, mock_ws, monkeypatch,
    ):
        biz, body = self._scoped(engine)
        with Session(engine) as s:
            cfg = s.exec(select(AgentConfig)).first()
            cfg.installed_agent_version = cfg.installed_release_version = None
            cfg.installed_checked_path = cfg.installed_checked_at = None
            s.add(cfg)
            s.commit()
        calls = _patch_export(monkeypatch, marker="5.3.3")
        _ws_with_run_now(mock_ws)
        out = _validate(client_with_agent, biz, body)
        assert not [b for b in out["blockers"] if b["field_path"] == "vibe_scope_agent"]
        assert calls == []
        r = client_with_agent.post(f"/api/businesses/{biz}/runs", json=body)
        assert r.status_code == 200, r.text
        assert calls == ["/Workspace/test/notebook"]
        with Session(engine) as s:
            assert s.exec(select(AgentConfig)).first().installed_agent_version == "5.3.3"

    def test_installing_a_dry_run_draft_needs_the_marker(self, engine, client_with_agent, mock_ws):
        biz, ids = _ladder(engine)
        _seed_identity(engine, "4.9.9")
        body = _install_body(ids[6], catalog="test_catalog")
        blockers = [b for b in _validate(client_with_agent, biz, body)["blockers"]
                    if b["field_path"] == "vibe_scope_agent"]
        assert [b["message"] for b in blockers] == [
            "Needs agent 5.3.3. Switch to the bundled agent in Settings."
        ]
        r = client_with_agent.post(f"/api/businesses/{biz}/runs", json=body)
        assert r.status_code == 422, r.text
        assert r.json()["detail"] == blockers[0]["message"]


# --- D3: next-vibe selections through the orchestrator ------------------------


@pytest.fixture
def vibe_iterate_registered():
    """``conftest._ensure_operations_registry`` does not re-register
    ``vibe_iterate`` after a module resets the registry."""
    from vibe_modeling.backend.services.operations import register
    from vibe_modeling.backend.services.operations.vibe_iterate import VibeIterate

    try:
        register(VibeIterate())
    except ValueError:
        pass


@pytest.mark.usefixtures("vibe_iterate_registered")
class TestNextVibesThroughTheOrchestrator:
    def test_the_run_has_an_op_row_links_and_a_report(self, engine, client_with_agent, mock_ws, seed_business):
        _ws_with_run_now(mock_ws)
        version_id, nv_ids = seed_version_with_next_vibe_inputs(engine, seed_business)
        r = client_with_agent.post(f"/api/businesses/{seed_business}/runs", json={
            "intent": "vibe-iterate",
            "version_id": version_id,
            "catalog": "test_catalog",
            "vibe_instructions": "existing instructions",
            "next_vibe_ids": nv_ids[:2],
        })
        assert r.status_code == 200, r.text
        run_id = r.json()["id"]
        ops = _ops(engine, run_id)
        assert [(op.operation_name, op.parent_version_id) for op in ops] == [("vibe_iterate", version_id)]
        with Session(engine) as s:
            links = s.exec(select(RunNextVibeLink).where(RunNextVibeLink.run_id == run_id)).all()
            assert sorted(link.next_vibe_id for link in links) == sorted(nv_ids[:2])
        report = client_with_agent.get(f"/api/businesses/{seed_business}/runs/{run_id}/report")
        assert report.status_code == 200, report.text
        assert report.json()["run_id"] == run_id

    def test_unknown_next_vibe_id_is_a_400_with_no_run(self, engine, client_with_agent, mock_ws, seed_business):
        _ws_with_run_now(mock_ws)
        version_id, _ = seed_version_with_next_vibe_inputs(engine, seed_business)
        r = client_with_agent.post(f"/api/businesses/{seed_business}/runs", json={
            "intent": "vibe-iterate", "version_id": version_id, "catalog": "test_catalog",
            "vibe_instructions": "x", "next_vibe_ids": ["nv-999"],
        })
        assert r.status_code == 400, r.text
        assert _runs(engine, seed_business) == []
        mock_ws.jobs.run_now.assert_not_called()


# --- X10: run delete removes its instruction files ----------------------------


def _file(catalog, segment, sid):
    return f"/Volumes/{catalog}/_metamodel/vol_root/business/{segment}/_vibe_inputs/{sid}.txt"


class TestDeleteRunFiles:
    def _seed(self, engine, biz):
        from vibe_modeling.backend.core._names import agent_business_segment

        with Session(engine) as s:
            seg = agent_business_segment(s.get(Business, biz).name)
            own_legacy, own_step = _file("cat_a", seg, "s1"), _file("cat_b", seg, "s2")
            other_biz = _file("cat_b", "someone_else", "s3")
            typed = _file("cat_b", seg, "typed")
            run = Run(business_id=biz, intent="vibe-iterate", status="failed",
                      vibe_instructions_volume_path=own_legacy, vibe_instructions_text="long text")
            s.add(run)
            s.flush()
            s.add(RunOperation(run_id=run.id, step_index=0, operation_name="vibe_iterate", status="failed",
                               params_json=json.dumps({"vibe_instructions": "long text"}),
                               dispatched_widgets_json=json.dumps({"model_vibes": own_step})))
            s.add(RunOperation(run_id=run.id, step_index=1, operation_name="vibe_iterate", status="failed",
                               params_json=json.dumps({"vibe_instructions": "x"}),
                               dispatched_widgets_json=json.dumps({"model_vibes": other_biz})))
            # Short instructions travel inline: a typed path is text, not a file.
            s.add(RunOperation(run_id=run.id, step_index=2, operation_name="vibe_iterate", status="failed",
                               params_json=json.dumps({"vibe_instructions": typed}),
                               dispatched_widgets_json=json.dumps({"model_vibes": typed})))
            s.add(RunOperation(run_id=run.id, step_index=3, operation_name="install", status="pending",
                               dispatched_widgets_json=json.dumps({"model_vibes": "/Volumes/x/y/z.txt"})))
            s.commit()
            return run.id, [own_legacy, own_step]

    def test_the_files_go_after_the_commit(self, engine, client, mock_ws, seed_business):
        run_id, own = self._seed(engine, seed_business)
        r = client.delete(f"/api/businesses/{seed_business}/runs/{run_id}")
        assert r.status_code == 200, r.text
        deleted = sorted(c.args[0] for c in mock_ws.files.delete.call_args_list)
        assert deleted == sorted(own)
        with Session(engine) as s:
            assert s.get(Run, run_id) is None

    def test_a_failed_file_delete_never_fails_the_run_delete(self, engine, client, mock_ws, seed_business):
        run_id, _ = self._seed(engine, seed_business)
        mock_ws.files.delete.side_effect = RuntimeError("no WRITE FILES")
        r = client.delete(f"/api/businesses/{seed_business}/runs/{run_id}")
        assert r.status_code == 200, r.text
        assert mock_ws.files.delete.call_count == 2
        with Session(engine) as s:
            assert s.get(Run, run_id) is None

    def test_a_refused_delete_touches_no_file(self, engine, client, mock_ws, seed_business):
        with Session(engine) as s:
            run = Run(business_id=seed_business, intent="vibe-iterate", status="running",
                      vibe_instructions_volume_path=_file("cat_a", "seed", "s1"))
            s.add(run)
            s.commit()
            run_id = run.id
        r = client.delete(f"/api/businesses/{seed_business}/runs/{run_id}")
        assert r.status_code == 400, r.text
        mock_ws.files.delete.assert_not_called()


# --- Retired intents are unrecognized ------------------------------------------


def _intent_error(r):
    """The 422 body's error of the ``intent`` field, without the echoed input."""
    errors = [e for e in r.json()["detail"] if e["loc"] == ["body", "intent"]]
    assert len(errors) == 1, r.text
    return {k: v for k, v in errors[0].items() if k != "input"}


class TestRetiredIntents:
    """Generate Samples and Revert are no longer started: ``RunIn`` refuses
    them like any unknown value. Their enum values stay for old run rows."""

    @pytest.mark.parametrize("intent", ["generate-samples", "revert", "popcorn"])
    def test_create_and_validate_say_the_intent_is_not_recognized(
        self, engine, client_with_agent, mock_ws, intent,
    ):
        biz, ids = _ladder(engine)
        body = {"intent": intent, "version_id": ids[5]}
        before = _runs(engine, biz)
        popcorn = client_with_agent.post(
            f"/api/businesses/{biz}/runs/validate", json={"intent": "popcorn"}
        )
        for url in (f"/api/businesses/{biz}/runs/validate", f"/api/businesses/{biz}/runs"):
            r = client_with_agent.post(url, json=body)
            assert r.status_code == 422, r.text
            err = _intent_error(r)
            assert "intent not recognized" in err["msg"]
            assert err == _intent_error(popcorn)
        assert _runs(engine, biz) == before == []
        mock_ws.jobs.run_now.assert_not_called()

    @pytest.mark.parametrize("intent", ["generate-samples", "revert"])
    @pytest.mark.parametrize("route", ["retry", "resume"])
    def test_an_old_run_is_not_dispatched_again(self, engine, client_with_agent, mock_ws, route, intent):
        biz, ids = _ladder(engine)
        with Session(engine) as s:
            run = Run(business_id=biz, intent=intent, status="failed", version_id=ids[5])
            s.add(run)
            s.flush()
            s.add(RunOperation(run_id=run.id, step_index=0, operation_name=intent.replace("-", "_"), status="failed"))
            s.commit()
            run_id = run.id
        r = client_with_agent.post(f"/api/businesses/{biz}/runs/{run_id}/{route}")
        assert r.status_code == 422, r.text
        assert r.json()["detail"] == "This run's type is no longer supported."
        with Session(engine) as s:
            assert s.get(Run, run_id).status == "failed"
        mock_ws.jobs.run_now.assert_not_called()


# --- Validate and create return the same issues -------------------------------


def _state_install_free(engine, mock_ws):
    biz, ids = _ladder(engine)
    return biz, _install_body(ids[3], catalog="sandbox_cat")


def _state_install_occupied(engine, mock_ws):
    biz, ids = _ladder(engine)
    return biz, _install_body(ids[3], catalog="test_catalog")


def _state_install_confirmed(engine, mock_ws):
    biz, ids = _ladder(engine)
    return biz, _install_body(ids[3], catalog="test_catalog", confirmed_issues=[
        install_over_newer_subject(ids[5]), install_replaces_subject(ids[5]),
    ])


def _state_install_no_catalog(engine, mock_ws):
    biz, ids = _ladder(engine)
    return biz, _install_body(ids[3])


def _state_install_overwrite_confirmed(engine, mock_ws):
    biz, ids = TestInstallClash()._seed(engine, other_owner=True, ours_there=False)
    _catalog_lists(mock_ws, "ecm_sales")
    return biz, _install_body(ids[3], catalog="sandbox_cat",
                              confirmed_issues=[install_overwrites_subject(ids[3], "sandbox_cat")])


def _state_scoped_install_clash(engine, mock_ws):
    biz, ids = TestInstallClash()._seed(engine, other_owner=True, ours_there=False, scoped=True)
    _catalog_lists(mock_ws, "ecm_sales")
    return biz, _install_body(ids[3], catalog="sandbox_cat")


def _state_install_clash(engine, mock_ws):
    biz, ids = TestInstallClash()._seed(engine, other_owner=True, ours_there=False)
    _catalog_lists(mock_ws, "ecm_sales")
    return biz, _install_body(ids[3], catalog="sandbox_cat")


def _state_draft_old_agent(engine, mock_ws):
    biz, ids = _ladder(engine)
    _seed_identity(engine, "4.9.9")
    return biz, _install_body(ids[6], catalog="test_catalog")


def _state_uninstall_with_rows(engine, mock_ws):
    biz, ids = _ladder(engine)
    return biz, _uninstall_body(ids[5])


def _state_vibe_wrong_catalog(engine, mock_ws):
    biz, ids = _ladder(engine)
    return biz, _vibe_body(ids[5], catalog="legacy_cat")


def _state_scoped_replaced(engine, mock_ws):
    biz, ids = _replaced_ladder(engine)
    _seed_identity(engine, "5.3.3")
    return biz, _vibe_body(ids[3], catalog="test_catalog", vibe_scope="some_domains",
                           vibe_scope_domains=["sales"])


def _state_vibe_ok(engine, mock_ws):
    biz, ids = _ladder(engine)
    return biz, _vibe_body(ids[5], catalog="test_catalog")


@pytest.mark.parametrize("build", [
    _state_install_free,
    _state_install_occupied,
    _state_install_confirmed,
    _state_install_no_catalog,
    _state_install_clash,
    _state_install_overwrite_confirmed,
    _state_scoped_install_clash,
    _state_draft_old_agent,
    _state_uninstall_with_rows,
    _state_vibe_wrong_catalog,
    _state_scoped_replaced,
    _state_vibe_ok,
])
def test_validate_and_create_agree(engine, client_with_agent, mock_ws, impact, build):
    biz, body = build(engine, mock_ws)
    _ws_with_run_now(mock_ws)
    out = _validate(client_with_agent, biz, body)
    confirmed = set(body.get("confirmed_issues", []))
    pending = [c for c in _confirms(out) if c["subject"] not in confirmed]

    r = client_with_agent.post(f"/api/businesses/{biz}/runs", json=body)
    if out["blockers"]:
        assert r.status_code in (400, 409, 422), r.text
        assert r.json()["detail"] == out["blockers"][0]["message"]
        assert _runs(engine, biz) == []
    elif pending:
        assert r.status_code == 422, r.text
        detail = r.json()["detail"]
        assert detail["error"] == "needs_confirmation"
        assert sorted((i["subject"], i["message"]) for i in detail["issues"]) == sorted(
            (c["subject"], c["message"]) for c in _confirms(out)
        )
        assert _runs(engine, biz) == []
    else:
        assert r.status_code == 200, r.text
        assert len(_runs(engine, biz)) == 1


# --- The parent-metamodel SQL gate never interpolates a non-identifier ------------


def test_a_catalog_that_is_not_an_identifier_never_reaches_sql(engine):
    """Review B1: the request's catalog is quoted through
    ``core._sql.safe_identifier``; anything else skips the gate."""
    from vibe_modeling.backend.services.orchestrator import preflight as preflight_mod
    from vibe_modeling.backend.models import RunIn

    with Session(engine) as s:
        cfg = AgentConfig(notebook_path="/x", deployment_catalog="home_cat", warehouse_id="wh")
        s.add(cfg)
        b = Business(name="Acme", description="d")
        s.add(b)
        s.flush()
        mv = ModelVersion(business_id=b.id, version=1, scope="ecm", status="completed")
        s.add(mv)
        s.commit()
        ws = MagicMock()
        data = RunIn(
            intent="vibe-iterate", version_id=mv.id, vibe_instructions="x",
            catalog="home_cat`.`_metamodel`.`business` WHERE 1=0 UNION ALL "
                    "SELECT COUNT(*) FROM `other_cat`.`secret`.`t` --",
        )
        assert preflight_mod._check_metamodel_parent_version_present(b.id, data, cfg, s, ws, live=True) is None
        ws.statement_execution.execute_statement.assert_not_called()

        data = RunIn(intent="vibe-iterate", version_id=mv.id, vibe_instructions="x", catalog="home_cat")
        preflight_mod._check_metamodel_parent_version_present(b.id, data, cfg, s, ws, live=True)
        statement = ws.statement_execution.execute_statement.call_args.kwargs["statement"]
        assert statement.startswith("SELECT COUNT(*) AS n FROM `home_cat`.`_metamodel`.`business` ")


# --- Install rows feed the reinstall warning and F6 (A2b) --------------------


def test_reinstall_into_a_second_install_catalog_warns(engine, client_with_agent, mock_ws):
    """v5 is installed in test_catalog and sandbox_cat (open install rows):
    an install into either warns that it is already deployed there."""
    from vibe_modeling.backend.db_models import ModelVersionInstall

    biz, ids = _ladder(engine)
    with Session(engine) as s:
        for catalog in ("test_catalog", "sandbox_cat"):
            s.add(ModelVersionInstall(version_id=ids[5], catalog=catalog,
                                      installed_at=datetime.now(timezone.utc)))
        s.commit()
    out = _validate(client_with_agent, biz, _install_body(ids[5], catalog="sandbox_cat"))
    assert any(
        w["field_path"] == "version_id" and "already recorded as deployed to sandbox_cat" in w["message"]
        for w in out["warnings"]
    )


def test_f6_compares_catalogs_in_any_case(engine, client_with_agent, mock_ws):
    biz, ids = _ladder(engine)
    body = _vibe_body(ids[5], catalog="TEST_CATALOG")
    assert not [b for b in _validate(client_with_agent, biz, body)["blockers"] if b["field_path"] == "catalog"]
