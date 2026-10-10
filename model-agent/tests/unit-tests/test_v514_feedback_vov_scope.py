"""v5.1.4 feedback F2: base model loaded at setup, VOV pins, QA scoped to VREQ-touched entities, review preservation gate."""
import copy
import sys
from pathlib import Path

import pytest

sys.path.insert(0, str(Path(__file__).resolve().parent))
import v514_feedback_util as fu  # noqa: E402
from v514_feedback_util import ah  # noqa: E402
from notebook_source_util import slice_function_source  # noqa: E402


@pytest.fixture(autouse=True)
def _isolate_runtime(monkeypatch):
    fu.inject_spark_types(monkeypatch)
    pinned = set(ah._USER_PINNED_DOMAINS_RUNTIME)
    yield
    ah.set_vibe_scope_runtime(None)
    ah._USER_PINNED_DOMAINS_RUNTIME.clear()
    ah._USER_PINNED_DOMAINS_RUNTIME.update(pinned)


def test_preload_reads_the_resolved_base_version_from_the_metamodel_catalog(monkeypatch, tmp_path):
    volume = fu.VolumeRedirect(monkeypatch, tmp_path)
    volume.put(fu.model_json_path("mm_cat", "airlines", "3", "mvm"), fu.RAW)
    wv = {"ai_agent": object(), "business_name": "Airlines", "model_version": "1", "base_version_for_review": "3",
          "metamodel_root_catalog": "mm_cat", "deployment_catalog": "inst_cat", "model_scope": "mvm",
          "data_model_scopes": "Minimum Viable Model - MVM", "business_context_raw": {"business_information": {}}}
    result = ah.run_vov_2_against_widgets(wv, fu.RecordingLogger(), vibe_text="")
    assert result["outcomes"] == []
    assert len(wv["domains"]) == 15 and len(wv["products"]) == 205
    assert len(wv["_v357_v1_products_snapshot"]) == 205
    assert wv["business_context_file_path"].lower() == fu.model_json_path("mm_cat", "airlines", "3", "mvm").lower()


def test_shared_loader_prefers_the_context_model():
    wv = {"business_context_raw": copy.deepcopy(fu.RAW), "business_name": "Airlines", "deployment_catalog": "inst_cat"}
    blob, source = ah._resolve_base_model_json(wv, None, base_version="7")
    assert source == "business_context_raw" and blob["model"]["domains"]


def test_shared_loader_falls_back_from_a_missing_widget_path_to_the_registry_volume(monkeypatch, tmp_path):
    volume = fu.VolumeRedirect(monkeypatch, tmp_path)
    volume.put(fu.model_json_path("inst_cat", "Airlines", "2", "mvm"), fu.small_model("v2_mvm"))
    wv = {"business_name": "Airlines", "deployment_catalog": "inst_cat", "business_context_file_path": "/Volumes/gone/model.json"}
    blob, source = ah._resolve_base_model_json(wv, fu.RecordingLogger(), base_version="2", model_scope="mvm")
    assert source.startswith("disk:derived:v2/mvm") and blob["model"]["version"] == "v2_mvm"
    assert wv["business_context_raw"]["model"]["version"] == "v2_mvm"
    assert wv["business_context_file_path"].lower() == fu.model_json_path("inst_cat", "airlines", "2", "mvm").lower()


def test_shared_loader_honours_an_explicit_scope_and_hydrate_flag(monkeypatch, tmp_path):
    volume = fu.VolumeRedirect(monkeypatch, tmp_path)
    volume.put(fu.model_json_path("inst_cat", "airlines", "1", "ecm"), fu.small_model("v1_ecm"))
    wv = {"business_name": "Airlines", "deployment_catalog": "inst_cat"}
    assert ah._resolve_base_model_json(wv, None, base_version="1", model_scope="mvm") == (None, None)
    blob, _source = ah._resolve_base_model_json(wv, None, base_version="1", model_scope="ecm", hydrate=False)
    assert blob["model"]["version"] == "v1_ecm" and "business_context_raw" not in wv


def test_preload_and_setup_share_one_loader():
    assert "_resolve_base_model_json(widgets_values, logger, base_version=widgets_values.get(\"base_version_for_review\")" in slice_function_source("run_vov_2_against_widgets")
    setup = slice_function_source("step_setup_and_clean")
    assert setup.count("_resolve_base_model_json(") == 3
    assert "with open(_bcfp" not in setup


