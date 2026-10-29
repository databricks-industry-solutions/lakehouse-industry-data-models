"""Migration 0.9.0 - version lifecycle, run report rows, agent identity cache.

The single migration of the 0.9.0 release, upgrading a 0.8.0 schema in one
step. Additive only. Four steps, in this order, in one transaction:

1. **Columns** on existing tables (:data:`NEW_COLUMNS`), all nullable or
   defaulted so pre-existing rows read as "not set":

   * ``model_versions``: ``dry_run`` (produced by a Dry Run; survives
     promotion), ``promoted_at`` / ``promoted_by_run_id`` (when and by which
     install run the version was made current), ``replaced_by_version_id`` /
     ``replaced_at`` (stamped on every version an install drops;
     ``replaced_at`` is the flag, the id is only a pointer that ON DELETE SET
     NULL may clear), ``files_catalog`` (where the agent wrote the version's
     files and home ``_metamodel`` rows; ``uc_catalog`` keeps meaning "where
     it is installed now"), and the file's ``_vibe_scope`` facts
     ``scope_fence_mode`` / ``scope_base_version`` / ``scope_base_scope``.
   * ``run_input_links``: ``outcome_status`` / ``outcome_reason`` /
     ``outcome_target`` (the agent's per-feedback outcome; NULL = no outcomes
     reported).
   * ``vibe_inputs``: ``consumed_by_run_id`` (the run whose success consumed
     the input).
   * ``agent_config``: the installed-notebook identity cache
     ``installed_release_version`` / ``installed_agent_version`` /
     ``installed_checked_at`` / ``installed_checked_path`` /
     ``installed_check_error``.

   The three new FK columns are ``ON DELETE SET NULL`` (provenance: the row
   outlives its referent) and are declared inline on the ``ADD COLUMN``.
   Postgres uses ``ADD COLUMN IF NOT EXISTS``; SQLite (tests) PRAGMA-checks
   first since its ``ADD COLUMN`` lacks ``IF NOT EXISTS``. Each table is
   guarded on existence so minimal migration-test fixtures are a no-op. The
   DDL is written as string LITERALS (not f-strings) so the owner-script drift
   gate (``tests/test_app/test_migration_drift_owner.py``) can regex the
   ``(table, column, type)`` triples out of this module and prove
   ``scripts/db/migrate.py`` mirrors them.

2. **Indexes** on the SET NULL FK columns (:data:`FK_INDEX_COLUMNS`, both
   dialects, ``CREATE INDEX IF NOT EXISTS``): an unindexed child column makes
   the SET NULL action scan the child table per deleted parent row. The
   names equal the ``index=True`` names ``db_models`` gives fresh installs.

3. **Tables** ``run_agent_reports`` and ``run_post_install_deletes``
   (:data:`NEW_TABLES`), built from the final models with
   ``metadata.create_all(tables=..., checkfirst=True)``.

4. **Backfills** (frozen inline SQL, idempotent):

   * ``files_catalog = uc_catalog`` for agent-produced rows
     (``import_source_path IS NULL``) that have no ``files_catalog`` yet and
     a non-empty ``uc_catalog``. A never-installed row (``uc_catalog = ''``)
     stays NULL rather than getting ``''``: both mean "unknown", and readers
     fall back to the installation's catalog for NULL. A row installed into
     another catalog before 0.9.0 already lost its files location; a resync
     recovers it.
   * ``dry_run = true`` for ``status='draft'`` outputs of succeeded
     ``vibe_iterate`` operations whose run's ``parameters_json`` records
     ``"dry_run": true``. The JSON is parsed in Python so both dialects
     read it the same way and a malformed blob is skipped, not fatal.

No run-report backfill: versions produced before 0.9.0 have no outcome rows.
"""

from __future__ import annotations

import json
import logging

from sqlalchemy import inspect, text
from sqlalchemy.engine import Connection, Engine
from sqlmodel import SQLModel

from .registry import Migration

logger = logging.getLogger(__name__)

