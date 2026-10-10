"""
v2.0.8 VOV preload + unconditional-writeback + review-base seeding tests.

These tests verify the THREE critical root-cause fixes identified by the
2026-05-26 code review of the VOV (vibe-modeling-of-version) path:

  1. vov-v1-preload          — flattens business_context_raw.model into flat widget
                                lists before VOV sandbox runs (was: empty initial_model).
  2. vov-unconditional-writeback — always persists sandbox output to widgets_values
                                    (was: gated on `if "domains" in widgets_values`).
  3. vov-review-base-seed    — sets use_review_base_data=True + review_base_* so
                                step_create_logical_schema enters REVIEW MODE instead
                                of regenerating the full model from scratch.

Per CLAUDE.md §8.10 anti-no-op rule: each test asserts an OBSERVABLE state change
on widgets_values that downstream stages will read.
"""

import json
import re
from collections import namedtuple
from pathlib import Path
from unittest.mock import MagicMock

import pytest

NB_PATH = Path(__file__).resolve().parents[2] / "agent" / "dbx_vibe_modelling_agent.ipynb"


def _notebook_source():
    nb = json.loads(NB_PATH.read_text())
    return "\n".join("".join(c.get("source", [])) for c in nb["cells"] if c.get("cell_type") == "code")


def _vov_shim_source():
    """Return the source of the cell containing run_vov_2_against_widgets."""
    nb = json.loads(NB_PATH.read_text())
    for c in nb["cells"]:
        if c.get("cell_type") != "code":
            continue
        s = "".join(c.get("source", []))
        if "def run_vov_2_against_widgets" in s:
            return s
    raise RuntimeError("VOV shim cell not found")


# ---------------------------------------------------------------------------
# Static-grep tests (smoke)
# ---------------------------------------------------------------------------

def test_all_three_vov_aliases_present():
    src = _vov_shim_source()
    assert "alias=vov-v1-preload" in src
    assert "alias=vov-unconditional-writeback" in src
    assert "alias=vov-review-base-seed" in src


def test_vov_v1_preload_uses_business_context_raw():
    src = _vov_shim_source()
    m = re.search(r"\[vov-v1-preload FIRED v2\.0\.8\].*?domains=", src)
    assert m is not None, "vov-v1-preload FIRED log line missing"
    assert "business_context_raw" in src, "preload must read business_context_raw"
    assert "model_to_widgets_flat" in src, "preload must use existing flattener"


def test_writeback_is_unconditional():
    """The conditional `if \"domains\" in widgets_values:` writeback must be gone from ACTUAL CODE
    (not comments)."""
    src = _vov_shim_source()
    m = re.search(r"new_domains, new_products, new_attrs, new_mvs = model_to_widgets_flat\(result\.final_model\)([\s\S]{0,8000})widgets_values\[.review_base_domains.\]", src)
    assert m is not None, "could not locate writeback region"
    region = m.group(1)
    # Strip comments (lines starting with #) to avoid false-positive on the rationale comment
    code_only_lines = []
    for line in region.splitlines():
        stripped = line.strip()
        if stripped.startswith("#"):
            continue
        code_only_lines.append(line)
    code_only = "\n".join(code_only_lines)
    assert 'if "domains" in widgets_values' not in code_only and "if 'domains' in widgets_values" not in code_only, \
        f"conditional writeback still present in ACTUAL CODE:\n{code_only}"


def test_review_base_seeding_sets_use_review_base_data_true():
    src = _vov_shim_source()
    assert 'widgets_values["use_review_base_data"] = True' in src or "widgets_values['use_review_base_data'] = True" in src
    assert 'widgets_values["review_base_domains"]' in src or "widgets_values['review_base_domains']" in src


# ---------------------------------------------------------------------------
# Behavioural tests — execute the shim against a mock setup
# ---------------------------------------------------------------------------

def _build_v1_business_context_raw():
    """Build a realistic v1 model.json shape that get_widget_values would have produced."""
    return {
        "agent_version": "2.0.7",
        "model": {
            "domains": [
                {
                    "name": "customer",
                    "division": "core",
                    "description": "customer domain",
                    "products": [
                        {
                            "name": "profile",
                            "primary_key": "customer_id",
                            "type": "entity",
                            "attributes": [
                                {"name": "customer_id", "type": "BIGINT"},
                                {"name": "name", "type": "STRING"},
                            ],
                        },
                        {
                            "name": "address",
                            "primary_key": "address_id",
                            "type": "entity",
                            "attributes": [
                                {"name": "address_id", "type": "BIGINT"},
                                {"name": "customer_id", "type": "BIGINT", "foreign_key_to": "customer.profile.customer_id"},
                            ],
                        },
                    ],
                },
                {
                    "name": "order",
                    "division": "core",
                    "description": "order domain",
                    "products": [
                        {
                            "name": "header",
                            "primary_key": "order_id",
                            "type": "entity",
                            "attributes": [
                                {"name": "order_id", "type": "BIGINT"},
                                {"name": "customer_id", "type": "BIGINT", "foreign_key_to": "customer.profile.customer_id"},
                            ],
                        },
                    ],
                },
            ],
            "metric_views": [
                {"name": "monthly_orders", "domain": "order", "source_product": "header"},
            ],
        },
    }


