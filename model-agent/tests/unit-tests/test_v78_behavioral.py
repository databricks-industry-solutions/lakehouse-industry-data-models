"""v0.7.8 behavioral tests — six root-cause fixes.

These tests exercise the patched code paths end-to-end against in-memory model
fixtures. They are NOT static-grep tautologies (per §8.3). Each test will fail
on v0.7.7 and pass on v0.7.8.

Patches under test:
  P31 n5-idempotent-add          -- product.add / domain.add count as applied
                                    when the entity already exists in the
                                    model. (v0.7.7 healthcare: 591 of 1056
                                    skips were silent no-ops mis-tagged as
                                    no_match_or_parts.)
  P32 n5-auto-parent-domain      -- product.add auto-creates a missing parent
                                    domain so the child can land in the same
                                    batch.
  P33 n4-link-applier-honesty    -- link.add / link.modify with empty new_value
                                    must NOT count as applied; instead append
                                    to skipped with reason 'link_fk_target_empty'.
  P34 n4-validator-fk-check      -- _llm_fallback_validate parses
                                    'foreign_key_to <target>' out of
                                    expected_outcome and verifies the FK on the
                                    row; case-insensitive lookup; implements
                                    'comparison' check_type.
  P35 vov-closure-parser-stricter -- _compute_vov_user_closure rejects 1-2 char
                                    tokens, expanded stopwords, strips known
                                    abbreviations like 'e.g.' and 'i.e.' before
                                    scanning.
  P36 vov-preserve-v1-domains    -- _strict_vov_diff_guard restores v1 input-
                                    model domains in preserve_v1_domains even
                                    when their name appears in user_closure.

These tests will catch regressions in any of the above.
"""
from __future__ import annotations

import json
import logging
import re
from pathlib import Path

import pytest

from notebook_source_util import notebook_concat_source

REPO_ROOT = Path(__file__).resolve().parent.parent.parent
AGENT_NB = REPO_ROOT / "agent" / "dbx_vibe_modelling_agent.ipynb"


def _load_cell3_helpers():
    from notebook_source_util import exec_function_namespace, slice_function_source

    stubs = {
        "logging": logging,
        "json": json,
        "re": re,
        "_MUT_ENTITY_SYNONYMS": {
            "link": "link",
            "attribute": "attribute",
            "product": "product",
            "domain": "domain",
            "fk": "link",
            "foreign_key": "link",
            "column": "attribute",
            "table": "product",
        },
        "_MUT_OPERATION_SYNONYMS": {
            "modify": "modify",
            "add": "add",
            "create": "add",
            "remove": "remove",
            "drop": "remove",
        },
        "sanitize_attribute_type": lambda a: None,
        "_vibe_set_entity_tag": lambda obj, field, value: (
            obj.__setitem__(field, value) if isinstance(obj, dict) else None
        ),
        "_p091_is_valid_identifier": lambda s: (True, ""),
        "_p091_reject_name_mutation": lambda *a, **k: False,
        "_preseed_rename_maps": lambda mutations: ({}, {}, {}),
        "_VIBE_SCOPE_RUNTIME": None,
        "_disk_cached_call": lambda prefix, key_parts, compute_fn: compute_fn(),
    }
    ns = dict(stubs)
    ns["__name__"] = "_v78test"
    for fn in (
        "get_vibe_scope_runtime",
        "_build_fk_adjacency",
        "_would_create_cycle",
        "_sync_fk_type_with_pk",
        "_llm_fallback_apply_mutations",
        "_llm_fallback_validate",
        "_cleanup_empty_domains",
    ):
        exec(
            compile(slice_function_source(fn), f"<v78_{fn}>", "exec"),
            ns,
        )
    return ns


def _load_cell9_helpers():
    from notebook_source_util import slice_function_source

    ns = {"__name__": "_v78test_c9", "logging": logging, "re": re}
    # v2.7.0: _vov_diff_guard_products and _strict_vov_diff_guard were removed
    # in the architectural collapse (sandbox is now authoritative). Only the
    # still-live closure helper is loaded here.
    for fn in (
        "_compute_vov_user_closure",
    ):
        exec(compile(slice_function_source(fn), f"<v78_{fn}>", "exec"), ns)
    return ns


