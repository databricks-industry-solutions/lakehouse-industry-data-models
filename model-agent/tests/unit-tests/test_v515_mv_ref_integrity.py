"""v5.1.5 — metric views must install as designed, and a row-count fallback must never be reported as success.

Live run 161935925891676 (agent 5.1.4, vs514 retail, new base MVM) installed 17 of 37 metric views as
bare row-count fallbacks while the log said "all 36 created ... 0 failed". The install errors were all
METRIC_VIEW_INVALID_VIEW_DEFINITION:
  * "window.order field must reference existing dimension columns. Invalid: Return Requested Month" (13)
  * "partition.include field must reference existing dimension columns. Invalid: RFM Segment" (3)
  * "Duplicate window order fields: effective_month" (1)
A live probe on the SQL warehouse (2026-10-09) confirmed: window.order / partition.include must name a
dimension `name` (not its display_name), a referenced dimension that was pruned fails, a duplicate order
fails, a partition needs outer_aggregate, AGG(<measure>) / MEASURE(<measure>) work, and wrapping AGG()
in SUM(CAST(...)) fails with NESTED_AGGREGATE_FUNCTION.
"""
import logging
import re
import sys
from concurrent.futures import ThreadPoolExecutor, as_completed
from pathlib import Path

import pytest

sys.path.insert(0, str(Path(__file__).resolve().parent))
import conftest  # noqa: F401,E402
import agent_helpers as ah  # noqa: E402
from notebook_source_util import notebook_concat_source  # noqa: E402


class _Log:
    def __init__(self):
        self.warnings, self.infos = [], []

    def warning(self, msg, *a, **k):
        self.warnings.append(str(msg))

    def info(self, msg, *a, **k):
        self.infos.append(str(msg))

    def error(self, msg, *a, **k):
        self.warnings.append(str(msg))

    def debug(self, *a, **k):
        pass


PRODUCTS = {"return_request": {"table_name": "return_request", "domain": "order", "product": "return_request"}}
COLUMNS = {"return_request": {"columns": {"return_request_id", "requested_at", "status"},
                              "string_columns": {"status"}, "boolean_columns": set(), "col_rewrite_map": {}}}


def _spec(measures, dims=None):
    return {"metric_views": [{
        "view_name": "metrics_return_request",
        "source_product": "return_request",
        "dimensions": dims or [
            {"name": "return_requested_month", "display_name": "Return Requested Month", "expr": "DATE_TRUNC('month', requested_at)"},
            {"name": "return_requested_year", "display_name": "Return Requested Year", "expr": "DATE_TRUNC('year', requested_at)"},
            {"name": "refund_method", "display_name": "Refund Method", "expr": "refund_method"},
            {"name": "status", "display_name": "Return Status", "expr": "status"},
        ],
        "measures": measures,
    }]}


def _render(measures, dims=None):
    log = _Log()
    out = ah._render_metric_sql_for_domain_from_llm_spec(
        "cat", "order", "order", _spec(measures, dims), PRODUCTS, log, product_columns=COLUMNS, config={})
    stmts = out[0] if isinstance(out, tuple) else out
    assert stmts, "the view must render"
    return "\n".join(stmts), log


def _measure_names(yaml_text):
    tail = yaml_text.split("measures:", 1)[1]
    return re.findall(r'^\s*-\s*name:\s*"([^"]+)"', tail, re.M)


WINDOWED = [
    {"name": "Return Count", "expr": "COUNT(1)"},
    {"name": "Returns CM", "expr": "COUNT(1)", "window": [{"order": "Return Requested Month", "range": "current", "semiadditive": "last"}]},
    {"name": "Returns PM", "expr": "COUNT(1)", "window": [{"order": "Return Requested Month", "range": "current", "semiadditive": "last", "offset": "-1 month"}]},
    {"name": "Returns MoM", "expr": "(AGG(`Returns CM`) - AGG(`Returns PM`)) / NULLIF(AGG(`Returns PM`), 0)"},
]


def test_window_order_naming_a_display_name_is_rewritten_to_the_dimension_name():
    yaml_text, log = _render(WINDOWED)
    assert "order: return_requested_month" in yaml_text
    assert "order: Return Requested Month" not in yaml_text, "the live install rejects a display name in window.order"
    assert any("mv-measure-ref-resolve FIRED v5.1.5" in w for w in log.warnings)


def test_a_derived_measure_keeps_its_backticked_agg_references_and_is_not_wrapped():
    yaml_text, _ = _render(WINDOWED)
    assert "AGG(`Returns CM`)" in yaml_text and "AGG(`Returns PM`)" in yaml_text
    assert "SUM(CAST(((AGG(" not in yaml_text, "SUM(AGG()) fails live with NESTED_AGGREGATE_FUNCTION"
    assert "Returns MoM" in _measure_names(yaml_text)


