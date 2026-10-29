"""Pydantic In/Out models for the headless-assessment API."""
from __future__ import annotations

import re
from datetime import datetime
from typing import Literal, Optional

from pydantic import BaseModel, Field, field_validator, model_validator

from .constants import INGEST_MAX_ATTEMPTS


class AssessConfigIn(BaseModel):
    reader_application_id: str = Field(min_length=1)
    max_concurrent_runs: int = Field(default=2, ge=1, le=5)
    default_reasoning_effort: Literal["low", "medium", "high"] = "high"
    warehouse_id: str = ""


class AssessConfigOut(BaseModel):
    reader_application_id: str
    reader_display_name: str = ""
    job_id: Optional[int]
    workspace_path: str
    max_concurrent_runs: int
    default_reasoning_effort: str
    warehouse_id: str
    genie_version: str
    skills_ref: str
    skills_version: str
    installed: bool
    ready: bool
    missing: list[str]
    job_url: str
    updated_at: datetime
    updated_by: str
    app_application_id: str = ""  # the app's own service principal; shown in Settings setup steps


class Check(BaseModel):
    key: str
    label: str
    state: Literal["ok", "blocked", "unverified"]
    detail: str = ""
    fix_sql: str = ""
    fix_action: str = ""  # "" | open_settings | warehouse_permissions | admin_help


class SourceIn(BaseModel):
    source_name: str = Field(min_length=1, pattern=r"^[A-Za-z0-9_]+$")
    catalog_name: str = Field(min_length=1, pattern=r"^[A-Za-z0-9_\-]+$")
    schema_name: str = Field(min_length=1, pattern=r"^[A-Za-z0-9_\-]+$")


class DomainSourcesIn(BaseModel):
    domain_id: str
    sources: list[SourceIn] = Field(min_length=1)


class ReadinessIn(BaseModel):
    version_id: str
    domains: list[DomainSourcesIn] = Field(min_length=1)


class DomainReadiness(BaseModel):
    domain_id: str
    domain_name: str
    checks: list[Check]
    blocked: bool


class ReadinessOut(BaseModel):
    global_checks: list[Check]
    domains: list[DomainReadiness]


class AssessBatchIn(BaseModel):
    version_id: str
    domains: list[DomainSourcesIn] = Field(min_length=1)
    output_model: Literal["normalized", "dimensional", "hybrid"] = "hybrid"
    etl_type: Literal["sdp_pipeline", "notebook"] = "sdp_pipeline"
    reasoning_effort: Literal["low", "medium", "high"] = "high"
    reuse_prior_tiers: bool = True


class AssessRelaunchIn(BaseModel):
    """None => every failed / cancelled / results_invalid domain run of the batch."""
    domain_run_ids: Optional[list[str]] = None


class SourceMapIn(BaseModel):
    sources: list[SourceIn]


class SourceMapOut(BaseModel):
    sources: list[SourceIn]


class AssessDomainRunOut(BaseModel):
    id: str
    domain_id: str
    domain_name: str
    databricks_run_id: Optional[int]
    run_url: str
    status: str
    stage: str
    attempt: int
    resume_at: Optional[datetime]
    last_message: str
    error_message: str
    started_at: Optional[datetime]
    ended_at: Optional[datetime]
    skills_commit: str
    skills_version: str
    genie_version: str
    model_quality_score: Optional[float]
    metamodel_location: str
    metamodel_version: str
    results_valid: Optional[bool]
    sources: list[SourceIn]
    job_url: str = ""  # from the run's own job_id, so links survive a recreated job
    job_reader: str = ""  # the reader service principal the run ran as
    schema_version: Optional[int] = None  # assessment.json contract version the run declared (summary.json)
    runs_path: str = ""  # the run's runs-volume folder (out_dir), as in the admin-help runs_path
    ingest_attempts: int = 0  # failed attempts to save the results so far
    ingest_next_at: Optional[datetime] = None  # next try while saving the results is being retried (UTC)
    ingest_max_attempts: int = INGEST_MAX_ATTEMPTS  # the run ends results_invalid after this many failures


class AssessBatchOut(BaseModel):
    id: str
    business_id: str
    version_id: str
    version: int
    scope: str
    output_model: str
    etl_type: str
    reasoning_effort: str
    status: str
    created_by: str
    created_at: datetime
    domain_runs: list[AssessDomainRunOut]


