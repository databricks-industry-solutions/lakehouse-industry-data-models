/**
 * WhatYouSubmitted — surfaces the user-facing inputs that were submitted
 * when the run was created.
 *
 * Intent: show the DATA MODELER what they actually typed/selected, verbatim.
 * This is distinct from the orchestrator-internal "Run configuration" block
 * (parameters_json), which contains widget mappings and pipeline phase flags
 * the user never typed.
 *
 * Previous wiring: reads from RunOut fields:
 *   - business_context_text (new, migration 0.2.0)
 *   - vibe_instructions_text (pre-existing Run column, already in RunOut)
 *   - vibe_instructions_volume_path (pre-existing, already in RunOut)
 *   - parameters_json → generate_samples / sample_count (inlined in params)
 * New wiring: also accepts the run's operations (`RunOperationOut[]`, fetched
 *   by the caller via `useListRunOperations`) and, for each operation whose
 *   `dispatched_widgets` map is non-empty, renders the complete key/value map
 *   verbatim. This is the durable, unredacted answer to "what did we
 *   actually dispatch to the job" for an operator debugging a run.
 *   Operations without a populated map (most ops today, until the rollout
 *   covers every primitive) render nothing.
 * Info-flow delta: form -> DB column (business_context_text) -> RunOut -> this
 *   component (pre-existing). New: run_operations.dispatched_widgets_json ->
 *   RunOperationOut.dispatched_widgets -> this component. No dead ends;
 *   every field has a consumer here.
 */

import ReactMarkdown from "react-markdown";
import type { RunOperationOut, RunOut } from "@/lib/api";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { FileText } from "lucide-react";
import { stripVibeMarkers } from "@/lib/vibe-scope";

interface WhatYouSubmittedProps {
  run: RunOut;
  operations?: RunOperationOut[];
}

/** Render a dict value as a single-line string, matching the "advanced
 * overrides" convention below (String(...) for scalars) but falling back to
 * JSON for non-scalar widget values (arrays, nested objects) since
 * dispatched_widgets is an untyped dict on the wire.
 */
function formatWidgetValue(value: unknown): string {
  // `model_vibes` carries K1 markers when sent inline; never show them raw (D16).
  if (typeof value === "string") return stripVibeMarkers(value);
  if (value === null || value === undefined) return String(value);
  if (typeof value === "object") return JSON.stringify(value);
  return String(value);
}

/** Parse sample-data intent out of parameters_json.
 *
 * The legacy path stores generate_samples + sample_count in parameters_json
 * as widget-derived values. The orchestrator path stores the full RunIn
 * snapshot (also includes generate_samples). We pull from either shape.
 */
function parseSampleInfo(paramsJson: string): {
  generateSamples: boolean;
  sampleCount: number | null;
} {
  try {
    const p = JSON.parse(paramsJson);
    if (typeof p !== "object" || p === null) return { generateSamples: false, sampleCount: null };
    const gs = p["generate_samples"];
    const sc = p["sample_count"] ?? p["samples_count"] ?? null;
    return {
      generateSamples: gs === true || gs === "true" || gs === 1,
      sampleCount: typeof sc === "number" && sc > 0 ? sc : null,
    };
  } catch {
    return { generateSamples: false, sampleCount: null };
  }
}

/** Parse any advanced-override fields the user may have set.
 *
 * Convention overrides are stored in parameters_json (both paths). The router
 * stamps canonical defaults into the params blob even when the user never
 * touched the Advanced Options panel — so a non-empty value alone does NOT
 * indicate a user override. We compare each field against its canonical
 * default (mirrored from `CONVENTION_DEFAULTS` in routes/_sidebar/runs.new.tsx)
 * and only surface fields that the user *actually changed*.
 *
 * Bug #43: previously this loop showed every non-empty field, polluting the
 * "what did I submit" surface with router-derived defaults like
 * `Schema prefix: ecm_`, `MVM schema prefix: mvm_`, `Cataloging style: One Catalog`.
 */
const ADVANCED_FIELD_LABELS: Record<string, string> = {
  naming_convention: "Naming convention",
  primary_key_suffix: "Primary key suffix",
  schema_prefix: "Schema prefix",
  ecm_schema_prefix: "ECM schema prefix",
  mvm_schema_prefix: "MVM schema prefix",
  schema_suffix: "Schema suffix",
  tag_prefix: "Tag prefix",
  tag_suffix: "Tag suffix",
  table_id_type: "Table ID type",
  boolean_format: "Boolean format",
  date_format: "Date format",
  timestamp_format: "Timestamp format",
  cataloging_style: "Cataloging style",
  catalog_prefix: "Catalog prefix",
  catalog_suffix: "Catalog suffix",
  org_divisions: "Org divisions",
  business_domains: "Business domains",
  classification_levels: "Classification levels",
  housekeeping_columns: "Housekeeping columns",
  history_tracking_columns: "History tracking columns",
  // No entry in ADVANCED_FIELD_DEFAULTS: the default comes from Settings and
  // can change, so the stored hours always show.
  runtime_budget_hours: "Run time budget (hours)",
};

