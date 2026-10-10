"""v5.1.6 primary-key integrity, from live run 161935925891676 (agent 5.1.4, vs514 retail).

SWEEP-LINK linked customer.campaign.campaign_id (that table's primary key) to product.campaign.campaign_id,
MV15 judged the FK invalid and deleted the whole column, model.json was serialized from that state and only
the later DDL pre-check re-created the key, so 11 FKs dangled in model.json. Each test drives a production
entry point that already exists on 2800131 and fails there.
"""
import copy
import json
import logging
import uuid
from pathlib import Path

import pytest

import conftest  # noqa: F401
import agent_helpers as ah

FIXTURE = Path(__file__).parent / "fixtures" / "v516_r0p_campaign_subset.json"
DANGLING = "customer.campaign.campaign_id"


class _Capture(logging.Handler):
    def __init__(self):
        super().__init__(logging.DEBUG)
        self.lines = []

    def emit(self, record):
        self.lines.append(record.getMessage())


def _logger():
    log = logging.getLogger(f"v516.{uuid.uuid4().hex}")
    log.setLevel(logging.DEBUG)
    log.propagate = False
    cap = _Capture()
    log.addHandler(cap)
    return log, cap


def _text(cap):
    return "\n".join(cap.lines)


def _cfg():
    return {
        "PROMPT_VARIABLES": {"business_config": {"business": "vs514 retail", "version": "1"},
                             "model_conventions_config": {"table_id_type": "BIGINT"}},
        "MODEL_CONVENTIONS": {"primary_key_suffix": "_id", "data_asset_naming_convention": "snake_case"},
        "MODEL_SCOPE": "mvm",
        "MAX_CONCURRENT_BATCHES": 1,
        "MAX_RETRIES": 1,
    }


def _r0p():
    return json.loads(FIXTURE.read_text())


def _flat(model=None):
    d, p, a, mv = ah.model_to_widgets_flat(model or _r0p(), quiet=True)
    return d, p, a, mv


def _find(attrs, domain, product, attribute):
    return [a for a in attrs if (a.get("domain"), a.get("product"), a.get("attribute")) == (domain, product, attribute)]


def _pk_row(attrs, domain, product, pk, fk=""):
    src = _find(attrs, "product", "campaign", "campaign_id")[0]
    row = dict(src, domain=domain, product=product, attribute=pk, column_name=pk, foreign_key_to=fk)
    return row


def _nested_product(model, domain, product):
    for d in model["model"]["domains"] if "model" in model else model["domains"]:
        if d["name"] == domain:
            for p in d["products"]:
                if p["name"] == product:
                    return p
    return None


def _dangling(model):
    root = model.get("model", model)
    cols = {(d["name"], p["name"]): {a["name"] for a in p["attributes"]} for d in root["domains"] for p in d["products"]}
    out = []
    for d in root["domains"]:
        for p in d["products"]:
            for a in p["attributes"]:
                fk = (a.get("foreign_key_to") or "").split(".")
                if len(fk) >= 3 and fk[2] not in cols.get((fk[0], fk[1]), set()):
                    out.append(f"{d['name']}.{p['name']}.{a['name']}")
    return out



class _MV15Agent:
    def __init__(self, invalid):
        self.invalid = invalid

    def _call_ai_query(self, *args, **kwargs):
        return {"evaluations": [{"source_product": s, "fk_column": c, "target_product": t, "classification": "invalid",
                                 "reason": "shared column name only"} for s, c, t in self.invalid]}


def test_mv15_clears_the_fk_on_a_primary_key_and_keeps_the_column():
    _d, products, attrs, _mv = _flat()
    attrs.insert(0, _pk_row(attrs, "customer", "campaign", "campaign_id", fk="product.campaign.campaign_id"))
    log, cap = _logger()
    agent = _MV15Agent([("customer.campaign", "campaign_id", "product.campaign"),
                        ("product.digital_asset", "campaign_id", "customer.campaign")])
    out = ah.run_fk_semantic_correctness_gate({"ai_agent": agent}, products, attrs, _cfg(), log)
    kept = _find(out, "customer", "campaign", "campaign_id")
    assert len(kept) == 1 and kept[0]["foreign_key_to"] == ""
    assert not _find(out, "product", "digital_asset", "campaign_id")
    assert "[mv15-pk-fk-clear-only FIRED v5.1.6]" in _text(cap)
    assert "Cleaned 1 invalid FK attribute(s)" in _text(cap)


