"""v5.1.5 — defects found by live run R2 (1079936862964808, agent 5.1.5, vs514 retail, unscoped VOV v1 -> v2).

1. Subdomain names as product targets. The vibe nested bullets under '## customer' / '### loyalty_engagement';
   the extractor wrote targets such as customer.loyalty_engagement and product.merchandise_catalog.sku.sku_status,
   the post-conditions expected a product named after the subdomain, and v2 gained 3 bogus products
   (customer.loyalty_engagement, order.order_management, product.merchandise_catalog).
2. Feedback markers at the end of a bullet (the documented integration-guide 16.3 format) gave every item an
   empty span, so all 11 requirements were 'unmapped' and input_outcomes reported nothing.
3. The SA finding "... rename generic columns to describe their business role ..." was classified as
   rename_product promotion_sku -> describe, and the rename post-condition then rejected every SelfFixer fix for
   that finding ("product.promotion_sku still exists next to product.describe").
4. Two metric views fell back to a row count with METRIC_VIEW_WINDOW_MEASURE_REFERENCES_WINDOW_MEASURE.
"""
import json
import logging
import re
import sys
import types
from pathlib import Path

import pytest

sys.path.insert(0, str(Path(__file__).resolve().parent))
import conftest  # noqa: F401,E402
import agent_helpers as ah  # noqa: E402
from notebook_source_util import notebook_concat_source  # noqa: E402
from test_v515_mv_ref_integrity import _measure_names, _render  # noqa: E402


class _Log:
    def __init__(self):
        self.infos, self.warnings = [], []

    def info(self, msg, *a, **k):
        self.infos.append(str(msg))

    def warning(self, msg, *a, **k):
        self.warnings.append(str(msg))

    error = warning

    def debug(self, *a, **k):
        pass


MODEL = {"model": {"domains": [
    {"name": "customer",
     "subdomains": [{"name": "loyalty_engagement", "products": ["loyalty_account", "campaign"]},
                    {"name": "customer_identity", "products": ["profile"]}],
     "products": [{"name": "loyalty_account", "subdomain": "loyalty_engagement", "attributes": []},
                  {"name": "campaign", "subdomain": "loyalty_engagement", "attributes": []},
                  {"name": "profile", "subdomain": "customer_identity", "attributes": []}]},
    {"name": "order", "subdomains": ["order_management"],
     "products": [{"name": "sales_order", "subdomain": "order_management", "attributes": []},
                  {"name": "line", "subdomain": "order_management", "attributes": []}]},
    {"name": "product", "subdomains": [{"name": "merchandise_catalog"}, {"name": "pricing"}],
     "products": [{"name": "sku", "subdomain": "merchandise_catalog", "attributes": []},
                  {"name": "style", "subdomain": "merchandise_catalog", "attributes": []},
                  {"name": "pricing", "subdomain": "pricing", "attributes": []}]},
]}}


@pytest.mark.parametrize("target,text,expected", [
    ("customer.loyalty_engagement",
     "In the customer domain's loyalty_engagement area, add a new product gift_card with one row per issued gift card",
     "customer.gift_card"),
    ("order.order_management",
     "In the order domain's order_management area, add a foreign key column gift_card_id to the sales_order table "
     "that references customer.gift_card", "order.sales_order"),
    ("product.merchandise_catalog",
     "In the product domain's merchandise_catalog area, add a STRING attribute named season_code to the sku table "
     "holding the merchandising season", "product.sku"),
    ("product.merchandise_catalog.sku.sku_status", "rewrite the description of the sku_status attribute",
     "product.sku.sku_status"),
    ("product.merchandise_catalog.season_code", "add a STRING attribute named season_code to the sku table",
     "product.sku.season_code"),
    ("customer.loyalty_engagement.gift_card", "add a new product gift_card", "customer.gift_card"),
    ("customer.loyalty_engagement", "add product store_credit to this area", "customer.store_credit"),
    ("customer.loyalty_engagement", "tighten the rules in this area", "customer"),
])
def test_a_subdomain_segment_is_dropped_from_a_target(target, text, expected):
    assert ah._vov_target_without_subdomain(target, text, MODEL) == expected


