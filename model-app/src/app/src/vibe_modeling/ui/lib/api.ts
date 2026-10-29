import { useQuery, useSuspenseQuery, useMutation } from "@tanstack/react-query";
import type { UseQueryOptions, UseSuspenseQueryOptions, UseMutationOptions } from "@tanstack/react-query";
export class ApiError extends Error {
    status: number;
    statusText: string;
    body: unknown;
    constructor(status: number, statusText: string, body: unknown){
        super(`HTTP ${status}: ${statusText}`);
        this.name = "ApiError";
        this.status = status;
        this.statusText = statusText;
        this.body = body;
    }
}
export interface AgentCompatChange {
    area: string;
    severity: string;
    summary: string;
    tag: string;
}
export interface AgentCompatOut {
    agent_owner?: "app" | "admin" | null;
    bundled_agent_marker?: string | null;
    check_error?: string | null;
    checked_at?: string | null;
    has_breaking_change: boolean;
    install_offered?: boolean;
    installed_agent_version?: string | null;
    installed_check_error?: string | null;
    installed_checked_at?: string | null;
    installed_checked_path?: string | null;
    installed_release_version?: string | null;
    installed_vs_bundled?: "same" | "older" | "newer" | "unknown" | null;
    known_breaking_changes?: AgentCompatChange[];
    latest_known_upstream: string;
    latest_upstream_marker?: string | null;
    latest_upstream_release?: string | null;
    newer_available: boolean;
    pinned_agent_marker?: string;
    pinned_release?: string;
    pinned_version: string;
    repo_compare_url?: string;
    repo_url?: string;
    scope_supported?: boolean | null;
    update_app_required?: boolean;
    verdict?: string;
}
export interface AgentConfigIn {
    collect_vibe_run_statistics?: boolean | null;
    max_concurrent_runs?: number;
    notebook_path: string;
    runtime_budget_hours?: number | null;
}
export interface AgentConfigOut {
    collect_vibe_run_statistics?: boolean;
    created_at: string;
    deployment_catalog: string;
    id: string;
    job_id: number | null;
    job_name: string;
    job_url?: string;
    max_concurrent_runs?: number;
    metamodel_catalog?: string;
    notebook_path: string;
    runtime_budget_hours?: number;
    runtime_budget_max_hours?: number;
    runtime_budget_min_hours?: number;
    updated_at: string;
    warehouse_id: string;
}
export interface ArtifactPreview {
    artifact_type: string;
    path: string;
    size_bytes?: number | null;
}
export interface AssessBatchIn {
    domains: DomainSourcesIn[];
    etl_type?: "sdp_pipeline" | "notebook";
    output_model?: "normalized" | "dimensional" | "hybrid";
    reasoning_effort?: "low" | "medium" | "high";
    reuse_prior_tiers?: boolean;
    version_id: string;
}
export interface AssessBatchOut {
    business_id: string;
    created_at: string;
    created_by: string;
    domain_runs: AssessDomainRunOut[];
    etl_type: string;
    id: string;
    output_model: string;
    reasoning_effort: string;
    scope: string;
    status: string;
    version: number;
    version_id: string;
}
export interface AssessConfigIn {
    default_reasoning_effort?: "low" | "medium" | "high";
    max_concurrent_runs?: number;
    reader_application_id: string;
    warehouse_id?: string;
}
export interface AssessConfigOut {
    app_application_id?: string;
    default_reasoning_effort: string;
    genie_version: string;
    installed: boolean;
    job_id: number | null;
    job_url: string;
    max_concurrent_runs: number;
    missing: string[];
    reader_application_id: string;
    reader_display_name?: string;
    ready: boolean;
    skills_ref: string;
    skills_version: string;
    updated_at: string;
    updated_by: string;
    warehouse_id: string;
    workspace_path: string;
}
export interface AssessDomainRunOut {
    attempt: number;
    databricks_run_id: number | null;
    domain_id: string;
    domain_name: string;
    ended_at: string | null;
    error_message: string;
    genie_version: string;
    id: string;
    ingest_attempts?: number;
    ingest_max_attempts?: number;
    ingest_next_at?: string | null;
    job_reader?: string;
    job_url?: string;
    last_message: string;
    metamodel_location: string;
    metamodel_version: string;
    model_quality_score: number | null;
    results_valid: boolean | null;
    resume_at: string | null;
    run_url: string;
    runs_path?: string;
    schema_version?: number | null;
    skills_commit: string;
    skills_version: string;
    sources: SourceIn[];
    stage: string;
    started_at: string | null;
    status: string;
}
export interface AssessEntityOut {
    columns: ColumnMappingOut[];
    core_sourced: number | null;
    core_total: number | null;
    coverage_pct: number | null;
    deferred_fk: number;
    deferred_fk_count: number | null;
    domain_run_id: string;
    dup_source: number;
    enrichment_pct: number | null;
    enrichment_sourced: number | null;
    enrichment_total: number | null;
    gap: number;
    grade: string;
    grade_reason: string;
    id: string;
    in_model: boolean;
    letter_grade: string | null;
    mapped: number;
    name: string;
    net_new_candidate: boolean;
    primary_source: string;
    product_id: string | null;
    row_count: number | null;
    row_filter: string;
    structure: "sound" | "review" | "rework";
    structure_refs: string[];
}
export interface AssessRelaunchIn {
    domain_run_ids?: string[] | null;
}
export interface AssessResultsOut {
    domain_run: AssessDomainRunOut;
    entities: AssessEntityOut[];
    gaps: GapOut[];
    grades: Record<string, number>;
    letter_counts: Record<string, number>;
    next_vibes: NextVibeOut[];
    pending_decisions: PendingDecisionOut[];
    structure_counts: Record<string, number>;
    summary: SummaryOut | null;
}
export interface AttributeOut {
    business_glossary_term?: string;
    change_status?: ChangeStatus;
    column_name: string;
    description: string;
    foreign_key_to?: string;
    id?: string;
    is_foreign_key?: boolean;
    is_primary_key?: boolean;
    name: string;
    references?: string;
    tags?: string;
    type: string;
    value_regex?: string;
}
export interface BaselineOut {
    industry_id: string;
    model_id: string;
    scope?: string | null;
    version?: string | null;
}
export interface BulkAddNextVibesToFeedbackIn {
    ids?: string[] | null;
    urgency?: string | null;
}
export interface BulkNextVibeToFeedbackOut {
    count_created: number;
    count_reused: number;
    failures?: NextVibeFeedbackFailureOut[];
    items: NextVibeToFeedbackOut[];
}
export interface BusinessContextIn {
    context_json?: string;
    conventions_json?: string;
    is_active?: boolean;
    version_label?: string;
}
export interface BusinessContextOut {
    business_id: string;
    context_json: string;
    conventions_json: string;
    created_at: string;
    id: string;
    is_active: boolean;
    version_label: string;
}
export interface BusinessDeleteOut {
    cascaded: boolean;
    metamodel_cleanup?: MetamodelCleanupSummaryOut;
    ok: boolean;
}
export interface BusinessDigest {
    agent_version?: string;
    business_name?: string;
    business_vibes?: string;
    common_business_jargons?: string;
    core_business_processes?: string;
    data_domains?: string;
    description?: string;
    industry_alignment?: string;
    industry_governing_body?: string;
    industry_id?: string | null;
    operational_systems_of_records?: string;
    orgnaization_divisions?: string;
}
export interface BusinessDigestDiff {
    digest: BusinessDigest;
    mismatch_fields?: FieldMismatch[];
}
export interface BusinessIn {
    business_domains?: string;
    business_vibes?: string;
    description: string;
    industry_alignment?: string;
    kind?: BusinessKind;
    name: string;
    org_divisions?: string;
    sector_id?: string | null;
}
export const BusinessKind = {
    business: "business",
    industry: "industry"
} as const;
export type BusinessKind = typeof BusinessKind[keyof typeof BusinessKind];
export interface BusinessListOut {
    created_at: string;
    downloaded_scopes?: string[];
    id: string;
    industry_alignment: string;
    kind?: BusinessKind;
    model_count?: number;
    name: string;
    sector_id?: string | null;
    source_industry_id?: string | null;
    source_version?: number | null;
}
export interface BusinessOut {
    business_domains?: string;
    business_vibes?: string;
    created_at: string;
    description: string;
    id: string;
    industry_alignment: string;
    kind?: BusinessKind;
    name: string;
    org_divisions?: string;
    sector_id?: string | null;
    source_industry_id?: string | null;
    source_repo_path?: string | null;
    source_version?: number | null;
    updated_at: string;
}
export type CancelOpAppliedOut = {
    kind?: string;
    operation_name?: string;
} & Record<string, unknown>;
export interface CancelOpFailureOut {
    error?: string;
    op?: Record<string, unknown>;
}
export interface CancelWithRollbackOut {
    ok: boolean;
    op_failures?: CancelOpFailureOut[];
    ops_applied?: CancelOpAppliedOut[];
    status: string;
}
export interface CandidateOut {
    model_id: string;
    name: string;
    scope?: string | null;
    version?: string | null;
}
export interface CarryForwardResultOut {
    auto_linked?: number;
    deprecated?: number;
    link_ids_needing_review?: string[];
    needs_review?: number;
    skipped_existing?: number;
    version_id: string;
}
export interface CatalogCapabilityOut {
    create_schema?: boolean | null;
    create_schema_fix?: string;
    name: string;
    use_metamodel?: boolean | null;
    use_metamodel_fix?: string;
}
export interface CatalogOut {
    can_create_schema?: boolean | null;
    comment?: string;
    name: string;
    owner?: string;
}
export interface CatalogSchemaWarningOut {
    catalog: string;
    schema_count: number;
    schemas: string[];
}
export const ChangeStatus = {
    unchanged: "unchanged",
    new: "new",
    modified: "modified",
    deleted: "deleted"
} as const;
export type ChangeStatus = typeof ChangeStatus[keyof typeof ChangeStatus];
export interface Check {
    detail?: string;
    fix_action?: string;
    fix_sql?: string;
    key: string;
    label: string;
    state: "ok" | "blocked" | "unverified";
}
export interface ClientGatewayErrorIn {
    attempt: number;
    context?: string | null;
    path: string;
    status: number;
    will_retry?: boolean;
}
export interface ClientTelemetryAck {
    logged: boolean;
}
export interface ColumnMappingOut {
    attribute_id: string | null;
    date_format: string;
    distinct_count: number | null;
    dup_source: boolean;
    entity_id: string;
    evidence: string;
    fk_orphans: number | null;
    id: string;
    in_model: boolean;
    null_pct: number | null;
    profiles_by_source?: SourceProfileOut[];
    row_count: number | null;
    source_column: string;
    source_table: string;
    status: string;
    target: string;
    tier: string;
    transform: string;
}
export interface CompileIn {
    input_ids?: string[];
    vibe_scope_domains?: string[];
}
export interface CompileOut {
    agent_markdown?: string;
    blocks?: CompiledBlockOut[];
    excluded_input_ids?: string[];
    excluded_reasons?: Record<string, string>;
    included_input_ids?: string[];
    input_scope_domains?: Record<string, string | null>;
    markdown?: string;
}
export interface CompiledBlockOut {
    author: string;
    confidence_score: number | null;
    input_id: string;
    origin: VibeInputOrigin;
    priority: VibeInputPriority;
    section_path: string[];
    text: string;
}
export interface CurrentUserEmailOut {
    value: string;
}
export interface CurrentUserOut {
    display_name: string;
    emails: CurrentUserEmailOut[];
    user_name: string;
}
export interface DecisionAffectedOut {
    column: string;
    entity: string;
}
export interface DecisionAnswerIn {
    option_id?: string | null;
    text?: string;
}
export interface DecisionOptionOut {
    cons: string[];
    id: string;
    impact: string;
    label: string;
    ordinal: number;
    pros: string[];
    recommended: boolean;
}
export interface DeleteVersionOut {
    deleted_version: number;
    message: string;
    metamodel_cleanup?: MetamodelCleanupSummaryOut;
    metamodel_rows_cleaned?: boolean;
    previous_version?: number | null;
    reopened_input_count?: number;
}
export interface DeployedUcSchemaOut {
    columns?: Record<string, unknown>[];
    foreign_keys?: Record<string, unknown>[];
    primary_keys?: Record<string, unknown>[];
    tables?: Record<string, unknown>[];
    verification_error?: string | null;
}
export interface DeploymentCatalogCheckOut {
    catalog: string;
    error?: string | null;
    exists: boolean;
    verification_error?: string | null;
}
export interface DeploymentCatalogIn {
    deployment_catalog: string;
}
export const DeploymentStatus = {
    draft: "draft",
    deployed: "deployed",
    uninstalled: "uninstalled"
} as const;
export type DeploymentStatus = typeof DeploymentStatus[keyof typeof DeploymentStatus];
export interface DeploymentVerificationOut {
    summary: Record<string, number>;
    tables: Record<string, Record<string, unknown>[]>;
    verification_error?: string | null;
}
export interface DiagramDomainGroup {
    division?: string;
    domain: string;
    height?: number;
    id: string;
    is_external?: boolean;
    product_count?: number;
    width?: number;
    x?: number;
    y?: number;
}
export interface DiagramEdge {
    id: string;
    source_column: string;
    source_node: string;
    target_column: string;
    target_node: string;
    waypoints?: unknown[][];
}
export interface DiagramLayoutOut {
    domain_filter?: string | null;
    edges?: DiagramEdge[];
    groups?: DiagramDomainGroup[];
    nodes?: DiagramNode[];
    show_columns?: boolean;
    total_edges?: number;
    total_products?: number;
}
export interface DiagramNode {
    change_status?: ChangeStatus;
    column_count?: number;
    columns?: DiagramNodePort[];
    description?: string;
    domain: string;
    fk_count?: number;
    height?: number;
    id: string;
    product: string;
    product_type?: string;
    table_name: string;
    width?: number;
    x?: number;
    y?: number;
}
export interface DiagramNodePort {
    description?: string;
    fk_target?: string;
    id: string;
    is_fk?: boolean;
    is_pk?: boolean;
    name: string;
    type?: string;
}
export interface DiffOut {
    attributes?: DiffRowOut[];
    counts?: Record<string, number>;
    domains?: DiffRowOut[];
    products?: DiffRowOut[];
}
export interface DiffRowOut {
    attribute?: string | null;
    domain: string;
    product?: string | null;
    status: ChangeStatus;
}
export const DiscoveryMode = {
    eager_listing: "eager_listing",
    lazy: "lazy"
} as const;
export type DiscoveryMode = typeof DiscoveryMode[keyof typeof DiscoveryMode];
export interface DocContentOut {
    content: string;
    path: string;
    truncated: boolean;
}
export interface DocEntry {
    category: "design" | "commentary" | "other";
    name: string;
    path: string;
}
export interface DocsOut {
    docs: DocEntry[];
    folder_url: string;
}
export interface DomainConnectivityOut {
    fk_count: number;
    source_domain: string;
    target_domain: string;
}
export interface DomainDetailOut {
    database_name?: string;
    description?: string;
    division?: string;
    name: string;
    products?: ProductSummaryOut[];
    references?: string;
}
export interface DomainReadiness {
    blocked: boolean;
    checks: Check[];
    domain_id: string;
    domain_name: string;
}
export interface DomainReviewProgressOut {
    domain?: string;
    domain_id: string;
    no_review_needed?: number;
    review_needed?: number;
    review_pct?: number;
    reviewed?: number;
}
export interface DomainSourcesIn {
    domain_id: string;
    sources: SourceIn[];
}
export interface DomainSummaryOut {
    change_status?: ChangeStatus;
    database_name?: string;
    description?: string;
    division?: string;
    id?: string;
    name: string;
    product_count?: number;
    references?: string;
    subdomains?: SubdomainSummaryOut[];
}
export interface DownloadIndustryModelIn {
    industry_id: string;
    model_id: string;
    sector_id: string;
}
export interface DownloadIndustryModelOut {
    attribute_count: number;
    business_id: string;
    business_name: string;
    domains: number;
    fk_count: number;
    on_conflict_applied: string;
    products: number;
    run_id?: string | null;
    scope: string;
    version: number;
    version_id: string;
    warnings?: string[];
}
export interface DropOrphanSchemasIn {
    catalog: string;
    confirmed_issues?: string[];
    schemas: string[];
}
export interface DropOrphanSchemasOut {
    catalog: string;
    metamodel_cleanup?: MetamodelCleanupSummaryOut;
    run_id: string;
    schemas?: OrphanSchemaDropOut[];
}
export interface EvolutionChangeOut {
    confidence_delta?: number | null;
    errors_delta?: number | null;
    model_touched_pct?: number | null;
    previous_confidence?: number | null;
    previous_errors?: number | null;
    previous_unlinked?: number | null;
    previous_warnings?: number | null;
    products_added?: number | null;
    products_modified?: number | null;
    products_removed?: number | null;
    unlinked_delta?: number | null;
    version_history?: VersionHistoryEntryOut[];
    version_trend?: string | null;
    warnings_delta?: number | null;
}
export interface EvolutionEffortOut {
    duration_hours?: number | null;
    estimated_input_tokens?: number | null;
    estimated_output_tokens?: number | null;
    estimated_total_cost_usd?: number | null;
    per_model_cost_usd?: Record<string, number>;
    total_ai_calls?: number | null;
}
export interface EvolutionMetricsOut {
    change?: EvolutionChangeOut;
    effort?: EvolutionEffortOut;
    has_confidence?: boolean;
    has_metadata?: boolean;
    has_predecessor?: boolean;
    provenance?: EvolutionProvenanceOut;
    quality?: EvolutionQualityOut;
    size?: EvolutionSizeOut;
    version_id: string;
}
export interface EvolutionProvenanceOut {
    agent_version?: string | null;
    generated_from_version?: string | null;
    status?: string | null;
    target_model_version?: string | null;
}
export interface EvolutionQualityOut {
    confidence_score?: number | null;
    error_count?: number | null;
    info_count?: number | null;
    issues_addressed?: string[];
    issues_not_addressed?: string[];
    warning_count?: number | null;
}
export interface EvolutionSizeOut {
    attribute_count?: number | null;
    avg_attributes_per_product?: number | null;
    domain_count?: number | null;
    fk_count?: number | null;
    product_count?: number | null;
    siloed_count?: number | null;
    unlinked_id_count?: number | null;
}
export interface FeedbackContext {
    domain_filter?: string | null;
    selected_attribute?: string | null;
    selected_edge_id?: string | null;
    selected_node_id?: string | null;
}
export interface FieldMismatch {
    current_value: string;
    field: string;
    source_value: string;
}
export interface GapOut {
    ask: string;
    column: string;
    description: string;
    domain_run_id: string;
    entity: string;
    gap_type: string;
    id: string;
    status: string;
}
export interface GithubConfigIn {
    auth_mode?: string;
    connection_name?: string;
    repo_name?: string;
    repo_owner?: string;
    secret_key?: string;
    secret_scope?: string;
}
export interface GithubConfigOut {
    auth_mode: string;
    connection_name: string;
    repo_name: string;
    repo_owner: string;
    secret_key: string;
    secret_scope: string;
}
export interface HTTPValidationError {
    detail?: ValidationError[];
}
export interface HandoffIn {
    path?: string | null;
}
export interface HandoffOut {
    created_at: string | null;
    created_by: string;
    domain_run_id: string;
    expected_handoffs: string[];
    folder_url: string;
    next_steps: NextStepOut[];
    path: string | null;
    prompts: HandoffPrompt[];
    skills: SkillStatus[];
    skills_note?: string;
    user_scope_note: string;
}
export interface HandoffPrompt {
    key: "continue" | "build" | "validate" | "gold" | "build_gold" | "validate_gold" | "document";
    prompt: string;
    skill: string;
    title: string;
}
export interface HealthOut {
    in_flight_runs?: number;
    ok?: boolean;
}
export interface ImportAnalyzeIn {
    volume_path: string;
}
export interface ImportAnalyzeOut {
    action: string;
    agent_output?: boolean;
    attribute_count?: number;
    business_digest?: BusinessDigest | null;
    business_digest_diff?: BusinessDigestDiff | null;
    compat_verdict?: string;
    detected_agent_tag?: string;
    domain_count?: number;
    file_schema_prefix?: string | null;
    fk_count?: number;
    import_schema_prefix?: string | null;
    inferred_scope?: "ecm" | "mvm" | null;
    inferred_version: string;
    latest_supported_tag?: string;
    message: string;
    product_count?: number;
    scope_settled?: boolean;
    valid: boolean;
    warnings?: string[];
}
export interface ImportCreateBusinessAndExecuteIn {
    business_name_override?: string | null;
    business_vibes_override?: string | null;
    create_industry?: boolean;
    databricks_run_id?: number | null;
    description_override?: string | null;
    industry_alignment_override?: string | null;
    industry_id?: string | null;
    scope?: "ecm" | "mvm" | null;
    volume_path: string;
}
export interface ImportCreateBusinessAndExecuteOut {
    attributes: number;
    business_id: string;
    compat_verdict?: string;
    detected_agent_tag?: string;
    domains: number;
    fk_links: number;
    latest_supported_tag?: string;
    linked_run_id?: string | null;
    products: number;
    version: number;
    version_id: string;
    warnings?: string[];
}
export interface ImportExecuteIn {
    accept_business_mismatch?: boolean;
    databricks_run_id?: number | null;
    scope?: "ecm" | "mvm" | null;
    volume_path: string;
}
export interface ImportExecuteOut {
    attributes: number;
    compat_verdict?: string;
    detected_agent_tag?: string;
    domains: number;
    fk_links: number;
    latest_supported_tag?: string;
    linked_run_id?: string | null;
    products: number;
    version: number;
    version_id: string;
    warnings?: string[];
}
export interface ImportPreviewOut {
    companion_artifacts?: ArtifactPreview[];
    model_json_found: boolean;
    next_vibes_path?: string | null;
    next_vibes_status: string;
    total_artifact_count?: number;
}
export interface IndustryIn {
    description?: string;
    display_order?: number;
    is_active?: boolean;
    name: string;
    notable_businesses?: string;
    short_name: string;
}
export interface IndustryOut {
    created_at: string;
    description: string;
    display_order: number;
    id: string;
    is_active: boolean;
    is_auto_created: boolean;
    name: string;
    notable_businesses: string;
    short_name: string;
    updated_at: string;
}
export interface IndustryScopePrefixRowOut {
    action: "changed" | "unchanged" | "skipped" | "failed";
    reason: string;
    scope: string;
    version: number;
    version_id: string;
    warnings?: string[];
}
export interface IndustryScopePrefixesIn {
    apply?: boolean;
}
export interface IndustryScopePrefixesOut {
    applied: boolean;
    business_id: string;
    business_name: string;
    rows?: IndustryScopePrefixRowOut[];
}
export interface InstallSkillsIn {
    names?: string[];
    update?: string[];
}
export interface InstallSkillsOut {
    installed: string[];
    skills: SkillStatus[];
    skipped: string[];
    updated: string[];
}
export interface InstallationStatusOut {
    also_installed_in?: string[];
    catalog_present: boolean;
    checked_at: string;
    deployment_catalog: string;
    expected_schemas: string[];
    found_schemas: string[];
    in_sync: boolean | null;
    lakebase_says_installed: boolean;
    missing_schemas: string[];
    skipped_reason?: string | null;
    version_id: string;
}
export const Intent = {
    "new-base-model": "new-base-model",
    "vibe-iterate": "vibe-iterate",
    "vibe-new-ecm-mvm": "vibe-new-ecm-mvm",
    revert: "revert",
    "import-from-volume": "import-from-volume",
    install: "install",
    uninstall: "uninstall",
    "generate-samples": "generate-samples"
} as const;
export type Intent = typeof Intent[keyof typeof Intent];
export interface IssueOut {
    field_path: string;
    message: string;
    severity: "warning" | "blocker" | "confirm" | "prepare";
    step_index: number;
    subject?: string | null;
    versions?: number[];
}
export interface KickstartIn {
    copy_inputs?: boolean;
    new_description?: string;
    new_name: string;
    source_version: number;
    whole_model?: boolean;
}
export interface KickstartOut {
    business: BusinessOut;
}
export interface LinkRunIn {
    databricks_run_id: number;
}
export interface LinkRunPreviewOut {
    databricks_run_id: number;
    evidence?: string[];
    intent?: string | null;
    linkable: boolean;
    problems?: string[];
    tier?: number | null;
}
export const MaterializationTiming = {
    at_rest: "at_rest",
    on_demand: "on_demand"
} as const;
export type MaterializationTiming = typeof MaterializationTiming[keyof typeof MaterializationTiming];
export interface MetamodelCatalogIn {
    metamodel_catalog: string;
}
export interface MetamodelCleanupOut {
    attempts?: number;
    business_segment: string;
    catalog: string;
    id: string;
    last_error?: string | null;
    reason: string;
    scope: string;
    status: string;
    updated_at: string;
    version: number;
}
export interface MetamodelCleanupSummaryOut {
    done?: number;
    failed?: number;
    pending?: number;
}
export interface ModelArtifact {
    download_url?: string | null;
    name: string;
    path: string;
    size?: number | null;
    target_kind: TargetKind;
}
export interface ModelPreviewOut {
    artifacts: ModelArtifact[];
    attributes?: number | null;
    avg_attrs_per_product?: number | null;
    domains?: number | null;
    foreign_keys?: number | null;
    industry_id: string;
    metric_views?: number | null;
    model_id: string;
    model_name?: string | null;
    primary_keys?: number | null;
    products?: number | null;
    readme?: string | null;
    scope: string;
    subdomains?: number | null;
    version: string;
}
export interface ModelSearchHitOut {
    attribute_name?: string | null;
    domain_name: string;
    label: string;
    product_name?: string | null;
    sublabel?: string;
    type: string;
}
export const ModelStatus = {
    draft: "draft",
    generating: "generating",
    completed: "completed",
    failed: "failed",
    superseded: "superseded"
} as const;
export type ModelStatus = typeof ModelStatus[keyof typeof ModelStatus];
export interface ModelSummaryOut {
    attribute_count?: number;
    confidence_score?: number | null;
    core_business_processes?: string;
    description?: string;
    domain_count?: number;
    domains?: DomainSummaryOut[];
    fk_count?: number;
    industry_alignment?: string;
    name: string;
    no_review_needed_count?: number;
    product_count?: number;
    review_needed_count?: number;
    review_pct?: number;
    reviewed_count?: number;
    subdomain_count?: number;
    version: number;
    vibe_modeling_instructions?: string;
}
export interface ModelVersionOut {
    agent_version?: string | null;
    base_version_id: string | null;
    business_id: string;
    completion_date: string | null;
    confidence_score: number | null;
    context_id: string | null;
    created_at: string;
    deployment_status: DeploymentStatus;
    draft_state?: "ready" | "older_base" | null;
    dry_run?: boolean;
    files_catalog?: string | null;
    id: string;
    import_source_path?: string | null;
    imported_at?: string | null;
    is_head?: boolean | null;
    is_imported?: boolean | null;
    linked_run_id?: string | null;
    promoted_at?: string | null;
    promoted_by_run_id?: string | null;
    release_version?: string | null;
    replaced_at?: string | null;
    replaced_by_version_id?: string | null;
    scope?: string;
    scope_fence_mode?: string | null;
    status: ModelStatus;
    sync_error_text?: string | null;
    sync_state?: string;
    uc_catalog: string;
    version: number;
    vibe_instructions: string;
}
export interface NextStepOut {
    detail: string;
    done?: boolean;
    order: number;
    title: string;
}
export const NextVibeCategory = {
    static_analysis: "static_analysis",
    priority_remediation: "priority_remediation",
    other: "other"
} as const;
export type NextVibeCategory = typeof NextVibeCategory[keyof typeof NextVibeCategory];
export interface NextVibeCategoryCountsOut {
    other?: number;
    priority_remediation?: number;
    static_analysis?: number;
    total?: number;
}
export interface NextVibeFeedbackFailureOut {
    message: string;
    next_vibe_id: string;
}
export interface NextVibeItem {
    description?: string;
    id: string;
    priority?: VibeInputPriority;
    title: string;
}
export interface NextVibeMetricsOut {
    counts?: NextVibeCategoryCountsOut;
    domain_id?: string | null;
    has_data?: boolean;
    quality_score?: number | null;
    total_open?: number;
    version_id: string;
}
export interface NextVibeOut {
    affected_entities: string[];
    category: string;
    confidence: number | null;
    domain_run_id: string;
    feedback_input_id?: string | null;
    id: string;
    impact_if_skipped: string;
    priority: number | null;
    problem: string;
    proposed_change: string;
    text: string;
    urgency: string;
}
export interface NextVibeToFeedbackOut {
    created: boolean;
    feedback_input_id: string;
    next_vibe_id: string;
}
export interface NextVibesOut {
    confidence_score?: number | null;
    items?: NextVibeItem[];
    model_version_id: string;
    status?: string;
    summary?: string;
}
export interface OobBusinessOut {
    business_id?: string | null;
    business_segment: string;
    candidate_business_ids?: string[];
    status: "existing" | "new" | "ambiguous";
    versions?: OobVersionOut[];
}
export interface OobImportOut {
    created_business_ids?: string[];
    imported_versions?: number;
    warnings?: string[];
}
export interface OobSummaryOut {
    businesses?: OobBusinessOut[];
    catalog?: string;
    checked_at?: string | null;
    checking?: boolean;
    skipped_reason?: string | null;
}
export interface OobVersionOut {
    refused_reason?: string | null;
    scope: string;
    version: number;
}
export interface OrphanSchemaDropOut {
    error?: string | null;
    name: string;
    status: string;
    table_count?: number;
}
export interface OrphanSchemaOut {
    blocked_reason?: string | null;
    match?: "exact" | "inferred";
    name: string;
    owned_by_app?: boolean;
    owner?: string;
    table_count?: number | null;
}
export interface OrphanSchemasOut {
    catalog: string;
    confirm_subject?: string | null;
    impact?: UninstallImpactOut | null;
    schemas?: OrphanSchemaOut[];
}
export interface PendingDecisionOut {
    affected: DecisionAffectedOut[];
    answer_option_id: string | null;
    answer_status: string;
    answer_text: string;
    answered_at: string | null;
    answered_by: string;
    blocks_build: boolean;
    context: string;
    default_taken: string;
    domain_run_id: string;
    entity: string;
    evidence: string;
    gate: string;
    id: string;
    kind: "structure" | "source" | "scope";
    options: DecisionOptionOut[];
    ordinal: number;
    question: string;
    recommendation_rationale: string;
    why_it_matters: string;
}
export interface ProductDetailOut {
    attributes?: AttributeOut[];
    data_type?: string;
    description: string;
    domain_name?: string;
    fqn?: string;
    id?: string;
    name: string;
    primary_key?: string;
    reference?: string;
    table_name: string;
    type?: string;
}
export interface ProductReviewOut {
    fqn?: string;
    id?: string;
    is_explicit?: boolean;
    product_id: string;
    product_name?: string;
    reviewed_at?: string | null;
    reviewer?: string;
    state: ReviewState;
    version_id: string;
}
export interface ProductSummaryOut {
    attribute_count?: number;
    change_status?: ChangeStatus;
    data_type?: string;
    description: string;
    fk_count?: number;
    fk_targets?: string[];
    fqn?: string;
    id?: string;
    name: string;
    primary_key?: string;
    reference?: string;
    subdomain?: string;
    table_name: string;
    type?: string;
}
export interface ProgressEventOut {
    created_at: string;
    event_seq: number | null;
    id: string;
    message: string;
    progress_increment: number;
    result_json: string;
    run_id: string;
    stage_name: string;
    status: string;
    step_id: number;
    step_name: string;
}
export interface PublishModelVersionIn {
    target_path?: string | null;
}
export interface PublishModelVersionOut {
    branch: string;
    files: string[];
    pr_number: number;
    pr_url: string;
    target_path: string;
}
export interface PublishPreviewIn {
    baseline_model_id?: string | null;
    target_path?: string | null;
}
export interface PublishPreviewOut {
    baseline?: BaselineOut | null;
    candidates?: CandidateOut[];
    diff?: DiffOut | null;
    manual_needed?: boolean;
    scope_mismatch?: boolean;
    tier: string;
}
export interface ReadinessIn {
    domains: DomainSourcesIn[];
    version_id: string;
}
export interface ReadinessOut {
    domains: DomainReadiness[];
    global_checks: Check[];
}
export interface ReanchorIn {
    attribute_id?: string | null;
    domain_id?: string | null;
    fk_link_id?: string | null;
    product_id?: string | null;
    subdomain_id?: string | null;
}
export interface ReconcileInstallationOut {
    new_deployment_status: string;
    notes: string[];
    previous_deployment_status: string;
    schemas_missing: string[];
    schemas_present: string[];
    version_id: string;
}
export interface RelationshipAnalysisOut {
    cross_domain_fk_count?: number;
    domain_connectivity?: DomainConnectivityOut[];
    intra_domain_fk_count?: number;
    total_fk_count?: number;
}
export interface ResumeRunOut {
    databricks_run_id?: number | null;
    error?: string;
    next_phase?: string;
    ok: boolean;
    status: string;
}
export interface ReviewCascadeOut {
    affected?: number;
    products?: ProductReviewOut[];
    version_id: string;
}
export interface ReviewMarkIn {
    state?: ReviewState;
}
export interface ReviewProgressOut {
    no_review_needed?: number;
    review_needed?: number;
    review_pct?: number;
    reviewed?: number;
    total?: number;
    version_id: string;
}
export interface ReviewQueueItemOut {
    input: VibeInputOut;
    link: VibeInputContextLinkOut;
    proposed_anchor_label: string;
    tier: string;
}
export interface ReviewQueueOut {
    items?: ReviewQueueItemOut[];
    total?: number;
}
export const ReviewState = {
    reviewed: "reviewed",
    not_reviewed: "not_reviewed",
    no_review_needed: "no_review_needed"
} as const;
export type ReviewState = typeof ReviewState[keyof typeof ReviewState];
export interface RunArtifactOut {
    artifact_type: string;
    created_at: string;
    file_path: string;
    id: string;
    model_version_id?: string | null;
    run_id?: string | null;
}
export interface RunChangeDecisionIn {
    decision: "accepted" | "rejected";
    element_kind: "domain" | "product" | "attribute";
    element_path: string;
}
export interface RunChangeDecisionsIn {
    decisions: RunChangeDecisionIn[];
}
export interface RunChangeOut {
    change_class: "asked" | "outside_scope" | "not_asked" | "unclear";
    change_kind: "added" | "modified" | "removed";
    decided_at?: string | null;
    decided_by?: string | null;
    decision?: "accepted" | "rejected" | null;
    element_kind: "domain" | "product" | "attribute";
    element_path: string;
    feedback_input_id?: string | null;
}
export interface RunChangeReviewConfigOut {
    enabled: boolean;
}
export interface RunChangesOut {
    base_version_id?: string | null;
    changes?: RunChangeOut[];
    decisions_open?: boolean;
    run_id: string;
    version_id: string;
}
export interface RunDefaultFieldOut {
    locked?: boolean;
    locked_scoped?: boolean;
    source: "base_file" | "base_run" | "default" | "unknown";
    value?: string | null;
}
export interface RunDefaultsOut {
    base_version_id: string;
    fields: Record<string, RunDefaultFieldOut>;
    file_read: boolean;
}
export type RunIn = {
    also_delete_replaced?: boolean;
    boolean_format?: string | null;
    business_context_path?: string;
    business_context_text?: string;
    business_domains?: string | null;
    catalog?: string;
    catalog_prefix?: string | null;
    catalog_suffix?: string | null;
    cataloging_style?: string | null;
    classification_levels?: string | null;
    confirmed_issues?: string[];
    context_id?: string | null;
    date_format?: string | null;
    deployment_catalog?: string;
    dry_run?: boolean;
    ecm_schema_prefix?: string | null;
    generate_samples?: boolean;
    history_tracking_columns?: string | null;
    housekeeping_columns?: string | null;
    input_ids?: string[];
    intent?: Intent;
    model_size?: string;
    mvm_schema_prefix?: string | null;
    naming_convention?: string | null;
    next_vibe_ids?: string[];
    org_divisions?: string | null;
    parent_version_id?: string | null;
    primary_key_suffix?: string | null;
    runtime_budget_hours?: number | null;
    sample_count?: number | null;
    schema_prefix?: string | null;
    schema_suffix?: string | null;
    scope?: string | null;
    table_id_type?: string | null;
    tag_prefix?: string | null;
    tag_suffix?: string | null;
    timestamp_format?: string | null;
    version_id?: string | null;
    version_int?: number | null;
    vibe_instructions?: string;
    vibe_scope?: VibeScope;
    vibe_scope_domains?: string[];
} & {
};
export interface RunLineageOut {
    business_id: string;
    generated_version?: RunLineageVersionOut | null;
    intent: string;
    operates_on_version?: RunLineageVersionOut | null;
    run_id: string;
    source_version?: RunLineageVersionOut | null;
}
export interface RunLineageVersionOut {
    deployment_status: DeploymentStatus;
    id: string;
    scope?: string;
    status: ModelStatus;
    version: number;
}
export interface RunListOut {
    business_id: string;
    completed_at: string | null;
    created_at: string;
    id: string;
    intent?: string;
    progress_percent: number;
    started_at: string | null;
    status: RunStatus;
}
export interface RunOperationOut {
    completed_at?: string | null;
    created_at: string;
    databricks_run_id?: number | null;
    dispatched_widgets?: Record<string, unknown>;
    error_message?: string;
    id: string;
    operation_name: string;
    output_version_id?: string | null;
    output_version_label?: string | null;
    output_version_url?: string | null;
    parent_version_id?: string | null;
    run_id: string;
    run_page_url?: string | null;
    started_at?: string | null;
    status: string;
    step_index: number;
}
export interface RunOut {
    business_context_text?: string;
    business_id: string;
    completed_at: string | null;
    created_at: string;
    databricks_run_id: number | null;
    elapsed_seconds?: number;
    error_message: string;
    id: string;
    intent?: string;
    last_jobs_api_state?: string;
    last_poll_error?: string;
    link_evidence?: string | null;
    linked_at?: string | null;
    parameters_json: string;
    progress_message: string;
    progress_percent: number;
    run_page_url?: string | null;
    started_at: string | null;
    status: RunStatus;
    version_id: string | null;
    version_resolutions?: VersionResolutionOut[];
    vibe_instructions_text?: string;
    vibe_instructions_volume_path?: string;
    vibe_session_id?: string | null;
    warnings?: Record<string, unknown>[];
    watchdog_state?: WatchdogState;
    watchdog_warm_up_seconds_remaining?: number;
}
export interface RunReportItemOut {
    consumed: boolean;
    consumed_by_run_id?: string | null;
    created_at: string;
    input_id: string;
    origin: VibeInputOrigin;
    outcome_reason?: string | null;
    outcome_status?: string | null;
    outcome_target?: string | null;
    priority: VibeInputPriority;
    selected_for_run: boolean;
    status: VibeInputStatus;
    text: string;
}
export interface RunReportOut {
    business_id: string;
    consume_note?: "dry_run_pending_install" | "dry_run_installed" | "sync_failed" | "version_mismatch" | "malformed" | "no_outcomes_reported" | "pre_0_9_0" | "install_consumed" | null;
    dry_run: boolean;
    expected_version?: number | null;
    fetched_version?: number | null;
    has_agent_report: boolean;
    has_input_outcomes: boolean;
    intent: string;
    items?: RunReportItemOut[];
    lineage_base_version?: number | null;
    lineage_head_at_write?: number | null;
    lineage_stale?: boolean | null;
    output_version_id?: string | null;
    run_id: string;
    run_status: string;
    unmatched_outcome_count?: number;
    version_mismatch: boolean;
}
export const RunStatus = {
    pending: "pending",
    running: "running",
    completed: "completed",
    failed: "failed",
    cancelled: "cancelled",
    stale: "stale",
    rolled_back_failed: "rolled_back_failed"
} as const;
export type RunStatus = typeof RunStatus[keyof typeof RunStatus];
export interface SectorIn {
    description?: string;
    display_order?: number;
    is_active?: boolean;
    name: string;
    short_name: string;
}
export interface SectorOut {
    created_at: string;
    description: string;
    display_order: number;
    id: string;
    is_active: boolean;
    name: string;
    short_name: string;
    updated_at: string;
}
export interface SkillStatus {
    bundled_version?: string;
    installed_version?: string;
    location?: "user" | "workspace" | "none";
    name: string;
    state: "present" | "update_available" | "missing" | "unknown";
}
export interface SourceAuthConfigIn {
    auth_mode?: string;
    github_app_id?: string;
    github_app_installation_id?: string;
    github_app_secret_key?: string;
    github_app_secret_scope?: string;
    token_secret_key?: string;
    token_secret_scope?: string;
}
export interface SourceAuthConfigOut {
    auth_mode: string;
    effective_mode: string;
    error?: string | null;
    github_app_id: string;
    github_app_installation_id: string;
    github_app_secret_key: string;
    github_app_secret_scope: string;
    token_secret_key: string;
    token_secret_scope: string;
}
export interface SourceCapabilities {
    auth_error?: string | null;
    auth_mode?: "github_app" | "token" | "anonymous";
    discovery_mode: DiscoveryMode;
    materialization_timing: MaterializationTiming;
    provides_sectors: boolean;
    read_only?: boolean;
    source_kind: string;
    target_kinds: TargetKind[];
}
export interface SourceIn {
    catalog_name: string;
    schema_name: string;
    source_name: string;
}
export interface SourceIndustry {
    id: string;
    name: string;
    sector_id: string;
}
export interface SourceMapIn {
    sources: SourceIn[];
}
export interface SourceMapOut {
    sources: SourceIn[];
}
export interface SourceModelRef {
    id: string;
    industry_id: string;
    name: string;
    scope?: string | null;
    version?: string | null;
}
export interface SourceProfileOut {
    distinct_count: number | null;
    fk_orphans: number | null;
    note: string;
    null_pct: number | null;
    role: string;
    row_count: number | null;
    source_column: string;
    source_table: string;
    system: string;
}
export interface SourceSector {
    id: string;
    name: string;
    synthetic?: boolean;
}
export interface SubdomainSummaryOut {
    id?: string;
    name: string;
    product_count?: number;
}
export interface SummaryOut {
    headline: string;
    key_findings: string[];
    recommended_next_step: string;
    top_risks: string[];
    verdict: string | null;
    verdict_reason: string;
}
export const TargetKind = {
    model_json: "model_json",
    schemas: "schemas",
    diagram: "diagram",
    docs: "docs",
    metrics: "metrics",
    ontology: "ontology",
    vibes: "vibes"
} as const;
export type TargetKind = typeof TargetKind[keyof typeof TargetKind];
export interface TaxonomyCheckOut {
    checked_at: string;
    message: string;
    status: "ok" | "denied" | "not_found" | "busy" | "error";
}
export interface TaxonomyClaim {
    provenance: "user" | "industry" | "confirm";
    text: string;
}
export interface TaxonomyCompileIn {
    sections?: Record<string, TaxonomySection>;
    strictness?: "strict" | "guided";
    tree: TaxonomyTree;
}
export interface TaxonomyCompileOut {
    business_domains: string;
    business_vibes: string;
    clamp: string;
    csv: string;
    issues: TaxonomyIssue[];
}
export interface TaxonomyCondenseIn {
    intake: TaxonomyIntake;
    sections: Record<string, TaxonomySection>;
    tree: TaxonomyTree;
}
export interface TaxonomyConfigIn {
    max_concurrency?: number;
    model_service?: string;
}
export interface TaxonomyConfigOut {
    install_default_model_service: string;
    installed: boolean;
    last_check?: TaxonomyCheckOut | null;
    max_concurrency: number;
    model_service: string;
    ready: boolean;
    updated_at?: string | null;
    updated_by?: string | null;
}
export interface TaxonomyDomain {
    name: string;
    schema_name?: string;
    subdomains?: TaxonomySubdomain[];
}
export interface TaxonomyDraftCreateIn {
    company_name: string;
    industry: string;
    key_systems?: string;
    known_domains?: string;
    one_liner?: string;
    pasted_doc?: string;
    regulators?: string;
    seed_sections?: Record<string, TaxonomySection>;
    seed_tree?: TaxonomyTree | null;
}
export interface TaxonomyDraftCreated {
    draft_id: string;
}
export interface TaxonomyDraftOut {
    draft_id: string;
    parts: Record<string, TaxonomyDraftPartOut>;
    status: "running" | "done" | "failed" | "cancelled" | "timed_out" | "busy";
}
export interface TaxonomyDraftPartOut {
    description?: string | null;
    error?: string | null;
    section?: TaxonomySection | null;
    status: "pending" | "running" | "done" | "failed" | "cancelled" | "timed_out" | "busy";
    tree?: TaxonomyTree | null;
}
export interface TaxonomyExampleOut {
    company_name: string;
    description: string;
    industry: string;
    sections: Record<string, TaxonomySection>;
    tree: TaxonomyTree;
}
export interface TaxonomyIntake {
    company_name: string;
    industry: string;
    key_systems?: string;
    known_domains?: string;
    one_liner?: string;
    pasted_doc?: string;
    regulators?: string;
}
export interface TaxonomyIssue {
    domains?: number[];
    message: string;
    rule_id?: string;
    severity: "error" | "warning";
}
export interface TaxonomyModelServicesOut {
    message?: string | null;
    services: string[];
}
export interface TaxonomyRelationship {
    source: string;
    targets: string[];
}
export interface TaxonomySavedWizardOut {
    saved?: TaxonomyWizardStateOut | null;
}
export interface TaxonomySection {
    claims: TaxonomyClaim[];
}
export interface TaxonomySharedMaster {
    entity: string;
    home_domain: string;
}
export interface TaxonomySubdomain {
    categories?: string[];
    name: string;
}
export interface TaxonomyTree {
    coverage?: "Operations" | "Operations and Business" | "Operations, Business and Corporate";
    division_names?: string[];
    domains: TaxonomyDomain[];
    relationships?: TaxonomyRelationship[];
    shared_masters?: TaxonomySharedMaster[];
}
export interface TaxonomyWizardDiscardOut {
    discarded: boolean;
}
export interface TaxonomyWizardStateIn {
    intake: TaxonomyIntake;
    revision: number;
    sections?: Record<string, TaxonomySection>;
    sector_id?: string | null;
    step: number;
    strictness?: "strict" | "guided";
    tree?: TaxonomyTree | null;
}
export interface TaxonomyWizardStateOut {
    expires_at: string;
    intake: TaxonomyIntake;
    revision: number;
    sections: Record<string, TaxonomySection>;
    sector_id?: string | null;
    step: number;
    strictness: "strict" | "guided";
    tree?: TaxonomyTree | null;
    updated_at: string;
}
export interface UninstallImpactOut {
    catalog: string;
    has_data?: "yes" | "no" | "unknown";
    installed_catalogs?: string[];
    reasons?: string[];
    schemas?: UninstallImpactSchemaOut[];
    truncated?: boolean;
    version_id: string;
}
export interface UninstallImpactSchemaOut {
    name: string;
    objects_listed?: boolean;
    other_versions?: UninstallImpactVersionOut[];
    owner?: string;
    shared?: boolean;
    tables?: UninstallImpactTableOut[];
    views?: string[];
    volumes?: string[];
}
export interface UninstallImpactTableOut {
    has_data?: boolean | null;
    kind: string;
    name: string;
}
export interface UninstallImpactVersionOut {
    business_id: string;
    business_name: string;
    scope: string;
    version: number;
    version_id: string;
}
export interface UserPreferenceDeleteOut {
    deleted: boolean;
}
export interface UserPreferenceIn {
    value: string;
}
export interface UserPreferenceOut {
    key: string;
    updated_at: string;
    value: string;
}
export interface ValidateRunOut {
    blockers?: IssueOut[];
    warnings?: IssueOut[];
}
export interface ValidationError {
    ctx?: Record<string, unknown>;
    input?: unknown;
    loc: (string | number)[];
    msg: string;
    type: string;
}
export interface VersionHistoryEntryOut {
    confidence?: number | null;
    errors?: number | null;
    fks?: number | null;
    products?: number | null;
    trend?: string | null;
    unlinked?: number | null;
    version?: string;
    warnings?: number | null;
}
export interface VersionOut {
    version: string;
}
export interface VersionReportOut {
    report?: RunReportOut | null;
    version_id: string;
}
export interface VersionResolutionOut {
    new_target: number;
    original_target: number;
    target_scope: string;
}
export interface VersionTreeOut {
    base_version_id?: string | null;
    confidence_score?: number | null;
    created_at: string;
    deployment_status?: string;
    id: string;
    is_base?: boolean;
    parent_deleted?: boolean;
    scope?: string;
    status: string;
    version: number;
    vibe_instructions?: string;
}
export interface VibeInputAnchorOut {
    attribute_id?: string | null;
    attribute_name?: string | null;
    domain_id?: string | null;
    domain_name?: string | null;
    fk_edge_id?: string | null;
    fk_label?: string | null;
    fk_link_id?: string | null;
    level: string;
    path?: string[];
    product_id?: string | null;
    product_name?: string | null;
    subdomain_id?: string | null;
    subdomain_name?: string | null;
}
export interface VibeInputContextLinkIn {
    attribute_id?: string | null;
    domain_id?: string | null;
    fk_link_id?: string | null;
    input_id: string;
    is_origin?: boolean;
    product_id?: string | null;
    subdomain_id?: string | null;
    version_id: string;
}
export interface VibeInputContextLinkOut {
    attribute_id: string | null;
    created_at: string;
    domain_id: string | null;
    fk_link_id: string | null;
    id: string;
    input_id: string;
    is_origin: boolean;
    needs_link_review: boolean;
    product_id: string | null;
    reviewed_at: string | null;
    reviewed_by: string | null;
    subdomain_id: string | null;
    version_id: string;
}
export interface VibeInputIn {
    attribute_id?: string | null;
    author?: string;
    confidence_score?: number | null;
    domain_id?: string | null;
    fk_link_id?: string | null;
    origin?: VibeInputOrigin;
    origin_context?: FeedbackContext | null;
    priority?: VibeInputPriority;
    product_id?: string | null;
    subdomain_id?: string | null;
    text: string;
    version_id?: string | null;
}
export const VibeInputOrigin = {
    user: "user",
    agent_next_vibe: "agent_next_vibe",
    change_rejection: "change_rejection"
} as const;
export type VibeInputOrigin = typeof VibeInputOrigin[keyof typeof VibeInputOrigin];
export interface VibeInputOut {
    anchor?: VibeInputAnchorOut | null;
    author: string;
    business_id: string;
    category?: NextVibeCategory | null;
    confidence_score: number | null;
    consumed: boolean;
    consumed_by_run_id?: string | null;
    created_at: string;
    deprecated_by: string | null;
    id: string;
    origin: VibeInputOrigin;
    priority: VibeInputPriority;
    selected_for_run: boolean;
    status: VibeInputStatus;
    text: string;
    updated_at: string;
}
export interface VibeInputPatchIn {
    priority?: VibeInputPriority | null;
    text?: string | null;
}
export const VibeInputPriority = {
    high: "high",
    medium: "medium",
    low: "low"
} as const;
export type VibeInputPriority = typeof VibeInputPriority[keyof typeof VibeInputPriority];
export interface VibeInputSelectionIn {
    input_ids: string[];
    selected: boolean;
}
export const VibeInputStatus = {
    active: "active",
    deprecated: "deprecated"
} as const;
export type VibeInputStatus = typeof VibeInputStatus[keyof typeof VibeInputStatus];
export const VibeScope = {
    all_domains: "all_domains",
    some_domains: "some_domains",
    some_subdomains: "some_subdomains"
} as const;
export type VibeScope = typeof VibeScope[keyof typeof VibeScope];
export interface VolumeBrowseEntry {
    is_dir: boolean;
    kind: string;
    modified_at?: string | null;
    name: string;
    size_bytes?: number | null;
}
export interface VolumeBrowseOut {
    entries: VolumeBrowseEntry[];
    parent: string | null;
    path: string;
    truncated?: boolean;
}
export interface WarehouseOut {
    cluster_size?: string;
    id: string;
    name: string;
    state: string;
    warehouse_type?: string;
}
export const WatchdogState = {
    warming_up: "warming_up",
    armed: "armed",
    tripped_stale: "tripped_stale",
    tripped_failed: "tripped_failed",
    disarmed: "disarmed"
} as const;
export type WatchdogState = typeof WatchdogState[keyof typeof WatchdogState];
export interface SwitchToBundledAgentParams {
    "X-Forwarded-Host"?: string | null;
    "X-Forwarded-Preferred-Username"?: string | null;
    "X-Forwarded-User"?: string | null;
    "X-Forwarded-Email"?: string | null;
    "X-Request-Id"?: string | null;
    "X-Forwarded-Access-Token"?: string | null;
}
export const switchToBundledAgent = async (params?: SwitchToBundledAgentParams, options?: RequestInit): Promise<{
    data: AgentConfigOut;
}> =>{
    const res = await fetch("/api/admin/agent/switch-to-bundled", {
        ...options,
        method: "POST",
        headers: {
            ...(params?.["X-Forwarded-Host"] != null && {
                "X-Forwarded-Host": params["X-Forwarded-Host"]
            }),
            ...(params?.["X-Forwarded-Preferred-Username"] != null && {
                "X-Forwarded-Preferred-Username": params["X-Forwarded-Preferred-Username"]
            }),
            ...(params?.["X-Forwarded-User"] != null && {
                "X-Forwarded-User": params["X-Forwarded-User"]
            }),
            ...(params?.["X-Forwarded-Email"] != null && {
                "X-Forwarded-Email": params["X-Forwarded-Email"]
            }),
            ...(params?.["X-Request-Id"] != null && {
                "X-Request-Id": params["X-Request-Id"]
            }),
            ...(params?.["X-Forwarded-Access-Token"] != null && {
                "X-Forwarded-Access-Token": params["X-Forwarded-Access-Token"]
            }),
            ...options?.headers
        }
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export function useSwitchToBundledAgent(options?: {
    mutation?: UseMutationOptions<{
        data: AgentConfigOut;
    }, ApiError, {
        params: SwitchToBundledAgentParams;
    }>;
}) {
    return useMutation({
        mutationFn: (vars)=>switchToBundledAgent(vars.params),
        ...options?.mutation
    });
}
export const getAssessConfig = async (options?: RequestInit): Promise<{
    data: AssessConfigOut;
}> =>{
    const res = await fetch("/api/assess/config", {
        ...options,
        method: "GET"
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export const getAssessConfigKey = ()=>{
    return [
        "/api/assess/config"
    ] as const;
};
export function useGetAssessConfig<TData = {
    data: AssessConfigOut;
}>(options?: {
    query?: Omit<UseQueryOptions<{
        data: AssessConfigOut;
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useQuery({
        queryKey: getAssessConfigKey(),
        queryFn: ()=>getAssessConfig(),
        ...options?.query
    });
}
export function useGetAssessConfigSuspense<TData = {
    data: AssessConfigOut;
}>(options?: {
    query?: Omit<UseSuspenseQueryOptions<{
        data: AssessConfigOut;
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useSuspenseQuery({
        queryKey: getAssessConfigKey(),
        queryFn: ()=>getAssessConfig(),
        ...options?.query
    });
}
export interface PutAssessConfigParams {
    "X-Forwarded-Host"?: string | null;
    "X-Forwarded-Preferred-Username"?: string | null;
    "X-Forwarded-User"?: string | null;
    "X-Forwarded-Email"?: string | null;
    "X-Request-Id"?: string | null;
    "X-Forwarded-Access-Token"?: string | null;
}
export const putAssessConfig = async (data: AssessConfigIn, params?: PutAssessConfigParams, options?: RequestInit): Promise<{
    data: AssessConfigOut;
}> =>{
    const res = await fetch("/api/assess/config", {
        ...options,
        method: "PUT",
        headers: {
            "Content-Type": "application/json",
            ...(params?.["X-Forwarded-Host"] != null && {
                "X-Forwarded-Host": params["X-Forwarded-Host"]
            }),
            ...(params?.["X-Forwarded-Preferred-Username"] != null && {
                "X-Forwarded-Preferred-Username": params["X-Forwarded-Preferred-Username"]
            }),
            ...(params?.["X-Forwarded-User"] != null && {
                "X-Forwarded-User": params["X-Forwarded-User"]
            }),
            ...(params?.["X-Forwarded-Email"] != null && {
                "X-Forwarded-Email": params["X-Forwarded-Email"]
            }),
            ...(params?.["X-Request-Id"] != null && {
                "X-Request-Id": params["X-Request-Id"]
            }),
            ...(params?.["X-Forwarded-Access-Token"] != null && {
                "X-Forwarded-Access-Token": params["X-Forwarded-Access-Token"]
            }),
            ...options?.headers
        },
        body: JSON.stringify(data)
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export function usePutAssessConfig(options?: {
    mutation?: UseMutationOptions<{
        data: AssessConfigOut;
    }, ApiError, {
        params: PutAssessConfigParams;
        data: AssessConfigIn;
    }>;
}) {
    return useMutation({
        mutationFn: (vars)=>putAssessConfig(vars.data, vars.params),
        ...options?.mutation
    });
}
export const checkAssessReadiness = async (data: ReadinessIn, options?: RequestInit): Promise<{
    data: ReadinessOut;
}> =>{
    const res = await fetch("/api/assess/readiness", {
        ...options,
        method: "POST",
        headers: {
            "Content-Type": "application/json",
            ...options?.headers
        },
        body: JSON.stringify(data)
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export function useCheckAssessReadiness(options?: {
    mutation?: UseMutationOptions<{
        data: ReadinessOut;
    }, ApiError, ReadinessIn>;
}) {
    return useMutation({
        mutationFn: (data)=>checkAssessReadiness(data),
        ...options?.mutation
    });
}
export interface AnswerAssessmentDecisionParams {
    decision_id: string;
    "X-Forwarded-Host"?: string | null;
    "X-Forwarded-Preferred-Username"?: string | null;
    "X-Forwarded-User"?: string | null;
    "X-Forwarded-Email"?: string | null;
    "X-Request-Id"?: string | null;
    "X-Forwarded-Access-Token"?: string | null;
}
export const answerAssessmentDecision = async (params: AnswerAssessmentDecisionParams, data: DecisionAnswerIn, options?: RequestInit): Promise<{
    data: PendingDecisionOut;
}> =>{
    const res = await fetch(`/api/assessment-decisions/${params.decision_id}/answer`, {
        ...options,
        method: "PUT",
        headers: {
            "Content-Type": "application/json",
            ...(params?.["X-Forwarded-Host"] != null && {
                "X-Forwarded-Host": params["X-Forwarded-Host"]
            }),
            ...(params?.["X-Forwarded-Preferred-Username"] != null && {
                "X-Forwarded-Preferred-Username": params["X-Forwarded-Preferred-Username"]
            }),
            ...(params?.["X-Forwarded-User"] != null && {
                "X-Forwarded-User": params["X-Forwarded-User"]
            }),
            ...(params?.["X-Forwarded-Email"] != null && {
                "X-Forwarded-Email": params["X-Forwarded-Email"]
            }),
            ...(params?.["X-Request-Id"] != null && {
                "X-Request-Id": params["X-Request-Id"]
            }),
            ...(params?.["X-Forwarded-Access-Token"] != null && {
                "X-Forwarded-Access-Token": params["X-Forwarded-Access-Token"]
            }),
            ...options?.headers
        },
        body: JSON.stringify(data)
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export function useAnswerAssessmentDecision(options?: {
    mutation?: UseMutationOptions<{
        data: PendingDecisionOut;
    }, ApiError, {
        params: AnswerAssessmentDecisionParams;
        data: DecisionAnswerIn;
    }>;
}) {
    return useMutation({
        mutationFn: (vars)=>answerAssessmentDecision(vars.params, vars.data),
        ...options?.mutation
    });
}
export interface ClearAssessmentDecisionAnswerParams {
    decision_id: string;
    "X-Forwarded-Host"?: string | null;
    "X-Forwarded-Preferred-Username"?: string | null;
    "X-Forwarded-User"?: string | null;
    "X-Forwarded-Email"?: string | null;
    "X-Request-Id"?: string | null;
    "X-Forwarded-Access-Token"?: string | null;
}
export const clearAssessmentDecisionAnswer = async (params: ClearAssessmentDecisionAnswerParams, options?: RequestInit): Promise<{
    data: PendingDecisionOut;
}> =>{
    const res = await fetch(`/api/assessment-decisions/${params.decision_id}/answer`, {
        ...options,
        method: "DELETE",
        headers: {
            ...(params?.["X-Forwarded-Host"] != null && {
                "X-Forwarded-Host": params["X-Forwarded-Host"]
            }),
            ...(params?.["X-Forwarded-Preferred-Username"] != null && {
                "X-Forwarded-Preferred-Username": params["X-Forwarded-Preferred-Username"]
            }),
            ...(params?.["X-Forwarded-User"] != null && {
                "X-Forwarded-User": params["X-Forwarded-User"]
            }),
            ...(params?.["X-Forwarded-Email"] != null && {
                "X-Forwarded-Email": params["X-Forwarded-Email"]
            }),
            ...(params?.["X-Request-Id"] != null && {
                "X-Request-Id": params["X-Request-Id"]
            }),
            ...(params?.["X-Forwarded-Access-Token"] != null && {
                "X-Forwarded-Access-Token": params["X-Forwarded-Access-Token"]
            }),
            ...options?.headers
        }
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export function useClearAssessmentDecisionAnswer(options?: {
    mutation?: UseMutationOptions<{
        data: PendingDecisionOut;
    }, ApiError, {
        params: ClearAssessmentDecisionAnswerParams;
    }>;
}) {
    return useMutation({
        mutationFn: (vars)=>clearAssessmentDecisionAnswer(vars.params),
        ...options?.mutation
    });
}
export interface CancelAssessmentDomainRunParams {
    domain_run_id: string;
    "X-Forwarded-Host"?: string | null;
    "X-Forwarded-Preferred-Username"?: string | null;
    "X-Forwarded-User"?: string | null;
    "X-Forwarded-Email"?: string | null;
    "X-Request-Id"?: string | null;
    "X-Forwarded-Access-Token"?: string | null;
}
export const cancelAssessmentDomainRun = async (params: CancelAssessmentDomainRunParams, options?: RequestInit): Promise<{
    data: AssessDomainRunOut;
}> =>{
    const res = await fetch(`/api/assessment-domain-runs/${params.domain_run_id}/cancel`, {
        ...options,
        method: "POST",
        headers: {
            ...(params?.["X-Forwarded-Host"] != null && {
                "X-Forwarded-Host": params["X-Forwarded-Host"]
            }),
            ...(params?.["X-Forwarded-Preferred-Username"] != null && {
                "X-Forwarded-Preferred-Username": params["X-Forwarded-Preferred-Username"]
            }),
            ...(params?.["X-Forwarded-User"] != null && {
                "X-Forwarded-User": params["X-Forwarded-User"]
            }),
            ...(params?.["X-Forwarded-Email"] != null && {
                "X-Forwarded-Email": params["X-Forwarded-Email"]
            }),
            ...(params?.["X-Request-Id"] != null && {
                "X-Request-Id": params["X-Request-Id"]
            }),
            ...(params?.["X-Forwarded-Access-Token"] != null && {
                "X-Forwarded-Access-Token": params["X-Forwarded-Access-Token"]
            }),
            ...options?.headers
        }
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export function useCancelAssessmentDomainRun(options?: {
    mutation?: UseMutationOptions<{
        data: AssessDomainRunOut;
    }, ApiError, {
        params: CancelAssessmentDomainRunParams;
    }>;
}) {
    return useMutation({
        mutationFn: (vars)=>cancelAssessmentDomainRun(vars.params),
        ...options?.mutation
    });
}
export interface ListAssessmentDocsParams {
    domain_run_id: string;
}
export const listAssessmentDocs = async (params: ListAssessmentDocsParams, options?: RequestInit): Promise<{
    data: DocsOut;
}> =>{
    const res = await fetch(`/api/assessment-domain-runs/${params.domain_run_id}/docs`, {
        ...options,
        method: "GET"
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export const listAssessmentDocsKey = (params?: ListAssessmentDocsParams)=>{
    return [
        "/api/assessment-domain-runs/{domain_run_id}/docs",
        params
    ] as const;
};
export function useListAssessmentDocs<TData = {
    data: DocsOut;
}>(options: {
    params: ListAssessmentDocsParams;
    query?: Omit<UseQueryOptions<{
        data: DocsOut;
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useQuery({
        queryKey: listAssessmentDocsKey(options.params),
        queryFn: ()=>listAssessmentDocs(options.params),
        ...options?.query
    });
}
export function useListAssessmentDocsSuspense<TData = {
    data: DocsOut;
}>(options: {
    params: ListAssessmentDocsParams;
    query?: Omit<UseSuspenseQueryOptions<{
        data: DocsOut;
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useSuspenseQuery({
        queryKey: listAssessmentDocsKey(options.params),
        queryFn: ()=>listAssessmentDocs(options.params),
        ...options?.query
    });
}
export interface GetAssessmentDocContentParams {
    domain_run_id: string;
    path: string;
}
export const getAssessmentDocContent = async (params: GetAssessmentDocContentParams, options?: RequestInit): Promise<{
    data: DocContentOut;
}> =>{
    const searchParams = new URLSearchParams();
    if (params.path != null) searchParams.set("path", String(params.path));
    const queryString = searchParams.toString();
    const url = queryString ? `/api/assessment-domain-runs/${params.domain_run_id}/docs/content?${queryString}` : `/api/assessment-domain-runs/${params.domain_run_id}/docs/content`;
    const res = await fetch(url, {
        ...options,
        method: "GET"
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export const getAssessmentDocContentKey = (params?: GetAssessmentDocContentParams)=>{
    return [
        "/api/assessment-domain-runs/{domain_run_id}/docs/content",
        params
    ] as const;
};
export function useGetAssessmentDocContent<TData = {
    data: DocContentOut;
}>(options: {
    params: GetAssessmentDocContentParams;
    query?: Omit<UseQueryOptions<{
        data: DocContentOut;
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useQuery({
        queryKey: getAssessmentDocContentKey(options.params),
        queryFn: ()=>getAssessmentDocContent(options.params),
        ...options?.query
    });
}
export function useGetAssessmentDocContentSuspense<TData = {
    data: DocContentOut;
}>(options: {
    params: GetAssessmentDocContentParams;
    query?: Omit<UseSuspenseQueryOptions<{
        data: DocContentOut;
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useSuspenseQuery({
        queryKey: getAssessmentDocContentKey(options.params),
        queryFn: ()=>getAssessmentDocContent(options.params),
        ...options?.query
    });
}
export interface GetAssessmentHandoffParams {
    domain_run_id: string;
    "X-Forwarded-Host"?: string | null;
    "X-Forwarded-Preferred-Username"?: string | null;
    "X-Forwarded-User"?: string | null;
    "X-Forwarded-Email"?: string | null;
    "X-Request-Id"?: string | null;
    "X-Forwarded-Access-Token"?: string | null;
}
export const getAssessmentHandoff = async (params: GetAssessmentHandoffParams, options?: RequestInit): Promise<{
    data: HandoffOut;
}> =>{
    const res = await fetch(`/api/assessment-domain-runs/${params.domain_run_id}/handoff`, {
        ...options,
        method: "GET",
        headers: {
            ...(params?.["X-Forwarded-Host"] != null && {
                "X-Forwarded-Host": params["X-Forwarded-Host"]
            }),
            ...(params?.["X-Forwarded-Preferred-Username"] != null && {
                "X-Forwarded-Preferred-Username": params["X-Forwarded-Preferred-Username"]
            }),
            ...(params?.["X-Forwarded-User"] != null && {
                "X-Forwarded-User": params["X-Forwarded-User"]
            }),
            ...(params?.["X-Forwarded-Email"] != null && {
                "X-Forwarded-Email": params["X-Forwarded-Email"]
            }),
            ...(params?.["X-Request-Id"] != null && {
                "X-Request-Id": params["X-Request-Id"]
            }),
            ...(params?.["X-Forwarded-Access-Token"] != null && {
                "X-Forwarded-Access-Token": params["X-Forwarded-Access-Token"]
            }),
            ...options?.headers
        }
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export const getAssessmentHandoffKey = (params?: GetAssessmentHandoffParams)=>{
    return [
        "/api/assessment-domain-runs/{domain_run_id}/handoff",
        params
    ] as const;
};
export function useGetAssessmentHandoff<TData = {
    data: HandoffOut;
}>(options: {
    params: GetAssessmentHandoffParams;
    query?: Omit<UseQueryOptions<{
        data: HandoffOut;
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useQuery({
        queryKey: getAssessmentHandoffKey(options.params),
        queryFn: ()=>getAssessmentHandoff(options.params),
        ...options?.query
    });
}
export function useGetAssessmentHandoffSuspense<TData = {
    data: HandoffOut;
}>(options: {
    params: GetAssessmentHandoffParams;
    query?: Omit<UseSuspenseQueryOptions<{
        data: HandoffOut;
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useSuspenseQuery({
        queryKey: getAssessmentHandoffKey(options.params),
        queryFn: ()=>getAssessmentHandoff(options.params),
        ...options?.query
    });
}
export interface CreateAssessmentHandoffParams {
    domain_run_id: string;
    "X-Forwarded-Host"?: string | null;
    "X-Forwarded-Preferred-Username"?: string | null;
    "X-Forwarded-User"?: string | null;
    "X-Forwarded-Email"?: string | null;
    "X-Request-Id"?: string | null;
    "X-Forwarded-Access-Token"?: string | null;
}
export const createAssessmentHandoff = async (params: CreateAssessmentHandoffParams, data: HandoffIn, options?: RequestInit): Promise<{
    data: HandoffOut;
}> =>{
    const res = await fetch(`/api/assessment-domain-runs/${params.domain_run_id}/handoff`, {
        ...options,
        method: "POST",
        headers: {
            "Content-Type": "application/json",
            ...(params?.["X-Forwarded-Host"] != null && {
                "X-Forwarded-Host": params["X-Forwarded-Host"]
            }),
            ...(params?.["X-Forwarded-Preferred-Username"] != null && {
                "X-Forwarded-Preferred-Username": params["X-Forwarded-Preferred-Username"]
            }),
            ...(params?.["X-Forwarded-User"] != null && {
                "X-Forwarded-User": params["X-Forwarded-User"]
            }),
            ...(params?.["X-Forwarded-Email"] != null && {
                "X-Forwarded-Email": params["X-Forwarded-Email"]
            }),
            ...(params?.["X-Request-Id"] != null && {
                "X-Request-Id": params["X-Request-Id"]
            }),
            ...(params?.["X-Forwarded-Access-Token"] != null && {
                "X-Forwarded-Access-Token": params["X-Forwarded-Access-Token"]
            }),
            ...options?.headers
        },
        body: JSON.stringify(data)
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export function useCreateAssessmentHandoff(options?: {
    mutation?: UseMutationOptions<{
        data: HandoffOut;
    }, ApiError, {
        params: CreateAssessmentHandoffParams;
        data: HandoffIn;
    }>;
}) {
    return useMutation({
        mutationFn: (vars)=>createAssessmentHandoff(vars.params, vars.data),
        ...options?.mutation
    });
}
export interface InstallAssessmentSkillsParams {
    domain_run_id: string;
    "X-Forwarded-Host"?: string | null;
    "X-Forwarded-Preferred-Username"?: string | null;
    "X-Forwarded-User"?: string | null;
    "X-Forwarded-Email"?: string | null;
    "X-Request-Id"?: string | null;
    "X-Forwarded-Access-Token"?: string | null;
}
export const installAssessmentSkills = async (params: InstallAssessmentSkillsParams, data: InstallSkillsIn, options?: RequestInit): Promise<{
    data: InstallSkillsOut;
}> =>{
    const res = await fetch(`/api/assessment-domain-runs/${params.domain_run_id}/handoff/install-skills`, {
        ...options,
        method: "POST",
        headers: {
            "Content-Type": "application/json",
            ...(params?.["X-Forwarded-Host"] != null && {
                "X-Forwarded-Host": params["X-Forwarded-Host"]
            }),
            ...(params?.["X-Forwarded-Preferred-Username"] != null && {
                "X-Forwarded-Preferred-Username": params["X-Forwarded-Preferred-Username"]
            }),
            ...(params?.["X-Forwarded-User"] != null && {
                "X-Forwarded-User": params["X-Forwarded-User"]
            }),
            ...(params?.["X-Forwarded-Email"] != null && {
                "X-Forwarded-Email": params["X-Forwarded-Email"]
            }),
            ...(params?.["X-Request-Id"] != null && {
                "X-Request-Id": params["X-Request-Id"]
            }),
            ...(params?.["X-Forwarded-Access-Token"] != null && {
                "X-Forwarded-Access-Token": params["X-Forwarded-Access-Token"]
            }),
            ...options?.headers
        },
        body: JSON.stringify(data)
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export function useInstallAssessmentSkills(options?: {
    mutation?: UseMutationOptions<{
        data: InstallSkillsOut;
    }, ApiError, {
        params: InstallAssessmentSkillsParams;
        data: InstallSkillsIn;
    }>;
}) {
    return useMutation({
        mutationFn: (vars)=>installAssessmentSkills(vars.params, vars.data),
        ...options?.mutation
    });
}
export interface AddNextVibesToFeedbackParams {
    domain_run_id: string;
    "X-Forwarded-Host"?: string | null;
    "X-Forwarded-Preferred-Username"?: string | null;
    "X-Forwarded-User"?: string | null;
    "X-Forwarded-Email"?: string | null;
    "X-Request-Id"?: string | null;
    "X-Forwarded-Access-Token"?: string | null;
}
export const addNextVibesToFeedback = async (params: AddNextVibesToFeedbackParams, data: BulkAddNextVibesToFeedbackIn, options?: RequestInit): Promise<{
    data: BulkNextVibeToFeedbackOut;
}> =>{
    const res = await fetch(`/api/assessment-domain-runs/${params.domain_run_id}/next-vibes/feedback/bulk`, {
        ...options,
        method: "POST",
        headers: {
            "Content-Type": "application/json",
            ...(params?.["X-Forwarded-Host"] != null && {
                "X-Forwarded-Host": params["X-Forwarded-Host"]
            }),
            ...(params?.["X-Forwarded-Preferred-Username"] != null && {
                "X-Forwarded-Preferred-Username": params["X-Forwarded-Preferred-Username"]
            }),
            ...(params?.["X-Forwarded-User"] != null && {
                "X-Forwarded-User": params["X-Forwarded-User"]
            }),
            ...(params?.["X-Forwarded-Email"] != null && {
                "X-Forwarded-Email": params["X-Forwarded-Email"]
            }),
            ...(params?.["X-Request-Id"] != null && {
                "X-Request-Id": params["X-Request-Id"]
            }),
            ...(params?.["X-Forwarded-Access-Token"] != null && {
                "X-Forwarded-Access-Token": params["X-Forwarded-Access-Token"]
            }),
            ...options?.headers
        },
        body: JSON.stringify(data)
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export function useAddNextVibesToFeedback(options?: {
    mutation?: UseMutationOptions<{
        data: BulkNextVibeToFeedbackOut;
    }, ApiError, {
        params: AddNextVibesToFeedbackParams;
        data: BulkAddNextVibesToFeedbackIn;
    }>;
}) {
    return useMutation({
        mutationFn: (vars)=>addNextVibesToFeedback(vars.params, vars.data),
        ...options?.mutation
    });
}
export interface AddNextVibeToFeedbackParams {
    domain_run_id: string;
    next_vibe_id: string;
    "X-Forwarded-Host"?: string | null;
    "X-Forwarded-Preferred-Username"?: string | null;
    "X-Forwarded-User"?: string | null;
    "X-Forwarded-Email"?: string | null;
    "X-Request-Id"?: string | null;
    "X-Forwarded-Access-Token"?: string | null;
}
export const addNextVibeToFeedback = async (params: AddNextVibeToFeedbackParams, options?: RequestInit): Promise<{
    data: NextVibeToFeedbackOut;
}> =>{
    const res = await fetch(`/api/assessment-domain-runs/${params.domain_run_id}/next-vibes/${params.next_vibe_id}/feedback`, {
        ...options,
        method: "POST",
        headers: {
            ...(params?.["X-Forwarded-Host"] != null && {
                "X-Forwarded-Host": params["X-Forwarded-Host"]
            }),
            ...(params?.["X-Forwarded-Preferred-Username"] != null && {
                "X-Forwarded-Preferred-Username": params["X-Forwarded-Preferred-Username"]
            }),
            ...(params?.["X-Forwarded-User"] != null && {
                "X-Forwarded-User": params["X-Forwarded-User"]
            }),
            ...(params?.["X-Forwarded-Email"] != null && {
                "X-Forwarded-Email": params["X-Forwarded-Email"]
            }),
            ...(params?.["X-Request-Id"] != null && {
                "X-Request-Id": params["X-Request-Id"]
            }),
            ...(params?.["X-Forwarded-Access-Token"] != null && {
                "X-Forwarded-Access-Token": params["X-Forwarded-Access-Token"]
            }),
            ...options?.headers
        }
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export function useAddNextVibeToFeedback(options?: {
    mutation?: UseMutationOptions<{
        data: NextVibeToFeedbackOut;
    }, ApiError, {
        params: AddNextVibeToFeedbackParams;
    }>;
}) {
    return useMutation({
        mutationFn: (vars)=>addNextVibeToFeedback(vars.params),
        ...options?.mutation
    });
}
export interface GetAssessmentResultsParams {
    domain_run_id: string;
}
export const getAssessmentResults = async (params: GetAssessmentResultsParams, options?: RequestInit): Promise<{
    data: AssessResultsOut;
}> =>{
    const res = await fetch(`/api/assessment-domain-runs/${params.domain_run_id}/results`, {
        ...options,
        method: "GET"
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export const getAssessmentResultsKey = (params?: GetAssessmentResultsParams)=>{
    return [
        "/api/assessment-domain-runs/{domain_run_id}/results",
        params
    ] as const;
};
export function useGetAssessmentResults<TData = {
    data: AssessResultsOut;
}>(options: {
    params: GetAssessmentResultsParams;
    query?: Omit<UseQueryOptions<{
        data: AssessResultsOut;
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useQuery({
        queryKey: getAssessmentResultsKey(options.params),
        queryFn: ()=>getAssessmentResults(options.params),
        ...options?.query
    });
}
export function useGetAssessmentResultsSuspense<TData = {
    data: AssessResultsOut;
}>(options: {
    params: GetAssessmentResultsParams;
    query?: Omit<UseSuspenseQueryOptions<{
        data: AssessResultsOut;
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useSuspenseQuery({
        queryKey: getAssessmentResultsKey(options.params),
        queryFn: ()=>getAssessmentResults(options.params),
        ...options?.query
    });
}
export interface GetAssessmentParams {
    batch_id: string;
}
export const getAssessment = async (params: GetAssessmentParams, options?: RequestInit): Promise<{
    data: AssessBatchOut;
}> =>{
    const res = await fetch(`/api/assessments/${params.batch_id}`, {
        ...options,
        method: "GET"
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export const getAssessmentKey = (params?: GetAssessmentParams)=>{
    return [
        "/api/assessments/{batch_id}",
        params
    ] as const;
};
export function useGetAssessment<TData = {
    data: AssessBatchOut;
}>(options: {
    params: GetAssessmentParams;
    query?: Omit<UseQueryOptions<{
        data: AssessBatchOut;
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useQuery({
        queryKey: getAssessmentKey(options.params),
        queryFn: ()=>getAssessment(options.params),
        ...options?.query
    });
}
export function useGetAssessmentSuspense<TData = {
    data: AssessBatchOut;
}>(options: {
    params: GetAssessmentParams;
    query?: Omit<UseSuspenseQueryOptions<{
        data: AssessBatchOut;
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useSuspenseQuery({
        queryKey: getAssessmentKey(options.params),
        queryFn: ()=>getAssessment(options.params),
        ...options?.query
    });
}
export interface CancelAssessmentParams {
    batch_id: string;
    "X-Forwarded-Host"?: string | null;
    "X-Forwarded-Preferred-Username"?: string | null;
    "X-Forwarded-User"?: string | null;
    "X-Forwarded-Email"?: string | null;
    "X-Request-Id"?: string | null;
    "X-Forwarded-Access-Token"?: string | null;
}
export const cancelAssessment = async (params: CancelAssessmentParams, options?: RequestInit): Promise<{
    data: AssessBatchOut;
}> =>{
    const res = await fetch(`/api/assessments/${params.batch_id}/cancel`, {
        ...options,
        method: "POST",
        headers: {
            ...(params?.["X-Forwarded-Host"] != null && {
                "X-Forwarded-Host": params["X-Forwarded-Host"]
            }),
            ...(params?.["X-Forwarded-Preferred-Username"] != null && {
                "X-Forwarded-Preferred-Username": params["X-Forwarded-Preferred-Username"]
            }),
            ...(params?.["X-Forwarded-User"] != null && {
                "X-Forwarded-User": params["X-Forwarded-User"]
            }),
            ...(params?.["X-Forwarded-Email"] != null && {
                "X-Forwarded-Email": params["X-Forwarded-Email"]
            }),
            ...(params?.["X-Request-Id"] != null && {
                "X-Request-Id": params["X-Request-Id"]
            }),
            ...(params?.["X-Forwarded-Access-Token"] != null && {
                "X-Forwarded-Access-Token": params["X-Forwarded-Access-Token"]
            }),
            ...options?.headers
        }
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export function useCancelAssessment(options?: {
    mutation?: UseMutationOptions<{
        data: AssessBatchOut;
    }, ApiError, {
        params: CancelAssessmentParams;
    }>;
}) {
    return useMutation({
        mutationFn: (vars)=>cancelAssessment(vars.params),
        ...options?.mutation
    });
}
export interface RelaunchAssessmentParams {
    batch_id: string;
    "X-Forwarded-Host"?: string | null;
    "X-Forwarded-Preferred-Username"?: string | null;
    "X-Forwarded-User"?: string | null;
    "X-Forwarded-Email"?: string | null;
    "X-Request-Id"?: string | null;
    "X-Forwarded-Access-Token"?: string | null;
}
export const relaunchAssessment = async (params: RelaunchAssessmentParams, data: AssessRelaunchIn | null, options?: RequestInit): Promise<{
    data: AssessBatchOut;
}> =>{
    const res = await fetch(`/api/assessments/${params.batch_id}/relaunch`, {
        ...options,
        method: "POST",
        headers: {
            "Content-Type": "application/json",
            ...(params?.["X-Forwarded-Host"] != null && {
                "X-Forwarded-Host": params["X-Forwarded-Host"]
            }),
            ...(params?.["X-Forwarded-Preferred-Username"] != null && {
                "X-Forwarded-Preferred-Username": params["X-Forwarded-Preferred-Username"]
            }),
            ...(params?.["X-Forwarded-User"] != null && {
                "X-Forwarded-User": params["X-Forwarded-User"]
            }),
            ...(params?.["X-Forwarded-Email"] != null && {
                "X-Forwarded-Email": params["X-Forwarded-Email"]
            }),
            ...(params?.["X-Request-Id"] != null && {
                "X-Request-Id": params["X-Request-Id"]
            }),
            ...(params?.["X-Forwarded-Access-Token"] != null && {
                "X-Forwarded-Access-Token": params["X-Forwarded-Access-Token"]
            }),
            ...options?.headers
        },
        body: JSON.stringify(data)
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export function useRelaunchAssessment(options?: {
    mutation?: UseMutationOptions<{
        data: AssessBatchOut;
    }, ApiError, {
        params: RelaunchAssessmentParams;
        data: AssessRelaunchIn | null;
    }>;
}) {
    return useMutation({
        mutationFn: (vars)=>relaunchAssessment(vars.params, vars.data),
        ...options?.mutation
    });
}
export interface ListBusinessesParams {
    kind?: BusinessKind | null;
}
export const listBusinesses = async (params?: ListBusinessesParams, options?: RequestInit): Promise<{
    data: BusinessListOut[];
}> =>{
    const searchParams = new URLSearchParams();
    if (params?.kind != null) searchParams.set("kind", String(params?.kind));
    const queryString = searchParams.toString();
    const url = queryString ? `/api/businesses?${queryString}` : "/api/businesses";
    const res = await fetch(url, {
        ...options,
        method: "GET"
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export const listBusinessesKey = (params?: ListBusinessesParams)=>{
    return [
        "/api/businesses",
        params
    ] as const;
};
export function useListBusinesses<TData = {
    data: BusinessListOut[];
}>(options?: {
    params?: ListBusinessesParams;
    query?: Omit<UseQueryOptions<{
        data: BusinessListOut[];
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useQuery({
        queryKey: listBusinessesKey(options?.params),
        queryFn: ()=>listBusinesses(options?.params),
        ...options?.query
    });
}
export function useListBusinessesSuspense<TData = {
    data: BusinessListOut[];
}>(options?: {
    params?: ListBusinessesParams;
    query?: Omit<UseSuspenseQueryOptions<{
        data: BusinessListOut[];
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useSuspenseQuery({
        queryKey: listBusinessesKey(options?.params),
        queryFn: ()=>listBusinesses(options?.params),
        ...options?.query
    });
}
export interface CreateBusinessParams {
    "X-Forwarded-Host"?: string | null;
    "X-Forwarded-Preferred-Username"?: string | null;
    "X-Forwarded-User"?: string | null;
    "X-Forwarded-Email"?: string | null;
    "X-Request-Id"?: string | null;
    "X-Forwarded-Access-Token"?: string | null;
}
export const createBusiness = async (data: BusinessIn, params?: CreateBusinessParams, options?: RequestInit): Promise<{
    data: BusinessOut;
}> =>{
    const res = await fetch("/api/businesses", {
        ...options,
        method: "POST",
        headers: {
            "Content-Type": "application/json",
            ...(params?.["X-Forwarded-Host"] != null && {
                "X-Forwarded-Host": params["X-Forwarded-Host"]
            }),
            ...(params?.["X-Forwarded-Preferred-Username"] != null && {
                "X-Forwarded-Preferred-Username": params["X-Forwarded-Preferred-Username"]
            }),
            ...(params?.["X-Forwarded-User"] != null && {
                "X-Forwarded-User": params["X-Forwarded-User"]
            }),
            ...(params?.["X-Forwarded-Email"] != null && {
                "X-Forwarded-Email": params["X-Forwarded-Email"]
            }),
            ...(params?.["X-Request-Id"] != null && {
                "X-Request-Id": params["X-Request-Id"]
            }),
            ...(params?.["X-Forwarded-Access-Token"] != null && {
                "X-Forwarded-Access-Token": params["X-Forwarded-Access-Token"]
            }),
            ...options?.headers
        },
        body: JSON.stringify(data)
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export function useCreateBusiness(options?: {
    mutation?: UseMutationOptions<{
        data: BusinessOut;
    }, ApiError, {
        params: CreateBusinessParams;
        data: BusinessIn;
    }>;
}) {
    return useMutation({
        mutationFn: (vars)=>createBusiness(vars.data, vars.params),
        ...options?.mutation
    });
}
export interface GetBusinessParams {
    business_id: string;
}
export const getBusiness = async (params: GetBusinessParams, options?: RequestInit): Promise<{
    data: BusinessOut;
}> =>{
    const res = await fetch(`/api/businesses/${params.business_id}`, {
        ...options,
        method: "GET"
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export const getBusinessKey = (params?: GetBusinessParams)=>{
    return [
        "/api/businesses/{business_id}",
        params
    ] as const;
};
export function useGetBusiness<TData = {
    data: BusinessOut;
}>(options: {
    params: GetBusinessParams;
    query?: Omit<UseQueryOptions<{
        data: BusinessOut;
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useQuery({
        queryKey: getBusinessKey(options.params),
        queryFn: ()=>getBusiness(options.params),
        ...options?.query
    });
}
export function useGetBusinessSuspense<TData = {
    data: BusinessOut;
}>(options: {
    params: GetBusinessParams;
    query?: Omit<UseSuspenseQueryOptions<{
        data: BusinessOut;
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useSuspenseQuery({
        queryKey: getBusinessKey(options.params),
        queryFn: ()=>getBusiness(options.params),
        ...options?.query
    });
}
export interface UpdateBusinessParams {
    business_id: string;
    "X-Forwarded-Host"?: string | null;
    "X-Forwarded-Preferred-Username"?: string | null;
    "X-Forwarded-User"?: string | null;
    "X-Forwarded-Email"?: string | null;
    "X-Request-Id"?: string | null;
    "X-Forwarded-Access-Token"?: string | null;
}
export const updateBusiness = async (params: UpdateBusinessParams, data: BusinessIn, options?: RequestInit): Promise<{
    data: BusinessOut;
}> =>{
    const res = await fetch(`/api/businesses/${params.business_id}`, {
        ...options,
        method: "PUT",
        headers: {
            "Content-Type": "application/json",
            ...(params?.["X-Forwarded-Host"] != null && {
                "X-Forwarded-Host": params["X-Forwarded-Host"]
            }),
            ...(params?.["X-Forwarded-Preferred-Username"] != null && {
                "X-Forwarded-Preferred-Username": params["X-Forwarded-Preferred-Username"]
            }),
            ...(params?.["X-Forwarded-User"] != null && {
                "X-Forwarded-User": params["X-Forwarded-User"]
            }),
            ...(params?.["X-Forwarded-Email"] != null && {
                "X-Forwarded-Email": params["X-Forwarded-Email"]
            }),
            ...(params?.["X-Request-Id"] != null && {
                "X-Request-Id": params["X-Request-Id"]
            }),
            ...(params?.["X-Forwarded-Access-Token"] != null && {
                "X-Forwarded-Access-Token": params["X-Forwarded-Access-Token"]
            }),
            ...options?.headers
        },
        body: JSON.stringify(data)
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export function useUpdateBusiness(options?: {
    mutation?: UseMutationOptions<{
        data: BusinessOut;
    }, ApiError, {
        params: UpdateBusinessParams;
        data: BusinessIn;
    }>;
}) {
    return useMutation({
        mutationFn: (vars)=>updateBusiness(vars.params, vars.data),
        ...options?.mutation
    });
}
export interface DeleteBusinessParams {
    business_id: string;
    cascade?: boolean;
    "X-Forwarded-Host"?: string | null;
    "X-Forwarded-Preferred-Username"?: string | null;
    "X-Forwarded-User"?: string | null;
    "X-Forwarded-Email"?: string | null;
    "X-Request-Id"?: string | null;
    "X-Forwarded-Access-Token"?: string | null;
}
export const deleteBusiness = async (params: DeleteBusinessParams, options?: RequestInit): Promise<{
    data: BusinessDeleteOut;
}> =>{
    const searchParams = new URLSearchParams();
    if (params?.cascade != null) searchParams.set("cascade", String(params?.cascade));
    const queryString = searchParams.toString();
    const url = queryString ? `/api/businesses/${params.business_id}?${queryString}` : `/api/businesses/${params.business_id}`;
    const res = await fetch(url, {
        ...options,
        method: "DELETE",
        headers: {
            ...(params?.["X-Forwarded-Host"] != null && {
                "X-Forwarded-Host": params["X-Forwarded-Host"]
            }),
            ...(params?.["X-Forwarded-Preferred-Username"] != null && {
                "X-Forwarded-Preferred-Username": params["X-Forwarded-Preferred-Username"]
            }),
            ...(params?.["X-Forwarded-User"] != null && {
                "X-Forwarded-User": params["X-Forwarded-User"]
            }),
            ...(params?.["X-Forwarded-Email"] != null && {
                "X-Forwarded-Email": params["X-Forwarded-Email"]
            }),
            ...(params?.["X-Request-Id"] != null && {
                "X-Request-Id": params["X-Request-Id"]
            }),
            ...(params?.["X-Forwarded-Access-Token"] != null && {
                "X-Forwarded-Access-Token": params["X-Forwarded-Access-Token"]
            }),
            ...options?.headers
        }
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export function useDeleteBusiness(options?: {
    mutation?: UseMutationOptions<{
        data: BusinessDeleteOut;
    }, ApiError, {
        params: DeleteBusinessParams;
    }>;
}) {
    return useMutation({
        mutationFn: (vars)=>deleteBusiness(vars.params),
        ...options?.mutation
    });
}
export interface GetAssessSourceMapParams {
    business_id: string;
}
export const getAssessSourceMap = async (params: GetAssessSourceMapParams, options?: RequestInit): Promise<{
    data: SourceMapOut;
}> =>{
    const res = await fetch(`/api/businesses/${params.business_id}/assess-source-map`, {
        ...options,
        method: "GET"
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export const getAssessSourceMapKey = (params?: GetAssessSourceMapParams)=>{
    return [
        "/api/businesses/{business_id}/assess-source-map",
        params
    ] as const;
};
export function useGetAssessSourceMap<TData = {
    data: SourceMapOut;
}>(options: {
    params: GetAssessSourceMapParams;
    query?: Omit<UseQueryOptions<{
        data: SourceMapOut;
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useQuery({
        queryKey: getAssessSourceMapKey(options.params),
        queryFn: ()=>getAssessSourceMap(options.params),
        ...options?.query
    });
}
export function useGetAssessSourceMapSuspense<TData = {
    data: SourceMapOut;
}>(options: {
    params: GetAssessSourceMapParams;
    query?: Omit<UseSuspenseQueryOptions<{
        data: SourceMapOut;
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useSuspenseQuery({
        queryKey: getAssessSourceMapKey(options.params),
        queryFn: ()=>getAssessSourceMap(options.params),
        ...options?.query
    });
}
export interface PutAssessSourceMapParams {
    business_id: string;
    "X-Forwarded-Host"?: string | null;
    "X-Forwarded-Preferred-Username"?: string | null;
    "X-Forwarded-User"?: string | null;
    "X-Forwarded-Email"?: string | null;
    "X-Request-Id"?: string | null;
    "X-Forwarded-Access-Token"?: string | null;
}
export const putAssessSourceMap = async (params: PutAssessSourceMapParams, data: SourceMapIn, options?: RequestInit): Promise<{
    data: SourceMapOut;
}> =>{
    const res = await fetch(`/api/businesses/${params.business_id}/assess-source-map`, {
        ...options,
        method: "PUT",
        headers: {
            "Content-Type": "application/json",
            ...(params?.["X-Forwarded-Host"] != null && {
                "X-Forwarded-Host": params["X-Forwarded-Host"]
            }),
            ...(params?.["X-Forwarded-Preferred-Username"] != null && {
                "X-Forwarded-Preferred-Username": params["X-Forwarded-Preferred-Username"]
            }),
            ...(params?.["X-Forwarded-User"] != null && {
                "X-Forwarded-User": params["X-Forwarded-User"]
            }),
            ...(params?.["X-Forwarded-Email"] != null && {
                "X-Forwarded-Email": params["X-Forwarded-Email"]
            }),
            ...(params?.["X-Request-Id"] != null && {
                "X-Request-Id": params["X-Request-Id"]
            }),
            ...(params?.["X-Forwarded-Access-Token"] != null && {
                "X-Forwarded-Access-Token": params["X-Forwarded-Access-Token"]
            }),
            ...options?.headers
        },
        body: JSON.stringify(data)
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export function usePutAssessSourceMap(options?: {
    mutation?: UseMutationOptions<{
        data: SourceMapOut;
    }, ApiError, {
        params: PutAssessSourceMapParams;
        data: SourceMapIn;
    }>;
}) {
    return useMutation({
        mutationFn: (vars)=>putAssessSourceMap(vars.params, vars.data),
        ...options?.mutation
    });
}
export interface ListAssessmentsParams {
    business_id: string;
}
export const listAssessments = async (params: ListAssessmentsParams, options?: RequestInit): Promise<{
    data: AssessBatchOut[];
}> =>{
    const res = await fetch(`/api/businesses/${params.business_id}/assessments`, {
        ...options,
        method: "GET"
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export const listAssessmentsKey = (params?: ListAssessmentsParams)=>{
    return [
        "/api/businesses/{business_id}/assessments",
        params
    ] as const;
};
export function useListAssessments<TData = {
    data: AssessBatchOut[];
}>(options: {
    params: ListAssessmentsParams;
    query?: Omit<UseQueryOptions<{
        data: AssessBatchOut[];
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useQuery({
        queryKey: listAssessmentsKey(options.params),
        queryFn: ()=>listAssessments(options.params),
        ...options?.query
    });
}
export function useListAssessmentsSuspense<TData = {
    data: AssessBatchOut[];
}>(options: {
    params: ListAssessmentsParams;
    query?: Omit<UseSuspenseQueryOptions<{
        data: AssessBatchOut[];
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useSuspenseQuery({
        queryKey: listAssessmentsKey(options.params),
        queryFn: ()=>listAssessments(options.params),
        ...options?.query
    });
}
export interface LaunchAssessmentParams {
    business_id: string;
    "X-Forwarded-Host"?: string | null;
    "X-Forwarded-Preferred-Username"?: string | null;
    "X-Forwarded-User"?: string | null;
    "X-Forwarded-Email"?: string | null;
    "X-Request-Id"?: string | null;
    "X-Forwarded-Access-Token"?: string | null;
}
export const launchAssessment = async (params: LaunchAssessmentParams, data: AssessBatchIn, options?: RequestInit): Promise<{
    data: AssessBatchOut;
}> =>{
    const res = await fetch(`/api/businesses/${params.business_id}/assessments`, {
        ...options,
        method: "POST",
        headers: {
            "Content-Type": "application/json",
            ...(params?.["X-Forwarded-Host"] != null && {
                "X-Forwarded-Host": params["X-Forwarded-Host"]
            }),
            ...(params?.["X-Forwarded-Preferred-Username"] != null && {
                "X-Forwarded-Preferred-Username": params["X-Forwarded-Preferred-Username"]
            }),
            ...(params?.["X-Forwarded-User"] != null && {
                "X-Forwarded-User": params["X-Forwarded-User"]
            }),
            ...(params?.["X-Forwarded-Email"] != null && {
                "X-Forwarded-Email": params["X-Forwarded-Email"]
            }),
            ...(params?.["X-Request-Id"] != null && {
                "X-Request-Id": params["X-Request-Id"]
            }),
            ...(params?.["X-Forwarded-Access-Token"] != null && {
                "X-Forwarded-Access-Token": params["X-Forwarded-Access-Token"]
            }),
            ...options?.headers
        },
        body: JSON.stringify(data)
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export function useLaunchAssessment(options?: {
    mutation?: UseMutationOptions<{
        data: AssessBatchOut;
    }, ApiError, {
        params: LaunchAssessmentParams;
        data: AssessBatchIn;
    }>;
}) {
    return useMutation({
        mutationFn: (vars)=>launchAssessment(vars.params, vars.data),
        ...options?.mutation
    });
}
export interface ListContextsParams {
    business_id: string;
}
export const listContexts = async (params: ListContextsParams, options?: RequestInit): Promise<{
    data: BusinessContextOut[];
}> =>{
    const res = await fetch(`/api/businesses/${params.business_id}/contexts`, {
        ...options,
        method: "GET"
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export const listContextsKey = (params?: ListContextsParams)=>{
    return [
        "/api/businesses/{business_id}/contexts",
        params
    ] as const;
};
export function useListContexts<TData = {
    data: BusinessContextOut[];
}>(options: {
    params: ListContextsParams;
    query?: Omit<UseQueryOptions<{
        data: BusinessContextOut[];
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useQuery({
        queryKey: listContextsKey(options.params),
        queryFn: ()=>listContexts(options.params),
        ...options?.query
    });
}
export function useListContextsSuspense<TData = {
    data: BusinessContextOut[];
}>(options: {
    params: ListContextsParams;
    query?: Omit<UseSuspenseQueryOptions<{
        data: BusinessContextOut[];
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useSuspenseQuery({
        queryKey: listContextsKey(options.params),
        queryFn: ()=>listContexts(options.params),
        ...options?.query
    });
}
export interface CreateContextParams {
    business_id: string;
    "X-Forwarded-Host"?: string | null;
    "X-Forwarded-Preferred-Username"?: string | null;
    "X-Forwarded-User"?: string | null;
    "X-Forwarded-Email"?: string | null;
    "X-Request-Id"?: string | null;
    "X-Forwarded-Access-Token"?: string | null;
}
export const createContext = async (params: CreateContextParams, data: BusinessContextIn, options?: RequestInit): Promise<{
    data: BusinessContextOut;
}> =>{
    const res = await fetch(`/api/businesses/${params.business_id}/contexts`, {
        ...options,
        method: "POST",
        headers: {
            "Content-Type": "application/json",
            ...(params?.["X-Forwarded-Host"] != null && {
                "X-Forwarded-Host": params["X-Forwarded-Host"]
            }),
            ...(params?.["X-Forwarded-Preferred-Username"] != null && {
                "X-Forwarded-Preferred-Username": params["X-Forwarded-Preferred-Username"]
            }),
            ...(params?.["X-Forwarded-User"] != null && {
                "X-Forwarded-User": params["X-Forwarded-User"]
            }),
            ...(params?.["X-Forwarded-Email"] != null && {
                "X-Forwarded-Email": params["X-Forwarded-Email"]
            }),
            ...(params?.["X-Request-Id"] != null && {
                "X-Request-Id": params["X-Request-Id"]
            }),
            ...(params?.["X-Forwarded-Access-Token"] != null && {
                "X-Forwarded-Access-Token": params["X-Forwarded-Access-Token"]
            }),
            ...options?.headers
        },
        body: JSON.stringify(data)
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export function useCreateContext(options?: {
    mutation?: UseMutationOptions<{
        data: BusinessContextOut;
    }, ApiError, {
        params: CreateContextParams;
        data: BusinessContextIn;
    }>;
}) {
    return useMutation({
        mutationFn: (vars)=>createContext(vars.params, vars.data),
        ...options?.mutation
    });
}
export interface GetExplorerVersionsParams {
    business_id: string;
}
export const getExplorerVersions = async (params: GetExplorerVersionsParams, options?: RequestInit): Promise<{
    data: VersionTreeOut[];
}> =>{
    const res = await fetch(`/api/businesses/${params.business_id}/explorer/versions`, {
        ...options,
        method: "GET"
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export const getExplorerVersionsKey = (params?: GetExplorerVersionsParams)=>{
    return [
        "/api/businesses/{business_id}/explorer/versions",
        params
    ] as const;
};
export function useGetExplorerVersions<TData = {
    data: VersionTreeOut[];
}>(options: {
    params: GetExplorerVersionsParams;
    query?: Omit<UseQueryOptions<{
        data: VersionTreeOut[];
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useQuery({
        queryKey: getExplorerVersionsKey(options.params),
        queryFn: ()=>getExplorerVersions(options.params),
        ...options?.query
    });
}
export function useGetExplorerVersionsSuspense<TData = {
    data: VersionTreeOut[];
}>(options: {
    params: GetExplorerVersionsParams;
    query?: Omit<UseSuspenseQueryOptions<{
        data: VersionTreeOut[];
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useSuspenseQuery({
        queryKey: getExplorerVersionsKey(options.params),
        queryFn: ()=>getExplorerVersions(options.params),
        ...options?.query
    });
}
export interface AnalyzeImportParams {
    business_id: string;
}
export const analyzeImport = async (params: AnalyzeImportParams, data: ImportAnalyzeIn, options?: RequestInit): Promise<{
    data: ImportAnalyzeOut;
}> =>{
    const res = await fetch(`/api/businesses/${params.business_id}/import/analyze`, {
        ...options,
        method: "POST",
        headers: {
            "Content-Type": "application/json",
            ...options?.headers
        },
        body: JSON.stringify(data)
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export function useAnalyzeImport(options?: {
    mutation?: UseMutationOptions<{
        data: ImportAnalyzeOut;
    }, ApiError, {
        params: AnalyzeImportParams;
        data: ImportAnalyzeIn;
    }>;
}) {
    return useMutation({
        mutationFn: (vars)=>analyzeImport(vars.params, vars.data),
        ...options?.mutation
    });
}
export interface ExecuteImportParams {
    business_id: string;
    "X-Forwarded-Host"?: string | null;
    "X-Forwarded-Preferred-Username"?: string | null;
    "X-Forwarded-User"?: string | null;
    "X-Forwarded-Email"?: string | null;
    "X-Request-Id"?: string | null;
    "X-Forwarded-Access-Token"?: string | null;
}
export const executeImport = async (params: ExecuteImportParams, data: ImportExecuteIn, options?: RequestInit): Promise<{
    data: ImportExecuteOut;
}> =>{
    const res = await fetch(`/api/businesses/${params.business_id}/import/execute`, {
        ...options,
        method: "POST",
        headers: {
            "Content-Type": "application/json",
            ...(params?.["X-Forwarded-Host"] != null && {
                "X-Forwarded-Host": params["X-Forwarded-Host"]
            }),
            ...(params?.["X-Forwarded-Preferred-Username"] != null && {
                "X-Forwarded-Preferred-Username": params["X-Forwarded-Preferred-Username"]
            }),
            ...(params?.["X-Forwarded-User"] != null && {
                "X-Forwarded-User": params["X-Forwarded-User"]
            }),
            ...(params?.["X-Forwarded-Email"] != null && {
                "X-Forwarded-Email": params["X-Forwarded-Email"]
            }),
            ...(params?.["X-Request-Id"] != null && {
                "X-Request-Id": params["X-Request-Id"]
            }),
            ...(params?.["X-Forwarded-Access-Token"] != null && {
                "X-Forwarded-Access-Token": params["X-Forwarded-Access-Token"]
            }),
            ...options?.headers
        },
        body: JSON.stringify(data)
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export function useExecuteImport(options?: {
    mutation?: UseMutationOptions<{
        data: ImportExecuteOut;
    }, ApiError, {
        params: ExecuteImportParams;
        data: ImportExecuteIn;
    }>;
}) {
    return useMutation({
        mutationFn: (vars)=>executeImport(vars.params, vars.data),
        ...options?.mutation
    });
}
export interface ListVibeInputsParams {
    business_id: string;
    origin?: VibeInputOrigin | null;
    status?: VibeInputStatus | null;
    consumed?: boolean | null;
    needs_link_review?: boolean | null;
    priority?: VibeInputPriority | null;
    q?: string | null;
    version_id?: string | null;
    domain_id?: string | null;
    subdomain_id?: string | null;
    product_id?: string | null;
    attribute_id?: string | null;
    fk_link_id?: string | null;
    model_wide?: boolean | null;
    "X-Forwarded-Host"?: string | null;
    "X-Forwarded-Preferred-Username"?: string | null;
    "X-Forwarded-User"?: string | null;
    "X-Forwarded-Email"?: string | null;
    "X-Request-Id"?: string | null;
    "X-Forwarded-Access-Token"?: string | null;
}
export const listVibeInputs = async (params: ListVibeInputsParams, options?: RequestInit): Promise<{
    data: VibeInputOut[];
}> =>{
    const searchParams = new URLSearchParams();
    if (params?.origin != null) searchParams.set("origin", String(params?.origin));
    if (params?.status != null) searchParams.set("status", String(params?.status));
    if (params?.consumed != null) searchParams.set("consumed", String(params?.consumed));
    if (params?.needs_link_review != null) searchParams.set("needs_link_review", String(params?.needs_link_review));
    if (params?.priority != null) searchParams.set("priority", String(params?.priority));
    if (params?.q != null) searchParams.set("q", String(params?.q));
    if (params?.version_id != null) searchParams.set("version_id", String(params?.version_id));
    if (params?.domain_id != null) searchParams.set("domain_id", String(params?.domain_id));
    if (params?.subdomain_id != null) searchParams.set("subdomain_id", String(params?.subdomain_id));
    if (params?.product_id != null) searchParams.set("product_id", String(params?.product_id));
    if (params?.attribute_id != null) searchParams.set("attribute_id", String(params?.attribute_id));
    if (params?.fk_link_id != null) searchParams.set("fk_link_id", String(params?.fk_link_id));
    if (params?.model_wide != null) searchParams.set("model_wide", String(params?.model_wide));
    const queryString = searchParams.toString();
    const url = queryString ? `/api/businesses/${params.business_id}/inputs?${queryString}` : `/api/businesses/${params.business_id}/inputs`;
    const res = await fetch(url, {
        ...options,
        method: "GET",
        headers: {
            ...(params?.["X-Forwarded-Host"] != null && {
                "X-Forwarded-Host": params["X-Forwarded-Host"]
            }),
            ...(params?.["X-Forwarded-Preferred-Username"] != null && {
                "X-Forwarded-Preferred-Username": params["X-Forwarded-Preferred-Username"]
            }),
            ...(params?.["X-Forwarded-User"] != null && {
                "X-Forwarded-User": params["X-Forwarded-User"]
            }),
            ...(params?.["X-Forwarded-Email"] != null && {
                "X-Forwarded-Email": params["X-Forwarded-Email"]
            }),
            ...(params?.["X-Request-Id"] != null && {
                "X-Request-Id": params["X-Request-Id"]
            }),
            ...(params?.["X-Forwarded-Access-Token"] != null && {
                "X-Forwarded-Access-Token": params["X-Forwarded-Access-Token"]
            }),
            ...options?.headers
        }
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export const listVibeInputsKey = (params?: ListVibeInputsParams)=>{
    return [
        "/api/businesses/{business_id}/inputs",
        params
    ] as const;
};
export function useListVibeInputs<TData = {
    data: VibeInputOut[];
}>(options: {
    params: ListVibeInputsParams;
    query?: Omit<UseQueryOptions<{
        data: VibeInputOut[];
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useQuery({
        queryKey: listVibeInputsKey(options.params),
        queryFn: ()=>listVibeInputs(options.params),
        ...options?.query
    });
}
export function useListVibeInputsSuspense<TData = {
    data: VibeInputOut[];
}>(options: {
    params: ListVibeInputsParams;
    query?: Omit<UseSuspenseQueryOptions<{
        data: VibeInputOut[];
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useSuspenseQuery({
        queryKey: listVibeInputsKey(options.params),
        queryFn: ()=>listVibeInputs(options.params),
        ...options?.query
    });
}
export interface CreateVibeInputParams {
    business_id: string;
    "X-Forwarded-Host"?: string | null;
    "X-Forwarded-Preferred-Username"?: string | null;
    "X-Forwarded-User"?: string | null;
    "X-Forwarded-Email"?: string | null;
    "X-Request-Id"?: string | null;
    "X-Forwarded-Access-Token"?: string | null;
}
export const createVibeInput = async (params: CreateVibeInputParams, data: VibeInputIn, options?: RequestInit): Promise<{
    data: VibeInputOut;
}> =>{
    const res = await fetch(`/api/businesses/${params.business_id}/inputs`, {
        ...options,
        method: "POST",
        headers: {
            "Content-Type": "application/json",
            ...(params?.["X-Forwarded-Host"] != null && {
                "X-Forwarded-Host": params["X-Forwarded-Host"]
            }),
            ...(params?.["X-Forwarded-Preferred-Username"] != null && {
                "X-Forwarded-Preferred-Username": params["X-Forwarded-Preferred-Username"]
            }),
            ...(params?.["X-Forwarded-User"] != null && {
                "X-Forwarded-User": params["X-Forwarded-User"]
            }),
            ...(params?.["X-Forwarded-Email"] != null && {
                "X-Forwarded-Email": params["X-Forwarded-Email"]
            }),
            ...(params?.["X-Request-Id"] != null && {
                "X-Request-Id": params["X-Request-Id"]
            }),
            ...(params?.["X-Forwarded-Access-Token"] != null && {
                "X-Forwarded-Access-Token": params["X-Forwarded-Access-Token"]
            }),
            ...options?.headers
        },
        body: JSON.stringify(data)
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export function useCreateVibeInput(options?: {
    mutation?: UseMutationOptions<{
        data: VibeInputOut;
    }, ApiError, {
        params: CreateVibeInputParams;
        data: VibeInputIn;
    }>;
}) {
    return useMutation({
        mutationFn: (vars)=>createVibeInput(vars.params, vars.data),
        ...options?.mutation
    });
}
export interface SetVibeInputSelectionParams {
    business_id: string;
    "X-Forwarded-Host"?: string | null;
    "X-Forwarded-Preferred-Username"?: string | null;
    "X-Forwarded-User"?: string | null;
    "X-Forwarded-Email"?: string | null;
    "X-Request-Id"?: string | null;
    "X-Forwarded-Access-Token"?: string | null;
}
export const setVibeInputSelection = async (params: SetVibeInputSelectionParams, data: VibeInputSelectionIn, options?: RequestInit): Promise<{
    data: VibeInputOut[];
}> =>{
    const res = await fetch(`/api/businesses/${params.business_id}/inputs/selection`, {
        ...options,
        method: "POST",
        headers: {
            "Content-Type": "application/json",
            ...(params?.["X-Forwarded-Host"] != null && {
                "X-Forwarded-Host": params["X-Forwarded-Host"]
            }),
            ...(params?.["X-Forwarded-Preferred-Username"] != null && {
                "X-Forwarded-Preferred-Username": params["X-Forwarded-Preferred-Username"]
            }),
            ...(params?.["X-Forwarded-User"] != null && {
                "X-Forwarded-User": params["X-Forwarded-User"]
            }),
            ...(params?.["X-Forwarded-Email"] != null && {
                "X-Forwarded-Email": params["X-Forwarded-Email"]
            }),
            ...(params?.["X-Request-Id"] != null && {
                "X-Request-Id": params["X-Request-Id"]
            }),
            ...(params?.["X-Forwarded-Access-Token"] != null && {
                "X-Forwarded-Access-Token": params["X-Forwarded-Access-Token"]
            }),
            ...options?.headers
        },
        body: JSON.stringify(data)
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export function useSetVibeInputSelection(options?: {
    mutation?: UseMutationOptions<{
        data: VibeInputOut[];
    }, ApiError, {
        params: SetVibeInputSelectionParams;
        data: VibeInputSelectionIn;
    }>;
}) {
    return useMutation({
        mutationFn: (vars)=>setVibeInputSelection(vars.params, vars.data),
        ...options?.mutation
    });
}
export interface GetVibeInputParams {
    business_id: string;
    input_id: string;
    "X-Forwarded-Host"?: string | null;
    "X-Forwarded-Preferred-Username"?: string | null;
    "X-Forwarded-User"?: string | null;
    "X-Forwarded-Email"?: string | null;
    "X-Request-Id"?: string | null;
    "X-Forwarded-Access-Token"?: string | null;
}
export const getVibeInput = async (params: GetVibeInputParams, options?: RequestInit): Promise<{
    data: VibeInputOut;
}> =>{
    const res = await fetch(`/api/businesses/${params.business_id}/inputs/${params.input_id}`, {
        ...options,
        method: "GET",
        headers: {
            ...(params?.["X-Forwarded-Host"] != null && {
                "X-Forwarded-Host": params["X-Forwarded-Host"]
            }),
            ...(params?.["X-Forwarded-Preferred-Username"] != null && {
                "X-Forwarded-Preferred-Username": params["X-Forwarded-Preferred-Username"]
            }),
            ...(params?.["X-Forwarded-User"] != null && {
                "X-Forwarded-User": params["X-Forwarded-User"]
            }),
            ...(params?.["X-Forwarded-Email"] != null && {
                "X-Forwarded-Email": params["X-Forwarded-Email"]
            }),
            ...(params?.["X-Request-Id"] != null && {
                "X-Request-Id": params["X-Request-Id"]
            }),
            ...(params?.["X-Forwarded-Access-Token"] != null && {
                "X-Forwarded-Access-Token": params["X-Forwarded-Access-Token"]
            }),
            ...options?.headers
        }
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export const getVibeInputKey = (params?: GetVibeInputParams)=>{
    return [
        "/api/businesses/{business_id}/inputs/{input_id}",
        params
    ] as const;
};
export function useGetVibeInput<TData = {
    data: VibeInputOut;
}>(options: {
    params: GetVibeInputParams;
    query?: Omit<UseQueryOptions<{
        data: VibeInputOut;
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useQuery({
        queryKey: getVibeInputKey(options.params),
        queryFn: ()=>getVibeInput(options.params),
        ...options?.query
    });
}
export function useGetVibeInputSuspense<TData = {
    data: VibeInputOut;
}>(options: {
    params: GetVibeInputParams;
    query?: Omit<UseSuspenseQueryOptions<{
        data: VibeInputOut;
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useSuspenseQuery({
        queryKey: getVibeInputKey(options.params),
        queryFn: ()=>getVibeInput(options.params),
        ...options?.query
    });
}
export interface UpdateVibeInputParams {
    business_id: string;
    input_id: string;
    "X-Forwarded-Host"?: string | null;
    "X-Forwarded-Preferred-Username"?: string | null;
    "X-Forwarded-User"?: string | null;
    "X-Forwarded-Email"?: string | null;
    "X-Request-Id"?: string | null;
    "X-Forwarded-Access-Token"?: string | null;
}
export const updateVibeInput = async (params: UpdateVibeInputParams, data: VibeInputPatchIn, options?: RequestInit): Promise<{
    data: VibeInputOut;
}> =>{
    const res = await fetch(`/api/businesses/${params.business_id}/inputs/${params.input_id}`, {
        ...options,
        method: "PATCH",
        headers: {
            "Content-Type": "application/json",
            ...(params?.["X-Forwarded-Host"] != null && {
                "X-Forwarded-Host": params["X-Forwarded-Host"]
            }),
            ...(params?.["X-Forwarded-Preferred-Username"] != null && {
                "X-Forwarded-Preferred-Username": params["X-Forwarded-Preferred-Username"]
            }),
            ...(params?.["X-Forwarded-User"] != null && {
                "X-Forwarded-User": params["X-Forwarded-User"]
            }),
            ...(params?.["X-Forwarded-Email"] != null && {
                "X-Forwarded-Email": params["X-Forwarded-Email"]
            }),
            ...(params?.["X-Request-Id"] != null && {
                "X-Request-Id": params["X-Request-Id"]
            }),
            ...(params?.["X-Forwarded-Access-Token"] != null && {
                "X-Forwarded-Access-Token": params["X-Forwarded-Access-Token"]
            }),
            ...options?.headers
        },
        body: JSON.stringify(data)
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export function useUpdateVibeInput(options?: {
    mutation?: UseMutationOptions<{
        data: VibeInputOut;
    }, ApiError, {
        params: UpdateVibeInputParams;
        data: VibeInputPatchIn;
    }>;
}) {
    return useMutation({
        mutationFn: (vars)=>updateVibeInput(vars.params, vars.data),
        ...options?.mutation
    });
}
export interface DeleteVibeInputParams {
    business_id: string;
    input_id: string;
    "X-Forwarded-Host"?: string | null;
    "X-Forwarded-Preferred-Username"?: string | null;
    "X-Forwarded-User"?: string | null;
    "X-Forwarded-Email"?: string | null;
    "X-Request-Id"?: string | null;
    "X-Forwarded-Access-Token"?: string | null;
}
export const deleteVibeInput = async (params: DeleteVibeInputParams, options?: RequestInit): Promise<{
    data: Record<string, unknown>;
}> =>{
    const res = await fetch(`/api/businesses/${params.business_id}/inputs/${params.input_id}`, {
        ...options,
        method: "DELETE",
        headers: {
            ...(params?.["X-Forwarded-Host"] != null && {
                "X-Forwarded-Host": params["X-Forwarded-Host"]
            }),
            ...(params?.["X-Forwarded-Preferred-Username"] != null && {
                "X-Forwarded-Preferred-Username": params["X-Forwarded-Preferred-Username"]
            }),
            ...(params?.["X-Forwarded-User"] != null && {
                "X-Forwarded-User": params["X-Forwarded-User"]
            }),
            ...(params?.["X-Forwarded-Email"] != null && {
                "X-Forwarded-Email": params["X-Forwarded-Email"]
            }),
            ...(params?.["X-Request-Id"] != null && {
                "X-Request-Id": params["X-Request-Id"]
            }),
            ...(params?.["X-Forwarded-Access-Token"] != null && {
                "X-Forwarded-Access-Token": params["X-Forwarded-Access-Token"]
            }),
            ...options?.headers
        }
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export function useDeleteVibeInput(options?: {
    mutation?: UseMutationOptions<{
        data: Record<string, unknown>;
    }, ApiError, {
        params: DeleteVibeInputParams;
    }>;
}) {
    return useMutation({
        mutationFn: (vars)=>deleteVibeInput(vars.params),
        ...options?.mutation
    });
}
export interface ConsumeVibeInputParams {
    business_id: string;
    input_id: string;
    "X-Forwarded-Host"?: string | null;
    "X-Forwarded-Preferred-Username"?: string | null;
    "X-Forwarded-User"?: string | null;
    "X-Forwarded-Email"?: string | null;
    "X-Request-Id"?: string | null;
    "X-Forwarded-Access-Token"?: string | null;
}
export const consumeVibeInput = async (params: ConsumeVibeInputParams, options?: RequestInit): Promise<{
    data: VibeInputOut;
}> =>{
    const res = await fetch(`/api/businesses/${params.business_id}/inputs/${params.input_id}/consume`, {
        ...options,
        method: "POST",
        headers: {
            ...(params?.["X-Forwarded-Host"] != null && {
                "X-Forwarded-Host": params["X-Forwarded-Host"]
            }),
            ...(params?.["X-Forwarded-Preferred-Username"] != null && {
                "X-Forwarded-Preferred-Username": params["X-Forwarded-Preferred-Username"]
            }),
            ...(params?.["X-Forwarded-User"] != null && {
                "X-Forwarded-User": params["X-Forwarded-User"]
            }),
            ...(params?.["X-Forwarded-Email"] != null && {
                "X-Forwarded-Email": params["X-Forwarded-Email"]
            }),
            ...(params?.["X-Request-Id"] != null && {
                "X-Request-Id": params["X-Request-Id"]
            }),
            ...(params?.["X-Forwarded-Access-Token"] != null && {
                "X-Forwarded-Access-Token": params["X-Forwarded-Access-Token"]
            }),
            ...options?.headers
        }
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export function useConsumeVibeInput(options?: {
    mutation?: UseMutationOptions<{
        data: VibeInputOut;
    }, ApiError, {
        params: ConsumeVibeInputParams;
    }>;
}) {
    return useMutation({
        mutationFn: (vars)=>consumeVibeInput(vars.params),
        ...options?.mutation
    });
}
export interface ListVibeInputLinksParams {
    business_id: string;
    input_id: string;
    "X-Forwarded-Host"?: string | null;
    "X-Forwarded-Preferred-Username"?: string | null;
    "X-Forwarded-User"?: string | null;
    "X-Forwarded-Email"?: string | null;
    "X-Request-Id"?: string | null;
    "X-Forwarded-Access-Token"?: string | null;
}
export const listVibeInputLinks = async (params: ListVibeInputLinksParams, options?: RequestInit): Promise<{
    data: VibeInputContextLinkOut[];
}> =>{
    const res = await fetch(`/api/businesses/${params.business_id}/inputs/${params.input_id}/links`, {
        ...options,
        method: "GET",
        headers: {
            ...(params?.["X-Forwarded-Host"] != null && {
                "X-Forwarded-Host": params["X-Forwarded-Host"]
            }),
            ...(params?.["X-Forwarded-Preferred-Username"] != null && {
                "X-Forwarded-Preferred-Username": params["X-Forwarded-Preferred-Username"]
            }),
            ...(params?.["X-Forwarded-User"] != null && {
                "X-Forwarded-User": params["X-Forwarded-User"]
            }),
            ...(params?.["X-Forwarded-Email"] != null && {
                "X-Forwarded-Email": params["X-Forwarded-Email"]
            }),
            ...(params?.["X-Request-Id"] != null && {
                "X-Request-Id": params["X-Request-Id"]
            }),
            ...(params?.["X-Forwarded-Access-Token"] != null && {
                "X-Forwarded-Access-Token": params["X-Forwarded-Access-Token"]
            }),
            ...options?.headers
        }
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export const listVibeInputLinksKey = (params?: ListVibeInputLinksParams)=>{
    return [
        "/api/businesses/{business_id}/inputs/{input_id}/links",
        params
    ] as const;
};
export function useListVibeInputLinks<TData = {
    data: VibeInputContextLinkOut[];
}>(options: {
    params: ListVibeInputLinksParams;
    query?: Omit<UseQueryOptions<{
        data: VibeInputContextLinkOut[];
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useQuery({
        queryKey: listVibeInputLinksKey(options.params),
        queryFn: ()=>listVibeInputLinks(options.params),
        ...options?.query
    });
}
export function useListVibeInputLinksSuspense<TData = {
    data: VibeInputContextLinkOut[];
}>(options: {
    params: ListVibeInputLinksParams;
    query?: Omit<UseSuspenseQueryOptions<{
        data: VibeInputContextLinkOut[];
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useSuspenseQuery({
        queryKey: listVibeInputLinksKey(options.params),
        queryFn: ()=>listVibeInputLinks(options.params),
        ...options?.query
    });
}
export interface AddVibeInputLinkParams {
    business_id: string;
    input_id: string;
    "X-Forwarded-Host"?: string | null;
    "X-Forwarded-Preferred-Username"?: string | null;
    "X-Forwarded-User"?: string | null;
    "X-Forwarded-Email"?: string | null;
    "X-Request-Id"?: string | null;
    "X-Forwarded-Access-Token"?: string | null;
}
export const addVibeInputLink = async (params: AddVibeInputLinkParams, data: VibeInputContextLinkIn, options?: RequestInit): Promise<{
    data: VibeInputContextLinkOut;
}> =>{
    const res = await fetch(`/api/businesses/${params.business_id}/inputs/${params.input_id}/links`, {
        ...options,
        method: "POST",
        headers: {
            "Content-Type": "application/json",
            ...(params?.["X-Forwarded-Host"] != null && {
                "X-Forwarded-Host": params["X-Forwarded-Host"]
            }),
            ...(params?.["X-Forwarded-Preferred-Username"] != null && {
                "X-Forwarded-Preferred-Username": params["X-Forwarded-Preferred-Username"]
            }),
            ...(params?.["X-Forwarded-User"] != null && {
                "X-Forwarded-User": params["X-Forwarded-User"]
            }),
            ...(params?.["X-Forwarded-Email"] != null && {
                "X-Forwarded-Email": params["X-Forwarded-Email"]
            }),
            ...(params?.["X-Request-Id"] != null && {
                "X-Request-Id": params["X-Request-Id"]
            }),
            ...(params?.["X-Forwarded-Access-Token"] != null && {
                "X-Forwarded-Access-Token": params["X-Forwarded-Access-Token"]
            }),
            ...options?.headers
        },
        body: JSON.stringify(data)
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export function useAddVibeInputLink(options?: {
    mutation?: UseMutationOptions<{
        data: VibeInputContextLinkOut;
    }, ApiError, {
        params: AddVibeInputLinkParams;
        data: VibeInputContextLinkIn;
    }>;
}) {
    return useMutation({
        mutationFn: (vars)=>addVibeInputLink(vars.params, vars.data),
        ...options?.mutation
    });
}
export interface RestoreVibeInputParams {
    business_id: string;
    input_id: string;
    "X-Forwarded-Host"?: string | null;
    "X-Forwarded-Preferred-Username"?: string | null;
    "X-Forwarded-User"?: string | null;
    "X-Forwarded-Email"?: string | null;
    "X-Request-Id"?: string | null;
    "X-Forwarded-Access-Token"?: string | null;
}
export const restoreVibeInput = async (params: RestoreVibeInputParams, options?: RequestInit): Promise<{
    data: VibeInputOut;
}> =>{
    const res = await fetch(`/api/businesses/${params.business_id}/inputs/${params.input_id}/restore`, {
        ...options,
        method: "POST",
        headers: {
            ...(params?.["X-Forwarded-Host"] != null && {
                "X-Forwarded-Host": params["X-Forwarded-Host"]
            }),
            ...(params?.["X-Forwarded-Preferred-Username"] != null && {
                "X-Forwarded-Preferred-Username": params["X-Forwarded-Preferred-Username"]
            }),
            ...(params?.["X-Forwarded-User"] != null && {
                "X-Forwarded-User": params["X-Forwarded-User"]
            }),
            ...(params?.["X-Forwarded-Email"] != null && {
                "X-Forwarded-Email": params["X-Forwarded-Email"]
            }),
            ...(params?.["X-Request-Id"] != null && {
                "X-Request-Id": params["X-Request-Id"]
            }),
            ...(params?.["X-Forwarded-Access-Token"] != null && {
                "X-Forwarded-Access-Token": params["X-Forwarded-Access-Token"]
            }),
            ...options?.headers
        }
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export function useRestoreVibeInput(options?: {
    mutation?: UseMutationOptions<{
        data: VibeInputOut;
    }, ApiError, {
        params: RestoreVibeInputParams;
    }>;
}) {
    return useMutation({
        mutationFn: (vars)=>restoreVibeInput(vars.params),
        ...options?.mutation
    });
}
export interface UnconsumeVibeInputParams {
    business_id: string;
    input_id: string;
    "X-Forwarded-Host"?: string | null;
    "X-Forwarded-Preferred-Username"?: string | null;
    "X-Forwarded-User"?: string | null;
    "X-Forwarded-Email"?: string | null;
    "X-Request-Id"?: string | null;
    "X-Forwarded-Access-Token"?: string | null;
}
export const unconsumeVibeInput = async (params: UnconsumeVibeInputParams, options?: RequestInit): Promise<{
    data: VibeInputOut;
}> =>{
    const res = await fetch(`/api/businesses/${params.business_id}/inputs/${params.input_id}/unconsume`, {
        ...options,
        method: "POST",
        headers: {
            ...(params?.["X-Forwarded-Host"] != null && {
                "X-Forwarded-Host": params["X-Forwarded-Host"]
            }),
            ...(params?.["X-Forwarded-Preferred-Username"] != null && {
                "X-Forwarded-Preferred-Username": params["X-Forwarded-Preferred-Username"]
            }),
            ...(params?.["X-Forwarded-User"] != null && {
                "X-Forwarded-User": params["X-Forwarded-User"]
            }),
            ...(params?.["X-Forwarded-Email"] != null && {
                "X-Forwarded-Email": params["X-Forwarded-Email"]
            }),
            ...(params?.["X-Request-Id"] != null && {
                "X-Request-Id": params["X-Request-Id"]
            }),
            ...(params?.["X-Forwarded-Access-Token"] != null && {
                "X-Forwarded-Access-Token": params["X-Forwarded-Access-Token"]
            }),
            ...options?.headers
        }
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export function useUnconsumeVibeInput(options?: {
    mutation?: UseMutationOptions<{
        data: VibeInputOut;
    }, ApiError, {
        params: UnconsumeVibeInputParams;
    }>;
}) {
    return useMutation({
        mutationFn: (vars)=>unconsumeVibeInput(vars.params),
        ...options?.mutation
    });
}
export interface GetReviewQueueParams {
    business_id: string;
    version_id?: string | null;
    "X-Forwarded-Host"?: string | null;
    "X-Forwarded-Preferred-Username"?: string | null;
    "X-Forwarded-User"?: string | null;
    "X-Forwarded-Email"?: string | null;
    "X-Request-Id"?: string | null;
    "X-Forwarded-Access-Token"?: string | null;
}
export const getReviewQueue = async (params: GetReviewQueueParams, options?: RequestInit): Promise<{
    data: ReviewQueueOut;
}> =>{
    const searchParams = new URLSearchParams();
    if (params?.version_id != null) searchParams.set("version_id", String(params?.version_id));
    const queryString = searchParams.toString();
    const url = queryString ? `/api/businesses/${params.business_id}/links/review-queue?${queryString}` : `/api/businesses/${params.business_id}/links/review-queue`;
    const res = await fetch(url, {
        ...options,
        method: "GET",
        headers: {
            ...(params?.["X-Forwarded-Host"] != null && {
                "X-Forwarded-Host": params["X-Forwarded-Host"]
            }),
            ...(params?.["X-Forwarded-Preferred-Username"] != null && {
                "X-Forwarded-Preferred-Username": params["X-Forwarded-Preferred-Username"]
            }),
            ...(params?.["X-Forwarded-User"] != null && {
                "X-Forwarded-User": params["X-Forwarded-User"]
            }),
            ...(params?.["X-Forwarded-Email"] != null && {
                "X-Forwarded-Email": params["X-Forwarded-Email"]
            }),
            ...(params?.["X-Request-Id"] != null && {
                "X-Request-Id": params["X-Request-Id"]
            }),
            ...(params?.["X-Forwarded-Access-Token"] != null && {
                "X-Forwarded-Access-Token": params["X-Forwarded-Access-Token"]
            }),
            ...options?.headers
        }
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export const getReviewQueueKey = (params?: GetReviewQueueParams)=>{
    return [
        "/api/businesses/{business_id}/links/review-queue",
        params
    ] as const;
};
export function useGetReviewQueue<TData = {
    data: ReviewQueueOut;
}>(options: {
    params: GetReviewQueueParams;
    query?: Omit<UseQueryOptions<{
        data: ReviewQueueOut;
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useQuery({
        queryKey: getReviewQueueKey(options.params),
        queryFn: ()=>getReviewQueue(options.params),
        ...options?.query
    });
}
export function useGetReviewQueueSuspense<TData = {
    data: ReviewQueueOut;
}>(options: {
    params: GetReviewQueueParams;
    query?: Omit<UseSuspenseQueryOptions<{
        data: ReviewQueueOut;
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useSuspenseQuery({
        queryKey: getReviewQueueKey(options.params),
        queryFn: ()=>getReviewQueue(options.params),
        ...options?.query
    });
}
export interface AcceptReviewLinkParams {
    business_id: string;
    link_id: string;
    "X-Forwarded-Host"?: string | null;
    "X-Forwarded-Preferred-Username"?: string | null;
    "X-Forwarded-User"?: string | null;
    "X-Forwarded-Email"?: string | null;
    "X-Request-Id"?: string | null;
    "X-Forwarded-Access-Token"?: string | null;
}
export const acceptReviewLink = async (params: AcceptReviewLinkParams, options?: RequestInit): Promise<{
    data: VibeInputContextLinkOut;
}> =>{
    const res = await fetch(`/api/businesses/${params.business_id}/links/${params.link_id}/review/accept`, {
        ...options,
        method: "POST",
        headers: {
            ...(params?.["X-Forwarded-Host"] != null && {
                "X-Forwarded-Host": params["X-Forwarded-Host"]
            }),
            ...(params?.["X-Forwarded-Preferred-Username"] != null && {
                "X-Forwarded-Preferred-Username": params["X-Forwarded-Preferred-Username"]
            }),
            ...(params?.["X-Forwarded-User"] != null && {
                "X-Forwarded-User": params["X-Forwarded-User"]
            }),
            ...(params?.["X-Forwarded-Email"] != null && {
                "X-Forwarded-Email": params["X-Forwarded-Email"]
            }),
            ...(params?.["X-Request-Id"] != null && {
                "X-Request-Id": params["X-Request-Id"]
            }),
            ...(params?.["X-Forwarded-Access-Token"] != null && {
                "X-Forwarded-Access-Token": params["X-Forwarded-Access-Token"]
            }),
            ...options?.headers
        }
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export function useAcceptReviewLink(options?: {
    mutation?: UseMutationOptions<{
        data: VibeInputContextLinkOut;
    }, ApiError, {
        params: AcceptReviewLinkParams;
    }>;
}) {
    return useMutation({
        mutationFn: (vars)=>acceptReviewLink(vars.params),
        ...options?.mutation
    });
}
export interface DismissReviewLinkParams {
    business_id: string;
    link_id: string;
    "X-Forwarded-Host"?: string | null;
    "X-Forwarded-Preferred-Username"?: string | null;
    "X-Forwarded-User"?: string | null;
    "X-Forwarded-Email"?: string | null;
    "X-Request-Id"?: string | null;
    "X-Forwarded-Access-Token"?: string | null;
}
export const dismissReviewLink = async (params: DismissReviewLinkParams, options?: RequestInit): Promise<{
    data: VibeInputOut;
}> =>{
    const res = await fetch(`/api/businesses/${params.business_id}/links/${params.link_id}/review/dismiss`, {
        ...options,
        method: "POST",
        headers: {
            ...(params?.["X-Forwarded-Host"] != null && {
                "X-Forwarded-Host": params["X-Forwarded-Host"]
            }),
            ...(params?.["X-Forwarded-Preferred-Username"] != null && {
                "X-Forwarded-Preferred-Username": params["X-Forwarded-Preferred-Username"]
            }),
            ...(params?.["X-Forwarded-User"] != null && {
                "X-Forwarded-User": params["X-Forwarded-User"]
            }),
            ...(params?.["X-Forwarded-Email"] != null && {
                "X-Forwarded-Email": params["X-Forwarded-Email"]
            }),
            ...(params?.["X-Request-Id"] != null && {
                "X-Request-Id": params["X-Request-Id"]
            }),
            ...(params?.["X-Forwarded-Access-Token"] != null && {
                "X-Forwarded-Access-Token": params["X-Forwarded-Access-Token"]
            }),
            ...options?.headers
        }
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export function useDismissReviewLink(options?: {
    mutation?: UseMutationOptions<{
        data: VibeInputOut;
    }, ApiError, {
        params: DismissReviewLinkParams;
    }>;
}) {
    return useMutation({
        mutationFn: (vars)=>dismissReviewLink(vars.params),
        ...options?.mutation
    });
}
export interface ReanchorReviewLinkParams {
    business_id: string;
    link_id: string;
    "X-Forwarded-Host"?: string | null;
    "X-Forwarded-Preferred-Username"?: string | null;
    "X-Forwarded-User"?: string | null;
    "X-Forwarded-Email"?: string | null;
    "X-Request-Id"?: string | null;
    "X-Forwarded-Access-Token"?: string | null;
}
export const reanchorReviewLink = async (params: ReanchorReviewLinkParams, data: ReanchorIn, options?: RequestInit): Promise<{
    data: VibeInputContextLinkOut;
}> =>{
    const res = await fetch(`/api/businesses/${params.business_id}/links/${params.link_id}/review/reanchor`, {
        ...options,
        method: "POST",
        headers: {
            "Content-Type": "application/json",
            ...(params?.["X-Forwarded-Host"] != null && {
                "X-Forwarded-Host": params["X-Forwarded-Host"]
            }),
            ...(params?.["X-Forwarded-Preferred-Username"] != null && {
                "X-Forwarded-Preferred-Username": params["X-Forwarded-Preferred-Username"]
            }),
            ...(params?.["X-Forwarded-User"] != null && {
                "X-Forwarded-User": params["X-Forwarded-User"]
            }),
            ...(params?.["X-Forwarded-Email"] != null && {
                "X-Forwarded-Email": params["X-Forwarded-Email"]
            }),
            ...(params?.["X-Request-Id"] != null && {
                "X-Request-Id": params["X-Request-Id"]
            }),
            ...(params?.["X-Forwarded-Access-Token"] != null && {
                "X-Forwarded-Access-Token": params["X-Forwarded-Access-Token"]
            }),
            ...options?.headers
        },
        body: JSON.stringify(data)
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export function useReanchorReviewLink(options?: {
    mutation?: UseMutationOptions<{
        data: VibeInputContextLinkOut;
    }, ApiError, {
        params: ReanchorReviewLinkParams;
        data: ReanchorIn;
    }>;
}) {
    return useMutation({
        mutationFn: (vars)=>reanchorReviewLink(vars.params, vars.data),
        ...options?.mutation
    });
}
export interface ListMetamodelCleanupsParams {
    business_id: string;
}
export const listMetamodelCleanups = async (params: ListMetamodelCleanupsParams, options?: RequestInit): Promise<{
    data: MetamodelCleanupOut[];
}> =>{
    const res = await fetch(`/api/businesses/${params.business_id}/metamodel-cleanups`, {
        ...options,
        method: "GET"
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export const listMetamodelCleanupsKey = (params?: ListMetamodelCleanupsParams)=>{
    return [
        "/api/businesses/{business_id}/metamodel-cleanups",
        params
    ] as const;
};
export function useListMetamodelCleanups<TData = {
    data: MetamodelCleanupOut[];
}>(options: {
    params: ListMetamodelCleanupsParams;
    query?: Omit<UseQueryOptions<{
        data: MetamodelCleanupOut[];
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useQuery({
        queryKey: listMetamodelCleanupsKey(options.params),
        queryFn: ()=>listMetamodelCleanups(options.params),
        ...options?.query
    });
}
export function useListMetamodelCleanupsSuspense<TData = {
    data: MetamodelCleanupOut[];
}>(options: {
    params: ListMetamodelCleanupsParams;
    query?: Omit<UseSuspenseQueryOptions<{
        data: MetamodelCleanupOut[];
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useSuspenseQuery({
        queryKey: listMetamodelCleanupsKey(options.params),
        queryFn: ()=>listMetamodelCleanups(options.params),
        ...options?.query
    });
}
export interface RetryMetamodelCleanupParams {
    business_id: string;
    cleanup_id: string;
    "X-Forwarded-Host"?: string | null;
    "X-Forwarded-Preferred-Username"?: string | null;
    "X-Forwarded-User"?: string | null;
    "X-Forwarded-Email"?: string | null;
    "X-Request-Id"?: string | null;
    "X-Forwarded-Access-Token"?: string | null;
}
export const retryMetamodelCleanup = async (params: RetryMetamodelCleanupParams, options?: RequestInit): Promise<{
    data: MetamodelCleanupOut;
}> =>{
    const res = await fetch(`/api/businesses/${params.business_id}/metamodel-cleanups/${params.cleanup_id}/retry`, {
        ...options,
        method: "POST",
        headers: {
            ...(params?.["X-Forwarded-Host"] != null && {
                "X-Forwarded-Host": params["X-Forwarded-Host"]
            }),
            ...(params?.["X-Forwarded-Preferred-Username"] != null && {
                "X-Forwarded-Preferred-Username": params["X-Forwarded-Preferred-Username"]
            }),
            ...(params?.["X-Forwarded-User"] != null && {
                "X-Forwarded-User": params["X-Forwarded-User"]
            }),
            ...(params?.["X-Forwarded-Email"] != null && {
                "X-Forwarded-Email": params["X-Forwarded-Email"]
            }),
            ...(params?.["X-Request-Id"] != null && {
                "X-Request-Id": params["X-Request-Id"]
            }),
            ...(params?.["X-Forwarded-Access-Token"] != null && {
                "X-Forwarded-Access-Token": params["X-Forwarded-Access-Token"]
            }),
            ...options?.headers
        }
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export function useRetryMetamodelCleanup(options?: {
    mutation?: UseMutationOptions<{
        data: MetamodelCleanupOut;
    }, ApiError, {
        params: RetryMetamodelCleanupParams;
    }>;
}) {
    return useMutation({
        mutationFn: (vars)=>retryMetamodelCleanup(vars.params),
        ...options?.mutation
    });
}
export interface ListArtifactsByVersionParams {
    business_id: string;
    model_version_id: string;
}
export const listArtifactsByVersion = async (params: ListArtifactsByVersionParams, options?: RequestInit): Promise<{
    data: RunArtifactOut[];
}> =>{
    const res = await fetch(`/api/businesses/${params.business_id}/model-versions/${params.model_version_id}/artifacts`, {
        ...options,
        method: "GET"
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export const listArtifactsByVersionKey = (params?: ListArtifactsByVersionParams)=>{
    return [
        "/api/businesses/{business_id}/model-versions/{model_version_id}/artifacts",
        params
    ] as const;
};
export function useListArtifactsByVersion<TData = {
    data: RunArtifactOut[];
}>(options: {
    params: ListArtifactsByVersionParams;
    query?: Omit<UseQueryOptions<{
        data: RunArtifactOut[];
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useQuery({
        queryKey: listArtifactsByVersionKey(options.params),
        queryFn: ()=>listArtifactsByVersion(options.params),
        ...options?.query
    });
}
export function useListArtifactsByVersionSuspense<TData = {
    data: RunArtifactOut[];
}>(options: {
    params: ListArtifactsByVersionParams;
    query?: Omit<UseSuspenseQueryOptions<{
        data: RunArtifactOut[];
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useSuspenseQuery({
        queryKey: listArtifactsByVersionKey(options.params),
        queryFn: ()=>listArtifactsByVersion(options.params),
        ...options?.query
    });
}
export interface DownloadAllArtifactsByVersionParams {
    business_id: string;
    model_version_id: string;
}
export const downloadAllArtifactsByVersion = async (params: DownloadAllArtifactsByVersionParams, options?: RequestInit): Promise<{
    data: unknown;
}> =>{
    const res = await fetch(`/api/businesses/${params.business_id}/model-versions/${params.model_version_id}/artifacts/download`, {
        ...options,
        method: "GET"
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export const downloadAllArtifactsByVersionKey = (params?: DownloadAllArtifactsByVersionParams)=>{
    return [
        "/api/businesses/{business_id}/model-versions/{model_version_id}/artifacts/download",
        params
    ] as const;
};
export function useDownloadAllArtifactsByVersion<TData = {
    data: unknown;
}>(options: {
    params: DownloadAllArtifactsByVersionParams;
    query?: Omit<UseQueryOptions<{
        data: unknown;
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useQuery({
        queryKey: downloadAllArtifactsByVersionKey(options.params),
        queryFn: ()=>downloadAllArtifactsByVersion(options.params),
        ...options?.query
    });
}
export function useDownloadAllArtifactsByVersionSuspense<TData = {
    data: unknown;
}>(options: {
    params: DownloadAllArtifactsByVersionParams;
    query?: Omit<UseSuspenseQueryOptions<{
        data: unknown;
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useSuspenseQuery({
        queryKey: downloadAllArtifactsByVersionKey(options.params),
        queryFn: ()=>downloadAllArtifactsByVersion(options.params),
        ...options?.query
    });
}
export interface GetArtifactContentByVersionParams {
    business_id: string;
    model_version_id: string;
    artifact_id: string;
    format?: "text" | "hex";
}
export const getArtifactContentByVersion = async (params: GetArtifactContentByVersionParams, options?: RequestInit): Promise<{
    data: Record<string, unknown>;
}> =>{
    const searchParams = new URLSearchParams();
    if (params?.format != null) searchParams.set("format", String(params?.format));
    const queryString = searchParams.toString();
    const url = queryString ? `/api/businesses/${params.business_id}/model-versions/${params.model_version_id}/artifacts/${params.artifact_id}/content?${queryString}` : `/api/businesses/${params.business_id}/model-versions/${params.model_version_id}/artifacts/${params.artifact_id}/content`;
    const res = await fetch(url, {
        ...options,
        method: "GET"
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export const getArtifactContentByVersionKey = (params?: GetArtifactContentByVersionParams)=>{
    return [
        "/api/businesses/{business_id}/model-versions/{model_version_id}/artifacts/{artifact_id}/content",
        params
    ] as const;
};
export function useGetArtifactContentByVersion<TData = {
    data: Record<string, unknown>;
}>(options: {
    params: GetArtifactContentByVersionParams;
    query?: Omit<UseQueryOptions<{
        data: Record<string, unknown>;
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useQuery({
        queryKey: getArtifactContentByVersionKey(options.params),
        queryFn: ()=>getArtifactContentByVersion(options.params),
        ...options?.query
    });
}
export function useGetArtifactContentByVersionSuspense<TData = {
    data: Record<string, unknown>;
}>(options: {
    params: GetArtifactContentByVersionParams;
    query?: Omit<UseSuspenseQueryOptions<{
        data: Record<string, unknown>;
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useSuspenseQuery({
        queryKey: getArtifactContentByVersionKey(options.params),
        queryFn: ()=>getArtifactContentByVersion(options.params),
        ...options?.query
    });
}
export interface DownloadArtifactByVersionParams {
    business_id: string;
    model_version_id: string;
    artifact_id: string;
    inline?: boolean;
}
export const downloadArtifactByVersion = async (params: DownloadArtifactByVersionParams, options?: RequestInit): Promise<{
    data: unknown;
}> =>{
    const searchParams = new URLSearchParams();
    if (params?.inline != null) searchParams.set("inline", String(params?.inline));
    const queryString = searchParams.toString();
    const url = queryString ? `/api/businesses/${params.business_id}/model-versions/${params.model_version_id}/artifacts/${params.artifact_id}/download?${queryString}` : `/api/businesses/${params.business_id}/model-versions/${params.model_version_id}/artifacts/${params.artifact_id}/download`;
    const res = await fetch(url, {
        ...options,
        method: "GET"
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export const downloadArtifactByVersionKey = (params?: DownloadArtifactByVersionParams)=>{
    return [
        "/api/businesses/{business_id}/model-versions/{model_version_id}/artifacts/{artifact_id}/download",
        params
    ] as const;
};
export function useDownloadArtifactByVersion<TData = {
    data: unknown;
}>(options: {
    params: DownloadArtifactByVersionParams;
    query?: Omit<UseQueryOptions<{
        data: unknown;
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useQuery({
        queryKey: downloadArtifactByVersionKey(options.params),
        queryFn: ()=>downloadArtifactByVersion(options.params),
        ...options?.query
    });
}
export function useDownloadArtifactByVersionSuspense<TData = {
    data: unknown;
}>(options: {
    params: DownloadArtifactByVersionParams;
    query?: Omit<UseSuspenseQueryOptions<{
        data: unknown;
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useSuspenseQuery({
        queryKey: downloadArtifactByVersionKey(options.params),
        queryFn: ()=>downloadArtifactByVersion(options.params),
        ...options?.query
    });
}
export interface ExportModelJsonParams {
    business_id: string;
    model_version_id: string;
}
export const exportModelJson = async (params: ExportModelJsonParams, options?: RequestInit): Promise<{
    data: Record<string, unknown>;
}> =>{
    const res = await fetch(`/api/businesses/${params.business_id}/model-versions/${params.model_version_id}/export`, {
        ...options,
        method: "GET"
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export const exportModelJsonKey = (params?: ExportModelJsonParams)=>{
    return [
        "/api/businesses/{business_id}/model-versions/{model_version_id}/export",
        params
    ] as const;
};
export function useExportModelJson<TData = {
    data: Record<string, unknown>;
}>(options: {
    params: ExportModelJsonParams;
    query?: Omit<UseQueryOptions<{
        data: Record<string, unknown>;
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useQuery({
        queryKey: exportModelJsonKey(options.params),
        queryFn: ()=>exportModelJson(options.params),
        ...options?.query
    });
}
export function useExportModelJsonSuspense<TData = {
    data: Record<string, unknown>;
}>(options: {
    params: ExportModelJsonParams;
    query?: Omit<UseSuspenseQueryOptions<{
        data: Record<string, unknown>;
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useSuspenseQuery({
        queryKey: exportModelJsonKey(options.params),
        queryFn: ()=>exportModelJson(options.params),
        ...options?.query
    });
}
export interface ExportModelBundleParams {
    business_id: string;
    model_version_id: string;
}
export const exportModelBundle = async (params: ExportModelBundleParams, options?: RequestInit): Promise<{
    data: unknown;
}> =>{
    const res = await fetch(`/api/businesses/${params.business_id}/model-versions/${params.model_version_id}/export/bundle`, {
        ...options,
        method: "GET"
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export const exportModelBundleKey = (params?: ExportModelBundleParams)=>{
    return [
        "/api/businesses/{business_id}/model-versions/{model_version_id}/export/bundle",
        params
    ] as const;
};
export function useExportModelBundle<TData = {
    data: unknown;
}>(options: {
    params: ExportModelBundleParams;
    query?: Omit<UseQueryOptions<{
        data: unknown;
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useQuery({
        queryKey: exportModelBundleKey(options.params),
        queryFn: ()=>exportModelBundle(options.params),
        ...options?.query
    });
}
export function useExportModelBundleSuspense<TData = {
    data: unknown;
}>(options: {
    params: ExportModelBundleParams;
    query?: Omit<UseSuspenseQueryOptions<{
        data: unknown;
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useSuspenseQuery({
        queryKey: exportModelBundleKey(options.params),
        queryFn: ()=>exportModelBundle(options.params),
        ...options?.query
    });
}
export interface GetRunDefaultsParams {
    business_id: string;
    model_version_id: string;
}
export const getRunDefaults = async (params: GetRunDefaultsParams, options?: RequestInit): Promise<{
    data: RunDefaultsOut;
}> =>{
    const res = await fetch(`/api/businesses/${params.business_id}/model-versions/${params.model_version_id}/run-defaults`, {
        ...options,
        method: "GET"
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export const getRunDefaultsKey = (params?: GetRunDefaultsParams)=>{
    return [
        "/api/businesses/{business_id}/model-versions/{model_version_id}/run-defaults",
        params
    ] as const;
};
export function useGetRunDefaults<TData = {
    data: RunDefaultsOut;
}>(options: {
    params: GetRunDefaultsParams;
    query?: Omit<UseQueryOptions<{
        data: RunDefaultsOut;
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useQuery({
        queryKey: getRunDefaultsKey(options.params),
        queryFn: ()=>getRunDefaults(options.params),
        ...options?.query
    });
}
export function useGetRunDefaultsSuspense<TData = {
    data: RunDefaultsOut;
}>(options: {
    params: GetRunDefaultsParams;
    query?: Omit<UseSuspenseQueryOptions<{
        data: RunDefaultsOut;
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useSuspenseQuery({
        queryKey: getRunDefaultsKey(options.params),
        queryFn: ()=>getRunDefaults(options.params),
        ...options?.query
    });
}
export interface PublishModelVersionParams {
    business_id: string;
    version_id: string;
    "X-Forwarded-Host"?: string | null;
    "X-Forwarded-Preferred-Username"?: string | null;
    "X-Forwarded-User"?: string | null;
    "X-Forwarded-Email"?: string | null;
    "X-Request-Id"?: string | null;
    "X-Forwarded-Access-Token"?: string | null;
}
export const publishModelVersion = async (params: PublishModelVersionParams, data: PublishModelVersionIn, options?: RequestInit): Promise<{
    data: PublishModelVersionOut;
}> =>{
    const res = await fetch(`/api/businesses/${params.business_id}/model-versions/${params.version_id}/publish`, {
        ...options,
        method: "POST",
        headers: {
            "Content-Type": "application/json",
            ...(params?.["X-Forwarded-Host"] != null && {
                "X-Forwarded-Host": params["X-Forwarded-Host"]
            }),
            ...(params?.["X-Forwarded-Preferred-Username"] != null && {
                "X-Forwarded-Preferred-Username": params["X-Forwarded-Preferred-Username"]
            }),
            ...(params?.["X-Forwarded-User"] != null && {
                "X-Forwarded-User": params["X-Forwarded-User"]
            }),
            ...(params?.["X-Forwarded-Email"] != null && {
                "X-Forwarded-Email": params["X-Forwarded-Email"]
            }),
            ...(params?.["X-Request-Id"] != null && {
                "X-Request-Id": params["X-Request-Id"]
            }),
            ...(params?.["X-Forwarded-Access-Token"] != null && {
                "X-Forwarded-Access-Token": params["X-Forwarded-Access-Token"]
            }),
            ...options?.headers
        },
        body: JSON.stringify(data)
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export function usePublishModelVersion(options?: {
    mutation?: UseMutationOptions<{
        data: PublishModelVersionOut;
    }, ApiError, {
        params: PublishModelVersionParams;
        data: PublishModelVersionIn;
    }>;
}) {
    return useMutation({
        mutationFn: (vars)=>publishModelVersion(vars.params, vars.data),
        ...options?.mutation
    });
}
export interface PreviewPublishModelVersionParams {
    business_id: string;
    version_id: string;
    "X-Forwarded-Host"?: string | null;
    "X-Forwarded-Preferred-Username"?: string | null;
    "X-Forwarded-User"?: string | null;
    "X-Forwarded-Email"?: string | null;
    "X-Request-Id"?: string | null;
    "X-Forwarded-Access-Token"?: string | null;
}
export const previewPublishModelVersion = async (params: PreviewPublishModelVersionParams, data: PublishPreviewIn, options?: RequestInit): Promise<{
    data: PublishPreviewOut;
}> =>{
    const res = await fetch(`/api/businesses/${params.business_id}/model-versions/${params.version_id}/publish-preview`, {
        ...options,
        method: "POST",
        headers: {
            "Content-Type": "application/json",
            ...(params?.["X-Forwarded-Host"] != null && {
                "X-Forwarded-Host": params["X-Forwarded-Host"]
            }),
            ...(params?.["X-Forwarded-Preferred-Username"] != null && {
                "X-Forwarded-Preferred-Username": params["X-Forwarded-Preferred-Username"]
            }),
            ...(params?.["X-Forwarded-User"] != null && {
                "X-Forwarded-User": params["X-Forwarded-User"]
            }),
            ...(params?.["X-Forwarded-Email"] != null && {
                "X-Forwarded-Email": params["X-Forwarded-Email"]
            }),
            ...(params?.["X-Request-Id"] != null && {
                "X-Request-Id": params["X-Request-Id"]
            }),
            ...(params?.["X-Forwarded-Access-Token"] != null && {
                "X-Forwarded-Access-Token": params["X-Forwarded-Access-Token"]
            }),
            ...options?.headers
        },
        body: JSON.stringify(data)
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export function usePreviewPublishModelVersion(options?: {
    mutation?: UseMutationOptions<{
        data: PublishPreviewOut;
    }, ApiError, {
        params: PreviewPublishModelVersionParams;
        data: PublishPreviewIn;
    }>;
}) {
    return useMutation({
        mutationFn: (vars)=>previewPublishModelVersion(vars.params, vars.data),
        ...options?.mutation
    });
}
export interface ImportOobVersionsForBusinessParams {
    business_id: string;
    "X-Forwarded-Host"?: string | null;
    "X-Forwarded-Preferred-Username"?: string | null;
    "X-Forwarded-User"?: string | null;
    "X-Forwarded-Email"?: string | null;
    "X-Request-Id"?: string | null;
    "X-Forwarded-Access-Token"?: string | null;
}
export const importOobVersionsForBusiness = async (params: ImportOobVersionsForBusinessParams, options?: RequestInit): Promise<{
    data: OobImportOut;
}> =>{
    const res = await fetch(`/api/businesses/${params.business_id}/oob/import`, {
        ...options,
        method: "POST",
        headers: {
            ...(params?.["X-Forwarded-Host"] != null && {
                "X-Forwarded-Host": params["X-Forwarded-Host"]
            }),
            ...(params?.["X-Forwarded-Preferred-Username"] != null && {
                "X-Forwarded-Preferred-Username": params["X-Forwarded-Preferred-Username"]
            }),
            ...(params?.["X-Forwarded-User"] != null && {
                "X-Forwarded-User": params["X-Forwarded-User"]
            }),
            ...(params?.["X-Forwarded-Email"] != null && {
                "X-Forwarded-Email": params["X-Forwarded-Email"]
            }),
            ...(params?.["X-Request-Id"] != null && {
                "X-Request-Id": params["X-Request-Id"]
            }),
            ...(params?.["X-Forwarded-Access-Token"] != null && {
                "X-Forwarded-Access-Token": params["X-Forwarded-Access-Token"]
            }),
            ...options?.headers
        }
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export function useImportOobVersionsForBusiness(options?: {
    mutation?: UseMutationOptions<{
        data: OobImportOut;
    }, ApiError, {
        params: ImportOobVersionsForBusinessParams;
    }>;
}) {
    return useMutation({
        mutationFn: (vars)=>importOobVersionsForBusiness(vars.params),
        ...options?.mutation
    });
}
export interface ListOrphanSchemasParams {
    business_id: string;
    catalog?: string | null;
    schemas?: string[];
    "X-Forwarded-Host"?: string | null;
    "X-Forwarded-Preferred-Username"?: string | null;
    "X-Forwarded-User"?: string | null;
    "X-Forwarded-Email"?: string | null;
    "X-Request-Id"?: string | null;
    "X-Forwarded-Access-Token"?: string | null;
}
export const listOrphanSchemas = async (params: ListOrphanSchemasParams, options?: RequestInit): Promise<{
    data: OrphanSchemasOut;
}> =>{
    const searchParams = new URLSearchParams();
    if (params?.catalog != null) searchParams.set("catalog", String(params?.catalog));
    if (params?.schemas != null) params?.schemas.forEach((v)=>searchParams.append("schemas", String(v)));
    const queryString = searchParams.toString();
    const url = queryString ? `/api/businesses/${params.business_id}/orphan-schemas?${queryString}` : `/api/businesses/${params.business_id}/orphan-schemas`;
    const res = await fetch(url, {
        ...options,
        method: "GET",
        headers: {
            ...(params?.["X-Forwarded-Host"] != null && {
                "X-Forwarded-Host": params["X-Forwarded-Host"]
            }),
            ...(params?.["X-Forwarded-Preferred-Username"] != null && {
                "X-Forwarded-Preferred-Username": params["X-Forwarded-Preferred-Username"]
            }),
            ...(params?.["X-Forwarded-User"] != null && {
                "X-Forwarded-User": params["X-Forwarded-User"]
            }),
            ...(params?.["X-Forwarded-Email"] != null && {
                "X-Forwarded-Email": params["X-Forwarded-Email"]
            }),
            ...(params?.["X-Request-Id"] != null && {
                "X-Request-Id": params["X-Request-Id"]
            }),
            ...(params?.["X-Forwarded-Access-Token"] != null && {
                "X-Forwarded-Access-Token": params["X-Forwarded-Access-Token"]
            }),
            ...options?.headers
        }
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export const listOrphanSchemasKey = (params?: ListOrphanSchemasParams)=>{
    return [
        "/api/businesses/{business_id}/orphan-schemas",
        params
    ] as const;
};
export function useListOrphanSchemas<TData = {
    data: OrphanSchemasOut;
}>(options: {
    params: ListOrphanSchemasParams;
    query?: Omit<UseQueryOptions<{
        data: OrphanSchemasOut;
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useQuery({
        queryKey: listOrphanSchemasKey(options.params),
        queryFn: ()=>listOrphanSchemas(options.params),
        ...options?.query
    });
}
export function useListOrphanSchemasSuspense<TData = {
    data: OrphanSchemasOut;
}>(options: {
    params: ListOrphanSchemasParams;
    query?: Omit<UseSuspenseQueryOptions<{
        data: OrphanSchemasOut;
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useSuspenseQuery({
        queryKey: listOrphanSchemasKey(options.params),
        queryFn: ()=>listOrphanSchemas(options.params),
        ...options?.query
    });
}
export interface DropOrphanSchemasParams {
    business_id: string;
    "X-Forwarded-Host"?: string | null;
    "X-Forwarded-Preferred-Username"?: string | null;
    "X-Forwarded-User"?: string | null;
    "X-Forwarded-Email"?: string | null;
    "X-Request-Id"?: string | null;
    "X-Forwarded-Access-Token"?: string | null;
}
export const dropOrphanSchemas = async (params: DropOrphanSchemasParams, data: DropOrphanSchemasIn, options?: RequestInit): Promise<{
    data: DropOrphanSchemasOut;
}> =>{
    const res = await fetch(`/api/businesses/${params.business_id}/orphan-schemas/drop`, {
        ...options,
        method: "POST",
        headers: {
            "Content-Type": "application/json",
            ...(params?.["X-Forwarded-Host"] != null && {
                "X-Forwarded-Host": params["X-Forwarded-Host"]
            }),
            ...(params?.["X-Forwarded-Preferred-Username"] != null && {
                "X-Forwarded-Preferred-Username": params["X-Forwarded-Preferred-Username"]
            }),
            ...(params?.["X-Forwarded-User"] != null && {
                "X-Forwarded-User": params["X-Forwarded-User"]
            }),
            ...(params?.["X-Forwarded-Email"] != null && {
                "X-Forwarded-Email": params["X-Forwarded-Email"]
            }),
            ...(params?.["X-Request-Id"] != null && {
                "X-Request-Id": params["X-Request-Id"]
            }),
            ...(params?.["X-Forwarded-Access-Token"] != null && {
                "X-Forwarded-Access-Token": params["X-Forwarded-Access-Token"]
            }),
            ...options?.headers
        },
        body: JSON.stringify(data)
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export function useDropOrphanSchemas(options?: {
    mutation?: UseMutationOptions<{
        data: DropOrphanSchemasOut;
    }, ApiError, {
        params: DropOrphanSchemasParams;
        data: DropOrphanSchemasIn;
    }>;
}) {
    return useMutation({
        mutationFn: (vars)=>dropOrphanSchemas(vars.params, vars.data),
        ...options?.mutation
    });
}
export interface ListRunsParams {
    business_id: string;
}
export const listRuns = async (params: ListRunsParams, options?: RequestInit): Promise<{
    data: RunListOut[];
}> =>{
    const res = await fetch(`/api/businesses/${params.business_id}/runs`, {
        ...options,
        method: "GET"
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export const listRunsKey = (params?: ListRunsParams)=>{
    return [
        "/api/businesses/{business_id}/runs",
        params
    ] as const;
};
export function useListRuns<TData = {
    data: RunListOut[];
}>(options: {
    params: ListRunsParams;
    query?: Omit<UseQueryOptions<{
        data: RunListOut[];
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useQuery({
        queryKey: listRunsKey(options.params),
        queryFn: ()=>listRuns(options.params),
        ...options?.query
    });
}
export function useListRunsSuspense<TData = {
    data: RunListOut[];
}>(options: {
    params: ListRunsParams;
    query?: Omit<UseSuspenseQueryOptions<{
        data: RunListOut[];
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useSuspenseQuery({
        queryKey: listRunsKey(options.params),
        queryFn: ()=>listRuns(options.params),
        ...options?.query
    });
}
export interface CreateRunParams {
    business_id: string;
    "X-Forwarded-Host"?: string | null;
    "X-Forwarded-Preferred-Username"?: string | null;
    "X-Forwarded-User"?: string | null;
    "X-Forwarded-Email"?: string | null;
    "X-Request-Id"?: string | null;
    "X-Forwarded-Access-Token"?: string | null;
}
export const createRun = async (params: CreateRunParams, data: RunIn, options?: RequestInit): Promise<{
    data: RunOut;
}> =>{
    const res = await fetch(`/api/businesses/${params.business_id}/runs`, {
        ...options,
        method: "POST",
        headers: {
            "Content-Type": "application/json",
            ...(params?.["X-Forwarded-Host"] != null && {
                "X-Forwarded-Host": params["X-Forwarded-Host"]
            }),
            ...(params?.["X-Forwarded-Preferred-Username"] != null && {
                "X-Forwarded-Preferred-Username": params["X-Forwarded-Preferred-Username"]
            }),
            ...(params?.["X-Forwarded-User"] != null && {
                "X-Forwarded-User": params["X-Forwarded-User"]
            }),
            ...(params?.["X-Forwarded-Email"] != null && {
                "X-Forwarded-Email": params["X-Forwarded-Email"]
            }),
            ...(params?.["X-Request-Id"] != null && {
                "X-Request-Id": params["X-Request-Id"]
            }),
            ...(params?.["X-Forwarded-Access-Token"] != null && {
                "X-Forwarded-Access-Token": params["X-Forwarded-Access-Token"]
            }),
            ...options?.headers
        },
        body: JSON.stringify(data)
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export function useCreateRun(options?: {
    mutation?: UseMutationOptions<{
        data: RunOut;
    }, ApiError, {
        params: CreateRunParams;
        data: RunIn;
    }>;
}) {
    return useMutation({
        mutationFn: (vars)=>createRun(vars.params, vars.data),
        ...options?.mutation
    });
}
export interface ValidateRunParams {
    business_id: string;
    "X-Forwarded-Host"?: string | null;
    "X-Forwarded-Preferred-Username"?: string | null;
    "X-Forwarded-User"?: string | null;
    "X-Forwarded-Email"?: string | null;
    "X-Request-Id"?: string | null;
    "X-Forwarded-Access-Token"?: string | null;
}
export const validateRun = async (params: ValidateRunParams, data: RunIn, options?: RequestInit): Promise<{
    data: ValidateRunOut;
}> =>{
    const res = await fetch(`/api/businesses/${params.business_id}/runs/validate`, {
        ...options,
        method: "POST",
        headers: {
            "Content-Type": "application/json",
            ...(params?.["X-Forwarded-Host"] != null && {
                "X-Forwarded-Host": params["X-Forwarded-Host"]
            }),
            ...(params?.["X-Forwarded-Preferred-Username"] != null && {
                "X-Forwarded-Preferred-Username": params["X-Forwarded-Preferred-Username"]
            }),
            ...(params?.["X-Forwarded-User"] != null && {
                "X-Forwarded-User": params["X-Forwarded-User"]
            }),
            ...(params?.["X-Forwarded-Email"] != null && {
                "X-Forwarded-Email": params["X-Forwarded-Email"]
            }),
            ...(params?.["X-Request-Id"] != null && {
                "X-Request-Id": params["X-Request-Id"]
            }),
            ...(params?.["X-Forwarded-Access-Token"] != null && {
                "X-Forwarded-Access-Token": params["X-Forwarded-Access-Token"]
            }),
            ...options?.headers
        },
        body: JSON.stringify(data)
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export function useValidateRun(options?: {
    mutation?: UseMutationOptions<{
        data: ValidateRunOut;
    }, ApiError, {
        params: ValidateRunParams;
        data: RunIn;
    }>;
}) {
    return useMutation({
        mutationFn: (vars)=>validateRun(vars.params, vars.data),
        ...options?.mutation
    });
}
export interface GetRunParams {
    business_id: string;
    run_id: string;
}
export const getRun = async (params: GetRunParams, options?: RequestInit): Promise<{
    data: RunOut;
}> =>{
    const res = await fetch(`/api/businesses/${params.business_id}/runs/${params.run_id}`, {
        ...options,
        method: "GET"
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export const getRunKey = (params?: GetRunParams)=>{
    return [
        "/api/businesses/{business_id}/runs/{run_id}",
        params
    ] as const;
};
export function useGetRun<TData = {
    data: RunOut;
}>(options: {
    params: GetRunParams;
    query?: Omit<UseQueryOptions<{
        data: RunOut;
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useQuery({
        queryKey: getRunKey(options.params),
        queryFn: ()=>getRun(options.params),
        ...options?.query
    });
}
export function useGetRunSuspense<TData = {
    data: RunOut;
}>(options: {
    params: GetRunParams;
    query?: Omit<UseSuspenseQueryOptions<{
        data: RunOut;
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useSuspenseQuery({
        queryKey: getRunKey(options.params),
        queryFn: ()=>getRun(options.params),
        ...options?.query
    });
}
export interface DeleteRunParams {
    business_id: string;
    run_id: string;
    "X-Forwarded-Host"?: string | null;
    "X-Forwarded-Preferred-Username"?: string | null;
    "X-Forwarded-User"?: string | null;
    "X-Forwarded-Email"?: string | null;
    "X-Request-Id"?: string | null;
    "X-Forwarded-Access-Token"?: string | null;
}
export const deleteRun = async (params: DeleteRunParams, options?: RequestInit): Promise<{
    data: Record<string, unknown>;
}> =>{
    const res = await fetch(`/api/businesses/${params.business_id}/runs/${params.run_id}`, {
        ...options,
        method: "DELETE",
        headers: {
            ...(params?.["X-Forwarded-Host"] != null && {
                "X-Forwarded-Host": params["X-Forwarded-Host"]
            }),
            ...(params?.["X-Forwarded-Preferred-Username"] != null && {
                "X-Forwarded-Preferred-Username": params["X-Forwarded-Preferred-Username"]
            }),
            ...(params?.["X-Forwarded-User"] != null && {
                "X-Forwarded-User": params["X-Forwarded-User"]
            }),
            ...(params?.["X-Forwarded-Email"] != null && {
                "X-Forwarded-Email": params["X-Forwarded-Email"]
            }),
            ...(params?.["X-Request-Id"] != null && {
                "X-Request-Id": params["X-Request-Id"]
            }),
            ...(params?.["X-Forwarded-Access-Token"] != null && {
                "X-Forwarded-Access-Token": params["X-Forwarded-Access-Token"]
            }),
            ...options?.headers
        }
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export function useDeleteRun(options?: {
    mutation?: UseMutationOptions<{
        data: Record<string, unknown>;
    }, ApiError, {
        params: DeleteRunParams;
    }>;
}) {
    return useMutation({
        mutationFn: (vars)=>deleteRun(vars.params),
        ...options?.mutation
    });
}
export interface ListArtifactsParams {
    business_id: string;
    run_id: string;
}
export const listArtifacts = async (params: ListArtifactsParams, options?: RequestInit): Promise<{
    data: RunArtifactOut[];
}> =>{
    const res = await fetch(`/api/businesses/${params.business_id}/runs/${params.run_id}/artifacts`, {
        ...options,
        method: "GET"
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export const listArtifactsKey = (params?: ListArtifactsParams)=>{
    return [
        "/api/businesses/{business_id}/runs/{run_id}/artifacts",
        params
    ] as const;
};
export function useListArtifacts<TData = {
    data: RunArtifactOut[];
}>(options: {
    params: ListArtifactsParams;
    query?: Omit<UseQueryOptions<{
        data: RunArtifactOut[];
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useQuery({
        queryKey: listArtifactsKey(options.params),
        queryFn: ()=>listArtifacts(options.params),
        ...options?.query
    });
}
export function useListArtifactsSuspense<TData = {
    data: RunArtifactOut[];
}>(options: {
    params: ListArtifactsParams;
    query?: Omit<UseSuspenseQueryOptions<{
        data: RunArtifactOut[];
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useSuspenseQuery({
        queryKey: listArtifactsKey(options.params),
        queryFn: ()=>listArtifacts(options.params),
        ...options?.query
    });
}
export interface DownloadAllArtifactsParams {
    business_id: string;
    run_id: string;
}
export const downloadAllArtifacts = async (params: DownloadAllArtifactsParams, options?: RequestInit): Promise<{
    data: unknown;
}> =>{
    const res = await fetch(`/api/businesses/${params.business_id}/runs/${params.run_id}/artifacts/download`, {
        ...options,
        method: "GET"
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export const downloadAllArtifactsKey = (params?: DownloadAllArtifactsParams)=>{
    return [
        "/api/businesses/{business_id}/runs/{run_id}/artifacts/download",
        params
    ] as const;
};
export function useDownloadAllArtifacts<TData = {
    data: unknown;
}>(options: {
    params: DownloadAllArtifactsParams;
    query?: Omit<UseQueryOptions<{
        data: unknown;
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useQuery({
        queryKey: downloadAllArtifactsKey(options.params),
        queryFn: ()=>downloadAllArtifacts(options.params),
        ...options?.query
    });
}
export function useDownloadAllArtifactsSuspense<TData = {
    data: unknown;
}>(options: {
    params: DownloadAllArtifactsParams;
    query?: Omit<UseSuspenseQueryOptions<{
        data: unknown;
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useSuspenseQuery({
        queryKey: downloadAllArtifactsKey(options.params),
        queryFn: ()=>downloadAllArtifacts(options.params),
        ...options?.query
    });
}
export interface GetArtifactContentParams {
    business_id: string;
    run_id: string;
    artifact_id: string;
    format?: "text" | "hex";
}
export const getArtifactContent = async (params: GetArtifactContentParams, options?: RequestInit): Promise<{
    data: Record<string, unknown>;
}> =>{
    const searchParams = new URLSearchParams();
    if (params?.format != null) searchParams.set("format", String(params?.format));
    const queryString = searchParams.toString();
    const url = queryString ? `/api/businesses/${params.business_id}/runs/${params.run_id}/artifacts/${params.artifact_id}/content?${queryString}` : `/api/businesses/${params.business_id}/runs/${params.run_id}/artifacts/${params.artifact_id}/content`;
    const res = await fetch(url, {
        ...options,
        method: "GET"
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export const getArtifactContentKey = (params?: GetArtifactContentParams)=>{
    return [
        "/api/businesses/{business_id}/runs/{run_id}/artifacts/{artifact_id}/content",
        params
    ] as const;
};
export function useGetArtifactContent<TData = {
    data: Record<string, unknown>;
}>(options: {
    params: GetArtifactContentParams;
    query?: Omit<UseQueryOptions<{
        data: Record<string, unknown>;
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useQuery({
        queryKey: getArtifactContentKey(options.params),
        queryFn: ()=>getArtifactContent(options.params),
        ...options?.query
    });
}
export function useGetArtifactContentSuspense<TData = {
    data: Record<string, unknown>;
}>(options: {
    params: GetArtifactContentParams;
    query?: Omit<UseSuspenseQueryOptions<{
        data: Record<string, unknown>;
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useSuspenseQuery({
        queryKey: getArtifactContentKey(options.params),
        queryFn: ()=>getArtifactContent(options.params),
        ...options?.query
    });
}
export interface DownloadArtifactParams {
    business_id: string;
    run_id: string;
    artifact_id: string;
    inline?: boolean;
}
export const downloadArtifact = async (params: DownloadArtifactParams, options?: RequestInit): Promise<{
    data: unknown;
}> =>{
    const searchParams = new URLSearchParams();
    if (params?.inline != null) searchParams.set("inline", String(params?.inline));
    const queryString = searchParams.toString();
    const url = queryString ? `/api/businesses/${params.business_id}/runs/${params.run_id}/artifacts/${params.artifact_id}/download?${queryString}` : `/api/businesses/${params.business_id}/runs/${params.run_id}/artifacts/${params.artifact_id}/download`;
    const res = await fetch(url, {
        ...options,
        method: "GET"
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export const downloadArtifactKey = (params?: DownloadArtifactParams)=>{
    return [
        "/api/businesses/{business_id}/runs/{run_id}/artifacts/{artifact_id}/download",
        params
    ] as const;
};
export function useDownloadArtifact<TData = {
    data: unknown;
}>(options: {
    params: DownloadArtifactParams;
    query?: Omit<UseQueryOptions<{
        data: unknown;
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useQuery({
        queryKey: downloadArtifactKey(options.params),
        queryFn: ()=>downloadArtifact(options.params),
        ...options?.query
    });
}
export function useDownloadArtifactSuspense<TData = {
    data: unknown;
}>(options: {
    params: DownloadArtifactParams;
    query?: Omit<UseSuspenseQueryOptions<{
        data: unknown;
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useSuspenseQuery({
        queryKey: downloadArtifactKey(options.params),
        queryFn: ()=>downloadArtifact(options.params),
        ...options?.query
    });
}
export interface CancelRunParams {
    business_id: string;
    run_id: string;
    "X-Forwarded-Host"?: string | null;
    "X-Forwarded-Preferred-Username"?: string | null;
    "X-Forwarded-User"?: string | null;
    "X-Forwarded-Email"?: string | null;
    "X-Request-Id"?: string | null;
    "X-Forwarded-Access-Token"?: string | null;
}
export const cancelRun = async (params: CancelRunParams, options?: RequestInit): Promise<{
    data: RunOut;
}> =>{
    const res = await fetch(`/api/businesses/${params.business_id}/runs/${params.run_id}/cancel`, {
        ...options,
        method: "POST",
        headers: {
            ...(params?.["X-Forwarded-Host"] != null && {
                "X-Forwarded-Host": params["X-Forwarded-Host"]
            }),
            ...(params?.["X-Forwarded-Preferred-Username"] != null && {
                "X-Forwarded-Preferred-Username": params["X-Forwarded-Preferred-Username"]
            }),
            ...(params?.["X-Forwarded-User"] != null && {
                "X-Forwarded-User": params["X-Forwarded-User"]
            }),
            ...(params?.["X-Forwarded-Email"] != null && {
                "X-Forwarded-Email": params["X-Forwarded-Email"]
            }),
            ...(params?.["X-Request-Id"] != null && {
                "X-Request-Id": params["X-Request-Id"]
            }),
            ...(params?.["X-Forwarded-Access-Token"] != null && {
                "X-Forwarded-Access-Token": params["X-Forwarded-Access-Token"]
            }),
            ...options?.headers
        }
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export function useCancelRun(options?: {
    mutation?: UseMutationOptions<{
        data: RunOut;
    }, ApiError, {
        params: CancelRunParams;
    }>;
}) {
    return useMutation({
        mutationFn: (vars)=>cancelRun(vars.params),
        ...options?.mutation
    });
}
export interface CancelRunWithRollbackParams {
    business_id: string;
    run_id: string;
    "X-Forwarded-Host"?: string | null;
    "X-Forwarded-Preferred-Username"?: string | null;
    "X-Forwarded-User"?: string | null;
    "X-Forwarded-Email"?: string | null;
    "X-Request-Id"?: string | null;
    "X-Forwarded-Access-Token"?: string | null;
}
export const cancelRunWithRollback = async (params: CancelRunWithRollbackParams, options?: RequestInit): Promise<{
    data: CancelWithRollbackOut;
}> =>{
    const res = await fetch(`/api/businesses/${params.business_id}/runs/${params.run_id}/cancel-with-rollback`, {
        ...options,
        method: "POST",
        headers: {
            ...(params?.["X-Forwarded-Host"] != null && {
                "X-Forwarded-Host": params["X-Forwarded-Host"]
            }),
            ...(params?.["X-Forwarded-Preferred-Username"] != null && {
                "X-Forwarded-Preferred-Username": params["X-Forwarded-Preferred-Username"]
            }),
            ...(params?.["X-Forwarded-User"] != null && {
                "X-Forwarded-User": params["X-Forwarded-User"]
            }),
            ...(params?.["X-Forwarded-Email"] != null && {
                "X-Forwarded-Email": params["X-Forwarded-Email"]
            }),
            ...(params?.["X-Request-Id"] != null && {
                "X-Request-Id": params["X-Request-Id"]
            }),
            ...(params?.["X-Forwarded-Access-Token"] != null && {
                "X-Forwarded-Access-Token": params["X-Forwarded-Access-Token"]
            }),
            ...options?.headers
        }
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export function useCancelRunWithRollback(options?: {
    mutation?: UseMutationOptions<{
        data: CancelWithRollbackOut;
    }, ApiError, {
        params: CancelRunWithRollbackParams;
    }>;
}) {
    return useMutation({
        mutationFn: (vars)=>cancelRunWithRollback(vars.params),
        ...options?.mutation
    });
}
export interface GetRunChangesParams {
    business_id: string;
    run_id: string;
}
export const getRunChanges = async (params: GetRunChangesParams, options?: RequestInit): Promise<{
    data: RunChangesOut;
}> =>{
    const res = await fetch(`/api/businesses/${params.business_id}/runs/${params.run_id}/changes`, {
        ...options,
        method: "GET"
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export const getRunChangesKey = (params?: GetRunChangesParams)=>{
    return [
        "/api/businesses/{business_id}/runs/{run_id}/changes",
        params
    ] as const;
};
export function useGetRunChanges<TData = {
    data: RunChangesOut;
}>(options: {
    params: GetRunChangesParams;
    query?: Omit<UseQueryOptions<{
        data: RunChangesOut;
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useQuery({
        queryKey: getRunChangesKey(options.params),
        queryFn: ()=>getRunChanges(options.params),
        ...options?.query
    });
}
export function useGetRunChangesSuspense<TData = {
    data: RunChangesOut;
}>(options: {
    params: GetRunChangesParams;
    query?: Omit<UseSuspenseQueryOptions<{
        data: RunChangesOut;
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useSuspenseQuery({
        queryKey: getRunChangesKey(options.params),
        queryFn: ()=>getRunChanges(options.params),
        ...options?.query
    });
}
export interface SetRunChangeDecisionsParams {
    business_id: string;
    run_id: string;
    "X-Forwarded-Host"?: string | null;
    "X-Forwarded-Preferred-Username"?: string | null;
    "X-Forwarded-User"?: string | null;
    "X-Forwarded-Email"?: string | null;
    "X-Request-Id"?: string | null;
    "X-Forwarded-Access-Token"?: string | null;
}
export const setRunChangeDecisions = async (params: SetRunChangeDecisionsParams, data: RunChangeDecisionsIn, options?: RequestInit): Promise<{
    data: RunChangesOut;
}> =>{
    const res = await fetch(`/api/businesses/${params.business_id}/runs/${params.run_id}/changes/decisions`, {
        ...options,
        method: "PUT",
        headers: {
            "Content-Type": "application/json",
            ...(params?.["X-Forwarded-Host"] != null && {
                "X-Forwarded-Host": params["X-Forwarded-Host"]
            }),
            ...(params?.["X-Forwarded-Preferred-Username"] != null && {
                "X-Forwarded-Preferred-Username": params["X-Forwarded-Preferred-Username"]
            }),
            ...(params?.["X-Forwarded-User"] != null && {
                "X-Forwarded-User": params["X-Forwarded-User"]
            }),
            ...(params?.["X-Forwarded-Email"] != null && {
                "X-Forwarded-Email": params["X-Forwarded-Email"]
            }),
            ...(params?.["X-Request-Id"] != null && {
                "X-Request-Id": params["X-Request-Id"]
            }),
            ...(params?.["X-Forwarded-Access-Token"] != null && {
                "X-Forwarded-Access-Token": params["X-Forwarded-Access-Token"]
            }),
            ...options?.headers
        },
        body: JSON.stringify(data)
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export function useSetRunChangeDecisions(options?: {
    mutation?: UseMutationOptions<{
        data: RunChangesOut;
    }, ApiError, {
        params: SetRunChangeDecisionsParams;
        data: RunChangeDecisionsIn;
    }>;
}) {
    return useMutation({
        mutationFn: (vars)=>setRunChangeDecisions(vars.params, vars.data),
        ...options?.mutation
    });
}
export interface AddRejectedChangesAsFeedbackParams {
    business_id: string;
    run_id: string;
    "X-Forwarded-Host"?: string | null;
    "X-Forwarded-Preferred-Username"?: string | null;
    "X-Forwarded-User"?: string | null;
    "X-Forwarded-Email"?: string | null;
    "X-Request-Id"?: string | null;
    "X-Forwarded-Access-Token"?: string | null;
}
export const addRejectedChangesAsFeedback = async (params: AddRejectedChangesAsFeedbackParams, options?: RequestInit): Promise<{
    data: RunChangesOut;
}> =>{
    const res = await fetch(`/api/businesses/${params.business_id}/runs/${params.run_id}/changes/rejected-feedback`, {
        ...options,
        method: "POST",
        headers: {
            ...(params?.["X-Forwarded-Host"] != null && {
                "X-Forwarded-Host": params["X-Forwarded-Host"]
            }),
            ...(params?.["X-Forwarded-Preferred-Username"] != null && {
                "X-Forwarded-Preferred-Username": params["X-Forwarded-Preferred-Username"]
            }),
            ...(params?.["X-Forwarded-User"] != null && {
                "X-Forwarded-User": params["X-Forwarded-User"]
            }),
            ...(params?.["X-Forwarded-Email"] != null && {
                "X-Forwarded-Email": params["X-Forwarded-Email"]
            }),
            ...(params?.["X-Request-Id"] != null && {
                "X-Request-Id": params["X-Request-Id"]
            }),
            ...(params?.["X-Forwarded-Access-Token"] != null && {
                "X-Forwarded-Access-Token": params["X-Forwarded-Access-Token"]
            }),
            ...options?.headers
        }
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export function useAddRejectedChangesAsFeedback(options?: {
    mutation?: UseMutationOptions<{
        data: RunChangesOut;
    }, ApiError, {
        params: AddRejectedChangesAsFeedbackParams;
    }>;
}) {
    return useMutation({
        mutationFn: (vars)=>addRejectedChangesAsFeedback(vars.params),
        ...options?.mutation
    });
}
export interface GetRunLineageParams {
    business_id: string;
    run_id: string;
}
export const getRunLineage = async (params: GetRunLineageParams, options?: RequestInit): Promise<{
    data: RunLineageOut;
}> =>{
    const res = await fetch(`/api/businesses/${params.business_id}/runs/${params.run_id}/lineage`, {
        ...options,
        method: "GET"
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export const getRunLineageKey = (params?: GetRunLineageParams)=>{
    return [
        "/api/businesses/{business_id}/runs/{run_id}/lineage",
        params
    ] as const;
};
export function useGetRunLineage<TData = {
    data: RunLineageOut;
}>(options: {
    params: GetRunLineageParams;
    query?: Omit<UseQueryOptions<{
        data: RunLineageOut;
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useQuery({
        queryKey: getRunLineageKey(options.params),
        queryFn: ()=>getRunLineage(options.params),
        ...options?.query
    });
}
export function useGetRunLineageSuspense<TData = {
    data: RunLineageOut;
}>(options: {
    params: GetRunLineageParams;
    query?: Omit<UseSuspenseQueryOptions<{
        data: RunLineageOut;
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useSuspenseQuery({
        queryKey: getRunLineageKey(options.params),
        queryFn: ()=>getRunLineage(options.params),
        ...options?.query
    });
}
export interface ListRunOperationsParams {
    business_id: string;
    run_id: string;
}
export const listRunOperations = async (params: ListRunOperationsParams, options?: RequestInit): Promise<{
    data: RunOperationOut[];
}> =>{
    const res = await fetch(`/api/businesses/${params.business_id}/runs/${params.run_id}/operations`, {
        ...options,
        method: "GET"
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export const listRunOperationsKey = (params?: ListRunOperationsParams)=>{
    return [
        "/api/businesses/{business_id}/runs/{run_id}/operations",
        params
    ] as const;
};
export function useListRunOperations<TData = {
    data: RunOperationOut[];
}>(options: {
    params: ListRunOperationsParams;
    query?: Omit<UseQueryOptions<{
        data: RunOperationOut[];
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useQuery({
        queryKey: listRunOperationsKey(options.params),
        queryFn: ()=>listRunOperations(options.params),
        ...options?.query
    });
}
export function useListRunOperationsSuspense<TData = {
    data: RunOperationOut[];
}>(options: {
    params: ListRunOperationsParams;
    query?: Omit<UseSuspenseQueryOptions<{
        data: RunOperationOut[];
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useSuspenseQuery({
        queryKey: listRunOperationsKey(options.params),
        queryFn: ()=>listRunOperations(options.params),
        ...options?.query
    });
}
export interface GetRunProgressParams {
    business_id: string;
    run_id: string;
    since_step_id?: number;
}
export const getRunProgress = async (params: GetRunProgressParams, options?: RequestInit): Promise<{
    data: ProgressEventOut[];
}> =>{
    const searchParams = new URLSearchParams();
    if (params?.since_step_id != null) searchParams.set("since_step_id", String(params?.since_step_id));
    const queryString = searchParams.toString();
    const url = queryString ? `/api/businesses/${params.business_id}/runs/${params.run_id}/progress?${queryString}` : `/api/businesses/${params.business_id}/runs/${params.run_id}/progress`;
    const res = await fetch(url, {
        ...options,
        method: "GET"
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export const getRunProgressKey = (params?: GetRunProgressParams)=>{
    return [
        "/api/businesses/{business_id}/runs/{run_id}/progress",
        params
    ] as const;
};
export function useGetRunProgress<TData = {
    data: ProgressEventOut[];
}>(options: {
    params: GetRunProgressParams;
    query?: Omit<UseQueryOptions<{
        data: ProgressEventOut[];
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useQuery({
        queryKey: getRunProgressKey(options.params),
        queryFn: ()=>getRunProgress(options.params),
        ...options?.query
    });
}
export function useGetRunProgressSuspense<TData = {
    data: ProgressEventOut[];
}>(options: {
    params: GetRunProgressParams;
    query?: Omit<UseSuspenseQueryOptions<{
        data: ProgressEventOut[];
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useSuspenseQuery({
        queryKey: getRunProgressKey(options.params),
        queryFn: ()=>getRunProgress(options.params),
        ...options?.query
    });
}
export interface GetRunReportParams {
    business_id: string;
    run_id: string;
}
export const getRunReport = async (params: GetRunReportParams, options?: RequestInit): Promise<{
    data: RunReportOut;
}> =>{
    const res = await fetch(`/api/businesses/${params.business_id}/runs/${params.run_id}/report`, {
        ...options,
        method: "GET"
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export const getRunReportKey = (params?: GetRunReportParams)=>{
    return [
        "/api/businesses/{business_id}/runs/{run_id}/report",
        params
    ] as const;
};
export function useGetRunReport<TData = {
    data: RunReportOut;
}>(options: {
    params: GetRunReportParams;
    query?: Omit<UseQueryOptions<{
        data: RunReportOut;
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useQuery({
        queryKey: getRunReportKey(options.params),
        queryFn: ()=>getRunReport(options.params),
        ...options?.query
    });
}
export function useGetRunReportSuspense<TData = {
    data: RunReportOut;
}>(options: {
    params: GetRunReportParams;
    query?: Omit<UseSuspenseQueryOptions<{
        data: RunReportOut;
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useSuspenseQuery({
        queryKey: getRunReportKey(options.params),
        queryFn: ()=>getRunReport(options.params),
        ...options?.query
    });
}
export interface ResumeRunParams {
    business_id: string;
    run_id: string;
    "X-Forwarded-Host"?: string | null;
    "X-Forwarded-Preferred-Username"?: string | null;
    "X-Forwarded-User"?: string | null;
    "X-Forwarded-Email"?: string | null;
    "X-Request-Id"?: string | null;
    "X-Forwarded-Access-Token"?: string | null;
}
export const resumeRun = async (params: ResumeRunParams, options?: RequestInit): Promise<{
    data: ResumeRunOut;
}> =>{
    const res = await fetch(`/api/businesses/${params.business_id}/runs/${params.run_id}/resume`, {
        ...options,
        method: "POST",
        headers: {
            ...(params?.["X-Forwarded-Host"] != null && {
                "X-Forwarded-Host": params["X-Forwarded-Host"]
            }),
            ...(params?.["X-Forwarded-Preferred-Username"] != null && {
                "X-Forwarded-Preferred-Username": params["X-Forwarded-Preferred-Username"]
            }),
            ...(params?.["X-Forwarded-User"] != null && {
                "X-Forwarded-User": params["X-Forwarded-User"]
            }),
            ...(params?.["X-Forwarded-Email"] != null && {
                "X-Forwarded-Email": params["X-Forwarded-Email"]
            }),
            ...(params?.["X-Request-Id"] != null && {
                "X-Request-Id": params["X-Request-Id"]
            }),
            ...(params?.["X-Forwarded-Access-Token"] != null && {
                "X-Forwarded-Access-Token": params["X-Forwarded-Access-Token"]
            }),
            ...options?.headers
        }
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export function useResumeRun(options?: {
    mutation?: UseMutationOptions<{
        data: ResumeRunOut;
    }, ApiError, {
        params: ResumeRunParams;
    }>;
}) {
    return useMutation({
        mutationFn: (vars)=>resumeRun(vars.params),
        ...options?.mutation
    });
}
export interface RetryRunParams {
    business_id: string;
    run_id: string;
    "X-Forwarded-Host"?: string | null;
    "X-Forwarded-Preferred-Username"?: string | null;
    "X-Forwarded-User"?: string | null;
    "X-Forwarded-Email"?: string | null;
    "X-Request-Id"?: string | null;
    "X-Forwarded-Access-Token"?: string | null;
}
export const retryRun = async (params: RetryRunParams, options?: RequestInit): Promise<{
    data: RunOut;
}> =>{
    const res = await fetch(`/api/businesses/${params.business_id}/runs/${params.run_id}/retry`, {
        ...options,
        method: "POST",
        headers: {
            ...(params?.["X-Forwarded-Host"] != null && {
                "X-Forwarded-Host": params["X-Forwarded-Host"]
            }),
            ...(params?.["X-Forwarded-Preferred-Username"] != null && {
                "X-Forwarded-Preferred-Username": params["X-Forwarded-Preferred-Username"]
            }),
            ...(params?.["X-Forwarded-User"] != null && {
                "X-Forwarded-User": params["X-Forwarded-User"]
            }),
            ...(params?.["X-Forwarded-Email"] != null && {
                "X-Forwarded-Email": params["X-Forwarded-Email"]
            }),
            ...(params?.["X-Request-Id"] != null && {
                "X-Request-Id": params["X-Request-Id"]
            }),
            ...(params?.["X-Forwarded-Access-Token"] != null && {
                "X-Forwarded-Access-Token": params["X-Forwarded-Access-Token"]
            }),
            ...options?.headers
        }
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export function useRetryRun(options?: {
    mutation?: UseMutationOptions<{
        data: RunOut;
    }, ApiError, {
        params: RetryRunParams;
    }>;
}) {
    return useMutation({
        mutationFn: (vars)=>retryRun(vars.params),
        ...options?.mutation
    });
}
export interface ListRunSchemaDropsParams {
    business_id: string;
    run_id: string;
}
export const listRunSchemaDrops = async (params: ListRunSchemaDropsParams, options?: RequestInit): Promise<{
    data: OrphanSchemaDropOut[];
}> =>{
    const res = await fetch(`/api/businesses/${params.business_id}/runs/${params.run_id}/schema-drops`, {
        ...options,
        method: "GET"
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export const listRunSchemaDropsKey = (params?: ListRunSchemaDropsParams)=>{
    return [
        "/api/businesses/{business_id}/runs/{run_id}/schema-drops",
        params
    ] as const;
};
export function useListRunSchemaDrops<TData = {
    data: OrphanSchemaDropOut[];
}>(options: {
    params: ListRunSchemaDropsParams;
    query?: Omit<UseQueryOptions<{
        data: OrphanSchemaDropOut[];
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useQuery({
        queryKey: listRunSchemaDropsKey(options.params),
        queryFn: ()=>listRunSchemaDrops(options.params),
        ...options?.query
    });
}
export function useListRunSchemaDropsSuspense<TData = {
    data: OrphanSchemaDropOut[];
}>(options: {
    params: ListRunSchemaDropsParams;
    query?: Omit<UseSuspenseQueryOptions<{
        data: OrphanSchemaDropOut[];
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useSuspenseQuery({
        queryKey: listRunSchemaDropsKey(options.params),
        queryFn: ()=>listRunSchemaDrops(options.params),
        ...options?.query
    });
}
export interface SeedModelParams {
    business_id: string;
    "X-Forwarded-Host"?: string | null;
    "X-Forwarded-Preferred-Username"?: string | null;
    "X-Forwarded-User"?: string | null;
    "X-Forwarded-Email"?: string | null;
    "X-Request-Id"?: string | null;
    "X-Forwarded-Access-Token"?: string | null;
}
export const seedModel = async (params: SeedModelParams, data: Record<string, unknown>, options?: RequestInit): Promise<{
    data: unknown;
}> =>{
    const res = await fetch(`/api/businesses/${params.business_id}/seed-model`, {
        ...options,
        method: "POST",
        headers: {
            "Content-Type": "application/json",
            ...(params?.["X-Forwarded-Host"] != null && {
                "X-Forwarded-Host": params["X-Forwarded-Host"]
            }),
            ...(params?.["X-Forwarded-Preferred-Username"] != null && {
                "X-Forwarded-Preferred-Username": params["X-Forwarded-Preferred-Username"]
            }),
            ...(params?.["X-Forwarded-User"] != null && {
                "X-Forwarded-User": params["X-Forwarded-User"]
            }),
            ...(params?.["X-Forwarded-Email"] != null && {
                "X-Forwarded-Email": params["X-Forwarded-Email"]
            }),
            ...(params?.["X-Request-Id"] != null && {
                "X-Request-Id": params["X-Request-Id"]
            }),
            ...(params?.["X-Forwarded-Access-Token"] != null && {
                "X-Forwarded-Access-Token": params["X-Forwarded-Access-Token"]
            }),
            ...options?.headers
        },
        body: JSON.stringify(data)
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export function useSeedModel(options?: {
    mutation?: UseMutationOptions<{
        data: unknown;
    }, ApiError, {
        params: SeedModelParams;
        data: Record<string, unknown>;
    }>;
}) {
    return useMutation({
        mutationFn: (vars)=>seedModel(vars.params, vars.data),
        ...options?.mutation
    });
}
export interface ListVersionsParams {
    business_id: string;
}
export const listVersions = async (params: ListVersionsParams, options?: RequestInit): Promise<{
    data: ModelVersionOut[];
}> =>{
    const res = await fetch(`/api/businesses/${params.business_id}/versions`, {
        ...options,
        method: "GET"
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export const listVersionsKey = (params?: ListVersionsParams)=>{
    return [
        "/api/businesses/{business_id}/versions",
        params
    ] as const;
};
export function useListVersions<TData = {
    data: ModelVersionOut[];
}>(options: {
    params: ListVersionsParams;
    query?: Omit<UseQueryOptions<{
        data: ModelVersionOut[];
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useQuery({
        queryKey: listVersionsKey(options.params),
        queryFn: ()=>listVersions(options.params),
        ...options?.query
    });
}
export function useListVersionsSuspense<TData = {
    data: ModelVersionOut[];
}>(options: {
    params: ListVersionsParams;
    query?: Omit<UseSuspenseQueryOptions<{
        data: ModelVersionOut[];
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useSuspenseQuery({
        queryKey: listVersionsKey(options.params),
        queryFn: ()=>listVersions(options.params),
        ...options?.query
    });
}
export interface ImportVersionFromVolumeParams {
    business_id: string;
    volume_path: string;
    new_version_number?: number | null;
    scope?: "ecm" | "mvm" | null;
    catalog?: string | null;
    base_version_id?: string | null;
    vibe_instructions?: string;
    databricks_run_id?: number | null;
    "X-Forwarded-Host"?: string | null;
    "X-Forwarded-Preferred-Username"?: string | null;
    "X-Forwarded-User"?: string | null;
    "X-Forwarded-Email"?: string | null;
    "X-Request-Id"?: string | null;
    "X-Forwarded-Access-Token"?: string | null;
}
export const importVersionFromVolume = async (params: ImportVersionFromVolumeParams, options?: RequestInit): Promise<{
    data: Record<string, unknown>;
}> =>{
    const searchParams = new URLSearchParams();
    if (params.volume_path != null) searchParams.set("volume_path", String(params.volume_path));
    if (params?.new_version_number != null) searchParams.set("new_version_number", String(params?.new_version_number));
    if (params?.scope != null) searchParams.set("scope", String(params?.scope));
    if (params?.catalog != null) searchParams.set("catalog", String(params?.catalog));
    if (params?.base_version_id != null) searchParams.set("base_version_id", String(params?.base_version_id));
    if (params?.vibe_instructions != null) searchParams.set("vibe_instructions", String(params?.vibe_instructions));
    if (params?.databricks_run_id != null) searchParams.set("databricks_run_id", String(params?.databricks_run_id));
    const queryString = searchParams.toString();
    const url = queryString ? `/api/businesses/${params.business_id}/versions/import-from-volume?${queryString}` : `/api/businesses/${params.business_id}/versions/import-from-volume`;
    const res = await fetch(url, {
        ...options,
        method: "POST",
        headers: {
            ...(params?.["X-Forwarded-Host"] != null && {
                "X-Forwarded-Host": params["X-Forwarded-Host"]
            }),
            ...(params?.["X-Forwarded-Preferred-Username"] != null && {
                "X-Forwarded-Preferred-Username": params["X-Forwarded-Preferred-Username"]
            }),
            ...(params?.["X-Forwarded-User"] != null && {
                "X-Forwarded-User": params["X-Forwarded-User"]
            }),
            ...(params?.["X-Forwarded-Email"] != null && {
                "X-Forwarded-Email": params["X-Forwarded-Email"]
            }),
            ...(params?.["X-Request-Id"] != null && {
                "X-Request-Id": params["X-Request-Id"]
            }),
            ...(params?.["X-Forwarded-Access-Token"] != null && {
                "X-Forwarded-Access-Token": params["X-Forwarded-Access-Token"]
            }),
            ...options?.headers
        }
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export function useImportVersionFromVolume(options?: {
    mutation?: UseMutationOptions<{
        data: Record<string, unknown>;
    }, ApiError, {
        params: ImportVersionFromVolumeParams;
    }>;
}) {
    return useMutation({
        mutationFn: (vars)=>importVersionFromVolume(vars.params),
        ...options?.mutation
    });
}
export interface DeleteVersionParams {
    business_id: string;
    version_id: string;
    "X-Forwarded-Host"?: string | null;
    "X-Forwarded-Preferred-Username"?: string | null;
    "X-Forwarded-User"?: string | null;
    "X-Forwarded-Email"?: string | null;
    "X-Request-Id"?: string | null;
    "X-Forwarded-Access-Token"?: string | null;
}
export const deleteVersion = async (params: DeleteVersionParams, options?: RequestInit): Promise<{
    data: DeleteVersionOut;
}> =>{
    const res = await fetch(`/api/businesses/${params.business_id}/versions/${params.version_id}`, {
        ...options,
        method: "DELETE",
        headers: {
            ...(params?.["X-Forwarded-Host"] != null && {
                "X-Forwarded-Host": params["X-Forwarded-Host"]
            }),
            ...(params?.["X-Forwarded-Preferred-Username"] != null && {
                "X-Forwarded-Preferred-Username": params["X-Forwarded-Preferred-Username"]
            }),
            ...(params?.["X-Forwarded-User"] != null && {
                "X-Forwarded-User": params["X-Forwarded-User"]
            }),
            ...(params?.["X-Forwarded-Email"] != null && {
                "X-Forwarded-Email": params["X-Forwarded-Email"]
            }),
            ...(params?.["X-Request-Id"] != null && {
                "X-Request-Id": params["X-Request-Id"]
            }),
            ...(params?.["X-Forwarded-Access-Token"] != null && {
                "X-Forwarded-Access-Token": params["X-Forwarded-Access-Token"]
            }),
            ...options?.headers
        }
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export function useDeleteVersion(options?: {
    mutation?: UseMutationOptions<{
        data: DeleteVersionOut;
    }, ApiError, {
        params: DeleteVersionParams;
    }>;
}) {
    return useMutation({
        mutationFn: (vars)=>deleteVersion(vars.params),
        ...options?.mutation
    });
}
export interface CheckDeploymentCatalogParams {
    business_id: string;
    version_id: string;
}
export const checkDeploymentCatalog = async (params: CheckDeploymentCatalogParams, options?: RequestInit): Promise<{
    data: DeploymentCatalogCheckOut;
}> =>{
    const res = await fetch(`/api/businesses/${params.business_id}/versions/${params.version_id}/deployment/catalog-check`, {
        ...options,
        method: "GET"
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export const checkDeploymentCatalogKey = (params?: CheckDeploymentCatalogParams)=>{
    return [
        "/api/businesses/{business_id}/versions/{version_id}/deployment/catalog-check",
        params
    ] as const;
};
export function useCheckDeploymentCatalog<TData = {
    data: DeploymentCatalogCheckOut;
}>(options: {
    params: CheckDeploymentCatalogParams;
    query?: Omit<UseQueryOptions<{
        data: DeploymentCatalogCheckOut;
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useQuery({
        queryKey: checkDeploymentCatalogKey(options.params),
        queryFn: ()=>checkDeploymentCatalog(options.params),
        ...options?.query
    });
}
export function useCheckDeploymentCatalogSuspense<TData = {
    data: DeploymentCatalogCheckOut;
}>(options: {
    params: CheckDeploymentCatalogParams;
    query?: Omit<UseSuspenseQueryOptions<{
        data: DeploymentCatalogCheckOut;
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useSuspenseQuery({
        queryKey: checkDeploymentCatalogKey(options.params),
        queryFn: ()=>checkDeploymentCatalog(options.params),
        ...options?.query
    });
}
export interface CompareDeploymentParams {
    business_id: string;
    version_id: string;
}
export const compareDeployment = async (params: CompareDeploymentParams, options?: RequestInit): Promise<{
    data: DeploymentVerificationOut;
}> =>{
    const res = await fetch(`/api/businesses/${params.business_id}/versions/${params.version_id}/deployment/compare`, {
        ...options,
        method: "GET"
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export const compareDeploymentKey = (params?: CompareDeploymentParams)=>{
    return [
        "/api/businesses/{business_id}/versions/{version_id}/deployment/compare",
        params
    ] as const;
};
export function useCompareDeployment<TData = {
    data: DeploymentVerificationOut;
}>(options: {
    params: CompareDeploymentParams;
    query?: Omit<UseQueryOptions<{
        data: DeploymentVerificationOut;
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useQuery({
        queryKey: compareDeploymentKey(options.params),
        queryFn: ()=>compareDeployment(options.params),
        ...options?.query
    });
}
export function useCompareDeploymentSuspense<TData = {
    data: DeploymentVerificationOut;
}>(options: {
    params: CompareDeploymentParams;
    query?: Omit<UseSuspenseQueryOptions<{
        data: DeploymentVerificationOut;
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useSuspenseQuery({
        queryKey: compareDeploymentKey(options.params),
        queryFn: ()=>compareDeployment(options.params),
        ...options?.query
    });
}
export interface GetDeployedUcSchemaParams {
    business_id: string;
    version_id: string;
}
export const getDeployedUcSchema = async (params: GetDeployedUcSchemaParams, options?: RequestInit): Promise<{
    data: DeployedUcSchemaOut;
}> =>{
    const res = await fetch(`/api/businesses/${params.business_id}/versions/${params.version_id}/deployment/uc-schema`, {
        ...options,
        method: "GET"
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export const getDeployedUcSchemaKey = (params?: GetDeployedUcSchemaParams)=>{
    return [
        "/api/businesses/{business_id}/versions/{version_id}/deployment/uc-schema",
        params
    ] as const;
};
export function useGetDeployedUcSchema<TData = {
    data: DeployedUcSchemaOut;
}>(options: {
    params: GetDeployedUcSchemaParams;
    query?: Omit<UseQueryOptions<{
        data: DeployedUcSchemaOut;
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useQuery({
        queryKey: getDeployedUcSchemaKey(options.params),
        queryFn: ()=>getDeployedUcSchema(options.params),
        ...options?.query
    });
}
export function useGetDeployedUcSchemaSuspense<TData = {
    data: DeployedUcSchemaOut;
}>(options: {
    params: GetDeployedUcSchemaParams;
    query?: Omit<UseSuspenseQueryOptions<{
        data: DeployedUcSchemaOut;
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useSuspenseQuery({
        queryKey: getDeployedUcSchemaKey(options.params),
        queryFn: ()=>getDeployedUcSchema(options.params),
        ...options?.query
    });
}
export interface CarryForwardInputsParams {
    business_id: string;
    version_id: string;
    "X-Forwarded-Host"?: string | null;
    "X-Forwarded-Preferred-Username"?: string | null;
    "X-Forwarded-User"?: string | null;
    "X-Forwarded-Email"?: string | null;
    "X-Request-Id"?: string | null;
    "X-Forwarded-Access-Token"?: string | null;
}
export const carryForwardInputs = async (params: CarryForwardInputsParams, options?: RequestInit): Promise<{
    data: CarryForwardResultOut;
}> =>{
    const res = await fetch(`/api/businesses/${params.business_id}/versions/${params.version_id}/inputs/carry-forward`, {
        ...options,
        method: "POST",
        headers: {
            ...(params?.["X-Forwarded-Host"] != null && {
                "X-Forwarded-Host": params["X-Forwarded-Host"]
            }),
            ...(params?.["X-Forwarded-Preferred-Username"] != null && {
                "X-Forwarded-Preferred-Username": params["X-Forwarded-Preferred-Username"]
            }),
            ...(params?.["X-Forwarded-User"] != null && {
                "X-Forwarded-User": params["X-Forwarded-User"]
            }),
            ...(params?.["X-Forwarded-Email"] != null && {
                "X-Forwarded-Email": params["X-Forwarded-Email"]
            }),
            ...(params?.["X-Request-Id"] != null && {
                "X-Request-Id": params["X-Request-Id"]
            }),
            ...(params?.["X-Forwarded-Access-Token"] != null && {
                "X-Forwarded-Access-Token": params["X-Forwarded-Access-Token"]
            }),
            ...options?.headers
        }
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export function useCarryForwardInputs(options?: {
    mutation?: UseMutationOptions<{
        data: CarryForwardResultOut;
    }, ApiError, {
        params: CarryForwardInputsParams;
    }>;
}) {
    return useMutation({
        mutationFn: (vars)=>carryForwardInputs(vars.params),
        ...options?.mutation
    });
}
export interface CompileVibeInputsParams {
    business_id: string;
    version_id: string;
    "X-Forwarded-Host"?: string | null;
    "X-Forwarded-Preferred-Username"?: string | null;
    "X-Forwarded-User"?: string | null;
    "X-Forwarded-Email"?: string | null;
    "X-Request-Id"?: string | null;
    "X-Forwarded-Access-Token"?: string | null;
}
export const compileVibeInputs = async (params: CompileVibeInputsParams, data: CompileIn, options?: RequestInit): Promise<{
    data: CompileOut;
}> =>{
    const res = await fetch(`/api/businesses/${params.business_id}/versions/${params.version_id}/inputs/compile`, {
        ...options,
        method: "POST",
        headers: {
            "Content-Type": "application/json",
            ...(params?.["X-Forwarded-Host"] != null && {
                "X-Forwarded-Host": params["X-Forwarded-Host"]
            }),
            ...(params?.["X-Forwarded-Preferred-Username"] != null && {
                "X-Forwarded-Preferred-Username": params["X-Forwarded-Preferred-Username"]
            }),
            ...(params?.["X-Forwarded-User"] != null && {
                "X-Forwarded-User": params["X-Forwarded-User"]
            }),
            ...(params?.["X-Forwarded-Email"] != null && {
                "X-Forwarded-Email": params["X-Forwarded-Email"]
            }),
            ...(params?.["X-Request-Id"] != null && {
                "X-Request-Id": params["X-Request-Id"]
            }),
            ...(params?.["X-Forwarded-Access-Token"] != null && {
                "X-Forwarded-Access-Token": params["X-Forwarded-Access-Token"]
            }),
            ...options?.headers
        },
        body: JSON.stringify(data)
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export function useCompileVibeInputs(options?: {
    mutation?: UseMutationOptions<{
        data: CompileOut;
    }, ApiError, {
        params: CompileVibeInputsParams;
        data: CompileIn;
    }>;
}) {
    return useMutation({
        mutationFn: (vars)=>compileVibeInputs(vars.params, vars.data),
        ...options?.mutation
    });
}
export interface LinkRunParams {
    business_id: string;
    version_id: string;
    "X-Forwarded-Host"?: string | null;
    "X-Forwarded-Preferred-Username"?: string | null;
    "X-Forwarded-User"?: string | null;
    "X-Forwarded-Email"?: string | null;
    "X-Request-Id"?: string | null;
    "X-Forwarded-Access-Token"?: string | null;
}
export const linkRun = async (params: LinkRunParams, data: LinkRunIn, options?: RequestInit): Promise<{
    data: RunOut;
}> =>{
    const res = await fetch(`/api/businesses/${params.business_id}/versions/${params.version_id}/link-run`, {
        ...options,
        method: "POST",
        headers: {
            "Content-Type": "application/json",
            ...(params?.["X-Forwarded-Host"] != null && {
                "X-Forwarded-Host": params["X-Forwarded-Host"]
            }),
            ...(params?.["X-Forwarded-Preferred-Username"] != null && {
                "X-Forwarded-Preferred-Username": params["X-Forwarded-Preferred-Username"]
            }),
            ...(params?.["X-Forwarded-User"] != null && {
                "X-Forwarded-User": params["X-Forwarded-User"]
            }),
            ...(params?.["X-Forwarded-Email"] != null && {
                "X-Forwarded-Email": params["X-Forwarded-Email"]
            }),
            ...(params?.["X-Request-Id"] != null && {
                "X-Request-Id": params["X-Request-Id"]
            }),
            ...(params?.["X-Forwarded-Access-Token"] != null && {
                "X-Forwarded-Access-Token": params["X-Forwarded-Access-Token"]
            }),
            ...options?.headers
        },
        body: JSON.stringify(data)
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export function useLinkRun(options?: {
    mutation?: UseMutationOptions<{
        data: RunOut;
    }, ApiError, {
        params: LinkRunParams;
        data: LinkRunIn;
    }>;
}) {
    return useMutation({
        mutationFn: (vars)=>linkRun(vars.params, vars.data),
        ...options?.mutation
    });
}
export interface PreviewLinkRunParams {
    business_id: string;
    version_id: string;
    "X-Forwarded-Host"?: string | null;
    "X-Forwarded-Preferred-Username"?: string | null;
    "X-Forwarded-User"?: string | null;
    "X-Forwarded-Email"?: string | null;
    "X-Request-Id"?: string | null;
    "X-Forwarded-Access-Token"?: string | null;
}
export const previewLinkRun = async (params: PreviewLinkRunParams, data: LinkRunIn, options?: RequestInit): Promise<{
    data: LinkRunPreviewOut;
}> =>{
    const res = await fetch(`/api/businesses/${params.business_id}/versions/${params.version_id}/link-run/preview`, {
        ...options,
        method: "POST",
        headers: {
            "Content-Type": "application/json",
            ...(params?.["X-Forwarded-Host"] != null && {
                "X-Forwarded-Host": params["X-Forwarded-Host"]
            }),
            ...(params?.["X-Forwarded-Preferred-Username"] != null && {
                "X-Forwarded-Preferred-Username": params["X-Forwarded-Preferred-Username"]
            }),
            ...(params?.["X-Forwarded-User"] != null && {
                "X-Forwarded-User": params["X-Forwarded-User"]
            }),
            ...(params?.["X-Forwarded-Email"] != null && {
                "X-Forwarded-Email": params["X-Forwarded-Email"]
            }),
            ...(params?.["X-Request-Id"] != null && {
                "X-Request-Id": params["X-Request-Id"]
            }),
            ...(params?.["X-Forwarded-Access-Token"] != null && {
                "X-Forwarded-Access-Token": params["X-Forwarded-Access-Token"]
            }),
            ...options?.headers
        },
        body: JSON.stringify(data)
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export function usePreviewLinkRun(options?: {
    mutation?: UseMutationOptions<{
        data: LinkRunPreviewOut;
    }, ApiError, {
        params: PreviewLinkRunParams;
        data: LinkRunIn;
    }>;
}) {
    return useMutation({
        mutationFn: (vars)=>previewLinkRun(vars.params, vars.data),
        ...options?.mutation
    });
}
export interface GetVersionReportParams {
    business_id: string;
    version_id: string;
}
export const getVersionReport = async (params: GetVersionReportParams, options?: RequestInit): Promise<{
    data: VersionReportOut;
}> =>{
    const res = await fetch(`/api/businesses/${params.business_id}/versions/${params.version_id}/report`, {
        ...options,
        method: "GET"
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export const getVersionReportKey = (params?: GetVersionReportParams)=>{
    return [
        "/api/businesses/{business_id}/versions/{version_id}/report",
        params
    ] as const;
};
export function useGetVersionReport<TData = {
    data: VersionReportOut;
}>(options: {
    params: GetVersionReportParams;
    query?: Omit<UseQueryOptions<{
        data: VersionReportOut;
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useQuery({
        queryKey: getVersionReportKey(options.params),
        queryFn: ()=>getVersionReport(options.params),
        ...options?.query
    });
}
export function useGetVersionReportSuspense<TData = {
    data: VersionReportOut;
}>(options: {
    params: GetVersionReportParams;
    query?: Omit<UseSuspenseQueryOptions<{
        data: VersionReportOut;
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useSuspenseQuery({
        queryKey: getVersionReportKey(options.params),
        queryFn: ()=>getVersionReport(options.params),
        ...options?.query
    });
}
export interface ForceResyncVersionParams {
    business_id: string;
    version_id: string;
    "X-Forwarded-Host"?: string | null;
    "X-Forwarded-Preferred-Username"?: string | null;
    "X-Forwarded-User"?: string | null;
    "X-Forwarded-Email"?: string | null;
    "X-Request-Id"?: string | null;
    "X-Forwarded-Access-Token"?: string | null;
}
export const forceResyncVersion = async (params: ForceResyncVersionParams, options?: RequestInit): Promise<{
    data: Record<string, unknown>;
}> =>{
    const res = await fetch(`/api/businesses/${params.business_id}/versions/${params.version_id}/resync`, {
        ...options,
        method: "POST",
        headers: {
            ...(params?.["X-Forwarded-Host"] != null && {
                "X-Forwarded-Host": params["X-Forwarded-Host"]
            }),
            ...(params?.["X-Forwarded-Preferred-Username"] != null && {
                "X-Forwarded-Preferred-Username": params["X-Forwarded-Preferred-Username"]
            }),
            ...(params?.["X-Forwarded-User"] != null && {
                "X-Forwarded-User": params["X-Forwarded-User"]
            }),
            ...(params?.["X-Forwarded-Email"] != null && {
                "X-Forwarded-Email": params["X-Forwarded-Email"]
            }),
            ...(params?.["X-Request-Id"] != null && {
                "X-Request-Id": params["X-Request-Id"]
            }),
            ...(params?.["X-Forwarded-Access-Token"] != null && {
                "X-Forwarded-Access-Token": params["X-Forwarded-Access-Token"]
            }),
            ...options?.headers
        }
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export function useForceResyncVersion(options?: {
    mutation?: UseMutationOptions<{
        data: Record<string, unknown>;
    }, ApiError, {
        params: ForceResyncVersionParams;
    }>;
}) {
    return useMutation({
        mutationFn: (vars)=>forceResyncVersion(vars.params),
        ...options?.mutation
    });
}
export interface SyncModelVersionParams {
    business_id: string;
    version_id: string;
    "X-Forwarded-Host"?: string | null;
    "X-Forwarded-Preferred-Username"?: string | null;
    "X-Forwarded-User"?: string | null;
    "X-Forwarded-Email"?: string | null;
    "X-Request-Id"?: string | null;
    "X-Forwarded-Access-Token"?: string | null;
}
export const syncModelVersion = async (params: SyncModelVersionParams, options?: RequestInit): Promise<{
    data: Record<string, unknown>;
}> =>{
    const res = await fetch(`/api/businesses/${params.business_id}/versions/${params.version_id}/sync`, {
        ...options,
        method: "POST",
        headers: {
            ...(params?.["X-Forwarded-Host"] != null && {
                "X-Forwarded-Host": params["X-Forwarded-Host"]
            }),
            ...(params?.["X-Forwarded-Preferred-Username"] != null && {
                "X-Forwarded-Preferred-Username": params["X-Forwarded-Preferred-Username"]
            }),
            ...(params?.["X-Forwarded-User"] != null && {
                "X-Forwarded-User": params["X-Forwarded-User"]
            }),
            ...(params?.["X-Forwarded-Email"] != null && {
                "X-Forwarded-Email": params["X-Forwarded-Email"]
            }),
            ...(params?.["X-Request-Id"] != null && {
                "X-Request-Id": params["X-Request-Id"]
            }),
            ...(params?.["X-Forwarded-Access-Token"] != null && {
                "X-Forwarded-Access-Token": params["X-Forwarded-Access-Token"]
            }),
            ...options?.headers
        }
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export function useSyncModelVersion(options?: {
    mutation?: UseMutationOptions<{
        data: Record<string, unknown>;
    }, ApiError, {
        params: SyncModelVersionParams;
    }>;
}) {
    return useMutation({
        mutationFn: (vars)=>syncModelVersion(vars.params),
        ...options?.mutation
    });
}
export interface GetUninstallImpactParams {
    business_id: string;
    version_id: string;
    catalog?: string | null;
    cataloging_style?: "One Catalog" | "Catalog per Division" | "Catalog per Domain" | null;
    "X-Forwarded-Host"?: string | null;
    "X-Forwarded-Preferred-Username"?: string | null;
    "X-Forwarded-User"?: string | null;
    "X-Forwarded-Email"?: string | null;
    "X-Request-Id"?: string | null;
    "X-Forwarded-Access-Token"?: string | null;
}
export const getUninstallImpact = async (params: GetUninstallImpactParams, options?: RequestInit): Promise<{
    data: UninstallImpactOut;
}> =>{
    const searchParams = new URLSearchParams();
    if (params?.catalog != null) searchParams.set("catalog", String(params?.catalog));
    if (params?.cataloging_style != null) searchParams.set("cataloging_style", String(params?.cataloging_style));
    const queryString = searchParams.toString();
    const url = queryString ? `/api/businesses/${params.business_id}/versions/${params.version_id}/uninstall-impact?${queryString}` : `/api/businesses/${params.business_id}/versions/${params.version_id}/uninstall-impact`;
    const res = await fetch(url, {
        ...options,
        method: "GET",
        headers: {
            ...(params?.["X-Forwarded-Host"] != null && {
                "X-Forwarded-Host": params["X-Forwarded-Host"]
            }),
            ...(params?.["X-Forwarded-Preferred-Username"] != null && {
                "X-Forwarded-Preferred-Username": params["X-Forwarded-Preferred-Username"]
            }),
            ...(params?.["X-Forwarded-User"] != null && {
                "X-Forwarded-User": params["X-Forwarded-User"]
            }),
            ...(params?.["X-Forwarded-Email"] != null && {
                "X-Forwarded-Email": params["X-Forwarded-Email"]
            }),
            ...(params?.["X-Request-Id"] != null && {
                "X-Request-Id": params["X-Request-Id"]
            }),
            ...(params?.["X-Forwarded-Access-Token"] != null && {
                "X-Forwarded-Access-Token": params["X-Forwarded-Access-Token"]
            }),
            ...options?.headers
        }
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export const getUninstallImpactKey = (params?: GetUninstallImpactParams)=>{
    return [
        "/api/businesses/{business_id}/versions/{version_id}/uninstall-impact",
        params
    ] as const;
};
export function useGetUninstallImpact<TData = {
    data: UninstallImpactOut;
}>(options: {
    params: GetUninstallImpactParams;
    query?: Omit<UseQueryOptions<{
        data: UninstallImpactOut;
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useQuery({
        queryKey: getUninstallImpactKey(options.params),
        queryFn: ()=>getUninstallImpact(options.params),
        ...options?.query
    });
}
export function useGetUninstallImpactSuspense<TData = {
    data: UninstallImpactOut;
}>(options: {
    params: GetUninstallImpactParams;
    query?: Omit<UseSuspenseQueryOptions<{
        data: UninstallImpactOut;
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useSuspenseQuery({
        queryKey: getUninstallImpactKey(options.params),
        queryFn: ()=>getUninstallImpact(options.params),
        ...options?.query
    });
}
export interface GetDiagramLayoutParams {
    business_id: string;
    version_int: number;
    scope: string;
    domain?: string | null;
    column_mode?: string;
    prefetch?: boolean;
}
export const getDiagramLayout = async (params: GetDiagramLayoutParams, options?: RequestInit): Promise<{
    data: DiagramLayoutOut;
}> =>{
    const searchParams = new URLSearchParams();
    if (params?.domain != null) searchParams.set("domain", String(params?.domain));
    if (params?.column_mode != null) searchParams.set("column_mode", String(params?.column_mode));
    if (params?.prefetch != null) searchParams.set("prefetch", String(params?.prefetch));
    const queryString = searchParams.toString();
    const url = queryString ? `/api/businesses/${params.business_id}/versions/${params.version_int}/${params.scope}/diagram?${queryString}` : `/api/businesses/${params.business_id}/versions/${params.version_int}/${params.scope}/diagram`;
    const res = await fetch(url, {
        ...options,
        method: "GET"
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export const getDiagramLayoutKey = (params?: GetDiagramLayoutParams)=>{
    return [
        "/api/businesses/{business_id}/versions/{version_int}/{scope}/diagram",
        params
    ] as const;
};
export function useGetDiagramLayout<TData = {
    data: DiagramLayoutOut;
}>(options: {
    params: GetDiagramLayoutParams;
    query?: Omit<UseQueryOptions<{
        data: DiagramLayoutOut;
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useQuery({
        queryKey: getDiagramLayoutKey(options.params),
        queryFn: ()=>getDiagramLayout(options.params),
        ...options?.query
    });
}
export function useGetDiagramLayoutSuspense<TData = {
    data: DiagramLayoutOut;
}>(options: {
    params: GetDiagramLayoutParams;
    query?: Omit<UseSuspenseQueryOptions<{
        data: DiagramLayoutOut;
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useSuspenseQuery({
        queryKey: getDiagramLayoutKey(options.params),
        queryFn: ()=>getDiagramLayout(options.params),
        ...options?.query
    });
}
export interface GetDomainDetailParams {
    business_id: string;
    version_int: number;
    scope: string;
    domain_name: string;
}
export const getDomainDetail = async (params: GetDomainDetailParams, options?: RequestInit): Promise<{
    data: DomainDetailOut;
}> =>{
    const res = await fetch(`/api/businesses/${params.business_id}/versions/${params.version_int}/${params.scope}/domains/${params.domain_name}`, {
        ...options,
        method: "GET"
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export const getDomainDetailKey = (params?: GetDomainDetailParams)=>{
    return [
        "/api/businesses/{business_id}/versions/{version_int}/{scope}/domains/{domain_name}",
        params
    ] as const;
};
export function useGetDomainDetail<TData = {
    data: DomainDetailOut;
}>(options: {
    params: GetDomainDetailParams;
    query?: Omit<UseQueryOptions<{
        data: DomainDetailOut;
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useQuery({
        queryKey: getDomainDetailKey(options.params),
        queryFn: ()=>getDomainDetail(options.params),
        ...options?.query
    });
}
export function useGetDomainDetailSuspense<TData = {
    data: DomainDetailOut;
}>(options: {
    params: GetDomainDetailParams;
    query?: Omit<UseSuspenseQueryOptions<{
        data: DomainDetailOut;
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useSuspenseQuery({
        queryKey: getDomainDetailKey(options.params),
        queryFn: ()=>getDomainDetail(options.params),
        ...options?.query
    });
}
export interface GetDomainNextVibeMetricsParams {
    business_id: string;
    version_int: number;
    scope: string;
    domain_name: string;
}
export const getDomainNextVibeMetrics = async (params: GetDomainNextVibeMetricsParams, options?: RequestInit): Promise<{
    data: NextVibeMetricsOut;
}> =>{
    const res = await fetch(`/api/businesses/${params.business_id}/versions/${params.version_int}/${params.scope}/domains/${params.domain_name}/next-vibe-metrics`, {
        ...options,
        method: "GET"
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export const getDomainNextVibeMetricsKey = (params?: GetDomainNextVibeMetricsParams)=>{
    return [
        "/api/businesses/{business_id}/versions/{version_int}/{scope}/domains/{domain_name}/next-vibe-metrics",
        params
    ] as const;
};
export function useGetDomainNextVibeMetrics<TData = {
    data: NextVibeMetricsOut;
}>(options: {
    params: GetDomainNextVibeMetricsParams;
    query?: Omit<UseQueryOptions<{
        data: NextVibeMetricsOut;
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useQuery({
        queryKey: getDomainNextVibeMetricsKey(options.params),
        queryFn: ()=>getDomainNextVibeMetrics(options.params),
        ...options?.query
    });
}
export function useGetDomainNextVibeMetricsSuspense<TData = {
    data: NextVibeMetricsOut;
}>(options: {
    params: GetDomainNextVibeMetricsParams;
    query?: Omit<UseSuspenseQueryOptions<{
        data: NextVibeMetricsOut;
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useSuspenseQuery({
        queryKey: getDomainNextVibeMetricsKey(options.params),
        queryFn: ()=>getDomainNextVibeMetrics(options.params),
        ...options?.query
    });
}
export interface GetProductDetailParams {
    business_id: string;
    version_int: number;
    scope: string;
    domain_name: string;
    product_name: string;
}
export const getProductDetail = async (params: GetProductDetailParams, options?: RequestInit): Promise<{
    data: ProductDetailOut;
}> =>{
    const res = await fetch(`/api/businesses/${params.business_id}/versions/${params.version_int}/${params.scope}/domains/${params.domain_name}/products/${params.product_name}`, {
        ...options,
        method: "GET"
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export const getProductDetailKey = (params?: GetProductDetailParams)=>{
    return [
        "/api/businesses/{business_id}/versions/{version_int}/{scope}/domains/{domain_name}/products/{product_name}",
        params
    ] as const;
};
export function useGetProductDetail<TData = {
    data: ProductDetailOut;
}>(options: {
    params: GetProductDetailParams;
    query?: Omit<UseQueryOptions<{
        data: ProductDetailOut;
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useQuery({
        queryKey: getProductDetailKey(options.params),
        queryFn: ()=>getProductDetail(options.params),
        ...options?.query
    });
}
export function useGetProductDetailSuspense<TData = {
    data: ProductDetailOut;
}>(options: {
    params: GetProductDetailParams;
    query?: Omit<UseSuspenseQueryOptions<{
        data: ProductDetailOut;
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useSuspenseQuery({
        queryKey: getProductDetailKey(options.params),
        queryFn: ()=>getProductDetail(options.params),
        ...options?.query
    });
}
export interface GetEvolutionMetricsParams {
    business_id: string;
    version_int: number;
    scope: string;
}
export const getEvolutionMetrics = async (params: GetEvolutionMetricsParams, options?: RequestInit): Promise<{
    data: EvolutionMetricsOut;
}> =>{
    const res = await fetch(`/api/businesses/${params.business_id}/versions/${params.version_int}/${params.scope}/evolution-metrics`, {
        ...options,
        method: "GET"
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export const getEvolutionMetricsKey = (params?: GetEvolutionMetricsParams)=>{
    return [
        "/api/businesses/{business_id}/versions/{version_int}/{scope}/evolution-metrics",
        params
    ] as const;
};
export function useGetEvolutionMetrics<TData = {
    data: EvolutionMetricsOut;
}>(options: {
    params: GetEvolutionMetricsParams;
    query?: Omit<UseQueryOptions<{
        data: EvolutionMetricsOut;
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useQuery({
        queryKey: getEvolutionMetricsKey(options.params),
        queryFn: ()=>getEvolutionMetrics(options.params),
        ...options?.query
    });
}
export function useGetEvolutionMetricsSuspense<TData = {
    data: EvolutionMetricsOut;
}>(options: {
    params: GetEvolutionMetricsParams;
    query?: Omit<UseSuspenseQueryOptions<{
        data: EvolutionMetricsOut;
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useSuspenseQuery({
        queryKey: getEvolutionMetricsKey(options.params),
        queryFn: ()=>getEvolutionMetrics(options.params),
        ...options?.query
    });
}
export interface GetModelSummaryParams {
    business_id: string;
    version_int: number;
    scope: string;
}
export const getModelSummary = async (params: GetModelSummaryParams, options?: RequestInit): Promise<{
    data: ModelSummaryOut;
}> =>{
    const res = await fetch(`/api/businesses/${params.business_id}/versions/${params.version_int}/${params.scope}/model`, {
        ...options,
        method: "GET"
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export const getModelSummaryKey = (params?: GetModelSummaryParams)=>{
    return [
        "/api/businesses/{business_id}/versions/{version_int}/{scope}/model",
        params
    ] as const;
};
export function useGetModelSummary<TData = {
    data: ModelSummaryOut;
}>(options: {
    params: GetModelSummaryParams;
    query?: Omit<UseQueryOptions<{
        data: ModelSummaryOut;
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useQuery({
        queryKey: getModelSummaryKey(options.params),
        queryFn: ()=>getModelSummary(options.params),
        ...options?.query
    });
}
export function useGetModelSummarySuspense<TData = {
    data: ModelSummaryOut;
}>(options: {
    params: GetModelSummaryParams;
    query?: Omit<UseSuspenseQueryOptions<{
        data: ModelSummaryOut;
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useSuspenseQuery({
        queryKey: getModelSummaryKey(options.params),
        queryFn: ()=>getModelSummary(options.params),
        ...options?.query
    });
}
export interface GetNextVibeMetricsParams {
    business_id: string;
    version_int: number;
    scope: string;
}
export const getNextVibeMetrics = async (params: GetNextVibeMetricsParams, options?: RequestInit): Promise<{
    data: NextVibeMetricsOut;
}> =>{
    const res = await fetch(`/api/businesses/${params.business_id}/versions/${params.version_int}/${params.scope}/next-vibe-metrics`, {
        ...options,
        method: "GET"
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export const getNextVibeMetricsKey = (params?: GetNextVibeMetricsParams)=>{
    return [
        "/api/businesses/{business_id}/versions/{version_int}/{scope}/next-vibe-metrics",
        params
    ] as const;
};
export function useGetNextVibeMetrics<TData = {
    data: NextVibeMetricsOut;
}>(options: {
    params: GetNextVibeMetricsParams;
    query?: Omit<UseQueryOptions<{
        data: NextVibeMetricsOut;
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useQuery({
        queryKey: getNextVibeMetricsKey(options.params),
        queryFn: ()=>getNextVibeMetrics(options.params),
        ...options?.query
    });
}
export function useGetNextVibeMetricsSuspense<TData = {
    data: NextVibeMetricsOut;
}>(options: {
    params: GetNextVibeMetricsParams;
    query?: Omit<UseSuspenseQueryOptions<{
        data: NextVibeMetricsOut;
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useSuspenseQuery({
        queryKey: getNextVibeMetricsKey(options.params),
        queryFn: ()=>getNextVibeMetrics(options.params),
        ...options?.query
    });
}
export interface GetRelationshipAnalysisParams {
    business_id: string;
    version_int: number;
    scope: string;
}
export const getRelationshipAnalysis = async (params: GetRelationshipAnalysisParams, options?: RequestInit): Promise<{
    data: RelationshipAnalysisOut;
}> =>{
    const res = await fetch(`/api/businesses/${params.business_id}/versions/${params.version_int}/${params.scope}/relationships`, {
        ...options,
        method: "GET"
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export const getRelationshipAnalysisKey = (params?: GetRelationshipAnalysisParams)=>{
    return [
        "/api/businesses/{business_id}/versions/{version_int}/{scope}/relationships",
        params
    ] as const;
};
export function useGetRelationshipAnalysis<TData = {
    data: RelationshipAnalysisOut;
}>(options: {
    params: GetRelationshipAnalysisParams;
    query?: Omit<UseQueryOptions<{
        data: RelationshipAnalysisOut;
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useQuery({
        queryKey: getRelationshipAnalysisKey(options.params),
        queryFn: ()=>getRelationshipAnalysis(options.params),
        ...options?.query
    });
}
export function useGetRelationshipAnalysisSuspense<TData = {
    data: RelationshipAnalysisOut;
}>(options: {
    params: GetRelationshipAnalysisParams;
    query?: Omit<UseSuspenseQueryOptions<{
        data: RelationshipAnalysisOut;
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useSuspenseQuery({
        queryKey: getRelationshipAnalysisKey(options.params),
        queryFn: ()=>getRelationshipAnalysis(options.params),
        ...options?.query
    });
}
export interface GetReviewProgressParams {
    business_id: string;
    version_int: number;
    scope: string;
}
export const getReviewProgress = async (params: GetReviewProgressParams, options?: RequestInit): Promise<{
    data: ReviewProgressOut;
}> =>{
    const res = await fetch(`/api/businesses/${params.business_id}/versions/${params.version_int}/${params.scope}/review-progress`, {
        ...options,
        method: "GET"
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export const getReviewProgressKey = (params?: GetReviewProgressParams)=>{
    return [
        "/api/businesses/{business_id}/versions/{version_int}/{scope}/review-progress",
        params
    ] as const;
};
export function useGetReviewProgress<TData = {
    data: ReviewProgressOut;
}>(options: {
    params: GetReviewProgressParams;
    query?: Omit<UseQueryOptions<{
        data: ReviewProgressOut;
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useQuery({
        queryKey: getReviewProgressKey(options.params),
        queryFn: ()=>getReviewProgress(options.params),
        ...options?.query
    });
}
export function useGetReviewProgressSuspense<TData = {
    data: ReviewProgressOut;
}>(options: {
    params: GetReviewProgressParams;
    query?: Omit<UseSuspenseQueryOptions<{
        data: ReviewProgressOut;
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useSuspenseQuery({
        queryKey: getReviewProgressKey(options.params),
        queryFn: ()=>getReviewProgress(options.params),
        ...options?.query
    });
}
export interface GetReviewProgressByDomainParams {
    business_id: string;
    version_int: number;
    scope: string;
}
export const getReviewProgressByDomain = async (params: GetReviewProgressByDomainParams, options?: RequestInit): Promise<{
    data: DomainReviewProgressOut[];
}> =>{
    const res = await fetch(`/api/businesses/${params.business_id}/versions/${params.version_int}/${params.scope}/review-progress/by-domain`, {
        ...options,
        method: "GET"
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export const getReviewProgressByDomainKey = (params?: GetReviewProgressByDomainParams)=>{
    return [
        "/api/businesses/{business_id}/versions/{version_int}/{scope}/review-progress/by-domain",
        params
    ] as const;
};
export function useGetReviewProgressByDomain<TData = {
    data: DomainReviewProgressOut[];
}>(options: {
    params: GetReviewProgressByDomainParams;
    query?: Omit<UseQueryOptions<{
        data: DomainReviewProgressOut[];
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useQuery({
        queryKey: getReviewProgressByDomainKey(options.params),
        queryFn: ()=>getReviewProgressByDomain(options.params),
        ...options?.query
    });
}
export function useGetReviewProgressByDomainSuspense<TData = {
    data: DomainReviewProgressOut[];
}>(options: {
    params: GetReviewProgressByDomainParams;
    query?: Omit<UseSuspenseQueryOptions<{
        data: DomainReviewProgressOut[];
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useSuspenseQuery({
        queryKey: getReviewProgressByDomainKey(options.params),
        queryFn: ()=>getReviewProgressByDomain(options.params),
        ...options?.query
    });
}
export interface ListProductReviewsParams {
    business_id: string;
    version_int: number;
    scope: string;
}
export const listProductReviews = async (params: ListProductReviewsParams, options?: RequestInit): Promise<{
    data: ProductReviewOut[];
}> =>{
    const res = await fetch(`/api/businesses/${params.business_id}/versions/${params.version_int}/${params.scope}/reviews`, {
        ...options,
        method: "GET"
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export const listProductReviewsKey = (params?: ListProductReviewsParams)=>{
    return [
        "/api/businesses/{business_id}/versions/{version_int}/{scope}/reviews",
        params
    ] as const;
};
export function useListProductReviews<TData = {
    data: ProductReviewOut[];
}>(options: {
    params: ListProductReviewsParams;
    query?: Omit<UseQueryOptions<{
        data: ProductReviewOut[];
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useQuery({
        queryKey: listProductReviewsKey(options.params),
        queryFn: ()=>listProductReviews(options.params),
        ...options?.query
    });
}
export function useListProductReviewsSuspense<TData = {
    data: ProductReviewOut[];
}>(options: {
    params: ListProductReviewsParams;
    query?: Omit<UseSuspenseQueryOptions<{
        data: ProductReviewOut[];
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useSuspenseQuery({
        queryKey: listProductReviewsKey(options.params),
        queryFn: ()=>listProductReviews(options.params),
        ...options?.query
    });
}
export interface MarkDomainReviewParams {
    business_id: string;
    version_int: number;
    scope: string;
    domain_id: string;
    "X-Forwarded-Host"?: string | null;
    "X-Forwarded-Preferred-Username"?: string | null;
    "X-Forwarded-User"?: string | null;
    "X-Forwarded-Email"?: string | null;
    "X-Request-Id"?: string | null;
    "X-Forwarded-Access-Token"?: string | null;
}
export const markDomainReview = async (params: MarkDomainReviewParams, data: ReviewMarkIn, options?: RequestInit): Promise<{
    data: ReviewCascadeOut;
}> =>{
    const res = await fetch(`/api/businesses/${params.business_id}/versions/${params.version_int}/${params.scope}/reviews/domain/${params.domain_id}`, {
        ...options,
        method: "POST",
        headers: {
            "Content-Type": "application/json",
            ...(params?.["X-Forwarded-Host"] != null && {
                "X-Forwarded-Host": params["X-Forwarded-Host"]
            }),
            ...(params?.["X-Forwarded-Preferred-Username"] != null && {
                "X-Forwarded-Preferred-Username": params["X-Forwarded-Preferred-Username"]
            }),
            ...(params?.["X-Forwarded-User"] != null && {
                "X-Forwarded-User": params["X-Forwarded-User"]
            }),
            ...(params?.["X-Forwarded-Email"] != null && {
                "X-Forwarded-Email": params["X-Forwarded-Email"]
            }),
            ...(params?.["X-Request-Id"] != null && {
                "X-Request-Id": params["X-Request-Id"]
            }),
            ...(params?.["X-Forwarded-Access-Token"] != null && {
                "X-Forwarded-Access-Token": params["X-Forwarded-Access-Token"]
            }),
            ...options?.headers
        },
        body: JSON.stringify(data)
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export function useMarkDomainReview(options?: {
    mutation?: UseMutationOptions<{
        data: ReviewCascadeOut;
    }, ApiError, {
        params: MarkDomainReviewParams;
        data: ReviewMarkIn;
    }>;
}) {
    return useMutation({
        mutationFn: (vars)=>markDomainReview(vars.params, vars.data),
        ...options?.mutation
    });
}
export interface MarkProductReviewParams {
    business_id: string;
    version_int: number;
    scope: string;
    product_id: string;
    "X-Forwarded-Host"?: string | null;
    "X-Forwarded-Preferred-Username"?: string | null;
    "X-Forwarded-User"?: string | null;
    "X-Forwarded-Email"?: string | null;
    "X-Request-Id"?: string | null;
    "X-Forwarded-Access-Token"?: string | null;
}
export const markProductReview = async (params: MarkProductReviewParams, data: ReviewMarkIn, options?: RequestInit): Promise<{
    data: ProductReviewOut;
}> =>{
    const res = await fetch(`/api/businesses/${params.business_id}/versions/${params.version_int}/${params.scope}/reviews/product/${params.product_id}`, {
        ...options,
        method: "POST",
        headers: {
            "Content-Type": "application/json",
            ...(params?.["X-Forwarded-Host"] != null && {
                "X-Forwarded-Host": params["X-Forwarded-Host"]
            }),
            ...(params?.["X-Forwarded-Preferred-Username"] != null && {
                "X-Forwarded-Preferred-Username": params["X-Forwarded-Preferred-Username"]
            }),
            ...(params?.["X-Forwarded-User"] != null && {
                "X-Forwarded-User": params["X-Forwarded-User"]
            }),
            ...(params?.["X-Forwarded-Email"] != null && {
                "X-Forwarded-Email": params["X-Forwarded-Email"]
            }),
            ...(params?.["X-Request-Id"] != null && {
                "X-Request-Id": params["X-Request-Id"]
            }),
            ...(params?.["X-Forwarded-Access-Token"] != null && {
                "X-Forwarded-Access-Token": params["X-Forwarded-Access-Token"]
            }),
            ...options?.headers
        },
        body: JSON.stringify(data)
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export function useMarkProductReview(options?: {
    mutation?: UseMutationOptions<{
        data: ProductReviewOut;
    }, ApiError, {
        params: MarkProductReviewParams;
        data: ReviewMarkIn;
    }>;
}) {
    return useMutation({
        mutationFn: (vars)=>markProductReview(vars.params, vars.data),
        ...options?.mutation
    });
}
export interface ClearProductReviewParams {
    business_id: string;
    version_int: number;
    scope: string;
    product_id: string;
    "X-Forwarded-Host"?: string | null;
    "X-Forwarded-Preferred-Username"?: string | null;
    "X-Forwarded-User"?: string | null;
    "X-Forwarded-Email"?: string | null;
    "X-Request-Id"?: string | null;
    "X-Forwarded-Access-Token"?: string | null;
}
export const clearProductReview = async (params: ClearProductReviewParams, options?: RequestInit): Promise<{
    data: Record<string, unknown>;
}> =>{
    const res = await fetch(`/api/businesses/${params.business_id}/versions/${params.version_int}/${params.scope}/reviews/product/${params.product_id}`, {
        ...options,
        method: "DELETE",
        headers: {
            ...(params?.["X-Forwarded-Host"] != null && {
                "X-Forwarded-Host": params["X-Forwarded-Host"]
            }),
            ...(params?.["X-Forwarded-Preferred-Username"] != null && {
                "X-Forwarded-Preferred-Username": params["X-Forwarded-Preferred-Username"]
            }),
            ...(params?.["X-Forwarded-User"] != null && {
                "X-Forwarded-User": params["X-Forwarded-User"]
            }),
            ...(params?.["X-Forwarded-Email"] != null && {
                "X-Forwarded-Email": params["X-Forwarded-Email"]
            }),
            ...(params?.["X-Request-Id"] != null && {
                "X-Request-Id": params["X-Request-Id"]
            }),
            ...(params?.["X-Forwarded-Access-Token"] != null && {
                "X-Forwarded-Access-Token": params["X-Forwarded-Access-Token"]
            }),
            ...options?.headers
        }
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export function useClearProductReview(options?: {
    mutation?: UseMutationOptions<{
        data: Record<string, unknown>;
    }, ApiError, {
        params: ClearProductReviewParams;
    }>;
}) {
    return useMutation({
        mutationFn: (vars)=>clearProductReview(vars.params),
        ...options?.mutation
    });
}
export interface MarkSubdomainReviewParams {
    business_id: string;
    version_int: number;
    scope: string;
    subdomain_id: string;
    "X-Forwarded-Host"?: string | null;
    "X-Forwarded-Preferred-Username"?: string | null;
    "X-Forwarded-User"?: string | null;
    "X-Forwarded-Email"?: string | null;
    "X-Request-Id"?: string | null;
    "X-Forwarded-Access-Token"?: string | null;
}
export const markSubdomainReview = async (params: MarkSubdomainReviewParams, data: ReviewMarkIn, options?: RequestInit): Promise<{
    data: ReviewCascadeOut;
}> =>{
    const res = await fetch(`/api/businesses/${params.business_id}/versions/${params.version_int}/${params.scope}/reviews/subdomain/${params.subdomain_id}`, {
        ...options,
        method: "POST",
        headers: {
            "Content-Type": "application/json",
            ...(params?.["X-Forwarded-Host"] != null && {
                "X-Forwarded-Host": params["X-Forwarded-Host"]
            }),
            ...(params?.["X-Forwarded-Preferred-Username"] != null && {
                "X-Forwarded-Preferred-Username": params["X-Forwarded-Preferred-Username"]
            }),
            ...(params?.["X-Forwarded-User"] != null && {
                "X-Forwarded-User": params["X-Forwarded-User"]
            }),
            ...(params?.["X-Forwarded-Email"] != null && {
                "X-Forwarded-Email": params["X-Forwarded-Email"]
            }),
            ...(params?.["X-Request-Id"] != null && {
                "X-Request-Id": params["X-Request-Id"]
            }),
            ...(params?.["X-Forwarded-Access-Token"] != null && {
                "X-Forwarded-Access-Token": params["X-Forwarded-Access-Token"]
            }),
            ...options?.headers
        },
        body: JSON.stringify(data)
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export function useMarkSubdomainReview(options?: {
    mutation?: UseMutationOptions<{
        data: ReviewCascadeOut;
    }, ApiError, {
        params: MarkSubdomainReviewParams;
        data: ReviewMarkIn;
    }>;
}) {
    return useMutation({
        mutationFn: (vars)=>markSubdomainReview(vars.params, vars.data),
        ...options?.mutation
    });
}
export interface SearchModelElementsParams {
    business_id: string;
    version_int: number;
    scope: string;
    q?: string;
    limit?: number;
}
export const searchModelElements = async (params: SearchModelElementsParams, options?: RequestInit): Promise<{
    data: ModelSearchHitOut[];
}> =>{
    const searchParams = new URLSearchParams();
    if (params?.q != null) searchParams.set("q", String(params?.q));
    if (params?.limit != null) searchParams.set("limit", String(params?.limit));
    const queryString = searchParams.toString();
    const url = queryString ? `/api/businesses/${params.business_id}/versions/${params.version_int}/${params.scope}/search?${queryString}` : `/api/businesses/${params.business_id}/versions/${params.version_int}/${params.scope}/search`;
    const res = await fetch(url, {
        ...options,
        method: "GET"
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export const searchModelElementsKey = (params?: SearchModelElementsParams)=>{
    return [
        "/api/businesses/{business_id}/versions/{version_int}/{scope}/search",
        params
    ] as const;
};
export function useSearchModelElements<TData = {
    data: ModelSearchHitOut[];
}>(options: {
    params: SearchModelElementsParams;
    query?: Omit<UseQueryOptions<{
        data: ModelSearchHitOut[];
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useQuery({
        queryKey: searchModelElementsKey(options.params),
        queryFn: ()=>searchModelElements(options.params),
        ...options?.query
    });
}
export function useSearchModelElementsSuspense<TData = {
    data: ModelSearchHitOut[];
}>(options: {
    params: SearchModelElementsParams;
    query?: Omit<UseSuspenseQueryOptions<{
        data: ModelSearchHitOut[];
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useSuspenseQuery({
        queryKey: searchModelElementsKey(options.params),
        queryFn: ()=>searchModelElements(options.params),
        ...options?.query
    });
}
export interface GetStatisticsReportXlsxParams {
    business_id: string;
    version_int: number;
    scope: string;
}
export const getStatisticsReportXlsx = async (params: GetStatisticsReportXlsxParams, options?: RequestInit): Promise<{
    data: unknown;
}> =>{
    const res = await fetch(`/api/businesses/${params.business_id}/versions/${params.version_int}/${params.scope}/statistics-report.xlsx`, {
        ...options,
        method: "GET"
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export const getStatisticsReportXlsxKey = (params?: GetStatisticsReportXlsxParams)=>{
    return [
        "/api/businesses/{business_id}/versions/{version_int}/{scope}/statistics-report.xlsx",
        params
    ] as const;
};
export function useGetStatisticsReportXlsx<TData = {
    data: unknown;
}>(options: {
    params: GetStatisticsReportXlsxParams;
    query?: Omit<UseQueryOptions<{
        data: unknown;
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useQuery({
        queryKey: getStatisticsReportXlsxKey(options.params),
        queryFn: ()=>getStatisticsReportXlsx(options.params),
        ...options?.query
    });
}
export function useGetStatisticsReportXlsxSuspense<TData = {
    data: unknown;
}>(options: {
    params: GetStatisticsReportXlsxParams;
    query?: Omit<UseSuspenseQueryOptions<{
        data: unknown;
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useSuspenseQuery({
        queryKey: getStatisticsReportXlsxKey(options.params),
        queryFn: ()=>getStatisticsReportXlsx(options.params),
        ...options?.query
    });
}
export const listCatalogs = async (options?: RequestInit): Promise<{
    data: CatalogOut[];
}> =>{
    const res = await fetch("/api/catalogs", {
        ...options,
        method: "GET"
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export const listCatalogsKey = ()=>{
    return [
        "/api/catalogs"
    ] as const;
};
export function useListCatalogs<TData = {
    data: CatalogOut[];
}>(options?: {
    query?: Omit<UseQueryOptions<{
        data: CatalogOut[];
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useQuery({
        queryKey: listCatalogsKey(),
        queryFn: ()=>listCatalogs(),
        ...options?.query
    });
}
export function useListCatalogsSuspense<TData = {
    data: CatalogOut[];
}>(options?: {
    query?: Omit<UseSuspenseQueryOptions<{
        data: CatalogOut[];
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useSuspenseQuery({
        queryKey: listCatalogsKey(),
        queryFn: ()=>listCatalogs(),
        ...options?.query
    });
}
export interface GetCatalogCapabilitiesParams {
    names?: string[];
}
export const getCatalogCapabilities = async (params?: GetCatalogCapabilitiesParams, options?: RequestInit): Promise<{
    data: CatalogCapabilityOut[];
}> =>{
    const searchParams = new URLSearchParams();
    if (params?.names != null) params?.names.forEach((v)=>searchParams.append("names", String(v)));
    const queryString = searchParams.toString();
    const url = queryString ? `/api/catalogs/capabilities?${queryString}` : "/api/catalogs/capabilities";
    const res = await fetch(url, {
        ...options,
        method: "GET"
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export const getCatalogCapabilitiesKey = (params?: GetCatalogCapabilitiesParams)=>{
    return [
        "/api/catalogs/capabilities",
        params
    ] as const;
};
export function useGetCatalogCapabilities<TData = {
    data: CatalogCapabilityOut[];
}>(options?: {
    params?: GetCatalogCapabilitiesParams;
    query?: Omit<UseQueryOptions<{
        data: CatalogCapabilityOut[];
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useQuery({
        queryKey: getCatalogCapabilitiesKey(options?.params),
        queryFn: ()=>getCatalogCapabilities(options?.params),
        ...options?.query
    });
}
export function useGetCatalogCapabilitiesSuspense<TData = {
    data: CatalogCapabilityOut[];
}>(options?: {
    params?: GetCatalogCapabilitiesParams;
    query?: Omit<UseSuspenseQueryOptions<{
        data: CatalogCapabilityOut[];
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useSuspenseQuery({
        queryKey: getCatalogCapabilitiesKey(options?.params),
        queryFn: ()=>getCatalogCapabilities(options?.params),
        ...options?.query
    });
}
export interface ReportClientGatewayErrorParams {
    "X-Forwarded-Host"?: string | null;
    "X-Forwarded-Preferred-Username"?: string | null;
    "X-Forwarded-User"?: string | null;
    "X-Forwarded-Email"?: string | null;
    "X-Request-Id"?: string | null;
    "X-Forwarded-Access-Token"?: string | null;
}
export const reportClientGatewayError = async (data: ClientGatewayErrorIn, params?: ReportClientGatewayErrorParams, options?: RequestInit): Promise<{
    data: ClientTelemetryAck;
}> =>{
    const res = await fetch("/api/client-telemetry/gateway-error", {
        ...options,
        method: "POST",
        headers: {
            "Content-Type": "application/json",
            ...(params?.["X-Forwarded-Host"] != null && {
                "X-Forwarded-Host": params["X-Forwarded-Host"]
            }),
            ...(params?.["X-Forwarded-Preferred-Username"] != null && {
                "X-Forwarded-Preferred-Username": params["X-Forwarded-Preferred-Username"]
            }),
            ...(params?.["X-Forwarded-User"] != null && {
                "X-Forwarded-User": params["X-Forwarded-User"]
            }),
            ...(params?.["X-Forwarded-Email"] != null && {
                "X-Forwarded-Email": params["X-Forwarded-Email"]
            }),
            ...(params?.["X-Request-Id"] != null && {
                "X-Request-Id": params["X-Request-Id"]
            }),
            ...(params?.["X-Forwarded-Access-Token"] != null && {
                "X-Forwarded-Access-Token": params["X-Forwarded-Access-Token"]
            }),
            ...options?.headers
        },
        body: JSON.stringify(data)
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export function useReportClientGatewayError(options?: {
    mutation?: UseMutationOptions<{
        data: ClientTelemetryAck;
    }, ApiError, {
        params: ReportClientGatewayErrorParams;
        data: ClientGatewayErrorIn;
    }>;
}) {
    return useMutation({
        mutationFn: (vars)=>reportClientGatewayError(vars.data, vars.params),
        ...options?.mutation
    });
}
export const getAgentConfig = async (options?: RequestInit): Promise<{
    data: AgentConfigOut;
}> =>{
    const res = await fetch("/api/config/agent", {
        ...options,
        method: "GET"
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export const getAgentConfigKey = ()=>{
    return [
        "/api/config/agent"
    ] as const;
};
export function useGetAgentConfig<TData = {
    data: AgentConfigOut;
}>(options?: {
    query?: Omit<UseQueryOptions<{
        data: AgentConfigOut;
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useQuery({
        queryKey: getAgentConfigKey(),
        queryFn: ()=>getAgentConfig(),
        ...options?.query
    });
}
export function useGetAgentConfigSuspense<TData = {
    data: AgentConfigOut;
}>(options?: {
    query?: Omit<UseSuspenseQueryOptions<{
        data: AgentConfigOut;
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useSuspenseQuery({
        queryKey: getAgentConfigKey(),
        queryFn: ()=>getAgentConfig(),
        ...options?.query
    });
}
export interface SetAgentConfigParams {
    "X-Forwarded-Host"?: string | null;
    "X-Forwarded-Preferred-Username"?: string | null;
    "X-Forwarded-User"?: string | null;
    "X-Forwarded-Email"?: string | null;
    "X-Request-Id"?: string | null;
    "X-Forwarded-Access-Token"?: string | null;
}
export const setAgentConfig = async (data: AgentConfigIn, params?: SetAgentConfigParams, options?: RequestInit): Promise<{
    data: AgentConfigOut;
}> =>{
    const res = await fetch("/api/config/agent", {
        ...options,
        method: "PUT",
        headers: {
            "Content-Type": "application/json",
            ...(params?.["X-Forwarded-Host"] != null && {
                "X-Forwarded-Host": params["X-Forwarded-Host"]
            }),
            ...(params?.["X-Forwarded-Preferred-Username"] != null && {
                "X-Forwarded-Preferred-Username": params["X-Forwarded-Preferred-Username"]
            }),
            ...(params?.["X-Forwarded-User"] != null && {
                "X-Forwarded-User": params["X-Forwarded-User"]
            }),
            ...(params?.["X-Forwarded-Email"] != null && {
                "X-Forwarded-Email": params["X-Forwarded-Email"]
            }),
            ...(params?.["X-Request-Id"] != null && {
                "X-Request-Id": params["X-Request-Id"]
            }),
            ...(params?.["X-Forwarded-Access-Token"] != null && {
                "X-Forwarded-Access-Token": params["X-Forwarded-Access-Token"]
            }),
            ...options?.headers
        },
        body: JSON.stringify(data)
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export function useSetAgentConfig(options?: {
    mutation?: UseMutationOptions<{
        data: AgentConfigOut;
    }, ApiError, {
        params: SetAgentConfigParams;
        data: AgentConfigIn;
    }>;
}) {
    return useMutation({
        mutationFn: (vars)=>setAgentConfig(vars.data, vars.params),
        ...options?.mutation
    });
}
export const getAgentCompat = async (options?: RequestInit): Promise<{
    data: AgentCompatOut;
}> =>{
    const res = await fetch("/api/config/agent-compat", {
        ...options,
        method: "GET"
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export const getAgentCompatKey = ()=>{
    return [
        "/api/config/agent-compat"
    ] as const;
};
export function useGetAgentCompat<TData = {
    data: AgentCompatOut;
}>(options?: {
    query?: Omit<UseQueryOptions<{
        data: AgentCompatOut;
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useQuery({
        queryKey: getAgentCompatKey(),
        queryFn: ()=>getAgentCompat(),
        ...options?.query
    });
}
export function useGetAgentCompatSuspense<TData = {
    data: AgentCompatOut;
}>(options?: {
    query?: Omit<UseSuspenseQueryOptions<{
        data: AgentCompatOut;
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useSuspenseQuery({
        queryKey: getAgentCompatKey(),
        queryFn: ()=>getAgentCompat(),
        ...options?.query
    });
}
export interface CheckAgentNotebookParams {
    path: string;
}
export const checkAgentNotebook = async (params: CheckAgentNotebookParams, options?: RequestInit): Promise<{
    data: Record<string, unknown>;
}> =>{
    const searchParams = new URLSearchParams();
    if (params.path != null) searchParams.set("path", String(params.path));
    const queryString = searchParams.toString();
    const url = queryString ? `/api/config/agent/check-notebook?${queryString}` : "/api/config/agent/check-notebook";
    const res = await fetch(url, {
        ...options,
        method: "GET"
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export const checkAgentNotebookKey = (params?: CheckAgentNotebookParams)=>{
    return [
        "/api/config/agent/check-notebook",
        params
    ] as const;
};
export function useCheckAgentNotebook<TData = {
    data: Record<string, unknown>;
}>(options: {
    params: CheckAgentNotebookParams;
    query?: Omit<UseQueryOptions<{
        data: Record<string, unknown>;
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useQuery({
        queryKey: checkAgentNotebookKey(options.params),
        queryFn: ()=>checkAgentNotebook(options.params),
        ...options?.query
    });
}
export function useCheckAgentNotebookSuspense<TData = {
    data: Record<string, unknown>;
}>(options: {
    params: CheckAgentNotebookParams;
    query?: Omit<UseSuspenseQueryOptions<{
        data: Record<string, unknown>;
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useSuspenseQuery({
        queryKey: checkAgentNotebookKey(options.params),
        queryFn: ()=>checkAgentNotebook(options.params),
        ...options?.query
    });
}
export const getAgentReady = async (options?: RequestInit): Promise<{
    data: Record<string, unknown>;
}> =>{
    const res = await fetch("/api/config/agent/ready", {
        ...options,
        method: "GET"
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export const getAgentReadyKey = ()=>{
    return [
        "/api/config/agent/ready"
    ] as const;
};
export function useGetAgentReady<TData = {
    data: Record<string, unknown>;
}>(options?: {
    query?: Omit<UseQueryOptions<{
        data: Record<string, unknown>;
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useQuery({
        queryKey: getAgentReadyKey(),
        queryFn: ()=>getAgentReady(),
        ...options?.query
    });
}
export function useGetAgentReadySuspense<TData = {
    data: Record<string, unknown>;
}>(options?: {
    query?: Omit<UseSuspenseQueryOptions<{
        data: Record<string, unknown>;
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useSuspenseQuery({
        queryKey: getAgentReadyKey(),
        queryFn: ()=>getAgentReady(),
        ...options?.query
    });
}
export const getSupportedAgentVersion = async (options?: RequestInit): Promise<{
    data: Record<string, unknown>;
}> =>{
    const res = await fetch("/api/config/agent/supported-version", {
        ...options,
        method: "GET"
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export const getSupportedAgentVersionKey = ()=>{
    return [
        "/api/config/agent/supported-version"
    ] as const;
};
export function useGetSupportedAgentVersion<TData = {
    data: Record<string, unknown>;
}>(options?: {
    query?: Omit<UseQueryOptions<{
        data: Record<string, unknown>;
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useQuery({
        queryKey: getSupportedAgentVersionKey(),
        queryFn: ()=>getSupportedAgentVersion(),
        ...options?.query
    });
}
export function useGetSupportedAgentVersionSuspense<TData = {
    data: Record<string, unknown>;
}>(options?: {
    query?: Omit<UseSuspenseQueryOptions<{
        data: Record<string, unknown>;
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useSuspenseQuery({
        queryKey: getSupportedAgentVersionKey(),
        queryFn: ()=>getSupportedAgentVersion(),
        ...options?.query
    });
}
export interface VerifyAgentConfigParams {
    "X-Forwarded-Host"?: string | null;
    "X-Forwarded-Preferred-Username"?: string | null;
    "X-Forwarded-User"?: string | null;
    "X-Forwarded-Email"?: string | null;
    "X-Request-Id"?: string | null;
    "X-Forwarded-Access-Token"?: string | null;
}
export const verifyAgentConfig = async (data: AgentConfigIn, params?: VerifyAgentConfigParams, options?: RequestInit): Promise<{
    data: Record<string, unknown>;
}> =>{
    const res = await fetch("/api/config/agent/verify", {
        ...options,
        method: "POST",
        headers: {
            "Content-Type": "application/json",
            ...(params?.["X-Forwarded-Host"] != null && {
                "X-Forwarded-Host": params["X-Forwarded-Host"]
            }),
            ...(params?.["X-Forwarded-Preferred-Username"] != null && {
                "X-Forwarded-Preferred-Username": params["X-Forwarded-Preferred-Username"]
            }),
            ...(params?.["X-Forwarded-User"] != null && {
                "X-Forwarded-User": params["X-Forwarded-User"]
            }),
            ...(params?.["X-Forwarded-Email"] != null && {
                "X-Forwarded-Email": params["X-Forwarded-Email"]
            }),
            ...(params?.["X-Request-Id"] != null && {
                "X-Request-Id": params["X-Request-Id"]
            }),
            ...(params?.["X-Forwarded-Access-Token"] != null && {
                "X-Forwarded-Access-Token": params["X-Forwarded-Access-Token"]
            }),
            ...options?.headers
        },
        body: JSON.stringify(data)
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export function useVerifyAgentConfig(options?: {
    mutation?: UseMutationOptions<{
        data: Record<string, unknown>;
    }, ApiError, {
        params: VerifyAgentConfigParams;
        data: AgentConfigIn;
    }>;
}) {
    return useMutation({
        mutationFn: (vars)=>verifyAgentConfig(vars.data, vars.params),
        ...options?.mutation
    });
}
export const getDeploymentCatalog = async (options?: RequestInit): Promise<{
    data: Record<string, unknown>;
}> =>{
    const res = await fetch("/api/config/deployment-catalog", {
        ...options,
        method: "GET"
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export const getDeploymentCatalogKey = ()=>{
    return [
        "/api/config/deployment-catalog"
    ] as const;
};
export function useGetDeploymentCatalog<TData = {
    data: Record<string, unknown>;
}>(options?: {
    query?: Omit<UseQueryOptions<{
        data: Record<string, unknown>;
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useQuery({
        queryKey: getDeploymentCatalogKey(),
        queryFn: ()=>getDeploymentCatalog(),
        ...options?.query
    });
}
export function useGetDeploymentCatalogSuspense<TData = {
    data: Record<string, unknown>;
}>(options?: {
    query?: Omit<UseSuspenseQueryOptions<{
        data: Record<string, unknown>;
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useSuspenseQuery({
        queryKey: getDeploymentCatalogKey(),
        queryFn: ()=>getDeploymentCatalog(),
        ...options?.query
    });
}
export interface SetDeploymentCatalogParams {
    "X-Forwarded-Host"?: string | null;
    "X-Forwarded-Preferred-Username"?: string | null;
    "X-Forwarded-User"?: string | null;
    "X-Forwarded-Email"?: string | null;
    "X-Request-Id"?: string | null;
    "X-Forwarded-Access-Token"?: string | null;
}
export const setDeploymentCatalog = async (data: DeploymentCatalogIn, params?: SetDeploymentCatalogParams, options?: RequestInit): Promise<{
    data: Record<string, unknown>;
}> =>{
    const res = await fetch("/api/config/deployment-catalog", {
        ...options,
        method: "PUT",
        headers: {
            "Content-Type": "application/json",
            ...(params?.["X-Forwarded-Host"] != null && {
                "X-Forwarded-Host": params["X-Forwarded-Host"]
            }),
            ...(params?.["X-Forwarded-Preferred-Username"] != null && {
                "X-Forwarded-Preferred-Username": params["X-Forwarded-Preferred-Username"]
            }),
            ...(params?.["X-Forwarded-User"] != null && {
                "X-Forwarded-User": params["X-Forwarded-User"]
            }),
            ...(params?.["X-Forwarded-Email"] != null && {
                "X-Forwarded-Email": params["X-Forwarded-Email"]
            }),
            ...(params?.["X-Request-Id"] != null && {
                "X-Request-Id": params["X-Request-Id"]
            }),
            ...(params?.["X-Forwarded-Access-Token"] != null && {
                "X-Forwarded-Access-Token": params["X-Forwarded-Access-Token"]
            }),
            ...options?.headers
        },
        body: JSON.stringify(data)
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export function useSetDeploymentCatalog(options?: {
    mutation?: UseMutationOptions<{
        data: Record<string, unknown>;
    }, ApiError, {
        params: SetDeploymentCatalogParams;
        data: DeploymentCatalogIn;
    }>;
}) {
    return useMutation({
        mutationFn: (vars)=>setDeploymentCatalog(vars.data, vars.params),
        ...options?.mutation
    });
}
export const getGithubConfig = async (options?: RequestInit): Promise<{
    data: GithubConfigOut;
}> =>{
    const res = await fetch("/api/config/github", {
        ...options,
        method: "GET"
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export const getGithubConfigKey = ()=>{
    return [
        "/api/config/github"
    ] as const;
};
export function useGetGithubConfig<TData = {
    data: GithubConfigOut;
}>(options?: {
    query?: Omit<UseQueryOptions<{
        data: GithubConfigOut;
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useQuery({
        queryKey: getGithubConfigKey(),
        queryFn: ()=>getGithubConfig(),
        ...options?.query
    });
}
export function useGetGithubConfigSuspense<TData = {
    data: GithubConfigOut;
}>(options?: {
    query?: Omit<UseSuspenseQueryOptions<{
        data: GithubConfigOut;
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useSuspenseQuery({
        queryKey: getGithubConfigKey(),
        queryFn: ()=>getGithubConfig(),
        ...options?.query
    });
}
export interface UpdateGithubConfigParams {
    "X-Forwarded-Host"?: string | null;
    "X-Forwarded-Preferred-Username"?: string | null;
    "X-Forwarded-User"?: string | null;
    "X-Forwarded-Email"?: string | null;
    "X-Request-Id"?: string | null;
    "X-Forwarded-Access-Token"?: string | null;
}
export const updateGithubConfig = async (data: GithubConfigIn, params?: UpdateGithubConfigParams, options?: RequestInit): Promise<{
    data: GithubConfigOut;
}> =>{
    const res = await fetch("/api/config/github", {
        ...options,
        method: "PUT",
        headers: {
            "Content-Type": "application/json",
            ...(params?.["X-Forwarded-Host"] != null && {
                "X-Forwarded-Host": params["X-Forwarded-Host"]
            }),
            ...(params?.["X-Forwarded-Preferred-Username"] != null && {
                "X-Forwarded-Preferred-Username": params["X-Forwarded-Preferred-Username"]
            }),
            ...(params?.["X-Forwarded-User"] != null && {
                "X-Forwarded-User": params["X-Forwarded-User"]
            }),
            ...(params?.["X-Forwarded-Email"] != null && {
                "X-Forwarded-Email": params["X-Forwarded-Email"]
            }),
            ...(params?.["X-Request-Id"] != null && {
                "X-Request-Id": params["X-Request-Id"]
            }),
            ...(params?.["X-Forwarded-Access-Token"] != null && {
                "X-Forwarded-Access-Token": params["X-Forwarded-Access-Token"]
            }),
            ...options?.headers
        },
        body: JSON.stringify(data)
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export function useUpdateGithubConfig(options?: {
    mutation?: UseMutationOptions<{
        data: GithubConfigOut;
    }, ApiError, {
        params: UpdateGithubConfigParams;
        data: GithubConfigIn;
    }>;
}) {
    return useMutation({
        mutationFn: (vars)=>updateGithubConfig(vars.data, vars.params),
        ...options?.mutation
    });
}
export interface TriggerInitialSyncParams {
    "X-Forwarded-Host"?: string | null;
    "X-Forwarded-Preferred-Username"?: string | null;
    "X-Forwarded-User"?: string | null;
    "X-Forwarded-Email"?: string | null;
    "X-Request-Id"?: string | null;
    "X-Forwarded-Access-Token"?: string | null;
}
export const triggerInitialSync = async (params?: TriggerInitialSyncParams, options?: RequestInit): Promise<{
    data: Record<string, unknown>;
}> =>{
    const res = await fetch("/api/config/initial-sync", {
        ...options,
        method: "POST",
        headers: {
            ...(params?.["X-Forwarded-Host"] != null && {
                "X-Forwarded-Host": params["X-Forwarded-Host"]
            }),
            ...(params?.["X-Forwarded-Preferred-Username"] != null && {
                "X-Forwarded-Preferred-Username": params["X-Forwarded-Preferred-Username"]
            }),
            ...(params?.["X-Forwarded-User"] != null && {
                "X-Forwarded-User": params["X-Forwarded-User"]
            }),
            ...(params?.["X-Forwarded-Email"] != null && {
                "X-Forwarded-Email": params["X-Forwarded-Email"]
            }),
            ...(params?.["X-Request-Id"] != null && {
                "X-Request-Id": params["X-Request-Id"]
            }),
            ...(params?.["X-Forwarded-Access-Token"] != null && {
                "X-Forwarded-Access-Token": params["X-Forwarded-Access-Token"]
            }),
            ...options?.headers
        }
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export function useTriggerInitialSync(options?: {
    mutation?: UseMutationOptions<{
        data: Record<string, unknown>;
    }, ApiError, {
        params: TriggerInitialSyncParams;
    }>;
}) {
    return useMutation({
        mutationFn: (vars)=>triggerInitialSync(vars.params),
        ...options?.mutation
    });
}
export const getMetamodelCatalog = async (options?: RequestInit): Promise<{
    data: Record<string, unknown>;
}> =>{
    const res = await fetch("/api/config/metamodel-catalog", {
        ...options,
        method: "GET"
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export const getMetamodelCatalogKey = ()=>{
    return [
        "/api/config/metamodel-catalog"
    ] as const;
};
export function useGetMetamodelCatalog<TData = {
    data: Record<string, unknown>;
}>(options?: {
    query?: Omit<UseQueryOptions<{
        data: Record<string, unknown>;
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useQuery({
        queryKey: getMetamodelCatalogKey(),
        queryFn: ()=>getMetamodelCatalog(),
        ...options?.query
    });
}
export function useGetMetamodelCatalogSuspense<TData = {
    data: Record<string, unknown>;
}>(options?: {
    query?: Omit<UseSuspenseQueryOptions<{
        data: Record<string, unknown>;
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useSuspenseQuery({
        queryKey: getMetamodelCatalogKey(),
        queryFn: ()=>getMetamodelCatalog(),
        ...options?.query
    });
}
export interface SetMetamodelCatalogParams {
    "X-Forwarded-Host"?: string | null;
    "X-Forwarded-Preferred-Username"?: string | null;
    "X-Forwarded-User"?: string | null;
    "X-Forwarded-Email"?: string | null;
    "X-Request-Id"?: string | null;
    "X-Forwarded-Access-Token"?: string | null;
}
export const setMetamodelCatalog = async (data: MetamodelCatalogIn, params?: SetMetamodelCatalogParams, options?: RequestInit): Promise<{
    data: Record<string, unknown>;
}> =>{
    const res = await fetch("/api/config/metamodel-catalog", {
        ...options,
        method: "PUT",
        headers: {
            "Content-Type": "application/json",
            ...(params?.["X-Forwarded-Host"] != null && {
                "X-Forwarded-Host": params["X-Forwarded-Host"]
            }),
            ...(params?.["X-Forwarded-Preferred-Username"] != null && {
                "X-Forwarded-Preferred-Username": params["X-Forwarded-Preferred-Username"]
            }),
            ...(params?.["X-Forwarded-User"] != null && {
                "X-Forwarded-User": params["X-Forwarded-User"]
            }),
            ...(params?.["X-Forwarded-Email"] != null && {
                "X-Forwarded-Email": params["X-Forwarded-Email"]
            }),
            ...(params?.["X-Request-Id"] != null && {
                "X-Request-Id": params["X-Request-Id"]
            }),
            ...(params?.["X-Forwarded-Access-Token"] != null && {
                "X-Forwarded-Access-Token": params["X-Forwarded-Access-Token"]
            }),
            ...options?.headers
        },
        body: JSON.stringify(data)
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export function useSetMetamodelCatalog(options?: {
    mutation?: UseMutationOptions<{
        data: Record<string, unknown>;
    }, ApiError, {
        params: SetMetamodelCatalogParams;
        data: MetamodelCatalogIn;
    }>;
}) {
    return useMutation({
        mutationFn: (vars)=>setMetamodelCatalog(vars.data, vars.params),
        ...options?.mutation
    });
}
export const getRunChangeReviewConfig = async (options?: RequestInit): Promise<{
    data: RunChangeReviewConfigOut;
}> =>{
    const res = await fetch("/api/config/run-change-review", {
        ...options,
        method: "GET"
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export const getRunChangeReviewConfigKey = ()=>{
    return [
        "/api/config/run-change-review"
    ] as const;
};
export function useGetRunChangeReviewConfig<TData = {
    data: RunChangeReviewConfigOut;
}>(options?: {
    query?: Omit<UseQueryOptions<{
        data: RunChangeReviewConfigOut;
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useQuery({
        queryKey: getRunChangeReviewConfigKey(),
        queryFn: ()=>getRunChangeReviewConfig(),
        ...options?.query
    });
}
export function useGetRunChangeReviewConfigSuspense<TData = {
    data: RunChangeReviewConfigOut;
}>(options?: {
    query?: Omit<UseSuspenseQueryOptions<{
        data: RunChangeReviewConfigOut;
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useSuspenseQuery({
        queryKey: getRunChangeReviewConfigKey(),
        queryFn: ()=>getRunChangeReviewConfig(),
        ...options?.query
    });
}
export const getSourceAuthConfig = async (options?: RequestInit): Promise<{
    data: SourceAuthConfigOut;
}> =>{
    const res = await fetch("/api/config/source-auth", {
        ...options,
        method: "GET"
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export const getSourceAuthConfigKey = ()=>{
    return [
        "/api/config/source-auth"
    ] as const;
};
export function useGetSourceAuthConfig<TData = {
    data: SourceAuthConfigOut;
}>(options?: {
    query?: Omit<UseQueryOptions<{
        data: SourceAuthConfigOut;
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useQuery({
        queryKey: getSourceAuthConfigKey(),
        queryFn: ()=>getSourceAuthConfig(),
        ...options?.query
    });
}
export function useGetSourceAuthConfigSuspense<TData = {
    data: SourceAuthConfigOut;
}>(options?: {
    query?: Omit<UseSuspenseQueryOptions<{
        data: SourceAuthConfigOut;
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useSuspenseQuery({
        queryKey: getSourceAuthConfigKey(),
        queryFn: ()=>getSourceAuthConfig(),
        ...options?.query
    });
}
export interface UpdateSourceAuthConfigParams {
    "X-Forwarded-Host"?: string | null;
    "X-Forwarded-Preferred-Username"?: string | null;
    "X-Forwarded-User"?: string | null;
    "X-Forwarded-Email"?: string | null;
    "X-Request-Id"?: string | null;
    "X-Forwarded-Access-Token"?: string | null;
}
export const updateSourceAuthConfig = async (data: SourceAuthConfigIn, params?: UpdateSourceAuthConfigParams, options?: RequestInit): Promise<{
    data: SourceAuthConfigOut;
}> =>{
    const res = await fetch("/api/config/source-auth", {
        ...options,
        method: "PUT",
        headers: {
            "Content-Type": "application/json",
            ...(params?.["X-Forwarded-Host"] != null && {
                "X-Forwarded-Host": params["X-Forwarded-Host"]
            }),
            ...(params?.["X-Forwarded-Preferred-Username"] != null && {
                "X-Forwarded-Preferred-Username": params["X-Forwarded-Preferred-Username"]
            }),
            ...(params?.["X-Forwarded-User"] != null && {
                "X-Forwarded-User": params["X-Forwarded-User"]
            }),
            ...(params?.["X-Forwarded-Email"] != null && {
                "X-Forwarded-Email": params["X-Forwarded-Email"]
            }),
            ...(params?.["X-Request-Id"] != null && {
                "X-Request-Id": params["X-Request-Id"]
            }),
            ...(params?.["X-Forwarded-Access-Token"] != null && {
                "X-Forwarded-Access-Token": params["X-Forwarded-Access-Token"]
            }),
            ...options?.headers
        },
        body: JSON.stringify(data)
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export function useUpdateSourceAuthConfig(options?: {
    mutation?: UseMutationOptions<{
        data: SourceAuthConfigOut;
    }, ApiError, {
        params: UpdateSourceAuthConfigParams;
        data: SourceAuthConfigIn;
    }>;
}) {
    return useMutation({
        mutationFn: (vars)=>updateSourceAuthConfig(vars.data, vars.params),
        ...options?.mutation
    });
}
export const getTaxonomyConfig = async (options?: RequestInit): Promise<{
    data: TaxonomyConfigOut;
}> =>{
    const res = await fetch("/api/config/taxonomy", {
        ...options,
        method: "GET"
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export const getTaxonomyConfigKey = ()=>{
    return [
        "/api/config/taxonomy"
    ] as const;
};
export function useGetTaxonomyConfig<TData = {
    data: TaxonomyConfigOut;
}>(options?: {
    query?: Omit<UseQueryOptions<{
        data: TaxonomyConfigOut;
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useQuery({
        queryKey: getTaxonomyConfigKey(),
        queryFn: ()=>getTaxonomyConfig(),
        ...options?.query
    });
}
export function useGetTaxonomyConfigSuspense<TData = {
    data: TaxonomyConfigOut;
}>(options?: {
    query?: Omit<UseSuspenseQueryOptions<{
        data: TaxonomyConfigOut;
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useSuspenseQuery({
        queryKey: getTaxonomyConfigKey(),
        queryFn: ()=>getTaxonomyConfig(),
        ...options?.query
    });
}
export interface UpdateTaxonomyConfigParams {
    "X-Forwarded-Host"?: string | null;
    "X-Forwarded-Preferred-Username"?: string | null;
    "X-Forwarded-User"?: string | null;
    "X-Forwarded-Email"?: string | null;
    "X-Request-Id"?: string | null;
    "X-Forwarded-Access-Token"?: string | null;
}
export const updateTaxonomyConfig = async (data: TaxonomyConfigIn, params?: UpdateTaxonomyConfigParams, options?: RequestInit): Promise<{
    data: TaxonomyConfigOut;
}> =>{
    const res = await fetch("/api/config/taxonomy", {
        ...options,
        method: "PUT",
        headers: {
            "Content-Type": "application/json",
            ...(params?.["X-Forwarded-Host"] != null && {
                "X-Forwarded-Host": params["X-Forwarded-Host"]
            }),
            ...(params?.["X-Forwarded-Preferred-Username"] != null && {
                "X-Forwarded-Preferred-Username": params["X-Forwarded-Preferred-Username"]
            }),
            ...(params?.["X-Forwarded-User"] != null && {
                "X-Forwarded-User": params["X-Forwarded-User"]
            }),
            ...(params?.["X-Forwarded-Email"] != null && {
                "X-Forwarded-Email": params["X-Forwarded-Email"]
            }),
            ...(params?.["X-Request-Id"] != null && {
                "X-Request-Id": params["X-Request-Id"]
            }),
            ...(params?.["X-Forwarded-Access-Token"] != null && {
                "X-Forwarded-Access-Token": params["X-Forwarded-Access-Token"]
            }),
            ...options?.headers
        },
        body: JSON.stringify(data)
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export function useUpdateTaxonomyConfig(options?: {
    mutation?: UseMutationOptions<{
        data: TaxonomyConfigOut;
    }, ApiError, {
        params: UpdateTaxonomyConfigParams;
        data: TaxonomyConfigIn;
    }>;
}) {
    return useMutation({
        mutationFn: (vars)=>updateTaxonomyConfig(vars.data, vars.params),
        ...options?.mutation
    });
}
export interface ListTaxonomyModelServicesParams {
    "X-Forwarded-Host"?: string | null;
    "X-Forwarded-Preferred-Username"?: string | null;
    "X-Forwarded-User"?: string | null;
    "X-Forwarded-Email"?: string | null;
    "X-Request-Id"?: string | null;
    "X-Forwarded-Access-Token"?: string | null;
}
export const listTaxonomyModelServices = async (params?: ListTaxonomyModelServicesParams, options?: RequestInit): Promise<{
    data: TaxonomyModelServicesOut;
}> =>{
    const res = await fetch("/api/config/taxonomy/model-services", {
        ...options,
        method: "GET",
        headers: {
            ...(params?.["X-Forwarded-Host"] != null && {
                "X-Forwarded-Host": params["X-Forwarded-Host"]
            }),
            ...(params?.["X-Forwarded-Preferred-Username"] != null && {
                "X-Forwarded-Preferred-Username": params["X-Forwarded-Preferred-Username"]
            }),
            ...(params?.["X-Forwarded-User"] != null && {
                "X-Forwarded-User": params["X-Forwarded-User"]
            }),
            ...(params?.["X-Forwarded-Email"] != null && {
                "X-Forwarded-Email": params["X-Forwarded-Email"]
            }),
            ...(params?.["X-Request-Id"] != null && {
                "X-Request-Id": params["X-Request-Id"]
            }),
            ...(params?.["X-Forwarded-Access-Token"] != null && {
                "X-Forwarded-Access-Token": params["X-Forwarded-Access-Token"]
            }),
            ...options?.headers
        }
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export const listTaxonomyModelServicesKey = (params?: ListTaxonomyModelServicesParams)=>{
    return [
        "/api/config/taxonomy/model-services",
        params
    ] as const;
};
export function useListTaxonomyModelServices<TData = {
    data: TaxonomyModelServicesOut;
}>(options?: {
    params?: ListTaxonomyModelServicesParams;
    query?: Omit<UseQueryOptions<{
        data: TaxonomyModelServicesOut;
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useQuery({
        queryKey: listTaxonomyModelServicesKey(options?.params),
        queryFn: ()=>listTaxonomyModelServices(options?.params),
        ...options?.query
    });
}
export function useListTaxonomyModelServicesSuspense<TData = {
    data: TaxonomyModelServicesOut;
}>(options?: {
    params?: ListTaxonomyModelServicesParams;
    query?: Omit<UseSuspenseQueryOptions<{
        data: TaxonomyModelServicesOut;
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useSuspenseQuery({
        queryKey: listTaxonomyModelServicesKey(options?.params),
        queryFn: ()=>listTaxonomyModelServices(options?.params),
        ...options?.query
    });
}
export interface TestTaxonomyModelServiceParams {
    "X-Forwarded-Host"?: string | null;
    "X-Forwarded-Preferred-Username"?: string | null;
    "X-Forwarded-User"?: string | null;
    "X-Forwarded-Email"?: string | null;
    "X-Request-Id"?: string | null;
    "X-Forwarded-Access-Token"?: string | null;
}
export const testTaxonomyModelService = async (params?: TestTaxonomyModelServiceParams, options?: RequestInit): Promise<{
    data: TaxonomyCheckOut;
}> =>{
    const res = await fetch("/api/config/taxonomy/test", {
        ...options,
        method: "POST",
        headers: {
            ...(params?.["X-Forwarded-Host"] != null && {
                "X-Forwarded-Host": params["X-Forwarded-Host"]
            }),
            ...(params?.["X-Forwarded-Preferred-Username"] != null && {
                "X-Forwarded-Preferred-Username": params["X-Forwarded-Preferred-Username"]
            }),
            ...(params?.["X-Forwarded-User"] != null && {
                "X-Forwarded-User": params["X-Forwarded-User"]
            }),
            ...(params?.["X-Forwarded-Email"] != null && {
                "X-Forwarded-Email": params["X-Forwarded-Email"]
            }),
            ...(params?.["X-Request-Id"] != null && {
                "X-Request-Id": params["X-Request-Id"]
            }),
            ...(params?.["X-Forwarded-Access-Token"] != null && {
                "X-Forwarded-Access-Token": params["X-Forwarded-Access-Token"]
            }),
            ...options?.headers
        }
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export function useTestTaxonomyModelService(options?: {
    mutation?: UseMutationOptions<{
        data: TaxonomyCheckOut;
    }, ApiError, {
        params: TestTaxonomyModelServiceParams;
    }>;
}) {
    return useMutation({
        mutationFn: (vars)=>testTaxonomyModelService(vars.params),
        ...options?.mutation
    });
}
export const getWarehouse = async (options?: RequestInit): Promise<{
    data: Record<string, unknown>;
}> =>{
    const res = await fetch("/api/config/warehouse", {
        ...options,
        method: "GET"
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export const getWarehouseKey = ()=>{
    return [
        "/api/config/warehouse"
    ] as const;
};
export function useGetWarehouse<TData = {
    data: Record<string, unknown>;
}>(options?: {
    query?: Omit<UseQueryOptions<{
        data: Record<string, unknown>;
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useQuery({
        queryKey: getWarehouseKey(),
        queryFn: ()=>getWarehouse(),
        ...options?.query
    });
}
export function useGetWarehouseSuspense<TData = {
    data: Record<string, unknown>;
}>(options?: {
    query?: Omit<UseSuspenseQueryOptions<{
        data: Record<string, unknown>;
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useSuspenseQuery({
        queryKey: getWarehouseKey(),
        queryFn: ()=>getWarehouse(),
        ...options?.query
    });
}
export interface SetWarehouseParams {
    "X-Forwarded-Host"?: string | null;
    "X-Forwarded-Preferred-Username"?: string | null;
    "X-Forwarded-User"?: string | null;
    "X-Forwarded-Email"?: string | null;
    "X-Request-Id"?: string | null;
    "X-Forwarded-Access-Token"?: string | null;
}
export const setWarehouse = async (data: Record<string, unknown>, params?: SetWarehouseParams, options?: RequestInit): Promise<{
    data: Record<string, unknown>;
}> =>{
    const res = await fetch("/api/config/warehouse", {
        ...options,
        method: "PUT",
        headers: {
            "Content-Type": "application/json",
            ...(params?.["X-Forwarded-Host"] != null && {
                "X-Forwarded-Host": params["X-Forwarded-Host"]
            }),
            ...(params?.["X-Forwarded-Preferred-Username"] != null && {
                "X-Forwarded-Preferred-Username": params["X-Forwarded-Preferred-Username"]
            }),
            ...(params?.["X-Forwarded-User"] != null && {
                "X-Forwarded-User": params["X-Forwarded-User"]
            }),
            ...(params?.["X-Forwarded-Email"] != null && {
                "X-Forwarded-Email": params["X-Forwarded-Email"]
            }),
            ...(params?.["X-Request-Id"] != null && {
                "X-Request-Id": params["X-Request-Id"]
            }),
            ...(params?.["X-Forwarded-Access-Token"] != null && {
                "X-Forwarded-Access-Token": params["X-Forwarded-Access-Token"]
            }),
            ...options?.headers
        },
        body: JSON.stringify(data)
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export function useSetWarehouse(options?: {
    mutation?: UseMutationOptions<{
        data: Record<string, unknown>;
    }, ApiError, {
        params: SetWarehouseParams;
        data: Record<string, unknown>;
    }>;
}) {
    return useMutation({
        mutationFn: (vars)=>setWarehouse(vars.data, vars.params),
        ...options?.mutation
    });
}
export const listWarehouses = async (options?: RequestInit): Promise<{
    data: WarehouseOut[];
}> =>{
    const res = await fetch("/api/config/warehouses", {
        ...options,
        method: "GET"
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export const listWarehousesKey = ()=>{
    return [
        "/api/config/warehouses"
    ] as const;
};
export function useListWarehouses<TData = {
    data: WarehouseOut[];
}>(options?: {
    query?: Omit<UseQueryOptions<{
        data: WarehouseOut[];
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useQuery({
        queryKey: listWarehousesKey(),
        queryFn: ()=>listWarehouses(),
        ...options?.query
    });
}
export function useListWarehousesSuspense<TData = {
    data: WarehouseOut[];
}>(options?: {
    query?: Omit<UseSuspenseQueryOptions<{
        data: WarehouseOut[];
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useSuspenseQuery({
        queryKey: listWarehousesKey(),
        queryFn: ()=>listWarehouses(),
        ...options?.query
    });
}
export interface CurrentUserParams {
    "X-Forwarded-Host"?: string | null;
    "X-Forwarded-Preferred-Username"?: string | null;
    "X-Forwarded-User"?: string | null;
    "X-Forwarded-Email"?: string | null;
    "X-Request-Id"?: string | null;
    "X-Forwarded-Access-Token"?: string | null;
}
export const currentUser = async (params?: CurrentUserParams, options?: RequestInit): Promise<{
    data: CurrentUserOut;
}> =>{
    const res = await fetch("/api/current-user", {
        ...options,
        method: "GET",
        headers: {
            ...(params?.["X-Forwarded-Host"] != null && {
                "X-Forwarded-Host": params["X-Forwarded-Host"]
            }),
            ...(params?.["X-Forwarded-Preferred-Username"] != null && {
                "X-Forwarded-Preferred-Username": params["X-Forwarded-Preferred-Username"]
            }),
            ...(params?.["X-Forwarded-User"] != null && {
                "X-Forwarded-User": params["X-Forwarded-User"]
            }),
            ...(params?.["X-Forwarded-Email"] != null && {
                "X-Forwarded-Email": params["X-Forwarded-Email"]
            }),
            ...(params?.["X-Request-Id"] != null && {
                "X-Request-Id": params["X-Request-Id"]
            }),
            ...(params?.["X-Forwarded-Access-Token"] != null && {
                "X-Forwarded-Access-Token": params["X-Forwarded-Access-Token"]
            }),
            ...options?.headers
        }
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export const currentUserKey = (params?: CurrentUserParams)=>{
    return [
        "/api/current-user",
        params
    ] as const;
};
export function useCurrentUser<TData = {
    data: CurrentUserOut;
}>(options?: {
    params?: CurrentUserParams;
    query?: Omit<UseQueryOptions<{
        data: CurrentUserOut;
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useQuery({
        queryKey: currentUserKey(options?.params),
        queryFn: ()=>currentUser(options?.params),
        ...options?.query
    });
}
export function useCurrentUserSuspense<TData = {
    data: CurrentUserOut;
}>(options?: {
    params?: CurrentUserParams;
    query?: Omit<UseSuspenseQueryOptions<{
        data: CurrentUserOut;
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useSuspenseQuery({
        queryKey: currentUserKey(options?.params),
        queryFn: ()=>currentUser(options?.params),
        ...options?.query
    });
}
export const getHealth = async (options?: RequestInit): Promise<{
    data: HealthOut;
}> =>{
    const res = await fetch("/api/health", {
        ...options,
        method: "GET"
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export const getHealthKey = ()=>{
    return [
        "/api/health"
    ] as const;
};
export function useGetHealth<TData = {
    data: HealthOut;
}>(options?: {
    query?: Omit<UseQueryOptions<{
        data: HealthOut;
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useQuery({
        queryKey: getHealthKey(),
        queryFn: ()=>getHealth(),
        ...options?.query
    });
}
export function useGetHealthSuspense<TData = {
    data: HealthOut;
}>(options?: {
    query?: Omit<UseSuspenseQueryOptions<{
        data: HealthOut;
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useSuspenseQuery({
        queryKey: getHealthKey(),
        queryFn: ()=>getHealth(),
        ...options?.query
    });
}
export const analyzeImportRoot = async (data: ImportAnalyzeIn, options?: RequestInit): Promise<{
    data: ImportAnalyzeOut;
}> =>{
    const res = await fetch("/api/import/analyze", {
        ...options,
        method: "POST",
        headers: {
            "Content-Type": "application/json",
            ...options?.headers
        },
        body: JSON.stringify(data)
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export function useAnalyzeImportRoot(options?: {
    mutation?: UseMutationOptions<{
        data: ImportAnalyzeOut;
    }, ApiError, ImportAnalyzeIn>;
}) {
    return useMutation({
        mutationFn: (data)=>analyzeImportRoot(data),
        ...options?.mutation
    });
}
export interface CreateBusinessAndExecuteImportParams {
    "X-Forwarded-Host"?: string | null;
    "X-Forwarded-Preferred-Username"?: string | null;
    "X-Forwarded-User"?: string | null;
    "X-Forwarded-Email"?: string | null;
    "X-Request-Id"?: string | null;
    "X-Forwarded-Access-Token"?: string | null;
}
export const createBusinessAndExecuteImport = async (data: ImportCreateBusinessAndExecuteIn, params?: CreateBusinessAndExecuteImportParams, options?: RequestInit): Promise<{
    data: ImportCreateBusinessAndExecuteOut;
}> =>{
    const res = await fetch("/api/import/create-business-and-execute", {
        ...options,
        method: "POST",
        headers: {
            "Content-Type": "application/json",
            ...(params?.["X-Forwarded-Host"] != null && {
                "X-Forwarded-Host": params["X-Forwarded-Host"]
            }),
            ...(params?.["X-Forwarded-Preferred-Username"] != null && {
                "X-Forwarded-Preferred-Username": params["X-Forwarded-Preferred-Username"]
            }),
            ...(params?.["X-Forwarded-User"] != null && {
                "X-Forwarded-User": params["X-Forwarded-User"]
            }),
            ...(params?.["X-Forwarded-Email"] != null && {
                "X-Forwarded-Email": params["X-Forwarded-Email"]
            }),
            ...(params?.["X-Request-Id"] != null && {
                "X-Request-Id": params["X-Request-Id"]
            }),
            ...(params?.["X-Forwarded-Access-Token"] != null && {
                "X-Forwarded-Access-Token": params["X-Forwarded-Access-Token"]
            }),
            ...options?.headers
        },
        body: JSON.stringify(data)
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export function useCreateBusinessAndExecuteImport(options?: {
    mutation?: UseMutationOptions<{
        data: ImportCreateBusinessAndExecuteOut;
    }, ApiError, {
        params: CreateBusinessAndExecuteImportParams;
        data: ImportCreateBusinessAndExecuteIn;
    }>;
}) {
    return useMutation({
        mutationFn: (vars)=>createBusinessAndExecuteImport(vars.data, vars.params),
        ...options?.mutation
    });
}
export interface GetImportPreviewParams {
    volume_path: string;
}
export const getImportPreview = async (params: GetImportPreviewParams, options?: RequestInit): Promise<{
    data: ImportPreviewOut;
}> =>{
    const searchParams = new URLSearchParams();
    if (params.volume_path != null) searchParams.set("volume_path", String(params.volume_path));
    const queryString = searchParams.toString();
    const url = queryString ? `/api/import/preview?${queryString}` : "/api/import/preview";
    const res = await fetch(url, {
        ...options,
        method: "GET"
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export const getImportPreviewKey = (params?: GetImportPreviewParams)=>{
    return [
        "/api/import/preview",
        params
    ] as const;
};
export function useGetImportPreview<TData = {
    data: ImportPreviewOut;
}>(options: {
    params: GetImportPreviewParams;
    query?: Omit<UseQueryOptions<{
        data: ImportPreviewOut;
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useQuery({
        queryKey: getImportPreviewKey(options.params),
        queryFn: ()=>getImportPreview(options.params),
        ...options?.query
    });
}
export function useGetImportPreviewSuspense<TData = {
    data: ImportPreviewOut;
}>(options: {
    params: GetImportPreviewParams;
    query?: Omit<UseSuspenseQueryOptions<{
        data: ImportPreviewOut;
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useSuspenseQuery({
        queryKey: getImportPreviewKey(options.params),
        queryFn: ()=>getImportPreview(options.params),
        ...options?.query
    });
}
export const listIndustries = async (options?: RequestInit): Promise<{
    data: IndustryOut[];
}> =>{
    const res = await fetch("/api/industries", {
        ...options,
        method: "GET"
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export const listIndustriesKey = ()=>{
    return [
        "/api/industries"
    ] as const;
};
export function useListIndustries<TData = {
    data: IndustryOut[];
}>(options?: {
    query?: Omit<UseQueryOptions<{
        data: IndustryOut[];
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useQuery({
        queryKey: listIndustriesKey(),
        queryFn: ()=>listIndustries(),
        ...options?.query
    });
}
export function useListIndustriesSuspense<TData = {
    data: IndustryOut[];
}>(options?: {
    query?: Omit<UseSuspenseQueryOptions<{
        data: IndustryOut[];
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useSuspenseQuery({
        queryKey: listIndustriesKey(),
        queryFn: ()=>listIndustries(),
        ...options?.query
    });
}
export interface CreateIndustryParams {
    "X-Forwarded-Host"?: string | null;
    "X-Forwarded-Preferred-Username"?: string | null;
    "X-Forwarded-User"?: string | null;
    "X-Forwarded-Email"?: string | null;
    "X-Request-Id"?: string | null;
    "X-Forwarded-Access-Token"?: string | null;
}
export const createIndustry = async (data: IndustryIn, params?: CreateIndustryParams, options?: RequestInit): Promise<{
    data: IndustryOut;
}> =>{
    const res = await fetch("/api/industries", {
        ...options,
        method: "POST",
        headers: {
            "Content-Type": "application/json",
            ...(params?.["X-Forwarded-Host"] != null && {
                "X-Forwarded-Host": params["X-Forwarded-Host"]
            }),
            ...(params?.["X-Forwarded-Preferred-Username"] != null && {
                "X-Forwarded-Preferred-Username": params["X-Forwarded-Preferred-Username"]
            }),
            ...(params?.["X-Forwarded-User"] != null && {
                "X-Forwarded-User": params["X-Forwarded-User"]
            }),
            ...(params?.["X-Forwarded-Email"] != null && {
                "X-Forwarded-Email": params["X-Forwarded-Email"]
            }),
            ...(params?.["X-Request-Id"] != null && {
                "X-Request-Id": params["X-Request-Id"]
            }),
            ...(params?.["X-Forwarded-Access-Token"] != null && {
                "X-Forwarded-Access-Token": params["X-Forwarded-Access-Token"]
            }),
            ...options?.headers
        },
        body: JSON.stringify(data)
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export function useCreateIndustry(options?: {
    mutation?: UseMutationOptions<{
        data: IndustryOut;
    }, ApiError, {
        params: CreateIndustryParams;
        data: IndustryIn;
    }>;
}) {
    return useMutation({
        mutationFn: (vars)=>createIndustry(vars.data, vars.params),
        ...options?.mutation
    });
}
export interface ApplyIndustryScopePrefixesParams {
    business_id: string;
    "X-Forwarded-Host"?: string | null;
    "X-Forwarded-Preferred-Username"?: string | null;
    "X-Forwarded-User"?: string | null;
    "X-Forwarded-Email"?: string | null;
    "X-Request-Id"?: string | null;
    "X-Forwarded-Access-Token"?: string | null;
}
export const applyIndustryScopePrefixes = async (params: ApplyIndustryScopePrefixesParams, data: IndustryScopePrefixesIn, options?: RequestInit): Promise<{
    data: IndustryScopePrefixesOut;
}> =>{
    const res = await fetch(`/api/industries/${params.business_id}/scope-prefixes`, {
        ...options,
        method: "POST",
        headers: {
            "Content-Type": "application/json",
            ...(params?.["X-Forwarded-Host"] != null && {
                "X-Forwarded-Host": params["X-Forwarded-Host"]
            }),
            ...(params?.["X-Forwarded-Preferred-Username"] != null && {
                "X-Forwarded-Preferred-Username": params["X-Forwarded-Preferred-Username"]
            }),
            ...(params?.["X-Forwarded-User"] != null && {
                "X-Forwarded-User": params["X-Forwarded-User"]
            }),
            ...(params?.["X-Forwarded-Email"] != null && {
                "X-Forwarded-Email": params["X-Forwarded-Email"]
            }),
            ...(params?.["X-Request-Id"] != null && {
                "X-Request-Id": params["X-Request-Id"]
            }),
            ...(params?.["X-Forwarded-Access-Token"] != null && {
                "X-Forwarded-Access-Token": params["X-Forwarded-Access-Token"]
            }),
            ...options?.headers
        },
        body: JSON.stringify(data)
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export function useApplyIndustryScopePrefixes(options?: {
    mutation?: UseMutationOptions<{
        data: IndustryScopePrefixesOut;
    }, ApiError, {
        params: ApplyIndustryScopePrefixesParams;
        data: IndustryScopePrefixesIn;
    }>;
}) {
    return useMutation({
        mutationFn: (vars)=>applyIndustryScopePrefixes(vars.params, vars.data),
        ...options?.mutation
    });
}
export interface UpdateIndustryParams {
    industry_id: string;
    "X-Forwarded-Host"?: string | null;
    "X-Forwarded-Preferred-Username"?: string | null;
    "X-Forwarded-User"?: string | null;
    "X-Forwarded-Email"?: string | null;
    "X-Request-Id"?: string | null;
    "X-Forwarded-Access-Token"?: string | null;
}
export const updateIndustry = async (params: UpdateIndustryParams, data: IndustryIn, options?: RequestInit): Promise<{
    data: IndustryOut;
}> =>{
    const res = await fetch(`/api/industries/${params.industry_id}`, {
        ...options,
        method: "PUT",
        headers: {
            "Content-Type": "application/json",
            ...(params?.["X-Forwarded-Host"] != null && {
                "X-Forwarded-Host": params["X-Forwarded-Host"]
            }),
            ...(params?.["X-Forwarded-Preferred-Username"] != null && {
                "X-Forwarded-Preferred-Username": params["X-Forwarded-Preferred-Username"]
            }),
            ...(params?.["X-Forwarded-User"] != null && {
                "X-Forwarded-User": params["X-Forwarded-User"]
            }),
            ...(params?.["X-Forwarded-Email"] != null && {
                "X-Forwarded-Email": params["X-Forwarded-Email"]
            }),
            ...(params?.["X-Request-Id"] != null && {
                "X-Request-Id": params["X-Request-Id"]
            }),
            ...(params?.["X-Forwarded-Access-Token"] != null && {
                "X-Forwarded-Access-Token": params["X-Forwarded-Access-Token"]
            }),
            ...options?.headers
        },
        body: JSON.stringify(data)
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export function useUpdateIndustry(options?: {
    mutation?: UseMutationOptions<{
        data: IndustryOut;
    }, ApiError, {
        params: UpdateIndustryParams;
        data: IndustryIn;
    }>;
}) {
    return useMutation({
        mutationFn: (vars)=>updateIndustry(vars.params, vars.data),
        ...options?.mutation
    });
}
export interface DeleteIndustryParams {
    industry_id: string;
    "X-Forwarded-Host"?: string | null;
    "X-Forwarded-Preferred-Username"?: string | null;
    "X-Forwarded-User"?: string | null;
    "X-Forwarded-Email"?: string | null;
    "X-Request-Id"?: string | null;
    "X-Forwarded-Access-Token"?: string | null;
}
export const deleteIndustry = async (params: DeleteIndustryParams, options?: RequestInit): Promise<{
    data: unknown;
}> =>{
    const res = await fetch(`/api/industries/${params.industry_id}`, {
        ...options,
        method: "DELETE",
        headers: {
            ...(params?.["X-Forwarded-Host"] != null && {
                "X-Forwarded-Host": params["X-Forwarded-Host"]
            }),
            ...(params?.["X-Forwarded-Preferred-Username"] != null && {
                "X-Forwarded-Preferred-Username": params["X-Forwarded-Preferred-Username"]
            }),
            ...(params?.["X-Forwarded-User"] != null && {
                "X-Forwarded-User": params["X-Forwarded-User"]
            }),
            ...(params?.["X-Forwarded-Email"] != null && {
                "X-Forwarded-Email": params["X-Forwarded-Email"]
            }),
            ...(params?.["X-Request-Id"] != null && {
                "X-Request-Id": params["X-Request-Id"]
            }),
            ...(params?.["X-Forwarded-Access-Token"] != null && {
                "X-Forwarded-Access-Token": params["X-Forwarded-Access-Token"]
            }),
            ...options?.headers
        }
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export function useDeleteIndustry(options?: {
    mutation?: UseMutationOptions<{
        data: unknown;
    }, ApiError, {
        params: DeleteIndustryParams;
    }>;
}) {
    return useMutation({
        mutationFn: (vars)=>deleteIndustry(vars.params),
        ...options?.mutation
    });
}
export const industryModelsHealth = async (options?: RequestInit): Promise<{
    data: Record<string, unknown>;
}> =>{
    const res = await fetch("/api/industry-models/_health", {
        ...options,
        method: "GET"
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export const industryModelsHealthKey = ()=>{
    return [
        "/api/industry-models/_health"
    ] as const;
};
export function useIndustryModelsHealth<TData = {
    data: Record<string, unknown>;
}>(options?: {
    query?: Omit<UseQueryOptions<{
        data: Record<string, unknown>;
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useQuery({
        queryKey: industryModelsHealthKey(),
        queryFn: ()=>industryModelsHealth(),
        ...options?.query
    });
}
export function useIndustryModelsHealthSuspense<TData = {
    data: Record<string, unknown>;
}>(options?: {
    query?: Omit<UseSuspenseQueryOptions<{
        data: Record<string, unknown>;
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useSuspenseQuery({
        queryKey: industryModelsHealthKey(),
        queryFn: ()=>industryModelsHealth(),
        ...options?.query
    });
}
export interface DownloadIndustryModelParams {
    "X-Forwarded-Host"?: string | null;
    "X-Forwarded-Preferred-Username"?: string | null;
    "X-Forwarded-User"?: string | null;
    "X-Forwarded-Email"?: string | null;
    "X-Request-Id"?: string | null;
    "X-Forwarded-Access-Token"?: string | null;
}
export const downloadIndustryModel = async (data: DownloadIndustryModelIn, params?: DownloadIndustryModelParams, options?: RequestInit): Promise<{
    data: DownloadIndustryModelOut;
}> =>{
    const res = await fetch("/api/industry-models/download", {
        ...options,
        method: "POST",
        headers: {
            "Content-Type": "application/json",
            ...(params?.["X-Forwarded-Host"] != null && {
                "X-Forwarded-Host": params["X-Forwarded-Host"]
            }),
            ...(params?.["X-Forwarded-Preferred-Username"] != null && {
                "X-Forwarded-Preferred-Username": params["X-Forwarded-Preferred-Username"]
            }),
            ...(params?.["X-Forwarded-User"] != null && {
                "X-Forwarded-User": params["X-Forwarded-User"]
            }),
            ...(params?.["X-Forwarded-Email"] != null && {
                "X-Forwarded-Email": params["X-Forwarded-Email"]
            }),
            ...(params?.["X-Request-Id"] != null && {
                "X-Request-Id": params["X-Request-Id"]
            }),
            ...(params?.["X-Forwarded-Access-Token"] != null && {
                "X-Forwarded-Access-Token": params["X-Forwarded-Access-Token"]
            }),
            ...options?.headers
        },
        body: JSON.stringify(data)
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export function useDownloadIndustryModel(options?: {
    mutation?: UseMutationOptions<{
        data: DownloadIndustryModelOut;
    }, ApiError, {
        params: DownloadIndustryModelParams;
        data: DownloadIndustryModelIn;
    }>;
}) {
    return useMutation({
        mutationFn: (vars)=>downloadIndustryModel(vars.data, vars.params),
        ...options?.mutation
    });
}
export interface KickstartFromIndustryParams {
    industry_business_id: string;
    "X-Forwarded-Host"?: string | null;
    "X-Forwarded-Preferred-Username"?: string | null;
    "X-Forwarded-User"?: string | null;
    "X-Forwarded-Email"?: string | null;
    "X-Request-Id"?: string | null;
    "X-Forwarded-Access-Token"?: string | null;
}
export const kickstartFromIndustry = async (params: KickstartFromIndustryParams, data: KickstartIn, options?: RequestInit): Promise<{
    data: KickstartOut;
}> =>{
    const res = await fetch(`/api/industry-models/${params.industry_business_id}/kickstart`, {
        ...options,
        method: "POST",
        headers: {
            "Content-Type": "application/json",
            ...(params?.["X-Forwarded-Host"] != null && {
                "X-Forwarded-Host": params["X-Forwarded-Host"]
            }),
            ...(params?.["X-Forwarded-Preferred-Username"] != null && {
                "X-Forwarded-Preferred-Username": params["X-Forwarded-Preferred-Username"]
            }),
            ...(params?.["X-Forwarded-User"] != null && {
                "X-Forwarded-User": params["X-Forwarded-User"]
            }),
            ...(params?.["X-Forwarded-Email"] != null && {
                "X-Forwarded-Email": params["X-Forwarded-Email"]
            }),
            ...(params?.["X-Request-Id"] != null && {
                "X-Request-Id": params["X-Request-Id"]
            }),
            ...(params?.["X-Forwarded-Access-Token"] != null && {
                "X-Forwarded-Access-Token": params["X-Forwarded-Access-Token"]
            }),
            ...options?.headers
        },
        body: JSON.stringify(data)
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export function useKickstartFromIndustry(options?: {
    mutation?: UseMutationOptions<{
        data: KickstartOut;
    }, ApiError, {
        params: KickstartFromIndustryParams;
        data: KickstartIn;
    }>;
}) {
    return useMutation({
        mutationFn: (vars)=>kickstartFromIndustry(vars.params, vars.data),
        ...options?.mutation
    });
}
export interface GetInstallationStatusParams {
    model_version_id: string;
}
export const getInstallationStatus = async (params: GetInstallationStatusParams, options?: RequestInit): Promise<{
    data: InstallationStatusOut;
}> =>{
    const res = await fetch(`/api/model-versions/${params.model_version_id}/installation-status`, {
        ...options,
        method: "GET"
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export const getInstallationStatusKey = (params?: GetInstallationStatusParams)=>{
    return [
        "/api/model-versions/{model_version_id}/installation-status",
        params
    ] as const;
};
export function useGetInstallationStatus<TData = {
    data: InstallationStatusOut;
}>(options: {
    params: GetInstallationStatusParams;
    query?: Omit<UseQueryOptions<{
        data: InstallationStatusOut;
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useQuery({
        queryKey: getInstallationStatusKey(options.params),
        queryFn: ()=>getInstallationStatus(options.params),
        ...options?.query
    });
}
export function useGetInstallationStatusSuspense<TData = {
    data: InstallationStatusOut;
}>(options: {
    params: GetInstallationStatusParams;
    query?: Omit<UseSuspenseQueryOptions<{
        data: InstallationStatusOut;
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useSuspenseQuery({
        queryKey: getInstallationStatusKey(options.params),
        queryFn: ()=>getInstallationStatus(options.params),
        ...options?.query
    });
}
export interface GetNextVibesParams {
    model_version_id: string;
}
export const getNextVibes = async (params: GetNextVibesParams, options?: RequestInit): Promise<{
    data: NextVibesOut;
}> =>{
    const res = await fetch(`/api/model-versions/${params.model_version_id}/next-vibes`, {
        ...options,
        method: "GET"
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export const getNextVibesKey = (params?: GetNextVibesParams)=>{
    return [
        "/api/model-versions/{model_version_id}/next-vibes",
        params
    ] as const;
};
export function useGetNextVibes<TData = {
    data: NextVibesOut;
}>(options: {
    params: GetNextVibesParams;
    query?: Omit<UseQueryOptions<{
        data: NextVibesOut;
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useQuery({
        queryKey: getNextVibesKey(options.params),
        queryFn: ()=>getNextVibes(options.params),
        ...options?.query
    });
}
export function useGetNextVibesSuspense<TData = {
    data: NextVibesOut;
}>(options: {
    params: GetNextVibesParams;
    query?: Omit<UseSuspenseQueryOptions<{
        data: NextVibesOut;
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useSuspenseQuery({
        queryKey: getNextVibesKey(options.params),
        queryFn: ()=>getNextVibes(options.params),
        ...options?.query
    });
}
export interface ReconcileInstallationParams {
    model_version_id: string;
    "X-Forwarded-Host"?: string | null;
    "X-Forwarded-Preferred-Username"?: string | null;
    "X-Forwarded-User"?: string | null;
    "X-Forwarded-Email"?: string | null;
    "X-Request-Id"?: string | null;
    "X-Forwarded-Access-Token"?: string | null;
}
export const reconcileInstallation = async (params: ReconcileInstallationParams, options?: RequestInit): Promise<{
    data: ReconcileInstallationOut;
}> =>{
    const res = await fetch(`/api/model-versions/${params.model_version_id}/reconcile-installation`, {
        ...options,
        method: "POST",
        headers: {
            ...(params?.["X-Forwarded-Host"] != null && {
                "X-Forwarded-Host": params["X-Forwarded-Host"]
            }),
            ...(params?.["X-Forwarded-Preferred-Username"] != null && {
                "X-Forwarded-Preferred-Username": params["X-Forwarded-Preferred-Username"]
            }),
            ...(params?.["X-Forwarded-User"] != null && {
                "X-Forwarded-User": params["X-Forwarded-User"]
            }),
            ...(params?.["X-Forwarded-Email"] != null && {
                "X-Forwarded-Email": params["X-Forwarded-Email"]
            }),
            ...(params?.["X-Request-Id"] != null && {
                "X-Request-Id": params["X-Request-Id"]
            }),
            ...(params?.["X-Forwarded-Access-Token"] != null && {
                "X-Forwarded-Access-Token": params["X-Forwarded-Access-Token"]
            }),
            ...options?.headers
        }
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export function useReconcileInstallation(options?: {
    mutation?: UseMutationOptions<{
        data: ReconcileInstallationOut;
    }, ApiError, {
        params: ReconcileInstallationParams;
    }>;
}) {
    return useMutation({
        mutationFn: (vars)=>reconcileInstallation(vars.params),
        ...options?.mutation
    });
}
export interface ListRunsForVersionParams {
    version_id: string;
}
export const listRunsForVersion = async (params: ListRunsForVersionParams, options?: RequestInit): Promise<{
    data: RunListOut[];
}> =>{
    const res = await fetch(`/api/model-versions/${params.version_id}/runs`, {
        ...options,
        method: "GET"
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export const listRunsForVersionKey = (params?: ListRunsForVersionParams)=>{
    return [
        "/api/model-versions/{version_id}/runs",
        params
    ] as const;
};
export function useListRunsForVersion<TData = {
    data: RunListOut[];
}>(options: {
    params: ListRunsForVersionParams;
    query?: Omit<UseQueryOptions<{
        data: RunListOut[];
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useQuery({
        queryKey: listRunsForVersionKey(options.params),
        queryFn: ()=>listRunsForVersion(options.params),
        ...options?.query
    });
}
export function useListRunsForVersionSuspense<TData = {
    data: RunListOut[];
}>(options: {
    params: ListRunsForVersionParams;
    query?: Omit<UseSuspenseQueryOptions<{
        data: RunListOut[];
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useSuspenseQuery({
        queryKey: listRunsForVersionKey(options.params),
        queryFn: ()=>listRunsForVersion(options.params),
        ...options?.query
    });
}
export interface CheckOobNowParams {
    "X-Forwarded-Host"?: string | null;
    "X-Forwarded-Preferred-Username"?: string | null;
    "X-Forwarded-User"?: string | null;
    "X-Forwarded-Email"?: string | null;
    "X-Request-Id"?: string | null;
    "X-Forwarded-Access-Token"?: string | null;
}
export const checkOobNow = async (params?: CheckOobNowParams, options?: RequestInit): Promise<{
    data: OobSummaryOut;
}> =>{
    const res = await fetch("/api/oob/check", {
        ...options,
        method: "POST",
        headers: {
            ...(params?.["X-Forwarded-Host"] != null && {
                "X-Forwarded-Host": params["X-Forwarded-Host"]
            }),
            ...(params?.["X-Forwarded-Preferred-Username"] != null && {
                "X-Forwarded-Preferred-Username": params["X-Forwarded-Preferred-Username"]
            }),
            ...(params?.["X-Forwarded-User"] != null && {
                "X-Forwarded-User": params["X-Forwarded-User"]
            }),
            ...(params?.["X-Forwarded-Email"] != null && {
                "X-Forwarded-Email": params["X-Forwarded-Email"]
            }),
            ...(params?.["X-Request-Id"] != null && {
                "X-Request-Id": params["X-Request-Id"]
            }),
            ...(params?.["X-Forwarded-Access-Token"] != null && {
                "X-Forwarded-Access-Token": params["X-Forwarded-Access-Token"]
            }),
            ...options?.headers
        }
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export function useCheckOobNow(options?: {
    mutation?: UseMutationOptions<{
        data: OobSummaryOut;
    }, ApiError, {
        params: CheckOobNowParams;
    }>;
}) {
    return useMutation({
        mutationFn: (vars)=>checkOobNow(vars.params),
        ...options?.mutation
    });
}
export interface ImportOobNewBusinessesParams {
    "X-Forwarded-Host"?: string | null;
    "X-Forwarded-Preferred-Username"?: string | null;
    "X-Forwarded-User"?: string | null;
    "X-Forwarded-Email"?: string | null;
    "X-Request-Id"?: string | null;
    "X-Forwarded-Access-Token"?: string | null;
}
export const importOobNewBusinesses = async (params?: ImportOobNewBusinessesParams, options?: RequestInit): Promise<{
    data: OobImportOut;
}> =>{
    const res = await fetch("/api/oob/import-new-businesses", {
        ...options,
        method: "POST",
        headers: {
            ...(params?.["X-Forwarded-Host"] != null && {
                "X-Forwarded-Host": params["X-Forwarded-Host"]
            }),
            ...(params?.["X-Forwarded-Preferred-Username"] != null && {
                "X-Forwarded-Preferred-Username": params["X-Forwarded-Preferred-Username"]
            }),
            ...(params?.["X-Forwarded-User"] != null && {
                "X-Forwarded-User": params["X-Forwarded-User"]
            }),
            ...(params?.["X-Forwarded-Email"] != null && {
                "X-Forwarded-Email": params["X-Forwarded-Email"]
            }),
            ...(params?.["X-Request-Id"] != null && {
                "X-Request-Id": params["X-Request-Id"]
            }),
            ...(params?.["X-Forwarded-Access-Token"] != null && {
                "X-Forwarded-Access-Token": params["X-Forwarded-Access-Token"]
            }),
            ...options?.headers
        }
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export function useImportOobNewBusinesses(options?: {
    mutation?: UseMutationOptions<{
        data: OobImportOut;
    }, ApiError, {
        params: ImportOobNewBusinessesParams;
    }>;
}) {
    return useMutation({
        mutationFn: (vars)=>importOobNewBusinesses(vars.params),
        ...options?.mutation
    });
}
export interface GetOobSummaryParams {
    "X-Forwarded-Host"?: string | null;
    "X-Forwarded-Preferred-Username"?: string | null;
    "X-Forwarded-User"?: string | null;
    "X-Forwarded-Email"?: string | null;
    "X-Request-Id"?: string | null;
    "X-Forwarded-Access-Token"?: string | null;
}
export const getOobSummary = async (params?: GetOobSummaryParams, options?: RequestInit): Promise<{
    data: OobSummaryOut;
}> =>{
    const res = await fetch("/api/oob/summary", {
        ...options,
        method: "GET",
        headers: {
            ...(params?.["X-Forwarded-Host"] != null && {
                "X-Forwarded-Host": params["X-Forwarded-Host"]
            }),
            ...(params?.["X-Forwarded-Preferred-Username"] != null && {
                "X-Forwarded-Preferred-Username": params["X-Forwarded-Preferred-Username"]
            }),
            ...(params?.["X-Forwarded-User"] != null && {
                "X-Forwarded-User": params["X-Forwarded-User"]
            }),
            ...(params?.["X-Forwarded-Email"] != null && {
                "X-Forwarded-Email": params["X-Forwarded-Email"]
            }),
            ...(params?.["X-Request-Id"] != null && {
                "X-Request-Id": params["X-Request-Id"]
            }),
            ...(params?.["X-Forwarded-Access-Token"] != null && {
                "X-Forwarded-Access-Token": params["X-Forwarded-Access-Token"]
            }),
            ...options?.headers
        }
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export const getOobSummaryKey = (params?: GetOobSummaryParams)=>{
    return [
        "/api/oob/summary",
        params
    ] as const;
};
export function useGetOobSummary<TData = {
    data: OobSummaryOut;
}>(options?: {
    params?: GetOobSummaryParams;
    query?: Omit<UseQueryOptions<{
        data: OobSummaryOut;
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useQuery({
        queryKey: getOobSummaryKey(options?.params),
        queryFn: ()=>getOobSummary(options?.params),
        ...options?.query
    });
}
export function useGetOobSummarySuspense<TData = {
    data: OobSummaryOut;
}>(options?: {
    params?: GetOobSummaryParams;
    query?: Omit<UseSuspenseQueryOptions<{
        data: OobSummaryOut;
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useSuspenseQuery({
        queryKey: getOobSummaryKey(options?.params),
        queryFn: ()=>getOobSummary(options?.params),
        ...options?.query
    });
}
export const listSectors = async (options?: RequestInit): Promise<{
    data: SectorOut[];
}> =>{
    const res = await fetch("/api/sectors", {
        ...options,
        method: "GET"
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export const listSectorsKey = ()=>{
    return [
        "/api/sectors"
    ] as const;
};
export function useListSectors<TData = {
    data: SectorOut[];
}>(options?: {
    query?: Omit<UseQueryOptions<{
        data: SectorOut[];
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useQuery({
        queryKey: listSectorsKey(),
        queryFn: ()=>listSectors(),
        ...options?.query
    });
}
export function useListSectorsSuspense<TData = {
    data: SectorOut[];
}>(options?: {
    query?: Omit<UseSuspenseQueryOptions<{
        data: SectorOut[];
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useSuspenseQuery({
        queryKey: listSectorsKey(),
        queryFn: ()=>listSectors(),
        ...options?.query
    });
}
export interface CreateSectorParams {
    "X-Forwarded-Host"?: string | null;
    "X-Forwarded-Preferred-Username"?: string | null;
    "X-Forwarded-User"?: string | null;
    "X-Forwarded-Email"?: string | null;
    "X-Request-Id"?: string | null;
    "X-Forwarded-Access-Token"?: string | null;
}
export const createSector = async (data: SectorIn, params?: CreateSectorParams, options?: RequestInit): Promise<{
    data: SectorOut;
}> =>{
    const res = await fetch("/api/sectors", {
        ...options,
        method: "POST",
        headers: {
            "Content-Type": "application/json",
            ...(params?.["X-Forwarded-Host"] != null && {
                "X-Forwarded-Host": params["X-Forwarded-Host"]
            }),
            ...(params?.["X-Forwarded-Preferred-Username"] != null && {
                "X-Forwarded-Preferred-Username": params["X-Forwarded-Preferred-Username"]
            }),
            ...(params?.["X-Forwarded-User"] != null && {
                "X-Forwarded-User": params["X-Forwarded-User"]
            }),
            ...(params?.["X-Forwarded-Email"] != null && {
                "X-Forwarded-Email": params["X-Forwarded-Email"]
            }),
            ...(params?.["X-Request-Id"] != null && {
                "X-Request-Id": params["X-Request-Id"]
            }),
            ...(params?.["X-Forwarded-Access-Token"] != null && {
                "X-Forwarded-Access-Token": params["X-Forwarded-Access-Token"]
            }),
            ...options?.headers
        },
        body: JSON.stringify(data)
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export function useCreateSector(options?: {
    mutation?: UseMutationOptions<{
        data: SectorOut;
    }, ApiError, {
        params: CreateSectorParams;
        data: SectorIn;
    }>;
}) {
    return useMutation({
        mutationFn: (vars)=>createSector(vars.data, vars.params),
        ...options?.mutation
    });
}
export interface UpdateSectorParams {
    sector_id: string;
    "X-Forwarded-Host"?: string | null;
    "X-Forwarded-Preferred-Username"?: string | null;
    "X-Forwarded-User"?: string | null;
    "X-Forwarded-Email"?: string | null;
    "X-Request-Id"?: string | null;
    "X-Forwarded-Access-Token"?: string | null;
}
export const updateSector = async (params: UpdateSectorParams, data: SectorIn, options?: RequestInit): Promise<{
    data: SectorOut;
}> =>{
    const res = await fetch(`/api/sectors/${params.sector_id}`, {
        ...options,
        method: "PUT",
        headers: {
            "Content-Type": "application/json",
            ...(params?.["X-Forwarded-Host"] != null && {
                "X-Forwarded-Host": params["X-Forwarded-Host"]
            }),
            ...(params?.["X-Forwarded-Preferred-Username"] != null && {
                "X-Forwarded-Preferred-Username": params["X-Forwarded-Preferred-Username"]
            }),
            ...(params?.["X-Forwarded-User"] != null && {
                "X-Forwarded-User": params["X-Forwarded-User"]
            }),
            ...(params?.["X-Forwarded-Email"] != null && {
                "X-Forwarded-Email": params["X-Forwarded-Email"]
            }),
            ...(params?.["X-Request-Id"] != null && {
                "X-Request-Id": params["X-Request-Id"]
            }),
            ...(params?.["X-Forwarded-Access-Token"] != null && {
                "X-Forwarded-Access-Token": params["X-Forwarded-Access-Token"]
            }),
            ...options?.headers
        },
        body: JSON.stringify(data)
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export function useUpdateSector(options?: {
    mutation?: UseMutationOptions<{
        data: SectorOut;
    }, ApiError, {
        params: UpdateSectorParams;
        data: SectorIn;
    }>;
}) {
    return useMutation({
        mutationFn: (vars)=>updateSector(vars.params, vars.data),
        ...options?.mutation
    });
}
export interface DeleteSectorParams {
    sector_id: string;
    "X-Forwarded-Host"?: string | null;
    "X-Forwarded-Preferred-Username"?: string | null;
    "X-Forwarded-User"?: string | null;
    "X-Forwarded-Email"?: string | null;
    "X-Request-Id"?: string | null;
    "X-Forwarded-Access-Token"?: string | null;
}
export const deleteSector = async (params: DeleteSectorParams, options?: RequestInit): Promise<{
    data: unknown;
}> =>{
    const res = await fetch(`/api/sectors/${params.sector_id}`, {
        ...options,
        method: "DELETE",
        headers: {
            ...(params?.["X-Forwarded-Host"] != null && {
                "X-Forwarded-Host": params["X-Forwarded-Host"]
            }),
            ...(params?.["X-Forwarded-Preferred-Username"] != null && {
                "X-Forwarded-Preferred-Username": params["X-Forwarded-Preferred-Username"]
            }),
            ...(params?.["X-Forwarded-User"] != null && {
                "X-Forwarded-User": params["X-Forwarded-User"]
            }),
            ...(params?.["X-Forwarded-Email"] != null && {
                "X-Forwarded-Email": params["X-Forwarded-Email"]
            }),
            ...(params?.["X-Request-Id"] != null && {
                "X-Request-Id": params["X-Request-Id"]
            }),
            ...(params?.["X-Forwarded-Access-Token"] != null && {
                "X-Forwarded-Access-Token": params["X-Forwarded-Access-Token"]
            }),
            ...options?.headers
        }
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export function useDeleteSector(options?: {
    mutation?: UseMutationOptions<{
        data: unknown;
    }, ApiError, {
        params: DeleteSectorParams;
    }>;
}) {
    return useMutation({
        mutationFn: (vars)=>deleteSector(vars.params),
        ...options?.mutation
    });
}
export const getSourceCapabilities = async (options?: RequestInit): Promise<{
    data: SourceCapabilities;
}> =>{
    const res = await fetch("/api/sources/capabilities", {
        ...options,
        method: "GET"
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export const getSourceCapabilitiesKey = ()=>{
    return [
        "/api/sources/capabilities"
    ] as const;
};
export function useGetSourceCapabilities<TData = {
    data: SourceCapabilities;
}>(options?: {
    query?: Omit<UseQueryOptions<{
        data: SourceCapabilities;
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useQuery({
        queryKey: getSourceCapabilitiesKey(),
        queryFn: ()=>getSourceCapabilities(),
        ...options?.query
    });
}
export function useGetSourceCapabilitiesSuspense<TData = {
    data: SourceCapabilities;
}>(options?: {
    query?: Omit<UseSuspenseQueryOptions<{
        data: SourceCapabilities;
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useSuspenseQuery({
        queryKey: getSourceCapabilitiesKey(),
        queryFn: ()=>getSourceCapabilities(),
        ...options?.query
    });
}
export interface ListSourceModelsParams {
    industry_id: string;
}
export const listSourceModels = async (params: ListSourceModelsParams, options?: RequestInit): Promise<{
    data: SourceModelRef[];
}> =>{
    const res = await fetch(`/api/sources/industries/${params.industry_id}/models`, {
        ...options,
        method: "GET"
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export const listSourceModelsKey = (params?: ListSourceModelsParams)=>{
    return [
        "/api/sources/industries/{industry_id}/models",
        params
    ] as const;
};
export function useListSourceModels<TData = {
    data: SourceModelRef[];
}>(options: {
    params: ListSourceModelsParams;
    query?: Omit<UseQueryOptions<{
        data: SourceModelRef[];
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useQuery({
        queryKey: listSourceModelsKey(options.params),
        queryFn: ()=>listSourceModels(options.params),
        ...options?.query
    });
}
export function useListSourceModelsSuspense<TData = {
    data: SourceModelRef[];
}>(options: {
    params: ListSourceModelsParams;
    query?: Omit<UseSuspenseQueryOptions<{
        data: SourceModelRef[];
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useSuspenseQuery({
        queryKey: listSourceModelsKey(options.params),
        queryFn: ()=>listSourceModels(options.params),
        ...options?.query
    });
}
export interface GetSourceModelPreviewParams {
    industry_id: string;
    model_id: string;
}
export const getSourceModelPreview = async (params: GetSourceModelPreviewParams, options?: RequestInit): Promise<{
    data: ModelPreviewOut;
}> =>{
    const res = await fetch(`/api/sources/industries/${params.industry_id}/models/${params.model_id}/preview`, {
        ...options,
        method: "GET"
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export const getSourceModelPreviewKey = (params?: GetSourceModelPreviewParams)=>{
    return [
        "/api/sources/industries/{industry_id}/models/{model_id}/preview",
        params
    ] as const;
};
export function useGetSourceModelPreview<TData = {
    data: ModelPreviewOut;
}>(options: {
    params: GetSourceModelPreviewParams;
    query?: Omit<UseQueryOptions<{
        data: ModelPreviewOut;
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useQuery({
        queryKey: getSourceModelPreviewKey(options.params),
        queryFn: ()=>getSourceModelPreview(options.params),
        ...options?.query
    });
}
export function useGetSourceModelPreviewSuspense<TData = {
    data: ModelPreviewOut;
}>(options: {
    params: GetSourceModelPreviewParams;
    query?: Omit<UseSuspenseQueryOptions<{
        data: ModelPreviewOut;
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useSuspenseQuery({
        queryKey: getSourceModelPreviewKey(options.params),
        queryFn: ()=>getSourceModelPreview(options.params),
        ...options?.query
    });
}
export const listSourceSectors = async (options?: RequestInit): Promise<{
    data: SourceSector[];
}> =>{
    const res = await fetch("/api/sources/sectors", {
        ...options,
        method: "GET"
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export const listSourceSectorsKey = ()=>{
    return [
        "/api/sources/sectors"
    ] as const;
};
export function useListSourceSectors<TData = {
    data: SourceSector[];
}>(options?: {
    query?: Omit<UseQueryOptions<{
        data: SourceSector[];
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useQuery({
        queryKey: listSourceSectorsKey(),
        queryFn: ()=>listSourceSectors(),
        ...options?.query
    });
}
export function useListSourceSectorsSuspense<TData = {
    data: SourceSector[];
}>(options?: {
    query?: Omit<UseSuspenseQueryOptions<{
        data: SourceSector[];
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useSuspenseQuery({
        queryKey: listSourceSectorsKey(),
        queryFn: ()=>listSourceSectors(),
        ...options?.query
    });
}
export interface ListSourceIndustriesParams {
    sector_id: string;
}
export const listSourceIndustries = async (params: ListSourceIndustriesParams, options?: RequestInit): Promise<{
    data: SourceIndustry[];
}> =>{
    const res = await fetch(`/api/sources/sectors/${params.sector_id}/industries`, {
        ...options,
        method: "GET"
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export const listSourceIndustriesKey = (params?: ListSourceIndustriesParams)=>{
    return [
        "/api/sources/sectors/{sector_id}/industries",
        params
    ] as const;
};
export function useListSourceIndustries<TData = {
    data: SourceIndustry[];
}>(options: {
    params: ListSourceIndustriesParams;
    query?: Omit<UseQueryOptions<{
        data: SourceIndustry[];
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useQuery({
        queryKey: listSourceIndustriesKey(options.params),
        queryFn: ()=>listSourceIndustries(options.params),
        ...options?.query
    });
}
export function useListSourceIndustriesSuspense<TData = {
    data: SourceIndustry[];
}>(options: {
    params: ListSourceIndustriesParams;
    query?: Omit<UseSuspenseQueryOptions<{
        data: SourceIndustry[];
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useSuspenseQuery({
        queryKey: listSourceIndustriesKey(options.params),
        queryFn: ()=>listSourceIndustries(options.params),
        ...options?.query
    });
}
export const compileTaxonomy = async (data: TaxonomyCompileIn, options?: RequestInit): Promise<{
    data: TaxonomyCompileOut;
}> =>{
    const res = await fetch("/api/taxonomy/compile", {
        ...options,
        method: "POST",
        headers: {
            "Content-Type": "application/json",
            ...options?.headers
        },
        body: JSON.stringify(data)
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export function useCompileTaxonomy(options?: {
    mutation?: UseMutationOptions<{
        data: TaxonomyCompileOut;
    }, ApiError, TaxonomyCompileIn>;
}) {
    return useMutation({
        mutationFn: (data)=>compileTaxonomy(data),
        ...options?.mutation
    });
}
export interface CondenseTaxonomyParams {
    "X-Forwarded-Host"?: string | null;
    "X-Forwarded-Preferred-Username"?: string | null;
    "X-Forwarded-User"?: string | null;
    "X-Forwarded-Email"?: string | null;
    "X-Request-Id"?: string | null;
    "X-Forwarded-Access-Token"?: string | null;
}
export const condenseTaxonomy = async (data: TaxonomyCondenseIn, params?: CondenseTaxonomyParams, options?: RequestInit): Promise<{
    data: TaxonomyDraftCreated;
}> =>{
    const res = await fetch("/api/taxonomy/condense", {
        ...options,
        method: "POST",
        headers: {
            "Content-Type": "application/json",
            ...(params?.["X-Forwarded-Host"] != null && {
                "X-Forwarded-Host": params["X-Forwarded-Host"]
            }),
            ...(params?.["X-Forwarded-Preferred-Username"] != null && {
                "X-Forwarded-Preferred-Username": params["X-Forwarded-Preferred-Username"]
            }),
            ...(params?.["X-Forwarded-User"] != null && {
                "X-Forwarded-User": params["X-Forwarded-User"]
            }),
            ...(params?.["X-Forwarded-Email"] != null && {
                "X-Forwarded-Email": params["X-Forwarded-Email"]
            }),
            ...(params?.["X-Request-Id"] != null && {
                "X-Request-Id": params["X-Request-Id"]
            }),
            ...(params?.["X-Forwarded-Access-Token"] != null && {
                "X-Forwarded-Access-Token": params["X-Forwarded-Access-Token"]
            }),
            ...options?.headers
        },
        body: JSON.stringify(data)
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export function useCondenseTaxonomy(options?: {
    mutation?: UseMutationOptions<{
        data: TaxonomyDraftCreated;
    }, ApiError, {
        params: CondenseTaxonomyParams;
        data: TaxonomyCondenseIn;
    }>;
}) {
    return useMutation({
        mutationFn: (vars)=>condenseTaxonomy(vars.data, vars.params),
        ...options?.mutation
    });
}
export interface CreateTaxonomyDraftParams {
    "X-Forwarded-Host"?: string | null;
    "X-Forwarded-Preferred-Username"?: string | null;
    "X-Forwarded-User"?: string | null;
    "X-Forwarded-Email"?: string | null;
    "X-Request-Id"?: string | null;
    "X-Forwarded-Access-Token"?: string | null;
}
export const createTaxonomyDraft = async (data: TaxonomyDraftCreateIn, params?: CreateTaxonomyDraftParams, options?: RequestInit): Promise<{
    data: TaxonomyDraftCreated;
}> =>{
    const res = await fetch("/api/taxonomy/drafts", {
        ...options,
        method: "POST",
        headers: {
            "Content-Type": "application/json",
            ...(params?.["X-Forwarded-Host"] != null && {
                "X-Forwarded-Host": params["X-Forwarded-Host"]
            }),
            ...(params?.["X-Forwarded-Preferred-Username"] != null && {
                "X-Forwarded-Preferred-Username": params["X-Forwarded-Preferred-Username"]
            }),
            ...(params?.["X-Forwarded-User"] != null && {
                "X-Forwarded-User": params["X-Forwarded-User"]
            }),
            ...(params?.["X-Forwarded-Email"] != null && {
                "X-Forwarded-Email": params["X-Forwarded-Email"]
            }),
            ...(params?.["X-Request-Id"] != null && {
                "X-Request-Id": params["X-Request-Id"]
            }),
            ...(params?.["X-Forwarded-Access-Token"] != null && {
                "X-Forwarded-Access-Token": params["X-Forwarded-Access-Token"]
            }),
            ...options?.headers
        },
        body: JSON.stringify(data)
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export function useCreateTaxonomyDraft(options?: {
    mutation?: UseMutationOptions<{
        data: TaxonomyDraftCreated;
    }, ApiError, {
        params: CreateTaxonomyDraftParams;
        data: TaxonomyDraftCreateIn;
    }>;
}) {
    return useMutation({
        mutationFn: (vars)=>createTaxonomyDraft(vars.data, vars.params),
        ...options?.mutation
    });
}
export interface GetTaxonomyDraftParams {
    draft_id: string;
    "X-Forwarded-Host"?: string | null;
    "X-Forwarded-Preferred-Username"?: string | null;
    "X-Forwarded-User"?: string | null;
    "X-Forwarded-Email"?: string | null;
    "X-Request-Id"?: string | null;
    "X-Forwarded-Access-Token"?: string | null;
}
export const getTaxonomyDraft = async (params: GetTaxonomyDraftParams, options?: RequestInit): Promise<{
    data: TaxonomyDraftOut;
}> =>{
    const res = await fetch(`/api/taxonomy/drafts/${params.draft_id}`, {
        ...options,
        method: "GET",
        headers: {
            ...(params?.["X-Forwarded-Host"] != null && {
                "X-Forwarded-Host": params["X-Forwarded-Host"]
            }),
            ...(params?.["X-Forwarded-Preferred-Username"] != null && {
                "X-Forwarded-Preferred-Username": params["X-Forwarded-Preferred-Username"]
            }),
            ...(params?.["X-Forwarded-User"] != null && {
                "X-Forwarded-User": params["X-Forwarded-User"]
            }),
            ...(params?.["X-Forwarded-Email"] != null && {
                "X-Forwarded-Email": params["X-Forwarded-Email"]
            }),
            ...(params?.["X-Request-Id"] != null && {
                "X-Request-Id": params["X-Request-Id"]
            }),
            ...(params?.["X-Forwarded-Access-Token"] != null && {
                "X-Forwarded-Access-Token": params["X-Forwarded-Access-Token"]
            }),
            ...options?.headers
        }
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export const getTaxonomyDraftKey = (params?: GetTaxonomyDraftParams)=>{
    return [
        "/api/taxonomy/drafts/{draft_id}",
        params
    ] as const;
};
export function useGetTaxonomyDraft<TData = {
    data: TaxonomyDraftOut;
}>(options: {
    params: GetTaxonomyDraftParams;
    query?: Omit<UseQueryOptions<{
        data: TaxonomyDraftOut;
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useQuery({
        queryKey: getTaxonomyDraftKey(options.params),
        queryFn: ()=>getTaxonomyDraft(options.params),
        ...options?.query
    });
}
export function useGetTaxonomyDraftSuspense<TData = {
    data: TaxonomyDraftOut;
}>(options: {
    params: GetTaxonomyDraftParams;
    query?: Omit<UseSuspenseQueryOptions<{
        data: TaxonomyDraftOut;
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useSuspenseQuery({
        queryKey: getTaxonomyDraftKey(options.params),
        queryFn: ()=>getTaxonomyDraft(options.params),
        ...options?.query
    });
}
export interface CancelTaxonomyDraftParams {
    draft_id: string;
    "X-Forwarded-Host"?: string | null;
    "X-Forwarded-Preferred-Username"?: string | null;
    "X-Forwarded-User"?: string | null;
    "X-Forwarded-Email"?: string | null;
    "X-Request-Id"?: string | null;
    "X-Forwarded-Access-Token"?: string | null;
}
export const cancelTaxonomyDraft = async (params: CancelTaxonomyDraftParams, options?: RequestInit): Promise<{
    data: TaxonomyDraftOut;
}> =>{
    const res = await fetch(`/api/taxonomy/drafts/${params.draft_id}/cancel`, {
        ...options,
        method: "POST",
        headers: {
            ...(params?.["X-Forwarded-Host"] != null && {
                "X-Forwarded-Host": params["X-Forwarded-Host"]
            }),
            ...(params?.["X-Forwarded-Preferred-Username"] != null && {
                "X-Forwarded-Preferred-Username": params["X-Forwarded-Preferred-Username"]
            }),
            ...(params?.["X-Forwarded-User"] != null && {
                "X-Forwarded-User": params["X-Forwarded-User"]
            }),
            ...(params?.["X-Forwarded-Email"] != null && {
                "X-Forwarded-Email": params["X-Forwarded-Email"]
            }),
            ...(params?.["X-Request-Id"] != null && {
                "X-Request-Id": params["X-Request-Id"]
            }),
            ...(params?.["X-Forwarded-Access-Token"] != null && {
                "X-Forwarded-Access-Token": params["X-Forwarded-Access-Token"]
            }),
            ...options?.headers
        }
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export function useCancelTaxonomyDraft(options?: {
    mutation?: UseMutationOptions<{
        data: TaxonomyDraftOut;
    }, ApiError, {
        params: CancelTaxonomyDraftParams;
    }>;
}) {
    return useMutation({
        mutationFn: (vars)=>cancelTaxonomyDraft(vars.params),
        ...options?.mutation
    });
}
export interface RetryTaxonomyDraftPartParams {
    draft_id: string;
    part: string;
    "X-Forwarded-Host"?: string | null;
    "X-Forwarded-Preferred-Username"?: string | null;
    "X-Forwarded-User"?: string | null;
    "X-Forwarded-Email"?: string | null;
    "X-Request-Id"?: string | null;
    "X-Forwarded-Access-Token"?: string | null;
}
export const retryTaxonomyDraftPart = async (params: RetryTaxonomyDraftPartParams, options?: RequestInit): Promise<{
    data: TaxonomyDraftOut;
}> =>{
    const res = await fetch(`/api/taxonomy/drafts/${params.draft_id}/parts/${params.part}/retry`, {
        ...options,
        method: "POST",
        headers: {
            ...(params?.["X-Forwarded-Host"] != null && {
                "X-Forwarded-Host": params["X-Forwarded-Host"]
            }),
            ...(params?.["X-Forwarded-Preferred-Username"] != null && {
                "X-Forwarded-Preferred-Username": params["X-Forwarded-Preferred-Username"]
            }),
            ...(params?.["X-Forwarded-User"] != null && {
                "X-Forwarded-User": params["X-Forwarded-User"]
            }),
            ...(params?.["X-Forwarded-Email"] != null && {
                "X-Forwarded-Email": params["X-Forwarded-Email"]
            }),
            ...(params?.["X-Request-Id"] != null && {
                "X-Request-Id": params["X-Request-Id"]
            }),
            ...(params?.["X-Forwarded-Access-Token"] != null && {
                "X-Forwarded-Access-Token": params["X-Forwarded-Access-Token"]
            }),
            ...options?.headers
        }
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export function useRetryTaxonomyDraftPart(options?: {
    mutation?: UseMutationOptions<{
        data: TaxonomyDraftOut;
    }, ApiError, {
        params: RetryTaxonomyDraftPartParams;
    }>;
}) {
    return useMutation({
        mutationFn: (vars)=>retryTaxonomyDraftPart(vars.params),
        ...options?.mutation
    });
}
export const getTaxonomyExample = async (options?: RequestInit): Promise<{
    data: TaxonomyExampleOut;
}> =>{
    const res = await fetch("/api/taxonomy/example", {
        ...options,
        method: "GET"
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export const getTaxonomyExampleKey = ()=>{
    return [
        "/api/taxonomy/example"
    ] as const;
};
export function useGetTaxonomyExample<TData = {
    data: TaxonomyExampleOut;
}>(options?: {
    query?: Omit<UseQueryOptions<{
        data: TaxonomyExampleOut;
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useQuery({
        queryKey: getTaxonomyExampleKey(),
        queryFn: ()=>getTaxonomyExample(),
        ...options?.query
    });
}
export function useGetTaxonomyExampleSuspense<TData = {
    data: TaxonomyExampleOut;
}>(options?: {
    query?: Omit<UseSuspenseQueryOptions<{
        data: TaxonomyExampleOut;
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useSuspenseQuery({
        queryKey: getTaxonomyExampleKey(),
        queryFn: ()=>getTaxonomyExample(),
        ...options?.query
    });
}
export interface GetSavedTaxonomyWizardParams {
    "X-Forwarded-Host"?: string | null;
    "X-Forwarded-Preferred-Username"?: string | null;
    "X-Forwarded-User"?: string | null;
    "X-Forwarded-Email"?: string | null;
    "X-Request-Id"?: string | null;
    "X-Forwarded-Access-Token"?: string | null;
}
export const getSavedTaxonomyWizard = async (params?: GetSavedTaxonomyWizardParams, options?: RequestInit): Promise<{
    data: TaxonomySavedWizardOut;
}> =>{
    const res = await fetch("/api/taxonomy/saved", {
        ...options,
        method: "GET",
        headers: {
            ...(params?.["X-Forwarded-Host"] != null && {
                "X-Forwarded-Host": params["X-Forwarded-Host"]
            }),
            ...(params?.["X-Forwarded-Preferred-Username"] != null && {
                "X-Forwarded-Preferred-Username": params["X-Forwarded-Preferred-Username"]
            }),
            ...(params?.["X-Forwarded-User"] != null && {
                "X-Forwarded-User": params["X-Forwarded-User"]
            }),
            ...(params?.["X-Forwarded-Email"] != null && {
                "X-Forwarded-Email": params["X-Forwarded-Email"]
            }),
            ...(params?.["X-Request-Id"] != null && {
                "X-Request-Id": params["X-Request-Id"]
            }),
            ...(params?.["X-Forwarded-Access-Token"] != null && {
                "X-Forwarded-Access-Token": params["X-Forwarded-Access-Token"]
            }),
            ...options?.headers
        }
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export const getSavedTaxonomyWizardKey = (params?: GetSavedTaxonomyWizardParams)=>{
    return [
        "/api/taxonomy/saved",
        params
    ] as const;
};
export function useGetSavedTaxonomyWizard<TData = {
    data: TaxonomySavedWizardOut;
}>(options?: {
    params?: GetSavedTaxonomyWizardParams;
    query?: Omit<UseQueryOptions<{
        data: TaxonomySavedWizardOut;
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useQuery({
        queryKey: getSavedTaxonomyWizardKey(options?.params),
        queryFn: ()=>getSavedTaxonomyWizard(options?.params),
        ...options?.query
    });
}
export function useGetSavedTaxonomyWizardSuspense<TData = {
    data: TaxonomySavedWizardOut;
}>(options?: {
    params?: GetSavedTaxonomyWizardParams;
    query?: Omit<UseSuspenseQueryOptions<{
        data: TaxonomySavedWizardOut;
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useSuspenseQuery({
        queryKey: getSavedTaxonomyWizardKey(options?.params),
        queryFn: ()=>getSavedTaxonomyWizard(options?.params),
        ...options?.query
    });
}
export interface SaveTaxonomyWizardParams {
    "X-Forwarded-Host"?: string | null;
    "X-Forwarded-Preferred-Username"?: string | null;
    "X-Forwarded-User"?: string | null;
    "X-Forwarded-Email"?: string | null;
    "X-Request-Id"?: string | null;
    "X-Forwarded-Access-Token"?: string | null;
}
export const saveTaxonomyWizard = async (data: TaxonomyWizardStateIn, params?: SaveTaxonomyWizardParams, options?: RequestInit): Promise<{
    data: TaxonomyWizardStateOut;
}> =>{
    const res = await fetch("/api/taxonomy/saved", {
        ...options,
        method: "PUT",
        headers: {
            "Content-Type": "application/json",
            ...(params?.["X-Forwarded-Host"] != null && {
                "X-Forwarded-Host": params["X-Forwarded-Host"]
            }),
            ...(params?.["X-Forwarded-Preferred-Username"] != null && {
                "X-Forwarded-Preferred-Username": params["X-Forwarded-Preferred-Username"]
            }),
            ...(params?.["X-Forwarded-User"] != null && {
                "X-Forwarded-User": params["X-Forwarded-User"]
            }),
            ...(params?.["X-Forwarded-Email"] != null && {
                "X-Forwarded-Email": params["X-Forwarded-Email"]
            }),
            ...(params?.["X-Request-Id"] != null && {
                "X-Request-Id": params["X-Request-Id"]
            }),
            ...(params?.["X-Forwarded-Access-Token"] != null && {
                "X-Forwarded-Access-Token": params["X-Forwarded-Access-Token"]
            }),
            ...options?.headers
        },
        body: JSON.stringify(data)
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export function useSaveTaxonomyWizard(options?: {
    mutation?: UseMutationOptions<{
        data: TaxonomyWizardStateOut;
    }, ApiError, {
        params: SaveTaxonomyWizardParams;
        data: TaxonomyWizardStateIn;
    }>;
}) {
    return useMutation({
        mutationFn: (vars)=>saveTaxonomyWizard(vars.data, vars.params),
        ...options?.mutation
    });
}
export interface DiscardTaxonomyWizardParams {
    "X-Forwarded-Host"?: string | null;
    "X-Forwarded-Preferred-Username"?: string | null;
    "X-Forwarded-User"?: string | null;
    "X-Forwarded-Email"?: string | null;
    "X-Request-Id"?: string | null;
    "X-Forwarded-Access-Token"?: string | null;
}
export const discardTaxonomyWizard = async (params?: DiscardTaxonomyWizardParams, options?: RequestInit): Promise<{
    data: TaxonomyWizardDiscardOut;
}> =>{
    const res = await fetch("/api/taxonomy/saved", {
        ...options,
        method: "DELETE",
        headers: {
            ...(params?.["X-Forwarded-Host"] != null && {
                "X-Forwarded-Host": params["X-Forwarded-Host"]
            }),
            ...(params?.["X-Forwarded-Preferred-Username"] != null && {
                "X-Forwarded-Preferred-Username": params["X-Forwarded-Preferred-Username"]
            }),
            ...(params?.["X-Forwarded-User"] != null && {
                "X-Forwarded-User": params["X-Forwarded-User"]
            }),
            ...(params?.["X-Forwarded-Email"] != null && {
                "X-Forwarded-Email": params["X-Forwarded-Email"]
            }),
            ...(params?.["X-Request-Id"] != null && {
                "X-Request-Id": params["X-Request-Id"]
            }),
            ...(params?.["X-Forwarded-Access-Token"] != null && {
                "X-Forwarded-Access-Token": params["X-Forwarded-Access-Token"]
            }),
            ...options?.headers
        }
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export function useDiscardTaxonomyWizard(options?: {
    mutation?: UseMutationOptions<{
        data: TaxonomyWizardDiscardOut;
    }, ApiError, {
        params: DiscardTaxonomyWizardParams;
    }>;
}) {
    return useMutation({
        mutationFn: (vars)=>discardTaxonomyWizard(vars.params),
        ...options?.mutation
    });
}
export interface GetCatalogSchemaWarningParams {
    catalog_name: string;
}
export const getCatalogSchemaWarning = async (params: GetCatalogSchemaWarningParams, options?: RequestInit): Promise<{
    data: CatalogSchemaWarningOut;
}> =>{
    const res = await fetch(`/api/uc/catalogs/${params.catalog_name}/schema-warning`, {
        ...options,
        method: "GET"
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export const getCatalogSchemaWarningKey = (params?: GetCatalogSchemaWarningParams)=>{
    return [
        "/api/uc/catalogs/{catalog_name}/schema-warning",
        params
    ] as const;
};
export function useGetCatalogSchemaWarning<TData = {
    data: CatalogSchemaWarningOut;
}>(options: {
    params: GetCatalogSchemaWarningParams;
    query?: Omit<UseQueryOptions<{
        data: CatalogSchemaWarningOut;
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useQuery({
        queryKey: getCatalogSchemaWarningKey(options.params),
        queryFn: ()=>getCatalogSchemaWarning(options.params),
        ...options?.query
    });
}
export function useGetCatalogSchemaWarningSuspense<TData = {
    data: CatalogSchemaWarningOut;
}>(options: {
    params: GetCatalogSchemaWarningParams;
    query?: Omit<UseSuspenseQueryOptions<{
        data: CatalogSchemaWarningOut;
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useSuspenseQuery({
        queryKey: getCatalogSchemaWarningKey(options.params),
        queryFn: ()=>getCatalogSchemaWarning(options.params),
        ...options?.query
    });
}
export interface BrowseVolumesParams {
    path?: string;
}
export const browseVolumes = async (params?: BrowseVolumesParams, options?: RequestInit): Promise<{
    data: VolumeBrowseOut;
}> =>{
    const searchParams = new URLSearchParams();
    if (params?.path != null) searchParams.set("path", String(params?.path));
    const queryString = searchParams.toString();
    const url = queryString ? `/api/uc/volumes/browse?${queryString}` : "/api/uc/volumes/browse";
    const res = await fetch(url, {
        ...options,
        method: "GET"
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export const browseVolumesKey = (params?: BrowseVolumesParams)=>{
    return [
        "/api/uc/volumes/browse",
        params
    ] as const;
};
export function useBrowseVolumes<TData = {
    data: VolumeBrowseOut;
}>(options?: {
    params?: BrowseVolumesParams;
    query?: Omit<UseQueryOptions<{
        data: VolumeBrowseOut;
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useQuery({
        queryKey: browseVolumesKey(options?.params),
        queryFn: ()=>browseVolumes(options?.params),
        ...options?.query
    });
}
export function useBrowseVolumesSuspense<TData = {
    data: VolumeBrowseOut;
}>(options?: {
    params?: BrowseVolumesParams;
    query?: Omit<UseSuspenseQueryOptions<{
        data: VolumeBrowseOut;
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useSuspenseQuery({
        queryKey: browseVolumesKey(options?.params),
        queryFn: ()=>browseVolumes(options?.params),
        ...options?.query
    });
}
export interface GetUserPreferencesParams {
    "X-Forwarded-Host"?: string | null;
    "X-Forwarded-Preferred-Username"?: string | null;
    "X-Forwarded-User"?: string | null;
    "X-Forwarded-Email"?: string | null;
    "X-Request-Id"?: string | null;
    "X-Forwarded-Access-Token"?: string | null;
}
export const getUserPreferences = async (params?: GetUserPreferencesParams, options?: RequestInit): Promise<{
    data: UserPreferenceOut[];
}> =>{
    const res = await fetch("/api/user/preferences", {
        ...options,
        method: "GET",
        headers: {
            ...(params?.["X-Forwarded-Host"] != null && {
                "X-Forwarded-Host": params["X-Forwarded-Host"]
            }),
            ...(params?.["X-Forwarded-Preferred-Username"] != null && {
                "X-Forwarded-Preferred-Username": params["X-Forwarded-Preferred-Username"]
            }),
            ...(params?.["X-Forwarded-User"] != null && {
                "X-Forwarded-User": params["X-Forwarded-User"]
            }),
            ...(params?.["X-Forwarded-Email"] != null && {
                "X-Forwarded-Email": params["X-Forwarded-Email"]
            }),
            ...(params?.["X-Request-Id"] != null && {
                "X-Request-Id": params["X-Request-Id"]
            }),
            ...(params?.["X-Forwarded-Access-Token"] != null && {
                "X-Forwarded-Access-Token": params["X-Forwarded-Access-Token"]
            }),
            ...options?.headers
        }
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export const getUserPreferencesKey = (params?: GetUserPreferencesParams)=>{
    return [
        "/api/user/preferences",
        params
    ] as const;
};
export function useGetUserPreferences<TData = {
    data: UserPreferenceOut[];
}>(options?: {
    params?: GetUserPreferencesParams;
    query?: Omit<UseQueryOptions<{
        data: UserPreferenceOut[];
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useQuery({
        queryKey: getUserPreferencesKey(options?.params),
        queryFn: ()=>getUserPreferences(options?.params),
        ...options?.query
    });
}
export function useGetUserPreferencesSuspense<TData = {
    data: UserPreferenceOut[];
}>(options?: {
    params?: GetUserPreferencesParams;
    query?: Omit<UseSuspenseQueryOptions<{
        data: UserPreferenceOut[];
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useSuspenseQuery({
        queryKey: getUserPreferencesKey(options?.params),
        queryFn: ()=>getUserPreferences(options?.params),
        ...options?.query
    });
}
export interface SetUserPreferenceParams {
    key: string;
    "X-Forwarded-Host"?: string | null;
    "X-Forwarded-Preferred-Username"?: string | null;
    "X-Forwarded-User"?: string | null;
    "X-Forwarded-Email"?: string | null;
    "X-Request-Id"?: string | null;
    "X-Forwarded-Access-Token"?: string | null;
}
export const setUserPreference = async (params: SetUserPreferenceParams, data: UserPreferenceIn, options?: RequestInit): Promise<{
    data: UserPreferenceOut;
}> =>{
    const res = await fetch(`/api/user/preferences/${params.key}`, {
        ...options,
        method: "PUT",
        headers: {
            "Content-Type": "application/json",
            ...(params?.["X-Forwarded-Host"] != null && {
                "X-Forwarded-Host": params["X-Forwarded-Host"]
            }),
            ...(params?.["X-Forwarded-Preferred-Username"] != null && {
                "X-Forwarded-Preferred-Username": params["X-Forwarded-Preferred-Username"]
            }),
            ...(params?.["X-Forwarded-User"] != null && {
                "X-Forwarded-User": params["X-Forwarded-User"]
            }),
            ...(params?.["X-Forwarded-Email"] != null && {
                "X-Forwarded-Email": params["X-Forwarded-Email"]
            }),
            ...(params?.["X-Request-Id"] != null && {
                "X-Request-Id": params["X-Request-Id"]
            }),
            ...(params?.["X-Forwarded-Access-Token"] != null && {
                "X-Forwarded-Access-Token": params["X-Forwarded-Access-Token"]
            }),
            ...options?.headers
        },
        body: JSON.stringify(data)
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export function useSetUserPreference(options?: {
    mutation?: UseMutationOptions<{
        data: UserPreferenceOut;
    }, ApiError, {
        params: SetUserPreferenceParams;
        data: UserPreferenceIn;
    }>;
}) {
    return useMutation({
        mutationFn: (vars)=>setUserPreference(vars.params, vars.data),
        ...options?.mutation
    });
}
export interface DeleteUserPreferenceParams {
    key: string;
    "X-Forwarded-Host"?: string | null;
    "X-Forwarded-Preferred-Username"?: string | null;
    "X-Forwarded-User"?: string | null;
    "X-Forwarded-Email"?: string | null;
    "X-Request-Id"?: string | null;
    "X-Forwarded-Access-Token"?: string | null;
}
export const deleteUserPreference = async (params: DeleteUserPreferenceParams, options?: RequestInit): Promise<{
    data: UserPreferenceDeleteOut;
}> =>{
    const res = await fetch(`/api/user/preferences/${params.key}`, {
        ...options,
        method: "DELETE",
        headers: {
            ...(params?.["X-Forwarded-Host"] != null && {
                "X-Forwarded-Host": params["X-Forwarded-Host"]
            }),
            ...(params?.["X-Forwarded-Preferred-Username"] != null && {
                "X-Forwarded-Preferred-Username": params["X-Forwarded-Preferred-Username"]
            }),
            ...(params?.["X-Forwarded-User"] != null && {
                "X-Forwarded-User": params["X-Forwarded-User"]
            }),
            ...(params?.["X-Forwarded-Email"] != null && {
                "X-Forwarded-Email": params["X-Forwarded-Email"]
            }),
            ...(params?.["X-Request-Id"] != null && {
                "X-Request-Id": params["X-Request-Id"]
            }),
            ...(params?.["X-Forwarded-Access-Token"] != null && {
                "X-Forwarded-Access-Token": params["X-Forwarded-Access-Token"]
            }),
            ...options?.headers
        }
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export function useDeleteUserPreference(options?: {
    mutation?: UseMutationOptions<{
        data: UserPreferenceDeleteOut;
    }, ApiError, {
        params: DeleteUserPreferenceParams;
    }>;
}) {
    return useMutation({
        mutationFn: (vars)=>deleteUserPreference(vars.params),
        ...options?.mutation
    });
}
export interface GetUserRoleParams {
    "X-Forwarded-Host"?: string | null;
    "X-Forwarded-Preferred-Username"?: string | null;
    "X-Forwarded-User"?: string | null;
    "X-Forwarded-Email"?: string | null;
    "X-Request-Id"?: string | null;
    "X-Forwarded-Access-Token"?: string | null;
}
export const getUserRole = async (params?: GetUserRoleParams, options?: RequestInit): Promise<{
    data: Record<string, unknown>;
}> =>{
    const res = await fetch("/api/user/role", {
        ...options,
        method: "GET",
        headers: {
            ...(params?.["X-Forwarded-Host"] != null && {
                "X-Forwarded-Host": params["X-Forwarded-Host"]
            }),
            ...(params?.["X-Forwarded-Preferred-Username"] != null && {
                "X-Forwarded-Preferred-Username": params["X-Forwarded-Preferred-Username"]
            }),
            ...(params?.["X-Forwarded-User"] != null && {
                "X-Forwarded-User": params["X-Forwarded-User"]
            }),
            ...(params?.["X-Forwarded-Email"] != null && {
                "X-Forwarded-Email": params["X-Forwarded-Email"]
            }),
            ...(params?.["X-Request-Id"] != null && {
                "X-Request-Id": params["X-Request-Id"]
            }),
            ...(params?.["X-Forwarded-Access-Token"] != null && {
                "X-Forwarded-Access-Token": params["X-Forwarded-Access-Token"]
            }),
            ...options?.headers
        }
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export const getUserRoleKey = (params?: GetUserRoleParams)=>{
    return [
        "/api/user/role",
        params
    ] as const;
};
export function useGetUserRole<TData = {
    data: Record<string, unknown>;
}>(options?: {
    params?: GetUserRoleParams;
    query?: Omit<UseQueryOptions<{
        data: Record<string, unknown>;
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useQuery({
        queryKey: getUserRoleKey(options?.params),
        queryFn: ()=>getUserRole(options?.params),
        ...options?.query
    });
}
export function useGetUserRoleSuspense<TData = {
    data: Record<string, unknown>;
}>(options?: {
    params?: GetUserRoleParams;
    query?: Omit<UseSuspenseQueryOptions<{
        data: Record<string, unknown>;
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useSuspenseQuery({
        queryKey: getUserRoleKey(options?.params),
        queryFn: ()=>getUserRole(options?.params),
        ...options?.query
    });
}
export const version = async (options?: RequestInit): Promise<{
    data: VersionOut;
}> =>{
    const res = await fetch("/api/version", {
        ...options,
        method: "GET"
    });
    if (!res.ok) {
        const body = await res.text();
        let parsed: unknown;
        try {
            parsed = JSON.parse(body);
        } catch  {
            parsed = body;
        }
        throw new ApiError(res.status, res.statusText, parsed);
    }
    return {
        data: await res.json()
    };
};
export const versionKey = ()=>{
    return [
        "/api/version"
    ] as const;
};
export function useVersion<TData = {
    data: VersionOut;
}>(options?: {
    query?: Omit<UseQueryOptions<{
        data: VersionOut;
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useQuery({
        queryKey: versionKey(),
        queryFn: ()=>version(),
        ...options?.query
    });
}
export function useVersionSuspense<TData = {
    data: VersionOut;
}>(options?: {
    query?: Omit<UseSuspenseQueryOptions<{
        data: VersionOut;
    }, ApiError, TData>, "queryKey" | "queryFn">;
}) {
    return useSuspenseQuery({
        queryKey: versionKey(),
        queryFn: ()=>version(),
        ...options?.query
    });
}
