/**
 * What a model version is in the "dry run, review, install" lifecycle, read
 * from the stored `ModelVersionOut` columns (design §1: `dry_run`,
 * `promoted_at`, `replaced_at` / `replaced_by_version_id`, `draft_state`,
 * `is_head`), and which actions its page offers.
 *
 * The backend decides; these helpers only label. The version page, the
 * explorer list and the install dialog share them so the labels agree.
 */
import type { ModelVersionOut } from "@/lib/api";
import { andList } from "@/lib/comma-list";
import { formatDate } from "@/lib/date";
import { versionScopeLabel } from "@/lib/version-label";

/** The version fields the helpers read. */
export type LifecycleVersion = Pick<
  ModelVersionOut,
  | "id"
  | "version"
  | "scope"
  | "status"
  | "deployment_status"
  | "uc_catalog"
  | "files_catalog"
  | "dry_run"
  | "promoted_at"
  | "replaced_at"
  | "replaced_by_version_id"
  | "draft_state"
  | "is_head"
>;

/** A draft nobody installed yet: `status` draft, the backend's
 *  `_version_lifecycle.is_draft` (today only a Dry Run writes one). */
export function isDryRunDraft(v: LifecycleVersion): boolean {
  return v.status === "draft";
}

/** `replaced_at` is the flag (design §1 data model); the pointer may be gone. */
export function isReplaced(v: Pick<LifecycleVersion, "replaced_at">): boolean {
  return Boolean(v.replaced_at);
}

export function isInstalled(v: LifecycleVersion): boolean {
  return v.deployment_status === "deployed";
}

/** The backend's `_version_lifecycle._MODEL_STATUSES`: real models. */
const MODEL_STATUSES = new Set(["completed", "superseded"]);

/** A finished, non-draft model: `completed` or `superseded`. */
export function isModelVersion(v: Pick<LifecycleVersion, "status">): boolean {
  return MODEL_STATUSES.has(v.status);
}

function sameScope(a: LifecycleVersion, b: LifecycleVersion): boolean {
  return (a.scope || "") === (b.scope || "");
}

/** "v3" of the version that replaced `v`, or null when that row is gone. */
export function replacedByLabel(
  v: Pick<LifecycleVersion, "replaced_by_version_id">,
  versions: readonly Pick<LifecycleVersion, "id" | "version">[],
): string | null {
  if (!v.replaced_by_version_id) return null;
  const by = versions.find((o) => o.id === v.replaced_by_version_id);
  return by ? `v${by.version}` : null;
}

/** "Replaced by v3" (or "Replaced" when that row is gone) for a replaced
 *  version, or null. The explorer badge and the run form's Base Version picker
 *  share it. */
export function replacedBadgeLabel(
  v: Pick<LifecycleVersion, "replaced_at" | "replaced_by_version_id">,
  versions: readonly Pick<LifecycleVersion, "id" | "version">[],
): string | null {
  if (!isReplaced(v)) return null;
  const by = replacedByLabel(v, versions);
  return by ? `Replaced by ${by}` : "Replaced";
}

/** "Replaced by v3 on <date>" for the version header, or null. */
export function replacedHeader(
  v: LifecycleVersion,
  versions: readonly LifecycleVersion[],
): string | null {
  if (!isReplaced(v)) return null;
  const by = replacedByLabel(v, versions);
  const when = formatDate(v.replaced_at ?? null, "");
  return `Replaced${by ? ` by ${by}` : ""}${when ? ` on ${when}` : ""}`;
}

export interface VersionBadge {
  label: string;
  /** `muted` for provenance that no longer changes what the version is. */
  tone: "draft" | "replaced" | "muted";
}

/** The lifecycle badges of a version row (design §1 UI, version list). */
export function versionLifecycleBadges(
  v: LifecycleVersion,
  versions: readonly LifecycleVersion[],
): VersionBadge[] {
  const out: VersionBadge[] = [];
  if (isDryRunDraft(v)) {
    out.push({
      label: v.draft_state === "older_base" ? "Dry Run (older base)" : "Dry Run",
      tone: "draft",
    });
  }
  const replaced = replacedBadgeLabel(v, versions);
  if (replaced) out.push({ label: replaced, tone: "replaced" });
  if (v.dry_run && v.promoted_at && !isDryRunDraft(v)) {
    out.push({ label: "from Dry Run", tone: "muted" });
  }
  return out;
}

/**
 * When installing an older or replaced version makes it the latest
 * (backend `_version_lifecycle.will_promote`): into a catalog the latest
 * version is installed in, or when the latest is installed nowhere.
 */
export function promotionRuleText(label: string): string {
  return `Where the latest version is installed (or when it is installed nowhere), ${label} becomes the latest version.`;
}

