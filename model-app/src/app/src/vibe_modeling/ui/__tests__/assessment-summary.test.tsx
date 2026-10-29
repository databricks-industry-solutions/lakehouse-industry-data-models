import { beforeEach, describe, expect, it, vi } from "vitest";
import { render, screen, within } from "@testing-library/react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";

const api = vi.hoisted(() => ({ useGetAssessmentDocContent: vi.fn() }));
vi.mock("@/lib/api", async () => {
  const actual = await vi.importActual<typeof import("@/lib/api")>("@/lib/api");
  return { ...actual, ...api };
});

import { Scorecard } from "@/components/assessment/scorecard";
import { LetterBadge } from "@/components/assessment/letter-badge";

const summary = {
  verdict: "iterate_first",
  verdict_reason: "Two entities lack sources",
  headline: "Sales order is mostly buildable but two entities need work.",
  key_findings: ["Order maps 81% of columns", "Invoice has no source"],
  top_risks: ["Credit check has no data"],
  recommended_next_step: "Ingest vbkd before building.",
};
const results = (over: Record<string, unknown> = {}) =>
  ({
    domain_run: {
      id: "r1", domain_name: "sales_order", status: "completed", model_quality_score: 72, skills_version: "0.4.0",
      skills_commit: "", genie_version: "v1", metamodel_location: "", metamodel_version: "",
    },
    grades: { full: 0, partial: 1, blocked: 1 },
    letter_counts: { A: 0, B: 1, C: 2, D: 0, F: 1 },
    entities: [], gaps: [], pending_decisions: [], next_vibes: [],
    summary, ...over,
  }) as never;
const mount = (r = results()) =>
  render(
    <QueryClientProvider client={new QueryClient()}>
      <Scorecard results={r} />
    </QueryClientProvider>,
  );

describe("Scorecard executive summary", () => {
  beforeEach(() => {
    api.useGetAssessmentDocContent.mockReset();
    api.useGetAssessmentDocContent.mockReturnValue({ data: undefined, isError: false, isLoading: false });
  });

  it("shows verdict, headline, findings, risks and the next step", () => {
    mount();
    expect(screen.getByText("Iterate first")).toBeTruthy();
    expect(screen.getByText(summary.headline)).toBeTruthy();
    expect(screen.getByText("Invoice has no source")).toBeTruthy();
    expect(screen.getByText("Credit check has no data")).toBeTruthy();
    expect(screen.getByText("Do this next")).toBeTruthy();
    expect(screen.getByText("Ingest vbkd before building.")).toBeTruthy();
  });

  it("colors non-zero letter chips and mutes zeros", () => {
    mount();
    expect(screen.getByText("1 B").className).toContain("bg-teal-100");
    expect(screen.getByText("0 A").className).toContain("opacity-40");
    expect(screen.getByText("0 A").className).not.toContain("bg-green-100");
  });

  it("omits empty findings and risks headings", () => {
    mount(results({ summary: { ...summary, key_findings: [], top_risks: [] } }));
    expect(screen.queryByText("Key findings")).toBeNull();
    expect(screen.queryByText("Top risks")).toBeNull();
  });

  it("shows letter chips with zero letters muted", () => {
    mount();
    expect(screen.getByText("0 A")).toBeTruthy();
    expect(screen.getByText("2 C")).toBeTruthy();
    expect(screen.getByText("0 A").className).toContain("opacity");
    expect(screen.getByText("2 C").className).not.toContain("opacity");
  });

  it("falls back to the markdown doc when summary is null", () => {
    api.useGetAssessmentDocContent.mockReturnValue({
      data: { data: { content: "Fallback readiness text", path: "docs/design/domain_readiness_summary.md", truncated: false } },
      isError: false, isLoading: false,
    });
    mount(results({ summary: null }));
    expect(screen.getByText("Fallback readiness text")).toBeTruthy();
    expect(api.useGetAssessmentDocContent.mock.calls[0][0].params).toEqual({
      domain_run_id: "r1", path: "docs/design/domain_readiness_summary.md",
    });
  });

  it("renders no summary card when summary is null and the doc 404s", async () => {
    const { ApiError } = await import("@/lib/api");
    api.useGetAssessmentDocContent.mockReturnValue({
      data: undefined, isError: true, isLoading: false, error: new ApiError(404, "Not Found", { detail: "Document not found." }),
    });
    mount(results({ summary: null }));
    expect(screen.queryByTestId("summary-admin-help")).toBeNull();
    expect(screen.queryByText("Do this next")).toBeNull();
    expect(screen.getByText("Scorecard")).toBeTruthy();
  });
});

describe("Scorecard summary fallback errors", () => {
  beforeEach(() => api.useGetAssessmentDocContent.mockReset());
  it("shows the admin-help block when the readiness-summary doc cannot be read", async () => {
    const { ApiError } = await import("@/lib/api");
    api.useGetAssessmentDocContent.mockReturnValue({
      data: undefined, isLoading: false, isError: true,
      error: new ApiError(409, "Conflict", { detail: { error: "admin_help", message: "Could not read doc: denied" } }),
    });
    mount(results({ summary: null }));
    expect(within(screen.getByTestId("summary-admin-help")).getByText("Could not read doc: denied")).toBeTruthy();
  });
});

describe("NextStepGuide", () => {
  beforeEach(() => {
    api.useGetAssessmentDocContent.mockReset();
    api.useGetAssessmentDocContent.mockReturnValue({ data: undefined, isError: false, isLoading: false });
  });

  it("shows before_build vibe refs in step 1 detail", () => {
    mount(
      results({
        structure_counts: { sound: 1, review: 1, rework: 0 },
        pending_decisions: [{ ordinal: 0, kind: "structure", answer_status: "open", entity: "bill", affected: [] }],
        next_vibes: [
          { id: "v1", priority: 1, urgency: "before_build", affected_entities: ["bill"], text: "", problem: "", proposed_change: "", impact_if_skipped: "", category: "", confidence: null },
          { id: "v2", priority: 2, urgency: "during_build", affected_entities: ["payment"], text: "", problem: "", proposed_change: "", impact_if_skipped: "", category: "", confidence: null },
        ],
      }),
    );
    // Step 1 should show the before_build vibe ref (Vibe 1) in the detail
    expect(screen.getByText(/Review the next vibes \(Vibe 1\)/)).toBeTruthy();
  });

  it("shows linked vibe refs when no before_build vibes exist", () => {
    mount(
      results({
        structure_counts: { sound: 1, review: 1, rework: 0 },
        pending_decisions: [{ ordinal: 0, kind: "structure", answer_status: "open", entity: "payment", affected: [] }],
        next_vibes: [
          { id: "v3", priority: 3, urgency: "during_build", affected_entities: ["payment"], text: "", problem: "", proposed_change: "", impact_if_skipped: "", category: "", confidence: null },
        ],
      }),
    );
    // Step 1 should show the linked vibe ref (Vibe 3) when no before_build vibes
    expect(screen.getByText(/Review the next vibes \(Vibe 3\)/)).toBeTruthy();
  });
});

describe("LetterBadge", () => {
  it("shows the letter, or only the gate label when null", () => {
    const { rerender } = render(<LetterBadge letter="B" gate="partial" />);
    expect(screen.getByText("B")).toBeTruthy();
    rerender(<LetterBadge letter={null} gate="blocked" />);
    expect(screen.getByText("Blocked")).toBeTruthy();
  });
});
