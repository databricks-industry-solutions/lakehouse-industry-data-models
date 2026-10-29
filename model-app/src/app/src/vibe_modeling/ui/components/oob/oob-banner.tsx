import { Link } from "@tanstack/react-router";
import { useQueryClient } from "@tanstack/react-query";
import { FileUp, RefreshCw } from "lucide-react";
import { toast } from "sonner";
import {
  getOobSummaryKey,
  getUserPreferencesKey,
  setUserPreference,
  useCheckOobNow,
  useGetOobSummary,
  useGetUserPreferences,
  useImportOobNewBusinesses,
  useImportOobVersionsForBusiness,
  useListBusinesses,
  type BusinessListOut,
  type OobBusinessOut,
  type OobImportOut,
  type OobSummaryOut,
  type OobVersionOut,
  type UserPreferenceOut,
} from "@/lib/api";
import { formatRelative } from "@/lib/date";
import { invalidateEntityLists } from "@/lib/delete-invalidation";
import { useUserRole, type AppRole, isBusinessAdmin } from "@/lib/hooks";
import { notifyError, notifyWarnings } from "@/lib/notify";
import selector from "@/lib/selector";
import { versionScopeLabel } from "@/lib/version-label";
import { Alert, AlertDescription, AlertTitle } from "@/components/ui/alert";
import { Button } from "@/components/ui/button";

/** While a background check runs, the summary is refetched this often. */
export const OOB_CHECKING_POLL_MS = 3000;

const DISMISS_PREFIX = "oob_dismissed:";

/** The `UserPreference` key that records a dismissal: the business id, or the
 *  agent segment for a version set with no business yet. */
export function oobDismissKey(entry: OobBusinessOut): string {
  return entry.business_id
    ? `${DISMISS_PREFIX}${entry.business_id}`
    : `${DISMISS_PREFIX}segment:${entry.business_segment}`;
}

/** Every `version:scope` of an entry, sorted and joined. A dismissal holds
 *  it, so any version that was not there when it was dismissed shows the
 *  banner again. */
export function oobFingerprint(entry: OobBusinessOut): string {
  return [...(entry.versions ?? [])]
    .sort((a, b) => a.version - b.version || a.scope.localeCompare(b.scope))
    .map((v) => `${v.version}:${v.scope}`)
    .join(",");
}

/** Versions the app would import: those without a refusal reason. */
export function importable(entry: OobBusinessOut): OobVersionOut[] {
  return (entry.versions ?? []).filter((v) => !v.refused_reason);
}

/** Entries the user has not dismissed at their current newest version. */
export function undismissed(
  entries: OobBusinessOut[],
  prefs: UserPreferenceOut[] | undefined,
): OobBusinessOut[] {
  const values = new Map((prefs ?? []).map((p) => [p.key, p.value]));
  return entries.filter((e) => values.get(oobDismissKey(e)) !== oobFingerprint(e));
}

/** Entries shown on one business page: its own versions, and a segment it
 *  shares with other businesses (import is refused there). */
export function entriesForBusiness(
  entries: OobBusinessOut[],
  businessId: string,
): OobBusinessOut[] {
  return entries.filter((e) =>
    e.status === "ambiguous"
      ? (e.candidate_business_ids ?? []).includes(businessId)
      : e.business_id === businessId,
  );
}

export function versionCount(entries: OobBusinessOut[]): number {
  return entries.reduce((n, e) => n + (e.versions?.length ?? 0), 0);
}

/** The summary is asked for once the role is known and is not Viewer, so a
 *  Viewer never sends the request the server would refuse. With roles off
 *  every caller resolves to `app_admin`. */
function canModel(role: AppRole | undefined): boolean {
  return role !== undefined && role !== "viewer";
}

function canCreateBusinesses(role: AppRole | undefined): boolean {
  return isBusinessAdmin(role);
}

