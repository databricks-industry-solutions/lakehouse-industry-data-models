"""API tests for the Vibe Inputs CRUD + disposition + links surface.

Covers backend/routes/vibe_inputs.py. See task5-backend-api.md §2.
"""

import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "..", "src", "app", "src"))

import pytest
from sqlmodel import Session, select

from vibe_modeling.backend.db_models import (
    Business,
    Domain,
    ModelVersion,
    Product,
    VibeInput,
    VibeInputContextLink,
)

HEADERS = {"X-Forwarded-Email": "alice@x.com"}


@pytest.fixture
def biz_version(engine):
    """Business + one completed version; returns (business_id, version_id)."""
    with Session(engine) as s:
        b = Business(name="Acme")
        s.add(b)
        s.commit()
        mv = ModelVersion(business_id=b.id, version=1, status="completed", scope="ecm")
        s.add(mv)
        s.commit()
        return b.id, mv.id


def test_create_input_materializes_origin_link(client, biz_version, engine):
    bid, vid = biz_version
    resp = client.post(
        f"/api/businesses/{bid}/inputs",
        json={"text": "Use snake_case", "version_id": vid},
        headers=HEADERS,
    )
    assert resp.status_code == 200, resp.text
    body = resp.json()
    assert body["text"] == "Use snake_case"
    assert body["author"] == "alice@x.com"
    assert body["origin"] == "user"
    assert body["status"] == "active"

    with Session(engine) as s:
        links = s.exec(
            select(VibeInputContextLink).where(
                VibeInputContextLink.input_id == body["id"]
            )
        ).all()
        assert len(links) == 1
        assert links[0].is_origin is True
        assert links[0].version_id == vid
        # model-wide origin (all-null element ids)
        assert links[0].domain_id is None


def _create(client, bid, vid, text="rule", **extra):
    payload = {"text": text, "version_id": vid, **extra}
    r = client.post(f"/api/businesses/{bid}/inputs", json=payload, headers=HEADERS)
    assert r.status_code == 200, r.text
    return r.json()


def test_create_empty_text_400(client, biz_version):
    bid, vid = biz_version
    r = client.post(f"/api/businesses/{bid}/inputs",
                    json={"text": "  ", "version_id": vid}, headers=HEADERS)
    assert r.status_code == 400


def test_create_missing_version_400(client, biz_version):
    bid, vid = biz_version
    r = client.post(f"/api/businesses/{bid}/inputs",
                    json={"text": "x"}, headers=HEADERS)
    assert r.status_code == 400


def test_create_unknown_business_404(client):
    r = client.post("/api/businesses/nope/inputs",
                    json={"text": "x", "version_id": "v"}, headers=HEADERS)
    assert r.status_code == 404


def test_get_and_cross_business_404(client, biz_version, engine):
    bid, vid = biz_version
    vi = _create(client, bid, vid)
    r = client.get(f"/api/businesses/{bid}/inputs/{vi['id']}")
    assert r.status_code == 200
    # Other business cannot see it.
    with Session(engine) as s:
        b2 = Business(name="Other")
        s.add(b2)
        s.commit()
        other_id = b2.id
    r = client.get(f"/api/businesses/{other_id}/inputs/{vi['id']}")
    assert r.status_code == 404


def test_get_input_hydrates_element_anchor(client, biz_version, engine):
    """Regression: getVibeInput must hydrate the context-link anchor (it used to
    return ``anchor: null`` because it called ``_input_to_out`` without it), so
    the card-details page and its "Open in model" focus can scope to the
    input's domain/product instead of falling back to all-domains."""
    bid, vid = biz_version
    # Mirror an agent_next_vibe input: one context link that IS the element
    # anchor (the table has a UNIQUE (input_id, version_id), so an input has a
    # single link per version).
    with Session(engine) as s:
        d = Domain(version_id=vid, name="sales")
        s.add(d)
        s.commit()
        p = Product(domain_id=d.id, version_id=vid, name="orders", table_name="orders")
        s.add(p)
        s.commit()
        vi = VibeInput(
            business_id=bid, origin="agent_next_vibe", author="",
            text="connect_table for sales.orders", priority="high", status="active",
        )
        s.add(vi)
        s.commit()
        iid = vi.id
        s.add(
            VibeInputContextLink(
                input_id=iid, version_id=vid,
                domain_id=d.id, product_id=p.id, is_origin=True,
            )
        )
        s.commit()

    got = client.get(f"/api/businesses/{bid}/inputs/{iid}")
    assert got.status_code == 200, got.text
    anchor = got.json()["anchor"]
    assert anchor is not None, "getVibeInput must hydrate the anchor (regression)"
    assert anchor["level"] == "element"
    assert anchor["domain_name"] == "sales"
    assert anchor["product_name"] == "orders"


