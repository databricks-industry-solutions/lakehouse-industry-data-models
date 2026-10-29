"""Run change review (v0.9.0 addendum design section 2.3).

Covers ``backend/run_changes.py`` (the change list from ``compute_model_diff``,
the ``change_class`` hint per anchor kind, outcome and scope, decisions open
and closed, feedback from rejections) and the three routes in
``routes/run_changes.py`` (``getRunChanges``, ``setRunChangeDecisions``,
``addRejectedChangesAsFeedback``) including RBAC and refused writes.
"""

from __future__ import annotations

import json
from datetime import datetime, timezone
from unittest.mock import patch

import pytest
from fastapi.testclient import TestClient
from sqlalchemy.pool import NullPool
from sqlmodel import Session, SQLModel, create_engine, select

from _test_app import make_test_app
from vibe_modeling.backend.db_models import (
    Attribute,
    Business,
    Domain,
    ModelVersion,
    Product,
    Run,
    RunChangeDecision,
    RunInputLink,
    RunOperation,
    Subdomain,
    VibeInput,
    VibeInputContextLink,
)
from vibe_modeling.backend import run_changes as rc
from vibe_modeling.backend.run_changes import list_model_changes

WHO = {"X-Forwarded-Email": "modeler@example.com"}

# name -> products -> attribute name -> type
BASE = {
    "Sales": {"Order": {"id": "int", "amount": "decimal"}, "Customer": {"id": "int"}},
    "Billing": {"Invoice": {"id": "int"}},
    "Ops": {"Shift": {"id": "int"}},
}
OUTPUT = {
    "Sales": {"Order": {"id": "int", "amount": "float", "note": "string"}, "Lead": {"id": "int"}},
    "Billing": {"Invoice": {"id": "int"}, "Payment": {"id": "int"}},
    "Marketing": {"Campaign": {"id": "int"}},
}
EXPECTED = {
    ("attribute", "Sales.Order.amount", "modified"),
    ("attribute", "Sales.Order.note", "added"),
    ("product", "Sales.Customer", "removed"),
    ("product", "Sales.Lead", "added"),
    ("product", "Billing.Payment", "added"),
    ("domain", "Ops", "removed"),
    ("domain", "Marketing", "added"),
}


def _model_dict(spec: dict) -> dict:
    return {"domains": [
        {"name": dn, "products": [
            {"name": pn, "attributes": [{"name": an, "type": t} for an, t in attrs.items()]}
            for pn, attrs in products.items()
        ]}
        for dn, products in spec.items()
    ]}


def _write_elements(s: Session, mv: ModelVersion, spec: dict) -> dict:
    ids: dict = {}
    for dn, products in spec.items():
        d = Domain(version_id=mv.id, name=dn)
        s.add(d)
        s.flush()
        ids[(dn,)] = d.id
        for pn, attrs in products.items():
            p = Product(version_id=mv.id, domain_id=d.id, name=pn, table_name=pn.lower())
            s.add(p)
            s.flush()
            ids[(dn, pn)] = p.id
            for an, t in attrs.items():
                a = Attribute(product_id=p.id, name=an, column_name=an, type=t)
                s.add(a)
                s.flush()
                ids[(dn, pn, an)] = a.id
    return ids


def _seed(engine, *, params: dict | None = None, name: str = "Acme", with_op: bool = True,
          dry_run: bool = False):
    """Business, base v1 and output v2 with elements, a vibe run producing v2."""
    with Session(engine) as s:
        biz = Business(name=name)
        s.add(biz)
        s.flush()
        base = ModelVersion(business_id=biz.id, version=1, scope="ecm", status="completed")
        s.add(base)
        s.flush()
        out = ModelVersion(business_id=biz.id, version=2, scope="ecm",
                           status="draft" if dry_run else "completed", dry_run=dry_run,
                           base_version_id=base.id)
        s.add(out)
        s.flush()
        base_ids = _write_elements(s, base, BASE)
        out_ids = _write_elements(s, out, OUTPUT)
        run = Run(business_id=biz.id, intent="vibe-iterate", status="completed",
                  parameters_json=json.dumps(params or {"vibe_scope": "all_domains"}))
        s.add(run)
        s.flush()
        if with_op:
            s.add(RunOperation(run_id=run.id, step_index=0, operation_name="vibe_iterate",
                               status="succeeded", parent_version_id=base.id,
                               output_version_id=out.id, completed_at=datetime.now(timezone.utc)))
        s.commit()
        return {"bid": biz.id, "run_id": run.id, "base_id": base.id, "out_id": out.id,
                "base_ids": base_ids, "out_ids": out_ids}


