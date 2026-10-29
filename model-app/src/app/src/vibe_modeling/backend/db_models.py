"""SQLModel database tables for the Vibe Modeling control plane.

These tables live in Lakebase and track businesses, contexts, model versions,
pipeline runs, generated artifacts, agent configuration, model structure,
and progress events.
"""

from datetime import datetime, timezone
from typing import Any, Optional
import uuid

from sqlalchemy import (
    BigInteger, Boolean, Column, ForeignKey, Index, Integer, String, Text, UniqueConstraint, false, true,
)
from sqlalchemy import text as sa_text
from sqlmodel import Field, SQLModel, Relationship

from .runtime_budget import RUNTIME_BUDGET_DEFAULT_HOURS


def _uuid() -> str:
    return str(uuid.uuid4())

def _now() -> datetime:
    return datetime.now(timezone.utc)

class Business(SQLModel, table=True):
    """A business (or, with ``kind='industry'``, an industry meta-business).

    ``business_domains`` is deliberately denormalized: a comma+space separated
    list of domain schema names (``"a, b, c"``) holding the agent's
    ``business_domains`` widget value verbatim. The app never queries it per
    element (the same reason ``next_vibes_json`` stays opaque); it only
    pre-fills the first New Base Model run. ``org_divisions`` is the proposed
    coverage preset (one of ``models.ORG_DIVISIONS_PRESETS``) or ''.
    """

    __tablename__ = "businesses"

    id: str = Field(default_factory=_uuid, primary_key=True)
    name: str = Field(index=True, unique=True)
    # Short (≤2k) summary → the agent's ``business_description`` widget
    # (industry/complexity-tier seed). The full, arbitrarily-long detailed
    # description lives in ``business_vibes`` (Text) → the agent's ``model_vibes``
    # channel on the initial run, where large content spills to a UC Volume file.
    description: str = Field(default="")
    business_vibes: str = Field(default="", sa_column=Column(Text, default=""))
    industry_alignment: str = Field(default="")
    industry_id: Optional[str] = Field(default=None, foreign_key="industries.id")
    # Discriminator (ADR D-046): 'business' (a real business) or 'industry'
    # (a meta-business — surfaced as an "Industry", never "meta-business" in
    # the UI). Mirrored by the ``BusinessKind`` enum on the Pydantic layer.
    kind: str = Field(default="business", index=True)
    # The industry's place in the two-level taxonomy (ADR D-047). Nullable at
    # the column level; NOT NULL enforced at the app layer on industry import
    # only (existing businesses legitimately have no sector).
    sector_id: Optional[str] = Field(default=None, foreign_key="sectors.id")
    # Kickstart provenance (ADR D-050): the industry this business was
    # snapshotted from (self-FK to a kind='industry' row) + the version taken.
    source_industry_id: Optional[str] = Field(default=None, foreign_key="businesses.id", ondelete="SET NULL")
    source_version: Optional[int] = Field(default=None)
    # Industry-folder round-trip publish target (ADR D-049). The repo path
    # this industry was downloaded from (``github://owner/repo@ref/<industry_id>``);
    # pre-fills the publish dialog's editable bundle-root. NULL when the business
    # was never downloaded from a source (created/kickstarted in-app).
    source_repo_path: Optional[str] = Field(default=None)
    # Domain Taxonomy Builder proposal (v_0_8_0); '' = no proposal.
    business_domains: str = Field(default="")
    org_divisions: str = Field(default="")
    created_at: datetime = Field(default_factory=_now)
    updated_at: datetime = Field(default_factory=_now)

    industry: Optional["Industry"] = Relationship()
    sector: Optional["Sector"] = Relationship()
    contexts: list["BusinessContext"] = Relationship(
        back_populates="business",
        sa_relationship_kwargs={"passive_deletes": "all"},
    )
    versions: list["ModelVersion"] = Relationship(
        back_populates="business",
        sa_relationship_kwargs={"passive_deletes": "all"},
    )
    runs: list["Run"] = Relationship(
        back_populates="business",
        sa_relationship_kwargs={"passive_deletes": "all"},
    )

class BusinessContext(SQLModel, table=True):
    __tablename__ = "business_contexts"

    id: str = Field(default_factory=_uuid, primary_key=True)
    business_id: str = Field(foreign_key="businesses.id", ondelete="CASCADE", index=True)
    version_label: str = Field(default="")
    context_json: str = Field(default="{}")
    conventions_json: str = Field(default="{}")
    is_active: bool = Field(default=True)
    created_at: datetime = Field(default_factory=_now)

    business: Optional[Business] = Relationship(back_populates="contexts")

class Industry(SQLModel, table=True):
    __tablename__ = "industries"

    id: str = Field(default_factory=_uuid, primary_key=True)
    name: str = Field(default="")
    short_name: str = Field(default="", index=True)
    description: str = Field(default="", sa_column=Column(Text, default=""))
    notable_businesses: str = Field(default="")
    display_order: int = Field(default=0)
    is_active: bool = Field(default=True)
    is_auto_created: bool = Field(default=False)
    created_at: datetime = Field(default_factory=_now)
    updated_at: datetime = Field(default_factory=_now)


class Sector(SQLModel, table=True):
    """Top level of the two-level taxonomy (ADR D-047): repurposes the flat
    industry classification as the higher level. The lower level (industries
    / meta-businesses) are ``businesses`` rows with ``kind='industry'`` that
    carry ``sector_id``. Seeded at boot from a SECTOR_MAP snapshot (see
    ``sector_catalog.py`` + ``seed_sectors``)."""

    __tablename__ = "sectors"

    id: str = Field(default_factory=_uuid, primary_key=True)
    name: str = Field(default="")
    short_name: str = Field(default="", index=True)
    description: str = Field(default="", sa_column=Column(Text, default=""))
    display_order: int = Field(default=0)
    is_active: bool = Field(default=True)
    created_at: datetime = Field(default_factory=_now)
    updated_at: datetime = Field(default_factory=_now)


