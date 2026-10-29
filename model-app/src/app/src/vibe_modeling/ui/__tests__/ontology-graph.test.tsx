/**
 * `OntologyGraph` rendering coverage.
 *
 * The graph reads two endpoints (`/model` and per-domain detail) via
 * `useSuspenseQuery`. We stub `fetch` directly: that's the smallest
 * surface and matches the route helpers used elsewhere in the suite.
 *
 * Two scenarios:
 *   1. Happy path with two domains and a couple of products — the
 *      view-toggle buttons (Clustered / Circular / Concentric /
 *      Sunburst) all render and the stats line picks up the totals.
 *   2. Empty model (no domains, no products) — the graph still mounts
 *      with the stats line at zero. No crash from empty arrays.
 */
import { afterEach, beforeAll, describe, expect, it, vi } from "vitest";
import { act, fireEvent, render, screen, waitFor } from "@testing-library/react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { Suspense } from "react";
import { ErrorBoundary } from "react-error-boundary";

import { OntologyGraph } from "@/components/explorer/ontology-graph";
import { PRODUCT_TYPE_COLORS } from "@/components/diagram/constants";
import { diagramColors } from "@/components/diagram/diagram-colors";
import { useStrictConsole } from "./helpers/strict-console";

beforeAll(() => {
  if (!window.matchMedia) {
    Object.defineProperty(window, "matchMedia", {
      writable: true,
      value: (q: string) => ({
        matches: false,
        media: q,
        onchange: null,
        addListener: () => {},
        removeListener: () => {},
        addEventListener: () => {},
        removeEventListener: () => {},
        dispatchEvent: () => false,
      }),
    });
  }
});

function makeClient() {
  return new QueryClient({
    defaultOptions: { queries: { retry: false } },
  });
}

function stubGraphFetch(opts: {
  modelSummary: unknown;
  domainDetail: (name: string) => unknown;
}) {
  vi.stubGlobal(
    "fetch",
    vi.fn(async (url: RequestInfo) => {
      const u = String(url);
      if (u.includes("/domains/")) {
        const decoded = decodeURIComponent(u.split("/domains/")[1]);
        return {
          ok: true,
          status: 200,
          json: async () => opts.domainDetail(decoded),
        };
      }
      // /model endpoint
      return {
        ok: true,
        status: 200,
        json: async () => opts.modelSummary,
      };
    }),
  );
}

function renderGraph(onDomainChange?: (domain: string | null) => void) {
  return render(
    <QueryClientProvider client={makeClient()}>
      <ErrorBoundary fallbackRender={({ error }) => <div role="alert">{String(error)}</div>}>
        <Suspense fallback={<div data-testid="suspense-fallback" />}>
          <OntologyGraph businessId="biz-1" version="1" scope="ecm" onDomainChange={onDomainChange} />
        </Suspense>
      </ErrorBoundary>
    </QueryClientProvider>,
  );
}

