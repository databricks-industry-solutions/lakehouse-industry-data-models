"""Version lifecycle (``services/operations/_version_lifecycle``).

Promotion of a Dry Run draft, an older version and a replaced version; the
dropped set and its ``replaced_*`` stamps (written and cleared); same-scope
eviction and its restore; the import/initial-sync eviction kept across
scopes; the head rule; reopen-then-consume; post-install deletes; the delete
service; the install confirm subjects.
"""
from __future__ import annotations

import json
from datetime import datetime, timezone
from typing import Optional

import pytest
from sqlmodel import Session, select

from vibe_modeling.backend.core._vibe_scope import scope_head, scoped_base_blocker
from vibe_modeling.backend.services.orchestrator.validate import install_over_newer_subject, install_replaces_subject
from vibe_modeling.backend.db_models import (
    Business,
    ModelVersion,
    Run,
    RunInputLink,
    RunOperation,
    RunPostInstallDelete,
    VibeInput,
)
from vibe_modeling.backend.services.operations import _version_lifecycle as lc
from vibe_modeling.backend.services.orchestrator.validate import install_confirm_issues, vibe_catalog_issues

CAT = "cat_a"
OTHER = "cat_b"


def _biz(session: Session, name: str = "Acme Co") -> Business:
    biz = Business(name=name, description="d")
    session.add(biz)
    session.flush()
    return biz


def _mv(
    session: Session,
    biz: Business,
    version: int,
    *,
    scope: str = "ecm",
    status: str = "superseded",
    deployment: str = "uninstalled",
    uc: str = CAT,
    files: Optional[str] = CAT,
    dry_run: bool = False,
    base: Optional[ModelVersion] = None,
    instructions: str = "",
) -> ModelVersion:
    mv = ModelVersion(
        business_id=biz.id, version=version, scope=scope, status=status,
        deployment_status=deployment, uc_catalog=uc, files_catalog=files,
        dry_run=dry_run, base_version_id=base.id if base else None,
        vibe_instructions=instructions,
    )
    session.add(mv)
    session.flush()
    return mv


def _ladder(session: Session):
    """v3 superseded, v4 superseded, v5 the head installed in CAT."""
    biz = _biz(session)
    v3 = _mv(session, biz, 3, instructions="add billing")
    v4 = _mv(session, biz, 4, base=v3, instructions="split orders")
    v5 = _mv(session, biz, 5, status="completed", deployment="deployed", base=v4, instructions="rename x")
    return biz, v3, v4, v5


def _producing_run(session: Session, biz: Business, mv: ModelVersion, applied: list[VibeInput] = (), consumed: list[VibeInput] = ()) -> Run:
    run = Run(business_id=biz.id, intent="vibe-iterate", status="completed")
    session.add(run)
    session.flush()
    session.add(RunOperation(
        run_id=run.id, step_index=0, operation_name="vibe_iterate", status="succeeded",
        output_version_id=mv.id, completed_at=datetime.now(timezone.utc),
    ))
    for vi in applied:
        session.add(RunInputLink(run_id=run.id, input_id=vi.id, outcome_status="applied"))
    for vi in consumed:
        vi.consumed = True
        vi.consumed_by_run_id = run.id
        session.add(vi)
    session.flush()
    return run


def _uninstall(
    session: Session, biz: Business, mv: ModelVersion, catalog: str, *, released: Optional[bool] = True,
) -> Run:
    """A succeeded uninstall step of ``mv`` from ``catalog`` (``Uninstall._finish``):
    the install row closes and the step records its registry release as done
    (``released``), pending (False), or not at all (None, an uninstall from
    before the release existed)."""
    run = Run(business_id=biz.id, intent="uninstall", status="completed")
    session.add(run)
    session.flush()
    state: dict = {}
    if released:
        state[lc.REGISTRY_RELEASED_KEY] = True
    elif released is False:
        state[lc.REGISTRY_RELEASE_PENDING_KEY] = {"catalog": catalog, "version_id": mv.id}
    session.add(RunOperation(
        run_id=run.id, step_index=0, operation_name="uninstall", status="succeeded",
        params_json=json.dumps({"version_id": mv.id, "deployment_catalog": catalog}),
        rollback_state_json=json.dumps(state),
    ))
    lc.mark_version_uninstalled(session, mv, catalog, run_id=run.id)
    session.flush()
    return run


def _input(session: Session, biz: Business, text: str, *, selected: bool = False) -> VibeInput:
    vi = VibeInput(business_id=biz.id, text=text, selected_for_run=selected)
    session.add(vi)
    session.flush()
    return vi


# --- Head -----------------------------------------------------------------


class TestHeadRule:
    def test_head_is_the_completed_row_not_the_highest_number(self, engine):
        with Session(engine) as s:
            biz, v3, v4, v5 = _ladder(s)
            v3.status, v5.status = "completed", "superseded"
            v5.replaced_at = datetime.now(timezone.utc)
            s.flush()
            assert scope_head(s, biz.id, "ecm").id == v3.id
            assert scoped_base_blocker(s, v3) is None

    def test_no_completed_row_no_head(self, engine):
        with Session(engine) as s:
            biz, v3, v4, v5 = _ladder(s)
            v5.status = "superseded"
            s.flush()
            assert scope_head(s, biz.id, "ecm") is None


# --- Eviction ---------------------------------------------------------------


class TestEviction:
    def test_same_scope_keeps_the_other_scope_installed(self, engine):
        with Session(engine) as s:
            biz = _biz(s)
            ecm = _mv(s, biz, 1, scope="ecm", status="completed", deployment="deployed")
            mvm_old = _mv(s, biz, 1, scope="mvm", status="superseded", deployment="deployed")
            mvm_new = _mv(s, biz, 2, scope="mvm", status="completed", deployment="deployed")
            evicted = lc.evict_deployed_siblings(s, mvm_new, same_scope=True)
            assert evicted == [mvm_old.id]
            assert ecm.deployment_status == "deployed"
            assert mvm_old.deployment_status == "uninstalled"
            lc.restore_evicted_deployments(s, evicted)
            assert mvm_old.deployment_status == "deployed"

    def test_import_and_initial_sync_evict_across_scopes(self, engine):
        """Characterisation: import and initial sync keep ``same_scope=False``,
        so an imported MVM still evicts the business's ECM in that catalog."""
        with Session(engine) as s:
            biz = _biz(s)
            ecm = _mv(s, biz, 1, scope="ecm", status="completed", deployment="deployed")
            other_catalog = _mv(s, biz, 2, scope="ecm", deployment="deployed", uc=OTHER)
            mvm = _mv(s, biz, 1, scope="mvm", status="completed", deployment="deployed")
            assert lc.evict_deployed_siblings(s, mvm, same_scope=False) == [ecm.id]
            assert other_catalog.deployment_status == "deployed"


# --- Promotion -------------------------------------------------------------


