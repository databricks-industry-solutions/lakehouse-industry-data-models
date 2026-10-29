/**
 * `ModelVersionPage` empty + 4xx page-tree test.
 *
 * This is the large route file wiring multiple Suspense queries plus the
 * overview command strip + metrics band, a `<DiagramViewer>` and an
 * `<OntologyGraph>`. A 4xx from `useListVersionsSuspense` (or its peers)
 * should bubble to the ErrorBoundary, not blank the screen with no console
 * signal.
 *
 * Two scenarios:
 *   1. Versions list is empty for the current model — the page must
 *      still render without a "currentVersion is undefined" crash, and
 *      no console.error should fire from the missing version data.
 *   2. A query throws an `ApiError(4xx)` — the surrounding ErrorBoundary
 *      catches it and shows a fallback. Page does not white-screen.
 *
 * Heavy children (DiagramViewer, OntologyGraph, ArtifactsTab, FeedbackList,
 * NextVibesCard) are stubbed so this test stays focused on the shell.
 */
import { afterEach, describe, expect, it, vi } from "vitest";
import { render, screen, waitFor, within } from "@testing-library/react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { Suspense } from "react";
import { ErrorBoundary } from "react-error-boundary";

// All @/lib/api suspense hooks are intercepted here so the page renders
// synchronously with controlled fixtures. The base build's hooks throw
// promises that suspend forever; replacing them with sync stubs lets us
// inspect the page tree directly.
let versionsHook: () => unknown = () => ({ data: [] });
let businessHook: () => unknown = () => ({
  data: { data: { id: "biz-1", name: "Test Biz" } },
});
let modelHook: () => unknown = () => ({
  data: {
    data: {
      name: "Test Model",
      version: 1,
      domain_count: 0,
      product_count: 0,
      attribute_count: 0,
      fk_count: 0,
      confidence_score: null,
      domains: [],
    },
  },
});
let feedbackHook: () => unknown = () => ({ data: [] });

vi.mock("@/lib/api", async () => {
  const actual = await vi.importActual<typeof import("@/lib/api")>("@/lib/api");
  return {
    ...actual,
    useListVersionsSuspense: () => versionsHook(),
    useGetBusinessSuspense: () => businessHook(),
    useGetModelSummarySuspense: () => modelHook(),
    useListVibeInputsSuspense: () => feedbackHook(),
    useListVibeInputs: () => feedbackHook(),
    // The band reads these once they resolve; the fetch stub below answers [] for every URL, so left real they would
    // swap the band's figures after the first paint and the assertions would depend on which paint they land in.
    useGetEvolutionMetrics: () => ({ data: undefined }),
    useGetNextVibeMetrics: () => ({ data: undefined }),
    createRun: vi.fn(),
    deleteVersion: vi.fn(),
    getRun: vi.fn(),
    forceResyncVersion: vi.fn(async () => ({ data: {} })),
  };
});

// TanStack Router hooks need a router context to resolve. We're mounting
// the bare component, not the route, so stub the two hooks the page
// actually uses.
vi.mock("@tanstack/react-router", async () => {
  const actual = await vi.importActual<typeof import("@tanstack/react-router")>(
    "@tanstack/react-router",
  );
  return {
    ...actual,
    useSearch: () => ({ tab: "overview" }),
    useNavigate: () => vi.fn(),
    Link: ({ children, ...props }: any) => <a {...props}>{children}</a>,
  };
});

// Heavy children — stub to identifiable testids so we know the tab
// content slot rendered, without dragging in their internal state.
vi.mock("@/components/diagram/diagram-viewer", () => ({
  DiagramViewer: () => <div data-testid="diagram-viewer-stub" />,
}));
vi.mock("@/components/explorer/relationship-analysis", () => ({
  RelationshipAnalysis: () => <div data-testid="relationship-analysis-stub" />,
}));
vi.mock("@/components/explorer/ontology-graph", () => ({
  OntologyGraph: () => <div data-testid="ontology-graph-stub" />,
}));
vi.mock("@/components/artifacts/artifacts-tab", () => ({
  ArtifactsTab: () => <div data-testid="artifacts-tab-stub" />,
}));
vi.mock("@/components/feedback/feedback-list", () => ({
  FeedbackList: () => <div data-testid="feedback-list-stub" />,
}));
vi.mock("@/components/next-vibes/next-vibes-card", () => ({
  NextVibesCard: () => <div data-testid="next-vibes-card-stub" />,
}));
vi.mock("@/components/runs/launch-run-dialog", () => ({
  LaunchRunDialog: () => <div data-testid="launch-run-dialog-stub" />,
}));

