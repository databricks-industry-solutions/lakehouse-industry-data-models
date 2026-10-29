import { describe, it, expect, vi, afterEach, beforeEach } from "vitest";
import {
  render,
  screen,
  fireEvent,
  within,
  waitFor,
} from "@testing-library/react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { ReactNode } from "react";
import type { ModelSummaryOut } from "@/lib/api";
import { StatisticsTab } from "@/components/statistics/statistics-tab";
import { findLoadedByTestId } from "./helpers/settled";

// The review-state control and feedback paths render <Link>; stub the router.
vi.mock("@tanstack/react-router", async (orig) => {
  const actual = await (orig() as Promise<Record<string, unknown>>);
  return {
    ...actual,
    Link: ({ children }: { children: ReactNode }) => <a>{children}</a>,
  };
});
vi.mock("sonner", () => ({ toast: { success: vi.fn(), error: vi.fn() } }));

function makeModel(overrides: Partial<ModelSummaryOut> = {}): ModelSummaryOut {
  return {
    name: "Test Retail",
    version: 2,
    domain_count: 3,
    product_count: 12,
    attribute_count: 80,
    fk_count: 9,
    subdomain_count: 5,
    domains: [
      { name: "sales", change_status: "new", product_count: 4 },
      { name: "inventory", change_status: "modified", product_count: 6 },
      { name: "finance", change_status: "unchanged", product_count: 2 },
      { name: "wishlist", change_status: "deleted", product_count: 1 },
    ],
    ...overrides,
  };
}

const EVOLUTION_MVM = {
  version_id: "mv-1",
  has_confidence: true,
  has_predecessor: true,
  has_metadata: true,
  quality: {
    confidence_score: 0.82,
    error_count: 2,
    warning_count: 5,
    issues_addressed: ["a", "b"],
    issues_not_addressed: ["c"],
  },
  change: {
    confidence_delta: 0.03,
    errors_delta: -1,
    warnings_delta: 2,
    unlinked_delta: 0,
    version_trend: "improving",
    version_history: [
      { version: "v0", confidence: 0.6, errors: 5, warnings: 3, products: 8, fks: 4 },
      { version: "v1", confidence: 0.75, errors: 3, warnings: 4, products: 10, fks: 6 },
      { version: "v2", confidence: 0.82, errors: 2, warnings: 5, products: 12, fks: 9 },
    ],
  },
  size: {
    domain_count: 3,
    product_count: 12,
    attribute_count: 80,
    fk_count: 9,
    avg_attributes_per_product: 6.7,
    unlinked_id_count: 1,
    siloed_count: 0,
  },
  effort: {
    total_ai_calls: 42,
    estimated_input_tokens: 100000,
    estimated_output_tokens: 50000,
    duration_hours: 1.5,
    estimated_total_cost_usd: 3.21,
  },
};

const NEXTVIBE_MODEL = {
  version_id: "mv-1",
  has_data: true,
  quality_score: 66,
  total_open: 11,
  counts: { total: 11, priority_remediation: 3, static_analysis: 6, other: 2 },
};

function domainNextVibe(name: string) {
  const open = name === "inventory" ? 9 : name === "sales" ? 4 : 0;
  return { version_id: "mv-1", domain_id: name, has_data: true, total_open: open };
}

function domainDetail(name: string) {
  return {
    name,
    products: [
      { id: "p-orders", fqn: `${name}.orders`, name: "orders", table_name: "orders", description: "", subdomain: "core", change_status: "new", attribute_count: 6, fk_count: 2 },
      { id: "p-returns", fqn: `${name}.returns`, name: "returns", table_name: "returns", description: "", subdomain: "core", change_status: "modified", attribute_count: 4, fk_count: 1 },
      { id: "p-ledger", fqn: `${name}.ledger`, name: "ledger", table_name: "ledger", description: "", subdomain: "audit", change_status: "unchanged", attribute_count: 3, fk_count: 0 },
    ],
  };
}

const REVIEW_PROGRESS = {
  version_id: "mv-1",
  reviewed: 3,
  review_needed: 8,
  no_review_needed: 1,
  review_pct: 0.375,
  total: 12,
};

// Per-domain review rollup (getReviewProgressByDomain): sales fully reviewed,
// inventory half, finance nothing-needs-review (review_needed 0 → tree "—").
const REVIEW_BY_DOMAIN = [
  { domain: "sales", domain_id: "d-sales", reviewed: 4, review_needed: 4, no_review_needed: 0, review_pct: 1 },
  { domain: "inventory", domain_id: "d-inv", reviewed: 2, review_needed: 4, no_review_needed: 2, review_pct: 0.5 },
  { domain: "finance", domain_id: "d-fin", reviewed: 0, review_needed: 0, no_review_needed: 2, review_pct: 0 },
];

