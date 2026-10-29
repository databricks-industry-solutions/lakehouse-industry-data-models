"""Both wrappers must produce identical widget maps for the same logical input.

The two wrappers exist for historical reasons (different caller shapes).
After Phase 2 unification they delegate to core._widgets.build_widget_map.
This regression locks the contract: any future drift between them fails here.
"""
import re
from types import SimpleNamespace

import pytest

from vibe_modeling.backend.core._widgets import refresh_stored_widgets
from vibe_modeling.backend.job_launcher import map_run_params_to_widgets
from vibe_modeling.backend.models import BOOLEAN_FORMATS
from vibe_modeling.backend.services.operations._generation_common import (
    build_generation_widgets,
)

from ._source_scan import agent_notebook_source


def _biz(name="Test Retail.", description="Test biz", industry_alignment="Retail"):
    return SimpleNamespace(
        name=name, description=description, industry_alignment=industry_alignment
    )


@pytest.mark.parametrize(
    "model_size,expected_scopes",
    [
        ("small model", "Minimum Viable Model - MVM"),
        ("large model", "Expanded Coverage Model - ECM"),
    ],
)
def test_wrappers_produce_identical_widget_maps(model_size, expected_scopes):
    biz = _biz()
    common_params = dict(
        operation="new base model",
        catalog="vibe_modeling_test",
        session_id="abc-123",
        runtime_budget_seconds=21600,
        vibe_instructions="Limit to 10 products per domain",
        business_context_path="",
        business_description_override="",
        model_version="",
        naming_convention="snake_case",
        primary_key_suffix="_id",
        schema_prefix="ecm_",
        schema_suffix="",
        tag_prefix="dbx_",
        tag_suffix="",
        table_id_type="BIGINT",
        boolean_format="Boolean (True/False)",
        date_format="yyyy-MM-dd",
        timestamp_format="yyyy-MM-dd HH:mm:ss",
        cataloging_style="One Catalog",
        catalog_prefix="",
        catalog_suffix="",
        org_divisions="Operations",
        business_domains="customer, product, inventory, store",
        classification_levels="",
        housekeeping_columns="No",
        history_tracking_columns="No",
    )
    out_jl = map_run_params_to_widgets(
        business=biz, model_size=model_size, **common_params
    )
    out_gc = build_generation_widgets(
        business=biz, data_model_scopes=expected_scopes, **common_params
    )
    assert out_jl == out_gc, (
        f"widget maps drifted: jl - gc = "
        f"{set(out_jl.items()) ^ set(out_gc.items())}"
    )
    # Sanity: business_name uses agent's rule
    assert out_jl["business_name"] == "test_retail"
    assert out_jl["data_model_scopes"] == expected_scopes


def test_widget_map_includes_all_expected_keys():
    """Lock the schema — adding/removing widgets is a deliberate act."""
    biz = _biz()
    out = map_run_params_to_widgets(
        operation="new base model",
        business=biz,
        catalog="vibe_modeling_test",
        session_id="abc",
        runtime_budget_seconds=21600,
    )
    expected_keys = {
        "operation", "business_name", "business_description", "context_file",
        "deployment_catalog", "data_model_scopes",
        "model_vibes", "vibe_session_id", "industry_alignment",
        "business_domains", "org_divisions", "cataloging_style",
        "catalog_prefix", "catalog_suffix", "naming_convention",
        "primary_key_suffix", "schema_prefix", "schema_suffix",
        "tag_prefix", "tag_suffix", "table_id_type", "boolean_format",
        "date_format", "timestamp_format", "classification_levels",
        "housekeeping_columns", "history_tracking_columns",
        "vibe_scope", "run_type", "runtime_budget_seconds",
    }
    assert set(out) == expected_keys, (
        f"unexpected: {set(out) - expected_keys}, "
        f"missing: {expected_keys - set(out)}"
    )


def test_business_name_uses_agent_rule_edge_cases():
    """Trailing dot, hyphen, internal punctuation — agent_business_segment handles all."""
    cases = [
        ("Test Retail.", "test_retail"),
        ("Acme.Inc", "acme_inc"),
        ("7-eleven", "_7_eleven"),
    ]
    for name, expected in cases:
        out = map_run_params_to_widgets(
            operation="new base model",
            business=_biz(name=name),
            catalog="cat",
            session_id="s",
            runtime_budget_seconds=21600,
        )
        assert out["business_name"] == expected, (
            f"{name!r} -> expected {expected!r}, got {out['business_name']!r}"
        )