/** Canonical defaults (mirrored from `CONVENTION_DEFAULTS` in routes/_sidebar/
 * runs.new.tsx). When a field in `parameters_json` matches its default, we
 * treat it as router-stamped and HIDE it; only true user overrides are shown.
 *
 * Keep this in sync with the new-run form. If the form gains a new override
 * field, add the label above and the default here.
 */
const ADVANCED_FIELD_DEFAULTS: Record<string, string> = {
  naming_convention: "snake_case",
  primary_key_suffix: "_id",
  schema_prefix: "",
  ecm_schema_prefix: "ecm_",
  mvm_schema_prefix: "mvm_",
  schema_suffix: "",
  tag_prefix: "dbx_",
  tag_suffix: "",
  table_id_type: "BIGINT",
  boolean_format: "Boolean (True/False)",
  date_format: "yyyy-MM-dd",
  timestamp_format: "yyyy-MM-dd HH:mm:ss",
  cataloging_style: "One Catalog",
  catalog_prefix: "",
  catalog_suffix: "",
  org_divisions: "Operations",
  business_domains: "",
  classification_levels: "",
  housekeeping_columns: "No",
  history_tracking_columns: "No",
};

// Fields that appear in parameters_json but are orchestrator-internal
// (never user-typed) — skip these even if non-empty.
const SKIP_FIELDS = new Set([
  "intent",
  "deployment_catalog",
  "ecm_mvm_unified",
  "ecm_mvm_phase",
  "business_id",
  "version_id",
  "parent_version_id",
  "context_id",
  "model_size",
  "vibe_instructions",
  "generate_samples",
  "sample_count",
  "samples_count",
  "business_context_path",
  "business_context_text",
  "next_vibe_ids",
  "catalog",
]);

/** Intents whose router path stamps the legacy `schema_prefix` as a MIRROR of
 * the effective ECM prefix (`stored_params["schema_prefix"] = ecm_prefix`, see
 * router.py `_create_new_base_model_run_via_orchestrator` and
 * `_create_vibe_new_ecm_mvm_run_via_orchestrator`). Only for these is a
 * `schema_prefix` value router-derived. `vibe-iterate` takes a different path
 * that appends `schema_prefix` ONLY when the user genuinely set it, so its
 * value must never be suppressed. */
const SCHEMA_PREFIX_MIRROR_INTENTS = new Set(["new-base-model", "vibe-new-ecm-mvm"]);

/** Whether a `schema_prefix` value is the router-stamped ECM mirror rather
 * than a genuine user override. Gated on `intent`: only the ECM-producing
 * intents stamp the mirror. For those, a value equal to the params'
 * `ecm_schema_prefix` (or the canonical `ecm_` default when that key is
 * absent) is not something the user typed. For every other intent (notably
 * `vibe-iterate`) the value is a real user field and is never suppressed. */
function isSchemaPrefixMirror(val: string, params: Record<string, unknown>): boolean {
  const intent = params["intent"];
  if (typeof intent !== "string" || !SCHEMA_PREFIX_MIRROR_INTENTS.has(intent)) {
    return false;
  }
  const ecmInParams = params["ecm_schema_prefix"];
  if (typeof ecmInParams === "string" && ecmInParams !== "" && val === ecmInParams) {
    return true;
  }
  return val === ADVANCED_FIELD_DEFAULTS.ecm_schema_prefix;
}

function parseAdvancedOverrides(paramsJson: string): Array<{ label: string; value: string }> {
  try {
    const p = JSON.parse(paramsJson);
    if (typeof p !== "object" || p === null) return [];
    const out: Array<{ label: string; value: string }> = [];
    for (const [key, label] of Object.entries(ADVANCED_FIELD_LABELS)) {
      if (SKIP_FIELDS.has(key)) continue;
      const val = p[key];
      if (val === null || val === undefined || val === "") continue;
      // Hide fields that match the canonical default — those were stamped by
      // the router, not typed by the user. Compare as strings so numeric and
      // boolean defaults still match.
      const defaultVal = ADVANCED_FIELD_DEFAULTS[key];
      if (defaultVal !== undefined && String(val) === defaultVal) continue;
      // `schema_prefix` is a backend MIRROR of the effective ECM prefix — the
      // router stamps `schema_prefix = ecm_schema_prefix` for base-model runs
      // (see router.py). So a value of `ecm_` here is router-derived, NOT a
      // user override, even though the legacy `schema_prefix` default is "".
      // Hide it when it matches the ECM prefix present in params (the mirror)
      // or the canonical ECM default (`ecm_`).
      if (key === "schema_prefix" && isSchemaPrefixMirror(String(val), p)) {
        continue;
      }
      out.push({ label, value: String(val) });
    }
    return out;
  } catch {
    return [];
  }
}

