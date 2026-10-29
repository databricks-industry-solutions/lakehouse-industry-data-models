import { createFileRoute, Link, useNavigate } from "@tanstack/react-router";
import { Suspense, useState } from "react";
import { useQueryClient } from "@tanstack/react-query";
import { APP_FOLDERS_DELETE_NOTE, notifyBusinessDeleted, notifyDeleteFailed } from "@/lib/delete-outcome";
import { invalidateEntityLists } from "@/lib/delete-invalidation";
import { MarkdownView } from "@/components/ui/markdown-view";
import {
  ApiError,
  BusinessKind,
  deleteBusiness,
  useGetBusinessSuspense,
  useGetExplorerVersionsSuspense,
  useListBusinessesSuspense,
  useListIndustriesSuspense,
  useListSectorsSuspense,
  useListVersions,
  useListVersionsSuspense,
  listVersionsKey,
} from "@/lib/api";
import { VersionLifecycleBadges } from "@/components/versions/version-lifecycle-badges";
import { MetamodelCleanupsPanel } from "@/components/versions/metamodel-cleanups-panel";
import { selector } from "@/lib/selector";
import { useAssessReady } from "@/lib/assessment";
import { formatDate } from "@/lib/date";
import { industryDisplayName, kickstartSourceLabel } from "@/lib/industry";
import { sectorDisplayName } from "@/lib/sector";
import { stripVibeMarkers } from "@/lib/vibe-scope";
import { entityKindLabel, entityKindLabelLower } from "@/lib/entity-kind";
import { versionBrandLabel, versionScopeLabel } from "@/lib/version-label";
import { isInstalled } from "@/lib/version-lifecycle";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import {
  Dialog,
  DialogContent,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Skeleton } from "@/components/ui/skeleton";
import { useBreadcrumbs } from "@/components/explorer/breadcrumb-context";
import {
  ArrowLeft,
  Building2,
  GitBranch,
  ListTodo,
  ClipboardCheck,
  Pencil,
  Plus,
  Rocket,
  Sparkles,
  CheckCircle,
  Clock,
  Trash2,
  Upload,
  XCircle,
} from "lucide-react";
import { ImportModelDialog } from "@/components/import/import-dialog";
import { KickstartDialog } from "@/components/industry/kickstart-dialog";

export const Route = createFileRoute(
  "/_sidebar/businesses/$businessId/explorer"
)({
  component: () => {
    const { businessId } = Route.useParams();
    return (
      <div className="p-4 space-y-3">
        <Suspense fallback={<PageSkeleton />}>
          <ExplorerLanding businessId={businessId} />
        </Suspense>
      </div>
    );
  },
  errorComponent: BusinessExplorerError,
});

// Renders a 404-friendly card when the business query rejects. Mirrors
// the run-detail page's 404 shell — the most common cause is a stale
// URL (the business was deleted or the link is wrong). Other 4xx/5xx
// reuse the same shell with a less-specific copy.
// Exported for direct unit testing (`businesses-explorer-error.test.tsx`)
// without having to mount the full route + its suspense query graph.
export function BusinessExplorerError({ error }: { error: Error }) {
  const status = error instanceof ApiError ? error.status : 0;
  const isNotFound = status === 404;
  const title = isNotFound
    ? "Business not found"
    : "Couldn't load this business.";
  const detail = isNotFound
    ? "The business in the URL doesn't match any business in your workspace. It may have been deleted, or the link is incorrect."
    : error instanceof Error
      ? error.message
      : "Unexpected error.";
  return (
    <div className="p-6 space-y-4">
      <h1 className="text-2xl font-semibold tracking-tight">{title}</h1>
      <p className="text-sm text-muted-foreground">{detail}</p>
      <Button asChild>
        <Link to="/businesses">
          <ArrowLeft className="h-4 w-4 mr-2" />
          See all businesses
        </Link>
      </Button>
    </div>
  );
}

