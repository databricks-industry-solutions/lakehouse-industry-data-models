/**
 * The ONE shared `config_missing` renderer (Track 4 finding #2).
 *
 * Covers the two halves every config-gated surface converges on:
 *   1. `parseConfigMissing` (lib/api-error) - unwraps the 422 envelope.
 *   2. `ConfigMissingNotice` (components/config-missing-notice) - renders the
 *      backend sentence + one working Settings deep-link per missing item.
 *   3. `notifyConfigMissing` (lib/notify) - raises the shared toast and reports
 *      whether it handled the error, so callers can fall back cleanly.
 */
import { afterEach, describe, expect, it, vi } from "vitest";
import { render, screen, waitFor } from "@testing-library/react";
import {
  createMemoryHistory,
  createRootRoute,
  createRoute,
  createRouter,
  Outlet,
  RouterProvider,
} from "@tanstack/react-router";
import type { ReactNode } from "react";

vi.mock("sonner", () => ({
  toast: { error: vi.fn(), success: vi.fn(), warning: vi.fn(), info: vi.fn() },
}));

import { toast } from "sonner";
import { ApiError } from "@/lib/api";
import { parseConfigMissing } from "@/lib/api-error";
import { ConfigMissingNotice, toLinkTarget } from "@/components/config-missing-notice";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { getAssessConfigKey, getTaxonomyConfigKey } from "@/lib/api";
import { notifyConfigMissing, notifyError } from "@/lib/notify";

const MISSING = [
  { key: "metamodel_catalog", label: "Metamodel catalog", settings_url: "/settings?tab=platform" },
  { key: "warehouse", label: "SQL warehouse", settings_url: "/settings?tab=platform" },
];

function configMissingError() {
  return new ApiError(422, "Unprocessable Entity", {
    detail: {
      error: "config_missing",
      missing: MISSING,
      message: "Finish setup before running: 2 settings are missing.",
    },
  });
}

/** Router with a real `/settings` route so `<Link>` builds a resolvable href. */
function wrap(ui: ReactNode) {
  const rootRoute = createRootRoute({ component: () => <Outlet /> });
  const indexRoute = createRoute({
    getParentRoute: () => rootRoute,
    path: "/",
    component: () => <>{ui}</>,
  });
  const settingsRoute = createRoute({
    getParentRoute: () => rootRoute,
    path: "/settings",
    component: () => <div data-testid="settings-stub" />,
  });
  const router = createRouter({
    routeTree: rootRoute.addChildren([indexRoute, settingsRoute]),
    history: createMemoryHistory({ initialEntries: ["/"] }),
  });
  return render(<RouterProvider router={router as any} />);
}

afterEach(() => vi.clearAllMocks());

describe("parseConfigMissing", () => {
  it("unwraps a 422 config_missing envelope", () => {
    const cm = parseConfigMissing(configMissingError());
    expect(cm).not.toBeNull();
    expect(cm?.message).toMatch(/Finish setup/);
    expect(cm?.missing.map((m) => m.key)).toEqual(["metamodel_catalog", "warehouse"]);
  });

  it("returns null for unrelated errors", () => {
    expect(parseConfigMissing(new Error("boom"))).toBeNull();
    expect(
      parseConfigMissing(new ApiError(409, "Conflict", { detail: { error: "other" } })),
    ).toBeNull();
  });
});

describe("ConfigMissingNotice", () => {
  it("lists every missing label and a working Settings deep-link", async () => {
    wrap(<ConfigMissingNotice missing={MISSING} message="Finish setup." />);
    await waitFor(() =>
      expect(screen.getByText("Finish setup.")).toBeInTheDocument(),
    );
    expect(screen.getByText("Metamodel catalog")).toBeInTheDocument();
    expect(screen.getByText("SQL warehouse")).toBeInTheDocument();
    const links = screen.getAllByRole("link", { name: /configure/i });
    expect(links).toHaveLength(2);
    // Deep-link resolves to the settings tab from settings_url.
    for (const link of links) {
      expect(link.getAttribute("href")).toBe("/settings?tab=platform");
    }
  });
});

describe("toLinkTarget", () => {
  it("splits path, search and hash", () => {
    expect(toLinkTarget("/settings?tab=platform#feature-taxonomy")).toEqual({
      to: "/settings", search: { tab: "platform" }, hash: "feature-taxonomy",
    });
    expect(toLinkTarget("/settings?tab=platform")).toEqual({ to: "/settings", search: { tab: "platform" } });
    expect(toLinkTarget("/settings#feature-assessment")).toEqual({ to: "/settings", search: {}, hash: "feature-assessment" });
  });
});