def _wrapper_params(**overrides) -> dict:
    """One logical input, in the keywords both wrappers take."""
    params = dict(
        operation="vibe modeling of version",
        business=_biz(),
        catalog="vibe_modeling_test",
        session_id="abc-123",
        runtime_budget_seconds=21600,
        vibe_instructions="x",
        business_context_path="",
        business_description_override="",
        model_version="3",
        naming_convention="snake_case",
        primary_key_suffix="_id",
        schema_prefix="ecm_",
        schema_suffix="",
        tag_prefix="dbx_",
        tag_suffix="",
        table_id_type="BIGINT",
        boolean_format="Boolean (True/False)",
        date_format="yyyy-MM-dd",
        timestamp_format="yyyy-MM-dd HH:mm:ss",
        cataloging_style="One Catalog",
        catalog_prefix="",
        catalog_suffix="",
        org_divisions="Operations",
        business_domains="",
        classification_levels="",
        housekeeping_columns="No",
        history_tracking_columns="No",
    )
    params.update(overrides)
    return params


def _both_wrappers(**overrides) -> tuple[dict[str, str], dict[str, str]]:
    """The widget map from each wrapper for the same logical input."""
    params = _wrapper_params(**overrides)
    jl = map_run_params_to_widgets(model_size="large model", **params)
    gc = build_generation_widgets(data_model_scopes="Expanded Coverage Model - ECM", **params)
    return jl, gc


# Values a stored run can carry into a retry: the agent's labels in any case,
# the agent's own legacy aliases (``_normalize_boolean_format_label``) and the
# labels earlier app forms sent ("Integer (1/0)", "String (Yes/No)").
@pytest.mark.parametrize(
    "value,label",
    [
        ("Boolean (True/False)", "Boolean (True/False)"),
        ("int (0/1)", "Int (0/1)"),
        ("String (Y/N)", "String (Y/N)"),
        ("tinyint", "Int (0/1)"),
        ("yes/no", "String (Y/N)"),
        ("Integer (1/0)", "Int (0/1)"),
        ("String (Yes/No)", "String (Y/N)"),
        ("", "Boolean (True/False)"),
        ("  ", "Boolean (True/False)"),
    ],
)
def test_both_wrappers_send_the_agent_boolean_label(value, label):
    jl, gc = _both_wrappers(boolean_format=value)
    assert jl["boolean_format"] == gc["boolean_format"] == label
    assert label in BOOLEAN_FORMATS


def test_unknown_boolean_format_fails_in_both_wrappers():
    """The agent would turn this into Boolean without a word; the app refuses it."""
    with pytest.raises(ValueError, match="boolean_format"):
        map_run_params_to_widgets(
            operation="new base model", business=_biz(), catalog="c", session_id="s",
            runtime_budget_seconds=21600, boolean_format="Maybe",
        )
    with pytest.raises(ValueError, match="boolean_format"):
        build_generation_widgets(
            operation="new base model", data_model_scopes="Expanded Coverage Model - ECM",
            business=_biz(), catalog="c", session_id="s", runtime_budget_seconds=21600,
            vibe_instructions="",
            business_context_path="", business_description_override="", model_version="",
            schema_prefix="", naming_convention="snake_case",
            primary_key_suffix="_id", schema_suffix="", tag_prefix="dbx_", tag_suffix="",
            table_id_type="BIGINT", boolean_format="Maybe", date_format="yyyy-MM-dd",
            timestamp_format="yyyy-MM-dd HH:mm:ss", cataloging_style="One Catalog",
            catalog_prefix="", catalog_suffix="", org_divisions="Operations",
            business_domains="", classification_levels="", housekeeping_columns="No",
            history_tracking_columns="No",
        )


