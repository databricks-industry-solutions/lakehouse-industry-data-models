/**
 * ModelTabsShell (Track 6 item 1) contract tests.
 *
 * The shell is the shared model-page orchestration both the model-version
 * route and the input-review route render. These tests lock the behaviors the
 * extraction must preserve/introduce:
 *   - full tab set renders; focusAnchor seeds the diagram to that domain
 *   - showLifecycleActions gates the run/install CommandStrip
 *   - the single-home Add-feedback affordance placement (tab bar vs diagram)
 *   - the ELK warm is domain-scoped when focusAnchor is present (never
 *     all-domains) and all-domains only when it is absent
 *   - the input route's ?tab= change MERGES search (preserves `from`)
 */
import { afterEach, describe, expect, it, vi } from "vitest";
import { fireEvent, render, screen, within } from "@testing-library/react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";

let versionsHook: () => unknown = () => ({
  data: [{ id: "v-1", version: 1, scope: "ecm", deployment_status: "draft", uc_catalog: "cat" }],
});
let businessHook: () => unknown = () => ({
  data: { data: { id: "biz-1", name: "Test Biz", source_repo_path: "" } },
});
let modelHook: () => unknown = () => ({
  data: {
    data: {
      name: "Test Model",
      version: 1,
      domain_count: 1,
      product_count: 1,
      attribute_count: 1,
      fk_count: 0,
      confidence_score: null,
      domains: [{ name: "sales", division: "Commercial", change_status: "unchanged", product_count: 1, subdomains: [] }],
    },
  },
});
const getDiagramLayoutMock = vi.fn(async (_params: any) => ({ data: {} }));
// The latest props the Add-feedback stub rendered with (context + disabled state).
let feedbackProps: any = null;

vi.mock("@/lib/api", async () => {
  const actual = await vi.importActual<typeof import("@/lib/api")>("@/lib/api");
  return {
    ...actual,
    useListVersionsSuspense: () => versionsHook(),
    useGetBusinessSuspense: () => businessHook(),
    useGetModelSummarySuspense: () => modelHook(),
    useListVibeInputsSuspense: () => ({ data: [] }),
    useListVibeInputs: () => ({ data: [] }),
    useListRunsForVersion: () => ({ data: [] }),
    useGetEvolutionMetrics: () => ({ data: null }),
    useGetNextVibeMetrics: () => ({ data: null }),
    useGetUserPreferences: () => ({ data: { data: [] }, isLoading: false }),
    getDiagramLayout: (params: any) => getDiagramLayoutMock(params),
  };
});

// DiagramViewer exposes the props under test (initialDomain + feedbackSlot).
vi.mock("@/components/diagram/diagram-viewer", () => ({
  DiagramViewer: ({ initialDomain, feedbackSlot, onSelectionChange }: any) => (
    <div data-testid="diagram-viewer-stub" data-initial-domain={initialDomain ?? ""}>
      <button onClick={() => onSelectionChange?.({ nodeId: "sales.orders", edgeId: null })}>
        select-node
      </button>
      <button
        onClick={() =>
          onSelectionChange?.({ nodeId: null, edgeId: "fk:sales.orders.cust_id>sales.customers.id" })
        }
      >
        select-edge
      </button>
      {feedbackSlot}
    </div>
  ),
}));
vi.mock("@/components/feedback/add-feedback-button", () => ({
  AddFeedbackButton: (props: any) => {
    feedbackProps = props;
    return <div data-testid="add-feedback-stub" />;
  },
}));
vi.mock("@/components/overview/command-strip", () => ({
  CommandStrip: () => <div data-testid="command-strip-stub" />,
}));
vi.mock("@/components/overview/metrics-band", () => ({
  MetricsBand: () => <div data-testid="metrics-band-stub" />,
}));
vi.mock("@/components/next-vibes/next-vibes-card", () => ({
  NextVibesCard: () => <div data-testid="next-vibes-card-stub" />,
}));
vi.mock("@/components/explorer/installation-drift-dialog", () => ({
  InstallationDriftDialog: () => <div data-testid="drift-dialog-stub" />,
}));
vi.mock("@/components/statistics/statistics-tab", () => ({
  StatisticsTab: ({ onDomainChange }: any) => (
    <div data-testid="statistics-tab-stub">
      <button onClick={() => onDomainChange?.("sales")}>scope-sales</button>
    </div>
  ),
}));
vi.mock("@/components/versions/version-sync-state-banner", () => ({
  VersionSyncStateBanner: () => <div data-testid="sync-banner-stub" />,
}));
vi.mock("@/components/explorer/relationship-analysis", () => ({
  RelationshipAnalysis: () => <div data-testid="relationship-analysis-stub" />,
}));
vi.mock("@/components/explorer/ontology-graph", () => ({
  OntologyGraph: ({ onDomainChange }: any) => (
    <div data-testid="ontology-graph-stub">
      <button onClick={() => onDomainChange?.("sales")}>ontology-sales</button>
    </div>
  ),
}));
vi.mock("@/components/artifacts/artifacts-tab", () => ({
  ArtifactsTab: () => <div data-testid="artifacts-tab-stub" />,
}));

