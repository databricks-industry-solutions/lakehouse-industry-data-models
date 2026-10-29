import { createFileRoute, Link, useNavigate, useParams, useSearch } from "@tanstack/react-router";
import { Suspense, useCallback, useEffect, useMemo, useRef, useState } from "react";
import { useQuery } from "@tanstack/react-query";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import {
  ArrowLeft,
  ArrowRight,
  ChevronDown,
  ChevronRight,
  FolderOpen,
} from "lucide-react";
import {
  compileVibeInputs,
  createRun,
  useGetAgentCompat,
  useGetAgentConfig,
  useGetBusinessSuspense,
  useGetCatalogSchemaWarning,
  useGetExplorerVersions,
  useGetModelSummary,
  useGetRunDefaults,
  useListVersionsSuspense,
  useListVibeInputs,
  validateRun,
  type CompileOut,
  type IssueOut,
  type ModelVersionOut,
  type RunIn,
  type VibeInputOut,
} from "@/lib/api";
import {
  derivedRunMode,
  EXCLUDED_REASON_LABELS,
  matchScopeDomains,
  feedbackScopeDomains,
  feedbackScopePrefill,
  modelWideExcludedCount,
  modelWideScopeNote,
  parseRunModeParam,
  parseScopeDomainsParam,
  parseScopeFromParam,
  scopedNeedsLatestNote,
  scopeKey,
  scopeLabel as formatScopeLabel,
  vibeScopeRequestFields,
  type AgentRunMode,
  type ScopeFrom,
  type VibeScopeMode,
} from "@/lib/vibe-scope";
import { VibeScopeControl } from "@/components/runs/vibe-scope-control";
import { ScopePrefillBanner, ScopePrefillNotes } from "@/components/runs/scope-prefill-notices";
import { installTargetCatalog } from "@/lib/install-catalog";
import { anchorPathForCompile } from "@/components/vibe-inputs/state";
import { selector } from "@/lib/selector";
import { notifyConfigMissing } from "@/lib/notify";
import { apiErrorMessage } from "@/lib/api-error";
import {
  baseDeepLinkNotice,
  baseVersionCandidates,
  baseVersionLabel,
  deriveRunFormBlockers,
  isSupersededBase,
  runDropsOwnSchemas,
} from "@/lib/run-form";
import {
  parseRuntimeBudgetInput,
  runtimeBudgetBoundsError,
  runtimeBudgetBoundsText,
} from "@/lib/runtime-budget";
import { CompiledPreview } from "@/components/vibe-inputs/compiled-preview";
import { SELECTION_SAVING_MESSAGE, useIsSelectionSaving } from "@/components/vibe-inputs/use-vibe-input-selection";
import { runTypeToIntent } from "@/lib/intent";
import { FORM_OPERATIONS, formOperationFromParam, normalizeOperationParam } from "@/lib/operations";
import { runCreatesSchemas } from "@/lib/catalog-capability";
import { Skeleton } from "@/components/ui/skeleton";
import { TagInput } from "@/components/ui/tag-input";
import { MarkdownEditor } from "@/components/ui/markdown-editor";
import { LaunchRunDialog } from "@/components/runs/launch-run-dialog";
import { HelpLink } from "@/components/help/help-link";
import { HISTORY_TRACKING_HINT, HOUSEKEEPING_COLUMNS_HINT } from "@/lib/tracking-columns";
import { DeleteBlockedVersionsAction } from "@/components/versions/delete-blocked-versions-action";
import { cn } from "@/lib/utils";
import {
  BASE_UNSET_NOTE,
  effectiveConventions,
  LOAD_FAILED_NOTE,
  LOADING_NOTE,
  LOCKED_NOTE,
  lockedPlaceholder,
  PREFILL_FIELDS,
  sourceLabel,
  UNREAD_NOTE,
  vibeConventionBody,
  type EffectiveField,
  type PrefillField,
} from "@/lib/run-defaults";
import { DeploymentCatalogPicker } from "@/components/runs/deployment-catalog-picker";
import { VolumePicker } from "@/components/import/volume-picker";
import { ORG_DIVISIONS_ALL, ORG_DIVISIONS_PRESETS, isOrgDivisionsPreset } from "@/lib/org-divisions";
import { joinCommaList, splitCommaList } from "@/lib/comma-list";
import {
  agentTooOldForScope,
  BOOLEAN_FORMATS,
  CATALOGING_STYLES,
  DATE_FORMATS,
  MIN_AGENT_MARKER_FOR_SCOPE,
  NAMING_CONVENTIONS,
  NO_YES,
  TABLE_ID_TYPES,
  TIMESTAMP_FORMATS,
} from "@/lib/run-options";

/** Operations a deep link may still name that the form no longer offers.
 *  Install and uninstall act on one chosen version, so they start from that
 *  version's page; Generate Samples is retired. */
const REMOVED_OPERATIONS = new Map<string, "version_page" | "retired">([
  ["install", "version_page"],
  ["install model", "version_page"],
  ["uninstall", "version_page"],
  ["uninstall model", "version_page"],
  ["uninstall model version", "version_page"],
  ["generate samples", "retired"],
  ["generate sample data", "retired"],
]);

const CONVENTION_DEFAULTS = {
  naming_convention: "snake_case",
  primary_key_suffix: "_id",
  // Legacy single schema_prefix — still sent for non-unified ops (vibe/
  // shrink/etc). For `new base model` runs `ecm_schema_prefix` +
  // `mvm_schema_prefix` take over; see the Advanced accordion below.
  schema_prefix: "",
  // Per-scope prefixes for the unified ECM→MVM pipeline (#122). Defaults
  // mirror what the router computes from `cataloging_style` so the form
  // preview matches the server-side behaviour.
  ecm_schema_prefix: "ecm_",
  mvm_schema_prefix: "mvm_",
  schema_suffix: "",
  tag_prefix: "dbx_",
  tag_suffix: "",
  table_id_type: "BIGINT",
  boolean_format: "Boolean (True/False)",
  date_format: "yyyy-MM-dd",
  timestamp_format: "yyyy-MM-dd HH:mm:ss",
  cataloging_style: "One Catalog",
  catalog_prefix: "",
  catalog_suffix: "",
  org_divisions: "Operations",
  business_domains: "",
  classification_levels: "",
  housekeeping_columns: "No",
  history_tracking_columns: "No",
};

type RunsNewSearch = {
  operationType?: string;
  /** Pre-select a base version by its integer version. Pairs with
   *  ``sourceScope`` to disambiguate when the same number hosts both
   *  ECM and MVM rows. */
  sourceVersion?: number;
  /** Pre-select the scope of the base version. Defaults to ``mvm`` —
   *  the deployable scope and the most common iterate target. */
  sourceScope?: string;
  /** Deep link: comma-separated domain names. When it names at least one
   *  domain, the scope starts as Some domains with these names (D15). */
  scopeDomains?: string;
  /** Set by the compose surface when `scopeDomains` comes from the selected
   *  feedback; turns on the pre-fill banner and notes. */
  scopeFrom?: ScopeFrom;
  /** Deep link: an explicit agent run type. Without it the run type is Dry Run. */
  runMode?: AgentRunMode;
};

export const Route = createFileRoute("/_sidebar/businesses/$businessId/runs/new")({
  validateSearch: (search: Record<string, unknown>): RunsNewSearch => ({
    operationType: typeof search.operationType === "string" ? search.operationType : undefined,
    sourceVersion:
      search.sourceVersion != null && search.sourceVersion !== ""
        ? Number(search.sourceVersion)
        : undefined,
    sourceScope: typeof search.sourceScope === "string" ? search.sourceScope : undefined,
    scopeDomains:
      search.scopeDomains != null && search.scopeDomains !== ""
        ? String(search.scopeDomains)
        : undefined,
    scopeFrom: parseScopeFromParam(search.scopeFrom),
    runMode: parseRunModeParam(search.runMode),
  }),
  component: () => {
    const { businessId } = useParams({ from: "/_sidebar/businesses/$businessId/runs/new" });
    return (
      <div className="p-6 space-y-6">
        <div className="flex items-center gap-4">
          <Button variant="ghost" size="icon" asChild>
            <Link to="/businesses/$businessId/explorer" params={{ businessId }}>
              <ArrowLeft className="h-4 w-4" />
            </Link>
          </Button>
          <h1 className="text-2xl font-semibold tracking-tight">New Run</h1>
          <HelpLink topic="runs" className="ml-auto text-sm">Run types</HelpLink>
        </div>
        <Suspense fallback={<Skeleton className="h-96" />}>
          <NewRunForm key={businessId} />
        </Suspense>
      </div>
    );
  },
});

/** Default org_divisions per model scope */
function scopeDefaultDivisions(size: string): string {
  return size === "large model" ? ORG_DIVISIONS_ALL : "Operations";
}

/** The id of the note a locked Advanced Options field points to. */
const LOCKED_NOTE_ID = "run-conventions-locked-note";

/** A locked field stays readable: full opacity on the muted surface
 *  (WCAG AA in both themes; the default disabled look is not). */
const LOCKED_CLASS = "disabled:opacity-100 disabled:bg-muted";

/** Props that disable a pre-filled field the vibe locks and say why. */
function lockProps(field: EffectiveField | undefined, className = "h-8 text-sm") {
  const title = (field && sourceLabel(field)) || undefined;
  return field?.locked
    ? { disabled: true, "aria-describedby": LOCKED_NOTE_ID, title, className: cn(className, LOCKED_CLASS) }
    : { title, className };
}

/** Under an unlocked field the base model leaves empty. */
function BaseUnsetNote({ field }: { field: EffectiveField }) {
  if (field.locked || !field.baseUnset) return null;
  return <p className="text-[10px] text-muted-foreground">{BASE_UNSET_NOTE}</p>;
}

/**
 * A Select over one of the agent's widget value lists (`lib/run-options.ts`).
 * A value off the list (a base model's LONG, say) is shown as its own item;
 * `placeholder` shows instead of the value when there is none to show.
 */
function ConventionSelect({
  id,
  value,
  options,
  onChange,
  field,
  placeholder,
}: {
  id: string;
  value: string;
  options: readonly string[];
  onChange: (value: string) => void;
  field?: EffectiveField;
  placeholder?: string;
}) {
  const shown = placeholder ? "" : value;
  const items = shown && !options.includes(shown) ? [...options, shown] : options;
  return (
    <Select value={shown} onValueChange={onChange} disabled={field?.locked}>
      <SelectTrigger id={id} {...lockProps(field)}>
        <SelectValue placeholder={placeholder} />
      </SelectTrigger>
      <SelectContent>
        {items.map((o) => (
          <SelectItem key={o} value={o}>{o}</SelectItem>
        ))}
      </SelectContent>
    </Select>
  );
}

