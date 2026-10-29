/**
 * `BusinessTable` delete-flow coverage.
 *
 * The Delete-business dialog is a SINGLE adaptive `<AlertDialog>`. Both
 * branches DELETE with `cascade=true` (the backend refuses a bare delete of a
 * business that has runs but no versions, and the model count says nothing
 * about runs):
 *   - `model_count === 0` → says attached runs go too + "Delete" action.
 *   - `model_count > 0` → cascade-warning panel quantifying the impact
 *     + "Delete everything" action.
 *
 * Scenarios:
 *   1. Empty business (`model_count=0`) → confirm that names runs, deleteBiz
 *      with `cascade=true`.
 *   2. Populated business (`model_count=3`) → cascade warning visible
 *      with quantified count, deleteBiz with `cascade=true`.
 *   3. Singular pluralization (`model_count=1`) → "1 model version" (no
 *      trailing "s").
 *   4. Failure path → `toast.error` surfaces the error message.
 *   5. Success path → `toast.success` naming the business + the lists invalidated.
 */
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";
import { fireEvent, screen, waitFor } from "@testing-library/react";
import { QueryClient } from "@tanstack/react-query";
import { ApiError } from "@/lib/api";

let businessesData: any[] = [];

const deleteBizMock = vi.fn().mockResolvedValue({ data: {} });

vi.mock("@/lib/api", async () => {
  const actual = await vi.importActual<typeof import("@/lib/api")>("@/lib/api");
  return {
    ...actual,
    useListBusinessesSuspense: () => ({ data: businessesData }),
    useListSectorsSuspense: () => ({ data: [] }),
    // useDeleteBusiness in api.ts closes over the module-local `deleteBusiness`
    // function, so re-exporting a mocked `deleteBusiness` would NOT intercept
    // the mutation. Instead we mock the hook itself, returning a mutateAsync
    // that calls our spy. This is the seam the component touches.
    useDeleteBusiness: () => ({
      mutateAsync: (vars: { params: { business_id: string; cascade?: boolean } }) =>
        deleteBizMock(vars.params),
    }),
  };
});

vi.mock("@/lib/selector", () => ({
  selector: () => ({}),
  default: () => ({}),
}));

vi.mock("sonner", () => ({
  toast: { error: vi.fn(), success: vi.fn(), warning: vi.fn() },
}));

vi.mock("@/lib/notify", () => ({
  notifyError: vi.fn(),
}));

import { BusinessTable } from "@/routes/_sidebar/businesses.index";
import { toast } from "sonner";
import { notifyError } from "@/lib/notify";
import { renderWithRouter } from "./helpers/router-wrapper";

function makeBusiness(overrides: Partial<{ id: string; name: string; model_count: number }>) {
  return {
    id: "biz-1",
    name: "Acme",
    industry_alignment: null,
    model_count: 0,
    created_at: "2026-04-20T00:00:00Z",
    ...overrides,
  };
}

let qc: QueryClient;

async function renderTable() {
  qc = new QueryClient({
    defaultOptions: {
      queries: { retry: false, staleTime: 30_000 },
      mutations: { retry: false },
    },
  });
  const result = renderWithRouter(<BusinessTable />, { queryClient: qc });
  // Wait for the router to settle and the table to render the trash button.
  await waitFor(() => {
    expect(screen.getByTitle("Delete business")).toBeInTheDocument();
  });
  return result;
}

beforeEach(() => {
  businessesData = [];
  deleteBizMock.mockReset();
  deleteBizMock.mockResolvedValue({ data: {} });
  vi.mocked(toast.error).mockReset();
  vi.mocked(toast.success).mockReset();
  vi.mocked(notifyError).mockReset();
});

afterEach(() => {
  vi.clearAllMocks();
});