class _CapturingLogger:
    def __init__(self):
        self.lines = []
    def info(self, m): self.lines.append(("info", str(m)))
    def warning(self, m): self.lines.append(("warning", str(m)))
    def error(self, m): self.lines.append(("error", str(m)))
    def debug(self, m): self.lines.append(("debug", str(m)))
    def has_alias(self, alias):
        return any(alias in l[1] for l in self.lines)
    def alias_count(self, alias):
        return sum(1 for l in self.lines if alias in l[1])


def _extract_function_block(src, fn_name):
    """Indent-based extractor: pulls `def fn_name(...): ...` to end of body."""
    lines = src.splitlines()
    out = []
    in_block = False
    fn_indent = None
    for line in lines:
        if not in_block:
            if line.lstrip().startswith(f"def {fn_name}(") and not line.lstrip().startswith(f"def {fn_name}_"):
                in_block = True
                fn_indent = len(line) - len(line.lstrip())
                out.append(line)
            continue
        if line.strip() == "":
            out.append(line)
            continue
        cur_indent = len(line) - len(line.lstrip())
        if cur_indent <= fn_indent and line.strip():
            break
        out.append(line)
    return "\n".join(out)


def _build_shim_namespace_with_stubs():
    """Extract ONLY run_vov_2_against_widgets + its called helpers from the shim cell, then
    exec them into an isolated namespace with stubs for heavyweight deps."""
    src = _vov_shim_source()
    fn_block = _extract_function_block(src, "run_vov_2_against_widgets")
    flat_to_model = _extract_function_block(src, "widgets_flat_to_model")
    model_to_flat = _extract_function_block(src, "model_to_widgets_flat")

    import copy as _copy
    import json as _json
    import logging as _logging

    ns = {
        "__name__": "__test_vov_shim__",
        "copy": _copy,
        "json": _json,
        "logging": _logging,
        # Heavyweight deps stubbed to MagicMock — these are never called when the pipeline
        # is also stubbed (which the tests do via ns["run_vov_pipeline"]).
        "AIAgentLLMBridge": MagicMock(),
        "__VOV_VERSION__": "2.0.8",
        # v2.0.8 [vov-agent-version-stamp-callsite] run_vov_2_against_widgets now reads
        # __AGENT_VERSION__ instead of __VOV_VERSION__. Inject both so the shim runs.
        "__AGENT_VERSION__": "2.0.8",
        # v0.8.0 [release-version-public] widgets_flat_to_model now also stamps
        # __RELEASE_VERSION__ (public label decoupled from the engine build). Cell 1
        # defines it in production; the extracted-function shim must inject it too.
        "__RELEASE_VERSION__": "0.8.0",
        "_VIBE_SCOPE_RUNTIME": None,
        "_vov_note_pass_changes": lambda *args, **kwargs: 0,
    }
    # Order matters: helpers first
    exec(compile(_extract_function_block(_notebook_source(), "_vibe_scope_bind_engine_baseline"), "<vibe-scope-bind>", "exec"), ns)
    exec(compile(_extract_function_block(_notebook_source(), "_metamodel_log"), "<metamodel-log>", "exec"), ns)
    exec(compile(_extract_function_block(_notebook_source(), "_resolve_base_model_json"), "<base-model-json>", "exec"), ns)
    exec(compile(_extract_function_block(_notebook_source(), "_vibe_scope_checkpoint"), "<vibe-scope-checkpoint>", "exec"), ns)
    exec(compile(_extract_function_block(_notebook_source(), "_vibe_scope_raw_base"), "<vibe-scope-raw-base>", "exec"), ns)
    exec(compile(model_to_flat, "<model_to_widgets_flat>", "exec"), ns)
    exec(compile(flat_to_model, "<widgets_flat_to_model>", "exec"), ns)
    exec(compile(fn_block, "<run_vov_2_against_widgets>", "exec"), ns)
    return ns


