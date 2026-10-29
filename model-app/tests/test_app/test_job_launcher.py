"""Test the job_launcher.py module — session IDs, parameter mapping, model-producing ops."""

import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "..", "src", "app", "src"))

from unittest.mock import MagicMock, patch

import pytest

from vibe_modeling.backend.job_launcher import (
    VIBE_INSTRUCTIONS_INLINE_LIMIT,
    build_job_tags,
    generate_session_id,
    is_model_producing,
    launch_run,
    map_run_params_to_widgets,
    resolve_vibe_instructions_widget,
    sanitize_tag,
    session_id_to_bigint,
    vibe_instructions_volume_path,
    write_vibe_instructions_to_volume,
)
from vibe_modeling.backend.db_models import Business


class TestGenerateSessionId:
    def test_returns_valid_uuid(self):
        sid = generate_session_id()
        assert isinstance(sid, str)
        assert len(sid) == 36
        assert sid.count("-") == 4

    def test_unique_each_call(self):
        s1 = generate_session_id()
        s2 = generate_session_id()
        assert s1 != s2


class TestSessionIdToBigint:
    def test_known_input(self):
        result = session_id_to_bigint("test-uuid")
        assert isinstance(result, int)
        assert result > 0
        # Must fit in 63 bits (positive BIGINT)
        assert result < (1 << 63)

    def test_deterministic(self):
        r1 = session_id_to_bigint("same-input")
        r2 = session_id_to_bigint("same-input")
        assert r1 == r2

    def test_different_inputs_differ(self):
        r1 = session_id_to_bigint("input-a")
        r2 = session_id_to_bigint("input-b")
        assert r1 != r2


class TestSanitizeTag:
    def test_special_chars_replaced(self):
        result = sanitize_tag("hello@world#test$value")
        assert "@" not in result
        assert "#" not in result
        assert "$" not in result
        # Replaced with underscore
        assert "_" in result

    def test_truncation(self):
        long_string = "a" * 300
        result = sanitize_tag(long_string)
        assert len(result) == 256

    def test_allowed_chars_preserved(self):
        # Only A-Za-z0-9, underscores, hyphens, dots per Integration Guide
        allowed = "abc-123_test.value"
        assert sanitize_tag(allowed) == allowed


class TestMapRunParams:
    def _make_business(self, name="test_corp", description="A test company", industry="Retail"):
        return Business(name=name, description=description, industry_alignment=industry)

    def test_all_widget_keys_present_for_base_model(self):
        business = self._make_business()
        widgets = map_run_params_to_widgets(
            operation="new base model",
            business=business,
            catalog="my_catalog",
            session_id="test-session-id",
            runtime_budget_seconds=21600,
            vibe_instructions="",
            model_size="small model",
            business_context_path="/Volumes/test/ctx/ctx.json",
        )
        assert widgets["operation"] == "new base model"
        assert widgets["business_name"] == "test_corp"
        assert widgets["business_description"] == "A test company"
        assert widgets["context_file"] == "/Volumes/test/ctx/ctx.json"
        assert widgets["deployment_catalog"] == "my_catalog"
        assert widgets["data_model_scopes"] == "Minimum Viable Model - MVM"
        assert widgets["model_vibes"] == ""
        # Widget receives the BIGINT-as-string derivation (SHA-256 truncation),
        # not the raw UUID — agent's int(_raw_sid) parse needs an integer.
        from vibe_modeling.backend.job_launcher import session_id_to_bigint
        assert widgets["vibe_session_id"] == str(session_id_to_bigint("test-session-id"))
        assert widgets["industry_alignment"] == "Retail"

    def test_model_size_mapping_small(self):
        business = self._make_business()
        widgets = map_run_params_to_widgets(
            operation="new base model", business=business, catalog="c", session_id="s",
            runtime_budget_seconds=21600,
            model_size="small model",
        )
        assert widgets["data_model_scopes"] == "Minimum Viable Model - MVM"

    def test_model_size_mapping_large(self):
        business = self._make_business()
        widgets = map_run_params_to_widgets(
            operation="new base model", business=business, catalog="c", session_id="s",
            runtime_budget_seconds=21600,
            model_size="large model",
        )
        assert widgets["data_model_scopes"] == "Expanded Coverage Model - ECM"

    def test_no_generate_samples_widget(self):
        """Agent 5.3.3 has no ``generate_samples`` widget (X18), so the app sends none."""
        business = self._make_business()
        widgets = map_run_params_to_widgets(
            operation="new base model", business=business, catalog="c", session_id="s",
            runtime_budget_seconds=21600,
        )
        assert "generate_samples" not in widgets

    def test_business_name_normalized(self):
        business = self._make_business(name="Acme Telecom Corp")
        widgets = map_run_params_to_widgets(
            operation="new base model", business=business, catalog="c", session_id="s",
            runtime_budget_seconds=21600,
        )
        assert widgets["business_name"] == "acme_telecom_corp"


