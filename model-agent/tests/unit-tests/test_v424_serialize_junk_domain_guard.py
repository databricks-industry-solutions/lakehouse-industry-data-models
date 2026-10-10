"""v4.2.4 behavioral tests -- v424-serialize-junk-domain-guard.

ROOT CAUSE (automotive v2 VOV run <run_id>):
    the final model.json shipped a garbage domain 'partially' with 0 products.
    The v3.5.7 flat junk guard (_v357_reject_junk_domains) + v4.1.3 _cleanup_empty_domains
    run on the FLAT lists at VOV finalize, but the SelfFixer 'missing_domain_description'
    repair runs AFTER finalize and RE-CREATES the removed junk domain ("Locate the domain
    named X, creating it if absent, set a description"), so the resurrection escapes the
    flat guards and ships in the NESTED data_model that model.json is built from (same
    flat<->nested desync class as R8b / v403-serialize-cycle-guard).

FIX: at the AUTHORITATIVE model.json serialization boundary, sweep the NESTED
    data_model['domains'] for junk-named husks (reuse _v357_is_junk_domain_name) AND
    empty (0-product) husks, reassign products off a junk domain to the most-populated
    valid sibling, and drop the husk IN PLACE. User-specified / user-vibed-new domains
    are PROTECTED even when empty (S3b/S3c). Idempotent (clean model = cheap no-op).

These tests extract the ACTUAL shipped function from the notebook cell and exec it in an
isolated namespace (a stand-in _v357_is_junk_domain_name flags the sentinel names; the
real junk-name detection is separately covered by test_v357_marathon_fixes). They prove
the OBSERVABLE state changes the guard produces (S8.10): pre-call the junk domain is
present; post-call it is gone, empty non-protected domains are dropped, protected empty
domains are kept, and products are reassigned to the most-populated valid sibling.
"""
import json
import logging
import os

import pytest

NB = os.path.join(os.path.dirname(__file__), "..", "..", "agent", "dbx_vibe_modelling_agent.ipynb")


def _guard_ns():
    """Extract _v424_reject_junk_empty_domains_in_serialized_model source and exec it
    into an isolated namespace with a stand-in _v357_is_junk_domain_name."""
    cells = json.load(open(NB))["cells"]
    src_concat = "\n".join("".join(c.get("source", [])) for c in cells if c["cell_type"] == "code")
    start = src_concat.find("def _v424_reject_junk_empty_domains_in_serialized_model(")
    assert start != -1, "guard def not found in notebook"
    end = src_concat.find("\ndef ", start + 10)
    fn_src = src_concat[start:end]

    _JUNK = {"partially", "unknown", ""}

    def _stub_is_junk(name):
        return str(name or "").strip().lower() in _JUNK

    ns = {"__name__": "_v424_guard_test", "_v357_is_junk_domain_name": _stub_is_junk, "_VIBE_SCOPE_RUNTIME": None}
    runtime_start = src_concat.find("def get_vibe_scope_runtime(")
    exec(src_concat[runtime_start:src_concat.find("\ndef ", runtime_start + 10)], ns)
    exec(fn_src, ns)
    return ns["_v424_reject_junk_empty_domains_in_serialized_model"]


def _logger():
    lg = logging.getLogger("v424_guard_test")
    lg.setLevel(logging.INFO)
    return lg


def _dm():
    return {
        "domains": [
            {"name": "powertrain", "products": [
                {"product": "engine"}, {"product": "transmission"}]},
            {"name": "partially", "products": []},                 # junk name, empty
            {"name": "unknown", "products": [{"product": "orphan_p"}]},  # junk name, 1 product
            {"name": "ghost", "products": []},                     # empty, NOT protected
            {"name": "future_dim", "products": []},                # empty, PROTECTED (user-vibed)
        ]
    }


class TestGuardDropsJunkAndEmpty:
    def test_junk_and_empty_removed_protected_kept_products_reassigned(self, caplog):
        guard = _guard_ns()
        dm = _dm()
        names_pre = {d["name"] for d in dm["domains"]}
        assert "partially" in names_pre and "unknown" in names_pre and "ghost" in names_pre

        with caplog.at_level(logging.INFO, logger="v424_guard_test"):
            removed = guard(dm, _logger(), protected_domains=["future_dim"])

        names_post = {d["name"] for d in dm["domains"]}
        # junk-named ('partially','unknown') + empty-unprotected ('ghost') dropped = 3
        assert removed == 3, f"expected 3 removed, got {removed}"
        assert "partially" not in names_post
        assert "unknown" not in names_post
        assert "ghost" not in names_post
        # valid + protected-empty survive
        assert "powertrain" in names_post
        assert "future_dim" in names_post
        # the product on junk 'unknown' was reassigned to the most-populated valid sibling
        pt = next(d for d in dm["domains"] if d["name"] == "powertrain")
        prods = {p["product"] for p in pt["products"]}
        assert "orphan_p" in prods, f"orphan product not reassigned: {prods}"
        assert len(pt["products"]) == 3
        assert any("v424-serialize-junk-domain-guard FIRED" in (r.message or "")
                   for r in caplog.records)

    def test_clean_model_is_idempotent_noop(self, caplog):
        guard = _guard_ns()
        clean = {"domains": [
            {"name": "powertrain", "products": [{"product": "engine"}]},
            {"name": "chassis", "products": [{"product": "frame"}]},
        ]}
        before = json.dumps(clean, sort_keys=True)
        removed = guard(clean, _logger(), protected_domains=None)
        assert removed == 0
        assert json.dumps(clean, sort_keys=True) == before

    def test_protected_empty_domain_never_dropped(self):
        guard = _guard_ns()
        dm = {"domains": [
            {"name": "powertrain", "products": [{"product": "engine"}]},
            {"name": "user_wanted", "products": []},  # empty but protected
        ]}
        removed = guard(dm, _logger(), protected_domains=["user_wanted"])
        assert removed == 0
        assert {d["name"] for d in dm["domains"]} == {"powertrain", "user_wanted"}

    def test_data_products_key_variant_supported(self):
        # some layouts use 'data_products' instead of 'products'
        guard = _guard_ns()
        dm = {"domains": [
            {"name": "powertrain", "data_products": [{"product": "engine"}]},
            {"name": "partially", "data_products": []},
        ]}
        removed = guard(dm, _logger(), protected_domains=None)
        assert removed == 1
        assert {d["name"] for d in dm["domains"]} == {"powertrain"}


class TestGuardWiredAtSerializationBoundary:
    def test_guard_called_with_protected_domains_at_serialize(self):
        cells = json.load(open(NB))["cells"]
        src = "\n".join("".join(c.get("source", [])) for c in cells if c["cell_type"] == "code")
        assert "_v424_reject_junk_empty_domains_in_serialized_model(data_model, logger, protected_domains=" in src
        assert "v424-serialize-junk-domain-guard" in src
