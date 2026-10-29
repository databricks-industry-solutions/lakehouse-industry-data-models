"use client";

import { useState } from "react";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Card, CardContent } from "@/components/ui/card";
import { useQueryClient } from "@tanstack/react-query";
import { useNavigate } from "@tanstack/react-router";
import { toast } from "sonner";
import type { NextVibeOut } from "@/lib/api";
import { useAddNextVibeToFeedback, useAddNextVibesToFeedback, getAssessmentResultsKey } from "@/lib/api";
import { parseAdminHelp, parsePlainConflict, type AdminHelp } from "@/lib/api-error";
import { notifyError } from "@/lib/notify";
import { StatusLine } from "@/components/settings/status-line";
import { AdminHelpBlock } from "./admin-help-block";
import { AgentText } from "./agent-text";

/**
 * Route a feedback failure: an admin-help detail to the block, a plain 409
 * `{message}` (e.g. a concurrent change) to the inline retry notice when the
 * caller has one (a single card), anything else to a toast.
 */
function surfaceFeedbackError(
  error: unknown,
  title: string,
  setHelp: (h: AdminHelp | null) => void,
  setRetry?: (message: string | null) => void,
) {
  const help = parseAdminHelp(error);
  const conflict = setRetry ? parsePlainConflict(error) : null;
  if (help) setHelp(help);
  else if (conflict && setRetry) setRetry(conflict);
  else notifyError(error, { title });
}

/** An inline failure the user can simply retry (a concurrent change, or one item of a bulk add). */
function RetryNotice({ message, onRetry, disabled, testId }: { message: string; onRetry: () => void; disabled?: boolean; testId: string }) {
  return (
    <div className="flex flex-wrap items-center gap-2" data-testid={testId} role="alert">
      <StatusLine tone="error">{message}</StatusLine>
      <Button size="sm" variant="outline" className="h-6 px-2 text-xs" onClick={onRetry} disabled={disabled}>
        Try again
      </Button>
    </div>
  );
}

/** The bulk-add label: "all N" only when none of the before-build vibes is added yet, else "the remaining N". */
export function bulkAddLabel(unlinked: number, total: number): string {
  if (unlinked < total) return unlinked === 1 ? "Add the remaining before-build vibe" : `Add the remaining ${unlinked} before-build vibes`;
  return unlinked === 1 ? "Add the before-build vibe" : `Add all ${unlinked} before-build vibes`;
}

const SECTIONS: { key: string; title: string }[] = [
  { key: "before_build", title: "Before build" },
  { key: "during_build", title: "During build" },
  { key: "later", title: "Later" },
  { key: "", title: "Unclassified" },
];

function banner(
  verdict: string | null | undefined,
  beforeBuild: number,
  unclassified: number,
  beforeBuildRefs: string[],
): { text: string; cls: string } {
  if (beforeBuild > 0) {
    const decisionRefs = beforeBuildRefs.length > 0 ? ` — they answer ${beforeBuildRefs.join(", ")}` : "";
    return {
      text: `Run these ${beforeBuild === 1 ? "change" : beforeBuild + " changes"} before you build${decisionRefs}`,
      cls: "border-amber-300 bg-amber-50 text-amber-800",
    };
  }
  if (verdict === "blocked")
    return {
      text: "Blocked entities need source data — see the build-gate decisions and Gaps",
      cls: "border-red-300 bg-red-50 text-red-800",
    };
  if (verdict === "ready_to_build" || (verdict && unclassified === 0))
    return { text: "Safe to continue to hand-off", cls: "border-green-300 bg-green-50 text-green-800" };
  return {
    text: "These suggestions weren't classified by urgency — review them before you build.",
    cls: "border-border bg-muted/40 text-muted-foreground",
  };
}

interface VibeCardProps {
  v: NextVibeOut;
  linkedDecisions?: string[];
  onJumpToRef?: (ref: string) => void;
  domainRunId: string;
  feedbackTarget?: { businessId: string; version: number; scope: string };
  /** This vibe's message from a bulk add's `failures`; cleared by `onClearFailure` on retry. */
  bulkFailure?: string;
  onClearFailure?: (id: string) => void;
}

