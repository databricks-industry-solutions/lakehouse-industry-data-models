"""Tests for the Industry catalog endpoints: DELETE and the create slug guard.

The list and update paths are covered indirectly by the
contracts + RBAC test suites. This file gates the ``deleteIndustry``
endpoint so a refactor can't silently turn it back into a 200 on the
in-use case (which would let the user nuke an industry that businesses
still reference and leave FKs dangling), and ``createIndustry``'s refusal
of a slug an active industry already has.
"""

from __future__ import annotations

from sqlmodel import Session, select

from vibe_modeling.backend.db_models import Business, Industry


def _seed_industry(engine, **kwargs) -> str:
    defaults = dict(
        name="Retail",
        short_name="retail",
        description="Retail seed text",
        notable_businesses="Amazon, Walmart, Target",
        display_order=10,
        is_active=True,
    )
    defaults.update(kwargs)
    with Session(engine) as session:
        ind = Industry(**defaults)
        session.add(ind)
        session.commit()
        session.refresh(ind)
        return ind.id


def test_delete_unused_industry_returns_ok_and_removes_row(client, engine):
    """An industry no business references can be deleted cleanly."""
    industry_id = _seed_industry(engine)

    resp = client.delete(f"/api/industries/{industry_id}")
    assert resp.status_code == 200, resp.text
    assert resp.json() == {"ok": True}

    # Row is actually gone.
    with Session(engine) as session:
        assert session.get(Industry, industry_id) is None

    # And the list endpoint reflects it.
    list_resp = client.get("/api/industries")
    assert list_resp.status_code == 200
    assert all(i["id"] != industry_id for i in list_resp.json())


def test_delete_industry_referenced_by_business_returns_409(client, engine):
    """When at least one Business.industry_id points at this Industry,
    refuse the delete with a structured 409 detail so the UI can render
    a useful "reassign these first" message — and the row is preserved.
    """
    industry_id = _seed_industry(engine, name="Auto-Created Retail")

    with Session(engine) as session:
        session.add(
            Business(
                name="BizOne",
                description="ref a",
                industry_alignment="auto-created-retail",
                industry_id=industry_id,
            )
        )
        session.add(
            Business(
                name="BizTwo",
                description="ref b",
                industry_alignment="auto-created-retail",
                industry_id=industry_id,
            )
        )
        session.commit()

    resp = client.delete(f"/api/industries/{industry_id}")
    assert resp.status_code == 409, resp.text
    detail = resp.json()["detail"]
    assert detail["error"] == "industry_in_use"
    assert detail["industry_id"] == industry_id
    assert detail["name"] == "Auto-Created Retail"
    assert detail["business_count"] == 2
    assert "Auto-Created Retail" in detail["message"]
    assert "2 business" in detail["message"]

    # Industry row is still there.
    with Session(engine) as session:
        assert session.get(Industry, industry_id) is not None


def test_delete_nonexistent_industry_returns_404(client):
    """Missing IDs 404 — matches update_industry's not-found path."""
    resp = client.delete("/api/industries/does-not-exist")
    assert resp.status_code == 404
    assert resp.json()["detail"] == "Industry not found"


def test_create_industry_refuses_a_slug_an_active_industry_has(client, engine):
    with Session(engine) as s:
        s.add(Industry(id="energy", name="Energy - Utilities", short_name="utilities"))
        s.commit()
    for body in (
        {"name": "Energy Utilities", "short_name": "new"},
        {"name": "Power", "short_name": "UTILITIES"},
    ):
        resp = client.post("/api/industries", json=body)
        assert resp.status_code == 409, resp.text
        detail = resp.json()["detail"]
        assert detail["error"] == "industry_slug_taken"
        assert detail["industries"] == [{"id": "energy", "name": "Energy - Utilities"}]
    with Session(engine) as s:
        assert [i.id for i in s.exec(select(Industry)).all()] == ["energy"]


def test_create_industry_allows_a_distinct_or_inactive_slug(client, engine):
    with Session(engine) as s:
        s.add(Industry(id="energy", name="Energy - Utilities", short_name="utilities"))
        s.add(Industry(id="old", name="Mining", short_name="mining", is_active=False))
        s.commit()
    assert client.post("/api/industries", json={"name": "Mining", "short_name": "mining"}).status_code == 200
    assert client.post(
        "/api/industries", json={"name": "Utilities", "short_name": "utilities-2", "is_active": False},
    ).status_code == 200