class SourceProfileOut(BaseModel):
    """Per-source profile for a column (when multiple sources contribute or grain differs)."""
    system: str
    source_table: str
    source_column: str
    role: str
    row_count: Optional[int]  # mapped from JSON key 'rows'
    null_pct: Optional[float]
    distinct_count: Optional[int]
    fk_orphans: Optional[int]
    note: str


class ColumnMappingOut(BaseModel):
    id: str
    entity_id: str
    attribute_id: Optional[str]
    in_model: bool
    target: str
    status: str
    source_table: str
    source_column: str
    transform: str
    row_count: Optional[int]
    null_pct: Optional[float]
    distinct_count: Optional[int]
    date_format: str
    fk_orphans: Optional[int]
    evidence: str
    dup_source: bool
    tier: str  # core | enrichment | "" (deferred_fk / technical / unknown)
    profiles_by_source: list[SourceProfileOut] = []


class AssessEntityOut(BaseModel):
    id: str
    domain_run_id: str
    product_id: Optional[str]
    in_model: bool
    name: str
    grade: str
    coverage_pct: Optional[float]
    primary_source: str
    row_count: Optional[int]
    net_new_candidate: bool
    mapped: int
    gap: int
    deferred_fk: int
    dup_source: int
    columns: list[ColumnMappingOut]
    core_sourced: Optional[int]
    core_total: Optional[int]
    enrichment_sourced: Optional[int]
    enrichment_total: Optional[int]
    deferred_fk_count: Optional[int]
    enrichment_pct: Optional[float]  # computed from the stored counts; None for old runs
    letter_grade: Optional[str]  # computed A/B/C/D/F; None when counts are missing (Blocked is always F)
    grade_reason: str
    row_filter: str
    structure: Literal["sound", "review", "rework"]  # computed at read time from open structure decisions/vibes
    structure_refs: list[str]  # driving refs, e.g. ["D3"] or ["Vibe 2"]


class GapOut(BaseModel):
    id: str
    domain_run_id: str
    entity: str
    column: str
    gap_type: str
    description: str
    status: str
    ask: str


class DecisionOptionOut(BaseModel):
    id: str
    ordinal: int
    label: str
    pros: list[str]
    cons: list[str]
    impact: str
    recommended: bool  # derived from the decision's recommended_option_id


class DecisionAffectedOut(BaseModel):
    entity: str
    column: str


class PendingDecisionOut(BaseModel):
    id: str
    domain_run_id: str
    gate: str
    question: str
    default_taken: str
    evidence: str
    entity: str
    answer_status: str
    answer_option_id: Optional[str]
    answer_text: str
    answered_by: str
    answered_at: Optional[datetime]
    options: list[DecisionOptionOut]
    context: str
    why_it_matters: str
    recommendation_rationale: str
    blocks_build: bool
    affected: list[DecisionAffectedOut]
    kind: Literal["structure", "source", "scope"]  # stored value, or the gate-text fallback for old runs
    ordinal: int  # document order (0-based); the UI labels the card D{ordinal+1}, matching structure_refs


class NextVibeOut(BaseModel):
    id: str
    domain_run_id: str
    priority: Optional[int]
    category: str
    text: str
    confidence: Optional[float]
    problem: str
    proposed_change: str
    impact_if_skipped: str
    urgency: str  # before_build | during_build | later | ""
    affected_entities: list[str]
    feedback_input_id: Optional[str] = None  # FK to vibe_inputs when linked; null if unlinked or linked input is deprecated


class NextVibeToFeedbackOut(BaseModel):
    """Response when converting a single next-vibe to feedback."""
    next_vibe_id: str
    feedback_input_id: str
    created: bool  # True if new VibeInput; False if reused existing


class BulkAddNextVibesToFeedbackIn(BaseModel):
    """Request to convert multiple next-vibes to feedback."""
    urgency: Optional[str] = None  # before_build | during_build | later
    ids: Optional[list[str]] = None  # explicit next_vibe_ids

    @model_validator(mode="after")
    def _validate_urgency_or_ids(self):
        if not self.urgency and not self.ids:
            raise ValueError("Provide either urgency or ids")
        return self


class NextVibeFeedbackFailureOut(BaseModel):
    """One next-vibe the bulk conversion could not add to feedback."""
    next_vibe_id: str
    message: str


