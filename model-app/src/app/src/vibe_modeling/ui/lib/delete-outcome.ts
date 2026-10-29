import { toast } from "sonner";
import {
  ApiError,
  type BusinessDeleteOut,
  type BusinessKind,
  type MetamodelCleanupSummaryOut,
} from "@/lib/api";
import { entityKindLabel, entityKindLabelLower, entityKindWithArticle } from "@/lib/entity-kind";
import { notifyError, type NotifyErrorOptions } from "@/lib/notify";
import { isTransientGatewayError } from "@/lib/retry-transient";

/**
 * What the user is told after a delete or an orphan drop, in one place.
 *
 * The server removes the agent's `_metamodel` rows after the delete, one
 * cleanup per version and catalog (`metamodel_cleanup`). When some did not
 * finish, every delete surface shows the same warning; only the words about
 * where to find Retry cleanup differ.
 */

/** Where Retry cleanup is, for a surface whose business (or industry) still exists. */
export function retryCleanupInExplorer(kind: BusinessKind | undefined | null): string {
  return `Retry cleanup on the ${entityKindLabelLower(kind)}'s Explorer page runs the retry now.`;
}

/** Where Retry cleanup is after a business delete: the business is gone. */
export function retryCleanupAfterRecreate(kind: BusinessKind | undefined | null): string {
  const created = entityKindWithArticle(kind);
  return `${created.charAt(0).toUpperCase()}${created.slice(1)} created again with this name lists the retries with Retry cleanup.`;
}

/** Cleanups that are failed or still pending in a delete response. */
export function countUnfinishedCleanups(cleanup: MetamodelCleanupSummaryOut | undefined | null): number {
  return (cleanup?.failed ?? 0) + (cleanup?.pending ?? 0);
}

/**
 * The success toast, or a warning when `unfinished` registry cleanups remain.
 * `retryHint` says where Retry cleanup is on the calling surface.
 */
export function notifyCleanupOutcome({
  title,
  unfinished,
  retryHint,
}: {
  title: string;
  unfinished: number;
  retryHint: string;
}): void {
  if (unfinished === 0) {
    toast.success(title);
    return;
  }
  toast.warning(title, {
    description:
      `${unfinished} registry ${unfinished === 1 ? "cleanup" : "cleanups"} did not finish, ` +
      "so the agent's registry rows are still there. " +
      `The app retries at the next start-ups. ${retryHint}`,
  });
}

/** The one toast for a finished business (or industry) delete. */
export function notifyBusinessDeleted(
  result: BusinessDeleteOut | undefined,
  kind: BusinessKind | undefined | null,
  name?: string,
): void {
  notifyCleanupOutcome({
    title: name ? `Deleted "${name}"` : `${entityKindLabel(kind)} deleted`,
    unfinished: countUnfinishedCleanups(result?.metamodel_cleanup),
    retryHint: retryCleanupAfterRecreate(kind),
  });
}

/**
 * What a version, business or industry delete does to the Volume: it removes
 * the folder the app wrote for each version (`version_files.app_written_folder`
 * on the server: a copy made from 0.9.0, whose import markers are set), never
 * an older copy or a file someone else wrote.
 */
export const APP_FOLDERS_DELETE_NOTE =
  "The model files the app copied into its own Volume folders at download, kickstart or import (from 0.9.0) are deleted. " +
  "Older copies, files the agent wrote, and the file an import read, stay.";

export const DELETE_MAY_BE_FINISHING = "The delete may still be finishing; refresh to check.";

/**
 * True for a 502/503/504 from the Apps proxy with no answer from the app in
 * the body: the request may have reached the server and committed. A 503 the
 * app sent itself (it carries a `detail`) is a real answer and is not this.
 */
export function isLostDeleteAnswer(err: unknown): boolean {
  if (!isTransientGatewayError(err)) return false;
  const body = (err as ApiError).body;
  return !(body !== null && typeof body === "object" && "detail" in body);
}

/**
 * A failed delete as a toast. Returns true when the answer was lost (the
 * delete may have committed), so the caller refreshes its list.
 */
export function notifyDeleteFailed(err: unknown, options?: NotifyErrorOptions): boolean {
  if (isLostDeleteAnswer(err)) {
    toast.warning(DELETE_MAY_BE_FINISHING);
    return true;
  }
  notifyError(err, options);
  return false;
}
