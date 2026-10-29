/**
 * The install and uninstall dialog of a model version (design §1 UI, B4; add
 * §6.2, §10.2). Driven by `useVersionOperationLaunch`:
 *
 * - Install: a catalog picker (default: where the version is installed, else
 *   where its files are), what the install does, the server's blockers and
 *   warnings, one confirmation per confirm subject, the optional "also delete
 *   the replaced versions" box (BusinessAdmins only), and the catalogs the
 *   version stays installed in.
 * - Install into a catalog another version occupies (uninstall-then-install):
 *   the occupant's uninstall impact (`UninstallImpactConfirm`) with a "Pick
 *   another catalog" control; typing the catalog name confirms it when data
 *   is at stake, a checkbox otherwise (one confirmation for one action, R8).
 * - Uninstall: the version's install catalogs and the uninstall impact; the
 *   typed catalog name confirms `uninstall_destroys_data`.
 */
import { useEffect, useId, useMemo, useRef, useState } from "react";
import { AlertTriangle, Info } from "lucide-react";
import {
  useGetInstallationStatus,
  type ModelVersionOut,
} from "@/lib/api";
import type { ConfirmIssue } from "@/lib/api-error";
import { useUserRole, isBusinessAdmin } from "@/lib/hooks";
import {
  defaultInstallCatalog,
  installActionLabel,
  isDryRunDraft,
  isReplaced,
  promotionRuleText,
  subjectKind,
  subjectVersionId,
  versionsPhrase,
} from "@/lib/version-lifecycle";
import {
  useVersionOperationLaunch,
  type VersionOperationIntent,
} from "@/lib/use-version-operation-launch";
import { versionScopeLabel } from "@/lib/version-label";
import { helpSlug } from "@/lib/operations";
import { HelpLink } from "@/components/help/help-link";
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
import { DeploymentCatalogPicker } from "@/components/runs/deployment-catalog-picker";
import {
  UninstallImpactConfirm,
  type UninstallImpactConfirmState,
} from "@/components/runs/uninstall-impact-confirm";

export interface VersionOperationDialogProps {
  open: boolean;
  onOpenChange: (open: boolean) => void;
  businessId: string;
  intent: VersionOperationIntent;
  version: ModelVersionOut;
  /** The business's versions: names the occupant of a catalog. */
  versions: readonly ModelVersionOut[];
  /** Preselected target (e.g. a failed run's catalog). */
  initialCatalog?: string;
}

const UNINSTALL_DESTROYS_DATA = "uninstall_destroys_data";
const INSTALL_OVER_NEWER = "install_over_newer";
const INSTALL_REPLACES_IN_CATALOG = "install_replaces_in_catalog";
const INSTALL_OVERWRITES_SCHEMAS = "install_overwrites_schemas";

const CHECKBOX_LABEL: Record<string, string> = {
  [INSTALL_OVER_NEWER]: "Make this version the latest and replace the newer ones",
  [INSTALL_REPLACES_IN_CATALOG]: "Uninstall the version there first, then install this one",
  [INSTALL_OVERWRITES_SCHEMAS]: "Install into these schemas",
};


function effectText(v: ModelVersionOut, intent: VersionOperationIntent): string {
  const label = `v${v.version}`;
  if (intent === "uninstall") {
    return `Drops ${label}'s schemas and every table in them from the catalog below. The version stays in the app; you can install it again. A schema that cannot be dropped stays, and the run page then names it.`;
  }
  if (isDryRunDraft(v)) {
    return `Creates the schemas and tables of this Dry Run in the catalog below, makes ${label} the latest version and marks the feedback it applied done.`;
  }
  if (isReplaced(v) || v.status === "superseded") {
    return `Installs ${label} into the catalog below. ${promotionRuleText(label)}`;
  }
  return `Creates ${label}'s schemas and tables in the catalog below.`;
}

function IssueList({
  tone,
  title,
  items,
  testId,
}: {
  tone: "blocker" | "warning" | "info";
  title: string;
  items: string[];
  testId: string;
}) {
  if (items.length === 0) return null;
  const cls =
    tone === "blocker"
      ? "border-destructive/50 bg-destructive/5 text-destructive"
      : tone === "warning"
        ? "border-warning/40 bg-warning/5 text-warning"
        : "border-border bg-muted text-foreground";
  return (
    <div role={tone === "blocker" ? "alert" : "note"} data-testid={testId} className={`rounded-md border p-3 text-sm ${cls}`}>
      <p className="font-medium">{title}</p>
      <ul className="mt-1 list-disc space-y-1 pl-5 text-xs">
        {items.map((m) => (
          <li key={m}>{m}</li>
        ))}
      </ul>
    </div>
  );
}