// Joined to the named breakdown products by UUID. 'orders' needs review,
// 'returns' is reviewed, 'ledger' (unchanged) needs no review.
const PRODUCT_REVIEWS = [
  { product_id: "p-orders", product_name: "orders", fqn: "inventory.orders", version_id: "mv-1", state: "not_reviewed", is_explicit: false },
  { product_id: "p-returns", product_name: "returns", fqn: "inventory.returns", version_id: "mv-1", state: "reviewed", is_explicit: true },
  { product_id: "p-ledger", product_name: "ledger", fqn: "inventory.ledger", version_id: "mv-1", state: "no_review_needed", is_explicit: false },
];

function routeFor(url: string): unknown {
  if (url.includes("/evolution-metrics")) return EVOLUTION_MVM;
  if (url.match(/\/domains\/([^/]+)\/next-vibe-metrics/)) {
    const name = decodeURIComponent(url.match(/\/domains\/([^/]+)\/next-vibe-metrics/)![1]);
    return domainNextVibe(name);
  }
  if (url.endsWith("/next-vibe-metrics")) return NEXTVIBE_MODEL;
  if (url.match(/\/domains\/([^/]+)$/)) {
    const name = decodeURIComponent(url.match(/\/domains\/([^/]+)$/)![1]);
    return domainDetail(name);
  }
  if (url.endsWith("/review-progress/by-domain")) return REVIEW_BY_DOMAIN;
  if (url.endsWith("/review-progress")) return REVIEW_PROGRESS;
  if (url.endsWith("/reviews")) return PRODUCT_REVIEWS;
  return {};
}

function installFetch(override?: (url: string) => unknown) {
  vi.stubGlobal(
    "fetch",
    vi.fn(async (input: RequestInfo | URL) => {
      const url = typeof input === "string" ? input : input.toString();
      const body = override ? override(url) : routeFor(url);
      return { ok: true, status: 200, json: async () => body, text: async () => JSON.stringify(body) };
    }),
  );
}

function renderTab(props: Partial<Parameters<typeof StatisticsTab>[0]> = {}) {
  const qc = new QueryClient({ defaultOptions: { queries: { retry: false } } });
  return render(
    <QueryClientProvider client={qc}>
      <StatisticsTab
        model={makeModel()}
        scope="mvm"
        businessId="b1"
        versionInt={2}
        {...props}
      />
    </QueryClientProvider>,
  );
}

describe("StatisticsTab shell", () => {
  beforeEach(() => installFetch());
  afterEach(() => vi.restoreAllMocks());

  it("renders the tab shell with the scope tree + Model node + live domains", async () => {
    renderTab();
    expect(screen.getByTestId("statistics-tab")).toBeInTheDocument();
    const tree = screen.getByRole("navigation", { name: /scope/i });
    expect(within(tree).getByRole("button", { name: /^Model/ })).toBeInTheDocument();
    expect(within(tree).getByRole("button", { name: /sales/ })).toBeInTheDocument();
    expect(within(tree).getByRole("button", { name: /inventory/ })).toBeInTheDocument();
    expect(within(tree).queryByRole("button", { name: /wishlist/ })).not.toBeInTheDocument();
  });

  it("shows real per-domain review % in the scope tree (not '—')", async () => {
    renderTab();
    const tree = screen.getByRole("navigation", { name: /scope/i });
    // sales 100%, inventory 50% from getReviewProgressByDomain.
    await waitFor(() => {
      expect(within(tree).getByRole("button", { name: /sales/ })).toHaveTextContent("100%");
    });
    expect(within(tree).getByRole("button", { name: /inventory/ })).toHaveTextContent("50%");
    // finance has nothing needing review (review_needed 0) → "—".
    expect(within(tree).getByRole("button", { name: /finance/ })).toHaveTextContent("—");
  });

  it("defaults to the full-model view with model-only sections", async () => {
    renderTab();
    expect(await findLoadedByTestId("stats-section-where-to-focus")).toBeInTheDocument();
    expect(await findLoadedByTestId("stats-section-effort")).toBeInTheDocument();
    expect(screen.queryByTestId("stats-section-domain-breakdown")).not.toBeInTheDocument();
  });

  it("scope tree domain rows carry nav anchors (ExternalLink icon) when navContext is present", async () => {
    renderTab();
    const tree = screen.getByRole("navigation", { name: /scope/i });
    // StatisticsTab always provides navContext, so each live domain row gets
    // a Link (rendered as <a> by the mock) for navigating to the model view.
    // There are 3 live domains (sales, inventory, finance); wishlist is deleted.
    await waitFor(() => {
      const anchors = tree.querySelectorAll("a");
      expect(anchors.length).toBe(3);
    });
  });
});

