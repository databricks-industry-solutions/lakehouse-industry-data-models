/**
 * `ModelVersionPage` (all-domains route): each tab with a per-domain view
 * carries the domain dropdown inside the tab, below the tab strip.
 *
 * Renders the real `ModelTabsShell` + `ModelView` + `DiagramViewer` +
 * `FeedbackList` (leaf bodies stubbed) and locks, per tab:
 *   - the header (`model-toolbar`: title, search, tab list) holds no domain
 *     control on any tab
 *   - Overview: the dropdown opens the picked domain's page on its Products
 *     tab
 *   - Relationships (model-wide): no domain select
 *   - Diagram: the toolbar dropdown redraws the diagram in place
 *     (`?domain=` on this route, push); "All domains" drops it; the URL's
 *     domain draws that domain's layout (no all-domains request, the warm-up
 *     is that domain only) and survives a tab switch; a name that is not a
 *     domain of the model counts as all domains; with no selection,
 *     Add-feedback captures that domain
 *   - Feedback: exactly one domain control, its filter, which filters in place
 *   - Ontology: shares the Diagram's `?domain=` (host-owned dropdown): a
 *     pick writes it on the Ontology tab, "All domains" removes it, a domain
 *     picked on the Diagram shows on the Ontology
 *   - Artifacts / Review Progress / Relationships: no domain select
 */
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";
import { cleanup, fireEvent, render, screen, waitFor, within } from "@testing-library/react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { Suspense } from "react";

class ResizeObserverStub {
  observe() {}
  unobserve() {}
  disconnect() {}
}
(globalThis as any).ResizeObserver = ResizeObserverStub;
if (!(globalThis as any).DOMMatrixReadOnly) {
  (globalThis as any).DOMMatrixReadOnly = class {
    m22 = 1;
  };
}

const navigateSpy = vi.fn();
const warmSpy = vi.fn((_params: Record<string, unknown>) => Promise.resolve({ data: {} }));
let currentTab = "overview";
let currentDomain: string | undefined;
let ontologyProps: Record<string, unknown> | null = null;
let feedbackProps: { getContext?: () => unknown } | null = null;

const INPUT_BASE = {
  business_id: "biz-1",
  author: "alice",
  origin: "user",
  priority: "medium",
  confidence_score: null,
  consumed: false,
  selected_for_run: false,
  status: "active",
  deprecated_by: null,
  created_at: "2026-04-20T00:00:00Z",
  updated_at: "2026-04-20T00:00:00Z",
};
const INPUTS = [
  { ...INPUT_BASE, id: "fb-1", text: "Sales orders need currency", anchor: { level: "element", domain_name: "Sales", path: ["Domain: Sales"] } },
  { ...INPUT_BASE, id: "fb-2", text: "Stock levels need a date", anchor: { level: "element", domain_name: "Inventory", path: ["Domain: Inventory"] } },
];

vi.mock("@/lib/api", async () => {
  const actual = await vi.importActual<typeof import("@/lib/api")>("@/lib/api");
  return {
    ...actual,
    useListVersionsSuspense: () => ({
      data: [{ id: "v-1", version: 1, scope: "ecm", deployment_status: "draft" }],
    }),
    useGetBusinessSuspense: () => ({ data: { id: "biz-1", name: "Test Biz", source_repo_path: "" } }),
    useGetModelSummarySuspense: () => ({
      data: {
        name: "Test Model",
        version: 1,
        domains: [
          { name: "Sales", division: "Commercial", change_status: "unchanged" },
          { name: "Inventory", division: "Ops", change_status: "unchanged" },
        ],
      },
    }),
    useListVibeInputsSuspense: () => ({ data: INPUTS }),
    useGetUserPreferences: () => ({ data: { data: [] }, isLoading: false }),
    getDiagramLayout: (params: Record<string, unknown>) => warmSpy(params),
  };
});