def _send_input(engine, seed, *, outcome=None, target=None, **anchor):
    """An input the run sent, anchored on the base version."""
    with Session(engine) as s:
        vi = VibeInput(business_id=seed["bid"], text="ask")
        s.add(vi)
        s.flush()
        s.add(VibeInputContextLink(input_id=vi.id, version_id=seed["base_id"], is_origin=True, **anchor))
        s.add(RunInputLink(run_id=seed["run_id"], input_id=vi.id,
                           outcome_status=outcome, outcome_target=target))
        s.commit()
        return vi.id


def _classes(client, seed) -> dict:
    resp = client.get(f"/api/businesses/{seed['bid']}/runs/{seed['run_id']}/changes")
    assert resp.status_code == 200, resp.text
    return {c["element_path"]: c["change_class"] for c in resp.json()["changes"]}


# --------------------------------------------------------------------------
# change list
# --------------------------------------------------------------------------


def test_list_model_changes_at_the_decision_grain():
    changes = list_model_changes(_model_dict(BASE), _model_dict(OUTPUT))
    assert {(c.element_kind, c.element_path, c.change_kind) for c in changes} == EXPECTED


def test_case_only_type_change_is_not_listed():
    upper = {"Sales": {"Order": {"id": "INT", "amount": "DECIMAL"}, "Customer": {"id": "Int"}},
             "Billing": {"Invoice": {"id": "int"}}, "Ops": {"Shift": {"id": "int"}}}
    assert list_model_changes(_model_dict(BASE), _model_dict(upper)) == []


def test_list_model_changes_empty_for_identical_models():
    assert list_model_changes(_model_dict(BASE), _model_dict(BASE)) == []


def test_get_changes_lists_every_change(client, engine):
    seed = _seed(engine)
    resp = client.get(f"/api/businesses/{seed['bid']}/runs/{seed['run_id']}/changes")
    assert resp.status_code == 200, resp.text
    body = resp.json()
    assert (body["run_id"], body["version_id"], body["base_version_id"]) == (
        seed["run_id"], seed["out_id"], seed["base_id"])
    assert body["decisions_open"] is True
    assert {(c["element_kind"], c["element_path"], c["change_kind"]) for c in body["changes"]} == EXPECTED
    assert all(c["decision"] is None for c in body["changes"])


# --------------------------------------------------------------------------
# change_class hint
# --------------------------------------------------------------------------


def test_nothing_sent_means_not_asked(client, engine):
    seed = _seed(engine)
    assert set(_classes(client, seed).values()) == {"not_asked"}


def test_product_anchor_marks_its_attributes_asked(client, engine):
    seed = _seed(engine)
    _send_input(engine, seed, product_id=seed["base_ids"][("Sales", "Order")])
    classes = _classes(client, seed)
    assert classes["Sales.Order.amount"] == "asked"
    assert classes["Sales.Order.note"] == "asked"
    assert classes["Sales.Lead"] == "not_asked"


def test_domain_anchor_marks_every_change_in_the_domain_asked(client, engine):
    seed = _seed(engine)
    _send_input(engine, seed, domain_id=seed["base_ids"][("Sales",)])
    classes = _classes(client, seed)
    assert {p for p, c in classes.items() if c == "asked"} == {
        "Sales.Order.amount", "Sales.Order.note", "Sales.Customer", "Sales.Lead"}


