"""Vibe scope and run type widget mapping tests.

Tests for the new vibe_scope and run_type widget parameters added to
support scoped vibe iterations and Dry Runs. Verifies:
- Widget defaults are unchanged for existing operations
- Scoped vibe iterations map vibe_scope="Some Domains" and business_domains correctly
- Dry Run operations map run_type="Dry Run"
- Both widget wrappers produce identical output
- The DAG factory forwards the fields to VibeIterateParams
"""
from types import SimpleNamespace

import pytest

from vibe_modeling.backend.job_launcher import map_run_params_to_widgets
from vibe_modeling.backend.services.operations._generation_common import (
    build_generation_widgets,
)
from vibe_modeling.backend.services.orchestrator.dag_factories._simple import (
    dag_for_vibe_iterate,
)


def _biz(name="Test Retail.", description="Test biz", industry_alignment="Retail"):
    return SimpleNamespace(
        name=name, description=description, industry_alignment=industry_alignment
    )


class TestWidgetDefaults:
    """Verify that default vibe_scope and run_type match agent defaults."""

    def test_default_vibe_scope_is_all_domains(self):
        """The default vibe_scope must be 'All Domains' (agent default)."""
        biz = _biz()
        out = map_run_params_to_widgets(
            operation="new base model",
            business=biz,
            catalog="test_cat",
            session_id="test_sid",
            runtime_budget_seconds=21600,
        )
        assert out["vibe_scope"] == "All Domains"

    def test_default_run_type_is_full_run(self):
        """The default run_type must be 'Full Run' (agent default)."""
        biz = _biz()
        out = map_run_params_to_widgets(
            operation="new base model",
            business=biz,
            catalog="test_cat",
            session_id="test_sid",
            runtime_budget_seconds=21600,
        )
        assert out["run_type"] == "Full Run"

    def test_defaults_unchanged_for_all_operations(self):
        """All existing operations should preserve defaults."""
        biz = _biz()
        operations = [
            "new base model",
            "shrink ecm",
            "enlarge mvm",
            "install model",
            "uninstall model version",
            "generate sample data",
            "revert model version",
        ]
        needs_version = {
            "install model", "uninstall model version",
            "generate sample data", "revert model version",
        }
        for op in operations:
            out = map_run_params_to_widgets(
                operation=op,
                business=biz,
                catalog="test_cat",
                session_id="test_sid",
                runtime_budget_seconds=21600,
                model_version="1" if op in needs_version else "",
            )
            assert out["vibe_scope"] == "All Domains", f"Failed for {op}"
            assert out["run_type"] == "Full Run", f"Failed for {op}"


class TestScopedVOVWidgets:
    """Verify that scoped vibe iterations map correctly."""

    def test_scoped_vov_has_some_domains_scope(self):
        """A scoped VOV must map vibe_scope='Some Domains'."""
        biz = _biz()
        out = map_run_params_to_widgets(
            operation="vibe modeling of version",
            business=biz,
            catalog="test_cat",
            session_id="test_sid",
            runtime_budget_seconds=21600,
            model_version="1",
            vibe_scope="Some Domains",
            business_domains="meter_to_cash, customer_service",
        )
        assert out["vibe_scope"] == "Some Domains"

    def test_scoped_vov_passes_business_domains(self):
        """A scoped VOV must include the business_domains list."""
        biz = _biz()
        domains = "meter_to_cash, customer_service"
        out = map_run_params_to_widgets(
            operation="vibe modeling of version",
            business=biz,
            catalog="test_cat",
            session_id="test_sid",
            runtime_budget_seconds=21600,
            model_version="1",
            vibe_scope="Some Domains",
            business_domains=domains,
        )
        assert out["business_domains"] == domains

    def test_both_wrappers_agree_on_scoped_vov(self):
        """The two wrappers must produce identical output for scoped VOVs."""
        biz = _biz()
        common_params = dict(
            operation="vibe modeling of version",
            business=biz,
            catalog="test_cat",
            session_id="test_sid",
            runtime_budget_seconds=21600,
            model_version="1",
            vibe_scope="Some Domains",
            business_domains="meter_to_cash",
            vibe_instructions="Test vibe",
            business_context_path="",
            business_description_override="",
            naming_convention="snake_case",
            primary_key_suffix="_id",
            schema_prefix="",
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
            classification_levels="",
            housekeeping_columns="No",
            history_tracking_columns="No",
        )
        out_jl = map_run_params_to_widgets(
            model_size="small model",
            **common_params
        )
        out_gc = build_generation_widgets(
            data_model_scopes="Minimum Viable Model - MVM",
            **common_params
        )
        assert out_jl == out_gc, (
            f"widget maps drifted: jl - gc = "
            f"{set(out_jl.items()) ^ set(out_gc.items())}"
        )


