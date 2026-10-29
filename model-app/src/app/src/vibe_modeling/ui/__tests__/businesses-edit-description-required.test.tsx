/**
 * v0.4.0 Task #6 — Edit Business form requires a non-empty description.
 *
 * Mirrors the New Business gate so the contract is uniform across every
 * Business-write surface (new, edit, inline-edit dialog, import dialog).
 */
import { describe, it, expect, afterEach, vi } from "vitest";
import { warmImports } from "./helpers/warm-imports";
import { render, screen, waitFor, fireEvent } from "@testing-library/react";
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

let businessData: any = {
  id: "biz-1",
  name: "Acme Co",
  description: "An acme business.",
  industry_alignment: "Retail",
  industry_id: null,
  sector_id: null,
  created_at: "2024-01-01T00:00:00Z",
  updated_at: "2024-01-01T00:00:00Z",
};

vi.mock("@/lib/api", async () => {
  const actual = await vi.importActual<typeof import("@/lib/api")>("@/lib/api");
  return {
    ...actual,
    useGetBusinessSuspense: () => ({ data: businessData }),
    useListSectorsSuspense: () => ({ data: [] }),
    updateBusiness: vi.fn(async () => ({ data: businessData })),
  };
});

vi.mock("@/components/explorer/breadcrumb-context", async () => {
  return { useBreadcrumbs: () => {} };
});

afterEach(() => {
  vi.restoreAllMocks();
});

async function renderEditBusiness(initialDescription: string) {
  businessData = { ...businessData, description: initialDescription };

  const { Route: EditRoute } = await import(
    "@/routes/_sidebar/businesses.$businessId.edit"
  );
  const rootRoute = createRootRoute({ component: () => <Outlet /> });
  const sidebarRoute = createRoute({
    getParentRoute: () => rootRoute,
    id: "/_sidebar",
    component: () => <Outlet />,
  });
  const editClone = createRoute({
    getParentRoute: () => sidebarRoute,
    path: "/businesses/$businessId/edit",
    component: EditRoute.options.component as any,
  });
  const explorerStub = createRoute({
    getParentRoute: () => rootRoute,
    path: "/businesses/$businessId/explorer",
    component: () => <div data-testid="explorer-stub" />,
  });
  const router = createRouter({
    routeTree: rootRoute.addChildren([
      sidebarRoute.addChildren([editClone]),
      explorerStub,
    ]),
    history: createMemoryHistory({ initialEntries: ["/businesses/biz-1/edit"] }),
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

function getSubmit(): HTMLButtonElement {
  return screen.getByRole("button", {
    name: /Save Changes|Saving/i,
  }) as HTMLButtonElement;
}

function getDescriptionTextarea(): HTMLTextAreaElement {
  return screen.getByTestId("business-description") as HTMLTextAreaElement;
}

warmImports(() => import("@/routes/_sidebar/businesses.$businessId.edit"));

describe("v0.4.0 #6 — Edit Business: description required", () => {
  it("submit disabled when description is cleared; helper text visible", async () => {
    await renderEditBusiness("An acme business.");
    await waitFor(() => {
      expect(screen.queryAllByRole("combobox").length).toBeGreaterThan(0);
    });

    // Initial state — submit enabled.
    expect(getSubmit().disabled).toBe(false);

    fireEvent.change(getDescriptionTextarea(), { target: { value: "" } });
    expect(getSubmit().disabled).toBe(true);

    const helper = screen.getByTestId("business-description-helper");
    expect(helper.textContent ?? "").toMatch(/Required/i);
  });

  it("submit disabled when description is whitespace-only", async () => {
    await renderEditBusiness("An acme business.");
    await waitFor(() => {
      expect(screen.queryAllByRole("combobox").length).toBeGreaterThan(0);
    });

    fireEvent.change(getDescriptionTextarea(), { target: { value: "   \n  " } });
    expect(getSubmit().disabled).toBe(true);
  });

  it("submit re-enabled after typing non-empty description", async () => {
    await renderEditBusiness("An acme business.");
    await waitFor(() => {
      expect(screen.queryAllByRole("combobox").length).toBeGreaterThan(0);
    });

    fireEvent.change(getDescriptionTextarea(), { target: { value: "" } });
    expect(getSubmit().disabled).toBe(true);

    fireEvent.change(getDescriptionTextarea(), {
      target: { value: "New description after edit." },
    });
    expect(getSubmit().disabled).toBe(false);
  });
});
