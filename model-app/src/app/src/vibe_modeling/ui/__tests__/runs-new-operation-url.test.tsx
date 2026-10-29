/**
 * The New Run form keeps `operationType` in the URL equal to the operation it
 * shows, so the top bar Help link (which reads the URL) opens that operation's
 * help page: on mount when the form started on another operation than the URL
 * named, and on every change of the Operation Type select. The writes replace
 * the history entry, so Back leaves the form.
 */
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";
import { warmImports } from "./helpers/warm-imports";
import { act, fireEvent, render, screen, waitFor } from "@testing-library/react";
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

const ECM_VERSION = {
  id: "v-1-ecm",
  version: 1,
  scope: "ecm",
  status: "completed",
  is_base: true,
  confidence_score: null,
  vibe_instructions: "",
  created_at: "2026-04-20T12:00:00Z",
  uc_catalog: "vibe_modeling",
  deployment_status: "draft",
};
const MVM_VERSION = { ...ECM_VERSION, id: "v-1-mvm", scope: "mvm", deployment_status: "deployed" };

let versionsHook: () => unknown = () => ({ data: [MVM_VERSION, ECM_VERSION] });

vi.mock("@/lib/api", async () => {
  const actual = await vi.importActual<typeof import("@/lib/api")>("@/lib/api");
  return {
    ...actual,
    useGetBusinessSuspense: () => ({ data: { id: "biz-1", name: "Acme Corp", description: "A retailer." } }),
    useListVersionsSuspense: () => versionsHook(),
    useListRunsForVersion: () => ({ data: [] }),
    useGetRunDefaults: () => ({ data: undefined, isLoading: false, isError: false }),
    useListVibeInputs: (opts: any) => {
      const data = [
        { id: "vi-1", text: "keep ids stable", priority: "medium", anchor: { level: "model_wide", path: [] }, consumed: false, selected_for_run: true },
      ];
      return { data: opts?.query?.select ? opts.query.select({ data }) : data };
    },
    createRun: vi.fn(async () => ({ data: { id: "run-new" } })),
    validateRun: vi.fn(async () => ({ data: { blockers: [], warnings: [] } })),
  };
});

vi.mock("@/lib/features", async () => {
  const actual = await vi.importActual<typeof import("@/lib/features")>("@/lib/features");
  return { ...actual, useFeaturesReady: () => ({ assessment: true, taxonomy: true }) };
});

vi.mock("@/components/ui/markdown-toolbar", () => ({ MarkdownToolbar: () => null }));
vi.mock("@/components/runs/deployment-catalog-picker", () => ({
  DeploymentCatalogPicker: ({ value, onChange }: { value: string; onChange: (v: string) => void }) => (
    <input data-testid="catalog-picker" value={value} onChange={(e) => onChange(e.target.value)} />
  ),
}));

import { HeaderHelpLink } from "@/components/help/header-help-link";

beforeEach(() => {
  versionsHook = () => ({ data: [MVM_VERSION, ECM_VERSION] });
});

afterEach(() => {
  vi.restoreAllMocks();
});

/** Mounts the form under the header Help link, with the explorer as the page before it. */
async function renderRunsNew(searchString: string) {
  const { Route: RunsNewRoute } = await import("@/routes/_sidebar/businesses.$businessId.runs.new");
  const rootRoute = createRootRoute({
    component: () => (
      <>
        <HeaderHelpLink />
        <Outlet />
      </>
    ),
  });
  const sidebar = createRoute({ getParentRoute: () => rootRoute, id: "/_sidebar", component: () => <Outlet /> });
  const runsNew = createRoute({
    getParentRoute: () => sidebar,
    path: "/businesses/$businessId/runs/new",
    component: RunsNewRoute.options.component as any,
    validateSearch: RunsNewRoute.options.validateSearch as any,
  });
  const explorer = createRoute({
    getParentRoute: () => rootRoute,
    path: "/businesses/$businessId/explorer",
    component: () => <div data-testid="explorer-stub" />,
  });
  const router = createRouter({
    routeTree: rootRoute.addChildren([sidebar.addChildren([runsNew]), explorer]),
    history: createMemoryHistory({
      initialEntries: ["/businesses/biz-1/explorer", `/businesses/biz-1/runs/new${searchString}`],
      initialIndex: 1,
    }),
    defaultPendingMs: 0,
  });
  const qc = new QueryClient({
    defaultOptions: {
      queries: { retry: false, staleTime: 30_000, refetchOnWindowFocus: false },
      mutations: { retry: false },
    },
  });
  render(
    <QueryClientProvider client={qc}>
      <Suspense fallback={<div data-testid="suspense-fallback" />}>
        <RouterProvider router={router} />
      </Suspense>
    </QueryClientProvider>,
  );
  return router;
}