def test_cycle_purge_clears_the_fk_on_a_primary_key():
    products = [{"domain": "s", "product": "x", "primary_key": "x_id"}, {"domain": "s", "product": "y", "primary_key": "y_id"}]
    attrs = [
        {"domain": "s", "product": "y", "attribute": "y_id", "tags": "primary_key", "foreign_key_to": "s.x.x_id"},
        {"domain": "s", "product": "x", "attribute": "x_id", "tags": "primary_key", "foreign_key_to": ""},
        {"domain": "s", "product": "x", "attribute": "y_id", "tags": "", "foreign_key_to": "s.y.y_id"},
    ]
    log, cap = _logger()
    purged = ah._v205_purge_residual_cycles_deterministically(attrs, products, log)
    assert purged >= 1
    kept = _find(attrs, "s", "y", "y_id")
    assert kept and kept[0]["foreign_key_to"] == "" and not ah._detect_cycles_dfs(products, attrs, log)
    assert "[cycle-purge-pk-clear-only FIRED v5.1.6]" in _text(cap)


def test_surrender_never_removes_a_primary_key():
    attrs = [
        {"domain": "customer", "product": "campaign", "attribute": "campaign_id", "tags": "primary_key", "foreign_key_to": ""},
        {"domain": "customer", "product": "campaign", "attribute": "campaign_code", "tags": "", "foreign_key_to": ""},
        {"domain": "customer", "product": "session", "attribute": "campaign_id", "tags": "", "foreign_key_to": DANGLING},
    ]
    log, cap = _logger()
    removed, fixed = ah._safe_remove_redundant_column("customer", "campaign", "campaign_id", "x_id", "product.campaign.campaign_id",
                                                      attrs, log, _cfg())
    assert (removed, fixed) == (False, 0)
    assert _find(attrs, "customer", "campaign", "campaign_id")
    assert _find(attrs, "customer", "session", "campaign_id")[0]["foreign_key_to"] == DANGLING
    assert "[surrender-pk-guard FIRED v5.1.6]" in _text(cap)
    removed, _ = ah._safe_remove_redundant_column("customer", "campaign", "campaign_code", None, None, attrs, log, _cfg())
    assert removed and not _find(attrs, "customer", "campaign", "campaign_code")


def test_fk_column_rename_never_renames_a_primary_key():
    pk = {"domain": "customer", "product": "campaign", "attribute": "campaign_key", "column_name": "campaign_key",
          "tags": "primary_key", "foreign_key_to": "product.campaign.campaign_id"}
    fk = {"domain": "customer", "product": "session", "attribute": "promo", "column_name": "promo",
          "tags": "", "foreign_key_to": "product.campaign.campaign_id"}
    attrs = [pk, fk]
    pk_map = {"product.campaign": "campaign_id"}
    log, cap = _logger()
    assert ah.normalize_fk_column_name(pk, pk_map, attrs, log, _cfg()) is False
    assert pk["attribute"] == "campaign_key"
    assert "[fk-colname-pk-guard FIRED v5.1.6]" in _text(cap)
    assert ah.normalize_fk_column_name(fk, pk_map, attrs, log, _cfg()) is True
    assert fk["attribute"] == "campaign_id"


def test_llm_fallback_remove_refuses_a_primary_key():
    domains = [{"domain": "customer"}]
    products = [{"domain": "customer", "product": "campaign", "primary_key": "campaign_id"}]
    attrs = [{"domain": "customer", "product": "campaign", "attribute": "campaign_id", "tags": "primary_key", "foreign_key_to": ""},
             {"domain": "customer", "product": "campaign", "attribute": "budget_amount", "tags": "", "foreign_key_to": ""}]
    log, cap = _logger()
    ah._llm_fallback_apply_mutations(
        [{"entity_type": "attribute", "operation": "remove", "entity_ref": "customer.campaign.campaign_id"},
         {"entity_type": "attribute", "operation": "remove", "entity_ref": "customer.campaign.budget_amount"}],
        domains, products, attrs, [], log)
    assert _find(attrs, "customer", "campaign", "campaign_id")
    assert not _find(attrs, "customer", "campaign", "budget_amount")
    assert "[llm-fallback-remove-pk-guard FIRED v5.1.6]" in _text(cap)


