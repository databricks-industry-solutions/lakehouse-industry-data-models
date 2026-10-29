"""Atomic run-state transition helper.

ALL terminal state changes for a Run — cancel, fail, succeed, rolled_back —
MUST go through :func:`transition_run`.  No other code is allowed to write
to ``Run.status``, ``Run.completed_at``, ``Run.progress_message``, or
``RunOperation.status`` for terminal statuses directly.

Intent
------
The cancel endpoint historically flipped ``Run.status`` to ``"cancelled"``
but left every other layer untouched:

* ``RunOperation`` rows stayed ``"running"`` / ``"pending"``
* ``Run.progress_message`` kept the stale ``"[generate_ecm] …RUNNING…"`` text
* ``Run.completed_at`` was not set  →  elapsed timer kept ticking
* The Databricks job kept running (no cancel API call)

This helper closes all five gaps in a single call that the caller commits.

All terminal writes route through ``transition_run``.  The
``"running"`` / ``"stale"`` non-terminal writes stay in-place (they are
progress updates, not terminal transitions).
"""

from __future__ import annotations

import logging
from datetime import datetime, timezone
from typing import Any, Literal

from sqlmodel import Session, select

from .core._runs import OPEN_OPERATION_STATUSES
from .db_models import Run, RunOperation, RunProgressEvent

logger = logging.getLogger(__name__)


# Run.status values that are terminal (no further transitions allowed).
# "stale" is intentionally NOT here — the watchdog can promote stale → failed.
_TERMINAL_RUN_STATUSES: frozenset[str] = frozenset({
    "cancelled",
    "failed",
    "completed",
    "rolled_back",
    "rolled_back_failed",
})

# Map from target Run status → terminal status for an in-flight RunOperation.
# NOTE: Run uses "completed" for success; RunOperation uses "succeeded".
_OP_TERMINAL_FOR_TARGET: dict[str, str] = {
    "cancelled": "cancelled",
    "failed": "failed",
    "completed": "succeeded",   # Run.completed → RunOperation.succeeded
    "rolled_back": "rolled_back",
    "rolled_back_failed": "rolled_back",
}

# The "pending" ops get a softer terminal status when the run is cancelled.
_OP_PENDING_TERMINAL: dict[str, str] = {
    "cancelled": "cancelled",
    "failed": "skipped",
    "completed": "succeeded",   # all ops done; pending ones succeeded too
    "rolled_back": "rolled_back",
    "rolled_back_failed": "skipped",
}

TerminalStatus = Literal[
    "cancelled",
    "failed",
    "completed",       # Run-level success (Run.status = "completed")
    "rolled_back",
    "rolled_back_failed",
]


