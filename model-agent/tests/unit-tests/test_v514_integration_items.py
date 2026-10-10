"""v5.1.4 cross-stream integration items, driven through production code.

Items 1, 2, 5, 9-16 of the integration brief, decision 8A (model_vibes is the only VOV instruction
source) and the shrink follow-ups (attribute drops in the summary-scope guard, the named-merge rule,
invariants on the deterministic _v337 path, the SelfFixer attribute-count guard).
"""
import copy
import json
import logging
import re
import sys
from pathlib import Path

import pytest

sys.path.insert(0, str(Path(__file__).resolve().parent))
import conftest  # noqa: F401,E402
import agent_helpers as ah  # noqa: E402

REPO = Path(__file__).resolve().parents[3]
NOTEBOOK = REPO / "model-agent" / "agent" / "dbx_vibe_modelling_agent.ipynb"
RAW = json.loads((REPO / "data-models" / "airlines" / "v1" / "mvm" / "model.json").read_text())
VOV = "vibe modeling of version"
NEW_BASE = "new base model"
LOG = logging.getLogger("test_v514_integration")


@pytest.fixture(autouse=True)
def _reset_runtime():
    ah.set_vibe_scope_runtime(None)
    yield
    ah.set_vibe_scope_runtime(None)


def _fence(entries="crew", mode="Some Domains", base=RAW, operation=VOV):
    fence = ah.build_vibe_scope_fence(ah.parse_vibe_scope(mode, entries), base if operation == VOV else None, operation, LOG)
    ah.set_vibe_scope_runtime(fence)
    return fence


def _model():
    return copy.deepcopy(RAW)


def _flat(root):
    return [list(x) for x in ah.model_to_widgets_flat(root)]


def _cell_source(marker):
    nb = json.loads(NOTEBOOK.read_text())
    return next("".join(c["source"]) for c in nb["cells"] if c["cell_type"] == "code" and marker in "".join(c["source"]))


class _SqlSpark:
    def __init__(self, schemas=(), describe=()):
        self.statements = []
        self.schemas = list(schemas)
        self.describe = list(describe)

    def sql(self, text):
        self.statements.append(text)
        rows = []
        if text.startswith("SHOW SCHEMAS"):
            rows = [(s,) for s in self.schemas]
        elif text.startswith("DESCRIBE TABLE"):
            rows = [(c,) for c in self.describe]
        return type("DF", (), {"collect": lambda _self: rows})()


# ---------------------------------------------------------------- item 1: setup teardown


def test_scoped_vov_never_drops_schemas_at_setup(caplog):
    _fence()
    spark = _SqlSpark(schemas=["crew", "flight", "_metrics", "_metamodel", "team_sandbox"])
    wv = {"operation": VOV, "_vibe_scope_spec": ah.parse_vibe_scope("Some Domains", "crew")}
    with caplog.at_level(logging.INFO):
        ah._early_clash_detection(spark, {"TARGET_CATALOG": "airlines_ecm"}, wv, LOG)
    assert not [s for s in spark.statements if s.startswith("DROP")]
    assert "[vibe-scope-no-schema-drop FIRED v5.1.4]" in caplog.text


def test_scope_spec_alone_is_enough_when_the_fence_is_deferred_to_engine_start():
    spark = _SqlSpark(schemas=["crew", "flight"])
    wv = {"operation": VOV, "_vibe_scope_spec": ah.parse_vibe_scope("Some Domains", "crew")}
    ah._early_clash_detection(spark, {"TARGET_CATALOG": "airlines_ecm"}, wv, LOG)
    assert not [s for s in spark.statements if s.startswith("DROP")]


def test_unscoped_vov_teardown_drops_no_schema_this_business_does_not_own():
    spark = _SqlSpark(schemas=["crew", "flight", "_metrics", "_metamodel", "default", "information_schema", "team_sandbox", "_install"])
    ah._early_clash_detection(spark, {"TARGET_CATALOG": "airlines_ecm"}, {"operation": VOV}, LOG)
    assert [s for s in spark.statements if s.startswith("DROP")] == []


# ---------------------------------------------------------------- item 2: subdomain halt / settle


def _subdomain_fence(entries="crew.crew_management"):
    return _fence(entries, mode="Some Subdomains")


