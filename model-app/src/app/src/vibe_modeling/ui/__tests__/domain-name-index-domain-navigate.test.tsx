/**
 * Domain page (`$domainName.index.tsx`): every tab carries the domain
 * dropdown inside the tab, below the tab strip.
 *
 * Uses the REAL `DiagramViewer` (mocked `fetch`) for the Diagram tab:
 *   - Products: the dropdown shows this domain, offers domains only, and
 *     opens the picked domain's page on the same tab
 *   - Relationships (model-wide): no domain select
 *   - Ontology: mounted with `domainFilter` and a host `onDomainPick`; a
 *     pick opens that domain's Ontology tab, "All domains" the version
 *     page's Ontology tab
 *   - Diagram: another domain opens its diagram (push, same route); "All
 *     domains" the version page's Diagram tab; a re-pick is a no-op
 */
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";
import { cleanup, fireEvent, render, screen, waitFor, within } from "@testing-library/react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { Suspense } from "react";
import { ErrorBoundary } from "react-error-boundary";

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
let currentTab = "diagram";
let ontologyProps: Record<string, unknown> | null = null;

vi.mock("@/components/explorer/relationship-analysis", () => ({
  RelationshipAnalysis: () => <div data-testid="relationship-analysis-stub" />,
}));
vi.mock("@/components/explorer/ontology-graph", () => ({
  OntologyGraph: (props: Record<string, unknown>) => {
    ontologyProps = props;
    return <div data-testid="ontology-graph-stub" />;
  },
}));
vi.mock("@/components/feedback/add-feedback-button", () => ({
  AddFeedbackButton: () => <div data-testid="add-feedback-stub" />,
}));
vi.mock("@/components/explorer/breadcrumb-context", () => ({ useBreadcrumbs: () => {} }));

vi.mock("@/lib/api", async () => {
  const actual = await vi.importActual<typeof import("@/lib/api")>("@/lib/api");
  return {
    ...actual,
    useGetBusinessSuspense: () => ({ data: { id: "biz-1", name: "Test Biz" } }),
    useGetDomainDetailSuspense: () => ({
      data: {
        name: "Sales",
        division: "Commercial",
        description: "",
        database_name: "",
        references: "",
        products: [],
      },
    }),
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
    useListVersionsSuspense: () => ({ data: [] }),
    useGetExplorerVersionsSuspense: () => ({
      data: [{ id: "v-1", version: 1, scope: "ecm" }],
    }),
    useGetUserPreferences: () => ({ data: { data: [] }, isLoading: false }),
  };
});

vi.mock("@tanstack/react-router", async () => {
  const actual = await vi.importActual<typeof import("@tanstack/react-router")>(
    "@tanstack/react-router",
  );
  return {
    ...actual,
    useSearch: () => ({ tab: currentTab }),
    useNavigate: () => navigateSpy,
    Link: ({ children, ...props }: any) => <a {...props}>{children}</a>,
  };
});

import { DomainDetail } from "@/routes/_sidebar/businesses.$businessId.model.$version.$scope.$domainName.index";

function renderDomainPage(tab: string) {
  currentTab = tab;
  const client = new QueryClient({
    defaultOptions: { queries: { retry: false }, mutations: { retry: false } },
  });
  return render(
    <QueryClientProvider client={client}>
      <ErrorBoundary fallbackRender={({ error }) => <div role="alert">Error: {String(error)}</div>}>
        <Suspense fallback={<div data-testid="suspense-fallback" />}>
          <DomainDetail businessId="biz-1" version="1" scope="ecm" domainName="Sales" />
        </Suspense>
      </ErrorBoundary>
    </QueryClientProvider>,
  );
}

/** The diagram's domain dropdown: the first combobox inside the active tab. */
async function diagramDomainSelect() {
  const panel = await screen.findByRole("tabpanel");
  await waitFor(() => expect(panel.querySelectorAll('[role="combobox"]').length).toBeGreaterThan(0));
  return panel.querySelector('[role="combobox"]') as HTMLElement;
}

beforeEach(() => {
  navigateSpy.mockClear();
  ontologyProps = null;
  (globalThis as any).fetch = vi.fn(() =>
    Promise.resolve({
      status: 200,
      ok: true,
      json: () =>
        Promise.resolve({
          nodes: [],
          edges: [],
          groups: [],
          domain_filter: "Sales",
          show_columns: false,
          total_products: 0,
          total_edges: 0,
        }),
    } as unknown as Response),
  );
});

afterEach(() => {
  cleanup();
});

