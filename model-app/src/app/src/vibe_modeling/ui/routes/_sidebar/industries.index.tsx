import { createFileRoute, Link } from "@tanstack/react-router";
import { Suspense, useState } from "react";
import {
  useListBusinessesSuspense,
  useDeleteBusiness,
  useListSectorsSuspense,
  BusinessKind,
} from "@/lib/api";
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
import { AlertTriangle, Download, Factory, Plus, Trash2 } from "lucide-react";
import { FirstRunGate } from "@/routes/_sidebar/businesses.index";
import { SourceExplorerDialog } from "@/components/source-explorer/source-explorer-dialog";

export const Route = createFileRoute("/_sidebar/industries/")({
  component: IndustriesIndexPage,
});

export function IndustriesIndexPage() {
  const [explorerOpen, setExplorerOpen] = useState(false);

  return (
    <div className="p-6 space-y-6">
      <FirstRunGate />
      <div className="flex items-center justify-between">
        <h1 className="text-2xl font-semibold tracking-tight">Industries</h1>
        <div className="flex items-center gap-2">
          {/* The source explorer is hosted in a dialog (not a standalone
              route): the user browses + picks a model, and the download dialog
              opens stacked with a real selection. */}
          <Button variant="outline" onClick={() => setExplorerOpen(true)}>
            <Download className="h-4 w-4 mr-2" />
            Download from source
          </Button>
          <Button asChild>
            <Link to="/industries/new">
              <Plus className="h-4 w-4 mr-2" />
              New Industry
            </Link>
          </Button>
        </div>
      </div>
      <SourceExplorerDialog open={explorerOpen} onOpenChange={setExplorerOpen} />
      <p className="text-sm text-muted-foreground max-w-3xl">
        Industries are reusable model templates. Each one shares the full
        modelling pipeline with a business, and businesses can be kickstarted
        from an industry's model.
      </p>
      <Suspense fallback={<IndustryTableSkeleton />}>
        <IndustryTable />
      </Suspense>
    </div>
  );
}

export function IndustryTable() {
  // Industries are ``businesses`` rows with kind='industry' (ADR D-046); they
  // share the id space and the /businesses/$businessId/* explorer routes.
  const { data: industries } = useListBusinessesSuspense({
    params: { kind: BusinessKind.industry },
    ...selector(),
  });
  const { data: sectors } = useListSectorsSuspense(selector());
  const { mutateAsync: deleteBiz } = useDeleteBusiness();
  const queryClient = useQueryClient();
  const { sorted, sortKey, sortDir, toggle } = useTableSort({
    rows: industries,
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
    notifyBusinessDeleted(res.data, BusinessKind.industry, name);
  };

  if (industries.length === 0) {
    return (
      <Card>
        <CardContent className="flex flex-col items-center justify-center py-12">
          <Factory className="h-12 w-12 text-muted-foreground mb-4" />
          <p className="text-muted-foreground">No industries yet</p>
          <Button className="mt-4" asChild>
            <Link to="/industries/new">Create your first industry</Link>
          </Button>
        </CardContent>
      </Card>
    );
  }

  return (
    <Card>
      <CardHeader>
        <CardTitle>All Industries</CardTitle>
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
                  <DeleteIndustryButton
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

function DeleteIndustryButton({
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
        title="Delete industry"
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
                    , plus all attached runs, feedback, artifacts, and contexts.
                    This cannot be undone. {APP_FOLDERS_DELETE_NOTE}
                  </span>
                </div>
              </AlertDialogDescription>
            ) : (
              <AlertDialogDescription>
                Any runs, feedback, artifacts, and contexts attached to it are
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

function IndustryTableSkeleton() {
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
