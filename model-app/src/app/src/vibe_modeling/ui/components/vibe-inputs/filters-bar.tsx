import { Search } from "lucide-react";
import { Input } from "@/components/ui/input";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import type { VibeInputOut } from "@/lib/api";
import { deriveInputState } from "./state";
import { domainNameFromPath } from "./section-tree-model";

/** Origin filter group. "import" is a client-side group matching any `*_import`
 *  origin (v1 generates none, but the control is forward-compatible). */
export type OriginFilter = "all" | "user" | "agent_next_vibe" | "change_rejection" | "import";
export type StateFilter = "all" | "active" | "consumed" | "needs_link_review" | "deprecated";
export type PriorityFilter = "all" | "high" | "medium" | "low";
export type SelectedFilter = "all" | "selected" | "not_selected";

export interface InputFilters {
  q: string;
  origin: OriginFilter;
  state: StateFilter;
  priority: PriorityFilter;
  selected: SelectedFilter;
  /** "all" = no filter, MODEL_WIDE_DOMAIN = model-wide inputs, otherwise a domain name. */
  domain: string;
}

/** `InputFilters.domain` value selecting model-wide inputs: `model_wide`-level or
 *  empty-path anchors (the section tree's root). Inputs with a null anchor are
 *  excluded. */
export const MODEL_WIDE_DOMAIN = "__model_wide__";

export const DEFAULT_FILTERS: InputFilters = {
  q: "",
  origin: "all",
  state: "all",
  priority: "all",
  selected: "all",
  domain: "all",
};

/** Where an input sits for the domain facet. "none" = no anchor (the tree drops
 *  it), "model_wide" = the tree's root (model_wide level or empty path, even if
 *  `domain_name` is set), otherwise the domain named by the path's "Domain: X"
 *  label, else `anchor.domain_name`. Relationship anchors have no Domain label,
 *  so an intra-domain FK is filed under its `domain_name` and a cross-domain FK
 *  (no `domain_name`) matches only "all". */
export type InputDomain =
  | { kind: "none" }
  | { kind: "model_wide" }
  | { kind: "domain"; name: string };

export function inputDomain(input: Pick<VibeInputOut, "anchor">): InputDomain {
  const anchor = input.anchor;
  if (!anchor) return { kind: "none" };
  const path = anchor.path ?? [];
  if (anchor.level === "model_wide" || path.length === 0) return { kind: "model_wide" };
  const name = domainNameFromPath(path) ?? anchor.domain_name;
  return name ? { kind: "domain", name } : { kind: "none" };
}

/** Unique domain names across `inputs`, sorted, for the domain facet options. */
export function collectDomainOptions(inputs: readonly VibeInputOut[]): string[] {
  const names = new Set<string>();
  for (const i of inputs) {
    const d = inputDomain(i);
    if (d.kind === "domain") names.add(d.name);
  }
  return [...names].sort((a, b) => a.localeCompare(b));
}

export interface FiltersBarProps {
  filters: InputFilters;
  onChange: (next: InputFilters) => void;
  /** Count after filtering. */
  shown: number;
  /** Total before filtering. */
  total: number;
  /** Show the origin facet. Defaults on; a caller can hide it where origin is
   *  fixed. */
  showOrigin?: boolean;
  /** Show the selection facet. Hidden where there is no run selection (Feedback tab). */
  showSelected?: boolean;
  /** Offer the Deprecated state. Hidden where the list holds active inputs only
   *  (Feedback tab), so the facet cannot be chosen into an empty list. */
  showDeprecated?: boolean;
  /** Domain names for the domain facet. The facet renders when non-empty or
   *  while a domain filter is active, so the active filter can always be cleared. */
  domains?: string[];
  /** Noun for the count hint ("inputs" on compose, "feedback" on the tab). */
  noun?: string;
  /** Offer the "Rejected change" origin: only while the run change review,
   *  which makes that feedback, is on (`useRunChangeReviewEnabled`). */
  offerRejectedOrigin?: boolean;
}

