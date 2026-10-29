import { createFileRoute, Link } from "@tanstack/react-router";
import { Suspense, useMemo, useState } from "react";
import {
  useGetBusinessSuspense,
  useGetRunSuspense,
  useListRunOperations,
  cancelRunWithRollback,
  retryRun,
  resumeRun,
  ApiError,
  type RunOperationOut,
  type RunOut,
} from "@/lib/api";
import { notifyError } from "@/lib/notify";
import { selector } from "@/lib/selector";
import { useBreadcrumbs } from "@/components/explorer/breadcrumb-context";
import { formatDateTime, formatElapsedSeconds } from "@/lib/date";
import { ORPHAN_DROP_RUN_INTENT, canRetryRunIntent, intentLabel, isSetupRunIntent } from "@/lib/intent";
import { RunSchemaDropsCard } from "@/components/runs/run-schema-drops-card";
import { RunWarningsCard } from "@/components/runs/run-warnings-card";
import { useInvalidateOnRunTerminal } from "@/lib/hooks";
import { isTerminalRunStatus } from "@/lib/run-status";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Progress } from "@/components/ui/progress";
import { Skeleton } from "@/components/ui/skeleton";
import { Tabs, TabsList, TabsTrigger, TabsContent } from "@/components/ui/tabs";
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
import { ArrowLeft, Clock, CheckCircle, XCircle, Loader2, RotateCcw, Square, AlertTriangle, ExternalLink, ChevronRight, PlayCircle } from "lucide-react";
import { useQueryClient } from "@tanstack/react-query";
import { toast } from "sonner";
import { RunHierarchyPipeline } from "@/components/runs/run-hierarchy-pipeline";
import { ArtifactsTab } from "@/components/artifacts/artifacts-tab";
import { WhatYouSubmitted } from "@/components/runs/what-you-submitted";
import { joinCommaList } from "@/lib/comma-list";
import { parseRunVibeScope } from "@/lib/vibe-scope";

import { LineageCard } from "@/components/lineage/lineage-card";
import { RunReportCard } from "@/components/runs/run-report-card";
import { FailedInstallActions } from "@/components/runs/failed-install-actions";
import { RunChangesCard } from "@/components/runs/run-changes-card";

export const Route = createFileRoute("/_sidebar/businesses/$businessId/runs/$runId")({
  component: () => {
    const { businessId, runId } = Route.useParams();
    return (
      <div className="p-6 space-y-6">
        <Suspense fallback={<Skeleton className="h-64 w-full" />}>
          <RunDetail businessId={businessId} runId={runId} />
        </Suspense>
      </div>
    );
  },
  errorComponent: RunDetailError,
});

// Renders a 404-friendly card when the run query rejects. The most common
// case is a wrong-business URL (BE's `get_run_in_business` ownership guard
// returns 404 for a runId that exists but belongs to another business);
// other 4xx/5xx surface the same shell with a less-specific copy and the
// underlying detail line.
function RunDetailError({ error }: { error: Error }) {
  const { businessId } = Route.useParams();
  const status = error instanceof ApiError ? error.status : 0;
  const isNotFound = status === 404;
  const title = isNotFound
    ? "Run not found in this business."
    : "Couldn't load this run.";
  const detail = isNotFound
    ? "It may belong to a different business, or it has been deleted. Use the runs list to find runs that belong here."
    : error instanceof Error
      ? error.message
      : "Unexpected error.";
  return (
    <div className="p-6 space-y-4">
      <h1 className="text-2xl font-semibold tracking-tight">{title}</h1>
      <p className="text-sm text-muted-foreground">{detail}</p>
      <Button asChild>
        <Link to="/businesses/$businessId/runs" params={{ businessId }}>
          <ArrowLeft className="h-4 w-4 mr-2" />
          Back to runs
        </Link>
      </Button>
    </div>
  );
}

const statusConfig: Record<string, { icon: React.ReactNode; variant: "default" | "secondary" | "destructive" | "outline" }> = {
  pending: { icon: <Clock className="h-3 w-3" />, variant: "outline" },
  running: { icon: <Loader2 className="h-3 w-3 animate-spin" />, variant: "default" },
  stale: { icon: <AlertTriangle className="h-3 w-3" />, variant: "destructive" },
  completed: { icon: <CheckCircle className="h-3 w-3" />, variant: "secondary" },
  failed: { icon: <XCircle className="h-3 w-3" />, variant: "destructive" },
  cancelled: { icon: <XCircle className="h-3 w-3" />, variant: "outline" },
  // #118: Cancel-with-rollback halted on a reverse-op failure. Treated as
  // destructive so the banner is visually aligned with the manual-cleanup
  // message shown below.
  rolled_back_failed: { icon: <AlertTriangle className="h-3 w-3" />, variant: "destructive" },
};

