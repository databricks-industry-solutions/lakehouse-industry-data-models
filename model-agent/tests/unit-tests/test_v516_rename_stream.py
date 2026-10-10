import copy
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

REPO = Path(__file__).resolve().parents[3]
RAW = json.loads((REPO / "data-models" / "airlines" / "v1" / "mvm" / "model.json").read_text())
VOV = "vibe modeling of version"
LOG = logging.getLogger("test_v516_rename_stream")


@pytest.fixture(autouse=True)
def _clean():
    ah.set_vibe_scope_runtime(None)
    ah.vov_ledger_reset()
    yield
    ah.set_vibe_scope_runtime(None)
    ah.vov_ledger_reset()


def _events():
    return [(e["kind"], e["old"], e["new"], e["cause"]) for e in ah.vov_rename_events()]


def _attr(domain, product, name, **extra):
    return dict({"domain": domain, "product": product, "attribute": name, "column_name": name, "type": "STRING"}, **extra)


def _prod(domain, product, pk):
    return {"domain": domain, "product": product, "table_name": product, "primary_key": pk}


def test_task2_note_helpers_classify_and_skip_noise(caplog):
    with caplog.at_level(logging.INFO, logger="vov2-pipeline"):
        ah._vov_note_product_rename("crew", "member", "crew", "crew_member", "pass:x")
        ah._vov_note_product_rename("crew", "pairing", "flight", "pairing", "pass:x")
        ah._vov_note_product_rename("crew", "Base", "crew", "base", "pass:x")
        ah._vov_note_attribute_rename("crew", "crew_member", "member_id", "crew_member_id", "pass:x")
        ah._vov_note_domain_rename("ops", "operations", "pass:y")
        ah._vov_note_domain_rename("ops", "", "pass:y")
    assert _events() == [
        ("product", "crew.member", "crew.crew_member", "pass:x"),
        ("move", "crew.pairing", "flight.pairing", "pass:x"),
        ("attribute", "crew.crew_member.member_id", "crew.crew_member.crew_member_id", "pass:x"),
        ("domain", "ops", "operations", "pass:y"),
    ]
    fired = [r.getMessage() for r in caplog.records if "[vov-rename-ledger-sweep FIRED v5.1.6]" in r.getMessage()]
    assert len(fired) == 2


SWEEP_CAUSES = (
    "shrink_relink_orphan_fk", "apply_convention_changes", "product_domain_location_fit", "v441_reviewer_finalize_scd",
    "v441_reviewer_finalize_pci", "v443_pk_selfref_repair", "domain_architect_review", "global_semantic_dedup",
    "global_semantic_dedup_same_name", "find_missing_fk_keep_as_is", "qa_small_domain_merge", "qa_duplicate_product_rename",
    "qa_name_overlap_rename", "apply_naming_case", "ddl_fk_collision_keep", "ddl_pk_dedup", "p074_product_name_collision",
    "p074_pk_attr_sync", "pre_sa_stub_id_product", "p016_ambiguous_fk_rename", "p075_fk_target_pk_suffix",
    "product_list_prefix_compliance", "p73i_prefix_strip", "resize_domain_relocation",
)


def test_task2_every_swept_rename_site_writes_the_ledger():
    src = notebook_concat_source()
    calls = re.findall(r"_vov_note_(?:product|attribute|domain|swept)_rename\([^\n]*", src)
    missing = [c for c in SWEEP_CAUSES if not any(c in call for call in calls)]
    assert not missing, missing
    assert sum(1 for call in calls if "architect_" in call) >= 6
    assert sum(1 for call in calls if "logical_schema_" in call) >= 3


