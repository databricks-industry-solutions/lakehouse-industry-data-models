"""The agent's ``dbutils.notebook.exit`` JSON, read from a finished job run.

The one reader for the lifecycle primitives: ``install`` fails a step on a
refused registration, ``uninstall`` warns about schemas the agent could not
drop. Each passes its own ``unreadable`` lead-in, the text a caller shows
when the output cannot be used.
"""

from __future__ import annotations

import json
import time
from typing import Any, Optional

# How long after the job ended an unreadable run output is re-read before the
# read gives up (the Jobs API can lag the run's end).
EXIT_RESULT_READ_DEADLINE_S = 300


class ExitResult:
    """The agent's exit JSON, a retry later, or a hard failure."""

    __slots__ = ("result", "retry", "failure")

    def __init__(self, result: Optional[dict] = None, *, retry: bool = False, failure: Optional[str] = None):
        self.result = result
        self.retry = retry
        self.failure = failure


def agent_exit_result(ws: Any, job_run: Any, databricks_run_id: Any, *, unreadable: str) -> ExitResult:
    """Read the agent's ``dbutils.notebook.exit`` JSON (nb 53447) for the run.

    The agent's job has one notebook task; the output is read from that
    task's run (``jobs.get_run_output(tasks[0].run_id)``; the parent run of a
    multi-task job has none), at ``notebook_output.result`` with the
    ``notebook_output.truncated`` flag (shape verified live).

    The app-agent boundary fails hard: a call that raises is retried on the
    next poll until :data:`EXIT_RESULT_READ_DEADLINE_S` after the job's end,
    then fails; an output that is read but empty, truncated, not JSON or not
    an object fails at once. ``failure`` is ``unreadable`` plus the reason.
    """
    tasks = getattr(job_run, "tasks", None)
    run_id = databricks_run_id
    if isinstance(tasks, (list, tuple)) and tasks:
        run_id = getattr(tasks[0], "run_id", None) or databricks_run_id
    try:
        output = ws.jobs.get_run_output(run_id)
    except Exception as exc:  # noqa: BLE001 - re-read until the deadline
        end_ms = getattr(job_run, "end_time", None)
        if isinstance(end_ms, int) and end_ms > 0 and time.time() < end_ms / 1000 + EXIT_RESULT_READ_DEADLINE_S:
            return ExitResult(retry=True)
        return ExitResult(failure=f"{unreadable} ({type(exc).__name__})")
    notebook_output = getattr(output, "notebook_output", None)
    raw = getattr(notebook_output, "result", None)
    if getattr(notebook_output, "truncated", False) is True:
        return ExitResult(failure=f"{unreadable} (the result was truncated)")
    if not isinstance(raw, str) or not raw.strip():
        return ExitResult(failure=f"{unreadable} (the result is empty)")
    try:
        result = json.loads(raw)
    except ValueError:
        return ExitResult(failure=f"{unreadable} (the result is not JSON)")
    if not isinstance(result, dict):
        return ExitResult(failure=f"{unreadable} (the result is not an object)")
    return ExitResult(result)