def test_attribute_anchor_marks_only_that_attribute(client, engine):
    seed = _seed(engine)
    _send_input(engine, seed, attribute_id=seed["base_ids"][("Sales", "Order", "amount")])
    classes = _classes(client, seed)
    assert classes["Sales.Order.amount"] == "asked"
    assert classes["Sales.Order.note"] == "not_asked"


def test_subdomain_anchor_counts_as_its_domain(client, engine):
    seed = _seed(engine)
    with Session(engine) as s:
        sub = Subdomain(version_id=seed["base_id"], domain_id=seed["base_ids"][("Billing",)], name="AR")
        s.add(sub)
        s.commit()
        sub_id = sub.id
    _send_input(engine, seed, subdomain_id=sub_id)
    assert _classes(client, seed)["Billing.Payment"] == "asked"


def test_subdomain_outcome_target_counts_as_its_domain(client, engine):
    seed = _seed(engine)
    with Session(engine) as s:
        s.add(Subdomain(version_id=seed["base_id"], domain_id=seed["base_ids"][("Billing",)], name="Receivables"))
        s.commit()
    _send_input(engine, seed, domain_id=seed["base_ids"][("Ops",)], outcome="applied",
                target="Billing.Receivables")
    assert _classes(client, seed)["Billing.Payment"] == "asked"


def test_applied_outcome_target_marks_asked(client, engine):
    seed = _seed(engine)
    _send_input(engine, seed, domain_id=seed["base_ids"][("Ops",)], outcome="applied",
                target="billing.payment")
    classes = _classes(client, seed)
    assert classes["Billing.Payment"] == "asked"
    assert classes["Ops"] == "asked"


def test_deferred_outcome_target_does_not_mark_asked(client, engine):
    seed = _seed(engine)
    _send_input(engine, seed, domain_id=seed["base_ids"][("Ops",)], outcome="deferred",
                target="Billing.Payment")
    assert _classes(client, seed)["Billing.Payment"] == "not_asked"


def test_model_wide_input_makes_the_rest_unclear(client, engine):
    seed = _seed(engine)
    _send_input(engine, seed, product_id=seed["base_ids"][("Sales", "Order")])
    _send_input(engine, seed)
    classes = _classes(client, seed)
    assert classes["Sales.Order.amount"] == "asked"
    assert classes["Marketing"] == "unclear"


def test_scoped_run_flags_changes_outside_its_scope(client, engine):
    seed = _seed(engine, params={"vibe_scope": "some_domains", "vibe_scope_domains": ["Sales", "Billing"]})
    classes = _classes(client, seed)
    assert classes["Ops"] == "outside_scope"
    assert classes["Marketing"] == "outside_scope"
    assert classes["Sales.Lead"] == "not_asked"


# --------------------------------------------------------------------------
# unavailable
# --------------------------------------------------------------------------


def test_404_for_another_business(client, engine):
    seed = _seed(engine)
    other = _seed(engine, name="Other Co")
    resp = client.get(f"/api/businesses/{other['bid']}/runs/{seed['run_id']}/changes")
    assert resp.status_code == 404


def test_409_without_a_vibe_output(client, engine):
    seed = _seed(engine, with_op=False)
    resp = client.get(f"/api/businesses/{seed['bid']}/runs/{seed['run_id']}/changes")
    assert resp.status_code == 409
    detail = resp.json()["detail"]
    assert (detail["error"], detail["reason"]) == ("changes_unavailable", "no_vibe_output")


def test_409_when_the_base_is_gone(client, engine):
    seed = _seed(engine)
    with Session(engine) as s:
        out = s.get(ModelVersion, seed["out_id"])
        out.base_version_id = None
        s.add(out)
        s.commit()
    resp = client.get(f"/api/businesses/{seed['bid']}/runs/{seed['run_id']}/changes")
    assert resp.status_code == 409
    assert resp.json()["detail"]["reason"] == "no_base_version"


