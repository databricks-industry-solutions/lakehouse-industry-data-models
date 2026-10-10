"""v5.2.2: restructuring requirements land in an unscoped strict VOV, and a scoped install of a Dry Run lands on its base.

Live R10 53995095148222 (5.2.0, advertising v3 -> v4) asked for a product rename, a domain rename, a domain merge, a
two-product move and a description edit. The domain rename failed on every attempt and the merge was reported
applied although the project domain was untouched:
- "Rename the domain vendor to partner" parsed as a rename of a domain named "the";
- "Merge the domain project into client" did not parse at all;
- a domain rename or merge produced no rename pair, so the fence saw the follow-up FK retargets as frozen changes,
  and diff_within_summary_scope rejected the removed domain;
- the rename postcondition had no domain branch, so nothing caught the merge that never happened.

Live R7b 336135601582356 (5.2.1) installed the scoped Dry Run v6 on its installed base v5: the full-install clash
guard refused the four existing schemas, and the failed install left v6 registered as installed.
"""
import copy
import sys
import types
from pathlib import Path

import pytest

sys.path.insert(0, str(Path(__file__).resolve().parent))
import conftest  # noqa: F401,E402
import agent_helpers as ah  # noqa: E402


def _attr(name, fk=""):
    return {"name": name, "type": "BIGINT" if name.endswith("_id") else "STRING", "foreign_key_to": fk}


def _model():
    return {"model": {"domains": [
        {"name": "vendor", "products": [
            {"name": "supplier", "primary_key": "supplier_id", "attributes": [_attr("supplier_id"), _attr("supplier_name")]},
            {"name": "publisher", "primary_key": "publisher_id", "attributes": [_attr("publisher_id"), _attr("supplier_id", "vendor.supplier.supplier_id")]},
        ]},
        {"name": "campaign", "products": [
            {"name": "ad", "primary_key": "ad_id", "attributes": [_attr("ad_id"), _attr("supplier_id", "vendor.supplier.supplier_id")]},
        ]},
        {"name": "performance", "products": [
            {"name": "tracking_pixel", "primary_key": "tracking_pixel_id", "attributes": [_attr("tracking_pixel_id"), _attr("ad_id", "campaign.ad.ad_id")]},
            {"name": "attribution_model", "primary_key": "attribution_model_id", "attributes": [_attr("attribution_model_id")]},
        ]},
        {"name": "media", "products": [
            {"name": "placement", "primary_key": "placement_id", "attributes": [_attr("placement_id")]},
        ]},
    ]}}


def _vreq(target, text):
    return types.SimpleNamespace(vreq_id="VREQ-0001", target=target, intent=text, source_quote=text)


@pytest.mark.parametrize("text,expected", [
    ("[vendor] Rename the domain vendor to partner.", ("vendor", "partner")),
    ("Rename the vendor domain to partner", ("vendor", "partner")),
    ("rename domain `vendor` to `partner`", ("vendor", "partner")),
    ("In the vendor domain, rename the domain to partner", None),
])
def test_a_domain_rename_never_reads_an_article_as_the_domain(text, expected):
    assert ah._v337_extract_domain_rename(text) == expected


@pytest.mark.parametrize("text,expected", [
    ("[project] Merge the domain project into client, so every project product now belongs to client.", ("project", "client")),
    ("merge domain project into the client domain", ("project", "client")),
    ("Merge the project domain into client", ("project", "client")),
    ("Fold project into client domain", ("project", "client")),
    ("Merge the domain into the client domain", None),
])
def test_merge_the_domain_x_into_y_parses(text, expected):
    assert ah._v337_extract_domain_merge(text) == expected


def test_domain_renames_and_merges_produce_a_pending_rename_pair():
    model = _model()
    rename = _vreq("vendor", "[vendor] Rename the domain vendor to partner.")
    merge = _vreq("vendor", "Merge the domain vendor into media, so every vendor product now belongs to media.")
    assert ah._v413_vreq_to_det_op(rename, model) == ("rename_domain", "vendor", "partner")
    assert ah._vov_rename_pairs_for_vreqs([rename, merge], model) == [("domain", "vendor", "partner"), ("domain", "vendor", "media")]
    assert ah._vov_pairs_touching([("domain", "vendor", "partner")], [("vendor", "*")]) == [("domain", "vendor", "partner")]
    assert ah._vov_pairs_touching([("domain", "vendor", "partner")], [("vendor", "supplier")]) == [("domain", "vendor", "partner")]
    assert ah._vov_pairs_touching([("domain", "vendor", "partner")], [("campaign", "ad")]) == []


def test_the_fence_resolves_fk_retargets_through_a_pending_domain_rename():
    events = [ah._vov_rename_event("domain", "vendor", "partner", "pending")]
    assert ("partner", "supplier", "supplier_id") in ah._vov_resolve_rename_candidates("vendor", "supplier", "supplier_id", events)


