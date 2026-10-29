"""Tests for ``services/operations/_install_conventions.py``.

Install of a ``_vibe_scope`` model.json must send the file's own model
conventions, or the agent's convention fence (``VibeScopeFenceError``)
rejects the install. Covers the pure parse, the bounded reader and the
merge, plus a parity test that ports the agent's four-key comparison.
"""

from __future__ import annotations

import inspect
import json
import logging
import threading
import time
from typing import Any
from unittest.mock import MagicMock

import pytest
from databricks.sdk.errors import NotFound, PermissionDenied
from pydantic import ValidationError

from vibe_modeling.backend.services.operations import _install_conventions as ic
from vibe_modeling.backend.services.operations._install_conventions import (
    apply_file_conventions,
    parse_scoped_conventions,
    read_scoped_conventions,
)
from vibe_modeling.backend.services.operations.install import (
    InstallParams,
    _build_install_widgets,
)

LOGGER = "vibe_modeling.backend.services.operations._install_conventions"
PATH = "/Volumes/cat/_metamodel/vol_root/business/biz/v3/mvm/model.json"

# Demo v3's ``model.model_conventions`` (design §2 / §7).
V3_MC = {
    "data_asset_naming_convention": "snake_case",
    "primary_key_suffix": "_id",
    "schema_prefix": "mvm_v2_",
    "schema_suffix": "",
    "tag_prefix": "dbx_",
    "tag_suffix": "",
    "table_id_type": "BIGINT",
}
V3_SCOPE = {
    "mode": "domains",
    "label": "Some Domains",
    "base_version": "2",
    "base_scope": "mvm",
}


def _scoped_nested(mc: Any = None) -> dict:
    return {
        "_vibe_scope": dict(V3_SCOPE),
        "model": {"model_conventions": V3_MC if mc is None else mc, "domains": []},
    }


def _params(**overrides) -> InstallParams:
    base: dict[str, Any] = dict(
        scope="mvm",
        business_name="ridgeline_energy",
        deployment_catalog="ridgeline_energy_vibe_model",
        schema_prefix="mvm_",
        model_version=3,
        cataloging_style="One Catalog",
    )
    base.update(overrides)
    return InstallParams(**base)


class _Body:
    def __init__(self, data: bytes, wait: threading.Event | None = None):
        self._data = data
        self._wait = wait
        self.requested: list[int] = []
        self.closed = False

    def close(self) -> None:
        self.closed = True

    def read(self, n: int = -1) -> bytes:
        self.requested.append(n)
        if self._wait is not None:
            self._wait.wait(5)
        return self._data if n < 0 else self._data[:n]


def _ws_returning(data: bytes, *, read_wait: threading.Event | None = None):
    ws = MagicMock()
    body = _Body(data, read_wait)
    resp = MagicMock()
    resp.contents = body
    ws.files.download.return_value = resp
    return ws, body


def _ws_json(root: dict):
    return _ws_returning(json.dumps(root).encode())


# ---------------------------------------------------------------------------
# 1. parse_scoped_conventions
# ---------------------------------------------------------------------------


class TestParse:
    def test_no_vibe_scope_is_none_even_with_custom_prefix(self):
        root = {"model": {"model_conventions": dict(V3_MC)}}
        assert parse_scoped_conventions(root) is None

    def test_empty_vibe_scope_is_none(self):
        root = _scoped_nested()
        root["_vibe_scope"] = {}
        assert parse_scoped_conventions(root) is None

    def test_nested_model_conventions(self):
        assert parse_scoped_conventions(_scoped_nested()) == V3_MC

    def test_flat_root_model_conventions(self):
        root = {"_vibe_scope": dict(V3_SCOPE), "model_conventions": dict(V3_MC)}
        assert parse_scoped_conventions(root) == V3_MC

    def test_conventions_as_json_string(self):
        assert parse_scoped_conventions(_scoped_nested(json.dumps(V3_MC))) == V3_MC

    def test_root_conventions_ignored_when_model_is_dict(self):
        root = {
            "_vibe_scope": dict(V3_SCOPE),
            "model_conventions": {"schema_prefix": "root_"},
            "model": {"domains": []},
        }
        assert parse_scoped_conventions(root) is None
        root["model"]["model_conventions"] = {"schema_prefix": "nested_"}
        assert parse_scoped_conventions(root) == {"schema_prefix": "nested_"}

    @pytest.mark.parametrize(
        "value",
        [None, [], "x", 3, {"_vibe_scope": {"a": 1}, "model_conventions": "not json"},
         {"_vibe_scope": {"a": 1}, "model_conventions": ["list"]},
         {"_vibe_scope": {"a": 1}, "model_conventions": "[1, 2]"},
         {"_vibe_scope": {"a": 1}}],
    )
    def test_garbage_is_none(self, value):
        assert parse_scoped_conventions(value) is None