describe("StatisticsTab — bound model sections", () => {
  beforeEach(() => installFetch());
  afterEach(() => vi.restoreAllMocks());

  it("binds the Quality section to next_vibes + evolution data", async () => {
    renderTab();
    const q = await findLoadedByTestId("stats-section-quality");
    // Quality score 66, confidence 82, errors 2 / warnings 5.
    expect(within(q).getByText("66")).toBeInTheDocument();
    expect(within(q).getByText("82")).toBeInTheDocument();
    expect(within(q).getByText("2")).toBeInTheDocument();
    expect(within(q).getByText("5")).toBeInTheDocument();
  });

  it("renders the Change Evolution small-multiples sparklines", async () => {
    renderTab();
    await screen.findByTestId("evolution-sparklines");
    expect(screen.getByTestId("evolution-row-confidence")).toBeInTheDocument();
    expect(screen.getByTestId("evolution-row-errors")).toBeInTheDocument();
    expect(screen.getByTestId("evolution-row-products")).toBeInTheDocument();
    expect(screen.getAllByTestId("sparkline").length).toBeGreaterThanOrEqual(5);
  });

  it("binds Work ahead to next_vibes category counts", async () => {
    renderTab();
    const w = await findLoadedByTestId("stats-section-work-ahead");
    expect(within(w).getByTestId("work-ahead-priority_remediation")).toHaveTextContent("3");
    expect(within(w).getByTestId("work-ahead-static_analysis")).toHaveTextContent("6");
    expect(within(w).getByTestId("work-ahead-other")).toHaveTextContent("2");
  });

  it("binds Size + Effort to evolution metrics", async () => {
    renderTab();
    const size = await findLoadedByTestId("stats-section-size");
    expect(within(size).getByText("12")).toBeInTheDocument(); // products
    const effort = await findLoadedByTestId("stats-section-effort");
    expect(within(effort).getByText("42")).toBeInTheDocument(); // AI calls
  });

  it("rounds avg attributes / product to 1 decimal even when the wire value is a raw float (finding #2)", async () => {
    vi.restoreAllMocks();
    installFetch((url) => {
      if (url.endsWith("/evolution-metrics")) {
        return {
          ...EVOLUTION_MVM,
          size: {
            ...EVOLUTION_MVM.size,
            avg_attributes_per_product: 41.161490683229815,
          },
        };
      }
      return routeFor(url);
    });
    renderTab();
    const size = await findLoadedByTestId("stats-section-size");
    expect(within(size).getByText(/41\.2 avg attributes \/ product/)).toBeInTheDocument();
    expect(within(size).queryByText(/41\.161/)).not.toBeInTheDocument();
  });
});

describe("StatisticsTab — Where to focus", () => {
  beforeEach(() => installFetch());
  afterEach(() => vi.restoreAllMocks());

  it("renders a ranked row per live domain with a Focus score", async () => {
    renderTab();
    await screen.findByTestId("focus-table");
    expect(screen.getByTestId("focus-row-sales")).toBeInTheDocument();
    expect(screen.getByTestId("focus-row-inventory")).toBeInTheDocument();
    expect(screen.getByTestId("focus-row-finance")).toBeInTheDocument();
  });

  it("labels the agent-findings column 'Open findings' and shows real per-domain reviewed %", async () => {
    renderTab();
    const table = await screen.findByTestId("focus-table");
    // Agent vibe-run findings — not user feedback.
    expect(within(table).getByText("Open findings")).toBeInTheDocument();
    expect(within(table).queryByText("Open inputs")).not.toBeInTheDocument();
    expect(within(table).getByText("Reviewed")).toBeInTheDocument();
    // Real per-domain reviewed % wired from getReviewProgressByDomain.
    await waitFor(() => {
      expect(within(screen.getByTestId("focus-row-sales")).getByText("100%")).toBeInTheDocument();
    });
    expect(within(screen.getByTestId("focus-row-inventory")).getByText("50%")).toBeInTheDocument();
  });

  it("default-sorts by Focus desc — inventory (9 open) above finance (0 open)", async () => {
    renderTab();
    const table = await screen.findByTestId("focus-table");
    await waitFor(() => {
      const rows = within(table).getAllByTestId(/focus-row-/);
      const names = rows.map((r) => r.getAttribute("data-testid"));
      expect(names.indexOf("focus-row-inventory")).toBeLessThan(
        names.indexOf("focus-row-finance"),
      );
    });
  });

  it("clicking a row drills into that domain (rebinds the report)", async () => {
    renderTab();
    fireEvent.click(await screen.findByTestId("focus-row-sales"));
    expect(await screen.findByTestId("stats-section-domain-breakdown")).toBeInTheDocument();
    expect(screen.queryByTestId("stats-section-where-to-focus")).not.toBeInTheDocument();
  });
});

