"""Install rows and one-by-one delete (v0.9.0 unit A2b; addendum design 6.1, 10.2).

* **Install rows.** Every install-state writer opens or closes a
  ``model_version_installs`` row per catalog; ``deployment_status`` and
  ``uc_catalog`` follow the latest open row. A version installed in two
  catalogs stays installed in the other when it is uninstalled from one; an
  every-scope eviction closes the other scope's row in that catalog; a
  rollback reopens the row it closed.
* **The base rule reads the rows**, closed ones included: a version once
  installed in a catalog stays registered there for the agent.
* **Delete rules.** Installed refused (409 ``installed``, writes nothing); a
  version with newer ones above refused ("Delete the newer versions first");
  the head restores its newest superseded, not replaced predecessor; drafts,
  replaced, failed and generating rows go; a scope peels to zero, then New
  Base Model passes its empty-business gate.
* **In the delete transaction:** the deleted version's applied feedback
  reopens, its change-review feedback goes, lineage pointers stay, one
  ``pending`` ``metamodel_cleanups`` row per catalog is written.
* **Cleanups.** Attempted after the commit; a failure stays ``failed``; the
  boot sweep stops at 3 attempts; Retry cleanup resets and runs under the
  lock; the list route shows unfinished rows.
* **The lock** (``core._runs.lock_business_for_run``): an active run and a
  held ``NOWAIT`` lock both refuse with 409 after a rollback.
"""
from __future__ import annotations

from datetime import datetime, timezone
from typing import Optional
from unittest.mock import MagicMock

import pytest
from sqlalchemy.exc import IntegrityError, OperationalError
from sqlmodel import Session, select

from vibe_modeling.backend.core import _metamodel_cleanups as cleanups
from vibe_modeling.backend.core._names import agent_business_segment
from vibe_modeling.backend.core._runs import LOCK_BUSY_MESSAGE, BusinessBusy, lock_business_for_run
from vibe_modeling.backend.db_models import (
    Business,
    MetamodelCleanup,
    ModelVersion,
    ModelVersionInstall,
    Run,
    RunOperation,
    VibeInput,
    VibeInputContextLink,
)
from vibe_modeling.backend.services.operations import _version_lifecycle as lc

from ._assess_helpers import changed_tables, table_digests

CAT = "cat_a"
OTHER = "cat_b"
BUSINESS = "Acme Co"
SEGMENT = agent_business_segment(BUSINESS)


def _biz(session: Session, name: str = BUSINESS) -> Business:
    biz = Business(name=name, description="d")
    session.add(biz)
    session.flush()
    return biz


def _mv(
    session: Session, biz: Business, version: int, *, scope: str = "ecm", status: str = "superseded",
    files: Optional[str] = CAT, **extra,
) -> ModelVersion:
    mv = ModelVersion(business_id=biz.id, version=version, scope=scope, status=status, files_catalog=files, **extra)
    session.add(mv)
    session.flush()
    return mv


def _run(session: Session, biz: Business, intent: str = "install", status: str = "completed") -> Run:
    run = Run(business_id=biz.id, intent=intent, status=status)
    session.add(run)
    session.flush()
    return run


def _rows(session: Session, mv: ModelVersion, *, open_only: bool = False) -> list[ModelVersionInstall]:
    stmt = select(ModelVersionInstall).where(ModelVersionInstall.version_id == mv.id)
    if open_only:
        stmt = stmt.where(ModelVersionInstall.uninstalled_at.is_(None))
    return list(session.exec(stmt).all())


def _open(session: Session, mv: ModelVersion) -> list[str]:
    return sorted(r.catalog for r in _rows(session, mv, open_only=True))


@pytest.fixture
def metamodel(monkeypatch):
    """The ``_metamodel`` cleaner, recorded; ``fail`` holds the catalogs whose
    cleanup raises."""
    state = MagicMock(calls=[], fail=set())

    class _Sync:
        def __init__(self, *_a, **_k):
            pass

        def delete_metamodel_rows(self, **kw):
            state.calls.append(kw)
            if kw["catalog"] in state.fail:
                raise RuntimeError(f"warehouse unavailable for {kw['catalog']}")
            return True

    monkeypatch.setattr("vibe_modeling.backend.model_sync.ModelSyncService", _Sync)
    return state


# --- Install rows -----------------------------------------------------------


