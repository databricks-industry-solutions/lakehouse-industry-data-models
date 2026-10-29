/**
 * Tests for the `DeleteVersionButton` on the model-version page.
 *
 * Covers the add §6.1 rules: the label per state (head, Dry Run draft,
 * replaced), Delete disabled with the reason for an installed version (with
 * Uninstall) and for a superseded version in the middle, the permanent-delete
 * copy, no reinstall option, the request, an inline refusal, and success.
 */
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";
import { fireEvent, render, screen, waitFor } from "@testing-library/react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { ApiError, BusinessKind, listMetamodelCleanupsKey, listVersionsKey } from "@/lib/api";
import { DeleteVersionsDialog } from "@/components/versions/delete-versions-dialog";

const navigateMock = vi.fn();
const deleteVersionMock = vi.fn();
const toastSuccessMock = vi.fn();
const toastErrorMock = vi.fn();
const toastWarningMock = vi.fn();

vi.mock("@/lib/api", async () => {
  const actual = await vi.importActual<typeof import("@/lib/api")>("@/lib/api");
  return {
    ...actual,
    deleteVersion: (...args: unknown[]) => deleteVersionMock(...args),
  };
});

vi.mock("@tanstack/react-router", async () => {
  const actual = await vi.importActual<typeof import("@tanstack/react-router")>(
    "@tanstack/react-router",
  );
  return {
    ...actual,
    useNavigate: () => navigateMock,
    Link: ({ children, ...props }: any) => <a {...props}>{children}</a>,
  };
});

vi.mock("sonner", () => ({
  toast: {
    success: (...args: unknown[]) => toastSuccessMock(...args),
    error: (...args: unknown[]) => toastErrorMock(...args),
    warning: (...args: unknown[]) => toastWarningMock(...args),
  },
}));

const notifyErrorMock = vi.fn();
vi.mock("@/lib/notify", () => ({
  notifyError: (...args: unknown[]) => notifyErrorMock(...args),
}));

vi.mock("@/components/runs/version-operation-dialog", () => ({
  VersionOperationDialog: ({ open, intent }: { open: boolean; intent: string }) =>
    open ? <div data-testid={`stub-${intent}-dialog`} /> : null,
}));

import { makeModelVersion } from "./helpers/model-version";
import { DeleteVersionButton } from "@/routes/_sidebar/businesses.$businessId.model.$version.$scope.index";
import { useToolbarNoteSlot } from "@/components/model/toolbar-note-slot";

function makeClient() {
  return new QueryClient({
    defaultOptions: {
      queries: { retry: false, staleTime: 30_000 },
      mutations: { retry: false },
    },
  });
}

function renderButton(
  overrides: Partial<React.ComponentProps<typeof DeleteVersionButton>> = {},
  client: QueryClient = makeClient(),
) {
  const props: React.ComponentProps<typeof DeleteVersionButton> = {
    businessId: "biz-1",
    businessName: "Test Biz",
    version: "2",
    scope: "ecm",
    versions: [
      makeModelVersion({ id: "v-2", version: 2, scope: "ecm", status: "completed" }),
      makeModelVersion({ id: "v-1", version: 1, scope: "ecm", status: "superseded", is_head: false }),
    ],
    currentVersionId: "v-2",
    ...overrides,
  };
  return render(
    <QueryClientProvider client={client}>
      <DeleteVersionButton {...props} />
    </QueryClientProvider>,
  );
}

beforeEach(() => {
  navigateMock.mockReset();
  deleteVersionMock.mockReset();
  toastSuccessMock.mockReset();
  toastErrorMock.mockReset();
  toastWarningMock.mockReset();
  notifyErrorMock.mockReset();
});

afterEach(() => {
  vi.clearAllMocks();
});

