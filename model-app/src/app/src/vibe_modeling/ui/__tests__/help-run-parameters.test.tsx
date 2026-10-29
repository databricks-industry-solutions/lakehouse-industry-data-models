/**
 * The run-parameters help page against the agent's widget lists
 * (`tests/fixtures/agent_widget_options.json`, pinned to the vendored
 * notebook's `dbutils.widgets.dropdown` calls by
 * `tests/test_app/test_agent_widget_options.py`): every list the page shows
 * equals the agent's, minus what the form leaves out, and the page says what
 * it leaves out. Also the fields' form order and the run time budget copy.
 */
import { describe, expect, it, vi } from "vitest";
import { render, screen, within } from "@testing-library/react";
import {
  createMemoryHistory,
  createRootRoute,
  createRoute,
  createRouter,
  Outlet,
  RouterProvider,
} from "@tanstack/react-router";
import fixture from "../../../../../../tests/fixtures/agent_widget_options.json";
import alwaysLocked from "../../../../../../tests/fixtures/vibe_always_locked_fields.json";

const agentConfig = vi.hoisted(() => ({
  value: { runtime_budget_hours: 6, runtime_budget_min_hours: 4, runtime_budget_max_hours: 48 } as
    | Record<string, number>
    | undefined,
}));

vi.mock("@/lib/api", async (importOriginal) => ({
  ...(await importOriginal<typeof import("@/lib/api")>()),
  useGetAgentConfig: () => ({ data: agentConfig.value }),
}));

import {
  ALWAYS_LOCKED_LABELS,
  INSTALL_OWN_PREFIX,
  PARAMETER_FIELDS,
  RunParametersContent,
} from "@/components/help/run-parameters-content";
import { RUNTIME_BUDGET_SETTINGS_HINT } from "@/lib/runtime-budget";
import { HISTORY_TRACKING_HINT, HOUSEKEEPING_COLUMNS_HINT } from "@/lib/tracking-columns";
import { useStrictConsole } from "./helpers/strict-console";

const options = fixture.options as Record<string, string[]>;
const omits = fixture.form_omits as Record<string, string[]>;

function offered(widget: string): string[] {
  const omitted = new Set(omits[widget] ?? []);
  return options[widget].filter((v) => !omitted.has(v));
}

async function renderPage() {
  const rootRoute = createRootRoute({ component: () => <Outlet /> });
  const page = createRoute({ getParentRoute: () => rootRoute, path: "/", component: RunParametersContent });
  const topic = createRoute({ getParentRoute: () => rootRoute, path: "/help/$topic", component: () => null });
  const index = createRoute({ getParentRoute: () => rootRoute, path: "/help", component: () => null });
  const router = createRouter({
    routeTree: rootRoute.addChildren([page, topic, index]),
    history: createMemoryHistory({ initialEntries: ["/"] }),
  });
  render(<RouterProvider router={router} />);
  await screen.findByRole("heading", { level: 1, name: "Run parameters" });
}

describe("Run parameters help: option lists equal the agent's", () => {
  const dom = useStrictConsole();

  it.each(Object.keys(options).filter((w) => w !== "cataloging_style"))("%s", async (widget) => {
    await renderPage();
    const lists = screen.getAllByTestId(`param-values-${widget}`);
    for (const list of lists) {
      const shown = within(list).getAllByRole("listitem").map((li) => li.textContent);
      expect(shown).toEqual(offered(widget));
    }
    expect(dom.messages).toEqual([]);
  });

  it("cataloging_style", async () => {
    await renderPage();
    expect(screen.getByTestId("param-values-cataloging_style")).toHaveTextContent(
      offered("cataloging_style").join(", "),
    );
  });

  it("shows every agent list the fixture holds", () => {
    const widgets = new Set(
      PARAMETER_FIELDS.flatMap((f) => (f.widget && typeof f.values !== "string" ? [f.widget] : [])),
    );
    widgets.add("cataloging_style");
    expect([...widgets].sort()).toEqual(Object.keys(options).sort());
  });

  it("names each value the form leaves out", async () => {
    await renderPage();
    for (const [widget, values] of Object.entries(omits)) {
      const field = PARAMETER_FIELDS.find((f) => f.widget === widget)!;
      for (const v of values) expect(field.note).toContain(v);
    }
  });
});

