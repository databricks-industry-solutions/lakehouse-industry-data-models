"""v5.1.4 feedback F1: one metamodel registrar, VOV/shrink/enlarge bootstrap, registry catalog."""
import ast
import copy
import json
import re
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


def _business_rows(fake, catalog):
    return fake.rows.get(f"{catalog}._metamodel.business", [])


def test_registrar_creates_the_registry_before_inserting():
    fake = fu.FakeSpark()
    result = fu.register(fake, "mm_cat", model=fu.small_model()).last_result
    first_insert = fake.first_index("INSERT INTO")
    assert fake.first_index("CREATE SCHEMA IF NOT EXISTS `mm_cat`.`_metamodel`") is not None
    for table in ("business", "domain", "product", "attribute"):
        create = next(i for i, s in enumerate(fake.statements) if s.startswith(f"CREATE TABLE IF NOT EXISTS `mm_cat`.`_metamodel`.`{table}`"))
        assert create < first_insert
    assert (result["success"], result["domain_count"], result["product_count"], result["attribute_count"]) == (True, 2, 3, 6)
    assert len(fake.inserted("._metamodel.domain")) == 2
    assert len(fake.inserted("._metamodel.product")) == 3
    assert len(fake.inserted("._metamodel.attribute")) == 6


def test_registry_ddl_reuses_the_shared_type_mapping():
    fake = fu.register(fu.FakeSpark(), "mm_cat", model=fu.small_model())
    ddl = next(s for s in fake.statements if s.startswith("CREATE TABLE IF NOT EXISTS `mm_cat`.`_metamodel`.`business`"))
    assert "`completed_percent` DOUBLE" in ddl and "`session_id` BIGINT" in ddl and "`completion_date` TIMESTAMP" in ddl
    assert "`business` STRING" in ddl
    setup = slice_function_source("step_setup_and_clean")
    assert "def create_table_sql" not in setup and "_ensure_metamodel_registry(spark, metamodel_catalog, logger)" in setup


def test_registrar_writes_a_complete_business_row_with_deploy_status():
    fake = fu.register(fu.FakeSpark(), "mm_cat", model=fu.small_model(), install_catalog="inst_cat", deploy_status="dry_run")
    [row] = _business_rows(fake, "mm_cat")
    assert (row["business"], row["version"], row["model_scope"], row["catalog"]) == ("Airlines", "1", "mvm", "inst_cat")
    assert row["completed_percent"] == 100.0 and row["processing_status"] == "done"
    assert row["deploy_status"] == "dry_run"
    assert "deploy_status" in fake.tables["mm_cat._metamodel.business"]


def test_registrar_stores_conventions_as_json_that_setup_can_read_back(monkeypatch):
    fake = fu.register(fu.FakeSpark(), "mm_cat", model=fu.small_model())
    [row] = _business_rows(fake, "mm_cat")
    assert json.loads(row["model_conventions"]) == fu.small_model()["model"]["model_conventions"]
    monkeypatch.setitem(ah.__dict__, "execute_sql", fu.execute_sql_via(fake))
    loaded = ah.load_previous_version_conventions(fake, "mm_cat._metamodel.business", "Airlines", "1", None, "mvm")
    assert loaded.get("tag_prefix") == "dbx_" and loaded.get("primary_key_suffix") == "_id"


def test_registrar_round_trips_quotes_and_backslashes():
    model = fu.small_model()
    tricky = "Customer's C:\\path with 'quotes' and \\n escapes"
    model["model"]["domains"][0]["products"][0]["description"] = tricky
    fake = fu.register(fu.FakeSpark(), "mm_cat", model=model)
    product = next(r for r in fake.inserted("._metamodel.product") if r["product"] == "customer")
    assert product["description"] == tricky


def test_registrar_replaces_a_version_instead_of_duplicating_it():
    fake = fu.FakeSpark()
    fu.register(fake, "mm_cat", model=fu.small_model())
    fu.register(fake, "mm_cat", model=fu.small_model())
    assert len(_business_rows(fake, "mm_cat")) == 1
    assert len(fake.inserted("._metamodel.product")) == 3
    assert len(fake.inserted("._metamodel.attribute")) == 6


