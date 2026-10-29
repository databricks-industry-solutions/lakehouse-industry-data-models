import { Suspense, useState } from "react";
import { useQueryClient } from "@tanstack/react-query";
import { ExternalLink, Save } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Skeleton } from "@/components/ui/skeleton";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import {
  getAssessConfigKey,
  putAssessConfig,
  useGetAssessConfigSuspense,
  type AssessConfigIn,
  type AssessConfigOut,
} from "@/lib/api";
import { ADMIN_HELP_LEAD_SAVE, ASSESS_MODEL, readerSetupSteps } from "@/lib/assessment";
import { apiErrorMessage, parseAdminHelp, parseSettingsError, type AdminHelp } from "@/lib/api-error";
import { SettingsErrorNotice } from "@/components/feature-gate";
import { AdminHelpBlock } from "@/components/assessment/admin-help-block";
import { CopyBlock } from "@/components/assessment/copy-block";
import { SavedNotice, SaveErrorBox, StatusLine } from "@/components/settings/status-line";
import { selector } from "@/lib/selector";

const EFFORTS = ["low", "medium", "high"] as const;
const SAVE_FAILED = "Couldn't save the assessment settings.";

/** The input each refusable Save field key (`setting_refused.key`) highlights. */
const FIELD_IDS: Record<string, string> = {
  reader_application_id: "assess-reader-id",
  warehouse_id: "assess-warehouse",
};

/** Input classes of a field a Save refused. */
const REFUSED_FIELD = "border-destructive focus-visible:ring-destructive";

function StatusRow({ label, value }: { label: string; value: string }) {
  return (
    <div className="flex gap-2 text-sm">
      <span className="w-32 shrink-0 text-muted-foreground">{label}</span>
      <span className="break-all font-mono text-xs">{value || "—"}</span>
    </div>
  );
}