function ExplorerLanding({ businessId }: { businessId: string }) {
  const { data: business } = useGetBusinessSuspense({
    params: { business_id: businessId },
    ...selector(),
  });
  const { data: industries } = useListIndustriesSuspense(selector());
  // Versions drive the cascade decision: a business with any model versions
  // must delete with the cascade flag, or the endpoint refuses. This suspense
  // query dedupes with the one VersionsSection makes below.
  const { data: versions } = useGetExplorerVersionsSuspense({
    params: { business_id: businessId },
    ...selector(),
  });
  // Install state rides on the versions list; the server refuses a business
  // delete while any version is installed, so the dialog lists them first.
  // Not a suspense query, so the header does not wait on it; Delete stays off
  // until it has loaded.
  const lifecycle = useListVersions({ params: { business_id: businessId } });
  const lifecycleRows = lifecycle.data?.data ?? [];
  const navigate = useNavigate();
  const queryClient = useQueryClient();
  const { ready: assessReady } = useAssessReady();
  const [deleteOpen, setDeleteOpen] = useState(false);
  const [deleting, setDeleting] = useState(false);
  const versionCount = versions?.length ?? 0;
  const installedVersions = lifecycleRows.filter(isInstalled);
  // An industry is a ``businesses`` row with kind='industry' (ADR D-046); it
  // shares this explorer surface with plain businesses, so every user-facing
  // noun must follow the kind discriminator instead of hardcoding "business".
  const kindLabel = entityKindLabel(business.kind);
  const kindLower = entityKindLabelLower(business.kind);

  useBreadcrumbs([
    {
      label: business.name,
      to: "/businesses/$businessId",
      params: { businessId },
    },
    { label: "Explorer" },
  ]);

  const handleDelete = async () => {
    // Always cascade: a confirmed business delete removes the business AND all
    // its dependents (versions, runs, feedback, artifacts). Cascade on a
    // business with no dependents is a harmless no-op. Passing it
    // unconditionally avoids the endpoint's 409 when a business has runs or
    // feedback but no versions (e.g. a failed base-model run).
    setDeleting(true);
    try {
      const res = await deleteBusiness({ business_id: businessId, cascade: true });
      notifyBusinessDeleted(res.data, business.kind, business.name);
      await invalidateEntityLists(queryClient, "business");
      navigate({ to: "/businesses" });
    } catch (err) {
      if (notifyDeleteFailed(err, { fallback: `Failed to delete ${kindLower}` })) {
        await invalidateEntityLists(queryClient, "business");
      }
      // A version installed since the list loaded is the likely refusal.
      await queryClient.invalidateQueries({ queryKey: listVersionsKey({ business_id: businessId }) });
      setDeleting(false);
    }
  };

  return (
    <>
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-semibold tracking-tight">{business.name}</h1>
          {business.industry_alignment && (
            <Badge variant="secondary" className="mt-1">
              {industryDisplayName(business.industry_alignment, industries)}
            </Badge>
          )}
          {business.source_industry_id && (
            <Suspense
              fallback={
                <Skeleton className="mt-1.5 h-4 w-48" data-testid="provenance-skeleton" />
              }
            >
              <KickstartProvenance
                sourceIndustryId={business.source_industry_id}
                sourceVersion={business.source_version ?? null}
              />
            </Suspense>
          )}
        </div>
        <div className="flex gap-2">
          {business.kind === BusinessKind.industry && (
            <KickstartDialog
              industryBusinessId={businessId}
              industryName={business.name}
              industryDescription={business.description}
              trigger={
                <Button variant="outline" size="sm">
                  <Rocket className="h-4 w-4 mr-1.5" />
                  Kickstart a business
                </Button>
              }
            />
          )}
          <Button variant="outline" size="sm" asChild>
            <Link to="/businesses/$businessId/edit" params={{ businessId }}>
              <Pencil className="h-4 w-4 mr-1.5" />
              Edit
            </Link>
          </Button>
          <Button variant="outline" size="sm" asChild>
            <Link to="/businesses/$businessId/runs" params={{ businessId }}>
              <ListTodo className="h-4 w-4 mr-1.5" />
              Runs
            </Link>
          </Button>
          {assessReady && (
            <Button variant="outline" size="sm" asChild>
              <Link to="/businesses/$businessId/assessments" params={{ businessId }}>
                <ClipboardCheck className="h-4 w-4 mr-1.5" />
                Assessments
              </Link>
            </Button>
          )}
          {/* Destructive-outline keeps text readable in the light theme while
              still signalling the danger of the action. */}
          <Button
            variant="outline"
            size="sm"
            className="border-destructive text-destructive hover:bg-destructive/10 hover:text-destructive"
            onClick={() => setDeleteOpen(true)}
            title={`Delete this ${kindLower} and all its versions, runs, feedback, and artifacts.`}
          >
            <Trash2 className="h-4 w-4 mr-1.5" />
            Delete {kindLower}
          </Button>
        </div>
      </div>

      {/* Delete Confirmation */}
      <Dialog open={deleteOpen} onOpenChange={setDeleteOpen}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>Delete "{business.name}"?</DialogTitle>
          </DialogHeader>
          <div className="space-y-2 text-sm">
            {lifecycle.isError && (
              <p role="alert" className="text-destructive">
                Couldn't load the version list, so Delete is off.{" "}
                <button
                  type="button"
                  className="font-medium underline underline-offset-2"
                  onClick={() => void lifecycle.refetch()}
                >
                  Try again
                </button>
              </p>
            )}
            {installedVersions.length > 0 && (
              <div
                role="alert"
                data-testid="delete-business-installed"
                className="space-y-1.5 rounded-md border border-destructive/40 bg-destructive/5 px-3 py-2"
              >
                <p className="font-medium text-destructive">
                  Uninstall these versions first (Uninstall on each version's page):
                </p>
                <ul className="space-y-1">
                  {installedVersions.map((v) => (
                    <li key={v.id} className="text-foreground">
                      <Link
                        to="/businesses/$businessId/model/$version/$scope"
                        params={{ businessId, version: String(v.version), scope: v.scope || "mvm" }}
                        search={{ tab: "overview" }}
                        className="font-medium underline underline-offset-2"
                      >
                        {versionScopeLabel(v.version, v.scope)}
                      </Link>{" "}
                      is installed in <span className="font-mono">{v.uc_catalog || "a catalog"}</span>
                    </li>
                  ))}
                </ul>
              </div>
            )}
            <p className="text-destructive font-medium">
              This permanently deletes this {kindLower} AND all its model
              versions, runs and their history, feedback and business contexts.
            </p>
            {versionCount > 0 && (
              <p className="text-muted-foreground">
                {`${versionCount} version${versionCount === 1 ? "" : "s"} will be removed from Lakebase, `}
                with the agent's registry rows (<span className="font-mono">_metamodel</span>) in the
                catalogs the versions were written to or installed in. A version imported from a
                Volume keeps the rows in that Volume's catalog. {APP_FOLDERS_DELETE_NOTE}
              </p>
            )}
          </div>
          <DialogFooter>
            <Button variant="outline" disabled={deleting} onClick={() => setDeleteOpen(false)}>
              Cancel
            </Button>
            <Button
              variant="outline"
              disabled={deleting || !lifecycle.isSuccess || installedVersions.length > 0}
              className="border-destructive text-destructive hover:bg-destructive/10 hover:text-destructive"
              onClick={handleDelete}
            >
              {deleting ? "Deleting…" : `Delete ${kindLower}`}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      <MetamodelCleanupsPanel businessId={businessId} />

      <Suspense fallback={<SectionSkeleton />}>
        <VersionsSection businessId={businessId} />
      </Suspense>

      <Suspense fallback={<SectionSkeleton />}>
        <ContextSection business={business} kindLabel={kindLabel} />
      </Suspense>

      <DetailedDescriptionCard businessVibes={business.business_vibes || ""} />
    </>
  );
}

/** Provenance line for a kickstarted business: "Kickstarted from <industry>
 *  v<n>", linking back to the source industry's explorer. ``source_industry_id``
 *  is the industry's ``businesses`` row id (kind='industry'); resolve its name
 *  from the businesses list. If the source row is gone (deleted), still link to
 *  the id so the trail isn't lost. */
function KickstartProvenance({
  sourceIndustryId,
  sourceVersion,
}: {
  sourceIndustryId: string;
  sourceVersion: number | null;
}) {
  const { data: businesses } = useListBusinessesSuspense(selector());
  const source = businesses.find((b) => b.id === sourceIndustryId);
  return (
    <p className="mt-1.5 text-xs text-muted-foreground">
      Kickstarted from{" "}
      <Link
        to="/businesses/$businessId/explorer"
        params={{ businessId: sourceIndustryId }}
        className="font-medium text-foreground hover:underline"
      >
        {kickstartSourceLabel(source?.name, sourceVersion)}
      </Link>
    </p>
  );
}

/** The business's detailed Markdown description (``business_vibes``) — the
 *  primary instruction seed for the initial model vibe. Rendered full-width as
 *  Markdown; it lives only here (not in any model.json artifact). */
function DetailedDescriptionCard({ businessVibes }: { businessVibes: string }) {
  return (
    <Card className="flex min-h-[45vh] flex-col">
      <CardHeader className="pb-2">
        <CardTitle className="text-base">Detailed description</CardTitle>
      </CardHeader>
      <CardContent className="flex-1 overflow-auto">
        {businessVibes.trim() ? (
          <MarkdownView content={businessVibes} className="text-sm" />
        ) : (
          <p className="text-sm text-muted-foreground">
            No detailed description yet. Add one by editing the business — it's
            the primary instructions the agent uses to seed this business's
            initial model.
          </p>
        )}
      </CardContent>
    </Card>
  );
}

/**
 * Business Context card - name + the business's short description + sector.
 * `context_json` (agent-derived) was never meant to render in the UI; this
 * card shows the required short summary the user typed at create time, not
 * the agent's internal blob. Gracefully omits the description/sector lines
 * when absent so the card never renders header-only.
 */
export function ContextSection({
  business,
  kindLabel,
}: {
  business: { name: string; description?: string | null; sector_id?: string | null };
  kindLabel: string;
}) {
  const { data: sectors } = useListSectorsSuspense(selector());
  const sectorName = sectorDisplayName(business.sector_id, sectors);

  return (
    <Card>
      <CardHeader>
        <CardTitle className="flex items-center gap-2">
          <Building2 className="h-5 w-5" />
          {kindLabel} Context
        </CardTitle>
      </CardHeader>
      <CardContent className="space-y-3">
        <div>
          <dt className="text-xs font-medium text-muted-foreground uppercase tracking-wide">
            {kindLabel}
          </dt>
          <dd className="mt-1 text-sm">{business.name}</dd>
        </div>
        {business.description && (
          <div>
            <dt className="text-xs font-medium text-muted-foreground uppercase tracking-wide">
              Description
            </dt>
            <dd className="mt-1 text-sm">{business.description}</dd>
          </div>
        )}
        {sectorName && (
          <div>
            <dt className="text-xs font-medium text-muted-foreground uppercase tracking-wide">
              Sector
            </dt>
            <dd className="mt-1 text-sm">{sectorName}</dd>
          </div>
        )}
      </CardContent>
    </Card>
  );
}

const statusIcon: Record<string, React.ReactNode> = {
  completed: <CheckCircle className="h-4 w-4 text-green-500" />,
  generating: <Clock className="h-4 w-4 text-warning animate-spin" />,
  draft: <Clock className="h-4 w-4 text-muted-foreground" />,
  failed: <XCircle className="h-4 w-4 text-red-500" />,
};

function VersionsSection({ businessId }: { businessId: string }) {
  const { data: versions } = useGetExplorerVersionsSuspense({
    params: { business_id: businessId },
    ...selector(),
  });
  // The lifecycle columns (dry_run, replaced_*, draft_state) ride on the
  // versions list, not the explorer tree; join by id.
  const { data: lifecycleRows } = useListVersionsSuspense({
    params: { business_id: businessId },
    ...selector(),
  });

  if (versions.length === 0) {
    return (
      <Card>
        <CardContent className="py-8 flex flex-col items-center gap-3 text-muted-foreground">
          <p>No model versions yet.</p>
          <div className="flex gap-2">
            <ImportModelDialog
              businessId={businessId}
              trigger={
                <Button size="sm" variant="outline">
                  <Upload className="h-4 w-4 mr-1" />
                  Import pre-vibed model
                </Button>
              }
            />
            <Button size="sm" variant="outline" asChild>
              <Link
                to="/businesses/$businessId/runs/new"
                params={{ businessId }}
                search={{ operationType: "new base model" }}
              >
                <Plus className="h-4 w-4 mr-1" />
                Generate base model
              </Link>
            </Button>
          </div>
        </CardContent>
      </Card>
    );
  }

  return (
    <div className="space-y-3">
      <div className="flex items-center justify-between">
        <h2 className="text-lg font-semibold flex items-center gap-2">
          <GitBranch className="h-5 w-5" />
          Model Versions
        </h2>
        <div className="flex gap-2">
          <ImportModelDialog
            businessId={businessId}
            trigger={
              <Button size="sm" variant="outline">
                <Upload className="h-4 w-4 mr-1" />
                Import pre-vibed model
              </Button>
            }
          />
          <Button size="sm" asChild>
            <Link
              to="/businesses/$businessId/runs/new"
              params={{ businessId }}
              search={{
                operationType: "vibe modeling of version",
              }}
            >
              <Plus className="h-4 w-4 mr-1" />
              New Version
            </Link>
          </Button>
        </div>
      </div>
      <div data-testid="versions-list" className="grid gap-3 max-h-[22rem] overflow-y-auto">
        {/* Sort: version desc, scope asc — keeps the ECM/MVM siblings at the
            same version number adjacent (ecm < mvm alphabetically). */}
        {[...versions]
          .sort((a, b) => {
            if (b.version !== a.version) return b.version - a.version;
            return ((a as any).scope || "").localeCompare((b as any).scope || "");
          })
          .map((v) => {
            const scope = (v as any).scope || "mvm";
            return (
              <Link
                key={v.id}
                to="/businesses/$businessId/model/$version/$scope"
                params={{ businessId, version: String(v.version), scope }}
                search={{ tab: "overview" }}
                className="block"
                data-testid={`version-row-${v.version}-${scope}`}
              >
                <Card className="hover:bg-accent/50 transition-colors cursor-pointer">
                  <CardContent className="flex items-start gap-4 py-4">
                    <div className="pt-0.5">
                      {statusIcon[v.status] || statusIcon.draft}
                    </div>
                    <div className="flex-1 min-w-0">
                      <div className="flex items-center gap-2">
                        <span className="font-semibold">v{v.version}</span>
                        {(v as any).scope && (
                          <Badge className={(v as any).scope === "ecm" ? "bg-muted text-foreground border-border" : "bg-info/10 text-info border-info/30"} variant="outline">
                            {(v as any).scope.toUpperCase()}
                          </Badge>
                        )}
                        <Badge variant={v.is_base ? "default" : "secondary"}>
                          {versionBrandLabel(v)}
                        </Badge>
                        <Badge variant="outline">{v.status}</Badge>
                        {(() => {
                          const row = lifecycleRows.find((r) => r.id === v.id);
                          return row ? <VersionLifecycleBadges version={row} versions={lifecycleRows} /> : null;
                        })()}
                        {v.confidence_score != null && (
                          <Badge variant="outline">
                            {Math.round(v.confidence_score * 100)}% confidence
                          </Badge>
                        )}
                      </div>
                      {!v.is_base && v.vibe_instructions && (
                        <div className="mt-2 text-sm text-muted-foreground flex items-start gap-1.5">
                          <Sparkles className="h-3.5 w-3.5 mt-0.5 shrink-0" />
                          <span className="line-clamp-2">
                            {stripVibeMarkers(v.vibe_instructions)}
                          </span>
                        </div>
                      )}
                      <div className="mt-1 text-xs text-muted-foreground">
                        Created {formatDate(v.created_at)}
                      </div>
                    </div>
                  </CardContent>
                </Card>
              </Link>
            );
          })}
      </div>
    </div>
  );
}

function PageSkeleton() {
  return (
    <div className="space-y-6">
      <Skeleton className="h-8 w-64" />
      <Skeleton className="h-48 w-full" />
      <Skeleton className="h-32 w-full" />
    </div>
  );
}

function SectionSkeleton() {
  return <Skeleton className="h-48 w-full" />;
}
