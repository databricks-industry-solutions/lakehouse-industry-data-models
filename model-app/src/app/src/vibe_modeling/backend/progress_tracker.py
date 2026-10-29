"""Progress tracker — per-run async polling for Delta tables and the
orchestrator's per-tick advance.

Reads session status and progress events from the agent's
``_metamodel.business`` / ``_vibe_progress`` Delta tables via the SQL
Statement Execution API and mirrors them into Lakebase
``run_progress_events`` rows for the UI.
"""

import asyncio
import contextvars
import json
import logging
import random
import time
from collections.abc import Iterable
from concurrent.futures import ThreadPoolExecutor
from dataclasses import dataclass
from datetime import datetime, timezone
from typing import Optional

from databricks.sdk import WorkspaceClient
from sqlmodel import Session, select

from .core import _sql, resolve_metamodel_catalog
from .core._config import AppConfig
from .core._metamodel_cleanups import sweep_metamodel_cleanups
from .core._time import as_utc
from .db_models import (
    AgentConfig,
    ModelVersion,
    Run,
    RunAgentReport,
    RunInputLink,
    RunOperation,
    RunProgressEvent,
    VibeInput,
)
from .error_sanitization import recorded_error_text, sanitize_error_message
from .job_launcher import session_id_to_bigint
from .run_report import OUTCOME_APPLIED, run_is_dry_run
from .services.operations._version_lifecycle import (
    promotion_of_run,
    queue_post_install_deletes,
    reopen_then_consume,
    run_post_install_deletes,
)
from .services.orchestrator import AdvanceOutcome, Orchestrator
from .subdomain_allocation_parser import (
    apply_subdomain_allocation,
    is_subdomain_allocation_event,
)
from .version_resolution_parser import (
    apply_version_resolution,
    is_version_resolution_event,
)


def resolve_session_id_bigint(
    run: Run,
    running_op: Optional[RunOperation],
) -> int:
    """Resolve the BIGINT session id the agent writes under in
    ``_vibe_progress`` / ``_business`` for a given run.

    Three sources, in priority order:

    1. ``Run.vibe_session_id_bigint`` — populated by the legacy
       (pre-orchestrator) dispatch path. Authoritative when set.
    2. ``running_op.vibe_session_id`` — the canonical UUID every
       dispatcher persists onto the active ``RunOperation``. The agent
       receives this UUID, hashes it via ``session_id_to_bigint``
       (SHA-256 truncation), and writes its Delta rows under that
       BIGINT. Deriving here uses the *same* deterministic helper, so
       no contract is required on the dispatcher beyond persisting the
       UUID — which both ``vibe_iterate.py`` and ``_generation_common.py``
       already do via ``_persist_run_id``.
    3. ``running_op.rollback_state_json["session_id_bigint"]`` — the
       prior orchestrator-era contract preserved here for back-compat
       with rows written before the UUID-derivation path landed.

    Returns 0 when no source can produce a value (e.g. between steps,
    or before any op has dispatched). Callers must treat 0 as "skip
    this tick, retry later" rather than as an error.
    """
    if run.vibe_session_id_bigint:
        return run.vibe_session_id_bigint
    if running_op is None:
        return 0
    if running_op.vibe_session_id:
        return session_id_to_bigint(running_op.vibe_session_id)
    if running_op.rollback_state_json:
        try:
            rs = json.loads(running_op.rollback_state_json)
        except Exception:
            return 0
        legacy = rs.get("session_id_bigint")
        if legacy:
            return int(legacy)
    return 0

logger = logging.getLogger(__name__)

_BOOTING_MESSAGE = "Booting agent — first events expected within ~2 min"


def _poll_error_note(exc: Exception, run: Run) -> str:
    """The user-facing ``last_poll_error`` for a failed read of the agent's
    tables, or ``""`` for a timeout before the first event: a stopped
    warehouse waking up reads as the agent booting, not as an error."""
    if isinstance(exc, _sql.SqlStatementError):
        if exc.state == "TIMEOUT" and not run.last_consumed_step_id:
            return ""
        return f"Could not read the agent's progress ({exc.state}): {exc.message}"
    return f"Could not read the agent's progress: {recorded_error_text(exc, 'Reading the agent progress')}"


# Each tick reads and writes the agent's tables with one 30 s server wait and
# no polls: the next tick asks again, and a statement still running at the end
# is cancelled and raises SqlStatementError("TIMEOUT").
_TICK_SQL_WAIT = "30s"

# Worker threads for advance ticks, owned by the tracker (never the shared
# default pool). A run holds at most one tick at a time (its tick lock), so
# this is how many runs can advance at once; more queue for a worker.
TICK_EXECUTOR_WORKERS = 8
# How long app shutdown waits for in-flight ticks before it moves on.
SHUTDOWN_TICK_WAIT_SECONDS = 5.0


async def _wait_through_cancels(futures: Iterable[asyncio.Future]) -> None:
    """Wait until every future is done, absorbing cancels of the caller.

    An advance tick's worker thread cannot be interrupted, so whoever holds
    the run's tick lock (or awaits the task that does) keeps waiting until
    the thread really ends; the caller re-raises its own cancel afterwards.
    Exceptions are marked retrieved so asyncio does not log them as lost.
    """
    futs = list(futures)
    pending = {f for f in futs if not f.done()}
    while pending:
        try:
            _, pending = await asyncio.wait(pending)
        except asyncio.CancelledError:
            pending = {f for f in pending if not f.done()}
    for f in futs:
        if not f.cancelled():
            f.exception()


def _finalize_run_inputs(run_id: str, session: Session, success: bool) -> None:
    """Finalize a terminated run's Vibe Inputs + legacy feedback in ONE commit.

    ``RunInputLink`` rows are written at launch as the *intended* set. Here:

    - **On success**, for the run's linked inputs (its ``RunInputLink`` rows),
      "consume" means ``consumed=true``, ``consumed_by_run_id=<run>`` and
      ``selected_for_run=false``. It reads the agent's report rows that
      ``run_report.persist_agent_report`` wrote when the vibe op finished:

      * a **Dry Run** (``run_report.run_is_dry_run``) consumes nothing; its
        links stay as the audit record and selection is left alone;
      * only inputs whose link has ``outcome_status="applied"`` are consumed
        (an input already consumed keeps its first consuming run and is
        deselected); every
        other status, ``not_reported`` or NULL stays open and selected;
      * a malformed ``input_outcomes``, no ``input_outcomes`` key, or no
        ``RunAgentReport`` at all (an older agent, a run without a
        ``vibe_iterate`` op, a run finished before reports existed) leaves
        every outcome NULL, so nothing is consumed (logged): without the
        agent's per-item outcomes no input is marked done.

      A model.json of the wrong version never reaches here: the vibe op
      fails on ``version_mismatch``.

      An install run that made its version current
      (``_version_lifecycle.promotion_of_run``) reopens the feedback of the
      versions it replaced and consumes what the installed version applied
      (``reopen_then_consume``), and queues the deletes the user asked for
      (``queue_post_install_deletes``; performed after this commit by
      :meth:`ProgressTracker._run_post_install_deletes`).
    - **On failure**: consume nothing and DELETE the run's ``RunInputLink``
      rows, so the selected inputs re-pool clean for the next attempt (the
      failed run never consumed them, so there is no usage to preserve).

    All mutations build, then ONE ``session.commit()`` at the end, together
    with the terminal run-status flip (``feedback_state_atomicity``). A
    successful run can still leave linked inputs with ``consumed=false``: the
    Dry Run, missing-outcomes and non-``applied`` cases above keep the link
    as the audit record and leave the input open and selected for the next
    run.

    Callers invoke this AFTER flushing (not committing) the run's terminal
    transition, so the run-status flip commits in this same transaction: a
    crash before the commit rolls the terminal transition back too, and the
    run is re-finalized on the next tick rather than stranded as
    success/consumed=false.
    """
    now = datetime.now(timezone.utc)

    # --- Vibe Inputs (new path) ---
    if success:
        input_links = session.exec(
            select(RunInputLink).where(RunInputLink.run_id == run_id)
        ).all()
        if input_links and not run_is_dry_run(session, session.get(Run, run_id)):
            _log_unreported_outcomes(session, run_id, len(input_links))
            applied_ids = [
                link.input_id for link in input_links
                if link.outcome_status == OUTCOME_APPLIED
            ]
            inputs = session.exec(
                select(VibeInput).where(VibeInput.id.in_(applied_ids))
            ).all() if applied_ids else []
            for vi in inputs:
                # Clear the run-selection flag in the SAME commit as consumed,
                # so a consumed input never silently re-enters the next run's
                # selected set (selection is moot once consumed). An input
                # consumed earlier (the manual consume route keeps its
                # selection) keeps its first consuming run but is deselected.
                if not vi.consumed:
                    vi.consumed = True
                    vi.consumed_by_run_id = run_id
                elif not vi.selected_for_run:
                    continue
                vi.selected_for_run = False
                vi.updated_at = now
                session.add(vi)
        promotion = promotion_of_run(session, run_id)
        if promotion is not None:
            reopen_then_consume(session, run_id, promotion)
            queue_post_install_deletes(session, run_id, promotion)
    else:
        # A failed run consumed nothing: delete its RunInputLink rows (the
        # per-run attempt record). ``VibeInput.selected_for_run`` is left
        # untouched on purpose — it is the user's durable selection, so the
        # Compose surface stays checked and the next run re-links the same
        # inputs without the user reselecting. Selection clears only on a
        # successful consume (above) or an explicit user unselect.
        stale_links = session.exec(
            select(RunInputLink).where(RunInputLink.run_id == run_id)
        ).all()
        for link in stale_links:
            session.delete(link)

    session.commit()