def test_409_when_a_model_cannot_be_loaded(client, engine):
    seed = _seed(engine)
    with Session(engine) as s:
        for d in s.exec(select(Domain).where(Domain.version_id == seed["base_id"])).all():
            for p in s.exec(select(Product).where(Product.domain_id == d.id)).all():
                for a in s.exec(select(Attribute).where(Attribute.product_id == p.id)).all():
                    s.delete(a)
                s.delete(p)
            s.delete(d)
        s.commit()
    resp = client.get(f"/api/businesses/{seed['bid']}/runs/{seed['run_id']}/changes")
    assert resp.status_code == 409
    assert resp.json()["detail"]["reason"] == "model_not_loaded"


# --------------------------------------------------------------------------
# decisions
# --------------------------------------------------------------------------


def _decide(client, seed, decisions, headers=WHO):
    return client.put(
        f"/api/businesses/{seed['bid']}/runs/{seed['run_id']}/changes/decisions",
        json={"decisions": decisions}, headers=headers,
    )


def _rows(engine):
    with Session(engine) as s:
        return sorted(
            (r.element_kind, r.element_path, r.change_kind, r.decision, r.decided_by, r.feedback_input_id)
            for r in s.exec(select(RunChangeDecision)).all()
        )


def test_decisions_are_recorded_with_who(client, engine):
    seed = _seed(engine)
    resp = _decide(client, seed, [
        {"element_kind": "domain", "element_path": "Ops", "decision": "rejected"},
        {"element_kind": "product", "element_path": "Sales.Lead", "decision": "accepted"},
    ])
    assert resp.status_code == 200, resp.text
    by_path = {c["element_path"]: c for c in resp.json()["changes"]}
    assert by_path["Ops"]["decision"] == "rejected"
    assert by_path["Ops"]["decided_by"] == "modeler@example.com"
    assert by_path["Ops"]["decided_at"].endswith(("Z", "+00:00"))
    assert by_path["Sales.Lead"]["decision"] == "accepted"
    assert _rows(engine) == [
        ("domain", "Ops", "removed", "rejected", "modeler@example.com", None),
        ("product", "Sales.Lead", "added", "accepted", "modeler@example.com", None),
    ]
    with Session(engine) as s:
        assert {r.version_id for r in s.exec(select(RunChangeDecision)).all()} == {seed["out_id"]}


def test_a_decision_can_be_changed(client, engine):
    seed = _seed(engine)
    assert _decide(client, seed, [{"element_kind": "domain", "element_path": "Ops", "decision": "rejected"}]).status_code == 200
    assert _decide(client, seed, [{"element_kind": "domain", "element_path": "Ops", "decision": "accepted"}]).status_code == 200
    assert [r[3] for r in _rows(engine)] == ["accepted"]


def test_unknown_change_is_refused_and_writes_nothing(client, engine):
    seed = _seed(engine)
    resp = _decide(client, seed, [
        {"element_kind": "domain", "element_path": "Ops", "decision": "rejected"},
        {"element_kind": "domain", "element_path": "Sales", "decision": "rejected"},
    ])
    assert resp.status_code == 422
    assert resp.json()["detail"]["error"] == "unknown_change"
    assert _rows(engine) == []


def _start_newer_run(engine, seed, *, intent="vibe-iterate", status="running", produced=False):
    with Session(engine) as s:
        later = Run(business_id=seed["bid"], intent=intent, status=status)
        s.add(later)
        s.flush()
        output_id = None
        if produced:
            mv = ModelVersion(business_id=seed["bid"], version=3, scope="ecm", status="completed",
                              base_version_id=seed["out_id"])
            s.add(mv)
            s.flush()
            output_id = mv.id
        s.add(RunOperation(run_id=later.id, step_index=0,
                           operation_name="install" if intent == "install" else "vibe_iterate",
                           status="succeeded" if produced or status == "completed" else status,
                           parent_version_id=seed["out_id"], output_version_id=output_id))
        s.commit()


def _open(client, seed) -> bool:
    resp = client.get(f"/api/businesses/{seed['bid']}/runs/{seed['run_id']}/changes")
    assert resp.status_code == 200, resp.text
    return resp.json()["decisions_open"]


