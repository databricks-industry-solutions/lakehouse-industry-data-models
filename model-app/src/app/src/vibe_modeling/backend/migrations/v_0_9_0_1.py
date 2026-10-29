"""Migration 0.9.0.1 - install locations, cleanups, change decisions, wizard state, industry dedup.

The second migration of the 0.9.0 release, applied on top of ``v_0_9_0``
(a database that already ran ``v_0_9_0`` gets it on the next boot). Additive
only: the industry dedup repoints and deactivates rows, never deletes them.
Four steps, in this order, in one transaction:

1. **Columns** on existing tables (:data:`NEW_COLUMNS`), all nullable:

   * ``runs``: ``linked_at`` / ``link_evidence``, set when a run is recorded
     after the fact by linking an imported version to its Databricks run.
   * ``agent_config``: ``taxonomy_updated_by`` / ``taxonomy_updated_at``, the
     audit pair of the taxonomy settings.

   Postgres uses ``ADD COLUMN IF NOT EXISTS``; SQLite (tests) PRAGMA-checks
   first. Each table is guarded on existence. The DDL is written as string
   literals so ``tests/test_app/test_migration_drift_owner.py`` can prove
   ``scripts/db/migrate.py`` mirrors it. No FK column is added to an existing
   table, so there is no ``SET_NULL_FKS`` entry here.

2. **Tables** (:data:`NEW_TABLES`) built from the final models with
   ``metadata.create_all(tables=..., checkfirst=True)``, then every index the
   models declare on them is created with ``checkfirst`` too, so a table that
   exists without one of its indexes converges. Their ON DELETE rules come
   from ``db_models`` (CASCADE to the run or version; SET NULL, indexed, for
   provenance pointers). ``model_version_installs`` carries the partial
   unique index ``uq_model_version_installs_open`` on ``(version_id,
   catalog) WHERE uninstalled_at IS NULL``; ``metamodel_cleanups`` carries
   ``ix_metamodel_cleanups_lookup (business_segment, scope, catalog, status)``.

3. **Install rows backfill** (re-runnable ``INSERT ... SELECT ... WHERE NOT
   EXISTS``, one statement per version so each row gets a uuid like the
   model default):

   * an open row for each ``deployed`` version with a ``uc_catalog``;
   * a closed row (``uninstalled_at`` = migration time) for each
     ``uninstalled`` version with a ``uc_catalog``, so the cleanup set
     (files catalog + ``uc_catalog`` + every row's catalog) still reaches
     the catalog it was uninstalled from.

   ``installed_at = COALESCE(promoted_at, completion_date, created_at)``,
   falling back to the migration time; ``installed_by_run_id =
   promoted_by_run_id``. The ``NOT EXISTS`` guard is "an open row for that
   ``(version, catalog)``" for open rows and "any row for it" for closed rows.
   A ``deployed`` version with an empty or NULL ``uc_catalog`` gets no row and
   is logged at WARNING with its id.

4. **Industry dedup** (:func:`plan_industry_dedup`, Python over two SELECTs so
   both dialects compare the same way): every ``is_auto_created`` industry
   whose slug (:func:`_frozen_industry_slug` of its ``name`` and
   ``short_name``) matches exactly one active curated industry has every
   business repointed to the curated row and is set ``is_active = false``.
   Skipped and logged: an initial-sync stub (its ``short_name`` equals the
   name of a business pointing at it, case-insensitive) and an ambiguous match
   (more than one curated row). An auto row that is already inactive with no
   business left is done. Each merge is logged with the moved businesses'
   names and ids, the only record outside the database of how to undo it. ``scripts/smoke/industry_dedup_dry_run.py`` prints
   the same plan read-only for any database.
"""

from __future__ import annotations

import logging
import re
import uuid
from dataclasses import dataclass
from datetime import datetime, timezone

from sqlalchemy import DateTime, bindparam, inspect, text
from sqlalchemy.engine import Connection, Engine
from sqlmodel import SQLModel

from .registry import Migration

logger = logging.getLogger(__name__)

# --- runs -------------------------------------------------------------------
_ADD_RUN_LINKED_AT_PG = "ALTER TABLE runs ADD COLUMN IF NOT EXISTS linked_at TIMESTAMP"
_ADD_RUN_LINKED_AT_SQLITE = "ALTER TABLE runs ADD COLUMN linked_at TIMESTAMP"
_ADD_RUN_LINK_EVIDENCE_PG = "ALTER TABLE runs ADD COLUMN IF NOT EXISTS link_evidence VARCHAR"
_ADD_RUN_LINK_EVIDENCE_SQLITE = "ALTER TABLE runs ADD COLUMN link_evidence VARCHAR"

