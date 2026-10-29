"""The post-version layout prefetch and how a failed layout job is reported.

The orchestrator queues the prefetch in the same transaction that creates the
version (``_runner._queue_layout_prefetch`` after ``session.flush()``, committed
by the tracker tick). These tests use a file-backed SQLite database so the
worker's own session runs on a second connection and, like on Lakebase, can't
see rows the caller hasn't committed.
"""

from unittest.mock import patch

import pytest
from fastapi.testclient import TestClient
from sqlmodel import Session, SQLModel, create_engine, select

from _test_app import make_test_app
from vibe_modeling.backend import diagram as diagram_mod
from vibe_modeling.backend import explorer as explorer_mod
from vibe_modeling.backend.db_models import Business, Domain, ModelVersion, Product
from vibe_modeling.backend.models import DiagramLayoutOut


@pytest.fixture(autouse=True)
def _clean_caches():
    def _clear():
        with diagram_mod._in_progress_lock:
            diagram_mod._in_progress.clear()
        with diagram_mod._cache_lock:
            diagram_mod._layout_cache.clear()
        explorer_mod._model_cache.clear()

    _clear()
    yield
    _clear()


@pytest.fixture
def file_engine(tmp_path):
    engine = create_engine(f"sqlite:///{tmp_path / 'app.db'}", connect_args={"check_same_thread": False})
    SQLModel.metadata.create_all(engine)
    yield engine
    engine.dispose()


@pytest.fixture
def run_jobs_inline(monkeypatch):
    """Run each submitted job at once, on the submitting thread, and record it.

    The overview layout calls the ELK subprocess; the model it was given is
    recorded instead, which is what these tests check."""
    submitted: list[tuple] = []
    models: list[dict] = []

    def _submit(fn, *args):
        submitted.append(args)
        fn(*args)

    def _compute(model, prev_model, domain, column_mode):
        models.append(model)
        return DiagramLayoutOut()

    monkeypatch.setattr(diagram_mod._prefetch_pool, "submit", _submit)
    monkeypatch.setattr(diagram_mod, "_compute_layout", _compute)
    return submitted, models


def _business(engine) -> str:
    with Session(engine) as s:
        biz = Business(name="Corner Bakery", description="d")
        s.add(biz)
        s.commit()
        return biz.id


def _create_version(session: Session, business_id: str) -> None:
    """What a version-producing op does in the tick's transaction: the version
    and its synced structure, flushed, not committed."""
    mv = ModelVersion(business_id=business_id, version=2, scope="mvm", status="completed")
    session.add(mv)
    session.flush()
    for name in ("sales", "inventory"):
        d = Domain(version_id=mv.id, name=name)
        session.add(d)
        session.flush()
        session.add(Product(domain_id=d.id, version_id=mv.id, name=f"{name}_orders"))
    session.flush()


def _queue(session: Session, engine, business_id: str) -> int:
    return diagram_mod.queue_layout_prefetch_for_version(
        session, lambda: Session(engine, expire_on_commit=False), None,
        business_id=business_id, version_int=2, scope="mvm",
    )


def _key(business_id: str, domain=None, column_mode="hide") -> str:
    return diagram_mod._cache_key(business_id, 2, "mvm", domain, column_mode)


class TestPrefetchWaitsForTheCommit:
    def test_a_version_created_in_the_same_transaction_is_laid_out_after_the_commit(
        self, file_engine, run_jobs_inline,
    ):
        submitted, models = run_jobs_inline
        biz = _business(file_engine)

        session = Session(file_engine)
        _create_version(session, biz)
        assert _queue(session, file_engine, biz) == 5
        assert submitted == []
        session.commit()
        session.close()

        assert len(submitted) == 5
        with diagram_mod._cache_lock:
            cached = {k: diagram_mod._layout_cache.get(k) for k in (
                _key(biz), _key(biz, column_mode="keys"), _key(biz, column_mode="all"),
                _key(biz, "sales"), _key(biz, "inventory"),
            )}
        assert all(isinstance(v, DiagramLayoutOut) for v in cached.values()), cached
        assert {d["name"] for d in models[0]["domains"]} == {"sales", "inventory"}

    def test_a_savepoint_rollback_inside_still_submits_on_the_commit(self, file_engine, run_jobs_inline):
        submitted, _ = run_jobs_inline
        biz = _business(file_engine)

        session = Session(file_engine)
        _create_version(session, biz)
        _queue(session, file_engine, biz)
        nested = session.begin_nested()
        session.add(Business(name="discarded", description=""))
        nested.rollback()
        assert submitted == []
        session.commit()
        session.close()

        assert len(submitted) == 5

    def test_a_rolled_back_transaction_submits_nothing(self, file_engine, run_jobs_inline):
        submitted, _ = run_jobs_inline
        biz = _business(file_engine)

        session = Session(file_engine)
        _create_version(session, biz)
        _queue(session, file_engine, biz)
        session.rollback()
        session.close()

        assert submitted == []
        with diagram_mod._in_progress_lock:
            assert not diagram_mod._in_progress

    def test_an_already_committed_version_submits_when_the_reading_session_closes(
        self, file_engine, run_jobs_inline,
    ):
        """The import routes queue after their own commit, from a request
        session that closes without committing again."""
        submitted, _ = run_jobs_inline
        biz = _business(file_engine)
        with Session(file_engine) as s:
            _create_version(s, biz)
            s.commit()

        with Session(file_engine) as s:
            _queue(s, file_engine, biz)
            assert submitted == []

        assert len(submitted) == 5
        with diagram_mod._cache_lock:
            assert isinstance(diagram_mod._layout_cache.get(_key(biz)), DiagramLayoutOut)

    def test_a_failing_pool_does_not_break_the_commit(self, file_engine):
        biz = _business(file_engine)
        session = Session(file_engine)
        _create_version(session, biz)
        with patch.object(diagram_mod._prefetch_pool, "submit", side_effect=RuntimeError("pool down")):
            _queue(session, file_engine, biz)
            session.commit()
        session.close()

        with Session(file_engine) as s:
            assert len(s.exec(select(ModelVersion).where(ModelVersion.business_id == biz)).all()) == 1
        with diagram_mod._in_progress_lock:
            assert not diagram_mod._in_progress


