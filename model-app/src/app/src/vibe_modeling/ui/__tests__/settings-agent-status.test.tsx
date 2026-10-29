/**
 * Settings > Agent above the form (add §8.3): one agent status line, the pin
 * sentence as a tooltip on Notebook Path, the readiness banner suppressed for
 * the "no notebook" reason (the status line says it), and no manual
 * "Install bundled agent" button (design §4).
 */
import { afterEach, describe, expect, it, vi } from "vitest";
import { render, screen, waitFor } from "@testing-library/react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { AgentConfigSection } from "@/routes/_sidebar/settings";
import { firstRunFetcher } from "./helpers/first-run";

const COMPAT = {
  pinned_version: "v0.9.0", latest_known_upstream: "v0.9.0", newer_available: false,
  has_breaking_change: false, known_breaking_changes: [], verdict: "up_to_date",
  pinned_agent_marker: "5.3.3", agent_owner: "app",
};

afterEach(() => {
  vi.restoreAllMocks();
  vi.unstubAllGlobals();
});

function renderSection() {
  const qc = new QueryClient({ defaultOptions: { queries: { retry: false } } });
  return render(
    <QueryClientProvider client={qc}>
      <AgentConfigSection />
    </QueryClientProvider>,
  );
}

describe("Settings > Agent status line", () => {
  it("first run: the status line offers the bundled agent and no readiness banner repeats it", async () => {
    vi.stubGlobal(
      "fetch",
      firstRunFetcher({ "/api/config/agent-compat": { status: 200, body: { ...COMPAT, installed_release_version: null } } }),
    );
    renderSection();
    expect(await screen.findByTestId("agent-status-row")).toHaveTextContent("No agent notebook is configured.");
    expect(screen.getByTestId("switch-to-bundled")).toHaveTextContent("Use the bundled agent 5.3.3");
    expect(screen.queryByText("no_notebook_path")).toBeNull();
    expect(screen.queryByRole("button", { name: /Install bundled agent/i })).toBeNull();
    expect(screen.queryByText(/This app is pinned to agent/)).toBeNull();
  });

  it("a saved notebook keeps the readiness banner for other reasons", async () => {
    vi.stubGlobal(
      "fetch",
      firstRunFetcher({
        "/api/config/agent": {
          status: 200,
          body: {
            id: "c1", notebook_path: "/Users/sp/vibe-modelling-agent/nb.ipynb", job_id: 1, job_name: "j",
            deployment_catalog: "cat", warehouse_id: "w", created_at: "2026-10-01T00:00:00Z", updated_at: "2026-10-01T00:00:00Z",
          },
        },
        "/api/config/agent/ready": { status: 200, body: { ready: false, reason: "The app can no longer access the notebook." } },
        "/api/config/agent-compat": { status: 200, body: COMPAT },
        "/api/config/agent/check": { status: 200, body: { ok: true, version: "v0.9.0" } },
      }),
    );
    renderSection();
    expect(await screen.findByText("The app can no longer access the notebook.")).toBeInTheDocument();
    await waitFor(() => expect(screen.getByTestId("agent-status-row")).toHaveTextContent(/managed by this app/));
    expect(screen.getByLabelText("Notebook Path *")).toBeInTheDocument();
  });
});