def _log_unreported_outcomes(session: Session, run_id: str, n_links: int) -> None:
    """Log why a successful run's linked inputs carry no agent outcomes."""
    report = session.get(RunAgentReport, run_id)
    if report is None:
        reason = "recorded no agent report"
    elif report.outcomes_malformed:
        reason = "agent input_outcomes is malformed"
    elif not report.has_input_outcomes:
        reason = "the agent reported no input_outcomes"
    else:
        return
    logger.warning(
        "run %s: %s; consuming no inputs (%d linked input(s) stay open and "
        "selected)", run_id, reason, n_links,
    )


def _log_boot_sweep_failure(future: asyncio.Future) -> None:
    """Log a boot sweep that raised outside its own handling (e.g. no
    session could be opened); the future is never awaited."""
    if not future.cancelled() and future.exception() is not None:
        logger.error("boot sweep failed (post-install deletes, metamodel cleanups)", exc_info=future.exception())


@dataclass
class SessionStatus:
    """Parsed row from _metamodel._business."""
    session_id: int
    processing_status: str
    completed_percent: float
    last_updated_at: Optional[str] = None
    results_json: Optional[dict] = None
    completion_date: Optional[str] = None
    business: str = ""
    version: str = ""
    model_scope: str = ""


@dataclass
class ProgressEvent:
    """Parsed row from _metamodel._vibe_progress."""
    step_id: int
    event_seq: Optional[int] = None
    stage_name: str = ""
    step_name: str = ""
    status: str = ""
    message: str = ""
    progress_increment: float = 0.0
    result_json: Optional[dict] = None


# How long with no updates before marking as stale (UI hint only).
# D-09 (plan task #51) bumped 10 → 20: long-running install / sync steps
# legitimately go quiet for >10 min on cold catalogs, and users were
# repeatedly seeing the "stale" banner on healthy runs. The watchdog still
# fires on real terminal-not-success states regardless of this hint.
STALE_THRESHOLD_MINUTES = 20

# Grace period before the Jobs-API watchdog may mark a model-producing run
# failed purely from the Databricks run state. Agents legitimately take
# 30-60 s to boot and emit their first `_vibe_progress` row; a tighter
# window would race the cluster warm-up. Once the agent has emitted any
# event (`last_consumed_step_id > 0`), the watchdog is active regardless
# of elapsed time so mid-flight failures surface promptly.
#
# D-09 (plan task #51) bumped 90 → 180: serverless cold starts on a test workspace
# routinely take 2+ minutes before the agent emits its first row, and the
# tighter window was occasionally clipping legitimate boots when the
# Jobs API briefly reported a transient TERMINATED/INTERNAL_ERROR pair
# during init.
WATCHDOG_WARM_UP_SECONDS = 180


from .core._names import escape_sql_literal as _esc
from .core._paths import version_dir_candidates


def index_artifacts_for_version(
    ws,
    run: "Run",
    mv: "ModelVersion",
    session: "Session",
    catalog: str,
    business_name: str,
    output_v: int,
    scope_short: str,
) -> None:
    """Index Volume artifacts the agent wrote for ``mv`` as ``RunArtifact`` rows.

    Path convention (agent 4.9.8+, nested):
      ``/Volumes/{catalog}/_metamodel/vol_root/business/{sanitized_biz}/v{N}/{scope}/``

    Delegates to :func:`services.artifact_indexer.index_artifacts_at_path`
    (the canonical indexer). This shim composes the agent's Volume folder
    layout and calls through, probing the nested root first and falling back
    to the legacy flat ``{scope}_v{N}`` root for pre-upgrade rows. The import
    path calls the lower-level helper directly with its own ``volume_root_path``.
    """
    if not ws or not catalog or not scope_short:
        return
    from .services.artifact_indexer import index_artifacts_at_path
    for root in version_dir_candidates(catalog, business_name, output_v, scope_short):
        if index_artifacts_at_path(
            ws, session,
            run_id=run.id,
            model_version_id=mv.id,
            volume_root_path=root,
        ):
            return


# Maps raw agent status strings to a stable app-side enum that downstream
# code (poll loop, UI) can rely on. Centralising the vocabulary here means
# agent-side renames only require updating this one table rather than
# chasing hardcoded strings through the stack. Unknown values are logged
# and passed through verbatim so the UI still has something to render.
_STATUS_NORMALIZATION: dict[str, str] = {
    # Agent-side vocabulary (current as of agent v27)
    "stage_started": "running",
    "stage_in_progress": "running",
    "stage_succeeded": "completed",
    "stage_ended": "completed",
    "stage_failed": "failed",
    "stage_skipped": "skipped",
    "stage_warning": "warning",
    "skipped": "skipped",
    "warning": "warning",
    # Legacy vocabulary still seen in older progress rows
    "running": "running",
    "in_progress": "running",
    "completed": "completed",
    "done": "completed",
    "failed": "failed",
    "error": "failed",
}

_unknown_status_warned: set[str] = set()


def _normalize_status(raw: str) -> str:
    """Map a raw agent status onto the stable {running, completed, failed,
    skipped} enum. Unknown values are logged once per process and returned
    unchanged so the UI can still render them (as an empty circle)."""
    if not raw:
        return ""
    mapped = _STATUS_NORMALIZATION.get(raw)
    if mapped is not None:
        return mapped
    if raw not in _unknown_status_warned:
        _unknown_status_warned.add(raw)
        logger.warning(
            "Unknown agent progress status %r — passing through verbatim. "
            "Update _STATUS_NORMALIZATION in progress_tracker.py if the "
            "agent has introduced a new vocabulary.",
            raw,
        )
    return raw


