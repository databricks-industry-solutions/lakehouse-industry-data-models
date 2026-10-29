"""Run report routes: what a run did with the feedback it sent.

Read-only views over the rows ``run_report.persist_agent_report`` writes
(``run_agent_reports`` and ``run_input_links.outcome_*``), assembled by
``run_report.build_run_report``. Open to every role, like the other run and
version reads.
"""

from __future__ import annotations

from fastapi import APIRouter

from ..._metadata import api_prefix
from ..core import Dependencies
from ..models import RunReportOut, VersionReportOut
from ..router import get_run_in_business
from ..run_report import build_run_report, producing_run
from .versions import get_model_version_in_business

router = APIRouter(prefix=api_prefix)


@router.get(
    "/businesses/{business_id}/runs/{run_id}/report",
    response_model=RunReportOut,
    operation_id="getRunReport",
)
def get_run_report(business_id: str, run_id: str, session: Dependencies.Session):
    """The run's per-feedback report: each input it sent with the agent's
    outcome and the input's state now, plus why inputs were or were not
    marked done (``consume_note``). 404 when the run is not in the business."""
    run = get_run_in_business(session, business_id, run_id)
    return build_run_report(session, run)


@router.get(
    "/businesses/{business_id}/versions/{version_id}/report",
    response_model=VersionReportOut,
    operation_id="getVersionReport",
)
def get_version_report(business_id: str, version_id: str, session: Dependencies.Session):
    """The report of the run that produced the version (its vibe, or the
    shrink / enlarge step of a unified run); ``report`` is null when no run
    produced it. 404 when the version is not in the
    business."""
    mv = get_model_version_in_business(session, business_id, version_id)
    run = producing_run(session, mv.id)
    return VersionReportOut(
        version_id=mv.id,
        report=build_run_report(session, run) if run is not None else None,
    )