def test_task2_stub_id_product_rename_repoints_the_pk_column_and_ledgers(caplog):
    d = [{"domain": "sales", "database_name": "sales", "division": "business"}]
    p = [_prod("sales", "voucher_id", "voucher_id_id"), _prod("sales", "order", "order_id")]
    a = [_attr("sales", "voucher_id", "voucher_id_id", type="BIGINT", is_primary_key=True),
         _attr("sales", "voucher_id", "voucher_code"),
         _attr("sales", "order", "order_id", type="BIGINT", is_primary_key=True),
         _attr("sales", "order", "voucher_ref", type="BIGINT", foreign_key_to="sales.voucher_id.voucher_id_id")]
    with caplog.at_level(logging.INFO):
        ah._pre_static_analysis_autofix(d, p, a, {}, LOG)
    assert {r["product"] for r in p} >= {"voucher", "order"}
    ref = next(r for r in a if r["attribute"] in ("voucher_ref", "voucher_id") and r["product"] == "order")
    assert ref["foreign_key_to"] == "sales.voucher.voucher_id"
    assert ("product", "sales.voucher_id", "sales.voucher", "pass:pre_sa_stub_id_product") in _events()
    assert ("attribute", "sales.voucher.voucher_id_id", "sales.voucher.voucher_id", "pass:pre_sa_stub_id_product") in _events()
    assert any("[renamed-pk-fk-column-repoint FIRED v5.1.6]" in r.getMessage() for r in caplog.records)


def test_task2_product_list_prefix_repoints_inbound_fk_pk_column_and_ledgers(monkeypatch):
    monkeypatch.setattr(ah, "_parse_product_lists_from_vibes", lambda wv: ({}, False))
    monkeypatch.setattr(ah, "_detect_required_product_prefix", lambda wv: "acme_")
    d = [{"domain": "sales"}]
    p = [_prod("sales", "acme_order", "acme_order_id"), _prod("sales", "customer", "customer_id")]
    a = [_attr("sales", "customer", "customer_id", type="BIGINT", is_primary_key=True),
         _attr("sales", "acme_order", "acme_order_id", type="BIGINT", is_primary_key=True),
         _attr("sales", "acme_order", "customer_id", type="BIGINT", foreign_key_to="sales.customer.customer_id")]
    ah._validate_product_list_compliance({}, d, p, a, {}, LOG)
    assert {r["product"] for r in p} == {"acme_order", "acme_customer"}
    fk = next(r for r in a if r["product"] == "acme_order" and r.get("foreign_key_to"))
    assert fk["foreign_key_to"] == "sales.acme_customer.acme_customer_id"
    assert ("product", "sales.customer", "sales.acme_customer", "pass:product_list_prefix_compliance") in _events()
    assert ("attribute", "sales.acme_customer.customer_id", "sales.acme_customer.acme_customer_id",
            "pass:product_list_prefix_compliance") in _events()


def test_task2_f5_ledger_pairs_follow_a_later_domain_rename(caplog):
    ah._vibe_scope_note_rename("product", "crew.member", "crew.crew_member", "VREQ-1")
    ah._vibe_scope_note_rename("domain", "crew", "workforce", "VREQ-2")
    with caplog.at_level(logging.INFO, logger="vov2-pipeline"):
        pairs = ah._vov_ledger_product_pairs()
    assert pairs == [(("workforce", "member"), ("workforce", ah._vov285_san("crew_member")))]
    assert any("[rename-leftover-domain-projection FIRED v5.1.6]" in r.getMessage() for r in caplog.records)
    assert ah._vov_ledgered_rename_pair("workforce", "member", "crew_member")


def _leftover_flat(twin="member_record"):
    d, p, a, mv = (list(x) for x in ah.model_to_widgets_flat(RAW))
    member = next(r for r in p if (r["domain"], r["product"]) == ("crew", "member"))
    p.append(dict(member, product=twin, table_name=twin, primary_key=f"{twin}_id"))
    for row in [r for r in a if (r["domain"], r["product"]) == ("crew", "member")]:
        name = f"{twin}_id" if row["attribute"] == "member_id" else row["attribute"]
        a.append(dict(row, product=twin, attribute=name, column_name=name))
    return d, p, a, mv