def test_a_window_on_a_pruned_dimension_drops_that_measure_and_every_measure_built_on_it():
    measures = WINDOWED + [
        {"name": "By Method", "expr": "COUNT(1)", "window": [{"order": "Refund Method", "range": "current", "semiadditive": "last"}]},
        {"name": "Method Share", "expr": "AGG(`By Method`) / NULLIF(AGG(`Return Count`), 0)"},
    ]
    yaml_text, log = _render(measures)
    names = _measure_names(yaml_text)
    assert "By Method" not in names, "refund_method is not a physical column, so its dimension is pruned"
    assert "Method Share" not in names, "a derived measure on a dropped measure fails UNRESOLVED_COLUMN live"
    assert {"Return Count", "Returns CM", "Returns PM", "Returns MoM"} <= set(names)
    assert any("By Method" in w and "Method Share" in w for w in log.warnings)


def test_a_duplicate_window_order_drops_only_that_measure():
    measures = WINDOWED + [{"name": "Returns YTD", "expr": "COUNT(1)", "window": [
        {"order": "return_requested_month", "range": "cumulative", "semiadditive": "last"},
        {"order": "Return Requested Month", "range": "current", "semiadditive": "last"}]}]
    yaml_text, _ = _render(measures)
    names = _measure_names(yaml_text)
    assert "Returns YTD" not in names
    assert "Returns CM" in names


def test_partition_include_is_resolved_and_a_partition_without_outer_aggregate_is_dropped():
    measures = [
        {"name": "Return Count", "expr": "COUNT(1)"},
        {"name": "Status Share", "expr": "COUNT(1)", "partition": {"include": ["Return Status"], "outer_aggregate": "sum"}},
        {"name": "Status Raw", "expr": "COUNT(1)", "partition": {"include": ["status"]}},
    ]
    yaml_text, _ = _render(measures)
    assert "include: [status]" in yaml_text
    assert "Return Status]" not in yaml_text
    assert "Status Raw" not in _measure_names(yaml_text)


def test_an_agg_reference_to_an_unknown_measure_drops_the_derived_measure():
    measures = [{"name": "Return Count", "expr": "COUNT(1)"},
                {"name": "Growth", "expr": "AGG(`Return Count`) / NULLIF(AGG(`Missing Measure`), 0)"}]
    yaml_text, _ = _render(measures)
    assert "Growth" not in _measure_names(yaml_text)


def test_a_view_without_windows_or_derived_measures_renders_unchanged_measures():
    measures = [{"name": "Return Count", "expr": "COUNT(1)"}, {"name": "Open Returns", "expr": "COUNT(CASE WHEN status = 'open' THEN 1 END)"}]
    yaml_text, log = _render(measures)
    assert _measure_names(yaml_text) == ["Return Count", "Open Returns"]
    assert not any("mv-measure-ref-resolve" in w for w in log.warnings)


def test_the_sanitizer_leaves_agg_and_measure_expressions_alone():
    for expr in ("(AGG(`Gross Revenue`) - AGG(`Gross Revenue PM`)) / NULLIF(AGG(`Gross Revenue PM`), 0)",
                 "MEASURE(rev) / NULLIF(MEASURE(cnt), 0)", "AGG(`Total POS Revenue`)"):
        assert ah._sanitize_metric_measure_expr(expr) == expr


def test_the_sanitizer_still_wraps_a_plain_expression_without_an_aggregate():
    assert ah._sanitize_metric_measure_expr("revenue - cost").startswith("SUM(")


STMT_PRUNED = (
    "CREATE OR REPLACE VIEW `c`.`_metrics`.`order_line`\nWITH METRICS\nLANGUAGE YAML\nAS $$\n  version: 1.1\n"
    '  source: "`c`.`order`.`line`"\n  dimensions:\n'
    '    - name: "line_created_year"\n      display_name: "Line Created Year"\n      expr: DATE_TRUNC(\'year\', created_at)\n'
    "  measures:\n"
    '    - name: "Lines"\n      expr: COUNT(1)\n'
    '    - name: "Lines CM"\n      expr: COUNT(1)\n      window:\n        - order: line_created_month\n          range: current\n'
    '    - name: "Lines CY"\n      expr: COUNT(1)\n      window:\n        - order: Line Created Year\n          range: current\n'
    '    - name: "Lines Growth"\n      expr: AGG(`Lines CM`) / NULLIF(AGG(`Lines`), 0)\n$$'
)


def test_the_yaml_pass_drops_measures_left_dangling_by_a_physical_dimension_prune():
    out, drops, rewrites = ah._mv_yaml_drop_dangling_refs(STMT_PRUNED)
    names = re.findall(r'^\s*-\s*name:\s*"([^"]+)"', out.split("measures:", 1)[1], re.M)
    assert names == ["Lines", "Lines CY"], names
    assert "order: line_created_year" in out and rewrites == 1
    assert {d[0] for d in drops} == {"Lines CM", "Lines Growth"}


