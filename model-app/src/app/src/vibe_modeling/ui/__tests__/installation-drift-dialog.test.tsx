import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";
import { render, screen, waitFor, fireEvent } from "@testing-library/react";
import { jsonResponse } from "./helpers/first-run";

import { InstallationDriftDialog } from "@/components/explorer/installation-drift-dialog";

function makeStatus(overrides: Record<string, unknown> = {}) {
  return {
    version_id: "mv-1",
    deployment_catalog: "vibe_modeling_test",
    lakebase_says_installed: true,
    expected_schemas: ["ecm_customer", "ecm_inventory"],
    found_schemas: [],
    missing_schemas: ["ecm_customer", "ecm_inventory"],
    catalog_present: false,
    in_sync: false,
    checked_at: "2026-04-27T12:00:00Z",
    skipped_reason: null,
    ...overrides,
  };
}

// Inverse-direction fixture: schemas physically exist in the catalog but
// Lakebase's deployment_status doesn't reflect it.
function makeInverseStatus(overrides: Record<string, unknown> = {}) {
  return makeStatus({
    lakebase_says_installed: false,
    catalog_present: true,
    found_schemas: ["ecm_customer", "ecm_inventory"],
    missing_schemas: [],
    in_sync: true,
    ...overrides,
  });
}