class TestInstallRows:
    def test_install_into_two_catalogs_keeps_both(self, engine):
        with Session(engine) as s:
            biz = _biz(s)
            mv = _mv(s, biz, 1, status="completed")
            r1, r2 = _run(s, biz), _run(s, biz)
            lc.record_install(s, mv, run_id=r1.id, catalog=CAT)
            lc.record_install(s, mv, run_id=r2.id, catalog=OTHER)
            s.commit()
            assert (mv.deployment_status, mv.uc_catalog) == ("deployed", OTHER)
            assert _open(s, mv) == [CAT, OTHER]
            assert {r.catalog: r.installed_by_run_id for r in _rows(s, mv)} == {CAT: r1.id, OTHER: r2.id}
            assert lc.installed_catalogs(s, mv) == [OTHER, CAT]

    def test_installing_again_where_it_is_installed_refreshes_that_row(self, engine):
        with Session(engine) as s:
            biz = _biz(s)
            mv = _mv(s, biz, 1, status="completed")
            for catalog in (CAT, OTHER, CAT):
                lc.mark_version_deployed(s, mv, catalog)
            s.commit()
            assert len(_rows(s, mv)) == 2
            assert mv.uc_catalog == CAT

    def test_uninstall_closes_only_that_catalog(self, engine):
        with Session(engine) as s:
            biz = _biz(s)
            mv = _mv(s, biz, 1, status="completed")
            lc.mark_version_deployed(s, mv, CAT)
            lc.mark_version_deployed(s, mv, OTHER)
            run = _run(s, biz, "uninstall")
            lc.mark_version_uninstalled(s, mv, OTHER, run_id=run.id)
            s.commit()
            assert (mv.deployment_status, mv.uc_catalog) == ("deployed", CAT)
            closed = next(r for r in _rows(s, mv) if r.catalog == OTHER)
            assert closed.uninstalled_at is not None and closed.uninstalled_by_run_id == run.id

    def test_the_installed_refusal_follows_deployment_status_through_every_transition(self, engine):
        """The UI's delete rule (``lib/version-lifecycle.deleteState``) reads
        only ``deployment_status``; the server's ``delete_refusal`` also counts
        open install rows. They agree because every install-row writer mirrors
        the open rows into ``deployment_status``."""
        third = "third_catalog"
        with Session(engine) as s:
            biz = _biz(s)
            mv = _mv(s, biz, 1, status="completed")
            steps = [
                lambda: lc.mark_version_deployed(s, mv, CAT),
                lambda: lc.mark_version_deployed(s, mv, OTHER),
                lambda: lc.mark_version_deployed(s, mv, third),
                lambda: lc.mark_version_uninstalled(s, mv, OTHER),
                lambda: lc.mark_version_uninstalled(s, mv, CAT),
                lambda: lc.mark_version_uninstalled(s, mv, third),
                lambda: lc.restore_evicted_deployments(s, [mv.id], catalog=OTHER),
                lambda: lc.mark_version_uninstalled(s, mv, OTHER),
            ]
            for step in steps:
                step()
                s.flush()
                refusal = lc.delete_refusal(s, mv)
                server_installed = refusal is not None and isinstance(refusal.detail, dict) and refusal.detail.get("error") == "installed"
                assert server_installed == (mv.deployment_status == "deployed"), (
                    _open(s, mv), mv.deployment_status,
                )

    def test_the_last_uninstall_keeps_the_last_location(self, engine):
        with Session(engine) as s:
            biz = _biz(s)
            mv = _mv(s, biz, 1, status="completed")
            lc.mark_version_deployed(s, mv, CAT)
            lc.mark_version_uninstalled(s, mv, CAT)
            s.commit()
            assert (mv.deployment_status, mv.uc_catalog, _open(s, mv)) == ("uninstalled", CAT, [])

    def test_uninstall_from_a_catalog_it_was_never_installed_in_changes_nothing(self, engine):
        with Session(engine) as s:
            biz = _biz(s)
            mv = _mv(s, biz, 1, status="completed")
            lc.mark_version_deployed(s, mv, CAT)
            lc.mark_version_uninstalled(s, mv, OTHER)
            s.commit()
            assert (mv.deployment_status, mv.uc_catalog, _open(s, mv)) == ("deployed", CAT, [CAT])

    def test_a_legacy_deployed_version_gets_its_row_on_the_next_install(self, engine):
        with Session(engine) as s:
            biz = _biz(s)
            mv = _mv(s, biz, 1, status="completed", deployment_status="deployed", uc_catalog=CAT)
            assert _rows(s, mv) == []
            assert lc.installed_catalogs(s, mv) == [CAT]
            lc.mark_version_deployed(s, mv, OTHER)
            s.commit()
            assert _open(s, mv) == [CAT, OTHER]

    def test_every_scope_eviction_closes_the_other_scopes_row_in_that_catalog(self, engine):
        """A shrink drops every schema of the business in its catalog: the ECM
        installed there is no longer installed there, and stays installed
        where else it is."""
        with Session(engine) as s:
            biz = _biz(s)
            ecm = _mv(s, biz, 1, status="completed")
            lc.mark_version_deployed(s, ecm, OTHER)
            lc.mark_version_deployed(s, ecm, CAT)
            mvm = _mv(s, biz, 1, scope="mvm", status="completed")
            lc.mark_version_deployed(s, mvm, CAT)
            evicted = lc.evict_deployed_siblings(s, mvm, same_scope=False)
            s.commit()
            assert evicted == [ecm.id]
            assert (ecm.deployment_status, ecm.uc_catalog, _open(s, ecm)) == ("deployed", OTHER, [OTHER])

    def test_same_scope_eviction_leaves_the_other_scope(self, engine):
        with Session(engine) as s:
            biz = _biz(s)
            ecm = _mv(s, biz, 1, status="completed")
            lc.mark_version_deployed(s, ecm, CAT)
            old_mvm = _mv(s, biz, 1, scope="mvm")
            lc.mark_version_deployed(s, old_mvm, CAT)
            new_mvm = _mv(s, biz, 2, scope="mvm", status="completed")
            lc.mark_version_deployed(s, new_mvm, CAT)
            assert lc.evict_deployed_siblings(s, new_mvm, same_scope=True) == [old_mvm.id]
            s.commit()
            assert _open(s, ecm) == [CAT] and _open(s, old_mvm) == []

    def test_rollback_reopens_the_row_the_eviction_closed(self, engine):
        with Session(engine) as s:
            biz = _biz(s)
            old = _mv(s, biz, 1)
            lc.mark_version_deployed(s, old, CAT)
            row_id = _rows(s, old)[0].id
            new = _mv(s, biz, 2, status="completed")
            lc.mark_version_deployed(s, new, CAT)
            ids = lc.evict_deployed_siblings(s, new, same_scope=True)
            assert old.deployment_status == "uninstalled"
            lc.restore_evicted_deployments(s, ids, catalog=CAT)
            s.commit()
            assert (old.deployment_status, old.uc_catalog) == ("deployed", CAT)
            assert [(r.id, r.uninstalled_at) for r in _rows(s, old)] == [(row_id, None)]

    def test_the_partial_unique_index_allows_one_open_row_per_catalog(self, engine):
        with Session(engine) as s:
            biz = _biz(s)
            mv = _mv(s, biz, 1, status="completed")
            s.add(ModelVersionInstall(version_id=mv.id, catalog=CAT, uninstalled_at=datetime.now(timezone.utc)))
            s.add(ModelVersionInstall(version_id=mv.id, catalog=CAT))
            s.commit()
            s.add(ModelVersionInstall(version_id=mv.id, catalog=CAT))
            with pytest.raises(IntegrityError):
                s.commit()


