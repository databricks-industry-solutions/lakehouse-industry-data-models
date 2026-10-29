/**
 * Contract: the wrapped markdown editor (MarkdownToolbar + Textarea inside
 * a focus-within ring container) used for Run Instructions, Business
 * Context, and Vibe Instructions on the New Run form propagates values
 * set via the React-aware "native input dispatch" idiom — the same path
 * Puppeteer / chrome-devtools `fill()` uses when typing into a controlled
 * React input.
 *
 * Locks the contract for Todoist tickets 6ggFf3jqVq8rrWXH (Run
 * Instructions) and 6ggFvJxgrxMjVXMH (Schema/Catalog Prefix Inputs).
 *
 * Earlier revisions of this file mocked `@/components/ui/markdown-toolbar`
 * to `() => null`, which meant the test never exercised the LIVE wrapped
 * editor — only the bare `<Textarea>` underneath. The Run Instructions
 * regression re-opened against v0.4.2 was reported against the live
 * wrapped form, so the regression test now mounts the editor with the
 * real `MarkdownToolbar` and `MarkdownEditor` wrapper.
 */
import { describe, it, expect, beforeEach, afterEach, vi } from "vitest";
import { warmImports } from "./helpers/warm-imports";
import { render, screen, waitFor, act, fireEvent, cleanup } from "@testing-library/react";
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

const BUSINESS_DESCRIPTION = "Test business description for native-input contract.";

let businessHook: () => unknown = () => ({
  data: { id: "biz-1", name: "Retail Co", description: BUSINESS_DESCRIPTION },
});
let versionsHook: () => unknown = () => ({ data: [] });
const createRunMock = vi.fn(async () => ({}));
const validateRunMock = vi.fn(async () => ({ data: { blockers: [], warnings: [] } }));

vi.mock("@/lib/api", async () => {
  const actual = await vi.importActual<typeof import("@/lib/api")>("@/lib/api");
  return {
    ...actual,
    // No base-model pre-fill: the form keeps its own values.
    useGetRunDefaults: () => ({ data: undefined, isLoading: false, isError: false }),
    useGetBusinessSuspense: () => businessHook(),
    useListVersionsSuspense: () => versionsHook(),
    createRun: createRunMock,
    validateRun: validateRunMock,
  };
});

// NOTE: MarkdownToolbar is intentionally NOT mocked. The live wrapped
// editor — toolbar + textarea inside the focus-within ring — is the
// surface under test. Mocking the toolbar reduces this to a stock
// shadcn Textarea contract and misses the regression bug class the
// ticket was filed against.
vi.mock("@/components/runs/deployment-catalog-picker", () => ({
  DeploymentCatalogPicker: ({
    value,
    onChange,
  }: {
    value: string;
    onChange: (v: string) => void;
  }) => (
    <input
      data-testid="catalog-picker"
      value={value}
      onChange={(e) => onChange(e.target.value)}
    />
  ),
}));

beforeEach(() => {
  businessHook = () => ({
    data: { id: "biz-1", name: "Retail Co", description: BUSINESS_DESCRIPTION },
  });
  versionsHook = () => ({ data: [] });
  createRunMock.mockClear();
  validateRunMock.mockClear();
});

afterEach(() => {
  cleanup();
  vi.restoreAllMocks();
});

/**
 * Emulates how Puppeteer / chrome-devtools / Playwright set a value on a
 * controlled React input. The native setter on the prototype is the one
 * React's input event delegation listens for; assigning `el.value = ...`
 * directly without the prototype setter is the path that silently fails
 * on controlled inputs.
 *
 * Reference: https://github.com/facebook/react/issues/10135
 */