function VersionList({ entry }: { entry: OobBusinessOut }) {
  return (
    <ul className="w-full space-y-0.5" data-testid="oob-versions">
      {(entry.versions ?? []).map((v) => (
        <li key={`${v.version}:${v.scope}`}>
          <span className="font-medium">{versionScopeLabel(v.version, v.scope)}</span>
          {v.refused_reason && (
            <span className="text-muted-foreground"> - not importable: {v.refused_reason}</span>
          )}
        </li>
      ))}
    </ul>
  );
}

function lastCheckedText(summary: OobSummaryOut | undefined): string {
  if (summary?.checking) return "Checking now";
  if (summary?.skipped_reason === "check_failed") return "The last check failed";
  if (!summary?.checked_at) {
    return summary?.skipped_reason === "warehouse_not_running"
      ? "Not checked: the SQL warehouse is stopped"
      : "Not checked yet";
  }
  return `Last checked ${formatRelative(summary.checked_at)}`;
}

/** The summary query and the "Check now" action, shared by both banner modes. */
function useOobSummary(enabled: boolean) {
  const queryClient = useQueryClient();
  const { data: summary } = useGetOobSummary({
    query: {
      enabled,
      retry: false,
      staleTime: 30_000,
      refetchInterval: (query) =>
        query.state.data?.data.checking ? OOB_CHECKING_POLL_MS : false,
      ...selector<OobSummaryOut>().query,
    },
  });
  const checkNow = useCheckOobNow({
    mutation: {
      onSuccess: (res) => queryClient.setQueryData(getOobSummaryKey(), res),
      onError: (err) => notifyError(err, { title: "Check failed" }),
    },
  });
  return { summary, checkNow };
}

function CheckLine({
  summary,
  onCheck,
  pending,
}: {
  summary: OobSummaryOut | undefined;
  onCheck: () => void;
  pending: boolean;
}) {
  return (
    <p className="text-xs text-muted-foreground" data-testid="oob-last-checked">
      {lastCheckedText(summary)} ·{" "}
      <Button
        variant="link"
        size="sm"
        className="h-auto p-0 text-xs"
        onClick={onCheck}
        disabled={pending || summary?.checking}
        title="Checks the agent's model registry now. This may start the SQL warehouse."
      >
        <RefreshCw className="mr-1 h-3 w-3" />
        Check now
      </Button>{" "}
      <span>(may start the SQL warehouse)</span>
    </p>
  );
}

function useDismiss() {
  const queryClient = useQueryClient();
  return async (entries: OobBusinessOut[]) => {
    try {
      await Promise.all(
        entries.map((e) => setUserPreference({ key: oobDismissKey(e) }, { value: oobFingerprint(e) })),
      );
    } catch (err) {
      notifyError(err, { title: "Dismiss failed" });
    }
    await queryClient.invalidateQueries({ queryKey: getUserPreferencesKey() });
  };
}

function importedToast(res: OobImportOut) {
  const n = res.imported_versions ?? 0;
  const title = `Imported ${n} version${n === 1 ? "" : "s"}`;
  if (!notifyWarnings(title, res.warnings)) toast.success(title);
}

/**
 * Versions the agent wrote outside the app (a hand-started job run), with
 * Import and Dismiss. With `businessId` it is the business page strip (that
 * business's versions only); without, the businesses list card (every
 * segment, plus the "Last checked · Check now" line even when nothing was
 * found). Hidden for Viewers. A page load never starts the SQL warehouse;
 * "Check now" may.
 */
