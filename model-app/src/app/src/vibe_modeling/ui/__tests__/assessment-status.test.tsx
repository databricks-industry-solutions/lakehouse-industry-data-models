import { beforeEach, describe, expect, it, vi } from "vitest";
import { render, screen, fireEvent, waitFor, within } from "@testing-library/react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";

const navigate = vi.hoisted(() => vi.fn());
vi.mock("@tanstack/react-router", () => ({
  useNavigate: () => navigate,
  Link: ({ children, to, ...rest }: any) => <a href={String(to)} {...rest}>{children}</a>,
}));
vi.mock("@/components/explorer/breadcrumb-context", () => ({ useBreadcrumbs: vi.fn() }));
vi.mock("@/components/assessment/domain-results", () => ({
  DomainResults: ({ domainRunId }: any) => <div>results for {domainRunId}</div>,
}));

const assess = vi.hoisted(() => ({ ready: true }));
const api = vi.hoisted(() => ({
  useGetAssessConfig: vi.fn(() => ({
    data: { data: { installed: true, ready: assess.ready, missing: assess.ready ? [] : ["No reader service principal"] } },
    isLoading: false,
  })),
  useGetAssessmentSuspense: vi.fn(),
  useGetBusinessSuspense: vi.fn(() => ({ data: { id: "biz", name: "Meridian" } })),
  cancelAssessment: vi.fn(),
  cancelAssessmentDomainRun: vi.fn(),
  relaunchAssessment: vi.fn(),
}));
vi.mock("@/lib/api", async () => {
  const actual = await vi.importActual<typeof import("@/lib/api")>("@/lib/api");
  return { ...actual, ...api };
});

import { StatusBadge } from "@/components/assessment/status-badge";
import { DomainRunRow } from "@/components/assessment/domain-run-row";
import { BatchStatus } from "@/components/assessment/batch-status";
import { useBreadcrumbs } from "@/components/explorer/breadcrumb-context";
import { nextTryAt, retryClock } from "@/lib/retry-time";
import { ApiError } from "@/lib/api";
import { RelaunchButton } from "@/components/assessment/relaunch-button";

const run = (over: Record<string, unknown> = {}) => ({
  id: "r1", domain_id: "d1", domain_name: "sales_order", status: "assessing", attempt: 1,
  last_message: "Mapping entities", run_url: "https://ws/run/1", resume_at: null, stage: "", ...over,
});
const batch = (runs: any[]) => ({
  id: "b1", business_id: "biz", version: 2, scope: "mvm", status: "running", created_at: "2026-10-08T10:00:00Z",
  created_by: "me", etl_type: "dlt", output_model: "gpt-5.6-sol", reasoning_effort: "high", domain_runs: runs,
});

describe("StatusBadge", () => {
  it("renders a busy (rate-limited) run with its attempt and next try", () => {
    vi.useFakeTimers({ now: new Date("2026-10-08T14:10:00Z") });
    try {
      const resumeAt = "2026-10-08T14:30:00Z";
      render(<StatusBadge status="rate_limited" attempt={3} resumeAt={resumeAt} />);
      expect(screen.getByText(`Model busy · attempt 3 · next try in 20 min (${retryClock(resumeAt)})`)).toBeTruthy();
    } finally {
      vi.useRealTimers();
    }
  });
  it("uses the destructive variant for failed", () => {
    render(<StatusBadge status="failed" />);
    expect(screen.getByText("Failed").className).toContain("text-destructive");
  });
});

