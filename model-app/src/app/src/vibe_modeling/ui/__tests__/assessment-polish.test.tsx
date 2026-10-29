import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";
import { fireEvent, render, screen, within } from "@testing-library/react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";

const api = vi.hoisted(() => ({
  useGetAssessmentResultsSuspense: vi.fn(),
  useListAssessmentDocs: vi.fn(),
  useGetAssessmentDocContent: vi.fn(),
  useGetAssessmentHandoffSuspense: vi.fn(),
}));
vi.mock("@/lib/api", async () => {
  const actual = await vi.importActual<typeof import("@/lib/api")>("@/lib/api");
  return { ...actual, ...api };
});

import { AgentText, plainAgentText } from "@/components/assessment/agent-text";
import { DomainResults } from "@/components/assessment/domain-results";
import { INLINE_CODE_CLASS } from "@/components/ui/markdown-view";

const opt = (id: string, label: string, over: Record<string, unknown> = {}) => ({
  id, label, ordinal: 0, pros: [], cons: [], impact: "", recommended: false, ...over,
});
const results = () => ({
  domain_run: {
    id: "r1", domain_id: "d1", domain_name: "sales_order", status: "completed", model_quality_score: 72,
    skills_version: "0.4.0", skills_commit: "", genie_version: "v1", metamodel_location: "", metamodel_version: "",
  },
  grades: { full: 0, partial: 1, blocked: 0 },
  letter_counts: { A: 0, B: 1, C: 0, D: 0, F: 0 },
  summary: {
    verdict: "iterate_first", verdict_reason: "`sales_tender` lacks a source",
    headline: "Map `sales_tender` first", key_findings: ["`order` maps 81%"], top_risks: [],
    recommended_next_step: "Ingest `vbkd`.",
  },
  entities: [
    { id: "e1", domain_run_id: "r1", product_id: "p1", in_model: true, name: "order", grade: "partial", coverage_pct: 80,
      primary_source: "sap.vbak", row_count: 10, net_new_candidate: false, mapped: 1, gap: 0, deferred_fk: 0, dup_source: 0,
      letter_grade: "B", structure: "sound", structure_refs: [], deferred_fk_count: 1, columns: [] },
  ],
  gaps: [{ id: "g1", domain_run_id: "r1", entity: "order", column: "incoterms", gap_type: "NULL_SOURCE",
    description: "No source for `incoterms`", status: "OPEN", ask: "Ingest `vbkd`" }],
  pending_decisions: [{
    id: "dec1", domain_run_id: "r1", ordinal: 0, kind: "source", gate: "G2", entity: "order",
    question: "Source `sales_tender` from `pos.tender`?", context: "`sales_tender` has no table.",
    why_it_matters: "", recommendation_rationale: "`pos.tender` is complete.", blocks_build: false,
    default_taken: "", evidence: "", affected: [],
    options: [opt("o1", "Use `pos.tender`", { pros: ["Fills `amount`"], recommended: true }), opt("o2", "Defer", { cons: ["x"] })],
    answer_status: "open", answer_option_id: null, answer_text: "", answered_by: "", answered_at: null,
  }],
  next_vibes: [],
  structure_counts: { sound: 1, review: 0, rework: 0 },
});

const mount = () =>
  render(
    <QueryClientProvider client={new QueryClient()}>
      <DomainResults domainRunId="r1" />
    </QueryClientProvider>,
  );
const openTab = (name: RegExp | string) => {
  const t = screen.getByRole("tab", { name });
  fireEvent.mouseDown(t, { button: 0 });
  fireEvent.click(t);
};
const codes = (root: HTMLElement) => [...root.querySelectorAll("code")].map((c) => c.textContent);

