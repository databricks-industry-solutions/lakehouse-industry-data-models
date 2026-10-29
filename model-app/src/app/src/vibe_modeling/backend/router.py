"""API routes for the Vibe Modeling control plane — runs surface.

Plan task #33 split the per-resource endpoints into `routes/<area>.py`
modules. This file deliberately keeps the `/runs/...` endpoints in place
because Phase 4 of the orchestrator refactor (collaborator branch
`mwissad/dev`) is rewriting them and we don't want to fight a merge over
identical lines moving in two directions.

The module also re-exports a handful of helpers (`launch_run`, …) so
existing tests that monkey-patch them via
`vibe_modeling.backend.router.<name>` keep working unchanged.
"""

import json
import logging
import re
from datetime import datetime, timezone
from typing import Literal, Optional

from fastapi import HTTPException, Query
from fastapi.responses import StreamingResponse
from sqlmodel import select

logger = logging.getLogger(__name__)

from ._artifact_io import (
    build_artifact_content_response,
    build_artifact_download_response,
    build_artifacts_zip_bytes,
)
from .core import (
    Dependencies,
    create_router,
    resolve_run_target_catalog,
)
from .error_sanitization import recorded_error_text, sanitize_error_message
from .db_models import (
    AgentConfig,
    ModelVersion,
    Run,
    RunArtifact,
    RunInputLink,
    RunNextVibeLink,
    RunOperation,
    RunProgressEvent,
)
from .job_launcher import (
    generate_session_id,
    job_tags_for_config,
    launch_run,
    map_run_params_to_widgets,
    finalize_widgets_or_raise,
    plan_widget_payload,
    WidgetPayloadTooLargeError,
    session_id_to_bigint,
)
from .models import (
    RETIRED_INTENTS,
    RUN_CONVENTION_FIELDS,
    CancelOpAppliedOut,
    CancelOpFailureOut,
    CancelWithRollbackOut,
    HealthOut,
    Intent,
    IssueOut,
    ProgressEventOut,
    ResumeRunOut,
    RunArtifactOut,
    RunIn,
    RunLineageOut,
    RunLineageVersionOut,
    RunListOut,
    RunOperationOut,
    RunOut,
    ValidateRunOut,
)
from .routes._helpers import (
    _build_run_out,
    _get_agent_config,
    _get_or_create_agent_config,
    params_json_omit_deployment_catalog_for_multi_catalog,
    resolve_warehouse_id,
)
from .services.orchestrator import Dag, OperationStep
from .services.orchestrator.preflight import _VERSION_BOUND_INTENTS, Preflight, run_preflight
from .services.operations._version_lifecycle import run_requests_post_install_delete
from .core._intents import AGENT_OP_NEW_BASE_MODEL, INTENT_TO_AGENT_OP
from .services.orphan_schemas import ORPHAN_DROP_INTENT, RETRY_REFUSED as ORPHAN_RETRY_REFUSED
from .core._roles import require_business_admin
from .core._runs import count_in_flight_runs, lock_business_for_run
from .core._widgets import refresh_stored_widgets
from .runtime_budget import (
    RUNTIME_BUDGET_HOURS_KEY,
    resolve_runtime_budget_hours,
    runtime_budget_seconds,
    stored_runtime_budget_hours,
)


router = create_router()


def _stored_included_input_ids(stored) -> list[str]:
    """Read the sent input ids back from a ``Run.parameters_json`` dict, falling
    back to ``input_ids`` for runs launched before ``included_input_ids`` was
    recorded."""
    if not isinstance(stored, dict):
        return []
    ids = stored.get("included_input_ids")
    if ids is None:
        ids = stored.get("input_ids")
    return list(ids or [])


def _persist_run_input_links(session, run_id, input_ids) -> None:
    """Write the intended-selection ``RunInputLink`` rows at launch (immutable
    usage audit; ``consumed`` flips only on successful completion). Idempotent
    against the composite PK."""
    if not input_ids:
        return
    for iid in input_ids:
        existing = session.get(RunInputLink, (run_id, iid))
        if existing is None:
            session.add(RunInputLink(run_id=run_id, input_id=iid))


def get_run_in_business(session, business_id: str, run_id: str) -> Run:
    """Load a ``Run`` by id and assert it belongs to ``business_id``.

    Raises ``HTTPException(404, "Run not found")`` when:
      * no row exists for ``run_id``, or
      * the row exists but its ``business_id`` does not match.

    Both cases collapse to 404 (not 403) so the API does not leak the
    existence of runs across businesses — a caller probing
    ``/businesses/{wrong}/runs/{rid}`` should see the same response as
    if ``rid`` did not exist at all.
    """
    run = session.get(Run, run_id)
    if not run or run.business_id != business_id:
        raise HTTPException(status_code=404, detail="Run not found")
    return run


# --- Orchestrator-driven create_run helpers (Phase 4 — #29) ---


def _create_run_via_orchestrator(
    *,
    business_id: str,
    data: RunIn,
    agent_config,
    intent: Intent,
    preflight: Preflight,
    session,
    ws,
    tracker,
) -> RunOut:
    """Persist a simple-intent run and hand its DAG to the orchestrator.

    ``preflight`` passed: it carries the validated single-step DAG (built
    from the parent ``ModelVersion`` it resolved), the compiled inputs and
    the next-vibe selections. Side-effects, under the route's session and
    committed at the end:

    1. Level 3 of the pre-flight (``preflight.prepare``), right before the
       Run row.
    2. Insert the ``Run`` row + the ``RunOperation`` row(s),
       pre-populating ``parent_version_id`` so the orchestrator's
       dispatch step doesn't have to re-derive it from prior steps
       (single-step DAGs have no priors to inherit from).
    3. Call ``tracker.orchestrator.start(run, dag, session)`` which
       dispatches step 0 via the registered ``Operation`` and stamps
       ``run.status = "running"``.

    Returns the ``RunOut`` with the pre-flight's warnings.
    """
    dag = preflight.dag
    parent_mv = preflight.parent_mv
    included_input_ids = preflight.included_input_ids(data)
    preflight.prepare(ws)

    # Persist the Run row. The ``parameters_json`` blob is the
    # user-submitted form values per spec §5.1, with the run time budget
    # replaced by the resolved hours (budgeted intents) or removed
    # (install, uninstall); the orchestrator never mutates it.
    # ``included_input_ids`` records which of ``input_ids`` the compile
    # actually sent (retry re-links it).
    snapshot = _run_parameters_snapshot(data)
    snapshot.pop(RUNTIME_BUDGET_HOURS_KEY, None)
    if intent.value in _BUDGETED_INTENTS:
        snapshot[RUNTIME_BUDGET_HOURS_KEY] = resolve_runtime_budget_hours(
            data.runtime_budget_hours, agent_config
        )
    run = Run(
        business_id=business_id,
        version_id=data.version_id,
        intent=intent.value,
        status="pending",
        parameters_json=json.dumps({
            **snapshot,
            "included_input_ids": included_input_ids,
        }),
        vibe_instructions_text=(data.vibe_instructions or ""),
        business_context_text=(data.business_context_text or "").strip(),
    )
    session.add(run)
    session.flush()

    # The selected inputs ARE this run's inputs: link them to THIS run so the
    # success-finalize consumes exactly them (the legacy launch paths do the
    # same). Emitted next_vibes are element-linked at generation, never linked
    # to their generating run, so they are not swept in here. Only the ids the
    # compile sent are linked; excluded (out-of-scope, deprecated) items stay open.
    _persist_run_input_links(session, run.id, included_input_ids)
    for nv in preflight.selected_next_vibes:
        session.add(RunNextVibeLink(run_id=run.id, next_vibe_id=nv.id))

    # Pre-create the ``RunOperation`` row(s) so we can stamp
    #    ``parent_version_id`` before the orchestrator dispatches.
    #    ``Orchestrator.start`` is idempotent w.r.t. existing rows —
    #    it sees our pre-persisted row, skips the persistence loop,
    #    and proceeds straight to dispatch. This keeps the
    #    parent-version wiring out of the factory's params dict
    #    (where it would fail validation against every primitive's
    #    ``params_model``).
    parent_version_id = parent_mv.id if parent_mv is not None else None
    for i, step in enumerate(dag.steps):
        from .db_models import RunOperation

        row = RunOperation(
            run_id=run.id,
            step_index=i,
            operation_name=step.name,
            params_json=json.dumps(step.params),
            skip_if=step.skip_if or "",
            status="pending",
            # A step that names its version (the uninstall of an occupying
            # version) acts on that one.
            parent_version_id=step.params.get("version_id") or parent_version_id,
        )
        session.add(row)
    session.flush()

    # Hand off to the orchestrator. ``start`` re-dispatches the
    #    first pending row; on dispatch failure the row is marked
    #    ``failed`` and the run terminal envelope reflects that —
    #    we still return RunOut so the UI sees the failed run row.
    #
    #    The orchestrator may not be wired through the test tracker
    #    (the unit-test ``mock_tracker`` is a bare ``MagicMock`` that
    #    never starts the real run). In that case we still want the
    #    Run + RunOperation rows to land so contract tests can read
    #    them back, so we treat any tracker failure as a non-fatal
    #    smoke. The legacy launch branch below wraps ``launch_run``
    #    in the same way.
    try:
        tracker.orchestrator.start(run, dag, session)
    except Exception:  # noqa: BLE001 — tracker errors must not lose the row
        logger.exception("orchestrator.start failed for run=%s", run.id)
    session.commit()
    session.refresh(run)

    # Mirror the legacy launch path's tracker-start hook so the poll
    # loop picks up this run on the next tick.
    if run.status == "running":
        try:
            tracker.start_tracking(run.id)
        except Exception:  # noqa: BLE001 — non-fatal
            logger.exception("tracker.start_tracking failed for run=%s", run.id)

    return _build_run_out(run, ws, session, warnings=_warning_dicts(preflight))