function VibeCard({
  v,
  linkedDecisions,
  onJumpToRef,
  domainRunId,
  feedbackTarget,
  bulkFailure,
  onClearFailure,
}: VibeCardProps) {
  const [pendingAdd, setPendingAdd] = useState(false);
  const [addHelp, setAddHelp] = useState<AdminHelp | null>(null);
  const [retryMessage, setRetryMessage] = useState<string | null>(null);
  const navigate = useNavigate();
  const queryClient = useQueryClient();
  const { mutate: addToFeedback } = useAddNextVibeToFeedback();
  const change = v.proposed_change || v.text;

  const handleAddToFeedback = () => {
    setPendingAdd(true);
    setAddHelp(null);
    setRetryMessage(null);
    onClearFailure?.(v.id);
    addToFeedback(
      { params: { domain_run_id: domainRunId, next_vibe_id: v.id } },
      {
        onSuccess: (response) => {
          setPendingAdd(false);
          queryClient.invalidateQueries({ queryKey: getAssessmentResultsKey({ domain_run_id: domainRunId }) });
          toast.success(response.data.created ? "Added to feedback" : "Already in feedback");
        },
        onError: (error: unknown) => {
          setPendingAdd(false);
          surfaceFeedbackError(error, "Failed to add to feedback", setAddHelp, setRetryMessage);
        },
      }
    );
  };

  const handleViewFeedback = () => {
    if (!feedbackTarget || !v.feedback_input_id) return;
    const { businessId, version, scope } = feedbackTarget;
    navigate({
      to: "/businesses/$businessId/model/$version/$scope/inputs/$inputId",
      params: { businessId, version: String(version), scope, inputId: v.feedback_input_id },
      search: { from: "feedback", tab: "diagram" },
    });
  };

  const hasLinkedFeedback = !!v.feedback_input_id;

  return (
    <Card>
      <CardContent className="space-y-1.5 p-3 text-sm">
        <div className="flex flex-wrap items-center justify-between gap-2">
          <div className="flex flex-wrap items-center gap-2">
            <Badge variant="secondary">{v.priority == null ? "—" : `P${v.priority}`}</Badge>
            <Badge variant="outline">{v.category}</Badge>
            {v.confidence != null && (
              <span className="text-xs text-muted-foreground">confidence {Math.round(v.confidence * 100)}%</span>
            )}
          </div>
          {hasLinkedFeedback ? (
            <div className="flex items-center gap-1">
              <span className="text-xs font-medium text-green-600">Added ✓</span>
              {feedbackTarget && (
                <Button size="sm" variant="link" className="h-auto p-0 text-xs" onClick={handleViewFeedback}>
                  View feedback
                </Button>
              )}
            </div>
          ) : (
            <Button
              size="sm"
              variant="outline"
              disabled={pendingAdd}
              onClick={handleAddToFeedback}
            >
              {pendingAdd ? "Adding..." : "Add to feedback"}
            </Button>
          )}
        </div>
        {linkedDecisions && linkedDecisions.length > 0 && (
          <span className="text-xs">
            Answers{" "}
            {linkedDecisions.map((d, i) => (
              <span key={d}>
                {i > 0 && ", "}
                <button
                  type="button"
                  className="text-xs font-medium text-primary hover:underline"
                  aria-label={`Go to ${d}`}
                  onClick={() => onJumpToRef?.(d)}
                >
                  {d}
                </button>
              </span>
            ))}
          </span>
        )}
        {v.problem && <div className="font-medium"><AgentText text={v.problem} /></div>}
        <div><AgentText text={change} /></div>
        {v.impact_if_skipped && (
          <div className="text-xs text-muted-foreground">If skipped: <AgentText text={v.impact_if_skipped} /></div>
        )}
        {v.affected_entities?.length > 0 && (
          <div className="flex flex-wrap gap-1">
            {v.affected_entities.map((e, i) => (
              <Badge key={`${i}-${e}`} variant="outline" className="font-mono text-[11px]">
                {e}
              </Badge>
            ))}
          </div>
        )}
        {addHelp && <AdminHelpBlock help={addHelp} testId={`vibe-admin-help-${v.id}`} live />}
        {(retryMessage ?? bulkFailure) && !hasLinkedFeedback && (
          <RetryNotice
            message={(retryMessage ?? bulkFailure) as string}
            onRetry={handleAddToFeedback}
            disabled={pendingAdd}
            testId={`vibe-retry-${v.id}`}
          />
        )}
      </CardContent>
    </Card>
  );
}

