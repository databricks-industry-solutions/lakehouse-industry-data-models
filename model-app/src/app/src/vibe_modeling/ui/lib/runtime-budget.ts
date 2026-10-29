/**
 * The agent's run time budget, in whole hours. The bounds always come from the
 * API (`AgentConfigOut.runtime_budget_min_hours` / `_max_hours`), so nothing
 * here repeats the backend's numbers.
 */

export const RUNTIME_BUDGET_SETTINGS_HINT =
  "How long the agent plans each agent job to take. In the last 40 minutes it stops " +
  "refining, and in the last ~15 it skips its per-change checks, so changes may be " +
  "reported unverified. The job is not stopped. Applies to new runs; each run can set its own.";

/** The bounds sentence both forms show, e.g. "Whole hours, 4 to 48 (the upper limit is a safety cap)." */
export function runtimeBudgetBoundsText(min: number, max: number): string {
  return `Whole hours, ${min} to ${max} (the upper limit is a safety cap).`;
}

/** A number input's text as hours: NaN when empty, fractions kept so the bounds check refuses them. */
export function parseRuntimeBudgetInput(raw: string): number {
  return raw.trim() === "" ? Number.NaN : Number(raw);
}

/**
 * The inline error for `hours`, or null when it is a whole number within
 * `[min, max]`. Unknown bounds (config not loaded) check nothing: the server
 * still rejects an out-of-range value with 422.
 */
export function runtimeBudgetBoundsError(
  hours: number | null,
  min: number | undefined,
  max: number | undefined,
): string | null {
  if (hours === null || min === undefined || max === undefined) return null;
  if (!Number.isInteger(hours) || hours < min || hours > max) {
    return `Run time budget must be a whole number of hours from ${min} to ${max}.`;
  }
  return null;
}