def _warning_dicts(preflight: Preflight) -> list[dict]:
    """``RunOut.warnings``: the pre-flight's warnings, as validate returned them."""
    return [w.model_dump() for w in preflight.warnings]


def _run_parameters_snapshot(data: RunIn) -> dict:
    """Serialise the user-submitted ``RunIn`` body for
    ``Run.parameters_json``.

    Per spec §5.1, the orchestrator narrows ``parameters_json`` to "the
    user's submitted form values" — the orchestrator no longer mutates
    it during execution. The legacy fallback (the existing
    ``router.create_run`` branch below) writes a widget-derived blob;
    here we just dump the pydantic model so the audit trail captures
    exactly what the caller submitted.
    """
    try:
        snapshot = data.model_dump(mode="json")
    except Exception:  # noqa: BLE001 — pydantic v1 fallback
        snapshot = data.dict()  # type: ignore[attr-defined]
    # Accepted but never sent to the agent, so the audit leaves it out.
    snapshot.pop("generate_samples", None)
    # RunIn carries ``deployment_catalog`` as a deprecated alias for
    # ``catalog``. In multi-catalog styles the agent derives per-scope
    # catalogs and ignores this field, so strip it from the audit
    # snapshot to match the other parameters_json sites.
    return params_json_omit_deployment_catalog_for_multi_catalog(
        snapshot, snapshot.get("cataloging_style")
    )


def _convention_params_snapshot(data: RunIn) -> dict:
    """The request's non-empty Advanced Options, for ``Run.parameters_json``
    of the two-step runs, so "What you submitted" shows what was sent. The
    DAG factories read the same fields off ``data``."""
    out: dict[str, str] = {}
    for field in RUN_CONVENTION_FIELDS:
        value = (getattr(data, field, None) or "").strip()
        if value:
            out[field] = value
    return out


def _create_new_base_model_run_via_orchestrator(
    *,
    business_id: str,
    data,
    agent_config,
    preflight: Preflight,
    session,
    ws,
    tracker,
):
    """Persist a ``new-base-model`` Run row for the pre-flight's validated
    DAG and call ``orchestrator.start`` (spec §2.4.1 + §4).

    Returns the standard :class:`RunOut` shape so the route handler is a
    transparent passthrough — the UI does not need to know whether a
    given run flowed through the orchestrator or the legacy path.
    """
    # Every check has passed: set up a missing `_metamodel` now (level 3),
    # before the Run row and before step-0 dispatch can spill ``model_vibes``
    # into ``vol_root``. ``ws`` is the App service principal client
    # (``Dependencies.Client``), so the grants the error asks for are the SP's.
    preflight.prepare(ws)

    # Persist a Run row. ``intent`` is the durable label (spec §5.1).
    sid = generate_session_id()
    sid_bigint = session_id_to_bigint(sid)

    # The DAG factory snapshots the user's submitted form values into
    # each step's params. Mirror them onto ``Run.parameters_json`` so
    # the UI's lineage / artifacts pages keep their reference shape.
    style = (data.cataloging_style or "One Catalog").strip() or "One Catalog"
    default_ecm_prefix = "ecm_" if style == "One Catalog" else ""
    default_mvm_prefix = "mvm_" if style == "One Catalog" else ""
    ecm_prefix = (
        data.ecm_schema_prefix
        if data.ecm_schema_prefix is not None
        else default_ecm_prefix
    )
    mvm_prefix = (
        data.mvm_schema_prefix
        if data.mvm_schema_prefix is not None
        else default_mvm_prefix
    )
    stored_params: dict[str, object] = {
        "intent": preflight.dag.intent,
        "cataloging_style": style,
        "deployment_catalog": resolve_run_target_catalog(data, agent_config),
        "ecm_schema_prefix": ecm_prefix,
        "mvm_schema_prefix": mvm_prefix,
        "schema_prefix": ecm_prefix,
        # Both agent jobs (ECM, then shrink) read it through inherited_params.
        RUNTIME_BUDGET_HOURS_KEY: resolve_runtime_budget_hours(
            data.runtime_budget_hours, agent_config
        ),
    }
    params_json_omit_deployment_catalog_for_multi_catalog(stored_params, style)
    stored_params.update(_convention_params_snapshot(data))

    run = Run(
        business_id=business_id,
        intent=preflight.dag.intent,
        status="pending",
        vibe_session_id=sid,
        vibe_session_id_bigint=sid_bigint,
        parameters_json=json.dumps(stored_params),
        vibe_instructions_text=(data.vibe_instructions or ""),
        business_context_text=(data.business_context_text or "").strip(),
    )
    session.add(run)
    session.commit()
    session.refresh(run)

    # Hand off to the orchestrator — persists RunOperation rows, sets
    # ``run.intent`` (already set above; idempotent) and dispatches step
    # 0. The orchestrator owns ``run.status`` from here on; tracker
    # picks up polling once started.
    try:
        tracker.orchestrator.start(run, preflight.dag, session)
        session.commit()
        session.refresh(run)
    except Exception as e:
        # Wiring audit (router orchestrator start failure):
        #   Previous: direct run.status / run.completed_at writes.
        #   New: transition_run stamps all five layers atomically.
        from .run_state_transitions import transition_run
        reason = f"Orchestrator failed to start: {recorded_error_text(e, 'Orchestrator start', str(e))}"
        run.error_message = reason
        session.add(run)
        transition_run(session, run, target_status="failed", reason=reason)
        session.commit()
        session.refresh(run)
        return _build_run_out(run, ws, session, warnings=_warning_dicts(preflight))

    if run.status == "running":
        tracker.start_tracking(run.id)

    return _build_run_out(run, ws, session, warnings=_warning_dicts(preflight))