# --- model_versions ---------------------------------------------------------
_ADD_MV_DRY_RUN_PG = (
    "ALTER TABLE model_versions ADD COLUMN IF NOT EXISTS dry_run BOOLEAN NOT NULL DEFAULT false"
)
_ADD_MV_DRY_RUN_SQLITE = (
    "ALTER TABLE model_versions ADD COLUMN dry_run BOOLEAN NOT NULL DEFAULT false"
)
_ADD_MV_PROMOTED_AT_PG = (
    "ALTER TABLE model_versions ADD COLUMN IF NOT EXISTS promoted_at TIMESTAMP"
)
_ADD_MV_PROMOTED_AT_SQLITE = "ALTER TABLE model_versions ADD COLUMN promoted_at TIMESTAMP"
_ADD_MV_PROMOTED_BY_RUN_ID_PG = (
    "ALTER TABLE model_versions ADD COLUMN IF NOT EXISTS "
    "promoted_by_run_id VARCHAR REFERENCES runs(id) ON DELETE SET NULL"
)
_ADD_MV_PROMOTED_BY_RUN_ID_SQLITE = (
    "ALTER TABLE model_versions ADD COLUMN "
    "promoted_by_run_id VARCHAR REFERENCES runs(id) ON DELETE SET NULL"
)
_ADD_MV_REPLACED_BY_VERSION_ID_PG = (
    "ALTER TABLE model_versions ADD COLUMN IF NOT EXISTS "
    "replaced_by_version_id VARCHAR REFERENCES model_versions(id) ON DELETE SET NULL"
)
_ADD_MV_REPLACED_BY_VERSION_ID_SQLITE = (
    "ALTER TABLE model_versions ADD COLUMN "
    "replaced_by_version_id VARCHAR REFERENCES model_versions(id) ON DELETE SET NULL"
)
_ADD_MV_REPLACED_AT_PG = (
    "ALTER TABLE model_versions ADD COLUMN IF NOT EXISTS replaced_at TIMESTAMP"
)
_ADD_MV_REPLACED_AT_SQLITE = "ALTER TABLE model_versions ADD COLUMN replaced_at TIMESTAMP"
_ADD_MV_FILES_CATALOG_PG = (
    "ALTER TABLE model_versions ADD COLUMN IF NOT EXISTS files_catalog VARCHAR"
)
_ADD_MV_FILES_CATALOG_SQLITE = "ALTER TABLE model_versions ADD COLUMN files_catalog VARCHAR"
_ADD_MV_SCOPE_FENCE_MODE_PG = (
    "ALTER TABLE model_versions ADD COLUMN IF NOT EXISTS scope_fence_mode VARCHAR"
)
_ADD_MV_SCOPE_FENCE_MODE_SQLITE = "ALTER TABLE model_versions ADD COLUMN scope_fence_mode VARCHAR"
_ADD_MV_SCOPE_BASE_VERSION_PG = (
    "ALTER TABLE model_versions ADD COLUMN IF NOT EXISTS scope_base_version INTEGER"
)
_ADD_MV_SCOPE_BASE_VERSION_SQLITE = (
    "ALTER TABLE model_versions ADD COLUMN scope_base_version INTEGER"
)
_ADD_MV_SCOPE_BASE_SCOPE_PG = (
    "ALTER TABLE model_versions ADD COLUMN IF NOT EXISTS scope_base_scope VARCHAR"
)
_ADD_MV_SCOPE_BASE_SCOPE_SQLITE = "ALTER TABLE model_versions ADD COLUMN scope_base_scope VARCHAR"

