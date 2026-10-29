"""Pydantic models for API request/response validation."""

from datetime import datetime
from enum import Enum
from typing import Any, Literal, Optional, get_args

from pydantic import BaseModel, ConfigDict, Field, field_validator, model_validator

from .. import __version__
from .runtime_budget import (
    RUNTIME_BUDGET_DEFAULT_HOURS,
    RUNTIME_BUDGET_HOURS_DESCRIPTION,
    RUNTIME_BUDGET_MAX_HOURS,
    RUNTIME_BUDGET_MIN_HOURS,
)

# Business.name flows into Delta SQL WHERE/UPDATE clauses via f-strings in
# progress_tracker and model_sync (properly escaped at the call site, but
# defence-in-depth: reject names with characters that can't legitimately
# appear in a business name). Pattern: starts with alphanumeric, continues
# with alphanumeric / space / underscore / hyphen / ampersand / dot / paren
# / comma / apostrophe for natural-language names; 1-128 chars. Shared by
# BusinessIn.name and the taxonomy wizard's intake so a bad name fails at
# Step 1, not at Create.
BUSINESS_NAME_PATTERN = r"^[A-Za-z0-9][A-Za-z0-9 _\-&.,'()]{0,127}$"

# The agent's ``org_divisions`` widget presets (dropdown values, verbatim).
OrgDivisions = Literal["Operations", "Operations and Business", "Operations, Business and Corporate"]
ORG_DIVISIONS_PRESETS: tuple[str, ...] = get_args(OrgDivisions)

# The agent's ``boolean_format`` widget values (dropdown values, verbatim).
BooleanFormat = Literal["Boolean (True/False)", "Int (0/1)", "String (Y/N)"]
BOOLEAN_FORMATS: tuple[str, ...] = get_args(BooleanFormat)
# Lower-cased spellings that mean one of the three: the agent's own legacy
# aliases (its ``_normalize_boolean_format_label``) and the labels earlier app
# forms sent. The agent maps any other value to "Boolean (True/False)" without
# saying so, which is why the app normalizes before dispatch.
_BOOLEAN_FORMAT_ALIASES: dict[str, str] = {
    **{label.lower(): label for label in BOOLEAN_FORMATS},
    "boolean": "Boolean (True/False)",
    "bool": "Boolean (True/False)",
    "true/false": "Boolean (True/False)",
    "tinyint": "Int (0/1)",
    "bit": "Int (0/1)",
    "1/0": "Int (0/1)",
    "integer (1/0)": "Int (0/1)",
    "yes/no": "String (Y/N)",
    "y/n": "String (Y/N)",
    "string (yes/no)": "String (Y/N)",
}


def normalize_boolean_format(value: str) -> str:
    """Return the agent's ``boolean_format`` label for ``value``.

    Accepts the agent's three labels in any case plus the aliases in
    ``_BOOLEAN_FORMAT_ALIASES``; raises ``ValueError`` for anything else, so a
    value the agent would silently replace with Boolean fails at the API.
    """
    label = _BOOLEAN_FORMAT_ALIASES.get(str(value).strip().lower())
    if label is None:
        raise ValueError(
            f"boolean_format must be one of {', '.join(BOOLEAN_FORMATS)}; got {value!r}"
        )
    return label


def validate_business_description(value: str) -> str:
    """Reject an empty/whitespace-only business description.

    Shared by ``BusinessIn``'s field validator (create/update Business via the
    API) and the industry-kickstart path (``industry_kickstart.py``), so a
    business can never end up with a blank description regardless of entry
    point - one check, one message.
    """
    if not value.strip():
        raise ValueError("description must not be empty or whitespace-only")
    return value


class VersionOut(BaseModel):
    version: str

    @classmethod
    def from_metadata(cls):
        return cls(version=__version__)

# --- Enums ---

class RunStatus(str, Enum):
    PENDING = "pending"
    RUNNING = "running"
    COMPLETED = "completed"
    FAILED = "failed"
    CANCELLED = "cancelled"
    STALE = "stale"
    # Set by /runs/{id}/cancel-with-rollback when at least one reverse-op
    # failed. The run is terminal — not reusable — and the UI should
    # surface a "manual cleanup required" banner. Introduced in #118.
    ROLLED_BACK_FAILED = "rolled_back_failed"

# --- Vibe Input enums (string columns + str,Enum mirror; no DB enum type) ---

class VibeInputOrigin(str, Enum):
    USER = "user"
    AGENT_NEXT_VIBE = "agent_next_vibe"
    # Feedback the modeler made from a rejected run change (run_change_decisions).
    CHANGE_REJECTION = "change_rejection"

class VibeInputPriority(str, Enum):
    """Canonical priority vocabulary. ``NextVibeItem.priority`` is typed to
    this so the agent's next-vibe priority and the input priority cannot
    drift (unify — task2-lakebase-schema.md §0.3). The agent vocabulary
    (must/optional) is translated to this vocabulary at the parse boundary
    (routes/_helpers.py); ``medium`` is a user-only value the agent never
    emits."""
    HIGH = "high"
    MEDIUM = "medium"
    LOW = "low"

class VibeInputStatus(str, Enum):
    ACTIVE = "active"
    DEPRECATED = "deprecated"

class NextVibeCategory(str, Enum):
    """Classification of an agent next-vibe finding. The canonical, structured
    representation the next_vibes ingestion will populate (it is NOT recovered
    from a text prefix). Mirrors the nullable ``VibeInput.category`` string
    column; null for ``origin=user`` inputs (feedback has no category).

    - ``STATIC_ANALYSIS`` — a deterministic static-analysis finding.
    - ``PRIORITY_REMEDIATION`` — a prioritized remediation step.
    - ``OTHER`` — any other known issue.
    """
    STATIC_ANALYSIS = "static_analysis"
    PRIORITY_REMEDIATION = "priority_remediation"
    OTHER = "other"

class ReviewState(str, Enum):
    """Product-canonical review state (ADR D-044). Stored sparsely on
    ``product_reviews.state`` (string column + ``str, Enum`` mirror); absence
    of a row means the state is computed (see ``backend/review.py``)."""
    REVIEWED = "reviewed"
    NOT_REVIEWED = "not_reviewed"
    NO_REVIEW_NEEDED = "no_review_needed"

class Intent(str, Enum):
    """Describes "what the user wants the run to accomplish" — multi-step
    DAGs no longer have to pretend to be a single op. The canonical run
    label persisted on ``Run.intent`` (see ``docs/orchestrator-design.md``
    §8).
    """

    NEW_BASE_MODEL = "new-base-model"
    VIBE_ITERATE = "vibe-iterate"
    # Internal-only authoring helper: vibe an ECM, then automatically
    # shrink to MVM in the same run. Same DAG shape as ``new-base-model``
    # but seeded from a parent ECM via ``vibe_iterate`` instead of a
    # cold-start ``generate_ecm``. The parent must be ECM-scoped — the
    # validator rejects MVM parents at submit time.
    VIBE_NEW_ECM_MVM = "vibe-new-ecm-mvm"
    REVERT = "revert"
    IMPORT_FROM_VOLUME = "import-from-volume"
    INSTALL = "install"
    UNINSTALL = "uninstall"
    GENERATE_SAMPLES = "generate-samples"


# Intents the app no longer starts. The enum values stay so old run rows still
# read and render; ``RunIn`` treats them like any unknown value.
RETIRED_INTENTS: frozenset[Intent] = frozenset({Intent.REVERT, Intent.GENERATE_SAMPLES})

class VibeScope(str, Enum):
    """Scope for a scoped vibe iteration (VOV). See design §5.1 and §16.2.

    - ``ALL_DOMAINS`` — no scope restriction; run touches all domains.
    - ``SOME_DOMAINS`` — run is restricted to specified domains only.
    - ``SOME_SUBDOMAINS`` — accepted by the enum; rejected by preflight in phase 1.
    """
    ALL_DOMAINS = "all_domains"
    SOME_DOMAINS = "some_domains"
    SOME_SUBDOMAINS = "some_subdomains"

class DeploymentStatus(str, Enum):
    DRAFT = "draft"
    DEPLOYED = "deployed"
    UNINSTALLED = "uninstalled"

class ModelStatus(str, Enum):
    DRAFT = "draft"
    GENERATING = "generating"
    COMPLETED = "completed"
    FAILED = "failed"
    # Defensive add: vibe-iterate marks the parent ModelVersion's
    # status='superseded' (services/operations/vibe_iterate.py:609) when
    # producing a derived version. Without this entry, ``GET /businesses/
    # {id}/versions`` 500s with a Pydantic enum validation error whenever
    # any version row carries that status. The upstream concern — whether
    # marking the SOURCE version as superseded is the right behaviour —
    # is filed as a separate followup; we widen the response enum here so
    # the FE Base Version dropdown stops breaking.
    SUPERSEDED = "superseded"

class BusinessKind(str, Enum):
    """Discriminator on ``businesses.kind`` (ADR D-046). An ``INDUSTRY`` is a
    meta-business: a reusable template surfaced in the UI as an "Industry"
    (never "meta-business"). A ``BUSINESS`` is a real business. Both share the
    full pipeline; deployments are labelled by kind."""
    BUSINESS = "business"
    INDUSTRY = "industry"

# --- Industry ---

class IndustryIn(BaseModel):
    name: str
    short_name: str
    description: str = ""
    notable_businesses: str = ""
    display_order: int = 0
    is_active: bool = True

class IndustryOut(BaseModel):
    id: str
    name: str
    short_name: str
    description: str
    notable_businesses: str
    display_order: int
    is_active: bool
    is_auto_created: bool
    created_at: datetime
    updated_at: datetime

# --- Sector (taxonomy top level, ADR D-047) ---

class SectorIn(BaseModel):
    name: str
    short_name: str
    description: str = ""
    display_order: int = 0
    is_active: bool = True

class SectorOut(BaseModel):
    id: str
    name: str
    short_name: str
    description: str
    display_order: int
    is_active: bool
    created_at: datetime
    updated_at: datetime

# --- Agent Config ---

# Persistent agent job's max_concurrent_runs floor. Below 3 the app's two
# benign overlaps collide: (a) unified-pipeline phase transition (finalizing
# run briefly coexists with the next phase's run_now) and (b) cancel-with-
# rollback (uninstall cleanup launches while the cancelled run is still
# moving to TERMINATED). Server enforces the floor via ``ge=`` so a sub-3
# value returns 422 with a clear minimum-is-3 message.
_MAX_CONCURRENT_RUNS_MIN = 3
_MAX_CONCURRENT_RUNS_DESCRIPTION = (
    f"Minimum {_MAX_CONCURRENT_RUNS_MIN} — slack for the unified-pipeline "
    "phase transition and cancel-with-rollback cleanup overlaps."
)
_RUN_TAGS_DESCRIPTION = (
    "When true, runs add identity tags to the agent job: business name, "
    "run session id and notebook file name. Operational tags are always added."
)
_RUN_TAGS_IN_DESCRIPTION = _RUN_TAGS_DESCRIPTION + " Omit to keep the stored value."


class AgentConfigIn(BaseModel):
    notebook_path: str
    max_concurrent_runs: int = Field(
        default=_MAX_CONCURRENT_RUNS_MIN,
        ge=_MAX_CONCURRENT_RUNS_MIN,
        description=_MAX_CONCURRENT_RUNS_DESCRIPTION,
    )
    collect_vibe_run_statistics: Optional[bool] = Field(
        default=None,
        description=_RUN_TAGS_IN_DESCRIPTION,
    )
    runtime_budget_hours: Optional[int] = Field(
        default=None,
        ge=RUNTIME_BUDGET_MIN_HOURS,
        le=RUNTIME_BUDGET_MAX_HOURS,
        description=RUNTIME_BUDGET_HOURS_DESCRIPTION + " Omit to keep the stored value.",
    )

