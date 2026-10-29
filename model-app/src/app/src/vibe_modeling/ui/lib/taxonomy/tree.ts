/**
 * Pure taxonomy-tree operations for the Domain Taxonomy Builder. Every op
 * returns a NEW tree. `snake` is byte-identical to backend
 * taxonomy/naming.py (contract: tests/fixtures/taxonomy_snake_fixture.json).
 */
import type { TaxonomyDomain, TaxonomySection, TaxonomyTree } from "@/lib/api";
import { ORG_DIVISIONS_ALL } from "@/lib/org-divisions";

export function snake(s: string): string {
  return s
    .normalize("NFKD")
    .replace(/[^\x00-\x7f]/g, "")
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, "_")
    .replace(/^_+|_+$/g, "");
}

export function domainSchema(d: TaxonomyDomain): string {
  // Backend parity (naming.schema_for): explicit override, else snake(name) without underscores ('fieldservice').
  return (d.schema_name ?? "").trim() || snake(d.name).replace(/_/g, "");
}

export function emptyTree(): TaxonomyTree {
  return { domains: [], shared_masters: [], relationships: [], division_names: [], coverage: ORG_DIVISIONS_ALL };
}

const clone = (t: TaxonomyTree): TaxonomyTree => structuredClone(t);
const move = <T,>(arr: T[], from: number, to: number) => {
  const [x] = arr.splice(from, 1);
  arr.splice(to, 0, x);
};

export function addDomain(t: TaxonomyTree, name: string): TaxonomyTree {
  if (!name.trim()) return t;
  const n = clone(t);
  n.domains.push({ name: name.trim(), schema_name: "", subdomains: [] });
  return n;
}

/** Move masters from `before` to `after`, unless another domain still owns schema `before` (mid-typing collisions). */
function retarget(n: TaxonomyTree, d: number, before: string, after: string) {
  if (n.domains.some((x, i) => i !== d && domainSchema(x) === before)) return;
  n.shared_masters = (n.shared_masters ?? []).map((m) => (m.home_domain === before ? { ...m, home_domain: after } : m));
}

export function renameDomain(t: TaxonomyTree, d: number, name: string): TaxonomyTree {
  const n = clone(t);
  const before = domainSchema(n.domains[d]);
  n.domains[d].name = name;
  const after = domainSchema(n.domains[d]);
  retarget(n, d, before, after);
  return n;
}

export function setDomainSchema(t: TaxonomyTree, d: number, schema: string): TaxonomyTree {
  const n = clone(t);
  const before = domainSchema(n.domains[d]);
  n.domains[d].schema_name = schema;
  const after = domainSchema(n.domains[d]);
  retarget(n, d, before, after);
  return n;
}

export function removeDomain(t: TaxonomyTree, d: number): TaxonomyTree {
  const n = clone(t);
  const gone = domainSchema(n.domains[d]);
  n.domains.splice(d, 1);
  n.shared_masters = (n.shared_masters ?? []).filter((m) => m.home_domain !== gone);
  return n;
}

export function moveDomain(t: TaxonomyTree, from: number, to: number): TaxonomyTree {
  const n = clone(t);
  move(n.domains, from, to);
  return n;
}

export function addSubdomain(t: TaxonomyTree, d: number, name: string): TaxonomyTree {
  if (!name.trim()) return t;
  const n = clone(t);
  (n.domains[d].subdomains ??= []).push({ name: name.trim(), categories: [] });
  return n;
}

export function renameSubdomain(t: TaxonomyTree, d: number, s: number, name: string): TaxonomyTree {
  const n = clone(t);
  n.domains[d].subdomains![s].name = name;
  return n;
}

export function removeSubdomain(t: TaxonomyTree, d: number, s: number): TaxonomyTree {
  const n = clone(t);
  n.domains[d].subdomains!.splice(s, 1);
  return n;
}

export function moveSubdomain(t: TaxonomyTree, d: number, s: number, toD: number): TaxonomyTree {
  if (toD === d) return t;
  const n = clone(t);
  const [sub] = n.domains[d].subdomains!.splice(s, 1);
  (n.domains[toD].subdomains ??= []).push(sub);
  return n;
}

