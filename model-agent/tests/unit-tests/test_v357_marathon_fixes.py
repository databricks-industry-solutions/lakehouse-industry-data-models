"""Behavioral tests for v3.5.7 root-cause fixes from the v2-marathon GROUND-TRUTH VReq audit.

aliases:
  v357-move-bare-domain-target   (RC1) — move_product extractor handled only 'to X domain'
  v357-preservation-gate         (RC2) — VOV dropped v1 products on rename/move conflicts
  v357-junk-domain-validator     (RC3) — LLM leaked sentinel words ('partially') as domains

Every test exercises the REAL production code extracted from the notebook (not a stub), and the
defect surface lives in a single industry-MIXED synthetic model (healthcare + automotive + retail
+ banking + one junk domain) so the same fixture proves the fixes are INDUSTRY-AGNOSTIC.

Pre-patch proof (§8.10): the old move extractor regex (replicated inline) returns None for the real
'move to <domain>' phrasing, so the deterministic move path used to defer to the flaky LLM sandbox.
"""
import copy
import json
import pathlib
import re
import types

import pytest

from notebook_source_util import vov_ledger_globals

ROOT = pathlib.Path(__file__).resolve().parents[2]
NB_PATH = ROOT / "agent" / "dbx_vibe_modelling_agent.ipynb"
FIX = pathlib.Path(__file__).resolve().parent / "fixtures"


def _read_source() -> str:
    nb = json.loads(NB_PATH.read_text())
    return "\n".join("".join(c.get("source", [])) for c in nb["cells"] if c.get("cell_type") == "code")


SRC = _read_source()


def _extract(start_marker: str, end_marker: str) -> str:
    s = SRC.find(start_marker)
    assert s >= 0, f"marker not found: {start_marker!r}"
    e = SRC.find(end_marker, s + len(start_marker))
    assert e >= 0, f"end marker not found: {end_marker!r}"
    return SRC[s:e]


def _build_ns():
    """Exec the real v337 mutator block + the v337 rename-target helper + the v357 functions."""
    ns = {**vov_ledger_globals(), "re": re, "copy": copy, "_VIBE_SCOPE_RUNTIME": None}
    exec(compile(_extract("def _vibe_scope_note_rename", "\n\ndef "), "<vibe-scope>", "exec"), ns)
    ns["sanitize_name"] = lambda n, strip_stop_words=True: re.sub(r"[^a-z0-9]+", "_", str(n).lower()).strip("_")
    # contiguous block: all _v337 mutator helpers + the v357 functions, ending right before retry
    block = _extract("def _v337_parse_fk_fqn", "def _apply_handler_with_retry(")
    # the rename-target helper lives further down
    rename_helper = _extract("def _v301_extract_rename_target", "\n\ndef ")
    exec(compile(rename_helper, "<v301>", "exec"), ns)
    exec(compile(block, "<v337-v357>", "exec"), ns)
    return ns


NS = _build_ns()


def _logger():
    return types.SimpleNamespace(info=lambda *a, **k: None, warning=lambda *a, **k: None)


def _load(name):
    return json.load(open(FIX / name))


def _flatten(model_json):
    """nested model.json -> (domains_data, products_data, attributes_data) flat lists."""
    dd, pp, aa = [], [], []
    m = model_json.get("model", model_json)
    for d in m.get("domains", []):
        dd.append({"domain": d["name"]})
        for p in (d.get("products") or d.get("data_products") or []):
            pp.append({"domain": d["name"], "product": p["name"]})
            for a in p.get("attributes", []):
                aa.append({"domain": d["name"], "product": p["name"],
                           "attribute": a["name"], "foreign_key_to": a.get("foreign_key_to")})
    return dd, pp, aa


# --------------------------------------------------------------------------- static
def test_v357_version_and_aliases():
    m = re.search(r'__AGENT_VERSION__\s*=\s*"([^"]+)"', SRC)
    assert tuple(int(x) for x in m.group(1).split(".")) >= (3, 5, 7), m.group(1)
    for a in ("v357-move-bare-domain-target", "v357-preservation-gate", "v357-junk-domain-validator"):
        assert a in SRC, f"alias missing: {a}"
    for fired in ("[v357-junk-domain-validator FIRED]", "[v357-preservation-gate FIRED]"):
        assert fired in SRC, f"FIRED sentinel missing: {fired}"


