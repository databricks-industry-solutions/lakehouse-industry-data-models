"""Write a model.json's structure into the agent's ``_metamodel.*`` Delta tables.

The agent's Phase 1 (vibe-iterate, shrink, enlarge) reads its system of
record from ``<deployment_catalog>._metamodel.{business,domain,product,attribute}``.
Imports bypass the agent entirely, so without this writer an imported
model can never be the input to a subsequent vibe-iterate run.

Before the first INSERT, :func:`metamodel_registry.ensure_metamodel_registry`
sets up the schema, ``vol_root`` and the agent's four registry tables when
any is missing, so a seed works in a catalog the agent never ran in.

The business row is a non-owning seed: ``deploy_status = 'dry_run'``, one of
the agent's two statuses (``_METAMODEL_DEPLOY_STATUSES``, nb 51578). The
agent's ownership snapshot skips ``dry_run`` rows (nb 7926-7927) and its
``_latest_installed_version`` counts only NULL or ``installed`` (nb 51855),
so a seeded version owns no schema names until an install registers it as
``installed`` (nb 51729); a failed install restores ``dry_run`` (nb
51796-51819). ``location`` is the version's folder: the agent appends
``/model.json`` to it (nb 53581).

This module produces INSERT rows matching the agent's column shape
(verified against ``vibe_modeling_test._metamodel.*`` on a test workspace
2026-05-11). It does not DELETE / UPDATE / TRUNCATE — every call only
appends new rows. Re-importing the same scope/version would produce
duplicates; callers are expected to bump the version per import or
clean the prior rows out-of-band.

Best-effort: every failure is logged and swallowed so the import's
HTTP response is not affected. Failures land in the returned summary's
``errors``; ``seed_metamodel_one`` logs them at ERROR.

The caller picks how long to wait (``WaitMode``); every bound is wall-clock
time on ``time.monotonic``:

- ``"request"`` (imports and downloads answered in the HTTP request): the
  whole write waits at most ``_REQUEST_BUDGET_S`` (90 s), then stops waiting
  and leaves the remaining statements running in the warehouse; their ids
  are reported in ``summary["still_running"]``.
- ``"background"`` (kickstart): each INSERT polls to a terminal state for at
  most ``_BACKGROUND_INSERT_TIMEOUT_S`` (10 min) and is cancelled at the end
  of it; the whole write is capped at ``_BACKGROUND_WRITE_TIMEOUT_S`` (20 min).

The registry setup runs first, inside the same bound; the business row is
the first INSERT, so it gets the rest of the wait.
"""
from __future__ import annotations

import logging
import time
from datetime import datetime, timezone
from dataclasses import dataclass, field
from typing import Any, Literal, Optional

from databricks.sdk import WorkspaceClient

from ..core._names import (
    escape_sql_literal as _esc,
    metamodel_display_business,
)
from ..core._sql import SqlStatementError, run
from ..error_sanitization import is_opaque_error, recorded_error_text, sanitize_error_message
from ..import_model import model_payload
from .metamodel_registry import DRY_RUN_STATUS, ensure_metamodel_registry
from .metamodel_setup import MetamodelSetupError

logger = logging.getLogger(__name__)


def _sql_str(v: Any) -> str:
    """Quote a Python value as a SQL VARCHAR literal. ``None`` → ``NULL``."""
    if v is None:
        return "NULL"
    return f"'{_esc(str(v))}'"


def _sql_double(v: Any) -> str:
    if v is None:
        return "NULL"
    try:
        return f"{float(v)}"
    except (TypeError, ValueError):
        return "NULL"


def _sql_bigint(v: Any) -> str:
    if v is None:
        return "NULL"
    try:
        return f"{int(v)}"
    except (TypeError, ValueError):
        return "NULL"


