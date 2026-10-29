/**
 * `<ModelView/>` — the reusable model-visualization tab host extracted from
 * the model-version route (commit a). Covers:
 *  - renders the full tab set for the model-route config;
 *  - `diagramDomain` pre-focuses the diagram via `initialDomain`;
 *  - a reduced `tabs` set (card-details config) hides the omitted tabs;
 *  - the overview / between / trailing slots render.
 *
 * The model-route REGRESSION (existing route still renders post-extraction)
 * is covered by `model-version-page.test.tsx`, which mounts the route shell.
 */
import { describe, expect, it, vi } from "vitest";
import { render, screen } from "@testing-library/react";

let lastDiagramProps: Record<string, unknown> = {};
vi.mock("@/components/diagram/diagram-viewer", () => ({
  DiagramViewer: (props: Record<string, unknown>) => {
    lastDiagramProps = props;
    return <div data-testid="diagram-viewer-stub" />;
  },
}));
vi.mock("@/components/explorer/relationship-analysis", () => ({
  RelationshipAnalysis: () => <div data-testid="relationship-analysis-stub" />,
}));
vi.mock("@/components/explorer/ontology-graph", () => ({
  OntologyGraph: () => <div data-testid="ontology-graph-stub" />,
}));
vi.mock("@/components/feedback/feedback-list", () => ({
  FeedbackList: () => <div data-testid="feedback-list-stub" />,
}));
vi.mock("@/components/artifacts/artifacts-tab", () => ({
  ArtifactsTab: () => <div data-testid="artifacts-tab-stub" />,
}));
vi.mock("@/lib/api", () => ({
  useListVibeInputsSuspense: () => ({ data: [] }),
  VibeInputOrigin: { user: "user", agent_next_vibe: "agent_next_vibe" },
}));

import { ModelView, MODEL_VIEW_TABS } from "@/components/vibe-inputs/model-view";

const baseProps = {
  businessId: "biz-1",
  version: "3",
  scope: "ecm",
  domains: [{ name: "Sales", division: "GTM" }],
  modelVersionId: "ver-1",
};

describe("ModelView", () => {
  it("renders all model-view tabs for the model-route config", () => {
    render(<ModelView {...baseProps} />);
    // Tab label overrides: keys whose display name doesn't follow the simple
    // capitalize-first-letter rule.
    const labelOverrides: Partial<Record<(typeof MODEL_VIEW_TABS)[number], string>> = {
      statistics: "Review Progress",
    };
    for (const t of MODEL_VIEW_TABS) {
      const label = labelOverrides[t] ?? (t.charAt(0).toUpperCase() + t.slice(1));
      expect(screen.getByRole("tab", { name: new RegExp(label) })).toBeInTheDocument();
    }
  });

  it("pre-focuses the diagram on diagramDomain via initialDomain", () => {
    lastDiagramProps = {};
    render(
      <ModelView
        {...baseProps}
        defaultTab="diagram"
        diagramDomain="Sales"
      />,
    );
    expect(screen.getByTestId("diagram-viewer-stub")).toBeInTheDocument();
    expect(lastDiagramProps.initialDomain).toBe("Sales");
  });

  it("hides omitted tabs for the card-details config", () => {
    render(
      <ModelView
        {...baseProps}
        tabs={["diagram", "relationships", "ontology"]}
        defaultTab="diagram"
      />,
    );
    expect(screen.getByRole("tab", { name: /Diagram/ })).toBeInTheDocument();
    expect(screen.queryByRole("tab", { name: /Overview/ })).not.toBeInTheDocument();
    expect(screen.queryByRole("tab", { name: /Feedback/ })).not.toBeInTheDocument();
    expect(screen.queryByRole("tab", { name: /Artifacts/ })).not.toBeInTheDocument();
  });

  it("renders the header, between, trailing and overview slots", () => {
    render(
      <ModelView
        {...baseProps}
        value="overview"
        headerSlot={<h1>My Model v3</h1>}
        betweenSlot={<div>sync-banner</div>}
        tabBarTrailing={<button>Delete</button>}
        overviewSlot={<div>overview-body</div>}
      />,
    );
    expect(screen.getByText("My Model v3")).toBeInTheDocument();
    expect(screen.getByText("sync-banner")).toBeInTheDocument();
    expect(screen.getByRole("button", { name: "Delete" })).toBeInTheDocument();
    expect(screen.getByText("overview-body")).toBeInTheDocument();
  });
});

describe("ModelView - diagram feedback single-home seam (item 5B, 0.6.6)", () => {
  it("omits tabBarTrailing when the diagram tab is active", () => {
    render(
      <ModelView
        {...baseProps}
        value="diagram"
        tabBarTrailing={<button>Delete</button>}
      />,
    );
    expect(screen.queryByRole("button", { name: "Delete" })).not.toBeInTheDocument();
  });

  it("renders tabBarTrailing on every other tab", () => {
    render(
      <ModelView
        {...baseProps}
        value="overview"
        tabBarTrailing={<button>Delete</button>}
      />,
    );
    expect(screen.getByRole("button", { name: "Delete" })).toBeInTheDocument();
  });

  it("passes feedbackSlot through to DiagramViewer", () => {
    render(
      <ModelView
        {...baseProps}
        value="diagram"
        feedbackSlot={<button>Add feedback</button>}
      />,
    );
    expect(lastDiagramProps.feedbackSlot).toBeTruthy();
  });
});

describe("ModelView - columnModePending gate (item 4C regression, 0.6.6 bug bash)", () => {
  // DiagramViewer seeds columnMode via a useState initializer read ONCE at
  // mount. Item 4C's first cut mounted DiagramViewer unconditionally while
  // the caller's preference query (non-suspense) was still in flight, so
  // the diagram's first getDiagramLayout request carried the hardcoded
  // fallback forever - a later-resolving initialColumnMode never reached
  // an already-mounted DiagramViewer. columnModePending defers the mount
  // until the caller says the preference lookup has settled.
  it("does not mount DiagramViewer while columnModePending is true", () => {
    lastDiagramProps = {};
    render(
      <ModelView
        {...baseProps}
        value="diagram"
        columnModePending={true}
        initialColumnMode="all"
      />,
    );
    expect(screen.queryByTestId("diagram-viewer-stub")).not.toBeInTheDocument();
  });

  it("mounts DiagramViewer immediately when columnModePending is omitted (default false)", () => {
    lastDiagramProps = {};
    render(
      <ModelView {...baseProps} value="diagram" initialColumnMode="all" />,
    );
    expect(screen.getByTestId("diagram-viewer-stub")).toBeInTheDocument();
    expect(lastDiagramProps.initialColumnMode).toBe("all");
  });

  it("mounts DiagramViewer with the resolved preference once pending flips to false (the race the bug hinged on)", () => {
    lastDiagramProps = {};
    const { rerender } = render(
      <ModelView
        {...baseProps}
        value="diagram"
        columnModePending={true}
        initialColumnMode={undefined}
      />,
    );
    expect(screen.queryByTestId("diagram-viewer-stub")).not.toBeInTheDocument();

    // Preference query resolves: pending flips false, the value arrives in
    // the SAME render. DiagramViewer must mount fresh with that value, not
    // with the hardcoded fallback it would have locked onto had it mounted
    // during the pending window.
    rerender(
      <ModelView
        {...baseProps}
        value="diagram"
        columnModePending={false}
        initialColumnMode="all"
      />,
    );
    expect(screen.getByTestId("diagram-viewer-stub")).toBeInTheDocument();
    expect(lastDiagramProps.initialColumnMode).toBe("all");
  });
});