class AgentConfigOut(BaseModel):
    id: str
    notebook_path: str
    job_id: Optional[int]
    job_name: str
    # ``deployment_catalog`` is the DB column name (unchanged); ``metamodel_catalog``
    # is its concern-A vocabulary rename exposed alongside it (see core._catalogs).
    # Both carry the same value. ``deployment_catalog`` STAYS for the FE surfaces
    # that still read it (what-you-submitted, installation-drift-dialog); the
    # after-validator below mirrors it into ``metamodel_catalog`` so callers that
    # build this via ``**cfg.model_dump()`` (which has no metamodel_catalog column)
    # still get the field populated.
    deployment_catalog: str
    metamodel_catalog: str = ""
    warehouse_id: str
    max_concurrent_runs: int = Field(
        default=_MAX_CONCURRENT_RUNS_MIN,
        ge=_MAX_CONCURRENT_RUNS_MIN,
        description=_MAX_CONCURRENT_RUNS_DESCRIPTION,
    )
    collect_vibe_run_statistics: bool = Field(
        default=True,
        description=_RUN_TAGS_DESCRIPTION,
    )
    runtime_budget_hours: int = Field(
        default=RUNTIME_BUDGET_DEFAULT_HOURS,
        description="Settings default for new runs. " + RUNTIME_BUDGET_HOURS_DESCRIPTION,
    )
    # The bounds the API enforces, so the UI never copies them.
    runtime_budget_min_hours: int = RUNTIME_BUDGET_MIN_HOURS
    runtime_budget_max_hours: int = RUNTIME_BUDGET_MAX_HOURS
    created_at: datetime
    updated_at: datetime
    # Pre-built workspace URL for the persistent agent job — backend has the
    # workspace host via Dependencies.Client; FE can't construct it because
    # the app is served from a Databricks Apps proxy origin, not the
    # workspace origin. Empty string when job_id is not yet set.
    job_url: str = ""

    @model_validator(mode="after")
    def _mirror_metamodel_catalog(self) -> "AgentConfigOut":
        # Concern-A rename: metamodel_catalog is the exposed vocabulary for the
        # deployment_catalog column. Mirror the column value unless a caller set
        # it explicitly (it never does today; the DB has no such column).
        if not self.metamodel_catalog:
            self.metamodel_catalog = self.deployment_catalog
        return self

class WarehouseOut(BaseModel):
    id: str
    name: str
    state: str
    cluster_size: str = ""
    warehouse_type: str = ""

class DeploymentCatalogIn(BaseModel):
    deployment_catalog: str


class DeploymentCatalogCheckOut(BaseModel):
    """``GET .../deployment/catalog-check``. ``verification_error`` is the
    sanitized reason the catalog could not be checked, else ``None``."""
    exists: bool
    catalog: str
    error: Optional[str] = None
    verification_error: Optional[str] = None


class DeployedUcSchemaOut(BaseModel):
    """``GET .../deployment/uc-schema``: the deployed tables, columns and keys
    as ``deployment_verifier.get_uc_schema`` reads them. When a query failed,
    every list is empty and ``verification_error`` says why."""
    tables: list[dict[str, Any]] = Field(default_factory=list)
    columns: list[dict[str, Any]] = Field(default_factory=list)
    primary_keys: list[dict[str, Any]] = Field(default_factory=list)
    foreign_keys: list[dict[str, Any]] = Field(default_factory=list)
    verification_error: Optional[str] = None


class DeploymentVerificationOut(BaseModel):
    """``GET .../deployment/compare``: the logical model against the deployed
    UC schema. When the deployed schema could not be read, nothing is
    compared (no table is model-only) and ``verification_error`` says why."""
    tables: dict[str, list[dict[str, Any]]]
    summary: dict[str, int]
    verification_error: Optional[str] = None


class MetamodelCatalogIn(BaseModel):
    """Concern-A metamodel catalog input for the renamed /config/metamodel-catalog
    endpoints. Same underlying column as DeploymentCatalogIn (deployment_catalog),
    exposed under the concern-A vocabulary."""
    metamodel_catalog: str


class AgentCompatChange(BaseModel):
    """A single known-upstream-change entry for an agent tag.

    Mirrors the dict shape produced by `agent_compat.known_changes_for_tag`
    so the release-monitor CI job and the Settings UI can render identical
    summaries.
    """
    tag: str
    severity: str  # "breaking" | "info"
    area: str
    summary: str


InstalledVsBundled = Literal["same", "older", "newer", "unknown"]
"""The configured notebook against the bundled agent: ``same``; ``older`` (the
bundled agent is newer); ``newer`` (the notebook is newer than the bundled
agent); ``unknown`` (the identity is not known: not read yet, read from
another path, the read failed or found no markers, or no bundled agent)."""


class AgentCompatOut(BaseModel):
    """Agent release-monitor health surface (Surface 2).

    Backs `GET /api/config/agent-compat` and is consumed by the Settings
    card. Checks BOTH version numbers of the latest upstream agent — the
    public `release_version` (the app-agent interface the app pins) and the
    `agent_version` build counter — and produces a three-way `verdict`:

    * `release_incompatible` — upstream shipped a newer RELEASE than the
      app's pinned `SUPPORTED_AGENT_VERSION`. The app's API calls target the
      pinned release and can't adapt, so the user must update the APP
      (`update_app_required=True`). No install is offered.
    * `build_update_available` — same release, newer `agent_version` build
      counter. Same contract, newer build — informational only.
    * `up_to_date` — otherwise.

    The upstream identity is live-read from the canonical repo notebook and
    cached 7 days on the AgentConfig singleton (see `_get_or_create_agent_config`);
    `checked_at` / `check_error` expose that cache's freshness + last error.
    `install_offered` is always False in this phase (install is deferred).
    """
    pinned_version: str
    latest_known_upstream: str
    newer_available: bool
    has_breaking_change: bool
    known_breaking_changes: list[AgentCompatChange] = []
    repo_url: str = (
        "https://github.com/databricks-industry-solutions/"
        "lakehouse-industry-data-models"
    )
    repo_compare_url: str = ""
    # Three-way release/build verdict (Surface 2). ``pinned_release`` mirrors
    # ``pinned_version`` (the release tag); ``pinned_agent_marker`` is the
    # pinned build counter. The ``latest_upstream_*`` fields carry the live
    # (cached) upstream identity, ``None`` when the cache is cold.
    pinned_release: str = ""
    pinned_agent_marker: str = ""
    latest_upstream_release: Optional[str] = None
    latest_upstream_marker: Optional[str] = None
    verdict: str = "up_to_date"  # up_to_date | build_update_available | release_incompatible
    update_app_required: bool = False
    install_offered: bool = False
    checked_at: Optional[datetime] = None
    check_error: Optional[str] = None
    # The configured notebook's own identity (the ``agent_config.installed_*``
    # cache) next to the bundled agent's marker. ``agent_owner`` is ``app``
    # when the notebook sits in the app's own agent folder (upgraded on boot)
    # and ``admin`` otherwise. ``installed_vs_bundled`` compares the installed
    # (release, marker) with the bundled one, release first: ``older`` means
    # the bundled agent is newer. All None while no notebook is configured.
    installed_release_version: Optional[str] = None
    installed_agent_version: Optional[str] = None
    installed_checked_at: Optional[datetime] = None
    installed_checked_path: Optional[str] = None
    installed_check_error: Optional[str] = None
    bundled_agent_marker: Optional[str] = None
    installed_vs_bundled: Optional[InstalledVsBundled] = None
    agent_owner: Optional[Literal["app", "admin"]] = None
    # Whether the configured notebook's cached marker supports scoped and Dry
    # runs (``core._vibe_scope.MIN_AGENT_MARKER_FOR_SCOPE``); None when the
    # marker is not known.
    scope_supported: Optional[bool] = None

# --- GitHub config (ADR D-049) ---

class GithubConfigIn(BaseModel):
    """Installation GitHub publish/browse config. The token is never carried
    here: for OAuth U2M the ``connection_name`` names the UC HTTP connection;
    for the PAT fallback the secret lives in a secret scope."""
    repo_owner: str = ""
    repo_name: str = ""
    auth_mode: str = ""  # '' | 'oauth_u2m' | 'secret_pat'
    connection_name: str = ""
    secret_scope: str = ""
    secret_key: str = ""

class GithubConfigOut(BaseModel):
    repo_owner: str
    repo_name: str
    auth_mode: str
    connection_name: str
    secret_scope: str
    secret_key: str

# --- Source read-auth config (0.7.1) ---

class SourceAuthConfigIn(BaseModel):
    """Installation source READ-auth config. Distinct from the publish config
    above. Secret material (App PEM, PAT) is never carried here: the row keeps
    only the secret scope/key REFERENCES. PUT round-trips all fields so a
    partial save never NULLs a sibling reference."""
    auth_mode: str = ""  # '' | 'github_app' | 'token' | 'anonymous'
    github_app_id: str = ""
    github_app_installation_id: str = ""
    github_app_secret_scope: str = ""
    github_app_secret_key: str = ""
    token_secret_scope: str = ""
    token_secret_key: str = ""

class SourceAuthConfigOut(BaseModel):
    """The persisted source read-auth config plus the computed effective mode.

    Returns the mode + non-secret ids + secret scope/key REFERENCES; it NEVER
    returns secret values. ``effective_mode`` is the transport the resolver
    would actually select right now ('github_app' | 'token' | 'anonymous'), and
    ``error`` carries the leak-free degrade reason when resolution fell back to
    anonymous (else None)."""
    auth_mode: str
    github_app_id: str
    github_app_installation_id: str
    github_app_secret_scope: str
    github_app_secret_key: str
    token_secret_scope: str
    token_secret_key: str
    effective_mode: str
    error: Optional[str] = None

# --- Business ---

class BusinessIn(BaseModel):
    name: str = Field(min_length=1, max_length=128, pattern=BUSINESS_NAME_PATTERN)
    # The ≤2k business SUMMARY → the agent's ``business_description`` widget
    # (the industry / complexity-tier seed). Capped at 2000 because that widget
    # is inline-only (hard 2048-char Databricks notebook_params limit, no Volume
    # spill). Non-empty after trim — the agent hard-fails an empty description.
    # The full detailed description goes in ``business_vibes`` (below).
    description: str = Field(min_length=1, max_length=2000)
    # The full, arbitrarily-long detailed description (Markdown). Routed to the
    # agent's ``model_vibes`` channel on the initial run (spills to a UC Volume
    # file when large). Optional — a summary alone can seed a model.
    business_vibes: str = ""
    industry_alignment: str = ""
    # ADR D-046/D-047. ``kind`` discriminates business vs industry (an industry
    # is a ``businesses`` row with ``kind='industry'``); ``sector_id`` is the
    # taxonomy placement. Both default to a plain business for back-compat.
    kind: BusinessKind = BusinessKind.BUSINESS
    sector_id: Optional[str] = None
    # Proposed domain schema names for the first New Base Model run (the
    # agent's ``business_domains`` widget value, ``"a, b, c"``) and the
    # proposed coverage preset (``""`` = not set). Pre-fill only: run launch
    # never reads them from the business.
    business_domains: str = Field("", max_length=2000)
    org_divisions: str = ""

    @field_validator("description")
    @classmethod
    def _description_not_whitespace(cls, v: str) -> str:
        return validate_business_description(v)

    @field_validator("business_domains")
    @classmethod
    def _normalize_business_domains(cls, v: str) -> str:
        names: list[str] = []
        for raw in v.split(","):
            name = raw.strip()
            if name and name not in names:
                names.append(name)
        return ", ".join(names)

    @field_validator("org_divisions")
    @classmethod
    def _org_divisions_preset(cls, v: str) -> str:
        if v and v not in ORG_DIVISIONS_PRESETS:
            raise ValueError(f"org_divisions must be empty or one of {', '.join(ORG_DIVISIONS_PRESETS)}")
        return v