def test_patch_text_and_priority(client, biz_version):
    bid, vid = biz_version
    vi = _create(client, bid, vid)
    r = client.patch(f"/api/businesses/{bid}/inputs/{vi['id']}",
                     json={"text": "new", "priority": "low"})
    assert r.status_code == 200
    body = r.json()
    assert body["text"] == "new"
    assert body["priority"] == "low"


def test_patch_deprecated_410(client, biz_version):
    bid, vid = biz_version
    vi = _create(client, bid, vid)
    client.delete(f"/api/businesses/{bid}/inputs/{vi['id']}", headers=HEADERS)
    r = client.patch(f"/api/businesses/{bid}/inputs/{vi['id']}", json={"text": "x"})
    assert r.status_code == 410


def test_soft_delete_sets_deprecated_by(client, biz_version):
    bid, vid = biz_version
    vi = _create(client, bid, vid)
    r = client.delete(f"/api/businesses/{bid}/inputs/{vi['id']}", headers=HEADERS)
    assert r.status_code == 200
    got = client.get(f"/api/businesses/{bid}/inputs/{vi['id']}").json()
    assert got["status"] == "deprecated"
    assert got["deprecated_by"] == "alice@x.com"


def test_restore_undoes_manual_delete(client, biz_version):
    bid, vid = biz_version
    vi = _create(client, bid, vid)
    client.delete(f"/api/businesses/{bid}/inputs/{vi['id']}", headers=HEADERS)
    r = client.post(f"/api/businesses/{bid}/inputs/{vi['id']}/restore")
    assert r.status_code == 200
    assert r.json()["status"] == "active"
    assert r.json()["deprecated_by"] is None


def test_restore_system_deprecated_409(client, biz_version, engine):
    bid, vid = biz_version
    vi = _create(client, bid, vid)
    with Session(engine) as s:
        row = s.get(VibeInput, vi["id"])
        row.status = "deprecated"
        row.deprecated_by = None
        s.add(row)
        s.commit()
    r = client.post(f"/api/businesses/{bid}/inputs/{vi['id']}/restore")
    assert r.status_code == 409
    assert "can't be restored" in r.json()["detail"]
    assert "add it again as new feedback" in r.json()["detail"]


def test_list_filters(client, biz_version, engine):
    bid, vid = biz_version
    a = _create(client, bid, vid, text="alpha", priority="high")
    b = _create(client, bid, vid, text="beta", priority="low")
    # filter by priority
    r = client.get(f"/api/businesses/{bid}/inputs?priority=low")
    ids = {x["id"] for x in r.json()}
    assert ids == {b["id"]}
    # filter by q
    r = client.get(f"/api/businesses/{bid}/inputs?q=alph")
    assert {x["id"] for x in r.json()} == {a["id"]}
    # filter by version_id (link join)
    r = client.get(f"/api/businesses/{bid}/inputs?version_id={vid}")
    assert {a["id"], b["id"]} <= {x["id"] for x in r.json()}
    # model_wide
    r = client.get(f"/api/businesses/{bid}/inputs?model_wide=true")
    assert {a["id"], b["id"]} <= {x["id"] for x in r.json()}


def test_links_list_origin_first(client, biz_version, engine):
    bid, vid = biz_version
    vi = _create(client, bid, vid)
    with Session(engine) as s:
        mv2 = ModelVersion(business_id=bid, version=2, status="completed", scope="ecm")
        s.add(mv2)
        s.commit()
        v2 = mv2.id
    client.post(f"/api/businesses/{bid}/inputs/{vi['id']}/links",
                json={"input_id": vi["id"], "version_id": v2})
    r = client.get(f"/api/businesses/{bid}/inputs/{vi['id']}/links")
    links = r.json()
    assert len(links) == 2
    assert links[0]["is_origin"] is True


