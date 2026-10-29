/**
 * The install / uninstall dialog and `useVersionOperationLaunch` (design §1
 * UI and B4; add §6.2, §10.2): the catalog picker default, one confirmation
 * per subject sent as `confirmed_issues`, the re-render on a 422
 * `needs_confirmation`, "also delete" only for BusinessAdmins, the
 * uninstall-then-install impact, the uninstall's typed confirmation, the
 * catalogs the version stays installed in, and blockers.
 */
import { beforeEach, describe, expect, it, vi } from "vitest";
import { act, fireEvent, screen, waitFor } from "@testing-library/react";
import type { UninstallImpactConfirmState } from "@/components/runs/uninstall-impact-confirm";

const validateMock = vi.fn();
const createMock = vi.fn();
let installStatus: unknown = undefined;
let role: string | undefined = "app_admin";

vi.mock("@/lib/api", async () => {
  const actual = await vi.importActual<typeof import("@/lib/api")>("@/lib/api");
  return {
    ...actual,
    validateRun: (...a: unknown[]) => validateMock(...a),
    createRun: (...a: unknown[]) => createMock(...a),
    useGetInstallationStatus: () => ({ data: installStatus }),
  };
});
vi.mock("@/lib/hooks", async () => {
  const actual = await vi.importActual<typeof import("@/lib/hooks")>("@/lib/hooks");
  return { ...actual, useUserRole: () => role, useDebouncedValue: <T,>(v: T) => v };
});
vi.mock("sonner", () => ({ toast: { warning: vi.fn(), success: vi.fn(), error: vi.fn() } }));
vi.mock("@/components/runs/deployment-catalog-picker", () => ({
  DeploymentCatalogPicker: ({ value, onChange }: { value: string; onChange: (v: string) => void }) => (
    <input aria-label="Deployment catalog" value={value} onChange={(e) => onChange(e.target.value)} />
  ),
}));
// The impact component is tested on its own. Here it reports a chosen state,
// and follows its contract for `requireConfirmation`: then only the typed
// name ("type name") confirms, whatever the impact says.
let impactState: UninstallImpactConfirmState = { status: "ready", needsConfirmation: true, confirmed: false };
vi.mock("@/components/runs/uninstall-impact-confirm", async () => {
  const { useState } = await import("react");
  return {
    UninstallImpactConfirm: ({
      versionId,
      catalog,
      onStateChange,
      requireConfirmation,
    }: {
      versionId: string;
      catalog: string;
      onStateChange?: (s: UninstallImpactConfirmState) => void;
      requireConfirmation?: boolean;
    }) => {
      const [typed, setTyped] = useState(false);
      const report = (t: boolean) =>
        onStateChange?.(
          requireConfirmation ? { status: "ready", needsConfirmation: true, confirmed: t } : impactState,
        );
      return (
        <div data-testid={`impact-${versionId}-${catalog}`} data-require={requireConfirmation ? "yes" : "no"}>
          <button type="button" onClick={() => report(typed)}>
            report impact
          </button>
          <button type="button" onClick={() => { setTyped(true); report(true); }}>
            type name
          </button>
        </div>
      );
    },
  };
});

import { ApiError } from "@/lib/api";
import { VersionOperationDialog } from "@/components/runs/version-operation-dialog";
import { renderWithRouter } from "./helpers/router-wrapper";
import { makeModelVersion } from "./helpers/model-version";

const v3 = makeModelVersion({
  id: "mv-3", version: 3, scope: "ecm", status: "superseded", is_head: false,
  files_catalog: "home_cat", uc_catalog: "",
});
const v5 = makeModelVersion({ id: "mv-5", version: 5, scope: "ecm", deployment_status: "deployed", uc_catalog: "cat_x" });

