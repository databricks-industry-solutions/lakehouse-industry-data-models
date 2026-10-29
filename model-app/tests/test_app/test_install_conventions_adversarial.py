"""Adversarial tests for ``Install.dispatch`` reading a scoped model.json's
conventions (fix/install-uses-version-conventions).

Written by the independent tester. The agent-parity helper below is a fresh
port of the 5.3.3 notebook (``_run_deploy_model`` Step 0.5 merge and the
four-key ``_convention_changed`` expression, plus widget declarations,
``_safe_widget`` strip and ``_sub_biz``), not a reuse of the developer's.
"""

from __future__ import annotations

import io
import json
import logging
import os
import subprocess
import sys
import textwrap
import threading
import time
from pathlib import Path
from types import SimpleNamespace
from typing import Any, Optional
from unittest.mock import MagicMock, patch

import pytest

_HERE = os.path.dirname(os.path.abspath(__file__))
_APP_SRC = os.path.abspath(os.path.join(_HERE, "..", "..", "src", "app", "src"))
if _APP_SRC not in sys.path:
    sys.path.insert(0, _APP_SRC)

from vibe_modeling.backend.core._paths import model_json_volume_path  # noqa: E402
from vibe_modeling.backend.services.operations import (  # noqa: E402
    OperationContext,
)
from vibe_modeling.backend.services.operations import (  # noqa: E402
    _install_conventions as ic,
)
from vibe_modeling.backend.services.operations import install as install_mod  # noqa: E402
from vibe_modeling.backend.services.operations.install import Install  # noqa: E402

_LAUNCH = "vibe_modeling.backend.services.operations.install.launch_run"
# A trimmed 5.3.3-shaped scoped model.json: root ``_vibe_scope`` block, the
# v3 demo conventions under ``model``, one small domain.
_SCOPED_FIXTURE = Path(_HERE).parent / "fixtures" / "vibe_scope_model_v3.json"
_V3_PATH = (
    "/Volumes/ridgeline_energy_vibe_model/_metamodel/vol_root/business/"
    "ridgeline_energy/v3/mvm/model.json"
)
_V3_MC = {
    "data_asset_naming_convention": "snake_case",
    "primary_key_suffix": "_id",
    "schema_prefix": "mvm_v2_",
    "schema_suffix": "",
    "tag_prefix": "dbx_",
    "tag_suffix": "",
    "table_id_type": "BIGINT",
}
_SCOPE_BLOCK = {"mode": "domains", "preserved_products": []}


# ---------------------------------------------------------------------------
# Independent port of the agent (5.3.3) convention fence
# ---------------------------------------------------------------------------

# dbutils.widgets declarations (notebook "Model Convention Widgets").
_NB_WIDGET_DEFAULTS = {
    "naming_convention": "snake_case",
    "primary_key_suffix": "_id",
    "schema_prefix": "",
    "schema_suffix": "",
    "tag_prefix": "dbx_",
    "tag_suffix": "",
    "table_id_type": "BIGINT",
    "catalog_prefix": "",
    "catalog_suffix": "",
    "boolean_format": "Boolean (True/False)",
    "date_format": "yyyy-MM-dd",
    "timestamp_format": "yyyy-MM-dd'T'HH:mm:ss.SSSXXX",
    "classification_levels": "restricted=restricted, confidential=confidential, "
    "internal=Internal, public=public",
    "housekeeping_columns": "No",
    "history_tracking_columns": "No",
}
_EXPLICIT_OVERRIDE_KEYS = {
    "schema_prefix", "schema_suffix", "catalog_prefix",
    "catalog_suffix", "tag_prefix", "tag_suffix",
}


def _agent_convention_changed(widgets: dict, root: Any, business: str) -> bool:
    """Port of the agent: widgets -> _widget_model_conventions -> merge with
    the file's model_conventions -> four-key comparison."""

    def w(name):  # widget absent -> notebook default; _safe_widget strips
        v = widgets.get(name, _NB_WIDGET_DEFAULTS.get(name, ""))
        return str(v).strip() if v is not None else ""

    def sub_biz(v):
        if not v:
            return v
        return v.replace("${business}", business).replace("{business}", business)

    widget_mc = {
        "data_classification_levels": w("classification_levels"),
        "data_asset_naming_convention": w("naming_convention"),
        "primary_key_suffix": w("primary_key_suffix"),
        "foreign_key_suffix": "",
        "schema_prefix": w("schema_prefix"),
        "schema_suffix": w("schema_suffix"),
        "tag_prefix": w("tag_prefix"),
        "tag_suffix": w("tag_suffix"),
        "catalog_prefix": w("catalog_prefix"),
        "catalog_suffix": w("catalog_suffix"),
        "table_id_type": w("table_id_type"),
        "boolean_format": w("boolean_format"),
        "date_format": w("date_format"),
        "timestamp_format": w("timestamp_format"),
        "add_house_keeping_columns": w("housekeeping_columns"),
        "add_history_tracking_columns": w("history_tracking_columns"),
    }
    widget_mc = {k: (sub_biz(v) if isinstance(v, str) else v) for k, v in widget_mc.items()}

    if isinstance(root, dict) and isinstance(root.get("model"), dict):
        data_model = root["model"]
    else:
        data_model = root
    file_mc = data_model.get("model_conventions") or {}
    if isinstance(file_mc, str):
        try:
            file_mc = json.loads(file_mc)
        except (json.JSONDecodeError, TypeError):
            file_mc = {}

    deploy_mc = dict(file_mc)
    for k, v in widget_mc.items():
        if k in _EXPLICIT_OVERRIDE_KEYS:
            deploy_mc[k] = v if v is not None else ""
        elif str(v).strip():
            deploy_mc[k] = v

    d_naming = deploy_mc.get("data_asset_naming_convention", "snake_case")
    d_prefix = deploy_mc.get("schema_prefix", "")
    d_pk = deploy_mc.get("primary_key_suffix", "_id")
    d_idt = deploy_mc.get("table_id_type", "")
    f_naming = file_mc.get("data_asset_naming_convention", "snake_case")
    f_pk = file_mc.get("primary_key_suffix", "_id")
    f_prefix = file_mc.get("schema_prefix", "")
    f_idt = file_mc.get("table_id_type", "")
    return bool(
        (d_naming != f_naming)
        or (d_pk != f_pk)
        or (d_prefix != f_prefix)
        or (d_idt and d_idt.upper() != (f_idt or "BIGINT").upper())
    )