def transition_run(
    session: Session,
    run: Run,
    *,
    target_status: TerminalStatus,
    reason: str = "",
    ws: Any = None,
) -> Run:
    """Atomically transition a Run and all dependent state to a terminal status.

    Layers updated (in order):
    1. ``Run.status`` → ``target_status``
    2. ``Run.completed_at`` → now (always; these are all terminal)
    3. Every ``RunOperation`` with status in {pending, running} →
       target-aware terminal:
       - ``cancelled``          → running ops cancelled, pending ops cancelled
       - ``failed``             → running op failed, pending ops skipped
       - ``succeeded``          → assert no in-flight ops (caller bug if any)
       - ``rolled_back``        → running op rolled_back, pending ops skipped
       - ``rolled_back_failed`` → running op rolled_back, pending ops skipped
    4. ``Run.progress_message`` → target-aware human-readable string.
       NEVER leaves a stale "RUNNING …" message.
    5. Best-effort Databricks job cancel (only when ``target_status`` is
       ``"cancelled"`` or ``"rolled_back_failed"``).

    Parameters
    ----------
    session:
        Open SQLModel session. Caller is responsible for ``session.commit()``
        after this call returns.
    run:
        The ``Run`` instance to transition (mutated in place).
    target_status:
        One of the terminal values above.
    reason:
        Optional human-readable cause (surfaces in the progress message for
        ``failed`` / ``rolled_back_failed``).
    ws:
        Databricks ``WorkspaceClient`` (or ``None``).  When provided and the
        run has a ``databricks_run_id``, a best-effort ``jobs.cancel_run``
        is issued for cancellation targets.

    Returns
    -------
    The same ``Run`` instance, mutated.  Caller commits.

    Wiring audit
    ------------
    **Intent**: single authoritative place for all terminal Run transitions.

    **Previous wiring**: each caller (router cancel handler, orchestrator
    rollback path, tracker watchdog) wrote ``run.status`` / ``run.completed_at``
    directly and left RunOperation rows and ``progress_message`` untouched.

    **New wiring**: callers call ``transition_run``; no direct ``run.status =``
    assignment for terminal statuses anywhere except this function.

    **Info-flow delta**:
    + RunOperation rows now always reach a terminal status when the Run does.
    + ``run.progress_message`` is always overwritten with a non-RUNNING string.
    + ``run.completed_at`` is always stamped on terminal (was sometimes missing).
    + Best-effort Databricks cancel is attempted for cancel targets.
    - No new callers introduced; all existing callers rerouted here.

    **Dead-end check**: ``run.progress_message`` was the only field that could
    become stale (RUNNING after cancel). This is now closed. No columns are
    left unused; no new columns are introduced.
    """
    # --- 0: idempotency guard -------------------------------------------
    # Some completion flows can pass through transition_run twice on the
    # same uncommitted session. When the run is ALREADY in the same
    # terminal status, treat the second call as a no-op — don't rewrite
    # progress_message / completed_at / RunOperation statuses again,
    # don't re-call ws.jobs.cancel_run. When the second call disagrees
    # on the target, log a warning and respect
    # the prior terminal (the first call wins; later mismatches are bugs
    # in the caller chain). This also protects retry loops that may
    # observe a terminal run after another tracker tick already finalized.
    if run.status in _TERMINAL_RUN_STATUSES:
        if run.status == target_status:
            logger.debug(
                "transition_run no-op: run %s already %s",
                run.id, target_status,
            )
            return run
        logger.warning(
            "transition_run idempotency guard: run %s already in terminal "
            "status %r; refusing to overwrite with target_status=%r. "
            "First terminal write wins (caller chain bug).",
            run.id, run.status, target_status,
        )
        return run

    if target_status == "completed":
        # Sanity check: caller should not invoke this for the success path
        # while there are still in-flight ops (that is the orchestrator's job).
        rows = _load_ops(session, run.id)
        in_flight = [r for r in rows if r.status in OPEN_OPERATION_STATUSES]
        if in_flight:
            names = ", ".join(r.operation_name for r in in_flight)
            raise ValueError(
                f"transition_run called with target_status='completed' but "
                f"RunOperation rows are still in-flight: {names}. "
                "Use Orchestrator._finalize_run_success() instead."
            )

    now = datetime.now(timezone.utc)

    # --- 1 + 2: stamp the run -------------------------------------------
    run.status = target_status
    run.completed_at = now
    session.add(run)

    # --- 3: stamp in-flight RunOperation rows ----------------------------
    rows = _load_ops(session, run.id)
    running_op: RunOperation | None = None
    for row in rows:
        if row.status == "running":
            running_op = row
            row.status = _OP_TERMINAL_FOR_TARGET[target_status]
            row.completed_at = now
            session.add(row)
        elif row.status == "pending":
            row.status = _OP_PENDING_TERMINAL[target_status]
            row.completed_at = now
            session.add(row)

    # --- 4: build a non-stale progress message ---------------------------
    run.progress_message = _build_progress_message(
        run, target_status, reason, running_op, rows, session
    )
    session.add(run)

    # --- 5: best-effort Databricks job cancel ----------------------------
    dbx_suffix = ""
    if target_status in ("cancelled", "rolled_back_failed"):
        dbx_run_id = _resolve_dbx_run_id(run, running_op)
        if dbx_run_id and ws is not None:
            try:
                ws.jobs.cancel_run(dbx_run_id)
                dbx_suffix = " — Databricks job cancelled"
                logger.info(
                    "transition_run: cancelled Databricks run_id=%d for run=%s",
                    dbx_run_id, run.id,
                )
            except Exception as e:  # noqa: BLE001 — best-effort, must not abort
                short = repr(e)[:120]
                dbx_suffix = f" — Databricks job cancel failed ({short}); output discarded"
                logger.warning(
                    "transition_run: jobs.cancel_run(%d) failed for run=%s: %r",
                    dbx_run_id, run.id, e,
                )

    if dbx_suffix:
        run.progress_message += dbx_suffix
        session.add(run)

    return run


