/**
 * What an uninstall destroys, and the typed confirmation it needs.
 *
 * `UninstallImpactConfirm` loads `getUninstallImpact` for a version and
 * catalog; `UninstallImpactSummary` renders an impact the caller already has
 * (`listOrphanSchemas` returns the same shape; `action="drop"` words it for
 * the orphan-schema drop and leaves out the install note). Both list the schemas, the
 * tables and which of them hold rows, views and metric views, and volumes,
 * mark the catalog's shared `_metrics` schema with the other versions installed
 * in the catalog that lose their metric views with it, say which other
 * catalogs the version is installed in (one impact per catalog), and show the
 * server's reasons for anything it could not check.
 *
 * When a table holds data, or the check could not tell (`has_data` is
 * `unknown`, or the request failed), the user must type the catalog name.
 * `requireConfirmation` asks for it whatever this impact says: the server
 * asks for the data-loss confirmation (its check found data, or could not
 * check) and the server's answer wins over a cached client one.
 * The parent disables its own confirm button until `onStateChange` reports
 * `confirmed`, and sends the server's confirm subject when
 * `needsConfirmation` is true. The component never calls a mutating API.
 */
import { useEffect, useId, useRef, useState } from "react";
import { AlertTriangle, Database, RefreshCw } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Skeleton } from "@/components/ui/skeleton";
import {
  useGetUninstallImpact,
  type UninstallImpactOut,
  type UninstallImpactSchemaOut,
  type UninstallImpactTableOut,
  type UninstallImpactVersionOut,
} from "@/lib/api";
import { apiErrorMessage } from "@/lib/api-error";

/** Names shown per list before "and N more". */
const LIST_LIMIT = 8;

export interface UninstallImpactConfirmState {
  /** `loading` while the impact is fetched; `error` when it could not be. */
  status: "loading" | "ready" | "error";
  /** Data is held or may be held: the confirm subject must be sent. */
  needsConfirmation: boolean;
  /** The parent may proceed: nothing needs confirming, or the name was typed. */
  confirmed: boolean;
}

export interface ImpactCounts {
  schemas: number;
  tables: number;
  tablesWithData: number;
  tablesUnchecked: number;
  views: number;
  volumes: number;
}

export function impactCounts(impact: UninstallImpactOut): ImpactCounts {
  const schemas = impact.schemas ?? [];
  const tables = schemas.flatMap((s) => s.tables ?? []);
  return {
    schemas: schemas.length,
    tables: tables.length,
    tablesWithData: tables.filter((t) => t.has_data === true).length,
    tablesUnchecked: tables.filter((t) => t.has_data == null).length,
    views: schemas.reduce((n, s) => n + (s.views?.length ?? 0), 0),
    volumes: schemas.reduce((n, s) => n + (s.volumes?.length ?? 0), 0),
  };
}

/** Mirrors the backend rule (`impact_needs_confirmation`): only a checked "no" is safe. */
export function impactNeedsConfirmation(impact: UninstallImpactOut | undefined): boolean {
  return (impact?.has_data ?? "unknown") !== "no";
}

function plural(n: number, one: string, many = `${one}s`): string {
  return `${n} ${n === 1 ? one : many}`;
}

/** What the confirmed action is: an uninstall, or the orphan-schema drop. */
export type ImpactAction = "uninstall" | "drop";

const ACTION_WORDS: Record<ImpactAction, { drops: string; deletes: string }> = {
  uninstall: { drops: "Uninstall drops", deletes: "Uninstall deletes" },
  drop: { drops: "The drop removes", deletes: "The drop deletes" },
};

function headline(impact: UninstallImpactOut, c: ImpactCounts, action: ImpactAction): string {
  const w = ACTION_WORDS[action];
  if (c.schemas === 0) {
    if (impact.has_data === "no") {
      return `No schemas of this version were found in ${impact.catalog}. Nothing will be dropped.`;
    }
    return impact.truncated
      ? `Could not read the schemas in ${impact.catalog}. Treat this uninstall as deleting data.`
      : `No schemas of this version were found in ${impact.catalog} under the expected names. Treat this uninstall as deleting data.`;
  }
  const onlyShared = (impact.schemas ?? []).every((s) => s.shared);
  const where = onlyShared
    ? `the shared _metrics schema in ${impact.catalog}`
    : `${plural(c.schemas, "schema")} in ${impact.catalog}`;
  if ((impact.schemas ?? []).some((s) => s.objects_listed === false)) {
    return `${w.drops} ${where}. The objects in these schemas could not be listed and may hold data.`;
  }
  if (c.tablesWithData > 0) {
    const holding =
      c.tables === 1 ? "The 1 table holds data." : `${c.tablesWithData} of ${plural(c.tables, "table")} hold data.`;
    return `${holding} ${w.deletes} ${where} with all ${c.schemas === 1 ? "its" : "their"} data.`;
  }
  if (impact.has_data === "no") {
    return c.tables === 0
      ? `${w.drops} ${where}. ${c.schemas === 1 ? "It holds" : "They hold"} no tables.`
      : `${c.tables === 1 ? "The 1 table holds no data." : `None of the ${plural(c.tables, "table")} hold data.`} ${w.drops} ${where}.`;
  }
  return `${w.drops} ${where}. Some objects could not be checked and may hold data.`;
}

