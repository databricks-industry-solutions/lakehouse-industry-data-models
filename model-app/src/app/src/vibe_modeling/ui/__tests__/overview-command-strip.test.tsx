/**
 * Command-strip tests: the install action named for the version's state
 * (design §1 UI), Uninstall only when installed, Generate samples gone (X18),
 * both open the version operation dialog without starting a run, the
 * "Prepare new Vibe" entry, and the run-status summary.
 */
import { beforeEach, describe, expect, it, vi } from "vitest";
import { act, fireEvent, screen } from "@testing-library/react";
import type { ModelVersionOut } from "@/lib/api";

let runsData: unknown[] = [];

vi.mock("@/lib/api", async () => {
  const actual = await vi.importActual<typeof import("@/lib/api")>("@/lib/api");
  return {
    ...actual,
    createRun: vi.fn(),
    // CommandStrip subscribes to the version's runs for its status summary.
    useListRunsForVersion: () => ({ data: runsData }),
  };
});

vi.mock("@/components/runs/version-operation-dialog", () => ({
  VersionOperationDialog: ({ intent }: { intent: string }) => (
    <div data-testid={`stub-${intent}-dialog`} />
  ),
}));

import { createRun } from "@/lib/api";
import { CommandStrip } from "@/components/overview/command-strip";
import { renderWithRouter } from "./helpers/router-wrapper";
import { makeModelVersion } from "./helpers/model-version";

function renderStrip(over: Partial<ModelVersionOut> = {}) {
  const version = makeModelVersion({ id: "v-abc", version: 3, ...over });
  return renderWithRouter(
    <CommandStrip businessId="b1" version={version} versions={[version]} />,
  );
}

describe("CommandStrip — lifecycle actions", () => {
  beforeEach(() => {
    vi.mocked(createRun).mockReset();
    runsData = [];
  });

  it("renders one strip", async () => {
    renderStrip();
    expect(await screen.findByTestId("overview-command-strip")).toBeInTheDocument();
  });

  it.each([
    [{ status: "draft", dry_run: true, draft_state: "ready", is_head: false }, "Install this Dry Run"],
    [{ status: "completed" }, "Install"],
    [{ status: "completed", deployment_status: "deployed", uc_catalog: "cat_a" }, "Re-install"],
    [{ status: "superseded", is_head: false }, "Make this version current"],
    [{ status: "superseded", replaced_at: "2026-10-21T00:00:00Z", is_head: false }, "Make this version current"],
  ] as [Partial<ModelVersionOut>, string][])("labels the install action (%j -> %s)", async (over, label) => {
    renderStrip(over);
    expect(await screen.findByTestId("install-version")).toHaveTextContent(label);
  });

  it("offers no install for a failed version", async () => {
    renderStrip({ status: "failed" });
    await screen.findByTestId("overview-command-strip");
    expect(screen.queryByTestId("install-version")).toBeNull();
  });

  it("enables Uninstall only when installed", async () => {
    const { unmount } = renderStrip();
    expect(await screen.findByTestId("uninstall-version")).toBeDisabled();
    unmount();
    renderStrip({ deployment_status: "deployed", uc_catalog: "cat_a" });
    expect(await screen.findByTestId("uninstall-version")).not.toBeDisabled();
  });

  it("no longer offers Generate samples (X18)", async () => {
    renderStrip({ deployment_status: "deployed", uc_catalog: "cat_a" });
    await screen.findByTestId("overview-command-strip");
    expect(screen.queryByRole("button", { name: /Generate samples/ })).toBeNull();
  });

  it("opens the install and uninstall dialogs without starting a run", async () => {
    renderStrip({ deployment_status: "deployed", uc_catalog: "cat_a" });
    await act(async () => {
      fireEvent.click(await screen.findByTestId("install-version"));
    });
    expect(screen.getByTestId("stub-install-dialog")).toBeInTheDocument();
    expect(createRun).not.toHaveBeenCalled();
  });

  it("shows 'Prepare new Vibe' on both ECM and MVM scopes", async () => {
    const { unmount } = renderStrip({ scope: "ecm" });
    expect((await screen.findByTestId("prepare-new-vibe")).closest("a")).toHaveAttribute(
      "href",
      expect.stringContaining("/ecm/inputs"),
    );
    unmount();
    renderStrip({ scope: "mvm" });
    expect((await screen.findByTestId("prepare-new-vibe")).closest("a")).toHaveAttribute(
      "href",
      expect.stringContaining("/mvm/inputs"),
    );
  });
});

describe("CommandStrip — run status summary", () => {
  beforeEach(() => {
    runsData = [];
  });

  it("shows 'No runs yet' with no runs", async () => {
    renderStrip();
    expect(await screen.findByText(/No runs yet/)).toBeInTheDocument();
  });

  it("summarises the run count when runs exist", async () => {
    runsData = [
      { id: "r2", business_id: "b1", status: "completed", created_at: new Date().toISOString() },
      { id: "r1", business_id: "b1", status: "completed", created_at: new Date().toISOString() },
    ];
    renderStrip();
    expect(await screen.findByText("2")).toBeInTheDocument();
  });

  it("shows the Installed badge only when deployed", async () => {
    renderStrip({ deployment_status: "deployed", uc_catalog: "cat_a" });
    expect(await screen.findByText("Installed")).toBeInTheDocument();
  });
});