class BusinessOut(BaseModel):
    id: str
    name: str
    description: str
    business_vibes: str = ""
    industry_alignment: str
    # ADR D-046/D-047/D-050. ``kind`` discriminates business vs industry;
    # ``sector_id`` is the taxonomy placement; ``source_industry_id`` +
    # ``source_version`` carry kickstart provenance (null for non-kickstarted).
    kind: BusinessKind = BusinessKind.BUSINESS
    sector_id: Optional[str] = None
    source_industry_id: Optional[str] = None
    source_version: Optional[int] = None
    # ADR D-049: the repo path an industry was downloaded from; pre-fills the
    # publish dialog's editable bundle-root. NULL for non-downloaded businesses.
    source_repo_path: Optional[str] = None
    # Plain ``str`` (not the preset Literal) so existing rows and later preset
    # changes never fail serialization.
    business_domains: str = ""
    org_divisions: str = ""
    created_at: datetime
    updated_at: datetime

class BusinessListOut(BaseModel):
    id: str
    name: str
    industry_alignment: str
    kind: BusinessKind = BusinessKind.BUSINESS
    sector_id: Optional[str] = None
    source_industry_id: Optional[str] = None
    source_version: Optional[int] = None
    model_count: int = 0
    downloaded_scopes: list[str] = []
    created_at: datetime

# --- Business Context ---

class BusinessContextIn(BaseModel):
    version_label: str = ""
    context_json: str = "{}"
    conventions_json: str = "{}"
    is_active: bool = True

class BusinessContextOut(BaseModel):
    id: str
    business_id: str
    version_label: str
    context_json: str
    conventions_json: str
    is_active: bool
    created_at: datetime

# --- Model Version ---

class ModelVersionOut(BaseModel):
    id: str
    business_id: str
    version: int
    status: ModelStatus
    deployment_status: DeploymentStatus
    base_version_id: Optional[str]
    vibe_instructions: str
    context_id: Optional[str]
    confidence_score: Optional[float]
    scope: str = ""
    uc_catalog: str
    completion_date: Optional[datetime]
    # Post-run sync state, surfaced so the UI can render a banner when
    # something silently failed downstream of the agent's terminal-success
    # event. ``ok`` (default) is the happy path; any other value pairs with a
    # human-readable hint in ``sync_error_text``. Notably ``sync_empty`` covers
    # both G1 (no Volume + no Delta) and G2 (0-domain payload) — a resync won't
    # help — versus ``incomplete_metadata`` (data found, write failed; resync
    # may recover). See db_models.ModelVersion for the full value set.
    sync_state: str = "ok"
    sync_error_text: Optional[str] = None
    # Import provenance — populated when the version was imported from a
    # Volume (a sync, not a run). NULL for agent-produced versions.
    import_source_path: Optional[str] = None
    imported_at: Optional[datetime] = None
    # Version provenance stamped from the model.json envelope at sync/import
    # time. ``agent_version`` is the agent-logic counter (``4.x.y``);
    # ``release_version`` is the public/compat release identity (``0.8.0``).
    # NULL for pre-existing rows and Delta-only payloads.
    agent_version: Optional[str] = None
    release_version: Optional[str] = None
    # Version lifecycle (see db_models.ModelVersion). ``replaced_at`` set means
    # an install replaced this version; ``replaced_by_version_id`` names the
    # replacer while it exists. ``files_catalog`` is where the version's files
    # live; ``uc_catalog`` is where it is installed now.
    dry_run: bool = False
    promoted_at: Optional[datetime] = None
    promoted_by_run_id: Optional[str] = None
    replaced_by_version_id: Optional[str] = None
    replaced_at: Optional[datetime] = None
    files_catalog: Optional[str] = None
    scope_fence_mode: Optional[str] = None
    # Derived by the versions list route, one head per (business, scope):
    # ``is_head`` marks the scope's current version; ``draft_state`` is
    # ``ready`` for a Dry Run draft on the head and ``older_base`` for one on
    # an older base. None where the route does not compute them.
    is_head: Optional[bool] = None
    draft_state: Optional[Literal["ready", "older_base"]] = None
    # The Run a link recorded for an imported version (``run_link``); set by
    # the versions list route only.
    linked_run_id: Optional[str] = None
    # Whether the version was imported (``run_link.import_sources``): an
    # import dialog, an industry download, a Volume recovery import or an
    # out-of-band import, as opposed to a run of the app producing it (a Run
    # with a RunOperation that output it; ``Run.version_id`` is only a
    # target or parent, so an install or a vibe of the version does not
    # count). Only an imported version can be linked to its run. None where
    # the route does not compute it.
    is_imported: Optional[bool] = None
    created_at: datetime


class InstallationStatusOut(BaseModel):
    """Catalog-vs-Lakebase drift snapshot for a single ``ModelVersion``.

    The UI polls this on the model-version Overview to detect cases
    where Lakebase says "Installed" but the underlying physical schemas
    have been dropped externally (DBA, sibling vibe-iterate run with
    different schema layout, etc.). When ``in_sync == False`` the UI
    pops a non-dismissible reconcile dialog.

    ``in_sync`` is ``Optional`` — ``None`` means the probe was skipped
    (no catalog/domains to check, or the catalog listing call failed;
    see ``skipped_reason``) and is deliberately distinct from ``True``
    ("checked, and it's fine"). A skipped probe must never read as
    healthy.

    ``deployment_catalog`` is the latest install catalog (``uc_catalog``);
    the schema lists are for it. ``also_installed_in`` lists the other
    catalogs with an open install row; each is probed too, a schema missing
    there is listed in ``missing_schemas`` as ``<catalog>.<schema>`` and
    makes ``in_sync`` False.
    """
    version_id: str
    deployment_catalog: str
    lakebase_says_installed: bool
    expected_schemas: list[str]
    found_schemas: list[str]
    missing_schemas: list[str]
    catalog_present: bool
    in_sync: Optional[bool]
    checked_at: datetime
    skipped_reason: Optional[str] = None
    also_installed_in: list[str] = Field(default_factory=list)


class ReconcileInstallationOut(BaseModel):
    """Result of a 3-way reconcile (catalog ↔ Lakebase) for a version."""
    version_id: str
    previous_deployment_status: str
    new_deployment_status: str
    schemas_present: list[str]
    schemas_missing: list[str]
    notes: list[str]

# --- Run ---

class RunIn(BaseModel):
    # ``extra="forbid"`` rejects any unknown body field with HTTP 422 so
    # stale clients sending the legacy ``business_id`` (now URL-only) or
    # any other typo surface in CI rather than getting silently dropped
    # into a Frankenstein run-state.
    model_config = ConfigDict(extra="forbid")

    # Spec §8: ``intent`` is the canonical field describing what the user
    # wants this run to accomplish. ``business_id`` is NOT a body field —
    # it is sourced from the URL path on every run-related route and
    # threaded into helpers as a separate parameter.
    intent: Intent = Intent.NEW_BASE_MODEL

    @field_validator("intent", mode="before")
    @classmethod
    def _intent_is_startable(cls, value: Any) -> Any:
        """A retired intent is refused with the same error as an unknown one."""
        try:
            intent = Intent(value)
        except (ValueError, TypeError):
            intent = None
        if intent is None or intent in RETIRED_INTENTS:
            raise ValueError("intent not recognized")
        return value

    version_id: Optional[str] = None
    parent_version_id: Optional[str] = None
    context_id: Optional[str] = None
    catalog: str = ""
    # ``deployment_catalog`` was added on the request body during the Phase 4
    # wirer rebases as a synonym for ``catalog`` (some test agents and curl
    # callers used one name, the frontend used the other). Keep both fields
    # accepted on the wire — the validator below normalises ``catalog`` to be
    # the canonical source of truth — but new clients should send ``catalog``.
    # This avoids the silent-fail mode where ``deployment_catalog`` was set
    # but the factory only read ``catalog`` (Phase 4.5 bug 2).
    deployment_catalog: str = ""

    @model_validator(mode="after")
    def _normalize_catalog_aliases(self):
        """Allow ``deployment_catalog`` as a deprecated alias for ``catalog``.
        If only the alias is set, copy it onto ``catalog`` so downstream
        readers (DAG factories, route handlers) see a single canonical
        field."""
        cat = (self.catalog or "").strip()
        alias = (self.deployment_catalog or "").strip()
        if not cat and alias:
            self.catalog = alias
        return self
    scope: Optional[str] = None
    version_int: Optional[int] = None
    sample_count: Optional[int] = None
    vibe_instructions: str = ""
    model_size: str = "small model"
    # Accepted for older clients and the smoke scripts, and ignored: agent
    # 5.3.3 has no ``generate_samples`` widget, so nothing reads or stores it.
    generate_samples: bool = False
    business_context_path: str = ""
    business_context_text: str = ""
    # Convention overrides (None = use defaults from map_run_params_to_widgets)
    naming_convention: Optional[str] = None
    primary_key_suffix: Optional[str] = None
    # Legacy single schema_prefix — still used for non-unified ops (vibe/shrink/
    # enlarge/install/etc). For the unified new-base-model pipeline the
    # per-scope `ecm_schema_prefix` / `mvm_schema_prefix` take over.
    schema_prefix: Optional[str] = None
    # Per-scope schema prefixes for the unified ECM→MVM pipeline (#122).
    # When omitted the router derives defaults from `cataloging_style`:
    #   - One Catalog → ecm_schema_prefix="ecm_", mvm_schema_prefix="mvm_"
    #   - Catalog per Division/Domain → both empty (per-scope catalogs
    #     already isolate ECM from MVM so prefixing would be redundant).
    ecm_schema_prefix: Optional[str] = None
    mvm_schema_prefix: Optional[str] = None
    schema_suffix: Optional[str] = None
    tag_prefix: Optional[str] = None
    tag_suffix: Optional[str] = None
    table_id_type: Optional[str] = None
    boolean_format: Optional[str] = None
    date_format: Optional[str] = None
    timestamp_format: Optional[str] = None
    cataloging_style: Optional[str] = None
    catalog_prefix: Optional[str] = None
    catalog_suffix: Optional[str] = None
    org_divisions: Optional[str] = None
    business_domains: Optional[str] = None
    classification_levels: Optional[str] = None
    housekeeping_columns: Optional[str] = None
    history_tracking_columns: Optional[str] = None
    # Agent-proposed next-vibe IDs the user picked from the base version's
    # structured agent VibeInput rows (the VibeInput.id uuids). Validated
    # against those rows and recorded as RunNextVibeLink rows for audit; their
    # text is NOT folded into the run instructions.
    next_vibe_ids: list[str] = []
    # Selected VibeInput ids — the sole source of run instructions. The server
    # compiles them via compile_inputs and dispatches the resulting markdown
    # through the vibe_instructions widget.
    input_ids: list[str] = []
    # Agent widget 06a. Only intent=vibe-iterate accepts a value other than
    # all_domains (phase 1). See design §5.1.
    vibe_scope: VibeScope = VibeScope.ALL_DOMAINS
    # Scope list under some_domains. Names are matched against the base
    # version's domains with the agent's normalization; the preflight rewrites
    # them to the canonical stored names. See design §5.1.
    vibe_scope_domains: list[str] = []
    # Agent widget 03a ("Dry Run" when True). Only intent=vibe-iterate in
    # phase 1. See design §5.1.
    dry_run: bool = False
    # Subject keys of the ``confirm`` issues the user accepted (see
    # ``IssueOut.subject``). Create recomputes the issues and refuses any
    # subject not listed here.
    confirmed_issues: list[str] = []
    # Install only: after a successful install, delete the versions it
    # replaced. BusinessAdmin only, like deleting a version directly.
    also_delete_replaced: bool = False
    # This run's agent budget; omitted means the Settings default. Create
    # stores the resolved hours in ``Run.parameters_json`` for runs that
    # dispatch generation (see ``backend/runtime_budget.py``).
    runtime_budget_hours: Optional[int] = Field(
        default=None,
        ge=RUNTIME_BUDGET_MIN_HOURS,
        le=RUNTIME_BUDGET_MAX_HOURS,
        description=(
            RUNTIME_BUDGET_HOURS_DESCRIPTION
            + " Omit for the Settings default. Install and uninstall runs ignore it."
        ),
    )

    @field_validator("boolean_format")
    @classmethod
    def _normalize_boolean_format(cls, value: Optional[str]) -> Optional[str]:
        """Rewrite to the agent's label; blank keeps today's "use the default"."""
        if value is None or not value.strip():
            return value
        return normalize_boolean_format(value)