import { ModelVersionPage } from "@/routes/_sidebar/businesses.$businessId.model.$version.$scope.index";
import { useStrictConsole } from "./helpers/strict-console";

afterEach(() => {
  vi.unstubAllGlobals();
  versionsHook = () => ({ data: [] });
  businessHook = () => ({
    data: { data: { id: "biz-1", name: "Test Biz" } },
  });
  modelHook = () => ({
    data: {
      data: {
        name: "Test Model",
        version: 1,
        domain_count: 0,
        product_count: 0,
        attribute_count: 0,
        fk_count: 0,
        confidence_score: null,
        domains: [],
      },
    },
  });
  feedbackHook = () => ({ data: [] });
});

function makeClient() {
  return new QueryClient({
    defaultOptions: {
      queries: { retry: false, staleTime: 30_000 },
      mutations: { retry: false },
    },
  });
}

function renderPage() {
  // Stub the diagram-prefetch fetch + the runs fetch the overview fires on
  // mount (command strip + metrics band). The endpoints must return arrays
  // (the data-shape contract is `RunListOut[]`) so the count derivations
  // don't crash once the queries resolve.
  vi.stubGlobal(
    "fetch",
    vi.fn(async () => ({ ok: true, status: 200, json: async () => [] })),
  );
  return render(
    <QueryClientProvider client={makeClient()}>
      <ErrorBoundary fallbackRender={({ error }) => <div role="alert">Error: {String(error)}</div>}>
        <Suspense fallback={<div data-testid="suspense-fallback" />}>
          <ModelVersionPage businessId="biz-1" version="1" scope="ecm" />
        </Suspense>
      </ErrorBoundary>
    </QueryClientProvider>,
  );
}

