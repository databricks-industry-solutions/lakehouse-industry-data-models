/**
 * LaunchRunDialog — confirmation dialog that gates all run triggers.
 *
 * Uses the shadcn AlertDialog (Radix primitive) so focus-trap and Esc-to-close
 * are wired for free. Rendering is controlled by the parent via `open`.
 *
 * The dialog is deliberately dumb: it does not call the API itself. The
 * caller wires `onConfirm` to its existing createRun(...) path; `onCancel`
 * is called both on explicit Cancel and on Esc / overlay dismissal so the
 * submit-in-progress flag can be cleared.
 */

import {
  AlertDialog,
  AlertDialogAction,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
} from "@/components/ui/alert-dialog";
import { AlertTriangle } from "lucide-react";
import { getOperationMetadata, helpSlug } from "@/lib/operations";
import { HelpLink } from "@/components/help/help-link";
import { fullRunConsequence, type AgentRunMode } from "@/lib/vibe-scope";

export interface LaunchRunDialogProps {
  /** Controls visibility. Parent owns this state. */
  open: boolean;
  /** Operation key (e.g. "install model"). See OPERATION_METADATA. */
  operationType: string;
  /** Name of the business the run targets — shown verbatim. */
  businessName: string;
  /** Version label (e.g. "v3") — omitted from the dialog body when absent. */
  versionLabel?: string;
  /** Vibe scope label (e.g. "Some domains: meter_to_cash"). Adds a Scope row. */
  scopeLabel?: string;
  /** Agent run type for a vibe iteration. Adds a Run type row; a Full Run
   *  also adds a warning line that names `catalog`. */
  agentRunMode?: AgentRunMode;
  /** Deployment catalog, named in the Full Run warning. */
  catalog?: string;
  /** Whether the launch request is currently in flight. Disables buttons. */
  submitting?: boolean;
  /** Called when the user confirms. Parent fires createRun(...) here. */
  onConfirm: () => void;
  /** Called on Cancel, Esc, or overlay dismiss. */
  onCancel: () => void;
}

export function LaunchRunDialog({
  open,
  operationType,
  businessName,
  versionLabel,
  scopeLabel,
  agentRunMode,
  catalog = "",
  submitting = false,
  onConfirm,
  onCancel,
}: LaunchRunDialogProps) {
  const meta = getOperationMetadata(operationType);

  return (
    <AlertDialog
      open={open}
      onOpenChange={(next) => {
        // AlertDialog only ever transitions open → closed on its own
        // (Esc, overlay). Mirror that into onCancel so the parent clears
        // any "submitting" flag it may have set.
        if (!next && !submitting) onCancel();
      }}
    >
      <AlertDialogContent>
        <AlertDialogHeader>
          <AlertDialogTitle>Launch run?</AlertDialogTitle>
          <AlertDialogDescription>
            Review before consuming compute.
          </AlertDialogDescription>
        </AlertDialogHeader>

        <dl className="grid grid-cols-[max-content_1fr] gap-x-4 gap-y-1.5 text-sm">
          <dt className="text-muted-foreground">Operation</dt>
          <dd className="font-medium">{meta.label}</dd>

          <dt className="text-muted-foreground">Business</dt>
          <dd className="font-medium">{businessName}</dd>

          {versionLabel && (
            <>
              <dt className="text-muted-foreground">Source version</dt>
              <dd className="font-medium">{versionLabel}</dd>
            </>
          )}

          {scopeLabel && (
            <>
              <dt className="text-muted-foreground">Scope</dt>
              <dd className="font-medium">{scopeLabel}</dd>
            </>
          )}

          {agentRunMode && (
            <>
              <dt className="text-muted-foreground">Run type</dt>
              <dd className="font-medium">{agentRunMode === "dry" ? "Dry Run" : "Full Run"}</dd>
            </>
          )}
        </dl>

        <p className="text-xs text-muted-foreground -mt-1">
          {meta.description}{" "}
          <HelpLink topic={helpSlug(operationType)}>What this run does</HelpLink>
        </p>

        <div
          role="note"
          className="flex items-start gap-2 rounded-md border border-warning/40 bg-warning/10 px-3 py-2 text-xs text-warning"
        >
          <AlertTriangle className="h-4 w-4 mt-0.5 shrink-0" aria-hidden />
          <span>
            This run will consume Databricks compute and LLM tokens
            proportional to the source model and instructions size.
          </span>
        </div>

        {agentRunMode === "full" && (
          <div
            role="note"
            data-testid="full-run-warning"
            className="flex items-start gap-2 rounded-md border border-warning/40 bg-warning/10 px-3 py-2 text-xs text-warning"
          >
            <AlertTriangle className="h-4 w-4 mt-0.5 shrink-0" aria-hidden />
            <span>{fullRunConsequence(catalog)}</span>
          </div>
        )}

        <AlertDialogFooter>
          <AlertDialogCancel
            disabled={submitting}
            onClick={(e) => {
              // Radix fires onOpenChange(false) after this handler, which
              // already calls onCancel. Nothing to do explicitly — but
              // leaving this handler here so the button has a stable click
              // target for test assertions.
              void e;
            }}
          >
            Cancel
          </AlertDialogCancel>
          <AlertDialogAction
            disabled={submitting}
            onClick={(e) => {
              // Prevent the AlertDialog from auto-closing on confirm;
              // the parent decides when to close (usually after the API
              // call resolves or the navigation fires).
              e.preventDefault();
              onConfirm();
            }}
          >
            {submitting ? "Starting..." : "Launch"}
          </AlertDialogAction>
        </AlertDialogFooter>
      </AlertDialogContent>
    </AlertDialog>
  );
}
