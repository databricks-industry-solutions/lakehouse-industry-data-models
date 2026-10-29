/**
 * Banner and notes the New Run form shows when the run's scope comes from the
 * selected feedback (design §8). Pure copy: the form decides what applies.
 *
 * - `ScopePrefillBanner`: names the source of a pre-filled scope.
 * - `ScopePrefillNotes`: under the scope control, the model-wide note, the
 *   "needs the latest version" note, and the "Scope to ..." hint.
 */
import { Button } from "@/components/ui/button";
import { scopePrefillBanner } from "@/lib/vibe-scope";

export function ScopePrefillBanner({
  itemCount,
  domains,
}: {
  itemCount: number;
  domains: readonly string[];
}) {
  return (
    <p
      role="status"
      data-testid="scope-prefill-banner"
      className="rounded-md border border-border bg-muted/40 px-3 py-2 text-sm text-foreground"
    >
      {scopePrefillBanner(itemCount, domains)}
    </p>
  );
}

export interface ScopePrefillNotesProps {
  /** Copy for selected items a scoped run leaves out as model-wide. */
  modelWideNote?: string;
  /** Copy explaining why the form opened on All domains. */
  latestNote?: string;
  /** Offer to scope to the selected feedback's domains. */
  hint?: { label: string; onApply: () => void };
}

export function ScopePrefillNotes({ modelWideNote, latestNote, hint }: ScopePrefillNotesProps) {
  if (!modelWideNote && !latestNote && !hint) return null;
  return (
    <div className="space-y-1 text-xs text-muted-foreground" data-testid="scope-prefill-notes">
      {latestNote && <p data-testid="scope-latest-note">{latestNote}</p>}
      {modelWideNote && <p data-testid="scope-model-wide-note">{modelWideNote}</p>}
      {hint && (
        <p>
          <Button
            type="button"
            variant="link"
            data-testid="scope-hint"
            onClick={hint.onApply}
            className="h-auto whitespace-normal p-0 text-left text-xs font-medium underline"
          >
            {hint.label}
          </Button>
        </p>
      )}
    </div>
  );
}