def _new_crew_product(products, attributes, name="standby_pool", subdomain=""):
    products.append({"domain": "crew", "product": name, "subdomain": subdomain, "table_name": name, "primary_key": f"{name}_id"})
    attributes.append({"domain": "crew", "product": name, "attribute": f"{name}_id", "column_name": f"{name}_id", "type": "BIGINT"})


def test_settle_assigns_the_only_listed_subdomain_to_a_new_unassigned_product(caplog):
    fence = _subdomain_fence()
    d, p, a, mv = _flat(_model())
    _new_crew_product(p, a)
    with caplog.at_level(logging.WARNING):
        ah._vibe_scope_settle_subdomains({"products": p}, LOG, allow_allocation=False)
    row = next(r for r in p if r["product"] == "standby_pool")
    assert ah._vov285_san(row["subdomain"]) == "crewmanagement"
    assert "[vibe-scope-subdomain-settle FIRED v5.1.4]" in caplog.text
    fence.mark_subdomains_allocated(LOG)
    fence.checkpoint("after_subdomains", d, p, a, mv, LOG)
    assert any(r["product"] == "standby_pool" for r in p)


def test_settle_runs_the_constrained_allocation_then_fails_clearly(monkeypatch):
    _subdomain_fence("crew.crew_management, crew.crew_planning")
    d, p, a, mv = _flat(_model())
    _new_crew_product(p, a)
    calls = []
    monkeypatch.setitem(ah.__dict__, "step_allocate_subdomains", lambda wv: calls.append(len(wv["products"])))
    with pytest.raises(ah.VibeScopeFenceError, match=r"crew\.standby_pool.*not pruned"):
        ah._vibe_scope_settle_subdomains({"products": p}, LOG, allow_allocation=True)
    assert calls, "the constrained allocation ran before failing"

    def _assign(wv):
        next(r for r in wv["products"] if r["product"] == "standby_pool")["subdomain"] = "crew_planning"

    monkeypatch.setitem(ah.__dict__, "step_allocate_subdomains", _assign)
    assert ah._vibe_scope_settle_subdomains({"products": p}, LOG, allow_allocation=True) == []


def test_checkpoint_after_allocation_never_prunes_an_unassigned_new_product_silently():
    fence = _subdomain_fence("crew.crew_management, crew.crew_planning")
    d, p, a, mv = _flat(_model())
    _new_crew_product(p, a)
    fence.mark_subdomains_allocated(LOG)
    with pytest.raises(ah.VibeScopeFenceError, match="not pruned"):
        fence.checkpoint("after_metric_views", d, p, a, mv, LOG)
    assert any(r["product"] == "standby_pool" for r in p)


def test_serialize_gate_refuses_a_missing_subdomain_mandate():
    _fence("crew.crew_management", mode="Some Subdomains", operation=NEW_BASE)
    root = {"model": {"domains": [{"name": "crew", "products": []}], "metric_views": []}}
    wv = {"_vibe_scope_subdomain_mandate": {"required": {"crew": ["crew_management"]}, "missing": ["crew.crew_management"],
                                            "error": "listed subdomain crew.crew_management received no product"}}
    with pytest.raises(ah.VibeScopeFenceError, match="received no product"):
        ah._vibe_scope_serialize_gate(root, wv, LOG)
    assert wv["_vibe_scope_facts"]["serialize_gate"]["status"] == "failed"


def test_splice_gives_the_only_listed_subdomain_instead_of_dropping_the_product():
    fence = _subdomain_fence()
    root = _model()
    crew = next(dom for dom in root["model"]["domains"] if dom["name"] == "crew")
    crew["products"].append({"name": "standby_pool", "table_name": "standby_pool", "primary_key": "standby_pool_id", "subdomain": "",
                             "attributes": [{"name": "standby_pool_id", "column_name": "standby_pool_id", "type": "BIGINT"}]})
    fence.splice_and_verify(root, LOG)
    product = next(pp for pp in next(dom for dom in root["model"]["domains"] if dom["name"] == "crew")["products"] if pp["name"] == "standby_pool")
    assert ah._vov285_san(product["subdomain"]) == "crewmanagement"