function ConfirmCheckbox({
  subject,
  label,
  checked,
  onChange,
}: {
  subject: string;
  label: string;
  checked: boolean;
  onChange: (v: boolean) => void;
}) {
  const id = useId();
  return (
    <div className="flex items-center gap-2">
      <Checkbox
        id={id}
        data-testid={`confirm-${subjectKind(subject)}`}
        checked={checked}
        onCheckedChange={(v) => onChange(v === true)}
      />
      <label htmlFor={id} className="text-sm font-medium">
        {label}
      </label>
    </div>
  );
}

/** The uninstall-then-install confirmation: the occupant's impact decides
 *  whether the catalog name must be typed or a checkbox is enough. */
function ReplaceInCatalogConfirm({
  businessId,
  issue,
  catalog,
  occupantLabel,
  checked,
  onChange,
  onPickAnother,
}: {
  businessId: string;
  issue: ConfirmIssue;
  catalog: string;
  occupantLabel: string;
  checked: boolean;
  onChange: (v: boolean) => void;
  onPickAnother: () => void;
}) {
  const occupantId = subjectVersionId(issue.subject);
  const [impact, setImpact] = useState<UninstallImpactConfirmState | null>(null);
  const [ticked, setTicked] = useState(false);
  const typed = impact?.needsConfirmation ?? true;
  const ok = impact?.status !== "loading" && (typed ? Boolean(impact?.confirmed) : ticked);
  const onChangeRef = useRef(onChange);
  onChangeRef.current = onChange;
  useEffect(() => {
    if (ok !== checked) onChangeRef.current(ok);
  }, [ok, checked]);
  return (
    <div className="space-y-2 rounded-md border border-destructive/40 p-3" data-testid="confirm-replace-in-catalog">
      <p className="text-sm">{issue.message}</p>
      <Button type="button" variant="outline" size="sm" onClick={onPickAnother} data-testid="pick-another-catalog">
        Pick another catalog
      </Button>
      {!catalog && (
        <p className="text-xs text-muted-foreground" data-testid="replace-needs-catalog">
          Pick the catalog above to see what the install replaces there.
        </p>
      )}
      {occupantId && catalog && (
        <div className="space-y-1">
          <p className="text-xs font-medium text-muted-foreground">
            What uninstalling {occupantLabel} drops in {catalog}:
          </p>
          <UninstallImpactConfirm
            businessId={businessId}
            versionId={occupantId}
            catalog={catalog}
            onStateChange={setImpact}
          />
        </div>
      )}
      {impact && !impact.needsConfirmation && impact.status !== "loading" && (
        <ConfirmCheckbox
          subject={issue.subject}
          label={CHECKBOX_LABEL[INSTALL_REPLACES_IN_CATALOG]}
          checked={ticked}
          onChange={setTicked}
        />
      )}
    </div>
  );
}