@pytest.mark.parametrize("target", ["product.sku", "product.sku.sku_status", "customer", "product.pricing",
                                    "nosuch.loyalty_engagement", "Model-wide", ""])
def test_a_target_without_a_subdomain_segment_is_left_alone(target):
    assert ah._vov_target_without_subdomain(target, "add a new product gift_card", MODEL) == target


def test_targets_are_left_alone_without_a_model():
    assert ah._vov_target_without_subdomain("customer.loyalty_engagement", "add product x", None) == "customer.loyalty_engagement"


def _vreq(vid, target, intent, quote=""):
    return ah.RawVREQ(vreq_id=vid, intent=intent, target=target, source_quote=quote or intent, source_chunk_id="c1")


def test_normalizing_requirements_retargets_only_the_subdomain_ones_and_logs_it():
    log = _Log()
    keep = _vreq("VREQ-003", "product.sku", "add season_code to sku")
    vreqs = [_vreq("VREQ-001", "customer.loyalty_engagement", "add a new product gift_card"),
             keep,
             _vreq("VREQ-002", "order.order_management, customer.loyalty_engagement.gift_card",
                   "add a foreign key column gift_card_id to the sales_order table")]
    out = ah._vov_normalize_vreq_targets(vreqs, MODEL, log)
    assert [v.target for v in out] == ["customer.gift_card", "product.sku", "order.sales_order, customer.gift_card"]
    assert out[1] is keep
    assert [v.vreq_id for v in out] == ["VREQ-001", "VREQ-003", "VREQ-002"]
    assert out[0].intent == vreqs[0].intent and out[0].source_quote == vreqs[0].source_quote
    assert any("vov-target-subdomain-drop FIRED v5.1.5" in m and "2 requirement target(s)" in m for m in log.infos)


def test_normalizing_clean_requirements_is_silent():
    log = _Log()
    vreqs = [_vreq("VREQ-001", "product.sku", "add season_code")]
    assert ah._vov_normalize_vreq_targets(vreqs, MODEL, log) == vreqs
    assert not log.infos


def _pipeline_body():
    src = notebook_concat_source()
    start = src.index("def run_vov_pipeline(")
    return src[start:src.index("\ndef ", start + 10)]


def test_both_extraction_paths_normalize_targets_before_scope_triage():
    body = _pipeline_body()
    raw = body.index("deduped = _vov_normalize_vreq_targets(deduped, model, logger)")
    assert body.index("_v292_audit_extraction_completeness(vibe_text, deduped") < raw
    assert raw < body.index("_vibe_scope_triage_vreqs(_VIBE_SCOPE_RUNTIME, _vs_work, model, logger)")
    user = body.index("_user_free = _vov_normalize_vreq_targets(_vov_extract_user_free_text(vibe_text, llm, parallel, logger), model, logger)")
    assert user < body.index("_vibe_scope_triage_vreqs(_VIBE_SCOPE_RUNTIME, _user_free, model, logger)")


def test_the_extraction_prompt_keeps_subdomains_out_of_targets():
    assert "never write a subdomain name as a target segment" in notebook_concat_source()


GUIDE_EXAMPLE = (
    "## Domain: procurement\n#### Product: livestock_procurement\n"
    "- (medium) [procurement.livestock_procurement] Rename to livestock_procurement_allocation. "
    "<!-- vi:5b6f0c2e-8d1a-4f3b-9a77-2c4e1d0b9f10 target=procurement.livestock_procurement -->\n"
)

