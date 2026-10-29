/**
 * `RelationshipAnalysis` rendering coverage.
 *
 * Reads `/api/businesses/{id}/versions/{v}/relationships` via
 * `useSuspenseQuery`. The component splits into three render branches:
 *   - happy: connectivity rows render with a horizontal-bar chart
 *   - all-intra-domain: shows the "all FKs are within domains" empty-ish card
 *   - zero-FK: shows the "no foreign key relationships" message
 *
 * We test happy + 4xx (which must bubble to the surrounding ErrorBoundary).
 */
import { afterEach, describe, expect, it, vi } from "vitest";
import { render, screen, waitFor } from "@testing-library/react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { Suspense } from "react";
import { ErrorBoundary } from "react-error-boundary";

import { RelationshipAnalysis } from "@/components/explorer/relationship-analysis";
import { useStrictConsole } from "./helpers/strict-console";
import { jsonResponse } from "./helpers/first-run";

function makeClient() {
  return new QueryClient({
    defaultOptions: { queries: { retry: false } },
  });
}

function renderAnalysis() {
  return render(
    <QueryClientProvider client={makeClient()}>
      <ErrorBoundary
        fallbackRender={({ error }) => (
          <div role="alert">Error: {String(error)}</div>
        )}
      >
        <Suspense fallback={<div data-testid="suspense-fallback" />}>
          <RelationshipAnalysis businessId="biz-1" version="1" scope="ecm" />
        </Suspense>
      </ErrorBoundary>
    </QueryClientProvider>,
  );
}

describe("RelationshipAnalysis", () => {
  const dom = useStrictConsole();

  afterEach(() => {
    vi.unstubAllGlobals();
  });

  it("renders FK stats and the connectivity chart on the happy path", async () => {
    vi.stubGlobal(
      "fetch",
      vi.fn(async () => ({
        ok: true,
        status: 200,
        json: async () => ({
          total_fk_count: 7,
          cross_domain_fk_count: 3,
          intra_domain_fk_count: 4,
          domain_connectivity: [
            { source_domain: "Sales", target_domain: "Inventory", fk_count: 2 },
            { source_domain: "Sales", target_domain: "Customer", fk_count: 1 },
          ],
        }),
      })),
    );
    renderAnalysis();
    await waitFor(() =>
      expect(screen.getByText(/Total FKs/i)).toBeInTheDocument(),
    );
    // Stat counts
    expect(screen.getByText("7")).toBeInTheDocument();
    expect(screen.getByText("3")).toBeInTheDocument();
    expect(screen.getByText("4")).toBeInTheDocument();
    // Connectivity table title
    expect(screen.getByText(/Domain Connectivity/i)).toBeInTheDocument();
    // Source / target domains rendered as text. Sales appears in both
    // rows so use getAllByText.
    expect(screen.getAllByText("Sales").length).toBeGreaterThan(0);
    expect(screen.getByText("Inventory")).toBeInTheDocument();
    expect(screen.getByText("Customer")).toBeInTheDocument();
    expect(dom.messages).toEqual([]);
  });

  it("renders the zero-FK empty-state message", async () => {
    vi.stubGlobal(
      "fetch",
      vi.fn(async () => ({
        ok: true,
        status: 200,
        json: async () => ({
          total_fk_count: 0,
          cross_domain_fk_count: 0,
          intra_domain_fk_count: 0,
          domain_connectivity: [],
        }),
      })),
    );
    renderAnalysis();
    await waitFor(() =>
      expect(
        screen.getByText(/No foreign key relationships found/i),
      ).toBeInTheDocument(),
    );
    expect(dom.messages).toEqual([]);
  });

  it("bubbles a 4xx Suspense rejection to the ErrorBoundary", async () => {
    // The Orval-generated `getRelationshipAnalysis` helper reads errors
    // via `res.text()`. Provide both `text()` and `json()` so the stub
    // matches both fetch contracts.
    vi.stubGlobal(
      "fetch",
      vi.fn(async () => jsonResponse(404, { detail: "not found" }, "Not Found")),
    );
    renderAnalysis();
    await waitFor(() =>
      expect(screen.getByRole("alert")).toHaveTextContent(/HTTP 404/i),
    );
    expect(dom.messages).toEqual([]);
  });
});