# The ``RunIn`` Advanced Options the generation steps take as they are: the
# DAG factories forward each one the request sets, and create records the
# non-empty ones in ``Run.parameters_json``.
RUN_CONVENTION_FIELDS: tuple[str, ...] = (
    "naming_convention",
    "primary_key_suffix",
    "schema_suffix",
    "tag_prefix",
    "tag_suffix",
    "table_id_type",
    "boolean_format",
    "date_format",
    "timestamp_format",
    "catalog_prefix",
    "catalog_suffix",
    "org_divisions",
    "business_domains",
    "classification_levels",
    "housekeeping_columns",
    "history_tracking_columns",
)


class RunDefaultFieldOut(BaseModel):
    """One Advanced Options value a vibe of a base version starts from.

    ``source``: ``base_file`` (the base's ``model.json``), ``base_run`` (the
    widgets the run that made the base dispatched), ``default`` (the app
    default) or ``unknown`` (the base's file could not be read; ``value`` is
    then ``None`` and the form sends nothing for the field).
    ``locked`` / ``locked_scoped``: the agent keeps the base's value on an
    All domains vibe (and Vibe ECM + MVM) / on a Some domains vibe, whatever
    the request sends.
    """

    value: Optional[str] = None
    source: Literal["base_file", "base_run", "default", "unknown"]
    locked: bool = False
    locked_scoped: bool = False


class RunDefaultsOut(BaseModel):
    """``getRunDefaults``: the Advanced Options a vibe of ``base_version_id``
    starts from, keyed by ``RunIn`` field (``schema_prefix`` is the base's
    prefix; the form sends it as ``ecm_schema_prefix`` on Vibe ECM + MVM).
    ``file_read`` is False when the base's ``model.json`` could not be read."""

    base_version_id: str
    file_read: bool
    fields: dict[str, RunDefaultFieldOut]


class WatchdogState(str, Enum):
    """D-09 user-visible watchdog state, derived from Run.status + warm-up."""
    WARMING_UP = "warming_up"
    ARMED = "armed"
    TRIPPED_STALE = "tripped_stale"
    TRIPPED_FAILED = "tripped_failed"
    DISARMED = "disarmed"


class RunOut(BaseModel):
    id: str
    business_id: str
    version_id: Optional[str]
    # Spec §8: durable label for "what does the user want this run to
    # accomplish". Empty string for runs created before the wirer landed.
    intent: str = ""
    status: RunStatus
    databricks_run_id: Optional[int]
    vibe_session_id: Optional[str] = None
    run_page_url: Optional[str] = None
    progress_percent: int
    progress_message: str
    error_message: str
    parameters_json: str
    vibe_instructions_text: str = ""
    vibe_instructions_volume_path: str = ""
    # The business context text the user typed at run-creation. Persisted
    # on Run.business_context_text (added in migration 0.2.0). Empty for
    # legacy runs and ops that don't carry user-typed context.
    business_context_text: str = ""
    started_at: Optional[datetime]
    completed_at: Optional[datetime]
    created_at: datetime
    # --- D-09 user-visible watchdog signals (plan task #51) ---
    # Derived: see backend.router._build_run_out for the watchdog_state
    # mapping; warm-up countdown reaches 0 once the watchdog is armed.
    watchdog_state: WatchdogState = WatchdogState.DISARMED
    watchdog_warm_up_seconds_remaining: int = 0
    # Persisted: tracker writes `last_jobs_api_state` and `last_poll_error`
    # to the Run row on every poll iteration. Empty strings when the
    # tracker has not yet seen a Jobs API call / has just succeeded.
    last_jobs_api_state: str = ""
    last_poll_error: str = ""
    # Derived: seconds since `started_at` (or `created_at` when the run
    # never reached the launched-tracker step). Rounded down.
    elapsed_seconds: int = 0
    # Spec §2.4 + §8: ``warnings`` is a non-optional list — empty on the
    # trivial happy path. Each entry mirrors the ``Issue`` envelope used by
    # ``POST /runs/validate`` and the 400 blocker payload:
    # ``{"field_path", "step_index", "message", "severity"}``. ``POST /runs``
    # returns the validator's warning-severity issues; every response then
    # adds the warnings the run's succeeded steps reported
    # (``RUN_WARNINGS_KEY`` in their rollback state, e.g. the schemas an
    # uninstall left behind), with ``field_path`` ``(<operation>)`` and the
    # step's ``step_index``. The run page shows them.
    warnings: list[dict] = []
    # Agent-emitted Version Resolution events for this run (auto-collision
    # resolves). Empty on the happy path. Derived from the run's
    # RunProgressEvent rows — see ``backend.version_resolution_parser``.
    version_resolutions: list["VersionResolutionOut"] = []
    # Set when the run was recorded by linking an imported version to its
    # Databricks run; ``link_evidence`` says how the match was verified.
    linked_at: Optional[datetime] = None
    link_evidence: Optional[str] = None


class VersionResolutionOut(BaseModel):
    """Surface row for a single agent-emitted Version Resolution event.

    The agent emits this when its pre-allocated output version collides
    with an existing artifact on Volume and it auto-bumps to a higher
    ordinal. Surfaced on the run-detail page so the user can see e.g.
    "Requested v1 → resolved v3 (auto-collision-resolved)".
    """
    target_scope: str
    original_target: int
    new_target: int


class RunListOut(BaseModel):
    id: str
    business_id: str
    intent: str = ""
    status: RunStatus
    progress_percent: int
    started_at: Optional[datetime]
    completed_at: Optional[datetime]
    created_at: datetime


class RunLineageVersionOut(BaseModel):
    id: str
    version: int
    scope: str = ""
    status: ModelStatus
    deployment_status: DeploymentStatus


class RunLineageOut(BaseModel):
    """Lineage links for a single run.

    - `source_version`: the BASE this run branched from (vibe/shrink/enlarge).
    - `generated_version`: the version this run produced, if any (model-producing ops).
    - `operates_on_version`: the version this run targets (install/uninstall/samples).
    """
    run_id: str
    intent: str
    business_id: str
    source_version: Optional[RunLineageVersionOut] = None
    generated_version: Optional[RunLineageVersionOut] = None
    operates_on_version: Optional[RunLineageVersionOut] = None

# --- Run Progress Event ---

class ProgressEventOut(BaseModel):
    id: str
    run_id: str
    step_id: int
    event_seq: Optional[int]
    stage_name: str
    step_name: str
    status: str
    message: str
    progress_increment: float
    result_json: str
    created_at: datetime

# --- Run Artifact ---

class RunArtifactOut(BaseModel):
    id: str
    # Nullable since v_0_5_0 (imports are syncs, not runs — there is no
    # parent Run when the indexer writes rows for an imported ModelVersion).
    # Agent-produced runs still carry a real run_id; only the import path
    # leaves it NULL.
    run_id: Optional[str] = None
    model_version_id: Optional[str] = None
    artifact_type: str
    file_path: str
    created_at: datetime


# --- Run Operation (DAG step persistence) ---


class RunOperationOut(BaseModel):
    """Single ``RunOperation`` row exposed via ``GET /runs/{id}/operations``.

    The UI's "what step are we on" pipeline reads from this — see
    ``docs/orchestrator-design.md`` §5.2 + §8. Step ordering is by
    ``step_index`` ascending; the orchestrator persists rows on
    ``Orchestrator.start()`` and updates lifecycle fields as each op
    transitions.
    """

    id: str
    run_id: str
    step_index: int
    operation_name: str
    status: str
    databricks_run_id: Optional[int] = None
    # Each phase dispatches its own job run, so the per-phase URL is
    # built from the phase's own ``databricks_run_id`` — see
    # ``_build_dbx_run_url`` in ``routes/_helpers.py``.
    run_page_url: Optional[str] = None
    parent_version_id: Optional[str] = None
    output_version_id: Optional[str] = None
    # Natural-key affordance for the UI's "→ v1 ECM" link on the Phase
    # row — populated from the linked ModelVersion's
    # ``(version, scope, business_id)`` so the label is human-meaningful
    # and the URL points at the canonical model version page (#49).
    output_version_label: Optional[str] = None
    output_version_url: Optional[str] = None
    error_message: str = ""
    started_at: Optional[datetime] = None
    completed_at: Optional[datetime] = None
    created_at: datetime
    # The exact widget map this op's dispatch() sent to `jobs.run_now()`
    # (e.g. `data_model_scopes`, `deployment_catalog`) — the durable
    # answer to "what did we actually dispatch," verifiable without
    # going to the Databricks Jobs API directly. Empty for ops that
    # dispatched before this field existed, or that don't launch a job.
    dispatched_widgets: dict = {}


# --- Run validation (live form feedback) ---


class IssueOut(BaseModel):
    """Single validation finding for ``POST /runs/validate`` /
    ``POST /runs`` (per spec §2.4 + §2.4.1).

    ``severity`` distinguishes ``"warning"`` (soft — UI surfaces a
    "Submit anyway" confirmation, run is still created; in ``RunOut.warnings``
    also something a succeeded step reported after it ran) from
    ``"blocker"`` (hard — ``POST /runs`` 400s; ``POST /runs/validate``
    flags the offending field inline), ``"confirm"`` (the run is created
    only when ``RunIn.confirmed_issues`` lists this issue's ``subject``) and
    ``"prepare"`` (validate only: a step create performs itself before it
    records the run, e.g. setting up ``_metamodel``).

    ``subject`` is set on ``confirm`` issues only: a key bound to what the
    confirmation is about, e.g. ``install_over_newer:<head version id>`` or
    ``install_replaces_in_catalog:<occupying version id>``, so a confirmation
    given for one version never covers another.

    ``versions`` lists the version numbers the issue names, when it names
    some: the versions an ``install_over_newer`` install replaces, and the
    versions a ``vibe_scope_base`` blocker asks to delete first.
    """

    field_path: str
    step_index: int
    message: str
    severity: Literal["warning", "blocker", "confirm", "prepare"]
    subject: Optional[str] = None
    versions: list[int] = Field(default_factory=list)


class ValidateRunOut(BaseModel):
    """Response shape for ``POST /runs/validate`` (spec §8).

    Does NOT create a Run row. The same validator powers ``POST /runs``;
    blockers there reject with 400, warnings flow through.
    """

    warnings: list[IssueOut] = []
    blockers: list[IssueOut] = []


# --- Cancel-with-rollback ---


class CancelOpAppliedOut(BaseModel):
    """One reverse-op the orchestrator successfully replayed during
    ``POST /runs/{id}/cancel-with-rollback`` (spec §6.3).

    ``operation_name`` is the canonical orchestrator-driven label
    (``RunOperation.operation_name``). ``kind`` carries the legacy
    rollback-plan op kind (``delete_model_version`` /
    ``uninstall_schema`` etc.) so existing UI / tests that read
    ``op.kind`` keep working through Phase 4's transition window.
    """

    model_config = {"extra": "allow"}

    operation_name: str = ""
    kind: str = ""


class CancelOpFailureOut(BaseModel):
    """One reverse-op that failed; rollback halts at the first such
    failure and the run lands in ``rolled_back_failed``."""

    op: dict = Field(default_factory=dict)
    error: str = ""


class CancelWithRollbackOut(BaseModel):
    """Response shape for ``POST /businesses/{bid}/runs/{rid}/cancel-with-rollback``."""

    ok: bool
    status: str
    ops_applied: list[CancelOpAppliedOut] = []
    op_failures: list[CancelOpFailureOut] = []


# --- Resume (admin) ---


class ResumeRunOut(BaseModel):
    """Response shape for ``POST /businesses/{bid}/runs/{rid}/resume``."""

    ok: bool
    status: str
    next_phase: str = ""
    databricks_run_id: Optional[int] = None
    error: str = ""


# --- Health ---


