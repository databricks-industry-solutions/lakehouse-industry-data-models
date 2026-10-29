/**
 * Centralized metadata for run operations: the single source of truth for
 * user-facing labels and descriptions used by the run-launch confirmation
 * dialog, and for the help page of each run (`helpSlug`).
 *
 * Keyed on the `OperationType` string values from the generated API client
 * (`src/app/src/vibe_modeling/ui/lib/api.ts`). We intentionally type the
 * keys as plain strings rather than the generated union so this file never
 * becomes a merge conflict with the generated client when ops are added.
 */

import type { Intent } from "@/lib/api";
import { runTypeToIntent } from "@/lib/intent";

export interface OperationMetadata {
  label: string;
  description: string;
}

const NEW_BASE_MODEL: OperationMetadata = {
  label: "New Base Model",
  description: "Generates ECM + MVM + installs both. Full unified pipeline.",
};
const VIBE_ITERATE: OperationMetadata = {
  label: "Vibe Version",
  description: "Re-models from your vibe feedback.",
};
const VIBE_NEW_ECM_MVM: OperationMetadata = {
  label: "Vibe ECM + MVM",
  description: "Re-models an ECM from your vibe feedback, then shrinks it to a new MVM.",
};
const SHRINK: OperationMetadata = {
  label: "Shrink to MVM",
  description: "Reduces ECM to minimum viable model.",
};
const ENLARGE: OperationMetadata = {
  label: "Enlarge to ECM",
  description: "Expands MVM back to ECM.",
};
const INSTALL: OperationMetadata = {
  label: "Install model",
  description: "Installs schemas to Unity Catalog.",
};
const UNINSTALL: OperationMetadata = {
  label: "Uninstall version",
  description: "Drops schemas from Unity Catalog.",
};
const GENERATE_SAMPLES: OperationMetadata = {
  label: "Generate samples",
  description: "Populates 10 rows per installed table.",
};

/**
 * Keyed by both the legacy human-readable run_type strings (still used by
 * the New Run form's Select) and the canonical Intent slugs (used by the
 * actions card on the model-version page after Phase 5). Either side
 * resolves to the same metadata object.
 */
export const OPERATION_METADATA: Record<string, OperationMetadata> = {
  // Legacy human-readable run_type values (form Select).
  "new base model": NEW_BASE_MODEL,
  "vibe modeling of version": VIBE_ITERATE,
  "vibe new ecm + mvm": VIBE_NEW_ECM_MVM,
  "shrink ecm": SHRINK,
  "enlarge mvm": ENLARGE,
  "install model": INSTALL,
  "uninstall model version": UNINSTALL,
  "generate sample data": GENERATE_SAMPLES,
  // Canonical Intent slugs (post-Phase-5 wire format).
  "new-base-model": NEW_BASE_MODEL,
  "vibe-iterate": VIBE_ITERATE,
  "vibe-new-ecm-mvm": VIBE_NEW_ECM_MVM,
  shrink: SHRINK,
  enlarge: ENLARGE,
  install: INSTALL,
  uninstall: UNINSTALL,
  "generate-samples": GENERATE_SAMPLES,
};

/**
 * Fallback metadata for operations not in the map — keeps the dialog
 * functional even if the API adds a new op before the UI ships a label.
 */
export function getOperationMetadata(op: string): OperationMetadata {
  return (
    OPERATION_METADATA[op] ?? {
      label: op,
      description: "This run will consume Databricks compute.",
    }
  );
}

/**
 * The help topic (`/help/<slug>`) of each run intent. Typed over the
 * generated `Intent` union, so a new intent fails `tsc` until it has a page.
 * Generate Samples and Revert are retired; their rows are on the run-types page.
 */
export const INTENT_HELP_SLUGS: Record<Intent, string> = {
  "new-base-model": "run-new-base-model",
  "vibe-iterate": "run-vibe",
  "vibe-new-ecm-mvm": "run-vibe-ecm-mvm",
  install: "run-install",
  uninstall: "run-uninstall",
  "import-from-volume": "import",
  revert: "runs",
  "generate-samples": "runs",
};

/** The operations this form launches. */
export const FORM_OPERATIONS: readonly string[] = [
  "new base model",
  "vibe modeling of version",
  "vibe new ecm + mvm",
];

/** Case-insensitive, with hyphens, underscores and spaces equivalent. */
export function normalizeOperationParam(value: string): string {
  return value.trim().toLowerCase().replace(/[-_\s]+/g, " ");
}

/** The form operation a deep link names, by OperationType value or Intent
 *  slug, with the same normalization as the removed operations. */
export function formOperationFromParam(value: string): string {
  const wanted = normalizeOperationParam(value);
  return (
    FORM_OPERATIONS.find(
      (op) =>
        normalizeOperationParam(op) === wanted
        || normalizeOperationParam(runTypeToIntent(op)) === wanted,
    ) ?? ""
  );
}

/**
 * The help topic for an operation, given as an Intent slug or as the New Run
 * form's operation value ("vibe modeling of version"). Unknown operations get
 * the run-types page.
 */
export function helpSlug(op: string): string {
  const own = (key: string): key is Intent => Object.prototype.hasOwnProperty.call(INTENT_HELP_SLUGS, key);
  const intent = own(op) ? op : runTypeToIntent(op);
  return own(intent) ? INTENT_HELP_SLUGS[intent] : "runs";
}

/** A run step that uninstalls a version of another business: the source
 *  industry's version a kickstarted business's install or Full Run removes
 *  (or, already replaced, only releases) first. Its `parent_version_id` is
 *  that version's, so it is never the run's source or its occupant. */
export function isForeignUninstall(
  op: { operation_name: string; parent_version_id?: string | null },
  ownVersionIds: { has(id: string): boolean },
): boolean {
  return op.operation_name === "uninstall" && !!op.parent_version_id && !ownVersionIds.has(op.parent_version_id);
}