R2_VIBE = (
    "## customer\n### loyalty_engagement\n"
    "- Add a new product gift_card with one row per issued gift card. <!-- vi:item-1 target=customer.gift_card -->\n"
    "## order\n### order_management\n"
    "- In sales_order add a foreign key column gift_card_id that references customer.gift_card. "
    "<!-- vi:item-2 target=order.sales_order.gift_card_id -->\n"
    "## product\n### merchandise_catalog\n"
    "- In sku add a STRING attribute season_code holding the merchandising season. <!-- vi:item-3 target=product.sku.season_code -->\n"
    "- In sku rewrite the description of sku_status so it lists the allowed values. <!-- vi:item-4 target=product.sku.sku_status -->\n"
)


def _span_texts(text):
    body, items = ah._vibe_input_strip(text)
    return body, items, {k: [body[s:e] for s, e in v["spans"]] for k, v in items.items()}


def test_the_documented_end_of_line_marker_owns_its_bullet():
    body, items, texts = _span_texts(GUIDE_EXAMPLE)
    assert "<!--" not in body
    assert texts == {"5b6f0c2e-8d1a-4f3b-9a77-2c4e1d0b9f10": [
        "- (medium) [procurement.livestock_procurement] Rename to livestock_procurement_allocation."]}
    assert items["5b6f0c2e-8d1a-4f3b-9a77-2c4e1d0b9f10"]["target"] == "procurement.livestock_procurement"


def test_each_end_of_line_marker_owns_only_its_own_line():
    _body, _items, texts = _span_texts(R2_VIBE)
    assert texts == {
        "item-1": ["- Add a new product gift_card with one row per issued gift card."],
        "item-2": ["- In sales_order add a foreign key column gift_card_id that references customer.gift_card."],
        "item-3": ["- In sku add a STRING attribute season_code holding the merchandising season."],
        "item-4": ["- In sku rewrite the description of sku_status so it lists the allowed values."],
    }


def test_a_block_marker_stops_at_the_next_end_of_line_marker():
    text = ("<!-- vi:a target=x.y -->\n- block item a\n- still item a\n"
            "- trailing item b <!-- vi:b target=x.z -->\n"
            "- trailing c <!-- vi:c target=x.w --> <!-- vi:d target=x.v -->\n")
    _body, _items, texts = _span_texts(text)
    assert texts == {"a": ["- block item a\n- still item a"], "b": ["- trailing item b"],
                     "c": ["- trailing c"], "d": ["- trailing c"]}


def test_a_leading_inline_marker_still_owns_the_text_after_it():
    text = "- (high) <!-- vi:x-1 target=crew.roster --> Re-point the roster FK\n<!-- vi:x-2 target=Model-wide -->\n- (low) Add audit columns\n"
    _body, _items, texts = _span_texts(text)
    assert texts == {"x-1": ["Re-point the roster FK"], "x-2": ["- (low) Add audit columns"]}


def test_requirements_quoting_end_of_line_bullets_map_to_their_items():
    body, items = ah._vibe_input_strip(R2_VIBE)
    input_map = {"sha": ah._vibe_input_sha(body), "chars": len(body), "items": items, "vreqs": {}}
    quotes = {"VREQ-001": "Add a new product gift_card with one row per issued gift card.",
              "VREQ-002": "In sales_order add a foreign key column gift_card_id that references customer.gift_card.",
              "VREQ-003": "In sku add a STRING attribute season_code holding the merchandising season.",
              "VREQ-004": "In sku rewrite the description of sku_status so it lists the allowed values."}
    vreqs = [types.SimpleNamespace(vreq_id=k, source_quote=q, intent=q, source_chunk_id="") for k, q in quotes.items()]
    out = ah._vibe_input_map_vreqs(input_map, body, vreqs, logger=_Log())
    assert {k: v["item_ids"] for k, v in out.items()} == {
        "VREQ-001": ["item-1"], "VREQ-002": ["item-2"], "VREQ-003": ["item-3"], "VREQ-004": ["item-4"]}
    assert all(v["method"] != "unmapped" for v in out.values())


