/**
 * Blind tests — `vibe-new-ecm-mvm` launcher.
 *
 * The new run intent re-runs both the ECM and MVM stages on top of an
 * existing ECM base version (i.e. it produces a fresh MVM tied to a
 * vibed ECM in one go). It surfaces in two places:
 *
 *   1. ``runs.new.tsx`` — a new option in the Operation Type picker.
 *   2. The model-version ActionsCard — a "Vibe ECM + MVM" button visible
 *      only on ECM versions; on MVM versions the button is hidden or
 *      disabled (the spec is explicit that either render is acceptable
 *      so the assertions accept both shapes).
 *
 * The form fields for ``vibe-new-ecm-mvm`` are identical to ``vibe-iterate``:
 *   - ``parent_version_id`` (the base version selector)
 *   - ``vibe_instructions`` (textarea)
 *   - ``business_context_text`` (optional)
 *   - ``catalog`` (Deployment Catalog picker)
 *   - ``cataloging_style`` (Namespace Style)
 *
 * Server-side validation (POST /runs/validate) rejects MVM parents with
 * a blocker on the ``parent_version_id`` field — these tests assert the
 * blocker message renders inline near the picker.
 *
 * STUB-FOR-INTEGRATION: this file is written before the FE dev agent's
 * launcher lands. If the dev agent's work is missing the new intent,
 * tests fail with a clear "INTENT_LABELS missing entry" / "no option
 * with text Vibe ECM + MVM" signal.
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
import { makeModelVersion } from "./helpers/model-version";

const NEW_INTENT = "vibe-new-ecm-mvm";
const NEW_INTENT_LABEL = "Vibe ECM + MVM";

// ---------------------------------------------------------------------------
// Shared fixtures + module mocks
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

// Vibe Inputs on the base version drive the compiled-instructions preview and
// satisfy the "something to vibe on" blocker. Default: two anchored, selected
// inputs (only `selected_for_run` inputs dispatch).
let vibeInputsData: unknown[] = [
  { id: "vi-1", text: "keep order ids stable", priority: "medium", anchor: { level: "model_wide", path: [] }, consumed: false, selected_for_run: true },
  { id: "vi-2", text: "tag pks", priority: "high", anchor: { level: "element", domain_name: "Sales", path: ["Domain: Sales"] }, consumed: false, selected_for_run: true },
];

vi.mock("@/lib/api", async () => {
  const actual = await vi.importActual<typeof import("@/lib/api")>("@/lib/api");
  return {
    ...actual,
    useGetBusinessSuspense: () => businessHook(),
    useListVersionsSuspense: () => versionsHook(),
    // CommandStrip subscribes to the version's runs for its status summary;
    // an empty array keeps the launcher-visibility assertions deterministic.
    useListRunsForVersion: () => ({ data: [] }),
    // No base-model pre-fill: the form keeps its own values.
    useGetRunDefaults: () => ({ data: undefined, isLoading: false, isError: false }),
    useListVibeInputs: (opts: any) => ({
      data: opts?.query?.select ? opts.query.select({ data: vibeInputsData }) : vibeInputsData,
    }),
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
  vibeInputsData = [
    { id: "vi-1", text: "keep order ids stable", priority: "medium", anchor: { level: "model_wide", path: [] }, consumed: false, selected_for_run: true },
    { id: "vi-2", text: "tag pks", priority: "high", anchor: { level: "element", domain_name: "Sales", path: ["Domain: Sales"] }, consumed: false, selected_for_run: true },
  ];
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
// runs.new route mounting helper (mirrors runs-new-base-model-instructions)
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

/** Read the labels of all options in the (radix-shadow) Operation Type
 *  select. The shadow `<select>` is the first one rendered in the form
 *  (mirrors the runs-new-source-scope helper). */