# ---------------------------------------------------------------------------
# The ordinary install contract (the widget map before scoped installs)
# ---------------------------------------------------------------------------

_DEV_EXTRA_KEYS = {
    "scope", "deployment_catalog", "schema_prefix", "model_version",
    "business_name", "cataloging_style",
}


def _dev_widgets(params: dict) -> dict:
    """The widgets an ordinary install sends for ``params`` (no
    ``vibe_session_id``), written out key by key so the comparison does
    not depend on the code under test."""
    scope = params["scope"]
    context_file = (params.get("context_file_candidates") or [None])[0] or model_json_volume_path(
        params["deployment_catalog"], params["business_name"],
        int(params["model_version"]), scope,
    )
    return {
        "operation": "install model",
        "business_name": params["business_name"],
        "deployment_catalog": params["deployment_catalog"],
        "data_model_scopes": (
            "Expanded Coverage Model - ECM" if scope == "ecm" else "Minimum Viable Model - MVM"
        ),
        "model_version": str(params["model_version"]),
        "context_file": context_file,
        "schema_prefix": params.get("schema_prefix", ""),
        "cataloging_style": params.get("cataloging_style", "One Catalog"),
        "naming_convention": params.get("naming_convention", "snake_case"),
        "primary_key_suffix": params.get("primary_key_suffix", "_id"),
        "table_id_type": params.get("table_id_type", "BIGINT"),
    }


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------


def _params(**overrides) -> dict:
    base = {
        "business_name": "ridgeline_energy",
        "deployment_catalog": "ridgeline_energy_vibe_model",
        "scope": "mvm",
        "cataloging_style": "One Catalog",
        "schema_prefix": "mvm_",
        "model_version": 3,
        "naming_convention": "snake_case",
        "primary_key_suffix": "_id",
        "table_id_type": "BIGINT",
        "context_file_candidates": [],
        "explicit_convention_keys": [],
    }
    base.update(overrides)
    return base


def _ctx(params: dict, parent_version_id: Optional[str] = "mv-3") -> OperationContext:
    return OperationContext(
        run_id="run-t", operation_id="op-t", business_id="biz-t",
        parent_version_id=parent_version_id, params=params,
        inherited_params={"cataloging_style": params.get("cataloging_style")},
    )


def _ws_bytes(body: Any) -> MagicMock:
    ws = MagicMock()
    ws.config.host = "https://test.databricks.com"
    resp = MagicMock()
    if isinstance(body, (bytes, bytearray)):
        resp.contents = io.BytesIO(bytes(body))
    else:
        resp.contents.read.return_value = body
    ws.files.download.return_value = resp
    return ws


def _ws_json(root: Any) -> MagicMock:
    return _ws_bytes(json.dumps(root).encode())


def _dispatch(params: dict, ws, parent_version_id: Optional[str] = "mv-3"):
    captured: dict = {}

    def _fake_launch_run(ws_, job_id, widget_params, *a, **k):
        captured.update(widget_params)
        return 4242

    with patch(_LAUNCH, _fake_launch_run):
        handle = Install().dispatch(_ctx(params, parent_version_id), ws, MagicMock())
    return captured, handle


def _no_sid(w: dict) -> dict:
    return {k: v for k, v in w.items() if k != "vibe_session_id"}


def _scoped(mc: Any, *, nested: bool = True) -> dict:
    if nested:
        return {"_vibe_scope": dict(_SCOPE_BLOCK), "model": {"model_conventions": mc}}
    return {"_vibe_scope": dict(_SCOPE_BLOCK), "model_conventions": mc}


# ---------------------------------------------------------------------------
# 1. Scoped fixture file
# ---------------------------------------------------------------------------