class TestReadersUseTheRows:
    def test_a_version_once_installed_in_a_catalog_stays_recorded_there(self, engine):
        """v3 was installed in X, moved to Z and uninstalled from X by no
        uninstall step whose registry release went through (so its rows in X
        were not released): the agent's registry in X still holds v3, so v2
        is not X's latest installed and a draft on v2 keeps it as an
        occupant."""
        with Session(engine) as s:
            biz = _biz(s)
            v2 = _mv(s, biz, 2, files="elsewhere")
            lc.mark_version_deployed(s, v2, CAT)
            v3 = _mv(s, biz, 3, status="completed", files="elsewhere")
            lc.mark_version_deployed(s, v3, CAT)
            lc.mark_version_deployed(s, v3, OTHER)
            lc.mark_version_uninstalled(s, v3, CAT)
            assert v3.uc_catalog == OTHER
            assert lc._newer_recorded(s, v2, CAT, exclude_ids=(v2.id,))
            assert not lc.base_is_latest_installed(s, v2, CAT, new_version_id="new")
            draft = _mv(s, biz, 4, status="draft", dry_run=True, base_version_id=v2.id,
                        scope_fence_mode="all", scope_base_version=2, scope_base_scope="ecm")
            assert lc.catalog_occupant(s, draft, CAT).id == v2.id

    def test_the_head_installed_in_two_catalogs_promotes_in_either(self, engine):
        with Session(engine) as s:
            biz = _biz(s)
            v3 = _mv(s, biz, 3)
            v5 = _mv(s, biz, 5, status="completed")
            lc.mark_version_deployed(s, v5, CAT)
            lc.mark_version_deployed(s, v5, OTHER)
            assert v5.uc_catalog == OTHER
            assert lc.will_promote(s, v3, CAT)
            assert lc.will_promote(s, v3, OTHER)
            assert not lc.will_promote(s, v3, "third")

    def test_an_occupant_installed_in_two_catalogs_is_found_in_both(self, engine):
        with Session(engine) as s:
            biz = _biz(s)
            v1 = _mv(s, biz, 1)
            v2 = _mv(s, biz, 2, status="completed")
            lc.mark_version_deployed(s, v2, CAT)
            lc.mark_version_deployed(s, v2, OTHER)
            assert lc.catalog_occupant(s, v1, CAT).id == v2.id
            assert lc.catalog_occupant(s, v1, OTHER).id == v2.id


