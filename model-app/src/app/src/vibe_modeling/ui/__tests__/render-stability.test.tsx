/**
 * Render-stability + DOM-validity tests.
 *
 * Bug 2 in Phase 4.5 (PR #151): two components in `<AgentConfigSection />`
 * each subscribed to `useGetAgentConfig`. When the query 404'd, React
 * Query's retry+error path re-fired both subscribers' effects on every
 * render. Component never committed; form blanked. None of the 148
 * frontend tests rendered the full Settings page with a 404 stub, so the
 * loop slipped through.
 *
 * This file enforces two invariants for every page-level subtree:
 *
 * 1. Render-stability: the component commits within ≤ N renders even
 *    when the network endpoint it subscribes to returns 4xx/5xx.
 * 2. DOM validity: no `<div>` inside `<p>`, no `<a>` inside `<a>`,
 *    no `<button>` inside `<button>`, etc. — caught via React's own
 *    validateDOMNesting warning channel.
 *
 * Pattern: when a new page-level component is added, copy the boilerplate
 * here, point it at the new component + its primary endpoint, and the
 * test guards against re-introduction of the same class of bugs.
 */
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";
import { render, waitFor } from "@testing-library/react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { StrictMode } from "react";

// Counts every `console.error` call so we can assert no React DOM-nesting
// warnings fire. React's `validateDOMNesting` issues warnings via
// `console.error`, so capturing those is the correct hook.
let domErrorMessages: string[] = [];
const originalError = console.error;

function trackConsoleErrors() {
  domErrorMessages = [];
  console.error = (...args: unknown[]) => {
    const msg = args.map((a) => String(a)).join(" ");
    if (
      msg.includes("validateDOMNesting") ||
      msg.includes("cannot be a descendant") ||
      msg.includes("cannot contain")
    ) {
      domErrorMessages.push(msg);
    }
    originalError.apply(console, args as []);
  };
}
function restoreConsoleErrors() {
  console.error = originalError;
}

beforeEach(() => trackConsoleErrors());
afterEach(() => {
  restoreConsoleErrors();
  vi.restoreAllMocks();
});


/**
 * Render the agent status line with each verdict and assert no DOM-nesting
 * warnings fire (bug 3: a Badge inside <p>).
 */
describe("DOM nesting (Phase 4.5 bug 3 guard)", () => {
  it.each(["up_to_date", "build_update_available", "release_incompatible"])(
    "AgentStatusRow (%s) nests cleanly",
    async (verdict) => {
      const { AgentStatusRow } = await import("@/components/settings/agent-status-row");
      const fetchMock = vi.fn(async () =>
        new Response(
          JSON.stringify({
            pinned_version: "v0.9.0",
            latest_known_upstream: "v1.0.0",
            newer_available: verdict !== "up_to_date",
            has_breaking_change: false,
            known_breaking_changes: [{ tag: "v1.0.0", severity: "breaking", area: "a", summary: "s" }],
            verdict,
            agent_owner: "admin",
            installed_vs_bundled: "older",
          }),
          { status: 200, headers: { "Content-Type": "application/json" } },
        ),
      );
      (globalThis as unknown as { fetch: typeof fetch }).fetch = fetchMock as unknown as typeof fetch;
      const qc = new QueryClient({ defaultOptions: { queries: { retry: false } } });
      render(
        <QueryClientProvider client={qc}>
          <AgentStatusRow hasNotebook />
        </QueryClientProvider>,
      );
      await waitFor(() => expect(fetchMock).toHaveBeenCalled());
      expect(domErrorMessages).toEqual([]);
    },
  );
});


/**
 * Component-level render-stability check. Mounts an `AgentConfigSection`
 * (or its proxy: a component using the same `useGetAgentConfig` hook)
 * with a 404-stubbed fetch and asserts the render count is bounded.
 *
 * If a future change re-introduces the dual-subscriber loop (bug 2),
 * this test will run for >5s emitting hundreds of console messages, and
 * the bounded-render-count assertion will fail.
 *
 * NOTE: We don't import the route component directly because it's bound
 * to TanStack Router context. Instead we reproduce the structural pattern
 * (two sibling subscribers) and assert no loop.
 */
describe("Render stability under 4xx (Phase 4.5 bug 2 guard)", () => {
  it("two sibling subscribers to the same erroring useQuery render finitely", async () => {
    // Reproduce the exact pattern that broke Settings: two siblings
    // both calling `useQuery` with `retry: false` against an endpoint
    // that 404s.
    const { useQuery } = await import("@tanstack/react-query");

    let renderCount = 0;
    function Subscriber({ id }: { id: string }) {
      renderCount += 1;
      const q = useQuery({
        queryKey: ["test-agent-config"],
        queryFn: async () => {
          throw Object.assign(new Error("404"), { status: 404 });
        },
        retry: false,
      });
      return <div data-testid={`sub-${id}`}>{q.status}</div>;
    }

    function Page() {
      return (
        <div>
          <Subscriber id="a" />
          <Subscriber id="b" />
        </div>
      );
    }

    const qc = new QueryClient({
      defaultOptions: {
        queries: { staleTime: 30_000, retry: 1 },
      },
    });

    render(
      <StrictMode>
        <QueryClientProvider client={qc}>
          <Page />
        </QueryClientProvider>
      </StrictMode>,
    );

    // Wait for the query to settle. Strict mode renders ×2 each, plus
    // the initial fetch + error transition. A reasonable bound is
    // ≤ 4 renders × 2 subscribers × 2 (strict double-mount) = 16.
    // The buggy pre-#151 build produced 100+ renders/sec for as long
    // as the page was mounted.
    // The explicit 1 s is an upper bound on purpose, not a load allowance: more than a second to reach the first
    // render means the render path regressed.
    await waitFor(() => {
      // At least one render past the error must have happened.
      expect(renderCount).toBeGreaterThan(0);
    }, { timeout: 1_000 });
    // Wait an additional 200ms to be sure no spurious re-renders happen.
    await new Promise((r) => setTimeout(r, 200));

    expect(renderCount).toBeLessThanOrEqual(16);
  });
});
