"""Regression baseline tests — capture API response shapes as snapshots.

These tests verify the structure (keys, types, nesting) of API responses.
If a future change alters a response shape, these tests fail, requiring
explicit review of the change. This is the "did I accidentally break the
API contract?" safety net.

Note: These test response *structure*, not specific values. Value assertions
are in the unit and flow tests.
"""

import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "..", "src", "app", "src"))
sys.path.insert(0, os.path.dirname(__file__))

import json

import pytest
from sqlmodel import Session, select

from _test_app import make_test_app
from vibe_modeling.backend.db_models import (
    AgentConfig,
    Attribute,
    Business,
    BusinessContext,
    Domain,
    ModelVersion,
    Product,
    Run,
    RunProgressEvent,
)


@pytest.fixture
def seeded_app(engine):
    """Seed a complete application state for regression testing."""
    with Session(engine) as session:
        # Agent config
        ac = AgentConfig(
            notebook_path="/Workspace/test/notebook",
            job_id=99,
            job_name="test_vibe_job",
            deployment_catalog="test_metamodel_catalog",
        )
        session.add(ac)

        # Business
        b = Business(
            name="Regression Corp",
            description="For regression testing",
            industry_alignment="Technology",
        )
        session.add(b)
        session.flush()

        # Context
        ctx = BusinessContext(
            business_id=b.id,
            version_label="v1.0",
            context_json=json.dumps({
                "business_context": {
                    "business_information": {
                        "business": "Regression Corp",
                        "description": "For regression testing",
                        "industry_alignment": "Technology",
                        "core_business_processes": "Testing",
                        "orgnaization_divisions": "Engineering",
                        "data_domains": "Core",
                        "common_business_jargons": "",
                        "operational_systems_of_records": "",
                        "industry_governing_body": "",
                    },
                    "model_conventions": {"pk_suffix": "_id"},
                }
            }),
            conventions_json="{}",
        )
        session.add(ctx)

        # Model version
        mv = ModelVersion(business_id=b.id, version=1, scope="mvm", status="completed")
        session.add(mv)
        session.flush()

        # Domain + Product + Attributes
        d = Domain(
            version_id=mv.id, name="core", division="Engineering",
            description="Core domain", database_name="core_db",
        )
        session.add(d)
        session.flush()

        p = Product(
            version_id=mv.id, domain_id=d.id, name="widget",
            table_name="widget", description="Widget records",
            type="Master", primary_key="widget_id",
        )
        session.add(p)
        session.flush()

        session.add(Attribute(
            product_id=p.id, name="widget_id", column_name="widget_id",
            type="BIGINT", description="PK",
        ))

        # Run with progress events
        run = Run(
            business_id=b.id,
            intent="new-base-model",
            status="completed",
            databricks_run_id=12345,
            vibe_session_id="test-session",
            progress_percent=100,
            progress_message="Complete",
            parameters_json='{"operation": "new base model"}',
        )
        session.add(run)
        session.flush()

        event = RunProgressEvent(
            run_id=run.id,
            step_id=1,
            event_seq=1,
            stage_name="Pipeline",
            step_name="Generate",
            status="completed",
            message="Done",
            progress_increment=100.0,
            result_json="{}",
        )
        session.add(event)

        session.commit()
        return {
            "business_id": b.id,
            "version_id": mv.id,
            "version_int": mv.version,
            "scope": mv.scope,
            "run_id": run.id,
        }


# ---------------------------------------------------------------------------
# Response shape assertions
# ---------------------------------------------------------------------------


def _assert_keys(data: dict, required_keys: set, msg: str = ""):
    """Assert that data contains exactly the required keys."""
    actual = set(data.keys())
    missing = required_keys - actual
    extra = actual - required_keys
    assert not missing, f"{msg} Missing keys: {missing}"
    assert not extra, f"{msg} Unexpected keys: {extra}"


class TestBusinessResponseShape:
    EXPECTED_KEYS = {
        "id", "name", "description", "business_vibes", "industry_alignment",
        "kind", "sector_id", "source_industry_id", "source_version",
        "source_repo_path", "business_domains", "org_divisions",
        "created_at", "updated_at",
    }
    LIST_KEYS = {
        "id", "name", "industry_alignment", "kind", "sector_id",
        "source_industry_id", "source_version",
        "model_count", "downloaded_scopes", "created_at",
    }

    def test_business_detail_shape(self, client, seeded_app):
        resp = client.get(f"/api/businesses/{seeded_app['business_id']}")
        assert resp.status_code == 200
        _assert_keys(resp.json(), self.EXPECTED_KEYS, "BusinessOut")

    def test_business_list_shape(self, client, seeded_app):
        resp = client.get("/api/businesses")
        assert resp.status_code == 200
        items = resp.json()
        assert len(items) > 0
        _assert_keys(items[0], self.LIST_KEYS, "BusinessListOut")

    # M2: create/update now return an OBJECT detail on a name clash (was a
    # plain string). Pin the object shape so it can't silently regress.
    NAME_CONFLICT_DETAIL_KEYS = {"error", "name", "message"}

    def test_create_name_conflict_detail_shape(self, client):
        assert client.post(
            "/api/businesses", json={"name": "Shape Co", "description": "d"}
        ).status_code == 200
        resp = client.post("/api/businesses", json={"name": "shape_co", "description": "d"})
        assert resp.status_code == 409, resp.text
        detail = resp.json()["detail"]
        assert isinstance(detail, dict)
        _assert_keys(detail, self.NAME_CONFLICT_DETAIL_KEYS, "create 409 detail")
        assert detail["error"] == "business_name_taken"

    def test_update_name_conflict_detail_shape(self, client):
        client.post("/api/businesses", json={"name": "Shape Co", "description": "d"})
        other = client.post(
            "/api/businesses", json={"name": "Other Co", "description": "d"}
        ).json()
        resp = client.put(
            f"/api/businesses/{other['id']}", json={"name": "shape_co", "description": "d"}
        )
        assert resp.status_code == 409, resp.text
        detail = resp.json()["detail"]
        assert isinstance(detail, dict)
        _assert_keys(detail, self.NAME_CONFLICT_DETAIL_KEYS, "update 409 detail")
        assert detail["error"] == "business_name_taken"


class TestModelVersionOutProvenanceShape:
    """v_0_7_0: ModelVersionOut gains agent_version/release_version — additive,
    both optional and defaulting to None so existing clients stay valid."""

    def test_new_fields_present_and_optional(self):
        from vibe_modeling.backend.models import ModelVersionOut

        fields = ModelVersionOut.model_fields
        assert "agent_version" in fields
        assert "release_version" in fields
        # Additive: optional with a None default, so a payload without them
        # still validates.
        assert fields["agent_version"].default is None
        assert fields["release_version"].default is None
        out = ModelVersionOut.model_validate(
            {
                "id": "v1",
                "business_id": "b1",
                "version": 1,
                "status": "completed",
                "deployment_status": "draft",
                "base_version_id": None,
                "vibe_instructions": "",
                "context_id": None,
                "confidence_score": None,
                "uc_catalog": "",
                "completion_date": None,
                "created_at": "2026-01-01T00:00:00Z",
            }
        )
        assert out.agent_version is None
        assert out.release_version is None


class TestVersionLifecycleShape:
    """v_0_9_0: the versions list carries the lifecycle fields, the derived
    ``is_head`` / ``draft_state`` filled by the list route, and IssueOut
    gains ``subject``."""

    VERSION_KEYS = {
        "id", "business_id", "version", "status", "deployment_status", "base_version_id",
        "vibe_instructions", "context_id", "confidence_score", "scope", "uc_catalog",
        "completion_date", "sync_state", "sync_error_text", "import_source_path", "imported_at",
        "agent_version", "release_version", "dry_run", "promoted_at", "promoted_by_run_id",
        "replaced_by_version_id", "replaced_at", "files_catalog", "scope_fence_mode", "is_head",
        "draft_state", "linked_run_id", "is_imported", "created_at",
    }

    def test_list_versions_shape(self, client, seeded_app):
        resp = client.get(f"/api/businesses/{seeded_app['business_id']}/versions")
        assert resp.status_code == 200
        (item,) = resp.json()
        _assert_keys(item, self.VERSION_KEYS, "ModelVersionOut")
        assert item["dry_run"] is False
        assert item["is_head"] is True and item["draft_state"] is None
        assert item["linked_run_id"] is None
        assert item["is_imported"] is False

    def test_issue_out_fields(self):
        from vibe_modeling.backend.models import IssueOut

        assert set(IssueOut.model_fields) == {"field_path", "step_index", "message", "severity", "subject", "versions"}


class TestAddendumWireShapes:
    """v_0_9_0_1 addendum: the delete responses carry the cleanup summary and the
    reopened-feedback count; the delete starts no run, so ``run_id`` and
    ``reinstall_dispatched`` are gone. ``BusinessDeleteOut`` is the response of
    ``DELETE /businesses/{id}``; its shape is locked on the model here and on the
    route in ``test_drift_delete_business.py``."""

    def test_delete_version_out_fields(self):
        from vibe_modeling.backend.models import DeleteVersionOut

        assert set(DeleteVersionOut.model_fields) == {
            "deleted_version", "previous_version",
            "metamodel_rows_cleaned", "metamodel_cleanup", "reopened_input_count", "message",
        }

    def test_business_delete_out_fields(self):
        from vibe_modeling.backend.models import BusinessDeleteOut, MetamodelCleanupSummaryOut

        assert set(BusinessDeleteOut.model_fields) == {"ok", "cascaded", "metamodel_cleanup"}
        assert set(MetamodelCleanupSummaryOut.model_fields) == {"done", "pending", "failed"}

    def test_metamodel_cleanup_out_fields(self):
        from vibe_modeling.backend.models import MetamodelCleanupOut

        assert set(MetamodelCleanupOut.model_fields) == {
            "id", "business_segment", "version", "scope", "catalog", "reason", "status",
            "attempts", "last_error", "updated_at",
        }


class TestImportScopeShapes:
    """The import dialogs' analyze reports the scope and the prefixes; both
    execute bodies take the user's ECM / MVM choice."""

    def test_analyze_out_fields(self):
        from vibe_modeling.backend.models import ImportAnalyzeOut

        fields = ImportAnalyzeOut.model_fields
        assert {"inferred_scope", "agent_output", "file_schema_prefix", "import_schema_prefix"} <= set(fields)
        out = ImportAnalyzeOut(valid=True, inferred_version="modern", action="import_as_is", message="ok")
        assert (out.inferred_scope, out.agent_output, out.file_schema_prefix, out.import_schema_prefix) == (
            None, False, None, None,
        )

    def test_execute_bodies_take_a_scope(self):
        from pydantic import ValidationError

        from vibe_modeling.backend.models import ImportCreateBusinessAndExecuteIn, ImportExecuteIn

        for model in (ImportExecuteIn, ImportCreateBusinessAndExecuteIn):
            assert model(volume_path="/Volumes/c/s/v/model.json").scope is None
            assert model(volume_path="/Volumes/c/s/v/model.json", scope="mvm").scope == "mvm"
            with pytest.raises(ValidationError):
                model(volume_path="/Volumes/c/s/v/model.json", scope="both")


