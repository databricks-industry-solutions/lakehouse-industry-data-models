import { createFileRoute, Link } from "@tanstack/react-router";
import { Suspense, useState } from "react";
import { useListBusinessesSuspense, useDeleteBusiness, useGetAgentConfig, useListSectorsSuspense, BusinessKind } from "@/lib/api";
import { APP_FOLDERS_DELETE_NOTE, notifyBusinessDeleted, notifyDeleteFailed } from "@/lib/delete-outcome";
import { invalidateEntityLists } from "@/lib/delete-invalidation";
import { selector } from "@/lib/selector";
import { formatDate } from "@/lib/date";
import { sectorDisplayName } from "@/lib/sector";
import { useQueryClient } from "@tanstack/react-query";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import {
  SortableTableHead,
  useTableSort,
} from "@/components/ui/sortable-table-head";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Skeleton } from "@/components/ui/skeleton";
import {
  AlertDialog,
  AlertDialogAction,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
} from "@/components/ui/alert-dialog";
import { AlertTriangle, Building2, FileUp, Plus, Settings, Trash2 } from "lucide-react";
import { ImportNewBusinessDialog } from "@/components/import/import-new-business-dialog";
import { OobBanner } from "@/components/oob/oob-banner";

export const Route = createFileRoute("/_sidebar/businesses/")({
  component: () => (
    <div className="p-6 space-y-6">
      <FirstRunGate />
      <div className="flex items-center justify-between">
        <h1 className="text-2xl font-semibold tracking-tight">Businesses</h1>
        <div className="flex items-center gap-2">
          <ImportNewBusinessDialog
            trigger={
              <Button variant="outline">
                <FileUp className="h-4 w-4 mr-2" />
                Import pre-vibed model
              </Button>
            }
          />
          <Button asChild>
            <Link to="/businesses/new">
              <Plus className="h-4 w-4 mr-2" />
              New Business
            </Link>
          </Button>
        </div>
      </div>
      <OobBanner />
      <Suspense fallback={<BusinessTableSkeleton />}>
        <BusinessTable />
      </Suspense>
    </div>
  ),
});

/**
 * First-run gate: on a fresh install, the agent notebook isn't configured
 * yet — nothing the user does from the businesses list will actually run.
 * Nudge them to Settings.
 */
export function FirstRunGate() {
  const { data: config, isError, isLoading } = useGetAgentConfig({
    query: {
      select: (res: { data: { notebook_path: string } }) => res.data,
      // A 404 is expected on fresh installs — suppress retries so the gate
      // shows immediately instead of after retry backoff.
      retry: false,
    },
  });

  // While the initial fetch is in flight, don't flash anything
  if (isLoading) return null;

  // Config exists AND is configured → no gate needed
  if (!isError && config && config.notebook_path) return null;

  return (
    <Card className="border-warning/40 bg-warning/5">
      <CardContent className="py-4">
        <div className="flex items-start gap-3">
          <Settings className="h-5 w-5 mt-0.5 text-warning" />
          <div className="flex-1 space-y-1.5">
            <p className="text-sm font-medium">Finish setup before creating a business</p>
            <p className="text-xs text-muted-foreground">
              The vibe modelling agent notebook path isn't configured yet. Without it,
              no run you start from this app can actually execute. Open Settings and
              point the agent at the <code className="text-[11px] bg-muted px-1 rounded">vibe-modelling-agent</code> notebook you imported into this workspace.
            </p>
            <Button size="sm" variant="outline" className="mt-2" asChild>
              <Link to="/settings" search={{ tab: "agent" }}>Open Settings</Link>
            </Button>
          </div>
        </div>
      </CardContent>
    </Card>
  );
}

