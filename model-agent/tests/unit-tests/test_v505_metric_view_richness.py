"""v5.0.5 behavioral test — richer UC Metric Views (learned from databricks-solutions/uc-semantics-patterns).

The agent previously emitted "light and trivial" metric views: dimensions/measures with only
{name, expr, comment}, no formatting, no display names, no time-intelligence, no LOD.

v5.0.5 embeds the reference patterns via shared, pure YAML emitters:
    _infer_mv_format          -> currency/percentage/number/date format inference
    _emit_mv_format_yaml      -> `format:` block
    _emit_mv_window_yaml      -> `window:` (time-intelligence + semi-additive)
    _emit_mv_partition_yaml   -> `partition:` (INCLUDE level-of-detail)
Both MV builders (LLM-driven and deterministic-fallback) now emit display_name + format, and the
LLM builder additionally emits window/partition. Both response schemas allow the new fields.

The emitters are pure functions, so this test extracts them from the notebook source and exercises
them directly (fail-pre: on HEAD~1 the functions do not exist -> ImportError-equivalent AssertionError).
"""
import json
import re
from pathlib import Path

NOTEBOOK = Path(__file__).resolve().parents[2] / "agent" / "dbx_vibe_modelling_agent.ipynb"


def _all_source():
    nb = json.loads(NOTEBOOK.read_text())
    return "\n".join("".join(c.get("source", [])) for c in nb["cells"])


def _load_emitters():
    """Extract and exec the four pure emitters (+ their two type-helper deps) from the notebook."""
    src = _all_source()
    ns = {}
    exec(
        "def _is_metric_temporal_type(t):\n"
        "    return str(t or '').upper() in {'DATE','TIMESTAMP','DATETIME','TIME'}\n"
        "def _is_metric_numeric_type(t):\n"
        "    return any(x in str(t or '').upper() for x in ['INT','DECIMAL','NUMERIC','DOUBLE','FLOAT','REAL'])\n",
        ns,
    )
    for fn in ("_infer_mv_format", "_emit_mv_format_yaml", "_emit_mv_window_yaml", "_emit_mv_partition_yaml"):
        m = re.search(r"\ndef " + fn + r"\(.*?\n(?=def |# v5\.0\.5|\Z)", src, re.S)
        assert m, f"v5.0.5: emitter {fn} not found in notebook source"
        exec(m.group(0), ns)
    return ns


# --------------------------- source / schema / prompt smoke ---------------------------

def test_v505_version_at_least_505():
    m = re.search(r'__AGENT_VERSION__\s*=\s*"(\d+)\.(\d+)\.(\d+)"', _all_source())
    assert m and tuple(int(g) for g in m.groups()) >= (5, 0, 5), "v5.0.5: version must be >= 5.0.5"


def test_v505_alias_and_emitters_present():
    src = _all_source()
    assert "v505-mv-rich-emitters" in src
    for fn in ("_infer_mv_format", "_emit_mv_format_yaml", "_emit_mv_window_yaml", "_emit_mv_partition_yaml"):
        assert f"def {fn}(" in src, f"v5.0.5: {fn} missing"


def test_v505_schemas_allow_rich_fields():
    """Both MV response schemas must permit display_name/format/window/partition and be non-strict."""
    src = _all_source()
    for base in ("_AI_KPI_FIRST_GLOBAL_SCHEMA_BASE", "_AI_DOMAIN_METRICS_SCHEMA_BASE"):
        m = re.search(base + r" = (\{.*?\})\n", src)
        assert m, f"v5.0.5: {base} not found"
        d = eval(m.group(0).split(" = ", 1)[1], {"True": True, "False": False, "None": None})
        s = json.dumps(d)
        assert '"display_name"' in s and '"format"' in s, f"v5.0.5: {base} missing display_name/format"
        assert '"window"' in s and '"partition"' in s, f"v5.0.5: {base} missing window/partition"
        assert d.get("strict") is False, f"v5.0.5: {base} must be strict=False for optional rich fields"


def test_v505_prompt_teaches_patterns():
    src = _all_source()
    assert "ADVANCED SEMANTIC PATTERNS" in src
    for kw in ("time-intelligence", "semiadditive", "AGG(", "partition", "DATE_TRUNC"):
        assert kw in src, f"v5.0.5: MV prompt guidance missing '{kw}'"


def test_v505_both_builders_emit_display_name_and_format():
    """Deterministic-fallback builder AND LLM builder must call the format emitter + display_name."""
    src = _all_source()
    assert src.count("_emit_mv_format_yaml(") >= 3, "v5.0.5: format emitter must be called in both builders"
    assert "_block.extend(_emit_mv_window_yaml(_meas_window, 6))" in src, "v5.0.5: LLM builder must emit window"
    assert "_block.extend(_emit_mv_partition_yaml(_meas_partition, 6))" in src, "v5.0.5: LLM builder must emit partition"
    assert "_mv_resolve_measure_refs(meas.get(\"window\"), meas.get(\"partition\"), _emitted_dims)" in src, (
        "v5.1.5: the emitted window/partition are the ones resolved against the emitted dimensions")


