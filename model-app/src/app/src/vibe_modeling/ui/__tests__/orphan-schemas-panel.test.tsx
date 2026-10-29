/**
 * The business edit page's "Orphan schemas" panel: hidden for non-admins,
 * check a catalog, only owned schemas selectable, the drop dialog loads the
 * impact of the selection, asks for the typed catalog name when data may be
 * lost, sends the server's subject, and takes the server's impact from a
 * `needs_confirmation` answer. `fetch` is stubbed, so the generated client
 * builds the real requests.
 */
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";
import { act, fireEvent, render, screen, waitFor, within } from "@testing-library/react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";

let role: string | undefined = "app_admin";
vi.mock("@/lib/hooks", async () => {
  const actual = await vi.importActual<typeof import("@/lib/hooks")>("@/lib/hooks");
  return { ...actual, useUserRole: () => role };
});
vi.mock("sonner", () => ({ toast: { success: vi.fn(), warning: vi.fn(), error: vi.fn() } }));
vi.mock("@/lib/notify", () => ({ notifyError: vi.fn() }));

import { toast } from "sonner";
import { OrphanSchemasPanel } from "@/components/business/orphan-schemas-panel";
import type { OrphanSchemasOut, UninstallImpactOut } from "@/lib/api";

const CATALOG = "home_cat";
const SUBJECT = "drop_destroys_data:home_cat:0123456789abcdef";

function impact(hasData: "yes" | "no"): UninstallImpactOut {
  return {
    version_id: "",
    catalog: CATALOG,
    has_data: hasData,
    truncated: false,
    reasons: [],
    installed_catalogs: [],
    schemas: [
      {
        name: "ecm_intake",
        owner: "app-sp",
        tables: [
          { name: "scale_ticket", kind: "MANAGED", has_data: hasData === "yes" },
          { name: "receiving_record", kind: "MANAGED", has_data: false },
        ],
        views: [],
        volumes: [],
      },
    ],
  };
}

const LISTED: OrphanSchemasOut = {
  catalog: CATALOG,
  schemas: [
    { name: "ecm_intake", owner: "app-sp", owned_by_app: true, match: "exact", table_count: 2 },
    { name: "ecm_party", owner: "app-sp", owned_by_app: true, match: "inferred", table_count: 0 },
    { name: "ecm_storage", owner: "someone@example.com", owned_by_app: false, match: "exact", table_count: null },
    {
      name: "ecm_billing", owner: "app-sp", owned_by_app: true, match: "exact", table_count: 3,
      blocked_reason: "The app has no record of starting the run that made this version: it was made outside the app, or deleted by an earlier release of the app. Import it and uninstall it, or drop it by hand.",
    },
  ],
  impact: null,
  confirm_subject: null,
};

function ok(body: unknown) {
  return { ok: true, status: 200, json: async () => body, text: async () => JSON.stringify(body) };
}

function err(status: number, body: unknown) {
  return { ok: false, status, statusText: "err", text: async () => JSON.stringify(body) };
}

let fetchMock: ReturnType<typeof vi.fn>;

function renderPanel() {
  return render(
    <QueryClientProvider client={new QueryClient({ defaultOptions: { queries: { retry: false } } })}>
      <OrphanSchemasPanel businessId="b1" />
    </QueryClientProvider>,
  );
}

async function checkCatalog(value = "") {
  const input = screen.getByTestId("orphan-catalog-input") as HTMLInputElement;
  fireEvent.change(input, { target: { value } });
  expect(input.value).toBe(value);
  await act(async () => {
    fireEvent.click(screen.getByTestId("orphan-check"));
  });
  await screen.findAllByTestId("orphan-schema-row");
}

beforeEach(() => {
  role = "app_admin";
  fetchMock = vi.fn();
  vi.stubGlobal("fetch", fetchMock);
});

afterEach(() => {
  vi.unstubAllGlobals();
  vi.clearAllMocks();
});

