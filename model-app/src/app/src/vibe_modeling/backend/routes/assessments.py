"""Headless assessment API (config, readiness, launch, status, results, hand-off).

The feature is optional and enabled at install time (``AppConfig.assessment_enabled``).
``config_router`` holds the ungated ``GET /assess/config``, which answers ``installed``
/``ready``/``missing`` on every deployment; every other route sits on ``router`` and
answers 404 when the feature is not installed. Both stay mounted so the OpenAPI spec
does not change by deployment.
"""
from __future__ import annotations

import logging

from databricks.sdk.errors.platform import DatabricksError, NotFound
from databricks.sdk import WorkspaceClient
from fastapi import APIRouter, Depends, HTTPException
from datetime import datetime, timezone
from urllib.parse import quote

from typing import cast

from sqlalchemy import CursorResult, update
from sqlalchemy.exc import SQLAlchemyError
from sqlmodel import Session, col, select

from ... import __version__ as APP_VERSION
from ..._metadata import api_prefix
from ..assessment.assets import read_bundled_skill_versions, read_versions, resolve_vendored_assessment
from ..assessment.config_service import (
    NOT_INSTALLED_DETAIL, AssessConfigMissing, AssessConfigRejected, AssessReaderLookupFailed, AssessSyncFailed, assess_ready,
    check_assess_config, get_or_create_assess_config, save_assess_config,
)
from ..assessment.handoff import (
    EXPECTED_HANDOFFS, USER_SCOPE_NOTE, HandoffWriteError, scope_message, allowed_handoff_target, build_prompts, default_handoff_path, handoff_domain_run, render_readme,
    build_next_steps, is_scope_error, skills_check, skills_check_with_note, token_scopes, user_home,
)
from ..assessment.docs import read_doc, resolve_doc_path
from ..assessment.grading import (
    DecisionFacts, VibeFacts, classify_decision_kind, enrichment_pct, letter_grade, structure_grade,
)
from ..assessment.constants import RUNS_VOLUME, TERMINAL_STATUSES
from ..assessment.launch import LaunchNotReady, ensure_launch_ready, launch_batch
from ..assessment.skill_install import install_skill, plan_install
from ..assessment.readiness import evaluate_readiness
from ..assessment.schemas import (
    AssessBatchIn, AssessBatchOut, AssessRelaunchIn, AssessConfigIn, AssessConfigOut, AssessDomainRunOut, AssessEntityOut,
    AssessResultsOut, BulkAddNextVibesToFeedbackIn, BulkNextVibeToFeedbackOut, ColumnMappingOut, DecisionAffectedOut, DecisionAnswerIn, DecisionOptionOut, DocContentOut, DocEntry, DocsOut, DomainSourcesIn, GapOut,
    HandoffIn, HandoffOut, InstallSkillsIn, InstallSkillsOut, NextVibeFeedbackFailureOut, NextVibeOut, NextVibeToFeedbackOut, PendingDecisionOut, ReadinessIn, ReadinessOut, SourceIn, SourceMapIn, SourceMapOut,
    SourceProfileOut, SummaryOut,
)
from ..core import Dependencies, resolve_metamodel_catalog
from ..core._app_identity import app_application_id
from ..core._features import require_installed
from ..core._errors import admin_help_error, config_missing_error, setting_refused_error
from ..core._identity import actor_label, current_user_email, require_user_email
from ..core._time import as_utc
from ..core._vibe_input_create import create_vibe_input_with_anchor
from ..db_models import (
    AssessBatch, AssessColumnMapping, AssessColumnSourceProfile, AssessConfig, AssessDecisionOption, AssessDomainRun, AssessDomainSource, AssessEntity,
    AssessDecisionAffected, AssessDecisionOptionPoint, AssessGap, AssessHandoff, AssessNextVibe,
    AssessNextVibeEntity, AssessPendingDecision, AssessSummary, AssessSummaryItem, AssessSourceMap, Business, Domain, ModelVersion,
    Product, VibeInput, VibeInputContextLink,
)
from ..error_sanitization import recorded_error_text, sanitize_error_message
from ..models import VibeInputOrigin, VibeInputPriority, VibeInputStatus, VibeInputOut, FeedbackContext
from ._helpers import build_job_run_url

logger = logging.getLogger(__name__)

require_assessment_installed = require_installed("assessment_enabled", NOT_INSTALLED_DETAIL)

config_router = APIRouter(prefix=api_prefix)
router = APIRouter(prefix=api_prefix, dependencies=[Depends(require_assessment_installed)])


def _run_links(ws: WorkspaceClient, dr: AssessDomainRun) -> dict:
    """The run's job link, job-run link and reader, from the job id pinned on the run (survives a recreated job)."""
    run_url = build_job_run_url(ws, dr.job_id, dr.databricks_run_id) if dr.databricks_run_id else ""
    return {"job_url": build_job_run_url(ws, dr.job_id), "run_url": run_url, "job_reader": dr.job_reader}


def _run_help(ws: WorkspaceClient, dr: AssessDomainRun, message: str, *, runs_path: str = "") -> HTTPException:
    """The 409 ``admin_help`` error for a failure on one domain run, with the run's links."""
    return admin_help_error(message, runs_path=runs_path, **_run_links(ws, dr))


def _config_out(cfg, ws: WorkspaceClient, *, installed: bool, app_id: str = "") -> AssessConfigOut:
    versions = read_versions()
    ready, missing = assess_ready(cfg, installed)
    return AssessConfigOut(
        reader_application_id=cfg.reader_application_id, reader_display_name=cfg.reader_display_name,
        job_id=cfg.job_id, workspace_path=cfg.workspace_path,
        max_concurrent_runs=cfg.max_concurrent_runs, default_reasoning_effort=cfg.default_reasoning_effort,
        warehouse_id=cfg.warehouse_id, genie_version=versions["genie"]["tag"],
        skills_ref=versions.get("skills_ref", ""), skills_version=versions.get("skills_version", ""),
        installed=installed, ready=ready, missing=missing, job_url=build_job_run_url(ws, cfg.job_id),
        updated_at=as_utc(cfg.updated_at), updated_by=cfg.updated_by, app_application_id=app_id)


@config_router.get("/assess/config", response_model=AssessConfigOut, operation_id="getAssessConfig")
def get_assess_config(session: Dependencies.Session, ws: Dependencies.Client, config: Dependencies.Config):
    """The assessment settings and whether the feature is ``installed``/``ready``.
    Not installed: answers ``installed=false`` from defaults without touching the
    AssessConfig row (no read, no lazy create) or resolving the app's identity."""
    if not config.assessment_enabled:
        return _config_out(AssessConfig(), ws, installed=False)
    return _config_out(get_or_create_assess_config(session, config), ws, installed=config.assessment_enabled,
                       app_id=app_application_id(ws))


@router.put("/assess/config", response_model=AssessConfigOut, operation_id="putAssessConfig")
def put_assess_config(body: AssessConfigIn, session: Dependencies.Session, ws: Dependencies.Client,
                      config: Dependencies.Config, headers: Dependencies.Headers, _role: Dependencies.AdminOnly):
    """Read-only checks, then apply + job sync; commits only a clean sync. A refusal writes nothing.

    An unset deployment catalog answers 422 ``config_missing``; a reader or warehouse the checks
    refuse answers 400 ``setting_refused`` (``key`` names the field); a failed reader lookup
    answers 409 ``admin_help``. A failed sync rolls the Save back, records the error on the row
    (``missing`` reports it) and answers 409 ``admin_help``.
    """
    catalog = resolve_metamodel_catalog(session, config)
    try:
        reader_sp = check_assess_config(ws, body, deployment_catalog=catalog)
    except AssessConfigMissing as e:
        raise config_missing_error(e.key) from e
    except AssessConfigRejected as e:
        raise setting_refused_error(e.key, str(e)) from e
    except AssessReaderLookupFailed as e:
        raise admin_help_error(f"Couldn't look up the reader service principal: {e}") from e
    try:
        cfg = save_assess_config(session, ws, body, deployment_catalog=catalog, user=actor_label(headers),
                                 app_version=APP_VERSION, config=config, reader_sp=reader_sp)
    except AssessSyncFailed as e:
        raise admin_help_error(f"The assessment job sync failed: {e.result.error}",
                               job_url=build_job_run_url(ws, e.job_id)) from e
    return _config_out(cfg, ws, installed=config.assessment_enabled, app_id=app_application_id(ws))


