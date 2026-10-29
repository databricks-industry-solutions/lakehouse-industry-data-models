import { useState } from "react";
import { useQueryClient } from "@tanstack/react-query";
import { toast } from "sonner";
import { Button } from "@/components/ui/button";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import {
  cancelAssessment,
  cancelAssessmentDomainRun,
  getAssessmentKey,
  useGetBusinessSuspense,
  listAssessmentsKey,
  useGetAssessmentSuspense,
  type AssessBatchOut,
  type AssessDomainRunOut,
  type BusinessOut,
} from "@/lib/api";
import {
  ADMIN_HELP_LEAD_INGEST,
  isIngestRetrying,
  isRelaunchable,
  isTerminal,
  runAdminHelp,
  useAssessReady,
} from "@/lib/assessment";
import { parseAdminHelp, type AdminHelp } from "@/lib/api-error";
import { formatDateTime } from "@/lib/date";
import { notifyError } from "@/lib/notify";
import { useBreadcrumbs } from "@/components/explorer/breadcrumb-context";
import { selector } from "@/lib/selector";
import { AdminHelpBlock } from "./admin-help-block";
import { FeatureNotReady } from "@/components/feature-gate";
import { DomainResults } from "./domain-results";
import { ReadinessPanel } from "./readiness-panel";
import { useRelaunch } from "./use-relaunch";
import { DomainRunRow } from "./domain-run-row";
import { StatusBadge } from "./status-badge";

const POLL_MS = 20000;

/**
 * A domain's results tab: the review UI once finished, a status-appropriate message before that.
 * A failed or results-invalid run shows only the admin-help block (an invalid run has no result rows).
 */
function RunResults({ run, feedbackTarget }: { run: AssessDomainRunOut; feedbackTarget?: { businessId: string; version: number; scope: string } }) {
  if (run.status === "completed") {
    return <DomainResults domainRunId={run.id} feedbackTarget={feedbackTarget} />;
  }
  if (run.status === "results_invalid") {
    return <AdminHelpBlock help={runAdminHelp(run)} testId={`run-admin-help-${run.id}`} lead={ADMIN_HELP_LEAD_INGEST} />;
  }
  if (run.status === "failed") {
    return <AdminHelpBlock help={runAdminHelp(run)} testId={`run-admin-help-${run.id}`} />;
  }
  if (run.status === "cancelled") {
    return <p className="text-sm text-muted-foreground">No results are available for this run.</p>;
  }
  return <p>Results appear when the run completes.</p>;
}

