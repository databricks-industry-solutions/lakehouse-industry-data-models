import { beforeEach, describe, expect, it, vi } from "vitest";
import { render, screen, fireEvent, waitFor, within } from "@testing-library/react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";

const api = vi.hoisted(() => ({
  useGetAssessmentHandoffSuspense: vi.fn(),
  createAssessmentHandoff: vi.fn(),
  installAssessmentSkills: vi.fn(),
}));
vi.mock("@/lib/api", async () => {
  const actual = await vi.importActual<typeof import("@/lib/api")>("@/lib/api");
  return { ...actual, ...api };
});
const toasts = vi.hoisted(() => ({ success: vi.fn(), error: vi.fn() }));
vi.mock("sonner", () => ({ toast: toasts }));

import { ApiError, getAssessmentHandoffKey } from "@/lib/api";
import { HandoffPanel } from "@/components/assessment/handoff-panel";

const skill = (name: string, state: string, location = "user") => ({
  name, state, location, bundled_version: "0.4.0", installed_version: state === "missing" ? "" : "0.3.0",
});
const handoff = (over: Record<string, unknown> = {}) => ({
  domain_run_id: "r1", path: "/Workspace/x", created_at: null, created_by: "", folder_url: "https://ws/x",
  next_steps: [
    { order: 1, title: "Answer 2 blocking decisions", detail: "Building is gated on these answers.", done: false },
    { order: 2, title: "Copy the assessment to your workspace", detail: "Copies conventions.yml.", done: over.created_at != null },
    { order: 3, title: "In Genie Code, run Continue", detail: "Paste the four prompts in order.", done: false },
  ],
  prompts: [],
  skills: [skill("domain-model-assessment", "present"), skill("domain-sync", "missing"), skill("etl-development-framework", "update_available")],
  user_scope_note: "note",
  expected_handoffs: [],
  ...over,
});

let qc: QueryClient;
const mount = () => {
  qc = new QueryClient();
  return render(
    <QueryClientProvider client={qc}>
      <HandoffPanel domainRunId="r1" />
    </QueryClientProvider>,
  );
};

let invalidate: ReturnType<typeof vi.spyOn>;

