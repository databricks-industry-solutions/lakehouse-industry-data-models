/**
 * Run-intent / agent-operation mapping helpers.
 *
 * The ``Intent`` slug values come from the Orval-generated enum in
 * ``lib/api.ts`` (auto-derived from the OpenAPI spec, which is sourced
 * from ``backend/models.py:Intent``). This module owns the FE-side
 * mappings to and from the agent-side operation strings the legacy form
 * Select still uses ("new base model", "vibe modeling of version", …).
 *
 * Drift-unification (Phase 7, Item 5): the agent-op strings are the same
 * vocabulary as ``backend/core/_intents.py:INTENT_TO_AGENT_OP``. Keep them in
 * sync — anywhere a string literal matches an entry below, prefer
 * ``intentToRunType`` / ``runTypeToIntent`` so a future rename only has
 * to touch one place.
 */
import { Intent } from "@/lib/api";

/**
 * ``Run.intent`` of the audit run a kickstart-from-industry writes
 * (``services/industry_kickstart.py``). Not part of the generated ``Intent``
 * enum: it is a label on a run no user starts.
 */
export const KICKSTART_RUN_INTENT = "kickstart-from-industry";

/** ``Run.intent`` of the audit run an industry download writes. */
export const DOWNLOAD_RUN_INTENT = "download-industry";

/** ``Run.intent`` of the audit run an orphan-schema drop writes
 *  (``services/orphan_schemas.ORPHAN_DROP_INTENT``). */
export const ORPHAN_DROP_RUN_INTENT = "uninstall-orphan-schemas";

/**
 * Runs that work inside the app and dispatch no agent job (the backend's
 * ``routes/_helpers.AUDIT_INTENTS``; both sides are tested against
 * ``tests/fixtures/setup_run_intents.json``). Cancelling one only marks it
 * cancelled: there is no job to stop.
 */
export const SETUP_RUN_INTENTS: ReadonlySet<string> = new Set([
  KICKSTART_RUN_INTENT,
  DOWNLOAD_RUN_INTENT,
  ORPHAN_DROP_RUN_INTENT,
]);

export function isSetupRunIntent(intent: string | null | undefined): boolean {
  return !!intent && SETUP_RUN_INTENTS.has(intent);
}

/** Display labels of the app-only run intents (not in the ``Intent`` enum). */
export const APP_RUN_LABELS: Record<string, string> = {
  [KICKSTART_RUN_INTENT]: "Kickstart from industry",
  [DOWNLOAD_RUN_INTENT]: "Download industry",
  [ORPHAN_DROP_RUN_INTENT]: "Drop orphan schemas",
};

/** Whether the run page offers Retry for a failed or cancelled run of this
 *  intent. The backend refuses retry and resume of an orphan-schema drop
 *  (``router._refuse_app_only_retry``). */
export function canRetryRunIntent(intent: string | null | undefined): boolean {
  return intent !== ORPHAN_DROP_RUN_INTENT;
}

/** Display label for each intent slug. Used by ``intentLabel``. */
export const INTENT_LABELS: Record<Intent, string> = {
  "new-base-model": "New base model",
  "vibe-iterate": "Vibe iterate",
  "vibe-new-ecm-mvm": "Vibe ECM + MVM",
  install: "Install model",
  uninstall: "Uninstall model",
  "generate-samples": "Generate samples",
  "import-from-volume": "Import from volume",
  revert: "Revert version",
};

/**
 * FE Select value (legacy human-readable agent-op vocabulary) for each
 * Intent slug. The Select is the FE-only contract — it pre-existed the
 * orchestrator refactor and the labels were already reviewed/translated.
 * The BE has a *similar* map (``backend/core/_intents.py:INTENT_TO_AGENT_OP``)
 * for agent-side operation tagging on multi-step pipelines, but it
 * collapses ``vibe-new-ecm-mvm`` onto ``"vibe modeling of version"``
 * (because the lead step IS the vibe op). The FE keeps the standalone
 * ``"vibe new ecm + mvm"`` Select value because users distinguish the
 * two flows visually.
 */
export const INTENT_TO_AGENT_OP: Record<Intent, string> = {
  "new-base-model": "new base model",
  "vibe-iterate": "vibe modeling of version",
  "vibe-new-ecm-mvm": "vibe new ecm + mvm",
  install: "install model",
  uninstall: "uninstall model version",
  "generate-samples": "generate sample data",
  revert: "revert model version",
  "import-from-volume": "import model version",
};

/** Reverse of ``INTENT_TO_AGENT_OP`` — derived once at module load. */
const AGENT_OP_TO_INTENT: Record<string, Intent> = (() => {
  const map: Record<string, Intent> = {};
  for (const [intent, op] of Object.entries(INTENT_TO_AGENT_OP) as [
    Intent,
    string,
  ][]) {
    map[op] = intent;
  }
  return map;
})();

/**
 * Render an intent slug as a human-friendly label: the run-form intents,
 * then the app-only ones. Falls back to the raw slug if it isn't in either
 * map so a newly-added intent shows up verbatim rather than as an empty
 * string.
 */
export const intentLabel = (intent: string | null | undefined): string =>
  intent ? (INTENT_LABELS[intent as Intent] ?? APP_RUN_LABELS[intent] ?? intent) : "";

/**
 * Translate a legacy ``run_type`` Select value (agent-side wording,
 * e.g. ``"new base model"``) into the canonical Intent slug
 * (``"new-base-model"``). Empty string for unknown values so a typo
 * lights up as a downstream validation failure rather than a silent
 * default.
 */
export function runTypeToIntent(runType: string): string {
  return AGENT_OP_TO_INTENT[runType] ?? "";
}

/**
 * Reverse of ``runTypeToIntent`` — converts an Intent slug
 * (``"vibe-iterate"``) back into the human-readable run_type Select
 * value (``"vibe modeling of version"``). Used when normalising the
 * ``operationType`` URL param (callers may pass either form). Unknown
 * values are returned as-is so a typo lights up as an empty Select
 * rather than silently coerced.
 */
export function intentToRunType(value: string): string {
  return INTENT_TO_AGENT_OP[value as Intent] ?? value;
}
