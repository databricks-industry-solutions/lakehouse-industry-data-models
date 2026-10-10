"""v5.1.4 feedback item 10: in 'vibe modeling of version' the base model's model_conventions win over convention widgets."""
import copy
import sys
from pathlib import Path

import pytest

sys.path.insert(0, str(Path(__file__).resolve().parent))
import v514_feedback_util as fu  # noqa: E402
from v514_feedback_util import ah  # noqa: E402
from notebook_source_util import slice_function_source  # noqa: E402

BASE_MC = fu.RAW["model"]["model_conventions"]
WARN = "[vov-base-conventions-win FIRED v5.1.4] convention widget values ignored"


@pytest.fixture(autouse=True)
def _isolate_runtime(monkeypatch):
    fu.inject_spark_types(monkeypatch)
    pinned = set(ah._USER_PINNED_DOMAINS_RUNTIME)
    yield
    ah.set_vibe_scope_runtime(None)
    ah._USER_PINNED_DOMAINS_RUNTIME.clear()
    ah._USER_PINNED_DOMAINS_RUNTIME.update(pinned)


def _widget_conventions(**overrides):
    return dict(copy.deepcopy(BASE_MC), **overrides)


def _vov(monkeypatch, fake, widget_mc, with_context=True, model_version="1", vibe_scope=None, business_domains="", raw=None):
    wv = fu.setup_widgets(fu.VOV, business_domains=business_domains, vibe_scope=vibe_scope, model_version=model_version)
    wv["business_context_data"]["model_conventions"] = widget_mc
    wv["_widget_raw_values"]["model_conventions"] = copy.deepcopy(widget_mc)
    if with_context:
        wv["business_context_raw"] = copy.deepcopy(raw or fu.RAW)
        wv["business_context_file_path"] = fu.model_json_path("inst_cat", "airlines", "1", "mvm")
    config = fu.run_setup(monkeypatch, wv, fake)
    return wv, config


def _error_log(config):
    return Path(config["LOCAL_ERROR_LOG_PATH"]).read_text()


def test_vov_base_conventions_win_over_widgets_with_one_warn(monkeypatch):
    fake = fu.register(fu.FakeSpark(), "inst_cat")
    wv, config = _vov(monkeypatch, fake, _widget_conventions(tag_prefix="zz_", primary_key_suffix="_key", data_asset_naming_convention="camelCase"))
    mc = config["MODEL_CONVENTIONS"]
    assert (mc["tag_prefix"], mc["primary_key_suffix"], mc["data_asset_naming_convention"]) == ("dbx_", "_id", BASE_MC["data_asset_naming_convention"])
    assert config["TAG_PREFIX"] == "dbx_"
    assert wv["has_convention_changes"] is False and wv["convention_changes"] == []
    warn = wv["_vov_conventions_override_warn"]
    for item in ("tag_prefix='zz_' (base 'dbx_')", "primary_key_suffix='_key' (base '_id')", "data_asset_naming_convention='camelCase'"):
        assert item in warn
    assert _error_log(config).count(WARN) == 1


def test_vov_widgets_fill_only_conventions_the_base_leaves_empty(monkeypatch):
    raw = copy.deepcopy(fu.RAW)
    raw["model"]["model_conventions"]["date_format"] = ""
    fake = fu.register(fu.FakeSpark(), "inst_cat", model=raw)
    wv, config = _vov(monkeypatch, fake, _widget_conventions(date_format="dd/MM/yyyy"), raw=raw)
    assert config["MODEL_CONVENTIONS"]["date_format"] == "dd/MM/yyyy"
    assert config["PROMPT_VARIABLES"]["date_format"] == "dd/MM/yyyy"
    assert "_vov_conventions_override_warn" not in wv


def test_vov_matching_widgets_emit_no_warning(monkeypatch):
    fake = fu.register(fu.FakeSpark(), "inst_cat")
    wv, config = _vov(monkeypatch, fake, _widget_conventions())
    assert "_vov_conventions_override_warn" not in wv
    assert WARN not in _error_log(config)
    assert any("[vov-base-conventions-win FIRED v5.1.4] base v1 model_conventions from business_context_raw" in s for s in wv["_vov_pending_sentinels"])


def test_vov_without_context_reads_the_registered_base_conventions(monkeypatch):
    stored = copy.deepcopy(fu.RAW)
    stored["model"]["model_conventions"]["primary_key_suffix"] = "_key"
    fake = fu.register(fu.FakeSpark(), "inst_cat", model=stored)
    wv, config = _vov(monkeypatch, fake, _widget_conventions(), with_context=False)
    assert config["MODEL_CONVENTIONS"]["primary_key_suffix"] == "_key"
    assert "primary_key_suffix='_id' (base '_key')" in wv["_vov_conventions_override_warn"]
    assert wv["has_convention_changes"] is False


def test_vov_with_an_empty_version_uses_the_latest_completed_version(monkeypatch):
    v3 = copy.deepcopy(fu.RAW)
    v3["model"]["model_conventions"]["tag_prefix"] = "v3_"
    fake = fu.register(fu.FakeSpark(), "inst_cat", version="1")
    fu.register(fake, "inst_cat", version="3", model=v3)
    wv, config = _vov(monkeypatch, fake, _widget_conventions(), with_context=False, model_version="")
    assert wv["base_version_for_review"] == "3"
    assert config["MODEL_CONVENTIONS"]["tag_prefix"] == "v3_" and config["TAG_PREFIX"] == "v3_"


