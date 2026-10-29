/**
 * KickstartProgressBanner - the business layout banner shown while a
 * kickstart's background copy runs. Real query hooks over a stubbed `fetch`,
 * so the polling, the terminal stop and the post-completion refetch are
 * exercised end to end.
 */
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";
import { act, screen, waitFor } from "@testing-library/react";
import { QueryClient } from "@tanstack/react-query";

let matchOverride: ((opts: { to: string }) => unknown) | null = null;

vi.mock("@tanstack/react-router", async () => {
  const actual = await vi.importActual<typeof import("@tanstack/react-router")>(
    "@tanstack/react-router",
  );
  return {
    ...actual,
    useMatchRoute: () => {
      const real = actual.useMatchRoute();
      return (opts: { to: string }) =>
        matchOverride ? matchOverride(opts) : real(opts as never);
    },
  };
});

import {
  KICKSTART_POLL_MS,
  KickstartProgressBanner,
  kickstartPollInterval,
  laterRunCompleted,
  latestKickstartRun,
} from "@/components/industry/kickstart-progress-banner";
import { useGetExplorerVersions } from "@/lib/api";
import { KICKSTART_RUN_INTENT } from "@/lib/intent";
import { renderWithRouter } from "./helpers/router-wrapper";

interface FakeRun {
  id: string;
  intent: string;
  status: string;
  progress_percent: number;
  progress_message?: string;
  error_message?: string;
  created_at?: string;
}

let runs: FakeRun[] = [];
let hasSource = true;
let calls: string[] = [];

const runOut = (r: FakeRun) => ({
  id: r.id,
  business_id: "biz-new",
  intent: r.intent,
  status: r.status,
  progress_percent: r.progress_percent,
  started_at: null,
  completed_at: null,
  created_at: r.created_at ?? "2026-10-01T00:00:00Z",
});

function respond(url: string): unknown {
  if (url.endsWith("/api/businesses/biz-new/runs")) return runs.map(runOut);
  const detail = url.match(/\/api\/businesses\/biz-new\/runs\/([^/]+)$/);
  if (detail) {
    const r = runs.find((x) => x.id === detail[1])!;
    return {
      ...runOut(r),
      progress_message: r.progress_message ?? "",
      error_message: r.error_message ?? "",
    };
  }
  if (url.endsWith("/api/businesses/biz-new")) {
    return {
      id: "biz-new",
      name: "Acme Retail",
      source_industry_id: hasSource ? "ind-1" : null,
      source_version: hasSource ? 1 : null,
    };
  }
  if (url.endsWith("/api/businesses")) {
    return [
      { id: "ind-1", name: "Retail" },
      { id: "biz-new", name: "Acme Retail" },
    ];
  }
  if (url.endsWith("/api/businesses/biz-new/explorer/versions")) return [];
  throw new Error(`unexpected fetch ${url}`);
}

const count = (suffix: string) => calls.filter((u) => u.endsWith(suffix)).length;

beforeEach(() => {
  runs = [];
  hasSource = true;
  calls = [];
  matchOverride = null;
  vi.stubGlobal(
    "fetch",
    vi.fn(async (input: RequestInfo | URL) => {
      const url = String(input);
      calls.push(url);
      return new Response(JSON.stringify(respond(url)), {
        status: 200,
        headers: { "Content-Type": "application/json" },
      });
    }),
  );
});

afterEach(() => {
  vi.useRealTimers();
  vi.unstubAllGlobals();
});

function Probe() {
  useGetExplorerVersions({ params: { business_id: "biz-new" } });
  return null;
}

function mount() {
  const queryClient = new QueryClient({
    defaultOptions: { queries: { retry: false } },
  });
  return renderWithRouter(
    <>
      <KickstartProgressBanner businessId="biz-new" />
      <Probe />
    </>,
    { queryClient },
  );
}

const running = (over: Partial<FakeRun> = {}): FakeRun => ({
  id: "run-1",
  intent: KICKSTART_RUN_INTENT,
  status: "running",
  progress_percent: 60,
  progress_message: "Copying ecm artifacts",
  ...over,
});

