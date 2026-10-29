/**
 * Runs/new live validation never shows a stale result.
 *
 * The debounced validate call is aborted when the form changes, and a
 * response that arrives after its request was aborted is dropped. So a
 * blocker for an old form value never reappears after the user fixed it,
 * even when the old response lands last.
 */
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";
import { warmImports } from "./helpers/warm-imports";
import { act, fireEvent, render, screen, waitFor } from "@testing-library/react";
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

type ValidateResult = { data: { blockers: unknown[]; warnings: unknown[] } };
type Deferred = {
  body: { catalog?: string };
  resolve: (r: ValidateResult) => void;
};

const calls: Deferred[] = [];
const validateRunMock = vi.fn(
  (_params: unknown, body: { catalog?: string }): Promise<ValidateResult> =>
    new Promise((resolve) => {
      calls.push({ body, resolve });
    }),
);

vi.mock("@/lib/api", async () => {
  const actual = await vi.importActual<typeof import("@/lib/api")>("@/lib/api");
  return {
    ...actual,
    // No base-model pre-fill: the form keeps its own values.
    useGetRunDefaults: () => ({ data: undefined, isLoading: false, isError: false }),
    useGetBusinessSuspense: () => ({
      data: { id: "biz-1", name: "Acme Corp", description: "An example business" },
    }),
    useListVersionsSuspense: () => ({ data: [] }),
    useListVibeInputs: () => ({ data: [] }),
    createRun: vi.fn(),
    validateRun: (...args: unknown[]) => (validateRunMock as any)(...args),
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

const BLOCKER = {
  data: {
    blockers: [
      { field_path: "catalog", step_index: 0, message: "Catalog bad_cat does not exist", severity: "blocker" },
    ],
    warnings: [],
  },
};
const CLEAN = { data: { blockers: [], warnings: [] } };

beforeEach(() => {
  calls.length = 0;
  validateRunMock.mockClear();
});

afterEach(() => vi.restoreAllMocks());

async function renderRunsNew() {
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
  const router = createRouter({
    routeTree: rootRoute.addChildren([sidebarRoute.addChildren([runsNewClone])]),
    history: createMemoryHistory({
      initialEntries: ["/businesses/biz-1/runs/new?businessId=biz-1&operationType=new base model"],
    }),
    defaultPendingMs: 0,
  });
  const qc = new QueryClient({
    defaultOptions: { queries: { retry: false, staleTime: 30_000 }, mutations: { retry: false } },
  });
  return render(
    <QueryClientProvider client={qc}>
      <Suspense fallback={<div data-testid="suspense-fallback" />}>
        <RouterProvider router={router} />
      </Suspense>
    </QueryClientProvider>,
  );
}

async function setCatalog(value: string) {
  const picker = await screen.findByTestId("catalog-picker");
  await act(async () => {
    fireEvent.change(picker, { target: { value } });
  });
  await waitFor(() => expect((picker as HTMLInputElement).value).toBe(value));
}

warmImports(() => import("@/routes/_sidebar/businesses.$businessId.runs.new"));

describe("Runs/new live validation (stale results)", () => {
  it("drops a late response for a form value the user already changed", async () => {
    await renderRunsNew();
    await setCatalog("bad_cat");
    await waitFor(() => expect(calls.some((c) => c.body.catalog === "bad_cat")).toBe(true));
    const stale = calls.find((c) => c.body.catalog === "bad_cat")!;

    await setCatalog("good_cat");
    await waitFor(() => expect(calls.some((c) => c.body.catalog === "good_cat")).toBe(true));
    const fresh = calls.find((c) => c.body.catalog === "good_cat")!;

    // The fixed value answers first, then the old request lands with a blocker.
    await act(async () => fresh.resolve(CLEAN));
    await act(async () => stale.resolve(BLOCKER));

    expect(screen.queryByTestId("validate-blockers")).toBeNull();
    expect(screen.queryByText(/Catalog bad_cat does not exist/)).toBeNull();
  });

  it("clears a shown blocker once the user fixes the field", async () => {
    await renderRunsNew();
    await setCatalog("bad_cat");
    await waitFor(() => expect(calls.some((c) => c.body.catalog === "bad_cat")).toBe(true));
    await act(async () => calls.find((c) => c.body.catalog === "bad_cat")!.resolve(BLOCKER));
    await waitFor(() => expect(screen.getByTestId("validate-blockers")).toBeInTheDocument());

    await setCatalog("good_cat");
    await waitFor(() => expect(calls.some((c) => c.body.catalog === "good_cat")).toBe(true));
    await act(async () => calls.find((c) => c.body.catalog === "good_cat")!.resolve(CLEAN));

    await waitFor(() => expect(screen.queryByTestId("validate-blockers")).toBeNull());
  });
});
