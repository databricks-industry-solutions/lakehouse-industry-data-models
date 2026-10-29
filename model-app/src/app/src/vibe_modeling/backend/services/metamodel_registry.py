"""The agent's registry in ``<catalog>._metamodel``, set up by the app.

App-only companion of :mod:`services.metamodel_setup` (which the installer
loads by path and keeps stdlib + ``databricks.sdk`` only):

- :func:`ensure_metamodel_registry`: the agent's ``_ensure_metamodel_registry``
  in the app. Every registry writer runs it first
  (``import_metamodel_writer.write_metamodel``,
  ``ModelSyncService.write_model_to_delta``), so a download, kickstart or
  import works in a catalog the agent never ran in. SQL runs through
  ``core._sql``. The app service principal needs ``CREATE_TABLE`` on a
  ``_metamodel`` it does not own (``install/grant_catalog.py`` grants it).
- :func:`registry_schema`: the agent's table columns, from the bundled
  ``metamodel_registry_schema.json``.
- :func:`setup_error_message` / :func:`invisible_metamodel_refusal`: the one
  mapping from a :class:`MetamodelSetupError` to user text;
  :func:`ensure_metamodel_or_refuse`: the setup for a request that writes into
  ``vol_root`` (a download, a dialog import), refused as a 400 with that text.
- :func:`set_deploy_status` / :func:`deploy_status_statement`: the app's one
  write of a registry row's ``deploy_status`` (an uninstall releases its
  rows to ``dry_run``).
"""

from __future__ import annotations

import json
import logging
import time
from dataclasses import dataclass
from functools import lru_cache
from typing import Optional

from databricks.sdk.errors import NotFound
from fastapi import HTTPException

from ..bundled_agent import vendored_agent_file
from ..core import _app_identity
from ..core._names import escape_sql_literal, metamodel_display_business
from ..core._sql import SqlStatementError, rows, run, safe_identifier
from ..core._uc_privileges import grant_statement
from ..error_sanitization import AppMessage
from .metamodel_setup import (
    METAMODEL_SCHEMA,
    VOL_ROOT,
    MetamodelSetupError,
    app_principal,
    ensure_metamodel_schema_and_volume,
    invisible_metamodel_message,
)

logger = logging.getLogger(__name__)


def invisible_metamodel_refusal(ws, catalog: str, volumes: tuple[str, ...] = (VOL_ROOT,)) -> AppMessage:
    """:func:`invisible_metamodel_message` followed by the GRANTs a catalog
    owner runs so the app can see ``_metamodel`` and its ``volumes``. An
    ``AppMessage``: its length grows with the catalog name and the GRANTs come
    last, so the error handler must not cut it at the plain 500 characters."""
    principal = _app_identity.app_application_id(ws) or "<app service principal>"
    grants = [grant_statement({"USE_SCHEMA"}, "schema", (catalog, METAMODEL_SCHEMA), principal)]
    grants += [
        grant_statement({"READ_VOLUME", "WRITE_VOLUME"}, "volume", (catalog, METAMODEL_SCHEMA, v), principal)
        for v in volumes
    ]
    grant_lines = "\n".join(grants)
    return AppMessage(f"{invisible_metamodel_message(catalog, volumes)} Ask a catalog owner to run:\n{grant_lines}")


def setup_error_message(ws, catalog: str, exc: MetamodelSetupError, volumes: tuple[str, ...] = (VOL_ROOT,)) -> str:
    """The user-facing text for a failed setup: the GRANTs to run when
    ``_metamodel`` exists but the app can't see it, the setup's fixed message
    otherwise. The one mapping for every caller that refuses on a
    :class:`MetamodelSetupError`."""
    return invisible_metamodel_refusal(ws, catalog, volumes) if exc.invisible else str(exc)


def ensure_metamodel_or_refuse(ws, catalog: str) -> None:
    """Set up ``<catalog>._metamodel`` and ``vol_root``
    (:func:`ensure_metamodel_schema_and_volume`, idempotent) for a request
    that writes model files there, or refuse it with a 400 carrying
    :func:`setup_error_message`. A request calls it after every check, right
    before its first write. No catalog: nothing to set up."""
    if not catalog:
        return
    try:
        ensure_metamodel_schema_and_volume(ws, catalog)
    except MetamodelSetupError as exc:
        raise HTTPException(status_code=400, detail=setup_error_message(ws, catalog, exc)) from exc


REGISTRY_SCHEMA_FILE = "metamodel_registry_schema.json"

# The bound on the registry DDL when the caller gives none: a cold serverless
# warehouse starts well within it.
_REGISTRY_DDL_TIMEOUT_S = 300.0
_REGISTRY_DDL_WAIT = "50s"
_REGISTRY_DDL_POLL_S = 5.0