export function FiltersBar({
  filters,
  onChange,
  shown,
  total,
  showOrigin = true,
  showSelected = true,
  showDeprecated = true,
  domains,
  noun = "inputs",
  offerRejectedOrigin = false,
}: FiltersBarProps) {
  const domainOptions =
    filters.domain === "all" ||
    filters.domain === MODEL_WIDE_DOMAIN ||
    domains?.includes(filters.domain)
      ? (domains ?? [])
      : [...(domains ?? []), filters.domain];

  const set = <K extends keyof InputFilters>(key: K, value: InputFilters[K]) =>
    onChange({ ...filters, [key]: value });

  return (
    <div className="flex flex-wrap items-center gap-2 border-b border-border px-3 py-2">
      <div className="relative w-[260px]">
        <Search className="pointer-events-none absolute left-2 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
        <Input
          value={filters.q}
          onChange={(e) => set("q", e.target.value)}
          placeholder="Search instructions…"
          aria-label="Search instructions"
          className="pl-8"
        />
      </div>

      {showOrigin && (
        <Select value={filters.origin} onValueChange={(v) => set("origin", v as OriginFilter)}>
          <SelectTrigger className="w-[150px]" aria-label="Filter by origin">
            <SelectValue placeholder="Origin" />
          </SelectTrigger>
          <SelectContent>
            <SelectItem value="all">All origins</SelectItem>
            <SelectItem value="user">User</SelectItem>
            <SelectItem value="agent_next_vibe">AI suggestion</SelectItem>
            {offerRejectedOrigin && <SelectItem value="change_rejection">Rejected change</SelectItem>}
            <SelectItem value="import">Import</SelectItem>
          </SelectContent>
        </Select>
      )}

      <Select value={filters.state} onValueChange={(v) => set("state", v as StateFilter)}>
        <SelectTrigger className="w-[160px]" aria-label="Filter by state">
          <SelectValue placeholder="State" />
        </SelectTrigger>
        <SelectContent>
          <SelectItem value="all">All states</SelectItem>
          <SelectItem value="active">Active</SelectItem>
          <SelectItem value="consumed">Consumed</SelectItem>
          <SelectItem value="needs_link_review">Needs link review</SelectItem>
          {showDeprecated && <SelectItem value="deprecated">Deprecated</SelectItem>}
        </SelectContent>
      </Select>

      <Select value={filters.priority} onValueChange={(v) => set("priority", v as PriorityFilter)}>
        <SelectTrigger className="w-[140px]" aria-label="Filter by priority">
          <SelectValue placeholder="Priority" />
        </SelectTrigger>
        <SelectContent>
          <SelectItem value="all">All priorities</SelectItem>
          <SelectItem value="high">High</SelectItem>
          <SelectItem value="medium">Medium</SelectItem>
          <SelectItem value="low">Low</SelectItem>
        </SelectContent>
      </Select>

      {(domainOptions.length > 0 || filters.domain !== "all") && (
        <Select value={filters.domain} onValueChange={(v) => set("domain", v)}>
          <SelectTrigger className="w-[170px]" aria-label="Filter by domain">
            <SelectValue placeholder="Domain" />
          </SelectTrigger>
          <SelectContent>
            <SelectItem value="all">All domains</SelectItem>
            <SelectItem value={MODEL_WIDE_DOMAIN}>Model-wide</SelectItem>
            {domainOptions.map((d) => (
              <SelectItem key={d} value={d}>
                {d}
              </SelectItem>
            ))}
          </SelectContent>
        </Select>
      )}

      {showSelected && (
        <Select value={filters.selected} onValueChange={(v) => set("selected", v as SelectedFilter)}>
          <SelectTrigger className="w-[150px]" aria-label="Filter by selection">
            <SelectValue placeholder="Selection" />
          </SelectTrigger>
          <SelectContent>
            <SelectItem value="all">All inputs</SelectItem>
            <SelectItem value="selected">Selected</SelectItem>
            <SelectItem value="not_selected">Not selected</SelectItem>
          </SelectContent>
        </Select>
      )}

      <span className="ml-auto text-xs text-muted-foreground" data-testid="filters-count">
        {shown} of {total} {noun}
      </span>
    </div>
  );
}

