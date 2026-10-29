/**
 * Story 8 — Kickstart a business from an industry (Track E).
 *
 * Locks the explorer-page wiring:
 *   - the "Kickstart a business" button shows ONLY when business.kind === "industry",
 *   - submitting calls kickstartFromIndustry with whole_model: true and the picked
 *     source_version, then navigates to the new business's explorer,
 *   - a 409 (business_name_taken) surfaces inline on the name field,
 *   - the "Kickstarted from <industry> v<n>" provenance line renders for a
 *     kickstarted (kind="business") business and links back to the source.
 *
 * The explorer reads business data from useGetBusinessSuspense (:94) and the
 * dialog reads the industry's versions via useGetExplorerVersions; we mock both.
 */
import { afterEach, describe, expect, it, vi } from "vitest";
import { warmImports } from "./helpers/warm-imports";
import {
  fireEvent,
  render,
  screen,
  waitFor,
  act,
  within,
} from "@testing-library/react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { Suspense } from "react";
import { toast } from "sonner";
import {
  createMemoryHistory,
  createRootRoute,
  createRoute,
  createRouter,
  Outlet,
  RouterProvider,
} from "@tanstack/react-router";
import { ApiError } from "@/lib/api";

let businessData: any = {
  id: "ind-1",
  name: "Retail Industry",
  description: "An industry.",
  business_vibes: "",
  industry_alignment: "Retail",
  kind: "industry",
  source_industry_id: null,
  source_version: null,
  created_at: "2024-01-01T00:00:00Z",
  updated_at: "2024-01-01T00:00:00Z",
};

let explorerVersions: any[] = [
  { id: "v2", version: 2, scope: "mvm", status: "completed", is_base: false, created_at: "2024-01-02T00:00:00Z" },
  { id: "v1", version: 1, scope: "mvm", status: "completed", is_base: true, created_at: "2024-01-01T00:00:00Z" },
];

let businessesList: any[] = [];

const kickstartMock = vi.fn();
const navigateMock = vi.fn();

vi.mock("@/lib/api", async () => {
  const actual = await vi.importActual<typeof import("@/lib/api")>("@/lib/api");
  return {
    ...actual,
    useGetBusinessSuspense: () => ({ data: businessData }),
    useListIndustriesSuspense: () => ({ data: [] }),
    useListBusinessesSuspense: () => ({ data: businessesList }),
    useGetExplorerVersionsSuspense: () => ({ data: explorerVersions }),
    // The explorer joins the lifecycle columns from the versions list and
    // lists unfinished metamodel cleanups.
    useListVersionsSuspense: () => ({ data: [] }),
    useListMetamodelCleanups: () => ({ data: { data: [] } }),
    useListSectorsSuspense: () => ({ data: [] }),
    useGetExplorerVersions: () => ({ data: { data: explorerVersions }, isLoading: false }),
    useKickstartFromIndustry: () => ({
      mutateAsync: kickstartMock,
      isPending: false,
    }),
  };
});

vi.mock("@tanstack/react-router", async () => {
  const actual = await vi.importActual<typeof import("@tanstack/react-router")>(
    "@tanstack/react-router",
  );
  return { ...actual, useNavigate: () => navigateMock };
});

vi.mock("@/components/explorer/breadcrumb-context", () => ({
  useBreadcrumbs: () => {},
}));

vi.mock("sonner", () => ({
  toast: { error: vi.fn(), success: vi.fn() },
}));