class AgentConfig(SQLModel, table=True):
    __tablename__ = "agent_config"

    id: str = Field(default_factory=_uuid, primary_key=True)
    notebook_path: str = Field(default="")
    job_id: Optional[int] = Field(default=None, sa_column=Column(BigInteger, nullable=True))
    job_name: str = Field(default="dbx_vibe_modelling")
    deployment_catalog: str = Field(default="")
    warehouse_id: str = Field(default="")
    # Persistent agent job's max_concurrent_runs. Minimum 3 — the app needs
    # headroom above the D-012 single-run gate for two benign overlaps:
    # (a) unified-pipeline phase transition (finalizing run briefly coexists
    # with the next phase's run_now) and (b) cancel-with-rollback (uninstall
    # cleanup launches while the cancelled run is still moving to TERMINATED).
    max_concurrent_runs: int = Field(
        default=3,
        sa_column=Column(Integer, nullable=False, server_default="3"),
    )
    # Settings -> Agent -> "Annotate jobs with run tags" (name kept). When True
    # (default), the per-run job tags add the business name, session id and
    # notebook file name; the operational tags are always added. A new row is
    # seeded from AppConfig.run_tags_default (install.sh --no-run-tags).
    # See backend/job_launcher.py:build_job_tags.
    collect_vibe_run_statistics: bool = Field(
        default=True,
        sa_column=Column(Boolean, nullable=False, server_default=true()),
    )
    # GitHub publish/browse config (ADR D-049). ``github_auth_mode`` is one of
    # '' | 'oauth_u2m' | 'secret_pat'. For OAuth U2M, ``github_connection_name``
    # names the UC HTTP connection; for the PAT fallback, the token lives in a
    # secret scope (``github_secret_scope``/``github_secret_key``) — never in
    # the row. ``github_repo_owner``/``github_repo_name`` are the installation's
    # publish-target repo (the public Databricks-managed repo is a constant).
    github_repo_owner: str = Field(default="")
    github_repo_name: str = Field(default="")
    github_auth_mode: str = Field(default="")
    github_connection_name: str = Field(default="")
    github_secret_scope: str = Field(default="")
    github_secret_key: str = Field(default="")
    # Source READ-auth config (0.7.1). Distinct from the publish fields above:
    # this drives how source browse / preview / download and the upstream-agent
    # monitor authenticate their reads of the public industry-models repo.
    # ``source_auth_mode`` is one of '' | 'github_app' | 'token' | 'anonymous'.
    # '' (unconfigured) falls back to the deployment env creds, then anonymous.
    # Secret material (App PEM, PAT) lives in a Databricks secret scope,
    # referenced by scope/key here — it never lands in this row. The App id /
    # installation id are non-secret. See sources/github.resolve_source_transport.
    source_auth_mode: str = Field(default="")
    source_github_app_id: str = Field(default="")
    source_github_app_installation_id: str = Field(default="")
    source_github_app_secret_scope: str = Field(default="")
    source_github_app_secret_key: str = Field(default="")
    source_token_secret_scope: str = Field(default="")
    source_token_secret_key: str = Field(default="")
    # Upstream agent-release monitor cache (Surface 2). The agent-compat health
    # surface live-reads the canonical repo notebook's __RELEASE_VERSION__ +
    # __AGENT_VERSION__ and caches the result here for 7 days so the Settings
    # page never blocks on a GitHub round-trip. All nullable: a cold cache
    # (never fetched) and a fetch that errored both leave these NULL, and a
    # fetch error keeps the last-good version values while recording the error.
    upstream_release_version: Optional[str] = Field(default=None)
    upstream_agent_version: Optional[str] = Field(default=None)
    upstream_checked_at: Optional[datetime] = Field(default=None)
    upstream_check_error: Optional[str] = Field(default=None)
    # Domain Taxonomy Builder (v_0_8_0). ``taxonomy_model_service`` is the UC
    # model service full name (``catalog.schema.service``) the wizard drafts
    # with; '' = not configured. Seeded once from the install-time
    # AppConfig.taxonomy_model_service; thereafter Settings owns it.
    # ``taxonomy_llm_max_concurrency`` caps live LLM calls app-wide (1-16).
    taxonomy_model_service: str = Field(default="")
    taxonomy_llm_max_concurrency: int = Field(
        default=6,
        sa_column=Column(Integer, nullable=False, server_default="6"),
    )
    # Identity of the notebook at ``notebook_path`` (v_0_9_0), read from the
    # workspace file and cached with a short TTL so boot, the Settings card and
    # the marker gates do not each re-export the notebook. ``installed_checked_path``
    # is the path the cached values were read from (a changed path invalidates
    # them). A failed read keeps the last-good versions and records the error.
    # All NULL until the first read.
    installed_release_version: Optional[str] = Field(default=None)
    installed_agent_version: Optional[str] = Field(default=None)
    installed_checked_at: Optional[datetime] = Field(default=None)
    installed_checked_path: Optional[str] = Field(default=None)
    installed_check_error: Optional[str] = Field(default=None)
    # Who last saved the taxonomy settings and when (v_0_9_0_1), the audit pair
    # ``assess_config`` keeps as ``updated_by`` / ``updated_at``. NULL until the
    # first save.
    taxonomy_updated_by: Optional[str] = Field(default=None)
    taxonomy_updated_at: Optional[datetime] = Field(default=None)
    # Settings -> Agent -> "Run time budget (hours)" (v_0_9_0_3): the default a
    # new run stores when it sets no budget of its own. See runtime_budget.py.
    runtime_budget_hours: int = Field(
        default=RUNTIME_BUDGET_DEFAULT_HOURS,
        sa_column=Column(
            Integer, nullable=False, server_default=str(RUNTIME_BUDGET_DEFAULT_HOURS)
        ),
    )
    created_at: datetime = Field(default_factory=_now)
    updated_at: datetime = Field(default_factory=_now)

class ModelVersion(SQLModel, table=True):
    __tablename__ = "model_versions"
    # The natural key for a ModelVersion is (business_id, version, scope)
    # — the agent's version counter is per-scope (e.g. v1_ecm + v1_mvm),
    # and the unified pipeline produces both in a single run, so the
    # (business, version) pair alone collides. Without this constraint,
    # the unified pipeline's MVM sync silently skips on collision.
    __table_args__ = (
        UniqueConstraint(
            "business_id",
            "version",
            "scope",
            name="uq_model_versions_business_version_scope",
        ),
    )

    id: str = Field(default_factory=_uuid, primary_key=True)
    business_id: str = Field(foreign_key="businesses.id", ondelete="CASCADE", index=True)
    version: int = Field(default=1)
    status: str = Field(default="draft")  # draft, generating, completed, failed
    deployment_status: str = Field(default="draft")  # draft, deployed, uninstalled
    base_version_id: Optional[str] = Field(default=None)
    vibe_instructions: str = Field(default="")
    context_id: Optional[str] = Field(default=None, foreign_key="business_contexts.id", ondelete="SET NULL")
    confidence_score: Optional[float] = Field(default=None)
    scope: str = Field(default="")  # "ecm" or "mvm"
    uc_catalog: str = Field(default="")
    completion_date: Optional[datetime] = Field(default=None)
    # Post-run sync state. ``ok`` (default) means the version's metadata
    # successfully landed in Lakebase + Volume; any other value means
    # something went wrong and downstream surfaces (diagrams, artifacts)
    # may be unavailable. Values:
    #   - ``ok``                    happy path: >=1 domain synced, metadata captured
    #   - ``incomplete_metadata``   sync found data but a write/metadata step
    #                               raised (partial write); Volume artifacts
    #                               exist, so a resync may recover
    #   - ``sync_empty``            no model structure to sync: ``sync_model``
    #                               returned False (no Volume + no Delta, G1) OR
    #                               the payload parsed to 0 domains (G2). A
    #                               resync won't help until the agent's Volume
    #                               output is populated
    #   - ``finalize_failed``       ``_finalize_session_completion`` raised
    #   - ``unknown``               reserved for future tagging
    sync_state: str = Field(default="ok")
    # Truncated to first 500 chars of the captured exception so the UI
    # banner can show the operator a hint without dragging a stack trace
    # into the wire format.
    sync_error_text: Optional[str] = Field(default=None, sa_column=Column(Text, nullable=True))
    # Provenance for imports — populated by the synchronous Volume → Lakebase
    # sync that the import dialog drives. NULL for agent-produced versions
    # (those have a parent ``Run`` carrying the equivalent metadata).
    import_source_path: Optional[str] = Field(default=None)
    imported_at: Optional[datetime] = Field(default=None)
    # Version provenance stamped from the model.json envelope at sync/import
    # time. ``agent_version`` is the agent-logic counter (``4.x.y`` from the
    # 0.8.0 agent line on); ``release_version`` is the public/compat release
    # identity (``0.8.0``), decoupled from the agent counter. Both NULL for
    # pre-existing rows and Delta-only payloads — model.json is re-read to
    # classify those on demand. Populated via
    # ``agent_compat.extract_version_provenance``.
    agent_version: Optional[str] = Field(default=None)
    release_version: Optional[str] = Field(default=None)
    # Version lifecycle (v_0_9_0). ``dry_run``: produced by a Dry Run; stays
    # True after the draft is installed. ``promoted_at`` /
    # ``promoted_by_run_id``: when and by which install run this version was
    # made current. ``replaced_at`` / ``replaced_by_version_id``: written on
    # every version an install drops; ``replaced_at`` is the flag and the id is
    # only a pointer (ON DELETE SET NULL clears it when the replacer is
    # deleted, which must not un-replace this version). Both cleared if this
    # version is made current again.
    dry_run: bool = Field(
        default=False,
        sa_column=Column(Boolean, nullable=False, server_default=false()),
    )
    promoted_at: Optional[datetime] = Field(default=None)
    # ``use_alter`` breaks the model_versions <-> runs FK cycle
    # (``runs.version_id`` points back here) so create_all / drop_all can order
    # the two tables; Postgres adds this constraint after both exist.
    promoted_by_run_id: Optional[str] = Field(
        default=None,
        sa_column=Column(
            String,
            ForeignKey("runs.id", ondelete="SET NULL", use_alter=True,
                       name="model_versions_promoted_by_run_id_fkey"),
            nullable=True,
            index=True,
        ),
    )
    replaced_by_version_id: Optional[str] = Field(
        default=None, foreign_key="model_versions.id", ondelete="SET NULL", index=True,
    )
    replaced_at: Optional[datetime] = Field(default=None)
    # Where the agent wrote this version's files and its home ``_metamodel``
    # rows. Set once when the version is created and never changed by an
    # install; ``uc_catalog`` is where it is installed now. NULL for imports
    # and for rows that predate it with no known catalog; readers must keep
    # falling back to the installation's catalog for NULL.
    files_catalog: Optional[str] = Field(default=None)
    # The model.json ``_vibe_scope`` facts: fence mode (``all`` / ``some_domains``)
    # and the base the agent scoped against. NULL when the file has no block.
    scope_fence_mode: Optional[str] = Field(default=None)
    scope_base_version: Optional[int] = Field(default=None)
    scope_base_scope: Optional[str] = Field(default=None)
    # The prefixes a 0.9.0 import put on the model's schemas and on its metric
    # view names (``services/scope_prefix``). ``""``: the app copied the
    # version's files into its own folder and added nothing. NULL: not brought
    # in by a 0.9.0 import (agent runs, older rows). Publishing strips exactly
    # these.
    import_schema_prefix_added: Optional[str] = Field(default=None)
    import_view_prefix_added: Optional[str] = Field(default=None)
    created_at: datetime = Field(default_factory=_now)

    business: Optional[Business] = Relationship(back_populates="versions")
    domains: list["Domain"] = Relationship(
        back_populates="version",
        sa_relationship_kwargs={"passive_deletes": "all"},
    )
    fk_links: list["ForeignKeyLink"] = Relationship(
        back_populates="version",
        sa_relationship_kwargs={"passive_deletes": "all"},
    )

