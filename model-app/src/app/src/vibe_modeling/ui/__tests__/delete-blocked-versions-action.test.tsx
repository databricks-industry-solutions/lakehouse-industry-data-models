/**
 * The B10 blocker's "Delete v4 and v5" action opens the permanent-delete
 * dialog for exactly the versions the blocker names.
 */
import { describe, expect, it, vi } from "vitest";
import { act, fireEvent, render, screen, waitFor } from "@testing-library/react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { DeleteBlockedVersionsAction } from "@/components/versions/delete-blocked-versions-action";
import { makeModelVersion } from "./helpers/model-version";

vi.mock("sonner", () => ({ toast: { success: vi.fn() } }));

const versions = [
  makeModelVersion({ id: "mv-3", version: 3, scope: "ecm" }),
  makeModelVersion({ id: "mv-4", version: 4, scope: "ecm", status: "draft", dry_run: true, draft_state: "ready", is_head: false }),
  makeModelVersion({ id: "mv-5", version: 5, scope: "ecm", status: "superseded", replaced_at: "2026-10-21T00:00:00Z", is_head: false }),
];
const deleteMock = vi.fn();
vi.mock("@/lib/api", async () => {
  const actual = await vi.importActual<typeof import("@/lib/api")>("@/lib/api");
  return { ...actual, deleteVersion: (...a: unknown[]) => deleteMock(...a) };
});

function renderAction(named: number[] = [4, 5], onDeleted?: () => void) {
  return render(
    <QueryClientProvider client={new QueryClient()}>
      <DeleteBlockedVersionsAction businessId="b1" businessName="Acme" named={named} versions={versions} scope="ecm" onDeleted={onDeleted} />
    </QueryClientProvider>,
  );
}

describe("DeleteBlockedVersionsAction", () => {
  it("opens the delete dialog for the named versions", () => {
    renderAction();
    fireEvent.click(screen.getByTestId("delete-blocking-versions"));
    expect(screen.getByTestId("delete-blocking-versions")).toHaveTextContent("Delete v4 and v5");
    expect(screen.getByRole("alertdialog", { name: "Delete v4 and v5 ECM of Acme?" })).toBeInTheDocument();
    expect(screen.getByTestId("delete-permanent-copy")).toHaveTextContent(
      "Deleting v4 and v5 is permanent. The agent reuses the numbers v4 and v5 for the next runs and clears those folders.",
    );
  });

  it("renders nothing when the blocker names no versions", () => {
    renderAction([]);
    expect(screen.queryByTestId("delete-blocking-versions")).toBeNull();
  });

  it("asks the form to validate again once both are deleted", async () => {
    deleteMock.mockResolvedValue({ data: { deleted_version: 5, message: "ok" } });
    const onDeleted = vi.fn();
    renderAction([4, 5], onDeleted);
    fireEvent.click(screen.getByTestId("delete-blocking-versions"));
    await act(async () => {
      fireEvent.click(screen.getByRole("button", { name: /^Delete$/ }));
    });
    await waitFor(() => expect(onDeleted).toHaveBeenCalledTimes(1));
    expect(deleteMock.mock.calls.map((c) => (c[0] as { version_id: string }).version_id)).toEqual(["mv-5", "mv-4"]);
  });
});