# --- agent_config -----------------------------------------------------------
_ADD_AC_TAXONOMY_UPDATED_BY_PG = (
    "ALTER TABLE agent_config ADD COLUMN IF NOT EXISTS taxonomy_updated_by VARCHAR"
)
_ADD_AC_TAXONOMY_UPDATED_BY_SQLITE = "ALTER TABLE agent_config ADD COLUMN taxonomy_updated_by VARCHAR"
_ADD_AC_TAXONOMY_UPDATED_AT_PG = (
    "ALTER TABLE agent_config ADD COLUMN IF NOT EXISTS taxonomy_updated_at TIMESTAMP"
)
_ADD_AC_TAXONOMY_UPDATED_AT_SQLITE = "ALTER TABLE agent_config ADD COLUMN taxonomy_updated_at TIMESTAMP"

# (table, column) -> (postgres DDL, sqlite DDL), in apply order.
NEW_COLUMNS: dict[tuple[str, str], tuple[str, str]] = {
    ("runs", "linked_at"): (_ADD_RUN_LINKED_AT_PG, _ADD_RUN_LINKED_AT_SQLITE),
    ("runs", "link_evidence"): (_ADD_RUN_LINK_EVIDENCE_PG, _ADD_RUN_LINK_EVIDENCE_SQLITE),
    ("agent_config", "taxonomy_updated_by"): (
        _ADD_AC_TAXONOMY_UPDATED_BY_PG, _ADD_AC_TAXONOMY_UPDATED_BY_SQLITE,
    ),
    ("agent_config", "taxonomy_updated_at"): (
        _ADD_AC_TAXONOMY_UPDATED_AT_PG, _ADD_AC_TAXONOMY_UPDATED_AT_SQLITE,
    ),
}

# Tables created by this migration (``db_models`` names).
NEW_TABLES: tuple[str, ...] = (
    "taxonomy_wizard_states",
    "model_version_installs",
    "metamodel_cleanups",
    "run_schema_drops",
    "run_change_decisions",
)

# --- step 3: install rows ---------------------------------------------------
_OPEN_INSTALL_CANDIDATES_SQL = (
    "SELECT mv.id FROM model_versions mv "
    "WHERE mv.deployment_status = 'deployed' AND mv.uc_catalog IS NOT NULL AND mv.uc_catalog <> '' "
    "AND NOT EXISTS (SELECT 1 FROM model_version_installs i "
    "WHERE i.version_id = mv.id AND i.catalog = mv.uc_catalog AND i.uninstalled_at IS NULL)"
)
_INSERT_OPEN_INSTALL_SQL = (
    "INSERT INTO model_version_installs "
    "(id, version_id, catalog, installed_by_run_id, installed_at, uninstalled_at, uninstalled_by_run_id) "
    "SELECT :id, mv.id, mv.uc_catalog, mv.promoted_by_run_id, "
    "COALESCE(mv.promoted_at, mv.completion_date, mv.created_at, :now), NULL, NULL "
    "FROM model_versions mv WHERE mv.id = :version_id "
    "AND NOT EXISTS (SELECT 1 FROM model_version_installs i "
    "WHERE i.version_id = mv.id AND i.catalog = mv.uc_catalog AND i.uninstalled_at IS NULL)"
)
_DEPLOYED_WITHOUT_CATALOG_SQL = (
    "SELECT id FROM model_versions "
    "WHERE deployment_status = 'deployed' AND (uc_catalog IS NULL OR uc_catalog = '') ORDER BY id"
)
_CLOSED_INSTALL_CANDIDATES_SQL = (
    "SELECT mv.id FROM model_versions mv "
    "WHERE mv.deployment_status = 'uninstalled' AND mv.uc_catalog IS NOT NULL AND mv.uc_catalog <> '' "
    "AND NOT EXISTS (SELECT 1 FROM model_version_installs i "
    "WHERE i.version_id = mv.id AND i.catalog = mv.uc_catalog)"
)
_INSERT_CLOSED_INSTALL_SQL = (
    "INSERT INTO model_version_installs "
    "(id, version_id, catalog, installed_by_run_id, installed_at, uninstalled_at, uninstalled_by_run_id) "
    "SELECT :id, mv.id, mv.uc_catalog, mv.promoted_by_run_id, "
    "COALESCE(mv.promoted_at, mv.completion_date, mv.created_at, :now), :now, NULL "
    "FROM model_versions mv WHERE mv.id = :version_id "
    "AND NOT EXISTS (SELECT 1 FROM model_version_installs i "
    "WHERE i.version_id = mv.id AND i.catalog = mv.uc_catalog)"
)