# ---------------------------------------------------------------------------
# 2. read_scoped_conventions
# ---------------------------------------------------------------------------


class TestReader:
    def test_reads_scoped_file(self):
        ws, body = _ws_json(_scoped_nested())
        assert read_scoped_conventions(ws, PATH) == V3_MC
        ws.files.download.assert_called_once_with(PATH)
        assert body.requested == [ic._MAX_BYTES + 1]
        assert body.closed

    def test_stream_closed_when_read_raises(self):
        class _Failing(_Body):
            def read(self, n: int = -1) -> bytes:
                raise OSError("connection reset")

        ws = MagicMock()
        body = _Failing(b"")
        ws.files.download.return_value.contents = body
        assert read_scoped_conventions(ws, PATH) is None
        assert body.closed

    def test_ordinary_file_is_none_without_warning(self, caplog):
        ws, _ = _ws_json({"model": {"model_conventions": dict(V3_MC)}})
        with caplog.at_level(logging.WARNING, logger=LOGGER):
            assert read_scoped_conventions(ws, PATH) is None
        assert caplog.records == []

    @pytest.mark.parametrize(
        "exc",
        [NotFound("no such file"), PermissionDenied("denied"), RuntimeError("boom")],
    )
    def test_download_errors_fall_back(self, exc, caplog):
        ws = MagicMock()
        ws.files.download.side_effect = exc
        with caplog.at_level(logging.WARNING, logger=LOGGER):
            assert read_scoped_conventions(ws, PATH) is None
        assert "could not read model conventions from" in caplog.text
        assert PATH in caplog.text

    @pytest.mark.parametrize("data", [b"{not json", b"\xff\xfe\x00bad"])
    def test_bad_body_falls_back(self, data, caplog):
        ws, _ = _ws_returning(data)
        with caplog.at_level(logging.WARNING, logger=LOGGER):
            assert read_scoped_conventions(ws, PATH) is None
        assert "could not read model conventions" in caplog.text

    def test_magicmock_ws_falls_back(self, caplog):
        with caplog.at_level(logging.WARNING, logger=LOGGER):
            assert read_scoped_conventions(MagicMock(), PATH) is None
        assert "could not read model conventions" in caplog.text

    def test_over_cap_body_falls_back(self, monkeypatch, caplog):
        monkeypatch.setattr(ic, "_MAX_BYTES", 16)
        ws, body = _ws_json(_scoped_nested())
        ws.files.download.return_value.content_length = None
        with caplog.at_level(logging.WARNING, logger=LOGGER):
            assert read_scoped_conventions(ws, PATH) is None
        assert body.requested == [17]
        assert body.closed
        assert "larger than 16 bytes" in caplog.text

    def test_hung_download_times_out(self, monkeypatch, caplog):
        monkeypatch.setattr(ic, "_READ_TIMEOUT_S", 0.1)
        release = threading.Event()
        workers: list[threading.Thread] = []

        def _hang(path):
            workers.append(threading.current_thread())
            release.wait(5)
            raise RuntimeError("released")

        ws = MagicMock()
        ws.files.download.side_effect = _hang
        try:
            start = time.monotonic()
            with caplog.at_level(logging.WARNING, logger=LOGGER):
                assert read_scoped_conventions(ws, PATH) is None
            assert time.monotonic() - start < 1
            assert "timed out" in caplog.text
            assert workers and workers[0].daemon
            assert workers[0] is not threading.main_thread()
        finally:
            release.set()

    def test_hung_read_times_out(self, monkeypatch, caplog):
        monkeypatch.setattr(ic, "_READ_TIMEOUT_S", 0.1)
        release = threading.Event()
        ws, body = _ws_returning(
            json.dumps(_scoped_nested()).encode(), read_wait=release
        )
        try:
            start = time.monotonic()
            with caplog.at_level(logging.WARNING, logger=LOGGER):
                assert read_scoped_conventions(ws, PATH) is None
            assert time.monotonic() - start < 1
            assert body.requested, "the read must run inside the worker"
            assert "timed out" in caplog.text
        finally:
            release.set()

    def test_model_json_reader_never_receives_a_session(self):
        assert list(inspect.signature(ic.read_model_json).parameters) == ["ws", "context_file", "timeout_s"]

    def test_reader_never_receives_a_session(self):
        assert list(inspect.signature(read_scoped_conventions).parameters) == [
            "ws",
            "context_file",
            "any_file",
        ]

    @pytest.mark.parametrize("bad_prefix", ["MVM_", "{business}_", "mvm"])
    def test_rejected_file_prefix_named_in_warning(self, bad_prefix, caplog):
        ws, _ = _ws_json(_scoped_nested({**V3_MC, "schema_prefix": bad_prefix}))
        with caplog.at_level(logging.WARNING, logger=LOGGER):
            file_mc = read_scoped_conventions(ws, PATH)
            params, _ = apply_file_conventions(_params(), file_mc)
        assert params.schema_prefix == "mvm_"
        assert repr(bad_prefix) in caplog.text
        assert "not usable" in caplog.text


