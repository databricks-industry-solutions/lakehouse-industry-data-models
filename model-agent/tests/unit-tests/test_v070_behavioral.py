"""Behavioral tests for v0.7.0 — three root-cause fixes from v0.6.9 telecom VOV audit.

Fixes shipped:
  1. vov-metrics-teardown   — `_early_clash_detection` drops `_metrics` schema
                              along with domain schemas on shrink/enlarge/VOV
                              start, eliminating the zombie-metric-view window
                              that left v1 views pointing at dropped tables.
  2. mv-measure-agg-wrap    — `_sanitize_metric_measure_expr` final guard wraps
                              any measure expression with zero aggregate calls
                              in `SUM(CAST(... AS DOUBLE))` (or COUNT(1) when
                              unsafe), eliminating METRIC_VIEW_MISSING_MEASURE_FUNCTION.
  3. step-boundary-flush    — `_log_step_start`/`_log_step_end` force-flush all
                              logger handlers AND raw-write a `[STEP-BOUNDARY]`
                              sentinel directly to the local INFO log, so step
                              transitions remain visible even if the Python
                              logger handler dies mid-run (R3 NEW SITE in
                              v0.6.9 telecom VOV: 50-min run captured only
                              first 25 min of INFO via volume mirror).

Aliases under test:
  - vov-metrics-teardown
  - mv-measure-agg-wrap
  - step-boundary-flush
  - agent-version-global   (re-asserted at 0.7.0)
  - agent-version-mirror   (re-asserted at 0.7.0)
"""

import ast
import json
import re
import textwrap
from pathlib import Path

AGENT = Path(__file__).resolve().parents[2] / "agent" / "dbx_vibe_modelling_agent.ipynb"
README = Path(__file__).resolve().parents[2] / "readme.md"

EXPECTED_VERSION = "4.2.7"  # engine build (__AGENT_VERSION__); public release label is __RELEASE_VERSION__ = 0.8.0


def _agent_cells():
    with AGENT.open() as f:
        nb = json.load(f)
    return nb.get("cells", [])


def _cell_source(cell):
    src = cell.get("source", "")
    return "".join(src) if isinstance(src, list) else src


def _agent_text():
    return "\n".join(_cell_source(c) for c in _agent_cells())


def _first_code_cell_source():
    for c in _agent_cells():
        if c.get("cell_type") == "code":
            s = _cell_source(c)
            if s.strip():
                return s
    raise AssertionError("No non-empty code cell found in agent notebook")


def _agent_text_for_grep():
    return _agent_text()


def test_v070_constant_bumped_to_expected():
    txt = _agent_text()
    m = re.search(r'__AGENT_VERSION__\s*=\s*"([^"]+)"', txt)
    assert m is not None, "__AGENT_VERSION__ constant not found"
    assert m.group(1) == EXPECTED_VERSION, (
        f"__AGENT_VERSION__ '{m.group(1)}' != expected '{EXPECTED_VERSION}'"
    )


def test_v070_constant_first_line_of_cell1_unchanged():
    src = _first_code_cell_source()
    code_lines = [
        ln for ln in src.splitlines()
        if ln.strip() and not ln.lstrip().startswith("#")
    ]
    assert code_lines and code_lines[0].startswith("__AGENT_VERSION__"), (
        f"First non-comment line in Cell 1 must be __AGENT_VERSION__; got: {code_lines[0]!r}"
    )


def test_v070_constant_single_digit_semver():
    assert re.fullmatch(r"\d\.\d\.\d", EXPECTED_VERSION), (
        f"EXPECTED_VERSION '{EXPECTED_VERSION}' violates §3a single-digit semver"
    )


# ============================================================================
# Fix 1: vov-metrics-teardown — _metrics dropped on shrink/enlarge/VOV start.
# ============================================================================


def test_v070_fix1_alias_present():
    txt = _agent_text_for_grep()
    assert "vov-metrics-teardown" in txt, (
        "vov-metrics-teardown alias not found in agent — Fix 1 sentinel missing"
    )


def test_v070_fix1_metrics_schema_is_never_dropped_after_decision_12a():
    """v5.1.4 decision 12A: `_metrics` is shared by every business in the catalog, so the
    teardown never drops the schema; only the base version's own metric views are dropped."""
    txt = _agent_text_for_grep()
    m = re.search(
        r'_SCHEMA_OWNERSHIP_INTERNAL\s*=\s*frozenset\(\{([^}]+)\}\)',
        txt,
    )
    assert m is not None, "_SCHEMA_OWNERSHIP_INTERNAL set not found"
    members = m.group(1)
    for schema in ("_metrics", "_metamodel"):
        assert f'"{schema}"' in members or f"'{schema}'" in members, (
            f"_SCHEMA_OWNERSHIP_INTERNAL must keep {schema}: {members}"
        )