@pytest.mark.parametrize("text,expected", [
    ("Move the products tracking_pixel and attribution_model from the performance domain to the media domain.", ("move_product", "performance", "tracking_pixel", "media")),
    ("Move the product tracking_pixel to the media domain", ("move_product", "performance", "tracking_pixel", "media")),
    ("Move the column ad_id of tracking_pixel to the media domain", None),
    ("Move the product tracking_pixel to the nowhere domain", None),
    ("Rewrite the description of tracking_pixel", None),
])
def test_a_free_text_move_of_a_named_product_is_deterministic(text, expected):
    assert ah._v337_classify_op("", "performance.tracking_pixel", text, "", _model()) == expected


def _renamed(model, lose=False, stale_fk=False):
    out = copy.deepcopy(model)
    vendor = next(d for d in out["model"]["domains"] if d["name"] == "vendor")
    vendor["name"] = "partner"
    if lose:
        vendor["products"].pop()
    for d in out["model"]["domains"]:
        for p in d["products"]:
            for a in p["attributes"]:
                if a["foreign_key_to"].startswith("vendor.") and not stale_fk:
                    a["foreign_key_to"] = "partner." + a["foreign_key_to"].split(".", 1)[1]
    return out


def test_the_rename_postcondition_checks_a_domain_rename_and_its_products():
    before, pair = _model(), [("domain", "vendor", "partner")]
    assert ah._vov_rename_postcondition(before, _renamed(before), pair) == (True, "")
    ok, diag = ah._vov_rename_postcondition(before, _renamed(before, lose=True), pair)
    assert not ok and "1 product(s) of vendor did not reach partner" in diag
    ok, diag = ah._vov_rename_postcondition(before, _renamed(before, stale_fk=True), pair)
    assert not ok and "foreign_key_to still point into domain vendor" in diag
    ok, diag = ah._vov_rename_postcondition(before, before, pair)
    assert not ok and "domain vendor still exists next to partner" in diag and "domain partner is missing" in diag


def test_the_scope_guard_accepts_a_rehomed_domain_and_rejects_a_lossy_one():
    before = _model()
    diff = ah.diff_models_summary(before, _renamed(before))
    assert diff["products_in_removed_domains"] == [("vendor", "publisher"), ("vendor", "supplier")]
    assert diff["products_in_added_domains"] == [("partner", "publisher"), ("partner", "supplier")]
    assert ah.diff_within_summary_scope(diff, "Renames the domain vendor to partner in place", ["partner"]) == (True, "")
    ok, diag = ah.diff_within_summary_scope(ah.diff_models_summary(before, _renamed(before, lose=True)), "Renames the domain vendor to partner", ["partner"])
    assert not ok and "domains_removed=['vendor']" in diag
    ok, diag = ah.diff_within_summary_scope(diff, "Renames a domain in place", ["partner"])
    assert not ok and "domains_removed=['vendor']" in diag


def test_the_serialized_ledger_keeps_only_events_that_landed():
    renames = [{"kind": "domain", "old": "vendor", "new": "partner"},
               {"kind": "domain", "old": "project", "new": "client"},
               {"kind": "product", "old": "campaign.ad", "new": "campaign.advert"},
               {"kind": "attribute", "old": "campaign.ad.ad_name", "new": "campaign.ad.ad_id"}]
    changes = [{"kind": "drop", "path": "vendor.supplier", "cause": "corrective:rename:vendor"},
               {"kind": "drop", "path": "performance.gone", "cause": "VREQ-1"},
               {"kind": "create", "path": "media.placement", "cause": "VREQ-2"},
               {"kind": "create", "path": "media.never_made", "cause": "VREQ-3"}]
    landed, kept = ah._vov_landed_events(renames, changes, _renamed(_model()))
    assert landed == [renames[0], renames[3]]
    assert kept == [changes[0], changes[1], changes[2]]
    landed, kept = ah._vov_landed_events(renames, changes, _model())
    assert landed == [renames[3]], "a rename the run reverted is not reported"
    assert kept == [changes[1], changes[2]], "a drop the run reverted is not reported"


class _Rows:
    def __init__(self, rows):
        self.rows = rows

    def collect(self):
        return self.rows


class _Spark:
    def __init__(self, status_rows):
        self.status_rows, self.sql_seen = status_rows, []

    def sql(self, statement):
        self.sql_seen.append(statement)
        if statement.startswith("SELECT deploy_status"):
            return _Rows(self.status_rows)
        if statement.startswith("SHOW SCHEMAS"):
            return _Rows([("customer",), ("order",)])
        return _Rows([])


class _Log:
    def __init__(self):
        self.lines = []

    def info(self, msg, *a, **k):
        self.lines.append(str(msg))

    warning = error = debug = info


