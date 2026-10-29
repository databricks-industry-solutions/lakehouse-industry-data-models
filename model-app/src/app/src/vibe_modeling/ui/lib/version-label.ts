/**
 * Single source of truth for the `v{n}` / `v{n} {SCOPE}` version label; don't inline
 * `scope ? ... : ...` ternaries.
 * Returns "v{version}" when scope is empty/null/undefined.
 * Returns "v{version} {SCOPE}" (uppercase) when scope is provided.
 * The backend builds the same label in `backend/router.py:1875`; keep empty-scope
 * behavior in sync.
 */
export function versionScopeLabel(
  version: number | string,
  scope?: string | null,
): string {
  if (!scope) {
    return `v${version}`;
  }
  return `v${version} ${scope.toUpperCase()}`;
}

/**
 * Brand badge text for a version row: "Base", "Vibed", or "Vibed (parent
 * deleted)" for a shrink/enlarge output whose lineage parent was deleted.
 * The backend decides `is_base` and `parent_deleted` (`explorer.py`
 * `_version_brands`); don't recompute them from `base_version_id`.
 */
export function versionBrandLabel(v: {
  is_base?: boolean;
  parent_deleted?: boolean;
}): string {
  if (v.is_base) {
    return "Base";
  }
  return v.parent_deleted ? "Vibed (parent deleted)" : "Vibed";
}