def _create_vibe_new_ecm_mvm_run_via_orchestrator(
    *,
    business_id: str,
    data,
    agent_config,
    preflight: Preflight,
    session,
    ws,
    tracker,
):
    """Persist a ``vibe-new-ecm-mvm`` Run + per-step RunOperation rows for
    the pre-flight's validated DAG, with ``parent_version_id`` stamped on the
    leading step, and hand off to the orchestrator.

    Mirrors :func:`_create_new_base_model_run_via_orchestrator`; the parent
    ECM is the pre-flight's ``parent_mv`` (its scope gate refused a missing
    or MVM parent), so the orchestrator threads it through every step's
    :class:`OperationContext`.
    """
    from .db_models import RunOperation

    # The pre-flight resolved the parent ECM (and refused a missing or MVM
    # one), validated the next-vibe selections against it, compiled the
    # selected Vibe Inputs into ``data.vibe_instructions`` and validated the
    # DAG. Level 3 runs right before the Run row.
    parent_mv = preflight.parent_mv
    selected_next_vibes = preflight.selected_next_vibes
    included_input_ids = preflight.included_input_ids(data)
    preflight.prepare(ws)

    sid = generate_session_id()
    sid_bigint = session_id_to_bigint(sid)

    # Snapshot the user-submitted form values for the audit trail.
    style = (data.cataloging_style or "One Catalog").strip() or "One Catalog"
    default_ecm_prefix = "ecm_" if style == "One Catalog" else ""
    default_mvm_prefix = "mvm_" if style == "One Catalog" else ""
    ecm_prefix = (
        data.ecm_schema_prefix
        if data.ecm_schema_prefix is not None
        else default_ecm_prefix
    )
    mvm_prefix = (
        data.mvm_schema_prefix
        if data.mvm_schema_prefix is not None
        else default_mvm_prefix
    )
    stored_params = {
        "intent": preflight.dag.intent,
        "cataloging_style": style,
        "deployment_catalog": resolve_run_target_catalog(data, agent_config),
        "ecm_schema_prefix": ecm_prefix,
        "mvm_schema_prefix": mvm_prefix,
        "schema_prefix": ecm_prefix,
        "parent_version_id": parent_mv.id,
        "input_ids": list(data.input_ids or []),
        "included_input_ids": included_input_ids,
        # Both agent jobs (vibe iterate, then shrink) read it through
        # inherited_params.
        RUNTIME_BUDGET_HOURS_KEY: resolve_runtime_budget_hours(
            data.runtime_budget_hours, agent_config
        ),
    }
    params_json_omit_deployment_catalog_for_multi_catalog(stored_params, style)
    stored_params.update(_convention_params_snapshot(data))

    run = Run(
        business_id=business_id,
        version_id=parent_mv.id,
        intent=preflight.dag.intent,
        status="pending",
        vibe_session_id=sid,
        vibe_session_id_bigint=sid_bigint,
        parameters_json=json.dumps(stored_params),
        # ``data.vibe_instructions`` was rewritten above to the compiled
        # Vibe Inputs doc; persist it so the audit trail reflects what the
        # agent saw.
        vibe_instructions_text=(data.vibe_instructions or ""),
        business_context_text=(data.business_context_text or "").strip(),
    )
    session.add(run)
    session.commit()
    session.refresh(run)

    # Persist next-vibe link rows for traceability. Links live regardless of
    # whether the downstream orchestrator dispatch succeeds, so the UI can
    # still surface which selections were intended for this attempt.
    for nv in selected_next_vibes:
        session.add(RunNextVibeLink(run_id=run.id, next_vibe_id=nv.id))
    # Vibe Inputs intended-selection audit (consume flips on success only).
    # Only the ids the compile sent are linked.
    _persist_run_input_links(session, run.id, included_input_ids)
    if selected_next_vibes or included_input_ids:
        session.commit()

    # Pre-create RunOperation rows so we can stamp ``parent_version_id``
    # on each step. The orchestrator's resume guard sees these existing
    # rows and skips its own persistence step. ``parent_version_id`` is
    # only meaningful for the leading version-producing step (the
    # ``vibe_iterate`` row); the orchestrator overrides it on subsequent
    # steps via ``needs_version_from``. An uninstall step in front (a
    # source-industry version the run replaces) names its own version.
    for i, step in enumerate(preflight.dag.steps):
        row = RunOperation(
            run_id=run.id,
            step_index=i,
            operation_name=step.name,
            params_json=json.dumps(step.params),
            skip_if=step.skip_if or "",
            status="pending",
            # Only the leading vibe step inherits from the user-supplied
            # parent; the orchestrator threads downstream steps via
            # ``needs_version_from`` when it advances each step.
            parent_version_id=step.params.get("version_id") or (
                parent_mv.id if step.name == "vibe_iterate" else None
            ),
        )
        session.add(row)
    session.commit()

    try:
        tracker.orchestrator.start(run, preflight.dag, session)
        session.commit()
        session.refresh(run)
    except Exception as e:
        from .run_state_transitions import transition_run
        reason = f"Orchestrator failed to start: {recorded_error_text(e, 'Orchestrator start', str(e))}"
        run.error_message = reason
        session.add(run)
        transition_run(session, run, target_status="failed", reason=reason)
        session.commit()
        session.refresh(run)
        return _build_run_out(run, ws, session, warnings=_warning_dicts(preflight))

    if run.status == "running":
        tracker.start_tracking(run.id)

    return _build_run_out(run, ws, session, warnings=_warning_dicts(preflight))


# --- Runs ---

# Intents whose agent jobs generate a model, the only work the agent paces by
# the run time budget. Their runs store ``runtime_budget_hours``; install and
# uninstall runs store none.
_BUDGETED_INTENTS: frozenset[str] = frozenset({
    Intent.NEW_BASE_MODEL.value,
    Intent.VIBE_ITERATE.value,
    Intent.VIBE_NEW_ECM_MVM.value,
})




@router.get("/health", response_model=HealthOut, operation_id="getHealth")
def get_health(session: Dependencies.Session):
    """Liveness + active-run count.

    ``in_flight_runs`` lets the deploy guard (``install/in_flight_guard.sh``)
    refuse to push a new wheel while a run is active. The App no longer
    carries a runtime drain gate — atomic-replace App containers can't
    cleanly hand off in-flight pollers, so blocking new dispatches while
    a deploy is in flight is the deploy script's job, not the App's.
    """
    return HealthOut(ok=True, in_flight_runs=count_in_flight_runs(session))


@router.post(
    "/businesses/{business_id}/runs/validate",
    response_model=ValidateRunOut,
    operation_id="validateRun",
)
def validate_run(
    business_id: str,
    data: RunIn,
    session: Dependencies.Session,
    ws: Dependencies.Client,
    config: Dependencies.Config,
    user: Dependencies.UserIdentity,
):
    """Live form-feedback for the New Run page (spec §2.4 + §2.4.1).

    Same body as ``POST /runs``; returns ``{warnings, blockers}`` from
    the same validator that gates the hard submit. Does NOT create a
    ``Run`` row, write to Lakebase, or launch a job — purely a pure
    function over the request + business + agent config.

    The UI calls this debounced (300ms or onBlur) so impossible field
    combinations surface inline next to the offending field. Submit
    stays disabled while blockers are present.

    ``confirm`` issues (subject-bound, see ``IssueOut.subject``) come back in
    ``warnings``: create refuses with 422 ``needs_confirmation`` until
    ``RunIn.confirmed_issues`` lists every one of their subjects.
    """
    from .db_models import Business

    intent_value = data.intent.value
    if not intent_value:
        # Unknown intent: surface as a single blocker so the form can
        # render it inline. Same shape as the validator emits.
        return ValidateRunOut(
            blockers=[
                IssueOut(
                    field_path="intent",
                    step_index=-1,
                    message=(
                        "Cannot validate request: intent is missing or "
                        "has no DAG factory wired yet."
                    ),
                    severity="blocker",
                )
            ]
        )

    business = session.get(Business, business_id)
    if not business:
        return ValidateRunOut(
            blockers=[
                IssueOut(
                    field_path="business_id",
                    step_index=-1,
                    message=f"Business {business_id!r} not found",
                    severity="blocker",
                )
            ]
        )

    preflight = run_preflight(
        business_id, data, business=business,
        agent_config=session.exec(select(AgentConfig).limit(1)).first(),
        session=session, ws=ws, config=config, user=user, create=False,
    )
    # Only a blocker reads as hard on the form; warnings, ``confirm`` and
    # ``prepare`` issues come back in ``warnings``.
    return ValidateRunOut(
        warnings=[i for i in preflight.issues if i.severity != "blocker"],
        blockers=[i for i in preflight.issues if i.severity == "blocker"],
    )


def _refuse_retired_intent(intent_value: Optional[str]) -> None:
    """422 for retrying or resuming a run of a retired intent (an old row)."""
    if intent_value in {i.value for i in RETIRED_INTENTS}:
        raise HTTPException(status_code=422, detail="This run's type is no longer supported.")


def _refuse_app_only_retry(intent_value: Optional[str]) -> None:
    """422 for retrying or resuming an orphan-schema drop: it has no agent
    job to start again, and the schemas left must be read again first."""
    if intent_value == ORPHAN_DROP_INTENT:
        raise HTTPException(status_code=422, detail=ORPHAN_RETRY_REFUSED)


