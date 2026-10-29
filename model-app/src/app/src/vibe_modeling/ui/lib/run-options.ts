/**
 * The agent's own widget values the New Run form offers, verbatim and in the
 * agent's order, and the agent version that Dry Runs and scoped runs need.
 *
 * `tests/fixtures/agent_widget_options.json` holds the agent's lists; the
 * backend pins it to the vendored notebook (`test_agent_widget_options.py`)
 * and `__tests__/run-options.test.ts` pins these constants to it, so an agent
 * upgrade that changes a list fails on both sides. `org_divisions` lives in
 * `lib/org-divisions.ts`.
 */

export const NAMING_CONVENTIONS = ["snake_case", "camelCase", "PascalCase", "SCREAMING_CASE"] as const;
/** The agent also offers LONG; the form leaves it out. */
export const TABLE_ID_TYPES = ["BIGINT", "INT", "STRING"] as const;
export const BOOLEAN_FORMATS = ["Boolean (True/False)", "Int (0/1)", "String (Y/N)"] as const;
export const DATE_FORMATS = ["yyyy-MM-dd", "dd/MM/yyyy", "MM/dd/yyyy", "yyyy/MM/dd", "dd-MM-yyyy"] as const;
export const TIMESTAMP_FORMATS = [
  "yyyy-MM-dd'T'HH:mm:ss.SSSXXX",
  "yyyy-MM-dd HH:mm:ss",
  "yyyy-MM-dd'T'HH:mm:ss",
  "yyyy-MM-dd HH:mm:ss.SSS",
] as const;
export const CATALOGING_STYLES = ["One Catalog", "Catalog per Division", "Catalog per Domain"] as const;
/** `housekeeping_columns` and `history_tracking_columns`. */
export const NO_YES = ["No", "Yes"] as const;

/** Backend `core/_vibe_scope.MIN_AGENT_MARKER_FOR_SCOPE`. */
export const MIN_AGENT_MARKER_FOR_SCOPE = "5.3.3";

function tagParts(tag: string): number[] {
  const parts: number[] = [];
  for (const chunk of tag.trim().replace(/^v/i, "").split(".")) {
    if (!/^\d+$/.test(chunk)) break;
    parts.push(Number(chunk));
  }
  return parts.length > 0 ? parts : [0];
}

/**
 * True when `candidate` sorts strictly after `baseline`. Mirrors the
 * backend `agent_compat.is_newer_tag`: numeric parts up to the first
 * non-numeric one, a `v` prefix ignored, and a shorter tag sorting first
 * when it is a prefix of the longer one.
 */
export function isNewerTag(candidate: string, baseline: string): boolean {
  const a = tagParts(candidate);
  const b = tagParts(baseline);
  for (let i = 0; i < Math.min(a.length, b.length); i++) {
    if (a[i] !== b[i]) return a[i] > b[i];
  }
  return a.length > b.length;
}

/**
 * The configured agent's version when it is known to predate Dry Runs and
 * scoped runs, else `null` (new enough, not read yet, or not a version).
 */
export function agentTooOldForScope(installedMarker: string | null | undefined): string | null {
  const reported = (installedMarker ?? "").trim();
  // Not a version (empty, "unknown", ...): treat as not read yet.
  if (!/^v?\d/i.test(reported)) return null;
  return isNewerTag(MIN_AGENT_MARKER_FOR_SCOPE, reported) ? reported.replace(/^v/i, "") : null;
}
