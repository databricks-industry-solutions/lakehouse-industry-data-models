/**
 * The run report card (design §2 UI): what the run did with each feedback item
 * it sent. One header sentence (`lib/run-report.reportHeadline`), the items
 * grouped by outcome with the agent's reason and the item's state now, the
 * lineage callout, the unmatched count, and the actions:
 *
 * - "Install this draft" on a Dry Run whose draft is not installed (opens the
 *   install dialog, `useVersionOperationLaunch`);
 * - "Select these" on an install's Reopened group (the selection route).
 *
 * `RunReportCard` sits on the run page; `VersionReportCompact` is the short
 * form on the version Overview.
 */
import { useState } from "react";
import { Link } from "@tanstack/react-router";
import { useQueryClient } from "@tanstack/react-query";
import { toast } from "sonner";
import { ClipboardList } from "lucide-react";
import {
  getRunReportKey,
  useGetRunReport,
  useGetVersionReport,
  useListVersions,
  type ModelVersionOut,
  type RunReportOut,
} from "@/lib/api";
import { notifyError } from "@/lib/notify";
import { isTerminalRunStatus } from "@/lib/run-status";
import { itemState, reportGroups, reportHeadline, type ReportGroup } from "@/lib/run-report";
import { isDryRunDraft, isReplaced } from "@/lib/version-lifecycle";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { VersionOperationDialog } from "@/components/runs/version-operation-dialog";
import { HelpLink } from "@/components/help/help-link";
import { useVibeInputSelection } from "@/components/vibe-inputs/use-vibe-input-selection";

/** The lineage callout, unless the newer version was replaced on purpose. */
export function lineageCallout(
  report: RunReportOut,
  versions: readonly ModelVersionOut[],
): string | null {
  if (!report.lineage_stale || report.lineage_head_at_write == null) return null;
  const output = versions.find((v) => v.id === report.output_version_id);
  const head = versions.find(
    (v) => v.version === report.lineage_head_at_write && (v.scope || "") === (output?.scope || ""),
  );
  if (head && isReplaced(head)) return null;
  const base = report.lineage_base_version != null ? `v${report.lineage_base_version}` : "an older version";
  return `The agent built this on ${base} while v${report.lineage_head_at_write} was the latest version. Changes made in v${report.lineage_head_at_write} are not in it.`;
}

function GroupBlock({
  group,
  businessId,
  runId,
}: {
  group: ReportGroup;
  businessId: string;
  runId: string;
}) {
  const queryClient = useQueryClient();
  const selection = useVibeInputSelection(businessId);
  const [selecting, setSelecting] = useState(false);
  const toSelect = group.items.filter((i) => !i.consumed && !i.selected_for_run && i.status !== "deprecated");
  const selectThese = async () => {
    setSelecting(true);
    try {
      await selection.mutateAsync({
        params: { business_id: businessId },
        data: { input_ids: toSelect.map((i) => i.input_id), selected: true },
      });
      await queryClient.invalidateQueries({ queryKey: getRunReportKey({ business_id: businessId, run_id: runId }) });
      toast.success(`${toSelect.length} feedback item${toSelect.length === 1 ? "" : "s"} selected for the next run.`);
    } catch (err) {
      notifyError(err, { title: "Selecting the feedback failed" });
    } finally {
      setSelecting(false);
    }
  };
  return (
    <section className="space-y-1.5" data-testid={`report-group-${group.key}`}>
      <div className="flex items-center gap-2">
        <h3 className="text-sm font-medium">
          {group.label} <span className="text-muted-foreground">({group.items.length})</span>
        </h3>
        {group.key === "reopened" && toSelect.length > 0 && (
          <Button size="sm" variant="outline" disabled={selecting} onClick={() => void selectThese()} data-testid="report-select-these">
            {selecting ? "Selecting..." : "Select these"}
          </Button>
        )}
      </div>
      <ul className="space-y-1.5">
        {group.items.map((item) => (
          <li key={item.input_id} className="rounded-md border px-3 py-2 text-sm" data-testid="report-item">
            <div className="flex items-start gap-2">
              <span className="line-clamp-2 flex-1">{item.text}</span>
              <Badge variant="outline" className="shrink-0 text-[11px]">
                {itemState(item)}
              </Badge>
            </div>
            {item.outcome_reason && (
              <p className="mt-1 text-xs text-muted-foreground">{item.outcome_reason}</p>
            )}
          </li>
        ))}
      </ul>
    </section>
  );
}