vi.mock("@tanstack/react-router", async () => {
  const actual = await vi.importActual<typeof import("@tanstack/react-router")>(
    "@tanstack/react-router",
  );
  return {
    ...actual,
    useSearch: () => ({ tab: currentTab, ...(currentDomain ? { domain: currentDomain } : {}) }),
    useNavigate: () => navigateSpy,
    Link: ({ children, ...props }: any) => <a {...props}>{children}</a>,
  };
});

vi.mock("@/components/explorer/breadcrumb-context", () => ({ useBreadcrumbs: () => {} }));
vi.mock("@/components/model/model-search", () => ({
  ModelSearch: () => <button type="button">Search model</button>,
}));
vi.mock("@/components/model/model-overview", () => ({
  ModelOverview: () => <div data-testid="overview-stub" />,
}));
vi.mock("@/components/statistics/statistics-tab", () => ({
  StatisticsTab: () => <div data-testid="statistics-tab-stub" />,
}));
vi.mock("@/components/versions/version-sync-state-banner", () => ({
  VersionSyncStateBanner: () => null,
}));
vi.mock("@/components/versions/version-lifecycle-badges", () => ({
  VersionLifecycleBadges: () => null,
}));
vi.mock("@/components/explorer/relationship-analysis", () => ({
  RelationshipAnalysis: () => <div data-testid="relationship-analysis-stub" />,
}));
vi.mock("@/components/explorer/ontology-graph", () => ({
  OntologyGraph: (props: Record<string, unknown>) => {
    ontologyProps = props;
    return <div data-testid="ontology-graph-stub" />;
  },
}));
vi.mock("@/components/artifacts/artifacts-tab", () => ({
  ArtifactsTab: () => <div data-testid="artifacts-tab-stub" />,
}));
vi.mock("@/components/feedback/add-feedback-button", () => ({
  AddFeedbackButton: (props: { getContext?: () => unknown }) => {
    feedbackProps = props;
    return <div data-testid="add-feedback-stub" />;
  },
}));
vi.mock("@/components/runs/link-run-dialog", () => ({ LinkRunAction: () => null }));
vi.mock("@/components/assessment/assess-button", () => ({ AssessButton: () => null }));
vi.mock("@/components/vibe-inputs/section-tree", () => ({
  SectionTree: ({ inputs }: { inputs: { id: string; text: string }[] }) => (
    <div data-testid="section-tree">
      {inputs.map((i) => (
        <div key={i.id}>{i.text}</div>
      ))}
    </div>
  ),
}));
vi.mock("@/components/vibe-inputs/input-markdown-editor-dialog", () => ({
  InputMarkdownEditorDialog: () => null,
}));

import { ModelVersionPage } from "@/routes/_sidebar/businesses.$businessId.model.$version.$scope.index";

const TABS = ["overview", "diagram", "relationships", "ontology", "artifacts", "feedback", "statistics"];
const DOMAIN_ROUTE = "/businesses/$businessId/model/$version/$scope/$domainName";

function renderPage(tab: string, domain?: string) {
  currentTab = tab;
  currentDomain = domain;
  const client = new QueryClient({
    defaultOptions: { queries: { retry: false }, mutations: { retry: false } },
  });
  return render(
    <QueryClientProvider client={client}>
      <Suspense fallback={<div data-testid="suspense-fallback" />}>
        <ModelVersionPage businessId="biz-1" version="1" scope="ecm" />
      </Suspense>
    </QueryClientProvider>,
  );
}

/** Every domain control on the page: the shared dropdown (aria-label
 *  "Domain") and the Feedback filter. */
function domainControls() {
  return screen
    .queryAllByRole("combobox")
    .filter((c) => /^(Domain|Filter by domain)$/.test(c.getAttribute("aria-label") ?? ""));
}

async function pick(box: HTMLElement, option: string | RegExp) {
  fireEvent.click(box);
  fireEvent.click(await screen.findByRole("option", { name: option }));
}

let fetchMock: ReturnType<typeof vi.fn>;

/** The diagram layout requests the page made. */
function layoutUrls(): string[] {
  return fetchMock.mock.calls.map((c) => String(c[0])).filter((u) => u.includes("/diagram?"));
}