class Run(SQLModel, table=True):
    __tablename__ = "runs"

    # Reject unknown kwargs (e.g. legacy `run_type=`/`rollback_plan=`) instead
    # of silently dropping them — Phase 5 retired those columns and we don't
    # want test-side or wire-side construction to silently coerce a field name
    # we no longer recognise. See docs/orchestrator-design.md §5.1.
    model_config = {"extra": "forbid"}

    id: str = Field(default_factory=_uuid, primary_key=True)
    business_id: str = Field(foreign_key="businesses.id", ondelete="CASCADE", index=True)
    version_id: Optional[str] = Field(default=None, foreign_key="model_versions.id", ondelete="SET NULL")
    # `intent` is the durable human-meaningful "what does the user want this
    # run to accomplish" label. Set once at create_run, never rewritten.
    # Replaces the legacy `run_type` column retired in Phase 5
    # (orchestrator-design.md §5.1).
    intent: str = Field(default="", index=True)
    # Status values: pending, running, completed, failed, cancelled, stale,
    # rolled_back_failed (set by /cancel-with-rollback when at least one
    # reverse-op failed — the run is no longer usable and needs manual
    # cleanup).
    status: str = Field(default="pending")
    databricks_run_id: Optional[int] = Field(default=None, sa_column=Column(BigInteger, nullable=True))
    vibe_session_id: Optional[str] = Field(default=None)
    vibe_session_id_bigint: Optional[int] = Field(default=None, sa_column=Column(BigInteger, nullable=True))
    # step_id is a millisecond epoch in the agent contract (13+ digit value),
    # which overflows INT32 — store as BIGINT so SQLModel writes succeed.
    last_consumed_step_id: int = Field(default=0, sa_column=Column(BigInteger, nullable=False, default=0))
    progress_percent: int = Field(default=0)
    progress_message: str = Field(default="")
    error_message: str = Field(default="")
    parameters_json: str = Field(default="{}")
    # Durable audit of the full user-submitted vibe instructions. The widget
    # value the notebook receives may be a Volume path (when the text is too
    # long for run_now's 2k param cap) — this column always keeps the text.
    vibe_instructions_text: str = Field(default="", sa_column=Column(Text, default=""))
    # Populated when the instructions were offloaded to a Volume file; empty
    # when they were small enough to be passed inline as the widget value.
    vibe_instructions_volume_path: str = Field(default="")
    # Durable audit of the business context the user typed at run-creation
    # time. The widget value sent to the agent notebook may be a truncated
    # summary (business_description) or a Volume-path reference
    # (business_context_path); this column keeps the original verbatim text
    # so the run-detail page can surface it accurately without parsing widget
    # payloads. Empty for runs that didn't carry inline text (e.g. revert,
    # import, install/uninstall), or for legacy runs created before this
    # column was added.
    business_context_text: str = Field(default="", sa_column=Column(Text, default=""))
    # D-09 watchdog signals — surfaced via RunOut so the UI can render WHY
    # the watchdog has marked a run stale/failed (or is still warming up).
    # `last_jobs_api_state` is the most recent `<life_cycle_state>/<result_state>`
    # pair seen by the tracker (e.g. "RUNNING/", "TERMINATED/SUCCESS"); empty
    # when no Jobs API call has been made yet on this run.
    # `last_poll_error` carries the `repr` of the most recent poll exception;
    # cleared back to "" on the next successful poll iteration.
    last_jobs_api_state: str = Field(default="", sa_column=Column(Text, default=""))
    last_poll_error: str = Field(default="", sa_column=Column(Text, default=""))
    started_at: Optional[datetime] = Field(default=None)
    completed_at: Optional[datetime] = Field(default=None)
    # Set when the run was recorded after the fact by linking an imported
    # version to the Databricks run that produced it (v_0_9_0_1).
    # ``link_evidence`` says how the match was verified. Both NULL for runs
    # the app launched.
    linked_at: Optional[datetime] = Field(default=None)
    link_evidence: Optional[str] = Field(default=None)
    created_at: datetime = Field(default_factory=_now)

    business: Optional[Business] = Relationship(back_populates="runs")
    artifacts: list["RunArtifact"] = Relationship(
        back_populates="run",
        sa_relationship_kwargs={"passive_deletes": "all"},
    )
    progress_events: list["RunProgressEvent"] = Relationship(
        back_populates="run",
        sa_relationship_kwargs={"passive_deletes": "all"},
    )

    def __init__(self, **data: Any) -> None:
        # A table model skips pydantic validation on construction, so the
        # ``extra="forbid"`` above alone would drop an unknown kwarg silently.
        cls = type(self)
        unknown = set(data) - set(cls.model_fields) - set(cls.__sqlmodel_relationships__)
        if unknown:
            raise TypeError(f"Run got unknown field(s): {', '.join(sorted(unknown))}")
        super().__init__(**data)


class RunArtifact(SQLModel, table=True):
    __tablename__ = "run_artifacts"

    id: str = Field(default_factory=_uuid, primary_key=True)
    # Nullable because imports — a synchronous Volume → Lakebase sync,
    # not a Databricks job run — produce artifacts without a parent Run.
    # The agent path still populates this with the producing Run.id.
    run_id: Optional[str] = Field(default=None, foreign_key="runs.id", ondelete="CASCADE", index=True)
    # The unified ECM+MVM pipeline yields two versions per run, so run_id
    # alone conflates their artifacts. This FK binds each artifact to the
    # ModelVersion that produced it so the UI can surface artifacts on the
    # model version page. Nullable for rows written before the FK existed.
    model_version_id: Optional[str] = Field(default=None, foreign_key="model_versions.id", ondelete="CASCADE", index=True)
    artifact_type: str = Field(default="")  # json, excel, dbml, ontology, etc.
    file_path: str = Field(default="")
    created_at: datetime = Field(default_factory=_now)

    run: Optional[Run] = Relationship(back_populates="artifacts")