export function VersionOperationDialog({
  open,
  onOpenChange,
  businessId,
  intent,
  version,
  versions,
  initialCatalog,
}: VersionOperationDialogProps) {
  const role = useUserRole();
  const canAlsoDelete = isBusinessAdmin(role);
  const status = useGetInstallationStatus({
    params: { model_version_id: version.id },
    query: { enabled: open && version.deployment_status === "deployed", retry: false, staleTime: 30_000 },
  });
  const installedIn = useMemo(() => {
    const s = status.data?.data;
    const list: string[] = [];
    if (version.deployment_status === "deployed" && version.uc_catalog) list.push(version.uc_catalog);
    for (const c of s?.also_installed_in ?? []) {
      if (!list.some((l) => l.toLowerCase() === c.toLowerCase())) list.push(c);
    }
    return list;
  }, [status.data, version.deployment_status, version.uc_catalog]);

  const startCatalog =
    initialCatalog ?? (intent === "uninstall" ? version.uc_catalog || "" : defaultInstallCatalog(version));
  const [catalog, setCatalog] = useState(startCatalog);
  const [alsoDelete, setAlsoDelete] = useState(false);
  const [uninstallImpact, setUninstallImpact] = useState<UninstallImpactConfirmState | null>(null);
  const pickerRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    if (open) {
      setCatalog(startCatalog);
      setAlsoDelete(false);
    }
    // Reset on every open; startCatalog follows the version.
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [open]);

  const op = useVersionOperationLaunch({
    businessId,
    versionId: version.id,
    intent,
    catalog,
    enabled: open,
  });

  // The uninstall's data-loss subject is confirmed only by typing the catalog
  // name: the impact component asks for it whenever the server asks the
  // subject, whatever its own (possibly cached) answer says.
  const destroysIssue = op.confirms.find((c) => subjectKind(c.subject) === UNINSTALL_DESTROYS_DATA);
  const destroysSubject = destroysIssue?.subject;
  const uninstallConfirmed = Boolean(uninstallImpact?.needsConfirmation && uninstallImpact.confirmed);
  const { setConfirmed } = op;
  useEffect(() => {
    if (destroysSubject) setConfirmed(destroysSubject, uninstallConfirmed);
  }, [destroysSubject, uninstallConfirmed, setConfirmed]);

  const label = versionScopeLabel(version.version, version.scope);
  const action = intent === "uninstall" ? "Uninstall" : (installActionLabel(version) ?? "Install");
  const overNewer = op.confirms.find((c) => subjectKind(c.subject) === INSTALL_OVER_NEWER);
  const replaced = overNewer && overNewer.versions.length > 0 ? versionsPhrase(overNewer.versions) : null;
  const offerAlsoDelete = Boolean(overNewer) && canAlsoDelete;
  const target = catalog.trim();
  const staysIn = installedIn.filter((c) => c.toLowerCase() !== target.toLowerCase());
  const impactReady = intent !== "uninstall" || (uninstallImpact?.status !== "loading" && (uninstallImpact?.confirmed ?? false));
  const canLaunch =
    !op.validating &&
    !op.launching &&
    op.blockers.length === 0 &&
    op.allConfirmed &&
    impactReady &&
    (intent === "install" || target !== "");

  const occupantLabel = (subject: string) => {
    const occ = versions.find((v) => v.id === subjectVersionId(subject));
    return occ ? `v${occ.version}` : "the version there";
  };

  return (
    <Dialog
      open={open}
      onOpenChange={(next) => {
        if (!op.launching) onOpenChange(next);
      }}
    >
      <DialogContent className="max-h-[90vh] max-w-2xl overflow-y-auto" data-testid={`${intent}-version-dialog`}>
        <DialogHeader>
          <DialogTitle>
            {action}: {label}
          </DialogTitle>
          <DialogDescription>{effectText(version, intent)}</DialogDescription>
          <HelpLink topic={helpSlug(intent)}>
            {intent === "uninstall" ? "How uninstall works" : "How install works"}
          </HelpLink>
        </DialogHeader>

        <div className="space-y-4">
          {intent === "install" ? (
            <div className="space-y-1.5" ref={pickerRef}>
              <p className="text-sm font-medium">Target catalog</p>
              <DeploymentCatalogPicker value={catalog} onChange={setCatalog} createsSchemas />
              {!target && (
                <p className="text-xs text-muted-foreground">
                  No catalog picked: the app installs into the configured catalog.
                </p>
              )}
            </div>
          ) : (
            installedIn.length > 1 && (
              <fieldset className="space-y-1.5">
                <legend className="text-sm font-medium">Uninstall from</legend>
                {installedIn.map((c) => (
                  <label key={c} className="flex items-center gap-2 text-sm">
                    <input
                      type="radio"
                      name="uninstall-catalog"
                      value={c}
                      checked={target.toLowerCase() === c.toLowerCase()}
                      onChange={() => setCatalog(c)}
                    />
                    <span className="font-mono">{c}</span>
                  </label>
                ))}
              </fieldset>
            )
          )}

          {staysIn.length > 0 && (
            <p className="flex items-start gap-1.5 text-xs text-muted-foreground" data-testid="stays-installed">
              <Info className="mt-0.5 h-3.5 w-3.5 shrink-0" aria-hidden />
              v{version.version} stays installed in {staysIn.join(", ")}.
            </p>
          )}

          {op.validating && (
            <p className="text-xs text-muted-foreground" data-testid="version-op-validating">
              Checking what this run changes...
            </p>
          )}
          {op.validateError && (
            <p className="text-xs text-warning" role="note">
              {op.validateError} The run is checked again when it starts.
            </p>
          )}

          {op.changedOnCreate && (
            <div
              role="alert"
              data-testid="confirmations-changed"
              className="flex items-start gap-2 rounded-md border border-warning/40 bg-warning/5 p-3 text-sm text-warning"
            >
              <AlertTriangle className="mt-0.5 h-4 w-4 shrink-0" aria-hidden />
              <span>Something changed since you opened this dialog. Review and confirm what is asked below.</span>
            </div>
          )}

          <IssueList
            tone="blocker"
            title="This run can't start:"
            items={op.blockers.map((b) => b.message)}
            testId="version-op-blockers"
          />
          <IssueList
            tone="warning"
            title="Before you start:"
            items={op.warnings.map((w) => w.message)}
            testId="version-op-warnings"
          />
          <IssueList
            tone="info"
            title="Before the run starts:"
            items={op.prepares.map((p) => p.message)}
            testId="version-op-prepares"
          />

          {op.confirms.map((c) => {
            const kind = subjectKind(c.subject);
            if (kind === UNINSTALL_DESTROYS_DATA) {
              return (
                <div
                  key={c.subject}
                  role="alert"
                  className="space-y-1 rounded-md border border-destructive/40 bg-destructive/5 p-3 text-sm"
                  data-testid="confirm-issue-uninstall_destroys_data"
                >
                  <p>{c.message}</p>
                  <p className="font-medium">Type the catalog name below to confirm.</p>
                </div>
              );
            }
            if (kind === INSTALL_REPLACES_IN_CATALOG) {
              return (
                <ReplaceInCatalogConfirm
                  key={c.subject}
                  businessId={businessId}
                  issue={c}
                  catalog={target}
                  occupantLabel={occupantLabel(c.subject)}
                  checked={op.isConfirmed(c.subject)}
                  onChange={(v) => op.setConfirmed(c.subject, v)}
                  onPickAnother={() => {
                    pickerRef.current?.querySelector<HTMLElement>("button, input")?.focus();
                  }}
                />
              );
            }
            return (
              <div key={c.subject} className="space-y-2 rounded-md border border-warning/40 p-3" data-testid={`confirm-issue-${kind}`}>
                <p className="text-sm">{c.message}</p>
                <ConfirmCheckbox
                  subject={c.subject}
                  label={CHECKBOX_LABEL[kind] ?? "I understand, go ahead"}
                  checked={op.isConfirmed(c.subject)}
                  onChange={(v) => op.setConfirmed(c.subject, v)}
                />
              </div>
            );
          })}

          {offerAlsoDelete && (
            <div className="space-y-1" data-testid="also-delete-replaced">
              <ConfirmCheckbox
                subject="also_delete_replaced"
                label={`Also delete ${replaced ?? "the replaced versions"} after the install`}
                checked={alsoDelete}
                onChange={setAlsoDelete}
              />
              <p className="pl-6 text-xs text-muted-foreground">
                Permanent. The agent reuses their numbers for the next runs.
              </p>
            </div>
          )}

          {intent === "uninstall" && target && (
            <UninstallImpactConfirm
              businessId={businessId}
              versionId={version.id}
              catalog={target}
              onStateChange={setUninstallImpact}
              requireConfirmation={Boolean(destroysIssue)}
            />
          )}

          {op.launchError && (
            <p role="alert" className="text-sm text-destructive" data-testid="version-op-error">
              {op.launchError}
            </p>
          )}
        </div>

        <DialogFooter>
          <Button variant="outline" disabled={op.launching} onClick={() => onOpenChange(false)}>
            Cancel
          </Button>
          <Button
            data-testid="version-op-launch"
            variant={intent === "uninstall" ? "destructive" : "default"}
            disabled={!canLaunch}
            onClick={() => void op.launch(offerAlsoDelete && alsoDelete ? { also_delete_replaced: true } : undefined)}
          >
            {op.launching ? "Starting..." : action}
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
}