const OVER_NEWER = {
  field_path: "version_id", step_index: -1, severity: "confirm" as const,
  message: "v5 is the latest ECM version. Installing v3 makes v3 the latest and replaces v4 and v5. Their changes that are not in v3 are dropped: v4: a; v5: b.",
  subject: "install_over_newer:mv-5",
  versions: [4, 5],
};
const REPLACES = {
  field_path: "catalog", step_index: -1, severity: "confirm" as const,
  message: "Catalog cat_x holds v5. To install v3 there, the app first uninstalls v5, then installs v3 in full.",
  subject: "install_replaces_in_catalog:mv-5",
};
const OVERWRITES = {
  field_path: "catalog", step_index: -1, severity: "confirm" as const,
  message: "The install writes into schemas this business doesn't own: ecm_sales (owned by Other).",
  subject: "install_overwrites_schemas:mv-3:cat_x",
};

function validates(warnings: unknown[] = [], blockers: unknown[] = []) {
  validateMock.mockResolvedValue({ data: { warnings, blockers } });
}

function renderDialog(
  over: Partial<React.ComponentProps<typeof VersionOperationDialog>> = {},
) {
  return renderWithRouter(
    <VersionOperationDialog
      open
      onOpenChange={() => {}}
      businessId="b1"
      intent="install"
      version={v3}
      versions={[v3, v5]}
      {...over}
    />,
  );
}

const launchButton = () => screen.getByTestId("version-op-launch");

beforeEach(() => {
  validateMock.mockReset();
  createMock.mockReset();
  installStatus = undefined;
  role = "app_admin";
  impactState = { status: "ready", needsConfirmation: true, confirmed: false };
});

describe("install: catalog picker default (B3)", () => {
  it("defaults to the files catalog of a version installed nowhere and validates there", async () => {
    validates();
    renderDialog();
    expect(await screen.findByLabelText("Deployment catalog")).toHaveValue("home_cat");
    await waitFor(() =>
      expect(validateMock).toHaveBeenCalledWith(
        { business_id: "b1" },
        { intent: "install", version_id: "mv-3", catalog: "home_cat" },
      ),
    );
  });

  it("defaults to the install catalog of an installed version", async () => {
    validates();
    renderDialog({ version: v5 });
    expect(await screen.findByLabelText("Deployment catalog")).toHaveValue("cat_x");
  });

  it("validates again for a new catalog", async () => {
    validates();
    renderDialog();
    fireEvent.change(await screen.findByLabelText("Deployment catalog"), { target: { value: "sandbox" } });
    await waitFor(() =>
      expect(validateMock).toHaveBeenLastCalledWith(
        { business_id: "b1" },
        { intent: "install", version_id: "mv-3", catalog: "sandbox" },
      ),
    );
  });
});

describe("help link", () => {
  it("links the install and the uninstall dialog to their help pages", async () => {
    validates();
    const { unmount } = renderDialog();
    expect(await screen.findByRole("link", { name: "How install works" })).toHaveAttribute("href", "/help/run-install");
    unmount();
    renderDialog({ intent: "uninstall", version: v5 });
    expect(await screen.findByRole("link", { name: "How uninstall works" })).toHaveAttribute("href", "/help/run-uninstall");
  });
});