# --------------------------------------------------------------------------- RC1
def _old_extract_move_target(text):
    """The PRE-v3.5.7 extractor (replicated) — proves the root-cause bug existed."""
    t = str(text)
    if re.search(r"\b(?:move[ds]?|moving|relocat\w+|reassign\w*)\b", t, re.I) is None:
        return None
    m = re.search(r"\bto\s+(?:the\s+)?([A-Za-z0-9_]+)\s+domain\b", t, re.I)
    if m:
        return m.group(1)
    m = re.search(r"\bto\s+(?:the\s+)?domain\s+([A-Za-z0-9_]+)", t, re.I)
    if m:
        return m.group(1)
    return None


REAL_PHRASING = [
    "move to merchandising because nameplate is retail master data",
    "move to product because nameplate definitions are SSOT",
    "move to workforce",
    "reassign to inventory because stock is owned there",
]


@pytest.mark.parametrize("phrase", REAL_PHRASING)
def test_v357_rc1_pre_patch_extractor_misses(phrase):
    # PRE-PATCH: the old extractor returns None on the real 'move to <domain>' phrasing.
    assert _old_extract_move_target(phrase) is None


@pytest.mark.parametrize("phrase,expect", [
    ("move to merchandising because nameplate is retail master data", "merchandising"),
    ("move to product because nameplate definitions are SSOT", "product"),
    ("move to workforce", "workforce"),
    ("reassign to inventory because stock is owned there", "inventory"),
    ("move to the finance domain", "finance"),  # legacy form still works
])
def test_v357_rc1_post_patch_extractor_hits(phrase, expect):
    assert NS["_v337_extract_move_target"](phrase) == expect


def test_v357_rc1_full_deterministic_move_applied():
    """End-to-end: a move_product VReq with bare 'move to merchandising' relocates the product
    deterministically (pre-patch this batch deferred to the LLM sandbox -> 'did not move')."""
    model = _load("v357_synthetic_model.json")
    batch = types.SimpleNamespace(
        batch_id="B1", vreq_ids=["P1"],
        data_payload=[{"source_quote": "PRIORITY 1 — move_product: aftersales.nameplate — "
                                       "move to merchandising because nameplate is retail master data"}],
        target_entities=[], intent_summary="",
    )
    new_model, summary = NS["_v337_deterministic_mutate"](batch, model, _logger())
    assert new_model is not None, "deterministic move must APPLY, not defer (RC1)"
    doms = {d["name"]: [p["name"] for p in d["products"]] for d in new_model["model"]["domains"]}
    assert "nameplate" in doms["merchandising"], "product must land in target domain"
    assert "nameplate" not in doms["aftersales"], "product must leave source domain (no duplicate)"


def test_v357_rc1_move_to_nonexistent_domain_defers_safely():
    """A bogus target domain must NOT create a domain (§3b) — the batch defers (returns None)."""
    model = _load("v357_synthetic_model.json")
    batch = types.SimpleNamespace(
        batch_id="B2", vreq_ids=["P9"],
        data_payload=[{"source_quote": "PRIORITY 9 — move_product: aftersales.nameplate — "
                                       "move to nonexistent_domain because reasons"}],
        target_entities=[], intent_summary="",
    )
    new_model, _ = NS["_v337_deterministic_mutate"](batch, model, _logger())
    assert new_model is None, "unknown target domain must defer, never invent a domain"


# --------------------------------------------------------------------------- RC3
def test_v357_rc3_junk_domain_rejected_and_reassigned():
    dd, pp, _ = _flatten(_load("v357_synthetic_model.json"))
    assert any(d["domain"] == "partially" for d in dd)
    n = NS["_v357_reject_junk_domains"](dd, pp, logger=_logger())
    assert n == 1, "exactly one junk domain ('partially') must be dropped"
    assert not any(d["domain"] == "partially" for d in dd), "junk domain removed"
    assert not any(p["domain"] == "partially" for p in pp), "no product left in junk domain"
    # most-populated valid sibling is clinical_care (12)
    moved = [p["product"] for p in pp if p["product"].startswith("orphan_")]
    assert all(next(x["domain"] for x in pp if x["product"] == op) == "clinical_care" for op in moved)


