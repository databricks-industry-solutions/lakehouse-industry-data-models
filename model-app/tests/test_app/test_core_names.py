"""Tests for core/_names.py — string-safety transforms."""

import logging
import sys
import os

import pytest

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "..", "src", "app", "src"))

from vibe_modeling.backend.core._names import (
    agent_business_segment,
    escape_sql_literal,
    metamodel_display_business,
    sanitize_catalog_segment,
    sanitize_tag,
)


class TestMetamodelDisplayBusiness:
    """Mirrors the agent's Cell-120 rule: ``business_name_raw.strip().title()``.

    The helper chains ``agent_business_segment`` (lowercase slug) then
    ``.strip().title()``.  Python's ``.title()`` capitalises after every
    non-alphabetical character — including digits, not just ``_``.
    Pre-fix: ``metamodel_display_business`` does not exist → all tests fail.
    """

    def test_multi_word_display_casing(self):
        assert metamodel_display_business("terranova_copy") == "Terranova_Copy"

    def test_raw_display_name_normalised_then_cased(self):
        assert metamodel_display_business("Terranova Copy") == "Terranova_Copy"

    def test_vesta_markets(self):
        assert metamodel_display_business("Vesta Markets") == "Vesta_Markets"

    def test_single_token(self):
        assert metamodel_display_business("cpg") == "Cpg"

    def test_digit_precedes_letter_title_capitalises(self):
        """Python .title() capitalises after digits: 'retail2b' → 'Retail2B'."""
        assert metamodel_display_business("retail2b") == "Retail2B"

    def test_empty_returns_empty(self):
        assert metamodel_display_business("") == ""

    def test_none_returns_empty(self):
        assert metamodel_display_business(None) == ""  # type: ignore[arg-type]

    def test_idempotent_on_slug_input(self):
        slug = agent_business_segment("Terranova Copy")
        assert metamodel_display_business(slug) == metamodel_display_business("Terranova Copy")

    def test_digit_prefix_preserved(self):
        assert metamodel_display_business("7-eleven") == "_7_Eleven"


class TestAgentBusinessSegment:
    """Mirrors the bundled agent's ``sanitize_name(strip_stop_words=False)``
    rule (see ``src/app/vendored/agent/vibe_modelling_agent_v0.7.1.ipynb``,
    cell defining ``def sanitize_name(name, strip_stop_words=True):  #
    GEN-RUL-002``):

        lower → re.sub(r'[^a-z0-9_]', '_', s) → collapse '_+' →
        strip '_' → digit-prefix '_' if startswith digit
    """

    def test_lowercase_and_space_to_underscore(self):
        assert agent_business_segment("Test Retail") == "test_retail"

    def test_trailing_dot(self):
        # `.` -> _, then trailing _ stripped.
        assert agent_business_segment("Test Retail.") == "test_retail"

    def test_internal_dot_replaced_with_underscore(self):
        # The agent REPLACES (not strips) non-safe chars.
        assert agent_business_segment("Acme.Inc") == "acme_inc"

    def test_hyphen_replaced(self):
        assert agent_business_segment("Pre-wipe Co") == "pre_wipe_co"

    def test_ampersand_replaced_then_collapsed(self):
        # 'acme & co.' -> 'acme___co_' -> 'acme_co_' -> 'acme_co'
        assert agent_business_segment("Acme & Co.") == "acme_co"

    def test_already_normalized_is_idempotent(self):
        assert agent_business_segment("test_retail") == "test_retail"

    def test_leading_trailing_spaces_stripped(self):
        # ' ' -> '_', collapse, then strip leading/trailing '_'.
        assert agent_business_segment("  Foo Bar  ") == "foo_bar"

    def test_digit_prefix_underscored(self):
        # '7-eleven' -> '7_eleven' -> starts with digit -> '_7_eleven'.
        assert agent_business_segment("7-eleven") == "_7_eleven"

    def test_empty(self):
        assert agent_business_segment("") == ""

    def test_none_safely_returns_empty(self):
        assert agent_business_segment(None) == ""  # type: ignore[arg-type]

    def test_clean_inputs_match_old_inline_form(self):
        # Round-trip property: for a "clean" input (only letters / digits
        # / underscores / spaces, no leading/trailing whitespace, no
        # leading digit), the legacy inline form
        # `name.lower().replace(" ", "_")` agrees with this helper. The
        # 8 inline call sites left for Phase 2 will migrate without
        # behavioral change for these inputs.
        for name in (
            "Test Retail",
            "Acme Co",
            "FooBar",
            "Multi Word Business Name",
            "snake_case_already",
        ):
            inline = name.lower().replace(" ", "_")
            assert agent_business_segment(name) == inline, (
                f"helper diverges from inline form for clean input {name!r}"
            )

    def test_parity_with_agent_sanitize_name(self):
        """Parity table against the bundled agent's
        ``sanitize_name(strip_stop_words=False)``. Each (input, expected)
        pair below was hand-traced through the agent's notebook
        implementation step-by-step.
        """
        cases = [
            # input,                expected
            ("Test Retail.",        "test_retail"),
            ("Acme.Inc",            "acme_inc"),
            ("Pre-wipe Co",         "pre_wipe_co"),
            ("Acme & Co.",          "acme_co"),
            ("  Foo Bar  ",         "foo_bar"),
            ("7-eleven",            "_7_eleven"),
            ("hello/world",         "hello_world"),
            ("multi   space",       "multi_space"),
            # 'é' is non-ASCII, replaced + collapsed + stripped.
            ("Café",                "caf"),
        ]
        for raw, want in cases:
            got = agent_business_segment(raw)
            assert got == want, f"{raw!r}: expected {want!r}, got {got!r}"

    def test_diverges_from_sanitize_catalog_segment_only_on_digit_and_empty(self):
        """``sanitize_catalog_segment`` and ``agent_business_segment`` are
        near-equivalent (Phase 4 will collapse them). Today they diverge
        only in: empty-default (``"vibe"`` vs ``""``) and digit-prefix
        guard (``agent_business_segment`` prepends ``_``).
        """
        # Match on a typical input.
        assert sanitize_catalog_segment("Test Retail.") == agent_business_segment("Test Retail.")
        assert sanitize_catalog_segment("Acme.Inc") == agent_business_segment("Acme.Inc")
        # Diverge on empty.
        assert sanitize_catalog_segment("") == "vibe"
        assert agent_business_segment("") == ""
        # Diverge on digit-prefix.
        assert sanitize_catalog_segment("7-eleven") == "7_eleven"
        assert agent_business_segment("7-eleven") == "_7_eleven"