/** Translate the filter UI state into the `listVibeInputs` server query params.
 *  Returns the params object the caller spreads into the list hook. State maps
 *  to status/consumed/needs_link_review; the "import" origin group can't be a
 *  single enum, so it's applied client-side by the caller (no import origins in
 *  v1). The domain facet has no server param and is applied client-side by
 *  `applyFilters`. */
export function filtersToQueryParams(filters: InputFilters): {
  q?: string;
  origin?: "user" | "agent_next_vibe" | "change_rejection";
  status?: "active" | "deprecated";
  consumed?: boolean;
  needs_link_review?: boolean;
  priority?: "high" | "medium" | "low";
} {
  const params: ReturnType<typeof filtersToQueryParams> = {};
  if (filters.q.trim()) params.q = filters.q.trim();
  if (filters.origin !== "all" && filters.origin !== "import") {
    params.origin = filters.origin;
  }
  if (filters.priority !== "all") params.priority = filters.priority;
  switch (filters.state) {
    case "deprecated":
      params.status = "deprecated";
      break;
    case "consumed":
      params.status = "active";
      params.consumed = true;
      break;
    case "needs_link_review":
      params.status = "active";
      params.needs_link_review = true;
      break;
    case "active":
      params.status = "active";
      params.consumed = false;
      break;
  }
  return params;
}

/** Client-side filter over an already-fetched input list. The single
 *  implementation shared by the compose surface and the Feedback tab so the two
 *  can't drift. The `selected` facet is orthogonal to q/origin/state/priority/domain
 *  and is evaluated against the caller's server-backed selection set (empty on
 *  surfaces without run selection, where the `selected` filter stays "all"). */
export function applyFilters(
  inputs: readonly VibeInputOut[],
  filters: InputFilters,
  selectedIds: ReadonlySet<string>,
): VibeInputOut[] {
  const q = filters.q.trim().toLowerCase();
  return inputs.filter((i) => {
    const isDeprecated = i.status === "deprecated";
    // Deprecated is an EXCLUSIVE state facet. Selecting "Deprecated" shows only
    // deprecated inputs; every other state (and "all") hides them — deprecated
    // inputs never mix with active ones in the same list.
    if (filters.state === "deprecated") {
      if (!isDeprecated) return false;
    } else if (isDeprecated) {
      return false;
    }
    if (q && !i.text.toLowerCase().includes(q)) return false;
    if (filters.origin === "import" && !String(i.origin).endsWith("_import")) return false;
    if (filters.origin !== "all" && filters.origin !== "import" && i.origin !== filters.origin) return false;
    if (filters.priority !== "all" && i.priority !== filters.priority) return false;
    if (filters.state !== "all" && filters.state !== "deprecated") {
      const st = deriveInputState(i, undefined);
      // needs_link_review can't be derived without links on the list; treat the
      // consumed/active states only here.
      if (filters.state === "consumed" && !i.consumed) return false;
      if (filters.state === "active" && (i.consumed || st !== "active")) return false;
    }
    if (filters.domain !== "all") {
      const d = inputDomain(i);
      const matches =
        filters.domain === MODEL_WIDE_DOMAIN
          ? d.kind === "model_wide"
          : d.kind === "domain" && d.name === filters.domain;
      if (!matches) return false;
    }
    if (filters.selected === "selected" && !selectedIds.has(i.id)) return false;
    if (filters.selected === "not_selected" && selectedIds.has(i.id)) return false;
    return true;
  });
}
