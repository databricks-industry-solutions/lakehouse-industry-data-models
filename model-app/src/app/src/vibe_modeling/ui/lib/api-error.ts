/**
 * Helpers for surfacing useful messages from the auto-generated `ApiError`
 * thrown by `lib/api.ts`. The default `err.message` is just
 * `"HTTP 422: Unprocessable Entity"`, which is technically correct but
 * useless to the user. The actual diagnostic — Pydantic validation msgs,
 * FastAPI's `detail` string, or a custom error body — sits on `err.body`.
 *
 * Use `apiErrorMessage(err)` (via `notifyError` in `lib/notify.ts`) at any
 * site that catches an `ApiError`. Falls back gracefully through the layers:
 *   1. FastAPI/Pydantic detail array → join the `msg` fields.
 *   2. FastAPI `{detail: "string"}` → return the string.
 *   3. Other Error → `err.message`.
 *   4. Anything else → a stable fallback string.
 */
import { ApiError } from "@/lib/api";
import { featureSettingsUrl, SETTING_FEATURE } from "@/lib/features";

type PydanticErrorEntry = {
  msg?: string;
  loc?: unknown[];
};

function isPydanticErrorArray(v: unknown): v is PydanticErrorEntry[] {
  return (
    Array.isArray(v) &&
    v.length > 0 &&
    typeof v[0] === "object" &&
    v[0] !== null &&
    "msg" in (v[0] as object)
  );
}

/**
 * Unwrap an `ApiError`'s body-or-detail envelope: the backend's error payload
 * may arrive either as the body directly (`{ error, ... }` / `{ message, ... }`)
 * or wrapped under FastAPI's `detail` (`{ detail: { error, ... } }`). Both
 * `parse409` and `apiErrorMessage` need this same unwrap, so it lives in one
 * place - the single site that knows about the two possible shapes.
 *
 * Returns the inner record (either `body` itself or `body.detail`) when it's
 * an object, or `null` when there's nothing object-shaped to read.
 */
function unwrapEnvelope(err: ApiError): Record<string, unknown> | null {
  const body = err.body;
  if (!body || typeof body !== "object") return null;
  const record = body as Record<string, unknown>;
  if ("detail" in record && record.detail && typeof record.detail === "object") {
    return record.detail as Record<string, unknown>;
  }
  return record;
}

/**
 * Parse a 409 conflict `ApiError` into its typed error body, or `null` when it
 * isn't a 409 carrying the expected `error` discriminator.
 *
 * Unwraps the body-or-detail envelope via `unwrapEnvelope` and verifies
 * `error === errorLiteral` before returning the candidate record cast to `T`.
 * Callers own any further field coercion (e.g. reading a numeric count off
 * the returned object).
 */
export function parse409<T extends { error: string }>(
  err: unknown,
  errorLiteral: T["error"],
): T | null {
  if (!(err instanceof ApiError) || err.status !== 409) return null;
  const candidate = unwrapEnvelope(err);
  if (!candidate || candidate.error !== errorLiteral) return null;
  return candidate as unknown as T;
}

/**
 * The backend's `admin_help` error detail: an assessment failure only an
 * administrator can fix. `message` is the error text; the links and the
 * reader are present only when the backend knows them, and `not_ready` lists
 * the setup reasons on a launch refused because the feature isn't ready.
 */
export interface AdminHelp {
  message: string;
  job_url?: string;
  run_url?: string;
  runs_path?: string;
  job_reader?: string;
  not_ready?: string[];
}

const optionalText = (v: unknown): string | undefined =>
  typeof v === "string" && v.trim() ? v : undefined;

/**
 * Parse an `ApiError` into its `admin_help` detail, or `null` when it isn't
 * one. Keys on the `error === "admin_help"` discriminator (the backend sends
 * it with 409, `core/_errors.admin_help_error`; the status is not checked)
 * through the shared `unwrapEnvelope`.
 * An empty `message` falls back to the HTTP-level message: `apiErrorMessage`
 * would return the `error` discriminator itself.
 */
export function parseAdminHelp(err: unknown): AdminHelp | null {
  if (!(err instanceof ApiError)) return null;
  const envelope = unwrapEnvelope(err);
  if (!envelope || envelope.error !== "admin_help") return null;
  const notReady = Array.isArray(envelope.not_ready)
    ? envelope.not_ready.filter((m): m is string => typeof m === "string" && m.trim() !== "")
    : [];
  return {
    message: optionalText(envelope.message) ?? err.message,
    job_url: optionalText(envelope.job_url),
    run_url: optionalText(envelope.run_url),
    runs_path: optionalText(envelope.runs_path),
    job_reader: optionalText(envelope.job_reader),
    ...(notReady.length ? { not_ready: notReady } : {}),
  };
}

/**
 * A plain 409 `{message}` with no `error` discriminator (e.g. two requests
 * changed the same next vibe at once): the message to show inline with a
 * Try again, or `null` for anything else. `parseAdminHelp` returns null for
 * these, so they never render as an admin-help block.
 */