import { ModelTabsShell } from "@/components/model/model-tabs-shell";

function makeClient() {
  return new QueryClient({
    defaultOptions: {
      queries: { retry: false, staleTime: 30_000 },
      mutations: { retry: false },
    },
  });
}

function renderShell(props: Partial<React.ComponentProps<typeof ModelTabsShell>> = {}) {
  return render(
    <QueryClientProvider client={makeClient()}>
      <ModelTabsShell
        businessId="biz-1"
        version="1"
        scope="ecm"
        tab="overview"
        onTabChange={() => {}}
        {...props}
      />
    </QueryClientProvider>,
  );
}

afterEach(() => {
  vi.clearAllMocks();
  feedbackProps = null;
  versionsHook = () => ({
    data: [{ id: "v-1", version: 1, scope: "ecm", deployment_status: "draft", uc_catalog: "cat" }],
  });
});

describe("ModelTabsShell", () => {
  it("renders the full model tab set", () => {
    renderShell();
    for (const name of [/Overview/i, /Diagram/i, /Relationships/i, /Ontology/i, /Artifacts/i, /Feedback/i, /Review Progress/i]) {
      expect(screen.getByRole("tab", { name })).toBeInTheDocument();
    }
  });

  it("seeds the diagram to the focusAnchor domain", () => {
    renderShell({ tab: "diagram", focusAnchor: { domain: "sales" } });
    const stub = screen.getByTestId("diagram-viewer-stub");
    expect(stub.getAttribute("data-initial-domain")).toBe("sales");
  });

  it("shows the run/install CommandStrip on Overview by default", () => {
    renderShell({ tab: "overview" });
    expect(screen.getByTestId("command-strip-stub")).toBeInTheDocument();
  });

  it("suppresses the CommandStrip when showLifecycleActions is false", () => {
    renderShell({ tab: "overview", showLifecycleActions: false });
    expect(screen.queryByTestId("command-strip-stub")).not.toBeInTheDocument();
    // The metrics band + next-vibes stay.
    expect(screen.getByTestId("metrics-band-stub")).toBeInTheDocument();
  });

  it("places Add-feedback in the tab bar on non-diagram tabs", () => {
    renderShell({ tab: "overview" });
    // The diagram is not mounted on the overview tab, so the ONLY Add-feedback
    // instance is the tab-bar one (single-home rule).
    expect(screen.getAllByTestId("add-feedback-stub")).toHaveLength(1);
    expect(screen.queryByTestId("diagram-viewer-stub")).not.toBeInTheDocument();
  });

  it("moves Add-feedback into the diagram toolbar on the diagram tab", () => {
    renderShell({ tab: "diagram" });
    // On the diagram tab the tab-bar trailing is suppressed and the single
    // Add-feedback lives inside the diagram (via feedbackSlot).
    const diagram = screen.getByTestId("diagram-viewer-stub");
    expect(within(diagram).getByTestId("add-feedback-stub")).toBeInTheDocument();
    expect(screen.getAllByTestId("add-feedback-stub")).toHaveLength(1);
  });

  it("renders the versionActions slot (e.g. delete button) in the tab bar", () => {
    renderShell({ tab: "overview", versionActions: <button>Delete this version</button> });
    expect(screen.getByRole("button", { name: /Delete this version/i })).toBeInTheDocument();
  });

  it("omits versionActions when not provided (input surface has no delete)", () => {
    renderShell({ tab: "overview" });
    expect(screen.queryByRole("button", { name: /Delete this version/i })).not.toBeInTheDocument();
  });

  it("warms the all-domains layout when no focusAnchor is set", () => {
    renderShell({ tab: "overview" });
    expect(getDiagramLayoutMock).toHaveBeenCalledTimes(1);
    const arg = getDiagramLayoutMock.mock.calls[0][0] as any;
    expect(arg.domain).toBeUndefined();
    expect(arg.column_mode).toBe("hide");
    expect(arg.prefetch).toBe(true);
  });

  it("warms ONLY the focus domain (never all-domains) when focusAnchor is set", () => {
    renderShell({ tab: "diagram", focusAnchor: { domain: "sales" } });
    expect(getDiagramLayoutMock).toHaveBeenCalledTimes(1);
    const arg = getDiagramLayoutMock.mock.calls[0][0] as any;
    expect(arg.domain).toBe("sales");
    // No all-domains (domain-less) prefetch ever fires for a focused review.
    for (const call of getDiagramLayoutMock.mock.calls) {
      expect((call[0] as any).domain).toBe("sales");
    }
  });

  it("mounts the search trigger in the header", () => {
    renderShell({ tab: "overview", searchTrigger: <div data-testid="search-trigger-stub" /> });
    expect(screen.getByTestId("search-trigger-stub")).toBeInTheDocument();
  });

  it("wraps the toolbar: identity row, tabs row and actions can each break onto a new line", () => {
    renderShell({
      tab: "overview",
      searchTrigger: <button>Search model</button>,
      versionActions: <button>Delete this version</button>,
    });
    const toolbar = screen.getByTestId("model-toolbar");
    const filters = screen.getByTestId("model-toolbar-filters");
    const actions = screen.getByTestId("model-toolbar-actions");
    expect(filters.className).toContain("flex-wrap");
    expect(filters.parentElement?.className).toContain("flex-wrap");
    expect(screen.getByRole("tablist").className).toContain("flex-wrap");
    expect(actions.parentElement?.className).toContain("flex-wrap");
    expect(actions.className).toContain("flex-wrap");
    expect(toolbar.contains(filters) && toolbar.contains(actions)).toBe(true);
  });

  it("keeps the keyboard order: title, search, tabs, Add-feedback, version actions", () => {
    renderShell({
      tab: "overview",
      searchTrigger: <button>Search model</button>,
      versionActions: <button>Delete this version</button>,
    });
    const order = [
      screen.getByRole("heading", { level: 1 }),
      screen.getByRole("button", { name: "Search model" }),
      screen.getByRole("tab", { name: /Overview/ }),
      screen.getByRole("tab", { name: /Review Progress/ }),
      screen.getByTestId("add-feedback-stub"),
      screen.getByRole("button", { name: "Delete this version" }),
    ];
    for (let i = 1; i < order.length; i++) {
      expect(order[i - 1].compareDocumentPosition(order[i]) & Node.DOCUMENT_POSITION_FOLLOWING).toBeTruthy();
    }
  });

  it("renders no filters or actions wrapper when the route supplies none (input surface)", () => {
    renderShell({ tab: "overview" });
    expect(screen.queryByTestId("model-toolbar-filters")).not.toBeInTheDocument();
  });

  it("keeps the Delete reason on its own full-width line under the toolbar", () => {
    renderShell({ tab: "overview", versionActions: <button>Delete this version</button> });
    const toolbar = screen.getByTestId("model-toolbar");
    const note = screen.getByTestId("toolbar-note-slot");
    expect(toolbar.contains(note)).toBe(false);
    expect(toolbar.compareDocumentPosition(note) & Node.DOCUMENT_POSITION_FOLLOWING).toBeTruthy();
  });
});