@pytest.mark.parametrize("name,is_junk", [
    ("partially", True), ("unknown", True), ("various", True), ("tbd", True), ("", True),
    ("healthcare", False), ("aftersales", False), ("merchandising", False),
    ("settlement", False), ("clinical_care", False), ("oil_and_gas", False),
])
def test_v357_rc3_industry_terms_never_junk(name, is_junk):
    """INDUSTRY-BIAS PROBE: no real industry/business term may be classified as junk."""
    assert NS["_v357_is_junk_domain_name"](name) is is_junk


# --------------------------------------------------------------------------- RC2
def test_v357_rc2_preservation_restores_dropped_products():
    v1 = _load("v357_synthetic_model.json")
    v2 = _load("v357_synthetic_v2_dropped.json")
    _, v1p, v1a = _flatten(v1)
    dd, pp, aa = _flatten(v2)
    before = {p["product"] for p in pp}
    assert "care_plan" not in before and "cash_flow" not in before, "fixture must start with drops"
    restored = NS["_v357_enforce_product_preservation_flat"](v1p, v1a, dd, pp, aa, logger=_logger())
    after = {p["product"] for p in pp}
    assert restored == 2, f"both dropped v1 products must be restored, got {restored}"
    assert {"care_plan", "cash_flow"} <= after, "specific dropped products restored per §3b"
    # attributes of restored products also come back
    assert any(a["product"] == "care_plan" for a in aa)


def test_v357_rc2_no_restore_when_nothing_dropped():
    v1 = _load("v357_synthetic_model.json")
    _, v1p, v1a = _flatten(v1)
    dd, pp, aa = _flatten(v1)  # v2 == v1, nothing dropped
    restored = NS["_v357_enforce_product_preservation_flat"](v1p, v1a, dd, pp, aa, logger=_logger())
    assert restored == 0, "a complete model must not trigger any restore (no false positives)"


def test_v357_rc2_prefix_rename_not_falsely_restored():
    """If a v1 product was renamed with a domain prefix (nameplate -> aftersales_nameplate),
    preservation must treat it as accounted (no duplicate restore)."""
    v1 = _load("v357_synthetic_model.json")
    _, v1p, v1a = _flatten(v1)
    dd, pp, aa = _flatten(v1)
    for p in pp:
        if p["product"] == "nameplate":
            p["product"] = "aftersales_nameplate"  # simulate applied prefix-rename
    restored = NS["_v357_enforce_product_preservation_flat"](v1p, v1a, dd, pp, aa, logger=_logger())
    assert restored == 0, "prefix-renamed product must not be falsely restored"


# --------------------------------------------------------------------------- industry-bias (cross-domain invariance)
def test_v357_industry_bias_move_works_for_every_domain_pair():
    """The move fix must work identically no matter which industry domain is source/target."""
    model = _load("v357_synthetic_model.json")
    pairs = [("clinical_care", "settlement"), ("settlement", "merchandising"),
             ("merchandising", "clinical_care"), ("aftersales", "settlement")]
    for src, dst in pairs:
        m = copy.deepcopy(model)
        src_prod = m["model"]["domains"][[d["name"] for d in m["model"]["domains"]].index(src)]["products"][0]["name"]
        batch = types.SimpleNamespace(
            batch_id="BX", vreq_ids=["PX"],
            data_payload=[{"source_quote": f"PRIORITY 1 — move_product: {src}.{src_prod} — move to {dst} because test"}],
            target_entities=[], intent_summary="",
        )
        nm, _ = NS["_v337_deterministic_mutate"](batch, m, _logger())
        assert nm is not None, f"move {src}->{dst} must apply"
        doms = {d["name"]: [p["name"] for p in d["products"]] for d in nm["model"]["domains"]}
        assert src_prod in doms[dst] and src_prod not in doms[src], f"move {src}->{dst} failed"


if __name__ == "__main__":
    import sys
    sys.exit(pytest.main([__file__, "-v"]))