def _resolve_business_context_override(
    business_id: str, data: RunIn, session
) -> tuple[str, str]:
    """Resolve the ``(business_context_path, business_description_override)``
    pair the LEGACY dispatch branch of ``create_run`` widgets with: inline
    text overrides the ``business_description`` widget, an explicit file path
    goes to the ``context_file`` widget, else fall back to the most recent
    completed base/iterate run's own context path so a re-run doesn't need to
    re-supply it.

    NOTE: the pre-submit description gate
    (:func:`business_description_blocker_for_intent`, called from
    :func:`services.orchestrator.preflight.run_preflight`) deliberately does NOT call this
    helper - it only honours ``data.business_context_text`` /
    ``data.business_context_path`` directly, not the last-completed-run
    fallback below. This is a conservative simplification, not a proven
    equivalence: a business whose only prior successful run relied on that
    fallback (description perpetually blank, always dispatched via an
    inherited context file) could see the gate block a resubmission the
    actual dispatch would still let through. Accepted for now because the
    gate errs toward over-blocking (an inline blocker the user can dismiss
    by re-typing the description) rather than under-blocking (a wasted
    minute of agent compute) - revisit if that edge case turns out to be
    common in practice.
    """
    business_context_path = data.business_context_path
    business_description_override = ""
    if data.business_context_text.strip():
        # Inline text: pass as business_description widget (the monolith
        # builds its full context from business_name + business_description
        # when no context_file is provided).
        business_description_override = data.business_context_text.strip()
    if not business_context_path:
        last_run = session.exec(
            select(Run)
            .where(
                Run.business_id == business_id,
                Run.status == "completed",
                Run.intent.in_([Intent.NEW_BASE_MODEL.value, Intent.VIBE_ITERATE.value]),
            )
            .order_by(Run.completed_at.desc())
        ).first()
        if last_run and last_run.parameters_json:
            try:
                prev_params = json.loads(last_run.parameters_json)
                business_context_path = prev_params.get("business_context", "") or prev_params.get("context_file", "")
            except (json.JSONDecodeError, TypeError):
                pass
    return business_context_path, business_description_override


@router.get(
    "/businesses/{business_id}/runs/{run_id}/operations",
    response_model=list[RunOperationOut],
    operation_id="listRunOperations",
)
def list_run_operations(
    business_id: str,
    run_id: str,
    session: Dependencies.Session,
    ws: Dependencies.Client,
):
    """List the persisted DAG steps for a run (spec §5.2 + §8).

    The UI reads this to render the "what step are we on" pipeline on
    the run-detail page — augments / replaces the legacy progress
    pipeline once a run has at least one ``RunOperation`` row.

    Returns the rows ordered by ``step_index`` ascending.

    ``run_page_url`` is built per-phase from the phase's own
    ``databricks_run_id`` — each Phase dispatches its own job run, so
    the link belongs at the phase level, not the run level.
    """
    from .db_models import RunOperation
    from .routes._helpers import _build_dbx_run_url

    run = get_run_in_business(session, business_id, run_id)

    rows = session.exec(
        select(RunOperation)
        .where(RunOperation.run_id == run_id)
        .order_by(RunOperation.step_index)
    ).all()

    # Resolve natural-key (version, scope, business_id) for each
    # ``output_version_id`` in one batched lookup so the "→ v1 ECM"
    # affordance on the Phase row is human-meaningful + navigable
    # instead of a dead "#/model-versions/{uuid}" hash anchor (#49).
    version_ids = [r.output_version_id for r in rows if r.output_version_id]
    version_map: dict[str, ModelVersion] = {}
    if version_ids:
        mvs = session.exec(
            select(ModelVersion).where(ModelVersion.id.in_(version_ids))
        ).all()
        version_map = {mv.id: mv for mv in mvs}

    out: list[RunOperationOut] = []
    for r in rows:
        label: Optional[str] = None
        url: Optional[str] = None
        if r.output_version_id and r.output_version_id in version_map:
            mv = version_map[r.output_version_id]
            scope = (mv.scope or "").strip()
            scope_upper = scope.upper() if scope else ""
            label = f"v{mv.version} {scope_upper}".strip()
            # No ?tab=overview — let the route default to the overview
            # tab. Mirrors the canonical model-version URL used in
            # LineageCard / sidebar chips.
            url = f"/businesses/{mv.business_id}/model/{mv.version}/{scope}"
        out.append(
            RunOperationOut(
                id=r.id,
                run_id=r.run_id,
                step_index=r.step_index,
                operation_name=r.operation_name,
                status=r.status,
                databricks_run_id=r.databricks_run_id,
                run_page_url=_build_dbx_run_url(r.databricks_run_id, ws, session, app_job=run.linked_at is None),
                parent_version_id=r.parent_version_id,
                output_version_id=r.output_version_id,
                output_version_label=label,
                output_version_url=url,
                error_message=r.error_message,
                started_at=r.started_at,
                completed_at=r.completed_at,
                created_at=r.created_at,
                dispatched_widgets=(
                    json.loads(r.dispatched_widgets_json)
                    if r.dispatched_widgets_json
                    else {}
                ),
            )
        )
    return out