class TestScopedFixtureFile:
    @pytest.fixture
    def raw(self) -> bytes:
        return _SCOPED_FIXTURE.read_bytes()

    def test_fixture_file_dispatches_file_conventions(self, raw):
        ws = _ws_bytes(raw)
        params = _params()
        widgets, handle = _dispatch(params, ws)
        ws.files.download.assert_called_once_with(_V3_PATH)
        assert widgets["context_file"] == _V3_PATH
        mc = json.loads(raw)["model"]["model_conventions"]
        assert widgets["schema_prefix"] == "mvm_v2_" == mc["schema_prefix"]
        assert widgets["naming_convention"] == mc["data_asset_naming_convention"]
        assert widgets["primary_key_suffix"] == mc["primary_key_suffix"]
        assert widgets["table_id_type"] == mc["table_id_type"].upper()
        assert widgets["schema_suffix"] == mc["schema_suffix"]
        assert widgets["tag_prefix"] == mc["tag_prefix"]
        assert "tag_suffix" not in widgets
        assert widgets["cataloging_style"] == "One Catalog"
        assert handle.extra["schema_prefix"] == "mvm_v2_"
        assert handle.extra["conventions_source"] == "file"
        assert handle.dispatched_widgets == widgets

    def test_fixture_file_passes_agent_fence_and_old_map_fails(self, raw):
        root = json.loads(raw)
        assert root.get("_vibe_scope")
        widgets, _ = _dispatch(_params(), _ws_bytes(raw))
        assert _agent_convention_changed(widgets, root, "ridgeline_energy") is False
        old = _dev_widgets(_params())
        assert old["schema_prefix"] == "mvm_"
        assert _agent_convention_changed(old, root, "ridgeline_energy") is True


# ---------------------------------------------------------------------------
# 2. Malformed / odd files fall back to the ordinary widgets exactly
# ---------------------------------------------------------------------------


class TestFallbacksAreByteIdenticalToDev:
    @pytest.mark.parametrize(
        "body",
        [
            pytest.param(json.dumps({"_vibe_scope": {}, "model": {"model_conventions": _V3_MC}}).encode(), id="empty-vibe-scope"),
            pytest.param(json.dumps({"_vibe_scope": None, "model": {"model_conventions": _V3_MC}}).encode(), id="null-vibe-scope"),
            pytest.param(json.dumps({"model": {"_vibe_scope": _SCOPE_BLOCK, "model_conventions": _V3_MC}}).encode(), id="vibe-scope-under-model"),
            pytest.param(json.dumps([_scoped(_V3_MC)]).encode(), id="json-array"),
            pytest.param(json.dumps(_scoped("not json {")).encode(), id="mc-bad-json-string"),
            pytest.param(json.dumps(_scoped(["a"])).encode(), id="mc-list"),
            pytest.param(json.dumps(_scoped(None)).encode(), id="mc-null"),
            pytest.param(json.dumps({"model": {"model_conventions": _V3_MC}}).encode(), id="ordinary-nested"),
            pytest.param(json.dumps({"model_conventions": _V3_MC, "domains": []}).encode(), id="ordinary-flat"),
        ],
    )
    def test_fallback(self, body, caplog):
        params = _params()
        ws = _ws_bytes(body)
        with caplog.at_level(logging.WARNING):
            widgets, handle = _dispatch(params, ws)
        ws.files.download.assert_called_once_with(_V3_PATH)
        assert _no_sid(widgets) == _dev_widgets(params)
        assert "conventions_source" not in handle.extra
        assert widgets["schema_prefix"] == "mvm_"

    def test_scoped_mc_empty_dict_keeps_today_and_warns_on_prefix(self, caplog):
        params = _params()
        with caplog.at_level(logging.WARNING):
            widgets, handle = _dispatch(params, _ws_json(_scoped({})))
        assert _no_sid(widgets) == _dev_widgets(params)
        assert "no schema_prefix" in caplog.text

    @pytest.mark.parametrize(
        "body",
        [
            pytest.param(json.dumps(_scoped(_V3_MC)).encode()[:-7], id="truncated-json"),
            pytest.param(b"\xff\xfe\x00garbage", id="bad-utf8"),
            pytest.param(b"", id="empty-body"),
        ],
    )
    def test_unparseable_body_fails_the_step(self, body):
        ws = _ws_bytes(body)
        with pytest.raises(RuntimeError, match="couldn't read the model.json"):
            _dispatch(_params(), ws)
        assert ws.files.download.call_args_list[0].args == (_V3_PATH,)

    def test_40mb_body_streamed_is_rejected(self, caplog):
        big = b'{"_vibe_scope": {"mode": "x"}, "pad": "' + b"a" * (40 * 1024 * 1024) + b'"}'
        ws = _ws_bytes(big)
        with caplog.at_level(logging.WARNING):
            with pytest.raises(RuntimeError, match="couldn't read the model.json"):
                _dispatch(_params(), ws)
        assert "larger than" in caplog.text

    def test_40mb_body_read_ignores_n_is_rejected(self):
        big = b"x" * (40 * 1024 * 1024)
        ws = _ws_bytes(None)
        ws.files.download.return_value.contents.read.return_value = big
        with pytest.raises(RuntimeError, match="couldn't read the model.json"):
            _dispatch(_params(), ws)
        args, _k = ws.files.download.return_value.contents.read.call_args
        assert args == (ic._MAX_BYTES + 1,)

    def test_generic_exception_from_download(self, caplog):
        ws = _ws_bytes(None)
        ws.files.download.side_effect = Exception("boom")
        with caplog.at_level(logging.WARNING):
            with pytest.raises(RuntimeError, match="couldn't read the model.json"):
                _dispatch(_params(), ws)
        assert "boom" in caplog.text

    def test_keyboard_interrupt_in_worker_does_not_escape(self):
        ws = _ws_bytes(None)
        ws.files.download.side_effect = KeyboardInterrupt()
        with pytest.raises(RuntimeError, match="couldn't read the model.json"):
            _dispatch(_params(), ws)

    def test_read_returns_str_body(self):
        ws = _ws_bytes(None)
        ws.files.download.return_value.contents.read.return_value = json.dumps(_scoped(_V3_MC))
        assert ic.read_scoped_conventions(ws, _V3_PATH)["schema_prefix"] == "mvm_v2_"


