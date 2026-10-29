"""New-semantics coverage for the collapsed version-delete path.

The manual Python cascade in ``delete_model_version`` was retired in favour of
DB ``ON DELETE`` rules plus two app-level rules the FK graph cannot express:

  * audit-intent runs (``_helpers.AUDIT_INTENTS``) recorded on a version are
    deleted WITH the version;
  * operational-run GC (Philosophy B): a run that PRODUCED the deleted version
    is GC'd only when no output version survives.

All GC/cascade outcomes require FK enforcement, so these tests use the
``fk_engine`` / ``fk_client`` fixtures and seed directly into ``fk_engine``.

The force-resync anchor tests drive ``ModelSyncService`` directly to exercise
the ``_delete_existing`` capture/detach + ``_reanchor_context_links`` re-resolve
that keeps anchored ``vibe_input_context_links`` correct across a rewrite.
"""

from __future__ import annotations

import json
import os
import sys
from pathlib import Path

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "..", "src", "app", "src"))

from sqlmodel import Session, select

from vibe_modeling.backend.db_models import (
    Attribute,
    Business,
    Domain,
    ModelVersion,
    Product,
    ProductReview,
    Run,
    RunArtifact,
    RunOperation,
    RunProgressEvent,
    Subdomain,
    VibeInput,
    VibeInputContextLink,
)
from vibe_modeling.backend.model_sync import ModelSyncService
from vibe_modeling.backend.routes._helpers import AUDIT_INTENTS


def _seed_business(fk_engine) -> str:
    with Session(fk_engine) as s:
        b = Business(name="GC Corp", description="d", industry_alignment="Retail")
        s.add(b)
        s.commit()
        s.refresh(b)
        return b.id


def _seed_version(fk_engine, business_id: str, *, version: int, scope: str) -> str:
    with Session(fk_engine) as s:
        mv = ModelVersion(
            business_id=business_id, version=version, scope=scope, status="completed",
        )
        s.add(mv)
        s.commit()
        s.refresh(mv)
        return mv.id


# --- A. Run GC matrix ------------------------------------------------------


def test_gc_run_with_only_deleted_output_is_removed(fk_client, fk_engine):
    """(a) A run whose ONLY output version is the deleted one is GC'd, along
    with its RunOperation, progress events, and artifacts."""
    bid = _seed_business(fk_engine)
    v_del = _seed_version(fk_engine, bid, version=1, scope="ecm")
    with Session(fk_engine) as s:
        run = Run(
            business_id=bid, version_id=v_del, intent="vibe-iterate",
            status="completed", parameters_json="{}",
        )
        s.add(run)
        s.flush()
        op = RunOperation(
            run_id=run.id, step_index=0, operation_name="generate_ecm",
            output_version_id=v_del, status="succeeded",
        )
        ev = RunProgressEvent(run_id=run.id, stage_name="x", step_name="y")
        art = RunArtifact(
            run_id=run.id, model_version_id=v_del,
            artifact_type="json", file_path="m.json",
        )
        s.add(op)
        s.add(ev)
        s.add(art)
        s.commit()
        run_id, op_id, ev_id, art_id = run.id, op.id, ev.id, art.id

    resp = fk_client.delete(f"/api/businesses/{bid}/versions/{v_del}")
    assert resp.status_code == 200, resp.text

    with Session(fk_engine) as s:
        assert s.get(ModelVersion, v_del) is None
        assert s.get(Run, run_id) is None
        assert s.get(RunOperation, op_id) is None
        assert s.get(RunProgressEvent, ev_id) is None
        assert s.get(RunArtifact, art_id) is None


