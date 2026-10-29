/**
 * New Run page — vibe scope + Dry Run (design §9.1, D15).
 *
 * Covers the deep link (`scopeDomains`, `runMode`), the scope control state,
 * the server-compiled scoped preview with its excluded list, the
 * validate/create bodies (`vibe_scope`, `vibe_scope_domains`, `dry_run`, no
 * `business_domains` when scoped), unknown-name chips, and the
 * included-count-0 submit block.
 */
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";
import { warmImports } from "./helpers/warm-imports";
import { act, fireEvent, render, screen, waitFor, within } from "@testing-library/react";
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

let compileResponse: Record<string, unknown> = {};
let validateBlockers: unknown[] = [];

const createRunMock = vi.fn(async (..._args: unknown[]) => ({ data: { id: "run-new" } }));
const validateRunMock = vi.fn(async (..._args: unknown[]) => ({
  data: { blockers: validateBlockers, warnings: [] },
}));
const compileMock = vi.fn(async (..._args: unknown[]) => ({ data: compileResponse }));

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

const DEEP_LINK =
  "?operationType=vibe-iterate&sourceVersion=2&sourceScope=mvm&scopeDomains=meter_to_cash&runMode=dry";

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

warmImports(() => import("@/routes/_sidebar/businesses.$businessId.runs.new"));

