import { afterEach, describe, expect, it, vi } from "vitest";
import { RequestTimeoutError, withRequestTimeout } from "@/lib/request-timeout";

describe("withRequestTimeout", () => {
  afterEach(() => vi.useRealTimers());

  it("returns the value of a request that answers in time and clears its timer", async () => {
    vi.useFakeTimers();
    await expect(withRequestTimeout(1_000, async () => "ok")).resolves.toBe("ok");
    expect(vi.getTimerCount()).toBe(0);
  });

  it("rejects with RequestTimeoutError and aborts the signal when the request is still pending", async () => {
    vi.useFakeTimers();
    let seen: AbortSignal | undefined;
    const pending = withRequestTimeout(1_000, (signal) => {
      seen = signal;
      return new Promise<never>(() => {});
    });
    const assertion = expect(pending).rejects.toBeInstanceOf(RequestTimeoutError);
    await vi.advanceTimersByTimeAsync(1_000);
    await assertion;
    expect(seen?.aborted).toBe(true);
  });

  it("maps an abort rejection from the request to RequestTimeoutError", async () => {
    await expect(
      withRequestTimeout(1_000, () => Promise.reject(new DOMException("aborted", "AbortError"))),
    ).rejects.toBeInstanceOf(RequestTimeoutError);
  });

  it("passes other errors through", async () => {
    const boom = new Error("boom");
    await expect(withRequestTimeout(1_000, () => Promise.reject(boom))).rejects.toBe(boom);
  });
});
