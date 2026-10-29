/**
 * Vibe scope helpers for scoped vibe iterations (design
 * `2026-10-18-single-domain-vibe-scope-design.md` §9).
 *
 * - `scopeKey` is the JS mirror of the backend `core/_vibe_scope.scope_key`
 *   (the agent's own rule): lowercase, then keep only `[a-z0-9]`.
 * - The deep-link parsers read the New Run search params `scopeDomains`
 *   (comma-separated) and `runMode` (`dry` | `full`, an explicit choice).
 * - `derivedRunMode` / `vibeScopeRequestFields` hold the run-type default and
 *   the request-body shape.
 * - `stripVibeMarkers` removes the K1 markers (`<!-- vi:<id> target=… -->`)
 *   the server adds to the agent text, so they never show raw in the UI (D16).
 * - The consequence copy is shared by the scope control and the launch dialog.
 */

import type { VibeScope } from "@/lib/api";
import { joinCommaList, splitCommaList } from "@/lib/comma-list";

/** The scopes the form offers; Some Subdomains is not offered. */
export type VibeScopeMode = Exclude<VibeScope, "some_subdomains">;
export type AgentRunMode = "dry" | "full";

/** The agent's entry-matching rule: lowercase, keep only letters and digits. */
export function scopeKey(name: string): string {
  return String(name).toLowerCase().replace(/[^a-z0-9]/g, "");
}

/** Parse the `scopeDomains` search param: a comma list (`splitCommaList`),
 *  then deduplicated by `scopeKey` (first spelling wins). */
export function parseScopeDomainsParam(raw: unknown): string[] {
  if (raw == null) return [];
  const names = Array.isArray(raw)
    ? splitCommaList(raw.map(String).join(","))
    : splitCommaList(String(raw));
  const seen = new Set<string>();
  return names.filter((name) => {
    const key = scopeKey(name) || name;
    if (seen.has(key)) return false;
    seen.add(key);
    return true;
  });
}

/** Parse the `runMode` search param. Anything other than `dry`/`full` is ignored. */
export function parseRunModeParam(raw: unknown): AgentRunMode | undefined {
  const v = typeof raw === "string" ? raw.trim().toLowerCase() : "";
  return v === "dry" || v === "full" ? v : undefined;
}

/**
 * Match requested scope names against the base version's domain names with
 * `scopeKey`. Returns the canonical (stored) names for the matches, in request
 * order and deduplicated, and the requested names that match no domain.
 */
export function matchScopeDomains(
  requested: readonly string[],
  domainNames: readonly string[],
): { matched: string[]; unknown: string[] } {
  const byKey = new Map<string, string>();
  for (const name of domainNames) {
    const key = scopeKey(name);
    if (key && !byKey.has(key)) byKey.set(key, name);
  }
  const matched: string[] = [];
  const unknown: string[] = [];
  const seen = new Set<string>();
  for (const name of requested) {
    const key = scopeKey(name);
    const canonical = byKey.get(key);
    if (canonical) {
      if (seen.has(key)) continue;
      seen.add(key);
      matched.push(canonical);
    } else {
      unknown.push(name);
    }
  }
  return { matched, unknown };
}

// A well-formed K1 marker only, mirroring the agent's `_VIBE_INPUT_MARKER_RE`:
// the id has no spaces or `>`, and the target cannot cross `<`, `>` or a line
// break, so a stray `<!-- vi:` in user text never swallows a later marker.
const VIBE_MARKER_RE = /<!--\s*vi:[A-Za-z0-9_.:-]+\s+target=[^<>\n]*?-->/g;

/**
 * Remove K1 markers from agent text before display (D16).
 *
 * A trailing marker is removed along with the space before it. A line that
 * holds only a marker is removed entirely. Lines with no well-formed marker
 * are kept byte-for-byte.
 */
export function stripVibeMarkers(text: string | null | undefined): string {
  if (!text) return "";
  if (!text.includes("<!--")) return text;
  const out: string[] = [];
  for (const line of text.split("\n")) {
    const removed = line.replace(VIBE_MARKER_RE, "");
    if (removed === line) {
      out.push(line);
      continue;
    }
    const stripped = removed.replace(/[ \t]+$/, "");
    if (stripped.trim() === "") continue;
    out.push(stripped);
  }
  return out.join("\n");
}

/**
 * The run type used when the user has not chosen one: Dry Run for both scopes.
 * The user reviews the draft and installs it. This is the form default only;
 * the API default `RunIn.dry_run=false` is unchanged.
 */
export function derivedRunMode(): AgentRunMode {
  return "dry";
}

/**
 * Vibe scope fields for a vibe-iteration request body. An unscoped Full Run
 * sends nothing, so its body stays identical to the body sent before the
 * scope feature (the server defaults are All Domains + Full Run). An unscoped
 * Dry Run, the form default, sends only `dry_run: true`.
 */
export function vibeScopeRequestFields(
  scope: VibeScopeMode,
  domains: readonly string[],
  mode: AgentRunMode,
): { vibe_scope?: VibeScopeMode; vibe_scope_domains?: string[]; dry_run?: boolean } {
  if (scope === "some_domains") {
    return { vibe_scope: scope, vibe_scope_domains: [...domains], dry_run: mode === "dry" };
  }
  return mode === "dry" ? { dry_run: true } : {};
}

