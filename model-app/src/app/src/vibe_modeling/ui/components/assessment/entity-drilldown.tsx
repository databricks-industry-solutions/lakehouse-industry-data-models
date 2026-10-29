import { Fragment, useMemo, useState } from "react";
import { AlertTriangle, ChevronDown, ChevronRight } from "lucide-react";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { LetterBadge } from "@/components/assessment/letter-badge";
import { StructureBadge } from "@/components/assessment/structure-badge";
import { AgentText } from "@/components/assessment/agent-text";
import { STRUCTURE_RANK } from "@/lib/assessment";
import { SortableTableHead, useTableSort } from "@/components/ui/sortable-table-head";
import { Table, TableBody, TableCell, TableHeader, TableHead, TableRow } from "@/components/ui/table";
import type { AssessEntityOut } from "@/lib/api";

type AssessColumn = AssessEntityOut["columns"][number];

const GRADE_RANK: Record<string, number> = { blocked: 0, partial: 1, full: 2 };
const GRADE_LABEL: Record<string, string> = { full: "Full", partial: "Partial", blocked: "Blocked" };
const GRADE_CLASS: Record<string, string> = {
  full: "text-green-700",
  partial: "text-amber-600",
  blocked: "text-destructive",
};
const LETTER_RANK: Record<string, number> = { F: 0, D: 1, C: 2, B: 3, A: 4 };
const TIERS = [
  { key: "core", label: "Core" },
  { key: "enrichment", label: "Enrichment" },
  { key: "deferred_fk", label: "Deferred FK" },
  { key: "technical", label: "Technical" },
] as const;
const TIER_ORDER: Record<string, number> = { core: 0, enrichment: 1, deferred_fk: 2, technical: 3 };
const TIER_LABEL: Record<string, string> = Object.fromEntries(TIERS.map((t) => [t.key, t.label]));
const COL_SPAN = 9;

/** Old runs carry no tier; deferred-FK status still classifies the column. */
const tierOf = (c: AssessColumn) => c.tier || (c.status === "deferred_fk" ? "deferred_fk" : "");

const DupWarning = () => (
  <span className="inline-flex items-center gap-1 text-xs text-amber-600">
    <AlertTriangle className="h-3 w-3" /> Same source as another column
  </span>
);

/** Coverage percent; amber below 50. */
const Coverage = ({ pct }: { pct: number | null }) =>
  pct == null ? (
    <span className="text-muted-foreground">—</span>
  ) : (
    <span className={pct < 50 ? "font-medium text-amber-600" : ""} data-testid="coverage">
      {Math.round(pct)}%
    </span>
  );

const Dash = () => <span className="text-muted-foreground">—</span>;

