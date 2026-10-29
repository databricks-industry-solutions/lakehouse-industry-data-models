/**
 * Runs/new route — catalog schema warning banner.
 *
 * When useGetCatalogSchemaWarning returns schema_count > 0 and the run is one
 * where the agent tears down this business's schemas at its start (a Vibe
 * Modeling Full Run, or Vibe ECM + MVM), an amber
 * data-testid="catalog-schema-warning" banner must be visible and say that
 * only this business's schemas go. A Dry Run, which drops nothing, shows no
 * banner. When schema_count === 0 (or the query is loading/disabled), the
 * banner is absent.
 */
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";
import { warmImports } from "./helpers/warm-imports";
import { render, screen, waitFor } from "@testing-library/react";
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

vi.mock("sonner", () => ({
  toast: { error: vi.fn(), success: vi.fn(), warning: vi.fn(), info: vi.fn() },
}));

let catalogSchemaCount = 0;

const ECM_WITH_CATALOG = {
  id: "v-1-ecm",
  version: 1,
  scope: "ecm",
  status: "completed",
  is_base: true,
  confidence_score: null,
  vibe_instructions: "",
  created_at: "2026-04-20T12:00:00Z",
  uc_catalog: "my_catalog",
  deployment_status: "deployed",
};

const VERSION_WITH_CATALOG = {
  id: "v-1-mvm",
  version: 1,
  scope: "mvm",
  status: "completed",
  is_base: true,
  confidence_score: null,
  vibe_instructions: "",
  created_at: "2026-04-20T12:01:00Z",
  uc_catalog: "my_catalog",
  deployment_status: "deployed",
};

vi.mock("@/lib/api", async () => {
  const actual = await vi.importActual<typeof import("@/lib/api")>("@/lib/api");
  return {
    ...actual,
    // No base-model pre-fill: the form keeps its own values.
    useGetRunDefaults: () => ({ data: undefined, isLoading: false, isError: false }),
    useGetBusinessSuspense: () => ({
      data: { id: "biz-1", name: "Acme Corp", description: "An example business" },
    }),
    useListVersionsSuspense: () => ({ data: [VERSION_WITH_CATALOG, ECM_WITH_CATALOG] }),
    useListVibeInputs: () => ({ data: [] }),
    validateRun: async () => ({ data: { blockers: [], warnings: [] } }),
    createRun: vi.fn(),
    useGetCatalogSchemaWarning: ({ params }: { params: { catalog_name: string } }) => ({
      data:
        params.catalog_name
          ? { catalog: params.catalog_name, schema_count: catalogSchemaCount, schemas: [] }
          : undefined,
    }),
  };
});

vi.mock("@/components/ui/markdown-toolbar", () => ({ MarkdownToolbar: () => null }));
vi.mock("@/components/runs/deployment-catalog-picker", () => ({
  DeploymentCatalogPicker: ({ value, onChange }: { value: string; onChange: (v: string) => void }) => (
    <input
      data-testid="catalog-picker"
      value={value}
      onChange={(e) => onChange(e.target.value)}
    />
  ),
}));

beforeEach(() => {
  catalogSchemaCount = 0;
});

afterEach(() => vi.restoreAllMocks());

async function renderRunsNew(search = "") {
  const { Route: RunsNewRoute } = await import(
    "@/routes/_sidebar/businesses.$businessId.runs.new"
  );
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
  const runsListRoute = createRoute({
    getParentRoute: () => rootRoute,
    path: "/businesses/$businessId/runs",
    component: () => <div data-testid="runs-stub" />,
  });
  const explorerRoute = createRoute({
    getParentRoute: () => rootRoute,
    path: "/businesses/$businessId/explorer",
    component: () => <div data-testid="explorer-stub" />,
  });
  const router = createRouter({
    routeTree: rootRoute.addChildren([
      sidebarRoute.addChildren([runsNewClone]),
      runsListRoute,
      explorerRoute,
    ]),
    history: createMemoryHistory({
      initialEntries: [`/businesses/biz-1/runs/new${search}`],
    }),
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

warmImports(() => import("@/routes/_sidebar/businesses.$businessId.runs.new"));

describe("catalog schema warning banner", () => {
  it("renders the amber warning on a Vibe Modeling Full Run when schema_count > 0", async () => {
    catalogSchemaCount = 3;

    await renderRunsNew("?operationType=vibe-iterate&runMode=full");

    await waitFor(() => {
      expect(screen.getByTestId("catalog-schema-warning")).toBeInTheDocument();
    });
    const text = screen.getByTestId("catalog-schema-warning").textContent ?? "";
    expect(text).toMatch(/contains 3 schemas/);
    expect(text).toMatch(/drops the ones this business owns/);
    expect(text).toMatch(/schemas of other businesses are left as they are/);
    expect(text).toMatch(/When the base is the installed latest version, it keeps them and replaces only the tables this run changes\./);
    expect(text).not.toMatch(/from prior deployments/);
  });

  it("shows nothing on the default Dry Run, which drops nothing", async () => {
    catalogSchemaCount = 3;

    await renderRunsNew("?operationType=vibe-iterate");

    await waitFor(() => {
      expect(screen.getByTestId("catalog-picker")).toHaveValue("my_catalog");
    });
    expect(screen.queryByTestId("catalog-schema-warning")).not.toBeInTheDocument();
  });

  it("renders the warning on Vibe ECM + MVM, whose shrink step tears down the schemas", async () => {
    catalogSchemaCount = 2;

    await renderRunsNew("?operationType=vibe-new-ecm-mvm");

    await waitFor(() => {
      expect(screen.getByTestId("catalog-schema-warning")).toBeInTheDocument();
    });
    const text = screen.getByTestId("catalog-schema-warning").textContent ?? "";
    expect(text).toMatch(/contains 2 schemas\. The MVM step of this run drops the schemas this business owns there, including the ECM the first step just deployed;/);
    expect(text).toMatch(/schemas of other businesses are left as they are\./);
    expect(text).not.toMatch(/keeps them/);
  });

  it("does not render the banner when schema_count === 0", async () => {
    catalogSchemaCount = 0;

    await renderRunsNew("?operationType=vibe-iterate&runMode=full");

    await waitFor(() => {
      expect(screen.getByTestId("catalog-picker")).toHaveValue("my_catalog");
    });
    expect(screen.queryByTestId("catalog-schema-warning")).not.toBeInTheDocument();
  });

  it("uses singular 'schema' when count is 1", async () => {
    catalogSchemaCount = 1;

    await renderRunsNew("?operationType=vibe-iterate&runMode=full");

    await waitFor(() => {
      expect(screen.getByTestId("catalog-schema-warning")).toBeInTheDocument();
    });
    expect(screen.getByTestId("catalog-schema-warning").textContent).toMatch(/contains 1 schema\./);
  });
});