@pytest.fixture(scope="module")
def c3():
    return _load_cell3_helpers()


@pytest.fixture(scope="module")
def c9():
    return _load_cell9_helpers()


def _logger():
    lg = logging.getLogger(f"v78test.{id(object())}")
    lg.handlers = []
    lg.addHandler(logging.NullHandler())
    lg.setLevel(logging.DEBUG)
    return lg


# ============================================================================
# P31 n5-idempotent-add — already-existing entity counts as applied
# ============================================================================


def test_p31_product_add_existing_counts_as_applied(c3):
    apply_mutations = c3["_llm_fallback_apply_mutations"]
    domains = [{"domain": "sales"}]
    products = [{"domain": "sales", "product": "orders", "description": "existing"}]
    attributes = []
    mutations = [{
        "entity_type": "product",
        "operation": "add",
        "entity_ref": "sales.orders",
        "field": "",
        "new_value": "Re-emitted by LLM in later batch",
    }]
    applied = apply_mutations(mutations, domains, products, attributes, [], _logger())
    assert applied == 1, (
        f"P31: product.add for an existing product must count as applied "
        f"(idempotent re-emit, user intent satisfied). Got applied={applied}."
    )
    assert len(products) == 1, "must not duplicate the row"


def test_p31_domain_add_existing_counts_as_applied(c3):
    apply_mutations = c3["_llm_fallback_apply_mutations"]
    domains = [{"domain": "billing"}]
    products = []
    attributes = []
    mutations = [{
        "entity_type": "domain",
        "operation": "add",
        "entity_ref": "billing",
        "field": "",
        "new_value": "Re-emitted",
    }]
    applied = apply_mutations(mutations, domains, products, attributes, [], _logger())
    assert applied == 1, f"P31: domain.add idempotent re-emit must count as applied. Got {applied}"
    assert len(domains) == 1


def test_p31_product_add_new_still_creates(c3):
    apply_mutations = c3["_llm_fallback_apply_mutations"]
    domains = [{"domain": "sales"}]
    products = []
    attributes = []
    mutations = [{
        "entity_type": "product",
        "operation": "add",
        "entity_ref": "sales.orders",
        "field": "",
        "new_value": "All orders",
    }]
    applied = apply_mutations(mutations, domains, products, attributes, [], _logger())
    assert applied == 1
    assert any(p["product"] == "orders" for p in products), "P31 must not regress: new product still adds"


# ============================================================================
# P32 n5-auto-parent-domain — product.add auto-creates missing parent
# ============================================================================


def test_p32_product_add_auto_creates_missing_parent_domain(c3):
    apply_mutations = c3["_llm_fallback_apply_mutations"]
    domains = []  # parent missing
    products = []
    attributes = []
    mutations = [{
        "entity_type": "product",
        "operation": "add",
        "entity_ref": "genomics.biobank_specimen",
        "field": "",
        "new_value": "Biobank specimen tracking",
    }]
    applied = apply_mutations(mutations, domains, products, attributes, [], _logger())
    assert any(d["domain"] == "genomics" for d in domains), (
        "P32: product.add on a missing parent domain must auto-create the parent"
    )
    assert any(p["domain"] == "genomics" and p["product"] == "biobank_specimen" for p in products)
    assert applied >= 1


def test_p32_product_add_does_not_duplicate_existing_parent(c3):
    apply_mutations = c3["_llm_fallback_apply_mutations"]
    domains = [{"domain": "genomics"}]
    products = []
    attributes = []
    mutations = [{
        "entity_type": "product",
        "operation": "add",
        "entity_ref": "genomics.biobank_specimen",
        "field": "",
        "new_value": "Biobank specimen tracking",
    }]
    apply_mutations(mutations, domains, products, attributes, [], _logger())
    assert len([d for d in domains if d["domain"] == "genomics"]) == 1, (
        "P32 must not duplicate an existing parent domain"
    )


# ============================================================================
# P33 n4-link-applier-honesty — link.add/modify refuses empty new_value
# ============================================================================


