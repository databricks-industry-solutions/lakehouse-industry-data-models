/**
 * Shared TanStack Query hooks layered over the Orval-generated client.
 *
 * Drift-unification (the model-versioning work, Phase 5): hand-rolled `useQuery({ queryFn })`
 * wrappers around `/api/...` endpoints duplicated across routes. Each duplicate
 * is its own queryKey + fetch implementation, which means cache-invalidation,
 * retry/staleTime tuning, and response shape decoding all drift over time.
 * The Orval client already covers every endpoint; this module just types the
 * payload and unwraps the `{ data: ... }` envelope so callers don't have to.
 */
import { useEffect, useRef, useState } from "react";
import { useQueryClient } from "@tanstack/react-query";
import { getAgentReadyKey, useGetAgentReady, useGetUserRole } from "@/lib/api";
import { isTerminalRunStatus } from "@/lib/run-status";

/** Debounce a fast-changing value (e.g. a search box) before it drives an
 *  expensive effect / query key. Returns the value after `delayMs` of quiet. */
export function useDebouncedValue<T>(value: T, delayMs = 250): T {
  const [debounced, setDebounced] = useState(value);
  useEffect(() => {
    const t = setTimeout(() => setDebounced(value), delayMs);
    return () => clearTimeout(t);
  }, [value, delayMs]);
  return debounced;
}

/**
 * Refetch every query when a run that was in flight lands in a terminal state:
 * a run that finishes on its own produces versions, artifacts and statuses
 * that other pages already cached. The first status seen never fires (a run
 * already terminal on mount has nothing new), and ``scopeKey`` (e.g. the
 * business id) restarts the comparison so switching between entities that
 * share a mounted layout does not read as a transition.
 */
export function useInvalidateOnRunTerminal(
  status: string | undefined,
  scopeKey?: string,
): void {
  const queryClient = useQueryClient();
  const last = useRef<{ scopeKey?: string; status: string | null }>({
    scopeKey,
    status: null,
  });
  useEffect(() => {
    if (status === undefined) return;
    const prev = last.current;
    last.current = { scopeKey, status };
    if (
      prev.scopeKey === scopeKey &&
      prev.status !== null &&
      prev.status !== status &&
      isTerminalRunStatus(status)
    ) {
      void queryClient.invalidateQueries();
    }
  }, [status, scopeKey, queryClient]);
}

export type AgentReady = { ready: boolean; reason?: string };

/** Stable queryKey re-export so consumers can `invalidateQueries({ queryKey })`
 *  without coupling to the Orval-generated module. */
export const agentReadyQueryKey = getAgentReadyKey;

/**
 * Is the app in a state where runs can launch right now?
 *
 * Wraps the Orval-generated `useGetAgentReady` and unwraps the response
 * envelope so callers get `{ ready, reason? }` directly instead of
 * `{ data: { ready, reason? } }`. Reused on the Settings page (banner) and
 * the business runs page (gate on the New Run button) so they always agree.
 *
 * @param staleTime  How long the result is considered fresh (default 15s).
 *                   The two original sites used 15s and 30s respectively;
 *                   15s is the lower bound, fine for both.
 */
export function useAgentReady(staleTime = 15_000) {
  return useGetAgentReady<AgentReady>({
    query: {
      select: (resp) => resp.data as AgentReady,
      staleTime,
      retry: false,
    },
  });
}

/** The four application RBAC roles resolved by `/api/user/role`. */
export type AppRole = "app_admin" | "business_admin" | "modeler" | "viewer";

/** An app or business admin: the roles the server's BusinessAdminOnly guard
 *  lets through. A loading or unknown role is not one. */
export function isBusinessAdmin(role: string | null | undefined): boolean {
  return role === "app_admin" || role === "business_admin";
}

/**
 * The current user's resolved RBAC role, or `undefined` while loading / when
 * the endpoint errored. Wraps the Orval-generated `useGetUserRole` and unwraps
 * the `{ data: { role } }` envelope. Roles are off server-side (every
 * user resolves to `app_admin`), so callers should treat `undefined` as "don't
 * gate" - only a positive non-admin role should ever tighten access.
 */
export function useUserRole(): AppRole | undefined {
  const { data } = useGetUserRole({
    query: { retry: false, staleTime: 60_000 },
  });
  const role = (data?.data as { role?: string } | undefined)?.role;
  return role as AppRole | undefined;
}
