import { useState } from "react";
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { CheckCircle2, AlertTriangle, Loader2, X, FolderOpen, FileWarning, Files } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Badge } from "@/components/ui/badge";
import { Checkbox } from "@/components/ui/checkbox";
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from "@/components/ui/dialog";
import { VolumePicker } from "@/components/import/volume-picker";
import {
  ImportScopeChoice,
  importScope,
  importScopeBody,
  initialScopeChoice,
  type ImportScope,
} from "@/components/import/import-scope-choice";
import { apiErrorMessage } from "@/lib/api-error";
import { notifyConfigMissing, notifyWarnings } from "@/lib/notify";
import {
  analyzeImport,
  executeImport,
  getExplorerVersionsKey,
  getImportPreview,
  getImportPreviewKey,
  listVersionsKey,
  type ImportAnalyzeOut,
  type ImportPreviewOut,
} from "@/lib/api";

interface ImportModelDialogProps {
  businessId: string;
  trigger: React.ReactNode;
}

/**
 * Two-step import flow:
 * 1. User enters a Volume path — the preview endpoint walks the folder
 *    and shows what will be imported (model.json presence, companion
 *    artifacts, next-vibes status).
 * 2. User clicks Analyze — the model.json is parsed and a schema
 *    verdict is rendered.
 * 3. Import threads accept_business_mismatch to the execute call.
 *
 * The preview is informational — it does not block submit on its own
 * except when model.json is missing. ``next_vibes`` missing renders a
 * warning banner so users know the agent's next-iteration suggestions
 * cannot be reconstructed for this version.
 */