def _sql_ts(v: Optional[datetime]) -> str:
    if v is None:
        return "NULL"
    # Spark/DB SQL TIMESTAMP literal: 'YYYY-MM-DD HH:MM:SS.ffffff'
    return f"TIMESTAMP '{v.strftime('%Y-%m-%d %H:%M:%S.%f')}'"


# Default rows-per-INSERT. The _metamodel tables are append-only and a
# single multi-row INSERT lands all rows in one warehouse round-trip.
#
# Live retime (2026-07) measured this path at a FLAT ~2.05s/statement —
# per-statement warehouse round-trip + Delta commit latency, independent
# of how many rows the statement carries. A 200-row chunk therefore left
# real throughput on the table: a 6450-attribute-row kickstart model took
# 36 statements x 2.05s = 74s. There is no documented hard limit on
# Databricks SQL statement text length in the Statement Execution API;
# 6450 rows at ~200 bytes/row is ~1.3MB, comfortably inside normal HTTP
# body limits. 10,000 keeps a single statement per table for every
# realistic model size (collapsing the kickstart case to ~4 statements
# total, ~8s) while still bounding statement size for any pathologically
# large future model instead of going fully unbounded.
DEFAULT_CHUNK_SIZE = 10_000


WaitMode = Literal["request", "background"]

APP_SEED_SESSION_ID = 0

_INSERT_WAIT_TIMEOUT = "50s"
_INSERT_POLL_INTERVAL_S = 5.0
# "request": the whole write, all INSERTs together.
_REQUEST_BUDGET_S = 90.0
# "background": each INSERT (enough for a warehouse cold start), and the
# whole write.
_BACKGROUND_INSERT_TIMEOUT_S = 600.0
_BACKGROUND_WRITE_TIMEOUT_S = 1200.0


@dataclass
class _WaitBudget:
    mode: WaitMode
    deadline: float
    still_running: list[str] = field(default_factory=list)


def _exec(ws: WorkspaceClient, warehouse_id: str, statement: str, budget: _WaitBudget) -> None:
    """Run one INSERT; raises ``SqlStatementError`` unless it SUCCEEDED or,
    in ``"request"`` mode, is still running when the write's budget is spent.

    ``"background"``: wait up to ``_BACKGROUND_INSERT_TIMEOUT_S`` or what is
    left of the write's cap, whichever is shorter; an INSERT still running
    then is cancelled (best-effort) and raises TIMEOUT. A spent write cap
    raises TIMEOUT without submitting.
    ``"request"``: wait within what is left of the write's budget (a ``0s``
    submit once it is spent); an INSERT still running then is left running
    and its id recorded in ``budget.still_running``.
    """
    remaining = budget.deadline - time.monotonic()
    if budget.mode == "background":
        if remaining <= 0:
            raise SqlStatementError(
                "TIMEOUT",
                f"the _metamodel write passed its {_BACKGROUND_WRITE_TIMEOUT_S:.0f}s cap; "
                "remaining INSERTs not submitted",
            )
        run(
            ws, warehouse_id, statement,
            wait_timeout=_INSERT_WAIT_TIMEOUT,
            timeout_s=min(_BACKGROUND_INSERT_TIMEOUT_S, remaining),
            poll_interval_s=_INSERT_POLL_INTERVAL_S,
        )
        return
    try:
        run(
            ws, warehouse_id, statement,
            wait_timeout=_INSERT_WAIT_TIMEOUT,
            timeout_s=max(remaining, 0.0),
            poll_interval_s=_INSERT_POLL_INTERVAL_S,
            on_timeout="detach",
        )
    except SqlStatementError as exc:
        if exc.state != "STILL_RUNNING":
            raise
        budget.still_running.append(exc.statement_id or "<no statement id>")