# ---------------------------------------------------------------------------
# 3. File values that cannot be used
# ---------------------------------------------------------------------------


class TestUnusableFileValues:
    @pytest.mark.parametrize("prefix", ["{business}_x_", "{business}_x", "MVM_V2_", "Mvm_v2_", "mvm_é_", "mvm v2_", "2mvm_", "mvm"])
    def test_bad_prefix_falls_back_to_scope_default(self, prefix, caplog):
        mc = {**_V3_MC, "schema_prefix": prefix}
        with caplog.at_level(logging.WARNING):
            widgets, handle = _dispatch(_params(), _ws_json(_scoped(mc)))
        assert widgets["schema_prefix"] == "mvm_"
        # The other file values still apply.
        assert widgets["tag_prefix"] == "dbx_"
        assert handle.extra["conventions_source"] == "partial"
        assert repr(prefix) in caplog.text

    def test_non_string_prefix(self):
        widgets, _ = _dispatch(_params(), _ws_json(_scoped({**_V3_MC, "schema_prefix": 7})))
        assert widgets["schema_prefix"] == "mvm_"

    @pytest.mark.parametrize("style", ["Catalog per Division", "Catalog per Domain"])
    def test_multi_catalog_sends_the_files_prefix_and_other_file_values(self, style):
        mc = {**_V3_MC, "data_asset_naming_convention": "camelCase", "table_id_type": "int"}
        params = _params(cataloging_style=style, schema_prefix="")
        widgets, handle = _dispatch(params, _ws_json(_scoped(mc)))
        assert widgets["schema_prefix"] == "mvm_v2_"
        assert widgets["cataloging_style"] == style
        assert widgets["naming_convention"] == "camelCase"
        assert widgets["table_id_type"] == "INT"
        # The file's own prefix passes the agent's fence in every style.
        assert _agent_convention_changed(widgets, _scoped(mc), "ridgeline_energy") is False

    def test_multi_catalog_file_with_empty_prefix_passes_fence(self):
        mc = {**_V3_MC, "schema_prefix": ""}
        params = _params(cataloging_style="Catalog per Division", schema_prefix="")
        widgets, handle = _dispatch(params, _ws_json(_scoped(mc)))
        assert widgets["schema_prefix"] == ""
        assert handle.extra["conventions_source"] == "file"
        assert _agent_convention_changed(widgets, _scoped(mc), "ridgeline_energy") is False

    def test_bad_naming_and_id_type_fall_back(self):
        mc = {**_V3_MC, "data_asset_naming_convention": "kebab-case", "table_id_type": "uuid"}
        widgets, _ = _dispatch(_params(), _ws_json(_scoped(mc)))
        assert widgets["naming_convention"] == "snake_case"
        assert widgets["table_id_type"] == "BIGINT"
        assert widgets["schema_prefix"] == "mvm_v2_"

    def test_non_string_text_values_fall_back(self):
        mc = {**_V3_MC, "primary_key_suffix": None, "tag_prefix": 5, "schema_suffix": ["x"]}
        widgets, _ = _dispatch(_params(), _ws_json(_scoped(mc)))
        assert widgets["primary_key_suffix"] == "_id"
        assert "tag_prefix" not in widgets
        assert "schema_suffix" not in widgets


# ---------------------------------------------------------------------------
# 4. Agent parity over a table of scoped files
# ---------------------------------------------------------------------------


@pytest.mark.parametrize(
    "mc",
    [
        pytest.param(dict(_V3_MC), id="v3"),
        pytest.param({**_V3_MC, "data_asset_naming_convention": "PascalCase", "primary_key_suffix": "_key", "table_id_type": "long"}, id="pascal-key-long"),
        pytest.param({**_V3_MC, "table_id_type": ""}, id="empty-id-type"),
        pytest.param({**_V3_MC, "schema_suffix": "_s", "tag_prefix": "acme_"}, id="suffix-and-tag"),
        pytest.param({"schema_prefix": "mvm_v2_"}, id="prefix-only"),
        pytest.param(json.dumps(_V3_MC), id="mc-as-json-string"),
    ],
)
@pytest.mark.parametrize("nested", [True, False], ids=["nested", "flat"])
def test_agent_parity(mc, nested):
    root = _scoped(mc, nested=nested)
    widgets, _ = _dispatch(_params(), _ws_json(root))
    assert _agent_convention_changed(widgets, root, "ridgeline_energy") is False
    old = _dev_widgets(_params())
    assert _agent_convention_changed(old, root, "ridgeline_energy") is True


def test_root_mc_ignored_when_model_dict_present():
    root = {
        "_vibe_scope": _SCOPE_BLOCK,
        "model_conventions": {**_V3_MC, "schema_prefix": "wrong_"},
        "model": {"model_conventions": _V3_MC},
    }
    widgets, _ = _dispatch(_params(), _ws_json(root))
    assert widgets["schema_prefix"] == "mvm_v2_"
    assert _agent_convention_changed(widgets, root, "ridgeline_energy") is False


