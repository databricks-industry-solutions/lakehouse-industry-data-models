"""After a structurally clean install, model.json is copied to the agent's canonical
volume path, `/Volumes/<catalog>/_metamodel/vol_root/business/<business>/v<N>/<scope>/
model.json` (business from model_requirements.business_name, N from model.version, scope
from the scope folder), creating the schema and volume when missing. The installer writes
no `_metamodel` table rows: the agent's registrar is their only writer.
"""
import json

import pytest

from installer_harness import (FakeFiles, FakeMetastore, FakeRegistry, agent_sanitize_name,
                               load_handoff, load_uninstall, redirect_volumes, run_main_cell,
                               uninstall_config)

CANONICAL = "/Volumes/demo/_metamodel/vol_root/business/acme_corp/v2/mvm/model.json"
DOC = {"agent_version": "5.1.4", "model_requirements": {"business_name": "Acme Corp"},
       "model": {"version": "v2_mvm", "domains": []}}


def _folder(tmp_path, doc=DOC, name="mvm", text=None):
    folder = tmp_path / "business" / "acme" / "v2" / name
    (folder / "schemas").mkdir(parents=True)
    (folder / "model.json").write_text(text if text is not None else json.dumps(doc))
    return folder


def _local_cfg(folder, raw=None, model_size="ecm"):
    return {"local_install": str(folder), "local_install_raw": str(raw or folder),
            "model_base": str(folder), "model_size": model_size, "catalog": "demo"}


def _model(**overrides):
    model = {"source": "/Volumes/src/_metamodel/vol_root/business/acme_corp/v2/mvm/model.json",
             "path": "/Volumes/src/_metamodel/vol_root/business/acme_corp/v2/mvm/model.json",
             "bytes": b'{"model": {"version": "v2_mvm"}}', "vibe_scope": None,
             "business": "Acme Corp", "version": 2, "scope": "mvm"}
    model.update(overrides)
    return model


def _register(model, schemas=None, files=None, fail_on=()):
    spark = FakeRegistry(schemas or {"demo": {"crew", "_install"}}, fail_on=fail_on)
    files = files if files is not None else FakeFiles()
    ns = load_handoff(spark, files=files)
    cfg = {"catalog": "demo"}
    reg = ns["register_model_json"](cfg, model)
    return reg, cfg, spark, files, ns


# ------------------------------------------------------------------ reading model.json

def test_the_model_json_beside_schemas_is_read_with_the_agents_identity(tmp_path):
    folder = _folder(tmp_path)
    ns = load_handoff(FakeRegistry({}))
    model = ns["load_model_json"](_local_cfg(folder))
    assert (model["business"], model["version"], model["scope"]) == ("Acme Corp", 2, "mvm")
    assert model["bytes"] == (folder / "model.json").read_bytes()
    assert model["path"] == str(folder / "model.json") and model["vibe_scope"] is None


def test_the_json_file_the_operator_pointed_at_is_the_one_read(tmp_path):
    folder = _folder(tmp_path)
    picked = folder / "acme_v2.json"
    picked.write_text(json.dumps(dict(DOC, _vibe_scope={"base_version": "1"})))
    ns = load_handoff(FakeRegistry({}))
    model = ns["load_model_json"](_local_cfg(folder, raw=picked))
    assert model["path"] == str(picked)
    assert model["vibe_scope"] == {"base_version": "1"}


def test_the_scope_comes_from_the_folder_then_model_version_then_the_size_widget(tmp_path):
    ns = load_handoff(FakeRegistry({}))
    exported = _folder(tmp_path / "a", dict(DOC, model={"version": "v3_ecm"}), name="export")
    assert ns["load_model_json"](_local_cfg(exported, model_size="mvm"))["scope"] == "ecm"
    numbered = _folder(tmp_path / "b", dict(DOC, model={"version": 2}), name="export")
    model = ns["load_model_json"](_local_cfg(numbered, model_size="mvm"))
    assert (model["scope"], model["version"]) == ("mvm", 2)


def test_a_folder_without_model_json_skips_the_hand_off(tmp_path):
    folder = tmp_path / "plain"
    (folder / "schemas").mkdir(parents=True)
    ns = load_handoff(FakeRegistry({}))
    assert ns["load_model_json"](_local_cfg(folder)) is None
    assert any("No model.json" in line for line in ns["_log_lines"])


@pytest.mark.parametrize("text,match", [("{not json", "not valid JSON"),
                                        ("[1, 2]", "not a JSON object")])
def test_an_unreadable_model_json_stops_before_any_ddl(tmp_path, text, match):
    folder = _folder(tmp_path, text=text)
    ns = load_handoff(FakeRegistry({}))
    with pytest.raises(Exception, match=match):
        ns["load_model_json"](_local_cfg(folder))