class HealthOut(BaseModel):
    """Response shape for ``GET /health``.

    Surfaces ``in_flight_runs`` so the deploy script can refuse to push
    a new wheel while runs are active (atomic-replace App containers
    can't hand off in-flight pollers cleanly).
    """

    ok: bool = True
    in_flight_runs: int = 0

# --- Model Explorer ---

class ChangeStatus(str, Enum):
    UNCHANGED = "unchanged"
    NEW = "new"
    MODIFIED = "modified"
    DELETED = "deleted"

class AttributeOut(BaseModel):
    # Stable per-version UUID; empty for previous-version-only (deleted)
    # placeholders that carry no current DB row.
    id: str = ""
    name: str
    column_name: str
    type: str
    description: str
    business_glossary_term: str = ""
    tags: str = ""
    value_regex: str = ""
    foreign_key_to: str = ""
    references: str = ""
    is_primary_key: bool = False
    is_foreign_key: bool = False
    change_status: ChangeStatus = ChangeStatus.UNCHANGED

class ProductSummaryOut(BaseModel):
    # Stable internal key (per-version UUID) + the human key. ``id`` is empty
    # for products that exist only in a previous version (deleted-product
    # placeholders carry no current DB row); ``fqn`` is the canonical
    # "<domain>.<product>" (formed at the explorer serialization boundary) and
    # is always present.
    id: str = ""
    fqn: str = ""
    name: str
    table_name: str
    description: str
    type: str = ""
    data_type: str = ""
    primary_key: str = ""
    subdomain: str = ""
    reference: str = ""
    attribute_count: int = 0
    fk_count: int = 0
    fk_targets: list[str] = []
    change_status: ChangeStatus = ChangeStatus.UNCHANGED

class ProductDetailOut(BaseModel):
    # Stable per-version UUID + canonical "<domain>.<product>" human key.
    id: str = ""
    fqn: str = ""
    name: str
    table_name: str
    description: str
    type: str = ""
    data_type: str = ""
    primary_key: str = ""
    reference: str = ""
    domain_name: str = ""
    attributes: list[AttributeOut] = []

class SubdomainSummaryOut(BaseModel):
    # Stable per-version UUID; empty when the model dict carries no DB id (the
    # subdomain rollup is name-derived from products on the Volume-fallback path).
    id: str = ""
    name: str
    product_count: int = 0

class DomainSummaryOut(BaseModel):
    # Stable per-version UUID; empty for previous-version-only (deleted)
    # placeholders that carry no current DB row.
    id: str = ""
    name: str
    division: str = ""
    description: str = ""
    database_name: str = ""
    references: str = ""
    product_count: int = 0
    subdomains: list[SubdomainSummaryOut] = []
    change_status: ChangeStatus = ChangeStatus.UNCHANGED

class DomainDetailOut(BaseModel):
    name: str
    division: str = ""
    description: str = ""
    database_name: str = ""
    references: str = ""
    products: list[ProductSummaryOut] = []

class ModelSummaryOut(BaseModel):
    name: str
    version: int
    description: str = ""
    industry_alignment: str = ""
    core_business_processes: str = ""
    vibe_modeling_instructions: str = ""
    domain_count: int = 0
    subdomain_count: int = 0
    product_count: int = 0
    attribute_count: int = 0
    fk_count: int = 0
    confidence_score: Optional[float] = None
    # Product-level review progress (0..1): reviewed ÷ review-needed products.
    # ``no_review_needed`` products are excluded from review_needed. Resets per
    # version (ProductReview FKs straight to this version's product rows).
    review_pct: float = 0.0
    reviewed_count: int = 0
    review_needed_count: int = 0
    no_review_needed_count: int = 0
    domains: list[DomainSummaryOut] = []

class ModelSearchHitOut(BaseModel):
    """One model-wide search result.

    ``type`` names the element kind; the ``*_name`` fields carry exactly what
    URL navigation needs (domain page for a domain/product hit, tabular product
    page for an attribute/column hit). ``label`` is the matched element name and
    ``sublabel`` a breadcrumb-ish context string for the palette secondary line.
    """

    type: str  # "domain" | "product" | "attribute"
    domain_name: str
    product_name: Optional[str] = None
    attribute_name: Optional[str] = None
    label: str
    sublabel: str = ""

# --- User Preferences ---

class UserPreferenceOut(BaseModel):
    key: str
    value: str
    updated_at: datetime

class UserPreferenceIn(BaseModel):
    value: str


class CurrentUserEmailOut(BaseModel):
    value: str


class CurrentUserOut(BaseModel):
    """Response shape for ``GET /current-user``.

    ``user_name`` is the canonical identity (email first, then preferred
    username); ``display_name`` is the preferred username when present.
    Anonymous callers get ``user_name="anonymous"``.
    """

    user_name: str
    display_name: str
    emails: list[CurrentUserEmailOut]


class UserPreferenceDeleteOut(BaseModel):
    """Response shape for ``DELETE /user/preferences/{key}``.

    ``deleted`` is False when the caller had no row for the key; the route is
    idempotent and never 404s.
    """

    deleted: bool


class MetamodelCleanupSummaryOut(BaseModel):
    """How many ``_metamodel`` cleanup rows a delete left in each state."""

    done: int = 0
    pending: int = 0
    failed: int = 0


class MetamodelCleanupOut(BaseModel):
    """One ``metamodel_cleanups`` row: removal of a deleted version's
    ``_metamodel`` rows from one catalog. ``status`` pending | done | failed;
    ``reason`` version_delete | business_delete | post_install_delete |
    orphan_drop."""

    id: str
    business_segment: str
    version: int
    scope: str
    catalog: str
    reason: str
    status: str
    attempts: int = 0
    last_error: Optional[str] = None
    updated_at: datetime


class BusinessDeleteOut(BaseModel):
    """Response shape for ``DELETE /businesses/{id}``."""

    ok: bool
    cascaded: bool
    metamodel_cleanup: MetamodelCleanupSummaryOut = Field(default_factory=MetamodelCleanupSummaryOut)


class DeleteVersionOut(BaseModel):
    """Response shape for ``DELETE /businesses/{id}/versions/{vid}``.

    The route deletes one version's Lakebase rows and records the removal of
    its ``_metamodel.*`` rows per catalog (``metamodel_cleanup``); it starts
    no run.
    """

    deleted_version: int
    # When the deleted version was the scope head: the head after the delete
    # (its restored predecessor), else NULL.
    previous_version: Optional[int] = None
    # True iff a cleanup found registry rows of this version and removed
    # them. False when none was found (e.g. never written to Delta).
    metamodel_rows_cleaned: bool = False
    # Outcome of the ``_metamodel`` cleanup rows the delete wrote, one per
    # catalog, after its post-commit attempt.
    metamodel_cleanup: MetamodelCleanupSummaryOut = Field(default_factory=MetamodelCleanupSummaryOut)
    # Feedback items the deleted version had applied that are open again.
    reopened_input_count: int = 0
    message: str

class VersionTreeOut(BaseModel):
    id: str
    version: int
    status: str
    deployment_status: str = "draft"
    base_version_id: Optional[str] = None
    vibe_instructions: str = ""
    confidence_score: Optional[float] = None
    scope: str = ""
    created_at: datetime
    is_base: bool = True
    # A shrink/enlarge output whose lineage parent was deleted: Vibed, labelled so.
    parent_deleted: bool = False

# --- ER Diagram ---

class DiagramNodePort(BaseModel):
    """A column represented as a port on a table node."""

    id: str
    name: str
    is_pk: bool = False
    is_fk: bool = False
    type: str = ""
    description: str = ""
    fk_target: str = ""  # "domain.product.column" if FK

class DiagramNode(BaseModel):
    """A product/table positioned in the diagram."""

    id: str  # "domain.product"
    domain: str
    product: str
    table_name: str
    product_type: str = ""  # Master/Transactional/Reference/Association
    description: str = ""
    x: float = 0
    y: float = 0
    width: float = 0
    height: float = 0
    columns: list[DiagramNodePort] = []
    column_count: int = 0
    fk_count: int = 0
    change_status: ChangeStatus = ChangeStatus.UNCHANGED

class DiagramEdge(BaseModel):
    """A foreign key relationship between two table nodes."""

    id: str
    source_node: str  # "domain.product"
    source_column: str
    target_node: str  # "domain.product"
    target_column: str
    # Focal-view routing (Increment 1). Additive + backward-compatible: empty
    # ``waypoints`` means "no backend routing — the frontend falls back to its
    # smoothstep path" (overview + keys/all focal). When non-empty these are
    # absolute polyline points (x, y) from the source anchor to the target
    # anchor; the frontend draws the polyline directly and self-orients the
    # crow's-foot markers, so no separate anchor side/offset is emitted.
    waypoints: list[tuple[float, float]] = []

class DiagramDomainGroup(BaseModel):
    """A domain boundary rectangle in the diagram."""

    id: str  # "domain:name"
    domain: str
    division: str = ""
    x: float = 0
    y: float = 0
    width: float = 0
    height: float = 0
    is_external: bool = False  # True for related domains in domain-specific view
    product_count: int = 0

class DiagramLayoutOut(BaseModel):
    """Complete positioned diagram layout returned by the backend."""

    nodes: list[DiagramNode] = []
    edges: list[DiagramEdge] = []
    groups: list[DiagramDomainGroup] = []
    domain_filter: Optional[str] = None
    show_columns: bool = False
    total_products: int = 0
    total_edges: int = 0


class DiagramPendingOut(BaseModel):
    """202 response body when a diagram layout is still computing.

    Carries a heartbeat timestamp + queue position so the frontend can show
    ``we're alive, you're #3 in queue`` instead of an opaque spinner.
    """

    status: str = "computing"
    key: str
    # ms-epoch of the most recent heartbeat signal for this key (or the request
    # time if the job hasn't emitted progress yet). Lets the UI display how
    # stale the signal is and detect truly-wedged workers.
    last_heartbeat_ms: int = 0
    # 1-indexed position of this key in the prefetch queue. ``None`` when the
    # key is no longer tracked (shouldn't happen on the 202 path, but kept
    # nullable so the contract is robust).
    queue_position: Optional[int] = None
    # Total number of pending jobs the prefetch pool knows about.
    total_in_queue: int = 0


class DomainConnectivityOut(BaseModel):
    """A pair of connected domains and the FK count between them."""
    source_domain: str
    target_domain: str
    fk_count: int


class RelationshipAnalysisOut(BaseModel):
    """Aggregated FK statistics and domain connectivity for a model version."""
    total_fk_count: int = 0
    cross_domain_fk_count: int = 0
    intra_domain_fk_count: int = 0
    domain_connectivity: list[DomainConnectivityOut] = []


# --- Feedback ---

class FeedbackContext(BaseModel):
    """The model element an "Add feedback" surface is about, by name.

    Feedback is about the model, so this carries model coordinates only and
    no view state (tab, column mode, filters). It is not stored: the create
    endpoint resolves it against the viewed version into the input's anchor
    (``core/anchor_resolve.resolve_feedback_anchor``). The lowest coordinate
    set wins: attribute (with ``selected_node_id``) > product > relationship
    > domain; none set is the whole model.
    """
    domain_filter: Optional[str] = None
    selected_node_id: Optional[str] = None  # "domain.product"
    selected_edge_id: Optional[str] = None  # "fk:..."
    selected_attribute: Optional[str] = None  # attribute name in selected_node_id


# --- Vibe Inputs (durable input content + anchoring) ---

class VibeInputIn(BaseModel):
    """Input for creating a vibe input.

    ``author`` is resolved from auth headers by the create endpoint (Task 5);
    it is accepted as a field so In→DB contract coverage maps to the new
    ``author`` column. ``version_id`` and the element ids are transient anchor
    fields — the create endpoint materializes the origin ``VibeInputContextLink``
    from them; they are not columns on ``VibeInput``.
    """
    text: str
    origin: VibeInputOrigin = VibeInputOrigin.USER
    priority: VibeInputPriority = VibeInputPriority.MEDIUM
    confidence_score: Optional[float] = None
    author: str = ""
    version_id: Optional[str] = None
    domain_id: Optional[str] = None
    subdomain_id: Optional[str] = None
    product_id: Optional[str] = None
    attribute_id: Optional[str] = None
    fk_link_id: Optional[str] = None
    # Name-based view selection from "Add Feedback" surfaces (the FE holds
    # names, not DB ids). When no explicit element id is given, the create
    # endpoint resolves this against version_id to the anchor element ids.
    origin_context: Optional[FeedbackContext] = None


