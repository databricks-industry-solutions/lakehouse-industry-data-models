"""v5.1.4 feedback F1/F3: install op registry catalog + version widget, deploy_status, scoped-install precondition."""
import copy
import json
import sys
from pathlib import Path

import pytest

sys.path.insert(0, str(Path(__file__).resolve().parent))
import v514_feedback_util as fu  # noqa: E402
from v514_feedback_util import ah  # noqa: E402

_DEPLOY_SRC = fu.nested_main_function("_run_deploy_model")


@pytest.fixture(autouse=True)
def _spark_types(monkeypatch):
    fu.inject_spark_types(monkeypatch)


class _PhysicalStop(Exception):
    pass


class _SparkSession:
    def __init__(self, spark):
        self.builder = self
        self._spark = spark

    def getOrCreate(self):
        return self._spark


def _install(monkeypatch, tmp_path, raw, widget_overrides=None, fake=None, real_registrar=False):
    fake = fake or fu.FakeSpark()
    calls = {"ensure_registry": [], "vibe_writer": [], "registrar": [], "ensure_catalog": []}
    ns = dict(ah.__dict__)
    ns["logger"] = fu.RecordingLogger()
    ns["WorkspaceClient"] = lambda *a, **k: object()
    ns["SparkSession"] = _SparkSession(fake)
    model_folder = "/Volumes/src_cat/_metamodel/vol_root/business/airlines/v1/mvm"
    ns["_resolve_user_model_json_path"] = lambda folder, user_path, w: (f"{model_folder}/model.json", json.dumps(raw))
    ns["_ensure_catalog_exists"] = lambda spark, cat, logger=None: calls["ensure_catalog"].append(cat)
    real_ensure = ah._ensure_metamodel_registry

    def _ensure(spark, catalog, logger=None):
        calls["ensure_registry"].append(catalog)
        return real_ensure(spark, catalog, logger)

    ns["_ensure_metamodel_registry"] = _ensure
    ns["_create_standalone_vibe_writer"] = lambda spark, catalog, business, version, scope, operation=None: calls["vibe_writer"].append((catalog, business, version, scope)) or None

    def _registrar(*args, **kwargs):
        calls["registrar"].append((args, kwargs))
        if real_registrar:
            result = ah._register_model_json_in_metamodel(*args, **kwargs)
            calls["registered_rows"] = copy.deepcopy(fake.rows)
            return result
        return {"success": True, "metamodel_db": "x", "errors": [], "domain_count": 0, "product_count": 0, "attribute_count": 0}

    ns["_register_model_json_in_metamodel"] = _registrar

    def _clash(*_a, **_k):
        raise _PhysicalStop("stop before physical DDL")

    ns["_check_physical_deployment_clash"] = _clash
    exec(compile(_DEPLOY_SRC, "<_run_deploy_model>", "exec"), ns)
    wv = {"model_folder": model_folder, "deployment_catalog": "inst_cat", "metamodel_catalog": "", "cataloging_style": "one_catalog",
          "catalog_prefix": "", "catalog_suffix": "", "business_context_file_path": f"{model_folder}/model.json",
          "_widget_raw_values": {"business_name": "Airlines", "model_conventions": {}}, "_model_version_widget": "", "vibe_session_id": "t"}
    wv.update(widget_overrides or {})
    error = None
    try:
        ns["_run_deploy_model"](wv)
    except Exception as exc:
        error = exc
    return calls, error, fake, ns["logger"]


def test_install_registers_into_the_metamodel_catalog_override_with_the_widget_version(monkeypatch, tmp_path):
    calls, error, fake, _ = _install(monkeypatch, tmp_path, fu.small_model("v1_mvm"),
                                     {"metamodel_catalog": "mm_cat", "_model_version_widget": "3"})
    assert isinstance(error, ValueError) and "Physical model creation failed" in str(error)
    assert calls["ensure_registry"] == ["mm_cat"]
    assert "mm_cat" in calls["ensure_catalog"] and "inst_cat" in calls["ensure_catalog"]
    assert calls["vibe_writer"] == [("mm_cat", "Airlines", "3", "mvm")]
    [(args, kwargs)] = calls["registrar"]
    assert (args[1], args[3], args[4], args[5]) == ("mm_cat", "Airlines", "3", "mvm")
    assert kwargs["catalog"] == "inst_cat" and kwargs["deploy_status"] == "installed"


def test_install_without_override_keeps_the_installation_catalog_and_file_version(monkeypatch, tmp_path):
    calls, error, fake, _ = _install(monkeypatch, tmp_path, fu.small_model("v2_mvm"))
    assert calls["ensure_registry"] == ["inst_cat"]
    assert calls["vibe_writer"] == [("inst_cat", "Airlines", "2", "mvm")]
    [(args, kwargs)] = calls["registrar"]
    assert (args[1], args[4], kwargs["deploy_status"]) == ("inst_cat", "2", "installed")