def test_a_repo_install_downloads_the_model_json_next_to_schemas():
    url = "https://raw.githubusercontent.com/o/r/main/data-models/acme/v2/mvm/model.json"
    ns = load_handoff(FakeRegistry({}))
    ns["_gh_contents"] = lambda cfg, path: [
        {"type": "dir", "name": "schemas"},
        {"type": "file", "name": "model.json", "download_url": url}]
    ns["_http_get"] = lambda u, token="": json.dumps(DOC) if u == url else None
    cfg = {"local_install": "", "model_base": "data-models/acme/v2/mvm", "model_size": "ecm",
           "github_token": ""}
    model = ns["load_model_json"](cfg)
    assert (model["source"], model["path"], model["scope"]) == (url, None, "mvm")
    assert json.loads(model["bytes"]) == DOC


def test_a_repo_folder_without_model_json_skips_the_hand_off():
    ns = load_handoff(FakeRegistry({}))
    ns["_gh_contents"] = lambda cfg, path: [{"type": "dir", "name": "schemas"}]
    assert ns["load_model_json"]({"local_install": "", "model_base": "x/v1/mvm",
                                  "model_size": "mvm", "github_token": ""}) is None


# ------------------------------------------------------------------ the copy

def test_the_model_json_lands_at_the_agents_canonical_path():
    reg, cfg, spark, files, ns = _register(_model())
    assert files.store[CANONICAL] == _model()["bytes"]
    assert ("create_directory", CANONICAL.rsplit("/", 1)[0]) in files.calls
    assert ("upload", CANONICAL, True) in files.calls
    assert "CREATE SCHEMA IF NOT EXISTS `demo`.`_metamodel`" in spark.queries
    assert "CREATE VOLUME IF NOT EXISTS `demo`.`_metamodel`.`vol_root`" in spark.queries
    assert cfg["model_registration"] is reg
    assert (reg["path"], reg["copied"], reg["metamodel_schema_created"]) == (CANONICAL, True, True)
    assert (reg["business"], reg["version"], reg["scope"]) == ("Acme Corp", 2, "mvm")
    assert reg["installer_files"] == [CANONICAL]
    assert any("[installer-metamodel-register FIRED]" in line for line in ns["_log_lines"])


def test_the_installer_writes_no_metamodel_rows():
    _, _, spark, _, _ = _register(_model())
    writes = [q for q in spark.queries
              if q.split(" ", 1)[0] in ("INSERT", "MERGE", "UPDATE", "DELETE")]
    assert writes == [], "the agent's registrar is the only writer of _metamodel rows"


def test_an_existing_metamodel_schema_is_not_recorded_as_created():
    reg = _register(_model(), schemas={"demo": {"crew", "_metamodel"}})[0]
    assert reg["metamodel_schema_created"] is False and reg["copied"] is True


@pytest.mark.parametrize("name", ["Acme Corp", "acme_corp", "  ACME   Corp!  ", "7-Eleven",
                                  "Health Insurance", "health_insurance", "NGO", "O'Hare Air",
                                  "Caf\u00e9 Co"])
def test_the_business_folder_is_the_one_the_agent_names(name):
    ns = load_handoff(FakeRegistry({}))
    assert ns["_metamodel_business_folder"](name) == agent_sanitize_name()(
        name, strip_stop_words=False)


def test_a_model_json_already_at_the_canonical_path_is_left_alone():
    reg, _, _, files, ns = _register(_model(path=CANONICAL, source=CANONICAL))
    assert files.calls == [] and reg["copied"] is True
    assert any("already at the agent's canonical path" in line for line in ns["_log_lines"])


def test_an_identical_model_json_is_not_uploaded_again():
    reg, _, _, files, _ = _register(_model(), files=FakeFiles({CANONICAL: _model()["bytes"]}))
    assert not [c for c in files.calls if c[0] == "upload"] and reg["copied"] is True


def test_a_different_model_json_the_installer_did_not_write_is_never_overwritten():
    files = FakeFiles({CANONICAL: b'{"the": "agent wrote this"}'})
    reg, _, _, files, ns = _register(_model(), files=files)
    assert files.store[CANONICAL] == b'{"the": "agent wrote this"}'
    assert (reg["copied"], reg.get("conflict"), reg["installer_files"]) == (False, True, [])
    assert any(line.startswith("Left %s in place" % CANONICAL) for line in ns["_log_lines"])


def _prior_manifest(monkeypatch, tmp_path, **registration):
    to_real = redirect_volumes(monkeypatch, tmp_path)
    manifest = to_real("/Volumes/demo/_install/logs/manifest_acme_mvm.json")
    manifest.parent.mkdir(parents=True)
    manifest.write_text(json.dumps({"model_registration": dict(
        {"metamodel_catalog": "demo", "installer_files": [CANONICAL]}, **registration)}))