# --- Delete rules -----------------------------------------------------------


def _delete(client, biz_id: str, version_id: str):
    return client.delete(f"/api/businesses/{biz_id}/versions/{version_id}")


class TestDeleteRules:
    def test_an_installed_version_is_refused_and_nothing_changes(self, engine, client_with_agent, metamodel):
        with Session(engine) as s:
            biz = _biz(s)
            mv = _mv(s, biz, 1, status="completed")
            lc.mark_version_deployed(s, mv, CAT)
            lc.mark_version_deployed(s, mv, OTHER)
            s.commit()
            biz_id, vid = biz.id, mv.id
        before = table_digests(engine)
        r = _delete(client_with_agent, biz_id, vid)
        assert r.status_code == 409, r.text
        assert r.json()["detail"] == {
            "error": "installed",
            "catalogs": [OTHER, CAT],
            "message": f"v1 ECM is installed in {OTHER}, {CAT}. Uninstall it first (Uninstall on its page), then delete it.",
        }
        assert changed_tables(before, table_digests(engine)) == set()
        assert metamodel.calls == []

    def test_a_version_below_newer_ones_is_refused(self, engine, client_with_agent, metamodel):
        with Session(engine) as s:
            biz = _biz(s)
            v1, v2 = _mv(s, biz, 1), _mv(s, biz, 2)
            _mv(s, biz, 3, status="completed")
            _mv(s, biz, 4, status="draft", dry_run=True)
            s.commit()
            biz_id, ids = biz.id, (v1.id, v2.id)
        before = table_digests(engine)
        r = _delete(client_with_agent, biz_id, ids[0])
        assert r.status_code == 409, r.text
        assert r.json()["detail"] == "Delete the newer versions first (v2, v3)"
        assert changed_tables(before, table_digests(engine)) == set()

    def test_the_head_restores_its_newest_superseded_not_replaced_predecessor(
        self, engine, client_with_agent, metamodel,
    ):
        with Session(engine) as s:
            biz = _biz(s)
            v2 = _mv(s, biz, 2)
            v3 = _mv(s, biz, 3, replaced_at=datetime.now(timezone.utc))
            v4 = _mv(s, biz, 4, status="completed")
            s.commit()
            biz_id, ids = biz.id, (v2.id, v3.id, v4.id)
        r = _delete(client_with_agent, biz_id, ids[2])
        assert r.status_code == 200, r.text
        assert r.json()["previous_version"] == 2
        with Session(engine) as s:
            assert [s.get(ModelVersion, i).status for i in ids[:2]] == ["completed", "superseded"]

    @pytest.mark.parametrize("status", ["draft", "failed", "generating", "cancelled"])
    def test_drafts_and_unfinished_rows_are_deletable_anywhere(self, engine, client_with_agent, metamodel, status):
        with Session(engine) as s:
            biz = _biz(s)
            _mv(s, biz, 1, status="completed")
            mv = _mv(s, biz, 1, scope="mvm", status=status)
            _mv(s, biz, 2, scope="mvm", status="completed")
            s.commit()
            biz_id, vid = biz.id, mv.id
        r = _delete(client_with_agent, biz_id, vid)
        assert r.status_code == 200, r.text
        assert r.json()["previous_version"] is None

    def test_peeling_both_scopes_to_zero_lets_new_base_model_run(self, engine, client_with_agent, metamodel):
        with Session(engine) as s:
            biz = _biz(s)
            order = [_mv(s, biz, n, status="completed" if n == 3 else "superseded").id for n in (3, 2, 1)]
            order += [_mv(s, biz, n, scope="mvm", status="completed" if n == 2 else "superseded").id for n in (2, 1)]
            s.commit()
            biz_id = biz.id
        for vid in order:
            r = _delete(client_with_agent, biz_id, vid)
            assert r.status_code == 200, r.text
        with Session(engine) as s:
            assert s.exec(select(ModelVersion).where(ModelVersion.business_id == biz_id)).all() == []
        v = client_with_agent.post(
            f"/api/businesses/{biz_id}/runs/validate",
            json={"intent": "new-base-model", "catalog": "tgt", "cataloging_style": "One Catalog"},
        )
        assert v.status_code == 200, v.text
        assert not [b for b in v.json()["blockers"] if "New Base Model needs" in b["message"]]