def _load_version_domains(session: Session, version_id: str, domain_ids: list[str]) -> tuple[ModelVersion, list[Domain]]:
    """Installed version + its requested domains, in request order (404/422 on bad input)."""
    mv = session.get(ModelVersion, version_id)
    if mv is None:
        raise HTTPException(404, "Model version not found.")
    if mv.deployment_status != "deployed" or not mv.uc_catalog:
        raise HTTPException(422, "Version is not installed in a catalog.")
    if len(set(domain_ids)) != len(domain_ids):
        raise HTTPException(422, "Duplicate domain ids.")
    doms = []
    for did in domain_ids:
        d = session.get(Domain, did)
        if d is None or d.version_id != mv.id:
            raise HTTPException(422, f"Domain {did!r} is not part of this version.")
        doms.append(d)
    return mv, doms


@router.post("/assess/readiness", response_model=ReadinessOut, operation_id="checkAssessReadiness")
def check_assess_readiness(body: ReadinessIn, session: Dependencies.Session, ws: Dependencies.Client,
                           config: Dependencies.Config):
    mv, doms = _load_version_domains(session, body.version_id, [d.domain_id for d in body.domains])
    by_id = {d.domain_id: d.sources for d in body.domains}
    return evaluate_readiness(session, ws, get_or_create_assess_config(session, config),
                              deployment_catalog=resolve_metamodel_catalog(session, config),
                              version=mv, domains=[(d, by_id[d.id]) for d in doms])


def _rollup_status(statuses: list[str]) -> str:
    """Batch status from its domain-run statuses.

    ``partial`` needs at least one completed run; with none, any failed or results_invalid
    run makes the batch ``failed`` (neither has usable results).
    """
    if any(st not in TERMINAL_STATUSES for st in statuses):
        return "running"
    if statuses and all(st == "completed" for st in statuses):
        return "completed"
    if "completed" in statuses:
        return "partial"
    return "failed" if any(st in ("failed", "results_invalid") for st in statuses) else "cancelled"


def _batch_out(session: Session, ws: WorkspaceClient, batch: AssessBatch) -> AssessBatchOut:
    """Assemble the nested batch shape (runs + source snapshots + roll-up status) via joins."""
    mv = session.get(ModelVersion, batch.version_id)
    rows = session.exec(
        select(AssessDomainRun, Domain.name).join(Domain, Domain.id == AssessDomainRun.domain_id)
        .where(AssessDomainRun.batch_id == batch.id).order_by(AssessDomainRun.created_at)).all()
    runs: list[AssessDomainRunOut] = []
    for dr, dname in rows:
        srcs = session.exec(select(AssessDomainSource).where(AssessDomainSource.domain_run_id == dr.id)
                            .order_by(AssessDomainSource.source_name)).all()
        runs.append(AssessDomainRunOut(
            id=dr.id, domain_id=dr.domain_id, domain_name=dname, databricks_run_id=dr.databricks_run_id,
            **_run_links(ws, dr), status=dr.status, stage=dr.stage, attempt=dr.attempt, resume_at=as_utc(dr.resume_at),
            last_message=dr.last_message, error_message=dr.error_message, started_at=as_utc(dr.started_at),
            ended_at=as_utc(dr.ended_at), skills_commit=dr.skills_commit, skills_version=dr.skills_version,
            genie_version=dr.genie_version, model_quality_score=dr.model_quality_score,
            metamodel_location=dr.metamodel_location, metamodel_version=dr.metamodel_version,
            results_valid=dr.results_valid, schema_version=dr.schema_version, runs_path=dr.out_dir,
            ingest_attempts=dr.ingest_attempts or 0, ingest_next_at=as_utc(dr.ingest_next_at),
            sources=[SourceIn(source_name=x.source_name, catalog_name=x.catalog_name, schema_name=x.schema_name)
                     for x in srcs]))
    return AssessBatchOut(
        id=batch.id, business_id=batch.business_id, version_id=batch.version_id,
        version=mv.version if mv else 0, scope=mv.scope if mv else "", output_model=batch.output_model,
        etl_type=batch.etl_type, reasoning_effort=batch.reasoning_effort,
        status=_rollup_status([r.status for r in runs]), created_by=batch.created_by,
        created_at=as_utc(batch.created_at), domain_runs=runs)


def _require_business(session: Session, business_id: str) -> Business:
    b = session.get(Business, business_id)
    if b is None:
        raise HTTPException(404, "Business not found.")
    return b


def _source_map_out(session: Session, business_id: str) -> SourceMapOut:
    rows = session.exec(select(AssessSourceMap).where(AssessSourceMap.business_id == business_id)
                        .order_by(AssessSourceMap.source_name)).all()
    return SourceMapOut(sources=[SourceIn(source_name=r.source_name, catalog_name=r.catalog_name,
                                          schema_name=r.schema_name) for r in rows])


@router.get("/businesses/{business_id}/assess-source-map", response_model=SourceMapOut,
            operation_id="getAssessSourceMap")
def get_assess_source_map(business_id: str, session: Dependencies.Session):
    _require_business(session, business_id)
    return _source_map_out(session, business_id)


@router.put("/businesses/{business_id}/assess-source-map", response_model=SourceMapOut,
            operation_id="putAssessSourceMap")
def put_assess_source_map(business_id: str, body: SourceMapIn, session: Dependencies.Session,
                          _role: Dependencies.ModelerOnly):
    """Replace the business's saved bronze source map (one transaction)."""
    _require_business(session, business_id)
    if len({s.source_name for s in body.sources}) != len(body.sources):
        raise HTTPException(422, "Duplicate source names.")
    for row in session.exec(select(AssessSourceMap).where(AssessSourceMap.business_id == business_id)).all():
        session.delete(row)
    session.flush()
    for s in body.sources:
        session.add(AssessSourceMap(business_id=business_id, source_name=s.source_name,
                                    catalog_name=s.catalog_name, schema_name=s.schema_name))
    session.commit()
    return _source_map_out(session, business_id)


@router.post("/businesses/{business_id}/assessments", response_model=AssessBatchOut, status_code=201,
             operation_id="launchAssessment")
def launch_assessment(business_id: str, body: AssessBatchIn, session: Dependencies.Session,
                      ws: Dependencies.Client, config: Dependencies.Config, headers: Dependencies.Headers,
                      _role: Dependencies.ModelerOnly):
    """Re-check readiness server-side, then write one config.json + run_now per domain."""
    business = _require_business(session, business_id)
    mv, doms = _load_version_domains(session, body.version_id, [d.domain_id for d in body.domains])
    if mv.business_id != business.id:
        raise HTTPException(422, "Version does not belong to this business.")
    by_id = {d.domain_id: d.sources for d in body.domains}
    return _launch_checked(session, ws, config, headers, business=business, mv=mv,
                           pairs=[(d, by_id[d.id]) for d in doms], body=body)