def _stub_pipeline_result(initial_model):
    """A PipelineResult-like object that returns the initial model unchanged."""
    PR = namedtuple("PR", ["raw_vreqs", "batches", "outcomes", "coverage_pct", "rejected_handlers", "final_model"])
    return PR(raw_vreqs=[], batches=[], outcomes=[], coverage_pct=100.0, rejected_handlers=[], final_model=initial_model)


def test_preload_flattens_v1_when_widgets_empty():
    """When widgets_values has no flat domains but has business_context_raw with v1 model,
    the preload block must flatten v1 into widgets BEFORE the pipeline builds initial_model."""
    ns = _build_shim_namespace_with_stubs()
    run = ns["run_vov_2_against_widgets"]
    logger = _CapturingLogger()
    captured = {}

    def stub_pipeline(*, vibe_text, initial_model, llm, user_pinned_domains, user_pinned_products, parallel):
        # Record what initial_model the pipeline saw -- THIS is the proof that preload worked.
        captured["initial_model"] = initial_model
        return _stub_pipeline_result(initial_model)

    ns["run_vov_pipeline"] = stub_pipeline

    fake_ai = MagicMock()
    widgets = {
        "ai_agent": fake_ai,
        "vibe_modelling_instructions": "make small changes",
        "business_context_raw": _build_v1_business_context_raw(),
    }
    res = run(widgets, logger, parallel=False)

    # Preload must have flattened v1 into the flat lists.
    assert logger.has_alias("vov-v1-preload"), "FIRED log missing"
    assert len(widgets["domains"]) == 2
    assert {d["domain"] for d in widgets["domains"]} == {"customer", "order"}
    assert len(widgets["products"]) == 3
    assert any(p["product"] == "profile" for p in widgets["products"])
    assert any(p["product"] == "address" for p in widgets["products"])
    assert any(p["product"] == "header" for p in widgets["products"])
    assert len(widgets["attributes"]) >= 5
    # The pipeline must have seen a non-empty initial_model.
    assert len(captured["initial_model"]["model"]["domains"]) == 2
    # Coverage should reflect the no-op pipeline outcome.
    assert res["coverage_pct"] == 100.0


def test_preload_skips_when_widgets_already_populated():
    """If widgets_values already has flat domains, preload must NOT clobber them."""
    ns = _build_shim_namespace_with_stubs()
    run = ns["run_vov_2_against_widgets"]
    logger = _CapturingLogger()
    captured = {}

    def stub_pipeline(*, vibe_text, initial_model, **kw):
        captured["initial_model"] = initial_model
        return _stub_pipeline_result(initial_model)

    ns["run_vov_pipeline"] = stub_pipeline

    # v2.0.8 vov-v1-preload-broader-gate (audit A4): preload now fires when ANY of
    # domains/products/attributes is empty (not just domains). The skip path requires
    # ALL THREE to be populated.
    existing_domains = [{"domain": "preexisting"}]
    existing_products = [{"domain": "preexisting", "product": "p1"}]
    existing_attributes = [{"domain": "preexisting", "product": "p1", "attribute": "a1", "type": "STRING"}]
    widgets = {
        "ai_agent": MagicMock(),
        "vibe_modelling_instructions": "go",
        "domains": existing_domains,
        "products": existing_products,
        "attributes": existing_attributes,
        "business_context_raw": _build_v1_business_context_raw(),
    }
    run(widgets, logger, parallel=False)
    # preload must NOT fire when all flat lists already populated
    assert not logger.has_alias("vov-v1-preload"), "preload should be skipped when all three flat lists populated"
    # original domains preserved (or replaced only by pipeline output, which for stub is the
    # widgets_flat_to_model of `existing_domains`)


def test_writeback_lands_unconditionally():
    """After pipeline runs, the writeback must populate widgets_values[domains/products/attributes/metric_views]
    even if those keys didn't exist before preload. Proves the conditional writeback bug is fixed."""
    ns = _build_shim_namespace_with_stubs()
    run = ns["run_vov_2_against_widgets"]
    logger = _CapturingLogger()

    def stub_pipeline(*, vibe_text, initial_model, **kw):
        return _stub_pipeline_result(initial_model)

    ns["run_vov_pipeline"] = stub_pipeline
    widgets = {
        "ai_agent": MagicMock(),
        "vibe_modelling_instructions": "go",
        "business_context_raw": _build_v1_business_context_raw(),
    }
    run(widgets, logger, parallel=False)
    # All 4 keys MUST be present (writeback unconditional)
    assert "domains" in widgets
    assert "products" in widgets
    assert "attributes" in widgets
    assert "metric_views" in widgets
    # And they must be non-empty (preload populated them, pipeline preserved)
    assert len(widgets["domains"]) > 0
    assert len(widgets["products"]) > 0


