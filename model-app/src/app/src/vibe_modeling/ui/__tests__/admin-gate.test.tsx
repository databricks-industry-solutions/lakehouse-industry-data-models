/**
 * `AdminGate` (Track 4 finding #7) - non-admins see admin Settings tabs
 * read-only UP FRONT (notice + disabled inputs), not just on a save 403.
 *
 * The gate reads the shared `/api/user/role` signal. Gating only ever tightens
 * on a positive non-admin role: when the role is unknown (loading / RBAC off /
 * endpoint error) the section stays fully editable, so the default deploy and
 * offline cases never lock a user out.
 */
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";
import { render, screen, waitFor } from "@testing-library/react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { jsonResponse } from "./helpers/first-run";

import { AdminGate } from "@/components/settings/admin-gate";

function withRole(role: string | null) {
  vi.stubGlobal(
    "fetch",
    vi.fn(async (url: string) => {
      const u = typeof url === "string" ? url : (url as URL).toString();
      if (u.includes("/api/user/role")) {
        if (role == null) {
          return jsonResponse(500, {}) as Response;
        }
        return jsonResponse(200, { role, display_name: role }) as Response;
      }
      return { ok: true, status: 200, json: async () => ({}) } as Response;
    }),
  );
}

function renderGate(scope: "app" | "business") {
  const qc = new QueryClient({
    defaultOptions: { queries: { retry: false }, mutations: { retry: false } },
  });
  return render(
    <QueryClientProvider client={qc}>
      <AdminGate scope={scope}>
        <input aria-label="notebook" />
      </AdminGate>
    </QueryClientProvider>,
  );
}

afterEach(() => {
  vi.unstubAllGlobals();
  vi.restoreAllMocks();
});

describe("AdminGate", () => {
  beforeEach(() => vi.restoreAllMocks());

  it("renders read-only with a notice for a viewer on an app-scoped tab", async () => {
    withRole("viewer");
    renderGate("app");
    await waitFor(() =>
      expect(screen.getByTestId("admin-readonly-notice")).toBeInTheDocument(),
    );
    expect(screen.getByText(/Requires admin access/i)).toBeInTheDocument();
    // The native fieldset[disabled] wrapper disables descendant inputs.
    expect(screen.getByLabelText("notebook")).toBeDisabled();
  });

  it("stays editable for an app_admin", async () => {
    withRole("app_admin");
    renderGate("app");
    // Give the role query a tick to settle; it should NOT flip read-only.
    await waitFor(() => expect(screen.getByLabelText("notebook")).toBeEnabled());
    expect(screen.queryByTestId("admin-readonly-notice")).toBeNull();
  });

  it("admits a business_admin on a business-scoped tab but not an app tab", async () => {
    withRole("business_admin");
    const { unmount } = renderGate("business");
    await waitFor(() => expect(screen.getByLabelText("notebook")).toBeEnabled());
    expect(screen.queryByTestId("admin-readonly-notice")).toBeNull();
    unmount();

    withRole("business_admin");
    renderGate("app");
    await waitFor(() =>
      expect(screen.getByTestId("admin-readonly-notice")).toBeInTheDocument(),
    );
  });

  it("stays editable when the role signal is unavailable", async () => {
    withRole(null);
    renderGate("app");
    await waitFor(() => expect(screen.getByLabelText("notebook")).toBeEnabled());
    expect(screen.queryByTestId("admin-readonly-notice")).toBeNull();
  });
});
