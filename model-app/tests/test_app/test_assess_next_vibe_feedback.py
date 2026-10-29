"""Tests for assessment next-vibe to feedback conversion endpoints."""
from __future__ import annotations

import os
import sys
from types import SimpleNamespace as NS

import pytest
from datetime import datetime, timezone
from sqlmodel import Session, select

from _test_app import make_test_app
from vibe_modeling.backend.db_models import (
    AssessBatch,
    AssessDomainRun,
    AssessNextVibe,
    AssessNextVibeEntity,
    Business,
    Domain,
    ModelVersion,
    Product,
    VibeInput,
    VibeInputContextLink,
)
from vibe_modeling.backend.models import VibeInputStatus, VibeInputOrigin

# For shared fixtures
sys.path.insert(0, os.path.dirname(__file__))

WHO = {"X-Forwarded-Email": "test@example.com"}


@pytest.fixture
def assess_next_vibe_data(engine):
    """Set up a domain run with next vibes for testing."""
    with Session(engine) as session:
        business = Business(name="Test Corp", description="A test company", industry_alignment="Retail")
        session.add(business)
        session.commit()
        session.refresh(business)

        model_version = ModelVersion(
            business_id=business.id,
            version=1,
            status="completed",
            scope="test",
            deployment_status="deployed",
            uc_catalog="test_catalog",
        )
        session.add(model_version)
        session.commit()
        session.refresh(model_version)

        domain = Domain(
            version_id=model_version.id,
            name="Test Domain",
            database_name="test_domain"
        )
        session.add(domain)
        session.commit()
        session.refresh(domain)

        product = Product(
            domain_id=domain.id,
            version_id=model_version.id,
            name="Test Product",
            table_name="test_product"
        )
        session.add(product)
        session.commit()
        session.refresh(product)

        batch = AssessBatch(
            business_id=business.id,
            version_id=model_version.id,
            scope="test",
            created_at=datetime.now(timezone.utc),
            updated_at=datetime.now(timezone.utc),
        )
        session.add(batch)
        session.commit()
        session.refresh(batch)

        dr = AssessDomainRun(
            batch_id=batch.id,
            domain_id=domain.id,
            out_dir="/test/out",
            status="completed",
            created_at=datetime.now(timezone.utc),
        )
        session.add(dr)
        session.commit()
        session.refresh(dr)

        nv1 = AssessNextVibe(
            domain_run_id=dr.id,
            ordinal=0,
            priority=1,
            category="",
            text="Fix indexing performance",
            confidence=0.9,
            problem="Slow queries on large tables",
            proposed_change="Add composite index on (id, created_at)",
            impact_if_skipped="Query timeouts in production",
            urgency="before_build",
        )
        session.add(nv1)
        session.commit()
        session.refresh(nv1)

        ent1 = AssessNextVibeEntity(next_vibe_id=nv1.id, ordinal=0, entity="Test Product")
        session.add(ent1)

        nv2 = AssessNextVibe(
            domain_run_id=dr.id,
            ordinal=1,
            priority=2,
            category="",
            text="Add data quality checks",
            confidence=0.8,
            problem="",
            proposed_change="Implement validation rules",
            impact_if_skipped="",
            urgency="during_build",
        )
        session.add(nv2)
        session.commit()
        session.refresh(nv2)

        ent2 = AssessNextVibeEntity(next_vibe_id=nv2.id, ordinal=0, entity="Test Product")
        session.add(ent2)

        nv3 = AssessNextVibe(
            domain_run_id=dr.id,
            ordinal=2,
            priority=3,
            category="",
            text="Consider denormalization",
            confidence=0.7,
            problem="",
            proposed_change="",
            impact_if_skipped="",
            urgency="later",
        )
        session.add(nv3)
        session.commit()
        session.refresh(nv3)

        session.commit()
        return NS(
            business_id=business.id,
            model_version_id=model_version.id,
            domain_id=domain.id,
            product_id=product.id,
            batch_id=batch.id,
            dr_id=dr.id,
            vibe_ids=[nv1.id, nv2.id, nv3.id],
        )