def test_task8_scoped_autofix_reports_out_of_scope_pairs_and_ledgers_in_scope_merges(caplog):
    d, p, a, _mv = _leftover_flat()
    ah.set_vibe_scope_runtime(ah.build_vibe_scope_fence(ah.parse_vibe_scope("Some Domains", "flight"), RAW, VOV, LOG))
    before = copy.deepcopy((p, a))
    with caplog.at_level(logging.WARNING):
        assert ah._vov_merge_rename_leftovers(p, a, {}, LOG, "t") == 0
    assert (p, a) == before
    assert any("[rename-leftover-fence-report FIRED v5.1.6]" in r.getMessage() and "crew.member" in r.getMessage()
               for r in caplog.records)
    ah.set_vibe_scope_runtime(ah.build_vibe_scope_fence(ah.parse_vibe_scope("Some Domains", "crew"), RAW, VOV, LOG))
    assert ah._vov_merge_rename_leftovers(p, a, {}, LOG, "t") == 1
    events = _events()
    assert ("product", "crew.member", "crew.member_record", "pass:t") in events
    assert ("attribute", "crew.member_record.member_id", "crew.member_record.member_record_id", "pass:t") in events
    assert [e for e in ah.vov_change_events() if e["kind"] == "merge"] == [
        {"kind": "merge", "path": "crew.member", "cause": "pass:t", "target": "crew.member_record"}]


def test_task4_rename_leftover_is_an_actionable_requeue_category():
    src = notebook_concat_source()
    block = re.search(r"_ACTIONABLE_CATEGORIES = \{(.*?)\}", src, re.S).group(1)
    assert "'rename_leftover_original'" in block


def test_task5_scoped_extraction_prompt_states_the_fully_qualified_target_rule_once():
    assert "fully qualified" not in ah._VIBE_SCOPE_EXTRACTION_RULES.lower()
    assert "comma" not in ah._VIBE_SCOPE_EXTRACTION_RULES.lower()
    src = notebook_concat_source()
    assert len(re.findall(r"(?i)fully qualified as domain, domain\.product or domain\.product\.column", src)) == 1
    assert "scope_rejected" in ah._VIBE_SCOPE_EXTRACTION_RULES


def _mv_root(names):
    root = {"model": {"domains": [], "metric_views": [{"view_name": n, "sql": "SELECT 1"} for n in names]}}
    root["entity_changes"] = {"entries": [
        {"kind": "metric_view", "status": "unchanged", "path": "mv_keep", "base_path": "mv_keep", "cause": []},
        {"kind": "metric_view", "status": "modified", "path": "mv_gone", "base_path": "mv_gone", "cause": ["VREQ-1"], "fields": ["sql"]},
        {"kind": "metric_view", "status": "added", "path": "mv_new_gone", "base_path": "", "cause": ["VREQ-2"]},
        {"kind": "product", "status": "unchanged", "path": "crew.member", "base_path": "crew.member", "cause": []},
    ], "counts": {}}
    return root


def test_task3_install_cleanup_prunes_metric_view_entries_for_views_that_were_dropped(caplog):
    root = _mv_root(["mv_keep"])
    with caplog.at_level(logging.INFO):
        out = ah._vov_entity_changes_refresh_metric_views(root, None, LOG, "install_mv_cleanup")
    by_base = {e["base_path"]: e for e in out["entries"] if e["kind"] == "metric_view"}
    assert set(by_base) == {"mv_keep", "mv_gone"}
    assert by_base["mv_keep"]["status"] == "unchanged"
    gone = by_base["mv_gone"]
    assert (gone["status"], gone["path"]) == ("dropped", "")
    assert gone["cause"] == ["VREQ-1", "pass:install_mv_cleanup"] and "fields" not in gone
    assert out["counts"]["metric_view"] == {"unchanged": 1, "dropped": 1}
    assert out["counts"]["product"] == {"unchanged": 1}
    assert any("[entity-changes-mv-refresh FIRED v5.1.6]" in r.getMessage() for r in caplog.records)