class TestPromotion:
    def test_dry_run_draft_is_always_promoted(self, engine):
        with Session(engine) as s:
            biz, v3, v4, v5 = _ladder(s)
            draft = _mv(s, biz, 6, status="draft", deployment="draft", uc=CAT, dry_run=True, base=v5)
            assert lc.will_promote(s, draft, OTHER)
            assert lc.dropped_versions(s, draft) == []
            out = lc.record_install(s, draft, run_id="run-i", catalog=OTHER)
            assert out.promoted and out.replaced_ids == []
            assert draft.status == "completed" and draft.dry_run
            assert draft.deployment_status == "deployed" and draft.uc_catalog == OTHER
            assert draft.files_catalog == CAT
            assert draft.promoted_by_run_id == "run-i" and draft.promoted_at is not None
            assert v5.status == "superseded" and v5.replaced_at is None
            assert v5.deployment_status == "deployed"

    def test_draft_on_an_older_base_drops_the_newer_versions(self, engine):
        with Session(engine) as s:
            biz, v3, v4, v5 = _ladder(s)
            draft = _mv(s, biz, 6, status="draft", deployment="draft", dry_run=True, base=v3)
            assert [m.version for m in lc.dropped_versions(s, draft)] == [5, 4]

    def test_older_version_into_the_head_catalog_is_promoted(self, engine):
        with Session(engine) as s:
            biz, v3, v4, v5 = _ladder(s)
            assert lc.will_promote(s, v3, CAT)
            out = lc.record_install(s, v3, run_id="run-i", catalog=CAT)
            assert out.promoted and sorted(out.replaced_ids) == sorted([v4.id, v5.id])
            assert v3.status == "completed"
            assert scope_head(s, biz.id, "ecm").id == v3.id
            for mv in (v4, v5):
                assert mv.replaced_by_version_id == v3.id and mv.replaced_at is not None
            assert v5.status == "superseded" and v5.deployment_status == "uninstalled"

    def test_older_version_into_another_catalog_is_a_plain_install(self, engine):
        with Session(engine) as s:
            biz, v3, v4, v5 = _ladder(s)
            assert not lc.will_promote(s, v3, OTHER)
            out = lc.record_install(s, v3, run_id="run-i", catalog=OTHER)
            assert not out.promoted
            assert v3.deployment_status == "deployed" and v3.uc_catalog == OTHER
            assert v3.status == "superseded" and v3.promoted_at is None
            assert v5.status == "completed" and v5.deployment_status == "deployed"
            assert v4.replaced_at is None and v5.replaced_at is None

    def test_older_version_promoted_when_the_head_is_installed_nowhere(self, engine):
        with Session(engine) as s:
            biz, v3, v4, v5 = _ladder(s)
            v5.deployment_status = "uninstalled"
            s.flush()
            assert lc.will_promote(s, v3, OTHER)

    def test_reinstalling_the_head_keeps_it(self, engine):
        with Session(engine) as s:
            biz, v3, v4, v5 = _ladder(s)
            assert not lc.will_promote(s, v5, CAT)
            assert not lc.record_install(s, v5, run_id="r", catalog=CAT).promoted

    def test_replaced_version_made_current_again_loses_its_mark(self, engine):
        with Session(engine) as s:
            biz, v3, v4, v5 = _ladder(s)
            lc.record_install(s, v3, run_id="r1", catalog=CAT)
            v3.deployment_status = "uninstalled"
            s.flush()
            out = lc.record_install(s, v5, run_id="r2", catalog=CAT)
            assert out.promoted
            assert v5.replaced_at is None and v5.replaced_by_version_id is None
            assert v5.status == "completed" and v3.status == "superseded"
            # v4 stays replaced (by v3), it is not newer than v5.
            assert v4.replaced_at is not None

    def test_replaced_flag_survives_its_replacer_being_gone(self, engine):
        with Session(engine) as s:
            biz, v3, v4, v5 = _ladder(s)
            lc.record_install(s, v3, run_id="r1", catalog=CAT)
            v5.replaced_by_version_id = None  # what ON DELETE SET NULL leaves
            s.flush()
            assert v5.replaced_at is not None
            assert lc.dropped_versions(s, v3) == []


# --- Feedback --------------------------------------------------------------


class TestReopenThenConsume:
    def _promote(self, s, biz, target, run_id="install-run"):
        run = Run(id=run_id, business_id=biz.id, intent="install", status="completed")
        s.add(run)
        s.flush()
        out = lc.record_install(s, target, run_id=run.id, catalog=CAT)
        return lc.Promotion(version_id=target.id, replaced_ids=tuple(out.replaced_ids))

    def test_reopen_replaced_then_consume_installed(self, engine):
        with Session(engine) as s:
            biz, v3, v4, v5 = _ladder(s)
            only_v5 = _input(s, biz, "only in v5", selected=False)
            both = _input(s, biz, "in v3 and v5")
            only_v3 = _input(s, biz, "only in v3", selected=True)
            _producing_run(s, biz, v5, consumed=[only_v5, both])
            _producing_run(s, biz, v3, applied=[both, only_v3])
            promotion = self._promote(s, biz, v3)
            lc.reopen_then_consume(s, "install-run", promotion)

            assert only_v5.consumed is False and only_v5.consumed_by_run_id is None
            assert only_v5.selected_for_run is False
            assert both.consumed is True and both.consumed_by_run_id == "install-run"
            assert only_v3.consumed is True and only_v3.selected_for_run is False
            links = {
                l.input_id: l.outcome_status
                for l in s.exec(select(RunInputLink).where(RunInputLink.run_id == "install-run"))
            }
            assert links == {only_v5.id: "reopened", both.id: "applied", only_v3.id: "applied"}

    def test_reopened_items_are_not_selected_again(self, engine):
        with Session(engine) as s:
            biz, v3, v4, v5 = _ladder(s)
            vi = _input(s, biz, "x", selected=True)
            _producing_run(s, biz, v4, consumed=[vi])
            vi.selected_for_run = False
            lc.reopen_then_consume(s, "install-run", self._promote(s, biz, v3))
            assert vi.consumed is False and vi.selected_for_run is False

    def test_versions_before_0_9_0_move_nothing(self, engine):
        with Session(engine) as s:
            biz, v3, v4, v5 = _ladder(s)
            legacy = _input(s, biz, "consumed before 0.9.0")
            legacy.consumed = True
            s.flush()
            lc.reopen_then_consume(s, "install-run", self._promote(s, biz, v3))
            assert legacy.consumed is True
            assert s.exec(select(RunInputLink)).all() == []

    def test_inputs_to_reopen_follows_the_promoting_run(self, engine):
        with Session(engine) as s:
            biz, v3, v4, v5 = _ladder(s)
            v5.promoted_by_run_id = "old-install"
            vi = _input(s, biz, "consumed by an install")
            vi.consumed, vi.consumed_by_run_id = True, None
            s.add(Run(id="old-install", business_id=biz.id, intent="install", status="completed"))
            s.flush()
            vi.consumed_by_run_id = "old-install"
            s.flush()
            assert [i.id for i in lc.inputs_to_reopen(s, [v5])] == [vi.id]