class TestBuildJobTags:
    """``collect_statistics=False`` (the builder's own default) emits no identity tags.

    The flag is Settings -> Agent -> "Annotate jobs with run tags"
    (``AgentConfig.collect_vibe_run_statistics``, on by default); when on, the
    business name, session id and notebook filename are added. The app
    identity tags are always on; outside the Apps runtime (the test default,
    ``DATABRICKS_APP_NAME`` unset) the app name key is left out.
    """

    _NON_IDENTITY_KEYS = {
        "managed_by",
        "dbx_vibe_modelling_app_version",
        "dbx_vibe_modelling_launcher_source",
        "dbx_vibe_modelling_model",
        "dbx_vibe_modelling_operation",
        "dbx_vibe_modelling_domains",
        "dbx_vibe_modelling_products",
        "dbx_vibe_modelling_attributes",
        "dbx_vibe_modelling_foreign_keys",
        "dbx_vibe_modelling_tags",
        "dbx_vibe_modelling_metrics",
    }
    _IDENTITY_KEYS = {
        "dbx_vibe_modelling_business",
        "dbx_vibe_modelling_session_id",
        "dbx_vibe_modelling_notebook",
    }

    def test_default_emits_only_non_identity_tags(self):
        tags = build_job_tags(
            business_name="Test Corp",
            model_scope="Minimum Viable Model - MVM",
            version="1",
            operation="new base model",
            notebook_path="/Workspace/Users/admin/vibe_agent_v27.py",
            session_id="abc-123-def",
        )
        assert set(tags.keys()) == self._NON_IDENTITY_KEYS
        assert not (set(tags.keys()) & self._IDENTITY_KEYS)

    def test_collect_statistics_true_emits_full_tag_set(self):
        tags = build_job_tags(
            business_name="Test Corp",
            model_scope="Minimum Viable Model - MVM",
            version="1",
            operation="new base model",
            notebook_path="/Workspace/Users/admin/vibe_agent_v27.py",
            session_id="abc-123-def",
            collect_statistics=True,
        )
        assert set(tags.keys()) == self._NON_IDENTITY_KEYS | self._IDENTITY_KEYS

    def test_launcher_source_is_vibe_modeling_app(self):
        tags = build_job_tags()
        assert tags["dbx_vibe_modelling_launcher_source"] == "vibe_modeling_app"

    def test_managed_by_is_vibe_modeling_app(self):
        tags = build_job_tags()
        assert tags["managed_by"] == "vibe_modeling_app"

    def test_notebook_tag_filename_only_when_opted_in(self):
        tags = build_job_tags(
            notebook_path="/Workspace/Users/admin/vibe_agent_v27.py",
            collect_statistics=True,
        )
        # Workspace folder is stripped — filename only — to minimise leakage
        # even in the opt-in case.
        assert tags["dbx_vibe_modelling_notebook"] == "vibe_agent_v27.py"

    def test_session_id_tag_value_when_opted_in(self):
        tags = build_job_tags(
            session_id="a1b2c3d4-e5f6-7890-abcd-ef1234567890",
            collect_statistics=True,
        )
        assert tags["dbx_vibe_modelling_session_id"] == "a1b2c3d4-e5f6-7890-abcd-ef1234567890"

    def test_empty_notebook_and_session_when_opted_in(self):
        tags = build_job_tags(collect_statistics=True)
        assert tags["dbx_vibe_modelling_notebook"] == ""
        assert tags["dbx_vibe_modelling_session_id"] == ""

    def test_count_tags_start_at_zero(self):
        tags = build_job_tags(business_name="biz", model_scope="MVM", version="1", operation="op")
        for count_key in ("domains", "products", "attributes", "foreign_keys", "tags", "metrics"):
            assert tags[f"dbx_vibe_modelling_{count_key}"] == "0"

    def test_business_name_sanitized_when_opted_in(self):
        tags = build_job_tags(
            business_name="Acme Corp!",
            model_scope="MVM",
            version="1",
            operation="op",
            collect_statistics=True,
        )
        value = tags["dbx_vibe_modelling_business"]
        assert " " not in value
        assert "!" not in value
        assert value == "Acme_Corp"

    def test_model_tag_mvm(self):
        tags = build_job_tags(business_name="b", model_scope="Minimum Viable Model - MVM", version="2")
        assert tags["dbx_vibe_modelling_model"] == "mvm_v2"

    def test_model_tag_ecm(self):
        tags = build_job_tags(business_name="b", model_scope="Expanded Coverage Model - ECM", version="3")
        assert tags["dbx_vibe_modelling_model"] == "ecm_v3"

    def test_model_tag_no_version(self):
        tags = build_job_tags(business_name="b", model_scope="MVM")
        assert tags["dbx_vibe_modelling_model"] == "mvm"

    def test_operation_sanitized(self):
        tags = build_job_tags(operation="new base model")
        assert tags["dbx_vibe_modelling_operation"] == "new_base_model"


