import { useMemo, useState } from "react";
import { Link } from "@tanstack/react-router";
import { useQueryClient } from "@tanstack/react-query";
import { ListChecks, Undo2 } from "lucide-react";
import { toast } from "sonner";
import {
  getRunChangesKey,
  useAddRejectedChangesAsFeedback,
  useGetRunChanges,
  useGetRunReport,
  useGetVersionReport,
  useListVersions,
  useSetRunChangeDecisions,
  type ModelVersionOut,
  type RunChangeDecisionIn,
  type RunChangeOut,
  type RunChangesOut,
  type RunOperationOut,
} from "@/lib/api";
import { apiErrorMessage, parse409 } from "@/lib/api-error";
import { useRunChangeReviewEnabled } from "@/lib/features";
import { notifyError } from "@/lib/notify";
import { formatDateTime } from "@/lib/date";
import { isTerminalRunStatus } from "@/lib/run-status";
import { versionScopeLabel } from "@/lib/version-label";
import { deleteState, isDryRunDraft, isInstalled, type LifecycleVersion } from "@/lib/version-lifecycle";
import { invalidateVibeInputQueries } from "@/components/vibe-inputs/query-keys";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Skeleton } from "@/components/ui/skeleton";

type RunChangeClass = RunChangeOut["change_class"];

/** Hint labels and token colours, in the order the list shows them. */
const CLASS_META: Record<RunChangeClass, { label: string; className: string; order: number }> = {
  outside_scope: { label: "Outside the run's scope", className: "text-destructive", order: 0 },
  not_asked: { label: "Not asked", className: "text-warning", order: 1 },
  unclear: { label: "Unclear", className: "text-muted-foreground", order: 2 },
  asked: { label: "Asked", className: "text-success", order: 3 },
};

const CHANGE_WORDS: Record<RunChangeOut["change_kind"], string> = {
  added: "Added",
  modified: "Changed",
  removed: "Removed",
};

const PAGE = 50;

/** True for a change the modeler did not ask for (the Overview count). */
export function isUnasked(c: RunChangeOut): boolean {
  return c.change_class === "not_asked" || c.change_class === "outside_scope";
}

/** The latest succeeded output of one of `names`, or null. */
function latestOutput(operations: readonly RunOperationOut[], names: readonly string[]): string | null {
  const op = [...operations]
    .sort((a, b) => b.step_index - a.step_index)
    .find((o) => names.includes(o.operation_name) && o.status === "succeeded" && o.output_version_id);
  return op?.output_version_id ?? null;
}

/** The run's succeeded vibe operation output, or null when it produced no vibe version. */
export function vibeOutputVersionId(operations: readonly RunOperationOut[]): string | null {
  return latestOutput(operations, ["vibe_iterate"]);
}

/** The MVM or ECM a unified run's shrink / enlarge step derived from its vibe output. */
export function derivedOutputVersionId(operations: readonly RunOperationOut[]): string | null {
  return latestOutput(operations, ["shrink_to_mvm", "enlarge_to_ecm"]);
}

/** One version's delete steps, in the order `deleteState` (the server's
 *  `delete_refusal`) allows: uninstall, the newer versions, then the version. */
function deleteSteps(v: LifecycleVersion, versions: readonly LifecycleVersion[]): string[] {
  const label = versionScopeLabel(v.version, v.scope);
  if (isDryRunDraft(v)) return [`delete ${label}`];
  const newer = deleteState(v, versions).newerVersions ?? [];
  return [
    ...(isInstalled(v) ? [`uninstall ${label}`] : []),
    ...(newer.length > 0 ? [`delete the newer versions (${newer.map((n) => `v${n}`).join(", ")})`] : []),
    `delete ${label}`,
  ];
}

function count(n: number, one: string, many: string): string {
  return n === 1 ? one : many.replace("{n}", String(n));
}

/**
 * The rollback steps for the run's outputs, in plain words. A unified run's
 * derived MVM or ECM (`derived`) goes first, so it never points at a deleted
 * version. Draft, installed and "the newer versions first" are
 * `lib/version-lifecycle`'s rules, so the card and the version page agree.
 */
