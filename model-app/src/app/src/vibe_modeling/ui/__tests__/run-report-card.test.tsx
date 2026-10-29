/**
 * The run report card (design §2 UI) and its compact form on the version
 * Overview: header sentence, groups with reasons, "Select these" on the
 * reopened group, "Install this draft", the lineage callout (skipped for a
 * replaced head) and the unmatched count.
 */
import { beforeEach, describe, expect, it, vi } from "vitest";
import { act, fireEvent, screen, waitFor } from "@testing-library/react";
import type { RunReportItemOut, RunReportOut } from "@/lib/api";

const selectMock = vi.fn();
let versionReport: RunReportOut | null = null;
vi.mock("@/lib/api", async () => {
  const actual = await vi.importActual<typeof import("@/lib/api")>("@/lib/api");
  return {
    ...actual,
    useSetVibeInputSelection: () => ({ mutateAsync: (...a: unknown[]) => selectMock(...a) }),
    useGetVersionReport: () => ({ data: { data: { version_id: "mv-4", report: versionReport } } }),
  };
});
vi.mock("sonner", () => ({ toast: { success: vi.fn(), error: vi.fn(), warning: vi.fn() } }));
vi.mock("@/components/runs/version-operation-dialog", () => ({
  VersionOperationDialog: ({ open, version }: { open: boolean; version: { id: string } }) =>
    open ? <div data-testid={`stub-install-${version.id}`} /> : null,
}));

import { RunReportBody, VersionReportCompact, lineageCallout } from "@/components/runs/run-report-card";
import { renderWithRouter } from "./helpers/router-wrapper";
import { makeModelVersion } from "./helpers/model-version";

function item(id: string, outcome: string | null, over: Partial<RunReportItemOut> = {}): RunReportItemOut {
  return {
    input_id: id, outcome_status: outcome, created_at: "2026-10-20T00:00:00Z", text: `feedback ${id}`,
    origin: "user", priority: "medium", status: "active", consumed: false, selected_for_run: false, ...over,
  } as RunReportItemOut;
}
function report(over: Partial<RunReportOut> = {}): RunReportOut {
  return {
    run_id: "r1", business_id: "b1", intent: "vibe-iterate", run_status: "completed", dry_run: false,
    has_agent_report: true, has_input_outcomes: true, version_mismatch: false, items: [], ...over,
  };
}

const draft = makeModelVersion({ id: "mv-4", version: 4, status: "draft", dry_run: true, draft_state: "ready", is_head: false });
const head = makeModelVersion({ id: "mv-3", version: 3 });

beforeEach(() => {
  selectMock.mockReset();
  versionReport = null;
});

describe("RunReportBody", () => {
  it("renders the header, groups and the agent's reasons", async () => {
    renderWithRouter(
      <RunReportBody
        businessId="b1"
        versions={[head]}
        report={report({ items: [item("a", "applied", { consumed: true }), item("b", "partial", { outcome_reason: "only half of it" })] })}
      />,
    );
    expect(await screen.findByTestId("report-headline")).toHaveTextContent("1 feedback item applied and marked done.");
    expect(screen.getByTestId("report-group-applied")).toHaveTextContent("Done");
    expect(screen.getByTestId("report-group-still_open")).toHaveTextContent("only half of it");
    expect(screen.getByRole("link", { name: "How the agent uses your feedback" })).toHaveAttribute("href", "/help/vibes");
  });

  it("offers 'Install this draft' on a Dry Run whose draft is not installed", async () => {
    renderWithRouter(
      <RunReportBody
        businessId="b1"
        versions={[draft]}
        report={report({ dry_run: true, consume_note: "dry_run_pending_install", output_version_id: "mv-4", items: [item("a", "applied")] })}
      />,
    );
    fireEvent.click(await screen.findByTestId("report-install-draft"));
    expect(screen.getByTestId("stub-install-mv-4")).toBeInTheDocument();
  });

  it("'Select these' selects the reopened items of an install", async () => {
    selectMock.mockResolvedValue({ data: {} });
    renderWithRouter(
      <RunReportBody
        businessId="b1"
        versions={[]}
        report={report({
          intent: "install", consume_note: "install_consumed",
          items: [item("a", "applied", { consumed: true }), item("b", "reopened"), item("c", "reopened", { selected_for_run: true })],
        })}
      />,
    );
    expect(await screen.findByTestId("report-group-reopened")).toBeInTheDocument();
    await act(async () => {
      fireEvent.click(screen.getByTestId("report-select-these"));
    });
    await waitFor(() =>
      expect(selectMock).toHaveBeenCalledWith({ params: { business_id: "b1" }, data: { input_ids: ["b"], selected: true } }),
    );
  });

  it("shows the unmatched count", async () => {
    renderWithRouter(
      <RunReportBody businessId="b1" versions={[]} report={report({ unmatched_outcome_count: 2, items: [item("a", "applied")] })} />,
    );
    expect(await screen.findByTestId("report-unmatched")).toHaveTextContent("2 outcomes the agent reported");
  });

  it("renders nothing for a run with nothing to report", async () => {
    const { container } = renderWithRouter(
      <RunReportBody businessId="b1" versions={[]} report={report({ intent: "new-base-model" })} />,
    );
    await waitFor(() => expect(container.querySelector('[data-testid="run-report-card"]')).toBeNull());
  });
});

describe("lineageCallout", () => {
  const out = makeModelVersion({ id: "mv-6", version: 6, scope: "ecm" });
  it("names the newer version the agent did not build on", () => {
    const v5 = makeModelVersion({ id: "mv-5", version: 5, scope: "ecm" });
    const r = report({ lineage_stale: true, lineage_base_version: 4, lineage_head_at_write: 5, output_version_id: "mv-6" });
    expect(lineageCallout(r, [out, v5])).toMatch(/built this on v4 while v5 was the latest/);
  });
  it("skips a head the user replaced", () => {
    const v5 = makeModelVersion({ id: "mv-5", version: 5, scope: "ecm", replaced_at: "2026-10-21T00:00:00Z" });
    const r = report({ lineage_stale: true, lineage_base_version: 4, lineage_head_at_write: 5, output_version_id: "mv-6" });
    expect(lineageCallout(r, [out, v5])).toBeNull();
  });
});

describe("VersionReportCompact", () => {
  it("shows the producing run's headline, counts and a link", async () => {
    versionReport = report({ dry_run: true, consume_note: "dry_run_pending_install", items: [item("a", "applied"), item("b", "deferred")] });
    renderWithRouter(<VersionReportCompact businessId="b1" version={draft} versions={[draft]} />);
    const line = await screen.findByTestId("version-report-compact");
    expect(line).toHaveTextContent("Dry Run. Nothing was marked done yet.");
    expect(line).toHaveTextContent("Applied 1 · Still open 1");
    expect(screen.getByRole("link", { name: "Open the run report" })).toHaveAttribute("href", "/businesses/b1/runs/r1");
  });

  it("renders nothing without a producing run", async () => {
    const { container } = renderWithRouter(<VersionReportCompact businessId="b1" version={head} versions={[head]} />);
    await waitFor(() => expect(container.querySelector('[data-testid="version-report-compact"]')).toBeNull());
  });
});
