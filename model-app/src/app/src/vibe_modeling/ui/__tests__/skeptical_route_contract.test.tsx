/**
 * Skeptical tests — frontend route reshape (Stream D).
 *
 * Contract clauses tested:
 * - Route file structure: `_sidebar/businesses.$businessId.model.$version.$scope.*.tsx`
 *   exists (so the URL `/businesses/{id}/model/{int}/{scope}` resolves under
 *   TanStack Router's file-based router).
 * - `runs.new` accepts `?sourceVersion=N&sourceScope=ecm|mvm` URL params and
 *   pre-selects the matching base-version dropdown entry.
 * - When only `sourceVersion` is passed, the dropdown defaults to MVM.
 *
 * These mirror the spec's "frontend" gates. We use a memory router rather
 * than the real file-based router so the tests stay deterministic and
 * decoupled from build-time route generation.
 */
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";
import { warmImports } from "./helpers/warm-imports";
import { render, waitFor } from "@testing-library/react";
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
  data: { id: "biz-1", name: "Acme Corp", description: "An example" },
});
let versionsHook: () => unknown = () => ({ data: [] });

vi.mock("@/lib/api", async () => {
  const actual = await vi.importActual<typeof import("@/lib/api")>("@/lib/api");
  return {
    ...actual,
    // No base-model pre-fill: the form keeps its own values.
    useGetRunDefaults: () => ({ data: undefined, isLoading: false, isError: false }),
    useGetBusinessSuspense: () => businessHook(),
    useListVersionsSuspense: () => versionsHook(),
    createRun: vi.fn(),
    validateRun: vi.fn(async () => ({
      data: { blockers: [], warnings: [] },
    })),
  };
});

vi.mock("@/components/ui/markdown-toolbar", () => ({
  MarkdownToolbar: () => null,
}));
vi.mock("@/components/runs/deployment-catalog-picker", () => ({
  DeploymentCatalogPicker: ({ value }: { value: string }) => (
    <input data-testid="catalog-picker" value={value} readOnly />
  ),
}));

const COMPLETED_VERSIONS = [
  {
    id: "v-2-mvm",
    version: 2,
    scope: "mvm",
    status: "completed",
    is_base: false,
    confidence_score: null,
    vibe_instructions: "",
    created_at: "2026-04-21T12:00:00Z",
    uc_catalog: "vibe_modeling",
    deployment_status: "deployed",
  },
  {
    id: "v-2-ecm",
    version: 2,
    scope: "ecm",
    status: "completed",
    is_base: false,
    confidence_score: null,
    vibe_instructions: "",
    created_at: "2026-04-21T12:00:00Z",
    uc_catalog: "vibe_modeling",
    deployment_status: "draft",
  },
  {
    id: "v-1-mvm",
    version: 1,
    scope: "mvm",
    status: "completed",
    is_base: true,
    confidence_score: null,
    vibe_instructions: "",
    created_at: "2026-04-20T12:01:00Z",
    uc_catalog: "vibe_modeling",
    deployment_status: "deployed",
  },
];

beforeEach(() => {
  businessHook = () => ({
    data: { id: "biz-1", name: "Acme Corp", description: "An example" },
  });
  versionsHook = () => ({ data: COMPLETED_VERSIONS });
});

afterEach(() => {
  vi.restoreAllMocks();
});

warmImports(() => import("@/routes/_sidebar/businesses.$businessId.runs.new"));

async function renderRunsNew(searchString: string) {
  const { Route: RunsNewRoute } = await import("@/routes/_sidebar/businesses.$businessId.runs.new");
  const rootRoute = createRootRoute({ component: () => <Outlet /> });
  const sidebarRoute = createRoute({
    getParentRoute: () => rootRoute,
    id: "/_sidebar",
    component: () => <Outlet />,
  });
  const runsNewClone = createRoute({
    getParentRoute: () => sidebarRoute,
    path: "/businesses/$businessId/runs/new",
    component: RunsNewRoute.options.component as any,
    validateSearch: RunsNewRoute.options.validateSearch as any,
  });
  const businessExplorerRoute = createRoute({
    getParentRoute: () => rootRoute,
    path: "/businesses/$businessId/explorer",
    component: () => <div data-testid="explorer-stub" />,
  });
  const router = createRouter({
    routeTree: rootRoute.addChildren([
      sidebarRoute.addChildren([runsNewClone]),
      businessExplorerRoute,
    ]),
    history: createMemoryHistory({ initialEntries: [`/businesses/biz-1/runs/new${searchString}`] }),
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

function readBaseVersionTrigger(): string {
  const selects = Array.from(document.querySelectorAll("select"));
  const baseVersionSelect = selects.find((s) =>
    Array.from(s.options).some((o) => /v\d+\s+(ECM|MVM)/i.test(o.textContent || "")),
  );
  if (!baseVersionSelect) return "";
  const sel = baseVersionSelect.options[baseVersionSelect.selectedIndex];
  return sel?.textContent?.trim() ?? "";
}

describe("Skeptical — frontend route file structure (Stream D)", () => {
  it("can import the model-version $scope route file", async () => {
    // Direct import — fails fast if the file isn't there or its export shape
    // changed. Asserts the file path the contract names.
    const mod = await import(
      "@/routes/_sidebar/businesses.$businessId.model.$version.$scope.index"
    );
    expect(mod).toBeDefined();
    // The route file must export at least one of: Route (file-route handle),
    // ModelVersionPage (the page component the dev tests import).
    expect("Route" in mod || "ModelVersionPage" in mod).toBe(true);
  }, 30_000);

  it("can import the domain-level $scope route file", async () => {
    const mod = await import(
      "@/routes/_sidebar/businesses.$businessId.model.$version.$scope.$domainName"
    );
    expect(mod).toBeDefined();
  }, 30_000);
});

describe("Skeptical — runs.new ?sourceVersion + ?sourceScope contract (Stream D)", () => {
  it("preselects ECM v=2 when ?sourceVersion=2&sourceScope=ecm", async () => {
    await renderRunsNew(
      "?businessId=biz-1&operationType=vibe-iterate&sourceVersion=2&sourceScope=ecm",
    );
    await waitFor(() => {
      expect(readBaseVersionTrigger()).toMatch(/^v2 ECM\b/);
    });
  });

  it("defaults to MVM when only ?sourceVersion is set", async () => {
    await renderRunsNew(
      "?businessId=biz-1&operationType=vibe-iterate&sourceVersion=2",
    );
    await waitFor(() => {
      expect(readBaseVersionTrigger()).toMatch(/^v2 MVM\b/);
    });
  });

  it("falls back to v1 MVM when ?sourceVersion=1 with no scope", async () => {
    await renderRunsNew(
      "?businessId=biz-1&operationType=vibe-iterate&sourceVersion=1",
    );
    await waitFor(() => {
      expect(readBaseVersionTrigger()).toMatch(/^v1 MVM\b/);
    });
  });
});
