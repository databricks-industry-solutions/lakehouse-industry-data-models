/**
 * How the run report (`getRunReport`, design §2) reads to a modeler: one
 * header sentence from `consume_note`, and the items grouped by the agent's
 * outcome. The status vocabulary is the agent's (`run_report.AGENT_OUTCOME_STATUSES`,
 * nb 55232-55243) plus the app's `not_reported`, and `applied` / `reopened`
 * on install runs (B5).
 */
import type { RunReportItemOut, RunReportOut } from "@/lib/api";

export type ReportGroupKey =
  | "applied"
  | "still_open"
  | "out_of_scope"
  | "not_reported"
  | "marked_done"
  | "reopened"
  | `other:${string}`;

export interface ReportGroup {
  key: ReportGroupKey;
  label: string;
  items: RunReportItemOut[];
}

const STILL_OPEN = new Set(["unmapped", "partial", "failed", "deferred"]);
const OUT_OF_SCOPE = new Set([
  "scope_dependency_conflict",
  "scope_fence_violation",
  "scope_rejected",
]);

const GROUP_LABELS: Record<string, string> = {
  applied: "Applied",
  still_open: "Still open",
  out_of_scope: "Out of scope",
  not_reported: "Not reported",
  marked_done: "Marked done",
  reopened: "Reopened",
};

const GROUP_ORDER: string[] = [
  "marked_done",
  "reopened",
  "applied",
  "still_open",
  "out_of_scope",
  "not_reported",
];

export function isInstallReport(report: Pick<RunReportOut, "intent">): boolean {
  return report.intent === "install";
}

function groupKey(status: string | null | undefined, install: boolean): ReportGroupKey {
  if (!status || status === "not_reported") return "not_reported";
  if (install && status === "applied") return "marked_done";
  if (install && status === "reopened") return "reopened";
  if (status === "applied") return "applied";
  if (STILL_OPEN.has(status)) return "still_open";
  if (OUT_OF_SCOPE.has(status)) return "out_of_scope";
  return `other:${status}`;
}

/** The report's items in display groups, empty groups left out. */
export function reportGroups(report: RunReportOut): ReportGroup[] {
  const install = isInstallReport(report);
  const by = new Map<ReportGroupKey, RunReportItemOut[]>();
  for (const item of report.items ?? []) {
    const key = groupKey(item.outcome_status, install);
    by.set(key, [...(by.get(key) ?? []), item]);
  }
  const rank = (k: string) => {
    const i = GROUP_ORDER.indexOf(k);
    return i === -1 ? GROUP_ORDER.length : i;
  };
  return [...by.entries()]
    .sort(([a], [b]) => rank(a) - rank(b) || a.localeCompare(b))
    .map(([key, items]) => ({
      key,
      label: key.startsWith("other:") ? `Other: ${key.slice(6)}` : GROUP_LABELS[key],
      items,
    }));
}

function items(n: number): string {
  return `${n} feedback item${n === 1 ? "" : "s"}`;
}

function count(report: RunReportOut, status: string): number {
  return (report.items ?? []).filter((i) => i.outcome_status === status).length;
}

/**
 * The card's header sentence, or null when the run has nothing to report
 * (a run that sent no feedback and has no note).
 */
export function reportHeadline(report: RunReportOut): string | null {
  const applied = count(report, "applied");
  switch (report.consume_note) {
    case "dry_run_pending_install":
      return `Dry Run. Nothing was marked done yet. Install this draft to mark the ${items(applied)} it applied done.`;
    case "dry_run_installed":
      return `Dry Run, installed since. The install marked the ${items(applied)} it applied done.`;
    case "no_outcomes_reported":
      return "The agent did not report per-feedback outcomes, so nothing was marked done; the feedback stays open and selected.";
    case "version_mismatch":
      return `The agent's file was for v${report.fetched_version ?? "?"}, not v${report.expected_version ?? "?"}, so nothing was marked done; the feedback stays open.`;
    case "malformed":
      return "The agent's per-feedback outcomes could not be read, so nothing was marked done; the feedback stays open.";
    case "sync_failed":
      return "The model sync did not finish, so nothing was marked done; the feedback stays open.";
    case "pre_0_9_0":
      return "This run finished before the app kept per-feedback reports, so nothing is listed here.";
    case "install_consumed": {
      const reopened = count(report, "reopened");
      const done = applied > 0 ? `marked ${items(applied)} done` : "";
      const back = reopened > 0 ? `reopened ${items(reopened)}` : "";
      return `This install ${[done, back].filter(Boolean).join(" and ")}.`;
    }
    default:
      break;
  }
  if (isInstallReport(report)) {
    return report.run_status === "completed"
      ? "Nothing was marked done or reopened: the installed version has no per-feedback outcomes (it was made before 0.9.0, or applied none)."
      : null;
  }
  if ((report.items ?? []).length === 0) return null;
  return applied > 0
    ? `${items(applied)} applied and marked done.`
    : "The agent applied none of the feedback this run sent; it stays open.";
}

/** The current state of a feedback item, in words. */
export function itemState(item: RunReportItemOut): string {
  if (item.status === "deprecated") return "Deleted";
  if (item.consumed) return "Done";
  return item.selected_for_run ? "Open, selected" : "Open";
}