class TestAddNextVibeToFeedback:
    """Test single next-vibe to feedback conversion."""

    def test_create_feedback_from_vibe_idempotent(self, client, assess_next_vibe_data):
        """Adding the same vibe twice returns the same VibeInput (idempotent)."""
        dr_id = assess_next_vibe_data.dr_id
        vibe_id = assess_next_vibe_data.vibe_ids[0]

        # First add
        response1 = client.post(
            f"/api/assessment-domain-runs/{dr_id}/next-vibes/{vibe_id}/feedback",
            json={},
            headers=WHO,
        )
        assert response1.status_code == 200
        data1 = response1.json()
        assert data1["created"] is True
        feedback_id_1 = data1["feedback_input_id"]

        # Second add (same vibe)
        response2 = client.post(
            f"/api/assessment-domain-runs/{dr_id}/next-vibes/{vibe_id}/feedback",
            json={},
            headers=WHO,
        )
        assert response2.status_code == 200
        data2 = response2.json()
        assert data2["created"] is False
        assert data2["feedback_input_id"] == feedback_id_1

    def test_create_feedback_text_composition(self, client, engine, assess_next_vibe_data):
        """Verify text composition: problem + proposed_change + impact trailer + reference."""
        dr_id = assess_next_vibe_data.dr_id
        vibe_id = assess_next_vibe_data.vibe_ids[0]

        response = client.post(
            f"/api/assessment-domain-runs/{dr_id}/next-vibes/{vibe_id}/feedback",
            json={},
            headers=WHO,
        )
        assert response.status_code == 200
        data = response.json()

        with Session(engine) as session:
            vi = session.get(VibeInput, data["feedback_input_id"])
            assert vi is not None
            # Text should be: problem + " / " + proposed_change + "\n\nWhy it matters: " + impact + reference
            assert "Slow queries" in vi.text or "Fix indexing" in vi.text
            assert "composite index" in vi.text
            assert "Query timeouts" in vi.text
            assert "from assessment" in vi.text
            assert "Test Domain" in vi.text

    def test_create_feedback_fallback_to_text(self, client, engine, assess_next_vibe_data):
        """When problem/proposed_change/impact all empty, use text as-is."""
        dr_id = assess_next_vibe_data.dr_id
        vibe_id = assess_next_vibe_data.vibe_ids[2]  # vibe-3 has empty fields

        response = client.post(
            f"/api/assessment-domain-runs/{dr_id}/next-vibes/{vibe_id}/feedback",
            json={},
            headers=WHO,
        )
        assert response.status_code == 200
        data = response.json()

        with Session(engine) as session:
            vi = session.get(VibeInput, data["feedback_input_id"])
            assert vi is not None
            assert "Consider denormalization" in vi.text
            assert "from assessment" in vi.text

    def test_create_feedback_with_product_anchor(self, client, engine, assess_next_vibe_data):
        """When affected entity resolves to a product, anchor to that product."""
        dr_id = assess_next_vibe_data.dr_id
        vibe_id = assess_next_vibe_data.vibe_ids[0]
        product_id = assess_next_vibe_data.product_id

        response = client.post(
            f"/api/assessment-domain-runs/{dr_id}/next-vibes/{vibe_id}/feedback",
            json={},
            headers=WHO,
        )
        assert response.status_code == 200
        data = response.json()

        with Session(engine) as session:
            vi = session.get(VibeInput, data["feedback_input_id"])
            link = session.exec(
                select(VibeInputContextLink).where(VibeInputContextLink.input_id == vi.id)
            ).first()
            assert link is not None
            assert link.product_id == product_id

    def test_create_feedback_with_unresolvable_entity_marks_needs_review(
        self, client, engine, assess_next_vibe_data
    ):
        """When affected entity doesn't resolve, mark needs_link_review=True."""
        dr_id = assess_next_vibe_data.dr_id

        with Session(engine) as session:
            # Add a vibe with an unresolvable entity name
            nv = AssessNextVibe(
                domain_run_id=dr_id,
                ordinal=10,
                priority=5,
                category="",
                text="Unknown entity vibe",
                confidence=0.5,
                problem="Test",
                proposed_change="Test",
                impact_if_skipped="",
                urgency="later",
            )
            session.add(nv)
            session.commit()
            session.refresh(nv)
            vibe_id = nv.id

            ent = AssessNextVibeEntity(next_vibe_id=nv.id, ordinal=0, entity="NonexistentProduct")
            session.add(ent)
            session.commit()

        response = client.post(
            f"/api/assessment-domain-runs/{dr_id}/next-vibes/{vibe_id}/feedback",
            json={},
            headers=WHO,
        )
        assert response.status_code == 200
        data = response.json()

        with Session(engine) as session:
            vi = session.get(VibeInput, data["feedback_input_id"])
            if vi:
                link = session.exec(
                    select(VibeInputContextLink).where(VibeInputContextLink.input_id == vi.id)
                ).first()
                assert link is not None
                assert link.needs_link_review is True

    def test_deprecated_input_creates_new(self, client, engine, assess_next_vibe_data):
        """If vibe is linked to deprecated input, create a new one."""
        dr_id = assess_next_vibe_data.dr_id
        vibe_id = assess_next_vibe_data.vibe_ids[0]
        business_id = assess_next_vibe_data.business_id

        with Session(engine) as session:
            # Create a deprecated VibeInput
            deprecated_vi = VibeInput(
                business_id=business_id,
                origin=VibeInputOrigin.USER.value,
                author="test@example.com",
                text="Old feedback",
                priority="medium",
                confidence_score=0.5,
                status=VibeInputStatus.ACTIVE.value,
                deprecated_by="some-user",
            )
            session.add(deprecated_vi)
            session.commit()
            session.refresh(deprecated_vi)

            # Link vibe to deprecated input
            nv = session.get(AssessNextVibe, vibe_id)
            nv.vibe_input_id = deprecated_vi.id
            session.add(nv)
            session.commit()
            deprecated_id = deprecated_vi.id

        # Add to feedback (should create new)
        response = client.post(
            f"/api/assessment-domain-runs/{dr_id}/next-vibes/{vibe_id}/feedback",
            json={},
            headers=WHO,
        )
        assert response.status_code == 200
        data = response.json()
        assert data["created"] is True
        assert data["feedback_input_id"] != deprecated_id

    def test_404_vibe_not_found(self, client, assess_next_vibe_data):
        """404 when vibe not found."""
        dr_id = assess_next_vibe_data.dr_id
        response = client.post(
            f"/api/assessment-domain-runs/{dr_id}/next-vibes/nonexistent/feedback",
            json={},
            headers=WHO,
        )
        assert response.status_code == 404

    def test_404_domain_run_not_found(self, client):
        """404 when domain_run not found."""
        response = client.post(
            "/api/assessment-domain-runs/nonexistent/next-vibes/vibe-1/feedback",
            json={},
            headers=WHO,
        )
        assert response.status_code == 404

    def test_origin_user_and_author_from_header(self, client, engine, assess_next_vibe_data):
        """Verify origin is 'user' and author is from request header."""
        dr_id = assess_next_vibe_data.dr_id
        vibe_id = assess_next_vibe_data.vibe_ids[0]

        response = client.post(
            f"/api/assessment-domain-runs/{dr_id}/next-vibes/{vibe_id}/feedback",
            json={},
            headers=WHO,
        )
        assert response.status_code == 200

        with Session(engine) as session:
            vi = session.get(VibeInput, response.json()["feedback_input_id"])
            assert vi.origin == VibeInputOrigin.USER.value
            assert vi.author == "test@example.com"

    @pytest.mark.parametrize("headers, expected", [
        ({"X-Forwarded-Preferred-Username": "tess"}, "tess"),
        ({}, "anonymous"),
    ])
    def test_author_is_actor_label_without_email(self, client, engine, assess_next_vibe_data, headers, expected):
        dr_id = assess_next_vibe_data.dr_id
        vibe_id = assess_next_vibe_data.vibe_ids[0]
        response = client.post(
            f"/api/assessment-domain-runs/{dr_id}/next-vibes/{vibe_id}/feedback", json={}, headers=headers)
        assert response.status_code == 200, response.text
        with Session(engine) as session:
            assert session.get(VibeInput, response.json()["feedback_input_id"]).author == expected

    def test_domain_anchor_with_multiple_affected_entities(self, client, engine, assess_next_vibe_data):
        """When multiple affected entities both resolve, use domain anchor (conservative)."""
        dr_id = assess_next_vibe_data.dr_id
        domain_id = assess_next_vibe_data.domain_id

        with Session(engine) as session:
            # Create a second product in the same domain
            product2 = Product(
                domain_id=domain_id,
                version_id=assess_next_vibe_data.model_version_id,
                name="Other Product",
                table_name="other_product"
            )
            session.add(product2)
            session.commit()
            session.refresh(product2)

            # Create a vibe with multiple affected entities that both resolve
            nv = AssessNextVibe(
                domain_run_id=dr_id,
                ordinal=20,
                priority=1,
                category="",
                text="Multi-entity vibe",
                confidence=0.5,
                problem="Multiple products",
                proposed_change="Refactor",
                impact_if_skipped="",
                urgency="before_build",
            )
            session.add(nv)
            session.commit()
            session.refresh(nv)
            vibe_id = nv.id

            # Add two affected entities that both resolve to products
            ent1 = AssessNextVibeEntity(next_vibe_id=nv.id, ordinal=0, entity="Test Product")
            ent2 = AssessNextVibeEntity(next_vibe_id=nv.id, ordinal=1, entity="Other Product")
            session.add(ent1)
            session.add(ent2)
            session.commit()

        response = client.post(
            f"/api/assessment-domain-runs/{dr_id}/next-vibes/{vibe_id}/feedback",
            json={},
            headers=WHO,
        )
        assert response.status_code == 200

        with Session(engine) as session:
            vi = session.get(VibeInput, response.json()["feedback_input_id"])
            link = session.exec(
                select(VibeInputContextLink).where(VibeInputContextLink.input_id == vi.id)
            ).first()
            assert link is not None
            # Multiple entities resolve should fall back to domain anchor (conservative)
            assert link.domain_id == assess_next_vibe_data.domain_id
            assert link.product_id is None

    def test_feedback_input_id_null_when_deprecated(self, client, engine, assess_next_vibe_data):
        """NextVibeOut.feedback_input_id is null when linked input is deprecated."""
        dr_id = assess_next_vibe_data.dr_id
        vibe_id = assess_next_vibe_data.vibe_ids[0]
        business_id = assess_next_vibe_data.business_id

        # First, create a feedback input
        response1 = client.post(
            f"/api/assessment-domain-runs/{dr_id}/next-vibes/{vibe_id}/feedback",
            json={},
            headers=WHO,
        )
        assert response1.status_code == 200
        feedback_id = response1.json()["feedback_input_id"]

        # Deprecate the input
        with Session(engine) as session:
            vi = session.get(VibeInput, feedback_id)
            vi.deprecated_by = "some-user"
            session.add(vi)
            session.commit()

        # Fetch results and verify feedback_input_id is null
        response_results = client.get(
            f"/api/assessment-domain-runs/{dr_id}/results",
            headers=WHO,
        )
        assert response_results.status_code == 200
        data = response_results.json()
        next_vibes = data.get("next_vibes", [])
        vibe_in_results = next((v for v in next_vibes if v["id"] == vibe_id), None)
        assert vibe_in_results is not None
        assert vibe_in_results.get("feedback_input_id") is None

    def test_priority_maps_from_urgency(self, client, engine, assess_next_vibe_data):
        """Verify priority is mapped from urgency: before_build→high, during_build→medium, later→low."""
        dr_id = assess_next_vibe_data.dr_id

        # Test each urgency level
        urgency_priority_map = {
            "before_build": "high",
            "during_build": "medium",
            "later": "low",
        }

        for idx, (urgency, expected_priority) in enumerate(urgency_priority_map.items()):
            # Find vibe with this urgency
            vibes = list(Session(engine).exec(
                select(AssessNextVibe).where(AssessNextVibe.domain_run_id == dr_id)
            ))
            vibe = next((v for v in vibes if v.urgency == urgency), None)
            if vibe:
                response = client.post(
                    f"/api/assessment-domain-runs/{dr_id}/next-vibes/{vibe.id}/feedback",
                    json={},
                    headers=WHO,
                )
                assert response.status_code == 200

                with Session(engine) as session:
                    vi = session.get(VibeInput, response.json()["feedback_input_id"])
                    assert vi.priority == expected_priority