# ---------------------------------------------------------------------------
# 3. apply_file_conventions
# ---------------------------------------------------------------------------


class TestApply:
    def test_v3_uses_file_values(self):
        params, source = apply_file_conventions(_params(), V3_MC)
        assert source == "file"
        assert params.schema_prefix == "mvm_v2_"
        assert params.tag_prefix == "dbx_"
        assert params.schema_suffix == ""
        assert params.naming_convention == "snake_case"
        assert params.primary_key_suffix == "_id"
        assert params.table_id_type == "BIGINT"

    def test_explicit_key_wins_over_file(self):
        p = _params(
            schema_prefix="mine_",
            naming_convention="PascalCase",
            explicit_convention_keys=["schema_prefix", "naming_convention"],
        )
        params, source = apply_file_conventions(
            p, {**V3_MC, "data_asset_naming_convention": "camelCase"}
        )
        assert params.schema_prefix == "mine_"
        assert params.naming_convention == "PascalCase"
        assert params.tag_prefix == "dbx_"
        assert source == "partial"

    @pytest.mark.parametrize(
        "style", ["Catalog per Domain", "Catalog per Division"]
    )
    def test_multi_catalog_sends_the_files_prefix(self, style):
        """The file's stored names carry its prefix, so every style sends it."""
        p = _params(cataloging_style=style, schema_prefix="")
        params, source = apply_file_conventions(p, V3_MC)
        assert (params.schema_prefix, params.prefix_from_record) == ("mvm_v2_", True)
        assert params.tag_prefix == "dbx_"
        assert source == "file"

    def test_multi_catalog_with_empty_file_prefix_is_file(self):
        p = _params(cataloging_style="Catalog per Domain", schema_prefix="")
        params, source = apply_file_conventions(p, {**V3_MC, "schema_prefix": ""})
        assert params.schema_prefix == ""
        assert source == "file"

    @pytest.mark.parametrize("bad", ["Mvm_", "mvm"])
    def test_one_catalog_invalid_prefix_keeps_default(self, bad, caplog):
        with caplog.at_level(logging.WARNING, logger=LOGGER):
            params, source = apply_file_conventions(
                _params(), {**V3_MC, "schema_prefix": bad}
            )
        assert params.schema_prefix == "mvm_"
        assert source == "partial"
        assert "not usable" in caplog.text

    def test_dropdown_value_outside_choices_falls_back(self, caplog):
        with caplog.at_level(logging.WARNING, logger=LOGGER):
            params, source = apply_file_conventions(
                _params(), {**V3_MC, "data_asset_naming_convention": "kebab-case"}
            )
        assert params.naming_convention == "snake_case"
        assert params.schema_prefix == "mvm_v2_"
        assert source == "partial"
        assert "kebab-case" in caplog.text

    @pytest.mark.parametrize(
        "raw,expected", [("", "BIGINT"), (None, "BIGINT"), ("bigint", "BIGINT"),
                         ("int", "INT"), ("STRING", "STRING")]
    )
    def test_table_id_type(self, raw, expected):
        params, _ = apply_file_conventions(_params(), {**V3_MC, "table_id_type": raw})
        assert params.table_id_type == expected

    def test_unknown_table_id_type_falls_back(self):
        params, source = apply_file_conventions(
            _params(table_id_type="INT"), {**V3_MC, "table_id_type": "UUID"}
        )
        assert params.table_id_type == "INT"
        assert source == "partial"

    def test_empty_file_conventions_change_nothing(self):
        p = _params()
        params, source = apply_file_conventions(p, {})
        assert params is p
        assert source == "request"

    def test_text_keys_sent_verbatim_including_empty(self):
        params, _ = apply_file_conventions(
            _params(),
            {**V3_MC, "primary_key_suffix": "", "schema_suffix": "_x", "tag_prefix": ""},
        )
        assert params.primary_key_suffix == ""
        assert params.schema_suffix == "_x"
        assert params.tag_prefix == ""

    def test_tag_suffix_is_never_taken(self):
        params, _ = apply_file_conventions(_params(), {**V3_MC, "tag_suffix": "_t"})
        widgets = _build_install_widgets(params, "1")
        assert "tag_suffix" not in widgets
        assert not hasattr(params, "tag_suffix")


