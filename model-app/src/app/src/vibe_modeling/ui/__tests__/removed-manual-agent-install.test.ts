/**
 * The manual "Install bundled agent" route and button are gone with every
 * caller (design §4): boot upgrades the app's own notebook and Settings
 * offers "Switch to bundled". Nothing in the UI, the smoke driver or the
 * generated client may call the removed routes again.
 */
import { describe, expect, it } from "vitest";
import { existsSync, readdirSync, readFileSync, statSync } from "node:fs";
import { join, resolve } from "node:path";

const UI_ROOT = resolve(__dirname, "..");
const REPO_ROOT = resolve(UI_ROOT, "../../../../..");
const REMOVED = /install-bundled-agent|admin\/bundled-agent|installBundledAgent|getBundledAgentInfo/;

function files(dir: string): string[] {
  return readdirSync(dir).flatMap((name) => {
    const p = join(dir, name);
    if (statSync(p).isDirectory()) return name === "node_modules" ? [] : files(p);
    return /\.(ts|tsx)$/.test(name) ? [p] : [];
  });
}

describe("manual agent install removed", () => {
  it("no UI source calls the removed routes", () => {
    const hits = files(UI_ROOT)
      .filter((p) => !p.endsWith("removed-manual-agent-install.test.ts"))
      .filter((p) => REMOVED.test(readFileSync(p, "utf8")));
    expect(hits).toEqual([]);
  });

  // The smoke driver is private tooling: a public clone does not ship it.
  const E2E = join(REPO_ROOT, "scripts/smoke/e2e_full.py");
  it.skipIf(!existsSync(E2E))("the e2e driver bootstraps through switch-to-bundled", () => {
    const src = readFileSync(E2E, "utf8");
    expect(src).not.toMatch(REMOVED);
    expect(src).toMatch(/\/api\/admin\/agent\/switch-to-bundled/);
  });
});