class BulkNextVibeToFeedbackOut(BaseModel):
    """Response when converting multiple next-vibes to feedback."""
    count_created: int  # newly created VibeInputs
    count_reused: int  # pre-existing VibeInputs
    items: list[NextVibeToFeedbackOut]
    failures: list[NextVibeFeedbackFailureOut] = []  # per-item failures; the other items still land


class DocEntry(BaseModel):
    path: str
    name: str
    category: Literal["design", "commentary", "other"]


class DocsOut(BaseModel):
    folder_url: str
    docs: list[DocEntry]


class DocContentOut(BaseModel):
    path: str
    content: str
    truncated: bool


class SummaryOut(BaseModel):
    headline: str
    verdict: Optional[str]
    verdict_reason: str
    key_findings: list[str]
    top_risks: list[str]
    recommended_next_step: str


class AssessResultsOut(BaseModel):
    domain_run: AssessDomainRunOut
    grades: dict[str, int]
    summary: Optional[SummaryOut]
    letter_counts: dict[str, int]  # keys A, B, C, D, F always present (zeros included)
    structure_counts: dict[str, int]  # keys sound, review, rework always present (zeros included)
    entities: list[AssessEntityOut]
    gaps: list[GapOut]
    pending_decisions: list[PendingDecisionOut]
    next_vibes: list[NextVibeOut]


class DecisionAnswerIn(BaseModel):
    option_id: Optional[str] = None
    text: str = ""

    @model_validator(mode="after")
    def _needs_option_or_text(self):
        if not self.option_id and not self.text.strip():
            raise ValueError("Provide an option_id or non-empty text.")
        return self


_HANDOFF_PATH_RE = re.compile(r"^/Workspace/[A-Za-z0-9_\-./ @+]+$")


class HandoffIn(BaseModel):
    path: Optional[str] = None

    @field_validator("path")
    @classmethod
    def _safe_path(cls, v: Optional[str]) -> Optional[str]:
        if v is None:
            return v
        if not _HANDOFF_PATH_RE.fullmatch(v) or any(
                not seg or seg != seg.strip() or seg.startswith(".") for seg in v.split("/")[1:]):
            raise ValueError("path must be an absolute /Workspace/... folder with no blank, padded or dot-leading "
                             "segments and only letters, digits, space and _-./@+")
        return v


class HandoffPrompt(BaseModel):
    key: Literal["continue", "build", "validate", "gold", "build_gold", "validate_gold", "document"]
    title: str
    skill: str
    prompt: str


class SkillStatus(BaseModel):
    name: str
    state: Literal["present", "update_available", "missing", "unknown"]
    location: Literal["user", "workspace", "none"] = "none"
    bundled_version: str = ""
    installed_version: str = ""


class NextStepOut(BaseModel):
    order: int
    title: str
    detail: str
    done: bool = False


class InstallSkillsIn(BaseModel):
    names: list[str] = []
    update: list[str] = []


class InstallSkillsOut(BaseModel):
    installed: list[str]
    updated: list[str]
    skipped: list[str]
    skills: list[SkillStatus]


class HandoffOut(BaseModel):
    domain_run_id: str
    path: Optional[str]
    created_at: Optional[datetime]
    created_by: str
    folder_url: str
    prompts: list[HandoffPrompt]
    skills: list[SkillStatus]
    next_steps: list[NextStepOut]
    user_scope_note: str
    expected_handoffs: list[str]
    skills_note: str = ""  # what couldn't be read, in plain words ("" when every skills folder was read)


def _norm_enum(v, allowed: set[str]) -> Optional[str]:
    """Lenient enum: lowercase, spaces/hyphens -> underscore; anything outside ``allowed`` becomes None."""
    if v is None:
        return None
    s = re.sub(r"[\s\-]+", "_", str(v).strip().lower())
    return s if s in allowed else None


def _str_list(v) -> list[str]:
    """Lenient list[str]: None -> [], a single str wraps, non-str items are str()'d."""
    if v is None:
        return []
    if isinstance(v, (str, int, float)):
        return [str(v)]
    if not isinstance(v, (list, tuple, set, frozenset, dict)):
        return []
    return [x if isinstance(x, str) else str(x) for x in v if x is not None]


def _none_to_empty(v):
    """Before-validator for new plain-string fields: an explicit JSON null reads as ""."""
    return "" if v is None else v


def _lenient_int(v) -> Optional[int]:
    if isinstance(v, bool) or v is None:
        return None
    try:
        return int(float(str(v).strip()))
    except (ValueError, TypeError, OverflowError):
        return None


