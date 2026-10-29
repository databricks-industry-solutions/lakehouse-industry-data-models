/**
 * Bidirectional drift-detection dialog (#69).
 *
 * Mounted next to the model-version Overview's command strip. On mount it
 * polls `GET /api/model-versions/{id}/installation-status` and pops an
 * AlertDialog for either direction of drift between Lakebase's
 * ``deployment_status`` and the catalog:
 *
 * - **Forced case** (`in_sync === false`): Lakebase says "Installed" but
 *   the catalog is missing schemas. Non-dismissible - the user MUST act
 *   via Reconcile before continuing (except the post-error Dismiss
 *   escape hatch below).
 * - **Inverse case** (`lakebase_says_installed === false &&
 *   catalog_present === true && found_schemas.length > 0`): schemas
 *   physically exist in the catalog but Lakebase doesn't know about
 *   them. Recoverable and informational - always dismissible.
 *
 * "Reconcile" calls `POST /api/model-versions/{id}/reconcile-installation`,
 * which flips the Lakebase ``deployment_status`` to match what the
 * catalog actually has. Same action wired to both directions.
 */
import { useEffect, useState } from "react";
import { AlertCircle, CheckCircle2, RefreshCw } from "lucide-react";
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
import {
  ApiError,
  getInstallationStatus,
  reconcileInstallation,
  type InstallationStatusOut,
  type ReconcileInstallationOut,
} from "@/lib/api";
import { RequestTimeoutError, withRequestTimeout } from "@/lib/request-timeout";

// Reconcile is just `SHOW SCHEMAS` + a Lakebase row update — both
// sub-second on a healthy workspace. If we don't get an answer in 10s
// something's wrong upstream and the user should be allowed to bail.
const RECONCILE_TIMEOUT_MS = 10_000;

type InstallationStatus = InstallationStatusOut;
type ReconcileResult = ReconcileInstallationOut;

async function fetchStatus(versionId: string): Promise<InstallationStatus> {
  // Phase 7 drift-unification: route through the Orval-generated helper so
  // request shape + error envelope stay in sync with the OpenAPI spec. The
  // defensive defaults below cover older deployments where some fields
  // weren't yet on the response.
  //
  // ``in_sync`` defaults to ``null`` ("unknown"), NOT ``true``. A response
  // with the field missing entirely (very old deployments) is exactly as
  // uninformative as a skipped probe — defaulting it to "healthy" would
  // repeat the same false-positive bug a skipped probe on the current API
  // shape now avoids by sending ``in_sync: null`` explicitly.
  const resp = await getInstallationStatus({ model_version_id: versionId });
  const payload = (resp.data ?? {}) as Partial<InstallationStatus>;
  return {
    version_id: payload.version_id ?? versionId,
    deployment_catalog: payload.deployment_catalog ?? "",
    lakebase_says_installed: payload.lakebase_says_installed ?? false,
    expected_schemas: payload.expected_schemas ?? [],
    found_schemas: payload.found_schemas ?? [],
    missing_schemas: payload.missing_schemas ?? [],
    catalog_present: payload.catalog_present ?? false,
    in_sync: payload.in_sync ?? null,
    checked_at: payload.checked_at ?? new Date().toISOString(),
    skipped_reason: payload.skipped_reason ?? null,
    also_installed_in: payload.also_installed_in ?? [],
  };
}

/** The catalogs missing schemas, with how many: the install catalog for
 * the bare names, and each other install catalog for its
 * ``<catalog>.<schema>`` entries. */
export function missingByCatalog(status: InstallationStatus): [string, number][] {
  const others = status.also_installed_in ?? [];
  const counts = new Map<string, number>();
  for (const name of status.missing_schemas) {
    const other = others.find((c) => name.startsWith(`${c}.`));
    const catalog = other ?? status.deployment_catalog;
    counts.set(catalog, (counts.get(catalog) ?? 0) + 1);
  }
  return [...counts.entries()];
}

