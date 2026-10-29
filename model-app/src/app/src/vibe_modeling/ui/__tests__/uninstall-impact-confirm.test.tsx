import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";
import { fireEvent, render, screen, waitFor } from "@testing-library/react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";

import {
  UninstallImpactConfirm,
  UninstallImpactSummary,
  impactCounts,
  impactNeedsConfirmation,
  type UninstallImpactConfirmState,
} from "@/components/runs/uninstall-impact-confirm";
import type { UninstallImpactOut } from "@/lib/api";

const CATALOG = "wt_catalog";

function impact(overrides: Partial<UninstallImpactOut> = {}): UninstallImpactOut {
  return {
    version_id: "mv-1",
    catalog: CATALOG,
    has_data: "yes",
    truncated: false,
    schemas: [
      {
        name: "ecm_customer",
        owner: "app-sp",
        tables: [
          { name: "party", kind: "MANAGED", has_data: true },
          { name: "address", kind: "MANAGED", has_data: false },
        ],
        views: ["party_v", "party_metrics"],
        volumes: ["samples"],
      },
      {
        name: "ecm_inventory",
        owner: "",
        tables: [{ name: "stock", kind: "EXTERNAL", has_data: false }],
        views: [],
        volumes: [],
      },
    ],
    ...overrides,
  };
}

function lastState(spy: ReturnType<typeof vi.fn>): UninstallImpactConfirmState {
  return spy.mock.calls[spy.mock.calls.length - 1][0];
}

function typeCatalog(value: string) {
  const input = screen.getByTestId("uninstall-impact-confirm-input") as HTMLInputElement;
  fireEvent.change(input, { target: { value } });
  expect(input.value).toBe(value);
}

describe("impactCounts / impactNeedsConfirmation", () => {
  it("counts tables, data, unchecked, views and volumes", () => {
    const i = impact();
    i.schemas![1].tables!.push({ name: "x", kind: "MANAGED", has_data: null });
    expect(impactCounts(i)).toEqual({
      schemas: 2, tables: 4, tablesWithData: 1, tablesUnchecked: 1, views: 2, volumes: 1,
    });
  });

  it("only a checked 'no' is safe", () => {
    expect(impactNeedsConfirmation(impact({ has_data: "yes" }))).toBe(true);
    expect(impactNeedsConfirmation(impact({ has_data: "unknown" }))).toBe(true);
    expect(impactNeedsConfirmation(impact({ has_data: "no" }))).toBe(false);
    expect(impactNeedsConfirmation(undefined)).toBe(true);
  });
});

