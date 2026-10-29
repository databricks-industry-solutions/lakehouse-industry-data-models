/**
 * `lib/retry-time`: the one "next try" wording of the busy countdowns, the
 * feature gates' retry, the assessment ingest retry and the busy assessment run.
 */
import { describe, expect, it } from "vitest";
import { nextTryAt, nextTryIn, retryClock, sentence } from "@/lib/retry-time";

describe("nextTryIn", () => {
  it("formats a live countdown in seconds", () => {
    expect(nextTryIn(42)).toBe("next try in 00:42");
    expect(nextTryIn(600)).toBe("next try in 10:00");
  });
  it("says now at zero or below", () => {
    expect(nextTryIn(0)).toBe("next try now");
    expect(nextTryIn(-3)).toBe("next try now");
    expect(nextTryIn(Number.NaN)).toBe("next try now");
  });
});

describe("nextTryAt", () => {
  const now = Date.parse("2026-10-19T10:00:00Z");
  it("gives the relative wait and the local clock time", () => {
    expect(nextTryAt("2026-10-19T10:05:00Z", now)).toBe(`next try in 5 min (${retryClock("2026-10-19T10:05:00Z")})`);
    expect(nextTryAt("2026-10-19T10:00:20Z", now)).toBe(`next try in under a minute (${retryClock("2026-10-19T10:00:20Z")})`);
  });
  it("reads an offset-less backend timestamp as UTC", () => {
    expect(nextTryAt("2026-10-19T10:05:00", now)).toBe(nextTryAt("2026-10-19T10:05:00Z", now));
  });
  it("says soon when unset, past or unparseable", () => {
    expect(nextTryAt(null, now)).toBe("next try soon");
    expect(nextTryAt("2026-10-19T09:00:00Z", now)).toBe("next try soon");
    expect(nextTryAt("nope", now)).toBe("next try soon");
  });
});

describe("retryClock / sentence", () => {
  it("is empty for an unset or unparseable time", () => {
    expect(retryClock(undefined)).toBe("");
    expect(retryClock("nope")).toBe("");
  });
  it("capitalises the first letter", () => {
    expect(sentence("next try in 00:42")).toBe("Next try in 00:42");
    expect(sentence("")).toBe("");
  });
});