def _launch_checked(session: Session, ws: WorkspaceClient, config, headers, *, business: Business,
                    mv: ModelVersion, pairs: list[tuple[Domain, list[SourceIn]]], body: AssessBatchIn) -> AssessBatchOut:
    """Shared launch tail: ``assess_ready`` (409), readiness re-check (409 when blocked), then ``launch_batch``."""
    cfg = get_or_create_assess_config(session, config)
    job_url = build_job_run_url(ws, cfg.job_id)
    try:
        ensure_launch_ready(cfg, config.assessment_enabled)
    except LaunchNotReady as e:
        raise admin_help_error(str(e), job_url=job_url, not_ready=e.missing) from e
    catalog = resolve_metamodel_catalog(session, config)
    readiness = evaluate_readiness(session, ws, cfg, deployment_catalog=catalog, version=mv, domains=pairs)
    if any(d.blocked for d in readiness.domains):
        raise admin_help_error("Assessment is blocked; resolve the failing checks.", job_url=job_url,
                               readiness=readiness.model_dump())
    try:
        batch = launch_batch(session, ws, business=business, version=mv, domains=pairs, body=body, cfg=cfg,
                             deployment_catalog=catalog, user=actor_label(headers),
                             installed=config.assessment_enabled)
    except RuntimeError as e:  # the bundled assets are unreadable; nothing was launched
        raise admin_help_error(f"Launch failed: {sanitize_error_message(str(e))}", job_url=job_url) from e
    return _batch_out(session, ws, batch)


@router.get("/businesses/{business_id}/assessments", response_model=list[AssessBatchOut],
            operation_id="listAssessments")
def list_assessments(business_id: str, session: Dependencies.Session, ws: Dependencies.Client):
    """Assessment batches for a business, newest first."""
    _require_business(session, business_id)
    batches = session.exec(select(AssessBatch).where(AssessBatch.business_id == business_id)
                           .order_by(AssessBatch.created_at.desc())).all()
    return [_batch_out(session, ws, b) for b in batches]


def _require_batch(session: Session, batch_id: str) -> AssessBatch:
    batch = session.get(AssessBatch, batch_id)
    if batch is None:
        raise HTTPException(404, "Assessment not found.")
    return batch


@router.get("/assessments/{batch_id}", response_model=AssessBatchOut, operation_id="getAssessment")
def get_assessment(batch_id: str, session: Dependencies.Session, ws: Dependencies.Client):
    return _batch_out(session, ws, _require_batch(session, batch_id))


RELAUNCHABLE_STATUSES = frozenset({"failed", "cancelled", "results_invalid"})


@router.post("/assessments/{batch_id}/relaunch", response_model=AssessBatchOut, status_code=201,
             operation_id="relaunchAssessment")
def relaunch_assessment(batch_id: str, session: Dependencies.Session, ws: Dependencies.Client,
                        config: Dependencies.Config, headers: Dependencies.Headers, _role: Dependencies.ModelerOnly,
                        body: AssessRelaunchIn | None = None):
    """Start a NEW batch from a prior one's settings and stored sources (the old batch is kept as history)."""
    old = _require_batch(session, batch_id)
    runs = session.exec(select(AssessDomainRun).where(AssessDomainRun.batch_id == old.id)
                        .order_by(AssessDomainRun.created_at)).all()
    ids = body.domain_run_ids if body else None
    if ids is None:
        picked = [r for r in runs if r.status in RELAUNCHABLE_STATUSES]
    else:
        by_id = {r.id: r for r in runs}
        if len(set(ids)) != len(ids) or any(i not in by_id for i in ids):
            raise HTTPException(422, "Domain run ids must be unique and belong to this assessment.")
        picked = [by_id[i] for i in ids]
        if any(r.status not in TERMINAL_STATUSES for r in picked):
            raise HTTPException(409, "Only finished domain runs can be relaunched.")
    if not picked:
        raise HTTPException(409, "Nothing to relaunch.")
    business = _require_business(session, old.business_id)
    mv, doms = _load_version_domains(session, old.version_id, [r.domain_id for r in picked])
    pairs: list[tuple[Domain, list[SourceIn]]] = []
    for r, d in zip(picked, doms):
        srcs = session.exec(select(AssessDomainSource).where(AssessDomainSource.domain_run_id == r.id)
                            .order_by(AssessDomainSource.source_name)).all()
        if not srcs:
            raise HTTPException(422, f"Domain run for {d.name!r} has no stored sources to relaunch.")
        pairs.append((d, [SourceIn(source_name=x.source_name, catalog_name=x.catalog_name,
                                   schema_name=x.schema_name) for x in srcs]))
    new_body = AssessBatchIn(
        version_id=old.version_id, domains=[DomainSourcesIn(domain_id=d.id, sources=s) for d, s in pairs],
        output_model=old.output_model, etl_type=old.etl_type, reasoning_effort=old.reasoning_effort)
    return _launch_checked(session, ws, config, headers, business=business, mv=mv, pairs=pairs, body=new_body)


SAVING_RESULTS_NOT_CANCELLABLE = ("This domain's job has finished and its results are being saved; "
                                  "it can't be cancelled now.")


def _cancel_domain_run(session: Session, ws: WorkspaceClient, dr: AssessDomainRun) -> None:
    """Cancel the Databricks run (if one was started) and mark the row cancelled; terminal rows are untouched.

    A run inside its ingest retry window has a finished job and is only saving results, so it
    answers a plain 409 (no admin help: nothing is wrong, the poller is still working on it).
    """
    if dr.status in TERMINAL_STATUSES:
        return
    if dr.ingest_next_at is not None:
        raise HTTPException(409, detail={"message": SAVING_RESULTS_NOT_CANCELLABLE})
    if dr.databricks_run_id:
        try:
            ws.jobs.cancel_run(run_id=dr.databricks_run_id)
        except DatabricksError as e:
            raise _run_help(
                ws, dr, f"Databricks could not cancel run {dr.databricks_run_id}: "
                        f"{sanitize_error_message(str(e))}") from e
    dr.status = "cancelled"
    dr.ended_at = datetime.now(timezone.utc)
    session.add(dr)
    session.commit()


@router.post("/assessment-domain-runs/{domain_run_id}/cancel", response_model=AssessDomainRunOut,
             operation_id="cancelAssessmentDomainRun")
def cancel_assessment_domain_run(domain_run_id: str, session: Dependencies.Session, ws: Dependencies.Client,
                                 _role: Dependencies.ModelerOnly):
    dr = session.get(AssessDomainRun, domain_run_id)
    if dr is None:
        raise HTTPException(404, "Assessment domain run not found.")
    _cancel_domain_run(session, ws, dr)
    batch = _require_batch(session, dr.batch_id)
    return next(r for r in _batch_out(session, ws, batch).domain_runs if r.id == domain_run_id)


@router.post("/assessments/{batch_id}/cancel", response_model=AssessBatchOut, operation_id="cancelAssessment")
def cancel_assessment(batch_id: str, session: Dependencies.Session, ws: Dependencies.Client,
                      _role: Dependencies.ModelerOnly):
    """Cancel every non-terminal domain run in the batch, except runs whose results are being saved."""
    batch = _require_batch(session, batch_id)
    for dr in session.exec(select(AssessDomainRun).where(AssessDomainRun.batch_id == batch_id)).all():
        if dr.ingest_next_at is None:
            _cancel_domain_run(session, ws, dr)
    return _batch_out(session, ws, batch)


_GRADE_RANK = {"blocked": 0, "partial": 1, "full": 2}
DOCS_CAP = 200


def _require_domain_run(session: Session, domain_run_id: str) -> AssessDomainRun:
    dr = session.get(AssessDomainRun, domain_run_id)
    if dr is None:
        raise HTTPException(404, "Assessment domain run not found.")
    return dr


def _domain_run_out(session: Session, ws: WorkspaceClient, dr: AssessDomainRun) -> AssessDomainRunOut:
    batch = _require_batch(session, dr.batch_id)
    return next(r for r in _batch_out(session, ws, batch).domain_runs if r.id == dr.id)


