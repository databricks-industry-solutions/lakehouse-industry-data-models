/**
 * Product page: the domain dropdown jumps from a product in one domain to
 * another domain's page, on its Products tab.
 */
import { beforeEach, describe, expect, it, vi } from "vitest";
import { fireEvent, render, screen } from "@testing-library/react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { Suspense } from "react";

const navigateSpy = vi.fn();
const summaryFetch = vi.fn((_params: unknown) => new Promise(() => {}));

vi.mock("@/components/feedback/add-feedback-button", () => ({
  AddFeedbackButton: () => <div data-testid="add-feedback-stub" />,
}));
vi.mock("@/components/explorer/breadcrumb-context", () => ({ useBreadcrumbs: () => {} }));

vi.mock("@/lib/api", async () => {
  const actual = await vi.importActual<typeof import("@/lib/api")>("@/lib/api");
  return {
    ...actual,
    getModelSummary: (params: unknown) => summaryFetch(params),
    useGetBusinessSuspense: () => ({ data: { id: "biz-1", name: "Test Biz" } }),
    useGetModelSummarySuspense: () => ({
      data: {
        name: "Test Model",
        version: 1,
        domains: [
          { name: "Sales", division: "Commercial", change_status: "unchanged" },
          { name: "Inventory", division: "Ops", change_status: "unchanged" },
          { name: "Legacy", division: "", change_status: "deleted" },
        ],
      },
    }),
    useGetExplorerVersionsSuspense: () => ({ data: [{ id: "v-1", version: 1, scope: "ecm" }] }),
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
    useNavigate: () => navigateSpy,
    Link: ({ children, ...props }: any) => <a {...props}>{children}</a>,
  };
});

import { ProductDetail } from "@/routes/_sidebar/businesses.$businessId.model.$version.$scope.$domainName.$productName";

function renderProduct() {
  const qc = new QueryClient({ defaultOptions: { queries: { retry: false } } });
  return render(
    <QueryClientProvider client={qc}>
      <Suspense fallback={<div data-testid="suspense-fallback" />}>
        <ProductDetail businessId="biz-1" version="1" scope="ecm" domainName="Sales" productName="Orders" />
      </Suspense>
    </QueryClientProvider>,
  );
}

beforeEach(() => {
  navigateSpy.mockClear();
  summaryFetch.mockClear();
});

describe("Product page - domain dropdown", () => {
  it("shows the product's domain and offers the live domains only", async () => {
    renderProduct();
    const box = await screen.findByRole("combobox", { name: "Domain" });
    expect(box).toHaveTextContent("Sales");
    fireEvent.click(box);
    expect(await screen.findByRole("option", { name: /Inventory/ })).toBeInTheDocument();
    expect(screen.queryByRole("option", { name: "All domains" })).not.toBeInTheDocument();
    expect(screen.queryByRole("option", { name: /Legacy/ })).not.toBeInTheDocument();
  });

  it("opens the picked domain's page on its Products tab (push)", async () => {
    renderProduct();
    fireEvent.click(await screen.findByRole("combobox", { name: "Domain" }));
    fireEvent.click(await screen.findByRole("option", { name: /Inventory/ }));
    expect(navigateSpy).toHaveBeenCalledWith({
      to: "/businesses/$businessId/model/$version/$scope/$domainName",
      params: { businessId: "biz-1", version: "1", scope: "ecm", domainName: "Inventory" },
      search: { tab: "products" },
    });
  });

  it("starts the dropdown's model-summary request on the first render, with the page's queries", () => {
    renderProduct();
    expect(summaryFetch).toHaveBeenCalledWith({ business_id: "biz-1", version_int: 1, scope: "ecm" });
  });

  it("does nothing when the product's own domain is re-picked", async () => {
    renderProduct();
    fireEvent.click(await screen.findByRole("combobox", { name: "Domain" }));
    fireEvent.click(await screen.findByRole("option", { name: /Sales/ }));
    expect(navigateSpy).not.toHaveBeenCalled();
  });
});
