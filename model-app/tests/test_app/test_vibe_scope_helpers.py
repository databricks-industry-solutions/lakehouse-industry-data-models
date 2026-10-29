"""Unit tests for core._vibe_scope scope validation and normalization.

Tests the pure, side-effect-free helpers in isolation using in-memory fixtures.
No database or router imports needed.
"""

import pytest
from sqlmodel import Session
from vibe_modeling.backend.core import _vibe_scope
from vibe_modeling.backend.db_models import Business, ModelVersion


class TestScopeKey:
    """scope_key() normalization: lowercase, keep only [a-z0-9]."""

    def test_basic_normalization(self):
        """Simple cases."""
        assert _vibe_scope.scope_key("Customer Service") == "customerservice"
        assert _vibe_scope.scope_key("meter_to_cash") == "metertocash"
        assert _vibe_scope.scope_key("Meter To Cash") == "metertocash"

    def test_punctuation_removed(self):
        """Special characters and punctuation stripped."""
        assert _vibe_scope.scope_key("Customer-Service") == "customerservice"
        assert _vibe_scope.scope_key("Customer.Service") == "customerservice"
        assert _vibe_scope.scope_key("Customer&Service") == "customerservice"
        assert _vibe_scope.scope_key("meter_to_cash_123") == "metertocash123"

    def test_spaces_removed(self):
        """Spaces treated like any other non-alphanumeric."""
        assert _vibe_scope.scope_key("  Foo Bar  ") == "foobar"
        assert _vibe_scope.scope_key("foo bar") == "foobar"

    def test_digits_preserved(self):
        """Digits are kept."""
        assert _vibe_scope.scope_key("Domain123") == "domain123"
        assert _vibe_scope.scope_key("7-eleven") == "7eleven"

    def test_empty_string(self):
        """Empty input returns empty."""
        assert _vibe_scope.scope_key("") == ""

    def test_only_special_chars(self):
        """Input with only special chars becomes empty."""
        assert _vibe_scope.scope_key("_-_.") == ""
        assert _vibe_scope.scope_key("!!!") == ""

    def test_parity_with_agent(self):
        """Verified against the 5.3.3 notebook examples."""
        # From the design guide "Entries" examples
        assert _vibe_scope.scope_key("Customer Service") == "customerservice"
        assert _vibe_scope.scope_key("meter_to_cash") == "metertocash"
        # Ensure similar names are NOT identical
        assert _vibe_scope.scope_key("customer") != _vibe_scope.scope_key("customer_service")


class TestResolveScopeDomains:
    """resolve_scope_domains() domain matching and suggestions."""

    def test_exact_normalized_match(self):
        """Request matches a base domain after normalization."""
        matched, unknown = _vibe_scope.resolve_scope_domains(
            requested=["meter_to_cash"],
            base_domain_names=["Meter To Cash", "Customer Service"],
        )
        assert matched == ["Meter To Cash"]
        assert unknown == []

    def test_multiple_matches_in_order(self):
        """Multiple requests, all matched, returned in request order."""
        matched, unknown = _vibe_scope.resolve_scope_domains(
            requested=["Customer Service", "meter_to_cash"],
            base_domain_names=["Meter To Cash", "Customer Service"],
        )
        assert matched == ["Customer Service", "Meter To Cash"]
        assert unknown == []

    def test_unknown_name_no_suggestions(self):
        """Request does not match any base domain."""
        matched, unknown = _vibe_scope.resolve_scope_domains(
            requested=["Unknown Domain"],
            base_domain_names=["Meter To Cash", "Customer Service"],
        )
        assert matched == []
        assert len(unknown) == 1
        assert unknown[0][0] == "Unknown Domain"
        # Suggestions should be empty or limited (depends on fuzzy match cutoff)

    def test_deduplication(self):
        """Duplicate normalized keys return unique canonical names."""
        matched, unknown = _vibe_scope.resolve_scope_domains(
            requested=["meter_to_cash", "Meter To Cash", "METER_TO_CASH"],
            base_domain_names=["Meter To Cash"],
        )
        # All three requests normalize to the same domain, but only one is returned.
        assert matched == ["Meter To Cash"]
        assert unknown == []

    def test_partial_match(self):
        """Some requests match, some don't."""
        matched, unknown = _vibe_scope.resolve_scope_domains(
            requested=["meter_to_cash", "Unknown"],
            base_domain_names=["Meter To Cash", "Customer Service"],
        )
        assert matched == ["Meter To Cash"]
        assert len(unknown) == 1
        assert unknown[0][0] == "Unknown"

    def test_suggestions_fuzzy_match(self):
        """Unknown name gets suggestions from fuzzy matching."""
        matched, unknown = _vibe_scope.resolve_scope_domains(
            requested=["meter2cash"],  # Close to "metertocash"
            base_domain_names=["Meter To Cash"],
        )
        assert matched == []
        assert len(unknown) == 1
        req_name, suggestions = unknown[0]
        assert req_name == "meter2cash"
        # Should suggest "Meter To Cash" (high fuzzy match on "metertocash")
        assert len(suggestions) > 0

    def test_suggestions_substring_match(self):
        """Unknown name gets suggestions including substring matches."""
        matched, unknown = _vibe_scope.resolve_scope_domains(
            requested=["meter"],  # Substring of "metertocash"
            base_domain_names=["Meter To Cash"],
        )
        assert matched == []
        assert len(unknown) == 1
        req_name, suggestions = unknown[0]
        assert req_name == "meter"
        # Should suggest "Meter To Cash" (substring match on "metertocash")
        assert len(suggestions) > 0

    def test_empty_requested_list(self):
        """Empty request list returns empty matched list."""
        matched, unknown = _vibe_scope.resolve_scope_domains(
            requested=[],
            base_domain_names=["Meter To Cash", "Customer Service"],
        )
        assert matched == []
        assert unknown == []

    def test_empty_base_list(self):
        """Empty base list means no matches possible."""
        matched, unknown = _vibe_scope.resolve_scope_domains(
            requested=["meter_to_cash"],
            base_domain_names=[],
        )
        assert matched == []
        assert len(unknown) == 1
        assert unknown[0][0] == "meter_to_cash"

    def test_suggestions_limit(self):
        """Suggestions are limited to ~3 items (or fewer if not available)."""
        matched, unknown = _vibe_scope.resolve_scope_domains(
            requested=["x"],
            base_domain_names=["Meter To Cash", "Customer Service", "Finance", "HR", "IT"],
        )
        assert matched == []
        assert len(unknown) == 1
        req_name, suggestions = unknown[0]
        # Suggestions should be at most 3
        assert len(suggestions) <= 3


