/**
 * The bronze assessment's settings are a card in Settings → Platform,
 * Optional features (no tab of its own; the old `?tab=assessment` link lands
 * there). The help-index Assessment card shows only once ready.
 */
import { afterEach, describe, expect, it, vi } from "vitest";
import { render, screen } from "@testing-library/react";
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

const { assess } = vi.hoisted(() => ({ assess: { installed: false, ready: false } }));

vi.mock("@/lib/assessment", async (importOriginal) => ({
  ...(await importOriginal<typeof import("@/lib/assessment")>()),
  useAssessReady: () => assess,
}));
vi.mock("@/components/explorer/breadcrumb-context", () => ({ useBreadcrumbs: () => {} }));

import { Route as SettingsRoute } from "@/routes/_sidebar/settings";
import { HelpIndexPage } from "@/routes/_sidebar/help.index";
import { firstRunFetcher } from "./helpers/first-run";

afterEach(() => {
  assess.installed = false;
  assess.ready = false;
  vi.unstubAllGlobals();
});

function renderAt(path: string, routePath: string, component: () => ReactNode) {
  const rootRoute = createRootRoute({ component: () => <Outlet /> });
  const sidebar = createRoute({ getParentRoute: () => rootRoute, id: "/_sidebar", component: () => <Outlet /> });
  const subject = createRoute({
    getParentRoute: () => sidebar,
    path: routePath,
    validateSearch: SettingsRoute.options.validateSearch as any,
    component: component as any,
  });
  const helpTopic = createRoute({ getParentRoute: () => rootRoute, path: "/help/$topic", component: () => <div /> });
  const router = createRouter({
    routeTree: rootRoute.addChildren([sidebar.addChildren([subject]), helpTopic]),
    history: createMemoryHistory({ initialEntries: [path] }),
    defaultPendingMs: 0,
  });
  const qc = new QueryClient({ defaultOptions: { queries: { retry: false } } });
  render(
    <QueryClientProvider client={qc}>
      <Suspense fallback={null}>
        <RouterProvider router={router} />
      </Suspense>
    </QueryClientProvider>,
  );
}

const renderSettings = (tab = "agent") =>
  renderAt(`/settings?tab=${tab}`, "/settings", SettingsRoute.options.component as () => ReactNode);

describe("Settings: the assessment lives under Platform → Optional features", () => {
  const notInstalled = {
    "/api/config/taxonomy": { status: 200, body: { installed: false, ready: false, model_service: "", max_concurrency: 4, install_default_model_service: "" } },
  };

  it("has no Assessment tab, installed or not", async () => {
    assess.installed = true;
    vi.stubGlobal("fetch", firstRunFetcher(notInstalled));
    renderSettings();
    expect(await screen.findByRole("tab", { name: "Agent" })).toBeInTheDocument();
    expect(screen.queryByRole("tab", { name: "Assessment" })).toBeNull();
  });

  it("an assessment deep link lands on the Platform tab, which shows the feature card", async () => {
    vi.stubGlobal("fetch", firstRunFetcher(notInstalled));
    renderSettings("assessment");
    expect(await screen.findByRole("tab", { name: "Platform" })).toHaveAttribute("aria-selected", "true");
    expect(await screen.findByTestId("feature-card-assessment")).toHaveTextContent("Not installed");
  });
});

describe("Help index Assessment card", () => {
  const renderHelp = () => renderAt("/help", "/help", HelpIndexPage);

  it("is absent when the skill is not installed", async () => {
    renderHelp();
    expect(await screen.findByText("How the modeling flow works")).toBeInTheDocument();
    expect(screen.queryByText("Assessing a model against your data")).toBeNull();
  });

  it("is absent when installed but not ready", async () => {
    assess.installed = true;
    renderHelp();
    expect(await screen.findByText("How the modeling flow works")).toBeInTheDocument();
    expect(screen.queryByText("Assessing a model against your data")).toBeNull();
  });

  it("shows once ready", async () => {
    assess.installed = true;
    assess.ready = true;
    renderHelp();
    expect(await screen.findByText("Assessing a model against your data")).toBeInTheDocument();
  });
});