@pytest.mark.parametrize("rows,expected", [([], None), ([("dry_run",)], "dry_run"), ([(None,)], "")])
def test_the_registry_status_before_an_install_is_read(rows, expected):
    assert ah._registry_deploy_status(_Spark(rows), "cat", "vs514 retail", "6", "mvm") == expected


@pytest.mark.parametrize("prior,statement", [
    (None, "DELETE FROM `cat`.`_metamodel`.`business`"),
    ("dry_run", "UPDATE `cat`.`_metamodel`.`business` SET deploy_status = 'dry_run'"),
    ("", "UPDATE `cat`.`_metamodel`.`business` SET deploy_status = NULL"),
])
def test_a_failed_install_reverts_its_registry_row(prior, statement):
    spark, log = _Spark([]), _Log()
    assert ah._registry_undo_failed_install(spark, "cat", "vs514 retail", "6", "mvm", prior, log) is True
    assert any(s.startswith(statement) for s in spark.sql_seen), spark.sql_seen
    assert any("install-registry-undo FIRED v5.2.2" in m for m in log.lines)
    if prior is None:
        assert [s.split("`")[5] for s in spark.sql_seen] == ["attribute", "product", "domain", "business"]


def test_an_unknown_prior_status_is_reported_not_guessed():
    spark, log = _Spark([]), _Log()
    assert ah._registry_undo_failed_install(spark, "cat", "vs514 retail", "6", "mvm", "unknown", log) is False
    assert spark.sql_seen == [] and any("could not be reverted" in m for m in log.lines)


def _snap(owned, foreign=()):
    return {"business": "vs514 retail", "target": "cat", "style": "one_catalog", "owned": {k: ["v5"] for k in owned},
            "foreign": {k: ["other"] for k in foreign}, "owned_catalogs": [], "foreign_catalogs": [], "metamodel": "cat._metamodel", "error": None}


def test_a_scoped_install_on_its_owned_base_passes_the_clash_check():
    log = _Log()
    wv = {"_schema_ownership": _snap(["cat.customer", "cat.order"]), "_scoped_install_base": True, "operation": "install model"}
    ah._check_physical_deployment_clash(_Spark([]), [("cat", "customer"), ("cat", "order")], wv, logger=log)
    assert any("scoped-install-clash FIRED v5.2.2" in m for m in log.lines)


def test_a_scoped_install_still_refuses_a_schema_another_business_owns():
    wv = {"_schema_ownership": _snap(["cat.customer"], ["cat.order"]), "_scoped_install_base": True, "operation": "install model"}
    with pytest.raises(ValueError, match="SCHEMA OWNERSHIP CLASH"):
        ah._check_physical_deployment_clash(_Spark([]), [("cat", "customer"), ("cat", "order")], wv, logger=_Log())


def test_a_full_install_over_existing_schemas_is_still_refused():
    with pytest.raises(ValueError, match="PHYSICAL DEPLOYMENT CLASH"):
        ah._check_physical_deployment_clash(_Spark([]), [("cat", "customer")], {"operation": "install model"}, logger=_Log())


def _mv(view, dom, prod, body):
    return {"view_name": view, "owner_domain": dom, "owner_product": prod,
            "sql": f"CREATE OR REPLACE VIEW `cat`.`_metrics`.`{view}`\nWITH METRICS\nLANGUAGE YAML\nAS $$\n{body}\n$$"}


def _model_with_views():
    model = _model()
    model["model"]["metric_views"] = [
        _mv("vendor_publisher", "vendor", "publisher", '  source: "`cat`.`vendor`.`publisher`"\n  joins:\n    - name: s\n      source: "`cat`.`vendor`.`supplier`"\n      on: source.supplier_id = s.supplier_id'),
        _mv("campaign_ad", "campaign", "ad", '  source: "`cat`.`campaign`.`ad`"\n  dimensions:\n    - name: "ad"\n      expr: ad_id'),
        _mv("performance_tracking_pixel", "performance", "tracking_pixel", '  source: "`cat`.`performance`.`tracking_pixel`"\n  joins:\n    - name: a\n      source: "`cat`.`campaign`.`ad`"\n      on: source.ad_id = a.ad_id'),
    ]
    return model


def _view(model, name):
    return next(mv for mv in model["model"]["metric_views"] if mv["view_name"] == name)


def test_a_domain_rename_carries_its_metric_views():
    model = _model_with_views()
    assert ah._v337_apply_rename_domain(model["model"], "vendor", "partner") is not None
    mv = _view(model, "partner_publisher")
    assert (mv["owner_domain"], mv["owner_product"]) == ("partner", "publisher")
    assert "`cat`.`partner`.`publisher`" in mv["sql"] and "`cat`.`partner`.`supplier`" in mv["sql"] and "`vendor`" not in mv["sql"]
    assert "`_metrics`.`partner_publisher`" in mv["sql"] and "vendor_publisher" not in mv["sql"]
    assert _view(model, "campaign_ad")["sql"] == _view(_model_with_views(), "campaign_ad")["sql"]


