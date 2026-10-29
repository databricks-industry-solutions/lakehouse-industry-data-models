import { beforeEach, describe, expect, it, vi } from "vitest";
import { fireEvent, render, screen, within } from "@testing-library/react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";

const api = vi.hoisted(() => ({ useGetAssessmentDocContent: vi.fn(), useListAssessmentDocs: vi.fn() }));
vi.mock("@/lib/api", async () => {
  const actual = await vi.importActual<typeof import("@/lib/api")>("@/lib/api");
  return { ...actual, ...api };
});

import { NextVibesList } from "@/components/assessment/next-vibes-list";
import { DocsPane } from "@/components/assessment/doc-viewer";

const vibe = (over: Record<string, unknown>) => ({
  id: "v", domain_run_id: "r1", priority: 1, category: "source", text: "legacy text", confidence: 0.8,
  problem: "", proposed_change: "", impact_if_skipped: "", urgency: "", affected_entities: [], ...over,
});
const vibes = [
  vibe({ id: "a", urgency: "later", problem: "Later problem" }),
  vibe({ id: "b", urgency: "before_build", problem: "Before problem", proposed_change: "Add vbkd", impact_if_skipped: "Wrong prices", affected_entities: ["order_header"] }),
  vibe({ id: "c", urgency: "during_build", problem: "During problem" }),
  vibe({ id: "d", urgency: "", text: "Old style vibe" }),
];
const mountVibes = (v: unknown[], verdict: string | null = "iterate_first") => {
  const qc = new QueryClient({
    defaultOptions: { queries: { retry: false } },
  });
  return render(
    <QueryClientProvider client={qc}>
      <NextVibesList vibes={v as never} verdict={verdict} domainRunId="r1" />
    </QueryClientProvider>,
  );
};

