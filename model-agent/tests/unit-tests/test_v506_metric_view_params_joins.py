"""v5.0.6 behavioral test — deeper uc-semantics-patterns learnings embedded into MV generation:
query-time parameters, nested star-schema joins (correct rely/no-type syntax), period-to-date
(cumulative multi-window), moving/rolling (trailing) windows, and the p_-prefix parameter gotcha.

Pure emitters are extracted from the notebook and exercised directly.
"""
import json
import re
from pathlib import Path

NOTEBOOK = Path(__file__).resolve().parents[2] / "agent" / "dbx_vibe_modelling_agent.ipynb"


def _all_source():
    nb = json.loads(NOTEBOOK.read_text())
    return "\n".join("".join(c.get("source", [])) for c in nb["cells"])


def _load(fns):
    src = _all_source()
    ns = {"re": re}  # the notebook has `re` imported globally; provide it to the isolated exec
    for fn in fns:
        m = re.search(r"\ndef " + fn + r"\(.*?\n(?=def |# v5|\Z)", src, re.S)
        assert m, f"v5.0.6: emitter {fn} not found"
        exec(m.group(0), ns)
    return ns


def test_v506_version_and_aliases():
    src = _all_source()
    m = re.search(r'__AGENT_VERSION__\s*=\s*"(\d+)\.(\d+)\.(\d+)"', src)
    assert m and tuple(int(g) for g in m.groups()) >= (5, 0, 6)
    assert "v506-mv-parameters" in src
    assert "v506-mv-joins-correct-syntax" in src


def test_v506_schemas_have_parameters():
    src = _all_source()
    for base in ("_AI_KPI_FIRST_GLOBAL_SCHEMA_BASE", "_AI_DOMAIN_METRICS_SCHEMA_BASE"):
        m = re.search(base + r" = (\{.*?\})\n", src)
        d = eval(m.group(1), {"True": True, "False": False, "None": None})
        assert '"parameters"' in json.dumps(d), f"v5.0.6: {base} missing parameters"


def test_v506_joins_default_off_flag_gated():
    src = _all_source()
    assert "config.get('MV_ENABLE_JOINS')" in src, "v5.0.6: joins must be behind MV_ENABLE_JOINS flag"
    assert "if False and isinstance(_mv_joins_raw" not in src, "v5.0.6: old hard-disabled join guard must be gone"


def test_v506_prompt_teaches_deeper_patterns():
    src = _all_source()
    for kw in ("PERIOD-TO-DATE", "cumulative", "trailing", "QUERY-TIME PARAMETERS", "p_ so a bare name"):
        assert kw in src, f"v5.0.6: prompt missing '{kw}'"


# ---------------- behavioral: parameters emitter ----------------

def test_v506_parameters_yaml():
    ns = _load(["_sql_string_escape", "_emit_mv_parameters_yaml"])
    # v5.1.0 v510-mv-param-string-quote: STRING default gets normalized to the SQL literal "'USD'"
    out = ns["_emit_mv_parameters_yaml"]([{"name": "p_target_currency", "data_type": "string", "default": "'USD'"}])
    assert out == [
        "  parameters:",
        "    - name: p_target_currency",
        "      data_type: STRING",
        "      default: \"'USD'\"",
    ]
    assert ns["_emit_mv_parameters_yaml"](None) == []
    assert ns["_emit_mv_parameters_yaml"]([]) == []
    # a param with no name is skipped
    assert ns["_emit_mv_parameters_yaml"]([{"data_type": "STRING"}]) == []