@dataclass(frozen=True)
class RegistrySchema:
    """The agent's registry tables as ``_ensure_metamodel_registry`` creates
    them: per table, ``(column, SQL type)`` in order, and the columns it adds
    to an existing ``business`` table that lacks them."""

    tables: dict[str, tuple[tuple[str, str], ...]]
    business_migration_columns: tuple[tuple[str, str], ...]


@lru_cache(maxsize=1)
def registry_schema() -> RegistrySchema:
    """The registry columns, generated from the vendored notebook by
    ``scripts/dev/gen_agent_registry_schema.py`` (pinned by
    ``test_agent_registry_schema_pin.py``)."""
    path = vendored_agent_file(REGISTRY_SCHEMA_FILE)
    if path is None:
        raise FileNotFoundError(f"{REGISTRY_SCHEMA_FILE} is not bundled with the agent notebook")
    data = json.loads(path.read_text())
    return RegistrySchema(
        tables={t: tuple((c, ty) for c, ty in cols) for t, cols in data["tables"].items()},
        business_migration_columns=tuple((c, ty) for c, ty in data["business_migration_columns"]),
    )


def not_identifier_message(catalog: str) -> str:
    return (
        f"The catalog name '{catalog}' isn't a plain identifier (letters, digits, "
        f"underscores); the app can't write the agent's registry there."
    )


def is_plain_identifier(name: str) -> bool:
    try:
        safe_identifier(name)
    except ValueError:
        return False
    return True


def _tables_failure_message(ws, catalog: str) -> str:
    return (
        f"Couldn't create the agent's registry tables (business, domain, product, "
        f"attribute) in '{catalog}.{METAMODEL_SCHEMA}'. Check that the SQL warehouse "
        f"in Settings is running and that the app's service principal "
        f"{app_principal(ws)} has USE_SCHEMA + CREATE_TABLE on that schema (and "
        f"MODIFY on a `business` table it does not own), or run "
        f"`install/grant_catalog.py`, then retry."
    )


def _table_columns(ws, full_name: str) -> Optional[set[str]]:
    """The lower-cased column names of ``full_name``; empty when it is absent,
    None when it could not be read (the caller then runs the idempotent DDL)."""
    try:
        info = ws.tables.get(full_name)
    except NotFound:
        return set()
    except Exception as exc:  # noqa: BLE001 - unreadable: fall back to CREATE IF NOT EXISTS + DESCRIBE
        logger.warning("Reading %s failed: %s", full_name, exc)
        return None
    columns = {str(c.name).lower() for c in (getattr(info, "columns", None) or []) if getattr(c, "name", None)}
    # A table always has columns; none back means the read did not show them.
    return columns or None


def ensure_metamodel_registry(
    ws, catalog: str, warehouse_id: str, *, timeout_s: float = _REGISTRY_DDL_TIMEOUT_S,
) -> list[str]:
    """Set up ``<catalog>._metamodel`` the way the agent's
    ``_ensure_metamodel_registry`` does (vendored 5.3.3 notebook, flat lines
    51728-51745): the schema and ``vol_root``
    (:func:`ensure_metamodel_schema_and_volume`), then each registry table
    ``CREATE TABLE IF NOT EXISTS`` with the agent's columns, then the business
    migration columns ``business`` lacks, one ``ALTER TABLE ... ADD COLUMN``
    each.

    Each table is read through Unity Catalog first: when all four exist and
    ``business`` has every migration column, no SQL runs. A new ``business``
    gets its missing migration columns in the CREATE itself, which leaves the
    same columns in the same order as the agent's CREATE then ALTER. A table
    that can't be read gets the idempotent CREATE, and ``business`` is then
    read with ``DESCRIBE TABLE``. The agent's legacy ``work_completed_percent``
    backfill is not mirrored: it applies only to tables an old agent made.

    No ``warehouse_id``: only the schema and volume are set up (the seed skips
    without a warehouse too). A catalog name that is not a plain identifier
    can't be put into the agent's SQL, so it is refused before anything is
    created. Every SQL statement shares ``timeout_s``. Raises
    :class:`MetamodelSetupError` (``step="tables"`` for the DDL). Returns what
    it created.
    """
    if warehouse_id and not is_plain_identifier(catalog):
        raise MetamodelSetupError(not_identifier_message(catalog), step="tables")
    created = ensure_metamodel_schema_and_volume(ws, catalog)
    if not warehouse_id:
        return created
    try:
        created += _ensure_registry_tables(ws, catalog, warehouse_id, time.monotonic() + timeout_s)
    except MetamodelSetupError:
        raise
    except Exception as exc:  # noqa: BLE001 - any SQL/transport/packaging error refuses with the fixed message
        logger.warning("Creating the registry tables in %s.%s failed: %s", catalog, METAMODEL_SCHEMA, exc,
                       exc_info=True)
        raise MetamodelSetupError(_tables_failure_message(ws, catalog), step="tables") from exc
    if created:
        logger.info("Registry setup in %s: %s", catalog, ", ".join(created))
    return created