SA_MULTI_FK = ("Table product.promotion_sku has 2 FK columns pointing to product.sku (sku_id, parent_sku_id) \u2014 rename "
               "generic columns to describe their business role (e.g., inspector_employee_id, approver_employee_id; "
               "origin_plan_id, amendment_plan_id)")


@pytest.mark.parametrize("target", ["product.promotion_sku", "product.sku", "product.promotion_sku.sku_id"])
def test_the_multi_fk_label_finding_is_not_a_product_rename(target):
    vreq = types.SimpleNamespace(source_quote=SA_MULTI_FK, intent=SA_MULTI_FK, target=target)
    assert ah._v413_vreq_to_det_op(vreq, MODEL) is None
    assert ah._v337_classify_op("", target, SA_MULTI_FK, SA_MULTI_FK, MODEL) is None


def test_the_multi_fk_label_finding_yields_no_rename_pair_for_the_post_condition():
    vreq = types.SimpleNamespace(source_quote=SA_MULTI_FK, intent=SA_MULTI_FK, target="product.promotion_sku")
    assert ah._vov_rename_pairs_for_vreqs([vreq], MODEL) == []


@pytest.mark.parametrize("text,expected", [
    ("Rename to livestock_procurement_allocation.", "livestock_procurement_allocation"),
    ("rename product order.sales_order to order_header", "order_header"),
    ("stub table x must be renamed to existing y", "y"),
    ("merge claimant into the claim table", "claim"),
    ("merge claimant into claim", "claim"),
    ("Rename the sales_order table to order_header because it is the header", "order_header"),
    ("rename generic columns to describe their business role", None),
    ("rename them to reflect the lifecycle", None),
    ("rename generic columns to describe their role; rename table x to x_header.", "x_header"),
])
def test_the_rename_target_is_a_name_not_a_verb_phrase(text, expected):
    assert ah._v301_extract_rename_target(text) == expected


@pytest.mark.parametrize("text,expected", [
    ("rename column status to lifecycle_status", ("status", "lifecycle_status")),
    ("Rename attribute qty to quantity.", ("qty", "quantity")),
    ("the column status should be renamed to order_status", ("status", "order_status")),
    ("rename the column status to reflect the lifecycle", None),
    ("add a foreign key column gift_card_id to the sales_order table", None),
])
def test_the_column_rename_target_is_a_name_not_a_verb_phrase(text, expected):
    assert ah._v337_extract_col_rename(text) == expected


def test_a_real_product_rename_still_classifies():
    vreq = types.SimpleNamespace(source_quote="", intent="Rename the sales_order table to order_header", target="order.sales_order")
    assert ah._v413_vreq_to_det_op(vreq, MODEL) == ("rename_product", "order", "sales_order", "order_header")


INVOICE_MODEL = {"model": {"domains": [{"name": "finance", "products": [
    {"name": "customer_invoice", "primary_key": "customer_invoice_id",
     "attributes": [{"name": "customer_invoice_id"}, {"name": "invoice_channel"}, {"name": "status"}]}]}]}}


@pytest.mark.parametrize("text,expected", [
    ("Rename the column invoice_channel in the product customer_invoice to delivery_channel.", ("invoice_channel", "delivery_channel")),
    ("In the finance domain, rename the column 'invoice_channel' in the product 'customer_invoice' to 'delivery_channel'.",
     ("invoice_channel", "delivery_channel")),
    ("Rename the attribute status of the customer_invoice table to invoice_status", ("status", "invoice_status")),
    ("Rename the field invoice_channel in table customer_invoice to delivery_channel", ("invoice_channel", "delivery_channel")),
])
def test_a_column_rename_that_names_its_table_renames_the_column(text, expected):
    vreq = types.SimpleNamespace(source_quote=text, intent=text, target="finance.customer_invoice")
    op = ah._v413_vreq_to_det_op(vreq, INVOICE_MODEL)
    assert op == ("rename_attribute", "finance", "customer_invoice") + expected, (
        "live R25 79132951735533 renamed the product finance.customer_invoice to delivery_channel")