def _insert_batched(
    ws: WorkspaceClient,
    warehouse_id: str,
    *,
    table: str,
    columns: list[str],
    rows: list[list[str]],
    chunk_size: int,
    budget: _WaitBudget,
) -> int:
    """Append ``rows`` to ``table`` via chunked multi-row INSERTs.

    Each ``row`` is a list of pre-quoted SQL value literals aligned with
    ``columns``. Rows are grouped into ``chunk_size``-sized batches; each
    batch is a single ``INSERT INTO ... VALUES (...), (...), ...``
    statement. No-op when ``rows`` is empty.

    Returns the number of INSERT statements issued (for the caller's
    statement-count evidence log).
    """
    if not rows:
        return 0
    step = chunk_size if chunk_size > 0 else len(rows)
    cols_clause = ", ".join(f"`{c}`" for c in columns)
    statements = 0
    for start in range(0, len(rows), step):
        chunk = rows[start:start + step]
        values_clause = ", ".join(f"({', '.join(r)})" for r in chunk)
        _exec(
            ws, warehouse_id,
            f"INSERT INTO {table} ({cols_clause}) VALUES {values_clause}",
            budget,
        )
        statements += 1
    return statements


def _conventions_to_json(conventions: Any) -> str:
    """The agent stores ``model_conventions`` as a JSON STRING in the Delta
    business row. The model.json typically holds it as a dict — serialise.
    """
    if conventions is None:
        return ""
    if isinstance(conventions, str):
        return conventions
    try:
        import json as _json
        return _json.dumps(conventions, ensure_ascii=False)
    except Exception:
        return ""


