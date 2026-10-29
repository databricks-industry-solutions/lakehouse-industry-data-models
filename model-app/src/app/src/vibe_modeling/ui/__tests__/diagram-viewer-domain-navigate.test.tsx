/**
 * `DiagramViewer` domain-navigate prop surface (items 3A/3B, 0.6.6).
 *
 * `onDomainNavigate` lets a host route domain selection through the URL
 * instead of an internal `selectedDomain` state. Item 3B deleted that
 * internal-state fallback (every in-tree embedder now navigates on domain
 * change), so `onDomainNavigate` absent means domain-change interactions
 * are simply inert - no local state mutation, no re-fetch.
 */
import { describe, it, expect, vi, beforeEach, afterEach } from "vitest";
import { render, screen, waitFor, cleanup, fireEvent } from "@testing-library/react";
import { DiagramViewer } from "@/components/diagram/diagram-viewer";

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

const layout = {
  nodes: [],
  edges: [],
  groups: [],
  domain_filter: null,
  show_columns: false,
  total_products: 0,
  total_edges: 0,
};

function mockLayoutFetch() {
  const impl = vi.fn((_url: string) =>
    Promise.resolve({
      status: 200,
      ok: true,
      json: () => Promise.resolve(layout),
    } as unknown as Response),
  );
  (globalThis as any).fetch = impl;
  return impl;
}

const domains = [
  { name: "A", division: "Commercial" },
  { name: "B", division: "Commercial" },
];

beforeEach(() => {
  vi.useRealTimers();
});

afterEach(() => {
  cleanup();
  vi.restoreAllMocks();
});

async function openDomainSelectAndPick(name: string) {
  await waitFor(() => {
    expect(screen.getAllByRole("combobox").length).toBeGreaterThan(0);
  });
  // Domain-select renders first in the toolbar (diagram-controls.tsx).
  const boxes = screen.getAllByRole("combobox");
  fireEvent.click(boxes[0]);
  fireEvent.click(await screen.findByText(name));
}

describe("DiagramViewer - onDomainNavigate (items 3A/3B, 0.6.6)", () => {
  it("calls onDomainNavigate when provided", async () => {
    mockLayoutFetch();
    const onDomainNavigate = vi.fn();
    render(
      <DiagramViewer
        businessId="biz-1"
        version="1"
        scope="ecm"
        domains={domains}
        onDomainNavigate={onDomainNavigate}
      />,
    );
    await openDomainSelectAndPick("A");
    expect(onDomainNavigate).toHaveBeenCalledWith("A");
  });

  it("is inert (no re-fetch) when onDomainNavigate is absent (item 3B: internal fallback deleted)", async () => {
    const fetchImpl = mockLayoutFetch();
    render(
      <DiagramViewer businessId="biz-1" version="1" scope="ecm" domains={domains} />,
    );
    await openDomainSelectAndPick("A");
    // No local state to mutate anymore, so no second fetch ever fires with
    // domain=A - only the initial all-domains fetch (domain unset) happens.
    await new Promise((r) => setTimeout(r, 50));
    const urls = fetchImpl.mock.calls.map((c) => c[0]);
    expect(urls.some((u) => String(u).includes("domain=A"))).toBe(false);
  });

  it("shows the toolbar domain dropdown by default", async () => {
    mockLayoutFetch();
    render(
      <DiagramViewer businessId="biz-1" version="1" scope="ecm" domains={domains} />,
    );
    await waitFor(() => {
      expect(screen.getAllByRole("combobox").length).toBeGreaterThan(0);
    });
    expect(screen.getByText("All domains")).toBeInTheDocument();
  });

  it("hides the toolbar domain dropdown when showDomainSelect is false", async () => {
    mockLayoutFetch();
    render(
      <DiagramViewer
        businessId="biz-1"
        version="1"
        scope="ecm"
        domains={domains}
        showDomainSelect={false}
      />,
    );
    await waitFor(() => {
      // The column-mode Select is still there, so at least one combobox
      // renders - but "All domains" (the domain-select placeholder text)
      // must be gone.
      expect(screen.getAllByRole("combobox").length).toBeGreaterThan(0);
    });
    expect(screen.queryByText("All domains")).not.toBeInTheDocument();
  });
});

describe("DiagramViewer - domain dropdown when the layout fails", () => {
  function mockFailingFetch() {
    (globalThis as any).fetch = vi.fn(() => Promise.reject(new Error("layout failed")));
  }

  it("still offers the domain dropdown on the error card, and it navigates", async () => {
    mockFailingFetch();
    const onDomainNavigate = vi.fn();
    render(
      <DiagramViewer
        businessId="biz-1"
        version="1"
        scope="ecm"
        domains={domains}
        onDomainNavigate={onDomainNavigate}
      />,
    );
    expect(await screen.findByText("Failed to load diagram")).toBeInTheDocument();
    expect(screen.getByRole("button", { name: "Retry" })).toBeInTheDocument();
    await openDomainSelectAndPick("A");
    expect(onDomainNavigate).toHaveBeenCalledWith("A");
  });

  it("keeps the dropdown hidden on the error card when showDomainSelect is false", async () => {
    mockFailingFetch();
    render(
      <DiagramViewer
        businessId="biz-1"
        version="1"
        scope="ecm"
        domains={domains}
        showDomainSelect={false}
      />,
    );
    expect(await screen.findByText("Failed to load diagram")).toBeInTheDocument();
    expect(screen.queryAllByRole("combobox")).toHaveLength(0);
  });
});
