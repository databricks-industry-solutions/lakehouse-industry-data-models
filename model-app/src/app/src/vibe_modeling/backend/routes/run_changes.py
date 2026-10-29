"""Run change review routes: list a vibe run's changes, accept or reject each,
and optionally turn the rejections into feedback items.

Hidden behind ``AppConfig.run_change_review_enabled`` (off by default): every
route on ``router`` answers 404 while it is off, and the router stays mounted.
``config_router`` holds the one ungated status route the UI reads to decide
whether to show the review.

The list is open to every role, like the other run reads; the two writes are
``ModelerOnly``. Logic lives in ``backend/run_changes.py``. Both 409s carry
``error`` (``changes_unavailable`` with a ``reason``, or ``decisions_closed``)
and a ``message``.
"""

from __future__ import annotations

from fastapi import APIRouter, Depends, HTTPException

from ..._metadata import api_prefix
from ..core import Dependencies
from ..core._features import require_installed
from ..models import RunChangeDecisionsIn, RunChangeReviewConfigOut, RunChangesOut
from ..router import get_run_in_business
from ..run_changes import (
    ChangesUnavailable,
    DecisionsClosed,
    UnknownChanges,
    add_rejected_as_feedback,
    build_run_changes,
    set_run_change_decisions,
)

NOT_ENABLED_DETAIL = "Run change review is not enabled in this installation."

require_run_change_review_enabled = require_installed("run_change_review_enabled", NOT_ENABLED_DETAIL)

config_router = APIRouter(prefix=api_prefix)
router = APIRouter(prefix=api_prefix, dependencies=[Depends(require_run_change_review_enabled)])

_CLOSED_MESSAGE = (
    "A newer model run has started from this run's version, so its change decisions are final."
)


@config_router.get(
    "/config/run-change-review",
    response_model=RunChangeReviewConfigOut,
    operation_id="getRunChangeReviewConfig",
)
def get_run_change_review_config(config: Dependencies.Config):
    """Whether the run change review is on; every role reads it."""
    return RunChangeReviewConfigOut(enabled=bool(config.run_change_review_enabled))


def _unavailable(exc: ChangesUnavailable) -> HTTPException:
    return HTTPException(
        status_code=409,
        detail={"error": "changes_unavailable", "reason": exc.reason, "message": exc.message},
    )


@router.get(
    "/businesses/{business_id}/runs/{run_id}/changes",
    response_model=RunChangesOut,
    operation_id="getRunChanges",
)
def get_run_changes(
    business_id: str, run_id: str, session: Dependencies.Session, ws: Dependencies.Client,
):
    """The changes between the run's base and output version, each with its
    hint and decision. 404 when the run is not in the business; 409
    ``changes_unavailable`` when the run has no vibe output or a model cannot
    be loaded."""
    run = get_run_in_business(session, business_id, run_id)
    try:
        return build_run_changes(session, ws, run)
    except ChangesUnavailable as exc:
        raise _unavailable(exc) from exc


@router.put(
    "/businesses/{business_id}/runs/{run_id}/changes/decisions",
    response_model=RunChangesOut,
    operation_id="setRunChangeDecisions",
)
def put_run_change_decisions(
    business_id: str,
    run_id: str,
    data: RunChangeDecisionsIn,
    session: Dependencies.Session,
    ws: Dependencies.Client,
    user_id: Dependencies.UserIdentity,
    _role: Dependencies.ModelerOnly,
):
    """Accept or reject changes; a later decision on the same change replaces
    the earlier one. 409 ``decisions_closed`` once a newer model run started
    from the output version (see ``run_changes.decisions_open``); 422 for a change the run did not make. A refused request
    writes nothing."""
    run = get_run_in_business(session, business_id, run_id)
    try:
        return set_run_change_decisions(session, ws, run, data.decisions, user_id)
    except ChangesUnavailable as exc:
        raise _unavailable(exc) from exc
    except DecisionsClosed as exc:
        raise HTTPException(
            status_code=409, detail={"error": "decisions_closed", "message": _CLOSED_MESSAGE},
        ) from exc
    except UnknownChanges as exc:
        raise HTTPException(
            status_code=422,
            detail={
                "error": "unknown_change",
                "message": "This run did not make some of these changes.",
                "changes": [{"element_kind": k, "element_path": p} for k, p in exc.keys],
            },
        ) from exc


@router.post(
    "/businesses/{business_id}/runs/{run_id}/changes/rejected-feedback",
    response_model=RunChangesOut,
    operation_id="addRejectedChangesAsFeedback",
)
def post_rejected_changes_as_feedback(
    business_id: str,
    run_id: str,
    session: Dependencies.Session,
    ws: Dependencies.Client,
    user_id: Dependencies.UserIdentity,
    _role: Dependencies.ModelerOnly,
):
    """One feedback item per rejected change that has none yet, anchored on
    the element in the output version and not selected for a run. 409
    ``decisions_closed`` once a newer model run started from the output version."""
    run = get_run_in_business(session, business_id, run_id)
    try:
        return add_rejected_as_feedback(session, ws, run, user_id)
    except ChangesUnavailable as exc:
        raise _unavailable(exc) from exc
    except DecisionsClosed as exc:
        raise HTTPException(
            status_code=409, detail={"error": "decisions_closed", "message": _CLOSED_MESSAGE},
        ) from exc
