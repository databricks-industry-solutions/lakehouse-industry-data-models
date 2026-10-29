/**
 * Bounded wait for one request.
 *
 * `withRequestTimeout(ms, run)` hands `run` an `AbortSignal` to pass as the
 * fetch option and rejects with `RequestTimeoutError` once `ms` pass. The race
 * settles the wait even when `run` ignores the signal.
 */
export class RequestTimeoutError extends Error {
  readonly timeoutMs: number;

  constructor(timeoutMs: number) {
    super(`request timed out after ${timeoutMs}ms`);
    this.name = "RequestTimeoutError";
    this.timeoutMs = timeoutMs;
  }
}

export async function withRequestTimeout<T>(
  timeoutMs: number,
  run: (signal: AbortSignal) => Promise<T>,
): Promise<T> {
  const ctrl = new AbortController();
  let timer: ReturnType<typeof setTimeout> | undefined;
  const expired = new Promise<never>((_, reject) => {
    timer = setTimeout(() => {
      ctrl.abort();
      reject(new RequestTimeoutError(timeoutMs));
    }, timeoutMs);
  });
  try {
    return await Promise.race([run(ctrl.signal), expired]);
  } catch (err) {
    if (err instanceof DOMException && err.name === "AbortError") {
      throw new RequestTimeoutError(timeoutMs);
    }
    throw err;
  } finally {
    clearTimeout(timer);
  }
}
