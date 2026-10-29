/**
 * The assessment pages' install/ready states (`FeatureGate feature="assessment"`): not installed,
 * every assessment page and the help topic say so; installed but not ready,
 * results stay readable, the New assessment page and button are replaced by
 * the not-set-up notice, and app admins also see `missing` with a Settings
 * link.
 */
import { afterEach, describe, expect, it, vi } from "vitest";
import { render, screen, waitFor } from "@testing-library/react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { Suspense, type ReactNode } from "react";
import {
  createMemoryHistory,
  createRootRoute,
  createRoute,
  createRouter,
  Outlet,
  RouterProvider,
} from "@tanstack/react-router";

const state = vi.hoisted(() => ({
  config: undefined as undefined | { installed: boolean; ready: boolean; missing: string[] },
  loading: false,
  error: null as unknown,
  refetch: vi.fn(),
  role: "app_admin" as string | undefined,
}));

vi.mock("@/lib/api", async () => {
  const actual = await vi.importActual<typeof import("@/lib/api")>("@/lib/api");
  return {
    ...actual,
    useGetAssessConfig: () => ({
      data: state.config ? { data: state.config } : undefined,
      isLoading: state.loading,
      error: state.error,
      refetch: state.refetch,
    }),
    useGetUserRole: () => ({ data: state.role ? { data: { role: state.role } } : undefined }),
    useGetBusinessSuspense: () => ({ data: { id: "biz-1", name: "Acme Co" } }),
    useListAssessmentsSuspense: () => ({
      data: [{
        id: "b1", version: 2, scope: "mvm", status: "failed", created_at: "2026-10-08T10:00:00Z", created_by: "me",
        domain_runs: [{ id: "r1", domain_name: "sales_order", status: "failed" }],
      }],
    }),
  };
});
vi.mock("@/components/explorer/breadcrumb-context", () => ({ useBreadcrumbs: () => {} }));
vi.mock("@/components/assessment/assessment-wizard", () => ({
  AssessmentWizard: () => <div data-testid="wizard" />,
}));
vi.mock("@/components/assessment/batch-status", () => ({
  BatchStatus: () => <div data-testid="batch-status" />,
}));

import { Route as LayoutRoute } from "@/routes/_sidebar/businesses.$businessId.assessments";
import { Route as IndexRoute } from "@/routes/_sidebar/businesses.$businessId.assessments.index";
import { Route as NewRoute } from "@/routes/_sidebar/businesses.$businessId.assessments.new";
import { Route as BatchRoute } from "@/routes/_sidebar/businesses.$businessId.assessments.$batchId";
import { Route as HelpTopicRoute } from "@/routes/_sidebar/help.$topic";
import { ASSESS_NOT_READY_TEXT as NOT_READY_TEXT, FEATURE_INFO } from "@/lib/features";

const NOT_INSTALLED_TEXT = FEATURE_INFO.assessment.notInstalledText;
import { ApiError } from "@/lib/api";

afterEach(() => {
  state.config = undefined;
  state.loading = false;
  state.error = null;
  state.role = "app_admin";
});

function renderAt(path: string) {
  const rootRoute = createRootRoute({ component: () => <Outlet /> });
  const layout = createRoute({
    getParentRoute: () => rootRoute,
    path: "/businesses/$businessId/assessments",
    component: LayoutRoute.options.component as () => ReactNode,
  });
  const index = createRoute({ getParentRoute: () => layout, path: "/", component: IndexRoute.options.component as any });
  const create = createRoute({
    getParentRoute: () => layout,
    path: "new",
    validateSearch: NewRoute.options.validateSearch as any,
    component: NewRoute.options.component as any,
  });
  const batch = createRoute({ getParentRoute: () => layout, path: "$batchId", component: BatchRoute.options.component as any });
  const help = createRoute({ getParentRoute: () => rootRoute, path: "/help/$topic", component: HelpTopicRoute.options.component as any });
  const settings = createRoute({ getParentRoute: () => rootRoute, path: "/settings", component: () => <div /> });
  const business = createRoute({ getParentRoute: () => rootRoute, path: "/businesses/$businessId", component: () => <div /> });
  const router = createRouter({
    routeTree: rootRoute.addChildren([layout.addChildren([index, create, batch]), help, settings, business]),
    history: createMemoryHistory({ initialEntries: [path] }),
    defaultPendingMs: 0,
  });
  render(
    <QueryClientProvider client={new QueryClient({ defaultOptions: { queries: { retry: false } } })}>
      <Suspense fallback={null}>
        <RouterProvider router={router} />
      </Suspense>
    </QueryClientProvider>,
  );
}

const notReady = { installed: true, ready: false, missing: ["No reader service principal"] };