def write_metamodel(
    ws: WorkspaceClient,
    *,
    catalog: str,
    warehouse_id: str,
    model_json: dict,
    business_name: str,
    scope: str,
    version: int,
    wait_mode: WaitMode,
    chunk_size: int = DEFAULT_CHUNK_SIZE,
    location: Optional[str] = None,
) -> dict:
    """Append rows for the imported model to ``<catalog>._metamodel.{business,
    domain,product,attribute}``.

    ``location`` is the business row's ``location``: the version's folder in
    the app's Volume (``core/_paths.version_dir_in_volume``), where a vibe of
    it reads its model.json (the agent appends ``/model.json``, nb 53581).
    ``None`` keeps the model's own ``location`` value.

    Domain/product/attribute rows are batched into chunked multi-row
    INSERTs (``chunk_size`` rows per statement) so a multi-thousand-row
    model lands in a handful of warehouse round-trips instead of one per
    row — the per-row path could exceed the Databricks Apps reverse-proxy
    timeout and wedge the import request.

    Returns a summary dict ``{"business": int, "domain": int, "product": int,
    "attribute": int, "errors": list[str], "still_running": list[str]}``.
    Row counts are rows submitted. ``still_running`` holds the ids of
    statements left running in ``"request"`` mode (a warning: the rows appear
    when the warehouse finishes them). Always returns; never raises.
    """
    summary: dict[str, Any] = {
        "business": 0, "domain": 0, "product": 0, "attribute": 0,
        "errors": [], "still_running": [],
    }
    if not ws or not catalog or not warehouse_id or not business_name or not scope:
        summary["errors"].append(
            "missing required arg: ws/catalog/warehouse_id/business_name/scope"
        )
        return summary

    started = time.monotonic()
    budget = _WaitBudget(
        mode=wait_mode,
        deadline=started + (
            _REQUEST_BUDGET_S if wait_mode == "request" else _BACKGROUND_WRITE_TIMEOUT_S
        ),
    )
    summary["still_running"] = budget.still_running
    statement_count = 0
    try:
        ensure_metamodel_registry(
            ws, catalog, warehouse_id, timeout_s=max(budget.deadline - time.monotonic(), 0.0),
        )
    except MetamodelSetupError as exc:
        logger.error("import_metamodel_writer: registry setup in %s failed: %s", catalog, exc)
        summary["errors"].append(str(exc))
        return summary
    try:
        model = model_payload(model_json)
        # The agent stores the display-cased slug in _metamodel.business.business
        # (e.g. "Terranova_Copy"), not the raw lowercase segment. Use the
        # same transform so iterate preflights and agent reads find the row.
        agent_biz = metamodel_display_business(business_name) or business_name
        version_str = str(version)
        scope_str = scope.lower()
        now = datetime.now(timezone.utc)

        # 1. business row -------------------------------------------------
        bus_cols = [
            ("business", _sql_str(agent_biz)),
            ("version", _sql_str(version_str)),
            ("model_scope", _sql_str(scope_str)),
            ("industry_alignment", _sql_str(model.get("industry_alignment", ""))),
            ("description", _sql_str(model.get("description", ""))),
            ("catalog", _sql_str(catalog)),
            ("location", _sql_str(model.get("location", "") if location is None else location)),
            ("core_business_processes", _sql_str(model.get("core_business_processes", ""))),
            ("orgnaization_divisions", _sql_str(model.get("orgnaization_divisions", ""))),
            ("data_domains", _sql_str(model.get("data_domains", ""))),
            ("common_business_jargons", _sql_str(model.get("common_business_jargons", ""))),
            ("operational_systems_of_records", _sql_str(model.get("operational_systems_of_records", ""))),
            ("industry_governing_body", _sql_str(model.get("industry_governing_body", ""))),
            ("vibe_modelling_instructions", _sql_str(model.get("vibe_modelling_instructions", ""))),
            ("model_conventions", _sql_str(_conventions_to_json(model.get("model_conventions")))),
            ("completion_date", _sql_ts(now)),
            # session_id 0 marks an app seed: no agent session wrote it
            # (``initial_sync._query_dry_run_keys`` does not read it as a Dry Run).
            ("session_id", _sql_bigint(APP_SEED_SESSION_ID)),
            ("processing_status", _sql_str("done")),
            ("completed_percent", _sql_double(100.0)),
            ("session_started_at", _sql_ts(now)),
            ("last_updated_at", _sql_ts(now)),
            ("session_json", _sql_str("{}")),
            ("results_json", _sql_str("{}")),
            ("deploy_status", _sql_str(DRY_RUN_STATUS)),
        ]
        cols_clause = ", ".join(f"`{c}`" for c, _ in bus_cols)
        vals_clause = ", ".join(v for _, v in bus_cols)
        bus_sql = (
            f"INSERT INTO `{catalog}`.`_metamodel`.`business` "
            f"({cols_clause}) VALUES ({vals_clause})"
        )
        _exec(ws, warehouse_id, bus_sql, budget)
        statement_count += 1
        summary["business"] = 1

        # 2-4. Collect domain / product / attribute rows, then emit each
        # table's rows as chunked multi-row INSERTs (see _insert_batched).
        # Column order is fixed per table so every row tuple aligns.
        domain_cols = [
            "business", "version", "model_scope", "domain", "division",
            "description", "database_name", "catalog", "reference", "tags",
        ]
        product_cols = [
            "business", "version", "model_scope", "domain", "subdomain",
            "product", "description", "type", "division", "function",
            "data_type", "source_domains", "association_edges", "primary_key",
            "reference", "table_name", "sample_path", "tags",
        ]
        attribute_cols = [
            "business", "version", "model_scope", "domain", "product",
            "attribute", "column_name", "type", "tags", "value_regex",
            "foreign_key_to", "business_glossary_term", "description",
            "reference",
        ]
        domain_rows: list[list[str]] = []
        product_rows: list[list[str]] = []
        attribute_rows: list[list[str]] = []

        domains = model.get("domains") or []
        for d in domains:
            if not isinstance(d, dict):
                continue
            d_name = d.get("name", "")
            domain_rows.append([
                _sql_str(agent_biz),
                _sql_str(version_str),
                _sql_str(scope_str),
                _sql_str(d_name),
                _sql_str(d.get("division", "")),
                _sql_str(d.get("description", "")),
                _sql_str(d.get("database_name", "")),
                _sql_str(catalog),
                _sql_str(d.get("references", "") or d.get("reference", "")),
                _sql_str(""),
            ])
            summary["domain"] += 1

            for p in d.get("products") or []:
                if not isinstance(p, dict):
                    continue
                p_name = p.get("name") or p.get("product") or ""
                product_rows.append([
                    _sql_str(agent_biz),
                    _sql_str(version_str),
                    _sql_str(scope_str),
                    _sql_str(d_name),
                    _sql_str(p.get("subdomain", "")),
                    _sql_str(p_name),
                    _sql_str(p.get("description", "")),
                    _sql_str(p.get("type", "")),
                    _sql_str(p.get("division", "")),
                    _sql_str(p.get("function", "")),
                    _sql_str(p.get("data_type", "")),
                    _sql_str(p.get("source_domains", "")),
                    _sql_str(p.get("association_edges", "")),
                    _sql_str(p.get("primary_key", "")),
                    _sql_str(p.get("references", "") or p.get("reference", "")),
                    _sql_str(p.get("table_name", "") or p_name),
                    _sql_str(p.get("sample_path", "")),
                    _sql_str(""),
                ])
                summary["product"] += 1

                for a in p.get("attributes") or []:
                    if not isinstance(a, dict):
                        continue
                    a_name = a.get("name") or a.get("attribute") or ""
                    attribute_rows.append([
                        _sql_str(agent_biz),
                        _sql_str(version_str),
                        _sql_str(scope_str),
                        _sql_str(d_name),
                        _sql_str(p_name),
                        _sql_str(a_name),
                        _sql_str(a.get("column_name", "") or a_name),
                        _sql_str(a.get("type", "")),
                        _sql_str(""),
                        _sql_str(a.get("value_regex", "")),
                        _sql_str(a.get("foreign_key_to", "")),
                        _sql_str(a.get("business_glossary_term", "")),
                        _sql_str(a.get("description", "")),
                        _sql_str(a.get("references", "") or a.get("reference", "")),
                    ])
                    summary["attribute"] += 1

        statement_count += _insert_batched(
            ws, warehouse_id,
            table=f"`{catalog}`.`_metamodel`.`domain`",
            columns=domain_cols, rows=domain_rows, chunk_size=chunk_size,
            budget=budget,
        )
        statement_count += _insert_batched(
            ws, warehouse_id,
            table=f"`{catalog}`.`_metamodel`.`product`",
            columns=product_cols, rows=product_rows, chunk_size=chunk_size,
            budget=budget,
        )
        statement_count += _insert_batched(
            ws, warehouse_id,
            table=f"`{catalog}`.`_metamodel`.`attribute`",
            columns=attribute_cols, rows=attribute_rows, chunk_size=chunk_size,
            budget=budget,
        )

        elapsed = time.monotonic() - started
        total_rows = (
            summary["business"] + summary["domain"] + summary["product"]
            + summary["attribute"]
        )
        logger.info(
            "import_metamodel_writer: wrote business=%d domain=%d product=%d attribute=%d "
            "for %s/%s/v%s in %s._metamodel (%d row(s), %d statement(s), %.1fs)",
            summary["business"], summary["domain"], summary["product"],
            summary["attribute"], agent_biz, scope_str, version_str, catalog,
            total_rows, statement_count, elapsed,
        )
    except Exception as e:
        logger.exception("import_metamodel_writer: failed (non-fatal)")
        summary["errors"].append(seed_error_text(e))
    return summary