async function reconcile(versionId: string): Promise<ReconcileResult> {
  try {
    const resp = await withRequestTimeout(RECONCILE_TIMEOUT_MS, (signal) =>
      reconcileInstallation({ model_version_id: versionId }, { signal }),
    );
    return resp.data;
  } catch (e) {
    if (e instanceof RequestTimeoutError) {
      throw new Error(
        `reconcile timed out after ${RECONCILE_TIMEOUT_MS}ms — try again or dismiss`,
      );
    }
    if (e instanceof ApiError) {
      // Preserve the HTTP-status detail the prior raw-fetch path surfaced.
      const text =
        typeof e.body === "string"
          ? e.body
          : (() => {
              try {
                return JSON.stringify(e.body);
              } catch {
                return "";
              }
            })();
      throw new Error(`reconcile HTTP ${e.status}: ${text}`);
    }
    throw e;
  }
}

export function InstallationDriftDialog({
  versionId,
  enabled,
  onReconciled,
}: {
  versionId: string;
  /** Skip the probe entirely when false — e.g. version isn't 'deployed' yet. */
  enabled: boolean;
  /** Fired after a successful reconcile so the parent can refetch. */
  onReconciled?: () => void;
}) {
  const [status, setStatus] = useState<InstallationStatus | null>(null);
  const [result, setResult] = useState<ReconcileResult | null>(null);
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    if (!enabled || !versionId) return;
    let cancelled = false;
    fetchStatus(versionId)
      .then((s) => {
        if (!cancelled) setStatus(s);
      })
      .catch(() => {
        // Silent — don't pop a dialog if the probe itself fails.
      });
    return () => {
      cancelled = true;
    };
  }, [enabled, versionId]);

  // Only a CONFIRMED drift (in_sync === false) forces the reconcile
  // dialog. ``null`` means the probe was skipped (unknown state, e.g. no
  // catalog recorded yet) — treated the same as "in sync" for display
  // purposes (no forced action), but never conflated with a positive
  // "checked, and it's healthy" result.
  const forcedDrift = !!status && status.in_sync === false;

  // Inverse direction: schemas physically exist in the catalog but
  // Lakebase's deployment_status doesn't reflect it. `in_sync` will be
  // `true` or `null` for this case (it is not a confirmed-installed vs.
  // missing-schema mismatch), so it must be checked independently of
  // forcedDrift rather than folded into it. Only a COMPLETE match counts:
  // reconcile promotes to "deployed" only when nothing is missing, and a
  // partial match can be another business's bare-name schemas in a shared
  // catalog, so offering reconcile for it would loop.
  const inverseDrift =
    !!status &&
    status.lakebase_says_installed === false &&
    status.catalog_present === true &&
    status.found_schemas.length > 0 &&
    status.missing_schemas.length === 0;

  const mode: "forced" | "inverse" | null = forcedDrift
    ? "forced"
    : inverseDrift
      ? "inverse"
      : null;

  const open = mode !== null && !result;

  if (!status || mode === null) return null;

  const handleReconcile = async () => {
    setBusy(true);
    setError(null);
    try {
      const r = await reconcile(versionId);
      setResult(r);
      onReconciled?.();
    } catch (e) {
      setError(e instanceof Error ? e.message : String(e));
    } finally {
      setBusy(false);
    }
  };

  return (
    <AlertDialog open={open || !!result}>
      {/* AlertDialog is non-dismissible by default — Esc and outside
          click do nothing unless we add an AlertDialogCancel button.
          The user MUST act on Reconcile to clear the dialog. */}
      <AlertDialogContent data-testid="installation-drift-dialog">
        <AlertDialogHeader>
          <AlertDialogTitle className="flex items-center gap-2">
            <AlertCircle className="h-5 w-5 text-warning" />
            {result
              ? "Lakebase synced with catalog"
              : mode === "forced"
                ? "Catalog drift detected"
                : "Installation status out of sync"}
          </AlertDialogTitle>
          <AlertDialogDescription asChild>
            <div className="space-y-3 text-sm">
              {!result && mode === "forced" && (
                <>
                  <p>
                    Lakebase shows this version as{" "}
                    <strong>installed</strong>, but expected schemas are{" "}
                    <strong>missing</strong>:{" "}
                    {missingByCatalog(status).map(([catalog, n], i) => (
                      <span key={catalog}>
                        {i > 0 && ", "}
                        {n} of {status.expected_schemas.length} from{" "}
                        <code className="text-xs">{catalog}</code>
                      </span>
                    ))}
                    .
                  </p>
                  <div>
                    <div className="font-medium">Missing schemas:</div>
                    <ul className="ml-4 list-disc text-xs">
                      {status.missing_schemas.slice(0, 6).map((s) => (
                        <li key={s}>
                          <code>{s}</code>
                        </li>
                      ))}
                      {status.missing_schemas.length > 6 && (
                        <li>
                          …and {status.missing_schemas.length - 6} more
                        </li>
                      )}
                    </ul>
                  </div>
                  <p className="text-muted-foreground text-xs">
                    Reconcile re-checks the catalog and updates Lakebase
                    metadata accordingly. No data is dropped.
                  </p>
                  {error && (
                    <div className="rounded border border-red-500/30 bg-red-500/10 p-2 text-xs text-red-700 dark:text-red-300">
                      {error}
                    </div>
                  )}
                </>
              )}
              {!result && mode === "inverse" && (
                <>
                  <p>
                    Schemas for this version exist in the catalog but
                    Lakebase shows it as <strong>not installed</strong>.
                  </p>
                  <div>
                    <div className="font-medium">Schemas found in catalog:</div>
                    <ul className="ml-4 list-disc text-xs">
                      {status.found_schemas.slice(0, 6).map((s) => (
                        <li key={s}>
                          <code>{s}</code>
                        </li>
                      ))}
                      {status.found_schemas.length > 6 && (
                        <li>
                          …and {status.found_schemas.length - 6} more
                        </li>
                      )}
                    </ul>
                  </div>
                  <p className="text-muted-foreground text-xs">
                    Reconcile re-checks the catalog and updates Lakebase
                    metadata accordingly. No data is dropped.
                  </p>
                  {error && (
                    <div className="rounded border border-red-500/30 bg-red-500/10 p-2 text-xs text-red-700 dark:text-red-300">
                      {error}
                    </div>
                  )}
                </>
              )}
              {result && (
                <div className="space-y-2">
                  <div className="flex items-center gap-2">
                    <CheckCircle2 className="h-4 w-4 text-emerald-600" />
                    <span>
                      Lakebase: <code>{result.previous_deployment_status}</code>{" "}
                      → <code>{result.new_deployment_status}</code>
                    </span>
                  </div>
                  <ul className="ml-4 list-disc text-xs text-muted-foreground">
                    {result.notes.map((n, i) => (
                      <li key={i}>{n}</li>
                    ))}
                  </ul>
                </div>
              )}
            </div>
          </AlertDialogDescription>
        </AlertDialogHeader>
        <AlertDialogFooter>
          {result ? (
            <AlertDialogAction
              onClick={() => {
                setResult(null);
                setStatus(
                  mode === "forced"
                    ? { ...status, in_sync: true }
                    : { ...status, lakebase_says_installed: true },
                );
              }}
            >
              Close
            </AlertDialogAction>
          ) : (
            <>
              {/* Forced case: surface "Dismiss" only after a failed
                  attempt, so the user is never trapped if the backend
                  is unreachable. The drift will still be there next
                  time the page loads, and the next install/uninstall
                  run will hit the pre-flight clash check. */}
              {mode === "forced" && error && (
                <AlertDialogCancel
                  onClick={() => {
                    setStatus({ ...status, in_sync: true });
                  }}
                >
                  Dismiss
                </AlertDialogCancel>
              )}
              {/* Inverse case is recoverable/informational, not a
                  confirmed-broken install. Always dismissible, not
                  gated behind a prior reconcile error. */}
              {mode === "inverse" && (
                <AlertDialogCancel
                  onClick={() => {
                    setStatus({ ...status, lakebase_says_installed: true });
                  }}
                >
                  Cancel
                </AlertDialogCancel>
              )}
              <AlertDialogAction
                disabled={busy}
                onClick={(e) => {
                  e.preventDefault();
                  void handleReconcile();
                }}
              >
                {busy ? (
                  <>
                    <RefreshCw className="mr-2 h-4 w-4 animate-spin" />
                    Reconciling…
                  </>
                ) : error ? (
                  "Retry reconcile"
                ) : (
                  "Reconcile"
                )}
              </AlertDialogAction>
            </>
          )}
        </AlertDialogFooter>
      </AlertDialogContent>
    </AlertDialog>
  );
}
