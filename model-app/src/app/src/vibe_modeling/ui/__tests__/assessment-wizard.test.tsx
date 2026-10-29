import { beforeEach, describe, expect, it, vi } from "vitest";
import { render, screen, fireEvent, waitFor } from "@testing-library/react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { Suspense } from "react";

const navigate = vi.fn();
vi.mock("@tanstack/react-router", () => ({
  useNavigate: () => navigate,
  Link: ({ children, to, ...rest }: any) => <a href={String(to)} {...rest}>{children}</a>,
}));

const api = vi.hoisted(() => ({
  checkAssessReadiness: vi.fn(),
  launchAssessment: vi.fn(),
  putAssessSourceMap: vi.fn(),
}));

const saved = [{ source_name: "src_sap", catalog_name: "raw", schema_name: "sap" }];
let savedNow: typeof saved | [] = saved;

vi.mock("@/lib/api", async () => {
  const actual = await vi.importActual<typeof import("@/lib/api")>("@/lib/api");
  return {
    ...actual,
    ...api,
    useListVersionsSuspense: () => ({
      data: [
        { id: "v2", version: 2, scope: "mvm", status: "completed", deployment_status: "deployed", uc_catalog: "mvm_cat" },
        { id: "v1", version: 1, scope: "ecm", status: "completed", deployment_status: "draft", uc_catalog: "" },
      ],
    }),
    useGetModelSummarySuspense: () => ({
      data: {
        name: "m",
        domains: [
          { id: "d1", name: "sales_order" },
          { id: "d2", name: "customer" },
        ],
      },
    }),
    useGetAssessSourceMapSuspense: () => ({ data: { sources: savedNow } }),
    useGetAssessConfig: () => ({ data: { default_reasoning_effort: "medium" } }),
  };
});

import { ASSESS_MODEL } from "@/lib/assessment";
import { AssessmentWizard } from "@/components/assessment/assessment-wizard";

const okReadiness = { global_checks: [], domains: [{ domain_id: "d1", domain_name: "sales_order", blocked: false, checks: [] }] };
const blockedReadiness = {
  global_checks: [],
  domains: [{
    domain_id: "d1", domain_name: "sales_order", blocked: true,
    checks: [{ key: "model_read", label: "Model catalog", state: "blocked", detail: "no read", fix_sql: "", fix_action: "" }],
  }],
};

function mount(props: { versionId?: string; domainId?: string } = { versionId: "v2", domainId: "d1" }) {
  const qc = new QueryClient({ defaultOptions: { queries: { retry: false } } });
  return render(
    <QueryClientProvider client={qc}>
      <Suspense fallback={null}>
        <AssessmentWizard businessId="b1" {...props} />
      </Suspense>
    </QueryClientProvider>,
  );
}

const launchBtn = () => screen.getByRole("button", { name: /^launch/i }) as HTMLButtonElement;

beforeEach(() => {
  savedNow = saved;
  Object.values(api).forEach((f) => f.mockReset());
  navigate.mockReset();
  api.checkAssessReadiness.mockResolvedValue({ data: okReadiness });
  api.putAssessSourceMap.mockResolvedValue({ data: { sources: saved } });
});

