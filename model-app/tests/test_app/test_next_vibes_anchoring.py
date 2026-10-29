"""Prose-target anchoring for next-vibe findings (an internal tracker item).

The parser only anchors dotted ``domain.product`` tokens; findings that name
their element in prose used to go model-wide. ``materialize_next_vibe_inputs``
now name-matches the prose against the version's (domain, product) pairs and
flags the inferred anchor ``needs_link_review`` for a human to confirm.
"""

from __future__ import annotations

import os
import sys

from sqlmodel import Session, select

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "..", "src", "app", "src"))

from vibe_modeling.backend.db_models import (
    Business,
    Domain,
    ModelVersion,
    Product,
    VibeInputContextLink,
)
from vibe_modeling.backend.model_sync import (
    ModelSyncService,
    _extract_name_tokens,
    _match_target_by_name,
)


# ---------------------------------------------------------------------------
# Pure matcher unit tests
# ---------------------------------------------------------------------------

class TestExtractNameTokens:
    def test_quoted_tokens(self):
        assert _extract_name_tokens("Domain 'procurement' has 'purchase_order'") == {
            "procurement", "purchase_order",
        }

    def test_snake_tokens(self):
        assert "order_line" in _extract_name_tokens("the order_line table drifts")

    def test_bare_common_word_not_a_token(self):
        # "order" unquoted and not underscore-shaped → not a candidate.
        assert _extract_name_tokens("the order was processed late") == set()

    def test_quoted_bare_word_is_a_token(self):
        assert _extract_name_tokens("'order' lacks a primary key") == {"order"}


class TestMatchTargetByName:
    PAIRS = [
        ("procurement", "purchase_order"),
        ("procurement", "procurement_purchase_order"),
        ("sales", "order"),
    ]
    DOMAINS = {"procurement", "sales"}

    def test_single_product_match_is_product_level(self):
        assert _match_target_by_name(
            self.PAIRS, self.DOMAINS, "'purchase_order' is denormalized"
        ) == "procurement.purchase_order"

    def test_duplicate_product_pair_degrades_to_domain(self):
        detail = ("Domain 'procurement' has both 'purchase_order' and "
                  "'procurement_purchase_order'")
        assert _match_target_by_name(self.PAIRS, self.DOMAINS, detail) == "procurement"

    def test_bare_english_word_does_not_match_product(self):
        # A product literally named `order` is not matched by unquoted prose.
        assert _match_target_by_name(self.PAIRS, self.DOMAINS, "process the order now") == ""

    def test_quoted_word_matches_product(self):
        assert _match_target_by_name(
            self.PAIRS, self.DOMAINS, "'order' needs a PK"
        ) == "sales.order"

    def test_non_unique_product_name_stays_model_wide(self):
        pairs = [("sales", "customer"), ("crm", "customer")]
        # Two domains own a product named 'customer'; no domain token → ambiguous.
        assert _match_target_by_name(pairs, {"sales", "crm"}, "'customer' is stale") == ""

    def test_no_tokens_is_model_wide(self):
        assert _match_target_by_name(self.PAIRS, self.DOMAINS, "generic advice") == ""


# ---------------------------------------------------------------------------
# Integration through materialize_next_vibe_inputs
# ---------------------------------------------------------------------------

MODEL = {"domains": [
    {"name": "procurement", "division": "", "description": "", "database_name": "",
     "references": "", "products": [
        {"product": "purchase_order", "primary_key": "id", "attributes": []},
        {"product": "procurement_purchase_order", "primary_key": "id", "attributes": []},
     ]},
    {"name": "sales", "division": "", "description": "", "database_name": "",
     "references": "", "products": [
        {"product": "order", "primary_key": "id", "attributes": []},
     ]},
]}


def _finding(ordinal, description, target=""):
    return {
        "ordinal": ordinal,
        "category": "static_analysis",
        "priority": "low",
        "title": "Static analysis: duplicate_product_pair",
        "description": description,
        "target": target,
        "quality_score": 0.5,
    }