function readOperationTypeOptions(): string[] {
  const selects = Array.from(document.querySelectorAll("select"));
  // The Operation Type select hosts the "New Base Model" option and is
  // therefore identifiable by its content.
  const opSelect = selects.find((s) =>
    Array.from(s.options).some((o) =>
      /new base model/i.test(o.textContent || ""),
    ),
  );
  if (!opSelect) return [];
  return Array.from(opSelect.options).map((o) =>
    (o.textContent || "").trim(),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

warmImports(() => import("@/routes/_sidebar/businesses.$businessId.runs.new"));

describe("intent map — vibe-new-ecm-mvm", () => {
  it("intentLabel('vibe-new-ecm-mvm') === 'Vibe ECM + MVM'", async () => {
    const { intentLabel, INTENT_LABELS } = await import("@/lib/intent");
    expect(INTENT_LABELS[NEW_INTENT]).toBe(NEW_INTENT_LABEL);
    expect(intentLabel(NEW_INTENT)).toBe(NEW_INTENT_LABEL);
  });
});

describe("runs.new — Operation Type picker exposes the new intent", () => {
  it("renders 'Vibe ECM + MVM' as a selectable option when versions exist", async () => {
    await renderRunsNew("?businessId=biz-1");

    await waitFor(() => {
      const labels = readOperationTypeOptions();
      expect(labels.length).toBeGreaterThan(0);
      // The picker must include both the legacy vibe-iterate label and
      // the new Vibe ECM + MVM label — same surface, no gating.
      expect(labels.some((l) => /Vibe Modeling/i.test(l))).toBe(true);
      expect(
        labels.some((l) => l === NEW_INTENT_LABEL || /Vibe ECM \+ MVM/i.test(l)),
      ).toBe(true);
    });
  });

  it("keeps both Vibe Iterate and Vibe ECM + MVM enabled simultaneously (no gating)", async () => {
    await renderRunsNew("?businessId=biz-1");

    await waitFor(() => {
      const selects = Array.from(document.querySelectorAll("select"));
      const opSelect = selects.find((s) =>
        Array.from(s.options).some((o) =>
          /new base model/i.test(o.textContent || ""),
        ),
      );
      expect(opSelect).toBeTruthy();
      const opts = Array.from(opSelect!.options);
      const vibeIterate = opts.find((o) =>
        /Vibe Modeling/i.test(o.textContent || ""),
      );
      const vibeNew = opts.find((o) =>
        /Vibe ECM \+ MVM/i.test(o.textContent || ""),
      );
      expect(vibeIterate?.disabled).toBeFalsy();
      expect(vibeNew?.disabled).toBeFalsy();
    });
  });
});

describe("runs.new — vibe-new-ecm-mvm form fields mirror vibe-iterate", () => {
  it("renders the same shared fields when the new intent is selected via URL", async () => {
    await renderRunsNew(`?businessId=biz-1&operationType=${NEW_INTENT}`);

    // Wait for the form to settle; reuse the vibe-iterate "Describe the
    // changes" placeholder which is the canonical vibe_instructions
    // textarea hint.
    await waitFor(() => {
      expect(
        screen.queryByText("Compiled instructions preview"),
      ).not.toBeNull();
    });

    // Catalog picker (mocked above) is always rendered for model-producing
    // intents.
    expect(screen.queryByTestId("catalog-picker")).not.toBeNull();

    // The base-version selector is the second `<select>` (after Operation
    // Type / Namespace Style). We assert by content shape: at least one
    // option matches `v\d+ (ECM|MVM)`.
    const selects = Array.from(document.querySelectorAll("select"));
    const baseVersionSelect = selects.find((s) =>
      Array.from(s.options).some((o) =>
        /v\d+\s+(ECM|MVM)/i.test(o.textContent || ""),
      ),
    );
    expect(baseVersionSelect).toBeTruthy();
  });
});

describe("runs.new — submit posts intent='vibe-new-ecm-mvm' to /runs", () => {
  it("sends the right body shape to createRun", async () => {
    await renderRunsNew(`?businessId=biz-1&operationType=${NEW_INTENT}`);

    // The vibe path is content-complete via the compiled Vibe Inputs (mocked);
    // no free-text editor to fill. Just launch.
    await waitFor(() => {
      expect(
        screen.queryByText("Compiled instructions preview"),
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
    const params = ((createRunMock.mock.calls[0] as unknown[] | undefined)?.[0] ??
      {}) as Record<string, unknown>;
    const body = ((createRunMock.mock.calls[0] as unknown[] | undefined)?.[1] ??
      {}) as Record<string, unknown>;
    expect(body.intent).toBe(NEW_INTENT);
    // business_id is now a path parameter on POST /businesses/{id}/runs,
    // not a body field.
    expect(params.business_id).toBe("biz-1");
    // The free-text vibe editor was retired; vibe runs carry no
    // vibe_instructions text — the content is the compiled input_ids.
    expect(body.vibe_instructions).toBe("");
    expect(body.input_ids).toEqual(["vi-1", "vi-2"]);
    // Same shape as vibe-iterate: a base version is attached.
    expect(typeof body.version_id === "string" && body.version_id.length > 0).toBe(
      true,
    );
  });
});

describe("runs.new — base-version dropdown filters to ECM only for vibe-new-ecm-mvm", () => {
  it("hides MVM versions from the picker when the combined intent is selected", async () => {
    await renderRunsNew(`?businessId=biz-1&operationType=${NEW_INTENT}`);

    await waitFor(() => {
      expect(
        screen.queryByText("Compiled instructions preview"),
      ).not.toBeNull();
    });

    const selects = Array.from(document.querySelectorAll("select"));
    const baseVersionSelect = selects.find((s) =>
      Array.from(s.options).some((o) =>
        /v\d+\s+(ECM|MVM)/i.test(o.textContent || ""),
      ),
    );
    expect(baseVersionSelect).toBeTruthy();
    const labels = Array.from(baseVersionSelect!.options).map((o) =>
      (o.textContent || "").trim(),
    );
    expect(labels.some((l) => /ECM/i.test(l))).toBe(true);
    expect(labels.some((l) => /MVM/i.test(l))).toBe(false);
  });

  it("submits the ECM version_id (never the MVM one) for the combined intent", async () => {
    // Versions hook returns BOTH MVM_VERSION and ECM_VERSION; MVM is
    // listed first. Without the eligibleBaseVersions filter, the default
    // pick would be MVM (first in the list) and createRun would carry
    // the wrong scope. The filter forces ECM as the only option.
    await renderRunsNew(`?businessId=biz-1&operationType=${NEW_INTENT}`);

    await waitFor(() => {
      expect(
        screen.queryByText("Compiled instructions preview"),
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
    expect(body.version_id).toBe(ECM_VERSION.id);
  });

  it("disables Start Run with an explanatory message when no ECM versions exist", async () => {
    versionsHook = () => ({ data: [MVM_VERSION] });
    await renderRunsNew(`?businessId=biz-1&operationType=${NEW_INTENT}`);

    await waitFor(() => {
      expect(
        screen.queryByText("Compiled instructions preview"),
      ).not.toBeNull();
    });

    expect(
      screen.queryByText(/No completed ECM versions available/i),
    ).not.toBeNull();
    const startBtn = screen.getByRole("button", {
      name: /^Start Run$/i,
    }) as HTMLButtonElement;
    expect(startBtn.disabled).toBe(true);
  });
});

describe("runs.new — vibe ops require something to vibe on", () => {
  it("disables Start Run for vibe-new-ecm-mvm when inputs + feedback + next-vibes are all empty", async () => {
    vibeInputsData = []; // no compiled Vibe Inputs
    await renderRunsNew(`?businessId=biz-1&operationType=${NEW_INTENT}`);

    await waitFor(() => {
      expect(
        screen.queryByText("Compiled instructions preview"),
      ).not.toBeNull();
    });

    expect(screen.queryByTestId("vibe-content-missing")).not.toBeNull();
    const startBtn = screen.getByRole("button", {
      name: /^Start Run$/i,
    }) as HTMLButtonElement;
    expect(startBtn.disabled).toBe(true);
  });

  it("disables Start Run for vibe-iterate when inputs + feedback + next-vibes are all empty", async () => {
    vibeInputsData = [];
    await renderRunsNew("?businessId=biz-1&operationType=vibe-iterate");

    await waitFor(() => {
      expect(
        screen.queryByText("Compiled instructions preview"),
      ).not.toBeNull();
    });

    expect(screen.queryByTestId("vibe-content-missing")).not.toBeNull();
    const startBtn = screen.getByRole("button", {
      name: /^Start Run$/i,
    }) as HTMLButtonElement;
    expect(startBtn.disabled).toBe(true);
  });

  it("enables Start Run for vibe-new-ecm-mvm when the base version has compiled inputs", async () => {
    // Default vibeInputsData has two anchored inputs → content present.
    await renderRunsNew(`?businessId=biz-1&operationType=${NEW_INTENT}`);

    await waitFor(() => {
      expect(
        screen.queryByText("Compiled instructions preview"),
      ).not.toBeNull();
    });

    expect(screen.queryByTestId("vibe-content-missing")).toBeNull();
    const startBtn = screen.getByRole("button", {
      name: /^Start Run$/i,
    }) as HTMLButtonElement;
    expect(startBtn.disabled).toBe(false);
  });
});

describe("runs.new — validate blocker for MVM parent renders inline", () => {
  it("displays the parent_version_id blocker message near the picker", async () => {
    validateRunMock.mockImplementation((async () => ({
      data: {
        blockers: [
          {
            field_path: "parent_version_id",
            step_index: 0,
            message: "Parent version must be an ECM scope",
            severity: "blocker",
          },
        ],
        warnings: [],
      },
    })) as never);

    await renderRunsNew(`?businessId=biz-1&operationType=${NEW_INTENT}`);

    // The validate effect fires on mount (debounced ~300ms) for the combined
    // intent; wait for the blocker text to appear. (The free-text editor that
    // used to kick the debounce was retired — the effect runs regardless.)
    await waitFor(() => {
      expect(
        screen.queryByText("Compiled instructions preview"),
      ).not.toBeNull();
    });

    await waitFor(
      () => {
        expect(
          screen.queryByText(/Parent version must be an ECM scope/i),
        ).not.toBeNull();
      },
    );
  });
});

// ---------------------------------------------------------------------------
// CommandStrip — "Prepare new Vibe" entry on ECM and MVM versions.
// The strip button no longer launches the run directly; it opens the prepare/
// compose surface (the combined ECM+MVM operation stays selectable on the run
// form, covered by the option tests above).
// ---------------------------------------------------------------------------

/** Find the launcher, which renders as an `<a>` styled like a button (links to
 *  the compose surface). */
function findLauncher(container: HTMLElement): HTMLElement | null {
  const byTestId = container.querySelector('[data-testid="prepare-new-vibe"]');
  if (byTestId) return byTestId as HTMLElement;
  const candidates = Array.from(
    container.querySelectorAll<HTMLElement>("button, a"),
  );
  return (
    candidates.find((el) => /Prepare new Vibe/i.test(el.textContent || "")) ??
    null
  );
}

describe("CommandStrip — Prepare new Vibe entry", () => {
  it("shows the entry when scope='ecm'", async () => {
    const { CommandStrip } = await import(
      "@/components/overview/command-strip"
    );
    const { renderWithRouter } = await import("./helpers/router-wrapper");
    const { container } = renderWithRouter(
      <CommandStrip
        businessId="biz-1"
        version={makeModelVersion({ id: "v-1-ecm", version: 1, scope: "ecm", deployment_status: "draft" })}
        versions={[]}
      />,
    );

    await waitFor(() => {
      const launcher = findLauncher(container);
      expect(launcher).not.toBeNull();
    });
    const launcher = findLauncher(container)!;
    // Disabled? For an `<a>` the dev agent should not render it as a
    // dead link; for a `<button>` `disabled` is the standard signal.
    expect(launcher.hasAttribute("disabled")).toBe(false);
    expect(launcher.getAttribute("aria-disabled")).not.toBe("true");

    // The entry opens the prepare/compose surface (pick inputs, then start
    // the run) rather than launching a run directly.
    if (launcher.tagName === "A") {
      const href = launcher.getAttribute("href") || "";
      expect(href).toMatch(/\/inputs$/);
    }
  });

  it("shows the entry, linking to the compose surface, when scope='mvm'", async () => {
    const { CommandStrip } = await import(
      "@/components/overview/command-strip"
    );
    const { renderWithRouter } = await import("./helpers/router-wrapper");
    const { container } = renderWithRouter(
      <CommandStrip
        businessId="biz-1"
        version={makeModelVersion({ id: "v-1-mvm", version: 1, scope: "mvm", deployment_status: "deployed", uc_catalog: "cat_a" })}
        versions={[]}
      />,
    );

    await waitFor(() => {
      expect(findLauncher(container)).not.toBeNull();
    });
    const launcher = findLauncher(container)!;
    expect(launcher.hasAttribute("disabled")).toBe(false);
    expect(launcher.getAttribute("aria-disabled")).not.toBe("true");
    expect(launcher.getAttribute("href") || "").toMatch(/\/inputs$/);
  });
});
