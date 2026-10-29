"""The vibe pre-fill (``services/run_defaults.run_defaults``) and its route
``GET /businesses/{bid}/model-versions/{mvid}/run-defaults``.

Files are the agent 5.3.3 shapes in ``tests/fixtures/vibe_conventions_a2.json``
(a vibed ECM that kept SCREAMING_CASE, Int (0/1), dd/MM/yyyy and the tag
suffix ``_wt``). The lock rule is the agent's ``_vov_base_conventions_win``
(nb 52132-52149): a key the base sets is kept on every vibe, an empty one only
on a Some domains vibe. ``schema_suffix`` and ``tag_suffix`` are locked on
every vibe: the live T2 re-check showed the agent ignoring an edit of both.
"""

from __future__ import annotations

import copy
import json
from pathlib import Path
from types import SimpleNamespace
from unittest.mock import MagicMock

import pytest
from sqlmodel import Session

from vibe_modeling.backend.db_models import Business, ModelVersion, Run, RunOperation
from vibe_modeling.backend.services.operations._install_conventions import VIBE_LOCKED_FIELDS
from vibe_modeling.backend.services.run_defaults import ALWAYS_LOCKED_FIELDS, FIELD_DEFAULTS, run_defaults

_FIXTURE = json.loads(
    (Path(__file__).resolve().parents[1] / "fixtures" / "vibe_conventions_a2.json").read_text()
)
ECM_FILE = _FIXTURE["ecm"]


def _ws_with_files(files: dict[str, dict]) -> MagicMock:
    """A client whose ``files.download`` serves ``files`` by path; any other
    path is missing."""
    ws = MagicMock()

    def _download(path):
        if path not in files:
            raise FileNotFoundError(path)
        resp = MagicMock()
        resp.contents.read.return_value = json.dumps(files[path]).encode()
        return resp

    ws.files.download.side_effect = _download
    return ws


def _nested_path(catalog: str, business: str, version: int, scope: str) -> str:
    return (
        f"/Volumes/{catalog}/_metamodel/vol_root/business/{business}/v{version}/{scope}/model.json"
    )


def _seed(session: Session, *, files_catalog: str = "home_cat", **mv_fields) -> tuple[Business, ModelVersion]:
    biz = Business(name="wt_brewery", description="A brewery")
    session.add(biz)
    session.commit()
    session.refresh(biz)
    mv = ModelVersion(
        business_id=biz.id,
        version=mv_fields.pop("version", 1),
        scope=mv_fields.pop("scope", "ecm"),
        status="completed",
        files_catalog=files_catalog,
        **mv_fields,
    )
    session.add(mv)
    session.commit()
    session.refresh(mv)
    return biz, mv


def _seed_producing_op(session: Session, mv: ModelVersion, widgets: dict) -> None:
    run = Run(business_id=mv.business_id, intent="vibe-new-ecm-mvm", status="completed")
    session.add(run)
    session.commit()
    session.add(
        RunOperation(
            run_id=run.id,
            step_index=0,
            operation_name="vibe_iterate",
            status="succeeded",
            output_version_id=mv.id,
            dispatched_widgets_json=json.dumps(widgets),
        )
    )
    session.commit()


def _file_with(**conventions) -> dict:
    root = copy.deepcopy(ECM_FILE)
    root["model"]["model_conventions"].update(conventions)
    return root