class TestIndustryScopePrefixesShape:
    """``applyIndustryScopePrefixes`` answers the industry and one row per
    version; ``install/fix_industry_prefixes.py`` reads these keys."""

    def test_out_fields(self):
        from vibe_modeling.backend.models import IndustryScopePrefixesOut, IndustryScopePrefixRowOut

        assert set(IndustryScopePrefixesOut.model_fields) == {"business_id", "business_name", "applied", "rows"}
        assert set(IndustryScopePrefixRowOut.model_fields) == {
            "version_id", "version", "scope", "action", "reason", "warnings",
        }

    def test_in_fields(self):
        from vibe_modeling.backend.models import IndustryScopePrefixesIn

        assert set(IndustryScopePrefixesIn.model_fields) == {"apply"}


class TestUninstallImpactShape:
    """``getUninstallImpact``: the version's schemas found in the catalog with
    their tables, views and volumes. ``mvm_core_db`` exists with one empty
    table; the version's other name forms do not."""

    IMPACT_KEYS = {
        "version_id", "catalog", "schemas", "has_data", "truncated", "reasons", "installed_catalogs",
    }
    SCHEMA_KEYS = {
        "name", "owner", "shared", "objects_listed", "tables", "views", "volumes", "other_versions",
    }
    TABLE_KEYS = {"name", "kind", "has_data"}

    def test_uninstall_impact_shape(self, client, seeded_app, mock_ws, engine):
        from types import SimpleNamespace

        from _sql_fakes import response
        from vibe_modeling.backend.services.uninstall_impact import IMPACT_CACHE

        IMPACT_CACHE.clear()
        with Session(engine) as session:
            cfg = session.exec(select(AgentConfig)).one()
            cfg.warehouse_id = "wh-regression"
            session.add(cfg)
            session.commit()
        mock_ws.schemas.list.side_effect = lambda **_kw: iter(
            [SimpleNamespace(name="mvm_core_db", owner="app-sp")]
        )
        mock_ws.statement_execution.execute_statement.side_effect = [
            response([["mvm_core_db", "widget", "MANAGED"]], columns=["s", "n", "k"]),
            response([["0", "0"]], columns=["i", "n"]),
        ]
        bid, vid = seeded_app["business_id"], seeded_app["version_id"]
        resp = client.get(
            f"/api/businesses/{bid}/versions/{vid}/uninstall-impact?catalog=regression_cat"
        )
        assert resp.status_code == 200, resp.text
        body = resp.json()
        _assert_keys(body, self.IMPACT_KEYS, "UninstallImpactOut")
        assert body["has_data"] == "no" and body["truncated"] is False
        (schema,) = body["schemas"]
        _assert_keys(schema, self.SCHEMA_KEYS, "UninstallImpactSchemaOut")
        (table,) = schema["tables"]
        _assert_keys(table, self.TABLE_KEYS, "UninstallImpactTableOut")
        IMPACT_CACHE.clear()


class TestRunDefaultsShape:
    """``getRunDefaults``: every pre-filled field with its value, source and
    locks. The seeded version's file cannot be read here, so the locked
    fields are unknown."""

    FIELD_KEYS = {"value", "source", "locked", "locked_scoped"}

    def test_run_defaults_shape(self, client, seeded_app, mock_ws):
        mock_ws.files.download.side_effect = FileNotFoundError("no file")
        bid, vid = seeded_app["business_id"], seeded_app["version_id"]
        resp = client.get(f"/api/businesses/{bid}/model-versions/{vid}/run-defaults")
        assert resp.status_code == 200, resp.text
        body = resp.json()
        _assert_keys(body, {"base_version_id", "file_read", "fields"}, "RunDefaultsOut")
        assert body["file_read"] is False
        assert set(body["fields"]) == {
            "naming_convention", "primary_key_suffix", "schema_prefix", "schema_suffix",
            "tag_prefix", "tag_suffix", "table_id_type", "boolean_format", "date_format",
            "timestamp_format", "classification_levels", "catalog_prefix", "catalog_suffix",
            "org_divisions", "housekeeping_columns", "history_tracking_columns",
        }
        for name, field in body["fields"].items():
            _assert_keys(field, self.FIELD_KEYS, f"RunDefaultFieldOut {name}")


class TestOobResponseShapes:
    """``getOobSummary`` / ``checkOobNow`` and the two out-of-band imports."""

    def test_summary_fields(self):
        from vibe_modeling.backend.models import OobBusinessOut, OobSummaryOut, OobVersionOut

        assert set(OobSummaryOut.model_fields) == {
            "checked_at", "catalog", "skipped_reason", "businesses", "checking",
        }
        assert set(OobBusinessOut.model_fields) == {
            "business_segment", "status", "business_id", "candidate_business_ids", "versions",
        }
        assert set(OobVersionOut.model_fields) == {"version", "scope", "refused_reason"}

    def test_import_fields(self):
        from vibe_modeling.backend.models import OobImportOut

        assert set(OobImportOut.model_fields) == {"imported_versions", "created_business_ids", "warnings"}

    def test_summary_route_shape(self, client, engine):
        from vibe_modeling.backend.db_models import AgentConfig

        with Session(engine) as s:
            s.add(AgentConfig(notebook_path="/nb", job_id=1, deployment_catalog="", warehouse_id=""))
            s.commit()
        resp = client.get("/api/oob/summary")
        assert resp.status_code == 200
        assert set(resp.json()) == {"checked_at", "catalog", "skipped_reason", "businesses", "checking"}


class TestPublishResponseShape:
    """The publish endpoint response gains ``target_path`` (the resolved bundle
    root used) alongside the branch/PR fields (ADR D-049)."""

    EXPECTED_KEYS = {"branch", "pr_number", "pr_url", "files", "target_path"}

    def test_publish_out_model_fields(self):
        from vibe_modeling.backend.routes.industry_models import (
            PublishModelVersionOut,
        )

        assert set(PublishModelVersionOut.model_fields) == self.EXPECTED_KEYS


class TestRunResponseShape:
    EXPECTED_KEYS = {
        "id", "business_id", "version_id", "status",
        "databricks_run_id", "vibe_session_id", "run_page_url",
        "progress_percent", "progress_message", "error_message",
        "parameters_json", "vibe_instructions_text",
        "vibe_instructions_volume_path",
        # Migration 0.2.0: the user-typed business context the run was
        # created with. Empty string for legacy runs and ops that don't
        # carry user-typed context (revert, import, install, etc.).
        "business_context_text",
        "started_at", "completed_at", "created_at",
        # Phase 4 (orchestrator refactor §8): durable label set on
        # the Run row at create time. Empty string for legacy runs.
        "intent",
        # D-09 watchdog signals (plan task #51): two persisted fields
        # (last_jobs_api_state, last_poll_error) and three derived fields
        # (watchdog_state, watchdog_warm_up_seconds_remaining,
        # elapsed_seconds). All five are required on RunOut.
        "watchdog_state", "watchdog_warm_up_seconds_remaining",
        "last_jobs_api_state", "last_poll_error", "elapsed_seconds",
        # Phase 4 (orchestrator design §2.4 + §8): validator warnings
        # echoed back on POST /runs and surfaced on GET /runs/{id} as
        # an empty list when no warnings were produced at create time.
        "warnings",
        # v0.4.0 #4b: agent-emitted Version Resolution events for this
        # run (auto-collision-resolved). Empty list on the happy path;
        # derived from the run's RunProgressEvent rows.
        "version_resolutions",
        # v_0_9_0_1: set only on runs recorded by linking an imported
        # version to its Databricks run; null on app-launched runs.
        "linked_at", "link_evidence",
    }

    def test_run_detail_shape(self, client, seeded_app):
        bid = seeded_app["business_id"]
        resp = client.get(f"/api/businesses/{bid}/runs/{seeded_app['run_id']}")
        assert resp.status_code == 200
        _assert_keys(resp.json(), self.EXPECTED_KEYS, "RunOut")
        assert resp.json()["linked_at"] is None and resp.json()["link_evidence"] is None


class TestRunReportShape:
    """getRunReport / getVersionReport (v0.9.0 per-feedback run report)."""

    EXPECTED_KEYS = {
        "run_id", "business_id", "intent", "run_status", "output_version_id",
        "dry_run", "consume_note", "has_agent_report", "has_input_outcomes",
        "version_mismatch", "expected_version", "fetched_version",
        "lineage_base_version", "lineage_head_at_write", "lineage_stale",
        "unmatched_outcome_count", "items",
    }
    ITEM_KEYS = {
        "input_id", "outcome_status", "outcome_reason", "outcome_target",
        "created_at", "text", "origin", "priority", "status", "consumed",
        "consumed_by_run_id", "selected_for_run",
    }

    def test_run_report_shape(self, client, seeded_app, engine):
        from vibe_modeling.backend.db_models import RunInputLink, VibeInput

        bid, run_id = seeded_app["business_id"], seeded_app["run_id"]
        with Session(engine) as s:
            vi = VibeInput(business_id=bid, text="one")
            s.add(vi)
            s.flush()
            s.add(RunInputLink(run_id=run_id, input_id=vi.id))
            s.commit()
        resp = client.get(f"/api/businesses/{bid}/runs/{run_id}/report")
        assert resp.status_code == 200
        data = resp.json()
        _assert_keys(data, self.EXPECTED_KEYS, "RunReportOut")
        _assert_keys(data["items"][0], self.ITEM_KEYS, "RunReportItemOut")

    def test_version_report_shape(self, client, seeded_app):
        bid, vid = seeded_app["business_id"], seeded_app["version_id"]
        resp = client.get(f"/api/businesses/{bid}/versions/{vid}/report")
        assert resp.status_code == 200
        _assert_keys(resp.json(), {"version_id", "report"}, "VersionReportOut")


class TestRunChangesShape:
    """getRunChanges / setRunChangeDecisions (v0.9.0 run change review)."""

    EXPECTED_KEYS = {"run_id", "version_id", "base_version_id", "decisions_open", "changes"}
    CHANGE_KEYS = {
        "element_kind", "element_path", "change_kind", "change_class",
        "decision", "decided_by", "decided_at", "feedback_input_id",
    }

    def _seed_vibe(self, engine, bid):
        from vibe_modeling.backend.db_models import Domain, ModelVersion, Run, RunOperation

        with Session(engine) as s:
            base = ModelVersion(business_id=bid, version=7, scope="ecm", status="completed")
            s.add(base)
            s.flush()
            out = ModelVersion(business_id=bid, version=8, scope="ecm", status="completed",
                               base_version_id=base.id)
            s.add(out)
            s.flush()
            s.add(Domain(version_id=base.id, name="Sales"))
            s.add(Domain(version_id=out.id, name="Sales"))
            s.add(Domain(version_id=out.id, name="Billing"))
            run = Run(business_id=bid, intent="vibe-iterate", status="completed")
            s.add(run)
            s.flush()
            s.add(RunOperation(run_id=run.id, step_index=0, operation_name="vibe_iterate",
                               status="succeeded", parent_version_id=base.id,
                               output_version_id=out.id))
            s.commit()
            return run.id

    def test_run_changes_shape(self, client, seeded_app, engine):
        bid = seeded_app["business_id"]
        run_id = self._seed_vibe(engine, bid)
        resp = client.get(f"/api/businesses/{bid}/runs/{run_id}/changes")
        assert resp.status_code == 200, resp.text
        data = resp.json()
        _assert_keys(data, self.EXPECTED_KEYS, "RunChangesOut")
        _assert_keys(data["changes"][0], self.CHANGE_KEYS, "RunChangeOut")

    def test_set_decisions_shape(self, client, seeded_app, engine):
        bid = seeded_app["business_id"]
        run_id = self._seed_vibe(engine, bid)
        resp = client.put(
            f"/api/businesses/{bid}/runs/{run_id}/changes/decisions",
            json={"decisions": [{"element_kind": "domain", "element_path": "Billing", "decision": "rejected"}]},
        )
        assert resp.status_code == 200, resp.text
        _assert_keys(resp.json(), self.EXPECTED_KEYS, "RunChangesOut")
        assert resp.json()["changes"][0]["decision"] == "rejected"