class TestInTheDeleteTransaction:
    def test_the_applied_feedback_of_the_deleted_head_is_open_again(self, engine, client_with_agent, metamodel):
        with Session(engine) as s:
            biz = _biz(s)
            v1 = _mv(s, biz, 1)
            v2 = _mv(s, biz, 2, status="completed", base_version_id=v1.id)
            vibe = _run(s, biz, "vibe-iterate")
            s.add(RunOperation(
                run_id=vibe.id, step_index=0, operation_name="vibe_iterate", status="succeeded",
                output_version_id=v2.id, completed_at=datetime.now(timezone.utc),
            ))
            promote = _run(s, biz, "install")
            v2.promoted_by_run_id = promote.id
            by_vibe = VibeInput(business_id=biz.id, text="split orders", consumed=True, consumed_by_run_id=vibe.id)
            by_install = VibeInput(business_id=biz.id, text="rename x", consumed=True, consumed_by_run_id=promote.id)
            untouched = VibeInput(business_id=biz.id, text="other", consumed=True, consumed_by_run_id=None)
            s.add_all([by_vibe, by_install, untouched])
            s.commit()
            biz_id, vid = biz.id, v2.id
            ids = (by_vibe.id, by_install.id, untouched.id)
        r = _delete(client_with_agent, biz_id, vid)
        assert r.status_code == 200, r.text
        assert r.json()["reopened_input_count"] == 2
        with Session(engine) as s:
            got = [(s.get(VibeInput, i).consumed, s.get(VibeInput, i).consumed_by_run_id) for i in ids]
            assert got == [(False, None), (False, None), (True, None)]

    @pytest.mark.parametrize("review_enabled", [True, False])
    def test_the_change_review_feedback_of_the_deleted_version_goes(
        self, engine, client_with_agent, metamodel, config, review_enabled,
    ):
        """With the run change review off its feedback is ordinary feedback and stays."""
        config.run_change_review_enabled = review_enabled
        with Session(engine) as s:
            biz = _biz(s)
            mv = _mv(s, biz, 1, status="completed")
            rejection = VibeInput(business_id=biz.id, text="undo x", origin="change_rejection")
            done = VibeInput(business_id=biz.id, text="undo y", origin="change_rejection", consumed=True)
            user = VibeInput(business_id=biz.id, text="mine", origin="user")
            s.add_all([rejection, done, user])
            s.flush()
            for vi in (rejection, done, user):
                s.add(VibeInputContextLink(input_id=vi.id, version_id=mv.id))
            s.commit()
            biz_id, vid, ids = biz.id, mv.id, (rejection.id, done.id, user.id)
        assert _delete(client_with_agent, biz_id, vid).status_code == 200
        with Session(engine) as s:
            assert [s.get(VibeInput, i) is not None for i in ids] == [not review_enabled, True, True]
            if review_enabled:
                assert s.exec(
                    select(VibeInputContextLink).where(VibeInputContextLink.input_id == ids[0])
                ).all() == []

    def test_lineage_pointers_to_the_deleted_version_stay(self, engine, client_with_agent, metamodel):
        """X-FB labels a shrink output whose parent is gone by the dangling id."""
        with Session(engine) as s:
            biz = _biz(s)
            ecm = _mv(s, biz, 5, status="completed")
            mvm = _mv(s, biz, 5, scope="mvm", status="completed", base_version_id=ecm.id)
            s.commit()
            biz_id, ecm_id, mvm_id = biz.id, ecm.id, mvm.id
        assert _delete(client_with_agent, biz_id, ecm_id).status_code == 200
        with Session(engine) as s:
            assert s.get(ModelVersion, mvm_id).base_version_id == ecm_id

    def test_cleanup_rows_are_committed_with_the_delete(self, engine, monkeypatch, metamodel):
        seen: list = []

        def _after_commit(session, ws, warehouse_id, ids):
            with Session(engine) as other:
                seen.extend(
                    (c.catalog, c.status, c.reason, c.business_segment, c.version, c.scope)
                    for c in other.exec(select(MetamodelCleanup)).all()
                )
                seen.append(other.get(ModelVersion, vid))
            return cleanups.CleanupSummary(pending=len(list(ids)))

        monkeypatch.setattr(cleanups, "run_cleanups", _after_commit)
        with Session(engine) as s:
            biz = _biz(s)
            mv = _mv(s, biz, 1, status="completed")
            lc.mark_version_deployed(s, mv, OTHER)
            lc.mark_version_uninstalled(s, mv, OTHER)
            s.commit()
            vid = mv.id
            out = lc.delete_version(s, MagicMock(), "wh", mv)
        assert out.cleanup_pending == 2
        assert sorted(seen[:-1]) == [
            (CAT, "pending", "version_delete", SEGMENT, 1, "ecm"),
            (OTHER, "pending", "version_delete", SEGMENT, 1, "ecm"),
        ]
        assert seen[-1] is None


