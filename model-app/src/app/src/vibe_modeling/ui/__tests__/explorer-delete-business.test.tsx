/**
 * "Delete business" lives on the EXPLORER page (the business's main page),
 * not the Runs page. These tests lock that move:
 *   - the explorer header renders a "Delete business" button,
 *   - confirming always deletes with `cascade=true` (the endpoint requires it
 *     when the business has versions OR runs OR feedback; cascade on an empty
 *     business is a harmless no-op), then redirects to /businesses,
 *   - a delete failure surfaces a toast and stays on the page,
 *   - installed versions are listed to uninstall first and Delete stays off,
 *   - an unfinished `_metamodel` cleanup in the response raises a warning.
 *
 * The explorer calls the standalone `deleteBusiness` API function (not the
 * `useDeleteBusiness` hook), so we mock that function directly.
 */
import { afterEach, describe, expect, it, vi } from "vitest";
import { warmImports } from "./helpers/warm-imports";
import { fireEvent, render, screen, waitFor, act, within } from "@testing-library/react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { Suspense } from "react";
import { ApiError } from "@/lib/api";
import {
  createMemoryHistory,
  createRootRoute,
  createRoute,
  createRouter,
  Outlet,
  RouterProvider,
} from "@tanstack/react-router";

const businessData = {
  id: "biz-1",
  name: "Acme Co",
  description: "An acme business.",
  business_vibes: "",
  industry_alignment: "Retail",
  industry_id: null,
  created_at: "2024-01-01T00:00:00Z",
  updated_at: "2024-01-01T00:00:00Z",
};

let versionsData: any[] = [];
let lifecycleData: any[] = [];
let lifecycleState: any = { isSuccess: true, isError: false };
const refetchMock = vi.fn();
const deleteBusinessMock = vi.fn().mockResolvedValue({ data: {} });

vi.mock("@/lib/api", async () => {
  const actual = await vi.importActual<typeof import("@/lib/api")>("@/lib/api");
  return {
    ...actual,
    useGetBusinessSuspense: () => ({ data: businessData }),
    useListIndustriesSuspense: () => ({ data: [] }),
    useGetExplorerVersionsSuspense: () => ({ data: versionsData }),
    // The explorer joins the lifecycle columns from the versions list and
    // lists unfinished metamodel cleanups.
    useListVersionsSuspense: () => ({ data: lifecycleData }),
    useListVersions: () => ({ data: { data: lifecycleData }, ...lifecycleState, refetch: refetchMock }),
    useListMetamodelCleanups: () => ({ data: { data: [] } }),
    useListSectorsSuspense: () => ({ data: [] }),
    deleteBusiness: (params: { business_id: string; cascade?: boolean }) =>
      deleteBusinessMock(params),
  };
});

vi.mock("@/components/explorer/breadcrumb-context", () => ({
  useBreadcrumbs: () => {},
}));

vi.mock("sonner", () => ({
  toast: { error: vi.fn(), success: vi.fn(), warning: vi.fn() },
}));

import { toast } from "sonner";

afterEach(() => {
  vi.clearAllMocks();
  versionsData = [];
  lifecycleData = [];
  lifecycleState = { isSuccess: true, isError: false };
});

