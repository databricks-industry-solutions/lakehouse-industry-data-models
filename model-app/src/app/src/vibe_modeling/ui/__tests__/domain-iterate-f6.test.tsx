/**
 * F6: the domain page header offers "Iterate on this domain" (a scoped vibe
 * on this domain) only when the page's version is the scope head.
 */
import { describe, expect, it, vi, beforeEach } from "vitest";
import { render, screen } from "@testing-library/react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { Suspense } from "react";
import { ErrorBoundary } from "react-error-boundary";

const navigateSpy = vi.fn();
let searchHook: () => unknown = () => ({ tab: "diagram" });
let listVersions: unknown[] = [];

vi.mock("@/components/diagram/diagram-viewer", () => ({
  DiagramViewer: () => <div data-testid="diagram-viewer-stub" />,
}));

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
    useListVersionsSuspense: () => ({ data: listVersions }),
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
    useSearch: () => searchHook(),
    useNavigate: () => navigateSpy,
    Link: ({ children, ...props }: any) => <a {...props}>{children}</a>,
  };
});

import { DomainDetail } from "@/routes/_sidebar/businesses.$businessId.model.$version.$scope.$domainName.index";

function makeClient() {
  return new QueryClient({
    defaultOptions: { queries: { retry: false }, mutations: { retry: false } },
  });
}

function renderDomainPage() {
  return render(
    <QueryClientProvider client={makeClient()}>
      <ErrorBoundary fallbackRender={({ error }) => <div role="alert">Error: {String(error)}</div>}>
        <Suspense fallback={<div data-testid="suspense-fallback" />}>
          <DomainDetail businessId="biz-1" version="1" scope="ecm" domainName="Sales" />
        </Suspense>
      </ErrorBoundary>
    </QueryClientProvider>,
  );
}

beforeEach(() => {
  navigateSpy.mockClear();
  searchHook = () => ({ tab: "products" });
  listVersions = [];
});

describe("Domain page - Iterate on this domain (F6)", () => {
  it("links a scoped vibe on this domain when the version is the head", () => {
    listVersions = [{ id: "v-1", version: 1, scope: "ecm", is_head: true, deployment_status: "draft", uc_catalog: "" }];
    renderDomainPage();
    const link = screen.getByTestId("iterate-on-domain");
    expect(link).toHaveTextContent("Iterate on this domain");
    expect(link).toHaveAttribute("to", "/businesses/$businessId/runs/new");
  });

  it("is hidden on a version that is not the head", () => {
    listVersions = [{ id: "v-1", version: 1, scope: "ecm", is_head: false, deployment_status: "draft", uc_catalog: "" }];
    renderDomainPage();
    expect(screen.queryByTestId("iterate-on-domain")).toBeNull();
  });
});
