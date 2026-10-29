/**
 * Add-feedback on the domain and product pages captures the model element
 * the page is about (the domain, the product, or the diagram's selection on
 * the domain page's diagram tab), never the tab.
 */
import { beforeEach, describe, expect, it, vi } from "vitest";
import { fireEvent, render, screen } from "@testing-library/react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { Suspense } from "react";

let searchHook: () => unknown = () => ({ tab: "products" });
// The latest props the Add-feedback stub rendered with.
let feedbackProps: any = null;

vi.mock("@/components/diagram/diagram-viewer", () => ({
  DiagramViewer: ({ feedbackSlot, onSelectionChange }: any) => (
    <div data-testid="diagram-viewer-stub">
      <button onClick={() => onSelectionChange?.({ nodeId: "Sales.Orders", edgeId: null })}>
        select-node
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
vi.mock("@/components/explorer/relationship-analysis", () => ({
  RelationshipAnalysis: () => <div data-testid="relationship-analysis-stub" />,
}));
vi.mock("@/components/explorer/ontology-graph", () => ({
  OntologyGraph: () => <div data-testid="ontology-graph-stub" />,
}));

vi.mock("@/lib/api", async () => {
  const actual = await vi.importActual<typeof import("@/lib/api")>("@/lib/api");
  return {
    ...actual,
    useGetBusinessSuspense: () => ({ data: { id: "biz-1", name: "Test Biz" } }),
    useGetDomainDetailSuspense: () => ({
      data: { name: "Sales", division: "", description: "", database_name: "", references: "", products: [] },
    }),
    useGetModelSummarySuspense: () => ({
      data: { name: "Test Model", version: 1, domains: [{ name: "Sales", division: "", change_status: "unchanged" }] },
    }),
    useListVersionsSuspense: () => ({ data: [] }),
    useGetExplorerVersionsSuspense: () => ({ data: [{ id: "v-1", version: 1, scope: "ecm" }] }),
    useGetUserPreferences: () => ({ data: { data: [] }, isLoading: false }),
    useGetProductDetailSuspense: () => ({
      data: { name: "Orders", table_name: "orders", description: "", attributes: [] },
    }),
  };
});

vi.mock("@tanstack/react-router", async () => {
  const actual = await vi.importActual<typeof import("@tanstack/react-router")>(
    "@tanstack/react-router",
  );
  return {
    ...actual,
    useSearch: () => searchHook(),
    useNavigate: () => vi.fn(),
    Link: ({ children, ...props }: any) => <a {...props}>{children}</a>,
  };
});

import { DomainDetail } from "@/routes/_sidebar/businesses.$businessId.model.$version.$scope.$domainName.index";
import { ProductDetail } from "@/routes/_sidebar/businesses.$businessId.model.$version.$scope.$domainName.$productName";

function wrap(ui: React.ReactNode) {
  const qc = new QueryClient({ defaultOptions: { queries: { retry: false } } });
  return render(
    <QueryClientProvider client={qc}>
      <Suspense fallback={null}>{ui}</Suspense>
    </QueryClientProvider>,
  );
}

const domainPage = () =>
  wrap(<DomainDetail businessId="biz-1" version="1" scope="ecm" domainName="Sales" />);

beforeEach(() => {
  feedbackProps = null;
});

describe("Domain page Add-feedback", () => {
  it.each(["products", "relationships", "ontology"])("captures the domain on the %s tab", (tab) => {
    searchHook = () => ({ tab });
    domainPage();
    expect(feedbackProps.getContext()).toEqual({ domain_filter: "Sales" });
  });

  it("captures the diagram's selected table, else the domain", () => {
    searchHook = () => ({ tab: "diagram" });
    domainPage();
    expect(feedbackProps.getContext()).toEqual({ domain_filter: "Sales" });
    fireEvent.click(screen.getByText("select-node"));
    expect(feedbackProps.getContext()).toEqual({ selected_node_id: "Sales.Orders" });
  });
});

describe("Product page Add-feedback", () => {
  it("captures the product", () => {
    wrap(
      <ProductDetail businessId="biz-1" version="1" scope="ecm" domainName="Sales" productName="Orders" />,
    );
    expect(feedbackProps.getContext()).toEqual({ selected_node_id: "Sales.Orders" });
  });
});