class TestProgressEventShape:
    EXPECTED_KEYS = {
        "id", "run_id", "step_id", "event_seq", "stage_name",
        "step_name", "status", "message", "progress_increment",
        "result_json", "created_at",
    }

    def test_progress_events_shape(self, client, seeded_app):
        bid = seeded_app["business_id"]
        resp = client.get(f"/api/businesses/{bid}/runs/{seeded_app['run_id']}/progress")
        assert resp.status_code == 200
        events = resp.json()
        assert len(events) > 0
        _assert_keys(events[0], self.EXPECTED_KEYS, "ProgressEventOut")


class TestAgentConfigShape:
    EXPECTED_KEYS = {
        "id", "notebook_path", "job_id",
        "job_name", "job_url",
        # deployment_catalog STAYS (legacy FE surfaces read it); metamodel_catalog
        # is its concern-A rename, mirrored to the same value (Track 4).
        "deployment_catalog", "metamodel_catalog", "warehouse_id",
        "max_concurrent_runs",
        "collect_vibe_run_statistics",
        # The Settings run time budget and the bounds the UI reads.
        "runtime_budget_hours", "runtime_budget_min_hours", "runtime_budget_max_hours",
        "created_at", "updated_at",
    }

    def test_agent_config_shape(self, client, seeded_app):
        resp = client.get("/api/config/agent")
        assert resp.status_code == 200
        _assert_keys(resp.json(), self.EXPECTED_KEYS, "AgentConfigOut")

    def test_switch_to_bundled_shape(self, client, monkeypatch):
        """switchToBundledAgent answers the same AgentConfigOut shape."""
        from vibe_modeling.backend import bundled_agent_install, job_launcher

        result = bundled_agent_install.InstallResult(
            path="/Users/sp/vibe-modelling-agent/nb.ipynb", version="v0.8.0",
            overwritten=False, agent_version="5.3.3",
        )
        monkeypatch.setattr(bundled_agent_install, "install_bundled_agent_into_workspace", lambda _ws: result)
        monkeypatch.setattr(job_launcher, "setup_agent_job", lambda _ws, _cfg: 4242)
        resp = client.post("/api/admin/agent/switch-to-bundled")
        assert resp.status_code == 200, resp.text
        _assert_keys(resp.json(), self.EXPECTED_KEYS, "AgentConfigOut")
        assert resp.json()["notebook_path"] == result.path


class TestExplorerResponseShapes:
    def test_model_summary_shape(self, client, seeded_app):
        bid = seeded_app["business_id"]
        resp = client.get(f"/api/businesses/{bid}/versions/1/mvm/model")
        assert resp.status_code == 200
        data = resp.json()
        expected = {
            "name", "version", "description", "industry_alignment",
            "core_business_processes", "vibe_modeling_instructions",
            "domain_count", "subdomain_count", "product_count",
            "attribute_count", "fk_count", "confidence_score",
            "review_pct", "reviewed_count", "review_needed_count",
            "no_review_needed_count", "domains",
        }
        _assert_keys(data, expected, "ModelSummaryOut")

        # Domain summary shape
        assert len(data["domains"]) > 0
        domain_keys = {
            "id", "name", "division", "description", "database_name",
            "references", "product_count", "subdomains", "change_status",
        }
        _assert_keys(data["domains"][0], domain_keys, "DomainSummaryOut")

    def test_evolution_metrics_shape(self, client, seeded_app):
        """T16 model-scope evolution metrics. seeded_app has no Volume
        model.json → the metadata-less degraded shape: size from the
        Lakebase structure, every flag False."""
        bid = seeded_app["business_id"]
        resp = client.get(f"/api/businesses/{bid}/versions/1/mvm/evolution-metrics")
        assert resp.status_code == 200
        data = resp.json()
        expected = {
            "version_id", "size", "quality", "change", "effort",
            "provenance", "has_metadata", "has_confidence", "has_predecessor",
        }
        _assert_keys(data, expected, "EvolutionMetricsOut")
        _assert_keys(
            data["size"],
            {
                "domain_count", "product_count", "attribute_count", "fk_count",
                "unlinked_id_count", "siloed_count", "avg_attributes_per_product",
            },
            "EvolutionSizeOut",
        )
        _assert_keys(
            data["quality"],
            {
                "confidence_score", "error_count", "warning_count", "info_count",
                "issues_addressed", "issues_not_addressed",
            },
            "EvolutionQualityOut",
        )
        _assert_keys(
            data["change"],
            {
                "version_trend", "model_touched_pct",
                "products_added", "products_modified", "products_removed",
                "confidence_delta",
                "warnings_delta", "errors_delta", "unlinked_delta",
                "previous_confidence", "previous_warnings", "previous_errors",
                "previous_unlinked", "version_history",
            },
            "EvolutionChangeOut",
        )
        _assert_keys(
            data["effort"],
            {
                "total_ai_calls", "estimated_input_tokens",
                "estimated_output_tokens", "estimated_total_cost_usd",
                "per_model_cost_usd", "duration_hours",
            },
            "EvolutionEffortOut",
        )
        _assert_keys(
            data["provenance"],
            {
                "agent_version", "generated_from_version",
                "target_model_version", "status",
            },
            "EvolutionProvenanceOut",
        )
        assert data["has_metadata"] is False
        assert data["has_confidence"] is False
        assert data["has_predecessor"] is False
        # Size still degrades to the Lakebase-reconstructed structure.
        assert data["size"]["domain_count"] == 1
        assert data["size"]["product_count"] == 1

    def test_relationship_analysis_shape(self, client, seeded_app):
        bid = seeded_app["business_id"]
        resp = client.get(f"/api/businesses/{bid}/versions/1/mvm/relationships")
        assert resp.status_code == 200
        data = resp.json()
        expected = {
            "total_fk_count", "cross_domain_fk_count",
            "intra_domain_fk_count", "domain_connectivity",
        }
        _assert_keys(data, expected, "RelationshipAnalysisOut")

    def test_domain_detail_shape(self, client, seeded_app):
        bid = seeded_app["business_id"]
        resp = client.get(f"/api/businesses/{bid}/versions/1/mvm/domains/core")
        assert resp.status_code == 200
        data = resp.json()
        expected = {"name", "division", "description", "database_name", "references", "products"}
        _assert_keys(data, expected, "DomainDetailOut")

        # Product summary shape
        product_keys = {
            "id", "fqn", "name", "table_name", "description", "type", "data_type",
            "primary_key", "subdomain", "reference", "attribute_count",
            "fk_count", "fk_targets", "change_status",
        }
        _assert_keys(data["products"][0], product_keys, "ProductSummaryOut")

    def test_product_detail_shape(self, client, seeded_app):
        bid = seeded_app["business_id"]
        resp = client.get(f"/api/businesses/{bid}/versions/1/mvm/domains/core/products/widget")
        assert resp.status_code == 200
        data = resp.json()
        expected = {
            "id", "fqn", "name", "table_name", "description", "type", "data_type",
            "primary_key", "reference", "domain_name", "attributes",
        }
        _assert_keys(data, expected, "ProductDetailOut")

        # Attribute shape
        attr_keys = {
            "id", "name", "column_name", "type", "description",
            "business_glossary_term", "tags", "value_regex",
            "foreign_key_to", "references", "is_primary_key",
            "is_foreign_key", "change_status",
        }
        _assert_keys(data["attributes"][0], attr_keys, "AttributeOut")

    def test_version_tree_shape(self, client, seeded_app):
        bid = seeded_app["business_id"]
        resp = client.get(f"/api/businesses/{bid}/explorer/versions")
        assert resp.status_code == 200
        versions = resp.json()
        assert len(versions) > 0
        expected = {
            "id", "version", "status", "deployment_status",
            "base_version_id", "vibe_instructions", "confidence_score",
            "scope", "created_at", "is_base", "parent_deleted",
        }
        _assert_keys(versions[0], expected, "VersionTreeOut")

    def test_next_vibe_metrics_shape(self, client, seeded_app):
        """T13 model-scope metrics. seeded_app has no agent inputs → the
        degraded (pre-ingestion) shape: zeros, null score, has_data=False."""
        bid = seeded_app["business_id"]
        resp = client.get(f"/api/businesses/{bid}/versions/1/mvm/next-vibe-metrics")
        assert resp.status_code == 200
        data = resp.json()
        expected = {
            "version_id", "domain_id", "quality_score",
            "counts", "total_open", "has_data",
        }
        _assert_keys(data, expected, "NextVibeMetricsOut")
        count_keys = {"static_analysis", "priority_remediation", "other", "total"}
        _assert_keys(data["counts"], count_keys, "NextVibeCategoryCountsOut")
        assert data["domain_id"] is None
        assert data["has_data"] is False
        assert data["total_open"] == 0
        assert data["quality_score"] is None

    def test_domain_next_vibe_metrics_shape(self, client, seeded_app):
        """T13 domain-scope metrics — same shape, domain_id populated."""
        bid = seeded_app["business_id"]
        resp = client.get(
            f"/api/businesses/{bid}/versions/1/mvm/domains/core/next-vibe-metrics"
        )
        assert resp.status_code == 200
        data = resp.json()
        expected = {
            "version_id", "domain_id", "quality_score",
            "counts", "total_open", "has_data",
        }
        _assert_keys(data, expected, "NextVibeMetricsOut")
        assert data["domain_id"] is not None
        assert data["has_data"] is False