def test_gc_run_with_surviving_sibling_output_stays(fk_client, fk_engine):
    """(b) A run with a surviving sibling output stays; only the op that
    produced the deleted version is gone."""
    bid = _seed_business(fk_engine)
    v_del = _seed_version(fk_engine, bid, version=1, scope="ecm")
    v_keep = _seed_version(fk_engine, bid, version=1, scope="mvm")
    with Session(fk_engine) as s:
        run = Run(
            business_id=bid, version_id=v_del, intent="new-base-model",
            status="completed", parameters_json="{}",
        )
        s.add(run)
        s.flush()
        op_del = RunOperation(
            run_id=run.id, step_index=0, operation_name="generate_ecm",
            output_version_id=v_del, status="succeeded",
        )
        op_keep = RunOperation(
            run_id=run.id, step_index=1, operation_name="shrink_to_mvm",
            parent_version_id=v_del, output_version_id=v_keep, status="succeeded",
        )
        s.add(op_del)
        s.add(op_keep)
        s.commit()
        run_id, op_del_id, op_keep_id = run.id, op_del.id, op_keep.id

    resp = fk_client.delete(f"/api/businesses/{bid}/versions/{v_del}")
    assert resp.status_code == 200, resp.text

    with Session(fk_engine) as s:
        assert s.get(ModelVersion, v_del) is None
        assert s.get(Run, run_id) is not None
        assert s.get(RunOperation, op_del_id) is None
        surviving = s.get(RunOperation, op_keep_id)
        assert surviving is not None
        assert surviving.output_version_id == v_keep
        assert surviving.parent_version_id is None  # deleted-version source SET NULL


def test_gc_run_referenced_only_as_source_stays(fk_client, fk_engine):
    """(c) A run that references the deleted version only as a SOURCE
    (``parent_version_id``) is never GC'd; its parent pointer SET NULLs."""
    bid = _seed_business(fk_engine)
    v_del = _seed_version(fk_engine, bid, version=1, scope="ecm")
    v_other = _seed_version(fk_engine, bid, version=1, scope="mvm")
    with Session(fk_engine) as s:
        run = Run(
            business_id=bid, version_id=v_other, intent="shrink-to-mvm",
            status="completed", parameters_json="{}",
        )
        s.add(run)
        s.flush()
        op = RunOperation(
            run_id=run.id, step_index=0, operation_name="shrink_to_mvm",
            parent_version_id=v_del, output_version_id=v_other, status="succeeded",
        )
        s.add(op)
        s.commit()
        run_id, op_id = run.id, op.id

    resp = fk_client.delete(f"/api/businesses/{bid}/versions/{v_del}")
    assert resp.status_code == 200, resp.text

    with Session(fk_engine) as s:
        assert s.get(ModelVersion, v_del) is None
        assert s.get(Run, run_id) is not None
        op = s.get(RunOperation, op_id)
        assert op is not None
        assert op.parent_version_id is None
        assert op.output_version_id == v_other


def test_audit_runs_deleted_but_non_audit_zero_op_run_detached(fk_client, fk_engine):
    """(d) Intent-conditional lock: audit-intent runs recorded on the version
    (zero RunOperation rows) are deleted WITH it; a non-audit zero-op run
    pointing at the version is merely detached (``version_id`` SET NULL)."""
    bid = _seed_business(fk_engine)
    v_del = _seed_version(fk_engine, bid, version=1, scope="ecm")
    with Session(fk_engine) as s:
        download = Run(
            business_id=bid, version_id=v_del, intent="download-industry",
            status="completed", parameters_json="{}",
        )
        kickstart = Run(
            business_id=bid, version_id=v_del, intent="kickstart-from-industry",
            status="completed", parameters_json="{}",
        )
        base = Run(
            business_id=bid, version_id=v_del, intent="new-base-model",
            status="completed", parameters_json="{}",
        )
        s.add(download)
        s.add(kickstart)
        s.add(base)
        s.commit()
        download_id, kickstart_id, base_id = download.id, kickstart.id, base.id

    resp = fk_client.delete(f"/api/businesses/{bid}/versions/{v_del}")
    assert resp.status_code == 200, resp.text

    with Session(fk_engine) as s:
        assert s.get(ModelVersion, v_del) is None
        assert s.get(Run, download_id) is None
        assert s.get(Run, kickstart_id) is None
        base = s.get(Run, base_id)
        assert base is not None  # non-audit run kept
        assert base.version_id is None  # just detached