# ---------------------------------------------------------------------------
# 4. Agent parity: port of the 5.3.3 Step 0.5 merge + four-key comparison
# ---------------------------------------------------------------------------

# The notebook's widget defaults for the convention widgets (an absent widget
# takes the notebook default; the persistent job has no base_parameters).
# Only the compared and explicit-override keys matter for the fence.
_NB_WIDGET_DEFAULTS = {
    "data_asset_naming_convention": "snake_case",
    "primary_key_suffix": "_id",
    "schema_prefix": "",
    "schema_suffix": "",
    "catalog_prefix": "",
    "catalog_suffix": "",
    "tag_prefix": "dbx_",
    "tag_suffix": "",
    "table_id_type": "BIGINT",
}
_EXPLICIT_OVERRIDE_KEYS = {
    "schema_prefix", "schema_suffix", "catalog_prefix",
    "catalog_suffix", "tag_prefix", "tag_suffix",
}
_WIDGET_TO_MC = {
    "naming_convention": "data_asset_naming_convention",
    "primary_key_suffix": "primary_key_suffix",
    "schema_prefix": "schema_prefix",
    "schema_suffix": "schema_suffix",
    "tag_prefix": "tag_prefix",
    "tag_suffix": "tag_suffix",
    "table_id_type": "table_id_type",
}


def _agent_convention_changed(widgets: dict, file_mc: dict) -> bool:
    widget_mc = dict(_NB_WIDGET_DEFAULTS)
    for widget, key in _WIDGET_TO_MC.items():
        if widget in widgets:
            widget_mc[key] = str(widgets[widget]).strip()
    deploy = dict(file_mc)
    for key, value in widget_mc.items():
        if key in _EXPLICIT_OVERRIDE_KEYS or str(value).strip():
            deploy[key] = value
    naming = deploy.get("data_asset_naming_convention", "snake_case") != file_mc.get(
        "data_asset_naming_convention", "snake_case"
    )
    pk = deploy.get("primary_key_suffix", "_id") != file_mc.get(
        "primary_key_suffix", "_id"
    )
    prefix = deploy.get("schema_prefix", "") != file_mc.get("schema_prefix", "")
    deploy_id = deploy.get("table_id_type")
    id_type = bool(deploy_id) and deploy_id.upper() != (
        file_mc.get("table_id_type") or "BIGINT"
    ).upper()
    return naming or pk or prefix or id_type


