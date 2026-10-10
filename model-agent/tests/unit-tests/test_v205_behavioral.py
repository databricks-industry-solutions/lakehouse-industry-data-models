"""Behavioral tests for v205 F1-F6 fixes.

Static-grep contracts cover sentinel presence; behavioral tests cover the
runtime effect (deterministic overcount trim, post-cycle-purge, partial-credit
precision, mutation-lock injection, F1-F4 observability via logger.info).
"""

from __future__ import annotations

import json
import logging
import re
from pathlib import Path

import pytest


NB_PATH = Path(__file__).resolve().parents[2] / "agent" / "dbx_vibe_modelling_agent.ipynb"


def _read_nb_src() -> str:
    nb = json.loads(NB_PATH.read_text())
    return "\n".join("".join(c.get("source", [])) for c in nb["cells"])


@pytest.fixture(scope="module")
def src() -> str:
    return _read_nb_src()


def test_v205_version_bumped(src: str):
    """v205 introduced the F1-F6 fix set. Subsequent versions are
    supersets — the version constant just needs to be >= 2.0.5."""
    m = re.search(r'__AGENT_VERSION__\s*=\s*"(\d+)\.(\d+)\.(\d+)"', src)
    assert m, "no __AGENT_VERSION__ found"
    major, minor, patch = int(m.group(1)), int(m.group(2)), int(m.group(3))
    triple = (major, minor, patch)
    assert triple >= (2, 0, 5), f"expected >= 2.0.5, got {major}.{minor}.{patch}"


def test_v205_f1_observability_aliases_log_emit(src: str):
    for fired in [
        "v204-verifier-stripped FIRED",
        "v204-mv-preservation-invariant FIRED",
        "v204-ast-class-hint FIRED",
        "v204-pinned-domains-in-prompt FIRED",
    ]:
        pattern = rf'logger\.info\([^)]*{re.escape(fired)}'
        assert re.search(pattern, src), f"no logger.info(...) emission for [{fired}]"


def test_v205_f2_schema_threaded_through_all_call_sites(src: str):
    for sentinel in [
        "v205-schema-thread-through-tools-fallback",
        "v205-outline-schema",
        "v205-extraction-schema",
        "v205-dedupe-schema",
        "v205-batching-schema",
    ]:
        assert sentinel in src, f"missing F2 sentinel {sentinel}"
    assert "def complete_with_tools(self, system, user, tools, tool_handlers,\n                            max_iters=6, temperature=0.0, response_schema=None):" in src \
        or "response_schema=None" in src, "complete_with_tools must accept response_schema kwarg"


def test_v205_f3_final_cycle_purge_function_defined_and_invoked(src: str):
    assert "def _v205_purge_residual_cycles_deterministically" in src
    assert "_v205_purge_residual_cycles_deterministically(attributes_data, products_data, logger)" in src
    assert "v205-final-cycle-purge" in src


