/**
 * The "Delete v4 and v5" action of the B10 blocker (`vibe_scope_base`): the
 * agent refuses a scoped run on a base while newer replaced versions or Dry
 * Run drafts stay in its registry. Opens the permanent-delete dialog for the
 * versions the blocker names (`IssueOut.versions`, via
 * `blockerVersionsToDelete`); renders nothing when it names none. After the
 * deletes the parent re-runs its checks (`onDeleted`).
 */
import { useState } from "react";
import { Trash2 } from "lucide-react";
import type { BusinessKind, ModelVersionOut } from "@/lib/api";
import { blockerVersionsToDelete, versionsPhrase } from "@/lib/version-lifecycle";
import { Button } from "@/components/ui/button";
import { DeleteVersionsDialog } from "@/components/versions/delete-versions-dialog";

export function DeleteBlockedVersionsAction({
  businessId,
  businessName,
  businessKind,
  named,
  versions,
  scope,
  onDeleted,
}: {
  businessId: string;
  businessName: string;
  businessKind?: BusinessKind | null;
  /** The version numbers the blocker names (`IssueOut.versions`). */
  named: readonly number[];
  versions: readonly ModelVersionOut[];
  /** The base version's scope. */
  scope: string | null | undefined;
  onDeleted?: () => void;
}) {
  const [open, setOpen] = useState(false);
  const targets = blockerVersionsToDelete(named, versions, scope);
  if (targets.length === 0) return null;
  return (
    <>
      <Button
        type="button"
        size="sm"
        variant="outline"
        className="ml-2 h-7 border-destructive text-destructive hover:bg-destructive/10 hover:text-destructive"
        onClick={() => setOpen(true)}
        data-testid="delete-blocking-versions"
      >
        <Trash2 className="mr-1.5 h-3.5 w-3.5" aria-hidden />
        Delete {versionsPhrase(targets.map((t) => t.version))}
      </Button>
      {open && (
        <DeleteVersionsDialog
          open
          onOpenChange={setOpen}
          businessId={businessId}
          businessName={businessName}
          businessKind={businessKind}
          targets={targets}
          onDeleted={onDeleted}
        />
      )}
    </>
  );
}