# --- Post-install deletes ----------------------------------------------------


@pytest.fixture
def no_metamodel(monkeypatch):
    calls: list[dict] = []

    class _Sync:
        def __init__(self, *_a, **_k):
            pass

        def delete_metamodel_rows(self, **kw):
            calls.append(kw)
            return True

    monkeypatch.setattr("vibe_modeling.backend.model_sync.ModelSyncService", _Sync)
    return calls


class TestPostInstallDeletes:
    def _install_run(self, s, biz, *, also_delete: bool) -> Run:
        run = Run(
            id="install-run", business_id=biz.id, intent="install", status="completed",
            parameters_json=json.dumps({"also_delete_replaced": also_delete}),
        )
        s.add(run)
        s.flush()
        return run

    def test_queued_only_when_asked(self, engine):
        with Session(engine) as s:
            biz, v3, v4, v5 = _ladder(s)
            self._install_run(s, biz, also_delete=False)
            lc.queue_post_install_deletes(s, "install-run", lc.Promotion(v3.id, (v4.id, v5.id)))
            assert s.exec(select(RunPostInstallDelete)).all() == []

    def test_deleted_after_the_commit_each_in_its_own_transaction(self, engine, no_metamodel):
        with Session(engine) as s:
            biz, v3, v4, v5 = _ladder(s)
            self._install_run(s, biz, also_delete=True)
            out = lc.record_install(s, v3, run_id="install-run", catalog=CAT)
            lc.queue_post_install_deletes(s, "install-run", lc.Promotion(v3.id, tuple(out.replaced_ids)))
            s.commit()
            rows = s.exec(select(RunPostInstallDelete)).all()
            assert {r.status for r in rows} == {"pending"}
            lc.run_post_install_deletes(s, None, "wh", run_id="install-run")
            rows = s.exec(select(RunPostInstallDelete)).all()
            assert {(r.version, r.status) for r in rows} == {(4, "deleted"), (5, "deleted")}
            assert s.get(ModelVersion, v4.id) is None and s.get(ModelVersion, v5.id) is None
            assert s.get(ModelVersion, v3.id).status == "completed"

    def test_installed_elsewhere_fails_with_the_reason(self, engine, no_metamodel):
        with Session(engine) as s:
            biz, v3, v4, v5 = _ladder(s)
            self._install_run(s, biz, also_delete=True)
            v4.deployment_status, v4.uc_catalog = "deployed", OTHER
            out = lc.record_install(s, v3, run_id="install-run", catalog=CAT)
            lc.queue_post_install_deletes(s, "install-run", lc.Promotion(v3.id, tuple(out.replaced_ids)))
            s.commit()
            lc.run_post_install_deletes(s, None, "wh", run_id="install-run")
            row = s.get(RunPostInstallDelete, ("install-run", v4.id))
            assert row.status == "failed" and OTHER in row.reason
            assert s.get(ModelVersion, v4.id) is not None

    def test_boot_sweep_marks_obsolete_rows_not_run(self, engine, no_metamodel):
        with Session(engine) as s:
            biz, v3, v4, v5 = _ladder(s)
            self._install_run(s, biz, also_delete=True)
            out = lc.record_install(s, v3, run_id="install-run", catalog=CAT)
            lc.queue_post_install_deletes(s, "install-run", lc.Promotion(v3.id, tuple(out.replaced_ids)))
            v4.replaced_at = None
            s.commit()
            lc.run_post_install_deletes(s, None, "wh", recheck=True)
            assert s.get(RunPostInstallDelete, ("install-run", v4.id)).status == "not_run"
            assert s.get(RunPostInstallDelete, ("install-run", v5.id)).status == "deleted"


# --- Delete ----------------------------------------------------------------


class TestDeleteService:
    def test_draft_and_replaced_versions_are_deletable_anywhere(self, engine, no_metamodel):
        with Session(engine) as s:
            biz, v3, v4, v5 = _ladder(s)
            draft = _mv(s, biz, 6, status="draft", deployment="draft", dry_run=True, base=v3)
            v4.replaced_at = datetime.now(timezone.utc)
            s.commit()
            assert lc.delete_refusal(s, draft) is None
            assert lc.delete_refusal(s, v4) is None
            assert lc.delete_refusal(s, v3) is not None
            lc.delete_version(s, None, "wh", draft)
            lc.delete_version(s, None, "wh", v4)
            assert s.get(ModelVersion, v4.id) is None

    def test_installed_draft_or_replaced_version_is_refused(self, engine):
        with Session(engine) as s:
            biz, v3, v4, v5 = _ladder(s)
            v4.replaced_at = datetime.now(timezone.utc)
            v4.deployment_status = "deployed"
            s.commit()
            with pytest.raises(lc.VersionDeleteRefused) as exc:
                lc.delete_version(s, None, "wh", v4)
            assert exc.value.status_code == 409
            assert exc.value.detail["error"] == "installed"
            assert s.get(ModelVersion, v4.id) is not None

    def test_active_run_refuses_with_409_except_the_finishing_run(self, engine, no_metamodel):
        with Session(engine) as s:
            biz, v3, v4, v5 = _ladder(s)
            lc.mark_version_uninstalled(s, v5, CAT)
            s.add(Run(id="busy", business_id=biz.id, intent="install", status="running"))
            s.commit()
            with pytest.raises(lc.VersionDeleteRefused) as exc:
                lc.delete_version(s, None, "wh", v5)
            assert exc.value.status_code == 409
            assert s.get(ModelVersion, v5.id) is not None
            lc.delete_version(s, None, "wh", v5, finishing_run_id="busy")
            assert s.get(ModelVersion, v5.id) is None

    def test_cleanup_in_the_files_and_the_install_catalog(self, engine, no_metamodel):
        with Session(engine) as s:
            biz, v3, v4, v5 = _ladder(s)
            v5.uc_catalog = OTHER
            v5.deployment_status = "uninstalled"
            s.commit()
            assert lc.metamodel_cleanup_catalogs(s, v5) == [CAT, OTHER]
            out = lc.delete_version(s, None, "wh", v5)
            assert [c["catalog"] for c in no_metamodel] == [CAT, OTHER]
            assert out.metamodel_rows_cleaned is True

    def test_import_cleans_where_it_was_seeded_and_its_install_catalog(self, engine):
        """An import seeds its registry rows into the metamodel catalog (not
        the catalog of the path it read), and the agent registers it again
        where it is installed. The path's catalog is not cleaned."""
        from vibe_modeling.backend.db_models import AgentConfig

        with Session(engine) as s:
            s.add(AgentConfig(deployment_catalog="meta_cat"))
            biz = _biz(s)
            mv = _mv(s, biz, 1, status="completed", deployment="deployed", uc=OTHER, files="src_cat")
            mv.import_source_path = "/Volumes/src_cat/x/y/model.json"
            s.flush()
            assert lc.metamodel_cleanup_catalogs(s, mv) == ["meta_cat", OTHER]


