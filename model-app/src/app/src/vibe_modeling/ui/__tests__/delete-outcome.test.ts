/**
 * `lib/delete-outcome` is what the user is told after a delete or an orphan
 * drop: the one cleanup-outcome toast (success, or a warning counting the
 * unfinished `_metamodel` cleanups, with the Retry cleanup words of the
 * calling surface) and the answer-lost notice for a proxy 502/503/504.
 */
import { afterEach, describe, expect, it, vi } from "vitest";

vi.mock("sonner", () => ({ toast: { success: vi.fn(), warning: vi.fn(), error: vi.fn() } }));
vi.mock("@/lib/notify", () => ({ notifyError: vi.fn() }));

import { toast } from "sonner";
import { ApiError, BusinessKind } from "@/lib/api";
import { notifyError } from "@/lib/notify";
import {
  DELETE_MAY_BE_FINISHING,
  countUnfinishedCleanups,
  isLostDeleteAnswer,
  notifyBusinessDeleted,
  notifyCleanupOutcome,
  notifyDeleteFailed,
  retryCleanupAfterRecreate,
  retryCleanupInExplorer,
} from "@/lib/delete-outcome";

afterEach(() => vi.clearAllMocks());

describe("notifyCleanupOutcome", () => {
  it("is a success toast when every cleanup finished", () => {
    notifyCleanupOutcome({ title: "v5 deleted.", unfinished: 0, retryHint: retryCleanupInExplorer(BusinessKind.business) });
    expect(toast.success).toHaveBeenCalledWith("v5 deleted.");
    expect(toast.warning).not.toHaveBeenCalled();
  });

  it("warns with the count and the surface's Retry cleanup words", () => {
    notifyCleanupOutcome({ title: "v5 deleted.", unfinished: 3, retryHint: retryCleanupInExplorer(BusinessKind.business) });
    expect(toast.success).not.toHaveBeenCalled();
    expect(toast.warning).toHaveBeenCalledWith("v5 deleted.", {
      description:
        "3 registry cleanups did not finish, so the agent's registry rows are still there. " +
        "The app retries at the next start-ups. " +
        "Retry cleanup on the business's Explorer page runs the retry now.",
    });
  });

  it("names the owner by kind: an industry's Explorer page, 'An industry created again'", () => {
    expect(retryCleanupInExplorer(BusinessKind.industry)).toBe(
      "Retry cleanup on the industry's Explorer page runs the retry now.",
    );
    expect(retryCleanupAfterRecreate(BusinessKind.industry)).toBe(
      "An industry created again with this name lists the retries with Retry cleanup.",
    );
    expect(retryCleanupAfterRecreate(BusinessKind.business)).toBe(
      "A business created again with this name lists the retries with Retry cleanup.",
    );
  });

  it("says 'cleanup' for one", () => {
    notifyCleanupOutcome({ title: "t", unfinished: 1, retryHint: "Hint." });
    const [, opts] = vi.mocked(toast.warning).mock.calls[0] as [string, { description: string }];
    expect(opts.description).toMatch(/^1 registry cleanup did not finish,/);
  });
});

describe("countUnfinishedCleanups", () => {
  it("counts failed and pending, not done; a missing summary is zero", () => {
    expect(countUnfinishedCleanups({ done: 4, pending: 2, failed: 1 })).toBe(3);
    expect(countUnfinishedCleanups({ done: 4 })).toBe(0);
    expect(countUnfinishedCleanups(undefined)).toBe(0);
    expect(countUnfinishedCleanups(null)).toBe(0);
  });
});

describe("notifyBusinessDeleted", () => {
  it("says the kind when no name is given and every cleanup finished", () => {
    notifyBusinessDeleted(
      { ok: true, cascaded: true, metamodel_cleanup: { done: 3, pending: 0, failed: 0 } },
      BusinessKind.industry,
    );
    expect(toast.success).toHaveBeenCalledWith("Industry deleted");
    expect(toast.warning).not.toHaveBeenCalled();
  });

  it("treats a response without a cleanup summary as finished", () => {
    notifyBusinessDeleted({ ok: true, cascaded: false }, BusinessKind.business, "Acme Co");
    expect(toast.success).toHaveBeenCalledWith('Deleted "Acme Co"');
  });

  it("counts failed and pending cleanups, not catalogs, and points to a re-created business", () => {
    notifyBusinessDeleted(
      { ok: true, cascaded: true, metamodel_cleanup: { done: 0, pending: 2, failed: 1 } },
      BusinessKind.business,
    );
    expect(toast.success).not.toHaveBeenCalled();
    const [title, opts] = vi.mocked(toast.warning).mock.calls[0] as [string, { description: string }];
    expect(title).toBe("Business deleted");
    expect(opts.description).toBe(
      "3 registry cleanups did not finish, so the agent's registry rows are still there. " +
        "The app retries at the next start-ups. " +
        "A business created again with this name lists the retries with Retry cleanup.",
    );
  });
});

describe("isLostDeleteAnswer", () => {
  it.each([502, 503, 504])("is true for a proxy %s with no app answer", (status) => {
    expect(isLostDeleteAnswer(new ApiError(status, "Bad Gateway", null))).toBe(true);
    expect(isLostDeleteAnswer(new ApiError(status, "Bad Gateway", "Gateway Timeout"))).toBe(true);
  });

  it("is false for a 503 the app sent itself (it has a detail)", () => {
    const body = { detail: { error: "orphan_check_failed", message: "The catalog could not be listed." } };
    expect(isLostDeleteAnswer(new ApiError(503, "Service Unavailable", body))).toBe(false);
  });

  it("is false for an app 4xx or 500 and for a non-ApiError", () => {
    expect(isLostDeleteAnswer(new ApiError(409, "Conflict", { detail: "busy" }))).toBe(false);
    expect(isLostDeleteAnswer(new ApiError(500, "Server Error", null))).toBe(false);
    expect(isLostDeleteAnswer(new Error("boom"))).toBe(false);
  });
});

describe("notifyDeleteFailed", () => {
  it("warns that the delete may still be finishing and returns true on a lost answer", () => {
    expect(notifyDeleteFailed(new ApiError(504, "Gateway Timeout", null), { title: "Delete failed" })).toBe(true);
    expect(toast.warning).toHaveBeenCalledWith(DELETE_MAY_BE_FINISHING);
    expect(notifyError).not.toHaveBeenCalled();
  });

  it("hands any other failure to notifyError and returns false", () => {
    const err = new ApiError(409, "Conflict", { detail: "busy" });
    expect(notifyDeleteFailed(err, { title: "Delete failed" })).toBe(false);
    expect(notifyError).toHaveBeenCalledWith(err, { title: "Delete failed" });
    expect(toast.warning).not.toHaveBeenCalled();
  });
});
