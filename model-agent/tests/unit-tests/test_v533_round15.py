"""v5.3.3 live round 19 (r19e 688909148981708) findings.

The bakery vibe asked for a yearly ingredient cost report with a query parameter p_fiscal_year (INT) whose default is
YEAR(CURRENT_DATE). The view installed without the parameter, and both the spec verifier and the physical audit scored the
requirement fulfilled because they only checked that a view of that name existed. The requirement spec kept only the view
names, the KPI-first prompt never said how to write a parameter, and KPI-first dropped any parameter the LLM did write before
rendering. The physical audit also scored a drop_metric_view requirement fulfilled while the view still existed.
"""
import logging
import sys
from pathlib import Path

import pytest

sys.path.insert(0, str(Path(__file__).resolve().parent))
import conftest  # noqa: F401,E402
import agent_helpers as ah  # noqa: E402
import vreq_spec_util as vs  # noqa: E402
from notebook_source_util import notebook_concat_source  # noqa: E402

LOG = logging.getLogger("test_v533_round15")
SRC = notebook_concat_source()

YEARLY = "yearly ingredient cost report"
SIGNUPS = "new loyalty sign-ups this month"
SIGNUP_EXPR = "COUNT(CASE WHEN date_trunc('month', signed_up_at) = date_trunc('month', current_date()) THEN 1 END)"

AGENT_SQL = """CREATE OR REPLACE VIEW `cat`.`_metrics`.`production_yearly_ingredient_cost_report`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Yearly ingredient spend"
  source: "`cat`.`production`.`ingredient_stock`"
{params}  dimensions:
    - name: "fiscal_year"
      expr: fiscal_year
  measures:
    - name: "total_cost"
      expr: SUM(CAST(ingredient_cost AS DOUBLE))
      format:
        type: number
$$"""

PARAMS = """  parameters:
    - name: p_fiscal_year
      data_type: INT
      default: YEAR(current_date())
"""

CATALOG_YAML = """CREATE VIEW cat._metrics.customer_new_loyalty_sign_ups_this_month (
  signed_up_month COMMENT 'Calendar month of enrolment')
WITH METRICS
LANGUAGE YAML
AS
$$
version: 1.1

source: '`cat`.`customer`.`loyalty_account`'

comment: "Counts new loyalty programme enrolments in the current calendar month, broken\\
  \\ down by enrolment channel and shop."

measures:
  - name: new_sign_ups_this_month
    expr: "COUNT(CASE WHEN date_trunc('month', signed_up_at) = date_trunc('month',\\
      \\ current_date()) THEN 1 END)"
    comment: Count of loyalty accounts enrolled in the current calendar month — the
      headline month-to-date sign-up KPI
    format:
      type: number
      decimal_places:
        type: all

  - name: total_active_loyalty_accounts
    expr: COUNT(loyalty_account_id)
$$"""


@pytest.fixture(autouse=True)
def _reset(monkeypatch):
    monkeypatch.setattr(ah, "logger", LOG, raising=False)
    ah._VREQ_SPECS.clear()
    yield
    ah._VREQ_SPECS.clear()


def _spec(action="add_metric_view", views=(YEARLY, SIGNUPS), params=None, measures=None):
    return {"action": action, "metric_views": list(views),
            "metric_view_parameters": params if params is not None else [{"view": YEARLY, "name": "p_fiscal_year", "data_type": "INT", "default": "YEAR(CURRENT_DATE)"}],
            "metric_view_measures": measures if measures is not None else [{"view": SIGNUPS, "name": "", "expr": SIGNUP_EXPR}]}


def _model():
    return {"model": {"domains": [{"name": "production", "products": [{"name": "ingredient_stock", "primary_key": "ingredient_stock_id",
                                                                        "attributes": [{"name": "ingredient_stock_id", "type": "BIGINT"}]}]}]}}


