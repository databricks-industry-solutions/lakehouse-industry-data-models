/**
 * What a failed install run offers (design §1 B3, "failure in the middle is
 * truthful"): "Install v3 again" for the version the run installed and, when
 * the run first uninstalled the version that occupied the catalog and that
 * step succeeded, "Install v5 again" so the catalog can hold a model again.
 * Both open the install dialog with the run's catalog preselected. A source
 * industry's version the run uninstalled first (a kickstarted business's
 * install over its industry) is named, with no button: it belongs to the
 * industry.
 */
import { useState } from "react";
import { RotateCcw } from "lucide-react";
import {
  useGetBusiness,
  useListVersions,
  type BusinessOut,
  type ModelVersionOut,
  type RunOperationOut,
  type RunOut,
} from "@/lib/api";
import { isForeignUninstall } from "@/lib/operations";
import selector from "@/lib/selector";
import { versionScopeLabel } from "@/lib/version-label";
import { Button } from "@/components/ui/button";
import { Card, CardContent } from "@/components/ui/card";
import { VersionOperationDialog } from "@/components/runs/version-operation-dialog";

/** The catalog the run installed into: the request, else the dispatched widget. */
export function runTargetCatalog(
  runParams: Record<string, unknown>,
  operations: readonly RunOperationOut[],
): string {
  for (const key of ["catalog", "deployment_catalog"]) {
    const v = runParams[key];
    if (typeof v === "string" && v.trim()) return v.trim();
  }
  for (const op of operations) {
    const v = op.dispatched_widgets?.["catalog"];
    if (typeof v === "string" && v.trim()) return v.trim();
  }
  return "";
}

const ALL_OWN = { has: () => true };

/** The versions to offer again: the install's target, then the occupant
 *  its succeeded uninstall step removed (a version of this business,
 *  ``ownVersionIds``). */
export function versionsToInstallAgain(
  run: Pick<RunOut, "version_id">,
  operations: readonly RunOperationOut[],
  ownVersionIds: { has(id: string): boolean } = ALL_OWN,
): string[] {
  const install = operations.find((o) => o.operation_name === "install");
  const target = install?.parent_version_id || run.version_id || null;
  const uninstalled = operations.find(
    (o) =>
      o.operation_name === "uninstall" &&
      o.status === "succeeded" &&
      o.parent_version_id &&
      !isForeignUninstall(o, ownVersionIds),
  )?.parent_version_id;
  return [target, uninstalled].filter(
    (id, i, all): id is string => !!id && all.indexOf(id) === i,
  );
}

/** The other business's versions the run's succeeded uninstall steps took
 *  out of the catalog. A release-only step (no agent job, no dispatched
 *  widgets) dropped nothing and is left out. */
export function foreignVersionsUninstalled(
  operations: readonly RunOperationOut[],
  ownVersionIds: { has(id: string): boolean },
): string[] {
  return operations
    .filter(
      (o) =>
        o.status === "succeeded" &&
        isForeignUninstall(o, ownVersionIds) &&
        Object.keys(o.dispatched_widgets ?? {}).length > 0,
    )
    .map((o) => o.parent_version_id as string);
}

export function FailedInstallActions({
  businessId,
  run,
  runParams,
  operations,
}: {
  businessId: string;
  run: RunOut;
  runParams: Record<string, unknown>;
  operations: readonly RunOperationOut[];
}) {
  const { data } = useListVersions({ params: { business_id: businessId } });
  const versions = data?.data ?? [];
  const own = new Set(versions.map((v) => v.id));
  const foreign = data ? foreignVersionsUninstalled(operations, own) : [];
  const { data: business } = useGetBusiness({
    params: { business_id: businessId },
    query: { enabled: foreign.length > 0, ...selector<BusinessOut>().query },
  });
  const industryId = business?.source_industry_id ?? "";
  const { data: industry } = useGetBusiness({
    params: { business_id: industryId },
    query: { enabled: !!industryId, ...selector<BusinessOut>().query },
  });
  const { data: industryVersions } = useListVersions({
    params: { business_id: industryId },
    query: { enabled: !!industryId },
  });
  const [open, setOpen] = useState<ModelVersionOut | null>(null);
  const catalog = runTargetCatalog(runParams, operations);
  const offered = versionsToInstallAgain(run, operations, data ? own : ALL_OWN)
    .map((id) => versions.find((v) => v.id === id))
    .filter((v): v is ModelVersionOut => !!v);
  const industryLabels = foreign.map((id) => {
    const v = industryVersions?.data?.find((x) => x.id === id);
    const label = v ? versionScopeLabel(v.version, v.scope) : "a version";
    return industry?.name ? `${industry.name} ${label}` : `the source industry's ${label}`;
  });
  const uninstalled = [
    ...industryLabels,
    ...(offered.length > 1 ? [versionScopeLabel(offered[1].version, offered[1].scope)] : []),
  ];
  if (offered.length === 0 && uninstalled.length === 0) return null;
  return (
    <Card data-testid="failed-install-actions">
      <CardContent className="flex flex-wrap items-center gap-2 pt-6 text-sm">
        <span className="text-muted-foreground">
          {uninstalled.length > 0
            ? `The install failed after ${uninstalled.join(" and ")} ${uninstalled.length > 1 ? "were" : "was"} uninstalled${catalog ? ` from ${catalog}` : ""}.`
            : "The install failed."}
        </span>
        {offered.map((v) => (
          <Button key={v.id} size="sm" variant="outline" onClick={() => setOpen(v)}>
            <RotateCcw className="mr-1.5 h-3.5 w-3.5" aria-hidden />
            Install v{v.version} again
          </Button>
        ))}
      </CardContent>
      {open && (
        <VersionOperationDialog
          open
          onOpenChange={(o) => {
            if (!o) setOpen(null);
          }}
          businessId={businessId}
          intent="install"
          version={open}
          versions={versions}
          initialCatalog={catalog}
        />
      )}
    </Card>
  );
}