def _registered_vov_setup(monkeypatch, tmp_path, vibes=None, business_domains=""):
    volume = fu.VolumeRedirect(monkeypatch, tmp_path)
    volume.put(fu.model_json_path("inst_cat", "airlines", "1", "mvm"), fu.RAW)
    fake = fu.register(fu.FakeSpark(), "inst_cat")
    wv = fu.setup_widgets(fu.VOV, business_domains=business_domains, vibes=vibes)
    config = fu.run_setup(monkeypatch, wv, fake)
    return wv, config


def test_vov_setup_loads_the_base_model_before_preserving_v1_domains(monkeypatch, tmp_path):
    wv, _config = _registered_vov_setup(monkeypatch, tmp_path)
    assert wv["business_context_raw"]["model"]["domains"]
    assert wv["_preserve_v1_domains"] == fu.AIRLINES_DOMAINS
    notes = [s for s in wv["_vov_pending_sentinels"] if "[vov-base-model-setup-load FIRED v5.1.4]" in s]
    assert len(notes) == 1 and "domains=15" in notes[0]


def test_vov_widget_domains_are_pins_not_a_closed_roster(monkeypatch, tmp_path):
    wv, config = _registered_vov_setup(monkeypatch, tmp_path, business_domains="crew, flight")
    sizing = wv.get("sizing_directives") or {}
    assert not {"user_domains_exhaustive", "max_domains", "min_domains"} & set(sizing)
    assert {"crew", "flight"} <= ah._USER_PINNED_DOMAINS_RUNTIME
    assert any("[vov-domains-are-pins FIRED v5.1.4]" in s for s in wv["_vov_pending_sentinels"])


def test_new_base_model_widget_domains_still_close_the_roster(monkeypatch):
    wv = fu.setup_widgets(fu.NEW_BASE, business_domains="crew, flight")
    fu.run_setup(monkeypatch, wv, fu.FakeSpark())
    sizing = wv["sizing_directives"]
    assert sizing["user_domains_exhaustive"] is True and sizing["max_domains"] == 2 and sizing["min_domains"] == 2


class _NoLLM:
    def __getattr__(self, name):
        def _call(*_a, **_k):
            raise RuntimeError(f"no LLM in unit tests: {name}")
        return _call


def _qa_config(operation=fu.VOV, v1_domains=("crm", "billing"), extra_wv=None):
    wv = {"operation": operation, "_preserve_v1_domains": list(v1_domains)}
    wv.update(extra_wv or {})
    return {
        "PROMPT_VARIABLES": {"min_attributes_per_product": 1, "min_data_products_per_domain": 1,
                             "business_config": {"business": "Airlines", "description": "An airline", "business_context": {}}},
        "MODEL_CONVENTIONS": {"primary_key_suffix": "_id", "data_asset_naming_convention": "snake_case"},
        "MAX_CONCURRENT_BATCHES": 2,
        "_widgets_values": wv,
    }


def _move_billing_to_crm(calls):
    def _fit(domains_data, products_data, attributes_data, logger, ai_agent, config, products_scope=None, protected_products=None):
        calls.append(products_scope)
        moved = 0
        for p in products_data:
            if p["domain"] == "billing" and (products_scope is None or f"billing.{p['product']}" in products_scope):
                p["domain"] = "crm"
                moved += 1
        for a in attributes_data:
            if a["domain"] == "billing":
                a["domain"] = "crm"
            if str(a.get("foreign_key_to") or "").startswith("billing."):
                a["foreign_key_to"] = "crm." + a["foreign_key_to"].split(".", 1)[1]
        return moved
    return _fit


def _flat(model=None):
    d, p, a, _mv = ah.model_to_widgets_flat(model or fu.small_model())
    return list(d), list(p), list(a)