/**
 * The version page's install action, or null when the version cannot be
 * installed (failed, still generating). An older or replaced version is made
 * current by installing it (design §1 B1).
 */
export function installActionLabel(v: LifecycleVersion): string | null {
  if (isDryRunDraft(v)) return "Install this Dry Run";
  if (v.status === "failed" || v.status === "generating") return null;
  if (isReplaced(v) || v.status === "superseded") return "Make this version current";
  return isInstalled(v) ? "Re-install" : "Install";
}

/**
 * Where an install of `v` goes when the user picks nothing (design §1 B3):
 * where it is installed, else where its files are. Empty lets the server
 * resolve the configured catalog.
 */
export function defaultInstallCatalog(v: LifecycleVersion): string {
  if (isInstalled(v) && v.uc_catalog) return v.uc_catalog;
  return v.files_catalog || v.uc_catalog || "";
}

export interface DeleteState {
  /** Button label. */
  label: string;
  allowed: boolean;
  /** Why it is refused, when it is. */
  reason?: string;
  /** Refused because it is installed: the page offers Uninstall. */
  installed?: boolean;
  /** The newer versions to delete first (also when installed: uninstalling
   *  does not lift that refusal). Absent when there are none. */
  newerVersions?: number[];
}

/** `delete_refusal`'s second rule: the newer real, not replaced versions of
 *  the scope above a real, not replaced `v` (superseded, or a legacy second
 *  completed row). */
function newerLiveVersions(v: LifecycleVersion, versions: readonly LifecycleVersion[]): number[] {
  if (!MODEL_STATUSES.has(v.status) || isReplaced(v)) return [];
  return versions
    .filter((o) => sameScope(o, v) && o.id !== v.id && o.version > v.version)
    .filter((o) => MODEL_STATUSES.has(o.status) && !isReplaced(o))
    .map((o) => o.version)
    .sort((a, b) => a - b);
}

/**
 * Whether the version page offers Delete, with what label (add §6.1 rules,
 * the server's `_version_lifecycle.delete_refusal` refuses the same cases
 * with 409). "Installed" is `deployment_status`: the server mirrors every
 * open install row into it (`_mirror_open_rows`), so a version installed in
 * any catalog reads `deployed` in the list too.
 */
export function deleteState(
  v: LifecycleVersion,
  versions: readonly LifecycleVersion[],
): DeleteState {
  const label = isDryRunDraft(v)
    ? "Delete draft"
    : isReplaced(v)
      ? "Delete replaced version"
      : "Delete this version";
  const newer = newerLiveVersions(v, versions);
  const newerList = newer.map((n) => `v${n}`).join(", ");
  const withNewer = newer.length > 0 ? { newerVersions: newer } : {};
  if (isInstalled(v)) {
    const where = v.uc_catalog ? ` in ${v.uc_catalog}` : "";
    const steps =
      newer.length > 0
        ? `Uninstall it first, then delete the newer versions (${newerList}), then delete it.`
        : "Uninstall it first, then delete it.";
    return {
      label,
      allowed: false,
      installed: true,
      reason: `${versionScopeLabel(v.version, v.scope)} is installed${where}. ${steps}`,
      ...withNewer,
    };
  }
  if (newer.length > 0) {
    return {
      label,
      allowed: false,
      reason: `Delete the newer versions first (${newerList}).`,
      ...withNewer,
    };
  }
  return { label, allowed: true };
}

/** "v4", "v4 and v5", "v3, v4 and v5". */
export function versionsPhrase(numbers: readonly number[]): string {
  return andList([...numbers].sort((a, b) => a - b).map((n) => `v${n}`));
}

/** The kind of a confirm subject: `install_over_newer:<id>` -> `install_over_newer`. */
export function subjectKind(subject: string): string {
  return subject.split(":")[0] ?? "";
}

/** The version id a subject is bound to (its first part after the kind). */
export function subjectVersionId(subject: string): string | null {
  return subject.split(":")[1] || null;
}

/**
 * The rows of the versions a `vibe_scope_base` blocker names (B10: "The
 * agent refuses scoped runs on v3 while v4 and v5 are in its registry in
 * X"), from the blocker's `versions`, limited to replaced versions and
 * drafts of the base's scope, newest first. The "Delete v4 and v5" action
 * never deletes a version the server did not name.
 */
export function blockerVersionsToDelete<T extends LifecycleVersion>(
  named: readonly number[],
  versions: readonly T[],
  scope: string | null | undefined,
): T[] {
  const wanted = new Set(named);
  return versions
    .filter((v) => (v.scope || "") === (scope || "") && wanted.has(v.version))
    .filter((v) => isReplaced(v) || v.status === "draft")
    .sort((a, b) => b.version - a.version);
}