beforeEach(() => {
  navigateSpy.mockClear();
  warmSpy.mockClear();
  ontologyProps = null;
  feedbackProps = null;
  fetchMock = vi.fn((_url: string) =>
    Promise.resolve({
      status: 200,
      ok: true,
      json: () =>
        Promise.resolve({
          nodes: [],
          edges: [],
          groups: [],
          domain_filter: null,
          show_columns: false,
          total_products: 0,
          total_edges: 0,
        }),
    } as unknown as Response),
  );
  (globalThis as any).fetch = fetchMock;
});

afterEach(() => {
  cleanup();
});

describe("ModelVersionPage - no domain control above the tabs", () => {
  it.each(TABS)("the header holds no domain select on the %s tab", async (tab) => {
    renderPage(tab);
    const toolbar = await screen.findByTestId("model-toolbar");
    expect(within(toolbar).getByRole("button", { name: "Search model" })).toBeInTheDocument();
    expect(within(toolbar).queryAllByRole("combobox")).toHaveLength(0);
  });

  it.each(["artifacts", "statistics", "relationships"])("renders no domain select on the %s tab", async (tab) => {
    renderPage(tab);
    await screen.findByTestId("model-toolbar");
    expect(domainControls()).toHaveLength(0);
  });
});

describe("ModelVersionPage - Overview tab domain dropdown", () => {
  it("sits inside the tab, offers domains only, and opens the domain's page on its Products tab", async () => {
    renderPage("overview");
    const panel = await screen.findByRole("tabpanel");
    const [box] = domainControls();
    expect(domainControls()).toHaveLength(1);
    expect(panel.contains(box)).toBe(true);
    expect(box).toHaveTextContent("Go to domain");
    fireEvent.click(box);
    expect(screen.queryByRole("option", { name: "All domains" })).not.toBeInTheDocument();
    fireEvent.click(await screen.findByRole("option", { name: /Inventory/ }));
    expect(navigateSpy).toHaveBeenCalledWith(
      expect.objectContaining({
        to: DOMAIN_ROUTE,
        params: { businessId: "biz-1", version: "1", scope: "ecm", domainName: "Inventory" },
        search: { tab: "products" },
      }),
    );
  });
});

