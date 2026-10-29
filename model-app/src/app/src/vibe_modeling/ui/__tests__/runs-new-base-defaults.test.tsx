/**
 * New Run form: a vibe's Advanced Options start from the base model
 * (`getRunDefaults`, `lib/run-defaults.ts`).
 *
 *  - Fields show the base's values (the A2 ECM of agent 5.3.3: SCREAMING_CASE,
 *    Int (0/1), dd/MM/yyyy, tag suffix _wt); the ones the agent keeps are
 *    disabled and point to one note. Schema Suffix and Tag Suffix are locked
 *    too, an empty base value included.
 *  - An edit to an unlocked field stands when the base changes; untouched
 *    fields re-fill from the new base.
 *  - A Some domains vibe locks the fields the base leaves empty.
 *  - Start Run waits for the read; an unreadable file and a failed read each
 *    say so.
 *  - The body carries every known field, blanks included; Vibe ECM + MVM
 *    sends the base prefix as its ECM prefix.
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
import type { RunDefaultFieldOut, RunDefaultsOut } from "@/lib/api";

const version = (id: string, n: number, scope: "ecm" | "mvm") => ({
  id,
  version: n,
  scope,
  status: "completed",
  is_base: n === 1,
  confidence_score: null,
  vibe_instructions: "",
  created_at: `2026-04-2${n}T12:00:00Z`,
  uc_catalog: "brew_cat",
  deployment_status: "deployed",
});
const ECM_V2 = version("v-2-ecm", 2, "ecm");
const ECM_V1 = version("v-1-ecm", 1, "ecm");

const VIBE_INPUTS = [
  {
    id: "vi-1",
    text: "Add a due date to invoices",
    priority: "high",
    anchor: { level: "element", domain_name: "brewing", path: ["Domain: brewing"] },
    consumed: false,
    selected_for_run: true,
    status: "active",
  },
];

const locked = (value: string | null, source: RunDefaultFieldOut["source"] = "base_file") => ({
  value,
  source,
  locked: true,
  locked_scoped: true,
});
const open = (value: string, source: RunDefaultFieldOut["source"] = "base_file", lockedScoped = false) => ({
  value,
  source,
  locked: false,
  locked_scoped: lockedScoped,
});

function a2Defaults(id: string, overrides: Record<string, RunDefaultFieldOut> = {}): RunDefaultsOut {
  return {
    base_version_id: id,
    file_read: true,
    fields: {
      naming_convention: locked("SCREAMING_CASE"),
      primary_key_suffix: locked("_id"),
      schema_prefix: locked("ecm_"),
      schema_suffix: locked(""),
      tag_prefix: locked("dbx_"),
      tag_suffix: locked("_wt"),
      table_id_type: locked("BIGINT"),
      boolean_format: locked("Int (0/1)"),
      date_format: locked("dd/MM/yyyy"),
      timestamp_format: locked("yyyy-MM-dd HH:mm:ss"),
      classification_levels: open("", "base_file", true),
      catalog_prefix: open("", "default"),
      catalog_suffix: open("", "default"),
      org_divisions: open("Operations, Business and Corporate", "base_run"),
      housekeeping_columns: open("No", "default"),
      history_tracking_columns: open("No", "default"),
      ...overrides,
    },
  };
}

let DEFAULTS: Record<string, RunDefaultsOut> = {};
let DEFAULTS_STATE: "ready" | "loading" | "error" = "ready";

const createRunMock = vi.fn(async (..._args: unknown[]) => ({ data: { id: "run-new" } }));
const validateRunMock = vi.fn(async (..._args: unknown[]) => ({ data: { blockers: [], warnings: [] } }));
const compileMock = vi.fn(async (..._args: unknown[]) => ({
  data: {
    markdown: "",
    agent_markdown: "",
    blocks: [],
    included_input_ids: ["vi-1"],
    excluded_input_ids: [],
    excluded_reasons: {},
  },
}));

vi.mock("@/lib/api", async () => {
  const actual = await vi.importActual<typeof import("@/lib/api")>("@/lib/api");
  return {
    ...actual,
    useGetBusinessSuspense: () => ({
      data: { id: "biz-1", name: "WT Brewery", description: "A brewery." },
    }),
    useListVersionsSuspense: () => ({ data: [ECM_V2, ECM_V1] }),
    useListVibeInputs: (opts: any) => ({
      data: opts?.query?.select ? opts.query.select({ data: VIBE_INPUTS }) : VIBE_INPUTS,
    }),
    useGetCatalogSchemaWarning: () => ({ data: undefined }),
    useGetAgentConfig: () => ({ data: undefined }),
    useGetModelSummary: (opts: any) => ({
      data:
        opts?.query?.enabled === false
          ? undefined
          : { name: "Brewery", version: 2, domains: [{ id: "d-1", name: "brewing" }] },
    }),
    useGetAgentCompat: () => ({ data: undefined }),
    useGetRunDefaults: (opts: any) => {
      if (opts?.query?.enabled === false) return { data: undefined, isLoading: false, isError: false };
      if (DEFAULTS_STATE === "loading") return { data: undefined, isLoading: true, isError: false };
      if (DEFAULTS_STATE === "error") return { data: undefined, isLoading: false, isError: true };
      const raw = DEFAULTS[opts.params.model_version_id];
      return { data: raw && opts.query.select({ data: raw }), isLoading: false, isError: false };
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
  const { Route: RunsNewRoute } = await import("@/routes/_sidebar/businesses.$businessId.runs.new");
  const rootRoute = createRootRoute({ component: () => <Outlet /> });
  const sidebarRoute = createRoute({ getParentRoute: () => rootRoute, id: "/_sidebar", component: () => <Outlet /> });
  const runsNewClone = createRoute({
    getParentRoute: () => sidebarRoute,
    path: "/businesses/$businessId/runs/new",
    component: RunsNewRoute.options.component as any,
    validateSearch: RunsNewRoute.options.validateSearch as any,
  });
  const stub = (path: string) => createRoute({ getParentRoute: () => rootRoute, path, component: () => <div /> });
  const router = createRouter({
    routeTree: rootRoute.addChildren([
      sidebarRoute.addChildren([runsNewClone]),
      stub("/businesses/$businessId/model/$version/$scope"),
      stub("/businesses/$businessId/model/$version/$scope/inputs"),
      stub("/businesses/$businessId/runs"),
      stub("/settings"),
    ]),
    history: createMemoryHistory({ initialEntries: [`/businesses/biz-1/runs/new${searchString}`] }),
    defaultPendingMs: 0,
  });
  const qc = new QueryClient({ defaultOptions: { queries: { retry: false }, mutations: { retry: false } } });
  return render(
    <QueryClientProvider client={qc}>
      <Suspense fallback={<div data-testid="suspense-fallback" />}>
        <RouterProvider router={router} />
      </Suspense>
    </QueryClientProvider>,
  );
}

async function openAdvanced() {
  await waitFor(() => expect(screen.getByRole("combobox", { name: "Operation Type" })).toBeInTheDocument());
  fireEvent.click(screen.getByRole("button", { name: /Advanced Options/ }));
}

async function pick(name: string | RegExp, value: string) {
  await act(async () => fireEvent.click(screen.getByRole("combobox", { name })));
  await screen.findAllByRole("option");
  await act(async () => fireEvent.click(screen.getByRole("option", { name: value })));
  await waitFor(() => expect(screen.getByRole("combobox", { name })).toHaveTextContent(value));
}

async function launchAndGetBody(): Promise<Record<string, unknown>> {
  const startBtn = screen.getByRole("button", { name: /^Start Run$/i });
  await waitFor(() => expect(startBtn).not.toBeDisabled());
  await act(async () => fireEvent.click(startBtn));
  const launchBtn = await screen.findByRole("button", { name: /^Launch$/i });
  await act(async () => fireEvent.click(launchBtn));
  await waitFor(() => expect(createRunMock).toHaveBeenCalledTimes(1));
  return (createRunMock.mock.calls[0] as unknown[])[1] as Record<string, unknown>;
}

const LOCKED_NOTE = "This vibe keeps the base model's conventions; the agent ignores changes here.";

beforeEach(() => {
  DEFAULTS = {
    "v-2-ecm": a2Defaults("v-2-ecm"),
    "v-1-ecm": a2Defaults("v-1-ecm", {
      naming_convention: locked("PascalCase"),
      tag_suffix: locked("_v1"),
      schema_suffix: locked("_raw"),
    }),
  };
  DEFAULTS_STATE = "ready";
  createRunMock.mockClear();
  validateRunMock.mockClear();
  compileMock.mockClear();
});
afterEach(() => vi.restoreAllMocks());

warmImports(() => import("@/routes/_sidebar/businesses.$businessId.runs.new"));

describe("a vibe pre-fills from the base model", () => {
  it("shows the base values and locks the ones the agent keeps", async () => {
    await renderRunsNew("?operationType=vibe-iterate&sourceVersion=2&sourceScope=ecm");
    await openAdvanced();

    expect(screen.getByTestId("run-defaults-source")).toHaveTextContent("Pre-filled from v2 ECM.");
    const naming = screen.getByRole("combobox", { name: "Naming Convention" });
    expect(naming).toHaveTextContent("SCREAMING_CASE");
    expect(naming).toBeDisabled();
    expect(naming).toHaveAccessibleDescription(LOCKED_NOTE);
    // Locked values stay readable (full opacity on the muted surface).
    expect(naming.className).toContain("disabled:opacity-100");
    expect(naming.className).toContain("disabled:bg-muted");
    expect(screen.getByRole("combobox", { name: "Boolean Format" })).toHaveTextContent("Int (0/1)");
    expect(screen.getByRole("combobox", { name: "Date Format" })).toHaveTextContent("dd/MM/yyyy");
    const prefix = screen.getByLabelText("Schema Prefix") as HTMLInputElement;
    expect(prefix.value).toBe("ecm_");
    expect(prefix).toBeDisabled();
    const tagSuffix = screen.getByLabelText("Tag Suffix") as HTMLInputElement;
    expect(tagSuffix.value).toBe("_wt");
    expect(tagSuffix).toBeDisabled();
    expect(tagSuffix).toHaveAttribute("title", "From the base model's file");
    expect(tagSuffix).toHaveAccessibleDescription(LOCKED_NOTE);
    const schemaSuffix = screen.getByLabelText("Schema Suffix") as HTMLInputElement;
    expect(schemaSuffix.value).toBe("");
    expect(schemaSuffix).toBeDisabled();
    expect(schemaSuffix).toHaveAccessibleDescription(LOCKED_NOTE);
    expect(screen.getByTestId("run-conventions-locked-note")).toHaveTextContent(LOCKED_NOTE);
    // Divisions come from the run that made the base, not from the model size.
    expect(screen.getByRole("combobox", { name: /Organization Divisions/ })).toHaveTextContent(
      "Operations, Business and Corporate",
    );
    expect(screen.queryByTestId("org-divisions-auto")).toBeNull();
  });

  it("keeps an edit to an unlocked field across a base change and re-fills the rest", async () => {
    await renderRunsNew("?operationType=vibe-iterate&sourceVersion=2&sourceScope=ecm");
    await openAdvanced();
    await pick("Housekeeping Columns", "Yes");

    await pick("Base Version", "v1 ECM");

    expect(screen.getByRole("combobox", { name: "Housekeeping Columns" })).toHaveTextContent("Yes");
    expect((screen.getByLabelText("Tag Suffix") as HTMLInputElement).value).toBe("_v1");
    expect((screen.getByLabelText("Schema Suffix") as HTMLInputElement).value).toBe("_raw");
    expect(screen.getByRole("combobox", { name: "Naming Convention" })).toHaveTextContent("PascalCase");
    const body = await launchAndGetBody();
    expect(body).toMatchObject({
      housekeeping_columns: "Yes",
      tag_suffix: "_v1",
      schema_suffix: "_raw",
      naming_convention: "PascalCase",
    });
  });

  it("an edit to a locked suffix never reaches the body", async () => {
    await renderRunsNew("?operationType=vibe-iterate&sourceVersion=2&sourceScope=ecm");
    await openAdvanced();
    fireEvent.change(screen.getByLabelText("Tag Suffix"), { target: { value: "_mine" } });
    fireEvent.change(screen.getByLabelText("Schema Suffix"), { target: { value: "_mine" } });
    expect((screen.getByLabelText("Tag Suffix") as HTMLInputElement).value).toBe("_wt");
    expect((screen.getByLabelText("Schema Suffix") as HTMLInputElement).value).toBe("");
    const body = await launchAndGetBody();
    expect(body).toMatchObject({ tag_suffix: "_wt", schema_suffix: "" });
  });

  it("a Some domains vibe locks the fields the base leaves empty", async () => {
    await renderRunsNew("?operationType=vibe-iterate&sourceVersion=2&sourceScope=ecm");
    await openAdvanced();
    expect(screen.getByText("The base model doesn't set this; the agent uses the value here.")).toBeInTheDocument();
    const classification = () => screen.getByTestId("run-classification-levels").querySelector("input")!;
    expect(classification()).not.toBeDisabled();

    fireEvent.click(screen.getByRole("radio", { name: "Some domains" }));

    expect(classification()).toBeDisabled();
    expect(classification()).toHaveAttribute("placeholder", "Not set in the base model");
    expect(screen.getByTestId("run-classification-levels")).toHaveAccessibleDescription(LOCKED_NOTE);
  });

  it("sends every known field, blanks included, on validate and create alike", async () => {
    await renderRunsNew("?operationType=vibe-iterate&sourceVersion=2&sourceScope=ecm");
    await openAdvanced();
    await waitFor(() => expect(validateRunMock).toHaveBeenCalled());
    const validated = (validateRunMock.mock.calls.at(-1) as unknown[])[1] as Record<string, unknown>;
    const body = await launchAndGetBody();
    for (const f of [
      "naming_convention", "schema_prefix", "schema_suffix", "tag_suffix", "boolean_format",
      "classification_levels", "housekeeping_columns", "org_divisions", "ecm_schema_prefix", "mvm_schema_prefix",
    ]) {
      expect(validated[f], f).toEqual(body[f]);
    }
    expect(body).toMatchObject({
      naming_convention: "SCREAMING_CASE",
      primary_key_suffix: "_id",
      schema_prefix: "ecm_",
      schema_suffix: "",
      tag_prefix: "dbx_",
      tag_suffix: "_wt",
      table_id_type: "BIGINT",
      boolean_format: "Int (0/1)",
      date_format: "dd/MM/yyyy",
      timestamp_format: "yyyy-MM-dd HH:mm:ss",
      classification_levels: "",
      catalog_prefix: "",
      housekeeping_columns: "No",
      org_divisions: "Operations, Business and Corporate",
    });
  });

  it("Vibe ECM + MVM sends the base prefix as its ECM prefix and classification verbatim", async () => {
    DEFAULTS["v-2-ecm"] = a2Defaults("v-2-ecm", {
      classification_levels: locked("restricted=restricted,public=public"),
      schema_prefix: locked("brew_ecm_"),
    });
    await renderRunsNew("?operationType=vibe-new-ecm-mvm&sourceVersion=2&sourceScope=ecm");
    await openAdvanced();
    await waitFor(() => expect(validateRunMock).toHaveBeenCalled());
    const validated = (validateRunMock.mock.calls.at(-1) as unknown[])[1] as Record<string, unknown>;
    expect(validated.ecm_schema_prefix).toBe("brew_ecm_");
    const body = await launchAndGetBody();
    expect(body.intent).toBe("vibe-new-ecm-mvm");
    expect(body.ecm_schema_prefix).toBe("brew_ecm_");
    expect(body.mvm_schema_prefix).toBe("mvm_");
    expect(body).not.toHaveProperty("schema_prefix");
    expect(body.classification_levels).toBe("restricted=restricted,public=public");
    expect(body.naming_convention).toBe("SCREAMING_CASE");

  });
});

describe("reading the base model", () => {
  it("disables Start Run while the defaults load", async () => {
    DEFAULTS_STATE = "loading";
    await renderRunsNew("?operationType=vibe-iterate&sourceVersion=2&sourceScope=ecm");
    await waitFor(() => expect(screen.getByTestId("run-defaults-loading")).toBeInTheDocument());
    expect(screen.getByTestId("run-defaults-loading")).toHaveTextContent("Reading the base model's conventions");
    expect(screen.getByRole("button", { name: /^Start Run$/i })).toBeDisabled();
  });

  it("an unreadable base file locks the conventions with no value and sends none", async () => {
    const unknown = locked(null, "unknown");
    DEFAULTS["v-2-ecm"] = {
      ...a2Defaults("v-2-ecm", {
        naming_convention: unknown,
        primary_key_suffix: unknown,
        schema_prefix: unknown,
        schema_suffix: unknown,
        tag_prefix: unknown,
        tag_suffix: unknown,
        table_id_type: unknown,
        boolean_format: unknown,
        date_format: unknown,
        timestamp_format: unknown,
        classification_levels: unknown,
      }),
      file_read: false,
    };
    await renderRunsNew("?operationType=vibe-iterate&sourceVersion=2&sourceScope=ecm");
    await openAdvanced();
    expect(screen.getByTestId("run-defaults-unread")).toHaveTextContent(
      "Couldn't read the base model's conventions; the agent keeps them.",
    );
    // The source line claims only what was pre-filled.
    expect(screen.getByTestId("run-defaults-source")).toHaveTextContent(
      "The options other than the conventions are pre-filled from the run that made v2 ECM.",
    );
    expect(screen.getByTestId("run-defaults-source")).not.toHaveTextContent("Pre-filled from v2 ECM.");
    const naming = screen.getByRole("combobox", { name: "Naming Convention" });
    expect(naming).toBeDisabled();
    expect(naming).toHaveTextContent("Kept from the base model");
    expect(naming).not.toHaveTextContent("snake_case");
    const prefix = screen.getByLabelText("Schema Prefix") as HTMLInputElement;
    expect(prefix.value).toBe("");
    expect(prefix).toHaveAttribute("placeholder", "Kept from the base model");
    const body = await launchAndGetBody();
    for (const f of [
      "naming_convention", "schema_prefix", "schema_suffix", "tag_suffix", "boolean_format", "classification_levels",
    ]) {
      expect(body).not.toHaveProperty(f);
    }
  });

  it("Vibe ECM + MVM with a failed read keeps the form's ECM prefix", async () => {
    DEFAULTS_STATE = "error";
    await renderRunsNew("?operationType=vibe-new-ecm-mvm&sourceVersion=2&sourceScope=ecm");
    await openAdvanced();
    const body = await launchAndGetBody();
    expect(body.ecm_schema_prefix).toBe("ecm_");
    expect(body).not.toHaveProperty("schema_prefix");
  });

  it("a failed read says so and sends what the form shows", async () => {
    DEFAULTS_STATE = "error";
    await renderRunsNew("?operationType=vibe-iterate&sourceVersion=2&sourceScope=ecm");
    await openAdvanced();
    expect(screen.getByTestId("run-defaults-failed")).toHaveTextContent(
      "Couldn't load the base model's conventions",
    );
    const naming = screen.getByRole("combobox", { name: "Naming Convention" });
    expect(naming).not.toBeDisabled();
    const body = await launchAndGetBody();
    expect(body).toMatchObject({ naming_convention: "snake_case", tag_suffix: "", schema_prefix: "" });
    expect(screen.queryByTestId("run-defaults-source")).toBeNull();
  });
});
