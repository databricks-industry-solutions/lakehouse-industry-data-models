/**
 * New Run page - scope pre-filled from the selected feedback (design §8) and the
 * catalog pre-filled from the version's install target.
 *
 * The compose surface sends `scopeDomains` with `scopeFrom=feedback`
 * (compose-surface.test.tsx). The form opens on Some domains with a banner and
 * notes, falls back to All domains when the base is not the latest version, and
 * on All domains offers "Scope to ..." for a selection that fits in a scope.
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

const MVM_V2: Record<string, unknown> = {
  id: "v-2-mvm",
  version: 2,
  scope: "mvm",
  status: "completed",
  is_base: false,
  confidence_score: null,
  vibe_instructions: "",
  created_at: "2026-04-21T12:00:00Z",
  uc_catalog: "utility_cat",
  files_catalog: "utility_cat",
  deployment_status: "deployed",
  is_head: true,
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
    { id: "d-3", name: "metering" },
    { id: "", name: "deleted_placeholder" },
  ],
};

let versionsData: Record<string, unknown>[] = [MVM_V2];
let compileResponse: Record<string, unknown> = {};
let unscopedResponse: Record<string, unknown> = {};
let validateBlockers: unknown[] = [];

const createRunMock = vi.fn(async (..._args: unknown[]) => ({ data: { id: "run-new" } }));
const validateRunMock = vi.fn(async (..._args: unknown[]) => ({
  data: { blockers: validateBlockers, warnings: [] },
}));
const summaryEnabled: boolean[] = [];
let compileHold: Promise<void> | null = null;
let heldVersionId = "";
const compileMock = vi.fn(async (...args: unknown[]) => {
  const params = args[0] as { version_id: string };
  const body = args[1] as { vibe_scope_domains?: string[] };
  if (compileHold && params.version_id === heldVersionId) await compileHold;
  return { data: body.vibe_scope_domains ? compileResponse : unscopedResponse };
});

vi.mock("@/lib/api", async () => {
  const actual = await vi.importActual<typeof import("@/lib/api")>("@/lib/api");
  return {
    ...actual,
    // No base-model pre-fill: the form keeps its own values.
    useGetRunDefaults: () => ({ data: undefined, isLoading: false, isError: false }),
    useGetBusinessSuspense: () => ({
      data: { id: "biz-1", name: "Acme Utility", description: "Utility blurb." },
    }),
    useListVersionsSuspense: () => ({ data: versionsData }),
    useListVibeInputs: (opts: any) => ({
      data: opts?.query?.select ? opts.query.select({ data: VIBE_INPUTS }) : VIBE_INPUTS,
    }),
    useGetCatalogSchemaWarning: () => ({ data: undefined }),
    useGetModelSummary: (opts: any) => {
      summaryEnabled.push(opts?.query?.enabled !== false);
      return {
        data:
          opts?.query?.enabled === false
            ? undefined
            : opts?.query?.select
              ? opts.query.select({ data: MODEL_SUMMARY })
              : MODEL_SUMMARY,
      };
    },
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


function lastBody(mock: typeof createRunMock): Record<string, unknown> {
  const calls = mock.mock.calls;
  return ((calls[calls.length - 1] as unknown[])?.[1] ?? {}) as Record<string, unknown>;
}

async function launch() {
  const startBtn = screen.getByRole("button", { name: /^Start Run$/i });
  await waitFor(() => expect(startBtn).not.toBeDisabled());
  await act(async () => fireEvent.click(startBtn));
  await waitFor(() => {
    expect(screen.queryByRole("button", { name: /^Launch$/i })).not.toBeNull();
  });
}

const DEEP_LINK =
  "?operationType=vibe-iterate&sourceVersion=2&sourceScope=mvm&scopeDomains=meter_to_cash&runMode=dry";

const FEEDBACK_LINK =
  "?operationType=vibe-iterate&sourceVersion=2&sourceScope=mvm&scopeDomains=meter_to_cash&scopeFrom=feedback";
const PLAIN_LINK = "?operationType=vibe-iterate&sourceVersion=2&sourceScope=mvm";
const MVM_V4 = { ...MVM_V2, id: "v-4-mvm", version: 4 };

const BANNER_TEXT =
  "Scope pre-filled from your 3 selected feedback items: meter_to_cash. Change it below.";

warmImports(() => import("@/routes/_sidebar/businesses.$businessId.runs.new"));

describe("New Run page - scope pre-filled from the feedback", () => {
  beforeEach(() => {
    versionsData = [MVM_V2];
    summaryEnabled.length = 0;
    compileHold = null;
    compileResponse = {
      markdown: "",
      agent_markdown: "",
      blocks: [],
      included_input_ids: ["vi-1"],
      excluded_input_ids: ["vi-2", "vi-3"],
      excluded_reasons: { "vi-2": "out_of_scope", "vi-3": "model_wide_in_scoped_run" },
    };
    unscopedResponse = {
      included_input_ids: ["vi-1", "vi-2", "vi-3"],
      excluded_input_ids: [],
      excluded_reasons: {},
      input_scope_domains: { "vi-1": "meter_to_cash", "vi-2": "billing", "vi-3": null },
    };
    validateBlockers = [];
    createRunMock.mockClear();
    validateRunMock.mockClear();
    compileMock.mockClear();
  });
  afterEach(() => vi.restoreAllMocks());

  it("opens on Some domains with the feedback's domains ticked and a banner naming the source", async () => {
    await renderRunsNew(FEEDBACK_LINK);
    await waitFor(() => expect(screen.getByTestId("vibe-scope-control")).toBeInTheDocument());
    expect(screen.getByRole("radio", { name: "Some domains" })).toHaveAttribute("aria-checked", "true");
    expect(screen.getByRole("checkbox", { name: "meter_to_cash" })).toBeChecked();
    expect(screen.getByRole("checkbox", { name: "billing" })).not.toBeChecked();
    expect(screen.getByTestId("scope-prefill-banner")).toHaveTextContent(BANNER_TEXT);
  });

  it("notes the model-wide items a scoped run does not send, from the scoped preview", async () => {
    await renderRunsNew(FEEDBACK_LINK);
    const note = await screen.findByTestId("scope-model-wide-note");
    expect(note).toHaveTextContent(
      "1 selected item is model-wide and is not sent in a scoped run. Switch to All domains to include it.",
    );
  });

  it("drops the banner once the scope is edited, and keeps the model-wide note", async () => {
    await renderRunsNew(FEEDBACK_LINK);
    await screen.findByTestId("scope-prefill-banner");
    await screen.findByTestId("scope-model-wide-note");
    fireEvent.click(screen.getByRole("checkbox", { name: "billing" }));
    expect(screen.queryByTestId("scope-prefill-banner")).toBeNull();
    expect(screen.getByRole("checkbox", { name: "billing" })).toBeChecked();
    expect(screen.getByTestId("scope-model-wide-note")).toBeInTheDocument();
  });

  it("drops the banner and the model-wide note on switching to All domains", async () => {
    await renderRunsNew(FEEDBACK_LINK);
    await screen.findByTestId("scope-prefill-banner");
    fireEvent.click(screen.getByRole("radio", { name: "All domains" }));
    expect(screen.queryByTestId("scope-prefill-banner")).toBeNull();
    await waitFor(() => expect(screen.queryByTestId("scope-model-wide-note")).toBeNull());
  });

  it("updates the preview live when the pre-filled scope is edited", async () => {
    await renderRunsNew(FEEDBACK_LINK);
    await waitFor(() => expect(compileMock).toHaveBeenCalled());
    compileMock.mockClear();
    fireEvent.click(screen.getByRole("checkbox", { name: "billing" }));
    await waitFor(() =>
      expect(compileMock).toHaveBeenCalledWith(
        { business_id: "biz-1", version_id: "v-2-mvm" },
        { input_ids: ["vi-1", "vi-2", "vi-3"], vibe_scope_domains: ["meter_to_cash", "billing"] },
        expect.anything(),
      ),
    );
  });

  it("sends the pre-filled scope in the run body", async () => {
    await renderRunsNew(FEEDBACK_LINK);
    await screen.findByTestId("scope-prefill-banner");
    await launch();
    await act(async () => fireEvent.click(screen.getByRole("button", { name: /^Launch$/i })));
    await waitFor(() => expect(createRunMock).toHaveBeenCalledTimes(1));
    const body = lastBody(createRunMock);
    expect(body.vibe_scope).toBe("some_domains");
    expect(body.vibe_scope_domains).toEqual(["meter_to_cash"]);
    expect(body.dry_run).toBe(true);
  });

  it("opens on All domains with a note when the base is not the latest version", async () => {
    versionsData = [MVM_V4, { ...MVM_V2, is_head: false }];
    await renderRunsNew(FEEDBACK_LINK);
    await waitFor(() => expect(screen.getByTestId("vibe-scope-control")).toBeInTheDocument());
    expect(screen.getByRole("radio", { name: "All domains" })).toHaveAttribute("aria-checked", "true");
    expect(screen.queryByTestId("scope-prefill-banner")).toBeNull();
    expect(screen.getByTestId("scope-latest-note")).toHaveTextContent(
      "Scoped runs need the latest version (v4).",
    );
    expect(screen.queryByTestId("scope-hint")).toBeNull();
    await act(async () => {});
    expect(compileMock).not.toHaveBeenCalled();
    expect(summaryEnabled).not.toContain(true);
  });

  it("does not show the previous base's model-wide count after the base is switched", async () => {
    const ECM_V3 = { ...MVM_V2, id: "v-3-ecm", version: 3, scope: "ecm" };
    versionsData = [ECM_V3, MVM_V2];
    let release: () => void = () => {};
    compileHold = new Promise<void>((r) => (release = r));
    heldVersionId = "v-3-ecm";
    await renderRunsNew(FEEDBACK_LINK);
    await screen.findByTestId("scope-model-wide-note");
    const baseSelect = Array.from(document.querySelectorAll("select")).find((el) =>
      Array.from(el.options).some((o) => o.value === "v-3-ecm"),
    )!;
    fireEvent.change(baseSelect, { target: { value: "v-3-ecm" } });
    await waitFor(() =>
      expect(compileMock).toHaveBeenCalledWith(
        { business_id: "biz-1", version_id: "v-3-ecm" },
        expect.objectContaining({ vibe_scope_domains: ["meter_to_cash"] }),
        expect.anything(),
      ),
    );
    expect(screen.queryByTestId("scope-model-wide-note")).toBeNull();
    compileResponse = {
      ...compileResponse,
      excluded_reasons: { "vi-1": "model_wide_in_scoped_run", "vi-3": "model_wide_in_scoped_run" },
    };
    release();
    expect(await screen.findByTestId("scope-model-wide-note")).toHaveTextContent(
      "2 selected items are model-wide",
    );
  });

  it("opens on Some domains when the base is the latest of a version that has a newer other scope", async () => {
    versionsData = [{ ...MVM_V4, scope: "ecm", id: "v-4-ecm" }, MVM_V2];
    await renderRunsNew(FEEDBACK_LINK);
    await screen.findByTestId("scope-prefill-banner");
    expect(screen.getByRole("radio", { name: "Some domains" })).toHaveAttribute("aria-checked", "true");
    expect(screen.queryByTestId("scope-latest-note")).toBeNull();
  });

  it("a deep link without scopeFrom keeps its scope and shows no feedback banner or notes", async () => {
    await renderRunsNew(DEEP_LINK);
    await waitFor(() => expect(screen.getByTestId("vibe-scope-control")).toBeInTheDocument());
    expect(screen.getByRole("radio", { name: "Some domains" })).toHaveAttribute("aria-checked", "true");
    await waitFor(() => expect(compileMock).toHaveBeenCalled());
    expect(screen.queryByTestId("scope-prefill-banner")).toBeNull();
    expect(screen.queryByTestId("scope-model-wide-note")).toBeNull();
    expect(screen.queryByTestId("scope-latest-note")).toBeNull();
  });

  it("scopeFrom without domains opens on All domains with no banner", async () => {
    await renderRunsNew(`${PLAIN_LINK}&scopeFrom=feedback`);
    await waitFor(() => expect(screen.getByTestId("vibe-scope-control")).toBeInTheDocument());
    expect(screen.getByRole("radio", { name: "All domains" })).toHaveAttribute("aria-checked", "true");
    expect(screen.queryByTestId("scope-prefill-banner")).toBeNull();
    expect(screen.queryByTestId("scope-latest-note")).toBeNull();
  });
});

describe("New Run page - Scope to ... hint", () => {
  beforeEach(() => {
    versionsData = [MVM_V2];
    summaryEnabled.length = 0;
    compileHold = null;
    compileResponse = { included_input_ids: [], excluded_input_ids: [], excluded_reasons: {} };
    unscopedResponse = {
      included_input_ids: ["vi-1", "vi-2", "vi-3"],
      excluded_input_ids: [],
      excluded_reasons: {},
      input_scope_domains: { "vi-1": "meter_to_cash", "vi-2": null, "vi-3": null },
    };
    validateBlockers = [];
    createRunMock.mockClear();
    validateRunMock.mockClear();
    compileMock.mockClear();
  });
  afterEach(() => vi.restoreAllMocks());

  it("offers to scope a plain All domains form to the selection's domains, and applies it", async () => {
    await renderRunsNew(PLAIN_LINK);
    const hint = await screen.findByTestId("scope-hint");
    expect(hint).toHaveTextContent("Scope to meter_to_cash");
    expect(hint).toHaveClass("text-primary", "hover:underline");
    expect(hint.className).not.toMatch(/hover:(opacity|text-|bg-)/);
    expect(compileMock).toHaveBeenCalledWith(
      { business_id: "biz-1", version_id: "v-2-mvm" },
      { input_ids: ["vi-1", "vi-2", "vi-3"] },
    );
    fireEvent.click(hint);
    expect(screen.getByRole("radio", { name: "Some domains" })).toHaveAttribute("aria-checked", "true");
    expect(screen.getByRole("checkbox", { name: "meter_to_cash" })).toBeChecked();
    expect(screen.getByRole("checkbox", { name: "billing" })).not.toBeChecked();
    expect(screen.queryByTestId("scope-hint")).toBeNull();
    expect(screen.queryByTestId("scope-prefill-banner")).toBeNull();
  });

  it("names every domain of the selection", async () => {
    unscopedResponse = {
      ...unscopedResponse,
      input_scope_domains: { "vi-1": "meter_to_cash", "vi-2": "Billing", "vi-3": null },
    };
    await renderRunsNew(PLAIN_LINK);
    expect(await screen.findByTestId("scope-hint")).toHaveTextContent("Scope to meter_to_cash, billing");
  });

  it("offers nothing when the selection covers every domain of the base", async () => {
    unscopedResponse = {
      ...unscopedResponse,
      input_scope_domains: { "vi-1": "meter_to_cash", "vi-2": "billing", "vi-3": "Metering" },
    };
    await renderRunsNew(PLAIN_LINK);
    await waitFor(() => expect(compileMock).toHaveBeenCalled());
    await waitFor(() => expect(screen.getByTestId("vibe-scope-control")).toBeInTheDocument());
    await act(async () => {});
    expect(screen.queryByTestId("scope-hint")).toBeNull();
  });

  it("offers nothing when no selected item has a domain", async () => {
    unscopedResponse = {
      ...unscopedResponse,
      input_scope_domains: { "vi-1": null, "vi-2": null, "vi-3": null },
    };
    await renderRunsNew(PLAIN_LINK);
    await waitFor(() => expect(compileMock).toHaveBeenCalled());
    await act(async () => {});
    expect(screen.queryByTestId("scope-hint")).toBeNull();
  });

  it("offers nothing when the base is not the latest version, and fetches nothing for it", async () => {
    versionsData = [MVM_V4, { ...MVM_V2, is_head: false }];
    summaryEnabled.length = 0;
    await renderRunsNew(PLAIN_LINK);
    await waitFor(() => expect(screen.getByTestId("vibe-scope-control")).toBeInTheDocument());
    await act(async () => {});
    expect(screen.queryByTestId("scope-hint")).toBeNull();
    expect(compileMock).not.toHaveBeenCalled();
    expect(summaryEnabled).not.toContain(true);
  });

  it("fetches the compile and the base summary for a base at the head", async () => {
    summaryEnabled.length = 0;
    await renderRunsNew(PLAIN_LINK);
    await screen.findByTestId("scope-hint");
    expect(compileMock).toHaveBeenCalledTimes(1);
    expect(summaryEnabled).toContain(true);
  });
});

describe("New Run page - catalog pre-fill", () => {
  const draft = (over: Record<string, unknown>) => ({
    ...MVM_V2,
    id: "v-3-mvm",
    version: 3,
    ...over,
  });
  const catalogOf = async () => {
    await renderRunsNew("?operationType=vibe-iterate");
    return ((await screen.findByTestId("catalog-picker")) as HTMLInputElement).value;
  };

  beforeEach(() => {
    compileResponse = { included_input_ids: [], excluded_input_ids: [], excluded_reasons: {} };
    unscopedResponse = { input_scope_domains: {} };
    validateBlockers = [];
  });

  it("a Dry Run draft or kickstart (no install catalog) takes its files catalog", async () => {
    versionsData = [
      draft({ status: "completed", deployment_status: "draft", uc_catalog: "", files_catalog: "home_cat" }),
      MVM_V2,
    ];
    expect(await catalogOf()).toBe("home_cat");
  });

  it("a version installed in another catalog takes the install catalog, not its files", async () => {
    versionsData = [
      draft({ deployment_status: "deployed", uc_catalog: "other_cat", files_catalog: "home_cat" }),
    ];
    expect(await catalogOf()).toBe("other_cat");
  });

  it("a version installed in two catalogs takes the latest install (uc_catalog)", async () => {
    versionsData = [
      draft({ deployment_status: "deployed", uc_catalog: "third_cat", files_catalog: "home_cat" }),
    ];
    expect(await catalogOf()).toBe("third_cat");
  });

  it("an uninstalled version takes its files catalog, not its last install location", async () => {
    versionsData = [
      draft({ deployment_status: "uninstalled", uc_catalog: "other_cat", files_catalog: "home_cat" }),
    ];
    expect(await catalogOf()).toBe("home_cat");
  });

  it("is empty when nothing is recorded", async () => {
    versionsData = [draft({ deployment_status: "draft", uc_catalog: "", files_catalog: null })];
    expect(await catalogOf()).toBe("");
  });
});