describe("Domain page - domain dropdown inside the tabs", () => {
  it.each(["products", "diagram", "relationships", "ontology"])(
    "every combobox on the %s tab sits inside the tab panel",
    async (tab) => {
      renderDomainPage(tab);
      const panel = await screen.findByRole("tabpanel");
      for (const box of screen.queryAllByRole("combobox")) {
        expect(panel.contains(box)).toBe(true);
      }
    },
  );

  it("relationships: no domain select (the tab is model-wide)", async () => {
    renderDomainPage("relationships");
    await screen.findByTestId("relationship-analysis-stub");
    expect(screen.queryAllByRole("combobox")).toHaveLength(0);
  });

  it.each(["products"])(
    "%s: shows this domain, offers domains only, and opens the picked domain on the same tab",
    async (tab) => {
      renderDomainPage(tab);
      const panel = await screen.findByRole("tabpanel");
      const box = within(panel).getByRole("combobox", { name: "Domain" });
      expect(box).toHaveTextContent("Sales");
      fireEvent.click(box);
      expect(screen.queryByRole("option", { name: "All domains" })).not.toBeInTheDocument();
      fireEvent.click(await screen.findByRole("option", { name: /Inventory/ }));
      expect(navigateSpy).toHaveBeenCalledWith(
        expect.objectContaining({
          to: "/businesses/$businessId/model/$version/$scope/$domainName",
          params: { businessId: "biz-1", version: "1", scope: "ecm", domainName: "Inventory" },
          search: { tab },
        }),
      );
      expect(navigateSpy.mock.calls.at(-1)?.[0].replace).toBeUndefined();
    },
  );

  it("ontology: scoped to this domain with a host pick that opens another domain's Ontology tab", async () => {
    renderDomainPage("ontology");
    await screen.findByTestId("ontology-graph-stub");
    expect(ontologyProps?.domainFilter).toBe("Sales");
    (ontologyProps!.onDomainPick as (d: string | null) => void)("Inventory");
    expect(navigateSpy).toHaveBeenLastCalledWith(
      expect.objectContaining({
        to: "/businesses/$businessId/model/$version/$scope/$domainName",
        params: { businessId: "biz-1", version: "1", scope: "ecm", domainName: "Inventory" },
        search: { tab: "ontology" },
      }),
    );
  });

  it("ontology: 'All domains' opens the version page's Ontology tab", async () => {
    renderDomainPage("ontology");
    await screen.findByTestId("ontology-graph-stub");
    (ontologyProps!.onDomainPick as (d: string | null) => void)(null);
    expect(navigateSpy).toHaveBeenLastCalledWith(
      expect.objectContaining({
        to: "/businesses/$businessId/model/$version/$scope",
        params: { businessId: "biz-1", version: "1", scope: "ecm" },
        search: { tab: "ontology" },
      }),
    );
  });
});

describe("Domain page - Diagram tab domain dropdown", () => {
  it("shows the current domain in the diagram toolbar's dropdown", async () => {
    renderDomainPage("diagram");
    expect(await diagramDomainSelect()).toHaveTextContent("Sales");
  });

  it("opens another domain's diagram (push, same route)", async () => {
    renderDomainPage("diagram");
    fireEvent.click(await diagramDomainSelect());
    fireEvent.click(await screen.findByRole("option", { name: /Inventory/ }));
    expect(navigateSpy).toHaveBeenCalledWith(
      expect.objectContaining({
        to: "/businesses/$businessId/model/$version/$scope/$domainName",
        params: { businessId: "biz-1", version: "1", scope: "ecm", domainName: "Inventory" },
        search: { tab: "diagram" },
      }),
    );
    expect(navigateSpy.mock.calls.at(-1)?.[0].replace).toBeUndefined();
  });

  it("opens the all-domains diagram on the scope route on 'All domains'", async () => {
    renderDomainPage("diagram");
    fireEvent.click(await diagramDomainSelect());
    fireEvent.click(await screen.findByRole("option", { name: "All domains" }));
    expect(navigateSpy).toHaveBeenCalledWith(
      expect.objectContaining({
        to: "/businesses/$businessId/model/$version/$scope",
        params: { businessId: "biz-1", version: "1", scope: "ecm" },
        search: { tab: "diagram" },
      }),
    );
  });

  it("does nothing when the current domain is re-picked", async () => {
    renderDomainPage("diagram");
    fireEvent.click(await diagramDomainSelect());
    fireEvent.click(await screen.findByRole("option", { name: /Sales/ }));
    expect(navigateSpy).not.toHaveBeenCalled();
  });
});
