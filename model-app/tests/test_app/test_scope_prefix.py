"""``services/scope_prefix`` and the import scope rule on the real agriculture model.

The agriculture fixture (``tests/fixtures/industry_agriculture_v1_trimmed.json``)
keeps every metric view's ``CREATE`` header and ``source:`` line verbatim
from lakehouse-industry-data-models ``data-models/agriculture/v1``: 97 ECM and
134 MVM views, ``CREATE OR REPLACE VIEW `agriculture_ecm`.`_metrics`.`<view>```,
``source: "`agriculture_ecm`.`<domain>`.`<table>`"``, blank schema prefix.
"""
from __future__ import annotations

import copy
import json
import re
from pathlib import Path

import pytest

from vibe_modeling.backend.import_model import ImportScopeError, import_scope, is_agent_output
from vibe_modeling.backend.services.scope_prefix import (
    apply_import_prefix,
    file_schema_prefix,
    import_schema_prefix,
    stamp_scope,
    strip_import_prefix,
    strip_import_prefix_sql,
)

FIXTURE = json.loads((Path(__file__).parent.parent / "fixtures" / "industry_agriculture_v1_trimmed.json").read_text())
COUNTS = {"ecm": 97, "mvm": 134}
_HEADER = re.compile(r"VIEW\s+`([^`]+)`\.`([^`]+)`\.`([^`]+)`")
_SOURCE = re.compile(r'source:\s*"`([^`]+)`\.`([^`]+)`\.`([^`]+)`"')


def _real(scope: str) -> dict:
    return copy.deepcopy(FIXTURE[scope])


@pytest.mark.parametrize("scope", ["ecm", "mvm"])
def test_the_real_model_gets_its_scope_prefix_everywhere(scope):
    root = _real(scope)
    prefix = import_schema_prefix(scope, file_schema_prefix(root))
    assert prefix == f"{scope}_"
    report = apply_import_prefix(root, scope, prefix)
    model = root["model"]
    names = {d["database_name"] for d in model["domains"]}
    assert all(n.startswith(f"{scope}_") and not n.startswith(f"{scope}_{scope}_") for n in names)
    assert len(model["metric_views"]) == COUNTS[scope]
    for view in model["metric_views"]:
        catalog, schema, name = _HEADER.search(view["sql"]).groups()
        assert (catalog, schema) == ("agriculture_ecm", "_metrics")
        assert name == view["view_name"] and name.startswith(f"{scope}_")
        sources = _SOURCE.findall(view["sql"])
        assert sources and all(c == "agriculture_ecm" and s in names for c, s, _ in sources)
    assert model["model_conventions"]["schema_prefix"] == f"{scope}_"
    assert root["model_requirements"]["model_conventions"]["schema_prefix"] == f"{scope}_"
    assert (report.schema_prefix_added, report.view_prefix_added) == (f"{scope}_", f"{scope}_")
    assert len(report.views) == COUNTS[scope] and report.warnings == []


@pytest.mark.parametrize("scope", ["ecm", "mvm"])
def test_apply_is_idempotent_and_strip_reverses_it(scope):
    original = _real(scope)
    root = copy.deepcopy(original)
    report = apply_import_prefix(root, scope, f"{scope}_")
    once = copy.deepcopy(root)
    again = apply_import_prefix(root, scope, f"{scope}_")
    assert root == once
    assert again.views == {}
    assert strip_import_prefix(root, report.schema_prefix_added, report.view_prefix_added) == original


def test_a_file_prefix_is_kept_and_survives_the_round_trip():
    original = _real("mvm")
    for holder in (original["model"], original["model_requirements"]):
        holder["model_conventions"]["schema_prefix"] = "farm_"
    for domain in original["model"]["domains"]:
        domain["database_name"] = f"farm_{domain['database_name']}"
    root = copy.deepcopy(original)
    assert import_schema_prefix("mvm", file_schema_prefix(root)) is None
    report = apply_import_prefix(root, "mvm", None)
    assert {d["database_name"] for d in root["model"]["domains"]} == {
        d["database_name"] for d in original["model"]["domains"]
    }
    assert all(v["view_name"].startswith("mvm_") for v in root["model"]["metric_views"])
    assert report.schema_prefix_added == "" and report.view_prefix_added == "mvm_"
    assert strip_import_prefix(root, report.schema_prefix_added, report.view_prefix_added) == original


def _small(conventions) -> dict:
    return {
        "model_requirements": {"model_conventions": json.dumps({"schema_prefix": ""})},
        "model": {
            "version": "v1_ecm",
            "model_conventions": conventions,
            "domains": [
                {"name": "crop", "database_name": "crop"},
                {"name": "land", "database_name": "land_wt"},
                {"name": "Cover Crop", "database_name": ""},
            ],
            "metric_views": [
                {"view_name": "crop_yield", "sql": (
                    "CREATE OR REPLACE VIEW `agriculture_ecm`.`_metrics`.`crop_yield`\nWITH METRICS\nAS $$\n"
                    '  source: "`agriculture_ecm`.`crop`.`field`"\n'
                    "  joins:\n  - name: parcel\n    source: agriculture_ecm.land_wt.parcel\n"
                    "    'on': source.parcel_id = parcel.parcel_id\n$$"
                )},
                {"view_name": "elsewhere", "sql": (
                    "CREATE VIEW agriculture_ecm._metrics.elsewhere AS $$\n"
                    '  source: "`agriculture_ecm`.`finance`.`ledger`"\n$$'
                )},
            ],
        },
    }