def test_v070_fix1_logger_emits_metrics_drop_count():
    """The new logger.info must report _metrics= and domain= drop counts on the one emitted FIRED line."""
    import test_v514_schema_ownership_teardown as own
    own.ah.set_vibe_scope_runtime(None)
    log = own._Log()
    own.ah._early_clash_detection(own._spark(own.ALL_SCHEMAS, *own._stale_history()), own._config(), own._vov_wv(), log)
    fired = [msg for _, msg in log.lines if "[vov-metrics-teardown FIRED]" in msg]
    assert len(fired) == 1 and "domain=2" in fired[0] and "_metrics=1" in fired[0], (
        f"Fix 1 log line must include domain= and _metrics= counts for grep auditing: {fired}"
    )


# ============================================================================
# Fix 2: mv-measure-agg-wrap — measures missing aggregate get wrapped.
# ============================================================================


def _extract_sanitize_metric_measure_expr_source():
    """Pull the textual source of _sanitize_metric_measure_expr from the notebook,
    plus its dependencies, and return a runnable namespace."""
    txt = _agent_text_for_grep()
    # Locate the function and the supporting helpers in the same cell.
    needed = [
        "_AGG_CALL_RE",
        "_METRIC_AGG_FUNCS_RE",
        "_NESTED_AGG_PATTERN",
        "_count_metric_aggregate_calls",
        "_is_safe_aggregate_ratio",
        "_split_top_level_add_sub",
        "_rewrite_multi_sum_to_single_sum",
        "_has_nested_aggregate_depth_aware",
        "_sanitize_metric_measure_expr",
    ]
    return txt, needed


def test_v070_fix2_alias_present():
    txt = _agent_text_for_grep()
    assert "mv-measure-agg-wrap" in txt, (
        "mv-measure-agg-wrap alias not found in agent — Fix 2 sentinel missing"
    )


def test_v070_fix2_zero_aggregate_branch_present():
    """The sanitizer must contain the zero-aggregate detection branch."""
    txt = _agent_text_for_grep()
    assert re.search(
        r"_count_metric_aggregate_calls\(expr\)\s*==\s*0",
        txt,
    ), "Zero-aggregate detection branch not found in _sanitize_metric_measure_expr"
    assert "SUM(CAST((" in txt, (
        "Fix 2 must wrap zero-aggregate exprs with SUM(CAST((expr) AS DOUBLE))"
    )


def _load_sanitizer_namespace():
    """Locate the cell containing the metric-view sanitizer + its helpers and
    execute it in an isolated namespace, providing the imports the agent's
    notebook cell expects to inherit from earlier cells."""
    cells = _agent_cells()
    target_src = None
    for c in cells:
        s = _cell_source(c)
        if "def _sanitize_metric_measure_expr(" in s and "def _count_metric_aggregate_calls(" in s:
            target_src = s
            break
    assert target_src is not None, "Could not locate the cell containing the sanitizer + helpers"
    import re as _re
    import os as _os
    import threading as _threading
    import time as _time
    import json as _json
    import sys as _sys
    import datetime as _datetime
    ns = {
        "re": _re,
        "os": _os,
        "threading": _threading,
        "time": _time,
        "json": _json,
        "sys": _sys,
        "datetime": _datetime,
        "__builtins__": __builtins__,
    }
    try:
        exec(compile(target_src, "<sanitizer-cell>", "exec"), ns, ns)
    except (NameError, AttributeError) as e:
        # If the cell references symbols defined in earlier cells, skip the
        # offending top-level statement by extracting JUST the helper defs we
        # need via AST.
        tree = ast.parse(target_src)
        wanted = {
            "_sanitize_metric_measure_expr",
            "_count_metric_aggregate_calls",
            "_is_safe_aggregate_ratio",
            "_split_top_level_add_sub",
            "_rewrite_multi_sum_to_single_sum",
            "_has_nested_aggregate_depth_aware",
            "_extract_column_refs_from_expr",
            "_extract_bare_arithmetic_operands",
            "_rewrite_column_refs_in_expr",
            "_strip_source_product_prefix_in_expr",
            "_metric_yaml_quote",
        }
        keep = []
        for node in tree.body:
            if isinstance(node, (ast.Import, ast.ImportFrom)):
                keep.append(node)
                continue
            if isinstance(node, (ast.FunctionDef, ast.AsyncFunctionDef)) and node.name in wanted:
                keep.append(node)
                continue
            if isinstance(node, ast.Assign):
                # Keep module-level constants the sanitizer references.
                names = []
                for t in node.targets:
                    if isinstance(t, ast.Name):
                        names.append(t.id)
                if any(n.startswith("_") and n.endswith(("RE", "PATTERN", "FUNCS_RE", "_PATTERN_RE")) for n in names):
                    keep.append(node)
                elif any(n in {"_AGG_CALL_RE", "_METRIC_AGG_FUNCS_RE", "_NESTED_AGG_PATTERN"} for n in names):
                    keep.append(node)
        new_mod = ast.Module(body=keep, type_ignores=[])
        ast.fix_missing_locations(new_mod)
        ns2 = {
            "re": _re,
            "os": _os,
            "threading": _threading,
            "__builtins__": __builtins__,
        }
        exec(compile(new_mod, "<sanitizer-cell-pruned>", "exec"), ns2, ns2)
        return ns2
    return ns