@pytest.mark.parametrize("text,expected", [
    ("Rename the product customer_invoice to client_invoice", ("rename_product", "finance", "customer_invoice", "client_invoice")),
    ("Rename the product customer_invoice in the finance domain to client_invoice",
     ("rename_product", "finance", "customer_invoice", "client_invoice")),
    ("Rename the product customer_invoice to client_invoice and update the attribute descriptions", None),
])
def test_a_product_rename_is_still_a_product_rename_unless_a_column_is_named(text, expected):
    vreq = types.SimpleNamespace(source_quote=text, intent=text, target="finance.customer_invoice")
    assert ah._v413_vreq_to_det_op(vreq, INVOICE_MODEL) == expected


@pytest.mark.parametrize("text", [
    "Rename the customer_invoice table's invoice_channel column to delivery_channel",
    "Rename the invoice_channel column in the customer_invoice table to delivery_channel",
])
def test_a_column_rename_is_never_applied_as_a_product_rename(text):
    vreq = types.SimpleNamespace(source_quote=text, intent=text, target="finance.customer_invoice")
    op = ah._v413_vreq_to_det_op(vreq, INVOICE_MODEL)
    assert op is None or op[0] == "rename_attribute"


def _rename_rows():
    return [{"domain": "finance", "product": "delivery_channel", "attribute": "delivery_channel_id", "foreign_key_to": ""},
            {"domain": "finance", "product": "delivery_channel", "attribute": "invoice_channel", "foreign_key_to": ""},
            {"domain": "finance", "product": "payment", "attribute": "channel_ref", "foreign_key_to": "finance.delivery_channel.invoice_channel"}]


def _rename(attrs, column, new_name, log):
    action = {"action": "rename", "scope": "attribute", "name": f"finance.delivery_channel.{column}", "target_state": new_name}
    products = [{"domain": "finance", "product": "delivery_channel", "primary_key": "delivery_channel_id"}]
    return ah.apply_mutation_command(action, [{"domain": "finance"}], products, attrs, {}, log)


@pytest.fixture
def _ledger():
    ah.vov_ledger_reset()
    yield
    ah.vov_ledger_reset()


def test_a_rename_to_a_sentence_is_refused(_ledger):
    attrs, log = _rename_rows(), logging.getLogger("t")
    prose = "Column renamed from invoice_channel to dispatch_channel in finance.delivery_channel."
    assert _rename(attrs, "invoice_channel", prose, log) == (True, {"applied": 0, "reason": "invalid_new_name"}), (
        "live R26 824350583887071 recorded a rename to that sentence")
    assert [a["attribute"] for a in attrs][:2] == ["delivery_channel_id", "invoice_channel"]
    assert ah.vov_rename_events() == []


def test_a_rename_of_a_missing_column_records_nothing(_ledger):
    attrs, log = _rename_rows(), logging.getLogger("t")
    attrs[2]["foreign_key_to"] = "finance.delivery_channel.no_such_column"
    assert _rename(attrs, "no_such_column", "dispatch_channel", log) == (True, {"applied": 0, "reason": "source_missing"})
    assert ah.vov_rename_events() == [] and attrs[2]["foreign_key_to"] == "finance.delivery_channel.no_such_column"


def test_a_rename_that_already_landed_is_protected_and_a_new_one_applies(_ledger):
    attrs, log = _rename_rows(), logging.getLogger("t")
    ok, meta = _rename(attrs, "invoice_channel", "dispatch_channel", log)
    assert ok and meta["applied"] == 1 and attrs[1]["attribute"] == "dispatch_channel"
    assert attrs[2]["foreign_key_to"] == "finance.delivery_channel.dispatch_channel"
    ok, meta = _rename(attrs, "invoice_channel", "dispatch_channel", log)
    assert ok and meta["applied"] == 0 and meta["renamed_attribute"]["new"] == "finance.delivery_channel.dispatch_channel"
    assert ah._is_user_renamed_attribute("finance", "delivery_channel", "dispatch_channel")