def test_add_link_dup_409(client, biz_version):
    bid, vid = biz_version
    vi = _create(client, bid, vid)
    r = client.post(f"/api/businesses/{bid}/inputs/{vi['id']}/links",
                    json={"input_id": vi["id"], "version_id": vid})
    assert r.status_code == 409


def test_add_link_never_origin(client, biz_version, engine):
    bid, vid = biz_version
    vi = _create(client, bid, vid)
    with Session(engine) as s:
        mv2 = ModelVersion(business_id=bid, version=2, status="completed", scope="ecm")
        s.add(mv2)
        s.commit()
        v2 = mv2.id
    r = client.post(f"/api/businesses/{bid}/inputs/{vi['id']}/links",
                    json={"input_id": vi["id"], "version_id": v2, "is_origin": True})
    assert r.status_code == 200
    assert r.json()["is_origin"] is False


def test_unconsume_creates_one_link_to_head(client, biz_version, engine):
    bid, vid = biz_version
    vi = _create(client, bid, vid)
    client.post(f"/api/businesses/{bid}/inputs/{vi['id']}/consume")
    # head version is still vid (only completed version). Link to head exists
    # already (origin), so unconsume just flips the flag.
    r = client.post(f"/api/businesses/{bid}/inputs/{vi['id']}/unconsume")
    assert r.status_code == 200
    assert r.json()["consumed"] is False


def test_unconsume_clears_the_consuming_run(client, biz_version, engine):
    from vibe_modeling.backend.db_models import Run, VibeInput

    bid, vid = biz_version
    vi = _create(client, bid, vid)
    with Session(engine) as s:
        run = Run(business_id=bid, intent="vibe-iterate", status="completed")
        s.add(run)
        s.flush()
        row = s.get(VibeInput, vi["id"])
        row.consumed, row.consumed_by_run_id = True, run.id
        s.add(row)
        s.commit()
    r = client.post(f"/api/businesses/{bid}/inputs/{vi['id']}/unconsume")
    assert r.status_code == 200
    assert r.json()["consumed"] is False
    assert r.json()["consumed_by_run_id"] is None


def test_unconsume_links_only_to_head_via_tiers(client, biz_version, engine):
    """Anchor on v1 domain that survives (pointer) to head v3; intervening v2
    gets NO link, only head."""
    bid, v1 = biz_version
    with Session(engine) as s:
        d1 = Domain(version_id=v1, name="Sales")
        s.add(d1)
        s.commit()
        d1_id = d1.id
        mv2 = ModelVersion(business_id=bid, version=2, status="completed", scope="ecm")
        s.add(mv2)
        s.commit()
        v2 = mv2.id
        mv3 = ModelVersion(business_id=bid, version=3, status="completed",
                           scope="ecm", base_version_id=v1)
        s.add(mv3)
        s.commit()
        v3 = mv3.id
        d3 = Domain(version_id=v3, name="Sales", previous_element_id=d1_id)
        s.add(d3)
        s.commit()
        d3_id = d3.id
    vi = _create(client, bid, v1, domain_id=d1_id)
    client.post(f"/api/businesses/{bid}/inputs/{vi['id']}/consume")

    r = client.post(f"/api/businesses/{bid}/inputs/{vi['id']}/unconsume")
    assert r.status_code == 200
    with Session(engine) as s:
        links = s.exec(
            select(VibeInputContextLink).where(
                VibeInputContextLink.input_id == vi["id"]
            )
        ).all()
        by_ver = {lk.version_id: lk for lk in links}
        assert v3 in by_ver           # head linked
        assert v2 not in by_ver       # intervening NOT linked
        assert by_ver[v3].domain_id == d3_id


def test_unconsume_head_context_gone_409(client, biz_version, engine):
    bid, v1 = biz_version
    with Session(engine) as s:
        d1 = Domain(version_id=v1, name="Sales")
        s.add(d1)
        s.commit()
        d1_id = d1.id
        # head v2 has no Sales domain and nothing pointing back.
        mv2 = ModelVersion(business_id=bid, version=2, status="completed",
                           scope="ecm", base_version_id=v1)
        s.add(mv2)
        s.commit()
    vi = _create(client, bid, v1, domain_id=d1_id)
    client.post(f"/api/businesses/{bid}/inputs/{vi['id']}/consume")

    r = client.post(f"/api/businesses/{bid}/inputs/{vi['id']}/unconsume")
    assert r.status_code == 409
    # Not silently deprecated.
    got = client.get(f"/api/businesses/{bid}/inputs/{vi['id']}").json()
    assert got["status"] == "active"