describe("kickstart helpers", () => {
  it("finds the newest kickstart run and ignores other intents", () => {
    const list = [
      { id: "a", intent: "install" },
      { id: "b", intent: KICKSTART_RUN_INTENT },
      { id: "c", intent: KICKSTART_RUN_INTENT },
    ] as never;
    expect(latestKickstartRun(list)?.id).toBe("b");
    expect(latestKickstartRun([])).toBeUndefined();
    expect(latestKickstartRun(undefined)).toBeUndefined();
  });

  it("polls only while the run is not terminal", () => {
    expect(kickstartPollInterval({ status: "running" })).toBe(KICKSTART_POLL_MS);
    expect(kickstartPollInterval({ status: "pending" })).toBe(KICKSTART_POLL_MS);
    expect(kickstartPollInterval({ status: "completed" })).toBe(false);
    expect(kickstartPollInterval({ status: "failed" })).toBe(false);
    expect(kickstartPollInterval(undefined)).toBe(false);
  });

  it("sees a later completed run, not an earlier or failed one", () => {
    const k = { id: "k", created_at: "2026-10-02T00:00:00Z" };
    const run = (id: string, status: string, created_at: string) =>
      ({ id, status, created_at }) as never;
    expect(laterRunCompleted([run("a", "completed", "2026-10-03T00:00:00Z")], k)).toBe(true);
    expect(laterRunCompleted([run("a", "completed", "2026-10-01T00:00:00Z")], k)).toBe(false);
    expect(laterRunCompleted([run("a", "failed", "2026-10-03T00:00:00Z")], k)).toBe(false);
    expect(laterRunCompleted([run("k", "completed", "2026-10-03T00:00:00Z")], k)).toBe(false);
    expect(laterRunCompleted(undefined, k)).toBe(false);
  });
});

