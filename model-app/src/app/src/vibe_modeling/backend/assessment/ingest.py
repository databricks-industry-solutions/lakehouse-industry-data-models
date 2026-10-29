"""Load a completed domain run's assessment.json into the assess_* result tables.

Ingest writes ``assess_*`` rows only. Before any row is written it checks the run's
output against fields only the notebook or the app wrote (never the LLM-written
assessment.json): the summary.json schema version, the domain, the pre-flight model
version check, and the launch's config.json. A refusal writes no result rows.
"""
from __future__ import annotations

import json
from collections import defaultdict
from dataclasses import dataclass

from databricks.sdk import WorkspaceClient
from databricks.sdk.errors.platform import NotFound
from pydantic import ValidationError
from sqlmodel import Session, delete, select

from ..db_models import (
    AssessBatch, AssessColumnMapping, AssessColumnSourceProfile, AssessDecisionAffected, AssessDecisionOption,
    AssessDecisionOptionPoint, AssessDomainRun, AssessEntity, AssessGap, AssessNextVibe, AssessNextVibeEntity,
    AssessPendingDecision, AssessSummary, AssessSummaryItem, Attribute, Domain, ModelVersion, Product,
)
from .constants import SUPPORTED_SCHEMA_VERSIONS
from .schemas import AssessmentDoc


@dataclass
class IngestResult:
    results_valid: bool
    error: str = ""


def read_volume_json(ws: WorkspaceClient, path: str) -> dict | None:
    """Download and parse a Volume JSON file; None when missing or not valid JSON."""
    try:
        return json.loads(ws.files.download(path).contents.read())
    except (NotFound, json.JSONDecodeError, UnicodeDecodeError):
        return None


def flag_duplicate_sources(mappings: list[AssessColumnMapping]) -> None:
    """Flag rows whose (source_table, source_column) feeds more than one distinct target."""
    by_src: dict[tuple[str, str], set[str]] = defaultdict(set)
    for m in mappings:
        if m.status in ("mapped", "derived") and m.source_table and m.source_column:
            by_src[(m.source_table.lower(), m.source_column.lower())].add(m.target.lower())
    dup = {k for k, targets in by_src.items() if len(targets) > 1}
    for m in mappings:
        eligible = m.status in ("mapped", "derived") and m.source_table and m.source_column
        m.dup_source = bool(eligible) and (m.source_table.lower(), m.source_column.lower()) in dup


def _norm_label(label: str | None) -> str:
    return (label or "").strip().casefold()