class TestLockedFields:
    def test_vibed_ecm_conventions_are_locked_at_the_file_values(self, engine):
        with Session(engine) as session:
            biz, mv = _seed(session)
            ws = _ws_with_files({_nested_path("home_cat", "wt_brewery", 1, "ecm"): ECM_FILE})
            out = run_defaults(session, ws, biz, mv)

        assert out.file_read is True
        assert out.base_version_id == mv.id
        expected = {
            "naming_convention": "SCREAMING_CASE",
            "primary_key_suffix": "_id",
            "schema_prefix": "ecm_",
            "tag_prefix": "dbx_",
            "table_id_type": "BIGINT",
            "boolean_format": "Int (0/1)",
            "date_format": "dd/MM/yyyy",
            "timestamp_format": "yyyy-MM-dd HH:mm:ss",
        }
        for field, value in expected.items():
            f = out.fields[field]
            assert (f.value, f.source, f.locked, f.locked_scoped) == (value, "base_file", True, True), field

    def test_lock_set_is_the_nine_model_convention_fields_and_the_two_suffixes(self, engine):
        with Session(engine) as session:
            biz, mv = _seed(session)
            ws = _ws_with_files({_nested_path("home_cat", "wt_brewery", 1, "ecm"): ECM_FILE})
            out = run_defaults(session, ws, biz, mv)
        assert {k for k, f in out.fields.items() if f.locked_scoped} == VIBE_LOCKED_FIELDS
        assert len(VIBE_LOCKED_FIELDS) == 11
        assert {"schema_suffix", "tag_suffix"} <= VIBE_LOCKED_FIELDS

    def test_the_suffixes_are_locked_on_every_vibe_even_when_the_base_leaves_them_empty(self, engine):
        """T2 re-check: an All domains Dry Run on a base with ``schema_suffix``
        "" and ``tag_suffix`` "_wt" dispatched edited suffixes and the agent
        kept the base's in model.json, so neither is left to the request."""
        root = _file_with(schema_suffix="", tag_suffix="_wt")
        del root["model"]["model_conventions"]["schema_suffix"]
        with Session(engine) as session:
            biz, mv = _seed(session)
            ws = _ws_with_files({_nested_path("home_cat", "wt_brewery", 1, "ecm"): root})
            out = run_defaults(session, ws, biz, mv)
        schema = out.fields["schema_suffix"]
        tag = out.fields["tag_suffix"]
        assert (schema.value, schema.source, schema.locked, schema.locked_scoped) == ("", "base_file", True, True)
        assert (tag.value, tag.source, tag.locked, tag.locked_scoped) == ("_wt", "base_file", True, True)

    def test_empty_base_value_locks_only_a_scoped_vibe(self, engine):
        """``data_classification_levels`` is "" in the file: an All domains
        vibe sends the form's value (the agent skips the key), a Some domains
        vibe keeps the empty base value."""
        with Session(engine) as session:
            biz, mv = _seed(session)
            root = _file_with(table_id_type="")
            ws = _ws_with_files({_nested_path("home_cat", "wt_brewery", 1, "ecm"): root})
            out = run_defaults(session, ws, biz, mv)

        classification = out.fields["classification_levels"]
        assert (classification.value, classification.source) == ("", "base_file")
        assert (classification.locked, classification.locked_scoped) == (False, True)
        # A list field the base leaves empty starts on the app default.
        table_id = out.fields["table_id_type"]
        assert (table_id.value, table_id.source) == ("BIGINT", "default")
        assert (table_id.locked, table_id.locked_scoped) == (False, True)

    def test_unprefixed_base_prefix_is_editable_unscoped(self, engine):
        """A downloaded industry model, or a business kickstarted before
        0.9.0, has no schema prefix (kickstarts since 0.9.0 get ecm_/mvm_
        and lock like the A2 base)."""
        with Session(engine) as session:
            biz, mv = _seed(session, files_catalog="ind_cat")
            ws = _ws_with_files(
                {_nested_path("ind_cat", "wt_brewery", 1, "ecm"): _file_with(schema_prefix="")}
            )
            out = run_defaults(session, ws, biz, mv)
        prefix = out.fields["schema_prefix"]
        assert (prefix.value, prefix.locked, prefix.locked_scoped) == ("", False, True)

    def test_boolean_alias_is_normalized(self, engine):
        with Session(engine) as session:
            biz, mv = _seed(session)
            ws = _ws_with_files(
                {_nested_path("home_cat", "wt_brewery", 1, "ecm"): _file_with(boolean_format="tinyint")}
            )
            out = run_defaults(session, ws, biz, mv)
        assert out.fields["boolean_format"].value == "Int (0/1)"

    @pytest.mark.parametrize("raw", ["", None, "Yes please"])
    def test_empty_or_unknown_boolean_is_locked_at_the_agents_default(self, engine, raw):
        """The agent canonicalizes the base value before its empty test
        (nb 52136-52143): "", a missing key and an unknown label all become
        Boolean (True/False), so even an All domains vibe keeps it."""
        root = _file_with(boolean_format=raw)
        if raw is None:
            del root["model"]["model_conventions"]["boolean_format"]
        with Session(engine) as session:
            biz, mv = _seed(session)
            ws = _ws_with_files({_nested_path("home_cat", "wt_brewery", 1, "ecm"): root})
            out = run_defaults(session, ws, biz, mv)
        f = out.fields["boolean_format"]
        assert (f.value, f.source, f.locked, f.locked_scoped) == (
            "Boolean (True/False)", "base_file", True, True,
        )

    def test_vibed_base_widgets_never_fill_a_locked_field(self, engine):
        """The run that made a vibed base dispatched snake_case; the agent
        overrode it, so the widget value is not what the model has."""
        with Session(engine) as session:
            biz, mv = _seed(session)
            _seed_producing_op(session, mv, {"naming_convention": "snake_case", "tag_suffix": ""})
            ws = _ws_with_files({_nested_path("home_cat", "wt_brewery", 1, "ecm"): ECM_FILE})
            out = run_defaults(session, ws, biz, mv)
        assert out.fields["naming_convention"].value == "SCREAMING_CASE"
        # The widget's tag_suffix "" does not fill it either.
        assert (out.fields["tag_suffix"].value, out.fields["tag_suffix"].source) == ("_wt", "base_file")
        assert out.fields["tag_suffix"].locked is True


