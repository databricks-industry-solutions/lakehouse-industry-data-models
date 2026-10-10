"""v5.0.1 one-mutation-engine: VoV structural ops apply through the single canonical
`_llm_fallback_apply_mutations` engine (no sandbox second path, no new engine).

Two root causes fixed and locked here:

1. Domain MERGE was absent as an engine op. Decomposing a merge into per-product
   move mutations + a trailing `domain.remove` is UNSAFE: the applier topologically
   sorts mutations (pass 2 orders `domain`=0 before `product`=1), so the destructive
   `domain.remove` ran BEFORE the product moves and DELETED the source's products
   (live evidence: `entity_not_in_model: 32`, 16 products lost, 130 FKs lost). The
   fix adds ONE atomic `domain.merge` handler that moves+cascades+drops in a single
   step the sort cannot split. `test_atomic_merge_*` fail pre-fix (no merge branch ->
   unknown_combo -> nothing folded / data lost) and pass post-fix.

2. Product MOVE between domains was a no-op: the product-modify branch accepted
   `product/description/tags/primary_key/table_name/subdomain` but NOT `domain`, so a
   move fell through to a tag-set. `test_product_move_*` fail pre-fix, pass post-fix.

These `merge`/`move` primitives are the "missing ops" added to the ONE existing engine
(`_llm_fallback_apply_mutations`). VoV reaches this engine because the v270 sandbox-only
bypass was removed, so the shared verification sweep now runs on VoV like every other op.
"""
from __future__ import annotations

import ast
import re

from notebook_source_util import notebook_concat_source, vov_ledger_globals

_ENGINE_FNS = [
    "_is_user_pinned_domain",
    "_guard_user_pinned_domain_drop",
    "_preseed_rename_maps",
    "_p091_is_valid_identifier",
    "_p091_reject_name_mutation",
    "_llm_fallback_apply_mutations",
]
_CONSTS = [
    "_USER_PINNED_DOMAINS_RUNTIME",
    "_MUT_ENTITY_SYNONYMS",
    "_MUT_OPERATION_SYNONYMS",
    "_P091_IDENTIFIER_RE",
    "_P091_PROSE_TOKENS",
]

# Parse the (large) notebook source ONCE and build the engine namespace ONCE.
_SOURCE = notebook_concat_source()
_LINES = _SOURCE.splitlines(keepends=True)
_TREE = ast.parse(_SOURCE)
_FUNC_TYPES = (ast.FunctionDef, ast.AsyncFunctionDef)


def _last_span(name):
    node = None
    for n in _TREE.body:
        if isinstance(n, _FUNC_TYPES) and n.name == name:
            node = n
        elif isinstance(n, ast.Assign) and any(
                isinstance(t, ast.Name) and t.id == name for t in n.targets):
            node = n
    if node is None:
        raise LookupError(name)
    return "".join(_LINES[node.lineno - 1:node.end_lineno])


def _build_engine():
    g = {**vov_ledger_globals(), "re": re,
         "_vibe_set_entity_tag": lambda ent, f, v: ent.__setitem__(f, v),
         "sanitize_attribute_type": lambda t: t}
    blob = "\n\n".join(_last_span(n) for n in (_CONSTS + _ENGINE_FNS))
    exec(compile(blob, "notebook_engine_slice", "exec"), g)
    return g


_NS = _build_engine()


def _engine():
    return _NS


class _Log:
    def info(self, *a, **k): pass
    def warning(self, *a, **k): pass
    def error(self, *a, **k): pass


def _model():
    """Small model: claims(2 products), claimfinancials(2 products, FK into claims),
    riskexposure(1), other(1, FK into claimfinancials)."""
    domains = [{"domain": d, "description": "", "division": "", "database_name": ""}
               for d in ("claims", "claimfinancials", "riskexposure", "other")]
    products = [
        {"domain": "claims", "product": "claim", "table_name": "claim", "subdomain": ""},
        {"domain": "claims", "product": "claimant", "table_name": "claimant", "subdomain": ""},
        {"domain": "claimfinancials", "product": "reserve", "table_name": "reserve", "subdomain": ""},
        {"domain": "claimfinancials", "product": "payment", "table_name": "payment", "subdomain": ""},
        {"domain": "riskexposure", "product": "exposure", "table_name": "exposure", "subdomain": ""},
        {"domain": "other", "product": "misc", "table_name": "misc", "subdomain": ""},
    ]
    attributes = [
        {"domain": "claims", "product": "claim", "attribute": "claim_id", "foreign_key_to": ""},
        {"domain": "claimfinancials", "product": "reserve", "attribute": "reserve_id", "foreign_key_to": ""},
        {"domain": "claimfinancials", "product": "reserve", "attribute": "claim_id", "foreign_key_to": "claims.claim.claim_id"},
        {"domain": "claimfinancials", "product": "payment", "attribute": "payment_id", "foreign_key_to": ""},
        {"domain": "riskexposure", "product": "exposure", "attribute": "exposure_id", "foreign_key_to": ""},
        {"domain": "other", "product": "misc", "attribute": "reserve_ref", "foreign_key_to": "claimfinancials.reserve.reserve_id"},
    ]
    return domains, products, attributes


