import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";
import { act, fireEvent, render, renderHook, screen } from "@testing-library/react";
import {
  BUSY_RETRY_JITTER, BUSY_RETRY_SCHEDULE_S, busyRetryDelayMs, useBusyAutoRetry,
} from "@/lib/taxonomy/busy-retry";
import { BUSY_EXHAUSTED_COPY, BusyCountdown } from "@/components/taxonomy/busy-countdown";

const advance = async (ms: number) => {
  await act(async () => {
    await vi.advanceTimersByTimeAsync(ms);
  });
};

function setup(status = "busy", resetKey: string = "d1") {
  const retry = vi.fn(() => Promise.resolve());
  const cancel = vi.fn(() => Promise.resolve());
  const hook = renderHook(
    ({ s, k }: { s: string; k: string }) => useBusyAutoRetry(s, { retry, cancel, resetKey: k }),
    { initialProps: { s: status, k: resetKey } },
  );
  return { retry, cancel, ...hook };
}

beforeEach(() => {
  vi.useFakeTimers();
  vi.spyOn(Math, "random").mockReturnValue(0.5); // no jitter
});
afterEach(() => {
  vi.useRealTimers();
  vi.restoreAllMocks();
});

describe("busyRetryDelayMs", () => {
  it("uses the one schedule constant", () => {
    expect([...BUSY_RETRY_SCHEDULE_S]).toEqual([15, 30, 60, 120, 300, 600]);
    expect(BUSY_RETRY_JITTER).toBe(0.2);
    expect(BUSY_RETRY_SCHEDULE_S.map((_, i) => busyRetryDelayMs(i))).toEqual([15, 30, 60, 120, 300, 600].map((s) => s * 1000));
  });

  it("keeps the jitter within ±20%", () => {
    vi.spyOn(Math, "random").mockReturnValue(0);
    expect(busyRetryDelayMs(0)).toBe(12_000);
    vi.spyOn(Math, "random").mockReturnValue(0.999999);
    expect(busyRetryDelayMs(0)).toBeLessThanOrEqual(18_000);
    expect(busyRetryDelayMs(5)).toBeGreaterThan(719_000);
  });
});

describe("useBusyAutoRetry", () => {
  it("retries once per step of 15/30/60/120/300/600 s, then stops after the 6th", async () => {
    const { retry, result } = setup();
    let calls = 0;
    for (const s of BUSY_RETRY_SCHEDULE_S) {
      await advance(s * 1000 - 1);
      expect(retry).toHaveBeenCalledTimes(calls);
      await advance(1);
      calls += 1;
      expect(retry).toHaveBeenCalledTimes(calls);
    }
    expect(result.current.exhausted).toBe(true);
    expect(result.current.remainingS).toBeNull();
    await advance(60 * 60 * 1000);
    expect(retry).toHaveBeenCalledTimes(6);
  });

  it("applies the jitter to the wait", async () => {
    vi.spyOn(Math, "random").mockReturnValue(0);
    const { retry } = setup();
    await advance(12_000 - 1);
    expect(retry).not.toHaveBeenCalled();
    await advance(1);
    expect(retry).toHaveBeenCalledTimes(1);
  });

  it("shows the remaining time", async () => {
    const { result } = setup();
    expect(result.current.remainingS).toBe(15);
    await advance(5_000);
    expect(result.current.remainingS).toBe(10);
  });

  it("Retry now fires at once and moves the schedule to the next step", async () => {
    const { retry, result } = setup();
    await advance(3_000);
    act(() => result.current.retryNow());
    await advance(0);
    expect(retry).toHaveBeenCalledTimes(1);
    expect(result.current.remainingS).toBe(30);
    await advance(30_000);
    expect(retry).toHaveBeenCalledTimes(2);
  });

  it("ignores Retry now while a retry is in flight", async () => {
    let settle!: () => void;
    const retry = vi.fn(() => new Promise<void>((r) => { settle = r; }));
    const cancel = vi.fn(() => Promise.resolve());
    const { result } = renderHook(() => useBusyAutoRetry("busy", { retry, cancel, resetKey: "d1" }));
    act(() => result.current.retryNow());
    await advance(0);
    expect(result.current.retrying).toBe(true);
    act(() => result.current.retryNow());
    act(() => result.current.retryNow());
    await advance(0);
    expect(retry).toHaveBeenCalledTimes(1);
    await act(async () => { settle(); });
    expect(result.current.retrying).toBe(false);
    expect(result.current.remainingS).toBe(30);
  });

  it("Cancel clears the timers and cancels", async () => {
    const { retry, cancel, result } = setup();
    act(() => result.current.cancel());
    expect(cancel).toHaveBeenCalledTimes(1);
    expect(result.current.remainingS).toBeNull();
    await advance(60 * 60 * 1000);
    expect(retry).not.toHaveBeenCalled();
  });

  it("keeps the schedule while a retry re-runs, and resets once the part ends otherwise", async () => {
    const { retry, result, rerender } = setup();
    await advance(15_000);
    rerender({ s: "running", k: "d1" });
    rerender({ s: "busy", k: "d1" });
    expect(result.current.remainingS).toBe(30); // next step, not back to 15
    rerender({ s: "done", k: "d1" });
    rerender({ s: "busy", k: "d1" });
    expect(result.current.remainingS).toBe(15);
    expect(retry).toHaveBeenCalledTimes(1);
  });

  it("a new draft resets the schedule", async () => {
    const { result, rerender } = setup();
    await advance(15_000);
    await advance(30_000);
    expect(result.current.remainingS).toBe(60);
    rerender({ s: "busy", k: "d2" });
    await advance(0);
    expect(result.current.remainingS).toBe(15);
  });

  it("never counts down for a part that isn't busy", async () => {
    const { retry, result } = setup("running");
    expect(result.current.busy).toBe(false);
    expect(result.current.remainingS).toBeNull();
    await advance(60 * 60 * 1000);
    expect(retry).not.toHaveBeenCalled();
  });
});