export function rollbackCopy(
  output: LifecycleVersion,
  base: Pick<ModelVersionOut, "version" | "scope"> | undefined,
  versions: readonly LifecycleVersion[],
  { applied = 0, rejectedFeedback = 0, derived }: {
    applied?: number;
    rejectedFeedback?: number;
    derived?: LifecycleVersion;
  } = {},
): string {
  const out = versionScopeLabel(output.version, output.scope);
  const prev = base ? versionScopeLabel(base.version, base.scope) : "the previous version";
  const outputs = derived ? [derived, output] : [output];
  const steps = outputs.flatMap((v) => deleteSteps(v, versions)).join(", then ");
  const reopen =
    applied > 0
      ? ` ${count(applied, `The 1 feedback item applied in ${out} becomes`, `The {n} feedback items applied in ${out} become`)} open again.`
      : "";
  const dropped =
    rejectedFeedback > 0
      ? ` ${count(rejectedFeedback, `The open "Rejected change" feedback item made from ${out} is`, `The {n} open "Rejected change" feedback items made from ${out} are`)} deleted with it.`
      : "";
  if (outputs.every(isDryRunDraft)) {
    const what = derived ? "They are Dry Run drafts" : "It is a Dry Run draft";
    return `Roll back: ${steps}. ${what}, so nothing is installed and ${prev} stays the latest version.${dropped}`;
  }
  const restore = isInstalled(output) ? `; install ${prev} to restore its tables` : "";
  return `Roll back: ${steps}. ${prev} becomes the latest version again${restore}.${reopen}${dropped}`;
}

interface RunChangesCardProps {
  businessId: string;
  runId: string;
  runStatus: string;
  operations: readonly RunOperationOut[];
}

/** The run change review card, only while the review is on
 *  (`useRunChangeReviewEnabled`); off, it renders nothing and fetches nothing
 *  of the run's changes. */
export function RunChangesCard(props: RunChangesCardProps) {
  return useRunChangeReviewEnabled() ? <RunChangesCardWhenReady {...props} /> : null;
}

/** Rendered once the run has ended and its report has answered (data or an
 *  error), so the run report card above it is already in place and does not
 *  push the list down; a failed report never hides the changes. */
function RunChangesCardWhenReady({ businessId, runId, runStatus, operations }: RunChangesCardProps) {
  const outputId = vibeOutputVersionId(operations);
  const ready = !!outputId && isTerminalRunStatus(runStatus);
  // `isFetched` stays true through a refetch, so a failed report that is
  // fetched again (another observer mounting) does not unmount the list.
  const { isFetched: reportAnswered } = useGetRunReport({
    params: { business_id: businessId, run_id: runId },
    query: { enabled: ready, retry: false, retryOnMount: false, staleTime: 30_000 },
  });
  if (!ready || !reportAnswered) return null;
  return (
    <RunChangesCardBody businessId={businessId} runId={runId} derivedId={derivedOutputVersionId(operations)} />
  );
}

