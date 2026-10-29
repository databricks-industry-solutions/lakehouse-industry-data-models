/**
 * `IndustryTable` delete-flow coverage. The Industries list deletes with
 * `cascade=true` for every row (the backend refuses a bare delete of an
 * industry that has runs but no versions) and the success toast names the
 * industry, like the Explorer's.
 */
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";
import { fireEvent, screen, waitFor } from "@testing-library/react";
import { QueryClient } from "@tanstack/react-query";

let industriesData: any[] = [];

const deleteBizMock = vi.fn().mockResolvedValue({ data: {} });

vi.mock("@/lib/api", async () => {
  const actual = await vi.importActual<typeof import("@/lib/api")>("@/lib/api");
  return {
    ...actual,
    useListBusinessesSuspense: () => ({ data: industriesData }),
    useListSectorsSuspense: () => ({ data: [] }),
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

import { IndustryTable } from "@/routes/_sidebar/industries.index";
import { toast } from "sonner";
import { renderWithRouter } from "./helpers/router-wrapper";

function makeIndustry(overrides: Partial<{ id: string; name: string; model_count: number }>) {
  return {
    id: "ind-1",
    name: "Retail",
    model_count: 0,
    created_at: "2026-04-20T00:00:00Z",
    ...overrides,
  };
}

async function renderTable() {
  const qc = new QueryClient({
    defaultOptions: { queries: { retry: false }, mutations: { retry: false } },
  });
  renderWithRouter(<IndustryTable />, { queryClient: qc });
  await waitFor(() => {
    expect(screen.getByTitle("Delete industry")).toBeInTheDocument();
  });
}

beforeEach(() => {
  industriesData = [];
  deleteBizMock.mockReset();
  deleteBizMock.mockResolvedValue({ data: {} });
  vi.mocked(toast.success).mockReset();
  vi.mocked(toast.warning).mockReset();
});

afterEach(() => {
  vi.clearAllMocks();
});

describe("IndustryTable delete", () => {
  it("cascades for a row with no versions, says runs go too, and the toast names the industry", async () => {
    industriesData = [makeIndustry({ model_count: 0 })];
    await renderTable();

    fireEvent.click(screen.getByTitle("Delete industry"));
    await waitFor(() => {
      expect(screen.getByText(/Delete "Retail"\?/i)).toBeInTheDocument();
    });
    expect(screen.getByText(/Any runs, feedback, artifacts/i)).toBeInTheDocument();
    fireEvent.click(screen.getByRole("button", { name: /^Delete$/ }));

    await waitFor(() => {
      expect(deleteBizMock).toHaveBeenCalledWith({ business_id: "ind-1", cascade: true });
    });
    await waitFor(() => {
      expect(vi.mocked(toast.success)).toHaveBeenCalledWith('Deleted "Retail"');
    });
  });

  it("cascades for a row with versions and quantifies them", async () => {
    industriesData = [makeIndustry({ model_count: 3 })];
    await renderTable();

    fireEvent.click(screen.getByTitle("Delete industry"));
    await waitFor(() => {
      expect(screen.getByText(/3 model versions/i)).toBeInTheDocument();
    });
    expect(
      screen.getByText(/The model files the app copied into its own Volume folders at download, kickstart or import \(from 0\.9\.0\) are deleted\. Older copies/),
    ).toBeInTheDocument();
    fireEvent.click(screen.getByRole("button", { name: /Delete everything/i }));

    await waitFor(() => {
      expect(deleteBizMock).toHaveBeenCalledWith({ business_id: "ind-1", cascade: true });
    });
    await waitFor(() => {
      expect(vi.mocked(toast.success)).toHaveBeenCalledWith('Deleted "Retail"');
    });
  });

  it("keeps the name in the warning when registry cleanups are unfinished", async () => {
    deleteBizMock.mockResolvedValue({ data: { ok: true, metamodel_cleanup: { done: 0, pending: 1, failed: 0 } } });
    industriesData = [makeIndustry({ model_count: 1 })];
    await renderTable();

    fireEvent.click(screen.getByTitle("Delete industry"));
    await waitFor(() => {
      expect(screen.getByText(/1 model version(?!s)/)).toBeInTheDocument();
    });
    fireEvent.click(screen.getByRole("button", { name: /Delete everything/i }));

    await waitFor(() => {
      expect(vi.mocked(toast.warning)).toHaveBeenCalledWith(
        'Deleted "Retail"',
        expect.objectContaining({ description: expect.stringContaining("1 registry cleanup ") }),
      );
    });
  });
});