def _decision_out(dec: AssessPendingDecision, options: list[AssessDecisionOption],
                  points: dict[str, list[AssessDecisionOptionPoint]] | None = None,
                  affected: list[AssessDecisionAffected] | None = None) -> PendingDecisionOut:
    points = points or {}

    def texts(opt_id: str, kind: str) -> list[str]:
        return [p.text for p in sorted(points.get(opt_id, []), key=lambda p: p.ordinal) if p.kind == kind]

    return PendingDecisionOut(
        id=dec.id, domain_run_id=dec.domain_run_id, gate=dec.gate, question=dec.question,
        default_taken=dec.default_taken, evidence=dec.evidence, entity=dec.entity,
        answer_status=dec.answer_status, answer_option_id=dec.answer_option_id, answer_text=dec.answer_text,
        answered_by=dec.answered_by, answered_at=as_utc(dec.answered_at),
        options=[DecisionOptionOut(id=o.id, ordinal=o.ordinal, label=o.label, pros=texts(o.id, "pro"),
                                   cons=texts(o.id, "con"), impact=o.impact,
                                   recommended=dec.recommended_option_id == o.id)
                 for o in sorted(options, key=lambda o: o.ordinal)],
        context=dec.context, why_it_matters=dec.why_it_matters,
        recommendation_rationale=dec.recommendation_rationale, blocks_build=dec.blocks_build,
        affected=[DecisionAffectedOut(entity=a.entity, column=a.column) for a in (affected or [])],
        kind=_decision_kind(dec), ordinal=dec.ordinal)


def _decision_kind(dec: AssessPendingDecision) -> str:
    """Stored kind, else the gate-text fallback (old runs have none)."""
    return dec.kind if dec.kind in ("structure", "source", "scope") else classify_decision_kind(dec.gate)


def _entity_letter(e: AssessEntity) -> str | None:
    return letter_grade(e.grade, core_sourced=e.core_sourced, core_total=e.core_total,
                        enrichment_sourced=e.enrichment_sourced, enrichment_total=e.enrichment_total)


def _entity_out(e: AssessEntity, cols: list[AssessColumnMapping],
                structure: tuple[str, list[str]] = ("sound", []),
                col_profiles: dict[str, list[SourceProfileOut]] | None = None) -> AssessEntityOut:
    cols = sorted(cols, key=lambda c: c.target)
    if col_profiles is None:
        col_profiles = {}
    return AssessEntityOut(
        id=e.id, domain_run_id=e.domain_run_id, product_id=e.product_id, in_model=e.product_id is not None,
        name=e.name, grade=e.grade, coverage_pct=e.coverage_pct, primary_source=e.primary_source,
        row_count=e.row_count, net_new_candidate=e.net_new_candidate,
        mapped=sum(c.status == "mapped" for c in cols),
        gap=sum(c.status in ("gap", "null_source") for c in cols),
        deferred_fk=sum(c.status == "deferred_fk" for c in cols),
        dup_source=sum(c.dup_source for c in cols),
        core_sourced=e.core_sourced, core_total=e.core_total, enrichment_sourced=e.enrichment_sourced,
        enrichment_total=e.enrichment_total, deferred_fk_count=e.deferred_fk_count,
        enrichment_pct=enrichment_pct(e.enrichment_sourced, e.enrichment_total), letter_grade=_entity_letter(e),
        grade_reason=e.grade_reason, row_filter=e.row_filter,
        structure=structure[0], structure_refs=structure[1],
        columns=[ColumnMappingOut(
            id=c.id, entity_id=c.entity_id, attribute_id=c.attribute_id, in_model=c.attribute_id is not None,
            target=c.target, status=c.status, source_table=c.source_table, source_column=c.source_column,
            transform=c.transform, row_count=c.row_count, null_pct=c.null_pct, distinct_count=c.distinct_count,
            date_format=c.date_format, fk_orphans=c.fk_orphans, evidence=c.evidence, dup_source=c.dup_source,
            tier=c.tier, profiles_by_source=col_profiles.get(c.id, []))
            for c in cols])


def _summary_out(session: Session, domain_run_id: str) -> SummaryOut | None:
    sm = session.get(AssessSummary, domain_run_id)
    if sm is None:
        return None
    items = sorted(session.exec(select(AssessSummaryItem).where(AssessSummaryItem.summary_id == sm.domain_run_id)).all(),
                   key=lambda i: i.ordinal)
    return SummaryOut(headline=sm.headline, verdict=sm.verdict or None, verdict_reason=sm.verdict_reason,
                      key_findings=[i.text for i in items if i.kind == "finding"],
                      top_risks=[i.text for i in items if i.kind == "risk"],
                      recommended_next_step=sm.recommended_next_step)


@router.get("/assessment-domain-runs/{domain_run_id}/results", response_model=AssessResultsOut,
            operation_id="getAssessmentResults")