# --- run_input_links --------------------------------------------------------
_ADD_RIL_OUTCOME_STATUS_PG = (
    "ALTER TABLE run_input_links ADD COLUMN IF NOT EXISTS outcome_status VARCHAR"
)
_ADD_RIL_OUTCOME_STATUS_SQLITE = "ALTER TABLE run_input_links ADD COLUMN outcome_status VARCHAR"
_ADD_RIL_OUTCOME_REASON_PG = (
    "ALTER TABLE run_input_links ADD COLUMN IF NOT EXISTS outcome_reason TEXT"
)
_ADD_RIL_OUTCOME_REASON_SQLITE = "ALTER TABLE run_input_links ADD COLUMN outcome_reason TEXT"
_ADD_RIL_OUTCOME_TARGET_PG = (
    "ALTER TABLE run_input_links ADD COLUMN IF NOT EXISTS outcome_target VARCHAR"
)
_ADD_RIL_OUTCOME_TARGET_SQLITE = "ALTER TABLE run_input_links ADD COLUMN outcome_target VARCHAR"

# --- vibe_inputs ------------------------------------------------------------
_ADD_VI_CONSUMED_BY_RUN_ID_PG = (
    "ALTER TABLE vibe_inputs ADD COLUMN IF NOT EXISTS "
    "consumed_by_run_id VARCHAR REFERENCES runs(id) ON DELETE SET NULL"
)
_ADD_VI_CONSUMED_BY_RUN_ID_SQLITE = (
    "ALTER TABLE vibe_inputs ADD COLUMN "
    "consumed_by_run_id VARCHAR REFERENCES runs(id) ON DELETE SET NULL"
)

# --- agent_config -----------------------------------------------------------
_ADD_AC_INSTALLED_RELEASE_VERSION_PG = (
    "ALTER TABLE agent_config ADD COLUMN IF NOT EXISTS installed_release_version VARCHAR"
)
_ADD_AC_INSTALLED_RELEASE_VERSION_SQLITE = (
    "ALTER TABLE agent_config ADD COLUMN installed_release_version VARCHAR"
)
_ADD_AC_INSTALLED_AGENT_VERSION_PG = (
    "ALTER TABLE agent_config ADD COLUMN IF NOT EXISTS installed_agent_version VARCHAR"
)
_ADD_AC_INSTALLED_AGENT_VERSION_SQLITE = (
    "ALTER TABLE agent_config ADD COLUMN installed_agent_version VARCHAR"
)
_ADD_AC_INSTALLED_CHECKED_AT_PG = (
    "ALTER TABLE agent_config ADD COLUMN IF NOT EXISTS installed_checked_at TIMESTAMP"
)
_ADD_AC_INSTALLED_CHECKED_AT_SQLITE = (
    "ALTER TABLE agent_config ADD COLUMN installed_checked_at TIMESTAMP"
)
_ADD_AC_INSTALLED_CHECKED_PATH_PG = (
    "ALTER TABLE agent_config ADD COLUMN IF NOT EXISTS installed_checked_path VARCHAR"
)
_ADD_AC_INSTALLED_CHECKED_PATH_SQLITE = (
    "ALTER TABLE agent_config ADD COLUMN installed_checked_path VARCHAR"
)
_ADD_AC_INSTALLED_CHECK_ERROR_PG = (
    "ALTER TABLE agent_config ADD COLUMN IF NOT EXISTS installed_check_error VARCHAR"
)
_ADD_AC_INSTALLED_CHECK_ERROR_SQLITE = (
    "ALTER TABLE agent_config ADD COLUMN installed_check_error VARCHAR"
)

