/**
 * Fix K — New Base Model form renders a "Run Instructions" textarea.
 *
 * Asserts:
 *  1. The textarea is visible when operationType=new-base-model (isBase).
 *  2. It is bound to the same ``vibeInstructions`` state variable — typing
 *     in it populates ``vibe_instructions`` in the createRun payload.
 *  3. The textarea is NOT rendered in the vibe-iterate branch (no duplicate).
 *
 * Fix M — Business Context textarea value is preserved when the Deployment
 * Catalog dropdown opens (no re-seed from business.description).
 *  4. After typing into Business Context, the value survives a re-render
 *     triggered by the catalog picker query completing.
 *
 * Run Instructions seeded from business.business_vibes — the base-run form
 * pre-fills Run Instructions from the business's long description (editable,
 * dirty-flag guarded, mirroring Business Context):
 *  5. Pre-populated with business_vibes on mount.
 *  6. Submitting without editing sends business_vibes as vibe_instructions.
 *  7. After editing, the typed value survives a re-render (no re-seed).
 */
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";
import { warmImports } from "./helpers/warm-imports";
import { render, screen, waitFor, fireEvent, act } from "@testing-library/react";
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

const BUSINESS_DESCRIPTION = "Seeded 187-char retail blurb from industry pick.";
const BUSINESS_VIBES = "Long-form vibes: prioritize omni-channel retail, keep PII minimal.";

let businessHook: () => unknown = () => ({
  data: {
    id: "biz-1",
    name: "Retail Co",
    description: BUSINESS_DESCRIPTION,
    business_vibes: BUSINESS_VIBES,
  },
});
let versionsHook: () => unknown = () => ({ data: [] });
const createRunMock = vi.fn(async () => ({}));
const validateRunMock = vi.fn(async () => ({ data: { blockers: [], warnings: [] } }));

