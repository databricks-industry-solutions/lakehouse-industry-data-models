"""One-shot helper: connect directly to a Lakebase Autoscaling project and apply
the `_add_missing_columns` migration list. Bypasses the in-app migration code
when the embedded version isn't getting through (observed during testing).

Usage:
  PROFILE=<profile> PROJECT=vibe-modeling python3 scripts/db/migrate.py

Mirrors `core.lakebase._add_missing_columns` exactly. Idempotent (uses
`ADD COLUMN IF NOT EXISTS`).
"""

from __future__ import annotations

import os
import pathlib
import sys

from databricks.sdk import WorkspaceClient
import psycopg

# Import the FK re-pointing rules from the runtime migration - single source of
# truth. The owner script re-runs the identical discover-drop-add sequence as
# ``migrations/v_0_6_6.apply`` so the owner path matches the migration exactly.
# ``src/app/src`` is added to the path so this file runs standalone
# (``python3 scripts/db/migrate.py``) without an installed wheel.
sys.path.insert(
    0, str(pathlib.Path(__file__).resolve().parents[2] / "src" / "app" / "src")
)
from vibe_modeling.backend.migrations.v_0_6_6 import (  # noqa: E402
    FK_RULES,
    PRECLEAN_SOURCE_INDUSTRY_SQL,
    SELF_FK_INDEX_COLUMNS,
    TRGM_INDEX_COLUMNS,
)
from vibe_modeling.backend.migrations.v_0_9_0 import FK_INDEX_COLUMNS  # noqa: E402