function RunChangesCardBody({
  businessId,
  runId,
  derivedId,
}: {
  businessId: string;
  runId: string;
  derivedId: string | null;
}) {
  const params = { business_id: businessId, run_id: runId };
  const queryClient = useQueryClient();
  const { data, error, isLoading } = useGetRunChanges({
    params,
    query: { retry: false, staleTime: 15_000 },
  });
  const { data: report } = useGetRunReport({ params, query: { retry: false, retryOnMount: false, staleTime: 30_000 } });
  const { data: versionsData } = useListVersions({
    params: { business_id: businessId },
    query: { staleTime: 30_000 },
  });
  const [showAll, setShowAll] = useState(false);

  const store = (next: { data: RunChangesOut }) => {
    queryClient.setQueryData(getRunChangesKey(params), next);
  };
  // A 409 decisions_closed means the card is stale: refetch so it turns read-only.
  const failed = (fallback: string) => (e: unknown) => {
    if (parse409(e, "decisions_closed")) {
      queryClient.invalidateQueries({ queryKey: getRunChangesKey(params) });
    }
    notifyError(apiErrorMessage(e, fallback));
  };
  const decide = useSetRunChangeDecisions({
    mutation: { onSuccess: store, onError: failed("Could not save the decision") },
  });
  const addFeedback = useAddRejectedChangesAsFeedback({
    mutation: {
      onSuccess: (next) => {
        store(next);
        invalidateVibeInputQueries(queryClient, businessId);
        toast.success("Rejected changes added as feedback. Select them on the compose surface for a next run.");
      },
      onError: failed("Could not add the feedback"),
    },
  });

  const changes = data?.data;
  const sorted = useMemo(
    () =>
      [...(changes?.changes ?? [])].sort(
        (a, b) => CLASS_META[a.change_class].order - CLASS_META[b.change_class].order,
      ),
    [changes],
  );

  if (isLoading) return <Skeleton className="h-40 w-full" />;
  if (error || !changes) {
    return (
      <Card>
        <CardHeader>
          <CardTitle className="text-base flex items-center gap-2">
            <ListChecks className="h-4 w-4" />
            Changes
          </CardTitle>
        </CardHeader>
        <CardContent className="text-sm text-muted-foreground">
          {apiErrorMessage(error, "This run's changes cannot be listed.")}
        </CardContent>
      </Card>
    );
  }

  const versions = versionsData?.data ?? [];
  const output = versions.find((v) => v.id === changes.version_id);
  const base = versions.find((v) => v.id === changes.base_version_id);
  const derived = derivedId ? versions.find((v) => v.id === derivedId) : undefined;
  const appliedCount = (report?.data?.items ?? []).filter((i) => i.outcome_status === "applied").length;
  const unasked = sorted.filter(isUnasked).length;
  const rejected = sorted.filter((c) => c.decision === "rejected");
  const pendingFeedback = rejected.filter((c) => !c.feedback_input_id).length;
  const askedUndecided = sorted.filter((c) => c.change_class === "asked" && !c.decision);
  const open = changes.decisions_open !== false;
  const busy = decide.isPending || addFeedback.isPending;
  const visible = showAll ? sorted : sorted.slice(0, PAGE);

  const send = (decisions: RunChangeDecisionIn[]) => decide.mutate({ params, data: { decisions } });

  return (
    <Card>
      <CardHeader className="space-y-1">
        <CardTitle className="text-base flex items-center gap-2">
          <ListChecks className="h-4 w-4" />
          Changes{output ? ` in ${versionScopeLabel(output.version, output.scope)}` : ""}
        </CardTitle>
        <p className="text-sm text-muted-foreground">
          {sorted.length === 0
            ? `No changes${base ? ` compared with ${versionScopeLabel(base.version, base.scope)}` : ""}.`
            : `${sorted.length} ${sorted.length === 1 ? "change" : "changes"}${
                base ? ` compared with ${versionScopeLabel(base.version, base.scope)}` : ""
              }: ${unasked} you did not ask for, ${rejected.length} rejected.`}
        </p>
      </CardHeader>
      {(sorted.length > 0 || !open) && (
        <CardContent className="space-y-4 text-sm">
          {sorted.length > 0 && (
            <p className="text-muted-foreground">
              The list shows domains, products and attributes added or removed, and attribute changes to the type, the
              foreign key target or the first 100 characters of the description. It does not show changes to product or
              domain descriptions, primary keys, table or column names, tags, glossary terms or value patterns. A rename
              shows as a removal and an addition. &ldquo;Asked&rdquo; is a hint: a request anchored on a domain counts
              every change in that domain as asked.
            </p>
          )}
          {!open && (
            <p className="rounded-md border border-border bg-muted px-3 py-2 text-foreground">
              A newer model run has started from this version, so these decisions are final.
            </p>
          )}
          {sorted.length > 0 && (
            <>
              {open && (
                <div className="flex flex-wrap items-center gap-2">
                  <Button
                    size="sm"
                    variant="outline"
                    disabled={busy || askedUndecided.length === 0}
                    onClick={() =>
                      send(
                        askedUndecided.map((c) => ({
                          element_kind: c.element_kind,
                          element_path: c.element_path,
                          decision: "accepted" as const,
                        })),
                      )
                    }
                  >
                    Accept all asked
                  </Button>
                  <Button
                    size="sm"
                    variant="outline"
                    disabled={busy || pendingFeedback === 0}
                    onClick={() => addFeedback.mutate({ params })}
                  >
                    <Undo2 className="h-3.5 w-3.5" />
                    Add rejected as feedback{pendingFeedback > 0 ? ` (${pendingFeedback})` : ""}
                  </Button>
                  {output && isDryRunDraft(output) && (
                    <span className="text-muted-foreground">
                      A run from this Dry Run draft is always All domains.
                    </span>
                  )}
                </div>
              )}
              <ul className="divide-y divide-border rounded-md border border-border" aria-label="Changes">
                {visible.map((c) => (
                  <ChangeRow
                    key={`${c.element_kind}:${c.element_path}`}
                    change={c}
                    open={open}
                    busy={busy}
                    onDecide={(decision) =>
                      send([{ element_kind: c.element_kind, element_path: c.element_path, decision }])
                    }
                  />
                ))}
              </ul>
              {sorted.length > PAGE && (
                <Button size="sm" variant="ghost" onClick={() => setShowAll((v) => !v)}>
                  {showAll ? "Show fewer" : `Show all ${sorted.length}`}
                </Button>
              )}
            </>
          )}
          {output && sorted.length > 0 && (
            <div className="space-y-1 border-t border-border pt-3">
              <p className="text-foreground">{rollbackCopy(output, base, versions, {
                  applied: appliedCount,
                  rejectedFeedback: rejected.filter((c) => c.feedback_input_id).length,
                  derived,
                })}</p>
              <Link
                to="/businesses/$businessId/model/$version/$scope"
                params={{ businessId, version: String(output.version), scope: output.scope || "ecm" }}
                search={{ tab: "overview" }}
                className="text-primary underline-offset-4 hover:underline"
              >
                Open {versionScopeLabel(output.version, output.scope)}
              </Link>
            </div>
          )}
        </CardContent>
      )}
    </Card>
  );
}

