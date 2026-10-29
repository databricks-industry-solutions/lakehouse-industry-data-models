import { Info } from "lucide-react";
import type { ImportAnalyzeOut } from "@/lib/api";

export type ImportScope = "ecm" | "mvm";

/** Whether the file settles the scope (its version, its agent folder, agent
 * output). When only its requirements suggest one, the user still chooses. */
function settled(analysis: ImportAnalyzeOut | null): boolean {
  return Boolean(analysis?.scope_settled && analysis.inferred_scope);
}

/** The choice to start from after an analyze: the suggested scope when the
 * file only suggests one, else none. */
export function initialScopeChoice(analysis: ImportAnalyzeOut): ImportScope | null {
  return settled(analysis) ? null : ((analysis.inferred_scope as ImportScope | null | undefined) ?? null);
}

/** The scope an import uses: the one the file settles, else the user's choice. */
export function importScope(
  analysis: ImportAnalyzeOut | null,
  chosen: ImportScope | null,
): ImportScope | null {
  return settled(analysis) ? (analysis!.inferred_scope as ImportScope) : chosen;
}

/** The `scope` an execute call sends: the user's choice, only when the file
 * did not settle it (the backend refuses a choice that contradicts the file). */
export function importScopeBody(
  analysis: ImportAnalyzeOut | null,
  chosen: ImportScope | null,
): ImportScope | null {
  return settled(analysis) ? null : chosen;
}

/** What the app does to the imported model's names (`services/scope_prefix`). */
export function importPrefixNote(analysis: ImportAnalyzeOut, scope: ImportScope | null): string | null {
  if (analysis.agent_output) return "Agent output: imported as the agent wrote it.";
  if (!scope) return null;
  if (!analysis.file_schema_prefix) {
    return `The file has no schema prefix; the app names its schemas ${scope}_<domain> and its metric views ${scope}_<view>. Your file is not changed.`;
  }
  return `The file's schemas keep its prefix ${analysis.file_schema_prefix}; the app names its metric views ${scope}_<view>. Your file is not changed.`;
}

/**
 * The ECM / MVM choice of an import, shown unless the file settles the scope
 * (`analysis.scope_settled`): preselected when its requirements suggest one,
 * required when nothing does. Plus the note on what the app does to its names.
 */
export function ImportScopeChoice({
  analysis,
  chosen,
  onChoose,
  disabled = false,
}: {
  analysis: ImportAnalyzeOut;
  chosen: ImportScope | null;
  onChoose: (scope: ImportScope) => void;
  disabled?: boolean;
}) {
  const scope = importScope(analysis, chosen);
  const note = importPrefixNote(analysis, scope);
  return (
    <div data-testid="import-scope-choice" className="border-t border-border pt-3 space-y-2">
      {!settled(analysis) && (
        <fieldset className="space-y-1.5" disabled={disabled}>
          <legend className="text-sm font-medium">Is this model an ECM or an MVM?</legend>
          <p className="text-xs text-muted-foreground">
            {analysis.inferred_scope
              ? `The file's requirements suggest ${analysis.inferred_scope.toUpperCase()}. Change it if the model is the other one.`
              : "The file doesn't say. Choose one to import it."}
          </p>
          <div className="flex gap-4 text-sm" role="radiogroup">
            {(["ecm", "mvm"] as const).map((value) => (
              <label key={value} className="flex items-center gap-1.5 cursor-pointer">
                <input
                  type="radio"
                  name="import-scope"
                  value={value}
                  checked={chosen === value}
                  onChange={() => onChoose(value)}
                  className="accent-primary"
                />
                {value === "ecm" ? "ECM (Expanded Coverage Model)" : "MVM (Minimum Viable Model)"}
              </label>
            ))}
          </div>
        </fieldset>
      )}
      {note && (
        <p data-testid="import-prefix-note" className="flex items-start gap-2 text-xs text-muted-foreground">
          <Info className="h-3.5 w-3.5 mt-0.5 shrink-0" />
          <span>{note}</span>
        </p>
      )}
    </div>
  );
}
