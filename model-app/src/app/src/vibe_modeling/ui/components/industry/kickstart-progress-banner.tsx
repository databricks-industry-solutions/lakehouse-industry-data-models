import { Link, useMatchRoute } from "@tanstack/react-router";
import { AlertTriangle, Loader2 } from "lucide-react";
import {
  useGetBusiness,
  useGetRun,
  useListBusinesses,
  useListRuns,
  type BusinessListOut,
  type BusinessOut,
  type RunListOut,
  type RunOut,
} from "@/lib/api";
import { useInvalidateOnRunTerminal } from "@/lib/hooks";
import { kickstartSourceLabel } from "@/lib/industry";
import { KICKSTART_RUN_INTENT } from "@/lib/intent";
import { isTerminalRunStatus } from "@/lib/run-status";
import selector from "@/lib/selector";
import { Alert, AlertDescription, AlertTitle } from "@/components/ui/alert";
import { Progress } from "@/components/ui/progress";

export const KICKSTART_POLL_MS = 5000;

/** The business's newest kickstart run. ``listRuns`` returns newest first. */
export function latestKickstartRun(
  runs: RunListOut[] | undefined,
): RunListOut | undefined {
  return runs?.find((r) => r.intent === KICKSTART_RUN_INTENT);
}

/**
 * Poll while the kickstart run is still working, stop once it is terminal or
 * when the business has no kickstart run at all.
 */
export function kickstartPollInterval(
  run: Pick<RunListOut, "status"> | undefined,
): number | false {
  return run && !isTerminalRunStatus(run.status) ? KICKSTART_POLL_MS : false;
}

/**
 * A later run that completed means the business works, whatever the kickstart
 * left behind, so its failure stops being news.
 */
export function laterRunCompleted(
  runs: RunListOut[] | undefined,
  kickstart: Pick<RunListOut, "id" | "created_at">,
): boolean {
  const since = Date.parse(kickstart.created_at);
  return (runs ?? []).some(
    (r) =>
      r.id !== kickstart.id &&
      r.status === "completed" &&
      Date.parse(r.created_at) > since,
  );
}

/**
 * Setup status for a business created by "Kickstart from industry". The
 * kickstart returns as soon as the business row exists and keeps copying the
 * model in the background; until that finishes the active-run lock refuses
 * runs, so this banner says why. Renders nothing for a business without a
 * kickstart run, after a successful one, on the kickstart run's own page and
 * on the full-height inputs pages, which size themselves to the viewport.
 */
export function KickstartProgressBanner({ businessId }: { businessId: string }) {
  const matchRoute = useMatchRoute();

  // A kickstarted business carries its source industry; asking for it first
  // keeps the runs request off every other business.
  const { data: business } = useGetBusiness({
    params: { business_id: businessId },
    query: selector<BusinessOut>().query,
  });
  const sourceId = business?.source_industry_id ?? null;

  const { data: runs } = useListRuns({
    params: { business_id: businessId },
    query: {
      enabled: sourceId != null,
      staleTime: 0,
      ...selector<RunListOut[]>().query,
    },
  });
  const run = latestKickstartRun(runs);

  // RunListOut carries no message and is fetched once; the run itself is the
  // single polled stream and its status wins over the list's.
  const { data: detail } = useGetRun({
    params: { business_id: businessId, run_id: run?.id ?? "" },
    query: {
      enabled:
        run != null &&
        (!isTerminalRunStatus(run.status) || run.status === "failed"),
      refetchInterval: (query) =>
        kickstartPollInterval(query.state.data?.data),
      staleTime: 0,
      ...selector<RunOut>().query,
    },
  });
  const status = detail?.status ?? run?.status;
  const working = status != null && !isTerminalRunStatus(status);
  const failed =
    status === "failed" && run != null && !laterRunCompleted(runs, run);

  // The model, versions and artifacts only exist once the copy lands; refetch
  // everything this business showed while it was empty.
  useInvalidateOnRunTerminal(status, businessId);

  const { data: businesses } = useListBusinesses({
    query: {
      enabled: sourceId != null && (working || failed),
      ...selector<BusinessListOut[]>().query,
    },
  });

  if (!run || (!working && !failed)) return null;
  if (
    matchRoute({
      to: "/businesses/$businessId/runs/$runId",
      params: { businessId, runId: run.id },
    }) ||
    matchRoute({
      to: "/businesses/$businessId/model/$version/$scope/inputs",
      fuzzy: true,
    })
  ) {
    return null;
  }

  const source = kickstartSourceLabel(
    businesses?.find((b) => b.id === sourceId)?.name,
    business?.source_version,
  );
  const runLink = (
    <Link
      to="/businesses/$businessId/runs/$runId"
      params={{ businessId, runId: run.id }}
      className="font-medium underline underline-offset-2"
    >
      View run
    </Link>
  );

  if (failed) {
    // The run's error_message is raw exception text the backend does not
    // sanitize yet (story "Run error messages reach users sanitized"), so the
    // banner shows the fixed progress_message and leaves the detail to the run
    // page.
    return (
      <Alert
        variant="destructive"
        role="status"
        className="rounded-none border-x-0 border-t-0"
        data-testid="kickstart-progress-banner"
      >
        <AlertTriangle className="h-4 w-4" />
        <AlertTitle>Setting up this business from {source} failed</AlertTitle>
        <AlertDescription>
          {detail?.progress_message || "Setup did not finish."} {runLink}
        </AlertDescription>
      </Alert>
    );
  }

  const percent = detail?.progress_percent ?? run.progress_percent;
  return (
    <Alert
      role={undefined}
      className="rounded-none border-x-0 border-t-0"
      data-testid="kickstart-progress-banner"
    >
      <Loader2 className="h-4 w-4 animate-spin" />
      <AlertTitle>Setting up this business from {source}</AlertTitle>
      <AlertDescription className="space-y-1">
        <p aria-live="polite">
          {detail?.progress_message || "Starting"} - {percent}%
        </p>
        <p>Runs are blocked until setup finishes. {runLink}</p>
        <Progress value={percent} aria-label="Setup progress" className="!mt-2" />
      </AlertDescription>
    </Alert>
  );
}