describe("DeleteVersionButton", () => {
  it("offers 'Delete this version' on the head", () => {
    renderButton();
    expect(screen.getByRole("button", { name: /Delete this version/i })).not.toBeDisabled();
  });

  it("disables Delete on a superseded version in the middle, naming the newer ones", () => {
    renderButton({ version: "1", currentVersionId: "v-1" });
    expect(screen.getByRole("button", { name: /Delete this version/i })).toBeDisabled();
    expect(screen.getByTestId("delete-version-reason")).toHaveTextContent(
      "Delete the newer versions first (v2).",
    );
  });

  it("puts the reason on the line under the tab bar, at no fixed width, so it never widens the tab bar", () => {
    function Page() {
      const note = useToolbarNoteSlot();
      return note.provide(
        <div>
          <div data-testid="tab-bar">
            <DeleteVersionButton
              businessId="biz-1"
              businessName="Test Biz"
              version="1"
              scope="ecm"
              versions={[
                makeModelVersion({ id: "v-2", version: 2, scope: "ecm", status: "completed" }),
                makeModelVersion({ id: "v-1", version: 1, scope: "ecm", status: "superseded", is_head: false }),
              ]}
              currentVersionId="v-1"
            />
          </div>
          {note.slot}
        </div>,
      );
    }
    render(
      <QueryClientProvider client={makeClient()}>
        <Page />
      </QueryClientProvider>,
    );
    const reason = screen.getByTestId("delete-version-reason");
    expect(screen.getByTestId("toolbar-note-slot")).toContainElement(reason);
    expect(screen.getByTestId("tab-bar")).not.toContainElement(reason);
    expect(reason.className.split(/\s+/).filter((c) => /^(min-)?w-/.test(c))).toEqual([]);
    expect(screen.getByRole("button", { name: /Delete this version/i })).toHaveAttribute(
      "aria-describedby",
      "delete-version-reason",
    );
  });

  it("labels a Dry Run draft and a replaced version", () => {
    const { unmount } = renderButton({
      versions: [makeModelVersion({ id: "v-2", version: 2, scope: "ecm", status: "draft", dry_run: true, draft_state: "ready", is_head: false })],
    });
    expect(screen.getByRole("button", { name: "Delete draft" })).not.toBeDisabled();
    unmount();
    renderButton({
      versions: [makeModelVersion({ id: "v-2", version: 2, scope: "ecm", status: "superseded", replaced_at: "2026-10-21T10:00:00Z", is_head: false })],
    });
    expect(screen.getByRole("button", { name: "Delete replaced version" })).not.toBeDisabled();
  });

  it("disables Delete on an installed version and links to Uninstall", async () => {
    renderButton({
      versions: [makeModelVersion({ id: "v-2", version: 2, scope: "ecm", deployment_status: "deployed", uc_catalog: "cat_x" })],
    });
    expect(screen.getByRole("button", { name: /Delete this version/i })).toBeDisabled();
    expect(screen.getByTestId("delete-version-reason")).toHaveTextContent(
      "v2 ECM is installed in cat_x. Uninstall it first, then delete it.",
    );
    fireEvent.click(screen.getByRole("button", { name: "Uninstall" }));
    expect(await screen.findByTestId("stub-uninstall-dialog")).toBeInTheDocument();
  });

  it("says the delete is permanent and offers no reinstall option", async () => {
    renderButton();
    fireEvent.click(screen.getByRole("button", { name: /Delete this version/i }));
    await waitFor(() => {
      expect(screen.getByRole("alertdialog", { name: /Delete v2 ECM of Test Biz/i })).toBeInTheDocument();
    });
    expect(screen.getByTestId("delete-permanent-copy")).toHaveTextContent(
      "Deleting v2 is permanent. The agent reuses the number v2 for the next run and clears that folder.",
    );
    expect(screen.queryByRole("checkbox")).toBeNull();
    expect(screen.queryByText(/Re-install/i)).toBeNull();
  });

  it("submits the business and version only", async () => {
    deleteVersionMock.mockResolvedValue({ data: { deleted_version: 2, message: "ok" } });
    renderButton();
    fireEvent.click(screen.getByRole("button", { name: /Delete this version/i }));
    fireEvent.click(await screen.findByRole("button", { name: /^Delete$/i }));
    await waitFor(() => expect(deleteVersionMock).toHaveBeenCalledTimes(1));
    expect(deleteVersionMock).toHaveBeenCalledWith({ business_id: "biz-1", version_id: "v-2" });
  });

  it("shows a refusal inline and keeps the dialog open", async () => {
    deleteVersionMock.mockRejectedValue(new Error("boom"));
    renderButton();
    fireEvent.click(screen.getByRole("button", { name: /Delete this version/i }));
    fireEvent.click(await screen.findByRole("button", { name: /^Delete$/i }));
    expect(await screen.findByTestId("delete-versions-error")).toHaveTextContent("boom");
    expect(screen.getByRole("alertdialog")).toBeInTheDocument();
    expect(navigateMock).not.toHaveBeenCalled();
  });

  it("copy says the agent's registry rows go too, and what happens when that fails", async () => {
    renderButton();
    fireEvent.click(screen.getByRole("button", { name: /Delete this version/i }));
    const dialog = await screen.findByTestId("delete-versions-dialog");
    expect(dialog).toHaveTextContent("the agent's _metamodel.* rows");
    expect(dialog).toHaveTextContent("If removing those rows fails, the app retries at the next start-ups");
    expect(dialog).toHaveTextContent("the business's Explorer page offers Retry cleanup");
    expect(dialog).toHaveTextContent(
      "The model files the app copied into its own Volume folders at download, kickstart or import (from 0.9.0) are deleted.",
    );
  });

  it("names an industry as an industry in the copy and the warning", async () => {
    deleteVersionMock.mockResolvedValue({
      data: { deleted_version: 2, message: "ok", metamodel_cleanup: { done: 0, pending: 1, failed: 0 } },
    });
    render(
      <QueryClientProvider client={makeClient()}>
        <DeleteVersionsDialog
          open
          onOpenChange={() => {}}
          businessId="ind-1"
          businessName="Retail"
          businessKind={BusinessKind.industry}
          targets={[{ id: "v-2", version: 2, scope: "ecm" }]}
        />
      </QueryClientProvider>,
    );
    expect(await screen.findByTestId("delete-versions-dialog")).toHaveTextContent(
      "the industry's Explorer page offers Retry cleanup",
    );
    fireEvent.click(screen.getByRole("button", { name: /^Delete$/i }));
    await waitFor(() => expect(toastWarningMock).toHaveBeenCalledTimes(1));
    expect(toastWarningMock.mock.calls[0][1].description).toMatch(
      /Retry cleanup on the industry's Explorer page runs the retry now\.$/,
    );
  });

  it("refreshes the cleanup list the warning points to", async () => {
    deleteVersionMock.mockResolvedValue({
      data: { deleted_version: 2, message: "ok", metamodel_cleanup: { done: 0, pending: 0, failed: 1 } },
    });
    const client = makeClient();
    const invalidateSpy = vi.spyOn(client, "invalidateQueries");
    renderButton({}, client);
    fireEvent.click(screen.getByRole("button", { name: /Delete this version/i }));
    fireEvent.click(await screen.findByRole("button", { name: /^Delete$/i }));
    await waitFor(() => expect(toastWarningMock).toHaveBeenCalled());
    expect(invalidateSpy).toHaveBeenCalledWith({ queryKey: listMetamodelCleanupsKey({ business_id: "biz-1" }) });
  });

  it("warns when the registry cleanup did not finish, instead of a plain success", async () => {
    deleteVersionMock.mockResolvedValue({
      data: {
        deleted_version: 2,
        message: "Deleted version 2",
        metamodel_cleanup: { done: 0, pending: 0, failed: 2 },
      },
    });
    renderButton();
    fireEvent.click(screen.getByRole("button", { name: /Delete this version/i }));
    fireEvent.click(await screen.findByRole("button", { name: /^Delete$/i }));
    await waitFor(() => expect(toastWarningMock).toHaveBeenCalledTimes(1));
    expect(toastWarningMock).toHaveBeenCalledWith("v2 deleted.", expect.objectContaining({
      description:
        "2 registry cleanups did not finish, so the agent's registry rows are still there. " +
        "The app retries at the next start-ups. " +
        "Retry cleanup on the business's Explorer page runs the retry now.",
    }));
    expect(toastSuccessMock).not.toHaveBeenCalled();
    expect(navigateMock).toHaveBeenCalled();
  });

  it("adds up the unfinished cleanups of several deleted versions into one warning", async () => {
    deleteVersionMock
      .mockResolvedValueOnce({ data: { deleted_version: 2, message: "ok", metamodel_cleanup: { done: 1, pending: 1, failed: 0 } } })
      .mockResolvedValueOnce({ data: { deleted_version: 1, message: "ok", metamodel_cleanup: { done: 0, pending: 0, failed: 1 } } });
    render(
      <QueryClientProvider client={makeClient()}>
        <DeleteVersionsDialog
          open
          onOpenChange={() => {}}
          businessId="biz-1"
          businessName="Test Biz"
          targets={[
            { id: "v-2", version: 2, scope: "ecm" },
            { id: "v-1", version: 1, scope: "ecm" },
          ]}
        />
      </QueryClientProvider>,
    );
    fireEvent.click(await screen.findByRole("button", { name: /^Delete$/i }));
    await waitFor(() => expect(toastWarningMock).toHaveBeenCalledTimes(1));
    expect(toastWarningMock.mock.calls[0][0]).toBe("v1 and v2 deleted.");
    expect(toastWarningMock.mock.calls[0][1].description).toMatch(/^2 registry cleanups did not finish/);
  });

  it("a proxy 504 says the delete may still be finishing and refreshes the version lists", async () => {
    deleteVersionMock.mockRejectedValue(new ApiError(504, "Gateway Timeout", null));
    const client = makeClient();
    const invalidateSpy = vi.spyOn(client, "invalidateQueries");
    renderButton({}, client);
    fireEvent.click(screen.getByRole("button", { name: /Delete this version/i }));
    fireEvent.click(await screen.findByRole("button", { name: /^Delete$/i }));
    expect(await screen.findByTestId("delete-versions-error")).toHaveTextContent(
      "The delete may still be finishing; refresh to check.",
    );
    await waitFor(() => expect(invalidateSpy).toHaveBeenCalled());
    expect(invalidateSpy).toHaveBeenCalledWith({ queryKey: listVersionsKey({ business_id: "biz-1" }) });
    expect(screen.getByRole("alertdialog")).toBeInTheDocument();
    expect(toastSuccessMock).not.toHaveBeenCalled();
  });

  it("an app 409 still shows its own message, not the answer-lost notice", async () => {
    deleteVersionMock.mockRejectedValue(new ApiError(409, "Conflict", { detail: "v2 is installed." }));
    renderButton();
    fireEvent.click(screen.getByRole("button", { name: /Delete this version/i }));
    fireEvent.click(await screen.findByRole("button", { name: /^Delete$/i }));
    expect(await screen.findByTestId("delete-versions-error")).toHaveTextContent("v2 is installed.");
  });

  it("on success: toast with the reopened feedback, then the explorer", async () => {
    deleteVersionMock.mockResolvedValue({
      data: { deleted_version: 2, message: "Deleted version 2", reopened_input_count: 3 },
    });
    renderButton();
    fireEvent.click(screen.getByRole("button", { name: /Delete this version/i }));
    fireEvent.click(await screen.findByRole("button", { name: /^Delete$/i }));
    await waitFor(() => {
      expect(toastSuccessMock).toHaveBeenCalledWith(
        "v2 deleted. 3 feedback items applied in v2 are open again.",
      );
    });
    expect(navigateMock).toHaveBeenCalledWith({
      to: "/businesses/$businessId/explorer",
      params: { businessId: "biz-1" },
    });
  });
});