describe("UninstallImpactSummary", () => {
  it("lists schemas, tables with data, views and volumes", () => {
    render(<UninstallImpactSummary impact={impact()} />);
    expect(screen.getByTestId("uninstall-impact-headline")).toHaveTextContent(
      "1 of 3 tables hold data. Uninstall deletes 2 schemas in wt_catalog with all their data.",
    );
    const rows = screen.getAllByTestId("uninstall-impact-schema");
    expect(rows).toHaveLength(2);
    expect(rows[0]).toHaveTextContent("ecm_customer - 2 tables, 1 with data, 2 views, 1 volume");
    expect(rows[0]).toHaveTextContent("Owner: app-sp");
    expect(rows[1]).toHaveTextContent("ecm_inventory - 1 table");
    expect(screen.queryByTestId("uninstall-impact-shared")).not.toBeInTheDocument();
    expect(rows[1]).not.toHaveTextContent("Owner:");
    expect(screen.getByTestId("uninstall-impact-tables-with-data")).toHaveTextContent("party");
    expect(screen.getByTestId("uninstall-impact-views")).toHaveTextContent("party_v, party_metrics");
    expect(screen.getByTestId("uninstall-impact-volumes")).toHaveTextContent("samples");
  });

  it("data: confirmed only when the catalog name is typed exactly", () => {
    const spy = vi.fn();
    render(<UninstallImpactSummary impact={impact()} onStateChange={spy} />);
    expect(lastState(spy)).toEqual({ status: "ready", needsConfirmation: true, confirmed: false });
    expect(screen.getByRole("alert")).toBeInTheDocument();

    typeCatalog("wt_cat");
    expect(lastState(spy).confirmed).toBe(false);
    expect(screen.getByTestId("uninstall-impact-confirm-input")).toHaveAttribute("aria-invalid", "true");

    typeCatalog("WT_CATALOG");
    expect(lastState(spy).confirmed).toBe(false);

    typeCatalog(CATALOG);
    expect(lastState(spy)).toEqual({ status: "ready", needsConfirmation: true, confirmed: true });
    expect(screen.getByTestId("uninstall-impact-confirm-input")).toHaveAttribute("aria-invalid", "false");
  });

  it("empty: no typed confirmation, confirmed at once", () => {
    const spy = vi.fn();
    const empty = impact({ has_data: "no" });
    empty.schemas![0].tables![0].has_data = false;
    render(<UninstallImpactSummary impact={empty} onStateChange={spy} />);
    expect(lastState(spy)).toEqual({ status: "ready", needsConfirmation: false, confirmed: true });
    expect(screen.queryByTestId("uninstall-impact-confirm-input")).not.toBeInTheDocument();
    expect(screen.queryByRole("alert")).not.toBeInTheDocument();
    expect(screen.getByTestId("uninstall-impact-headline")).toHaveTextContent(
      "None of the 3 tables hold data. Uninstall drops 2 schemas in wt_catalog.",
    );
  });

  it("single table: grammatical headline for empty and with-data", () => {
    const one = (hasData: boolean) => {
      const i = impact({ has_data: hasData ? "yes" : "no" });
      i.schemas = [{ name: "ecm_customer", owner: "", tables: [{ name: "party", kind: "MANAGED", has_data: hasData }], views: [], volumes: [] }];
      return i;
    };
    const { unmount } = render(<UninstallImpactSummary impact={one(false)} />);
    expect(screen.getByTestId("uninstall-impact-headline")).toHaveTextContent(
      "The 1 table holds no data. Uninstall drops 1 schema in wt_catalog.",
    );
    unmount();
    render(<UninstallImpactSummary impact={one(true)} />);
    expect(screen.getByTestId("uninstall-impact-headline")).toHaveTextContent(
      "The 1 table holds data. Uninstall deletes 1 schema in wt_catalog with all its data.",
    );
  });

  it("unknown and truncated: says so and needs the typed name", () => {
    const spy = vi.fn();
    const unknown = impact({ has_data: "unknown", truncated: true });
    unknown.schemas![0].tables![0].has_data = null;
    render(<UninstallImpactSummary impact={unknown} onStateChange={spy} />);
    expect(screen.getByTestId("uninstall-impact-headline")).toHaveTextContent(
      "Some objects could not be checked and may hold data.",
    );
    expect(screen.getByTestId("uninstall-impact-truncated")).toBeInTheDocument();
    expect(screen.getByTestId("uninstall-impact-tables-unchecked")).toHaveTextContent("party");
    expect(lastState(spy).needsConfirmation).toBe(true);
    typeCatalog(CATALOG);
    expect(lastState(spy).confirmed).toBe(true);
  });

  it("nothing found: nothing will be dropped", () => {
    render(<UninstallImpactSummary impact={impact({ has_data: "no", schemas: [] })} />);
    expect(screen.getByTestId("uninstall-impact-headline")).toHaveTextContent(
      "No schemas of this version were found in wt_catalog. Nothing will be dropped.",
    );
  });

  it("unknown with no schemas found: the expected names were not found", () => {
    render(<UninstallImpactSummary impact={impact({ has_data: "unknown", truncated: false, schemas: [] })} />);
    expect(screen.getByTestId("uninstall-impact-headline")).toHaveTextContent(
      "No schemas of this version were found in wt_catalog under the expected names. Treat this uninstall as deleting data.",
    );
    expect(screen.getByTestId("uninstall-impact-confirm-input")).toBeInTheDocument();
  });

  it("only the shared _metrics schema, with no tables", () => {
    render(<UninstallImpactSummary impact={impact({
      has_data: "no",
      schemas: [{ name: "_metrics", owner: "", shared: true, objects_listed: true, tables: [], views: ["mv"], volumes: [] }],
    })} />);
    expect(screen.getByTestId("uninstall-impact-headline")).toHaveTextContent(
      "Uninstall drops the shared _metrics schema in wt_catalog. It holds no tables.",
    );
  });

  it("two schemas without tables read 'They hold no tables'", () => {
    const empty = impact({ has_data: "no" });
    empty.schemas = empty.schemas!.map((sc) => ({ ...sc, tables: [], volumes: [] }));
    render(<UninstallImpactSummary impact={empty} />);
    expect(screen.getByTestId("uninstall-impact-headline")).toHaveTextContent(
      "Uninstall drops 2 schemas in wt_catalog. They hold no tables.",
    );
  });

  it("unreadable catalog: treated as deleting data", () => {
    render(<UninstallImpactSummary impact={impact({ has_data: "unknown", truncated: true, schemas: [] })} />);
    expect(screen.getByTestId("uninstall-impact-headline")).toHaveTextContent(
      "Could not read the schemas in wt_catalog. Treat this uninstall as deleting data.",
    );
    expect(screen.getByTestId("uninstall-impact-confirm-input")).toBeInTheDocument();
  });

  it("marks the shared _metrics schema", () => {
    const withMetrics = impact();
    withMetrics.schemas!.push({
      name: "_metrics", owner: "app-sp", shared: true, objects_listed: true,
      tables: [], views: ["party_mv"], volumes: [],
    });
    render(<UninstallImpactSummary impact={withMetrics} />);
    const rows = screen.getAllByTestId("uninstall-impact-schema");
    expect(rows[2]).toHaveAttribute("data-shared", "true");
    expect(screen.getByTestId("uninstall-impact-shared")).toHaveTextContent(
      "Shared: holds the metric views of every model in this catalog.",
    );
    expect(screen.queryByTestId("uninstall-impact-shared-versions")).toBeNull();
  });

  it("names the other versions installed here that lose their metric views", () => {
    const withMetrics = impact();
    withMetrics.schemas!.push({
      name: "_metrics", owner: "app-sp", shared: true, objects_listed: true,
      tables: [], views: ["party_mv", "billing_mv"], volumes: [],
      other_versions: [
        { version_id: "mv-2", business_id: "b-1", business_name: "Retail Bank", scope: "mvm", version: 2 },
        { version_id: "mv-9", business_id: "b-2", business_name: "Fleet", scope: "ecm", version: 4 },
      ],
    });
    render(<UninstallImpactSummary impact={withMetrics} />);
    expect(screen.getByTestId("uninstall-impact-shared-versions")).toHaveTextContent(
      "Installed here and losing their metric views: Retail Bank MVM v2, Fleet ECM v4.",
    );
  });

  it("says which other catalogs the version is installed in", () => {
    render(<UninstallImpactSummary impact={impact({ installed_catalogs: [CATALOG, "second_cat"] })} />);
    expect(screen.getByTestId("uninstall-impact-installed")).toHaveTextContent(
      "This version is also installed in second_cat. This uninstall leaves that catalog alone; only wt_catalog is checked here.",
    );
  });

  it("says when the version is not recorded as installed in the catalog", () => {
    const { unmount } = render(
      <UninstallImpactSummary impact={impact({ installed_catalogs: ["second_cat", "third_cat"] })} />,
    );
    expect(screen.getByTestId("uninstall-impact-installed")).toHaveTextContent(
      "The app does not record this version as installed in wt_catalog; it is installed in second_cat, third_cat. This uninstall still drops what is listed here.",
    );
    unmount();
    render(<UninstallImpactSummary impact={impact({ installed_catalogs: [], schemas: [], has_data: "no" })} />);
    expect(screen.getByTestId("uninstall-impact-installed")).toHaveTextContent(
      "The app does not record this version as installed in wt_catalog.",
    );
    expect(screen.getByTestId("uninstall-impact-installed")).not.toHaveTextContent("still drops");
  });

  it("no install note when installed only here, or without install facts", () => {
    const { unmount } = render(<UninstallImpactSummary impact={impact({ installed_catalogs: [CATALOG] })} />);
    expect(screen.queryByTestId("uninstall-impact-installed")).toBeNull();
    unmount();
    render(<UninstallImpactSummary impact={impact()} />);
    expect(screen.queryByTestId("uninstall-impact-installed")).toBeNull();
  });

  it("a schema whose objects could not be listed does not read as empty", () => {
    const unlisted = impact({
      has_data: "unknown",
      truncated: true,
      reasons: ["The tables, views and volumes in these schemas could not be listed."],
      schemas: [{ name: "ecm_customer", owner: "", objects_listed: false, tables: [], views: [], volumes: [] }],
    });
    render(<UninstallImpactSummary impact={unlisted} />);
    const row = screen.getByTestId("uninstall-impact-schema");
    expect(row).toHaveTextContent("objects in this schema could not be listed");
    expect(row).not.toHaveTextContent("0 tables");
    expect(screen.getByTestId("uninstall-impact-headline")).toHaveTextContent(
      "The objects in these schemas could not be listed and may hold data.",
    );
    expect(screen.getByTestId("uninstall-impact-reasons")).toHaveTextContent(
      "The tables, views and volumes in these schemas could not be listed.",
    );
  });

  it("shows the server's reasons", () => {
    render(<UninstallImpactSummary impact={impact({
      has_data: "unknown",
      reasons: ["This version uses Catalog per Domain, so its schemas are in other catalogs."],
    })} />);
    expect(screen.getByTestId("uninstall-impact-reasons")).toHaveTextContent("Catalog per Domain");
  });

  it("names a table's kind when it is not a managed table", () => {
    const external = impact();
    external.schemas![1].tables![0].has_data = true;
    render(<UninstallImpactSummary impact={external} />);
    const lists = screen.getAllByTestId("uninstall-impact-tables-with-data");
    expect(lists[0]).toHaveTextContent("party");
    expect(lists[0]).not.toHaveTextContent("managed");
    expect(lists[1]).toHaveTextContent("stock (external)");
  });

  it("an inline callback does not re-report an unchanged state", () => {
    const calls: UninstallImpactConfirmState[] = [];
    const { rerender } = render(<UninstallImpactSummary impact={impact()} onStateChange={(st) => calls.push(st)} />);
    rerender(<UninstallImpactSummary impact={impact()} onStateChange={(st) => calls.push(st)} />);
    rerender(<UninstallImpactSummary impact={impact()} onStateChange={(st) => calls.push(st)} />);
    expect(calls).toHaveLength(1);
  });

  it("long lists end with 'and N more'", () => {
    const many = impact();
    many.schemas![0].views = Array.from({ length: 11 }, (_, i) => `v${i}`);
    render(<UninstallImpactSummary impact={many} />);
    expect(screen.getByTestId("uninstall-impact-views")).toHaveTextContent("v7 and 3 more");
  });
});

