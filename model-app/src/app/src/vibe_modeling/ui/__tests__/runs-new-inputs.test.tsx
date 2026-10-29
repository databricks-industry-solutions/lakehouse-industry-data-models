/**
 * New Run page — Vibe Inputs integration.
 *
 * A vibe run dispatches `RunIn.input_ids` = the active, anchored, non-consumed
 * inputs on the selected base version that the user marked `selected_for_run`
 * on the compose surface. The page surfaces an "Edit inputs →" entry point, a
 * read-only compiled preview of the selection, and an empty-state CTA back to
 * the compose surface when nothing is selected. The next-vibes/feedback sidebar
 * is gone. First-model (new-base) description mode is unaffected: `input_ids`
 * is empty there.
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

const ECM_VERSION = {
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
};

// vi-1 (selected, anchored) + vi-2 (selected, anchored) dispatch.
// vi-3 is anchored but NOT selected_for_run → excluded.
// vi-4 is selected but anchor-free → excluded.
let VIBE_INPUTS: unknown[] = [
  { id: "vi-1", text: "rule one", priority: "medium", anchor: { level: "model_wide", path: [] }, consumed: false, selected_for_run: true },
  {
    id: "vi-2",
    text: "rule two",
    priority: "high",
    anchor: { level: "element", domain_name: "Sales", path: ["Domain: Sales"] },
    consumed: false,
    selected_for_run: true,
  },
  { id: "vi-3", text: "rule three", priority: "low", anchor: { level: "model_wide", path: [] }, consumed: false, selected_for_run: false },
  { id: "vi-4", text: "orphan", priority: "low", anchor: null, consumed: false, selected_for_run: true },
];

const createRunMock = vi.fn(async () => ({ data: { id: "run-new" } }));
const validateRunMock = vi.fn(async () => ({ data: { blockers: [], warnings: [] } }));

vi.mock("@/lib/api", async () => {
  const actual = await vi.importActual<typeof import("@/lib/api")>("@/lib/api");
  return {
    ...actual,
    // No base-model pre-fill: the form keeps its own values.
    useGetRunDefaults: () => ({ data: undefined, isLoading: false, isError: false }),
    useGetBusinessSuspense: () => ({
      data: { id: "biz-1", name: "Acme Corp", description: "Retail blurb." },
    }),
    useListVersionsSuspense: () => ({ data: [ECM_VERSION] }),
    useListVibeInputs: (opts: any) => ({
      data: opts?.query?.select
        ? opts.query.select({ data: VIBE_INPUTS })
        : VIBE_INPUTS,
    }),
    createRun: (...args: unknown[]) => (createRunMock as any)(...args),
    validateRun: (...args: unknown[]) => (validateRunMock as any)(...args),
  };
});

vi.mock("@/components/ui/markdown-toolbar", () => ({ MarkdownToolbar: () => null }));
vi.mock("@/components/runs/deployment-catalog-picker", () => ({
  DeploymentCatalogPicker: ({ value, onChange }: any) => (
    <input data-testid="catalog-picker" value={value} onChange={(e) => onChange(e.target.value)} />
  ),
}));

async function renderRunsNew(searchString: string) {
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
  const router = createRouter({
    routeTree: rootRoute.addChildren([
      sidebarRoute.addChildren([runsNewClone]),
      inputsRoute,
    ]),
    history: createMemoryHistory({
      initialEntries: [`/businesses/biz-1/runs/new${searchString}`],
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

describe("New Run page — Vibe Inputs integration", () => {
  beforeEach(() => {
    VIBE_INPUTS = [
      { id: "vi-1", text: "rule one", priority: "medium", anchor: { level: "model_wide", path: [] }, consumed: false, selected_for_run: true },
      {
        id: "vi-2",
        text: "rule two",
        priority: "high",
        anchor: { level: "element", domain_name: "Sales", path: ["Domain: Sales"] },
        consumed: false,
        selected_for_run: true,
      },
      { id: "vi-3", text: "rule three", priority: "low", anchor: { level: "model_wide", path: [] }, consumed: false, selected_for_run: false },
      { id: "vi-4", text: "orphan", priority: "low", anchor: null, consumed: false, selected_for_run: true },
    ];
    createRunMock.mockClear();
    validateRunMock.mockClear();
  });
  afterEach(() => vi.restoreAllMocks());

  it("shows the selected-inputs summary + Edit inputs link for a vibe run", async () => {
    await renderRunsNew("?businessId=biz-1&operationType=vibe-new-ecm-mvm");
    await waitFor(() => {
      expect(screen.queryByTestId("vibe-inputs-summary")).not.toBeNull();
    });
    // Only vi-1 + vi-2 are selected_for_run AND anchored.
    expect(screen.getByTestId("vibe-inputs-summary")).toHaveTextContent(
      "2 vibe inputs selected",
    );
    expect(screen.getByRole("link", { name: /Edit inputs/ })).toBeInTheDocument();
  });

  it("renders the read-only compiled preview of the selected inputs, no sidebar", async () => {
    await renderRunsNew("?businessId=biz-1&operationType=vibe-new-ecm-mvm");
    await waitFor(() => {
      expect(screen.queryByText("Compiled instructions preview")).not.toBeNull();
    });
    // CompiledPreview renders the count of compiled (selected + anchored) inputs.
    expect(screen.getByTestId("compiled-preview-count")).toHaveTextContent(
      "2 selected",
    );
    // The next-vibes / feedback sidebar is removed for vibe runs.
    expect(screen.queryByTestId("feedback-tree-stub")).toBeNull();
    expect(screen.queryByTestId("next-vibes-stub")).toBeNull();
  });

  it("dispatches only the selected_for_run inputs in the createRun payload", async () => {
    await renderRunsNew("?businessId=biz-1&operationType=vibe-new-ecm-mvm");
    await waitFor(() => {
      expect(screen.queryByText("Compiled instructions preview")).not.toBeNull();
    });
    const startBtn = screen.getByRole("button", { name: /^Start Run$/i });
    await act(async () => fireEvent.click(startBtn));
    await waitFor(() => {
      expect(screen.queryByRole("button", { name: /^Launch$/i })).not.toBeNull();
    });
    await act(async () => fireEvent.click(screen.getByRole("button", { name: /^Launch$/i })));
    await waitFor(() => expect(createRunMock).toHaveBeenCalledTimes(1));
    const body = ((createRunMock.mock.calls[0] as unknown[])?.[1] ?? {}) as Record<string, unknown>;
    expect(Array.isArray(body.input_ids)).toBe(true);
    // vi-3 (not selected) and vi-4 (anchor-free) are excluded.
    expect(body.input_ids).toEqual(["vi-1", "vi-2"]);
    expect(body.next_vibe_ids).toEqual([]);
  });

  it("shows the empty-state CTA back to Compose when nothing is selected", async () => {
    VIBE_INPUTS = [
      { id: "vi-3", text: "rule three", priority: "low", anchor: { level: "model_wide", path: [] }, consumed: false, selected_for_run: false },
    ];
    await renderRunsNew("?businessId=biz-1&operationType=vibe-new-ecm-mvm");
    await waitFor(() => {
      expect(screen.queryByTestId("vibe-inputs-empty-state")).not.toBeNull();
    });
    expect(screen.getByTestId("vibe-inputs-empty-state")).toHaveTextContent(
      /No inputs selected/i,
    );
    expect(
      screen.getByRole("link", { name: /Choose inputs on the Compose surface/i }),
    ).toBeInTheDocument();
    const startBtn = screen.getByRole("button", { name: /^Start Run$/i }) as HTMLButtonElement;
    expect(startBtn.disabled).toBe(true);
  });
});