def test_reviewer_p11_keeps_the_primary_key():
    model = {"domains": [{"name": "customer", "products": [{"name": "campaign", "primary_key": "campaign_id", "attributes": [
        {"name": "campaign_id", "tags": "primary_key", "foreign_key_to": ""},
        {"name": "campaign_type", "tags": "", "foreign_key_to": ""},
        {"name": "campaign_name", "tags": "", "foreign_key_to": ""}]}]}]}
    text = ("REVIEWER-PRIORITY P11 customer_type_clean: customer.campaign.campaign_name keeps a separate "
            "campaign_id/campaign_type column that duplicates the name. REVIEWER-PRIORITY P12 none")
    log, cap = _logger()
    ah._v441_reviewer_finalization(model, text, log)
    names = [a["name"] for a in _nested_product(model, "customer", "campaign")["attributes"]]
    assert "campaign_id" in names and "campaign_type" not in names
    assert "[reviewer-p11-pk-guard FIRED v5.1.6]" in _text(cap)


def test_g9_never_drops_a_primary_key_twin():
    model = {"domains": [{"name": "sales", "products": [
        {"name": "campaign", "primary_key": "campaign_id", "attributes": [
            {"name": "campaign_id", "tags": "primary_key", "foreign_key_to": ""},
            {"name": "campaign_code", "tags": "", "foreign_key_to": ""}]},
        {"name": "promo_slot", "primary_key": "campaign_code", "attributes": [
            {"name": "campaign_code", "tags": "primary_key", "foreign_key_to": ""},
            {"name": "campaign_id", "tags": "", "foreign_key_to": "sales.campaign.campaign_id"},
            {"name": "channel_code", "tags": "", "foreign_key_to": ""}]}]}]}
    log, cap = _logger()
    ah._v443_structural_hardening(model, log)
    names = [a["name"] for a in _nested_product(model, "sales", "promo_slot")["attributes"]]
    assert "campaign_code" in names
    assert "[g9-pk-guard FIRED v5.1.6]" in _text(cap)


def test_lineage_demotion_keeps_a_lineage_named_primary_key():
    products = [{"domain": "ref", "product": "source_registry", "primary_key": "source_system"}]
    attrs = [{"domain": "ref", "product": "source_registry", "attribute": "source_system", "tags": "primary_key", "foreign_key_to": ""},
             {"domain": "ref", "product": "other", "attribute": "source_system", "tags": "", "foreign_key_to": ""}]
    log, cap = _logger()
    ah._v381_demote_metadata_columns(products, attrs, _cfg(), log)
    assert _find(attrs, "ref", "source_registry", "source_system")
    assert not _find(attrs, "ref", "other", "source_system")
    assert "[metadata-demote-pk-guard FIRED v5.1.6]" in _text(cap)


def test_dedupe_keeps_the_primary_key_row():
    pk = {"domain": "customer", "product": "campaign", "attribute": "campaign_id", "tags": "primary_key", "is_primary_key": True,
          "foreign_key_to": "", "description": "PK"}
    dup = {"domain": "customer", "product": "campaign", "attribute": "campaign_id", "tags": "",
           "foreign_key_to": "product.campaign.campaign_id", "description": "a much longer duplicate description of the same column"}
    attrs = [pk, dup]
    log, cap = _logger()
    assert ah.deduplicate_attributes_in_place(attrs, log) == 1
    assert attrs == [pk]
    assert "[dedup-keep-pk-row FIRED v5.1.6]" in _text(cap)


def test_alignment_never_renames_a_primary_key_that_carries_an_fk():
    products = [{"domain": "customer", "product": "campaign", "primary_key": "campaign_key"},
                {"domain": "product", "product": "campaign", "primary_key": "campaign_id"}]
    attrs = [{"domain": "customer", "product": "campaign", "attribute": "campaign_key", "column_name": "campaign_key",
              "tags": "primary_key", "foreign_key_to": "product.campaign.campaign_id"},
             {"domain": "product", "product": "campaign", "attribute": "campaign_id", "column_name": "campaign_id",
              "tags": "primary_key", "foreign_key_to": ""}]
    log, cap = _logger()
    ah._v493_align_fk_column_names_to_parent_pk(products, attrs, _cfg(), log)
    assert attrs[0]["attribute"] == "campaign_key"
    assert "[fk-align-pk-guard FIRED v5.1.6]" in _text(cap)