def test_vov_bootstrap_without_registry_reads_the_newest_volume_model(monkeypatch, tmp_path):
    volume = fu.VolumeRedirect(monkeypatch, tmp_path)
    v2 = fu.small_model("v2_mvm")
    v2["model"]["model_conventions"] = dict(copy.deepcopy(BASE_MC), tag_prefix="vol_")
    volume.put(fu.model_json_path("inst_cat", "airlines", "1", "mvm"), fu.small_model("v1_mvm"))
    volume.put(fu.model_json_path("inst_cat", "airlines", "2", "mvm"), v2)
    wv, config = _vov(monkeypatch, fu.FakeSpark(), _widget_conventions(), with_context=False, model_version="")
    assert wv["base_version_for_review"] == "2"
    assert config["MODEL_CONVENTIONS"]["tag_prefix"] == "vol_"


def test_scoped_vov_keeps_base_conventions_exactly(monkeypatch):
    raw = copy.deepcopy(fu.RAW)
    raw["model"]["model_conventions"]["date_format"] = ""
    fake = fu.register(fu.FakeSpark(), "inst_cat", model=raw)
    wv, config = _vov(monkeypatch, fake, _widget_conventions(date_format="dd/MM/yyyy"), raw=raw, vibe_scope="Some Domains", business_domains="crew")
    assert config["MODEL_CONVENTIONS"]["date_format"] == ""
    assert "date_format='dd/MM/yyyy' (base '')" in wv["_vov_conventions_override_warn"]
    assert isinstance(ah.get_vibe_scope_runtime(), ah.VibeScopeFence)


def test_unscoped_vov_still_applies_a_convention_edit_in_the_base_model_json(monkeypatch):
    fake = fu.register(fu.FakeSpark(), "inst_cat")
    edited = copy.deepcopy(fu.RAW)
    edited["model"]["model_conventions"]["schema_prefix"] = "edited_"
    wv, config = _vov(monkeypatch, fake, _widget_conventions(), raw=edited)
    assert config["MODEL_CONVENTIONS"]["schema_prefix"] == "edited_"
    assert wv["has_convention_changes"] is True
    assert [c["convention"] for c in wv["convention_changes"]] == ["schema_prefix"]


def test_scoped_vov_warns_and_drops_a_model_wide_convention_change(monkeypatch):
    fake = fu.register(fu.FakeSpark(), "inst_cat")
    edited = copy.deepcopy(fu.RAW)
    edited["model"]["model_conventions"]["schema_prefix"] = "edited_"
    wv, config = _vov(monkeypatch, fake, _widget_conventions(schema_prefix="edited_"), raw=edited, vibe_scope="Some Domains", business_domains="crew")
    assert wv["has_convention_changes"] is False and wv["convention_changes"] == []
    assert "[vibe-scope-convention-mismatch FIRED v5.1.4]" in _error_log(config)
    assert "these convention changes are NOT applied" in _error_log(config)


def test_new_base_model_widgets_still_win(monkeypatch):
    wv = fu.setup_widgets(fu.NEW_BASE)
    wv["business_context_data"]["model_conventions"] = _widget_conventions(tag_prefix="zz_")
    wv["_widget_raw_values"]["model_conventions"] = _widget_conventions(tag_prefix="zz_")
    config = fu.run_setup(monkeypatch, wv, fu.FakeSpark())
    assert config["TAG_PREFIX"] == "zz_"
    assert "_vov_base_conventions" not in wv and "_vov_conventions_override_warn" not in wv


def test_base_wins_helper_semantics():
    conventions = {"tag_prefix": "zz_", "boolean_format": "Boolean (True/False)", "date_format": "dd/MM/yyyy"}
    overridden = ah._vov_base_conventions_win({"tag_prefix": "dbx_", "boolean_format": "boolean", "date_format": ""}, conventions)
    assert [o["convention"] for o in overridden] == ["tag_prefix"]
    assert conventions["tag_prefix"] == "dbx_" and conventions["date_format"] == "dd/MM/yyyy"
    assert conventions["boolean_format"] == ah._normalize_boolean_format_label("boolean")
    exact = {"date_format": "dd/MM/yyyy"}
    assert [o["convention"] for o in ah._vov_base_conventions_win({"date_format": ""}, exact, exact=True)] == ["date_format"]
    assert exact["date_format"] == ""
    assert ah._vov_base_conventions_win(None, {}) is None


def test_get_widget_values_uses_base_wins_for_the_no_vibes_convention_check():
    src = fu.nested_main_function("get_widget_values")
    assert "_vov_base_conventions_win(_vibe_scope_model_conventions(_context_file_data) or old_conventions, new_conventions)" in src
    assert 'if _mc_overrides and _prefer_widget_value(w_operation, uc.get("operation", "")) != "vibe modeling of version":' in src
    assert "base_model=" not in src


def test_setup_resolves_base_conventions_before_the_convention_derivations():
    body = slice_function_source("step_setup_and_clean")
    win = body.index("_vov_conv_overridden = _vov_base_conventions_win(")
    assert win < body.index('_gen_tag_prefix = model_conventions.get("tag_prefix", "")')
    assert win < body.index('raw_classification_levels = model_conventions.get("data_classification_levels", "")')
    assert win < body.index('"MODEL_CONVENTIONS": model_conventions,')