@router.post(
    "/businesses/{business_id}/runs",
    response_model=RunOut,
    operation_id="createRun",
)
def create_run(
    business_id: str,
    data: RunIn,
    session: Dependencies.Session,
    ws: Dependencies.Client,
    config: Dependencies.Config,
    tracker: Dependencies.Tracker,
    _role: Dependencies.ModelerOnly,
    user: Dependencies.UserIdentity,
):
    """Create a run record and trigger the Databricks job.

    Phase 4 (#29): runs whose ``intent == "new-base-model"`` are routed
    through :class:`Orchestrator.start` against the DAG produced by
    :func:`dag_for_new_base_model`. Other intents fall through to the
    legacy single-job launch until the simple/recovery wirers replace
    them.
    """
    from .db_models import Business

    intent_value = data.intent.value

    business = session.get(Business, business_id)
    if not business:
        raise HTTPException(status_code=404, detail="Business not found")

    # Deleting the replaced versions after the install is a delete: the same
    # role as ``deleteVersion``.
    if data.also_delete_replaced:
        require_business_admin(_role)

    # Before the pre-flight takes the business lock: creating a missing row
    # commits, and a commit releases the lock.
    agent_config = _get_or_create_agent_config(session, config)
    # The pre-flight ``POST /runs/validate`` runs: the first blocker refuses
    # with its status, then 422 ``needs_confirmation``. Nothing outside
    # Lakebase is written before this passes (level 3 runs in the branches,
    # right before their Run row). From its level 2 on, the business lock is
    # held: nothing below commits before the Run row is written.
    preflight = run_preflight(
        business_id, data, business=business, agent_config=agent_config,
        session=session, ws=ws, config=config, user=user, create=True,
    )
    preflight.raise_refusal(data)

    # ------------------------------------------------------------------
    # Orchestrator branches: the pre-flight built and validated the DAG of
    # ``new-base-model``, ``vibe-new-ecm-mvm`` and of a simple intent
    # (vibe-iterate, install, uninstall) with a resolved version. Anything
    # else takes the legacy single-job launch below.
    # ------------------------------------------------------------------
    if intent_value == Intent.NEW_BASE_MODEL.value:
        return _create_new_base_model_run_via_orchestrator(
            business_id=business_id,
            data=data,
            agent_config=agent_config,
            preflight=preflight,
            session=session,
            ws=ws,
            tracker=tracker,
        )

    if intent_value == Intent.VIBE_NEW_ECM_MVM.value:
        return _create_vibe_new_ecm_mvm_run_via_orchestrator(
            business_id=business_id,
            data=data,
            agent_config=agent_config,
            preflight=preflight,
            session=session,
            ws=ws,
            tracker=tracker,
        )

    if preflight.dag is not None:
        return _create_run_via_orchestrator(
            business_id=business_id,
            data=data,
            agent_config=agent_config,
            intent=data.intent,
            preflight=preflight,
            session=session,
            ws=ws,
            tracker=tracker,
        )

    business_context_path, business_description_override = (
        _resolve_business_context_override(business_id, data, session)
    )

    # The version this run operates on, resolved by the pre-flight (which
    # refuses a version-bound intent without one). The agent's
    # `model_version` widget (human-facing integer like "1" / "2") tells
    # it which model.json to load off Volumes. For base-model runs
    # version_id stays None until the run completes.
    version_id = data.version_id
    base_version_int: Optional[int] = None
    if intent_value in _VERSION_BOUND_INTENTS and preflight.parent_mv is not None:
        version_id = preflight.parent_mv.id
        base_version_int = preflight.parent_mv.version

    # Generate session ID
    sid = generate_session_id()
    sid_bigint = session_id_to_bigint(sid)

    # Map parameters to widget values, passing any convention overrides
    _convention_fields = [
        "naming_convention", "primary_key_suffix", "schema_prefix", "schema_suffix",
        "tag_prefix", "tag_suffix", "table_id_type", "boolean_format", "date_format",
        "timestamp_format", "cataloging_style", "catalog_prefix", "catalog_suffix",
        "org_divisions", "business_domains", "classification_levels",
        "housekeeping_columns", "history_tracking_columns",
    ]
    convention_overrides = {
        f: getattr(data, f) for f in _convention_fields if getattr(data, f) is not None
    }

    # The pre-flight validated the next-vibe selections and compiled the
    # selected Vibe Inputs into ``data.vibe_instructions``.
    selected_next_vibes = preflight.selected_next_vibes
    included_input_ids = preflight.included_input_ids(data)
    vibe_instructions = data.vibe_instructions

    # Vibe files live under the run's _metamodel/vol_root, so the upload target
    # is the run's target catalog (explicit form catalog, else the configured
    # metamodel catalog) - the same value the run dispatches with.
    upload_catalog = resolve_run_target_catalog(data, agent_config)

    # New-base-model is the unified ECM → shrink-to-MVM pipeline. Force
    # "large model" here regardless of what the client sent so the
    # orchestrator's DAG sees a consistent input.
    effective_model_size = (
        "large model"
        if intent_value == Intent.NEW_BASE_MODEL.value
        else data.model_size
    )

    agent_op = INTENT_TO_AGENT_OP.get(intent_value, AGENT_OP_NEW_BASE_MODEL)
    budget_hours = resolve_runtime_budget_hours(data.runtime_budget_hours, agent_config)
    widgets = map_run_params_to_widgets(
        operation=agent_op,
        business=business,
        catalog=data.catalog,
        session_id=sid,
        runtime_budget_seconds=runtime_budget_seconds(budget_hours),
        vibe_instructions=vibe_instructions,
        model_size=effective_model_size,
        business_context_path=business_context_path,
        business_description_override=business_description_override,
        model_version=str(base_version_int) if base_version_int is not None else "",
        **convention_overrides,
    )

    # A map too large to send is refused before level 3 writes anything;
    # then level 3 (the vibe file below goes to vol_root).
    try:
        plan_widget_payload(
            widgets, catalog=upload_catalog, business_name=business.name,
            session_id=sid, raw_vibes=vibe_instructions,
        )
    except WidgetPayloadTooLargeError as e:
        raise HTTPException(status_code=400, detail=str(e))
    preflight.prepare(ws)

    try:
        widgets = finalize_widgets_or_raise(
            ws,
            widgets,
            catalog=upload_catalog,
            business_name=business.name,
            session_id=sid,
            raw_vibes=vibe_instructions,
        )
    except WidgetPayloadTooLargeError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except Exception:
        raise HTTPException(
            status_code=502,
            detail=(
                "Could not stage vibe instructions on the target Volume. "
                "Confirm the app's service principal has WRITE FILES on "
                f"`{upload_catalog}._metamodel.vol_root`."
            ),
        )
    vibe_instructions_volume_path = (
        widgets.get("model_vibes", "")
        if widgets.get("model_vibes", "").startswith("/")
        else ""
    )

    stored_params = dict(widgets)
    params_json_omit_deployment_catalog_for_multi_catalog(
        stored_params, data.cataloging_style
    )
    # Not widgets: the sent input ids, for retry re-linking, and (budgeted
    # intents only) the run's budget in hours. ``retry_run`` takes both out
    # before replaying this map as notebook_params.
    stored_params["included_input_ids"] = included_input_ids
    if intent_value in _BUDGETED_INTENTS:
        stored_params[RUNTIME_BUDGET_HOURS_KEY] = budget_hours

    run = Run(
        business_id=business_id,
        version_id=version_id,
        intent=intent_value,
        status="pending",
        vibe_session_id=sid,
        vibe_session_id_bigint=sid_bigint,
        parameters_json=json.dumps(stored_params),
        vibe_instructions_text=vibe_instructions,
        vibe_instructions_volume_path=vibe_instructions_volume_path,
        business_context_text=(data.business_context_text or "").strip(),
    )
    session.add(run)
    session.commit()
    session.refresh(run)

    # Persist RunNextVibeLink rows for traceability, regardless of whether the
    # job launch succeeds below. If the launch fails, we'll still know which
    # selections were intended for this attempt.
    for nv in selected_next_vibes:
        session.add(RunNextVibeLink(run_id=run.id, next_vibe_id=nv.id))
    # Vibe Inputs intended-selection audit (consume flips on success only).
    # Only the ids the compile sent are linked.
    _persist_run_input_links(session, run.id, included_input_ids)
    if selected_next_vibes or included_input_ids:
        session.commit()

    # Build per-run job tags for monitoring
    job_tags = job_tags_for_config(
        agent_config,
        business_name=business.name,
        model_scope=widgets.get("data_model_scopes", ""),
        version=widgets.get("model_version", "1"),
        operation=agent_op,
        session_id=sid,
    )

    # Launch the job
    try:
        dbx_run_id = launch_run(
            ws,
            agent_config.job_id,
            widgets,
            job_tags=job_tags,
            warehouse_id=resolve_warehouse_id(session, config),
            progress_migrate_strategy=config.progress_migrate_strategy,
        )
        run.databricks_run_id = dbx_run_id
        run.status = "running"
        run.started_at = datetime.now(timezone.utc)
        # Baseline message so the UI doesn't show "Waiting for updates" during
        # the gap between job launch and the tracker's first successful read
        # of the agent's session row.
        run.progress_message = "Starting — waiting for agent to report progress"
    except Exception as e:
        # Wiring audit (router legacy launch failure):
        #   Previous: direct run.status write (no completed_at!).
        #   New: transition_run stamps all five layers atomically.
        from .run_state_transitions import transition_run
        reason = f"Failed to trigger job: {sanitize_error_message(str(e))}"
        run.error_message = reason
        session.add(run)
        transition_run(session, run, target_status="failed", reason=reason)

    session.add(run)
    session.commit()
    session.refresh(run)

    # Start async progress tracking
    if run.status == "running":
        tracker.start_tracking(run.id)

    return _build_run_out(run, ws, session)

@router.get(
    "/businesses/{business_id}/runs/{run_id}",
    response_model=RunOut,
    operation_id="getRun",
)
def get_run(
    business_id: str,
    run_id: str,
    session: Dependencies.Session,
    ws: Dependencies.Client,
):
    """Get run status. Progress is already mirrored to Lakebase by the tracker."""
    run = get_run_in_business(session, business_id, run_id)
    return _build_run_out(run, ws, session)


_SOURCE_LINK_INTENTS = {
    Intent.VIBE_ITERATE.value,
    Intent.VIBE_NEW_ECM_MVM.value,
}
_OPERATES_ON_INTENTS = {
    Intent.INSTALL.value,
    Intent.UNINSTALL.value,
    Intent.GENERATE_SAMPLES.value,
    Intent.REVERT.value,
    Intent.IMPORT_FROM_VOLUME.value,
}
_MODEL_PRODUCING_INTENTS = {
    Intent.NEW_BASE_MODEL.value,
    Intent.VIBE_ITERATE.value,
    Intent.VIBE_NEW_ECM_MVM.value,
}


def _version_lineage_out(mv: Optional[ModelVersion]) -> Optional[RunLineageVersionOut]:
    if mv is None:
        return None
    return RunLineageVersionOut(
        id=mv.id,
        version=mv.version,
        scope=mv.scope or "",
        status=mv.status,
        deployment_status=mv.deployment_status,
    )