def test_the_installers_own_earlier_copy_is_refreshed(tmp_path, monkeypatch):
    _prior_manifest(monkeypatch, tmp_path)
    files = FakeFiles({CANONICAL: b'{"older": "installer copy"}'})
    reg, _, _, files, _ = _register(_model(), files=files)
    assert files.store[CANONICAL] == _model()["bytes"] and reg["copied"] is True
    assert reg["installer_files"] == [CANONICAL]


def test_every_file_the_installer_wrote_in_the_catalog_stays_recorded(tmp_path, monkeypatch):
    v1 = CANONICAL.replace("/v2/", "/v1/")
    _prior_manifest(monkeypatch, tmp_path, installer_files=[v1])
    reg = _register(_model())[0]
    assert reg["installer_files"] == sorted([v1, CANONICAL])


def test_a_reinstall_keeps_the_metamodel_schema_recorded_as_created(tmp_path, monkeypatch):
    _prior_manifest(monkeypatch, tmp_path, metamodel_schema_created=True)
    reg = _register(_model(), schemas={"demo": {"crew", "_metamodel"}})[0]
    assert reg["metamodel_schema_created"] is True


def test_a_registration_for_another_metamodel_catalog_is_ignored(tmp_path, monkeypatch):
    _prior_manifest(monkeypatch, tmp_path, metamodel_catalog="elsewhere",
                    metamodel_schema_created=True)
    files = FakeFiles({CANONICAL: b'{"the": "agent wrote this"}'})
    reg = _register(_model(), schemas={"demo": {"crew", "_metamodel"}}, files=files)[0]
    assert reg["metamodel_schema_created"] is False and reg.get("conflict") is True
    assert reg["installer_files"] == []


def test_an_upload_that_does_not_read_back_is_reported_not_hidden():
    reg, cfg, _, _, ns = _register(_model(), files=FakeFiles(reported_size=3))
    assert reg["copied"] is False and "the volume reports 3 bytes" in reg["error"]
    assert cfg["model_registration"] is reg
    assert reg["installer_files"] == [CANONICAL], "a file we wrote stays ours to replace later"
    assert any(line.startswith("Could not hand model.json to the agent") for line in
               ns["_log_lines"])


def test_a_failed_schema_create_is_reported_and_not_recorded_as_created():
    reg = _register(_model(), fail_on=["CREATE SCHEMA"])[0]
    assert reg["metamodel_schema_created"] is False and "simulated failure" in reg["error"]


@pytest.mark.parametrize("overrides", [{"business": ""}, {"business": "!!!"}, {"version": None}])
def test_a_model_json_without_business_or_version_is_not_handed_off(overrides):
    reg, cfg, spark, files, _ = _register(_model(**overrides))
    assert reg is None and "model_registration" not in cfg
    assert spark.queries == [] and files.calls == []


def test_nothing_is_handed_off_without_a_model_json():
    reg, cfg, spark, _, _ = _register(None)
    assert reg is None and spark.queries == []


# ------------------------------------------------------------------ wiring in main()

def test_main_hands_off_after_a_clean_install_and_before_the_manifest():
    calls = {}
    run_main_cell({"enabled": False, "rows": 10}, calls=calls)
    order = calls["order"]
    assert order.index("install") < order.index("register_model_json") \
        < order.index("write_install_manifest")


def test_main_hands_off_when_only_metric_views_failed():
    calls = {}
    run_main_cell({"enabled": False, "rows": 10}, [("metric", "CREATE VIEW v", "bad")], calls)
    assert "register_model_json" in calls["order"]


def test_main_does_not_hand_off_a_structurally_failed_install():
    calls = {}
    with pytest.raises(Exception, match="Install FAILED"):
        run_main_cell({"enabled": False, "rows": 10}, [("fk", "ALTER TABLE t", "boom")], calls)
    assert "register_model_json" not in calls["order"]


# ------------------------------------------------------------------ manifest + uninstall

REG_PATH = "/Volumes/bank_cat/_metamodel/vol_root/business/acme_corp/v2/mvm/model.json"
REG = {"business": "Acme Corp", "version": 2, "scope": "mvm", "metamodel_catalog": "bank_cat",
       "path": REG_PATH, "metamodel_schema_created": True, "installer_files": [REG_PATH],
       "vibe_scope": False, "copied": True}


