import { Suspense, useEffect, useState } from "react";
import { useQueryClient } from "@tanstack/react-query";
import { AlertTriangle, Download, Loader2 } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Skeleton } from "@/components/ui/skeleton";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import { SectorSelect } from "@/components/business/sector-select";
import type { SourceModelSelection } from "@/lib/source-selection";
import {
  ApiError,
  useDownloadIndustryModel,
  listSectorsKey,
  type DownloadIndustryModelOut,
} from "@/lib/api";
import { apiErrorMessage } from "@/lib/api-error";
import { invalidateBusinessLists } from "@/lib/business-cache";
import { notifyConfigMissing } from "@/lib/notify";
import { sourceErrorCopy } from "@/lib/source-error-copy";
import {
  DownloadConflictStep,
  parseDownloadConflict,
  type IndustryModelAlreadyExistsBody,
} from "@/components/import/download-conflict-step";

interface Props {
  /** The model selected in the source explorer (Track A), or null. */
  selection: SourceModelSelection | null;
  open: boolean;
  onOpenChange: (open: boolean) => void;
  /**
   * Fired after a successful download. The source-explorer dialog uses this to
   * close this dialog and open the `DownloadCompleteDialog` in its place (the
   * completion dialog IS the notification - no more success toast) and to
   * refresh its "already downloaded" badges.
   */
  onDownloaded?: (out: DownloadIndustryModelOut) => void;
}

/**
 * Download an industry model from the source registry and materialize it as a
 * local `kind="industry"` business.
 *
 * The conflict unit is the model SCOPE within the industry. The download
 * always submits with no `on_conflict` (additive semantics): the backend
 * creates the industry, ADDS a never-seen scope under an existing industry, or
 * returns a 409 `industry_model_already_exists` for a same-scope clash. The
 * 409 renders the informational `DownloadConflictStep` (delete-in-app to
 * re-download); there are no resolution choices.
 *
 * On success this dialog closes itself; the host (`SourceExplorerDialog`)
 * owns the `DownloadCompleteDialog` that replaces it, summarizing the result
 * (including any warnings) and offering "View industry" / "Download another".
 */
export function DownloadIndustryDialog({
  selection,
  open,
  onOpenChange,
  onDownloaded,
}: Props) {
  const [sectorId, setSectorId] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [conflict, setConflict] = useState<IndustryModelAlreadyExistsBody | null>(
    null,
  );
  const queryClient = useQueryClient();
  const { mutate, isPending } = useDownloadIndustryModel();

  // Pre-fill the target sector from the source suggestion when present.
  useEffect(() => {
    if (open) {
      setSectorId(selection?.suggested_sector_id ?? null);
      setError(null);
      setConflict(null);
    }
  }, [open, selection]);

  const onSuccess = (out: DownloadIndustryModelOut) => {
    invalidateBusinessLists(queryClient);
    queryClient.invalidateQueries({ queryKey: listSectorsKey() });
    // Close self - the host swaps in the DownloadCompleteDialog, which IS the
    // notification (summary + any warnings), so no toast here.
    onOpenChange(false);
    onDownloaded?.(out);
  };

  const submit = () => {
    if (!selection || !sectorId) return;
    setError(null);
    mutate(
      {
        params: {},
        data: {
          sector_id: sectorId,
          industry_id: selection.industry_id,
          model_id: selection.model_id,
        },
      },
      {
        onSuccess: (resp) => onSuccess(resp.data),
        onError: (err) => {
          const parsed = parseDownloadConflict(err);
          if (parsed) {
            setConflict(parsed);
            return;
          }
          setConflict(null);
          // Route missing-config through the ONE shared renderer (rich toast
          // with per-item Settings deep-links) instead of a generic
          // "HTTP 422" inline banner.
          if (notifyConfigMissing(err)) return;
          // A 403 from the source (bad/missing GitHub App creds or a private
          // repo) gets the shared, actionable copy - never a raw "HTTP 403".
          if (err instanceof ApiError && err.status === 403) {
            setError(sourceErrorCopy(403).detail);
            return;
          }
          setError(apiErrorMessage(err, "Download failed"));
        },
      },
    );
  };

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent className="max-w-lg">
        <DialogHeader>
          <DialogTitle>Download industry model</DialogTitle>
          <DialogDescription>
            Materialize the selected source model as a local industry. Choose
            the target sector — businesses can be kickstarted from it later.
          </DialogDescription>
        </DialogHeader>

        {!selection ? (
          <p className="text-sm text-muted-foreground py-4">
            No source model selected. Browse a source model first, then download
            it from here.
          </p>
        ) : (
          <div className="space-y-4">
            <div className="space-y-1.5">
              <label className="text-sm font-medium">Target sector</label>
              <Suspense fallback={<Skeleton className="h-9 w-full" />}>
                <SectorSelect
                  value={sectorId}
                  onChange={setSectorId}
                  placeholder="Select a target sector…"
                />
              </Suspense>
              {!sectorId && (
                <p className="text-[10px] text-muted-foreground">
                  Pick a sector to enable download. Manage sectors in{" "}
                  <span className="font-medium">Settings → Sectors</span>.
                </p>
              )}
            </div>

            {conflict ? (
              <DownloadConflictStep
                conflict={conflict}
                onClose={() => setConflict(null)}
              />
            ) : (
              <>
                {error && (
                  <div className="rounded-md border border-destructive/50 bg-destructive/10 p-3 text-sm flex items-start gap-2">
                    <AlertTriangle className="h-4 w-4 mt-0.5 text-destructive shrink-0" />
                    <p className="text-destructive">{error}</p>
                  </div>
                )}
                <div className="flex justify-end gap-2">
                  <Button
                    variant="outline"
                    size="sm"
                    onClick={() => onOpenChange(false)}
                    disabled={isPending}
                  >
                    Cancel
                  </Button>
                  <Button
                    size="sm"
                    data-testid="download-submit"
                    onClick={() => submit()}
                    disabled={!sectorId || isPending}
                  >
                    {isPending ? (
                      <Loader2 className="h-4 w-4 mr-2 animate-spin" />
                    ) : (
                      <Download className="h-4 w-4 mr-2" />
                    )}
                    Download
                  </Button>
                </div>
              </>
            )}
          </div>
        )}
      </DialogContent>
    </Dialog>
  );
}
