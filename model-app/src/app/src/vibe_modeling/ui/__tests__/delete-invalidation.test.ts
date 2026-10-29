/**
 * `invalidateEntityLists` — the single convergent delete-invalidation map
 * (Track 8 item 3). Each entity invalidates its mapped keys; `version` also
 * invalidates the business lists so `model_count` updates immediately.
 */
import { describe, expect, it, vi } from "vitest";
import { QueryClient } from "@tanstack/react-query";
import { invalidateEntityLists } from "@/lib/delete-invalidation";
import { listVersionsKey, getExplorerVersionsKey, listSectorsKey, listMetamodelCleanupsKey } from "@/lib/api";
import { BUSINESSES_QUERY_PATH } from "@/lib/business-cache";

function makeClient() {
  return new QueryClient({
    defaultOptions: { queries: { retry: false } },
  });
}

describe("invalidateEntityLists", () => {
  it("business: invalidates every /api/businesses list query", async () => {
    const qc = makeClient();
    const spy = vi.spyOn(qc, "invalidateQueries");
    await invalidateEntityLists(qc, "business");
    expect(spy).toHaveBeenCalledWith({
      predicate: expect.any(Function),
    });
    const predicate = spy.mock.calls[0][0]?.predicate as (q: { queryKey: unknown }) => boolean;
    expect(predicate({ queryKey: [BUSINESSES_QUERY_PATH, { kind: "industry" }] })).toBe(true);
    expect(predicate({ queryKey: ["/api/other"] })).toBe(false);
  });

  it("version: invalidates business lists + version keys", async () => {
    const qc = makeClient();
    const spy = vi.spyOn(qc, "invalidateQueries");
    await invalidateEntityLists(qc, "version", { businessId: "biz-1" });
    const keys = spy.mock.calls.map((c) => c[0]);
    expect(keys).toContainEqual({ predicate: expect.any(Function) });
    expect(keys).toContainEqual({ queryKey: listVersionsKey({ business_id: "biz-1" }) });
    expect(keys).toContainEqual({ queryKey: getExplorerVersionsKey({ business_id: "biz-1" }) });
    expect(keys).toContainEqual({ queryKey: listMetamodelCleanupsKey({ business_id: "biz-1" }) });
  });

  it("version: throws without a businessId", () => {
    const qc = makeClient();
    expect(() => invalidateEntityLists(qc, "version")).toThrow(/businessId/);
  });

  it("vibeInput: routes through invalidateVibeInputQueries's marker predicate", async () => {
    const qc = makeClient();
    const spy = vi.spyOn(qc, "invalidateQueries");
    await invalidateEntityLists(qc, "vibeInput", { businessId: "biz-1" });
    expect(spy).toHaveBeenCalledWith({ predicate: expect.any(Function) });
  });

  it("sector: invalidates listSectorsKey", async () => {
    const qc = makeClient();
    const spy = vi.spyOn(qc, "invalidateQueries");
    await invalidateEntityLists(qc, "sector");
    expect(spy).toHaveBeenCalledWith({ queryKey: listSectorsKey() });
  });
});