def _clear_children(session: Session, dr_id: str) -> tuple[dict[tuple[str, str], tuple], dict[tuple[int, str], str]]:
    """Delete prior results for the run; return recorded answers + vibe_input_id links.

    Returns:
        (answers, prior_links) where:
        - answers: {(gate, question): (status, text, by, at, label)}
        - prior_links: {(ordinal, text_normalized): vibe_input_id}
    """
    prior = list(session.exec(select(AssessPendingDecision).where(AssessPendingDecision.domain_run_id == dr_id)))
    answers = {}
    for d in prior:
        if d.answer_status == "answered":
            opt = session.get(AssessDecisionOption, d.answer_option_id) if d.answer_option_id else None
            answers[(d.gate, d.question)] = (d.answer_status, d.answer_text, d.answered_by, d.answered_at,
                                             _norm_label(opt.label) if opt else None)
    ent_ids = [e.id for e in session.exec(select(AssessEntity).where(AssessEntity.domain_run_id == dr_id))]
    dec_ids = [d.id for d in prior]
    nv_ids = [n.id for n in session.exec(select(AssessNextVibe).where(AssessNextVibe.domain_run_id == dr_id))]

    # Extract vibe_input_id links before deleting (preserve on re-ingest).
    prior_links = {}
    for n in session.exec(select(AssessNextVibe).where(AssessNextVibe.domain_run_id == dr_id)):
        if n.vibe_input_id:
            prior_links[(n.ordinal, n.text.strip().casefold())] = n.vibe_input_id

    # Children before parents; SQLite test engines do not enforce FK cascades.
    session.exec(delete(AssessSummaryItem).where(AssessSummaryItem.summary_id == dr_id))
    session.exec(delete(AssessSummary).where(AssessSummary.domain_run_id == dr_id))
    if ent_ids:
        col_ids = [c.id for c in session.exec(select(AssessColumnMapping)
                                              .where(AssessColumnMapping.entity_id.in_(ent_ids)))]
        if col_ids:
            session.exec(delete(AssessColumnSourceProfile).where(AssessColumnSourceProfile.column_id.in_(col_ids)))
        session.exec(delete(AssessColumnMapping).where(AssessColumnMapping.entity_id.in_(ent_ids)))
    if dec_ids:
        opt_ids = [o.id for o in session.exec(select(AssessDecisionOption)
                                              .where(AssessDecisionOption.decision_id.in_(dec_ids)))]
        if opt_ids:
            session.exec(delete(AssessDecisionOptionPoint).where(AssessDecisionOptionPoint.option_id.in_(opt_ids)))
        session.exec(delete(AssessDecisionAffected).where(AssessDecisionAffected.decision_id.in_(dec_ids)))
        # Null the self-references first so deleting options never trips the FKs.
        for d in prior:
            d.answer_option_id = None
            d.recommended_option_id = None
            session.add(d)
        session.flush()
        session.exec(delete(AssessDecisionOption).where(AssessDecisionOption.decision_id.in_(dec_ids)))
    if nv_ids:
        session.exec(delete(AssessNextVibeEntity).where(AssessNextVibeEntity.next_vibe_id.in_(nv_ids)))
    for model in (AssessEntity, AssessGap, AssessPendingDecision, AssessNextVibe):
        session.exec(delete(model).where(model.domain_run_id == dr_id))
    session.expire_all()
    return answers, prior_links


def _schema_version(summary: dict) -> int | None:
    v = summary.get("schema_version")
    return v if isinstance(v, int) and not isinstance(v, bool) else None


def version_check_ok(check: object) -> bool:
    """The notebook's pre-flight model version check passed (``ok``) or was skipped (``skipped...``)."""
    return check == "ok" or (isinstance(check, str) and check.startswith("skipped"))


def pin_mismatch(session: Session, ws: WorkspaceClient, dr: AssessDomainRun, summary: dict) -> str:
    """Why the run's output can't be this run's, or '' when it matches.

    Uses only notebook-written summary.json fields (``domain``, ``preflight.version_check``)
    and the app-written config.json (``batch_id``, ``domain``, ``model_version``).
    """
    domain = session.get(Domain, dr.domain_id)
    batch = session.get(AssessBatch, dr.batch_id)
    mv = session.get(ModelVersion, batch.version_id) if batch else None
    if domain is None or mv is None:
        return "the run's domain or model version no longer exists"
    if summary.get("domain") != domain.name:
        return f"summary.json is for domain {summary.get('domain')!r}, but this run assessed {domain.name!r}"
    preflight = summary.get("preflight")
    check = preflight.get("version_check") if isinstance(preflight, dict) else None
    if not version_check_ok(check):
        return f"the pre-flight model version check is {check!r}, expected ok or skipped"
    cfg = read_volume_json(ws, dr.config_path) if dr.config_path else None
    if not isinstance(cfg, dict):
        return "the launch's config.json is missing or not valid JSON"
    if cfg.get("batch_id") != dr.batch_id:
        return f"config.json is for batch {cfg.get('batch_id')!r}, but this run is in batch {dr.batch_id!r}"
    if cfg.get("domain") != domain.name:
        return f"config.json is for domain {cfg.get('domain')!r}, but this run assessed {domain.name!r}"
    if str(cfg.get("model_version")) != str(mv.version):
        return f"config.json pins model version {cfg.get('model_version')!r}, but this run is for version {mv.version}"
    return ""