describe("AgentText", () => {
  it("renders backtick spans as inline code and keeps the rest as text", () => {
    const { container } = render(<p><AgentText text="Map `a.b` then `c`, not d" /></p>);
    expect(container.textContent).toBe("Map a.b then c, not d");
    expect(codes(container)).toEqual(["a.b", "c"]);
    expect(container.querySelector("code")!.className).toBe(INLINE_CODE_CLASS);
  });
  it("leaves an unpaired backtick and empty text as written", () => {
    const { container } = render(<p><AgentText text="a `b" /></p>);
    expect(container.textContent).toBe("a `b");
    expect(container.querySelector("code")).toBeNull();
    const empty = render(<p data-testid="e"><AgentText text={null} /></p>);
    expect(empty.getByTestId("e").textContent).toBe("");
  });
  it("styles code with theme tokens only, so it follows light and dark", () => {
    for (const theme of ["light", "dark"]) {
      document.documentElement.classList.add(theme);
      const { container, unmount } = render(<AgentText text="`x`" />);
      const cls = container.querySelector("code")!.className;
      expect(cls).toMatch(/\bbg-muted\//);
      expect(cls).not.toMatch(/-(?:50|[1-9]00)\b/);
      unmount();
      document.documentElement.classList.remove(theme);
    }
  });
});

describe("plainAgentText", () => {
  it("drops the backticks of paired spans only", () => {
    expect(plainAgentText("Use `a.b` or `c`; keep `x")).toBe("Use a.b or c; keep `x");
    expect(plainAgentText("")).toBe("");
  });
});

describe("Assessment results polish", () => {
  beforeEach(() => {
    api.useGetAssessmentResultsSuspense.mockReturnValue({ data: results() });
    api.useGetAssessmentDocContent.mockReturnValue({ data: undefined, isError: false, isLoading: false });
  });
  afterEach(() => vi.clearAllMocks());

  it("contains wide tab content inside the results panel", () => {
    mount();
    expect(screen.getByTestId("results-tabs").className).toContain("[contain:inline-size]");
  });

  it("renders agent backticks as inline code on the Scorecard", () => {
    const { container } = mount();
    expect(codes(container)).toEqual(expect.arrayContaining(["sales_tender", "order", "vbkd"]));
    expect(container.textContent).not.toContain("`");
  });

  it("renders agent backticks as inline code on Gaps", () => {
    mount();
    openTab("Gaps");
    const panel = screen.getByRole("tabpanel");
    expect(codes(panel)).toEqual(["incoterms", "vbkd"]);
    expect(panel.textContent).not.toContain("`");
  });

  it("renders agent backticks as inline code on Decisions", () => {
    mount();
    openTab(/Decisions/);
    const panel = screen.getByRole("tabpanel");
    expect(codes(panel)).toEqual(expect.arrayContaining(["sales_tender", "pos.tender", "amount"]));
    expect(panel.textContent).not.toContain("`");
    expect(within(panel).getByText(/Recommended:/).textContent).toBe("Recommended: Use pos.tender — pos.tender is complete.");
  });

  it("renders every Entities and Gaps header in title case, sortable or not", () => {
    mount();
    for (const tab of ["Entities", "Gaps"]) {
      openTab(tab);
      const ths = [...screen.getByRole("tabpanel").querySelectorAll("thead th")];
      expect(ths.length).toBeGreaterThan(0);
      for (const th of ths) expect(th.className).not.toMatch(/\b(uppercase|capitalize)\b/);
    }
    openTab("Entities");
    const thead = screen.getByRole("tabpanel").querySelector("thead")!;
    expect(within(thead).getByText("Deferred FK").tagName).toBe("TH");
    expect(within(thead).getByText("Source").tagName).toBe("TH");
  });

  it("names the decision radios and groups without the agent's backticks", () => {
    mount();
    openTab(/Decisions/);
    const panel = screen.getByRole("tabpanel");
    expect((within(panel).getByRole("radio", { name: "Use pos.tender" }) as HTMLInputElement).checked).toBe(true);
    expect(within(panel).getByRole("radiogroup", { name: "Source sales_tender from pos.tender?" })).toBeTruthy();
  });
});