describe("DomainRunRow", () => {
  it("shows message, run link, and cancel when non-terminal", () => {
    const onCancel = vi.fn();
    render(<DomainRunRow run={run() as any} onCancel={onCancel} />);
    expect(screen.getByText("Mapping entities")).toBeTruthy();
    expect(screen.getByRole("link", { name: /open run/i }).getAttribute("href")).toBe("https://ws/run/1");
    fireEvent.click(screen.getByRole("button", { name: /cancel/i }));
    expect(onCancel).toHaveBeenCalledWith("r1");
  });
  it("shows the ingest retry from the structured fields, with the last error, and no Cancel", () => {
    vi.useFakeTimers({ now: new Date("2026-10-19T10:00:00Z") });
    try {
      render(<DomainRunRow run={run({
        status: "assessing", ingest_attempts: 2, ingest_max_attempts: 5, ingest_next_at: "2026-10-19T10:05:00Z",
        last_message: "OperationalError: timeout talking to Lakebase while writing assess_entity rows for the run",
      }) as any} onCancel={vi.fn()} />);
      const retry = screen.getByTestId("ingest-retry-r1");
      expect(retry).toHaveTextContent(`Saving results (attempt 2 of 5), next try in 5 min (${retryClock("2026-10-19T10:05:00Z")})`);
      const error = screen.getByText("OperationalError: timeout talking to Lakebase while writing assess_entity rows for the run");
      expect(error.className).not.toContain("truncate");
      expect(screen.queryByRole("button", { name: /cancel/i })).toBeNull();
    } finally {
      vi.useRealTimers();
    }
  });
  it("says only 'attempt n' when the backend gives no attempt limit", () => {
    render(<DomainRunRow run={run({ status: "assessing", ingest_attempts: 3, ingest_next_at: null, last_message: "boom" }) as any} onCancel={vi.fn()} />);
    expect(screen.getByTestId("ingest-retry-r1")).toHaveTextContent("Saving results (attempt 3), next try soon");
  });
  it("retryClock reads an offset-less timestamp as UTC", () => {
    expect(retryClock("2026-10-08T14:30:00")).toBe(retryClock("2026-10-08T14:30:00Z"));
    expect(retryClock(null)).toBe("");
    expect(nextTryAt(null)).toBe("next try soon");
  });
  it("a live run without ingest attempts keeps its message and Cancel", () => {
    render(<DomainRunRow run={run({ ingest_attempts: 0 }) as any} onCancel={vi.fn()} />);
    expect(screen.queryByTestId("ingest-retry-r1")).toBeNull();
    expect(screen.getByRole("button", { name: /cancel/i })).toBeTruthy();
  });
  it("hides cancel when terminal", () => {
    render(<DomainRunRow run={run({ status: "completed" }) as any} onCancel={vi.fn()} />);
    expect(screen.queryByRole("button", { name: /cancel/i })).toBeNull();
  });
});