function ColumnTable({ entity }: { entity: AssessEntityOut }) {
  const [tier, setTier] = useState<string>("all");
  const [expandedProfiles, setExpandedProfiles] = useState<Set<string>>(new Set());
  const cols = useMemo(
    () =>
      [...entity.columns].sort(
        (a, b) => (TIER_ORDER[tierOf(a)] ?? 4) - (TIER_ORDER[tierOf(b)] ?? 4) || a.target.localeCompare(b.target),
      ),
    [entity.columns],
  );
  const count = (k: string) => cols.filter((c) => tierOf(c) === k).length;
  const chips = [
    { key: "all", label: "All", n: cols.length },
    ...[...TIERS.map((t) => ({ key: t.key as string, label: t.label as string })), { key: "", label: "Unclassified" }]
      .map((t) => ({ ...t, n: count(t.key) }))
      .filter((t) => t.n > 0),
  ];
  const shown = tier === "all" ? cols : cols.filter((c) => tierOf(c) === tier);
  const toggleProfiles = (colId: string) => {
    const next = new Set(expandedProfiles);
    if (next.has(colId)) {
      next.delete(colId);
    } else {
      next.add(colId);
    }
    setExpandedProfiles(next);
  };
  return (
    <div className="space-y-3 py-2">
      <div className="space-y-1 text-sm">
        {entity.grade_reason && <p><AgentText text={entity.grade_reason} /></p>}
        {entity.row_filter && (
          <p className="text-muted-foreground">
            Row filter: <code className="text-xs">{entity.row_filter}</code>
          </p>
        )}
      </div>
      <h4 className="text-sm font-medium">{entity.name} columns</h4>
      {cols.length === 0 ? (
        <p className="text-sm text-muted-foreground">
          {entity.in_model ? "No column mappings." : "Net-new candidate — no columns mapped yet."}
        </p>
      ) : (
        <>
          <div className="flex flex-wrap gap-2">
            {chips.map((t) => (
              <Button
                key={t.key}
                type="button"
                size="sm"
                variant={tier === t.key ? "default" : "outline"}
                aria-pressed={tier === t.key}
                onClick={() => setTier(t.key)}
              >
                {t.label} ({t.n})
              </Button>
            ))}
          </div>
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>Target</TableHead>
                <TableHead>Tier</TableHead>
                <TableHead>Status</TableHead>
                <TableHead>Source</TableHead>
                <TableHead>Null %</TableHead>
                <TableHead>Distinct</TableHead>
                <TableHead>Evidence</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {shown.map((c) => {
                const hasProfiles = c.profiles_by_source && c.profiles_by_source.length > 0;
                const isExpanded = expandedProfiles.has(c.id);
                return (
                  <Fragment key={c.id}>
                    <TableRow>
                      <TableCell className="font-medium">
                        {c.target} {!c.in_model && <Badge variant="outline">Not in model</Badge>}
                      </TableCell>
                      <TableCell>{TIER_LABEL[tierOf(c)] ?? "—"}</TableCell>
                      <TableCell className="space-x-1">
                        {c.status === "deferred_fk" ? <Badge variant="secondary">Deferred FK</Badge> : c.status}
                        {c.dup_source && <DupWarning />}
                      </TableCell>
                      <TableCell>
                        <div className="space-y-1">
                          <div>
                            {c.source_table}
                            {c.source_column ? `.${c.source_column}` : ""}
                          </div>
                          {c.transform && <div className="text-xs text-muted-foreground">{c.transform}</div>}
                          {hasProfiles && (
                            <Button
                              type="button"
                              size="sm"
                              variant="ghost"
                              className="h-6 px-2 text-xs"
                              aria-expanded={isExpanded}
                              onClick={() => toggleProfiles(c.id)}
                            >
                              {isExpanded ? <ChevronDown className="h-3 w-3 mr-1" /> : <ChevronRight className="h-3 w-3 mr-1" />}
                              {c.profiles_by_source?.length} system{c.profiles_by_source?.length !== 1 ? "s" : ""}
                            </Button>
                          )}
                        </div>
                      </TableCell>
                      <TableCell>{c.null_pct ?? "—"}</TableCell>
                      <TableCell>{c.distinct_count ?? "—"}</TableCell>
                      <TableCell className="text-xs text-muted-foreground"><AgentText text={c.evidence} /></TableCell>
                    </TableRow>
                    {isExpanded && hasProfiles && (
                      <>
                        {c.profiles_by_source?.map((profile, idx) => (
                          <TableRow key={`${c.id}-profile-${idx}`} className="bg-muted/20">
                            <TableCell colSpan={4} className="pl-8 pr-4">
                              <div className="space-y-1">
                                <div className="text-sm font-medium">{profile.system}</div>
                                <div className="grid grid-cols-2 gap-3 text-xs">
                                  <div><span className="text-muted-foreground">Role:</span> {profile.role}</div>
                                  <div><span className="text-muted-foreground">Source:</span> {profile.source_table}.{profile.source_column}</div>
                                  <div><span className="text-muted-foreground">Rows:</span> {profile.row_count?.toLocaleString() ?? "—"}</div>
                                  <div><span className="text-muted-foreground">Null %:</span> {profile.null_pct ?? "—"}</div>
                                  <div><span className="text-muted-foreground">Distinct:</span> {profile.distinct_count?.toLocaleString() ?? "—"}</div>
                                  <div className={profile.fk_orphans && profile.fk_orphans > 0 ? "text-amber-600 font-medium" : ""}>
                                    <span className="text-muted-foreground">FK orphans:</span> {profile.fk_orphans?.toLocaleString() ?? "—"}
                                  </div>
                                  {profile.note && <div className="col-span-2"><span className="text-muted-foreground">Note:</span> {profile.note}</div>}
                                </div>
                              </div>
                            </TableCell>
                            <TableCell colSpan={3} />
                          </TableRow>
                        ))}
                      </>
                    )}
                  </Fragment>
                );
              })}
            </TableBody>
          </Table>
        </>
      )}
    </div>
  );
}

