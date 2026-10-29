"""The agent's runtime budget: bounds, default and how a run gets its value.

The agent paces each agent job by the ``runtime_budget_seconds`` job base
parameter (agent 5.3.3 nb 105565-105584; it falls back to 14400 s when the
parameter is missing). With under 40 minutes left its refinement loops stop
(``_agentic_loop_should_stop``, nb 929-975), and with under about 16 minutes
left it skips the per-requirement verifier (nb 46290-46302). It never stops
the job. Each job's clock starts at its own ``main()``, so both jobs of a
two-step run (generate ECM, then shrink) get the full budget.

The app keeps the budget in whole hours: Settings holds the app-wide default
(``AgentConfig.runtime_budget_hours``) and a run may override it
(``RunIn.runtime_budget_hours``). Create resolves the effective hours once and
stores them under :data:`RUNTIME_BUDGET_HOURS_KEY` in ``Run.parameters_json``;
every dispatch and retry of the run reads them back from there. Only runs
created before the setting existed have no stored value and use the Settings
default at dispatch time. The agent only ever receives seconds.

This module imports nothing from the app, so ``models``, ``db_models`` and the
dispatch paths can all share it.
"""

from __future__ import annotations

from collections.abc import Mapping
from typing import Any, Optional

RUNTIME_BUDGET_MIN_HOURS = 4
# A sanity ceiling: a typo such as 400 would let a stuck job keep calling
# models for days. The serverless job limit (168 h) is well above it.
RUNTIME_BUDGET_MAX_HOURS = 48
RUNTIME_BUDGET_DEFAULT_HOURS = 6

# The ``Run.parameters_json`` key that holds a run's resolved hours. Never a
# widget: the agent gets :func:`runtime_budget_seconds` of it.
RUNTIME_BUDGET_HOURS_KEY = "runtime_budget_hours"

RUNTIME_BUDGET_HOURS_DESCRIPTION = (
    f"Whole hours the agent plans each agent job to take, "
    f"{RUNTIME_BUDGET_MIN_HOURS} to {RUNTIME_BUDGET_MAX_HOURS}."
)


def settings_runtime_budget_hours(agent_config: Any) -> int:
    """The Settings default on ``agent_config``, or the app default without a row."""
    value = getattr(agent_config, "runtime_budget_hours", None)
    return value if _is_hours(value) else RUNTIME_BUDGET_DEFAULT_HOURS


def resolve_runtime_budget_hours(override: Optional[int], agent_config: Any) -> int:
    """The hours a new run stores: its own override, else the Settings default."""
    return override if _is_hours(override) else settings_runtime_budget_hours(agent_config)


def stored_runtime_budget_hours(stored: Optional[Mapping[str, Any]], agent_config: Any) -> int:
    """The hours a run dispatches with, read from its ``parameters_json``.

    A run created before the setting existed has no value and gets the current
    Settings default. A stored value is not re-checked against the bounds, so
    a later change to them never fails an older run.
    """
    value = (stored or {}).get(RUNTIME_BUDGET_HOURS_KEY)
    return value if _is_hours(value) else settings_runtime_budget_hours(agent_config)


def runtime_budget_seconds(hours: int) -> int:
    """The agent's ``runtime_budget_seconds`` value for ``hours``."""
    return hours * 60 * 60


def _is_hours(value: Any) -> bool:
    return isinstance(value, int) and not isinstance(value, bool) and value > 0