class VibeInputPatchIn(BaseModel):
    """Edit text/priority. Status + consumed + selected_for_run are driven by
    dedicated endpoints, not free PATCH."""
    text: Optional[str] = None
    priority: Optional[VibeInputPriority] = None


class VibeInputSelectionIn(BaseModel):
    """Bulk set the run-selection flag on a set of inputs. One body serves
    both the single-card toggle (1-element list) and select-all-under-a-tree-
    branch (N-element list). Consumed and out-of-business ids are skipped."""
    input_ids: list[str]
    selected: bool


class VibeInputAnchorOut(BaseModel):
    """Read-only, head-version anchor projection for an input, hydrated by
    listVibeInputs so the FE section tree can render element-named headers
    without an N+1 of /links calls. The durable anchor lives on
    VibeInputContextLink; this is a derived view and is never persisted.

    ``level == "model_wide"`` (link present on the head version but unscoped,
    empty ``path``) is DISTINCT from a null ``VibeInputOut.anchor`` (no link on
    the head version at all).
    """
    level: str
    domain_id: Optional[str] = None
    domain_name: Optional[str] = None
    subdomain_id: Optional[str] = None
    subdomain_name: Optional[str] = None
    product_id: Optional[str] = None
    product_name: Optional[str] = None
    attribute_id: Optional[str] = None
    attribute_name: Optional[str] = None
    fk_link_id: Optional[str] = None
    fk_label: Optional[str] = None
    # The relationship's diagram edge id, the same id the diagram gives it
    # (``anchor_resolve.fk_link_edge_ids``: source column = the source
    # attribute's column_name); what an Add-feedback ``selected_edge_id`` carries.
    fk_edge_id: Optional[str] = None
    path: list[str] = []


class VibeInputOut(BaseModel):
    id: str
    business_id: str
    origin: VibeInputOrigin
    author: str
    text: str
    # Agent next-vibe classification; null for origin=user inputs.
    category: Optional[NextVibeCategory] = None
    priority: VibeInputPriority
    confidence_score: Optional[float]
    consumed: bool
    # The run whose success consumed this input; None while open.
    consumed_by_run_id: Optional[str] = None
    selected_for_run: bool
    status: VibeInputStatus
    deprecated_by: Optional[str]
    created_at: datetime
    updated_at: datetime
    anchor: Optional[VibeInputAnchorOut] = None


class VibeInputContextLinkIn(BaseModel):
    input_id: str
    version_id: str
    domain_id: Optional[str] = None
    subdomain_id: Optional[str] = None
    product_id: Optional[str] = None
    attribute_id: Optional[str] = None
    fk_link_id: Optional[str] = None
    is_origin: bool = False


class VibeInputContextLinkOut(BaseModel):
    id: str
    input_id: str
    version_id: str
    domain_id: Optional[str]
    subdomain_id: Optional[str]
    product_id: Optional[str]
    attribute_id: Optional[str]
    fk_link_id: Optional[str]
    is_origin: bool
    needs_link_review: bool
    reviewed_by: Optional[str]
    reviewed_at: Optional[datetime]
    created_at: datetime


RunConsumeNote = Literal[
    "dry_run_pending_install",
    "dry_run_installed",
    "sync_failed",
    "version_mismatch",
    "malformed",
    "no_outcomes_reported",
    "pre_0_9_0",
    "install_consumed",
]


class RunReportItemOut(BaseModel):
    """One input a run sent (its ``RunInputLink``) with the input's state now.

    ``outcome_status`` is the agent's status for the input (``applied``,
    ``partial``, ``deferred``, ``scope_rejected``, ...; unknown values pass
    through), ``not_reported`` when the agent reported outcomes but none (or
    one with no status) for this input, ``applied`` / ``reopened`` on install runs, and None when the
    agent reported no outcomes. ``created_at`` is when the run linked it.
    """
    input_id: str
    outcome_status: Optional[str] = None
    outcome_reason: Optional[str] = None
    outcome_target: Optional[str] = None
    created_at: datetime
    text: str
    origin: VibeInputOrigin
    priority: VibeInputPriority
    status: VibeInputStatus
    consumed: bool
    consumed_by_run_id: Optional[str] = None
    selected_for_run: bool


class RunReportOut(BaseModel):
    """What a run did with the feedback it sent (``getRunReport``).

    ``consume_note`` says why inputs were or were not marked done; None when
    the agent's outcomes were applied normally. The ``*_version`` and
    ``lineage_*`` fields come from the agent's model.json and are None when
    the run recorded no agent report.
    """
    run_id: str
    business_id: str
    intent: str
    run_status: str
    # The version a vibe run produced; None for other runs and before success.
    output_version_id: Optional[str] = None
    dry_run: bool
    consume_note: Optional[RunConsumeNote] = None
    has_agent_report: bool
    has_input_outcomes: bool
    version_mismatch: bool
    expected_version: Optional[int] = None
    fetched_version: Optional[int] = None
    lineage_base_version: Optional[int] = None
    lineage_head_at_write: Optional[int] = None
    lineage_stale: Optional[bool] = None
    unmatched_outcome_count: int = 0
    items: list[RunReportItemOut] = []


class VersionReportOut(BaseModel):
    """The report of the vibe run that produced a version (``getVersionReport``);
    ``report`` is None when no vibe run produced it (generated or imported)."""
    version_id: str
    report: Optional[RunReportOut] = None


class SubdomainOut(BaseModel):
    id: str
    version_id: str
    domain_id: str
    name: str
    previous_element_id: Optional[str]
    created_at: datetime


class RunElementLineageOut(BaseModel):
    """Wire shape for a rename/merge/delete lineage edge (Task 4)."""
    id: str
    run_id: str
    version_id: str
    element_type: str
    change_kind: str
    old_element_id: Optional[str]
    new_element_id: Optional[str]
    old_fqn: str
    new_fqn: str
    reason: str
    created_at: datetime


class ReviewMarkIn(BaseModel):
    """Body for a review mark at any granularity (product / domain / subdomain).

    The target element id rides the URL path; this carries only the chosen
    ``state``. For aggregation grains (domain / subdomain) the state fans out
    onto the product rows beneath the target (the cascade write semantics)."""
    state: ReviewState = ReviewState.REVIEWED


class ProductReviewOut(BaseModel):
    """Effective review state of a single product.

    ``is_explicit`` distinguishes a stored user mark (``product_reviews`` row)
    from a computed default. ``id``/``reviewer``/``reviewed_at`` are populated
    only for explicit rows (empty/None for computed defaults).
    ``product_name``/``fqn`` make a review row self-describing (the human key
    alongside the stable ``product_id`` UUID) so the FE never renders a raw
    UUID; ``fqn`` is the canonical "<domain>.<product>"."""
    id: str = ""
    version_id: str
    product_id: str
    product_name: str = ""
    fqn: str = ""
    state: ReviewState
    reviewer: str = ""
    reviewed_at: Optional[datetime] = None
    is_explicit: bool = False


class ReviewProgressOut(BaseModel):
    """Product-level review progress for a scope (model or a domain).

    ``review_pct`` = reviewed ÷ review-needed (0.0 when nothing needs review);
    ``no_review_needed`` is excluded from ``review_needed``."""
    version_id: str
    review_pct: float = 0.0
    reviewed: int = 0
    review_needed: int = 0
    no_review_needed: int = 0
    total: int = 0


class DomainReviewProgressOut(BaseModel):
    """Per-domain review rollup (derived; no stored aggregate).

    ``review_pct`` = reviewed ÷ review-needed for the domain's products
    (0.0 when nothing needs review); ``no_review_needed`` is excluded from
    ``review_needed``. ``domain`` carries the domain name (the human key the
    scope tree / focus table render by); ``domain_id`` is the stable UUID."""
    domain_id: str
    domain: str = ""
    review_pct: float = 0.0
    reviewed: int = 0
    review_needed: int = 0
    no_review_needed: int = 0


class ReviewCascadeOut(BaseModel):
    """Result of a cascade mark: how many product rows were written and their
    effective states after the write."""
    version_id: str
    affected: int = 0
    products: list[ProductReviewOut] = []


class NextVibeCategoryCountsOut(BaseModel):
    """Open agent-next-vibe counts per ``NextVibeCategory``.

    One non-negative integer per category; the keys match the enum values so
    the client gets a stable, exhaustive shape regardless of which categories
    are present in the data. ``total`` is their sum (== ``total_open``)."""
    static_analysis: int = 0
    priority_remediation: int = 0
    other: int = 0
    total: int = 0


class NextVibeMetricsOut(BaseModel):
    """next_vibes "expected work" metrics for one scope on a version (T13).

    Sourced from open (active, non-consumed) ``origin=agent_next_vibe``
    ``VibeInput`` rows anchored to the scope via ``VibeInputContextLink``:

    * ``quality_score`` — the Model Quality Score: the **mean** of the open
      agent inputs' ``confidence_score`` in scope, ``None`` when there are no
      scored open inputs. The mean is the version-/domain-level representative
      score (a single 0..1 value the FE renders as the headline metric).
    * ``counts`` — open count broken out by category.
    * ``total_open`` — total open agent inputs in scope (== ``counts.total``).
    * ``has_data`` — ``False`` when there are zero open agent inputs in scope
      (the pre-ingestion default). Lets the FE distinguish "genuinely zero
      expected work" from "the next_vibes source has not been populated yet":
      both degrade to zeros/null, only ``has_data`` tells them apart.

    ``domain_id`` is ``None`` for the model scope; set to the resolved domain
    id for the domain scope. Domain scope counts an input when ANY of its
    anchor links on this version resolves to that domain — directly via
    ``domain_id`` or derived from the product/attribute anchor's product →
    domain map (the same derivation the seeder uses)."""
    version_id: str
    domain_id: Optional[str] = None
    quality_score: Optional[float] = None
    counts: NextVibeCategoryCountsOut = NextVibeCategoryCountsOut()
    total_open: int = 0
    has_data: bool = False


# --- Model Evolution Metrics (T16, "Model Evolution Metrics" epic) ---------

class EvolutionSizeOut(BaseModel):
    """Size tally for the version. Counts are the agent's
    ``model_stats_at_generation`` when present, else derived from the model
    structure. ``avg_attributes_per_product`` is derived; ``unlinked_id_count``
    / ``siloed_count`` are agent-only static-analysis findings (``None`` for
    metadata-less imports)."""
    domain_count: Optional[int] = None
    product_count: Optional[int] = None
    attribute_count: Optional[int] = None
    fk_count: Optional[int] = None
    unlinked_id_count: Optional[int] = None
    siloed_count: Optional[int] = None
    avg_attributes_per_product: Optional[float] = None


class EvolutionQualityOut(BaseModel):
    """Quality signals. ``confidence_score`` is a 0..100 percentage, ``None``
    when the run produced no confidence (ECM, or any unjudged run) — never
    coerced to 0. ``issues_addressed`` / ``issues_not_addressed`` are the
    agent's verified issue-resolution claims for this run."""
    confidence_score: Optional[float] = None
    error_count: Optional[int] = None
    warning_count: Optional[int] = None
    info_count: Optional[int] = None
    issues_addressed: list[str] = []
    issues_not_addressed: list[str] = []


class VersionHistoryEntryOut(BaseModel):
    """One point on the per-version timeline (newest last), for sparklines."""
    version: str = ""
    confidence: Optional[int] = None
    errors: Optional[int] = None
    warnings: Optional[int] = None
    unlinked: Optional[int] = None
    trend: Optional[str] = None
    products: Optional[int] = None
    fks: Optional[int] = None


