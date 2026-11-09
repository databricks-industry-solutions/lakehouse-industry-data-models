"""v5.3.4 — metric-view joins are ON by default and render in the shape a live UC runtime installs.

Live probe (2026-11-09, SQL warehouse, YAML 1.1) of the renderer's exact join YAML: name/source/'on'/rely joins
install and query cross-schema with joined columns in dims, measures and filter. The ONLY failing shape was an
LLM-invented alias for the primary table inside the join condition (`o.customer_id = dim_customer.customer_id`) ->
UNRESOLVED_COLUMN — the v1.0.0 signature that got joins disabled. These tests drive the production renderer.
"""
import re
import sys
from pathlib import Path

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


def _attr(domain, product, col, pk=False):
    return {"domain": domain, "product": product, "column_name": col, "attribute": col,
            "tags": "primary_key" if pk else ""}


PRODUCTS = {"order_header": {"table_name": "order_header", "domain": "sales", "product": "order_header",
                             "primary_key": "order_header_id"}}
COLUMNS = {"order_header": {"columns": {"order_header_id", "customer_id", "order_amount", "order_date", "order_status"},
                            "string_columns": {"order_status"}, "boolean_columns": set(), "col_rewrite_map": {}}}
CUSTOMER = {"table_name": "customer", "domain": "party", "product": "customer", "primary_key": "customer_id"}
CUSTOMER_ATTRS = [_attr("party", "customer", "customer_id", pk=True), _attr("party", "customer", "customer_segment"),
                  _attr("party", "customer", "region_code")]


def _config(**over):
    cfg = {"_metric_view_all_products_by_key": {"party.customer": CUSTOMER, "sales.order_header": PRODUCTS["order_header"]},
           "_metric_view_all_attrs_by_key": {"party.customer": CUSTOMER_ATTRS},
           "_per_domain_domain_to_db_map": {"party": "party", "sales": "sales"}}
    cfg.update(over)
    return cfg


def _spec(join_on, dims=None, measures=None, filt=""):
    return {"metric_views": [{
        "view_name": "order_revenue",
        "source_product": "order_header",
        "filter": filt,
        "joins": [{"alias": "dim_customer", "target_domain": "party", "target_product": "customer", "on": join_on, "type": "LEFT"}],
        "dimensions": dims or [
            {"name": "customer_segment", "expr": "dim_customer.customer_segment", "comment": "segment"},
            {"name": "order_month", "expr": "DATE_TRUNC('month', o.order_date)", "comment": "month"},
        ],
        "measures": measures or [
            {"name": "Total Revenue", "expr": "SUM(o.order_amount)", "comment": "revenue"},
            {"name": "Customers", "expr": "COUNT(DISTINCT dim_customer.customer_id)", "comment": "customers"},
        ],
    }]}


def _render(spec, cfg=None):
    log = _Log()
    out = ah._render_metric_sql_for_domain_from_llm_spec(
        "cat", "sales", "sales", spec, PRODUCTS, log, product_columns=COLUMNS, config=_config() if cfg is None else cfg)
    stmts = out[0] if isinstance(out, tuple) else out
    assert stmts, "the view must render"
    return "\n".join(stmts), log


def _names(yaml_text, section):
    block = yaml_text.split(f"  {section}:", 1)[1]
    block = re.split(r"\n  [a-z]+:", block, 1)[0]
    return re.findall(r'^\s*-\s*name:\s*"([^"]+)"', block, re.M)


def test_join_is_emitted_by_default():
    yaml_text, _ = _render(_spec("source.customer_id = dim_customer.customer_id"))
    assert "  joins:" in yaml_text, "joins must render without any config flag"
    assert "source: \"`cat`.`party`.`customer`\"" in yaml_text
    assert "at_most_one_match: true" in yaml_text