async function renderExplorer() {
  const { Route: ExplorerRoute } = await import(
    "@/routes/_sidebar/businesses.$businessId.explorer"
  );
  const rootRoute = createRootRoute({ component: () => <Outlet /> });
  const sidebarRoute = createRoute({
    getParentRoute: () => rootRoute,
    id: "/_sidebar",
    component: () => <Outlet />,
  });
  const explorerClone = createRoute({
    getParentRoute: () => sidebarRoute,
    path: "/businesses/$businessId/explorer",
    component: ExplorerRoute.options.component as any,
  });
  const businessesStub = createRoute({
    getParentRoute: () => rootRoute,
    path: "/businesses",
    component: () => <div data-testid="businesses-stub" />,
  });
  const router = createRouter({
    routeTree: rootRoute.addChildren([
      sidebarRoute.addChildren([explorerClone]),
      businessesStub,
    ]),
    history: createMemoryHistory({
      initialEntries: ["/businesses/biz-1/explorer"],
    }),
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
  return qc;
}

async function openDeleteDialog() {
  const trigger = await screen.findByRole("button", { name: /delete business/i });
  await act(async () => {
    fireEvent.click(trigger);
  });
}

warmImports(() => import("@/routes/_sidebar/businesses.$businessId.explorer"));

describe("Explorer page — Delete business", () => {
  it("renders the Delete business button in the header", async () => {
    await renderExplorer();
    expect(
      await screen.findByRole("button", { name: /delete business/i }),
    ).toBeInTheDocument();
  });

  it("cascades on confirm when the business has versions, then redirects", async () => {
    versionsData = [{ id: "v1", version: 1, scope: "mvm", status: "completed", created_at: "2024-01-01T00:00:00Z" }];
    const qc = await renderExplorer();
    const invalidateSpy = vi.spyOn(qc, "invalidateQueries");
    await openDeleteDialog();

    // Version-count detail is visible when versions exist.
    expect(screen.getByText(/will be removed from Lakebase/i)).toBeInTheDocument();
    // The delete removes the app's copies of the model files; the dialog says so.
    const detail = screen.getByText(/will be removed from Lakebase/i);
    expect(detail).toHaveTextContent(
      "The model files the app copied into its own Volume folders at download, kickstart or import (from 0.9.0) are deleted.",
    );
    expect(detail).toHaveTextContent("Older copies, files the agent wrote, and the file an import read, stay.");
    expect(detail).not.toHaveTextContent(/model files in Volumes stay/i);

    await act(async () => {
      fireEvent.click(
        within(screen.getByRole("dialog")).getByRole("button", { name: /^delete business$/i }),
      );
    });

    await waitFor(() =>
      expect(deleteBusinessMock).toHaveBeenCalledWith({
        business_id: "biz-1",
        cascade: true,
      }),
    );
    // The reported bug: delete-then-navigate never invalidated the
    // businesses-list cache, so /businesses served a stale row on return.
    await waitFor(() =>
      expect(invalidateSpy).toHaveBeenCalledWith({
        predicate: expect.any(Function),
      }),
    );
    await waitFor(() =>
      expect(screen.getByTestId("businesses-stub")).toBeInTheDocument(),
    );
  });

  it("still deletes with cascade=true on an empty business (no 409 path)", async () => {
    versionsData = [];
    await renderExplorer();
    await openDeleteDialog();

    // Always-cascade warning is shown; the version-count line is omitted at 0.
    expect(
      screen.getByText(/permanently deletes this business/i),
    ).toBeInTheDocument();
    expect(screen.queryByText(/will be removed from Lakebase/i)).toBeNull();

    await act(async () => {
      fireEvent.click(
        within(screen.getByRole("dialog")).getByRole("button", { name: /^delete business$/i }),
      );
    });

    await waitFor(() =>
      expect(deleteBusinessMock).toHaveBeenCalledWith({
        business_id: "biz-1",
        cascade: true,
      }),
    );
  });

  it("surfaces a toast on delete failure and stays on the page", async () => {
    deleteBusinessMock.mockRejectedValueOnce(new Error("boom"));
    await renderExplorer();
    await openDeleteDialog();

    await act(async () => {
      fireEvent.click(
        within(screen.getByRole("dialog")).getByRole("button", { name: /^delete business$/i }),
      );
    });

    await waitFor(() => expect(toast.error).toHaveBeenCalled());
    expect(screen.queryByTestId("businesses-stub")).toBeNull();
  });

  it("a proxy 504 says the delete may still be finishing, refreshes the lists and stays on the page", async () => {
    deleteBusinessMock.mockRejectedValueOnce(new ApiError(504, "Gateway Timeout", null));
    const qc = await renderExplorer();
    const invalidateSpy = vi.spyOn(qc, "invalidateQueries");
    await openDeleteDialog();

    await act(async () => {
      fireEvent.click(
        within(screen.getByRole("dialog")).getByRole("button", { name: /^delete business$/i }),
      );
    });

    await waitFor(() =>
      expect(toast.warning).toHaveBeenCalledWith("The delete may still be finishing; refresh to check."),
    );
    expect(toast.error).not.toHaveBeenCalled();
    expect(invalidateSpy).toHaveBeenCalledWith({ predicate: expect.any(Function) });
    expect(screen.queryByTestId("businesses-stub")).toBeNull();
  });

  it("lists installed versions to uninstall first and keeps Delete off", async () => {
    versionsData = [
      { id: "v5", version: 5, scope: "ecm", status: "completed", created_at: "2024-01-01T00:00:00Z" },
      { id: "v4", version: 4, scope: "mvm", status: "completed", created_at: "2024-01-01T00:00:00Z" },
    ];
    lifecycleData = [
      { id: "v5", version: 5, scope: "ecm", status: "completed", deployment_status: "deployed", uc_catalog: "sales_cat" },
      { id: "v4", version: 4, scope: "mvm", status: "completed", deployment_status: "uninstalled", uc_catalog: "sales_cat" },
    ];
    await renderExplorer();
    await openDeleteDialog();

    const installed = screen.getByTestId("delete-business-installed");
    expect(installed).toHaveTextContent(/Uninstall these versions first/);
    expect(installed).toHaveTextContent("v5 ECM is installed in sales_cat");
    expect(installed).not.toHaveTextContent("v4 MVM");
    const confirm = within(screen.getByRole("dialog")).getByRole("button", { name: /^delete business$/i });
    expect(confirm).toBeDisabled();
    expect(screen.getByText(/registry rows/i)).toBeInTheDocument();
  });

  it("warns when the agent's registry cleanup is unfinished, then redirects", async () => {
    versionsData = [{ id: "v1", version: 1, scope: "mvm", status: "completed", created_at: "2024-01-01T00:00:00Z" }];
    deleteBusinessMock.mockResolvedValueOnce({
      data: { ok: true, cascaded: true, metamodel_cleanup: { done: 1, pending: 0, failed: 1 } },
    });
    await renderExplorer();
    await openDeleteDialog();

    await act(async () => {
      fireEvent.click(
        within(screen.getByRole("dialog")).getByRole("button", { name: /^delete business$/i }),
      );
    });

    await waitFor(() => expect(toast.warning).toHaveBeenCalledTimes(1));
    const [title, opts] = (toast.warning as any).mock.calls[0];
    expect(title).toBe('Deleted "Acme Co"');
    expect(opts.description).toBe(
      "1 registry cleanup did not finish, so the agent's registry rows are still there. " +
        "The app retries at the next start-ups. " +
        "A business created again with this name lists the retries with Retry cleanup.",
    );
    await waitFor(() => expect(screen.getByTestId("businesses-stub")).toBeInTheDocument());
  });

  it("raises no warning when every cleanup finished", async () => {
    deleteBusinessMock.mockResolvedValueOnce({
      data: { ok: true, cascaded: true, metamodel_cleanup: { done: 2, pending: 0, failed: 0 } },
    });
    await renderExplorer();
    await openDeleteDialog();
    await act(async () => {
      fireEvent.click(
        within(screen.getByRole("dialog")).getByRole("button", { name: /^delete business$/i }),
      );
    });
    await waitFor(() => expect(screen.getByTestId("businesses-stub")).toBeInTheDocument());
    expect(toast.warning).not.toHaveBeenCalled();
    expect(toast.success).toHaveBeenCalledWith('Deleted "Acme Co"');
  });

  it("says why Delete is off when the version list fails to load, and retries", async () => {
    lifecycleState = { isSuccess: false, isError: true, data: undefined };
    await renderExplorer();
    await openDeleteDialog();
    const dialog = screen.getByRole("dialog");
    expect(within(dialog).getByText(/Couldn't load the version list, so Delete is off/)).toBeInTheDocument();
    expect(within(dialog).getByRole("button", { name: /^delete business$/i })).toBeDisabled();
    await act(async () => {
      fireEvent.click(within(dialog).getByRole("button", { name: /try again/i }));
    });
    expect(refetchMock).toHaveBeenCalledTimes(1);
  });
});
