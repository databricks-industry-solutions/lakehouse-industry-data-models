/**
 * The run page's warnings: what a step that succeeded asks the user to know,
 * from `RunOut.warnings` (for example an uninstall whose agent could not drop
 * every schema or whose registry release may not have gone through, or a
 * shrink that could not read the parent ECM's conventions). A warning
 * with a statement an admin can run carries it under `sql`, shown as a
 * copyable block. Same look as the stale-run card.
 */
import { AlertTriangle } from "lucide-react";
import { CopyBlock } from "@/components/assessment/copy-block";
import { Card, CardContent } from "@/components/ui/card";

export type RunWarning = { message: string; sql?: string };

export function runWarnings(warnings: Record<string, unknown>[] | undefined): RunWarning[] {
  return (warnings ?? []).flatMap((w) =>
    typeof w.message === "string" && w.message
      ? [{ message: w.message, ...(typeof w.sql === "string" && w.sql ? { sql: w.sql } : {}) }]
      : [],
  );
}

export function RunWarningsCard({ warnings }: { warnings: Record<string, unknown>[] | undefined }) {
  const items = runWarnings(warnings);
  if (items.length === 0) return null;
  return (
    <Card className="border-warning/40 bg-warning/5" data-testid="run-warnings">
      <CardContent className="py-4 flex items-start gap-3">
        <AlertTriangle className="h-5 w-5 text-warning shrink-0 mt-0.5" aria-hidden />
        <div className="flex-1 min-w-0 space-y-1 text-sm">
          <p className="font-medium text-warning">Run warning</p>
          {items.map((w) => (
            <div key={w.message} className="space-y-1">
              <p className="text-muted-foreground" data-testid="run-warning">
                {w.message}
              </p>
              {w.sql ? <CopyBlock text={w.sql} /> : null}
            </div>
          ))}
        </div>
      </CardContent>
    </Card>
  );
}