def test_product_review_mark_idempotent_and_clear(client, biz_version, engine):
    bid, vid = biz_version
    with Session(engine) as s:
        d = Domain(version_id=vid, name="Sales")
        s.add(d)
        s.commit()
        p = Product(version_id=vid, domain_id=d.id, name="Orders")
        s.add(p)
        s.commit()
        p_id = p.id
    r = client.post(f"/api/businesses/{bid}/versions/1/ecm/reviews/product/{p_id}",
                    json={"state": "reviewed"}, headers=HEADERS)
    assert r.status_code == 200
    first_id = r.json()["id"]
    assert r.json()["reviewer"] == "alice@x.com"
    assert r.json()["is_explicit"] is True
    # The resolved MV id is still surfaced in the response body.
    assert r.json()["version_id"] == vid
    # Idempotent upsert: same row, state updated.
    r2 = client.post(f"/api/businesses/{bid}/versions/1/ecm/reviews/product/{p_id}",
                     json={"state": "no_review_needed"}, headers=HEADERS)
    assert r2.json()["id"] == first_id
    assert r2.json()["state"] == "no_review_needed"
    # Clear.
    r3 = client.delete(f"/api/businesses/{bid}/versions/1/ecm/reviews/product/{p_id}")
    assert r3.status_code == 200


def test_product_review_product_not_in_version_400(client, biz_version):
    bid, vid = biz_version
    r = client.post(f"/api/businesses/{bid}/versions/1/ecm/reviews/product/nope",
                    json={"state": "reviewed"}, headers=HEADERS)
    assert r.status_code == 400


def test_product_review_bad_version_404(client, biz_version):
    # Composite key resolving to no MV → 404 (matches the read routes).
    bid, _ = biz_version
    r = client.post(f"/api/businesses/{bid}/versions/999/ecm/reviews/product/x",
                    json={"state": "reviewed"}, headers=HEADERS)
    assert r.status_code == 404


def test_clear_missing_404(client, biz_version):
    bid, vid = biz_version
    r = client.delete(f"/api/businesses/{bid}/versions/1/ecm/reviews/product/x")
    assert r.status_code == 404


def test_compile_endpoint_scopes_to_business(client, biz_version):
    bid, vid = biz_version
    a = _create(client, bid, vid, text="rule a")
    r = client.post(f"/api/businesses/{bid}/versions/{vid}/inputs/compile",
                    json={"input_ids": [a["id"]]})
    assert r.status_code == 200
    body = r.json()
    assert body["included_input_ids"] == [a["id"]]
    assert "## Model-wide" in body["markdown"]
    assert "- (medium) rule a" in body["markdown"]


def test_compile_endpoint_returns_each_items_scope_domain(client, biz_version, engine):
    """The wire carries the scope domain per item, for a scoped call and an
    unscoped one alike; a model-wide item maps to null."""
    bid, vid = biz_version
    with Session(engine) as s:
        d = Domain(version_id=vid, name="Sales")
        s.add(d)
        s.commit()
        d_id = d.id
    anchored = _create(client, bid, vid, text="sales rule", domain_id=d_id)
    model_wide = _create(client, bid, vid, text="global rule")
    url = f"/api/businesses/{bid}/versions/{vid}/inputs/compile"
    ids = [anchored["id"], model_wide["id"]]

    unscoped = client.post(url, json={"input_ids": ids})
    assert unscoped.status_code == 200, unscoped.text
    assert unscoped.json()["input_scope_domains"] == {anchored["id"]: "Sales", model_wide["id"]: None}

    scoped = client.post(url, json={"input_ids": ids, "vibe_scope_domains": ["Sales"]})
    assert scoped.status_code == 200, scoped.text
    assert scoped.json()["input_scope_domains"] == unscoped.json()["input_scope_domains"]
    assert scoped.json()["included_input_ids"] == [anchored["id"]]


# --- setVibeInputSelection (persisted run-selection) --------------------------