describe("Run parameters help: fields", () => {
  it("lists the Advanced Options fields in form order, run time budget first", async () => {
    await renderPage();
    const labels = screen
      .getAllByTestId("param-field")
      .map((el) => within(el).getByRole("heading", { level: 3 }).textContent);
    expect(labels).toEqual([
      "Run time budget (hours)",
      "Organization Divisions",
      "Business Domains",
      "Catalog Prefix",
      "Catalog Suffix",
      "ECM Schema Prefix and MVM Schema Prefix",
      "Schema Prefix",
      "Schema Suffix",
      "Naming Convention",
      "PK Suffix",
      "Tag Prefix",
      "Tag Suffix",
      "Table ID Type",
      "Boolean Format",
      "Date Format",
      "Timestamp Format",
      "Housekeeping Columns",
      "History Tracking",
      "Classification Levels",
    ]);
  });

  it("gives every field a default, the runs that send it and what Install does", () => {
    for (const f of PARAMETER_FIELDS) {
      expect(f.defaultValue, f.label).toBeTruthy();
      expect(f.usedBy, f.label).toBeTruthy();
      expect(f.install, f.label).toMatch(/^No\b/);
    }
  });

  it("says how Install picks the schema prefix (install_schema_prefix)", () => {
    const rows = PARAMETER_FIELDS.filter((f) => f.label.includes("Schema Prefix"));
    expect(rows.map((f) => f.label)).toEqual(["ECM Schema Prefix and MVM Schema Prefix", "Schema Prefix"]);
    for (const f of rows) expect(f.install, f.label).toBe(INSTALL_OWN_PREFIX);
    expect(INSTALL_OWN_PREFIX).toMatch(/the schema prefix saved in its model file, even an empty one/);
    expect(INSTALL_OWN_PREFIX).toMatch(/gets ecm_ or mvm_, from its scope, when its file has no prefix/);
    expect(INSTALL_OWN_PREFIX).toMatch(/typed Schema Prefix other than the file's is refused/);
  });

  it("explains the run time budget with the Settings default and bounds", async () => {
    agentConfig.value = { runtime_budget_hours: 6, runtime_budget_min_hours: 4, runtime_budget_max_hours: 48 };
    await renderPage();
    const field = screen.getAllByTestId("param-field")[0];
    expect(field).toHaveTextContent("now 6 hours");
    expect(field).toHaveTextContent("Whole hours, 4 to 48");
    expect(field).toHaveTextContent("No. Install and Uninstall do not use it.");
    expect(screen.getByTestId("runtime-budget-help")).toHaveTextContent(RUNTIME_BUDGET_SETTINGS_HINT);
    expect(screen.getByTestId("runtime-budget-help")).toHaveTextContent(/never stops the job/);
  });

  it("names no numbers for the run time budget before Settings answers", async () => {
    agentConfig.value = undefined;
    await renderPage();
    const field = screen.getAllByTestId("param-field")[0];
    expect(field).toHaveTextContent("within the bounds Settings shows");
    expect(field).not.toHaveTextContent(/now \d+ hours/);
    agentConfig.value = { runtime_budget_hours: 6, runtime_budget_min_hours: 4, runtime_budget_max_hours: 48 };
  });

  it("says Generate Samples is retired", async () => {
    await renderPage();
    expect(screen.getByText(/Generate Samples is retired/)).toBeInTheDocument();
  });

  it("names the agent's housekeeping and history columns", async () => {
    await renderPage();
    expect(HOUSEKEEPING_COLUMNS_HINT).toBe(
      "Yes adds created_by, creation_date, changed_by, change_date columns to every product.",
    );
    expect(HISTORY_TRACKING_HINT).toBe("Yes adds valid_from and valid_to columns to every master data product.");
    expect(screen.getByText(HOUSEKEEPING_COLUMNS_HINT)).toBeInTheDocument();
    expect(screen.getByText(HISTORY_TRACKING_HINT)).toBeInTheDocument();
    expect(document.body.textContent).not.toMatch(/created_at|is_current/);
  });

  it("says Vibe ECM + MVM sends Schema Prefix as the new ECM's prefix, locked from the base", () => {
    const field = PARAMETER_FIELDS.find((f) => f.label === "Schema Prefix")!;
    expect(field.usedBy).toMatch(/^Vibe Modeling and Vibe ECM \+ MVM, which sends it as the new ECM's prefix\./);
    expect(field.usedBy).toMatch(/always on Some domains/);
    expect(field.note).toBeUndefined();
  });

  it("says which fields a vibe locks, and when", async () => {
    await renderPage();
    expect(screen.getByText(/on All domains and Vibe ECM \+ MVM, the ones the base sets; on\s+Some domains, all of them/)).toBeInTheDocument();
    expect(
      screen.getByText(
        /It locks Schema Suffix, Tag Suffix and Boolean Format on every vibe,\s+whether or not the base sets them/,
      ),
    ).toBeInTheDocument();
    for (const label of ["Naming Convention", "Date Format", "Classification Levels"]) {
      expect(PARAMETER_FIELDS.find((f) => f.label === label)!.usedBy).toMatch(/always on Some domains/);
    }
    for (const label of ALWAYS_LOCKED_LABELS) {
      expect(PARAMETER_FIELDS.find((f) => f.label === label)!.usedBy).toMatch(
        /locks it, whether or not the base sets one: the agent ignores a change to it/,
      );
    }
    expect(PARAMETER_FIELDS.find((f) => f.label === "Boolean Format")!.note).toMatch(
      /sets no boolean format keeps Boolean \(True\/False\)/,
    );
  });

  it("names the fields locked on every vibe as the backend does (shared fixture)", () => {
    expect(ALWAYS_LOCKED_LABELS).toEqual(alwaysLocked.fields.map((f) => f.label));
    for (const { field, label } of alwaysLocked.fields) {
      expect(PARAMETER_FIELDS.find((f) => f.label === label)?.widget).toBe(field);
    }
    expect(PARAMETER_FIELDS.find((f) => f.label === "Housekeeping Columns")!.usedBy).toMatch(/you can change it/);
  });
});