class TestJobTagsForConfig:
    """The one reader of the run-tags setting and notebook path off an AgentConfig."""

    _IDENTITY = {"dbx_vibe_modelling_business", "dbx_vibe_modelling_session_id", "dbx_vibe_modelling_notebook"}

    def _cfg(self, collect):
        from vibe_modeling.backend.db_models import AgentConfig
        return AgentConfig(notebook_path="/Workspace/Users/me/agent_v27.py", collect_vibe_run_statistics=collect)

    def test_setting_on_adds_identity_tags(self):
        from vibe_modeling.backend.job_launcher import job_tags_for_config
        tags = job_tags_for_config(self._cfg(True), business_name="Acme Corp", operation="op", session_id="abc")
        assert tags["dbx_vibe_modelling_business"] == "Acme_Corp"
        assert tags["dbx_vibe_modelling_session_id"] == "abc"
        assert tags["dbx_vibe_modelling_notebook"] == "agent_v27.py"

    def test_setting_off_leaves_identity_tags_out(self):
        from vibe_modeling.backend.job_launcher import job_tags_for_config
        tags = job_tags_for_config(self._cfg(False), business_name="Acme", operation="op", session_id="abc")
        assert not (set(tags) & self._IDENTITY)
        assert tags["managed_by"] == "vibe_modeling_app"

    def test_no_config_reads_as_off(self):
        from vibe_modeling.backend.job_launcher import job_tags_for_config
        tags = job_tags_for_config(None, business_name="Acme", operation="op", session_id="abc")
        assert not (set(tags) & self._IDENTITY)

    def test_matches_build_job_tags(self):
        from vibe_modeling.backend.job_launcher import job_tags_for_config
        kw = dict(business_name="b", model_scope="MVM", version="2", operation="op", session_id="s")
        assert job_tags_for_config(self._cfg(True), **kw) == build_job_tags(
            notebook_path="/Workspace/Users/me/agent_v27.py", collect_statistics=True, **kw)