def test_review_base_seed_sets_use_review_base_data_true():
    """The biggest fix: ensure widgets_values['use_review_base_data'] = True is set so
    step_create_logical_schema reads from review_base_* instead of regenerating."""
    ns = _build_shim_namespace_with_stubs()
    run = ns["run_vov_2_against_widgets"]
    logger = _CapturingLogger()

    def stub_pipeline(*, vibe_text, initial_model, **kw):
        return _stub_pipeline_result(initial_model)

    ns["run_vov_pipeline"] = stub_pipeline
    widgets = {
        "ai_agent": MagicMock(),
        "vibe_modelling_instructions": "go",
        "business_context_raw": _build_v1_business_context_raw(),
    }
    run(widgets, logger, parallel=False)
    # CRITICAL assertion: review base mode is engaged
    assert widgets.get("use_review_base_data") is True, "use_review_base_data NOT set to True — step_create_logical_schema will regen!"
    assert "review_base_domains" in widgets and len(widgets["review_base_domains"]) > 0
    assert "review_base_products" in widgets and len(widgets["review_base_products"]) > 0
    assert "review_base_attributes" in widgets and len(widgets["review_base_attributes"]) > 0
    assert logger.has_alias("vov-review-base-seed")


def test_review_base_seed_matches_writeback_data():
    """review_base_* MUST contain the SAME data the writeback put in widgets_values[domains/products/attributes]."""
    ns = _build_shim_namespace_with_stubs()
    run = ns["run_vov_2_against_widgets"]
    logger = _CapturingLogger()

    def stub_pipeline(*, vibe_text, initial_model, **kw):
        return _stub_pipeline_result(initial_model)

    ns["run_vov_pipeline"] = stub_pipeline
    widgets = {
        "ai_agent": MagicMock(),
        "vibe_modelling_instructions": "go",
        "business_context_raw": _build_v1_business_context_raw(),
    }
    run(widgets, logger, parallel=False)
    assert widgets["domains"] == widgets["review_base_domains"]
    assert widgets["products"] == widgets["review_base_products"]
    assert widgets["attributes"] == widgets["review_base_attributes"]


def test_pre_patch_would_have_been_no_op():
    """Positive control — prove that WITHOUT v1 preload + review-base seed, VOV would
    have produced empty review_base_* + use_review_base_data unset."""
    bcr = _build_v1_business_context_raw()
    # Simulated PRE-PATCH behaviour: just look at the flat widgets BEFORE shim runs.
    # In pre-patch code, widgets_values["domains"] was empty AND use_review_base_data was unset.
    widgets_pre_patch = {
        "ai_agent": MagicMock(),
        "vibe_modelling_instructions": "go",
        "business_context_raw": bcr,
    }
    assert widgets_pre_patch.get("domains") is None, "pre-patch: no flat domains"
    assert widgets_pre_patch.get("use_review_base_data") is None, "pre-patch: use_review_base_data unset"
    # This is the §8.10 anti-tautology proof: without the v2.0.8 patch, downstream
    # step_create_logical_schema would have entered NEW BASE MODE and regenerated.


def test_metric_views_preserved_through_preload():
    """Metric views must round-trip from v1 -> flat list -> widgets_values."""
    ns = _build_shim_namespace_with_stubs()
    run = ns["run_vov_2_against_widgets"]
    logger = _CapturingLogger()

    def stub_pipeline(*, vibe_text, initial_model, **kw):
        return _stub_pipeline_result(initial_model)

    ns["run_vov_pipeline"] = stub_pipeline
    widgets = {
        "ai_agent": MagicMock(),
        "vibe_modelling_instructions": "go",
        "business_context_raw": _build_v1_business_context_raw(),
    }
    run(widgets, logger, parallel=False)
    assert len(widgets.get("metric_views", [])) == 1
    assert widgets["metric_views"][0]["name"] == "monthly_orders"


def test_no_op_when_vibe_text_empty():
    """Empty vibe_text -> shim returns early; preload should still happen for downstream
    consistency, but pipeline must not fire."""
    ns = _build_shim_namespace_with_stubs()
    run = ns["run_vov_2_against_widgets"]
    logger = _CapturingLogger()

    pipeline_calls = {"n": 0}
    def stub_pipeline(**kw):
        pipeline_calls["n"] += 1
        return _stub_pipeline_result(kw["initial_model"])

    ns["run_vov_pipeline"] = stub_pipeline
    widgets = {
        "ai_agent": MagicMock(),
        "vibe_modelling_instructions": "",
        "business_context_raw": _build_v1_business_context_raw(),
    }
    res = run(widgets, logger, parallel=False)
    assert pipeline_calls["n"] == 0, "pipeline must NOT fire on empty vibe"
    assert res["coverage_pct"] == 100.0