describe("install: confirm subjects", () => {
  it("needs every subject confirmed, then sends them as confirmed_issues", async () => {
    validates([OVER_NEWER, OVERWRITES]);
    createMock.mockResolvedValue({ data: { id: "run-9", warnings: [] } });
    renderDialog();
    expect(await screen.findByText(OVER_NEWER.message)).toBeInTheDocument();
    expect(screen.getByText(OVERWRITES.message)).toBeInTheDocument();
    expect(launchButton()).toBeDisabled();
    fireEvent.click(screen.getByTestId("confirm-install_over_newer"));
    expect(launchButton()).toBeDisabled();
    fireEvent.click(screen.getByTestId("confirm-install_overwrites_schemas"));
    expect(launchButton()).not.toBeDisabled();
    await act(async () => {
      fireEvent.click(launchButton());
    });
    expect(createMock).toHaveBeenCalledWith(
      { business_id: "b1" },
      {
        intent: "install",
        version_id: "mv-3",
        catalog: "home_cat",
        confirmed_issues: ["install_over_newer:mv-5", "install_overwrites_schemas:mv-3:cat_x"],
      },
    );
  });

  it("re-renders with the new subjects on needs_confirmation, keeping the confirmed ones", async () => {
    validates([OVER_NEWER]);
    createMock
      .mockRejectedValueOnce(
        new ApiError(422, "Unprocessable", {
          detail: { error: "needs_confirmation", issues: [OVER_NEWER, OVERWRITES], message: "cut".repeat(200) },
        }),
      )
      .mockResolvedValueOnce({ data: { id: "run-10", warnings: [] } });
    renderDialog();
    fireEvent.click(await screen.findByTestId("confirm-install_over_newer"));
    await act(async () => {
      fireEvent.click(launchButton());
    });
    expect(await screen.findByTestId("confirmations-changed")).toBeInTheDocument();
    expect(screen.getByText(OVERWRITES.message)).toBeInTheDocument();
    expect(screen.queryByText(/cutcut/)).toBeNull();
    expect(screen.getByTestId("confirm-install_over_newer")).toHaveAttribute("data-state", "checked");
    expect(launchButton()).toBeDisabled();
    fireEvent.click(screen.getByTestId("confirm-install_overwrites_schemas"));
    await act(async () => {
      fireEvent.click(launchButton());
    });
    expect(createMock).toHaveBeenLastCalledWith(
      { business_id: "b1" },
      expect.objectContaining({
        confirmed_issues: ["install_over_newer:mv-5", "install_overwrites_schemas:mv-3:cat_x"],
      }),
    );
  });

  it("raises the Settings notice for a config_missing refusal, as the run form does", async () => {
    const { toast } = await import("sonner");
    vi.mocked(toast.error).mockClear();
    validates();
    createMock.mockRejectedValue(
      new ApiError(422, "Unprocessable", {
        detail: {
          error: "config_missing",
          missing: [{ key: "warehouse", label: "SQL warehouse", settings_url: "/settings?tab=platform" }],
          message: "Missing required configuration: SQL warehouse.",
        },
      }),
    );
    renderDialog();
    await waitFor(() => expect(launchButton()).not.toBeDisabled());
    await act(async () => {
      fireEvent.click(launchButton());
    });
    expect(toast.error).toHaveBeenCalledTimes(1);
    expect(screen.queryByTestId("version-op-error")).not.toBeInTheDocument();
  });

  it("shows another error inline and does not navigate", async () => {
    validates();
    createMock.mockRejectedValue(new ApiError(409, "Conflict", { detail: "A run is already active." }));
    renderDialog();
    await waitFor(() => expect(launchButton()).not.toBeDisabled());
    await act(async () => {
      fireEvent.click(launchButton());
    });
    expect(await screen.findByTestId("version-op-error")).toHaveTextContent("A run is already active.");
  });

  it("blocks the launch on a blocker", async () => {
    validates([], [{ field_path: "catalog", step_index: -1, severity: "blocker", message: "Another business owns these schemas." }]);
    renderDialog();
    expect(await screen.findByTestId("version-op-blockers")).toHaveTextContent("Another business owns these schemas.");
    expect(launchButton()).toBeDisabled();
  });

  it("lists prepare items apart from the warnings, as a note, and still launches", async () => {
    const prepare = {
      field_path: "catalog", step_index: -1, severity: "prepare" as const,
      message: "The `vol_root` volume will be created in 'home_cat._metamodel' when you start the run.",
    };
    const warning = { field_path: "catalog", step_index: -1, severity: "warning" as const, message: "Heads up." };
    validates([prepare, warning]);
    createMock.mockResolvedValue({ data: { id: "run-p", warnings: [] } });
    renderDialog();
    const prepares = await screen.findByTestId("version-op-prepares");
    expect(prepares).toHaveAttribute("role", "note");
    expect(prepares).toHaveTextContent(prepare.message);
    expect(prepares.className).toContain("bg-muted");
    expect(screen.getByTestId("version-op-warnings")).toHaveTextContent("Heads up.");
    expect(screen.getByTestId("version-op-warnings")).not.toHaveTextContent(prepare.message);
    await waitFor(() => expect(launchButton()).not.toBeDisabled());
    await act(async () => {
      fireEvent.click(launchButton());
    });
    expect(createMock).toHaveBeenCalledTimes(1);
  });
});