class TestDryRunWidgets:
    """Verify that Dry Run operations map correctly."""

    def test_dry_run_has_dry_run_type(self):
        """A Dry Run must map run_type='Dry Run'."""
        biz = _biz()
        out = map_run_params_to_widgets(
            operation="vibe modeling of version",
            business=biz,
            catalog="test_cat",
            session_id="test_sid",
            runtime_budget_seconds=21600,
            model_version="1",
            run_type="Dry Run",
        )
        assert out["run_type"] == "Dry Run"

    def test_both_wrappers_agree_on_dry_run(self):
        """The two wrappers must produce identical output for Dry Runs."""
        biz = _biz()
        common_params = dict(
            operation="vibe modeling of version",
            business=biz,
            catalog="test_cat",
            session_id="test_sid",
            runtime_budget_seconds=21600,
            model_version="1",
            run_type="Dry Run",
            vibe_instructions="Test vibe",
            business_context_path="",
            business_description_override="",
            naming_convention="snake_case",
            primary_key_suffix="_id",
            schema_prefix="",
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
        out_jl = map_run_params_to_widgets(
            model_size="small model",
            **common_params
        )
        out_gc = build_generation_widgets(
            data_model_scopes="Minimum Viable Model - MVM",
            **common_params
        )
        assert out_jl == out_gc, (
            f"widget maps drifted: jl - gc = "
            f"{set(out_jl.items()) ^ set(out_gc.items())}"
        )

    def test_dry_run_with_scope_maps_both(self):
        """A Dry Run with a scope must map both vibe_scope and run_type."""
        biz = _biz()
        out = map_run_params_to_widgets(
            operation="vibe modeling of version",
            business=biz,
            catalog="test_cat",
            session_id="test_sid",
            runtime_budget_seconds=21600,
            model_version="1",
            vibe_scope="Some Domains",
            business_domains="meter_to_cash",
            run_type="Dry Run",
        )
        assert out["vibe_scope"] == "Some Domains"
        assert out["run_type"] == "Dry Run"


class TestFactoryIntegration:
    """Verify that the DAG factory forwards scope and dry_run to params."""

    def test_dag_factory_forwards_vibe_scope(self):
        """The factory must forward vibe_scope to params."""
        req = SimpleNamespace(
            vibe_scope="some_domains",
            vibe_scope_domains=["meter_to_cash"],
            dry_run=False,
        )
        biz = SimpleNamespace(name="Test")
        dag = dag_for_vibe_iterate(req, biz)
        assert len(dag.steps) == 1
        params = dag.steps[0].params
        assert params.get("vibe_scope") == "some_domains"

    def test_dag_factory_forwards_vibe_scope_domains(self):
        """The factory must forward vibe_scope_domains to params."""
        req = SimpleNamespace(
            vibe_scope="some_domains",
            vibe_scope_domains=["meter_to_cash", "customer_service"],
            dry_run=False,
        )
        biz = SimpleNamespace(name="Test")
        dag = dag_for_vibe_iterate(req, biz)
        params = dag.steps[0].params
        assert params.get("vibe_scope_domains") == ["meter_to_cash", "customer_service"]

    def test_dag_factory_forwards_dry_run(self):
        """The factory must forward dry_run to params."""
        req = SimpleNamespace(
            vibe_scope="all_domains",
            vibe_scope_domains=[],
            dry_run=True,
        )
        biz = SimpleNamespace(name="Test")
        dag = dag_for_vibe_iterate(req, biz)
        params = dag.steps[0].params
        assert params.get("dry_run") is True

    def test_dag_factory_defaults_scope_fields(self):
        """The factory must provide defaults when fields are missing."""
        req = SimpleNamespace()
        biz = SimpleNamespace(name="Test")
        dag = dag_for_vibe_iterate(req, biz)
        params = dag.steps[0].params
        assert params.get("vibe_scope") == "all_domains"
        assert params.get("vibe_scope_domains") == []
        assert params.get("dry_run") is False