describe("BatchStatus", () => {
  beforeEach(() => api.useGetAssessmentSuspense.mockReset());
  const mount = () =>
    render(
      <QueryClientProvider client={new QueryClient()}>
        <BatchStatus businessId="biz" batchId="b1" />
      </QueryClientProvider>,
    );
  const interval = (b: any) => {
    const opts = api.useGetAssessmentSuspense.mock.calls[0][0];
    return opts.query.refetchInterval({ state: { data: { data: b } } });
  };

  it("polls every 20s while a domain is running", () => {
    const b = batch([run()]);
    api.useGetAssessmentSuspense.mockReturnValue({ data: b });
    mount();
    expect(interval(b)).toBe(20000);
    expect(screen.getByText("Results appear when the run completes.")).toBeTruthy();
    expect(screen.getByRole("button", { name: /cancel all/i })).toBeTruthy();
  });
  it("keeps polling but offers no Cancel all while the only live run is retrying its save", () => {
    const b = batch([run({ status: "assessing", ingest_attempts: 1, ingest_next_at: null })]);
    api.useGetAssessmentSuspense.mockReturnValue({ data: b });
    mount();
    expect(interval(b)).toBe(20000);
    expect(screen.queryByRole("button", { name: /cancel all/i })).toBeNull();
  });
  it("stops polling when all terminal", () => {
    const b = batch([run({ status: "completed" })]);
    api.useGetAssessmentSuspense.mockReturnValue({ data: b });
    mount();
    expect(interval(b)).toBe(false);
    expect(screen.queryByRole("button", { name: /cancel all/i })).toBeNull();
  });
  it("starts the breadcrumb with the business name", () => {
    api.useGetAssessmentSuspense.mockReturnValue({ data: batch([run()]) });
    mount();
    const crumbs = (useBreadcrumbs as any).mock.calls.at(-1)[0];
    expect(crumbs.map((c: any) => c.label)).toEqual(["Meridian", "Assessments", "v2 mvm"]);
  });
  it("renders results for finished runs and the admin-help block for failed ones", () => {
    api.useGetAssessmentSuspense.mockReturnValue({
      data: batch([
        run({ id: "r1", status: "completed" }),
        run({
          id: "r2", domain_name: "x", status: "failed", error_message: "PERMISSION_DENIED: EXECUTE on gpt-5-6-sol",
          run_url: "https://ws/jobs/7/runs/9", job_url: "https://ws/jobs/7", job_reader: "reader-app-id",
        }),
      ]),
    });
    mount();
    expect(screen.getByText("results for r1")).toBeTruthy();
    fireEvent.mouseDown(screen.getByRole("tab", { name: "x" }), { button: 0 });
    fireEvent.click(screen.getByRole("tab", { name: "x" }));
    const block = within(screen.getByTestId("run-admin-help-r2"));
    expect(block.getByText("PERMISSION_DENIED: EXECUTE on gpt-5-6-sol")).toBeTruthy();
    expect(block.getByText("reader-app-id")).toBeTruthy();
    expect(block.getByRole("link", { name: /open job run/i }).getAttribute("href")).toBe("https://ws/jobs/7/runs/9");
    expect(block.getByRole("link", { name: /^open job$/i }).getAttribute("href")).toBe("https://ws/jobs/7");
  });
  it("a results_invalid run shows only the admin-help block, with the ingest lead and its files", () => {
    api.useGetAssessmentSuspense.mockReturnValue({
      data: batch([run({
        id: "r1", status: "results_invalid", results_valid: false,
        error_message: "Ingest failed 5 times: ValueError: bad doc", runs_path: "/Volumes/c/_metamodel/assess_runs/b1/d1",
        job_url: "https://ws/jobs/7", run_url: "https://ws/jobs/7/runs/9", job_reader: "rdr",
      })]),
    });
    mount();
    const block = within(screen.getByTestId("run-admin-help-r1"));
    expect(block.getByText(/The assessment finished but its results couldn't be saved\./)).toBeTruthy();
    expect(block.getByText("Ingest failed 5 times: ValueError: bad doc")).toBeTruthy();
    expect(block.getByText("/Volumes/c/_metamodel/assess_runs/b1/d1")).toBeTruthy();
    expect(block.getByRole("link", { name: /open job run/i }).getAttribute("href")).toBe("https://ws/jobs/7/runs/9");
    expect(screen.queryByText("results for r1")).toBeNull();
    expect(screen.queryByRole("tab", { name: /hand-off/i })).toBeNull();
  });
  it("keeps a plain no-results note for a cancelled run", () => {
    api.useGetAssessmentSuspense.mockReturnValue({ data: batch([run({ id: "r1", status: "cancelled" })]) });
    mount();
    expect(screen.getByText("No results are available for this run.")).toBeTruthy();
    expect(screen.queryByTestId("run-admin-help-r1")).toBeNull();
  });
  it("disables Cancel and Cancel all while the request is in flight", async () => {
    let release: () => void = () => {};
    api.cancelAssessment.mockReturnValue(new Promise<void>((r) => { release = r; }));
    api.cancelAssessmentDomainRun.mockReturnValue(new Promise<void>((r) => { release = r; }));
    api.useGetAssessmentSuspense.mockReturnValue({ data: batch([run()]) });
    mount();
    const all = screen.getByRole("button", { name: /cancel all/i });
    fireEvent.click(all);
    await waitFor(() => expect((all as HTMLButtonElement).disabled).toBe(true));
    fireEvent.click(all);
    expect(api.cancelAssessment).toHaveBeenCalledTimes(1);
    const one = screen.getByRole("button", { name: "Cancel" });
    fireEvent.click(one);
    await waitFor(() => expect((one as HTMLButtonElement).disabled).toBe(true));
    release();
  });
  it.each([
    ["Cancel", "cancelAssessmentDomainRun"],
    ["Cancel all", "cancelAssessment"],
  ] as const)("a refused %s shows the admin-help block with the run's links", async (label, fn) => {
    api[fn].mockRejectedValue(new ApiError(409, "Conflict", { detail: {
      error: "admin_help", message: "Databricks could not cancel run 9: denied",
      job_url: "https://ws/jobs/7", run_url: "https://ws/jobs/7/runs/9", job_reader: "rdr",
    } }));
    api.useGetAssessmentSuspense.mockReturnValue({ data: batch([run()]) });
    mount();
    fireEvent.click(screen.getByRole("button", { name: label }));
    const block = within(await screen.findByTestId("cancel-admin-help"));
    expect(block.getByText("Databricks could not cancel run 9: denied")).toBeTruthy();
    expect(block.getByRole("link", { name: /open job run/i }).getAttribute("href")).toBe("https://ws/jobs/7/runs/9");
  });
});

describe("Relaunch", () => {
  beforeEach(() => {
    assess.ready = true;
    api.useGetAssessmentSuspense.mockReset();
    api.relaunchAssessment.mockReset();
    navigate.mockReset();
  });
  const mount = () =>
    render(
      <QueryClientProvider client={new QueryClient()}>
        <BatchStatus businessId="biz" batchId="b1" />
      </QueryClientProvider>,
    );

  it("row button only on failed / cancelled / results_invalid", () => {
    for (const [status, shown] of [["failed", true], ["cancelled", true], ["results_invalid", true],
      ["completed", false], ["assessing", false]] as const) {
      const { unmount } = render(<DomainRunRow run={run({ status }) as any} onCancel={vi.fn()} onRelaunch={vi.fn()} />);
      expect(!!screen.queryByRole("button", { name: /^relaunch$/i })).toBe(shown);
      unmount();
    }
  });
  it("header shows the eligible count and relaunches with no body", async () => {
    const b = batch([run({ id: "r1", status: "failed" }), run({ id: "r2", status: "cancelled" }), run({ id: "r3", status: "completed" })]);
    api.useGetAssessmentSuspense.mockReturnValue({ data: b });
    api.relaunchAssessment.mockResolvedValue({ data: { id: "b2" } });
    mount();
    fireEvent.click(screen.getByRole("button", { name: /relaunch failed \(2\)/i }));
    await waitFor(() => expect(api.relaunchAssessment).toHaveBeenCalledWith({ batch_id: "b1" }, null));
    await waitFor(() =>
      expect(navigate).toHaveBeenCalledWith({
        to: "/businesses/$businessId/assessments/$batchId",
        params: { businessId: "biz", batchId: "b2" },
      }));
  });
  it("no header button when nothing is eligible", () => {
    api.useGetAssessmentSuspense.mockReturnValue({ data: batch([run({ status: "completed" })]) });
    mount();
    expect(screen.queryByRole("button", { name: /relaunch failed/i })).toBeNull();
  });
  it("per-row relaunch passes only that run id", async () => {
    api.useGetAssessmentSuspense.mockReturnValue({ data: batch([run({ id: "r1", status: "failed" }), run({ id: "r2", status: "failed", domain_name: "other" })]) });
    api.relaunchAssessment.mockResolvedValue({ data: { id: "b2" } });
    mount();
    fireEvent.click(screen.getAllByRole("button", { name: /^relaunch$/i })[1]);
    await waitFor(() => expect(api.relaunchAssessment).toHaveBeenCalledWith({ batch_id: "b1" }, { domain_run_ids: ["r2"] }));
  });
  it("409 blocked shows the message and readiness panel, no navigation", async () => {
    api.useGetAssessmentSuspense.mockReturnValue({ data: batch([run({ status: "failed" })]) });
    const readiness = {
      global_checks: [],
      domains: [{ domain_id: "d1", domain_name: "sales_order", blocked: true, checks: [
        { key: "bronze_select", label: "Bronze read access", state: "blocked", detail: "no SELECT", fix_sql: "", fix_action: "" }] }],
    };
    api.relaunchAssessment.mockRejectedValue(
      new ApiError(409, "Conflict", {
        detail: { error: "admin_help", message: "Assessment is blocked; resolve the failing checks.", readiness },
      }));
    mount();
    fireEvent.click(screen.getByRole("button", { name: /relaunch failed/i }));
    await waitFor(() => expect(screen.getByText("Bronze read access")).toBeTruthy());
    expect(screen.getByText("Assessment is blocked; resolve the failing checks.")).toBeTruthy();
    expect(navigate).not.toHaveBeenCalled();
  });
  it("shows the admin-help block for a launch refused as not ready", async () => {
    api.useGetAssessmentSuspense.mockReturnValue({ data: batch([run({ status: "failed" })]) });
    api.relaunchAssessment.mockRejectedValue(new ApiError(409, "Conflict", {
      detail: {
        error: "admin_help", message: "The last job sync failed: boom", job_url: "https://ws/jobs/7",
        not_ready: ["Job sync failed: boom"],
      },
    }));
    mount();
    fireEvent.click(screen.getByRole("button", { name: /relaunch failed/i }));
    const block = within(await screen.findByTestId("relaunch-admin-help"));
    expect(block.getByText("The last job sync failed: boom")).toBeTruthy();
    expect(block.getByText("Job sync failed: boom")).toBeTruthy();
    expect(block.getByRole("link", { name: /^open job$/i }).getAttribute("href")).toBe("https://ws/jobs/7");
    expect(navigate).not.toHaveBeenCalled();
  });
  it("hides every relaunch while the skill is not ready, and says why", () => {
    assess.ready = false;
    api.useGetAssessmentSuspense.mockReturnValue({ data: batch([run({ id: "r1", status: "failed" })]) });
    mount();
    expect(screen.queryByRole("button", { name: /relaunch/i })).toBeNull();
    expect(screen.getByTestId("feature-not-ready")).toBeTruthy();
    const { container } = render(<QueryClientProvider client={new QueryClient()}>
      <RelaunchButton businessId="biz" batch={batch([run({ status: "failed" })]) as any} /></QueryClientProvider>);
    expect(container.textContent).toBe("");
  });
  it("list-row relaunch shows a readiness block inline", async () => {
    const readiness = {
      global_checks: [],
      domains: [{ domain_id: "d1", domain_name: "sales_order", blocked: true, checks: [
        { key: "bronze_select", label: "Bronze read access", state: "blocked", detail: "no SELECT", fix_sql: "", fix_action: "" }] }],
    };
    api.relaunchAssessment.mockRejectedValue(new ApiError(409, "Conflict", {
      detail: { error: "admin_help", message: "Assessment is blocked; resolve the failing checks.", readiness },
    }));
    render(<QueryClientProvider client={new QueryClient()}>
      <RelaunchButton businessId="biz" batch={batch([run({ status: "failed" })]) as any} /></QueryClientProvider>);
    fireEvent.click(screen.getByRole("button", { name: /relaunch/i }));
    expect(await screen.findByText("Bronze read access")).toBeTruthy();
    expect(screen.getByText("Assessment is blocked; resolve the failing checks.")).toBeTruthy();
  });
  it("list-row relaunch shows an admin-help failure inline", async () => {
    api.relaunchAssessment.mockRejectedValue(new ApiError(409, "Conflict", {
      detail: { error: "admin_help", message: "Launch failed: assets unreadable", job_url: "https://ws/jobs/7" },
    }));
    render(<QueryClientProvider client={new QueryClient()}>
      <RelaunchButton businessId="biz" batch={batch([run({ status: "failed" })]) as any} /></QueryClientProvider>);
    fireEvent.click(screen.getByRole("button", { name: /relaunch/i }));
    expect(await screen.findByTestId("relaunch-admin-help-b1")).toHaveTextContent("Launch failed: assets unreadable");
  });
  it("list-row button appears only for batches with an eligible run and relaunches with no body", async () => {
    api.relaunchAssessment.mockResolvedValue({ data: { id: "b2" } });
    const ok = batch([run({ status: "completed" })]);
    const { container, unmount } = render(
      <QueryClientProvider client={new QueryClient()}><RelaunchButton businessId="biz" batch={ok as any} /></QueryClientProvider>);
    expect(container.textContent).toBe("");
    unmount();
    render(<QueryClientProvider client={new QueryClient()}>
      <RelaunchButton businessId="biz" batch={batch([run({ status: "failed" })]) as any} /></QueryClientProvider>);
    fireEvent.click(screen.getByRole("button", { name: /relaunch/i }));
    await waitFor(() => expect(api.relaunchAssessment).toHaveBeenCalledWith({ batch_id: "b1" }, null));
  });
});