def test_the_install_manifest_records_the_hand_off():
    ns = load_uninstall(FakeMetastore({}))
    cfg = uninstall_config(catalog="c", target_catalogs=["c"], model_registration=REG)
    assert ns["write_install_manifest"](cfg, {"schema": []}, set())["model_registration"] == REG
    plain = uninstall_config(catalog="c", target_catalogs=["c"])
    assert "model_registration" not in ns["write_install_manifest"](plain, {"schema": []}, set())


def test_a_reinstall_that_skips_the_hand_off_keeps_the_earlier_registration():
    ns = load_uninstall(FakeMetastore({}), manifest={"model_registration": REG})
    cfg = uninstall_config(catalog="c", target_catalogs=["c"])
    assert ns["write_install_manifest"](cfg, {"schema": []}, set())["model_registration"] == REG
    newer = dict(REG, version=3)
    cfg["model_registration"] = newer
    assert ns["write_install_manifest"](cfg, {"schema": []}, set())["model_registration"] == newer


def _uninstall_manifest(**reg_overrides):
    return {"industry": "banking", "model_size": "mvm", "catalog": "bank_cat",
            "catalogs": [{"name": "bank_cat", "created_by_installer": True}],
            "schemas": [["bank_cat", "customer"], ["bank_cat", "_metrics"]],
            "model_registration": dict(REG, **reg_overrides)}


def _place_handoff(monkeypatch, tmp_path, extra=()):
    to_real = redirect_volumes(monkeypatch, tmp_path)
    for path in (REG["path"],) + tuple(extra):
        to_real(path).parent.mkdir(parents=True, exist_ok=True)
        to_real(path).write_text("{}")


def test_uninstall_drops_the_metamodel_schema_it_created_and_nothing_else_used(tmp_path,
                                                                               monkeypatch):
    _place_handoff(monkeypatch, tmp_path)
    spark = FakeRegistry({"bank_cat": {"customer", "_metrics", "_install", "_metamodel"}})
    ns = load_uninstall(spark, manifest=_uninstall_manifest())
    failures, _ = ns["uninstall"](uninstall_config())
    assert failures == []
    assert "bank_cat" not in spark.schemas, "an installer-made catalog must still drop cleanly"
    assert any("[installer-uninstall-metamodel FIRED]" in line for line in ns["_log_lines"])


def test_uninstall_drops_a_metamodel_schema_holding_every_copy_the_installer_wrote(tmp_path,
                                                                                    monkeypatch):
    v1 = REG_PATH.replace("/v2/", "/v1/")
    _place_handoff(monkeypatch, tmp_path, extra=(v1,))
    spark = FakeRegistry({"bank_cat": {"customer", "_metrics", "_install", "_metamodel"}})
    ns = load_uninstall(spark, manifest=_uninstall_manifest(installer_files=[v1, REG_PATH]))
    failures, _ = ns["uninstall"](uninstall_config())
    assert failures == [] and "bank_cat" not in spark.schemas


def test_uninstall_keeps_a_metamodel_schema_the_agent_has_written_to(tmp_path, monkeypatch):
    _place_handoff(monkeypatch, tmp_path)
    spark = FakeRegistry({"bank_cat": {"customer", "_metrics", "_install", "_metamodel"}},
                         tables=["business", "domain"])
    ns = load_uninstall(spark, manifest=_uninstall_manifest())
    failures, _ = ns["uninstall"](uninstall_config())
    assert "_metamodel" in spark.schemas["bank_cat"]
    assert [f for f in failures if f[0] == "drop-catalog" and "_metamodel" in f[2]]


def test_uninstall_keeps_a_metamodel_schema_holding_other_files(tmp_path, monkeypatch):
    other = "/Volumes/bank_cat/_metamodel/vol_root/business/acme_corp/v3/mvm/model.json"
    _place_handoff(monkeypatch, tmp_path, extra=(other,))
    spark = FakeRegistry({"bank_cat": {"customer", "_metrics", "_install", "_metamodel"}})
    ns = load_uninstall(spark, manifest=_uninstall_manifest())
    ns["uninstall"](uninstall_config())
    assert "_metamodel" in spark.schemas["bank_cat"]
    assert any("1 other file(s)" in line for line in ns["_log_lines"])


def test_uninstall_keeps_a_metamodel_schema_that_existed_before_the_install(tmp_path,
                                                                            monkeypatch):
    _place_handoff(monkeypatch, tmp_path)
    spark = FakeRegistry({"bank_cat": {"customer", "_metrics", "_install", "_metamodel"}})
    ns = load_uninstall(spark, manifest=_uninstall_manifest(metamodel_schema_created=False))
    ns["uninstall"](uninstall_config())
    assert "_metamodel" in spark.schemas["bank_cat"]
    assert not any("DROP SCHEMA IF EXISTS `bank_cat`.`_metamodel`" in q for q in spark.queries)