class TestUnreadableFile:
    def test_locked_fields_are_unknown_and_locked(self, engine):
        with Session(engine) as session:
            biz, mv = _seed(session)
            _seed_producing_op(
                session, mv, {"naming_convention": "snake_case", "tag_suffix": "_x", "org_divisions": "Operations and Business"}
            )
            out = run_defaults(session, _ws_with_files({}), biz, mv)

        assert out.file_read is False
        for field in VIBE_LOCKED_FIELDS:
            f = out.fields[field]
            assert (f.value, f.source, f.locked, f.locked_scoped) == (None, "unknown", True, True), field
        # Open fields still come from the producing run.
        assert out.fields["org_divisions"].value == "Operations and Business"


class TestOpenFields:
    def test_widget_only_fields_come_from_the_producing_run(self, engine):
        with Session(engine) as session:
            biz, mv = _seed(session)
            _seed_producing_op(
                session,
                mv,
                {
                    "org_divisions": "Operations, Business and Corporate",
                    "housekeeping_columns": "Yes",
                    "history_tracking_columns": "No",
                    "catalog_prefix": "",
                },
            )
            ws = _ws_with_files({_nested_path("home_cat", "wt_brewery", 1, "ecm"): ECM_FILE})
            out = run_defaults(session, ws, biz, mv)
        assert out.fields["org_divisions"].value == "Operations, Business and Corporate"
        assert (out.fields["housekeeping_columns"].value, out.fields["housekeeping_columns"].source) == ("Yes", "base_run")
        assert (out.fields["catalog_prefix"].value, out.fields["catalog_prefix"].source) == ("", "base_run")
        # Not in the widgets: the app default.
        assert (out.fields["catalog_suffix"].value, out.fields["catalog_suffix"].source) == ("", "default")
        assert not any(out.fields[f].locked or out.fields[f].locked_scoped for f in (
            "org_divisions", "housekeeping_columns", "history_tracking_columns",
            "catalog_prefix", "catalog_suffix",
        ))

    def test_imported_version_with_no_run_uses_defaults_for_open_fields(self, engine):
        with Session(engine) as session:
            biz, mv = _seed(session)
            ws = _ws_with_files({_nested_path("home_cat", "wt_brewery", 1, "ecm"): ECM_FILE})
            out = run_defaults(session, ws, biz, mv)
        assert out.fields["org_divisions"].value == FIELD_DEFAULTS["org_divisions"]
        assert out.fields["org_divisions"].source == "default"
        # Neither run time budget nor Business Domains are pre-filled.
        assert "business_domains" not in out.fields
        assert "runtime_budget_hours" not in out.fields