# --- Confirm subjects --------------------------------------------------------


class TestInstallConfirmIssues:
    def test_install_over_newer_into_the_head_catalog(self, engine):
        with Session(engine) as s:
            biz, v3, v4, v5 = _ladder(s)
            vi = _input(s, biz, "f")
            _producing_run(s, biz, v5, consumed=[vi])
            issues = install_confirm_issues(s, v3, CAT)
            subjects = {i.subject for i in issues}
            assert subjects == {
                install_over_newer_subject(v5.id),
                install_replaces_subject(v5.id),
            }
            over = next(i for i in issues if i.subject.startswith("install_over_newer"))
            assert over.severity == "confirm"
            assert "replaces v4 and v5" in over.message
            assert "split orders" in over.message and "rename x" in over.message
            assert "1 feedback item applied in v4 and v5 is reopened" in over.message
            # v5, the occupant, is uninstalled first and its rows released; v4
            # stays recorded in CAT.
            assert (
                f"Scoped runs on v3 in {CAT} are refused by the agent until v4 is deleted: "
                "it stays in the agent's registry there after it is replaced."
            ) in over.message
            assert over.versions == (4, 5)
            run = _uninstall(s, biz, v5, CAT)
            lc.record_install(s, v3, run_id=run.id, catalog=CAT)
            blocker = next(
                i for i in vibe_catalog_issues(s, v3, CAT, scoped=True, dry_run=False, intent="vibe-iterate")
                if i.field_path == "vibe_scope_base"
            )
            assert blocker.versions == (4,)

    def test_draft_on_an_older_base_does_not_name_older_versions_as_blocking(self, engine):
        """Draft v6 on base v3 replaces v4 and v5, both below it: a scoped run
        on v6 is not refused (``vibe_scope_base`` counts versions above the
        base only), so the text must not ask for their deletion."""
        with Session(engine) as s:
            biz, v3, v4, v5 = _ladder(s)
            draft = _mv(s, biz, 6, status="draft", deployment="draft", dry_run=True, base=v3)
            over = next(
                i for i in install_confirm_issues(s, draft, CAT)
                if i.subject.startswith("install_over_newer")
            )
            assert "Installing v6 makes v6 the latest and replaces v4 and v5." in over.message
            assert "Scoped runs" not in over.message and "deleted" not in over.message
            assert over.versions == (4, 5)
            lc.record_install(s, draft, run_id="run-i", catalog=CAT)
            assert not [
                i for i in vibe_catalog_issues(s, draft, CAT, scoped=True, dry_run=False, intent="vibe-iterate")
                if i.field_path == "vibe_scope_base"
            ]

    def test_mixed_names_only_the_versions_above_the_target(self, engine):
        """Synthetic: a draft numbered below one of the versions it drops
        (reused numbers after deletes). Only the one above the draft blocks."""
        with Session(engine) as s:
            biz = _biz(s)
            v1 = _mv(s, biz, 1, instructions="a")
            _mv(s, biz, 2, base=v1, instructions="b")
            _mv(s, biz, 5, status="completed", deployment="deployed", uc=OTHER, instructions="c")
            draft = _mv(s, biz, 3, status="draft", deployment="draft", dry_run=True, base=v1)
            over = next(
                i for i in install_confirm_issues(s, draft, CAT)
                if i.subject.startswith("install_over_newer")
            )
            assert "replaces v2 and v5" in over.message
            assert (
                f"Scoped runs on v3 in {CAT} are refused by the agent until v5 is deleted:"
            ) in over.message
            assert "until v2" not in over.message and "v2 and v5 are deleted" not in over.message
            assert over.versions == (2, 5)

    def test_another_catalog_has_no_head_change_and_no_occupant(self, engine):
        with Session(engine) as s:
            biz, v3, v4, v5 = _ladder(s)
            assert install_confirm_issues(s, v3, OTHER) == []

    def test_draft_over_its_installed_base_needs_no_confirmation(self, engine):
        """A draft whose ``_vibe_scope`` facts name its installed base: the
        agent's base_match path, a plain install."""
        with Session(engine) as s:
            biz, v3, v4, v5 = _ladder(s)
            draft = _mv(s, biz, 6, status="draft", deployment="draft", dry_run=True, base=v5)
            draft.scope_fence_mode, draft.scope_base_version, draft.scope_base_scope = "some_domains", 5, "ecm"
            s.flush()
            assert install_confirm_issues(s, draft, CAT) == []
            assert lc.catalog_occupant(s, draft, CAT) is None

    def test_base_from_the_vibe_scope_facts_is_not_an_occupant(self, engine):
        with Session(engine) as s:
            biz, v3, v4, v5 = _ladder(s)
            draft = _mv(s, biz, 6, status="draft", deployment="draft", dry_run=True)
            draft.scope_fence_mode, draft.scope_base_version, draft.scope_base_scope = "all", 5, "ecm"
            s.flush()
            assert lc.catalog_occupant(s, draft, CAT) is None

    def test_a_version_without_vibe_scope_facts_keeps_its_base_as_occupant(self, engine):
        """No ``_vibe_scope`` block: the agent's ordinary install replaces
        every table (``CREATE OR REPLACE TABLE``), so the rows are lost either
        way; the app keeps the base as an occupant and uninstalls it first
        under the confirmation."""
        with Session(engine) as s:
            biz, v3, v4, v5 = _ladder(s)
            draft = _mv(s, biz, 6, status="draft", deployment="draft", dry_run=True, base=v5)
            assert lc.catalog_occupant(s, draft, CAT).id == v5.id

    def test_facts_naming_another_version_with_the_base_number_do_not_match(self, engine):
        """The lineage pointer wins over the number: a reused number is not
        the base."""
        with Session(engine) as s:
            biz, v3, v4, v5 = _ladder(s)
            draft = _mv(s, biz, 6, status="draft", deployment="draft", dry_run=True, base=v4)
            draft.scope_fence_mode, draft.scope_base_version, draft.scope_base_scope = "all", 5, "ecm"
            s.flush()
            assert lc.catalog_occupant(s, draft, CAT).id == v5.id

    def test_replaced_version_made_current_again_over_its_base_keeps_the_occupant(self, engine):
        """Full Run v4 (scoped, base v3) was installed in the catalog, then v3
        installed back over it: v4 is replaced but still registered installed
        there, so installing v4 again sees latest installed v4, not its base
        v3, and the agent would refuse a plain install."""
        with Session(engine) as s:
            biz, v3, v4, v5 = _ladder(s)
            v5.deployment_status = "uninstalled"
            v4.scope_fence_mode, v4.scope_base_version, v4.scope_base_scope = "some_domains", 3, "ecm"
            v4.base_version_id = v3.id
            s.delete(v5)
            s.flush()
            lc.record_install(s, v3, run_id=None, catalog=CAT)
            assert v4.replaced_at is not None and v4.uc_catalog == CAT
            assert lc.catalog_occupant(s, v4, CAT).id == v3.id

    def test_lineage_pointer_and_facts_must_agree_on_the_base(self, engine):
        with Session(engine) as s:
            biz, v3, v4, v5 = _ladder(s)
            draft = _mv(s, biz, 6, status="draft", deployment="draft", dry_run=True, base=v5)
            draft.scope_fence_mode, draft.scope_base_version, draft.scope_base_scope = "all", 4, "ecm"
            s.flush()
            assert lc.catalog_occupant(s, draft, CAT).id == v5.id

    def test_draft_on_a_head_made_current_over_newer_versions_keeps_the_occupant(self, engine):
        """Install v3 over v5 in the same catalog, then a Dry Run on head v3:
        v4 and v5 are still registered in that catalog, so the agent's latest
        installed is v5, not the draft's base v3."""
        with Session(engine) as s:
            biz, v3, v4, v5 = _ladder(s)
            v5.deployment_status = "uninstalled"
            lc.record_install(s, v3, run_id=None, catalog=CAT)
            draft = _mv(s, biz, 6, status="draft", deployment="draft", dry_run=True, base=v3)
            draft.scope_fence_mode, draft.scope_base_version, draft.scope_base_scope = "all", 3, "ecm"
            s.flush()
            assert lc.catalog_occupant(s, draft, CAT).id == v3.id

    def test_a_draft_on_an_older_base_still_replaces_the_occupant(self, engine):
        with Session(engine) as s:
            biz, v3, v4, v5 = _ladder(s)
            draft = _mv(s, biz, 6, status="draft", deployment="draft", dry_run=True, base=v3)
            assert lc.catalog_occupant(s, draft, CAT).id == v5.id
            assert install_replaces_subject(v5.id) in {
                i.subject for i in install_confirm_issues(s, draft, CAT)
            }