class RunOperation(SQLModel, table=True):
    """One row per OperationStep in a Run's DAG (orchestrator refactor §5.2).

    The Orchestrator persists the DAG as a list of these rows on
    `start()`, advances them as the Databricks jobs progress, and walks
    them in reverse on cancel-with-rollback.

    Lifecycle: pending → running → succeeded | failed | skipped | rolled_back.
    """

    __tablename__ = "run_operations"
    __table_args__ = (
        # One op per step per run. Orchestrator inserts in advance() and
        # would silently dupe without this guard if start() is retried.
        UniqueConstraint("run_id", "step_index", name="uq_run_operations_run_step"),
    )

    id: str = Field(default_factory=_uuid, primary_key=True)
    run_id: str = Field(foreign_key="runs.id", ondelete="CASCADE", index=True)
    step_index: int = Field()
    operation_name: str = Field()
    params_json: str = Field(default="{}")
    skip_if: str = Field(default="")

    # Lifecycle: pending → running → succeeded | failed | skipped | rolled_back
    status: str = Field(default="pending")

    # Set when the op transitions to running.
    databricks_run_id: Optional[int] = Field(default=None, sa_column=Column(BigInteger, nullable=True))
    vibe_session_id: Optional[str] = Field(default=None)

    # parent_version_id at dispatch time; output_version_id on success
    # (only for produces_version=True ops).
    parent_version_id: Optional[str] = Field(default=None, foreign_key="model_versions.id", ondelete="SET NULL")
    output_version_id: Optional[str] = Field(default=None, foreign_key="model_versions.id", ondelete="CASCADE")

    # Opaque blob from OperationResult.rollback_state, used by rollback().
    # Overloaded (see `_runner.py`): also carries dispatch-time extras
    # (`handle.extra`) between poll ticks until terminal completion
    # overwrites it with the real rollback state.
    rollback_state_json: str = Field(default="{}")

    # The exact widget map dispatch() handed to `jobs.run_now()` (agent
    # wire field names, e.g. `data_model_scopes`), written once at
    # dispatch time from `OperationDispatchHandle.dispatched_widgets`
    # and never overwritten again. Deliberately NOT reused from
    # `params_json` (the DAG-plan-time params in this op's own schema,
    # re-validated on every dispatch tick and re-parsed by `observe()`;
    # overwriting it with the agent wire shape breaks both) or
    # `rollback_state_json` (already overloaded between dispatch-extras
    # and terminal-rollback-state; adding a third meaning there would
    # make it unreadable). This is the durable answer to "what did we
    # actually send the agent for this op" surfaced via
    # `RunOperationOut.dispatched_widgets` on `GET .../runs/{id}/operations`.
    dispatched_widgets_json: str = Field(default="{}")

    # Error message on failure; surfaced via the UI's "manual cleanup
    # required" banner when the run terminates in rolled_back_failed.
    error_message: str = Field(default="")

    started_at: Optional[datetime] = Field(default=None)
    completed_at: Optional[datetime] = Field(default=None)
    created_at: datetime = Field(default_factory=_now)

    run: Optional[Run] = Relationship()


class RunProgressEvent(SQLModel, table=True):
    __tablename__ = "run_progress_events"

    id: str = Field(default_factory=_uuid, primary_key=True)
    run_id: str = Field(foreign_key="runs.id", ondelete="CASCADE", index=True)
    # step_id is a millisecond epoch (13+ digit), event_seq can be large —
    # both need BIGINT to avoid integer-overflow writes from the agent.
    step_id: int = Field(default=0, sa_column=Column(BigInteger, nullable=False, default=0))
    event_seq: Optional[int] = Field(default=None, sa_column=Column(BigInteger, nullable=True))
    stage_name: str = Field(default="")
    step_name: str = Field(default="")
    status: str = Field(default="")
    message: str = Field(default="")
    progress_increment: float = Field(default=0.0)
    result_json: str = Field(default="{}", sa_column=Column(Text, default="{}"))
    created_at: datetime = Field(default_factory=_now)

    run: Optional[Run] = Relationship(back_populates="progress_events")

# --- Model structure tables (synced from model.json on run completion) ---

class Domain(SQLModel, table=True):
    __tablename__ = "domains"

    id: str = Field(default_factory=_uuid, primary_key=True)
    version_id: str = Field(foreign_key="model_versions.id", ondelete="CASCADE", index=True)
    name: str = Field(default="")
    division: str = Field(default="")
    description: str = Field(default="")
    database_name: str = Field(default="")
    references: str = Field(default="")
    # Self-FK to the same element in the prior model version (lineage chain).
    # Null on base versions and pre-existing rows; populated by model_sync.
    previous_element_id: Optional[str] = Field(default=None, foreign_key="domains.id", ondelete="SET NULL", index=True)
    created_at: datetime = Field(default_factory=_now)

    version: Optional[ModelVersion] = Relationship(back_populates="domains")
    products: list["Product"] = Relationship(back_populates="domain")

class Product(SQLModel, table=True):
    __tablename__ = "products"

    id: str = Field(default_factory=_uuid, primary_key=True)
    domain_id: str = Field(foreign_key="domains.id", ondelete="CASCADE", index=True)
    version_id: str = Field(foreign_key="model_versions.id", ondelete="CASCADE", index=True)
    name: str = Field(default="")
    table_name: str = Field(default="")
    description: str = Field(default="")
    type: str = Field(default="")
    data_type: str = Field(default="")
    primary_key: str = Field(default="")
    subdomain: str = Field(default="")
    subdomain_id: Optional[str] = Field(default=None, foreign_key="subdomains.id", ondelete="CASCADE", index=True)
    reference: str = Field(default="")
    previous_element_id: Optional[str] = Field(default=None, foreign_key="products.id", ondelete="SET NULL", index=True)
    created_at: datetime = Field(default_factory=_now)

    domain: Optional[Domain] = Relationship(back_populates="products")
    attributes: list["Attribute"] = Relationship(back_populates="product")

class Attribute(SQLModel, table=True):
    __tablename__ = "attributes"

    id: str = Field(default_factory=_uuid, primary_key=True)
    product_id: str = Field(foreign_key="products.id", ondelete="CASCADE", index=True)
    name: str = Field(default="")
    column_name: str = Field(default="")
    type: str = Field(default="")
    description: str = Field(default="")
    business_glossary_term: str = Field(default="")
    tags: str = Field(default="")
    value_regex: str = Field(default="")
    foreign_key_to: str = Field(default="")
    references: str = Field(default="")
    is_primary_key: bool = Field(default=False)
    is_foreign_key: bool = Field(default=False)
    previous_element_id: Optional[str] = Field(default=None, foreign_key="attributes.id", ondelete="SET NULL", index=True)
    created_at: datetime = Field(default_factory=_now)

    product: Optional[Product] = Relationship(back_populates="attributes")

class UserPreference(SQLModel, table=True):
    __tablename__ = "user_preferences"

    user_id: str = Field(primary_key=True)
    key: str = Field(primary_key=True)
    value: str = Field(default="")
    updated_at: datetime = Field(default_factory=_now)


class ForeignKeyLink(SQLModel, table=True):
    __tablename__ = "foreign_key_links"

    id: str = Field(default_factory=_uuid, primary_key=True)
    version_id: str = Field(foreign_key="model_versions.id", ondelete="CASCADE", index=True)
    source_domain: str = Field(default="")
    source_product: str = Field(default="")
    source_column: str = Field(default="")
    target_domain: str = Field(default="")
    target_product: str = Field(default="")
    target_column: str = Field(default="")
    previous_element_id: Optional[str] = Field(default=None, foreign_key="foreign_key_links.id", ondelete="SET NULL", index=True)
    created_at: datetime = Field(default_factory=_now)

    version: Optional[ModelVersion] = Relationship(back_populates="fk_links")


class RunNextVibeLink(SQLModel, table=True):
    __tablename__ = "run_next_vibe_links"

    id: str = Field(default_factory=_uuid, primary_key=True)
    run_id: str = Field(foreign_key="runs.id", ondelete="CASCADE", index=True)
    # `next_vibe_id` records which next-vibe a run was launched against, for
    # audit only. It holds the `VibeInput.id` uuid of the selected suggestion;
    # kept as a plain string (no FK) because the link is historical and must
    # survive the VibeInput row being superseded or deleted.
    next_vibe_id: str = Field(default="")
    created_at: datetime = Field(default_factory=_now)


# --- Vibe Inputs (durable input content + anchoring + lineage) ---

