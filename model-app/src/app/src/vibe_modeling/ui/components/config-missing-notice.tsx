import { useContext, useEffect } from "react";
import { QueryClientContext } from "@tanstack/react-query";
import { Link } from "@tanstack/react-router";
import { AlertTriangle } from "lucide-react";
import type { ConfigMissingItem } from "@/lib/api-error";
import { FEATURE_CONFIG_KEY, SETTING_FEATURE } from "@/lib/features";

/**
 * The single renderer for the backend's `config_missing` error. Used by the
 * shared `notifyError`/`notifyConfigMissing` path in `lib/notify.ts` (toast)
 * so every config-gated surface - run create/validate, kickstart, download,
 * volume import, resync, initial-sync, oob - renders the SAME thing: the
 * backend's sentence plus one working Settings deep-link per missing item.
 *
 * NOTE: this file intentionally never calls `toast.*` - the toast lives in
 * `lib/notify.ts` (the only site the anti-drift grep guard allows). This is
 * the presentation component; `notifyConfigMissing` wraps it in a toast.
 */

/** Split a `settings_url` like "/settings?tab=platform#feature-taxonomy" into router Link props. */
export function toLinkTarget(url: string): {
  to: string;
  search: Record<string, string>;
  hash?: string;
} {
  const hashAt = url.indexOf("#");
  const beforeHash = hashAt >= 0 ? url.slice(0, hashAt) : url;
  const hash = hashAt >= 0 ? decodeURIComponent(url.slice(hashAt + 1)) : "";
  const queryAt = beforeHash.indexOf("?");
  const path = queryAt >= 0 ? beforeHash.slice(0, queryAt) : beforeHash;
  const query = queryAt >= 0 ? beforeHash.slice(queryAt + 1) : "";
  const search: Record<string, string> = {};
  for (const pair of query.split("&")) {
    if (!pair) continue;
    const [k, v = ""] = pair.split("=");
    if (k) search[decodeURIComponent(k)] = decodeURIComponent(v);
  }
  return { to: path || "/settings", search, ...(hash ? { hash } : {}) };
}

/**
 * An error that names an optional feature's setting means that feature's
 * cached readiness is out of date (the server just recorded a refused test
 * call, or found the setting unset): refetch it, so the gate and the Settings
 * card the link opens show the refusal. Every toast and inline notice of
 * these errors renders here, so this is the one place it happens. Without a
 * query client (a bare test render) there is nothing to refresh.
 */
function useRefreshNamedFeatures(missing: ConfigMissingItem[]) {
  const queryClient = useContext(QueryClientContext);
  const features = [...new Set(missing.map((m) => SETTING_FEATURE[m.key]).filter(Boolean))].sort().join(",");
  useEffect(() => {
    if (!queryClient || !features) return;
    for (const f of features.split(",") as (keyof typeof FEATURE_CONFIG_KEY)[]) {
      void queryClient.invalidateQueries({ queryKey: FEATURE_CONFIG_KEY[f]() });
    }
  }, [queryClient, features]);
}

export function ConfigMissingNotice({
  missing,
  message,
}: {
  missing: ConfigMissingItem[];
  message: string;
}) {
  useRefreshNamedFeatures(missing);
  return (
    <div className="space-y-2" data-testid="config-missing-notice">
      <div className="flex items-start gap-2">
        <AlertTriangle className="h-4 w-4 shrink-0 mt-0.5" />
        <p className="text-sm font-medium">{message}</p>
      </div>
      {missing.length > 0 && (
        <ul className="space-y-1 pl-6 text-sm">
          {missing.map((m) => {
            const target = toLinkTarget(m.settings_url);
            return (
              <li key={m.key} className="flex items-center gap-2">
                <span className="min-w-0">{m.label}</span>
                {/* The router is strongly typed; a runtime-derived path/search
                    pair needs the cast. All config_missing URLs resolve under
                    the /settings route. */}
                <Link
                  to={target.to as never}
                  search={target.search as never}
                  hash={target.hash}
                  className="shrink-0 whitespace-nowrap underline underline-offset-2 hover:opacity-80"
                >
                  Configure
                </Link>
              </li>
            );
          })}
        </ul>
      )}
    </div>
  );
}