class ProgressTracker:
    """Manages per-run async polling tasks."""

    def __init__(self, ws: WorkspaceClient, config: AppConfig, session_factory):
        self._ws = ws
        self._config = config
        self._session_factory = session_factory
        self._tasks: dict[str, asyncio.Task] = {}
        # Per-run lock: a run's drain and advance ticks never interleave.
        self._tick_locks: dict[str, asyncio.Lock] = {}
        self._tick_executor = ThreadPoolExecutor(
            max_workers=TICK_EXECUTOR_WORKERS, thread_name_prefix="tracker-tick"
        )
        # The startup sweep of post-install deletes (resume_running_runs).
        self._boot_sweep: Optional[asyncio.Future] = None
        self._loop: asyncio.AbstractEventLoop | None = None
        # The orchestrator owns every run's lifecycle. The tracker holds
        # the singleton so route handlers can borrow it via
        # ``tracker.orchestrator``.
        self.orchestrator = Orchestrator(
            ws, session_factory, progress_drain=self._sync_orch_progress_events,
        )

    def _resolve_warehouse_id(self) -> str:
        """Read AgentConfig.warehouse_id, lazily seeded from env on first read.

        The route layer's get-or-create helper has typically already
        bootstrapped the row before any tracker work runs, so the lookup
        is a plain DB read in the steady state. We still fall back to the
        env-var config if the row genuinely doesn't exist (defensive: the
        tracker can be invoked from a worker thread that didn't pass
        through a route handler).
        """
        with self._session_factory() as session:
            cfg = session.exec(select(AgentConfig).limit(1)).first()
            if cfg is not None:
                return cfg.warehouse_id
            return self._config.warehouse_id

    # ------------------------------------------------------------------
    # Delta table SQL methods (formerly DeltaPoller)
    # ------------------------------------------------------------------

    def _query(self, sql: str) -> Optional[list[list]]:
        """Rows of a read on the agent's tables, ``None`` when the table does
        not exist yet. Any other failure raises ``SqlStatementError``."""
        return _sql.rows(
            self._ws, self._resolve_warehouse_id(), sql,
            wait_timeout=_TICK_SQL_WAIT, missing_table="none",
        )

    def _write(self, sql: str) -> None:
        """A write on ``_metamodel.business``; every failure raises
        ``SqlStatementError``, a missing table included."""
        _sql.run(self._ws, self._resolve_warehouse_id(), sql, wait_timeout=_TICK_SQL_WAIT)

    def _poll_session_status(
        self,
        catalog: str,
        business_name: str,
        version: str,
        model_scope: str,
    ) -> Optional[SessionStatus]:
        """Query _business table for the session row. Returns None if table or row doesn't exist."""
        sql = (
            f"SELECT session_id, processing_status, completed_percent, "
            f"CAST(last_updated_at AS STRING) as last_updated_at, "
            f"results_json, "
            f"CAST(completion_date AS STRING) as completion_date, "
            f"business, version, model_scope "
            f"FROM `{catalog}`.`_metamodel`.`business` "
            f"WHERE LOWER(business) = LOWER('{_esc(business_name)}') AND version = '{_esc(version)}' "
            f"AND model_scope = '{_esc(model_scope)}' "
            f"ORDER BY session_id DESC LIMIT 1"
        )
        found = self._query(sql)
        if not found or not found[0]:
            return None

        row = found[0]
        results = None
        if row[4]:
            try:
                results = json.loads(row[4])
            except (json.JSONDecodeError, TypeError):
                results = {"raw": row[4]}

        return SessionStatus(
            session_id=int(row[0]) if row[0] else 0,
            processing_status=row[1] or "",
            completed_percent=float(row[2]) if row[2] else 0.0,
            last_updated_at=row[3],
            results_json=results,
            completion_date=row[5],
            business=row[6] or "",
            version=row[7] or "",
            model_scope=row[8] or "",
        )

    def _poll_session_status_by_id(
        self,
        catalog: str,
        session_id_bigint: int,
    ) -> Optional[SessionStatus]:
        """Query _business by session_id directly."""
        sql = (
            f"SELECT session_id, processing_status, completed_percent, "
            f"CAST(last_updated_at AS STRING) as last_updated_at, "
            f"results_json, "
            f"CAST(completion_date AS STRING) as completion_date, "
            f"business, version, model_scope "
            f"FROM `{catalog}`.`_metamodel`.`business` "
            f"WHERE session_id = {session_id_bigint} "
            f"LIMIT 1"
        )
        found = self._query(sql)
        if not found or not found[0]:
            return None

        row = found[0]
        results = None
        if row[4]:
            try:
                results = json.loads(row[4])
            except (json.JSONDecodeError, TypeError):
                results = {"raw": row[4]}

        return SessionStatus(
            session_id=int(row[0]) if row[0] else 0,
            processing_status=row[1] or "",
            completed_percent=float(row[2]) if row[2] else 0.0,
            last_updated_at=row[3],
            results_json=results,
            completion_date=row[5],
            business=row[6] or "",
            version=row[7] or "",
            model_scope=row[8] or "",
        )

    def _poll_progress_events(
        self,
        catalog: str,
        session_id_bigint: int,
        last_event_seq: int = 0,
    ) -> list[ProgressEvent]:
        """Query _vibe_progress for new events after ``last_event_seq``.

        The cursor is on ``event_seq`` (monotonic per session, unique per
        event) — NOT ``step_id`` (which is the step's millisecond-epoch
        creation timestamp and can repeat across multiple events of the
        same step, e.g. ``stage_started`` → ``stage_warning`` →
        ``stage_succeeded`` for one ``Applying Metric Views`` step). A
        ``step_id`` high-water-mark cursor silently drops the later
        events for a step once the cursor has advanced past it.

        For backward compatibility the persisted column on ``Run`` is
        still named ``last_consumed_step_id``; it now stores the highest
        ``event_seq`` consumed. A future migration will rename the
        column to match the semantic.
        """
        sql = (
            f"SELECT step_id, event_seq, stage_name, step_name, status, message, "
            f"progress_increment, CAST(result_json AS STRING) as result_json "
            f"FROM `{catalog}`.`_metamodel`.`_vibe_progress` "
            f"WHERE session_id = {session_id_bigint} AND event_seq > {last_event_seq} "
            f"ORDER BY event_seq ASC"
        )
        found = self._query(sql)
        if not found:
            return []

        events = []
        for row in found:
            rj = None
            if row[7]:
                try:
                    rj = json.loads(row[7])
                except (json.JSONDecodeError, TypeError):
                    rj = {"raw": row[7]}

            events.append(ProgressEvent(
                step_id=int(row[0]) if row[0] else 0,
                event_seq=int(row[1]) if row[1] else None,
                stage_name=row[2] or "",
                step_name=row[3] or "",
                status=_normalize_status(row[4] or ""),
                message=row[5] or "",
                progress_increment=float(row[6]) if row[6] else 0.0,
                result_json=rj,
            ))
        return events

    def _acknowledge_batch(
        self,
        catalog: str,
        session_id_bigint: int,
        business_name: str = "",
        version: str = "",
        model_scope: str = "",
    ) -> None:
        """Set processing_status='done' to acknowledge the handshake.

        Per the Integration Guide, the WHERE clause must include all identity columns.
        """
        where_parts = [f"session_id = {session_id_bigint}"]
        if business_name:
            where_parts.append(f"LOWER(business) = LOWER('{_esc(business_name)}')")
        if version:
            where_parts.append(f"version = '{_esc(version)}'")
        if model_scope:
            where_parts.append(f"model_scope = '{_esc(model_scope)}'")

        sql = (
            f"UPDATE `{catalog}`.`_metamodel`.`business` "
            f"SET processing_status = 'done' "
            f"WHERE {' AND '.join(where_parts)}"
        )
        self._write(sql)

    def _finalize_session_completion(
        self,
        catalog: str,
        session_id_bigint: int,
        business_name: str = "",
        version: str = "",
        model_scope: str = "",
    ) -> None:
        """Force ``completed_percent=100`` and ``completion_date`` for a
        session whose terminal "Session Ended" event has fired.

        Background: the agent's `Applying Metric Views` stage can fire a
        ``stage_warning`` (e.g. 7 of 22 metric views fail to compile because
        the LLM hallucinated columns that don't exist on the underlying
        tables) and continue to a successful Session Ended event, but it
        leaves ``_metamodel.business.completed_percent`` at the partial
        value (observed: 99.0). Downstream agent operations (shrink,
        enlarge, vibe-iterate) then refuse via ``_version_is_incomplete()``
        which strictly checks ``< 100``.

        The model is functionally complete at Session Ended — every
        downstream-relevant artifact (model.json, schemas, FKs,
        attributes) has been produced. The percent counter is a UI
        artifact that should not gate downstream operations once the
        agent has emitted its terminal event.

        This patch is conditional on ``completed_percent < 100`` (a
        no-op when the agent already wrote 100), so it cannot regress
        the normal happy path. It always stamps ``completion_date``.

        Stays until the upstream agent writes 100 itself on this path.
        """
        where_parts = [f"session_id = {session_id_bigint}", "completed_percent < 100"]
        if business_name:
            where_parts.append(f"LOWER(business) = LOWER('{_esc(business_name)}')")
        if version:
            where_parts.append(f"version = '{_esc(version)}'")
        if model_scope:
            where_parts.append(f"model_scope = '{_esc(model_scope)}'")

        sql = (
            f"UPDATE `{catalog}`.`_metamodel`.`business` "
            f"SET completed_percent = 100.0, "
            f"    completion_date = current_timestamp() "
            f"WHERE {' AND '.join(where_parts)}"
        )
        # Retry on `DELTA_CONCURRENT_APPEND.ROW_LEVEL_CHANGES` only —
        # this UPDATE races with the agent's own row-level appends to
        # ``_metamodel.business`` from sibling sessions. Other SQL
        # errors (auth, syntax, table-not-found) are not transient and
        # should propagate immediately so the catch site can mark
        # ``sync_state='finalize_failed'``.
        backoff_ms = (200, 400, 800)
        last_exc: Optional[Exception] = None
        # Up to 3 retries (= 4 total attempts) before giving up.
        for attempt in range(len(backoff_ms) + 1):
            try:
                self._write(sql)
                return
            except Exception as exc:
                msg = str(exc)
                if "DELTA_CONCURRENT_APPEND.ROW_LEVEL_CHANGES" not in msg:
                    raise
                last_exc = exc
                if attempt >= len(backoff_ms):
                    # No retries left — surface the last exception so the
                    # caller marks sync_state='finalize_failed'.
                    raise
                # Sleep with ±50ms jitter to avoid lockstep retries when
                # multiple runs hit the same partition simultaneously.
                base_ms = backoff_ms[attempt]
                jitter_ms = random.randint(-50, 50)
                time.sleep(max(0.0, (base_ms + jitter_ms) / 1000.0))
        # Defensive: loop always returns or raises above.
        if last_exc is not None:
            raise last_exc

    # ------------------------------------------------------------------
    # Task management
    # ------------------------------------------------------------------

    def start_tracking(self, run_id: str) -> None:
        """Spawn a background asyncio task to track a run.

        Works from both async contexts (lifespan) and sync contexts
        (threadpool route handlers) by caching the event loop reference.

        PLAN #53 — captures the current ``contextvars.Context`` so the
        per-request correlation id (and any future request-scoped vars)
        is preserved inside the spawned poll loop. Without this, every
        log line emitted by the tracker for an in-flight run would have
        an empty ``request_id`` because the loop runs on a fresh task
        whose context inherits from the loop's startup, not the caller.
        """
        # Skip only while the existing loop is alive. A poll loop that ended
        # (terminal state, cancel) leaves its done task in ``_tasks``; a
        # Retry on the same run must replace it, or the run is never polled.
        existing = self._tasks.get(run_id)
        if existing is not None and not existing.done():
            return
        loop = self._loop or asyncio.get_event_loop()
        # `loop.create_task(coro, context=ctx)` is the asyncio-native way
        # to attach a context snapshot to a task. Falls back to plain
        # create_task on Python < 3.11 just in case.
        from .core._request_id import copy_context_for_task

        ctx = copy_context_for_task()
        try:
            task = loop.create_task(self._poll_loop(run_id), context=ctx)
        except TypeError:
            task = loop.create_task(self._poll_loop(run_id))
        self._tasks[run_id] = task

    def stop_tracking(self, run_id: str) -> None:
        """Cancel tracking for a run (user-initiated cancel only)."""
        task = self._tasks.pop(run_id, None)
        if task and not task.done():
            task.cancel()

    async def shutdown(self, wait_seconds: float = SHUTDOWN_TICK_WAIT_SECONDS) -> None:
        """Stop tracking every run and shut the tick executor down.

        Waits up to ``wait_seconds`` for in-flight ticks to finish (a tick
        cannot be interrupted), then stops the executor without waiting:
        queued ticks are cancelled, a running one ends on its own SQL/HTTP
        timeout.
        """
        tasks = [t for t in self._tasks.values() if not t.done()]
        for run_id in self.get_active_runs():
            self.stop_tracking(run_id)
        if tasks:
            _, still_running = await asyncio.wait(tasks, timeout=wait_seconds)
            if still_running:
                logger.warning(
                    f"ProgressTracker shutdown: {len(still_running)} tick(s) "
                    f"still running after {wait_seconds}s"
                )
        self._tick_executor.shutdown(wait=False, cancel_futures=True)

    def get_active_runs(self) -> list[str]:
        """Return IDs of runs currently being tracked."""
        return [rid for rid, t in self._tasks.items() if not t.done()]

    async def _drain_tick(self, run_id: str) -> bool:
        """Cheap drain-only tick: mirror ``_vibe_progress`` rows into
        Lakebase and commit. Returns ``True`` only when the run row is
        gone or no longer in a tracked state — never makes terminal-state
        decisions, those belong to ``_advance_tick``.

        Runs on the fast (``drain_interval_seconds``) loop so new agent
        events surface in the UI within seconds of being written to Delta,
        independent of how long the advance tick is taking (it waits only
        while the same run's advance tick holds the run's tick lock).
        """
        async with self._tick_lock(run_id):
            with self._session_factory() as session:
                run = session.get(Run, run_id)
                if not run:
                    return True
                if run.status not in ("running", "pending", "stale"):
                    return True
                try:
                    self._sync_orch_progress_events(run, session)
                except Exception:
                    logger.exception(
                        f"Failed to sync orchestrator progress events for run {run_id}"
                    )
                session.commit()
                return False

    def _tick_lock(self, run_id: str) -> asyncio.Lock:
        return self._tick_locks.setdefault(run_id, asyncio.Lock())

    async def _advance_tick(self, run_id: str) -> bool:
        """Slow tick: Jobs API check + ``orchestrator.advance`` +
        handshake ack + terminal handling. Returns ``True`` if the loop
        should exit (run reached terminal).

        This is the path that pays cold-warehouse SQL latency and the
        Jobs API roundtrip. By keeping it on its own cadence, a 60–80s
        tick here does not delay event mirroring.

        The body blocks (Jobs API, warehouse SQL, an install dispatch's
        bounded ``model.json`` read), so it runs on the tracker's own
        bounded executor (``_tick_executor``) and the event loop is not
        held by it. (The drain tick still runs its SQL on the loop.) The
        session is opened in the worker thread; contextvars (request ids)
        are copied in. The run's tick lock keeps the tick from
        interleaving with the same run's drain tick, and it is held until
        the thread ends, however often the tick is cancelled.
        """
        async with self._tick_lock(run_id):
            ctx = contextvars.copy_context()
            tick = asyncio.get_running_loop().run_in_executor(
                self._tick_executor, lambda: ctx.run(self._advance_tick_sync, run_id)
            )
            try:
                return await asyncio.shield(tick)
            except asyncio.CancelledError:
                # A thread cannot be interrupted. Let the tick finish, as it
                # always did on the loop, before releasing the lock.
                await _wait_through_cancels([tick])
                if not tick.cancelled() and tick.exception() is not None:
                    logger.error(
                        f"Advance tick for run {run_id} failed during cancel",
                        exc_info=tick.exception(),
                    )
                raise

    def _advance_tick_sync(self, run_id: str) -> bool:
        """The blocking body of :meth:`_advance_tick`."""
        with self._session_factory() as session:
            run = session.get(Run, run_id)
            if not run:
                return True
            if run.status not in ("running", "pending", "stale"):
                return True

            # Bug C fallback: if the running op's underlying Databricks job
            # has flipped to TERMINATED-not-success before any progress
            # events were emitted (observed 2026-04-27 on run 273d137e —
            # Phase 2 shrink_to_mvm failed at ``step_setup_and_clean`` with
            # 0 events drained, leaving the op stuck at ``status=running``
            # for 6+ minutes until the watchdog tripped), force-fail the
            # row here so ``advance()`` immediately routes through
            # ``TERMINAL_FAILED`` instead of waiting on the watchdog.
            try:
                self._fail_op_if_jobs_api_terminal(run, session)
            except Exception:
                logger.exception(
                    f"Jobs API fallback check failed for run {run_id}"
                )

            outcome = self.orchestrator.advance(run, session)
            if outcome in (
                AdvanceOutcome.TERMINAL_SUCCESS,
                AdvanceOutcome.TERMINAL_FAILED,
            ):
                # ``advance`` flushed (not committed) the terminal transition.
                # ``_finalize_run_inputs`` commits — so the run-status flip, the
                # consume-flip + RunInputLink confirm, and the legacy feedback
                # flip all land in ONE transaction (feedback_state_atomicity).
                # No try/except swallow on this path: a crash here must roll
                # back the terminal commit so the run is re-finalized on the
                # next tick rather than stranded as success/consumed=false.
                _finalize_run_inputs(
                    run_id, session,
                    success=outcome == AdvanceOutcome.TERMINAL_SUCCESS,
                )
                if outcome == AdvanceOutcome.TERMINAL_SUCCESS:
                    self._run_post_install_deletes(session, run_id)
                return True
            session.commit()
            return False

    def _run_post_install_deletes(self, session: Session, run_id: Optional[str]) -> None:
        """Perform the post-install deletes queued by ``run_id`` (all pending
        rows when None, the boot sweep), after the install's terminal commit.
        A failure is recorded on its row and logged; it never changes the
        install's result."""
        try:
            run_post_install_deletes(
                session, self._ws, self._resolve_warehouse_id(),
                run_id=run_id, recheck=run_id is None,
                discard_change_feedback=self._config.run_change_review_enabled,
            )
        except Exception:
            session.rollback()
            logger.exception("post-install deletes failed (run %s)", run_id or "boot sweep")

    def _sweep_post_install_deletes(self) -> None:
        """The boot sweep: leftover post-install deletes, then one more
        attempt at every unfinished ``_metamodel`` cleanup below its attempt
        limit (``core._metamodel_cleanups.sweep_metamodel_cleanups``)."""
        with self._session_factory() as session:
            self._run_post_install_deletes(session, None)
            try:
                sweep_metamodel_cleanups(session, self._ws, self._resolve_warehouse_id())
            except Exception:
                session.rollback()
                logger.exception("metamodel cleanup boot sweep failed")

    def _fail_op_if_jobs_api_terminal(self, run: Run, session: Session) -> None:
        """Bug C safety net for the orchestrator path.

        When a Databricks job for an in-flight ``RunOperation`` reaches
        ``TERMINATED`` with a non-SUCCESS result (or hits
        ``INTERNAL_ERROR`` / ``SKIPPED``) BEFORE the agent emits any
        ``_vibe_progress`` events, the orchestrator's primitive-level
        ``observe()`` is the only thing that should detect it. In
        practice (run 273d137e on 2026-04-27, ``shrink_to_mvm`` failed
        at ``step_setup_and_clean``) the row stayed ``running`` for
        minutes after the job had already TERMINATED/FAILED — the agent
        never got far enough to write ``_business``/``_vibe_progress``
        rows, so ``_sync_orch_progress_events`` had nothing to drain,
        and the legacy watchdog (D-09) was the only thing that
        eventually flipped it.

        Poll the Jobs API directly for the running op's
        ``databricks_run_id`` and force-fail the row if it has reached a
        terminal-not-success state. ``advance()`` (which runs immediately
        after) will then observe the ``failed`` row and route through
        ``TERMINAL_FAILED``, triggering rollback over priors.

        Best-effort: any exception is allowed to bubble up to
        ``_advance_tick`` which catches and logs it. Jobs API
        intermittency must NOT mark the row failed — only an
        authoritative TERMINATED/<not-SUCCESS> response does.
        """
        running_op = session.exec(
            select(RunOperation)
            .where(RunOperation.run_id == run.id)
            .where(RunOperation.status == "running")
            .order_by(RunOperation.step_index)
        ).first()
        if running_op is None or not running_op.databricks_run_id:
            return

        try:
            job_run = self._ws.jobs.get_run(running_op.databricks_run_id)
        except Exception:
            # Jobs API unavailable — leave the row alone; the next tick
            # will retry. The orchestrator's primitive observe() may
            # also pick this up.
            return

        state = getattr(job_run, "state", None)
        lcs_obj = getattr(state, "life_cycle_state", None) if state else None
        rs_obj = getattr(state, "result_state", None) if state else None
        lcs_raw = getattr(lcs_obj, "value", "") if lcs_obj else ""
        rs_raw = getattr(rs_obj, "value", "") if rs_obj else ""
        lcs = lcs_raw if isinstance(lcs_raw, str) else ""
        rs = rs_raw if isinstance(rs_raw, str) else ""

        #   * INTERNAL_ERROR / SKIPPED → terminal failure regardless of rs
        #   * TERMINATED + result_state in {FAILED, TIMEDOUT, CANCELED, ...}
        #     → terminal failure
        #   * TERMINATED + SUCCESS → leave row alone; observe() will run
        #     the model.json verification and only then declare success.
        terminal_failure = lcs in ("INTERNAL_ERROR", "SKIPPED") or (
            lcs == "TERMINATED" and bool(rs) and rs != "SUCCESS"
        )
        if not terminal_failure:
            return

        reason = self._compose_job_failure_message(job_run, lcs, rs)

        # Mark the row failed and route through the orchestrator's
        # rollback chain so any prior succeeded ops get cleaned up
        # atomically with the Run terminal transition. This mirrors
        # what ``_advance_running`` does on a terminal-failure obs.
        running_op.status = "failed"
        running_op.error_message = reason
        running_op.completed_at = datetime.now(timezone.utc)
        session.add(running_op)
        logger.warning(
            "Bug C fallback: forced run=%s op=%s to failed (job %s lcs=%s rs=%s)",
            run.id, running_op.operation_name, running_op.databricks_run_id, lcs, rs,
        )
        # ``_initiate_rollback`` owns the atomic Run + RunOperation
        # transition via ``transition_run`` — no half-failed state.
        # ``_advance_tick`` will fire ``_finalize_run_inputs`` once
        # ``advance()`` reports ``TERMINAL_FAILED``; don't double-fire it
        # here.
        self.orchestrator._initiate_rollback(run, running_op, session)

    def _sync_orch_progress_events(self, run: Run, session: Session) -> None:
        """Mirror agent ``_vibe_progress`` events into Lakebase + update
        ``run.progress_percent``/``run.progress_message`` for an
        orchestrator-routed run. Idempotent: events are filtered by
        ``step_id > run.last_consumed_step_id`` so re-runs of this method
        within a single tick are no-ops once the batch has been written.

        Only runs for model-producing ops (the agent only writes a
        ``_vibe_progress`` session row for ``generate_ecm`` /
        ``shrink_to_mvm`` / ``enlarge_to_ecm`` / ``vibe_iterate``). For
        lifecycle ops (install / uninstall / samples) the agent doesn't
        emit per-step events; the Jobs API state is the only signal and
        the orchestrator owns that path itself.
        """
        # Resolve the currently-running op and gate on whether it produces
        # a version (matches the agent contract: lifecycle ops don't write
        # `_vibe_progress` rows).
        running_op = session.exec(
            select(RunOperation)
            .where(RunOperation.run_id == run.id)
            .where(RunOperation.status == "running")
            .order_by(RunOperation.step_index)
        ).first()
        if running_op is None:
            return
        try:
            from .services.operations import get as _ops_get
            op = _ops_get(running_op.operation_name)
        except KeyError:
            return
        if not op.produces_version:
            return
        params = json.loads(run.parameters_json) if run.parameters_json else {}
        # The agent writes its ``_metamodel`` schema (host of ``_vibe_progress``
        # events, the model artifacts / ``vol_root`` Volume, and the deployed
        # schemas) to the catalog THIS run was dispatched with — the run's
        # ``deployment_catalog``. The launch path sets that via
        # ``resolve_run_target_catalog`` (explicit form catalog, else the
        # configured metamodel catalog), so a user-picked catalog can differ
        # from the installation metamodel catalog. Read it from the run's
        # params here so progress events AND the completion/model-sync (which
        # reuse this ``catalog``) read from where the agent actually wrote.
        # Fall back to the installation metamodel catalog for runs whose params
        # omit it (legacy / synthesized test runs without the field).
        catalog = (params.get("deployment_catalog") or params.get("catalog") or "").strip()
        if not catalog:
            # Legacy / synthesized runs whose params omit the catalog: fall
            # back to the installation metamodel catalog (concern A).
            catalog = resolve_metamodel_catalog(session)
        if not catalog:
            return

        # Single source of truth for session_id resolution: see the
        # ``resolve_session_id_bigint`` helper at module scope. Returns 0
        # between steps or before any op has dispatched, in which case
        # we skip and retry on the next tick.
        sid_bigint = resolve_session_id_bigint(run, running_op)
        if not sid_bigint:
            return

        # 1) Drain step events FIRST, regardless of session-status row.
        #    The agent writes events to ``_vibe_progress`` as it boots
        #    but the ``_business`` session row may not appear until later
        #    in the run (seen in a vibe-iterate run on a test workspace: 73 events written
        #    to Delta, 0 in Lakebase, run failed because we early-returned
        #    on ``status is None`` and never drained). The producer/
        #    consumer contract is by step_id ordering, not session
        #    presence — reading partial sequences is safe because we
        #    cursor on ``step_id > run.last_consumed_step_id``.
        try:
            events = self._poll_progress_events(
                catalog, sid_bigint, run.last_consumed_step_id
            )
            saw_session_ended = False
            for ev in events:
                pe = RunProgressEvent(
                    run_id=run.id,
                    step_id=ev.step_id,
                    event_seq=ev.event_seq,
                    stage_name=ev.stage_name,
                    step_name=ev.step_name,
                    status=ev.status,
                    message=ev.message,
                    progress_increment=ev.progress_increment,
                    result_json=json.dumps(ev.result_json) if ev.result_json else "{}",
                )
                session.add(pe)
                # Cursor advance is on ``event_seq`` (unique per event),
                # NOT ``step_id`` (which can repeat across events of the
                # same step). The persisted column on ``Run`` is named
                # ``last_consumed_step_id`` for backward compatibility
                # but stores the event_seq high-water-mark. See
                # ``_poll_progress_events`` for the full rationale.
                if ev.event_seq is not None and ev.event_seq > run.last_consumed_step_id:
                    run.last_consumed_step_id = ev.event_seq
                # Detect the agent's terminal-success event so we can
                # repair a sub-100 ``completed_percent`` left by partial
                # metric-view compile failures (see
                # ``_finalize_session_completion`` for context).
                if (
                    ev.stage_name == "Vibe Session"
                    and ev.step_name == "Session Ended"
                ):
                    saw_session_ended = True

                # Parse the agent's "Version Collision Auto-Resolved"
                # event and re-stamp the ModelVersion (if it exists) +
                # any RunArtifact paths to match the agent's chosen
                # ordinal. See ``version_resolution_parser`` for the
                # full contract and atomicity story. The RunProgressEvent
                # row above is the durable record consulted later at
                # observe-time when the MV row hasn't been created yet.
                if is_version_resolution_event(
                    ev.stage_name, ev.step_name, ev.result_json,
                ):
                    apply_version_resolution(session, run, ev)
                    # If the parser tripped a fail-fast (mv.version
                    # doesn't match original_target), transition_run
                    # has already set run.status='failed' on the
                    # session-attached row; stop draining further
                    # events on this tick.
                    if run.status == "failed":
                        break

                # Parse the agent's "Subdomain Allocation" stage_succeeded
                # event and backfill Product.subdomain on each matching
                # row. Idempotent — ModelSyncService also hydrates the
                # same field from model.json on observe; whichever runs
                # first wins (they should agree).
                if is_subdomain_allocation_event(
                    ev.stage_name, ev.status, ev.result_json,
                ):
                    apply_subdomain_allocation(session, run, ev)
            if events:
                session.add(run)
            if saw_session_ended:
                try:
                    # We don't have business/version/scope at this exact
                    # spot; the next status-row read will validate via the
                    # full identity columns. Patch by session_id alone —
                    # session_id is unique across runs.
                    self._finalize_session_completion(catalog, sid_bigint)
                except Exception as exc:
                    # Mark the run's ModelVersion (if any) so the version
                    # detail page can render an "incomplete metadata"
                    # banner. Without this, _finalize_session_completion
                    # raising left the version stuck at percent=99 with
                    # no user-visible signal — only a stack trace in the
                    # app log.
                    try:
                        if run.version_id:
                            mv = session.get(ModelVersion, run.version_id)
                            # Don't downgrade an earlier mark — if
                            # `_terminal_success` already set
                            # `incomplete_metadata`, that's the more
                            # informative state and finalize_failed would
                            # mask it. Only stamp on virgin rows.
                            if mv is not None and mv.sync_state == "ok":
                                mv.sync_state = "finalize_failed"
                                mv.sync_error_text = recorded_error_text(
                                    exc, f"Finalizing version {mv.id}", str(exc)[:500])
                                session.add(mv)
                                session.commit()
                    except Exception:
                        logger.exception(
                            "Failed to mark sync_state=finalize_failed for run %s",
                            run.id,
                        )
                    logger.exception(
                        f"Error finalizing session completion for run {run.id}"
                    )
        except Exception as e:
            # The cursor stays where it was, so the next tick reads these
            # events again; the failure shows on the run's watchdog signal.
            drain_error = _poll_error_note(e, run)
            logger.exception(
                f"Error draining orchestrator progress events for run {run.id}"
            )
        else:
            drain_error = ""

        # 2) Read session-status row (per-stage % + processing_status).
        try:
            status = self._poll_session_status_by_id(
                catalog, sid_bigint
            )
        except Exception as e:
            note = drain_error or _poll_error_note(e, run)
            if note:
                self._record_poll_signals(
                    run, session, jobs_api_state=None, poll_error=note,
                )
            elif run.progress_message != _BOOTING_MESSAGE:
                run.progress_message = _BOOTING_MESSAGE
                session.add(run)
            return

        # Successful poll: clear any sticky error from a prior tick so the
        # UI's "watchdog signal" banner doesn't lie about a recovered
        # transient. _record_poll_signals only writes when the value
        # actually changes, so this is a no-op when the field was empty.
        if drain_error:
            self._record_poll_signals(
                run, session, jobs_api_state=None, poll_error=drain_error,
            )
        elif run.last_poll_error:
            self._record_poll_signals(
                run, session, jobs_api_state=None, poll_error="",
            )

        if status is None:
            # Agent hasn't written its session row yet. Set a baseline
            # message + 1% dispatch-ack bar — but the events drained
            # above are already in Lakebase for the UI's progress feed.
            waiting = _BOOTING_MESSAGE
            changed = False
            if run.progress_message != waiting:
                run.progress_message = waiting
                changed = True
            if not run.progress_percent:
                run.progress_percent = 1  # dispatch ack only
                changed = True
            if changed:
                session.add(run)
            return

        # 2) Update run.progress_percent / run.progress_message.
        #
        # Vocabulary (user-facing, 2026-04-26): a Run has Phases (DAG
        # nodes — RunOperation rows like generate_ecm), each Phase has
        # Steps (agent stages — RunProgressEvent groups like "Designing
        # Domains"). The bar reflects user-visible progress, NOT
        # orchestrator dispatch state.
        #
        # The bar is strictly event-driven:
        #   bar = sum(slice for completed Phases)
        #       + (agent_pct_for_running_phase / 100) × slice
        # AND it stays at ≤1% (a small dispatch-ack sliver) until at
        # least one RunProgressEvent has been persisted for this run.
        # That guarantees the user never sees the bar advance past
        # "we got it" until events are visibly streaming in the panel.
        ops = session.exec(
            select(RunOperation)
            .where(RunOperation.run_id == run.id)
            .order_by(RunOperation.step_index)
        ).all()
        total = max(len(ops), 1)
        completed_or_skipped = sum(
            1 for o in ops if o.status in ("succeeded", "skipped")
        )
        running_phase = next(
            (o for o in ops if o.status in ("running", "pending")), None
        )
        slice_pct = 100.0 / total
        floor = completed_or_skipped * slice_pct
        agent_pct = max(0.0, min(100.0, float(status.completed_percent)))
        running_contribution = (
            slice_pct * (agent_pct / 100.0) if running_phase else 0.0
        )

        # Gate: ≤1% until events have actually landed in Lakebase.
        # Without this, the agent's session-row `completed_percent` can
        # update the bar before the events panel shows anything, which
        # erodes user trust ("bar at 25% but the events list is empty").
        events_drained = session.exec(
            select(RunProgressEvent.id)
            .where(RunProgressEvent.run_id == run.id)
            .limit(1)
        ).first()
        if events_drained is None:
            overall_pct = 1  # dispatch ack — "we got it, agent booting"
        else:
            overall_pct = int(round(floor + running_contribution))

        # Never let the bar go backwards.
        if run.progress_percent and overall_pct < run.progress_percent:
            overall_pct = run.progress_percent
        # Cap at 99 until the run is terminal (orchestrator owns 100%).
        if overall_pct > 99 and run.status not in (
            "completed", "succeeded", "failed", "cancelled",
            "rolled_back", "rolled_back_failed",
        ):
            overall_pct = 99
        run.progress_percent = overall_pct

        ps = (status.processing_status or "").lower()
        if ps == "pending":
            user_state = "Queued"
        elif ps in ("done", "ready"):
            user_state = "Running"
        else:
            user_state = status.processing_status or "Running"
        # User vocabulary: outer level is "Phase", not "step".
        phase_label = (
            f"Phase {running_phase.step_index + 1}/{total}"
            if running_phase is not None
            else f"Phase {total}/{total}"
        )
        if events_drained is None:
            run.progress_message = _BOOTING_MESSAGE
        else:
            run.progress_message = (
                f"{user_state} — {phase_label}, {status.completed_percent:.0f}%"
            )
        session.add(run)

        # 3) Acknowledge the handshake batch when the agent says it's
        #    ``ready``. (Step events are already drained in step 1, so
        #    we no longer gate on processing_status here for that — the
        #    only purpose of this branch is the ack.)
        if status.processing_status == "ready":
            try:
                self._acknowledge_batch(
                    catalog, sid_bigint,
                    business_name=status.business,
                    version=status.version,
                    model_scope=status.model_scope,
                )
            except Exception:
                logger.exception(
                    f"Error acknowledging handshake batch for run {run.id}"
                )

    async def resume_running_runs(self) -> None:
        """On app startup, resume tracking for any runs still in running/stale status."""
        # Cache the event loop so start_tracking works from sync threadpool contexts
        self._loop = asyncio.get_running_loop()
        # Phase 3 #52 — collapse the diagram prefetch runtime onto the
        # tracker / orchestrator's event loop. The pool was previously
        # a separate ThreadPoolExecutor; it is now an async scheduler
        # that routes work through this loop's default executor.
        try:
            from .diagram import attach_prefetch_loop
            attach_prefetch_loop(self._loop)
        except Exception:
            logger.exception("Failed to attach prefetch scheduler to event loop")
        try:
            with self._session_factory() as session:
                runs = session.exec(
                    select(Run).where(Run.status.in_(["running", "stale"]))
                ).all()
                for run in runs:
                    self.start_tracking(run.id)
            if runs:
                logger.info(f"Resumed tracking for {len(runs)} running runs")
            # Post-install deletes queued by an install that finished before
            # a restart: performed now, or recorded not_run when the version
            # changed since; then the unfinished _metamodel cleanups.
            # Scheduled on the tick executor and not awaited: each calls the
            # warehouse, and app startup must not wait.
            self._boot_sweep = self._loop.run_in_executor(
                self._tick_executor, self._sweep_post_install_deletes,
            )
            self._boot_sweep.add_done_callback(_log_boot_sweep_failure)
        except Exception as e:
            # Don't crash the lifespan on a SELECT failure (e.g., migration
            # silently skipped a column the model now references). Log loud,
            # skip resume — the app comes up; in-flight runs can be recovered
            # via the UI on the next poll cycle.
            logger.error(
                f"resume_running_runs failed; skipping in-flight resume so app can serve: {e!r}"
            )

    async def _poll_loop(self, run_id: str) -> None:
        """Top-level polling loop for a single run.

        Spawns two child loops on independent cadences:

          * ``_drain_loop_inner`` — every ``drain_interval_seconds`` (5s
            by default), cheap SELECT against ``_vibe_progress`` plus
            inserts into ``run_progress_events``. Surfaces agent events
            in the UI within seconds, regardless of how long the advance
            tick is taking.
          * ``_advance_loop_inner`` — every ``poll_interval_seconds`` (10s
            by default), pays cold-warehouse latency for Jobs API +
            ``orchestrator.advance`` + handshake ack. This is also the
            loop that decides terminal state.

        Drift-unification (Phase 7, Item 3): this is the only
        multi-cadence "fast drain + slow advance" poll loop in the
        codebase. The other polling sites are single-cadence:

          * ``install/provision_lakebase.py`` — single 5s sync poll
            for endpoint host assignment.
          * ``services/operations/vibe_iterate.py`` /
            ``_generation_common.py`` — exponential-backoff retry on
            ``ws.files.download`` failure, not a status poll.
          * UI ``components/diagram/diagram-viewer.tsx`` — single 2s
            client-side poll for 200/202 layout-compute status.

        None of them have a fast/slow pair, so there's nothing to
        unify into a shared ``cooperative_split_poll`` helper. If a
        second multi-cadence site appears, extract this loop's
        ``_run_split_loops`` + child-loop scaffolding into a generic
        helper and migrate both sites at once.

        When either child returns (run reached terminal, or the Run row
        is gone), the other is cancelled and ``_poll_loop`` exits.

        Retries transient errors at the outer level so a flaky tick
        doesn't kill tracking on the first hiccup. When retries are
        exhausted, ``_handle_watchdog_exit`` decides whether to fail the
        run based on the *Databricks job state* — if the underlying job
        is still running we mark it ``stale`` and let the next app
        startup resume tracking.
        """
        max_retries = 5  # was 3 — long agent runs see more transient dips
        base_wait = self._config.poll_interval_seconds
        try:
            for attempt in range(max_retries + 1):
                try:
                    await self._run_split_loops(run_id)
                    return
                except asyncio.CancelledError:
                    logger.info(f"Tracking cancelled for run {run_id}")
                    return
                except Exception:
                    if attempt < max_retries:
                        # Capped exponential backoff: 10s, 20s, 40s, 80s, 120s
                        wait = min(base_wait * (2 ** attempt), 120)
                        logger.exception(
                            f"Poll loop error for run {run_id} "
                            f"(attempt {attempt + 1}/{max_retries}), retrying in {wait}s"
                        )
                        await asyncio.sleep(wait)
                    else:
                        logger.exception(
                            f"Poll loop exhausted retries for run {run_id} "
                            f"after {max_retries} attempts"
                        )
                        self._handle_watchdog_exit(run_id)
        finally:
            # Drop the run's lock only if no newer poll loop has taken over
            # the run (stop then resume) and nothing holds it.
            owner = self._tasks.get(run_id)
            lock = self._tick_locks.get(run_id)
            if (
                owner in (None, asyncio.current_task())
                and lock is not None
                and not lock.locked()
            ):
                self._tick_locks.pop(run_id, None)

    async def _run_split_loops(self, run_id: str) -> None:
        """Run the drain and advance loops concurrently. Returns when
        either signals exit (terminal state or Run row gone). The other
        loop is cancelled so we never leak tasks."""
        drain_task = asyncio.create_task(self._drain_loop_inner(run_id))
        advance_task = asyncio.create_task(self._advance_loop_inner(run_id))
        try:
            done, pending = await asyncio.wait(
                {drain_task, advance_task},
                return_when=asyncio.FIRST_COMPLETED,
            )
            for t in pending:
                t.cancel()
                try:
                    await t
                except (asyncio.CancelledError, Exception):
                    pass
            # Re-raise non-cancellation exceptions so the outer retry
            # path can decide how to handle them.
            for t in done:
                exc = t.exception()
                if exc is not None and not isinstance(exc, asyncio.CancelledError):
                    raise exc
        except asyncio.CancelledError:
            for t in (drain_task, advance_task):
                if not t.done():
                    t.cancel()
            # The advance child holds the run's tick lock until its worker
            # thread ends. Wait for both children so the loop never exits
            # (and a resumed loop never starts a second tick) while it runs.
            await _wait_through_cancels([drain_task, advance_task])
            raise

    async def _drain_loop_inner(self, run_id: str) -> None:
        """Fast loop: drain agent events into Lakebase. Exits when the
        Run row is gone or no longer in a tracked state."""
        while True:
            if await self._drain_tick(run_id):
                return
            await asyncio.sleep(self._config.drain_interval_seconds)

    async def _advance_loop_inner(self, run_id: str) -> None:
        """Slow loop: Jobs API check + orchestrator advance + ack +
        terminal handling. Owns terminal-state decisions."""
        while True:
            if await self._advance_tick(run_id):
                return
            await asyncio.sleep(self._config.poll_interval_seconds)

    def _handle_watchdog_exit(self, run_id: str) -> None:
        """Called when the poll loop has exhausted its retries.

        The prior behaviour unconditionally marked the run as failed, which
        stole model sync from the app whenever there was a transient spike
        of SQL/Lakebase errors even though the underlying Databricks job was
        still running fine. Check the job state first: if the job is still
        running, mark the run `stale` so the UI flags it and leave the run
        available for `resume_running_runs` to pick back up on the next app
        start. Only declare the run failed if the Databricks job itself has
        ended without success.
        """
        try:
            job_run = None
            with self._session_factory() as session:
                run = session.get(Run, run_id)
                if not run:
                    return
                if run.databricks_run_id:
                    try:
                        job_run = self._ws.jobs.get_run(run.databricks_run_id)
                    except Exception:
                        logger.exception(
                            f"Watchdog couldn't read Jobs API for run {run_id}"
                        )

                lcs = (
                    job_run.state.life_cycle_state.value
                    if job_run and job_run.state and job_run.state.life_cycle_state
                    else ""
                )
                rs = (
                    job_run.state.result_state.value
                    if job_run and job_run.state and job_run.state.result_state
                    else ""
                )
                job_still_running = lcs in ("PENDING", "QUEUED", "RUNNING", "BLOCKED", "WAITING_FOR_RETRY")
                job_terminal_not_success = lcs in ("TERMINATED", "INTERNAL_ERROR", "SKIPPED") and rs != "SUCCESS"

                if job_still_running and run.status in ("running", "stale", "pending"):
                    run.status = "stale"
                    run.progress_message = (
                        f"Tracker paused after repeated errors (Databricks job "
                        f"state: {lcs}). The run will resume on next app restart."
                    )
                    session.add(run)
                    session.commit()
                    logger.warning(
                        f"Watchdog: run {run_id} marked stale; job {lcs}"
                    )
                elif job_terminal_not_success and run.status in ("running", "stale", "pending"):
                    from .run_state_transitions import transition_run
                    reason = (
                        job_run.state.state_message
                        or f"Databricks job ended with {lcs}/{rs}"
                    )
                    run.error_message = reason
                    session.add(run)
                    transition_run(session, run, target_status="failed", reason=reason)
                    # ``transition_run`` flushed (not committed); finalize
                    # commits — failed-status flip + (no-op) finalize land in
                    # one transaction (feedback_state_atomicity).
                    _finalize_run_inputs(run.id, session, success=False)
                else:
                    # Unknown job state or app run already in a terminal state —
                    # leave the run alone, just log.
                    logger.warning(
                        f"Watchdog: run {run_id} status={run.status} job_lcs={lcs}/{rs} — "
                        f"no status change"
                    )
        except Exception:
            logger.exception(f"Watchdog handler crashed for run {run_id}")
        finally:
            # Only drop our own entry: a stop + restart from a threadpool
            # route may have registered a new loop for this run meanwhile.
            if self._tasks.get(run_id) is asyncio.current_task():
                self._tasks.pop(run_id, None)

    def _job_lifecycle(self, run: Run) -> tuple[str, str]:
        """Fetch the Databricks job's (life_cycle_state, result_state) pair.
        Returns ("", "") if there's no job id yet, the Jobs API call fails,
        or the SDK response doesn't carry string enum values — callers should
        treat that as "not yet terminated" and keep polling. The string-type
        check matters in tests where `ws` is a MagicMock: without it,
        attribute accesses would return nested mocks and callers would
        misinterpret them as concrete state values."""
        if not run.databricks_run_id:
            return ("", "")
        try:
            job_run = self._ws.jobs.get_run(run.databricks_run_id)
        except Exception:
            return ("", "")
        state = job_run.state if job_run else None
        lcs_raw = state.life_cycle_state.value if state and state.life_cycle_state else ""
        rs_raw = state.result_state.value if state and state.result_state else ""
        lcs = lcs_raw if isinstance(lcs_raw, str) else ""
        rs = rs_raw if isinstance(rs_raw, str) else ""
        return (lcs, rs)

    def _record_poll_signals(
        self,
        run: Run,
        session: Session,
        *,
        jobs_api_state: Optional[str],
        poll_error: Optional[str],
    ) -> None:
        """Set watchdog signals on a Run row and add it to ``session``.
        Never commits: the caller owns the transaction, and the final drain
        runs inside the model-sync savepoint, where a commit would close it.

        - `jobs_api_state`: pass `None` to leave the field unchanged (e.g.
          when the Jobs API call itself failed); pass a string (possibly
          empty) to overwrite.
        - `poll_error`: same convention. Pass "" to clear after a successful
          poll.
        """
        try:
            changed = False
            if jobs_api_state is not None and run.last_jobs_api_state != jobs_api_state:
                run.last_jobs_api_state = jobs_api_state
                changed = True
            if poll_error is not None and run.last_poll_error != poll_error:
                run.last_poll_error = poll_error
                changed = True
            if changed:
                session.add(run)
        except Exception:
            logger.exception(
                f"Failed to record watchdog signals for run {run.id}"
            )

    def _watchdog_armed(self, run: Run) -> bool:
        """Watchdog is armed once either the agent has emitted any progress
        event OR the warm-up window has elapsed since `started_at`."""
        if run.last_consumed_step_id and run.last_consumed_step_id > 0:
            return True
        started = run.started_at or run.created_at
        if started is None:
            return True
        now = datetime.now(timezone.utc)
        return (now - as_utc(started)).total_seconds() >= WATCHDOG_WARM_UP_SECONDS

    def _compose_job_failure_message(self, job_run, lcs: str, rs: str) -> str:
        """Join job-level state_message with any task-level state_messages so
        the UI surfaces the actual cause (e.g. early_clash_detection trace)
        rather than just the outer 'INTERNAL_ERROR' wrapper."""
        parts: list[str] = []
        state = job_run.state if job_run else None
        top_raw = state.state_message if state and state.state_message else ""
        top = top_raw if isinstance(top_raw, str) else ""
        if top:
            parts.append(top)

        tasks = getattr(job_run, "tasks", None)
        if isinstance(tasks, list):
            for task in tasks:
                ts = getattr(task, "state", None)
                if not ts:
                    continue
                t_rs_obj = getattr(ts, "result_state", None)
                t_rs_val = t_rs_obj.value if t_rs_obj else ""
                t_rs = t_rs_val if isinstance(t_rs_val, str) else ""
                t_msg_raw = getattr(ts, "state_message", "") or ""
                t_msg = t_msg_raw if isinstance(t_msg_raw, str) else ""
                if t_rs and t_rs != "SUCCESS" and t_msg and t_msg not in parts:
                    task_key_raw = getattr(task, "task_key", "") or ""
                    task_key = task_key_raw if isinstance(task_key_raw, str) else ""
                    parts.append(f"[{task_key}] {t_msg}" if task_key else t_msg)

        if parts:
            return " | ".join(parts)
        return f"{lcs}/{rs}".strip("/") or "job ended without success"