class VibeInput(SQLModel, table=True):
    """Umbrella durable-content row. User feedback is the ``origin=user``
    flavor; agent next-vibes are ``origin=agent_next_vibe``.

    ``origin``/``priority``/``status``/``category`` are string columns mirrored
    by the ``VibeInputOrigin``/``VibeInputPriority``/``VibeInputStatus``/
    ``NextVibeCategory`` enums on the Pydantic layer (the canonical pattern in
    this codebase: string column + ``str, Enum`` mirror). No DB-native enum type.
    """

    __tablename__ = "vibe_inputs"

    id: str = Field(default_factory=_uuid, primary_key=True)
    business_id: str = Field(foreign_key="businesses.id", ondelete="CASCADE", index=True)
    origin: str = Field(default="user", index=True)
    # Submitter email for origin=user; "" for agent inputs. Non-null -
    # source for attributed cards.
    author: str = Field(default="")
    text: str = Field(default="", sa_column=Column(Text, default=""))
    # Agent next-vibe classification (static_analysis / priority_remediation /
    # other), mirrored by ``NextVibeCategory``. Null for origin=user inputs —
    # feedback carries no category. The metrics layer counts agent inputs by
    # this column (the structured source the next_vibes ingestion will write).
    category: Optional[str] = Field(default=None, index=True)
    priority: str = Field(default="medium", index=True)
    # 0..1; agent next-vibes carry it, user inputs leave it null.
    confidence_score: Optional[float] = Field(default=None)
    consumed: bool = Field(default=False, index=True)
    # The run whose success consumed this input; NULL while open and when the
    # input is reopened. SET NULL keeps the input when that run is deleted.
    consumed_by_run_id: Optional[str] = Field(
        default=None, foreign_key="runs.id", ondelete="SET NULL", index=True,
    )
    # Persisted "include in the next run" flag, toggled on the compose surface.
    # Default False (explicit opt-in); reset to False when the input is consumed
    # by a successful run. The run dispatches exactly the selected, active,
    # anchored, non-consumed inputs.
    selected_for_run: bool = Field(default=False, index=True)
    status: str = Field(default="active", index=True)
    # Null = system/automatic deprecation; set = user email (manual soft-delete).
    deprecated_by: Optional[str] = Field(default=None)
    created_at: datetime = Field(default_factory=_now)
    updated_at: datetime = Field(default_factory=_now)

    context_links: list["VibeInputContextLink"] = Relationship(
        back_populates="input",
        sa_relationship_kwargs={"passive_deletes": "all"},
    )
    run_links: list["RunInputLink"] = Relationship(
        back_populates="input",
        sa_relationship_kwargs={"passive_deletes": "all"},
    )


class VibeInputContextLink(SQLModel, table=True):
    """Binds an input to a (version + element) anchor. All element FKs are
    nullable; an all-null link means "applies to the whole model version".
    """

    __tablename__ = "vibe_input_context_links"
    __table_args__ = (
        UniqueConstraint(
            "input_id",
            "version_id",
            name="uq_vibe_input_context_links_input_version",
        ),
    )

    id: str = Field(default_factory=_uuid, primary_key=True)
    input_id: str = Field(foreign_key="vibe_inputs.id", ondelete="CASCADE", index=True)
    version_id: str = Field(foreign_key="model_versions.id", ondelete="CASCADE", index=True)
    domain_id: Optional[str] = Field(default=None, foreign_key="domains.id")
    subdomain_id: Optional[str] = Field(default=None, foreign_key="subdomains.id")
    product_id: Optional[str] = Field(default=None, foreign_key="products.id")
    attribute_id: Optional[str] = Field(default=None, foreign_key="attributes.id")
    fk_link_id: Optional[str] = Field(default=None, foreign_key="foreign_key_links.id")
    # Immutable once true (origin anchor). Not DB-enforced in v1.
    is_origin: bool = Field(default=False)
    # Set by re-link tiers 3/4.
    needs_link_review: bool = Field(default=False)
    reviewed_by: Optional[str] = Field(default=None)
    reviewed_at: Optional[datetime] = Field(default=None)
    created_at: datetime = Field(default_factory=_now)

    input: Optional[VibeInput] = Relationship(back_populates="context_links")


class RunInputLink(SQLModel, table=True):
    """Run↔input usage audit: a link records an input a run sent, consumed or
    reopened. Composite PK ``(run_id, input_id)``.

    The ``outcome_*`` columns hold the agent's per-feedback outcome for that
    input (status from the agent vocabulary, e.g. ``applied`` / ``deferred``,
    plus its reason and target), written once when the run finishes. NULL =
    the agent reported no outcomes; ``not_reported`` = it reported outcomes
    but none for this input. Install runs record ``applied`` / ``reopened``.
    """

    __tablename__ = "run_input_links"

    run_id: str = Field(foreign_key="runs.id", ondelete="CASCADE", primary_key=True)
    input_id: str = Field(foreign_key="vibe_inputs.id", ondelete="CASCADE", primary_key=True)
    outcome_status: Optional[str] = Field(default=None)
    outcome_reason: Optional[str] = Field(default=None, sa_column=Column(Text, nullable=True))
    outcome_target: Optional[str] = Field(default=None)
    created_at: datetime = Field(default_factory=_now)

    input: Optional[VibeInput] = Relationship(back_populates="run_links")


class RunAgentReport(SQLModel, table=True):
    """What the agent's model.json said about one vibe run, one row per run.

    Written when the run finishes; read by the feedback consume step and the
    run report. The per-input outcomes live on ``run_input_links``. Versions
    are the agent's integer version numbers. ``lineage_*`` are NULL when the
    file carries no ``lineage`` block.
    """

    __tablename__ = "run_agent_reports"

    run_id: str = Field(foreign_key="runs.id", ondelete="CASCADE", primary_key=True)
    has_input_outcomes: bool = Field(default=False)
    outcomes_malformed: bool = Field(default=False)
    version_mismatch: bool = Field(default=False)
    expected_version: Optional[int] = Field(default=None)
    fetched_version: Optional[int] = Field(default=None)
    lineage_base_version: Optional[int] = Field(default=None)
    lineage_head_at_write: Optional[int] = Field(default=None)
    lineage_stale: Optional[bool] = Field(default=None)
    # Outcomes whose ``item_id`` matched no input the run sent.
    unmatched_outcome_count: int = Field(default=0)
    created_at: datetime = Field(default_factory=_now)


class RunPostInstallDelete(SQLModel, table=True):
    """A replaced version the user asked an install run to delete afterwards.

    Written ``pending`` in the install's terminal commit; each row is then
    deleted in its own transaction and set to ``deleted`` or ``failed``, or
    to ``not_run`` by the boot sweep when the version changed in between.
    Composite PK ``(run_id, version_id)``. ``version_id`` has no FK because
    the row must outlive the version it deleted; ``version`` and ``scope``
    keep it readable after that.
    """

    __tablename__ = "run_post_install_deletes"

    run_id: str = Field(foreign_key="runs.id", ondelete="CASCADE", primary_key=True)
    version_id: str = Field(primary_key=True)
    version: int = Field()
    scope: str = Field(default="")
    status: str = Field(default="pending")  # pending | deleted | failed | not_run
    reason: str = Field(default="", sa_column=Column(Text, default=""))
    created_at: datetime = Field(default_factory=_now)
    completed_at: Optional[datetime] = Field(default=None)


class ModelVersionInstall(SQLModel, table=True):
    """One catalog a version was installed into, open while it stays installed.

    ``uninstalled_at`` NULL = still installed there; at most one open row per
    ``(version_id, catalog)`` (partial unique index). ``ModelVersion.uc_catalog``
    and ``deployment_status`` duplicate the latest open row: about 30 readers
    use them, so they stay, and the drift checker asserts the two agree.
    """

    __tablename__ = "model_version_installs"
    __table_args__ = (
        Index(
            "uq_model_version_installs_open",
            "version_id",
            "catalog",
            unique=True,
            sqlite_where=sa_text("uninstalled_at IS NULL"),
            postgresql_where=sa_text("uninstalled_at IS NULL"),
        ),
    )

    id: str = Field(default_factory=_uuid, primary_key=True)
    version_id: str = Field(foreign_key="model_versions.id", ondelete="CASCADE", index=True)
    catalog: str = Field()
    installed_by_run_id: Optional[str] = Field(
        default=None, foreign_key="runs.id", ondelete="SET NULL", index=True,
    )
    installed_at: datetime = Field(default_factory=_now)
    uninstalled_at: Optional[datetime] = Field(default=None)
    uninstalled_by_run_id: Optional[str] = Field(
        default=None, foreign_key="runs.id", ondelete="SET NULL", index=True,
    )