def test_sandbox_invariant_rejects_a_mutation_that_drops_a_primary_key():
    model = _r0p()
    _nested_product(model, "customer", "campaign")["attributes"].insert(0, {"name": "campaign_id", "tags": "primary_key", "foreign_key_to": ""})
    snap = ah.capture_invariants(model, [], [])
    ok, _ = ah.verify_invariants(copy.deepcopy(model), snap)
    assert ok
    mutated = copy.deepcopy(model)
    prod = _nested_product(mutated, "customer", "campaign")
    prod["attributes"] = [a for a in prod["attributes"] if a["name"] != "campaign_id"]
    ok, diag = ah.verify_invariants(mutated, snap)
    assert not ok and "primary key attribute removed" in diag and "customer.campaign.campaign_id" in diag


def test_selffixer_invariants_count_products_missing_their_primary_key():
    model = _r0p()
    assert ah._selffixer_capture_invariants(model)["pk_missing"] == 1
    _nested_product(model, "customer", "campaign")["attributes"].insert(0, {"name": "campaign_id", "tags": "primary_key"})
    assert ah._selffixer_capture_invariants(model)["pk_missing"] == 0



def _pre_fmfl_state():
    _d, products, attrs, _mv = _flat()
    domains = [{"domain": n, "description": n} for n in ("customer", "order", "product")]
    products = [p for p in products if p["product"] != "campaign"]
    attrs = [a for a in attrs if a["product"] != "campaign"]
    for a in attrs:
        if (a.get("foreign_key_to") or "").split(".")[1:2] == ["campaign"]:
            a["foreign_key_to"] = ""
    return domains, products, attrs


def _run_fmfl(decisions_by_domain, domains, products, attrs):
    saved = ah.__dict__["smart_worker_loop"]

    def _fake(**kwargs):
        dom = kwargs["step_name"].rsplit("_", 1)[-1]
        return True, {"decisions": decisions_by_domain.get(dom, [])}, []

    ah.__dict__["smart_worker_loop"] = _fake
    log, cap = _logger()
    try:
        totals = ah._run_find_missing_fk_links(domains, products, attrs, ah.build_pk_map(products, _cfg(), include_lowercase=True),
                                               log, object(), _cfg())
    finally:
        ah.__dict__["smart_worker_loop"] = saved
    return totals, cap


def test_sweep_link_never_links_an_own_primary_key_to_another_products_primary_key():
    domains, products, attrs = _pre_fmfl_state()
    decisions = {
        "customer": [{"table": "interaction", "column": "campaign_id", "decision": "CREATE", "create_table_name": "campaign",
                      "create_in_domain": "customer", "confidence": "HIGH", "reasoning": "campaign master"}],
        "product": [{"table": "digital_asset", "column": "campaign_id", "decision": "CREATE", "create_table_name": "campaign",
                     "create_in_domain": "product", "confidence": "HIGH", "reasoning": "campaign master"}],
    }
    totals, cap = _run_fmfl(decisions, domains, products, attrs)
    assert totals["created"] == 1 and [p["domain"] for p in products if p["product"] == "campaign"] == ["customer"]
    assert _find(attrs, "customer", "campaign", "campaign_id")[0]["foreign_key_to"] == ""
    assert _find(attrs, "product", "digital_asset", "campaign_id")[0]["foreign_key_to"] == DANGLING
    assert _find(attrs, "customer", "nps_response", "campaign_id")[0]["foreign_key_to"] == DANGLING
    assert "[stub-single-owner FIRED v5.1.6]" in _text(cap)


def test_fmfl_drop_never_drops_a_primary_key():
    domains, products, attrs = _pre_fmfl_state()
    products.append({"domain": "customer", "product": "campaign", "primary_key": "campaign_id"})
    attrs.append({"domain": "customer", "product": "campaign", "attribute": "campaign_id", "tags": "primary_key", "foreign_key_to": ""})
    decisions = {"customer": [
        {"table": "campaign", "column": "campaign_id", "decision": "DROP", "confidence": "HIGH", "reasoning": "hallucinated"},
        {"table": "session", "column": "campaign_id", "decision": "DROP", "confidence": "HIGH", "reasoning": "hallucinated"}]}
    totals, cap = _run_fmfl(decisions, domains, products, attrs)
    assert _find(attrs, "customer", "campaign", "campaign_id")
    assert not _find(attrs, "customer", "session", "campaign_id")
    assert totals["dropped"] == 1
    assert "[fmfl-drop-pk-guard FIRED v5.1.6]" in _text(cap)


