import { useNavigate } from "@tanstack/react-router";
import { DiagramViewer } from "@/components/diagram/diagram-viewer";
import { useGetUserPreferences, type VibeInputOut } from "@/lib/api";
import type { ColumnDisplayMode } from "@/components/diagram/types";
import { Skeleton } from "@/components/ui/skeleton";
import { anchorFromInput } from "./state";

// Same focal key as the other diagram hosts (item 4, 0.6.6). This pane is
// always domain-scoped (never all-domains, per the ELK perf note below), so
// only the focal preference applies here.
const DIAGRAM_FOCAL_MODE_KEY = "diagram.default_column_mode_focal";

export interface FollowingPaneProps {
  businessId: string;
  version: string;
  scope: string;
  /** Domains for the diagram (same list the model route passes). */
  domains: { name: string; division: string }[];
  /** The card currently focused (last clicked), or null. */
  focusedInput: VibeInputOut | null;
  /** Whether this pane is the active right-pane tab. The DiagramViewer is only
   *  mounted when active AND a domain-scoped card is focused — lazy by design
   *  (ELK perf). */
  active: boolean;
}

/**
 * Model-subgraph pane that follows the focused card. Reuses the real
 * `DiagramViewer`, SCOPED to the focused card's domain via `initialDomain` —
 * never all-domains (ELK perf). Mounts lazily: nothing renders until the pane
 * is active and a domain-scoped card is focused. Model-wide / anchor-free focus
 * shows an empty state rather than falling back to all-domains.
 */
export function FollowingPane({
  businessId,
  version,
  scope,
  domains,
  focusedInput,
  active,
}: FollowingPaneProps) {
  // DiagramViewer seeds columnMode via a useState initializer read ONCE at
  // mount, so mounting it before this preference resolves would
  // permanently lock it onto the hardcoded fallback - a later-resolving
  // initialColumnMode can't retroactively fix an already-mounted
  // useState. This gates the DiagramViewer mount below instead of racing
  // it. Called unconditionally (before the `active` early return) to keep
  // hook order stable across renders.
  const { data: userPrefs, isLoading: columnModePending } = useGetUserPreferences();
  const columnModePref = userPrefs?.data.find(
    (p) => p.key === DIAGRAM_FOCAL_MODE_KEY,
  )?.value as ColumnDisplayMode | undefined;

  // This mini-pane has no domain picker, but its diagram can
  // still show a RELATED domain group with a clickable header
  // (diagram-viewer.tsx's onDomainClick). Item 3B deleted DiagramViewer's
  // internal domain-state fallback, so without this callback that click
  // would go inert. Wire it to navigate to the clicked domain's own page -
  // hiding the toolbar's own dropdown (showDomainSelect=false) since a
  // free-floating "jump anywhere" picker doesn't belong on a pane that
  // only ever follows the focused card.
  const navigate = useNavigate();
  const handleDomainNavigate = (domain: string | null) => {
    if (!domain) return;
    navigate({
      to: "/businesses/$businessId/model/$version/$scope/$domainName",
      params: { businessId, version, scope, domainName: domain },
      search: { tab: "diagram" },
    });
  };

  if (!active) return null;

  const focusAnchor = focusedInput ? anchorFromInput(focusedInput) : undefined;
  const anchorPath = focusedInput?.anchor?.path;

  if (!focusAnchor?.domain) {
    return (
      <div className="flex h-full flex-col">
        <div className="border-b border-border px-4 py-2 text-xs font-semibold uppercase tracking-wide text-muted-foreground">
          Following
        </div>
        <div className="flex flex-1 items-center justify-center p-6 text-center text-sm text-muted-foreground">
          Focus a domain or product card to scope the diagram.
        </div>
      </div>
    );
  }

  return (
    <div className="flex h-full flex-col">
      <div className="flex items-center justify-between border-b border-border px-4 py-2">
        <span className="text-xs font-semibold uppercase tracking-wide text-muted-foreground">
          Following · {anchorPath?.join(" › ") || focusAnchor.domain}
        </span>
        <span className="rounded-sm bg-tertiary/10 px-1.5 py-0.5 text-[10px] font-medium text-tertiary">
          live
        </span>
      </div>
      <div className="min-h-0 flex-1 overflow-auto">
        {columnModePending ? (
          <Skeleton className="h-full w-full" />
        ) : (
          <DiagramViewer
            // Picking a different card that belongs to a new domain changes
            // `focusAnchor.domain` as a prop, but DiagramViewer's internal
            // `selectedDomain` useState is seeded ONCE at mount (item 3B
            // removed the resync fallback). Keying on the focal domain forces
            // a fresh mount whenever the domain changes, matching the same
            // fix applied to the $domainName route (key={domainName}).
            key={focusAnchor.domain}
            businessId={businessId}
            version={version}
            scope={scope}
            domains={domains}
            initialDomain={focusAnchor.domain}
            initialColumnMode={columnModePref}
            onDomainNavigate={handleDomainNavigate}
            showDomainSelect={false}
          />
        )}
      </div>
    </div>
  );
}
