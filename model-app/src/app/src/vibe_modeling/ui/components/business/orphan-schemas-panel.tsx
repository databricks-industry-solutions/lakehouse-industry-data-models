/**
 * The business edit page's "Orphan schemas" panel (Deployment section, app
 * admins only, like `listOrphanSchemas` / `dropOrphanSchemas`).
 *
 * The admin names a catalog (empty = the metamodel catalog) and checks it.
 * The list shows the business's schemas there that no installed version uses,
 * each with its table count, whether its name was inferred from the agent's
 * registry, and its owner; only schemas the app owns and the server does not
 * block (`blocked_reason`: a version made outside the app) can be selected. "Drop
 * selected" opens a dialog that loads the impact of exactly that selection
 * (`listOrphanSchemas` with `schemas`) and renders it with the uninstall
 * impact component, which asks for the typed catalog name when a table holds
 * data or could not be checked. The drop sends the server's confirm subject;
 * a `needs_confirmation` answer replaces the impact with the server's.
 */
import { useState } from "react";
import { useQueryClient } from "@tanstack/react-query";
import { Database, RefreshCw, Search, Trash2 } from "lucide-react";
import {
  ApiError,
  dropOrphanSchemas,
  listOrphanSchemasKey,
  useListOrphanSchemas,
  type BusinessKind,
  type OrphanSchemaOut,
  type UninstallImpactOut,
} from "@/lib/api";
import { apiErrorMessage, parseNeedsConfirmation } from "@/lib/api-error";
import { useUserRole } from "@/lib/hooks";
import {
  countUnfinishedCleanups,
  isLostDeleteAnswer,
  notifyCleanupOutcome,
  retryCleanupInExplorer,
} from "@/lib/delete-outcome";
import { invalidateMetamodelCleanups } from "@/lib/delete-invalidation";
import { notifyError } from "@/lib/notify";
import {
  UninstallImpactSummary,
  type UninstallImpactConfirmState,
} from "@/components/runs/uninstall-impact-confirm";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Checkbox } from "@/components/ui/checkbox";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import { Input } from "@/components/ui/input";
import { Skeleton } from "@/components/ui/skeleton";

const QUERY_OPTIONS = { retry: false, staleTime: 60_000, refetchOnWindowFocus: false } as const;

function tablesLabel(n: number | null | undefined): string {
  if (n == null) return "tables not counted";
  return `${n} ${n === 1 ? "table" : "tables"}`;
}

function SchemaRow({
  schema,
  checked,
  onToggle,
}: {
  schema: OrphanSchemaOut;
  checked: boolean;
  onToggle: (next: boolean) => void;
}) {
  const id = `orphan-${schema.name}`;
  const owned = schema.owned_by_app === true;
  const blocked = schema.blocked_reason ?? null;
  return (
    <li className="flex items-start gap-2" data-testid="orphan-schema-row" data-owned={owned ? "true" : "false"}>
      <Checkbox
        id={id}
        checked={checked}
        disabled={!owned || !!blocked}
        onCheckedChange={(v) => onToggle(v === true)}
        aria-label={`Select ${schema.name}`}
        className="mt-0.5"
      />
      <label htmlFor={id} className="space-y-0.5 text-sm">
        <span className="flex flex-wrap items-center gap-2">
          <Database className="h-3.5 w-3.5 text-muted-foreground" aria-hidden />
          <span className="font-mono font-medium">{schema.name}</span>
          <span className="text-muted-foreground">{tablesLabel(schema.table_count)}</span>
          {schema.match === "inferred" && (
            <Badge variant="outline" data-testid="orphan-schema-inferred">
              inferred name
            </Badge>
          )}
        </span>
        {schema.match === "inferred" && (
          <span className="block text-xs text-muted-foreground">
            The registry no longer says which prefix this schema was installed with; the
            name was rebuilt with the default one.
          </span>
        )}
        {blocked && (
          <span className="block text-xs text-muted-foreground" data-testid="orphan-schema-blocked">
            {blocked}
          </span>
        )}
        {!owned && (
          <span className="block text-xs text-muted-foreground" data-testid="orphan-schema-not-owned">
            Not owned by this app{schema.owner ? ` (owner: ${schema.owner})` : ""}. The app does
            not drop it; its owner can.
          </span>
        )}
      </label>
    </li>
  );
}

