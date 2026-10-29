import { useMemo } from "react";
import { Link } from "@tanstack/react-router";
import { GitBranch } from "lucide-react";
import {
  useGetRunLineage,
  useListRunOperations,
  useListVersions,
  type ModelVersionOut,
  type RunLineageVersionOut,
  type RunOperationOut,
  type RunStatus,
} from "@/lib/api";
import { Badge } from "@/components/ui/badge";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { isForeignUninstall } from "@/lib/operations";
import { isTerminalRunStatus } from "@/lib/run-status";
import { versionScopeLabel } from "@/lib/version-label";

// LineageCard renders the source / generated / operates-on relationships
// for a Run. Source/generated are derived from the run's RunOperation rows
// (the primary signal — survives version supersession + matches what the
// hierarchical pipeline below shows). The legacy lineage endpoint is kept
// only as a fallback for runs that pre-date the RunOperation wirer or
// haven't dispatched any operations yet (the row is hidden entirely if
// there's nothing to show). Operates-on is rendered when the lineage
// endpoint surfaces it; install/uninstall/samples/revert/import don't have
// a meaningful (parent → output) on RunOperation — they target a single
// existing ModelVersion which the endpoint surfaces directly off
// `Run.version_id`.
export function LineageCard({
  runId,
  businessId,
  runStatus,
}: {
  runId: string;
  businessId: string;
  runStatus: RunStatus;
}) {
  // Wrapped envelope (no selector) — we access `lineage?.data?.source_version`
  // below; mirrors the shape that the manual fetch returned.
  const { data: lineage } = useGetRunLineage({
    params: { business_id: businessId, run_id: runId },
    query: {
      staleTime: 15_000,
      retry: false,
    },
  });

  // Pull the same RunOperation rows the hierarchical pipeline below reads.
  // No second backend trip — TanStack Query dedupes on the key.
  const { data: opsData } = useListRunOperations({
    params: { business_id: businessId, run_id: runId },
    query: {
      // While the run is still in flight the latest op may flip from
      // "no output yet" → "output_version_id set", so refresh on the
      // same cadence as the hierarchical pipeline. Stop polling once
      // the run is terminal.
      refetchInterval: () => (isTerminalRunStatus(runStatus) ? false : 4_000),
      staleTime: 2_000,
    },
  });
  const operations: RunOperationOut[] = useMemo(
    () => (Array.isArray(opsData?.data) ? [...opsData!.data] : []),
    [opsData],
  );

  // Versions list — we need (id) → (version, scope, status, deployment_status)
  // so the chip can render "v2 MVM" and link to the natural-key URL. The
  // explorer/runs pages already fetch this list, so it's likely cached.
  const { data: versionsData } = useListVersions({
    params: { business_id: businessId },
    query: { staleTime: 30_000 },
  });
  const versionById = useMemo(() => {
    const map = new Map<string, ModelVersionOut>();
    for (const v of versionsData?.data ?? []) {
      map.set(v.id, v);
    }
    return map;
  }, [versionsData]);

  const sortedOps = useMemo(
    () => [...operations].sort((a, b) => a.step_index - b.step_index),
    [operations],
  );

  // Source = first operation's parent_version_id. For a unified pipeline,
  // later phases have intermediate parents (phase 2's parent is phase 1's
  // output) — those are pipeline plumbing, not "the parent the user picked".
  // For new-base-model runs phase 1 has no parent, so Source legitimately
  // resolves to null (rendered as "—" below).
  // Skipped: an uninstall of another business's version, the source
  // industry's version a kickstarted business's run removes first.
  const sourceVersionId =
    sortedOps.find((op) => !isForeignUninstall(op, versionById))?.parent_version_id ?? null;
  const sourceVersion = sourceVersionId ? versionById.get(sourceVersionId) : undefined;

  // Generated = the latest (highest step_index) op's output_version_id that
  // has been written. Earlier phases may have produced intermediate artifacts
  // (e.g. v2 ECM in phase 1) but the final artifact is what the user cares
  // about. Walk backwards so a half-finished pipeline still surfaces the
  // most-recent artifact.
  let generatedVersionId: string | null = null;
  for (let i = sortedOps.length - 1; i >= 0; i--) {
    if (sortedOps[i].output_version_id) {
      generatedVersionId = sortedOps[i].output_version_id ?? null;
      break;
    }
  }
  const generatedVersion = generatedVersionId
    ? versionById.get(generatedVersionId)
    : undefined;

  // Render Source/Generated from RunOperations whenever we have op rows.
  // If no op rows yet (legacy run pre-dating the wirer, or run dispatched
  // but no operations persisted) fall back to the lineage endpoint so the
  // card stays useful.
  const haveOps = sortedOps.length > 0;
  const operatesOn = lineage?.data?.operates_on_version ?? null;

  // Hide the card when there's truly nothing to show. For an in-flight
  // model-producing run the "Pending" generated row counts as content,
  // so it's enough to have any op rows to render something useful.
  const fallbackSource = !haveOps ? lineage?.data?.source_version ?? null : null;
  const fallbackGenerated = !haveOps ? lineage?.data?.generated_version ?? null : null;
  const renderSourceRow = haveOps || fallbackSource;
  const renderGeneratedRow = haveOps || fallbackGenerated;
  if (!renderSourceRow && !renderGeneratedRow && !operatesOn) return null;

  return (
    <Card>
      <CardHeader>
        <CardTitle className="text-base flex items-center gap-2">
          <GitBranch className="h-4 w-4" />
          Lineage
        </CardTitle>
      </CardHeader>
      <CardContent className="space-y-2 text-sm">
        {haveOps ? (
          <>
            <LineageSourceRow
              businessId={businessId}
              version={sourceVersion ? toLineageVersion(sourceVersion) : null}
            />
            <LineageGeneratedRow
              businessId={businessId}
              version={generatedVersion ? toLineageVersion(generatedVersion) : null}
              runStatus={runStatus}
            />
          </>
        ) : (
          <>
            {fallbackSource && (
              <LineageRow
                label="Source model version"
                businessId={businessId}
                version={fallbackSource}
              />
            )}
            {fallbackGenerated && (
              <LineageRow
                label="Generated model version"
                businessId={businessId}
                version={fallbackGenerated}
              />
            )}
          </>
        )}
        {operatesOn && (
          <LineageRow
            label="Operates on"
            businessId={businessId}
            version={operatesOn}
          />
        )}
      </CardContent>
    </Card>
  );
}

