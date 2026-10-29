"""Version lifecycle through the routes.

* ``listVersions`` derives ``is_head`` and ``draft_state`` (B1 head rule).
* An install into a catalog another version holds is uninstall-then-install
  only once its subject is confirmed; unconfirmed, create refuses it with
  422 ``needs_confirmation``. An install that names no catalog targets the
  version's own (B3).
* Reconcile never marks a Dry Run draft deployed (B9).
* Deployment checks probe the install catalog, the files resolver prefers
  ``files_catalog``.
* ``_vibe_scope`` facts are stamped at sync and never overwritten with NULL
  (B8).
"""
from __future__ import annotations

import json
from datetime import datetime, timezone
from unittest.mock import MagicMock

from sqlmodel import Session, select

from vibe_modeling.backend.agent_compat import extract_vibe_scope_facts
from vibe_modeling.backend.services.orchestrator.validate import install_over_newer_subject, install_replaces_subject
from vibe_modeling.backend.services.uninstall_impact import uninstall_confirm_subject
from vibe_modeling.backend.core import (
    resolve_version_install_catalog,
    resolve_version_volume_catalog,
)
from vibe_modeling.backend.db_models import Business, ModelVersion, RunOperation
from vibe_modeling.backend.model_sync import ModelSyncService


def _ladder(engine, *, catalog="test_catalog"):
    """v3 superseded, v5 the head installed in ``catalog``, v6 a draft on v5
    and v7 a draft on v3. Returns (business_id, ids by number)."""
    with Session(engine) as s:
        b = Business(name="Life Co", description="d", industry_alignment="Retail")
        s.add(b)
        s.flush()
        ids: dict[int, str] = {}
        v3 = ModelVersion(business_id=b.id, version=3, scope="ecm", status="superseded",
                          deployment_status="uninstalled", uc_catalog=catalog, files_catalog=catalog)
        v5 = ModelVersion(business_id=b.id, version=5, scope="ecm", status="completed",
                          deployment_status="deployed", uc_catalog=catalog, files_catalog=catalog)
        s.add(v3)
        s.add(v5)
        s.flush()
        v6 = ModelVersion(business_id=b.id, version=6, scope="ecm", status="draft", dry_run=True,
                          deployment_status="draft", uc_catalog=catalog, files_catalog=catalog,
                          base_version_id=v5.id)
        v7 = ModelVersion(business_id=b.id, version=7, scope="ecm", status="draft", dry_run=True,
                          deployment_status="draft", uc_catalog=catalog, files_catalog=catalog,
                          base_version_id=v3.id)
        s.add(v6)
        s.add(v7)
        s.commit()
        for mv in (v3, v5, v6, v7):
            ids[mv.version] = mv.id
        return b.id, ids


class TestListVersions:
    def test_head_and_draft_state(self, engine, client):
        biz, ids = _ladder(engine)
        r = client.get(f"/api/businesses/{biz}/versions")
        assert r.status_code == 200, r.text
        rows = {row["version"]: row for row in r.json()}
        assert [n for n, row in rows.items() if row["is_head"]] == [5]
        assert rows[6]["draft_state"] == "ready"
        assert rows[7]["draft_state"] == "older_base"
        assert rows[3]["draft_state"] is None and rows[5]["draft_state"] is None
        assert rows[5]["files_catalog"] == "test_catalog"


def _ws_with_run_now(mock_ws, run_id=777):
    run = MagicMock()
    run.run_id = run_id
    mock_ws.jobs.run_now.return_value = run


def _install(client, biz, vid, **extra):
    body = {"intent": "install", "version_id": vid, "scope": "ecm", "cataloging_style": "One Catalog"}
    body.update(extra)
    return client.post(f"/api/businesses/{biz}/runs", json=body)


def _ops(engine, run_id):
    with Session(engine) as s:
        return list(s.exec(
            select(RunOperation).where(RunOperation.run_id == run_id).order_by(RunOperation.step_index)
        ).all())


