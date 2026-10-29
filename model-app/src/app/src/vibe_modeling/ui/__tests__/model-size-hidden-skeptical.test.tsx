/**
 * Skeptical-tester pass — Model Size combobox visibility on runs.new.
 *
 * Fix C from the change spec: the Model Size dropdown only renders when
 * the user actually has a choice — i.e. only for ``vibe-iterate`` (a
 * single-op intent). For ``new-base-model`` (isBase) and the new
 * ``vibe-new-ecm-mvm`` (isVibeCombined), the sizes are intent-fixed
 * (large then small) inside the DAG factories, so the combobox is
 * meaningless on those forms — it just confuses the user and provides a
 * value the BE will ignore. Hide it.
 *
 * Submit-body invariant: even when the widget is hidden, the body sent
 * to ``createRun`` must still carry ``model_size: "large model"`` (the
 * Phase 1 size, which the FE picks for both isBase and isVibeCombined
 * regardless of any leftover ``modelSize`` form state).
 *
 * These tests are written WITHOUT reading ``runs.new.tsx`` or the dev's
 * own model-size-hidden test (Skeptical Tester pattern, blind run).
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

// ---------------------------------------------------------------------------
// Fixtures + module mocks (mirror runs-new-vibe-ecm-mvm.test.tsx exactly so
// the form mounts cleanly)
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
  data: {
    id: "biz-1",
    name: "Acme Corp",
    description: "A 187-char retail blurb to seed the form.",
  },
});
let versionsHook: () => unknown = () => ({
  data: [MVM_VERSION, ECM_VERSION],
});
const createRunMock = vi.fn(async () => ({ data: { id: "run-1" } }));
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
    useListVibeInputs: (opts: any) => {
      const data = [
        { id: "vi-1", text: "keep order ids stable", priority: "medium", anchor: { level: "model_wide", path: [] }, consumed: false, selected_for_run: true },
      ];
      return { data: opts?.query?.select ? opts.query.select({ data }) : data };
    },
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
      description: "A 187-char retail blurb to seed the form.",
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

// ---------------------------------------------------------------------------
// Mount helper — mirrors runs-new-vibe-ecm-mvm.test.tsx
// ---------------------------------------------------------------------------

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

/**
 * Probe for the "Model Size" widget without depending on a specific
 * shadcn primitive (it could be a native ``<select>``, a Radix Select
 * trigger ``<button>``, or a Combobox button — the spec calls it a
 * "combobox"). The label is the stable contract: the widget is rendered
 * inside a section with a ``Model Size`` label. We accept ANY label
 * whose visible text is exactly ``Model Size``.
 *
 * Returns the label element, or null if no such label is in the DOM.
 */
function findModelSizeLabel(): HTMLElement | null {
  const labels = Array.from(document.querySelectorAll("label, span, div"));
  return (
    (labels.find((l) => (l.textContent || "").trim() === "Model Size") as
      | HTMLElement
      | undefined) ?? null
  );
}

/**
 * Stronger probe: the widget itself. Look for any ``<select>`` whose
 * options include "small model" / "large model" (the canonical agent
 * model sizes, used by the FE's modelSize state). Falls back to any
 * button/element with aria-label including "Model Size".
 */
