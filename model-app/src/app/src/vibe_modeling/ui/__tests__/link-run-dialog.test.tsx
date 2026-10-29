/**
 * Link an imported version to its run (add §5.2): the version page offers
 * "Link to run" to admins for an unlinked import, the dialog checks the run id
 * and shows how it matched, and Link records it.
 */
import { beforeEach, describe, expect, it, vi } from "vitest";
import { act, fireEvent, render, screen, waitFor } from "@testing-library/react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import type { ModelVersionOut } from "@/lib/api";

const previewMock = vi.fn();
const linkMock = vi.fn();
let role: string | undefined = "business_admin";
vi.mock("@/lib/api", async () => {
  const actual = await vi.importActual<typeof import("@/lib/api")>("@/lib/api");
  return {
    ...actual,
    previewLinkRun: (...a: unknown[]) => previewMock(...a),
    linkRun: (...a: unknown[]) => linkMock(...a),
  };
});
vi.mock("@/lib/hooks", async () => {
  const actual = await vi.importActual<typeof import("@/lib/hooks")>("@/lib/hooks");
  return { ...actual, useUserRole: () => role };
});
vi.mock("@tanstack/react-router", () => ({
  Link: ({ children, params, ...rest }: { children: React.ReactNode; params: { runId: string } }) => (
    <a href={`/runs/${params.runId}`} {...rest}>
      {children}
    </a>
  ),
}));
vi.mock("sonner", () => ({ toast: { success: vi.fn(), error: vi.fn() } }));

import { toast } from "sonner";
import { LinkRunAction, parseRunId } from "@/components/runs/link-run-dialog";
import { isBusinessAdmin } from "@/lib/hooks";

const imported = {
  id: "v1",
  business_id: "b1",
  version: 1,
  scope: "ecm",
  import_source_path: "/Volumes/business_3/_metamodel/vol_root/business/wt_p0_grain_coop/v1/ecm/model.json",
  is_imported: true,
  linked_run_id: null,
} as unknown as ModelVersionOut;

function renderAction(version: ModelVersionOut = imported) {
  return render(
    <QueryClientProvider client={new QueryClient()}>
      <LinkRunAction businessId="b1" version={version} />
    </QueryClientProvider>,
  );
}

async function check(runId: string) {
  fireEvent.click(screen.getByRole("button", { name: "Link to run" }));
  const input = screen.getByLabelText("Databricks run id") as HTMLInputElement;
  fireEvent.change(input, { target: { value: runId } });
  expect(input.value).toBe(runId);
  await act(async () => {
    fireEvent.click(screen.getByRole("button", { name: "Check run" }));
  });
}

beforeEach(() => {
  role = "business_admin";
  previewMock.mockReset();
  linkMock.mockReset();
});

describe("parseRunId", () => {
  it("takes a positive whole number only", () => {
    expect(parseRunId(" 409596894605355 ")).toBe(409596894605355);
    expect(parseRunId("12a")).toBeNull();
    expect(parseRunId("0")).toBeNull();
    expect(parseRunId("")).toBeNull();
  });
});

describe("isBusinessAdmin", () => {
  it("is true for app and business admins only", () => {
    expect(["app_admin", "business_admin", "modeler", "viewer", undefined].map(isBusinessAdmin)).toEqual([
      true, true, false, false, false,
    ]);
  });
});

describe("LinkRunAction", () => {
  it("links a run the registry confirms", async () => {
    previewMock.mockResolvedValue({
      data: {
        databricks_run_id: 409596894605355, linkable: true, tier: 1, intent: "new-base-model",
        evidence: ["The agent's registry in business_3 records that this run (new base model) wrote v1 ECM of wt_p0_grain_coop."], problems: [],
      },
    });
    linkMock.mockResolvedValue({ data: { id: "r1" } });
    renderAction();
    await check("409596894605355");
    expect(previewMock).toHaveBeenCalledWith({ business_id: "b1", version_id: "v1" }, { databricks_run_id: 409596894605355 });
    expect(screen.getByTestId("link-run-preview")).toHaveTextContent("Confirmed by the agent's registry.");
    expect(screen.getByTestId("link-run-preview")).toHaveTextContent("Recorded as a New base model run.");
    await act(async () => {
      fireEvent.click(screen.getByRole("button", { name: "Link" }));
    });
    await waitFor(() => expect(linkMock).toHaveBeenCalledWith({ business_id: "b1", version_id: "v1" }, { databricks_run_id: 409596894605355 }));
    expect(toast.success).toHaveBeenCalledWith("Linked v1 ECM to Databricks run 409596894605355.");
  });

  it("labels a best-effort match", async () => {
    previewMock.mockResolvedValue({
      data: { databricks_run_id: 7, linkable: true, tier: 2, intent: "vibe-iterate", evidence: [], problems: [] },
    });
    renderAction();
    await check("7");
    expect(screen.getByTestId("link-run-preview")).toHaveTextContent("Best-effort match: the agent's registry did not confirm this run.");
  });

  it("shows the problems and offers no Link", async () => {
    previewMock.mockResolvedValue({
      data: {
        databricks_run_id: 7, linkable: false, tier: null, intent: null, evidence: [],
        problems: ["The run did not succeed (FAILED); its model.json may be partial."],
      },
    });
    renderAction();
    await check("7");
    expect(screen.getByRole("alert")).toHaveTextContent("The run did not succeed (FAILED)");
    expect(screen.queryByRole("button", { name: "Link" })).toBeNull();
    expect(screen.getByRole("button", { name: "Check run" })).toBeInTheDocument();
  });

  it("shows the run of a linked version", () => {
    renderAction({ ...imported, linked_run_id: "r9" } as ModelVersionOut);
    expect(screen.getByTestId("linked-run-link")).toHaveAttribute("href", "/runs/r9");
    expect(screen.queryByRole("button", { name: "Link to run" })).toBeNull();
  });

  it.each(["modeler", "viewer"])("hides Link to run for role %s", (r) => {
    role = r;
    renderAction();
    expect(screen.queryByRole("button", { name: "Link to run" })).toBeNull();
  });

  it("offers nothing for a version that was not imported", () => {
    renderAction({ ...imported, import_source_path: null, is_imported: false } as ModelVersionOut);
    expect(screen.queryByRole("button", { name: "Link to run" })).toBeNull();
  });

  it("offers nothing when the server did not say the version was imported", () => {
    renderAction({ ...imported, is_imported: null } as ModelVersionOut);
    expect(screen.queryByRole("button", { name: "Link to run" })).toBeNull();
  });

  it("shows Link to run for an out-of-band import, which has no import path", () => {
    renderAction({ ...imported, import_source_path: null, is_imported: true } as ModelVersionOut);
    expect(screen.getByRole("button", { name: "Link to run" })).toBeInTheDocument();
  });

  it("hides Link to run when the version has a path but the server says it was not imported", () => {
    renderAction({ ...imported, is_imported: false } as ModelVersionOut);
    expect(screen.queryByRole("button", { name: "Link to run" })).toBeNull();
  });
});