def seed_metamodel_one(
    ws: WorkspaceClient,
    *,
    catalog: str,
    warehouse_id: str,
    model_json: dict,
    business_name: str,
    scope: str,
    version: int,
    log_prefix: str,
    wait_mode: WaitMode,
    location: Optional[str] = None,
) -> Optional[dict]:
    """Seed one version's ``_metamodel.*`` rows, non-fatal, with consistent
    logging. The single convergence point for EVERY iterable-version producer
    (import model.json, Volume-import, kickstart, download) so the seed
    contract can't drift between them.

    Callers own catalog/warehouse resolution and MUST have committed their
    Lakebase rows first: this targets an external SQL warehouse and must never
    be able to roll back the caller's transaction. Failure semantics (M1):

    - unconfigured catalog/warehouse -> INFO skip (a no-op, not a failure);
    - ``write_metamodel`` reports errors -> ERROR (a real, actionable failure,
      logged DISTINCT from the info skip so an operator can tell them apart);
    - statements left running (``wait_mode="request"`` only) -> WARNING naming
      their ids: the rows appear when the warehouse finishes them;
    - any unexpected exception -> EXCEPTION; never re-raised.

    Returns the ``write_metamodel`` summary dict (whose ``errors`` list a caller
    can inspect to decide its own status), or ``None`` on the unconfigured
    skip. Never raises. Most callers ignore the return; the kickstart
    background task uses it to fail the audit run on a real seed error.
    ``location`` is passed to :func:`write_metamodel`: every producer passes
    the version's folder in the app's Volume.
    """
    if not (catalog and warehouse_id):
        logger.info(
            "%s: skipping _metamodel seed - no deployment_catalog/warehouse configured",
            log_prefix,
        )
        return None
    try:
        summary = write_metamodel(
            ws,
            catalog=catalog,
            warehouse_id=warehouse_id,
            model_json=model_json,
            business_name=business_name,
            scope=scope,
            version=version,
            wait_mode=wait_mode,
            location=location,
        )
        if summary.get("still_running"):
            logger.warning(
                "%s: _metamodel seed for %s/%s v%s is still being written; the rows "
                "will appear when the warehouse finishes statement(s) %s",
                log_prefix, business_name, scope, version, summary["still_running"],
            )
        if summary.get("errors"):
            logger.error(
                "%s: _metamodel seed had errors for %s/%s v%s: %s",
                log_prefix, business_name, scope, version, summary["errors"],
            )
        return summary
    except Exception as exc:
        logger.exception(
            "%s: _metamodel seed failed for %s/%s v%s (non-fatal)",
            log_prefix, business_name, scope, version,
        )
        return {"business": 0, "domain": 0, "product": 0, "attribute": 0,
                "errors": [seed_error_text(exc)],
                "still_running": []}