def test_p33_link_modify_empty_new_value_is_skipped(c3):
    apply_mutations = c3["_llm_fallback_apply_mutations"]
    domains = [{"domain": "sales"}, {"domain": "customer"}]
    products = [
        {"domain": "sales", "product": "orders"},
        {"domain": "customer", "product": "customers"},
    ]
    attributes = [
        {"domain": "sales", "product": "orders", "attribute": "customer_id",
         "type": "BIGINT", "foreign_key_to": ""},
    ]
    mutations = [{
        "entity_type": "link",
        "operation": "modify",
        "entity_ref": "sales.orders.customer_id",
        "field": "foreign_key_to",
        "new_value": "",  # empty target -> P33 must reject
    }]
    applied = apply_mutations(mutations, domains, products, attributes, [], _logger())
    target = next(a for a in attributes if a["attribute"] == "customer_id")
    assert target["foreign_key_to"] == "", (
        "P33: link.modify with empty new_value must NOT write any FK. "
        f"Got foreign_key_to={target['foreign_key_to']!r}"
    )
    assert applied == 0, f"P33: empty FK must not count as applied; got applied={applied}"


def test_p33_link_add_empty_new_value_is_skipped(c3):
    apply_mutations = c3["_llm_fallback_apply_mutations"]
    domains = [{"domain": "sales"}, {"domain": "customer"}]
    products = [
        {"domain": "sales", "product": "orders"},
        {"domain": "customer", "product": "customers"},
    ]
    attributes = []
    mutations = [{
        "entity_type": "link",
        "operation": "add",
        "entity_ref": "sales.orders.cust_ref",
        "field": "",
        "new_value": "",
    }]
    applied = apply_mutations(mutations, domains, products, attributes, [], _logger())
    assert applied == 0, "P33: link.add with empty new_value must not count as applied"
    assert not any(a.get("attribute") == "cust_ref" for a in attributes), (
        "P33: link.add with empty new_value must NOT create a phantom column"
    )


def test_p33_link_add_non_empty_still_works(c3):
    """Anti-regression: P33 must not break legitimate link.add."""
    apply_mutations = c3["_llm_fallback_apply_mutations"]
    domains = [{"domain": "sales"}, {"domain": "customer"}]
    products = [
        {"domain": "sales", "product": "orders"},
        {"domain": "customer", "product": "customers"},
    ]
    attributes = []
    mutations = [{
        "entity_type": "link",
        "operation": "add",
        "entity_ref": "sales.orders.customer_id",
        "field": "",
        "new_value": "customer.customers.customer_pk",
    }]
    applied = apply_mutations(mutations, domains, products, attributes, [], _logger())
    assert applied >= 1
    target = next(a for a in attributes if a["attribute"] == "customer_id")
    assert target["foreign_key_to"] == "customer.customers.customer_pk"


# ============================================================================
# P34 n4-validator-fk-check — validator verifies FK target
# ============================================================================


def test_p34_validator_existence_fk_match(c3):
    validate = c3["_llm_fallback_validate"]
    attributes = [
        {"domain": "sales", "product": "orders", "attribute": "customer_id",
         "foreign_key_to": "customer.customers.customer_pk"},
    ]
    hint = {
        "check_type": "existence",
        "target_description": "sales.orders.customer_id",
        "expected_outcome": "attribute exists with foreign_key_to reference to customer.customers.customer_pk",
    }
    assert validate(hint, [], [], attributes, _logger()) is True


def test_p34_validator_existence_fk_mismatch_fails(c3):
    """The exact legal-VOV failure: row exists, but FK is empty (or wrong).
    Pre-v0.7.8 this returned PASS because existence check ignored the FK.
    v0.7.8 must report FAIL."""
    validate = c3["_llm_fallback_validate"]
    attributes = [
        {"domain": "document", "product": "production_specification", "attribute": "matter_id",
         "foreign_key_to": ""},  # FK empty — the legal-VOV bug
    ]
    hint = {
        "check_type": "existence",
        "target_description": "document.production_specification.matter_id",
        "expected_outcome": "attribute exists with foreign_key_to reference to matter.matter.matter_id",
    }
    assert validate(hint, [], [], attributes, _logger()) is False, (
        "P34: FK empty must be a FAIL when expected mentions foreign_key_to"
    )


