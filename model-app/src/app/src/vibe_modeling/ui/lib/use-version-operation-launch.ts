/**
 * `useVersionOperationLaunch`: the one way the app starts an install or an
 * uninstall of a model version (design §1 UI, B4 confirmation protocol).
 *
 * 1. Validate (`POST /runs/validate`) for the version and catalog, again
 *    whenever the catalog changes. Blockers stop the launch; `confirm` issues
 *    (subject-bound, in `warnings`) each need the user's confirmation.
 * 2. Create (`POST /runs`) with `confirmed_issues` = the confirmed subjects.
 * 3. A 422 `needs_confirmation` (a subject appeared between validate and
 *    create, e.g. another run finished) re-renders the dialog with the
 *    server's `issues`; confirmations of subjects still asked are kept.
 * 4. On success, non-confirm warnings become toasts and the run page opens.
 */
import { useCallback, useEffect, useMemo, useState } from "react";
import { useQuery } from "@tanstack/react-query";
import { useNavigate } from "@tanstack/react-router";
import { toast } from "sonner";
import { createRun, validateRun, type IssueOut, type RunIn } from "@/lib/api";
import {
  apiErrorMessage,
  parseNeedsConfirmation,
  type ConfirmIssue,
} from "@/lib/api-error";
import { useDebouncedValue } from "@/lib/hooks";
import { notifyConfigMissing } from "@/lib/notify";

export type VersionOperationIntent = "install" | "uninstall";

export interface VersionOperationLaunchOptions {
  businessId: string;
  versionId: string;
  intent: VersionOperationIntent;
  /** Target catalog; empty lets the server pick its default (B3). */
  catalog: string;
  /** Only while the dialog is open. */
  enabled: boolean;
}

export interface VersionOperationLaunch {
  validating: boolean;
  /** Validate itself failed (network, 5xx); the launch stays possible. */
  validateError: string | null;
  blockers: IssueOut[];
  /** Warnings that need no confirmation. */
  warnings: IssueOut[];
  /** What the launch sets up itself before the run starts (``prepare``). */
  prepares: IssueOut[];
  /** The subject-bound issues to confirm, from validate or from a 422. */
  confirms: ConfirmIssue[];
  isConfirmed: (subject: string) => boolean;
  setConfirmed: (subject: string, value: boolean) => void;
  /** Every confirm subject is confirmed. */
  allConfirmed: boolean;
  /** The server asked for confirmations the dialog did not show. */
  changedOnCreate: boolean;
  launching: boolean;
  launchError: string | null;
  launch: (extra?: Pick<RunIn, "also_delete_replaced">) => Promise<void>;
}

function toConfirm(issue: IssueOut): ConfirmIssue | null {
  if (issue.severity !== "confirm" || !issue.subject) return null;
  return {
    subject: issue.subject,
    message: issue.message,
    field_path: issue.field_path,
    versions: issue.versions ?? [],
  };
}

export function useVersionOperationLaunch({
  businessId,
  versionId,
  intent,
  catalog,
  enabled,
}: VersionOperationLaunchOptions): VersionOperationLaunch {
  const navigate = useNavigate();
  const target = useDebouncedValue(catalog.trim(), 300);
  const body = useMemo<RunIn>(
    () => ({ intent, version_id: versionId, ...(target ? { catalog: target } : {}) }),
    [intent, versionId, target],
  );

  const validation = useQuery({
    queryKey: ["versionOperationValidate", businessId, body],
    queryFn: async () => (await validateRun({ business_id: businessId }, body)).data,
    enabled,
    retry: false,
    staleTime: 0,
    gcTime: 0,
    // Each validate of an uninstall may scan the catalog (per-user limit).
    refetchOnWindowFocus: false,
  });

  // Confirm issues the create answered with; they replace validate's until
  // the next validate (a new catalog) answers.
  const [serverConfirms, setServerConfirms] = useState<{
    key: string;
    issues: ConfirmIssue[];
  } | null>(null);
  const [confirmed, setConfirmedState] = useState<Set<string>>(new Set());
  const [launching, setLaunching] = useState(false);
  const [launchError, setLaunchError] = useState<string | null>(null);

  const bodyKey = JSON.stringify(body);
  // A new target asks new questions: confirmations given for the previous
  // one do not carry over (some subjects are not bound to a catalog).
  useEffect(() => {
    setConfirmedState(new Set());
    setServerConfirms(null);
    setLaunchError(null);
  }, [bodyKey]);
  const fromValidate = useMemo(
    () =>
      (validation.data?.warnings ?? [])
        .map(toConfirm)
        .filter((c): c is ConfirmIssue => c !== null),
    [validation.data],
  );
  const confirms =
    serverConfirms && serverConfirms.key === bodyKey ? serverConfirms.issues : fromValidate;
  const warnings = (validation.data?.warnings ?? []).filter(
    (w) => w.severity !== "confirm" && w.severity !== "prepare",
  );
  const prepares = (validation.data?.warnings ?? []).filter((w) => w.severity === "prepare");
  const blockers = validation.data?.blockers ?? [];

  const isConfirmed = useCallback((subject: string) => confirmed.has(subject), [confirmed]);
  const setConfirmed = useCallback((subject: string, value: boolean) => {
    setConfirmedState((prev) => {
      if (prev.has(subject) === value) return prev;
      const next = new Set(prev);
      if (value) next.add(subject);
      else next.delete(subject);
      return next;
    });
  }, []);
  const allConfirmed = confirms.every((c) => confirmed.has(c.subject));

  const launch = useCallback(
    async (extra?: Pick<RunIn, "also_delete_replaced">) => {
      setLaunching(true);
      setLaunchError(null);
      const subjects = confirms.map((c) => c.subject).filter((s) => confirmed.has(s));
      try {
        const res = await createRun(
          { business_id: businessId },
          {
            ...body,
            confirmed_issues: subjects,
            ...(extra?.also_delete_replaced ? { also_delete_replaced: true } : {}),
          },
        );
        for (const w of res.data.warnings ?? []) {
          const issue = w as { message?: string; severity?: string };
          if (issue.message && issue.severity !== "confirm") toast.warning(issue.message);
        }
        navigate({
          to: "/businesses/$businessId/runs/$runId",
          params: { businessId, runId: res.data.id },
        });
      } catch (err) {
        const needs = parseNeedsConfirmation(err);
        if (needs) {
          setServerConfirms({ key: bodyKey, issues: needs.issues });
          const asked = new Set(needs.issues.map((i) => i.subject));
          setConfirmedState((prev) => new Set([...prev].filter((s) => asked.has(s))));
        } else if (!notifyConfigMissing(err)) {
          // A 422 config_missing shows only the shared notice with its
          // Settings links, as the run form does.
          setLaunchError(apiErrorMessage(err, "The run could not be started."));
        }
        setLaunching(false);
      }
    },
    [businessId, body, bodyKey, confirms, confirmed, navigate],
  );

  return {
    validating: enabled && (validation.isPending || target !== catalog.trim()),
    validateError: validation.isError
      ? apiErrorMessage(validation.error, "The checks could not run.")
      : null,
    blockers,
    warnings,
    prepares,
    confirms,
    isConfirmed,
    setConfirmed,
    allConfirmed,
    changedOnCreate: serverConfirms?.key === bodyKey,
    launching,
    launchError,
    launch,
  };
}