WINDOW_ON_WINDOW = [
    {"name": "Return Count", "expr": "COUNT(1)"},
    {"name": "Returns CM", "expr": "COUNT(1)", "window": [{"order": "return_requested_month", "range": "current", "semiadditive": "last"}]},
    {"name": "Returns Trailing", "expr": "AGG(`Returns CM`)",
     "window": [{"order": "return_requested_month", "range": "trailing 3 month", "semiadditive": "last"}]},
    {"name": "Count PM", "expr": "AGG(`Return Count`)",
     "window": [{"order": "return_requested_month", "range": "current", "semiadditive": "last", "offset": "-1 month"}]},
    {"name": "CM Share", "expr": "AGG(`Returns CM`) / NULLIF(AGG(`Return Count`), 0)"},
    {"name": "Trailing Share", "expr": "AGG(`Returns Trailing`) / NULLIF(AGG(`Return Count`), 0)"},
]


def test_a_window_measure_reading_a_window_measure_is_dropped_with_its_dependents():
    yaml_text, log = _render(WINDOW_ON_WINDOW)
    names = _measure_names(yaml_text)
    assert "Returns Trailing" not in names, "METRIC_VIEW_WINDOW_MEASURE_REFERENCES_WINDOW_MEASURE live"
    assert "Trailing Share" not in names, "a measure on a dropped measure fails UNRESOLVED_COLUMN live"
    assert names == ["Return Count", "Returns CM", "Count PM", "CM Share"]
    assert any("window measure references window measure(s)" in w and "Returns Trailing" in w for w in log.warnings)


STMT_WINDOW_ON_WINDOW = (
    "CREATE OR REPLACE VIEW `c`.`_metrics`.`order_line`\nWITH METRICS\nLANGUAGE YAML\nAS $$\n  version: 1.1\n"
    '  source: "`c`.`order`.`line`"\n  dimensions:\n'
    '    - name: "line_created_month"\n      display_name: "Line Created Month"\n      expr: DATE_TRUNC(\'month\', created_at)\n'
    "  measures:\n"
    '    - name: "Lines"\n      expr: COUNT(1)\n'
    '    - name: "Lines CM"\n      expr: COUNT(1)\n      window:\n        - order: line_created_month\n          range: current\n'
    '    - name: "Lines CM Trailing"\n      expr: AGG(`Lines CM`)\n      window:\n        - order: line_created_month\n'
    "          range: trailing 3 month\n"
    '    - name: "Lines PM"\n      expr: AGG(`Lines`)\n      window:\n        - order: line_created_month\n          range: current\n'
    '    - name: "Lines Share"\n      expr: AGG(`Lines CM`) / NULLIF(AGG(`Lines`), 0)\n$$'
)


def test_the_yaml_pass_drops_a_window_measure_reading_a_window_measure():
    out, drops, rewrites = ah._mv_yaml_drop_dangling_refs(STMT_WINDOW_ON_WINDOW)
    names = re.findall(r'^\s*-\s*name:\s*"([^"]+)"', out.split("measures:", 1)[1], re.M)
    assert names == ["Lines", "Lines CM", "Lines PM", "Lines Share"], names
    assert [d[0] for d in drops] == ["Lines CM Trailing"] and rewrites == 0


def test_window_on_window_ignores_self_and_non_window_references():
    entries = [("a", [], True), ("b", ["a"], True), ("c", ["a"], False), ("d", ["d"], True), ("e", ["c"], True)]
    assert [n for n, _why in ah._mv_window_on_window(entries)] == ["b"]


def test_the_metric_view_prompt_forbids_window_on_window():
    assert "A measure with a 'window' may not AGG() another measure that has its own 'window'." in notebook_concat_source()