def test_a_domain_merge_carries_its_metric_views():
    model = _model_with_views()
    assert ah._v337_apply_merge_domain(model["model"], "vendor", "media") is not None
    mv = _view(model, "media_publisher")
    assert (mv["owner_domain"], mv["owner_product"]) == ("media", "publisher")
    assert "`cat`.`media`.`publisher`" in mv["sql"] and "`cat`.`media`.`supplier`" in mv["sql"]


def test_a_product_move_carries_its_metric_view():
    model = _model_with_views()
    assert ah._v337_apply_move_product(model["model"], "performance", "tracking_pixel", "media") is not None
    mv = _view(model, "media_tracking_pixel")
    assert (mv["owner_domain"], mv["owner_product"]) == ("media", "tracking_pixel")
    assert "`cat`.`media`.`tracking_pixel`" in mv["sql"] and "`cat`.`campaign`.`ad`" in mv["sql"]


def test_a_product_rename_carries_its_views_and_the_renamed_key():
    model = _model_with_views()
    assert ah._v337_apply_rename_product(model["model"], "campaign", "ad", "advert") is not None
    own, joined = _view(model, "campaign_advert"), _view(model, "performance_tracking_pixel")
    assert (own["owner_domain"], own["owner_product"]) == ("campaign", "advert")
    assert "`cat`.`campaign`.`advert`" in own["sql"] and "expr: advert_id" in own["sql"]
    assert "`cat`.`campaign`.`advert`" in joined["sql"] and "a.advert_id" in joined["sql"] and "source.ad_id" in joined["sql"]


def test_an_attribute_rename_carries_the_column_into_metric_views():
    model = _model_with_views()
    assert ah._v337_apply_rename_attribute(model["model"], "campaign", "ad", "ad_id", "advert_key") is not None
    assert "expr: advert_key" in _view(model, "campaign_ad")["sql"] and _view(model, "campaign_ad")["owner_product"] == "ad"
    assert "a.advert_key" in _view(model, "performance_tracking_pixel")["sql"]


def test_a_frozen_metric_view_is_left_to_the_fence_p5():
    model = _model_with_views()
    spec = ah.parse_vibe_scope("Some Domains", "campaign")
    fence = ah.build_vibe_scope_fence(spec, model, "vibe modeling of version", _Log())
    ah.set_vibe_scope_runtime(fence)
    try:
        frozen_before = _view(model, "performance_tracking_pixel")["sql"]
        assert ah._v337_apply_rename_product(model["model"], "campaign", "ad", "advert") is not None
        assert _view(model, "performance_tracking_pixel")["sql"] == frozen_before
        assert "`cat`.`campaign`.`advert`" in _view(model, "campaign_advert")["sql"]
    finally:
        ah.set_vibe_scope_runtime(None)


def test_a_move_the_directive_expander_applies_leaves_the_llm_loop(monkeypatch):
    import test_v514_rename_integrity as RI
    text = "Move the product roster from the crew domain to the flight domain."
    vreq = ah.RawVREQ(vreq_id="VREQ-0001", intent=text, target="crew.roster", source_quote="- " + text, source_chunk_id="c1",
                      is_user_directive=True)
    monkeypatch.setitem(ah.__dict__, "extract_all", lambda *a, **k: [vreq])
    monkeypatch.setattr(ah, "logger", RI.LOG, raising=False)
    llm = RI._FakeLLM()
    result = ah.run_vov_pipeline("## crew\n- " + text + "\n", RI._engine(), llm, [], [], parallel=False, priority_reapply_loops=1)
    assert RI._has(result.final_model, "flight", "roster") and not RI._has(result.final_model, "crew", "roster")
    assert RI._statuses(result)["VREQ-0001"] == ["applied"]
    assert not [system for system, _user in llm.prompts if "group VREQs into BATCHES" in system]


def _strict_fence(vreqs):
    ah.vov_ledger_reset()
    fence = ah._vibe_scope_start_requested(vreqs, _model(), _Log())
    assert fence is not None and fence.spec.mode == "requested"
    return fence


def _relocated_flat():
    d, p, a, mv = ah.model_to_widgets_flat(copy.deepcopy(_model()), quiet=True)
    for rows in (d, p, a):
        for row in rows:
            if row.get("domain") == "vendor":
                row["domain"] = "partner"
    p.append({"domain": "partner", "product": "partner_note", "primary_key": "partner_note_id"})
    a.append({"domain": "partner", "product": "partner_note", "attribute": "partner_note_id", "type": "BIGINT"})
    return d, p, a, mv