def test_v510_string_param_default_sql_quoted():
    """Regression: UC rejects an UNQUOTED string default (METRIC_VIEW_INVALID_VIEW_DEFINITION).
    The emitter must SQL-quote STRING defaults and leave numeric/boolean verbatim."""
    ns = _load(["_sql_string_escape", "_emit_mv_parameters_yaml"])
    f = ns["_emit_mv_parameters_yaml"]
    # bare string -> SQL-quoted YAML scalar "'OPERATED'"
    assert f([{"name": "p_leg_status", "data_type": "STRING", "default": "OPERATED"}])[-1] == "      default: \"'OPERATED'\""
    # already SQL-quoted -> normalized, not double-wrapped
    assert f([{"name": "p_cur", "data_type": "STRING", "default": "'USD'"}])[-1] == "      default: \"'USD'\""
    # numeric type -> verbatim
    assert f([{"name": "p_min", "data_type": "INT", "default": 15}])[-1] == "      default: 15"
    # no data_type but numeric-looking -> verbatim
    assert f([{"name": "p_x", "default": "42"}])[-1] == "      default: 42"
    # no data_type, non-numeric -> quoted as string
    assert f([{"name": "p_y", "default": "ACTIVE"}])[-1] == "      default: \"'ACTIVE'\""
    # embedded apostrophe -> backslash-escaped (Spark reads 'O''Hare' as the two literals 'O' 'Hare' = OHare)
    assert f([{"name": "p_z", "data_type": "STRING", "default": "O'Hare"}])[-1] == "      default: \"'O\\\\'Hare'\""


# ---------------- behavioral: nested-join emitter (correct UC syntax) ----------------

def test_v506_nested_joins_yaml_matches_reference():
    ns = _load(["_emit_mv_joins_yaml"])
    joins = [{
        "name": "customer", "source": "customer",
        "on": "source.o_custkey = customer.c_custkey", "rely": {"at_most_one_match": True},
        "joins": [{
            "name": "nation", "source": "nation",
            "on": "customer.c_nationkey = nation.n_nationkey", "at_most_one_match": True,
        }],
    }]
    out = ns["_emit_mv_joins_yaml"](joins, 2)
    assert out == [
        "  joins:",
        "    - name: customer",
        "      source: customer",
        "      'on': source.o_custkey = customer.c_custkey",
        "      rely:",
        "        at_most_one_match: true",
        "      joins:",
        "        - name: nation",
        "          source: nation",
        "          'on': customer.c_nationkey = nation.n_nationkey",
        "          rely:",
        "            at_most_one_match: true",
    ]


def test_v506_joins_never_emit_type_field():
    ns = _load(["_emit_mv_joins_yaml"])
    out = ns["_emit_mv_joins_yaml"]([{"name": "fx", "source": "exchange_rate", "on": "a=b", "type": "INNER", "rely": True}], 2)
    body = "\n".join(out)
    assert "type:" not in body, "v5.0.6: UC join YAML must NOT contain a type: field (runtime rejects it)"
    assert "rely:" in body and "at_most_one_match: true" in body


def test_v506_multiline_on_uses_block_scalar():
    ns = _load(["_emit_mv_joins_yaml"])
    out = ns["_emit_mv_joins_yaml"](
        [{"name": "fx", "source": "exchange_rate",
          "on": "fx.rate_month = DATE_TRUNC('month', source.o_orderdate)\nAND fx.to_currency = p_target_currency",
          "rely": True}], 2)
    body = "\n".join(out)
    assert "'on': |-" in body, "v5.0.6: multi-line join predicate must use the YAML block scalar |-"
    assert "AND fx.to_currency = p_target_currency" in body


def test_v506_empty_joins_noop():
    ns = _load(["_emit_mv_joins_yaml"])
    assert ns["_emit_mv_joins_yaml"]([], 2) == []
    assert ns["_emit_mv_joins_yaml"]([{"name": "x"}], 2) == []  # missing source/on -> skipped -> no block


# ---------------- behavioral: multi-window period-to-date via existing window emitter ----------------

def test_v506_period_to_date_multi_window():
    ns = _load(["_emit_mv_window_yaml"])
    out = ns["_emit_mv_window_yaml"](
        [{"order": "OrderDate", "range": "cumulative", "semiadditive": "last"},
         {"order": "Year", "range": "current", "semiadditive": "last"}], 6)
    assert out == [
        "      window:",
        "        - order: OrderDate",
        "          range: cumulative",
        "          semiadditive: last",
        "        - order: Year",
        "          range: current",
        "          semiadditive: last",
    ]


def test_v506_trailing_moving_window():
    ns = _load(["_emit_mv_window_yaml"])
    out = ns["_emit_mv_window_yaml"]([{"order": "OrderDate", "semiadditive": "last", "range": "trailing 7 day inclusive"}], 6)
    assert "range: trailing 7 day inclusive" in "\n".join(out)