def _lenient_float(v) -> Optional[float]:
    if v is None:
        return None
    try:
        return float(str(v).strip())
    except (ValueError, TypeError, OverflowError):
        return None


class _SourceProfile(BaseModel):
    model_config = {"extra": "ignore"}

    system: str = ""
    source_table: str = ""
    source_column: str = ""
    role: str = ""
    rows: Optional[int] = None  # JSON key; DB stores as row_count
    null_pct: Optional[float] = None
    distinct_count: Optional[int] = None
    fk_orphans: Optional[int] = None
    note: str = ""

    @field_validator("system", "source_table", "source_column", "role", "note", mode="before")
    @classmethod
    def _str_fields(cls, v):
        return _none_to_empty(v)

    @field_validator("rows", "distinct_count", "fk_orphans", mode="before")
    @classmethod
    def _int_fields(cls, v):
        return _lenient_int(v)

    @field_validator("null_pct", mode="before")
    @classmethod
    def _float_field(cls, v):
        return _lenient_float(v)

    @field_validator("role", mode="before")
    @classmethod
    def _lowercase_role(cls, v):
        v = _none_to_empty(v)
        return v.lower() if v else v


class _Col(BaseModel):
    model_config = {"extra": "ignore"}
    target: str
    status: Literal["mapped", "derived", "gap", "null_source", "deferred_fk"]
    source_table: str = ""
    source_column: str = ""
    transform: str = ""
    row_count: Optional[int] = None
    null_pct: Optional[float] = None
    distinct_count: Optional[int] = None
    date_format: str = ""
    fk_orphans: Optional[int] = None
    evidence: str = ""
    tier: Optional[str] = None  # core | enrichment | deferred_fk | technical; off-values -> None
    profiles_by_source: list[_SourceProfile] = []

    @field_validator("profiles_by_source", mode="before")
    @classmethod
    def _profiles(cls, v):
        """Lenient list: null or non-list -> [], drop non-dict items and items with all three key fields empty."""
        if v is None:
            return []
        if not isinstance(v, (list, tuple)):
            return []
        out = []
        for item in v:
            if isinstance(item, dict):
                # Drop items with system, source_table, and source_column all empty
                if not (item.get("system") or item.get("source_table") or item.get("source_column")):
                    continue
                out.append(item)
        return out

    @field_validator("tier", mode="before")
    @classmethod
    def _tier(cls, v):
        return _norm_enum(v, {"core", "enrichment", "deferred_fk", "technical"})


class _Entity(BaseModel):
    model_config = {"extra": "ignore"}

    _nulls = field_validator("grade_reason", "row_filter", mode="before")(_none_to_empty)
    name: str
    grade: Literal["full", "partial", "blocked"]
    coverage_pct: Optional[float] = None
    primary_source: str = ""
    row_count: Optional[int] = None
    net_new_candidate: bool = False
    columns: list[_Col] = []
    core_sourced: Optional[int] = None
    core_total: Optional[int] = None
    enrichment_sourced: Optional[int] = None
    enrichment_total: Optional[int] = None
    deferred_fk_count: Optional[int] = None
    grade_reason: str = ""
    row_filter: str = ""
    letter_grade: Optional[str] = None  # A-F as written in the S2T grade line; anything else -> None
    structure: Optional[str] = None  # sound | review | rework self-report (diagnostics only); off-values -> None

    @field_validator("structure", mode="before")
    @classmethod
    def _structure(cls, v):
        return _norm_enum(v, {"sound", "review", "rework"})

    @field_validator("core_sourced", "core_total", "enrichment_sourced", "enrichment_total", "deferred_fk_count",
                     mode="before")
    @classmethod
    def _counts(cls, v):
        return _lenient_int(v)

    @field_validator("letter_grade", mode="before")
    @classmethod
    def _letter(cls, v):
        v = str(v).strip().upper() if v is not None else None
        return v if v in {"A", "B", "C", "D", "F"} else None


class _Gap(BaseModel):
    model_config = {"extra": "ignore"}
    entity: str = ""
    column: str = ""
    gap_type: str = ""
    description: str
    status: Literal["OPEN", "IN_PROGRESS", "DEFERRED", "ACCEPTED", "RESOLVED"] = "OPEN"
    ask: str = ""


