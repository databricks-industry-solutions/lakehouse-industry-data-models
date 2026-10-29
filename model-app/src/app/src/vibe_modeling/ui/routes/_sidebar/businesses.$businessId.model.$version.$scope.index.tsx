import { createFileRoute, Link, useNavigate, useSearch } from "@tanstack/react-router";
import { Suspense, useState } from "react";
import { ErrorBoundary } from "react-error-boundary";
import { AssessButton } from "@/components/assessment/assess-button";
import {
  useGetBusinessSuspense,
  useListVersionsSuspense,
  type BusinessKind,
  type ModelVersionOut,
} from "@/lib/api";
import { deleteState } from "@/lib/version-lifecycle";
import { DeleteVersionsDialog } from "@/components/versions/delete-versions-dialog";
import { VersionOperationDialog } from "@/components/runs/version-operation-dialog";
import { LinkRunAction } from "@/components/runs/link-run-dialog";
import { isNotFoundError } from "@/lib/api-error";
import { selector } from "@/lib/selector";
import { versionScopeLabel } from "@/lib/version-label";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Skeleton } from "@/components/ui/skeleton";
import { useBreadcrumbs } from "@/components/explorer/breadcrumb-context";
import { Trash2 } from "lucide-react";
import { ModelTabsShell } from "@/components/model/model-tabs-shell";
import { ToolbarNote } from "@/components/model/toolbar-note-slot";
import { ModelSearch } from "@/components/model/model-search";
import type { ModelViewTab } from "@/components/vibe-inputs/model-view";

const validTabs = ["overview", "diagram", "relationships", "ontology", "artifacts", "feedback", "statistics"] as const;
type ModelTab = (typeof validTabs)[number];

export const Route = createFileRoute(
  "/_sidebar/businesses/$businessId/model/$version/$scope/"
)({
  // `domain` (optional) is the Diagram tab's picked domain: the diagram draws
  // that domain in place. Absent = the all-domains diagram.
  validateSearch: (
    search: Record<string, unknown>,
  ): { tab: ModelTab; domain?: string } => ({
    tab: validTabs.includes(search.tab as ModelTab)
      ? (search.tab as ModelTab)
      : "overview",
    ...(typeof search.domain === "string" && search.domain
      ? { domain: search.domain }
      : {}),
  }),
  component: () => {
    const { businessId, version, scope } = Route.useParams();
    return (
      <div className="p-4 space-y-3">
        <ErrorBoundary
          // Re-throw non-404s so the parent generic boundary still
          // surfaces them. We only own the "version doesn't exist for
          // this business" empty-state. Reset when the route params change
          // (sidebar links reuse this mounted route) so the card clears.
          resetKeys={[businessId, version, scope]}
          fallbackRender={({ error }) => {
            if (isNotFoundError(error)) {
              return (
                <ModelVersionMissing
                  businessId={businessId}
                  version={version}
                  scope={scope}
                />
              );
            }
            throw error;
          }}
        >
          <Suspense fallback={<PageSkeleton />}>
            <ModelVersionPage businessId={businessId} version={version} scope={scope} />
          </Suspense>
        </ErrorBoundary>
      </div>
    );
  },
});

function ModelVersionMissing({
  businessId,
  version,
  scope,
}: {
  businessId: string;
  version: string;
  scope: string;
}) {
  return (
    <Card>
      <CardHeader>
        <CardTitle>Model version not found</CardTitle>
      </CardHeader>
      <CardContent className="space-y-4">
        <p className="text-sm text-muted-foreground">
          Version {versionScopeLabel(version, scope)} doesn't exist for this business.
        </p>
        <Button asChild variant="outline" size="sm">
          <Link
            to="/businesses/$businessId/explorer"
            params={{ businessId }}
          >
            Back to Explorer
          </Link>
        </Button>
      </CardContent>
    </Card>
  );
}

