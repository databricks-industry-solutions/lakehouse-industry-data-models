/**
 * Single convergent entity -> invalidator map for every FE delete site.
 *
 * Mirrors the pattern `lib/business-cache.ts` already established: instead of
 * each delete call site hand-rolling its own set of `invalidateQueries`
 * calls (some do, some don't - the source of the explorer delete-business
 * bug and the version-delete stale `model_count`), every delete success path
 * routes through `invalidateEntityLists(queryClient, entity, ctx)`, which
 * composes the existing per-entity helpers/keys.
 */
import type { QueryClient } from "@tanstack/react-query";
import { invalidateBusinessLists } from "./business-cache";
import { invalidateVibeInputQueries } from "@/components/vibe-inputs/query-keys";
import { listVersionsKey, getExplorerVersionsKey, listSectorsKey, listMetamodelCleanupsKey } from "./api";

/** The business page's unfinished-cleanup list, which the cleanup-outcome toast points to. */
export function invalidateMetamodelCleanups(queryClient: QueryClient, businessId: string): Promise<void> {
  return queryClient.invalidateQueries({ queryKey: listMetamodelCleanupsKey({ business_id: businessId }) });
}

export type DeletableEntity = "business" | "version" | "vibeInput" | "sector";

export interface InvalidateEntityContext {
  /** Required for "version" (listVersionsKey/getExplorerVersionsKey are
   *  business-scoped) and "vibeInput" (invalidateVibeInputQueries's shape). */
  businessId?: string;
}

/**
 * Invalidate the list queries a successful delete of `entity` makes stale.
 * `version` also invalidates the businesses lists so the `model_count`
 * column on the Businesses/Industries pages updates immediately.
 */
export function invalidateEntityLists(
  queryClient: QueryClient,
  entity: DeletableEntity,
  ctx: InvalidateEntityContext = {},
): Promise<unknown> {
  switch (entity) {
    case "business":
      return invalidateBusinessLists(queryClient);
    case "version": {
      const businessId = requireBusinessId(entity, ctx);
      return Promise.all([
        invalidateBusinessLists(queryClient),
        queryClient.invalidateQueries({
          queryKey: listVersionsKey({ business_id: businessId }),
        }),
        queryClient.invalidateQueries({
          queryKey: getExplorerVersionsKey({ business_id: businessId }),
        }),
        invalidateMetamodelCleanups(queryClient, businessId),
      ]);
    }
    case "vibeInput": {
      const businessId = requireBusinessId(entity, ctx);
      return Promise.resolve(invalidateVibeInputQueries(queryClient, businessId));
    }
    case "sector":
      return queryClient.invalidateQueries({ queryKey: listSectorsKey() });
  }
}

function requireBusinessId(entity: DeletableEntity, ctx: InvalidateEntityContext): string {
  if (!ctx.businessId) {
    throw new Error(`invalidateEntityLists("${entity}") requires ctx.businessId`);
  }
  return ctx.businessId;
}
