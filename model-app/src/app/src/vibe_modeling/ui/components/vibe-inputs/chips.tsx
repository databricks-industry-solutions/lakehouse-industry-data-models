import { Sparkles, Database, Flag, AlertTriangle, Undo2 } from "lucide-react";
import { Badge } from "@/components/ui/badge";
import { cn } from "@/lib/utils";
import type { VibeInputOrigin, VibeInputPriority } from "@/lib/api";
import type { VibeInputState } from "./state";

/** Human labels for the known origins. Unknown / future import origins fall
 *  back to a title-cased raw value (the backend emits user, agent_next_vibe and
 *  change_rejection; import variants render defensively for forward-compat). */
const ORIGIN_LABELS: Record<string, string> = {
  user: "User",
  agent_next_vibe: "AI suggestion",
  change_rejection: "Rejected change",
  uc_import: "UC import",
  genie_import: "Genie import",
  dashboard_import: "Dashboard import",
  agent_import: "Agent import",
};

function titleCase(raw: string): string {
  return raw
    .split("_")
    .map((w) => (w ? w[0].toUpperCase() + w.slice(1) : w))
    .join(" ");
}

/** Origin chip. AI → sparkles; rejected change → outline + undo; *_import →
 *  outline + database; user/unknown → plain. Tolerant of origins outside the
 *  current TS union. */
export function OriginBadge({ origin }: { origin: VibeInputOrigin | string }) {
  const key = String(origin);
  const label = ORIGIN_LABELS[key] ?? titleCase(key);
  if (key === "agent_next_vibe") {
    return (
      <Badge variant="default" className="gap-1">
        <Sparkles className="h-3 w-3" />
        {label}
      </Badge>
    );
  }
  if (key === "change_rejection") {
    return (
      <Badge variant="outline" className="gap-1">
        <Undo2 className="h-3 w-3" />
        {label}
      </Badge>
    );
  }
  if (key.endsWith("_import")) {
    return (
      <Badge variant="outline" className="gap-1">
        <Database className="h-3 w-3" />
        {label}
      </Badge>
    );
  }
  return <Badge variant="default">{label}</Badge>;
}

const PRIORITY_META: Record<VibeInputPriority, { className: string; label: string }> = {
  high: { className: "text-destructive", label: "High" },
  medium: { className: "text-warning", label: "Medium" },
  low: { className: "text-muted-foreground", label: "Low" },
};

/** Priority indicator: flag tinted by token class + label (Task 11 enum). */
export function PriorityIndicator({ priority }: { priority: VibeInputPriority }) {
  const meta = PRIORITY_META[priority] ?? PRIORITY_META.low;
  return (
    <span
      className="inline-flex items-center gap-1 text-xs text-muted-foreground"
      title={`Priority: ${meta.label}`}
    >
      <Flag className={cn("h-3 w-3", meta.className)} />
      {meta.label}
    </span>
  );
}

/** State chip, a pure function of the derived state. `active` renders nothing
 *  (the default); `needs_link_review` is rendered as a clickable chip-button by
 *  the card, so this returns null for it (see ReviewChipButton). */
export function StateChip({ state }: { state: VibeInputState }) {
  if (state === "consumed") return <Badge variant="secondary">Consumed</Badge>;
  if (state === "deprecated") return <Badge variant="secondary">Deprecated</Badge>;
  return null;
}

/** The clickable "Needs link review" chip-button. `title` carries the rename
 *  detail across three lines; clicking opens the review queue. */
export function ReviewChipButton({
  title,
  onClick,
}: {
  title?: string;
  onClick: () => void;
}) {
  return (
    <button
      type="button"
      title={title}
      onClick={onClick}
      className="inline-flex items-center gap-1 rounded-sm border border-warning/40 bg-warning/10 px-2 py-0.5 text-xs font-medium text-warning transition-colors hover:bg-warning/15"
    >
      <AlertTriangle className="h-3 w-3" />
      Needs link review
    </button>
  );
}