def test_task3_dict_shaped_metric_views_are_read_by_view_name():
    root = _mv_root([])
    root["model"]["metric_views"] = {"crew": "CREATE OR REPLACE VIEW cat._metrics.mv_keep WITH METRICS LANGUAGE YAML AS $$\nversion: 0.1\n$$;"}
    out = ah._vov_entity_changes_refresh_metric_views(root, None, LOG, "step_apply_metric_views")
    statuses = {e["base_path"]: e["status"] for e in out["entries"] if e["kind"] == "metric_view"}
    assert statuses == {"mv_keep": "unchanged", "mv_gone": "dropped"}


def test_task3_refresh_is_wired_at_both_metric_view_writebacks():
    src = notebook_concat_source()
    assert '_vov_entity_changes_refresh_metric_views(_mj_root, widgets_values, logger, "step_apply_metric_views")' in src
    assert '_vov_entity_changes_refresh_metric_views(_parsed_root, None, _dlog, "install_mv_cleanup")' in src


def test_task7_p5_text_covers_columns():
    assert ah._VIBE_SCOPE_PERMIT_CAUSES["P5"] == "renamed in-scope table or column substituted"
    src = notebook_concat_source()
    assert "- P5: in an out-of-scope metric view, only substitute renamed in-scope table and column names." in src
    assert "reads a renamed in-scope table or column; reconcile applies P5" in src


def test_task7_surgical_preserve_substitutes_ledgered_column_renames(monkeypatch, caplog):
    base = {"model": {
        "products": [{"domain": "crew", "product": "member"}, {"domain": "crew", "product": "roster"}],
        "metric_views": [{"view_name": "mv_member", "owner_domain": "crew", "owner_product": "member",
                          "sql": "SELECT m.rank_code, COUNT(*) FROM cat.crew.member m JOIN cat.crew.roster r ON r.member_id = m.member_id "
                                 "GROUP BY m.rank_code"}]}}
    monkeypatch.setattr(ah, "read_file_for_ddl", lambda path, w: json.dumps(base))
    sdk = types.ModuleType("databricks.sdk")
    sdk.WorkspaceClient = lambda *a, **k: object()
    monkeypatch.setitem(sys.modules, "databricks.sdk", sdk)
    monkeypatch.setitem(sys.modules, "databricks", sys.modules.get("databricks") or types.ModuleType("databricks"))
    ah._vibe_scope_note_rename("product", "crew.member", "crew.crew_member", "VREQ-1")
    ah._vibe_scope_note_rename("attribute", "crew.crew_member.member_id", "crew.crew_member.crew_member_id", "VREQ-1")
    ah._vibe_scope_note_rename("attribute", "crew.crew_member.rank_code", "crew.crew_member.rank", "VREQ-2")
    wv = {"operation": VOV, "base_version_for_review": "1", "current_version": "2", "model_scope": "mvm",
          "products": [{"domain": "crew", "product": "crew_member"}, {"domain": "crew", "product": "roster"}]}
    cfg = {"TARGET_VOLUME": "/Volumes/c/s/v/airlines/v2/mvm"}
    with caplog.at_level(logging.INFO):
        ah._preserve_baseline_metric_views_for_surgical(wv, cfg, LOG)
    mvs = wv.get("_metric_view_records") or []
    assert len(mvs) == 1, mvs
    sql = mvs[0]["sql"]
    assert "crew.crew_member" in sql and "m.rank," in sql and "GROUP BY m.rank" in sql
    assert "m.crew_member_id" in sql and "r.member_id" in sql
    assert "rank_code" not in sql
    assert any("[surgical-mv-column-rewrite FIRED v5.1.6]" in r.getMessage() for r in caplog.records)


def test_task7_column_jobs_ignore_case_only_and_unqualified_events():
    ah._vibe_scope_note_rename("attribute", "crew.member.Rank", "crew.member.rank", "x")
    ah._vibe_scope_note_rename("attribute", "rank", "grade", "x")
    assert ah._vov_ledger_column_jobs({}) == []