describe("install: also delete the replaced versions", () => {
  it("is offered to BusinessAdmins with an install over newer, and sent when ticked", async () => {
    role = "business_admin";
    validates([OVER_NEWER]);
    createMock.mockResolvedValue({ data: { id: "run-11", warnings: [] } });
    renderDialog();
    expect(await screen.findByTestId("also-delete-replaced")).toHaveTextContent("Also delete v4 and v5 after the install");
    fireEvent.click(screen.getByTestId("confirm-also_delete_replaced"));
    fireEvent.click(screen.getByTestId("confirm-install_over_newer"));
    await act(async () => {
      fireEvent.click(launchButton());
    });
    expect(createMock).toHaveBeenCalledWith({ business_id: "b1" }, expect.objectContaining({ also_delete_replaced: true }));
  });

  it.each(["modeler", "viewer", undefined])("is hidden for role %s", async (r) => {
    role = r;
    validates([OVER_NEWER]);
    renderDialog();
    await screen.findByText(OVER_NEWER.message);
    expect(screen.queryByTestId("also-delete-replaced")).toBeNull();
  });

  it("names all replaced versions and leaves the scoped-run claim to the confirm message (mixed)", async () => {
    role = "business_admin";
    const message = "Installing v3 replaces v2 and v5. Scoped runs on v3 in cat_a are refused by the agent until v5 is deleted: it stays in the agent's registry there after it is replaced.";
    validates([{ ...OVER_NEWER, message, versions: [2, 5] }]);
    renderDialog({ version: makeModelVersion({ id: "mv-3", version: 3, scope: "ecm", status: "draft" }) });
    const note = await screen.findByTestId("also-delete-replaced");
    expect(note).toHaveTextContent("Also delete v2 and v5 after the install");
    expect(note).not.toHaveTextContent("Scoped runs");
    expect(screen.getByText(message)).toBeInTheDocument();
  });

  it("keeps the helper line free of the scoped-run claim when all replaced versions are above", async () => {
    role = "business_admin";
    validates([OVER_NEWER]);
    renderDialog();
    const note = await screen.findByTestId("also-delete-replaced");
    expect(note).toHaveTextContent("Also delete v4 and v5 after the install");
    expect(note).not.toHaveTextContent("Scoped runs");
  });

  it("keeps the helper line free of the scoped-run claim when all replaced versions are below", async () => {
    role = "business_admin";
    validates([{ ...OVER_NEWER, versions: [4, 5] }]);
    renderDialog({ version: makeModelVersion({ id: "mv-6", version: 6, scope: "ecm", status: "draft" }) });
    const note = await screen.findByTestId("also-delete-replaced");
    expect(note).toHaveTextContent("Also delete v4 and v5 after the install");
    expect(note).not.toHaveTextContent("Scoped runs");
  });

  it("is hidden without an install over newer", async () => {
    validates([OVERWRITES]);
    renderDialog();
    await screen.findByText(OVERWRITES.message);
    expect(screen.queryByTestId("also-delete-replaced")).toBeNull();
  });
});

