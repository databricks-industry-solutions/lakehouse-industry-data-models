"""Migration 0.9.0.4 - the scope prefixes an import added to a model.

The fifth migration of the 0.9.0 release, applied on top of ``v_0_9_0_3``.
It adds two nullable columns to ``model_versions``:

- ``import_schema_prefix_added``: the schema prefix the app put on the
  version's schemas when it brought the model in (``ecm_`` / ``mvm_``);
- ``import_view_prefix_added``: the prefix it put on its metric view names.

``""`` means the app copied the version's files into its own folder and
added nothing (agent output, or a file that already had a prefix). NULL
means the version was not brought in by a 0.9.0 import (agent runs, and
every row that predates this migration). ``services/scope_prefix.py`` writes
them; publishing strips exactly what they record.

Guarded on ``model_versions`` existing and each column being absent, so a
re-run changes nothing. Postgres uses ``ADD COLUMN IF NOT EXISTS``; SQLite
(tests) PRAGMA-checks first. The DDL is written as string literals so
``tests/test_app/test_migration_drift_owner.py`` can prove
``scripts/db/migrate.py`` mirrors it.
"""

from __future__ import annotations

import logging

from sqlalchemy import inspect, text
from sqlalchemy.engine import Engine

from .registry import Migration

logger = logging.getLogger(__name__)

_ADD_SCHEMA_PREFIX_ADDED_PG = (
    "ALTER TABLE model_versions ADD COLUMN IF NOT EXISTS import_schema_prefix_added VARCHAR"
)
_ADD_SCHEMA_PREFIX_ADDED_SQLITE = (
    "ALTER TABLE model_versions ADD COLUMN import_schema_prefix_added VARCHAR"
)
_ADD_VIEW_PREFIX_ADDED_PG = (
    "ALTER TABLE model_versions ADD COLUMN IF NOT EXISTS import_view_prefix_added VARCHAR"
)
_ADD_VIEW_PREFIX_ADDED_SQLITE = (
    "ALTER TABLE model_versions ADD COLUMN import_view_prefix_added VARCHAR"
)

NEW_COLUMNS: dict[str, tuple[str, str]] = {
    "import_schema_prefix_added": (_ADD_SCHEMA_PREFIX_ADDED_PG, _ADD_SCHEMA_PREFIX_ADDED_SQLITE),
    "import_view_prefix_added": (_ADD_VIEW_PREFIX_ADDED_PG, _ADD_VIEW_PREFIX_ADDED_SQLITE),
}


def apply(engine: Engine) -> None:
    """Add the two ``model_versions`` import-prefix columns when missing."""
    with engine.begin() as conn:
        insp = inspect(conn)
        if not insp.has_table("model_versions"):
            logger.info("v_0_9_0_4: no model_versions table; nothing to do")
            return
        present = {c["name"] for c in insp.get_columns("model_versions")}
        postgres = engine.dialect.name == "postgresql"
        for column, (pg_ddl, sqlite_ddl) in NEW_COLUMNS.items():
            if column in present:
                continue
            conn.execute(text(pg_ddl if postgres else sqlite_ddl))
            logger.info("v_0_9_0_4: added model_versions.%s", column)


MIGRATION = Migration(
    version="0.9.0.4",
    apply=apply,
    description=(
        "Add model_versions.import_schema_prefix_added and import_view_prefix_added "
        "(nullable VARCHAR): the scope prefixes an import added to the model."
    ),
)
