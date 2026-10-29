/**
 * ModelView — DiagramViewer remounts on focal domain change (fix regression).
 *
 * When `diagramDomain` changes in place (e.g. the input-review route
 * re-renders `ModelTabsShell` → `ModelView` with a new anchor domain),
 * `DiagramViewer`'s internal `selectedDomain` useState was seeded only at
 * mount (item 3B removed the resync fallback), so the diagram kept showing the
 * OLD domain. The fix adds `key={diagramDomain ?? ""}` so React remounts
 * DiagramViewer on every focal-domain change.
 *
 * This test uses the REAL DiagramViewer (not a stub) with a mocked fetch,
 * rerenders `ModelView` with a new `diagramDomain`, and asserts a fresh
 * layout request goes to the NEW domain rather than staying on the old one.
 */
import { describe, it, expect, vi, beforeEach, afterEach } from "vitest";
import { render, waitFor, cleanup } from "@testing-library/react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";

class ResizeObserverStub {
  observe() {}
  unobserve() {}
  disconnect() {}
}
(globalThis as any).ResizeObserver = ResizeObserverStub;

if (!(globalThis as any).DOMMatrixReadOnly) {
  (globalThis as any).DOMMatrixReadOnly = class {
    m22 = 1;
    constructor() {}
  };
}

vi.mock("@/lib/api", async () => {
  const actual = await vi.importActual<typeof import("@/lib/api")>("@/lib/api");
  return {
    ...actual,
    useListVibeInputsSuspense: () => ({ data: [] }),
  };
});

import { ModelView } from "@/components/vibe-inputs/model-view";

function fetchUrls(impl: ReturnType<typeof vi.fn>) {
  return impl.mock.calls.map((c) => String(c[0]));
}

function mockLayoutFetch() {
  const impl = vi.fn((_url: string) =>
    Promise.resolve({
      status: 200,
      ok: true,
      json: () =>
        Promise.resolve({
          nodes: [],
          edges: [],
          groups: [],
          domain_filter: null,
          show_columns: false,
          total_products: 0,
          total_edges: 0,
        }),
    } as unknown as Response),
  );
  (globalThis as any).fetch = impl;
  return impl;
}

const baseProps = {
  businessId: "biz-1",
  version: "1",
  scope: "ecm",
  domains: [
    { name: "Sales", division: "GTM" },
    { name: "Inventory", division: "Ops" },
  ],
};

beforeEach(() => {
  vi.useRealTimers();
});

afterEach(() => {
  cleanup();
  vi.restoreAllMocks();
});

describe("ModelView — DiagramViewer remounts on focal domain change", () => {
  it("re-fetches the layout for the NEW domain when diagramDomain changes", async () => {
    const fetchImpl = mockLayoutFetch();
    const qc = new QueryClient({ defaultOptions: { queries: { retry: false } } });

    const { rerender } = render(
      <QueryClientProvider client={qc}>
        <ModelView
          {...baseProps}
          value="diagram"
          diagramDomain="Sales"
          modelVersionId="ver-1"
        />
      </QueryClientProvider>,
    );

    await waitFor(() => {
      expect(fetchUrls(fetchImpl).some((u) => u.includes("domain=Sales"))).toBe(true);
    });

    fetchImpl.mockClear();

    rerender(
      <QueryClientProvider client={qc}>
        <ModelView
          {...baseProps}
          value="diagram"
          diagramDomain="Inventory"
          modelVersionId="ver-1"
        />
      </QueryClientProvider>,
    );

    await waitFor(() => {
      expect(fetchUrls(fetchImpl).some((u) => u.includes("domain=Inventory"))).toBe(true);
    });
    expect(fetchUrls(fetchImpl).some((u) => u.includes("domain=Sales"))).toBe(false);
  });
});
