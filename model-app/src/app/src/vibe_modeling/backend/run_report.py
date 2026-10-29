"""Per-feedback run report: the agent's outcomes as typed rows.

A vibe run's model.json says, per feedback item the run sent, what the agent
did with it (``input_outcomes``), plus the version facts and the ``lineage``
block. :func:`persist_agent_report` stores that summary (built by
``vibe_iterate._build_agent_outcomes``) as one ``RunAgentReport`` row and the
``outcome_*`` columns of the run's ``RunInputLink`` rows. The feedback
consume step (``progress_tracker._finalize_run_inputs``) and the report
routes (``routes/run_report.py``) read those rows.

Outcome values on a link:

* the agent's status (:data:`AGENT_OUTCOME_STATUSES`, unknown values kept);
* :data:`OUTCOME_NOT_REPORTED` when the agent reported outcomes but none for
  this input, or an entry for it with no status;
* NULL when the agent reported no outcomes (missing or malformed key, a
  version mismatch, or no report at all).
"""

from __future__ import annotations

import json
from datetime import datetime, timezone
from typing import Any, Optional

from sqlmodel import Session, col, select

from .core._time import as_utc
from .db_models import (
    ModelVersion,
    Run,
    RunAgentReport,
    RunInputLink,
    RunOperation,
    VibeInput,
)
from .models import Intent, RunConsumeNote, RunReportItemOut, RunReportOut

# The agent's per-input statuses (nb 55232-55243: ``_vibe_input_fold`` and
# ``_VIBE_INPUT_OPEN_ORDER`` / ``_VIBE_INPUT_SCOPE_STATUSES``).
AGENT_OUTCOME_STATUSES = (
    "applied",
    "unmapped",
    "partial",
    "failed",
    "deferred",
    "scope_dependency_conflict",
    "scope_fence_violation",
    "scope_rejected",
)
OUTCOME_APPLIED = "applied"
OUTCOME_NOT_REPORTED = "not_reported"
OUTCOME_REOPENED = "reopened"
# The agent caps its reasons at this length (nb 55240).
OUTCOME_REASON_MAX = 500

_VIBE_OP = "vibe_iterate"
# Ops whose succeeded run produced a version from the run's inputs.
PRODUCING_OPS = (_VIBE_OP, "shrink_to_mvm", "enlarge_to_ecm")
# ``ModelVersion.sync_state`` values of a version whose sync did not land; the
# report rows are written in the same savepoint, so such a version has none.
_SYNC_FAILED_STATES = ("sync_empty", "incomplete_metadata")


def persist_agent_report(session: Session, run_id: str, summary: dict) -> RunAgentReport:
    """Write the run's ``RunAgentReport`` row and its links' ``outcome_*``.

    Replaces any earlier report of the same run (a retry reuses the run), and
    rewrites every link of the run, so a relinked retry starts from its own
    outcomes. Outcomes are written only when the agent reported a readable
    ``input_outcomes`` list for the expected version. Flushes; the caller
    owns the commit.
    """
    reported = bool(
        summary.get("has_input_outcomes")
        and not summary.get("input_outcomes_malformed")
        and not summary.get("version_mismatch")
    )
    by_id: dict[str, dict] = {}
    if reported:
        for o in summary.get("input_outcomes") or []:
            if o.get("item_id"):
                by_id[o["item_id"]] = o

    links = session.exec(select(RunInputLink).where(RunInputLink.run_id == run_id)).all()
    for link in links:
        outcome = by_id.get(link.input_id)
        if not reported:
            status, reason, target = None, None, None
        elif outcome is None:
            status, reason, target = OUTCOME_NOT_REPORTED, None, None
        else:
            status = outcome.get("status") or OUTCOME_NOT_REPORTED
            reason = outcome.get("reason") or None
            target = outcome.get("target") or None
        link.outcome_status = status
        link.outcome_reason = reason
        link.outcome_target = target
        session.add(link)

    lineage = summary.get("lineage") or {}
    report = session.get(RunAgentReport, run_id) or RunAgentReport(run_id=run_id)
    report.has_input_outcomes = bool(summary.get("has_input_outcomes"))
    report.outcomes_malformed = bool(summary.get("input_outcomes_malformed"))
    report.version_mismatch = bool(summary.get("version_mismatch"))
    report.expected_version = summary.get("expected_version")
    report.fetched_version = summary.get("fetched_version")
    report.lineage_base_version = lineage.get("base_version")
    report.lineage_head_at_write = lineage.get("head_at_write")
    report.lineage_stale = lineage.get("stale")
    report.unmatched_outcome_count = len(set(by_id) - {link.input_id for link in links})
    report.created_at = datetime.now(timezone.utc)
    session.add(report)
    session.flush()
    return report


def clear_agent_report(session: Session, run_id: str) -> None:
    """Undo :func:`persist_agent_report` (the vibe op's rollback). Flushes."""
    report = session.get(RunAgentReport, run_id)
    if report is not None:
        session.delete(report)
    for link in session.exec(select(RunInputLink).where(RunInputLink.run_id == run_id)).all():
        link.outcome_status = None
        link.outcome_reason = None
        link.outcome_target = None
        session.add(link)
    session.flush()


def vibe_output_version_id(session: Session, run_id: str) -> Optional[str]:
    """The version the run's succeeded ``vibe_iterate`` op produced, if any."""
    return session.exec(
        select(RunOperation.output_version_id)
        .where(RunOperation.run_id == run_id)
        .where(RunOperation.operation_name == _VIBE_OP)
        .where(RunOperation.status == "succeeded")
        .where(RunOperation.output_version_id.is_not(None))
        .order_by(RunOperation.step_index.desc())
    ).first()


