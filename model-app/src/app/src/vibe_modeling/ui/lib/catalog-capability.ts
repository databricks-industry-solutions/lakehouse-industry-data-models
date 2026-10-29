/**
 * Which runs need CREATE SCHEMA in their catalog, and whether a catalog is
 * usable for a run. The twin of backend `core/_uc_privileges.run_creates_schemas`
 * and `catalog_usable`; both sides are tested against
 * `tests/fixtures/catalog_capability_rule_fixture.json`.
 */
import type { CatalogCapabilityOut } from "@/lib/api";
import { CATALOGING_STYLES } from "@/lib/run-options";

/** The agent's single-catalog style (its first `cataloging_style` option). */
export const SINGLE_CATALOG_STYLE: string = CATALOGING_STYLES[0];

const SCHEMA_CREATING_INTENTS = new Set(["new-base-model", "vibe-new-ecm-mvm", "install"]);

/** True when a run of `intent` creates schemas in its own catalog. In the
 *  multi-catalog styles the model schemas go to derived catalogs, so the
 *  run's catalog holds only `_metamodel`. */
export function runCreatesSchemas(
  intent: string,
  dryRun: boolean,
  catalogingStyle: string = SINGLE_CATALOG_STYLE,
): boolean {
  if ((catalogingStyle || SINGLE_CATALOG_STYLE) !== SINGLE_CATALOG_STYLE) return false;
  if (intent === "vibe-iterate") return !dryRun;
  return SCHEMA_CREATING_INTENTS.has(intent);
}

type Capability = Pick<CatalogCapabilityOut, "create_schema" | "use_metamodel">;

/** false when a needed check failed, null when one could not be made, else true. */
export function catalogUsable(cap: Capability, createsSchemas: boolean): boolean | null {
  const needed = [cap.use_metamodel ?? null, ...(createsSchemas ? [cap.create_schema ?? null] : [])];
  if (needed.includes(false)) return false;
  if (needed.includes(null)) return null;
  return true;
}

const GRANT_RE = /^GRANT (.+) ON (.+) TO (.+);$/;

/** The GRANT statements an admin runs so the catalog becomes usable for the
 *  run, one per securable: grants on the same securable are merged. */
export function capabilityFix(cap: CatalogCapabilityOut, createsSchemas: boolean): string {
  const parts: string[] = [];
  if (createsSchemas && cap.create_schema === false && cap.create_schema_fix) parts.push(cap.create_schema_fix);
  if (cap.use_metamodel === false && cap.use_metamodel_fix) parts.push(cap.use_metamodel_fix);
  const merged = new Map<string, { on: string; to: string; privs: Set<string> } | string>();
  for (const line of parts.flatMap((p) => p.split("\n")).filter(Boolean)) {
    const m = GRANT_RE.exec(line);
    if (!m) {
      merged.set(line, line);
      continue;
    }
    const [, privs, on, to] = m;
    const key = `${on}\u0000${to}`;
    const entry = merged.get(key);
    const target = typeof entry === "object" ? entry : { on, to, privs: new Set<string>() };
    for (const p of privs.split(",")) target.privs.add(p.trim());
    merged.set(key, target);
  }
  return Array.from(merged.values())
    .map((e) => (typeof e === "string" ? e : `GRANT ${[...e.privs].sort().join(", ")} ON ${e.on} TO ${e.to};`))
    .join("\n");
}