export function addCategory(t: TaxonomyTree, d: number, s: number, name: string): TaxonomyTree {
  if (!name.trim()) return t;
  const n = clone(t);
  (n.domains[d].subdomains![s].categories ??= []).push(name.trim());
  return n;
}

export function renameCategory(t: TaxonomyTree, d: number, s: number, c: number, name: string): TaxonomyTree {
  const n = clone(t);
  n.domains[d].subdomains![s].categories![c] = name;
  return n;
}

export function removeCategory(t: TaxonomyTree, d: number, s: number, c: number): TaxonomyTree {
  const n = clone(t);
  n.domains[d].subdomains![s].categories!.splice(c, 1);
  return n;
}

export function moveCategory(t: TaxonomyTree, d: number, s: number, c: number, toD: number, toS: number): TaxonomyTree {
  if (toD === d && toS === s) return t;
  const n = clone(t);
  const [cat] = n.domains[d].subdomains![s].categories!.splice(c, 1);
  (n.domains[toD].subdomains![toS].categories ??= []).push(cat);
  return n;
}

export type Sanitized = {
  tree: TaxonomyTree;
  sections: Record<string, TaxonomySection>;
  /** Blocking problems the user must fix (blank names, no domains). Create is blocked while non-empty. */
  problems: string[];
};

/**
 * Clean the editor state before compile/condense. The backend models are
 * min_length=1 on names, claim text, section claims, and relationship targets,
 * so anything blank the editor can produce would 422. Trims everything; drops
 * empty claims, blank categories, sections with zero claims, blank division
 * names, and incomplete shared masters / relationships; reports blank domain or
 * sub-domain names (which can't be dropped silently) as problems.
 */
export function sanitize(tree: TaxonomyTree, sections: Record<string, TaxonomySection>): Sanitized {
  const problems: string[] = [];
  const domains = tree.domains.map((d, di) => {
    const name = d.name.trim();
    if (!name) problems.push(`Domain ${di + 1} needs a name.`);
    return {
      name,
      schema_name: (d.schema_name ?? "").trim(),
      subdomains: (d.subdomains ?? []).map((s, si) => {
        const sub = s.name.trim();
        if (!sub) problems.push(`Sub-domain ${si + 1} in '${name || `domain ${di + 1}`}' needs a name.`);
        return { name: sub, categories: (s.categories ?? []).map((c) => c.trim()).filter(Boolean) };
      }),
    };
  });
  if (domains.length === 0) problems.push("Add at least one domain.");
  const clean: TaxonomyTree = {
    domains,
    shared_masters: (tree.shared_masters ?? [])
      .map((m) => ({ entity: m.entity.trim(), home_domain: m.home_domain.trim() }))
      .filter((m) => m.entity && m.home_domain),
    relationships: (tree.relationships ?? [])
      .map((r) => ({ source: r.source.trim(), targets: r.targets.map((x) => x.trim()).filter(Boolean) }))
      .filter((r) => r.source && r.targets.length > 0),
    division_names: (tree.division_names ?? []).map((x) => x.trim()).filter(Boolean),
    coverage: tree.coverage,
  };
  const outSections: Record<string, TaxonomySection> = {};
  for (const [k, s] of Object.entries(sections)) {
    const claims = (s.claims ?? []).map((c) => ({ ...c, text: c.text.trim() })).filter((c) => c.text);
    if (claims.length > 0) outSections[k] = { claims };
  }
  return { tree: clean, sections: outSections, problems };
}

/**
 * The finished parts of the editor state, in the backend's shape: the
 * sanitized tree when it has no problems (else null) and the sanitized
 * sections. Used to seed a draft and to save the wizard.
 */
export function finishedParts(
  tree: TaxonomyTree | null, sections: Record<string, TaxonomySection>,
): { tree: TaxonomyTree | null; sections: Record<string, TaxonomySection> } {
  const clean = sanitize(tree ?? emptyTree(), sections);
  return { tree: tree && clean.problems.length === 0 ? clean.tree : null, sections: clean.sections };
}