function AssessSettingsForm() {
  const { data: config } = useGetAssessConfigSuspense(selector<AssessConfigOut>());
  const queryClient = useQueryClient();
  const [readerId, setReaderId] = useState(config.reader_application_id);
  const [maxRuns, setMaxRuns] = useState(String(config.max_concurrent_runs));
  const [effort, setEffort] = useState<string>(config.default_reasoning_effort);
  const [warehouseId, setWarehouseId] = useState(config.warehouse_id);
  const [saving, setSaving] = useState(false);
  const [saveError, setSaveError] = useState<string | null>(null);
  const [saveHelp, setSaveHelp] = useState<AdminHelp | null>(null);
  // An unset deployment catalog (config_missing) or a refused field (setting_refused).
  const [settingsError, setSettingsError] = useState<unknown>(null);
  const refused = parseSettingsError(settingsError);
  const refusedKey = refused?.refusedKey ?? null;
  const fieldProps = (key: string) =>
    refusedKey === key
      ? { "aria-invalid": true, "aria-describedby": `${FIELD_IDS[key]}-refused`, className: `font-mono ${REFUSED_FIELD}` }
      : { className: "font-mono" };
  const [saved, setSaved] = useState(false);

  const handleSave = async (e: React.FormEvent) => {
    e.preventDefault();
    setSaving(true);
    setSaveError(null);
    setSaveHelp(null);
    setSettingsError(null);
    setSaved(false);
    try {
      await putAssessConfig({
        reader_application_id: readerId.trim(),
        max_concurrent_runs: Number(maxRuns),
        default_reasoning_effort: effort as AssessConfigIn["default_reasoning_effort"],
        warehouse_id: warehouseId.trim(),
      });
      setSaved(true);
    } catch (err) {
      // Nothing is written on a refusal. A 422 `config_missing` (deployment catalog unset) shows
      // its message with the Settings link; a 400 `setting_refused` (reader or warehouse refused)
      // shows it under the refused field, which is highlighted and focused; a 409 admin-help
      // detail (the reader lookup failed, or the job sync failed and was rolled back) shows the block.
      const settings = parseSettingsError(err);
      const help = parseAdminHelp(err);
      if (settings) {
        setSettingsError(err);
        const fieldId = settings.refusedKey ? FIELD_IDS[settings.refusedKey] : undefined;
        if (fieldId) requestAnimationFrame(() => document.getElementById(fieldId)?.focus());
      } else {
        setSaveHelp(help);
        setSaveError(help ? SAVE_FAILED : apiErrorMessage(err, SAVE_FAILED));
      }
    } finally {
      // A failed sync is recorded on the row, so `missing` changes on every outcome.
      await queryClient.invalidateQueries({ queryKey: getAssessConfigKey() });
      setSaving(false);
    }
  };

  const refusedLine = (key: string) =>
    refusedKey === key && refused ? (
      <StatusLine tone="error" id={`${FIELD_IDS[key]}-refused`} testId={`assess-refused-${key}`}>
        {refused.message}
      </StatusLine>
    ) : null;

  return (
    <div className="space-y-6">
      <section className="space-y-1" aria-labelledby="assess-status-heading">
        <h3 id="assess-status-heading" className="text-sm font-semibold">Status</h3>
        {config.missing.length > 0 && (
          <div className="space-y-1 pb-2" data-testid="assess-missing">
            {config.missing.map((reason) => (
              <StatusLine key={reason} tone="error">
                {reason}
              </StatusLine>
            ))}
          </div>
        )}
        {config.reader_display_name && (
          <StatusRow label="Reader" value={config.reader_display_name} />
        )}
        <StatusRow label="Job ID" value={config.job_id == null ? "" : String(config.job_id)} />
        {config.job_url && (
          <div className="flex gap-2 text-sm">
            <span className="w-32 shrink-0" />
            <a
              href={config.job_url}
              target="_blank"
              rel="noreferrer"
              className="inline-flex items-center gap-1 text-xs text-primary hover:underline"
            >
              Open job <ExternalLink className="h-3 w-3" />
            </a>
          </div>
        )}
        <StatusRow label="Workspace path" value={config.workspace_path} />
        <StatusRow label="Genie version" value={config.genie_version} />
        <StatusRow
          label="Skills"
          value={`${config.skills_version} @ ${config.skills_ref.slice(0, 7)}`}
        />
      </section>

      <section className="space-y-4" aria-labelledby="assess-reader-heading">
        <h3 id="assess-reader-heading" className="text-sm font-semibold">Reader service principal</h3>
        <details open={!config.ready} data-testid="assess-setup-steps">
          <summary className="cursor-pointer text-sm underline underline-offset-2">
            Setup steps
          </summary>
          {config.app_application_id && (
            <div className="mt-3 space-y-1.5">
              <p className="text-xs text-muted-foreground">
                This app runs as service principal{" "}
                <span className="font-mono">{config.app_application_id}</span>
              </p>
              <CopyBlock text={config.app_application_id} label="Copy app application ID" />
            </div>
          )}
          <ol className="mt-3 space-y-4">
            {readerSetupSteps(readerId, warehouseId, config.app_application_id ?? "").map((step, i) => (
              <li
                key={step.title}
                data-testid={`assess-setup-step-${i + 1}`}
                className="flex gap-3"
              >
                <span className="flex h-5 w-5 shrink-0 items-center justify-center rounded-full border text-xs font-medium text-muted-foreground">
                  {i + 1}
                </span>
                <div className="min-w-0 flex-1 space-y-1.5">
                  <div className="text-sm font-medium">{step.title}</div>
                  <p className="text-xs text-muted-foreground">{step.detail}</p>
                  {step.code && <CopyBlock text={step.code} label="Copy" />}
                </div>
              </li>
            ))}
          </ol>
          <p className="mt-3 text-xs text-muted-foreground">
            The New assessment page checks the reader's grants before launch and shows the exact
            GRANT for anything missing.
          </p>
        </details>
        <form onSubmit={handleSave} className="space-y-4">
          <div className="space-y-1">
            <label htmlFor="assess-reader-id" className="text-sm font-medium">
              Reader application ID
            </label>
            <Input
              id="assess-reader-id"
              value={readerId}
              onChange={(e) => {
                setReaderId(e.target.value);
                if (refusedKey === "reader_application_id") setSettingsError(null);
              }}
              placeholder="Application ID of vibe-assess-reader"
              {...fieldProps("reader_application_id")}
            />
            {refusedLine("reader_application_id")}
          </div>
          <div className="grid gap-4 sm:grid-cols-2">
            <div className="space-y-1">
              <label htmlFor="assess-max-runs" className="text-sm font-medium">
                Max concurrent runs
              </label>
              <Select value={maxRuns} onValueChange={setMaxRuns}>
                <SelectTrigger id="assess-max-runs">
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  {[1, 2, 3, 4, 5].map((n) => (
                    <SelectItem key={n} value={String(n)}>
                      {n}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
              <p className="text-xs text-muted-foreground">
                All runs share the workspace's {ASSESS_MODEL} rate limit, so more than 2 mostly
                makes them take turns. To run faster, ask your Databricks account team for a
                higher rate limit.
              </p>
            </div>
            <div className="space-y-1">
              <label htmlFor="assess-effort" className="text-sm font-medium">
                Default reasoning effort
              </label>
              <Select value={effort} onValueChange={setEffort}>
                <SelectTrigger id="assess-effort">
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  {EFFORTS.map((v) => (
                    <SelectItem key={v} value={v}>
                      {v}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>
          </div>
          <div className="space-y-1">
            <label htmlFor="assess-warehouse" className="text-sm font-medium">
              SQL warehouse ID (optional)
            </label>
            <Input
              id="assess-warehouse"
              value={warehouseId}
              onChange={(e) => {
                setWarehouseId(e.target.value);
                if (refusedKey === "warehouse_id") setSettingsError(null);
              }}
              placeholder="Defaults to the platform warehouse"
              {...fieldProps("warehouse_id")}
            />
            {refusedLine("warehouse_id")}
          </div>
          <Button type="submit" disabled={saving || !readerId.trim()}>
            <Save className="mr-1.5 h-4 w-4" />
            {saving ? "Saving..." : "Save"}
          </Button>
          {refused && !(refusedKey && FIELD_IDS[refusedKey]) && (
            <SettingsErrorNotice error={settingsError} fallback={SAVE_FAILED} testId="assess-save-config-missing" />
          )}
          {saveError && <SaveErrorBox testId="assess-save-error">{saveError}</SaveErrorBox>}
          {saveHelp && (
            <AdminHelpBlock help={saveHelp} testId="assess-save-admin-help" lead={ADMIN_HELP_LEAD_SAVE} live />
          )}
          {saved && <SavedNotice>Assessment settings saved</SavedNotice>}
        </form>
      </section>
    </div>
  );
}

export function AssessSettings() {
  return (
    <Suspense fallback={<Skeleton className="h-96 w-full" />}>
      <AssessSettingsForm />
    </Suspense>
  );
}