// Matches RunStatus on the backend. `rolled_back_failed` + `failed` +
// `cancelled` + `stale` are treated as "failure-ish" for the Retry button
// (already in the codebase) — Resume is narrower and only applies to
// unified-pipeline runs.
const UNIFIED_PHASE_LABELS: Record<string, string> = {
  ecm: "Phase 1: Generate ECM",
  mvm: "Phase 2: Shrink to MVM",
};

function parseRunParameters(run: RunOut): Record<string, unknown> {
  if (!run.parameters_json) return {};
  try {
    const v = JSON.parse(run.parameters_json);
    return typeof v === "object" && v !== null ? (v as Record<string, unknown>) : {};
  } catch {
    return {};
  }
}

// Exported for unit tests — renders the run toolbar, cancel/resume dialogs,
// and overview/artifacts tabs for a single run.
export function RunDetail({ businessId, runId }: { businessId: string; runId: string }) {
  // Poll the run endpoint while the run is still in a non-terminal state so
  // the page picks up progress_message / progress_percent updates without the
  // user having to reload. Once the run reaches a terminal state (completed /
  // failed / cancelled / rolled_back_failed) we stop polling to avoid
  // unnecessary traffic. Merge the `select` function from selector() with
  // the refetchInterval so the axios envelope still gets unwrapped.
  const { data: rawRun } = useGetRunSuspense({
    params: { business_id: businessId, run_id: runId },
    query: {
      ...selector().query,
      refetchInterval: (query: { state: { data?: { data?: { status?: string } } } }) => {
        const s = query.state.data?.data?.status;
        return s && isTerminalRunStatus(s) ? false : 5000;
      },
      // Keep polling even when the tab is backgrounded so the user doesn't
      // have to refresh to see a status change (running → stale / failed /
      // completed) they missed while another tab was focused. The default
      // TanStack Query behaviour pauses `refetchInterval` in background
      // tabs; for a long-running agent pipeline that behaviour means the
      // stale banner + terminal-state badges lag behind reality until the
      // window regains focus.
      refetchIntervalInBackground: true,
    },
  });
  // The select helper's generic inference gets lost when it's combined with
  // the refetchInterval option above — cast here so the rest of the render
  // tree stays typed.
  const run = rawRun as RunOut;
  const cfg = statusConfig[run.status] || statusConfig.pending;
  // Shares the react-query cache key with RunHierarchyPipeline's own
  // useListRunOperations call below (fetched once, read by both). Feeds
  // WhatYouSubmitted's "Dispatched widgets" section.
  const { data: operationsData } = useListRunOperations({
    params: { business_id: businessId, run_id: runId },
  });
  const operations: RunOperationOut[] = Array.isArray(operationsData?.data)
    ? operationsData.data
    : [];
  const { data: business } = useGetBusinessSuspense({
    params: { business_id: businessId },
    ...selector(),
  });
  useBreadcrumbs([
    { label: business.name, to: "/businesses/$businessId", params: { businessId } },
    { label: "Runs", to: "/businesses/$businessId/runs", params: { businessId } },
    { label: `${intentLabel(run.intent)} run` },
  ]);
  const queryClient = useQueryClient();
  // A run that finishes on its own produced versions other pages cached; the
  // cancel/retry/resume handlers invalidate themselves.
  useInvalidateOnRunTerminal(run.status, runId);
  const [acting, setActing] = useState(false);
  const [tab, setTab] = useState<"overview" | "artifacts">("overview");
  const [resumeOpen, setResumeOpen] = useState(false);
  const [cancelOpen, setCancelOpen] = useState(false);

  // Parse once per render — both the Resume button (visibility gate) and
  // the Cancel dialog (wording) read `ecm_mvm_unified` + `ecm_mvm_phase`
  // from here.
  const runParams = useMemo(() => parseRunParameters(run), [run]);
  const isUnifiedPipeline = runParams["ecm_mvm_unified"] === true;
  const vibeScopeInfo = useMemo(() => parseRunVibeScope(runParams), [runParams]);
  const currentPhaseKey = typeof runParams["ecm_mvm_phase"] === "string"
    ? (runParams["ecm_mvm_phase"] as string)
    : "";
  const currentPhaseLabel = UNIFIED_PHASE_LABELS[currentPhaseKey] || currentPhaseKey;

  const handleCancelWithRollback = async () => {
    setActing(true);
    try {
      const { data } = await cancelRunWithRollback({
        business_id: businessId,
        run_id: runId,
      });
      if (data?.ok === false) {
        notifyError(
          `Rollback halted - manual cleanup required.${
            typeof data?.status === "string" ? ` Status: ${data.status}` : ""
          }`,
        );
      } else {
        const applied = Array.isArray(data?.ops_applied) ? data.ops_applied.length : 0;
        toast.success(
          applied > 0
            ? `Cancelled — rolled back ${applied} step${applied === 1 ? "" : "s"}.`
            : "Cancelled."
        );
      }
      queryClient.invalidateQueries();
    } catch (err) {
      notifyError(err, { title: "Cancel-with-rollback failed" });
    } finally {
      setActing(false);
      setCancelOpen(false);
    }
  };

  const handleRetry = async () => {
    setActing(true);
    try {
      await retryRun({ business_id: businessId, run_id: runId });
      queryClient.invalidateQueries();
      toast.success("Retry started.");
    } catch (err) {
      notifyError(err, { title: "Retry failed" });
    } finally {
      setActing(false);
    }
  };

  const handleResume = async () => {
    setActing(true);
    try {
      const { data } = await resumeRun({
        business_id: businessId,
        run_id: runId,
      });
      if (data?.ok === false) {
        const errMsg = typeof data?.error === "string" ? data.error : "Dispatcher declined to resume";
        notifyError(errMsg);
      } else {
        const nextPhase = typeof data?.next_phase === "string" ? data.next_phase : "";
        const label = UNIFIED_PHASE_LABELS[nextPhase] || nextPhase || "next phase";
        toast.success(`Resuming — ${label}`);
      }
      queryClient.invalidateQueries();
    } catch (err) {
      notifyError(err, { fallback: "Failed to resume run" });
    } finally {
      setActing(false);
      setResumeOpen(false);
    }
  };

  const setupRun = isSetupRunIntent(run.intent);
  const showResume = isUnifiedPipeline
    && ["failed", "cancelled", "stale"].includes(run.status);

  return (
    <>
      <div className="flex items-center gap-4">
        <Button variant="ghost" size="icon" asChild title="Back to business runs">
          <Link to="/businesses/$businessId/runs" params={{ businessId }}>
            <ArrowLeft className="h-4 w-4" />
          </Link>
        </Button>
        {/* Phase 5 (orchestrator refactor §8): runs surface a
            canonical ``Intent`` slug; the human-friendly label
            comes from ``intentLabel``. */}
        <h1 className="text-2xl font-semibold tracking-tight">Run: {intentLabel(run.intent)}</h1>
        <Badge variant={cfg.variant} className="flex items-center gap-1">
          {cfg.icon}
          {run.status}
        </Badge>
        <WatchdogBadge state={run.watchdog_state} warmUpRemaining={run.watchdog_warm_up_seconds_remaining} />
        {vibeScopeInfo.dryRun && (
          <Badge variant="outline" data-testid="run-dry-run-badge">Dry Run</Badge>
        )}
        {vibeScopeInfo.scopeDomains && (
          <Badge variant="outline" data-testid="run-scope-badge">
            Scope: {joinCommaList(vibeScopeInfo.scopeDomains) || "some domains"}
          </Badge>
        )}
        <div className="flex-1" />
        {/* D-09: Cancel is visible whenever the run is `running` or
            `stale`. A setup run (kickstart, download, orphan-schema drop)
            works inside the app with no agent job: cancelling only marks the
            run cancelled, which frees the business when its work died (e.g.
            an app restart). */}
        {(run.status === "running" || run.status === "stale") && (
          <Button
            variant="destructive"
            size="sm"
            onClick={() => setCancelOpen(true)}
            disabled={acting}
            data-testid="cancel-run"
          >
            <Square className="h-4 w-4 mr-2" />
            {setupRun ? "Mark as cancelled" : "Cancel"}
          </Button>
        )}
        {showResume && (
          <Button
            variant="default"
            size="sm"
            onClick={() => setResumeOpen(true)}
            disabled={acting}
            title="Re-dispatch the failed phase on this same run"
          >
            <PlayCircle className="h-4 w-4 mr-2" />
            Resume
          </Button>
        )}
        {(run.status === "failed" || run.status === "cancelled") && canRetryRunIntent(run.intent) && (
          <Button variant="outline" size="sm" onClick={handleRetry} disabled={acting}>
            <RotateCcw className="h-4 w-4 mr-2" />
            Retry
          </Button>
        )}
      </div>

      {/* Resume confirmation — admin-recovery action that re-dispatches the
          failed phase on the same run. Destructive side-effects from the
          previous attempt (half-installed UC schemas, half-synced rows) are
          NOT cleaned up — the warning copy pushes the user to Cancel+Rollback
          first if that's what they want. */}
      <AlertDialog open={resumeOpen} onOpenChange={setResumeOpen}>
        <AlertDialogContent>
          <AlertDialogHeader>
            <AlertDialogTitle>Resume from failed phase?</AlertDialogTitle>
            <AlertDialogDescription asChild>
              <div className="space-y-2">
                <p>
                  Re-dispatches <span className="font-medium">{currentPhaseLabel || "the failed phase"}</span>{" "}
                  on this same run.
                </p>
                <p className="text-warning">
                  Resume does <span className="font-semibold">not</span> clean up
                  partial side-effects from the previous attempt (half-installed UC
                  schemas, half-synced Lakebase rows). If you want a clean slate,
                  Cancel + Rollback the run first, then launch a fresh one.
                </p>
              </div>
            </AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter>
            <AlertDialogCancel disabled={acting}>Cancel</AlertDialogCancel>
            <AlertDialogAction onClick={handleResume} disabled={acting}>
              {acting ? "Resuming..." : "Resume"}
            </AlertDialogAction>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>

      {/* Cancel dialog — single action, always rolls back. v0.4.0 #2b
          made cascade-rollback reliable across cataloging styles, so the
          non-rollback "just cancel" variant is gone: every cancel cleans
          up partial UC schemas + Lakebase rows + ModelVersion rows the
          run created. The handler logs a rollback-halted error toast if
          a reverse-op fails (orphan-schema state); the run still ends
          up cancelled in either case. */}
      <AlertDialog open={cancelOpen} onOpenChange={setCancelOpen}>
        <AlertDialogContent>
          <AlertDialogHeader>
            <AlertDialogTitle>{setupRun ? "Mark this setup run as cancelled?" : "Cancel run?"}</AlertDialogTitle>
            <AlertDialogDescription data-testid="cancel-run-copy">
              {setupRun
                ? "This setup run works inside the app and has no Databricks job. Marking it cancelled frees the business for other runs. It does not stop a step that is still going or undo what was done; if a step is still going, the run shows its own result when it ends."
                : "Any partial work will be rolled back, and the run marked as canceled."}
            </AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter>
            <AlertDialogCancel disabled={acting}>Keep running</AlertDialogCancel>
            <AlertDialogAction
              onClick={handleCancelWithRollback}
              disabled={acting}
              className="bg-destructive text-destructive-foreground hover:bg-destructive/90"
            >
              {acting ? "Cancelling..." : setupRun ? "Mark as cancelled" : "Cancel run"}
            </AlertDialogAction>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>

      <Tabs value={tab} onValueChange={(v) => setTab(v as "overview" | "artifacts")}>
        <TabsList>
          <TabsTrigger value="overview">Overview</TabsTrigger>
          <TabsTrigger value="artifacts">Artifacts</TabsTrigger>
        </TabsList>

        <TabsContent value="overview" className="space-y-6">
          {run.intent === ORPHAN_DROP_RUN_INTENT && (
            <RunSchemaDropsCard businessId={businessId} runId={runId} active={run.status === "running"} />
          )}
          {/* #118: rolled_back_failed — one of the rollback reverse-ops threw.
              Surface a prominent manual-cleanup banner with the recorded
              failure message so the operator knows to chase residual state
              (orphan UC schemas, half-cleared Lakebase rows). */}
          {run.status === "rolled_back_failed" && (
            <Card className="border-destructive/60 bg-destructive/5">
              <CardContent className="py-4 flex items-start gap-3">
                <AlertTriangle className="h-5 w-5 text-destructive shrink-0 mt-0.5" />
                <div className="flex-1 space-y-1 text-sm">
                  <p className="font-medium text-destructive">
                    Rollback halted — manual cleanup required
                  </p>
                  <p className="text-muted-foreground">
                    A reverse-operation failed during cancel-with-rollback. The
                    run is marked <span className="font-mono">rolled_back_failed</span>{" "}
                    — subsequent rollback steps were skipped. Check the Error
                    section below for details, then drop any orphan UC schemas
                    or Lakebase rows by hand.
                  </p>
                </div>
              </CardContent>
            </Card>
          )}

          <RunWarningsCard warnings={run.warnings} />

          {/* Stale warning — the polling loop hasn't seen progress for a while,
              or the Databricks job itself may have crashed. Pushes the user to
              the Databricks run page for diagnosis. */}
          {run.status === "stale" && (
            <Card className="border-warning/40 bg-warning/5">
              <CardContent className="py-4 flex items-start gap-3">
                <AlertTriangle className="h-5 w-5 text-warning shrink-0 mt-0.5" />
                <div className="flex-1 space-y-1 text-sm">
                  <p className="font-medium text-warning">
                    No progress updates recently
                  </p>
                  <p className="text-muted-foreground">
                    The vibe job is still running, but no progress reported for 10+
                    minutes. This can just be a long step — check progress below,
                    and open the Databricks run if you want to check it.
                  </p>
                  <p className="text-muted-foreground">
                    I recommend you wait, we'll warn you if the job fails.
                  </p>
                </div>
                {run.run_page_url && (
                  <Button variant="outline" size="sm" asChild>
                    <a
                      href={run.run_page_url}
                      target="_blank"
                      rel="noopener noreferrer"
                    >
                      <ExternalLink className="h-3.5 w-3.5 mr-1.5" />
                      Databricks run
                    </a>
                  </Button>
                )}
              </CardContent>
            </Card>
          )}

          {/* Run metadata — compact single-line strip above progress. Fields
              wrap to a second line on narrow viewports. */}
          <Card>
            <CardContent className="flex flex-wrap items-center gap-x-6 gap-y-2 text-sm pt-6">
              <div className="flex items-center gap-2">
                <span className="text-muted-foreground">Run ID</span>
                <span className="font-mono text-xs select-all">{run.id}</span>
              </div>
              {/* Per-Phase Databricks job-run links live on the
                  hierarchical pipeline below — each Phase dispatches
                  its own job, so a single Run-level link is misleading
                  for multi-Phase runs. */}
              <div className="flex items-center gap-2">
                <span className="text-muted-foreground">Started</span>
                <span>{formatDateTime(run.started_at)}</span>
              </div>
              <div className="flex items-center gap-2">
                <span className="text-muted-foreground">Completed</span>
                <span>{formatDateTime(run.completed_at)}</span>
              </div>
            </CardContent>
          </Card>

          {/* Overall progress bar */}
          <Card>
            <CardContent className="space-y-3 pt-6">
              <div className="flex items-center justify-between text-sm">
                <span className="text-muted-foreground">
                  {(() => {
                    // Once the run reaches a terminal state, the
                    // backend's last in-flight progress_message
                    // ("Running — Phase 2/2, 100%") becomes stale —
                    // its "Running — " prefix contradicts the run
                    // status badge. Render a status-appropriate
                    // line instead.
                    if (isTerminalRunStatus(run.status)) {
                      if (run.status === "completed") return "Done";
                      if (run.status === "failed") return run.error_message || "Failed";
                      if (run.status === "cancelled") return "Cancelled";
                      if (run.status === "rolled_back_failed") return "Rolled back (with failure)";
                    }
                    return run.progress_message || "Waiting for updates...";
                  })()}
                </span>
                <span className="font-medium">{run.progress_percent}%</span>
              </div>
              <Progress value={run.progress_percent} />
              {/* D-09 watchdog detail strip — elapsed time, last Jobs API
                  state, and any current poll error. Plain text per
                  contract; the destructive class only fires when there
                  is an actual poll error to render. */}
              <div className="flex flex-wrap items-center gap-x-6 gap-y-1 text-xs text-muted-foreground pt-1">
                <span>
                  Elapsed:{" "}
                  <span className="font-mono text-foreground">
                    {formatElapsedSeconds(run.elapsed_seconds ?? 0)}
                  </span>
                </span>
                {run.last_jobs_api_state && (
                  <span>
                    Jobs API:{" "}
                    <span className="font-mono text-foreground">
                      {run.last_jobs_api_state}
                    </span>
                  </span>
                )}
                {run.last_poll_error && (
                  <span className="text-destructive break-all">
                    Last poll error:{" "}
                    <span className="font-mono">{run.last_poll_error}</span>
                  </span>
                )}
              </div>
            </CardContent>
          </Card>

          <LineageCard runId={runId} businessId={businessId} runStatus={run.status} />

          <RunReportCard businessId={businessId} runId={runId} runStatus={run.status} />

          <RunChangesCard businessId={businessId} runId={runId} runStatus={run.status} operations={operations} />

          {run.intent === "install" && ["failed", "cancelled", "rolled_back_failed"].includes(run.status) && (
            <FailedInstallActions
              businessId={businessId}
              run={run}
              runParams={runParams}
              operations={operations}
            />
          )}

          {/* Unified hierarchical pipeline tree — one row per Phase (DAG node)
              with Steps (agent stages) nested inside each. Replaces the two
              decoupled cards ("Pipeline Steps" + "Pipeline Progress"). */}
          <Suspense fallback={<Skeleton className="h-48 w-full" />}>
            <RunHierarchyPipeline
              businessId={businessId}
              runId={runId}
              status={run.status}
              progressPercent={run.progress_percent ?? 0}
              runTerminalAtMs={
                isTerminalRunStatus(run.status) && run.completed_at
                  ? new Date(run.completed_at).getTime()
                  : null
              }
            />
          </Suspense>

          {run.error_message && (
            <Card className="border-destructive/40 bg-destructive/5">
              <CardHeader className="flex flex-row items-center justify-between gap-2 space-y-0">
                <CardTitle className="text-destructive flex items-center gap-2">
                  <XCircle className="h-5 w-5" />
                  Error
                </CardTitle>
                {run.run_page_url && (
                  <Button variant="outline" size="sm" asChild>
                    <a
                      href={run.run_page_url}
                      target="_blank"
                      rel="noopener noreferrer"
                    >
                      <ExternalLink className="h-3.5 w-3.5 mr-1.5" />
                      Open in Databricks
                    </a>
                  </Button>
                )}
              </CardHeader>
              <CardContent>
                <pre className="text-sm text-destructive whitespace-pre-wrap break-words">
                  {run.error_message}
                </pre>
              </CardContent>
            </Card>
          )}

          <WhatYouSubmitted run={run} operations={operations} />

          {run.parameters_json && (
            <details className="group">
              <summary className="cursor-pointer list-none">
                <Card className="hover:bg-muted/20 transition-colors">
                  <CardHeader className="flex flex-row items-center justify-between gap-2 space-y-0 py-3">
                    <CardTitle className="text-sm font-medium text-muted-foreground">
                      Run configuration
                    </CardTitle>
                    <ChevronRight className="h-4 w-4 text-muted-foreground transition-transform group-open:rotate-90" />
                  </CardHeader>
                </Card>
              </summary>
              <Card className="rounded-t-none border-t-0">
                <CardContent className="pt-4">
                  <pre className="text-sm text-muted-foreground whitespace-pre-wrap">
                    {JSON.stringify(JSON.parse(run.parameters_json), null, 2)}
                  </pre>
                </CardContent>
              </Card>
            </details>
          )}
        </TabsContent>

        <TabsContent value="artifacts" className="space-y-6">
          <ArtifactsTab businessId={businessId} runId={runId} />
        </TabsContent>
      </Tabs>
    </>
  );
}
function WatchdogBadge({
  state,
  warmUpRemaining,
}: {
  state?: string;
  warmUpRemaining?: number;
}) {
  if (!state) return null;
  let label = "";
  let variant: "default" | "secondary" | "destructive" | "outline" = "outline";
  switch (state) {
    case "warming_up": {
      const secs = Math.max(0, warmUpRemaining ?? 0);
      // Keep the leading word "Warming up" intact so the count doesn't
      // break a screen reader at a sentence boundary.
      label = `Warming up (${secs}s)`;
      variant = "outline";
      break;
    }
    case "armed":
      label = "Active";
      variant = "secondary";
      break;
    case "tripped_stale":
      label = "Stale";
      variant = "destructive";
      break;
    case "tripped_failed":
      label = "Failed";
      variant = "destructive";
      break;
    case "disarmed":
      label = "Done";
      variant = "outline";
      break;
    default:
      return null;
  }
  return (
    <Badge variant={variant} className="text-[10px]" data-testid="watchdog-badge">
      {label}
    </Badge>
  );
}
