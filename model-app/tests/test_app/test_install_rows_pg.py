"""Real Postgres checks for A2b: the business lock and the install rows.

Run by ``scripts/smoke/run_pg_branch_test.sh tests/test_app/test_install_rows_pg.py
A2B_PG_DATABASE`` on an ephemeral Lakebase branch; skipped unless ``A2B_PG_DATABASE`` is set.
Everything runs in a new, empty database on that branch, built by ``reconcile_schema`` as a fresh
install, so the cloned production data is never read or written. SQLite ignores ``FOR UPDATE``
and does not enforce the foreign keys of the default test engine, so these run here:

- ``lock_business_for_run`` takes ``FOR UPDATE NOWAIT``: a second session is refused at once with
  "Another request for this business is in progress", its transaction is rolled back and usable,
  and it gets the lock once the first commits; with ``rollback=False`` inside a savepoint only the
  savepoint is rolled back and the transaction's earlier work commits; a run committed by the holder is seen by the next
  one (the active-run re-check);
- two concurrent deletes on one business: one deletes, the other is refused and changes nothing;
- the partial unique index refuses a second open row for ``(version, catalog)``, the writer
  refreshes the open row instead, and a closed row does not count;
- ``mark_version_deployed`` on a version not flushed yet writes the version before its install row;
- deleting a version removes its install rows (ON DELETE CASCADE) and keeps its cleanup rows.
"""
from __future__ import annotations

import os
import sys
import threading
import time
from unittest.mock import MagicMock

import pytest
from sqlalchemy import text
from sqlalchemy.exc import IntegrityError
from sqlmodel import Session, select

sys.path.insert(0, os.path.dirname(__file__))

DATABASE = os.environ.get("A2B_PG_DATABASE", "")
pytestmark = pytest.mark.skipif(not DATABASE, reason="needs a Lakebase branch (set A2B_PG_DATABASE)")

from _pg_branch import fresh_database_engine  # noqa: E402

from vibe_modeling.backend.core._runs import LOCK_BUSY_MESSAGE, BusinessBusy, lock_business_for_run  # noqa: E402
from vibe_modeling.backend.db_models import (  # noqa: E402
    Business,
    MetamodelCleanup,
    ModelVersion,
    ModelVersionInstall,
    Run,
)
from vibe_modeling.backend.services.operations import _version_lifecycle as lc  # noqa: E402


@pytest.fixture(scope="module")
def pg_engine():
    from vibe_modeling.backend.migrations import reconcile_schema

    engine = fresh_database_engine(DATABASE)
    reconcile_schema(engine)
    yield engine
    engine.dispose()


@pytest.fixture
def no_metamodel(monkeypatch):
    class _Sync:
        def __init__(self, *_a, **_k):
            pass

        def delete_metamodel_rows(self, **_kw):
            return True

    monkeypatch.setattr("vibe_modeling.backend.model_sync.ModelSyncService", _Sync)


def _business(engine, name: str) -> str:
    with Session(engine) as s:
        biz = Business(name=name, description="d")
        s.add(biz)
        s.commit()
        return biz.id


def _version(engine, business_id: str, version: int, *, status: str = "completed") -> str:
    with Session(engine) as s:
        mv = ModelVersion(business_id=business_id, version=version, scope="ecm", status=status,
                          files_catalog="cat_a")
        s.add(mv)
        s.commit()
        return mv.id