class MetamodelCleanup(SQLModel, table=True):
    """A pending, done or failed removal of one deleted version's ``_metamodel``
    rows from one catalog.

    Written ``pending`` in the transaction that deletes the version (or the
    business), run after the commit, and retried by a bounded boot sweep. No
    FKs: the version and business are gone by design, so the row keeps the
    agent's key ``(business_segment, version, scope)`` and the catalog.
    """

    __tablename__ = "metamodel_cleanups"
    __table_args__ = (
        Index("ix_metamodel_cleanups_lookup", "business_segment", "scope", "catalog", "status"),
    )

    id: str = Field(default_factory=_uuid, primary_key=True)
    business_segment: str = Field()
    version: int = Field()
    scope: str = Field(default="")
    catalog: str = Field()
    reason: str = Field()  # version_delete | business_delete | post_install_delete | orphan_drop
    status: str = Field(default="pending")  # pending | done | failed
    attempts: int = Field(default=0)
    last_error: Optional[str] = Field(default=None, sa_column=Column(Text, nullable=True))
    created_at: datetime = Field(default_factory=_now)
    updated_at: datetime = Field(default_factory=_now)


class RunSchemaDrop(SQLModel, table=True):
    """One orphan schema an orphan-drop run dropped or tried to drop.
    Composite PK ``(run_id, catalog, schema_name)``."""

    __tablename__ = "run_schema_drops"

    run_id: str = Field(foreign_key="runs.id", ondelete="CASCADE", primary_key=True)
    catalog: str = Field(primary_key=True)
    schema_name: str = Field(primary_key=True)
    table_count: int = Field(default=0)
    status: str = Field(default="pending")  # pending | dropped | failed
    error: Optional[str] = Field(default=None, sa_column=Column(Text, nullable=True))
    created_at: datetime = Field(default_factory=_now)


class RunChangeDecision(SQLModel, table=True):
    """The modeler's accept or reject of one change a vibe run made.

    One row per ``(run_id, element_kind, element_path)``; changed in place
    until a newer run on the version starts. ``feedback_input_id`` is the
    feedback item made from a rejection, if the modeler asked for one.
    """

    __tablename__ = "run_change_decisions"
    __table_args__ = (
        UniqueConstraint("run_id", "element_kind", "element_path", name="uq_run_change_decisions_element"),
    )

    id: str = Field(default_factory=_uuid, primary_key=True)
    run_id: str = Field(foreign_key="runs.id", ondelete="CASCADE")
    version_id: str = Field(foreign_key="model_versions.id", ondelete="CASCADE", index=True)
    element_kind: str = Field()  # domain | product | attribute
    element_path: str = Field()
    change_kind: str = Field()  # added | modified | removed
    decision: str = Field()  # accepted | rejected
    decided_by: str = Field(default="")
    decided_at: datetime = Field(default_factory=_now)
    feedback_input_id: Optional[str] = Field(
        default=None, foreign_key="vibe_inputs.id", ondelete="SET NULL", index=True,
    )


class TaxonomyWizardState(SQLModel, table=True):
    """One user's saved Domain Taxonomy wizard, so a draft survives a reload.

    ``owner`` is the ``UserPreference.user_id`` key. The JSON columns are one
    transient wizard document in the shape of the taxonomy request models,
    read and written whole, never queried inside, and deleted once the
    business exists; a table rather than a ``UserPreference`` value because the
    row needs the sector FK, a ``revision`` for two-tab conflicts and an
    expiry query.
    """

    __tablename__ = "taxonomy_wizard_states"

    id: str = Field(default_factory=_uuid, primary_key=True)
    owner: str = Field(unique=True)
    step: int = Field(default=0)
    sector_id: Optional[str] = Field(default=None, foreign_key="sectors.id", ondelete="SET NULL", index=True)
    strictness: str = Field(default="strict")
    intake_json: str = Field(sa_column=Column(Text, nullable=False))
    tree_json: Optional[str] = Field(default=None, sa_column=Column(Text, nullable=True))
    sections_json: Optional[str] = Field(default=None, sa_column=Column(Text, nullable=True))
    revision: int = Field(default=0)
    created_at: datetime = Field(default_factory=_now)
    updated_at: datetime = Field(default_factory=_now)
    expires_at: datetime = Field(index=True)


class Subdomain(SQLModel, table=True):
    """Promoted optional subdomain element with version/domain FK + a
    prior-version pointer. A version may have zero subdomains.
    """

    __tablename__ = "subdomains"

    id: str = Field(default_factory=_uuid, primary_key=True)
    version_id: str = Field(foreign_key="model_versions.id", ondelete="CASCADE", index=True)
    domain_id: str = Field(foreign_key="domains.id", ondelete="CASCADE", index=True)
    name: str = Field(default="")
    previous_element_id: Optional[str] = Field(default=None, foreign_key="subdomains.id", ondelete="SET NULL", index=True)
    created_at: datetime = Field(default_factory=_now)


class ProductReview(SQLModel, table=True):
    """Sparse, product-canonical review marker (supersedes ``domain_reviews``).

    A row exists ONLY when a user has explicitly marked the product — absence
    means "use the computed default" (see ``backend/review.py``). ``state`` is
    one of {``reviewed``, ``not_reviewed``, ``no_review_needed``}, mirrored on
    the Pydantic layer by ``ReviewState`` (the string-column + ``str, Enum``
    mirror pattern). Marking a domain/subdomain/entity fans out to the product
    rows beneath it (cascade write). Resets per version — FKs straight to this
    version's product rows, no carry-forward.
    """

    __tablename__ = "product_reviews"
    __table_args__ = (
        UniqueConstraint(
            "version_id",
            "product_id",
            name="uq_product_reviews_version_product",
        ),
    )

    id: str = Field(default_factory=_uuid, primary_key=True)
    version_id: str = Field(foreign_key="model_versions.id", ondelete="CASCADE", index=True)
    product_id: str = Field(foreign_key="products.id", ondelete="CASCADE", index=True)
    state: str = Field(default="not_reviewed", index=True)
    reviewer: str = Field(default="")
    reviewed_at: datetime = Field(default_factory=_now)


class RunElementLineage(SQLModel, table=True):
    """Per-run element rename/merge/delete edges (the model-versioning work Task 4).

    The 1:1 rename/exact-match lineage lives on the element rows'
    ``previous_element_id`` self-FK; this table is the home for the facts a
    single self-FK cannot express:

    - **Merges (N:1):** several old ids collapse to one survivor → many rows
      sharing one ``new_element_id``.
    - **Deletes (1:0):** an old id with no survivor → ``new_element_id`` NULL
      (the version-W row doesn't exist, so there's nowhere to hang a self-FK).

    Rename rows are also written (``change_kind='rename'``) as cheap audit so
    Task 5 / the review queue can render "renamed from X" without walking the
    self-FK backwards; the self-FK remains the canonical 1:1 source.
    """

    __tablename__ = "run_element_lineage"

    id: str = Field(default_factory=_uuid, primary_key=True)
    run_id: str = Field(foreign_key="runs.id", ondelete="CASCADE", index=True)
    # The NEW version W produced by this run.
    version_id: str = Field(foreign_key="model_versions.id", ondelete="CASCADE", index=True)
    # 'domain'|'subdomain'|'product'|'attribute'|'fk_link'
    element_type: str = Field(default="", index=True)
    # 'rename'|'merge'|'delete' (exact-match is not recorded — it's the self-FK).
    change_kind: str = Field(default="", index=True)
    # Prior-version row id. NULL only when the old row id is unknown.
    old_element_id: Optional[str] = Field(default=None)
    # Version-W row id; NULL for deletes.
    new_element_id: Optional[str] = Field(default=None)
    # Human-readable audit ('domain.product' etc.).
    old_fqn: str = Field(default="")
    new_fqn: str = Field(default="")
    # Agent-supplied reason ('consolidation', 'duplicate_name_across_domains', ...).
    reason: str = Field(default="")
    created_at: datetime = Field(default_factory=_now)


class DiagramLayout(SQLModel, table=True):
    """Cached ELK layout output for a (business, version, cache_key) tuple.

    cache_key = SHA256 of (version_id, domain_filter, column_mode) per the
    in-memory cache format. layout_json is the serialized DiagramLayoutOut.
    """

    __tablename__ = "diagram_layouts"

    id: str = Field(default_factory=_uuid, primary_key=True)
    business_id: str = Field(foreign_key="businesses.id", ondelete="CASCADE", index=True)
    version_id: str = Field(foreign_key="model_versions.id", ondelete="CASCADE", index=True)
    cache_key: str = Field(index=True)
    layout_json: str = Field(default="{}", sa_column=Column(Text, default="{}"))
    created_at: datetime = Field(default_factory=_now)
    updated_at: datetime = Field(default_factory=_now)