function findModelSizeWidget(): HTMLElement | null {
  const selects = Array.from(document.querySelectorAll("select"));
  const sizeSelect = selects.find((s) =>
    Array.from(s.options).some((o) =>
      /(small|large|tiny)\s+model/i.test((o.textContent || "").trim()),
    ),
  );
  if (sizeSelect) return sizeSelect;
  const ariaButtons = Array.from(
    document.querySelectorAll<HTMLElement>('[aria-label]'),
  ).filter((el) =>
    /model size/i.test(el.getAttribute("aria-label") || ""),
  );
  if (ariaButtons.length) return ariaButtons[0];
  return null;
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

warmImports(() => import("@/routes/_sidebar/businesses.$businessId.runs.new"));

describe("runs.new — Model Size combobox visibility (Fix C)", () => {
  it("renders the Model Size combobox when intent='vibe-iterate' (control case)", async () => {
    // Vibe-iterate is the only intent where the user gets to pick model
    // size — confirm the widget is visible so the negative cases below
    // aren't no-ops. Without this control, an accidental rename of the
    // label or a top-level early return would silently pass every
    // negative assertion.
    await renderRunsNew("?businessId=biz-1&operationType=vibe-iterate");

    await waitFor(() => {
      // The vibe path shows the read-only compiled-instructions preview —
      // wait on that signal before probing for Model Size.
      expect(
        screen.queryByText("Compiled instructions preview"),
      ).not.toBeNull();
    });

    const label = findModelSizeLabel();
    const widget = findModelSizeWidget();
    expect(
      label || widget,
      "vibe-iterate must surface the Model Size widget — neither label " +
        "'Model Size' nor a select with model-size options found in DOM.",
    ).not.toBeNull();
  });

  it("hides the Model Size combobox when intent='new-base-model' (isBase)", async () => {
    versionsHook = () => ({ data: [] });
    await renderRunsNew("?businessId=biz-1&operationType=new-base-model");

    // Wait for the new-base-model form to settle (the per-run instructions
    // textarea is its canonical rendered fingerprint).
    await waitFor(() => {
      expect(
        screen.queryByPlaceholderText(/Per-run constraints|per-run instructions/i),
      ).not.toBeNull();
    });

    const label = findModelSizeLabel();
    const widget = findModelSizeWidget();
    expect(label).toBeNull();
    expect(widget).toBeNull();
  });

  it("hides the Model Size combobox when intent='vibe-new-ecm-mvm' (isVibeCombined)", async () => {
    await renderRunsNew(
      "?businessId=biz-1&operationType=vibe-new-ecm-mvm",
    );

    // Wait on the shared vibe compiled-preview, identical to vibe-iterate.
    await waitFor(() => {
      expect(
        screen.queryByText("Compiled instructions preview"),
      ).not.toBeNull();
    });

    const label = findModelSizeLabel();
    const widget = findModelSizeWidget();
    expect(
      label,
      "vibe-new-ecm-mvm must NOT show a 'Model Size' label — Phase 1 is " +
        "intent-fixed to 'large model' and Phase 2 to 'small model' " +
        "inside the DAG, so the user has no real choice.",
    ).toBeNull();
    expect(widget).toBeNull();
  });
});

describe("runs.new — submit body model_size for intent-fixed intents", () => {
  it("submits model_size='large model' for vibe-new-ecm-mvm regardless of any leftover modelSize state", async () => {
    await renderRunsNew(
      "?businessId=biz-1&operationType=vibe-new-ecm-mvm",
    );

    // Settle the form. The vibe path is content-complete via the compiled
    // Vibe Inputs (mocked) — no free-text editor to fill.
    await waitFor(() => {
      expect(
        screen.queryByText("Compiled instructions preview"),
      ).not.toBeNull();
    });

    // Click Start Run → Launch in the dialog.
    const startBtn = screen.getByRole("button", { name: /^Start Run$/i });
    await act(async () => {
      fireEvent.click(startBtn);
    });
    await waitFor(() => {
      expect(
        screen.queryByRole("button", { name: /^Launch$/i }),
      ).not.toBeNull();
    });
    const launchBtn = screen.getByRole("button", { name: /^Launch$/i });
    await act(async () => {
      fireEvent.click(launchBtn);
    });

    await waitFor(() => {
      expect(createRunMock).toHaveBeenCalledTimes(1);
    });
    const body = ((createRunMock.mock.calls[0] as unknown[] | undefined)?.[1] ??
      {}) as Record<string, unknown>;
    expect(body.intent).toBe("vibe-new-ecm-mvm");
    expect(body.model_size).toBe("large model");
  });

  it("submits model_size='large model' for new-base-model (isBase)", async () => {
    versionsHook = () => ({ data: [] });
    await renderRunsNew("?businessId=biz-1&operationType=new-base-model");

    await waitFor(() => {
      expect(
        screen.queryByPlaceholderText(/Per-run constraints|per-run instructions/i),
      ).not.toBeNull();
    });

    const startBtn = screen.getByRole("button", { name: /^Start Run$/i });
    await act(async () => {
      fireEvent.click(startBtn);
    });
    await waitFor(() => {
      expect(
        screen.queryByRole("button", { name: /^Launch$/i }),
      ).not.toBeNull();
    });
    const launchBtn = screen.getByRole("button", { name: /^Launch$/i });
    await act(async () => {
      fireEvent.click(launchBtn);
    });

    await waitFor(() => {
      expect(createRunMock).toHaveBeenCalledTimes(1);
    });
    const body = ((createRunMock.mock.calls[0] as unknown[] | undefined)?.[1] ??
      {}) as Record<string, unknown>;
    expect(body.intent).toBe("new-base-model");
    expect(body.model_size).toBe("large model");
  });
});