describe("BusyCountdown", () => {
  function Harness({ retry, cancel }: { retry: () => Promise<void>; cancel: () => Promise<void> }) {
    const state = useBusyAutoRetry("busy", { retry, cancel, resetKey: "d1" });
    return <BusyCountdown state={state} />;
  }

  it("renders the remaining time with Retry now and Cancel, then only manual Retry and Cancel", async () => {
    const retry = vi.fn(() => Promise.resolve());
    const cancel = vi.fn(() => Promise.resolve());
    render(<Harness retry={retry} cancel={cancel} />);
    expect(screen.getByTestId("busy-countdown").textContent).toContain("The model is busy. Next try in 00:15");
    expect(screen.getByRole("button", { name: "Retry now" })).toBeTruthy();
    expect(screen.getByRole("button", { name: "Cancel" })).toBeTruthy();
    for (const s of BUSY_RETRY_SCHEDULE_S) await advance(s * 1000);
    expect(retry).toHaveBeenCalledTimes(6);
    expect(screen.getByTestId("busy-countdown").textContent).toContain(BUSY_EXHAUSTED_COPY);
    expect(screen.queryByRole("button", { name: "Retry now" })).toBeNull();
    fireEvent.click(screen.getByRole("button", { name: "Retry" }));
    await advance(0);
    expect(retry).toHaveBeenCalledTimes(7);
    fireEvent.click(screen.getByRole("button", { name: "Cancel" }));
    expect(cancel).toHaveBeenCalledTimes(1);
  });

  it("disables both buttons while a retry is in flight", async () => {
    const retry = vi.fn(() => new Promise<void>(() => {}));
    const cancel = vi.fn(() => Promise.resolve());
    render(<Harness retry={retry as any} cancel={cancel} />);
    fireEvent.click(screen.getByRole("button", { name: "Retry now" }));
    await advance(0);
    expect((screen.getByRole("button", { name: "Retry now" }) as HTMLButtonElement).disabled).toBe(true);
    expect((screen.getByRole("button", { name: "Cancel" }) as HTMLButtonElement).disabled).toBe(true);
    fireEvent.click(screen.getByRole("button", { name: "Retry now" }));
    expect(retry).toHaveBeenCalledTimes(1);
  });
});