def test_set_selection_selects_and_deselects(client, biz_version):
    bid, vid = biz_version
    vi = _create(client, bid, vid)
    assert vi["selected_for_run"] is False  # default deselected

    r = client.post(f"/api/businesses/{bid}/inputs/selection",
                    json={"input_ids": [vi["id"]], "selected": True})
    assert r.status_code == 200, r.text
    body = r.json()
    assert len(body) == 1
    assert body[0]["id"] == vi["id"]
    assert body[0]["selected_for_run"] is True
    # Persisted: a fresh GET reflects it.
    assert client.get(f"/api/businesses/{bid}/inputs/{vi['id']}").json()["selected_for_run"] is True

    r = client.post(f"/api/businesses/{bid}/inputs/selection",
                    json={"input_ids": [vi["id"]], "selected": False})
    assert r.json()[0]["selected_for_run"] is False
    assert client.get(f"/api/businesses/{bid}/inputs/{vi['id']}").json()["selected_for_run"] is False


def test_set_selection_bulk(client, biz_version):
    bid, vid = biz_version
    a = _create(client, bid, vid, text="a")
    b = _create(client, bid, vid, text="b")
    r = client.post(f"/api/businesses/{bid}/inputs/selection",
                    json={"input_ids": [a["id"], b["id"]], "selected": True})
    assert r.status_code == 200
    assert {row["id"] for row in r.json()} == {a["id"], b["id"]}
    assert all(row["selected_for_run"] for row in r.json())


def test_set_selection_skips_consumed(client, biz_version):
    bid, vid = biz_version
    vi = _create(client, bid, vid)
    client.post(f"/api/businesses/{bid}/inputs/{vi['id']}/consume")
    r = client.post(f"/api/businesses/{bid}/inputs/selection",
                    json={"input_ids": [vi["id"]], "selected": True})
    assert r.status_code == 200
    # Consumed input is skipped (selection is moot once consumed).
    assert r.json() == []
    assert client.get(f"/api/businesses/{bid}/inputs/{vi['id']}").json()["selected_for_run"] is False


def test_set_selection_cross_business_ignored(client, biz_version, engine):
    bid, vid = biz_version
    vi = _create(client, bid, vid)
    with Session(engine) as s:
        other = Business(name="Other")
        s.add(other)
        s.commit()
        other_id = other.id
        ov = ModelVersion(business_id=other_id, version=1, status="completed", scope="ecm")
        s.add(ov)
        s.commit()
        other_vid = ov.id
    other_vi = _create(client, other_id, other_vid)
    # Target the OTHER business's input + an unknown id from THIS business:
    # both are silently ignored (business-scoped), not a 404, and untouched.
    r = client.post(f"/api/businesses/{bid}/inputs/selection",
                    json={"input_ids": [vi["id"], other_vi["id"], "nope"], "selected": True})
    assert r.status_code == 200
    assert {row["id"] for row in r.json()} == {vi["id"]}
    assert client.get(
        f"/api/businesses/{other_id}/inputs/{other_vi['id']}").json()["selected_for_run"] is False


def test_set_selection_skips_deprecated(client, biz_version):
    bid, vid = biz_version
    vi = _create(client, bid, vid)
    client.delete(f"/api/businesses/{bid}/inputs/{vi['id']}")  # soft-delete → deprecated
    r = client.post(f"/api/businesses/{bid}/inputs/selection",
                    json={"input_ids": [vi["id"]], "selected": True})
    assert r.status_code == 200
    assert r.json() == []
    assert client.get(f"/api/businesses/{bid}/inputs/{vi['id']}").json()["selected_for_run"] is False


def test_set_selection_empty_ids(client, biz_version):
    bid, vid = biz_version
    r = client.post(f"/api/businesses/{bid}/inputs/selection",
                    json={"input_ids": [], "selected": True})
    assert r.status_code == 200
    assert r.json() == []


def test_set_selection_missing_business_404(client):
    r = client.post("/api/businesses/nope/inputs/selection",
                    json={"input_ids": [], "selected": True})
    assert r.status_code == 404


# --- createVibeInput origin_context resolution -------------------------------

def _seed_model(engine, vid):
    """Seed a Sales domain with an Orders product + one FK link on `vid`."""
    from vibe_modeling.backend.db_models import ForeignKeyLink
    with Session(engine) as s:
        d = Domain(version_id=vid, name="Sales")
        s.add(d)
        s.commit()
        d_id = d.id
        p = Product(version_id=vid, domain_id=d_id, name="Orders", table_name="orders")
        s.add(p)
        s.commit()
        p_id = p.id
        fk = ForeignKeyLink(
            version_id=vid, source_domain="Sales", source_product="Orders",
            source_column="cust_id", target_domain="Sales",
            target_product="Customers", target_column="id",
        )
        s.add(fk)
        s.commit()
        fk_id = fk.id
    return d_id, p_id, fk_id