def test_deferred_link_never_links_an_own_primary_key():
    domains, products, attrs = _pre_fmfl_state()
    products += [{"domain": "customer", "product": "campaign", "primary_key": "campaign_id"},
                 {"domain": "product", "product": "campaign", "primary_key": "campaign_id"}]
    attrs += [{"domain": "customer", "product": "campaign", "attribute": "campaign_id", "tags": "primary_key", "foreign_key_to": ""},
              {"domain": "product", "product": "campaign", "attribute": "campaign_id", "tags": "primary_key", "foreign_key_to": ""}]
    decisions = {"customer": [
        {"table": "campaign", "column": "campaign_id", "decision": "LINK", "target_table": "product.campaign", "confidence": "HIGH", "reasoning": "x"},
        {"table": "session", "column": "campaign_id", "decision": "LINK", "target_table": "customer.campaign", "confidence": "HIGH", "reasoning": "x"}]}
    _totals, cap = _run_fmfl(decisions, domains, products, attrs)
    assert _find(attrs, "customer", "campaign", "campaign_id")[0]["foreign_key_to"] == ""
    assert _find(attrs, "customer", "session", "campaign_id")[0]["foreign_key_to"] == DANGLING
    assert "[own-pk-link-guard FIRED v5.1.6]" in _text(cap)



_BUSINESS_ROW = {"business": "vs514 retail", "description": "A retailer.", "industry_alignment": "Retail", "location": "Global",
                 "core_business_processes": "Sell", "orgnaization_divisions": "operations", "data_domains": "",
                 "common_business_jargons": "", "operational_systems_of_records": "", "industry_governing_body": ""}


def _export(flat_lists, tmp_path, extra=None, patches=None):
    d, p, a, mv = flat_lists
    uploads = {}

    class _Files:
        def delete(self, file_path):
            uploads.pop(file_path, None)

        def upload(self, file_path, contents, overwrite=True):
            uploads[file_path] = contents.read()

    class _Workspace:
        def __init__(self, *args, **kwargs):
            self.files = _Files()

    cfg = _cfg()
    cfg.update({"TARGET_VOLUME": "/Volumes/c/_metamodel/vol_root/business/vs514_retail/v1/mvm",
                "MAIN_METAMODEL_TABLES": {"BUSINESS": "c._metamodel.business"},
                "PRODUCTS_FILE_PATH": str(tmp_path / "products.json"),
                "ATTRIBUTES_FILE_PATH": str(tmp_path / "attributes.json"),
                "DOMAINS_FILE_PATH": str(tmp_path / "domains.json")})
    for key, rows in (("PRODUCTS_FILE_PATH", p), ("ATTRIBUTES_FILE_PATH", a), ("DOMAINS_FILE_PATH", d)):
        Path(cfg[key]).write_text(json.dumps(rows))
    log, cap = _logger()
    wv = {"spark": None, "logger": log, "config": cfg, "business_name": "vs514 retail", "operation": "new base model",
          "current_version": "1", "model_scope": "mvm", "domains": d, "products": p, "attributes": a, "metric_views": [],
          "_metric_view_records": [], "metric_view_statements": [], "_run_start_time": "2026-10-08T22:00:00",
          "_widget_raw_values": {"business_name": "vs514 retail", "operation": "new base model"}}
    wv.update(extra or {})
    all_patches = {"WorkspaceClient": _Workspace, "execute_sql": lambda spark, query, logger=None: [dict(_BUSINESS_ROW)]}
    all_patches.update(patches or {})
    saved = {k: ah.__dict__.get(k, KeyError) for k in all_patches}
    ah.__dict__.update(all_patches)
    try:
        import time as _time
        wv["_run_start_timestamp"] = _time.time()
        ah.step_generate_data_model_json(wv)
    finally:
        for k, v in saved.items():
            if v is KeyError:
                ah.__dict__.pop(k, None)
            else:
                ah.__dict__[k] = v
    payload = uploads.get(f"{cfg['TARGET_VOLUME']}/model.json")
    return (json.loads(payload) if payload else None), wv, cap


def _count(model):
    return sum(len(p["attributes"]) for d in model["model"]["domains"] for p in d["products"])