def test_step_8c_halts_a_scoped_subdomain_run_instead_of_swallowing_the_error():
    src = _cell_source("def main():")
    block = src[src.index("--- Step 8c: Allocating Products to Subdomains"):src.index("--- Step 8d-KPI-FIRST")]
    handler = block[block.index("except Exception as _sd_err:"):]
    assert handler.index('_VIBE_SCOPE_RUNTIME.spec.mode == "subdomains"') < handler.index("raise") < handler.index("non-critical")
    assert block.index("_vibe_scope_settle_subdomains(widgets_values, logger, allow_allocation=False)") < block.index('"after_subdomains"')
    surgical = src[src.index("--- Step 8c: SKIPPED (surgical fast path"):src.index("if not _surgical_fast_path:")]
    assert "_vibe_scope_settle_subdomains(widgets_values, logger, allow_allocation=True)" in surgical


# ---------------------------------------------------------------- item 5: reallocate_subdomains


def test_reallocate_subdomains_keeps_frozen_and_scope_defining_subdomains(monkeypatch):
    fence = _subdomain_fence()
    d, p, a, mv = _flat(_model())
    before = {(r["domain"], r["product"]): r.get("subdomain") for r in p}
    monkeypatch.setitem(ah.__dict__, "step_allocate_subdomains", lambda wv: None)
    results = ah._execute_queued_vibe_operations_unscoped({"reallocate_subdomains": {}}, {}, {}, d, p, a, {}, LOG, None,
                                                          {"PROMPT_VARIABLES": {}}, {"products": p})
    assert "reallocate_subdomains" in results["operations_executed"]
    assert all(r.get("subdomain") == before[(r["domain"], r["product"])] for r in p)
    assert fence.may_reallocate_subdomain("crew", "brand_new_product")


def test_reallocate_subdomains_still_clears_in_scope_rows_in_some_domains_mode(monkeypatch):
    _fence()
    d, p, a, mv = _flat(_model())
    monkeypatch.setitem(ah.__dict__, "step_allocate_subdomains", lambda wv: None)
    ah._execute_queued_vibe_operations_unscoped({"reallocate_subdomains": {}}, {}, {}, d, p, a, {}, LOG, None,
                                                {"PROMPT_VARIABLES": {}}, {"products": p})
    assert all(not r.get("subdomain") for r in p if r["domain"] == "crew")
    assert all(r.get("subdomain") for r in p if r["domain"] == "fleet")


# ---------------------------------------------------------------- item 9: SA dedup / sanitize


def test_dedup_and_type_sanitize_leave_frozen_rows_alone_when_called_directly():
    _fence()
    d, p, a, mv = _flat(_model())
    frozen = next(x for x in a if x["domain"] == "fleet")
    inscope = next(x for x in a if x["domain"] == "crew")
    a.append(dict(frozen, description=""))
    a.append(dict(inscope, description=""))
    frozen_type = next(x for x in a if x["domain"] == "fleet" and x["product"] != frozen["product"])
    frozen_type["type"] = "STRING FK to fleet.aircraft"
    n_before = len(a)
    ah.run_metamodel_static_analysis(d, p, a, {"MODEL_CONVENTIONS": {}, "PROMPT_VARIABLES": {}}, LOG)
    assert len(a) == n_before - 1
    assert sum(1 for x in a if (x["domain"], x["product"], x["attribute"]) == (frozen["domain"], frozen["product"], frozen["attribute"])) == 2
    assert frozen_type["type"] == "STRING FK to fleet.aircraft"


# ---------------------------------------------------------------- item 10: allocation-pending agreement


def test_engine_gate_and_passes_agree_on_the_allocation_pending_rule():
    fence = _subdomain_fence()
    before = _model()
    after = _model()
    crew = next(dom for dom in after["model"]["domains"] if dom["name"] == "crew")
    crew["products"].append({"name": "standby_pool", "table_name": "standby_pool", "primary_key": "standby_pool_id", "subdomain": "",
                             "attributes": [{"name": "standby_pool_id", "column_name": "standby_pool_id", "type": "BIGINT"}]})
    assert ah._vibe_scope_engine_gate(before, after, "deterministic", ("V1",), LOG) == ("", "")
    assert not fence.is_frozen_pass_row("crew", "standby_pool")
    fence.mark_subdomains_allocated(LOG)
    status, diag = ah._vibe_scope_engine_gate(before, after, "deterministic", ("V1",), LOG)
    assert status == "scope_rejected" and "subdomain_violation" in diag