describe("UninstallImpactConfirm", () => {
  let fetchMock: ReturnType<typeof vi.fn>;

  beforeEach(() => {
    fetchMock = vi.fn();
    vi.stubGlobal("fetch", fetchMock);
  });

  afterEach(() => {
    vi.restoreAllMocks();
    vi.unstubAllGlobals();
  });

  function renderConfirm(
    spy = vi.fn(),
    catalogProp = CATALOG,
    style?: "One Catalog" | "Catalog per Division" | "Catalog per Domain",
  ) {
    const qc = new QueryClient({ defaultOptions: { queries: { retry: false } } });
    render(
      <QueryClientProvider client={qc}>
        <UninstallImpactConfirm
          businessId="b-1"
          versionId="mv-1"
          catalog={catalogProp}
          catalogingStyle={style}
          onStateChange={spy}
        />
      </QueryClientProvider>,
    );
    return spy;
  }

  it("loads the impact for the version and catalog", async () => {
    fetchMock.mockResolvedValueOnce({ ok: true, json: async () => impact() });
    const spy = renderConfirm();
    expect(screen.getByTestId("uninstall-impact-loading")).toBeInTheDocument();
    expect(lastState(spy)).toEqual({ status: "loading", needsConfirmation: true, confirmed: false });

    await waitFor(() => expect(screen.getAllByTestId("uninstall-impact-schema")).toHaveLength(2));
    expect(fetchMock.mock.calls[0][0]).toBe(
      "/api/businesses/b-1/versions/mv-1/uninstall-impact?catalog=wt_catalog",
    );
    expect(lastState(spy)).toEqual({ status: "ready", needsConfirmation: true, confirmed: false });
    typeCatalog(CATALOG);
    expect(lastState(spy).confirmed).toBe(true);
  });

  it("requireConfirmation asks for the typed name over a 'no data' impact and reads it again", async () => {
    const empty = impact({ has_data: "no", schemas: [{ name: "ecm_customer", owner: "", tables: [{ name: "party", kind: "MANAGED", has_data: false }], views: [], volumes: [] }] });
    fetchMock.mockImplementation(async () => ({ ok: true, json: async () => empty }));
    const spy = vi.fn();
    const qc = new QueryClient({ defaultOptions: { queries: { retry: false } } });
    const view = (require: boolean) => (
      <QueryClientProvider client={qc}>
        <UninstallImpactConfirm businessId="b-1" versionId="mv-1" catalog={CATALOG} onStateChange={spy} requireConfirmation={require} />
      </QueryClientProvider>
    );
    const { rerender } = render(view(false));
    await waitFor(() => expect(lastState(spy)).toEqual({ status: "ready", needsConfirmation: false, confirmed: true }));
    expect(screen.queryByTestId("uninstall-impact-confirm-input")).toBeNull();
    const calls = fetchMock.mock.calls.length;
    rerender(view(true));
    await waitFor(() => expect(lastState(spy)).toEqual({ status: "ready", needsConfirmation: true, confirmed: false }));
    await waitFor(() => expect(fetchMock.mock.calls.length).toBeGreaterThan(calls));
    expect(screen.getByTestId("uninstall-impact-server-asks")).toHaveTextContent("Treat this uninstall as deleting data.");
    typeCatalog(CATALOG);
    expect(lastState(spy).confirmed).toBe(true);
  });

  it("a style change resets the typed confirmation", async () => {
    fetchMock.mockImplementation(async () => ({ ok: true, json: async () => impact() }));
    const spy = vi.fn();
    const qc = new QueryClient({ defaultOptions: { queries: { retry: false } } });
    const view = (style?: "One Catalog" | "Catalog per Domain") => (
      <QueryClientProvider client={qc}>
        <UninstallImpactConfirm businessId="b-1" versionId="mv-1" catalog={CATALOG} catalogingStyle={style} onStateChange={spy} />
      </QueryClientProvider>
    );
    const { rerender } = render(view("One Catalog"));
    await waitFor(() => expect(screen.getByTestId("uninstall-impact-confirm-input")).toBeInTheDocument());
    typeCatalog(CATALOG);
    expect(lastState(spy).confirmed).toBe(true);
    rerender(view("Catalog per Domain"));
    await waitFor(() =>
      expect((screen.getByTestId("uninstall-impact-confirm-input") as HTMLInputElement).value).toBe(""),
    );
    expect(lastState(spy).confirmed).toBe(false);
  });

  it("passes the cataloging style", async () => {
    fetchMock.mockResolvedValueOnce({ ok: true, json: async () => impact() });
    renderConfirm(vi.fn(), CATALOG, "Catalog per Domain");
    await waitFor(() => expect(fetchMock).toHaveBeenCalled());
    expect(fetchMock.mock.calls[0][0]).toBe(
      "/api/businesses/b-1/versions/mv-1/uninstall-impact?catalog=wt_catalog&cataloging_style=Catalog+per+Domain",
    );
  });

  it("a failed check on a mixed-case catalog asks for the lower-case name", async () => {
    fetchMock.mockResolvedValueOnce({
      ok: false, status: 500, statusText: "Server Error", text: async () => JSON.stringify({ detail: "boom" }),
    });
    const spy = renderConfirm(vi.fn(), "WT_Catalog");
    await waitFor(() => expect(screen.getByTestId("uninstall-impact-error")).toBeInTheDocument());
    typeCatalog(CATALOG);
    expect(lastState(spy).confirmed).toBe(true);
  });

  it("a failed check shows the server message, needs the typed name and can retry", async () => {
    fetchMock.mockResolvedValueOnce({
      ok: false,
      status: 429,
      statusText: "Too Many Requests",
      text: async () =>
        JSON.stringify({
          detail: { message: "Too many uninstall checks in the last minute. Try again in 20 s.", retry_after_s: 20 },
        }),
    });
    const spy = renderConfirm();
    await waitFor(() => expect(screen.getByTestId("uninstall-impact-error")).toBeInTheDocument());
    expect(screen.getByTestId("uninstall-impact-error")).toHaveTextContent("Try again in 20 s.");
    expect(lastState(spy)).toEqual({ status: "error", needsConfirmation: true, confirmed: false });
    typeCatalog(CATALOG);
    expect(lastState(spy)).toEqual({ status: "error", needsConfirmation: true, confirmed: true });

    fetchMock.mockResolvedValueOnce({ ok: true, json: async () => impact({ has_data: "no", schemas: [] }) });
    fireEvent.click(screen.getByRole("button", { name: /check again/i }));
    await waitFor(() =>
      expect(screen.getByTestId("uninstall-impact-headline")).toHaveTextContent("Nothing will be dropped."),
    );
    expect(lastState(spy)).toEqual({ status: "ready", needsConfirmation: false, confirmed: true });
  });
});
