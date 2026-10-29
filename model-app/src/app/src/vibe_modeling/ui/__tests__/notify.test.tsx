/**
 * `notifyError` / `openDetails` / `useErrorDetails` — the single
 * convergence point for error toasts (Track 8 item 2). Sonner's `toast.error`
 * is mocked so we can assert the persistent-toast options; the store is
 * exercised directly via `useSyncExternalStore` through a tiny test hook.
 */
import { describe, expect, it, vi, beforeEach, afterEach } from "vitest";
import { renderHook, act } from "@testing-library/react";
import { toast } from "sonner";
import { notifyError, notifyWarnings, openDetails, closeDetails, useErrorDetails } from "@/lib/notify";
import { ApiError } from "@/lib/api";

vi.mock("sonner", async () => {
  const actual = await vi.importActual<typeof import("sonner")>("sonner");
  return {
    ...actual,
    toast: {
      ...actual.toast,
      error: vi.fn(),
      success: vi.fn(),
      warning: vi.fn(),
    },
  };
});

describe("notifyError", () => {
  beforeEach(() => {
    vi.mocked(toast.error).mockClear();
    closeDetails();
  });

  it("raises a persistent toast with a Copy action for a plain string", () => {
    notifyError("Sector in use by 3 businesses");
    expect(toast.error).toHaveBeenCalledTimes(1);
    const [, opts] = vi.mocked(toast.error).mock.calls[0];
    expect(opts?.duration).toBe(Infinity);
    expect(opts?.closeButton).toBe(true);
    expect(opts?.action).toMatchObject({ label: "Copy" });
    expect(opts?.cancel).toMatchObject({ label: "Details" });
  });

  it("extracts the message from a thrown ApiError", () => {
    const err = new ApiError(409, "Conflict", { detail: { message: "in use" } });
    notifyError(err, { title: "Delete failed" });
    const [message, opts] = vi.mocked(toast.error).mock.calls[0];
    expect(message).toBe("Delete failed");
    expect(opts?.description).toBe("in use");
  });

  it("Copy writes the full detail to the clipboard", async () => {
    const writeText = vi.fn().mockResolvedValue(undefined);
    vi.stubGlobal("navigator", { clipboard: { writeText } });
    notifyError("boom");
    const [, opts] = vi.mocked(toast.error).mock.calls[0];
    const action = opts?.action as unknown as { onClick: () => void };
    action.onClick();
    expect(writeText).toHaveBeenCalledWith("boom");
    vi.unstubAllGlobals();
  });
});

describe("error details store", () => {
  afterEach(() => closeDetails());

  it("openDetails updates the store; the host would render the full text", () => {
    const { result } = renderHook(() => useErrorDetails());
    expect(result.current).toBeNull();
    act(() => openDetails("the full error text"));
    expect(result.current).toBe("the full error text");
    act(() => closeDetails());
    expect(result.current).toBeNull();
  });
});

describe("notifyWarnings", () => {
  beforeEach(() => vi.mocked(toast.warning).mockClear());

  it("shows the warnings as the description of one warning toast", () => {
    expect(notifyWarnings("Imported with warnings", ["First.", "Second."])).toBe(true);
    expect(toast.warning).toHaveBeenCalledWith("Imported with warnings", { description: "First. Second." });
  });

  it("shows nothing for no warnings", () => {
    expect(notifyWarnings("Imported with warnings", [])).toBe(false);
    expect(notifyWarnings("Imported with warnings", undefined)).toBe(false);
    expect(notifyWarnings("Imported with warnings", ["  "])).toBe(false);
    expect(toast.warning).not.toHaveBeenCalled();
  });
});
