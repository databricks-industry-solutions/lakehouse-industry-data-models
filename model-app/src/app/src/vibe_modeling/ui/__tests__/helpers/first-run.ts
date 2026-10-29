/**
 * Canonical "first-run" workspace fixtures.
 *
 * On a fresh install (no agent config, no businesses, no industries…)
 * almost every page renders a different banner / empty state / gate.
 * Phase 4.5 bug 2 was an infinite render loop on this exact path.
 *
 * Each fixture is a `fetch` stub keyed by URL substring. Pass
 * `firstRunFetcher()` to `vi.stubGlobal("fetch", …)` to make every API
 * the page might call answer like an empty workspace would. Override
 * specific endpoints by passing extra entries to the spread.
 */
import { vi } from "vitest";

/** What the generated client reads from a response: `json()` on success, `text()` and `statusText` on any non-2xx. */
export interface StubResponse {
  ok: boolean;
  status: number;
  statusText: string;
  json: () => Promise<unknown>;
  text: () => Promise<string>;
}

type FetchHandler = (url: string, init?: RequestInit) => Promise<StubResponse>;

export interface FirstRunOverrides {
  /** Per-URL-substring overrides. Longest match wins. */
  [urlFragment: string]: FetchHandler | { status: number; body?: unknown };
}

/**
 * The one builder for stubbed fetch responses, so every stub answers both read
 * paths of the generated client. A hand-written `{ ok: false, status, json }`
 * lacks `text()`, which the client calls on every non-2xx response, and the
 * resulting TypeError surfaces outside the test.
 */
export const jsonResponse = (status: number, body: unknown, statusText = ""): StubResponse => ({
  ok: status >= 200 && status < 300,
  status,
  statusText,
  json: async () => body,
  text: async () => (typeof body === "string" ? body : JSON.stringify(body)),
});

export const EMPTY_SOURCE_AUTH_CONFIG = {
  auth_mode: "",
  github_app_id: "",
  github_app_installation_id: "",
  github_app_secret_scope: "",
  github_app_secret_key: "",
  token_secret_scope: "",
  token_secret_key: "",
  effective_mode: "anonymous",
  error: null,
};

/**
 * Default first-run map: agent unconfigured (404), no businesses, no
 * industries, no warehouses, etc. The keys are URL substrings — a
 * request URL matches a key if it includes that substring. The longest
 * matching key wins so callers can override `/api/runs/{id}` (specific)
 * without touching `/api/runs` (broad list).
 */
export const FIRST_RUN_DEFAULTS: Record<
  string,
  { status: number; body?: unknown }
> = {
  // Agent config — 404 is the canonical "not yet configured" signal.
  "/api/config/agent": { status: 404 },
  "/api/config/agent/ready": {
    status: 200,
    body: { ready: false, reason: "no_notebook_path" },
  },
  "/api/config/supported-agent-version": {
    status: 200,
    body: { data: { version: "v0.5.8", repo: "databricks-industry-solutions/lakehouse-industry-data-models" } },
  },
  "/api/config/deployment-catalog": { status: 404 },
  "/api/config/warehouse": { status: 404 },
  // Source-auth card on Settings > Sources reads this on mount.
  "/api/config/source-auth": { status: 200, body: EMPTY_SOURCE_AUTH_CONFIG },
  // GitHub publishing — unconfigured on a fresh install (all fields empty).
  "/api/config/github": {
    status: 200,
    body: {
      repo_owner: "",
      repo_name: "",
      auth_mode: "",
      connection_name: "",
      secret_scope: "",
      secret_key: "",
    },
  },
  // Agent-compat advisory card — fail quiet on first run.
  "/api/config/agent-compat": { status: 404 },
  "/api/warehouses": { status: 200, body: { data: [] } },
  // Domain data — empty workspace.
  "/api/businesses": { status: 200, body: { data: [] } },
  "/api/industries": { status: 200, body: { data: [] } },
  "/api/runs": { status: 200, body: [] },
  // Health — drain not in progress.
  "/api/health": {
    status: 200,
    body: { status: "ok", drain: { active: false } },
  },
};

/**
 * Build a fetch stub that answers like a freshly-installed workspace.
 * Pass overrides to short-circuit specific endpoints with custom data
 * for the path under test.
 */
export function firstRunFetcher(overrides: FirstRunOverrides = {}) {
  // Two passes: overrides first (longest-key first within each pass), so
  // a caller's `"/api/config/agent": 200` wins over the default 404 even
  // when keys are identical. Within a pass, longest key wins so a
  // specific URL like `/api/runs/{id}` is preferred over `/api/runs`.
  const sortByLength = (
    o: Record<string, FetchHandler | { status: number; body?: unknown }>,
  ) =>
    Object.entries(o).sort((a, b) => b[0].length - a[0].length);
  const overrideEntries = sortByLength(overrides);
  const defaultEntries = sortByLength(FIRST_RUN_DEFAULTS);

  return vi.fn(async (url: RequestInfo | URL, init?: RequestInit) => {
    const u = String(url);
    for (const [fragment, handler] of [...overrideEntries, ...defaultEntries]) {
      if (!u.includes(fragment)) continue;
      if (typeof handler === "function") return handler(u, init);
      return jsonResponse(handler.status, handler.body ?? {});
    }
    // Unknown URL → 404 with empty body. Loud-fail surfaces missing
    // fixtures without hanging the test on a real network request.
    return jsonResponse(404, { detail: `firstRunFetcher: no stub for ${u}` });
  });
}