def test_the_spec_reads_the_parameters_and_measures_a_named_view_asks_for():
    idx = ah._vreq_spec_index(_model())
    raw = vs.spec("VREQ-012", "add_metric_view", metric_views=[YEARLY],
                  metric_view_parameters=[{"name": "p_fiscal_year", "data_type": "INT", "default": "YEAR(CURRENT_DATE)"}, {"name": ""}, "junk"],
                  metric_view_measures=[{"expr": SIGNUP_EXPR}])
    spec = ah._normalize_vreq_spec(raw, idx)
    assert spec["metric_view_parameters"] == [{"view": YEARLY, "name": "p_fiscal_year", "data_type": "INT", "default": "YEAR(CURRENT_DATE)"}]
    assert spec["metric_view_measures"] == [{"view": YEARLY, "name": "", "expr": SIGNUP_EXPR}]
    two = ah._normalize_vreq_spec(vs.spec("VREQ-013", "change_metric_view", metric_views=[YEARLY, SIGNUPS],
                                          metric_view_measures=[{"expr": "COUNT(1)"}, {"view": SIGNUPS, "expr": SIGNUP_EXPR}]), idx)
    assert two["metric_view_measures"] == [{"view": "", "name": "", "expr": "COUNT(1)"}, {"view": SIGNUPS, "name": "", "expr": SIGNUP_EXPR}]
    other = ah._normalize_vreq_spec(vs.spec("VREQ-014", "drop_metric_view", metric_views=[YEARLY],
                                            metric_view_parameters=[{"name": "p_fiscal_year"}]), idx)
    assert other["metric_view_parameters"] == [] and other["metric_view_measures"] == []


def test_the_spec_prompt_and_schema_ask_for_the_view_details():
    prompt = SRC[SRC.index("- metric_views: for add_metric_view, change_metric_view and drop_metric_view"):]
    assert prompt.index("- metric_view_parameters: for add_metric_view and change_metric_view") < prompt.index("- interpretable:")
    assert prompt.index("- metric_view_measures: for add_metric_view and change_metric_view") < prompt.index("- interpretable:")
    assert '"metric_views": [], "metric_view_parameters": [], "metric_view_measures": [], ' in SRC
    assert '"metric_view_parameters": {"type": "array", "items": {"type": "object", "properties": {' in SRC
    assert '"metric_view_measures": {"type": "array", "items": {"type": "object", "properties": {' in SRC


def test_the_yaml_reader_reads_the_agent_sql_and_the_folded_catalog_text():
    own = ah._mv_yaml_items(AGENT_SQL.format(params=PARAMS), "parameters")
    assert own == [{"name": "p_fiscal_year", "data_type": "INT", "default": "YEAR(current_date())"}]
    assert [m["expr"] for m in ah._mv_yaml_items(AGENT_SQL.format(params=PARAMS), "measures")] == ["SUM(CAST(ingredient_cost AS DOUBLE))"]
    assert ah._mv_yaml_items(AGENT_SQL.format(params=""), "parameters") == []
    measures = ah._mv_yaml_items(CATALOG_YAML, "measures")
    assert [m["name"] for m in measures] == ["new_sign_ups_this_month", "total_active_loyalty_accounts"]
    assert measures[0]["expr"] == SIGNUP_EXPR
    assert measures[0]["comment"].endswith("the headline month-to-date sign-up KPI")
    assert measures[0]["format"].startswith("type: number")


def test_a_missing_or_wrong_parameter_is_a_miss_and_a_written_measure_is_matched():
    yearly = AGENT_SQL.format(params=PARAMS)
    texts = {"production_yearly_ingredient_cost_report": yearly, "customer_new_loyalty_sign_ups_this_month": CATALOG_YAML}
    assert ah._mv_detail_misses(_spec(), texts) == ([], 2)
    without = dict(texts, production_yearly_ingredient_cost_report=AGENT_SQL.format(params=""))
    assert ah._mv_detail_misses(_spec(), without) == (["parameter p_fiscal_year on " + YEARLY], 2)
    for bad in (yearly.replace("YEAR(current_date())", "2024"), yearly.replace("data_type: INT", "data_type: STRING")):
        assert ah._mv_detail_misses(_spec(), dict(texts, production_yearly_ingredient_cost_report=bad))[0] == ["parameter p_fiscal_year on " + YEARLY]
    as_written = _spec(params=[], measures=[{"view": YEARLY, "name": "", "expr": "SUM(ingredient_cost)"}])
    assert ah._mv_detail_misses(as_written, texts) == ([], 1)
    other_view = _spec(params=[], measures=[{"view": YEARLY, "name": "", "expr": SIGNUP_EXPR}])
    assert ah._mv_detail_misses(other_view, texts) == (["measure " + SIGNUP_EXPR[:60] + " on " + YEARLY], 1)
    assert ah._mv_detail_misses(_spec(), {})[0] == ["parameter p_fiscal_year on " + YEARLY, "measure " + SIGNUP_EXPR[:60] + " on " + SIGNUPS]