function setNativeValueAndDispatch(
  el: HTMLInputElement | HTMLTextAreaElement,
  value: string,
) {
  const proto =
    el instanceof HTMLTextAreaElement
      ? HTMLTextAreaElement.prototype
      : HTMLInputElement.prototype;
  const setter = Object.getOwnPropertyDescriptor(proto, "value")?.set;
  setter?.call(el, value);
  el.dispatchEvent(new Event("input", { bubbles: true }));
}

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
  const explorerRoute = createRoute({
    getParentRoute: () => rootRoute,
    path: "/businesses/$businessId/explorer",
    component: () => <div data-testid="explorer-stub" />,
  });
  const router = createRouter({
    routeTree: rootRoute.addChildren([
      sidebarRoute.addChildren([runsNewClone]),
      explorerRoute,
    ]),
    history: createMemoryHistory({
      initialEntries: [`/businesses/biz-1/runs/new${searchString}`],
    }),
    defaultPendingMs: 0,
  });
  const qc = new QueryClient({
    defaultOptions: {
      queries: { retry: false, staleTime: 30_000, refetchOnWindowFocus: false },
      mutations: { retry: false },
    },
  });
  return render(
    <QueryClientProvider client={qc}>
      <Suspense fallback={<div data-testid="suspense-fallback" />}>
        <RouterProvider router={router} />
      </Suspense>
    </QueryClientProvider>,
  );
}

warmImports(() => import("@/routes/_sidebar/businesses.$businessId.runs.new"));