def test_json_string_conventions_suffixes_joins_bare_names_and_a_foreign_schema(caplog):
    root = _small(json.dumps({"schema_prefix": "", "tag_prefix": "dbx_"}))
    with caplog.at_level("WARNING"):
        report = apply_import_prefix(root, "ecm", "ecm_")
    model = root["model"]
    assert json.loads(model["model_conventions"]) == {"schema_prefix": "ecm_", "tag_prefix": "dbx_"}
    assert json.loads(root["model_requirements"]["model_conventions"])["schema_prefix"] == "ecm_"
    assert [d["database_name"] for d in model["domains"]] == ["ecm_crop", "ecm_land_wt", "ecm_cover_crop"]
    joined, foreign = (v["sql"] for v in model["metric_views"])
    assert '`agriculture_ecm`.`ecm_crop`.`field`' in joined
    assert "source: agriculture_ecm.ecm_land_wt.parcel" in joined
    assert "`_metrics`.`ecm_crop_yield`" in joined
    assert "`finance`" in foreign and "agriculture_ecm._metrics.ecm_elsewhere" in foreign
    assert [v["view_name"] for v in model["metric_views"]] == ["ecm_crop_yield", "ecm_elsewhere"]
    assert report.warnings == ["Metric view 'elsewhere': a source names no domain of this model; left as is."]
    assert "'elsewhere'" in caplog.text


def test_the_legacy_dict_shape_keeps_its_order():
    root = {"model": {"domains": [{"name": "crop", "database_name": "crop"}], "metric_views": {
        "b_view": "CREATE VIEW c._metrics.b_view AS $$\n  source: c.crop.t\n$$",
        "a_view": "CREATE VIEW c._metrics.a_view AS $$\n  source: c.crop.t\n$$",
    }}}
    apply_import_prefix(root, "mvm", "mvm_")
    views = root["model"]["metric_views"]
    assert list(views) == ["mvm_b_view", "mvm_a_view"]
    assert "c._metrics.mvm_b_view" in views["mvm_b_view"] and "c.mvm_crop.t" in views["mvm_b_view"]


def test_strip_sql_reverses_a_companion_file():
    sql = (
        "CREATE OR REPLACE VIEW `agriculture_ecm`.`_metrics`.`ecm_crop_yield`\nAS $$\n"
        '  source: "`agriculture_ecm`.`ecm_crop`.`field`"\n$$\n'
        "CREATE VIEW agriculture_ecm._metrics.shared AS $$\n  source: agriculture_ecm.other.t\n$$"
    )
    out = strip_import_prefix_sql(sql, {"ecm_crop": "crop"}, "ecm_")
    assert "`_metrics`.`crop_yield`" in out and "`agriculture_ecm`.`crop`.`field`" in out
    assert "_metrics.shared" in out and "agriculture_ecm.other.t" in out


def test_stamp_scope_sets_the_model_version():
    root = {"model": {"version": "v3_ecm"}}
    stamp_scope(root, 1, "mvm")
    assert root["model"]["version"] == "v1_mvm"


# --- import_scope ---------------------------------------------------------------


def test_the_upstream_mvm_resolves_mvm_although_its_requirements_say_ecm():
    """The agriculture MVM's ``data_model_scopes`` is "Expanded Coverage Model
    - ECM"; its ``model.version`` "v1_mvm" wins."""
    root = {"model_requirements": {"data_model_scopes": "Expanded Coverage Model - ECM"},
            "model": {"version": "v1_mvm"}}
    assert import_scope(root, "/Volumes/c/s/v/model.json", None) == "mvm"
    assert import_scope(root, "/Volumes/c/s/v/model.json", "mvm") == "mvm"


def test_a_choice_contradicting_the_files_version_is_refused():
    with pytest.raises(ImportScopeError, match="says it is an MVM"):
        import_scope({"model": {"version": "v1_mvm"}}, "/Volumes/c/s/v/model.json", "ecm")


def test_a_choice_beats_the_requirements_and_the_folder():
    root = {"model_requirements": {"data_model_scopes": "Expanded Coverage Model - ECM"}, "model": {}}
    path = "/Volumes/c/_metamodel/vol_root/business/acme/v1/ecm/model.json"
    assert import_scope(root, path, "mvm") == "mvm"
    assert import_scope(root, path, None) == "ecm"
    assert import_scope({"model": {}}, path, None) == "ecm"


def test_nothing_answering_is_refused():
    with pytest.raises(ImportScopeError, match="Choose whether this model is an ECM or an MVM"):
        import_scope({"model": {"version": "v1"}}, "/Volumes/c/s/v/model.json", None)


def test_agent_output_is_a_run_id_an_agent_folder_or_the_exact_vibe_scope_key():
    industry = {"agent_version": "5.3.3", "_vibe_session_metadata": {"x": 1}, "model": {}}
    user_path = "/Volumes/c/s/v/model.json"
    assert not is_agent_output(industry, user_path, None)
    assert is_agent_output(industry, user_path, 42)
    assert is_agent_output(industry, "/Volumes/c/_metamodel/vol_root/business/acme/v2/mvm/model.json", None)
    assert is_agent_output({**industry, "_vibe_scope": {"mode": "domains"}}, user_path, None)
    assert not is_agent_output({**industry, "model": {"_vibe_scope": {"mode": "domains"}}}, user_path, None)