def seed_error_text(exc: BaseException) -> str:
    """The stored text of a failed registry write. ``core._sql`` wraps a
    transport failure in ``SqlStatementError("ERROR")`` with the transport's
    text (it names the host), so the cause decides: a database or connection
    error gives ``recorded_error_text``'s fixed sentence and reference; any
    other error keeps ``str(exc)`` (a warehouse error stops before its
    ``== SQL ==`` echo)."""
    cause = exc.__cause__ if isinstance(exc, SqlStatementError) and exc.__cause__ is not None else exc
    if is_opaque_error(cause):
        return recorded_error_text(cause, "_metamodel seed")
    return recorded_error_text(exc, "_metamodel seed", fallback=str(exc))


def seed_warnings(summary: Optional[dict]) -> list[str]:
    """User-facing warnings for a :func:`seed_metamodel_one` result: a failed
    seed (the version can't be the base of a vibe run until its rows are in
    ``_metamodel``) and statements still being written. Empty for a clean
    seed or the unconfigured skip (``None``)."""
    if not summary:
        return []
    out: list[str] = []
    errors = [sanitize_error_message(str(e)) for e in summary.get("errors") or []]
    if errors:
        out.append(
            "Seeding the agent's registry (_metamodel) failed, so this version can't "
            "be the base of a vibe run yet: " + "; ".join(errors)
        )
    if summary.get("still_running"):
        out.append(
            "The agent's registry (_metamodel) rows for this version are still being "
            "written; they appear when the SQL warehouse finishes."
        )
    return out