describe("install into an occupied catalog (uninstall-then-install)", () => {
  it("shows the occupant's impact and asks for the typed confirmation when data is at stake", async () => {
    validates([REPLACES]);
    renderDialog({ initialCatalog: "cat_x" });
    expect(await screen.findByTestId("impact-mv-5-cat_x")).toBeInTheDocument();
    expect(launchButton()).toBeDisabled();
    impactState = { status: "ready", needsConfirmation: true, confirmed: true };
    fireEvent.click(screen.getByText("report impact"));
    await waitFor(() => expect(launchButton()).not.toBeDisabled());
  });

  it("uses a checkbox when nothing holds data", async () => {
    validates([REPLACES]);
    renderDialog({ initialCatalog: "cat_x" });
    impactState = { status: "ready", needsConfirmation: false, confirmed: true };
    fireEvent.click(await screen.findByText("report impact"));
    expect(launchButton()).toBeDisabled();
    fireEvent.click(screen.getByTestId("confirm-install_replaces_in_catalog"));
    await waitFor(() => expect(launchButton()).not.toBeDisabled());
  });

  it("asks to pick a catalog when the target is empty", async () => {
    validates([REPLACES]);
    renderDialog({ initialCatalog: "cat_x" });
    fireEvent.change(await screen.findByLabelText("Deployment catalog"), { target: { value: "" } });
    expect(await screen.findByTestId("replace-needs-catalog")).toBeInTheDocument();
  });
});

describe("install: other install catalogs (add §10.2)", () => {
  it("says the version stays installed in its other catalogs", async () => {
    validates();
    installStatus = { data: { also_installed_in: ["cat_y"] } };
    renderDialog({ version: v5, initialCatalog: "sandbox" });
    expect(await screen.findByTestId("stays-installed")).toHaveTextContent("v5 stays installed in cat_x, cat_y.");
  });

  it("does not list the target itself", async () => {
    validates();
    installStatus = { data: { also_installed_in: [] } };
    renderDialog({ version: v5 });
    await waitFor(() => expect(validateMock).toHaveBeenCalled());
    expect(screen.queryByTestId("stays-installed")).toBeNull();
  });
});

describe("uninstall", () => {
  const DESTROYS = {
    field_path: "version_id", step_index: -1, severity: "confirm" as const,
    message: "Uninstalling v5 from cat_x drops 2 schemas and every table in them. 1 of 3 tables holds data.",
    subject: "uninstall_destroys_data:mv-5:cat_x",
  };
  const LIMITED = {
    ...DESTROYS,
    message: "Uninstalling v5 from cat_x drops its schemas and every table in them. Too many checks were started in the last minute, so whether they hold rows was not checked; treat them as holding data.",
  };

  it("needs the typed name for the server's subject and shows its message", async () => {
    validates([DESTROYS]);
    createMock.mockResolvedValue({ data: { id: "run-12", warnings: [] } });
    renderDialog({ intent: "uninstall", version: v5 });
    expect(await screen.findByTestId("confirm-issue-uninstall_destroys_data")).toHaveTextContent(DESTROYS.message);
    expect(screen.getByTestId("impact-mv-5-cat_x")).toHaveAttribute("data-require", "yes");
    fireEvent.click(screen.getByText("report impact"));
    expect(launchButton()).toBeDisabled();
    fireEvent.click(screen.getByText("type name"));
    await waitFor(() => expect(launchButton()).not.toBeDisabled());
    await act(async () => {
      fireEvent.click(launchButton());
    });
    expect(createMock).toHaveBeenCalledWith(
      { business_id: "b1" },
      { intent: "uninstall", version_id: "mv-5", catalog: "cat_x", confirmed_issues: ["uninstall_destroys_data:mv-5:cat_x"] },
    );
  });

  it("a cached 'no data' never confirms a subject the create's fresh scan asks", async () => {
    validates([]);
    impactState = { status: "ready", needsConfirmation: false, confirmed: true };
    createMock.mockRejectedValueOnce(
      new ApiError(422, "Unprocessable", { detail: { error: "needs_confirmation", issues: [DESTROYS], message: "cut" } }),
    );
    renderDialog({ intent: "uninstall", version: v5 });
    fireEvent.click(await screen.findByText("report impact"));
    await waitFor(() => expect(launchButton()).not.toBeDisabled());
    await act(async () => {
      fireEvent.click(launchButton());
    });
    expect(await screen.findByTestId("confirm-issue-uninstall_destroys_data")).toHaveTextContent(DESTROYS.message);
    expect(screen.getByTestId("impact-mv-5-cat_x")).toHaveAttribute("data-require", "yes");
    fireEvent.click(screen.getByText("report impact"));
    expect(launchButton()).toBeDisabled();
    fireEvent.click(screen.getByText("type name"));
    await waitFor(() => expect(launchButton()).not.toBeDisabled());
  });

  it("the rate-limited subject from validate needs the typed name too", async () => {
    validates([LIMITED]);
    impactState = { status: "ready", needsConfirmation: false, confirmed: true };
    renderDialog({ intent: "uninstall", version: v5 });
    expect(await screen.findByTestId("confirm-issue-uninstall_destroys_data")).toHaveTextContent(/Too many checks/);
    fireEvent.click(screen.getByText("report impact"));
    expect(launchButton()).toBeDisabled();
  });

  it("an empty impact with no subject needs no typed name", async () => {
    validates([]);
    impactState = { status: "ready", needsConfirmation: false, confirmed: true };
    renderDialog({ intent: "uninstall", version: v5 });
    fireEvent.click(await screen.findByText("report impact"));
    await waitFor(() => expect(launchButton()).not.toBeDisabled());
  });

  it("offers each install catalog when there are several", async () => {
    validates();
    installStatus = { data: { also_installed_in: ["cat_y"] } };
    renderDialog({ intent: "uninstall", version: v5 });
    fireEvent.click(await screen.findByRole("radio", { name: "cat_y" }));
    expect(await screen.findByTestId("impact-mv-5-cat_y")).toBeInTheDocument();
  });
});