def test_p34_validator_case_insensitive_lookup(c3):
    """The model row uses 'Document' (capital D); validator was case-sensitive
    and missed it. P34 normalizes both sides to lowercase."""
    validate = c3["_llm_fallback_validate"]
    attributes = [
        {"domain": "Document", "product": "Production_Specification", "attribute": "matter_id",
         "foreign_key_to": "matter.matter.matter_id"},
    ]
    hint = {
        "check_type": "existence",
        "target_description": "document.production_specification.matter_id",
        "expected_outcome": "attribute exists with foreign_key_to reference to matter.matter.matter_id",
    }
    assert validate(hint, [], [], attributes, _logger()) is True


def test_p34_validator_comparison_check(c3):
    validate = c3["_llm_fallback_validate"]
    attributes = [
        {"domain": "sales", "product": "orders", "attribute": "customer_id",
         "foreign_key_to": "customer.customers.customer_pk"},
    ]
    hint = {
        "check_type": "comparison",
        "target_description": "sales.orders.customer_id",
        "expected_outcome": "foreign_key_to customer.customers.customer_pk",
    }
    assert validate(hint, [], [], attributes, _logger()) is True
    hint["expected_outcome"] = "foreign_key_to customer.customers.wrong_pk"
    assert validate(hint, [], [], attributes, _logger()) is False


# ============================================================================
# P35 vov-closure-parser-stricter — no more 'e.g.' / 'above' / 'instruction'
# ============================================================================


def test_p35_no_eg_tuple_from_eg_prose(c9):
    """The legal v0.7.7 run produced ('e','g') in _vov_user_new_entities because
    the parser matched 'e.g.' as a 2-token entity. P35 strips abbreviations."""
    fn = c9["_compute_vov_user_closure"]
    vibe = "Please add a new domain, e.g. billing.invoice for the legal practice."
    closure, new_entities = fn(vibe)
    assert ("e", "g") not in closure
    assert ("e", "g") not in new_entities
    assert ("e",) not in new_entities
    assert ("g",) not in new_entities


def test_p35_no_ie_tuple_from_ie_prose(c9):
    fn = c9["_compute_vov_user_closure"]
    vibe = "We need a new domain (i.e. risk.exposure) to handle the new use case."
    closure, new_entities = fn(vibe)
    assert ("i", "e") not in closure
    assert ("i",) not in new_entities


def test_p35_no_short_tokens(c9):
    """Identifier must be at least 3 chars long. 'above', 'below', 'see' etc.
    are explicitly in the stopword set."""
    fn = c9["_compute_vov_user_closure"]
    vibe = "Please create see.above for the noted needs.list above"
    _, new_entities = fn(vibe)
    flat = {t for tup in new_entities for t in tup}
    assert "see" not in flat
    assert "above" not in flat
    assert "needs" not in flat
    assert "list" not in flat


def test_p35_real_two_token_still_extracts(c9):
    """Anti-regression: a legitimate two-token entity must still be captured."""
    fn = c9["_compute_vov_user_closure"]
    vibe = "Please CREATE billing.invoice as a new domain.product."
    _, new_entities = fn(vibe)
    flat_pairs = {tup for tup in new_entities if len(tup) == 2}
    assert ("billing", "invoice") in flat_pairs


def test_p35_above_instruction_needs_filtered(c9):
    """Three of the exact garbage tokens from the v0.7.7 legal log."""
    fn = c9["_compute_vov_user_closure"]
    vibe = "CREATE the following per instruction above for the customer needs section."
    _, new_entities = fn(vibe)
    flat = {t for tup in new_entities for t in tup}
    for bad in ("above", "instruction", "needs", "per", "section"):
        assert bad not in flat, f"P35: stopword {bad!r} leaked into new_entities"


# ============================================================================
# P36 vov-preserve-v1-domains — strict-diff-guard tests REMOVED in v2.7.0.
# The _strict_vov_diff_guard was deleted in the architectural collapse: the
# sandbox (run_vov_pipeline) is now the single authoritative mutation engine,
# so there is no additive-diff guard to revert/restore domains. The cleanup
# integration test below (c3-based) remains valid and is retained.
# ============================================================================