def test_a_renamed_domain_keeps_its_base_lineage_and_stays_protected_from_autofix():
    fence = _strict_fence([_vreq("vendor", "[vendor] Rename the domain vendor to partner.")])
    try:
        ah._vibe_scope_note_rename("domain", "vendor", "partner", "VREQ-0001")
        ah._vibe_scope_note_rename("move", "performance.attribution_model", "media.attribution_model", "VREQ-0002")
        assert fence.base_key_of("partner", "supplier") == ("vendor", "supplier")
        assert fence.base_key_of("media", "attribution_model") == ("performance", "attributionmodel")
        assert fence.base_key_of("partner", "partner_note") is None
        assert fence.in_base_lineage("partner", "supplier", "supplier_name") and not fence.in_base_lineage("partner", "supplier", "new_col")
        assert fence.base_domain_of("partner") == "vendor" and fence.base_domain_of("brand_new") is None
        d, p, a, mv = _relocated_flat()
        with ah._vibe_scope_contain(d, p, a, _Log(), "autofix:pre_sa_naming_convention"):
            for row in a:
                if (row["domain"], row["product"], row["attribute"]) == ("partner", "supplier", "supplier_name"):
                    row["attribute"] = "name"
                if (row["domain"], row["product"], row["attribute"]) == ("partner", "partner_note", "partner_note_id"):
                    row["attribute"] = "note_id"
        names = {(r["domain"], r["product"], r["attribute"]) for r in a}
        assert ("partner", "supplier", "supplier_name") in names and ("partner", "supplier", "name") not in names
        assert ("partner", "partner_note", "note_id") in names, "a product created this run is still shaped by autofix passes"
        fence.requested_snapshot(d, p, a, mv, _Log())
        spec, _baseline = fence._engine_snapshot
        assert spec.products == {("partner", "partnernote")} and spec.whole_domains == frozenset()
    finally:
        ah.set_vibe_scope_runtime(None)
        ah.vov_ledger_reset()


def test_a_duplicate_requirement_for_a_landed_rename_counts_as_already_satisfied():
    ah.vov_ledger_reset()
    model = _model()
    op = ("rename_domain", "vendor", "partner")
    assert ah._vov_det_op_already_landed(op, model) is False
    assert ah._v337_apply_rename_domain(model["model"], "vendor", "partner") is not None
    assert ah._vov_det_op_already_landed(op, model) is True
    assert ah._vov_det_op_already_landed(("rename_domain", "campaign", "promo"), model) is False
    ah.vov_ledger_reset()


def test_a_subdomain_moved_by_a_domain_rename_cites_the_rename():
    base = _model()
    for d in base["model"]["domains"]:
        for p in d["products"]:
            p["subdomain"] = d["name"] + "_core"
    cur = copy.deepcopy(base)
    next(d for d in cur["model"]["domains"] if d["name"] == "vendor")["name"] = "partner"
    for d in cur["model"]["domains"]:
        for p in d["products"]:
            for a in p["attributes"]:
                if a["foreign_key_to"].startswith("vendor."):
                    a["foreign_key_to"] = "partner." + a["foreign_key_to"].split(".", 1)[1]
    ah.vov_ledger_reset()
    ah._vov_record_rename("domain", "vendor", "partner", "VREQ-0001")
    wv = {"operation": "vibe modeling of version", "_vov_2_raw_vreqs": [{"vreq_id": "VREQ-0001", "target": "vendor"}],
          "_vov_2_pipeline_result": {"outcomes": [{"status": "applied", "vreq_ids": ["VREQ-0001"], "target_entities": [["vendor", "*"]]}]}}
    changes = ah.vov_entity_changes(base, cur, wv)
    sub = next(e for e in changes["entries"] if e["kind"] == "subdomain" and e["base_path"] == "vendor.vendor_core")
    assert sub["status"] == "renamed" and "VREQ-0001" in sub["cause"]
    ah.vov_ledger_reset()


def _flat_rows():
    return ah.model_to_widgets_flat(copy.deepcopy(_model()), quiet=True)


def test_the_fallback_validator_reads_the_dotted_ref_inside_a_prose_target():
    d, p, a, _mv = _flat_rows()
    hint = {"check_type": "existence", "target_description": "performance.tracking_pixel table in performance domain",
            "expected_outcome": "performance.tracking_pixel exists after move"}
    assert ah._llm_fallback_validate(hint, d, p, a, _Log()) is True
    hint["target_description"] = "media.tracking_pixel table in media domain"
    assert ah._llm_fallback_validate(hint, d, p, a, _Log()) is False