def _link_of(engine, input_id):
    with Session(engine) as s:
        return s.exec(
            select(VibeInputContextLink).where(VibeInputContextLink.input_id == input_id)
        ).first()


def test_create_origin_context_resolves_product(client, biz_version, engine):
    bid, vid = biz_version
    d_id, p_id, _ = _seed_model(engine, vid)
    vi = _create(client, bid, vid, origin_context={"selected_node_id": "Sales.Orders"})
    lk = _link_of(engine, vi["id"])
    assert lk.product_id == p_id
    assert lk.domain_id == d_id
    assert lk.is_origin is True


def test_create_origin_context_resolves_domain(client, biz_version, engine):
    bid, vid = biz_version
    d_id, _, _ = _seed_model(engine, vid)
    vi = _create(client, bid, vid, origin_context={"domain_filter": "Sales"})
    lk = _link_of(engine, vi["id"])
    assert lk.domain_id == d_id
    assert lk.product_id is None


def test_create_origin_context_resolves_fk(client, biz_version, engine):
    bid, vid = biz_version
    _, _, fk_id = _seed_model(engine, vid)
    vi = _create(client, bid, vid, origin_context={
        "selected_edge_id": "fk:Sales.Orders.cust_id>Sales.Customers.id"})
    lk = _link_of(engine, vi["id"])
    assert lk.fk_link_id == fk_id


def test_create_origin_context_model_wide(client, biz_version, engine):
    bid, vid = biz_version
    _seed_model(engine, vid)
    vi = _create(client, bid, vid, origin_context={})
    lk = _link_of(engine, vi["id"])
    assert lk.domain_id is None and lk.product_id is None and lk.fk_link_id is None
    assert lk.needs_link_review is False


def _seed_attribute(engine, product_id, name="amount"):
    from vibe_modeling.backend.db_models import Attribute
    with Session(engine) as s:
        a = Attribute(product_id=product_id, name=name, type="decimal")
        s.add(a)
        s.commit()
        return a.id


def test_create_origin_context_resolves_attribute(client, biz_version, engine):
    bid, vid = biz_version
    d_id, p_id, _ = _seed_model(engine, vid)
    a_id = _seed_attribute(engine, p_id)
    vi = _create(client, bid, vid, origin_context={
        "selected_node_id": "Sales.Orders", "selected_attribute": "amount"})
    lk = _link_of(engine, vi["id"])
    assert (lk.domain_id, lk.product_id, lk.attribute_id) == (d_id, p_id, a_id)
    assert lk.needs_link_review is False


def test_create_origin_context_unknown_attribute_degrades_to_product(client, biz_version, engine):
    bid, vid = biz_version
    _, p_id, _ = _seed_model(engine, vid)
    vi = _create(client, bid, vid, origin_context={
        "selected_node_id": "Sales.Orders", "selected_attribute": "missing"})
    lk = _link_of(engine, vi["id"])
    assert lk.product_id == p_id
    assert lk.attribute_id is None
    assert lk.needs_link_review is True


LEGACY_VIEW_STATE = {
    "context_version": 1,
    "view_mode": "relationships",
    "column_mode": "all",
    "hide_cross_domain": True,
}


def test_create_ignores_legacy_view_state(client, biz_version, engine):
    """An old client still sending tab/view state is accepted; the view keys
    are dropped and the anchor comes from the element names alone."""
    bid, vid = biz_version
    d_id, _, _ = _seed_model(engine, vid)
    only_view = _create(client, bid, vid, text="global rule",
                        origin_context=LEGACY_VIEW_STATE)
    lk = _link_of(engine, only_view["id"])
    assert (lk.domain_id, lk.product_id, lk.fk_link_id) == (None, None, None)
    with_domain = _create(client, bid, vid, text="sales rule",
                          origin_context={**LEGACY_VIEW_STATE, "domain_filter": "Sales"})
    assert _link_of(engine, with_domain["id"]).domain_id == d_id


