/**
 * Pure derivation of the New Run form's submit-button blockers.
 *
 * Drift-unification (the model-versioning work, Phase 5): two booleans
 * (`baseContextMissing`, `vibeInstructionsMissing`) were derived inline
 * inside `routes/_sidebar/runs.new.tsx` and then re-tested in the Submit
 * `disabled` prop, with copy-paste comments explaining each gate. Adding a
 * third gate meant remembering to update both call sites and keeping the
 * disabled-reason banner in sync with the actual disabled condition.
 *
 * One pure function so the form just spreads the result and renders the
 * correct inline reason.
 */

import type { ModelVersionOut } from "@/lib/api";
import { isModelVersion, replacedBadgeLabel } from "@/lib/version-lifecycle";
import { versionScopeLabel } from "@/lib/version-label";

export interface RunFormState {
  isBase: boolean;
  isVibe: boolean;
  contextMode: "text" | "path";
  businessContextText: string;
  businessContextPath: string;
  /** Count of Vibe Inputs selected on the compose surface that will be compiled
   *  into the run (the read-only compiled preview is their rendering). */
  inputCount: number;
}

export interface RunFormBlockers {
  /** new-base-model with neither freeform context nor a context path. */
  baseContextMissing: boolean;
  /** vibe-* run with no selected Vibe Inputs. The selected inputs (compiled
   *  server-side) are the content; an empty selection is the blocker. */
  vibeContentMissing: boolean;
  /** True when there is at least one blocker — handy as a single test
   *  for the `disabled` prop. Doesn't include external blockers like
   *  `submitting` or live-validate errors; those stay caller-owned. */
  hasBlocker: boolean;
}

/**
 * Compute submit blockers from the form state. Pure; no side effects.
 *
 * Intentionally does NOT include `submitting`, `eligibleBaseVersions.length === 0`,
 * or live `validateBlockers` — those are runtime/external concerns the form
 * combines with the result of this function. The split keeps this helper a
 * pure function of form-input state, which is testable in isolation and
 * doesn't drag the entire validator stack into a unit test.
 */
export function deriveRunFormBlockers(state: RunFormState): RunFormBlockers {
  const baseContextMissing =
    state.isBase
    && (
      (state.contextMode === "text" && state.businessContextText.trim() === "")
      || (state.contextMode === "path" && state.businessContextPath.trim() === "")
    );

  const vibeContentMissing = state.isVibe && state.inputCount === 0;

  return {
    baseContextMissing,
    vibeContentMissing,
    hasBlocker: baseContextMissing || vibeContentMissing,
  };
}

/** The version fields the Base Version picker reads. */
export type BaseVersionRow = Pick<
  ModelVersionOut,
  "id" | "version" | "scope" | "status" | "replaced_at" | "replaced_by_version_id"
>;

/**
 * The versions a Vibe Modeling run can use as its base: every finished,
 * non-draft model, superseded ones included. The server takes the explicit
 * parent whatever its status and warns when newer versions follow it
 * (`validate.py` `dry_run` warning), so the picker does not hide them.
 * Input order is kept.
 */
export function baseVersionCandidates<T extends BaseVersionRow>(versions: readonly T[]): T[] {
  return versions.filter(isModelVersion);
}

/** True when a version was superseded by a newer one. */
export function isSupersededBase(v: Pick<BaseVersionRow, "status">): boolean {
  return v.status === "superseded";
}

/**
 * The picker label: "v2 MVM", " (vibed)" only when `isBase` says a vibe
 * produced it (the explorer's brand, `VersionTreeOut.is_base`; unknown reads
 * as no text), " (superseded)" from the status, and the explorer's own
 * " (Replaced by v3)" when the version was replaced (`replacedBadgeLabel`).
 */
export function baseVersionLabel(
  v: BaseVersionRow,
  versions: readonly BaseVersionRow[],
  isBase: boolean | undefined,
): string {
  const parts = [versionScopeLabel(v.version, v.scope || "mvm")];
  if (isBase === false) parts.push("(vibed)");
  if (isSupersededBase(v)) parts.push("(superseded)");
  const replaced = replacedBadgeLabel(v, versions);
  if (replaced) parts.push(`(${replaced})`);
  return parts.join(" ");
}

/**
 * Said under the Base Version picker when a deep link names a version the
 * picker does not offer for this run: `null` when the named version is
 * offered (or the link names none), else why not and which version the form
 * selected instead.
 */
export function baseDeepLinkNotice(args: {
  sourceVersion: number | null | undefined;
  sourceScope: string | null | undefined;
  versions: readonly BaseVersionRow[];
  eligible: readonly BaseVersionRow[];
  selected: BaseVersionRow | undefined;
  needsEcm: boolean;
}): string | null {
  const { sourceVersion, versions, eligible, selected, needsEcm } = args;
  if (sourceVersion == null) return null;
  const wantedScope = args.sourceScope ? args.sourceScope.toLowerCase() : null;
  const scopeOf = (v: BaseVersionRow) => (v.scope || "mvm").toLowerCase();
  const matches = (v: BaseVersionRow) =>
    v.version === sourceVersion && (wantedScope == null || scopeOf(v) === wantedScope);
  if (eligible.some(matches)) return null;
  const named = versions.find(matches);
  const label = named
    ? versionScopeLabel(named.version, scopeOf(named))
    : versionScopeLabel(sourceVersion, wantedScope);
  let why: string;
  if (!named) why = "does not exist";
  else if (named.status === "draft") why = "is a Dry Run draft";
  else if (named.status === "generating") why = "is still generating";
  else if (named.status === "failed") why = "failed";
  else if (needsEcm && scopeOf(named) !== "ecm") why = "is not an ECM; this run needs an ECM as its base";
  else why = "cannot be used as a base";
  const instead = selected
    ? `${versionScopeLabel(selected.version, scopeOf(selected))} is selected instead.`
    : "No other version is available to select.";
  return `The link points to ${label}, which ${why}. ${instead}`;
}

/**
 * True when the agent tears down this business's schemas in the run's catalog
 * at the start of the run (`_staging_catalog_teardown` in the vendored agent):
 * a Vibe Modeling Full Run (not a Dry Run, and not a Some domains run, which
 * skip it) and the shrink step of Vibe ECM + MVM. New Base Model's shrink
 * drops only its own new ECM's schemas: the business has no versions, so
 * there is nothing else to warn about.
 */
export function runDropsOwnSchemas(state: {
  isVibeIterate: boolean;
  isVibeCombined: boolean;
  dryRun: boolean;
  scoped: boolean;
}): boolean {
  if (state.isVibeCombined) return true;
  return state.isVibeIterate && !state.dryRun && !state.scoped;
}