export function RunReportBody({
  report,
  versions,
  businessId,
}: {
  report: RunReportOut;
  versions: readonly ModelVersionOut[];
  businessId: string;
}) {
  const [installOpen, setInstallOpen] = useState(false);
  const headline = reportHeadline(report);
  const groups = reportGroups(report);
  const callout = lineageCallout(report, versions);
  const output = versions.find((v) => v.id === report.output_version_id);
  const offerInstall = report.consume_note === "dry_run_pending_install" && output && isDryRunDraft(output);
  if (!headline && groups.length === 0) return null;
  return (
    <Card data-testid="run-report-card">
      <CardHeader className="pb-2">
        <CardTitle className="flex items-center gap-2 text-base">
          <ClipboardList className="h-4 w-4" aria-hidden />
          Feedback report
          <HelpLink topic="vibes" label="How the agent uses your feedback" className="ml-auto" />
        </CardTitle>
      </CardHeader>
      <CardContent className="space-y-4">
        {headline && (
          <div className="flex flex-wrap items-center gap-3">
            <p className="text-sm" data-testid="report-headline">
              {headline}
            </p>
            {offerInstall && (
              <Button size="sm" onClick={() => setInstallOpen(true)} data-testid="report-install-draft">
                Install this draft
              </Button>
            )}
          </div>
        )}
        {callout && (
          <p role="note" className="rounded-md border border-warning/40 bg-warning/5 px-3 py-2 text-xs text-warning" data-testid="report-lineage">
            {callout}
          </p>
        )}
        {(report.unmatched_outcome_count ?? 0) > 0 && (
          <p className="text-xs text-muted-foreground" data-testid="report-unmatched">
            {report.unmatched_outcome_count} outcome{report.unmatched_outcome_count === 1 ? "" : "s"} the agent
            reported matched no feedback item this run sent.
          </p>
        )}
        {groups.map((g) => (
          <GroupBlock key={g.key} group={g} businessId={businessId} runId={report.run_id} />
        ))}
      </CardContent>
      {offerInstall && output && installOpen && (
        <VersionOperationDialog
          open
          onOpenChange={setInstallOpen}
          businessId={businessId}
          intent="install"
          version={output}
          versions={versions}
        />
      )}
    </Card>
  );
}

/** The report card of a finished run; nothing while it runs. */
export function RunReportCard({
  businessId,
  runId,
  runStatus,
}: {
  businessId: string;
  runId: string;
  runStatus: string;
}) {
  const terminal = isTerminalRunStatus(runStatus);
  const { data } = useGetRunReport({
    params: { business_id: businessId, run_id: runId },
    query: { enabled: terminal, retry: false },
  });
  const { data: versions } = useListVersions({
    params: { business_id: businessId },
    query: { enabled: terminal },
  });
  if (!terminal || !data) return null;
  return <RunReportBody report={data.data} versions={versions?.data ?? []} businessId={businessId} />;
}

/** One line on the version Overview: the producing run's report headline,
 *  per-group counts and a link to the run. */
export function VersionReportCompact({
  businessId,
  version,
  versions,
}: {
  businessId: string;
  version: ModelVersionOut;
  versions: readonly ModelVersionOut[];
}) {
  const [installOpen, setInstallOpen] = useState(false);
  const { data } = useGetVersionReport({
    params: { business_id: businessId, version_id: version.id },
    query: { retry: false },
  });
  const report = data?.data.report;
  if (!report) return null;
  const headline = reportHeadline(report);
  const groups = reportGroups(report);
  if (!headline && groups.length === 0) return null;
  const offerInstall = report.consume_note === "dry_run_pending_install" && isDryRunDraft(version);
  return (
    <div className="flex flex-wrap items-center gap-x-3 gap-y-1 rounded-md border px-3 py-2 text-sm" data-testid="version-report-compact">
      <ClipboardList className="h-4 w-4 text-muted-foreground" aria-hidden />
      {headline && <span>{headline}</span>}
      {groups.length > 0 && (
        <span className="text-xs text-muted-foreground">
          {groups.map((g) => `${g.label} ${g.items.length}`).join(" · ")}
        </span>
      )}
      {offerInstall && (
        <Button size="sm" variant="outline" onClick={() => setInstallOpen(true)}>
          Install this draft
        </Button>
      )}
      <Link
        to="/businesses/$businessId/runs/$runId"
        params={{ businessId, runId: report.run_id }}
        className="ml-auto text-xs font-medium underline underline-offset-2"
      >
        Open the run report
      </Link>
      {offerInstall && installOpen && (
        <VersionOperationDialog
          open
          onOpenChange={setInstallOpen}
          businessId={businessId}
          intent="install"
          version={version}
          versions={versions}
        />
      )}
    </div>
  );
}