def test_qa_relocation_that_empties_a_v1_domain_keeps_the_domain(monkeypatch):
    calls = []
    monkeypatch.setitem(ah.__dict__, "run_product_domain_location_fit", _move_billing_to_crm(calls))
    d, p, a = _flat()
    ah.run_quality_assurance_checks(d, p, a, fu.RecordingLogger(), _NoLLM(), _qa_config(),
                                    protected_artifacts={"products": ["billing.invoice", "billing.payment"], "domains": [], "links": []})
    assert [x["domain"] for x in d] == ["crm", "billing"]
    assert {x["product"]: x["domain"] for x in p} == {"customer": "crm", "invoice": "crm", "payment": "crm"}
    assert calls == [["billing.invoice", "billing.payment"]]


def test_qa_relocation_skips_untouched_products_in_vov(monkeypatch):
    calls = []
    monkeypatch.setitem(ah.__dict__, "run_product_domain_location_fit", _move_billing_to_crm(calls))
    d, p, a = _flat()
    log = fu.RecordingLogger()
    ah.run_quality_assurance_checks(d, p, a, log, _NoLLM(), _qa_config(), protected_artifacts={"products": ["crm.customer"], "domains": [], "links": []})
    assert calls == [["crm.customer"]]
    assert {x["product"]: x["domain"] for x in p} == {"customer": "crm", "invoice": "billing", "payment": "billing"}
    calls.clear()
    ah.run_quality_assurance_checks(d, p, a, log, _NoLLM(), _qa_config(), protected_artifacts={"products": [], "domains": [], "links": []})
    assert calls == []
    assert "[vov-qa-scope FIRED v5.1.4] Step 7A-0.4 relocation limited to 0" in log.text()


def test_qa_domain_level_vreq_target_opens_the_whole_domain(monkeypatch):
    calls = []
    monkeypatch.setitem(ah.__dict__, "run_product_domain_location_fit", _move_billing_to_crm(calls))
    d, p, a = _flat()
    outcome = {"status": "applied", "target_entities": [["billing", "*"]]}
    ah.run_quality_assurance_checks(d, p, a, fu.RecordingLogger(), _NoLLM(),
                                    _qa_config(extra_wv={"_vov_2_pipeline_result": {"outcomes": [outcome]}}),
                                    protected_artifacts={"products": [], "domains": [], "links": []})
    assert calls == [["billing.invoice", "billing.payment"]]


def test_non_vov_qa_is_unchanged(monkeypatch):
    calls = []
    monkeypatch.setitem(ah.__dict__, "run_product_domain_location_fit", _move_billing_to_crm(calls))
    d, p, a = _flat()
    ah.run_quality_assurance_checks(d, p, a, fu.RecordingLogger(), _NoLLM(), _qa_config(operation=fu.NEW_BASE, v1_domains=()),
                                    protected_artifacts=None)
    assert calls == [None]
    assert [x["domain"] for x in d] == ["crm"]


def _dedup_model():
    def product(name, extra=()):
        attrs = [fu._attr(f"{name}_id", "bigint", "primary_key"), fu._attr("full_name"), fu._attr("email")] + list(extra)
        return {"name": name, "table_name": name, "primary_key": f"{name}_id", "description": name, "attributes": attrs}
    model = fu.small_model()
    model["model"]["domains"] = [
        {"name": "crm", "division": "business", "description": "CRM", "products": [product("customer"), product("sales_customer")]},
        {"name": "sales", "division": "business", "description": "Sales", "products": [
            product("customer"), product("crm_customer"),
            {"name": "order", "table_name": "order", "primary_key": "order_id", "description": "Order",
             "attributes": [fu._attr("order_id", "bigint", "primary_key"), fu._attr("customer_id", "bigint", fk="sales.customer.customer_id")]}]},
    ]
    return model


def _keys(products):
    return {(x["domain"], x["product"]) for x in products}


def test_qa_ssot_dedup_leaves_untouched_duplicates_alone():
    d, p, a = _flat(_dedup_model())
    ah.run_quality_assurance_checks(d, p, a, fu.RecordingLogger(), None, _qa_config(v1_domains=("crm", "sales")),
                                    protected_artifacts={"products": [], "domains": [], "links": []})
    assert _keys(p) >= {("crm", "customer"), ("sales", "customer")}