def test_a_fallback_mutation_cannot_write_a_dotted_table_name_or_key():
    d, p, a, _mv = _flat_rows()
    log = _Log()
    muts = [{"entity_type": "product", "operation": "modify", "entity_ref": "performance.tracking_pixel", "field": "table_name",
             "new_value": "media.tracking_pixel"},
            {"entity_type": "product", "operation": "modify", "entity_ref": "performance.tracking_pixel", "field": "primary_key",
             "new_value": "tracking pixel id"}]
    row = next(r for r in p if r["product"] == "tracking_pixel")
    before = (row.get("table_name"), row.get("primary_key"))
    assert ah._llm_fallback_apply_mutations(muts, d, p, a, [], log) == 0
    assert (row.get("table_name"), row.get("primary_key")) == before and before[1] == "tracking_pixel_id"
    assert any("P0.91-PROSE-REJECT" in m for m in log.lines)


def test_a_priority_rename_moves_the_table_name_and_key_with_the_product():
    model = _model()
    for d in model["model"]["domains"]:
        for prod in d["products"]:
            prod["table_name"] = prod["name"]
    ok, why = ah._v251_apply_priority_deterministic({"action": "rename_product", "target": "campaign.ad"}, {"new_name": "advert"}, model, _Log())
    assert (ok, why) == (True, "applied")
    advert = next(prod for d in model["model"]["domains"] for prod in d["products"] if prod["name"] == "advert")
    assert advert["table_name"] == "advert" and advert["primary_key"] == "advert_id"
    pixel = next(prod for d in model["model"]["domains"] for prod in d["products"] if prod["name"] == "tracking_pixel")
    assert next(x for x in pixel["attributes"] if x["name"] == "ad_id")["foreign_key_to"] == "campaign.advert.advert_id"


def test_a_domain_rename_keeps_a_schema_prefix_and_repairs_a_foreign_schema_name():
    model = _model()
    vendor = next(d for d in model["model"]["domains"] if d["name"] == "vendor")
    vendor["database_name"] = "dbx_vendor"
    media = next(d for d in model["model"]["domains"] if d["name"] == "media")
    media["database_name"] = "project"
    ah._v337_apply_rename_domain(model["model"], "vendor", "partner")
    ah._v337_apply_rename_domain(model["model"], "media", "channel")
    names = {d["name"]: d["database_name"] for d in model["model"]["domains"] if d.get("database_name")}
    assert names == {"partner": "dbx_partner", "channel": "channel"}


def test_a_domain_whose_schema_names_another_domain_is_flagged():
    d, p, a, _mv = _flat_rows()
    for row in d:
        row["database_name"] = {"vendor": "dbx_vendor", "media": "project"}.get(row["domain"], row["domain"])
    issues = ah.run_metamodel_static_analysis(d, p, a, {}, _Log())["issues"]
    hits = [i for i in issues if i["category"] == "domain_database_name_mismatch"]
    assert [h["details"]["domain"] for h in hits] == ["media"]


def test_a_merged_domain_is_reported_as_merged_not_renamed():
    base = _model()
    cur = copy.deepcopy(base)
    ah.vov_ledger_reset()
    assert ah._v337_apply_merge_domain(cur["model"], "vendor", "media") is not None
    changes = ah.vov_entity_changes(base, cur, {"operation": "vibe modeling of version"})
    entry = next(e for e in changes["entries"] if e["kind"] == "domain" and e["base_path"] == "vendor")
    assert (entry["status"], entry["path"]) == ("merged", "media")
    ah.vov_ledger_reset()


def test_a_table_name_that_is_not_an_identifier_is_an_error():
    d, p, a, _mv = _flat_rows()
    for row in p:
        row["table_name"] = "media.tracking_pixel" if row["product"] == "tracking_pixel" else row["product"]
    issues = ah.run_metamodel_static_analysis(d, p, a, {}, _Log())["issues"]
    bad = [i for i in issues if i["category"] == "invalid_table_name"]
    assert [(i["details"]["table"], i["severity"]) for i in bad] == [("performance.tracking_pixel", "error")]
    assert not [i for i in issues if i["category"] == "table_name_product_mismatch" and i["details"]["table"] == "performance.tracking_pixel"]


def test_subdomains_of_a_deterministically_renamed_domain_cite_the_rename():
    base = _model()
    for d in base["model"]["domains"]:
        for prod in d["products"]:
            prod["subdomain"] = d["name"] + "_core"
    cur = copy.deepcopy(base)
    ah.vov_ledger_reset()
    assert ah._v337_apply_rename_domain(cur["model"], "vendor", "partner") is not None
    ah.vov_ledger_reset()
    ah._vov_record_rename("domain", "vendor", "partner", "VREQ-0007")
    wv = {"operation": "vibe modeling of version",
          "_vov_2_pipeline_result": {"outcomes": [{"status": "applied", "vreq_ids": ["VREQ-0007"], "target_entities": []}]}}
    changes = ah.vov_entity_changes(base, cur, wv)
    sub = next(e for e in changes["entries"] if e["kind"] == "subdomain" and e["base_path"] == "vendor.vendor_core")
    assert sub["status"] == "renamed" and "VREQ-0007" in sub["cause"]
    ah.vov_ledger_reset()


