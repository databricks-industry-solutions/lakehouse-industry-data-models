"""v5.1.4 feedback F3: deploy_status on consolidate, honest dry-run log, release notes that name removals, setup bugs."""
import copy
import json
import sys
from pathlib import Path

import pytest

sys.path.insert(0, str(Path(__file__).resolve().parent))
import v514_feedback_util as fu  # noqa: E402
from v514_feedback_util import ah  # noqa: E402
from notebook_source_util import notebook_concat_source, slice_function_source  # noqa: E402


@pytest.fixture(autouse=True)
def _isolate_runtime(monkeypatch):
    fu.inject_spark_types(monkeypatch)
    pinned = set(ah._USER_PINNED_DOMAINS_RUNTIME)
    yield
    ah.set_vibe_scope_runtime(None)
    ah._USER_PINNED_DOMAINS_RUNTIME.clear()
    ah._USER_PINNED_DOMAINS_RUNTIME.update(pinned)


class _DataFrame:
    def __init__(self):
        self.write = self

    def mode(self, *_a):
        return self

    def option(self, *_a):
        return self

    def saveAsTable(self, *_a):
        return None


class _VibeWriter:
    def emit_step(self, **_kw):
        return "step"


def _consolidate(monkeypatch, tmp_path, dry_run, initial_status, fail_on=()):
    model = fu.small_model("v2_mvm")
    d, p, a, _mv = ah.model_to_widgets_flat(model)
    files = {}
    for name, rows in (("DOMAINS", d), ("PRODUCTS", p), ("ATTRIBUTES", a)):
        path = tmp_path / f"{name.lower()}.json"
        path.write_text(json.dumps(rows))
        files[f"{name}_FILE_PATH"] = str(path)
    fake = fu.register(fu.FakeSpark(), "inst_cat", version="2", model=model, deploy_status=initial_status)
    fake.statements.clear()
    fake.fail_on = fail_on
    fake.createDataFrame = lambda data, schema=None: _DataFrame()
    for name in ("StructType", "StructField", "StringType"):
        monkeypatch.setitem(ah.__dict__, name, lambda *a, **k: None)
    monkeypatch.setitem(ah.__dict__, "execute_sql_in_parallel", lambda *a, **k: None)
    monkeypatch.setitem(ah.__dict__, "execute_sql", fu.execute_sql_via(fake))
    tables = {k: f"inst_cat._metamodel.{k.lower()}" for k in ("BUSINESS", "DOMAIN", "PRODUCT", "ATTRIBUTE")}
    config = dict(files, MAIN_METAMODEL_TABLES=tables, MODEL_SCOPE="mvm", METAMODEL_DB="inst_cat._metamodel", MAX_CONCURRENT_BATCHES=2)
    log = fu.RecordingLogger()
    wv = {"spark": fake, "logger": log, "config": config, "business_name": "Airlines", "current_version": "2",
          "operation": fu.NEW_BASE, "_dry_run": dry_run, "vibe_writer": _VibeWriter()}
    ah.step_consolidate_and_cleanup(wv)
    return fake, log


def test_dry_run_consolidation_registers_the_version_as_dry_run(monkeypatch, tmp_path):
    fake, log = _consolidate(monkeypatch, tmp_path, dry_run=True, initial_status="installed")
    [biz] = fake.rows["inst_cat._metamodel.business"]
    assert biz["deploy_status"] == "dry_run"
    assert "[dry-run-registry FIRED v5.1.4]" in log.text("info")
    assert ah._latest_installed_version(fake, "inst_cat", "Airlines", "mvm") is None


def test_installed_consolidation_marks_the_version_installed(monkeypatch, tmp_path):
    fake, log = _consolidate(monkeypatch, tmp_path, dry_run=False, initial_status="dry_run")
    [biz] = fake.rows["inst_cat._metamodel.business"]
    assert biz["deploy_status"] == "installed"
    assert any("SET deploy_status = 'installed'" in s for s in fake.statements)
    assert "[dry-run-registry FIRED" not in log.text()
    assert ah._latest_installed_version(fake, "inst_cat", "Airlines", "mvm") == "2"


def test_consolidation_survives_a_registry_that_rejects_deploy_status(monkeypatch, tmp_path):
    fake, log = _consolidate(monkeypatch, tmp_path, dry_run=True, initial_status="installed", fail_on=("SET deploy_status",))
    assert fake.rows["inst_cat._metamodel.business"][0]["deploy_status"] == "installed"
    assert "[deploy-status ERROR v5.1.4] could not set deploy_status='dry_run' for v2" in log.text("warning")


def test_the_dry_run_skip_log_no_longer_claims_the_registry_is_skipped():
    body = slice_function_source("step_create_physical_schema_stage1")
    line = next(l for l in body.splitlines() if "[dry-run-skip-physical FIRED]" in l)
    assert "metamodel registry insert" not in line
    assert "deploy_status='dry_run'" in line