/** Batch status page body: header, per-domain status rows (polled while any run is live), per-domain result tabs. */
export function BatchStatus({ businessId, batchId }: { businessId: string; batchId: string }) {
  const queryClient = useQueryClient();
  const { data: batch } = useGetAssessmentSuspense<AssessBatchOut>({
    params: { batch_id: batchId },
    query: {
      select: (res) => res.data,
      refetchInterval: (q) =>
        q.state.data?.data.domain_runs.some((r) => !isTerminal(r.status)) ? POLL_MS : false,
    },
  });
  const { data: business } = useGetBusinessSuspense({ params: { business_id: businessId }, ...selector<BusinessOut>() });
  const [cancelling, setCancelling] = useState<Set<string>>(new Set());
  const [cancellingAll, setCancellingAll] = useState(false);
  const [cancelHelp, setCancelHelp] = useState<AdminHelp | null>(null);
  const { relaunch, pending: relaunching, blocked, help: relaunchHelp } = useRelaunch(businessId, batchId);
  const { ready } = useAssessReady();

  useBreadcrumbs([
    { label: business.name, to: "/businesses/$businessId", params: { businessId } },
    { label: "Assessments", to: "/businesses/$businessId/assessments", params: { businessId } },
    { label: `v${batch.version} ${batch.scope}` },
  ]);

  const refresh = () => {
    queryClient.invalidateQueries({ queryKey: getAssessmentKey({ batch_id: batchId }) });
    queryClient.invalidateQueries({ queryKey: listAssessmentsKey({ business_id: businessId }) });
  };

  // A cancel Databricks refused carries the admin-help detail; anything else toasts.
  const surfaceCancelError = (err: unknown, fallback: string) => {
    const help = parseAdminHelp(err);
    if (help) setCancelHelp(help);
    else notifyError(err, { fallback });
  };

  const onCancelRun = async (domainRunId: string) => {
    setCancelling((prev) => new Set(prev).add(domainRunId));
    setCancelHelp(null);
    try {
      await cancelAssessmentDomainRun({ domain_run_id: domainRunId });
      toast.success("Cancel requested");
      refresh();
    } catch (err) {
      surfaceCancelError(err, "Couldn't cancel the domain run");
    } finally {
      setCancelling((prev) => {
        const next = new Set(prev);
        next.delete(domainRunId);
        return next;
      });
    }
  };
  const onCancelAll = async () => {
    setCancellingAll(true);
    setCancelHelp(null);
    try {
      await cancelAssessment({ batch_id: batchId });
      toast.success("Cancel requested");
      refresh();
    } catch (err) {
      surfaceCancelError(err, "Couldn't cancel the assessment");
    } finally {
      setCancellingAll(false);
    }
  };

  const runs = batch.domain_runs;
  const anyRelaunchable = runs.some((r) => isRelaunchable(r.status));
  const relaunchable = ready ? runs.filter((r) => isRelaunchable(r.status)) : [];
  return (
    <div className="p-6 space-y-6">
      <div className="flex items-start justify-between">
        <div className="space-y-1">
          <h1 className="text-2xl font-semibold tracking-tight">
            Assessment · v{batch.version} {batch.scope}
          </h1>
          <p className="text-sm text-muted-foreground">
            {batch.output_model} · {batch.etl_type} · reasoning {batch.reasoning_effort} · started{" "}
            {formatDateTime(batch.created_at)} by {batch.created_by}
          </p>
        </div>
        <div className="flex items-center gap-2">
          <StatusBadge status={batch.status} />
          {relaunchable.length > 0 && (
            <Button variant="outline" onClick={() => relaunch()} disabled={relaunching}>
              Relaunch failed ({relaunchable.length})
            </Button>
          )}
          {runs.some((r) => !isTerminal(r.status) && !isIngestRetrying(r)) && (
            <Button variant="outline" onClick={onCancelAll} disabled={cancellingAll}>
              Cancel all
            </Button>
          )}
        </div>
      </div>
      {blocked && (
        <div className="space-y-2">
          <p className="text-sm text-destructive">{blocked.message}</p>
          <ReadinessPanel readiness={blocked.readiness} />
        </div>
      )}
      {!ready && anyRelaunchable && <FeatureNotReady feature="assessment" />}
      {relaunchHelp && <AdminHelpBlock help={relaunchHelp} testId="relaunch-admin-help" live />}
      {cancelHelp && <AdminHelpBlock help={cancelHelp} testId="cancel-admin-help" live />}
      <div className="space-y-2">
        {runs.map((r) => (
          <DomainRunRow
            key={r.id}
            run={r}
            onCancel={onCancelRun}
            cancelling={cancelling.has(r.id)}
            onRelaunch={ready ? (id) => relaunch([id]) : undefined}
            relaunching={relaunching}
          />
        ))}
      </div>
      {runs.length > 0 && (
        <Tabs defaultValue={runs[0].id}>
          <TabsList>
            {runs.map((r) => (
              <TabsTrigger key={r.id} value={r.id}>
                {r.domain_name}
              </TabsTrigger>
            ))}
          </TabsList>
          {runs.map((r) => (
            <TabsContent key={r.id} value={r.id}>
              <RunResults
                run={r}
                feedbackTarget={{ businessId, version: batch.version, scope: batch.scope }}
              />
            </TabsContent>
          ))}
        </Tabs>
      )}
    </div>
  );
}