class TestBuildJobTagsFromSession:
    """The wrapper that production dispatch sites use to look up the toggle
    + notebook_path off the singleton AgentConfig before calling build_job_tags.
    Regression coverage for the bug where multiple launch_run call sites
    (new-base-model orchestrator, install, uninstall, generate_samples)
    silently bypassed the toggle because they didn't tag at all.
    """

    def _session_returning(self, cfg):
        from unittest.mock import MagicMock
        session = MagicMock()
        chain = MagicMock()
        chain.first.return_value = cfg
        session.exec.return_value = chain
        return session

    def test_no_agent_config_falls_back_to_default_off(self):
        from vibe_modeling.backend.job_launcher import build_job_tags_from_session
        tags = build_job_tags_from_session(
            self._session_returning(None),
            business_name="biz",
            operation="op",
        )
        # No AgentConfig row → default OFF, only non-identity tags.
        assert "dbx_vibe_modelling_business" not in tags
        assert "dbx_vibe_modelling_session_id" not in tags
        assert "dbx_vibe_modelling_notebook" not in tags
        assert tags["dbx_vibe_modelling_launcher_source"] == "vibe_modeling_app"

    def test_agent_config_with_collect_off_omits_identity(self):
        from unittest.mock import MagicMock
        from vibe_modeling.backend.job_launcher import build_job_tags_from_session
        cfg = MagicMock()
        cfg.collect_vibe_run_statistics = False
        cfg.notebook_path = "/Workspace/agent.py"
        tags = build_job_tags_from_session(
            self._session_returning(cfg),
            business_name="biz",
            operation="op",
            session_id="abc",
        )
        assert "dbx_vibe_modelling_business" not in tags
        assert "dbx_vibe_modelling_session_id" not in tags
        assert "dbx_vibe_modelling_notebook" not in tags

    def test_agent_config_with_collect_on_includes_identity(self):
        from unittest.mock import MagicMock
        from vibe_modeling.backend.job_launcher import build_job_tags_from_session
        cfg = MagicMock()
        cfg.collect_vibe_run_statistics = True
        cfg.notebook_path = "/Workspace/Users/me/agent_v27.py"
        tags = build_job_tags_from_session(
            self._session_returning(cfg),
            business_name="biz",
            operation="op",
            session_id="abc",
        )
        assert tags["dbx_vibe_modelling_business"] == "biz"
        assert tags["dbx_vibe_modelling_session_id"] == "abc"
        assert tags["dbx_vibe_modelling_notebook"] == "agent_v27.py"  # filename-only

    def test_bare_mock_session_falls_back_safely(self):
        """Tests that pass a bare MagicMock as session must not crash. The
        helper has to tolerate the wrong shape and produce a safe default
        rather than letting MagicMocks leak into sanitize_tag."""
        from unittest.mock import MagicMock
        from vibe_modeling.backend.job_launcher import build_job_tags_from_session
        tags = build_job_tags_from_session(
            MagicMock(),  # session that returns MagicMocks all the way down
            business_name="biz",
            operation="op",
        )
        # Should produce the default-OFF tag set; never raise.
        assert isinstance(tags, dict)
        assert "dbx_vibe_modelling_business" not in tags
        assert tags["managed_by"] == "vibe_modeling_app"


class TestLaunchRunWithJobTags:
    def test_job_tags_triggers_update(self):
        """When job_tags is provided, ws.jobs.update is called with a typed
        JobSettings(tags=...) before run_now. databricks-sdk 0.112.0 rejects
        raw-dict new_settings — the bare except in launch_run was previously
        masking that, so tags never landed on the job. Lock the typed shape
        here so a regression to the dict form fails CI immediately."""
        from databricks.sdk.service.jobs import JobSettings

        mock_ws = MagicMock()
        mock_ws.jobs.run_now.return_value = MagicMock(run_id=42)

        tags = {"managed_by": "test", "dbx_vibe_modelling_business": "biz"}
        launch_run(mock_ws, job_id=123, widget_params={"operation": "test"}, job_tags=tags)

        mock_ws.jobs.update.assert_called_once()
        call_kwargs = mock_ws.jobs.update.call_args.kwargs
        assert call_kwargs["job_id"] == 123
        new_settings = call_kwargs["new_settings"]
        assert isinstance(new_settings, JobSettings), (
            f"new_settings must be JobSettings; got {type(new_settings).__name__} "
            f"— raw-dict form is silently rejected by the SDK"
        )
        assert new_settings.tags == tags
        mock_ws.jobs.run_now.assert_called_once()

    def test_no_tags_skips_update(self):
        """When job_tags is None, ws.jobs.update is NOT called."""
        mock_ws = MagicMock()
        mock_ws.jobs.run_now.return_value = MagicMock(run_id=42)

        launch_run(mock_ws, job_id=123, widget_params={"operation": "test"})

        mock_ws.jobs.update.assert_not_called()
        mock_ws.jobs.run_now.assert_called_once()

    def test_tag_update_failure_non_fatal(self):
        """If ws.jobs.update raises, launch_run still proceeds with run_now."""
        mock_ws = MagicMock()
        mock_ws.jobs.update.side_effect = RuntimeError("Permission denied")
        mock_ws.jobs.run_now.return_value = MagicMock(run_id=99)

        result = launch_run(mock_ws, job_id=123, widget_params={}, job_tags={"k": "v"})
        assert result == 99
        mock_ws.jobs.run_now.assert_called_once()