class TestFileLocation:
    def test_import_source_path_is_read_first(self, engine):
        source = "/Volumes/src_cat/landing/models/brewery.json"
        with Session(engine) as session:
            biz, mv = _seed(session, import_source_path=source)
            ws = _ws_with_files({source: _file_with(data_asset_naming_convention="PascalCase")})
            out = run_defaults(session, ws, biz, mv)
        assert out.fields["naming_convention"].value == "PascalCase"
        assert ws.files.download.call_args_list[0].args == (source,)

    def test_github_source_is_never_read_the_canonical_folder_is(self, engine):
        """A downloaded industry version records a ``github://`` source (E-15);
        the pre-fill reads its Volume copy, in the install's order."""
        github = "github://databricks-industry-solutions/lakehouse-industry-data-models@main/data-models/agriculture/v1/ecm/model.json"
        nested = _nested_path("home_cat", "wt_brewery", 1, "ecm")
        with Session(engine) as session:
            biz, mv = _seed(session, import_source_path=github)
            ws = _ws_with_files({nested: _file_with(data_asset_naming_convention="PascalCase")})
            out = run_defaults(session, ws, biz, mv)
        assert out.fields["naming_convention"].value == "PascalCase"
        assert [c.args[0] for c in ws.files.download.call_args_list] == [nested]

    def test_candidate_order_is_volume_source_nested_flat(self, engine):
        source = "/Volumes/src_cat/landing/models/brewery.json"
        flat = "/Volumes/home_cat/_metamodel/vol_root/business/wt_brewery/ecm_v1/model.json"
        with Session(engine) as session:
            biz, mv = _seed(session, import_source_path=source)
            ws = _ws_with_files({flat: ECM_FILE})
            run_defaults(session, ws, biz, mv)
        assert [c.args[0] for c in ws.files.download.call_args_list] == [
            source, _nested_path("home_cat", "wt_brewery", 1, "ecm"), flat,
        ]

    def test_flat_layout_is_the_fallback(self, engine):
        flat = "/Volumes/home_cat/_metamodel/vol_root/business/wt_brewery/ecm_v1/model.json"
        with Session(engine) as session:
            biz, mv = _seed(session)
            out = run_defaults(session, _ws_with_files({flat: ECM_FILE}), biz, mv)
        assert out.file_read is True

    def test_files_catalog_is_where_the_file_is_read(self, engine):
        """The version was written in ``files_cat`` and installed elsewhere."""
        with Session(engine) as session:
            biz, mv = _seed(session, files_catalog="files_cat", uc_catalog="install_cat")
            out = run_defaults(
                session,
                _ws_with_files({_nested_path("files_cat", "wt_brewery", 1, "ecm"): ECM_FILE}),
                biz,
                mv,
            )
        assert out.file_read is True


class TestRoute:
    def test_returns_the_defaults(self, client, engine, mock_ws):
        with Session(engine) as session:
            biz, mv = _seed(session)
            bid, mvid = biz.id, mv.id
        files = {_nested_path("home_cat", "wt_brewery", 1, "ecm"): ECM_FILE}
        mock_ws.files.download.side_effect = _ws_with_files(files).files.download.side_effect
        resp = client.get(f"/api/businesses/{bid}/model-versions/{mvid}/run-defaults")
        assert resp.status_code == 200, resp.text
        body = resp.json()
        assert body["base_version_id"] == mvid
        assert body["file_read"] is True
        assert body["fields"]["naming_convention"] == {
            "value": "SCREAMING_CASE",
            "source": "base_file",
            "locked": True,
            "locked_scoped": True,
        }

    def test_unreadable_file_is_200(self, client, engine, mock_ws):
        with Session(engine) as session:
            biz, mv = _seed(session)
            bid, mvid = biz.id, mv.id
        mock_ws.files.download.side_effect = PermissionError("denied")
        resp = client.get(f"/api/businesses/{bid}/model-versions/{mvid}/run-defaults")
        assert resp.status_code == 200, resp.text
        assert resp.json()["file_read"] is False

    def test_version_of_another_business_is_404(self, client, engine):
        with Session(engine) as session:
            _, mv = _seed(session)
            other = Business(name="other_co", description="x")
            session.add(other)
            session.commit()
            other_id, mvid = other.id, mv.id
        resp = client.get(f"/api/businesses/{other_id}/model-versions/{mvid}/run-defaults")
        assert resp.status_code == 404, resp.text

    def test_missing_version_is_404(self, client, engine):
        with Session(engine) as session:
            biz, _ = _seed(session)
            bid = biz.id
        resp = client.get(f"/api/businesses/{bid}/model-versions/nope/run-defaults")
        assert resp.status_code == 404, resp.text