def get_assessment_results(domain_run_id: str, session: Dependencies.Session, ws: Dependencies.Client):
    """Everything the review UI needs for one domain run, assembled with one query per table."""
    dr = _require_domain_run(session, domain_run_id)
    ents = sorted(session.exec(select(AssessEntity).where(AssessEntity.domain_run_id == dr.id)).all(),
                  key=lambda e: (_GRADE_RANK.get(e.grade, 3), e.name))
    cols_by_entity: dict[str, list[AssessColumnMapping]] = {}
    col_profiles: dict[str, list[SourceProfileOut]] = {}  # column_id -> list of profiles
    if ents:
        col_ids = [e.id for e in ents]
        for c in session.exec(select(AssessColumnMapping)
                              .where(AssessColumnMapping.entity_id.in_(col_ids))).all():
            cols_by_entity.setdefault(c.entity_id, []).append(c)
        # One query for all profiles, grouped by column_id
        all_col_ids = [c.id for cols in cols_by_entity.values() for c in cols]
        if all_col_ids:
            for profile in session.exec(select(AssessColumnSourceProfile)
                                      .where(AssessColumnSourceProfile.column_id.in_(all_col_ids))
                                      .order_by(AssessColumnSourceProfile.column_id, AssessColumnSourceProfile.ordinal)).all():
                col_profiles.setdefault(profile.column_id, []).append(SourceProfileOut(
                    system=profile.system,
                    source_table=profile.source_table,
                    source_column=profile.source_column,
                    role=profile.role,
                    row_count=profile.row_count,
                    null_pct=profile.null_pct,
                    distinct_count=profile.distinct_count,
                    fk_orphans=profile.fk_orphans,
                    note=profile.note,
                ))
    decs = session.exec(select(AssessPendingDecision).where(AssessPendingDecision.domain_run_id == dr.id)
                        .order_by(AssessPendingDecision.ordinal, AssessPendingDecision.id)).all()
    opts_by_dec: dict[str, list[AssessDecisionOption]] = {}
    points_by_opt: dict[str, list[AssessDecisionOptionPoint]] = {}
    affected_by_dec: dict[str, list[AssessDecisionAffected]] = {}
    if decs:
        dec_ids = [d.id for d in decs]
        for o in session.exec(select(AssessDecisionOption).where(AssessDecisionOption.decision_id.in_(dec_ids))).all():
            opts_by_dec.setdefault(o.decision_id, []).append(o)
        opt_ids = [o.id for os_ in opts_by_dec.values() for o in os_]
        if opt_ids:
            for p in session.exec(select(AssessDecisionOptionPoint)
                                  .where(AssessDecisionOptionPoint.option_id.in_(opt_ids))).all():
                points_by_opt.setdefault(p.option_id, []).append(p)
        for a in session.exec(select(AssessDecisionAffected).where(AssessDecisionAffected.decision_id.in_(dec_ids))
                              .order_by(AssessDecisionAffected.ordinal, AssessDecisionAffected.id)).all():
            affected_by_dec.setdefault(a.decision_id, []).append(a)
    decs = sorted(decs, key=lambda d: not d.blocks_build)  # stable: blocking first, then stored order
    gaps = session.exec(select(AssessGap).where(AssessGap.domain_run_id == dr.id).order_by(AssessGap.id)).all()
    vibes = session.exec(select(AssessNextVibe).where(AssessNextVibe.domain_run_id == dr.id)).all()
    vibes = sorted(vibes, key=lambda v: (v.priority is None, v.priority if v.priority is not None else 0, v.ordinal, v.id))
    entities_by_vibe: dict[str, list[str]] = {}
    if vibes:
        for ve in session.exec(select(AssessNextVibeEntity)
                               .where(AssessNextVibeEntity.next_vibe_id.in_([v.id for v in vibes]))
                               .order_by(AssessNextVibeEntity.ordinal, AssessNextVibeEntity.id)).all():
            entities_by_vibe.setdefault(ve.next_vibe_id, []).append(ve.entity)
    # One query for the linked feedback items still active (same rule as ``_is_vibe_input_active``).
    linked_input_ids = [v.vibe_input_id for v in vibes if v.vibe_input_id]
    active_input_ids: set[str] = set()
    if linked_input_ids:
        active_input_ids = set(session.exec(
            select(VibeInput.id).where(VibeInput.id.in_(linked_input_ids),
                                       VibeInput.status == VibeInputStatus.ACTIVE.value,
                                       VibeInput.deprecated_by.is_(None))).all())
    grades = {"full": 0, "partial": 0, "blocked": 0}
    letter_counts = {k: 0 for k in "ABCDF"}
    for e in ents:
        if e.grade in grades:
            grades[e.grade] += 1
        letter = _entity_letter(e)
        if letter in letter_counts:
            letter_counts[letter] += 1
    decision_facts = [DecisionFacts(ordinal=d.ordinal, kind=_decision_kind(d), is_open=d.answer_status == "open",
                                    blocks_build=d.blocks_build, entity=d.entity,
                                    affected=tuple(a.entity for a in affected_by_dec.get(d.id, [])))
                      for d in decs]
    vibe_facts = [VibeFacts(priority=v.priority, urgency=v.urgency, ordinal=v.ordinal, affected_entities=tuple(entities_by_vibe.get(v.id, [])))
                  for v in vibes]
    structure_counts = {"sound": 0, "review": 0, "rework": 0}
    structure_by_entity: dict[str, tuple[str, list[str]]] = {}
    for e in ents:
        status, d_refs, v_refs = structure_grade(e.name, decision_facts, vibe_facts)
        structure_counts[status] += 1
        structure_by_entity[e.id] = (status, d_refs + v_refs)
    return AssessResultsOut(
        domain_run=_domain_run_out(session, ws, dr), grades=grades, letter_counts=letter_counts,
        structure_counts=structure_counts, summary=_summary_out(session, dr.id),
        entities=[_entity_out(e, cols_by_entity.get(e.id, []), structure_by_entity[e.id], col_profiles) for e in ents],
        gaps=[GapOut(id=g.id, domain_run_id=g.domain_run_id, entity=g.entity, column=g.column,
                     gap_type=g.gap_type, description=g.description, status=g.status, ask=g.ask) for g in gaps],
        pending_decisions=[_decision_out(d, opts_by_dec.get(d.id, []), points_by_opt, affected_by_dec.get(d.id, []))
                           for d in decs],
        next_vibes=[NextVibeOut(id=v.id, domain_run_id=v.domain_run_id, priority=v.priority,
                                category=v.category, text=v.text, confidence=v.confidence, problem=v.problem,
                                proposed_change=v.proposed_change, impact_if_skipped=v.impact_if_skipped,
                                urgency=v.urgency, affected_entities=entities_by_vibe.get(v.id, []),
                                feedback_input_id=v.vibe_input_id if v.vibe_input_id in active_input_ids else None)
                    for v in vibes])


def _doc_category(out_dir: str, path: str) -> str:
    rel = path[len(out_dir) + 1:] if path.startswith(out_dir + "/") else path
    if rel.startswith("docs/commentary/"):
        return "commentary"
    if rel.startswith("docs/design/"):
        return "design"
    return "other"


@router.get("/assessment-domain-runs/{domain_run_id}/docs", response_model=DocsOut,
            operation_id="listAssessmentDocs")
def list_assessment_docs(domain_run_id: str, session: Dependencies.Session, ws: Dependencies.Client,
                         config: Dependencies.Config):
    """Files under the run's ``docs`` folder in the runs Volume (capped), categorized, plus a folder link."""
    dr = _require_domain_run(session, domain_run_id)
    out_dir = dr.out_dir.rstrip("/")
    base = f"{out_dir}/docs"
    host = (ws.config.host or "").rstrip("/")
    catalog = resolve_metamodel_catalog(session, config)
    folder_url = (f"{host}/explore/data/volumes/{quote(catalog, safe='')}/_metamodel/{RUNS_VOLUME}"
                  f"?volumePath={quote(out_dir + '/')}")
    entries: list[DocEntry] = []
    try:
        for f in ws.files.list_directory_contents(base):
            if f.is_directory:
                # Recurse manually: the Files API listing is one level deep.
                stack = [f.path]
                while stack and len(entries) < DOCS_CAP * 2:
                    for g in ws.files.list_directory_contents(stack.pop()):
                        if g.is_directory:
                            stack.append(g.path)
                        else:
                            entries.append(DocEntry(path=g.path, name=g.name or g.path.rsplit("/", 1)[-1],
                                                    category=_doc_category(out_dir, g.path)))
            else:
                entries.append(DocEntry(path=f.path, name=f.name or f.path.rsplit("/", 1)[-1],
                                        category=_doc_category(out_dir, f.path)))
            if len(entries) >= DOCS_CAP * 2:
                break
    except NotFound:
        return DocsOut(folder_url=folder_url, docs=[])
    except DatabricksError as e:
        raise _run_help(
            ws, dr, f"Could not list run docs: {sanitize_error_message(str(e))}", runs_path=dr.out_dir) from e
    return DocsOut(folder_url=folder_url, docs=sorted(entries, key=lambda d: d.path)[:DOCS_CAP])


@router.get("/assessment-domain-runs/{domain_run_id}/docs/content", response_model=DocContentOut,
            operation_id="getAssessmentDocContent")
def get_assessment_doc_content(domain_run_id: str, path: str, session: Dependencies.Session,
                               ws: Dependencies.Client):
    """Text of one doc inside the run's folder (capped at 512 KB); the app SP reads the run Volume."""
    dr = _require_domain_run(session, domain_run_id)
    try:
        full = resolve_doc_path(dr.out_dir, path)
    except ValueError as e:
        raise HTTPException(422, str(e)) from e
    try:
        content, truncated = read_doc(ws, full)
    except NotFound:
        raise HTTPException(404, "Document not found.") from None
    except DatabricksError as e:
        raise _run_help(
            ws, dr, f"Could not read doc: {sanitize_error_message(str(e))}", runs_path=dr.out_dir) from e
    return DocContentOut(path=full, content=content, truncated=truncated)


def _require_decision(session: Session, decision_id: str) -> AssessPendingDecision:
    dec = session.get(AssessPendingDecision, decision_id)
    if dec is None:
        raise HTTPException(404, "Decision not found.")
    return dec


