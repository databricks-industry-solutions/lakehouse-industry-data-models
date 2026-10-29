import type { ReactNode } from "react";
import { AlertTriangle } from "lucide-react";
import { useUserRole, isBusinessAdmin } from "@/lib/hooks";

/** Which privilege level a gated Settings tab requires. */
type AdminScope = "app" | "business";

/**
 * Wraps an admin-only Settings tab so non-admins see it read-only up front,
 * not just when a save 403s.
 *
 * The current role comes from the shared `useUserRole` signal
 * (`/api/user/role`). When the role is KNOWN to be below the required level,
 * the section renders a "Requires admin access" notice and a
 * `<fieldset disabled>` - which natively disables every input, select, and
 * button inside, so the whole tab becomes view-only in one place instead of
 * per-field wiring. When the role is unknown (still loading, roles disabled so
 * everyone resolves to app_admin, or the endpoint errored) the section stays
 * fully editable: gating only ever tightens on a positive non-admin signal, so
 * the current app (roles off) and the offline/error cases never lock a user
 * out.
 *
 * `scope="app"` gates to app admins (Agent, Platform, Sources);
 * `scope="business"` also admits business admins (Sectors). Preferences is not
 * gated - it is per-user and editable by everyone.
 */
export function AdminGate({
  scope,
  children,
}: {
  scope: AdminScope;
  children: ReactNode;
}) {
  const role = useUserRole();
  const readOnly =
    role != null &&
    (scope === "app"
      ? role !== "app_admin"
      : !isBusinessAdmin(role));

  return (
    <fieldset disabled={readOnly} className="m-0 min-w-0 space-y-4 border-0 p-0">
      {readOnly && (
        <div
          data-testid="admin-readonly-notice"
          className="flex max-w-4xl items-start gap-2 rounded-md border border-warning/40 bg-warning/5 px-3 py-2 text-xs"
        >
          <AlertTriangle className="h-4 w-4 shrink-0 mt-0.5 text-warning" />
          <span className="text-warning">
            Requires admin access. You can view these settings but not change
            them.
          </span>
        </div>
      )}
      {children}
    </fieldset>
  );
}