describe("InstallationDriftDialog", () => {
  let fetchMock: ReturnType<typeof vi.fn>;

  beforeEach(() => {
    fetchMock = vi.fn();
    vi.stubGlobal("fetch", fetchMock);
  });

  afterEach(() => {
    vi.restoreAllMocks();
    vi.unstubAllGlobals();
  });

  it("does not render when in_sync=true", async () => {
    fetchMock.mockResolvedValueOnce({
      ok: true,
      json: async () => makeStatus({ in_sync: true, missing_schemas: [] }),
    });

    render(
      <InstallationDriftDialog versionId="mv-1" enabled={true} />,
    );
    await new Promise((r) => setTimeout(r, 0));
    expect(
      screen.queryByTestId("installation-drift-dialog"),
    ).not.toBeInTheDocument();
  });

  it("does not render when in_sync=null (skipped probe)", async () => {
    // Regression: a skipped probe (no catalog recorded yet, or the
    // catalog listing call failed) must not force the reconcile dialog
    // the way a confirmed in_sync=false would — "unknown" is not "drift".
    fetchMock.mockResolvedValueOnce({
      ok: true,
      json: async () =>
        makeStatus({
          in_sync: null,
          missing_schemas: [],
          skipped_reason: "no deployment_catalog or no domains recorded; cannot probe",
        }),
    });

    render(<InstallationDriftDialog versionId="mv-1" enabled={true} />);
    await new Promise((r) => setTimeout(r, 0));
    expect(
      screen.queryByTestId("installation-drift-dialog"),
    ).not.toBeInTheDocument();
  });

  it("does not call status endpoint when disabled", () => {
    render(
      <InstallationDriftDialog versionId="mv-1" enabled={false} />,
    );
    expect(fetchMock).not.toHaveBeenCalled();
  });

  it("names each catalog that is missing schemas", async () => {
    fetchMock.mockResolvedValueOnce({
      ok: true,
      json: async () =>
        makeStatus({
          deployment_catalog: "cat_b",
          also_installed_in: ["cat_a"],
          missing_schemas: ["cat_a.ecm_customer", "cat_a.ecm_inventory"],
        }),
    });
    render(<InstallationDriftDialog versionId="mv-1" enabled />);
    const dialog = await screen.findByRole("alertdialog");
    expect(dialog.textContent).toContain("2 of 2 from cat_a");
    expect(dialog.textContent).not.toContain("from cat_b");
  });

  it("names the install catalog for its own missing schemas", async () => {
    fetchMock.mockResolvedValueOnce({ ok: true, json: async () => makeStatus({ missing_schemas: ["ecm_customer"] }) });
    render(<InstallationDriftDialog versionId="mv-1" enabled />);
    const dialog = await screen.findByRole("alertdialog");
    expect(dialog.textContent).toContain("1 of 2 from vibe_modeling_test");
  });

  it("pops the dialog and reconciles on user click", async () => {
    fetchMock.mockResolvedValueOnce({
      ok: true,
      json: async () => makeStatus(),
    });
    fetchMock.mockResolvedValueOnce({
      ok: true,
      json: async () => ({
        version_id: "mv-1",
        previous_deployment_status: "deployed",
        new_deployment_status: "uninstalled",
        schemas_present: [],
        schemas_missing: ["ecm_customer", "ecm_inventory"],
        notes: ["no expected schemas found; marked uninstalled"],
      }),
    });

    const onReconciled = vi.fn();
    render(
      <InstallationDriftDialog
        versionId="mv-1"
        enabled={true}
        onReconciled={onReconciled}
      />,
    );

    await waitFor(() => {
      expect(
        screen.getByText(/Catalog drift detected/i),
      ).toBeInTheDocument();
    });
    expect(screen.getByText(/ecm_customer/i)).toBeInTheDocument();

    fireEvent.click(screen.getByRole("button", { name: /reconcile/i }));

    await waitFor(() => {
      expect(
        screen.getByText(/Lakebase synced with catalog/i),
      ).toBeInTheDocument();
    });
    expect(onReconciled).toHaveBeenCalledTimes(1);
  });

  it("surfaces a backend error and lets the user retry", async () => {
    fetchMock.mockResolvedValueOnce({
      ok: true,
      json: async () => makeStatus(),
    });
    fetchMock.mockResolvedValueOnce(jsonResponse(502, "could not list schemas"));

    render(<InstallationDriftDialog versionId="mv-1" enabled={true} />);

    await waitFor(() => {
      expect(
        screen.getByText(/Catalog drift detected/i),
      ).toBeInTheDocument();
    });

    fireEvent.click(screen.getByRole("button", { name: /reconcile/i }));

    await waitFor(() => {
      expect(
        screen.getByText(/could not list schemas|HTTP 502/i),
      ).toBeInTheDocument();
    });
    // The Reconcile button is still there — user can retry.
    expect(
      screen.getByRole("button", { name: /retry reconcile/i }),
    ).toBeInTheDocument();
    // Dismiss escape hatch is now available after the error so the
    // user is never stuck on a hung backend.
    expect(
      screen.getByRole("button", { name: /dismiss/i }),
    ).toBeInTheDocument();
  });

  it("user can dismiss after a failed attempt to escape a stuck backend", async () => {
    fetchMock.mockResolvedValueOnce({
      ok: true,
      json: async () => makeStatus(),
    });
    fetchMock.mockResolvedValueOnce(jsonResponse(502, "boom"));

    render(<InstallationDriftDialog versionId="mv-1" enabled={true} />);
    await waitFor(() => {
      expect(
        screen.getByText(/Catalog drift detected/i),
      ).toBeInTheDocument();
    });
    fireEvent.click(screen.getByRole("button", { name: /reconcile/i }));
    await waitFor(() =>
      expect(screen.getByRole("button", { name: /dismiss/i })).toBeInTheDocument(),
    );

    fireEvent.click(screen.getByRole("button", { name: /dismiss/i }));
    await waitFor(() => {
      expect(
        screen.queryByTestId("installation-drift-dialog"),
      ).not.toBeInTheDocument();
    });
  });

  it("does not render when in_sync=null and there is no catalog signal (skipped probe)", async () => {
    // Explicit combination: catalog_present=false and found_schemas=[]
    // alongside in_sync=null must never trip the inverse-drift branch.
    fetchMock.mockResolvedValueOnce({
      ok: true,
      json: async () =>
        makeStatus({
          in_sync: null,
          missing_schemas: [],
          catalog_present: false,
          found_schemas: [],
          lakebase_says_installed: false,
          skipped_reason: "no deployment_catalog or no domains recorded; cannot probe",
        }),
    });

    render(<InstallationDriftDialog versionId="mv-1" enabled={true} />);
    await new Promise((r) => setTimeout(r, 0));
    expect(
      screen.queryByTestId("installation-drift-dialog"),
    ).not.toBeInTheDocument();
  });

  it("does not render the inverse-drift dialog for a partial match", async () => {
    // Reconcile only promotes to "deployed" when every expected schema is
    // present; a partial match (e.g. another business's bare-name schemas
    // in a shared catalog) would re-open this dialog on every visit.
    fetchMock.mockResolvedValueOnce({
      ok: true,
      json: async () =>
        makeInverseStatus({
          found_schemas: ["customer"],
          missing_schemas: ["ecm_geology", "ecm_tailings"],
        }),
    });

    render(<InstallationDriftDialog versionId="mv-1" enabled={true} />);
    await new Promise((r) => setTimeout(r, 0));
    expect(
      screen.queryByTestId("installation-drift-dialog"),
    ).not.toBeInTheDocument();
  });

  it("pops the inverse-drift dialog and reconciles on user click", async () => {
    fetchMock.mockResolvedValueOnce({
      ok: true,
      json: async () => makeInverseStatus(),
    });
    fetchMock.mockResolvedValueOnce({
      ok: true,
      json: async () => ({
        version_id: "mv-1",
        previous_deployment_status: "uninstalled",
        new_deployment_status: "deployed",
        schemas_present: ["ecm_customer", "ecm_inventory"],
        schemas_missing: [],
        notes: ["all expected schemas found; marked deployed"],
      }),
    });

    const onReconciled = vi.fn();
    render(
      <InstallationDriftDialog
        versionId="mv-1"
        enabled={true}
        onReconciled={onReconciled}
      />,
    );

    await waitFor(() => {
      expect(
        screen.getByText(/Installation status out of sync/i),
      ).toBeInTheDocument();
    });
    expect(
      screen.getByText(/exist in the catalog but Lakebase shows it as/i),
    ).toBeInTheDocument();
    expect(screen.getByText(/not installed/i)).toBeInTheDocument();
    expect(screen.getByText(/ecm_customer/i)).toBeInTheDocument();

    fireEvent.click(screen.getByRole("button", { name: /reconcile/i }));

    await waitFor(() => {
      expect(
        screen.getByText(/Lakebase synced with catalog/i),
      ).toBeInTheDocument();
    });
    expect(onReconciled).toHaveBeenCalledTimes(1);
  });

  it("inverse-drift dialog is dismissible via a Cancel button, unlike the forced case", async () => {
    fetchMock.mockResolvedValueOnce({
      ok: true,
      json: async () => makeInverseStatus(),
    });

    render(<InstallationDriftDialog versionId="mv-1" enabled={true} />);

    await waitFor(() => {
      expect(
        screen.getByText(/Installation status out of sync/i),
      ).toBeInTheDocument();
    });

    // No prior error yet, but the Cancel button is already present.
    // Unlike the forced case's Dismiss, it doesn't wait for a failed
    // reconcile attempt.
    const cancelButton = screen.getByRole("button", { name: /cancel/i });
    expect(cancelButton).toBeInTheDocument();

    fireEvent.click(cancelButton);
    await waitFor(() => {
      expect(
        screen.queryByTestId("installation-drift-dialog"),
      ).not.toBeInTheDocument();
    });
  });
});