export function parsePlainConflict(err: unknown): string | null {
  if (!(err instanceof ApiError) || err.status !== 409) return null;
  const envelope = unwrapEnvelope(err);
  if (!envelope || "error" in envelope) return null;
  return optionalText(envelope.message) ?? null;
}

/** One missing configuration entry from a `config_missing` 422 payload. */
export interface ConfigMissingItem {
  key: string;
  label: string;
  settings_url: string;
}

/**
 * The backend's structured `config_missing` error, emitted with a 422 across
 * every config-gated surface (run create/validate, kickstart, download, volume
 * import, resync, initial-sync, oob). Shape:
 *   { detail: { error: "config_missing", missing: [{key,label,settings_url}], message } }
 */
export interface ConfigMissing {
  error: "config_missing";
  missing: ConfigMissingItem[];
  message: string;
}

/**
 * Parse an `ApiError` into its `config_missing` payload, or `null` when it
 * isn't one. Reuses `unwrapEnvelope` so the same body-or-`detail` unwrap that
 * `apiErrorMessage`/`parse409` use applies here - the single site that knows
 * the two envelope shapes. Deliberately does NOT gate on the HTTP status: the
 * discriminator (`error === "config_missing"`) is authoritative and the status
 * is a consistent 422 across surfaces.
 */
export function parseConfigMissing(err: unknown): ConfigMissing | null {
  if (!(err instanceof ApiError)) return null;
  const envelope = unwrapEnvelope(err);
  if (!envelope || envelope.error !== "config_missing") return null;
  const rawMissing = Array.isArray(envelope.missing) ? envelope.missing : [];
  const missing: ConfigMissingItem[] = rawMissing
    .filter((m): m is Record<string, unknown> => !!m && typeof m === "object")
    .map((m) => ({
      key: String(m.key ?? ""),
      label: String(m.label ?? m.key ?? ""),
      settings_url: String(m.settings_url ?? "/settings"),
    }));
  const message =
    typeof envelope.message === "string" && envelope.message.trim()
      ? envelope.message
      : "Required configuration is missing.";
  return { error: "config_missing", missing, message };
}

/**
 * The backend's 400 refusal of a setting's value, from a Save check or a
 * feature call: `model_service_refused` (the model service failed its test
 * call; `status` is `denied` / `not_found` / `error`) or `setting_refused`
 * (any other setting, e.g. a reader that does not exist). `key` names the
 * setting. Shape:
 *   { detail: { error, key, message, status? } }
 */
export interface SettingRefused {
  error: "model_service_refused" | "setting_refused";
  key: string;
  message: string;
  status?: string;
}

const REFUSED_ERRORS = new Set<string>(["model_service_refused", "setting_refused"]);

/**
 * Parse an `ApiError` into its setting refusal, or `null` when it isn't one.
 * Keys on the discriminator, like `parseConfigMissing`.
 */
export function parseSettingRefused(err: unknown): SettingRefused | null {
  if (!(err instanceof ApiError)) return null;
  const envelope = unwrapEnvelope(err);
  if (!envelope || typeof envelope.error !== "string" || !REFUSED_ERRORS.has(envelope.error)) return null;
  return {
    error: envelope.error as SettingRefused["error"],
    key: typeof envelope.key === "string" ? envelope.key : "",
    message: optionalText(envelope.message) ?? err.message,
    ...(typeof envelope.status === "string" ? { status: envelope.status } : {}),
  };
}

/**
 * Where each refusable setting is changed: its feature's card in Settings →
 * Platform, Optional features (`lib/features.featureSettingsUrl`). A refusal
 * carries only its `key`. The `taxonomy_llm` link adds the card's
 * `#feature-taxonomy` anchor to the backend's `core/_errors.CONFIG_REQUIREMENTS`
 * URL (`/settings?tab=platform`); `parseSettingsError` adds it to a
 * `config_missing` item of a feature setting too.
 */
export const REFUSED_SETTING_LOCATIONS: Readonly<Record<string, { label: string; settings_url: string }>> = {
  taxonomy_llm: { label: "Domain Taxonomy Builder model service", settings_url: featureSettingsUrl(SETTING_FEATURE.taxonomy_llm) },
  reader_application_id: { label: "Assessment reader service principal", settings_url: featureSettingsUrl(SETTING_FEATURE.reader_application_id) },
  warehouse_id: { label: "Assessment SQL warehouse", settings_url: featureSettingsUrl(SETTING_FEATURE.warehouse_id) },
};

/** A settings error the user fixes in Settings: its sentence and the Settings links that fix it. */
export interface SettingsError {
  message: string;
  missing: ConfigMissingItem[];
  /** The refused setting's key; null for `config_missing`. */
  refusedKey: string | null;
}