def _rename_domain(src, tgt):
    return {"entity_type": "domain", "operation": "modify", "entity_ref": src, "field": "domain", "new_value": tgt}


def _merge_domain(src, tgt):
    return {"entity_type": "domain", "operation": "merge", "entity_ref": src, "new_value": tgt}


def _move_product(dom_prod, new_dom):
    return {"entity_type": "product", "operation": "modify", "entity_ref": dom_prod, "field": "domain", "new_value": new_dom}


def _apply(ns, mut, D, P, A):
    return ns["_llm_fallback_apply_mutations"]([mut], D, P, A, [], _Log())


def test_domain_rename_cascades_and_repoints_fks():
    ns = _engine()
    D, P, A = _model()
    applied = _apply(ns, _rename_domain("claims", "claim"), D, P, A)
    assert applied == 1
    assert "claim" in [d["domain"] for d in D] and "claims" not in [d["domain"] for d in D]
    # products + attributes cascaded
    assert all(p["domain"] != "claims" for p in P)
    assert all(a["domain"] != "claims" for a in A)
    # FK that pointed into claims.* is re-pointed to claim.*
    fk = next(a for a in A if a["attribute"] == "claim_id" and a["product"] == "reserve")
    assert fk["foreign_key_to"] == "claim.claim.claim_id"


def test_atomic_merge_folds_without_data_loss():
    """THE regression: merge must move every product (as subdomain), drop the empty
    source, re-point ALL FKs, and lose ZERO products. Pre-fix this destroyed the
    source's products because the sort ran domain.remove before the moves."""
    ns = _engine()
    D, P, A = _model()
    p_before, a_before = len(P), len(A)
    fk_before = sum(1 for a in A if a["foreign_key_to"])
    applied = _apply(ns, _merge_domain("claimfinancials", "claims"), D, P, A)
    assert applied == 1
    # source domain gone, no products left under it, both products folded under target
    assert "claimfinancials" not in [d["domain"] for d in D]
    assert [p for p in P if p["domain"] == "claimfinancials"] == []
    folded = [p for p in P if p["domain"] == "claims" and p["subdomain"] == "claimfinancials"]
    assert len(folded) == 2, "both claimfinancials products must fold under claims as subdomain"
    # NO DATA LOSS
    assert len(P) == p_before, "merge must not drop any product"
    assert len(A) == a_before, "merge must not drop any attribute"
    assert sum(1 for a in A if a["foreign_key_to"]) == fk_before, "merge must not drop any FK"
    # every FK that referenced the old domain is re-pointed; none dangle
    assert not [a["foreign_key_to"] for a in A
                if a["foreign_key_to"].startswith("claimfinancials.")]
    ext = next(a for a in A if a["attribute"] == "reserve_ref")
    assert ext["foreign_key_to"] == "claims.reserve.reserve_id"


def test_product_move_between_domains_repoints_fks():
    ns = _engine()
    D, P, A = _model()
    applied = _apply(ns, _move_product("claimfinancials.reserve", "other"), D, P, A)
    assert applied == 1
    moved = next(p for p in P if p["product"] == "reserve")
    assert moved["domain"] == "other"
    # its attributes cascaded to the new domain
    assert all(a["domain"] == "other" for a in A if a["product"] == "reserve")
    # external FK into the moved product is re-pointed
    ext = next(a for a in A if a["attribute"] == "reserve_ref")
    assert ext["foreign_key_to"] == "other.reserve.reserve_id"


def test_four_pc_vibes_end_to_end():
    """The user's exact 4 P&C vibes on the small model: 3 renames + 1 merge,
    all applied by the single canonical engine, zero data loss."""
    ns = _engine()
    D, P, A = _model()
    p_before, fk_before = len(P), sum(1 for a in A if a["foreign_key_to"])
    total = 0
    total += _apply(ns, _rename_domain("claims", "claim"), D, P, A)
    total += _apply(ns, _rename_domain("riskexposure", "risk"), D, P, A)
    total += _apply(ns, _merge_domain("claimfinancials", "claim"), D, P, A)
    assert total == 3
    names = sorted(d["domain"] for d in D)
    assert names == ["claim", "other", "risk"]
    assert len(P) == p_before
    assert sum(1 for a in A if a["foreign_key_to"]) == fk_before
    assert not [a for a in A if a["foreign_key_to"].split(".")[0]
                in ("claims", "claimfinancials", "riskexposure")]