@pytest.mark.parametrize("intent,status,produced,open_", [
    ("install", "completed", False, True),
    ("uninstall", "completed", False, True),
    ("generate-samples", "running", False, True),
    ("vibe-iterate", "failed", False, True),
    ("vibe-iterate", "cancelled", False, True),
    ("vibe-iterate", "completed", True, False),
    ("vibe-iterate", "pending", False, False),
    ("vibe-iterate", "failed", True, False),
], ids=["install", "uninstall", "samples", "failed-vibe", "cancelled-vibe", "completed-vibe",
        "pending-vibe", "failed-after-output"])
def test_which_runs_close_decisions(client, engine, intent, status, produced, open_):
    seed = _seed(engine)
    _start_newer_run(engine, seed, intent=intent, status=status, produced=produced)
    assert _open(client, seed) is open_
    resp = _decide(client, seed, [{"element_kind": "domain", "element_path": "Ops", "decision": "rejected"}])
    assert resp.status_code == (200 if open_ else 409)


def test_decisions_close_once_a_newer_run_starts(client, engine):
    seed = _seed(engine)
    assert _decide(client, seed, [{"element_kind": "domain", "element_path": "Ops", "decision": "rejected"}]).status_code == 200
    _start_newer_run(engine, seed)
    before = _rows(engine)
    resp = _decide(client, seed, [{"element_kind": "domain", "element_path": "Ops", "decision": "accepted"}])
    assert resp.status_code == 409
    assert resp.json()["detail"]["error"] == "decisions_closed"
    assert _rows(engine) == before
    got = client.get(f"/api/businesses/{seed['bid']}/runs/{seed['run_id']}/changes")
    assert got.status_code == 200
    assert got.json()["decisions_open"] is False


# --------------------------------------------------------------------------
# rejected changes as feedback
# --------------------------------------------------------------------------


def _feedback(client, seed, headers=WHO):
    return client.post(
        f"/api/businesses/{seed['bid']}/runs/{seed['run_id']}/changes/rejected-feedback",
        headers=headers,
    )


def test_rejections_become_anchored_unselected_feedback(client, engine):
    seed = _seed(engine)
    assert _decide(client, seed, [
        {"element_kind": "attribute", "element_path": "Sales.Order.amount", "decision": "rejected"},
        {"element_kind": "product", "element_path": "Sales.Customer", "decision": "rejected"},
        {"element_kind": "domain", "element_path": "Ops", "decision": "rejected"},
        {"element_kind": "product", "element_path": "Sales.Lead", "decision": "accepted"},
    ]).status_code == 200
    resp = _feedback(client, seed)
    assert resp.status_code == 200, resp.text
    by_path = {c["element_path"]: c for c in resp.json()["changes"]}
    assert by_path["Sales.Lead"]["feedback_input_id"] is None
    with Session(engine) as s:
        made = {}
        for path in ("Sales.Order.amount", "Sales.Customer", "Ops"):
            vi = s.get(VibeInput, by_path[path]["feedback_input_id"])
            link = s.exec(select(VibeInputContextLink).where(VibeInputContextLink.input_id == vi.id)).one()
            assert (vi.origin, vi.selected_for_run, vi.consumed, vi.author) == (
                "change_rejection", False, False, "modeler@example.com")
            assert (link.version_id, link.is_origin) == (seed["out_id"], True)
            made[path] = (vi.text, link)
    amount_text, amount_link = made["Sales.Order.amount"]
    assert amount_link.attribute_id == seed["out_ids"][("Sales", "Order", "amount")]
    assert amount_text.startswith("Undo the change to the attribute Sales.Order.amount.")
    customer_text, customer_link = made["Sales.Customer"]
    assert customer_link.domain_id == seed["out_ids"][("Sales",)]
    assert customer_link.product_id is None
    assert customer_text.startswith("Restore the product Sales.Customer.")
    _, ops_link = made["Ops"]
    assert not any((ops_link.domain_id, ops_link.product_id, ops_link.attribute_id))