describe("assessment pages when the skill is not installed", () => {
  for (const path of ["/businesses/biz-1/assessments", "/businesses/biz-1/assessments/new", "/businesses/biz-1/assessments/b1"]) {
    it(`${path} shows the not-installed page`, async () => {
      state.config = { installed: false, ready: false, missing: [] };
      renderAt(path);
      expect(await screen.findByText(NOT_INSTALLED_TEXT)).toBeInTheDocument();
      expect(screen.queryByTestId("wizard")).toBeNull();
      expect(screen.queryByTestId("batch-status")).toBeNull();
      expect(screen.queryByText("Assessments")).toBeNull();
    });
  }

  it("the help topic says so too", async () => {
    state.config = { installed: false, ready: false, missing: [] };
    renderAt("/help/assessment");
    expect(await screen.findByText(NOT_INSTALLED_TEXT)).toBeInTheDocument();
    expect(screen.queryByText("What an assessment does")).toBeNull();
  });

  it("a config fetch error reads as an error with a retry, not as not installed", async () => {
    state.error = new ApiError(500, "Internal Server Error", { detail: "Lakebase unavailable" });
    renderAt("/businesses/biz-1/assessments");
    const err = await screen.findByTestId("feature-config-error");
    expect(err).toHaveTextContent("Lakebase unavailable");
    expect(err).toHaveTextContent(/Next try in 00:\d\d/);
    expect(screen.queryByText(NOT_INSTALLED_TEXT)).toBeNull();
    screen.getByRole("button", { name: /try again/i }).click();
    await waitFor(() => expect(state.refetch).toHaveBeenCalled());
  });

  it("waits for the config instead of flashing the not-installed page", async () => {
    state.loading = true;
    renderAt("/businesses/biz-1/assessments");
    await new Promise((r) => setTimeout(r, 20));
    expect(screen.queryByText(NOT_INSTALLED_TEXT)).toBeNull();
  });
});

describe("assessment pages when installed but not ready", () => {
  it("the list stays readable, without New assessment or Relaunch, under the notice", async () => {
    state.config = notReady;
    renderAt("/businesses/biz-1/assessments");
    expect(await screen.findByRole("heading", { name: "Assessments" })).toBeInTheDocument();
    expect(screen.getByRole("link", { name: /2026/ })).toBeInTheDocument();
    expect(screen.queryByRole("link", { name: /new assessment/i })).toBeNull();
    expect(screen.queryByRole("button", { name: /relaunch/i })).toBeNull();
    expect(screen.getByText(NOT_READY_TEXT)).toBeInTheDocument();
  });

  it("the batch page stays readable", async () => {
    state.config = notReady;
    renderAt("/businesses/biz-1/assessments/b1");
    expect(await screen.findByTestId("batch-status")).toBeInTheDocument();
  });

  it("the New assessment page shows the notice with missing and a Settings link for app admins", async () => {
    state.config = notReady;
    renderAt("/businesses/biz-1/assessments/new");
    expect(await screen.findByText(NOT_READY_TEXT)).toBeInTheDocument();
    expect(screen.queryByTestId("wizard")).toBeNull();
    expect(screen.getByText("No reader service principal")).toBeInTheDocument();
    expect(screen.getByRole("link", { name: /open settings/i })).toHaveAttribute(
      "href",
      "/settings?tab=platform#feature-assessment",
    );
  });

  it("non-admins see only the notice", async () => {
    state.config = notReady;
    state.role = "modeler";
    renderAt("/businesses/biz-1/assessments/new");
    expect(await screen.findByText(NOT_READY_TEXT)).toBeInTheDocument();
    expect(screen.queryByText("No reader service principal")).toBeNull();
    expect(screen.queryByRole("link", { name: /open settings/i })).toBeNull();
  });

  it("the help topic shows the not-ready notice", async () => {
    state.config = notReady;
    renderAt("/help/assessment");
    expect(await screen.findByText(NOT_READY_TEXT)).toBeInTheDocument();
    expect(screen.queryByText("What an assessment does")).toBeNull();
  });
});

describe("assessment pages when ready", () => {
  it("the list offers New assessment and Relaunch and no notice", async () => {
    state.config = { installed: true, ready: true, missing: [] };
    renderAt("/businesses/biz-1/assessments");
    expect(await screen.findByRole("link", { name: /new assessment/i })).toBeInTheDocument();
    expect(screen.getByRole("button", { name: /relaunch/i })).toBeInTheDocument();
    expect(screen.queryByText(NOT_READY_TEXT)).toBeNull();
  });

  it("the help topic renders", async () => {
    state.config = { installed: true, ready: true, missing: [] };
    renderAt("/help/assessment");
    expect(await screen.findByText("What an assessment does")).toBeInTheDocument();
  });

  it("the New assessment page renders the wizard", async () => {
    state.config = { installed: true, ready: true, missing: [] };
    renderAt("/businesses/biz-1/assessments/new");
    expect(await screen.findByTestId("wizard")).toBeInTheDocument();
  });
});
