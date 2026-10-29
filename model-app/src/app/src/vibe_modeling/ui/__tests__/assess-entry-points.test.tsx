/**
 * The optional bronze assessment skill's entry points show only when
 * `GET /assess/config` reports `ready` (`useAssessReady`): the explorer's
 * Assessments link here; the Assess button and the workflow diagram's
 * "After you publish" phase have their own tests.
 */
import { afterEach, describe, expect, it, vi } from "vitest";
import { warmImports } from "./helpers/warm-imports";
import { render, screen } from "@testing-library/react";
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

const { assess } = vi.hoisted(() => ({ assess: { data: undefined as unknown } }));

vi.mock("@/lib/api", async () => {
  const actual = await vi.importActual<typeof import("@/lib/api")>("@/lib/api");
  return {
    ...actual,
    useGetBusinessSuspense: () => ({
      data: {
        id: "biz-1", name: "Acme Co", description: "d", business_vibes: "", industry_alignment: "",
        industry_id: null, created_at: "2024-01-01T00:00:00Z", updated_at: "2024-01-01T00:00:00Z",
      },
    }),
    useListIndustriesSuspense: () => ({ data: [] }),
    useGetExplorerVersionsSuspense: () => ({ data: [] }),
    useListVersions: () => ({ data: { data: [] }, isSuccess: true }),
    useListSectorsSuspense: () => ({ data: [] }),
    useGetAssessConfig: () => ({ data: assess.data }),
  };
});

vi.mock("@/components/explorer/breadcrumb-context", () => ({ useBreadcrumbs: () => {} }));

afterEach(() => {
  assess.data = undefined;
});

async function renderExplorer() {
  const { Route: ExplorerRoute } = await import("@/routes/_sidebar/businesses.$businessId.explorer");
  const rootRoute = createRootRoute({ component: () => <Outlet /> });
  const sidebarRoute = createRoute({ getParentRoute: () => rootRoute, id: "/_sidebar", component: () => <Outlet /> });
  const explorer = createRoute({
    getParentRoute: () => sidebarRoute,
    path: "/businesses/$businessId/explorer",
    component: ExplorerRoute.options.component as any,
  });
  const router = createRouter({
    routeTree: rootRoute.addChildren([sidebarRoute.addChildren([explorer])]),
    history: createMemoryHistory({ initialEntries: ["/businesses/biz-1/explorer"] }),
    defaultPendingMs: 0,
  });
  const qc = new QueryClient({ defaultOptions: { queries: { retry: false } } });
  render(
    <QueryClientProvider client={qc}>
      <Suspense fallback={null}>
        <RouterProvider router={router} />
      </Suspense>
    </QueryClientProvider>,
  );
  await screen.findByRole("heading", { name: "Acme Co" });
}

warmImports(() => import("@/routes/_sidebar/businesses.$businessId.explorer"));

describe("Explorer Assessments link", () => {
  it("is hidden while the assessment config is loading", async () => {
    await renderExplorer();
    expect(screen.queryByRole("link", { name: /^assessments$/i })).toBeNull();
  });

  it("is hidden when installed but not ready", async () => {
    assess.data = { data: { installed: true, ready: false } };
    await renderExplorer();
    expect(screen.queryByRole("link", { name: /^assessments$/i })).toBeNull();
  });

  it("shows when ready", async () => {
    assess.data = { data: { installed: true, ready: true } };
    await renderExplorer();
    expect(screen.getByRole("link", { name: /^assessments$/i })).toHaveAttribute(
      "href",
      "/businesses/biz-1/assessments",
    );
  });
});