/** Sortable entities table (worst letter first); a row expands its column-mapping drill-down inline beneath it. */
export function EntityDrilldown({
  entities,
  onJumpToRef,
}: {
  entities: AssessEntityOut[];
  onJumpToRef?: (ref: string) => void;
}) {
  const [selectedId, setSelectedId] = useState<string | null>(null);
  // Pre-sorted by gate, then structure (rework first), then name, so equal letters keep a stable, readable order.
  const base = useMemo(
    () =>
      [...entities].sort(
        (a, b) => (GRADE_RANK[a.grade] ?? 3) - (GRADE_RANK[b.grade] ?? 3) ||
          (STRUCTURE_RANK[a.structure] ?? 3) - (STRUCTURE_RANK[b.structure] ?? 3) ||
          a.name.localeCompare(b.name),
      ),
    [entities],
  );
  const accessors = useMemo(
    () => ({
      letter: (e: AssessEntityOut) => (e.letter_grade ? (LETTER_RANK[e.letter_grade] ?? 5) : 5),
      name: (e: AssessEntityOut) => e.name,
      grade: (e: AssessEntityOut) => GRADE_RANK[e.grade] ?? 3,
      structure: (e: AssessEntityOut) => STRUCTURE_RANK[e.structure] ?? 3,
      core: (e: AssessEntityOut) => (e.core_total ? e.core_sourced! / e.core_total : null),
      enrichment: (e: AssessEntityOut) => e.enrichment_pct ?? (e.letter_grade ? null : e.coverage_pct),
      rows: (e: AssessEntityOut) => e.row_count,
    }),
    [],
  );
  const { sorted, sortKey, sortDir, toggle } = useTableSort<AssessEntityOut>({
    rows: base,
    accessors,
    initialKey: "letter",
  });
  const head = { sortKey, sortDir, onToggle: toggle };
  return (
    <Table>
      <TableHeader>
        <TableRow>
          <SortableTableHead columnKey="letter" {...head}>Letter</SortableTableHead>
          <SortableTableHead columnKey="structure" {...head}>Structure</SortableTableHead>
          <SortableTableHead columnKey="name" {...head}>Entity</SortableTableHead>
          <SortableTableHead columnKey="grade" {...head}>Gate</SortableTableHead>
          <SortableTableHead columnKey="core" {...head}>Core</SortableTableHead>
          <SortableTableHead columnKey="enrichment" {...head}>Enrichment</SortableTableHead>
          <TableHead>Deferred FK</TableHead>
          <SortableTableHead columnKey="rows" {...head}>Rows</SortableTableHead>
          <TableHead>Source</TableHead>
        </TableRow>
      </TableHeader>
      <TableBody>
        {sorted.map((e) => {
          const open = e.id === selectedId;
          const Chevron = open ? ChevronDown : ChevronRight;
          const deferred = e.deferred_fk_count ?? e.deferred_fk;
          return (
            <Fragment key={e.id}>
              <TableRow
                data-state={open ? "selected" : undefined}
                className="cursor-pointer"
                onClick={() => setSelectedId(open ? null : e.id)}
              >
                <TableCell><LetterBadge letter={e.letter_grade ?? null} gate={e.grade} /></TableCell>
                <TableCell><StructureBadge structure={e.structure} refs={e.structure_refs} onJump={onJumpToRef} /></TableCell>
                <TableCell className="space-x-1">
                  <button
                    type="button"
                    aria-expanded={open}
                    aria-label={`${open ? "Collapse" : "Expand"} ${e.name}`}
                    className="inline-flex items-center gap-1 font-medium text-primary hover:underline"
                  >
                    <Chevron className="h-4 w-4" aria-hidden />
                    {e.name}
                  </button>
                  {!e.in_model && <Badge variant="outline">Not in model</Badge>}
                  {e.net_new_candidate && <Badge variant="secondary">Net-new candidate</Badge>}
                  {e.dup_source > 0 && <DupWarning />}
                </TableCell>
                <TableCell className={GRADE_CLASS[e.grade]}>{GRADE_LABEL[e.grade] ?? e.grade}</TableCell>
                <TableCell>
                  {e.core_total == null ? <Dash /> : `${e.core_sourced ?? 0}/${e.core_total}`}
                </TableCell>
                <TableCell>
                  {/* Old runs have no enrichment split: fall back to overall coverage. */}
                  <Coverage pct={e.enrichment_pct ?? (e.letter_grade ? null : e.coverage_pct)} />
                </TableCell>
                <TableCell>{deferred > 0 ? <Badge variant="secondary">{`Deferred FK ${deferred}`}</Badge> : <Dash />}</TableCell>
                <TableCell>{e.row_count ?? "—"}</TableCell>
                <TableCell>{e.primary_source || "—"}</TableCell>
              </TableRow>
              {open && (
                <TableRow>
                  <TableCell colSpan={COL_SPAN} className="bg-muted/30 whitespace-normal">
                    <ColumnTable entity={e} />
                  </TableCell>
                </TableRow>
              )}
            </Fragment>
          );
        })}
      </TableBody>
    </Table>
  );
}