MIGRATIONS = [
    ("model_versions", "scope", "TEXT DEFAULT ''"),
    ("agent_config", "warehouse_id", "TEXT DEFAULT ''"),
    ("runs", "vibe_instructions_text", "TEXT DEFAULT ''"),
    ("runs", "vibe_instructions_volume_path", "TEXT DEFAULT ''"),
    ("runs", "business_context_text", "TEXT DEFAULT ''"),
    # v_0_4_0: post-run sync failure surfacing.
    ("model_versions", "sync_state", "VARCHAR DEFAULT 'ok' NOT NULL"),
    ("model_versions", "sync_error_text", "TEXT"),
    # v_0_5_0: imports are syncs, not runs — provenance columns.
    ("model_versions", "import_source_path", "VARCHAR"),
    ("model_versions", "imported_at", "TIMESTAMP"),
    # v_0_6_0: operator-controlled agent job max_concurrent_runs.
    ("agent_config", "max_concurrent_runs", "INTEGER NOT NULL DEFAULT 3"),
    # v_0_6_1: operator-controlled vibe-run statistics opt-in (identity tags).
    ("agent_config", "collect_vibe_run_statistics", "BOOLEAN NOT NULL DEFAULT false"),
    # v_0_6_2: Vibe Inputs redesign — element-lineage self-FK columns +
    # products.subdomain_id (the new tables ride CREATE TABLE, not ADD COLUMN).
    ("domains", "previous_element_id", "VARCHAR"),
    ("products", "previous_element_id", "VARCHAR"),
    ("products", "subdomain_id", "VARCHAR"),
    ("attributes", "previous_element_id", "VARCHAR"),
    ("foreign_key_links", "previous_element_id", "VARCHAR"),
    # v_0_6_3: agent next-vibe classification (nullable; null for origin=user).
    ("vibe_inputs", "category", "VARCHAR"),
    # v_0_6_3: full detailed business description → model_vibes seed on run 1.
    ("businesses", "business_vibes", "TEXT DEFAULT ''"),
    # v_0_6_4: Industry Management spine — businesses.kind discriminator
    # (business|industry), sector_id FK, source_industry_id self-FK +
    # source_version (kickstart provenance). The sectors table rides
    # CREATE TABLE in the runtime migration, not this ADD COLUMN list.
    ("businesses", "kind", "VARCHAR NOT NULL DEFAULT 'business'"),
    ("businesses", "sector_id", "VARCHAR"),
    ("businesses", "source_industry_id", "VARCHAR"),
    ("businesses", "source_version", "INTEGER"),
    ("businesses", "source_repo_path", "VARCHAR"),
    # v_0_6_4: agent_config GitHub publish/browse config (ADR D-049).
    ("agent_config", "github_repo_owner", "VARCHAR DEFAULT ''"),
    ("agent_config", "github_repo_name", "VARCHAR DEFAULT ''"),
    ("agent_config", "github_auth_mode", "VARCHAR DEFAULT ''"),
    ("agent_config", "github_connection_name", "VARCHAR DEFAULT ''"),
    ("agent_config", "github_secret_scope", "VARCHAR DEFAULT ''"),
    ("agent_config", "github_secret_key", "VARCHAR DEFAULT ''"),
    # v_0_6_6: run_operations dispatched-widgets audit trail (bug bash item:
    # surface the actual widget map dispatch() sent to jobs.run_now()).
    ("run_operations", "dispatched_widgets_json", "TEXT DEFAULT '{}'"),
    # v_0_7_0: ModelVersion version provenance (agent-logic counter 4.x.y +
    # public/compat release identity 0.8.0), stamped from the model.json
    # envelope at sync/import time. Nullable — pre-existing rows stay NULL.
    ("model_versions", "agent_version", "TEXT"),
    ("model_versions", "release_version", "TEXT"),
    # v_0_7_1: upstream agent-release monitor cache on the agent_config
    # singleton (Surface 2). Live-read from the canonical repo notebook,
    # cached 7 days. All nullable — a cold cache stays NULL.
    ("agent_config", "upstream_release_version", "TEXT"),
    ("agent_config", "upstream_agent_version", "TEXT"),
    ("agent_config", "upstream_checked_at", "TIMESTAMP"),
    ("agent_config", "upstream_check_error", "TEXT"),
    # v_0_7_3: source READ-auth config on the agent_config singleton. All
    # defaulted to '' (unconfigured → env → anonymous). Secret material lives
    # in a Databricks secret scope; only the scope/key REFERENCES land here.
    ("agent_config", "source_auth_mode", "VARCHAR DEFAULT ''"),
    ("agent_config", "source_github_app_id", "VARCHAR DEFAULT ''"),
    ("agent_config", "source_github_app_installation_id", "VARCHAR DEFAULT ''"),
    ("agent_config", "source_github_app_secret_scope", "VARCHAR DEFAULT ''"),
    ("agent_config", "source_github_app_secret_key", "VARCHAR DEFAULT ''"),
    ("agent_config", "source_token_secret_scope", "VARCHAR DEFAULT ''"),
    ("agent_config", "source_token_secret_key", "VARCHAR DEFAULT ''"),
    # v_0_8_0: Domain Taxonomy Builder settings on the agent_config singleton
    # ('' = no model service configured) and the wizard's proposed domains +
    # coverage on businesses ('' = no proposal).
    ("agent_config", "taxonomy_model_service", "VARCHAR DEFAULT ''"),
    ("agent_config", "taxonomy_llm_max_concurrency", "INTEGER NOT NULL DEFAULT 6"),
    ("businesses", "business_domains", "VARCHAR DEFAULT ''"),
    ("businesses", "org_divisions", "VARCHAR DEFAULT ''"),
    # v_0_9_0: version lifecycle on model_versions (Dry Run flag, promotion,
    # replacement, files location, _vibe_scope facts), per-feedback outcomes on
    # run_input_links, the consuming run on vibe_inputs, and the installed
    # notebook identity cache on agent_config. The three FK columns are
    # ON DELETE SET NULL; their indexes ride FK_INDEX_COLUMNS below. The two
    # new tables (run_agent_reports, run_post_install_deletes) and the
    # files_catalog / dry_run backfills run in the in-app migration only.
    ("model_versions", "dry_run", "BOOLEAN NOT NULL DEFAULT false"),
    ("model_versions", "promoted_at", "TIMESTAMP"),
    ("model_versions", "promoted_by_run_id", "VARCHAR REFERENCES runs(id) ON DELETE SET NULL"),
    (
        "model_versions",
        "replaced_by_version_id",
        "VARCHAR REFERENCES model_versions(id) ON DELETE SET NULL",
    ),
    ("model_versions", "replaced_at", "TIMESTAMP"),
    ("model_versions", "files_catalog", "VARCHAR"),
    ("model_versions", "scope_fence_mode", "VARCHAR"),
    ("model_versions", "scope_base_version", "INTEGER"),
    ("model_versions", "scope_base_scope", "VARCHAR"),
    ("run_input_links", "outcome_status", "VARCHAR"),
    ("run_input_links", "outcome_reason", "TEXT"),
    ("run_input_links", "outcome_target", "VARCHAR"),
    ("vibe_inputs", "consumed_by_run_id", "VARCHAR REFERENCES runs(id) ON DELETE SET NULL"),
    ("agent_config", "installed_release_version", "VARCHAR"),
    ("agent_config", "installed_agent_version", "VARCHAR"),
    ("agent_config", "installed_checked_at", "TIMESTAMP"),
    ("agent_config", "installed_checked_path", "VARCHAR"),
    ("agent_config", "installed_check_error", "VARCHAR"),
    # v_0_9_0_1: link-run provenance on runs and the taxonomy settings audit
    # pair on agent_config. The five new tables (install locations, metamodel
    # cleanups, schema drops, change decisions, wizard state), the install-row
    # backfill and the industry dedup run in the in-app migration only.
    ("runs", "linked_at", "TIMESTAMP"),
    ("runs", "link_evidence", "VARCHAR"),
    ("agent_config", "taxonomy_updated_by", "VARCHAR"),
    ("agent_config", "taxonomy_updated_at", "TIMESTAMP"),
    # v_0_9_0_3: the Settings default run time budget (whole hours) on the
    # agent_config singleton.
    ("agent_config", "runtime_budget_hours", "INTEGER NOT NULL DEFAULT 6"),
    # v_0_9_0_4: the scope prefixes an import added to a model.
    ("model_versions", "import_schema_prefix_added", "VARCHAR"),
    ("model_versions", "import_view_prefix_added", "VARCHAR"),
]