# ---------------------------------------------------------------- item 11: QA 7A-0.6 naming scope


def test_naming_enforcement_leaves_untouched_products_alone_when_the_qa_scope_is_set():
    products = [{"domain": "crew", "product": "crew_roster", "primary_key": "crew_roster_id", "table_name": "crew_roster"},
                {"domain": "crew", "product": "crew_pairing", "primary_key": "crew_pairing_id", "table_name": "crew_pairing"}]
    attrs = [{"domain": "crew", "product": "crew_roster", "attribute": "crew_roster_id", "column_name": "crew_roster_id"},
             {"domain": "crew", "product": "crew_pairing", "attribute": "crew_pairing_id", "column_name": "crew_pairing_id"},
             {"domain": "crew", "product": "crew_pairing", "attribute": "crew_pairing_note", "column_name": "crew_pairing_note"}]
    scope = {"products": {("crew", "crew_roster")}, "domains": set(), "v1_domains": set(), "fence": None}
    ah.enforce_naming_conventions(products, attrs, LOG, config={"MODEL_CONVENTIONS": {}},
                                  may_rename=lambda dom, prod: ah._qa_vov_scope_allows(scope, dom, prod))
    assert [p["product"] for p in products] == ["roster", "crew_pairing"]
    assert any(x["product"] == "crew_pairing" and x["attribute"] == "crew_pairing_note" for x in attrs)


def test_qa_step_7a_06_passes_the_vreq_scope_to_naming():
    src = _cell_source("def run_quality_assurance_checks(")
    step = src[src.index("--- Step 7A-0.6: Enforce Naming Conventions"):src.index("--- Step 7A-0.8")]
    assert "_qa_vov_scope_allows(_qa_scope, _d, _p)" in step and "may_rename=" in step


# ---------------------------------------------------------------- item 12: v357 preservation gate


def test_v357_gate_restores_dropped_products_without_readding_removed_columns():
    v1_products = [{"domain": "crew", "product": "member"}, {"domain": "crew", "product": "roster"}]
    v1_attrs = [{"domain": "crew", "product": "member", "attribute": "member_id"},
                {"domain": "crew", "product": "member", "attribute": "legacy_code"},
                {"domain": "crew", "product": "roster", "attribute": "roster_id"}]
    products = [{"domain": "crew", "product": "member"}]
    attrs = [{"domain": "crew", "product": "member", "attribute": "member_id"}]
    restored = ah._v357_enforce_product_preservation_flat(v1_products, v1_attrs, [{"domain": "crew"}], products, attrs, logger=LOG)
    assert restored == 1
    assert {(x["product"], x["attribute"]) for x in attrs} == {("member", "member_id"), ("roster", "roster_id")}


# ---------------------------------------------------------------- items 13 + 8A: preflight


def test_vov_with_an_empty_model_vibes_fails_preflight():
    errors = ah._validate_required_widget_values(VOV, "Airlines", "An airline", "1", "", False, "", model_vibes="")
    assert any("'08. Model Vibes' is required" in e and "next_vibes.txt" in e for e in errors)
    assert not ah._validate_required_widget_values(VOV, "Airlines", "An airline", "1", "", False, "", model_vibes="add a column")
    assert not ah._validate_required_widget_values(NEW_BASE, "Airlines", "An airline", "", "", False, "", model_vibes="")


def test_both_preflight_callers_pass_the_raw_widgets():
    src = _cell_source("def main():")
    parent = src[src.index("_pf_errors = _validate_required_widget_values("):][:900]
    assert 'business_domains=_pf_w("business_domains")' in parent and 'model_vibes=_pf_w("model_vibes")' in parent
    child_src = _cell_source("def get_widget_values(")
    child = child_src[child_src.index("errors = _validate_required_widget_values("):][:700]
    assert "business_domains=w_domains" in child and "model_vibes=w_vibes_raw" in child


def test_vov_instructions_come_only_from_the_widget_not_the_base_model_file():
    wv = {"operation": VOV, "_widget_raw_values": {"vibe_modelling_instructions": "rename crew.member to crew.crew_member"}}
    bcd = {"vibe_modelling_instructions": "OLD v1 instructions"}
    assert ah._vov_single_source_vibes(wv, bcd) == "rename crew.member to crew.crew_member"
    assert bcd["vibe_modelling_instructions"] == "rename crew.member to crew.crew_member"
    assert ah._vov_single_source_vibes({"operation": NEW_BASE, "_widget_raw_values": {}}, {"vibe_modelling_instructions": "base"}) == "base"