def test_feedback_is_made_once_per_rejection(client, engine):
    seed = _seed(engine)
    assert _decide(client, seed, [{"element_kind": "domain", "element_path": "Marketing", "decision": "rejected"}]).status_code == 200
    assert _feedback(client, seed).status_code == 200
    assert _feedback(client, seed).status_code == 200
    with Session(engine) as s:
        assert len(s.exec(select(VibeInput).where(VibeInput.origin == "change_rejection")).all()) == 1


def test_feedback_refused_once_decisions_close(client, engine):
    seed = _seed(engine)
    assert _decide(client, seed, [{"element_kind": "domain", "element_path": "Ops", "decision": "rejected"}]).status_code == 200
    _start_newer_run(engine, seed)
    resp = _feedback(client, seed)
    assert resp.status_code == 409
    assert resp.json()["detail"]["error"] == "decisions_closed"
    with Session(engine) as s:
        assert s.exec(select(VibeInput).where(VibeInput.origin == "change_rejection")).all() == []


def test_get_writes_nothing(client, engine):
    seed = _seed(engine)
    _send_input(engine, seed)
    with Session(engine) as s:
        before = (len(s.exec(select(VibeInput)).all()), len(s.exec(select(VibeInputContextLink)).all()))
    assert client.get(f"/api/businesses/{seed['bid']}/runs/{seed['run_id']}/changes").status_code == 200
    with Session(engine) as s:
        after = (len(s.exec(select(VibeInput)).all()), len(s.exec(select(VibeInputContextLink)).all()))
    assert after == before and _rows(engine) == []


def test_feedback_keeps_the_resolvers_review_flag(client, engine):
    seed = _seed(engine)
    assert _decide(client, seed, [
        {"element_kind": "attribute", "element_path": "Sales.Order.note", "decision": "rejected"},
    ]).status_code == 200
    real = rc.prefetch_anchor_maps

    def maps_without_the_attribute(session, version_id):
        maps = real(session, version_id)
        maps.attributes.pop((seed["out_ids"][("Sales", "Order")], "note"))
        return maps

    with patch.object(rc, "prefetch_anchor_maps", maps_without_the_attribute):
        resp = _feedback(client, seed)
    assert resp.status_code == 200, resp.text
    with Session(engine) as s:
        link = s.exec(select(VibeInputContextLink).join(
            VibeInput, VibeInput.id == VibeInputContextLink.input_id,
        ).where(VibeInput.origin == "change_rejection")).one()
        assert (link.product_id, link.attribute_id, link.needs_link_review) == (
            seed["out_ids"][("Sales", "Order")], None, True)


def test_rolling_back_the_output_reopens_the_asks_and_drops_the_review(fk_client, fk_engine, monkeypatch):
    """The card's rollback copy: deleting P (``_version_lifecycle.delete_version``)
    reopens what the run applied and removes the decisions and the open
    rejection feedback made from P, on an FK-enforcing database."""
    monkeypatch.setattr(
        "vibe_modeling.backend.model_sync.ModelSyncService",
        type("_Sync", (), {"__init__": lambda self, *a, **k: None,
                           "delete_metamodel_rows": lambda self, **kw: True}),
    )
    seed = _seed(fk_engine)
    asked = _send_input(fk_engine, seed, product_id=seed["base_ids"][("Sales", "Order")])
    with Session(fk_engine) as s:
        vi = s.get(VibeInput, asked)
        vi.consumed, vi.consumed_by_run_id = True, seed["run_id"]
        s.add(vi)
        s.commit()
    assert _decide(fk_client, seed, [
        {"element_kind": "domain", "element_path": "Ops", "decision": "rejected"},
        {"element_kind": "product", "element_path": "Sales.Lead", "decision": "rejected"},
    ]).status_code == 200
    assert _feedback(fk_client, seed).status_code == 200
    resp = fk_client.delete(f"/api/businesses/{seed['bid']}/versions/{seed['out_id']}")
    assert resp.status_code == 200, resp.text
    assert resp.json()["reopened_input_count"] == 1
    with Session(fk_engine) as s:
        assert s.get(ModelVersion, seed["out_id"]) is None
        assert s.exec(select(RunChangeDecision)).all() == []
        assert s.exec(select(VibeInput).where(VibeInput.origin == "change_rejection")).all() == []
        reopened = s.get(VibeInput, asked)
        assert (reopened.consumed, reopened.consumed_by_run_id) == (False, None)