_PARITY_CASES = [
    ("defaults", "One Catalog", "mvm_", {
        "data_asset_naming_convention": "snake_case", "primary_key_suffix": "_id",
        "schema_prefix": "mvm_", "table_id_type": "BIGINT",
    }),
    ("v3", "One Catalog", "mvm_", V3_MC),
    ("camel_key_int", "One Catalog", "mvm_", {
        "data_asset_naming_convention": "camelCase", "primary_key_suffix": "_key",
        "schema_prefix": "ecm_v4_", "table_id_type": "INT",
        "schema_suffix": "_s", "tag_prefix": "acme_",
    }),
    ("lowercase_id_type", "One Catalog", "mvm_", {**V3_MC, "table_id_type": "int"}),
    ("empty_id_type", "One Catalog", "mvm_", {**V3_MC, "table_id_type": ""}),
    ("missing_keys", "One Catalog", "mvm_", {"schema_prefix": "mvm_v2_"}),
    ("catalog_per_domain", "Catalog per Domain", "", {
        **V3_MC, "schema_prefix": "", "data_asset_naming_convention": "PascalCase",
    }),
]


class TestAgentParity:
    @pytest.mark.parametrize(
        "style,prefix,file_mc",
        [c[1:] for c in _PARITY_CASES],
        ids=[c[0] for c in _PARITY_CASES],
    )
    def test_effective_widgets_pass_the_fence(self, style, prefix, file_mc):
        params, _ = apply_file_conventions(
            _params(cataloging_style=style, schema_prefix=prefix), file_mc
        )
        widgets = _build_install_widgets(params, "1")
        assert _agent_convention_changed(widgets, file_mc) is False, widgets

    def test_todays_widgets_for_v3_trip_the_fence(self):
        widgets = _build_install_widgets(_params(), "1")
        assert widgets["schema_prefix"] == "mvm_"
        assert _agent_convention_changed(widgets, V3_MC) is True

    def test_read_then_merge_end_to_end_for_v3(self):
        ws, _ = _ws_json(_scoped_nested())
        file_mc = read_scoped_conventions(ws, PATH)
        params, source = apply_file_conventions(_params(), file_mc)
        widgets = _build_install_widgets(params, "1")
        assert source == "file"
        assert widgets["schema_prefix"] == "mvm_v2_"
        assert _agent_convention_changed(widgets, file_mc) is False


# ---------------------------------------------------------------------------
# 5. Unprefixed models (industry, kickstart) in One Catalog
# ---------------------------------------------------------------------------

# ``model.model_conventions`` of the agriculture industry model, verbatim
# (lakehouse-industry-data-models data-models/agriculture/v1/mvm/model.json).
# A business kickstarted from it vibes with these, so its drafts carry them.
INDUSTRY_MC = {
    "data_asset_naming_convention": "snake_case",
    "primary_key_suffix": "_id",
    "schema_prefix": "",
    "schema_suffix": "",
    "tag_prefix": "dbx_",
    "tag_suffix": "",
    "table_id_type": "BIGINT",
    "boolean_format": "Boolean (True/False)",
    "date_format": "yyyy-MM-dd",
    "timestamp_format": "yyyy-MM-dd'T'HH:mm:ss.SSSXXX",
    "data_classification_levels": "restricted=restricted, confidential=confidential, internal=Internal, public=public",
    "housekeeping_columns": "",
    "history_tracking_columns": "",
}
# A New Base Model's (P0 business_3 wt_p0_grain_coop v2 mvm, a ``_vibe_scope``
# file), verbatim.
BASE_MODEL_MC = {
    "data_asset_naming_convention": "snake_case",
    "primary_key_suffix": "_id",
    "schema_prefix": "mvm_",
    "schema_suffix": "",
    "tag_prefix": "dbx_",
    "tag_suffix": "",
    "table_id_type": "BIGINT",
    "boolean_format": "Boolean (True/False)",
    "date_format": "yyyy-MM-dd",
    "timestamp_format": "yyyy-MM-dd HH:mm:ss",
    "data_classification_levels": "",
    "housekeeping_columns": "",
    "history_tracking_columns": "",
}