/** "and N more" after the first `LIST_LIMIT` names. */
function shortList(names: string[]): string {
  const shown = names.slice(0, LIST_LIMIT);
  const rest = names.length - shown.length;
  return `${shown.join(", ")}${rest > 0 ? ` and ${rest} more` : ""}`;
}

function versionLabel(v: UninstallImpactVersionOut): string {
  return `${v.business_name} ${(v.scope || "").toUpperCase()} v${v.version}`;
}

/** Where else the version is installed, or that it is not recorded here. */
function installedNote(impact: UninstallImpactOut): string | null {
  const installed = impact.installed_catalogs;
  if (installed === undefined) return null;
  const others = installed.filter((c) => c.toLowerCase() !== impact.catalog);
  if (others.length === installed.length) {
    const elsewhere = others.length > 0 ? `; it is installed in ${shortList(others)}` : "";
    const still = (impact.schemas?.length ?? 0) > 0 ? " This uninstall still drops what is listed here." : "";
    return `The app does not record this version as installed in ${impact.catalog}${elsewhere}.${still}`;
  }
  return others.length > 0
    ? `This version is also installed in ${shortList(others)}. This uninstall leaves ${others.length === 1 ? "that catalog" : "those catalogs"} alone; only ${impact.catalog} is checked here.`
    : null;
}

function NameList({ label, names, testId }: { label: string; names: string[]; testId: string }) {
  if (names.length === 0) return null;
  return (
    <p className="text-xs text-muted-foreground" data-testid={testId}>
      <span className="font-medium text-foreground">{label}:</span> {shortList(names)}
    </p>
  );
}

/** A table name, with its kind when it is not a plain managed table. */
function tableLabel(t: UninstallImpactTableOut): string {
  const kind = (t.kind || "").toUpperCase();
  return kind && kind !== "MANAGED" ? `${t.name} (${kind.toLowerCase().replace(/_/g, " ")})` : t.name;
}

function SchemaRow({ schema }: { schema: UninstallImpactSchemaOut }) {
  const tables = schema.tables ?? [];
  const withData = tables.filter((t) => t.has_data === true).map(tableLabel);
  const unchecked = tables.filter((t) => t.has_data == null).map(tableLabel);
  const listed = schema.objects_listed !== false;
  const parts: string[] = [];
  if (!listed) {
    parts.push("objects in this schema could not be listed");
  } else {
    parts.push(plural(tables.length, "table"));
    if (withData.length > 0) parts.push(`${withData.length} with data`);
    if (unchecked.length > 0) parts.push(`${unchecked.length} not checked`);
    if ((schema.views?.length ?? 0) > 0) parts.push(plural(schema.views!.length, "view"));
    if ((schema.volumes?.length ?? 0) > 0) parts.push(plural(schema.volumes!.length, "volume"));
  }
  return (
    <li className="space-y-0.5" data-testid="uninstall-impact-schema" data-shared={schema.shared ? "true" : undefined}>
      <p className="text-sm">
        <Database className="mr-1 inline h-3.5 w-3.5 align-[-2px] text-muted-foreground" aria-hidden />
        <span className="font-mono font-medium">{schema.name}</span>
        <span className="text-muted-foreground"> - {parts.join(", ")}</span>
      </p>
      {schema.shared && (
        <p className="text-xs font-medium text-destructive" data-testid="uninstall-impact-shared">
          Shared: holds the metric views of every model in this catalog. Uninstall drops it
          for all of them.
        </p>
      )}
      {schema.shared && (schema.other_versions?.length ?? 0) > 0 && (
        <p className="text-xs text-destructive" data-testid="uninstall-impact-shared-versions">
          Installed here and losing their metric views:{" "}
          {shortList(schema.other_versions!.map(versionLabel))}.
        </p>
      )}
      {schema.owner && (
        <p className="text-xs text-muted-foreground">Owner: {schema.owner}</p>
      )}
      <NameList label="Tables with data" names={withData} testId="uninstall-impact-tables-with-data" />
      <NameList label="Not checked" names={unchecked} testId="uninstall-impact-tables-unchecked" />
      <NameList label="Views and metric views" names={schema.views ?? []} testId="uninstall-impact-views" />
      <NameList label="Volumes" names={schema.volumes ?? []} testId="uninstall-impact-volumes" />
    </li>
  );
}