def test_both_wrappers_send_the_runtime_budget_they_are_given():
    jl, gc = _both_wrappers()
    assert jl["runtime_budget_seconds"] == gc["runtime_budget_seconds"] == "21600"
    jl, gc = _both_wrappers(runtime_budget_seconds=36000)
    assert jl["runtime_budget_seconds"] == gc["runtime_budget_seconds"] == "36000"


@pytest.mark.parametrize("wrapper", ["map_run_params_to_widgets", "build_generation_widgets"])
def test_a_caller_that_passes_no_budget_fails(wrapper):
    """The budget has no default anywhere, so a missed caller fails loudly
    instead of sending a stale value."""
    params = _wrapper_params()
    del params["runtime_budget_seconds"]
    with pytest.raises(TypeError, match="runtime_budget_seconds"):
        if wrapper == "map_run_params_to_widgets":
            map_run_params_to_widgets(**params)
        else:
            build_generation_widgets(data_model_scopes="Expanded Coverage Model - ECM", **params)


def test_no_wrapper_sends_generate_samples():
    jl, gc = _both_wrappers()
    assert "generate_samples" not in jl and "generate_samples" not in gc


def test_refresh_brings_a_stored_map_to_the_builder_shape():
    """A pre-0.9.0 stored map: generate_samples dropped, the old form's label
    rewritten, the budget set from the hours given, everything else kept."""
    stored = {"operation": "new base model", "generate_samples": "10",
              "boolean_format": "String (Yes/No)", "date_format": "dd/MM/yyyy",
              "runtime_budget_seconds": "14400"}
    out = refresh_stored_widgets(stored, runtime_budget_hours=6)
    assert out == {"operation": "new base model", "boolean_format": "String (Y/N)",
                   "date_format": "dd/MM/yyyy", "runtime_budget_seconds": "21600"}
    assert "generate_samples" in stored, "the stored map is not mutated"


def test_refresh_drops_the_stored_hours_and_sends_them_as_seconds():
    """``runtime_budget_hours`` is the run's audit value, never a widget."""
    out = refresh_stored_widgets(
        {"operation": "new base model", "runtime_budget_hours": 10}, runtime_budget_hours=10,
    )
    assert out == {"operation": "new base model", "runtime_budget_seconds": "36000"}


def test_refresh_matches_the_builder_and_keeps_absent_keys_absent():
    jl, _ = _both_wrappers(boolean_format="tinyint")
    assert refresh_stored_widgets(jl, runtime_budget_hours=6) == jl
    assert "boolean_format" not in refresh_stored_widgets(
        {"operation": "install model"}, runtime_budget_hours=6,
    )
    with pytest.raises(ValueError, match="boolean_format"):
        refresh_stored_widgets({"boolean_format": "Maybe"}, runtime_budget_hours=6)


# --------------------------------------------------------------------------- #
# Pins to the vendored agent
# --------------------------------------------------------------------------- #

_WIDGET_DECL_RE = re.compile(r'dbutils\.widgets\.(?:text|dropdown|combobox|multiselect)\(\s*"(\w+)"')


# Keys the builder sends that the agent declares no widget for:
# ``runtime_budget_seconds`` is read as a job base parameter, and
# ``industry_alignment`` is not read from the widgets at all in 5.3.3 (it is
# not in ``_NOTEBOOK_WIDGET_NAMES``).
_UNDECLARED_KEYS = {"runtime_budget_seconds", "industry_alignment"}


def test_every_sent_widget_is_one_the_agent_declares():
    """A new key the agent does not declare (like the retired
    ``generate_samples``) fails here."""
    declared = set(_WIDGET_DECL_RE.findall(agent_notebook_source()))
    jl, _ = _both_wrappers()
    assert set(jl) - declared == _UNDECLARED_KEYS
    assert "runtime_budget_seconds" not in declared
    assert "generate_samples" not in declared


def test_agent_reads_a_positive_runtime_budget_in_seconds_defaulting_to_4h():
    """The agent's own fallback when no budget is sent (pinned on its literal,
    which is not the app's Settings default)."""
    src = agent_notebook_source()
    assert 'dbutils.widgets.get("runtime_budget_seconds")' in src
    assert "if _v294_w and int(_v294_w) > 0:" in src
    assert 'environ.get("DATABRICKS_TASK_TIMEOUT_SECONDS", "14400")' in src