WIDEN_TO_BIGINT = [
    ("runs", "last_consumed_step_id"),
    ("run_progress_events", "step_id"),
    ("run_progress_events", "event_seq"),
]

DROP_NOT_NULL = [
    ("agent_config", "agent_version"),
    # v_0_5_0: imports don't have a parent Run; the artifact indexer
    # writes rows with NULL run_id.
    ("run_artifacts", "run_id"),
]

# Subtractive column drops mirroring the runtime registry's DROP COLUMN
# migrations. Order matters: must match the registry's emission order so
# the drift test can pair them positionally. Phase 5 retired the legacy
# state-machine columns on `runs` (v_0_3_0); future drops append here.
DROP_COLUMNS: list[tuple[str, str]] = [
    ("runs", "run_type"),
    ("runs", "rollback_plan"),
    # v_0_6_4: retire the lossy next_vibes_json blob — structured
    # VibeInput(agent_next_vibe) rows replace it.
    ("model_versions", "next_vibes_json"),
]


def main() -> int:
    profile = os.environ.get("PROFILE") or os.environ.get("DATABRICKS_CONFIG_PROFILE")
    if not profile:
        print("PROFILE env required (e.g., PROFILE=<profile>)", file=sys.stderr)
        return 1
    project = os.environ.get("PROJECT", "vibe-modeling")
    database = os.environ.get("DATABASE", "vibe_modeling")
    branch = (
        os.environ.get("BRANCH")
        or os.environ.get("VIBE_MODELING_LAKEBASE_BRANCH")
        or "production"
    )

    # Production guard. Applying migrations against the production branch is
    # off-limits except the formal release cut. Point BRANCH (or
    # VIBE_MODELING_LAKEBASE_BRANCH) at a disposable fork, or set
    # ALLOW_PRODUCTION_DEPLOY=1 for the release cut.
    if branch == "production" and os.environ.get("ALLOW_PRODUCTION_DEPLOY") != "1":
        print(
            "REFUSING: this would target the PRODUCTION Lakebase branch. "
            "Production is off-limits except the formal release cut. Point "
            "VIBE_MODELING_LAKEBASE_BRANCH at a disposable fork, or (release "
            "cut only) set ALLOW_PRODUCTION_DEPLOY=1.",
            file=sys.stderr,
        )
        return 1

    endpoint_name = f"projects/{project}/branches/{branch}/endpoints/primary"
    print(f"profile:  {profile}")
    print(f"endpoint: {endpoint_name}")
    print(f"database: {database}")

    ws = WorkspaceClient(profile=profile)

    print("fetching endpoint...")
    endpoint = ws.postgres.get_endpoint(name=endpoint_name)
    host = endpoint.status.hosts.host
    port = 5432
    print(f"host: {host}:{port}")

    print("generating credential...")
    cred = ws.postgres.generate_database_credential(endpoint=endpoint_name)
    # Different SDK versions stash the short-lived password under different
    # attribute names. Try the common candidates.
    password = (
        getattr(cred, "token", None)
        or getattr(cred, "credential", None)
        or getattr(cred, "password", None)
    )
    if not password:
        print(f"could not extract password from credential: {cred!r}", file=sys.stderr)
        return 2

    username = ws.config.client_id or ws.current_user.me().user_name
    print(f"connecting as {username}")

    conn_str = (
        f"host={host} port={port} dbname={database} user={username} "
        f"password={password} sslmode=require"
    )
    with psycopg.connect(conn_str, autocommit=True) as conn:
        with conn.cursor() as cur:
            for table, column, col_type in MIGRATIONS:
                stmt = f"ALTER TABLE {table} ADD COLUMN IF NOT EXISTS {column} {col_type}"
                try:
                    cur.execute(stmt)
                    print(f"  OK    {table}.{column}")
                except Exception as e:
                    print(f"  FAIL  {table}.{column}: {e!r}")
            for table, column in WIDEN_TO_BIGINT:
                stmt = f"ALTER TABLE {table} ALTER COLUMN {column} TYPE BIGINT"
                try:
                    cur.execute(stmt)
                    print(f"  WIDEN {table}.{column}")
                except Exception as e:
                    print(f"  WIDEN-skip {table}.{column}: {e!r}")
            for table, column in DROP_NOT_NULL:
                stmt = f"ALTER TABLE {table} ALTER COLUMN {column} DROP NOT NULL"
                try:
                    cur.execute(stmt)
                    print(f"  DROP-NOTNULL {table}.{column}")
                except Exception as e:
                    print(f"  DROP-NOTNULL-skip {table}.{column}: {e!r}")
            for table, column in DROP_COLUMNS:
                stmt = f"ALTER TABLE {table} DROP COLUMN IF EXISTS {column}"
                try:
                    cur.execute(stmt)
                    print(f"  DROP {table}.{column}")
                except Exception as e:
                    print(f"  DROP-skip {table}.{column}: {e!r}")
            # v_0_6_6 + v_0_9_0: index the SET NULL FK columns (imported from
            # the migrations so there is one definition). Idempotent; safe in
            # autocommit (non-CONCURRENT CREATE INDEX IF NOT EXISTS).
            for table, column in (*SELF_FK_INDEX_COLUMNS, *FK_INDEX_COLUMNS):
                stmt = (
                    f"CREATE INDEX IF NOT EXISTS ix_{table}_{column} "
                    f"ON {table} ({column})"
                )
                try:
                    cur.execute(stmt)
                    print(f"  INDEX ix_{table}_{column}")
                except Exception as e:
                    print(f"  INDEX-skip ix_{table}_{column}: {e!r}")
            # v_0_6_6: pg_trgm GIN indexes backing searchModelElements' attribute
            # ILIKE filter (imported from the migration - single definition).
            # Best-effort: autocommit means a failed statement here does not
            # poison the DDL loop above or the transactional FK re-point below.
            try:
                cur.execute("CREATE EXTENSION IF NOT EXISTS pg_trgm")
                print("  EXTENSION pg_trgm")
                for table, column in TRGM_INDEX_COLUMNS:
                    index_name = f"ix_trgm_{table}_{column}"
                    stmt = (
                        f"CREATE INDEX IF NOT EXISTS {index_name} ON {table} "
                        f"USING gin ({column} gin_trgm_ops)"
                    )
                    try:
                        cur.execute(stmt)
                        print(f"  INDEX {index_name}")
                    except Exception as e:
                        print(f"  INDEX-skip {index_name}: {e!r}")
            except Exception as e:
                print(f"  EXTENSION-skip pg_trgm: {e!r} (trigram indexes skipped)")
            # Verify each newly-added column exists.
            print("\nverifying:")
            for table, column, _ in MIGRATIONS:
                cur.execute(
                    "SELECT 1 FROM information_schema.columns "
                    "WHERE table_name = %s AND column_name = %s",
                    (table, column),
                )
                ok = cur.fetchone() is not None
                print(f"  {'PRESENT' if ok else 'MISSING'}  {table}.{column}")

    # v_0_6_6 FK re-pointing. UNSAFE under the autocommit log-and-continue
    # pattern above: a DROP CONSTRAINT that succeeds followed by an ADD
    # CONSTRAINT that fails would leave the column with NO FK while the script
    # exits 0. So this section runs in a SINGLE transaction and exits non-zero
    # on any error - a partial re-point rolls back and the operator re-runs.
    rc = _repoint_fks(conn_str)
    if rc != 0:
        return rc
    return 0