class TestInstallRun:
    def test_unconfirmed_occupied_catalog_is_refused(self, engine, client_with_agent, mock_ws):
        """P0 item 4: an unconfirmed install into an occupied catalog is no
        longer dispatched as a plain install the agent refuses."""
        biz, ids = _ladder(engine)
        _ws_with_run_now(mock_ws)
        r = _install(client_with_agent, biz, ids[3], catalog="test_catalog")
        assert r.status_code == 422, r.text
        assert r.json()["detail"]["error"] == "needs_confirmation"
        mock_ws.jobs.run_now.assert_not_called()

    def test_confirmed_occupied_catalog_uninstalls_the_occupant_first(
        self, engine, client_with_agent, mock_ws,
    ):
        biz, ids = _ladder(engine)
        _ws_with_run_now(mock_ws)
        r = _install(
            client_with_agent, biz, ids[3], catalog="test_catalog",
            confirmed_issues=[install_replaces_subject(ids[5]), install_over_newer_subject(ids[5])],
        )
        assert r.status_code == 200, r.text
        ops = _ops(engine, r.json()["id"])
        assert [op.operation_name for op in ops] == ["uninstall", "install"]
        uninstall, install = (json.loads(op.params_json) for op in ops)
        assert uninstall["version_id"] == ids[5] and uninstall["model_version"] == 5
        assert install["version_id"] == ids[3] and install["model_version"] == 3
        assert ops[0].parent_version_id == ids[5]
        assert ops[1].parent_version_id == ids[3]

    def test_install_without_a_catalog_targets_the_versions_files(self, engine, client_with_agent, mock_ws):
        biz, ids = _ladder(engine, catalog="own_cat")
        _ws_with_run_now(mock_ws)
        r = _install(client_with_agent, biz, ids[3], confirmed_issues=[
            install_replaces_subject(ids[5]), install_over_newer_subject(ids[5]),
        ])
        assert r.status_code == 200, r.text
        params = json.loads(_ops(engine, r.json()["id"])[-1].params_json)
        assert params["deployment_catalog"] == "own_cat"


class TestReconcileGuard:
    def test_dry_run_draft_is_never_marked_deployed(self, engine, client, mock_ws, monkeypatch):
        biz, ids = _ladder(engine)
        from vibe_modeling.backend.routes import versions as versions_mod

        monkeypatch.setattr(
            versions_mod, "expected_schema_candidates_for_version", lambda *_a, **_k: [["ecm_sales"]],
        )
        monkeypatch.setattr(
            versions_mod, "resolve_expected_and_found_schemas",
            lambda *_a, **_k: (["ecm_sales"], ["ecm_sales"]),
        )
        r = client.post(f"/api/model-versions/{ids[6]}/reconcile-installation")
        assert r.status_code == 200, r.text
        assert r.json()["new_deployment_status"] == "draft"
        with Session(engine) as s:
            assert s.get(ModelVersion, ids[6]).deployment_status == "draft"


class TestCatalogResolvers:
    def test_files_catalog_wins_for_artifacts_install_catalog_for_checks(self, engine):
        with Session(engine) as s:
            mv = ModelVersion(business_id="b", version=1, scope="mvm", uc_catalog="base_mvm_v1",
                              files_catalog="meta", deployment_status="deployed")
            assert resolve_version_volume_catalog(mv, s) == "meta"
            assert resolve_version_install_catalog(mv, s) == "base_mvm_v1"

    def test_rows_without_files_catalog_keep_the_old_rule(self, engine):
        with Session(engine) as s:
            mv = ModelVersion(business_id="b", version=1, scope="mvm", uc_catalog="x")
            assert resolve_version_volume_catalog(mv, s) == "x"

    def test_deployment_check_probes_the_install_catalog(self, engine, client, monkeypatch):
        with Session(engine) as s:
            b = Business(name="Dep Co", description="d")
            s.add(b)
            s.flush()
            mv = ModelVersion(business_id=b.id, version=1, scope="ecm", status="completed",
                              deployment_status="deployed", uc_catalog="install_cat",
                              files_catalog="files_cat")
            s.add(mv)
            s.commit()
            biz, vid = b.id, mv.id
        seen: list[str] = []

        class _Verifier:
            def __init__(self, *_a, **_k):
                pass

            def check_catalog(self, catalog):
                seen.append(catalog)
                return {"exists": True, "catalog": catalog, "error": None, "verification_error": None}

        monkeypatch.setattr("vibe_modeling.backend.deployment_verifier.DeploymentVerifier", _Verifier)
        r = client.get(f"/api/businesses/{biz}/versions/{vid}/deployment/catalog-check")
        assert r.status_code == 200, r.text
        assert seen == ["install_cat"]