function DropDialog({
  businessId,
  businessKind,
  catalog,
  names,
  open,
  onOpenChange,
  onDropped,
}: {
  businessId: string;
  businessKind?: BusinessKind | null;
  catalog: string;
  names: string[];
  open: boolean;
  onOpenChange: (open: boolean) => void;
  onDropped: () => void;
}) {
  const query = useListOrphanSchemas({
    params: { business_id: businessId, catalog, schemas: names },
    query: { ...QUERY_OPTIONS, enabled: open && names.length > 0 },
  });
  const [serverImpact, setServerImpact] = useState<{ impact: UninstallImpactOut; subject: string } | null>(null);
  const [confirm, setConfirm] = useState<UninstallImpactConfirmState | null>(null);
  const [dropping, setDropping] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const impact = serverImpact?.impact ?? query.data?.data.impact ?? null;
  const subject = serverImpact ? serverImpact.subject : (query.data?.data.confirm_subject ?? null);
  const canDrop = !!impact && !!confirm && confirm.status === "ready" && confirm.confirmed && !dropping;

  const drop = async () => {
    setDropping(true);
    setError(null);
    try {
      const res = await dropOrphanSchemas(
        { business_id: businessId },
        { catalog, schemas: names, confirmed_issues: subject ? [subject] : [] },
      );
      const rows = res.data.schemas ?? [];
      const failed = rows.filter((r) => r.status !== "dropped");
      if (failed.length === 0) {
        notifyCleanupOutcome({
          title: `Dropped ${rows.length} ${rows.length === 1 ? "schema" : "schemas"} from ${catalog}.`,
          unfinished: countUnfinishedCleanups(res.data.metamodel_cleanup),
          retryHint: retryCleanupInExplorer(businessKind),
        });
      } else {
        notifyError(
          failed.map((r) => `${r.name}: ${r.error ?? "not dropped"}`).join("\n"),
          { title: `${failed.length} of ${rows.length} schemas were not dropped` },
        );
      }
      onDropped();
    } catch (err) {
      const needs = parseNeedsConfirmation(err);
      const detail = err instanceof ApiError ? (err.body as { detail?: { impact?: UninstallImpactOut } } | null)?.detail : null;
      if (needs && needs.issues.length > 0 && detail?.impact) {
        setServerImpact({ impact: detail.impact, subject: needs.issues[0].subject });
        setError("The check found data or could not check since the impact was loaded. Review it and confirm again.");
      } else if (!(err instanceof ApiError) || isLostDeleteAnswer(err)) {
        setError(
          "The answer did not arrive. The drop may still be running: open the business's runs to see its outcome before you try again.",
        );
      } else {
        setError(apiErrorMessage(err, "The drop failed."));
      }
    } finally {
      setDropping(false);
    }
  };

  return (
    <Dialog open={open} onOpenChange={(next) => { if (!dropping) onOpenChange(next); }}>
      <DialogContent className="max-h-[90vh] max-w-2xl overflow-y-auto" data-testid="orphan-drop-dialog">
        <DialogHeader>
          <DialogTitle>Drop orphan schemas</DialogTitle>
          <DialogDescription>
            Drops {names.length === 1 ? "this schema" : `these ${names.length} schemas`} from{" "}
            <span className="font-mono">{catalog}</span> with every table, view and volume in{" "}
            {names.length === 1 ? "it" : "them"}. No model version uses{" "}
            {names.length === 1 ? "it" : "them"}. This cannot be undone.
          </DialogDescription>
        </DialogHeader>
        {query.isPending && !serverImpact ? (
          <div className="space-y-2" aria-busy="true" data-testid="orphan-drop-loading">
            <p className="text-sm text-muted-foreground">Checking what the drop deletes...</p>
            <Skeleton className="h-16 w-full" />
          </div>
        ) : query.isError && !serverImpact ? (
          <div role="alert" className="space-y-2 text-sm" data-testid="orphan-drop-check-error">
            <p className="text-destructive">{apiErrorMessage(query.error, "The check failed.")}</p>
            <Button type="button" variant="outline" size="sm" onClick={() => void query.refetch()}>
              <RefreshCw className="mr-1.5 h-3.5 w-3.5" aria-hidden />
              Check again
            </Button>
          </div>
        ) : impact ? (
          <UninstallImpactSummary
            key={serverImpact ? `server:${serverImpact.subject}` : "listed"}
            impact={impact}
            action="drop"
            onStateChange={setConfirm}
          />
        ) : null}
        {error && (
          <p role="alert" className="text-sm text-destructive" data-testid="orphan-drop-error">
            {error}
          </p>
        )}
        <DialogFooter>
          <Button variant="outline" disabled={dropping} onClick={() => onOpenChange(false)}>
            Cancel
          </Button>
          <Button
            variant="destructive"
            disabled={!canDrop}
            onClick={() => void drop()}
            data-testid="orphan-drop-confirm"
          >
            <Trash2 className="mr-1.5 h-4 w-4" aria-hidden />
            {dropping ? "Dropping..." : `Drop ${names.length === 1 ? "schema" : `${names.length} schemas`}`}
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
}

function PanelBody({ businessId, businessKind }: { businessId: string; businessKind?: BusinessKind | null }) {
  const queryClient = useQueryClient();
  const [catalogInput, setCatalogInput] = useState("");
  const [checkedCatalog, setCheckedCatalog] = useState<string | null>(null);
  const [selected, setSelected] = useState<Set<string>>(new Set());
  const [dialogOpen, setDialogOpen] = useState(false);

  const list = useListOrphanSchemas({
    params: { business_id: businessId, catalog: checkedCatalog || null },
    query: { ...QUERY_OPTIONS, enabled: checkedCatalog !== null },
  });
  const result = list.data?.data;
  const schemas = result?.schemas ?? [];
  const catalog = result?.catalog ?? "";
  const names = schemas.filter((s) => selected.has(s.name)).map((s) => s.name);

  const check = () => {
    setSelected(new Set());
    const next = catalogInput.trim().toLowerCase();
    if (next === checkedCatalog) void list.refetch();
    else setCheckedCatalog(next);
  };

  const toggle = (name: string, on: boolean) => {
    setSelected((prev) => {
      const next = new Set(prev);
      if (on) next.add(name);
      else next.delete(name);
      return next;
    });
  };

  const afterDrop = async () => {
    setDialogOpen(false);
    setSelected(new Set());
    await Promise.all([
      queryClient.invalidateQueries({ queryKey: listOrphanSchemasKey({ business_id: businessId }).slice(0, 1) }),
      invalidateMetamodelCleanups(queryClient, businessId),
    ]);
  };

  return (
    <div className="space-y-3" data-testid="orphan-schemas-panel">
      <div className="space-y-1">
        <h3 className="text-sm font-medium">Orphan schemas</h3>
        <p className="text-xs text-muted-foreground">
          Schemas this business left in a catalog that no installed model version uses, for
          example after a version was deleted while it was installed. The app drops only
          schemas it owns.
        </p>
      </div>
      <form
        className="flex flex-wrap items-center gap-2"
        onSubmit={(e) => {
          e.preventDefault();
          check();
        }}
      >
        <Input
          value={catalogInput}
          onChange={(e) => setCatalogInput(e.target.value)}
          placeholder="Catalog (empty = the metamodel catalog)"
          aria-label="Catalog to check"
          className="max-w-xs"
          data-testid="orphan-catalog-input"
          autoComplete="off"
          spellCheck={false}
        />
        <Button type="submit" variant="outline" size="sm" disabled={list.isFetching} data-testid="orphan-check">
          <Search className="mr-1.5 h-3.5 w-3.5" aria-hidden />
          {list.isFetching ? "Checking..." : "Check catalog"}
        </Button>
      </form>

      {checkedCatalog !== null && list.isPending && (
        <Skeleton className="h-16 w-full max-w-2xl" data-testid="orphan-loading" />
      )}
      {list.isError && (
        <p role="alert" className="text-sm text-destructive" data-testid="orphan-list-error">
          {apiErrorMessage(list.error, "The catalog could not be checked.")}
        </p>
      )}
      {result && schemas.length === 0 && (
        <p className="text-sm text-muted-foreground" data-testid="orphan-none">
          No orphan schemas of this business in <span className="font-mono">{catalog}</span>.
        </p>
      )}
      {result && schemas.length > 0 && (
        <div className="max-w-2xl space-y-3 rounded-md border px-3 py-2">
          <p className="text-sm">
            {schemas.length} orphan {schemas.length === 1 ? "schema" : "schemas"} in{" "}
            <span className="font-mono">{catalog}</span>:
          </p>
          <ul className="space-y-2">
            {schemas.map((s) => (
              <SchemaRow
                key={s.name}
                schema={s}
                checked={selected.has(s.name)}
                onToggle={(on) => toggle(s.name, on)}
              />
            ))}
          </ul>
          <Button
            type="button"
            variant="destructive"
            size="sm"
            disabled={names.length === 0}
            onClick={() => setDialogOpen(true)}
            data-testid="orphan-drop-open"
          >
            <Trash2 className="mr-1.5 h-3.5 w-3.5" aria-hidden />
            Drop selected{names.length > 0 ? ` (${names.length})` : ""}
          </Button>
        </div>
      )}

      {dialogOpen && (
        <DropDialog
          businessId={businessId}
          businessKind={businessKind}
          catalog={catalog}
          names={names}
          open={dialogOpen}
          onOpenChange={setDialogOpen}
          onDropped={() => void afterDrop()}
        />
      )}
    </div>
  );
}

/** False for a known role other than app admin (the routes are AdminOnly);
 *  an unknown role does not gate, the server refuses. */
export function useCanManageOrphanSchemas(): boolean {
  const role = useUserRole();
  return role === undefined || role === "app_admin";
}

/** Renders nothing when the caller cannot manage orphan schemas. */
export function OrphanSchemasPanel({ businessId, businessKind }: { businessId: string; businessKind?: BusinessKind | null }) {
  return useCanManageOrphanSchemas() ? <PanelBody businessId={businessId} businessKind={businessKind} /> : null;
}
