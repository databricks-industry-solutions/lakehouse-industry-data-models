/**
 * Single convergence point for surfacing failures to the user. Every error
 * toast in the app goes through `notifyError()` instead of a raw
 * `toast.error(...)` call - see the anti-drift grep guard in
 * `__tests__/notify.test.tsx`.
 *
 * `notifyError` raises a PERSISTENT toast (`duration: Infinity`, a close
 * button, and a Copy action) so the user can read and copy long/rich error
 * messages instead of watching them auto-dismiss. A `Details` action opens a
 * scrollable, copyable dialog for the full text via a tiny module-level
 * store - `<ErrorDetailsHost/>` (mounted once in `routes/__root.tsx`) reads
 * that store through `useSyncExternalStore`, so no extra dependency is
 * needed for the host/store wiring.
 */
import { createElement, useSyncExternalStore } from "react";
import { toast } from "sonner";
import { apiErrorMessage, parseSettingsError } from "./api-error";
import { ConfigMissingNotice } from "@/components/config-missing-notice";

export interface NotifyErrorOptions {
  /** Headline shown above the detail, e.g. "Delete failed". */
  title?: string;
  /** Fallback message when nothing more specific can be extracted. */
  fallback?: string;
}

let detailsText: string | null = null;
const listeners = new Set<() => void>();

function notifyListeners() {
  for (const l of listeners) l();
}

function subscribe(listener: () => void): () => void {
  listeners.add(listener);
  return () => listeners.delete(listener);
}

function getSnapshot(): string | null {
  return detailsText;
}

/** Push the full error text into the store and open the details dialog. */
export function openDetails(text: string): void {
  detailsText = text;
  notifyListeners();
}

/** Close the details dialog. */
export function closeDetails(): void {
  detailsText = null;
  notifyListeners();
}

/** Hook for `<ErrorDetailsHost/>` - the currently open details text, or `null`. */
export function useErrorDetails(): string | null {
  return useSyncExternalStore(subscribe, getSnapshot);
}

/** Shared clipboard-copy helper - used by `notifyError`'s Copy action and by
 *  `<ErrorDetailsHost/>`'s Copy button, so there's one place that knows how
 *  to report copy success/failure. */
export async function copyToClipboard(text: string): Promise<void> {
  try {
    await navigator.clipboard.writeText(text);
    toast.success("Copied to clipboard");
  } catch {
    toast.error("Couldn't copy to clipboard");
  }
}

/**
 * Raise a persistent, copyable error toast. `input` accepts either a plain
 * message (for sites that already computed one, e.g. reading `data.error`
 * off a successful response body) or a thrown value (an `ApiError`, `Error`,
 * or anything else) - the message is extracted via `apiErrorMessage` in the
 * latter case.
 */
/**
 * If `err` is an error a Settings change fixes (the backend's 422
 * `config_missing`, or a 400 `model_service_refused` / `setting_refused`,
 * read by `parseSettingsError`), raise the shared rich toast (the backend's
 * sentence + one Settings deep-link per setting) and return `true`. Otherwise return `false` so the caller can
 * fall back to its own handling. This is the ONE handler every config-gated
 * surface routes through - do not re-implement config_missing rendering at a
 * call site. `notifyError` calls it too, so any surface already using
 * `notifyError(err)` gets the rich treatment for free.
 */
export function notifyConfigMissing(input: unknown): boolean {
  const cm = parseSettingsError(input);
  if (!cm) return false;
  toast.error(
    createElement(ConfigMissingNotice, { missing: cm.missing, message: cm.message }),
    {
      duration: Infinity,
      closeButton: true,
    },
  );
  return true;
}

export function notifyError(input: string | unknown, opts: NotifyErrorOptions = {}): void {
  if (typeof input !== "string" && notifyConfigMissing(input)) return;
  const detail =
    typeof input === "string" ? input : apiErrorMessage(input, opts.fallback ?? "Request failed");
  toast.error(opts.title ?? detail, {
    description: opts.title ? detail : undefined,
    duration: Infinity,
    closeButton: true,
    action: {
      label: "Copy",
      onClick: () => void copyToClipboard(detail),
    },
    cancel: {
      label: "Details",
      onClick: () => openDetails(detail),
    },
  });
}

/**
 * A warning toast for a request that succeeded with `warnings` (the server's
 * user-facing notes, such as a registry seed that failed): `title` with the
 * warnings as its description. Returns false, showing nothing, when there are
 * none, so the caller can show its own success.
 */
export function notifyWarnings(title: string, warnings: readonly string[] | null | undefined): boolean {
  const list = (warnings ?? []).filter((w) => w.trim());
  if (!list.length) return false;
  toast.warning(title, { description: list.join(" ") });
  return true;
}