def test_v205_f3_purge_runs_and_emits_alias(caplog):
    """The deterministic purge removes exactly 1 FK per simulated cycle and
    emits v205-final-cycle-purge. Mocks _detect_cycles_dfs so the test doesn't
    depend on the full cycle-detection helper chain."""
    nb = json.loads(NB_PATH.read_text())
    src_concat = "\n".join("".join(c.get("source", [])) for c in nb["cells"])

    def_start = src_concat.find("def _v205_purge_residual_cycles_deterministically")
    assert def_start != -1
    def_end = src_concat.find("\ndef ", def_start + 10)
    purge_src = src_concat[def_start:def_end]

    # The purge routine factors its cycle-edge derivation through the module-level
    # helper _cycle_to_edges (agent nb ~L54108). Extract + exec it into the same
    # isolated namespace so this test exercises the REAL function chain rather than
    # NameError-ing on a legitimate helper dependency (test-isolation fragility, not
    # a production bug — _cycle_to_edges is defined at module scope in the notebook).
    def _extract_def(name: str) -> str:
        s = src_concat.find(f"def {name}(")
        assert s != -1, f"helper def {name} not found in notebook source"
        e = src_concat.find("\ndef ", s + 10)
        return src_concat[s:e]

    # Build a mock _detect_cycles_dfs that returns the cycle on first call and []
    # thereafter (simulating successful purge).
    # Cycle is a list of NODE strings (matching _detect_cycles_dfs return shape).
    call_box = {"n": 0, "synthetic_cycle": ["a.p", "b.q", "c.r"]}

    def mock_detect_cycles_dfs(products_data, attributes_data, logger):
        call_box["n"] += 1
        # After we've removed at least 1 FK matching the cycle edge, return no cycles.
        for a in attributes_data:
            fk = a.get("foreign_key_to") or ""
            if a.get("domain") == "c" and a.get("product") == "r" and fk.startswith("a.p."):
                return [call_box["synthetic_cycle"]]
        return []

    from notebook_source_util import pk_predicate_globals

    ns = {"__name__": "_v205_test", **pk_predicate_globals()}
    ns["_detect_cycles_dfs"] = mock_detect_cycles_dfs
    exec(_extract_def("_cycle_to_edges"), ns)
    exec(purge_src, ns)

    products = [
        {"domain": "a", "product": "p", "primary_key": "p_id"},
        {"domain": "b", "product": "q", "primary_key": "q_id"},
        {"domain": "c", "product": "r", "primary_key": "r_id"},
    ]
    attrs = [
        {"domain": "a", "product": "p", "attribute": "q_id", "foreign_key_to": "b.q.q_id"},
        {"domain": "b", "product": "q", "attribute": "r_id", "foreign_key_to": "c.r.r_id"},
        {"domain": "c", "product": "r", "attribute": "p_id", "foreign_key_to": "a.p.p_id"},
    ]

    test_logger = logging.getLogger("v205_purge_test")
    test_logger.setLevel(logging.INFO)
    with caplog.at_level(logging.INFO, logger="v205_purge_test"):
        purged = ns["_v205_purge_residual_cycles_deterministically"](attrs, products, test_logger)
    assert purged >= 1, f"expected at least 1 FK purged, got {purged}"
    # The c.r.p_id FK (lex-max src.tgt of {a.p->b.q, b.q->c.r, c.r->a.p}) must be removed.
    remaining_fks = [(a["domain"], a["product"], a.get("foreign_key_to")) for a in attrs]
    assert ("c", "r", "a.p.p_id") not in remaining_fks, f"c.r.p_id should have been purged; remaining: {remaining_fks}"
    assert any("v205-final-cycle-purge" in (r.message or "") for r in caplog.records), \
        "no v205-final-cycle-purge log line emitted"


def test_v205_f4_overcount_trim_in_source(src: str):
    assert "v205-deterministic-overcount-trim" in src
    assert "_overage <= 3" in src or "_overage = len(products) - max_products" in src
    assert "v205-deterministic-overcount-trim FIRED" in src


def test_v205_f5_partial_credit_precision():
    """build_fidelity_scorecard should reward partial fulfilment proportionally."""
    nb = json.loads(NB_PATH.read_text())
    full = "\n".join("".join(c.get("source", [])) for c in nb["cells"])
    start = full.find("def build_fidelity_scorecard(")
    end = full.find("\ndef ", start + 10)
    fn_src = full[start:end]
    ns: dict = {"hashlib": __import__("hashlib")}
    exec(fn_src, ns)
    fn = ns["build_fidelity_scorecard"]

    reqs = [
        {"status": "fulfilled"},
        {"status": "fulfilled"},
        {"status": "fulfilled"},
        {"status": "partially_fulfilled"},
        {"status": "partially_fulfilled"},
        {"status": "not_fulfilled"},
    ]
    score = fn(reqs, [])
    expected = (3 + 0.7 * 2) / 6
    assert abs(score["precision"] - expected) < 1e-6, \
        f"expected precision {expected:.4f}, got {score['precision']:.4f}"
    assert "v205-fidelity-partial-credit" in fn_src


def test_v205_f6_immutable_lock_injection_in_source(src: str):
    assert "v205-immutable-mutation-lock FIRED" in src
    assert "v205-ALL_MUTATIONS_FORBIDDEN" in src
    assert "v205 MUTATION LOCK v205" in src


def test_v205_synth_schema_still_required_only_two_fields(src: str):
    m = re.search(r'"required":\s*\["mutator_source",\s*"expected_changes_summary"\]', src)
    assert m, "synth _synth_schema required keys must be exactly mutator_source + expected_changes_summary (no verifier_source)"
    assert "_synth_schema" in src
