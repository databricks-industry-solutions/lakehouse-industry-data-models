/**
 * Unfinished `_metamodel` cleanups on the business page (add §6.1, R1):
 * listed with their error and "Retry cleanup" for BusinessAdmins; nothing
 * when every cleanup is done.
 */
import { beforeEach, describe, expect, it, vi } from "vitest";
import { act, fireEvent, render, screen, waitFor } from "@testing-library/react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";

const retryMock = vi.fn();
let rows: unknown[] = [];
let role: string | undefined = "business_admin";
vi.mock("@/lib/api", async () => {
  const actual = await vi.importActual<typeof import("@/lib/api")>("@/lib/api");
  return {
    ...actual,
    useListMetamodelCleanups: () => ({ data: { data: rows } }),
    retryMetamodelCleanup: (...a: unknown[]) => retryMock(...a),
  };
});
vi.mock("@/lib/hooks", async () => {
  const actual = await vi.importActual<typeof import("@/lib/hooks")>("@/lib/hooks");
  return { ...actual, useUserRole: () => role };
});
vi.mock("sonner", () => ({ toast: { success: vi.fn(), error: vi.fn() } }));
vi.mock("@/lib/notify", () => ({ notifyError: vi.fn() }));

import { toast } from "sonner";
import { MetamodelCleanupsPanel } from "@/components/versions/metamodel-cleanups-panel";

const failed = {
  id: "c1", business_segment: "acme", version: 5, scope: "ecm", catalog: "cat_x",
  reason: "version_delete", status: "failed", attempts: 3, last_error: "warehouse stopped", updated_at: "2026-10-20T00:00:00Z",
};

function renderPanel() {
  return render(
    <QueryClientProvider client={new QueryClient()}>
      <MetamodelCleanupsPanel businessId="b1" />
    </QueryClientProvider>,
  );
}

beforeEach(() => {
  rows = [];
  role = "business_admin";
  retryMock.mockReset();
});

describe("MetamodelCleanupsPanel", () => {
  it("renders nothing when every cleanup is done", () => {
    renderPanel();
    expect(screen.queryByTestId("metamodel-cleanups")).toBeNull();
  });

  it("lists a failed cleanup and retries it", async () => {
    rows = [failed];
    retryMock.mockResolvedValue({ data: { ...failed, status: "done" } });
    renderPanel();
    expect(screen.getByTestId("metamodel-cleanup-row")).toHaveTextContent(
      "Cleanup of deleted v5 ECM is failing in cat_x.",
    );
    expect(screen.getByTestId("metamodel-cleanup-row")).toHaveTextContent("warehouse stopped");
    await act(async () => {
      fireEvent.click(screen.getByRole("button", { name: "Retry cleanup" }));
    });
    await waitFor(() => expect(retryMock).toHaveBeenCalledWith({ business_id: "b1", cleanup_id: "c1" }));
    expect(toast.success).toHaveBeenCalledWith("Cleanup of deleted v5 ECM in cat_x finished.");
  });

  it.each(["modeler", undefined])("hides Retry for role %s", (r) => {
    rows = [failed];
    role = r;
    renderPanel();
    expect(screen.queryByRole("button", { name: "Retry cleanup" })).toBeNull();
  });
});
