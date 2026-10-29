/**
 * The one agent status line on Settings > Agent (add §8.3, base §4): the
 * identity and owner of the configured notebook, "last checked" from
 * `installed_checked_at`, the upstream verdict, and "Switch to bundled" for an
 * admin-owned or missing notebook.
 */
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";
import { act, fireEvent, render, screen, waitFor } from "@testing-library/react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import type { AgentCompatOut } from "@/lib/api";

const switchMock = vi.fn();
let compat: AgentCompatOut;

vi.mock("@/lib/api", async () => {
  const actual = await vi.importActual<typeof import("@/lib/api")>("@/lib/api");
  return {
    ...actual,
    useGetAgentCompat: () => ({ data: { data: compat }, isError: false }),
    switchToBundledAgent: (...a: unknown[]) => switchMock(...a),
  };
});
vi.mock("sonner", () => ({ toast: { success: vi.fn(), error: vi.fn(), warning: vi.fn() } }));

import { AgentStatusRow, agentStatus } from "@/components/settings/agent-status-row";

function info(overrides: Partial<AgentCompatOut> = {}): AgentCompatOut {
  return {
    pinned_version: "v0.9.0",
    latest_known_upstream: "v0.9.0",
    newer_available: false,
    has_breaking_change: false,
    known_breaking_changes: [],
    pinned_release: "v0.9.0",
    pinned_agent_marker: "5.3.3",
    bundled_agent_marker: "5.3.3",
    latest_upstream_release: "v0.9.0",
    latest_upstream_marker: "5.3.3",
    verdict: "up_to_date",
    agent_owner: "app",
    installed_release_version: "v0.9.0",
    installed_agent_version: "5.3.3",
    installed_checked_at: new Date(Date.now() - 5 * 60_000).toISOString(),
    installed_vs_bundled: "same",
    ...overrides,
  };
}

function renderRow(hasNotebook = true, onSwitched?: (p: string) => void) {
  const qc = new QueryClient({ defaultOptions: { queries: { retry: false } } });
  return render(
    <QueryClientProvider client={qc}>
      <AgentStatusRow hasNotebook={hasNotebook} onSwitched={onSwitched} />
    </QueryClientProvider>,
  );
}

beforeEach(() => {
  compat = info();
  switchMock.mockReset();
});
afterEach(() => vi.clearAllMocks());

describe("agentStatus", () => {
  it("app-owned: managed by the app, last checked, up to date, no switch", () => {
    const s = agentStatus(info(), true);
    expect(s.tone).toBe("ok");
    expect(s.identity).toMatch(/Agent v0\.9\.0 \(build 5\.3\.3\), managed by this app/);
    expect(s.checked).toMatch(/^Last checked /);
    expect(s.upstream).toBe("Up to date with upstream.");
    expect(s.offerSwitch).toBe(false);
  });

  it("admin-owned and older: names the gap, warns, offers the switch", () => {
    const s = agentStatus(
      info({ agent_owner: "admin", installed_vs_bundled: "older", installed_release_version: "v0.8.0", installed_agent_version: "4.9.9" }),
      true,
    );
    expect(s.tone).toBe("warn");
    expect(s.identity).toMatch(/Your own notebook \(agent v0\.8\.0 \(build 4\.9\.9\)\), older than the bundled 5\.3\.3/);
    expect(s.offerSwitch).toBe(true);
    expect(s.switchLabel).toBe("Switch to bundled 5.3.3");
  });

  it("no notebook: offers the bundled agent", () => {
    const s = agentStatus(info({ installed_release_version: null, installed_agent_version: null }), false);
    expect(s.identity).toBe("No agent notebook is configured.");
    expect(s.switchLabel).toBe("Use the bundled agent 5.3.3");
  });

  it("never checked: no last-checked text", () => {
    expect(agentStatus(info({ installed_checked_at: null }), true).checked).toBeNull();
  });

  it("release_incompatible: warns that the app needs updating", () => {
    const s = agentStatus(info({ verdict: "release_incompatible", latest_upstream_release: "v1.0.0" }), true);
    expect(s.tone).toBe("warn");
    expect(s.upstream).toMatch(/Upstream released agent v1\.0\.0; using it needs a newer version of this app/);
  });

  it("build_update_available is informational", () => {
    const s = agentStatus(info({ verdict: "build_update_available", latest_upstream_marker: "5.3.4" }), true);
    expect(s.tone).toBe("ok");
    expect(s.upstream).toMatch(/newer upstream build \(5\.3\.4\)/);
  });
});

describe("AgentStatusRow", () => {
  it("renders one line with no switch for an app-owned notebook", () => {
    renderRow();
    const row = screen.getByTestId("agent-status-row");
    expect(row).toHaveTextContent(/managed by this app/);
    expect(row).toHaveTextContent(/Last checked/);
    expect(screen.queryByTestId("switch-to-bundled")).toBeNull();
  });

  it("switches an admin-owned notebook after confirming", async () => {
    compat = info({ agent_owner: "admin", installed_vs_bundled: "older" });
    switchMock.mockResolvedValue({ data: { notebook_path: "/Users/sp/vibe-modelling-agent/nb.ipynb" } });
    const onSwitched = vi.fn();
    renderRow(true, onSwitched);
    fireEvent.click(screen.getByTestId("switch-to-bundled"));
    expect(await screen.findByRole("alertdialog")).toHaveTextContent(/stays where it is/);
    await act(async () => {
      fireEvent.click(screen.getByRole("button", { name: "Switch" }));
    });
    await waitFor(() => expect(switchMock).toHaveBeenCalledTimes(1));
    expect(onSwitched).toHaveBeenCalledWith("/Users/sp/vibe-modelling-agent/nb.ipynb");
  });

  it("lists known breaking changes on release_incompatible", () => {
    compat = info({
      verdict: "release_incompatible",
      known_breaking_changes: [{ tag: "v1.0.0", severity: "breaking", area: "widgets", summary: "renamed" }],
    });
    renderRow();
    expect(screen.getByTestId("agent-status-row")).toHaveTextContent(/v1\.0\.0 \[widgets\] renamed/);
  });
});
