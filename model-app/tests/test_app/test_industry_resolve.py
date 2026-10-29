"""Backend half of the industry resolution contract
(``tests/fixtures/industry_slug_fixture.json``; the UI half is
``ui/__tests__/industry-resolve-parity.test.ts``): ``industry_resolve`` and the
frozen slug of the ``v_0_9_0_1`` migration give the fixture's slugs, and
``pick_industry`` / ``resolve_industry`` its matches. ``createBusiness`` and
``updateBusiness`` resolve through it."""

from __future__ import annotations

import json
from pathlib import Path
from types import SimpleNamespace

import pytest
from sqlmodel import Session, select

from vibe_modeling.backend.db_models import Business, Industry
from vibe_modeling.backend.industry_resolve import (
    industry_candidates,
    industry_slug,
    matching_industries,
    pick_industry,
    resolve_industry,
    resolve_industry_id,
)
from vibe_modeling.backend.migrations.v_0_9_0_1 import _frozen_industry_slug

FIXTURE = json.loads(
    (Path(__file__).resolve().parents[1] / "fixtures" / "industry_slug_fixture.json").read_text()
)
SLUGS = [tuple(c) for c in FIXTURE["slugs"]]
RESOLVE = [tuple(c) for c in FIXTURE["resolve"]]
CANDIDATES = [tuple(c) for c in FIXTURE["candidates"]]


@pytest.mark.parametrize(("text", "slug"), SLUGS)
def test_slug_matches_the_fixture(text, slug):
    assert industry_slug(text) == slug


@pytest.mark.parametrize(("text", "slug"), SLUGS)
def test_the_migration_frozen_slug_agrees(text, slug):
    assert _frozen_industry_slug(text) == slug


def test_none_slugs_to_empty():
    assert industry_slug(None) == ""


@pytest.mark.parametrize(("text", "expected"), RESOLVE)
def test_pick_industry_matches_the_fixture(text, expected):
    rows = [SimpleNamespace(**r) for r in FIXTURE["industries"]]
    picked = pick_industry(rows, text)
    assert (picked.id if picked else None) == expected


@pytest.mark.parametrize(("text", "ids"), CANDIDATES)
def test_matching_industries_matches_the_fixture(text, ids):
    rows = [SimpleNamespace(**r) for r in FIXTURE["industries"]]
    assert [i.id for i in matching_industries(rows, text)] == ids


@pytest.fixture
def seeded(engine):
    with Session(engine) as s:
        for r in FIXTURE["industries"]:
            s.add(Industry(**r))
        s.commit()
    return engine


@pytest.mark.parametrize(("text", "expected"), RESOLVE)
def test_resolve_industry_over_the_table(seeded, text, expected):
    with Session(seeded) as s:
        found = resolve_industry(s, text)
        assert (found.id if found else None) == expected
        assert resolve_industry_id(s, text) == expected


@pytest.mark.parametrize(("text", "ids"), CANDIDATES)
def test_industry_candidates_over_the_table(seeded, text, ids):
    with Session(seeded) as s:
        assert sorted(i.id for i in industry_candidates(s, text)) == sorted(ids)


def test_resolve_industry_on_an_empty_catalog(engine):
    with Session(engine) as s:
        assert resolve_industry(s, "retail") is None


class TestBusinessRoutes:
    def test_create_resolves_by_slug(self, client, seeded):
        r = client.post("/api/businesses", json={
            "name": "Grid Co", "description": "x", "industry_alignment": "energy_utilities",
        })
        assert r.status_code == 200, r.text
        with Session(seeded) as s:
            assert s.get(Business, r.json()["id"]).industry_id == "ind-energy"

    def test_create_treats_wildcards_literally(self, client, seeded):
        r = client.post("/api/businesses", json={
            "name": "Shop Co", "description": "x", "industry_alignment": "retai_",
        })
        assert r.status_code == 200, r.text
        with Session(seeded) as s:
            biz = s.get(Business, r.json()["id"])
            assert biz.industry_id is None
            assert biz.industry_alignment == "retai_"
            assert len(s.exec(select(Industry)).all()) == len(FIXTURE["industries"])

    def test_update_resolves_by_slug(self, client, seeded):
        created = client.post("/api/businesses", json={"name": "Later Co", "description": "x"})
        assert created.status_code == 200, created.text
        biz_id = created.json()["id"]
        r = client.put(f"/api/businesses/{biz_id}", json={
            "name": "Later Co", "description": "x", "industry_alignment": "Apparel-Fashion",
        })
        assert r.status_code == 200, r.text
        with Session(seeded) as s:
            assert s.get(Business, biz_id).industry_id == "ind-apparel"
