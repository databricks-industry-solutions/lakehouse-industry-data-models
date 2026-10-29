"""Migration 0.9.0.2 - "Annotate jobs with run tags" on by default.

The third migration of the 0.9.0 release, applied on top of ``v_0_9_0_1``.
It runs once per database, on the first boot of 0.9.0 or later against it
(the registry applies every pending migration). In one transaction, guarded
on ``agent_config`` existing:

1. Postgres only: the server default of ``agent_config.collect_vibe_run_statistics``
   becomes true (:data:`_SET_DEFAULT_PG`), matching ``db_models``. SQLite
   (tests only) cannot change a default; its schemas come from ``create_all``.
2. Every existing row gets the install default: ``VIBE_MODELING_RUN_TAGS_DEFAULT``
   read with :func:`_frozen_run_tags_default`, so it is true unless the deploy
   ran ``install.sh --no-run-tags``. A fresh install has no row yet (the app
   creates it later, seeded from ``AppConfig.run_tags_default``), so this
   changes nothing there.

After this migration Settings own the value. Reading the environment here is
deliberate: it honors ``--no-run-tags`` on the same boot as the upgrade.
``scripts/db/migrate.py`` is not changed, since it mirrors added columns only.
"""

from __future__ import annotations

import logging
import os
from collections.abc import Mapping

from sqlalchemy import inspect, text
from sqlalchemy.engine import Engine

from .registry import Migration

logger = logging.getLogger(__name__)

RUN_TAGS_ENV = "VIBE_MODELING_RUN_TAGS_DEFAULT"

_SET_DEFAULT_PG = (
    "ALTER TABLE agent_config ALTER COLUMN collect_vibe_run_statistics SET DEFAULT true"
)
_APPLY_INSTALL_DEFAULT_SQL = "UPDATE agent_config SET collect_vibe_run_statistics = :on"

# pydantic's false words for a bool field; any other value pydantic accepts is true.
_FROZEN_FALSE = frozenset({"0", "off", "f", "false", "n", "no"})


def _frozen_run_tags_default(env: Mapping[str, str]) -> bool:
    """Frozen copy of ``AppConfig.run_tags_default``'s parse of :data:`RUN_TAGS_ENV`.

    Kept here so this migration's result never changes with the app's config
    parsing. Unset means true; a value in :data:`_FROZEN_FALSE` (after strip
    and lowercase) means false; everything else means true. Values pydantic
    rejects never get here: ``AppConfig`` fails the boot first.
    """
    raw = env.get(RUN_TAGS_ENV)
    if raw is None:
        return True
    return raw.strip().lower() not in _FROZEN_FALSE


def apply(engine: Engine) -> None:
    """Set the server default (Postgres) and apply the install default to every row."""
    on = _frozen_run_tags_default(os.environ)
    with engine.begin() as conn:
        if not inspect(conn).has_table("agent_config"):
            logger.info("v_0_9_0_2: no agent_config table; nothing to do")
            return
        if engine.dialect.name == "postgresql":
            conn.execute(text(_SET_DEFAULT_PG))
        updated = conn.execute(text(_APPLY_INSTALL_DEFAULT_SQL), {"on": on}).rowcount or 0
    logger.info("v_0_9_0_2: set run tags to %s on %d agent_config row(s)", on, updated)


MIGRATION = Migration(
    version="0.9.0.2",
    apply=apply,
    description=(
        "Turn 'Annotate jobs with run tags' (agent_config.collect_vibe_run_statistics) on by "
        "default: server default true (Postgres) and the install default "
        "(VIBE_MODELING_RUN_TAGS_DEFAULT, true unless --no-run-tags) applied once to existing rows."
    ),
)