def _payload(*findings):
    return {"_next_vibe_metadata": {"findings": list(findings)}}


def _seed_version(session, model=MODEL, business_name="Anchor Corp"):
    b = Business(name=business_name)
    session.add(b)
    session.flush()
    mv = ModelVersion(business_id=b.id, version=1, status="completed", scope="ecm")
    session.add(mv)
    session.flush()
    ModelSyncService(session).sync_from_model_json(mv.id, model)
    session.flush()
    return b.id, mv.id


class TestMaterializeAnchoring:
    def test_duplicate_product_pair_anchors_domain_with_review(self, engine):
        with Session(engine) as session:
            biz_id, vid = _seed_version(session)
            proc = session.exec(
                select(Domain).where(Domain.version_id == vid, Domain.name == "procurement")
            ).one()
            payload = _payload(_finding(
                1, "Domain 'procurement' has both 'purchase_order' and "
                   "'procurement_purchase_order'"))
            ModelSyncService(session).materialize_next_vibe_inputs(vid, biz_id, payload)
            session.commit()

            link = session.exec(
                select(VibeInputContextLink).where(
                    VibeInputContextLink.version_id == vid
                )
            ).one()
            assert link.domain_id == proc.id
            assert link.product_id is None
            assert link.needs_link_review is True

    def test_single_product_anchors_product_with_review(self, engine):
        with Session(engine) as session:
            biz_id, vid = _seed_version(session)
            prod = session.exec(
                select(Product).where(Product.version_id == vid, Product.name == "purchase_order")
            ).one()
            payload = _payload(_finding(1, "'purchase_order' is denormalized"))
            ModelSyncService(session).materialize_next_vibe_inputs(vid, biz_id, payload)
            session.commit()
            link = session.exec(
                select(VibeInputContextLink).where(VibeInputContextLink.version_id == vid)
            ).one()
            assert link.product_id == prod.id
            assert link.needs_link_review is True

    def test_no_match_stays_model_wide_unflagged(self, engine):
        with Session(engine) as session:
            biz_id, vid = _seed_version(session)
            payload = _payload(_finding(1, "process the order carefully"))
            ModelSyncService(session).materialize_next_vibe_inputs(vid, biz_id, payload)
            session.commit()
            link = session.exec(
                select(VibeInputContextLink).where(VibeInputContextLink.version_id == vid)
            ).one()
            assert link.domain_id is None
            assert link.product_id is None
            assert link.needs_link_review is False

    def test_dotted_target_unchanged_and_unflagged(self, engine):
        with Session(engine) as session:
            biz_id, vid = _seed_version(session)
            proc = session.exec(
                select(Domain).where(Domain.version_id == vid, Domain.name == "procurement")
            ).one()
            prod = session.exec(
                select(Product).where(Product.version_id == vid, Product.name == "purchase_order")
            ).one()
            # A dotted target resolves via the canonical path, keeping the
            # resolver's needs_link_review (False for a clean resolution).
            payload = _payload(_finding(
                1, "anything", target="procurement.purchase_order"))
            ModelSyncService(session).materialize_next_vibe_inputs(vid, biz_id, payload)
            session.commit()
            link = session.exec(
                select(VibeInputContextLink).where(VibeInputContextLink.version_id == vid)
            ).one()
            assert link.domain_id == proc.id
            assert link.product_id == prod.id
            assert link.needs_link_review is False

    def test_column_level_target_anchors_at_product(self, engine):
        """A ``domain.product.column`` target resolves at the product; the
        column segment is accepted and ignored (no attribute anchor)."""
        with Session(engine) as session:
            biz_id, vid = _seed_version(session)
            prod = session.exec(
                select(Product).where(Product.version_id == vid, Product.name == "purchase_order")
            ).one()
            payload = _payload(_finding(
                1, "anything", target="procurement.purchase_order.id"))
            ModelSyncService(session).materialize_next_vibe_inputs(vid, biz_id, payload)
            session.commit()
            link = session.exec(
                select(VibeInputContextLink).where(VibeInputContextLink.version_id == vid)
            ).one()
            assert link.product_id == prod.id
            assert link.attribute_id is None

    def test_bare_domain_target_resolves_domain_unflagged(self, engine):
        """A PRIORITY directive's bare (dotless) target keeps the old
        domain-level resolution and is NOT treated as prose inference."""
        with Session(engine) as session:
            biz_id, vid = _seed_version(session)
            proc = session.exec(
                select(Domain).where(Domain.version_id == vid, Domain.name == "procurement")
            ).one()
            # Explicit bare target "procurement"; description prose is generic.
            payload = _payload(_finding(1, "add a primary key", target="procurement"))
            ModelSyncService(session).materialize_next_vibe_inputs(vid, biz_id, payload)
            session.commit()
            link = session.exec(
                select(VibeInputContextLink).where(VibeInputContextLink.version_id == vid)
            ).one()
            assert link.domain_id == proc.id
            assert link.product_id is None
            # Explicit target → resolver's own value (clean resolution → False),
            # NOT the prose-inferred review flag.
            assert link.needs_link_review is False

    def test_element_load_happens_once_per_call(self, engine):
        with Session(engine) as session:
            biz_id, vid = _seed_version(session)
            svc = ModelSyncService(session)
            calls = {"n": 0}
            orig = svc._load_version_elements

            def wrapped(version_id):
                calls["n"] += 1
                return orig(version_id)

            svc._load_version_elements = wrapped  # type: ignore[method-assign]
            payload = _payload(
                _finding(1, "'purchase_order' drifts"),
                _finding(2, "'order' drifts"),
                _finding(3, "generic note"),
            )
            svc.materialize_next_vibe_inputs(vid, biz_id, payload)
            assert calls["n"] == 1