# ---------------------------------------------------------------------------
# 5. Explicit request values, override path, ordinary files
# ---------------------------------------------------------------------------


class TestPrecedenceAndPaths:
    def test_explicit_prefix_differs_from_file(self):
        """Dispatch repeats the validate / create refusal (m7)."""
        params = _params(schema_prefix="custom_", explicit_convention_keys=["schema_prefix"])
        with pytest.raises(RuntimeError, match="uses the schema prefix 'mvm_v2_'. Installing with 'custom_'"):
            _dispatch(params, _ws_json(_scoped(_V3_MC)))

    def test_all_keys_explicit_is_request(self):
        keys = ["schema_prefix", "naming_convention", "primary_key_suffix", "table_id_type", "schema_suffix", "tag_prefix"]
        params = _params(explicit_convention_keys=keys)
        widgets, handle = _dispatch(params, _ws_json(_scoped({**_V3_MC, "schema_prefix": "mvm_"})))
        assert widgets["schema_prefix"] == "mvm_"
        assert handle.extra["conventions_source"] == "request"

    def test_the_context_file_candidate_is_the_file_read(self):
        override = "/Volumes/other_cat/_metamodel/vol_root/imports/abc/model.json"
        ws = _ws_json(_scoped(_V3_MC))
        widgets, _ = _dispatch(_params(context_file_candidates=[override]), ws)
        ws.files.download.assert_called_once_with(override)
        assert widgets["context_file"] == override
        assert widgets["schema_prefix"] == "mvm_v2_"

    def test_ordinary_file_is_read_and_byte_identical_to_dev(self):
        for root in (
            {"model": {"model_conventions": {**_V3_MC, "schema_prefix": "zzz_"}}},
            {"model_conventions": {**_V3_MC, "schema_prefix": "zzz_"}},
        ):
            params = _params()
            ws = _ws_json(root)
            widgets, handle = _dispatch(params, ws)
            assert ws.files.download.call_count == 1
            assert _no_sid(widgets) == _dev_widgets(params)
            assert list(_no_sid(widgets)) == list(_dev_widgets(params))
            assert "conventions_source" not in handle.extra

    def test_ordinary_dispatch_handle_matches_dev_dispatch(self):
        params = _params()
        widgets, handle = _dispatch(params, _ws_json({"model": {"model_conventions": _V3_MC}}))
        assert set(handle.extra) == _DEV_EXTRA_KEYS
        assert handle.extra["schema_prefix"] == "mvm_"
        assert _no_sid(widgets) == _dev_widgets(params)
        assert _no_sid(handle.dispatched_widgets) == _dev_widgets(params)

    def test_ordinary_handle_extra_matches_dev_keys(self):
        _, handle = _dispatch(_params(), _ws_json({"model": {}}))
        assert "conventions_source" not in handle.extra
        assert "explicit_convention_keys" not in handle.dispatched_widgets


# ---------------------------------------------------------------------------
# 6. Factory -> dispatch: an explicit tag_prefix/schema_suffix request
# ---------------------------------------------------------------------------


def _factory_params(*, import_source_path=None, **req_kw) -> dict:
    from vibe_modeling.backend.models import RunIn
    from vibe_modeling.backend.services.orchestrator.dag_factories._simple import (
        dag_for_install,
    )

    req = RunIn(intent="install", catalog="ridgeline_energy_vibe_model", cataloging_style="One Catalog", **req_kw)
    ctx = SimpleNamespace(
        parent_mv=SimpleNamespace(scope="mvm", version=3, import_source_path=import_source_path)
    )
    dag = dag_for_install(req, SimpleNamespace(name="ridgeline_energy"), ctx)
    return dict(dag.steps[0].params)


def test_factory_ui_request_end_to_end_fixes_v3():
    params = _factory_params()
    assert params["explicit_convention_keys"] == []
    root = _scoped(_V3_MC)
    widgets, _ = _dispatch(params, _ws_json(root))
    assert widgets["context_file"] == _V3_PATH
    assert widgets["schema_prefix"] == "mvm_v2_"
    assert _agent_convention_changed(widgets, root, "ridgeline_energy") is False


def test_explicit_request_tag_prefix_reaches_widget():
    params = _factory_params(tag_prefix="acme_", schema_suffix="_s")
    assert "tag_prefix" in params["explicit_convention_keys"]
    mc = {**_V3_MC, "tag_prefix": "file_", "schema_suffix": "_f"}
    widgets, _ = _dispatch(params, _ws_json(_scoped(mc)))
    assert widgets.get("tag_prefix") == "acme_"
    assert widgets.get("schema_suffix") == "_s"


# ---------------------------------------------------------------------------
# 7. Hung download, threads, concurrency
# ---------------------------------------------------------------------------