# ============================================================================
# Bonus: cleanup integration — preserve_v1_domains protects empty shells
# ============================================================================


def test_p36_cleanup_protects_v1_preserved_domain_emptied_by_move_product(c3):
    """Legal-VOV exact scenario: move_product emptied 'court'. The cleanup
    call must keep the shell because preserve_v1_domains includes 'court'."""
    cleanup = c3["_cleanup_empty_domains"]
    domains_data = [
        {"domain": "billing"},
        {"domain": "court"},   # emptied by move_product
        {"domain": "matter"},
    ]
    products_data = [
        {"domain": "billing", "product": "invoice"},
        {"domain": "matter", "product": "adr_proceeding"},  # was court.adr_proceeding
        {"domain": "matter", "product": "arbitral_award"},  # was court.arbitral_award
    ]
    cleanup(
        domains_data, products_data, _logger(),
        user_specified_domains=["billing", "court", "matter"],  # preserve list threaded in
        user_vibed_new_domains=set(),
    )
    names = [d["domain"] for d in domains_data]
    assert "court" in names, "P36: preserved-v1 domain must survive _cleanup_empty_domains"


# ============================================================================
# Static-grep contracts — cheap audit signals
# ============================================================================


def test_v78_agent_version_constant():
    src = notebook_concat_source()
    m = re.search(r'__AGENT_VERSION__\s*=\s*\\?"(\d+)\.(\d+)\.(\d+)\\?"', src)
    assert m, "__AGENT_VERSION__ literal not found"
    assert (int(m.group(1)), int(m.group(2)), int(m.group(3))) >= (0, 7, 8), (
        f"expected v>=0.7.8, found {m.group(1)}.{m.group(2)}.{m.group(3)}"
    )


def test_v78_aliases_present():
    src = notebook_concat_source()
    for alias in [
        "n5-idempotent-add",
        "n5-auto-parent-domain",
        "n4-link-applier-honesty",
        "n4-validator-fk-check",
        "vov-closure-parser-stricter",
        "vov-preserve-v1-domains",
        "n5-new-base-skip-context",
    ]:
        assert alias in src, f"v0.7.8 alias {alias!r} must be present in deployed code"


def test_p38_new_base_skips_context_file_load():
    """P38 [n5-new-base-skip-context]: when operation == 'new base model', the
    notebook MUST skip loading any context_file (even if widget is non-empty)
    so that a stale path doesn't crash get_widget_values before any logs ship.
    """
    # Walk the actual cell sources (post-JSON-load) so we read the python code,
    # not the json-escaped serialized form.
    nb = json.loads(AGENT_NB.read_text(encoding="utf-8"))
    code = "\n".join(
        "".join(cell.get("source", []))
        for cell in nb.get("cells", [])
        if cell.get("cell_type") == "code"
    )
    assert "n5-new-base-skip-context" in code, (
        "P38 sentinel n5-new-base-skip-context must be present in code"
    )
    assert 'str(w_operation or "").strip().lower() == "new base model"' in code, (
        "P38 guard must compare lowercased w_operation to 'new base model'"
    )
    pre_idx = code.find("n5-new-base-skip-context")
    post_block = code[pre_idx: pre_idx + 1200]
    assert 'w_context_file = ""' in post_block, (
        "P38 must blank out w_context_file inside the guard so the next "
        "load attempt short-circuits"
    )


def test_v78_preserves_p22_p30():
    """Anti-regression: prior version aliases must remain intact."""
    from notebook_source_util import notebook_concat_source
    from version_test_util import assert_aliases_present

    assert_aliases_present(
        notebook_concat_source(),
        [
            "vov-user-authority-bypass-contract",
            "vov-closure-action-aware",
            "vov-ssot-user-wins",
            "vreq-target-revalidate-on-execute",
            "vreq-target-revalidate-retry",
            "vov-sizing-source-scale-guard",
            "vov-master-failure-user-authority",
            "vov-skip-regen-action-aware",
        ],
    )
