"""Progress-table schema compat for legacy STRING `_vibe_progress.result_json`.

Background
----------
Pre-v0.5 builds of the modelling agent created `_metamodel._vibe_progress` with
`result_json STRING`. v0.5.x+ uses `parse_json(...)` on the INSERT path, which
returns VARIANT. Inserting VARIANT into STRING fails with
`CANNOT_UP_CAST_DATATYPE`, breaking every flush (the user sees "Running —
waiting for agent to report progress" until timeout).

The app's READ path is already compatible — `progress_tracker` wraps
`result_json` in `CAST(... AS STRING)`, which works for both schemas. The fix
is purely on the agent-side INSERT path: detect legacy STRING schemas before
launch and repair them so the agent's `CREATE TABLE IF NOT EXISTS` recreates
the table with VARIANT.

Strategy
--------
Option B from the plan: on a model-producing launch, check
`information_schema.columns` for the column type; if STRING, DROP the table
and let the agent recreate it as VARIANT on the first flush. This is safe
because the app mirrors every consumed event to Lakebase
(`run_progress_events`) — the Delta table is event log only, not a source of
truth for anything the app later reads.

Best-effort: any failure (permissions, warehouse unreachable, legacy
workspace that can't be repaired) is logged at WARN and swallowed. The run
still launches; if the legacy schema is present, the agent will fail at
first flush with the old error — which is no worse than today. A failed
probe is never read as a schema: the DROP runs only on a confirmed STRING
column, and a catalog is cached only after a successful probe or repair.
"""

from __future__ import annotations

import logging
import threading
from typing import Literal

from databricks.sdk import WorkspaceClient

from .core._sql import SqlStatementError, run, scalar

logger = logging.getLogger(__name__)

ResultJsonType = Literal["VARIANT", "STRING", "MISSING"]

# Per-catalog cache so we only probe + repair once per process per catalog.
# Populated after a successful `ensure_progress_schema` call; subsequent
# launches short-circuit. Cleared on process restart.
_ENSURED_CATALOGS: set[str] = set()
_CACHE_LOCK = threading.Lock()


def detect_result_json_type(
    ws: WorkspaceClient,
    warehouse_id: str,
    catalog: str,
) -> ResultJsonType:
    """Detect the storage type of `_metamodel._vibe_progress.result_json`.

    Returns:
        - "VARIANT" — current v0.5.x schema; no action needed.
        - "STRING"  — legacy pre-v0.5 schema; INSERTs from the agent will fail.
        - "MISSING" — table does not exist; the agent's CREATE IF NOT EXISTS
                      will create it as VARIANT on next run. No action needed.

    Uses `information_schema.columns` (already used elsewhere in the app).
    Raises `SqlStatementError` when the probe fails, so no caller acts on
    a guessed type.
    """
    if not catalog or not warehouse_id:
        return "MISSING"

    sql = (
        f"SELECT UPPER(data_type) "
        f"FROM `{catalog}`.`information_schema`.`columns` "
        f"WHERE table_schema = '_metamodel' "
        f"AND table_name   = '_vibe_progress' "
        f"AND column_name  = 'result_json' "
        f"LIMIT 1"
    )
    # Fails fast on purpose (one 30 s wait, no polls): this runs inside
    # launch_run, and on a cold warehouse the repair is skipped for this
    # launch and probed again on the next one.
    found = scalar(ws, warehouse_id, sql, wait_timeout="30s")
    if found is None:
        return "MISSING"
    dtype = str(found).upper().strip()
    if dtype == "VARIANT":
        return "VARIANT"
    if dtype == "STRING":
        return "STRING"
    # Anything else (unexpected type) — treat as MISSING rather than guessing.
    logger.warning(
        "progress_schema: unexpected result_json data_type %r in %s._metamodel._vibe_progress; "
        "skipping repair.",
        dtype, catalog,
    )
    return "MISSING"


def ensure_progress_schema(
    ws: WorkspaceClient,
    warehouse_id: str,
    catalog: str,
    *,
    strategy: str = "drop",
) -> None:
    """Ensure `_vibe_progress.result_json` is VARIANT-compatible before launch.

    Best-effort: any exception is logged at WARN and swallowed — legacy
    workspaces that can't be repaired still attempt the run (no worse than
    today's behavior). A failed probe skips the repair and caches nothing,
    so the next launch probes again.

    - `strategy="drop"` (default): if STRING detected, DROP the table and
      let the agent recreate it as VARIANT on first flush. Safe because the
      app mirrors every consumed event to Lakebase `run_progress_events`.
    - `strategy="alter"`: reserved for future use (in-place ALTER COLUMN).
      Currently falls through to a no-op with a warning.
    - `strategy="off"`: skip entirely.

    Cached per-catalog in-process: a successful call short-circuits further
    probes in the same process lifetime.
    """
    try:
        if not catalog or not warehouse_id:
            return
        if strategy == "off":
            return

        with _CACHE_LOCK:
            if catalog in _ENSURED_CATALOGS:
                return

        try:
            dtype = detect_result_json_type(ws, warehouse_id, catalog)
        except SqlStatementError as e:
            logger.warning(
                "progress_schema: result_json probe failed for %s (%s); "
                "skipping repair, will probe again on the next launch.",
                catalog, e,
            )
            return

        if dtype in ("VARIANT", "MISSING"):
            # Already good, or not-yet-existing — the agent will create it
            # correctly on first flush.
            with _CACHE_LOCK:
                _ENSURED_CATALOGS.add(catalog)
            return

        # dtype == "STRING" — legacy schema, needs repair.
        if strategy == "drop":
            drop_sql = (
                f"DROP TABLE IF EXISTS `{catalog}`.`_metamodel`.`_vibe_progress`"
            )
            try:
                run(ws, warehouse_id, drop_sql, wait_timeout="30s")
            except SqlStatementError as e:
                logger.warning(
                    "progress_schema: DROP failed for %s._metamodel._vibe_progress (%s); "
                    "legacy STRING schema still in place. Agent INSERT may fail at "
                    "first flush.",
                    catalog, e,
                )
                return
            logger.info(
                "progress_schema: dropped legacy STRING _vibe_progress table in %s; "
                "agent will recreate as VARIANT on next run.",
                catalog,
            )
            with _CACHE_LOCK:
                _ENSURED_CATALOGS.add(catalog)
            return

        if strategy == "alter":
            logger.warning(
                "progress_schema: strategy='alter' is not implemented; "
                "leaving legacy STRING schema in place for %s. Agent INSERT "
                "may fail at first flush.",
                catalog,
            )
            return

        logger.warning(
            "progress_schema: unknown strategy %r; skipping repair for %s.",
            strategy, catalog,
        )
    except Exception as e:
        # Catch-all: never let schema maintenance block a launch.
        logger.warning(
            "progress_schema: ensure_progress_schema failed for %s: %s",
            catalog, e,
        )


def _reset_cache_for_testing() -> None:
    """Clear the per-catalog cache. Intended for test use only."""
    with _CACHE_LOCK:
        _ENSURED_CATALOGS.clear()
