"""
v4.5.5 behavioral test -- v455-glossary-tagprefix-sanitize.

ROOT CAUSE (automotive v2 ECM VOV, origin/regen/v2-automotive-reviewer @ 7847afa,
__AGENT_VERSION__ 4.5.4): the VOV business-context regeneration produced
model_conventions.tag_prefix = "dbx_pii_" -- a reserved SENSITIVITY namespace
EMBEDDED as a segment of the prefix (not the whole token). The authoritative
model.json tagger `_enrich_model_authoritative_tags` builds every derived
governance key as f"{tag_prefix}{key}", so the glossary-term key became
"dbx_pii_business_glossary_term" (16959 hits) and dbx_pii_{subdomain,data_type,
domain,division,association_edges} likewise. The rc6-tagprefix-reserved-clamp
guard only tested the WHOLE stripped prefix for equality against a reserved token
(`_tp.strip().strip("_").lower() in ("pii","phi",...)`), so "dbx_pii_"
(strip("_") -> "dbx_pii") slipped through unclamped.

FIX: a shared segment-level sanitizer `_v455_sanitize_reserved_tag_prefix` strips
ANY reserved sensitivity SEGMENT wherever it appears in the prefix, wired into the
enrich clamp (and the base config-assembly guard). dbx_pii_ -> dbx_, so the
glossary key emits dbx_business_glossary_term.

These tests EXEC the ACTUAL shipped notebook cells (helpers + enrich, not a copy)
and run `_enrich_model_authoritative_tags` end-to-end. They prove fail-pre (the
pre-patch predicate leaves the pii_ segment, and the pre-patch enrich would emit
dbx_pii_business_glossary_term) / pass-post (dbx_business_glossary_term).
"""
import json
import os

import pytest

NB = os.path.join(os.path.dirname(__file__), "..", "..", "agent", "dbx_vibe_modelling_agent.ipynb")


def _cell_src(pred):
    cells = json.load(open(NB))["cells"]
    for c in cells:
        if c["cell_type"] != "code":
            continue
        s = "".join(c["source"]) if isinstance(c["source"], list) else c["source"]
        if pred(s):
            return s
    return None


def _build_namespace():
    """Exec the helper cell (66) then the enrich cell (68) into a shared namespace."""
    import re as _re
    import json as _json
    from notebook_source_util import slice_function_source
    ns = {"re": _re, "json": _json, "_VIBE_SCOPE_RUNTIME": None}
    exec(compile(slice_function_source("get_vibe_scope_runtime"), "<vibe-scope>", "exec"), ns)
    helpers = _cell_src(lambda s: "def _tagset_add" in s and "def _v381_filter_tagset" in s)
    enrich = _cell_src(lambda s: "def _v455_sanitize_reserved_tag_prefix" in s and "def _enrich_model_authoritative_tags" in s)
    assert helpers, "helper cell (tagset helpers) not found"
    assert enrich, "enrich cell (sanitizer + enrich) not found"
    exec(compile(helpers, "<helpers>", "exec"), ns)
    exec(compile(enrich, "<enrich>", "exec"), ns)
    return ns


def _model_with_pii_prefix_config():
    """Minimal model dict + config mirroring the automotive VOV run (tag_prefix=dbx_pii_)."""
    model = {
        "domains": [
            {
                "name": "vehicle_registry",
                "division": "operations",
                "products": [
                    {
                        "name": "vin_registry",
                        "subdomain": "registration",
                        "attributes": [
                            {"name": "vin_registry_id", "business_glossary_term": "Vin Registry Id",
                             "type": "STRING"},
                            {"name": "make", "business_glossary_term": "Make", "type": "STRING"},
                        ],
                    }
                ],
            }
        ]
    }
    config = {"MODEL_CONVENTIONS": {"tag_prefix": "dbx_pii_", "tag_suffix": ""}}
    return model, config


def _glossary_keys(model):
    keys = []
    for d in model.get("domains", []):
        for p in (d.get("products") or d.get("data_products") or []):
            for a in (p.get("attributes") or []):
                for t in (a.get("tag_set") or []):
                    if "business_glossary_term" in str(t.get("key", "")):
                        keys.append(t["key"])
    return keys


def _all_derived_keys(model):
    keys = []
    for d in model.get("domains", []):
        for t in (d.get("tag_set") or []):
            keys.append(t.get("key", ""))
        for p in (d.get("products") or d.get("data_products") or []):
            for t in (p.get("tag_set") or []):
                keys.append(t.get("key", ""))
            for a in (p.get("attributes") or []):
                for t in (a.get("tag_set") or []):
                    keys.append(t.get("key", ""))
    return keys


class TestSanitizerUnit:
    def test_embedded_reserved_segment_stripped(self):
        f = _build_namespace()["_v455_sanitize_reserved_tag_prefix"]
        # The exact automotive failure: dbx_pii_ must sanitize to dbx_.
        assert f("dbx_pii_") == "dbx_"
        # whole-token reserved (the old clamp already handled these) still works
        assert f("pii_") == "dbx_"
        assert f("phi_") == "dbx_"
        assert f("restricted_pii_") == "dbx_"

    def test_legit_prefixes_unchanged(self):
        f = _build_namespace()["_v455_sanitize_reserved_tag_prefix"]
        assert f("dbx_") == "dbx_"
        assert f("acme_") == "acme_"
        assert f("") == ""  # no prefix is valid

    def test_prepatch_predicate_would_miss_embedded(self):
        # Proves the OLD exact-match guard is a false-negative on dbx_pii_.
        tp = "dbx_pii_"
        prepatch_would_clamp = tp.strip().strip("_").lower() in (
            "pii", "phi", "pci", "pi", "gdpr", "sensitive", "confidential", "restricted")
        assert prepatch_would_clamp is False  # <-- the bug: pre-patch does NOT clamp dbx_pii_


class TestEnrichEndToEnd:
    def test_glossary_key_is_canonical_dbx(self):
        ns = _build_namespace()
        model, config = _model_with_pii_prefix_config()
        ns["_enrich_model_authoritative_tags"](model, config, None)
        gkeys = _glossary_keys(model)
        assert gkeys, "no glossary tag_set keys were emitted"
        # pass-post: every glossary key is the canonical dbx_business_glossary_term
        assert all(k == "dbx_business_glossary_term" for k in gkeys), gkeys
        # the corrupt key must be entirely absent (the automotive leak signature)
        assert "dbx_pii_business_glossary_term" not in gkeys

    def test_no_derived_key_carries_pii_segment(self):
        ns = _build_namespace()
        model, config = _model_with_pii_prefix_config()
        ns["_enrich_model_authoritative_tags"](model, config, None)
        derived = _all_derived_keys(model)
        assert derived, "no derived tags emitted"
        leaked = [k for k in derived if k.startswith("dbx_pii_")]
        assert leaked == [], f"reserved pii_ segment leaked into derived governance keys: {leaked}"

    def test_config_writeback_sanitized(self):
        # The clamp must also write the sanitized prefix back to config so the
        # downstream physical UC tagger agrees (defense in depth).
        ns = _build_namespace()
        model, config = _model_with_pii_prefix_config()
        ns["_enrich_model_authoritative_tags"](model, config, None)
        assert config["MODEL_CONVENTIONS"]["tag_prefix"] == "dbx_"
        assert config.get("TAG_PREFIX") == "dbx_"