def test_v070_fix2_sanitizer_wraps_bare_column():
    """End-to-end: feed a bare column name into the sanitizer; expect SUM-wrap."""
    ns = _load_sanitizer_namespace()
    sanitize = ns["_sanitize_metric_measure_expr"]
    out = sanitize("total_invoice_count", logger=None, view_context=" | test")
    assert "SUM" in out and "CAST" in out and "AS DOUBLE" in out, (
        f"Fix 2 must wrap bare column 'total_invoice_count' with SUM(CAST(... AS DOUBLE)); got: {out!r}"
    )
    out2 = sanitize("amount + tax", logger=None, view_context=" | test")
    assert "SUM" in out2 and "CAST" in out2, (
        f"Fix 2 must wrap arithmetic expression 'amount + tax' with SUM(CAST(...)); got: {out2!r}"
    )


def test_v070_fix2_preserves_existing_aggregates():
    """Sanitizer must NOT double-wrap expressions that already have an aggregate."""
    ns = _load_sanitizer_namespace()
    sanitize = ns["_sanitize_metric_measure_expr"]
    out = sanitize("SUM(amount)", logger=None, view_context=" | test")
    assert "SUM(SUM" not in out, f"Sanitizer double-wrapped SUM: {out!r}"
    out2 = sanitize("COUNT(1)", logger=None, view_context=" | test")
    assert out2.strip() == "COUNT(1)", f"COUNT(1) must pass through unchanged; got: {out2!r}"


def test_v070_fix2_string_literal_falls_back_to_count1():
    """Sanitizer must NOT wrap an expr containing string literals in SUM-CAST.
    Such expressions can't be safely cast to DOUBLE and must fall back to COUNT(1)."""
    ns = _load_sanitizer_namespace()
    sanitize = ns["_sanitize_metric_measure_expr"]
    out = sanitize("status = 'ACTIVE'", logger=None, view_context=" | test")
    assert out.strip() == "COUNT(1)", (
        f"Unsafe expr with string literal must fall back to COUNT(1); got: {out!r}"
    )


# ============================================================================
# Fix 3: step-boundary-flush — force-flush + raw-write sentinel at every step.
# ============================================================================


def test_v070_fix3_alias_present():
    txt = _agent_text_for_grep()
    assert "step-boundary-flush" in txt, (
        "step-boundary-flush alias not found in agent — Fix 3 sentinel missing"
    )


def test_v070_fix3_helper_defined_and_called_in_both_log_steps():
    txt = _agent_text_for_grep()
    assert "_step_boundary_force_flush" in txt, (
        "_step_boundary_force_flush helper not defined"
    )
    # The helper must be invoked from both _log_step_start AND _log_step_end.
    assert re.search(
        r"def _log_step_start\(step_func\):.+?_step_boundary_force_flush\('start'",
        txt,
        re.DOTALL,
    ), "_log_step_start must invoke _step_boundary_force_flush('start', ...)"
    assert re.search(
        r"def _log_step_end\(step_func, step_start_time\):.+?_step_boundary_force_flush\('end'",
        txt,
        re.DOTALL,
    ), "_log_step_end must invoke _step_boundary_force_flush('end', ...)"


def test_v070_fix3_helper_writes_step_boundary_sentinel_with_fsync():
    txt = _agent_text_for_grep()
    # The helper must write a [STEP-BOUNDARY] line and call fsync for durability.
    assert "[STEP-BOUNDARY] kind=" in txt, (
        "Fix 3 must write '[STEP-BOUNDARY] kind=...' sentinel via raw open()"
    )
    assert "os.fsync" in txt, (
        "Fix 3 must call os.fsync to durably write the step boundary"
    )


def test_v070_fix3_helper_flushes_logger_handlers():
    txt = _agent_text_for_grep()
    # Loop over getattr(logger, 'handlers', []) and call _h.flush()
    assert re.search(
        r"for _h in list\(getattr\(logger,\s*'handlers',\s*\[\]\)\):",
        txt,
    ), "Fix 3 must iterate logger.handlers and flush each"


# ============================================================================
# README + version history must reflect v0.7.0.
# ============================================================================


def test_v070_readme_lists_v070():
    txt = README.read_text()
    assert "v0.7.0" in txt, "readme.md must contain a v0.7.0 entry"
    assert re.search(r"Current version[^\n]*v0\.7\.0", txt), (
        "readme.md 'Current version' line must read v0.7.0"
    )


def test_v070_readme_mentions_three_fixes():
    txt = README.read_text()
    for needle in ("vov-metrics-teardown", "mv-measure-agg-wrap", "step-boundary-flush"):
        assert needle in txt, f"readme.md must mention alias '{needle}' for v0.7.0 traceability"