class TestHangAndConcurrency:
    def test_hung_download_capped_and_daemon(self, monkeypatch):
        from vibe_modeling.backend.services.operations import install as install_mod

        monkeypatch.setattr(install_mod, "REQUIRED_READ_TIMEOUT_S", 0.3)
        release = threading.Event()
        ws = _ws_bytes(None)
        ws.files.download.side_effect = lambda p: release.wait(30)
        params = _params()
        before = {t.ident for t in threading.enumerate()}
        t0 = time.monotonic()
        try:
            with pytest.raises(RuntimeError, match="couldn't read the model.json"):
                _dispatch(params, ws)
            elapsed = time.monotonic() - t0
            new = [t for t in threading.enumerate() if t.ident not in before]
            assert elapsed < 3
            assert new, "expected the worker to still be alive"
            assert all(t.daemon for t in new), [(t.name, t.daemon) for t in new]
        finally:
            release.set()

    def test_hung_contents_read_capped(self, monkeypatch):
        monkeypatch.setattr(ic, "_READ_TIMEOUT_S", 0.3)
        release = threading.Event()
        ws = _ws_bytes(None)
        ws.files.download.return_value.contents.read.side_effect = lambda n: release.wait(30)
        t0 = time.monotonic()
        try:
            assert ic.read_scoped_conventions(ws, _V3_PATH) is None
            assert time.monotonic() - t0 < 1.5
        finally:
            release.set()

    def test_cap_bounds_caller(self, monkeypatch):
        """The caller waits the full cap, then returns. The production cap
        is 15 s; the wait is measured against a patched 0.5 s cap so the
        suite does not sleep 15 s."""
        assert ic._READ_TIMEOUT_S == 15
        monkeypatch.setattr(ic, "_READ_TIMEOUT_S", 0.5)
        release = threading.Event()
        ws = _ws_bytes(None)
        ws.files.download.side_effect = lambda p: release.wait(60)
        t0 = time.monotonic()
        try:
            assert ic.read_scoped_conventions(ws, _V3_PATH) is None
            elapsed = time.monotonic() - t0
        finally:
            release.set()
        assert 0.45 <= elapsed < 2.0, elapsed

    def test_hung_worker_does_not_block_interpreter_exit(self):
        code = textwrap.dedent(
            f"""
            import sys, time
            sys.path.insert(0, {_APP_SRC!r})
            from unittest.mock import MagicMock
            from vibe_modeling.backend.services.operations import _install_conventions as ic
            ic._READ_TIMEOUT_S = 0.2
            ws = MagicMock()
            ws.files.download.side_effect = lambda p: time.sleep(120)
            assert ic.read_scoped_conventions(ws, "/x/model.json") is None
            print("returned")
            """
        )
        t0 = time.monotonic()
        out = subprocess.run([sys.executable, "-c", code], capture_output=True, text=True, timeout=60)
        assert out.returncode == 0, out.stderr[-2000:]
        assert "returned" in out.stdout
        assert time.monotonic() - t0 < 30

    def test_two_concurrent_dispatches_do_not_cross(self):
        barrier = threading.Barrier(2, timeout=10)

        def ws_for(prefix: str):
            ws = _ws_bytes(None)

            def _dl(path):
                barrier.wait()
                resp = MagicMock()
                resp.contents = io.BytesIO(json.dumps(_scoped({**_V3_MC, "schema_prefix": prefix})).encode())
                return resp

            ws.files.download.side_effect = _dl
            return ws

        results: dict = {}
        errors: list = []

        def run(name, prefix):
            try:
                params = install_mod.InstallParams(**_params())
                mc = ic.read_scoped_conventions(ws_for(prefix), _V3_PATH)
                eff, src = ic.apply_file_conventions(params, mc)
                results[name] = (eff.schema_prefix, src)
            except Exception as e:  # pragma: no cover
                errors.append(e)

        threads = [threading.Thread(target=run, args=("a", "aaa_")), threading.Thread(target=run, args=("b", "bbb_"))]
        for t in threads:
            t.start()
        for t in threads:
            t.join(20)
        assert not errors, errors
        assert results["a"] == ("aaa_", "file")
        assert results["b"] == ("bbb_", "file")

    def test_two_concurrent_full_dispatches(self):
        """Full ``Install.dispatch`` in two threads with one shared patch."""
        barrier = threading.Barrier(2, timeout=10)
        lock = threading.Lock()
        launched: list = []

        def _fake_launch_run(ws_, job_id, widget_params, *a, **k):
            with lock:
                launched.append(dict(widget_params))
            return 1

        def ws_for(prefix):
            ws = _ws_bytes(None)

            def _dl(path):
                barrier.wait()
                resp = MagicMock()
                resp.contents = io.BytesIO(json.dumps(_scoped({**_V3_MC, "schema_prefix": prefix})).encode())
                return resp

            ws.files.download.side_effect = _dl
            return ws

        handles: dict = {}

        def run(name, prefix):
            handles[name] = Install().dispatch(_ctx(_params()), ws_for(prefix), MagicMock())

        with patch(_LAUNCH, _fake_launch_run):
            ts = [threading.Thread(target=run, args=("a", "aaa_")), threading.Thread(target=run, args=("b", "bbb_"))]
            for t in ts:
                t.start()
            for t in ts:
                t.join(20)
        assert handles["a"].dispatched_widgets["schema_prefix"] == "aaa_"
        assert handles["b"].dispatched_widgets["schema_prefix"] == "bbb_"
        assert sorted(w["schema_prefix"] for w in launched) == ["aaa_", "bbb_"]


# ---------------------------------------------------------------------------
# 8. dispatched_widgets_json persisted by the runner
# ---------------------------------------------------------------------------