export function ImportModelDialog({ businessId, trigger }: ImportModelDialogProps) {
  const [open, setOpen] = useState(false);
  const [pickerOpen, setPickerOpen] = useState(false);
  const [volumePath, setVolumePath] = useState("");
  const [analysis, setAnalysis] = useState<ImportAnalyzeOut | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [acceptMismatch, setAcceptMismatch] = useState(false);
  const [chosenScope, setChosenScope] = useState<ImportScope | null>(null);
  const queryClient = useQueryClient();

  // Preview query — runs as soon as the user has a plausibly-valid Volume
  // path. ``useQuery`` with ``enabled`` keeps it idle until then, and
  // react-query handles refetch/dedupe across renders.
  const previewEnabled = volumePath.startsWith("/Volumes/");
  const previewQuery = useQuery({
    queryKey: getImportPreviewKey({ volume_path: volumePath }),
    queryFn: () => getImportPreview({ volume_path: volumePath }),
    enabled: previewEnabled,
    retry: false,
    staleTime: 30_000,
  });
  const preview: ImportPreviewOut | undefined = previewQuery.data?.data;

  const analyzeMutation = useMutation({
    mutationFn: () =>
      analyzeImport({ business_id: businessId }, { volume_path: volumePath }),
    onSuccess: (response) => {
      setAnalysis(response.data);
      setError(null);
      setAcceptMismatch(false);
      setChosenScope(initialScopeChoice(response.data));
    },
    onError: (err: unknown) => {
      if (notifyConfigMissing(err)) {
        setAnalysis(null);
        return;
      }
      setError(apiErrorMessage(err, "Failed to analyze"));
      setAnalysis(null);
    },
  });

  const executeMutation = useMutation({
    mutationFn: () =>
      executeImport(
        { business_id: businessId },
        {
          volume_path: volumePath,
          accept_business_mismatch: acceptMismatch,
          scope: importScopeBody(analysis, chosenScope),
        },
      ),
    onSuccess: (response) => {
      notifyWarnings("Imported with warnings", response.data.warnings);
      queryClient.invalidateQueries({
        queryKey: listVersionsKey({ business_id: businessId }),
      });
      // The sidebar's version list uses ``getExplorerVersions`` (richer
      // payload with scope grouping), not ``listVersions``. Invalidate
      // both so the new version appears without a manual refresh.
      queryClient.invalidateQueries({
        queryKey: getExplorerVersionsKey({ business_id: businessId }),
      });
      reset();
      setOpen(false);
    },
    onError: (err: unknown) => {
      // Missing config renders via the ONE shared renderer (rich toast with
      // per-item Settings deep-links); everything else stays inline.
      if (notifyConfigMissing(err)) return;
      setError(apiErrorMessage(err, "Import failed"));
    },
  });

  const reset = () => {
    setVolumePath("");
    setAnalysis(null);
    setError(null);
    setAcceptMismatch(false);
    setChosenScope(null);
  };

  const mismatches = analysis?.business_digest_diff?.mismatch_fields ?? [];
  const hasMismatch = mismatches.length > 0;
  // Block submit when:
  //  - the mutation is in flight,
  //  - the user has unacknowledged business-identity mismatches,
  //  - the model's scope is neither settled by the file nor chosen, OR
  //  - the preview says model.json is not present at the path.
  const importDisabled =
    executeMutation.isPending ||
    (hasMismatch && !acceptMismatch) ||
    importScope(analysis, chosenScope) == null ||
    (preview != null && !preview.model_json_found);

  // Analyze is blocked when preview says no model.json sits at the path.
  // No preview yet (path empty or fetch in flight) → fall back to the
  // legacy ``/Volumes/`` prefix check so the affordance still works
  // before the first preview lands.
  const analyzeDisabled =
    !previewEnabled ||
    analyzeMutation.isPending ||
    (preview != null && !preview.model_json_found);

  return (
    <Dialog
      open={open}
      onOpenChange={(v) => {
        setOpen(v);
        if (!v) reset();
      }}
    >
      <DialogTrigger asChild>{trigger}</DialogTrigger>
      <DialogContent className="max-w-lg">
        <DialogHeader>
          <DialogTitle>Import pre-vibed model</DialogTitle>
        </DialogHeader>

        <div className="space-y-4">
          <div className="space-y-1.5">
            <label className="text-sm font-medium">Volume path to model.json</label>
            <div className="flex gap-2">
              <Input
                value={volumePath}
                onChange={(e) => {
                  setVolumePath(e.target.value);
                  // Drop a stale analyze envelope when the user re-types.
                  setAnalysis(null);
                  setError(null);
                }}
                placeholder="/Volumes/catalog/schema/vibes/model.json"
                disabled={analyzeMutation.isPending || executeMutation.isPending}
              />
              <Button
                type="button"
                variant="outline"
                onClick={() => setPickerOpen(true)}
                disabled={analyzeMutation.isPending || executeMutation.isPending}
              >
                <FolderOpen className="h-4 w-4 mr-1" />
                Browse Volumes…
              </Button>
            </div>
            <p className="text-xs text-muted-foreground">
              The model.json file produced by the vibe agent (v0.3.x, v0.4.x, or v0.5.x)
            </p>
          </div>

          <VolumePicker
            open={pickerOpen}
            onOpenChange={setPickerOpen}
            onSelect={(path) => {
              setVolumePath(path);
              setAnalysis(null);
              setError(null);
            }}
          />

          {preview && !analysis && (
            <ImportPreviewCard preview={preview} />
          )}

          {!analysis && !error && (
            <div className="flex justify-end">
              <Button
                onClick={() => analyzeMutation.mutate()}
                disabled={analyzeDisabled}
              >
                {analyzeMutation.isPending && <Loader2 className="h-4 w-4 mr-2 animate-spin" />}
                Analyze
              </Button>
            </div>
          )}

          {error && (
            <div className="rounded-md border border-destructive/50 bg-destructive/10 p-3 text-sm space-y-2">
              <div className="flex items-start gap-2">
                <AlertTriangle className="h-4 w-4 mt-0.5 text-destructive shrink-0" />
                <p className="text-destructive">{error}</p>
              </div>
              <Button variant="outline" size="sm" onClick={reset}>Try again</Button>
            </div>
          )}

          {analysis && analysis.valid && (
            <div className="rounded-md border border-green-500/30 bg-green-500/5 p-3 space-y-3">
              <div className="flex items-start gap-2">
                <CheckCircle2 className="h-4 w-4 mt-0.5 text-green-600 dark:text-green-400 shrink-0" />
                <div className="space-y-1.5 flex-1">
                  <p className="text-sm">{analysis.message}</p>
                  <div className="flex flex-wrap gap-1.5">
                    <Badge variant="secondary" className="text-[10px]">
                      {analysis.domain_count} domains
                    </Badge>
                    <Badge variant="secondary" className="text-[10px]">
                      {analysis.product_count} products
                    </Badge>
                    <Badge variant="secondary" className="text-[10px]">
                      {analysis.attribute_count} attributes
                    </Badge>
                    <Badge variant="secondary" className="text-[10px]">
                      {analysis.fk_count} FKs
                    </Badge>
                  </div>
                </div>
              </div>

              {hasMismatch && (
                <div
                  data-testid="business-mismatch-warning"
                  className="border-t border-warning/40 pt-3 space-y-2"
                >
                  <div className="flex items-start gap-2">
                    <AlertTriangle className="h-4 w-4 mt-0.5 text-warning shrink-0" />
                    <div className="space-y-1.5 flex-1">
                      <p className="text-sm font-medium">
                        Business identity does not match this model.json
                      </p>
                      <ul className="text-xs text-muted-foreground space-y-0.5">
                        {mismatches.map((m) => (
                          <li key={m.field}>
                            <span className="font-mono">{m.field}</span>:
                            {" "}model.json says
                            {" "}<span className="font-medium">"{m.source_value}"</span>,
                            this business is
                            {" "}<span className="font-medium">"{m.current_value}"</span>
                          </li>
                        ))}
                      </ul>
                    </div>
                  </div>
                  <label className="flex items-center gap-2 text-xs cursor-pointer">
                    <Checkbox
                      checked={acceptMismatch}
                      onCheckedChange={(v) => setAcceptMismatch(v === true)}
                    />
                    Ignore field mismatches and import anyway
                  </label>
                </div>
              )}

              <ImportScopeChoice
                analysis={analysis}
                chosen={chosenScope}
                onChoose={setChosenScope}
                disabled={executeMutation.isPending}
              />

              {(analysis.warnings?.length ?? 0) > 0 && (
                <div className="border-t border-border pt-2">
                  <p className="text-xs font-medium mb-1">Warnings ({analysis.warnings!.length})</p>
                  <ul className="text-xs text-muted-foreground space-y-0.5 list-disc list-inside">
                    {analysis.warnings!.slice(0, 5).map((w, i) => (
                      <li key={i}>{w}</li>
                    ))}
                    {analysis.warnings!.length > 5 && (
                      <li>...and {analysis.warnings!.length - 5} more</li>
                    )}
                  </ul>
                </div>
              )}

              {preview && (
                <ImportPreviewCard preview={preview} compact />
              )}

              <div className="flex justify-end gap-2 pt-1">
                <Button variant="outline" size="sm" onClick={reset}>
                  Cancel
                </Button>
                <Button
                  size="sm"
                  onClick={() => executeMutation.mutate()}
                  disabled={importDisabled}
                >
                  {executeMutation.isPending && <Loader2 className="h-4 w-4 mr-2 animate-spin" />}
                  Import as new version
                </Button>
              </div>

              <p className="text-[10px] text-muted-foreground">
                Imported version will be marked <span className="font-semibold">draft</span>.
                Run the install operation separately to install it into Unity Catalog.
              </p>
            </div>
          )}

          {analysis && !analysis.valid && (
            <div className="rounded-md border border-destructive/50 bg-destructive/10 p-3 text-sm space-y-2">
              <div className="flex items-start gap-2">
                <X className="h-4 w-4 mt-0.5 text-destructive shrink-0" />
                <p className="text-destructive">{analysis.message}</p>
              </div>
              <Button variant="outline" size="sm" onClick={reset}>Try another file</Button>
            </div>
          )}
        </div>
      </DialogContent>
    </Dialog>
  );
}


