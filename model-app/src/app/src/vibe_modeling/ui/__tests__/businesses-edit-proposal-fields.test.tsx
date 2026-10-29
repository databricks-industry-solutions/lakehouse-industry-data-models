/**
 * Edit Business: the proposed "Business domains" (TagInput) and
 * "Organization divisions" (presets + "Not set") round-trip through
 * updateBusiness. Patch-style: unchanged fields are not sent, so a stored
 * value that is no longer a preset survives an unrelated edit.
 */
import { beforeEach, describe, expect, it, vi } from "vitest";
import { warmImports } from "./helpers/warm-imports";
import { fireEvent, render, screen, waitFor } from "@testing-library/react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { Suspense } from "react";
import {
  createMemoryHistory,
  createRootRoute,
  createRoute,
  createRouter,
  Outlet,
  RouterProvider,
} from "@tanstack/react-router";

const m = vi.hoisted(() => ({
  business: {} as Record<string, unknown>,
  updateBusiness: vi.fn(),
}));

vi.mock("@/lib/api", async () => {
  const actual = await vi.importActual<typeof import("@/lib/api")>("@/lib/api");
  return {
    ...actual,
    useGetBusinessSuspense: () => ({ data: m.business }),
    useListSectorsSuspense: () => ({ data: [] }),
    updateBusiness: m.updateBusiness,
  };
});
vi.mock("@/components/explorer/breadcrumb-context", () => ({ useBreadcrumbs: () => {} }));
vi.mock("@/components/ui/markdown-toolbar", () => ({ MarkdownToolbar: () => null }));

const BUSINESS = {
  id: "biz-1", name: "Acme Co", description: "An acme business.", business_vibes: "", industry_alignment: "",
  sector_id: null, business_domains: "customer, billing", org_divisions: "Operations and Business",
  created_at: "2024-01-01T00:00:00Z", updated_at: "2024-01-01T00:00:00Z",
};

async function renderEdit() {
  const { Route: EditRoute } = await import("@/routes/_sidebar/businesses.$businessId.edit");
  const root = createRootRoute({ component: () => <Outlet /> });
  const sidebar = createRoute({ getParentRoute: () => root, id: "/_sidebar", component: () => <Outlet /> });
  const edit = createRoute({
    getParentRoute: () => sidebar, path: "/businesses/$businessId/edit", component: EditRoute.options.component as any,
  });
  const explorer = createRoute({
    getParentRoute: () => root, path: "/businesses/$businessId/explorer", component: () => <div data-testid="explorer-stub" />,
  });
  const router = createRouter({
    routeTree: root.addChildren([sidebar.addChildren([edit]), explorer]),
    history: createMemoryHistory({ initialEntries: ["/businesses/biz-1/edit"] }),
    defaultPendingMs: 0,
  });
  render(
    <QueryClientProvider client={new QueryClient({ defaultOptions: { queries: { retry: false }, mutations: { retry: false } } })}>
      <Suspense fallback={<div />}>
        <RouterProvider router={router} />
      </Suspense>
    </QueryClientProvider>,
  );
  await screen.findByText("Business domains");
}

const orgTrigger = () => screen.getByTestId("business-org-divisions");
const save = () => fireEvent.click(screen.getByRole("button", { name: /save changes/i }));
const sent = () => m.updateBusiness.mock.calls[0][1];

beforeEach(() => {
  m.business = { ...BUSINESS };
  m.updateBusiness.mockReset().mockResolvedValue({ data: BUSINESS });
});

warmImports(() => import("@/routes/_sidebar/businesses.$businessId.edit"));

describe("Edit Business: proposed domains + coverage", () => {
  it("shows the stored values", async () => {
    await renderEdit();
    expect(screen.getByText("customer")).toBeTruthy();
    expect(screen.getByText("billing")).toBeTruthy();
    expect(orgTrigger().textContent).toBe("Operations and Business");
  });

  it("an unrelated edit sends neither field", async () => {
    await renderEdit();
    fireEvent.change(screen.getByTestId("business-description"), { target: { value: "Changed." } });
    save();
    await waitFor(() => expect(m.updateBusiness).toHaveBeenCalled());
    expect(sent()).not.toHaveProperty("business_domains");
    expect(sent()).not.toHaveProperty("org_divisions");
    expect(sent().description).toBe("Changed.");
  });

  it("adding a domain and picking a preset sends both", async () => {
    await renderEdit();
    const tagInput = screen.getByText("customer").parentElement!.querySelector("input")!;
    fireEvent.change(tagInput, { target: { value: "asset" } });
    fireEvent.keyDown(tagInput, { key: "Enter" });
    fireEvent.click(orgTrigger());
    fireEvent.click(await screen.findByRole("option", { name: "Operations, Business and Corporate" }));
    save();
    await waitFor(() => expect(m.updateBusiness).toHaveBeenCalled());
    expect(sent()).toMatchObject({
      business_domains: "customer, billing, asset",
      org_divisions: "Operations, Business and Corporate",
    });
  });

  it("Not set clears org divisions", async () => {
    await renderEdit();
    fireEvent.click(orgTrigger());
    fireEvent.click(await screen.findByRole("option", { name: "Not set" }));
    save();
    await waitFor(() => expect(m.updateBusiness).toHaveBeenCalled());
    expect(sent().org_divisions).toBe("");
  });

  it("empty stored values show Not set and no chips", async () => {
    m.business = { ...BUSINESS, business_domains: "", org_divisions: "" };
    await renderEdit();
    expect(orgTrigger().textContent).toBe("Not set");
    expect(screen.queryByText("customer")).toBeNull();
  });

  it("a stored non-preset value shows as 'Current: <value>' and survives an unrelated save", async () => {
    m.business = { ...BUSINESS, org_divisions: "Legacy coverage" };
    await renderEdit();
    expect(orgTrigger().textContent).toBe("Current: Legacy coverage");
    fireEvent.change(screen.getByTestId("business-description"), { target: { value: "Changed." } });
    save();
    await waitFor(() => expect(m.updateBusiness).toHaveBeenCalled());
    expect(sent()).not.toHaveProperty("org_divisions");
  });

  it("a stored preset gets no 'Current:' item", async () => {
    await renderEdit();
    fireEvent.click(orgTrigger());
    await screen.findByRole("option", { name: "Not set" });
    expect(screen.queryByRole("option", { name: /^Current:/ })).toBeNull();
  });
});