def test_audit_intents_membership():
    """(e) Regression lock on the audit-intent set itself. The UI's
    ``lib/intent.isSetupRunIntent`` reads the same fixture
    (``ui/__tests__/setup-run-intents-parity.test.ts``)."""
    fixture = json.loads(
        (Path(__file__).resolve().parents[1] / "fixtures" / "setup_run_intents.json").read_text()
    )
    assert AUDIT_INTENTS == frozenset({"download-industry", "kickstart-from-industry", "uninstall-orphan-schemas"})
    assert AUDIT_INTENTS == frozenset(fixture["intents"])


# --- B. Anchored-input version delete --------------------------------------


def test_delete_version_with_anchored_input_cascades_link(fk_client, fk_engine):
    """A surviving ``vibe_input_context_links`` row anchored to a product
    (product_id NO-ACTION) dies via the ``version_id`` CASCADE when the version
    is deleted - no FK violation.

    Note: Postgres checks the product_id FK at end-of-statement while SQLite
    checks it immediately, so the fork rehearsal against Lakebase is the
    authoritative check; here we assert the SQLite-FK-enforced outcome.
    """
    bid = _seed_business(fk_engine)
    v_del = _seed_version(fk_engine, bid, version=1, scope="ecm")
    with Session(fk_engine) as s:
        dom = Domain(version_id=v_del, name="Sales")
        s.add(dom)
        s.flush()
        prod = Product(domain_id=dom.id, version_id=v_del, name="Order")
        s.add(prod)
        s.flush()
        vi = VibeInput(business_id=bid, origin="user", text="rule")
        s.add(vi)
        s.flush()
        link = VibeInputContextLink(
            input_id=vi.id, version_id=v_del, product_id=prod.id, is_origin=True,
        )
        s.add(link)
        s.commit()
        link_id, vi_id = link.id, vi.id

    resp = fk_client.delete(f"/api/businesses/{bid}/versions/{v_del}")
    assert resp.status_code == 200, resp.text

    with Session(fk_engine) as s:
        assert s.get(ModelVersion, v_del) is None
        assert s.get(VibeInputContextLink, link_id) is None
        # The VibeInput row FKs into the business, not the version, so it stays.
        assert s.get(VibeInput, vi_id) is not None


# --- C. Force-resync with anchored inputs ----------------------------------


def _flat_model(domain: str, product: str) -> dict:
    return {
        "domains": [
            {
                "name": domain,
                "products": [
                    {
                        "name": product,
                        "primary_key": f"{product.lower()}_id",
                        "attributes": [
                            {"name": f"{product.lower()}_id", "type": "string"},
                        ],
                    }
                ],
            }
        ]
    }


def _seed_version_with_anchored_input(fk_engine, bid: str, version_id: str):
    """Seed a Sales/Order element tree on ``version_id`` plus a product-level
    is_origin context link, a surviving subdomain, and a product review."""
    with Session(fk_engine) as s:
        dom = Domain(version_id=version_id, name="Sales")
        s.add(dom)
        s.flush()
        sub = Subdomain(version_id=version_id, domain_id=dom.id, name="Fulfilment")
        s.add(sub)
        s.flush()
        prod = Product(
            domain_id=dom.id, version_id=version_id, name="Order",
            subdomain_id=sub.id,
        )
        s.add(prod)
        s.flush()
        s.add(Attribute(product_id=prod.id, name="order_id"))
        s.add(ProductReview(version_id=version_id, product_id=prod.id, state="reviewed"))
        vi = VibeInput(business_id=bid, origin="user", text="rule")
        s.add(vi)
        s.flush()
        link = VibeInputContextLink(
            input_id=vi.id, version_id=version_id, domain_id=dom.id,
            product_id=prod.id, is_origin=True,
        )
        s.add(link)
        s.commit()
        return vi.id, link.id