def _upload_calls(src):
    for m in re.finditer(r"files\.upload\(", src):
        depth, end = 0, None
        for k in range(m.end() - 1, min(len(src), m.end() + 600)):
            if src[k] == "(":
                depth += 1
            elif src[k] == ")":
                depth -= 1
                if depth == 0:
                    end = k
                    break
        yield src[m.start():(end or m.end()) + 1]


def test_every_files_upload_call_passes_a_stream_not_bytes():
    installer = Path(__file__).resolve().parents[3] / "model-installer" / "data-model-installer.ipynb"
    sources = {"agent": notebook_concat_source(),
               "installer": "\n".join("".join(c["source"]) for c in json.loads(installer.read_text())["cells"] if c.get("cell_type") == "code")}
    calls = [(name, call) for name, src in sources.items() for call in _upload_calls(src)]
    assert len(calls) >= 12
    raw = [(name, call) for name, call in calls if re.search(r"\.encode\(|\bb['\"]", call) and "BytesIO" not in call]
    assert raw == [], "WorkspaceClient.files.upload needs a binary stream; bytes fail with 'bytes' object has no attribute 'seekable'"


def test_an_attribute_rename_carries_the_cause_its_pass_recorded():
    import copy as _copy
    repo = Path(__file__).resolve().parents[3]
    raw = json.loads((repo / "data-models" / "airlines" / "v1" / "mvm" / "model.json").read_text())
    dom = raw["model"]["domains"][0]
    prod = dom["products"][0]
    old = prod["attributes"][1]["name"]
    cur = _copy.deepcopy(raw)
    cur["model"]["domains"][0]["products"][0]["attributes"][1]["name"] = "primary_" + old
    ah.vov_ledger_reset()
    ah._vov_record_rename("attribute", f"{dom['name']}.{prod['name']}.{old}", f"{dom['name']}.{prod['name']}.primary_{old}",
                          "pass:p016_ambiguous_fk_rename")
    changes = ah.vov_entity_changes(raw, cur, {"operation": "vibe modeling of version"})
    hit = [e for e in changes["entries"] if e["kind"] == "attribute" and e["status"] == "renamed"]
    assert len(hit) == 1 and hit[0]["base_path"].endswith(f".{old}"), hit
    assert "pass:p016_ambiguous_fk_rename" in hit[0]["cause"], hit[0]


def _one_product_model(description="Status of the SKU.", attr_type="STRING"):
    return {"model": {"domains": [{"name": "product", "products": [{"name": "sku", "primary_key": "sku_id", "description": "A sellable item.",
                                                                     "attributes": [{"name": "sku_id", "type": "STRING"},
                                                                                    {"name": "sku_status", "type": attr_type, "description": description}]}]}]}}


def test_a_description_rewrite_is_a_real_change_for_the_noop_guard():
    diff = ah.diff_models_summary(_one_product_model(), _one_product_model("Allowed values: active, discontinued, seasonal."))
    assert int(diff.get("n_products_modified", 0)) == 1, diff


def test_a_type_change_is_a_real_change_for_the_noop_guard():
    diff = ah.diff_models_summary(_one_product_model(), _one_product_model(attr_type="INT"))
    assert int(diff.get("n_products_modified", 0)) == 1, diff


def test_an_identity_mutator_is_still_a_noop():
    diff = ah.diff_models_summary(_one_product_model(), _one_product_model())
    assert int(diff.get("n_products_modified", 0)) == 0 and not diff.get("products_added"), diff