function ChangeRow({
  change,
  open,
  busy,
  onDecide,
}: {
  change: RunChangeOut;
  open: boolean;
  busy: boolean;
  onDecide: (decision: "accepted" | "rejected") => void;
}) {
  const meta = CLASS_META[change.change_class];
  return (
    <li className="flex flex-wrap items-center gap-x-3 gap-y-1 px-3 py-2">
      <Badge variant="outline" className="capitalize">
        {change.element_kind}
      </Badge>
      <span className="font-mono text-foreground break-all">{change.element_path}</span>
      <span className="text-muted-foreground">{CHANGE_WORDS[change.change_kind]}</span>
      <span className={meta.className}>{meta.label}</span>
      <span className="ml-auto flex items-center gap-2">
        {change.decision && change.decided_by && (
          <span className="text-xs text-muted-foreground">
            {change.decision === "accepted" ? "Accepted" : "Rejected"} by {change.decided_by},{" "}
            {formatDateTime(change.decided_at)}
            {change.feedback_input_id ? " (feedback added)" : ""}
          </span>
        )}
        {open ? (
          <>
            <Button
              size="sm"
              variant={change.decision === "accepted" ? "default" : "outline"}
              aria-pressed={change.decision === "accepted"}
              aria-label={`Accept the change to ${change.element_path}`}
              disabled={busy}
              onClick={() => onDecide("accepted")}
            >
              Accept
            </Button>
            <Button
              size="sm"
              variant={change.decision === "rejected" ? "destructive" : "outline"}
              aria-pressed={change.decision === "rejected"}
              aria-label={`Reject the change to ${change.element_path}`}
              disabled={busy}
              onClick={() => onDecide("rejected")}
            >
              Reject
            </Button>
          </>
        ) : (
          !change.decision && <span className="text-xs text-muted-foreground">No decision</span>
        )}
      </span>
    </li>
  );
}

interface VersionChangesSummaryProps {
  businessId: string;
  versionId: string;
}

/** The version Overview's change review line, only while the review is on
 *  (`useRunChangeReviewEnabled`); off, it renders and fetches nothing. */
export function VersionChangesSummary(props: VersionChangesSummaryProps) {
  return useRunChangeReviewEnabled() ? <VersionChangesSummaryLine {...props} /> : null;
}

/** One line for the version Overview: how many changes the producing vibe run
 *  made that were not asked for, and how many the modeler rejected. Renders
 *  nothing for a version no vibe run produced or when there is nothing to say. */
function VersionChangesSummaryLine({ businessId, versionId }: VersionChangesSummaryProps) {
  const { data: versionReport } = useGetVersionReport({
    params: { business_id: businessId, version_id: versionId },
    query: { retry: false, staleTime: 30_000 },
  });
  // The version report also names a unified run for the MVM or ECM its
  // shrink / enlarge step derived; that run's changes are its vibe output's,
  // so they are fetched only for the vibe output itself.
  const report = versionReport?.data?.report;
  const runId = report && report.output_version_id === versionId ? report.run_id : null;
  const { data } = useGetRunChanges({
    params: { business_id: businessId, run_id: runId ?? "" },
    query: { enabled: !!runId, retry: false, staleTime: 15_000 },
  });
  const changes = data?.data?.changes;
  if (!runId || !changes) return null;
  const unasked = changes.filter(isUnasked).length;
  const rejected = changes.filter((c) => c.decision === "rejected").length;
  if (unasked === 0 && rejected === 0) return null;
  return (
    <p className="text-sm text-foreground" data-testid="version-changes-summary">
      {unasked} {unasked === 1 ? "change" : "changes"} you did not ask for, {rejected} rejected.{" "}
      <Link
        to="/businesses/$businessId/runs/$runId"
        params={{ businessId, runId }}
        className="text-primary underline-offset-4 hover:underline"
      >
        Review the changes
      </Link>
    </p>
  );
}