class TestVibeInputsResponseShapes:
    """Response-shape baselines for the Task 5 Vibe Inputs endpoints (§2).

    Catches silent contract breaks on the new surface. Uses the shared
    seeded_app (business + completed version + one domain).
    """

    HEADERS = {"X-Forwarded-Email": "baseline@x.com"}

    def _create(self, client, bid, vid, **extra):
        r = client.post(
            f"/api/businesses/{bid}/inputs",
            json={"text": "rule", "version_id": vid, **extra},
            headers=self.HEADERS,
        )
        assert r.status_code == 200, r.text
        return r.json()

    def test_input_out_shape(self, client, seeded_app):
        bid, vid = seeded_app["business_id"], seeded_app["version_id"]
        body = self._create(client, bid, vid)
        _assert_keys(body, {
            "id", "business_id", "origin", "author", "text", "category",
            "priority", "confidence_score", "consumed", "consumed_by_run_id",
            "selected_for_run", "status", "deprecated_by", "created_at",
            "updated_at", "anchor",
        }, "VibeInputOut")
        assert body["consumed_by_run_id"] is None
        # User-origin create carries a null category (feedback has no category).
        assert body["category"] is None
        # createVibeInput does not hydrate the anchor (list-only).
        assert body["anchor"] is None

    def test_list_input_out_anchor_hydrated(self, client, seeded_app, engine):
        bid, vid = seeded_app["business_id"], seeded_app["version_id"]
        # Resolve the seeded domain + product ids on the head version.
        from vibe_modeling.backend.db_models import Domain, Product
        with Session(engine) as session:
            d = session.exec(select(Domain).where(Domain.version_id == vid)).first()
            p = session.exec(select(Product).where(Product.version_id == vid)).first()
            domain_id, product_id = d.id, p.id
            domain_name, product_name = d.name, p.name

        # 1) Element-anchored input (domain + product).
        elem = self._create(
            client, bid, vid, text="product rule",
            domain_id=domain_id, product_id=product_id,
        )
        # 2) Model-wide input (link with all-null element ids).
        wide = self._create(client, bid, vid, text="model-wide rule")
        # 3) Input with NO link on the head version: create it, then delete
        #    its head-version link so it has no presence on the current model.
        orphan = self._create(client, bid, vid, text="orphan rule")
        links = client.get(
            f"/api/businesses/{bid}/inputs/{orphan['id']}/links"
        ).json()
        from vibe_modeling.backend.db_models import VibeInputContextLink
        with Session(engine) as session:
            for lk in links:
                session.delete(session.get(VibeInputContextLink, lk["id"]))
            session.commit()

        items = client.get(f"/api/businesses/{bid}/inputs").json()
        by_id = {it["id"]: it for it in items}

        a_elem = by_id[elem["id"]]["anchor"]
        assert a_elem is not None
        assert a_elem["level"] == "element"
        assert a_elem["domain_id"] == domain_id
        assert a_elem["domain_name"] == domain_name
        assert a_elem["product_id"] == product_id
        assert a_elem["product_name"] == product_name
        assert f"Product: {product_name}" in a_elem["path"]

        a_wide = by_id[wide["id"]]["anchor"]
        assert a_wide is not None
        assert a_wide["level"] == "model_wide"
        assert a_wide["path"] == []
        assert a_wide["product_id"] is None

        assert by_id[orphan["id"]]["anchor"] is None

    def test_link_out_shape(self, client, seeded_app):
        bid, vid = seeded_app["business_id"], seeded_app["version_id"]
        vi = self._create(client, bid, vid)
        links = client.get(f"/api/businesses/{bid}/inputs/{vi['id']}/links").json()
        _assert_keys(links[0], {
            "id", "input_id", "version_id", "domain_id", "subdomain_id",
            "product_id", "attribute_id", "fk_link_id", "is_origin",
            "needs_link_review", "reviewed_by", "reviewed_at", "created_at",
        }, "VibeInputContextLinkOut")

    def test_compile_out_shape(self, client, seeded_app):
        bid, vid = seeded_app["business_id"], seeded_app["version_id"]
        vi = self._create(client, bid, vid)
        body = client.post(
            f"/api/businesses/{bid}/versions/{vid}/inputs/compile",
            json={"input_ids": [vi["id"]]},
        ).json()
        _assert_keys(body, {
            "markdown", "agent_markdown", "blocks", "included_input_ids",
            "excluded_input_ids", "excluded_reasons", "input_scope_domains",
        }, "CompileOut")

    def test_carry_forward_out_shape(self, client, seeded_app):
        bid, vid = seeded_app["business_id"], seeded_app["version_id"]
        body = client.post(
            f"/api/businesses/{bid}/versions/{vid}/inputs/carry-forward"
        ).json()
        _assert_keys(body, {
            "version_id", "auto_linked", "needs_review", "deprecated",
            "skipped_existing", "link_ids_needing_review",
        }, "CarryForwardResultOut")

    def test_review_queue_out_shape(self, client, seeded_app):
        bid = seeded_app["business_id"]
        body = client.get(f"/api/businesses/{bid}/links/review-queue").json()
        _assert_keys(body, {"total", "items"}, "ReviewQueueOut")

    def test_product_review_out_shape(self, client, seeded_app, engine):
        from sqlmodel import select as _select

        from vibe_modeling.backend.db_models import Product as _P
        bid, vid = seeded_app["business_id"], seeded_app["version_id"]
        vint, scope = seeded_app["version_int"], seeded_app["scope"]
        with Session(engine) as s:
            prod = s.exec(_select(_P).where(_P.version_id == vid)).first()
            pid = prod.id
        body = client.post(
            f"/api/businesses/{bid}/versions/{vint}/{scope}/reviews/product/{pid}",
            json={"state": "reviewed"}, headers=self.HEADERS,
        ).json()
        _assert_keys(body, {
            "id", "version_id", "product_id", "product_name", "fqn", "state",
            "reviewer", "reviewed_at", "is_explicit",
        }, "ProductReviewOut")


class TestPublishPreviewResponseShape:
    """The publish-preview endpoint (Story 3): tiered baseline diff, model.json
    only, degrade-open. Locks the wire contract (operation_id
    ``previewPublishModelVersion``, response ``PublishPreviewOut``) and the
    no-UserClient guard that keeps it smoke-testable."""

    def _seed(self, engine, *, name="Preview Corp", scope="ecm"):
        from vibe_modeling.backend.model_sync import ModelSyncService
        from .test_model_export import SAMPLE_MODEL

        with Session(engine) as session:
            biz = Business(name=name, industry_alignment="Retail", description="demo")
            session.add(biz)
            session.flush()
            mv = ModelVersion(business_id=biz.id, version=2, scope=scope, status="completed")
            session.add(mv)
            session.flush()
            ModelSyncService(session).sync_from_model_json(mv.id, SAMPLE_MODEL)
            session.commit()
            return biz.id, mv.id

    def _app(self, engine, fake_http, monkeypatch):
        from fastapi.testclient import TestClient

        from vibe_modeling.backend.core._config import AppConfig
        from vibe_modeling.backend.core._defaults import (
            _ConfigDependency,
            _WorkspaceClientDependency,
        )
        from vibe_modeling.backend.core._roles import require_modeler
        from vibe_modeling.backend.core.lakebase import _LakebaseDependency
        from vibe_modeling.backend.routes.industry_models import router as im_router
        from vibe_modeling.backend.services import publish_preview as svc
        from vibe_modeling.backend.sources.github import GithubSourceConnector

        monkeypatch.setattr(
            svc,
            "build_source_connector",
            lambda cfg, app_config, ws, **_: GithubSourceConnector(http=fake_http),
        )

        app = make_test_app(im_router)

        def override_session():
            with Session(engine) as session:
                yield session

        app.dependency_overrides[_LakebaseDependency.__call__] = override_session
        app.dependency_overrides[_ConfigDependency.__call__] = lambda: AppConfig(app_name="test")
        # App-SP client: the configured source read-auth reads its secret with it.
        app.dependency_overrides[_WorkspaceClientDependency.__call__] = lambda: object()
        app.dependency_overrides[require_modeler] = lambda: object()
        return TestClient(app)

    def test_publish_preview_endpoint_shape_tier1(self, engine, monkeypatch):
        from .test_publish_preview import (
            _SAMPLE_BASELINE_DOC,
            _industry_listing_http,
        )

        bid, vid = self._seed(engine)
        http = _industry_listing_http("preview_corp", {"v1": ["ecm"]}, model_doc=_SAMPLE_BASELINE_DOC)
        client = self._app(engine, http, monkeypatch)
        body = client.post(
            f"/api/businesses/{bid}/model-versions/{vid}/publish-preview", json={}
        ).json()
        _assert_keys(body, {
            "baseline", "tier", "scope_mismatch", "manual_needed",
            "candidates", "diff",
        }, "PublishPreviewOut")
        assert body["tier"] == "same_scope_latest"
        assert body["baseline"]["model_id"] == "v1_ecm"
        assert body["manual_needed"] is False
        assert set(body["diff"]["counts"]) == {"new", "modified", "deleted"}

    def test_publish_preview_endpoint_manual_needed_no_500(self, engine, monkeypatch):
        from .test_publish_preview import _industry_listing_http

        bid, vid = self._seed(engine)
        http = _industry_listing_http("preview_corp", {})  # empty industry -> Tier 3
        client = self._app(engine, http, monkeypatch)
        resp = client.post(
            f"/api/businesses/{bid}/model-versions/{vid}/publish-preview", json={}
        )
        assert resp.status_code == 200, resp.text
        body = resp.json()
        assert body["manual_needed"] is True
        assert body["diff"] is None

    def test_publish_preview_endpoint_requires_no_userclient(self, engine, monkeypatch):
        # The route resolves with ONLY Session + Config + Client (app SP) +
        # ModelerOnly overridden (no UserClient override) -> 200. A future
        # regression that adds a Dependencies.UserClient param would 500 here.
        from .test_publish_preview import (
            _SAMPLE_BASELINE_DOC,
            _industry_listing_http,
        )

        bid, vid = self._seed(engine)
        http = _industry_listing_http("preview_corp", {"v1": ["ecm"]}, model_doc=_SAMPLE_BASELINE_DOC)
        client = self._app(engine, http, monkeypatch)
        resp = client.post(
            f"/api/businesses/{bid}/model-versions/{vid}/publish-preview", json={}
        )
        assert resp.status_code == 200, resp.text

    def test_publish_preview_route_has_no_userclient_dep(self):
        # Signature-level guard: the route fn must not depend on UserClient.
        import inspect

        from vibe_modeling.backend.core import Dependencies
        from vibe_modeling.backend.routes.industry_models import (
            preview_publish_model_version_endpoint,
        )

        sig = inspect.signature(preview_publish_model_version_endpoint)
        annotations = [p.annotation for p in sig.parameters.values()]
        assert Dependencies.UserClient not in annotations


class TestDiagramOverviewPathUnchanged:
    """The overview / all-domains diagram path (``domain is None``) must stay
    byte-unchanged after Increment 1: its edges carry the additive focal-view
    routing fields at their backward-compatible empty defaults (the FE then
    falls back to its smoothstep path)."""

    def test_extract_layout_edges_have_empty_focal_fields(self):
        from vibe_modeling.backend.diagram import _extract_layout

        elk_result = {
            "children": [{
                "id": "domain:sales", "x": 0, "y": 0, "width": 400, "height": 300,
                "children": [{"id": "sales.customer", "x": 0, "y": 0,
                              "width": 200, "height": 80}],
            }],
        }
        metadata = {
            "domain:sales": {"domain": "sales", "division": "", "is_external": False,
                             "product_count": 1},
            "sales.customer": {"domain": "sales", "product": "customer",
                               "table_name": "customer", "product_type": "",
                               "description": "", "columns": [], "column_count": 1,
                               "fk_count": 1},
        }
        edges = [{"source_node": "sales.customer", "source_column": "segment_id",
                  "target_node": "sales.customer_segment", "target_column": "segment_id"}]
        layout = _extract_layout(elk_result, metadata, edges)
        assert len(layout.edges) == 1
        e = layout.edges[0]
        assert e.waypoints == []

    def test_layout_algorithm_version_is_7(self):
        # v5 (Increment 1): focal pipeline. v6: focal nodes carry display
        # metadata + height, invalidating v5 layouts cached with empty columns.
        # v7 (0.6.6 item 1): deterministic column ordering (PK, FK, rest; each
        # alpha), invalidating v6 layouts cached with source-order columns.
        from vibe_modeling.backend.diagram import _LAYOUT_ALGORITHM_VERSION

        assert _LAYOUT_ALGORITHM_VERSION == 7