class TestBulkAddNextVibesToFeedback:
    """Test bulk next-vibes to feedback conversion."""

    def test_bulk_by_urgency_before_build(self, client, assess_next_vibe_data):
        """Bulk convert all before_build vibes."""
        dr_id = assess_next_vibe_data.dr_id

        response = client.post(
            f"/api/assessment-domain-runs/{dr_id}/next-vibes/feedback/bulk",
            json={"urgency": "before_build"},
            headers=WHO,
        )
        assert response.status_code == 200
        data = response.json()
        assert data["count_created"] == 1  # vibe-1 is before_build
        assert data["count_reused"] == 0
        assert len(data["items"]) == 1

    def test_bulk_by_ids(self, client, assess_next_vibe_data):
        """Bulk convert specific vibes by ids."""
        dr_id = assess_next_vibe_data.dr_id
        vibe_ids = assess_next_vibe_data.vibe_ids[:2]

        response = client.post(
            f"/api/assessment-domain-runs/{dr_id}/next-vibes/feedback/bulk",
            json={"ids": vibe_ids},
            headers=WHO,
        )
        assert response.status_code == 200
        data = response.json()
        assert data["count_created"] == 2
        assert len(data["items"]) == 2

    def test_bulk_skips_linked_vibes(self, client, assess_next_vibe_data):
        """Bulk skips vibes already linked to active inputs."""
        dr_id = assess_next_vibe_data.dr_id
        vibe_id = assess_next_vibe_data.vibe_ids[0]

        # Pre-create a feedback for vibe-1
        first_response = client.post(
            f"/api/assessment-domain-runs/{dr_id}/next-vibes/{vibe_id}/feedback",
            json={},
            headers=WHO,
        )
        assert first_response.status_code == 200

        # Bulk by urgency
        response = client.post(
            f"/api/assessment-domain-runs/{dr_id}/next-vibes/feedback/bulk",
            json={"urgency": "before_build"},
            headers=WHO,
        )
        assert response.status_code == 200
        data = response.json()
        assert data["count_created"] == 0
        assert data["count_reused"] == 1

    def test_bulk_422_missing_urgency_and_ids(self, client, assess_next_vibe_data):
        """422 (validation error) when neither urgency nor ids provided."""
        dr_id = assess_next_vibe_data.dr_id

        response = client.post(
            f"/api/assessment-domain-runs/{dr_id}/next-vibes/feedback/bulk",
            json={},
            headers=WHO,
        )
        assert response.status_code == 422

    def test_bulk_422_bad_urgency(self, client, assess_next_vibe_data):
        """422 when urgency is invalid."""
        dr_id = assess_next_vibe_data.dr_id

        response = client.post(
            f"/api/assessment-domain-runs/{dr_id}/next-vibes/feedback/bulk",
            json={"urgency": "invalid"},
            headers=WHO,
        )
        assert response.status_code == 422

    def test_bulk_mixed_linked_and_unlinked(self, client, engine, assess_next_vibe_data):
        """Bulk with 1 linked + 2 unlinked before_build vibes: count_created=2, count_reused=1."""
        dr_id = assess_next_vibe_data.dr_id
        business_id = assess_next_vibe_data.business_id

        with Session(engine) as session:
            # Create 2 additional before_build vibes
            nv1 = AssessNextVibe(
                domain_run_id=dr_id,
                ordinal=30,
                priority=1,
                category="",
                text="Before build 1",
                confidence=0.8,
                problem="Test",
                proposed_change="Fix",
                impact_if_skipped="",
                urgency="before_build",
            )
            session.add(nv1)
            session.commit()
            session.refresh(nv1)

            nv2 = AssessNextVibe(
                domain_run_id=dr_id,
                ordinal=31,
                priority=1,
                category="",
                text="Before build 2",
                confidence=0.7,
                problem="Test",
                proposed_change="Fix",
                impact_if_skipped="",
                urgency="before_build",
            )
            session.add(nv2)
            session.commit()
            session.refresh(nv2)

            # Link one of them to an active input
            active_vi = VibeInput(
                business_id=business_id,
                origin=VibeInputOrigin.USER.value,
                author="test@example.com",
                text="Existing feedback",
                priority="medium",
                confidence_score=0.5,
            )
            session.add(active_vi)
            session.commit()
            session.refresh(active_vi)

            nv1.vibe_input_id = active_vi.id
            session.add(nv1)
            session.commit()

        # Bulk by before_build urgency
        response = client.post(
            f"/api/assessment-domain-runs/{dr_id}/next-vibes/feedback/bulk",
            json={"urgency": "before_build"},
            headers=WHO,
        )
        assert response.status_code == 200
        data = response.json()
        # 1 original before_build + 2 new ones = 1 linked + 2 created
        assert data["count_reused"] == 1
        assert data["count_created"] == 2
        assert len(data["items"]) == 3