@pytest.mark.parametrize("raw,expected,fixes", [
    (["VREQ-0001", "VREQ-0002"], ("VREQ-0001", "VREQ-0002"), []),
    (["VREQ-001", "VREQ-0002"], ("VREQ-0001", "VREQ-0002"), [("VREQ-001", "VREQ-0001")]),
    (["VREQ-9", "AUDIT-P1-02"], ("AUDIT-P1-2",), [("VREQ-9", None), ("AUDIT-P1-02", "AUDIT-P1-2")]),
    (["VREQ-001", "VREQ-0001"], ("VREQ-0001",), [("VREQ-001", "VREQ-0001")]),
])
def test_batcher_ids_are_reconciled_to_the_input_requirements(raw, expected, fixes):
    lookup = {"VREQ-0001": 1, "VREQ-0002": 2, "AUDIT-P1-2": 3}
    assert ah._vov_reconcile_batch_ids(raw, lookup) == (expected, fixes)


class _BatcherLLM:
    def __init__(self, ids):
        self.ids = ids

    def complete_json(self, **_kw):
        return {"batches": [{"batch_id": "B1", "vreq_ids": self.ids, "intent_summary": "add a product", "target_entities": [["customer", "gift_card"]]}]}


def test_a_batch_naming_a_three_digit_id_carries_the_real_requirement():
    vreqs = [ah.RawVREQ(vreq_id="VREQ-0001", intent="add product gift_card", target="customer.gift_card", source_quote="add product gift_card", source_chunk_id="c")]
    batches = ah.batch_vreqs(vreqs, llm=_BatcherLLM(["VREQ-001"]))
    assert [b.vreq_ids for b in batches] == [("VREQ-0001",)]


def test_the_completeness_auditor_cannot_re_add_a_quote_the_extractor_already_holds():
    existing = [ah.RawVREQ(vreq_id="VREQ-0002", intent="add FK", target="order.sales_order",
                           source_quote="In sales_order add a foreign key column gift_card_id that references customer.gift_card.", source_chunk_id="c")]
    assert ah._v292_duplicate_of("In sales_order add a foreign key column gift_card_id that references customer.gift_card", existing) == "VREQ-0002"
    assert ah._v292_duplicate_of("In sku add a STRING attribute season_code", existing) is None

    class _Auditor:
        def complete_json(self, **_kw):
            return {"missing": [{"intent": "add FK gift_card_id", "target": "order.sales_order",
                                 "source_quote": "In sales_order add a foreign key column gift_card_id that references customer.gift_card."}]}

    log = _Log()
    out, recovered = ah._v292_audit_extraction_completeness("vibe text", existing, _Auditor(), log, max_passes=1)
    assert recovered == 0 and [v.vreq_id for v in out] == ["VREQ-0002"]
    assert any("vov-extract-audit-dedupe FIRED v5.1.6" in m for m in log.infos)


def test_batch_targets_that_name_a_subdomain_fall_back_to_the_requirement_text():
    targets, named = ah._vov_batch_targets_without_subdomains((("product", "merchandise_catalog"), ("product", "sku")), MODEL)
    assert targets == (("product", "*"), ("product", "sku")) and named == ["product.merchandise_catalog"]
    assert ah._vov_batch_targets_without_subdomains((("product", "sku"),), MODEL) == ((("product", "sku"),), [])
    assert ah._vov_batch_targets_without_subdomains((("product", "pricing"),), MODEL) == ((("product", "pricing"),), [])


class _SubdomainBatcherLLM:
    def complete_json(self, **_kw):
        return {"batches": [{"batch_id": "B1", "vreq_ids": ["VREQ-0001"], "intent_summary": "add size_chart",
                             "target_entities": [["product", "merchandise_catalog"]]}]}


def test_the_batcher_never_hands_a_subdomain_to_the_mutator_as_a_product():
    vreqs = [ah.RawVREQ(vreq_id="VREQ-0001", intent="In the product domain's merchandise_catalog area, add a column to the sku table",
                        target="product.sku", source_quote="add a column to the sku table", source_chunk_id="c")]
    batches = ah.batch_vreqs(vreqs, llm=_SubdomainBatcherLLM(), model_snapshot=MODEL)
    assert all(t != ("product", "merchandise_catalog") for b in batches for t in b.target_entities), [b.target_entities for b in batches]