class TestAsciiSanitization:
    """Databricks Jobs API rejects non-Latin1 characters in notebook_params.
    launch_run sanitizes widget values before submitting."""

    def test_en_dash_becomes_hyphen(self):
        from vibe_modeling.backend.job_launcher import _sanitize_widget_params_to_ascii

        out = _sanitize_widget_params_to_ascii({
            "model_vibes": "use 5\u20138 attributes per product",
        })
        assert out["model_vibes"] == "use 5-8 attributes per product"

    def test_typographic_quotes_become_ascii(self):
        from vibe_modeling.backend.job_launcher import _sanitize_widget_params_to_ascii

        out = _sanitize_widget_params_to_ascii({
            "business_description": "Amazon\u2019s platform \u201cretail\u201d",
        })
        assert out["business_description"] == "Amazon's platform \"retail\""

    def test_accented_letters_decompose_to_ascii(self):
        """NFKD normalisation: é → e, ñ → n."""
        from vibe_modeling.backend.job_launcher import _sanitize_widget_params_to_ascii

        out = _sanitize_widget_params_to_ascii({"name": "Café Piña"})
        assert out["name"] == "Cafe Pina"

    def test_pure_ascii_passthrough(self):
        from vibe_modeling.backend.job_launcher import _sanitize_widget_params_to_ascii

        original = {
            "operation": "new base model",
            "business_name": "qa-test-20260421",
            "model_vibes": "Generate exactly 2 domains.",
        }
        assert _sanitize_widget_params_to_ascii(original) == original

    def test_launch_run_sanitizes_before_submit(self):
        """End-to-end: launch_run hands already-sanitized params to ws.jobs.run_now."""
        mock_ws = MagicMock()
        mock_ws.jobs.run_now.return_value = MagicMock(run_id=77)

        launch_run(mock_ws, job_id=55, widget_params={
            "model_vibes": "rule: 5\u20138 attrs per product",  # en-dash
            "business_description": "Salesforce\u2019s platform",  # typographic apostrophe
        })

        call = mock_ws.jobs.run_now.call_args
        submitted = call.kwargs["notebook_params"]
        assert submitted["model_vibes"] == "rule: 5-8 attrs per product"
        assert submitted["business_description"] == "Salesforce's platform"


