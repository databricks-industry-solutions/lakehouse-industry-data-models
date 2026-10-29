/**
 * New Business form requires a non-empty business summary (description).
 *
 * Submit is gated on both ``name`` and a non-whitespace ``description``. The
 * form's taxonomy picker is now the ``SectorSelect`` (ADR D-047) — there is no
 * industry-pick auto-seed anymore, so the description must be typed by the
 * user. We mock ``useListSectorsSuspense`` so the embedded SectorSelect
 * resolves without a network fetch.
 */
import { describe, it, expect, beforeEach, afterEach, vi } from "vitest";
import { warmImports } from "./helpers/warm-imports";
import { render, screen, waitFor, fireEvent } from "@testing-library/react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { Suspense } from "react";
import {
  createMemoryHistory,
  createRootRoute,
  createRoute,
  createRouter,
  Outlet,
  RouterProvider,
} from "@tanstack/react-router";

const RETAIL_SECTOR = {
  id: "sec-retail",
  name: "Retail & E-Commerce",
  short_name: "retail",
  description: "",
  display_order: 1,
  is_active: true,
  created_at: "2024-01-01T00:00:00Z",
  updated_at: "2024-01-01T00:00:00Z",
};

let sectorsHook: () => unknown = () => ({ data: [RETAIL_SECTOR] });
const createBusinessMock = vi.fn(async () => ({ data: { id: "new-biz-id" } }));

vi.mock("@/lib/api", async () => {
  const actual = await vi.importActual<typeof import("@/lib/api")>("@/lib/api");
  return {
    ...actual,
    useListSectorsSuspense: () => sectorsHook(),
    createBusiness: createBusinessMock,
  };
});

beforeEach(() => {
  sectorsHook = () => ({ data: [RETAIL_SECTOR] });
  createBusinessMock.mockClear();
});

afterEach(() => {
  vi.restoreAllMocks();
});

async function renderNewBusiness() {
  const { Route: BusinessesNewRoute } = await import(
    "@/routes/_sidebar/businesses.new"
  );
  const rootRoute = createRootRoute({ component: () => <Outlet /> });
  const sidebarRoute = createRoute({
    getParentRoute: () => rootRoute,
    id: "/_sidebar",
    component: () => <Outlet />,
  });
  const businessesNewClone = createRoute({
    getParentRoute: () => sidebarRoute,
    path: "/businesses/new",
    component: BusinessesNewRoute.options.component as any,
  });
  const businessRoute = createRoute({
    getParentRoute: () => rootRoute,
    path: "/businesses/$businessId",
    component: () => <div data-testid="business-stub" />,
  });
  const businessesRoute = createRoute({
    getParentRoute: () => rootRoute,
    path: "/businesses",
    component: () => <div data-testid="businesses-stub" />,
  });
  const router = createRouter({
    routeTree: rootRoute.addChildren([
      sidebarRoute.addChildren([businessesNewClone]),
      businessRoute,
      businessesRoute,
    ]),
    history: createMemoryHistory({ initialEntries: ["/businesses/new"] }),
    defaultPendingMs: 0,
  });
  const qc = new QueryClient({
    defaultOptions: {
      queries: { retry: false },
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
  // SectorSelect mounts inside its own Suspense; wait for its combobox.
  await waitFor(() => {
    expect(screen.queryByRole("combobox")).not.toBeNull();
  });
}

function getNameInput(): HTMLInputElement {
  return screen.getByPlaceholderText(/Contoso Retail/i) as HTMLInputElement;
}

function getDescriptionTextarea(): HTMLTextAreaElement {
  return screen.getByTestId("business-description") as HTMLTextAreaElement;
}

function getSubmitButton(): HTMLButtonElement {
  return screen.getByRole("button", { name: /Create Business/i }) as HTMLButtonElement;
}

warmImports(() => import("@/routes/_sidebar/businesses.new"));

describe("New Business — non-empty description required to create a Business", () => {
  it("submit disabled when only name is filled", async () => {
    await renderNewBusiness();

    fireEvent.change(getNameInput(), { target: { value: "Acme Co" } });

    expect(getSubmitButton().disabled).toBe(true);
  });

  it("submit disabled when description is only whitespace", async () => {
    await renderNewBusiness();

    fireEvent.change(getNameInput(), { target: { value: "Acme Co" } });
    fireEvent.change(getDescriptionTextarea(), { target: { value: "   \n  " } });

    expect(getSubmitButton().disabled).toBe(true);
  });

  it("submit enabled when name + description are both non-empty", async () => {
    await renderNewBusiness();

    fireEvent.change(getNameInput(), { target: { value: "Acme Co" } });
    fireEvent.change(getDescriptionTextarea(), {
      target: { value: "A typed description." },
    });

    expect(getSubmitButton().disabled).toBe(false);
  });

  it("passes the chosen sector_id through to createBusiness on submit", async () => {
    await renderNewBusiness();

    fireEvent.change(getNameInput(), { target: { value: "Acme Co" } });
    fireEvent.change(getDescriptionTextarea(), {
      target: { value: "A typed description." },
    });

    fireEvent.click(screen.getByRole("combobox"));
    fireEvent.click(
      await screen.findByRole("option", { name: /Retail & E-Commerce/ }),
    );

    fireEvent.click(getSubmitButton());

    await waitFor(() => {
      expect(createBusinessMock).toHaveBeenCalledWith(
        expect.objectContaining({ sector_id: "sec-retail" }),
      );
    });
  });
});