class TestVibeScopeFacts:
    def test_extract(self):
        assert extract_vibe_scope_facts(
            {"_vibe_scope": {"mode": "some_domains", "base_version": "4", "base_scope": "ECM"}}
        ) == ("some_domains", 4, "ecm")
        assert extract_vibe_scope_facts({"model": {"_vibe_scope": {"mode": "all"}}}) == (None, None, None)
        assert extract_vibe_scope_facts({"_vibe_scope": {"mode": "all", "base_version": None}}) == (
            "all", None, None,
        )

    def test_sync_stamps_facts_and_never_clears_them(self, engine):
        with Session(engine) as s:
            b = Business(name="Facts Co", description="d")
            s.add(b)
            s.flush()
            mv = ModelVersion(business_id=b.id, version=2, scope="ecm", status="completed")
            s.add(mv)
            s.commit()
            sync = ModelSyncService(s)
            payload = {"_vibe_scope": {"mode": "some_domains", "base_version": "1", "base_scope": "ecm"}}
            sync._capture_run_metadata(mv.id, "", "facts_co", "2", "ecm", payload)
            assert (mv.scope_fence_mode, mv.scope_base_version, mv.scope_base_scope) == (
                "some_domains", 1, "ecm",
            )
            sync._capture_run_metadata(mv.id, "", "facts_co", "2", "ecm", {"model": {}})
            assert mv.scope_fence_mode == "some_domains" and mv.scope_base_version == 1


# --- Flows ------------------------------------------------------------------

from vibe_modeling.backend import progress_tracker as pt  # noqa: E402
from vibe_modeling.backend.db_models import Run, RunInputLink, VibeInput  # noqa: E402


def _jobs_succeed(mock_ws):
    from ._lifecycle_fixtures import agent_exits_ok, model_json_readable

    agent_exits_ok(mock_ws)
    model_json_readable(mock_ws, "ecm_")
    _ws_with_run_now(mock_ws)
    job_run = MagicMock()
    job_run.state.life_cycle_state.value = "TERMINATED"
    job_run.state.result_state.value = "SUCCESS"
    job_run.state.state_message = ""
    mock_ws.jobs.get_run.return_value = job_run


def _drive_to_terminal(engine, mock_tracker, run_id):
    """What the tracker's advance tick does: advance until terminal, then the
    terminal commit (``_finalize_run_inputs``)."""
    from vibe_modeling.backend.services.orchestrator import AdvanceOutcome

    for _ in range(5):
        with Session(engine) as s:
            run = s.get(Run, run_id)
            outcome = mock_tracker.orchestrator.advance(run, s)
            if outcome in (AdvanceOutcome.TERMINAL_SUCCESS, AdvanceOutcome.TERMINAL_FAILED):
                pt._finalize_run_inputs(run_id, s, success=outcome == AdvanceOutcome.TERMINAL_SUCCESS)
                return outcome
            s.commit()
    raise AssertionError("install run did not finish")


def _with_feedback(engine, biz, ids):
    """v5's producing run consumed ``a``; v3's and v6's runs report ``b``
    applied (open). Returns the input ids."""
    with Session(engine) as s:
        a = VibeInput(business_id=biz, text="applied in v5")
        b = VibeInput(business_id=biz, text="applied in v3 and the v6 draft")
        s.add(a)
        s.add(b)
        s.flush()
        for n, consumed, applied in ((5, [a], []), (3, [], [b]), (6, [], [b])):
            run = Run(business_id=biz, intent="vibe-iterate", status="completed")
            s.add(run)
            s.flush()
            s.add(RunOperation(run_id=run.id, step_index=0, operation_name="vibe_iterate",
                               status="succeeded", output_version_id=ids[n],
                               completed_at=datetime.now(timezone.utc)))
            for vi in consumed:
                vi.consumed, vi.consumed_by_run_id = True, run.id
                s.add(vi)
            for vi in applied:
                s.add(RunInputLink(run_id=run.id, input_id=vi.id, outcome_status="applied"))
        s.commit()
        return a.id, b.id