/**
 * Preview card — shown before analyze (full) and after analyze (compact).
 *
 * Surfaces three things:
 *  1. Whether model.json sits at the path (error icon if not).
 *  2. The next-vibes status (success line when found, warning banner
 *     when missing). Missing next-vibes does NOT block import — the
 *     model still lands, but the agent's next-iteration suggestions
 *     cannot be reconstructed for this version.
 *  3. The list of typed companion artifacts that will be indexed.
 */
export function ImportPreviewCard({
  preview,
  compact = false,
}: {
  preview: ImportPreviewOut;
  compact?: boolean;
}) {
  const groupedTypes = countByType(preview.companion_artifacts ?? []);

  return (
    <div
      data-testid="import-preview-card"
      className="rounded-md border border-border bg-muted/30 p-3 space-y-2 text-sm"
    >
      <div className="flex items-start gap-2">
        {preview.model_json_found ? (
          <CheckCircle2 className="h-4 w-4 mt-0.5 text-green-600 dark:text-green-400 shrink-0" />
        ) : (
          <X
            data-testid="preview-model-json-missing"
            className="h-4 w-4 mt-0.5 text-destructive shrink-0"
          />
        )}
        <div className="flex-1">
          {preview.model_json_found ? (
            <p>Will import <span className="font-mono text-xs">model.json</span></p>
          ) : (
            <p className="text-destructive">
              No <span className="font-mono text-xs">model.json</span> at this path. Import disabled.
            </p>
          )}
        </div>
      </div>

      {preview.next_vibes_status === "missing" ? (
        <div
          data-testid="preview-next-vibes-missing-warning"
          role="alert"
          className="flex items-start gap-2 rounded border border-warning/40 bg-warning/5 p-2 text-xs"
        >
          <FileWarning className="h-4 w-4 mt-0.5 text-warning shrink-0" />
          <p>
            <span className="font-mono">next_vibes.txt</span> not found at this path.
            The model imports without it, but next-iteration suggestions cannot be reconstructed.
          </p>
        </div>
      ) : (
        <p
          data-testid="preview-next-vibes-success"
          className="flex items-center gap-2 text-xs text-muted-foreground"
        >
          <CheckCircle2 className="h-3 w-3 text-green-600 dark:text-green-400 shrink-0" />
          Next vibes will be imported (
          <span className="font-mono">.{preview.next_vibes_status}</span>)
        </p>
      )}

      {!compact && (preview.total_artifact_count ?? 0) > 0 && (
        <div className="flex items-start gap-2 pt-1 text-xs text-muted-foreground border-t border-border">
          <Files className="h-3 w-3 mt-0.5 shrink-0" />
          <p>
            {preview.total_artifact_count} companion artifact
            {(preview.total_artifact_count ?? 0) === 1 ? "" : "s"}:
            {" "}
            {Object.entries(groupedTypes)
              .map(([t, n]) => `${n} ${t}`)
              .join(", ")}
          </p>
        </div>
      )}
    </div>
  );
}


function countByType(artifacts: { artifact_type: string }[]): Record<string, number> {
  const out: Record<string, number> = {};
  for (const a of artifacts) {
    out[a.artifact_type] = (out[a.artifact_type] ?? 0) + 1;
  }
  return out;
}