@router.get(
    "/businesses/{business_id}/runs/{run_id}/lineage",
    response_model=RunLineageOut,
    operation_id="getRunLineage",
)
def get_run_lineage(
    business_id: str,
    run_id: str,
    session: Dependencies.Session,
):
    """Return the source / generated / operates-on version links for a run.

    - source_version: BASE this run branched from (vibe/shrink/enlarge).
    - generated_version: version this run produced (model-producing ops).
    - operates_on_version: target of install/uninstall/samples/revert/import.

    For model-producing ops, `version_id` on the Run points at the OUTPUT
    once the run completes; before that it points at the BASE for vibe /
    shrink / enlarge runs (set at launch time). We disambiguate by
    checking `ModelVersion.base_version_id`: if Run.version_id.base_version_id
    is set, Run.version_id IS the output and its base is the source.
    """
    run = get_run_in_business(session, business_id, run_id)

    out = RunLineageOut(
        run_id=run.id,
        intent=run.intent or "",
        business_id=run.business_id,
    )

    target_mv = session.get(ModelVersion, run.version_id) if run.version_id else None

    intent_value = run.intent or ""
    if intent_value in _OPERATES_ON_INTENTS:
        out.operates_on_version = _version_lineage_out(target_mv)
        return out

    if intent_value in _MODEL_PRODUCING_INTENTS and target_mv is not None:
        if intent_value == Intent.NEW_BASE_MODEL.value:
            out.generated_version = _version_lineage_out(target_mv)
            return out

        # For vibe / shrink / enlarge: Run.version_id is overloaded.
        # At launch time it points at the BASE the user picked; once the
        # run completes successfully, model_sync updates it to point at
        # the freshly-produced OUTPUT. Disambiguate on Run.status:
        #
        #   - run.status != "completed"  → version_id is the SOURCE
        #     (running, pending, failed, cancelled — the run never
        #     advanced past launch, or produced no output)
        #   - run.status == "completed"  → version_id is the OUTPUT
        #
        # Without this, an in-flight vibe-iterate that picked v=1 MVM
        # (which itself has base_version_id pointing to v=1 ECM from
        # the earlier shrink) was rendered as
        #   "Source: v=1 ECM, Generated: v=1 MVM"
        # — both wrong: v=1 MVM is the SOURCE, the output doesn't exist
        # yet.
        is_completed = run.status == "completed"
        if not is_completed:
            out.source_version = _version_lineage_out(target_mv)
            return out

        if target_mv.base_version_id:
            out.generated_version = _version_lineage_out(target_mv)
            base_mv = session.get(ModelVersion, target_mv.base_version_id)
            out.source_version = _version_lineage_out(base_mv)
            return out

        out.source_version = _version_lineage_out(target_mv)
        child = session.exec(
            select(ModelVersion)
            .where(ModelVersion.base_version_id == target_mv.id)
            .order_by(ModelVersion.version.desc())
        ).first()
        out.generated_version = _version_lineage_out(child)
        return out

    return out

@router.get(
    "/businesses/{business_id}/runs",
    response_model=list[RunListOut],
    operation_id="listRuns",
)
def list_runs(business_id: str, session: Dependencies.Session):
    runs = session.exec(
        select(Run)
        .where(Run.business_id == business_id)
        .order_by(Run.created_at.desc())
    ).all()
    return [
        RunListOut(
            id=r.id, business_id=r.business_id,
            intent=r.intent or "",
            status=r.status, progress_percent=r.progress_percent,
            started_at=r.started_at, completed_at=r.completed_at,
            created_at=r.created_at,
        )
        for r in runs
    ]

@router.get(
    "/model-versions/{version_id}/runs",
    response_model=list[RunListOut],
    operation_id="listRunsForVersion",
)
def list_runs_for_version(version_id: str, session: Dependencies.Session):
    """List runs that directly produced or were submitted against this version.

    Does not include runs that produced descendants — those are linked from the
    descendants' own pages.

    A run is "directly involved" if either:
      - ``Run.version_id == version_id`` (generated-for / operates-on / submitted-against), or
      - the run produced this version via a ``RunOperation`` whose
        ``output_version_id == version_id`` (covers cases where the run's own
        ``version_id`` points at the parent or is null at dispatch time).
    """
    mv = session.get(ModelVersion, version_id)
    if not mv:
        raise HTTPException(status_code=404, detail="Model version not found")

    from sqlalchemy import or_

    producing_run_ids_subq = (
        select(RunOperation.run_id)
        .where(RunOperation.output_version_id == version_id)
    )

    runs = session.exec(
        select(Run)
        .where(
            Run.business_id == mv.business_id,
            or_(
                Run.version_id == version_id,
                Run.id.in_(producing_run_ids_subq),
            ),
        )
        .order_by(Run.created_at.desc())
    ).all()
    return [
        RunListOut(
            id=r.id, business_id=r.business_id,
            intent=r.intent or "",
            status=r.status, progress_percent=r.progress_percent,
            started_at=r.started_at, completed_at=r.completed_at,
            created_at=r.created_at,
        )
        for r in runs
    ]

@router.get(
    "/businesses/{business_id}/runs/{run_id}/progress",
    response_model=list[ProgressEventOut],
    operation_id="getRunProgress",
)
def get_run_progress(
    business_id: str,
    run_id: str,
    session: Dependencies.Session,
    since_step_id: int = 0,
):
    """Get progress events for a run, optionally filtered by step_id."""
    get_run_in_business(session, business_id, run_id)
    events = session.exec(
        select(RunProgressEvent)
        .where(
            RunProgressEvent.run_id == run_id,
            RunProgressEvent.step_id > since_step_id,
        )
        .order_by(RunProgressEvent.created_at.asc(), RunProgressEvent.event_seq.asc())
    ).all()
    return events

@router.post(
    "/businesses/{business_id}/runs/{run_id}/cancel",
    response_model=RunOut,
    operation_id="cancelRun",
)
def cancel_run(
    business_id: str,
    run_id: str,
    session: Dependencies.Session,
    ws: Dependencies.Client,
    tracker: Dependencies.Tracker,
    _role: Dependencies.ModelerOnly,
):
    """Cancel a running job.

    Wiring audit
    ------------
    **Intent**: cancel endpoint that atomically closes all dependent layers.

    **Previous wiring**: wrote ``run.status`` and ``run.completed_at`` directly
    via ``ws.jobs.cancel_run``; left RunOperation rows, ``progress_message``,
    and the Databricks job partially dealt with.

    **New wiring**: delegates ALL terminal state changes to
    ``transition_run(..., target_status="cancelled", ws=ws)``.  The helper
    stamps Run.status, Run.completed_at, every in-flight RunOperation, the
    progress_message, and best-effort cancels the Databricks job.

    **Info-flow delta**:
    + RunOperation rows now reach ``"cancelled"`` status.
    + ``progress_message`` is replaced with a non-RUNNING string.
    + Databricks job cancel is now inside the helper (was inline here before;
      the helper issues it best-effort so HTTP 500 is no longer raised on
      cancel API failure — the message notes the failure instead).

    **Dead-end check**: ``tracker.stop_tracking`` is still called here before
    the helper so the poll loop exits before we stamp the terminal status.
    """
    from .run_state_transitions import transition_run

    run = get_run_in_business(session, business_id, run_id)
    if run.status not in ("running", "stale"):
        raise HTTPException(status_code=400, detail=f"Cannot cancel run in '{run.status}' state")
    tracker.stop_tracking(run_id)

    # Atomically close all layers (RunOperation rows, progress_message,
    # completed_at, best-effort Databricks cancel).
    transition_run(session, run, target_status="cancelled", ws=ws)

    session.commit()
    session.refresh(run)
    return _build_run_out(run, ws, session)