def _decision_response(session: Session, dec: AssessPendingDecision) -> PendingDecisionOut:
    opts = session.exec(select(AssessDecisionOption).where(AssessDecisionOption.decision_id == dec.id)).all()
    points: dict[str, list[AssessDecisionOptionPoint]] = {}
    if opts:
        for p in session.exec(select(AssessDecisionOptionPoint)
                              .where(AssessDecisionOptionPoint.option_id.in_([o.id for o in opts]))).all():
            points.setdefault(p.option_id, []).append(p)
    affected = session.exec(select(AssessDecisionAffected).where(AssessDecisionAffected.decision_id == dec.id)
                            .order_by(AssessDecisionAffected.ordinal, AssessDecisionAffected.id)).all()
    return _decision_out(dec, opts, points, list(affected))


@router.put("/assessment-decisions/{decision_id}/answer", response_model=PendingDecisionOut,
            operation_id="answerAssessmentDecision")
def answer_assessment_decision(decision_id: str, body: DecisionAnswerIn, session: Dependencies.Session,
                               headers: Dependencies.Headers, _role: Dependencies.ModelerOnly):
    dec = _require_decision(session, decision_id)
    if body.option_id:
        opt = session.get(AssessDecisionOption, body.option_id)
        if opt is None or opt.decision_id != dec.id:
            raise HTTPException(422, "Option does not belong to this decision.")
    dec.answer_status = "answered"
    dec.answer_option_id = body.option_id or None
    dec.answer_text = body.text.strip()
    dec.answered_by = actor_label(headers)
    dec.answered_at = datetime.now(timezone.utc)
    session.add(dec)
    session.commit()
    session.refresh(dec)
    return _decision_response(session, dec)


@router.delete("/assessment-decisions/{decision_id}/answer", response_model=PendingDecisionOut,
               operation_id="clearAssessmentDecisionAnswer")
def clear_assessment_decision_answer(decision_id: str, session: Dependencies.Session,
                                     _role: Dependencies.ModelerOnly):
    dec = _require_decision(session, decision_id)
    dec.answer_status, dec.answer_option_id, dec.answer_text = "open", None, ""
    dec.answered_by, dec.answered_at = "", None
    session.add(dec)
    session.commit()
    session.refresh(dec)
    return _decision_response(session, dec)


def _log_token_scopes(token: str | None) -> None:
    """INFO-log the forwarded token's granted scopes only (never the token or other claims)."""
    scopes = token_scopes(token) if token else None
    if scopes is not None:
        logger.info("Forwarded token scopes: %s", " ".join(scopes))


HANDOFF_FOLDER_PLACEHOLDER = "<your hand-off folder>"


def _handoff_out(session: Session, ws: WorkspaceClient, user_ws: WorkspaceClient | None, dr: AssessDomainRun,
                 path: str | None, h: AssessHandoff | None, email: str, token: str | None = None) -> HandoffOut:
    host = (ws.config.host or "").rstrip("/")
    expected = read_versions()["handoff_skills"]
    _log_token_scopes(token)
    skills, skills_note = skills_check_with_note(
        ws, user_ws, expected, user_email=email, bundled=read_bundled_skill_versions(expected))
    decs = session.exec(select(AssessPendingDecision).where(AssessPendingDecision.domain_run_id == dr.id)).all()
    summary = session.get(AssessSummary, dr.id)
    vibes = session.exec(select(AssessNextVibe).where(AssessNextVibe.domain_run_id == dr.id)).all()
    copied = h is not None or session.exec(
        select(AssessHandoff.id).where(AssessHandoff.domain_run_id == dr.id)).first() is not None
    open_ = [d for d in decs if d.answer_status == "open"]
    output_model = _require_batch(session, dr.batch_id).output_model
    steps = build_next_steps(
        verdict=(summary.verdict or None) if summary else None, open_blocking=sum(1 for d in open_ if d.blocks_build),
        open_total=len(open_), before_build_vibes=sum(1 for v in vibes if v.urgency == "before_build"),
        copied=copied, skills_ok=all(s.state == "present" for s in skills),
        blocked_entities=len(session.exec(select(AssessEntity.id).where(
            AssessEntity.domain_run_id == dr.id, AssessEntity.grade == "blocked")).all()),
        output_model=output_model)
    return HandoffOut(
        domain_run_id=dr.id, path=path, created_at=as_utc(h.created_at) if h else None,
        created_by=h.created_by if h else "", folder_url=f"{host}/#workspace{path}" if path else "",
        prompts=build_prompts(path or HANDOFF_FOLDER_PLACEHOLDER, output_model), skills=skills, next_steps=steps,
        user_scope_note=USER_SCOPE_NOTE, expected_handoffs=EXPECTED_HANDOFFS,
        skills_note=skills_note)


def _default_path(session: Session, dr: AssessDomainRun,
                  email: str) -> tuple[str | None, Business, Domain, ModelVersion]:
    """The caller's default hand-off folder (``None`` without an email) plus the run's business, domain, version."""
    batch = _require_batch(session, dr.batch_id)
    biz, dom, mv = session.get(Business, batch.business_id), session.get(Domain, dr.domain_id), session.get(ModelVersion, batch.version_id)
    return (default_handoff_path(email, biz.name, dom.name, batch.id) if email else None), biz, dom, mv


@router.get("/assessment-domain-runs/{domain_run_id}/handoff", response_model=HandoffOut,
            operation_id="getAssessmentHandoff")
def get_assessment_handoff(domain_run_id: str, session: Dependencies.Session, ws: Dependencies.Client,
                           user_ws: Dependencies.OptionalUserClient, headers: Dependencies.Headers):
    dr = _require_domain_run(session, domain_run_id)
    last = session.exec(select(AssessHandoff).where(AssessHandoff.domain_run_id == dr.id)
                        .order_by(AssessHandoff.created_at.desc())).first()
    email = current_user_email(headers) or ""
    return _handoff_out(session, ws, user_ws, dr, last.path if last else _default_path(session, dr, email)[0], last,
                        email, headers.token.get_secret_value() if headers.token else None)


@router.post("/assessment-domain-runs/{domain_run_id}/handoff", response_model=HandoffOut,
             operation_id="createAssessmentHandoff")
def create_assessment_handoff(domain_run_id: str, body: HandoffIn, session: Dependencies.Session,
                              ws: Dependencies.Client, user_ws: Dependencies.OptionalUserClient,
                              headers: Dependencies.Headers, _role: Dependencies.ModelerOnly):
    """Copy the run's project into the caller's home, written with the caller's own (OBO) token.

    Only a ``completed`` run hands off. A caller without a workspace email is
    401 ``identity_missing``. A missing OBO client, a scope error from the
    caller's token (sign in or re-consent), any other write failure and a
    failed read of the run's files are 409 ``admin_help`` with the real error
    and ``runs_path`` (the run's Volume folder), so the files can still be
    copied by hand.
    """
    dr = _require_domain_run(session, domain_run_id)
    if dr.status != "completed":
        raise HTTPException(409, "Hand-off is available once the assessment has completed with valid results.")
    email = require_user_email(headers)
    default, biz, dom, mv = _default_path(session, dr, email)
    path = body.path or default
    if not allowed_handoff_target(path, email):
        raise HTTPException(422, "Hand-off folder must be a subfolder of your own home folder "
                                 f"({user_home('<your email>')}/).")
    if user_ws is None:
        raise _run_help(
            ws, dr, "Sign in through the deployed app to hand off the assessment.", runs_path=dr.out_dir)
    readme = render_readme(business=biz.name, domain=dom.name, model_version=mv.version, batch_id=dr.batch_id,
                           dr=dr, prompts=build_prompts(path, _require_batch(session, dr.batch_id).output_model))
    try:
        h = handoff_domain_run(session, ws, user_ws, dr, path=path, user_email=email, readme=readme)
    except HandoffWriteError as e:
        error = sanitize_error_message(str(e.cause))
        if is_scope_error(e.cause):
            raise _run_help(ws, dr, scope_message("your workspace folder", error), runs_path=dr.out_dir) from e
        raise _run_help(ws, dr, f"Hand-off failed writing to the chosen folder: {error}",
                        runs_path=dr.out_dir) from e
    except DatabricksError as e:  # reading the run's files as the app
        raise _run_help(
            ws, dr, f"Hand-off failed reading the run's files: {sanitize_error_message(str(e))}",
            runs_path=dr.out_dir) from e
    return _handoff_out(session, ws, user_ws, dr, path, h, email,
                        headers.token.get_secret_value() if headers.token else None)