# ---------------------------------------------------------------------------
# Internals
# ---------------------------------------------------------------------------

def _load_ops(session: Session, run_id: str) -> list[RunOperation]:
    """Load all RunOperation rows for ``run_id`` ordered by step_index."""
    return list(
        session.exec(
            select(RunOperation)
            .where(RunOperation.run_id == run_id)
            .order_by(RunOperation.step_index)
        ).all()
    )


def _resolve_dbx_run_id(run: Run, running_op: RunOperation | None) -> int | None:
    """Return the Databricks run_id to cancel.

    Prefer the running op's run_id (orchestrator path) over the legacy
    ``run.databricks_run_id`` field.
    """
    if running_op is not None and running_op.databricks_run_id:
        return running_op.databricks_run_id
    return run.databricks_run_id


def _build_progress_message(
    run: Run,
    target_status: TerminalStatus,
    reason: str,
    running_op: RunOperation | None,
    rows: list[RunOperation],
    session: Session,
) -> str:
    """Compose a human-readable terminal progress message.

    For cancellation we surface how far the run got: the phase index and
    the last-seen step name from the most recent RunProgressEvent.
    For failure we surface the reason.
    """
    total = len(rows)

    # How many phases had completed before the terminal event?
    completed = sum(
        1 for r in rows if r.status in ("succeeded", "skipped", "rolled_back")
    )
    # Which phase was running? (1-indexed for display)
    if running_op is not None:
        current_phase = running_op.step_index + 1
        op_name = running_op.operation_name
    else:
        # No running op — we were between dispatches or at start.
        current_phase = completed + 1
        op_name = ""

    # Fetch the most recent progress event for the running op.
    last_step = _last_progress_step(session, run.id, running_op)

    if target_status == "cancelled":
        phase_info = f"Phase {current_phase}/{total}" if total > 0 else "Phase ?/?"
        step_info = f" (last seen: {last_step})" if last_step else ""
        base = f"Cancelled at {phase_info}{step_info}"
        # Mirror the `completed` branch: when the caller supplies a reason
        # (e.g. cancel_run_with_rollback passes ``reason="with rollback"``),
        # surface it after the base message so the user sees:
        #   "Cancelled at Phase 1/2 (last seen: …) — with rollback"
        # Otherwise keep the base unchanged.
        return f"{base} — {reason}" if reason else base

    if target_status in ("rolled_back", "rolled_back_failed"):
        phase_info = f"Phase {current_phase}/{total}" if total > 0 else "Phase ?/?"
        suffix = f" — {reason}" if reason else ""
        return f"Rolled back at {phase_info}{suffix}"

    if target_status == "failed":
        # Find the op that actually failed and surface ITS step_index, not
        # the highest-step-index "completed" tally. When op[0] fails and the
        # orchestrator marks op[1+] skipped before calling transition_run,
        # neither op is "running" anymore so the running_op-based current_phase
        # fallback (completed + 1) drifts to N/N. The user sees "Failed at
        # Phase 2/2" when reality is op[0] (Phase 1) failed.
        failed_op = next(
            (r for r in rows if r.status == "failed"),
            None,
        )
        if failed_op is not None:
            current_phase = failed_op.step_index + 1
        phase_info = f"Phase {current_phase}/{total}" if total > 0 else "Phase ?/?"
        suffix = f" — {reason}" if reason else ""
        return f"Failed at {phase_info}{suffix}"

    if target_status == "completed":
        return reason or "Run complete"

    return f"Run ended: {target_status}"


def _last_progress_step(
    session: Session,
    run_id: str,
    running_op: RunOperation | None,
) -> str:
    """Return the most recent progress event's step_name (or stage_name) for display.

    Picks from all events on this run; for single-op runs this is fine.
    For multi-op runs the running_op context is available but we don't
    have an op-level FK on RunProgressEvent yet, so we use the global
    most-recent event which is still the right one (events are sequential).
    """
    try:
        event = session.exec(
            select(RunProgressEvent)
            .where(RunProgressEvent.run_id == run_id)
            .order_by(RunProgressEvent.step_id.desc())
            .limit(1)
        ).first()
    except Exception:  # noqa: BLE001 — non-critical; swallow to avoid aborting cancel
        return ""

    if event is None:
        return ""
    return event.step_name or event.stage_name or ""