def test_view_state_never_reaches_compiled_instructions(client, biz_version, engine):
    """Neither the human preview nor the agent markdown (what a run sends as
    its instructions) carries view state from the create payload."""
    bid, vid = biz_version
    _seed_model(engine, vid)
    ids = [
        _create(client, bid, vid, text="global rule",
                origin_context=LEGACY_VIEW_STATE)["id"],
        _create(client, bid, vid, text="orders rule",
                origin_context={**LEGACY_VIEW_STATE, "selected_node_id": "Sales.Orders"})["id"],
    ]
    r = client.post(f"/api/businesses/{bid}/versions/{vid}/inputs/compile",
                    json={"input_ids": ids})
    assert r.status_code == 200, r.text
    body = r.json()
    assert body["included_input_ids"] == ids
    for doc in (body["markdown"], body["agent_markdown"]):
        assert "global rule" in doc and "orders rule" in doc
        lowered = doc.lower()
        for leaked in ("relationships", "view", "column_mode", "hide_cross_domain"):
            assert leaked not in lowered, (leaked, doc)
    assert "[Sales.Orders]" in body["agent_markdown"]


def test_create_origin_context_resolves_against_viewed_version(client, biz_version, engine):
    """The anchor resolves against the version the caller is viewing, not the
    latest version of the model."""
    bid, v1 = biz_version
    d1_id, p1_id, _ = _seed_model(engine, v1)
    with Session(engine) as s:
        mv2 = ModelVersion(business_id=bid, version=2, status="completed", scope="ecm")
        s.add(mv2)
        s.commit()
        v2 = mv2.id
        d2 = Domain(version_id=v2, name="Sales")  # same NAME, different version
        s.add(d2)
        s.commit()
        p2 = Product(version_id=v2, domain_id=d2.id, name="Orders", table_name="orders")
        s.add(p2)
        s.commit()
    # Create while viewing v1 → must bind to v1's product, not v2's.
    vi = _create(client, bid, v1, origin_context={"selected_node_id": "Sales.Orders"})
    lk = _link_of(engine, vi["id"])
    assert lk.version_id == v1
    assert lk.product_id == p1_id


def test_create_explicit_ids_take_precedence_over_context(client, biz_version, engine):
    bid, vid = biz_version
    d_id, p_id, _ = _seed_model(engine, vid)
    # Explicit domain_id given AND a context pointing at the product: explicit wins.
    vi = _create(client, bid, vid, domain_id=d_id,
                 origin_context={"selected_node_id": "Sales.Orders"})
    lk = _link_of(engine, vi["id"])
    assert lk.domain_id == d_id
    assert lk.product_id is None


def test_relationship_anchor_round_trips_as_feedback_context(client, biz_version, engine):
    """A cross-domain relationship input exposes its diagram edge id, and new
    feedback sent with that id as selected_edge_id anchors to the same FK (the
    input-review page's Add-feedback)."""
    from vibe_modeling.backend.db_models import ForeignKeyLink
    bid, vid = biz_version
    with Session(engine) as s:
        fk = ForeignKeyLink(
            version_id=vid, source_domain="Sales", source_product="Orders",
            source_column="cust_id", target_domain="Party",
            target_product="Customers", target_column="id",
        )
        s.add(fk)
        s.commit()
        fk_id = fk.id
    rel = _create(client, bid, vid, text="relationship rule", fk_link_id=fk_id)

    got = client.get(f"/api/businesses/{bid}/inputs/{rel['id']}")
    assert got.status_code == 200, got.text
    anchor = got.json()["anchor"]
    assert anchor["domain_name"] is None
    assert anchor["fk_edge_id"] == "fk:Sales.Orders.cust_id>Party.Customers.id"

    again = _create(client, bid, vid, text="more on it",
                    origin_context={"selected_edge_id": anchor["fk_edge_id"]})
    lk = _link_of(engine, again["id"])
    assert lk.fk_link_id == fk_id
    assert lk.needs_link_review is False


def test_fk_edge_id_parses_back_to_its_names():
    from vibe_modeling.backend.fk import fk_edge_id, parse_fk_edge_id
    edge = fk_edge_id("Sales.Orders", "cust_id", "Party.Customers", "id")
    assert edge == "fk:Sales.Orders.cust_id>Party.Customers.id"
    assert parse_fk_edge_id(edge) == ("Sales", "Orders", "cust_id", "Party", "Customers", "id")
    assert parse_fk_edge_id("fk:Sales.Orders>Party.Customers") == (
        "Sales", "Orders", None, "Party", "Customers", None)
    assert parse_fk_edge_id("not-an-edge") is None