export function OobBanner({ businessId }: { businessId?: string }) {
  const role = useUserRole();
  const enabled = canModel(role);
  const queryClient = useQueryClient();
  const { summary, checkNow } = useOobSummary(enabled);
  const { data: prefs } = useGetUserPreferences({
    query: { enabled, ...selector<UserPreferenceOut[]>().query },
  });
  const { data: businesses } = useListBusinesses({
    query: { enabled: enabled && !businessId, ...selector<BusinessListOut[]>().query },
  });
  const dismiss = useDismiss();

  const refreshAfterImport = async (res: { data: OobImportOut }, scope: { businessId?: string }) => {
    importedToast(res.data);
    await Promise.all([
      queryClient.invalidateQueries({ queryKey: getOobSummaryKey() }),
      scope.businessId
        ? invalidateEntityLists(queryClient, "version", { businessId: scope.businessId })
        : invalidateEntityLists(queryClient, "business"),
    ]);
  };
  const importForBusiness = useImportOobVersionsForBusiness({
    mutation: {
      onSuccess: (res, vars) => refreshAfterImport(res, { businessId: vars.params.business_id }),
      onError: (err) => notifyError(err, { title: "Import failed" }),
    },
  });
  const importNew = useImportOobNewBusinesses({
    mutation: {
      onSuccess: (res) => refreshAfterImport(res, {}),
      onError: (err) => notifyError(err, { title: "Import failed" }),
    },
  });

  if (!enabled || !summary) return null;

  const all = undismissed(summary.businesses ?? [], prefs);
  const shown = businessId ? entriesForBusiness(all, businessId) : all;
  const check = () => checkNow.mutate({ params: {} });
  const busy = importForBusiness.isPending || importNew.isPending;

  if (shown.length === 0) {
    if (businessId) return null;
    return <CheckLine summary={summary} onCheck={check} pending={checkNow.isPending} />;
  }

  const importButton = (e: OobBusinessOut) =>
    e.status === "existing" && e.business_id ? (
      <Button
        key={`import-${e.business_segment}`}
        size="sm"
        variant="outline"
        className="h-7"
        disabled={busy || importable(e).length === 0}
        onClick={() => importForBusiness.mutate({ params: { business_id: e.business_id! } })}
      >
        Import
      </Button>
    ) : null;

  const n = versionCount(shown);
  const names = new Map((businesses ?? []).map((b) => [b.id, b.name]));
  const newEntries = shown.filter((e) => e.status === "new");
  const newImportable = newEntries.some((e) => importable(e).length > 0);

  return (
    <Alert
      className={businessId ? "rounded-none border-x-0 border-t-0" : undefined}
      data-testid="oob-banner"
    >
      <FileUp className="h-4 w-4" />
      <AlertTitle>
        Detected {n} model version{n === 1 ? "" : "s"} created outside this app
      </AlertTitle>
      <AlertDescription className="space-y-2">
        <ul className="space-y-2">
          {shown.map((e) => (
            <li key={e.business_segment} className="space-y-0.5">
              {(!businessId || e.status !== "existing") && (
                <div className="flex flex-wrap items-center gap-x-2 gap-y-1">
                  {!businessId && e.business_id ? (
                    <Link
                      to="/businesses/$businessId"
                      params={{ businessId: e.business_id }}
                      className="font-medium underline underline-offset-2"
                    >
                      {names.get(e.business_id) ?? e.business_segment}
                    </Link>
                  ) : !businessId ? (
                    <span className="font-medium">{e.business_segment}</span>
                  ) : null}
                  {e.status === "new" && <span className="text-muted-foreground">(new business)</span>}
                  {e.status === "ambiguous" && (
                    <span className="text-muted-foreground">
                      Several businesses share this name in the agent's registry. Rename one to import.
                    </span>
                  )}
                  {!businessId && importButton(e)}
                </div>
              )}
              <VersionList entry={e} />
            </li>
          ))}
        </ul>
        <div className="flex flex-wrap items-center gap-2">
          {businessId && shown.map((e) => importButton(e))}
          {newEntries.length > 0 && canCreateBusinesses(role) && (
            <Button size="sm" disabled={busy || !newImportable} onClick={() => importNew.mutate({ params: {} })}>
              Import as new businesses
            </Button>
          )}
          <Button size="sm" variant="ghost" onClick={() => void dismiss(shown)}>
            Dismiss
          </Button>
        </div>
        <CheckLine summary={summary} onCheck={check} pending={checkNow.isPending} />
      </AlertDescription>
    </Alert>
  );
}