@pytest.mark.parametrize("name", [
    "test_retail", "test retail.", "Test Retail.", "Acme.Inc",
    "Pre-wipe Co", "7-eleven", "Foo (Bar)", "O'Brien Ltd",
    "  whitespace  ", "Café", "ALLCAPS", "_under_",
    "1starts_with_digit", "", "single", "a",
])
def test_agent_segment_eq_catalog_segment_for_business_names(name):
    """Document the empirical equivalence of ``agent_business_segment`` and
    ``sanitize_catalog_segment`` for realistic business-name inputs.

    Phase 4 of the drift-unification plan: before consolidating the two
    sanitizers, lock down their observable behaviour on a representative
    input set. The parametric matrix is the union of every realistic
    business-name shape we've seen at the Phase 1-3 path-builder + widget
    consumers: typical multi-word labels, trailing punctuation, internal
    punctuation, parens, apostrophes, leading whitespace, non-ASCII,
    all-caps, digit-prefix, single-char, and empty.

    The ONLY divergences this test documents (and accepts) are:

    * Empty default — agent returns ``""``, catalog returns ``"vibe"``.
      The agent boundary uses the empty sentinel to detect "no name was
      passed" and abort rather than silently bucketing into a shared
      Volume folder. The catalog rule defaults to ``"vibe"`` because it
      is used to derive UC catalog segments where an identifier IS
      required by the grammar.

    * Digit-prefix — agent prepends ``_`` (UC catalog identifiers can't
      start with a digit). ``sanitize_catalog_segment`` was authored
      before the digit-prefix concern surfaced; the agent rule is the
      stricter one and produces the on-disk Volume segments.

    Any unexpected divergence here is a bug in one of the two helpers
    (or in this test's assumption set) and should fail loudly so the
    consolidation strategy can adjust.
    """
    a = agent_business_segment(name)
    c = sanitize_catalog_segment(name)
    if a == c:
        return
    # Acceptable: empty default — agent returns "", catalog returns "vibe".
    if a == "" and c == "vibe":
        return
    # Acceptable: digit-prefix — agent prepends "_", catalog doesn't.
    if a == "_" + c:
        return
    pytest.fail(f"unexpected divergence on {name!r}: agent={a!r}, catalog={c!r}")


class TestSyncModelWarning:
    """The defensive `_warn_if_unsanitized` helper at the boundary of
    `ModelSyncService` should fire for un-normalized names and stay
    silent for already-normalized ones.
    """

    def test_warning_fires_on_unsanitized_name(self, caplog):
        from vibe_modeling.backend.model_sync import _warn_if_unsanitized

        with caplog.at_level(logging.WARNING, logger="vibe_modeling.backend.model_sync"):
            _warn_if_unsanitized("sync_model", "Test Retail.")

        assert any(
            "Test Retail." in r.getMessage()
            and "outside agent rule" in r.getMessage()
            and r.levelno == logging.WARNING
            for r in caplog.records
        ), f"expected drift warning, got: {[r.getMessage() for r in caplog.records]}"

    def test_warning_silent_on_sanitized_name(self, caplog):
        from vibe_modeling.backend.model_sync import _warn_if_unsanitized

        with caplog.at_level(logging.WARNING, logger="vibe_modeling.backend.model_sync"):
            _warn_if_unsanitized("sync_model", "test_retail")

        drift_warnings = [
            r for r in caplog.records
            if "outside agent rule" in r.getMessage()
        ]
        assert not drift_warnings, (
            f"clean name should not trigger drift warning, got: {drift_warnings}"
        )

    def test_warning_silent_on_empty(self, caplog):
        from vibe_modeling.backend.model_sync import _warn_if_unsanitized

        with caplog.at_level(logging.WARNING, logger="vibe_modeling.backend.model_sync"):
            _warn_if_unsanitized("sync_model", "")

        assert not caplog.records, (
            f"empty name should not warn, got: {[r.getMessage() for r in caplog.records]}"
        )


class TestEscapeSqlLiteralNulBytes:
    """NUL bytes are stripped (Databricks SQL rejects them) and the loss is
    logged with a count, never silently."""

    def test_strips_and_warns_with_count(self, caplog):
        with caplog.at_level(logging.WARNING, logger="vibe_modeling.backend.core._names"):
            assert escape_sql_literal("a\x00b'\x00c") == "ab''c"
        warnings = [r for r in caplog.records if r.levelno == logging.WARNING]
        assert len(warnings) == 1
        assert "2 NUL" in warnings[0].getMessage()
        # The value is not logged.
        assert "ab" not in warnings[0].getMessage()

    def test_no_warning_without_nul(self, caplog):
        with caplog.at_level(logging.WARNING, logger="vibe_modeling.backend.core._names"):
            assert escape_sql_literal("it's") == "it''s"
        assert not [r for r in caplog.records if r.levelno == logging.WARNING]
