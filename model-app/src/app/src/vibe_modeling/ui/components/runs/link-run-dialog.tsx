/**
 * Link an imported version to the Databricks run that produced it (add §5.2).
 *
 * The version page shows "Link to run" for an imported version that no run
 * produced yet, to business admins (the server enforces BusinessAdminOnly).
 * The dialog takes a Databricks run id, checks it (`previewLinkRun`, writes
 * nothing) and shows how it matched: confirmed by the agent's registry
 * (tier 1), or a best-effort match on the folder and parameters (tier 2).
 * Problems block the link. "Link" records the run (`linkRun`). A linked
 * version shows a link to its run instead.
 */
import { useState } from "react";
import { Link as RouterLink } from "@tanstack/react-router";
import { useQueryClient } from "@tanstack/react-query";
import { CheckCircle2, AlertTriangle, Link2, XCircle } from "lucide-react";
import { toast } from "sonner";
import {
  linkRun,
  listRunsKey,
  listVersionsKey,
  previewLinkRun,
  type LinkRunPreviewOut,
  type ModelVersionOut,
} from "@/lib/api";
import { apiErrorMessage } from "@/lib/api-error";
import { isBusinessAdmin, useUserRole } from "@/lib/hooks";
import { intentLabel } from "@/lib/intent";
import { versionScopeLabel } from "@/lib/version-label";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";

/** A Databricks run id typed by the user, or null when it is not one. */
export function parseRunId(text: string): number | null {
  const trimmed = text.trim();
  if (!/^\d{1,19}$/.test(trimmed)) return null;
  const n = Number(trimmed);
  return Number.isSafeInteger(n) && n > 0 ? n : null;
}

function PreviewResult({ preview }: { preview: LinkRunPreviewOut }) {
  const problems = preview.problems ?? [];
  const evidence = preview.evidence ?? [];
  return (
    <div className="space-y-2" data-testid="link-run-preview">
      {preview.linkable && preview.tier === 1 && (
        <p className="flex items-center gap-2 text-sm font-medium text-success">
          <CheckCircle2 className="h-4 w-4" aria-hidden />
          Confirmed by the agent's registry.
        </p>
      )}
      {preview.linkable && preview.tier === 2 && (
        <p className="flex items-center gap-2 text-sm font-medium text-warning">
          <AlertTriangle className="h-4 w-4" aria-hidden />
          Best-effort match: the agent's registry did not confirm this run.
        </p>
      )}
      {preview.linkable && preview.intent && (
        <p className="text-sm">
          Recorded as a <strong>{intentLabel(preview.intent)}</strong> run.
        </p>
      )}
      {problems.length > 0 && (
        <div className="space-y-1" role="alert">
          <p className="flex items-center gap-2 text-sm font-medium text-destructive">
            <XCircle className="h-4 w-4" aria-hidden />
            This run cannot be linked to this version.
          </p>
          <ul className="list-disc space-y-0.5 pl-6 text-sm">
            {problems.map((p) => (
              <li key={p}>{p}</li>
            ))}
          </ul>
        </div>
      )}
      {evidence.length > 0 && (
        <ul className="list-disc space-y-0.5 pl-6 text-xs text-muted-foreground">
          {evidence.map((e) => (
            <li key={e}>{e}</li>
          ))}
        </ul>
      )}
    </div>
  );
}

export function LinkRunDialog({
  open,
  onOpenChange,
  businessId,
  version,
}: {
  open: boolean;
  onOpenChange: (open: boolean) => void;
  businessId: string;
  version: ModelVersionOut;
}) {
  const queryClient = useQueryClient();
  const [text, setText] = useState("");
  const [preview, setPreview] = useState<LinkRunPreviewOut | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [busy, setBusy] = useState(false);
  const runId = parseRunId(text);
  const label = versionScopeLabel(version.version, version.scope);
  const ids = { business_id: businessId, version_id: version.id };

  const check = async () => {
    if (runId === null) return;
    setBusy(true);
    setError(null);
    try {
      const res = await previewLinkRun(ids, { databricks_run_id: runId });
      setPreview(res.data);
    } catch (err) {
      setError(apiErrorMessage(err, "The run could not be checked."));
    } finally {
      setBusy(false);
    }
  };

  const doLink = async () => {
    if (runId === null) return;
    setBusy(true);
    setError(null);
    try {
      await linkRun(ids, { databricks_run_id: runId });
      toast.success(`Linked ${label} to Databricks run ${runId}.`);
      await Promise.all([
        queryClient.invalidateQueries({ queryKey: listVersionsKey({ business_id: businessId }) }),
        queryClient.invalidateQueries({ queryKey: listRunsKey({ business_id: businessId }) }),
      ]);
      onOpenChange(false);
    } catch (err) {
      setError(apiErrorMessage(err, "The run could not be linked."));
    } finally {
      setBusy(false);
    }
  };

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent className="sm:max-w-lg">
        <DialogHeader>
          <DialogTitle>Link {label} to its run</DialogTitle>
          <DialogDescription>
            Enter the id of the Databricks job run that produced this model. The app checks it against the agent's
            registry, or else against the run's folder and parameters, before it records the run.
          </DialogDescription>
        </DialogHeader>
        <div className="space-y-3">
          <label className="block space-y-1 text-sm font-medium" htmlFor="link-run-id">
            <span>Databricks run id</span>
            <Input
              id="link-run-id"
              inputMode="numeric"
              autoComplete="off"
              value={text}
              onChange={(e) => {
                setText(e.target.value);
                setPreview(null);
                setError(null);
              }}
              placeholder="409596894605355"
            />
          </label>
          {text.trim() !== "" && runId === null && (
            <p className="text-xs text-destructive">A run id is a number.</p>
          )}
          {preview && <PreviewResult preview={preview} />}
          {error && (
            <p className="text-sm text-destructive" role="alert">
              {error}
            </p>
          )}
        </div>
        <DialogFooter>
          <Button variant="outline" onClick={() => onOpenChange(false)} disabled={busy}>
            Cancel
          </Button>
          {preview?.linkable ? (
            <Button onClick={() => void doLink()} disabled={busy || runId === null}>
              {busy ? "Linking..." : "Link"}
            </Button>
          ) : (
            <Button onClick={() => void check()} disabled={busy || runId === null}>
              {busy ? "Checking..." : "Check run"}
            </Button>
          )}
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
}

/** The version page's action: "Link to run" for an unlinked imported
 *  version (admins only), a link to the run once linked. */
export function LinkRunAction({ businessId, version }: { businessId: string; version: ModelVersionOut }) {
  const role = useUserRole();
  const [open, setOpen] = useState(false);
  if (version.linked_run_id) {
    return (
      <Button asChild variant="ghost" size="sm">
        <RouterLink
          to="/businesses/$businessId/runs/$runId"
          params={{ businessId, runId: version.linked_run_id }}
          data-testid="linked-run-link"
        >
          <Link2 className="mr-2 h-4 w-4" aria-hidden />
          Linked run
        </RouterLink>
      </Button>
    );
  }
  const canLink = isBusinessAdmin(role);
  if (!version.is_imported || !canLink) return null;
  return (
    <>
      <Button variant="outline" size="sm" onClick={() => setOpen(true)}>
        <Link2 className="mr-2 h-4 w-4" aria-hidden />
        Link to run
      </Button>
      {open && <LinkRunDialog open onOpenChange={setOpen} businessId={businessId} version={version} />}
    </>
  );
}