function operationSelect(): HTMLSelectElement {
  const select = Array.from(document.querySelectorAll("select")).find((s) =>
    Array.from(s.options).some((o) => /new base model/i.test(o.textContent || "")),
  );
  if (!select) throw new Error("Operation Type select not found");
  return select;
}

const helpLink = () => screen.getByTestId("header-help-link");

warmImports(() => import("@/routes/_sidebar/businesses.$businessId.runs.new"));

describe("New Run form - operationType in the URL", () => {
  it("writes the operation the form starts on when the URL names none", async () => {
    const router = await renderRunsNew("");
    await waitFor(() => expect(router.state.location.search).toMatchObject({ operationType: "vibe-iterate" }));
    expect(helpLink().getAttribute("href")).toBe("/help/run-vibe");
  });

  it("shows the Vibe Modeling help when new base model is asked for on a business with versions", async () => {
    const router = await renderRunsNew("?operationType=new-base-model");
    await waitFor(() => expect(router.state.location.search).toMatchObject({ operationType: "vibe-iterate" }));
    expect(helpLink().getAttribute("href")).toBe("/help/run-vibe");
    expect(helpLink().getAttribute("aria-label")).toBe("Help: Vibe Modeling");
  });

  it("starts on new base model, and keeps that URL, for a business with no versions", async () => {
    versionsHook = () => ({ data: [] });
    const router = await renderRunsNew("?operationType=new-base-model");
    await waitFor(() => expect(helpLink().getAttribute("href")).toBe("/help/run-new-base-model"));
    expect(router.state.location.search).toMatchObject({ operationType: "new-base-model" });
  });

  it("leaves a URL that already names the form's operation alone, in either spelling", async () => {
    const router = await renderRunsNew("?operationType=vibe-iterate&sourceVersion=1&sourceScope=ecm");
    await waitFor(() => expect(screen.queryByText("Compiled instructions preview")).not.toBeNull());
    expect(router.state.location.search).toMatchObject({ operationType: "vibe-iterate", sourceVersion: 1, sourceScope: "ecm" });
    expect(helpLink().getAttribute("href")).toBe("/help/run-vibe");
  });

  it("leaves a URL that names the operation by its form value alone too", async () => {
    const router = await renderRunsNew("?operationType=vibe modeling of version");
    await waitFor(() => expect(screen.queryByText("Compiled instructions preview")).not.toBeNull());
    expect(router.state.location.search).toMatchObject({ operationType: "vibe modeling of version" });
    expect(helpLink().getAttribute("href")).toBe("/help/run-vibe");
  });

  it("leaves a removed operation's deep link, which names its notice, alone until an operation is picked", async () => {
    const router = await renderRunsNew("?operationType=install");
    await waitFor(() => expect(screen.queryByTestId("removed-operation-notice")).not.toBeNull());
    expect(router.state.location.search).toMatchObject({ operationType: "install" });
    expect(helpLink().getAttribute("href")).toBe("/help/runs");
  });

  it("follows the select after a removed operation's deep link, and the notice goes", async () => {
    const router = await renderRunsNew("?operationType=install");
    await waitFor(() => expect(screen.queryByTestId("removed-operation-notice")).not.toBeNull());
    await act(async () => {
      fireEvent.change(operationSelect(), { target: { value: "vibe new ecm + mvm" } });
    });
    await waitFor(() => expect(router.state.location.search).toMatchObject({ operationType: "vibe-new-ecm-mvm" }));
    expect(helpLink().getAttribute("href")).toBe("/help/run-vibe-ecm-mvm");
    expect(screen.queryByTestId("removed-operation-notice")).toBeNull();
  });

  it("updates operationType, and the Help link, when the select changes", async () => {
    const router = await renderRunsNew("?operationType=vibe-iterate");
    await waitFor(() => expect(screen.queryByText("Compiled instructions preview")).not.toBeNull());
    await act(async () => {
      fireEvent.change(operationSelect(), { target: { value: "vibe new ecm + mvm" } });
    });
    await waitFor(() => expect(router.state.location.search).toMatchObject({ operationType: "vibe-new-ecm-mvm" }));
    expect(helpLink().getAttribute("href")).toBe("/help/run-vibe-ecm-mvm");
    expect(helpLink().getAttribute("aria-label")).toBe("Help: Vibe ECM + MVM");
  });

  it("goes Back to the page before the form after a select change", async () => {
    const router = await renderRunsNew("?operationType=vibe-iterate");
    await waitFor(() => expect(screen.queryByText("Compiled instructions preview")).not.toBeNull());
    await act(async () => {
      fireEvent.change(operationSelect(), { target: { value: "vibe new ecm + mvm" } });
    });
    await waitFor(() => expect(router.state.location.search).toMatchObject({ operationType: "vibe-new-ecm-mvm" }));
    await act(async () => {
      router.history.back();
    });
    await waitFor(() => expect(router.state.location.pathname).toBe("/businesses/biz-1/explorer"));
  });
});