function TypedConfirmation({
  catalog,
  value,
  onChange,
}: {
  catalog: string;
  value: string;
  onChange: (next: string) => void;
}) {
  const id = useId();
  return (
    <div className="space-y-1.5">
      <label htmlFor={id} className="text-sm">
        Type <span className="font-mono font-semibold">{catalog}</span> to confirm that this
        data will be deleted.
      </label>
      <Input
        id={id}
        data-testid="uninstall-impact-confirm-input"
        value={value}
        autoComplete="off"
        spellCheck={false}
        onChange={(e) => onChange(e.target.value)}
        aria-invalid={value.length > 0 && value.trim() !== catalog}
      />
    </div>
  );
}

/** A ref that always holds the latest value, so an inline callback prop does
 *  not re-run the effects that call it. */
function useLatest<T>(value: T) {
  const ref = useRef(value);
  ref.current = value;
  return ref;
}

export interface UninstallImpactSummaryProps {
  impact: UninstallImpactOut;
  onStateChange?: (state: UninstallImpactConfirmState) => void;
  /** `drop` for the orphan-schema drop: its wording, and no install note. */
  action?: ImpactAction;
}

/** Renders an impact and, when data may be lost, the typed confirmation. */
export function UninstallImpactSummary({ impact, onStateChange, action = "uninstall" }: UninstallImpactSummaryProps) {
  return <ImpactBody impact={impact} status="ready" onStateChange={onStateChange} action={action} />;
}

function ImpactBody({
  impact,
  status,
  errorText,
  onRetry,
  onStateChange,
  requireConfirmation = false,
  action = "uninstall",
}: {
  impact: UninstallImpactOut;
  status: "ready" | "error";
  errorText?: string;
  onRetry?: () => void;
  onStateChange?: (state: UninstallImpactConfirmState) => void;
  requireConfirmation?: boolean;
  action?: ImpactAction;
}) {
  const [typed, setTyped] = useState("");
  const needsConfirmation = requireConfirmation || status === "error" || impactNeedsConfirmation(impact);
  const confirmed = !needsConfirmation || typed.trim() === impact.catalog;
  const onStateChangeRef = useLatest(onStateChange);

  useEffect(() => {
    onStateChangeRef.current?.({ status, needsConfirmation, confirmed });
  }, [status, needsConfirmation, confirmed, onStateChangeRef]);

  const c = impactCounts(impact);
  const holdsData = c.tablesWithData > 0;
  const installed = status === "ready" && action === "uninstall" ? installedNote(impact) : null;
  return (
    <div className="space-y-3" data-testid="uninstall-impact" data-has-data={status === "error" ? "unknown" : impact.has_data}>
      {status === "error" ? (
        <div
          role="alert"
          className="flex items-start gap-2 rounded-md border border-destructive/40 bg-destructive/5 px-3 py-2 text-sm"
          data-testid="uninstall-impact-error"
        >
          <AlertTriangle className="mt-0.5 h-4 w-4 shrink-0 text-destructive" aria-hidden />
          <div className="space-y-1">
            <p className="font-medium text-destructive">
              Could not check what this uninstall deletes in {impact.catalog}.
            </p>
            <p>{errorText}</p>
            <p>Treat this uninstall as deleting data.</p>
            {onRetry && (
              <Button type="button" variant="outline" size="sm" onClick={onRetry}>
                <RefreshCw className="mr-1.5 h-3.5 w-3.5" aria-hidden />
                Check again
              </Button>
            )}
          </div>
        </div>
      ) : (
        <div
          role={needsConfirmation ? "alert" : "note"}
          className={
            needsConfirmation
              ? "flex items-start gap-2 rounded-md border border-destructive/40 bg-destructive/5 px-3 py-2 text-sm"
              : "flex items-start gap-2 rounded-md border px-3 py-2 text-sm"
          }
          data-testid="uninstall-impact-headline"
        >
          {needsConfirmation ? (
            <AlertTriangle className="mt-0.5 h-4 w-4 shrink-0 text-destructive" aria-hidden />
          ) : (
            <Database className="mt-0.5 h-4 w-4 shrink-0 text-muted-foreground" aria-hidden />
          )}
          <div className="space-y-1">
            <p className={holdsData ? "font-medium text-destructive" : "font-medium"}>
              {headline(impact, c, action)}
            </p>
            {(impact.reasons?.length ?? 0) > 0 && (
              <ul className="list-disc space-y-0.5 pl-4" data-testid="uninstall-impact-reasons">
                {impact.reasons!.map((r) => (
                  <li key={r}>{r}</li>
                ))}
              </ul>
            )}
            {requireConfirmation && !impactNeedsConfirmation(impact) && (
              <p data-testid="uninstall-impact-server-asks">
                The run's own check found data or could not check. Treat this uninstall as
                deleting data.
              </p>
            )}
            {impact.truncated && c.schemas > 0 && (
              <p data-testid="uninstall-impact-truncated">
                The check stopped before everything was checked. What was not checked is
                treated as holding data.
              </p>
            )}
          </div>
        </div>
      )}

      {installed && (
        <p className="text-xs text-muted-foreground" data-testid="uninstall-impact-installed">
          {installed}
        </p>
      )}

      {(impact.schemas?.length ?? 0) > 0 && (
        <ul className="max-h-56 space-y-2 overflow-y-auto pr-1">
          {impact.schemas!.map((s) => (
            <SchemaRow key={s.name} schema={s} />
          ))}
        </ul>
      )}

      {needsConfirmation && (
        <TypedConfirmation catalog={impact.catalog} value={typed} onChange={setTyped} />
      )}
    </div>
  );
}

