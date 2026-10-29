/**
 * The "Build from your domains" card is the only link to the optional Domain
 * Taxonomy Builder. It shows only when GET /config/taxonomy reports `ready`;
 * hidden while loading, on error, when not installed, and when not ready. The
 * grid's column count follows the number of cards.
 */
import { beforeEach, describe, expect, it, vi } from "vitest";
import { render, screen } from "@testing-library/react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import {
  createMemoryHistory,
  createRootRoute,
  createRoute,
  createRouter,
  Outlet,
  RouterProvider,
} from "@tanstack/react-router";
import type { ReactNode } from "react";

const m = vi.hoisted(() => ({ config: { current: {} as any } }));

vi.mock("@/lib/api", async () => {
  const actual = await vi.importActual<typeof import("@/lib/api")>("@/lib/api");
  return { ...actual, useGetTaxonomyConfig: () => m.config.current };
});
vi.mock("@/components/import/import-new-business-dialog", () => ({
  ImportNewBusinessDialog: ({ trigger }: { trigger: ReactNode }) => <>{trigger}</>,
}));

import { EntryPoints } from "@/components/home/entry-points";

const BASE = {
  installed: true, ready: true, model_service: "main.ai.drafter", install_default_model_service: "",
  max_concurrency: 6, last_check: null,
};

async function renderEntryPoints() {
  const root = createRootRoute({ component: () => <Outlet /> });
  const subject = createRoute({ getParentRoute: () => root, path: "/", component: () => <EntryPoints /> });
  const stubs = ["/industries", "/businesses/new", "/businesses/new/from-domains"].map((path) =>
    createRoute({ getParentRoute: () => root, path, component: () => <div /> }),
  );
  const router = createRouter({
    routeTree: root.addChildren([subject, ...stubs]),
    history: createMemoryHistory({ initialEntries: ["/"] }),
  });
  render(
    <QueryClientProvider client={new QueryClient()}>
      <RouterProvider router={router as any} />
    </QueryClientProvider>,
  );
  await screen.findByText("Browse industries");
}

const card = () => screen.queryByRole("link", { name: /build from your domains/i });
const grid = () => screen.getByText("Browse industries").closest("div.grid") as HTMLElement;

beforeEach(() => {
  m.config.current = { data: { data: BASE } };
});

describe("EntryPoints: Domain Taxonomy Builder card", () => {
  it("shows the card in a 4-column grid when ready", async () => {
    await renderEntryPoints();
    expect(card()?.getAttribute("href")).toBe("/businesses/new/from-domains");
    expect(grid().className.split(/\s+/)).toEqual(expect.arrayContaining(["sm:grid-cols-2", "lg:grid-cols-4"]));
  });

  it("names no model vendor: the drafter is whichever model service is configured", async () => {
    await renderEntryPoints();
    expect(card()?.textContent).toContain("The model drafts it, you shape it");
    expect(card()?.textContent).not.toMatch(/claude/i);
  });

  it.each([
    ["loading", { data: undefined }],
    ["error", { data: undefined, error: new Error("boom") }],
    ["not installed", { data: { data: { ...BASE, installed: false, ready: false } } }],
    ["no model service", { data: { data: { ...BASE, model_service: "", ready: false } } }],
    ["access refused", { data: { data: { ...BASE, ready: false } } }],
  ])("hides the card when %s, and the grid keeps the 3-card layout", async (_label, result) => {
    m.config.current = result;
    await renderEntryPoints();
    expect(card()).toBeNull();
    // The original 3-card layout: one row from sm up, no 2-column step.
    const cls = grid().className.split(/\s+/);
    expect(cls).toContain("sm:grid-cols-3");
    expect(cls.some((c) => c.startsWith("lg:grid-cols") || c === "sm:grid-cols-2")).toBe(false);
    expect(screen.getByText("New business")).toBeTruthy();
  });
});