def test_task9_rename_product_rebuilds_a_pk_that_only_contains_the_old_name_mid_identifier(caplog):
    m = {"domains": [{"name": "museum", "products": [
        {"name": "art", "primary_key": "artwork_id", "attributes": [{"name": "artwork_id", "type": "BIGINT"}]},
        {"name": "loan", "primary_key": "loan_id", "attributes": [
            {"name": "loan_id", "type": "BIGINT"}, {"name": "artwork_id", "type": "BIGINT", "foreign_key_to": "museum.art.artwork_id"}]}]}]}
    with caplog.at_level(logging.INFO, logger="vov2-pipeline"):
        assert ah._v337_apply_rename_product(m, "museum", "art", "artefact")
    art = m["domains"][0]["products"][0]
    assert art["primary_key"] == "artefact" + ah.get_pk_suffix() == "artefact_id"
    assert art["attributes"][0]["name"] == "artefact_id"
    assert m["domains"][0]["products"][1]["attributes"][1]["foreign_key_to"] == "museum.artefact.artefact_id"
    assert any("[rename-product-pk-prefix FIRED v5.1.6]" in r.getMessage() for r in caplog.records)


def test_task9_rename_product_keeps_the_configured_suffix_tail_at_a_word_boundary(monkeypatch):
    monkeypatch.setitem(ah._PIPELINE_CONFIG_RUNTIME, "config", {"MODEL_CONVENTIONS": {"primary_key_suffix": "_key"}})
    m = {"domains": [{"name": "crew", "products": [
        {"name": "member", "primary_key": "member_key", "attributes": [{"name": "member_key", "type": "BIGINT"}]},
        {"name": "id_card", "primary_key": "legacy_ref", "attributes": [{"name": "legacy_ref", "type": "BIGINT"}]}]}]}
    ah._v337_apply_rename_product(m, "crew", "member", "crew_member")
    ah._v337_apply_rename_product(m, "crew", "id_card", "badge")
    pks = [p["primary_key"] for p in m["domains"][0]["products"]]
    assert pks == ["crew_member_key", "badge_key"]
    assert not [k for k in pks if k.endswith("_id")]


def test_task9_suffix_group_strips_the_pk_suffix_only_at_the_end(caplog):
    d = [{"domain": "ideas"}, {"domain": "sales"}, {"domain": "ops"}]
    p = [_prod("ideas", "product_idea", "product_idea_id"), _prod("sales", "order", "order_id"), _prod("ops", "ticket", "ticket_id")]
    a = [_attr("ideas", "product_idea", "product_idea_id", type="BIGINT", is_primary_key=True),
         _attr("sales", "order", "order_id", type="BIGINT", is_primary_key=True),
         _attr("sales", "order", "product_idea_id", type="BIGINT"),
         _attr("ops", "ticket", "ticket_id", type="BIGINT", is_primary_key=True),
         _attr("ops", "ticket", "product_idea_id", type="BIGINT"),
         _attr("ops", "ticket", "qzx_marker_id", type="BIGINT")]
    cfg = {"_widgets_values": {"_vov_removed_fk_fqns": ["sales.order.product_idea_id", "ops.ticket.product_idea_id"]}}
    with caplog.at_level(logging.INFO):
        ah._create_missing_parent_tables_for_unlinked_fks(d, p, a, cfg, LOG)
    assert sorted(r["product"] for r in p) == ["order", "product_idea", "ticket"]
    assert any("[pk-suffix-trailing-strip FIRED v5.1.6]" in r.getMessage() for r in caplog.records)


def test_anchored_pass_blanks_handled_lines_without_shifting_offsets():
    import test_v514_contract_inputs as CI
    ah.set_vibe_scope_runtime(None)
    stripped, _imap = CI._input_map()
    _model, vreqs, _outcomes, out = ah._vov_apply_anchored_directives(stripped, CI.E._engine(), LOG)
    assert [v.vreq_id for v in vreqs] == ["ANCHOR-001"]
    assert "Rename roster to duty_roster" not in out
    assert len(out) == len(stripped)
    tail = stripped.index("## Domain: fleet")
    assert out[tail:] == stripped[tail:]