# --- The install run's terminal step ----------------------------------------


class TestInstallRunFinalize:
    """``progress_tracker._finalize_run_inputs`` moves the feedback of the
    promotion the install op recorded, and queues the requested deletes, in
    the terminal commit."""

    def _install_run_with_promotion(self, s, biz, target, replaced, *, also_delete):
        run = Run(
            id="install-run", business_id=biz.id, intent="install", status="completed",
            parameters_json=json.dumps({"also_delete_replaced": also_delete}),
        )
        s.add(run)
        s.flush()
        s.add(RunOperation(
            run_id=run.id, step_index=0, operation_name="install", status="succeeded",
            rollback_state_json=json.dumps({
                lc.PROMOTED_VERSION_KEY: target.id,
                lc.REPLACED_VERSIONS_KEY: [r.id for r in replaced],
            }),
        ))
        s.flush()
        return run

    def test_reopen_consume_and_queue_in_one_commit(self, engine):
        from vibe_modeling.backend import progress_tracker as pt

        with Session(engine) as s:
            biz, v3, v4, v5 = _ladder(s)
            reopened = _input(s, biz, "in v5")
            applied = _input(s, biz, "in v3")
            _producing_run(s, biz, v5, consumed=[reopened])
            _producing_run(s, biz, v3, applied=[applied])
            self._install_run_with_promotion(s, biz, v3, [v4, v5], also_delete=True)
            reopened_id, applied_id = reopened.id, applied.id
            pt._finalize_run_inputs("install-run", s, success=True)

        with Session(engine) as s:
            assert s.get(VibeInput, reopened_id).consumed is False
            assert s.get(VibeInput, applied_id).consumed_by_run_id == "install-run"
            rows = s.exec(select(RunPostInstallDelete)).all()
            assert {(r.version, r.status) for r in rows} == {(4, "pending"), (5, "pending")}

    def test_failed_install_moves_nothing(self, engine):
        from vibe_modeling.backend import progress_tracker as pt

        with Session(engine) as s:
            biz, v3, v4, v5 = _ladder(s)
            vi = _input(s, biz, "in v5")
            _producing_run(s, biz, v5, consumed=[vi])
            self._install_run_with_promotion(s, biz, v3, [v4, v5], also_delete=True)
            vi_id = vi.id
            pt._finalize_run_inputs("install-run", s, success=False)

        with Session(engine) as s:
            assert s.get(VibeInput, vi_id).consumed is True
            assert s.exec(select(RunPostInstallDelete)).all() == []


# --- On the UC fake ---------------------------------------------------------

from ._drift.consistency import check_lakebase_metamodel_consistency  # noqa: E402
from ._drift.fake_uc import RegistryKey  # noqa: E402
from ._drift.fixtures import fake_uc, mock_model, seed_synced_version  # noqa: E402,F401


class TestOnTheUcFake:
    """The files catalog keeps the registry and Volume checks on the agent's
    home rows after installs elsewhere; deleting a replaced version cleans
    its home rows and the rows its install registered in another catalog.
    The install rows stay consistent with the columns throughout."""

    def test_install_elsewhere_promote_and_delete(self, engine, fake_uc):
        from vibe_modeling.backend.db_models import AgentConfig

        with Session(engine) as s:
            s.add(AgentConfig(deployment_catalog=CAT))
            v1 = seed_synced_version(s, fake_uc, catalog=CAT, business_name="Fake Co", version=1)
            v2 = seed_synced_version(s, fake_uc, catalog=CAT, business_name="Fake Co", version=2)
            v1.status = "superseded"
            lc.mark_version_uninstalled(s, v1, CAT)
            s.commit()

            # v2 also installed into OTHER: the agent registers it there too.
            fake_uc.add_agent_version(OTHER, "Fake Co", 2, "mvm", mock_model())
            lc.record_install(s, v2, run_id=None, catalog=OTHER)
            s.commit()
            report = check_lakebase_metamodel_consistency(
                s, fake_uc, allow_orphans=[RegistryKey(OTHER, "fake_co", "2", "mvm")],
            )
            assert report.problems == [], report.problems
            assert lc.installed_catalogs(s, v2) == [OTHER, CAT]

            # Uninstall v2 from CAT, then make v1 current in OTHER: v2 is replaced.
            lc.mark_version_uninstalled(s, v2, CAT)
            out = lc.record_install(s, v1, run_id=None, catalog=OTHER)
            s.commit()
            assert out.promoted and out.replaced_ids == [v2.id]

            lc.delete_version(s, fake_uc.ws, "wh-drift", v2)
            deletes = [c.args["catalog"] for c in fake_uc.calls_to("delete_metamodel_rows")]
            assert deletes == [CAT, OTHER]
            assert fake_uc.registry_entry(CAT, "fake_co", 2, "mvm") is None
            assert fake_uc.registry_entry(OTHER, "fake_co", 2, "mvm") is None
            report = check_lakebase_metamodel_consistency(s, fake_uc)
            assert report.problems == [], report.problems