class TestFlows:
    def test_dry_run_then_install(self, engine, client_with_agent, mock_ws, mock_tracker):
        """A draft on the head installed into the head's catalog: the head is
        the draft's base, not an occupant, so this is one install step (the
        agent's base_match path); the draft becomes current and evicts its
        base, its applied feedback is consumed by the install, and nothing is
        replaced."""
        biz, ids = _ladder(engine)
        a, b = _with_feedback(engine, biz, ids)
        with Session(engine) as s:
            v6 = s.get(ModelVersion, ids[6])
            v6.scope_fence_mode, v6.scope_base_version, v6.scope_base_scope = "all", 5, "ecm"
            s.add(v6)
            s.commit()
        _jobs_succeed(mock_ws)
        # Even a confirmation naming the base does not turn it into an
        # occupant: the base is installed over, not uninstalled.
        r = _install(
            client_with_agent, biz, ids[6], catalog="test_catalog",
            confirmed_issues=[install_replaces_subject(ids[5])],
        )
        assert r.status_code == 200, r.text
        run_id = r.json()["id"]
        assert [op.operation_name for op in _ops(engine, run_id)] == ["install"]
        assert _drive_to_terminal(engine, mock_tracker, run_id).name == "TERMINAL_SUCCESS"

        with Session(engine) as s:
            v5, v6 = s.get(ModelVersion, ids[5]), s.get(ModelVersion, ids[6])
            assert (v6.status, v6.deployment_status, v6.uc_catalog) == ("completed", "deployed", "test_catalog")
            assert v6.dry_run and v6.promoted_by_run_id == run_id
            assert (v5.status, v5.deployment_status, v5.replaced_at) == ("superseded", "uninstalled", None)
            assert s.get(VibeInput, b).consumed_by_run_id == run_id
            assert s.get(VibeInput, a).consumed is True
        rows = {row["version"]: row for row in client_with_agent.get(f"/api/businesses/{biz}/versions").json()}
        assert [n for n, row in rows.items() if row["is_head"]] == [6]

    def test_install_over_newer_then_delete_the_replaced_version(
        self, engine, client_with_agent, mock_ws, mock_tracker,
    ):
        """v3 installed over v5 in the same catalog: uninstall v5, install v3;
        v3 is the head, v5 is replaced, v5's feedback is open again (not
        selected), v3's is consumed; v5 can then be deleted."""
        biz, ids = _ladder(engine)
        a, b = _with_feedback(engine, biz, ids)
        _jobs_succeed(mock_ws)
        r = _install(
            client_with_agent, biz, ids[3], catalog="test_catalog",
            confirmed_issues=[install_replaces_subject(ids[5]), install_over_newer_subject(ids[5])],
        )
        assert r.status_code == 200, r.text
        run_id = r.json()["id"]
        assert _drive_to_terminal(engine, mock_tracker, run_id).name == "TERMINAL_SUCCESS"

        with Session(engine) as s:
            v3, v5 = s.get(ModelVersion, ids[3]), s.get(ModelVersion, ids[5])
            assert (v3.status, v3.deployment_status) == ("completed", "deployed")
            assert (v5.status, v5.deployment_status) == ("superseded", "uninstalled")
            assert v5.replaced_by_version_id == ids[3] and v5.replaced_at is not None
            reopened = s.get(VibeInput, a)
            assert (reopened.consumed, reopened.selected_for_run) == (False, False)
            assert s.get(VibeInput, b).consumed_by_run_id == run_id
            links = {l.input_id: l.outcome_status for l in s.exec(
                select(RunInputLink).where(RunInputLink.run_id == run_id))}
            assert links == {a: "reopened", b: "applied"}

        d = client_with_agent.delete(f"/api/businesses/{biz}/versions/{ids[5]}")
        assert d.status_code == 200, d.text
        rows = {row["version"]: row for row in client_with_agent.get(f"/api/businesses/{biz}/versions").json()}
        assert 5 not in rows and rows[3]["is_head"] is True

    def test_install_into_a_second_catalog_keeps_the_head(
        self, engine, client_with_agent, mock_ws, mock_tracker,
    ):
        biz, ids = _ladder(engine)
        _jobs_succeed(mock_ws)
        r = _install(client_with_agent, biz, ids[3], catalog="sandbox_cat")
        assert r.status_code == 200, r.text
        _drive_to_terminal(engine, mock_tracker, r.json()["id"])
        with Session(engine) as s:
            v3, v5 = s.get(ModelVersion, ids[3]), s.get(ModelVersion, ids[5])
            assert (v3.status, v3.deployment_status, v3.uc_catalog) == ("superseded", "deployed", "sandbox_cat")
            assert v3.files_catalog == "test_catalog"
            assert (v5.status, v5.deployment_status) == ("completed", "deployed")