interface NextVibesListProps {
  vibes: NextVibeOut[];
  verdict?: string | null;
  decisionsForVibe?: Record<string, string[]>;
  onJumpToRef?: (ref: string) => void;
  domainRunId: string;
  feedbackTarget?: { businessId: string; version: number; scope: string };
}

/** Next-vibe suggestions grouped by urgency under a verdict banner, with optional decision linking and "Add to feedback" buttons. */
export function NextVibesList({
  vibes,
  verdict,
  decisionsForVibe = {},
  onJumpToRef,
  domainRunId,
  feedbackTarget,
}: NextVibesListProps) {
  const [pendingBulk, setPendingBulk] = useState(false);
  const [bulkHelp, setBulkHelp] = useState<AdminHelp | null>(null);
  const [failures, setFailures] = useState<Record<string, string>>({});
  const queryClient = useQueryClient();
  const { mutate: bulkAddToFeedback } = useAddNextVibesToFeedback();

  if (vibes.length === 0) return <p className="text-sm text-muted-foreground">No next vibes suggested.</p>;

  const known = new Set(SECTIONS.map((s) => s.key));
  const bucket = (key: string) => vibes.filter((v) => (known.has(v.urgency) ? v.urgency : "") === key);
  const beforeBuildVibes = bucket("before_build");
  const unlinkedBeforeBuild = beforeBuildVibes.filter((v) => !v.feedback_input_id);
  const beforeBuildRefs = beforeBuildVibes.flatMap((v) => decisionsForVibe[v.id] || []);
  const b = banner(verdict, beforeBuildVibes.length, bucket("").length, beforeBuildRefs);

  const clearFailure = (id: string) =>
    setFailures((prev) => {
      if (!(id in prev)) return prev;
      const next = { ...prev };
      delete next[id];
      return next;
    });

  const handleBulkAdd = () => {
    setPendingBulk(true);
    setBulkHelp(null);
    setFailures({});
    bulkAddToFeedback(
      { params: { domain_run_id: domainRunId }, data: { urgency: "before_build" } },
      {
        onSuccess: (response) => {
          setPendingBulk(false);
          queryClient.invalidateQueries({ queryKey: getAssessmentResultsKey({ domain_run_id: domainRunId }) });
          const done = response.data.count_created + response.data.count_reused;
          if (done > 0) toast.success(`Added ${done} vibe${done === 1 ? "" : "s"} as feedback`);
          setFailures(Object.fromEntries((response.data.failures ?? []).map((f) => [f.next_vibe_id, f.message])));
        },
        onError: (error: unknown) => {
          setPendingBulk(false);
          surfaceFeedbackError(error, "Failed to add vibes", setBulkHelp);
        },
      }
    );
  };

  return (
    <div className="space-y-3">
      <div className={`rounded-md border px-3 py-2 text-sm font-medium ${b.cls}`}>{b.text}</div>
      <p className="text-sm text-muted-foreground">
        Edit, drop or keep each one, then add the ones you keep as vibe inputs for your next modeling iteration. Running them
        answers the linked structure decisions; re-assess on the new model version afterwards.
      </p>
      {unlinkedBeforeBuild.length > 0 && (
        <Button
          onClick={handleBulkAdd}
          disabled={pendingBulk}
          variant="default"
        >
          {pendingBulk ? "Adding..." : bulkAddLabel(unlinkedBeforeBuild.length, beforeBuildVibes.length)}
        </Button>
      )}
      {bulkHelp && <AdminHelpBlock help={bulkHelp} testId="bulk-feedback-admin-help" live />}
      {SECTIONS.map(({ key, title }) => {
        const items = bucket(key);
        if (items.length === 0) return null;
        return (
          <section key={title} className="space-y-2">
            <h4 className="text-sm font-semibold">{title}</h4>
            {items.map((v) => (
              <VibeCard
                key={v.id}
                v={v}
                linkedDecisions={decisionsForVibe[v.id]}
                onJumpToRef={onJumpToRef}
                domainRunId={domainRunId}
                feedbackTarget={feedbackTarget}
                bulkFailure={failures[v.id]}
                onClearFailure={clearFailure}
              />
            ))}
          </section>
        );
      })}
    </div>
  );
}