class TestVibeInstructionsVolume:
    def test_path_layout(self):
        path = vibe_instructions_volume_path(
            catalog="mycat",
            business_name="Acme Corp",
            session_id="abc-123",
        )
        assert path == (
            "/Volumes/mycat/_metamodel/vol_root/business/acme_corp"
            "/_vibe_inputs/abc-123.txt"
        )

    def test_upload_returns_path_and_writes_utf8(self):
        mock_ws = MagicMock()
        path = write_vibe_instructions_to_volume(
            mock_ws,
            catalog="mycat",
            business_name="Acme Corp",
            session_id="sid",
            instructions="rules with unicode - e",
        )
        assert path.endswith("/_vibe_inputs/sid.txt")
        mock_ws.files.upload.assert_called_once()
        args, kwargs = mock_ws.files.upload.call_args
        assert args[0] == path
        buf = args[1]
        assert buf.read() == "rules with unicode - e".encode("utf-8")
        assert kwargs.get("overwrite") is True

    def test_resolve_short_stays_inline(self):
        mock_ws = MagicMock()
        widget, path = resolve_vibe_instructions_widget(
            mock_ws,
            catalog="c",
            business_name="acme",
            session_id="s",
            instructions="short rules",
        )
        assert widget == "short rules"
        assert path == ""
        mock_ws.files.upload.assert_not_called()

    def test_resolve_long_offloads_to_volume(self):
        mock_ws = MagicMock()
        long = "x" * (VIBE_INSTRUCTIONS_INLINE_LIMIT + 100)
        widget, path = resolve_vibe_instructions_widget(
            mock_ws,
            catalog="c",
            business_name="acme",
            session_id="s",
            instructions=long,
        )
        assert widget == path
        assert path.startswith("/Volumes/c/_metamodel/vol_root/business/acme/_vibe_inputs/")
        mock_ws.files.upload.assert_called_once()

    def test_resolve_no_catalog_falls_back_to_inline(self):
        mock_ws = MagicMock()
        long = "x" * (VIBE_INSTRUCTIONS_INLINE_LIMIT + 100)
        widget, path = resolve_vibe_instructions_widget(
            mock_ws,
            catalog="",
            business_name="acme",
            session_id="s",
            instructions=long,
        )
        assert widget == long
        assert path == ""
        mock_ws.files.upload.assert_not_called()

    def test_model_vibes_only_widget(self):
        business = Business(name="Acme", description="", industry_alignment="")
        widgets = map_run_params_to_widgets(
            operation="new base model", business=business, catalog="c", session_id="s",
            runtime_budget_seconds=21600,
            vibe_instructions="/Volumes/c/_metamodel/vol_root/business/acme/_vibe_inputs/s.txt",
        )
        # The agent has a single `model_vibes` widget; a path value is routed
        # to the file resolver by the agent itself.
        assert widgets["model_vibes"].endswith("/_vibe_inputs/s.txt")
        assert "model_vibes_file" not in widgets

    def test_inline_limit_below_widget_cap(self):
        # Widget params hard-fail at ~2k chars; we need headroom.
        assert VIBE_INSTRUCTIONS_INLINE_LIMIT < 2000


class TestIsModelProducing:
    def test_model_producing_ops(self):
        assert is_model_producing("new base model") is True
        assert is_model_producing("vibe modeling of version") is True
        assert is_model_producing("shrink ecm") is True
        assert is_model_producing("enlarge mvm") is True

    def test_lifecycle_ops(self):
        assert is_model_producing("install model") is False
        assert is_model_producing("uninstall model version") is False
        assert is_model_producing("generate sample data") is False

    def test_unknown_op(self):
        assert is_model_producing("something random") is False


class TestLaunchRunEnsureProgressSchemaHook:
    """Pre-launch hook for legacy STRING `_vibe_progress.result_json` (#115)."""

    def test_called_for_model_producing_op(self):
        """For model-producing ops, ensure_progress_schema is called with (ws, warehouse, catalog)."""
        mock_ws = MagicMock()
        mock_ws.jobs.run_now.return_value = MagicMock(run_id=1)
        with patch(
            "vibe_modeling.backend.job_launcher.ensure_progress_schema"
        ) as mock_ensure:
            launch_run(
                mock_ws,
                job_id=10,
                widget_params={
                    "operation": "new base model",
                    "deployment_catalog": "cat_a",
                },
                warehouse_id="wh-xyz",
            )
        mock_ensure.assert_called_once()
        args, kwargs = mock_ensure.call_args
        assert args[0] is mock_ws
        assert args[1] == "wh-xyz"
        assert args[2] == "cat_a"
        assert kwargs.get("strategy") == "drop"

    def test_not_called_for_install_model(self):
        mock_ws = MagicMock()
        mock_ws.jobs.run_now.return_value = MagicMock(run_id=1)
        with patch(
            "vibe_modeling.backend.job_launcher.ensure_progress_schema"
        ) as mock_ensure:
            launch_run(
                mock_ws,
                job_id=10,
                widget_params={
                    "operation": "install model",
                    "deployment_catalog": "cat_a",
                },
                warehouse_id="wh-xyz",
            )
        mock_ensure.assert_not_called()

    def test_not_called_when_warehouse_missing(self):
        """No warehouse_id → skip (keeps legacy callers that don't pass warehouse safe)."""
        mock_ws = MagicMock()
        mock_ws.jobs.run_now.return_value = MagicMock(run_id=1)
        with patch(
            "vibe_modeling.backend.job_launcher.ensure_progress_schema"
        ) as mock_ensure:
            launch_run(
                mock_ws,
                job_id=10,
                widget_params={
                    "operation": "new base model",
                    "deployment_catalog": "cat_a",
                },
            )
        mock_ensure.assert_not_called()

    def test_hook_failure_does_not_block_launch(self):
        """A raise from ensure_progress_schema must not prevent run_now."""
        mock_ws = MagicMock()
        mock_ws.jobs.run_now.return_value = MagicMock(run_id=77)
        with patch(
            "vibe_modeling.backend.job_launcher.ensure_progress_schema",
            side_effect=RuntimeError("boom"),
        ):
            result = launch_run(
                mock_ws,
                job_id=10,
                widget_params={
                    "operation": "new base model",
                    "deployment_catalog": "cat_a",
                },
                warehouse_id="wh-xyz",
            )
        assert result == 77
        mock_ws.jobs.run_now.assert_called_once()