def test_a_renamed_product_metric_view_takes_the_new_name_once():
    ah.vov_ledger_reset()
    model = _model_with_views()
    assert ah._v337_apply_rename_product(model["model"], "campaign", "ad", "advert") is not None
    names = [mv["view_name"] for mv in model["model"]["metric_views"]]
    assert names.count("campaign_advert") == 1 and "campaign_ad" not in names
    assert ah._VOV_LEDGER["mv_renames"] == {"campaign_advert": "campaign_ad"}
    ah.vov_ledger_reset()
    assert ah._VOV_LEDGER["mv_renames"] == {}


def test_a_metric_view_keeps_its_name_when_the_new_name_is_taken():
    ah.vov_ledger_reset()
    model = _model_with_views()
    model["model"]["metric_views"].append(_mv("campaign_advert", "campaign", "advert", '  source: "`cat`.`campaign`.`advert`"'))
    assert ah._v337_apply_rename_product(model["model"], "campaign", "ad", "advert") is not None
    names = [mv["view_name"] for mv in model["model"]["metric_views"]]
    assert names.count("campaign_advert") == 1 and "campaign_ad" in names
    assert _view(model, "campaign_ad")["owner_product"] == "advert" and ah._VOV_LEDGER["mv_renames"] == {}


@pytest.mark.parametrize("view,old,new,expected", [
    ("campaign_ad", ("campaign", "ad"), ("campaign", "advert"), "campaign_advert"),
    ("campaign_ad_spend", ("campaign", "ad"), ("campaign", "advert"), "campaign_advert_spend"),
    ("campaign_adx", ("campaign", "ad"), ("campaign", "advert"), "campaign_adx"),
    ("vendor_publisher_kpis", ("vendor", "publisher"), ("partner", "publisher"), "partner_publisher_kpis"),
    ("vendor_rollup", ("vendor", "publisher"), ("partner", "publisher"), "partner_rollup"),
    ("media_rollup", ("vendor", "publisher"), ("partner", "publisher"), "media_rollup"),
    ("crew_member", ("crew", "member"), ("crew", "crew_member"), "crew_member"),
    ("order_channel", ("order", "channel"), ("order", "order_channel"), "order_channel"),
    ("crew_member_kpis", ("crew", "crew_member"), ("crew", "member"), "crew_member_kpis"),
])
def test_the_view_name_follows_only_its_own_owner_prefix(view, old, new, expected):
    assert ah._v337_renamed_view_name(view, old, new) == expected


def test_entity_changes_report_a_renamed_metric_view():
    ah.vov_ledger_reset()
    base = _model_with_views()
    new = copy.deepcopy(base)
    assert ah._v337_apply_rename_product(new["model"], "campaign", "ad", "advert") is not None
    rows = [e for e in ah.vov_entity_changes(base, new)["entries"] if e["kind"] == "metric_view" and e["status"] != "unchanged"]
    assert [(e["status"], e["path"], e["base_path"]) for e in rows if "campaign" in e["path"] + e["base_path"]] == [("renamed", "campaign_advert", "campaign_ad")]
    ah.vov_ledger_reset()


def _transient_fence():
    import test_v514_vibe_scope_parse as PS
    raw = copy.deepcopy(PS.RAW)
    log = _Log()
    fence = ah.build_vibe_scope_fence(ah.parse_vibe_scope("Some Domains", "crew"), copy.deepcopy(raw), "vibe modeling of version", log)
    return fence, ah.model_to_widgets_flat(copy.deepcopy(raw)), log


def _toggle_transient(flat):
    d, p, a, _mv = copy.deepcopy(flat)
    pks = {(r["domain"], r["product"]): r.get("primary_key") for r in p}
    for row in a:
        if pks.get((row["domain"], row["product"])) == row["attribute"]:
            row["is_primary_key"] = not row.get("is_primary_key", False)
        row["nullable"] = False
        row["classification"] = "confidential"
    for row in p:
        row["row_estimate"] = "1000"
    for row in d:
        row["classification"] = "internal"
    return d, p, a


def test_working_fields_model_json_does_not_store_are_not_out_of_scope_changes():
    fence, flat, log = _transient_fence()
    d, p, a = _toggle_transient(flat)
    issues = ah._vibe_scope_sa_issues(fence, d, p, a, log)
    assert not [i for i in issues if i["category"] == "vibe_scope_out_of_scope_change"], issues
    assert sum("[vibe-scope-transient-ignore FIRED v5.2.8]" in m for m in log.lines) == 1
    assert fence.restore_flat(d, p, a, None, "test") == 0


