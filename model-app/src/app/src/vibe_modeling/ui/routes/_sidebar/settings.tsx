import { createFileRoute, useNavigate, useSearch } from "@tanstack/react-router";
import { Suspense, useState } from "react";
import { toast } from "sonner";
import { notifyError } from "@/lib/notify";
import { apiErrorMessage } from "@/lib/api-error";
import { invalidateEntityLists } from "@/lib/delete-invalidation";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Textarea } from "@/components/ui/textarea";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Skeleton } from "@/components/ui/skeleton";
import { Tabs, TabsList, TabsTrigger, TabsContent } from "@/components/ui/tabs";
import { Checkbox } from "@/components/ui/checkbox";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import {
  AlertTriangle,
  Check,
  Database,
  Factory,
  Github,
  Info,
  LayoutGrid,
  Pencil,
  Plus,
  Save,
  Settings,
  Trash2,
  X,
} from "lucide-react";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import {
  Dialog,
  DialogContent,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import {
  AlertDialog,
  AlertDialogAction,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
} from "@/components/ui/alert-dialog";
import {
  Tooltip,
  TooltipContent,
  TooltipProvider,
  TooltipTrigger,
} from "@/components/ui/tooltip";
import {
  SortableTableHead,
  useTableSort,
} from "@/components/ui/sortable-table-head";
import {
  useGetAgentConfig,
  useSetAgentConfig,
  useGetMetamodelCatalog,
  useSetMetamodelCatalog,
  getMetamodelCatalogKey,
  useGetSupportedAgentVersion,
  useListSectorsSuspense,
  useCreateSector,
  useUpdateSector,
  useDeleteSector,
  listSectorsKey,
  useListWarehousesSuspense,
  useGetWarehouseSuspense,
  useSetWarehouse,
  useGetGithubConfigSuspense,
  useUpdateGithubConfig,
  getGithubConfigKey,
  useGetSourceAuthConfigSuspense,
  useUpdateSourceAuthConfig,
  getSourceAuthConfigKey,
  getAgentConfigKey,
  checkAgentNotebook,
  useGetUserPreferences,
  useSetUserPreference,
  getUserPreferencesKey,
} from "@/lib/api";
import type { ColumnDisplayMode } from "@/components/diagram/types";
import { useAgentReady, agentReadyQueryKey } from "@/lib/hooks";
import type { SectorOut } from "@/lib/api";
import { selector } from "@/lib/selector";
import { useBreadcrumbs } from "@/components/explorer/breadcrumb-context";
import { AgentStatusRow } from "@/components/settings/agent-status-row";
import { SourceAuthBanner } from "@/components/source-explorer/source-auth-banner";
import { AdminGate } from "@/components/settings/admin-gate";
import { SavedNotice, SaveErrorBox, StatusLine } from "@/components/settings/status-line";
import {
  RUNTIME_BUDGET_SETTINGS_HINT,
  runtimeBudgetBoundsError,
  runtimeBudgetBoundsText,
  parseRuntimeBudgetInput,
} from "@/lib/runtime-budget";
import { OptionalFeaturesSection } from "@/components/settings/optional-features";
import { useQueryClient } from "@tanstack/react-query";

// Re-exported so existing imports (`@/routes/_sidebar/settings`) and tests keep
// resolving after the banner moved to its shared home.
export { SourceAuthBanner };

const validTabs = [
  "agent",
  "platform",
  "sources",
  "sectors",
  "preferences",
] as const;
type SettingsTab = (typeof validTabs)[number];

// Deep links to retired tab names still circulate (bookmarks, docs, in-app
// links; `assessment` is now the Platform tab's Optional features section).
// Map the retired tab names onto their new homes so those
// URLs keep landing on the right section instead of silently falling back to
// "agent". Resolved inside validateSearch so the redirect happens at parse
// time, before any component renders.
const legacyTabRedirects: Record<string, SettingsTab> = {
  diagram: "preferences",
  warehouse: "platform",
  github: "sources",
  assessment: "platform",
};

export const Route = createFileRoute("/_sidebar/settings")({
  validateSearch: (search: Record<string, unknown>): { tab: SettingsTab } => {
    const raw = search.tab as string;
    const mapped = legacyTabRedirects[raw] ?? raw;
    return {
      tab: validTabs.includes(mapped as SettingsTab)
        ? (mapped as SettingsTab)
        : "agent",
    };
  },
  component: () => {
    const navigate = useNavigate();
    const { tab } = useSearch({ from: "/_sidebar/settings" });

    const setTab = (value: string) => {
      navigate({ to: ".", search: { tab: value as SettingsTab }, replace: true });
    };

    useBreadcrumbs([{ label: "Settings" }]);

    return (
      <div className="p-4 space-y-3">
        <div className="flex items-center gap-3">
          <Settings className="h-5 w-5" />
          <h1 className="text-2xl font-semibold tracking-tight">Settings</h1>
        </div>
        <Tabs value={tab} onValueChange={setTab}>
          <TabsList>
            <TabsTrigger value="agent">Agent</TabsTrigger>
            <TabsTrigger value="platform">
              <Database className="h-4 w-4 mr-1.5" />
              Platform
            </TabsTrigger>
            <TabsTrigger value="sources">
              <Github className="h-4 w-4 mr-1.5" />
              Sources
            </TabsTrigger>
            <TabsTrigger value="sectors">
              <Factory className="h-4 w-4 mr-1.5" />
              Sectors
            </TabsTrigger>
            <TabsTrigger value="preferences">
              <LayoutGrid className="h-4 w-4 mr-1.5" />
              Preferences
            </TabsTrigger>
          </TabsList>
          <TabsContent value="agent">
            <AdminGate scope="app">
              <AgentConfigSection />
            </AdminGate>
          </TabsContent>
          <TabsContent value="platform">
            <AdminGate scope="app">
              <PlatformSection />
            </AdminGate>
          </TabsContent>
          <TabsContent value="sources">
            <AdminGate scope="app">
              <SourcesSection />
            </AdminGate>
          </TabsContent>
          <TabsContent value="sectors">
            <AdminGate scope="business">
              <Suspense fallback={<Skeleton className="h-96 w-full" />}>
                <SectorsSection />
              </Suspense>
            </AdminGate>
          </TabsContent>
          <TabsContent value="preferences">
            <DiagramSettingsSection />
          </TabsContent>
        </Tabs>
      </div>
    );
  },
});

type NotebookCheckState =
  | { status: "idle" }
  | { status: "checking" }
  | { status: "ok"; version?: string }
  | { status: "warn"; message: string }
  | { status: "error"; reason: string };

export function AgentConfigSection() {
  const { data: result, isLoading } = useGetAgentConfig({
    query: { retry: false },
  });
  const config = result?.data;
  const { mutateAsync: saveConfig } = useSetAgentConfig();
  const { data: supportedResult } = useGetSupportedAgentVersion();
  const supported = supportedResult?.data as
    | { version: string; repo: string; repo_tag_url?: string }
    | undefined;
  const { data: agentReady } = useAgentReady();
  const queryClient = useQueryClient();
  const [notebookPath, setNotebookPath] = useState("");
  // Persistent agent job's max_concurrent_runs. Min 3 mirrors AgentConfigIn
  // (ge=3) — slack for unified-pipeline phase transition + cancel-with-
  // rollback cleanup overlaps. Sub-3 would also be rejected with 422
  // server-side; the client-side check shows a clearer inline message.
  const MIN_CONCURRENT_RUNS = 3;
  const [maxConcurrentRuns, setMaxConcurrentRuns] = useState<number>(
    MIN_CONCURRENT_RUNS,
  );
  const [maxConcurrentRunsError, setMaxConcurrentRunsError] = useState<
    string | null
  >(null);
  const [runTags, setRunTags] = useState<boolean>(true);
  // Settings default run time budget, whole hours. The bounds come from the
  // API (AgentConfigOut), never from literals here; until the config loads
  // there is nothing to edit.
  const budgetMin = config?.runtime_budget_min_hours;
  const budgetMax = config?.runtime_budget_max_hours;
  const [runtimeBudgetHours, setRuntimeBudgetHours] = useState<number | null>(null);
  const [runtimeBudgetError, setRuntimeBudgetError] = useState<string | null>(null);
  const [saving, setSaving] = useState(false);
  const [saved, setSaved] = useState(false);
  const [initialized, setInitialized] = useState(false);
  const [saveError, setSaveError] = useState<string | null>(null);
  const [notebookCheck, setNotebookCheck] = useState<NotebookCheckState>({
    status: "idle",
  });

  // Sync form state when config loads. Also kick off a notebook check
  // automatically so the green/amber/red status reflects the *saved* path
  // without requiring the user to tab through the input first — the common
  // case where a previously-reachable notebook has become inaccessible was
  // otherwise invisible on this screen.
  //
  // First-time use case: the API returns 404 ("Agent not configured")
  // when no AgentConfig row exists. `result.data` is undefined and `config`
  // is undefined; we still need to flip `initialized=true` once the load
  // settles so `dirty` can react to user edits, otherwise the Save button
  // stays disabled forever on a fresh deploy.
  if (config && !initialized) {
    setNotebookPath(config.notebook_path);
    setMaxConcurrentRuns(config.max_concurrent_runs ?? MIN_CONCURRENT_RUNS);
    setRunTags(config.collect_vibe_run_statistics ?? true);
    setRuntimeBudgetHours(config.runtime_budget_hours ?? null);
    setInitialized(true);
    if (config.notebook_path.trim()) {
      // Defer so the update happens after the current render cycle.
      Promise.resolve().then(() => runNotebookCheck(config.notebook_path));
    }
  } else if (!isLoading && !config && !initialized) {
    // Settled to "no config" — no row to mirror, but mark initialized so
    // the dirty calc lets the user save the first config.
    setInitialized(true);
  }

  // Dirty if either field differs from the persisted config. While the
  // config is still loading we treat the form as clean so the Save button
  // stays disabled until the user has something to save.
  const persistedNotebook = config?.notebook_path ?? "";
  const persistedMaxConcurrent =
    config?.max_concurrent_runs ?? MIN_CONCURRENT_RUNS;
  const persistedRunTags = config?.collect_vibe_run_statistics ?? true;
  const persistedRuntimeBudget = config?.runtime_budget_hours ?? null;
  const dirty =
    initialized &&
    (notebookPath !== persistedNotebook ||
      maxConcurrentRuns !== persistedMaxConcurrent ||
      runTags !== persistedRunTags ||
      runtimeBudgetHours !== persistedRuntimeBudget);

  const runNotebookCheck = async (path: string) => {
    if (!path.trim()) {
      setNotebookCheck({ status: "idle" });
      return;
    }
    setNotebookCheck({ status: "checking" });
    try {
      const resp = await checkAgentNotebook({ path });
      const body = resp.data as {
        ok: boolean;
        reason?: string;
        version?: string;
        warning?: string;
      };
      if (body.ok) {
        if (body.warning) {
          setNotebookCheck({ status: "warn", message: body.warning });
        } else {
          setNotebookCheck({ status: "ok", version: body.version });
        }
      } else {
        setNotebookCheck({
          status: "error",
          reason: body.reason || "Notebook not reachable by the app.",
        });
      }
    } catch (e) {
      setNotebookCheck({
        status: "error",
        reason: apiErrorMessage(e, String(e)),
      });
    }
  };

  const handleSave = async (e: React.FormEvent) => {
    e.preventDefault();
    // The form is noValidate, so the notebook path's `required` is checked here.
    if (!notebookPath.trim()) {
      setSaveError("Notebook Path is required.");
      return;
    }
    // Client-side floor enforcement. Mirrors AgentConfigIn(ge=3); the
    // backend would 422 anyway, but the inline error reads better than
    // the parsed-422 banner.
    if (
      !Number.isFinite(maxConcurrentRuns) ||
      maxConcurrentRuns < MIN_CONCURRENT_RUNS
    ) {
      setMaxConcurrentRunsError(
        `Concurrent runs must be at least ${MIN_CONCURRENT_RUNS}.`,
      );
      return;
    }
    setMaxConcurrentRunsError(null);
    const budgetMessage = runtimeBudgetBoundsError(runtimeBudgetHours, budgetMin, budgetMax);
    if (budgetMessage) {
      setRuntimeBudgetError(budgetMessage);
      return;
    }
    setRuntimeBudgetError(null);
    // Confirm-on-warning: if the path is reachable but the version
    // marker wasn't found (or some other warning was returned by the
    // check endpoint), the user has the authority to ignore it. Show a
    // confirm dialog so the override is explicit, not silent.
    if (notebookCheck.status === "warn") {
      const proceed = window.confirm(
        `Heads up: ${notebookCheck.message}\n\n` +
          `The app couldn't verify the notebook's version. Continue saving anyway?`,
      );
      if (!proceed) {
        return;
      }
    }
    setSaving(true);
    setSaveError(null);
    try {
      // Persist the agent job's fields: the notebook path +
      // max_concurrent_runs provision / re-reset the Databricks job, the
      // statistics flag rides along. A failure surfaces a single error and
      // leaves the form dirty so the user can retry. The metamodel catalog
      // is a separate concern (Platform tab); it is no longer saved here.
      const notebookChanged = notebookPath !== persistedNotebook;
      const maxConcurrentChanged =
        maxConcurrentRuns !== persistedMaxConcurrent;
      const runTagsChanged =
        runTags !== persistedRunTags;
      const runtimeBudgetChanged = runtimeBudgetHours !== persistedRuntimeBudget;
      if (notebookChanged || maxConcurrentChanged || runTagsChanged || runtimeBudgetChanged) {
        await saveConfig({
          params: {},
          data: {
            notebook_path: notebookPath,
            max_concurrent_runs: maxConcurrentRuns,
            collect_vibe_run_statistics: runTags,
            ...(runtimeBudgetHours !== null ? { runtime_budget_hours: runtimeBudgetHours } : {}),
          },
        });
      }
      // Use the orval-generated key constants so the readout (driven by
      // useGetAgentConfig) actually refetches. The previous string key
      // "getAgentConfig" never matched, leaving the summary block stuck on
      // "Not set" until a manual reload — the F3 bug.
      //
      // AWAIT the agent-config invalidation before flipping `initialized=false`
      // so the next render sees FRESH config in the cache, not stale. Without
      // the await, the rehydrate block (`if (config && !initialized)`) fires
      // against the stale-cache value and clobbers the user's input — the
      // post-save toggle showed checked=true even though the backend had
      // already persisted false. invalidateQueries' returned Promise resolves
      // only after in-flight refetches complete.
      await queryClient.invalidateQueries({ queryKey: getAgentConfigKey() });
      // Saving a new path/catalog can make the app "ready" (or not) — force
      // the readiness banner to re-query so its state matches what just
      // saved.
      queryClient.invalidateQueries({ queryKey: agentReadyQueryKey() });
      setInitialized(false);
      setSaved(true);
      // Re-run the actual reachability + version check so the post-save
      // banner reflects the same backend verdict the on-load path will use
      // (single source of truth: `_detect_notebook_version`). Optimistically
      // setting `status: "ok"` here was the F2 flicker — Save said "matches"
      // even when the backend's parser hadn't recognised the marker.
      if (notebookChanged) {
        Promise.resolve().then(() => runNotebookCheck(notebookPath));
      }
      setTimeout(() => setSaved(false), 2000);
    } catch (err: unknown) {
      const detail = apiErrorMessage(err, "Save failed.");
      setSaveError(detail);
      setNotebookCheck({ status: "error", reason: detail });
    } finally {
      setSaving(false);
    }
  };

  if (isLoading) return <Skeleton className="h-64 w-full max-w-4xl" />;

  return (
    <Card className="max-w-4xl">
      <CardHeader>
        <CardTitle>Agent Configuration</CardTitle>
      </CardHeader>
      <CardContent>
        {/* Readiness banner: every "runs are blocked" reason (no job, the SP
            lost access to the saved notebook) except "no notebook", which
            the status line below already says with its fix. */}
        {agentReady && !agentReady.ready && persistedNotebook.trim() !== "" && (
          <div className="mb-4 flex items-start gap-2 rounded-md border border-warning/40 bg-warning/5 px-3 py-2 text-xs">
            <AlertTriangle className="h-4 w-4 text-warning shrink-0 mt-0.5" />
            <span className="text-warning">
              {agentReady.reason ||
                "Agent configuration is not ready — runs are disabled."}
            </span>
          </div>
        )}
        <AgentStatusRow
          hasNotebook={persistedNotebook.trim() !== ""}
          onSwitched={(path) => {
            setNotebookPath(path);
            setInitialized(false);
            setNotebookCheck({ status: "idle" });
          }}
        />
        {/* noValidate: the browser's own bubbles would replace the inline
            errors handleSave shows for each field. */}
        <form onSubmit={handleSave} className="space-y-4" noValidate data-testid="agent-config-form">
          <div className="space-y-2">
            <div className="flex items-center gap-1.5">
              <label className="text-sm font-medium" htmlFor="agent-notebook-path">
                Notebook Path *
              </label>
              {supported && (
                <TooltipProvider delayDuration={200}>
                  <Tooltip>
                    <TooltipTrigger asChild>
                      <button
                        type="button"
                        aria-label="About the agent version"
                        className="text-muted-foreground hover:text-foreground"
                        data-testid="notebook-path-pin-help"
                      >
                        <Info className="h-3.5 w-3.5" />
                      </button>
                    </TooltipTrigger>
                    <TooltipContent className="max-w-sm text-xs">
                      This app is pinned to agent {supported.version}. The notebook's{" "}
                      <span className="font-mono">__RELEASE_VERSION__</span> is verified on
                      save; the agent build (<span className="font-mono">__AGENT_VERSION__</span>)
                      can move within a release without a re-pin.
                    </TooltipContent>
                  </Tooltip>
                </TooltipProvider>
              )}
            </div>
            <Input
              id="agent-notebook-path"
              value={notebookPath}
              onChange={(e) => {
                setNotebookPath(e.target.value);
                setNotebookCheck({ status: "idle" });
              }}
              onBlur={() => runNotebookCheck(notebookPath)}
              placeholder="/Workspace/path/to/notebook"
              required
            />
            {notebookCheck.status === "checking" && (
              <p className="text-xs text-muted-foreground">
                Checking access…
              </p>
            )}
            {notebookCheck.status === "ok" && (
              <StatusLine tone="ok">
                Reachable; version matches
                {notebookCheck.version ? ` (${notebookCheck.version})` : ""}.
              </StatusLine>
            )}
            {notebookCheck.status === "warn" && (
              <StatusLine tone="warn">{notebookCheck.message}</StatusLine>
            )}
            {notebookCheck.status === "error" && (
              <StatusLine tone="error">{notebookCheck.reason}</StatusLine>
            )}
            <p className="text-xs text-muted-foreground">
              Path to the vibe modelling agent notebook in the Databricks workspace.
            </p>
          </div>

          <div className="space-y-2">
            <label className="text-sm font-medium" htmlFor="max-concurrent-runs">
              Concurrent runs
            </label>
            <Input
              id="max-concurrent-runs"
              type="number"
              min={MIN_CONCURRENT_RUNS}
              step={1}
              aria-invalid={maxConcurrentRunsError !== null}
              aria-describedby={
                maxConcurrentRunsError
                  ? "max-concurrent-runs-error max-concurrent-runs-hint"
                  : "max-concurrent-runs-hint"
              }
              value={maxConcurrentRuns}
              onChange={(e) => {
                const next = parseInt(e.target.value, 10);
                setMaxConcurrentRuns(Number.isNaN(next) ? 0 : next);
                setMaxConcurrentRunsError(null);
              }}
            />
            {maxConcurrentRunsError && (
              <StatusLine tone="error" id="max-concurrent-runs-error">
                {maxConcurrentRunsError}
              </StatusLine>
            )}
            <p id="max-concurrent-runs-hint" className="text-xs text-muted-foreground">
              Minimum {MIN_CONCURRENT_RUNS}. The agent job needs slack for the
              unified-pipeline phase transition and cancel-with-rollback
              cleanup overlaps.
            </p>
          </div>

          {runtimeBudgetHours !== null && budgetMin !== undefined && budgetMax !== undefined && (
            <div className="space-y-2">
              <label className="text-sm font-medium" htmlFor="runtime-budget-hours">
                Run time budget (hours)
              </label>
              <Input
                id="runtime-budget-hours"
                type="number"
                min={budgetMin}
                max={budgetMax}
                step={1}
                aria-invalid={runtimeBudgetError !== null}
                aria-describedby={
                  runtimeBudgetError
                    ? "runtime-budget-hours-error runtime-budget-hours-hint"
                    : "runtime-budget-hours-hint"
                }
                value={Number.isNaN(runtimeBudgetHours) ? "" : runtimeBudgetHours}
                onChange={(e) => {
                  setRuntimeBudgetHours(parseRuntimeBudgetInput(e.target.value));
                  setRuntimeBudgetError(null);
                }}
              />
              {runtimeBudgetError && (
                <StatusLine tone="error" id="runtime-budget-hours-error">
                  {runtimeBudgetError}
                </StatusLine>
              )}
              <p
                id="runtime-budget-hours-hint"
                className="text-xs text-muted-foreground"
                data-testid="runtime-budget-hint"
              >
                {RUNTIME_BUDGET_SETTINGS_HINT} {runtimeBudgetBoundsText(budgetMin, budgetMax)}
              </p>
            </div>
          )}

          <div className="space-y-2">
            <TooltipProvider delayDuration={200}>
              <Tooltip>
                <TooltipTrigger asChild>
                  <label className="flex items-center gap-2 text-sm font-medium cursor-help">
                    <Checkbox
                      checked={runTags}
                      onCheckedChange={(v) => setRunTags(v === true)}
                    />
                    Annotate jobs with run tags
                  </label>
                </TooltipTrigger>
                <TooltipContent className="max-w-sm text-xs">
                  Each run tags the agent job with the business name, the
                  run's session ID and the notebook file name, so you can tell
                  which business and run used the job. Operational tags (app,
                  app version, operation, model scope, element counts and
                  launcher) are always added.
                </TooltipContent>
              </Tooltip>
            </TooltipProvider>
          </div>

          {config && (
            <div className="text-sm">
              <span className="text-muted-foreground">Job:</span>{" "}
              {config.job_id ? (
                <span className="font-mono">
                  {config.job_url ? (
                    <a
                      href={config.job_url}
                      target="_blank"
                      rel="noopener noreferrer"
                      className="underline hover:text-foreground"
                    >
                      {config.job_id}
                    </a>
                  ) : (
                    config.job_id
                  )}
                  {" "}
                  ({config.job_name})
                </span>
              ) : (
                <span className="font-mono">Not set</span>
              )}
            </div>
          )}

          {saveError && (
            <SaveErrorBox>{saveError}</SaveErrorBox>
          )}

          <Button
            type="submit"
            disabled={!notebookPath || saving || !dirty}
          >
            <Save className="h-4 w-4 mr-2" />
            {saving ? "Saving..." : saved ? "Saved!" : "Save Configuration"}
          </Button>
        </form>
      </CardContent>
    </Card>
  );
}

// Platform tab: installation-wide platform settings an admin controls - the
// metamodel catalog (concern A), the SQL warehouse used for progress
// polling + model sync, and the "Optional features" section (the Domain
// Taxonomy Builder and the bronze assessment: installed or not, ready or not,
// last saved by, and the settings of each installed one).
export function PlatformSection() {
  return (
    <div className="space-y-4">
      <MetamodelCatalogCard />
      <Suspense fallback={<Skeleton className="h-64 w-full max-w-4xl" />}>
        <WarehouseSection />
      </Suspense>
      <OptionalFeaturesSection />
    </div>
  );
}

// Unity Catalog names must start with a lowercase letter and contain only
// lowercase letters, digits, and underscores. Mirrors the agent's op-param
// pattern so the app rejects a catalog the agent would reject on dispatch.
const METAMODEL_CATALOG_PATTERN = /^[a-z][a-z0-9_]+$/;

export function MetamodelCatalogCard() {
  const { data: result, isLoading } = useGetMetamodelCatalog({
    query: { retry: false },
  });
  const persisted = (result?.data?.metamodel_catalog as string) ?? "";
  const { mutateAsync: saveCatalog } = useSetMetamodelCatalog();
  const queryClient = useQueryClient();

  const [value, setValue] = useState("");
  const [initialized, setInitialized] = useState(false);
  const [saving, setSaving] = useState(false);
  const [saved, setSaved] = useState(false);
  const [saveError, setSaveError] = useState<string | null>(null);

  if (result && !initialized) {
    setValue(persisted);
    setInitialized(true);
  } else if (!isLoading && !result && !initialized) {
    setInitialized(true);
  }

  const trimmed = value.trim();
  // Empty is a valid state (unconfigured / clearing). A non-empty value must
  // match the UC name pattern; only then is it a legal catalog to save.
  const invalid = trimmed.length > 0 && !METAMODEL_CATALOG_PATTERN.test(trimmed);
  const dirty = initialized && trimmed !== persisted.trim();

  const handleSave = async (e: React.FormEvent) => {
    e.preventDefault();
    if (invalid) return;
    setSaving(true);
    setSaveError(null);
    try {
      await saveCatalog({
        params: {},
        data: { metamodel_catalog: trimmed },
      });
      await queryClient.invalidateQueries({ queryKey: getMetamodelCatalogKey() });
      queryClient.invalidateQueries({ queryKey: agentReadyQueryKey() });
      setInitialized(false);
      setSaved(true);
      setTimeout(() => setSaved(false), 2000);
    } catch (err: unknown) {
      const detail = apiErrorMessage(err, "Save failed. The metamodel catalog requires admin access.");
      setSaveError(detail);
    } finally {
      setSaving(false);
    }
  };

  if (isLoading) return <Skeleton className="h-64 w-full max-w-4xl" />;

  return (
    <Card className="max-w-4xl">
      <CardHeader>
        <CardTitle>Metamodel catalog</CardTitle>
      </CardHeader>
      <CardContent>
        <form onSubmit={handleSave} className="space-y-4">
          <div className="space-y-2">
            <label className="text-sm font-medium" htmlFor="metamodel-catalog">
              Metamodel catalog
            </label>
            <Input
              id="metamodel-catalog"
              value={value}
              onChange={(e) => setValue(e.target.value)}
              placeholder="e.g. vibe_modeling_metamodel"
              className="font-mono"
              aria-invalid={invalid}
            />
            {invalid && (
              <StatusLine tone="error">
                Must start with a lowercase letter and contain only lowercase
                letters, digits, and underscores.
              </StatusLine>
            )}
            <p className="text-xs text-muted-foreground">
              UC catalog holding the agent's{" "}
              <span className="font-mono">_metamodel</span> schema and{" "}
              <span className="font-mono">vol_root</span> Volume; also the
              default run target.
            </p>
          </div>

          {saveError && (
            <SaveErrorBox>{saveError}</SaveErrorBox>
          )}

          {saved && (
            <SavedNotice>Metamodel catalog saved</SavedNotice>
          )}

          <Button type="submit" disabled={saving || invalid || !dirty}>
            <Save className="h-4 w-4 mr-2" />
            {saving ? "Saving..." : saved ? "Saved!" : "Save"}
          </Button>
        </form>
      </CardContent>
    </Card>
  );
}

function WarehouseSection() {
  const { data: warehouses } = useListWarehousesSuspense(selector());
  const { data: current } = useGetWarehouseSuspense(selector());
  const { mutateAsync: setWh } = useSetWarehouse();
  const queryClient = useQueryClient();
  const [saving, setSaving] = useState(false);
  const [saved, setSaved] = useState(false);

  const currentId = (current?.warehouse_id as string) ?? "";

  const handleChange = async (value: string) => {
    setSaving(true);
    try {
      await setWh({ params: {}, data: { warehouse_id: value } });
      queryClient.invalidateQueries({ queryKey: ["getWarehouse"] });
      setSaved(true);
      setTimeout(() => setSaved(false), 2000);
    } finally {
      setSaving(false);
    }
  };

  const running = (warehouses ?? []).filter((w) => w.state === "RUNNING");
  const stopped = (warehouses ?? []).filter((w) => w.state !== "RUNNING");

  return (
    <Card className="max-w-4xl">
      <CardHeader>
        <CardTitle>SQL Warehouse</CardTitle>
      </CardHeader>
      <CardContent className="space-y-4">
        <p className="text-sm text-muted-foreground">
          Select the SQL warehouse used for querying Delta tables during run
          progress monitoring and model sync operations.
        </p>
        <div className="space-y-2">
          <label className="text-sm font-medium">Active Warehouse</label>
          <Select
            value={currentId}
            onValueChange={handleChange}
            disabled={saving}
          >
            <SelectTrigger className="w-full">
              <SelectValue placeholder="Select a warehouse..." />
            </SelectTrigger>
            <SelectContent>
              {running.length > 0 && (
                <>
                  {running.map((w) => (
                    <SelectItem key={w.id} value={w.id}>
                      <span className="flex items-center gap-2">
                        <span className="h-2 w-2 rounded-full bg-green-500 inline-block" />
                        {w.name}
                        {w.cluster_size && (
                          <span className="text-muted-foreground text-xs">
                            ({w.cluster_size})
                          </span>
                        )}
                      </span>
                    </SelectItem>
                  ))}
                </>
              )}
              {stopped.length > 0 && (
                <>
                  {stopped.map((w) => (
                    <SelectItem key={w.id} value={w.id}>
                      <span className="flex items-center gap-2">
                        <span className="h-2 w-2 rounded-full bg-muted-foreground inline-block" />
                        {w.name}
                        <span className="text-muted-foreground text-xs">
                          ({w.state.toLowerCase()})
                        </span>
                      </span>
                    </SelectItem>
                  ))}
                </>
              )}
            </SelectContent>
          </Select>
        </div>
        {saved && (
          <SavedNotice>Warehouse updated</SavedNotice>
        )}
        {currentId && (
          <div className="text-xs text-muted-foreground font-mono">
            ID: {currentId}
          </div>
        )}
      </CardContent>
    </Card>
  );
}

// Preference keys backing the diagram's default column-display mode (item 4,
// 0.6.6). Two separate defaults: the all-domains diagram view and the
// focal/single-domain view start from different defaults today (hide vs.
// keys), so each gets its own per-user preference.
const DIAGRAM_ALL_DOMAINS_MODE_KEY = "diagram.default_column_mode";
const DIAGRAM_FOCAL_MODE_KEY = "diagram.default_column_mode_focal";
// Seed defaults for the two diagram column-mode preferences. These are the
// values the diagram viewer falls back to when no preference row exists,
// so "Reset to defaults" writes the seed values back.
const DIAGRAM_ALL_DOMAINS_SEED: ColumnDisplayMode = "hide";
const DIAGRAM_FOCAL_SEED: ColumnDisplayMode = "keys";

export function DiagramSettingsSection() {
  const { data: result, isLoading } = useGetUserPreferences();
  const prefs = result?.data ?? [];
  const { mutateAsync: setPref } = useSetUserPreference();
  const queryClient = useQueryClient();
  const [saved, setSaved] = useState<string | null>(null);
  const [resetting, setResetting] = useState(false);

  const allDomainsValue =
    prefs.find((p) => p.key === DIAGRAM_ALL_DOMAINS_MODE_KEY)?.value ??
    DIAGRAM_ALL_DOMAINS_SEED;
  const focalValue =
    prefs.find((p) => p.key === DIAGRAM_FOCAL_MODE_KEY)?.value ??
    DIAGRAM_FOCAL_SEED;

  const handleChange = async (key: string, value: ColumnDisplayMode) => {
    try {
      await setPref({ params: { key }, data: { value } });
      setSaved(key);
      setTimeout(() => setSaved((s) => (s === key ? null : s)), 2000);
    } catch (err) {
      notifyError(err, { title: "Couldn't save the diagram setting" });
    } finally {
      await queryClient.invalidateQueries({ queryKey: getUserPreferencesKey() });
    }
  };

  const handleReset = async () => {
    setResetting(true);
    try {
      await setPref({
        params: { key: DIAGRAM_ALL_DOMAINS_MODE_KEY },
        data: { value: DIAGRAM_ALL_DOMAINS_SEED },
      });
      await setPref({
        params: { key: DIAGRAM_FOCAL_MODE_KEY },
        data: { value: DIAGRAM_FOCAL_SEED },
      });
    } catch (err) {
      notifyError(err, { title: "Couldn't reset the diagram settings" });
    } finally {
      setResetting(false);
      await queryClient.invalidateQueries({ queryKey: getUserPreferencesKey() });
    }
  };

  if (isLoading) return <Skeleton className="h-64 w-full max-w-4xl" />;

  return (
    <Card className="max-w-4xl">
      <CardHeader>
        <div className="flex items-center gap-2">
          <CardTitle>Diagram</CardTitle>
          <Badge variant="secondary">Only affects you</Badge>
        </div>
      </CardHeader>
      <CardContent className="space-y-4">
        <p className="text-sm text-muted-foreground">
          Default column display mode for new diagram views. Changing these
          does not affect diagrams already open - reload to see the new
          default.
        </p>
        <div className="space-y-2">
          <label className="text-sm font-medium">
            Default columns - all-domains view
          </label>
          <Select
            value={allDomainsValue}
            onValueChange={(v) =>
              handleChange(DIAGRAM_ALL_DOMAINS_MODE_KEY, v as ColumnDisplayMode)
            }
          >
            <SelectTrigger className="w-48">
              <SelectValue />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="hide">Hide columns</SelectItem>
              <SelectItem value="keys">Keys only</SelectItem>
              <SelectItem value="all">All columns</SelectItem>
            </SelectContent>
          </Select>
          {saved === DIAGRAM_ALL_DOMAINS_MODE_KEY && (
            <SavedNotice size="xs">Saved</SavedNotice>
          )}
        </div>
        <div className="space-y-2">
          <label className="text-sm font-medium">
            Default columns - single-domain view
          </label>
          <Select
            value={focalValue}
            onValueChange={(v) =>
              handleChange(DIAGRAM_FOCAL_MODE_KEY, v as ColumnDisplayMode)
            }
          >
            <SelectTrigger className="w-48">
              <SelectValue />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="hide">Hide columns</SelectItem>
              <SelectItem value="keys">Keys only</SelectItem>
              <SelectItem value="all">All columns</SelectItem>
            </SelectContent>
          </Select>
          {saved === DIAGRAM_FOCAL_MODE_KEY && (
            <SavedNotice size="xs">Saved</SavedNotice>
          )}
        </div>
        <div className="pt-2">
          <Button
            variant="outline"
            size="sm"
            onClick={handleReset}
            disabled={resetting}
          >
            {resetting ? "Resetting…" : "Reset to defaults"}
          </Button>
        </div>
      </CardContent>
    </Card>
  );
}

// Sources tab: the industry-models source/publish repo config plus a live
// auth-state line. In 0.6.6 the connector always browses GitHub anonymously
// (transport work deferred to 0.6.7), so an anonymous auth mode surfaces the
// persistent rate-limit warning; the authenticated state arrives with 0.6.7.
export function SourcesSection() {
  return (
    <div className="space-y-4">
      <SourceAuthBanner />
      <Suspense fallback={<Skeleton className="h-64 w-full max-w-4xl" />}>
        <SourceAuthConfigSection />
      </Suspense>
      <Suspense fallback={<Skeleton className="h-64 w-full max-w-4xl" />}>
        <GithubConfigSection />
      </Suspense>
    </div>
  );
}

// Pointer to the human-gated UC HTTP connection setup. Surfaced in the
// empty-state callout so the admin knows publishing requires a manual
// Catalog Explorer step that this form can't perform.
const GITHUB_SETUP_GUIDE_URL =
  "https://github.com/databricks-industry-solutions/lakehouse-industry-data-models/blob/main/model-app/docs/github-integration-setup.md";

// Setup guide for the three source READ-auth modes (0.7.1). Exported as the
// public monorepo path by the export scrubber.
const SOURCE_AUTH_DOC_URL =
  "https://github.com/databricks-industry-solutions/lakehouse-industry-data-models/blob/main/model-app/docs/github-app-source-auth.md";

export function SourceAuthConfigSection() {
  const { data: result } = useGetSourceAuthConfigSuspense(selector());
  const config = result;
  const { mutateAsync: saveConfig } = useUpdateSourceAuthConfig();
  const queryClient = useQueryClient();

  const [authMode, setAuthMode] = useState("");
  const [githubAppId, setGithubAppId] = useState("");
  const [githubAppInstallationId, setGithubAppInstallationId] = useState("");
  const [githubAppSecretScope, setGithubAppSecretScope] = useState("");
  const [githubAppSecretKey, setGithubAppSecretKey] = useState("");
  const [tokenSecretScope, setTokenSecretScope] = useState("");
  const [tokenSecretKey, setTokenSecretKey] = useState("");
  const [initialized, setInitialized] = useState(false);
  const [saving, setSaving] = useState(false);
  const [saved, setSaved] = useState(false);
  const [saveError, setSaveError] = useState<string | null>(null);

  if (config && !initialized) {
    setAuthMode(config.auth_mode ?? "");
    setGithubAppId(config.github_app_id ?? "");
    setGithubAppInstallationId(config.github_app_installation_id ?? "");
    setGithubAppSecretScope(config.github_app_secret_scope ?? "");
    setGithubAppSecretKey(config.github_app_secret_key ?? "");
    setTokenSecretScope(config.token_secret_scope ?? "");
    setTokenSecretKey(config.token_secret_key ?? "");
    setInitialized(true);
  }

  const dirty =
    initialized &&
    (authMode !== (config?.auth_mode ?? "") ||
      githubAppId !== (config?.github_app_id ?? "") ||
      githubAppInstallationId !== (config?.github_app_installation_id ?? "") ||
      githubAppSecretScope !== (config?.github_app_secret_scope ?? "") ||
      githubAppSecretKey !== (config?.github_app_secret_key ?? "") ||
      tokenSecretScope !== (config?.token_secret_scope ?? "") ||
      tokenSecretKey !== (config?.token_secret_key ?? ""));

  const handleSave = async (e: React.FormEvent) => {
    e.preventDefault();
    setSaving(true);
    setSaveError(null);
    try {
      // Round-trip ALL fields so switching modes never NULLs the sibling
      // references (a PUT that omits a field clears it).
      await saveConfig({
        params: {},
        data: {
          auth_mode: authMode,
          github_app_id: githubAppId,
          github_app_installation_id: githubAppInstallationId,
          github_app_secret_scope: githubAppSecretScope,
          github_app_secret_key: githubAppSecretKey,
          token_secret_scope: tokenSecretScope,
          token_secret_key: tokenSecretKey,
        },
      });
      await queryClient.invalidateQueries({ queryKey: getSourceAuthConfigKey() });
      setInitialized(false);
      setSaved(true);
      setTimeout(() => setSaved(false), 2000);
    } catch (err: unknown) {
      const detail = apiErrorMessage(err, "Save failed. Source read access requires admin access.");
      setSaveError(detail);
    } finally {
      setSaving(false);
    }
  };

  return (
    <Card className="max-w-4xl">
      <CardHeader>
        <CardTitle>Source read access</CardTitle>
      </CardHeader>
      <CardContent>
        <p className="mb-4 text-xs text-muted-foreground">
          How the app authenticates when it reads models from the public
          industry-model repo. Anonymous reads are capped at 60 requests/hour per
          shared egress IP, so downloads fail; a GitHub App or a personal access
          token raises the limit to 5,000/hour. Secret material lives in a
          Databricks secret scope — only the scope/key references are stored
          here. See the{" "}
          <a
            href={SOURCE_AUTH_DOC_URL}
            target="_blank"
            rel="noopener noreferrer"
            className="underline hover:text-foreground"
          >
            source read authentication guide
          </a>
          .
        </p>

        {config?.error && (
          <div className="mb-4 flex items-start gap-2 rounded-md border border-warning/40 bg-warning/5 px-3 py-2 text-xs">
            <AlertTriangle className="h-4 w-4 text-warning shrink-0 mt-0.5" />
            <span className="text-warning">
              The saved read-auth config could not be applied (currently reading
              as <span className="font-mono">{config.effective_mode}</span>):{" "}
              {config.error}
            </span>
          </div>
        )}

        <form onSubmit={handleSave} className="space-y-4">
          <div className="space-y-2">
            <label className="text-sm font-medium">Authentication mode</label>
            <Select value={authMode} onValueChange={setAuthMode}>
              <SelectTrigger className="w-full">
                <SelectValue placeholder="Select a mode..." />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="github_app">
                  GitHub App (recommended)
                </SelectItem>
                <SelectItem value="token">Personal access token</SelectItem>
                <SelectItem value="anonymous">Anonymous</SelectItem>
              </SelectContent>
            </Select>
          </div>

          {authMode === "github_app" && (
            <div className="space-y-4">
              <div className="grid grid-cols-2 gap-3">
                <div className="space-y-2">
                  <label className="text-sm font-medium" htmlFor="source-app-id">
                    App ID
                  </label>
                  <Input
                    id="source-app-id"
                    value={githubAppId}
                    onChange={(e) => setGithubAppId(e.target.value)}
                    placeholder="e.g. 123456"
                  />
                </div>
                <div className="space-y-2">
                  <label
                    className="text-sm font-medium"
                    htmlFor="source-app-installation-id"
                  >
                    Installation ID
                  </label>
                  <Input
                    id="source-app-installation-id"
                    value={githubAppInstallationId}
                    onChange={(e) => setGithubAppInstallationId(e.target.value)}
                    placeholder="e.g. 99887766"
                  />
                </div>
              </div>
              <div className="grid grid-cols-2 gap-3">
                <div className="space-y-2">
                  <label
                    className="text-sm font-medium"
                    htmlFor="source-app-secret-scope"
                  >
                    PEM secret scope
                  </label>
                  <Input
                    id="source-app-secret-scope"
                    value={githubAppSecretScope}
                    onChange={(e) => setGithubAppSecretScope(e.target.value)}
                    placeholder="e.g. vibe-modeling"
                    className="font-mono"
                  />
                </div>
                <div className="space-y-2">
                  <label
                    className="text-sm font-medium"
                    htmlFor="source-app-secret-key"
                  >
                    PEM secret key
                  </label>
                  <Input
                    id="source-app-secret-key"
                    value={githubAppSecretKey}
                    onChange={(e) => setGithubAppSecretKey(e.target.value)}
                    placeholder="e.g. github_app_pem"
                    className="font-mono"
                  />
                </div>
              </div>
              <p className="text-xs text-muted-foreground">
                Store the App's private key (PEM) in the secret scope above and
                grant the app service principal READ on that scope.
              </p>
            </div>
          )}

          {authMode === "token" && (
            <div className="space-y-4">
              <div className="grid grid-cols-2 gap-3">
                <div className="space-y-2">
                  <label
                    className="text-sm font-medium"
                    htmlFor="source-token-secret-scope"
                  >
                    PAT secret scope
                  </label>
                  <Input
                    id="source-token-secret-scope"
                    value={tokenSecretScope}
                    onChange={(e) => setTokenSecretScope(e.target.value)}
                    placeholder="e.g. vibe-modeling"
                    className="font-mono"
                  />
                </div>
                <div className="space-y-2">
                  <label
                    className="text-sm font-medium"
                    htmlFor="source-token-secret-key"
                  >
                    PAT secret key
                  </label>
                  <Input
                    id="source-token-secret-key"
                    value={tokenSecretKey}
                    onChange={(e) => setTokenSecretKey(e.target.value)}
                    placeholder="e.g. github_pat"
                    className="font-mono"
                  />
                </div>
              </div>
              <p className="text-xs text-muted-foreground">
                Store the personal access token in the secret scope above and
                grant the app service principal READ on that scope. A read-only
                public-repo token is enough.
              </p>
            </div>
          )}

          {authMode === "anonymous" && (
            <p className="text-xs text-muted-foreground">
              Reads run unauthenticated and are capped at 60 requests/hour per
              egress IP. Behind the shared Databricks Apps egress IP that budget
              is exhausted quickly and downloads fail — use an authenticated mode
              for anything beyond a quick trial.
            </p>
          )}

          {saveError && (
            <SaveErrorBox>{saveError}</SaveErrorBox>
          )}

          {saved && (
            <SavedNotice>Source read access saved</SavedNotice>
          )}

          <Button type="submit" disabled={saving || !dirty}>
            <Save className="h-4 w-4 mr-2" />
            {saving ? "Saving..." : saved ? "Saved!" : "Save Configuration"}
          </Button>
        </form>
      </CardContent>
    </Card>
  );
}

export function GithubConfigSection() {
  const { data: result } = useGetGithubConfigSuspense(selector());
  const config = result;
  const { mutateAsync: saveConfig } = useUpdateGithubConfig();
  const queryClient = useQueryClient();

  const [repoOwner, setRepoOwner] = useState("");
  const [repoName, setRepoName] = useState("");
  const [authMode, setAuthMode] = useState("");
  const [connectionName, setConnectionName] = useState("");
  // secret_scope / secret_key are part of GithubConfigIn but are NOT
  // surfaced as editable fields in this OAuth-first UI: the OAuth U2M path
  // uses the UC HTTP connection (connection_name), and the secret-PAT path
  // is deferred (backend rejects it). We still round-trip the persisted
  // values on PUT so saving the OAuth fields never NULLs an already-
  // configured secret scope/key — a PUT that omits a field clears it.
  const [secretScope, setSecretScope] = useState("");
  const [secretKey, setSecretKey] = useState("");
  const [initialized, setInitialized] = useState(false);
  const [saving, setSaving] = useState(false);
  const [saved, setSaved] = useState(false);
  const [saveError, setSaveError] = useState<string | null>(null);

  if (config && !initialized) {
    setRepoOwner(config.repo_owner ?? "");
    setRepoName(config.repo_name ?? "");
    setAuthMode(config.auth_mode ?? "");
    setConnectionName(config.connection_name ?? "");
    setSecretScope(config.secret_scope ?? "");
    setSecretKey(config.secret_key ?? "");
    setInitialized(true);
  }

  const dirty =
    initialized &&
    (repoOwner !== (config?.repo_owner ?? "") ||
      repoName !== (config?.repo_name ?? "") ||
      authMode !== (config?.auth_mode ?? "") ||
      connectionName !== (config?.connection_name ?? ""));

  const handleSave = async (e: React.FormEvent) => {
    e.preventDefault();
    setSaving(true);
    setSaveError(null);
    try {
      await saveConfig({
        params: {},
        data: {
          repo_owner: repoOwner,
          repo_name: repoName,
          auth_mode: authMode,
          connection_name: connectionName,
          // Preserved, not surfaced — see the secretScope/secretKey
          // comment above. Omitting these would NULL them server-side.
          secret_scope: secretScope,
          secret_key: secretKey,
        },
      });
      await queryClient.invalidateQueries({ queryKey: getGithubConfigKey() });
      setInitialized(false);
      setSaved(true);
      setTimeout(() => setSaved(false), 2000);
    } catch (err: unknown) {
      const detail = apiErrorMessage(err, "Save failed. GitHub config requires admin access.");
      setSaveError(detail);
    } finally {
      setSaving(false);
    }
  };

  const connectionUnset = !connectionName.trim();

  return (
    <Card className="max-w-4xl">
      <CardHeader>
        <CardTitle>GitHub Publishing</CardTitle>
      </CardHeader>
      <CardContent>
        {connectionUnset && (
          <div className="mb-4 flex items-start gap-2 rounded-md border border-warning/40 bg-warning/5 px-3 py-2 text-xs">
            <AlertTriangle className="h-4 w-4 text-warning shrink-0 mt-0.5" />
            <span className="text-warning">
              GitHub publishing isn't configured yet — an admin must create a
              UC HTTP connection (the <span className="font-mono">github_pr</span>{" "}
              connection) in Catalog Explorer, then enter its name below. See
              the{" "}
              <a
                href={GITHUB_SETUP_GUIDE_URL}
                target="_blank"
                rel="noopener noreferrer"
                className="underline hover:text-foreground"
              >
                GitHub Integration Setup Guide
              </a>
              .
            </span>
          </div>
        )}
        <form onSubmit={handleSave} className="space-y-4">
          <div className="grid grid-cols-2 gap-3">
            <div className="space-y-2">
              <label className="text-sm font-medium" htmlFor="github-repo-owner">
                Repository owner
              </label>
              <Input
                id="github-repo-owner"
                value={repoOwner}
                onChange={(e) => setRepoOwner(e.target.value)}
                placeholder="e.g. databricks-industry-solutions"
              />
            </div>
            <div className="space-y-2">
              <label className="text-sm font-medium" htmlFor="github-repo-name">
                Repository name
              </label>
              <Input
                id="github-repo-name"
                value={repoName}
                onChange={(e) => setRepoName(e.target.value)}
                placeholder="e.g. industry-models"
              />
            </div>
          </div>

          <div className="space-y-2">
            <label className="text-sm font-medium">Auth mode</label>
            <Select value={authMode} onValueChange={setAuthMode}>
              <SelectTrigger className="w-full">
                <SelectValue placeholder="Select auth mode..." />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="oauth_u2m">
                  OAuth U2M (UC HTTP connection)
                </SelectItem>
                <SelectItem value="secret_pat">
                  Personal access token (deferred)
                </SelectItem>
              </SelectContent>
            </Select>
            <p className="text-xs text-muted-foreground">
              OAuth U2M publishes via the UC HTTP connection named below. The
              PAT mode is not yet implemented server-side.
            </p>
          </div>

          <div className="space-y-2">
            <label className="text-sm font-medium" htmlFor="github-connection-name">
              UC connection name
            </label>
            <Input
              id="github-connection-name"
              value={connectionName}
              onChange={(e) => setConnectionName(e.target.value)}
              placeholder="e.g. github_pr"
              className="font-mono"
            />
            <p className="text-xs text-muted-foreground">
              The Unity Catalog HTTP connection used to open pull requests. An
              admin must create this connection in Catalog Explorer first.
            </p>
          </div>

          {saveError && (
            <SaveErrorBox>{saveError}</SaveErrorBox>
          )}

          {saved && (
            <SavedNotice>GitHub configuration saved</SavedNotice>
          )}

          <Button type="submit" disabled={saving || !dirty}>
            <Save className="h-4 w-4 mr-2" />
            {saving ? "Saving..." : saved ? "Saved!" : "Save Configuration"}
          </Button>
        </form>
      </CardContent>
    </Card>
  );
}

interface SectorFormData {
  name: string;
  short_name: string;
  description: string;
  display_order: number;
  is_active: boolean;
}

const emptyForm: SectorFormData = {
  name: "",
  short_name: "",
  description: "",
  display_order: 0,
  is_active: true,
};

export function SectorsSection() {
  const { data: sectors } = useListSectorsSuspense(selector());
  const { mutateAsync: createSec } = useCreateSector();
  const { mutateAsync: updateSec } = useUpdateSector();
  const { mutateAsync: deleteSec } = useDeleteSector();
  const queryClient = useQueryClient();

  const [editingId, setEditingId] = useState<string | null>(null);
  const [creating, setCreating] = useState(false);
  const [form, setForm] = useState<SectorFormData>(emptyForm);
  const [saving, setSaving] = useState(false);

  const runDelete = async (id: string, name: string) => {
    try {
      await deleteSec({ params: { sector_id: id } });
    } catch (err: unknown) {
      notifyError(err, { fallback: `Failed to delete "${name}"` });
      return;
    }
    await invalidateEntityLists(queryClient, "sector");
    toast.success(`Sector "${name}" deleted`);
  };

  const startEdit = (sec: SectorOut) => {
    setEditingId(sec.id);
    setCreating(false);
    setForm({
      name: sec.name,
      short_name: sec.short_name,
      description: sec.description,
      display_order: sec.display_order,
      is_active: sec.is_active,
    });
  };

  const startCreate = () => {
    setCreating(true);
    setEditingId(null);
    setForm({
      ...emptyForm,
      display_order: (sectors ?? []).length,
    });
  };

  const cancel = () => {
    setEditingId(null);
    setCreating(false);
    setForm(emptyForm);
  };

  const handleSave = async () => {
    setSaving(true);
    try {
      if (creating) {
        await createSec({ params: {}, data: form });
      } else if (editingId) {
        await updateSec({ params: { sector_id: editingId }, data: form });
      }
      queryClient.invalidateQueries({ queryKey: listSectorsKey() });
      cancel();
    } finally {
      setSaving(false);
    }
  };

  const activeCount = (sectors ?? []).filter((s) => s.is_active).length;

  return (
    <div className="space-y-4">
      <div className="flex items-center justify-between">
        <span className="text-sm text-muted-foreground">
          {activeCount} active of {(sectors ?? []).length} total
        </span>
        <Button size="sm" onClick={startCreate} disabled={creating}>
          <Plus className="h-4 w-4 mr-1" />
          Add Sector
        </Button>
      </div>

      <SectorsTable
        sectors={sectors ?? []}
        onEdit={startEdit}
        onDelete={runDelete}
      />
      <SectorEditDialog
        open={creating || editingId !== null}
        isCreate={creating}
        form={form}
        setForm={setForm}
        onSave={handleSave}
        onCancel={cancel}
        saving={saving}
      />
    </div>
  );
}

function SectorsTable({
  sectors,
  onEdit,
  onDelete,
}: {
  sectors: SectorOut[];
  onEdit: (sec: SectorOut) => void;
  onDelete: (id: string, name: string) => Promise<void>;
}) {
  const { sorted, sortKey, sortDir, toggle } = useTableSort({
    rows: sectors,
    initialKey: "name",
    initialDir: "asc",
    accessors: {
      display_order: (r: SectorOut) => r.display_order,
      name: (r: SectorOut) => r.name,
      short_name: (r: SectorOut) => r.short_name,
      is_active: (r: SectorOut) => (r.is_active ? 1 : 0),
    },
  });
  return (
    <Table>
      <TableHeader>
        <TableRow>
          <SortableTableHead columnKey="display_order" sortKey={sortKey} sortDir={sortDir} onToggle={toggle} className="w-8">#</SortableTableHead>
          <SortableTableHead columnKey="name" sortKey={sortKey} sortDir={sortDir} onToggle={toggle}>Name</SortableTableHead>
          <SortableTableHead columnKey="short_name" sortKey={sortKey} sortDir={sortDir} onToggle={toggle}>Short Name</SortableTableHead>
          <SortableTableHead columnKey="is_active" sortKey={sortKey} sortDir={sortDir} onToggle={toggle} className="text-center">Active</SortableTableHead>
          <TableHead className="w-24" />
        </TableRow>
      </TableHeader>
      <TableBody>
        {sorted.map((sec) => (
            <TableRow
              key={sec.id}
              className={!sec.is_active ? "opacity-50" : ""}
            >
              <TableCell className="text-muted-foreground text-xs">
                {sec.display_order}
              </TableCell>
              <TableCell>
                <TooltipProvider delayDuration={200}>
                  <Tooltip>
                    <TooltipTrigger asChild>
                      <span className="font-medium cursor-help">{sec.name}</span>
                    </TooltipTrigger>
                    {sec.description && (
                      <TooltipContent className="max-w-sm text-xs">
                        {sec.description}
                      </TooltipContent>
                    )}
                  </Tooltip>
                </TooltipProvider>
              </TableCell>
              <TableCell className="font-mono text-sm">
                {sec.short_name}
              </TableCell>
              <TableCell className="text-center">
                {sec.is_active ? (
                  <Check className="h-4 w-4 text-green-500 mx-auto" />
                ) : (
                  <X className="h-4 w-4 text-muted-foreground mx-auto" />
                )}
              </TableCell>
              <TableCell>
                <div className="flex items-center gap-1">
                  <Button
                    variant="ghost"
                    size="icon"
                    className="h-7 w-7"
                    onClick={() => onEdit(sec)}
                    title="Edit sector"
                  >
                    <Pencil className="h-3.5 w-3.5" />
                  </Button>
                  <DeleteSectorButton
                    id={sec.id}
                    name={sec.name}
                    onDelete={onDelete}
                  />
                </div>
              </TableCell>
            </TableRow>
          ))}
        {sectors.length === 0 && (
          <TableRow>
            <TableCell
              colSpan={5}
              className="text-center text-muted-foreground py-8"
            >
              No sectors configured. Click "Add Sector" to create one.
            </TableCell>
          </TableRow>
        )}
      </TableBody>
    </Table>
  );
}

function SectorEditDialog({
  open,
  isCreate,
  form,
  setForm,
  onSave,
  onCancel,
  saving,
}: {
  open: boolean;
  isCreate: boolean;
  form: SectorFormData;
  setForm: React.Dispatch<React.SetStateAction<SectorFormData>>;
  onSave: () => void;
  onCancel: () => void;
  saving: boolean;
}) {
  return (
    <Dialog open={open} onOpenChange={(v) => { if (!v) onCancel(); }}>
      <DialogContent className="sm:max-w-lg">
        <DialogHeader>
          <DialogTitle>
            {isCreate ? "New sector" : "Edit sector"}
          </DialogTitle>
        </DialogHeader>
        <div className="space-y-4 py-2">
          <div className="grid grid-cols-3 gap-3">
            <div className="col-span-1 space-y-1">
              <label className="text-xs font-medium text-muted-foreground">
                Display order
              </label>
              <Input
                type="number"
                value={form.display_order}
                onChange={(e) =>
                  setForm((f) => ({ ...f, display_order: Number(e.target.value) }))
                }
              />
            </div>
            <div className="col-span-2 space-y-1">
              <label className="text-xs font-medium text-muted-foreground">
                Short name
              </label>
              <Input
                className="font-mono"
                value={form.short_name}
                onChange={(e) =>
                  setForm((f) => ({ ...f, short_name: e.target.value }))
                }
                placeholder="short_name"
                required
              />
            </div>
          </div>
          <div className="space-y-1">
            <label className="text-xs font-medium text-muted-foreground">
              Name
            </label>
            <Input
              value={form.name}
              onChange={(e) => setForm((f) => ({ ...f, name: e.target.value }))}
              placeholder="Sector name"
              required
            />
          </div>
          <div className="space-y-1">
            <label className="text-xs font-medium text-muted-foreground">
              Description
            </label>
            <Textarea
              value={form.description}
              onChange={(e) =>
                setForm((f) => ({ ...f, description: e.target.value }))
              }
              placeholder="Sector description"
              rows={5}
            />
          </div>
          <label className="flex items-center gap-2 text-sm">
            <Checkbox
              checked={form.is_active}
              onCheckedChange={(v) =>
                setForm((f) => ({ ...f, is_active: v === true }))
              }
            />
            Active (visible in business / industry creation)
          </label>
        </div>
        <DialogFooter>
          <Button variant="outline" onClick={onCancel}>
            Cancel
          </Button>
          <Button
            onClick={onSave}
            disabled={!form.name || !form.short_name || saving}
          >
            {saving ? "Saving…" : isCreate ? "Create" : "Save"}
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
}

function DeleteSectorButton({
  id,
  name,
  onDelete,
}: {
  id: string;
  name: string;
  onDelete: (id: string, name: string) => Promise<void>;
}) {
  const [open, setOpen] = useState(false);
  return (
    <>
      <Button
        variant="ghost"
        size="icon"
        className="h-7 w-7 text-muted-foreground hover:text-destructive"
        onClick={() => setOpen(true)}
        title="Delete sector"
      >
        <Trash2 className="h-3.5 w-3.5" />
      </Button>

      <AlertDialog open={open} onOpenChange={setOpen}>
        <AlertDialogContent>
          <AlertDialogHeader>
            <AlertDialogTitle>Delete "{name}"?</AlertDialogTitle>
            <AlertDialogDescription>
              This removes the sector from the catalog. Any business or industry
              currently referencing it must be reassigned first — the server
              will reject the delete otherwise.
            </AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter>
            <AlertDialogCancel>Cancel</AlertDialogCancel>
            <AlertDialogAction
              onClick={() => onDelete(id, name)}
              className="bg-destructive text-destructive-foreground hover:bg-destructive/90"
            >
              Delete
            </AlertDialogAction>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>
    </>
  );
}
