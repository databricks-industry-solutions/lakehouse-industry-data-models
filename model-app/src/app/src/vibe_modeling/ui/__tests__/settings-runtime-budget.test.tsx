/**
 * Settings > Agent: "Run time budget (hours)".
 *
 * The field hydrates from `AgentConfigOut.runtime_budget_hours`, takes its
 * min/max from the API's bounds (the fixture uses bounds other than the
 * backend's to prove nothing is hard-coded), refuses an out-of-range or
 * fractional value inline without calling the API, and sends a valid change
 * in the PUT body.
 */
import { afterEach, describe, expect, it, vi } from "vitest";
import { fireEvent, render, screen, waitFor } from "@testing-library/react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";

import { AgentConfigSection } from "@/routes/_sidebar/settings";
import { RUNTIME_BUDGET_SETTINGS_HINT } from "@/lib/runtime-budget";
import { firstRunFetcher, jsonResponse } from "./helpers/first-run";

afterEach(() => {
  vi.restoreAllMocks();
  vi.unstubAllGlobals();
});

const SAVED = {
  notebook_path: "/Workspace/Users/me/agent",
  deployment_catalog: "vibe_modeling",
  job_id: 12345,
  job_name: "vibe-modelling-agent",
  max_concurrent_runs: 3,
  collect_vibe_run_statistics: true,
  runtime_budget_hours: 8,
  runtime_budget_min_hours: 5,
  runtime_budget_max_hours: 30,
  updated_at: "2026-10-25T00:00:00Z",
};

function stubConfig(putSpy = vi.fn(), saved: Record<string, unknown> = SAVED) {
  vi.stubGlobal(
    "fetch",
    firstRunFetcher({
      "/api/config/agent/check-notebook": { status: 200, body: { ok: true, version: "v0.9.0" } },
      "/api/config/agent": (url: string, init?: RequestInit) => {
        if (init && init.method === "PUT") {
          putSpy(url, JSON.parse(String(init.body)));
          return Promise.resolve(jsonResponse(200, saved));
        }
        return Promise.resolve(jsonResponse(200, saved));
      },
    }),
  );
  return putSpy;
}

function renderSection() {
  const qc = new QueryClient({
    defaultOptions: { queries: { retry: false, staleTime: 30_000 }, mutations: { retry: false } },
  });
  return render(
    <QueryClientProvider client={qc}>
      <AgentConfigSection />
    </QueryClientProvider>,
  );
}

async function budgetInput() {
  const input = (await screen.findByLabelText(/Run time budget \(hours\)/i)) as HTMLInputElement;
  await waitFor(() => expect(input.value).toBe("8"));
  return input;
}

describe("Settings run time budget", () => {
  it("hydrates the saved hours with the API's bounds and the hint", async () => {
    stubConfig();
    renderSection();
    const input = await budgetInput();
    expect(input.type).toBe("number");
    expect(input.min).toBe("5");
    expect(input.max).toBe("30");
    expect(input.step).toBe("1");
    const hint = screen.getByTestId("runtime-budget-hint");
    expect(hint).toHaveTextContent(RUNTIME_BUDGET_SETTINGS_HINT);
    expect(hint).toHaveTextContent("Whole hours, 5 to 30 (the upper limit is a safety cap).");
  });

  it("is absent while there is no saved config (404)", async () => {
    vi.stubGlobal("fetch", firstRunFetcher());
    renderSection();
    await screen.findByText(/Agent Configuration/i);
    expect(screen.queryByLabelText(/Run time budget/i)).toBeNull();
  });

  it.each([["31"], ["4"], ["6.5"], [""]])(
    "refuses %s on Save with an inline error and no API call",
    async (value) => {
      const putSpy = stubConfig();
      renderSection();
      const input = await budgetInput();
      fireEvent.change(input, { target: { value } });
      fireEvent.submit(input.closest("form")!);
      const error = await screen.findByText(
        "Run time budget must be a whole number of hours from 5 to 30.",
      );
      expect(putSpy).not.toHaveBeenCalled();
      expect(input).toHaveAttribute("aria-invalid", "true");
      expect(input.getAttribute("aria-describedby")?.split(" ")).toEqual([
        error.closest("p")!.id,
        screen.getByTestId("runtime-budget-hint").id,
      ]);
    },
  );

  it("turns off native validation so the inline errors show, and ties hints to both number inputs", async () => {
    stubConfig();
    renderSection();
    const input = await budgetInput();
    // jsdom runs no native validation; the browser would, and its bubble
    // would replace the inline error for 3, 49 or 6.5.
    expect(screen.getByTestId("agent-config-form")).toHaveAttribute("novalidate");
    expect(input.getAttribute("aria-describedby")).toBe(
      screen.getByTestId("runtime-budget-hint").id,
    );
    const concurrent = screen.getByLabelText(/Concurrent runs/i);
    const hintId = concurrent.getAttribute("aria-describedby")!;
    expect(document.getElementById(hintId)).toHaveTextContent(/Minimum 3/);
    fireEvent.change(concurrent, { target: { value: "2" } });
    fireEvent.submit(input.closest("form")!);
    const error = await screen.findByText(/Concurrent runs must be at least 3/i);
    expect(concurrent.getAttribute("aria-describedby")?.split(" ")).toEqual([
      error.closest("p")!.id,
      hintId,
    ]);
  });

  it("checks the required notebook path itself", async () => {
    const putSpy = stubConfig();
    renderSection();
    await budgetInput();
    const path = screen.getByLabelText(/Notebook Path/i);
    fireEvent.change(path, { target: { value: "  " } });
    fireEvent.submit(path.closest("form")!);
    expect(await screen.findByText("Notebook Path is required.")).toBeInTheDocument();
    expect(putSpy).not.toHaveBeenCalled();
  });

  it("sends a valid change in the PUT body", async () => {
    const putSpy = stubConfig();
    renderSection();
    const input = await budgetInput();
    fireEvent.change(input, { target: { value: "12" } });
    expect(input.value).toBe("12");
    const save = screen.getByRole("button", { name: /^Save/i });
    await waitFor(() => expect(save).not.toBeDisabled());
    fireEvent.click(save);
    await waitFor(() => expect(putSpy).toHaveBeenCalledTimes(1));
    expect(putSpy.mock.calls[0][1]).toMatchObject({
      notebook_path: SAVED.notebook_path,
      runtime_budget_hours: 12,
    });
  });
});
