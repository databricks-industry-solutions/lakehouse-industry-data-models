/**
 * Track B coverage: ``DownloadIndustryDialog`` + ``DownloadConflictStep``
 * (Stories 4 + 7).
 *
 * The dialog mounts ``SectorSelect`` (suspense, reads ``useListSectorsSuspense``)
 * so we mock the sectors list. Under additive semantics the download submits
 * with no ``on_conflict``; the conflict branch is a 409
 * ``industry_model_already_exists`` (same-scope clash) that renders an
 * informational, button-free notice. On success the dialog closes itself
 * (``onOpenChange(false)``) and hands the result to ``onDownloaded`` - no
 * toast, no navigation from this dialog; the host owns the completion UI.
 */
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";
import {
  act,
  fireEvent,
  render,
  screen,
  waitFor,
  within,
} from "@testing-library/react";
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

// ``useDownloadIndustryModel`` closes over the module-internal
// ``downloadIndustryModel`` (not the exported binding), so mocking the bare
// function does nothing. Replace the hook with a real ``useMutation`` whose
// ``mutationFn`` delegates to the mocked function so per-call onSuccess/onError
// (which the dialog relies on) still fire.
vi.mock("@/lib/api", async () => {
  const actual = await vi.importActual<typeof import("@/lib/api")>("@/lib/api");
  const rq =
    await vi.importActual<typeof import("@tanstack/react-query")>(
      "@tanstack/react-query",
    );
  const downloadIndustryModel = vi.fn();
  return {
    ...actual,
    downloadIndustryModel,
    useListSectorsSuspense: vi.fn(),
    useDownloadIndustryModel: () =>
      rq.useMutation({
        mutationFn: (vars: { params: unknown; data: unknown }) =>
          downloadIndustryModel(vars.data, vars.params),
      }),
  };
});

vi.mock("sonner", () => ({
  toast: {
    success: vi.fn(),
    warning: vi.fn(),
    error: vi.fn(),
    info: vi.fn(),
  },
}));

import { toast } from "sonner";
import {
  downloadIndustryModel,
  useListSectorsSuspense,
  ApiError,
} from "@/lib/api";
import { DownloadIndustryDialog } from "@/components/import/download-industry-dialog";
import {
  parseDownloadConflict,
} from "@/components/import/download-conflict-step";

const mockedDownload = vi.mocked(downloadIndustryModel);
const mockedSectors = vi.mocked(useListSectorsSuspense);

const SELECTION = {
  industry_id: "ind-1",
  model_id: "model-1",
  suggested_sector_id: "sec-retail",
};

function makeRouter(ui: ReactNode) {
  const rootRoute = createRootRoute({ component: () => <Outlet /> });
  const indexRoute = createRoute({
    getParentRoute: () => rootRoute,
    path: "/",
    component: () => <>{ui}</>,
  });
  const explorerRoute = createRoute({
    getParentRoute: () => rootRoute,
    path: "/businesses/$businessId/explorer",
    component: () => <div data-testid="explorer-stub" />,
  });
  return createRouter({
    routeTree: rootRoute.addChildren([indexRoute, explorerRoute]),
    history: createMemoryHistory({ initialEntries: ["/"] }),
  });
}

function wrap(ui: ReactNode) {
  const qc = new QueryClient({
    defaultOptions: {
      queries: { retry: false },
      mutations: { retry: false },
    },
  });
  const router = makeRouter(ui);
  return (
    <QueryClientProvider client={qc}>
      <RouterProvider router={router as any} />
    </QueryClientProvider>
  );
}

beforeEach(() => {
  mockedDownload.mockReset();
  mockedSectors.mockReturnValue({
    data: [
      { id: "sec-retail", name: "Retail", is_active: true },
      { id: "sec-fsi", name: "Financial Services", is_active: true },
    ],
  } as unknown as ReturnType<typeof useListSectorsSuspense>);
});

afterEach(() => {
  vi.restoreAllMocks();
});

