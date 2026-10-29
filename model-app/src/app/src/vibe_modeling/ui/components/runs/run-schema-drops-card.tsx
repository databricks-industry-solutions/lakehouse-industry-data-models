/**
 * The run page's card for an orphan-schema drop run: each schema it dropped
 * or failed to drop, with the error (`listRunSchemaDrops`, the run's
 * `run_schema_drops` rows).
 */
import { CheckCircle, XCircle } from "lucide-react";
import { useListRunSchemaDrops } from "@/lib/api";
import { apiErrorMessage } from "@/lib/api-error";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Skeleton } from "@/components/ui/skeleton";

export function RunSchemaDropsCard({
  businessId,
  runId,
  active,
}: {
  businessId: string;
  runId: string;
  /** The run is still going: read the outcomes again every few seconds. */
  active: boolean;
}) {
  const query = useListRunSchemaDrops({
    params: { business_id: businessId, run_id: runId },
    query: { retry: false, refetchInterval: active ? 5_000 : false },
  });
  const rows = query.data?.data ?? [];
  const dropped = rows.filter((r) => r.status === "dropped").length;
  return (
    <Card data-testid="run-schema-drops">
      <CardHeader className="pb-2">
        <CardTitle className="text-base">Schemas</CardTitle>
      </CardHeader>
      <CardContent className="space-y-2 text-sm">
        {query.isPending ? (
          <Skeleton className="h-12 w-full" />
        ) : query.isError ? (
          <p role="alert" className="text-destructive">{apiErrorMessage(query.error, "The schemas could not be loaded.")}</p>
        ) : (
          <>
            <p className="text-muted-foreground">
              {dropped} of {rows.length} {rows.length === 1 ? "schema" : "schemas"} dropped.
            </p>
            <ul className="space-y-1.5">
              {rows.map((r) => (
                <li key={r.name} data-testid="run-schema-drop" data-status={r.status} className="space-y-0.5">
                  <span className="flex items-center gap-2">
                    {r.status === "dropped" ? (
                      <CheckCircle className="h-3.5 w-3.5 text-muted-foreground" aria-hidden />
                    ) : (
                      <XCircle className="h-3.5 w-3.5 text-destructive" aria-hidden />
                    )}
                    <span className="font-mono">{r.name}</span>
                    <span className="text-muted-foreground">
                      {r.status === "dropped" ? "dropped" : r.status === "failed" ? "not dropped" : "pending"}
                      {` (${r.table_count ?? 0} ${r.table_count === 1 ? "table" : "tables"})`}
                    </span>
                  </span>
                  {r.error && <span className="block pl-5 text-xs text-destructive">{r.error}</span>}
                </li>
              ))}
            </ul>
          </>
        )}
      </CardContent>
    </Card>
  );
}
