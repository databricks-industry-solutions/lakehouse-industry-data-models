/**
 * New Run page - the Base Version picker of Vibe Modeling.
 *
 * - It offers every finished non-draft version, superseded ones included,
 *   labelled "(superseded)" from the status plus the explorer's "(Replaced by
 *   vN)" when the version was replaced; drafts, failed and generating
 *   versions are not offered.
 * - The default stays the freshest completed version.
 * - A deep link to a version the picker offers selects it silently; a link to
 *   one it does not offer says why and which version was selected instead.
 * - "(vibed)" follows the explorer's Base / Vibed brand, not whether the
 *   version carries run instructions.
 */
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";
import { warmImports } from "./helpers/warm-imports";
import { fireEvent, render, screen, waitFor } from "@testing-library/react";
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

function row(over: Record<string, unknown>) {
  return {
    scope: "mvm",
    status: "completed",
    confidence_score: null,
    vibe_instructions: "",
    created_at: "2026-04-20T12:00:00Z",
    uc_catalog: "vibe_modeling",
    deployment_status: "deployed",
    is_head: true,
    ...over,
  };
}

// Newest first, as the list endpoint returns it.
const VERSIONS = [
  row({ id: "v-4-mvm", version: 4, status: "generating", is_head: false }),
  row({ id: "v-3-mvm", version: 3, status: "draft", deployment_status: "draft", is_head: false }),
  row({ id: "v-2-mvm", version: 2, vibe_instructions: "" }),
  row({ id: "v-2-ecm", version: 2, scope: "ecm" }),
  row({
    id: "v-1-mvm",
    version: 1,
    status: "superseded",
    is_head: false,
    // A pointer without replaced_at (install promotion sets both): not a replacement.
    replaced_by_version_id: "v-2-mvm",
    vibe_instructions: "Seed instructions of the base run",
  }),
  row({
    id: "v-1-ecm",
    version: 1,
    scope: "ecm",
    status: "superseded",
    is_head: false,
    replaced_at: "2026-04-22T12:00:00Z",
    replaced_by_version_id: "v-2-ecm",
    vibe_instructions: "Seed instructions of the base run",
  }),
];

let explorerRows: Array<{ id: string; is_base?: boolean }> = [];
let explorerPending = false;
let validateWarnings: unknown[] = [];

vi.mock("@/lib/api", async () => {
  const actual = await vi.importActual<typeof import("@/lib/api")>("@/lib/api");
  return {
    ...actual,
    // No base-model pre-fill: the form keeps its own values.
    useGetRunDefaults: () => ({ data: undefined, isLoading: false, isError: false }),
    useGetBusinessSuspense: () => ({ data: { id: "biz-1", name: "Acme Corp", description: "An example" } }),
    useListVersionsSuspense: () => ({ data: VERSIONS }),
    useGetExplorerVersions: () =>
      explorerPending ? { data: undefined, isPending: true } : { data: explorerRows },
    useListVibeInputs: () => ({
      data: [{
        id: "vi-1", text: "keep ids", priority: "medium", anchor: { level: "model_wide", path: [] },
        consumed: false, selected_for_run: true,
      }],
    }),
    validateRun: vi.fn(async () => ({ data: { blockers: [], warnings: validateWarnings } })),
    createRun: vi.fn(),
  };
});

vi.mock("@/components/ui/markdown-toolbar", () => ({ MarkdownToolbar: () => null }));
vi.mock("@/components/runs/deployment-catalog-picker", () => ({
  DeploymentCatalogPicker: ({ value }: { value: string }) => (
    <input data-testid="catalog-picker" value={value} readOnly />
  ),
}));

beforeEach(() => {
  explorerPending = false;
  validateWarnings = [];
  explorerRows = [
    { id: "v-1-mvm", is_base: true },
    { id: "v-1-ecm", is_base: true },
    { id: "v-2-mvm", is_base: false },
    { id: "v-2-ecm", is_base: false },
  ];
});

afterEach(() => vi.restoreAllMocks());