class TestUnprefixedModels:
    def test_the_files_blank_prefix_is_sent(self):
        """E-09: One Catalog sends the file's ``""``; the agent's fence
        passes."""
        params, source = apply_file_conventions(_params(), INDUSTRY_MC)
        widgets = _build_install_widgets(params, "1")
        assert source == "file"
        assert params.prefix_from_record is True
        assert widgets["schema_prefix"] == ""
        assert widgets["cataloging_style"] == "One Catalog"
        assert _agent_convention_changed(widgets, INDUSTRY_MC) is False

    def test_the_old_widgets_trip_the_fence(self):
        assert _agent_convention_changed(_build_install_widgets(_params(), "1"), INDUSTRY_MC) is True

    def test_a_prefixed_base_model_draft_is_unchanged(self):
        before = _build_install_widgets(_params(), "1")
        params, source = apply_file_conventions(_params(), BASE_MODEL_MC)
        after = _build_install_widgets(params, "1")
        assert source == "file"
        assert after["schema_prefix"] == "mvm_"
        assert {k: v for k, v in after.items() if k not in ("schema_suffix", "tag_prefix")} == before
        assert _agent_convention_changed(after, BASE_MODEL_MC) is False

    def test_an_explicit_prefix_keeps_the_request_rule(self):
        p = _params(schema_prefix="mine_", explicit_convention_keys=["schema_prefix"])
        params, _ = apply_file_conventions(p, INDUSTRY_MC)
        assert params.schema_prefix == "mine_"
        assert params.prefix_from_record is False

    def test_a_request_without_a_prefix_is_still_refused(self):
        """A user-typed One Catalog install with no prefix: the validator
        refuses as before."""
        with pytest.raises(ValidationError, match="requires a non-empty schema_prefix"):
            _params(schema_prefix="")

    @pytest.mark.parametrize("style", ["Catalog per Domain", "Catalog per Division"])
    def test_multi_catalog_forbids_a_typed_prefix_and_allows_the_files(self, style):
        with pytest.raises(ValidationError, match="forbids schema_prefix"):
            _params(cataloging_style=style, schema_prefix="mvm_")
        assert _params(cataloging_style=style, schema_prefix="mvm_", prefix_from_record=True).schema_prefix == "mvm_"



# ---------------------------------------------------------------------------
# 6. The version's own prefix for an ordinary install
# ---------------------------------------------------------------------------


class TestVersionOwnPrefix:
    def _resolve(self, req_prefix):
        from types import SimpleNamespace

        from vibe_modeling.backend.services.orchestrator.dag_factories._simple import (
            install_schema_prefix,
        )

        return install_schema_prefix(SimpleNamespace(schema_prefix=req_prefix))

    def test_a_typed_prefix_is_the_requests(self):
        assert self._resolve("mine_") == ("mine_", "request")

    def test_a_typed_blank_is_kept_for_the_validator(self):
        assert self._resolve("") == ("", "request")

    def test_no_typed_prefix_takes_the_file_at_dispatch(self):
        assert self._resolve(None) == ("", "version")

    def test_the_versions_prefix_passes_every_style_until_dispatch(self):
        for style in ("One Catalog", "Catalog per Division", "Catalog per Domain"):
            assert _params(schema_prefix="", prefix_from_version=True, cataloging_style=style).prefix_from_version

    def test_apply_file_prefix_takes_only_the_prefix(self):
        params, source = ic.apply_file_prefix(
            _params(prefix_from_version=True), {**INDUSTRY_MC, "schema_prefix": "acme_"},
        )
        assert (params.schema_prefix, params.prefix_from_record, source) == ("acme_", True, "prefix")
        assert params.schema_suffix is None and params.tag_prefix is None

    def test_apply_file_prefix_sends_a_blank_file_prefix(self):
        p = _params(schema_prefix="", prefix_from_version=True)
        for mc in (INDUSTRY_MC, {"data_asset_naming_convention": "snake_case"}, {}):
            params, source = ic.apply_file_prefix(p, mc)
            assert (params.schema_prefix, params.prefix_from_record, source) == ("", True, "prefix")

    def test_apply_file_prefix_keeps_the_params_without_a_file_or_a_usable_prefix(self, caplog):
        p = _params(prefix_from_version=True)
        assert ic.apply_file_prefix(p, None) == (p, None)
        with caplog.at_level(logging.WARNING, logger=LOGGER):
            assert ic.apply_file_prefix(p, {"schema_prefix": "MVM_"}) == (p, None)
        assert "not usable" in caplog.text
