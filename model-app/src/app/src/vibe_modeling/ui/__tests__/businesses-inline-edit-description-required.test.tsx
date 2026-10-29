/**
 * v0.4.0 Task #6 — Inline edit-business dialog (Pencil icon on the Runs
 * page header) requires a non-empty description before Save enables.
 */
import { describe, it, expect, afterEach, vi } from "vitest";
import { warmImports } from "./helpers/warm-imports";
import { render, screen, waitFor, fireEvent, act } from "@testing-library/react";
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

const RETAIL_IND = {
  id: "ind-retail",
  name: "Retail",
  short_name: "Retail",
  description: "Retail sector description.",
  notable_businesses: "Amazon, Walmart",
  is_active: true,
  is_auto_created: false,
  display_order: 1,
  created_at: "2024-01-01T00:00:00Z",
  updated_at: "2024-01-01T00:00:00Z",
};

const businessData = {
  id: "biz-1",
  name: "Acme Co",
  description: "An acme business.",
  industry_alignment: "Retail",
  industry_id: null,
  created_at: "2024-01-01T00:00:00Z",
  updated_at: "2024-01-01T00:00:00Z",
};

vi.mock("@/lib/api", async () => {
  const actual = await vi.importActual<typeof import("@/lib/api")>("@/lib/api");
  return {
    ...actual,
    useGetBusinessSuspense: () => ({ data: businessData }),
    useListRunsSuspense: () => ({ data: [] }),
    useListVersionsSuspense: () => ({ data: [] }),
    useListIndustriesSuspense: () => ({ data: [RETAIL_IND] }),
    useListSectorsSuspense: () => ({ data: [] }),
    updateBusiness: vi.fn(async () => ({ data: businessData })),
    deleteBusiness: vi.fn(),
  };
});

vi.mock("@/lib/hooks", async () => {
  const actual = await vi.importActual<typeof import("@/lib/hooks")>("@/lib/hooks");
  return {
    ...actual,
    useAgentReady: () => ({ data: { ready: true, reason: null } }),
  };
});

afterEach(() => {
  vi.restoreAllMocks();
});

async function renderRunsIndex() {
  const { Route: RunsIndexRoute } = await import(
    "@/routes/_sidebar/businesses.$businessId.runs.index"
  );
  const rootRoute = createRootRoute({ component: () => <Outlet /> });
  const sidebarRoute = createRoute({
    getParentRoute: () => rootRoute,
    id: "/_sidebar",
    component: () => <Outlet />,
  });
  const runsClone = createRoute({
    getParentRoute: () => sidebarRoute,
    path: "/businesses/$businessId/runs",
    component: RunsIndexRoute.options.component as any,
  });
  const businessesStub = createRoute({
    getParentRoute: () => rootRoute,
    path: "/businesses",
    component: () => <div data-testid="businesses-stub" />,
  });
  const router = createRouter({
    routeTree: rootRoute.addChildren([
      sidebarRoute.addChildren([runsClone]),
      businessesStub,
    ]),
    history: createMemoryHistory({ initialEntries: ["/businesses/biz-1/runs"] }),
    defaultPendingMs: 0,
  });
  const qc = new QueryClient({
    defaultOptions: {
      queries: { retry: false },
      mutations: { retry: false },
    },
  });
  render(
    <QueryClientProvider client={qc}>
      <Suspense fallback={<div data-testid="suspense-fallback" />}>
        <RouterProvider router={router} />
      </Suspense>
    </QueryClientProvider>,
  );
}

async function openEditDialog() {
  const editTrigger = await screen.findByTitle(/Edit business/i);
  await act(async () => {
    fireEvent.click(editTrigger);
  });
}

function getSaveButton(): HTMLButtonElement {
  return screen.getByRole("button", { name: /Save|Saving/i }) as HTMLButtonElement;
}

warmImports(() => import("@/routes/_sidebar/businesses.$businessId.runs.index"));

describe("v0.4.0 #6 — Inline edit dialog: description required", () => {
  it("Save disabled when description is cleared; helper visible", async () => {
    await renderRunsIndex();
    await waitFor(() => {
      expect(screen.queryByTitle(/Edit business/i)).not.toBeNull();
    });
    await openEditDialog();

    const desc = screen.getByTestId("business-description") as HTMLTextAreaElement;
    expect(desc.value).toBe("An acme business.");
    expect(getSaveButton().disabled).toBe(false);

    fireEvent.change(desc, { target: { value: "" } });
    expect(getSaveButton().disabled).toBe(true);

    expect(
      screen.getByTestId("business-description-helper").textContent ?? "",
    ).toMatch(/Required/i);
  });

  it("Save disabled when description is whitespace-only", async () => {
    await renderRunsIndex();
    await waitFor(() => {
      expect(screen.queryByTitle(/Edit business/i)).not.toBeNull();
    });
    await openEditDialog();

    const desc = screen.getByTestId("business-description") as HTMLTextAreaElement;
    fireEvent.change(desc, { target: { value: "   \n  " } });
    expect(getSaveButton().disabled).toBe(true);
  });

  it("Save re-enabled after typing non-empty description", async () => {
    await renderRunsIndex();
    await waitFor(() => {
      expect(screen.queryByTitle(/Edit business/i)).not.toBeNull();
    });
    await openEditDialog();

    const desc = screen.getByTestId("business-description") as HTMLTextAreaElement;
    fireEvent.change(desc, { target: { value: "" } });
    expect(getSaveButton().disabled).toBe(true);

    fireEvent.change(desc, { target: { value: "Updated through inline dialog." } });
    expect(getSaveButton().disabled).toBe(false);
  });
});