class TestImportsAndRaces:
    def test_an_import_is_cleaned_where_it_was_seeded_never_in_its_path_catalog(
        self, engine, client_with_agent, metamodel,
    ):
        """An import read from ``src_cat`` seeded its registry rows into the
        metamodel catalog (``test_metamodel_catalog`` in ``client_with_agent``)
        and was installed into OTHER: those two are cleaned, ``src_cat`` is
        never touched."""
        with Session(engine) as s:
            biz = _biz(s)
            mv = _mv(s, biz, 1, status="completed", files="src_cat",
                     import_source_path="/Volumes/src_cat/x/y/model.json")
            lc.mark_version_deployed(s, mv, OTHER)
            lc.mark_version_uninstalled(s, mv, OTHER)
            s.commit()
            assert lc.metamodel_cleanup_catalogs(s, mv) == ["test_metamodel_catalog", OTHER]
            biz_id, vid = biz.id, mv.id
        r = _delete(client_with_agent, biz_id, vid)
        assert r.status_code == 200, r.text
        assert [c["catalog"] for c in metamodel.calls] == ["test_metamodel_catalog", OTHER]
        with Session(engine) as s:
            assert sorted(c.catalog for c in s.exec(select(MetamodelCleanup)).all()) == sorted(
                ["test_metamodel_catalog", OTHER]
            )

    def test_stale_version_read_before_the_lock(self, engine, client_with_agent, metamodel):
        """Tester F1: request B loaded the version before request A deleted it
        and committed; B then takes the lock and must see the row gone (404),
        writing no second cleanup row."""
        with Session(engine) as s:
            biz = _biz(s)
            _mv(s, biz, 1)
            mv = _mv(s, biz, 2, status="completed")
            s.commit()
            biz_id, vid = biz.id, mv.id
        with Session(engine) as b:
            mv_b = b.get(ModelVersion, vid)
            r = _delete(client_with_agent, biz_id, vid)
            assert r.status_code == 200, r.text
            with Session(engine) as chk:
                assert chk.get(ModelVersion, vid) is None
                rows_after_first = len(chk.exec(select(MetamodelCleanup)).all())
            with pytest.raises(lc.VersionDeleteRefused) as exc:
                lc.delete_version(b, MagicMock(), "wh", mv_b)
            assert exc.value.status_code == 404
        with Session(engine) as chk:
            assert len(chk.exec(select(MetamodelCleanup)).all()) == rows_after_first


# --- Cleanups ---------------------------------------------------------------


def _deleted_with_failing_cleanup(engine, metamodel) -> tuple[str, str]:
    """A version deleted while its cleanup in OTHER fails; returns the
    business id and the failed row's id."""
    metamodel.fail = {OTHER}
    with Session(engine) as s:
        biz = _biz(s)
        mv = _mv(s, biz, 1, status="completed")
        lc.mark_version_deployed(s, mv, OTHER)
        lc.mark_version_uninstalled(s, mv, OTHER)
        s.commit()
        out = lc.delete_version(s, MagicMock(), "wh", mv)
        assert (out.cleanup_done, out.cleanup_failed, out.metamodel_rows_cleaned) == (1, 1, True)
        failed = s.exec(select(MetamodelCleanup).where(MetamodelCleanup.status == "failed")).one()
        assert (failed.catalog, failed.attempts) == (OTHER, 1)
        assert "warehouse unavailable" in failed.last_error
        return biz.id, failed.id


