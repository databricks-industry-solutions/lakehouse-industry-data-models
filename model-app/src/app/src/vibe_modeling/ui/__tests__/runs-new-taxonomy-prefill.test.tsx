/**
 * Business-field pre-fill: the business's stored `business_domains` +
 * `org_divisions` (saved by the Domain Taxonomy Builder or the edit page) seed
 * the FIRST New Base Model run - only when the business has no versions - and
 * open the Advanced Options disclosure so the values are visible. Without them
 * the form is unchanged (collapsed, org divisions on the form default).
 * URL params no longer pre-fill anything.
 */
import { beforeEach, describe, expect, it, vi } from "vitest";
import { warmImports } from "./helpers/warm-imports";
import { fireEvent, render, screen, waitFor } from "@testing-library/react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import {
  createMemoryHistory,
  createRootRoute,
  createRoute,
  createRouter,
  Outlet,
  RouterProvider,
} from "@tanstack/react-router";
import { Suspense } from "react";

const mocks = vi.hoisted(() => ({
  createRun: vi.fn(async () => ({})),
  validateRun: vi.fn(async () => ({ data: { blockers: [], warnings: [] } })),
  business: {} as Record<string, unknown>,
  versions: [] as unknown[],
}));

vi.mock("@/lib/api", async () => {
  const actual = await vi.importActual<typeof import("@/lib/api")>("@/lib/api");
  return {
    ...actual,
    // No base-model pre-fill: the form keeps its own values.
    useGetRunDefaults: () => ({ data: undefined, isLoading: false, isError: false }),
    useGetBusinessSuspense: () => ({
      data: {
        id: "biz-1", name: "Ridgeline Energy", description: "Short summary.", business_vibes: "## Conformance clamp",
        business_domains: "", org_divisions: "", ...mocks.business,
      },
    }),
    useListVersionsSuspense: () => ({ data: mocks.versions }),
    createRun: mocks.createRun,
    validateRun: mocks.validateRun,
  };
});
vi.mock("@/components/ui/markdown-toolbar", () => ({ MarkdownToolbar: () => null }));
vi.mock("@/components/runs/deployment-catalog-picker", () => ({
  DeploymentCatalogPicker: ({ value, onChange }: { value: string; onChange: (v: string) => void }) => (
    <input data-testid="catalog-picker" value={value} onChange={(e) => onChange(e.target.value)} />
  ),
}));

async function renderRunsNew(search: Record<string, string>) {
  const { Route: RunsNewRoute } = await import("@/routes/_sidebar/businesses.$businessId.runs.new");
  const rootRoute = createRootRoute({ component: () => <Outlet /> });
  const sidebarRoute = createRoute({ getParentRoute: () => rootRoute, id: "/_sidebar", component: () => <Outlet /> });
  const runsNewClone = createRoute({
    getParentRoute: () => sidebarRoute,
    path: "/businesses/$businessId/runs/new",
    component: RunsNewRoute.options.component as any,
    validateSearch: RunsNewRoute.options.validateSearch as any,
  });
  const explorerRoute = createRoute({
    getParentRoute: () => rootRoute,
    path: "/businesses/$businessId/explorer",
    component: () => <div data-testid="explorer-stub" />,
  });
  const router = createRouter({
    routeTree: rootRoute.addChildren([sidebarRoute.addChildren([runsNewClone]), explorerRoute]),
    history: createMemoryHistory({
      initialEntries: [`/businesses/biz-1/runs/new?${new URLSearchParams(search).toString()}`],
    }),
    defaultPendingMs: 0,
  });
  const qc = new QueryClient({
    defaultOptions: { queries: { retry: false, staleTime: 30_000, refetchOnWindowFocus: false }, mutations: { retry: false } },
  });
  return render(
    <QueryClientProvider client={qc}>
      <Suspense fallback={<div data-testid="suspense-fallback" />}>
        <RouterProvider router={router} />
      </Suspense>
    </QueryClientProvider>,
  );
}