def test_effective_values_recorded_in_dispatched_widgets():
    widgets, handle = _dispatch(_params(), _ws_json(_scoped({**_V3_MC, "schema_suffix": "_s"})))
    recorded = json.loads(json.dumps(handle.dispatched_widgets))
    assert recorded == widgets
    assert recorded["schema_prefix"] == "mvm_v2_"
    assert recorded["schema_suffix"] == "_s"
    assert recorded["tag_prefix"] == "dbx_"


# ---------------------------------------------------------------------------
# 9. Install step dispatched without a pre-created version row
# ---------------------------------------------------------------------------

# A run started through ``Orchestrator.start`` (an install over an occupant)
# has no pre-created rows, so the install step dispatches with
# ``parent_version_id=None`` and the scoped-file read keys off the dispatched
# ``context_file`` only.


def test_install_step_fixture_file_parent_none():
    raw = _SCOPED_FIXTURE.read_bytes()
    ws = _ws_bytes(raw)
    widgets, handle = _dispatch(_factory_params(), ws, parent_version_id=None)
    ws.files.download.assert_called_once_with(_V3_PATH)
    assert widgets["schema_prefix"] == "mvm_v2_"
    assert handle.extra["conventions_source"] == "file"
    assert _agent_convention_changed(widgets, json.loads(raw), "ridgeline_energy") is False


def test_install_step_override_parent_none():
    src = "/Volumes/ridgeline_energy_vibe_model/_metamodel/vol_root/imports/q/model.json"
    ws = _ws_json(_scoped({**_V3_MC, "data_asset_naming_convention": "camelCase"}))
    widgets, _ = _dispatch(_factory_params(import_source_path=src), ws, parent_version_id=None)
    ws.files.download.assert_called_once_with(src)
    assert widgets["schema_prefix"] == "mvm_v2_"
    assert widgets["naming_convention"] == "camelCase"


def test_install_step_ordinary_matches_dev_parent_none():
    params = _factory_params(schema_prefix="mvm_")
    root = {"model": {"model_conventions": {**_V3_MC, "schema_prefix": "mvm_"}}}
    widgets, handle = _dispatch(params, _ws_json(root), parent_version_id=None)
    assert _no_sid(widgets) == _dev_widgets(params)
    assert "conventions_source" not in handle.extra


def test_uninstall_step_of_an_install_over_an_occupant_ignores_a_scoped_file():
    from vibe_modeling.backend.models import RunIn
    from vibe_modeling.backend.services.operations.uninstall import Uninstall
    from vibe_modeling.backend.services.orchestrator.dag_factories._simple import dag_for_install

    req = RunIn(intent="install", catalog="ridgeline_energy_vibe_model", cataloging_style="One Catalog")
    ctx = SimpleNamespace(
        parent_mv=SimpleNamespace(scope="mvm", version=3, import_source_path=None),
        occupant=SimpleNamespace(id="mv-4", scope="mvm", version=4),
        occupant_install_widgets=None,
    )
    dag = dag_for_install(req, SimpleNamespace(name="ridgeline_energy"), ctx)
    step = next(st for st in dag.steps if st.name == "uninstall")
    ws = _ws_json(_scoped(_V3_MC))
    captured: dict = {}

    def _fake_launch_run(ws_, job_id, widget_params, *a, **k):
        captured.update(widget_params)
        return 4242

    with patch("vibe_modeling.backend.services.operations.uninstall.launch_run", _fake_launch_run):
        Uninstall().dispatch(_ctx(dict(step.params), parent_version_id=None), ws, MagicMock())
    assert captured["schema_prefix"] == "mvm_"
    ws.files.download.assert_not_called()


# ---------------------------------------------------------------------------
# 10. Draft install of an unprefixed model (industry / kickstart), E-09
# ---------------------------------------------------------------------------

