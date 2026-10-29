import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";
import { screen, waitFor } from "@testing-library/react";

import { LineageCard } from "@/components/lineage/lineage-card";
import { renderWithRouter } from "./helpers/router-wrapper";

type FetchMock = ReturnType<typeof vi.fn>;

interface StubData {
  /** Body for `/api/runs/{id}/lineage`. */
  lineage?: unknown;
  /** Body for `/api/runs/{id}/operations`. */
  operations?: unknown;
  /** Body for `/api/businesses/{id}/versions`. */
  versions?: unknown;
}

// Route a single fetch stub across the three endpoints LineageCard now
// hits: legacy lineage (still used for operates_on_version), the
// authoritative RunOperation rows for source/generated, and the versions
// list for the version-id → (version, scope) lookup.
function stubLineageEndpoints({
  lineage = null,
  operations = [],
  versions = [],
}: StubData): FetchMock {
  const fn = vi.fn(async (url: RequestInfo) => {
    const u = String(url);
    if (u.includes("/operations")) {
      return { ok: true, status: 200, json: async () => operations };
    }
    if (u.includes("/lineage")) {
      return {
        ok: lineage !== null,
        status: lineage !== null ? 200 : 500,
        json: async () => lineage,
      };
    }
    if (u.includes("/versions")) {
      return { ok: true, status: 200, json: async () => versions };
    }
    return { ok: true, status: 200, json: async () => ({}) };
  }) as FetchMock;
  vi.stubGlobal("fetch", fn);
  return fn;
}