export interface UninstallImpactConfirmProps {
  businessId: string;
  versionId: string;
  /** The catalog to uninstall from (the uninstall run's catalog). */
  catalog: string;
  /** The cataloging style the uninstall runs with. */
  catalogingStyle?: "One Catalog" | "Catalog per Division" | "Catalog per Domain";
  onStateChange?: (state: UninstallImpactConfirmState) => void;
  /** The server asks for the data-loss confirmation: the typed name is
   *  required whatever the impact says, and the impact is fetched again. */
  requireConfirmation?: boolean;
}

/** Loads the impact of uninstalling `versionId` from `catalog` and renders it. */
export function UninstallImpactConfirm({
  businessId,
  versionId,
  catalog,
  catalogingStyle,
  onStateChange,
  requireConfirmation = false,
}: UninstallImpactConfirmProps) {
  const query = useGetUninstallImpact({
    params: {
      business_id: businessId,
      version_id: versionId,
      catalog,
      cataloging_style: catalogingStyle ?? null,
    },
    query: { retry: false, staleTime: 60_000, refetchOnWindowFocus: false },
  });

  const onStateChangeRef = useLatest(onStateChange);

  // A server request for the confirmation means the client's answer may be
  // stale: read the impact again.
  const { refetch } = query;
  useEffect(() => {
    if (requireConfirmation) void refetch();
  }, [requireConfirmation, refetch]);

  useEffect(() => {
    if (query.isPending) {
      onStateChangeRef.current?.({ status: "loading", needsConfirmation: true, confirmed: false });
    }
  }, [query.isPending, onStateChangeRef]);

  if (query.isPending) {
    return (
      <div className="space-y-2" data-testid="uninstall-impact-loading" aria-busy="true">
        <p className="text-sm text-muted-foreground">
          Checking what this uninstall deletes in {catalog}...
        </p>
        <Skeleton className="h-16 w-full" />
      </div>
    );
  }
  if (query.isError) {
    return (
      <ImpactBody
        key={`error:${catalog}:${catalogingStyle ?? ""}`}
        impact={{ version_id: versionId, catalog: catalog.toLowerCase(), has_data: "unknown" }}
        status="error"
        errorText={apiErrorMessage(query.error, "The check failed.")}
        onRetry={() => void query.refetch()}
        onStateChange={onStateChange}
        requireConfirmation={requireConfirmation}
      />
    );
  }
  return (
    <ImpactBody
      key={`ready:${catalog}:${catalogingStyle ?? ""}`}
      impact={query.data.data}
      status="ready"
      onStateChange={onStateChange}
      requireConfirmation={requireConfirmation}
    />
  );
}