@router.post(
    "/businesses/{business_id}/runs/{run_id}/cancel-with-rollback",
    response_model=CancelWithRollbackOut,
    operation_id="cancelRunWithRollback",
)
def cancel_run_with_rollback(
    business_id: str,
    run_id: str,
    session: Dependencies.Session,
    ws: Dependencies.Client,
    tracker: Dependencies.Tracker,
    _role: Dependencies.ModelerOnly,
):
    """Cancel a running run AND roll back any partial state recorded
    by the orchestrator.

    Safety:
      * Refuses if the current phase's Databricks job has already
        terminated with SUCCESS — ripping apart a valid install would
        be a data-loss bug.
      * First stops the agent job via ``ws.jobs.cancel_run`` (same as the
        plain cancel endpoint), then replays each
        :meth:`Operation.rollback` in REVERSE step order.
      * Each reverse-op is guarded try/except. First failure marks the
        run ``rolled_back_failed``, records the failing step in
        ``error_message``, and stops — subsequent ops are NOT attempted
        so the operator can triage the residual state.

    Returns ``{ok, status, ops_applied, op_failures}``.
    """
    run = get_run_in_business(session, business_id, run_id)
    if run.status not in ("running", "stale"):
        raise HTTPException(
            status_code=400,
            detail=f"Cannot cancel-with-rollback a run in '{run.status}' state",
        )

    tracker.stop_tracking(run_id)
    result = tracker.orchestrator.cancel_with_rollback(run, session, ws=ws)

    # Refusal (e.g. the current step's Databricks job already SUCCEEDED,
    # so rolling it back would lose a valid install): the orchestrator
    # changed nothing and the run is still live, so polling resumes before
    # the 409 names the reason.
    if result.refusal_reason:
        tracker.start_tracking(run_id)
        raise HTTPException(status_code=409, detail=result.op_failures[0]["error"])

    session.commit()
    session.refresh(run)
    return CancelWithRollbackOut(
        ok=result.ok,
        status=result.final_run_status,
        ops_applied=[
            CancelOpAppliedOut(operation_name=n, kind=n)
            for n in result.ops_rolled_back
        ],
        op_failures=[
            CancelOpFailureOut(
                op=f.get("op", {}) if isinstance(f, dict) else {},
                error=(f.get("error", "") if isinstance(f, dict) else str(f)),
            )
            for f in result.op_failures
        ],
    )


def _resume_run_impl(
    business_id: str,
    run_id: str,
    session,
    tracker,
) -> ResumeRunOut:
    """Re-enter the orchestrator at the failed step (spec §6.4)."""
    run = get_run_in_business(session, business_id, run_id)
    _refuse_retired_intent(run.intent)
    _refuse_app_only_retry(run.intent)
    if run.status not in ("failed", "cancelled", "stale", "rolled_back_failed"):
        raise HTTPException(
            status_code=400,
            detail=(
                f"Run is in '{run.status}' state; resume only applies to "
                "failed / cancelled / stale / rolled_back_failed runs"
            ),
        )
    tracker.orchestrator.resume(run, session)
    session.commit()
    session.refresh(run)
    if run.status == "running":
        tracker.start_tracking(run.id)
    return ResumeRunOut(
        ok=True,
        status=run.status,
        next_phase="",
        databricks_run_id=run.databricks_run_id,
    )


@router.post(
    "/businesses/{business_id}/runs/{run_id}/resume",
    response_model=ResumeRunOut,
    operation_id="resumeRun",
)
def resume_run(
    business_id: str,
    run_id: str,
    session: Dependencies.Session,
    tracker: Dependencies.Tracker,
    _role: Dependencies.AdminOnly,
):
    """Resume an orchestrator-managed run from its failed step (spec §6.4)."""
    return _resume_run_impl(business_id, run_id, session, tracker)


@router.delete(
    "/businesses/{business_id}/runs/{run_id}",
    response_model=dict,
    operation_id="deleteRun",
)
def delete_run(
    business_id: str,
    run_id: str,
    session: Dependencies.Session,
    ws: Dependencies.Client,
    _role: Dependencies.AdminOnly,
):
    """Delete a run and all its dependents. Only allowed on terminal runs
    (completed / failed / cancelled) to avoid racing the poll loop.

    Progress events, artifacts, operations, next-vibe links, input links, and
    element-lineage rows all die via ``run_id`` ON DELETE CASCADE. After the
    commit, the run's instruction files on the Volume are deleted best-effort
    (X10): a failure is logged and never fails the delete."""
    run = get_run_in_business(session, business_id, run_id)
    if run.status not in ("completed", "failed", "cancelled"):
        raise HTTPException(
            status_code=400,
            detail=f"Cannot delete run in '{run.status}' state; cancel it first.",
        )

    instruction_files = _run_instruction_files(session, run)
    session.delete(run)
    session.commit()
    for path in instruction_files:
        try:
            ws.files.delete(path)
        except Exception:  # noqa: BLE001 - best effort; the run is already gone
            logger.warning("delete_run: could not delete instruction file %s", path, exc_info=True)
    return {
        "ok": True,
        "deleted_run_id": run_id,
    }


# The per-session instruction file ``job_launcher.vibe_instructions_volume_path``
# writes: ``/Volumes/<catalog>/_metamodel/vol_root/business/<biz>/_vibe_inputs/<sid>.txt``.
_INSTRUCTION_FILE_RE = re.compile(
    r"^/Volumes/[^/]+/_metamodel/vol_root/business/(?P<biz>[^/]+)/_vibe_inputs/[^/]+\.txt$"
)


def _run_instruction_files(session, run: Run) -> list[str]:
    """The instruction files the app spilled to the Volume for ``run``.

    The legacy launch records the path on the run; each orchestrator step
    sends it as its ``model_vibes`` widget. Short instructions travel inline
    in the same widget, so a value that equals the instruction text the run
    or step sent is text, not a file reference, even when it reads like a
    path. Only paths of the app's layout under this run's own business
    folder count.
    """
    from .core._names import agent_business_segment

    business = run.business
    segment = agent_business_segment(business.name) if business is not None else ""
    if not segment:
        return []
    texts = {(run.vibe_instructions_text or "").strip()}
    candidates = [run.vibe_instructions_volume_path or ""]
    for params_json, widgets_json in session.exec(
        select(RunOperation.params_json, RunOperation.dispatched_widgets_json)
        .where(RunOperation.run_id == run.id)
    ).all():
        try:
            params = json.loads(params_json) if params_json else {}
            widgets = json.loads(widgets_json) if widgets_json else {}
        except (TypeError, ValueError):
            continue
        if isinstance(params, dict):
            texts.add(str(params.get("vibe_instructions") or "").strip())
        if isinstance(widgets, dict):
            candidates.append(str(widgets.get("model_vibes") or ""))
    files = set()
    for path in candidates:
        match = _INSTRUCTION_FILE_RE.match(path)
        if match and match.group("biz") == segment and path.strip() not in texts:
            files.add(path)
    return sorted(files)