describe("parseDownloadConflict", () => {
  it("reads scope from a wrapped same-scope 409", () => {
    const parsed = parseDownloadConflict(
      new ApiError(409, "Conflict", {
        detail: {
          error: "industry_model_already_exists",
          scope: "ecm",
          message: "This model (ecm) is already downloaded for Retail.",
        },
      }),
    );
    expect(parsed).not.toBeNull();
    expect(parsed?.scope).toBe("ecm");
    expect(parsed?.error).toBe("industry_model_already_exists");
  });

  it("returns null for non-409 or non-model-clash errors", () => {
    expect(parseDownloadConflict(new ApiError(500, "boom", {}))).toBeNull();
    expect(
      parseDownloadConflict(
        new ApiError(409, "Conflict", { detail: { error: "other" } }),
      ),
    ).toBeNull();
    // The old industry-unit code is no longer recognised.
    expect(
      parseDownloadConflict(
        new ApiError(409, "Conflict", {
          detail: { error: "industry_already_exists" },
        }),
      ),
    ).toBeNull();
    expect(parseDownloadConflict(new Error("nope"))).toBeNull();
  });
});

describe("DownloadIndustryDialog", () => {
  it("pre-fills the suggested sector and submits with no on_conflict", async () => {
    mockedDownload.mockResolvedValue({
      data: {
        business_id: "biz-1",
        business_name: "Retail Industry",
        version: 1,
        version_id: "v-1",
        domains: 5,
        scope: "ecm",
        on_conflict_applied: "none",
      },
    } as unknown as Awaited<ReturnType<typeof downloadIndustryModel>>);

    render(
      wrap(
        <DownloadIndustryDialog
          selection={SELECTION}
          open
          onOpenChange={() => {}}
        />,
      ),
    );

    const submit = await screen.findByTestId("download-submit");
    expect(submit).not.toBeDisabled();
    await act(async () => {
      fireEvent.click(submit);
    });

    await waitFor(() => {
      expect(mockedDownload).toHaveBeenCalledWith(
        {
          sector_id: "sec-retail",
          industry_id: "ind-1",
          model_id: "model-1",
        },
        {},
      );
    });
  });

  it("shows a button-free same-scope notice on a 409 industry_model_already_exists", async () => {
    mockedDownload.mockRejectedValueOnce(
      new ApiError(409, "Conflict", {
        detail: {
          error: "industry_model_already_exists",
          scope: "ecm",
          message: "This model (ecm) is already downloaded for Retail.",
        },
      }),
    );

    render(
      wrap(
        <DownloadIndustryDialog
          selection={SELECTION}
          open
          onOpenChange={() => {}}
        />,
      ),
    );

    await act(async () => {
      fireEvent.click(await screen.findByTestId("download-submit"));
    });

    // Conflict step renders — informational only, no resolution buttons.
    const step = await screen.findByTestId("download-conflict-step");
    expect(step).toHaveTextContent(/already downloaded/i);
    expect(screen.queryByTestId("conflict-replace")).toBeNull();
    expect(screen.queryByTestId("conflict-create-distinct")).toBeNull();
    // Only a Close affordance inside the step (Radix's own dialog close
    // button is excluded by scoping to the step).
    expect(
      within(step).getByRole("button", { name: /^Close$/i }),
    ).toBeInTheDocument();
  });

  it("does not navigate away on success - closes itself and hands the result to the host", async () => {
    mockedDownload.mockResolvedValue({
      data: {
        business_id: "biz-1",
        business_name: "Retail Industry",
        version: 1,
        version_id: "v-1",
        domains: 5,
        products: 10,
        attribute_count: 40,
        fk_count: 3,
        scope: "ecm",
        on_conflict_applied: "added",
      },
    } as unknown as Awaited<ReturnType<typeof downloadIndustryModel>>);

    const onDownloaded = vi.fn();
    const onOpenChange = vi.fn();
    render(
      wrap(
        <DownloadIndustryDialog
          selection={SELECTION}
          open
          onOpenChange={onOpenChange}
          onDownloaded={onDownloaded}
        />,
      ),
    );

    await act(async () => {
      fireEvent.click(await screen.findByTestId("download-submit"));
    });

    // The dialog requests its own close and hands the result up (no
    // explorer-stub navigation from THIS dialog - that's the host's job).
    await waitFor(() => expect(onDownloaded).toHaveBeenCalledTimes(1));
    expect(onOpenChange).toHaveBeenCalledWith(false);
    expect(onDownloaded).toHaveBeenCalledWith(
      expect.objectContaining({ business_name: "Retail Industry" }),
    );
    expect(screen.queryByTestId("explorer-stub")).toBeNull();
  });

  it("never shows a success or warning toast - the completion dialog is the host's job", async () => {
    mockedDownload.mockResolvedValue({
      data: {
        business_id: "biz-1",
        business_name: "Retail Industry",
        version: 1,
        version_id: "v-1",
        domains: 5,
        products: 10,
        attribute_count: 40,
        fk_count: 3,
        scope: "v1_ecm",
        on_conflict_applied: "none",
        run_id: "run-42",
        warnings: ["could not fetch an artifact"],
      },
    } as unknown as Awaited<ReturnType<typeof downloadIndustryModel>>);

    render(
      wrap(
        <DownloadIndustryDialog
          selection={SELECTION}
          open
          onOpenChange={() => {}}
        />,
      ),
    );

    await act(async () => {
      fireEvent.click(await screen.findByTestId("download-submit"));
    });

    await waitFor(() => {
      expect(mockedDownload).toHaveBeenCalled();
    });
    expect(toast.success).not.toHaveBeenCalled();
    expect(toast.warning).not.toHaveBeenCalled();
  });

  it("routes a 422 config_missing through the shared renderer, not a generic inline banner", async () => {
    mockedDownload.mockRejectedValueOnce(
      new ApiError(422, "Unprocessable Entity", {
        detail: {
          error: "config_missing",
          missing: [
            {
              key: "metamodel_catalog",
              label: "Metamodel catalog",
              settings_url: "/settings?tab=platform",
            },
          ],
          message: "Finish setup before downloading.",
        },
      }),
    );

    render(
      wrap(
        <DownloadIndustryDialog
          selection={SELECTION}
          open
          onOpenChange={() => {}}
        />,
      ),
    );

    await act(async () => {
      fireEvent.click(await screen.findByTestId("download-submit"));
    });

    // Shared renderer fires (rich toast), and the generic inline fallback
    // ("Download failed") does not.
    await waitFor(() => expect(toast.error).toHaveBeenCalledTimes(1));
    expect(screen.queryByText(/Download failed/i)).toBeNull();
    expect(screen.queryByTestId("download-conflict-step")).toBeNull();
  });

  it("shows the 400 detail of a refused _metamodel setup, not the HTTP status line", async () => {
    const detail =
      "The app can't create `_metamodel` in 'cat' (needs USE_CATALOG + CREATE_SCHEMA on the catalog).";
    mockedDownload.mockRejectedValueOnce(
      new ApiError(400, "Bad Request", { detail }),
    );

    render(
      wrap(
        <DownloadIndustryDialog
          selection={SELECTION}
          open
          onOpenChange={() => {}}
        />,
      ),
    );

    await act(async () => {
      fireEvent.click(await screen.findByTestId("download-submit"));
    });

    expect(await screen.findByText(detail)).toBeTruthy();
    expect(screen.queryByText(/HTTP 400/)).toBeNull();
  });

  it("blocks download until a sector is selected", async () => {
    render(
      wrap(
        <DownloadIndustryDialog
          selection={{ industry_id: "ind-1", model_id: "model-1" }}
          open
          onOpenChange={() => {}}
        />,
      ),
    );
    const submit = await screen.findByTestId("download-submit");
    expect(submit).toBeDisabled();
  });

  it("renders guidance when no model is selected", async () => {
    render(
      wrap(
        <DownloadIndustryDialog selection={null} open onOpenChange={() => {}} />,
      ),
    );
    expect(
      await screen.findByText(/No source model selected/i),
    ).toBeInTheDocument();
  });
});