describe("HandoffPanel next steps + skill install", () => {
  beforeEach(() => {
    Object.values(api).forEach((f) => f.mockReset());
    Object.values(toasts).forEach((f) => f.mockReset());
    api.useGetAssessmentHandoffSuspense.mockReturnValue({ data: handoff() });
    invalidate = vi.spyOn(QueryClient.prototype, "invalidateQueries").mockResolvedValue(undefined);
  });

  it("renders What to do next with the steps in order", () => {
    mount();
    expect(screen.getByText("What to do next")).toBeTruthy();
    const items = screen.getAllByTestId("next-step").map((n) => n.textContent ?? "");
    expect(items).toHaveLength(3);
    expect(items[0]).toContain("Answer 2 blocking decisions");
    expect(items[1]).toContain("Copy the assessment");
    expect(items[2]).toContain("run Continue");
  });

  it("marks the copy step done once copied", () => {
    api.useGetAssessmentHandoffSuspense.mockReturnValue({ data: handoff({ created_at: "2026-10-13T10:00:00Z" }) });
    mount();
    const items = screen.getAllByTestId("next-step");
    expect(within(items[1]).getByLabelText("done")).toBeTruthy();
    expect(within(items[0]).queryByLabelText("done")).toBeNull();
  });

  it("shows state badges and location", () => {
    mount();
    const li = (n: string) => screen.getByText(n).closest("li")!;
    expect(within(li("domain-model-assessment")).getByText("Installed")).toBeTruthy();
    expect(within(li("domain-sync")).getByText("Missing")).toBeTruthy();
    expect(within(li("etl-development-framework")).getByText("Update available")).toBeTruthy();
    expect(within(li("domain-model-assessment")).getByText("in your folder")).toBeTruthy();
  });

  it("installs missing skills with {} then refetches", async () => {
    api.installAssessmentSkills.mockResolvedValue({ data: { installed: ["domain-sync"], updated: [], skipped: [], skills: [] } });
    mount();
    fireEvent.click(screen.getByRole("button", { name: "Install / update skills" }));
    await waitFor(() => expect(api.installAssessmentSkills).toHaveBeenCalledWith({ domain_run_id: "r1" }, { update: ["etl-development-framework"], names: [] }));
    await waitFor(() => expect(toasts.success).toHaveBeenCalledWith("Installed 1, updated 0"));
    await waitFor(() => expect(invalidate).toHaveBeenCalled());
  });

  it("says nothing to install when nothing changed", async () => {
    api.installAssessmentSkills.mockResolvedValue({ data: { installed: [], updated: [], skipped: [], skills: [] } });
    mount();
    fireEvent.click(screen.getByRole("button", { name: "Install / update skills" }));
    await waitFor(() => expect(toasts.success).toHaveBeenCalledWith("Nothing to install"));
  });

  it("shows the skills note and offers Re-check when a skill state is unknown", async () => {
    api.useGetAssessmentHandoffSuspense.mockReturnValue({
      data: handoff({
        skills: [skill("domain-sync", "unknown", "none")],
        skills_note: "Couldn't read your skills folder: TEMPORARILY_UNAVAILABLE",
      }),
    });
    mount();
    expect(screen.getByTestId("skills-note").textContent).toContain("Couldn't read your skills folder: TEMPORARILY_UNAVAILABLE");
    fireEvent.click(screen.getByRole("button", { name: "Re-check" }));
    await waitFor(() => expect(invalidate).toHaveBeenCalled());
  });

  it("shows no skills note when every folder was read", () => {
    mount();
    expect(screen.queryByTestId("skills-note")).toBeNull();
  });

  it("updates one skill with {update:[name]}", async () => {
    api.installAssessmentSkills.mockResolvedValue({ data: { installed: [], updated: ["etl-development-framework"], skipped: [], skills: [] } });
    mount();
    fireEvent.click(screen.getByRole("button", { name: "Update etl-development-framework" }));
    await waitFor(() =>
      expect(api.installAssessmentSkills).toHaveBeenCalledWith({ domain_run_id: "r1" }, { update: ["etl-development-framework"] }),
    );
  });

  it("toasts an error that isn't admin_help", async () => {
    api.installAssessmentSkills.mockRejectedValue(
      new ApiError(409, "Conflict", { detail: "Sign in through the deployed app to install skills." }),
    );
    mount();
    fireEvent.click(screen.getByRole("button", { name: "Install / update skills" }));
    await waitFor(() => expect(toasts.error).toHaveBeenCalled());
    expect(screen.queryByTestId("install-skills-admin-help")).toBeNull();
    await waitFor(() => expect(invalidate).toHaveBeenCalled());
  });

  it("shows the copyable admin-help block when install-skills answers admin_help", async () => {
    api.installAssessmentSkills.mockRejectedValue(
      new ApiError(409, "Conflict", {
        detail: {
          error: "admin_help", message: "Couldn't install skills: PERMISSION_DENIED",
          job_url: "https://ws/jobs/7", run_url: "https://ws/jobs/7/runs/9", job_reader: "reader-app-id",
        },
      }),
    );
    mount();
    fireEvent.click(screen.getByRole("button", { name: "Install / update skills" }));
    const block = within(await screen.findByTestId("install-skills-admin-help"));
    expect(block.getByText("Couldn't install skills: PERMISSION_DENIED")).toBeTruthy();
    expect(block.getByText("reader-app-id")).toBeTruthy();
    expect(block.getByRole("link", { name: /open job run/i }).getAttribute("href")).toBe("https://ws/jobs/7/runs/9");
    expect(toasts.error).not.toHaveBeenCalled();
    await waitFor(() => expect(invalidate).toHaveBeenCalled());
  });

  it("hides the action button when every skill is present", () => {
    api.useGetAssessmentHandoffSuspense.mockReturnValue({
      data: handoff({ skills: [skill("domain-sync", "present")] }),
    });
    mount();
    expect(screen.queryByRole("button", { name: /skills for me|Update skills|Try installing skills/ })).toBeNull();
  });

  it("offers Update skills when all are update_available and posts them", async () => {
    api.useGetAssessmentHandoffSuspense.mockReturnValue({
      data: handoff({ skills: [skill("a", "update_available"), skill("b", "update_available"), skill("c", "present")] }),
    });
    api.installAssessmentSkills.mockResolvedValue({ data: { installed: [], updated: ["a", "b"], skipped: [], skills: [] } });
    mount();
    fireEvent.click(screen.getByRole("button", { name: "Update skills" }));
    await waitFor(() => expect(api.installAssessmentSkills).toHaveBeenCalledWith({ domain_run_id: "r1" }, { update: ["a", "b"], names: [] }));
  });

  it("offers Try installing skills when all are unknown", async () => {
    api.useGetAssessmentHandoffSuspense.mockReturnValue({
      data: handoff({ skills: [skill("a", "unknown", "none"), skill("b", "unknown", "none")] }),
    });
    api.installAssessmentSkills.mockResolvedValue({ data: { installed: [], updated: ["a", "b"], skipped: [], skills: [] } });
    mount();
    fireEvent.click(screen.getByRole("button", { name: "Try installing skills" }));
    await waitFor(() => expect(api.installAssessmentSkills).toHaveBeenCalledWith({ domain_run_id: "r1" }, { update: ["a", "b"], names: [] }));
  });

  it("shows the re-consent note the backend sends for a scope error", () => {
    api.useGetAssessmentHandoffSuspense.mockReturnValue({
      data: handoff({ skills_note: "The app needs one more permission to write to your skills folder." }),
    });
    mount();
    expect(screen.getByTestId("skills-note").textContent).toContain("The app needs one more permission");
  });

  it("pure install shows Install skills for me without the overwrite note", () => {
    api.useGetAssessmentHandoffSuspense.mockReturnValue({ data: handoff({ skills: [skill("a", "missing", "none")] }) });
    mount();
    expect(screen.getByRole("button", { name: "Install skills for me" })).toBeTruthy();
    expect(screen.queryByText(/Replaces the listed skills/)).toBeNull();
  });

  it("overwrite note shows when updating", () => {
    mount();
    expect(screen.getByText(/Replaces the listed skills/)).toBeTruthy();
  });

  it("Re-check toasts an error, not stale counts, when the refetch fails", async () => {
    invalidate.mockRejectedValue(new Error("boom"));
    mount();
    fireEvent.click(screen.getByRole("button", { name: "Re-check" }));
    await waitFor(() => expect(toasts.error).toHaveBeenCalled());
    expect(toasts.success).not.toHaveBeenCalled();
  });

  it.each([
    [[skill("a", "present")], "All skills up to date"],
    [[skill("a", "update_available"), skill("b", "missing"), skill("c", "present")], "1 missing, 1 needs an update"],
    [[skill("a", "unknown", "none"), skill("b", "unknown", "none")], "Couldn't read 2 skills"],
  ])("Re-check toasts the outcome", async (skills, msg) => {
    api.useGetAssessmentHandoffSuspense.mockReturnValue({ data: handoff({ skills: [skill("z", "unknown", "none")] }) });
    invalidate.mockImplementation(async () => {
      qc.setQueryData(getAssessmentHandoffKey({ domain_run_id: "r1" }), { data: handoff({ skills }) });
    });
    mount();
    fireEvent.click(screen.getByRole("button", { name: "Re-check" }));
    await waitFor(() => expect(toasts.success).toHaveBeenCalledWith(msg));
  });
});