describe("LineageCard — RunOperation-driven source/generated", () => {
  beforeEach(() => {
    vi.unstubAllGlobals();
  });
  afterEach(() => {
    vi.restoreAllMocks();
    vi.unstubAllGlobals();
  });

  it("renders source from first op's parent_version_id and generated from latest op's output_version_id (vibe-iterate from v1 MVM)", async () => {
    // the model-versioning work #52 regression scenario. A vibe-iterate run from v1 MVM
    // unfolds into a unified pipeline: phase 1 (ecm) takes v1 MVM →
    // produces v2 ECM; later phases shrink to v2 MVM. The first op's
    // parent_version_id is what the user picked (v1 MVM); the LAST op's
    // output_version_id is the artifact (v2 MVM).
    stubLineageEndpoints({
      lineage: {
        run_id: "r1",
        run_type: "vibe modeling of version",
        business_id: "b1",
        // The legacy endpoint mis-attributes the source to v1 ECM here —
        // fixture matches the bug exactly to prove the new code IGNORES
        // it for source/generated and trusts RunOperation rows instead.
        source_version: {
          id: "vsrc-wrong",
          version: 1,
          scope: "ecm",
          status: "completed",
          deployment_status: "deployed",
        },
        generated_version: {
          id: "vgen-wrong",
          version: 1,
          scope: "mvm",
          status: "completed",
          deployment_status: "deployed",
        },
        operates_on_version: null,
      },
      operations: [
        {
          id: "op-1",
          run_id: "r1",
          step_index: 0,
          operation_name: "ecm",
          status: "completed",
          parent_version_id: "v1-mvm",
          output_version_id: "v2-ecm",
          created_at: "2026-04-20T12:00:00Z",
        },
        {
          id: "op-3",
          run_id: "r1",
          step_index: 1,
          operation_name: "mvm",
          status: "completed",
          parent_version_id: "v2-ecm",
          output_version_id: "v2-mvm",
          created_at: "2026-04-20T12:10:00Z",
        },
      ],
      versions: [
        {
          id: "v1-mvm",
          business_id: "b1",
          version: 1,
          scope: "mvm",
          status: "completed",
          deployment_status: "deployed",
          uc_catalog: "c",
          completion_date: null,
          created_at: "2026-04-20T11:00:00Z",
          confidence_score: null,
          context_id: null,
          base_version_id: null,
          vibe_instructions: "",
        },
        {
          id: "v2-mvm",
          business_id: "b1",
          version: 2,
          scope: "mvm",
          status: "completed",
          deployment_status: "draft",
          uc_catalog: "c",
          completion_date: null,
          created_at: "2026-04-20T12:30:00Z",
          confidence_score: null,
          context_id: null,
          base_version_id: "v1-mvm",
          vibe_instructions: "",
        },
      ],
    });

    renderWithRouter(<LineageCard runId="r1" businessId="b1" runStatus="completed" />);

    await waitFor(() =>
      expect(screen.getByText("Lineage")).toBeInTheDocument(),
    );

    expect(screen.getByText("Source model version")).toBeInTheDocument();
    expect(screen.getByText("Generated model version")).toBeInTheDocument();

    // Source is v1 MVM (the parent the user picked), NOT v1 ECM (the
    // misleading lineage-endpoint answer). Generated is v2 MVM (final
    // pipeline output), NOT v1 MVM (the legacy endpoint's answer).
    expect(screen.getByRole("link", { name: /v1 MVM/ })).toBeInTheDocument();
    expect(screen.getByRole("link", { name: /v2 MVM/ })).toBeInTheDocument();
    expect(screen.queryByRole("link", { name: /v1 ECM/ })).not.toBeInTheDocument();

    const links = screen
      .getAllByRole("link")
      .map((a) => a.getAttribute("href"));
    expect(links).toContain("/businesses/b1/model/1/mvm?tab=overview");
    expect(links).toContain("/businesses/b1/model/2/mvm?tab=overview");
  });

  it("skips the leading uninstall of the source industry's version: Source is the business's own base", async () => {
    const version = (id: string, business: string, n: number, scope: string) => ({
      id, business_id: business, version: n, scope, status: "completed", deployment_status: "deployed",
      uc_catalog: "c", completion_date: null, created_at: "2026-04-20T11:00:00Z", confidence_score: null,
      context_id: null, base_version_id: null, vibe_instructions: "",
    });
    stubLineageEndpoints({
      operations: [
        { id: "op-0", run_id: "r1", step_index: 0, operation_name: "uninstall", status: "succeeded",
          parent_version_id: "ind-v1-ecm", output_version_id: null, created_at: "2026-04-20T12:00:00Z" },
        { id: "op-1", run_id: "r1", step_index: 1, operation_name: "vibe_iterate", status: "succeeded",
          parent_version_id: "v1-ecm", output_version_id: "v2-ecm", created_at: "2026-04-20T12:05:00Z" },
      ],
      versions: [version("v1-ecm", "b1", 1, "ecm"), version("v2-ecm", "b1", 2, "ecm")],
    });
    renderWithRouter(<LineageCard runId="r1" businessId="b1" runStatus="completed" />);
    const links = await screen.findAllByRole("link");
    expect(links.map((a) => a.getAttribute("href"))).toEqual([
      "/businesses/b1/model/1/ecm?tab=overview",
      "/businesses/b1/model/2/ecm?tab=overview",
    ]);
  });

  it("renders Pending placeholder for generated when run is running and no output_version_id yet", async () => {
    stubLineageEndpoints({
      lineage: {
        run_id: "r1",
        run_type: "vibe modeling of version",
        business_id: "b1",
        source_version: null,
        generated_version: null,
        operates_on_version: null,
      },
      operations: [
        {
          id: "op-1",
          run_id: "r1",
          step_index: 0,
          operation_name: "ecm",
          status: "running",
          parent_version_id: "v1-mvm",
          output_version_id: null,
          created_at: "2026-04-20T12:00:00Z",
        },
      ],
      versions: [
        {
          id: "v1-mvm",
          business_id: "b1",
          version: 1,
          scope: "mvm",
          status: "completed",
          deployment_status: "deployed",
          uc_catalog: "c",
          completion_date: null,
          created_at: "2026-04-20T11:00:00Z",
          confidence_score: null,
          context_id: null,
          base_version_id: null,
          vibe_instructions: "",
        },
      ],
    });

    renderWithRouter(<LineageCard runId="r1" businessId="b1" runStatus="running" />);

    await waitFor(() =>
      expect(screen.getByText("Lineage")).toBeInTheDocument(),
    );

    // Source resolves normally — v1 MVM picked at submit time, op already
    // has parent_version_id even before output is ready.
    expect(screen.getByRole("link", { name: /v1 MVM/ })).toBeInTheDocument();

    // Generated is "Pending" — old code would have linked back to the
    // parent here, which is the model-versioning work #52 bug. Test asserts no link
    // is rendered for the generated row.
    expect(screen.getByTestId("lineage-generated-pending")).toHaveTextContent("Pending");
    // No link with "v1 MVM" appears in BOTH source and generated; only
    // the source row links. Two lookups would mean the generated row
    // mis-links to the parent.
    expect(screen.getAllByRole("link", { name: /v1 MVM/ })).toHaveLength(1);
  });

  it("renders 'Failed before generation' placeholder when run failed before any output_version_id was written", async () => {
    stubLineageEndpoints({
      lineage: {
        run_id: "r1",
        run_type: "vibe modeling of version",
        business_id: "b1",
        source_version: null,
        generated_version: null,
        operates_on_version: null,
      },
      operations: [
        {
          id: "op-1",
          run_id: "r1",
          step_index: 0,
          operation_name: "ecm",
          status: "failed",
          parent_version_id: "v1-mvm",
          output_version_id: null,
          created_at: "2026-04-20T12:00:00Z",
        },
      ],
      versions: [
        {
          id: "v1-mvm",
          business_id: "b1",
          version: 1,
          scope: "mvm",
          status: "completed",
          deployment_status: "deployed",
          uc_catalog: "c",
          completion_date: null,
          created_at: "2026-04-20T11:00:00Z",
          confidence_score: null,
          context_id: null,
          base_version_id: null,
          vibe_instructions: "",
        },
      ],
    });

    renderWithRouter(<LineageCard runId="r1" businessId="b1" runStatus="failed" />);

    await waitFor(() =>
      expect(screen.getByText("Lineage")).toBeInTheDocument(),
    );

    expect(screen.getByTestId("lineage-generated-failed")).toHaveTextContent(
      /Failed before generation/,
    );
    // Generated row must NOT contain a link — old code linked back to the
    // parent v1 MVM here, which is the regression the model-versioning work #52 fixed.
    expect(screen.getAllByRole("link", { name: /v1 MVM/ })).toHaveLength(1);
  });

  it("renders 'Failed before generation' placeholder when run was cancelled before output", async () => {
    stubLineageEndpoints({
      lineage: {
        run_id: "r1",
        run_type: "vibe modeling of version",
        business_id: "b1",
        source_version: null,
        generated_version: null,
        operates_on_version: null,
      },
      operations: [
        {
          id: "op-1",
          run_id: "r1",
          step_index: 0,
          operation_name: "ecm",
          status: "cancelled",
          parent_version_id: "v1-mvm",
          output_version_id: null,
          created_at: "2026-04-20T12:00:00Z",
        },
      ],
      versions: [
        {
          id: "v1-mvm",
          business_id: "b1",
          version: 1,
          scope: "mvm",
          status: "completed",
          deployment_status: "deployed",
          uc_catalog: "c",
          completion_date: null,
          created_at: "2026-04-20T11:00:00Z",
          confidence_score: null,
          context_id: null,
          base_version_id: null,
          vibe_instructions: "",
        },
      ],
    });

    renderWithRouter(<LineageCard runId="r1" businessId="b1" runStatus="cancelled" />);

    await waitFor(() =>
      expect(screen.getByText("Lineage")).toBeInTheDocument(),
    );

    expect(screen.getByTestId("lineage-generated-failed")).toHaveTextContent(
      /Failed before generation/,
    );
  });

  it("renders em-dash for source on a new-base-model run (first op has no parent_version_id)", async () => {
    stubLineageEndpoints({
      lineage: {
        run_id: "r1",
        run_type: "new base model",
        business_id: "b1",
        source_version: null,
        generated_version: null,
        operates_on_version: null,
      },
      operations: [
        {
          id: "op-1",
          run_id: "r1",
          step_index: 0,
          operation_name: "ecm",
          status: "completed",
          parent_version_id: null,
          output_version_id: "v1-ecm",
          created_at: "2026-04-20T12:00:00Z",
        },
        {
          id: "op-2",
          run_id: "r1",
          step_index: 1,
          operation_name: "mvm",
          status: "completed",
          parent_version_id: "v1-ecm",
          output_version_id: "v1-mvm",
          created_at: "2026-04-20T12:10:00Z",
        },
      ],
      versions: [
        {
          id: "v1-mvm",
          business_id: "b1",
          version: 1,
          scope: "mvm",
          status: "completed",
          deployment_status: "deployed",
          uc_catalog: "c",
          completion_date: null,
          created_at: "2026-04-20T12:30:00Z",
          confidence_score: null,
          context_id: null,
          base_version_id: null,
          vibe_instructions: "",
        },
      ],
    });

    renderWithRouter(<LineageCard runId="r1" businessId="b1" runStatus="completed" />);

    await waitFor(() =>
      expect(screen.getByText("Lineage")).toBeInTheDocument(),
    );

    expect(screen.getByTestId("lineage-source-empty")).toHaveTextContent("—");
    // Generated should still resolve to v1 MVM (final phase output).
    expect(screen.getByRole("link", { name: /v1 MVM/ })).toBeInTheDocument();
  });

  it("falls back to the legacy lineage endpoint when no RunOperation rows exist (legacy run pre-dating the wirer)", async () => {
    stubLineageEndpoints({
      lineage: {
        run_id: "r1",
        run_type: "vibe modeling of version",
        business_id: "b1",
        source_version: {
          id: "vsrc",
          version: 2,
          scope: "ecm",
          status: "completed",
          deployment_status: "deployed",
        },
        generated_version: {
          id: "vgen",
          version: 3,
          scope: "mvm",
          status: "completed",
          deployment_status: "draft",
        },
        operates_on_version: null,
      },
      operations: [],
      versions: [],
    });

    renderWithRouter(<LineageCard runId="r1" businessId="b1" runStatus="completed" />);

    await waitFor(() =>
      expect(screen.getByText("Lineage")).toBeInTheDocument(),
    );

    expect(screen.getByRole("link", { name: /v2 ECM/ })).toBeInTheDocument();
    expect(screen.getByRole("link", { name: /v3 MVM/ })).toBeInTheDocument();
  });

  it("renders operates_on_version row for install/uninstall ops (still served by lineage endpoint)", async () => {
    stubLineageEndpoints({
      lineage: {
        run_id: "r1",
        run_type: "install model",
        business_id: "b1",
        source_version: null,
        generated_version: null,
        operates_on_version: {
          id: "vop",
          version: 4,
          scope: "",
          status: "completed",
          deployment_status: "deployed",
        },
      },
      operations: [],
      versions: [],
    });

    renderWithRouter(<LineageCard runId="r1" businessId="b1" runStatus="completed" />);

    await waitFor(() =>
      expect(screen.getByText("Lineage")).toBeInTheDocument(),
    );

    expect(screen.getByText("Operates on")).toBeInTheDocument();
    const links = screen
      .getAllByRole("link")
      .map((a) => a.getAttribute("href"));
    // Empty scope falls back to "mvm" so the URL is well-formed.
    expect(links).toContain("/businesses/b1/model/4/mvm?tab=overview");
  });

  it("renders nothing when there are no operations and lineage has no versions", async () => {
    stubLineageEndpoints({
      lineage: {
        run_id: "r1",
        run_type: "install model",
        business_id: "b1",
        source_version: null,
        generated_version: null,
        operates_on_version: null,
      },
      operations: [],
      versions: [],
    });

    renderWithRouter(<LineageCard runId="r1" businessId="b1" runStatus="completed" />);

    await waitFor(() => {
      expect((globalThis.fetch as unknown as FetchMock)).toHaveBeenCalled();
    });

    expect(screen.queryByText("Lineage")).not.toBeInTheDocument();
    expect(screen.queryByText("Source model version")).not.toBeInTheDocument();
    expect(screen.queryByText("Generated model version")).not.toBeInTheDocument();
    expect(screen.queryByText("Operates on")).not.toBeInTheDocument();
  });
});