/** Plain-language consequence of a Dry Run (§9.1, §10). */
export const DRY_RUN_CONSEQUENCE =
  "Builds the new version and its files, but deploys no tables. "
  + "The result is a draft: it is not the latest version, and no feedback is marked as done.";

/** Plain-language consequence of a Full Run (§9.1, §10), naming the catalog. */
export function fullRunConsequence(catalog: string): string {
  const target = catalog.trim() || "the deployment catalog";
  return (
    `Deploys to ${target}. With Some domains, the agent is asked to change only those `
    + "domains, but it can still change tables in other domains. A table whose structure "
    + "changes may be replaced and lose its rows. With All domains, if the base is not the "
    + "version installed there, the agent drops and rebuilds every schema this business owns."
  );
}

/** Confirm-dialog scope label: "All domains" or "Some domains: a, b". */
export function scopeLabel(scope: VibeScopeMode, domains: readonly string[]): string {
  if (scope === "all_domains") return "All domains";
  return domains.length > 0 ? `Some domains: ${joinCommaList(domains)}` : "Some domains";
}

/** Labels for the compile `excluded_reasons` values shown under the preview. */
export const EXCLUDED_REASON_LABELS: Record<string, string> = {
  out_of_scope: "Not sent (other domain)",
  model_wide_in_scoped_run: "Not sent (model-wide)",
  deprecated: "Not sent (deprecated)",
  no_anchor_on_version: "Not sent (no anchor on this version)",
  missing: "Not sent (not found)",
};

/** Dry Run and scope facts recorded in a run's `parameters_json` snapshot. */
export function parseRunVibeScope(params: Record<string, unknown>): {
  dryRun: boolean;
  scopeDomains: string[] | null;
} {
  const dryRun = params["dry_run"] === true;
  const scope = params["vibe_scope"];
  const raw = params["vibe_scope_domains"];
  const domains = Array.isArray(raw)
    ? raw.filter((d): d is string => typeof d === "string" && d.trim() !== "")
    : [];
  const scoped = scope === "some_domains" || scope === "some_subdomains";
  return { dryRun, scopeDomains: scoped ? domains : null };
}

/** Where a pre-filled scope came from. Only the compose surface sets it. */
export type ScopeFrom = "feedback";

/** Parse the `scopeFrom` search param. Anything other than `feedback` is ignored. */
export function parseScopeFromParam(raw: unknown): ScopeFrom | undefined {
  return typeof raw === "string" && raw.trim().toLowerCase() === "feedback" ? "feedback" : undefined;
}

/**
 * The distinct scope domains of the selected feedback, from the compile's
 * `input_scope_domains` (the backend rule the scoped compile filters by).
 * Names keep the first spelling and the order of `selectedIds`. Selected items
 * with no domain (model-wide, no anchor on the version) are not in the list.
 */
export function feedbackScopeDomains(
  inputScopeDomains: Readonly<Record<string, string | null | undefined>> | undefined,
  selectedIds: readonly string[],
): string[] {
  const seen = new Set<string>();
  const names: string[] = [];
  for (const id of selectedIds) {
    const name = inputScopeDomains?.[id];
    if (!name) continue;
    const key = scopeKey(name) || name;
    if (seen.has(key)) continue;
    seen.add(key);
    names.push(name);
  }
  return names;
}

/**
 * The domains a feedback-driven run opens scoped to, or `[]` for All domains.
 * `[]` when no selected item has a domain, none matches a domain of the base,
 * or the feedback covers every domain of the base. Names come back in the
 * base's spelling.
 */
export function feedbackScopePrefill(
  feedbackDomains: readonly string[],
  baseDomainNames: readonly string[],
): string[] {
  const { matched } = matchScopeDomains(feedbackDomains, baseDomainNames);
  if (matched.length === 0) return [];
  const baseKeys = new Set(baseDomainNames.map(scopeKey).filter(Boolean));
  const matchedKeys = new Set(matched.map(scopeKey));
  return matchedKeys.size >= baseKeys.size ? [] : matched;
}

/** The count of selected items a scoped compile leaves out as model-wide. */
export function modelWideExcludedCount(
  excludedReasons: Readonly<Record<string, string>> | undefined,
): number {
  return Object.values(excludedReasons ?? {}).filter((r) => r === "model_wide_in_scoped_run").length;
}

export function scopePrefillBanner(itemCount: number, domains: readonly string[]): string {
  const items = itemCount === 1 ? "1 selected feedback item" : `${itemCount} selected feedback items`;
  return `Scope pre-filled from your ${items}: ${joinCommaList(domains)}. Change it below.`;
}

export function modelWideScopeNote(count: number): string {
  return count === 1
    ? "1 selected item is model-wide and is not sent in a scoped run. Switch to All domains to include it."
    : `${count} selected items are model-wide and are not sent in a scoped run. Switch to All domains to include them.`;
}

export function scopedNeedsLatestNote(headLabel: string): string {
  return `Scoped runs need the latest version (${headLabel}).`;
}