def test_install_widget_version_with_scope_suffix_is_normalized(monkeypatch, tmp_path):
    calls, _error, _fake, _ = _install(monkeypatch, tmp_path, fu.small_model("v1_mvm"), {"_model_version_widget": "v4_mvm"})
    assert calls["vibe_writer"][0][2] == "4"


def test_install_writes_installed_rows_into_the_registry(monkeypatch, tmp_path):
    calls, error, fake, logger = _install(monkeypatch, tmp_path, fu.small_model("v1_mvm"), {"metamodel_catalog": "mm_cat"}, real_registrar=True)
    written = calls["registered_rows"]
    [biz] = written["mm_cat._metamodel.business"]
    assert (biz["version"], biz["deploy_status"], biz["catalog"]) == ("1", "installed", "inst_cat")
    assert {r["product"] for r in written["mm_cat._metamodel.product"]} == {"customer", "invoice", "payment"}
    assert "inst_cat._metamodel.business" not in written
    assert isinstance(error, ValueError) and "Physical model creation failed" in str(error)
    assert fake.rows["mm_cat._metamodel.business"] == [] and fake.rows["mm_cat._metamodel.product"] == [], \
        "a failed physical step leaves no installed version in the registry"


def _scoped(raw, base_version=2, base_scope="mvm", operation="vibe modeling of version"):
    raw = copy.deepcopy(raw)
    raw["_vibe_scope"] = {"mode": "domains", "label": "Some Domains", "entries": ["crm"], "operation": operation,
                          "base_version": None if base_version is None else str(base_version), "base_scope": base_scope,
                          "base_catalog": "inst_cat", "changed_in_scope_products": ["crm.customer"],
                          "preserved_products": ["billing.invoice", "billing.payment"], "permitted_deltas": [],
                          "serialize_gate": {"status": "passed", "violations": []}}
    return raw


def _existing_install(version, deploy_status="installed", schemas=("crm", "billing")):
    fake = fu.FakeSpark(schemata={"inst_cat": list(schemas)})
    fu.register(fake, "inst_cat", version=str(version), model=fu.small_model(), deploy_status=deploy_status)
    return fake


def test_scoped_install_over_a_different_installed_version_is_refused(monkeypatch, tmp_path):
    fake = _existing_install(1)
    calls, error, _fake, _ = _install(monkeypatch, tmp_path, _scoped(fu.small_model("v3_mvm"), base_version=2), fake=fake)
    assert isinstance(error, ValueError) and "Scoped install refused" in str(error)
    assert "v1 as its latest installed version" in str(error) and "base v2" in str(error)
    assert calls["registrar"] == []


def test_scoped_install_on_its_base_version_is_allowed(monkeypatch, tmp_path):
    fake = _existing_install(2)
    calls, error, _fake, _ = _install(monkeypatch, tmp_path, _scoped(fu.small_model("v3_mvm"), base_version=2), fake=fake)
    assert "Physical model creation failed" in str(error)
    assert len(calls["registrar"]) == 1


def test_scoped_install_into_a_fresh_catalog_is_allowed(monkeypatch, tmp_path):
    fake = fu.FakeSpark(schemata={"inst_cat": ["unrelated"]})
    calls, error, _fake, _ = _install(monkeypatch, tmp_path, _scoped(fu.small_model("v3_mvm"), base_version=2), fake=fake)
    assert "Physical model creation failed" in str(error)
    assert len(calls["registrar"]) == 1


def test_unscoped_install_skips_the_precondition(monkeypatch, tmp_path):
    fake = _existing_install(1)
    calls, error, _fake, _ = _install(monkeypatch, tmp_path, fu.small_model("v3_mvm"), fake=fake)
    assert "Physical model creation failed" in str(error)
    assert len(calls["registrar"]) == 1


def _resolver():
    return ah.CatalogResolver(style="one_catalog", base_catalog="inst_cat")


def test_precondition_ignores_dry_run_versions():
    fake = _existing_install(1)
    fu.register(fake, "inst_cat", version="2", model=fu.small_model(), deploy_status="dry_run")
    assert ah._latest_installed_version(fake, "inst_cat", "Airlines", "mvm", catalog="inst_cat") == "1"
    with pytest.raises(ValueError, match="Scoped install refused"):
        ah._scoped_install_precondition(fake, _scoped(fu.small_model()), fu.small_model()["model"], "inst_cat", "Airlines", "mvm", "inst_cat", _resolver())


