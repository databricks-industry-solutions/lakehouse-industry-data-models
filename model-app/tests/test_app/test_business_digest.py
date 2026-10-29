"""Unit coverage for ``business_digest.extract_business_digest`` and
``diff_business_digest``. No HTTP — pure-function semantics only."""

from __future__ import annotations

from vibe_modeling.backend.services.business_digest import (
    diff_business_digest,
    extract_business_digest,
)


class TestExtractBusinessDigest:
    def test_envelope_pulls_name_from_requirements_and_context_from_model(self):
        payload = {
            "model_requirements": {
                "business_name": "Gaming",
                "description": "A gaming reference business",
            },
            "model": {
                "type": "business",
                "name": "Gaming",
                "version": "v1_ecm",
                "industry_alignment": "Gaming",
                "core_business_processes": "matchmaking, monetization",
                "orgnaization_divisions": "studios, publishing",
                "common_business_jargons": "MAU, DAU",
                "operational_systems_of_records": "Steam, PlayFab",
                "industry_governing_body": "ESRB",
            },
        }
        digest = extract_business_digest(payload)
        assert digest is not None
        assert digest.business_name == "Gaming"
        assert digest.description == "A gaming reference business"
        assert digest.industry_alignment == "Gaming"
        assert digest.core_business_processes == "matchmaking, monetization"
        assert digest.orgnaization_divisions == "studios, publishing"
        assert digest.common_business_jargons == "MAU, DAU"
        assert digest.operational_systems_of_records == "Steam, PlayFab"
        assert digest.industry_governing_body == "ESRB"
        assert digest.industry_id is None

    def test_flat_payload_falls_back_to_model_name(self):
        """Hand-edited model.json files without the agent wrapper still
        have ``name`` at the top level — extract should find it."""
        payload = {
            "type": "business",
            "name": "Solo",
            "version": "v1_mvm",
            "description": "Hand-typed business",
            "industry_alignment": "Retail",
            "domains": [],
        }
        digest = extract_business_digest(payload)
        assert digest is not None
        assert digest.business_name == "Solo"
        assert digest.description == "Hand-typed business"
        assert digest.industry_alignment == "Retail"

    def test_no_name_returns_none(self):
        payload = {"random": "junk"}
        assert extract_business_digest(payload) is None

    def test_business_vibes_lists_are_sorted_bullets_jargon_as_key_value(self):
        """The assembled detailed-description renders each comma-list context
        field as an alphabetically-sorted Markdown bullet list, the lead is the
        free-form description, and jargon ``TERM (meaning)`` entries collapse to
        ``TERM: meaning``."""
        payload = {
            "model_requirements": {
                "business_name": "Energy",
                "description": "An energy utility.",
                "org_divisions": "Operations, Business",
            },
            "model": {
                "type": "business",
                "name": "Energy",
                "core_business_processes": "Generation (a; b), Billing, Asset Mgmt",
                "common_business_jargons": "kWh (Kilowatt-Hour), AMI (Advanced Metering Infrastructure)",
            },
        }
        vibes = extract_business_digest(payload).business_vibes
        assert vibes.startswith("An energy utility.")
        # Lead description is prose, not a bullet.
        assert "- An energy utility." not in vibes
        # Comma-list → sorted bullets; the inner "(a; b)" comma is NOT split.
        assert (
            "## Core business processes\n"
            "- Asset Mgmt\n"
            "- Billing\n"
            "- Generation (a; b)" in vibes
        )
        # Jargon → "TERM: meaning", alphabetically sorted by term.
        assert (
            "## Common business jargon\n"
            "- AMI: Advanced Metering Infrastructure\n"
            "- kWh: Kilowatt-Hour" in vibes
        )
        # org_divisions fallback (requirements) bulletized + sorted.
        assert "## Organization divisions\n- Business\n- Operations" in vibes

    def test_business_vibes_jargon_dict_renders_key_value(self):
        """A dict-shaped ``common_business_jargons`` renders ``key: value``."""
        payload = {
            "model_requirements": {"business_name": "X", "description": "d"},
            "model": {
                "type": "business",
                "name": "X",
                "common_business_jargons": {"MAU": "Monthly Active Users", "DAU": "Daily Active Users"},
            },
        }
        vibes = extract_business_digest(payload).business_vibes
        assert (
            "## Common business jargon\n"
            "- DAU: Daily Active Users\n"
            "- MAU: Monthly Active Users" in vibes
        )

    def test_empty_context_fields_default_to_blank_strings(self):
        payload = {
            "model_requirements": {"business_name": "X"},
            "model": {"type": "business", "name": "X"},
        }
        digest = extract_business_digest(payload)
        assert digest is not None
        assert digest.core_business_processes == ""
        assert digest.industry_alignment == ""

    def test_industry_alignment_only_in_inner_model_not_requirements(self):
        """Spec contract: industry_alignment lives in ``model.*``, not in
        ``model_requirements.*``. Make sure we don't accidentally read
        the wrong one if both happen to be present."""
        payload = {
            "model_requirements": {
                "business_name": "Acme",
                "industry_alignment": "WRONG",  # agent never writes this here
            },
            "model": {
                "type": "business",
                "name": "Acme",
                "industry_alignment": "Retail",
            },
        }
        digest = extract_business_digest(payload)
        assert digest is not None
        assert digest.industry_alignment == "Retail"