describe("AssessmentWizard", () => {
  it("preselects the version and domain with saved sources", async () => {
    mount();
    expect(await screen.findByText("mvm_cat")).toBeTruthy();
    expect((screen.getByRole("checkbox", { name: "sales_order" }) as HTMLInputElement).getAttribute("aria-checked")).toBe("true");
    expect((screen.getByRole("checkbox", { name: "customer" }) as HTMLInputElement).getAttribute("aria-checked")).toBe("false");
    expect((screen.getByLabelText("Source name") as HTMLInputElement).value).toBe("src_sap");
    expect(screen.getByText(/Typically 30–60 min per domain/)).toBeTruthy();
  });

  it("Check readiness posts the version and per-domain sources", async () => {
    mount();
    fireEvent.click(await screen.findByRole("button", { name: /check readiness/i }));
    await waitFor(() =>
      expect(api.checkAssessReadiness).toHaveBeenCalledWith({
        version_id: "v2",
        domains: [{ domain_id: "d1", sources: saved }],
      }),
    );
  });

  it("disables Launch when a domain is blocked", async () => {
    api.checkAssessReadiness.mockResolvedValue({ data: blockedReadiness });
    mount();
    fireEvent.click(await screen.findByRole("button", { name: /check readiness/i }));
    await screen.findByTestId("readiness-panel");
    expect(launchBtn().disabled).toBe(true);
  });

  it("launches when ready: saves the source map first, then navigates to the batch", async () => {
    api.launchAssessment.mockResolvedValue({ data: { id: "batch-9" } });
    mount();
    fireEvent.click(await screen.findByRole("button", { name: /check readiness/i }));
    await waitFor(() => expect(launchBtn().disabled).toBe(false));
    fireEvent.click(launchBtn());
    await waitFor(() => expect(navigate).toHaveBeenCalled());
    expect(api.putAssessSourceMap).toHaveBeenCalledWith({ business_id: "b1" }, { sources: saved });
    expect(api.putAssessSourceMap.mock.invocationCallOrder[0]).toBeLessThan(
      api.launchAssessment.mock.invocationCallOrder[0],
    );
    expect(api.launchAssessment).toHaveBeenCalledWith(
      { business_id: "b1" },
      expect.objectContaining({
        version_id: "v2",
        output_model: "hybrid",
        etl_type: "sdp_pipeline",
        reasoning_effort: "medium",
        domains: [{ domain_id: "d1", sources: saved }],
      }),
    );
    expect(navigate).toHaveBeenCalledWith(
      expect.objectContaining({
        to: "/businesses/$businessId/assessments/$batchId",
        params: { businessId: "b1", batchId: "batch-9" },
      }),
    );
  });

  it("does not launch when saving the source map fails", async () => {
    api.putAssessSourceMap.mockRejectedValue(new Error("boom"));
    mount();
    fireEvent.click(await screen.findByRole("button", { name: /check readiness/i }));
    await waitFor(() => expect(launchBtn().disabled).toBe(false));
    fireEvent.click(launchBtn());
    await waitFor(() => expect(api.putAssessSourceMap).toHaveBeenCalled());
    expect(api.launchAssessment).not.toHaveBeenCalled();
    expect(navigate).not.toHaveBeenCalled();
  });

  it("renders the readiness from a 409 and does not navigate", async () => {
    const { ApiError } = await import("@/lib/api");
    api.launchAssessment.mockRejectedValue(
      new ApiError(409, "Conflict", {
        detail: { error: "admin_help", message: "Launch blocked by readiness", readiness: blockedReadiness },
      }),
    );
    mount();
    fireEvent.click(await screen.findByRole("button", { name: /check readiness/i }));
    await waitFor(() => expect(launchBtn().disabled).toBe(false));
    fireEvent.click(launchBtn());
    expect(await screen.findByText("Launch blocked by readiness")).toBeTruthy();
    expect(await screen.findByText("Model catalog")).toBeTruthy();
    expect(navigate).not.toHaveBeenCalled();
    expect(launchBtn().disabled).toBe(true);
  });

  it("shows the admin-help block for a launch the backend refused or failed", async () => {
    const { ApiError } = await import("@/lib/api");
    api.launchAssessment.mockRejectedValue(
      new ApiError(409, "Conflict", {
        detail: { error: "admin_help", message: "Launch failed: assets unreadable", job_url: "https://ws/jobs/7" },
      }),
    );
    mount();
    fireEvent.click(await screen.findByRole("button", { name: /check readiness/i }));
    await waitFor(() => expect(launchBtn().disabled).toBe(false));
    fireEvent.click(launchBtn());
    const block = await screen.findByTestId("launch-admin-help");
    expect(block).toHaveTextContent("Launch failed: assets unreadable");
    expect(block).toHaveTextContent("Please contact your administrator with these details");
    expect(screen.getByRole("link", { name: /^open job$/i }).getAttribute("href")).toBe("https://ws/jobs/7");
    expect(navigate).not.toHaveBeenCalled();
  });

  it("lists the not_ready reasons of a not-ready 409 in the block", async () => {
    const { ApiError } = await import("@/lib/api");
    api.launchAssessment.mockRejectedValue(
      new ApiError(409, "Conflict", {
        detail: { error: "admin_help", message: "Assessment isn't ready", not_ready: ["No reader service principal"] },
      }),
    );
    mount();
    fireEvent.click(await screen.findByRole("button", { name: /check readiness/i }));
    await waitFor(() => expect(launchBtn().disabled).toBe(false));
    fireEvent.click(launchBtn());
    const block = await screen.findByTestId("launch-admin-help");
    expect(block).toHaveTextContent("No reader service principal");
  });

  it("one Check readiness button re-checks; the panel stays up, dimmed, while the check runs", async () => {
    api.checkAssessReadiness.mockResolvedValue({ data: blockedReadiness });
    mount();
    fireEvent.click(await screen.findByRole("button", { name: /check readiness/i }));
    await screen.findByTestId("readiness-panel");
    expect(screen.queryByRole("button", { name: /check again/i })).toBeNull();
    let release: (v: unknown) => void = () => {};
    api.checkAssessReadiness.mockReturnValue(new Promise((r) => { release = r; }));
    const check = screen.getByRole("button", { name: /check readiness/i }) as HTMLButtonElement;
    fireEvent.click(check);
    await waitFor(() => expect(check.disabled).toBe(true));
    expect(screen.getByTestId("readiness-panel")).toHaveAttribute("aria-busy", "true");
    release({ data: okReadiness });
    await waitFor(() => expect(launchBtn().disabled).toBe(false));
    expect(check.disabled).toBe(false);
  });

  it("with an empty saved map: no readiness request, inline message, Launch disabled", async () => {
    savedNow = [];
    mount();
    expect(await screen.findByText("Add at least one complete source for sales_order")).toBeTruthy();
    await new Promise((r) => setTimeout(r, 800));
    expect(api.checkAssessReadiness).not.toHaveBeenCalled();
    expect(launchBtn().disabled).toBe(true);
    expect((screen.getByRole("button", { name: /check readiness/i }) as HTMLButtonElement).disabled).toBe(true);
  });

  it("flags a half-filled row and sends no request", async () => {
    mount();
    fireEvent.click(await screen.findByRole("button", { name: /add source/i }));
    fireEvent.change(screen.getAllByLabelText("Source name")[1], { target: { value: "src_half" } });
    expect(await screen.findByText("Complete or remove the incomplete source rows for sales_order")).toBeTruthy();
    api.checkAssessReadiness.mockClear();
    await new Promise((r) => setTimeout(r, 800));
    expect(api.checkAssessReadiness).not.toHaveBeenCalled();
    expect(launchBtn().disabled).toBe(true);
  });

  it("ignores a domainId that is not in the selected version", async () => {
    mount({ versionId: "v2", domainId: "ghost" });
    await screen.findByText("mvm_cat");
    expect(screen.getByRole("checkbox", { name: "sales_order" }).getAttribute("aria-checked")).toBe("false");
    expect(screen.queryByTestId("source-map-editor")).toBeNull();
  });

  it("ignores the domainId when the versionId param fell back", async () => {
    mount({ versionId: "v-unknown", domainId: "d1" });
    await screen.findByText("mvm_cat");
    expect(screen.getByRole("checkbox", { name: "sales_order" }).getAttribute("aria-checked")).toBe("false");
  });

  it("opens with a description, the read-only note, timing and a help link", () => {
    mount();
    expect(screen.getByTestId("assess-intro")).toBeInTheDocument();
    expect(screen.getByText(/read-only/i)).toBeInTheDocument();
    expect(screen.getByText(/30.60 minutes per domain/i)).toBeInTheDocument();
    expect(screen.getByText(new RegExp(`rate limit for ${ASSESS_MODEL}`))).toBeInTheDocument();
    const link = screen.getByRole("link", { name: /How assessments work/i });
    expect(link.getAttribute("href")).toContain("/help/");
  });
});