def test_registrar_migrates_a_legacy_business_table():
    fake = fu.FakeSpark()
    legacy_cols = [c for c in ah.TABLE_BUSINESS_SCHEMA["properties"] if c not in {n for n, _ in ah._METAMODEL_BUSINESS_MIGRATION_COLUMNS}]
    fake.add_table("mm_cat._metamodel.business", legacy_cols + ["work_completed_percent"])
    fu.register(fake, "mm_cat", model=fu.small_model())
    added = [s for s in fake.statements if s.startswith("ALTER TABLE `mm_cat`.`_metamodel`.`business` ADD COLUMN")]
    assert [re.search(r"ADD COLUMN `(\w+)`", s).group(1) for s in added] == [n for n, _ in ah._METAMODEL_BUSINESS_MIGRATION_COLUMNS]
    assert any("SET completed_percent = CAST(REPLACE(work_completed_percent" in s for s in fake.statements)


def test_registrar_without_business_row_keeps_the_existing_row():
    fake = fu.register(fu.FakeSpark(), "mm_cat", model=fu.small_model())
    _business_rows(fake, "mm_cat")[0]["location"] = "/Volumes/keep/me"
    fake.statements.clear()
    result = ah._register_model_json_in_metamodel(fake, "mm_cat", fu.small_model()["model"], "Airlines", "1", "mvm", "/other",
                                                  business_row=False)
    assert result["success"]
    assert [r["location"] for r in _business_rows(fake, "mm_cat")] == ["/Volumes/keep/me"]
    assert not any("`_metamodel`.`business`" in s and not s.startswith("DESCRIBE") and not s.startswith("CREATE") for s in fake.statements)
    assert len(fake.inserted("._metamodel.product")) == 3


def test_registrar_reports_failed_batches():
    class _Failing(fu.FakeSpark):
        def sql(self, sql):
            if sql.startswith("INSERT INTO `mm_cat`.`_metamodel`.`attribute`"):
                raise RuntimeError("DELTA_CONCURRENT_WRITE boom")
            return super().sql(sql)

    result = fu.register(_Failing(), "mm_cat", model=fu.small_model()).last_result
    assert result["success"] is False and result["attribute_count"] == 0
    assert any(e.startswith("attribute batch 0") for e in result["errors"])


def test_registrar_rejects_an_unknown_deploy_status():
    with pytest.raises(ValueError, match="deploy_status must be one of"):
        fu.register(fu.FakeSpark(), "mm_cat", model=fu.small_model(), deploy_status="maybe")


def test_registrar_name_hooks_drive_the_physical_names():
    fake = fu.FakeSpark()
    ah._register_model_json_in_metamodel(
        fake, "mm_cat", fu.small_model()["model"], "Airlines", "1", "mvm", "/loc", catalog="inst_cat",
        names={"table": lambda p: "tbl_" + p["name"], "catalog": lambda d: "cat_" + d["name"]})
    assert {r["table_name"] for r in fake.inserted("._metamodel.product")} == {"tbl_customer", "tbl_invoice", "tbl_payment"}
    assert {r["catalog"] for r in fake.inserted("._metamodel.domain")} == {"cat_crm", "cat_billing"}


def _template(node):
    if isinstance(node, ast.Constant) and isinstance(node.value, str):
        return node.value
    if isinstance(node, ast.JoinedStr):
        return "".join(v.value if isinstance(v, ast.Constant) else "{" + ast.unparse(v.value) + "}" for v in node.values)
    return None


_RECORD_INSERT = re.compile(r"INSERT\s+INTO\s+\{[^}]+\}\.`?(\{[^}]+\}|domain\b|product\b|attribute\b)", re.IGNORECASE)


def test_exactly_one_function_inserts_metamodel_domain_product_attribute_rows():
    tree = ast.parse(notebook_concat_source())
    writers = []
    for top in tree.body:
        if not isinstance(top, (ast.FunctionDef, ast.AsyncFunctionDef, ast.ClassDef)):
            continue
        for node in ast.walk(top):
            text = _template(node)
            if text and _RECORD_INSERT.search(text):
                writers.append((top.name, text[:80]))
    assert [w[0] for w in writers] == ["_register_model_json_in_metamodel"], writers


def _calls_in(function_source, callee):
    tree = ast.parse(function_source)
    return [n for n in ast.walk(tree) if isinstance(n, ast.Call) and getattr(n.func, "id", None) == callee]