def test_v505_agg_derived_measures_exempt_from_colcheck():
    src = _all_source()
    assert "_is_agg_derived" in src, "v5.0.5: AGG-derived measures must be exempt from bare-column ColCheck"
    assert "not _is_agg_derived" in src


# --------------------------- behavioral: exercise the pure emitters ---------------------------

def test_v505_infer_format_currency_percentage_number_date():
    ns = _load_emitters()
    inf = ns["_infer_mv_format"]
    assert inf("Total Revenue", "SUM(revenue)", "DECIMAL")["type"] == "currency"
    assert inf("Churn Rate", "AGG(a)/AGG(b)")["type"] == "percentage"
    assert inf("Order Month", "DATE_TRUNC('month', d)")["type"] == "date"
    assert inf("Order Count", "COUNT(id)", "BIGINT")["type"] == "number"
    # a categorical dimension should NOT be force-currency'd
    assert inf("Amount Band", "CASE WHEN x>1 THEN 'HI' END", None, is_dimension=True) is None


def test_v505_format_yaml_currency_shape():
    ns = _load_emitters()
    lines = ns["_emit_mv_format_yaml"](
        {"type": "currency", "currency_code": "USD", "decimal_places": {"type": "exact", "places": 2}}, 6
    )
    assert lines == [
        "      format:",
        "        type: currency",
        "        currency_code: USD",
        "        decimal_places:",
        "          type: exact",
        "          places: 2",
    ]


def test_v505_format_yaml_empty_is_noop():
    ns = _load_emitters()
    assert ns["_emit_mv_format_yaml"](None, 6) == []
    assert ns["_emit_mv_format_yaml"]({}, 6) == []


def test_v511_format_type_whitelist():
    """Regression: an unknown ColumnFormat type (e.g. LLM-emitted 'string') makes the whole metric
    view INVALID. The emitter must drop the cosmetic format block for unknown/absent types and keep
    valid ones (currency/number/percentage/date/date_time/boolean/byte, case-insensitive)."""
    ns = _load_emitters()
    f = ns["_emit_mv_format_yaml"]
    assert f({"type": "string"}, 6) == [], "invalid 'string' type must drop the format block, not break the view"
    assert f({"decimal_places": {"type": "all"}}, 6) == [], "format with no type -> dropped"
    assert f({"type": "text"}, 6) == []
    # valid types still emit
    for t in ("currency", "number", "percentage", "date", "date_time", "boolean", "byte"):
        assert f({"type": t}, 6)[:1] == ["      format:"], f"valid type {t} must emit"
        assert f({"type": t}, 6)[1] == "        type: " + t
    # capitalized normalized to lowercase
    assert f({"type": "Currency"}, 6)[1] == "        type: currency"


def test_v505_window_yaml_time_intelligence():
    ns = _load_emitters()
    lines = ns["_emit_mv_window_yaml"](
        [{"order": "Month", "range": "current", "semiadditive": "last", "offset": "-1 month"}], 6
    )
    assert lines == [
        "      window:",
        "        - order: Month",
        "          range: current",
        "          semiadditive: last",
        "          offset: -1 month",
    ]
    assert ns["_emit_mv_window_yaml"]([], 6) == []
    assert ns["_emit_mv_window_yaml"](None, 6) == []


def test_v505_partition_yaml_lod():
    ns = _load_emitters()
    lines = ns["_emit_mv_partition_yaml"]({"include": ["Customer Segment"], "outer_aggregate": "sum"}, 6)
    assert lines == [
        "      partition:",
        "        include: [Customer Segment]",
        "        outer_aggregate: sum",
    ]
    # empty / malformed -> no-op (never emit an empty partition block)
    assert ns["_emit_mv_partition_yaml"]({"include": []}, 6) == []
    assert ns["_emit_mv_partition_yaml"]({}, 6) == []


def test_v505_end_to_end_measure_yaml_is_rich_not_trivial():
    """Simulate the LLM-builder measure emission for a monetary measure and assert the
    produced YAML carries display_name + currency format (i.e. no longer 'light and trivial')."""
    ns = _load_emitters()
    fmt = ns["_infer_mv_format"]("Total Premium", "SUM(premium_amount)", "DECIMAL")
    yaml_lines = ['    - name: "Total Premium"', '      display_name: "Total Premium"', "      expr: SUM(premium_amount)"]
    yaml_lines += ns["_emit_mv_format_yaml"](fmt, 6)
    body = "\n".join(yaml_lines)
    assert "display_name:" in body
    assert "type: currency" in body and "currency_code: USD" in body
    assert "places: 2" in body