describe("ModelVersionPage - Diagram tab draws a picked domain in place", () => {
  it("shows the toolbar dropdown inside the tab; a pick stays on this route and tab (push)", async () => {
    renderPage("diagram");
    const panel = await screen.findByRole("tabpanel");
    await waitFor(() => expect(domainControls()).toHaveLength(1));
    expect(panel.contains(domainControls()[0])).toBe(true);
    await pick(domainControls()[0], /Sales/);
    expect(navigateSpy).toHaveBeenCalledWith({ to: ".", search: { tab: "diagram", domain: "Sales" } });
  });

  it("draws the URL's domain: the dropdown shows it and the layout request names it", async () => {
    renderPage("diagram", "Sales");
    await waitFor(() => expect(domainControls()[0]).toHaveTextContent("Sales"));
    await waitFor(() =>
      expect(fetchMock.mock.calls.some((c) => String(c[0]).includes("domain=Sales"))).toBe(true),
    );
  });

  it("with ?domain= set, requests no all-domains layout and warms only that domain", async () => {
    renderPage("diagram", "Sales");
    await waitFor(() => expect(layoutUrls().length).toBeGreaterThan(0));
    expect(layoutUrls().every((u) => u.includes("domain=Sales"))).toBe(true);
    expect(warmSpy).toHaveBeenCalled();
    expect(warmSpy.mock.calls.every((c) => c[0].domain === "Sales")).toBe(true);
  });

  it("treats a ?domain= that names no domain of the model as All domains", async () => {
    renderPage("diagram", "Bogus");
    await waitFor(() => expect(layoutUrls().length).toBeGreaterThan(0));
    expect(layoutUrls().some((u) => u.includes("Bogus"))).toBe(false);
    expect(warmSpy.mock.calls.some((c) => c[0].domain !== undefined)).toBe(false);
    await waitFor(() => expect(domainControls()[0]).toHaveTextContent("All domains"));
    await waitFor(() => expect(feedbackProps?.getContext).toBeTypeOf("function"));
    expect(feedbackProps!.getContext!()).toEqual({});
  });

  it("'All domains' redraws the full diagram (drops ?domain=)", async () => {
    renderPage("diagram", "Sales");
    await waitFor(() => expect(domainControls()).toHaveLength(1));
    await pick(domainControls()[0], "All domains");
    expect(navigateSpy).toHaveBeenCalledWith({ to: ".", search: { tab: "diagram" } });
  });

  it("'All domains' on the all-domains diagram does nothing", async () => {
    renderPage("diagram");
    await waitFor(() => expect(domainControls()).toHaveLength(1));
    await pick(domainControls()[0], "All domains");
    expect(navigateSpy).not.toHaveBeenCalled();
  });

  it("keeps the picked domain in the URL when switching to the Ontology", async () => {
    renderPage("diagram", "Sales");
    const ontology = await screen.findByRole("tab", { name: /Ontology/ });
    fireEvent.mouseDown(ontology, { button: 0, ctrlKey: false });
    expect(navigateSpy).toHaveBeenCalledWith({
      to: ".",
      search: { tab: "ontology", domain: "Sales" },
      replace: true,
    });
  });

  it("Add-feedback with nothing selected captures the picked domain", async () => {
    renderPage("diagram", "Sales");
    await waitFor(() => expect(feedbackProps?.getContext).toBeTypeOf("function"));
    expect(feedbackProps!.getContext!()).toEqual({ domain_filter: "Sales" });
  });

  it("Add-feedback on the all-domains diagram captures the whole model", async () => {
    renderPage("diagram");
    await waitFor(() => expect(feedbackProps?.getContext).toBeTypeOf("function"));
    expect(feedbackProps!.getContext!()).toEqual({});
  });
});

describe("ModelVersionPage - Feedback tab domain filter", () => {
  it("shows exactly one domain control: the feedback filter", async () => {
    renderPage("feedback");
    const filter = await screen.findByRole("combobox", { name: /Filter by domain/i });
    expect(domainControls()).toEqual([filter]);
    expect(screen.getByRole("tabpanel").contains(filter)).toBe(true);
  });

  it("filters the list in place and never navigates", async () => {
    renderPage("feedback");
    await pick(await screen.findByRole("combobox", { name: /Filter by domain/i }), "Sales");
    expect(screen.getByText("Sales orders need currency")).toBeInTheDocument();
    expect(screen.queryByText("Stock levels need a date")).not.toBeInTheDocument();
    expect(navigateSpy).not.toHaveBeenCalled();
  });
});

describe("ModelVersionPage - Ontology tab shares the Diagram's ?domain=", () => {
  const pickOnOntology = (d: string | null) => (ontologyProps!.onDomainPick as (d: string | null) => void)(d);

  it("a pick writes ?domain= on the Ontology tab (push)", async () => {
    renderPage("ontology");
    await screen.findByTestId("ontology-graph-stub");
    expect(ontologyProps?.domainFilter).toBeUndefined();
    pickOnOntology("Sales");
    expect(navigateSpy).toHaveBeenCalledWith({ to: ".", search: { tab: "ontology", domain: "Sales" } });
  });

  it("shows the domain picked on the Diagram, and 'All domains' removes it", async () => {
    renderPage("ontology", "Sales");
    await screen.findByTestId("ontology-graph-stub");
    expect(ontologyProps?.domainFilter).toBe("Sales");
    pickOnOntology(null);
    expect(navigateSpy).toHaveBeenCalledWith({ to: ".", search: { tab: "ontology" } });
  });

  it("treats an unknown ?domain= as All domains", async () => {
    renderPage("ontology", "Bogus");
    await screen.findByTestId("ontology-graph-stub");
    expect(ontologyProps?.domainFilter).toBeUndefined();
  });
});