def test_qa_ssot_consolidation_needs_both_copies_touched():
    d, p, a = _flat(_dedup_model())
    log = fu.RecordingLogger()
    ah.run_quality_assurance_checks(d, p, a, log, None, _qa_config(v1_domains=("crm", "sales")),
                                    protected_artifacts={"products": ["sales.customer"], "domains": [], "links": []})
    assert _keys(p) >= {("crm", "customer"), ("sales", "customer")}
    assert "Step 7D-1 SSOT consolidation skipped for 'sales.customer' into 'crm.customer'" in log.text()


def test_non_vov_ssot_consolidation_still_runs():
    d, p, a = _flat(_dedup_model())
    ah.run_quality_assurance_checks(d, p, a, fu.RecordingLogger(), None, _qa_config(operation=fu.NEW_BASE, v1_domains=()),
                                    protected_artifacts=None)
    assert ("sales", "customer") not in _keys(p)


def _vov_review_widgets(model):
    _d, p, a = _flat(model)
    return {"operation": fu.VOV, "_v357_v1_products_snapshot": copy.deepcopy(p), "_v357_v1_attributes_snapshot": copy.deepcopy(a)}


def test_ssot_dedup_removal_of_a_v1_product_is_restored_by_the_review_gate():
    model = _dedup_model()
    d, p, a = _flat(model)
    wv = _vov_review_widgets(model)
    pre_qa = ah._vov_review_pre_qa_snapshot(wv, p, a)
    ah.run_quality_assurance_checks(d, p, a, fu.RecordingLogger(), None, _qa_config(v1_domains=("crm", "sales")),
                                    protected_artifacts={"products": ["crm.customer", "sales.customer"], "domains": [], "links": []})
    assert ("sales", "customer") not in _keys(p)
    order_fk = next(x for x in a if x["product"] == "order" and x["attribute"] == "customer_id")
    assert order_fk["foreign_key_to"] == "crm.customer.customer_id"
    log = fu.RecordingLogger()
    assert ah._vov_review_preservation_gate(wv, pre_qa, d, p, a, log) == 1
    assert ("sales", "customer") in _keys(p)
    assert sorted(x["attribute"] for x in a if (x["domain"], x["product"]) == ("sales", "customer")) == ["customer_id", "email", "full_name"]
    assert order_fk["foreign_key_to"] == "sales.customer.customer_id"
    assert "[vov-review-preservation-gate FIRED v5.1.4] restored 1" in log.text("warning")


def test_review_gate_does_not_restore_products_qa_renamed_in_place():
    model = fu.small_model()
    model["model"]["domains"][1]["products"][0]["name"] = "billing_invoice"
    model["model"]["domains"][1]["products"][0]["table_name"] = "billing_invoice"
    d, p, a = _flat(model)
    wv = _vov_review_widgets(model)
    pre_qa = ah._vov_review_pre_qa_snapshot(wv, p, a)
    ah.run_quality_assurance_checks(d, p, a, fu.RecordingLogger(), None, _qa_config(),
                                    protected_artifacts={"products": ["billing.billing_invoice"], "domains": [], "links": []})
    assert ("billing", "invoice") in _keys(p) and ("billing", "billing_invoice") not in _keys(p)
    assert ah._vov_review_preservation_gate(wv, pre_qa, d, p, a) == 0
    assert len(p) == 3


def test_review_gate_restores_the_pre_qa_state_and_moves_transferred_columns_back():
    model = fu.small_model()
    d, p, a = _flat(model)
    wv = _vov_review_widgets(model)
    invoice = next(x for x in p if x["product"] == "invoice")
    invoice["description"] = "edited by the user's VREQ"
    a.append(dict(next(x for x in a if x["product"] == "invoice"), attribute="due_date", column_name="due_date", foreign_key_to="", tags=""))
    pre_qa = ah._vov_review_pre_qa_snapshot(wv, p, a)
    due = next(x for x in a if x["attribute"] == "due_date")
    due["product"] = "payment"
    a[:] = [x for x in a if not (x["product"] == "invoice")]
    p[:] = [x for x in p if x is not invoice]
    for x in a:
        if x.get("foreign_key_to") == "billing.invoice.invoice_id":
            x["foreign_key_to"] = "billing.payment.payment_id"
    assert ah._vov_review_preservation_gate(wv, pre_qa, d, p, a) == 1
    restored = next(x for x in p if x["product"] == "invoice")
    assert restored["description"] == "edited by the user's VREQ" and restored is not invoice
    assert sorted(x["attribute"] for x in a if x["product"] == "invoice") == ["customer_id", "due_date", "invoice_id"]
    assert due["product"] == "invoice"
    assert [x["attribute"] for x in a if x["product"] == "payment"] == ["payment_id", "invoice_id"]
    assert next(x for x in a if x["product"] == "payment" and x["attribute"] == "invoice_id")["foreign_key_to"] == "billing.invoice.invoice_id"


