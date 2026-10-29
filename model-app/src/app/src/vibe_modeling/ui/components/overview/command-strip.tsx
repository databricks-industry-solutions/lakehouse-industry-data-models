import { useState } from "react";
import { Link } from "@tanstack/react-router";
import { useQueryClient } from "@tanstack/react-query";
import {
  Clock,
  Check,
  Download,
  RefreshCw,
  Sparkles,
  Trash,
} from "lucide-react";
import {
  forceResyncVersion,
  useListRunsForVersion,
  type ModelVersionOut,
  type RunListOut,
} from "@/lib/api";
import { installActionLabel, isInstalled } from "@/lib/version-lifecycle";
import type { VersionOperationIntent } from "@/lib/use-version-operation-launch";
import { selector } from "@/lib/selector";
import { versionScopeLabel } from "@/lib/version-label";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import {
  Dialog,
  DialogClose,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import { VersionOperationDialog } from "@/components/runs/version-operation-dialog";
import { PublishVersionDialog } from "@/components/overview/publish-version-dialog";
import { formatRelative } from "@/lib/date";

/**
 * Compact command strip (design: `.cmd-strip`). One bordered row:
 *   left  - a "Manage" overline + the version-lifecycle actions: the install
 *           action named for the version's state ("Install this Dry Run",
 *           "Install" / "Re-install", "Make this version current"),
 *           Uninstall, the "Prepare new Vibe" entry to the compose surface,
 *           Re-sync and Publish. Install and Uninstall open
 *           `VersionOperationDialog` (`useVersionOperationLaunch`).
 *   right - run-status summary ("N runs · latest <ago>") + an "Installed"
 *           success badge when deployed.
 */
export function CommandStrip({
  businessId,
  version,
  versions,
  defaultTargetPath,
}: {
  businessId: string;
  version: ModelVersionOut;
  /** The business's versions, for the dialogs' version labels. */
  versions: readonly ModelVersionOut[];
  /** Pre-fill for the publish dialog's editable bundle-root (ADR D-049). */
  defaultTargetPath?: string;
}) {
  const queryClient = useQueryClient();
  const versionId = version.id;
  const versionNum = version.version;
  const scope = version.scope || undefined;
  const [error, setError] = useState("");
  const [dialog, setDialog] = useState<VersionOperationIntent | null>(null);
  const [resyncOpen, setResyncOpen] = useState(false);
  const [resyncing, setResyncing] = useState(false);

  const { data: runs } = useListRunsForVersion({
    params: { version_id: versionId },
    query: {
      // Active runs flip status often; idle runs don't. 3s while anything is
      // in flight, off entirely once everything is terminal (mirrors the old
      // RunsForVersionCard cadence).
      refetchInterval: (query) => {
        const rows = query.state.data?.data;
        if (!rows) return 5000;
        const active = rows.some(
          (r) =>
            r.status === "running" ||
            r.status === "pending" ||
            r.status === "stale",
        );
        return active ? 3000 : false;
      },
      staleTime: 0,
      ...selector<RunListOut[]>().query,
    },
  });

  const handleResync = async () => {
    setResyncing(true);
    setError("");
    try {
      await forceResyncVersion({ business_id: businessId, version_id: versionId });
      // Resync rewrites domains/products/attributes/FKs and re-materializes
      // the agent next-vibe inputs — invalidate everything keyed off this
      // business so the summary, version list, runs, and next-vibes views all
      // re-fetch.
      await queryClient.invalidateQueries();
      setResyncOpen(false);
    } catch (err: unknown) {
      const e = err as { body?: { detail?: string }; message?: string };
      setError(e?.body?.detail || e?.message || String(err));
    } finally {
      setResyncing(false);
    }
  };

  const installed = isInstalled(version);
  const installLabel = installActionLabel(version);
  const versionLabel = versionScopeLabel(versionNum, scope);

  const runRows = runs ?? [];
  const latest = runRows[0];
  const latestAt = latest?.started_at || latest?.created_at;

  return (
    <div
      data-testid="overview-command-strip"
      className="flex flex-wrap items-center gap-x-3 gap-y-2 rounded-md border border-border bg-card px-3 py-1.5"
    >
      <span className="text-xs font-medium uppercase tracking-wide text-muted-foreground">
        Manage
      </span>
      <div className="flex flex-wrap items-center gap-1.5">
        {installLabel && (
          <Button
            variant="outline"
            size="sm"
            data-testid="install-version"
            onClick={() => setDialog("install")}
            title="Pick the catalog, review what changes, then start the install"
          >
            <Download className="h-4 w-4 mr-1.5" />
            {installLabel}
          </Button>
        )}
        <Button
          variant="ghost"
          size="sm"
          data-testid="uninstall-version"
          disabled={!installed}
          onClick={() => setDialog("uninstall")}
          title={
            installed
              ? "Review what the uninstall drops, then start it"
              : "Version is not installed"
          }
        >
          <Trash className="h-4 w-4 mr-1.5" />
          Uninstall
        </Button>
        {/* Opens the compose surface for this version's scope — pick inputs,
            then Start run will iterate the version. */}
        {scope && (
          <Button
            variant="ghost"
            size="sm"
            data-testid="prepare-new-vibe"
            asChild
            title="Prepare a new vibe: pick inputs on the compose surface, then start the run"
          >
            <Link
              to="/businesses/$businessId/model/$version/$scope/inputs"
              params={{ businessId, version: String(versionNum), scope }}
            >
              <Sparkles className="h-4 w-4 mr-1.5" />
              Prepare new Vibe
            </Link>
          </Button>
        )}
        <Button
          variant="ghost"
          size="sm"
          disabled={resyncing}
          onClick={() => {
            setError("");
            setResyncOpen(true);
          }}
          title="Re-read this version's generated model and suggestions from the source files into the app"
        >
          <RefreshCw
            className={`h-4 w-4 mr-1.5 ${resyncing ? "animate-spin" : ""}`}
          />
          {resyncing ? "Re-syncing..." : "Re-sync"}
        </Button>
        <PublishVersionDialog
          businessId={businessId}
          versionId={versionId}
          versionNum={versionNum}
          scope={scope}
          defaultTargetPath={defaultTargetPath}
        />
      </div>

      <div className="ml-auto flex items-center gap-3">
        {runRows.length > 0 ? (
          <Link
            to="/businesses/$businessId/runs/$runId"
            params={{ businessId, runId: latest?.id ?? "" }}
            className="flex items-center gap-1.5 whitespace-nowrap text-xs text-muted-foreground hover:text-foreground"
            title="Open the latest run for this version"
          >
            <Clock className="h-3.5 w-3.5" />
            <span>
              <strong className="text-foreground">{runRows.length}</strong>{" "}
              {runRows.length === 1 ? "run" : "runs"}
              {latestAt && (
                <>
                  {" · latest "}
                  <span className="text-foreground">{formatRelative(latestAt)}</span>
                </>
              )}
            </span>
          </Link>
        ) : (
          <span className="flex items-center gap-1.5 whitespace-nowrap text-xs text-muted-foreground">
            <Clock className="h-3.5 w-3.5" />
            No runs yet
          </span>
        )}
        {installed && (
          <Badge
            variant="outline"
            className="gap-1 border-success/40 bg-success/15 text-success"
          >
            <Check className="h-3 w-3" />
            Installed
          </Badge>
        )}
      </div>

      {error && (
        <p className="basis-full pt-0.5 text-xs text-destructive">{error}</p>
      )}

      {dialog && (
        <VersionOperationDialog
          open
          onOpenChange={(open) => {
            if (!open) setDialog(null);
          }}
          businessId={businessId}
          intent={dialog}
          version={version}
          versions={versions}
        />
      )}
      <Dialog
        open={resyncOpen}
        onOpenChange={(open) => {
          if (!resyncing) setResyncOpen(open);
        }}
      >
        <DialogContent className={resyncing ? "[&>button]:hidden" : ""}>
          <DialogHeader>
            <DialogTitle>Re-sync model data from source?</DialogTitle>
            <DialogDescription>
              This re-reads the generated model and suggestions for{" "}
              {versionLabel} from the source files and refreshes the app's copy.
              Useful when the underlying files changed but the app still shows
              stale data.
            </DialogDescription>
          </DialogHeader>
          <DialogFooter>
            <DialogClose asChild>
              <Button variant="outline" disabled={resyncing}>
                Cancel
              </Button>
            </DialogClose>
            <Button onClick={handleResync} disabled={resyncing}>
              {resyncing ? "Re-syncing..." : "Re-sync"}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  );
}