# --- step 4: industry dedup -------------------------------------------------
# Every FK column that points at ``industries.id``; a test pairs it against
# ``db_models`` so a new FK cannot be missed by the repoint.
INDUSTRY_FK_COLUMNS: tuple[tuple[str, str], ...] = (("businesses", "industry_id"),)

_INDUSTRIES_SQL = "SELECT id, name, short_name, is_active, is_auto_created FROM industries"
_POINTING_BUSINESSES_SQL = (
    "SELECT industry_id, id, name FROM businesses WHERE industry_id IS NOT NULL"
)
_DEACTIVATE_INDUSTRY_SQL = (
    "UPDATE industries SET is_active = :off, updated_at = :now WHERE id = :id"
)


def _frozen_industry_slug(value: str | None) -> str:
    """Frozen copy of the industry slug rule (lowercase; every run of
    non-alphanumerics becomes one hyphen; hyphens trimmed). Kept here so this
    migration's result never changes when the app's resolver does; an empty
    slug matches nothing."""
    return re.sub(r"[^a-z0-9]+", "-", (value or "").strip().lower()).strip("-")


@dataclass(frozen=True)
class IndustryMerge:
    duplicate_id: str
    duplicate_name: str
    duplicate_short_name: str
    target_id: str
    target_name: str
    business_names: tuple[str, ...]
    business_ids: tuple[str, ...]


@dataclass(frozen=True)
class IndustrySkip:
    industry_id: str
    name: str
    short_name: str
    reason: str  # "stub" | "ambiguous"
    detail: tuple[str, ...]  # stub: the business named after it; ambiguous: the curated names matched


@dataclass(frozen=True)
class IndustryDedupPlan:
    merges: tuple[IndustryMerge, ...]
    skipped: tuple[IndustrySkip, ...]


def plan_industry_dedup(conn: Connection) -> IndustryDedupPlan:
    """Read-only: which auto-created industries merge into which curated one,
    and which are skipped and why. Empty plan when either table is missing."""
    insp = inspect(conn)
    if not (insp.has_table("industries") and insp.has_table("businesses")):
        return IndustryDedupPlan(merges=(), skipped=())
    industries = conn.execute(text(_INDUSTRIES_SQL)).fetchall()
    pointing: dict[str, list[tuple[str, str]]] = {}
    for industry_id, business_id, business_name in conn.execute(text(_POINTING_BUSINESSES_SQL)).fetchall():
        pointing.setdefault(industry_id, []).append((business_name or "", business_id))

    curated_by_slug: dict[str, set[str]] = {}
    curated_names: dict[str, str] = {}
    for ind_id, name, short_name, is_active, is_auto in industries:
        if bool(is_auto) or not bool(is_active):
            continue
        curated_names[ind_id] = name or ""
        for slug in {_frozen_industry_slug(name), _frozen_industry_slug(short_name)} - {""}:
            curated_by_slug.setdefault(slug, set()).add(ind_id)

    merges: list[IndustryMerge] = []
    skipped: list[IndustrySkip] = []
    for ind_id, name, short_name, is_active, is_auto in sorted(industries, key=lambda r: r[0]):
        if not bool(is_auto):
            continue
        pointed = sorted(pointing.get(ind_id, []))
        businesses = [b_name for b_name, _b_id in pointed]
        if not bool(is_active) and not businesses:
            continue
        stub_key = (short_name or "").strip().casefold()
        named_after = tuple(b for b in businesses if stub_key and b.strip().casefold() == stub_key)
        if named_after:
            skipped.append(IndustrySkip(ind_id, name or "", short_name or "", "stub", named_after))
            continue
        targets: set[str] = set()
        for slug in {_frozen_industry_slug(name), _frozen_industry_slug(short_name)} - {""}:
            targets |= curated_by_slug.get(slug, set())
        if len(targets) > 1:
            skipped.append(IndustrySkip(
                ind_id, name or "", short_name or "", "ambiguous",
                tuple(sorted(curated_names[t] for t in targets)),
            ))
            continue
        if targets:
            (target,) = targets
            merges.append(IndustryMerge(
                ind_id, name or "", short_name or "", target, curated_names[target],
                tuple(businesses), tuple(b_id for _b_name, b_id in pointed),
            ))
    return IndustryDedupPlan(merges=tuple(merges), skipped=tuple(skipped))


