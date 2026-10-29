/**
 * New Run page: Start Run waits for queued selection writes.
 *
 * The run form lists the selected inputs from its own query and sends those
 * ids; the server compiles exactly them. While selection writes (and the list
 * refetch after the last one) are still in flight that list is not the
 * selection the user made, so Start Run is disabled and a submit is refused.
 */
import { beforeEach, describe, expect, it, vi } from "vitest";
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
import { vibeInputSelectionMutationKey } from "@/components/vibe-inputs/use-vibe-input-selection";

const MVM_V2 = {
  id: "v-2-mvm",
  version: 2,
  scope: "mvm",
  status: "completed",
  is_base: false,
  confidence_score: null,
  vibe_instructions: "",
  created_at: "2026-04-21T12:00:00Z",
  uc_catalog: "utility_cat",
  deployment_status: "deployed",
};

const VIBE_INPUTS = [
  {
    id: "vi-1",
    text: "Add a due date to invoices",
    priority: "high",
    anchor: { level: "element", domain_name: "meter_to_cash", path: ["Domain: meter_to_cash"] },
    consumed: false,
    selected_for_run: true,
    status: "active",
  },
  {
    id: "vi-2",
    text: "Split billing accounts",
    priority: "medium",
    anchor: { level: "element", domain_name: "billing", path: ["Domain: billing"] },
    consumed: false,
    selected_for_run: true,
    status: "active",
  },
  {
    id: "vi-3",
    text: "Use snake_case everywhere",
    priority: "low",
    anchor: { level: "model_wide", path: [] },
    consumed: false,
    selected_for_run: true,
    status: "active",
  },
];

const MODEL_SUMMARY = {
  name: "Utility",
  version: 2,
  domains: [
    { id: "d-1", name: "meter_to_cash" },
    { id: "d-2", name: "billing" },
    { id: "", name: "deleted_placeholder" },
  ],
};


const createRunMock = vi.fn(async (..._args: unknown[]) => ({ data: { id: "run-new" } }));
const validateRunMock = vi.fn(async (..._args: unknown[]) => ({
  data: { blockers: [], warnings: [] },
}));
const compileMock = vi.fn(async (..._args: unknown[]) => ({ data: { markdown: "", agent_markdown: "", blocks: [], included_input_ids: ["vi-1", "vi-2", "vi-3"], excluded_input_ids: [], excluded_reasons: {} } }));

vi.mock("@/lib/api", async () => {
  const actual = await vi.importActual<typeof import("@/lib/api")>("@/lib/api");
  return {
    ...actual,
    // No base-model pre-fill: the form keeps its own values.
    useGetRunDefaults: () => ({ data: undefined, isLoading: false, isError: false }),
    useGetBusinessSuspense: () => ({
      data: { id: "biz-1", name: "Acme Utility", description: "Utility blurb." },
    }),
    useListVersionsSuspense: () => ({ data: [MVM_V2] }),
    useListVibeInputs: (opts: any) => ({
      data: opts?.query?.select ? opts.query.select({ data: VIBE_INPUTS }) : VIBE_INPUTS,
    }),
    useGetCatalogSchemaWarning: () => ({ data: undefined }),
    useGetModelSummary: (opts: any) => ({
      data:
        opts?.query?.enabled === false
          ? undefined
          : opts?.query?.select
            ? opts.query.select({ data: MODEL_SUMMARY })
            : MODEL_SUMMARY,
    }),
    compileVibeInputs: (...args: unknown[]) => compileMock(...args),
    createRun: (...args: unknown[]) => createRunMock(...args),
    validateRun: (...args: unknown[]) => validateRunMock(...args),
  };
});

vi.mock("@/components/ui/markdown-toolbar", () => ({ MarkdownToolbar: () => null }));
vi.mock("@/components/runs/deployment-catalog-picker", () => ({
  DeploymentCatalogPicker: ({ value, onChange }: any) => (
    <input data-testid="catalog-picker" value={value} onChange={(e) => onChange(e.target.value)} />
  ),
}));