# ---------------------------------------------------------------------------
# Query-count regression: the whole call must be O(1) round trips, not
# O(findings) (a session.get dedup check + a session.get link check + a
# domain/product resolve query per finding).
# ---------------------------------------------------------------------------

def _count_statements(engine, fn):
    """Run ``fn()`` and count DB statements ``engine`` executes meanwhile.

    An ``executemany`` batch (the bulk multi-row INSERT this module's
    materialize path uses) fires exactly one ``before_cursor_execute`` event
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


def _make_next_vibes_payload(n: int) -> dict:
    """Build a payload of ``n`` findings, alternating between two dotted
    targets so each finding forces a real domain/product resolution (not the
    cheap intended-model-wide short-circuit)."""
    targets = ["procurement.purchase_order", "sales.order"]
    findings = [
        _finding(i + 1, "anything", target=targets[i % len(targets)])
        for i in range(n)
    ]
    return _payload(*findings)


def _materialize_with_n_findings(engine, n: int) -> int:
    """Seed a fresh version, materialize ``n`` next-vibe findings against it,
    and return the statement count the materialize call issues."""
    with Session(engine) as session:
        biz_id, vid = _seed_version(session, business_name=f"Anchor Corp {n}")
        session.commit()

    with Session(engine) as session:
        svc = ModelSyncService(session)
        payload = _make_next_vibes_payload(n)
        count = _count_statements(
            engine, lambda: svc.materialize_next_vibe_inputs(vid, biz_id, payload)
        )
        session.commit()
    return count


class TestMaterializeQueryCount:
    def test_query_count_is_bounded_not_per_finding(self, engine):
        """Materializing N next-vibe findings must issue the same number of
        statements regardless of N - a small constant (the existing-id dedup
        select, the AnchorMaps prefetch selects, and the two bulk inserts),
        not O(N). A regression back to a per-finding
        session.get-dedup/resolve/insert loop would show up here as growth
        between the 1-finding and 8-finding runs.
        """
        count_1 = _materialize_with_n_findings(engine, 1)
        count_8 = _materialize_with_n_findings(engine, 8)
        assert count_8 == count_1, (
            f"materialize statement count grew with finding count: "
            f"{count_1} -> {count_8} (should stay O(1), not O(findings))"
        )