# --- Headless assessment (optional, enabled at install time with --enable-assessment) ---

class AssessConfig(SQLModel, table=True):
    """Singleton row: reader SP + job wiring for headless assessments.

    ``job_id`` is the assessment job; ``job_reader`` is the reader it actually runs as;
    ``synced_version`` is the app version the last clean job sync ran for. ``reader_display_name``
    is the reader's SCIM display name as the last clean sync resolved it, stored so Settings can
    show it without a SCIM call per read. The Genie CLI and skills pins come from
    ``VERSIONS.json``, not this row.
    """
    __tablename__ = "assess_config"

    id: str = Field(default_factory=_uuid, primary_key=True)
    reader_application_id: str = Field(default="")
    reader_display_name: str = Field(default="")
    job_id: Optional[int] = Field(default=None, sa_column=Column(BigInteger, nullable=True))
    synced_version: str = Field(default="")
    job_reader: str = Field(default="")
    job_setup_error: str = Field(default="", sa_column=Column(Text, default=""))
    workspace_path: str = Field(default="")
    max_concurrent_runs: int = Field(default=2)
    default_reasoning_effort: str = Field(default="high")
    warehouse_id: str = Field(default="")
    updated_at: datetime = Field(default_factory=_now)
    updated_by: str = Field(default="")


class AssessSourceMap(SQLModel, table=True):
    """Saved logical-source → bronze schema map per business (one row per source)."""
    __tablename__ = "assess_source_map"
    __table_args__ = (UniqueConstraint("business_id", "source_name", name="uq_assess_source_map_business_source"),)

    id: str = Field(default_factory=_uuid, primary_key=True)
    business_id: str = Field(foreign_key="businesses.id", ondelete="CASCADE", index=True)
    source_name: str
    catalog_name: str
    schema_name: str
    updated_at: datetime = Field(default_factory=_now)


class AssessBatch(SQLModel, table=True):
    """One user launch covering one or more domains of one model version."""
    __tablename__ = "assess_batch"

    id: str = Field(default_factory=_uuid, primary_key=True)
    business_id: str = Field(foreign_key="businesses.id", ondelete="CASCADE", index=True)
    version_id: str = Field(foreign_key="model_versions.id", ondelete="CASCADE", index=True)
    output_model: str = Field(default="hybrid")
    etl_type: str = Field(default="sdp_pipeline")
    reasoning_effort: str = Field(default="high")
    created_by: str = Field(default="")
    created_at: datetime = Field(default_factory=_now)


class AssessDomainRun(SQLModel, table=True):
    """One domain inside a batch == one Databricks job run.

    ``metamodel_location`` is the resolved ``catalog.schema`` + prefix string the agent
    recorded; kept as text (not FK) because it names a UC object, not a Lakebase row.
    ``notebook_folder``, ``job_reader`` and ``job_id`` pin the workspace folder, reader SP and job
    the run was launched with (links are built from ``job_id``, so they survive a recreated job); ``ingest_attempts``/``ingest_next_at`` hold the ingest retry state;
    ``schema_version`` is the assessment schema version the run's output declared.
    """
    __tablename__ = "assess_domain_run"

    id: str = Field(default_factory=_uuid, primary_key=True)
    batch_id: str = Field(foreign_key="assess_batch.id", ondelete="CASCADE", index=True)
    domain_id: str = Field(foreign_key="domains.id", ondelete="CASCADE", index=True)
    databricks_run_id: Optional[int] = Field(default=None, sa_column=Column(BigInteger, nullable=True))
    job_id: Optional[int] = Field(default=None, sa_column=Column(BigInteger, nullable=True))
    status: str = Field(default="queued", index=True)
    stage: str = Field(default="")
    attempt: int = Field(default=0)
    resume_at: Optional[datetime] = Field(default=None)
    last_message: str = Field(default="", sa_column=Column(Text, default=""))
    error_message: str = Field(default="", sa_column=Column(Text, default=""))
    started_at: Optional[datetime] = Field(default=None)
    ended_at: Optional[datetime] = Field(default=None)
    skills_commit: str = Field(default="")
    skills_version: str = Field(default="")
    genie_version: str = Field(default="")
    out_dir: str = Field(default="")
    config_path: str = Field(default="")
    model_quality_score: Optional[float] = Field(default=None)
    metamodel_location: str = Field(default="")
    metamodel_version: str = Field(default="")
    results_valid: Optional[bool] = Field(default=None)
    notebook_folder: str = Field(default="")
    job_reader: str = Field(default="")
    ingest_attempts: int = Field(default=0)
    ingest_next_at: Optional[datetime] = Field(default=None)
    schema_version: Optional[int] = Field(default=None)
    created_at: datetime = Field(default_factory=_now)


class AssessDomainSource(SQLModel, table=True):
    """Snapshot of the bronze map a domain run used (history-stable)."""
    __tablename__ = "assess_domain_source"

    id: str = Field(default_factory=_uuid, primary_key=True)
    domain_run_id: str = Field(foreign_key="assess_domain_run.id", ondelete="CASCADE", index=True)
    source_name: str
    catalog_name: str
    schema_name: str


class AssessEntity(SQLModel, table=True):
    __tablename__ = "assess_entity"

    id: str = Field(default_factory=_uuid, primary_key=True)
    domain_run_id: str = Field(foreign_key="assess_domain_run.id", ondelete="CASCADE", index=True)
    product_id: Optional[str] = Field(default=None, foreign_key="products.id", ondelete="SET NULL", index=True)
    name: str
    grade: str  # full | partial | blocked
    coverage_pct: Optional[float] = Field(default=None)
    primary_source: str = Field(default="")
    row_count: Optional[int] = Field(default=None, sa_column=Column(BigInteger, nullable=True))
    net_new_candidate: bool = Field(default=False)
    # Tier counts behind the deterministic letter grade (core vs enrichment columns).
    core_sourced: Optional[int] = Field(default=None)
    core_total: Optional[int] = Field(default=None)
    enrichment_sourced: Optional[int] = Field(default=None)
    enrichment_total: Optional[int] = Field(default=None)
    deferred_fk_count: Optional[int] = Field(default=None)
    grade_reason: str = Field(default="", sa_column=Column(Text, default=""))
    row_filter: str = Field(default="", sa_column=Column(Text, default=""))
    reported_letter: str = Field(default="")  # letter the agent reported; app recomputes its own
    reported_structure: str = Field(default="")  # skill's self-reported structure; app recomputes at read time


class AssessColumnMapping(SQLModel, table=True):
    __tablename__ = "assess_column_mapping"

    id: str = Field(default_factory=_uuid, primary_key=True)
    entity_id: str = Field(foreign_key="assess_entity.id", ondelete="CASCADE", index=True)
    attribute_id: Optional[str] = Field(default=None, foreign_key="attributes.id", ondelete="SET NULL", index=True)
    target: str
    status: str  # mapped | derived | gap | null_source | deferred_fk
    source_table: str = Field(default="")
    source_column: str = Field(default="")
    transform: str = Field(default="", sa_column=Column(Text, default=""))
    row_count: Optional[int] = Field(default=None, sa_column=Column(BigInteger, nullable=True))
    null_pct: Optional[float] = Field(default=None)
    distinct_count: Optional[int] = Field(default=None, sa_column=Column(BigInteger, nullable=True))
    date_format: str = Field(default="")
    fk_orphans: Optional[int] = Field(default=None, sa_column=Column(BigInteger, nullable=True))
    evidence: str = Field(default="", sa_column=Column(Text, default=""))
    dup_source: bool = Field(default=False)
    tier: str = Field(default="")  # core | enrichment | ""