def test_force_resync_reanchors_surviving_element(fk_engine):
    """(a) When the anchored element survives by NAME across the rewrite, the
    link re-resolves to the NEW same-version element id, keeps is_origin, and
    stays out of the review queue. No orphaned subdomains / product reviews."""
    bid = _seed_business(fk_engine)
    v_id = _seed_version(fk_engine, bid, version=1, scope="ecm")
    _vi_id, link_id = _seed_version_with_anchored_input(fk_engine, bid, v_id)

    with Session(fk_engine) as s:
        svc = ModelSyncService(s)
        svc.clear_version_data(v_id)
        svc.sync_from_model_json(v_id, _flat_model("Sales", "Order"))
        s.commit()

    with Session(fk_engine) as s:
        # New same-version element ids after the rewrite.
        new_dom = s.exec(
            select(Domain).where(Domain.version_id == v_id, Domain.name == "Sales")
        ).one()
        new_prod = s.exec(
            select(Product).where(Product.version_id == v_id, Product.name == "Order")
        ).one()

        link = s.get(VibeInputContextLink, link_id)
        assert link is not None
        assert link.domain_id == new_dom.id
        assert link.product_id == new_prod.id
        assert link.is_origin is True
        assert link.needs_link_review is False

        # No orphaned subdomains / product reviews left from the old element tree.
        assert s.exec(
            select(Subdomain).where(Subdomain.version_id == v_id)
        ).all() == []
        assert s.exec(
            select(ProductReview).where(ProductReview.version_id == v_id)
        ).all() == []


def test_force_resync_detaches_removed_element(fk_engine):
    """(b) When the anchored element is REMOVED from the rewritten model.json,
    its link is left detached (element ids NULL) with needs_link_review=True,
    while the VibeInput row itself survives."""
    bid = _seed_business(fk_engine)
    v_id = _seed_version(fk_engine, bid, version=1, scope="ecm")
    vi_id, link_id = _seed_version_with_anchored_input(fk_engine, bid, v_id)

    with Session(fk_engine) as s:
        svc = ModelSyncService(s)
        svc.clear_version_data(v_id)
        # Rewrite drops Sales/Order entirely - the anchor no longer resolves.
        svc.sync_from_model_json(v_id, _flat_model("Warehouse", "Bin"))
        s.commit()

    with Session(fk_engine) as s:
        link = s.get(VibeInputContextLink, link_id)
        assert link is not None
        assert link.domain_id is None
        assert link.subdomain_id is None
        assert link.product_id is None
        assert link.attribute_id is None
        assert link.needs_link_review is True
        # Only one link exists, and it is the degraded one.
        degraded = s.exec(
            select(VibeInputContextLink).where(
                VibeInputContextLink.needs_link_review == True  # noqa: E712
            )
        ).all()
        assert [lk.id for lk in degraded] == [link_id]
        # The VibeInput row survives the resync.
        assert s.get(VibeInput, vi_id) is not None


def _count_statements(engine, fn):
    """Run ``fn()`` and count DB statements ``engine`` executes meanwhile.

    An ``executemany`` batch (the bulk multi-row INSERT/UPDATE this module's
    re-anchor path uses) fires exactly one ``before_cursor_execute`` event
    regardless of row count, so this counts round trips, not rows.
    """
    from sqlalchemy import event

    count = 0

    def _before_cursor_execute(*_args, **_kwargs):
        nonlocal count
        count += 1

    event.listen(engine, "before_cursor_execute", _before_cursor_execute)
    try:
        fn()
    finally:
        event.remove(engine, "before_cursor_execute", _before_cursor_execute)
    return count