def _release_notes(monkeypatch, wv):
    written = {}
    monkeypatch.setitem(ah.__dict__, "write_to_dbfs", lambda content, path, logger=None: written.update(content=content, path=path))
    ah.step_generate_release_notes(wv)
    return written.get("content", "")


def _rn_widgets(current_model, base_model, operation=fu.VOV, config_extra=None):
    d, p, a, _mv = ah.model_to_widgets_flat(current_model)
    config = {"TARGET_VOLUME": "/Volumes/x/v", "SANITIZED_BUSINESS_NAME": "airlines", "PROMPT_VARIABLES": {"business_config": {}}}
    config.update(config_extra or {})
    return {"spark": fu.FakeSpark(), "logger": fu.RecordingLogger(), "config": config, "business_name": "Airlines",
            "domains": list(d), "products": list(p), "attributes": list(a), "operation": operation,
            "current_version": "2", "base_version_for_review": "1", "model_scope": "mvm", "business_context_raw": base_model}


def _current_after_vov():
    model = copy.deepcopy(fu.small_model("v2_mvm"))
    billing = model["model"]["domains"][1]
    invoice = billing["products"].pop(0)
    billing["products"] = [p for p in billing["products"] if p["name"] != "payment"]
    billing["products"].append({"name": "refund", "table_name": "refund", "primary_key": "refund_id", "description": "A refund",
                                "attributes": [fu._attr("refund_id", "bigint", "primary_key")]})
    model["model"]["domains"][0]["products"].append(invoice)
    return model


def test_release_notes_name_removed_added_and_moved_products(monkeypatch):
    wv = _rn_widgets(_current_after_vov(), fu.small_model())
    content = _release_notes(monkeypatch, wv)
    flat = " ".join(line.strip("| ") for line in content.splitlines())
    assert "1 data product(s) removed: billing.payment" in flat
    assert "1 new data product(s) added: billing.refund" in flat
    assert "1 data product(s) moved to another domain: billing.invoice -> crm.invoice" in flat
    assert "Removed 1 product(s) - dependent tables will be dropped on deploy" in flat
    assert "No net new additions" not in flat
    assert "[release-notes-explicit-removals FIRED v5.1.4]" in wv["logger"].text("info")


def test_release_notes_report_a_pure_removal_as_a_removal(monkeypatch):
    current = copy.deepcopy(fu.small_model("v2_mvm"))
    current["model"]["domains"][1]["products"].pop()
    content = _release_notes(monkeypatch, _rn_widgets(current, fu.small_model()))
    flat = " ".join(line.strip("| ") for line in content.splitlines())
    assert "No new artifacts added (artifacts were removed, see WHAT WAS REMOVED)" in flat
    assert "1 data product(s) removed: billing.payment" in flat
    assert "No net new additions (model refinement only)" not in flat


def test_release_notes_outside_vov_still_use_the_count_delta(monkeypatch):
    current = copy.deepcopy(fu.small_model("v2_mvm"))
    current["model"]["domains"][1]["products"].pop()
    meta = {"_next_vibe_metadata": {"model_stats_at_generation": {"domain_count": 2, "product_count": 3, "attribute_count": 6, "fk_count": 2}}}
    wv = _rn_widgets(current, fu.small_model(), operation=fu.NEW_BASE, config_extra={"PROMPT_VARIABLES": dict(meta, business_config={})})
    content = _release_notes(monkeypatch, wv)
    flat = " ".join(line.strip("| ") for line in content.splitlines())
    assert "1 data product(s) removed" in flat and "billing.payment" not in flat
    assert "No new artifacts added (artifacts were removed, see WHAT WAS REMOVED)" in flat


def test_setup_logs_the_pinned_domain_cache_without_a_logger(monkeypatch, capsys):
    wv = fu.setup_widgets(fu.NEW_BASE, business_domains="crew, flight")
    fu.run_setup(monkeypatch, wv, fu.FakeSpark())
    assert any("[user-pinned-domains-runtime-populate FIRED]" in s for s in wv["_vov_pending_sentinels"])
    assert not any("[user-pinned-domains-runtime-populate ERROR]" in s for s in wv["_vov_pending_sentinels"])
    assert "[user-pinned-domains-runtime-populate FIRED]" in capsys.readouterr().out


def test_setup_applies_a_vibe_fk_suffix_after_config_exists(monkeypatch):
    wv = fu.setup_widgets(fu.NEW_BASE, vibes="Use FK suffix _ref for every foreign key")
    config = fu.run_setup(monkeypatch, wv, fu.FakeSpark())
    assert config["MODEL_CONVENTIONS"]["foreign_key_suffix"] == "_ref"


def test_get_widget_values_forwards_the_version_widget_to_install():
    assert 'widget_values["_model_version_widget"] = w_version' in fu.nested_main_function("get_widget_values")


def test_scoped_install_precondition_stays_out_of_ddl_generation():
    for name in ("_generate_ddl_from_enriched_json", "_run_physical_model_creation"):
        assert "_scoped_install_precondition" not in fu.nested_main_function(name)
    assert notebook_concat_source().count("_scoped_install_precondition(spark, _parsed_root") == 1
