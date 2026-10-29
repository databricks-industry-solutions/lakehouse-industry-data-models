/**
 * useInvalidateOnRunTerminal - refetch everything when a run that was in
 * flight lands in a terminal state.
 */
import { describe, expect, it, vi } from "vitest";
import { renderHook } from "@testing-library/react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import type { ReactNode } from "react";

import { useInvalidateOnRunTerminal } from "@/lib/hooks";

function setup(initial: { status?: string; scopeKey?: string }) {
  const queryClient = new QueryClient();
  const spy = vi.spyOn(queryClient, "invalidateQueries");
  const wrapper = ({ children }: { children: ReactNode }) => (
    <QueryClientProvider client={queryClient}>{children}</QueryClientProvider>
  );
  const hook = renderHook(
    (props: { status?: string; scopeKey?: string }) =>
      useInvalidateOnRunTerminal(props.status, props.scopeKey),
    { wrapper, initialProps: initial },
  );
  return { spy, ...hook };
}

describe("useInvalidateOnRunTerminal", () => {
  it("invalidates every query when a running run completes", () => {
    const { spy, rerender } = setup({ status: "running", scopeKey: "b1" });
    expect(spy).not.toHaveBeenCalled();
    rerender({ status: "completed", scopeKey: "b1" });
    expect(spy).toHaveBeenCalledTimes(1);
    expect(spy).toHaveBeenCalledWith();
  });

  it.each(["failed", "cancelled", "rolled_back_failed"])(
    "invalidates when a running run ends %s",
    (terminal) => {
      const { spy, rerender } = setup({ status: "running", scopeKey: "b1" });
      rerender({ status: terminal, scopeKey: "b1" });
      expect(spy).toHaveBeenCalledTimes(1);
    },
  );

  it("does nothing for a run first seen terminal, an unknown status or a non-terminal change", () => {
    const first = setup({ status: "completed", scopeKey: "b1" });
    expect(first.spy).not.toHaveBeenCalled();
    first.rerender({ status: undefined, scopeKey: "b1" });
    expect(first.spy).not.toHaveBeenCalled();

    const second = setup({ status: "pending", scopeKey: "b1" });
    second.rerender({ status: "running", scopeKey: "b1" });
    expect(second.spy).not.toHaveBeenCalled();
  });

  it("fires once per transition, not on every render", () => {
    const { spy, rerender } = setup({ status: "running", scopeKey: "b1" });
    rerender({ status: "completed", scopeKey: "b1" });
    rerender({ status: "completed", scopeKey: "b1" });
    expect(spy).toHaveBeenCalledTimes(1);
  });

  it("does not read a switch to another entity as a transition", () => {
    const { spy, rerender } = setup({ status: "running", scopeKey: "b1" });
    rerender({ status: "completed", scopeKey: "b2" });
    expect(spy).not.toHaveBeenCalled();
    rerender({ status: "running", scopeKey: "b2" });
    rerender({ status: "completed", scopeKey: "b2" });
    expect(spy).toHaveBeenCalledTimes(1);
  });
});