@router.post("/assessment-domain-runs/{domain_run_id}/handoff/install-skills", response_model=InstallSkillsOut,
             operation_id="installAssessmentSkills")
def install_assessment_skills(domain_run_id: str, body: InstallSkillsIn, session: Dependencies.Session,
                              ws: Dependencies.Client, user_ws: Dependencies.OptionalUserClient,
                              headers: Dependencies.Headers):
    """Install missing (or, on request, outdated) bundled skills into the caller's own Genie Code skills folder."""
    dr = _require_domain_run(session, domain_run_id)
    email = require_user_email(headers)
    _log_token_scopes(headers.token.get_secret_value() if headers.token else None)
    if user_ws is None:
        raise _run_help(ws, dr, "Sign in through the deployed app to install skills.")
    if resolve_vendored_assessment() is None:
        raise _run_help(ws, dr, "The app's bundled skills are missing — redeploy the app.")
    expected = read_versions()["handoff_skills"]
    bundled = read_bundled_skill_versions(expected)
    before = skills_check(ws, user_ws, expected, user_email=email, bundled=bundled)
    to_install, to_update, skipped = plan_install(before, body.names, body.update)
    current = ""
    try:
        for name in [*to_install, *to_update]:
            current = name
            install_skill(user_ws, name, email)
    except DatabricksError as e:
        if is_scope_error(e):
            raise _run_help(
                ws, dr, scope_message("your skills folder", sanitize_error_message(str(e)))) from e
        raise _run_help(ws, dr, (
            f"Updating {current} failed: {sanitize_error_message(str(e))}. "
            "Other skills may already be updated — Re-check to see the current state.")) from e
    return InstallSkillsOut(installed=to_install, updated=to_update, skipped=skipped,
                            skills=skills_check(ws, user_ws, expected, user_email=email, bundled=bundled))


# --- Next-vibe to feedback conversion (assessment results -> VibeInputs) ----------


def _map_urgency_to_priority(urgency: str) -> VibeInputPriority:
    """Map assessment urgency to feedback priority.

    Mapping:
    - before_build → high
    - during_build → medium
    - later → low
    - "" / other → medium (default)
    """
    mapping = {
        "before_build": VibeInputPriority.HIGH,
        "during_build": VibeInputPriority.MEDIUM,
        "later": VibeInputPriority.LOW,
    }
    return mapping.get(urgency, VibeInputPriority.MEDIUM)


def _compose_feedback_text(nv: AssessNextVibe, domain_name: str, batch_created_at: datetime) -> str:
    """Compose feedback text from next-vibe structured fields.

    Format:
    - Base: problem + " / " + proposed_change (if both present; otherwise just whichever is non-empty)
    - Impact trailer: "Why it matters: " + impact_if_skipped (if non-empty)
    - Reference: " (from assessment <date>, <domain_name>)"
    - Fallback: text as-is if all structured fields empty
    """
    parts = []
    if nv.problem and nv.proposed_change:
        parts.append(f"{nv.problem} / {nv.proposed_change}")
    elif nv.problem:
        parts.append(nv.problem)
    elif nv.proposed_change:
        parts.append(nv.proposed_change)

    base_text = " ".join(parts)
    if nv.impact_if_skipped:
        base_text += f"\n\nWhy it matters: {nv.impact_if_skipped}"

    # Add reference trailer with batch date and domain name.
    date_str = batch_created_at.date().isoformat()
    base_text += f" (from assessment {date_str}, {domain_name})"

    # Fallback: if no structured fields, use text as-is.
    if not parts and not nv.impact_if_skipped:
        return f"{nv.text} (from assessment {date_str}, {domain_name})"

    return base_text


def _is_vibe_input_active(vi: VibeInput) -> bool:
    """Check if a VibeInput is active (not deprecated)."""
    return vi.status == VibeInputStatus.ACTIVE.value and vi.deprecated_by is None


def _resolve_next_vibe_anchor(
    session: Session,
    affected_entities: list[str],
    dr: AssessDomainRun,
    batch: AssessBatch,
) -> tuple[FeedbackContext | None, str | None, bool]:
    """Resolve affected entities to a product anchor, or fall back to domain.

    Returns:
        (FeedbackContext, domain_id, needs_link_review) where:
        - FeedbackContext.selected_node_id is "domain.product" if exactly one product resolves
        - domain_id is the domain_id if falling back to domain anchor
        - needs_link_review signals unresolved entities
    """
    # Resolve entity names to products in the domain/version.
    domain_products = list(session.exec(select(Product).where(Product.domain_id == dr.domain_id)))
    products_by_name = {}
    for p in domain_products:
        if p.table_name:
            products_by_name[p.table_name.lower()] = p
        if p.name:
            products_by_name[p.name.lower()] = p

    needs_link_review = False
    resolved_products = []

    # Resolve all affected entities to products; fall back to domain if multiple resolve.
    for entity_name in affected_entities:
        product = products_by_name.get(entity_name.lower())
        if product:
            resolved_products.append(product)
        else:
            needs_link_review = True

    # Use product anchor only if exactly one entity resolves; else fall back to domain.
    resolved_product = None
    if len(resolved_products) == 1:
        resolved_product = resolved_products[0]

    # Build the FeedbackContext or return domain_id.
    selected_node_id = None
    domain_id_out = None
    if resolved_product:
        domain = session.get(Domain, dr.domain_id)
        if domain:
            selected_node_id = f"{domain.name}.{resolved_product.name}"
        ctx = FeedbackContext(selected_node_id=selected_node_id)
    else:
        # Fall back to domain anchor
        domain_id_out = dr.domain_id
        ctx = None

    return ctx, domain_id_out, needs_link_review


def _create_feedback_for_next_vibe(session: Session, nv: AssessNextVibe, dr: AssessDomainRun, batch: AssessBatch,
                                   affected_entities: list[str], domain_name: str, author: str) -> VibeInput:
    """Create the VibeInput for one next-vibe (flushed, not committed, not yet linked to the next-vibe)."""
    ctx, domain_id_fallback, needs_link_review = _resolve_next_vibe_anchor(session, affected_entities, dr, batch)
    vi = create_vibe_input_with_anchor(
        session=session,
        business_id=batch.business_id,
        text=_compose_feedback_text(nv, domain_name, batch.created_at),
        author=author,
        version_id=batch.version_id,
        origin=VibeInputOrigin.USER,
        priority=_map_urgency_to_priority(nv.urgency),
        confidence_score=float(nv.confidence) if nv.confidence else None,
        domain_id=domain_id_fallback,
        origin_context=ctx,
    )
    if needs_link_review:
        ctx_link = session.exec(
            select(VibeInputContextLink).where(VibeInputContextLink.input_id == vi.id)
        ).first()
        if ctx_link:
            ctx_link.needs_link_review = True
            session.add(ctx_link)
            session.flush()
    return vi