class EvolutionChangeOut(BaseModel):
    """Change vs the previous version. On a baseline (predecessor-less) version
    ``version_trend == "baseline"`` and every delta/previous_* is ``None`` (no
    predecessor to diff against — a 0 would be misleading). ``version_history``
    is the full timeline regardless (a single entry on a baseline).

    ``model_touched_pct`` is the share (0..100) of the model touched this
    version, normalized by the UNION of both versions
    (``(added+modified+removed) / (current_product_count + removed)``) so it
    stays bounded and a deletion-only version reads above 0. Derived from the
    SAME per-product change diff behind the UI change icons
    (``explorer._compute_diff``); ``None`` on a baseline.

    ``products_added`` / ``products_modified`` / ``products_removed`` are the
    raw change-count breakdown behind that ratio (NEW / MODIFIED / DELETED
    product counts from the same diff); each ``None`` on a baseline."""
    version_trend: Optional[str] = None
    model_touched_pct: Optional[float] = None
    products_added: Optional[int] = None
    products_modified: Optional[int] = None
    products_removed: Optional[int] = None
    confidence_delta: Optional[int] = None
    warnings_delta: Optional[int] = None
    errors_delta: Optional[int] = None
    unlinked_delta: Optional[int] = None
    previous_confidence: Optional[int] = None
    previous_warnings: Optional[int] = None
    previous_errors: Optional[int] = None
    previous_unlinked: Optional[int] = None
    version_history: list[VersionHistoryEntryOut] = []


class EvolutionEffortOut(BaseModel):
    """AI effort/cost for the run that produced this version.
    ``per_model_cost_usd`` maps serving-model name → USD."""
    total_ai_calls: Optional[int] = None
    estimated_input_tokens: Optional[int] = None
    estimated_output_tokens: Optional[int] = None
    estimated_total_cost_usd: Optional[float] = None
    per_model_cost_usd: dict[str, float] = Field(default_factory=dict)
    duration_hours: Optional[float] = None


class EvolutionProvenanceOut(BaseModel):
    """Where the version came from: the agent build tag, the agent's own
    version labels, and the run status."""
    agent_version: Optional[str] = None
    generated_from_version: Optional[str] = None
    target_model_version: Optional[str] = None
    status: Optional[str] = None


class EvolutionMetricsOut(BaseModel):
    """Model-scope evolution metrics for one version (T16).

    Sourced on demand from the version's Volume ``model.json``
    ``_vibe_session_metadata`` block (NOT Lakebase — the sync drops it). Adds
    no migration. Degrades cleanly with data-driven flags so the FE never has
    to fabricate values:

    * ``has_metadata`` — ``False`` when the envelope carried no
      ``_vibe_session_metadata`` (hand-edited / pre-metadata import). The
      ``size`` block still degrades to structure-derived counts; everything
      else is null/empty.
    * ``has_confidence`` — ``False`` for ECM and any run the quality judge
      didn't score. ``quality.confidence_score`` is then ``None``.
    * ``has_predecessor`` — ``False`` on a baseline/first version. The
      ``change`` deltas/previous_* are then ``None`` and ``version_trend`` is
      ``"baseline"``.
    """
    version_id: str
    size: EvolutionSizeOut = EvolutionSizeOut()
    quality: EvolutionQualityOut = EvolutionQualityOut()
    change: EvolutionChangeOut = EvolutionChangeOut()
    effort: EvolutionEffortOut = EvolutionEffortOut()
    provenance: EvolutionProvenanceOut = EvolutionProvenanceOut()
    has_metadata: bool = False
    has_confidence: bool = False
    has_predecessor: bool = False


# --- Vibe Inputs: re-link / review-queue / compile request-response shapes ---

class CarryForwardResultOut(BaseModel):
    """Result of running the re-link tiers across a version (Task 5 §3.4)."""
    version_id: str
    auto_linked: int = 0          # tiers 1+2
    needs_review: int = 0         # tiers 3+4
    deprecated: int = 0           # tier 5
    skipped_existing: int = 0     # already had a link to the target version
    link_ids_needing_review: list[str] = []


class ReanchorIn(BaseModel):
    """Move a flagged link to a user-chosen element on the same version. All
    element ids nullable; all-null = model-wide."""
    domain_id: Optional[str] = None
    subdomain_id: Optional[str] = None
    product_id: Optional[str] = None
    attribute_id: Optional[str] = None
    fk_link_id: Optional[str] = None


class ReviewQueueItemOut(BaseModel):
    link: VibeInputContextLinkOut
    input: VibeInputOut
    proposed_anchor_label: str        # hydrated, e.g. "Domain X › Product Y"
    tier: str                         # "merge_survivor" | "partial_ancestor"


class ReviewQueueOut(BaseModel):
    total: int = 0                    # count of needs_link_review links (progress)
    items: list[ReviewQueueItemOut] = []   # oldest-first; UI processes head-of-queue


class CompileIn(BaseModel):
    """Explicit selection of input ids to serialize. Empty = compile nothing.

    When vibe_scope_domains is non-empty, the compile is scoped: only inputs
    anchored in those domains are included; model-wide inputs are excluded
    with the reason "model_wide_in_scoped_run".
    """
    input_ids: list[str] = []
    # Non-empty => scoped compile: keep only inputs anchored in these domains
    # (normalized match), exclude model-wide inputs. Empty => today's behaviour.
    vibe_scope_domains: list[str] = []


class CompiledBlockOut(BaseModel):
    """Structured provenance for one included input. Provenance rides as
    metadata, never as inline markers in the markdown."""
    input_id: str
    origin: VibeInputOrigin
    priority: VibeInputPriority
    author: str
    confidence_score: Optional[float]   # null for user inputs; never coerced to 0
    section_path: list[str]             # e.g. ["Domain: Sales", "Product: Orders"]
    text: str


class CompileOut(BaseModel):
    markdown: str = ""                  # the single doc handed to the agent (no markers)
    # NEW: markdown + inline [target] anchors + K1 markers (what launch sends to agent).
    # markdown carries no markers; agent_markdown does. See design §6, D9.
    agent_markdown: str = ""
    blocks: list[CompiledBlockOut] = []
    included_input_ids: list[str] = []  # excludes deprecated/missing
    excluded_input_ids: list[str] = []  # deprecated or not-on-this-version
    excluded_reasons: dict[str, str] = {}  # input_id -> reason (may include "out_of_scope", "model_wide_in_scoped_run")
    # input_id -> the scope domain its anchor on this version maps to (the
    # same rule the scoped compile filters by); None for model-wide and
    # unanchored inputs, which a scoped run does not send.
    input_scope_domains: dict[str, Optional[str]] = {}


# --- Model Import ---

class BusinessDigest(BaseModel):
    """Business identity + context pulled out of a model.json payload.

    Drives two flows: seeding a brand-new Business on create-by-import,
    and diffing against an existing Business so the user can spot
    misrouted imports before they land.
    """
    business_name: str = ""
    industry_alignment: str = ""
    description: str = ""
    # Agent release that produced the model.json (top-level ``agent_version``;
    # empty for flat/hand-edited files). Surfaced in the import analysis.
    agent_version: str = ""
    # Draft detailed description assembled from the enriched context below —
    # the ``business_vibes`` seed the import pre-fills (editable).
    business_vibes: str = ""
    core_business_processes: str = ""
    data_domains: str = ""
    orgnaization_divisions: str = ""
    common_business_jargons: str = ""
    operational_systems_of_records: str = ""
    industry_governing_body: str = ""
    # The catalog industry ``industry_alignment`` resolves to
    # (``industry_resolve.resolve_industry``); None when nothing matches or the
    # match is ambiguous. Set by the analyze route only.
    industry_id: Optional[str] = None


class FieldMismatch(BaseModel):
    """A single field where the digest disagrees with the current Business."""
    field: str
    source_value: str
    current_value: str


class BusinessDigestDiff(BaseModel):
    """Diff envelope returned alongside ``ImportAnalyzeOut`` when importing
    into an existing business. ``mismatch_fields`` empty → safe to import
    without the warning panel."""
    digest: BusinessDigest
    mismatch_fields: list[FieldMismatch] = []


class ImportAnalyzeIn(BaseModel):
    """Request to analyze a model.json at a Volume path without importing."""
    volume_path: str


class ImportAnalyzeOut(BaseModel):
    """Result of analyzing a model.json before importing."""
    valid: bool
    inferred_version: str
    action: str  # "import_as_is" | "unsupported"
    message: str
    domain_count: int = 0
    product_count: int = 0
    attribute_count: int = 0
    fk_count: int = 0
    warnings: list[str] = []
    detected_agent_tag: str = ""
    compat_verdict: str = "unknown"
    latest_supported_tag: str = ""
    # Story-1 (create-by-import): populated when the model.json carries a
    # business identity. UI uses this to pre-fill the new-business form.
    business_digest: Optional[BusinessDigest] = None
    # Story-2 (import-into-existing): populated when ``business_id`` is
    # known. ``mismatch_fields`` non-empty → UI shows the warning panel.
    business_digest_diff: Optional[BusinessDigestDiff] = None
    # The scope the file and its path settle; None when the user must choose
    # (``import_model.import_scope``).
    inferred_scope: Optional[Literal["ecm", "mvm"]] = None
    # True when the file's version, its agent folder or agent output settles
    # the scope; False when only its requirements suggest it (the user's
    # choice still wins) or nothing does.
    scope_settled: bool = False
    # The file is agent output and is imported as the agent wrote it
    # (``import_model.is_agent_output``; a run id given at import also counts).
    agent_output: bool = False
    # The file's ``model_conventions.schema_prefix`` ("" when it names none).
    file_schema_prefix: Optional[str] = None
    # The schema prefix the app's copy uses; None when the file's is kept or
    # the scope is not known yet.
    import_schema_prefix: Optional[str] = None


class ImportExecuteIn(BaseModel):
    """Request to execute an import. Volume path must match a prior analyze call."""
    volume_path: str
    # Story-2: explicit user opt-in to import even when the model.json's
    # business identity disagrees with the target Business. Server
    # returns 409 when mismatches exist and this flag is False.
    accept_business_mismatch: bool = False
    # The Databricks run that produced the file: linked right after the
    # import commits (``run_link.link_after_import``); a refused link leaves
    # the import in place and adds a warning.
    databricks_run_id: Optional[int] = None
    # The user's ECM / MVM choice, needed when the analyze reported no
    # ``inferred_scope``; refused when it contradicts the file's version.
    scope: Optional[Literal["ecm", "mvm"]] = None


class ImportCreateBusinessAndExecuteIn(BaseModel):
    """Story-1 request: create a Business from the model.json + import it.

    All ``*_override`` fields are optional. When provided they override
    the digest's values before the Business is created; otherwise the
    digest is used as-is.
    """
    volume_path: str
    business_name_override: Optional[str] = None
    industry_alignment_override: Optional[str] = None
    description_override: Optional[str] = None
    # The detailed description (business_vibes) the user reviewed — defaults to
    # the digest's assembled draft when omitted.
    business_vibes_override: Optional[str] = None
    # The catalog industry the user picked; wins over resolving the alignment.
    industry_id: Optional[str] = None
    # Add the industry alignment to the catalog when no industry matches it.
    # Without it an unmatched alignment leaves the business with no industry.
    create_industry: bool = False
    # As on ``ImportExecuteIn``.
    databricks_run_id: Optional[int] = None
    scope: Optional[Literal["ecm", "mvm"]] = None



class IndustryScopePrefixesIn(BaseModel):
    """``applyIndustryScopePrefixes``: give an industry downloaded before 0.9.0
    the scope prefixes a download adds now. ``apply`` False (the default)
    reports what would change and writes nothing."""
    apply: bool = False


ScopePrefixAction = Literal["changed", "unchanged", "skipped", "failed"]