async function renderRunsNew(searchString: string, qc: QueryClient) {
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
  const inputsRoute = createRoute({
    getParentRoute: () => rootRoute,
    path: "/businesses/$businessId/model/$version/$scope/inputs",
    component: () => <div data-testid="inputs-stub" />,
  });
  const runsRoute = createRoute({
    getParentRoute: () => rootRoute,
    path: "/businesses/$businessId/runs",
    component: () => <div data-testid="runs-stub" />,
  });
  const router = createRouter({
    routeTree: rootRoute.addChildren([
      sidebarRoute.addChildren([runsNewClone]),
      inputsRoute,
      runsRoute,
    ]),
    history: createMemoryHistory({
      initialEntries: [`/businesses/biz-1/runs/new${searchString}`],
    }),
    defaultPendingMs: 0,
  });
  return render(
    <QueryClientProvider client={qc}>
      <Suspense fallback={<div data-testid="suspense-fallback" />}>
        <RouterProvider router={router} />
      </Suspense>
    </QueryClientProvider>,
  );
}


const SEARCH = "?operationType=vibe-iterate&sourceVersion=2&sourceScope=mvm";

function startSelectionWrite(qc: QueryClient) {
  let finish: () => void = () => {};
  const done = qc
    .getMutationCache()
    .build(qc, {
      mutationKey: vibeInputSelectionMutationKey("biz-1"),
      mutationFn: () => new Promise<void>((r) => (finish = r)),
    })
    .execute(undefined);
  return async () => {
    finish();
    await done;
  };
}

const newQc = () =>
  new QueryClient({
    defaultOptions: { queries: { retry: false, staleTime: 30_000 }, mutations: { retry: false } },
  });

warmImports(() => import("@/routes/_sidebar/businesses.$businessId.runs.new"));

describe("New Run page: selection writes still queued", () => {
  beforeEach(() => {
    createRunMock.mockClear();
  });

  it("disables Start Run, refuses a submit, and launches with the settled list afterwards", async () => {
    const qc = newQc();
    const settle = startSelectionWrite(qc);
    await renderRunsNew(SEARCH, qc);
    await waitFor(() => expect(screen.getByTestId("vibe-scope-control")).toBeInTheDocument());

    const start = screen.getByRole("button", { name: /^Start Run$/i });
    await waitFor(() => expect(start).toBeDisabled());
    expect(screen.getByTestId("selection-saving")).toHaveTextContent(
      "Saving your selection\u2026 try again in a moment",
    );

    fireEvent.submit(start.closest("form")!);
    expect(screen.queryByRole("button", { name: /^Launch$/i })).toBeNull();
    expect(createRunMock).not.toHaveBeenCalled();

    await act(async () => settle());
    await waitFor(() => expect(start).not.toBeDisabled());
    expect(screen.queryByTestId("selection-saving")).toBeNull();

    await act(async () => fireEvent.click(start));
    await waitFor(() => expect(screen.queryByRole("button", { name: /^Launch$/i })).not.toBeNull());
    await act(async () => fireEvent.click(screen.getByRole("button", { name: /^Launch$/i })));
    await waitFor(() => expect(createRunMock).toHaveBeenCalledTimes(1));
    const body = (createRunMock.mock.calls[0] as unknown[])[1] as Record<string, unknown>;
    expect(body.input_ids).toEqual(["vi-1", "vi-2", "vi-3"]);
  });

  it("does not wait for a write of another business", async () => {
    const qc = newQc();
    let finish: () => void = () => {};
    void qc
      .getMutationCache()
      .build(qc, {
        mutationKey: vibeInputSelectionMutationKey("biz-2"),
        mutationFn: () => new Promise<void>((r) => (finish = r)),
      })
      .execute(undefined);
    await renderRunsNew(SEARCH, qc);
    await waitFor(() => expect(screen.getByTestId("vibe-scope-control")).toBeInTheDocument());
    await waitFor(() => expect(screen.getByRole("button", { name: /^Start Run$/i })).not.toBeDisabled());
    finish();
  });
});