class TestLock:
    def test_a_second_session_is_refused_at_once_and_stays_usable(self, pg_engine):
        biz_id = _business(pg_engine, "Lock One")
        with Session(pg_engine) as holder, Session(pg_engine) as other:
            lock_business_for_run(holder, biz_id)
            started = time.monotonic()
            with pytest.raises(BusinessBusy) as exc:
                lock_business_for_run(other, biz_id)
            assert time.monotonic() - started < 5
            assert (exc.value.detail, exc.value.active_run_id) == (LOCK_BUSY_MESSAGE, None)
            assert other.exec(text("SELECT 1")).one() == (1,)
            holder.commit()
            lock_business_for_run(other, biz_id)
            other.commit()

    def test_a_refusal_inside_a_savepoint_keeps_the_transaction(self, pg_engine):
        """``rollback=False`` in a savepoint (initial sync's per-business lock):
        a held lock is refused at once, only the savepoint is rolled back, and
        the work already in the transaction commits."""
        biz_id = _business(pg_engine, "Lock Savepoint")
        kept_id = _business(pg_engine, "Lock Savepoint Kept")
        with Session(pg_engine) as holder, Session(pg_engine) as other:
            lock_business_for_run(holder, biz_id)
            other.add(ModelVersion(business_id=kept_id, version=1, scope="mvm", status="draft",
                                   deployment_status="draft"))
            other.flush()
            with pytest.raises(BusinessBusy) as exc:
                with other.begin_nested():
                    lock_business_for_run(other, biz_id, rollback=False)
            assert exc.value.detail == LOCK_BUSY_MESSAGE
            other.commit()
            holder.commit()
        with Session(pg_engine) as check:
            assert len(check.exec(select(ModelVersion).where(ModelVersion.business_id == kept_id)).all()) == 1

    def test_the_next_holder_sees_the_run_the_first_committed(self, pg_engine):
        biz_id = _business(pg_engine, "Lock Two")
        with Session(pg_engine) as first, Session(pg_engine) as second:
            lock_business_for_run(first, biz_id)
            run = Run(business_id=biz_id, intent="install", status="pending")
            first.add(run)
            first.commit()
            with pytest.raises(BusinessBusy) as exc:
                lock_business_for_run(second, biz_id)
            assert exc.value.active_run_id == run.id

    def test_two_concurrent_deletes_on_one_business_do_not_both_run(self, pg_engine, no_metamodel, monkeypatch):
        """Both deletes target the same business; the one that finds the
        lock held is refused and changes nothing."""
        biz_id = _business(pg_engine, "Lock Three")
        a = _version(pg_engine, biz_id, 1, status="draft")
        b = _version(pg_engine, biz_id, 2, status="draft")
        inside = threading.Event()
        release = threading.Event()
        real = lc.predecessor_to_restore

        def slow_predecessor(session, mv):
            if mv.id == a:
                inside.set()
                release.wait(10)
            return real(session, mv)

        monkeypatch.setattr(lc, "predecessor_to_restore", slow_predecessor)
        outcomes: dict[str, str] = {}

        def delete(version_id: str) -> None:
            with Session(pg_engine) as s:
                try:
                    lc.delete_version(s, MagicMock(), "wh", s.get(ModelVersion, version_id))
                    outcomes[version_id] = "deleted"
                except lc.ActiveRunRefused as refused:
                    outcomes[version_id] = refused.message

        first = threading.Thread(target=delete, args=(a,))
        first.start()
        assert inside.wait(10)
        delete(b)
        release.set()
        first.join(10)
        assert outcomes == {a: "deleted", b: LOCK_BUSY_MESSAGE}
        with Session(pg_engine) as s:
            assert s.get(ModelVersion, a) is None and s.get(ModelVersion, b) is not None


class TestInstallRows:
    def test_one_open_row_per_catalog(self, pg_engine):
        biz_id = _business(pg_engine, "Rows One")
        vid = _version(pg_engine, biz_id, 1)
        with Session(pg_engine) as s:
            mv = s.get(ModelVersion, vid)
            lc.mark_version_deployed(s, mv, "cat_a")
            lc.mark_version_deployed(s, mv, "cat_a")
            s.commit()
            assert len(s.exec(select(ModelVersionInstall).where(ModelVersionInstall.version_id == vid)).all()) == 1
            s.add(ModelVersionInstall(version_id=vid, catalog="cat_a"))
            with pytest.raises(IntegrityError):
                s.commit()
            s.rollback()
            lc.mark_version_uninstalled(s, s.get(ModelVersion, vid), "cat_a")
            lc.mark_version_deployed(s, s.get(ModelVersion, vid), "cat_a")
            s.commit()
            rows = s.exec(select(ModelVersionInstall).where(ModelVersionInstall.version_id == vid)).all()
            assert sorted(r.uninstalled_at is None for r in rows) == [False, True]

    def test_a_new_version_is_written_before_its_install_row(self, pg_engine):
        biz_id = _business(pg_engine, "Rows Two")
        with Session(pg_engine) as s:
            mv = ModelVersion(business_id=biz_id, version=1, scope="ecm", status="completed", files_catalog="cat_a")
            lc.mark_version_deployed(s, mv, "cat_a")
            s.commit()
            assert (mv.deployment_status, mv.uc_catalog) == ("deployed", "cat_a")

    def test_delete_removes_the_install_rows_and_keeps_the_cleanups(self, pg_engine, no_metamodel):
        biz_id = _business(pg_engine, "Rows Three")
        vid = _version(pg_engine, biz_id, 1)
        with Session(pg_engine) as s:
            mv = s.get(ModelVersion, vid)
            lc.mark_version_deployed(s, mv, "cat_b")
            lc.mark_version_uninstalled(s, mv, "cat_b")
            s.commit()
            lc.delete_version(s, MagicMock(), "wh", s.get(ModelVersion, vid))
        with Session(pg_engine) as s:
            assert s.exec(select(ModelVersionInstall).where(ModelVersionInstall.version_id == vid)).all() == []
            done = s.exec(select(MetamodelCleanup).where(MetamodelCleanup.business_segment == "rows_three")).all()
            assert sorted((c.catalog, c.status) for c in done) == [("cat_a", "done"), ("cat_b", "done")]