@router.post(
    "/businesses/{business_id}/runs/{run_id}/retry",
    response_model=RunOut,
    operation_id="retryRun",
)
def retry_run(
    business_id: str,
    run_id: str,
    session: Dependencies.Session,
    ws: Dependencies.Client,
    config: Dependencies.Config,
    tracker: Dependencies.Tracker,
    _role: Dependencies.ModelerOnly,
):
    """Retry a failed or cancelled run with a new session ID.

    Orchestrator-managed runs (those with persisted ``RunOperation`` rows)
    are retried through ``Orchestrator.resume``, the same re-dispatch
    machinery the admin ``/resume`` endpoint uses. Each operation's own
    ``dispatch()`` rebuilds its notebook_params from its typed params
    model (via ``map_run_params_to_widgets``) and mints a fresh session
    id itself, so this reuses the SAME flattening the original launch
    used. It deliberately does NOT replay ``Run.parameters_json``
    against ``launch_run`` for these runs: per the 0.6.6 run-config
    disclosure work, ``parameters_json`` for orchestrator-managed runs
    is a structured audit record (may hold lists / booleans / nested
    values, e.g. ``input_ids`` or a full request-body snapshot), not
    the flat map of STRING values the Databricks Jobs `run_now` API
    requires for `notebook_params`. Passing it straight through 500s
    with "Expected Scalar value for String field \"value\"".

    Runs with no ``RunOperation`` rows went through the legacy
    single-job launch path, where ``parameters_json`` IS the flat
    widget map used at launch (see ``create_run``'s
    ``stored_params = dict(widgets)``). Those remain safe to replay
    directly below.
    """
    run = get_run_in_business(session, business_id, run_id)
    if run.status not in ("failed", "cancelled"):
        raise HTTPException(status_code=400, detail=f"Cannot retry run in '{run.status}' state")
    _refuse_retired_intent(run.intent)
    _refuse_app_only_retry(run.intent)
    # A retried install still performs the deletes it carries: the same role
    # as asking for them.
    if run_requests_post_install_delete(run):
        require_business_admin(_role)
    # One run per business, as on create: the lock (409 while another request
    # holds it) and its active-run re-check (409 naming the active run). Held
    # until the commit that sets this run going again; nothing commits before.
    lock_business_for_run(session, business_id)

    has_orchestrator_ops = session.exec(
        select(RunOperation.id).where(RunOperation.run_id == run.id)
    ).first() is not None
    if has_orchestrator_ops:
        # A preceding *failure* deletes this run's RunInputLink rows
        # (re-pool contract; a cancellation does not). Re-establish them
        # from the recorded ``included_input_ids`` (the ids the compile
        # actually sent; ``input_ids`` for older runs) before re-dispatching
        # either way, same as the legacy path below, so a successful retry
        # consumes exactly the inputs the run was launched with and never an
        # excluded (out-of-scope) one (a no-op when the links are still
        # present). Both keys live in the structured ``parameters_json`` audit
        # record regardless of which orchestrator branch created the run.
        try:
            stored = json.loads(run.parameters_json) if run.parameters_json else {}
        except (json.JSONDecodeError, TypeError):
            stored = {}
        _persist_run_input_links(session, run.id, _stored_included_input_ids(stored))
        try:
            tracker.orchestrator.resume(run, session)
        except Exception as e:
            logger.exception("Retry of run %s failed in orchestrator.resume", run.id)
            raise HTTPException(
                status_code=500,
                detail=f"Failed to retry: {recorded_error_text(e, 'Retry', str(e))}",
            )
        session.commit()
        session.refresh(run)
        if run.status == "running":
            tracker.start_tracking(run.id)
        return _build_run_out(run, ws, session)

    agent_config = _get_agent_config(session)

    # Generate new session ID for the retry
    sid = generate_session_id()
    sid_bigint = session_id_to_bigint(sid)

    try:
        params = json.loads(run.parameters_json) if run.parameters_json else {}
        # The run's own budget; a run created before the setting existed gets
        # today's Settings default, which this retry then keeps.
        budget_hours = stored_runtime_budget_hours(params, agent_config)
        # A map stored by an older app: send it as build_widget_map would today.
        try:
            params = refresh_stored_widgets(params, runtime_budget_hours=budget_hours)
        except ValueError as e:
            raise HTTPException(status_code=422, detail=f"Cannot retry this run: {e}") from e
        # Not a widget (a list): keep it out of the notebook_params replay.
        relink_ids = _stored_included_input_ids(params)
        included_input_ids = params.pop("included_input_ids", None)
        params["vibe_session_id"] = sid
        run.vibe_session_id = sid
        run.vibe_session_id_bigint = sid_bigint
        run.last_consumed_step_id = 0

        retry_job_tags = job_tags_for_config(
            agent_config,
            business_name=run.business.name if run.business else "",
            model_scope=params.get("data_model_scopes", ""),
            version=params.get("model_version", ""),
            operation=run.intent,
            session_id=sid,
        )
        dbx_run_id = launch_run(
            ws,
            agent_config.job_id,
            params,
            job_tags=retry_job_tags,
            warehouse_id=resolve_warehouse_id(session, config),
            progress_migrate_strategy=config.progress_migrate_strategy,
        )
        run.databricks_run_id = dbx_run_id
        run.status = "running"
        run.started_at = datetime.now(timezone.utc)
        run.completed_at = None
        run.error_message = ""
        run.progress_percent = 0
        run.progress_message = ""
        stored_params = dict(params)
        if included_input_ids is not None:
            stored_params["included_input_ids"] = included_input_ids
        if run.intent in _BUDGETED_INTENTS:
            stored_params[RUNTIME_BUDGET_HOURS_KEY] = budget_hours
        run.parameters_json = json.dumps(stored_params)
        # The preceding failure deleted this run's RunInputLink rows (re-pool
        # contract). Re-establish them from the recorded included_input_ids so
        # a successful retry consumes exactly the inputs the run was launched
        # with — without them, finalize would find no links and consume nothing.
        _persist_run_input_links(session, run.id, relink_ids)
    except HTTPException:
        raise
    except ValueError as e:
        # ``launch_run`` refused the stored map (a model-producing op with no
        # ``deployment_catalog``) before any workspace call.
        raise HTTPException(status_code=422, detail=(
            "Cannot retry this run: its stored parameters have no deployment catalog. "
            "Start a new run instead."
        )) from e
    except Exception as e:
        logger.exception("Retry of run %s failed", run.id)
        raise HTTPException(
            status_code=500,
            detail=f"Failed to retry: {recorded_error_text(e, 'Retry', str(e))}",
        )

    session.add(run)
    session.commit()
    session.refresh(run)

    tracker.start_tracking(run.id)

    return _build_run_out(run, ws, session)

@router.get(
    "/businesses/{business_id}/runs/{run_id}/artifacts",
    response_model=list[RunArtifactOut],
    operation_id="listArtifacts",
)
def list_artifacts(
    business_id: str,
    run_id: str,
    session: Dependencies.Session,
):
    get_run_in_business(session, business_id, run_id)
    artifacts = session.exec(
        select(RunArtifact)
        .where(RunArtifact.run_id == run_id)
        .order_by(RunArtifact.created_at.desc())
    ).all()
    return artifacts


# Artifact preview / download tuning + helpers live in `_artifact_io`
# so router.py (`/runs/.../artifacts/...`) and routes/versions.py
# (`/businesses/.../model-versions/.../artifacts/...`) share one source of truth.


@router.get(
    "/businesses/{business_id}/runs/{run_id}/artifacts/{artifact_id}/content",
    response_model=dict,
    operation_id="getArtifactContent",
)
def get_artifact_content(
    business_id: str,
    run_id: str,
    artifact_id: str,
    session: Dependencies.Session,
    ws: Dependencies.Client,
    content_format: Literal["text", "hex"] = Query(
        "text",
        alias="format",
        description='Use "text" for UTF-8 text bodies, "hex" for a short hex dump of any file.',
    ),
):
    """Read artifact bytes from its Volume path. See :func:`build_artifact_content_response`."""
    get_run_in_business(session, business_id, run_id)
    artifact = session.exec(
        select(RunArtifact).where(
            RunArtifact.id == artifact_id,
            RunArtifact.run_id == run_id,
        )
    ).first()
    if not artifact:
        raise HTTPException(status_code=404, detail="Artifact not found")
    return build_artifact_content_response(ws, artifact, content_format)


@router.get(
    "/businesses/{business_id}/runs/{run_id}/artifacts/download",
    operation_id="downloadAllArtifacts",
)
def download_all_artifacts(
    business_id: str,
    run_id: str,
    session: Dependencies.Session,
    ws: Dependencies.Client,
):
    """Stream a zip of every artifact for this run.

    Artifacts are read from the Volume sequentially and packed into a zip
    in memory. Fine for the MVP size range; if archives ever grow beyond a
    few hundred MB we'd need to stream via a temp file.
    """
    get_run_in_business(session, business_id, run_id)

    artifacts = session.exec(
        select(RunArtifact)
        .where(RunArtifact.run_id == run_id)
        .order_by(RunArtifact.created_at.desc())
    ).all()
    if not artifacts:
        raise HTTPException(status_code=404, detail="No artifacts to download")

    body = build_artifacts_zip_bytes(ws, artifacts)
    filename = f"run-{run_id[:8]}-artifacts.zip"
    return StreamingResponse(
        iter([body]),
        media_type="application/zip",
        headers={"Content-Disposition": f'attachment; filename="{filename}"'},
    )


@router.get(
    "/businesses/{business_id}/runs/{run_id}/artifacts/{artifact_id}/download",
    operation_id="downloadArtifact",
)
def download_artifact(
    business_id: str,
    run_id: str,
    artifact_id: str,
    session: Dependencies.Session,
    ws: Dependencies.Client,
    inline: bool = Query(
        False,
        description="If true, use Content-Disposition: inline and a browser-friendly Content-Type (PDF, images) for embedding in the UI.",
    ),
):
    """Stream a single artifact's raw bytes as a file download (or inline preview)."""
    get_run_in_business(session, business_id, run_id)
    artifact = session.exec(
        select(RunArtifact).where(
            RunArtifact.id == artifact_id,
            RunArtifact.run_id == run_id,
        )
    ).first()
    if not artifact:
        raise HTTPException(status_code=404, detail="Artifact not found")
    return build_artifact_download_response(ws, artifact, inline=inline)