describe("ConfigMissingNotice for a feature setting", () => {
  const refusedItem = [{ key: "taxonomy_llm", label: "Domain Taxonomy Builder model service", settings_url: "/settings?tab=platform#feature-taxonomy" }];

  it("links to the feature's card, with the link text kept on one line", async () => {
    wrap(<ConfigMissingNotice missing={refusedItem} message="Refused." />);
    const link = await screen.findByRole("link", { name: "Configure" });
    expect(link.getAttribute("href")).toBe("/settings?tab=platform#feature-taxonomy");
    expect(link.className).toContain("whitespace-nowrap");
  });

  it("refreshes the named feature's readiness, and only that one", async () => {
    const qc = new QueryClient();
    qc.setQueryData(getTaxonomyConfigKey(), { data: { ready: true } });
    qc.setQueryData(getAssessConfigKey(), { data: { ready: true } });
    const spy = vi.spyOn(qc, "invalidateQueries");
    const rootRoute = createRootRoute({ component: () => <Outlet /> });
    const indexRoute = createRoute({
      getParentRoute: () => rootRoute, path: "/",
      component: () => <ConfigMissingNotice missing={refusedItem} message="Refused." />,
    });
    const router = createRouter({ routeTree: rootRoute.addChildren([indexRoute]), history: createMemoryHistory({ initialEntries: ["/"] }) });
    render(<QueryClientProvider client={qc}><RouterProvider router={router as any} /></QueryClientProvider>);
    await screen.findByText("Refused.");
    await waitFor(() => expect(qc.getQueryState(getTaxonomyConfigKey())?.isInvalidated).toBe(true));
    expect(qc.getQueryState(getAssessConfigKey())?.isInvalidated).toBe(false);
    expect(spy).toHaveBeenCalledTimes(1);
  });

  it("a config_missing of platform settings refreshes no feature", async () => {
    const qc = new QueryClient();
    qc.setQueryData(getTaxonomyConfigKey(), { data: { ready: true } });
    const rootRoute = createRootRoute({ component: () => <Outlet /> });
    const indexRoute = createRoute({
      getParentRoute: () => rootRoute, path: "/",
      component: () => <ConfigMissingNotice missing={MISSING} message="Finish setup." />,
    });
    const router = createRouter({ routeTree: rootRoute.addChildren([indexRoute]), history: createMemoryHistory({ initialEntries: ["/"] }) });
    render(<QueryClientProvider client={qc}><RouterProvider router={router as any} /></QueryClientProvider>);
    await screen.findByText("Finish setup.");
    expect(qc.getQueryState(getTaxonomyConfigKey())?.isInvalidated).toBe(false);
  });
});

describe("notifyConfigMissing", () => {
  it("raises the shared toast and returns true for config_missing", () => {
    expect(notifyConfigMissing(configMissingError())).toBe(true);
    expect(vi.mocked(toast.error)).toHaveBeenCalledTimes(1);
    // The toast body IS the shared ConfigMissingNotice element.
    const arg = vi.mocked(toast.error).mock.calls[0][0] as { type?: unknown };
    expect(arg.type).toBe(ConfigMissingNotice);
  });

  it("does nothing and returns false for other errors", () => {
    expect(notifyConfigMissing(new Error("nope"))).toBe(false);
    expect(vi.mocked(toast.error)).not.toHaveBeenCalled();
  });

  it("raises the same toast for a refused taxonomy model service, linking to its setting", () => {
    const refused = new ApiError(400, "Bad Request", {
      detail: { error: "model_service_refused", key: "taxonomy_llm", status: "denied", message: "The app's service principal may not use it." },
    });
    expect(notifyConfigMissing(refused)).toBe(true);
    const arg = vi.mocked(toast.error).mock.calls[0][0] as { type?: unknown; props: { message: string; missing: { key: string; settings_url: string }[] } };
    expect(arg.type).toBe(ConfigMissingNotice);
    expect(arg.props.message).toBe("The app's service principal may not use it.");
    expect(arg.props.missing).toEqual([
      { key: "taxonomy_llm", label: "Domain Taxonomy Builder model service", settings_url: "/settings?tab=platform#feature-taxonomy" },
    ]);
  });

  it("notifyError routes a refused model service through it too", () => {
    const refused = new ApiError(400, "Bad Request", {
      detail: { error: "model_service_refused", key: "taxonomy_llm", status: "not_found", message: "Not found." },
    });
    notifyError(refused, { fallback: "Couldn't start drafting" });
    expect(vi.mocked(toast.error)).toHaveBeenCalledTimes(1);
    expect((vi.mocked(toast.error).mock.calls[0][0] as { type?: unknown }).type).toBe(ConfigMissingNotice);
  });
});