def _repoint_fks(conn_str: str) -> int:
    """Re-point every FK in ``FK_RULES`` to its ON DELETE action, transactionally.

    Mirrors ``migrations/v_0_6_6._repoint_foreign_keys`` (imports the same
    ``FK_RULES`` object) and runs the ``source_industry_id`` pre-clean ahead of
    the loop, exactly like the runtime migration. Returns 0 on success, non-zero
    on any FK error (with the transaction rolled back).
    """
    print("\nre-pointing foreign keys (v_0_6_6, transactional):")
    try:
        with psycopg.connect(conn_str, autocommit=False) as conn:
            with conn.cursor() as cur:
                # Pre-clean orphaned source_industry_id BEFORE its ADD CONSTRAINT.
                cur.execute(PRECLEAN_SOURCE_INDUSTRY_SQL)
                for child, column, parent, action in FK_RULES:
                    cur.execute(
                        """
                        SELECT con.conname
                        FROM pg_constraint con
                        JOIN pg_class rel ON rel.oid = con.conrelid
                        JOIN pg_attribute att
                          ON att.attrelid = con.conrelid
                         AND att.attnum = ANY (con.conkey)
                        WHERE con.contype = 'f'
                          AND rel.relname = %s
                          AND att.attname = %s
                          AND array_length(con.conkey, 1) = 1
                        """,
                        (child, column),
                    )
                    for (conname,) in cur.fetchall():
                        cur.execute(
                            f'ALTER TABLE {child} DROP CONSTRAINT "{conname}"'
                        )
                    cur.execute(
                        f"ALTER TABLE {child} ADD CONSTRAINT {child}_{column}_fkey "
                        f"FOREIGN KEY ({column}) REFERENCES {parent}(id) "
                        f"ON DELETE {action}"
                    )
                    print(f"  FK    {child}.{column} -> {parent} ON DELETE {action}")
            conn.commit()
    except Exception as e:
        print(f"  FK-FAIL (rolled back): {e!r}", file=sys.stderr)
        return 3
    return 0


if __name__ == "__main__":
    sys.exit(main())