# Verbatim ``model.model_conventions`` of the agriculture industry model
# (lakehouse-industry-data-models data-models/agriculture/v1/mvm/model.json).
_INDUSTRY_MC = {
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


def _dispatch_version(params: dict, ws, *, dry_run: bool):
    """``Install.dispatch`` with the target version's ``dry_run`` flag."""
    captured: dict = {}

    def _fake_launch_run(ws_, job_id, widget_params, *a, **k):
        captured.update(widget_params)
        return 4242

    session = MagicMock()
    session.get.return_value = SimpleNamespace(dry_run=dry_run)
    with patch(_LAUNCH, _fake_launch_run):
        handle = Install().dispatch(_ctx(params), ws, session)
    return captured, handle


class TestUnprefixedDraftInstall:
    def test_scoped_kickstart_draft_sends_the_blank_prefix(self):
        root = _scoped(_INDUSTRY_MC)
        widgets, handle = _dispatch_version(_factory_params(), _ws_json(root), dry_run=True)
        assert widgets["schema_prefix"] == ""
        assert widgets["cataloging_style"] == "One Catalog"
        assert handle.extra["schema_prefix"] == ""
        assert handle.extra["conventions_source"] == "file"
        assert _agent_convention_changed(widgets, root, "ridgeline_energy") is False

    def test_unscoped_dry_run_draft_sends_the_blank_prefix(self):
        """A Dry Run draft's file is read whether or not it is scoped
        (``any_file``)."""
        root = {"model": {"model_conventions": _INDUSTRY_MC, "domains": []}}
        widgets, _ = _dispatch_version(_factory_params(), _ws_json(root), dry_run=True)
        assert widgets["schema_prefix"] == ""
        assert _agent_convention_changed(widgets, root, "ridgeline_energy") is False

    def test_an_unprefixed_file_sends_its_blank_prefix(self):
        """An industry downloaded before 0.9.0 (no ``_vibe_scope``, not a
        draft, its file unprefixed): the file decides, ``""`` is sent. A 0.9.0
        download's file carries ``ecm_`` / ``mvm_``."""
        params = _factory_params()
        assert params["prefix_from_version"] is True
        root = {"model": {"model_conventions": _INDUSTRY_MC, "domains": []}}
        widgets, handle = _dispatch_version(params, _ws_json(root), dry_run=False)
        assert _no_sid(widgets) == {**_dev_widgets(params), "schema_prefix": ""}
        assert handle.extra["conventions_source"] == "prefix"
        assert _agent_convention_changed(widgets, root, "ridgeline_energy") is False

    def test_a_named_file_prefix_is_sent(self):
        params = _factory_params()
        root = {"model": {"model_conventions": {**_INDUSTRY_MC, "schema_prefix": "acme_"}, "domains": []}}
        widgets, handle = _dispatch_version(params, _ws_json(root), dry_run=False)
        assert _no_sid(widgets) == {**_dev_widgets(params), "schema_prefix": "acme_"}
        assert handle.extra["conventions_source"] == "prefix"
        assert _agent_convention_changed(widgets, root, "ridgeline_energy") is False

    @pytest.mark.parametrize("scope,prefix", [("mvm", "mvm_"), ("ecm", "ecm_")])
    def test_a_prefixed_base_model_version_keeps_its_prefix(self, scope, prefix):
        """P0 ``wt_p0_grain_coop`` v1 ecm/mvm conventions."""
        from vibe_modeling.backend.models import RunIn
        from vibe_modeling.backend.services.orchestrator.dag_factories._simple import dag_for_install

        req = RunIn(intent="install", catalog="ridgeline_energy_vibe_model", cataloging_style="One Catalog")
        ctx = SimpleNamespace(parent_mv=SimpleNamespace(scope=scope, version=1, import_source_path=None))
        params = dict(dag_for_install(req, SimpleNamespace(name="ridgeline_energy"), ctx).steps[0].params)
        root = {"model": {"model_conventions": {**_INDUSTRY_MC, "schema_prefix": prefix}, "domains": []}}
        widgets, _ = _dispatch_version(params, _ws_json(root), dry_run=False)
        assert widgets["schema_prefix"] == prefix

    def test_an_unreadable_file_fails_the_step(self, caplog):
        params = _factory_params()
        ws = _ws_bytes(b"not json")
        with caplog.at_level(logging.WARNING):
            with pytest.raises(RuntimeError, match="couldn't read the model.json"):
                _dispatch_version(params, ws, dry_run=False)

    def test_an_explicit_prefix_other_than_the_files_is_refused(self):
        params = _factory_params(schema_prefix="mine_")
        assert params["schema_prefix"] == "mine_" and "prefix_from_version" not in params
        root = {"model": {"model_conventions": _INDUSTRY_MC, "domains": []}}
        with pytest.raises(RuntimeError, match="uses no schema prefix. Installing with 'mine_'"):
            _dispatch_version(params, _ws_json(root), dry_run=False)

    def test_the_files_own_prefix_typed_is_sent(self):
        params = _factory_params(schema_prefix="acme_")
        root = {"model": {"model_conventions": {**_INDUSTRY_MC, "schema_prefix": "acme_"}, "domains": []}}
        widgets, _ = _dispatch_version(params, _ws_json(root), dry_run=False)
        assert widgets["schema_prefix"] == "acme_"

    def test_a_recorded_install_prefix_does_not_decide(self):
        """The file decides, not an earlier install's prefix."""
        from vibe_modeling.backend.models import RunIn
        from vibe_modeling.backend.services.orchestrator.dag_factories._simple import dag_for_install

        req = RunIn(intent="install", catalog="ridgeline_energy_vibe_model", cataloging_style="One Catalog")
        ctx = SimpleNamespace(
            parent_mv=SimpleNamespace(scope="mvm", version=3, import_source_path=None),
            install_widgets={"schema_prefix": "acme_", "cataloging_style": "One Catalog"},
        )
        params = dict(dag_for_install(req, SimpleNamespace(name="ridgeline_energy"), ctx).steps[0].params)
        assert params["schema_prefix"] == "" and params["prefix_from_version"] is True
        assert "prefix_from_record" not in params
        install_mod.InstallParams(**params)

    def test_a_prefixed_base_model_draft_is_unchanged(self):
        """P0 business_3 v2 mvm conventions (``mvm_``)."""
        mc = {**_INDUSTRY_MC, "schema_prefix": "mvm_", "timestamp_format": "yyyy-MM-dd HH:mm:ss",
              "data_classification_levels": ""}
        root = _scoped(mc)
        widgets, _ = _dispatch_version(_factory_params(), _ws_json(root), dry_run=True)
        assert widgets["schema_prefix"] == "mvm_"
        assert _agent_convention_changed(widgets, root, "ridgeline_energy") is False

    def test_the_params_the_step_stores_still_validate(self):
        """``observe`` re-reads ``ctx.params``, which hold a blank prefix
        until dispatch reads the file."""
        params = _factory_params()
        assert params["schema_prefix"] == "" and "prefix_from_record" not in params
        install_mod.InstallParams(**params)
