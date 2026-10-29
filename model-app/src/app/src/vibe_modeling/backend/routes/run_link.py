"""Link an imported version to the Databricks run that produced it.

``previewLinkRun`` verifies the match and writes nothing; ``linkRun`` verifies
again and records the run. Both are BusinessAdminOnly. Logic lives in
``backend/run_link.py``. A refused link answers ``{error: "link_refused",
message, problems}``: 409 when the version or the Databricks run is already
recorded, else 422.
"""

from __future__ import annotations

from fastapi import APIRouter, HTTPException

from ..._metadata import api_prefix
from ..core import Dependencies
from ..db_models import Business
from ..models import LinkRunIn, LinkRunPreviewOut, RunOut
from ..run_link import LinkRefused, link, preview_link
from ._helpers import _build_run_out
from .versions import get_model_version_in_business

router = APIRouter(prefix=api_prefix)


def _business(session, business_id: str) -> Business:
    business = session.get(Business, business_id)
    if business is None:
        raise HTTPException(status_code=404, detail="Business not found")
    return business


@router.post(
    "/businesses/{business_id}/versions/{version_id}/link-run/preview",
    response_model=LinkRunPreviewOut,
    operation_id="previewLinkRun",
)
def preview_link_run(
    business_id: str,
    version_id: str,
    data: LinkRunIn,
    session: Dependencies.Session,
    ws: Dependencies.Client,
    _role: Dependencies.BusinessAdminOnly,
):
    """Whether the Databricks run produced this imported version: the tier
    that matched, the intent it would be recorded with, the evidence, and the
    reasons it cannot be linked. Writes nothing."""
    business = _business(session, business_id)
    mv = get_model_version_in_business(session, business_id, version_id)
    return preview_link(session, ws, business, mv, data.databricks_run_id).out()


@router.post(
    "/businesses/{business_id}/versions/{version_id}/link-run",
    response_model=RunOut,
    operation_id="linkRun",
)
def link_run(
    business_id: str,
    version_id: str,
    data: LinkRunIn,
    session: Dependencies.Session,
    ws: Dependencies.Client,
    _role: Dependencies.BusinessAdminOnly,
):
    """Record the Databricks run as the run that produced this imported
    version (a completed run with ``linked_at`` and ``link_evidence``). 409
    when the business has an active run or another request holds it."""
    business = _business(session, business_id)
    mv = get_model_version_in_business(session, business_id, version_id)
    try:
        run = link(session, ws, business, mv, data.databricks_run_id)
    except LinkRefused as exc:
        raise HTTPException(
            status_code=exc.status,
            detail={"error": "link_refused", "message": " ".join(exc.problems), "problems": exc.problems},
        ) from exc
    return _build_run_out(run, ws, session)