class TestCleanups:
    def test_the_sweep_retries_until_three_attempts(self, engine, metamodel):
        biz_id, cid = _deleted_with_failing_cleanup(engine, metamodel)
        with Session(engine) as s:
            for expected in (2, 3, 3):
                cleanups.sweep_metamodel_cleanups(s, MagicMock(), "wh")
                assert s.get(MetamodelCleanup, cid).attempts == expected
            metamodel.fail = set()
            cleanups.sweep_metamodel_cleanups(s, MagicMock(), "wh")
            assert s.get(MetamodelCleanup, cid).status == "failed"
            assert [c.id for c in cleanups.unfinished_cleanups(s, SEGMENT, scope="ecm", catalog=OTHER)] == [cid]

    def test_the_sweep_finishes_a_pending_row(self, engine, metamodel):
        with Session(engine) as s:
            row = cleanups.record_cleanups(
                s, business_segment=SEGMENT, version=3, scope="mvm", catalogs=[CAT], reason="version_delete",
            )[0]
            s.commit()
            summary = cleanups.sweep_metamodel_cleanups(s, MagicMock(), "wh")
            assert (summary.done, row.status, row.attempts) == (1, "done", 1)

    def test_without_a_warehouse_a_cleanup_fails_visibly(self, engine, metamodel):
        with Session(engine) as s:
            row = cleanups.record_cleanups(
                s, business_segment=SEGMENT, version=3, scope="mvm", catalogs=[CAT], reason="version_delete",
            )[0]
            s.commit()
            cleanups.run_cleanup(s, MagicMock(), None, row)
            assert row.status == "failed" and "No SQL warehouse" in row.last_error
            assert metamodel.calls == []

    def test_retry_resets_the_attempts_and_finishes_it(self, engine, client_with_agent, metamodel):
        biz_id, cid = _deleted_with_failing_cleanup(engine, metamodel)
        listed = client_with_agent.get(f"/api/businesses/{biz_id}/metamodel-cleanups")
        assert listed.status_code == 200, listed.text
        assert [(c["id"], c["status"], c["catalog"]) for c in listed.json()] == [(cid, "failed", OTHER)]
        assert listed.json()[0]["updated_at"].endswith(("+00:00", "Z"))
        metamodel.fail = set()
        r = client_with_agent.post(f"/api/businesses/{biz_id}/metamodel-cleanups/{cid}/retry")
        assert r.status_code == 200, r.text
        assert (r.json()["status"], r.json()["attempts"], r.json()["last_error"]) == ("done", 1, None)
        assert client_with_agent.get(f"/api/businesses/{biz_id}/metamodel-cleanups").json() == []

    def test_retry_waits_for_an_active_run(self, engine, client_with_agent, metamodel):
        biz_id, cid = _deleted_with_failing_cleanup(engine, metamodel)
        with Session(engine) as s:
            s.add(Run(id="busy", business_id=biz_id, intent="vibe-iterate", status="running"))
            s.commit()
        metamodel.fail = set()
        r = client_with_agent.post(f"/api/businesses/{biz_id}/metamodel-cleanups/{cid}/retry")
        assert r.status_code == 409, r.text
        assert r.json()["detail"] == "Business already has an active run: busy"
        with Session(engine) as s:
            assert s.get(MetamodelCleanup, cid).status == "failed"

    def test_another_business_cannot_retry_it(self, engine, client_with_agent, metamodel):
        _, cid = _deleted_with_failing_cleanup(engine, metamodel)
        with Session(engine) as s:
            other = _biz(s, "Other Co")
            s.commit()
            other_id = other.id
        r = client_with_agent.post(f"/api/businesses/{other_id}/metamodel-cleanups/{cid}/retry")
        assert r.status_code == 404, r.text

    def test_the_delete_reports_the_cleanup_summary(self, engine, client_with_agent, metamodel):
        metamodel.fail = {OTHER}
        with Session(engine) as s:
            biz = _biz(s)
            mv = _mv(s, biz, 1, status="completed")
            lc.mark_version_deployed(s, mv, OTHER)
            lc.mark_version_uninstalled(s, mv, OTHER)
            s.commit()
            biz_id, vid = biz.id, mv.id
        r = _delete(client_with_agent, biz_id, vid)
        assert r.status_code == 200, r.text
        assert r.json()["metamodel_cleanup"] == {"done": 1, "pending": 0, "failed": 1}
        assert r.json()["metamodel_rows_cleaned"] is True

    def test_a_reused_number_keeps_the_live_versions_rows(self, engine, metamodel):
        """v5 ECM was deleted while its cleanup in OTHER failed; then a v5 ECM
        of a business with the same segment is installed into OTHER (from
        another catalog). The sweep must not delete the live version's rows."""
        with Session(engine) as s:
            row = cleanups.record_cleanups(
                s, business_segment=SEGMENT, version=5, scope="ecm", catalogs=[OTHER], reason="version_delete",
            )[0]
            row.status, row.attempts = "failed", 1
            biz = _biz(s)
            live = _mv(s, biz, 5, status="completed", files="elsewhere")
            lc.mark_version_deployed(s, live, OTHER)
            s.commit()
            cleanups.sweep_metamodel_cleanups(s, MagicMock(), "wh")
            assert metamodel.calls == []
            assert row.status == "done"
            assert row.last_error == f"Not removed: v5 ECM of {BUSINESS} now holds these registry rows in {OTHER}"

    def test_a_live_version_elsewhere_does_not_stop_the_cleanup(self, engine, metamodel):
        with Session(engine) as s:
            row = cleanups.record_cleanups(
                s, business_segment=SEGMENT, version=5, scope="ecm", catalogs=[OTHER], reason="version_delete",
            )[0]
            biz = _biz(s)
            _mv(s, biz, 5, status="completed", files=CAT)
            s.commit()
            cleanups.run_cleanup(s, MagicMock(), "wh", row)
            assert [c["catalog"] for c in metamodel.calls] == [OTHER]
            assert (row.status, row.last_error) == ("done", None)

    def test_a_post_install_delete_records_its_reason(self, engine, metamodel):
        import json

        from vibe_modeling.backend.db_models import RunPostInstallDelete

        with Session(engine) as s:
            biz = _biz(s)
            replaced = _mv(s, biz, 5, replaced_at=datetime.now(timezone.utc))
            _mv(s, biz, 3, status="completed")
            run = Run(business_id=biz.id, intent="install", status="completed",
                      parameters_json=json.dumps({"also_delete_replaced": True}))
            s.add(run)
            s.flush()
            s.add(RunPostInstallDelete(run_id=run.id, version_id=replaced.id, version=5, scope="ecm"))
            s.commit()
            lc.run_post_install_deletes(s, MagicMock(), "wh", run_id=run.id)
            assert s.get(RunPostInstallDelete, (run.id, replaced.id)).status == "deleted"
            reasons = {c.reason for c in s.exec(select(MetamodelCleanup)).all()}
            assert reasons == {"post_install_delete"}