describe("ModelTabsShell Add-feedback context (model elements only)", () => {
  const capture = () => feedbackProps.getContext();

  it.each(["overview", "relationships", "ontology", "feedback", "statistics"] as const)(
    "captures the whole model on the %s tab, with no tab name",
    (tab) => {
      renderShell({ tab });
      expect(capture()).toEqual({});
      expect(feedbackProps.disabledReason).toBeUndefined();
    },
  );

  it("captures the selected table or relationship on the diagram tab", () => {
    renderShell({ tab: "diagram" });
    expect(capture()).toEqual({});
    fireEvent.click(screen.getByText("select-node"));
    expect(capture()).toEqual({ selected_node_id: "sales.orders" });
    fireEvent.click(screen.getByText("select-edge"));
    expect(capture()).toEqual({ selected_edge_id: "fk:sales.orders.cust_id>sales.customers.id" });
  });

  it("captures the domain the Review Progress report is bound to", () => {
    renderShell({ tab: "statistics" });
    fireEvent.click(screen.getByText("scope-sales"));
    expect(capture()).toEqual({ domain_filter: "sales" });
  });

  it("captures the domain the Ontology filter shows", () => {
    renderShell({ tab: "ontology" });
    expect(capture()).toEqual({});
    fireEvent.click(screen.getByText("ontology-sales"));
    expect(capture()).toEqual({ domain_filter: "sales" });
  });

  it("captures the reviewed input's element on the input-review route", () => {
    renderShell({
      tab: "relationships",
      feedbackSubject: { domain: "sales", product: "orders", attribute: "amount" },
    });
    expect(capture()).toEqual({ selected_node_id: "sales.orders", selected_attribute: "amount" });
  });

  it("captures a reviewed relationship input's relationship", () => {
    const edge = "fk:sales.orders.cust_id>party.customers.id";
    renderShell({ tab: "overview", feedbackSubject: { relationship: edge } });
    expect(capture()).toEqual({ selected_edge_id: edge });
  });

  it("follows Review Progress, not the input, on the input-review route", () => {
    renderShell({ tab: "statistics", feedbackSubject: { domain: "sales", product: "orders" } });
    expect(capture()).toEqual({});
    fireEvent.click(screen.getByText("scope-sales"));
    expect(capture()).toEqual({ domain_filter: "sales" });
  });

  it("disables Add-feedback on the Artifacts tab and says where to give it", () => {
    renderShell({ tab: "artifacts" });
    expect(feedbackProps.disabledReason).toMatch(/about the model/i);
    expect(feedbackProps.disabledReason).toMatch(/Add feedback from any other tab\./);
  });
});