class TestConstants:
    """Widget labels and constants."""

    def test_vibe_scope_labels(self):
        """Widget labels exist and have expected values."""
        assert _vibe_scope.VIBE_SCOPE_WIDGET_LABELS["all_domains"] == "All Domains"
        assert _vibe_scope.VIBE_SCOPE_WIDGET_LABELS["some_domains"] == "Some Domains"
        assert _vibe_scope.VIBE_SCOPE_WIDGET_LABELS["some_subdomains"] == "Some Subdomains"

    def test_run_type_labels(self):
        """Run type constants."""
        assert _vibe_scope.RUN_TYPE_FULL == "Full Run"
        assert _vibe_scope.RUN_TYPE_DRY == "Dry Run"

    def test_min_agent_marker_for_scope(self):
        """Minimum agent marker for scope support."""
        assert _vibe_scope.MIN_AGENT_MARKER_FOR_SCOPE == "5.3.3"


class TestScopedBaseBlocker:
    """scoped_base_blocker() head validation per design §5.3 and §16.6.

    The head is: max(version) over ModelVersion(business_id, scope=base.scope,
    status in {"completed", "superseded"}). Excludes drafts and failed.
    The base is valid when: status == "completed" AND version == head version.
    """

    def _seed_business(self, session) -> str:
        """Create a test business and return its ID."""
        biz = Business(name="Test Business", description="Test")
        session.add(biz)
        session.commit()
        session.refresh(biz)
        return biz.id

    def _seed_version(
        self, session, business_id: str, version: int, scope: str = "ecm",
        status: str = "completed"
    ) -> ModelVersion:
        """Create a test ModelVersion and return it."""
        mv = ModelVersion(
            business_id=business_id,
            version=version,
            scope=scope,
            status=status,
            uc_catalog="test_catalog",
        )
        session.add(mv)
        session.commit()
        session.refresh(mv)
        return mv

    def test_base_is_head_completed(self, engine):
        """Base is the head and has status='completed' → None (valid)."""
        with Session(engine) as session:
            bid = self._seed_business(session)
            base = self._seed_version(session, bid, version=5, status="completed")

            blocker = _vibe_scope.scoped_base_blocker(session, base)
            assert blocker is None

    def test_base_behind_head(self, engine):
        """Base is behind the head → blocker message naming both versions."""
        with Session(engine) as session:
            bid = self._seed_business(session)
            base = self._seed_version(session, bid, version=5, status="completed")
            head = self._seed_version(session, bid, version=7, status="completed")

            blocker = _vibe_scope.scoped_base_blocker(session, base)
            assert blocker is not None
            assert "v5" in blocker
            assert "v7" in blocker
            assert "behind" in blocker.lower()

    def test_base_is_draft(self, engine):
        """Base is a draft → blocker with 'Dry Run draft' message."""
        with Session(engine) as session:
            bid = self._seed_business(session)
            head = self._seed_version(session, bid, version=5, status="completed")
            base_draft = self._seed_version(session, bid, version=6, status="draft")

            blocker = _vibe_scope.scoped_base_blocker(session, base_draft)
            assert blocker is not None
            assert "Dry Run draft" in blocker
            assert "v6" in blocker
            assert "v5" in blocker

    def test_draft_with_higher_number_ignored(self, engine):
        """A draft with version > base is ignored when computing head."""
        with Session(engine) as session:
            bid = self._seed_business(session)
            # v5 completed is the actual head
            base = self._seed_version(session, bid, version=5, status="completed")
            # v6 draft exists but should be ignored
            self._seed_version(session, bid, version=6, status="draft")

            blocker = _vibe_scope.scoped_base_blocker(session, base)
            # Base is the head of completed/superseded versions, so valid
            assert blocker is None

    def test_another_scope_ignored(self, engine):
        """Another scope's higher version is ignored when computing head."""
        with Session(engine) as session:
            bid = self._seed_business(session)
            # v5 ecm completed is the head for ecm scope
            base = self._seed_version(session, bid, version=5, scope="ecm", status="completed")
            # v10 mvm completed exists but is in a different scope
            self._seed_version(session, bid, version=10, scope="mvm", status="completed")

            blocker = _vibe_scope.scoped_base_blocker(session, base)
            # Base is the head of its own scope, so valid
            assert blocker is None

    def test_empty_business_no_head(self, engine):
        """An empty business with no completed versions → blocker."""
        with Session(engine) as session:
            bid = self._seed_business(session)
            # Only a draft version exists, no completed version
            base_draft = self._seed_version(session, bid, version=1, status="draft")

            blocker = _vibe_scope.scoped_base_blocker(session, base_draft)
            assert blocker is not None
            assert "No completed version" in blocker or "draft" in blocker.lower()

    def test_superseded_base_not_valid(self, engine):
        """A superseded base is not valid (must be status='completed')."""
        with Session(engine) as session:
            bid = self._seed_business(session)
            # v5 completed is the head
            head = self._seed_version(session, bid, version=5, status="completed")
            # v4 superseded exists
            base_superseded = self._seed_version(session, bid, version=4, status="superseded")

            blocker = _vibe_scope.scoped_base_blocker(session, base_superseded)
            assert blocker is not None
            assert "no longer the latest version" in blocker
            assert "v4" in blocker
            assert "v5" in blocker

    def test_superseded_is_head_still_invalid(self, engine):
        """Even if a superseded version is the highest, base must be 'completed'."""
        with Session(engine) as session:
            bid = self._seed_business(session)
            # v5 superseded is the highest completed/superseded version
            base_superseded = self._seed_version(session, bid, version=5, status="superseded")

            blocker = _vibe_scope.scoped_base_blocker(session, base_superseded)
            assert blocker is not None
            assert blocker.startswith(
                "v5 is marked superseded and can't be used as a scoped base."
            )
            assert "no longer the latest" not in blocker

    def test_superseded_top_row_after_newer_deleted(self, engine):
        """v3 was superseded by v4, then v4 was deleted: v3 is the top row but
        still superseded. The message names only v3 and never claims another
        latest version (no "v3 is no longer the latest (v3 is)")."""
        with Session(engine) as session:
            bid = self._seed_business(session)
            self._seed_version(session, bid, version=2, status="superseded")
            v3 = self._seed_version(session, bid, version=3, status="superseded")

            blocker = _vibe_scope.scoped_base_blocker(session, v3)
            assert blocker == (
                "v3 is marked superseded and can't be used as a scoped base. "
                "Scoped runs must start from a completed version."
            )

    def test_multiple_completed_latest_is_head(self, engine):
        """Among multiple completed versions, the highest is the head."""
        with Session(engine) as session:
            bid = self._seed_business(session)
            v1 = self._seed_version(session, bid, version=1, status="completed")
            v3 = self._seed_version(session, bid, version=3, status="completed")
            v2 = self._seed_version(session, bid, version=2, status="completed")

            # v3 is the head
            blocker = _vibe_scope.scoped_base_blocker(session, v3)
            assert blocker is None

            # v2 is behind
            blocker = _vibe_scope.scoped_base_blocker(session, v2)
            assert blocker is not None
            assert "v2" in blocker
            assert "v3" in blocker


def test_run_scope_domains_reads_the_mode_and_the_list():
    from enum import Enum

    from vibe_modeling.backend.core._vibe_scope import run_scope_domains

    class Mode(str, Enum):
        SOME = "some_domains"
        ALL = "all_domains"

    assert run_scope_domains("all_domains", ["Sales"]) == []
    assert run_scope_domains(None, ["Sales"]) == []
    assert run_scope_domains(Mode.ALL, ["Sales"]) == []
    assert run_scope_domains("some_domains", ["Sales", "Billing"]) == ["Sales", "Billing"]
    assert run_scope_domains(Mode.SOME, None) == []