export function BusinessTable() {
  // Filter to plain businesses; industries (kind='industry') have their own
  // list at /industries and must not appear here (ADR D-046).
  const { data: businesses } = useListBusinessesSuspense({
    params: { kind: BusinessKind.business },
    ...selector(),
  });
  const { data: sectors } = useListSectorsSuspense(selector());
  const { mutateAsync: deleteBiz } = useDeleteBusiness();
  const queryClient = useQueryClient();
  const { sorted, sortKey, sortDir, toggle } = useTableSort({
    rows: businesses,
    initialKey: "name",
    initialDir: "asc",
    accessors: {
      name: (r: any) => r.name,
      sector_id: (r: any) => sectorDisplayName(r.sector_id, sectors) ?? "",
      model_count: (r: any) => r.model_count ?? 0,
      created_at: (r: any) => new Date(r.created_at),
    },
  });

  // Always cascade, like the Explorer: the backend refuses a bare delete of a
  // row that has runs but no versions, and a confirmed delete removes them all.
  const runDelete = async (id: string, name: string) => {
    let res;
    try {
      res = await deleteBiz({ params: { business_id: id, cascade: true } });
    } catch (err) {
      if (notifyDeleteFailed(err, { title: "Delete failed" })) {
        await invalidateEntityLists(queryClient, "business");
      }
      return;
    }
    await invalidateEntityLists(queryClient, "business");
    notifyBusinessDeleted(res.data, BusinessKind.business, name);
  };

  if (businesses.length === 0) {
    return (
      <Card>
        <CardContent className="flex flex-col items-center justify-center py-12">
          <Building2 className="h-12 w-12 text-muted-foreground mb-4" />
          <p className="text-muted-foreground">No businesses yet</p>
          <Button className="mt-4" asChild>
            <Link to="/businesses/new">Create your first business</Link>
          </Button>
        </CardContent>
      </Card>
    );
  }

  return (
    <Card>
      <CardHeader>
        <CardTitle>All Businesses</CardTitle>
      </CardHeader>
      <CardContent>
        <Table>
          <TableHeader>
            <TableRow>
              <SortableTableHead columnKey="name" sortKey={sortKey} sortDir={sortDir} onToggle={toggle}>Name</SortableTableHead>
              <SortableTableHead columnKey="sector_id" sortKey={sortKey} sortDir={sortDir} onToggle={toggle}>Sector</SortableTableHead>
              <SortableTableHead columnKey="model_count" sortKey={sortKey} sortDir={sortDir} onToggle={toggle} className="text-center">Models</SortableTableHead>
              <SortableTableHead columnKey="created_at" sortKey={sortKey} sortDir={sortDir} onToggle={toggle}>Created</SortableTableHead>
              <TableHead className="w-10" />
            </TableRow>
          </TableHeader>
          <TableBody>
            {sorted.map((b) => (
              <TableRow key={b.id}>
                <TableCell>
                  <Link
                    to="/businesses/$businessId"
                    params={{ businessId: b.id }}
                    className="font-medium hover:underline"
                  >
                    {b.name}
                  </Link>
                </TableCell>
                <TableCell>
                  {sectorDisplayName(b.sector_id, sectors) ? (
                    <Badge variant="secondary">{sectorDisplayName(b.sector_id, sectors)}</Badge>
                  ) : (
                    <span className="text-muted-foreground">—</span>
                  )}
                </TableCell>
                <TableCell className="text-center">
                  {(b.model_count ?? 0) > 0 ? (
                    <Badge variant="outline">{b.model_count}</Badge>
                  ) : (
                    <span className="text-muted-foreground">0</span>
                  )}
                </TableCell>
                <TableCell className="text-muted-foreground">
                  {formatDate(b.created_at)}
                </TableCell>
                <TableCell>
                  <DeleteBusinessButton
                    id={b.id}
                    name={b.name}
                    modelCount={b.model_count ?? 0}
                    runDelete={runDelete}
                  />
                </TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </CardContent>
    </Card>
  );
}

function DeleteBusinessButton({
  id,
  name,
  modelCount,
  runDelete,
}: {
  id: string;
  name: string;
  modelCount: number;
  runDelete: (id: string, name: string) => Promise<void>;
}) {
  const [open, setOpen] = useState(false);
  const hasModels = modelCount > 0;
  const versionWord = modelCount === 1 ? "model version" : "model versions";

  return (
    <>
      <Button
        variant="ghost"
        size="icon"
        className="h-7 w-7 text-muted-foreground hover:text-destructive"
        onClick={() => setOpen(true)}
        title="Delete business"
      >
        <Trash2 className="h-3.5 w-3.5" />
      </Button>

      <AlertDialog open={open} onOpenChange={setOpen}>
        <AlertDialogContent>
          <AlertDialogHeader>
            <AlertDialogTitle>Delete "{name}"?</AlertDialogTitle>
            {hasModels ? (
              <AlertDialogDescription asChild>
                <div className="rounded-md border border-destructive/50 bg-destructive/10 p-3 text-sm flex items-start gap-2">
                  <AlertTriangle className="h-4 w-4 mt-0.5 text-destructive shrink-0" />
                  <span>
                    This will permanently delete{" "}
                    <strong>
                      {modelCount} {versionWord}
                    </strong>
                    , plus all attached runs, feedback, artifacts, and business
                    contexts. This cannot be undone. {APP_FOLDERS_DELETE_NOTE}
                  </span>
                </div>
              </AlertDialogDescription>
            ) : (
              <AlertDialogDescription>
                Any runs, feedback, artifacts, and business contexts attached to it are
                deleted too. This cannot be undone.
              </AlertDialogDescription>
            )}
          </AlertDialogHeader>
          <AlertDialogFooter>
            <AlertDialogCancel>Cancel</AlertDialogCancel>
            <AlertDialogAction
              onClick={() => runDelete(id, name)}
              className="bg-destructive text-destructive-foreground hover:bg-destructive/90"
            >
              {hasModels ? "Delete everything" : "Delete"}
            </AlertDialogAction>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>
    </>
  );
}

function BusinessTableSkeleton() {
  return (
    <Card>
      <CardHeader>
        <Skeleton className="h-6 w-32" />
      </CardHeader>
      <CardContent className="space-y-3">
        {[...Array(3)].map((_, i) => (
          <Skeleton key={i} className="h-12 w-full" />
        ))}
      </CardContent>
    </Card>
  );
}