class AssessColumnSourceProfile(SQLModel, table=True):
    __tablename__ = "assess_column_source_profile"

    id: str = Field(default_factory=_uuid, primary_key=True)
    column_id: str = Field(foreign_key="assess_column_mapping.id", ondelete="CASCADE", index=True)
    ordinal: int
    system: str = Field(default="")
    source_table: str = Field(default="")
    source_column: str = Field(default="")
    role: str = Field(default="")
    row_count: Optional[int] = Field(default=None, sa_column=Column(BigInteger, nullable=True))
    null_pct: Optional[float] = Field(default=None)
    distinct_count: Optional[int] = Field(default=None, sa_column=Column(BigInteger, nullable=True))
    fk_orphans: Optional[int] = Field(default=None, sa_column=Column(BigInteger, nullable=True))
    note: str = Field(default="", sa_column=Column(Text, default=""))


class AssessGap(SQLModel, table=True):
    __tablename__ = "assess_gap"

    id: str = Field(default_factory=_uuid, primary_key=True)
    domain_run_id: str = Field(foreign_key="assess_domain_run.id", ondelete="CASCADE", index=True)
    entity: str = Field(default="")
    column: str = Field(default="")
    gap_type: str = Field(default="")
    description: str = Field(default="", sa_column=Column(Text, default=""))
    status: str = Field(default="OPEN")
    ask: str = Field(default="", sa_column=Column(Text, default=""))


class AssessPendingDecision(SQLModel, table=True):
    __tablename__ = "assess_pending_decision"

    id: str = Field(default_factory=_uuid, primary_key=True)
    domain_run_id: str = Field(foreign_key="assess_domain_run.id", ondelete="CASCADE", index=True)
    gate: str = Field(default="")
    kind: str = Field(default="")  # structure | source | scope as written by the skill; '' on old runs
    question: str = Field(sa_column=Column(Text, nullable=False))
    default_taken: str = Field(default="", sa_column=Column(Text, default=""))
    evidence: str = Field(default="", sa_column=Column(Text, default=""))
    entity: str = Field(default="")
    answer_status: str = Field(default="open")  # open | answered
    answer_option_id: Optional[str] = Field(
        default=None,
        sa_column=Column(
            String,
            ForeignKey("assess_decision_option.id", ondelete="SET NULL", use_alter=True,
                       name="fk_assess_decision_answer_option"),
            nullable=True,
        ),
    )
    answer_text: str = Field(default="", sa_column=Column(Text, default=""))
    answered_by: str = Field(default="")
    answered_at: Optional[datetime] = Field(default=None)
    context: str = Field(default="", sa_column=Column(Text, default=""))
    why_it_matters: str = Field(default="", sa_column=Column(Text, default=""))
    recommendation_rationale: str = Field(default="", sa_column=Column(Text, default=""))
    blocks_build: bool = Field(default=False)
    recommended_option_id: Optional[str] = Field(
        default=None,
        sa_column=Column(
            String,
            ForeignKey("assess_decision_option.id", ondelete="SET NULL", use_alter=True,
                       name="fk_assess_decision_recommended_option"),
            nullable=True,
        ),
    )
    ordinal: int = Field(default=0)  # position in the document, so decisions keep their D1, D2... order


class AssessDecisionOption(SQLModel, table=True):
    __tablename__ = "assess_decision_option"

    id: str = Field(default_factory=_uuid, primary_key=True)
    decision_id: str = Field(foreign_key="assess_pending_decision.id", ondelete="CASCADE", index=True)
    ordinal: int = Field(default=0)
    label: str = Field(sa_column=Column(Text, nullable=False))
    impact: str = Field(default="", sa_column=Column(Text, default=""))


class AssessNextVibe(SQLModel, table=True):
    """Assessment next-vibe recommendation; can be linked to a VibeInput (origin=user) created on user request."""
    __tablename__ = "assess_next_vibe"

    id: str = Field(default_factory=_uuid, primary_key=True)
    domain_run_id: str = Field(foreign_key="assess_domain_run.id", ondelete="CASCADE", index=True)
    vibe_input_id: Optional[str] = Field(default=None, foreign_key="vibe_inputs.id", ondelete="SET NULL", index=True)
    priority: Optional[int] = Field(default=None)
    category: str = Field(default="")
    text: str = Field(sa_column=Column(Text, nullable=False))
    confidence: Optional[float] = Field(default=None)
    problem: str = Field(default="", sa_column=Column(Text, default=""))
    proposed_change: str = Field(default="", sa_column=Column(Text, default=""))
    impact_if_skipped: str = Field(default="", sa_column=Column(Text, default=""))
    urgency: str = Field(default="")  # before_build | during_build | later | ""
    ordinal: int = Field(default=0)  # document order; tie-break after priority


class AssessSummary(SQLModel, table=True):
    """Agent-written executive summary of one domain run (1:1 with the run)."""
    __tablename__ = "assess_summary"

    domain_run_id: str = Field(foreign_key="assess_domain_run.id", ondelete="CASCADE", primary_key=True)
    headline: str = Field(default="", sa_column=Column(Text, default=""))
    verdict: str = Field(default="")
    verdict_reason: str = Field(default="", sa_column=Column(Text, default=""))
    recommended_next_step: str = Field(default="", sa_column=Column(Text, default=""))


class AssessSummaryItem(SQLModel, table=True):
    """One finding or risk bullet under an AssessSummary."""
    __tablename__ = "assess_summary_item"

    id: str = Field(default_factory=_uuid, primary_key=True)
    summary_id: str = Field(foreign_key="assess_summary.domain_run_id", ondelete="CASCADE", index=True)
    kind: str  # finding | risk
    ordinal: int = Field(default=0)
    text: str = Field(sa_column=Column(Text, nullable=False))


class AssessDecisionOptionPoint(SQLModel, table=True):
    """One pro or con bullet under a decision option."""
    __tablename__ = "assess_decision_option_point"

    id: str = Field(default_factory=_uuid, primary_key=True)
    option_id: str = Field(foreign_key="assess_decision_option.id", ondelete="CASCADE", index=True)
    kind: str  # pro | con
    ordinal: int = Field(default=0)
    text: str = Field(sa_column=Column(Text, nullable=False))


class AssessDecisionAffected(SQLModel, table=True):
    """An entity (and optionally column) a pending decision touches."""
    __tablename__ = "assess_decision_affected"

    id: str = Field(default_factory=_uuid, primary_key=True)
    decision_id: str = Field(foreign_key="assess_pending_decision.id", ondelete="CASCADE", index=True)
    ordinal: int = Field(default=0)
    entity: str = Field(default="")
    column: str = Field(default="")


class AssessNextVibeEntity(SQLModel, table=True):
    """An entity a next-vibe recommendation applies to."""
    __tablename__ = "assess_next_vibe_entity"

    id: str = Field(default_factory=_uuid, primary_key=True)
    next_vibe_id: str = Field(foreign_key="assess_next_vibe.id", ondelete="CASCADE", index=True)
    ordinal: int = Field(default=0)
    entity: str = Field(default="")


class AssessHandoff(SQLModel, table=True):
    __tablename__ = "assess_handoff"

    id: str = Field(default_factory=_uuid, primary_key=True)
    domain_run_id: str = Field(foreign_key="assess_domain_run.id", ondelete="CASCADE", index=True)
    path: str
    created_by: str = Field(default="")
    created_at: datetime = Field(default_factory=_now)


ASSESS_TABLES: tuple[type[SQLModel], ...] = (
    AssessConfig, AssessSourceMap, AssessBatch, AssessDomainRun, AssessDomainSource,
    AssessEntity, AssessColumnMapping, AssessColumnSourceProfile, AssessGap, AssessPendingDecision,
    AssessDecisionOption, AssessNextVibe, AssessHandoff,
    AssessSummary, AssessSummaryItem, AssessDecisionOptionPoint,
    AssessDecisionAffected, AssessNextVibeEntity,
)


class LakebaseSchemaVersion(SQLModel, table=True):
    """Singleton row tracking the installed schema version.

    The migration registry (``backend.migrations.reconcile_schema``)
    reads this table on boot to decide which migrations to apply. We
    keep it as a singleton (id=1) rather than an append-only audit
    log because the operator's question is always "what version is
    this DB on right now?" — not "what was the upgrade path?".

    Empty/missing row means a fresh install; reconcile then either
    applies every migration (permissive policy) or refuses (strict
    policy + non-empty schema).
    """

    __tablename__ = "_lakebase_schema_version"

    id: int = Field(default=1, primary_key=True)
    version: str = Field(default="")
    applied_at: datetime = Field(default_factory=_now)
