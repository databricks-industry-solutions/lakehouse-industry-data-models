/**
 * The New Run form's pre-fill for a vibe (Vibe Modeling, Vibe ECM + MVM) from
 * `getRunDefaults` (backend `services/run_defaults.py`), and the lock the
 * agent applies: on `vibe modeling of version` it keeps the base model's value
 * of each `MODEL_CONVENTION_KEYS` field, every one on a Some domains run and
 * the ones the base sets otherwise (`_vov_base_conventions_win`, nb
 * 52132-52149). Schema Suffix and Tag Suffix are outside that list but the
 * agent ignored an edit of both on a live Dry Run, so the server locks them on
 * every vibe. The server says which fields lock; this module only derives what
 * the form shows and sends.
 */
import type { RunDefaultFieldOut, RunDefaultsOut } from "@/lib/api";

/** The Advanced Options a vibe pre-fills, by `RunIn` field. */
export const PREFILL_FIELDS = [
  "naming_convention",
  "primary_key_suffix",
  "schema_prefix",
  "schema_suffix",
  "tag_prefix",
  "tag_suffix",
  "table_id_type",
  "boolean_format",
  "date_format",
  "timestamp_format",
  "classification_levels",
  "catalog_prefix",
  "catalog_suffix",
  "org_divisions",
  "housekeeping_columns",
  "history_tracking_columns",
] as const;
export type PrefillField = (typeof PREFILL_FIELDS)[number];

export const LOCKED_NOTE =
  "This vibe keeps the base model's conventions; the agent ignores changes here.";
export const UNREAD_NOTE = "Couldn't read the base model's conventions; the agent keeps them.";
export const BASE_UNSET_NOTE = "The base model doesn't set this; the agent uses the value here.";
export const BASE_UNSET_PLACEHOLDER = "Not set in the base model";
export const UNKNOWN_PLACEHOLDER = "Kept from the base model";
export const LOADING_NOTE = "Reading the base model's conventions";
export const LOAD_FAILED_NOTE =
  "Couldn't load the base model's conventions, so these fields show the form's values. The agent still keeps the base model's own conventions.";

export type FieldSource = RunDefaultFieldOut["source"] | "form";

export interface EffectiveField {
  /** What the form shows and sends; `null` is unknown and is not sent. */
  value: string | null;
  locked: boolean;
  source: FieldSource;
  /** The base leaves this field empty, so only a Some domains vibe locks it. */
  baseUnset: boolean;
}

/** What an empty locked field shows instead of a value, if anything. */
export function lockedPlaceholder(field: EffectiveField): string | undefined {
  if (field.value === null) return UNKNOWN_PLACEHOLDER;
  if (field.locked && field.baseUnset) return BASE_UNSET_PLACEHOLDER;
  return undefined;
}

/** Where a field's value comes from, for its tooltip. */
export function sourceLabel(field: EffectiveField): string {
  switch (field.source) {
    case "base_file":
      return "From the base model's file";
    case "base_run":
      return "From the run that made the base model";
    case "default":
      return "App default";
    case "unknown":
      return UNREAD_NOTE;
    default:
      return "";
  }
}

/**
 * Each pre-filled field as the form shows it. A locked field shows the base
 * value whatever the user typed; otherwise a user edit stands; otherwise the
 * pre-fill; otherwise the form's own value. Without `defaults` (a New Base
 * Model, or while loading or after a failed load) every field is the user's
 * value or the form's.
 */
export function effectiveConventions(
  defaults: RunDefaultsOut | undefined,
  userEdits: Partial<Record<PrefillField, string>>,
  scoped: boolean,
  formValues: Record<PrefillField, string>,
): Record<PrefillField, EffectiveField> {
  const out = {} as Record<PrefillField, EffectiveField>;
  for (const field of PREFILL_FIELDS) {
    const d = defaults?.fields[field];
    const locked = d ? Boolean(scoped ? d.locked_scoped : d.locked) : false;
    const baseUnset = Boolean(d && d.locked_scoped && !d.locked);
    if (d && locked) {
      out[field] = { value: d.value ?? null, locked, source: d.source, baseUnset };
    } else if (userEdits[field] !== undefined) {
      out[field] = { value: userEdits[field]!, locked, source: "form", baseUnset };
    } else if (d && d.value != null) {
      out[field] = { value: d.value, locked, source: d.source, baseUnset };
    } else {
      out[field] = { value: formValues[field], locked, source: "form", baseUnset };
    }
  }
  return out;
}

/**
 * The convention fields a vibe sends: every known value, blanks included
 * (an unscoped vibe takes a blank as the value), unknown ones left out so
 * the server default applies. Organization Divisions is sent by the form's
 * own rule. `schemaPrefixAs` names the field the Schema Prefix box goes out
 * as: `schema_prefix` on Vibe Modeling, `ecm_schema_prefix` on Vibe ECM +
 * MVM with the base's prefix loaded, `null` to leave it out (Vibe ECM + MVM
 * whose pre-fill failed keeps the form's own ECM prefix).
 */
export function vibeConventionBody(
  effective: Record<PrefillField, EffectiveField>,
  schemaPrefixAs: "schema_prefix" | "ecm_schema_prefix" | null,
): Record<string, string> {
  const body: Record<string, string> = {};
  for (const field of PREFILL_FIELDS) {
    if (field === "org_divisions") continue;
    const value = effective[field].value;
    if (value === null) continue;
    if (field === "schema_prefix") {
      if (schemaPrefixAs) body[schemaPrefixAs] = value;
      continue;
    }
    body[field] = value;
  }
  return body;
}