class TestAlsoDeleteReplacedRole:
    def test_a_modeler_cannot_ask_an_install_to_delete(self, engine, client_with_agent, mock_ws):
        from vibe_modeling.backend.core._roles import UserRole, resolve_user_role

        biz, ids = _ladder(engine)
        _ws_with_run_now(mock_ws)
        client_with_agent.app.dependency_overrides[resolve_user_role] = lambda: UserRole.MODELER
        r = _install(client_with_agent, biz, ids[3], catalog="sandbox_cat", also_delete_replaced=True)
        assert r.status_code == 403, r.text
        with Session(engine) as s:
            assert s.exec(select(Run).where(Run.business_id == biz)).all() == []
        r = _install(client_with_agent, biz, ids[3], catalog="sandbox_cat")
        assert r.status_code == 200, r.text

    def test_a_business_admin_can(self, engine, client_with_agent, mock_ws):
        from vibe_modeling.backend.core._roles import UserRole, resolve_user_role

        biz, ids = _ladder(engine)
        _ws_with_run_now(mock_ws)
        client_with_agent.app.dependency_overrides[resolve_user_role] = lambda: UserRole.BUSINESS_ADMIN
        r = _install(client_with_agent, biz, ids[3], catalog="sandbox_cat", also_delete_replaced=True)
        assert r.status_code == 200, r.text


class TestUninstallTarget:
    def test_uninstall_without_a_catalog_targets_where_the_version_is_installed(
        self, engine, client_with_agent, mock_ws,
    ):
        biz, ids = _ladder(engine)
        with Session(engine) as s:
            v3 = s.get(ModelVersion, ids[3])
            v3.deployment_status, v3.uc_catalog = "deployed", "sandbox_cat"
            s.add(v3)
            s.commit()
        _ws_with_run_now(mock_ws)
        r = client_with_agent.post(f"/api/businesses/{biz}/runs", json={
            "intent": "uninstall", "version_id": ids[3], "scope": "ecm", "cataloging_style": "One Catalog",
            "confirmed_issues": [uninstall_confirm_subject(ids[3], "sandbox_cat")],
        })
        assert r.status_code == 200, r.text
        params = json.loads(_ops(engine, r.json()["id"])[0].params_json)
        assert params["deployment_catalog"] == "sandbox_cat"
        assert params["version_id"] == ids[3]


class TestRetryRole:
    def test_a_modeler_cannot_retry_an_install_that_deletes(self, engine, client_with_agent):
        from vibe_modeling.backend.core._roles import UserRole, resolve_user_role

        biz, ids = _ladder(engine)
        with Session(engine) as s:
            run = Run(business_id=biz, intent="install", status="failed",
                      parameters_json=json.dumps({"also_delete_replaced": True}))
            s.add(run)
            s.flush()
            s.add(RunOperation(run_id=run.id, step_index=0, operation_name="install", status="failed"))
            s.commit()
            run_id = run.id
        client_with_agent.app.dependency_overrides[resolve_user_role] = lambda: UserRole.MODELER
        r = client_with_agent.post(f"/api/businesses/{biz}/runs/{run_id}/retry")
        assert r.status_code == 403, r.text
        with Session(engine) as s:
            assert s.get(Run, run_id).status == "failed"


class TestVersionReport:
    def test_a_unified_runs_mvm_report_shows_its_producing_run(self, engine, client):
        biz, ids = _ladder(engine)
        with Session(engine) as s:
            mvm = ModelVersion(business_id=biz, version=5, scope="mvm", status="completed",
                               deployment_status="deployed", uc_catalog="test_catalog",
                               files_catalog="test_catalog")
            s.add(mvm)
            s.flush()
            run = Run(business_id=biz, intent="vibe-new-ecm-mvm", status="completed")
            s.add(run)
            s.flush()
            for i, (op, out) in enumerate((("vibe_iterate", ids[5]), ("shrink_to_mvm", mvm.id))):
                s.add(RunOperation(run_id=run.id, step_index=i, operation_name=op, status="succeeded",
                                   output_version_id=out, completed_at=datetime.now(timezone.utc)))
            s.commit()
            mvm_id, run_id = mvm.id, run.id
        r = client.get(f"/api/businesses/{biz}/versions/{mvm_id}/report")
        assert r.status_code == 200, r.text
        assert r.json()["report"]["run_id"] == run_id