class TestDiffBusinessDigest:
    def _digest(self, **overrides):
        from vibe_modeling.backend.models import BusinessDigest
        base = dict(
            business_name="Gaming",
            industry_alignment="Gaming",
            description="",
        )
        base.update(overrides)
        return BusinessDigest(**base)

    def test_clean_match_returns_no_mismatches(self):
        digest = self._digest()
        assert diff_business_digest(
            digest, current_name="Gaming", current_industry_alignment="Gaming",
        ) == []

    def test_case_insensitive_match(self):
        digest = self._digest()
        assert diff_business_digest(
            digest, current_name="gaming", current_industry_alignment="GAMING",
        ) == []

    def test_name_mismatch_caught(self):
        digest = self._digest()
        mismatches = diff_business_digest(
            digest,
            current_name="Gaming Reference Model",
            current_industry_alignment="Gaming",
        )
        assert len(mismatches) == 1
        assert mismatches[0].field == "business_name"
        assert mismatches[0].source_value == "Gaming"
        assert mismatches[0].current_value == "Gaming Reference Model"

    def test_industry_mismatch_caught(self):
        digest = self._digest(industry_alignment="Gaming")
        mismatches = diff_business_digest(
            digest,
            current_name="Gaming",
            current_industry_alignment="Retail",
        )
        assert len(mismatches) == 1
        assert mismatches[0].field == "industry_alignment"
        assert mismatches[0].source_value == "Gaming"
        assert mismatches[0].current_value == "Retail"

    def test_empty_source_industry_is_not_a_mismatch(self):
        """Silent file ('I don't know') is not a disagreement with a set
        target. Otherwise every minimal model.json without
        industry_alignment would trip the warning."""
        digest = self._digest(industry_alignment="")
        mismatches = diff_business_digest(
            digest,
            current_name="Gaming",
            current_industry_alignment="Gaming",
        )
        assert mismatches == []

    def test_industry_slug_match_is_not_a_mismatch(self):
        """The import dialog stores the catalog name of the agent's slug."""
        digest = self._digest(industry_alignment="energy-utilities")
        assert diff_business_digest(
            digest, current_name="Gaming", current_industry_alignment="Energy - Utilities",
        ) == []

    def test_same_resolved_industry_is_not_a_mismatch(self):
        digest = self._digest(industry_alignment="utilities")
        assert diff_business_digest(
            digest,
            current_name="Gaming",
            current_industry_alignment="Energy - Utilities",
            digest_industry_id="ind-1",
            current_industry_id="ind-1",
        ) == []

    def test_different_resolved_industries_still_mismatch(self):
        digest = self._digest(industry_alignment="utilities")
        mismatches = diff_business_digest(
            digest,
            current_name="Gaming",
            current_industry_alignment="Energy - Utilities",
            digest_industry_id="ind-1",
            current_industry_id="ind-2",
        )
        assert [m.field for m in mismatches] == ["industry_alignment"]

    def test_unresolved_ids_do_not_count_as_equal(self):
        digest = self._digest(industry_alignment="Retail")
        mismatches = diff_business_digest(
            digest,
            current_name="Gaming",
            current_industry_alignment="Energy",
            digest_industry_id=None,
            current_industry_id=None,
        )
        assert [m.field for m in mismatches] == ["industry_alignment"]

    def test_both_fields_mismatch(self):
        digest = self._digest(business_name="A", industry_alignment="B")
        mismatches = diff_business_digest(
            digest, current_name="X", current_industry_alignment="Y",
        )
        assert {m.field for m in mismatches} == {
            "business_name", "industry_alignment",
        }
