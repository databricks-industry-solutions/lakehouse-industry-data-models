/**
 * Runs/new — `sourceVersion` + `sourceScope` URL preselect.
 *
 * the model-versioning work: linking from elsewhere (e.g. the model version page) into
 * the New Run form passes `sourceVersion` and `sourceScope` so the base
 * version dropdown lands on the (version, scope) the user came from.
 *
 * Defaults to `mvm` when only `sourceVersion` is set — MVM is the
 * deployable scope and the most common iterate target.
 *
 * The route component reads `useSearch` from the TanStack Router context,
 * so the tests have to mount the real route in a memory router rather
 * than rendering the component standalone.
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

// The route assumes versions are sorted desc by version (`latestVersion =
// versions[0]`). Mirror that wire shape exactly.
const COMPLETED_VERSIONS = [
  {
    id: "v-2-mvm",
    version: 2,
    scope: "mvm",
    status: "completed",
    is_base: false,
    confidence_score: null,
    vibe_instructions: "Add SCD-2",
    created_at: "2026-04-21T12:00:00Z",
    uc_catalog: "vibe_modeling",
    deployment_status: "deployed",
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
  {
    id: "v-1-ecm",
    version: 1,
    scope: "ecm",
    status: "completed",
    is_base: true,
    confidence_score: null,
    vibe_instructions: "",
    created_at: "2026-04-20T12:00:00Z",
    uc_catalog: "vibe_modeling",
    deployment_status: "draft",
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

async function renderRunsNew(searchString: string) {
  // Lazy import so the vi.mock above is wired before the route module is
  // evaluated. The route registers a `from: "/_sidebar/runs/new"` ID — we
  // build a router with that exact ID so `useSearch({ from: ... })`
  // resolves cleanly.
  const { Route: RunsNewRoute } = await import("@/routes/_sidebar/businesses.$businessId.runs.new");
  const rootRoute = createRootRoute({ component: () => <Outlet /> });
  const sidebarRoute = createRoute({
    getParentRoute: () => rootRoute,
    id: "/_sidebar",
    component: () => <Outlet />,
  });
  // Re-anchor the file route under our memory root so the path is
  // `/runs/new` and the registered ID matches the route file's expectation.
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

/** Read the *currently selected* value from the radix-shadow `<select>`
 *  the form mirrors. Returns the label of the selected option, which
 *  matches the trigger's display label. Looks up the second `<select>`
 *  (the first is the Operation Type dropdown). */
function readBaseVersionTrigger(): string {
  const selects = Array.from(document.querySelectorAll("select"));
  // Order in DOM: Operation Type, Namespace Style, Base Version. The
  // Base Version select shows v{N} {SCOPE} labels.
  const baseVersionSelect = selects.find((s) =>
    Array.from(s.options).some((o) => /v\d+\s+(ECM|MVM)/i.test(o.textContent || "")),
  );
  if (!baseVersionSelect) return "";
  const sel = baseVersionSelect.options[baseVersionSelect.selectedIndex];
  return sel?.textContent?.trim() ?? "";
}

warmImports(() => import("@/routes/_sidebar/businesses.$businessId.runs.new"));

describe("Runs/new — sourceVersion + sourceScope URL preselect", () => {
  it("renders scope-suffixed labels in the base-version dropdown", async () => {
    await renderRunsNew("?businessId=biz-1&operationType=vibe-iterate");

    // Latest first → v2 MVM is the default selection. The `(vibed)`
    // suffix is appended when the version has vibe_instructions, so
    // assert with a starts-with anchor.
    await waitFor(() => {
      expect(readBaseVersionTrigger()).toMatch(/^v2 MVM\b/);
    });
  });

  it("preselects the ECM v1 option when sourceVersion=1 + sourceScope=ecm", async () => {
    await renderRunsNew(
      "?businessId=biz-1&operationType=vibe-iterate&sourceVersion=1&sourceScope=ecm",
    );

    await waitFor(() => {
      expect(readBaseVersionTrigger()).toMatch(/^v1 ECM\b/);
    });
  });

  it("defaults to MVM when sourceScope is omitted", async () => {
    await renderRunsNew(
      "?businessId=biz-1&operationType=vibe-iterate&sourceVersion=1",
    );

    await waitFor(() => {
      expect(readBaseVersionTrigger()).toMatch(/^v1 MVM\b/);
    });
  });
});
