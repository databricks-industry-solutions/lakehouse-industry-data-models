"""``core/_job_tags``: one home for tag keys and values, and the app identity tags on every job.

- ``app_identity_tags`` carries ``managed_by``, the app name (left out when empty)
  and the app version, all sanitized; ``sanitize_tag`` lives here and ``core/_names``
  re-exports the same function.
- The module loads by file path with no package (``install/tag_app.py`` does that).
- Each job site carries the app identity tags: the per-run builder
  (``build_job_tags``), the agent job (``setup_agent_job``) and the assessment job.
  The name tag follows ``DATABRICKS_APP_NAME``; the version tag is ``vibe_modeling.__version__``
  (sanitized: a release version like ``0.9.0`` is unchanged, a local build's ``+`` becomes ``_``).
"""

from __future__ import annotations

import importlib.util
import sys
from pathlib import Path
from unittest.mock import MagicMock

import pytest

from vibe_modeling import __version__
from vibe_modeling.backend.core import _job_tags, _names
from vibe_modeling.backend.core._job_tags import (
    IDENTITY_TAG_KEYS,
    TAG_APP,
    TAG_APP_VERSION,
    TAG_MANAGED_BY,
    app_identity_tags,
    sanitize_tag,
)

JOB_TAGS_FILE = Path(_job_tags.__file__)
APP_NAME = "vibe-modeling-test"


def test_app_identity_tags_full_set():
    assert app_identity_tags("vibe-modeling-fe", "0.9.0") == {
        "managed_by": "vibe_modeling_app",
        "dbx_vibe_modelling_app": "vibe-modeling-fe",
        "dbx_vibe_modelling_app_version": "0.9.0",
    }


@pytest.mark.parametrize("name", ["", None])
def test_app_identity_tags_omit_an_empty_name(name):
    tags = app_identity_tags(name, "0.9.0")
    assert TAG_APP not in tags
    assert tags[TAG_APP_VERSION] == "0.9.0"


def test_app_identity_tags_sanitize_values():
    tags = app_identity_tags("my app!", "0.9.0+local build")
    assert tags[TAG_APP] == "my_app"
    assert tags[TAG_APP_VERSION] == "0.9.0_local_build"


@pytest.mark.parametrize("cut", ["-", "_", "."])
def test_sanitize_tag_never_ends_on_a_separator_after_truncation(cut):
    value = "a" * 255 + cut + "bbb"
    result = sanitize_tag(value)
    assert result == "a" * 255
    assert len(result) <= 256


def test_identity_keys():
    assert IDENTITY_TAG_KEYS == (
        "dbx_vibe_modelling_business", "dbx_vibe_modelling_session_id", "dbx_vibe_modelling_notebook",
    )


def test_names_reexports_the_same_sanitizer():
    assert _names.sanitize_tag is _job_tags.sanitize_tag


def test_loads_by_file_path_without_the_package():
    spec = importlib.util.spec_from_file_location("_job_tags_by_path", JOB_TAGS_FILE)
    module = importlib.util.module_from_spec(spec)
    assert spec.loader is not None
    spec.loader.exec_module(module)
    assert module.app_identity_tags("a", "1") == app_identity_tags("a", "1")


def test_imports_only_the_standard_library():
    import ast

    tree = ast.parse(JOB_TAGS_FILE.read_text())
    imported = set()
    for node in ast.walk(tree):
        if isinstance(node, ast.Import):
            imported |= {a.name.split(".")[0] for a in node.names}
        elif isinstance(node, ast.ImportFrom):
            assert node.level == 0, "relative imports break loading by file path"
            imported.add((node.module or "").split(".")[0])
    assert imported <= set(sys.stdlib_module_names) | {"__future__"}


# --- the three job sites ---------------------------------------------------


def _agent_job_tags() -> dict:
    from vibe_modeling.backend.db_models import AgentConfig
    from vibe_modeling.backend.job_launcher import setup_agent_job

    ws = MagicMock()
    ws.jobs.create.return_value.job_id = 1
    setup_agent_job(ws, AgentConfig(notebook_path="/Users/sp/agent", job_name="dbx_vibe_modelling"))
    return ws.jobs.create.call_args.kwargs["tags"]


def _run_tags() -> dict:
    from vibe_modeling.backend.job_launcher import build_job_tags

    return build_job_tags(business_name="b", operation="op", collect_statistics=True)


def _assessment_job_tags() -> dict:
    from vibe_modeling.backend.assessment.job import setup_assessment_job

    ws = MagicMock()
    ws.jobs.create.return_value.job_id = 1
    setup_assessment_job(ws, job_id=None, notebook_path="/n", reader_application_id="r", max_concurrent_runs=2)
    return ws.jobs.create.call_args.kwargs["tags"]


SITES = {"per_run": _run_tags, "agent_job": _agent_job_tags, "assessment_job": _assessment_job_tags}


@pytest.mark.parametrize("site", sorted(SITES))
def test_every_job_site_carries_the_app_identity_tags_in_the_apps_runtime(site, monkeypatch):
    monkeypatch.setenv("DATABRICKS_APP_NAME", APP_NAME)
    tags = SITES[site]()
    assert tags[TAG_MANAGED_BY] == "vibe_modeling_app"
    assert tags[TAG_APP] == APP_NAME
    assert tags[TAG_APP_VERSION] == sanitize_tag(__version__)


@pytest.mark.parametrize("site", sorted(SITES))
def test_the_app_name_tag_is_left_out_outside_the_apps_runtime(site, monkeypatch):
    monkeypatch.delenv("DATABRICKS_APP_NAME", raising=False)
    tags = SITES[site]()
    assert TAG_APP not in tags
    assert tags[TAG_APP_VERSION] == sanitize_tag(__version__)
    assert tags[TAG_MANAGED_BY] == "vibe_modeling_app"


def test_agent_job_carries_only_the_app_identity_tags(monkeypatch):
    monkeypatch.setenv("DATABRICKS_APP_NAME", APP_NAME)
    assert _agent_job_tags() == app_identity_tags(APP_NAME, __version__)


def test_assessment_job_keeps_its_feature_tag(monkeypatch):
    monkeypatch.setenv("DATABRICKS_APP_NAME", APP_NAME)
    assert _assessment_job_tags() == {**app_identity_tags(APP_NAME, __version__), "feature": "assessment"}


def test_assessment_job_resets_when_the_app_version_changes(monkeypatch):
    """The tags are in the fingerprint, so a new release resets the job once."""
    from databricks.sdk.service.jobs import JobSettings

    from vibe_modeling.backend.assessment import job as assess_job
    from vibe_modeling.backend import job_launcher

    ws = MagicMock()
    ws.jobs.get.return_value.settings = JobSettings(**assess_job._settings("/n", "r", 2))
    assert assess_job.setup_assessment_job(ws, job_id=7, notebook_path="/n", reader_application_id="r",
                                           max_concurrent_runs=2) == 7
    ws.jobs.reset.assert_not_called()

    monkeypatch.setattr(job_launcher, "__version__", "99.0.0")
    assess_job.setup_assessment_job(ws, job_id=7, notebook_path="/n", reader_application_id="r",
                                    max_concurrent_runs=2)
    ws.jobs.reset.assert_called_once()
    assert ws.jobs.reset.call_args.kwargs["new_settings"].tags[TAG_APP_VERSION] == "99.0.0"
