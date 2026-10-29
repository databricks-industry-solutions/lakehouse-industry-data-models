"""Orchestrator runner — DAG walker that drives Runs through their
primitive sequence.

See ``docs/orchestrator-design.md`` §4 (interface), §6 (failure
semantics), §7 (rollback stack).

The :class:`Orchestrator` is the sole driver of Run lifecycles. Each run
is a linear list of :class:`RunOperation` rows persisted from the
:class:`Dag` at start time; the orchestrator advances them one-by-one by
calling each :class:`Operation`'s ``dispatch`` / ``observe`` /
``rollback`` methods.

This module is deliberately small: every interesting bit of logic
(widget construction, polling, rollback semantics) lives on the
:class:`Operation` implementation. The orchestrator just sequences
them.
"""

from __future__ import annotations

import json
import logging
from contextlib import contextmanager
from dataclasses import dataclass, field
from datetime import datetime, timezone
from enum import Enum
from typing import Any, Callable, Iterator, Optional

from pydantic import ValidationError
from sqlmodel import Session, select

from .. import operations as _operations_pkg
from ..operations import (
    OperationContext,
    OperationDispatchHandle,
    OperationObservation,
)
from ..operations._protocol import Operation
from ...core._json import json_object
from ...db_models import ModelVersion, Run, RunOperation
from ...error_sanitization import recorded_error_text, sanitize_error_message
from .dag import Dag, OperationStep


def _registry_get_default(name: str) -> Operation:
    """Look up an operation in the registry by name.

    This indirection through the package attribute (rather than a
    module-level alias bound at import time) ensures that test-time
    monkeypatches to ``services.operations.get`` are honoured by the
    orchestrator. Tests use
    ``unittest.mock.patch('vibe_modeling.backend.services.operations.get', ...)``
    to swap in a fake registry; binding ``registry_get_default = get``
    at import time would freeze the original reference and bypass the
    patch (the ``patched_registry_full`` fixture comment in
    ``tests/test_app/test_orchestrator_runner.py`` calls this out
    explicitly).
    """
    return _operations_pkg.get(name)

logger = logging.getLogger(__name__)


# Statuses that count as "the op has done some work that may need
# undoing" (rollback candidates). Anything in
# ``("pending", "skipped", "rolled_back")`` is left alone.
_ROLLBACK_CANDIDATE_STATUSES: frozenset[str] = frozenset({"succeeded", "running"})


class AdvanceOutcome(Enum):
    """Result of a single :meth:`Orchestrator.advance` tick.

    The poll loop interprets this to decide whether to keep polling
    (``CONTINUE`` / ``ADVANCED``) or stop (``TERMINAL_*``).
    """

    CONTINUE = "continue"
    """Current op still in flight; keep polling."""

    ADVANCED = "advanced"
    """An op terminated cleanly and the orchestrator dispatched the
    next pending step (or ran a skip). Caller may keep polling."""

    TERMINAL_SUCCESS = "terminal_success"
    """All ops succeeded; ``Run.status`` is now ``"completed"``."""

    TERMINAL_FAILED = "terminal_failed"
    """An op failed; the orchestrator initiated rollback over prior
    succeeded ops. ``Run.status`` is now ``"failed"`` or
    ``"rolled_back_failed"``."""


@dataclass(frozen=True, slots=True)
class CancelResult:
    """Outcome of a :meth:`Orchestrator.cancel_with_rollback` call."""

    ok: bool
    """``True`` iff every rollback step succeeded."""

    final_run_status: str
    """``"cancelled"`` when ``ok`` is true, otherwise
    ``"rolled_back_failed"``."""

    ops_rolled_back: list[str] = field(default_factory=list)
    """``operation_name``s applied in reverse step-index order."""

    op_failures: list[dict] = field(default_factory=list)
    """Populated when rollback halted mid-chain. Each entry:
    ``{"op": <RunOperation snapshot dict>, "error": str}``."""

    refusal_reason: str = ""
    """Set when the call refused before changing anything: the run is
    untouched and still live. One of the ``CANCEL_REFUSED_*`` codes; the
    matching human message is ``op_failures[0]["error"]``. Empty when the
    rollback ran (whether it finished or halted)."""


CANCEL_REFUSED_PHASE_SUCCEEDED = "phase_job_succeeded"
"""The running op's Databricks job already TERMINATED/SUCCESS: rolling it
back would undo completed work (spec §6.3)."""


def _now() -> datetime:
    return datetime.now(timezone.utc)


def _row_snapshot(row: RunOperation) -> dict:
    """Snapshot a RunOperation row into a JSON-friendly dict for
    error reporting (e.g. ``op_failures``)."""
    return {
        "id": row.id,
        "step_index": row.step_index,
        "operation_name": row.operation_name,
        "status": row.status,
        "databricks_run_id": row.databricks_run_id,
    }


def _params_or_blocker(
    op: Operation, params_json: str
) -> tuple[Optional[dict], Optional[str]]:
    """Re-validate persisted params against the live registry's
    ``params_model``. Returns ``(validated_dict, None)`` on success or
    ``(None, error_string)`` on failure (spec §2.4 dispatch-time gate).
    """
    try:
        raw = json.loads(params_json) if params_json else {}
    except (json.JSONDecodeError, TypeError) as e:
        return None, f"params_json is not valid JSON: {e!r}"
    if not isinstance(raw, dict):
        return None, f"params_json is not an object: {raw!r}"
    try:
        validated = op.params_model(**raw)
    except ValidationError as e:
        return None, f"Schema drift on op '{op.name}': {e}"
    return validated.model_dump(), None


