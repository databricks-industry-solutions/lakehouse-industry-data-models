/**
 * A failed install run offers "Install vN again" for its target and, after a
 * succeeded uninstall of the occupying version, for that one too (design §1
 * B3), with the run's catalog preselected.
 */
import { describe, expect, it, vi } from "vitest";
import { fireEvent, screen } from "@testing-library/react";
import type { RunOperationOut, RunOut } from "@/lib/api";

const v3 = { id: "mv-3", version: 3, scope: "ecm" };
const v5 = { id: "mv-5", version: 5, scope: "ecm" };
// The source industry's v1 ECM, which a kickstarted business's install
// uninstalls first.
const i1 = { id: "ind-1", version: 1, scope: "ecm" };
vi.mock("@/lib/api", async () => {
  const actual = await vi.importActual<typeof import("@/lib/api")>("@/lib/api");
  return {
    ...actual,
    useListVersions: ({ params }: { params: { business_id: string } }) => ({
      data: { data: params.business_id === "ind" ? [i1] : [v3, v5] },
    }),
    useGetBusiness: ({ params, query }: { params: { business_id: string }; query?: { enabled?: boolean } }) =>
      query?.enabled === false
        ? { data: undefined }
        : { data: params.business_id === "ind" ? { id: "ind", name: "Agriculture" } : { id: "b1", source_industry_id: "ind" } },
  };
});
vi.mock("@/components/runs/version-operation-dialog", () => ({
  VersionOperationDialog: ({ version, initialCatalog }: { version: { id: string }; initialCatalog?: string }) => (
    <div data-testid={`stub-install-${version.id}-${initialCatalog}`} />
  ),
}));

import {
  FailedInstallActions,
  runTargetCatalog,
  versionsToInstallAgain,
} from "@/components/runs/failed-install-actions";
import { renderWithRouter } from "./helpers/router-wrapper";

function op(name: string, status: string, parent: string | null, widgets: Record<string, unknown> = {}): RunOperationOut {
  return {
    id: `${name}-op`, run_id: "r1", operation_name: name, status, step_index: name === "uninstall" ? 0 : 1,
    created_at: "2026-10-20T00:00:00Z", parent_version_id: parent, dispatched_widgets: widgets,
  };
}
const run = { id: "r1", version_id: "mv-3", intent: "install", status: "failed" } as RunOut;

describe("versionsToInstallAgain", () => {
  it("offers the target, then the uninstalled occupant", () => {
    expect(versionsToInstallAgain(run, [op("uninstall", "succeeded", "mv-5"), op("install", "failed", "mv-3")])).toEqual(["mv-3", "mv-5"]);
  });
  it("never offers another business's version; the occupant still is", () => {
    const own = new Set(["mv-3", "mv-5"]);
    const ops = [op("uninstall", "succeeded", "ind-1"), op("uninstall", "succeeded", "mv-5"), op("install", "failed", "mv-3")];
    expect(versionsToInstallAgain(run, ops, own)).toEqual(["mv-3", "mv-5"]);
  });
  it("offers only the target when the uninstall did not succeed", () => {
    expect(versionsToInstallAgain(run, [op("uninstall", "failed", "mv-5"), op("install", "pending", "mv-3")])).toEqual(["mv-3"]);
  });
});

describe("runTargetCatalog", () => {
  it("reads the request, else the dispatched widget", () => {
    expect(runTargetCatalog({ catalog: "cat_x" }, [])).toBe("cat_x");
    expect(runTargetCatalog({}, [op("install", "failed", "mv-3", { catalog: "cat_w" })])).toBe("cat_w");
  });
});

describe("FailedInstallActions", () => {
  it("opens the install dialog for the occupant with the run's catalog", async () => {
    renderWithRouter(
      <FailedInstallActions
        businessId="b1"
        run={run}
        runParams={{ catalog: "cat_x" }}
        operations={[op("uninstall", "succeeded", "mv-5"), op("install", "failed", "mv-3")]}
      />,
    );
    expect(await screen.findByTestId("failed-install-actions")).toHaveTextContent("The install failed after v5 ECM was uninstalled from cat_x.");
    fireEvent.click(screen.getByRole("button", { name: "Install v5 again" }));
    expect(screen.getByTestId("stub-install-mv-5-cat_x")).toBeInTheDocument();
    expect(screen.getByRole("button", { name: "Install v3 again" })).toBeInTheDocument();
  });

  it("names the source industry's version the run uninstalled first, with no button for it", async () => {
    renderWithRouter(
      <FailedInstallActions
        businessId="b1"
        run={run}
        runParams={{ catalog: "cat_x" }}
        operations={[
          op("uninstall", "succeeded", "ind-1", { operation: "uninstall model version" }),
          op("install", "failed", "mv-3"),
        ]}
      />,
    );
    expect(await screen.findByTestId("failed-install-actions")).toHaveTextContent(
      "The install failed after Agriculture v1 ECM was uninstalled from cat_x.",
    );
    expect(screen.getAllByRole("button").map((b) => b.textContent)).toEqual(["Install v3 again"]);
  });

  it("a release-only step of the industry dropped nothing and is not named", async () => {
    renderWithRouter(
      <FailedInstallActions
        businessId="b1"
        run={run}
        runParams={{ catalog: "cat_x" }}
        operations={[op("uninstall", "succeeded", "ind-1"), op("install", "failed", "mv-3")]}
      />,
    );
    expect(await screen.findByTestId("failed-install-actions")).toHaveTextContent("The install failed.");
  });
});