def _resync_with_n_anchored_inputs(fk_engine, bid: str, n: int, *, version: int) -> int:
    """Seed ``n`` VibeInputs anchored to the same product on a fresh version,
    then force-resync it, returning the statement count the resync issues."""
    v_id = _seed_version(fk_engine, bid, version=version, scope="ecm")
    with Session(fk_engine) as s:
        dom = Domain(version_id=v_id, name="Sales")
        s.add(dom)
        s.flush()
        prod = Product(domain_id=dom.id, version_id=v_id, name="Order")
        s.add(prod)
        s.flush()
        for _ in range(n):
            vi = VibeInput(business_id=bid, origin="user", text="rule")
            s.add(vi)
            s.flush()
            s.add(VibeInputContextLink(
                input_id=vi.id, version_id=v_id, product_id=prod.id, is_origin=True,
            ))
        s.commit()

    with Session(fk_engine) as s:
        svc = ModelSyncService(s)
        svc.clear_version_data(v_id)
        count = _count_statements(
            fk_engine,
            lambda: svc.sync_from_model_json(v_id, _flat_model("Sales", "Order")),
        )
        s.commit()
    return count


def test_reanchor_query_count_is_bounded_not_per_input(fk_engine):
    """Re-anchoring N captured inputs must issue the same number of
    statements regardless of N - O(1) in the number of element tables
    (domains/subdomains/products/attributes/fk_links) it prefetches, not
    O(N) point lookups. A regression back to a per-input resolve-then-write
    loop would show up here as growth between the 1-input and 8-input runs.
    """
    bid = _seed_business(fk_engine)
    count_1 = _resync_with_n_anchored_inputs(fk_engine, bid, 1, version=1)
    count_8 = _resync_with_n_anchored_inputs(fk_engine, bid, 8, version=2)

    assert count_8 == count_1, (
        f"reanchor statement count grew with input count: {count_1} -> {count_8} "
        "(should stay O(1) in element tables, not O(inputs))"
    )


def _clear_with_n_anchored_inputs(fk_engine, bid: str, n: int, *, version: int) -> int:
    """Seed ``n`` VibeInputs anchored to the same product on a fresh version,
    then force-clear it, returning the statement count the CAPTURE phase
    (``clear_version_data`` -> ``_capture_and_detach_context_links``) issues."""
    v_id = _seed_version(fk_engine, bid, version=version, scope="ecm")
    with Session(fk_engine) as s:
        dom = Domain(version_id=v_id, name="Sales")
        s.add(dom)
        s.flush()
        prod = Product(domain_id=dom.id, version_id=v_id, name="Order")
        s.add(prod)
        s.flush()
        for _ in range(n):
            vi = VibeInput(business_id=bid, origin="user", text="rule")
            s.add(vi)
            s.flush()
            s.add(VibeInputContextLink(
                input_id=vi.id, version_id=v_id, product_id=prod.id, is_origin=True,
            ))
        s.commit()

    with Session(fk_engine) as s:
        svc = ModelSyncService(s)
        count = _count_statements(fk_engine, lambda: svc.clear_version_data(v_id))
        s.commit()
    return count


def test_capture_query_count_is_bounded_not_per_link(fk_engine):
    """Capturing N anchored links' natural-key names before detach/teardown
    must issue the same number of statements regardless of N - O(1) in the
    number of element tables it prefetches, not O(N) point reads (one
    ``session.get`` per link per element table walked). A regression back to
    the per-link point-read loop would show up here as growth between the
    1-input and 8-input runs, mirroring
    ``test_reanchor_query_count_is_bounded_not_per_input`` on the resolve side.
    """
    bid = _seed_business(fk_engine)
    count_1 = _clear_with_n_anchored_inputs(fk_engine, bid, 1, version=1)
    count_8 = _clear_with_n_anchored_inputs(fk_engine, bid, 8, version=2)

    assert count_8 == count_1, (
        f"capture statement count grew with input count: {count_1} -> {count_8} "
        "(should stay O(1) in element tables, not O(inputs))"
    )