class TestUnifiedRunScopes:
    """A unified run consumes its inputs once for both outputs; they are
    anchored to its base's scope, so only that scope's replacement or
    promotion moves them. The MVM its shrink step produced finds the run."""

    def _unified(self, s):
        from vibe_modeling.backend.db_models import VibeInputContextLink

        biz = _biz(s)
        base = _mv(s, biz, 1, status="superseded")
        ecm2 = _mv(s, biz, 2, status="completed", deployment="deployed", base=base)
        mvm2 = _mv(s, biz, 2, scope="mvm", status="completed", deployment="deployed", base=ecm2)
        vi = _input(s, biz, "anchored to the ECM base")
        s.add(VibeInputContextLink(input_id=vi.id, version_id=base.id))
        run = _producing_run(s, biz, ecm2, consumed=[vi])
        s.add(RunOperation(
            run_id=run.id, step_index=1, operation_name="shrink_to_mvm", status="succeeded",
            output_version_id=mvm2.id, completed_at=datetime.now(timezone.utc),
        ))
        s.flush()
        return biz, ecm2, mvm2, vi, run

    def test_replacing_the_mvm_output_keeps_the_ecm_feedback_done(self, engine):
        with Session(engine) as s:
            biz, ecm2, mvm2, vi, run = self._unified(s)
            assert lc._producing_run_id(s, mvm2.id) == run.id
            assert lc.inputs_to_reopen(s, [mvm2]) == []
            assert [i.id for i in lc.inputs_to_reopen(s, [ecm2])] == [vi.id]


class TestPostInstallDeleteWaitsForActiveRun:
    def test_a_409_keeps_the_row_pending_with_the_reason(self, engine, no_metamodel):
        with Session(engine) as s:
            biz, v3, v4, v5 = _ladder(s)
            s.add(Run(id="install-run", business_id=biz.id, intent="install", status="completed",
                      parameters_json=json.dumps({"also_delete_replaced": True})))
            s.flush()
            out = lc.record_install(s, v3, run_id="install-run", catalog=CAT)
            lc.queue_post_install_deletes(s, "install-run", lc.Promotion(v3.id, tuple(out.replaced_ids)))
            s.add(Run(id="busy", business_id=biz.id, intent="vibe-iterate", status="running"))
            s.commit()
            lc.run_post_install_deletes(s, None, "wh", recheck=True)
            row = s.get(RunPostInstallDelete, ("install-run", v5.id))
            assert row.status == "pending" and "active run" in row.reason
            assert s.get(ModelVersion, v5.id) is not None


class TestPostInstallDeleteDatabaseFailure:
    def test_an_integrity_error_marks_the_row_failed(self, engine, no_metamodel, monkeypatch):
        from sqlalchemy.exc import IntegrityError

        def broken(*_a, **_k):
            raise IntegrityError("DELETE", {}, Exception('violates constraint "x_fkey"'))

        monkeypatch.setattr("vibe_modeling.backend.routes._helpers.delete_model_version", broken)
        with Session(engine) as s:
            biz, v3, v4, v5 = _ladder(s)
            s.add(Run(id="install-run", business_id=biz.id, intent="install", status="completed",
                      parameters_json=json.dumps({"also_delete_replaced": True})))
            s.flush()
            out = lc.record_install(s, v3, run_id="install-run", catalog=CAT)
            lc.queue_post_install_deletes(s, "install-run", lc.Promotion(v3.id, tuple(out.replaced_ids)))
            s.commit()
            lc.run_post_install_deletes(s, None, "wh", recheck=True)
            row = s.get(RunPostInstallDelete, ("install-run", v5.id))
            assert row.status == "failed" and "x_fkey" in row.reason


class TestAgentEvictionTable:
    """What each agent run does to the business's other schemas in its
    target catalog (agent 5.3.3), the rule ``evict_deployed_siblings`` follows."""

    @pytest.mark.parametrize(
        ("operation", "kwargs", "clears"),
        [
            # _early_clash_detection runs the staging teardown for these (nb 8538-8546).
            ("shrink ecm", {}, True),
            ("enlarge mvm", {}, True),
            ("vibe modeling of version", {}, True),
            # The teardown skips a Some domains run (nb 8493-8497).
            ("vibe modeling of version", {"scoped": True}, False),
            # ... and a vibe whose base is the latest installed (nb 8505-8507, 8446-8460).
            ("vibe modeling of version", {"keeps_installed": True}, False),
            # One Catalog: new base model takes the clash check, no DROP (nb
            # 8547-8676); install model replaces only its own scope's tables
            # (nb 110014-110026; the other scope has another prefix).
            ("new base model", {}, False),
            ("install model", {}, False),
            # Catalog per Division/Domain: both scopes share catalogs and schema
            # names, so a deploy overwrites the other scope in place
            # (CREATE OR REPLACE TABLE, nb 84984, 107368).
            ("shrink ecm", {"cataloging_style": "Catalog per Domain"}, True),
            ("vibe modeling of version", {"cataloging_style": "Catalog per Division", "keeps_installed": True}, True),
            # install model there too: soft-replace over present schemas (nb
            # 7955-7964, 8060-8091), no clash check on its path (nb 110014-110026).
            ("install model", {"cataloging_style": "Catalog per Domain"}, True),
            ("new base model", {"cataloging_style": "Catalog per Division"}, True),
        ],
    )
    def test_table(self, operation, kwargs, clears):
        kwargs = {"cataloging_style": "One Catalog", **kwargs}
        assert lc.deploy_evicts_every_scope(operation, **kwargs) is clears

    def test_an_install_keeps_the_other_scope_installed(self, engine):
        """One Catalog: ``install model`` replaces only its own scope's tables
        (nb 110014-110026; the other scope has another schema prefix), so
        ``record_install`` evicts the same scope only."""
        with Session(engine) as s:
            biz = _biz(s)
            mvm = _mv(s, biz, 1, scope="mvm", status="completed", deployment="deployed")
            ecm = _mv(s, biz, 1, status="completed", deployment="uninstalled")
            lc.record_install(s, ecm, run_id=None, catalog=CAT)
            assert (ecm.deployment_status, mvm.deployment_status) == ("deployed", "deployed")

    def test_an_install_in_catalog_per_division_evicts_every_scope(self, engine):
        """Catalog per Division/Domain: both scopes share catalogs and schema
        names, and the install soft-replaces present schemas (nb 7955-7964,
        8060-8091, CREATE OR REPLACE nb 107368), so the other scope's tables
        are overwritten in place."""
        with Session(engine) as s:
            biz = _biz(s)
            mvm = _mv(s, biz, 1, scope="mvm", status="completed", deployment="deployed")
            ecm = _mv(s, biz, 1, status="completed", deployment="uninstalled")
            lc.record_install(s, ecm, run_id=None, catalog=CAT, cataloging_style="Catalog per Division")
            assert (ecm.deployment_status, mvm.deployment_status) == ("deployed", "uninstalled")

    def test_base_is_latest_installed(self, engine):
        with Session(engine) as s:
            biz, v3, v4, v5 = _ladder(s)
            new = _mv(s, biz, 6, status="completed", deployment="deployed", base=v5)
            assert lc.base_is_latest_installed(s, v5, CAT, new_version_id=new.id)
            assert not lc.base_is_latest_installed(s, v3, CAT, new_version_id=new.id)
            assert not lc.base_is_latest_installed(s, v5, OTHER, new_version_id=new.id)


