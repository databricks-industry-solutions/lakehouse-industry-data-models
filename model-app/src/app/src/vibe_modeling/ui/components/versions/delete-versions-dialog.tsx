/**
 * Permanent delete of one or more model versions (add §6.1: one by one, the
 * newest first). The version page's Delete and the "Delete v4 and v5" action
 * of the B10 blocker both open it. The server refuses an installed version or
 * one in the middle with a message; the dialog stops there and shows it.
 */
import { useState } from "react";
import { AlertTriangle } from "lucide-react";
import { useQueryClient } from "@tanstack/react-query";
import { deleteVersion, type BusinessKind } from "@/lib/api";
import { apiErrorMessage } from "@/lib/api-error";
import { invalidateEntityLists } from "@/lib/delete-invalidation";
import {
  APP_FOLDERS_DELETE_NOTE,
  DELETE_MAY_BE_FINISHING,
  countUnfinishedCleanups,
  isLostDeleteAnswer,
  notifyCleanupOutcome,
  retryCleanupInExplorer,
} from "@/lib/delete-outcome";
import { entityKindLabelLower } from "@/lib/entity-kind";
import { versionsPhrase } from "@/lib/version-lifecycle";
import { versionScopeLabel } from "@/lib/version-label";
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

export interface DeleteTarget {
  id: string;
  version: number;
  scope?: string | null;
}

/** "Deleting v5 is permanent. The agent reuses the number v5 ..." (design B6). */
export function permanentDeleteCopy(numbers: readonly number[]): string {
  const names = versionsPhrase(numbers);
  return numbers.length > 1
    ? `Deleting ${names} is permanent. The agent reuses the numbers ${names} for the next runs and clears those folders.`
    : `Deleting ${names} is permanent. The agent reuses the number ${names} for the next run and clears that folder.`;
}

export function DeleteVersionsDialog({
  open,
  onOpenChange,
  businessId,
  businessName,
  businessKind,
  targets,
  onDeleted,
}: {
  open: boolean;
  onOpenChange: (open: boolean) => void;
  businessId: string;
  businessName: string;
  /** Names the owner in the cleanup texts ("industry" or "business"). */
  businessKind?: BusinessKind | null;
  targets: readonly DeleteTarget[];
  /** After every target is deleted. */
  onDeleted?: () => void;
}) {
  const queryClient = useQueryClient();
  const [deleting, setDeleting] = useState(false);
  const [error, setError] = useState<string | null>(null);
  // Versions already deleted by an attempt that stopped on a refusal.
  const [gone, setGone] = useState<ReadonlySet<string>>(new Set());
  const ordered = [...targets]
    .filter((t) => !gone.has(t.id))
    .sort((a, b) => b.version - a.version);
  const scope = ordered[0]?.scope;
  const title =
    ordered.length === 1
      ? `Delete ${versionScopeLabel(ordered[0].version, scope)} of ${businessName}?`
      : `Delete ${versionsPhrase(ordered.map((t) => t.version))} ${(scope || "").toUpperCase()} of ${businessName}?`;

  const handleDelete = async () => {
    setDeleting(true);
    setError(null);
    let reopened = 0;
    let unfinished = 0;
    let answerLost = false;
    const done: number[] = [];
    try {
      for (const t of ordered) {
        const res = await deleteVersion({ business_id: businessId, version_id: t.id });
        reopened += res.data.reopened_input_count ?? 0;
        unfinished += countUnfinishedCleanups(res.data.metamodel_cleanup);
        done.push(t.version);
        setGone((prev) => new Set([...prev, t.id]));
      }
    } catch (err) {
      answerLost = isLostDeleteAnswer(err);
      setError(answerLost ? DELETE_MAY_BE_FINISHING : apiErrorMessage(err, "Delete failed."));
    }
    if (done.length > 0 || answerLost) {
      await invalidateEntityLists(queryClient, "version", { businessId });
    }
    if (done.length > 0) {
      const reopenedNote =
        reopened > 0
          ? ` ${reopened} feedback item${reopened === 1 ? "" : "s"} applied in ${versionsPhrase(done)} ${reopened === 1 ? "is" : "are"} open again.`
          : "";
      notifyCleanupOutcome({
        title: `${versionsPhrase(done)} deleted.${reopenedNote}`,
        unfinished,
        retryHint: retryCleanupInExplorer(businessKind),
      });
    }
    setDeleting(false);
    if (done.length === ordered.length) {
      setGone(new Set());
      onOpenChange(false);
      onDeleted?.();
    }
  };

  return (
    <AlertDialog
      open={open}
      onOpenChange={(next) => {
        if (!deleting) {
          setError(null);
          onOpenChange(next);
        }
      }}
    >
      <AlertDialogContent data-testid="delete-versions-dialog">
        <AlertDialogHeader>
          <AlertDialogTitle>{title}</AlertDialogTitle>
          <AlertDialogDescription asChild>
            <div className="space-y-3">
              <div className="flex items-start gap-2 rounded-md border border-destructive/50 bg-destructive/10 p-3 text-sm text-foreground">
                <AlertTriangle className="mt-0.5 h-4 w-4 shrink-0 text-destructive" aria-hidden />
                <div className="space-y-1">
                  <p className="font-medium" data-testid="delete-permanent-copy">
                    {permanentDeleteCopy(ordered.map((t) => t.version))}
                  </p>
                  <p>
                    This also deletes the domains, products, attributes, foreign keys,
                    artifacts and the agent&apos;s <code>_metamodel.*</code> rows. If
                    removing those rows fails, the app retries at the next start-ups and
                    the {entityKindLabelLower(businessKind)}&apos;s Explorer page offers Retry
                    cleanup. Feedback they applied becomes open again. {APP_FOLDERS_DELETE_NOTE}
                  </p>
                </div>
              </div>
              {error && (
                <p role="alert" className="text-sm text-destructive" data-testid="delete-versions-error">
                  {error}
                </p>
              )}
            </div>
          </AlertDialogDescription>
        </AlertDialogHeader>
        <AlertDialogFooter>
          <AlertDialogCancel disabled={deleting}>Cancel</AlertDialogCancel>
          <AlertDialogAction
            onClick={(e) => {
              e.preventDefault();
              void handleDelete();
            }}
            disabled={deleting || ordered.length === 0}
            className="bg-destructive text-destructive-foreground hover:bg-destructive/90"
          >
            {deleting ? "Deleting..." : "Delete"}
          </AlertDialogAction>
        </AlertDialogFooter>
      </AlertDialogContent>
    </AlertDialog>
  );
}
