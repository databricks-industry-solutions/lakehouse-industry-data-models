"""Real Postgres checks for the assessment ingest and the next-vibe -> feedback writes.

To run it, fork an ephemeral Lakebase branch, point ``VIBE_MODELING_LAKEBASE_*`` at it, set
``ASSESS_PG_DATABASE`` and delete the branch afterwards. Skipped unless ``ASSESS_PG_DATABASE`` is set.
``scripts/smoke/run_assess_ingest_pg.sh`` does all of that.

Everything runs in a new, empty database on that branch, so the production data the fork cloned is
never read or written. ``reconcile_schema`` builds it as a fresh install, which runs every migration
up to the head. On it:

- the two ``use_alter`` decision-option FKs and the ``vibe_input_id`` SET NULL FK exist;
- ingest of the fixture changes ``assess_*`` tables only;
- the feedback conversion changes ``vibe_inputs`` and ``vibe_input_context_links`` only, besides
  ``assess_next_vibe``;
- racing single and bulk requests create exactly one VibeInput per next vibe, with no deadlock.
"""
from __future__ import annotations

import os
import sys
import threading
import time
from concurrent.futures import ThreadPoolExecutor

import pytest
from sqlalchemy import inspect, text
from sqlmodel import Session, select

sys.path.insert(0, os.path.dirname(__file__))

DATABASE = os.environ.get("ASSESS_PG_DATABASE", "")
pytestmark = pytest.mark.skipif(not DATABASE, reason="needs a Lakebase branch (set ASSESS_PG_DATABASE)")

from _assess_helpers import FEEDBACK_TABLES, changed_tables, table_digests  # noqa: E402
from _pg_branch import fresh_database_engine  # noqa: E402
from test_assess_ingest import _fixture_files, _seed_run, _ws_with  # noqa: E402

from vibe_modeling.backend.assessment.ingest import ingest_domain_run  # noqa: E402
from vibe_modeling.backend.assessment.schemas import BulkAddNextVibesToFeedbackIn  # noqa: E402
from vibe_modeling.backend.core._headers import DatabricksAppsHeaders  # noqa: E402
from vibe_modeling.backend.db_models import AssessDomainRun, AssessNextVibe, VibeInput  # noqa: E402
from vibe_modeling.backend.migrations import MIGRATIONS  # noqa: E402

HEADERS = DatabricksAppsHeaders(host=None, user_name=None, user_id=None, user_email="pg-test@example.com",
                                request_id=None, token=None)


@pytest.fixture(scope="module")
def pg_engine():
    from vibe_modeling.backend.migrations import reconcile_schema

    engine = fresh_database_engine(DATABASE)
    reconcile_schema(engine)
    yield engine
    engine.dispose()


@pytest.fixture(scope="module")
def ingested(pg_engine):
    """The fixture ingested once; the table digests before and after."""
    dr_id, _, _ = _seed_run(pg_engine)
    before = table_digests(pg_engine)
    with Session(pg_engine) as s:
        assert ingest_domain_run(s, _ws_with(_fixture_files()), s.get(AssessDomainRun, dr_id)).results_valid
    return dr_id, before, table_digests(pg_engine)


def test_v_0_8_0_emits_the_use_alter_and_set_null_fks(pg_engine):
    insp = inspect(pg_engine)
    decision = {tuple(fk["constrained_columns"]): fk["referred_table"]
                for fk in insp.get_foreign_keys("assess_pending_decision")}
    assert decision[("answer_option_id",)] == "assess_decision_option"
    assert decision[("recommended_option_id",)] == "assess_decision_option"
    nv = {tuple(fk["constrained_columns"]): fk for fk in insp.get_foreign_keys("assess_next_vibe")}
    assert nv[("vibe_input_id",)]["referred_table"] == "vibe_inputs"
    assert nv[("vibe_input_id",)]["options"].get("ondelete") == "SET NULL"
    with pg_engine.connect() as conn:
        installed = conn.execute(text("SELECT version FROM _lakebase_schema_version WHERE id = 1")).scalar()
    assert installed == MIGRATIONS[-1].version


def test_ingest_writes_assess_tables_only(ingested):
    _, before, after = ingested
    changed = changed_tables(before, after)
    assert changed and all(t.startswith("assess_") for t in changed), changed


def _add_next_vibes(pg_engine, dr_id: str, n: int) -> list[str]:
    with Session(pg_engine) as s:
        rows = [AssessNextVibe(domain_run_id=dr_id, ordinal=100 + i, priority=1, category="", text=f"pg vibe {i}",
                               problem=f"problem {i}", proposed_change=f"change {i}", urgency="later")
                for i in range(n)]
        s.add_all(rows)
        s.commit()
        return sorted(r.id for r in rows)