describe("OntologyGraph", () => {
  const dom = useStrictConsole();

  afterEach(() => {
    vi.unstubAllGlobals();
  });

  it("renders the view-toggle buttons and stats line for a populated model", async () => {
    stubGraphFetch({
      modelSummary: {
        name: "Test Biz",
        domain_count: 2,
        product_count: 3,
        attribute_count: 12,
        domains: [
          { name: "Sales", product_count: 2 },
          { name: "Inventory", product_count: 1 },
        ],
      },
      domainDetail: (name) =>
        name === "Sales"
          ? {
              name: "Sales",
              products: [
                {
                  name: "Order",
                  table_name: "orders",
                  attribute_count: 4,
                  fk_count: 1,
                  fk_targets: ["Inventory.products"],
                },
                {
                  name: "Customer",
                  table_name: "customers",
                  attribute_count: 5,
                  fk_count: 0,
                  fk_targets: [],
                },
              ],
            }
          : {
              name: "Inventory",
              products: [
                {
                  name: "Product",
                  table_name: "products",
                  attribute_count: 3,
                  fk_count: 0,
                  fk_targets: [],
                },
              ],
            },
    });
    renderGraph();
    // View toggles all render
    await waitFor(() => {
      expect(
        screen.getByRole("button", { name: /Clustered/i }),
      ).toBeInTheDocument();
    });
    expect(
      screen.getByRole("button", { name: /^Circular$/i }),
    ).toBeInTheDocument();
    expect(
      screen.getByRole("button", { name: /^Concentric$/i }),
    ).toBeInTheDocument();
    expect(
      screen.getByRole("button", { name: /^Sunburst$/i }),
    ).toBeInTheDocument();
    // Stats line (text is split across spans, so use a regex)
    expect(screen.getByText(/2 domains/i)).toBeInTheDocument();
    expect(screen.getByText(/3 tables/i)).toBeInTheDocument();
    expect(dom.messages).toEqual([]);
  });

  it("renders the domain selector as a dropdown and shows the product-type legend", async () => {
    stubGraphFetch({
      modelSummary: {
        name: "Test Biz",
        domain_count: 1,
        product_count: 1,
        attribute_count: 3,
        domains: [{ name: "Sales", product_count: 1 }],
      },
      domainDetail: () => ({
        name: "Sales",
        products: [
          {
            name: "Order",
            table_name: "orders",
            type: "Transactional",
            attribute_count: 3,
            fk_count: 0,
            fk_targets: [],
          },
        ],
      }),
    });
    const { container } = renderGraph();
    // Domain selector is now a Radix <Select> trigger (combobox role),
    // not a row of buttons. Wait for the data to load first.
    await waitFor(() => {
      expect(screen.getByRole("combobox")).toBeInTheDocument();
    });
    // Legend swatches mount alongside the selector.
    expect(screen.getByText(/^Master$/)).toBeInTheDocument();
    expect(screen.getByText(/^Transactional$/)).toBeInTheDocument();
    expect(screen.getByText(/^Reference$/)).toBeInTheDocument();
    expect(screen.getByText(/^Association$/)).toBeInTheDocument();
    expect(screen.getByText(/^Other$/)).toBeInTheDocument();
    // Node circles are SVG <circle> elements colored by product type.
    // For a single Transactional product, we expect at least one circle
    // filled with the canonical Transactional hex.
    const expectedHex = PRODUCT_TYPE_COLORS.Transactional.hex.toLowerCase();
    const circles = Array.from(
      container.querySelectorAll<SVGCircleElement>("circle"),
    );
    const matched = circles.filter(
      (c) => c.getAttribute("fill")?.toLowerCase() === expectedHex,
    );
    expect(matched.length).toBeGreaterThan(0);
    expect(dom.messages).toEqual([]);
  });

  it("reports the chosen domain for Add-feedback on every layout", async () => {
    stubGraphFetch({
      modelSummary: {
        name: "Test Biz",
        domain_count: 1,
        product_count: 1,
        attribute_count: 3,
        domains: [{ name: "Sales", product_count: 1 }],
      },
      domainDetail: () => ({
        name: "Sales",
        products: [
          { name: "Order", table_name: "orders", type: "Transactional", attribute_count: 3, fk_count: 0, fk_targets: [] },
        ],
      }),
    });
    const onDomainChange = vi.fn();
    renderGraph(onDomainChange);
    await waitFor(() => expect(screen.getByRole("combobox")).toBeInTheDocument());
    expect(onDomainChange).toHaveBeenLastCalledWith(null);

    fireEvent.click(screen.getByRole("combobox"));
    fireEvent.click(await screen.findByRole("option", { name: /Sales/ }));
    expect(onDomainChange).toHaveBeenLastCalledWith("Sales");

    fireEvent.click(screen.getByRole("button", { name: "Circular" }));
    expect(onDomainChange).toHaveBeenLastCalledWith("Sales");
  });

  const TWO_DOMAINS = {
    modelSummary: {
      name: "Test Biz",
      domain_count: 2,
      product_count: 3,
      attribute_count: 9,
      domains: [
        { name: "Sales", product_count: 2 },
        { name: "Inventory", product_count: 1 },
        { name: "Legacy", product_count: 0, change_status: "deleted" },
      ],
    },
    domainDetail: (name: string) =>
      name === "Sales"
        ? {
            name: "Sales",
            products: [
              // One cross-domain FK: Sales.orders -> Inventory.products.
              { name: "Order", table_name: "orders", attribute_count: 3, fk_count: 1, fk_targets: ["Inventory.products"] },
              { name: "Customer", table_name: "customers", attribute_count: 3, fk_count: 0, fk_targets: [] },
            ],
          }
        : {
            name: "Inventory",
            products: [
              { name: "Product", table_name: "products", attribute_count: 3, fk_count: 0, fk_targets: [] },
            ],
          },
  };

  it("lists the model's live domains, in model order, in the dropdown", async () => {
    stubGraphFetch(TWO_DOMAINS);
    renderGraph();
    fireEvent.click(await screen.findByRole("combobox"));
    const names = (await screen.findAllByRole("option")).map((o) => o.textContent);
    expect(names).toEqual(["All domains", "Sales", "Inventory"]);
  });

  // Inventory chosen, cross-domain edges shown: the node layouts also draw
  // Sales.orders (the far end of Inventory's FK), never the unconnected
  // Sales.customers; the Sunburst shows Inventory's own tables. Center labels
  // count the chosen domain only, never the far-end domains.
  it.each([
    ["Clustered", [], true],
    ["Circular", ["1 tables"], true],
    ["Concentric", ["1 domains, 1 tables"], true],
    ["Sunburst", ["1 domains", "1 tables"], false],
  ] as const)("the %s layout keeps the dropdown, draws the chosen domain and counts it in the center", async (layout, centerLabels, drawsFarEnd) => {
    stubGraphFetch(TWO_DOMAINS);
    const { container } = renderGraph();
    const box = await screen.findByRole("combobox");
    // The whole-model counts line shows only while no domain is chosen.
    expect(screen.queryAllByText(/2 domains, 3 tables/).length).toBeGreaterThan(0);
    fireEvent.click(box);
    fireEvent.click(await screen.findByRole("option", { name: /Inventory/ }));
    fireEvent.click(screen.getByRole("button", { name: layout }));
    expect(screen.getByRole("combobox")).toHaveTextContent("Inventory");
    expect(screen.queryAllByText(/2 domains, 3 tables/)).toHaveLength(0);
    const texts = Array.from(container.querySelectorAll("text, title")).map((t) => (t.textContent ?? "").trim());
    expect(texts.some((t) => /products/.test(t))).toBe(true);
    expect(texts.some((t) => /customers/.test(t))).toBe(false);
    expect(texts.some((t) => /orders/.test(t))).toBe(drawsFarEnd);
    for (const label of centerLabels) expect(texts).toContain(label);
    expect(texts.some((t) => /^[2-9]\d* domains/.test(t))).toBe(false);
  });

  it("in host mode, a new domainFilter re-scopes the graph and onDomainChange follows it", async () => {
    stubGraphFetch(TWO_DOMAINS);
    const onDomainChange = vi.fn();
    const onDomainPick = vi.fn();
    const client = makeClient();
    const ui = (domain: string) => (
      <QueryClientProvider client={client}>
        <Suspense fallback={<div data-testid="suspense-fallback" />}>
          <OntologyGraph
            businessId="biz-1"
            version="1"
            scope="ecm"
            domainFilter={domain}
            onDomainChange={onDomainChange}
            onDomainPick={onDomainPick}
          />
        </Suspense>
      </QueryClientProvider>
    );
    const { rerender } = render(ui("Sales"));
    await waitFor(() => expect(screen.getByRole("combobox")).toHaveTextContent("Sales"));
    expect(onDomainChange).toHaveBeenLastCalledWith("Sales");
    rerender(ui("Inventory"));
    await waitFor(() => expect(screen.getByRole("combobox")).toHaveTextContent("Inventory"));
    expect(onDomainChange).toHaveBeenLastCalledWith("Inventory");
    fireEvent.click(screen.getByRole("button", { name: "Sunburst" }));
    expect(onDomainChange).toHaveBeenLastCalledWith("Inventory");
  });

  it("with onDomainPick, the dropdown shows domainFilter and a pick calls the host instead of filtering", async () => {
    stubGraphFetch({
      modelSummary: {
        name: "Test Biz",
        domain_count: 2,
        product_count: 2,
        attribute_count: 6,
        domains: [
          { name: "Sales", product_count: 1 },
          { name: "Inventory", product_count: 1 },
        ],
      },
      domainDetail: (name) => ({
        name,
        products: [
          { name: `${name}Item`, table_name: `${name.toLowerCase()}_items`, attribute_count: 3, fk_count: 0, fk_targets: [] },
        ],
      }),
    });
    const onDomainPick = vi.fn();
    const onDomainChange = vi.fn();
    render(
      <QueryClientProvider client={makeClient()}>
        <Suspense fallback={<div data-testid="suspense-fallback" />}>
          <OntologyGraph
            businessId="biz-1"
            version="1"
            scope="ecm"
            domainFilter="Sales"
            onDomainChange={onDomainChange}
            onDomainPick={onDomainPick}
          />
        </Suspense>
      </QueryClientProvider>,
    );
    const box = await screen.findByRole("combobox");
    expect(box).toHaveTextContent("Sales");
    expect(onDomainChange).toHaveBeenLastCalledWith("Sales");

    fireEvent.click(box);
    fireEvent.click(await screen.findByRole("option", { name: /Inventory/ }));
    expect(onDomainPick).toHaveBeenLastCalledWith("Inventory");
    // The host owns the value: nothing changes until it re-renders with a new domainFilter.
    expect(screen.getByRole("combobox")).toHaveTextContent("Sales");

    fireEvent.click(screen.getByRole("combobox"));
    fireEvent.click(await screen.findByRole("option", { name: "All domains" }));
    expect(onDomainPick).toHaveBeenLastCalledWith(null);
  });

  it("colors intra-domain edges with the unified light-slate stroke", async () => {
    stubGraphFetch({
      modelSummary: {
        name: "Test Biz",
        domain_count: 1,
        product_count: 2,
        attribute_count: 5,
        domains: [{ name: "Sales", product_count: 2 }],
      },
      domainDetail: () => ({
        name: "Sales",
        products: [
          {
            name: "Order",
            table_name: "orders",
            attribute_count: 3,
            fk_count: 1,
            // intra-domain FK: orders -> customers, both in Sales
            fk_targets: ["Sales.customers"],
          },
          {
            name: "Customer",
            table_name: "customers",
            attribute_count: 2,
            fk_count: 0,
            fk_targets: [],
          },
        ],
      }),
    });
    const { container } = renderGraph();
    await waitFor(() => {
      expect(container.querySelector('[data-testid="ontology-edge-intra"]'))
        .not.toBeNull();
    });
    const intra = container.querySelector('[data-testid="ontology-edge-intra"]')!;
    // Stroke is sourced from the `--diagram-edge-intra` custom property via the
    // diagram-colors helper, not a raw hex literal. Lock against that token.
    expect(intra.getAttribute("stroke")?.toLowerCase()).toBe(
      diagramColors().edgeIntra.toLowerCase(),
    );
    expect(dom.messages).toEqual([]);
  });

  it("renders domain labels with the (division) suffix when provided", async () => {
    stubGraphFetch({
      modelSummary: {
        name: "Test Biz",
        domain_count: 1,
        product_count: 1,
        attribute_count: 3,
        domains: [{ name: "Sales", product_count: 1, division: "Operations" }],
      },
      domainDetail: () => ({
        name: "Sales",
        division: "Operations",
        products: [
          {
            name: "Order",
            table_name: "orders",
            attribute_count: 3,
            fk_count: 0,
            fk_targets: [],
          },
        ],
      }),
    });
    renderGraph();
    await waitFor(() => {
      expect(screen.getByText(/Sales \(Operations\)/)).toBeInTheDocument();
    });
    expect(dom.messages).toEqual([]);
  });

  it("anchors wheel zoom at the cursor (pan adjusts as zoom changes)", async () => {
    stubGraphFetch({
      modelSummary: {
        name: "Test Biz",
        domain_count: 1,
        product_count: 1,
        attribute_count: 1,
        domains: [{ name: "Sales", product_count: 1 }],
      },
      domainDetail: () => ({
        name: "Sales",
        products: [{ name: "Order", table_name: "orders", attribute_count: 1, fk_count: 0, fk_targets: [] }],
      }),
    });
    const { container } = renderGraph();
    // The zoom-pan wrapper renders an outer <div> containing an SVG with a single <g transform="...">.
    await waitFor(() => {
      expect(container.querySelector("svg g[transform]")).not.toBeNull();
    });
    const g = container.querySelector("svg g[transform]")!;
    const initial = g.getAttribute("transform") ?? "";
    const svg = g.closest("svg")!;
    const wrapper = svg.parentElement!;
    vi.spyOn(wrapper, "getBoundingClientRect").mockReturnValue({
      x: 0, y: 0, top: 0, left: 0, right: 800, bottom: 600, width: 800, height: 600,
      toJSON: () => ({}),
    } as DOMRect);
    act(() => {
      fireEvent.wheel(svg, { deltaY: -200, clientX: 100, clientY: 50 });
    });
    const updated = g.getAttribute("transform") ?? "";
    // Cursor-anchored math always shifts pan when zoom changes at a non-origin cursor.
    expect(updated).not.toBe(initial);
    expect(updated).not.toMatch(/translate\(0,0\)/);
    expect(dom.messages).toEqual([]);
  });

  it("zooms the Sunburst view via the wheel (transform attribute updates)", async () => {
    stubGraphFetch({
      modelSummary: {
        name: "Test Biz",
        domain_count: 1,
        product_count: 1,
        attribute_count: 1,
        domains: [{ name: "Sales", product_count: 1 }],
      },
      domainDetail: () => ({
        name: "Sales",
        products: [{ name: "Order", table_name: "orders", attribute_count: 1, fk_count: 0, fk_targets: [] }],
      }),
    });
    const { container } = renderGraph();
    await waitFor(() => {
      expect(screen.getByRole("button", { name: /Sunburst/i })).toBeInTheDocument();
    });
    fireEvent.click(screen.getByRole("button", { name: /Sunburst/i }));
    // Sunburst's <g> initial transform is `translate(0,0) scale(0.8)` — wait
    // for that specific value to confirm the new view rendered.
    await waitFor(() => {
      const node = container.querySelector("svg g[transform]");
      expect(node?.getAttribute("transform")).toMatch(/scale\(0\.8\)/);
    });
    const g = container.querySelector("svg g[transform]")!;
    const before = g.getAttribute("transform") ?? "";
    const svg = g.closest("svg")!;
    const wrapper = svg.parentElement!;
    vi.spyOn(wrapper, "getBoundingClientRect").mockReturnValue({
      x: 0, y: 0, top: 0, left: 0, right: 800, bottom: 600, width: 800, height: 600,
      toJSON: () => ({}),
    } as DOMRect);
    act(() => {
      fireEvent.wheel(svg, { deltaY: -250, clientX: 200, clientY: 200 });
    });
    expect(g.getAttribute("transform") ?? "").not.toBe(before);
    expect(dom.messages).toEqual([]);
  });

  it("FK total comes from the model summary and excludes deleted predecessor products", async () => {
    // `getDomainDetail` appends a `deleted` predecessor product carrying its
    // own historical fk_count. The header FK total must equal the canonical
    // `summary.fk_count` (3) and NOT re-sum the domain-detail products (which
    // would add the deleted product's 5 -> 8). Connections are surfaced
    // separately.
    stubGraphFetch({
      modelSummary: {
        name: "Test Biz",
        domain_count: 1,
        product_count: 2,
        attribute_count: 10,
        fk_count: 3,
        domains: [{ name: "Sales", product_count: 2 }],
      },
      domainDetail: () => ({
        name: "Sales",
        products: [
          {
            name: "Order",
            table_name: "orders",
            attribute_count: 5,
            fk_count: 3,
            fk_targets: ["Sales.customers"],
          },
          {
            name: "Customer",
            table_name: "customers",
            attribute_count: 5,
            fk_count: 0,
            fk_targets: [],
          },
          {
            name: "Legacy",
            table_name: "legacy",
            attribute_count: 5,
            fk_count: 5,
            fk_targets: [],
            change_status: "deleted",
          },
        ],
      }),
    });
    renderGraph();
    await waitFor(() => {
      expect(screen.getByText(/3 FKs/)).toBeInTheDocument();
    });
    // The deleted product's 5 FKs must not have inflated the total to 8.
    expect(screen.queryByText(/8 FKs/)).not.toBeInTheDocument();
    // Connection metric is presented as a distinct, separately-labelled number.
    expect(screen.getByText(/table-pair connection/)).toBeInTheDocument();
    expect(dom.messages).toEqual([]);
  });

  it("collapses multiple FKs between the same table pair into one connection", async () => {
    // Order references Customer via two FK columns. The header shows the full
    // FK count (summary, 2) but exactly ONE table-pair connection.
    stubGraphFetch({
      modelSummary: {
        name: "Test Biz",
        domain_count: 1,
        product_count: 2,
        attribute_count: 6,
        fk_count: 2,
        domains: [{ name: "Sales", product_count: 2 }],
      },
      domainDetail: () => ({
        name: "Sales",
        products: [
          {
            name: "Order",
            table_name: "orders",
            attribute_count: 4,
            fk_count: 2,
            // two FK columns, both to Sales.customers
            fk_targets: ["Sales.customers"],
          },
          {
            name: "Customer",
            table_name: "customers",
            attribute_count: 2,
            fk_count: 0,
            fk_targets: [],
          },
        ],
      }),
    });
    const { container } = renderGraph();
    await waitFor(() => {
      expect(screen.getByText(/2 FKs/)).toBeInTheDocument();
    });
    expect(screen.getByText(/1 table-pair connection\b/)).toBeInTheDocument();
    // Exactly one edge is drawn for the pair.
    await waitFor(() => {
      const edges = container.querySelectorAll('[data-testid^="ontology-edge"]');
      expect(edges.length).toBe(1);
    });
    expect(dom.messages).toEqual([]);
  });

  it("excludes dangling fk_targets from connections while the FK total stays from the summary", async () => {
    // Order has an FK to a table outside the model. It counts toward the
    // canonical FK total (summary, 1) but draws no edge, so connections = 0.
    stubGraphFetch({
      modelSummary: {
        name: "Test Biz",
        domain_count: 1,
        product_count: 1,
        attribute_count: 4,
        fk_count: 1,
        domains: [{ name: "Sales", product_count: 1 }],
      },
      domainDetail: () => ({
        name: "Sales",
        products: [
          {
            name: "Order",
            table_name: "orders",
            attribute_count: 4,
            fk_count: 1,
            fk_targets: ["Ghost.missing"],
          },
        ],
      }),
    });
    const { container } = renderGraph();
    await waitFor(() => {
      expect(screen.getByText(/1 FKs/)).toBeInTheDocument();
    });
    expect(screen.getByText(/0 table-pair connections/)).toBeInTheDocument();
    const edges = container.querySelectorAll('[data-testid^="ontology-edge"]');
    expect(edges.length).toBe(0);
    expect(dom.messages).toEqual([]);
  });

  it("renders the empty-graph case with zero stats and no crash", async () => {
    stubGraphFetch({
      modelSummary: {
        name: "Empty Biz",
        domain_count: 0,
        product_count: 0,
        attribute_count: 0,
        domains: [],
      },
      domainDetail: () => ({ name: "", products: [] }),
    });
    renderGraph();
    await waitFor(() => {
      expect(
        screen.getByRole("button", { name: /Clustered/i }),
      ).toBeInTheDocument();
    });
    expect(screen.getByText(/0 domains/i)).toBeInTheDocument();
    expect(screen.getByText(/0 tables/i)).toBeInTheDocument();
    // Sanity: no error-boundary fallback
    expect(screen.queryByRole("alert")).not.toBeInTheDocument();
    expect(dom.messages).toEqual([]);
  });
});
