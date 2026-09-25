"""Behavioral tests: installer accepts a model.json volume path for local_install.

User request: "allow it to deploy from volume path when user passes the model.json;
use it to figure out where the ddl folder is and deploy it." The installer's runnable
DDL lives in a sibling `schemas/` folder next to model.json (the agent writes both under
.../business/<biz>/v<N>/<mvm|ecm>/), so pointing local_install at the model.json file
must resolve to the folder that CONTAINS it.

These exec the SHIPPED config cell (so the test binds to what ships) and fail on
pre-patch HEAD, where _local_install_dir does not exist.
"""
import os

from installer_harness import find_cell


def _load_config_cell():
    calls = {"log": []}
    ns = {
        "__name__": "installer_config_cell",
        "log": lambda m: calls["log"].append(str(m)),
    }
    exec(compile(find_cell("def _resolve_local_base"), "<config-cell>", "exec"), ns)
    return ns, calls


def test_local_install_dir_maps_modeljson_to_folder():
    ns, _ = _load_config_cell()
    f = ns["_local_install_dir"]
    base = "/Volumes/cat/_metamodel/vol_root/business/acme/v1/mvm"
    assert f(base + "/model.json") == base
    # any *.json filename, not just model.json
    assert f(base + "/acme_v1.json") == base
    # trailing slash tolerated
    assert f(base + "/model.json/") == base


def test_local_install_dir_passthrough_folder_and_empty():
    ns, _ = _load_config_cell()
    f = ns["_local_install_dir"]
    folder = "/Volumes/cat/_metamodel/vol_root/business/acme/v1/mvm"
    assert f(folder) == folder
    assert f("") == ""
    assert f(None) == ""


def test_resolve_local_base_from_modeljson_path(tmp_path):
    ns, calls = _load_config_cell()
    model_dir = tmp_path / "business" / "acme" / "v1" / "mvm"
    (model_dir / "schemas").mkdir(parents=True)
    (model_dir / "schemas" / "acme_catalogs_v1_mvm.sql").write_text("CREATE CATALOG acme;")
    (model_dir / "model.json").write_text('{"model": {}}')

    # Simulate resolve_config having normalized a model.json path to its folder.
    cfg = {
        "local_install_raw": str(model_dir / "model.json"),
        "local_install": ns["_local_install_dir"](str(model_dir / "model.json")),
        "model_size": "mvm",
    }
    base = ns["_resolve_local_base"](cfg)
    assert base == str(model_dir)
    assert any("installer-local-modeljson-path FIRED" in line for line in calls["log"]), (
        "FIRED marker must be logged when a model.json file path was normalized to a folder"
    )


def test_resolve_local_base_folder_input_no_fired(tmp_path):
    ns, calls = _load_config_cell()
    model_dir = tmp_path / "acme_mvm"
    (model_dir / "schemas").mkdir(parents=True)
    (model_dir / "schemas" / "x.sql").write_text("CREATE CATALOG acme;")

    cfg = {
        "local_install_raw": str(model_dir),  # folder in == folder out
        "local_install": str(model_dir),
        "model_size": "mvm",
    }
    base = ns["_resolve_local_base"](cfg)
    assert base == str(model_dir)
    assert not any("installer-local-modeljson-path FIRED" in line for line in calls["log"]), (
        "FIRED marker must NOT fire for a plain folder input"
    )


def test_resolve_local_base_parent_of_scope_folder(tmp_path):
    # local_install pointed at the version folder (parent of mvm/): resolver appends model_size.
    ns, _ = _load_config_cell()
    version_dir = tmp_path / "v1"
    (version_dir / "mvm" / "schemas").mkdir(parents=True)
    (version_dir / "mvm" / "schemas" / "x.sql").write_text("CREATE CATALOG acme;")
    cfg = {"local_install": str(version_dir), "model_size": "mvm"}
    assert ns["_resolve_local_base"](cfg) == str(version_dir / "mvm")