// Adapts a ModelVersionOut (from /businesses/{id}/versions) to the
// RunLineageVersionOut shape LineageRow already knows how to render. The
// `id` field is unused by LineageRow (it links via natural key (version,
// scope) so the URL stays human-readable across DB resets).
function toLineageVersion(mv: ModelVersionOut): RunLineageVersionOut {
  return {
    id: mv.id,
    version: mv.version,
    scope: mv.scope ?? "",
    status: mv.status,
    deployment_status: mv.deployment_status,
  };
}

function LineageSourceRow({
  businessId,
  version,
}: {
  businessId: string;
  version: RunLineageVersionOut | null;
}) {
  // null source = the run produces a base (new-base-model) — render an em
  // dash rather than a misleading "v0" link. Same shape applies to legacy
  // runs whose first op has no parent_version_id recorded.
  return (
    <div className="flex items-center gap-3">
      <span className="text-muted-foreground w-44 shrink-0">Source model version</span>
      {version ? (
        <LineageVersionLink businessId={businessId} version={version} showDeploymentBadge />
      ) : (
        <span className="text-muted-foreground" data-testid="lineage-source-empty">—</span>
      )}
    </div>
  );
}

function LineageGeneratedRow({
  businessId,
  version,
  runStatus,
}: {
  businessId: string;
  version: RunLineageVersionOut | null;
  runStatus: RunStatus;
}) {
  // Generated = the run's actual output. While the run is still working
  // (pending/running/stale) the operation hasn't written output_version_id
  // yet — show "Pending" so the user knows the pipeline hasn't reached
  // the artifact stage. On a terminal failure / cancel show
  // "Failed before generation" so the row doesn't link back to the parent
  // (the bug this fix is repairing — old code linked to the parent here).
  let placeholder: { label: string; testId: string } | null = null;
  if (!version) {
    if (runStatus === "running" || runStatus === "pending") {
      placeholder = { label: "Pending", testId: "lineage-generated-pending" };
    } else if (
      runStatus === "stale"
    ) {
      // Stale = watchdog hasn't seen progress recently, but the run is
      // still nominally in-flight. Treat the same as pending — the
      // pipeline may still produce an output.
      placeholder = { label: "Pending", testId: "lineage-generated-pending" };
    } else if (
      runStatus === "failed" ||
      runStatus === "cancelled" ||
      runStatus === "rolled_back_failed"
    ) {
      placeholder = {
        label: "Failed before generation",
        testId: "lineage-generated-failed",
      };
    } else {
      // completed but no output_version_id (non-model-producing run that
      // shouldn't be rendering a Generated row at all — defensive em dash).
      placeholder = { label: "—", testId: "lineage-generated-empty" };
    }
  }
  return (
    <div className="flex items-center gap-3">
      <span className="text-muted-foreground w-44 shrink-0">Generated model version</span>
      {version ? (
        <LineageVersionLink businessId={businessId} version={version} showDeploymentBadge />
      ) : (
        <span className="text-muted-foreground" data-testid={placeholder!.testId}>
          {placeholder!.label}
        </span>
      )}
    </div>
  );
}

function LineageRow({
  label,
  businessId,
  version,
}: {
  label: string;
  businessId: string;
  version: RunLineageVersionOut;
}) {
  return (
    <div className="flex items-center gap-3">
      <span className="text-muted-foreground w-44 shrink-0">{label}</span>
      <LineageVersionLink businessId={businessId} version={version} showDeploymentBadge />
    </div>
  );
}

function LineageVersionLink({
  businessId,
  version,
  showDeploymentBadge,
}: {
  businessId: string;
  version: RunLineageVersionOut;
  showDeploymentBadge: boolean;
}) {
  // Default to "mvm" if the lineage row has no scope yet (legacy runs created
  // before the (version, scope) reshape). The route guard rejects unknown
  // scopes so we keep this strictly within the {ecm, mvm} set.
  const scope = version.scope || "mvm";
  return (
    <>
      <Link
        to="/businesses/$businessId/model/$version/$scope"
        params={{ businessId, version: String(version.version), scope }}
        search={{ tab: "overview" }}
        className="font-medium text-primary hover:underline"
      >
        {/* Spec §4: source/output displayed as "v1 ECM" not just "v1". */}
        {versionScopeLabel(version.version, version.scope)}
      </Link>
      {showDeploymentBadge && (
        <Badge variant="outline" className="text-[10px] capitalize">
          {version.deployment_status}
        </Badge>
      )}
    </>
  );
}