describe("DeleteBusinessButton — unified adaptive dialog", () => {
  it("tells the user runs go too when model_count=0 and deletes with cascade", async () => {
    businessesData = [makeBusiness({ model_count: 0 })];
    await renderTable();

    fireEvent.click(screen.getByTitle("Delete business"));

    await waitFor(() => {
      expect(screen.getByText(/Delete "Acme"\?/i)).toBeInTheDocument();
    });
    // No version-count panel, but the runs that the cascade removes are named.
    expect(screen.queryByText(/permanently delete/i)).not.toBeInTheDocument();
    expect(screen.getByText(/Any runs, feedback, artifacts/i)).toBeInTheDocument();
    expect(screen.getByText(/This cannot be undone/i)).toBeInTheDocument();

    // Action button text is "Delete" (not "Delete everything").
    const action = screen.getByRole("button", { name: /^Delete$/ });
    fireEvent.click(action);

    await waitFor(() => {
      expect(deleteBizMock).toHaveBeenCalledTimes(1);
    });
    const args = deleteBizMock.mock.calls[0][0];
    expect(args.business_id).toBe("biz-1");
    expect(args.cascade).toBe(true);
  });

  it("shows the quantified warning when model_count>0 and deletes with cascade", async () => {
    businessesData = [makeBusiness({ model_count: 3 })];
    await renderTable();

    fireEvent.click(screen.getByTitle("Delete business"));

    await waitFor(() => {
      expect(screen.getByText(/Delete "Acme"\?/i)).toBeInTheDocument();
    });
    // Warning panel mentions the quantified count + plural noun.
    expect(screen.getByText(/3 model versions/i)).toBeInTheDocument();
    expect(
      screen.getByText(/runs, feedback, artifacts/i),
    ).toBeInTheDocument();
    expect(
      screen.getByText(/The model files the app copied into its own Volume folders at download, kickstart or import \(from 0\.9\.0\) are deleted\. Older copies/),
    ).toBeInTheDocument();

    fireEvent.click(screen.getByRole("button", { name: /Delete everything/i }));

    await waitFor(() => {
      expect(deleteBizMock).toHaveBeenCalledTimes(1);
    });
    const args = deleteBizMock.mock.calls[0][0];
    expect(args.business_id).toBe("biz-1");
    expect(args.cascade).toBe(true);
  });

  it("uses singular 'model version' when model_count=1", async () => {
    businessesData = [makeBusiness({ model_count: 1 })];
    await renderTable();

    fireEvent.click(screen.getByTitle("Delete business"));

    await waitFor(() => {
      // "1 model version" (singular). Use a regex that disallows a
      // trailing "s" to lock the pluralization branch.
      expect(screen.getByText(/1 model version(?!s)/)).toBeInTheDocument();
    });
  });

  it("surfaces toast.error and does not invalidate on failure", async () => {
    businessesData = [makeBusiness({ model_count: 0 })];
    deleteBizMock.mockRejectedValueOnce(
      new Error("HTTP 500: boom"),
    );
    await renderTable();
    const invalidateSpy = vi.spyOn(qc, "invalidateQueries");

    fireEvent.click(screen.getByTitle("Delete business"));
    await waitFor(() => {
      expect(screen.getByText(/Delete "Acme"\?/i)).toBeInTheDocument();
    });
    fireEvent.click(screen.getByRole("button", { name: /^Delete$/ }));

    await waitFor(() => {
      expect(vi.mocked(notifyError)).toHaveBeenCalledWith(
        expect.objectContaining({ message: expect.stringContaining("HTTP 500: boom") }),
        { title: "Delete failed" },
      );
    });
    expect(vi.mocked(toast.success)).not.toHaveBeenCalled();
    expect(invalidateSpy).not.toHaveBeenCalled();
  });

  it("a proxy 504 says the delete may still be finishing and refreshes the lists", async () => {
    businessesData = [makeBusiness({ model_count: 0 })];
    deleteBizMock.mockRejectedValueOnce(new ApiError(504, "Gateway Timeout", null));
    await renderTable();
    const invalidateSpy = vi.spyOn(qc, "invalidateQueries");

    fireEvent.click(screen.getByTitle("Delete business"));
    await waitFor(() => {
      expect(screen.getByText(/Delete "Acme"\?/i)).toBeInTheDocument();
    });
    fireEvent.click(screen.getByRole("button", { name: /^Delete$/ }));

    await waitFor(() => {
      expect(vi.mocked(toast.warning)).toHaveBeenCalledWith("The delete may still be finishing; refresh to check.");
    });
    expect(vi.mocked(notifyError)).not.toHaveBeenCalled();
    expect(invalidateSpy).toHaveBeenCalledWith({ predicate: expect.any(Function) });
  });

  it("invalidates the business lists and shows success toast on success", async () => {
    businessesData = [makeBusiness({ model_count: 2 })];
    await renderTable();
    const invalidateSpy = vi.spyOn(qc, "invalidateQueries");

    fireEvent.click(screen.getByTitle("Delete business"));
    await waitFor(() => {
      expect(screen.getByText(/2 model versions/i)).toBeInTheDocument();
    });
    fireEvent.click(screen.getByRole("button", { name: /Delete everything/i }));

    await waitFor(() => {
      expect(vi.mocked(toast.success)).toHaveBeenCalledWith('Deleted "Acme"');
    });
    // Delete now goes through `invalidateBusinessLists`, which invalidates ALL
    // `/api/businesses` list queries via a queryKey-prefix predicate so the
    // kind-filtered Industries list refreshes too.
    expect(invalidateSpy).toHaveBeenCalledWith({
      predicate: expect.any(Function),
    });
    expect(vi.mocked(toast.error)).not.toHaveBeenCalled();
  });
});

describe("DeleteBusinessButton - runs without versions", () => {
  it("cascades for a row with model_count=0 so a business that only has runs is deleted", async () => {
    businessesData = [makeBusiness({ id: "biz-runs-only", name: "Runs Only", model_count: 0 })];
    await renderTable();

    fireEvent.click(screen.getByTitle("Delete business"));
    await waitFor(() => {
      expect(screen.getByText(/Delete "Runs Only"\?/i)).toBeInTheDocument();
    });
    fireEvent.click(screen.getByRole("button", { name: /^Delete$/ }));

    await waitFor(() => {
      expect(deleteBizMock).toHaveBeenCalledWith({ business_id: "biz-runs-only", cascade: true });
    });
    await waitFor(() => {
      expect(vi.mocked(toast.success)).toHaveBeenCalledWith('Deleted "Runs Only"');
    });
  });

  it("warns that a delete left registry cleanups unfinished and still names the business", async () => {
    deleteBizMock.mockResolvedValue({ data: { ok: true, metamodel_cleanup: { done: 0, pending: 0, failed: 2 } } });
    businessesData = [makeBusiness({ model_count: 1 })];
    await renderTable();

    fireEvent.click(screen.getByTitle("Delete business"));
    await waitFor(() => {
      expect(screen.getByText(/1 model version(?!s)/)).toBeInTheDocument();
    });
    fireEvent.click(screen.getByRole("button", { name: /Delete everything/i }));

    await waitFor(() => {
      expect(vi.mocked(toast.warning)).toHaveBeenCalledWith(
        'Deleted "Acme"',
        expect.objectContaining({ description: expect.stringContaining("2 registry cleanups") }),
      );
    });
  });
});