def test_the_yaml_pass_returns_a_clean_statement_untouched():
    clean = STMT_PRUNED.split("    - name: \"Lines CM\"")[0] + "$$"
    out, drops, rewrites = ah._mv_yaml_drop_dangling_refs(clean)
    assert out == clean and drops == [] and rewrites == 0


def test_the_physical_prune_runs_the_dangling_reference_pass():
    src = notebook_concat_source()
    body = src[src.index("def _mvcp_prune_blocks(_seg):"):]
    body = body[:body.index("_kept2.append(_new_stmt)")]
    assert "_mv_yaml_drop_dangling_refs(_new_stmt)" in body


FN = "execute_metric_views_in_parallel_no_halt"
STMT = (
    "CREATE OR REPLACE VIEW `c`.`_metrics`.`order_payment`\nWITH METRICS\nLANGUAGE YAML\nAS $$\n  version: 1.1\n"
    '  source: "`c`.`order`.`payment`"\n  dimensions:\n    - name: "payment_month"\n      expr: DATE_TRUNC(\'month\', paid_at)\n'
    '  measures:\n    - name: "payments"\n      expr: COUNT(1)\n$$'
)
INVALID = ("[METRIC_VIEW_INVALID_VIEW_DEFINITION] The metric view definition is invalid. Reason: window.order field must "
           "reference existing dimension columns. Invalid: Payment Month. SQLSTATE: 42K0E")


def _slice_function(src, name):
    lines = src.split("\n")
    start = next(i for i, l in enumerate(lines) if l.startswith("def %s(" % name))
    end = start + 1
    while end < len(lines) and not (lines[end][:1] not in ("", " ", "\t") and lines[end].startswith("def ")):
        end += 1
    return "\n".join(lines[start:end])


def _fails_until_fallback(spark, stmt, logger, *a, **k):
    if "ROWCOUNT-FALLBACK" in stmt:
        return None
    raise Exception(INVALID)


def _always_ok(spark, stmt, logger, *a, **k):
    return None


def _run_installer(statements, log, execute_sql):
    ns = {
        "re": re, "time": __import__("time"), "logging": logging, "logger": log, "TimeoutError": TimeoutError,
        "_DEFAULT_FUTURE_TIMEOUT": 600, "execute_sql": execute_sql,
        "_extract_metric_view_name_from_statement": lambda s: "order_payment",
        "_extract_metric_view_target_from_statement": lambda s: "`c`.`_metrics`.`order_payment`",
        "_extract_metric_view_source_from_statement": lambda s: "`c`.`order`.`payment`",
        "_v468_derive_mv_source_from_target": lambda spark, target, logger=None: None,
        "_v469_build_mv_rowcount_fallback": lambda target, source: f"CREATE OR REPLACE VIEW {target} -- ROWCOUNT-FALLBACK {source}",
        "_ts": lambda: "00:00:00", "_fmt_hms": lambda s: "0s", "_format_eta": lambda *a, **k: "0s",
        "_flush_log_handlers": lambda *a, **k: None, "_sanitize_metric_stmt_nested_agg": lambda x=None, *a, **k: x,
        "_v458_metric_exception_detail": lambda e, hist=None: str(e),
    }

    class _Pool:
        def __init__(self, max_workers):
            self._e = ThreadPoolExecutor(max_workers=max_workers)

        def __enter__(self):
            return self._e

        def __exit__(self, *a):
            self._e.shutdown(wait=True)
            return False

    ns["guarded_thread_pool_executor"] = lambda mw, **kw: _Pool(mw)
    ns["_safe_as_completed"] = lambda f, timeout=None, logger=None, label=None: as_completed(f)
    exec(compile(_slice_function(notebook_concat_source(), FN), "<agent:%s>" % FN, "exec"), ns, ns)
    return ns[FN](None, list(statements), log, 2, None)


def test_a_rowcount_fallback_is_counted_and_reported_not_laundered_into_success():
    log = _Log()
    result = _run_installer([STMT + ";"], log, _fails_until_fallback)
    assert result["failed"] == []
    assert result["rowcount_fallbacks"] == ["order_payment"]
    assert any("mv-rowcount-fallback-honest FIRED v5.1.5" in w and "order_payment" in w for w in log.warnings)
    finished = [m for m in log.infos + log.warnings if "Finished METRIC VIEWS" in m]
    assert finished and "1 as row-count fallback" in finished[-1], finished


def test_a_view_that_installs_as_designed_is_not_a_fallback():
    log = _Log()
    result = _run_installer([STMT + ";"], log, _always_ok)
    assert result["rowcount_fallbacks"] == []
    assert not any("mv-rowcount-fallback-honest" in w for w in log.warnings)
    finished = [m for m in log.infos if "Finished METRIC VIEWS" in m]
    assert finished and "1 as designed and 0 as row-count fallback" in finished[-1], finished
