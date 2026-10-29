/**
 * The business page's unfinished `_metamodel` cleanups (add §6.1, R1): while a
 * deleted version's registry rows are still in a catalog, the agent sees it
 * as its head there and the next run on that scope would fail. Lists each
 * pending or failed cleanup with its last error and offers "Retry cleanup"
 * (`retryMetamodelCleanup`, BusinessAdmins). Renders nothing when all are done.
 */
import { useState } from "react";
import { useQueryClient } from "@tanstack/react-query";
import { AlertTriangle, RefreshCw } from "lucide-react";
import { toast } from "sonner";
import {
  listMetamodelCleanupsKey,
  retryMetamodelCleanup,
  useListMetamodelCleanups,
  type MetamodelCleanupOut,
} from "@/lib/api";
import { useUserRole, isBusinessAdmin } from "@/lib/hooks";
import { notifyError } from "@/lib/notify";
import { versionScopeLabel } from "@/lib/version-label";
import { Button } from "@/components/ui/button";

function CleanupRow({
  businessId,
  row,
  canRetry,
}: {
  businessId: string;
  row: MetamodelCleanupOut;
  canRetry: boolean;
}) {
  const queryClient = useQueryClient();
  const [busy, setBusy] = useState(false);
  const label = versionScopeLabel(row.version, row.scope);
  const retry = async () => {
    setBusy(true);
    try {
      const res = await retryMetamodelCleanup({ business_id: businessId, cleanup_id: row.id });
      if (res.data.status === "done") toast.success(`Cleanup of deleted ${label} in ${row.catalog} finished.`);
      else notifyError(res.data.last_error || `Cleanup of deleted ${label} in ${row.catalog} failed again.`);
    } catch (err) {
      notifyError(err, { title: "Retry cleanup failed" });
    } finally {
      await queryClient.invalidateQueries({ queryKey: listMetamodelCleanupsKey({ business_id: businessId }) });
      setBusy(false);
    }
  };
  return (
    <li className="flex flex-wrap items-center gap-2" data-testid="metamodel-cleanup-row">
      <span className="text-sm">
        Cleanup of deleted <strong>{label}</strong> is{" "}
        {row.status === "failed" ? "failing" : "not finished"} in{" "}
        <span className="font-mono">{row.catalog}</span>.
      </span>
      {row.last_error && <span className="text-xs text-muted-foreground">{row.last_error}</span>}
      {canRetry && (
        <Button size="sm" variant="outline" disabled={busy} onClick={() => void retry()}>
          <RefreshCw className={`mr-1.5 h-3.5 w-3.5 ${busy ? "animate-spin" : ""}`} aria-hidden />
          {busy ? "Retrying..." : "Retry cleanup"}
        </Button>
      )}
    </li>
  );
}

export function MetamodelCleanupsPanel({ businessId }: { businessId: string }) {
  const role = useUserRole();
  // Same rule as the install dialog's also-delete: only a known admin role
  // sees the action (the server enforces BusinessAdminOnly either way).
  const canRetry = isBusinessAdmin(role);
  const { data } = useListMetamodelCleanups({
    params: { business_id: businessId },
    query: { retry: false, staleTime: 15_000 },
  });
  const rows = data?.data ?? [];
  if (rows.length === 0) return null;
  return (
    <div
      role="status"
      data-testid="metamodel-cleanups"
      className="space-y-2 rounded-md border border-warning/40 bg-warning/5 px-3 py-2"
    >
      <p className="flex items-center gap-2 text-sm font-medium text-warning">
        <AlertTriangle className="h-4 w-4" aria-hidden />
        Until a cleanup finishes, the agent still sees the deleted version in that catalog, and runs on its scope there fail.
      </p>
      <ul className="space-y-1.5">
        {rows.map((r) => (
          <CleanupRow key={r.id} businessId={businessId} row={r} canRetry={canRetry} />
        ))}
      </ul>
    </div>
  );
}