# --------------------------------------------------------------------------
# concurrency (file SQLite: separate connections, as two requests have)
# --------------------------------------------------------------------------


@pytest.fixture
def file_engine(tmp_path):
    eng = create_engine(f"sqlite:///{tmp_path / 'race.db'}", connect_args={"check_same_thread": False},
                        poolclass=NullPool)
    SQLModel.metadata.create_all(eng)
    return eng


@pytest.fixture
def file_client(file_engine, mock_ws, config, mock_tracker):
    from vibe_modeling.backend.core._defaults import _ConfigDependency, _WorkspaceClientDependency
    from vibe_modeling.backend.core._tracker import _TrackerDependency
    from vibe_modeling.backend.core.lakebase import _LakebaseDependency

    app = make_test_app()

    def override_session():
        with Session(file_engine) as session:
            yield session

    app.dependency_overrides[_LakebaseDependency.__call__] = override_session
    app.dependency_overrides[_ConfigDependency.__call__] = lambda: config
    app.dependency_overrides[_WorkspaceClientDependency.__call__] = lambda: mock_ws
    app.dependency_overrides[_TrackerDependency.__call__] = lambda: mock_tracker
    return TestClient(app)


def test_concurrent_first_decision_retries_over_the_winners_row(file_client, file_engine):
    seed = _seed(file_engine)
    real = rc._decision_rows
    raced = []

    def racing_rows(session, run_id):
        rows = real(session, run_id)
        if not raced:
            raced.append(True)
            with Session(file_engine) as other:
                other.add(RunChangeDecision(run_id=run_id, version_id=seed["out_id"], element_kind="domain",
                                            element_path="Ops", change_kind="removed", decision="accepted",
                                            decided_by="other@example.com"))
                other.commit()
        return rows

    with patch.object(rc, "_decision_rows", racing_rows):
        resp = _decide(file_client, seed, [{"element_kind": "domain", "element_path": "Ops", "decision": "rejected"}])
    assert resp.status_code == 200, resp.text
    assert _rows(file_engine) == [("domain", "Ops", "removed", "rejected", "modeler@example.com", None)]


def test_concurrent_feedback_leaves_one_item_per_rejection(file_client, file_engine):
    seed = _seed(file_engine)
    assert _decide(file_client, seed, [
        {"element_kind": "domain", "element_path": "Ops", "decision": "rejected"},
        {"element_kind": "product", "element_path": "Sales.Lead", "decision": "rejected"},
    ]).status_code == 200
    with Session(file_engine) as s:
        winner = VibeInput(business_id=seed["bid"], text="made by the other request", origin="change_rejection")
        s.add(winner)
        s.commit()
        winner_id = winner.id
    real = rc.create_vibe_input_with_anchor
    raced = []

    def racing_create(**kw):
        if not raced:
            raced.append(True)
            with Session(file_engine) as other:
                row = other.exec(select(RunChangeDecision).where(RunChangeDecision.element_path == "Ops")).one()
                row.feedback_input_id = winner_id
                other.add(row)
                other.commit()
        return real(**kw)

    with patch.object(rc, "create_vibe_input_with_anchor", racing_create):
        resp = _feedback(file_client, seed)
    assert resp.status_code == 200, resp.text
    by_path = {c["element_path"]: c["feedback_input_id"] for c in resp.json()["changes"]}
    assert by_path["Ops"] == winner_id
    with Session(file_engine) as s:
        inputs = s.exec(select(VibeInput).where(VibeInput.origin == "change_rejection")).all()
        assert sorted(i.id for i in inputs) == sorted([winner_id, by_path["Sales.Lead"]])
        orphan_links = s.exec(select(VibeInputContextLink).where(
            VibeInputContextLink.input_id.not_in([i.id for i in inputs]))).all()
        assert orphan_links == []


