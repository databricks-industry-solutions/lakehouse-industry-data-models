import { describe, expect, it, vi, beforeEach } from "vitest";
import { render, screen, fireEvent, waitFor, within } from "@testing-library/react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";

const { putAssessConfig, state } = vi.hoisted(() => ({
  putAssessConfig: vi.fn(),
  state: { config: {} as Record<string, unknown> },
}));

vi.mock("@/lib/api", async () => {
  const actual = await vi.importActual<typeof import("@/lib/api")>("@/lib/api");
  return {
    ...actual,
    useGetAssessConfigSuspense: () => ({ data: state.config }),
    putAssessConfig,
    getAssessConfigKey: () => ["/api/assess/config"],
  };
});
vi.mock("sonner", () => ({ toast: { success: vi.fn(), error: vi.fn() } }));
vi.mock("@tanstack/react-router", () => ({
  Link: ({ children, to, search, ...rest }: any) => (
    <a href={`${to}${search?.tab ? `?tab=${search.tab}` : ""}`} {...rest}>{children}</a>
  ),
}));

import { ApiError } from "@/lib/api";
import { ASSESS_MODEL, ASSESS_MODEL_SERVICE } from "@/lib/assessment";
import { AssessSettings } from "@/components/assessment/assess-settings";

const unconfigured = {
  installed: true, ready: false, missing: ["No reader service principal"], job_url: "",
  reader_application_id: "", reader_display_name: "", job_id: null,
  workspace_path: "", max_concurrent_runs: 2,
  default_reasoning_effort: "high", warehouse_id: "", genie_version: "v0.1.0-beta.2",
  skills_ref: "4c709f704d4e4bc977aeb4379409fb709f2ab7e4", skills_version: "0.4.0",
  app_application_id: "",
};

function renderIt() {
  const qc = new QueryClient();
  return render(<QueryClientProvider client={qc}><AssessSettings /></QueryClientProvider>);
}

const typeReaderAndSave = (value = "app-1") => {
  fireEvent.change(screen.getByLabelText(/reader application id/i), { target: { value } });
  fireEvent.click(screen.getByRole("button", { name: /^save$/i }));
};