class TestCatalogSchemaWarningResponseShape:
    """Pin the response shape of GET /api/uc/catalogs/{catalog_name}/schema-warning.

    Any change to the three-field contract (``catalog``, ``schema_count``,
    ``schemas``) will surface here before it silently breaks the FE warning
    banner that reads these fields by name.
    """

    EXPECTED_KEYS = {"catalog", "schema_count", "schemas"}

    def test_response_shape(self, client, mock_ws):
        from types import SimpleNamespace

        mock_ws.schemas.list.return_value = [
            SimpleNamespace(name="retail"),
            SimpleNamespace(name="_metamodel"),
        ]

        resp = client.get("/api/uc/catalogs/my_catalog/schema-warning")
        assert resp.status_code == 200, resp.text
        body = resp.json()
        _assert_keys(body, self.EXPECTED_KEYS, "CatalogSchemaWarningOut")
        assert body["catalog"] == "my_catalog"
        assert isinstance(body["schema_count"], int)
        assert isinstance(body["schemas"], list)


class TestCatalogListAndCapabilitiesShape:
    """Pin the wire shapes of listCatalogs (``CatalogOut``) and
    getCatalogCapabilities (``CatalogCapabilityOut``); the deployment catalog
    picker reads these fields by name."""

    LIST_KEYS = {"name", "comment", "owner", "can_create_schema"}
    CAP_KEYS = {"name", "create_schema", "use_metamodel", "create_schema_fix", "use_metamodel_fix"}

    def test_list_shape(self, client, mock_ws):
        from types import SimpleNamespace

        mock_ws.catalogs.list.return_value = [SimpleNamespace(name="main", comment=None, owner=None)]
        resp = client.get("/api/catalogs")
        assert resp.status_code == 200, resp.text
        _assert_keys(resp.json()[0], self.LIST_KEYS, "CatalogOut")

    def test_capabilities_shape(self, client, mock_ws, monkeypatch):
        from vibe_modeling.backend.core import _uc_privileges

        monkeypatch.setattr(_uc_privileges, "_CHECK_WS", mock_ws)
        resp = client.get("/api/catalogs/capabilities", params={"names": "main"})
        assert resp.status_code == 200, resp.text
        body = resp.json()
        assert len(body) == 1
        _assert_keys(body[0], self.CAP_KEYS, "CatalogCapabilityOut")


class TestSourceCapabilitiesShape:
    """Wire contract for getSourceCapabilities. The 0.7.1 read-auth work
    widened ``auth_mode`` (adds 'token') and added ``auth_error``; lock both
    onto the response shape so a silent drop is caught."""

    EXPECTED_KEYS = {
        "source_kind", "target_kinds", "discovery_mode",
        "materialization_timing", "provides_sectors", "read_only",
        "auth_mode", "auth_error",
    }

    def test_capabilities_shape(self, client):
        resp = client.get("/api/sources/capabilities")
        assert resp.status_code == 200, resp.text
        body = resp.json()
        _assert_keys(body, self.EXPECTED_KEYS, "SourceCapabilities")
        # Unconfigured test AppConfig (no env App creds) → anonymous, clean.
        assert body["auth_mode"] in {"github_app", "token", "anonymous"}
        assert body["auth_mode"] == "anonymous"
        assert body["auth_error"] is None


class TestSourceAuthConfigShape:
    """Wire contract for getSourceAuthConfig — references + effective mode,
    never a secret value."""

    EXPECTED_KEYS = {
        "auth_mode", "github_app_id", "github_app_installation_id",
        "github_app_secret_scope", "github_app_secret_key",
        "token_secret_scope", "token_secret_key", "effective_mode", "error",
    }

    def test_source_auth_config_shape(self, client):
        resp = client.get("/api/config/source-auth")
        assert resp.status_code == 200, resp.text
        _assert_keys(resp.json(), self.EXPECTED_KEYS, "SourceAuthConfigOut")


class TestAssessConfigShape:
    """Wire contract for getAssessConfig (headless assessment Settings)."""

    EXPECTED_KEYS = {
        "reader_application_id", "reader_display_name", "job_id",
        "workspace_path", "max_concurrent_runs",
        "default_reasoning_effort", "warehouse_id", "genie_version",
        "skills_ref", "skills_version", "installed", "ready", "missing",
        "job_url", "updated_at", "updated_by", "app_application_id",
    }

    def test_assess_config_shape(self, client):
        resp = client.get("/api/assess/config")
        assert resp.status_code == 200, resp.text
        _assert_keys(resp.json(), self.EXPECTED_KEYS, "AssessConfigOut")


class TestAssessReadinessShape:
    """Wire contract for checkAssessReadiness."""

    READINESS_KEYS = {"global_checks", "domains"}
    CHECK_KEYS = {"key", "label", "state", "detail", "fix_sql", "fix_action"}
    DOMAIN_KEYS = {"domain_id", "domain_name", "checks", "blocked"}

    def _seed(self, engine, mock_ws):
        from sqlmodel import Session

        from _assess_helpers import ready_config, ws_ok
        from vibe_modeling.backend.db_models import AssessConfig, Business, Domain, ModelVersion
        ws_ok(mock_ws)
        with Session(engine) as s:
            b = Business(name="Shape", description="d")
            s.add(b); s.commit(); s.refresh(b)
            mv = ModelVersion(business_id=b.id, version=1, scope="mvm", status="completed",
                              deployment_status="deployed", uc_catalog="cat")
            s.add(mv); s.commit(); s.refresh(mv)
            d = Domain(version_id=mv.id, name="d1", database_name="d1")
            s.add(d)
            s.add(ready_config(job_id=1))
            s.commit(); s.refresh(d)
            return mv.id, d.id

    def test_readiness_shape(self, client, engine, mock_ws):
        vid, did = self._seed(engine, mock_ws)
        resp = client.post("/api/assess/readiness", json={"version_id": vid, "domains": [
            {"domain_id": did, "sources": [{"source_name": "s", "catalog_name": "b", "schema_name": "x"}]}]})
        assert resp.status_code == 200, resp.text
        body = resp.json()
        _assert_keys(body, self.READINESS_KEYS, "ReadinessOut")
        _assert_keys(body["domains"][0], self.DOMAIN_KEYS, "DomainReadiness")
        _assert_keys(body["global_checks"][0], self.CHECK_KEYS, "Check")


class TestAssessLaunchShape:
    """Wire contract for launchAssessment / getAssessSourceMap / putAssessSourceMap."""

    BATCH_KEYS = {"id", "business_id", "version_id", "version", "scope", "output_model", "etl_type",
                  "reasoning_effort", "status", "created_by", "created_at", "domain_runs"}
    RUN_KEYS = {"id", "domain_id", "domain_name", "databricks_run_id", "run_url", "status", "stage", "attempt",
                "resume_at", "last_message", "error_message", "started_at", "ended_at", "skills_commit",
                "skills_version", "genie_version", "model_quality_score", "metamodel_location",
                "metamodel_version", "results_valid", "sources", "job_url", "job_reader",
                "schema_version", "runs_path", "ingest_attempts", "ingest_next_at", "ingest_max_attempts"}

    def _seed(self, engine, mock_ws):
        from sqlmodel import Session

        from _assess_helpers import ready_config, ws_ok
        from vibe_modeling.backend.db_models import AssessConfig, Business, Domain, ModelVersion
        ws_ok(mock_ws)
        mock_ws.jobs.run_now.return_value.run_id = 5
        with Session(engine) as s:
            b = Business(name="LaunchShape", description="d")
            s.add(b); s.commit(); s.refresh(b)
            mv = ModelVersion(business_id=b.id, version=1, scope="mvm", status="completed",
                              deployment_status="deployed", uc_catalog="cat")
            s.add(mv); s.commit(); s.refresh(mv)
            d = Domain(version_id=mv.id, name="d1", database_name="d1")
            s.add(d)
            s.add(ready_config(job_id=1))
            s.commit(); s.refresh(d)
            return b.id, mv.id, d.id

    def test_launch_shape(self, client, engine, mock_ws):
        bid, vid, did = self._seed(engine, mock_ws)
        resp = client.post(f"/api/businesses/{bid}/assessments", json={"version_id": vid, "domains": [
            {"domain_id": did, "sources": [{"source_name": "s", "catalog_name": "b", "schema_name": "x"}]}]})
        assert resp.status_code == 201, resp.text
        body = resp.json()
        _assert_keys(body, self.BATCH_KEYS, "AssessBatchOut")
        _assert_keys(body["domain_runs"][0], self.RUN_KEYS, "AssessDomainRunOut")
        _assert_keys(body["domain_runs"][0]["sources"][0], {"source_name", "catalog_name", "schema_name"}, "SourceIn")

    def test_relaunch_shape(self, client, engine, mock_ws):
        bid, vid, did = self._seed(engine, mock_ws)
        first = client.post(f"/api/businesses/{bid}/assessments", json={"version_id": vid, "domains": [
            {"domain_id": did, "sources": [{"source_name": "s", "catalog_name": "b", "schema_name": "x"}]}]}).json()
        client.post(f"/api/assessments/{first['id']}/cancel")
        resp = client.post(f"/api/assessments/{first['id']}/relaunch")
        assert resp.status_code == 201, resp.text
        body = resp.json()
        assert body["id"] != first["id"]
        _assert_keys(body, self.BATCH_KEYS, "AssessBatchOut")
        _assert_keys(body["domain_runs"][0], self.RUN_KEYS, "AssessDomainRunOut")

    def test_source_map_shape(self, client, engine, mock_ws):
        bid, _, _ = self._seed(engine, mock_ws)
        src = [{"source_name": "s", "catalog_name": "b", "schema_name": "x"}]
        put = client.put(f"/api/businesses/{bid}/assess-source-map", json={"sources": src})
        assert put.status_code == 200, put.text
        _assert_keys(put.json(), {"sources"}, "SourceMapOut")
        got = client.get(f"/api/businesses/{bid}/assess-source-map")
        assert got.status_code == 200, got.text
        _assert_keys(got.json(), {"sources"}, "SourceMapOut")
        _assert_keys(got.json()["sources"][0], {"source_name", "catalog_name", "schema_name"}, "SourceIn")


