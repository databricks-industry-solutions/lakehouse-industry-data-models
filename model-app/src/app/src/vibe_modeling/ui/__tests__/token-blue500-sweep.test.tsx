/**
 * Lock the `--primary` token contract for "active / running / in-progress"
 * semantic sites that previously used raw `text-blue-500` / `bg-blue-500/X` /
 * `border-blue-500/X`.
 *
 * These sites render the same DuBois hue today only because the literal
 * tailwind `blue-500` palette entry sits near `--primary`. If `--primary`
 * ever moves, the raw classes would desync — that's why they must be
 * migrated to the token.
 *
 * The test does two things:
 *   1. Asserts the run-hierarchy running-status markup uses `text-primary`.
 *   2. Grep-locks the source files: no raw `text-blue-500` / `bg-blue-500`
 *      / `border-blue-500` may sneak back into the in-scope files.
 */
import { describe, expect, it } from "vitest";
import { readFileSync } from "node:fs";
import { resolve } from "node:path";

const UI_SRC_ROOT = resolve(__dirname, "..");

function readSource(relPath: string): string {
  return readFileSync(resolve(UI_SRC_ROOT, relPath), "utf8");
}

describe("token-blue500 sweep — `--primary` for active/running semantic", () => {
  // ---------------------------------------------------------------------
  // Grep-lock: no raw blue-500 may sneak back into the in-scope files.
  // The run-hierarchy-pipeline rendering tests against a full Op tree live
  // in run-hierarchy-pipeline.test.tsx; for the className contract here we
  // use a source grep — cheap, refactor-resistant, and catches stray
  // re-introductions anywhere in the file.
  // ---------------------------------------------------------------------
  const IN_SCOPE_FILES = [
    "components/runs/run-hierarchy-pipeline.tsx",
    "components/settings/agent-status-row.tsx",
  ];

  it.each(IN_SCOPE_FILES)(
    "%s contains no raw text-blue-500 / bg-blue-500 / border-blue-500 classes",
    (relPath) => {
      const src = readSource(relPath);
      expect(src).not.toMatch(/\btext-blue-500\b/);
      expect(src).not.toMatch(/\bbg-blue-500\b/);
      expect(src).not.toMatch(/\bborder-blue-500\b/);
    },
  );

  it("run-hierarchy-pipeline running step + spinner sites use text-primary", () => {
    const src = readSource("components/runs/run-hierarchy-pipeline.tsx");
    // Sanity: the running-status colour must use the primary token at all
    // five migrated sites (StepStatusIcon, EventIcon, stepNameColor map,
    // and the two standalone Loader2 spinners).
    const primaryMatches = src.match(/text-primary\b/g)?.length ?? 0;
    expect(primaryMatches).toBeGreaterThanOrEqual(5);
    expect(src).toContain('running: "text-primary"');
  });
});