class IndustryScopePrefixRowOut(BaseModel):
    """One industry version: ``changed`` (or, in a dry run, would change),
    ``unchanged`` (nothing to do), ``skipped`` (left as it is: ``reason``
    says why, e.g. installed in the catalogs it names) or ``failed`` (the
    apply stopped on it: ``reason`` says what completed; a rerun finishes it)."""
    version_id: str
    version: int
    scope: str
    action: ScopePrefixAction
    reason: str
    warnings: list[str] = Field(default_factory=list)


class IndustryScopePrefixesOut(BaseModel):
    """What ``applyIndustryScopePrefixes`` did, one row per version."""
    business_id: str
    business_name: str
    applied: bool
    rows: list[IndustryScopePrefixRowOut] = Field(default_factory=list)


class ImportExecuteOut(BaseModel):
    version_id: str
    version: int
    domains: int
    products: int
    attributes: int
    fk_links: int
    warnings: list[str] = []
    detected_agent_tag: str = ""
    compat_verdict: str = "unknown"
    latest_supported_tag: str = ""
    # The Run recorded for ``databricks_run_id``; None when none was given or
    # the link was refused (the reason is in ``warnings``).
    linked_run_id: Optional[str] = None


class ImportCreateBusinessAndExecuteOut(ImportExecuteOut):
    """Story-1 response: the regular execute envelope plus the new
    business id so the UI can redirect to it."""
    business_id: str


class ArtifactPreview(BaseModel):
    """A single companion artifact that the import will index."""
    path: str
    artifact_type: str
    size_bytes: Optional[int] = None


class ImportPreviewOut(BaseModel):
    """Preview of what an import will actually pull in from a Volume folder.

    Surfaces enough detail for the UI to show users what WILL be
    imported BEFORE they commit, and to warn when the agent's
    next-iteration suggestions can't be reconstructed (no
    ``next_vibes.{txt,json}`` at the source path).
    """
    model_json_found: bool
    next_vibes_status: str  # "txt" | "json" | "missing"
    next_vibes_path: Optional[str] = None
    companion_artifacts: list[ArtifactPreview] = []
    total_artifact_count: int = 0


# --- Next Vibes (agent-proposed follow-up operations) ---

class NextVibeItem(BaseModel):
    """A single agent-proposed follow-up operation.

    Parsed from the agent's `vibes/next_vibes.json` artifact — a big
    `vibe_modeling_instructions` blob split into ordered MUST DO / OPTIONAL
    steps the user can run as the next vibe.
    """
    id: str
    title: str
    description: str = ""
    priority: VibeInputPriority = VibeInputPriority.HIGH


class NextVibesOut(BaseModel):
    model_version_id: str
    items: list[NextVibeItem] = []
    summary: str = ""
    # 0..1 fraction (UI multiplies by 100 for the "%" label). Same
    # convention as ModelVersion.confidence_score and the agent's
    # model.json `confidence_score` field.
    confidence_score: Optional[float] = None
    status: str = ""  # agent's overall health label, e.g. "needs_work" / "healthy"


# --- Workspace catalogs ---


class CatalogOut(BaseModel):
    """One UC catalog the app service principal can list (``listCatalogs``).

    ``can_create_schema`` is True when a recent positive check of the app's
    privileges is cached (negative results are never cached); None means ask
    ``getCatalogCapabilities``.
    """

    name: str
    comment: str = ""
    owner: str = ""
    can_create_schema: Optional[bool] = None


class CatalogCapabilityOut(BaseModel):
    """What the app service principal can do in one catalog. None = could not
    be checked (over the per-call cap, timed out, or the grants read failed).

    ``create_schema``: USE_CATALOG + CREATE_SCHEMA on the catalog (runs that
    create schemas need it). ``use_metamodel``: the app can use
    ``<catalog>._metamodel`` and its ``vol_root`` volume, creating what is
    absent (every run needs it). The ``*_fix`` fields carry the GRANT
    statements for what is missing, for an admin to run; empty when nothing is.
    """

    name: str
    create_schema: Optional[bool] = None
    use_metamodel: Optional[bool] = None
    create_schema_fix: str = ""
    use_metamodel_fix: str = ""


# --- Run change review (accept or reject a vibe run's changes) ---

RunChangeElementKind = Literal["domain", "product", "attribute"]
RunChangeKind = Literal["added", "modified", "removed"]
# ``asked``: the element (or its product or domain) is the anchor of an input
# the run sent, or the target of an ``applied`` outcome; ``outside_scope``: a
# scoped run changed a domain outside its scope; ``not_asked``: neither, and
# the run sent no model-wide input; ``unclear``: the run sent a model-wide input.
RunChangeClass = Literal["asked", "outside_scope", "not_asked", "unclear"]
RunChangeDecisionValue = Literal["accepted", "rejected"]


class RunChangeOut(BaseModel):
    """One change between a vibe run's base and output version, with the
    modeler's decision when there is one."""

    element_kind: RunChangeElementKind
    element_path: str
    change_kind: RunChangeKind
    change_class: RunChangeClass
    decision: Optional[RunChangeDecisionValue] = None
    decided_by: Optional[str] = None
    decided_at: Optional[datetime] = None
    feedback_input_id: Optional[str] = None


class RunChangesOut(BaseModel):
    """``getRunChanges``: the changes a vibe run made. ``decisions_open`` is
    False once a newer run on the output version has started."""

    run_id: str
    version_id: str
    base_version_id: Optional[str] = None
    decisions_open: bool = True
    changes: list[RunChangeOut] = []


class RunChangeDecisionIn(BaseModel):
    element_kind: RunChangeElementKind
    element_path: str
    decision: RunChangeDecisionValue


class RunChangeDecisionsIn(BaseModel):
    """Body of ``setRunChangeDecisions``."""

    decisions: list[RunChangeDecisionIn]


class RunChangeReviewConfigOut(BaseModel):
    """``getRunChangeReviewConfig``: whether the run change review is on
    (``AppConfig.run_change_review_enabled``)."""

    enabled: bool


# --- Uninstall impact ---


class UninstallImpactTableOut(BaseModel):
    """``has_data`` None = not checked (over the cap, out of time, or failed),
    which callers treat as holding data."""

    name: str
    kind: str
    has_data: Optional[bool] = None


class UninstallImpactVersionOut(BaseModel):
    """Another version the app records as installed in the catalog."""

    version_id: str
    business_id: str
    business_name: str
    scope: str
    version: int


class UninstallImpactSchemaOut(BaseModel):
    """``shared``: the catalog's ``_metrics`` schema, which holds the metric
    views of every model installed in the catalog and is dropped by every
    uninstall there; ``other_versions`` are the other versions the app
    records as installed in the catalog, whose metric views go with it.
    ``objects_listed`` is False when the schema's tables, views and volumes
    could not be read (its lists are then empty)."""

    name: str
    owner: str = ""
    shared: bool = False
    objects_listed: bool = True
    tables: list[UninstallImpactTableOut] = []
    views: list[str] = []
    volumes: list[str] = []
    other_versions: list[UninstallImpactVersionOut] = []


class UninstallImpactOut(BaseModel):
    """``getUninstallImpact``: what uninstalling a version from a catalog
    drops. ``has_data`` is ``unknown`` when anything that may hold data could
    not be checked (a table, a volume, a schema in another catalog);
    ``reasons`` says why in plain sentences. ``truncated`` when the check
    stopped at its table cap or time budget, or could not list the schemas'
    objects. ``installed_catalogs``: every catalog the version is installed
    in now, latest install first; the impact is of ``catalog`` only, which
    may be none of them (the uninstall then drops what it finds there)."""

    version_id: str
    catalog: str
    schemas: list[UninstallImpactSchemaOut] = []
    has_data: Literal["yes", "no", "unknown"] = "unknown"
    truncated: bool = False
    reasons: list[str] = []
    installed_catalogs: list[str] = []


# --- Out-of-band versions (made by agent runs the app did not launch) ---


class OobVersionOut(BaseModel):
    """One out-of-band version. ``refused_reason`` is set when the app will
    not import it (an agent release the compatibility matrix rejects, a
    registry row waiting for the agent's migration, a failed import)."""

    version: int
    scope: str
    refused_reason: Optional[str] = None


class OobBusinessOut(BaseModel):
    """Out-of-band versions of one agent business segment. ``status``:
    ``existing`` = one app business has this segment (``business_id``);
    ``new`` = none has; ``ambiguous`` = several have
    (``candidate_business_ids``), and import is refused for it."""

    business_segment: str
    status: Literal["existing", "new", "ambiguous"]
    business_id: Optional[str] = None
    candidate_business_ids: list[str] = []
    versions: list[OobVersionOut] = []


class OobSummaryOut(BaseModel):
    """``getOobSummary``: the last cached check. ``checked_at`` None = never
    checked; ``skipped_reason`` says why the last check did not run or
    failed (``not_configured``, ``warehouse_not_running``, ``check_failed``);
    ``checking`` is True while a check runs in the background."""

    checked_at: Optional[datetime] = None
    catalog: str = ""
    skipped_reason: Optional[str] = None
    businesses: list[OobBusinessOut] = []
    checking: bool = False


class OobImportOut(BaseModel):
    """Result of an out-of-band import: versions imported and the businesses
    created (new-businesses import only)."""

    imported_versions: int = 0
    created_business_ids: list[str] = []
    warnings: list[str] = []


# --- Link an imported version to its run ---


class LinkRunIn(BaseModel):
    databricks_run_id: int


class LinkRunPreviewOut(BaseModel):
    """``previewLinkRun``. ``tier`` 1 = matched on the session id in
    ``_metamodel.business``, 2 = matched on output path and parameters; None
    when not linkable. ``problems`` holds the reasons a link is refused."""

    databricks_run_id: int
    linkable: bool
    tier: Optional[int] = None
    intent: Optional[str] = None
    evidence: list[str] = []
    problems: list[str] = []


# --- Orphan schemas ---


class OrphanSchemaOut(BaseModel):
    """A schema in the catalog that no installed version claims. ``match``:
    ``exact`` when the name came from a version Lakebase knows, ``inferred``
    when it was rebuilt from a registry name with the default prefixes.
    Only schemas the app service principal owns and with no
    ``blocked_reason`` are droppable; ``blocked_reason`` says why a schema
    of a version the app did not make (or cannot tell) is left alone."""

    name: str
    owner: str = ""
    owned_by_app: bool = False
    match: Literal["exact", "inferred"] = "exact"
    table_count: Optional[int] = None
    blocked_reason: Optional[str] = None


class OrphanSchemasOut(BaseModel):
    """``listOrphanSchemas``. ``impact`` is what dropping the selected
    schemas (or, with no selection, every droppable one) deletes, in the
    uninstall-impact shape; ``confirm_subject`` is the subject
    ``dropOrphanSchemas`` needs in ``confirmed_issues`` for that set when it
    holds data or could not be checked, else None."""

    catalog: str
    schemas: list[OrphanSchemaOut] = []
    impact: Optional[UninstallImpactOut] = None
    confirm_subject: Optional[str] = None


class DropOrphanSchemasIn(BaseModel):
    """Body of ``dropOrphanSchemas``. ``confirmed_issues`` carries the confirm
    subject the drop needs when a selected schema holds data or could not be
    checked (same protocol as ``RunIn.confirmed_issues``)."""

    catalog: str
    schemas: list[str]
    confirmed_issues: list[str] = []


class OrphanSchemaDropOut(BaseModel):
    """One schema of a drop: ``status`` ``dropped`` or ``failed`` (with a
    sanitized ``error``), as recorded in ``run_schema_drops``."""

    name: str
    status: str
    table_count: int = 0
    error: Optional[str] = None


class DropOrphanSchemasOut(BaseModel):
    """``dropOrphanSchemas``: the audit run, each schema's outcome, and the
    ``_metamodel`` cleanups of the registry versions whose schemas are all
    gone (they also show in ``listMetamodelCleanups``)."""

    run_id: str
    catalog: str
    schemas: list[OrphanSchemaDropOut] = []
    metamodel_cleanup: MetamodelCleanupSummaryOut = Field(default_factory=MetamodelCleanupSummaryOut)