describe("AssessSettings setup checklist", () => {
  beforeEach(() => {
    state.config = { ...unconfigured };
  });

  it("renders the six INSTALL.md steps plus Save, expanded while not ready", () => {
    renderIt();
    expect(screen.getByTestId("assess-setup-steps")).toHaveProperty("open", true);
    const steps = screen.getAllByTestId(/^assess-setup-step-/);
    expect(steps).toHaveLength(6);
    expect(within(steps[0]).getByText(/databricks service-principals create --display-name vibe-assess-reader/)).toBeInTheDocument();
    expect(within(steps[0]).getByText(/Service Principal: User/)).toBeInTheDocument();
    expect(within(steps[1]).getByText(/GRANT USE CATALOG, USE SCHEMA, SELECT ON CATALOG `<model_catalog>`/)).toBeInTheDocument();
    expect(within(steps[1]).getByText(/Catalog-level grants cover schemas created later/)).toBeInTheDocument();
    expect(within(steps[2]).getByText(/GRANT USE CATALOG ON CATALOG `<deployment_catalog>`/)).toBeInTheDocument();
    expect(within(steps[3]).getByText(new RegExp(`grants update model_service ${ASSESS_MODEL_SERVICE}`))).toBeInTheDocument();
    expect(within(steps[4]).getByText(/github\.com egress/)).toBeInTheDocument();
    expect(within(steps[5]).getByText(/--assess-reader-sp/)).toBeInTheDocument();
  });

  it("no longer asks for the grants the installer and Save already make", () => {
    renderIt();
    const steps = screen.getByTestId("assess-setup-steps");
    expect(within(steps).queryByText(/GRANT CREATE VOLUME/)).toBeNull();
    expect(within(steps).queryByText(/Let the app create its runs volume/)).toBeNull();
  });

  it("calls out the shared model rate limit under Max concurrent runs", () => {
    renderIt();
    expect(screen.getByText(new RegExp(`share the workspace's ${ASSESS_MODEL} rate limit`))).toBeInTheDocument();
    expect(screen.getByText(/Databricks account team/)).toBeInTheDocument();
  });

  it("collapses the checklist once ready", () => {
    state.config = { ...unconfigured, ready: true, missing: [], reader_application_id: "app-1" };
    renderIt();
    expect(screen.getByTestId("assess-setup-steps")).toHaveProperty("open", false);
  });

  it("substitutes the typed application id and warehouse id into the snippets live", () => {
    renderIt();
    expect(screen.getAllByText(/<reader-application-id>/).length).toBeGreaterThan(0);
    fireEvent.change(screen.getByLabelText(/reader application id/i), { target: { value: "1234-abcd" } });
    fireEvent.change(screen.getByLabelText(/sql warehouse id/i), { target: { value: "wh-9" } });
    expect(screen.queryByText(/<reader-application-id>/)).toBeNull();
    expect(screen.queryByText(/<warehouse-id>/)).toBeNull();
    expect(screen.getByText(/GRANT USE CATALOG ON CATALOG `<deployment_catalog>` TO `1234-abcd`;/)).toBeInTheDocument();
    expect(screen.getByText(/warehouses update-permissions wh-9 /)).toBeInTheDocument();
    // catalog placeholders are left for the user.
    expect(screen.getAllByText(/<source_catalog>/).length).toBeGreaterThan(0);
  });

  it("copy buttons write the substituted text to the clipboard", async () => {
    const writeText = vi.fn().mockResolvedValue(undefined);
    Object.defineProperty(navigator, "clipboard", { value: { writeText }, configurable: true });
    renderIt();
    fireEvent.change(screen.getByLabelText(/reader application id/i), { target: { value: "1234-abcd" } });
    const buttons = within(screen.getByTestId("assess-setup-step-4")).getAllByRole("button", { name: /copy/i });
    fireEvent.click(buttons[0]);
    await waitFor(() => expect(writeText).toHaveBeenCalled());
    const text = writeText.mock.calls[0][0] as string;
    expect(text).toContain('"principal":"1234-abcd"');
    expect(text).not.toContain("<reader-application-id>");
  });

  it("names the app's service principal in step 1 when its id is known", () => {
    state.config = { ...unconfigured, app_application_id: "aeae7e5c-1111" };
    renderIt();
    expect(screen.getByText(/pick the app's service principal \(Application ID aeae7e5c-1111\)/)).toBeInTheDocument();
    expect(screen.getByText(/This app runs as service principal/)).toBeInTheDocument();
  });

  it("keeps the fallback text when the app id is unknown", () => {
    renderIt();
    expect(screen.getByText(/look for the app's name/)).toBeInTheDocument();
    expect(screen.queryByText(/This app runs as service principal/)).toBeNull();
  });
});

describe("AssessSettings status", () => {
  beforeEach(() => {
    state.config = { ...unconfigured };
  });

  it("lists every `missing` reason as an error StatusLine", () => {
    state.config = {
      ...unconfigured, reader_application_id: "app-1",
      missing: ["Job sync failed: PermissionDenied", "The assessment job does not run as the configured reader"],
    };
    renderIt();
    const lines = within(screen.getByTestId("assess-missing")).getAllByText(/./, { selector: "span" });
    expect(lines.map((l) => l.textContent)).toEqual([
      "Job sync failed: PermissionDenied",
      "The assessment job does not run as the configured reader",
    ]);
    const tone = screen.getByText("Job sync failed: PermissionDenied").closest("[data-tone]");
    expect(tone).toHaveAttribute("data-tone", "error");
    expect(tone?.className).toContain("text-destructive");
  });

  it("shows no missing lines once ready", () => {
    state.config = { ...unconfigured, ready: true, missing: [], reader_application_id: "app-1" };
    renderIt();
    expect(screen.queryByTestId("assess-missing")).toBeNull();
  });

  it("links the job when there is one", () => {
    state.config = { ...unconfigured, job_id: 42, job_url: "https://ws/jobs/42?o=1" };
    renderIt();
    expect(screen.getByRole("link", { name: /open job/i })).toHaveAttribute("href", "https://ws/jobs/42?o=1");
  });

  it("shows ready status details", () => {
    state.config = { ...unconfigured, ready: true, missing: [], reader_application_id: "app-1", job_id: 42, workspace_path: "/Workspace/x" };
    renderIt();
    expect(screen.queryByTestId("assess-missing")).toBeNull();
    expect(screen.getByText("42")).toBeInTheDocument();
    expect(screen.getByText(/4c709f7/)).toBeInTheDocument();
  });

  it("lists what is missing while the setup is incomplete", () => {
    renderIt();
    expect(screen.getByTestId("assess-missing")).toHaveTextContent("No reader service principal");
  });
});

describe("AssessSettings save", () => {
  beforeEach(() => {
    putAssessConfig.mockReset();
    state.config = { ...unconfigured };
  });

  it("saves the reader application id and confirms inline", async () => {
    putAssessConfig.mockResolvedValue({ data: { ...unconfigured, ready: true, missing: [] } });
    renderIt();
    typeReaderAndSave();
    await waitFor(() =>
      expect(putAssessConfig).toHaveBeenCalledWith({
        reader_application_id: "app-1", max_concurrent_runs: 2,
        default_reasoning_effort: "high", warehouse_id: "",
      }),
    );
    expect(await screen.findByText("Assessment settings saved")).toBeInTheDocument();
    expect(screen.queryByTestId("assess-save-error")).toBeNull();
  });

  it.each([
    ["reader_application_id", /reader application id/i],
    ["warehouse_id", /sql warehouse id/i],
  ])("a 400 setting_refused for %s highlights and focuses that field, with its message under it", async (key, label) => {
    putAssessConfig.mockRejectedValue(new ApiError(400, "Bad Request", {
      detail: { error: "setting_refused", key, message: "Not found in this workspace" },
    }));
    renderIt();
    typeReaderAndSave("bad");
    const line = await screen.findByTestId(`assess-refused-${key}`);
    expect(line).toHaveTextContent("Not found in this workspace");
    expect(line.getAttribute("data-tone")).toBe("error");
    const field = screen.getByLabelText(label);
    expect(field).toHaveAttribute("aria-invalid", "true");
    expect(field.getAttribute("aria-describedby")).toBe(line.id);
    expect(field.className).toContain("border-destructive");
    await waitFor(() => expect(document.activeElement).toBe(field));
    expect(screen.queryByTestId("assess-save-error")).toBeNull();
    expect(screen.queryByTestId("assess-save-admin-help")).toBeNull();
  });

  it("editing a refused field clears its error at once", async () => {
    putAssessConfig.mockRejectedValue(new ApiError(400, "Bad Request", {
      detail: { error: "setting_refused", key: "reader_application_id", message: "Not found in this workspace" },
    }));
    renderIt();
    typeReaderAndSave("bad");
    await screen.findByTestId("assess-refused-reader_application_id");
    const field = screen.getByLabelText(/reader application id/i);
    fireEvent.change(field, { target: { value: "good-id" } });
    expect((field as HTMLInputElement).value).toBe("good-id");
    expect(screen.queryByTestId("assess-refused-reader_application_id")).toBeNull();
    expect(field).not.toHaveAttribute("aria-invalid");
    expect(field.className).not.toContain("border-destructive");
  });

  it("editing another field keeps the refused field's error", async () => {
    putAssessConfig.mockRejectedValue(new ApiError(400, "Bad Request", {
      detail: { error: "setting_refused", key: "warehouse_id", message: "No such warehouse" },
    }));
    renderIt();
    typeReaderAndSave("app-1");
    await screen.findByTestId("assess-refused-warehouse_id");
    fireEvent.change(screen.getByLabelText(/reader application id/i), { target: { value: "app-2" } });
    expect(screen.getByTestId("assess-refused-warehouse_id")).toBeInTheDocument();
  });

  it("a 422 config_missing shows its message with the Settings link, no field highlighted", async () => {
    putAssessConfig.mockRejectedValue(new ApiError(422, "Unprocessable Entity", {
      detail: {
        error: "config_missing",
        missing: [{ key: "metamodel_catalog", label: "Metamodel catalog", settings_url: "/settings?tab=platform" }],
        message: "Missing required configuration: Metamodel catalog. Configure it in Settings, then retry.",
      },
    }));
    renderIt();
    typeReaderAndSave();
    const notice = within(await screen.findByTestId("assess-save-config-missing"));
    expect(notice.getByText(/Missing required configuration: Metamodel catalog/)).toBeInTheDocument();
    expect(notice.getByRole("link", { name: "Configure" })).toHaveAttribute("href", "/settings?tab=platform");
    expect(screen.getByLabelText(/reader application id/i)).not.toHaveAttribute("aria-invalid");
    expect(screen.queryByTestId("assess-save-error")).toBeNull();
  });

  it("shows a 409 sync failure as SaveErrorBox plus the copyable admin-help block", async () => {
    const writeText = vi.fn().mockResolvedValue(undefined);
    Object.defineProperty(navigator, "clipboard", { value: { writeText }, configurable: true });
    putAssessConfig.mockRejectedValue(new ApiError(409, "Conflict", {
      detail: { error: "admin_help", message: "The assessment job sync failed: PermissionDenied", job_url: "https://ws/jobs/42" },
    }));
    renderIt();
    typeReaderAndSave();
    expect(await screen.findByTestId("assess-save-error")).toHaveTextContent("Couldn't save the assessment settings.");
    expect(screen.getByTestId("assess-save-admin-help")).toHaveAttribute("role", "alert");
    const block = within(screen.getByTestId("assess-save-admin-help"));
    expect(block.getByText("The assessment job sync failed: PermissionDenied")).toBeInTheDocument();
    fireEvent.click(block.getByRole("button", { name: /copy details/i }));
    await waitFor(() => expect(writeText).toHaveBeenCalled());
    expect(writeText.mock.calls[0][0]).toBe(
      [
        "Saving these settings failed. Please contact your administrator with these details.",
        "The assessment job sync failed: PermissionDenied",
        "Job: https://ws/jobs/42",
      ].join("\n"),
    );
  });

  it("clears an earlier error on the next successful save", async () => {
    putAssessConfig.mockRejectedValueOnce(new ApiError(400, "Bad Request", {
      detail: { error: "setting_refused", key: "reader_application_id", message: "nope" },
    }));
    putAssessConfig.mockResolvedValueOnce({ data: { ...unconfigured } });
    renderIt();
    typeReaderAndSave();
    expect(await screen.findByTestId("assess-refused-reader_application_id")).toBeInTheDocument();
    fireEvent.click(screen.getByRole("button", { name: /^save$/i }));
    await waitFor(() => expect(screen.queryByTestId("assess-refused-reader_application_id")).toBeNull());
    expect(screen.getByLabelText(/reader application id/i)).not.toHaveAttribute("aria-invalid");
  });
});