def test_volume_recovery_and_install_both_use_the_registrar():
    setup_tree = ast.parse(notebook_concat_source())
    setup = next(n for n in setup_tree.body if isinstance(n, ast.FunctionDef) and n.name == "step_setup_and_clean")
    recover = next(n for n in ast.walk(setup) if isinstance(n, ast.FunctionDef) and n.name == "_recover_model_data_from_volume")
    calls = [n for n in ast.walk(recover) if isinstance(n, ast.Call) and getattr(n.func, "id", None) == "_register_model_json_in_metamodel"]
    assert len(calls) == 1
    assert {k.arg: ast.unparse(k.value) for k in calls[0].keywords}.get("business_row") == "False"
    install_calls = _calls_in(fu.nested_main_function("_run_deploy_model"), "_register_model_json_in_metamodel")
    assert len(install_calls) == 1
    assert {k.arg: ast.unparse(k.value) for k in install_calls[0].keywords}.get("deploy_status") == "'installed'"


def _vov_setup_with_context(monkeypatch, fake, raw=None, model_version="1", **widget_kw):
    wv = fu.setup_widgets(fu.VOV, business_domains="", model_version=model_version, **widget_kw)
    wv["business_context_raw"] = copy.deepcopy(raw or fu.RAW)
    wv["business_context_file_path"] = fu.model_json_path(wv["deployment_catalog"], "airlines", "1", "mvm")
    fu.run_setup(monkeypatch, wv, fake)
    return wv


def test_vov_bootstraps_an_empty_registry_from_the_context_file(monkeypatch):
    fake = fu.FakeSpark()
    wv = _vov_setup_with_context(monkeypatch, fake)
    first_ddl = fake.first_index("CREATE")
    first_insert = fake.first_index("INSERT INTO")
    assert first_ddl is not None and first_insert is not None and first_ddl < first_insert
    assert len(fake.inserted("inst_cat._metamodel.domain")) == 15
    assert len(fake.inserted("inst_cat._metamodel.product")) == 205
    assert len(fake.inserted("inst_cat._metamodel.attribute")) == sum(len(p["attributes"]) for d in fu.RAW["model"]["domains"] for p in d["products"])
    [biz] = _business_rows(fake, "inst_cat")
    assert (biz["version"], biz["model_scope"], biz["completed_percent"], biz["deploy_status"]) == ("1", "mvm", 100.0, "dry_run")
    assert biz["location"] == "/Volumes/inst_cat/_metamodel/vol_root/business/airlines/v1/mvm"
    assert wv["base_version_for_review"] == "1" and wv["current_version"] == "2"
    notes = [s for s in wv["_vov_pending_sentinels"] if "[vov-metamodel-bootstrap FIRED v5.1.4]" in s]
    assert len(notes) == 1 and "15 domains / 205 products" in notes[0]


def test_vov_bootstrap_marks_the_base_installed_when_its_schemas_exist(monkeypatch):
    schema = fu.RAW["model"]["domains"][0].get("database_name") or ah.sanitize_name(fu.AIRLINES_DOMAINS[0])
    fake = fu.FakeSpark(schemata={"inst_cat": [schema]})
    _vov_setup_with_context(monkeypatch, fake)
    assert _business_rows(fake, "inst_cat")[0]["deploy_status"] == "installed"


def test_vov_bootstrap_writes_to_the_metamodel_catalog_override(monkeypatch):
    fake = fu.FakeSpark()
    wv = _vov_setup_with_context(monkeypatch, fake, metamodel_catalog="mm_cat")
    assert len(fake.inserted("mm_cat._metamodel.product")) == 205
    assert not fake.inserted("inst_cat._metamodel.product")
    assert _business_rows(fake, "mm_cat")[0]["catalog"] == "inst_cat"
    assert wv["metamodel_root_catalog"] == "mm_cat"


def test_vov_bootstrap_reads_the_volume_model_json_without_a_context_file(monkeypatch, tmp_path):
    volume = fu.VolumeRedirect(monkeypatch, tmp_path)
    volume.put(fu.model_json_path("inst_cat", "airlines", "1", "mvm"), fu.RAW)
    fake = fu.FakeSpark()
    wv = fu.setup_widgets(fu.VOV, business_domains="")
    fu.run_setup(monkeypatch, wv, fake)
    assert len(fake.inserted("inst_cat._metamodel.domain")) == 15
    assert len(fake.inserted("inst_cat._metamodel.product")) == 205
    assert wv["business_context_raw"]["model"]["domains"][0]["name"] == fu.AIRLINES_DOMAINS[0]
    assert wv["_preserve_v1_domains"] == fu.AIRLINES_DOMAINS