def test_precondition_treats_legacy_null_deploy_status_as_installed():
    fake = _existing_install(2)
    for row in fake.rows["inst_cat._metamodel.business"]:
        row["deploy_status"] = None
    assert ah._scoped_install_precondition(fake, _scoped(fu.small_model()), fu.small_model()["model"], "inst_cat", "Airlines", "mvm", "inst_cat", _resolver()) == "base_match"


def test_precondition_reads_only_the_root_base_version_like_the_installer():
    fake = _existing_install(2)
    parsed = _scoped(fu.small_model(), base_version=None)
    parsed["_vibe_scope"]["stale_base"] = {"base_version": "2"}
    with pytest.raises(ValueError, match="an unrecorded base version"):
        ah._scoped_install_precondition(fake, parsed, fu.small_model()["model"], "inst_cat", "Airlines", "mvm", "inst_cat", _resolver())
    assert ah._scoped_install_precondition(fake, _scoped(fu.small_model()), fu.small_model()["model"], "inst_cat", "Airlines", "mvm", "inst_cat", _resolver()) == "base_match"


def test_precondition_looks_up_the_base_scope_from_the_block():
    fake = _existing_install(2)
    with pytest.raises(ValueError, match="Scoped install refused"):
        ah._scoped_install_precondition(fake, _scoped(fu.small_model(), base_scope="ecm"), fu.small_model()["model"], "inst_cat", "Airlines", "mvm", "inst_cat", _resolver())


def test_precondition_needs_no_base_for_a_scoped_new_base_model_like_the_installer():
    fake = _existing_install(1)
    parsed = _scoped(fu.small_model(), base_version=None, base_scope=None, operation="new base model")
    assert ah._scoped_install_precondition(fake, parsed, fu.small_model()["model"], "inst_cat", "Airlines", "mvm", "inst_cat", _resolver()) == "new_base"


def test_precondition_without_registry_and_schemas_is_fresh():
    fake = fu.FakeSpark()
    assert ah._latest_installed_version(fake, "inst_cat", "Airlines", "mvm") is None
    assert ah._scoped_install_precondition(fake, _scoped(fu.small_model()), fu.small_model()["model"], "inst_cat", "Airlines", "mvm", "inst_cat", _resolver()) == "fresh"


def test_model_schemas_present_lists_only_the_model_schemas():
    fake = fu.FakeSpark(schemata={"inst_cat": ["crm", "other"]})
    assert ah._model_schemas_present(fake, fu.small_model()["model"], _resolver()) == ["inst_cat.crm"]


def test_an_installer_manifest_counts_as_installed_like_the_installer(monkeypatch, tmp_path):
    import glob
    fake = _existing_install(1)
    fu.register(fake, "inst_cat", version="2", model=fu.small_model(), deploy_status="dry_run")
    manifest = tmp_path / "manifest_airlines_mvm.json"
    manifest.write_text(json.dumps({"model_registration": {"business": "Airlines", "version": 2, "scope": "mvm"}}))
    real_glob = glob.glob
    monkeypatch.setattr(glob, "glob", lambda pattern, *a, **k: [str(manifest)] if pattern == "/Volumes/inst_cat/_install/logs/manifest_*.json" else real_glob(pattern, *a, **k))
    assert ah._latest_installed_version(fake, "inst_cat", "Airlines", "mvm", catalog="inst_cat") == "2"
    assert ah._scoped_install_precondition(fake, _scoped(fu.small_model()), fu.small_model()["model"], "inst_cat", "Airlines", "mvm", "inst_cat", _resolver()) == "base_match"


def test_a_null_catalog_row_counts_only_in_a_co_located_registry():
    fake = _existing_install(2)
    for row in fake.rows["inst_cat._metamodel.business"]:
        row["catalog"] = None
    assert ah._latest_installed_version(fake, "inst_cat", "Airlines", "mvm", catalog="inst_cat") == "2"
    assert ah._latest_installed_version(fake, "inst_cat", "Airlines", "mvm", catalog="other_cat") is None


def test_precondition_skips_a_failed_run_that_registered_no_domains():
    fake = _existing_install(2)
    failed = dict(fake.rows["inst_cat._metamodel.business"][0], version="3", deploy_status=None)
    fake.rows["inst_cat._metamodel.business"].append(failed)
    log = fu.RecordingLogger()
    assert ah._latest_installed_version(fake, "inst_cat", "Airlines", "mvm", catalog="inst_cat", logger=log) == "2"
    assert "[registry-unregistered-skip FIRED v5.2.7] Airlines (mvm) versions ['3']" in log.text("warning")
    assert ah._scoped_install_precondition(fake, _scoped(fu.small_model()), fu.small_model()["model"], "inst_cat", "Airlines", "mvm", "inst_cat", _resolver()) == "base_match"
