/**
 * New Run form — the agent's option values, seed domains, Model Size, the
 * operations the form no longer offers, and the old-agent Full Run note.
 *
 *  - Advanced Options offer the agent's own lists (date and timestamp as
 *    Selects) and the create body carries the picked agent strings.
 *  - Seed `business_domains` are sent only by Vibe ECM + MVM and New Base
 *    Model; a vibe iteration has no seed-domain field.
 *  - Model Size shows the base's scope and is locked on every vibe iteration;
 *    Organization Divisions follow it until the user picks them.
 *  - Install / Uninstall / Generate Samples are not offered; a deep link to
 *    one of them (any case, hyphen, underscore or space) shows a notice
 *    (version-page links, or "retired").
 *  - An agent older than 5.3.3 locks All domains + Full Run with a note.
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

const version = (id: string, n: number, scope: "ecm" | "mvm") => ({
  id,
  version: n,
  scope,
  status: "completed",
  is_base: n === 1,
  confidence_score: null,
  vibe_instructions: "",
  created_at: `2026-04-2${n}T12:00:00Z`,
  uc_catalog: "utility_cat",
  deployment_status: "deployed",
});
const MVM_V3 = version("v-3-mvm", 3, "mvm");
const MVM_V2 = version("v-2-mvm", 2, "mvm");
const ECM_V1 = version("v-1-ecm", 1, "ecm");

const VIBE_INPUTS = [
  {
    id: "vi-1",
    text: "Add a due date to invoices",
    priority: "high",
    anchor: { level: "element", domain_name: "billing", path: ["Domain: billing"] },
    consumed: false,
    selected_for_run: true,
    status: "active",
  },
];

const MODEL_SUMMARY = { name: "Utility", version: 2, domains: [{ id: "d-1", name: "billing" }] };

let VERSIONS: unknown[] = [];
let COMPAT: Record<string, unknown> | undefined;

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
    // No base-model pre-fill: the form keeps its own values.
    useGetRunDefaults: () => ({ data: undefined, isLoading: false, isError: false }),
    useGetBusinessSuspense: () => ({
      data: { id: "biz-1", name: "Acme Utility", description: "Utility blurb." },
    }),
    useListVersionsSuspense: () => ({ data: VERSIONS }),
    useListVibeInputs: (opts: any) => ({
      data: opts?.query?.select ? opts.query.select({ data: VIBE_INPUTS }) : VIBE_INPUTS,
    }),
    useGetCatalogSchemaWarning: () => ({ data: undefined }),
    useGetModelSummary: (opts: any) => ({
      data: opts?.query?.enabled === false ? undefined : MODEL_SUMMARY,
    }),
    useGetAgentCompat: (opts: any) => ({
      data: opts?.query?.enabled === false || COMPAT === undefined ? undefined : COMPAT,
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
  const stub = (path: string) =>
    createRoute({ getParentRoute: () => rootRoute, path, component: () => <div /> });
  const router = createRouter({
    routeTree: rootRoute.addChildren([
      sidebarRoute.addChildren([runsNewClone]),
      stub("/businesses/$businessId/model/$version/$scope"),
      stub("/businesses/$businessId/model/$version/$scope/inputs"),
      stub("/businesses/$businessId/runs"),
      stub("/settings"),
    ]),
    history: createMemoryHistory({
      initialEntries: [`/businesses/biz-1/runs/new${searchString}`],
    }),
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

async function formReady() {
  await waitFor(() => expect(screen.getByRole("combobox", { name: "Operation Type" })).toBeInTheDocument());
}

async function openSelect(name: string | RegExp): Promise<string[]> {
  const trigger = screen.getByRole("combobox", { name });
  await act(async () => fireEvent.click(trigger));
  const options = await screen.findAllByRole("option");
  return options.map((o) => o.textContent ?? "");
}

async function pick(name: string | RegExp, value: string) {
  await openSelect(name);
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

beforeEach(() => {
  VERSIONS = [MVM_V3, MVM_V2, ECM_V1];
  COMPAT = undefined;
  createRunMock.mockClear();
  validateRunMock.mockClear();
  compileMock.mockClear();
});
afterEach(() => vi.restoreAllMocks());

warmImports(() => import("@/routes/_sidebar/businesses.$businessId.runs.new"));

describe("Advanced Options offer the agent's values", () => {
  it("links the page header to the run types and Advanced Options to the run parameters", async () => {
    await renderRunsNew("?operationType=vibe-iterate");
    await formReady();
    expect(screen.getByRole("link", { name: "Run types" })).toHaveAttribute("href", "/help/runs");
    expect(screen.getByRole("link", { name: "Run parameters" })).toHaveAttribute("href", "/help/run-parameters");
  });

  it("lists the agent strings, date and timestamp as Selects, and sends the picks", async () => {
    await renderRunsNew("?operationType=vibe-iterate");
    await formReady();
    fireEvent.click(screen.getByRole("button", { name: /Advanced Options/ }));

    expect(await openSelect("Naming Convention")).toEqual([
      "snake_case", "camelCase", "PascalCase", "SCREAMING_CASE",
    ]);
    await act(async () => fireEvent.click(screen.getByRole("option", { name: "SCREAMING_CASE" })));

    expect(await openSelect("Table ID Type")).toEqual(["BIGINT", "INT", "STRING"]);
    await act(async () => fireEvent.click(screen.getByRole("option", { name: "STRING" })));

    expect(await openSelect("Boolean Format")).toEqual([
      "Boolean (True/False)", "Int (0/1)", "String (Y/N)",
    ]);
    await act(async () => fireEvent.click(screen.getByRole("option", { name: "Int (0/1)" })));

    expect(await openSelect("Date Format")).toEqual([
      "yyyy-MM-dd", "dd/MM/yyyy", "MM/dd/yyyy", "yyyy/MM/dd", "dd-MM-yyyy",
    ]);
    await act(async () => fireEvent.click(screen.getByRole("option", { name: "dd/MM/yyyy" })));

    expect(await openSelect("Timestamp Format")).toEqual([
      "yyyy-MM-dd'T'HH:mm:ss.SSSXXX",
      "yyyy-MM-dd HH:mm:ss",
      "yyyy-MM-dd'T'HH:mm:ss",
      "yyyy-MM-dd HH:mm:ss.SSS",
    ]);
    await act(async () => fireEvent.click(screen.getByRole("option", { name: "yyyy-MM-dd'T'HH:mm:ss" })));

    expect(await openSelect("Housekeeping Columns")).toEqual(["No", "Yes"]);
    await act(async () => fireEvent.click(screen.getByRole("option", { name: "Yes" })));

    expect(screen.queryByText(/Generate sample data/)).toBeNull();

    const body = await launchAndGetBody();
    expect(body).toMatchObject({
      naming_convention: "SCREAMING_CASE",
      table_id_type: "STRING",
      boolean_format: "Int (0/1)",
      date_format: "dd/MM/yyyy",
      timestamp_format: "yyyy-MM-dd'T'HH:mm:ss",
      housekeeping_columns: "Yes",
    });
    expect(body).not.toHaveProperty("generate_samples");
  }, 15_000);

  it("starts on the defaults shared with the backend widget builders", async () => {
    await renderRunsNew("?operationType=vibe-iterate");
    await formReady();
    fireEvent.click(screen.getByRole("button", { name: /Advanced Options/ }));
    expect(screen.getByRole("combobox", { name: "Boolean Format" })).toHaveTextContent("Boolean (True/False)");
    expect(screen.getByRole("combobox", { name: "Date Format" })).toHaveTextContent("yyyy-MM-dd");
    expect(screen.getByRole("combobox", { name: "Timestamp Format" })).toHaveTextContent("yyyy-MM-dd HH:mm:ss");
  });
});

describe("seed business_domains only for operations that build from the business", () => {
  it("a vibe iteration shows no seed-domain field and sends none", async () => {
    await renderRunsNew("?operationType=vibe-iterate");
    await formReady();
    fireEvent.click(screen.getByRole("button", { name: /Advanced Options/ }));
    expect(screen.queryByText("Business Domains")).toBeNull();
    const body = await launchAndGetBody();
    expect(body.intent).toBe("vibe-iterate");
    expect(body).not.toHaveProperty("business_domains");
  });

  it("Vibe ECM + MVM sends the typed seed domains", async () => {
    await renderRunsNew("?operationType=vibe-new-ecm-mvm");
    await formReady();
    fireEvent.click(screen.getByRole("button", { name: /Advanced Options/ }));
    const tagInput = screen.getByPlaceholderText("Type a domain, press Enter");
    fireEvent.change(tagInput, { target: { value: "seed_domain" } });
    fireEvent.keyDown(tagInput, { key: "Enter" });
    const body = await launchAndGetBody();
    expect(body.intent).toBe("vibe-new-ecm-mvm");
    expect(body.business_domains).toBe("seed_domain");
  });
});

describe("Model Size keeps the base version's size", () => {
  const sizeTrigger = () => screen.getByRole("combobox", { name: "Model Size" });
  const divisions = () => screen.getByRole("combobox", { name: /Organization Divisions/ });

  it("is Large for an ECM base, with divisions following it, and sends both", async () => {
    await renderRunsNew("?operationType=vibe-iterate&sourceVersion=1&sourceScope=ecm");
    await formReady();
    expect(sizeTrigger()).toHaveTextContent("Large Model (ECM)");
    fireEvent.click(screen.getByRole("button", { name: /Advanced Options/ }));
    expect(divisions()).toHaveTextContent("Operations, Business and Corporate");
    expect(screen.getByTestId("org-divisions-auto")).toHaveTextContent("Auto-set from model size");
    const body = await launchAndGetBody();
    expect(body.model_size).toBe("large model");
    expect(body.org_divisions).toBe("Operations, Business and Corporate");
  });

  it("is Small for an MVM base", async () => {
    await renderRunsNew("?operationType=vibe-iterate&sourceVersion=2&sourceScope=mvm");
    await formReady();
    expect(sizeTrigger()).toHaveTextContent("Small Model (MVM)");
  });

  it("follows the base when the base changes", async () => {
    await renderRunsNew("?operationType=vibe-iterate&sourceVersion=3&sourceScope=mvm");
    await formReady();
    await pick("Base Version", "v1 ECM");
    expect(sizeTrigger()).toHaveTextContent("Large Model (ECM)");
    await pick("Base Version", "v2 MVM");
    expect(sizeTrigger()).toHaveTextContent("Small Model (MVM)");
  });

  it("treats a base with an empty scope as ECM, like the backend", async () => {
    VERSIONS = [{ ...version("v-4-legacy", 4, "ecm"), scope: "" }];
    await renderRunsNew("?operationType=vibe-iterate");
    await formReady();
    expect(sizeTrigger()).toHaveTextContent("Large Model (ECM)");
    fireEvent.click(screen.getByRole("button", { name: /Advanced Options/ }));
    expect(divisions()).toHaveTextContent("Operations, Business and Corporate");
    const body = await launchAndGetBody();
    expect(body.model_size).toBe("large model");
  });

  it("is locked on every vibe iteration, scoped or not, with a note", async () => {
    await renderRunsNew("?operationType=vibe-iterate&sourceVersion=2&sourceScope=mvm");
    await formReady();
    expect(sizeTrigger()).toBeDisabled();
    expect(sizeTrigger()).toHaveAccessibleDescription("A vibe run keeps the base version's size.");

    fireEvent.click(screen.getByRole("radio", { name: "Some domains" }));
    expect(sizeTrigger()).toBeDisabled();
    expect(sizeTrigger()).toHaveTextContent("Small Model (MVM)");
    fireEvent.click(screen.getByRole("button", { name: /Advanced Options/ }));
    expect(divisions()).toHaveTextContent(/^Operations$/);
    fireEvent.click(screen.getByRole("checkbox", { name: "billing" }));
    const body = await launchAndGetBody();
    expect(body.model_size).toBe("small model");
    expect(body.org_divisions).toBe("Operations");
  });

  it("keeps the user's divisions once picked, whatever the base", async () => {
    await renderRunsNew("?operationType=vibe-iterate&sourceVersion=1&sourceScope=ecm");
    await formReady();
    fireEvent.click(screen.getByRole("button", { name: /Advanced Options/ }));
    await pick(/Organization Divisions/, "Operations and Business");
    expect(screen.queryByTestId("org-divisions-auto")).toBeNull();
    await pick("Base Version", "v2 MVM");
    expect(divisions()).toHaveTextContent("Operations and Business");
    expect((await launchAndGetBody()).org_divisions).toBe("Operations and Business");
  });
});

describe("operations the form does not offer", () => {
  it("lists only the model-producing operations", async () => {
    await renderRunsNew("?operationType=vibe-iterate");
    await formReady();
    expect(await openSelect("Operation Type")).toEqual([
      "New Base Model", "Vibe Modeling", "Vibe ECM + MVM",
    ]);
    expect(screen.queryByTestId("removed-operation-notice")).toBeNull();
  });

  it.each([
    "install", "install model", "uninstall", "uninstall model version",
    "Install Model", "install-model", "uninstall_model", "Uninstall Model",
  ])(
    "a %s deep link opens Vibe Modeling with links to each scope's latest version",
    async (op) => {
      await renderRunsNew(`?operationType=${encodeURIComponent(op)}`);
      await formReady();
      expect(screen.getByRole("combobox", { name: "Operation Type" })).toHaveTextContent("Vibe Modeling");
      const notice = screen.getByTestId("removed-operation-notice");
      expect(notice).toHaveTextContent("Install or uninstall a version from its page.");
      const links = within(notice).getAllByRole("link");
      expect(links.map((l) => l.textContent)).toEqual(["Open v3 MVM", "Open v1 ECM"]);
      expect(links[0]).toHaveAttribute("href", "/businesses/biz-1/model/3/mvm?tab=overview");
    },
  );

  it.each(["constructor", "toString", "__proto__"])(
    "a %s deep link is not a removed operation",
    async (op) => {
      await renderRunsNew(`?operationType=${op}`);
      await formReady();
      expect(screen.getByRole("combobox", { name: "Operation Type" })).toHaveTextContent("Vibe Modeling");
      expect(screen.queryByTestId("removed-operation-notice")).toBeNull();
    },
  );

  it.each(["Vibe-Iterate", "VIBE_ITERATE", "vibe iterate", "Vibe Modeling Of Version"])(
    "a %s deep link opens Vibe Modeling",
    async (op) => {
      await renderRunsNew(`?operationType=${encodeURIComponent(op)}&sourceVersion=1&sourceScope=ecm`);
      await formReady();
      expect(screen.getByRole("combobox", { name: "Operation Type" })).toHaveTextContent("Vibe Modeling");
      expect(screen.getByRole("combobox", { name: "Base Version" })).toHaveTextContent("v1 ECM");
      expect(screen.queryByTestId("removed-operation-notice")).toBeNull();
    },
  );

  it.each(["Vibe-New-ECM-MVM", "vibe_new_ecm_mvm"])(
    "a %s deep link opens Vibe ECM + MVM",
    async (op) => {
      await renderRunsNew(`?operationType=${encodeURIComponent(op)}`);
      await formReady();
      expect(screen.getByRole("combobox", { name: "Operation Type" })).toHaveTextContent("Vibe ECM + MVM");
    },
  );

  it.each(["1", "true", "%5B1%5D", "%7B%22a%22%3A1%7D"])(
    "a non-string operationType (%s) opens the default operation without a notice",
    async (raw) => {
      await renderRunsNew(`?operationType=${raw}&sourceScope=1`);
      await formReady();
      expect(screen.getByRole("combobox", { name: "Operation Type" })).toHaveTextContent("Vibe Modeling");
      expect(screen.queryByTestId("removed-operation-notice")).toBeNull();
    },
  );

  it("links only the version the deep link names", async () => {
    await renderRunsNew("?operationType=uninstall&sourceVersion=1&sourceScope=ecm");
    await formReady();
    const notice = screen.getByTestId("removed-operation-notice");
    const links = within(notice).getAllByRole("link");
    expect(links.map((l) => l.textContent)).toEqual(["Open v1 ECM"]);
    expect(links[0]).toHaveAttribute("href", "/businesses/biz-1/model/1/ecm?tab=overview");
  });

  it.each(["generate-samples", "generate sample data", "Generate Samples", "generate_samples"])(
    "a %s deep link says the operation was retired",
    async (op) => {
      await renderRunsNew(`?operationType=${encodeURIComponent(op)}`);
      await formReady();
      expect(screen.getByRole("combobox", { name: "Operation Type" })).toHaveTextContent("Vibe Modeling");
      const notice = screen.getByTestId("removed-operation-notice");
      expect(notice).toHaveTextContent(
        "Generate Samples was retired: the agent no longer generates sample data.",
      );
      expect(within(notice).queryByRole("link")).toBeNull();
    },
  );

  it("a removed operation on a business without versions opens New Base Model", async () => {
    VERSIONS = [];
    await renderRunsNew("?operationType=install");
    await formReady();
    expect(screen.getByRole("combobox", { name: "Operation Type" })).toHaveTextContent("New Base Model");
    const notice = screen.getByTestId("removed-operation-notice");
    expect(within(notice).queryByRole("link")).toBeNull();
  });
});

describe("old agent: Full Run only", () => {
  const SCOPED_LINK = "?operationType=vibe-iterate&sourceVersion=2&sourceScope=mvm&scopeDomains=billing";

  it("locks All domains + Full Run and says why when the agent predates 5.3.3", async () => {
    COMPAT = { installed_agent_version: "4.9.9" };
    await renderRunsNew(`${SCOPED_LINK}&runMode=dry`);
    await formReady();
    expect(screen.getByRole("radio", { name: "All domains" })).toHaveAttribute("aria-checked", "true");
    expect(screen.getByRole("radio", { name: "Full Run" })).toHaveAttribute("aria-checked", "true");
    expect(screen.getByRole("radio", { name: "Some domains" })).toBeDisabled();
    expect(screen.getByRole("radio", { name: "Dry Run" })).toBeDisabled();
    expect(screen.getByRole("radio", { name: "All domains" })).not.toBeDisabled();
    expect(screen.getByRole("radio", { name: "Full Run" })).not.toBeDisabled();
    const note = screen.getByTestId("old-agent-full-run-note");
    expect(note).toHaveTextContent(
      "Full Run only. The configured agent is 4.9.9. Dry Run and Some domains need agent 5.3.3 or later.",
    );
    expect(within(note).getByRole("link", { name: "Settings" })).toHaveAttribute(
      "href",
      "/settings?tab=agent",
    );
    for (const name of ["Scope", "Run type"]) {
      expect(screen.getByRole("radiogroup", { name })).toHaveAccessibleDescription(
        /^Full Run only\. The configured agent is 4\.9\.9\./,
      );
    }
    const body = await launchAndGetBody();
    for (const key of ["vibe_scope", "vibe_scope_domains", "dry_run"]) {
      expect(body).not.toHaveProperty(key);
    }
  });

  it("overrides the Dry Run default on an unscoped link without runMode", async () => {
    COMPAT = { installed_agent_version: "4.9.9" };
    await renderRunsNew("?operationType=vibe-iterate");
    await formReady();
    expect(screen.getByRole("radio", { name: "All domains" })).toHaveAttribute("aria-checked", "true");
    expect(screen.getByRole("radio", { name: "Full Run" })).toHaveAttribute("aria-checked", "true");
    expect(screen.getByRole("radio", { name: "Dry Run" })).toBeDisabled();
    expect(screen.getByTestId("old-agent-full-run-note")).toBeInTheDocument();
    const body = await launchAndGetBody();
    for (const key of ["vibe_scope", "vibe_scope_domains", "dry_run"]) {
      expect(body).not.toHaveProperty(key);
    }
  });

  it("defaults to Dry Run for a 5.3.3 agent, scoped or not", async () => {
    COMPAT = { installed_agent_version: "5.3.3" };
    const scoped = await renderRunsNew(SCOPED_LINK);
    await formReady();
    expect(screen.getByRole("radio", { name: "Dry Run" })).toHaveAttribute("aria-checked", "true");
    expect(screen.queryByTestId("old-agent-full-run-note")).toBeNull();
    scoped.unmount();

    await renderRunsNew("?operationType=vibe-iterate");
    await formReady();
    expect(screen.getByRole("radio", { name: "Dry Run" })).toHaveAttribute("aria-checked", "true");
    expect(screen.queryByTestId("old-agent-full-run-note")).toBeNull();
  });

  it.each([null, "unknown", "garbage"])(
    "shows no note when the agent version is %s",
    async (installed) => {
      COMPAT = { installed_agent_version: installed };
      await renderRunsNew(SCOPED_LINK);
      await formReady();
      expect(screen.getByRole("radio", { name: "Dry Run" })).toHaveAttribute("aria-checked", "true");
      expect(screen.getByRole("radio", { name: "Some domains" })).not.toBeDisabled();
      expect(screen.queryByTestId("old-agent-full-run-note")).toBeNull();
    },
  );

  it("does not show the note on Vibe ECM + MVM", async () => {
    COMPAT = { installed_agent_version: "4.9.9" };
    await renderRunsNew("?operationType=vibe-new-ecm-mvm");
    await formReady();
    expect(screen.queryByTestId("old-agent-full-run-note")).toBeNull();
  });
});