describe("review fixes", () => {
  it("drops confirmations when the catalog changes", async () => {
    validates([OVER_NEWER]);
    renderDialog();
    fireEvent.click(await screen.findByTestId("confirm-install_over_newer"));
    expect(screen.getByTestId("confirm-install_over_newer")).toHaveAttribute("data-state", "checked");
    fireEvent.change(screen.getByLabelText("Deployment catalog"), { target: { value: "sandbox" } });
    await waitFor(() => expect(screen.getByTestId("confirm-install_over_newer")).toHaveAttribute("data-state", "unchecked"));
  });

  it("does not send a hidden 'also delete'", async () => {
    role = "business_admin";
    validateMock.mockImplementation(async (_p: unknown, body: { catalog?: string }) => ({
      data: { warnings: body.catalog === "sandbox" ? [] : [OVER_NEWER], blockers: [] },
    }));
    createMock.mockResolvedValue({ data: { id: "run-13", warnings: [] } });
    renderDialog();
    fireEvent.click(await screen.findByTestId("confirm-also_delete_replaced"));
    fireEvent.change(screen.getByLabelText("Deployment catalog"), { target: { value: "sandbox" } });
    await waitFor(() => expect(screen.queryByTestId("also-delete-replaced")).toBeNull());
    await waitFor(() => expect(launchButton()).not.toBeDisabled());
    await act(async () => {
      fireEvent.click(launchButton());
    });
    expect(createMock.mock.calls[0][1]).not.toHaveProperty("also_delete_replaced");
  });

  it("names the replaced versions from IssueOut.versions", async () => {
    role = "app_admin";
    validates([{ ...OVER_NEWER, message: "reworded by the server", versions: [4, 5] }]);
    renderDialog();
    expect(await screen.findByTestId("also-delete-replaced")).toHaveTextContent("Also delete v4 and v5 after the install");
  });

  it("'Pick another catalog' keeps the target, so the subject stays confirmable", async () => {
    validates([REPLACES]);
    renderDialog({ initialCatalog: "cat_x" });
    fireEvent.click(await screen.findByTestId("pick-another-catalog"));
    expect(screen.getByLabelText("Deployment catalog")).toHaveValue("cat_x");
    expect(screen.getByTestId("impact-mv-5-cat_x")).toBeInTheDocument();
  });
});