# --- The lock ---------------------------------------------------------------


class _LockHeld(Exception):
    sqlstate = "55P03"


class TestLock:
    def test_an_active_run_refuses_except_the_allowed_one(self, engine):
        with Session(engine) as s:
            biz = _biz(s)
            run_id = _run(s, biz, status="running").id
            s.commit()
            with pytest.raises(BusinessBusy) as exc:
                lock_business_for_run(s, biz.id)
            assert (exc.value.status_code, exc.value.active_run_id) == (409, run_id)
            lock_business_for_run(s, biz.id, allow_run_id=run_id)

    def test_a_held_lock_rolls_back_and_refuses(self):
        session = MagicMock()
        session.exec.side_effect = OperationalError("SELECT ... FOR UPDATE NOWAIT", {}, _LockHeld())
        with pytest.raises(BusinessBusy) as exc:
            lock_business_for_run(session, "biz")
        assert (exc.value.status_code, exc.value.detail, exc.value.active_run_id) == (409, LOCK_BUSY_MESSAGE, None)
        session.rollback.assert_called_once()

    def test_another_database_error_is_not_taken_for_the_lock(self):
        session = MagicMock()
        session.exec.side_effect = OperationalError("SELECT 1", {}, Exception("connection reset"))
        with pytest.raises(OperationalError):
            lock_business_for_run(session, "biz")
        session.rollback.assert_not_called()

    def test_a_delete_that_meets_the_held_lock_waits(self, engine, metamodel, monkeypatch):
        def _busy(session, business_id, *, allow_run_id=None):
            raise BusinessBusy(LOCK_BUSY_MESSAGE)

        monkeypatch.setattr(lc, "lock_business_for_run", _busy)
        with Session(engine) as s:
            biz = _biz(s)
            mv = _mv(s, biz, 1, status="completed")
            s.commit()
            with pytest.raises(lc.ActiveRunRefused) as exc:
                lc.delete_version(s, MagicMock(), "wh", mv)
            assert exc.value.message == LOCK_BUSY_MESSAGE
            assert s.get(ModelVersion, mv.id) is not None


# --- Probe and reconcile ----------------------------------------------------


def _schemas(*names):
    out = []
    for n in names:
        sch = MagicMock()
        sch.name = n
        out.append(sch)
    return out


class TestProbeAndReconcile:
    def _installed_twice(self, engine) -> str:
        from vibe_modeling.backend.db_models import Domain

        with Session(engine) as s:
            biz = _biz(s)
            mv = _mv(s, biz, 1, status="completed")
            s.add(Domain(version_id=mv.id, name="sales", database_name="sales"))
            lc.mark_version_deployed(s, mv, CAT)
            lc.mark_version_deployed(s, mv, OTHER)
            s.commit()
            return mv.id

    def test_the_probe_checks_every_catalog_it_is_installed_in(self, engine, client, mock_ws):
        vid = self._installed_twice(engine)
        mock_ws.schemas.list.side_effect = lambda catalog_name: _schemas("ecm_sales") if catalog_name == OTHER else []
        r = client.get(f"/api/model-versions/{vid}/installation-status")
        assert r.status_code == 200, r.text
        body = r.json()
        assert (body["deployment_catalog"], body["also_installed_in"], body["in_sync"]) == (OTHER, [CAT], False)
        assert body["missing_schemas"] == [f"{CAT}.ecm_sales"]

    def test_reconcile_closes_only_the_catalog_that_lost_its_schemas(self, engine, client, mock_ws):
        vid = self._installed_twice(engine)
        mock_ws.schemas.list.side_effect = lambda catalog_name: _schemas("ecm_sales") if catalog_name == OTHER else []
        r = client.post(f"/api/model-versions/{vid}/reconcile-installation")
        assert r.status_code == 200, r.text
        assert r.json()["new_deployment_status"] == "deployed"
        with Session(engine) as s:
            mv = s.get(ModelVersion, vid)
            assert (mv.uc_catalog, _open(s, mv)) == (OTHER, [OTHER])