const VERSION = {
  id: "mv-1", version: 1, status: "completed", scope: "mvm", uc_catalog: "cat", created_at: "2026-10-01T00:00:00Z",
};

beforeEach(() => {
  mocks.business = {};
  mocks.versions = [];
});

const orgTrigger = () =>
  // Scope to the Organization Divisions trigger: Radix also renders a hidden
  // native <option> per preset, so a bare text match would pass for any value.
  screen.getAllByRole("combobox").find((el) => (el.textContent ?? "").includes("Operations"));

warmImports(() => import("@/routes/_sidebar/businesses.$businessId.runs.new"));

describe("runs.new pre-fill from the business", () => {
  it("pre-fills domain tags + org divisions and opens Advanced Options so they are visible", async () => {
    mocks.business = { business_domains: "customer, billing", org_divisions: "Operations, Business and Corporate" };
    await renderRunsNew({ operationType: "new base model" });
    // No click on "Advanced Options": the disclosure starts open when pre-filled.
    await waitFor(() => expect(screen.getByText("customer")).toBeTruthy());
    expect(screen.getByText("billing")).toBeTruthy();
    expect(orgTrigger()?.textContent).toBe("Operations, Business and Corporate");
    expect(screen.queryByTestId("org-divisions-auto")).toBeNull();
  });

  it("seeds the domain chips in stored order", async () => {
    mocks.business = { business_domains: "customer, billing" };
    await renderRunsNew({ operationType: "new base model" });
    await waitFor(() => expect(screen.getByText("customer")).toBeTruthy());
    const chips = [...document.querySelectorAll("span.bg-secondary")].map((e) => e.textContent);
    expect(chips).toEqual(["customer", "billing"]);
  });

  it("ignores a stored org_divisions that is not a preset", async () => {
    mocks.business = { org_divisions: "Everything" };
    await renderRunsNew({ operationType: "new base model" });
    await waitFor(() => expect(screen.getByText(/advanced options/i)).toBeTruthy());
    expect(screen.queryByText("Organization Divisions")).toBeNull();
    fireEvent.click(screen.getByText(/advanced options/i));
    await waitFor(() => expect(orgTrigger()?.textContent).toBe("Operations"));
  });

  it("without stored values the form keeps today's defaults (collapsed, default divisions)", async () => {
    await renderRunsNew({ operationType: "new base model" });
    await waitFor(() => expect(screen.getByText(/advanced options/i)).toBeTruthy());
    expect(screen.queryByText("Organization Divisions")).toBeNull();
    fireEvent.click(screen.getByText(/advanced options/i));
    await waitFor(() => expect(orgTrigger()?.textContent).toBe("Operations"));
    // New Base Model always runs as the large model; its divisions do not follow a size.
    expect(screen.queryByTestId("org-divisions-auto")).toBeNull();
  });

  it("does not pre-fill when the business already has versions", async () => {
    mocks.business = { business_domains: "customer, billing", org_divisions: "Operations, Business and Corporate" };
    mocks.versions = [VERSION];
    await renderRunsNew({ operationType: "new base model" });
    await waitFor(() => expect(screen.getByText(/advanced options/i)).toBeTruthy());
    expect(screen.queryByText("Organization Divisions")).toBeNull();
    fireEvent.click(screen.getByText(/advanced options/i));
    await waitFor(() => expect(screen.getByText("Organization Divisions")).toBeTruthy());
    expect(screen.queryByText("customer")).toBeNull();
    expect(orgTrigger()?.textContent).not.toBe("Operations, Business and Corporate");
  });

  it("URL params no longer pre-fill", async () => {
    await renderRunsNew({ operationType: "new base model", domains: "customer", orgDivisions: "Operations and Business" });
    await waitFor(() => expect(screen.getByText(/advanced options/i)).toBeTruthy());
    expect(screen.queryByText("customer")).toBeNull();
    expect(screen.queryByText("Organization Divisions")).toBeNull();
  });
});
