/**
 * `FeedbackList` coverage.
 *
 * The Feedback tab reuses the canonical Edit-Inputs `SectionTree` over the
 * unified VibeInput store (origin=user), as a review-only list: the
 * run-inclusion checkbox is hidden (`selectable={false}`) and each card gets a
 * delete action wired to `deleteVibeInput`. `SectionTree`'s own grouping/render
 * is covered by its dedicated test; here we assert FeedbackList's wiring.
 *
 * Scenarios:
 *   1. Empty list → renders the empty-state copy (SectionTree not mounted).
 *   2. Non-empty → mounts SectionTree review-only (selectable=false) with the
 *      active user inputs.
 *   3. The wired delete handler calls `deleteVibeInput` with the input id.
 */
import { afterEach, describe, expect, it, vi } from "vitest";
import { fireEvent, render, screen } from "@testing-library/react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import type { ReactNode } from "react";

const FEEDBACK_HAPPY = [
  {
    id: "fb-1",
    business_id: "biz-1",
    author: "alice",
    text: "Add timestamps to inventory tables",
    origin: "user",
    priority: "medium",
    confidence_score: null,
    consumed: false,
    selected_for_run: false,
    status: "active",
    deprecated_by: null,
    created_at: "2026-04-20T00:00:00Z",
    updated_at: "2026-04-20T00:00:00Z",
    anchor: { level: "element", domain_name: "inventory", path: ["Domain inventory"] },
  },
  {
    id: "fb-2",
    business_id: "biz-1",
    author: "bob",
    text: "Cross-domain join missing",
    origin: "user",
    priority: "medium",
    confidence_score: null,
    consumed: false,
    selected_for_run: false,
    status: "deprecated",
    deprecated_by: "alice",
    created_at: "2026-04-20T00:00:00Z",
    updated_at: "2026-04-20T00:00:00Z",
    anchor: { level: "model_wide", path: [] },
  },
];

const FEEDBACK_MULTI_DOMAIN = [
  { ...FEEDBACK_HAPPY[0] },
  {
    ...FEEDBACK_HAPPY[0],
    id: "fb-3",
    text: "Sales orders need currency",
    anchor: { level: "element", domain_name: "sales", path: ["Domain: sales"] },
  },
  {
    ...FEEDBACK_HAPPY[0],
    id: "fb-4",
    text: "Overall naming is inconsistent",
    anchor: { level: "model_wide", path: [] },
  },
];

let feedbackData: unknown[] = FEEDBACK_HAPPY;

// Capture the props the FeedbackList hands to the (mocked) SectionTree.
let sectionTreeProps: Record<string, unknown> = {};

vi.mock("@/lib/api", async () => {
  const actual = await vi.importActual<typeof import("@/lib/api")>("@/lib/api");
  return {
    ...actual,
    useListVibeInputsSuspense: () => ({ data: feedbackData }),
    createVibeInput: vi.fn().mockResolvedValue({}),
    updateVibeInput: vi.fn().mockResolvedValue({}),
    deleteVibeInput: vi.fn().mockResolvedValue({}),
  };
});

vi.mock("@/components/vibe-inputs/section-tree", () => ({
  SectionTree: (props: Record<string, unknown>) => {
    sectionTreeProps = props;
    const inputs = (props.inputs as { id: string; text: string }[]) ?? [];
    return (
      <div data-testid="section-tree">
        {inputs.map((i) => (
          <div key={i.id}>{i.text}</div>
        ))}
      </div>
    );
  },
}));

vi.mock("@/components/vibe-inputs/input-markdown-editor-dialog", () => ({
  InputMarkdownEditorDialog: () => null,
}));

vi.mock("@/components/vibe-inputs/query-keys", () => ({
  invalidateVibeInputQueries: vi.fn(),
}));

vi.mock("@tanstack/react-router", () => ({
  useNavigate: () => vi.fn(),
}));

vi.mock("@/lib/selector", () => ({
  selector: () => ({}),
  default: () => ({}),
}));

vi.mock("sonner", () => ({
  toast: { error: vi.fn(), success: vi.fn() },
}));

import { FeedbackList } from "@/components/feedback/feedback-list";
import { deleteVibeInput } from "@/lib/api";