async function renderRunsNew(search: string) {
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
    routeTree: rootRoute.addChildren([sidebarRoute.addChildren([runsNewClone]), explorerRoute]),
    history: createMemoryHistory({ initialEntries: [`/businesses/biz-1/runs/new${search}`] }),
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

function baseVersionSelect(): HTMLSelectElement | undefined {
  return Array.from(document.querySelectorAll("select")).find((s) =>
    Array.from(s.options).some((o) => /v\d+\s+(ECM|MVM)/i.test(o.textContent || "")),
  );
}

function optionLabels(): string[] {
  return Array.from(baseVersionSelect()?.options ?? []).map((o) => (o.textContent ?? "").trim());
}

function selectedLabel(): string {
  const sel = baseVersionSelect();
  return sel ? (sel.options[sel.selectedIndex]?.textContent ?? "").trim() : "";
}

warmImports(() => import("@/routes/_sidebar/businesses.$businessId.runs.new"));

describe("Runs/new - Base Version picker for Vibe Modeling", () => {
  it("offers finished versions with the superseded ones labelled, and no draft or generating version", async () => {
    await renderRunsNew("?operationType=vibe-iterate");

    await waitFor(() => {
      expect(optionLabels().length).toBeGreaterThan(0);
    });
    expect(optionLabels()).toEqual([
      "v2 MVM (vibed)",
      "v2 ECM (vibed)",
      "v1 MVM (superseded)",
      "v1 ECM (superseded) (Replaced by v2)",
    ]);
  });

  it("defaults to the freshest completed version", async () => {
    await renderRunsNew("?operationType=vibe-iterate");

    await waitFor(() => {
      expect(selectedLabel()).toMatch(/^v2 MVM\b/);
    });
    expect(screen.queryByTestId("base-deep-link-notice")).not.toBeInTheDocument();
  });

  it("selects a superseded version named by the link, with no notice", async () => {
    await renderRunsNew("?operationType=vibe-iterate&sourceVersion=1&sourceScope=ecm");

    await waitFor(() => {
      expect(selectedLabel()).toBe("v1 ECM (superseded) (Replaced by v2)");
    });
    expect(screen.queryByTestId("base-deep-link-notice")).not.toBeInTheDocument();
  });

  it("says so when the link names a Dry Run draft, and which version it selected instead", async () => {
    await renderRunsNew("?operationType=vibe-iterate&sourceVersion=3&sourceScope=mvm");

    const notice = await screen.findByTestId("base-deep-link-notice");
    expect(notice.textContent).toBe(
      "The link points to v3 MVM, which is a Dry Run draft. v2 MVM is selected instead.",
    );
    expect(selectedLabel()).toMatch(/^v2 MVM\b/);
  });

  it("says so when the link names a version that does not exist", async () => {
    await renderRunsNew("?operationType=vibe-iterate&sourceVersion=9&sourceScope=ecm");

    const notice = await screen.findByTestId("base-deep-link-notice");
    expect(notice.textContent).toMatch(/^The link points to v9 ECM, which does not exist\. v2 MVM is selected instead\.$/);
  });

  it("says so when Vibe ECM + MVM is linked to an MVM, which it cannot use", async () => {
    await renderRunsNew("?operationType=vibe-new-ecm-mvm&sourceVersion=2&sourceScope=mvm");

    const notice = await screen.findByTestId("base-deep-link-notice");
    expect(notice.textContent).toBe(
      "The link points to v2 MVM, which is not an ECM; this run needs an ECM as its base. v2 ECM is selected instead.",
    );
    await waitFor(() => {
      expect(selectedLabel()).toMatch(/^v2 ECM\b/);
    });
    expect(optionLabels().every((l) => /ECM/.test(l))).toBe(true);
  });

  it("offers a superseded ECM to Vibe ECM + MVM, and never selects one by default", async () => {
    await renderRunsNew("?operationType=vibe-new-ecm-mvm");

    await waitFor(() => {
      expect(optionLabels()).toEqual(["v2 ECM (vibed)", "v1 ECM (superseded) (Replaced by v2)"]);
    });
    expect(selectedLabel()).toMatch(/^v2 ECM\b/);
  });
});

describe("Runs/new - (vibed) follows the brand", () => {
  it("does not call a base version vibed because it carries run instructions", async () => {
    await renderRunsNew("?operationType=vibe-iterate&sourceVersion=1&sourceScope=mvm");

    await waitFor(() => {
      expect(selectedLabel()).toBe("v1 MVM (superseded)");
    });
    expect(selectedLabel()).not.toMatch(/vibed/);
  });

  it("calls a vibe-produced version vibed even when its instructions are empty", async () => {
    await renderRunsNew("?operationType=vibe-iterate");

    await waitFor(() => {
      expect(selectedLabel()).toBe("v2 MVM (vibed)");
    });
  });

  it("shows no brand text while the explorer list has not answered", async () => {
    explorerRows = [];
    await renderRunsNew("?operationType=vibe-iterate");

    await waitFor(() => {
      expect(optionLabels()).toContain("v2 MVM");
    });
    expect(optionLabels().some((l) => /vibed/.test(l))).toBe(false);
  });
});

describe("Runs/new - labels while the explorer list is pending", () => {
  it("shows no vibed text and leaves Start Run enabled", async () => {
    explorerPending = true;
    await renderRunsNew("?operationType=vibe-iterate");

    const trigger = await waitFor(() => {
      const t = screen
        .queryAllByRole("combobox", { hidden: true })
        .find((c) => /v\d+\s+(ECM|MVM)/.test(c.textContent || ""));
      expect(t).toBeTruthy();
      return t as HTMLElement;
    });
    fireEvent.click(trigger);
    const labels = () =>
      Array.from(document.querySelectorAll('[role="listbox"] [role="option"]'))
        .map((o) => (o.textContent ?? "").trim())
        .filter((t) => /^v\d+\s+(ECM|MVM)/.test(t));
    await waitFor(() => expect(labels().length).toBe(4));
    expect(labels()).toEqual([
      "v2 MVM",
      "v2 ECM",
      "v1 MVM (superseded)",
      "v1 ECM (superseded) (Replaced by v2)",
    ]);
    expect(document.body.textContent).not.toMatch(/vibed/i);
    expect(screen.getByRole("button", { name: /^Start Run$/i, hidden: true })).not.toBeDisabled();
  });
});

describe("Runs/new - older base warning", () => {
  it("renders the server's base_version warning with the other validate warnings", async () => {
    validateWarnings = [{
      field_path: "base_version",
      step_index: -1,
      severity: "warning",
      message: "v2 is installed in my_catalog. This Full Run builds from v1, drops v2's tables and leaves v2's changes out of the new version.",
    }];
    await renderRunsNew("?operationType=vibe-iterate&runMode=full&sourceVersion=1&sourceScope=mvm");

    const box = await screen.findByTestId("validate-warnings");
    expect(box.textContent).toContain("builds from v1, drops v2's tables and leaves v2's changes out of the new version.");
    expect(screen.getByRole("button", { name: /^Start Run$/i, hidden: true })).not.toBeDisabled();
  });
});