describe("New Run form: wrapped markdown editor accepts native `input` events (chrome-devtools fill contract)", () => {
  it("Run Instructions wrapped editor propagates a native `input` event into the createRun payload", async () => {
    await renderRunsNew("?businessId=biz-1&operationType=new-base-model");

    await waitFor(() => {
      expect(
        screen.queryByPlaceholderText(/Per-run constraints|per-run instructions/i),
      ).not.toBeNull();
    });

    const runInstructions = screen.getByPlaceholderText(
      /Per-run constraints|per-run instructions/i,
    ) as HTMLTextAreaElement;

    // Sanity check: this textarea is wrapped by a MarkdownEditor
    // container that ALSO renders the toolbar buttons. If a future
    // refactor strips the toolbar or breaks the wrapper-ref wiring,
    // this guard fails before the propagation assertion, surfacing
    // the structural drift up-front rather than as a silent contract
    // erosion.
    const editorWrapper = runInstructions.closest(
      "div.rounded-md.border.border-input",
    );
    expect(editorWrapper).not.toBeNull();
    expect(editorWrapper!.querySelector("button[title='Bold']")).not.toBeNull();

    const probe = `PROBE_run_instructions_${Date.now()}`;
    act(() => {
      setNativeValueAndDispatch(runInstructions, probe);
    });

    // value= must reflect the probe — same gate `feedback_verify_form_fills`
    // calls for after every chrome-devtools fill on a multi-line textarea.
    expect(runInstructions.value).toBe(probe);

    // And the payload submitted to createRun must carry the same string.
    const startBtn = screen.getByRole("button", { name: /^Start Run$/i });
    await act(async () => {
      fireEvent.click(startBtn);
    });
    await waitFor(() => {
      expect(screen.queryByRole("button", { name: /^Launch$/i })).not.toBeNull();
    });
    const launchBtn = screen.getByRole("button", { name: /^Launch$/i });
    await act(async () => {
      fireEvent.click(launchBtn);
    });
    await waitFor(() => {
      expect(createRunMock).toHaveBeenCalledWith(
        expect.objectContaining({ business_id: "biz-1" }),
        expect.objectContaining({ vibe_instructions: probe }),
      );
    });
  });

  it("Business Context wrapped editor propagates a native `input` event into the createRun payload", async () => {
    await renderRunsNew("?businessId=biz-1&operationType=new-base-model");

    await waitFor(() => {
      expect(
        screen.queryByPlaceholderText(/Describe your business here/i),
      ).not.toBeNull();
    });

    const businessContext = screen.getByPlaceholderText(
      /Describe your business here/i,
    ) as HTMLTextAreaElement;

    // Same structural guard as Run Instructions — both fields use the
    // unified MarkdownEditor wrapper, so the closest match must include
    // the toolbar buttons.
    const editorWrapper = businessContext.closest(
      "div.rounded-md.border.border-input",
    );
    expect(editorWrapper).not.toBeNull();
    expect(editorWrapper!.querySelector("button[title='Bold']")).not.toBeNull();

    const probe = `PROBE_business_context_${Date.now()}`;
    act(() => {
      setNativeValueAndDispatch(businessContext, probe);
    });
    expect(businessContext.value).toBe(probe);

    const startBtn = screen.getByRole("button", { name: /^Start Run$/i });
    await act(async () => {
      fireEvent.click(startBtn);
    });
    await waitFor(() => {
      expect(screen.queryByRole("button", { name: /^Launch$/i })).not.toBeNull();
    });
    await act(async () => {
      fireEvent.click(screen.getByRole("button", { name: /^Launch$/i }));
    });
    await waitFor(() => {
      expect(createRunMock).toHaveBeenCalledWith(
        expect.objectContaining({ business_id: "biz-1" }),
        expect.objectContaining({ business_context_text: probe }),
      );
    });
  });

  it("ECM Schema Prefix Input propagates a native `input` event into createRun payload", async () => {
    await renderRunsNew("?businessId=biz-1&operationType=new-base-model");

    // Open Advanced Options accordion to surface the prefix inputs.
    await waitFor(() => {
      expect(
        screen.queryByRole("button", { name: /Advanced Options/i }),
      ).not.toBeNull();
    });
    await act(async () => {
      fireEvent.click(screen.getByRole("button", { name: /Advanced Options/i }));
    });
    await waitFor(() => {
      expect(screen.queryByText(/ECM Schema Prefix/i)).not.toBeNull();
    });

    // Find the Input under the "ECM Schema Prefix" label — it's the next
    // input sibling. Tests use placeholder ("ecm_") to disambiguate.
    const ecmInput = screen.getByPlaceholderText("ecm_") as HTMLInputElement;
    const probe = `wt_ecm_${Date.now()}_`;
    act(() => {
      setNativeValueAndDispatch(ecmInput, probe);
    });
    expect(ecmInput.value).toBe(probe);

    // Submit and assert the override hit the payload.
    const startBtn = screen.getByRole("button", { name: /^Start Run$/i });
    await act(async () => {
      fireEvent.click(startBtn);
    });
    await waitFor(() => {
      expect(screen.queryByRole("button", { name: /^Launch$/i })).not.toBeNull();
    });
    await act(async () => {
      fireEvent.click(screen.getByRole("button", { name: /^Launch$/i }));
    });
    await waitFor(() => {
      expect(createRunMock).toHaveBeenCalledWith(
        expect.objectContaining({ business_id: "biz-1" }),
        expect.objectContaining({ ecm_schema_prefix: probe }),
      );
    });
  });

  it("Catalog Prefix Input accepts a native `input` event via the same shadcn <Input> path", async () => {
    // Render the form and open Advanced Options. Catalog Prefix is disabled
    // in One Catalog mode (form default), but jsdom honours the prototype
    // setter regardless of the `disabled` attribute, and the contract under
    // test is the React event-system wiring — identical to the ECM Schema
    // Prefix Input the previous test exercises end-to-end. This smoke
    // confirms the same shadcn <Input> primitive is mounted for the
    // Catalog Prefix slot and that native-input dispatch updates its
    // controlled value when enabled.
    await renderRunsNew("?businessId=biz-1&operationType=new-base-model");

    await waitFor(() => {
      expect(
        screen.queryByRole("button", { name: /Advanced Options/i }),
      ).not.toBeNull();
    });
    await act(async () => {
      fireEvent.click(
        screen.getByRole("button", { name: /Advanced Options/i }),
      );
    });
    await waitFor(() => {
      expect(screen.queryByText(/^Catalog Prefix$/)).not.toBeNull();
    });

    const catalogPrefixLabel = screen.getByText(/^Catalog Prefix$/);
    const catalogPrefixInput =
      catalogPrefixLabel.parentElement?.querySelector("input") as HTMLInputElement;
    expect(catalogPrefixInput).toBeTruthy();
    // Bypass the `disabled` UI gate (jsdom enforces it at the property
    // level but not the prototype setter) so we can validate the React
    // event-system wiring is the standard shadcn one.
    catalogPrefixInput.disabled = false;
    act(() => {
      setNativeValueAndDispatch(catalogPrefixInput, "wt_cat_");
    });
    expect(catalogPrefixInput.value).toBe("wt_cat_");
  });
});