function withQuery(ui: ReactNode) {
  const qc = new QueryClient({
    defaultOptions: { queries: { retry: false }, mutations: { retry: false } },
  });
  return <QueryClientProvider client={qc}>{ui}</QueryClientProvider>;
}

const baseProps = { businessId: "biz-1", version: "1", scope: "ecm", versionId: "v-1" };

afterEach(() => {
  feedbackData = FEEDBACK_HAPPY;
  sectionTreeProps = {};
  vi.clearAllMocks();
});

describe("FeedbackList", () => {
  it("renders an empty-state when no active feedback exists", () => {
    feedbackData = [];
    render(withQuery(<FeedbackList {...baseProps} />));
    expect(screen.getByText(/No feedback yet/i)).toBeInTheDocument();
    expect(screen.queryByTestId("section-tree")).not.toBeInTheDocument();
  });

  it("mounts SectionTree review-only with the active user inputs", () => {
    render(withQuery(<FeedbackList {...baseProps} />));
    expect(screen.getByTestId("section-tree")).toBeInTheDocument();
    // Run-inclusion checkbox suppressed.
    expect(sectionTreeProps.selectable).toBe(false);
    // Only the active input is passed (the deprecated one is filtered out).
    const inputs = sectionTreeProps.inputs as { id: string }[];
    expect(inputs.map((i) => i.id)).toEqual(["fb-1"]);
    expect(screen.getByText(/Add timestamps to inventory tables/i)).toBeInTheDocument();
    expect(screen.queryByText(/Cross-domain join missing/i)).not.toBeInTheDocument();
  });

  it("offers search/origin/state/priority filters but hides selection", () => {
    render(withQuery(<FeedbackList {...baseProps} />));
    expect(screen.getByLabelText(/Search instructions/i)).toBeInTheDocument();
    // The tab reviews ALL inputs, so origin is a usable facet here.
    expect(screen.getByLabelText(/Filter by origin/i)).toBeInTheDocument();
    expect(screen.getByLabelText(/Filter by state/i)).toBeInTheDocument();
    expect(screen.getByLabelText(/Filter by priority/i)).toBeInTheDocument();
    // No run selection on the Feedback tab — that facet is hidden.
    expect(screen.queryByLabelText(/Filter by selection/i)).not.toBeInTheDocument();
  });

  it("does not offer the Deprecated state, which this active-only list could not show", () => {
    render(withQuery(<FeedbackList {...baseProps} />));
    fireEvent.click(screen.getByLabelText(/Filter by state/i));
    expect(screen.getByRole("option", { name: "Active" })).toBeInTheDocument();
    expect(screen.queryByRole("option", { name: "Deprecated" })).not.toBeInTheDocument();
  });

  it("domain filter narrows the list and offers model-wide", () => {
    feedbackData = FEEDBACK_MULTI_DOMAIN;
    render(withQuery(<FeedbackList {...baseProps} />));
    const idsShown = () => (sectionTreeProps.inputs as { id: string }[]).map((i) => i.id);
    expect(idsShown()).toEqual(["fb-1", "fb-3", "fb-4"]);

    fireEvent.click(screen.getByLabelText(/Filter by domain/i));
    expect(screen.getByRole("option", { name: "inventory" })).toBeInTheDocument();
    fireEvent.click(screen.getByRole("option", { name: "sales" }));
    expect(idsShown()).toEqual(["fb-3"]);

    fireEvent.click(screen.getByLabelText(/Filter by domain/i));
    fireEvent.click(screen.getByRole("option", { name: "Model-wide" }));
    expect(idsShown()).toEqual(["fb-4"]);
  });

  it("wires a delete handler that calls deleteVibeInput with the input id", async () => {
    render(withQuery(<FeedbackList {...baseProps} />));
    const onDelete = sectionTreeProps.onDelete as (i: { id: string }) => void;
    expect(onDelete).toBeTypeOf("function");
    onDelete({ id: "fb-1" });
    expect(vi.mocked(deleteVibeInput)).toHaveBeenCalledWith({
      business_id: "biz-1",
      input_id: "fb-1",
    });
  });
});