def test_a_real_frozen_change_is_still_an_out_of_scope_change():
    fence, flat, log = _transient_fence()
    d, p, a = _toggle_transient(flat)
    victim = next(r for r in a if r["domain"] != "crew")
    victim["description"] = "rewritten by a pass"
    issues = ah._vibe_scope_sa_issues(fence, d, p, a, log)
    found = [i for i in issues if i["category"] == "vibe_scope_out_of_scope_change"]
    assert found and f"{victim['domain']}.{victim['product']}.{victim['attribute']}" in found[0]["message"] and "description" in found[0]["message"]
    assert "is_primary_key" not in found[0]["message"] and "classification" not in found[0]["message"]
    toggled = next(r for r in a if r["domain"] != "crew" and r is not victim and r.get("classification") == "confidential")
    assert fence.restore_flat(d, p, a, None, "test") == 1
    base_desc = next(r for r in flat[2] if (r["domain"], r["product"], r["attribute"]) == (victim["domain"], victim["product"], victim["attribute"]))["description"]
    assert victim["description"] == base_desc and toggled["classification"] == "confidential"


def test_a_base_that_stores_is_primary_key_is_not_flagged_when_the_working_rows_drop_it():
    raw = __import__("json").loads((Path(__file__).resolve().parents[3] / "data-models" / "retail" / "v2" / "ecm" / "model.json").read_text())
    log = _Log()
    fence = ah.build_vibe_scope_fence(ah.parse_vibe_scope("Some Domains", raw["model"]["domains"][0]["name"]), copy.deepcopy(raw), "vibe modeling of version", log)
    d, p, a, _mv = ah.model_to_widgets_flat(copy.deepcopy(raw))
    for row in a:
        row.pop("is_primary_key", None)
    assert not [i for i in ah._vibe_scope_sa_issues(fence, d, p, a, log) if i["category"] == "vibe_scope_out_of_scope_change"]


NEXT_VIBES = """**Model Quality Score: 87/100**

**PRIORITY 1 \u2014 rename_product: campaign.ad** \u2014 rename to advert because the user vibe directive asks for it; verify the product is named advert
**PRIORITY 2 \u2014 rename_attribute: performance.tracking_pixel** \u2014 rename column ad_id to advert_id because it points at campaign.advert
"""


def test_next_vibes_drop_a_priority_for_a_rename_this_run_applied():
    ah.vov_ledger_reset()
    model = _model()
    assert ah._v337_apply_rename_product(model["model"], "campaign", "ad", "advert") is not None
    ah._vibe_scope_note_rename("product", "campaign.ad", "campaign.advert", "VREQ-0001")
    text, dropped = ah._vov_drop_landed_priorities(NEXT_VIBES, model)
    assert len(dropped) == 1 and "rename_product: campaign.ad" in dropped[0]
    assert "PRIORITY 1" not in text and "PRIORITY 2" in text and "Model Quality Score" in text
    ah.vov_ledger_reset()


def test_next_vibes_keep_a_rename_priority_that_did_not_land():
    ah.vov_ledger_reset()
    model = _model()
    text, dropped = ah._vov_drop_landed_priorities(NEXT_VIBES, model)
    assert dropped == [] and text == NEXT_VIBES
    ah._vibe_scope_note_rename("product", "campaign.ad", "campaign.advert", "VREQ-0001")
    assert ah._vov_drop_landed_priorities(NEXT_VIBES, model)[1] == [], "a recorded rename the model does not show has not landed"
    ah.vov_ledger_reset()
    renamed_earlier = _model()
    next(p for d in renamed_earlier["model"]["domains"] for p in d["products"] if p["name"] == "ad")["name"] = "advert"
    assert ah._vov_drop_landed_priorities(NEXT_VIBES, renamed_earlier)[1] == [], "a name that was already there is not this run's rename"


def test_next_vibes_drop_a_priority_that_restates_a_domain_rename_as_a_product_rename():
    ah.vov_ledger_reset()
    model = _model()
    assert ah._v337_apply_rename_domain(model["model"], "vendor", "partner") is not None
    text = ("**PRIORITY 1 \u2014 rename_product: vendor.publisher** \u2014 rename to partner because the user vibe directive renames the vendor domain to partner\n"
            "**PRIORITY 2 \u2014 connect_table: partner.publisher** \u2014 add column placement_id (BIGINT) with FK to media.placement.placement_id because publishers own placements\n")
    kept, dropped = ah._vov_drop_landed_priorities(text, model)
    assert len(dropped) == 1 and "vendor.publisher" in dropped[0]
    assert "PRIORITY 2" in kept and "PRIORITY 1" not in kept
    ah.vov_ledger_reset()