def _scoped_blockers(s, base, catalog):
    return [
        i for i in vibe_catalog_issues(s, base, catalog, scoped=True, dry_run=False, intent="vibe-iterate")
        if i.field_path == "vibe_scope_base"
    ]


def _make_current_over(s, biz, base, head, catalog, *, released: Optional[bool] = True) -> None:
    """"Make this version current" on ``base`` over ``head`` installed in
    ``catalog``: the run uninstalls ``head`` there first, then installs
    ``base``, which replaces ``head``."""
    run = _uninstall(s, biz, head, catalog, released=released)
    lc.record_install(s, base, run_id=run.id, catalog=catalog)
    assert head.replaced_at is not None


class TestReleasedVersions:
    """A newer version counts for the agent's stale-base check and its latest
    installed version only while its registry rows still own its names: the
    app's release after an uninstall sets them ``dry_run``, which both skip."""

    def _two(self, s):
        biz = _biz(s)
        v2 = _mv(s, biz, 2)
        lc.mark_version_deployed(s, v2, CAT)
        v3 = _mv(s, biz, 3, status="completed", base=v2)
        lc.mark_version_deployed(s, v3, CAT)
        lc.mark_version_uninstalled(s, v2, CAT)
        return biz, v2, v3

    def test_make_current_then_a_scoped_run_on_the_base_is_allowed(self, engine):
        with Session(engine) as s:
            biz, v2, v3 = self._two(s)
            _make_current_over(s, biz, v2, v3, CAT)
            assert lc.released_from(s, [v3.id], CAT) == {v3.id}
            assert _scoped_blockers(s, v2, CAT) == []
            assert lc.base_is_latest_installed(s, v2, CAT, new_version_id="new")

    def test_a_pending_release_still_blocks(self, engine):
        with Session(engine) as s:
            biz, v2, v3 = self._two(s)
            _make_current_over(s, biz, v2, v3, CAT, released=False)
            assert lc.released_from(s, [v3.id], CAT) == set()
            assert [b.versions for b in _scoped_blockers(s, v2, CAT)] == [(3,)]
            assert not lc.base_is_latest_installed(s, v2, CAT, new_version_id="new")

    def test_an_uninstall_without_a_recorded_release_still_blocks(self, engine):
        """An uninstall step recorded before the app released registry rows."""
        with Session(engine) as s:
            biz, v2, v3 = self._two(s)
            _make_current_over(s, biz, v2, v3, CAT, released=None)
            assert [b.versions for b in _scoped_blockers(s, v2, CAT)] == [(3,)]

    def test_a_newer_version_still_installed_blocks_in_that_catalog_only(self, engine):
        """Replaced v3, uninstalled and released in OTHER, still installed in
        CAT: it blocks in CAT only."""
        with Session(engine) as s:
            biz = _biz(s)
            v2 = _mv(s, biz, 2, uc=OTHER, files=OTHER)
            lc.mark_version_deployed(s, v2, OTHER)
            v3 = _mv(s, biz, 3, base=v2, uc=OTHER, files=OTHER)
            lc.mark_version_deployed(s, v3, CAT)
            lc.mark_version_deployed(s, v3, OTHER)
            _uninstall(s, biz, v3, OTHER)
            v3.replaced_at, v3.replaced_by_version_id = datetime.now(timezone.utc), v2.id
            s.flush()
            assert _scoped_blockers(s, v2, OTHER) == []
            assert lc.base_is_latest_installed(s, v2, OTHER, new_version_id="new")
            lc.mark_version_deployed(s, v2, CAT)
            assert [b.versions for b in _scoped_blockers(s, v2, CAT)] == [(3,)]
            assert not lc.base_is_latest_installed(s, v2, CAT, new_version_id="new")

    def test_an_eviction_is_not_a_release(self, engine):
        """An install run that evicts v3 (the agent replaced its tables)
        leaves v3's rows ``installed`` in the agent's registry."""
        with Session(engine) as s:
            biz, v2, v3 = self._two(s)
            run = _producing_run(s, biz, v2)
            lc.record_install(s, v2, run_id=run.id, catalog=CAT)
            assert v3.deployment_status == "uninstalled"
            assert lc.released_from(s, [v3.id], CAT) == set()
            assert not lc.base_is_latest_installed(s, v2, CAT, new_version_id="new")

    def test_the_newest_install_row_decides(self, engine):
        """A release left pending, a reinstall, then an uninstall whose
        release goes through: the last release covers every registry row of
        the version there. Reinstalled again, it counts again."""
        with Session(engine) as s:
            biz, v2, v3 = self._two(s)
            _uninstall(s, biz, v3, CAT, released=False)
            lc.mark_version_deployed(s, v3, CAT)
            assert lc.released_from(s, [v3.id], CAT) == set()
            _uninstall(s, biz, v3, CAT)
            assert lc.released_from(s, [v3.id], CAT) == {v3.id}
            assert lc.released_from(s, [v3.id], CAT.upper()) == set()
            assert lc.released_from(s, [v3.id], CAT.upper(), fold_case=True) == {v3.id}
            lc.mark_version_deployed(s, v3, CAT)
            assert lc.released_from(s, [v3.id], CAT) == set()

    def test_another_versions_uninstall_in_the_same_run_does_not_release(self, engine):
        """The release is matched to the step's own version and catalog."""
        with Session(engine) as s:
            biz, v2, v3 = self._two(s)
            other = _mv(s, biz, 4, status="superseded")
            lc.mark_version_deployed(s, other, CAT)
            run = _uninstall(s, biz, other, CAT)
            lc.mark_version_uninstalled(s, v3, CAT, run_id=run.id)
            assert lc.released_from(s, [v3.id, other.id], CAT) == {other.id}

    def test_a_released_base_is_not_the_latest_installed(self, engine):
        """The agent keeps the installed tables only when its latest
        installed version is the base; a released base is not installed."""
        with Session(engine) as s:
            biz = _biz(s)
            v2 = _mv(s, biz, 2)
            lc.mark_version_deployed(s, v2, CAT)
            _uninstall(s, biz, v2, CAT)
            assert not lc.base_is_latest_installed(s, v2, CAT, new_version_id="new")


    def test_a_mixed_case_install_row_and_a_lowercase_release_step(self, engine):
        """A legacy install row stored as ``Cat_A``, released by a step that
        names ``cat_a``: the vibe eviction folds case as validate does."""
        with Session(engine) as s:
            biz = _biz(s)
            v2 = _mv(s, biz, 2)
            lc.mark_version_deployed(s, v2, CAT)
            v3 = _mv(s, biz, 3, base=v2)
            lc.mark_version_deployed(s, v3, CAT.capitalize())
            run = Run(business_id=biz.id, intent="install", status="completed")
            s.add(run)
            s.flush()
            s.add(RunOperation(
                run_id=run.id, step_index=0, operation_name="uninstall", status="succeeded",
                params_json=json.dumps({"version_id": v3.id, "deployment_catalog": CAT}),
                rollback_state_json=json.dumps({lc.REGISTRY_RELEASED_KEY: True}),
            ))
            lc.mark_version_uninstalled(s, v3, CAT.capitalize(), run_id=run.id)
            assert not lc._newer_recorded(s, v2, CAT, exclude_ids=(v2.id,))
            assert lc.base_is_latest_installed(s, v2, CAT, new_version_id="new")


