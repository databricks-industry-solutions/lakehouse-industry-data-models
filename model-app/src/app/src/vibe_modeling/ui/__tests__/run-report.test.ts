/**
 * The run report's header sentence per `consume_note` and its groups per
 * outcome status (design §2 UI).
 */
import { describe, expect, it } from "vitest";
import type { RunReportItemOut, RunReportOut } from "@/lib/api";
import { itemState, reportGroups, reportHeadline } from "@/lib/run-report";

function item(id: string, outcome: string | null, over: Partial<RunReportItemOut> = {}): RunReportItemOut {
  return {
    input_id: id,
    outcome_status: outcome,
    created_at: "2026-10-20T00:00:00Z",
    text: `feedback ${id}`,
    origin: "user",
    priority: "medium",
    status: "active",
    consumed: false,
    selected_for_run: true,
    ...over,
  } as RunReportItemOut;
}

function report(over: Partial<RunReportOut> = {}): RunReportOut {
  return {
    run_id: "r1",
    business_id: "b1",
    intent: "vibe-iterate",
    run_status: "completed",
    dry_run: false,
    has_agent_report: true,
    has_input_outcomes: true,
    version_mismatch: false,
    items: [],
    ...over,
  };
}

describe("reportGroups", () => {
  it("groups a vibe's items by outcome, unknown statuses as Other", () => {
    const groups = reportGroups(
      report({
        items: [
          item("a", "applied"),
          item("b", "partial"),
          item("c", "deferred"),
          item("d", "scope_rejected"),
          item("e", "not_reported"),
          item("f", null),
          item("g", "brand_new_status"),
        ],
      }),
    );
    expect(groups.map((g) => [g.label, g.items.length])).toEqual([
      ["Applied", 1],
      ["Still open", 2],
      ["Out of scope", 1],
      ["Not reported", 2],
      ["Other: brand_new_status", 1],
    ]);
  });

  it("an install's items read Marked done and Reopened", () => {
    const groups = reportGroups(
      report({ intent: "install", items: [item("a", "applied"), item("b", "reopened"), item("c", "reopened")] }),
    );
    expect(groups.map((g) => [g.key, g.items.length])).toEqual([
      ["marked_done", 1],
      ["reopened", 2],
    ]);
  });
});

describe("reportHeadline", () => {
  it.each([
    ["dry_run_pending_install", /^Dry Run\. Nothing was marked done yet\. Install this draft to mark the 2 feedback items it applied done\.$/],
    ["dry_run_installed", /installed since/],
    ["no_outcomes_reported", /did not report per-feedback outcomes, so nothing was marked done; the feedback stays open and selected/],
    ["malformed", /could not be read/],
    ["sync_failed", /sync did not finish/],
    ["pre_0_9_0", /before the app kept per-feedback reports/],
  ] as const)("%s", (note, re) => {
    const r = report({ consume_note: note, items: [item("a", "applied"), item("b", "applied")] });
    expect(reportHeadline(r)).toMatch(re);
  });

  it("names the versions of a mismatch", () => {
    expect(reportHeadline(report({ consume_note: "version_mismatch", expected_version: 4, fetched_version: 3 }))).toMatch(
      /was for v3, not v4/,
    );
  });

  it("counts an install's marked-done and reopened items", () => {
    const r = report({ intent: "install", consume_note: "install_consumed", items: [item("a", "applied"), item("b", "reopened")] });
    expect(reportHeadline(r)).toBe("This install marked 1 feedback item done and reopened 1 feedback item.");
  });

  it("leaves out a zero count", () => {
    const r = report({ intent: "install", consume_note: "install_consumed", items: [item("a", "applied"), item("b", "applied")] });
    expect(reportHeadline(r)).toBe("This install marked 2 feedback items done.");
  });

  it("says a pre-0.9.0 install consumed and reopened nothing", () => {
    expect(reportHeadline(report({ intent: "install", consume_note: null }))).toMatch(/Nothing was marked done or reopened/);
  });

  it("is null for a run that sent no feedback", () => {
    expect(reportHeadline(report({ intent: "new-base-model", consume_note: null }))).toBeNull();
  });
});

describe("itemState", () => {
  it("reads the item's state now", () => {
    expect(itemState(item("a", "applied", { consumed: true }))).toBe("Done");
    expect(itemState(item("a", "partial", { selected_for_run: true }))).toBe("Open, selected");
    expect(itemState(item("a", "reopened", { selected_for_run: false }))).toBe("Open");
    expect(itemState(item("a", null, { status: "deprecated" }))).toBe("Deleted");
  });
});