# (table, column) -> (postgres DDL, sqlite DDL), in apply order. Single source
# of truth for the apply loop and the migration test.
NEW_COLUMNS: dict[tuple[str, str], tuple[str, str]] = {
    ("model_versions", "dry_run"): (_ADD_MV_DRY_RUN_PG, _ADD_MV_DRY_RUN_SQLITE),
    ("model_versions", "promoted_at"): (_ADD_MV_PROMOTED_AT_PG, _ADD_MV_PROMOTED_AT_SQLITE),
    ("model_versions", "promoted_by_run_id"): (
        _ADD_MV_PROMOTED_BY_RUN_ID_PG, _ADD_MV_PROMOTED_BY_RUN_ID_SQLITE,
    ),
    ("model_versions", "replaced_by_version_id"): (
        _ADD_MV_REPLACED_BY_VERSION_ID_PG, _ADD_MV_REPLACED_BY_VERSION_ID_SQLITE,
    ),
    ("model_versions", "replaced_at"): (_ADD_MV_REPLACED_AT_PG, _ADD_MV_REPLACED_AT_SQLITE),
    ("model_versions", "files_catalog"): (_ADD_MV_FILES_CATALOG_PG, _ADD_MV_FILES_CATALOG_SQLITE),
    ("model_versions", "scope_fence_mode"): (
        _ADD_MV_SCOPE_FENCE_MODE_PG, _ADD_MV_SCOPE_FENCE_MODE_SQLITE,
    ),
    ("model_versions", "scope_base_version"): (
        _ADD_MV_SCOPE_BASE_VERSION_PG, _ADD_MV_SCOPE_BASE_VERSION_SQLITE,
    ),
    ("model_versions", "scope_base_scope"): (
        _ADD_MV_SCOPE_BASE_SCOPE_PG, _ADD_MV_SCOPE_BASE_SCOPE_SQLITE,
    ),
    ("run_input_links", "outcome_status"): (
        _ADD_RIL_OUTCOME_STATUS_PG, _ADD_RIL_OUTCOME_STATUS_SQLITE,
    ),
    ("run_input_links", "outcome_reason"): (
        _ADD_RIL_OUTCOME_REASON_PG, _ADD_RIL_OUTCOME_REASON_SQLITE,
    ),
    ("run_input_links", "outcome_target"): (
        _ADD_RIL_OUTCOME_TARGET_PG, _ADD_RIL_OUTCOME_TARGET_SQLITE,
    ),
    ("vibe_inputs", "consumed_by_run_id"): (
        _ADD_VI_CONSUMED_BY_RUN_ID_PG, _ADD_VI_CONSUMED_BY_RUN_ID_SQLITE,
    ),
    ("agent_config", "installed_release_version"): (
        _ADD_AC_INSTALLED_RELEASE_VERSION_PG, _ADD_AC_INSTALLED_RELEASE_VERSION_SQLITE,
    ),
    ("agent_config", "installed_agent_version"): (
        _ADD_AC_INSTALLED_AGENT_VERSION_PG, _ADD_AC_INSTALLED_AGENT_VERSION_SQLITE,
    ),
    ("agent_config", "installed_checked_at"): (
        _ADD_AC_INSTALLED_CHECKED_AT_PG, _ADD_AC_INSTALLED_CHECKED_AT_SQLITE,
    ),
    ("agent_config", "installed_checked_path"): (
        _ADD_AC_INSTALLED_CHECKED_PATH_PG, _ADD_AC_INSTALLED_CHECKED_PATH_SQLITE,
    ),
    ("agent_config", "installed_check_error"): (
        _ADD_AC_INSTALLED_CHECK_ERROR_PG, _ADD_AC_INSTALLED_CHECK_ERROR_SQLITE,
    ),
}

# ``(child_table, fk_column, parent_table)`` for the ON DELETE SET NULL FKs
# this migration adds. The drift test pairs it against ``db_models`` and the
# owner script imports it for the index loop.
SET_NULL_FKS: tuple[tuple[str, str, str], ...] = (
    ("model_versions", "promoted_by_run_id", "runs"),
    ("model_versions", "replaced_by_version_id", "model_versions"),
    ("vibe_inputs", "consumed_by_run_id", "runs"),
)

# Each SET NULL FK column gets ``ix_<table>_<column>``.
FK_INDEX_COLUMNS: tuple[tuple[str, str], ...] = tuple((c, col) for c, col, _p in SET_NULL_FKS)

# Tables created by this migration (``db_models`` names).
NEW_TABLES: tuple[str, ...] = ("run_agent_reports", "run_post_install_deletes")

BACKFILL_FILES_CATALOG_SQL = (
    "UPDATE model_versions SET files_catalog = uc_catalog "
    "WHERE files_catalog IS NULL AND import_source_path IS NULL "
    "AND uc_catalog IS NOT NULL AND uc_catalog <> ''"
)

