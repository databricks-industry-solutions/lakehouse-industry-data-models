/**
 * Domain page (`$domainName.index.tsx`) same-route domain switch (item 3B
 * regression, caught in commit review).
 *
 * A domain-to-domain navigation from the diagram's domain dropdown (or a
 * related-domain-group click inside the diagram) stays on THIS route -
 * only the `domainName` URL param changes. The router re-renders
 * `DomainDetail` in place rather than remounting it, so a plain prop change
 * would NOT reach `DiagramViewer`'s internal `useState`-seeded
 * `selectedDomain` (item 3B deleted the resync fallback that used to keep
 * it live). Without a fix, the diagram would silently keep showing the OLD
 * domain's layout while the URL, breadcrumbs, and page title all show
 * the new one. The fix keys `DiagramViewer` on `domainName` so React
 * remounts it on every domain change, matching what a cross-route
 * navigation already gets for free.
 *
 * This test uses the REAL `DiagramViewer` (not a stub) with a mocked
 * `fetch`, rerenders `DomainDetail` with a new `domainName` prop (the same
 * prop change the router would apply), and asserts the diagram issues a
 * fresh layout request for the NEW domain rather than staying stuck on the
 * old one.
 */
import { describe, it, expect, vi, beforeEach, afterEach } from "vitest";
import { render, waitFor, cleanup } from "@testing-library/react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";

class ResizeObserverStub {
  observe() {}
  unobserve() {}
  disconnect() {}
}
(globalThis as any).ResizeObserver = ResizeObserverStub;

if (!(globalThis as any).DOMMatrixReadOnly) {
  (globalThis as any).DOMMatrixReadOnly = class {
    m22 = 1;
    constructor() {}
  };
}

vi.mock("@tanstack/react-router", async () => {
  const actual = await vi.importActual<typeof import("@tanstack/react-router")>(
    "@tanstack/react-router",
  );
  return {
    ...actual,
    useSearch: () => ({ tab: "diagram" }),
    useNavigate: () => vi.fn(),
    Link: ({ children, ...props }: any) => <a {...props}>{children}</a>,
  };
});

vi.mock("@/lib/api", async () => {
  const actual = await vi.importActual<typeof import("@/lib/api")>("@/lib/api");
  return {
    ...actual,
    useGetBusinessSuspense: () => ({ data: { id: "biz-1", name: "Test Biz" } }),
    useGetDomainDetailSuspense: (opts: any) => ({
      data: {
        name: opts.params.domain_name,
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

import { DomainDetail } from "@/routes/_sidebar/businesses.$businessId.model.$version.$scope.$domainName.index";

function fetchUrls(impl: ReturnType<typeof vi.fn>) {
  return impl.mock.calls.map((c) => String(c[0]));
}

function mockLayoutFetch() {
  const impl = vi.fn((_url: string) =>
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
  (globalThis as any).fetch = impl;
  return impl;
}

function renderDomainPage(qc: QueryClient, domainName: string) {
  return render(
    <QueryClientProvider client={qc}>
      <DomainDetail businessId="biz-1" version="1" scope="ecm" domainName={domainName} />
    </QueryClientProvider>,
  );
}

beforeEach(() => {
  vi.useRealTimers();
});

afterEach(() => {
  cleanup();
  vi.restoreAllMocks();
});

describe("Domain page - DiagramViewer remounts on a same-route domain switch (item 3B regression)", () => {
  it("re-fetches the layout for the NEW domain after a domainName prop change, not the old one", async () => {
    const fetchImpl = mockLayoutFetch();
    const qc = new QueryClient({ defaultOptions: { queries: { retry: false } } });
    const { rerender } = renderDomainPage(qc, "Sales");

    await waitFor(() => {
      expect(fetchUrls(fetchImpl).some((u) => u.includes("domain=Sales"))).toBe(true);
    });

    // Simulate the router re-rendering this SAME route with a new
    // `domainName` param (no unmount of the outer tree - exactly what a
    // same-route param-only navigation does).
    fetchImpl.mockClear();
    rerender(
      <QueryClientProvider client={qc}>
        <DomainDetail businessId="biz-1" version="1" scope="ecm" domainName="Inventory" />
      </QueryClientProvider>,
    );

    await waitFor(() => {
      expect(fetchUrls(fetchImpl).some((u) => u.includes("domain=Inventory"))).toBe(true);
    });
    // The stale domain must not still be the one in flight.
    expect(fetchUrls(fetchImpl).some((u) => u.includes("domain=Sales"))).toBe(false);
  });
});