def test_reader_is_bounded_per_candidate(engine, monkeypatch):
    """Each candidate goes through the bounded reader once."""
    from vibe_modeling.backend.services.operations import _install_conventions

    calls: list[str] = []
    # ``version_files.read_conventions`` imports the bounded reader at call time.
    monkeypatch.setattr(
        _install_conventions,
        "read_model_json",
        lambda ws, path, **_kw: calls.append((path, True)) or None,
    )
    with Session(engine) as session:
        biz, mv = _seed(session, import_source_path="/Volumes/a/b/c/m.json")
        run_defaults(session, SimpleNamespace(), biz, mv)
    assert [c[0] for c in calls] == [
        "/Volumes/a/b/c/m.json",
        _nested_path("home_cat", "wt_brewery", 1, "ecm"),
        "/Volumes/home_cat/_metamodel/vol_root/business/wt_brewery/ecm_v1/model.json",
    ]
    assert all(c[1] is True for c in calls)


@pytest.mark.parametrize("field", sorted(FIELD_DEFAULTS))
def test_every_field_is_a_run_in_field(field):
    from vibe_modeling.backend.models import RunIn

    assert field in RunIn.model_fields


def test_always_locked_fields_match_the_help_fixture():
    """BE half of ``fixtures/vibe_always_locked_fields.json``: the help pages
    name these fields as locked on every vibe."""
    fixture = json.loads(
        (Path(__file__).resolve().parents[1] / "fixtures" / "vibe_always_locked_fields.json").read_text()
    )
    assert ALWAYS_LOCKED_FIELDS == {f["field"] for f in fixture["fields"]}
    assert ALWAYS_LOCKED_FIELDS <= VIBE_LOCKED_FIELDS


def test_agent_boolean_label_matches_the_notebook():
    """Oracle: the vendored agent's own ``_normalize_boolean_format_label``."""
    import ast

    from vibe_modeling.backend.services.run_defaults import agent_boolean_label

    from ._source_scan import agent_notebook_source

    source = agent_notebook_source()
    start = source.index("def _normalize_boolean_format_label(")
    end = source.index("\ndef ", start + 1)
    namespace: dict = {}
    exec(compile(ast.parse(source[start:end]), "agent", "exec"), namespace)
    oracle = namespace["_normalize_boolean_format_label"]
    for raw in ["", None, "  ", "Boolean (True/False)", "int (0/1)", "String (Y/N)", "tinyint",
                "BIT", "yes/no", "y/n", "1/0", "integer (1/0)", "string (yes/no)", "Yes please"]:
        expected = oracle("" if raw is None else raw)
        assert agent_boolean_label(raw) == expected, raw


class TestReadConventions:
    """``version_files.read_conventions``, shared with the industry kickstart."""

    def test_with_exists_a_present_unreadable_file_is_reported(self):
        from vibe_modeling.backend.services.version_files import read_conventions

        ws = MagicMock()
        ws.files.download.side_effect = PermissionError("denied")
        found = read_conventions(ws, ["/Volumes/a/b/c/m.json"], exists=lambda p: True)
        assert (found.path, found.conventions, found.unreadable) == ("/Volumes/a/b/c/m.json", None, True)

    def test_with_exists_missing_files_are_skipped(self):
        from vibe_modeling.backend.services.version_files import read_conventions

        ws = _ws_with_files({"/b.json": ECM_FILE})
        found = read_conventions(ws, ["/a.json", "/b.json"], exists=lambda p: p == "/b.json")
        assert found.path == "/b.json" and found.unreadable is False
        assert found.conventions["data_asset_naming_convention"] == "SCREAMING_CASE"
        assert [c.args[0] for c in ws.files.download.call_args_list] == ["/b.json"]

    def test_without_exists_an_unreadable_candidate_falls_through(self):
        from vibe_modeling.backend.services.version_files import read_conventions

        ws = _ws_with_files({"/b.json": ECM_FILE})
        found = read_conventions(ws, ["/a.json", "/b.json"])
        assert found.path == "/b.json"