def _vibe_inputs(pg_engine) -> int:
    with Session(pg_engine) as s:
        return len(s.exec(select(VibeInput.id)).all())


def test_feedback_writes_only_vibe_inputs_and_links(pg_engine, ingested):
    from vibe_modeling.backend.routes.assessments import add_next_vibes_to_feedback

    dr_id, _, after_ingest = ingested
    with Session(pg_engine) as s:
        ids = list(s.exec(select(AssessNextVibe.id).where(AssessNextVibe.domain_run_id == dr_id)))
        out = add_next_vibes_to_feedback(dr_id, BulkAddNextVibesToFeedbackIn(ids=ids), s, HEADERS, None)
    assert out.count_created == len(ids) and not out.failures
    changed = changed_tables(after_ingest, table_digests(pg_engine))
    assert {t for t in changed if not t.startswith("assess_")} == FEEDBACK_TABLES
    assert changed - FEEDBACK_TABLES == {"assess_next_vibe"}


def test_two_racing_single_requests_create_one_item(pg_engine, ingested, monkeypatch):
    """Both requests read the next vibe unlinked and create an item; a barrier makes them reach the
    compare-and-set together, so one waits on the other's row lock and then loses."""
    import vibe_modeling.backend.routes.assessments as routes

    dr_id = ingested[0]
    (nv_id,) = _add_next_vibes(pg_engine, dr_id, 1)
    real = routes.create_vibe_input_with_anchor
    barrier = threading.Barrier(2, timeout=60)

    def create_then_wait(*a, **k):
        vi = real(*a, **k)
        barrier.wait()
        return vi

    monkeypatch.setattr(routes, "create_vibe_input_with_anchor", create_then_wait)
    before = _vibe_inputs(pg_engine)

    def one_request(_):
        with Session(pg_engine) as s:
            return routes.add_next_vibe_to_feedback(dr_id, nv_id, s, HEADERS, None)

    with ThreadPoolExecutor(2) as pool:
        results = list(pool.map(one_request, range(2), timeout=120))
    assert sorted(r.created for r in results) == [False, True]
    assert len({r.feedback_input_id for r in results}) == 1
    assert _vibe_inputs(pg_engine) == before + 1
    with Session(pg_engine) as s:
        assert s.get(AssessNextVibe, nv_id).vibe_input_id == results[0].feedback_input_id


def test_racing_bulk_and_single_requests_create_one_item_per_next_vibe(pg_engine, ingested, monkeypatch):
    """Two bulk requests (ids in opposite orders) and a single request per next vibe, all at once,
    with a pause after each create to widen the race. No failures, no deadlock, one item each."""
    import vibe_modeling.backend.routes.assessments as routes

    dr_id = ingested[0]
    ids = _add_next_vibes(pg_engine, dr_id, 4)
    real = routes.create_vibe_input_with_anchor

    def slow_create(*a, **k):
        vi = real(*a, **k)
        time.sleep(0.3)
        return vi

    monkeypatch.setattr(routes, "create_vibe_input_with_anchor", slow_create)
    before = _vibe_inputs(pg_engine)

    def bulk(order):
        with Session(pg_engine) as s:
            out = routes.add_next_vibes_to_feedback(dr_id, BulkAddNextVibesToFeedbackIn(ids=order), s, HEADERS, None)
            assert not out.failures, out.failures
            return {i.next_vibe_id: i.feedback_input_id for i in out.items}

    def single(nv_id):
        with Session(pg_engine) as s:
            out = routes.add_next_vibe_to_feedback(dr_id, nv_id, s, HEADERS, None)
            return {out.next_vibe_id: out.feedback_input_id}

    started = time.monotonic()
    with ThreadPoolExecutor(2 + len(ids)) as pool:
        futures = [pool.submit(bulk, ids), pool.submit(bulk, list(reversed(ids)))]
        futures += [pool.submit(single, i) for i in ids]
        answers = [f.result(timeout=180) for f in futures]
    assert time.monotonic() - started < 180
    for nv_id in ids:
        assert len({a[nv_id] for a in answers if nv_id in a}) == 1, nv_id
    assert _vibe_inputs(pg_engine) == before + len(ids)
    with Session(pg_engine) as s:
        linked = {nv.id: nv.vibe_input_id for nv in s.exec(select(AssessNextVibe).where(AssessNextVibe.id.in_(ids)))}
    assert all(linked.values()) and len(set(linked.values())) == len(ids)
    assert all(answers[0][i] == linked[i] for i in ids)