def _ensure_registry_tables(ws, catalog: str, warehouse_id: str, deadline: float) -> list[str]:
    schema = registry_schema()
    db = f"{safe_identifier(catalog)}.{safe_identifier(METAMODEL_SCHEMA)}"
    created: list[str] = []

    def bound() -> float:
        remaining = deadline - time.monotonic()
        if remaining <= 0:
            raise SqlStatementError("TIMEOUT", "the registry setup passed its time bound")
        return remaining

    def execute(statement: str) -> None:
        run(ws, warehouse_id, statement, wait_timeout=_REGISTRY_DDL_WAIT, timeout_s=bound(),
            poll_interval_s=_REGISTRY_DDL_POLL_S)

    business_columns: Optional[set[str]] = None
    for table, columns in schema.tables.items():
        found = _table_columns(ws, f"{catalog}.{METAMODEL_SCHEMA}.{table}")
        if table == "business":
            business_columns = found
        if found:
            continue
        defs = list(columns)
        if table == "business" and found is not None:
            names = {c for c, _ in defs}
            defs += [(c, t) for c, t in schema.business_migration_columns if c not in names]
            business_columns = {c for c, _ in defs}
        cols = ", ".join(f"{safe_identifier(c)} {t}" for c, t in defs)
        execute(f"CREATE TABLE IF NOT EXISTS {db}.{safe_identifier(table)} ({cols})")
        if found is not None:
            created.append(f"table {catalog}.{METAMODEL_SCHEMA}.{table}")

    if business_columns is None:
        described = rows(ws, warehouse_id, f"DESCRIBE TABLE {db}.{safe_identifier('business')}",
                         wait_timeout=_REGISTRY_DDL_WAIT, timeout_s=bound(),
                         poll_interval_s=_REGISTRY_DDL_POLL_S) or []
        business_columns = {
            str(r[0]).lower() for r in described if r and r[0] and not str(r[0]).startswith("#")
        }
    for column, column_type in schema.business_migration_columns:
        if column.lower() not in business_columns:
            execute(f"ALTER TABLE {db}.{safe_identifier('business')} ADD COLUMN {safe_identifier(column)} {column_type}")
            created.append(f"column {catalog}.{METAMODEL_SCHEMA}.business.{column}")
    return created


# The agent's registry statuses (``_METAMODEL_DEPLOY_STATUSES``, nb 51578),
# pinned by ``test_registry_status_drift.py``.
DRY_RUN_STATUS = "dry_run"
DEPLOY_STATUSES = ("installed", DRY_RUN_STATUS)
# One bounded server wait. A statement still running then is left running
# (it may still apply), so a caller says the status "may not" have been set.
_DEPLOY_STATUS_WAIT = "30s"


def deploy_status_statement(catalog: str, business: str, version: int, scope: str, status: str) -> str:
    """The UPDATE that sets ``deploy_status`` on the business rows of
    ``business`` v``version`` ``scope`` in ``<catalog>._metamodel``.

    The key is the agent's ``_metamodel_key_sql`` (nb 51601-51602): business
    in any case (the agent stores the display-cased slug), the version as
    text, and the scope or a NULL scope (``_metamodel_scope_sql``, nb
    51597-51598). The ``catalog`` column names ``catalog`` or is blank, as
    the agent's ``_latest_installed_version`` reads its own registry
    (nb 51856-51858). Raises ``ValueError`` for a catalog that is not a
    plain identifier or a status the agent does not know."""
    if status not in DEPLOY_STATUSES:
        raise ValueError(f"deploy_status must be one of {DEPLOY_STATUSES}, got {status!r}")
    table = f"{safe_identifier(catalog)}.{safe_identifier(METAMODEL_SCHEMA)}.`business`"

    def lit(value: object) -> str:
        return f"'{escape_sql_literal(value)}'"

    display = metamodel_display_business(business) or business
    return (
        f"UPDATE {table} SET deploy_status = {lit(status)} "
        f"WHERE LOWER(business) = LOWER({lit(display)}) AND version = {lit(int(version))} "
        f"AND (model_scope = {lit(scope.lower())} OR model_scope IS NULL) "
        f"AND (LOWER(catalog) = LOWER({lit(catalog)}) OR catalog IS NULL OR catalog = '')"
    )


def set_deploy_status(
    ws, warehouse_id: str, catalog: str, business: str, version: int, scope: str, status: str,
    *, wait: str = _DEPLOY_STATUS_WAIT,
) -> None:
    """Run :func:`deploy_status_statement` through ``core._sql`` with one
    bounded server wait (``wait``). Idempotent. Raises :class:`SqlStatementError` when it did
    not succeed (``STILL_RUNNING``: left running, so it may still apply), and
    ``ValueError`` as :func:`deploy_status_statement`."""
    run(
        ws, warehouse_id, deploy_status_statement(catalog, business, version, scope, status),
        wait_timeout=wait, on_timeout="detach",
    )