afterEach(() => {
  vi.clearAllMocks();
  businessData = {
    id: "ind-1",
    name: "Retail Industry",
    description: "An industry.",
    business_vibes: "",
    industry_alignment: "Retail",
    kind: "industry",
    source_industry_id: null,
    source_version: null,
    created_at: "2024-01-01T00:00:00Z",
    updated_at: "2024-01-01T00:00:00Z",
  };
  explorerVersions = [
    { id: "v2", version: 2, scope: "mvm", status: "completed", is_base: false, created_at: "2024-01-02T00:00:00Z" },
    { id: "v1", version: 1, scope: "mvm", status: "completed", is_base: true, created_at: "2024-01-01T00:00:00Z" },
  ];
  businessesList = [];
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
  const router = createRouter({
    routeTree: rootRoute.addChildren([sidebarRoute.addChildren([explorerClone])]),
    history: createMemoryHistory({
      initialEntries: [`/businesses/${businessData.id}/explorer`],
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
}

async function openKickstartDialog() {
  const trigger = await screen.findByRole("button", {
    name: /kickstart a business/i,
  });
  await act(async () => {
    fireEvent.click(trigger);
  });
}

warmImports(() => import("@/routes/_sidebar/businesses.$businessId.explorer"));

describe("Explorer page — Kickstart from industry", () => {
  it("shows the Kickstart button only when kind === 'industry'", async () => {
    await renderExplorer();
    expect(
      await screen.findByRole("button", { name: /kickstart a business/i }),
    ).toBeInTheDocument();
  });

  it("hides the Kickstart button for a plain business", async () => {
    businessData = { ...businessData, kind: "business" };
    await renderExplorer();
    // Wait for the header to render (the Delete action is always present).
    await screen.findByRole("button", { name: /delete business/i });
    expect(
      screen.queryByRole("button", { name: /kickstart a business/i }),
    ).toBeNull();
  });

  it("submits whole_model + source_version and navigates on success", async () => {
    kickstartMock.mockResolvedValueOnce({
      data: { business: { id: "new-biz", name: "Acme Retail" } },
    });
    await renderExplorer();
    await openKickstartDialog();

    const dialog = screen.getByRole("dialog");
    fireEvent.change(within(dialog).getByLabelText(/business name/i), {
      target: { value: "Acme Retail" },
    });

    // Pick a source version (Radix Select renders options into a portal).
    await act(async () => {
      fireEvent.click(within(dialog).getByRole("combobox"));
    });
    await act(async () => {
      fireEvent.click(screen.getByRole("option", { name: /v2/ }));
    });

    await act(async () => {
      fireEvent.click(within(dialog).getByRole("button", { name: /^kickstart$/i }));
    });

    await waitFor(() =>
      expect(kickstartMock).toHaveBeenCalledWith({
        params: { industry_business_id: "ind-1" },
        data: {
          new_name: "Acme Retail",
          new_description: undefined,
          source_version: 2,
          whole_model: true,
          copy_inputs: true,
        },
      }),
    );
    await waitFor(() =>
      expect(navigateMock).toHaveBeenCalledWith({
        to: "/businesses/$businessId/explorer",
        params: { businessId: "new-biz" },
      }),
    );
    expect(toast.success).toHaveBeenCalledWith(
      "Kickstart started",
      expect.objectContaining({
        description: expect.stringContaining("Acme Retail"),
      }),
    );
  });

  it("defaults the copy-inputs checkbox ON and sends copy_inputs:false when unchecked", async () => {
    kickstartMock.mockResolvedValueOnce({
      data: { business: { id: "new-biz", name: "Clean Slate" } },
    });
    await renderExplorer();
    await openKickstartDialog();

    const dialog = screen.getByRole("dialog");
    const copyInputs = within(dialog).getByRole("checkbox", {
      name: /bring this industry's inputs and feedback/i,
    });
    // Default ON.
    expect(copyInputs).toBeChecked();

    fireEvent.change(within(dialog).getByLabelText(/business name/i), {
      target: { value: "Clean Slate" },
    });
    await act(async () => {
      fireEvent.click(within(dialog).getByRole("combobox"));
    });
    await act(async () => {
      fireEvent.click(screen.getByRole("option", { name: /v2/ }));
    });
    // Uncheck for a clean slate.
    await act(async () => {
      fireEvent.click(copyInputs);
    });
    await act(async () => {
      fireEvent.click(within(dialog).getByRole("button", { name: /^kickstart$/i }));
    });

    await waitFor(() =>
      expect(kickstartMock).toHaveBeenCalledWith({
        params: { industry_business_id: "ind-1" },
        data: {
          new_name: "Clean Slate",
          new_description: undefined,
          source_version: 2,
          whole_model: true,
          copy_inputs: false,
        },
      }),
    );
  });

  it("shows an inline name error on 409 business_name_taken", async () => {
    kickstartMock.mockRejectedValueOnce(
      new ApiError(409, "Conflict", { detail: { error: "business_name_taken" } }),
    );
    await renderExplorer();
    await openKickstartDialog();

    const dialog = screen.getByRole("dialog");
    fireEvent.change(within(dialog).getByLabelText(/business name/i), {
      target: { value: "Dupe" },
    });
    await act(async () => {
      fireEvent.click(within(dialog).getByRole("combobox"));
    });
    await act(async () => {
      fireEvent.click(screen.getByRole("option", { name: /v2/ }));
    });
    await act(async () => {
      fireEvent.click(within(dialog).getByRole("button", { name: /^kickstart$/i }));
    });

    await waitFor(() =>
      expect(screen.getByText(/already exists/i)).toBeInTheDocument(),
    );
    expect(navigateMock).not.toHaveBeenCalled();
  });

  it("requires a description when the source industry's own description is blank", async () => {
    businessData = { ...businessData, description: "" };
    await renderExplorer();
    await openKickstartDialog();

    const dialog = screen.getByRole("dialog");
    // The (required) marker + helper text appear because the industry has
    // no description to fall back on.
    expect(within(dialog).getByText(/\(required\)/i)).toBeInTheDocument();
    expect(
      within(dialog).getByTestId("kickstart-description-helper"),
    ).toHaveTextContent(/required/i);

    fireEvent.change(within(dialog).getByLabelText(/business name/i), {
      target: { value: "Blank Desc Co" },
    });
    await act(async () => {
      fireEvent.click(within(dialog).getByRole("combobox"));
    });
    await act(async () => {
      fireEvent.click(screen.getByRole("option", { name: /v2/ }));
    });

    // Submit is disabled until a description is entered - no fallback
    // exists for the request to land on.
    const submitButton = within(dialog).getByRole("button", { name: /^kickstart$/i });
    expect(submitButton).toBeDisabled();

    await act(async () => {
      fireEvent.click(submitButton);
    });
    expect(kickstartMock).not.toHaveBeenCalled();

    fireEvent.change(within(dialog).getByTestId("kickstart-description"), {
      target: { value: "A fresh summary." },
    });
    expect(submitButton).not.toBeDisabled();
  });

  it("leaves description optional when the source industry has a description", async () => {
    // businessData.description is "An industry." (non-blank) by default.
    kickstartMock.mockResolvedValueOnce({
      data: { business: { id: "new-biz", name: "Falls Back Co" } },
    });
    await renderExplorer();
    await openKickstartDialog();

    const dialog = screen.getByRole("dialog");
    expect(within(dialog).getByText(/\(optional\)/i)).toBeInTheDocument();
    expect(
      screen.queryByTestId("kickstart-description-helper"),
    ).toBeNull();

    fireEvent.change(within(dialog).getByLabelText(/business name/i), {
      target: { value: "Falls Back Co" },
    });
    await act(async () => {
      fireEvent.click(within(dialog).getByRole("combobox"));
    });
    await act(async () => {
      fireEvent.click(screen.getByRole("option", { name: /v2/ }));
    });

    // Submit is enabled with no description typed - silently falls back to
    // the industry's own description server-side (unchanged behavior).
    const submitButton = within(dialog).getByRole("button", { name: /^kickstart$/i });
    expect(submitButton).not.toBeDisabled();

    await act(async () => {
      fireEvent.click(submitButton);
    });
    await waitFor(() =>
      expect(kickstartMock).toHaveBeenCalledWith({
        params: { industry_business_id: "ind-1" },
        data: {
          new_name: "Falls Back Co",
          new_description: undefined,
          source_version: 2,
          whole_model: true,
          copy_inputs: true,
        },
      }),
    );
  });

  it("auto-retries a transient 502 and navigates once it clears (E-04)", async () => {
    kickstartMock
      .mockRejectedValueOnce(new ApiError(502, "Bad Gateway", ""))
      .mockResolvedValueOnce({
        data: { business: { id: "new-biz", name: "Retry Co" } },
      });
    await renderExplorer();
    await openKickstartDialog();

    const dialog = screen.getByRole("dialog");
    fireEvent.change(within(dialog).getByLabelText(/business name/i), {
      target: { value: "Retry Co" },
    });
    await act(async () => {
      fireEvent.click(within(dialog).getByRole("combobox"));
    });
    await act(async () => {
      fireEvent.click(screen.getByRole("option", { name: /v2/ }));
    });
    await act(async () => {
      fireEvent.click(within(dialog).getByRole("button", { name: /^kickstart$/i }));
    });

    // The first attempt 502'd; the wrapper retries and the second resolves.
    await waitFor(() => expect(kickstartMock).toHaveBeenCalledTimes(2));
    await waitFor(
      () =>
        expect(navigateMock).toHaveBeenCalledWith({
          to: "/businesses/$businessId/explorer",
          params: { businessId: "new-biz" },
        }),
    );
    // Never surfaced the raw gateway status.
    expect(screen.queryByText(/HTTP 502/i)).toBeNull();
  });

  it("shows a friendly message (not raw HTTP 502) when retries are exhausted", async () => {
    kickstartMock.mockRejectedValue(new ApiError(502, "Bad Gateway", ""));
    await renderExplorer();
    await openKickstartDialog();

    const dialog = screen.getByRole("dialog");
    fireEvent.change(within(dialog).getByLabelText(/business name/i), {
      target: { value: "Doomed Co" },
    });
    await act(async () => {
      fireEvent.click(within(dialog).getByRole("combobox"));
    });
    await act(async () => {
      fireEvent.click(screen.getByRole("option", { name: /v2/ }));
    });
    await act(async () => {
      fireEvent.click(within(dialog).getByRole("button", { name: /^kickstart$/i }));
    });

    // 1 initial + 2 retries = 3 attempts, then the friendly copy.
    await waitFor(() => expect(kickstartMock).toHaveBeenCalledTimes(3));
    await waitFor(
      () =>
        expect(
          screen.getByText(/temporarily unavailable/i),
        ).toBeInTheDocument(),
    );
    expect(screen.queryByText(/HTTP 502/i)).toBeNull();
    expect(navigateMock).not.toHaveBeenCalled();
  });

  it("treats a 409 after a transient retry as 'may already exist', not a name clash", async () => {
    kickstartMock
      .mockRejectedValueOnce(new ApiError(502, "Bad Gateway", ""))
      .mockRejectedValueOnce(
        new ApiError(409, "Conflict", { detail: { error: "business_name_taken" } }),
      );
    await renderExplorer();
    await openKickstartDialog();

    const dialog = screen.getByRole("dialog");
    fireEvent.change(within(dialog).getByLabelText(/business name/i), {
      target: { value: "Maybe Made" },
    });
    await act(async () => {
      fireEvent.click(within(dialog).getByRole("combobox"));
    });
    await act(async () => {
      fireEvent.click(screen.getByRole("option", { name: /v2/ }));
    });
    await act(async () => {
      fireEvent.click(within(dialog).getByRole("button", { name: /^kickstart$/i }));
    });

    await waitFor(
      () =>
        expect(
          screen.getByText(/may already have been created/i),
        ).toBeInTheDocument(),
    );
    // Not the plain field-level "already exists" message.
    expect(screen.queryByText(/A business with this name already exists/i)).toBeNull();
    expect(navigateMock).not.toHaveBeenCalled();
  });

  it("renders the provenance line for a kickstarted business", async () => {
    businessData = {
      ...businessData,
      id: "biz-9",
      name: "Acme Retail",
      kind: "business",
      source_industry_id: "ind-1",
      source_version: 3,
    };
    businessesList = [{ id: "ind-1", name: "Retail Industry", kind: "industry" }];
    await renderExplorer();

    const line = await screen.findByText(/kickstarted from/i);
    expect(line).toBeInTheDocument();
    expect(within(line).getByText(/Retail Industry v3/)).toBeInTheDocument();
  });
});