def test_model_json_is_serialized_from_canonical_memory_with_every_primary_key(tmp_path):
    flat = _flat()
    n_memory = len(flat[2])
    root, wv, cap = _export(flat, tmp_path)
    assert root is not None
    camp = _nested_product(root, "customer", "campaign")
    assert any(a["name"] == "campaign_id" for a in camp["attributes"])
    assert _dangling(root) == []
    assert _count(root) == n_memory + 1 == len(wv["attributes"])
    assert len(json.loads(Path(wv["config"]["ATTRIBUTES_FILE_PATH"]).read_text())) == n_memory + 1
    text = _text(cap)
    assert "[MODEL.JSON PRE-CHECK] Created missing PK attribute: customer.campaign.campaign_id" in text
    assert "SYNC CHECK: export matches canonical memory" in text
    assert "[modeljson-parity-gate FIRED v5.1.6] passed" in text


def test_parity_gate_restores_a_primary_key_dropped_after_the_export_and_syncs_memory(tmp_path):
    flat = _flat()
    flat[2].insert(0, _pk_row(flat[2], "customer", "campaign", "campaign_id"))

    def _drop_pk(data_model, logger=None):
        prod = _nested_product({"domains": data_model["domains"]}, "customer", "campaign")
        prod["attributes"] = [a for a in prod["attributes"] if a["name"] != "campaign_id"]
        return {}

    root, wv, cap = _export(flat, tmp_path, patches={"_v443_structural_hardening": _drop_pk})
    assert root is not None
    assert any(a["name"] == "campaign_id" for a in _nested_product(root, "customer", "campaign")["attributes"])
    assert _dangling(root) == []
    assert _count(root) == len(wv["attributes"])
    assert wv["_modeljson_parity_gate"]["status"] == "repaired"
    assert "[modeljson-parity-gate FIRED v5.1.6] repaired" in _text(cap)


def test_parity_gate_writes_a_model_json_only_drop_back_to_memory(tmp_path):
    flat = _flat()

    def _drop_twin(data_model, logger=None):
        prod = _nested_product({"domains": data_model["domains"]}, "customer", "session")
        prod["attributes"] = [a for a in prod["attributes"] if a["name"] != "campaign_id"]
        return {}

    root, wv, cap = _export(flat, tmp_path, patches={"_v443_structural_hardening": _drop_twin})
    assert root is not None
    assert not _find(wv["attributes"], "customer", "session", "campaign_id")
    assert _count(root) == len(wv["attributes"])
    assert not _find(json.loads(Path(wv["config"]["ATTRIBUTES_FILE_PATH"]).read_text()), "customer", "session", "campaign_id")


def test_parity_gate_fails_closed_and_halts_when_the_repair_cannot_fix_it(tmp_path):
    flat = _flat()

    def _drop_pk(data_model, logger=None):
        prod = _nested_product({"domains": data_model["domains"]}, "customer", "campaign")
        prod["attributes"] = [a for a in prod["attributes"] if a["name"] != "campaign_id"]
        return {}

    def _no_repair(data_model, widgets_values, config, logger, frozen):
        return {}, set()

    with pytest.raises(Exception) as exc:
        _export(flat, tmp_path, patches={"_v443_structural_hardening": _drop_pk, "_v516_modeljson_parity_repair": _no_repair})
    assert "parity" in str(exc.value).lower()


def test_halt_and_carry_over_honour_a_failed_parity_gate():
    log, cap = _logger()
    wv = {"_modeljson_parity_gate": {"status": "failed", "violations": [{"kind": "pk_attribute_missing", "path": DANGLING}]},
          "operation": "vibe modeling of version", "base_version_for_review": "1"}
    with pytest.raises(RuntimeError):
        ah._vibe_scope_halt_if_gate_failed(wv, "Step 9a physical deploy", log)
    ah._carry_over_missing_artifacts_from_previous_version(wv, {"TARGET_VOLUME": "/Volumes/c/s/v/business/x/v2/mvm"}, log)
    assert "[CARRY-OVER] skipped" in _text(cap)


def test_static_analysis_flags_fks_to_a_missing_column():
    _d, products, attrs, _mv = _flat()
    issues = ah.run_metamodel_static_analysis(_d, products, attrs, _cfg(), _logger()[0])["issues"]
    missing_col = [i for i in issues if i["category"] == "broken_fk" and "non-existent column" in i["message"]]
    assert len(missing_col) == 11
    assert all(i["details"]["target_column"] == "campaign_id" for i in missing_col)
