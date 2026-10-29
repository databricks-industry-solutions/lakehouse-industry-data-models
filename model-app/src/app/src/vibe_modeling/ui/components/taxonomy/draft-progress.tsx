import { Check, Clock, Loader2, X, Circle } from "lucide-react";
import type { TaxonomyDraftOut } from "@/lib/api";
import type { BusyAutoRetry } from "@/lib/taxonomy/busy-retry";
import { Button } from "@/components/ui/button";
import { BusyCountdown } from "./busy-countdown";

export const SECTION_LABELS: Record<string, string> = {
  tree: "Domains",
  company: "Company & segments",
  channels: "Channels",
  processes: "Core processes",
  terminology: "Terminology",
  systems_of_record: "Systems of record",
  regulatory: "Regulatory",
  description: "Description",
};
export const SECTION_BLURBS: Record<string, string> = {
  company: "Who you are: what you sell or operate, your segments and scale, and how the organization is divided.",
  channels: "How customers and partners reach you — portals, stores, field visits, contact centers, agents.",
  processes: "The end-to-end processes that run the business, e.g. order-to-cash, procure-to-pay, plan-to-produce.",
  terminology: "Words and acronyms your people use that the model should name things by.",
  systems_of_record: "Which systems are the source of truth for customers, assets, orders, money. Name products if you know them.",
  regulatory: "Regulators, filings, and compliance rules that shape what data you must keep.",
};
export const PART_ORDER = ["tree", "company", "channels", "processes", "terminology", "systems_of_record", "regulatory"];

function Icon({ status }: { status: string }) {
  if (status === "done") return <Check className="h-3 w-3 text-green-600" />;
  if (status === "running") return <Loader2 className="h-3 w-3 animate-spin" />;
  if (status === "pending") return <Circle className="h-3 w-3 text-muted-foreground" />;
  if (status === "busy") return <Clock className="h-3 w-3 text-warning" />;
  return <X className="h-3 w-3 text-destructive" />;
}

type Props = {
  draft: TaxonomyDraftOut;
  onCancel: () => void;
  /** The busy tree's countdown, shown here when the step itself doesn't show
   *  it. Busy parts carry their own Cancel, so the button here is for running drafts. */
  treeRetry?: BusyAutoRetry;
};

export function DraftProgress({ draft, onCancel, treeRetry }: Props) {
  const running = draft.status === "running";
  const busy = draft.status === "busy";
  return (
    <div className="space-y-2 rounded-md border bg-muted/40 px-3 py-2 text-xs" data-testid="draft-progress">
      <div className="flex flex-wrap items-center gap-3">
        {running && (
          <span className="flex items-center gap-1 font-medium">
            <Loader2 className="h-3.5 w-3.5 animate-spin" /> The model is drafting…
          </span>
        )}
        {busy && <span className="font-medium text-warning">The model is busy</span>}
        {PART_ORDER.filter((k) => draft.parts[k]).map((k) => (
          <span key={k} data-testid={`part-${k}`} data-status={draft.parts[k].status} className="flex items-center gap-1">
            <Icon status={draft.parts[k].status} /> {SECTION_LABELS[k]}
          </span>
        ))}
        {running && (
          <Button type="button" size="sm" variant="ghost" className="ml-auto h-6" aria-label="Cancel drafting" onClick={onCancel}>
            Cancel
          </Button>
        )}
      </div>
      {treeRetry?.busy && <BusyCountdown state={treeRetry} testId="tree-busy-countdown" />}
    </div>
  );
}
