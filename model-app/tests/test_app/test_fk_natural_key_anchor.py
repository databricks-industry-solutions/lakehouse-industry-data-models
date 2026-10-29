"""An FK anchor names the exact relationship, also when a product pair has
several FKs.

The real advertising model (`tests/fixtures/real_agent_model_sample.json`)
has three FKs from `client.advertiser_hierarchy` to `client.advertiser`
(child / parent / primary root). Every path that names an FK by its names
must land on the one meant: a diagram edge selection, the input-review page
(the anchor's `fk_edge_id` sent back), and the kickstart clone / force-resync
re-anchor (`capture_named_anchor` + `resolve_named_anchor`). A column-less
match that finds several FKs flags review instead of picking one. The diagram
edge carries the attribute's `column_name`; ForeignKeyLink stores its name.
"""

import json
import os
import sys

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "..", "src", "app", "src"))

import pytest
from sqlmodel import Session, select

from vibe_modeling.backend.core.anchor_resolve import (
    capture_named_anchor,
    prefetch_anchor_maps,
    prefetch_id_name_maps,
    resolve_named_anchor,
)
from vibe_modeling.backend.db_models import (
    Attribute,
    Business,
    Domain,
    ForeignKeyLink,
    ModelVersion,
    Product,
    VibeInputContextLink,
)
from vibe_modeling.backend.diagram import _build_product_index, _collect_fk_edges
from vibe_modeling.backend.fk import fk_edge_id, parse_fk_edge_id
from vibe_modeling.backend.model_sync import ModelSyncService

HEADERS = {"X-Forwarded-Email": "alice@x.com"}
FIXTURE = os.path.join(os.path.dirname(__file__), "..", "fixtures", "real_agent_model_sample.json")
SRC, TGT = "client.advertiser_hierarchy", "client.advertiser"
HIERARCHY_COLUMNS = {"child_advertiser_id", "parent_advertiser_id", "primary_root_advertiser_id"}


def _real_model() -> dict:
    with open(FIXTURE) as f:
        return json.load(f)["model"]


def _synced_version(engine, business_id: str, number: int) -> str:
    with Session(engine) as s:
        mv = ModelVersion(business_id=business_id, version=number, status="completed", scope="ecm")
        s.add(mv)
        s.commit()
        vid = mv.id
        ModelSyncService(s).sync_from_model_json(vid, _real_model())
        s.commit()
    return vid


@pytest.fixture
def business(engine) -> str:
    with Session(engine) as s:
        b = Business(name="Acme Ads")
        s.add(b)
        s.commit()
        return b.id


def _create(client, bid, vid, **extra) -> dict:
    r = client.post(f"/api/businesses/{bid}/inputs",
                    json={"text": "rule", "version_id": vid, **extra}, headers=HEADERS)
    assert r.status_code == 200, r.text
    return r.json()


def _link(engine, input_id) -> VibeInputContextLink:
    with Session(engine) as s:
        return s.exec(
            select(VibeInputContextLink).where(VibeInputContextLink.input_id == input_id)
        ).one()


def _fk(engine, fk_id) -> ForeignKeyLink:
    with Session(engine) as s:
        return s.get(ForeignKeyLink, fk_id)


def _hierarchy_fks(engine, vid) -> dict[str, str]:
    """source_column -> fk id for the three hierarchy FKs on `vid`."""
    with Session(engine) as s:
        rows = s.exec(select(ForeignKeyLink).where(
            ForeignKeyLink.version_id == vid,
            ForeignKeyLink.source_product == "advertiser_hierarchy",
            ForeignKeyLink.target_product == "advertiser",
        )).all()
    return {r.source_column: r.id for r in rows}


def test_fixture_has_a_multi_fk_pair(engine, business):
    vid = _synced_version(engine, business, 1)
    assert set(_hierarchy_fks(engine, vid)) == HIERARCHY_COLUMNS


def test_each_diagram_edge_selects_its_own_fk(client, engine, business):
    vid = _synced_version(engine, business, 1)
    model = _real_model()
    edges = [
        e for e in _collect_fk_edges(model, _build_product_index(model), None)
        if e["source_node"] == SRC and e["target_node"] == TGT
    ]
    assert {e["source_column"] for e in edges} == HIERARCHY_COLUMNS
    for e in edges:
        edge = fk_edge_id(e["source_node"], e["source_column"], e["target_node"], e["target_column"])
        lk = _link(engine, _create(client, business, vid,
                                   origin_context={"selected_edge_id": edge})["id"])
        assert lk.needs_link_review is False
        assert _fk(engine, lk.fk_link_id).source_column == e["source_column"]