vi.mock("@/lib/api", async () => {
  const actual = await vi.importActual<typeof import("@/lib/api")>("@/lib/api");
  return {
    ...actual,
    // No base-model pre-fill: the form keeps its own values.
    useGetRunDefaults: () => ({ data: undefined, isLoading: false, isError: false }),
    useGetBusinessSuspense: () => businessHook(),
    useListVersionsSuspense: () => versionsHook(),
    createRun: createRunMock,
    validateRun: validateRunMock,
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
      name: "Retail Co",
      description: BUSINESS_DESCRIPTION,
      business_vibes: BUSINESS_VIBES,
    },
  });
  versionsHook = () => ({ data: [] });
  createRunMock.mockClear();
  validateRunMock.mockClear();
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
  const router = createRouter({
    routeTree: rootRoute.addChildren([
      sidebarRoute.addChildren([runsNewClone]),
      explorerRoute,
    ]),
    history: createMemoryHistory({ initialEntries: [`/businesses/biz-1/runs/new${searchString}`] }),
    defaultPendingMs: 0,
  });
  // Mirror the production QueryClient defaults from `main.tsx`:
  // `refetchOnWindowFocus: false` is global so suspense queries don't
  // re-fire on focus events (the model-versioning work fix M).
  const qc = new QueryClient({
    defaultOptions: {
      queries: {
        retry: false,
        staleTime: 30_000,
        refetchOnWindowFocus: false,
      },
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

describe("Fix K — Run Instructions textarea in new-base-model", () => {
  it("renders a Run Instructions textarea when operation type is new-base-model", async () => {
    await renderRunsNew("?businessId=biz-1&operationType=new-base-model");

    await waitFor(() => {
      // The textarea is identified by its placeholder which contains the
      // "Per-run constraints" wording specified in the fix.
      const textarea = screen.queryByPlaceholderText(
        /Per-run constraints|per-run instructions/i,
      );
      expect(textarea).not.toBeNull();
    });
  });

  it("does NOT render a Run Instructions textarea for vibe-iterate (no duplicate)", async () => {
    versionsHook = () => ({
      data: [
        {
          id: "v-1-mvm",
          version: 1,
          scope: "mvm",
          status: "completed",
          is_base: true,
          confidence_score: null,
          vibe_instructions: "",
          created_at: "2026-04-20T12:00:00Z",
          uc_catalog: "vibe_cat",
          deployment_status: "deployed",
        },
      ],
    });
    await renderRunsNew("?businessId=biz-1&operationType=vibe-iterate");

    await waitFor(() => {
      // The vibe path renders the read-only compiled-instructions preview, not
      // a free-text editor (that was retired).
      expect(screen.queryByText("Compiled instructions preview")).not.toBeNull();
    });

    // The isBase "Run Instructions" textarea must NOT appear in vibe mode, and
    // the retired vibe free-text editor must be gone too.
    expect(
      screen.queryByPlaceholderText(/Per-run constraints|per-run instructions/i),
    ).toBeNull();
    expect(screen.queryByPlaceholderText(/Describe the changes/i)).toBeNull();
  });

  it("populates vibe_instructions in createRun payload when user types in Run Instructions", async () => {
    await renderRunsNew("?businessId=biz-1&operationType=new-base-model");

    await waitFor(() => {
      expect(
        screen.queryByPlaceholderText(/Per-run constraints|per-run instructions/i),
      ).not.toBeNull();
    });

    const runInstructionsTextarea = screen.getByPlaceholderText(
      /Per-run constraints|per-run instructions/i,
    ) as HTMLTextAreaElement;

    const typed = "Only Finance domain.";
    fireEvent.change(runInstructionsTextarea, { target: { value: typed } });
    expect(runInstructionsTextarea.value).toBe(typed);

    // Click Start Run to open the LaunchRunDialog confirmation.
    const startBtn = screen.getByRole("button", { name: /^Start Run$/i });
    await act(async () => {
      fireEvent.click(startBtn);
    });

    // The dialog renders an AlertDialogAction labelled "Launch" — click it
    // to fire the actual createRun call.
    await waitFor(() => {
      expect(
        screen.queryByRole("button", { name: /^Launch$/i }),
      ).not.toBeNull();
    });
    const launchBtn = screen.getByRole("button", { name: /^Launch$/i });
    await act(async () => {
      fireEvent.click(launchBtn);
    });

    // Assert the payload sent to createRun contains the typed instructions.
    // createRun's signature is (params, data) — vibe_instructions lives in
    // the second (data/RunIn) arg.
    await waitFor(() => {
      expect(createRunMock).toHaveBeenCalledWith(
        expect.objectContaining({ business_id: "biz-1" }),
        expect.objectContaining({ vibe_instructions: typed }),
      );
    });
  });
});

describe("Fix M — Business Context textarea value preserved across re-renders", () => {
  it("preserves typed Business Context value after a re-render", async () => {
    await renderRunsNew("?businessId=biz-1&operationType=new-base-model");

    // Wait for the seeded Business Context textarea to appear.
    await waitFor(() => {
      const contextTextarea = screen.queryByDisplayValue(BUSINESS_DESCRIPTION);
      expect(contextTextarea).not.toBeNull();
    });

    const contextTextarea = screen.getByDisplayValue(
      BUSINESS_DESCRIPTION,
    ) as HTMLTextAreaElement;

    // User clears the seeded text and types their own content.
    const customText = "User typed 501 chars of custom business context.";
    fireEvent.change(contextTextarea, { target: { value: customText } });

    // After typing, the textarea value must reflect what the user typed.
    expect(contextTextarea.value).toBe(customText);

    // Interact with the catalog picker (simulates focus-change that would
    // normally trigger a stale-data refetch and re-suspend in production).
    const catalogPicker = screen.getByTestId("catalog-picker");
    await act(async () => {
      fireEvent.change(catalogPicker, { target: { value: "new_catalog" } });
    });

    // After the re-render triggered by catalog interaction, the user's typed
    // content must still be present — not reset to the seeded business description.
    expect(contextTextarea.value).toBe(customText);
    expect(contextTextarea.value).not.toBe(BUSINESS_DESCRIPTION);
  });

  it("businessContextDirty flag does not affect initial seeded value before user edits", async () => {
    await renderRunsNew("?businessId=biz-1&operationType=new-base-model");

    // Before any user interaction, the textarea should show the seeded description.
    await waitFor(() => {
      const contextTextarea = screen.queryByDisplayValue(BUSINESS_DESCRIPTION);
      expect(contextTextarea).not.toBeNull();
    });
  });
});

describe("Run Instructions seeded from business.business_vibes", () => {
  it("pre-populates the Run Instructions textarea with business_vibes on mount", async () => {
    await renderRunsNew("?businessId=biz-1&operationType=new-base-model");

    await waitFor(() => {
      const textarea = screen.getByPlaceholderText(
        /Per-run constraints|per-run instructions/i,
      ) as HTMLTextAreaElement;
      expect(textarea.value).toBe(BUSINESS_VIBES);
    });
  });

  it("submits business_vibes as vibe_instructions when the field is not edited", async () => {
    await renderRunsNew("?businessId=biz-1&operationType=new-base-model");

    await waitFor(() => {
      const textarea = screen.getByPlaceholderText(
        /Per-run constraints|per-run instructions/i,
      ) as HTMLTextAreaElement;
      expect(textarea.value).toBe(BUSINESS_VIBES);
    });

    // Launch without touching the pre-filled Run Instructions.
    const startBtn = screen.getByRole("button", { name: /^Start Run$/i });
    await act(async () => {
      fireEvent.click(startBtn);
    });

    await waitFor(() => {
      expect(screen.queryByRole("button", { name: /^Launch$/i })).not.toBeNull();
    });
    const launchBtn = screen.getByRole("button", { name: /^Launch$/i });
    await act(async () => {
      fireEvent.click(launchBtn);
    });

    await waitFor(() => {
      expect(createRunMock).toHaveBeenCalledWith(
        expect.objectContaining({ business_id: "biz-1" }),
        expect.objectContaining({ vibe_instructions: BUSINESS_VIBES }),
      );
    });
  });

  it("preserves the user's typed Run Instructions across a re-render (dirty flag stops re-seed)", async () => {
    await renderRunsNew("?businessId=biz-1&operationType=new-base-model");

    await waitFor(() => {
      const textarea = screen.getByPlaceholderText(
        /Per-run constraints|per-run instructions/i,
      ) as HTMLTextAreaElement;
      expect(textarea.value).toBe(BUSINESS_VIBES);
    });

    const textarea = screen.getByPlaceholderText(
      /Per-run constraints|per-run instructions/i,
    ) as HTMLTextAreaElement;

    // User clears the seeded vibes and types their own instructions.
    const customText = "Only the Finance domain, no PII columns.";
    fireEvent.change(textarea, { target: { value: customText } });
    expect(textarea.value).toBe(customText);

    // A re-render triggered by the catalog picker query must not re-seed
    // the field back to business_vibes.
    const catalogPicker = screen.getByTestId("catalog-picker");
    await act(async () => {
      fireEvent.change(catalogPicker, { target: { value: "new_catalog" } });
    });

    expect(textarea.value).toBe(customText);
    expect(textarea.value).not.toBe(BUSINESS_VIBES);
  });
});