describe("New Run page — vibe scope", () => {
  beforeEach(() => {
    compileResponse = {
      markdown: "## Domain: meter_to_cash\n- (high) Add a due date to invoices",
      agent_markdown: "",
      blocks: [],
      included_input_ids: ["vi-1"],
      excluded_input_ids: ["vi-2", "vi-3"],
      excluded_reasons: { "vi-2": "out_of_scope", "vi-3": "model_wide_in_scoped_run" },
    };
    validateBlockers = [];
    createRunMock.mockClear();
    validateRunMock.mockClear();
    compileMock.mockClear();
  });
  afterEach(() => vi.restoreAllMocks());

  it("pre-fills Some domains, the linked domain and Dry Run from the deep link", async () => {
    await renderRunsNew(DEEP_LINK);
    await waitFor(() => expect(screen.getByTestId("vibe-scope-control")).toBeInTheDocument());
    expect(screen.getByRole("radio", { name: "Some domains" })).toHaveAttribute("aria-checked", "true");
    expect(screen.getByRole("checkbox", { name: "meter_to_cash" })).toBeChecked();
    expect(screen.getByRole("checkbox", { name: "billing" })).not.toBeChecked();
    // The deleted placeholder (id "") is not offered.
    expect(screen.queryByRole("checkbox", { name: "deleted_placeholder" })).toBeNull();
    expect(screen.getByRole("radio", { name: "Dry Run" })).toHaveAttribute("aria-checked", "true");
  });

  it("defaults to All domains + Dry Run without scopeDomains, sending only dry_run", async () => {
    await renderRunsNew("?operationType=vibe-iterate");
    await waitFor(() => expect(screen.getByTestId("vibe-scope-control")).toBeInTheDocument());
    expect(screen.getByRole("radio", { name: "All domains" })).toHaveAttribute("aria-checked", "true");
    expect(screen.getByRole("radio", { name: "Dry Run" })).toHaveAttribute("aria-checked", "true");
    expect(screen.getByRole("radio", { name: "Full Run" })).toHaveAttribute("aria-checked", "false");
    expect(screen.getByTestId("compiled-preview-count")).toHaveTextContent("3 selected");
    await waitFor(() => expect(validateRunMock).toHaveBeenCalled());
    const validateBody = (validateRunMock.mock.calls[validateRunMock.mock.calls.length - 1] as unknown[])[1] as
      Record<string, unknown>;
    expect(validateBody.dry_run).toBe(true);
    expect(validateBody).not.toHaveProperty("vibe_scope");
    expect(validateBody).not.toHaveProperty("vibe_scope_domains");
    await launch();
    await act(async () => fireEvent.click(screen.getByRole("button", { name: /^Launch$/i })));
    await waitFor(() => expect(createRunMock).toHaveBeenCalledTimes(1));
    const body = lastBody(createRunMock);
    expect(body.dry_run).toBe(true);
    expect(body).not.toHaveProperty("vibe_scope");
    expect(body).not.toHaveProperty("vibe_scope_domains");
    // An unscoped run keeps the FE preview. The only compile call is the one
    // for the "Scope to ..." hint, and it sends no scope.
    for (const call of compileMock.mock.calls) {
      expect((call as unknown[])[1]).toEqual({ input_ids: ["vi-1", "vi-2", "vi-3"] });
    }
  });

  it("an unscoped Full Run chosen by the user sends the pre-scope body", async () => {
    await renderRunsNew("?operationType=vibe-iterate");
    await waitFor(() => expect(screen.getByTestId("vibe-scope-control")).toBeInTheDocument());
    fireEvent.click(screen.getByRole("radio", { name: "Full Run" }));
    expect(screen.getByRole("radio", { name: "Full Run" })).toHaveAttribute("aria-checked", "true");
    await waitFor(() => expect(validateRunMock).toHaveBeenCalled());
    await waitFor(() => {
      const last = (validateRunMock.mock.calls[validateRunMock.mock.calls.length - 1] as unknown[])[1] as
        Record<string, unknown>;
      expect(last).not.toHaveProperty("dry_run");
    });
    await launch();
    await act(async () => fireEvent.click(screen.getByRole("button", { name: /^Launch$/i })));
    await waitFor(() => expect(createRunMock).toHaveBeenCalledTimes(1));
    const body = lastBody(createRunMock);
    for (const key of ["vibe_scope", "vibe_scope_domains", "dry_run"]) {
      expect(body).not.toHaveProperty(key);
    }
  });

  it("starts on All domains + Dry Run when scopeDomains parses to an empty list", async () => {
    await renderRunsNew("?operationType=vibe-iterate&scopeDomains=%2C%20%2C");
    await waitFor(() => expect(screen.getByTestId("vibe-scope-control")).toBeInTheDocument());
    expect(screen.getByRole("radio", { name: "All domains" })).toHaveAttribute("aria-checked", "true");
    expect(screen.getByRole("radio", { name: "Dry Run" })).toHaveAttribute("aria-checked", "true");
    expect(screen.queryByTestId("vibe-scope-domains")).toBeNull();
  });

  it("is Dry Run for either scope until the user picks one", async () => {
    await renderRunsNew("?operationType=vibe-iterate");
    await waitFor(() => expect(screen.getByTestId("vibe-scope-control")).toBeInTheDocument());
    expect(screen.getByRole("radio", { name: "Dry Run" })).toHaveAttribute("aria-checked", "true");
    fireEvent.click(screen.getByRole("radio", { name: "Some domains" }));
    expect(screen.getByRole("radio", { name: "Dry Run" })).toHaveAttribute("aria-checked", "true");
    fireEvent.click(screen.getByRole("radio", { name: "All domains" }));
    expect(screen.getByRole("radio", { name: "Dry Run" })).toHaveAttribute("aria-checked", "true");

    // An explicit Full Run sticks across scope toggles.
    fireEvent.click(screen.getByRole("radio", { name: "Full Run" }));
    fireEvent.click(screen.getByRole("radio", { name: "Some domains" }));
    expect(screen.getByRole("radio", { name: "Full Run" })).toHaveAttribute("aria-checked", "true");
    fireEvent.click(screen.getByRole("radio", { name: "All domains" }));
    expect(screen.getByRole("radio", { name: "Full Run" })).toHaveAttribute("aria-checked", "true");
  });

  it("treats a runMode deep link as an explicit choice", async () => {
    // Scoped link with runMode=full stays Full Run.
    const scoped = await renderRunsNew(DEEP_LINK.replace("runMode=dry", "runMode=full"));
    await waitFor(() => expect(screen.getByTestId("vibe-scope-control")).toBeInTheDocument());
    expect(screen.getByRole("radio", { name: "Full Run" })).toHaveAttribute("aria-checked", "true");
    fireEvent.click(screen.getByRole("radio", { name: "All domains" }));
    fireEvent.click(screen.getByRole("radio", { name: "Some domains" }));
    expect(screen.getByRole("radio", { name: "Full Run" })).toHaveAttribute("aria-checked", "true");
    scoped.unmount();

    // Unscoped link with runMode=dry: Dry Run, body sends only dry_run.
    await renderRunsNew("?operationType=vibe-iterate&runMode=dry");
    await waitFor(() => expect(screen.getByTestId("vibe-scope-control")).toBeInTheDocument());
    expect(screen.getByRole("radio", { name: "All domains" })).toHaveAttribute("aria-checked", "true");
    expect(screen.getByRole("radio", { name: "Dry Run" })).toHaveAttribute("aria-checked", "true");
    expect(screen.getByTestId("vibe-run-mode-consequence")).toHaveTextContent(
      /deploys no tables/,
    );
    await launch();
    await act(async () => fireEvent.click(screen.getByRole("button", { name: /^Launch$/i })));
    await waitFor(() => expect(createRunMock).toHaveBeenCalledTimes(1));
    const body = lastBody(createRunMock);
    expect(body.dry_run).toBe(true);
    expect(body).not.toHaveProperty("vibe_scope");
    expect(body).not.toHaveProperty("vibe_scope_domains");
  });

  it("compiles the preview with the scope and lists the excluded items with reasons", async () => {
    await renderRunsNew(DEEP_LINK);
    await waitFor(() => expect(compileMock).toHaveBeenCalled());
    const [params, data] = compileMock.mock.calls[compileMock.mock.calls.length - 1] as unknown[];
    expect(params).toEqual({ business_id: "biz-1", version_id: "v-2-mvm" });
    expect(data).toEqual({ input_ids: ["vi-1", "vi-2", "vi-3"], vibe_scope_domains: ["meter_to_cash"] });

    await waitFor(() => expect(screen.getByTestId("vibe-scope-excluded")).toBeInTheDocument());
    expect(screen.getByTestId("compiled-preview-count")).toHaveTextContent("1 selected");
    const items = screen.getAllByTestId("vibe-scope-excluded-item");
    expect(items).toHaveLength(2);
    expect(items[0]).toHaveTextContent("Not sent (other domain)");
    expect(items[0]).toHaveTextContent("Domain: billing");
    expect(items[1]).toHaveTextContent("Not sent (model-wide)");
    expect(screen.getByTestId("vibe-inputs-summary")).toHaveTextContent("1 in scope");
  });

  it("sends vibe_scope, vibe_scope_domains and dry_run on validate and create, without business_domains", async () => {
    await renderRunsNew("?operationType=vibe-iterate");
    await waitFor(() => expect(screen.getByTestId("vibe-scope-control")).toBeInTheDocument());

    // A vibe iteration has no seed-domain field, scoped or not.
    fireEvent.click(screen.getByRole("button", { name: /Advanced Options/ }));
    expect(screen.queryByText("Business Domains")).toBeNull();

    fireEvent.click(screen.getByRole("radio", { name: "Some domains" }));
    fireEvent.click(screen.getByRole("checkbox", { name: "meter_to_cash" }));

    await waitFor(() => {
      const body = (validateRunMock.mock.calls[validateRunMock.mock.calls.length - 1] as unknown[])?.[1] as
        | Record<string, unknown>
        | undefined;
      expect(body?.vibe_scope).toBe("some_domains");
      expect(body?.vibe_scope_domains).toEqual(["meter_to_cash"]);
      expect(body?.dry_run).toBe(true);
    });

    await waitFor(() => expect(screen.getByTestId("vibe-scope-excluded")).toBeInTheDocument());
    await launch();
    const dialog = screen.getByRole("alertdialog");
    expect(within(dialog).getByText("Some domains: meter_to_cash")).toBeInTheDocument();
    expect(within(dialog).getByText("Dry Run")).toBeInTheDocument();
    expect(within(dialog).queryByTestId("full-run-warning")).toBeNull();

    await act(async () => fireEvent.click(screen.getByRole("button", { name: /^Launch$/i })));
    await waitFor(() => expect(createRunMock).toHaveBeenCalledTimes(1));
    const body = lastBody(createRunMock);
    expect(body.intent).toBe("vibe-iterate");
    expect(body.vibe_scope).toBe("some_domains");
    expect(body.vibe_scope_domains).toEqual(["meter_to_cash"]);
    expect(body.dry_run).toBe(true);
    expect(body).not.toHaveProperty("business_domains");
  });

  it("sends dry_run=false and warns with the catalog for a Full Run", async () => {
    await renderRunsNew(DEEP_LINK.replace("runMode=dry", "runMode=full"));
    await waitFor(() => expect(screen.getByTestId("vibe-scope-control")).toBeInTheDocument());
    expect(screen.getByRole("radio", { name: "Full Run" })).toHaveAttribute("aria-checked", "true");
    await waitFor(() => expect(screen.getByTestId("vibe-scope-excluded")).toBeInTheDocument());
    await launch();
    expect(screen.getByTestId("full-run-warning")).toHaveTextContent(/Deploys to utility_cat\./);
    await act(async () => fireEvent.click(screen.getByRole("button", { name: /^Launch$/i })));
    await waitFor(() => expect(createRunMock).toHaveBeenCalledTimes(1));
    expect(lastBody(createRunMock).dry_run).toBe(false);
  });

  it("shows an unknown deep-link name as an error chip with the server's suggestion", async () => {
    validateBlockers = [
      {
        field_path: "vibe_scope_domains",
        message:
          "'meter2cash' is not a domain of v2 MVM. Did you mean: meter_to_cash? The agent would treat it as a new domain and change nothing in the one you meant.",
        severity: "error",
        step_index: 0,
      },
    ];
    await renderRunsNew(DEEP_LINK.replace("scopeDomains=meter_to_cash", "scopeDomains=meter2cash"));
    await waitFor(() => expect(screen.getByTestId("vibe-scope-unknown")).toHaveTextContent(
      "Did you mean: meter_to_cash?",
    ));
    expect(screen.getByRole("checkbox", { name: "meter_to_cash" })).not.toBeChecked();
    expect(screen.getByRole("button", { name: /^Start Run$/i })).toBeDisabled();
  });

  it("blocks submit when the scoped compile includes none of the selected inputs", async () => {
    compileResponse = {
      ...compileResponse,
      included_input_ids: [],
      excluded_input_ids: ["vi-1", "vi-2", "vi-3"],
      excluded_reasons: {
        "vi-1": "out_of_scope",
        "vi-2": "out_of_scope",
        "vi-3": "model_wide_in_scoped_run",
      },
    };
    await renderRunsNew(DEEP_LINK);
    await waitFor(() => expect(screen.getByTestId("vibe-scope-nothing-included")).toBeInTheDocument());
    expect(screen.getByRole("button", { name: /^Start Run$/i })).toBeDisabled();
  });

  it("blocks submit when Some domains has no domain picked", async () => {
    await renderRunsNew("?operationType=vibe-iterate");
    await waitFor(() => expect(screen.getByTestId("vibe-scope-control")).toBeInTheDocument());
    fireEvent.click(screen.getByRole("radio", { name: "Some domains" }));
    expect(screen.getByRole("button", { name: /^Start Run$/i })).toBeDisabled();
  });
});
