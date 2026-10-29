"""``getExplorerVersions`` Base / Vibed brand (an internal tracker item).

A version is Base when it has no lineage parent, or when a shrink/enlarge op
produced it from a Base parent. Vibe iterations and imports with a lineage tag
are Vibed. A shrink/enlarge output whose parent row was deleted reads
``parent_deleted``.
"""

from __future__ import annotations

import os
import sys

from sqlalchemy import event
from sqlmodel import Session, select

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "..", "src", "app", "src"))

from vibe_modeling.backend.db_models import Business, ModelVersion, Run, RunOperation
from vibe_modeling.backend.explorer import _BRAND_INHERITING_OPS, _version_brands
from vibe_modeling.backend.routes._helpers import delete_model_version
from vibe_modeling.backend.services.operations import _registry


def _business(session) -> str:
    b = Business(name="Brand Corp")
    session.add(b)
    session.flush()
    return b.id


def _next_step(session, run_id) -> int:
    return len(session.exec(
        select(RunOperation.id).where(RunOperation.run_id == run_id)
    ).all())


def _version(
    session, biz_id, n, scope, base=None, op=None, run=None, intent=""
) -> ModelVersion:
    mv = ModelVersion(
        business_id=biz_id, version=n, scope=scope, status="completed",
        base_version_id=base.id if base is not None else None,
    )
    session.add(mv)
    session.flush()
    if op is not None:
        if run is None:
            run = Run(business_id=biz_id, intent=intent)
            session.add(run)
            session.flush()
        session.add(RunOperation(
            run_id=run.id, step_index=_next_step(session, run.id), operation_name=op,
            status="succeeded", output_version_id=mv.id,
            parent_version_id=base.id if base is not None else None,
        ))
        session.flush()
    return mv


def _run(session, biz_id, intent) -> Run:
    run = Run(business_id=biz_id, intent=intent)
    session.add(run)
    session.flush()
    return run


def _brands(client, biz_id) -> dict[tuple[int, str], tuple[bool, bool]]:
    resp = client.get(f"/api/businesses/{biz_id}/explorer/versions")
    assert resp.status_code == 200
    return {
        (v["version"], v["scope"]): (v["is_base"], v["parent_deleted"])
        for v in resp.json()
    }