def run_is_dry_run(session: Session, run: Optional[Run]) -> bool:
    """True when the run was launched as a Dry Run.

    ``Run.parameters_json.dry_run`` is the launch record; the ``dry_run`` flag
    of the version the run produced is the fallback.
    """
    if run is None:
        return False
    try:
        params = json.loads(run.parameters_json) if run.parameters_json else {}
    except (TypeError, ValueError):
        params = {}
    if isinstance(params, dict) and params.get("dry_run") is True:
        return True
    version_id = vibe_output_version_id(session, run.id)
    mv = session.get(ModelVersion, version_id) if version_id else None
    return bool(mv is not None and mv.dry_run)


def _is_vibe_run(session: Session, run: Run) -> bool:
    return run.intent == Intent.VIBE_ITERATE.value or session.exec(
        select(RunOperation.id)
        .where(RunOperation.run_id == run.id)
        .where(RunOperation.operation_name == _VIBE_OP)
    ).first() is not None


def consume_note(
    run: Run,
    report: Optional[RunAgentReport],
    links: list[RunInputLink],
    *,
    is_vibe: bool,
    dry_run: bool,
    output_version: Optional[ModelVersion],
) -> Optional[RunConsumeNote]:
    """Why the run's inputs were or were not marked done; None when normal.

    The reasons nothing was consumed come first, in the order the consume
    step applies them: the output version's sync failed (its report rolled
    back with it), no report from a vibe run that finished before reports
    existed, the wrong version's file, an unreadable ``input_outcomes``, no
    outcome for any input the run sent; then a Dry Run, which consumes on
    install.
    """
    if run.intent == Intent.INSTALL.value:
        if any(link.outcome_status in (OUTCOME_APPLIED, OUTCOME_REOPENED) for link in links):
            return "install_consumed"
        return None
    if output_version is not None and output_version.sync_state in _SYNC_FAILED_STATES:
        return "sync_failed"
    if report is None:
        return "pre_0_9_0" if is_vibe and run.status == "completed" else None
    if report.version_mismatch:
        return "version_mismatch"
    if report.outcomes_malformed:
        return "malformed"
    if not report.has_input_outcomes or (
        links and all(link.outcome_status == OUTCOME_NOT_REPORTED for link in links)
    ):
        return "no_outcomes_reported"
    if dry_run:
        if output_version is not None and output_version.promoted_at is not None:
            return "dry_run_installed"
        return "dry_run_pending_install"
    return None


def build_run_report(session: Session, run: Run) -> RunReportOut:
    """Assemble :class:`RunReportOut` for ``run`` from its rows."""
    report = session.get(RunAgentReport, run.id)
    rows = session.exec(
        select(RunInputLink, VibeInput)
        .join(VibeInput, VibeInput.id == RunInputLink.input_id)
        .where(RunInputLink.run_id == run.id)
        .order_by(VibeInput.created_at, VibeInput.id)
    ).all()
    links = [link for link, _ in rows]
    output_version_id = vibe_output_version_id(session, run.id)
    output_version = session.get(ModelVersion, output_version_id) if output_version_id else None
    dry_run = run_is_dry_run(session, run)
    note = consume_note(
        run, report, links,
        is_vibe=_is_vibe_run(session, run),
        dry_run=dry_run,
        output_version=output_version,
    )
    facts: dict[str, Any] = {"has_input_outcomes": False, "version_mismatch": False}
    if report is not None:
        facts.update(
            has_input_outcomes=report.has_input_outcomes,
            version_mismatch=report.version_mismatch,
            expected_version=report.expected_version,
            fetched_version=report.fetched_version,
            lineage_base_version=report.lineage_base_version,
            lineage_head_at_write=report.lineage_head_at_write,
            lineage_stale=report.lineage_stale,
            unmatched_outcome_count=report.unmatched_outcome_count,
        )
    return RunReportOut(
        run_id=run.id,
        business_id=run.business_id,
        intent=run.intent,
        run_status=run.status,
        output_version_id=output_version_id,
        dry_run=dry_run,
        consume_note=note,
        has_agent_report=report is not None,
        items=[_item_out(link, vi) for link, vi in rows],
        **facts,
    )


def producing_run(session: Session, version_id: str) -> Optional[Run]:
    """The run whose succeeded op produced ``version_id``: a vibe, or the
    shrink / enlarge step of a unified run (the MVM or ECM it derived from
    the run's vibe output, from the same inputs)."""
    run_id = session.exec(
        select(RunOperation.run_id)
        .where(RunOperation.output_version_id == version_id)
        .where(col(RunOperation.operation_name).in_(PRODUCING_OPS))
        .where(RunOperation.status == "succeeded")
        .order_by(col(RunOperation.completed_at).desc())
    ).first()
    return session.get(Run, run_id) if run_id else None


def _item_out(link: RunInputLink, vi: VibeInput) -> RunReportItemOut:
    return RunReportItemOut(
        input_id=link.input_id,
        outcome_status=link.outcome_status,
        outcome_reason=link.outcome_reason,
        outcome_target=link.outcome_target,
        created_at=as_utc(link.created_at),
        text=vi.text,
        origin=vi.origin,
        priority=vi.priority,
        status=vi.status,
        consumed=vi.consumed,
        consumed_by_run_id=vi.consumed_by_run_id,
        selected_for_run=vi.selected_for_run,
    )


__all__ = [
    "AGENT_OUTCOME_STATUSES",
    "OUTCOME_APPLIED",
    "OUTCOME_NOT_REPORTED",
    "OUTCOME_REASON_MAX",
    "OUTCOME_REOPENED",
    "build_run_report",
    "clear_agent_report",
    "consume_note",
    "persist_agent_report",
    "PRODUCING_OPS",
    "producing_run",
    "run_is_dry_run",
    "vibe_output_version_id",
]
