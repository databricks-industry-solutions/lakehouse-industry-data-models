import { Link } from "@tanstack/react-router";
import { useQueryClient } from "@tanstack/react-query";
import { Layers } from "lucide-react";
import {
  useListVibeInputs,
  useListRunsForVersion,
  useGetEvolutionMetrics,
  useGetNextVibeMetrics,
  listVersionsKey,
} from "@/lib/api";
import type {
  ModelVersionOut,
  VibeInputOut,
  RunListOut,
  EvolutionMetricsOut,
  NextVibeMetricsOut,
} from "@/lib/api";
import { selector } from "@/lib/selector";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { ChangeBadge } from "@/components/explorer/change-badge";
import { NextVibesCard } from "@/components/next-vibes/next-vibes-card";
import { CommandStrip } from "@/components/overview/command-strip";
import { MetricsBand } from "@/components/overview/metrics-band";
import { deriveOverviewMetrics } from "@/components/overview/metrics";
import { InstallationDriftDialog } from "@/components/explorer/installation-drift-dialog";
import { VersionReportCompact } from "@/components/runs/run-report-card";
import { VersionChangesSummary } from "@/components/runs/run-changes-card";

/**
 * Shared Overview tab body for the model page. Rendered by `ModelTabsShell`
 * (which both the model-version route and the input-review route mount), so
 * there is ONE copy of the metrics band + domain cards + next-vibes, not two.
 *
 * `showLifecycleActions` (default true) gates the run/install `CommandStrip`.
 * The input-review surface passes `false`: a review page must not offer run or
 * install lifecycle actions (and the shell also omits the destructive
 * DeleteVersionButton there via `versionActions`). Everything else - drift
 * reconcile prompt, metrics band, domain cards, next-vibes - is unconditional.
 */
export function ModelOverview({
  businessId,
  version,
  scope,
  currentVersion,
  versions,
  model,
  modelVersionId,
  defaultTargetPath,
  showLifecycleActions = true,
}: {
  businessId: string;
  version: string;
  scope: string;
  /** The page's version row; undefined while it is not in the list. */
  currentVersion: ModelVersionOut | undefined;
  versions: readonly ModelVersionOut[];
  model: any;
  modelVersionId: string;
  defaultTargetPath?: string;
  showLifecycleActions?: boolean;
}) {
  const queryClient = useQueryClient();
  const versionId = currentVersion?.id;
  const deploymentStatus = currentVersion?.deployment_status || "draft";
  return (
    <div className="space-y-6 mt-4">
      {versionId && (
        <InstallationDriftDialog
          versionId={versionId}
          enabled={deploymentStatus === "deployed"}
          onReconciled={() => {
            // Reconcile flips deployment_status in Lakebase. The overview's
            // "Installed" badge + command strip read it from the version list
            // (currentVersion), NOT an explorer query - so invalidate that too,
            // else the badge stays stale until a hard refresh. Keep the explorer
            // invalidation for the explorer list/context views.
            queryClient.invalidateQueries({
              queryKey: listVersionsKey({ business_id: businessId }),
            });
            queryClient.invalidateQueries({
              predicate: (q) =>
                Array.isArray(q.queryKey) &&
                typeof q.queryKey[0] === "string" &&
                String(q.queryKey[0]).includes("explorer"),
            });
          }}
        />
      )}

      {/* Command strip - replaces the old Actions + Runs cards. Suppressed on
          the input-review surface (showLifecycleActions=false): a review page
          offers no run/install lifecycle actions. */}
      {showLifecycleActions && currentVersion && (
        <CommandStrip
          businessId={businessId}
          version={currentVersion}
          versions={versions}
          defaultTargetPath={defaultTargetPath}
        />
      )}

      {showLifecycleActions && currentVersion && (
        <VersionReportCompact
          businessId={businessId}
          version={currentVersion}
          versions={versions}
        />
      )}
      {versionId && <VersionChangesSummary businessId={businessId} versionId={versionId} />}

      {/* Metrics band - review %, quality, change, size. The full Statistics
          tab (and review marking) lives in the tab bar, not behind a link. */}
      <ModelMetricsBand
        businessId={businessId}
        version={version}
        scope={scope}
        versionId={versionId}
        model={model}
      />

      {/* Domain cards */}
      <div className="space-y-3">
        <h2 className="text-lg font-semibold flex items-center gap-2">
          <Layers className="h-5 w-5" />
          Domains
        </h2>
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
          {(model.domains ?? []).map((d: any) => {
            const isDeleted = d.change_status === "deleted";
            const inner = (
              <Card className={`${isDeleted ? "opacity-50" : "hover:bg-accent/50 cursor-pointer"} transition-colors h-full`}>
                <CardHeader className="pb-2">
                  <CardTitle className="text-base flex items-center gap-2">
                    <span className={isDeleted ? "line-through" : ""}>{d.name}</span>
                    <ChangeBadge status={d.change_status} />
                    <div className="ml-auto">
                      <Badge variant="outline" className="text-xs">
                        {d.division}
                      </Badge>
                    </div>
                  </CardTitle>
                </CardHeader>
                <CardContent>
                  <p className="text-sm text-muted-foreground line-clamp-3">
                    {d.description}
                  </p>
                  <div className="mt-3 flex items-center gap-3 text-xs text-muted-foreground">
                    <span>
                      <strong>{d.product_count}</strong> tables
                    </span>
                    {(d.subdomains?.length ?? 0) > 0 && (
                      <span>
                        <strong>{d.subdomains.length}</strong> subdomains
                      </span>
                    )}
                    {d.references && <span>Ref: {d.references}</span>}
                  </div>
                  {(d.subdomains?.length ?? 0) > 0 && (
                    <div className="mt-2 flex flex-wrap gap-1">
                      {d.subdomains.map((s: any) => (
                        <Badge
                          key={s.name}
                          variant="secondary"
                          className="text-[10px] font-normal"
                          title={`${s.product_count} ${s.product_count === 1 ? "table" : "tables"}`}
                        >
                          {s.name}
                          <span className="ml-1 text-muted-foreground">
                            {s.product_count}
                          </span>
                        </Badge>
                      ))}
                    </div>
                  )}
                </CardContent>
              </Card>
            );
            return isDeleted ? (
              <div key={d.name} className="block">{inner}</div>
            ) : (
              <Link
                key={d.name}
                to="/businesses/$businessId/model/$version/$scope/$domainName"
                params={{ businessId, version, scope, domainName: d.name }}
                search={{ tab: "products" }}
                className="block"
              >
                {inner}
              </Link>
            );
          })}
        </div>
      </div>

      {modelVersionId && (
        <NextVibesCard
          businessId={businessId}
          modelVersionId={modelVersionId}
        />
      )}
    </div>
  );
}

