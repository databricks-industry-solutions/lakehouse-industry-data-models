/**
 * Versions list (explorer page) — `(version, scope)` row coverage.
 *
 * the model-versioning work: a unified `new-base-model` run produces TWO ModelVersion rows
 * sharing the same `version` int but differing in `scope` (ECM + MVM).
 * The explorer page must render BOTH rows, surface a scope badge on each,
 * and link to the new `/businesses/{id}/model/{version}/{scope}` URL.
 *
 * Sort order: version desc, scope asc — keeps siblings adjacent.
 *
 * The explorer route component reads `Route.useParams()` for the
 * `businessId`, which only resolves inside an actual router. Mount the
 * real route under a memory router rather than rendering the component
 * standalone.
 */
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";
import { warmImports } from "./helpers/warm-imports";
import { render, screen, within } from "@testing-library/react";
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

let businessHook: () => unknown = () => ({
  data: { id: "biz-1", name: "Acme Corp" },
});
let versionsHook: () => unknown = () => ({ data: [] });

vi.mock("@/lib/api", async () => {
  const actual = await vi.importActual<typeof import("@/lib/api")>("@/lib/api");
  return {
    ...actual,
    useGetBusinessSuspense: () => businessHook(),
    useGetExplorerVersionsSuspense: () => versionsHook(),
    // The explorer joins the lifecycle columns from the versions list and
    // lists unfinished metamodel cleanups.
    useListVersionsSuspense: () => versionsHook(),
    useListMetamodelCleanups: () => ({ data: { data: [] } }),
    useListIndustriesSuspense: () => ({ data: [] }),
    useListSectorsSuspense: () => ({ data: [] }),
  };
});

vi.mock("@/components/import/import-dialog", () => ({
  ImportModelDialog: ({ trigger }: { trigger: React.ReactNode }) => <>{trigger}</>,
}));

beforeEach(() => {
  businessHook = () => ({ data: { id: "biz-1", name: "Acme Corp" } });
});

afterEach(() => {
  vi.restoreAllMocks();
});

function makeVersion(over: any = {}) {
  return {
    id: over.id ?? "v-stub",
    version: over.version ?? 1,
    scope: over.scope ?? "mvm",
    status: over.status ?? "completed",
    is_base: over.is_base ?? true,
    confidence_score: null,
    vibe_instructions: "",
    created_at: "2026-04-20T12:00:00Z",
    uc_catalog: "vibe_modeling",
    deployment_status: "draft",
    ...over,
  };
}

async function renderExplorer(versions: unknown[]) {
  versionsHook = () => ({ data: versions });
  const { Route: ExplorerRoute } = await import(
    "@/routes/_sidebar/businesses.$businessId.explorer"
  );
  const rootRoute = createRootRoute({ component: () => <Outlet /> });
  const sidebarRoute = createRoute({
    getParentRoute: () => rootRoute,
    id: "/_sidebar",
    component: () => <Outlet />,
  });
  const businessesRoute = createRoute({
    getParentRoute: () => sidebarRoute,
    path: "/businesses",
    component: () => <Outlet />,
  });
  const businessRoute = createRoute({
    getParentRoute: () => businessesRoute,
    path: "/$businessId",
    component: () => <Outlet />,
  });
  const explorerClone = createRoute({
    getParentRoute: () => businessRoute,
    path: "/explorer",
    component: ExplorerRoute.options.component as any,
  });
  // Stub link targets so navigation assertions don't 404.
  const modelStub = createRoute({
    getParentRoute: () => rootRoute,
    path: "/businesses/$businessId/model/$version/$scope",
    component: () => <div data-testid="model-stub" />,
  });
  const router = createRouter({
    routeTree: rootRoute.addChildren([
      sidebarRoute.addChildren([
        businessesRoute.addChildren([businessRoute.addChildren([explorerClone])]),
      ]),
      modelStub,
    ]),
    history: createMemoryHistory({ initialEntries: ["/businesses/biz-1/explorer"] }),
    defaultPendingMs: 0,
  });
  const qc = new QueryClient({
    defaultOptions: {
      queries: { retry: false, staleTime: 30_000 },
      mutations: { retry: false },
    },
  });
  return render(
    <QueryClientProvider client={qc}>
      <Suspense fallback={<div data-testid="suspense-fallback" />}>
        <RouterProvider router={router} />
      </Suspense>
    </QueryClientProvider>,
  );
}

