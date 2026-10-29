import { useEffect, useLayoutEffect, useRef, useState } from "react";
import { Loader2, RotateCcw, X } from "lucide-react";
import type { TaxonomyClaim, TaxonomySection } from "@/lib/api";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Textarea } from "@/components/ui/textarea";
import { useBusyAutoRetry } from "@/lib/taxonomy/busy-retry";
import { LIVE_PART_STATUSES, RETRYABLE_PART_STATUSES } from "@/lib/taxonomy/part-status";
import { BusyCountdown } from "./busy-countdown";
import { SECTION_BLURBS, SECTION_LABELS } from "./draft-progress";


const lines = (t: string) => t.split("\n").map((l) => l.trim()).filter(Boolean);

/** Auto-growing textarea (no inner scrollbar). Keeps raw text locally so a trailing newline survives
 *  the split-and-rejoin round trip, and re-syncs when the parent value changes from outside. */
function AutoTextarea({ value, onValue, ...rest }: {
  value: string; onValue: (v: string) => void;
} & Omit<React.ComponentProps<typeof Textarea>, "value" | "onChange">) {
  const [text, setText] = useState(value);
  const ref = useRef<HTMLTextAreaElement>(null);
  useEffect(() => {
    if (lines(value).join("\n") !== lines(text).join("\n")) setText(value);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [value]);
  useLayoutEffect(() => {
    const el = ref.current;
    if (!el) return;
    el.style.height = "auto";
    el.style.height = `${el.scrollHeight}px`;
  }, [text]);
  return (
    <Textarea
      ref={ref}
      {...rest}
      value={text}
      style={{ overflow: "hidden", resize: "none" }}
      onChange={(e) => { setText(e.target.value); onValue(e.target.value); }}
    />
  );
}

type Props = {
  sectionKey: string;
  section?: TaxonomySection;
  partStatus: string;
  partError?: string | null;
  exampleText: string;
  onChange: (s: TaxonomySection) => void;
  onRetry: () => Promise<unknown> | void;
  /** Cancels the draft (the busy countdown's Cancel). */
  onCancel?: () => Promise<unknown> | void;
  /** The tree is busy: this section waits for it and does not count down itself. */
  waitingForTree?: boolean;
  /** The draft id: a new draft resets the busy countdown. */
  draftId?: string | null;
};

const noop = () => {};

export function SectionCard({
  sectionKey, section, partStatus, partError, exampleText, onChange, onRetry, onCancel, waitingForTree, draftId,
}: Props) {
  const [showExample, setShowExample] = useState(false);
  // Once the model drafted industry claims, keep the block mounted even if the user clears it (focus must survive).
  const [hadIndustry, setHadIndustry] = useState(false);
  const claims: TaxonomyClaim[] = section?.claims ?? [];
  const industry = claims.filter((c) => c.provenance === "industry");
  const confirm = claims.filter((c) => c.provenance === "confirm");
  const user = claims.filter((c) => c.provenance === "user");
  // Compiled order is by provenance group: industry, then confirm, then user.
  const emit = (i: TaxonomyClaim[], c: TaxonomyClaim[], u: TaxonomyClaim[]) => onChange({ claims: [...i, ...c, ...u] });
  const toClaims = (t: string, provenance: TaxonomyClaim["provenance"]): TaxonomyClaim[] =>
    lines(t).map((text) => ({ text, provenance }));
  if (industry.length > 0 && !hadIndustry) setHadIndustry(true);
  const hasBody = Boolean(section) || partStatus === "done";
  const id = `section-${sectionKey}`;
  // Count down only for a section the user doesn't have yet: a drafted copy
  // never overwrites one they already have.
  const ownBusy = partStatus === "busy" && !waitingForTree && !section;
  const busyRetry = useBusyAutoRetry(ownBusy ? partStatus : undefined, {
    retry: onRetry, cancel: onCancel ?? noop, resetKey: draftId,
  });

  return (
    <Card data-testid={`section-card-${sectionKey}`}>
      <CardHeader className="space-y-1 py-3">
        <div className="flex flex-row items-center justify-between">
          <CardTitle className="text-base">{SECTION_LABELS[sectionKey]}</CardTitle>
          <Button type="button" variant="link" size="sm" onClick={() => setShowExample((x) => !x)}>
            {showExample ? "Hide example" : "See a finished example"}
          </Button>
        </div>
        {SECTION_BLURBS[sectionKey] && <p className="text-sm text-muted-foreground">{SECTION_BLURBS[sectionKey]}</p>}
      </CardHeader>
      <CardContent className="space-y-3">
        {showExample && <p className="rounded border bg-muted/40 p-2 text-xs text-muted-foreground whitespace-pre-wrap">{exampleText}</p>}
        {LIVE_PART_STATUSES.has(partStatus) && !section && (
          <div className="flex items-center gap-2 text-sm text-muted-foreground"><Loader2 className="h-4 w-4 animate-spin" /> Drafting…</div>
        )}
        {partStatus === "busy" && !section && (waitingForTree
          ? <div className="flex items-center gap-2 text-sm text-muted-foreground">Waiting for the domains…</div>
          : <BusyCountdown state={busyRetry} testId={`busy-countdown-${sectionKey}`} />)}
        {RETRYABLE_PART_STATUSES.has(partStatus) && (
          <div className="flex items-center gap-2 text-sm">
            <span className="text-destructive">{partError || "This section didn't finish."}</span>
            <Button type="button" size="sm" variant="outline" onClick={onRetry}><RotateCcw className="mr-1 h-3 w-3" /> Retry</Button>
          </div>
        )}

        {(industry.length > 0 || hadIndustry) && (
          <div className="space-y-1 rounded-md border border-sky-200 bg-sky-50 p-2 dark:border-sky-900 dark:bg-sky-950/40">
            <label htmlFor={`${id}-industry`} className="block text-xs font-medium text-sky-900 dark:text-sky-200">
              From the model <span className="font-normal text-muted-foreground">· typical for your industry</span>
            </label>
            <AutoTextarea
              id={`${id}-industry`}
              className="bg-background text-sm"
              value={industry.map((c) => c.text).join("\n")}
              onValue={(v) => emit(toClaims(v, "industry"), confirm, user)}
            />
          </div>
        )}

        {confirm.length > 0 && (
          <div className="space-y-1 rounded-md border border-amber-300 bg-amber-50 p-2 dark:border-amber-800 dark:bg-amber-950/40">
            <p className="text-xs font-medium text-amber-900 dark:text-amber-200">The model guessed. Please confirm.</p>
            {confirm.map((c, i) => (
              <div key={i} className="flex items-start gap-2">
                <input
                  type="checkbox"
                  className="mt-2.5"
                  aria-label={`Confirm: ${c.text}`}
                  checked={false}
                  onChange={() => emit(industry, confirm.filter((_, j) => j !== i), [...user, { text: c.text, provenance: "user" }])}
                />
                <AutoTextarea
                  rows={1}
                  className="bg-background text-sm"
                  value={c.text}
                  onValue={(v) => emit(industry, confirm.map((x, j) => (j === i ? { ...x, text: v } : x)), user)}
                />
                <button type="button" className="mt-2.5 text-muted-foreground" aria-label={`Remove claim ${i + 1}`}
                  onClick={() => emit(industry, confirm.filter((_, j) => j !== i), user)}>
                  <X className="h-3 w-3" />
                </button>
              </div>
            ))}
          </div>
        )}

        {hasBody && (
          <div className="space-y-1 rounded-md border bg-muted/30 p-2">
            <label htmlFor={`${id}-notes`} className="block text-xs font-medium">
              Your notes <span className="font-normal text-muted-foreground">· You</span>
            </label>
            <AutoTextarea
              id={`${id}-notes`}
              rows={2}
              className="bg-background text-sm"
              placeholder="Add anything the model missed, one point per line."
              value={user.map((c) => c.text).join("\n")}
              onValue={(v) => emit(industry, confirm, toClaims(v, "user"))}
            />
          </div>
        )}
      </CardContent>
    </Card>
  );
}