describe("OrphanSchemasPanel", () => {
  it.each(["business_admin", "modeler", "viewer"])("renders nothing for %s", (r) => {
    role = r;
    renderPanel();
    expect(screen.queryByTestId("orphan-schemas-panel")).toBeNull();
    expect(fetchMock).not.toHaveBeenCalled();
  });

  it("does not check a catalog until asked", () => {
    renderPanel();
    expect(screen.getByTestId("orphan-schemas-panel")).toBeInTheDocument();
    expect(fetchMock).not.toHaveBeenCalled();
  });

  it("lists orphans; a schema the app does not own cannot be selected", async () => {
    fetchMock.mockResolvedValue(ok(LISTED));
    renderPanel();
    await checkCatalog("Home_Cat");
    expect(fetchMock.mock.calls[0][0]).toBe("/api/businesses/b1/orphan-schemas?catalog=home_cat");
    const rows = screen.getAllByTestId("orphan-schema-row");
    expect(rows).toHaveLength(4);
    expect(rows[0]).toHaveTextContent("ecm_intake2 tables");
    expect(within(rows[1]).getByTestId("orphan-schema-inferred")).toBeInTheDocument();
    expect(within(rows[2]).getByTestId("orphan-schema-not-owned")).toHaveTextContent(
      "Not owned by this app (owner: someone@example.com)",
    );
    expect(within(rows[2]).getByRole("checkbox")).toBeDisabled();
    expect(within(rows[3]).getByTestId("orphan-schema-blocked")).toHaveTextContent("Import it and uninstall it");
    expect(within(rows[3]).getByRole("checkbox")).toBeDisabled();
    expect(screen.getByTestId("orphan-drop-open")).toBeDisabled();
  });

  it("an empty catalog says so", async () => {
    fetchMock.mockResolvedValue(ok({ catalog: CATALOG, schemas: [], impact: null, confirm_subject: null }));
    renderPanel();
    await act(async () => {
      fireEvent.click(screen.getByTestId("orphan-check"));
    });
    expect(await screen.findByTestId("orphan-none")).toHaveTextContent("No orphan schemas of this business in home_cat.");
    expect(fetchMock.mock.calls[0][0]).toBe("/api/businesses/b1/orphan-schemas");
  });

  it("drops a selection with data after the typed catalog name, sending the subject", async () => {
    fetchMock
      .mockResolvedValueOnce(ok(LISTED))
      .mockResolvedValueOnce(ok({ ...LISTED, impact: impact("yes"), confirm_subject: SUBJECT }))
      .mockResolvedValueOnce(ok({
        run_id: "r1", catalog: CATALOG,
        schemas: [{ name: "ecm_intake", status: "dropped", table_count: 2, error: null }],
        metamodel_cleanup: { done: 1, pending: 0, failed: 0 },
      }))
      .mockResolvedValue(ok({ ...LISTED, schemas: LISTED.schemas!.slice(1) }));
    renderPanel();
    await checkCatalog();
    fireEvent.click(within(screen.getAllByTestId("orphan-schema-row")[0]).getByRole("checkbox"));
    fireEvent.click(screen.getByTestId("orphan-drop-open"));

    const dialog = await screen.findByTestId("orphan-drop-dialog");
    expect(fetchMock.mock.calls[1][0]).toBe("/api/businesses/b1/orphan-schemas?catalog=home_cat&schemas=ecm_intake");
    expect(await within(dialog).findByTestId("uninstall-impact-headline")).toHaveTextContent(
      "1 of 2 tables hold data. The drop deletes 1 schema in home_cat with all its data.",
    );
    expect(within(dialog).queryByTestId("uninstall-impact-installed")).toBeNull();
    expect(screen.getByTestId("orphan-drop-confirm")).toBeDisabled();

    const input = within(dialog).getByTestId("uninstall-impact-confirm-input") as HTMLInputElement;
    fireEvent.change(input, { target: { value: CATALOG } });
    expect(input.value).toBe(CATALOG);
    await waitFor(() => expect(screen.getByTestId("orphan-drop-confirm")).toBeEnabled());
    await act(async () => {
      fireEvent.click(screen.getByTestId("orphan-drop-confirm"));
    });

    await waitFor(() => expect(fetchMock.mock.calls.length).toBeGreaterThanOrEqual(3));
    const [url, init] = fetchMock.mock.calls[2];
    expect(url).toBe("/api/businesses/b1/orphan-schemas/drop");
    expect(JSON.parse(init.body)).toEqual({ catalog: CATALOG, schemas: ["ecm_intake"], confirmed_issues: [SUBJECT] });
    await waitFor(() => expect(toast.success).toHaveBeenCalledWith("Dropped 1 schema from home_cat."));
    await waitFor(() => expect(screen.queryByTestId("orphan-drop-dialog")).toBeNull());
  });

  it("drops empty schemas without the typed name and without a subject", async () => {
    fetchMock
      .mockResolvedValueOnce(ok(LISTED))
      .mockResolvedValueOnce(ok({ ...LISTED, impact: impact("no"), confirm_subject: null }))
      .mockResolvedValue(ok({
        run_id: "r1", catalog: CATALOG,
        schemas: [{ name: "ecm_intake", status: "dropped", table_count: 2, error: null }],
        metamodel_cleanup: { done: 0, pending: 0, failed: 0 },
      }));
    renderPanel();
    await checkCatalog();
    fireEvent.click(within(screen.getAllByTestId("orphan-schema-row")[0]).getByRole("checkbox"));
    fireEvent.click(screen.getByTestId("orphan-drop-open"));
    const dialog = await screen.findByTestId("orphan-drop-dialog");
    await within(dialog).findByTestId("uninstall-impact-headline");
    expect(within(dialog).queryByTestId("uninstall-impact-confirm-input")).toBeNull();
    await waitFor(() => expect(screen.getByTestId("orphan-drop-confirm")).toBeEnabled());
    await act(async () => {
      fireEvent.click(screen.getByTestId("orphan-drop-confirm"));
    });
    await waitFor(() => expect(fetchMock.mock.calls.length).toBeGreaterThanOrEqual(3));
    expect(JSON.parse(fetchMock.mock.calls[2][1].body).confirmed_issues).toEqual([]);
  });

  it("takes the server's impact and subject from a needs_confirmation answer", async () => {
    fetchMock
      .mockResolvedValueOnce(ok(LISTED))
      .mockResolvedValueOnce(ok({ ...LISTED, impact: impact("no"), confirm_subject: null }))
      .mockResolvedValueOnce(err(422, {
        detail: {
          error: "needs_confirmation",
          message: "Confirm what this drop deletes",
          issues: [{ subject: SUBJECT, message: "1 of 2 tables hold data", field_path: "schemas", versions: [] }],
          impact: impact("yes"),
        },
      }));
    renderPanel();
    await checkCatalog();
    fireEvent.click(within(screen.getAllByTestId("orphan-schema-row")[0]).getByRole("checkbox"));
    fireEvent.click(screen.getByTestId("orphan-drop-open"));
    const dialog = await screen.findByTestId("orphan-drop-dialog");
    await within(dialog).findByTestId("uninstall-impact-headline");
    await waitFor(() => expect(screen.getByTestId("orphan-drop-confirm")).toBeEnabled());
    await act(async () => {
      fireEvent.click(screen.getByTestId("orphan-drop-confirm"));
    });
    expect(await within(dialog).findByTestId("orphan-drop-error")).toHaveTextContent("Review it and confirm again");
    expect(within(dialog).getByTestId("uninstall-impact-headline")).toHaveTextContent("1 of 2 tables hold data.");
    expect(screen.getByTestId("orphan-drop-confirm")).toBeDisabled();
    fireEvent.change(within(dialog).getByTestId("uninstall-impact-confirm-input"), { target: { value: CATALOG } });
    await waitFor(() => expect(screen.getByTestId("orphan-drop-confirm")).toBeEnabled());
  });

  async function dropWithAnswer(answer: unknown) {
    fetchMock
      .mockResolvedValueOnce(ok(LISTED))
      .mockResolvedValueOnce(ok({ ...LISTED, impact: impact("no"), confirm_subject: null }))
      .mockResolvedValueOnce(answer)
      .mockResolvedValue(ok({ ...LISTED, schemas: LISTED.schemas!.slice(1) }));
    renderPanel();
    await checkCatalog();
    fireEvent.click(within(screen.getAllByTestId("orphan-schema-row")[0]).getByRole("checkbox"));
    fireEvent.click(screen.getByTestId("orphan-drop-open"));
    const dialog = await screen.findByTestId("orphan-drop-dialog");
    await within(dialog).findByTestId("uninstall-impact-headline");
    await waitFor(() => expect(screen.getByTestId("orphan-drop-confirm")).toBeEnabled());
    await act(async () => {
      fireEvent.click(screen.getByTestId("orphan-drop-confirm"));
    });
    return dialog;
  }

  it.each([502, 503, 504])("a lost %s answer points to the runs instead of claiming the drop failed", async (status) => {
    const dialog = await dropWithAnswer(err(status, "Gateway Timeout"));
    expect(await within(dialog).findByTestId("orphan-drop-error")).toHaveTextContent("The drop may still be running");
  });

  it("a 503 the app sent itself shows its message, not the answer-lost notice", async () => {
    const dialog = await dropWithAnswer(
      err(503, { detail: { error: "orphan_check_failed", message: "The agent's registry in home_cat could not be read." } }),
    );
    expect(await within(dialog).findByTestId("orphan-drop-error")).toHaveTextContent(
      "The agent's registry in home_cat could not be read.",
    );
    expect(within(dialog).getByTestId("orphan-drop-error")).not.toHaveTextContent("may still be running");
  });

  it("warns when the registry cleanup of the drop did not finish", async () => {
    await dropWithAnswer(ok({
      run_id: "r1", catalog: CATALOG,
      schemas: [{ name: "ecm_intake", status: "dropped", table_count: 2, error: null }],
      metamodel_cleanup: { done: 0, pending: 1, failed: 1 },
    }));
    await waitFor(() => expect(toast.warning).toHaveBeenCalledTimes(1));
    expect(toast.warning).toHaveBeenCalledWith("Dropped 1 schema from home_cat.", expect.objectContaining({
      description:
        "2 registry cleanups did not finish, so the agent's registry rows are still there. " +
        "The app retries at the next start-ups. " +
        "Retry cleanup on the business's Explorer page runs the retry now.",
    }));
    expect(toast.success).not.toHaveBeenCalled();
  });

  it("shows a failed check", async () => {
    fetchMock.mockResolvedValue(err(503, { detail: { error: "orphan_check_failed", message: "The agent's registry in home_cat could not be read." } }));
    renderPanel();
    await act(async () => {
      fireEvent.click(screen.getByTestId("orphan-check"));
    });
    expect(await screen.findByTestId("orphan-list-error")).toHaveTextContent(
      "The agent's registry in home_cat could not be read.",
    );
  });
});
