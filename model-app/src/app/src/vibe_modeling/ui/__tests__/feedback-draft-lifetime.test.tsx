/**
 * The Add-feedback draft lives for one page: tab switches keep it (see
 * feedback-wiring.test.tsx), Cancel / X / Escape discard it (an Escape a
 * nested control handled does not), a save clears
 * it, it is per model version, and leaving the page discards it. Real
 * button, dialog and draft store; the API is mocked.
 */
import { beforeEach, describe, expect, it, vi } from "vitest";
import { act, fireEvent, render, screen, waitFor } from "@testing-library/react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { Suspense, type ReactNode } from "react";

let routerPath = "/";
let searchHook: () => unknown = () => ({ tab: "products" });

vi.mock("@/components/diagram/diagram-viewer", () => ({
  DiagramViewer: () => <div data-testid="diagram-viewer-stub" />,
}));
vi.mock("@/components/explorer/relationship-analysis", () => ({
  RelationshipAnalysis: () => <div />,
}));
vi.mock("@/components/explorer/ontology-graph", () => ({ OntologyGraph: () => <div /> }));

vi.mock("@/lib/api", async () => {
  const actual = await vi.importActual<typeof import("@/lib/api")>("@/lib/api");
  return {
    ...actual,
    createVibeInput: vi.fn().mockResolvedValue({ data: { id: "vi1", text: "saved" } }),
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
    useRouterState: ({ select }: { select: (s: { location: { pathname: string } }) => string }) =>
      select({ location: { pathname: routerPath } }),
    Link: ({ children, ...props }: any) => <a {...props}>{children}</a>,
  };
});

import { createVibeInput } from "@/lib/api";
import { AddFeedbackButton } from "@/components/feedback/add-feedback-button";
import { FeedbackDraftPageScope } from "@/components/feedback/feedback-draft";
import { DomainDetail } from "@/routes/_sidebar/businesses.$businessId.model.$version.$scope.$domainName.index";
import { ProductDetail } from "@/routes/_sidebar/businesses.$businessId.model.$version.$scope.$domainName.$productName";

function wrap(ui: ReactNode) {
  const qc = new QueryClient({ defaultOptions: { queries: { retry: false } } });
  return render(
    <QueryClientProvider client={qc}>
      <Suspense fallback={null}>{ui}</Suspense>
    </QueryClientProvider>,
  );
}

const button = (versionId = "v1") => (
  <AddFeedbackButton businessId="b1" versionId={versionId} getContext={() => ({ domain_filter: "Sales" })} />
);

function openAndType(text = "my draft") {
  fireEvent.click(screen.getByRole("button", { name: /add feedback/i }));
  fireEvent.change(screen.getByRole("textbox"), { target: { value: text } });
}

function goToPage(path: string) {
  window.history.pushState({}, "", path);
  routerPath = path;
}

beforeEach(() => {
  goToPage("/page-a");
  vi.mocked(createVibeInput).mockClear();
});

describe("Add-feedback draft lifetime", () => {
  it.each([
    ["Cancel", () => fireEvent.click(screen.getByRole("button", { name: /cancel/i }))],
    ["the X", () => fireEvent.click(screen.getByRole("button", { name: /close/i }))],
    ["Escape", () => fireEvent.keyDown(window, { key: "Escape" })],
  ])("%s discards the draft: reopening is empty", (_label, close) => {
    wrap(button());
    openAndType();
    close();
    expect(screen.queryByRole("textbox")).not.toBeInTheDocument();
    fireEvent.click(screen.getByRole("button", { name: /add feedback/i }));
    expect(screen.getByRole("textbox")).toHaveValue("");
  });

  it("an Escape that closes the Priority select keeps the draft; the next one discards it", () => {
    wrap(button());
    openAndType("kept");
    fireEvent.click(screen.getByLabelText("Priority"));
    const listbox = screen.getByRole("listbox");
    fireEvent.keyDown(listbox, { key: "Escape" });
    expect(screen.queryByRole("listbox")).not.toBeInTheDocument();
    expect(screen.getByRole("textbox")).toHaveValue("kept");
    fireEvent.keyDown(window, { key: "Escape" });
    expect(screen.queryByRole("textbox")).not.toBeInTheDocument();
  });

  it("a successful save clears the draft: reopening is empty", async () => {
    const { unmount } = wrap(button());
    openAndType("make orders richer");
    await act(async () => {
      fireEvent.click(screen.getByRole("button", { name: /save feedback/i }));
    });
    await waitFor(() => expect(screen.queryByRole("textbox")).not.toBeInTheDocument());
    expect(vi.mocked(createVibeInput).mock.calls[0][1]).toMatchObject({
      text: "make orders richer",
      origin_context: { domain_filter: "Sales" },
    });
    unmount();
    wrap(button());
    fireEvent.click(screen.getByRole("button", { name: /add feedback/i }));
    expect(screen.getByRole("textbox")).toHaveValue("");
  });

  it("is kept per model version", () => {
    const first = wrap(button("v1"));
    openAndType("about v1");
    first.unmount();
    const second = wrap(button("v2"));
    expect(screen.queryByRole("textbox")).not.toBeInTheDocument();
    fireEvent.click(screen.getByRole("button", { name: /add feedback/i }));
    expect(screen.getByRole("textbox")).toHaveValue("");
    second.unmount();
    wrap(button("v1"));
    expect(screen.getByRole("textbox")).toHaveValue("about v1");
  });

  it("does not reopen on the next page: domain page -> product page", () => {
    searchHook = () => ({ tab: "products" });
    const domain = wrap(<DomainDetail businessId="biz-1" version="1" scope="ecm" domainName="Sales" />);
    openAndType("about the domain");
    domain.unmount();
    goToPage("/businesses/biz-1/model/1/ecm/Sales/Orders");
    wrap(<ProductDetail businessId="biz-1" version="1" scope="ecm" domainName="Sales" productName="Orders" />);
    expect(screen.queryByRole("textbox")).not.toBeInTheDocument();
  });

  it("is gone when the user later returns to the page it was written on", () => {
    const page = wrap(button());
    openAndType();
    page.unmount();
    goToPage("/page-b");
    wrap(<FeedbackDraftPageScope />).unmount();
    goToPage("/page-a");
    wrap(button());
    expect(screen.queryByRole("textbox")).not.toBeInTheDocument();
  });

  it("keeps the draft through a ?tab= change (same pathname)", () => {
    const page = wrap(button());
    openAndType("kept");
    page.unmount();
    window.history.pushState({}, "", "/page-a?tab=relationships");
    wrap(<FeedbackDraftPageScope />).unmount();
    wrap(button());
    expect(screen.getByRole("textbox")).toHaveValue("kept");
  });
});