describe("ModelVersionPage — empty + 4xx branches", () => {
  const dom = useStrictConsole();

  it("renders without crashing when the versions list is empty", async () => {
    versionsHook = () => ({ data: [] });
    renderPage();
    // The Tabs shell should mount even without a matching version.
    await waitFor(() => {
      expect(screen.getByRole("tab", { name: /Overview/i })).toBeInTheDocument();
    });
    // No DOM-nesting warnings from the Badge-in-div fix sites.
    expect(dom.messages).toEqual([]);
  });

  it("renders without crashing when the model has zero domains", async () => {
    versionsHook = () => ({
      data: [
        {
          id: "v-1",
          version: 1,
          scope: "ecm",
          deployment_status: "draft",
        },
      ],
    });
    renderPage();
    await waitFor(() => {
      expect(screen.getByRole("tab", { name: /Diagram/i })).toBeInTheDocument();
    });
    // The metrics band replaces the old stat-card grid; its Size+effort
    // cell carries the FK figure that used to be a "Foreign Keys" stat card.
    expect(screen.getAllByText(/Domains/i).length).toBeGreaterThan(0);
    expect(screen.getByTestId("metric-size-effort")).toBeInTheDocument();
    expect(within(screen.getByTestId("metric-size-effort")).getByText(/FKs/)).toBeInTheDocument();
    expect(dom.messages).toEqual([]);
  });

  it("surfaces a 4xx via the ErrorBoundary, not a blank screen", async () => {
    versionsHook = () => {
      throw new Error("404 Not Found");
    };
    renderPage();
    // The ErrorBoundary above the page catches the throw; user sees the
    // fallback alert rather than a blank tab area.
    await waitFor(() => {
      expect(screen.getByRole("alert")).toHaveTextContent(/404 Not Found/i);
    });
    expect(dom.messages).toEqual([]);
  });

  it("renders the size+effort domains·subdomains·products trio", async () => {
    versionsHook = () => ({
      data: [
        { id: "v-1", version: 1, scope: "ecm", deployment_status: "draft" },
      ],
    });
    modelHook = () => ({
      data: {
        name: "Test Model",
        version: 1,
        domain_count: 2,
        subdomain_count: 5,
        product_count: 12,
        attribute_count: 40,
        fk_count: 3,
        confidence_score: null,
        domains: [],
      },
    });
    renderPage();
    const cell = await screen.findByTestId("metric-size-effort");
    // The trio is always shown in the band (no per-figure hiding); the
    // subdomain figure "5" + label live inside the Size+effort cell.
    expect(within(cell).getByText("5")).toBeInTheDocument();
    expect(within(cell).getByText(/subdomains/)).toBeInTheDocument();
    expect(within(cell).getByText("12")).toBeInTheDocument();
  });

  it("renders subdomain pills on each domain card when subdomains are present", async () => {
    versionsHook = () => ({
      data: [
        { id: "v-1", version: 1, scope: "ecm", deployment_status: "draft" },
      ],
    });
    modelHook = () => ({
      data: {
        name: "Test Model",
        version: 1,
        domain_count: 1,
        subdomain_count: 2,
        product_count: 4,
        attribute_count: 10,
        fk_count: 0,
        confidence_score: null,
        domains: [
          {
            name: "party",
            division: "Customer",
            description: "Party domain",
            product_count: 4,
            subdomains: [
              { name: "identity", product_count: 2 },
              { name: "engagement", product_count: 2 },
            ],
            change_status: "unchanged",
          },
        ],
      },
    });
    renderPage();
    await waitFor(() => {
      // Subdomain pills are unique to the domain card branch.
      expect(screen.getByText(/identity/i)).toBeInTheDocument();
    });
    expect(screen.getByText(/engagement/i)).toBeInTheDocument();
    // The inline "<N> subdomains" summary on the card sits next to the
    // "Subdomains" stat label on the stats bar — both match the literal
    // text. Assert at least one is present.
    expect(screen.getAllByText(/subdomains/i).length).toBeGreaterThanOrEqual(1);
  });

  it("degrades the Quality confidence to ?? when confidence_score is null", async () => {
    versionsHook = () => ({
      data: [
        {
          id: "v-1",
          version: 1,
          scope: "ecm",
          deployment_status: "draft",
        },
      ],
    });
    modelHook = () => ({
      data: {
        name: "Test Model",
        version: 1,
        domain_count: 0,
        product_count: 0,
        attribute_count: 0,
        fk_count: 0,
        confidence_score: null,
        domains: [],
      },
    });
    renderPage();
    const cell = await screen.findByTestId("metric-quality");
    expect(within(cell).getByText("Confidence not scored")).toBeInTheDocument();
  });

  it("degrades the Quality confidence to ?? when confidence_score is 0 (ECM)", async () => {
    versionsHook = () => ({
      data: [
        {
          id: "v-1",
          version: 1,
          scope: "ecm",
          deployment_status: "draft",
        },
      ],
    });
    modelHook = () => ({
      data: {
        name: "Test Model",
        version: 1,
        domain_count: 0,
        product_count: 0,
        attribute_count: 0,
        fk_count: 0,
        confidence_score: 0,
        domains: [],
      },
    });
    renderPage();
    const cell = await screen.findByTestId("metric-quality");
    expect(within(cell).getByText("Confidence not scored")).toBeInTheDocument();
  });

  it("shows the Quality confidence number when confidence_score > 0 (MVM)", async () => {
    versionsHook = () => ({
      data: [
        {
          id: "v-1",
          version: 1,
          scope: "mvm",
          deployment_status: "draft",
        },
      ],
    });
    // The route consumes `model.confidence_score` directly; the suspense
    // hook's outer `{data}` is destructured into `model`. Fixture must
    // mirror that single-`data` shape to drive the conditional.
    modelHook = () => ({
      data: {
        name: "Test Model",
        version: 1,
        domain_count: 0,
        product_count: 0,
        attribute_count: 0,
        fk_count: 0,
        confidence_score: 0.74,
        domains: [],
      },
    });
    renderPage();
    const cell = await screen.findByTestId("metric-quality");
    // 0.74 → 74 on the 0..100 confidence hero.
    expect(within(cell).getByText("74")).toBeInTheDocument();
    expect(within(cell).getByText(/\/ 100 confidence/)).toBeInTheDocument();
  });

  it("renders the 'Re-sync' action button on the command strip", async () => {
    versionsHook = () => ({
      data: [
        {
          id: "v-1",
          version: 1,
          scope: "ecm",
          deployment_status: "draft",
        },
      ],
    });
    renderPage();
    await waitFor(() => {
      expect(
        screen.getByRole("button", { name: /^Re-sync$/i }),
      ).toBeInTheDocument();
    });
  });
});