class TestEmptyDeploymentCatalog:
    """A model-producing op with no ``deployment_catalog`` is refused: the
    agent would derive a catalog from the business name (nb 55985-55992)."""

    MODEL_OPS = ("new base model", "vibe modeling of version", "shrink ecm", "enlarge mvm")

    def test_build_widget_map_refuses_every_model_producing_op(self):
        from vibe_modeling.backend.core._widgets import empty_catalog_message
        from vibe_modeling.backend.services.operations._generation_common import build_generation_widgets

        business = Business(name="test_corp", description="d")
        for op in self.MODEL_OPS:
            for catalog in ("", "   "):
                with pytest.raises(ValueError) as exc:
                    map_run_params_to_widgets(
                        operation=op, business=business, catalog=catalog, session_id="s",
                        runtime_budget_seconds=60, model_version="1",
                    )
                assert str(exc.value) == empty_catalog_message(op)
                with pytest.raises(ValueError, match="needs a deployment catalog"):
                    build_generation_widgets(
                        operation=op, data_model_scopes="Expanded Coverage Model - ECM", business=business,
                        catalog=catalog, session_id="s", runtime_budget_seconds=60, vibe_instructions="",
                        business_context_path="", business_description_override="", model_version="1",
                        schema_prefix="", naming_convention="snake_case", primary_key_suffix="_id",
                        schema_suffix="", tag_prefix="dbx_", tag_suffix="", table_id_type="BIGINT",
                        boolean_format="", date_format="yyyy-MM-dd", timestamp_format="yyyy-MM-dd HH:mm:ss",
                        cataloging_style="One Catalog", catalog_prefix="", catalog_suffix="",
                        org_divisions="Operations", business_domains="", classification_levels="",
                        housekeeping_columns="No", history_tracking_columns="No",
                    )

    def test_build_widget_map_keeps_lifecycle_ops(self):
        widgets = map_run_params_to_widgets(
            operation="install model", business=Business(name="test_corp", description="d"), catalog="",
            session_id="s", runtime_budget_seconds=60, model_version="1",
        )
        assert widgets["deployment_catalog"] == ""

    def test_launch_run_refuses_before_any_workspace_call(self):
        for op in self.MODEL_OPS:
            for params in ({"operation": op}, {"operation": op, "deployment_catalog": ""},
                           {"operation": op, "deployment_catalog": "  "}):
                mock_ws = MagicMock()
                with patch("vibe_modeling.backend.job_launcher.ensure_progress_schema") as mock_ensure:
                    with pytest.raises(ValueError, match="needs a deployment catalog"):
                        launch_run(mock_ws, job_id=10, widget_params=params, job_tags={"k": "v"},
                                   warehouse_id="wh-xyz")
                mock_ensure.assert_not_called()
                mock_ws.jobs.update.assert_not_called()
                mock_ws.jobs.run_now.assert_not_called()

    def test_launch_run_keeps_lifecycle_ops_without_a_catalog(self):
        mock_ws = MagicMock()
        mock_ws.jobs.run_now.return_value = MagicMock(run_id=5)
        assert launch_run(mock_ws, job_id=10, widget_params={"operation": "install model"}) == 5