/**
 * Fetches the supporting data the metrics band needs that doesn't ride on the
 * model summary - feedback + runs counts, plus the evolution (T16) and
 * next-vibe (T13) metrics - with non-suspense queries so the band paints
 * immediately and just fills in those figures when they arrive. The evolution
 * + next-vibe payloads back the confidence delta/sparkline, open-issue
 * severity split, Δ-issues, tokens/hours effort, and the next_vibes Quality
 * Score; until they resolve (or if they error) `deriveOverviewMetrics`
 * degrades those figures exactly as it does for a metadata-less version.
 */
function ModelMetricsBand({
  businessId,
  version,
  scope,
  versionId,
  model,
}: {
  businessId: string;
  version: string;
  scope: string;
  versionId: string | undefined;
  model: any;
}) {
  const { data: feedback } = useListVibeInputs({
    params: { business_id: businessId, version_id: versionId ?? null },
    query: { enabled: !!versionId, ...selector<VibeInputOut[]>().query },
  });
  const { data: runs } = useListRunsForVersion({
    params: { version_id: versionId ?? "" },
    query: { enabled: !!versionId, ...selector<RunListOut[]>().query },
  });
  const { data: evolution } = useGetEvolutionMetrics({
    params: { business_id: businessId, version_int: Number(version), scope },
    query: { ...selector<EvolutionMetricsOut>().query },
  });
  const { data: nextVibe } = useGetNextVibeMetrics({
    params: { business_id: businessId, version_int: Number(version), scope },
    query: { ...selector<NextVibeMetricsOut>().query },
  });

  const metrics = deriveOverviewMetrics(model, {
    feedbackCount: feedback?.filter((i) => i.status !== "deprecated").length ?? 0,
    runsCount: runs?.length ?? 0,
    evolution: evolution ?? null,
    nextVibe: nextVibe ?? null,
  });

  return (
    <MetricsBand
      metrics={metrics}
      businessId={businessId}
      version={version}
      scope={scope}
    />
  );
}