describe("KickstartProgressBanner", () => {
  it("shows the step, percent and run lock while the kickstart runs", async () => {
    runs = [running()];
    mount();

    const banner = await screen.findByTestId("kickstart-progress-banner");
    await waitFor(() =>
      expect(banner).toHaveTextContent("Setting up this business from Retail v1"),
    );
    await waitFor(() =>
      expect(banner).toHaveTextContent("Copying ecm artifacts - 60%"),
    );
    expect(banner).toHaveTextContent(
      "Runs are blocked until setup finishes.",
    );
    expect(screen.getByRole("progressbar")).toHaveAttribute(
      "aria-valuenow",
      "60",
    );
    expect(screen.getByRole("link", { name: "View run" })).toBeInTheDocument();
  });

  it("announces only the step line, not the whole banner", async () => {
    runs = [running()];
    mount();
    const banner = await screen.findByTestId("kickstart-progress-banner");
    await waitFor(() =>
      expect(banner).toHaveTextContent("Copying ecm artifacts"),
    );
    expect(banner).not.toHaveAttribute("role");
    expect(screen.queryByRole("alert")).toBeNull();
    const live = banner.querySelector("[aria-live]");
    expect(live).toHaveTextContent("Copying ecm artifacts - 60%");
    expect(live).not.toHaveTextContent("Runs are blocked");
  });

  it("does not double the parentheses of a step that ends in one", async () => {
    runs = [running({ progress_message: "Seeding metamodel (1/2 scope(s))", progress_percent: 20 })];
    mount();
    const banner = await screen.findByTestId("kickstart-progress-banner");
    await waitFor(() =>
      expect(banner).toHaveTextContent("Seeding metamodel (1/2 scope(s)) - 20%"),
    );
  });

  it("asks for no runs and renders nothing for a business that was not kickstarted", async () => {
    hasSource = false;
    runs = [running()];
    mount();
    await waitFor(() => expect(count("/api/businesses/biz-new")).toBe(1));
    expect(screen.queryByTestId("kickstart-progress-banner")).toBeNull();
    expect(count("/runs")).toBe(0);
  });

  it("renders nothing without a kickstart run", async () => {
    runs = [{ ...running(), intent: "install" }];
    mount();
    await waitFor(() => expect(count("/runs")).toBe(1));
    expect(screen.queryByTestId("kickstart-progress-banner")).toBeNull();
    expect(count("/runs/run-1")).toBe(0);
  });

  it("renders nothing and does not poll once the kickstart completed", async () => {
    runs = [running({ status: "completed", progress_percent: 100 })];
    vi.useFakeTimers({ shouldAdvanceTime: true });
    mount();
    await waitFor(() => expect(count("/runs")).toBe(1));
    const before = calls.length;
    await act(async () => {
      await vi.advanceTimersByTimeAsync(KICKSTART_POLL_MS * 3);
    });
    expect(screen.queryByTestId("kickstart-progress-banner")).toBeNull();
    expect(calls.length).toBe(before);
    expect(count("/runs/run-1")).toBe(0);
  });

  it("shows the failure message and the run link, never the raw error, and stops polling", async () => {
    runs = [
      running({
        status: "failed",
        progress_message:
          "Kickstart background work failed; the business is created but may not yet be iterable.",
        error_message: "RuntimeError: boom",
      }),
    ];
    vi.useFakeTimers({ shouldAdvanceTime: true });
    mount();

    const banner = await screen.findByTestId("kickstart-progress-banner");
    await waitFor(() =>
      expect(banner).toHaveTextContent(
        "Setting up this business from Retail v1 failed",
      ),
    );
    await waitFor(() =>
      expect(banner).toHaveTextContent(
        "Kickstart background work failed; the business is created but may not yet be iterable.",
      ),
    );
    expect(banner).not.toHaveTextContent("boom");
    expect(banner).toHaveAttribute("role", "status");
    expect(screen.queryByRole("alert")).toBeNull();
    expect(screen.getByRole("link", { name: "View run" })).toBeInTheDocument();
    expect(screen.queryByRole("progressbar")).toBeNull();

    const before = calls.length;
    await act(async () => {
      await vi.advanceTimersByTimeAsync(KICKSTART_POLL_MS * 3);
    });
    expect(calls.length).toBe(before);
  });

  it("hides the failure once a later run completed", async () => {
    runs = [
      running({ status: "failed", created_at: "2026-10-01T00:00:00Z" }),
      {
        id: "run-2",
        intent: "vibe-iterate",
        status: "completed",
        progress_percent: 100,
        created_at: "2026-10-02T00:00:00Z",
      },
    ];
    mount();
    await waitFor(() => expect(count("/runs/run-1")).toBe(1));
    expect(screen.queryByTestId("kickstart-progress-banner")).toBeNull();
  });

  it("stays off the kickstart run's own page and the full-height inputs pages", async () => {
    runs = [running()];
    matchOverride = (opts) =>
      opts.to === "/businesses/$businessId/runs/$runId"
        ? { businessId: "biz-new", runId: "run-1" }
        : false;
    const { unmount } = mount();
    await waitFor(() => expect(count("/runs/run-1")).toBe(1));
    expect(screen.queryByTestId("kickstart-progress-banner")).toBeNull();
    unmount();

    matchOverride = (opts) =>
      opts.to.endsWith("/inputs") ? { businessId: "biz-new" } : false;
    mount();
    await waitFor(() => expect(count("/runs/run-1")).toBe(2));
    expect(screen.queryByTestId("kickstart-progress-banner")).toBeNull();
  });

  it("polls the run only, then clears and refetches the business data on completion", async () => {
    runs = [running({ progress_percent: 20, progress_message: "Seeding metamodel" })];
    vi.useFakeTimers({ shouldAdvanceTime: true });
    mount();

    const banner = await screen.findByTestId("kickstart-progress-banner");
    await waitFor(() => expect(banner).toHaveTextContent("Seeding metamodel - 20%"));

    runs = [running({ progress_percent: 80, progress_message: "Copying mvm artifacts" })];
    await act(async () => {
      await vi.advanceTimersByTimeAsync(KICKSTART_POLL_MS + 100);
    });
    await waitFor(() =>
      expect(banner).toHaveTextContent("Copying mvm artifacts - 80%"),
    );
    expect(count("/biz-new/runs")).toBe(1);
    expect(count("/runs/run-1")).toBeGreaterThanOrEqual(2);
    const versionsBefore = count("/explorer/versions");

    runs = [running({ status: "completed", progress_percent: 100 })];
    await act(async () => {
      await vi.advanceTimersByTimeAsync(KICKSTART_POLL_MS + 100);
    });
    await waitFor(() =>
      expect(screen.queryByTestId("kickstart-progress-banner")).toBeNull(),
    );

    // Completion refetched an unrelated query of this business (and the run
    // list), after which nothing keeps polling.
    await waitFor(() => expect(count("/explorer/versions")).toBe(versionsBefore + 1));
    await waitFor(() => expect(count("/biz-new/runs")).toBe(2));
    const settled = calls.length;
    await act(async () => {
      await vi.advanceTimersByTimeAsync(KICKSTART_POLL_MS * 3);
    });
    expect(calls.length).toBe(settled);
  });
});