class TestFailedInstallAfterUninstall:
    def test_the_uninstall_step_stays_succeeded(self, engine, client_with_agent, mock_ws, mock_tracker):
        """Uninstall-then-install whose install fails: the run fails, and the
        uninstall step keeps ``succeeded`` (its rollback undoes nothing and
        its effect stands in UC) instead of reading ``rolled_back`` (P0 F5)."""
        biz, ids = _ladder(engine)
        _ws_with_run_now(mock_ws)
        states = iter(["SUCCESS"])

        def get_run(_run_id):
            job_run = MagicMock()
            job_run.state.life_cycle_state.value = "TERMINATED"
            job_run.state.result_state.value = next(states, "FAILED")
            job_run.state.state_message = ""
            return job_run

        mock_ws.jobs.get_run.side_effect = get_run
        r = _install(
            client_with_agent, biz, ids[3], catalog="test_catalog",
            confirmed_issues=[install_replaces_subject(ids[5]), install_over_newer_subject(ids[5])],
        )
        assert r.status_code == 200, r.text
        assert _drive_to_terminal(engine, mock_tracker, r.json()["id"]).name == "TERMINAL_FAILED"
        ops = _ops(engine, r.json()["id"])
        assert [(op.operation_name, op.status) for op in ops] == [("uninstall", "succeeded"), ("install", "failed")]
        with Session(engine) as s:
            assert s.get(ModelVersion, ids[5]).deployment_status == "uninstalled"
            assert s.get(ModelVersion, ids[3]).deployment_status == "uninstalled"


class TestCancelAndRetryUninstallThenInstall:
    """Cancel with rollback while the install step runs: the uninstall step
    keeps ``succeeded`` (the runner's cancel loop skips an op whose rollback
    undoes nothing). A retry then dispatches the install only."""

    def test_cancel_keeps_the_uninstall_and_retry_redispatches_the_install(
        self, engine, client_with_agent, mock_ws, mock_tracker,
    ):
        from vibe_modeling.backend.services.orchestrator import AdvanceOutcome

        biz, ids = _ladder(engine)
        _jobs_succeed(mock_ws)
        state = {"rs": "SUCCESS", "lcs": "TERMINATED"}

        def get_run(_run_id):
            job_run = MagicMock()
            job_run.state.life_cycle_state.value = state["lcs"]
            job_run.state.result_state.value = state["rs"]
            job_run.state.state_message = ""
            return job_run

        mock_ws.jobs.get_run.side_effect = get_run
        r = _install(
            client_with_agent, biz, ids[3], catalog="test_catalog",
            confirmed_issues=[install_replaces_subject(ids[5]), install_over_newer_subject(ids[5])],
        )
        run_id = r.json()["id"]
        with Session(engine) as s:
            run = s.get(Run, run_id)
            state.update(lcs="TERMINATED", rs="SUCCESS")
            assert mock_tracker.orchestrator.advance(run, s) == AdvanceOutcome.ADVANCED
            s.commit()
        uninstall_dbx = _ops(engine, run_id)[0].databricks_run_id

        state.update(lcs="RUNNING", rs="")
        c = client_with_agent.post(f"/api/businesses/{biz}/runs/{run_id}/cancel-with-rollback")
        assert c.status_code == 200, c.text
        ops = _ops(engine, run_id)
        assert ops[0].status == "succeeded" and ops[1].status == "rolled_back"

        mock_ws.jobs.run_now.return_value.run_id = 999
        state.update(lcs="TERMINATED", rs="SUCCESS")
        retry = client_with_agent.post(f"/api/businesses/{biz}/runs/{run_id}/retry")
        assert retry.status_code == 200, retry.text
        ops = _ops(engine, run_id)
        assert ops[0].status == "succeeded" and ops[0].databricks_run_id == uninstall_dbx
        assert ops[1].status in ("running", "pending") and ops[1].databricks_run_id == 999