def test_review_gate_does_not_undo_pre_qa_removals_or_add_columns_to_survivors():
    model = fu.small_model()
    d, p, a = _flat(model)
    wv = _vov_review_widgets(model)
    p[:] = [x for x in p if x["product"] != "payment"]
    a[:] = [x for x in a if x["product"] != "payment" and x["attribute"] != "name"]
    pre_qa = ah._vov_review_pre_qa_snapshot(wv, p, a)
    p[:] = [x for x in p if x["product"] != "invoice"]
    a[:] = [x for x in a if x["product"] != "invoice"]
    assert ah._vov_review_preservation_gate(wv, pre_qa, d, p, a) == 1
    assert {x["product"] for x in p} == {"customer", "invoice"}
    assert [x["attribute"] for x in a if x["product"] == "customer"] == ["customer_id"]


def test_review_gate_only_restores_base_version_products():
    model = fu.small_model()
    d, p, a = _flat(model)
    wv = _vov_review_widgets(model)
    p.append(dict(p[0], product="new_thing", table_name="new_thing"))
    pre_qa = ah._vov_review_pre_qa_snapshot(wv, p, a)
    p.pop()
    assert ah._vov_review_preservation_gate(wv, pre_qa, d, p, a) == 0


def test_review_gate_honours_fence_renames():
    model = fu.small_model()
    d, p, a = _flat(model)
    wv = _vov_review_widgets(model)
    pre_qa = ah._vov_review_pre_qa_snapshot(wv, p, a)
    p[:] = [x for x in p if x["product"] != "invoice"] + [dict(next(x for x in p if x["product"] == "invoice"), product="bill")]
    ah._vibe_scope_note_rename("product", "billing.invoice", "billing.bill", "VREQ-0001")
    assert ah._vov_review_preservation_gate(wv, pre_qa, d, p, a) == 0
    assert "invoice" not in {x["product"] for x in p}


def test_review_gate_skips_products_whose_domain_is_gone():
    model = fu.small_model()
    d, p, a = _flat(model)
    wv = _vov_review_widgets(model)
    pre_qa = ah._vov_review_pre_qa_snapshot(wv, p, a)
    p[:] = [x for x in p if x["domain"] != "billing"]
    d[:] = [x for x in d if x["domain"] != "billing"]
    log = fu.RecordingLogger()
    assert ah._vov_review_preservation_gate(wv, pre_qa, d, p, a, log) == 0
    assert "could not be restored because their domain is gone" in log.text("warning")


def test_review_gate_is_a_noop_outside_vov():
    d, p, a = _flat()
    assert ah._vov_review_pre_qa_snapshot({}, p, a) is None
    assert ah._vov_review_preservation_gate({}, None, d, p, a) == 0


def test_review_block_wires_the_gate_after_default_qa_and_protects_v1_domains_in_cleanup():
    body = slice_function_source("step_create_logical_schema")
    review = body[body.index('if widgets_values.get("use_review_base_data"):'):body.index("FILE-BASED MODE")]
    cleanup = review.index("_cleanup_empty_domains(domains_data, products_data, logger=logger, user_specified_domains=_usd_empty_drop")
    protect = review.index('_usd_empty_drop = _usd_empty_drop + list(widgets_values.get("_preserve_v1_domains") or [])')
    assert protect < cleanup
    snapshot = review.index("_vov_pre_qa = _vov_review_pre_qa_snapshot(widgets_values, products_data, attributes_data)")
    qa = review.index("qa_results = run_quality_assurance_checks(", snapshot)
    gate = review.index("_vov_review_preservation_gate(widgets_values, _vov_pre_qa, domains_data, products_data, attributes_data, logger)")
    assert snapshot < qa < gate < review.index("step_finalize_model_before_physical_schema(widgets_values)")
