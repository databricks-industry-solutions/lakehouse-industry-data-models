/**
 * New Run form: "Run time budget (hours)" under Advanced Options.
 *
 *  - Prefilled from the Settings default and sent in both the validate and
 *    the create body as `runtime_budget_hours` (a number, outside the
 *    string-only conventions spread).
 *  - A change is sent as typed.
 *  - Out of the API's bounds (non-backend bounds in the fixture): an inline
 *    error tied to the input, Start Run disabled, and no validate request
 *    (create would 422 on that value, so validate == create holds).
 *  - Without a loaded agent config the field is absent and nothing is sent,
 *    so the server applies the Settings default.
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

let agentConfig: Record<string, unknown> | undefined;
const createRunMock = vi.fn(async () => ({ data: { id: "run-1" } }));
const validateRunMock = vi.fn(
  async (): Promise<{ data: { blockers: unknown[]; warnings: unknown[] } }> => ({
    data: { blockers: [], warnings: [] },
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
    useGetAgentConfig: () => ({ data: agentConfig }),
    createRun: (...args: unknown[]) => (createRunMock as any)(...args),
    validateRun: (...args: unknown[]) => (validateRunMock as any)(...args),
  };
});

vi.mock("@/components/ui/markdown-toolbar", () => ({ MarkdownToolbar: () => null }));
vi.mock("@/components/runs/deployment-catalog-picker", () => ({
  DeploymentCatalogPicker: ({ value, onChange }: { value: string; onChange: (v: string) => void }) => (
    <input data-testid="catalog-picker" value={value} onChange={(e) => onChange(e.target.value)} />
  ),
}));

const CONFIG = {
  notebook_path: "/nb",
  runtime_budget_hours: 7,
  runtime_budget_min_hours: 5,
  runtime_budget_max_hours: 30,
};

beforeEach(() => {
  agentConfig = CONFIG;
  createRunMock.mockClear();
  validateRunMock.mockClear();
});

afterEach(() => vi.restoreAllMocks());

async function renderRunsNew() {
  const { Route: RunsNewRoute } = await import("@/routes/_sidebar/businesses.$businessId.runs.new");
  const rootRoute = createRootRoute({ component: () => <Outlet /> });
  const sidebarRoute = createRoute({ getParentRoute: () => rootRoute, id: "/_sidebar", component: () => <Outlet /> });
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
    routeTree: rootRoute.addChildren([sidebarRoute.addChildren([runsNewClone]), runsListRoute, explorerRoute]),
    history: createMemoryHistory({
      initialEntries: ["/businesses/biz-1/runs/new?businessId=biz-1&operationType=new base model"],
    }),
    defaultPendingMs: 0,
  });
  const qc = new QueryClient({ defaultOptions: { queries: { retry: false, staleTime: 30_000 } } });
  return render(
    <QueryClientProvider client={qc}>
      <Suspense fallback={<div data-testid="suspense-fallback" />}>
        <RouterProvider router={router} />
      </Suspense>
    </QueryClientProvider>,
  );
}

warmImports(() => import("@/routes/_sidebar/businesses.$businessId.runs.new"));

async function openAdvanced() {
  const toggle = await screen.findByRole("button", { name: /Advanced Options/i });
  await act(async () => {
    fireEvent.click(toggle);
  });
}

async function launch() {
  const startBtn = await screen.findByRole("button", { name: /Start Run/i });
  await waitFor(() => expect(startBtn).not.toBeDisabled());
  await act(async () => {
    fireEvent.click(startBtn);
  });
  await act(async () => {
    fireEvent.click(await screen.findByRole("button", { name: /^Launch$/i }));
  });
  await waitFor(() => expect(createRunMock).toHaveBeenCalledTimes(1));
  return (createRunMock.mock.calls[0] as unknown[])[1] as Record<string, unknown>;
}

function lastValidateBody(): Record<string, unknown> {
  const calls = validateRunMock.mock.calls as unknown[][];
  return calls[calls.length - 1][1] as Record<string, unknown>;
}

describe("Run form run time budget", () => {
  it("prefills the Settings default and sends it to validate and create", async () => {
    await renderRunsNew();
    await openAdvanced();
    const input = (await screen.findByLabelText(/Run time budget \(hours\)/i)) as HTMLInputElement;
    expect(input.value).toBe("7");
    expect(input.getAttribute("aria-describedby")).toBe(screen.getByTestId("runtime-budget-hint").id);
    expect(input.min).toBe("5");
    expect(input.max).toBe("30");
    expect(screen.getByTestId("runtime-budget-hint")).toHaveTextContent(
      "Default from Settings (7 hours). Raise it for large models. Whole hours, 5 to 30",
    );
    await waitFor(() => expect(validateRunMock).toHaveBeenCalled());
    expect(lastValidateBody().runtime_budget_hours).toBe(7);
    const body = await launch();
    expect(body.runtime_budget_hours).toBe(7);
  });

  it("sends a changed value as a number", async () => {
    await renderRunsNew();
    await openAdvanced();
    const input = (await screen.findByLabelText(/Run time budget \(hours\)/i)) as HTMLInputElement;
    fireEvent.change(input, { target: { value: "12" } });
    expect(input.value).toBe("12");
    await waitFor(() => expect(lastValidateBody().runtime_budget_hours).toBe(12));
    const body = await launch();
    expect(body.runtime_budget_hours).toBe(12);
  });

  it.each([["31"], ["4"], ["6.5"], [""]])(
    "refuses %s inline and disables Start Run",
    async (value) => {
      await renderRunsNew();
      await openAdvanced();
      const input = (await screen.findByLabelText(/Run time budget \(hours\)/i)) as HTMLInputElement;
      await waitFor(() => expect(validateRunMock).toHaveBeenCalled());
      await new Promise((r) => setTimeout(r, 400));
      const before = validateRunMock.mock.calls.length;
      fireEvent.change(input, { target: { value } });
      const error = await screen.findByTestId("runtime-budget-error");
      expect(error).toHaveTextContent("Run time budget must be a whole number of hours from 5 to 30.");
      expect(input).toHaveAttribute("aria-invalid", "true");
      expect(input.getAttribute("aria-describedby")?.split(" ")).toEqual([
        error.id,
        screen.getByTestId("runtime-budget-hint").id,
      ]);
      expect(screen.getByRole("button", { name: /Start Run/i })).toBeDisabled();
      await new Promise((r) => setTimeout(r, 400));
      expect(validateRunMock.mock.calls.length).toBe(before);
      // Collapsed, the reason still shows next to the disabled button.
      await act(async () => {
        fireEvent.click(screen.getByRole("button", { name: /Advanced Options/i }));
      });
      expect(screen.getByTestId("runtime-budget-invalid")).toBeInTheDocument();
    },
  );

  it("is absent and not sent without a loaded agent config", async () => {
    agentConfig = undefined;
    await renderRunsNew();
    await openAdvanced();
    expect(screen.queryByLabelText(/Run time budget/i)).toBeNull();
    const body = await launch();
    expect("runtime_budget_hours" in body).toBe(false);
  });
});