class TestAssessStatusShape:
    """Wire contract for listAssessments / getAssessment / cancelAssessment / cancelAssessmentDomainRun."""

    def _seed(self, engine):
        from sqlmodel import Session

        from _assess_helpers import seed_domain_run
        from vibe_modeling.backend.db_models import AssessConfig, AssessDomainRun, Business
        dr_id = seed_domain_run(engine, databricks_run_id=11, status="assessing")
        with Session(engine) as s:
            dr = s.get(AssessDomainRun, dr_id)
            s.add(AssessConfig(job_id=1)); s.commit()
            from vibe_modeling.backend.db_models import AssessBatch
            batch = s.get(AssessBatch, dr.batch_id)
            return batch.business_id, batch.id, dr_id

    def test_list_get_shape(self, client, engine):
        bid, batch_id, _ = self._seed(engine)
        lst = client.get(f"/api/businesses/{bid}/assessments")
        assert lst.status_code == 200, lst.text
        _assert_keys(lst.json()[0], TestAssessLaunchShape.BATCH_KEYS, "AssessBatchOut")
        one = client.get(f"/api/assessments/{batch_id}")
        assert one.status_code == 200, one.text
        _assert_keys(one.json(), TestAssessLaunchShape.BATCH_KEYS, "AssessBatchOut")
        _assert_keys(one.json()["domain_runs"][0], TestAssessLaunchShape.RUN_KEYS, "AssessDomainRunOut")

    def test_cancel_domain_run_shape(self, client, engine):
        _, _, dr_id = self._seed(engine)
        resp = client.post(f"/api/assessment-domain-runs/{dr_id}/cancel")
        assert resp.status_code == 200, resp.text
        _assert_keys(resp.json(), TestAssessLaunchShape.RUN_KEYS, "AssessDomainRunOut")

    def test_cancel_batch_shape(self, client, engine):
        _, batch_id, _ = self._seed(engine)
        resp = client.post(f"/api/assessments/{batch_id}/cancel")
        assert resp.status_code == 200, resp.text
        _assert_keys(resp.json(), TestAssessLaunchShape.BATCH_KEYS, "AssessBatchOut")
        _assert_keys(resp.json()["domain_runs"][0], TestAssessLaunchShape.RUN_KEYS, "AssessDomainRunOut")


class TestAssessResultsShape:
    """Wire contract for getAssessmentResults / listAssessmentDocs / answer + clear decision."""

    def test_results_docs_and_answer_shapes(self, client, engine, mock_ws):
        from types import SimpleNamespace as NS

        from test_assess_ingest import OUT, _fixture_files, _seed_run, _ws_with
        from vibe_modeling.backend.assessment.ingest import ingest_domain_run
        from vibe_modeling.backend.db_models import AssessDomainRun
        dr_id, _, _ = _seed_run(engine)
        with Session(engine) as s:
            ingest_domain_run(s, _ws_with(_fixture_files()), s.get(AssessDomainRun, dr_id))
        r = client.get(f"/api/assessment-domain-runs/{dr_id}/results")
        assert r.status_code == 200, r.text
        body = r.json()
        _assert_keys(body, {"domain_run", "grades", "summary", "letter_counts", "structure_counts",
                            "entities", "gaps", "pending_decisions", "next_vibes"}, "AssessResultsOut")
        _assert_keys(body["structure_counts"], {"sound", "review", "rework"}, "structure_counts")
        _assert_keys(body["letter_counts"], {"A", "B", "C", "D", "F"}, "letter_counts")
        assert body["summary"] is None
        _assert_keys(body["domain_run"], TestAssessLaunchShape.RUN_KEYS, "AssessDomainRunOut")
        _assert_keys(body["grades"], {"full", "partial", "blocked"}, "grades")
        ent = next(e for e in body["entities"] if e["columns"])
        _assert_keys(ent, {"id", "domain_run_id", "product_id", "in_model", "name", "grade", "coverage_pct",
                           "primary_source", "row_count", "net_new_candidate", "mapped", "gap", "deferred_fk",
                           "dup_source", "columns", "core_sourced", "core_total", "enrichment_sourced",
                           "enrichment_total", "deferred_fk_count", "enrichment_pct", "letter_grade",
                           "grade_reason", "row_filter", "structure", "structure_refs"}, "AssessEntityOut")
        _assert_keys(ent["columns"][0], {"id", "entity_id", "attribute_id", "in_model", "target", "status",
                                         "source_table", "source_column", "transform", "row_count", "null_pct",
                                         "distinct_count", "date_format", "fk_orphans", "evidence", "dup_source", "tier",
                                         "profiles_by_source"},
                     "ColumnMappingOut")
        _assert_keys(body["gaps"][0], {"id", "domain_run_id", "entity", "column", "gap_type", "description",
                                       "status", "ask"}, "GapOut")
        dec = body["pending_decisions"][0]
        dec_keys = {"id", "domain_run_id", "gate", "question", "default_taken", "evidence", "entity",
                    "answer_status", "answer_option_id", "answer_text", "answered_by", "answered_at", "options",
                    "context", "why_it_matters", "recommendation_rationale", "blocks_build", "affected", "kind", "ordinal"}
        _assert_keys(dec, dec_keys, "PendingDecisionOut")
        _assert_keys(dec["options"][0], {"id", "ordinal", "label", "pros", "cons", "impact", "recommended"},
                     "DecisionOptionOut")
        _assert_keys(body["next_vibes"][0], {"id", "domain_run_id", "priority", "category", "text", "confidence",
                                             "problem", "proposed_change", "impact_if_skipped", "urgency",
                                             "affected_entities", "feedback_input_id"}, "NextVibeOut")
        put = client.put(f"/api/assessment-decisions/{dec['id']}/answer", json={"text": "ok"})
        assert put.status_code == 200, put.text
        _assert_keys(put.json(), dec_keys, "PendingDecisionOut")
        dele = client.delete(f"/api/assessment-decisions/{dec['id']}/answer")
        assert dele.status_code == 200, dele.text
        _assert_keys(dele.json(), dec_keys, "PendingDecisionOut")
        mock_ws.files.list_directory_contents.side_effect = lambda p: iter(
            [NS(path=f"{OUT}/docs/a.md", name="a.md", is_directory=False)])
        docs = client.get(f"/api/assessment-domain-runs/{dr_id}/docs")
        assert docs.status_code == 200, docs.text
        _assert_keys(docs.json(), {"folder_url", "docs"}, "DocsOut")
        _assert_keys(docs.json()["docs"][0], {"path", "name", "category"}, "DocEntry")
        mock_ws.files.download.side_effect = lambda p: NS(contents=__import__("io").BytesIO(b"# a"))
        content = client.get(f"/api/assessment-domain-runs/{dr_id}/docs/content", params={"path": "docs/a.md"})
        assert content.status_code == 200, content.text
        _assert_keys(content.json(), {"path", "content", "truncated"}, "DocContentOut")


class TestAssessHandoffShape:
    """Wire contract for getAssessmentHandoff / createAssessmentHandoff."""

    KEYS = {"domain_run_id", "path", "created_at", "created_by", "folder_url", "prompts", "skills",
            "next_steps", "user_scope_note", "expected_handoffs", "skills_note"}

    def test_get_and_post_shapes(self, client, engine, mock_ws):
        import io
        from types import SimpleNamespace as NS

        from databricks.sdk.errors.platform import NotFound
        from test_assess_ingest import OUT, _fixture_files, _seed_run, _ws_with
        from vibe_modeling.backend.assessment.ingest import ingest_domain_run
        from vibe_modeling.backend.db_models import AssessDomainRun
        dr_id, _, _ = _seed_run(engine)
        with Session(engine) as s:
            ingest_domain_run(s, _ws_with(_fixture_files()), s.get(AssessDomainRun, dr_id))
            dr = s.get(AssessDomainRun, dr_id)
            dr.status = "completed"
            s.add(dr); s.commit()
        mock_ws.files.list_directory_contents.side_effect = lambda p: iter(
            [NS(path=f"{OUT}/conventions.yml", is_directory=False)] if p == OUT else [])
        mock_ws.files.download.side_effect = lambda p: NS(contents=io.BytesIO(b"x"))
        mock_ws.workspace.get_status.return_value.object_id = 11
        mock_ws.workspace.download.side_effect = NotFound("no marker")
        got = client.get(f"/api/assessment-domain-runs/{dr_id}/handoff")
        assert got.status_code == 200, got.text
        _assert_keys(got.json(), self.KEYS, "HandoffOut")
        assert got.json()["created_at"] is None
        from unittest.mock import MagicMock

        from vibe_modeling.backend.core._defaults import _get_user_ws_optional
        uw = MagicMock()
        uw.workspace.get_status.side_effect = NotFound("none")
        uw.workspace.download.side_effect = NotFound("no marker")
        client.app.dependency_overrides[_get_user_ws_optional] = lambda: uw
        try:
            posted = client.post(f"/api/assessment-domain-runs/{dr_id}/handoff", json={},
                                 headers={"X-Forwarded-Email": "dana@example.com"})
        finally:
            client.app.dependency_overrides.pop(_get_user_ws_optional, None)
        assert posted.status_code == 200, posted.text
        body = posted.json()
        _assert_keys(body, self.KEYS, "HandoffOut")
        _assert_keys(body["prompts"][0], {"key", "title", "skill", "prompt"}, "HandoffPrompt")
        _assert_keys(body["skills"][0], {"name", "state", "location", "bundled_version", "installed_version"},
                     "SkillStatus")
        _assert_keys(body["next_steps"][0], {"order", "title", "detail", "done"}, "NextStepOut")
        assert body["created_at"] is not None


class TestAssessInstallSkillsShape:
    """Wire contract for installAssessmentSkills."""

    def test_install_skills_response(self, client, mock_ws, engine):
        from unittest.mock import MagicMock

        from databricks.sdk.errors.platform import NotFound
        from vibe_modeling.backend.core._defaults import _get_user_ws_optional
        from _assess_helpers import seed_domain_run
        dr_id = seed_domain_run(engine)
        uw = MagicMock()
        uw.workspace.get_status.side_effect = NotFound("none")
        mock_ws.workspace.get_status.side_effect = NotFound("none")
        client.app.dependency_overrides[_get_user_ws_optional] = lambda: uw
        try:
            r = client.post(f"/api/assessment-domain-runs/{dr_id}/handoff/install-skills",
                            json={"names": ["domain-model-assessment"]},
                            headers={"X-Forwarded-Email": "dana@example.com"})
        finally:
            client.app.dependency_overrides.pop(_get_user_ws_optional, None)
        assert r.status_code == 200, r.text
        _assert_keys(r.json(), {"installed", "updated", "skipped", "skills"}, "InstallSkillsOut")
        _assert_keys(r.json()["skills"][0], {"name", "state", "location", "bundled_version", "installed_version"},
                     "SkillStatus")