class TestAppSeeds:
    """A version the app imported, downloaded or kickstarted (import markers
    set) is seeded ``dry_run`` in the metamodel catalog, which the agent
    skips: it counts there only once it is installed there. An agent Dry Run
    draft (no markers, registered ``deploy_status`` NULL) keeps counting."""

    def _seeded(self, s, biz, version, *, scope="ecm", status="completed"):
        mv = _mv(s, biz, version, scope=scope, status=status, deployment="draft", uc="")
        mv.import_schema_prefix_added = mv.import_view_prefix_added = ""
        s.flush()
        return mv

    def test_a_full_run_vibe_on_a_seeded_ecm_evicts_the_installed_mvm(self, engine):
        """Kickstart into CAT, install only the MVM, Full Run vibe on the
        never-installed ECM v1: the agent's latest installed ECM is none, so
        its teardown drops every schema of the business, the MVM's too."""
        with Session(engine) as s:
            biz = _biz(s)
            ecm = self._seeded(s, biz, 1)
            mvm = self._seeded(s, biz, 1, scope="mvm")
            lc.mark_version_deployed(s, mvm, CAT)
            assert lc.agent_counts_in(s, [ecm.id, mvm.id], CAT) == {mvm.id}
            keeps = lc.base_is_latest_installed(s, ecm, CAT, new_version_id="new")
            assert keeps is False
            assert lc.deploy_evicts_every_scope(
                lc.AGENT_OP_VIBE, cataloging_style="One Catalog", keeps_installed=keeps,
            )

    def test_a_seeded_newer_replaced_version_does_not_block_a_scoped_run(self, engine):
        with Session(engine) as s:
            biz = _biz(s)
            v2 = _mv(s, biz, 2, status="completed")
            lc.mark_version_deployed(s, v2, CAT)
            v3 = self._seeded(s, biz, 3, status="superseded")
            v3.replaced_at = datetime.now(timezone.utc)
            s.flush()
            assert _scoped_blockers(s, v2, CAT) == []
            lc.mark_version_deployed(s, v3, OTHER)
            lc.mark_version_deployed(s, v3, CAT)
            lc.mark_version_uninstalled(s, v3, CAT)
            assert [b.versions for b in _scoped_blockers(s, v2, CAT)] == [(3,)]

    def test_a_seeded_newer_version_keeps_the_base_match_install(self, engine):
        """A draft whose ``_vibe_scope`` facts name its installed base v2: a
        seeded v3 in the catalog is not the agent's latest installed, so v2 is
        not an occupant (the plain ``base_match`` install)."""
        with Session(engine) as s:
            biz = _biz(s)
            v2 = _mv(s, biz, 2, status="completed")
            lc.mark_version_deployed(s, v2, CAT)
            self._seeded(s, biz, 3, status="superseded")
            draft = _mv(s, biz, 4, status="draft", deployment="draft", dry_run=True, base=v2)
            draft.scope_fence_mode, draft.scope_base_version, draft.scope_base_scope = "some_domains", 2, "ecm"
            s.flush()
            assert lc.catalog_occupant(s, draft, CAT) is None

    def test_an_agent_dry_run_draft_still_counts(self, engine):
        with Session(engine) as s:
            biz = _biz(s)
            v2 = _mv(s, biz, 2, status="completed")
            lc.mark_version_deployed(s, v2, CAT)
            draft = _mv(s, biz, 3, status="draft", deployment="draft", dry_run=True, base=v2, uc="")
            assert lc.agent_counts_in(s, [draft.id], CAT) == {draft.id}
            assert [b.versions for b in _scoped_blockers(s, v2, CAT)] == [(3,)]


class TestLatestInstalledAfterADrop:
    def test_an_uninstalled_base_still_counts_as_latest_installed(self, engine):
        """After a shrink dropped the ECM's schemas the agent's registry still
        holds ECM v1 ``installed`` (P0), so a vibe on it takes the keep-tables
        path; the app reads the same from v1 being recorded in the catalog."""
        with Session(engine) as s:
            biz = _biz(s)
            v1 = _mv(s, biz, 1, status="completed", deployment="uninstalled")
            new = _mv(s, biz, 2, status="completed", deployment="deployed", base=v1)
            assert lc.base_is_latest_installed(s, v1, CAT, new_version_id=new.id)


class TestDeleteKeepsTheReplacedChain:
    def test_deleting_the_middle_replacer_repoints_to_its_replacer(self, engine, no_metamodel):
        """v5 replaced by v4, v4 replaced by v3: deleting v4 points v5 at v3
        instead of leaving the pointer NULL (P0 F7)."""
        with Session(engine) as s:
            biz, v3, v4, v5 = _ladder(s)
            now = datetime.now(timezone.utc)
            v5.status, v5.deployment_status = "superseded", "uninstalled"
            v4.replaced_by_version_id, v4.replaced_at = v3.id, now
            v5.replaced_by_version_id, v5.replaced_at = v4.id, now
            v3.status, v3.deployment_status = "completed", "deployed"
            s.commit()
            lc.delete_version(s, None, "wh", v4)
            s.refresh(v5)
            assert (v5.replaced_by_version_id, v5.replaced_at is not None) == (v3.id, True)

    def test_a_replacer_with_no_replacer_keeps_the_flag(self, engine, no_metamodel):
        with Session(engine) as s:
            biz, v3, v4, v5 = _ladder(s)
            v4.status, v4.deployment_status = "draft", "draft"
            v4.dry_run = True
            v5.status, v5.deployment_status = "superseded", "uninstalled"
            v5.replaced_by_version_id, v5.replaced_at = v4.id, datetime.now(timezone.utc)
            v3.status = "completed"
            s.commit()
            lc.delete_version(s, None, "wh", v4)
            s.refresh(v5)
            assert v5.replaced_by_version_id is None and v5.replaced_at is not None