class TestVersionBrand:
    def test_new_base_model_both_base(self, engine, client):
        with Session(engine) as session:
            biz = _business(session)
            ecm = _version(session, biz, 1, "ecm", op="generate_ecm")
            _version(session, biz, 1, "mvm", base=ecm, op="shrink_to_mvm")
            session.commit()
        assert _brands(client, biz) == {
            (1, "ecm"): (True, False),
            (1, "mvm"): (True, False),
        }

    def test_vibe_new_ecm_mvm_on_vibed_ecm_both_vibed(self, engine, client):
        with Session(engine) as session:
            biz = _business(session)
            ecm1 = _version(session, biz, 1, "ecm", op="generate_ecm")
            mvm1 = _version(session, biz, 1, "mvm", base=ecm1, op="shrink_to_mvm")
            ecm2 = _version(session, biz, 2, "ecm", base=ecm1, op="vibe_iterate")
            _version(session, biz, 2, "mvm", base=ecm2, op="shrink_to_mvm")
            session.commit()
        brands = _brands(client, biz)
        assert brands[(1, "mvm")] == (True, False)
        assert brands[(2, "ecm")] == (False, False)
        assert brands[(2, "mvm")] == (False, False)

    def test_enlarge_of_base_mvm_is_base(self, engine, client):
        with Session(engine) as session:
            biz = _business(session)
            mvm = _version(session, biz, 1, "mvm", op="generate_ecm")
            _version(session, biz, 2, "ecm", base=mvm, op="enlarge_to_ecm")
            session.commit()
        assert _brands(client, biz)[(2, "ecm")] == (True, False)

    def test_enlarge_of_vibed_mvm_is_vibed(self, engine, client):
        with Session(engine) as session:
            biz = _business(session)
            ecm = _version(session, biz, 1, "ecm", op="generate_ecm")
            mvm = _version(session, biz, 2, "mvm", base=ecm, op="vibe_iterate")
            _version(session, biz, 3, "ecm", base=mvm, op="enlarge_to_ecm")
            session.commit()
        assert _brands(client, biz)[(3, "ecm")] == (False, False)

    def test_shrink_output_with_deleted_parent(self, engine, client):
        with Session(engine) as session:
            biz = _business(session)
            ecm = _version(session, biz, 5, "ecm", op="vibe_iterate")
            mvm = _version(session, biz, 5, "mvm", base=ecm, op="shrink_to_mvm")
            session.delete(ecm)
            session.commit()
            assert session.get(ModelVersion, mvm.id).base_version_id == ecm.id
        assert _brands(client, biz) == {(5, "mvm"): (False, True)}

    def test_vibe_output_with_deleted_parent_is_plain_vibed(self, engine, client):
        with Session(engine) as session:
            biz = _business(session)
            ecm = _version(session, biz, 1, "ecm", op="generate_ecm")
            _version(session, biz, 2, "ecm", base=ecm, op="vibe_iterate")
            session.delete(ecm)
            session.commit()
        assert _brands(client, biz) == {(2, "ecm"): (False, False)}

    def test_version_without_operation_row_and_a_parent_is_vibed(self, engine, client):
        with Session(engine) as session:
            biz = _business(session)
            ecm = _version(session, biz, 1, "ecm")
            _version(session, biz, 1, "mvm", base=ecm)
            session.commit()
        assert _brands(client, biz)[(1, "mvm")] == (False, False)

    def test_one_operation_query_per_list(self, engine, client):
        with Session(engine) as session:
            biz = _business(session)
            parent = _version(session, biz, 1, "ecm", op="generate_ecm")
            for n in range(2, 8):
                parent = _version(session, biz, n, "mvm", base=parent, op="shrink_to_mvm")
            session.commit()

        selects: list[str] = []

        def _record(conn, cursor, statement, params, context, executemany):
            if statement.lstrip().upper().startswith("SELECT"):
                selects.append(statement)

        event.listen(engine, "before_cursor_execute", _record)
        try:
            resp = client.get(f"/api/businesses/{biz}/explorer/versions")
        finally:
            event.remove(engine, "before_cursor_execute", _record)
        assert resp.status_code == 200
        ops = [s for s in selects if "run_operations" in s]
        assert len(ops) == 1, ops
        assert all(v["is_base"] and not v["parent_deleted"] for v in resp.json())
        assert len(resp.json()) == 7

    def test_new_base_model_mvm_stays_base_after_ecm_delete(self, fk_engine, fk_client):
        with Session(fk_engine) as session:
            biz = _business(session)
            run = _run(session, biz, "new-base-model")
            ecm = _version(session, biz, 1, "ecm", op="generate_ecm", run=run)
            _version(session, biz, 1, "mvm", base=ecm, op="shrink_to_mvm", run=run)
            session.commit()
            delete_model_version(session, session.get(ModelVersion, ecm.id))
            session.commit()
        assert _brands(fk_client, biz) == {(1, "mvm"): (True, False)}

    def test_vibe_new_ecm_mvm_mvm_after_ecm_delete_is_parent_deleted(
        self, fk_engine, fk_client
    ):
        with Session(fk_engine) as session:
            biz = _business(session)
            run = _run(session, biz, "vibe-new-ecm-mvm")
            ecm = _version(session, biz, 5, "ecm", op="vibe_iterate", run=run)
            _version(session, biz, 5, "mvm", base=ecm, op="shrink_to_mvm", run=run)
            session.commit()
            delete_model_version(session, session.get(ModelVersion, ecm.id))
            session.commit()
        assert _brands(fk_client, biz) == {(5, "mvm"): (False, True)}

    def test_lineage_cycle_does_not_loop(self, engine, client):
        with Session(engine) as session:
            biz = _business(session)
            run = _run(session, biz, "new-base-model")
            a = _version(session, biz, 1, "ecm", op="shrink_to_mvm", run=run)
            b = _version(session, biz, 2, "ecm", base=a, op="shrink_to_mvm", run=run)
            a.base_version_id = b.id
            session.add(a)
            session.commit()
        brands = _brands(client, biz)
        assert brands == {(1, "ecm"): (False, False), (2, "ecm"): (False, False)}

    def test_long_lineage_chain_does_not_hit_recursion_limit(self, engine):
        depth = 1500
        with Session(engine) as session:
            biz = _business(session)
            run = _run(session, biz, "new-base-model")
            parent = _version(session, biz, 1, "ecm", op="generate_ecm", run=run)
            versions = [parent]
            for n in range(2, depth + 1):
                parent = _version(session, biz, n, "mvm", base=parent, op="shrink_to_mvm", run=run)
                versions.append(parent)
            session.commit()
            brands = _version_brands(session, versions)
        assert len(brands) == depth
        assert all(b == (True, False) for b in brands.values())

    def test_brand_inheriting_ops_are_registered_operations(self):
        assert set(_BRAND_INHERITING_OPS) <= set(_registry.all_names())