def test_vov_bootstrap_without_a_version_picks_the_newest_volume_version(monkeypatch, tmp_path):
    volume = fu.VolumeRedirect(monkeypatch, tmp_path)
    volume.put(fu.model_json_path("inst_cat", "airlines", "1", "mvm"), fu.small_model("v1_mvm"))
    volume.put(fu.model_json_path("inst_cat", "airlines", "3", "mvm"), fu.RAW)
    fake = fu.FakeSpark()
    wv = fu.setup_widgets(fu.VOV, business_domains="", model_version="")
    fu.run_setup(monkeypatch, wv, fake)
    assert [r["version"] for r in _business_rows(fake, "inst_cat")] == ["3"]
    assert wv["base_version_for_review"] == "3" and wv["current_version"] == "4"


def test_vov_bootstrap_refuses_a_model_json_of_the_other_scope(monkeypatch):
    raw = copy.deepcopy(fu.RAW)
    raw["model"]["version"] = "v1_ecm"
    with pytest.raises(ValueError, match="is a 'ecm' model"):
        _vov_setup_with_context(monkeypatch, fu.FakeSpark(), raw=raw)


def test_vov_without_any_model_json_still_fails_loudly(monkeypatch, tmp_path):
    fu.VolumeRedirect(monkeypatch, tmp_path)
    wv = fu.setup_widgets(fu.VOV, business_domains="")
    with pytest.raises(ValueError, match="does not exist"):
        fu.run_setup(monkeypatch, wv, fu.FakeSpark())
    assert any("nothing to register" in s or "no model.json was found" in s for s in wv.get("_vov_pending_sentinels", []))


def test_vov_with_a_registered_base_does_not_bootstrap(monkeypatch):
    fake = fu.register(fu.FakeSpark(), "inst_cat")
    inserts_before = len(fake.inserted("._metamodel.product"))
    wv = _vov_setup_with_context(monkeypatch, fake)
    assert len(fake.inserted("._metamodel.product")) == inserts_before
    assert not any("[vov-metamodel-bootstrap FIRED" in s for s in wv["_vov_pending_sentinels"])


@pytest.mark.parametrize("operation,source,target,label", [
    ("shrink ecm", "ecm", "mvm", "Expanded Coverage Model - ECM"),
    ("enlarge mvm", "mvm", "ecm", "Minimum Viable Model - MVM"),
])
def test_resize_bootstraps_the_source_scope(monkeypatch, operation, source, target, label):
    wv = fu.setup_widgets(operation, business_domains="", model_version="1")
    wv["data_model_scopes"] = label
    wv["business_context_raw"] = fu.small_model(f"v1_{source}")
    wv["business_context_file_path"] = fu.model_json_path("inst_cat", "airlines", "1", source)
    fake = fu.FakeSpark()
    fu.run_setup(monkeypatch, wv, fake)
    [biz] = _business_rows(fake, "inst_cat")
    assert (biz["version"], biz["model_scope"]) == ("1", source)
    assert {r["product"] for r in fake.inserted("._metamodel.product")} == {"customer", "invoice", "payment"}
    assert wv["source_version"] == "1" and wv["target_model_scope"] == target
    assert any("[vov-metamodel-bootstrap FIRED v5.1.4] registered Airlines v1" in s for s in wv["_vov_pending_sentinels"])


@pytest.mark.parametrize("name", ["_run_undeploy_model", "_run_resize_model"])
def test_uninstall_and_resize_read_the_registry_from_the_metamodel_catalog(name):
    src = fu.nested_main_function(name)
    assert "_mm_root = _metamodel_root_catalog_of(widgets_values, deployment_catalog)" in src
    assert 'metamodel_db = f"`{_mm_root}`.`_metamodel`"' in src
    assert "{deployment_catalog}`.`_metamodel`" not in src and "/Volumes/{deployment_catalog}/_metamodel" not in src