warmImports(() => import("@/routes/_sidebar/businesses.$businessId.explorer"));

describe("Versions list — lifecycle badges", () => {
  it("labels drafts, replaced versions and promoted drafts", async () => {
    await renderExplorer([
      makeVersion({ id: "v-3", version: 3, scope: "ecm", dry_run: true, promoted_at: "2026-10-22T00:00:00Z" }),
      makeVersion({ id: "v-4", version: 4, scope: "ecm", status: "draft", dry_run: true, draft_state: "older_base" }),
      makeVersion({ id: "v-5", version: 5, scope: "ecm", status: "superseded", replaced_at: "2026-10-22T00:00:00Z", replaced_by_version_id: "v-3" }),
      makeVersion({ id: "v-6", version: 6, scope: "ecm", status: "draft", dry_run: true, draft_state: "ready" }),
    ]);
    const list = await screen.findByTestId("versions-list");
    expect(within(within(list).getByTestId("version-row-6-ecm")).getByText("Dry Run")).toBeInTheDocument();
    expect(within(within(list).getByTestId("version-row-4-ecm")).getByText("Dry Run (older base)")).toBeInTheDocument();
    expect(within(within(list).getByTestId("version-row-5-ecm")).getByText("Replaced by v3")).toBeInTheDocument();
    expect(within(within(list).getByTestId("version-row-3-ecm")).getByText("from Dry Run")).toBeInTheDocument();
  });
});

describe("Versions list — (version, scope) rows", () => {
  it("renders TWO rows (one ECM + one MVM) at the same version number", async () => {
    await renderExplorer([
      makeVersion({ id: "v-1-ecm", version: 1, scope: "ecm" }),
      makeVersion({ id: "v-1-mvm", version: 1, scope: "mvm" }),
    ]);

    const list = await screen.findByTestId("versions-list");
    expect(within(list).getByTestId("version-row-1-ecm")).toBeInTheDocument();
    expect(within(list).getByTestId("version-row-1-mvm")).toBeInTheDocument();

    // Scope badges (one per row).
    expect(within(list).getByText("ECM")).toBeInTheDocument();
    expect(within(list).getByText("MVM")).toBeInTheDocument();

    // Each row links to the new `/model/{version}/{scope}` URL.
    const ecmLink = within(list).getByTestId("version-row-1-ecm") as HTMLAnchorElement;
    const mvmLink = within(list).getByTestId("version-row-1-mvm") as HTMLAnchorElement;
    expect(ecmLink.getAttribute("href")).toBe(
      "/businesses/biz-1/model/1/ecm?tab=overview",
    );
    expect(mvmLink.getAttribute("href")).toBe(
      "/businesses/biz-1/model/1/mvm?tab=overview",
    );
  });

  it("orders rows newest-first, with ECM and MVM siblings adjacent", async () => {
    await renderExplorer([
      makeVersion({ id: "v-1-mvm", version: 1, scope: "mvm" }),
      makeVersion({ id: "v-2-mvm", version: 2, scope: "mvm" }),
      makeVersion({ id: "v-1-ecm", version: 1, scope: "ecm" }),
      makeVersion({ id: "v-2-ecm", version: 2, scope: "ecm" }),
    ]);
    const list = await screen.findByTestId("versions-list");
    const rowIds = Array.from(
      list.querySelectorAll("[data-testid^='version-row-']"),
    ).map((el) => el.getAttribute("data-testid"));
    // Newest version first; within a version, ECM before MVM (ecm < mvm
    // alphabetically) so the sibling pair stays adjacent.
    expect(rowIds).toEqual([
      "version-row-2-ecm",
      "version-row-2-mvm",
      "version-row-1-ecm",
      "version-row-1-mvm",
    ]);
  });
});