describe("StatisticsTab — domain breakdown (marking surface)", () => {
  beforeEach(() => installFetch());
  afterEach(() => vi.restoreAllMocks());

  it("groups products by subdomain and embeds a marking control on each named row", async () => {
    renderTab();
    const tree = screen.getByRole("navigation", { name: /scope/i });
    fireEvent.click(within(tree).getByRole("button", { name: /inventory/ }));

    await screen.findByTestId("breakdown-groups");
    expect(screen.getByTestId("breakdown-subdomain-core")).toBeInTheDocument();
    expect(screen.getByTestId("breakdown-subdomain-audit")).toBeInTheDocument();
    // Each named product row carries its own ReviewStateControl (the two-block
    // workaround is gone) — orders + returns + ledger all expose marking.
    const orders = screen.getByTestId("breakdown-product-orders");
    expect(within(orders).getByRole("button", { name: /^Reviewed/ })).toBeInTheDocument();
    expect(within(orders).getByRole("button", { name: /Not reviewed/ })).toBeInTheDocument();
    // 'returns' is reviewed (explicit) → its Reviewed button is pressed.
    const returns = screen.getByTestId("breakdown-product-returns");
    expect(within(returns).getByRole("button", { name: /^Reviewed/ })).toHaveAttribute(
      "aria-pressed",
      "true",
    );
  });

  it("'Needs review only' filter hides unchanged (no-review-needed) products", async () => {
    renderTab();
    const tree = screen.getByRole("navigation", { name: /scope/i });
    fireEvent.click(within(tree).getByRole("button", { name: /inventory/ }));
    await screen.findByTestId("breakdown-groups");

    // 'ledger' is unchanged → no_review_needed → present before filtering.
    expect(screen.getByTestId("breakdown-product-ledger")).toBeInTheDocument();
    fireEvent.click(screen.getByRole("button", { name: /needs review only/i }));
    expect(screen.queryByTestId("breakdown-product-ledger")).not.toBeInTheDocument();
    // 'orders' (new) still shows.
    expect(screen.getByTestId("breakdown-product-orders")).toBeInTheDocument();
  });

  it("returns to the model view via Back to model", async () => {
    renderTab();
    const tree = screen.getByRole("navigation", { name: /scope/i });
    fireEvent.click(within(tree).getByRole("button", { name: /finance/ }));
    expect(await screen.findByTestId("stats-section-domain-breakdown")).toBeInTheDocument();
    fireEvent.click(screen.getByRole("button", { name: /back to model/i }));
    expect(await screen.findByTestId("stats-section-where-to-focus")).toBeInTheDocument();
    expect(screen.queryByTestId("stats-section-domain-breakdown")).not.toBeInTheDocument();
  });
});

describe("StatisticsTab — degradation", () => {
  afterEach(() => vi.restoreAllMocks());

  it("ECM: confidence degrades to NoData (n/a)", async () => {
    installFetch((url) =>
      url.includes("/evolution-metrics")
        ? { ...EVOLUTION_MVM, has_confidence: false }
        : routeFor(url),
    );
    renderTab({ scope: "ecm" });
    await findLoadedByTestId("stats-section-quality");
    expect(screen.getAllByTestId("no-data").length).toBeGreaterThan(0);
  });

  it("MVM with confidence: no NoData token in Quality", async () => {
    installFetch();
    renderTab();
    const q = await findLoadedByTestId("stats-section-quality");
    // The model Quality section confidence is present (82), so no n/a there.
    expect(within(q).getByText("82")).toBeInTheDocument();
    expect(within(q).queryByTestId("no-data")).not.toBeInTheDocument();
  });

  it("base version: Change collapses to a no-predecessor note + drops Changed column", async () => {
    installFetch((url) =>
      url.includes("/evolution-metrics")
        ? { ...EVOLUTION_MVM, has_predecessor: false }
        : routeFor(url),
    );
    renderTab();
    expect(await screen.findByTestId("base-version-note")).toBeInTheDocument();
    // 'Changed' header is dropped from the focus table on a base version.
    const table = await findLoadedByTestId("focus-table");
    expect(within(table).queryByText("Changed")).not.toBeInTheDocument();
  });
});
