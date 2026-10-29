/**
 * Locks the "Model Size combobox is hidden for vibe-new-ecm-mvm" UI invariant.
 *
 * The intent contract pins both phases:
 *   - Phase 1 (vibe_iterate)  → ECM ("large model")
 *   - Phase 2 (shrink_to_mvm) → MVM ("small model", hardcoded inside
 *     `_shrink_to_mvm_params`)
 *
 * The user has no choice for either phase. Surfacing the Model Size
 * combobox would imply a knob that the DAG factory ignores; before the
 * fix it actively misled callers because the form's default value
 * ("Small Model (MVM)") was forwarded into the agent's vibe_iterate
 * widget and broke the run.
 *
 * Same logic applies to new-base-model — that's already covered by the
 * shipping form (the Model Size widget renders inside `{isVibe && ...}`
 * which is false for `isBase`). This test extends that contract to the
 * combined intent.
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

const NEW_INTENT = "vibe-new-ecm-mvm";

// ---------------------------------------------------------------------------
// Shared fixtures + module mocks (mirror runs-new-vibe-ecm-mvm.test.tsx)
// ---------------------------------------------------------------------------

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
const MVM_VERSION = {
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
};

let businessHook: () => unknown = () => ({
  data: { id: "biz-1", name: "Acme Corp", description: "A 187-char retail blurb." },
});
let versionsHook: () => unknown = () => ({
  data: [MVM_VERSION, ECM_VERSION],
});
const createRunMock = vi.fn(async () => ({ data: { id: "run-new" } }));
const validateRunMock = vi.fn(async () => ({
  data: { blockers: [], warnings: [] },
}));

vi.mock("@/lib/api", async () => {
  const actual = await vi.importActual<typeof import("@/lib/api")>("@/lib/api");
  return {
    ...actual,
    // No base-model pre-fill: the form keeps its own values.
    useGetRunDefaults: () => ({ data: undefined, isLoading: false, isError: false }),
    useGetBusinessSuspense: () => businessHook(),
    useListVersionsSuspense: () => versionsHook(),
    createRun: (...args: unknown[]) =>
      (createRunMock as unknown as (...a: unknown[]) => unknown)(...args),
    validateRun: (...args: unknown[]) =>
      (validateRunMock as unknown as (...a: unknown[]) => unknown)(...args),
  };
});

vi.mock("@/components/ui/markdown-toolbar", () => ({
  MarkdownToolbar: () => null,
}));
vi.mock("@/components/runs/deployment-catalog-picker", () => ({
  DeploymentCatalogPicker: ({
    value,
    onChange,
  }: {
    value: string;
    onChange: (v: string) => void;
  }) => (
    <input
      data-testid="catalog-picker"
      value={value}
      onChange={(e) => onChange(e.target.value)}
    />
  ),
}));

beforeEach(() => {
  businessHook = () => ({
    data: {
      id: "biz-1",
      name: "Acme Corp",
      description: "A 187-char retail blurb.",
    },
  });
  versionsHook = () => ({ data: [MVM_VERSION, ECM_VERSION] });
  createRunMock.mockClear();
  validateRunMock.mockClear();
  validateRunMock.mockImplementation(async () => ({
    data: { blockers: [], warnings: [] },
  }));
});

afterEach(() => {
  vi.restoreAllMocks();
});

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
  const explorerRoute = createRoute({
    getParentRoute: () => rootRoute,
    path: "/businesses/$businessId/explorer",
    component: () => <div data-testid="explorer-stub" />,
  });
  const businessRunsRoute = createRoute({
    getParentRoute: () => rootRoute,
    path: "/businesses/$businessId/runs",
    component: () => <div data-testid="business-runs-stub" />,
  });
  const router = createRouter({
    routeTree: rootRoute.addChildren([
      sidebarRoute.addChildren([runsNewClone]),
      explorerRoute,
      businessRunsRoute,
    ]),
    history: createMemoryHistory({
      initialEntries: [`/businesses/biz-1/runs/new${searchString}`],
    }),
    defaultPendingMs: 0,
  });
  const qc = new QueryClient({
    defaultOptions: {
      queries: { retry: false, staleTime: 30_000, refetchOnWindowFocus: false },
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

/** Find the "Model Size" form section by its label text. The label is
 *  rendered as a sibling of the radix-shadow `<select>`, so we walk up
 *  to the wrapping `<div className="space-y-2">` to detect presence/
 *  absence of the entire widget (label + combobox). Returns null when
 *  the section is not in the DOM at all. */
function findModelSizeSection(): HTMLElement | null {
  const labels = Array.from(document.querySelectorAll("label"));
  const label = labels.find(
    (l) => (l.textContent || "").trim() === "Model Size",
  );
  if (!label) return null;
  // Walk up to the wrapping `space-y-2` div so we can also assert any
  // sibling combobox's disabled state if the impl chose hide-vs-disable.
  let cur: HTMLElement | null = label;
  while (cur && !cur.classList.contains("space-y-2")) {
    cur = cur.parentElement;
  }
  return cur ?? label;
}

warmImports(() => import("@/routes/_sidebar/businesses.$businessId.runs.new"));

describe("runs.new — Model Size combobox is hidden for vibe-new-ecm-mvm", () => {
  it("renders the Model Size widget for the legacy vibe-iterate intent (control)", async () => {
    // Sanity: the widget is still there for the intent that legitimately
    // lets the user pick a size. Without this control the absence-test
    // below would tautologically pass on any unrelated regression that
    // tore the widget out wholesale.
    await renderRunsNew(
      `?businessId=biz-1&operationType=vibe modeling of version`,
    );
    await waitFor(() => {
      expect(
        screen.queryByText("Compiled instructions preview"),
      ).not.toBeNull();
    });
    expect(findModelSizeSection()).not.toBeNull();
  });

  it("hides the Model Size widget when intent='vibe-new-ecm-mvm'", async () => {
    await renderRunsNew(`?businessId=biz-1&operationType=${NEW_INTENT}`);
    await waitFor(() => {
      expect(
        screen.queryByText("Compiled instructions preview"),
      ).not.toBeNull();
    });
    // The section must not be in the DOM at all. (Spec accepted "hide
    // OR disable"; the dev pick is hide — assert hide directly. If a
    // future change switches to disable, update the assertion together
    // with the runs.new wirer.)
    expect(findModelSizeSection()).toBeNull();
  });

  it("hides the Model Size widget for new-base-model (existing contract)", async () => {
    versionsHook = () => ({ data: [] });
    // Belt-and-braces — the same logic ("user has no choice") covers
    // new-base-model. The shipping form already gates the widget on
    // `{isVibe && ...}` so this is a regression guard, not a new lock.
    await renderRunsNew(`?businessId=biz-1&operationType=new base model`);
    await waitFor(() => {
      // new-base-model surfaces a different placeholder; key off the
      // Operation Type select being settled instead of a vibe textarea.
      expect(document.querySelectorAll("select").length).toBeGreaterThan(0);
    });
    expect(findModelSizeSection()).toBeNull();
  });
});