export function WhatYouSubmitted({ run, operations = [] }: WhatYouSubmittedProps) {
  const businessContextText = (run.business_context_text || "").trim();
  // The stored text is the agent text, which carries K1 markers; react-markdown
  // would render them as raw text (D16).
  const vibeInstructionsText = stripVibeMarkers(run.vibe_instructions_text).trim();
  const volumePath = (run.vibe_instructions_volume_path || "").trim();
  const paramsJson = run.parameters_json || "{}";

  const { generateSamples, sampleCount } = parseSampleInfo(paramsJson);
  const advancedOverrides = parseAdvancedOverrides(paramsJson);
  const versionResolutions = (run.version_resolutions ?? []).filter(
    (vr) => vr.original_target !== vr.new_target,
  );
  // Only operations whose dispatched-widget map was actually populated at
  // dispatch time. Legacy runs and ops that don't yet write this field carry
  // `{}` (or omit it); skip those entirely rather than showing an empty
  // section.
  const opsWithDispatchedWidgets = operations.filter(
    (op) => op.dispatched_widgets && Object.keys(op.dispatched_widgets).length > 0,
  );

  const hasBusinessContext = businessContextText.length > 0;
  const hasVibeInstructions = vibeInstructionsText.length > 0;
  const hasVolumePath = volumePath.length > 0;
  const hasSamples = generateSamples;
  const hasAdvanced = advancedOverrides.length > 0;
  const hasResolutions = versionResolutions.length > 0;
  const hasDispatchedWidgets = opsWithDispatchedWidgets.length > 0;

  const hasAny =
    hasBusinessContext ||
    hasVibeInstructions ||
    hasVolumePath ||
    hasSamples ||
    hasAdvanced ||
    hasResolutions ||
    hasDispatchedWidgets;

  return (
    <Card>
      <CardHeader className="pb-3">
        <CardTitle className="text-base flex items-center gap-2">
          <FileText className="h-4 w-4" />
          What you submitted
        </CardTitle>
      </CardHeader>
      <CardContent className="space-y-4">
        {!hasAny && (
          <p className="text-sm text-muted-foreground italic">
            No additional inputs recorded for this run.
          </p>
        )}

        {hasBusinessContext && (
          <SubmittedField label="Business context">
            <div className="prose prose-sm dark:prose-invert max-w-none text-sm">
              <ReactMarkdown>{businessContextText}</ReactMarkdown>
            </div>
          </SubmittedField>
        )}

        {hasVibeInstructions && (
          <SubmittedField label="Run instructions">
            <div className="prose prose-sm dark:prose-invert max-w-none text-sm">
              <ReactMarkdown>{vibeInstructionsText}</ReactMarkdown>
            </div>
          </SubmittedField>
        )}

        {hasVolumePath && (
          <SubmittedField label="Instructions file (Volume path)">
            <code className="text-xs font-mono text-muted-foreground break-all select-all">
              {volumePath}
            </code>
          </SubmittedField>
        )}

        {hasSamples && (
          <SubmittedField label="Sample data">
            <div className="flex items-center gap-2">
              <Badge variant="secondary" className="text-xs">
                {sampleCount != null ? `${sampleCount} records` : "Enabled"}
              </Badge>
            </div>
          </SubmittedField>
        )}

        {hasAdvanced && (
          <SubmittedField label="Advanced overrides">
            <dl className="grid grid-cols-[auto_1fr] gap-x-4 gap-y-1 text-sm">
              {advancedOverrides.map(({ label, value }) => (
                <div key={label} className="contents">
                  <dt className="text-muted-foreground whitespace-nowrap">{label}</dt>
                  <dd className="font-mono break-all">{value}</dd>
                </div>
              ))}
            </dl>
          </SubmittedField>
        )}

        {hasResolutions && (
          <div
            data-testid="version-resolutions"
            className="rounded border border-info/40 bg-info/5 p-3 text-sm"
          >
            <p className="text-xs font-semibold uppercase tracking-wide text-info mb-1">
              Version resolution
            </p>
            <ul className="space-y-0.5">
              {versionResolutions.map((vr) => (
                <li
                  key={vr.target_scope}
                  className="text-info"
                >
                  Requested {vr.target_scope.toUpperCase()} v{vr.original_target}. Agent resolved to v{vr.new_target} (auto-collision-resolved).
                </li>
              ))}
            </ul>
          </div>
        )}

        {opsWithDispatchedWidgets.map((op) => (
          <SubmittedField
            key={op.id}
            label={`Dispatched widgets (${op.operation_name})`}
          >
            <dl className="grid grid-cols-[auto_1fr] gap-x-4 gap-y-1 text-sm font-mono">
              {Object.entries(op.dispatched_widgets as Record<string, unknown>).map(
                ([key, value]) => (
                  <div key={key} className="contents">
                    <dt className="text-muted-foreground whitespace-nowrap">{key}</dt>
                    <dd className="break-all">{formatWidgetValue(value)}</dd>
                  </div>
                ),
              )}
            </dl>
          </SubmittedField>
        ))}
      </CardContent>
    </Card>
  );
}

function SubmittedField({
  label,
  children,
}: {
  label: string;
  children: React.ReactNode;
}) {
  return (
    <div className="space-y-1">
      <p className="text-xs font-semibold uppercase tracking-wide text-muted-foreground">
        {label}
      </p>
      <div className="rounded border bg-muted/30 p-3">{children}</div>
    </div>
  );
}