export function ModelVersionPage({
  businessId,
  version,
  scope,
}: {
  businessId: string;
  version: string;
  /** Required model scope ("ecm" | "mvm"). Tests may also pass an empty
   *  string for legacy fixtures; downstream lookups gracefully degrade. */
  scope: string;
}) {
  const navigate = useNavigate();
  const { tab, domain } = useSearch({
    from: "/_sidebar/businesses/$businessId/model/$version/$scope/",
  });

  // Switching tabs keeps the picked domain, so the Diagram and the Ontology
  // show the same domain.
  const setTab = (value: ModelViewTab) => {
    navigate({
      to: ".",
      search: { tab: value as ModelTab, ...(domain ? { domain } : {}) },
      replace: true,
    });
  };

  // Business + versions are resolved here (not just in the shell) because the
  // breadcrumb trail and the DeleteVersionButton both need them; react-query
  // dedupes with the shell's identical fetches.
  const { data: business } = useGetBusinessSuspense({
    params: { business_id: businessId },
    ...selector(),
  });
  const { data: versions } = useListVersionsSuspense({
    params: { business_id: businessId },
    ...selector(),
  });
  // Two MV rows can share `version` if their `scope` differs (the model-versioning work),
  // so use `(version, scope)` as the natural key. Fall back to the
  // version-only match if scope is unknown (legacy callers).
  const currentVersion =
    versions.find(
      (v: any) => v.version === Number(version) && (v.scope || "") === scope,
    ) ?? versions.find((v: any) => v.version === Number(version));

  // The Diagram and the Ontology share one picked domain, `?domain=`. Their
  // dropdowns (and a diagram related-domain group header click) write it and
  // both tabs draw it in place; "All domains" removes it. Push (not replace)
  // so Back returns to the previous view.
  const handlePickedDomain = (next: string | null) => {
    if ((next ?? undefined) === domain) return;
    navigate({
      to: ".",
      search: { tab, ...(next ? { domain: next } : {}) },
    });
  };

  // Overview: a pick opens the domain's page on its Products tab.
  const handleOpenDomain = (next: string) => {
    navigate({
      to: "/businesses/$businessId/model/$version/$scope/$domainName",
      params: { businessId, version, scope, domainName: next },
      search: { tab: "products" },
    });
  };

  useBreadcrumbs([
    {
      label: business.name,
      to: "/businesses/$businessId",
      params: { businessId },
    },
    {
      label: "Explorer",
      to: "/businesses/$businessId/explorer",
      params: { businessId },
    },
    { label: versionScopeLabel(version, scope) },
  ]);

  return (
    <ModelTabsShell
      businessId={businessId}
      version={version}
      scope={scope}
      tab={tab}
      onTabChange={setTab}
      searchTrigger={<ModelSearch businessId={businessId} version={version} scope={scope} />}
      pickedDomain={domain}
      onDomainNavigate={handlePickedDomain}
      onOntologyDomainPick={handlePickedDomain}
      onOpenDomain={handleOpenDomain}
      versionActions={
        <>
          {currentVersion && <LinkRunAction businessId={businessId} version={currentVersion} />}
          {(currentVersion as any)?.id && (
            <AssessButton
              businessId={businessId}
              versionId={(currentVersion as any).id}
              installed={
                (currentVersion as any).deployment_status === "deployed" &&
                !!(currentVersion as any).uc_catalog
              }
            />
          )}
          <DeleteVersionButton
          businessId={businessId}
          businessName={business.name}
          businessKind={business.kind}
          version={version}
          scope={scope}
          versions={versions}
          currentVersionId={(currentVersion as any)?.id}
        />
        </>
      }
    />
  );
}

export function DeleteVersionButton({
  businessId,
  businessName,
  businessKind,
  version,
  scope,
  versions,
  currentVersionId,
}: {
  businessId: string;
  businessName: string;
  businessKind?: BusinessKind | null;
  version: string;
  scope: string;
  versions: ModelVersionOut[];
  currentVersionId: string | undefined;
}) {
  const navigate = useNavigate();
  const [dialogOpen, setDialogOpen] = useState(false);
  const [uninstallOpen, setUninstallOpen] = useState(false);
  const current = versions.find((v) => v.id === currentVersionId);
  if (!current) return null;
  const sameScope = versions.filter((v) => !scope || (v.scope || "") === scope);
  const state = deleteState(current, sameScope);

  return (
    <>
      <div className="flex items-center gap-2">
        <Button
          variant="destructive"
          size="sm"
          disabled={!state.allowed}
          onClick={() => setDialogOpen(true)}
          title={state.reason}
          aria-describedby={state.reason ? "delete-version-reason" : undefined}
        >
          <Trash2 className="h-4 w-4 mr-2" />
          {state.label}
        </Button>
        {state.reason && (
          <ToolbarNote>
            <span id="delete-version-reason" className="max-w-xl text-right text-xs text-muted-foreground" data-testid="delete-version-reason">
              {state.reason}{" "}
              {state.installed && (
                <button
                  type="button"
                  className="font-medium text-foreground underline underline-offset-2"
                  onClick={() => setUninstallOpen(true)}
                >
                  Uninstall
                </button>
              )}
            </span>
          </ToolbarNote>
        )}
      </div>
      {dialogOpen && (
        <DeleteVersionsDialog
          open
          onOpenChange={setDialogOpen}
          businessId={businessId}
          businessName={businessName}
          businessKind={businessKind}
          targets={[{ id: current.id, version: Number(version), scope }]}
          onDeleted={() =>
            navigate({
              to: "/businesses/$businessId/explorer",
              params: { businessId },
            })
          }
        />
      )}
      {state.installed && uninstallOpen && (
        <VersionOperationDialog
          open
          onOpenChange={setUninstallOpen}
          businessId={businessId}
          intent="uninstall"
          version={current}
          versions={versions}
        />
      )}
    </>
  );
}

function PageSkeleton() {
  return (
    <div className="space-y-6">
      <Skeleton className="h-8 w-64" />
      <Skeleton className="h-10 w-96" />
      <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-5 gap-4">
        {[...Array(5)].map((_, i) => (
          <Skeleton key={i} className="h-20" />
        ))}
      </div>
      <div className="grid grid-cols-3 gap-4">
        {[...Array(6)].map((_, i) => (
          <Skeleton key={i} className="h-32" />
        ))}
      </div>
    </div>
  );
}