def test_the_next_vibes_auto_load_and_merge_paths_are_gone():
    src = NOTEBOOK.read_text()
    for token in ("vov-auto-next-vibes FIRED", "vov-merge-user-first FIRED", "_auto_loaded_next_vibes_from_version", "_v296_merged_user_plus_auto",
                  "vov-auto-next-vibes-keyfix-v2", "vov-auto-latest-version-when-v1"):
        assert token not in src, token


# ---------------------------------------------------------------- item 14: VibeWriter deploy_status


def test_vibewriter_session_columns_add_deploy_status():
    writer = object.__new__(ah.VibeWriter)
    writer._tables_ensured = False
    writer.progress_table = "cat._metamodel._vibe_progress"
    writer.business_table = "cat._metamodel.business"
    writer._logger = LOG
    spark = _SqlSpark(describe=["business", "version", "session_id", "processing_status", "completed_percent", "session_started_at",
                                "last_updated_at", "session_json", "results_json", "event_seq"])
    writer._spark = spark
    writer._ensure_tables()
    assert "ALTER TABLE cat._metamodel.business ADD COLUMN `deploy_status` STRING" in spark.statements


# ---------------------------------------------------------------- item 15: _v251 renames feed the ledger


def test_v251_deterministic_renames_are_recorded_in_the_fence_ledger():
    fence = _fence()
    model = _model()
    ok, diag = ah._v251_apply_priority_deterministic({"action": "rename_product", "target": "crew.licence"}, {"new_name": "crew_licence"}, model, LOG)
    assert (ok, diag) == (True, "applied")
    ok, diag = ah._v251_apply_priority_deterministic({"action": "rename_attribute", "target": "crew.member"},
                                                     {"old_name": "member_id", "new_name": "crew_member_id"}, model, LOG)
    assert ok
    ledger = fence.report()["rename_ledger"]
    assert {"kind": "product", "old": "crew.licence", "new": "crew.crew_licence"} in ledger
    assert {"kind": "attribute", "old": "crew.member.member_id", "new": "crew.member.crew_member_id"} in ledger


def test_pass1_rename_compensation_is_removed():
    assert "_vibe_scope_note_pass1_renames" not in NOTEBOOK.read_text()


# ---------------------------------------------------------------- item 16: no early corporate


def test_small_scoped_roster_drops_the_division_quota_rules_from_the_domain_prompt():
    assert ah._domain_priority_guidance() is ah.DOMAIN_PRIORITY_GUIDANCE
    _fence("crew, finance", operation=NEW_BASE)
    text = ah._domain_priority_guidance()
    assert "NO EARLY CORPORATE" not in text and "DIVISION BALANCE:** Operations" not in text
    assert "USER ROSTER" in text and "SSOT ENFORCEMENT" in text
    assert "division_balance_score 100" in ah._architect_division_guidance({})
    assessment = ah._vibe_scope_architect_division_report_only({"division_balance_score": 40}, LOG)
    assert assessment == {"division_balance_score": 100, "division_balance_score_report_only": 40}


def test_a_four_domain_roster_keeps_the_division_rules():
    _fence("crew, finance, flight, fleet", operation=NEW_BASE)
    assert ah._domain_priority_guidance() is ah.DOMAIN_PRIORITY_GUIDANCE
    assert ah._vibe_scope_architect_division_report_only({"division_balance_score": 40}, LOG) == {"division_balance_score": 40}


# ---------------------------------------------------------------- shrink follow-ups


def _diff_model(products):
    return {"model": {"domains": [{"name": "crew", "products": products}], "metric_views": []}}


def _p(name, attrs):
    return {"name": name, "attributes": [{"name": a} for a in attrs]}