def ingest_domain_run(session: Session, ws: WorkspaceClient, dr: AssessDomainRun) -> IngestResult:
    """Ingest one successful run, or refuse it with a reason and no result rows.

    Volume or database errors raise; the poller retries them inside its attempt window.
    """
    summary = read_volume_json(ws, f"{dr.out_dir}/summary.json")
    if not isinstance(summary, dict):
        return _invalid(session, dr, "summary.json not found or not valid JSON")
    raw_skills = summary.get("skills")
    skills: dict = raw_skills if isinstance(raw_skills, dict) else {}
    dr.skills_commit = skills.get("commit") or ""
    dr.skills_version = skills.get("version") or ""
    dr.genie_version = summary.get("genie_version") or dr.genie_version
    dr.schema_version = _schema_version(summary)
    if dr.schema_version not in SUPPORTED_SCHEMA_VERSIONS:
        supported = ", ".join(str(v) for v in sorted(SUPPORTED_SCHEMA_VERSIONS))
        return _invalid(session, dr, f"Results refused: summary.json schema_version is "
                                     f"{summary.get('schema_version')!r}; this app supports {supported}")
    mismatch = pin_mismatch(session, ws, dr, summary)
    if mismatch:
        return _invalid(session, dr, f"Results refused: {mismatch}")
    if summary.get("results_valid") is not True:
        errs = summary.get("validation_errors") if isinstance(summary.get("validation_errors"), list) else []
        detail = f": {'; '.join(str(e) for e in errs[:3])}" if errs else ""
        return _invalid(session, dr, f"Results refused: the notebook reported results_valid="
                                     f"{json.dumps(summary.get('results_valid'))}{detail}")
    raw = read_volume_json(ws, f"{dr.out_dir}/docs/design/assessment.json")
    if raw is None:
        return _invalid(session, dr, "assessment.json not found or not valid JSON")
    try:
        doc = AssessmentDoc.model_validate(raw)
    except ValidationError as e:
        return _invalid(session, dr, f"assessment.json failed validation: {e.errors()[:3]}")

    # Entity name -> Product within the run's domain, by name or table_name (case-insensitive).
    domain_products = list(session.exec(select(Product).where(Product.domain_id == dr.domain_id)))
    products = {p.table_name.lower(): p for p in domain_products if p.table_name}
    products.update({p.name.lower(): p for p in domain_products if p.name})

    answers, prior_links = _clear_children(session, dr.id)
    mappings: list[AssessColumnMapping] = []
    col_profiles: list[tuple[AssessColumnMapping, list]] = []
    for e in doc.entities:
        p = products.get(e.name.lower())
        attrs: dict[str, Attribute] = {}
        if p:
            # A name match wins over a column_name match, so names go in second.
            product_attrs = list(session.exec(select(Attribute).where(Attribute.product_id == p.id)))
            attrs = {a.column_name.lower(): a for a in product_attrs if a.column_name}
            attrs.update({a.name.lower(): a for a in product_attrs if a.name})
        ent = AssessEntity(domain_run_id=dr.id, product_id=p.id if p else None, name=e.name, grade=e.grade,
                           coverage_pct=e.coverage_pct, primary_source=e.primary_source, row_count=e.row_count,
                           net_new_candidate=e.net_new_candidate, core_sourced=e.core_sourced,
                           core_total=e.core_total, enrichment_sourced=e.enrichment_sourced,
                           enrichment_total=e.enrichment_total, deferred_fk_count=e.deferred_fk_count,
                           grade_reason=e.grade_reason, row_filter=e.row_filter,
                           reported_letter=e.letter_grade or "",
                           reported_structure=e.structure or "")
        session.add(ent)
        session.flush()
        for c in e.columns:
            a = attrs.get(c.target.lower())
            col_data = {**c.model_dump(exclude={"profiles_by_source"}), "tier": c.tier or ""}
            m = AssessColumnMapping(entity_id=ent.id, attribute_id=a.id if a else None, **col_data)
            mappings.append(m)
            col_profiles.append((m, c.profiles_by_source))
    flag_duplicate_sources(mappings)
    session.add_all(mappings)
    session.flush()

    for m, profiles in col_profiles:
        for ordinal, profile in enumerate(profiles):
            session.add(AssessColumnSourceProfile(
                column_id=m.id, ordinal=ordinal, system=profile.system, source_table=profile.source_table,
                source_column=profile.source_column, role=profile.role,
                row_count=profile.rows,  # JSON key 'rows' -> DB column 'row_count'
                null_pct=profile.null_pct, distinct_count=profile.distinct_count,
                fk_orphans=profile.fk_orphans, note=profile.note))
    for g in doc.gaps:
        session.add(AssessGap(domain_run_id=dr.id, **g.model_dump()))
    sm = doc.executive_summary
    if sm and (sm.headline or sm.verdict or sm.verdict_reason or sm.recommended_next_step
               or sm.key_findings or sm.top_risks):
        session.add(AssessSummary(domain_run_id=dr.id, headline=sm.headline, verdict=sm.verdict or "",
                                  verdict_reason=sm.verdict_reason, recommended_next_step=sm.recommended_next_step))
        session.flush()
        for kind, texts in (("finding", sm.key_findings), ("risk", sm.top_risks)):
            session.add_all([AssessSummaryItem(summary_id=dr.id, kind=kind, ordinal=i, text=t)
                             for i, t in enumerate(texts)])
    for di, d in enumerate(doc.pending_decisions):
        dec = AssessPendingDecision(domain_run_id=dr.id, ordinal=di, gate=d.gate, kind=d.kind or "",
                                    question=d.question,
                                    default_taken=d.default_taken, evidence=d.evidence, entity=d.entity,
                                    context=d.context, why_it_matters=d.why_it_matters,
                                    recommendation_rationale=d.recommendation_rationale,
                                    blocks_build=d.blocks_build)
        session.add(dec)
        session.flush()
        opts = [AssessDecisionOption(decision_id=dec.id, ordinal=i, label=o.label, impact=o.impact)
                for i, o in enumerate(d.options)]
        session.add_all(opts)
        session.flush()
        for opt, o in zip(opts, d.options):
            session.add_all([AssessDecisionOptionPoint(option_id=opt.id, kind=kind, ordinal=i, text=t)
                             for kind, texts in (("pro", o.pros), ("con", o.cons)) for i, t in enumerate(texts)])
        session.add_all([AssessDecisionAffected(decision_id=dec.id, ordinal=i, entity=a.entity, column=a.column)
                         for i, a in enumerate(d.affected)])
        rec = _norm_label(d.recommended_option)
        dec.recommended_option_id = next((o.id for o in opts if _norm_label(o.label) == rec), None) if rec else None
        prev = answers.get((d.gate, d.question))
        if prev:
            dec.answer_status, dec.answer_text, dec.answered_by, dec.answered_at, label = prev
            dec.answer_option_id = next((o.id for o in opts if label and _norm_label(o.label) == label), None)
    for ni, n in enumerate(doc.next_vibes):
        # Restore vibe_input_id link by matching (ordinal, text_normalized). This is deliberately
        # conservative: if ordinal or text changed, the link is lost. User can re-add if needed.
        nv = AssessNextVibe(domain_run_id=dr.id, ordinal=ni, priority=n.priority, category=n.category, text=n.text,
                            confidence=n.confidence, problem=n.problem, proposed_change=n.proposed_change,
                            impact_if_skipped=n.impact_if_skipped, urgency=n.urgency or "",
                            vibe_input_id=prior_links.get((ni, n.text.strip().casefold())))
        session.add(nv)
        session.flush()
        session.add_all([AssessNextVibeEntity(next_vibe_id=nv.id, ordinal=i, entity=ent)
                         for i, ent in enumerate(n.affected_entities)])
    dr.model_quality_score = doc.model_quality_score
    dr.metamodel_location = doc.metamodel.location
    dr.metamodel_version = doc.metamodel.version
    dr.results_valid = True
    session.add(dr)
    session.commit()
    return IngestResult(results_valid=True)


def _invalid(session: Session, dr: AssessDomainRun, msg: str) -> IngestResult:
    dr.results_valid = False
    session.add(dr)
    session.commit()
    return IngestResult(results_valid=False, error=msg)
