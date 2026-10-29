"""Migration 0.9.0.3 - the agent's run time budget in Settings.

The fourth migration of the 0.9.0 release, applied on top of ``v_0_9_0_2``.
It adds ``agent_config.runtime_budget_hours INTEGER NOT NULL DEFAULT 6``: the
app-wide default, in whole hours, that a new run stores when it sets no budget
of its own (``backend/runtime_budget.py``). Existing rows read 6 through the
column default. A fresh install gets the column from ``create_all``, with the
same server default (``db_models.AgentConfig``).

Guarded on ``agent_config`` existing and the column being absent, so a re-run
changes nothing. Postgres uses ``ADD COLUMN IF NOT EXISTS``; SQLite (tests)
PRAGMA-checks first. The DDL is a string literal so
``tests/test_app/test_migration_drift_owner.py`` can prove
``scripts/db/migrate.py`` mirrors it. The 6 is frozen here: a later change to
the app default does not change what this migration did.
"""

from __future__ import annotations

import logging

from sqlalchemy import inspect, text
from sqlalchemy.engine import Engine

from .registry import Migration

logger = logging.getLogger(__name__)

_ADD_RUNTIME_BUDGET_PG = (
    "ALTER TABLE agent_config ADD COLUMN IF NOT EXISTS runtime_budget_hours INTEGER NOT NULL DEFAULT 6"
)
_ADD_RUNTIME_BUDGET_SQLITE = (
    "ALTER TABLE agent_config ADD COLUMN runtime_budget_hours INTEGER NOT NULL DEFAULT 6"
)


def apply(engine: Engine) -> None:
    """Add ``agent_config.runtime_budget_hours`` (default 6) when it is missing."""
    with engine.begin() as conn:
        insp = inspect(conn)
        if not insp.has_table("agent_config"):
            logger.info("v_0_9_0_3: no agent_config table; nothing to do")
            return
        if "runtime_budget_hours" in {c["name"] for c in insp.get_columns("agent_config")}:
            logger.info("v_0_9_0_3: agent_config.runtime_budget_hours already present")
            return
        if engine.dialect.name == "postgresql":
            conn.execute(text(_ADD_RUNTIME_BUDGET_PG))
        else:
            conn.execute(text(_ADD_RUNTIME_BUDGET_SQLITE))
    logger.info("v_0_9_0_3: added agent_config.runtime_budget_hours (default 6)")


MIGRATION = Migration(
    version="0.9.0.3",
    apply=apply,
    description=(
        "Add agent_config.runtime_budget_hours INTEGER NOT NULL DEFAULT 6: the Settings "
        "default run time budget, in whole hours, for new runs."
    ),
)
