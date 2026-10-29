import { beforeEach, describe, expect, it, vi } from "vitest";
import { render, screen, fireEvent, waitFor, within } from "@testing-library/react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";

const api = vi.hoisted(() => ({
  useGetAssessmentHandoffSuspense: vi.fn(),
  createAssessmentHandoff: vi.fn(),
}));
vi.mock("@/lib/api", async () => {
  const actual = await vi.importActual<typeof import("@/lib/api")>("@/lib/api");
  return { ...actual, ...api };
});
const copyToast = vi.hoisted(() => vi.fn());
vi.mock("sonner", () => ({ toast: { success: copyToast, error: vi.fn() } }));

import { HandoffPanel } from "@/components/assessment/handoff-panel";

const ROOT = "/Workspace/Users/dana@example.com/vibe-assess/Meridian/sales_order/b1";
const handoff = (over: Record<string, unknown> = {}) => ({
  domain_run_id: "r1", path: ROOT, created_at: null, created_by: "", folder_url: `https://ws/#workspace${ROOT}`,
  next_steps: [],
  prompts: [
    // The backend numbers the titles (handoff.build_prompts).
    { key: "continue", title: "1. Continue the assessment", skill: "domain-model-assessment", prompt: `continue prompt ${ROOT}` },
    { key: "build", title: "2. Build", skill: "etl-development-framework", prompt: "build prompt" },
    { key: "validate", title: "3. Validate", skill: "domain-model-validation", prompt: "validate prompt" },
    { key: "document", title: "4. Document", skill: "domain-documentation", prompt: "document prompt" },
  ],
  skills: [
    { name: "domain-model-assessment", state: "present" },
    { name: "domain-sync", state: "missing" },
    { name: "autonomous-validation", state: "unknown" },
  ],
  user_scope_note: "Your user-level skills can't be checked by the app.",
  expected_handoffs: ["conventions.yml"],
  ...over,
});

const mount = () =>
  render(
    <QueryClientProvider client={new QueryClient()}>
      <HandoffPanel domainRunId="r1" />
    </QueryClientProvider>,
  );

describe("HandoffPanel", () => {
  beforeEach(() => {
    Object.values(api).forEach((f) => f.mockReset());
    copyToast.mockReset();
    api.useGetAssessmentHandoffSuspense.mockReturnValue({ data: handoff() });
    Object.assign(navigator, { clipboard: { writeText: vi.fn().mockResolvedValue(undefined) } });
  });

  it("shows the default path, copies to workspace, then reports where", async () => {
    api.createAssessmentHandoff.mockResolvedValue({
      data: handoff({ path: `${ROOT}2`, created_at: "2026-10-09T10:00:00Z", created_by: "dana@example.com", folder_url: "https://ws/#workspace/x" }),
    });
    mount();
    const input = screen.getByLabelText("Workspace folder") as HTMLInputElement;
    expect(input.value).toBe(ROOT);
    fireEvent.change(input, { target: { value: `${ROOT}2` } });
    fireEvent.click(screen.getByRole("button", { name: "Copy to workspace" }));
    await waitFor(() =>
      expect(api.createAssessmentHandoff).toHaveBeenCalledWith({ domain_run_id: "r1" }, { path: `${ROOT}2` }),
    );
    expect(await screen.findByText(new RegExp(`Copied to ${ROOT}2 at`))).toBeTruthy();
    expect(screen.getByRole("link", { name: /open folder/i }).getAttribute("href")).toBe("https://ws/#workspace/x");
  });

  it("shows the admin-help block with the runs folder when the copy fails", async () => {
    const { ApiError } = await import("@/lib/api");
    api.createAssessmentHandoff.mockRejectedValue(
      new ApiError(409, "Conflict", {
        detail: {
          error: "admin_help", message: "Hand-off needs the workspace scope: re-consent", job_url: "https://ws/jobs/7",
          run_url: "https://ws/jobs/7/runs/9", runs_path: "/Volumes/cat/_metamodel/assess_runs/b1/d1",
        },
      }),
    );
    mount();
    fireEvent.click(screen.getByRole("button", { name: "Copy to workspace" }));
    const block = within(await screen.findByTestId("handoff-admin-help"));
    expect(block.getByText("Hand-off needs the workspace scope: re-consent")).toBeTruthy();
    expect(block.getByText("/Volumes/cat/_metamodel/assess_runs/b1/d1")).toBeTruthy();
    fireEvent.click(block.getByRole("button", { name: /copy details/i }));
    await waitFor(() =>
      expect(navigator.clipboard.writeText).toHaveBeenCalledWith(
        expect.stringContaining("Files: /Volumes/cat/_metamodel/assess_runs/b1/d1"),
      ),
    );
    expect(screen.queryByText(/Copied to/)).toBeNull();
  });

  it("renders four prompt blocks in order, each copyable", async () => {
    mount();
    const titles = ["1. Continue the assessment", "2. Build", "3. Validate", "4. Document"];
    const buttons = titles.map((t) => screen.getByRole("button", { name: `Copy ${t}` }));
    expect(buttons).toHaveLength(4);
    const order = screen.getAllByText(/^\d\. /).map((n) => n.textContent);
    expect(order).toEqual([
      "1. Continue the assessment (domain-model-assessment)",
      "2. Build (etl-development-framework)",
      "3. Validate (domain-model-validation)",
      "4. Document (domain-documentation)",
    ]);
    expect(screen.queryByText(/\d\. \d\. /)).toBeNull();
    fireEvent.click(buttons[1]);
    await waitFor(() => expect(navigator.clipboard.writeText).toHaveBeenCalledWith("build prompt"));
    expect(copyToast).toHaveBeenCalledWith("Copied to clipboard");
  });

  it("lists skill state badges and the user-scope note", () => {
    mount();
    const li = (name: string) => screen.getByText(name).closest("li")!;
    expect(within(li("domain-model-assessment")).getByText("Installed")).toBeTruthy();
    expect(within(li("domain-sync")).getByText("Missing")).toBeTruthy();
    expect(within(li("autonomous-validation")).getByText("Unknown")).toBeTruthy();
    expect(screen.getByText("Your user-level skills can't be checked by the app.")).toBeTruthy();
  });

  it("labels the folder input visibly and gives it a placeholder when there is no default path", () => {
    api.useGetAssessmentHandoffSuspense.mockReturnValue({ data: handoff({ path: null }) });
    mount();
    const input = screen.getByLabelText("Workspace folder") as HTMLInputElement;
    expect(input.value).toBe("");
    expect(input.placeholder).toBe("/Workspace/Users/<your email>/vibe-assess");
    expect(screen.getByText("Workspace folder").tagName).toBe("LABEL");
    expect(screen.getByRole("button", { name: "Copy to workspace" })).toBeDisabled();
    fireEvent.change(input, { target: { value: "/Workspace/Users/dana@example.com/x" } });
    expect(input.value).toBe("/Workspace/Users/dana@example.com/x");
    expect(screen.getByRole("button", { name: "Copy to workspace" })).toBeEnabled();
  });

  it("states that next vibes are not imported automatically", () => {
    mount();
    expect(screen.getByText(/not imported automatically/i)).toBeTruthy();
  });
});