class _Option(BaseModel):
    model_config = {"extra": "ignore"}

    _nulls = field_validator("impact", mode="before")(_none_to_empty)
    label: str
    pros: list[str] = []
    cons: list[str] = []
    impact: str = ""

    @field_validator("pros", "cons", mode="before")
    @classmethod
    def _lists(cls, v):
        return _str_list(v)


class _Affected(BaseModel):
    model_config = {"extra": "ignore"}
    entity: str
    column: str = ""


class _Decision(BaseModel):
    model_config = {"extra": "ignore"}

    _nulls = field_validator("context", "why_it_matters", "recommended_option", "recommendation_rationale", mode="before")(_none_to_empty)
    gate: str = ""
    question: str
    options: list[_Option] = []

    @field_validator("options", mode="before")
    @classmethod
    def _opts(cls, v):
        out = []
        for o in v or []:
            if isinstance(o, str):
                out.append({"label": o})
            elif isinstance(o, dict) and isinstance(o.get("label"), str) and o["label"]:
                out.append(o)  # option objects without a label are dropped
        return out

    @field_validator("affected", mode="before")
    @classmethod
    def _affected(cls, v):
        if v is None:
            return []
        if isinstance(v, (str, dict)):
            v = [v]
        if not isinstance(v, (list, tuple)):
            return []
        out = []
        for a in v:
            if isinstance(a, str):
                ent, _, col = a.partition(".")
                out.append({"entity": ent, "column": col})
            elif isinstance(a, dict) and isinstance(a.get("entity"), str):
                out.append({**a, "column": a.get("column") or ""})
        return out

    @field_validator("kind", mode="before")
    @classmethod
    def _kind(cls, v):
        return _norm_enum(v, {"structure", "source", "scope"})

    @field_validator("blocks_build", mode="before")
    @classmethod
    def _blocks(cls, v):
        if isinstance(v, bool):
            return v
        if v is None:
            return False
        if isinstance(v, (int, float)):
            return bool(v)
        return isinstance(v, str) and v.strip().lower() in {"yes", "true", "y"}

    context: str = ""
    why_it_matters: str = ""
    recommended_option: str = ""
    recommendation_rationale: str = ""
    blocks_build: bool = False
    kind: Optional[str] = None  # structure | source | scope; off-values -> None (old runs: gate-text fallback)
    affected: list[_Affected] = []
    default_taken: str
    evidence: str = ""
    entity: str = ""


class _NextVibe(BaseModel):
    model_config = {"extra": "ignore"}

    _nulls = field_validator("problem", "proposed_change", "impact_if_skipped", mode="before")(_none_to_empty)
    priority: Optional[int] = None
    category: str = ""
    text: str
    confidence: Optional[float] = None
    problem: str = ""
    proposed_change: str = ""
    impact_if_skipped: str = ""
    urgency: Optional[str] = None  # before_build | during_build | later; off-values -> None
    affected_entities: list[str] = []

    @field_validator("affected_entities", mode="before")
    @classmethod
    def _aff(cls, v):
        return _str_list(v)

    @field_validator("urgency", mode="before")
    @classmethod
    def _urgency(cls, v):
        return _norm_enum(v, {"before_build", "during_build", "later"})


class _Summary(BaseModel):
    model_config = {"extra": "ignore"}

    _nulls = field_validator("headline", "verdict_reason", "recommended_next_step", mode="before")(_none_to_empty)
    headline: str = ""
    verdict: Optional[str] = None  # ready_to_build | iterate_first | blocked; off-values -> None
    verdict_reason: str = ""
    key_findings: list[str] = []
    top_risks: list[str] = []
    recommended_next_step: str = ""

    @field_validator("key_findings", "top_risks", mode="before")
    @classmethod
    def _lists(cls, v):
        return _str_list(v)

    @field_validator("verdict", mode="before")
    @classmethod
    def _verdict(cls, v):
        return _norm_enum(v, {"ready_to_build", "iterate_first", "blocked"})


class _Metamodel(BaseModel):
    location: str
    version: str


class AssessmentDoc(BaseModel):
    """Mirror of ``vendored/assessment/assessment.schema.json`` (the agent's assessment.json)."""
    model_config = {"extra": "ignore"}
    model_quality_score: Optional[float] = None
    metamodel: _Metamodel
    executive_summary: Optional[_Summary] = None
    entities: list[_Entity]
    gaps: list[_Gap] = []
    pending_decisions: list[_Decision] = []
    next_vibes: list[_NextVibe] = []