def test_summary_scope_rejects_an_unexplained_attribute_drop():
    before = _diff_model([_p("member", ["member_id", "full_name", "legacy_code"])])
    after = _diff_model([_p("member", ["member_id", "full_name"])])
    diff = ah.diff_models_summary(before, after)
    assert diff["attributes_removed"] == [("crew", "member", "legacy_code")]
    ok, msg = ah.diff_within_summary_scope(diff, "Describe crew.member for crew control")
    assert not ok and "attributes_removed" in msg
    assert ah.diff_within_summary_scope(diff, "Drop the legacy_code column from crew.member")[0]
    renamed = ah.diff_models_summary(before, _diff_model([_p("member", ["member_id", "full_name", "legacy_ref"])]))
    assert ah.diff_within_summary_scope(renamed, "Rename legacy_code -> legacy_ref on crew.member")[0]


def test_summary_scope_merge_must_name_every_removed_product():
    before = _diff_model([_p("member", ["member_id"]), _p("licence", ["licence_id"]), _p("roster", ["roster_id"])])
    after = _diff_model([_p("member", ["member_id"])])
    diff = ah.diff_models_summary(before, after)
    assert not ah.diff_within_summary_scope(diff, "Merge duplicate tags on crew.member")[0]
    assert not ah.diff_within_summary_scope(diff, "Merge crew.licence into crew.member")[0]
    assert ah.diff_within_summary_scope(diff, "Merge crew.licence and crew roster into crew.member")[0]


def test_deterministic_v337_path_runs_the_invariants_for_unscoped_runs(monkeypatch):
    monkeypatch.setitem(ah.__dict__, "logger", LOG)
    model = _model()
    invariants = ah.capture_invariants(model, [], [("crew", "licence")])
    quote = "**PRIORITY 1 — rename_product: crew.licence** — rename to crew_licence"
    batch = ah.Batch(batch_id="B1", vreq_ids=("V1",), intent_summary=quote, target_entities=(("crew", "licence"),),
                     data_payload=({"intent": quote, "target": "crew.licence", "source_quote": quote},))
    det_model, det_summary = ah._v337_deterministic_mutate(batch, model, LOG)
    assert det_model is not None, "the batch must take the deterministic rename path"
    handler = ah.Handler(batch_id="B1", mutator_src="", verifier_src="", expected_changes_summary="rename", target_entities=(("crew", "licence"),))
    new_model, outcome = ah._apply_handler_with_retry(handler, batch, model, invariants, None, 1, (), (), 60.0)
    assert new_model is None and outcome.status == "invariant_violation"
    assert "user-pinned products removed" in outcome.diagnostic


def _selffixer(sandbox_new_model, req_text):
    class _AI:
        def _call_ai_query(self, **kwargs):
            return {"mutator_src": "def mutator(model, data):\n    return model\n",
                    "verifier_src": "def verifier(model, data):\n    return (True, '')\n", "rationale": "x"}

    def _sandbox(mutator_src, verifier_src, model, data=None, timeout=20.0):
        return type("SB", (), {"ok": True, "verifier_ok": True, "verifier_diag": "", "error": None,
                               "new_model": copy.deepcopy(sandbox_new_model)})()

    fixer = ah.SelfFixer(ai_agent=_AI(), logger=LOG, sandbox_executor=_sandbox)
    fixer.llm_endpoint = None
    return fixer, {"id": "REQ-1", "text": req_text, "evidence": ""}


def test_selffixer_rejects_a_fix_that_loses_columns_unless_the_requirement_asks():
    model = {"model": {"domains": [{"name": "crew", "products": [
        {"name": "member", "primary_key": "member_id", "attributes": [{"name": "member_id"}, {"name": "full_name"}, {"name": "rank"}]},
        {"name": "roster", "primary_key": "roster_id", "attributes": [{"name": "roster_id"}, {"name": "member_id", "foreign_key_to": "crew.member.member_id"}]},
    ]}]}}
    shrunk = copy.deepcopy(model)
    shrunk["model"]["domains"][0]["products"][0]["attributes"].pop()
    shrunk["model"]["domains"][0]["products"][0]["description"] = "Crew member."
    fixer, req = _selffixer(shrunk, "Describe crew.member")
    ok, applied, evidence = fixer._fix_one_req(copy.deepcopy(model), req, per_req_retries=0)
    assert not ok and not applied
    fixer, req = _selffixer(shrunk, "Remove the rank column from crew.member")
    ok, applied, _ = fixer._fix_one_req(copy.deepcopy(model), req, per_req_retries=0)
    assert ok and applied