class TestBulkAtomicity:
    """Test transaction semantics — bulk endpoint commits per item; a failed item rolls back alone."""

    def test_bulk_happy_path_links_all(self, client, engine, assess_next_vibe_data):
        """Bulk endpoint creates and links a VibeInput for every matching vibe.

        Before the call no VibeInputs exist; after it, every created item has a
        VibeInput and its AssessNextVibe carries the vibe_input_id.
        """
        dr_id = assess_next_vibe_data.dr_id

        with Session(engine) as session:
            initial_vi_count = len(session.exec(select(VibeInput)).all())
            assert initial_vi_count == 0

        response = client.post(
            f"/api/assessment-domain-runs/{dr_id}/next-vibes/feedback/bulk",
            json={"urgency": "before_build"},
            headers=WHO,
        )
        assert response.status_code == 200

        with Session(engine) as session:
            data = response.json()
            expected_created = data["count_created"]

            nvs_linked = session.exec(
                select(AssessNextVibe).where(AssessNextVibe.vibe_input_id.isnot(None))
            ).all()
            assert len(nvs_linked) == expected_created

            vi_count = len(session.exec(select(VibeInput)).all())
            assert vi_count == expected_created

    def test_bulk_mid_loop_failure_keeps_the_other_items(
        self, client, engine, assess_next_vibe_data, monkeypatch
    ):
        """Each item commits on its own: a failure on the 2nd vibe (in id order) is reported in
        ``failures`` and rolls back only its own writes; the 1st vibe's item stays."""
        import vibe_modeling.backend.routes.assessments as assessments_routes

        dr_id = assess_next_vibe_data.dr_id

        # Fixture has only one before_build vibe; add a second so the loop
        # reaches a 2nd create call.
        with Session(engine) as session:
            extra = AssessNextVibe(
                domain_run_id=dr_id,
                ordinal=3,
                priority=1,
                category="",
                text="Partition the fact table",
                confidence=0.85,
                problem="Full scans on every query",
                proposed_change="Partition by event_date",
                impact_if_skipped="Cost grows linearly",
                urgency="before_build",
            )
            session.add(extra)
            session.commit()
            ids = sorted(nv.id for nv in session.exec(
                select(AssessNextVibe).where(
                    AssessNextVibe.domain_run_id == dr_id,
                    AssessNextVibe.urgency == "before_build",
                    AssessNextVibe.vibe_input_id.is_(None),
                )
            ).all())
            assert len(ids) == 2

        real_create = assessments_routes.create_vibe_input_with_anchor
        calls = {"n": 0}

        def flaky_create(*args, **kwargs):
            calls["n"] += 1
            vi = real_create(*args, **kwargs)
            if calls["n"] == 2:
                raise RuntimeError("boom")
            return vi

        monkeypatch.setattr(
            assessments_routes, "create_vibe_input_with_anchor", flaky_create
        )

        r = client.post(
            f"/api/assessment-domain-runs/{dr_id}/next-vibes/feedback/bulk",
            json={"urgency": "before_build"},
            headers=WHO,
        )
        assert r.status_code == 200, r.text
        body = r.json()
        assert calls["n"] == 2
        assert body["count_created"] == 1 and [i["next_vibe_id"] for i in body["items"]] == [ids[0]]
        assert body["failures"] == [{"next_vibe_id": ids[1], "message": "Couldn't add this next vibe to feedback: boom. Please contact your administrator with these details."}]

        with Session(engine) as session:
            vis = session.exec(select(VibeInput)).all()
            assert len(vis) == 1
            assert [link.input_id for link in session.exec(select(VibeInputContextLink))] == [vis[0].id]
            assert session.get(AssessNextVibe, ids[0]).vibe_input_id == vis[0].id
            assert session.get(AssessNextVibe, ids[1]).vibe_input_id is None