class TestAddNextVibeToFeedbackShape:
    """Wire contract for addNextVibeToFeedback (single vibe endpoint)."""

    def test_single_vibe_response_shape(self, client, engine):
        """Verify NextVibeToFeedbackOut response structure."""
        from datetime import datetime, timezone
        from vibe_modeling.backend.db_models import (
            Business, ModelVersion, Domain, AssessBatch, AssessDomainRun, AssessNextVibe
        )

        with Session(engine) as session:
            b = Business(name="TestCorpA", description="Test", industry_alignment="Retail")
            session.add(b)
            session.commit()

            mv = ModelVersion(business_id=b.id, version=1, status="completed", scope="test",
                            deployment_status="deployed", uc_catalog="cat")
            session.add(mv)
            session.commit()

            d = Domain(version_id=mv.id, name="TestDomA", database_name="test_dom_a")
            session.add(d)
            session.commit()

            batch = AssessBatch(business_id=b.id, version_id=mv.id, scope="test",
                              created_at=datetime.now(timezone.utc), updated_at=datetime.now(timezone.utc))
            session.add(batch)
            session.commit()

            dr = AssessDomainRun(batch_id=batch.id, domain_id=d.id, out_dir="/test",
                                status="completed", created_at=datetime.now(timezone.utc))
            session.add(dr)
            session.commit()

            nv = AssessNextVibe(domain_run_id=dr.id, ordinal=0, priority=1, category="",
                               text="Test vibe", confidence=0.8, problem="", proposed_change="",
                               impact_if_skipped="", urgency="before_build")
            session.add(nv)
            session.commit()

            dr_id, nv_id = dr.id, nv.id

        response = client.post(
            f"/api/assessment-domain-runs/{dr_id}/next-vibes/{nv_id}/feedback",
            json={},
            headers={"X-Forwarded-Email": "test@example.com"}
        )
        assert response.status_code == 200, response.text
        body = response.json()
        _assert_keys(body, {"next_vibe_id", "feedback_input_id", "created"}, "NextVibeToFeedbackOut")
        assert isinstance(body["created"], bool)


class TestAddNextVibesToFeedbackShape:
    """Wire contract for addNextVibesToFeedback (bulk endpoint)."""

    def test_bulk_vibes_response_shape(self, client, engine):
        """Verify BulkNextVibeToFeedbackOut response structure."""
        from datetime import datetime, timezone
        from vibe_modeling.backend.db_models import (
            Business, ModelVersion, Domain, AssessBatch, AssessDomainRun, AssessNextVibe
        )

        with Session(engine) as session:
            b = Business(name="TestCorpB", description="Test", industry_alignment="Retail")
            session.add(b)
            session.commit()

            mv = ModelVersion(business_id=b.id, version=1, status="completed", scope="test",
                            deployment_status="deployed", uc_catalog="cat")
            session.add(mv)
            session.commit()

            d = Domain(version_id=mv.id, name="TestDomB", database_name="test_dom_b")
            session.add(d)
            session.commit()

            batch = AssessBatch(business_id=b.id, version_id=mv.id, scope="test",
                              created_at=datetime.now(timezone.utc), updated_at=datetime.now(timezone.utc))
            session.add(batch)
            session.commit()

            dr = AssessDomainRun(batch_id=batch.id, domain_id=d.id, out_dir="/test",
                                status="completed", created_at=datetime.now(timezone.utc))
            session.add(dr)
            session.commit()

            nv = AssessNextVibe(domain_run_id=dr.id, ordinal=0, priority=1, category="",
                               text="Test vibe", confidence=0.8, problem="", proposed_change="",
                               impact_if_skipped="", urgency="before_build")
            session.add(nv)
            session.commit()

            dr_id = dr.id

        response = client.post(
            f"/api/assessment-domain-runs/{dr_id}/next-vibes/feedback/bulk",
            json={"urgency": "before_build"},
            headers={"X-Forwarded-Email": "test@example.com"}
        )
        assert response.status_code == 200, response.text
        body = response.json()
        _assert_keys(body, {"count_created", "count_reused", "items", "failures"}, "BulkNextVibeToFeedbackOut")
        assert isinstance(body["count_created"], int)
        assert isinstance(body["count_reused"], int)
        assert isinstance(body["items"], list)
        if body["items"]:
            _assert_keys(body["items"][0], {"next_vibe_id", "feedback_input_id", "created"}, "NextVibeToFeedbackOut")


class TestTaxonomyResponseShapes:
    """Wire contracts for the Domain Taxonomy Builder: the 10 ``/api/taxonomy/*``
    routes and the 4 ``/config/taxonomy`` settings routes, with the feature
    installed and a stored model service."""

    SERVICE = "main.ai.drafter"
    INTAKE = {"company_name": "Ridgeline Energy", "industry": "Utility"}
    DRAFT_KEYS = {"draft_id", "status", "parts"}
    PART_KEYS = {"status", "error", "tree", "section", "description"}
    TREE_KEYS = {"domains", "shared_masters", "relationships", "division_names", "coverage"}
    DOMAIN_KEYS = {"name", "schema_name", "subdomains"}
    SUBDOMAIN_KEYS = {"name", "categories"}
    CLAIM_KEYS = {"text", "provenance"}
    ISSUE_KEYS = {"severity", "message", "rule_id", "domains"}
    CONFIG_KEYS = {
        "installed", "model_service", "install_default_model_service", "max_concurrency", "ready", "last_check",
        "updated_by", "updated_at",
    }
    CHECK_KEYS = {"status", "message", "checked_at"}

    @pytest.fixture
    def tax(self, engine, monkeypatch):
        from unittest.mock import MagicMock

        from fastapi.testclient import TestClient

        from vibe_modeling.backend.core._config import AppConfig
        from vibe_modeling.backend.core._defaults import _ConfigDependency, _WorkspaceClientDependency
        from vibe_modeling.backend.core._roles import UserRole, resolve_user_role
        from vibe_modeling.backend.core.lakebase import _LakebaseDependency
        from vibe_modeling.backend.routes import config as config_routes
        from vibe_modeling.backend.routes import taxonomy as taxonomy_routes
        from vibe_modeling.backend.taxonomy import llm as llm_module
        from vibe_modeling.backend.taxonomy.access import MODEL_SERVICE_ACCESS
        from vibe_modeling.backend.taxonomy.drafts import DraftStore
        from vibe_modeling.backend.taxonomy.example import load_ridgeline_example
        from vibe_modeling.backend.taxonomy.models import SECTION_HEADINGS, SECTION_KEYS, TaxonomyTree
        from vibe_modeling.backend.taxonomy.slots import LLMSlots

        ex = load_ridgeline_example()
        service = self.SERVICE

        class FakeLLM:
            model_service = service

            def probe(self):
                from vibe_modeling.backend.taxonomy.llm import ProbeResult

                return ProbeResult("ok", "answered")

            def complete_json(self, system, user, model):
                if model is TaxonomyTree:
                    return ex.tree
                return ex.sections[next(k for k in SECTION_KEYS if f"'{SECTION_HEADINGS[k]}'" in system)]

            def complete_text(self, system, user):
                return "Ridgeline is a regional utility."

        llm_ws = MagicMock()
        llm_ws.config.client_id = "sp-id"
        # The LLM client answers the gateway POST and, as the bounded client
        # the model-services list uses, the UC list GET.
        llm_ws.api_client.do.side_effect = lambda method, path, **kw: (
            {"choices": [{"message": {"role": "assistant", "content": "OK"}}]}
            if method == "POST"
            else {"model_services": [{"name": f"model-services/{service}"}]}
        )
        monkeypatch.setattr(llm_module, "_LLM_WS", llm_ws)
        self.llm_ws = llm_ws
        app_ws = MagicMock()

        with Session(engine) as session:
            session.add(AgentConfig(taxonomy_model_service=service))
            session.commit()

        app = make_test_app(config_routes.router, taxonomy_routes.router)

        def override_session():
            with Session(engine) as session:
                yield session

        config = AppConfig(app_name="test", taxonomy_builder_enabled=True)
        app.dependency_overrides[_LakebaseDependency.__call__] = override_session
        app.dependency_overrides[_ConfigDependency.__call__] = lambda: config
        app.dependency_overrides[_WorkspaceClientDependency.__call__] = lambda: app_ws
        app.dependency_overrides[resolve_user_role] = lambda: UserRole.APP_ADMIN
        app.dependency_overrides[taxonomy_routes.get_taxonomy_llm] = FakeLLM
        self.store = DraftStore(slots=LLMSlots())
        app.dependency_overrides[taxonomy_routes.get_draft_store] = lambda: self.store
        MODEL_SERVICE_ACCESS.clear()
        with TestClient(app) as c:
            yield c
        MODEL_SERVICE_ACCESS.clear()

    @staticmethod
    def _poll(c, draft_id):
        import time

        deadline = time.time() + 5
        while time.time() < deadline:
            body = c.get(f"/api/taxonomy/drafts/{draft_id}").json()
            if body["status"] != "running":
                return body
            time.sleep(0.02)
        raise AssertionError("draft never finished")

    def _assert_draft(self, body, parts):
        _assert_keys(body, self.DRAFT_KEYS, "TaxonomyDraftOut")
        assert set(body["parts"]) == parts
        for key, part in body["parts"].items():
            _assert_keys(part, self.PART_KEYS, f"TaxonomyDraftPartOut[{key}]")

    def _assert_tree(self, tree):
        _assert_keys(tree, self.TREE_KEYS, "TaxonomyTree")
        _assert_keys(tree["domains"][0], self.DOMAIN_KEYS, "TaxonomyDomain")
        _assert_keys(tree["domains"][0]["subdomains"][0], self.SUBDOMAIN_KEYS, "TaxonomySubdomain")

    def test_draft_create_get_cancel_retry_shapes(self, tax):
        from vibe_modeling.backend.taxonomy.models import SECTION_KEYS

        created = tax.post("/api/taxonomy/drafts", json=self.INTAKE)
        assert created.status_code == 200, created.text
        _assert_keys(created.json(), {"draft_id"}, "TaxonomyDraftCreated")
        draft_id = created.json()["draft_id"]

        body = self._poll(tax, draft_id)
        self._assert_draft(body, {"tree", *SECTION_KEYS})
        self._assert_tree(body["parts"]["tree"]["tree"])
        _assert_keys(body["parts"]["company"]["section"], {"claims"}, "TaxonomySection")
        _assert_keys(body["parts"]["company"]["section"]["claims"][0], self.CLAIM_KEYS, "TaxonomyClaim")

        cancelled = tax.post(f"/api/taxonomy/drafts/{draft_id}/cancel")
        assert cancelled.status_code == 200
        self._assert_draft(cancelled.json(), {"tree", *SECTION_KEYS})

        # A done part answers 409 with a plain detail.
        refused = tax.post(f"/api/taxonomy/drafts/{draft_id}/parts/company/retry")
        assert refused.status_code == 409
        _assert_keys(refused.json(), {"detail"}, "retry 409")

    def test_retry_of_a_busy_part_shape(self, tax):
        from vibe_modeling.backend.core._identity import LOCAL_DEV_IDENTITY
        from vibe_modeling.backend.taxonomy.models import SECTION_KEYS, TaxonomyIntake

        # A draft whose tree is busy (as after a busy pre-draft test call), owned by the header-less identity.
        draft_id = self.store.create(LOCAL_DEV_IDENTITY, TaxonomyIntake(**self.INTAKE), None, busy=True)
        busy = tax.get(f"/api/taxonomy/drafts/{draft_id}").json()
        assert busy["status"] == "busy"
        self._assert_draft(busy, {"tree", *SECTION_KEYS})
        retried = tax.post(f"/api/taxonomy/drafts/{draft_id}/parts/tree/retry")
        assert retried.status_code == 200, retried.text
        self._assert_draft(retried.json(), {"tree", *SECTION_KEYS})

    def test_condense_shape(self, tax):
        from vibe_modeling.backend.taxonomy.example import load_ridgeline_example

        ex = load_ridgeline_example()
        body = {
            "intake": self.INTAKE, "tree": ex.tree.model_dump(),
            "sections": {k: v.model_dump() for k, v in ex.sections.items()},
        }
        created = tax.post("/api/taxonomy/condense", json=body)
        assert created.status_code == 200, created.text
        _assert_keys(created.json(), {"draft_id"}, "TaxonomyDraftCreated")
        self._assert_draft(self._poll(tax, created.json()["draft_id"]), {"description"})

    def test_compile_shape(self, tax):
        from vibe_modeling.backend.taxonomy.example import load_ridgeline_example

        tree = load_ridgeline_example().tree.model_dump()
        tree["domains"] = tree["domains"][:2]  # fewer than 3 domains -> one model-level issue
        resp = tax.post("/api/taxonomy/compile", json={"tree": tree, "strictness": "strict", "sections": {}})
        assert resp.status_code == 200, resp.text
        body = resp.json()
        _assert_keys(body, {"clamp", "business_vibes", "business_domains", "csv", "issues"}, "TaxonomyCompileOut")
        assert body["issues"], "expected at least one issue"
        for issue in body["issues"]:
            _assert_keys(issue, self.ISSUE_KEYS, "TaxonomyIssue")

    SAVED_KEYS = {
        "revision", "step", "sector_id", "strictness", "intake", "tree", "sections", "updated_at", "expires_at",
    }

    def test_saved_wizard_shapes(self, tax):
        from vibe_modeling.backend.taxonomy.example import load_ridgeline_example

        ex = load_ridgeline_example()
        empty = tax.get("/api/taxonomy/saved")
        assert empty.status_code == 200
        _assert_keys(empty.json(), {"saved"}, "TaxonomySavedWizardOut")
        body = {
            "revision": 0, "step": 2, "intake": self.INTAKE, "tree": ex.tree.model_dump(),
            "sections": {"company": ex.sections["company"].model_dump()},
        }
        saved = tax.put("/api/taxonomy/saved", json=body)
        assert saved.status_code == 200, saved.text
        _assert_keys(saved.json(), self.SAVED_KEYS, "TaxonomyWizardStateOut")
        self._assert_tree(saved.json()["tree"])
        loaded = tax.get("/api/taxonomy/saved")
        assert loaded.status_code == 200
        _assert_keys(loaded.json()["saved"], self.SAVED_KEYS, "TaxonomyWizardStateOut")

        stale = tax.put("/api/taxonomy/saved", json=body)
        assert stale.status_code == 409
        _assert_keys(stale.json(), {"detail"}, "saved 409")
        _assert_keys(stale.json()["detail"], {"error", "revision", "message"}, "stale_revision detail")

        discarded = tax.delete("/api/taxonomy/saved")
        assert discarded.status_code == 200
        _assert_keys(discarded.json(), {"discarded"}, "TaxonomyWizardDiscardOut")

    def test_example_shape(self, tax):
        resp = tax.get("/api/taxonomy/example")
        assert resp.status_code == 200
        body = resp.json()
        _assert_keys(body, {"company_name", "industry", "tree", "sections", "description"}, "TaxonomyExampleOut")
        self._assert_tree(body["tree"])

    def test_config_get_put_test_shapes(self, tax):
        got = tax.get("/api/config/taxonomy")
        assert got.status_code == 200
        _assert_keys(got.json(), self.CONFIG_KEYS, "TaxonomyConfigOut")
        assert got.json()["last_check"] is None

        put = tax.put("/api/config/taxonomy", json={"model_service": self.SERVICE, "max_concurrency": 4})
        assert put.status_code == 200, put.text
        _assert_keys(put.json(), self.CONFIG_KEYS, "TaxonomyConfigOut (PUT)")
        _assert_keys(put.json()["last_check"], self.CHECK_KEYS, "TaxonomyCheckOut (last_check)")

        tested = tax.post("/api/config/taxonomy/test")
        assert tested.status_code == 200, tested.text
        _assert_keys(tested.json(), self.CHECK_KEYS, "TaxonomyCheckOut")

    def test_config_refused_put_detail_shape(self, tax):
        from databricks.sdk.errors import PermissionDenied

        self.llm_ws.api_client.do.side_effect = PermissionDenied("no")
        resp = tax.put("/api/config/taxonomy", json={"model_service": self.SERVICE, "max_concurrency": 4})
        assert resp.status_code == 400
        _assert_keys(resp.json()["detail"], {"error", "key", "status", "message"}, "model_service_refused")

    def test_model_services_shape(self, tax):
        resp = tax.get("/api/config/taxonomy/model-services")
        assert resp.status_code == 200, resp.text
        _assert_keys(resp.json(), {"services", "message"}, "TaxonomyModelServicesOut")
        assert resp.json()["services"] == [self.SERVICE]