_DRY_RUN_CANDIDATES_SQL = (
    "SELECT DISTINCT mv.id, r.parameters_json "
    "FROM model_versions mv "
    "JOIN run_operations ro ON ro.output_version_id = mv.id "
    "JOIN runs r ON r.id = ro.run_id "
    "WHERE mv.status = 'draft' AND mv.dry_run = :off "
    "AND ro.operation_name = 'vibe_iterate' AND ro.status = 'succeeded'"
)

_MARK_DRY_RUN_SQL = "UPDATE model_versions SET dry_run = :on WHERE id = :id"


def _add_column(conn: Connection, table: str, column: str, is_postgres: bool) -> None:
    pg_ddl, sqlite_ddl = NEW_COLUMNS[(table, column)]
    if is_postgres:
        conn.execute(text(pg_ddl))
        return
    # SQLite (tests): ADD COLUMN lacks IF NOT EXISTS, so check first.
    present = {row[1] for row in conn.execute(text(f"PRAGMA table_info({table})")).fetchall()}
    if column not in present:
        conn.execute(text(sqlite_ddl))


def _add_columns(conn: Connection, is_postgres: bool) -> None:
    insp = inspect(conn)
    present_tables = {t for (t, _c) in NEW_COLUMNS if insp.has_table(t)}
    for table, column in NEW_COLUMNS:
        if table in present_tables:
            _add_column(conn, table, column, is_postgres)


def _index_fk_columns(conn: Connection) -> None:
    insp = inspect(conn)
    for table, column in FK_INDEX_COLUMNS:
        if insp.has_table(table):
            conn.execute(text(
                f"CREATE INDEX IF NOT EXISTS ix_{table}_{column} ON {table} ({column})"
            ))


def _create_tables(conn: Connection) -> None:
    SQLModel.metadata.create_all(
        conn,
        tables=[SQLModel.metadata.tables[name] for name in NEW_TABLES],
        checkfirst=True,
    )


def _backfill_files_catalog(conn: Connection) -> int:
    if not inspect(conn).has_table("model_versions"):
        return 0
    return conn.execute(text(BACKFILL_FILES_CATALOG_SQL)).rowcount or 0


def _parameters_say_dry_run(parameters_json: object) -> bool:
    try:
        params = json.loads(parameters_json) if isinstance(parameters_json, str) else None
    except ValueError:
        return False
    return isinstance(params, dict) and params.get("dry_run") is True


def _backfill_dry_run(conn: Connection) -> int:
    insp = inspect(conn)
    if not all(insp.has_table(t) for t in ("model_versions", "run_operations", "runs")):
        return 0
    rows = conn.execute(text(_DRY_RUN_CANDIDATES_SQL), {"off": False}).fetchall()
    marked = 0
    for version_id, parameters_json in rows:
        if _parameters_say_dry_run(parameters_json):
            conn.execute(text(_MARK_DRY_RUN_SQL), {"on": True, "id": version_id})
            marked += 1
    return marked


def apply(engine: Engine) -> None:
    """Add the columns and FK indexes, create the two tables, then run the two
    backfills. Idempotent; one transaction, both dialects."""
    is_postgres = engine.dialect.name == "postgresql"
    with engine.begin() as conn:
        _add_columns(conn, is_postgres)
        _index_fk_columns(conn)
        _create_tables(conn)
        files = _backfill_files_catalog(conn)
        dry = _backfill_dry_run(conn)
    logger.info(
        "v_0_9_0: backfilled files_catalog on %d version(s), dry_run on %d draft(s)",
        files, dry,
    )


MIGRATION = Migration(
    version="0.9.0",
    apply=apply,
    description=(
        "Add model_versions lifecycle columns (dry_run, promoted_at/by, replaced_by/at, "
        "files_catalog, _vibe_scope facts), run_input_links outcome columns, "
        "vibe_inputs.consumed_by_run_id and the agent_config installed-identity cache; "
        "index the SET NULL FKs; create run_agent_reports and run_post_install_deletes; "
        "backfill files_catalog and dry_run."
    ),
)