class Orchestrator:
    """DAG walker for Run lifecycle (see module docstring + design §4).

    Construct one instance per app process and reuse across runs;
    instances are stateless beyond the workspace client + session
    factory passed at construction.

    Per spec §4 the per-run side-effecting methods
    (``cancel_with_rollback``, ``resume``) take a ``ws`` argument so
    tests + callers can pass a per-call workspace client. The
    construction-time ``ws`` is therefore optional and acts only as the
    default ``advance()`` / ``start()`` use when no explicit ``ws`` is
    available (the production wiring sets it once on the singleton).
    """

    def __init__(
        self,
        ws: Any = None,
        session_factory: Optional[Callable[[], Session]] = None,
        registry_get: Optional[Callable[[str], Operation]] = None,
        progress_drain: Optional[Callable[[Run, Session], None]] = None,
    ) -> None:
        self._ws = ws
        self._session_factory = session_factory
        self._registry_get = registry_get or _registry_get_default
        # Canonical _vibe_progress drainer (ProgressTracker._sync_orch_progress_events),
        # threaded into the model-producing observe ctx so the model_sync
        # lineage pass can run a synchronous final drain before reading the
        # rename/merge/delete signals (Task 4 §2.0a). None in tests / when no
        # tracker is wired — the lineage drain is then skipped (no-op gate).
        self._progress_drain = progress_drain

    # ------------------------------------------------------------------
    # Public API (spec §4)
    # ------------------------------------------------------------------

    def start(self, run: Run, dag: Dag, session: Session) -> None:
        """Persist the DAG as ``RunOperation`` rows and dispatch step 0.

        Idempotent: if ``run_operations`` rows already exist for this
        run, the DAG is NOT re-persisted; only the first ``pending``
        op is re-dispatched (re-attaching to an existing Databricks
        run via ``op.observe`` if one was already launched).

        Sets ``run.intent = dag.intent`` and ``run.status = "running"``.
        Does not commit — the caller owns the transaction boundary.
        """
        # Persist the DAG (idempotent — skip if rows already exist).
        existing = session.exec(
            select(RunOperation)
            .where(RunOperation.run_id == run.id)
            .order_by(RunOperation.step_index)
        ).all()
        if not existing:
            for i, step in enumerate(dag.steps):
                row = RunOperation(
                    run_id=run.id,
                    step_index=i,
                    operation_name=step.name,
                    params_json=json.dumps(step.params),
                    skip_if=step.skip_if or "",
                    status="pending",
                )
                session.add(row)
            session.flush()

        # Stamp run-level fields the orchestrator owns.
        run.intent = dag.intent
        if run.status not in ("running", "stale"):
            run.status = "running"
        if run.started_at is None:
            run.started_at = _now()
        session.add(run)
        session.flush()

        # Zero-step DAG: degenerate but legal — finalize immediately.
        # The validators reject empty DAGs at create time, but we MUST
        # be defensive (no IndexError on an empty steps tuple).
        if not dag.steps:
            self._finalize_run_success(run, session)
            session.flush()
            return

        # Dispatch the first pending op (or re-attach to one already
        # running). When all ops are already terminal, finalize.
        self._dispatch_or_advance_initial(run, session)

    def advance(self, run: Run, session: Session) -> AdvanceOutcome:
        """Single tick: observe the running op, advance / rollback as
        needed.

        State machine (spec §6):

        1. Load all ``RunOperation`` rows ordered by step_index.
        2. If any has status ``"failed"`` and run is already terminal,
           return ``TERMINAL_FAILED``.
        3. If a row has status ``"running"``, observe it. If the
           observation is non-terminal → ``CONTINUE``. Otherwise mark
           the row terminal and either dispatch the next pending or
           initiate rollback.
        4. If every row is ``succeeded``/``skipped``, mark the Run
           ``completed`` and return ``TERMINAL_SUCCESS``.
        """
        rows = self._load_rows(run, session)
        if not rows:
            # No DAG persisted (legacy run) — nothing to advance.
            return AdvanceOutcome.CONTINUE

        # Quick terminal check — if a row is already failed, the run is
        # in its post-rollback state; the poll loop should have exited
        # already, but be safe.
        if any(r.status == "failed" for r in rows):
            return AdvanceOutcome.TERMINAL_FAILED
        if all(r.status in ("succeeded", "skipped") for r in rows):
            self._finalize_run_success(run, session)
            return AdvanceOutcome.TERMINAL_SUCCESS

        # Find the first row that is in flight.
        running = next((r for r in rows if r.status == "running"), None)
        if running is not None:
            return self._advance_running(run, running, rows, session)

        # No running, but some pending — dispatch the next.
        pending = next((r for r in rows if r.status == "pending"), None)
        if pending is not None:
            return self._dispatch_pending(run, pending, rows, session)

        # All terminal: nothing to do but mark complete.
        self._finalize_run_success(run, session)
        return AdvanceOutcome.TERMINAL_SUCCESS

    def cancel_with_rollback(
        self,
        run: Run,
        session: Session,
        ws: Any = None,
    ) -> CancelResult:
        """Stop polling, cancel any in-flight Databricks job, and replay
        :meth:`Operation.rollback` in reverse over completed/running ops.

        Idempotent: a re-call after a partial rollback skips rows
        already in ``rolled_back`` status. Safety gate: refuses if the
        running op's Databricks job has terminated SUCCESS — in that
        case the user should fully cancel via the plain endpoint and
        run an uninstall explicitly (spec §6.3). On safety-gate refusal
        the run is left untouched and the caller receives
        ``CancelResult(ok=False, final_run_status=<unchanged>)`` so the
        route handler can map that to a 409 without us having raised;
        ``refusal_reason`` says which check refused.

        Per spec §4: ``ws`` is a method argument — passing it here
        overrides any ``ws`` set on the orchestrator instance for the
        duration of this call.
        """
        ws_for_call = ws if ws is not None else self._ws
        rows = self._load_rows(run, session)

        # Idempotent re-call against a terminal-cancelled run is a
        # no-op: there's nothing to roll back, and we mustn't touch
        # ``jobs.cancel_run`` again.
        if run.status in ("cancelled", "rolled_back_failed") and not any(
            r.status in _ROLLBACK_CANDIDATE_STATUSES for r in rows
        ):
            return CancelResult(
                ok=run.status == "cancelled",
                final_run_status=run.status,
                ops_rolled_back=[],
                op_failures=[],
            )

        # Safety gate: refuse if the running op's job is TERMINATED/SUCCESS.
        # Per the test contract (tests/test_orchestrator_runner.py
        # ``test_safety_gate_refuses_when_current_phase_terminated_success``)
        # we return ``CancelResult(ok=False)`` rather than raise — the
        # caller maps this to the 409 response.
        running = next((r for r in rows if r.status == "running"), None)
        if running is not None and running.databricks_run_id and ws_for_call is not None:
            try:
                job_run = ws_for_call.jobs.get_run(running.databricks_run_id)
                state = getattr(job_run, "state", None)
                lcs = ""
                rs = ""
                if state is not None:
                    lcs_obj = getattr(state, "life_cycle_state", None)
                    rs_obj = getattr(state, "result_state", None)
                    lcs = getattr(lcs_obj, "value", "") if lcs_obj else ""
                    rs = getattr(rs_obj, "value", "") if rs_obj else ""
                if lcs == "TERMINATED" and rs == "SUCCESS":
                    return CancelResult(
                        ok=False,
                        final_run_status=run.status,
                        ops_rolled_back=[],
                        op_failures=[
                            {
                                "op": _row_snapshot(running),
                                "error": (
                                    f"Cancel-with-rollback refused: the "
                                    f"Databricks job of step "
                                    f"'{running.operation_name}' already "
                                    f"finished successfully, so rolling it "
                                    f"back would undo completed work. The run "
                                    f"continues."
                                ),
                            }
                        ],
                        refusal_reason=CANCEL_REFUSED_PHASE_SUCCEEDED,
                    )
            except Exception as e:  # noqa: BLE001 — best-effort gate
                logger.warning(
                    "cancel_with_rollback: Jobs API state check failed for "
                    "run=%s dbx=%s: %r — proceeding (trust app status).",
                    run.id, running.databricks_run_id, e,
                )

        # Best-effort cancel of the in-flight Databricks job.
        if running is not None and running.databricks_run_id and ws_for_call is not None:
            try:
                ws_for_call.jobs.cancel_run(running.databricks_run_id)
            except Exception as e:  # noqa: BLE001 — non-fatal
                logger.warning(
                    "cancel_with_rollback: jobs.cancel_run failed for "
                    "run=%s dbx=%s: %r",
                    run.id, running.databricks_run_id, e,
                )

        # Walk in reverse step_index, rolling back succeeded/running ops.
        ops_rolled_back: list[str] = []
        op_failures: list[dict] = []
        first_failure: Optional[dict] = None

        with self._scoped_ws(ws_for_call):
            for row in sorted(rows, key=lambda r: r.step_index, reverse=True):
                if row.status in ("pending", "skipped", "rolled_back"):
                    continue
                if row.status not in _ROLLBACK_CANDIDATE_STATUSES:
                    continue
                if first_failure is not None:
                    # Halt — operator inspects residual state.
                    break
                if self._keeps_its_effect(row):
                    continue
                try:
                    self._rollback_one(row, session)
                    row.status = "rolled_back"
                    row.completed_at = _now()
                    session.add(row)
                    ops_rolled_back.append(row.operation_name)
                except Exception as e:  # noqa: BLE001 — caller-aware halt
                    logger.exception(
                        "Rollback failed for run=%s op=%s step=%d",
                        run.id, row.operation_name, row.step_index,
                    )
                    # IMPORTANT: do NOT mutate ``row.status`` here. Per
                    # spec §6.2 + the adversarial test
                    # ``test_rollback_failure_halts_chain_and_marks_rolled_back_failed``,
                    # a row whose rollback raised stays in its prior
                    # status (``succeeded``) so the operator can see
                    # exactly which UC state still needs manual cleanup.
                    first_failure = {
                        "op": _row_snapshot(row),
                        "error": recorded_error_text(
                            e, f"Rollback of {row.operation_name}", f"{type(e).__name__}: {e}"),
                    }
                    op_failures.append(first_failure)

        # Final Run status — route through the atomic helper so RunOperation
        # rows, progress_message, and completed_at are all stamped together.
        # Wiring audit:
        #   Previous: direct run.status / run.completed_at writes here.
        #   New: transition_run owns all terminal layer updates.
        #   Info-flow delta: RunOperation rows that were still "running"
        #     during rollback now reach "cancelled" / "rolled_back" instead
        #     of being left in their prior status.
        from ...run_state_transitions import transition_run

        if first_failure is None:
            run.error_message = ""
            transition_run(session, run, target_status="cancelled", reason="with rollback")
        else:
            err = (
                f"Rollback halted on op "
                f"{first_failure['op'].get('operation_name', '?')}: "
                f"{first_failure['error']}. Remaining ops skipped; "
                f"manual cleanup required."
            )
            run.error_message = err
            session.add(run)
            transition_run(session, run, target_status="rolled_back_failed", reason=err)
        session.flush()

        return CancelResult(
            ok=first_failure is None,
            final_run_status=run.status,
            ops_rolled_back=ops_rolled_back,
            op_failures=op_failures,
        )

    def resume(self, run: Run, session: Session, ws: Any = None) -> None:
        """Re-enter the orchestrator at the failed/stale op.

        Used by the lifespan startup scan and the admin
        ``/admin/runs/{id}/resume`` endpoint (spec §6.4).

        Four entry conditions (spec §6.4 table):

        1. ``running``/``stale`` (app restart). Re-attach via the
           persisted handle and let :meth:`advance` observe it.
        2. ``failed`` (admin retry). Reset failed rows to a re-dispatch
           state (``pending`` if the job never launched, ``running``
           otherwise so observe can re-attach to the persisted handle)
           and call :meth:`advance`.
        3. ``rolled_back_failed`` (crash mid-rollback). Continue the
           rollback chain from the next-newer succeeded op below the
           one that previously raised. Calls
           :meth:`_initiate_rollback` directly against the original
           failed row.
        4. ``cancelled`` (admin retry after the run was cancelled, with or
           without rollback). Every row is already terminal in some
           status other than ``failed`` (``cancelled``, ``rolled_back``,
           ``succeeded``, or a never-started ``pending``, depending on
           which cancel path fired), so the reset in case 2 above would
           not touch any of them. Reset every non-``succeeded``/``skipped``
           row to ``pending`` and restart the DAG from scratch; a full
           cancellation already unwound this run's outputs, so there is
           nothing left to resume mid-flight.

        Per spec §4: ``ws`` is a method argument — passing it here
        overrides the orchestrator's stored ``ws`` for the duration of
        this call.
        """
        ws_for_call = ws if ws is not None else self._ws
        rows = self._load_rows(run, session)
        if not rows:
            return

        prior_status = run.status

        # Crash-mid-rollback recovery (spec §6.4 row 3): the run is
        # ``rolled_back_failed`` and there is at least one ``succeeded``
        # row sitting above the original failure. Continue the rollback
        # chain — do NOT reset the failed row, do NOT re-dispatch.
        if prior_status == "rolled_back_failed":
            failed_row = next(
                (r for r in rows if r.status == "failed"),
                None,
            )
            has_pending_rollback = any(
                r.status in _ROLLBACK_CANDIDATE_STATUSES for r in rows
            )
            if failed_row is not None and has_pending_rollback:
                # _initiate_rollback expects to drive run state
                # transitions itself; clear the prior terminal envelope
                # so it can re-stamp.
                run.status = "running"
                run.error_message = ""
                run.completed_at = None
                session.add(run)
                # Use the resume-time ws so primitives that hit the
                # workspace get the live client.
                with self._scoped_ws(ws_for_call):
                    self._initiate_rollback(run, failed_row, session)
                return
            # Nothing left to roll back — leave the run in its terminal
            # envelope.
            return

        # Admin retry path (spec §6.4 row 2): reset failed rows so the
        # advance loop can re-dispatch them. The recorded
        # databricks_run_id (if any) points at a terminal-FAILED job —
        # re-attaching via observe() would re-discover that failure and
        # trigger the rollback chain, which deletes upstream ops'
        # outputs (e.g. an ECM ModelVersion produced by a succeeded
        # earlier op). Always re-dispatch from scratch instead.
        if prior_status in ("failed", "stale"):
            for row in rows:
                if row.status != "failed":
                    continue
                row.error_message = ""
                row.completed_at = None
                row.databricks_run_id = None
                row.status = "pending"
                session.add(row)

        # Admin retry from a cancelled run (spec §6.4 row 4): every row is
        # already terminal in a status the "failed" reset above never
        # touches ("rolled_back" / "cancelled"), so a bare re-call to
        # advance() would find nothing to (re)dispatch and fall through to
        # its "all rows terminal" branch, incorrectly marking the run
        # "completed" without ever relaunching a job. Reset the whole DAG
        # to "pending" and restart it instead.
        if prior_status == "cancelled":
            for row in rows:
                if row.status in ("succeeded", "skipped"):
                    continue
                row.error_message = ""
                row.completed_at = None
                row.databricks_run_id = None
                row.status = "pending"
                session.add(row)

        # Clear any terminal envelope — the orchestrator is taking over.
        if prior_status in ("failed", "stale", "cancelled", "rolled_back_failed"):
            run.status = "running"
            run.error_message = ""
            run.completed_at = None
            session.add(run)

        # Drive the advance machinery with the resume-time ws.
        with self._scoped_ws(ws_for_call):
            self.advance(run, session)

    # ------------------------------------------------------------------
    # Internal helpers
    # ------------------------------------------------------------------

    @contextmanager
    def _scoped_ws(self, ws: Any) -> Iterator[None]:
        """Temporarily swap ``self._ws`` for ``ws`` so the inner advance
        / rollback helpers (which read ``self._ws`` directly) see the
        per-call workspace client. Restored on exit."""
        if ws is None or ws is self._ws:
            yield
            return
        prior = self._ws
        self._ws = ws
        try:
            yield
        finally:
            self._ws = prior

    def _load_rows(self, run: Run, session: Session) -> list[RunOperation]:
        """Load all RunOperation rows for ``run`` ordered by
        step_index. Returned eagerly so the caller can iterate without
        issuing extra queries."""
        return list(
            session.exec(
                select(RunOperation)
                .where(RunOperation.run_id == run.id)
                .order_by(RunOperation.step_index)
            ).all()
        )

    def _dispatch_or_advance_initial(self, run: Run, session: Session) -> None:
        """Dispatch step 0 (or re-dispatch the first pending op).

        Called from :meth:`start` and from idempotent re-call paths.
        Walks through and:

        - Skips any row whose ``skip_if`` predicate evaluates true.
        - Re-attaches if the row already has ``databricks_run_id``.
        - Otherwise calls ``op.dispatch`` to launch the work.
        """
        rows = self._load_rows(run, session)
        # Find the first row that needs dispatching.
        for row in rows:
            if row.status == "skipped":
                continue
            if row.status == "succeeded":
                continue
            if row.status == "running":
                # Already dispatched — nothing to do (poll loop will
                # observe it on the next tick).
                return
            if row.status == "failed":
                return
            # Pending: try to skip or dispatch.
            self._dispatch_pending(run, row, rows, session)
            return

    def _dispatch_pending(
        self,
        run: Run,
        row: RunOperation,
        rows: list[RunOperation],
        session: Session,
    ) -> AdvanceOutcome:
        """Dispatch a pending RunOperation row.

        Handles skip-predicate evaluation, parent_version_id
        inheritance from prior rows (spec §3
        ``needs_version_from``), and idempotent dispatch (a re-call
        with an existing ``databricks_run_id`` re-attaches via
        ``observe``).
        """
        # Skip predicate: pure-text predicates are evaluated against
        # the run's params + prior steps' outputs. We don't currently
        # have a predicate language — the only producer of skip_if is
        # the DAG factory (Phase 4); when it's set we assume the
        # factory has already pruned dead steps. Any non-empty
        # skip_if is treated literally as "skip this step".
        if row.skip_if:
            row.status = "skipped"
            row.completed_at = _now()
            session.add(row)
            session.flush()
            return self._post_terminal(run, session)

        # Resolve the operation.
        try:
            op = self._registry_get(row.operation_name)
        except KeyError as e:
            return self._fail_run(
                run, row, session,
                f"Unknown primitive '{row.operation_name}': {e}",
            )

        # Re-validate params against current registry (spec §2.4
        # dispatch-time gate — defends against schema drift after a
        # deploy).
        validated_params, error = _params_or_blocker(op, row.params_json)
        if error is not None:
            return self._fail_run(run, row, session, error)

        # Inherit parent_version_id from the matching prior step (the
        # DAG factory can also populate this directly via
        # `OperationStep.params['parent_version_id']`; we fill in if
        # not already set).
        parent_version_id = row.parent_version_id
        if parent_version_id is None:
            parent_version_id = self._inherit_parent_version(row, rows)

        ctx = OperationContext(
            run_id=run.id,
            operation_id=row.id,
            business_id=run.business_id,
            parent_version_id=parent_version_id,
            params=validated_params or {},
            inherited_params=self._inherited_params(run),
        )

        # Idempotency: if this row already has a databricks_run_id
        # (e.g. process crashed between dispatch and DB commit),
        # don't relaunch. Move row to running and let the next
        # advance tick observe it.
        if row.databricks_run_id:
            row.status = "running"
            if row.started_at is None:
                row.started_at = _now()
            session.add(row)
            session.flush()
            return AdvanceOutcome.ADVANCED

        # A registry release an earlier uninstall from this catalog could not
        # complete is issued again first (bounded, never fails the step).
        catalog = str((validated_params or {}).get("deployment_catalog") or "")
        if catalog:
            from ..operations.uninstall import retry_registry_releases

            retry_registry_releases(session, self._ws, catalog)

        # Live dispatch.
        try:
            handle = op.dispatch(ctx, self._ws, session)
        except Exception as e:  # noqa: BLE001 — surface to Run.error
            logger.exception(
                "dispatch failed for run=%s op=%s", run.id, op.name,
            )
            return self._fail_run(
                run, row, session,
                "dispatch error: " + recorded_error_text(
                    e, f"Dispatch of {op.name}", sanitize_error_message(repr(e))),
            )

        row.status = "running"
        row.databricks_run_id = handle.databricks_run_id
        row.vibe_session_id = handle.vibe_session_id
        row.parent_version_id = parent_version_id
        if row.started_at is None:
            row.started_at = _now()
        # Persist dispatch-time extras (deployment_catalog, business_name,
        # scope, …) onto the same ``rollback_state_json`` column
        # ``_advance_running`` reads back into ``handle.extra`` on every
        # subsequent poll tick. Without this write, the very first poll
        # after dispatch rebuilds the handle with an EMPTY ``extra`` (the
        # column stays "{}" until a terminal observation overwrites it
        # with ``result.rollback_state`` — see below) — so an install
        # that reaches TERMINATED/SUCCESS on its first observed tick
        # calls ``mark_version_deployed`` with ``deployment_catalog=""``
        # even though ``dispatch()`` built the real value. This is what
        # live run 771d6b7d hit: deployment_status flipped to "deployed"
        # but uc_catalog stayed "" because the runner never round-tripped
        # the dispatch handle's extras through the DB before observe()
        # ran in a later process tick with a freshly rebuilt handle.
        if handle.extra:
            row.rollback_state_json = json.dumps(handle.extra)
        # Write-once audit trail of the actual dispatched widget map
        # (see `OperationDispatchHandle.dispatched_widgets` docstring).
        # Unlike `rollback_state_json` this is never overwritten again —
        # it answers "what did we send the agent for this op", not
        # "what does rollback need."
        if handle.dispatched_widgets:
            row.dispatched_widgets_json = json.dumps(handle.dispatched_widgets)
        session.add(row)

        # Reflect the dispatched job on the Run so the existing UI
        # (which reads run.databricks_run_id and progress_message)
        # keeps showing live state.
        run.databricks_run_id = handle.databricks_run_id
        run.vibe_session_id = handle.vibe_session_id
        # Phase 4.5 walkthrough bug: the dispatcher generates its own
        # ``vibe_session_id`` (a fresh UUID per dispatch). The router
        # set ``vibe_session_id_bigint`` at create time off ITS UUID,
        # not the dispatcher's. Without recomputing here, the bigint
        # column stays stale and ``progress_tracker`` polls the agent's
        # ``_vibe_progress`` Delta with the wrong session_id — every
        # event the agent writes is invisible to Lakebase, the UI's
        # progress monitor stays empty, and runs that succeed at the
        # agent level look stalled at 50% in the app.
        from ...job_launcher import session_id_to_bigint
        if handle.vibe_session_id:
            run.vibe_session_id_bigint = session_id_to_bigint(handle.vibe_session_id)
        if run.status not in ("running", "stale"):
            run.status = "running"
        run.progress_message = f"Running {op.name}"
        run.last_consumed_step_id = 0
        session.add(run)
        session.flush()
        return AdvanceOutcome.ADVANCED

    def _advance_running(
        self,
        run: Run,
        row: RunOperation,
        rows: list[RunOperation],
        session: Session,
    ) -> AdvanceOutcome:
        """Observe a running op and act on its terminal state.

        On non-terminal: refresh ``run.progress_*`` and return
        ``CONTINUE``. On terminal-success: persist the result and
        dispatch the next pending op. On terminal-failure: mark the
        run failed and initiate rollback.
        """
        try:
            op = self._registry_get(row.operation_name)
        except KeyError as e:
            return self._fail_run(
                run, row, session,
                f"Unknown primitive '{row.operation_name}': {e}",
            )

        # Re-build the context from persisted state.
        try:
            params_raw = json.loads(row.params_json) if row.params_json else {}
        except (json.JSONDecodeError, TypeError):
            params_raw = {}
        ctx = OperationContext(
            run_id=run.id,
            operation_id=row.id,
            business_id=run.business_id,
            parent_version_id=row.parent_version_id,
            params=params_raw if isinstance(params_raw, dict) else {},
            inherited_params=self._inherited_params(run),
        )
        # Load dispatch-time extras (deployment_catalog, business_name,
        # parent_version_int, session_id_bigint, …) that the primitive's
        # ``dispatch()`` persisted on ``rollback_state_json``. Without
        # this, primitives like ``vibe_iterate._fetch_model_json`` see an
        # empty ``handle.extra``, can't construct a Volume path, and fall
        # back to ``/Volumes/_unknown/model.json`` which the workspace
        # Files API rejects with "Path is missing a volume name". The
        # rollback_state_json column is overloaded with both dispatch
        # context and rollback state; treat any persisted dict as
        # carry-forward extras.
        extras = json_object(row.rollback_state_json)
        # Inject the live (non-persisted) _vibe_progress drainer so the
        # model-producing observe() can run model_sync's synchronous final
        # drain before reading rename/merge/delete signals (Task 4 §2.0a).
        if self._progress_drain is not None:
            extras = {**extras, "progress_drain": self._progress_drain}
        handle = OperationDispatchHandle(
            databricks_run_id=row.databricks_run_id,
            vibe_session_id=row.vibe_session_id,
            extra=extras,
        )

        try:
            obs: OperationObservation = op.observe(handle, ctx, self._ws, session)
        except Exception as e:  # noqa: BLE001 — surface as observe error
            logger.exception(
                "observe failed for run=%s op=%s", run.id, op.name,
            )
            # Treat as a transient — the poll loop will retry.
            run.last_poll_error = recorded_error_text(e, f"Observe of {op.name}", repr(e))
            session.add(run)
            return AdvanceOutcome.CONTINUE

        # Refresh progress signals on the Run.
        #
        # ``obs.progress_percent`` here is an INFERRED value from the
        # primitive's observe() — for model-producing ops it's just a
        # Jobs-API state heuristic (RUNNING → 50, TERMINATED → 100),
        # NOT real per-event progress. Letting it advance the user-
        # facing bar makes a fresh run snap to 25% the moment Jobs
        # reports RUNNING, even though the agent hasn't emitted a
        # single event yet — the user sees "25%" while the events
        # panel is empty. (Feedback 2026-04-26: erodes trust.)
        #
        # Resolution: for model-producing ops, the runner does NOT
        # write the bar. ``_sync_orch_progress_events`` owns the bar
        # for those — it reads the agent's actual per-event
        # ``completed_percent`` and gates on whether events have been
        # drained to Lakebase. For lifecycle ops (install / uninstall /
        # samples), the agent emits no events, so the runner remains
        # the sole progress source.
        if isinstance(obs.progress_percent, int) and not op.produces_version:
            total = max(len(rows), 1)
            completed = sum(
                1 for r in rows if r.status in ("succeeded", "skipped")
            )
            slice_pct = 100.0 / total
            local_pct = max(0, min(100, obs.progress_percent))
            overall_pct = int(round(
                completed * slice_pct + (local_pct / 100.0) * slice_pct
            ))
            # Cap at 99 until the orchestrator marks the run terminal.
            if overall_pct > 99:
                overall_pct = 99
            # Never let the bar go backwards.
            existing = int(run.progress_percent or 0)
            if overall_pct < existing:
                overall_pct = existing
            run.progress_percent = overall_pct
        # Progress message: same split — model-producing runs let
        # ``_sync_orch_progress_events`` write the user-facing message
        # ("Booting agent — …" / "Running — Phase N/total, X%").
        # Lifecycle ops use the runner's per-step message.
        if obs.progress_message and not op.produces_version:
            run.progress_message = f"[{op.name}] {obs.progress_message}"
        run.last_poll_error = ""
        session.add(run)

        if not obs.is_terminal:
            return AdvanceOutcome.CONTINUE

        result = obs.terminal_result
        if result is None:
            # Operation contract violation — treat as a failure.
            return self._fail_run(
                run, row, session,
                f"Op '{op.name}' reported is_terminal=True with no terminal_result",
            )

        # Record the terminal payload on the row.
        row.completed_at = _now()
        row.rollback_state_json = json.dumps(result.rollback_state or {})
        if result.output_version_id:
            row.output_version_id = result.output_version_id

        if result.succeeded:
            row.status = "succeeded"
            row.error_message = ""
            session.add(row)
            # If the op produced a version, surface it on the Run too
            # so the UI's "what version did this run create" works.
            if op.produces_version and result.output_version_id:
                run.version_id = result.output_version_id
                session.add(run)
            session.flush()
            # Background ELK prefetch for the new version so the first
            # diagram view is instant. Non-blocking; helper logs and
            # swallows any failure so a flaky cache layer can never
            # block the run from completing. The jobs start only after
            # the tick commits the new version.
            if op.produces_version and result.output_version_id and self._session_factory and self._ws:
                self._queue_layout_prefetch(run, result.output_version_id, session)
            return self._post_terminal(run, session)

        # Terminal-failure: mark row + rollback over priors.
        row.status = "failed"
        row.error_message = result.error or "operation failed"
        session.add(row)
        return self._initiate_rollback(run, row, session)

    def _queue_layout_prefetch(
        self, run: Run, output_version_id: str, session: Session,
    ) -> None:
        """Fan out ELK layout prefetch jobs for a freshly-produced version.

        Called from the per-op terminal-success path whenever a
        ``produces_version=True`` operation completes
        (``generate_ecm`` / ``shrink_to_mvm`` / ``enlarge_to_ecm`` /
        ``vibe_iterate``). Looks up the new ``ModelVersion`` to get its
        ``version`` and ``scope`` integers, then delegates to
        ``diagram.queue_layout_prefetch_for_version``.

        Best-effort — wrapped in a broad ``try`` so any failure (model
        version row missing, prefetch pool exhausted, importing
        ``diagram`` fails) is logged and swallowed without affecting the
        run completion path.
        """
        try:
            from ...db_models import ModelVersion as _DbMV
            from ...diagram import queue_layout_prefetch_for_version

            mv = session.get(_DbMV, output_version_id)
            if mv is None:
                return
            queue_layout_prefetch_for_version(
                session, self._session_factory, self._ws,
                business_id=run.business_id,
                version_int=mv.version,
                scope=mv.scope,
            )
        except Exception:
            logger.exception(
                "Layout prefetch fanout failed for run=%s version=%s — non-fatal",
                run.id, output_version_id,
            )

    def _post_terminal(self, run: Run, session: Session) -> AdvanceOutcome:
        """After an op reaches a clean terminal (succeeded or skipped),
        decide what's next.

        Either dispatch the next pending op, or finalize the run as
        completed.
        """
        rows = self._load_rows(run, session)
        if any(r.status == "failed" for r in rows):
            # Defensive — should be handled before we got here.
            return AdvanceOutcome.TERMINAL_FAILED
        if all(r.status in ("succeeded", "skipped") for r in rows):
            self._finalize_run_success(run, session)
            return AdvanceOutcome.TERMINAL_SUCCESS

        pending = next((r for r in rows if r.status == "pending"), None)
        if pending is None:
            # Some op is still running (we just transitioned, not
            # multi-tick) — caller will tick again.
            return AdvanceOutcome.ADVANCED

        return self._dispatch_pending(run, pending, rows, session)

    def _finalize_run_success(self, run: Run, session: Session) -> None:
        """Mark the Run completed; idempotent. Flushes so callers
        (including ``session.refresh(run)``) see the new status.

        Wiring audit
        ------------
        Previous: wrote run.status / run.completed_at / run.progress_message
        directly.
        New: delegates to transition_run(..., target_status="completed") which
        also stamps RunOperation rows and does the idempotency guard.
        Info-flow delta: run.progress_percent=100 and run.error_message="" are
        still set here before the helper so they are included in the same flush.
        """
        if run.status == "completed":
            return
        from ...run_state_transitions import transition_run

        run.progress_percent = 100
        run.error_message = ""
        session.add(run)
        transition_run(session, run, target_status="completed")
        session.flush()

    def _fail_run(
        self,
        run: Run,
        row: RunOperation,
        session: Session,
        error: str,
    ) -> AdvanceOutcome:
        """Mark a row failed and initiate rollback over priors.

        TODO (Backlog #6gXvCx7Rj5GHrWCH — orphan UC schema rollback):
        ``_initiate_rollback`` calls each op's ``Operation.rollback``;
        ``rollback_generation_op`` only drops UC schemas when the op
        reached the agent's install stages (``installed_inline=True``).
        Failures during ECM/MVM generation (Stages 1-11) leave
        agent-created schemas orphaned, which then trip the
        ``_check_target_catalog_clash`` pre-flight on retry. Per
        ``feedback_state_atomicity`` the fix is a true rollback path,
        not a force-overwrite escape hatch — see the Backlog task for
        the architectural change (~250-400 LOC: rollback_state seeding
        in ``dispatch()``, new ``drop_partial_schemas_in_catalog``
        helper, wiring through ``rollback_generation_op``, real-infra
        regression smoke).
        """
        row.status = "failed"
        row.error_message = error
        row.completed_at = _now()
        session.add(row)
        return self._initiate_rollback(run, row, session)

    def _initiate_rollback(
        self, run: Run, failed_row: RunOperation, session: Session
    ) -> AdvanceOutcome:
        """Replay rollback() in reverse over prior succeeded ops.

        Per spec §6.2: each rollback wrapped try/except. First
        rollback failure marks the Run ``rolled_back_failed`` and
        halts. If all rollbacks succeed, Run is marked ``failed`` (not
        ``cancelled`` — the user didn't ask to cancel).
        """
        rows = self._load_rows(run, session)
        first_failure: Optional[dict] = None
        # Every caller hands in a row already marked ``failed``, which is not
        # a rollback candidate: only the steps that succeeded (or are still
        # running) before it are rolled back.
        for row in sorted(rows, key=lambda r: r.step_index, reverse=True):
            if row.status not in _ROLLBACK_CANDIDATE_STATUSES:
                continue
            if self._keeps_its_effect(row):
                continue
            try:
                self._rollback_one(row, session)
                row.status = "rolled_back"
                row.completed_at = _now()
                session.add(row)
            except Exception as e:  # noqa: BLE001 — chain halt
                logger.exception(
                    "Rollback failed during failure-recovery for "
                    "run=%s op=%s step=%d",
                    run.id, row.operation_name, row.step_index,
                )
                # IMPORTANT: do NOT mutate ``row.status`` — see spec
                # §6.2 + adversarial test
                # ``test_rollback_failure_halts_chain_and_marks_rolled_back_failed``.
                # The row keeps its prior ``succeeded`` status so the
                # operator can identify exactly what UC state still
                # needs manual cleanup.
                first_failure = {
                    "op": _row_snapshot(row),
                    "error": recorded_error_text(
                        e, f"Rollback of {row.operation_name}", f"{type(e).__name__}: {e}"),
                }
                break

        # Mark the Run terminal via the atomic helper.
        # Wiring audit:
        #   Previous: direct run.status / run.completed_at writes here.
        #   New: transition_run stamps all layers.
        #   Info-flow delta: progress_message now reflects the failed phase
        #     index; prior code left whatever "Running …" text was last set.
        from ...run_state_transitions import transition_run

        if first_failure is None:
            reason = (
                failed_row.error_message
                or f"Operation '{failed_row.operation_name}' failed"
            )
            run.error_message = reason
            session.add(run)
            transition_run(session, run, target_status="failed", reason=reason)
        else:
            err = (
                f"Op '{failed_row.operation_name}' failed; rollback then "
                f"halted on '{first_failure['op'].get('operation_name', '?')}': "
                f"{first_failure['error']}. Manual cleanup required."
            )
            run.error_message = err
            session.add(run)
            transition_run(session, run, target_status="rolled_back_failed", reason=err)
        session.flush()
        return AdvanceOutcome.TERMINAL_FAILED

    def _keeps_its_effect(self, row: RunOperation) -> bool:
        """A succeeded op whose rollback undoes nothing (an uninstall) keeps
        ``succeeded``: its effect stands in UC, so ``rolled_back`` would be
        untrue."""
        if row.status != "succeeded":
            return False
        try:
            op = self._registry_get(row.operation_name)
        except KeyError:
            return False
        return getattr(op, "rollback_is_noop", False) is True

    def _rollback_one(self, row: RunOperation, session: Session) -> None:
        """Resolve the operation, build a context, and call
        :meth:`Operation.rollback`. Raises on failure."""
        op = self._registry_get(row.operation_name)
        try:
            params_raw = json.loads(row.params_json) if row.params_json else {}
        except (json.JSONDecodeError, TypeError):
            params_raw = {}
        try:
            rollback_state = (
                json.loads(row.rollback_state_json)
                if row.rollback_state_json
                else {}
            )
        except (json.JSONDecodeError, TypeError):
            rollback_state = {}
        # We don't have run_id directly on the row outside of a
        # join — use row.run_id.
        ctx = OperationContext(
            run_id=row.run_id,
            operation_id=row.id,
            business_id=self._business_id_for_run(row.run_id, session),
            parent_version_id=row.parent_version_id,
            params=params_raw if isinstance(params_raw, dict) else {},
            inherited_params={},
        )
        op.rollback(
            ctx,
            rollback_state if isinstance(rollback_state, dict) else {},
            self._ws,
            session,
        )

    def _business_id_for_run(self, run_id: str, session: Session) -> str:
        run = session.get(Run, run_id)
        return run.business_id if run is not None else ""

    def _inherit_parent_version(
        self, row: RunOperation, rows: list[RunOperation]
    ) -> Optional[str]:
        """Resolve a step's ``parent_version_id`` from prior steps.

        Today the DAG's ``needs_version_from`` reference is consumed
        at validation (cross-step) and the orchestrator simply takes
        the most recent prior op that has an ``output_version_id``.
        Phase 4 may make this explicit per ``OperationStep``.
        """
        # rows is ordered ascending by step_index; walk priors and
        # remember the most recent ``output_version_id``.
        latest_id: Optional[str] = None
        for prior in rows:
            if prior.step_index >= row.step_index:
                break
            if prior.output_version_id:
                latest_id = prior.output_version_id
        return latest_id

    def _inherited_params(self, run: Run) -> dict:
        """Carry-keys propagated to every op in the DAG (spec §2.4
        "OperationContext.inherited_params"). Today this is just the
        Run.parameters_json blob — Phase 4 may narrow it to a
        explicit allowlist."""
        try:
            data = json.loads(run.parameters_json) if run.parameters_json else {}
        except (json.JSONDecodeError, TypeError):
            return {}
        return data if isinstance(data, dict) else {}