describe("NextVibesList banner honesty", () => {
  it("is neutral for all-unclassified with no verdict", () => {
    mountVibes([vibes[3]], null);
    expect(screen.queryByText(/Safe to continue/)).toBeNull();
    expect(screen.getByText(/weren't classified by urgency/)).toBeTruthy();
  });
  it("is neutral for null verdict with classified vibes", () => {
    mountVibes([vibes[0]], null);
    expect(screen.queryByText(/Safe to continue/)).toBeNull();
    expect(screen.getByText(/weren't classified by urgency/)).toBeTruthy();
  });
  it("is safe for ready_to_build with nothing before build", () => {
    mountVibes([vibes[3]], "ready_to_build");
    expect(screen.getByText("Safe to continue to hand-off")).toBeTruthy();
  });
});

describe("NextVibesList by urgency", () => {
  it("orders sections and shows the before-build banner", () => {
    mountVibes(vibes);
    expect(screen.getByText(/Run these.*change.*before you build/)).toBeTruthy();
    const heads = screen.getAllByRole("heading", { level: 4 }).map((h) => h.textContent);
    expect(heads).toEqual(["Before build", "During build", "Later", "Unclassified"]);
    expect(screen.getByText("Add vbkd")).toBeTruthy();
    expect(screen.getByText(/Wrong prices/)).toBeTruthy();
    expect(screen.getByText("order_header")).toBeTruthy();
    expect(screen.getByText(/add the ones you keep as vibe inputs/i)).toBeTruthy();
  });
  it("shows safe banner and hides empty sections", () => {
    mountVibes([vibes[0]], "ready_to_build");
    expect(screen.getByText("Safe to continue to hand-off")).toBeTruthy();
    expect(screen.queryByText("Before build")).toBeNull();
  });
  it("shows blocked banner when no before_build vibes", () => {
    // When there are no before_build vibes, show blocked
    mountVibes([vibes[0], vibes[2], vibes[3]], "blocked");
    expect(screen.getByText(/Blocked entities/)).toBeTruthy();
  });
  it("shows amber before_build banner even when verdict is blocked", () => {
    // When verdict is blocked but there are before_build vibes, before_build takes precedence
    mountVibes(vibes, "blocked");
    expect(screen.getByText(/Run these.*change.*before you build/)).toBeTruthy();
    expect(screen.queryByText(/Blocked entities/)).toBeNull();
  });
  it("puts old vibes in Unclassified with their text", () => {
    mountVibes([vibes[3]]);
    expect(screen.getByText("Unclassified")).toBeTruthy();
    expect(screen.getByText("Old style vibe")).toBeTruthy();
  });
});

const docs = {
  folder_url: "https://ws/browse/run",
  docs: [
    { name: "domain_readiness_summary.md", path: "docs/design/domain_readiness_summary.md", category: "design" },
    { name: "s2t_map.md", path: "docs/design/s2t_map.md", category: "design" },
    { name: "notes.md", path: "docs/notes.md", category: "other" },
    { name: "skill_feedback.md", path: "docs/commentary/skill_feedback.md", category: "commentary" },
  ],
};

describe("DocsPane", () => {
  beforeEach(() => {
    api.useListAssessmentDocs.mockReturnValue({ data: docs, isLoading: false });
    api.useGetAssessmentDocContent.mockImplementation(({ params }: { params: { path: string } }) => ({
      data: { data: { path: params.path, content: params.path.includes("s2t") ? "# S2T heading" : "# Summary heading", truncated: params.path.includes("s2t") } },
      isLoading: false, isError: false,
    }));
  });
  const mount = () =>
    render(<QueryClientProvider client={new QueryClient()}><DocsPane domainRunId="r1" /></QueryClientProvider>);

  it("preselects the readiness summary and renders markdown", () => {
    mount();
    expect(screen.getByRole("heading", { name: "Summary heading" })).toBeTruthy();
  });
  it("loads a clicked doc by path and shows truncated notice", () => {
    mount();
    fireEvent.click(screen.getByText("s2t_map.md"));
    expect(api.useGetAssessmentDocContent).toHaveBeenLastCalledWith(
      expect.objectContaining({ params: { domain_run_id: "r1", path: "docs/design/s2t_map.md" } }),
    );
    expect(screen.getByRole("heading", { name: "S2T heading" })).toBeTruthy();
    expect(screen.getByText(/truncated/i)).toBeTruthy();
  });
  it("groups commentary in a collapsed section and links the folder", () => {
    const { container } = mount();
    const details = container.querySelector("details")!;
    expect(details.open).toBe(false);
    expect(details.textContent).toContain("Feedback for the skill authors");
    expect(details.textContent).toContain("skill_feedback.md");
    expect(screen.getByText("Browse folder").closest("a")!.getAttribute("href")).toBe("https://ws/browse/run");
  });
  it("selects a doc when a relative .md link is clicked", () => {
    api.useGetAssessmentDocContent.mockImplementation(({ params }: { params: { path: string } }) => ({
      data: { data: { path: params.path, content: params.path.includes("notes") ? "# Notes heading" : "[go](../notes.md) [ext](https://x.io)", truncated: false } },
      isLoading: false, isError: false,
    }));
    mount();
    fireEvent.click(screen.getByText("go"));
    expect(screen.getByRole("heading", { name: "Notes heading" })).toBeTruthy();
  });
  it("opens the commentary section when a commentary doc is selected", () => {
    const { container } = mount();
    fireEvent.click(screen.getByText("skill_feedback.md"));
    expect(container.querySelector("details")!.open).toBe(true);
  });
  it("shows the admin-help block, not the empty message, when listing the docs fails, without retrying", async () => {
    const { ApiError } = await import("@/lib/api");
    api.useListAssessmentDocs.mockReturnValue({
      data: undefined, isLoading: false,
      error: new ApiError(409, "Conflict", {
        detail: {
          error: "admin_help", message: "Could not list run docs: denied for [REDACTED]",
          job_url: "https://ws/jobs/7", run_url: "https://ws/jobs/7/runs/9", runs_path: "/Volumes/c/_metamodel/assess_runs/b1/d1",
        },
      }),
    });
    mount();
    const block = within(screen.getByTestId("docs-admin-help"));
    expect(block.getByText("Could not list run docs: denied for [REDACTED]")).toBeTruthy();
    expect(block.getByText(/The run's documents couldn't be read\./)).toBeTruthy();
    expect(block.getByRole("link", { name: /Open job run/ }).getAttribute("href")).toBe("https://ws/jobs/7/runs/9");
    expect(block.getByText("/Volumes/c/_metamodel/assess_runs/b1/d1")).toBeTruthy();
    expect(screen.queryByText("No docs were produced.")).toBeNull();
    expect(api.useListAssessmentDocs).toHaveBeenCalledWith(
      expect.objectContaining({ query: expect.objectContaining({ retry: false }) }),
    );
  });
  it("shows a plain error line for a non-admin-help listing failure", async () => {
    const { ApiError } = await import("@/lib/api");
    api.useListAssessmentDocs.mockReturnValue({
      data: undefined, isLoading: false, error: new ApiError(404, "Not Found", { detail: "Assessment domain run not found." }),
    });
    mount();
    expect(screen.getByText("Assessment domain run not found.")).toBeTruthy();
    expect(screen.queryByTestId("docs-admin-help")).toBeNull();
    expect(screen.queryByText("No docs were produced.")).toBeNull();
  });
  it("keeps the empty message for a run with no docs", () => {
    api.useListAssessmentDocs.mockReturnValue({ data: { folder_url: "", docs: [] }, isLoading: false, error: null });
    mount();
    expect(screen.getByText("No docs were produced.")).toBeTruthy();
  });
  it("shows the admin-help block when reading one doc fails", async () => {
    const { ApiError } = await import("@/lib/api");
    api.useGetAssessmentDocContent.mockReturnValue({
      data: undefined, isLoading: false, isError: true,
      error: new ApiError(409, "Conflict", { detail: { error: "admin_help", message: "Could not read doc: denied" } }),
    });
    mount();
    expect(within(screen.getByTestId("doc-admin-help")).getByText("Could not read doc: denied")).toBeTruthy();
    expect(screen.queryByText("This document could not be loaded.")).toBeNull();
  });
  it("has no anchors to file-level paths", () => {
    const { container } = mount();
    const hrefs = [...container.querySelectorAll("a")].map((a) => a.getAttribute("href"));
    expect(hrefs.every((h) => h === "https://ws/browse/run")).toBe(true);
  });
});