def test_a_measure_the_sanitizer_turns_into_a_row_count_does_not_match_the_row_count():
    nested = "SUM(AVG(ingredient_cost))"
    assert ah._mv_canon(ah._sanitize_metric_measure_expr(nested)) == "count(1)"
    row_count = AGENT_SQL.format(params="").replace("SUM(CAST(ingredient_cost AS DOUBLE))", "COUNT(1)")
    spec = _spec(params=[], measures=[{"view": YEARLY, "name": "", "expr": nested}])
    assert ah._mv_detail_misses(spec, {"production_yearly_ingredient_cost_report": row_count})[0] == ["measure " + nested + " on " + YEARLY]
    asked = _spec(params=[], measures=[{"view": YEARLY, "name": "", "expr": "COUNT(1)"}])
    assert ah._mv_detail_misses(asked, {"production_yearly_ingredient_cost_report": row_count}) == ([], 1)


def test_the_spec_verifier_scores_view_details_and_drops():
    def mv(name, sql):
        return {"view_name": name, "sql": sql}
    yearly_bare = mv("production_yearly_ingredient_cost_report", AGENT_SQL.format(params=""))
    signups = mv("customer_new_loyalty_sign_ups_this_month", CATALOG_YAML)
    live = ah._verify_spec_index([], [], [], [yearly_bare, signups])
    status, evidence = ah._verify_spec_action(dict(_spec(), targets=[]), live)
    assert status == "partial"
    assert evidence == f"3/4 named metric view(s) exist with the 2 parameter(s) and measure(s) asked; missing ['parameter p_fiscal_year on {YEARLY}']"
    live_ok = ah._verify_spec_index([], [], [], [mv("production_yearly_ingredient_cost_report", AGENT_SQL.format(params=PARAMS)), signups])
    assert ah._verify_spec_action(dict(_spec(), targets=[]), live_ok)[0] == "fulfilled"
    names_only = dict(_spec(params=[], measures=[]), targets=[])
    assert ah._verify_spec_action(names_only, live) == ("fulfilled", "2/2 named metric view(s) exist")
    assert ah._verify_spec_action(dict(names_only, action="change_metric_view"), live) is None
    drop = dict(names_only, action="drop_metric_view", metric_views=[SIGNUPS])
    assert ah._verify_spec_action(drop, live) == ("failed", "0/1 named metric view(s) dropped")
    assert ah._verify_spec_action(drop, ah._verify_spec_index([], [], [], [yearly_bare])) == ("fulfilled", "1/1 named metric view(s) dropped")
    fallback = mv("customer_new_loyalty_sign_ups_this_month", f"... {ah._MV_ROWCOUNT_FALLBACK_COMMENT} ...")
    assert ah._verify_spec_action(drop, ah._verify_spec_index([], [], [], [yearly_bare, fallback]))[0] == "failed"