def test_input_review_relationship_round_trips_to_the_same_fk(client, engine, business):
    vid = _synced_version(engine, business, 1)
    for column, fk_id in _hierarchy_fks(engine, vid).items():
        rel = _create(client, business, vid, fk_link_id=fk_id)
        got = client.get(f"/api/businesses/{business}/inputs/{rel['id']}")
        assert got.status_code == 200, got.text
        edge = got.json()["anchor"]["fk_edge_id"]
        assert edge == f"fk:{SRC}.{column}>{TGT}.advertiser_id"
        again = _create(client, business, vid, origin_context={"selected_edge_id": edge})
        lk = _link(engine, again["id"])
        assert lk.fk_link_id == fk_id
        assert lk.needs_link_review is False


@pytest.mark.parametrize("prefetched", [False, True])
def test_reanchor_keeps_the_exact_fk(client, engine, business, prefetched):
    """Kickstart clone / force-resync capture an FK anchor by names on one
    version and resolve it on another with the same elements."""
    v1 = _synced_version(engine, business, 1)
    v2 = _synced_version(engine, business, 2)
    v2_fks = _hierarchy_fks(engine, v2)
    for column, fk_id in _hierarchy_fks(engine, v1).items():
        with Session(engine) as s:
            link = VibeInputContextLink(input_id="x", version_id=v1, fk_link_id=fk_id)
            named = capture_named_anchor(
                s, link, prefetch_id_name_maps(s, v1) if prefetched else None)
            assert named.fk_parts == (
                "client", "advertiser_hierarchy", column, "client", "advertiser", "advertiser_id")
            fks = resolve_named_anchor(
                s, v2, named, prefetch_anchor_maps(s, v2) if prefetched else None)
        assert fks.fk_link_id == v2_fks[column]
        assert fks.needs_link_review is False


def test_columnless_edge_is_exact_only_when_unique(client, engine, business):
    vid = _synced_version(engine, business, 1)
    ambiguous = _create(client, business, vid,
                        origin_context={"selected_edge_id": f"fk:{SRC}>{TGT}"})
    lk = _link(engine, ambiguous["id"])
    assert lk.fk_link_id is None
    assert lk.product_id is not None
    assert lk.needs_link_review is True

    with Session(engine) as s:
        single = s.exec(select(ForeignKeyLink).where(ForeignKeyLink.version_id == vid)).all()
    pairs: dict[tuple, list[ForeignKeyLink]] = {}
    for fk in single:
        pairs.setdefault((fk.source_domain, fk.source_product, fk.target_domain, fk.target_product), []).append(fk)
    (sd, sp, td, tp), (only,) = next((k, v) for k, v in pairs.items() if len(v) == 1)
    unique = _create(client, business, vid,
                     origin_context={"selected_edge_id": f"fk:{sd}.{sp}>{td}.{tp}"})
    lk = _link(engine, unique["id"])
    assert lk.fk_link_id == only.id
    assert lk.needs_link_review is False


def test_attribute_name_differs_from_its_column(client, engine, business):
    """ForeignKeyLink.source_column holds the attribute name; the diagram edge
    carries its column_name. Both directions agree."""
    with Session(engine) as s:
        mv = ModelVersion(business_id=business, version=1, status="completed", scope="ecm")
        s.add(mv)
        s.commit()
        vid = mv.id
        d = Domain(version_id=vid, name="Sales")
        s.add(d)
        s.commit()
        p = Product(version_id=vid, domain_id=d.id, name="Orders", table_name="orders")
        s.add(p)
        s.commit()
        for name, col in (("Customer Ref", "cust_ref"), ("Billing Ref", "bill_ref")):
            s.add(Attribute(product_id=p.id, name=name, column_name=col))
            s.add(ForeignKeyLink(
                version_id=vid, source_domain="Sales", source_product="Orders",
                source_column=name, target_domain="Sales",
                target_product="Customers", target_column="id",
            ))
        s.commit()
        billing = s.exec(select(ForeignKeyLink.id).where(
            ForeignKeyLink.source_column == "Billing Ref")).one()

    edge = "fk:Sales.Orders.bill_ref>Sales.Customers.id"
    assert parse_fk_edge_id(edge) == ("Sales", "Orders", "bill_ref", "Sales", "Customers", "id")
    lk = _link(engine, _create(client, business, vid,
                               origin_context={"selected_edge_id": edge})["id"])
    assert lk.fk_link_id == billing
    assert lk.needs_link_review is False

    rel = _create(client, business, vid, fk_link_id=billing)
    got = client.get(f"/api/businesses/{business}/inputs/{rel['id']}")
    assert got.status_code == 200, got.text
    assert got.json()["anchor"]["fk_edge_id"] == edge