def _add_next_vibe_once(session: Session, next_vibe_id: str, dr: AssessDomainRun, batch: AssessBatch,
                        affected_entities: list[str], domain_name: str, author: str) -> NextVibeToFeedbackOut:
    """Add one next-vibe to feedback in its own transaction, at most once however many requests race.

    A link to an active VibeInput is reused. Otherwise a new VibeInput is created and linked with a
    compare-and-set on the link this request read (``vibe_input_id IS NOT DISTINCT FROM <seen>``). When
    another request linked it first, this transaction rolls back (its VibeInput with it) and the winner's
    item is returned with ``created=False``. Commits on success; any error rolls back and propagates.
    """
    nv = session.get(AssessNextVibe, next_vibe_id)
    if nv is None:
        raise HTTPException(404, detail={"message": "Next vibe not found"})
    seen = nv.vibe_input_id
    if seen:
        existing = session.get(VibeInput, seen)
        if existing and _is_vibe_input_active(existing):
            return NextVibeToFeedbackOut(next_vibe_id=next_vibe_id, feedback_input_id=existing.id, created=False)
    try:
        vi_id = _create_feedback_for_next_vibe(session, nv, dr, batch, affected_entities, domain_name, author).id
        linked = cast(CursorResult, session.execute(
            update(AssessNextVibe)
            .where(col(AssessNextVibe.id) == next_vibe_id, col(AssessNextVibe.vibe_input_id).is_not_distinct_from(seen))
            .values(vibe_input_id=vi_id)
            .execution_options(synchronize_session=False)
        )).rowcount
        if linked == 1:
            session.commit()
            return NextVibeToFeedbackOut(next_vibe_id=next_vibe_id, feedback_input_id=vi_id, created=True)
        session.rollback()
        winner = session.exec(select(AssessNextVibe.vibe_input_id).where(AssessNextVibe.id == next_vibe_id)).first()
    except Exception:
        session.rollback()
        raise
    if not winner:
        # A retry fixes this, so it's a plain message for the modeler, not the admin-help shape.
        raise HTTPException(409, detail={
            "message": "Another request changed this next vibe's feedback link at the same time; try again."})
    return NextVibeToFeedbackOut(next_vibe_id=next_vibe_id, feedback_input_id=winner, created=False)


@router.post(
    "/assessment-domain-runs/{domain_run_id}/next-vibes/{next_vibe_id}/feedback",
    response_model=NextVibeToFeedbackOut,
    operation_id="addNextVibeToFeedback",
)
def add_next_vibe_to_feedback(
    domain_run_id: str,
    next_vibe_id: str,
    session: Dependencies.Session,
    headers: Dependencies.Headers,
    _role: Dependencies.ModelerOnly,
) -> NextVibeToFeedbackOut:
    """Convert a single assessment next-vibe into a feedback item (VibeInput).

    If the vibe is already linked to an active VibeInput, returns the existing one (idempotent).
    If the linked input was deprecated, creates a new one. Concurrent requests (a double click, or
    this route racing the bulk route) still create one item: see ``_add_next_vibe_once``.

    Returns:
        NextVibeToFeedbackOut with feedback_input_id and created flag.

    Raises:
        404: domain_run or next_vibe not found, or vibe doesn't belong to domain_run.
    """
    dr = _require_domain_run(session, domain_run_id)
    nv = session.get(AssessNextVibe, next_vibe_id)
    if not nv or nv.domain_run_id != domain_run_id:
        raise HTTPException(404, detail={"message": "Next vibe not found"})

    batch = _require_batch(session, dr.batch_id)

    affected_entities = list(session.exec(
        select(AssessNextVibeEntity.entity)
        .where(AssessNextVibeEntity.next_vibe_id == nv.id)
        .order_by(AssessNextVibeEntity.ordinal, AssessNextVibeEntity.id)
    ))
    domain = session.get(Domain, dr.domain_id)
    try:
        return _add_next_vibe_once(session, next_vibe_id, dr, batch, affected_entities,
                                   domain.name if domain else "Unknown", actor_label(headers))
    except SQLAlchemyError as e:
        raise admin_help_error(
            f"Couldn't add the next vibe to feedback: {recorded_error_text(e, 'Adding a next vibe to feedback')}") from e


@router.post(
    "/assessment-domain-runs/{domain_run_id}/next-vibes/feedback/bulk",
    response_model=BulkNextVibeToFeedbackOut,
    operation_id="addNextVibesToFeedback",
)
def add_next_vibes_to_feedback(
    domain_run_id: str,
    body: BulkAddNextVibesToFeedbackIn,
    session: Dependencies.Session,
    headers: Dependencies.Headers,
    _role: Dependencies.ModelerOnly,
) -> BulkNextVibeToFeedbackOut:
    """Convert multiple assessment next-vibes into feedback items in bulk.

    Filters by urgency (before_build, during_build, later) or explicit ids, then creates
    VibeInputs for unlinked vibes, reusing existing active ones (idempotent). Each item commits on
    its own (``_add_next_vibe_once``, sorted by id); an explicit id that isn't a next vibe of this
    run, or an item whose create fails, is reported in ``failures`` and the rest still land.

    Returns:
        BulkNextVibeToFeedbackOut with counts and item details.

    Raises:
        404: domain_run not found.
        422: neither urgency nor ids provided (request validation), or unknown urgency value.
    """
    dr = _require_domain_run(session, domain_run_id)
    batch = _require_batch(session, dr.batch_id)

    vibes = list(session.exec(select(AssessNextVibe).where(AssessNextVibe.domain_run_id == dr.id)))
    failures: list[NextVibeFeedbackFailureOut] = []
    if body.ids:
        vibe_map = {v.id: v for v in vibes}
        filtered_vibes = [vibe_map[vid] for vid in body.ids if vid in vibe_map]
        failures += [NextVibeFeedbackFailureOut(next_vibe_id=vid, message="Next vibe not found in this assessment")
                     for vid in body.ids if vid not in vibe_map]
    else:  # the request model already refused a body with neither urgency nor ids (422)
        if body.urgency not in ("before_build", "during_build", "later"):
            raise HTTPException(422, detail={"message": f"Unknown urgency: {body.urgency}"})
        filtered_vibes = [v for v in vibes if v.urgency == body.urgency]

    entities_by_vibe: dict[str, list[str]] = {}
    if vibes:
        for ave in session.exec(
            select(AssessNextVibeEntity)
            .where(AssessNextVibeEntity.next_vibe_id.in_([v.id for v in vibes]))
            .order_by(AssessNextVibeEntity.ordinal, AssessNextVibeEntity.id)
        ):
            entities_by_vibe.setdefault(ave.next_vibe_id, []).append(ave.entity)

    items: list[NextVibeToFeedbackOut] = []
    author = actor_label(headers)
    domain = session.get(Domain, dr.domain_id)
    domain_name = domain.name if domain else "Unknown"

    # One transaction per item, in id order: a failed item lands in ``failures`` and the others still
    # commit, and concurrent bulk calls take the next-vibe row locks in the same order.
    for vid in sorted({v.id for v in filtered_vibes}):
        try:
            items.append(_add_next_vibe_once(session, vid, dr, batch, entities_by_vibe.get(vid, []),
                                             domain_name, author))
        except HTTPException as e:
            failures.append(NextVibeFeedbackFailureOut(
                next_vibe_id=vid, message=e.detail.get("message", "") if isinstance(e.detail, dict) else str(e.detail)))
        except Exception as e:  # noqa: BLE001 — one item's failure is reported; the other items still land
            logger.exception("adding next vibe %s to feedback failed", vid)
            detail = recorded_error_text(e, "Adding a next vibe to feedback")
            failures.append(NextVibeFeedbackFailureOut(
                next_vibe_id=vid, message=f"Couldn't add this next vibe to feedback: {detail}. "
                                          "Please contact your administrator with these details."))
    count_created = sum(1 for i in items if i.created)
    count_reused = len(items) - count_created

    return BulkNextVibeToFeedbackOut(
        count_created=count_created,
        count_reused=count_reused,
        items=items,
        failures=failures,
    )