class TestUserPreferenceDeleteShape:
    """Wire contract for deleteUserPreference: a single ``deleted`` bool,
    200 whether or not the caller had a row."""

    def test_delete_response_shape(self, client):
        client.put("/api/user/preferences/k", json={"value": "v"})
        hit = client.delete("/api/user/preferences/k")
        assert hit.status_code == 200, hit.text
        _assert_keys(hit.json(), {"deleted"}, "UserPreferenceDeleteOut")
        assert hit.json()["deleted"] is True
        miss = client.delete("/api/user/preferences/k")
        assert miss.status_code == 200, miss.text
        _assert_keys(miss.json(), {"deleted"}, "UserPreferenceDeleteOut")
        assert miss.json()["deleted"] is False


class TestDeploymentVerificationShapes:
    """``checkDeploymentCatalog`` / ``getDeployedUcSchema`` / ``compareDeployment``:
    each body carries ``verification_error``."""

    def test_model_fields(self):
        from vibe_modeling.backend.models import (
            DeployedUcSchemaOut,
            DeploymentCatalogCheckOut,
            DeploymentVerificationOut,
        )

        assert set(DeploymentCatalogCheckOut.model_fields) == {"exists", "catalog", "error", "verification_error"}
        assert set(DeployedUcSchemaOut.model_fields) == {
            "tables", "columns", "primary_keys", "foreign_keys", "verification_error",
        }
        assert set(DeploymentVerificationOut.model_fields) == {"tables", "summary", "verification_error"}

    def test_compare_route_shape(self, client, seeded_app, mock_ws):
        from _sql_fakes import response, ws_returning

        mock_ws.statement_execution = ws_returning(response([])).statement_execution
        bid, vid = seeded_app["business_id"], seeded_app["version_id"]
        resp = client.get(f"/api/businesses/{bid}/versions/{vid}/deployment/compare")
        assert resp.status_code == 200, resp.text
        _assert_keys(resp.json(), {"tables", "summary", "verification_error"}, "DeploymentVerificationOut")


class TestLinkRunShape:
    """previewLinkRun answers ``LinkRunPreviewOut``; linkRun answers ``RunOut``
    (``TestRunDetailShape``); the import routes take ``databricks_run_id`` and
    answer ``linked_run_id``."""

    PREVIEW_KEYS = {"databricks_run_id", "linkable", "tier", "intent", "evidence", "problems"}

    def test_preview_shape(self, client, engine, mock_ws, seed_business):
        from databricks.sdk.errors import NotFound
        from sqlmodel import Session

        from vibe_modeling.backend.db_models import ModelVersion

        with Session(engine) as s:
            mv = ModelVersion(
                business_id=seed_business, version=1, scope="mvm", status="completed",
                import_source_path="/Volumes/c/_metamodel/vol_root/business/test_corp/v1/mvm/model.json",
            )
            s.add(mv)
            s.commit()
            vid = mv.id
        mock_ws.jobs.get_run.side_effect = NotFound("no such run")
        resp = client.post(
            f"/api/businesses/{seed_business}/versions/{vid}/link-run/preview",
            json={"databricks_run_id": 1},
        )
        assert resp.status_code == 200, resp.text
        _assert_keys(resp.json(), self.PREVIEW_KEYS, "LinkRunPreviewOut")
        assert resp.json()["linkable"] is False

    def test_model_fields(self):
        from vibe_modeling.backend.models import (
            ImportCreateBusinessAndExecuteIn,
            ImportExecuteIn,
            ImportExecuteOut,
            LinkRunIn,
            LinkRunPreviewOut,
        )

        assert set(LinkRunPreviewOut.model_fields) == self.PREVIEW_KEYS
        assert set(LinkRunIn.model_fields) == {"databricks_run_id"}
        assert "databricks_run_id" in ImportExecuteIn.model_fields
        assert "databricks_run_id" in ImportCreateBusinessAndExecuteIn.model_fields
        assert ImportExecuteOut.model_fields["linked_run_id"].default is None


class TestOrphanSchemaShapes:
    """``listOrphanSchemas`` and ``dropOrphanSchemas``. The list's ``impact``
    has the ``getUninstallImpact`` shape."""

    def test_list_fields(self):
        from vibe_modeling.backend.models import OrphanSchemaOut, OrphanSchemasOut

        assert set(OrphanSchemasOut.model_fields) == {"catalog", "schemas", "impact", "confirm_subject"}
        assert set(OrphanSchemaOut.model_fields) == {
            "name", "owner", "owned_by_app", "match", "table_count", "blocked_reason",
        }

    def test_drop_fields(self):
        from vibe_modeling.backend.models import DropOrphanSchemasOut, OrphanSchemaDropOut

        assert set(DropOrphanSchemasOut.model_fields) == {"run_id", "catalog", "schemas", "metamodel_cleanup"}
        assert set(OrphanSchemaDropOut.model_fields) == {"name", "status", "table_count", "error"}

    def test_list_route_shape_with_nothing_to_drop(self, client, engine, mock_ws):
        from types import SimpleNamespace

        from _sql_fakes import response
        from vibe_modeling.backend.db_models import AgentConfig, Business

        with Session(engine) as s:
            s.add(AgentConfig(deployment_catalog="regression_cat", warehouse_id="wh-regression"))
            b = Business(name="Orphan Shape", description="t")
            s.add(b)
            s.commit()
            bid = b.id
        mock_ws.schemas.list.side_effect = lambda **_kw: iter([SimpleNamespace(name="_metamodel", owner="x")])
        mock_ws.statement_execution.execute_statement.side_effect = [
            response([], columns=["business", "version", "model_scope", "database_name", "catalog"]),
            response([], columns=["business", "version", "model_scope", "session_id"]),
        ]
        resp = client.get(f"/api/businesses/{bid}/orphan-schemas")
        assert resp.status_code == 200, resp.text
        assert resp.json() == {
            "catalog": "regression_cat", "schemas": [], "impact": None, "confirm_subject": None,
        }