# --------------------------------------------------------------------------
# RBAC
# --------------------------------------------------------------------------


@pytest.fixture
def viewer_client(engine, mock_ws, config, mock_tracker):
    from vibe_modeling.backend.core._defaults import _ConfigDependency, _WorkspaceClientDependency
    from vibe_modeling.backend.core._roles import UserRole, resolve_user_role
    from vibe_modeling.backend.core._tracker import _TrackerDependency
    from vibe_modeling.backend.core.lakebase import _LakebaseDependency

    app = make_test_app()

    def override_session():
        with Session(engine) as session:
            yield session

    app.dependency_overrides[_LakebaseDependency.__call__] = override_session
    app.dependency_overrides[_ConfigDependency.__call__] = lambda: config
    app.dependency_overrides[_WorkspaceClientDependency.__call__] = lambda: mock_ws
    app.dependency_overrides[_TrackerDependency.__call__] = lambda: mock_tracker
    app.dependency_overrides[resolve_user_role] = lambda: UserRole.VIEWER
    return TestClient(app)


def test_viewer_reads_but_cannot_decide_or_add_feedback(viewer_client, engine):
    seed = _seed(engine)
    assert viewer_client.get(
        f"/api/businesses/{seed['bid']}/runs/{seed['run_id']}/changes", headers=WHO,
    ).status_code == 200
    assert _decide(viewer_client, seed, [
        {"element_kind": "domain", "element_path": "Ops", "decision": "rejected"},
    ]).status_code == 403
    assert _feedback(viewer_client, seed).status_code == 403
    assert _rows(engine) == []


def test_a_kickstarted_business_run_that_uninstalls_this_version_first_leaves_decisions_open(client, engine):
    """Rule 1: a vibe of a business kickstarted from this one starts with an
    ``uninstall`` step naming this version; that run does not start from it."""
    seed = _seed(engine)
    with Session(engine) as s:
        kick = Business(name="Kicked Co", description="d", source_industry_id=seed["bid"])
        s.add(kick)
        s.flush()
        base = ModelVersion(business_id=kick.id, version=1, scope="ecm", status="completed")
        s.add(base)
        s.flush()
        later = Run(business_id=kick.id, intent="vibe-iterate", status="running")
        s.add(later)
        s.flush()
        s.add(RunOperation(run_id=later.id, step_index=0, operation_name="uninstall", status="succeeded",
                           parent_version_id=seed["out_id"]))
        s.add(RunOperation(run_id=later.id, step_index=1, operation_name="vibe_iterate", status="running",
                           parent_version_id=base.id))
        s.commit()
    assert _open(client, seed) is True


# --------------------------------------------------------------------------
# the flag (AppConfig.run_change_review_enabled; on in the shared config fixture)
# --------------------------------------------------------------------------


def _gated_routes() -> list[tuple[str, str]]:
    from vibe_modeling.backend.routes import run_changes as rc_routes
    return [(m, r.path) for r in rc_routes.router.routes for m in sorted(r.methods)]


@pytest.mark.parametrize("method,path", _gated_routes())
def test_gated_routes_answer_404_while_the_review_is_off(client, engine, config, method, path):
    """Off: every run-change route is 404 and writes nothing; the ungated
    status route tells the UI so."""
    seed = _seed(engine)
    config.run_change_review_enabled = False
    url = path.replace("{business_id}", seed["bid"]).replace("{run_id}", seed["run_id"])
    body = {"decisions": [{"element_kind": "domain", "element_path": "Ops", "decision": "rejected"}]}
    r = client.request(method, url, json=body, headers=WHO)
    assert r.status_code == 404
    assert r.json()["detail"] == "Run change review is not enabled in this installation."
    assert _rows(engine) == []
    with Session(engine) as s:
        assert s.exec(select(VibeInput)).all() == []
    status = client.get("/api/config/run-change-review")
    assert status.status_code == 200 and status.json() == {"enabled": False}