def test_llm_primary_alias_in_on_is_rewritten_to_source_and_stripped_from_exprs():
    yaml_text, log = _render(_spec("o.customer_id = dim_customer.customer_id"))
    assert "'on': source.customer_id = dim_customer.customer_id" in yaml_text
    assert "o.customer_id" not in yaml_text and "o.order_amount" not in yaml_text and "o.order_date" not in yaml_text
    assert re.search(r"SUM\((CAST\()?order_amount", yaml_text), "the source alias must be stripped from measures, not drop the measure"
    assert "Total Revenue" in _names(yaml_text, "measures")
    assert "order_month" in _names(yaml_text, "dimensions")
    assert "customer_segment" in _names(yaml_text, "dimensions")
    assert any("mv-join-on-source-alias FIRED" in i for i in log.infos)


def test_bare_source_column_in_on_is_qualified():
    yaml_text, _ = _render(_spec("customer_id = dim_customer.customer_id"))
    assert "'on': source.customer_id = dim_customer.customer_id" in yaml_text


def test_fan_out_join_not_on_target_pk_is_skipped():
    # joining on a non-key column of the target can match many rows -> silent double counting
    yaml_text, log = _render(_spec("source.order_status = dim_customer.region_code"))
    assert "  joins:" not in yaml_text
    assert "customer_segment" not in _names(yaml_text, "dimensions"), "a dim on a skipped join must be dropped"
    assert any("mv-join-many-to-one FIRED" in w for w in log.warnings)


def test_join_condition_on_a_column_the_target_lacks_is_skipped():
    yaml_text, log = _render(_spec("source.customer_id = dim_customer.cust_key"))
    assert "  joins:" not in yaml_text
    assert any("mv-join-many-to-one FIRED" in w for w in log.warnings)


def test_alias_column_not_on_joined_table_is_dropped():
    # order_amount exists on the SOURCE, not on customer: the merged valid-columns set used to accept it
    dims = [{"name": "bad_dim", "expr": "dim_customer.order_amount", "comment": "x"},
            {"name": "customer_segment", "expr": "dim_customer.customer_segment", "comment": "ok"}]
    yaml_text, _ = _render(_spec("source.customer_id = dim_customer.customer_id", dims=dims))
    names = _names(yaml_text, "dimensions")
    assert "bad_dim" not in names and "customer_segment" in names


def test_filter_on_joined_column_survives():
    yaml_text, _ = _render(_spec("source.customer_id = dim_customer.customer_id", filt="dim_customer.region_code IS NOT NULL"))
    assert "filter: dim_customer.region_code IS NOT NULL" in yaml_text


def test_flag_false_still_disables_joins():
    yaml_text, log = _render(_spec("source.customer_id = dim_customer.customer_id"), cfg=_config(MV_ENABLE_JOINS=False))
    assert "  joins:" not in yaml_text
    assert any("suppressed_joins=1" in i for i in log.infos)


def test_single_table_view_unchanged_and_source_prefix_stripped():
    spec = {"metric_views": [{"view_name": "order_counts", "source_product": "order_header", "joins": [],
                              "dimensions": [{"name": "order_status", "expr": "order_status", "comment": "s"}],
                              "measures": [{"name": "Orders", "expr": "COUNT(source.order_header_id)", "comment": "n"}]}]}
    yaml_text, _ = _render(spec)
    assert "joins:" not in yaml_text
    assert "COUNT(order_header_id)" in yaml_text


def test_column_rewriter_leaves_qualified_tokens_alone():
    out = ah._rewrite_column_refs_in_expr("SUM(amt) + MAX(dim_x.amt)", {"amt": "amount_value"})
    assert out == "SUM(amount_value) + MAX(dim_x.amt)"


def test_prompts_no_longer_forbid_joins():
    src = notebook_concat_source()
    assert "JOINS ARE DISABLED" not in src
    assert src.count("alias=mv-prompt-joins-enabled") >= 2
    assert '"leg.origin_region_code"' not in src, "the KPI example must not alias the source table"