def _apply_industry_dedup(conn: Connection, now: datetime) -> IndustryDedupPlan:
    plan = plan_industry_dedup(conn)
    deactivate = text(_DEACTIVATE_INDUSTRY_SQL).bindparams(bindparam("now", type_=DateTime()))
    for merge in plan.merges:
        for table, column in INDUSTRY_FK_COLUMNS:
            conn.execute(
                text(f"UPDATE {table} SET {column} = :target WHERE {column} = :dup"),
                {"target": merge.target_id, "dup": merge.duplicate_id},
            )
        conn.execute(deactivate, {"off": False, "now": now, "id": merge.duplicate_id})
        logger.info(
            "v_0_9_0_1: merged auto-created industry %r (%s) into %r (%s) and deactivated it; "
            "%d business(es) repointed: %s",
            merge.duplicate_name, merge.duplicate_id, merge.target_name, merge.target_id,
            len(merge.business_ids),
            ", ".join(f"{b_name!r} ({b_id})" for b_name, b_id in zip(merge.business_names, merge.business_ids))
            or "(none)",
        )
    for skip in plan.skipped:
        logger.warning(
            "v_0_9_0_1: kept auto-created industry %r (%s: %s)",
            skip.name, skip.reason, ", ".join(skip.detail),
        )
    return plan


def _add_column(conn: Connection, table: str, column: str, is_postgres: bool) -> None:
    pg_ddl, sqlite_ddl = NEW_COLUMNS[(table, column)]
    if is_postgres:
        conn.execute(text(pg_ddl))
        return
    present = {row[1] for row in conn.execute(text(f"PRAGMA table_info({table})")).fetchall()}
    if column not in present:
        conn.execute(text(sqlite_ddl))


def _add_columns(conn: Connection, is_postgres: bool) -> None:
    insp = inspect(conn)
    present_tables = {t for (t, _c) in NEW_COLUMNS if insp.has_table(t)}
    for table, column in NEW_COLUMNS:
        if table in present_tables:
            _add_column(conn, table, column, is_postgres)


def _create_tables(conn: Connection) -> None:
    tables = [SQLModel.metadata.tables[name] for name in NEW_TABLES]
    SQLModel.metadata.create_all(conn, tables=tables, checkfirst=True)
    for table in tables:
        for index in table.indexes:
            index.create(conn, checkfirst=True)


def _backfill_installs(conn: Connection, now: datetime) -> tuple[int, int]:
    if not inspect(conn).has_table("model_versions"):
        return 0, 0
    skipped = [row[0] for row in conn.execute(text(_DEPLOYED_WITHOUT_CATALOG_SQL)).fetchall()]
    if skipped:
        logger.warning(
            "v_0_9_0_1: %d deployed version(s) have no uc_catalog and get no install row: %s",
            len(skipped), ", ".join(skipped),
        )
    counts = []
    for candidates_sql, insert_sql in (
        (_OPEN_INSTALL_CANDIDATES_SQL, _INSERT_OPEN_INSTALL_SQL),
        (_CLOSED_INSTALL_CANDIDATES_SQL, _INSERT_CLOSED_INSTALL_SQL),
    ):
        insert = text(insert_sql).bindparams(bindparam("now", type_=DateTime()))
        inserted = 0
        for (version_id,) in conn.execute(text(candidates_sql)).fetchall():
            result = conn.execute(insert, {"id": str(uuid.uuid4()), "version_id": version_id, "now": now})
            inserted += result.rowcount or 0
        counts.append(inserted)
    return counts[0], counts[1]


def apply(engine: Engine) -> None:
    """Add the columns, create the tables and their indexes, backfill install
    rows, then dedup auto-created industries. Idempotent; one transaction,
    both dialects."""
    is_postgres = engine.dialect.name == "postgresql"
    now = datetime.now(timezone.utc)
    with engine.begin() as conn:
        _add_columns(conn, is_postgres)
        _create_tables(conn)
        opened, closed = _backfill_installs(conn, now)
        plan = _apply_industry_dedup(conn, now)
    logger.info(
        "v_0_9_0_1: backfilled %d open and %d closed install row(s); merged %d industr(ies), skipped %d",
        opened, closed, len(plan.merges), len(plan.skipped),
    )


MIGRATION = Migration(
    version="0.9.0.1",
    apply=apply,
    description=(
        "Add runs.linked_at/link_evidence and agent_config.taxonomy_updated_by/at; create "
        "taxonomy_wizard_states, model_version_installs (open-row partial unique index), "
        "metamodel_cleanups (lookup index), run_schema_drops and run_change_decisions; backfill "
        "open and closed install rows; repoint and deactivate auto-created industries that "
        "duplicate one curated industry."
    ),
)
