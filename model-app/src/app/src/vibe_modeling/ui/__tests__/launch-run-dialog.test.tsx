import { describe, expect, it, vi } from "vitest";
import { act, fireEvent, screen } from "@testing-library/react";

import { LaunchRunDialog } from "@/components/runs/launch-run-dialog";
import { renderWithRouter } from "./helpers/router-wrapper";

async function setup(overrides: Partial<React.ComponentProps<typeof LaunchRunDialog>> = {}) {
  const onConfirm = vi.fn();
  const onCancel = vi.fn();
  const utils = renderWithRouter(
    <LaunchRunDialog
      open
      operationType="install model"
      businessName="Acme Retail"
      versionLabel="v3"
      onConfirm={onConfirm}
      onCancel={onCancel}
      {...overrides}
    />,
  );
  await screen.findByRole("alertdialog");
  return { ...utils, onConfirm, onCancel };
}

describe("LaunchRunDialog", () => {
  it("renders metadata for the given operation", async () => {
    await setup();
    // Title
    expect(screen.getByRole("alertdialog")).toBeInTheDocument();
    expect(screen.getByText("Launch run?")).toBeInTheDocument();
    // Operation label from OPERATION_METADATA["install model"]
    expect(screen.getByText("Install model")).toBeInTheDocument();
    // Business name
    expect(screen.getByText("Acme Retail")).toBeInTheDocument();
    // Source version label (rendered when provided)
    expect(screen.getByText("Source version")).toBeInTheDocument();
    expect(screen.getByText("v3")).toBeInTheDocument();
    // SWAG fields removed
    expect(screen.queryByText("Expected duration")).not.toBeInTheDocument();
    expect(screen.queryByText(/Compute cost/)).not.toBeInTheDocument();
    // Honest compute + tokens warning
    expect(
      screen.getByText(/Databricks compute and LLM tokens/i),
    ).toBeInTheDocument();
  });

  it("invokes onConfirm when Launch is clicked", async () => {
    const { onConfirm, onCancel } = await setup();
    act(() => {
      fireEvent.click(screen.getByRole("button", { name: /^Launch$/ }));
    });
    expect(onConfirm).toHaveBeenCalledTimes(1);
    expect(onCancel).not.toHaveBeenCalled();
  });

  it("invokes onCancel when Cancel is clicked", async () => {
    const { onConfirm, onCancel } = await setup();
    act(() => {
      fireEvent.click(screen.getByRole("button", { name: /^Cancel$/ }));
    });
    expect(onCancel).toHaveBeenCalled();
    expect(onConfirm).not.toHaveBeenCalled();
  });

  it("invokes onCancel when Escape is pressed", async () => {
    const { onConfirm, onCancel } = await setup();
    act(() => {
      fireEvent.keyDown(document.activeElement ?? document.body, {
        key: "Escape",
        code: "Escape",
      });
    });
    expect(onCancel).toHaveBeenCalled();
    expect(onConfirm).not.toHaveBeenCalled();
  });

  it("disables both buttons and swaps the Launch label while submitting", async () => {
    await setup({ submitting: true });
    const launch = screen.getByRole("button", { name: /Starting/ });
    expect(launch).toBeDisabled();
    expect(screen.getByRole("button", { name: /^Cancel$/ })).toBeDisabled();
  });

  it("omits the Scope and Run type rows when not given", async () => {
    await setup();
    expect(screen.queryByText("Scope")).not.toBeInTheDocument();
    expect(screen.queryByText("Run type")).not.toBeInTheDocument();
    expect(screen.queryByTestId("full-run-warning")).not.toBeInTheDocument();
  });

  it("shows the Scope and Run type rows for a scoped Dry Run, with no Full Run warning", async () => {
    await setup({
      operationType: "vibe modeling of version",
      scopeLabel: "Some domains: meter_to_cash",
      agentRunMode: "dry",
      catalog: "utility_cat",
    });
    expect(screen.getByText("Scope")).toBeInTheDocument();
    expect(screen.getByText("Some domains: meter_to_cash")).toBeInTheDocument();
    expect(screen.getByText("Run type")).toBeInTheDocument();
    expect(screen.getByText("Dry Run")).toBeInTheDocument();
    expect(screen.queryByTestId("full-run-warning")).not.toBeInTheDocument();
  });

  it("shows one Full Run warning line naming the catalog", async () => {
    await setup({
      operationType: "vibe modeling of version",
      scopeLabel: "All domains",
      agentRunMode: "full",
      catalog: "utility_cat",
    });
    expect(screen.getByText("Full Run")).toBeInTheDocument();
    const warnings = screen.getAllByTestId("full-run-warning");
    expect(warnings).toHaveLength(1);
    expect(warnings[0]).toHaveTextContent(/Deploys to utility_cat\./);
    expect(warnings[0]).toHaveTextContent(/drops and rebuilds every schema this business owns/);
  });

  it("links to the help page of the operation", async () => {
    await setup({ operationType: "vibe new ecm + mvm" });
    expect(screen.getByText("Vibe ECM + MVM")).toBeInTheDocument();
    expect(screen.getByRole("link", { name: "What this run does" })).toHaveAttribute(
      "href",
      "/help/run-vibe-ecm-mvm",
    );
  });

  it("keeps the text help link at its own size (no icon-only padding)", async () => {
    await setup();
    expect(screen.getByRole("link", { name: "What this run does" })).not.toHaveClass("p-[5px]");
  });
});
