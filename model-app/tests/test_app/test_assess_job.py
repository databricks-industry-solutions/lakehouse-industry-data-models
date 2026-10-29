import hashlib
import json
import re
from unittest.mock import MagicMock

import pytest
from databricks.sdk.errors.platform import NotFound

from vibe_modeling.backend.assessment import constants as C
from vibe_modeling.backend.assessment.assets import (
    MANIFEST_NAME, bundle_files, bundle_manifest, read_versions, resolve_vendored_assessment, upload_assessment_assets,
)
from vibe_modeling.backend.assessment.job import setup_assessment_job


@pytest.mark.parametrize("raw,expected", [
    ("sales_order", "sales_order"), ("Sales Order", "Sales_Order"),
    ("../etc", "___etc"), ("a/b.c", "a_b_c"), ("", "_"),
])
def test_domain_segment_is_path_safe(raw, expected):
    assert C.domain_segment(raw) == expected


def test_domain_out_dir():
    assert C.domain_out_dir("vibe_modeling", "b1", "sales order") == \
        "/Volumes/vibe_modeling/_metamodel/assess_runs/b1/sales_order"


def test_setup_creates_job_running_as_reader():
    ws = MagicMock(); ws.jobs.create.return_value.job_id = 42
    jid = setup_assessment_job(ws, job_id=None, notebook_path="/Users/app-sp/vibe-assess/0.8.0/assess_domain",
                               reader_application_id="app-123", max_concurrent_runs=2)
    assert jid == 42
    kw = ws.jobs.create.call_args.kwargs
    assert kw["name"] == C.JOB_NAME
    assert kw["run_as"].service_principal_name == "app-123"
    assert kw["queue"].enabled is True and kw["max_concurrent_runs"] == 2
    assert [p.name for p in kw["parameters"]] == ["config_path"]
    assert kw["tasks"][0].notebook_task.base_parameters == {"config_path": "{{job.parameters.config_path}}"}
    assert kw["tasks"][0].timeout_seconds == 10800


def test_setup_resets_existing_job():
    ws = MagicMock()
    assert setup_assessment_job(ws, job_id=7, notebook_path="/n", reader_application_id="a",
                                max_concurrent_runs=3) == 7
    ws.jobs.reset.assert_called_once()
    assert ws.jobs.reset.call_args.kwargs["new_settings"].run_as.service_principal_name == "a"
    ws.jobs.create.assert_not_called()


def test_setup_recreates_when_job_deleted():
    ws = MagicMock(); ws.jobs.reset.side_effect = NotFound("gone"); ws.jobs.create.return_value.job_id = 9
    assert setup_assessment_job(ws, job_id=7, notebook_path="/n", reader_application_id="a", max_concurrent_runs=2) == 9


def test_setup_propagates_other_errors():
    ws = MagicMock(); ws.jobs.create.side_effect = RuntimeError("cannot act as SP")
    with pytest.raises(RuntimeError):
        setup_assessment_job(ws, job_id=None, notebook_path="/n", reader_application_id="a", max_concurrent_runs=2)


def test_upload_assets_writes_files_then_the_manifest_last():
    ws = MagicMock()
    ws.workspace.download.side_effect = NotFound("no manifest")
    assert upload_assessment_assets(ws, "/Users/app-sp/vibe-assess/0.8.0") is True
    folder = "/Users/app-sp/vibe-assess/0.8.0"
    order = [c.args[0] for c in ws.workspace.upload.call_args_list]
    assert f"{folder}/assess_domain" in order            # notebook, no extension
    assert f"{folder}/assess_lib.py" in order
    assert f"{folder}/skills/domain-model-assessment/SKILL.md" in order
    assert f"{folder}/skills/domain-model-assessment/.vibe-skill-version" in order  # the run records it
    assert not any("__pycache__" in u or ("/." in u and not u.endswith("/.vibe-skill-version")) for u in order)
    assert order[-1] == f"{folder}/{MANIFEST_NAME}"
    manifest = json.loads(ws.workspace.upload.call_args_list[-1].args[1].getvalue())
    assert manifest["assess_domain.py"] == hashlib.sha256(
        (resolve_vendored_assessment() / "assess_domain.py").read_bytes()).hexdigest()
    ws.permissions.update.assert_not_called()


def test_upload_assets_skips_when_the_manifest_matches():
    root, files = bundle_files()
    ws = MagicMock()
    ws.workspace.download.return_value.read.return_value = bundle_manifest(root, files)
    assert upload_assessment_assets(ws, "/Users/app-sp/vibe-assess/0.8.0") is False
    ws.workspace.upload.assert_not_called(); ws.workspace.mkdirs.assert_not_called()


def test_upload_assets_redoes_a_partial_upload():
    ws = MagicMock()
    ws.workspace.download.return_value.read.return_value = b'{"assess_domain.py": "stale"}'
    assert upload_assessment_assets(ws, "/Users/app-sp/vibe-assess/0.8.0") is True


def test_setup_leaves_a_matching_job_alone():
    from databricks.sdk.service.jobs import JobSettings

    from vibe_modeling.backend.assessment.job import _settings
    ws = MagicMock()
    ws.jobs.get.return_value.settings = JobSettings(**_settings("/n", "a", 2))
    assert setup_assessment_job(ws, job_id=7, notebook_path="/n", reader_application_id="a", max_concurrent_runs=2) == 7
    ws.jobs.reset.assert_not_called(); ws.jobs.create.assert_not_called()


@pytest.mark.parametrize("field,value", [("notebook_path", "/other"), ("reader_application_id", "b"),
                                         ("max_concurrent_runs", 3)])
def test_setup_resets_when_a_field_differs(field, value):
    from databricks.sdk.service.jobs import JobSettings

    from vibe_modeling.backend.assessment.job import _settings
    want = {"notebook_path": "/n", "reader_application_id": "a", "max_concurrent_runs": 2}
    ws = MagicMock()
    ws.jobs.get.return_value.settings = JobSettings(**_settings(*want.values()))
    want[field] = value
    assert setup_assessment_job(ws, job_id=7, **want) == 7
    ws.jobs.reset.assert_called_once()


def test_setup_creates_when_get_says_the_job_is_gone():
    ws = MagicMock(); ws.jobs.get.side_effect = NotFound("gone"); ws.jobs.create.return_value.job_id = 9
    assert setup_assessment_job(ws, job_id=7, notebook_path="/n", reader_application_id="a", max_concurrent_runs=2) == 9
    ws.jobs.reset.assert_not_called()


def test_read_versions_has_pins():
    v = read_versions()
    assert re.fullmatch(r"[0-9a-f]{40}", v["skills_ref"]) and v["skills_version"] == "0.5.0"
    assert "genie_version" not in v