/**
 * The one reader for every error a Settings change fixes: 422
 * `config_missing` (its own links; a feature setting's link without an anchor
 * gets its card's) and the 400 refusals (`model_service_refused`,
 * `setting_refused`; the link from `REFUSED_SETTING_LOCATIONS`). `null` for
 * anything else.
 */
export function parseSettingsError(err: unknown): SettingsError | null {
  const cm = parseConfigMissing(err);
  if (cm) {
    const missing = cm.missing.map((m) =>
      SETTING_FEATURE[m.key] && !m.settings_url.includes("#")
        ? { ...m, settings_url: featureSettingsUrl(SETTING_FEATURE[m.key]) }
        : m,
    );
    return { message: cm.message, missing, refusedKey: null };
  }
  const refused = parseSettingRefused(err);
  if (!refused) return null;
  const where = REFUSED_SETTING_LOCATIONS[refused.key];
  return {
    message: refused.message,
    missing: [{ key: refused.key, label: where?.label ?? refused.key, settings_url: where?.settings_url ?? "/settings" }],
    refusedKey: refused.key,
  };
}

/** One subject-bound `confirm` issue of a `needs_confirmation` 422. */
export interface ConfirmIssue {
  subject: string;
  message: string;
  field_path: string;
  /** The version numbers the issue names (`IssueOut.versions`). */
  versions: number[];
}

/**
 * The backend's `needs_confirmation` error from `POST /runs`: the run changes
 * something the request did not confirm. Shape:
 *   { detail: { error: "needs_confirmation", issues: [IssueOut], message } }
 * `issues` holds every confirm issue the run needs, confirmed or not, so a
 * dialog re-renders from them. `message` is cut at 500 characters by the
 * error handler; render `issues`, never `message`.
 */
export interface NeedsConfirmation {
  error: "needs_confirmation";
  issues: ConfirmIssue[];
}

/**
 * Parse an `ApiError` into its `needs_confirmation` payload, or `null` when it
 * isn't one. Keys on the discriminator, beside `parseConfigMissing`. Issues
 * without a subject are dropped: nothing can confirm them.
 */
export function parseNeedsConfirmation(err: unknown): NeedsConfirmation | null {
  if (!(err instanceof ApiError)) return null;
  const envelope = unwrapEnvelope(err);
  if (!envelope || envelope.error !== "needs_confirmation") return null;
  const raw = Array.isArray(envelope.issues) ? envelope.issues : [];
  const issues: ConfirmIssue[] = raw
    .filter((i): i is Record<string, unknown> => !!i && typeof i === "object")
    .filter((i) => typeof i.subject === "string" && i.subject !== "")
    .map((i) => ({
      subject: String(i.subject),
      message: String(i.message ?? ""),
      field_path: String(i.field_path ?? ""),
      versions: Array.isArray(i.versions) ? i.versions.filter((n): n is number => typeof n === "number") : [],
    }));
  return { error: "needs_confirmation", issues };
}

/**
 * Whether a thrown value represents an HTTP 404. Matches either the structured
 * `ApiError` (`.status === 404`), any object carrying a numeric `status` of
 * 404, or an `Error` whose message contains a standalone `404` (the `HTTP 404`
 * string formatting older fetch sites still use). The single 404 predicate for
 * every route that wants to render a friendly not-found instead of the generic
 * error boundary.
 */
export function isNotFoundError(error: unknown): boolean {
  if (error instanceof ApiError && error.status === 404) return true;
  if (error && typeof error === "object" && "status" in error) {
    if ((error as { status?: unknown }).status === 404) return true;
  }
  if (error instanceof Error && /\b404\b/.test(error.message)) return true;
  return false;
}

export function apiErrorMessage(err: unknown, fallback = "Request failed"): string {
  if (err instanceof ApiError) {
    const body = err.body as { detail?: unknown } | null;
    const detail = body?.detail;
    if (typeof detail === "string" && detail.trim()) {
      return detail;
    }
    if (isPydanticErrorArray(detail)) {
      // Join up to 3 validation messages so the toast stays compact.
      const msgs = detail
        .slice(0, 3)
        .map((e) => e.msg)
        .filter((m): m is string => typeof m === "string" && m.length > 0);
      if (msgs.length > 0) {
        return msgs.join("; ");
      }
    }
    // Object-shaped detail (or body) - e.g. a 409 conflict payload like
    // `{ message: "sector in use by 3 businesses" }` or `{ error: "..." }`.
    // Prefer `message`, then `error`, before falling back to the HTTP-level
    // message. Without this, object-detail 409s regress to "HTTP 409: Conflict".
    const envelope = unwrapEnvelope(err);
    if (envelope) {
      if (typeof envelope.message === "string" && envelope.message.trim()) {
        return envelope.message;
      }
      if (typeof envelope.error === "string" && envelope.error.trim()) {
        return envelope.error;
      }
    }
    // ApiError but no useful body → fall back to the HTTP-level message.
    return err.message || fallback;
  }
  if (err instanceof Error && err.message) {
    return err.message;
  }
  return fallback;
}
