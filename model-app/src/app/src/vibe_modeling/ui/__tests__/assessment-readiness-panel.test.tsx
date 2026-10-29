import { describe, expect, it, vi, beforeEach } from "vitest";
import { render, screen, fireEvent, within } from "@testing-library/react";

const { toastSuccess } = vi.hoisted(() => ({ toastSuccess: vi.fn() }));
vi.mock("sonner", () => ({ toast: { success: toastSuccess, error: vi.fn() } }));
vi.mock("@tanstack/react-router", () => ({
  Link: ({ children, to, search, hash, ...rest }: any) => (
    <a href={`${to}?tab=${search?.tab ?? ""}${hash ? `#${hash}` : ""}`} {...rest}>{children}</a>
  ),
}));

import { ReadinessPanel } from "@/components/assessment/readiness-panel";

const base = {
  global_checks: [
    { key: "reader_configured", label: "Reader service principal", state: "ok", detail: "", fix_sql: "", fix_action: "" },
    { key: "warehouse", label: "SQL warehouse", state: "ok", detail: "", fix_sql: "", fix_action: "" },
  ],
  domains: [{
    domain_id: "d1", domain_name: "sales_order", blocked: true,
    checks: [
      { key: "model_read", label: "Model catalog", state: "blocked", detail: "Reader can't read mvm.sales_order.",
        fix_sql: "GRANT SELECT ON SCHEMA mvm.sales_order TO `app-1`;", fix_action: "" },
      { key: "bronze:src_sap", label: "Bronze src_sap", state: "unverified", detail: "pre-flight will check", fix_sql: "", fix_action: "" },
    ],
  }],
} as const;

describe("ReadinessPanel", () => {
  beforeEach(() => {
    toastSuccess.mockClear();
    Object.assign(navigator, { clipboard: { writeText: vi.fn().mockResolvedValue(undefined) } });
  });

  it("shows blocked, unverified and the fix SQL", () => {
    render(<ReadinessPanel readiness={base as any} />);
    expect(screen.getByText("sales_order")).toBeInTheDocument();
    expect(screen.getByText(/Blocked/)).toBeInTheDocument();
    expect(screen.getByText(/Unverified/)).toBeInTheDocument();
    expect(screen.getByText(/GRANT SELECT ON SCHEMA mvm.sales_order/)).toBeInTheDocument();
    expect(screen.getByText(/confirm before any model calls/i)).toBeInTheDocument();
  });

  it("offers no grant action; a blocked model read shows its SQL only", () => {
    render(<ReadinessPanel readiness={base as any} />);
    expect(screen.queryByRole("button", { name: /grant/i })).toBeNull();
    expect(screen.getByRole("button", { name: /copy sql/i })).toBeInTheDocument();
  });

  it("copies fix SQL", async () => {
    render(<ReadinessPanel readiness={base as any} />);
    fireEvent.click(screen.getByRole("button", { name: /copy sql/i }));
    expect(navigator.clipboard.writeText).toHaveBeenCalledWith(
      "GRANT SELECT ON SCHEMA mvm.sales_order TO `app-1`;",
    );
    await vi.waitFor(() => expect(toastSuccess).toHaveBeenCalledWith("Copied to clipboard"));
  });

  it("links open_settings fixes to the assessment card in Settings → Platform", () => {
    const r = {
      global_checks: [{ key: "reader_configured", label: "Reader service principal", state: "blocked", detail: "Not set", fix_sql: "", fix_action: "open_settings" }],
      domains: [],
    };
    render(<ReadinessPanel readiness={r as any} />);
    expect(screen.getByRole("link", { name: /open settings/i })).toHaveAttribute("href", "/settings?tab=platform#feature-assessment");
  });

  it("shows the admin-help block, not SQL, for checks the app's setup owns", () => {
    const r = {
      global_checks: [
        { key: "runs_volume", label: "Runs volume", state: "blocked", detail: "The reader can't read and write cat._metamodel.assess_runs.", fix_sql: "", fix_action: "admin_help" },
        { key: "metamodel_access", label: "Deployment _metamodel schema", state: "blocked", detail: "The reader can't use cat._metamodel.", fix_sql: "GRANT USE SCHEMA", fix_action: "admin_help" },
      ],
      domains: [],
    };
    render(<ReadinessPanel readiness={r as any} />);
    const vol = within(screen.getByTestId("readiness-check-runs_volume"));
    const block = vol.getByTestId("readiness-admin-help-global-runs_volume");
    expect(block).toHaveTextContent("The reader can't read and write cat._metamodel.assess_runs.");
    expect(block).toHaveTextContent("This check needs your administrator. Please contact your administrator with these details.");
    expect(block).not.toHaveAttribute("role");
    expect(screen.queryByRole("button", { name: /copy sql/i })).toBeNull();
    expect(screen.queryByText("GRANT USE SCHEMA")).toBeNull();
    expect(screen.getByTestId("readiness-admin-help-global-metamodel_access")).toBeInTheDocument();
  });

  it("dims and marks busy while a new check runs", () => {
    render(<ReadinessPanel readiness={base as any} checking />);
    expect(screen.getByTestId("readiness-panel")).toHaveAttribute("aria-busy", "true");
  });

  it("renders all-ok compactly", () => {
    const ok = { global_checks: base.global_checks, domains: [{ ...base.domains[0], blocked: false, checks: [] }] };
    render(<ReadinessPanel readiness={ok as any} />);
    expect(screen.getByText(/ready to launch/i)).toBeInTheDocument();
  });
});