def test_the_physical_audit_checks_view_details_and_scores_a_drop_the_right_way_round():
    req = {"yearlyingredientcostreport", "newloyaltysignupsthismonth"}
    phys = {"productionyearlyingredientcostreport", "customernewloyaltysignupsthismonth"}
    bare = {YEARLY: AGENT_SQL.format(params=""), SIGNUPS: CATALOG_YAML}
    res = ah._gt_mv_requirement_verdict(_spec(), req, phys, phys, bare.get)
    assert res["status"] == "partial" and "[gt-mv-detail-verify FIRED v5.3.3]" in res["evidence"] and "1/2" in res["evidence"]
    full = dict(bare, **{YEARLY: AGENT_SQL.format(params=PARAMS)})
    res = ah._gt_mv_requirement_verdict(_spec(), req, phys, phys, full.get)
    assert res["status"] == "fulfilled" and "2/2 parameter(s) and measure(s) asked are in their YAML" in res["evidence"]
    names_only = _spec(params=[], measures=[])
    assert ah._gt_mv_requirement_verdict(names_only, req, phys, phys, bare.get) == {
        "status": "fulfilled", "evidence": f"[gt-mv-verify FIRED v3.4.1] all required MV(s) present physically: {sorted(req)}"}
    assert ah._gt_mv_requirement_verdict(dict(names_only, action="change_metric_view"), req, phys, phys, bare.get) is None
    assert ah._gt_mv_requirement_verdict(names_only, req, {"productionyearlyingredientcostreport"}, phys, bare.get)["status"] == "partial"
    assert ah._gt_mv_requirement_verdict(names_only, req, set(), set(), bare.get)["status"] == "failed"
    drop = dict(names_only, action="drop_metric_view")
    assert ah._gt_mv_requirement_verdict(drop, req, set(), phys, bare.get)["status"] == "failed"
    assert ah._gt_mv_requirement_verdict(drop, req, set(), {"productionyearlyingredientcostreport"}, bare.get)["status"] == "partial"
    gone = ah._gt_mv_requirement_verdict(drop, req, set(), {"salesdailysales"}, bare.get)
    assert gone["status"] == "fulfilled" and "[gt-mv-drop-verify FIRED v5.3.3]" in gone["evidence"]
    audit = SRC[SRC.index("def _run_ground_truth_audit(widgets_values):"):]
    audit = audit[:audit.index("\ndef ", 10)]
    assert "res = _gt_mv_requirement_verdict(_gt_spec, _req_norm, _gt_phys_mv_norm, _gt_phys_all_norm, _gt_view_text)" in audit
    assert "_gt_phys_all = set(_gt_phys_mvs)" in audit.split("_gt_phys_mvs -= _gt_fallbacks")[0]


def test_the_physical_audit_reads_a_named_view_yaml_from_the_catalog():
    class _Rows:
        def __init__(self, rows):
            self._rows = rows

        def collect(self):
            return self._rows

    calls = []

    class _Spark:
        def sql(self, stmt):
            calls.append(stmt)
            if stmt.startswith("SHOW CREATE TABLE"):
                return _Rows([[CATALOG_YAML]])
            return _Rows([{"s": "_metrics"}])
    audit = SRC[SRC.index("def _run_ground_truth_audit(widgets_values):"):]
    audit = audit[:audit.index("\ndef ", 10)]
    end = "            return None\n"
    block = audit[audit.index("        def _gt_norm_set(_names):"):audit.index(end, audit.index("        def _gt_view_text(_name):")) + len(end)]
    ns = {"_gt_norm_mv": lambda n: "".join(ch for ch in str(n or "").lower() if ch.isalnum()), "_gt_phys_mvs": {"customer_new_loyalty_sign_ups_this_month"},
          "_gt_phys_all": {"customer_new_loyalty_sign_ups_this_month"}, "cat_schema": [("cat", "customer")], "spark": _Spark()}
    exec("\n".join(line[8:] for line in block.split("\n")), ns)
    assert ns["_gt_view_text"](SIGNUPS) == CATALOG_YAML
    assert ns["_gt_view_text"](SIGNUPS) == CATALOG_YAML
    assert ns["_gt_view_text"](YEARLY) is None
    assert calls == ["SELECT table_schema AS s FROM `cat`.information_schema.tables WHERE LOWER(table_schema) RLIKE 'metric' "
                     "AND LOWER(table_name) = 'customer_new_loyalty_sign_ups_this_month'",
                     "SHOW CREATE TABLE `cat`.`_metrics`.`customer_new_loyalty_sign_ups_this_month`"]


