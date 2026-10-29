"""Persistent `vibe-assess` job: check-then-act reset-or-create, runs as the reader SP."""
from __future__ import annotations

from databricks.sdk import WorkspaceClient
from databricks.sdk.errors.platform import NotFound
from databricks.sdk.service.jobs import (
    JobParameterDefinition, JobRunAs, JobSettings, NotebookTask, QueueSettings, Task,
)

from ..job_launcher import app_job_tags, reset_or_create_job
from .constants import JOB_NAME, TASK_KEY, TASK_TIMEOUT_S


def job_tags() -> dict[str, str]:
    """The app identity tags plus ``feature=assessment``. They carry the app version,
    so ``_fingerprint`` sees a new release and the job is reset once per release."""
    return {**app_job_tags(), "feature": "assessment"}


def _settings(notebook_path: str, reader_application_id: str, max_concurrent_runs: int) -> dict:
    return dict(
        name=JOB_NAME,
        tasks=[Task(task_key=TASK_KEY, timeout_seconds=TASK_TIMEOUT_S,
                    notebook_task=NotebookTask(notebook_path=notebook_path,
                                               base_parameters={"config_path": "{{job.parameters.config_path}}"}))],
        parameters=[JobParameterDefinition(name="config_path", default="")],
        run_as=JobRunAs(service_principal_name=reader_application_id),
        queue=QueueSettings(enabled=True),
        max_concurrent_runs=max_concurrent_runs,
        tags=job_tags(),
    )


def _fingerprint(settings) -> tuple:
    """Every field ``_settings`` sets, read off a ``JobSettings`` (missing fields read as None)."""
    g = getattr
    tasks = g(settings, "tasks", None) or []
    t = tasks[0] if len(tasks) == 1 else None
    nb = g(t, "notebook_task", None)
    params = tuple((g(p, "name", None), g(p, "default", None)) for p in (g(settings, "parameters", None) or []))
    return (
        g(settings, "name", None),
        g(t, "task_key", None), g(t, "timeout_seconds", None),
        g(nb, "notebook_path", None), dict(g(nb, "base_parameters", None) or {}),
        params,
        g(g(settings, "run_as", None), "service_principal_name", None),
        g(g(settings, "queue", None), "enabled", None),
        g(settings, "max_concurrent_runs", None),
        dict(g(settings, "tags", None) or {}),
    )


def setup_assessment_job(ws: WorkspaceClient, *, job_id: int | None, notebook_path: str,
                         reader_application_id: str, max_concurrent_runs: int) -> int:
    """Leave a matching job alone, reset a differing one, create a missing one.

    Reads the job first and resets only when a field the app sets differs, so
    a sync with nothing changed writes nothing. Errors other than NotFound propagate.
    """
    settings = _settings(notebook_path, reader_application_id, max_concurrent_runs)
    if job_id:
        try:
            current = ws.jobs.get(job_id).settings
        except NotFound:
            job_id = None
        else:
            if _fingerprint(current) == _fingerprint(JobSettings(**settings)):
                return job_id
    return reset_or_create_job(ws, job_id=job_id, settings=settings, raise_on_reset_error=True)