class TestCreateVibeInputBehaviorUnchanged:
    """Verify that refactoring create_vibe_input didn't change its behavior."""

    def test_create_vibe_input_still_works(self, client, assess_next_vibe_data):
        """The create_vibe_input endpoint should work identically after refactoring."""
        business_id = assess_next_vibe_data.business_id
        model_version_id = assess_next_vibe_data.model_version_id

        response = client.post(
            f"/api/businesses/{business_id}/inputs",
            json={
                "text": "Test feedback",
                "origin": "user",
                "priority": "medium",
                "confidence_score": 0.5,
                "version_id": model_version_id,
            },
            headers=WHO,
        )
        assert response.status_code == 200
        data = response.json()
        assert data["text"] == "Test feedback"
        assert data["origin"] == VibeInputOrigin.USER.value


class TestRbac:
    """Test RBAC guards on both feedback endpoints."""

    def test_single_endpoint_403_for_viewer(self, engine, mock_ws, config, mock_tracker, assess_next_vibe_data):
        """Single endpoint returns 403 for non-modeler (viewer) role."""
        from vibe_modeling.backend.core._roles import UserRole, resolve_user_role
        from vibe_modeling.backend.core._defaults import (
            _ConfigDependency,
            _WorkspaceClientDependency,
        )
        from vibe_modeling.backend.core._tracker import _TrackerDependency
        from vibe_modeling.backend.core.lakebase import _LakebaseDependency
        from fastapi.testclient import TestClient

        app = make_test_app()

        def override_session():
            with Session(engine) as session:
                yield session

        app.dependency_overrides[_LakebaseDependency.__call__] = override_session
        app.dependency_overrides[_ConfigDependency.__call__] = lambda: config
        app.dependency_overrides[_WorkspaceClientDependency.__call__] = lambda: mock_ws
        app.dependency_overrides[_TrackerDependency.__call__] = lambda: mock_tracker
        app.dependency_overrides[resolve_user_role] = lambda: UserRole.VIEWER

        client = TestClient(app)
        dr_id = assess_next_vibe_data.dr_id
        vibe_id = assess_next_vibe_data.vibe_ids[0]

        response = client.post(
            f"/api/assessment-domain-runs/{dr_id}/next-vibes/{vibe_id}/feedback",
            json={},
            headers=WHO,
        )
        assert response.status_code == 403

    def test_bulk_endpoint_403_for_viewer(self, engine, mock_ws, config, mock_tracker, assess_next_vibe_data):
        """Bulk endpoint returns 403 for non-modeler (viewer) role."""
        from vibe_modeling.backend.core._roles import UserRole, resolve_user_role
        from vibe_modeling.backend.core._defaults import (
            _ConfigDependency,
            _WorkspaceClientDependency,
        )
        from vibe_modeling.backend.core._tracker import _TrackerDependency
        from vibe_modeling.backend.core.lakebase import _LakebaseDependency
        from fastapi.testclient import TestClient

        app = make_test_app()

        def override_session():
            with Session(engine) as session:
                yield session

        app.dependency_overrides[_LakebaseDependency.__call__] = override_session
        app.dependency_overrides[_ConfigDependency.__call__] = lambda: config
        app.dependency_overrides[_WorkspaceClientDependency.__call__] = lambda: mock_ws
        app.dependency_overrides[_TrackerDependency.__call__] = lambda: mock_tracker
        app.dependency_overrides[resolve_user_role] = lambda: UserRole.VIEWER

        client = TestClient(app)
        dr_id = assess_next_vibe_data.dr_id

        response = client.post(
            f"/api/assessment-domain-runs/{dr_id}/next-vibes/feedback/bulk",
            json={"urgency": "before_build"},
            headers=WHO,
        )
        assert response.status_code == 403