def test_kpi_first_keeps_the_parameters_the_llm_writes():
    kpi = SRC[SRC.index("def step_generate_kpi_first_metric_views("):]
    kpi = kpi[:kpi.index("\ndef ", 10)]
    shape = kpi[kpi.index("        mv_shape = {"):kpi.index("        kpis_by_domain.setdefault(od, []).append(mv_shape)")]
    assert "'parameters': kpi.get('parameters') or []," in shape
    products = {"ingredient_stock": {"table_name": "ingredient_stock", "domain": "production", "product": "ingredient_stock"}}
    columns = {"ingredient_stock": {"columns": {"ingredient_stock_id", "fiscal_year", "ingredient_cost"}, "string_columns": set(),
                                    "boolean_columns": set(), "col_rewrite_map": {}}}
    spec = {"metric_views": [{"view_name": "production_yearly_ingredient_cost_report", "source_product": "ingredient_stock", "comment": "c", "filter": "",
                              "parameters": [{"name": "p_fiscal_year", "data_type": "INT", "default": "YEAR(CURRENT_DATE)"}], "joins": [],
                              "dimensions": [{"name": "fiscal_year", "expr": "fiscal_year", "comment": "c"}],
                              "measures": [{"name": "total_cost", "expr": "SUM(CASE WHEN fiscal_year = p_fiscal_year THEN ingredient_cost END)", "comment": "c"}]}]}
    out = ah._render_metric_sql_for_domain_from_llm_spec("cat", "production", "production", spec, products, LOG, product_columns=columns, config={})
    text = "\n".join(out[0] if isinstance(out, tuple) else out)
    assert ah._mv_yaml_items(text, "parameters") == [{"name": "p_fiscal_year", "data_type": "INT", "default": "YEAR(current_date())"}]
    assert ah._mv_detail_misses(_spec(views=[YEARLY], measures=[]), {"production_yearly_ingredient_cost_report": text}) == ([], 1)


def test_kpi_first_mandates_the_view_details_the_specs_fix(monkeypatch, caplog):
    table = ["production.ingredient_stock"]
    vs.register(ah, _model(), vs.spec("VREQ-012", "add_metric_view", table, metric_views=[YEARLY],
                                      metric_view_parameters=[{"name": "p_fiscal_year", "data_type": "INT", "default": "YEAR(CURRENT_DATE)"}]),
                vs.spec("VREQ-013", "add_metric_view", table, metric_views=[SIGNUPS], metric_view_measures=[{"expr": SIGNUP_EXPR}]),
                vs.spec("VREQ-014", "drop_metric_view", table, metric_views=["old view"]))
    assert all(ah.vreq_spec(v)["interpretable"] for v in ("VREQ-012", "VREQ-013", "VREQ-014"))
    lines = ah._vreq_spec_metric_view_detail_lines()
    assert lines == [f"the view '{YEARLY}' declares the query parameter p_fiscal_year of type INT with the default YEAR(CURRENT_DATE) in its "
                     "parameters array and uses it by name in a measure expression",
                     f"the view '{SIGNUPS}' carries a measure that computes {SIGNUP_EXPR}, written as valid Databricks SQL with every string "
                     "literal quoted (for example a date unit: date_trunc('month', column))"]

    seen = {}

    def _capture(name, variables, logger):
        seen.update(variables)
        return None
    monkeypatch.setitem(ah.__dict__, "_build_compact_global_model_summary", lambda *a, **k: "summary")
    monkeypatch.setitem(ah.__dict__, "_build_compact_global_fk_summary", lambda *a, **k: "fks")
    monkeypatch.setitem(ah.__dict__, "load_and_format_prompt", _capture)
    wv = {"logger": LOG, "config": {"TARGET_CATALOG": "cat"}, "domains": [{"domain": "production"}],
          "products": [{"domain": "production", "product": "ingredient_stock"}], "attributes": []}
    with caplog.at_level(logging.INFO):
        ah.step_generate_kpi_first_metric_views(wv)
    assert seen["metric_vibe_guidance"].startswith("USER-KING MANDATE (HIGHEST AUTHORITY): the user's requirements fix these details of the views they name: "
                                                   + "; ".join(lines))
    assert any("[kpi-first-spec-details FIRED v5.3.3] 2 view detail(s)" in r.getMessage() for r in caplog.records)


def test_both_metric_prompts_share_one_parameter_rule():
    rule = ah._MV_QUERY_PARAMETER_RULE
    assert rule.startswith("QUERY-TIME PARAMETERS (currency reporting, thresholds, what-if): add a TOP-LEVEL 'parameters' array")
    assert "10. " + rule in ah.PROMPT_TEMPLATES["DOMAIN_METRICS_PROMPT"]
    kpi = ah.PROMPT_TEMPLATES["KPI_FIRST_GLOBAL_PROMPT"]
    assert ("### QUERY-TIME PARAMETERS\n\n" + rule + " A view a requirement asks to take a query parameter declares it with the name, "
            "the data type and the default the requirement gives.") in kpi
    assert '      "parameters": [],\n      "joins": [{{"alias": "dim_<parent_product>"' in kpi  # v5.3.4 join example
    assert SRC.count("QUERY-TIME PARAMETERS (currency reporting") == 1