/** Shown when a deep link names an operation the form no longer offers. */
function RemovedOperationNotice({
  kind,
  businessId,
  versions,
}: {
  kind: "version_page" | "retired";
  businessId: string;
  versions: readonly ModelVersionOut[];
}) {
  return (
    <div
      role="status"
      data-testid="removed-operation-notice"
      className="rounded-md border border-input bg-muted/30 p-3 text-sm space-y-2"
    >
      {kind === "retired" ? (
        <p>Generate Samples was retired: the agent no longer generates sample data.</p>
      ) : (
        <>
          <p>Install or uninstall a version from its page.</p>
          {versions.length > 0 && (
            <ul className="flex flex-wrap gap-x-4 gap-y-1">
              {versions.map((v) => (
                <li key={v.id}>
                  <Link
                    to="/businesses/$businessId/model/$version/$scope"
                    params={{
                      businessId,
                      version: String(v.version),
                      scope: (v.scope || "mvm").toLowerCase(),
                    }}
                    search={{ tab: "overview" }}
                    className="text-primary hover:underline"
                  >
                    Open v{v.version} {(v.scope || "mvm").toUpperCase()}
                  </Link>
                </li>
              ))}
            </ul>
          )}
        </>
      )}
    </div>
  );
}

function NewRunForm() {
  const navigate = useNavigate();
  const { businessId } = useParams({
    from: "/_sidebar/businesses/$businessId/runs/new",
  });
  const {
    operationType,
    sourceVersion,
    sourceScope,
    scopeDomains: scopeDomainsParam,
    scopeFrom,
    runMode,
  } = useSearch({ from: "/_sidebar/businesses/$businessId/runs/new" });
  // Suspense-driven loads. The QueryClient in `main.tsx` sets
  // `refetchOnWindowFocus: false` globally so opening a Popover (catalog
  // picker, etc.) does not re-suspend the form and wipe typed content
  // (the model-versioning work fix M).
  const { data: versions } = useListVersionsSuspense({
    params: { business_id: businessId },
    ...selector(),
  });
  const { data: business } = useGetBusinessSuspense({
    params: { business_id: businessId },
    ...selector(),
  });

  const hasVersions = versions.length > 0;
  const completedVersions = versions.filter((v) => v.status === "completed");
  // The Vibe Modeling base picker offers every finished non-draft version,
  // superseded ones included; the server accepts any explicit parent.
  const baseCandidates = baseVersionCandidates(versions);
  // "(vibed)" follows the explorer's Base / Vibed brand (`is_base`), which the
  // version list does not carry.
  const { data: explorerVersions } = useGetExplorerVersions({
    params: { business_id: businessId },
    query: { select: (resp) => resp.data },
  });
  const isBaseById = new Map((explorerVersions ?? []).map((v) => [v.id, v.is_base]));
  const latestVersion = versions[0]; // sorted desc by version
  // The URL ``operationType`` param accepts either an OperationType
  // value (``"vibe modeling of version"``) or its Intent alias
  // (``"vibe-iterate"``). Normalise to OperationType so the Select
  // pre-populates correctly.
  const requestedRunType = operationType ? formOperationFromParam(operationType) : "";
  const removedOperation = operationType
    ? REMOVED_OPERATIONS.get(normalizeOperationParam(operationType))
    : undefined;
  const defaultRunType =
    FORM_OPERATIONS.includes(requestedRunType)
    && !(hasVersions && requestedRunType === "new base model")
      ? requestedRunType
      : hasVersions
        ? "vibe modeling of version"
        : "new base model";

  const [runType, setRunType] = useState(defaultRunType);
  // Keep the URL naming the operation the form shows (the top bar Help link
  // reads it): on mount when the URL names none or another (the form may have
  // started elsewhere), and on every change of the Select. `replace` keeps
  // Back going to the page before the form. A removed operation's deep link
  // keeps its URL, which names the notice below, until the user picks an
  // operation.
  const [operationPicked, setOperationPicked] = useState(false);
  useEffect(() => {
    if ((removedOperation && !operationPicked) || requestedRunType === runType) return;
    navigate({
      to: "/businesses/$businessId/runs/new",
      params: { businessId },
      search: (prev) => ({ ...prev, operationType: runTypeToIntent(runType) }),
      replace: true,
    });
  }, [removedOperation, operationPicked, requestedRunType, runType, navigate, businessId]);
  const [catalog, setCatalog] = useState(installTargetCatalog(latestVersion));
  const [contextMode, setContextMode] = useState<"path" | "text">("text");
  const [businessContextPath, setBusinessContextPath] = useState("");
  // Volume browser dialog for the File-Path business-context mode. Manual
  // entry into the text input stays as the fallback (U-05).
  const [volumePickerOpen, setVolumePickerOpen] = useState(false);
  // Business Context starts empty; the effect below seeds it from
  // `business.description` on first render (and on subsequent business
  // identity changes) ONLY while the user has not yet edited the textarea.
  // Once `businessContextDirty` flips true, any future re-render of this
  // form (Suspense re-mount, business object identity change, etc.) will
  // NOT clobber what the user typed. This is the second layer of defence
  // for the model-versioning work fix M; the first layer is the QueryClient-wide
  // `refetchOnWindowFocus: false` in `main.tsx`.
  const [businessContextText, setBusinessContextText] = useState("");
  const [businessContextDirty, setBusinessContextDirty] = useState(false);
  useEffect(() => {
    if (!businessContextDirty && business?.description) {
      setBusinessContextText(business.description);
    }
  }, [business?.description, businessContextDirty]);
  // URL preselect: prefer (sourceVersion, sourceScope) over the latest row.
  // Default sourceScope to "mvm" — the deployable scope and the most common
  // iterate target. Falls back to the freshest completed version when no
  // preselect URL params are set.
  const initialBaseVersionId = (() => {
    if (sourceVersion != null) {
      const wantedScope = (sourceScope || "mvm").toLowerCase();
      const exact = baseCandidates.find(
        (v) =>
          v.version === sourceVersion
          && ((v as any).scope || "").toLowerCase() === wantedScope,
      );
      if (exact) return exact.id;
      // Fall back to a same-version match in any scope so the user lands
      // somewhere reasonable rather than the wrong row.
      const anyScope = baseCandidates.find((v) => v.version === sourceVersion);
      if (anyScope) return anyScope.id;
    }
    return completedVersions[0]?.id || baseCandidates[0]?.id || "";
  })();
  const [baseVersionId, setBaseVersionId] = useState(initialBaseVersionId);
  // Where a removed-operation deep link sends the user: the version it names,
  // else the latest completed version of each scope.
  const removedOperationVersions: ModelVersionOut[] = (() => {
    if (!removedOperation) return [];
    if (sourceVersion != null) {
      const wantedScope = (sourceScope || "mvm").toLowerCase();
      const named =
        versions.find(
          (v) => v.version === sourceVersion && (v.scope || "mvm").toLowerCase() === wantedScope,
        ) ?? versions.find((v) => v.version === sourceVersion);
      if (named) return [named];
    }
    const seenScopes = new Set<string>();
    return completedVersions.filter((v) => {
      const scope = (v.scope || "mvm").toLowerCase();
      if (seenScopes.has(scope)) return false;
      seenScopes.add(scope);
      return true;
    });
  })();
  // Remember the base-version selection per operation type so switching
  // Operation Type and back restores the prior selection instead of
  // silently losing it (E-01). The selected Vibe Inputs are durable
  // server-side (`selected_for_run`, keyed by version), so restoring the
  // version id re-derives the exact selection + count. Populated on
  // op-switch (handleRunTypeChange stashes the outgoing op's version) and
  // on explicit base-version picks, then read by the reconcile effect on
  // switch-back.
  const selectionByOpRef = useRef<Record<string, string>>({});
  // The run dispatches the inputs the user selected on the compose surface:
  // active, anchored, non-consumed, and `selected_for_run`. The server
  // re-compiles authoritatively from these ids on launch.
  const { data: vibeInputs } = useListVibeInputs({
    params: { business_id: businessId, version_id: baseVersionId, status: "active" },
    query: { enabled: Boolean(baseVersionId), select: (resp) => resp.data },
  });

  const { data: catalogWarningData } = useGetCatalogSchemaWarning({
    params: { catalog_name: catalog },
    query: { enabled: Boolean(catalog), select: (resp) => resp.data },
  });
  const catalogSchemaCount = catalogWarningData?.schema_count ?? 0;
  const baseInputs: VibeInputOut[] = (Array.isArray(vibeInputs) ? vibeInputs : []).filter(
    (vi) => !vi.consumed && vi.anchor != null && vi.selected_for_run,
  );
  const inputIds = baseInputs.map((vi) => vi.id);
  // Queued selection writes (and the refetch after them) are still in flight:
  // the list above is not the selection the user made yet.
  const selectionSaving = useIsSelectionSaving(businessId);
  const includedInputIds = new Set(inputIds);
  const [vibeInstructions, setVibeInstructions] = useState("");
  // Run Instructions seeds from `business.business_vibes` (the long
  // description) on first render, mirroring the businessContext pattern
  // above. The backend fallback injects `business_vibes` when this field is
  // empty, so pre-filling makes that injected text visible and editable. The
  // dirty flag stops any re-render from clobbering what the user typed.
  const [vibeInstructionsDirty, setVibeInstructionsDirty] = useState(false);
  useEffect(() => {
    if (!vibeInstructionsDirty && business?.business_vibes) {
      setVibeInstructions(business.business_vibes);
    }
  }, [business?.business_vibes, vibeInstructionsDirty]);
  const [submitting, setSubmitting] = useState(false);
  const [error, setError] = useState("");
  // The business's proposed domains + coverage (saved by the Domain Taxonomy
  // Builder, or on the edit page) pre-fill the FIRST New Base Model run only:
  // with versions, New Base Model is disabled, so nothing is seeded. They live
  // inside the Advanced Options disclosure; open it when either is seeded, so
  // the user sees what they're about to launch with.
  const seedFromBusiness = !hasVersions && defaultRunType === "new base model";
  const domains = seedFromBusiness ? (business?.business_domains ?? "") : "";
  const orgDivisions =
    seedFromBusiness && isOrgDivisionsPreset(business?.org_divisions ?? "") ? business!.org_divisions : "";
  const [advancedOpen, setAdvancedOpen] = useState(() => Boolean(domains.trim() || orgDivisions));
  // Dialog gate. Submit only actually fires createRun once the user confirms
  // via the LaunchRunDialog — preventing accidental submissions from stray
  // Enter presses (e.g. in the TagInput, see PR #115).
  const [confirmOpen, setConfirmOpen] = useState(false);

  // Convention overrides — initialized to defaults
  const [conventions, setConventions] = useState(() => ({
    ...CONVENTION_DEFAULTS,
    ...(orgDivisions ? { org_divisions: orgDivisions } : {}),
  }));
  // Multi-value fields stored as arrays, serialized to comma-separated on submit
  const [domainTags, setDomainTags] = useState<string[]>(() => splitCommaList(domains));
  // Track whether user manually changed org_divisions. A pre-filled value
  // counts as a manual choice, so the model size never overrides it.
  const [orgDivisionsManual, setOrgDivisionsManual] = useState(Boolean(orgDivisions));

  // The fields the user changed: on a vibe these keep the user's value over
  // the base model's pre-fill (unless the vibe locks the field).
  const [editedFields, setEditedFields] = useState<ReadonlySet<string>>(() => new Set());
  const updateConvention = useCallback((key: keyof typeof CONVENTION_DEFAULTS, value: string) => {
    setConventions((prev) => ({ ...prev, [key]: value }));
    setEditedFields((prev) => (prev.has(key) ? prev : new Set(prev).add(key)));
  }, []);

  // Run time budget (whole hours): prefilled from the Settings default and
  // always sent, so the run stores the value the user saw. Kept out of
  // `conventions`, whose submit filter keeps only non-empty strings. Until the
  // agent config loads the field is absent and the server applies the
  // Settings default itself.
  const { data: agentConfig } = useGetAgentConfig({
    query: { retry: false, select: (resp) => resp.data },
  });
  const budgetDefault = agentConfig?.runtime_budget_hours;
  const budgetMin = agentConfig?.runtime_budget_min_hours;
  const budgetMax = agentConfig?.runtime_budget_max_hours;
  const [runtimeBudgetChoice, setRuntimeBudgetChoice] = useState<number | null>(null);
  const runtimeBudgetHours = runtimeBudgetChoice ?? budgetDefault ?? null;
  const runtimeBudgetError = runtimeBudgetBoundsError(runtimeBudgetHours, budgetMin, budgetMax);
  const runtimeBudgetFields: Pick<RunIn, "runtime_budget_hours"> =
    runtimeBudgetHours !== null && !runtimeBudgetError
      ? { runtime_budget_hours: runtimeBudgetHours }
      : {};

  const isVibeIterate = runType === "vibe modeling of version";
  const isVibeCombined = runType === "vibe new ecm + mvm";
  // The combined "Vibe ECM + MVM" run reuses the same form fields as
  // vibe-iterate (parent_version_id, vibe_instructions, business_context_text,
  // catalog, cataloging_style, schema prefixes). Treat them identically for
  // form rendering and submission. The BE differentiates by intent slug; the
  // validate endpoint also enforces "parent must be ECM scope" for the
  // combined intent.
  const isVibe = isVibeIterate || isVibeCombined;
  const isBase = runType === "new base model";
  const isSingleCatalog = conventions.cataloging_style === "One Catalog";

  // ─── Vibe scope + agent run type (design §9.1, D15) ───
  // Only a vibe iteration carries these. A deep link whose `scopeDomains`
  // names a domain starts on Some domains; otherwise All domains. The run type is the user's
  // explicit choice (a `runMode` deep link counts as one); until they choose,
  // it is Dry Run for either scope.
  // An agent older than the scope marker overrides both: All domains, Full Run.
  // `agentRunMode` is named so it does not clash with `runType` (the operation).
  // A link whose list parses empty (e.g. `,,`) starts on All domains.
  // A scope pre-filled from the feedback needs the scope head as its base
  // (`scoped_base_blocker`); a base behind the head opens on All domains.
  const headOfBase = (v: ModelVersionOut | undefined) =>
    v && v.is_head === false
      ? versions.find((x) => x.is_head && (x.scope || "") === (v.scope || ""))
      : undefined;
  const [scopePrefill] = useState(() => {
    const requested = parseScopeDomainsParam(scopeDomainsParam);
    const blocked =
      scopeFrom === "feedback"
      && requested.length > 0
      && headOfBase(versions.find((v) => v.id === baseVersionId)) != null;
    return { domains: blocked ? [] : requested, blocked };
  });
  const initialScopeDomains = scopePrefill.domains;
  const [scopeEdited, setScopeEdited] = useState(false);
  const [vibeScopeChoice, setVibeScope] = useState<VibeScopeMode>(
    initialScopeDomains.length > 0 ? "some_domains" : "all_domains",
  );
  const [scopeDomains, setScopeDomains] = useState<string[]>(initialScopeDomains);
  const [agentRunModeChoice, setAgentRunModeChoice] = useState<AgentRunMode | null>(
    runMode ?? null,
  );
  // An agent older than the scope marker runs only unscoped Full Runs: the
  // form locks All domains + Full Run and a note says why. The installed
  // version is unknown (null) until the backend has read the notebook.
  const { data: agentCompat } = useGetAgentCompat({
    query: { enabled: isVibeIterate, select: (resp) => resp.data },
  });
  const oldAgentVersion = isVibeIterate
    ? agentTooOldForScope(agentCompat?.installed_agent_version)
    : null;
  const vibeScope: VibeScopeMode = oldAgentVersion ? "all_domains" : vibeScopeChoice;
  const agentRunMode: AgentRunMode = oldAgentVersion
    ? "full"
    : (agentRunModeChoice ?? derivedRunMode());
  const isScoped = isVibeIterate && vibeScope === "some_domains";
  const baseVersion = baseCandidates.find((v) => v.id === baseVersionId);
  // The base model's conventions pre-fill a vibe's Advanced Options and lock
  // the ones the agent keeps (`lib/run-defaults.ts`). Keyed on the base only.
  const runDefaultsQuery = useGetRunDefaults({
    params: { business_id: businessId, model_version_id: baseVersionId },
    query: { enabled: isVibe && Boolean(baseVersionId), retry: false, select: (resp) => resp.data },
  });
  const runDefaults =
    isVibe && runDefaultsQuery.data?.base_version_id === baseVersionId ? runDefaultsQuery.data : undefined;
  const runDefaultsLoading = isVibe && Boolean(baseVersionId) && runDefaultsQuery.isLoading;
  const runDefaultsFailed = isVibe && Boolean(baseVersionId) && runDefaultsQuery.isError;
  const effective = useMemo(() => {
    const edits: Partial<Record<PrefillField, string>> = {};
    for (const f of PREFILL_FIELDS) if (editedFields.has(f)) edits[f] = conventions[f];
    return effectiveConventions(runDefaults, edits, isScoped, conventions);
  }, [runDefaults, editedFields, conventions, isScoped]);
  const anyLocked = isVibe && PREFILL_FIELDS.some((f) => effective[f].locked);
  // What a text field shows; unknown (null) shows empty with a placeholder.
  const shown = (f: PrefillField) => effective[f].value ?? "";
  // A vibe iteration keeps its base's size: the backend dispatches the parent
  // version's scope (`vibe_iterate.py`), and an ECM is the large model.
  const modelSize =
    baseVersion && (baseVersion.scope || "ecm").toLowerCase() === "ecm"
      ? "large model"
      : "small model";
  // Until the user picks divisions, a vibe iteration's follow that size
  // (derived, never written back), so the Select and the body agree. Other
  // operations keep the form default.
  // A vibe pre-fills them from the run that made its base, when that run
  // recorded them.
  const orgPrefill = runDefaults?.fields.org_divisions;
  const orgFromBase =
    orgPrefill && orgPrefill.source !== "default" && isOrgDivisionsPreset(orgPrefill.value ?? "")
      ? orgPrefill.value!
      : null;
  const orgDivisionsAuto = !orgDivisionsManual && isVibeIterate && orgFromBase === null;
  const orgDivisionsValue = orgDivisionsManual
    ? conventions.org_divisions
    : orgFromBase
      ?? (isVibeIterate ? scopeDefaultDivisions(modelSize) : CONVENTION_DEFAULTS.org_divisions);
  const behindHead = headOfBase(baseVersion);
  // "Scope to ..." hint: on All domains, the selected feedback may fit in a
  // scope. The unscoped compile maps each item to its scope domain. A base
  // behind the scope head cannot be scoped, so nothing is fetched for it.
  const scopeHintWanted =
    isVibeIterate
    && !isScoped
    && !oldAgentVersion
    && Boolean(baseVersionId)
    && inputIds.length > 0
    && !behindHead;
  const { data: feedbackCompile } = useQuery({
    queryKey: ["feedback-scope-domains", businessId, baseVersionId, inputIds.join(",")],
    queryFn: async () =>
      (await compileVibeInputs(
        { business_id: businessId, version_id: baseVersionId },
        { input_ids: inputIds },
      )).data,
    enabled: scopeHintWanted,
    retry: false,
  });
  const { data: baseSummary } = useGetModelSummary({
    params: {
      business_id: businessId,
      version_int: baseVersion?.version ?? 0,
      scope: baseVersion?.scope || "mvm",
    },
    query: { enabled: (isScoped || scopeHintWanted) && Boolean(baseVersion), select: (resp) => resp.data },
  });
  // Distinct live domain names of the base. Deleted placeholders carry id "".
  const baseDomainNames = useMemo(() => {
    if (!baseSummary) return undefined;
    const names: string[] = [];
    for (const d of baseSummary.domains ?? []) {
      if (d.id === "" || names.includes(d.name)) continue;
      names.push(d.name);
    }
    return names;
  }, [baseSummary]);
  const { matched: matchedScopeDomains, unknown: unknownScopeDomains } = useMemo(
    () =>
      baseDomainNames
        ? matchScopeDomains(scopeDomains, baseDomainNames)
        : { matched: scopeDomains, unknown: [] as string[] },
    [scopeDomains, baseDomainNames],
  );
  const handleScopeChange = useCallback((next: VibeScopeMode) => {
    setScopeEdited(true);
    setVibeScope(next);
  }, []);
  const handleToggleScopeDomain = useCallback((name: string, checked: boolean) => {
    setScopeEdited(true);
    const key = scopeKey(name);
    setScopeDomains((prev) => {
      const rest = prev.filter((n) => scopeKey(n) !== key);
      return checked ? [...rest, name] : rest;
    });
  }, []);
  const handleRemoveUnknownScopeDomain = useCallback((name: string) => {
    setScopeEdited(true);
    setScopeDomains((prev) => prev.filter((n) => n !== name));
  }, []);
  // Shared by the validate and create bodies. The server matches the names,
  // rewrites them to the stored spelling, and rejects unknown ones. An
  // unscoped Full Run sends none of these, so its body is unchanged.
  const vibeScopeFields: Pick<RunIn, "vibe_scope" | "vibe_scope_domains" | "dry_run"> =
    isVibeIterate ? vibeScopeRequestFields(vibeScope, scopeDomains, agentRunMode) : {};

  // Scoped preview: the server compile filtered by the scope decides which
  // inputs are sent. Unscoped runs keep the FE twin preview unchanged.
  const scopedCompileKey = isScoped
    ? `${baseVersionId}|${inputIds.join(",")}|${scopeDomains.join(",")}`
    : "";
  const [scopedCompile, setScopedCompile] = useState<
    { key: string; baseVersionId: string; data: CompileOut | null; error?: string } | null
  >(null);
  useEffect(() => {
    if (!isScoped || !baseVersionId || inputIds.length === 0) {
      setScopedCompile(null);
      return;
    }
    const ctl = new AbortController();
    const key = scopedCompileKey;
    const handle = window.setTimeout(async () => {
      try {
        const { data } = await compileVibeInputs(
          { business_id: businessId, version_id: baseVersionId },
          { input_ids: inputIds, vibe_scope_domains: scopeDomains },
          { signal: ctl.signal },
        );
        if (!ctl.signal.aborted) setScopedCompile({ key, baseVersionId, data });
      } catch (err) {
        // The launch recompiles on the server, which blocks an empty scoped
        // run itself, so a preview failure is shown but does not block submit.
        if (!ctl.signal.aborted) {
          setScopedCompile({
            key,
            baseVersionId,
            data: null,
            error: apiErrorMessage(err, "Could not compile the scoped preview"),
          });
        }
      }
    }, 300);
    return () => {
      window.clearTimeout(handle);
      ctl.abort();
    };
    // scopedCompileKey captures baseVersionId, inputIds and scopeDomains.
  }, [isScoped, businessId, scopedCompileKey]);
  const scopedCompileCurrent =
    scopedCompile != null && scopedCompile.key === scopedCompileKey ? scopedCompile : null;
  const scopedCompileFresh = scopedCompileCurrent?.data ?? null;
  const scopedCompileError = scopedCompileCurrent?.error ?? "";
  const scopedIncludedIds = scopedCompileFresh?.included_input_ids ?? [];
  const scopedExcluded = (scopedCompileFresh?.excluded_input_ids ?? []).map((id) => ({
    id,
    reason: scopedCompileFresh?.excluded_reasons?.[id] ?? "",
    input: baseInputs.find((vi) => vi.id === id),
  }));
  const scopedCompilePending = isScoped && inputIds.length > 0 && scopedCompileCurrent == null;
  const scopedNothingIncluded =
    isScoped && inputIds.length > 0 && scopedCompileFresh != null && scopedIncludedIds.length === 0;
  const scopeDomainsMissing = isScoped && scopeDomains.length === 0;
  const previewIncludedIds = isScoped ? new Set(scopedIncludedIds) : includedInputIds;

  // Banner and notes for a scope that came from the selected feedback.
  const fromFeedback = scopeFrom === "feedback";
  const showScopeBanner = fromFeedback && isScoped && !scopeEdited && scopePrefill.domains.length > 0;
  // Model-wide items are left out by any scope, so the last preview of this
  // base answers even while a new one is being compiled; the note does not
  // flicker on a scope edit. Another base is another input set, so its
  // preview is not reused.
  const modelWideCount = modelWideExcludedCount(
    scopedCompile?.baseVersionId === baseVersionId
      ? scopedCompile.data?.excluded_reasons
      : undefined,
  );
  const feedbackHintDomains =
    scopeHintWanted && baseDomainNames
      ? feedbackScopePrefill(
          feedbackScopeDomains(feedbackCompile?.input_scope_domains, inputIds),
          baseDomainNames,
        )
      : [];
  const applyFeedbackScope = () => {
    setScopeEdited(true);
    setVibeScope("some_domains");
    setScopeDomains(feedbackHintDomains);
  };

  // Eligible base versions per intent. The combined ECM+MVM run pipes its
  // input through the shrink step, which requires an ECM source. Vibe-iterate
  // accepts either scope (the user iterates the version they want).
  const eligibleBaseVersions = useMemo(() => {
    if (isVibeCombined) {
      return baseCandidates.filter((v) => v.scope === "ecm");
    }
    return baseCandidates;
  }, [baseCandidates, isVibeCombined]);
  const dropsOwnSchemas = runDropsOwnSchemas({
    isVibeIterate,
    isVibeCombined,
    dryRun: Boolean(vibeScopeFields.dry_run),
    scoped: isScoped,
  });
  const baseNotice = isVibe
    ? baseDeepLinkNotice({
        sourceVersion,
        sourceScope,
        versions,
        eligible: eligibleBaseVersions,
        selected: baseVersion,
        needsEcm: isVibeCombined,
      })
    : null;

  // Record the version a user explicitly picks under the current op so it
  // can be restored after an Operation Type round-trip (E-01).
  const handleBaseVersionChange = useCallback((id: string) => {
    setBaseVersionId(id);
    selectionByOpRef.current[runType] = id;
  }, [runType]);

  // Stash the current vibe selection under the outgoing op before switching,
  // so switching back can restore it (E-01).
  const handleRunTypeChange = useCallback((next: string) => {
    if (isVibe && baseVersionId) {
      selectionByOpRef.current[runType] = baseVersionId;
    }
    setRunType(next);
    setOperationPicked(true);
  }, [isVibe, baseVersionId, runType]);

  // Keep the base-version picker consistent with the chosen op:
  //  1. Restore the remembered selection for this op if it is eligible again
  //     (switching Operation Type back must not lose the prior selection —
  //     E-01). The selected Vibe Inputs come back with it because they are
  //     durable server-side, keyed by version.
  //  2. Otherwise, if the current selection is not eligible for this op
  //     (e.g. an MVM version while on the combined intent, which only accepts
  //     ECM), fall back to the first eligible version.
  useEffect(() => {
    if (!isVibe) return;
    const remembered = selectionByOpRef.current[runType];
    const rememberedValid =
      Boolean(remembered) && eligibleBaseVersions.some((v) => v.id === remembered);
    const currentValid = eligibleBaseVersions.some((v) => v.id === baseVersionId);
    if (rememberedValid && remembered !== baseVersionId) {
      setBaseVersionId(remembered);
    } else if (!currentValid) {
      setBaseVersionId(
        (eligibleBaseVersions.find((v) => !isSupersededBase(v)) ?? eligibleBaseVersions[0])?.id || "",
      );
    }
  }, [eligibleBaseVersions, baseVersionId, isVibe, runType]);

  // Submit blockers derived from form state. Centralised in
  // `lib/run-form.ts` so the disabled-banner copy and the actual `disabled`
  // prop can never disagree, and so a third gate can be added without
  // touching the form file.
  //
  // - `baseContextMissing`: new-base-model's agent fails fast in widget
  //   '02. Description' / '11. Model JSON File Path' when the business has
  //   nothing to describe. Mirror that here so the user gets immediate
  //   feedback instead of a failed run with no progress events.
  // - `vibeContentMissing`: vibe ops require something to vibe on. The selected
  //   Vibe Inputs (compiled server-side from `input_ids`) are the content; an
  //   empty selection is the blocker, surfaced as an empty-state CTA.
  const { baseContextMissing, vibeContentMissing } = deriveRunFormBlockers({
    isBase,
    isVibe,
    contextMode,
    businessContextText,
    businessContextPath,
    inputCount: inputIds.length,
  });

  // The Advanced Options the run sends, one body for validate and create so
  // a refusal shows in the form before launch. A New Base Model sends every
  // non-empty override and leaves the rest to the server defaults; a vibe
  // sends every pre-filled field it knows, blanks included
  // (`vibeConventionBody`). Vibe ECM + MVM sends the base's schema prefix as
  // its ECM prefix once the base's conventions are loaded.
  const schemaPrefixAs = isVibeIterate
    ? "schema_prefix"
    : isVibeCombined && runDefaults
      ? "ecm_schema_prefix"
      : null;
  const conventionFields: Record<string, string> = {
    ...Object.fromEntries(
      Object.entries(conventions).filter(
        ([k, v]) =>
          typeof v === "string"
          && v.trim().length > 0
          && !(isVibe && (PREFILL_FIELDS as readonly string[]).includes(k)),
      ),
    ),
    ...(isVibe ? vibeConventionBody(effective, schemaPrefixAs) : {}),
    org_divisions: orgDivisionsValue,
    // Seed domains shape a new model, so only the operations that build
    // one from the business (new base model, vibe ECM + MVM) send them.
    // A vibe iteration works on the base version's own domains.
    ...(domainTags.length > 0 && (isBase || isVibeCombined)
      ? { business_domains: joinCommaList(domainTags) }
      : {}),
  };
  const conventionFieldsKey = JSON.stringify(conventionFields);

  // Live validation state — debounced from form changes (spec §2.4 + §2.4.1).
  const [revalidateNonce, setRevalidateNonce] = useState(0);
  const [validateBlockers, setValidateBlockers] = useState<IssueOut[]>([]);
  const [validateWarnings, setValidateWarnings] = useState<IssueOut[]>([]);
  const validateAbortRef = useRef<AbortController | null>(null);

  // Live validation runs for every operation the form launches (all of them
  // produce a model). It surfaces two classes of pre-submit signal the user
  // must see BEFORE launching: config-missing blockers (the
  // agent/warehouse/metamodel-catalog isn't set up) and the run-target-
  // override divergence warning (the run's catalog differs from the
  // configured metamodel catalog).
  useEffect(() => {
    if (!businessId) {
      setValidateBlockers([]);
      setValidateWarnings([]);
      return;
    }
    const intent = runTypeToIntent(runType);
    if (!intent) return;
    // An invalid budget is never sent: create would 422 on it and Start Run
    // is disabled, so validating the body without it would check another
    // request than the one the user would launch.
    if (runtimeBudgetError) {
      validateAbortRef.current?.abort();
      return;
    }

    const ctl = new AbortController();
    validateAbortRef.current?.abort();
    validateAbortRef.current = ctl;

    const handle = window.setTimeout(async () => {
      const body: RunIn = {
        // Cast to satisfy the api.ts forward-ref type alias; backend
        // accepts the snake-case Intent enum value verbatim.
        intent: intent as RunIn["intent"],
        catalog,
        cataloging_style: conventions.cataloging_style,
        business_context_path: contextMode === "path" ? businessContextPath : "",
        business_context_text: contextMode === "text" ? businessContextText : "",
        ...conventionFields,
        // Vibe intents carry the parent version so the BE can validate it
        // (the combined intent additionally enforces "parent must be ECM
        // scope"). new-base-model has no parent.
        ...(isVibe && baseVersionId ? { version_id: baseVersionId } : {}),
        // Vibe intents MUST send the selected input ids so /validate can
        // compile `vibe_instructions` server-side. vibe-new-ecm-mvm builds
        // the full DAG and runs Gate B, which enforces the vibe_iterate
        // step's `vibe_instructions: min_length=1`; without the ids that
        // field compiles empty → a permanent blocker that disables Start Run
        // (E-10). Mirror the CREATE body so validate sees the same content.
        ...(isVibe ? { input_ids: inputIds, next_vibe_ids: [] } : {}),
        ...vibeScopeFields,
        ...runtimeBudgetFields,
      };
      try {
        const { data } = await validateRun(
          { business_id: businessId },
          body,
          { signal: ctl.signal },
        );
        if (!ctl.signal.aborted) {
          setValidateBlockers(data.blockers || []);
          setValidateWarnings(data.warnings || []);
        }
      } catch (err) {
        // Aborted (user kept typing) or network error — clear stale state
        // but don't surface the error inline; the hard submit will
        // re-validate and produce a real error if needed.
        if (!ctl.signal.aborted) {
          setValidateBlockers([]);
          setValidateWarnings([]);
        }
      }
    }, 300);
    return () => {
      window.clearTimeout(handle);
      ctl.abort();
    };
  }, [
    businessId,
    isVibe,
    isVibeCombined,
    runType,
    catalog,
    conventions.cataloging_style,
    // Every Advanced Option the create body carries.
    conventionFieldsKey,
    contextMode,
    businessContextPath,
    businessContextText,
    baseVersionId,
    // Re-validate when the compiled selection changes so Gate B's
    // vibe_instructions check re-runs with the current inputs (E-10).
    inputIds.join(","),
    // Re-validate on scope / run-type changes so the scope blockers update.
    vibeScopeFields.vibe_scope,
    (vibeScopeFields.vibe_scope_domains ?? []).join(","),
    vibeScopeFields.dry_run,
    runtimeBudgetFields.runtime_budget_hours,
    runtimeBudgetError,
    // Re-validate after something outside the form changed (deleting the
    // versions a blocker named).
    revalidateNonce,
  ]);

  // Form submit only validates + opens the confirmation dialog. The actual
  // createRun call happens in `performRun` once the user confirms. This
  // makes the dialog a hard gate: an accidental Enter press (e.g. an empty
  // draft in a TagInput) can at worst surface a confirm prompt, never kick
  // off a real run.
  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (submitting || confirmOpen) return;
    if (isVibe && selectionSaving) {
      setError(SELECTION_SAVING_MESSAGE);
      return;
    }
    if (runDefaultsLoading) {
      setError(`${LOADING_NOTE}. Try again in a moment.`);
      return;
    }
    // Vibe runs dispatch the inputs selected on the compose surface. Block when
    // the selection is empty; the empty-state CTA points back to Compose.
    if (isVibe && inputIds.length === 0) {
      setError(
        "No inputs selected — choose inputs on the Compose surface to include in this run."
      );
      return;
    }
    if (isVibe && !baseVersionId) {
      setError("Select a base version to apply vibes to");
      return;
    }
    if (scopeDomainsMissing) {
      setError("Pick at least one domain to scope this run to.");
      return;
    }
    if (scopedCompilePending || scopedNothingIncluded) {
      setError(
        scopedNothingIncluded
          ? "None of the selected inputs are anchored in the chosen domains. Select feedback on those domains, or widen the scope."
          : "The scoped preview is still compiling. Try again in a moment.",
      );
      return;
    }
    setError("");
    setConfirmOpen(true);
  };

  const performRun = async () => {
    setSubmitting(true);
    setError("");
    try {
      await createRun(
        { business_id: businessId },
        {
        // Phase 5 (orchestrator refactor §8): the wire only carries
        // the canonical Intent slug now; ``run_type`` was retired.
        intent: runTypeToIntent(runType) as RunIn["intent"],
        catalog,
        version_id: isVibe ? baseVersionId : undefined,
        business_context_path:
          (isBase || isVibeCombined) && contextMode === "path" ? businessContextPath : "",
        business_context_text:
          (isBase || isVibeCombined) && contextMode === "text" ? businessContextText : "",
        // New-base-model and vibe-new-ecm-mvm are both ECM → shrink-to-MVM
        // pipelines (PR #86 + the combined-intent factory). Phase 1 must
        // always run as ECM ("large model") for the shrink step to find
        // its source; the user has no choice for either intent, so we
        // hardcode and ignore any leftover Model Size form state.
        model_size: (isBase || isVibeCombined) ? "large model" : modelSize,
        // The base path keeps a per-run "Run Instructions" editor; the vibe
        // path retired its free-text editor (Vibe Inputs are the content,
        // compiled server-side from input_ids). Send the editor text only
        // where the editor still exists.
        vibe_instructions: isBase ? vibeInstructions : "",
        next_vibe_ids: [],
        // Vibe Inputs selected on the compose surface — the durable selection.
        // Server re-compiles authoritatively from these ids.
        input_ids: isVibe ? inputIds : [],
        // Vibe iteration only: scope, scope domains and Dry Run (§9.1).
        ...vibeScopeFields,
        ...runtimeBudgetFields,
        // Convention overrides — sent independently of the Advanced
        // Options disclosure being currently open (gating on `advancedOpen`
        // once dropped typed `business_domains`). Same fields as validate.
        ...conventionFields,
        },
      );
      setConfirmOpen(false);
      navigate({
        to: "/businesses/$businessId/runs",
        params: { businessId },
      });
    } catch (err) {
      // A hard-submit 422 config_missing renders via the ONE shared renderer
      // (rich toast + Settings deep-links); other failures stay inline.
      if (!notifyConfigMissing(err)) {
        setError(apiErrorMessage(err, "Failed to start run"));
      }
      setSubmitting(false);
      setConfirmOpen(false);
    }
  };

  return (
    <div className={isVibe ? "grid grid-cols-[1fr_380px] gap-4" : ""}>
    <Card>
      <CardHeader>
        <CardTitle>Run Configuration</CardTitle>
      </CardHeader>
      <CardContent>
        <form onSubmit={handleSubmit} className="space-y-5">
          {removedOperation && (
            <RemovedOperationNotice
              kind={removedOperation}
              businessId={businessId}
              versions={removedOperationVersions}
            />
          )}

          {/* Shared: Operation Type + Namespace Style + Deployment Catalog.
              Namespace style is now in the main form (not Advanced) because
              picking "Catalog per Division" / "Catalog per Domain" changes
              whether "Deployment catalog" is even meaningful — the agent
              derives per-division/per-domain catalog names from the prefix
              and suffix in those modes. */}
          <div className="grid grid-cols-3 gap-4">
            <div className="space-y-2">
              <label className="text-sm font-medium">Operation Type</label>
              <Select value={runType} onValueChange={handleRunTypeChange}>
                <SelectTrigger
                  aria-label="Operation Type"
                  aria-describedby={hasVersions ? "new-base-model-disabled-hint" : undefined}
                >
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="new base model" disabled={hasVersions}>New Base Model</SelectItem>
                  {/* The remaining operations all require an existing model
                      version. Hide them entirely when the business has none
                      instead of letting the user pick a dead-end option. */}
                  {baseCandidates.length > 0 && (
                    <>
                      <SelectItem value="vibe modeling of version">Vibe Modeling</SelectItem>
                      <SelectItem value="vibe new ecm + mvm">Vibe ECM + MVM</SelectItem>
                    </>
                  )}
                </SelectContent>
              </Select>
              {hasVersions && (
                <p id="new-base-model-disabled-hint" className="text-[10px] text-muted-foreground">
                  New Base Model needs a business with no model versions. Delete its versions one by one from their pages (uninstall installed ones first), or create a new business.
                </p>
              )}
            </div>

            <div className="space-y-2">
              <label className="text-sm font-medium">Namespace Style</label>
              <Select
                value={conventions.cataloging_style}
                onValueChange={(v) => updateConvention("cataloging_style", v)}
              >
                <SelectTrigger>
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  {CATALOGING_STYLES.map((s) => (
                    <SelectItem key={s} value={s}>{s}</SelectItem>
                  ))}
                </SelectContent>
              </Select>
              <p className="text-[10px] text-muted-foreground">
                {isSingleCatalog
                  ? "All generated tables land in the single catalog below."
                  : "Targets are derived per division/domain via the catalog and schema prefix/suffix in Advanced options."}
              </p>
            </div>

            <div className="space-y-2">
              {/* Label flips to "Metamodel Catalog" in multi-catalog modes
                  because the agent uses this value as the metamodel root
                  (where _metamodel.* tables + the vol_root volume live);
                  per-domain / per-division deploy catalogs are derived
                  from Catalog Prefix/Suffix in Advanced Options. The
                  field is NOT ignored in those modes — it's used. */}
              <label className="text-sm font-medium">
                {isSingleCatalog ? "Deployment Catalog" : "Metamodel Catalog"}
              </label>
              <DeploymentCatalogPicker
                value={catalog}
                onChange={setCatalog}
                createsSchemas={runCreatesSchemas(
                  runTypeToIntent(runType),
                  Boolean(vibeScopeFields.dry_run),
                  conventions.cataloging_style,
                )}
              />
              {!isSingleCatalog && (
                <p className="text-[10px] text-muted-foreground">
                  Used as the metamodel root only. Per-domain deploy catalogs
                  derive from Catalog Prefix/Suffix in Advanced Options.
                </p>
              )}
            </div>
          </div>

          {/* ─── New Base Model fields ─── */}
          {isBase && (
            <>
              <div className="space-y-2">
                <div className="flex items-center gap-3">
                  <label className="text-sm font-medium">Business Context</label>
                  <div className="flex gap-1">
                    <button
                      type="button"
                      onClick={() => setContextMode("text")}
                      className={`px-3 py-0.5 text-xs rounded-md transition-colors ${contextMode === "text" ? "bg-primary text-primary-foreground" : "bg-muted text-muted-foreground hover:bg-muted/80"}`}
                    >
                      Write
                    </button>
                    <button
                      type="button"
                      onClick={() => setContextMode("path")}
                      className={`px-3 py-0.5 text-xs rounded-md transition-colors ${contextMode === "path" ? "bg-primary text-primary-foreground" : "bg-muted text-muted-foreground hover:bg-muted/80"}`}
                    >
                      File Path
                    </button>
                  </div>
                </div>
                {contextMode === "path" ? (
                  <>
                    <div className="flex gap-2">
                      <Input
                        value={businessContextPath}
                        onChange={(e) => setBusinessContextPath(e.target.value)}
                        placeholder="e.g. /Volumes/catalog/schema/vibes/business_context.json"
                      />
                      <Button
                        type="button"
                        variant="outline"
                        onClick={() => setVolumePickerOpen(true)}
                        className="shrink-0"
                        data-testid="business-context-browse"
                      >
                        <FolderOpen className="h-4 w-4 mr-1.5" />
                        Browse
                      </Button>
                    </div>
                    <p className="text-xs text-muted-foreground">
                      Volume path to a business context JSON file — type it or
                      Browse Unity Catalog volumes.
                      Leave empty to reuse context from the last run.
                    </p>
                    <VolumePicker
                      open={volumePickerOpen}
                      onOpenChange={setVolumePickerOpen}
                      onSelect={setBusinessContextPath}
                    />
                  </>
                ) : (
                  <>
                    <MarkdownEditor
                      value={businessContextText}
                      onChange={(v) => {
                        setBusinessContextText(v);
                        setBusinessContextDirty(true);
                      }}
                      placeholder={"Describe your business here. The AI will use this to generate domains, products, and attributes.\n\nFor example:\n- What does the business do?\n- What industry is it in?\n- What are the core business processes?\n- What data domains matter most?"}
                      rows={8}
                    />
                    <p className="text-xs text-muted-foreground">
                      Describe your business in plain text or markdown. The AI generates domains, products, and attributes from this description.
                    </p>
                  </>
                )}
              </div>

              <div className="space-y-2">
                <label className="text-sm font-medium">
                  Run Instructions{" "}
                  <span className="font-normal text-muted-foreground">(optional)</span>
                </label>
                <MarkdownEditor
                  value={vibeInstructions}
                  onChange={(v) => {
                    setVibeInstructions(v);
                    setVibeInstructionsDirty(true);
                  }}
                  placeholder="Per-run constraints, scope tweaks, or guidance the agent reads after the business description. Leave empty for default behaviour."
                  rows={4}
                />
                <p className="text-xs text-muted-foreground">
                  Per-run instructions the agent reads AFTER the business description (constraints, scope tweaks, etc.).
                  Hard constraints belong here, not in the business description — the description is durable and reusable;
                  these instructions are submission-specific.
                </p>
              </div>

              <div className="rounded-md border border-input bg-muted/30 px-3 py-2 text-xs text-muted-foreground">
                A new base model run generates a complete <strong>ECM</strong>{" "}
                (Expanded Coverage Model) and then automatically{" "}
                <strong>shrinks it to an MVM</strong> (Minimum Viable Model).
                Both versions land in the deployment catalog and appear in the
                explorer when the run completes. With One Catalog only the MVM
                stays installed.
              </div>
            </>
          )}

          {/* ─── Vibe Modeling fields ─── */}
          {isVibe && (
            <>
              <div className="space-y-2">
                <label htmlFor="run-base-version" className="text-sm font-medium">Base Version</label>
                {eligibleBaseVersions.length > 0 ? (
                  <Select value={baseVersionId} onValueChange={handleBaseVersionChange}>
                    <SelectTrigger id="run-base-version">
                      <SelectValue placeholder="Select a version to apply vibes to" />
                    </SelectTrigger>
                    <SelectContent>
                      {eligibleBaseVersions.map((v) => (
                        <SelectItem key={v.id} value={v.id}>
                          {baseVersionLabel(v, versions, isBaseById.get(v.id))}
                        </SelectItem>
                      ))}
                    </SelectContent>
                  </Select>
                ) : (
                  <p className="text-sm text-muted-foreground py-2">
                    {isVibeCombined
                      ? "No completed ECM versions available. The combined ECM+MVM run pipes through shrink, which needs an ECM source. Run a new base model first."
                      : "No completed versions available. Create a new base model first."}
                  </p>
                )}
                <p className="text-xs text-muted-foreground">
                  {isVibeCombined
                    ? "Pick the ECM version to vibe. The run regenerates ECM and shrinks to MVM."
                    : "The existing model structure and business context will be loaded from this version."}
                </p>
              </div>

              {baseNotice && (
                <p
                  role="note"
                  data-testid="base-deep-link-notice"
                  className="rounded-md border border-amber-500/40 bg-amber-500/5 px-3 py-2 text-xs text-amber-700 dark:text-amber-300"
                >
                  {baseNotice}
                </p>
              )}

              {baseVersionId && (
                <div className="flex items-center justify-between rounded-md border border-border bg-muted/40 px-3 py-2 text-sm">
                  <span className="text-muted-foreground" data-testid="vibe-inputs-summary">
                    {inputIds.length} vibe input{inputIds.length === 1 ? "" : "s"} selected for this run
                    {scopedCompileFresh && ` · ${scopedIncludedIds.length} in scope`}
                  </span>
                  <Button asChild variant="outline" size="sm">
                    <Link
                      to="/businesses/$businessId/model/$version/$scope/inputs"
                      params={{
                        businessId,
                        version: String(
                          (versions.find((v) => v.id === baseVersionId) as any)?.version ?? "",
                        ),
                        scope:
                          ((versions.find((v) => v.id === baseVersionId) as any)?.scope || "ecm"),
                      }}
                    >
                      Edit inputs
                      <ArrowRight className="h-4 w-4 ml-1.5" />
                    </Link>
                  </Button>
                </div>
              )}

              {showScopeBanner && (
                <ScopePrefillBanner itemCount={inputIds.length} domains={scopePrefill.domains} />
              )}

              {isVibeIterate && (
                <VibeScopeControl
                  scope={vibeScope}
                  onScopeChange={handleScopeChange}
                  domainNames={baseDomainNames}
                  selectedDomains={matchedScopeDomains}
                  onToggleDomain={handleToggleScopeDomain}
                  unknownDomains={unknownScopeDomains}
                  unknownMessages={Object.fromEntries(
                    unknownScopeDomains.flatMap((name) => {
                      const b = validateBlockers.find(
                        (vb) => vb.field_path === "vibe_scope_domains" && vb.message.includes(`'${name}'`),
                      );
                      return b ? [[name, b.message]] : [];
                    }),
                  )}
                  onRemoveUnknown={handleRemoveUnknownScopeDomain}
                  runMode={agentRunMode}
                  onRunModeChange={setAgentRunModeChoice}
                  catalog={catalog}
                  fullRunOnly={Boolean(oldAgentVersion)}
                  fullRunOnlyNoteId="old-agent-full-run-note"
                />
              )}

              {isVibeIterate && (
                <ScopePrefillNotes
                  latestNote={
                    fromFeedback && scopePrefill.blocked && behindHead
                      ? scopedNeedsLatestNote(`v${behindHead.version}`)
                      : undefined
                  }
                  modelWideNote={
                    fromFeedback && isScoped && modelWideCount > 0
                      ? modelWideScopeNote(modelWideCount)
                      : undefined
                  }
                  hint={
                    feedbackHintDomains.length > 0
                      ? {
                          label: `Scope to ${joinCommaList(feedbackHintDomains)}`,
                          onApply: applyFeedbackScope,
                        }
                      : undefined
                  }
                />
              )}

              {oldAgentVersion && (
                <p
                  id="old-agent-full-run-note"
                  data-testid="old-agent-full-run-note"
                  className="rounded-md border border-warning/40 bg-warning/10 px-3 py-2 text-xs text-warning"
                >
                  <span className="font-medium">Full Run only.</span> The configured agent is{" "}
                  {oldAgentVersion}. Dry Run and Some domains need agent {MIN_AGENT_MARKER_FOR_SCOPE} or
                  later. Switch to the bundled agent in{" "}
                  <Link to="/settings" search={{ tab: "agent" }} className="underline underline-offset-2">
                    Settings
                  </Link>
                  .
                </p>
              )}

              {/* Model Size is shown read-only for a vibe iteration (it keeps
                  the base's size) and hidden for vibe-new-ecm-mvm, which
                  always starts as ECM and shrinks to MVM, like new-base-model. */}
              {isVibeIterate && (
                <div className="space-y-2">
                  <label htmlFor="run-model-size" className="text-sm font-medium">Model Size</label>
                  <Select value={modelSize} disabled>
                    <SelectTrigger id="run-model-size" aria-describedby="run-model-size-locked">
                      <SelectValue />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectItem value="small model">Small Model (MVM)</SelectItem>
                      <SelectItem value="large model">Large Model (ECM)</SelectItem>
                    </SelectContent>
                  </Select>
                  <p
                    id="run-model-size-locked"
                    data-testid="model-size-locked"
                    className="text-xs text-muted-foreground"
                  >
                    A vibe run keeps the base version's size.
                  </p>
                </div>
              )}
            </>
          )}

          {/* Advanced Options */}
          <div className="border rounded-lg">
            <div className="flex items-center gap-2 pr-4">
              <button
                type="button"
                onClick={() => setAdvancedOpen((v) => !v)}
                className="flex flex-1 items-center gap-2 px-4 py-2.5 text-sm font-medium text-left hover:bg-muted/50 transition-colors rounded-lg"
              >
                {advancedOpen ? <ChevronDown className="h-4 w-4" /> : <ChevronRight className="h-4 w-4" />}
                Advanced Options
                <span className="text-xs text-muted-foreground font-normal ml-1">
                  Naming, data types, cataloging, tracking
                </span>
              </button>
              <HelpLink topic="run-parameters">Run parameters</HelpLink>
            </div>

            {advancedOpen && (
              <div className="px-4 pb-4 space-y-5">
                {isVibe && (runDefaults || runDefaultsFailed) && (
                  <div className="space-y-1" data-testid="run-defaults-notes">
                    {runDefaults && baseVersion && (
                      <p className="text-xs text-muted-foreground" data-testid="run-defaults-source">
                        {runDefaults.file_read
                          ? `Pre-filled from v${baseVersion.version} ${(baseVersion.scope || "mvm").toUpperCase()}.`
                          : `The options other than the conventions are pre-filled from the run that made v${baseVersion.version} ${(baseVersion.scope || "mvm").toUpperCase()}.`}
                      </p>
                    )}
                    {runDefaults && !runDefaults.file_read && (
                      <p role="note" data-testid="run-defaults-unread" className="text-xs text-foreground">
                        {UNREAD_NOTE}
                      </p>
                    )}
                    {runDefaultsFailed && (
                      <p role="note" data-testid="run-defaults-failed" className="text-xs text-foreground">
                        {LOAD_FAILED_NOTE}
                      </p>
                    )}
                    {anyLocked && (
                      <p id={LOCKED_NOTE_ID} data-testid="run-conventions-locked-note" className="text-xs text-muted-foreground">
                        {LOCKED_NOTE}
                      </p>
                    )}
                  </div>
                )}
                {runtimeBudgetHours !== null && budgetMin !== undefined && budgetMax !== undefined && (
                  <fieldset className="space-y-3">
                    <legend className="text-xs font-semibold text-muted-foreground uppercase tracking-wider">Agent</legend>
                    <div className="grid grid-cols-2 gap-3">
                      <div className="space-y-1">
                        <label htmlFor="run-runtime-budget-hours" className="text-xs font-medium">
                          Run time budget (hours)
                        </label>
                        <Input
                          id="run-runtime-budget-hours"
                          type="number"
                          min={budgetMin}
                          max={budgetMax}
                          step={1}
                          className="h-8 text-sm"
                          aria-invalid={runtimeBudgetError !== null}
                          aria-describedby={
                            runtimeBudgetError
                              ? "run-runtime-budget-error run-runtime-budget-hint"
                              : "run-runtime-budget-hint"
                          }
                          value={Number.isNaN(runtimeBudgetHours) ? "" : runtimeBudgetHours}
                          onChange={(e) => setRuntimeBudgetChoice(parseRuntimeBudgetInput(e.target.value))}
                        />
                        {runtimeBudgetError && (
                          <p id="run-runtime-budget-error" data-testid="runtime-budget-error" className="text-[10px] text-destructive">
                            {runtimeBudgetError}
                          </p>
                        )}
                        <p id="run-runtime-budget-hint" data-testid="runtime-budget-hint" className="text-[10px] text-muted-foreground">
                          Default from Settings ({budgetDefault} hours). Raise it for large models.{" "}
                          {runtimeBudgetBoundsText(budgetMin, budgetMax)}
                        </p>
                      </div>
                    </div>
                  </fieldset>
                )}
                {/* Organization */}
                <fieldset className="space-y-3">
                  <legend className="text-xs font-semibold text-muted-foreground uppercase tracking-wider">Organization</legend>
                  <div className="grid grid-cols-2 gap-3">
                    <div className="space-y-1">
                      <label
                        htmlFor="run-org-divisions"
                        className="text-xs font-medium flex items-center gap-1"
                        title={
                          "Which organisational divisions the agent should cover. " +
                          "Pending confirmation with the agent maintainers whether " +
                          "divisions apply to `Minimum Viable Model - MVM` scope — " +
                          "treat this as informational on small models for now."
                        }
                      >
                        Organization Divisions
                        <span className="text-muted-foreground">(?)</span>
                      </label>
                      <Select
                        value={orgDivisionsValue}
                        onValueChange={(v) => {
                          updateConvention("org_divisions", v);
                          setOrgDivisionsManual(true);
                        }}
                      >
                        <SelectTrigger
                          id="run-org-divisions"
                          className="h-8 text-sm"
                          title={orgFromBase && !orgDivisionsManual ? "From the run that made the base model" : undefined}
                        >
                          <SelectValue />
                        </SelectTrigger>
                        <SelectContent>
                          {ORG_DIVISIONS_PRESETS.map((d) => (
                            <SelectItem key={d} value={d}>{d}</SelectItem>
                          ))}
                        </SelectContent>
                      </Select>
                      {orgDivisionsAuto && (
                        <p data-testid="org-divisions-auto" className="text-[10px] text-muted-foreground">
                          Auto-set from model size
                        </p>
                      )}
                    </div>
                    {/* Only the operations that send seed domains show them. */}
                    {(isBase || isVibeCombined) && (
                      <div className="space-y-1">
                        <label className="text-xs font-medium">Business Domains</label>
                        <TagInput
                          value={domainTags}
                          onChange={setDomainTags}
                          placeholder="Type a domain, press Enter"
                        />
                        <p className="text-[10px] text-muted-foreground">
                          Comma-separated. Filtered by selected divisions at generation time.
                        </p>
                      </div>
                    )}
                  </div>
                </fieldset>

                {/* Namespace Style — catalog + schema prefix/suffix in one
                    place. The top-level Namespace Style selector above is
                    the authoritative control; these prefixes/suffixes only
                    apply for multi-catalog styles. */}
                <fieldset className="space-y-3">
                  <legend className="text-xs font-semibold text-muted-foreground uppercase tracking-wider">Namespace Style</legend>
                  <div className="grid grid-cols-2 gap-3">
                    <div className="space-y-1">
                      <label className="text-xs font-medium">Catalog Prefix</label>
                      <Input
                        value={shown("catalog_prefix")}
                        onChange={(e) => updateConvention("catalog_prefix", e.target.value)}
                        {...lockProps(effective.catalog_prefix)}
                        disabled={isSingleCatalog}
                      />
                    </div>
                    <div className="space-y-1">
                      <label className="text-xs font-medium">Catalog Suffix</label>
                      <Input
                        value={shown("catalog_suffix")}
                        onChange={(e) => updateConvention("catalog_suffix", e.target.value)}
                        {...lockProps(effective.catalog_suffix)}
                        disabled={isSingleCatalog}
                      />
                    </div>
                    {/* Schema Prefix — for `new base model` the unified
                        pipeline needs per-scope prefixes so the ECM and
                        MVM installs don't collide in a shared catalog
                        (#122). The vibe operations use the single
                        `schema_prefix` field below. */}
                    {isBase ? (
                      <>
                        <div className="space-y-1">
                          <label className="text-xs font-medium">ECM Schema Prefix</label>
                          <Input
                            value={isSingleCatalog ? conventions.ecm_schema_prefix : ""}
                            onChange={(e) => updateConvention("ecm_schema_prefix", e.target.value)}
                            disabled={!isSingleCatalog}
                            placeholder={isSingleCatalog ? "ecm_" : "(per-scope catalog — no prefix)"}
                            className="h-8 text-sm"
                          />
                        </div>
                        <div className="space-y-1">
                          <label className="text-xs font-medium">MVM Schema Prefix</label>
                          <Input
                            value={isSingleCatalog ? conventions.mvm_schema_prefix : ""}
                            onChange={(e) => updateConvention("mvm_schema_prefix", e.target.value)}
                            disabled={!isSingleCatalog}
                            placeholder={isSingleCatalog ? "mvm_" : "(per-scope catalog — no prefix)"}
                            className="h-8 text-sm"
                          />
                        </div>
                      </>
                    ) : (
                      <div className="space-y-1">
                        <label htmlFor="run-schema-prefix" className="text-xs font-medium">Schema Prefix</label>
                        <Input
                          id="run-schema-prefix"
                          value={shown("schema_prefix")}
                          onChange={(e) => updateConvention("schema_prefix", e.target.value)}
                          placeholder={lockedPlaceholder(effective.schema_prefix)}
                          {...lockProps(effective.schema_prefix)}
                        />
                        <BaseUnsetNote field={effective.schema_prefix} />
                      </div>
                    )}
                    <div className="space-y-1">
                      <label htmlFor="run-schema-suffix" className="text-xs font-medium">Schema Suffix</label>
                      <Input
                        id="run-schema-suffix"
                        value={shown("schema_suffix")}
                        onChange={(e) => updateConvention("schema_suffix", e.target.value)}
                        {...lockProps(effective.schema_suffix)}
                      />
                    </div>
                  </div>
                  {isSingleCatalog ? (
                    isBase && (
                      <p className="text-[10px] text-muted-foreground">
                        ECM and MVM land in the same catalog on One Catalog, so each scope gets a distinct schema prefix to avoid collisions. Catalog prefix/suffix only apply for "Catalog per Division" / "Catalog per Domain".
                      </p>
                    )
                  ) : (
                    isBase && (
                      <p className="text-[10px] text-muted-foreground">
                        Schema prefixes are disabled: each scope targets its own catalog (`&lt;base&gt;_ecm_v&lt;N&gt;` / `&lt;base&gt;_mvm_v&lt;N&gt;`), so prefixing is unnecessary.
                      </p>
                    )
                  )}
                  {isSingleCatalog && !isBase && (
                    <p className="text-[10px] text-muted-foreground">
                      Catalog prefix/suffix only apply when Namespace Style is
                      "Catalog per Division" or "Catalog per Domain". Change it above to edit those.
                    </p>
                  )}
                </fieldset>

                {/* Naming & Format — identifier conventions, excluding the
                    catalog/schema prefix/suffix which belong to Namespace Style. */}
                <fieldset className="space-y-3">
                  <legend className="text-xs font-semibold text-muted-foreground uppercase tracking-wider">Naming &amp; Format</legend>
                  <div className="grid grid-cols-3 gap-3">
                    <div className="space-y-1">
                      <label htmlFor="run-naming-convention" className="text-xs font-medium">Naming Convention</label>
                      <ConventionSelect
                        id="run-naming-convention"
                        value={shown("naming_convention")}
                        options={NAMING_CONVENTIONS}
                        onChange={(v) => updateConvention("naming_convention", v)}
                        field={effective.naming_convention}
                        placeholder={lockedPlaceholder(effective.naming_convention)}
                      />
                      <BaseUnsetNote field={effective.naming_convention} />
                    </div>
                    <div className="space-y-1">
                      <label htmlFor="run-primary-key-suffix" className="text-xs font-medium">PK Suffix</label>
                      <Input
                        id="run-primary-key-suffix"
                        value={shown("primary_key_suffix")}
                        onChange={(e) => updateConvention("primary_key_suffix", e.target.value)}
                        placeholder={lockedPlaceholder(effective.primary_key_suffix)}
                        {...lockProps(effective.primary_key_suffix)}
                      />
                      <BaseUnsetNote field={effective.primary_key_suffix} />
                    </div>
                    <div className="space-y-1">
                      <label htmlFor="run-tag-prefix" className="text-xs font-medium">Tag Prefix</label>
                      <Input
                        id="run-tag-prefix"
                        value={shown("tag_prefix")}
                        onChange={(e) => updateConvention("tag_prefix", e.target.value)}
                        placeholder={lockedPlaceholder(effective.tag_prefix)}
                        {...lockProps(effective.tag_prefix)}
                      />
                      <BaseUnsetNote field={effective.tag_prefix} />
                    </div>
                    <div className="space-y-1">
                      <label htmlFor="run-tag-suffix" className="text-xs font-medium">Tag Suffix</label>
                      <Input
                        id="run-tag-suffix"
                        value={shown("tag_suffix")}
                        onChange={(e) => updateConvention("tag_suffix", e.target.value)}
                        {...lockProps(effective.tag_suffix)}
                      />
                    </div>
                  </div>
                </fieldset>

                {/* Data Types */}
                <fieldset className="space-y-3">
                  <legend className="text-xs font-semibold text-muted-foreground uppercase tracking-wider">Data Types</legend>
                  <div className="grid grid-cols-2 gap-3">
                    <div className="space-y-1">
                      <label htmlFor="run-table-id-type" className="text-xs font-medium">Table ID Type</label>
                      <ConventionSelect
                        id="run-table-id-type"
                        value={shown("table_id_type")}
                        options={TABLE_ID_TYPES}
                        onChange={(v) => updateConvention("table_id_type", v)}
                        field={effective.table_id_type}
                        placeholder={lockedPlaceholder(effective.table_id_type)}
                      />
                      <BaseUnsetNote field={effective.table_id_type} />
                    </div>
                    <div className="space-y-1">
                      <label htmlFor="run-boolean-format" className="text-xs font-medium">Boolean Format</label>
                      <ConventionSelect
                        id="run-boolean-format"
                        value={shown("boolean_format")}
                        options={BOOLEAN_FORMATS}
                        onChange={(v) => updateConvention("boolean_format", v)}
                        field={effective.boolean_format}
                        placeholder={lockedPlaceholder(effective.boolean_format)}
                      />
                      <BaseUnsetNote field={effective.boolean_format} />
                    </div>
                    <div className="space-y-1">
                      <label htmlFor="run-date-format" className="text-xs font-medium">Date Format</label>
                      <ConventionSelect
                        id="run-date-format"
                        value={shown("date_format")}
                        options={DATE_FORMATS}
                        onChange={(v) => updateConvention("date_format", v)}
                        field={effective.date_format}
                        placeholder={lockedPlaceholder(effective.date_format)}
                      />
                      <BaseUnsetNote field={effective.date_format} />
                    </div>
                    <div className="space-y-1">
                      <label htmlFor="run-timestamp-format" className="text-xs font-medium">Timestamp Format</label>
                      <ConventionSelect
                        id="run-timestamp-format"
                        value={shown("timestamp_format")}
                        options={TIMESTAMP_FORMATS}
                        onChange={(v) => updateConvention("timestamp_format", v)}
                        field={effective.timestamp_format}
                        placeholder={lockedPlaceholder(effective.timestamp_format)}
                      />
                      <BaseUnsetNote field={effective.timestamp_format} />
                    </div>
                  </div>
                </fieldset>

                {/* Tracking & Governance */}
                <fieldset className="space-y-3">
                  <legend
                    className="text-xs font-semibold text-muted-foreground uppercase tracking-wider flex items-center gap-1 cursor-help"
                    title={`Housekeeping Columns: ${HOUSEKEEPING_COLUMNS_HINT} History Tracking: ${HISTORY_TRACKING_HINT}`}
                  >
                    Tracking &amp; Governance <span className="text-muted-foreground normal-case">(?)</span>
                  </legend>
                  <div className="grid grid-cols-3 gap-3">
                    <div className="space-y-1">
                      <label
                        htmlFor="run-housekeeping-columns"
                        className="text-xs font-medium cursor-help"
                        title={HOUSEKEEPING_COLUMNS_HINT}
                      >
                        Housekeeping Columns
                      </label>
                      <ConventionSelect
                        id="run-housekeeping-columns"
                        value={shown("housekeeping_columns")}
                        options={NO_YES}
                        onChange={(v) => updateConvention("housekeeping_columns", v)}
                        field={effective.housekeeping_columns}
                      />
                    </div>
                    <div className="space-y-1">
                      <label
                        htmlFor="run-history-tracking-columns"
                        className="text-xs font-medium cursor-help"
                        title={HISTORY_TRACKING_HINT}
                      >
                        History Tracking
                      </label>
                      <ConventionSelect
                        id="run-history-tracking-columns"
                        value={shown("history_tracking_columns")}
                        options={NO_YES}
                        onChange={(v) => updateConvention("history_tracking_columns", v)}
                        field={effective.history_tracking_columns}
                      />
                    </div>
                    <div className="space-y-1">
                      <label
                        className="text-xs font-medium cursor-help"
                        title={
                          "key=label pairs. The agent labels attributes with these sensitivity " +
                          "levels, and they become Unity Catalog tags when the version is installed. " +
                          "Format: key1=label1, key2=label2. Any key is accepted."
                        }
                      >
                        Classification Levels
                      </label>
                      <div
                        data-testid="run-classification-levels"
                        title={sourceLabel(effective.classification_levels) || undefined}
                        aria-describedby={effective.classification_levels.locked ? LOCKED_NOTE_ID : undefined}
                      >
                        <TagInput
                          value={splitCommaList(shown("classification_levels"))}
                          onChange={(tags) => updateConvention("classification_levels", joinCommaList(tags))}
                          placeholder={lockedPlaceholder(effective.classification_levels) ?? "e.g. public=public, press Enter"}
                          disabled={effective.classification_levels.locked}
                          className={effective.classification_levels.locked ? "opacity-100 bg-muted" : undefined}
                        />
                      </div>
                      <BaseUnsetNote field={effective.classification_levels} />
                      <p className="text-[10px] text-muted-foreground">
                        Key=value pairs (e.g. restricted=restricted)
                      </p>
                    </div>
                  </div>
                </fieldset>
              </div>
            )}
          </div>

          {error && (
            <p className="text-sm text-destructive">{error}</p>
          )}

          {/* Live validate-debounce surface (orchestrator wirer §2.4.1) —
              exercised for new-base-model and vibe-new-ecm-mvm. The
              combined intent surfaces "parent must be ECM scope" here. */}
          {validateBlockers.length > 0 && (
            <div
              data-testid="validate-blockers"
              className="rounded-md border border-destructive/50 bg-destructive/5 p-3 space-y-1"
            >
              <p className="text-sm font-medium text-destructive">
                Fix the following before submitting:
              </p>
              <ul className="text-xs text-destructive list-disc pl-5">
                {validateBlockers.map((b, i) => (
                  <li key={`${b.field_path}-${i}`}>
                    <span className="font-mono">{b.field_path || "form"}</span>: {b.message}
                    {b.field_path === "vibe_scope_base" && (
                      <DeleteBlockedVersionsAction
                        businessId={businessId}
                        businessName={business.name}
                        businessKind={business.kind}
                        named={b.versions ?? []}
                        versions={versions}
                        scope={baseVersion?.scope}
                        onDeleted={() => setRevalidateNonce((n) => n + 1)}
                      />
                    )}
                  </li>
                ))}
              </ul>
            </div>
          )}
          {validateWarnings.some((w) => w.severity !== "prepare") && (
            <div
              data-testid="validate-warnings"
              className="rounded-md border border-amber-500/40 bg-amber-500/5 p-3 space-y-1"
            >
              <p className="text-sm font-medium text-amber-700 dark:text-amber-300">
                Warnings (you can still submit):
              </p>
              <ul className="text-xs text-amber-700 dark:text-amber-300 list-disc pl-5">
                {validateWarnings
                  .filter((w) => w.severity !== "prepare")
                  .map((w, i) => (
                    <li key={`${w.field_path}-${i}`}>
                      <span className="font-mono">{w.field_path || "form"}</span>: {w.message}
                    </li>
                  ))}
              </ul>
            </div>
          )}
          {/* ``prepare`` issues: what the run sets up itself when it starts. */}
          {validateWarnings.some((w) => w.severity === "prepare") && (
            <div
              data-testid="validate-prepares"
              role="note"
              className="rounded-md border border-border bg-muted p-3 space-y-1"
            >
              <p className="text-sm font-medium text-foreground">
                Before the run starts:
              </p>
              <ul className="text-xs text-foreground list-disc pl-5">
                {validateWarnings
                  .filter((w) => w.severity === "prepare")
                  .map((w, i) => (
                    <li key={`${w.field_path}-${i}`}>{w.message}</li>
                  ))}
              </ul>
            </div>
          )}

          {catalogSchemaCount > 0 && catalog && dropsOwnSchemas && (
            <div
              data-testid="catalog-schema-warning"
              className="rounded-md border border-amber-500/40 bg-amber-500/5 p-3"
            >
              <p className="text-sm text-amber-700 dark:text-amber-300">
                Catalog &lsquo;{catalog}&rsquo; contains {catalogSchemaCount} schema{catalogSchemaCount === 1 ? "" : "s"}.{" "}
                {isVibeCombined
                  ? `The MVM step of this run drops the schemas this business owns there, including the ECM the first step just deployed; `
                    + "schemas of other businesses are left as they are."
                  : `At the start of this run the agent drops the ones this business owns there before it deploys; `
                    + "schemas of other businesses are left as they are. When the base is the installed latest version, "
                    + "it keeps them and replaces only the tables this run changes."}
              </p>
            </div>
          )}

          {baseContextMissing && (
            <div
              data-testid="base-context-missing"
              className="rounded-md border border-destructive/50 bg-destructive/5 p-3"
            >
              <p className="text-sm text-destructive">
                {contextMode === "text"
                  ? "Business Context is required — describe the business in the Write tab before starting."
                  : "Business Context is required — provide a model.json file path before starting."}
              </p>
            </div>
          )}

          {vibeContentMissing && (
            <div
              data-testid="vibe-content-missing"
              className="rounded-md border border-destructive/50 bg-destructive/5 p-3"
            >
              <p className="text-sm text-destructive">
                No inputs selected — choose inputs on the Compose surface (Edit inputs) to include in this run.
              </p>
            </div>
          )}

          {runtimeBudgetError && !advancedOpen && (
            <div
              data-testid="runtime-budget-invalid"
              className="rounded-md border border-destructive/50 bg-destructive/5 p-3"
            >
              <p className="text-sm text-destructive">
                {runtimeBudgetError} Change it under Advanced Options.
              </p>
            </div>
          )}

          {scopedNothingIncluded && (
            <div
              data-testid="vibe-scope-nothing-included"
              className="rounded-md border border-destructive/50 bg-destructive/5 p-3"
            >
              <p className="text-sm text-destructive">
                None of the selected inputs are anchored in the chosen domains. Select feedback
                on those domains, or widen the scope.
              </p>
            </div>
          )}

          {isVibe && selectionSaving && (
            <p className="text-sm text-muted-foreground" data-testid="selection-saving">
              {SELECTION_SAVING_MESSAGE}
            </p>
          )}

          {runDefaultsLoading && (
            <p className="text-sm text-muted-foreground" data-testid="run-defaults-loading">
              {LOADING_NOTE}
            </p>
          )}

          <div className="flex gap-2 pt-2">
            <Button
              type="submit"
              disabled={
                submitting
                || (isVibe && selectionSaving)
                || runDefaultsLoading
                || (isVibe && eligibleBaseVersions.length === 0)
                || validateBlockers.length > 0
                || baseContextMissing
                || vibeContentMissing
                || scopeDomainsMissing
                || scopedCompilePending
                || scopedNothingIncluded
                || runtimeBudgetError !== null
              }
            >
              {submitting ? "Starting..." : "Start Run"}
            </Button>
            <Button variant="outline" asChild>
              <Link to="/businesses/$businessId/explorer" params={{ businessId }}>
                Cancel
              </Link>
            </Button>
          </div>
        </form>
      </CardContent>
    </Card>
    <LaunchRunDialog
      open={confirmOpen}
      operationType={runType}
      businessName={business?.name ?? "this business"}
      versionLabel={
        isVibe
          ? (() => {
              const v = baseCandidates.find((cv) => cv.id === baseVersionId);
              if (!v) return undefined;
              const scopeLabel = (v.scope || "mvm").toUpperCase();
              return `v${v.version} ${scopeLabel}`;
            })()
          : undefined
      }
      scopeLabel={
        isVibeIterate
          ? formatScopeLabel(vibeScope, [...matchedScopeDomains, ...unknownScopeDomains])
          : undefined
      }
      agentRunMode={isVibeIterate ? agentRunMode : undefined}
      catalog={catalog}
      submitting={submitting}
      onConfirm={performRun}
      onCancel={() => {
        if (!submitting) setConfirmOpen(false);
      }}
    />
    {isVibe && (
      <div className="sticky top-4 self-start flex max-h-[calc(100vh-2rem)] flex-col gap-2">
        <label className="text-sm font-medium">Compiled instructions preview</label>
        {inputIds.length === 0 ? (
          <div
            data-testid="vibe-inputs-empty-state"
            className="flex flex-col items-start gap-3 rounded-md border border-input bg-muted/30 p-4 text-sm"
          >
            <p className="text-muted-foreground">
              No inputs selected — choose inputs on the Compose surface to include
              in this run.
            </p>
            {baseVersionId && (
              <Button asChild variant="outline" size="sm">
                <Link
                  to="/businesses/$businessId/model/$version/$scope/inputs"
                  params={{
                    businessId,
                    version: String(
                      (versions.find((v) => v.id === baseVersionId) as any)?.version ?? "",
                    ),
                    scope:
                      ((versions.find((v) => v.id === baseVersionId) as any)?.scope || "ecm"),
                  }}
                >
                  Choose inputs on the Compose surface
                  <ArrowRight className="h-4 w-4 ml-1.5" />
                </Link>
              </Button>
            )}
          </div>
        ) : (
          scopedCompilePending ? (
            <div
              data-testid="vibe-scope-preview-pending"
              className="rounded-md border border-input bg-muted/30 p-4 text-sm text-muted-foreground"
            >
              Compiling the scoped preview…
            </div>
          ) : scopedCompileError ? (
            <div
              data-testid="vibe-scope-preview-error"
              className="rounded-md border border-destructive/50 bg-destructive/5 p-4 text-sm text-destructive"
            >
              {scopedCompileError}
            </div>
          ) : (
            <div className="min-h-0 flex-1 overflow-auto rounded-md border border-input bg-muted/30">
              <CompiledPreview inputs={baseInputs} includedIds={previewIncludedIds} />
            </div>
          )
        )}
        {isScoped && scopedExcluded.length > 0 && (
          <div
            data-testid="vibe-scope-excluded"
            className="rounded-md border border-input bg-muted/30 p-3 text-xs space-y-1.5"
          >
            <p className="font-medium text-muted-foreground">Not sent in this scoped run</p>
            <ul className="space-y-1">
              {scopedExcluded.map(({ id, reason, input }) => {
                const anchor = input ? (anchorPathForCompile(input) ?? []).join(" › ") : "";
                return (
                  <li key={id} data-testid="vibe-scope-excluded-item">
                    <span className="font-medium">
                      {EXCLUDED_REASON_LABELS[reason] ?? `Not sent (${reason || "excluded"})`}
                    </span>
                    {anchor && <span className="text-muted-foreground"> · {anchor}</span>}
                    {input && (
                      <span className="block truncate text-muted-foreground">{input.text}</span>
                    )}
                  </li>
                );
              })}
            </ul>
          </div>
        )}
        <p className="text-xs text-muted-foreground">
          Read-only preview of what the agent receives, compiled from the selected
          Vibe Inputs. Use <strong>Edit inputs</strong> to change the selection.
        </p>
      </div>
    )}
    </div>
  );
}
