import type { QueryClient } from "@tanstack/react-query";

/**
 * Invalidate every vibe-input-related query for a business after a mutation.
 * One predicate so every mutation site (card toggle, inline edit, editor
 * dialog, add-instruction, review actions) refreshes the same set — no
 * per-site key drift.
 *
 * The orval query keys for these endpoints all start with a string that
 * contains the operation path segment; matching on the substring keeps this
 * robust to orval's key shape without importing every key builder.
 */
const VIBE_INPUT_KEY_MARKERS = [
  "/inputs",
  "/links",
  "review-queue",
  "/reviews",
  "review-progress",
];

export function invalidateVibeInputQueries(
  queryClient: QueryClient,
  _businessId: string,
): Promise<void> {
  return queryClient.invalidateQueries({
    predicate: (q) => {
      const head = Array.isArray(q.queryKey) ? q.queryKey[0] : q.queryKey;
      if (typeof head !== "string") return false;
      return VIBE_INPUT_KEY_MARKERS.some((m) => head.includes(m));
    },
  });
}