@pytest.fixture
def diagram_client(monkeypatch):
    submitted: list[tuple] = []

    class _Future:
        def result(self, timeout=None):
            return None

    def _submit(fn, *args):
        submitted.append(args)
        return _Future()

    monkeypatch.setattr(diagram_mod._prefetch_pool, "submit", _submit)
    monkeypatch.setattr(diagram_mod, "_read_lakebase_layout", lambda *a, **kw: None)

    from vibe_modeling.backend.core._defaults import _WorkspaceClientDependency
    from vibe_modeling.backend.core.lakebase import _LakebaseDependency

    app = make_test_app(diagram_mod.router)
    app.dependency_overrides[_LakebaseDependency.__call__] = lambda: object()
    app.dependency_overrides[_WorkspaceClientDependency.__call__] = lambda: object()
    return TestClient(app), submitted


def _fail_job(key: str, exc: Exception, monkeypatch) -> None:
    """Run the background job for ``key`` with its model read raising ``exc``."""

    class _Session:
        def __enter__(self):
            return self

        def __exit__(self, *a):
            return False

    def _raise(*a, **kw):
        raise exc

    monkeypatch.setattr(diagram_mod, "_load_layout_inputs", _raise)
    diagram_mod._background_compute(lambda: _Session(), None, "biz-1", 2, "mvm", None, "hide", key)


URL = "/api/businesses/biz-1/versions/2/mvm/diagram"
KEY = diagram_mod._cache_key("biz-1", 2, "mvm", None, "hide")


class TestAFailedLayoutJob:
    def test_the_viewer_gets_the_original_status_once_then_a_recompute(self, diagram_client, monkeypatch):
        from fastapi import HTTPException

        client, submitted = diagram_client
        _fail_job(KEY, HTTPException(404, "Model JSON not found"), monkeypatch)

        resp = client.get(URL)
        assert resp.status_code == 404
        assert resp.json() == {"detail": "Model JSON not found"}

        resp = client.get(URL)
        assert resp.status_code == 202
        assert len(submitted) == 1

    def test_the_warm_up_request_recomputes_instead_of_replaying(self, diagram_client, monkeypatch):
        from fastapi import HTTPException

        client, submitted = diagram_client
        _fail_job(KEY, HTTPException(404, "Model JSON not found"), monkeypatch)

        resp = client.get(URL, params={"column_mode": "hide", "prefetch": "true"})
        assert resp.status_code == 202
        assert len(submitted) == 1
        with diagram_mod._cache_lock:
            assert KEY not in diagram_mod._layout_cache

    def test_a_stale_failure_is_recomputed(self, diagram_client, monkeypatch):
        from fastapi import HTTPException

        client, submitted = diagram_client
        _fail_job(KEY, HTTPException(404, "Model JSON not found"), monkeypatch)
        later = diagram_mod._now_ms() + diagram_mod._LAYOUT_ERROR_TTL_MS + 1
        monkeypatch.setattr(diagram_mod, "_now_ms", lambda: later)

        resp = client.get(URL)
        assert resp.status_code == 202
        assert len(submitted) == 1

    def test_an_unexpected_error_is_a_sanitized_500(self, diagram_client, monkeypatch):
        client, _ = diagram_client
        _fail_job(KEY, RuntimeError("ELK could not read /Volumes/cat/_metamodel/vol_root/x.json"), monkeypatch)

        with diagram_mod._cache_lock:
            cached = diagram_mod._layout_cache[KEY]
        assert cached.status_code == 500
        assert "/Volumes/cat" not in cached.detail

        resp = client.get(URL)
        assert resp.status_code == 500
        assert resp.json() == {"detail": "Layout computation failed: ELK could not read [REDACTED]"}
