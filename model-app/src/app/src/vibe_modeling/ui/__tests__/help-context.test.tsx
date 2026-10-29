/**
 * The top bar's Help icon goes to the top-level help page of the area the
 * user is in (`helpTopicForRoute`, one table), and to the main help page when
 * the area has none, its page is not ready, or its optional feature is off.
 */
import { describe, expect, it, vi } from "vitest";
import { render, screen } from "@testing-library/react";
import {
  createMemoryHistory,
  createRootRoute,
  createRoute,
  createRouter,
  RouterProvider,
} from "@tanstack/react-router";

let featureReady = { assessment: true, taxonomy: true };

vi.mock("@/lib/features", async () => {
  const actual = await vi.importActual<typeof import("@/lib/features")>("@/lib/features");
  return { ...actual, useFeaturesReady: () => featureReady };
});

import { HeaderHelpLink } from "@/components/help/header-help-link";
import { HELP_CONTEXT_ROUTES, helpTopicForRoute } from "@/components/help/help-context";
import { HELP_TOPICS, getHelpTopic } from "@/components/help/help-topics";

function renderHeaderHelpAt(initialPath: string) {
  const rootRoute = createRootRoute({ component: HeaderHelpLink });
  const anyRoute = createRoute({ getParentRoute: () => rootRoute, path: "$", component: () => null });
  const router = createRouter({
    routeTree: rootRoute.addChildren([anyRoute]),
    history: createMemoryHistory({ initialEntries: [initialPath] }),
  });
  return render(<RouterProvider router={router} />);
}

const allReady = { assessment: true, taxonomy: true };
const slugAt = (pathname: string, search?: Record<string, unknown>, ready = allReady) =>
  helpTopicForRoute({ pathname, search }, ready)?.slug;

describe("helpTopicForRoute", () => {
  it.each([
    ["/businesses/b1/runs", "runs"],
    ["/businesses/b1/runs/r9", "runs"],
    ["/businesses/b1/runs/new", "runs"],
    ["/businesses/b1/explorer", "flow"],
    ["/businesses/b1/model/3/mvm", "flow"],
    ["/businesses/b1/model/3/ecm/sales", "flow"],
    ["/businesses/b1/model/3/ecm/sales/orders", "flow"],
    ["/businesses/b1/model/3/ecm/inputs", "vibes"],
    ["/businesses/b1/model/3/ecm/inputs/i7", "vibes"],
    ["/businesses/b1/assessments", "assessment"],
    ["/businesses/b1/assessments/new", "assessment"],
    ["/businesses/b1/assessments/batch-1", "assessment"],
    ["/businesses/new/from-domains", "taxonomy-builder"],
    ["/businesses/b1/runs/", "runs"],
  ])("%s -> %s", (pathname, slug) => {
    expect(slugAt(pathname)).toBe(slug);
  });

  it.each([
    ["/businesses/b1/runs/new", "operationType=new base model", "run-new-base-model"],
    ["/businesses/b1/runs/new", "operationType=new-base-model", "run-new-base-model"],
    ["/businesses/b1/runs/new", "operationType=vibe modeling of version", "run-vibe"],
    ["/businesses/b1/runs/new", "operationType=vibe-iterate", "run-vibe"],
    ["/businesses/b1/runs/new", "operationType=vibe new ecm + mvm", "run-vibe-ecm-mvm"],
    ["/businesses/b1/runs/new", "operationType=Vibe_New_ECM_MVM", "run-vibe-ecm-mvm"],
  ])("%s with %s -> %s", (pathname, query, slug) => {
    const [key, value] = query.split("=");
    expect(slugAt(pathname, { [key]: value })).toBe(slug);
  });

  it("falls back to the run types page when the New Run form's operation is unknown or absent", () => {
    expect(slugAt("/businesses/b1/runs/new")).toBe("runs");
    expect(slugAt("/businesses/b1/runs/new", { operationType: "nonsense" })).toBe("runs");
    expect(slugAt("/businesses/b1/runs/new", { operationType: 7 })).toBe("runs");
    expect(slugAt("/businesses/b1/runs/new", { operationType: "install" })).toBe("runs");
  });

  it.each([
    "/",
    "/businesses",
    "/businesses/new",
    "/businesses/b1/edit",
    "/industries",
    "/industries/new",
    "/settings",
    "/profile",
    "/help",
    "/help/flow",
    "/somewhere/unmapped",
  ])("has no topic for %s, so it is the main help page", (pathname) => {
    expect(slugAt(pathname)).toBeUndefined();
  });

  it("falls back to the main help page when the topic's feature is not ready", () => {
    expect(slugAt("/businesses/b1/assessments", undefined, { assessment: false, taxonomy: true })).toBeUndefined();
    expect(slugAt("/businesses/new/from-domains", undefined, { assessment: true, taxonomy: false })).toBeUndefined();
    expect(slugAt("/businesses/b1/runs", undefined, { assessment: false, taxonomy: false })).toBe("runs");
  });

  it("falls back to the main help page when the topic is coming soon", () => {
    const flow = getHelpTopic("flow")!;
    const original = flow.status;
    flow.status = "soon";
    try {
      expect(slugAt("/businesses/b1/explorer")).toBeUndefined();
    } finally {
      flow.status = original;
    }
  });

  it("names only topics the help catalogue has", () => {
    const slugs = new Set(HELP_TOPICS.map((t) => t.slug));
    for (const route of HELP_CONTEXT_ROUTES) {
      if (typeof route.topic === "string") expect(slugs.has(route.topic)).toBe(true);
    }
  });
});

describe("HeaderHelpLink", () => {
  it("links to the area's help page and names it", async () => {
    featureReady = allReady;
    renderHeaderHelpAt("/businesses/b1/runs");
    const link = await screen.findByTestId("header-help-link");
    expect(link.getAttribute("href")).toBe("/help/runs");
    expect(link.getAttribute("aria-label")).toBe("Help: Run types and what they change");
    expect(link.getAttribute("title")).toBe("Help: Run types and what they change");
  });

  it("follows the New Run form's operation", async () => {
    featureReady = allReady;
    renderHeaderHelpAt("/businesses/b1/runs/new?operationType=vibe-iterate");
    const link = await screen.findByTestId("header-help-link");
    expect(link.getAttribute("href")).toBe("/help/run-vibe");
    expect(link.getAttribute("aria-label")).toBe("Help: Vibe Modeling");
  });

  it("links to the main help page on a page with no help area", async () => {
    featureReady = allReady;
    renderHeaderHelpAt("/settings");
    const link = await screen.findByTestId("header-help-link");
    expect(link.getAttribute("href")).toBe("/help");
    expect(link.getAttribute("aria-label")).toBe("Help");
  });

  it("links to the main help page when the area's feature is off", async () => {
    featureReady = { assessment: false, taxonomy: true };
    renderHeaderHelpAt("/businesses/b1/assessments");
    const link = await screen.findByTestId("header-help-link");
    expect(link.getAttribute("href")).toBe("/help");
  });
});
