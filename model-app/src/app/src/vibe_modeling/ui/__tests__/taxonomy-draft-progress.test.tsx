import { describe, it, expect, vi } from "vitest";
import { render, screen, fireEvent } from "@testing-library/react";
import { DraftProgress } from "@/components/taxonomy/draft-progress";

const part = (status: string) => ({ status });
const draft = {
  draft_id: "d1", status: "running",
  parts: { tree: part("done"), company: part("running"), channels: part("pending"), processes: part("done"),
    terminology: part("failed"), systems_of_record: part("running"), regulatory: part("done") },
} as any;

describe("DraftProgress", () => {
  it("lists every part with its state and offers Cancel while running", () => {
    const onCancel = vi.fn();
    render(<DraftProgress draft={draft} onCancel={onCancel} />);
    expect(screen.getByText("Domains")).toBeTruthy();
    expect(screen.getByTestId("part-tree").getAttribute("data-status")).toBe("done");
    expect(screen.getByTestId("part-terminology").getAttribute("data-status")).toBe("failed");
    expect(screen.getByText(/the model is drafting/i)).toBeTruthy();
    fireEvent.click(screen.getByRole("button", { name: "Cancel drafting" }));
    expect(onCancel).toHaveBeenCalled();
  });

  it("hides Cancel when finished", () => {
    render(<DraftProgress draft={{ ...draft, status: "done" }} onCancel={() => {}} />);
    expect(screen.queryByRole("button", { name: "Cancel drafting" })).toBeNull();
  });

  it("shows busy parts and the tree countdown it is given", () => {
    const busyDraft = { ...draft, status: "busy", parts: { ...draft.parts, company: part("busy"), channels: part("busy"), systems_of_record: part("done") } };
    const treeRetry = { busy: true, remainingS: 42, exhausted: false, retrying: false, retryNow: vi.fn(), cancel: vi.fn() };
    render(<DraftProgress draft={busyDraft} onCancel={() => {}} treeRetry={treeRetry} />);
    expect(screen.getByText("The model is busy")).toBeTruthy();
    expect(screen.getByTestId("part-company").getAttribute("data-status")).toBe("busy");
    expect(screen.getByTestId("tree-busy-countdown").textContent).toContain("Next try in 00:42");
    // Busy parts carry their own Cancel; the drafting Cancel is for running drafts.
    expect(screen.queryByRole("button", { name: "Cancel drafting" })).toBeNull();
    fireEvent.click(screen.getByRole("button", { name: "Retry now" }));
    expect(treeRetry.retryNow).toHaveBeenCalled();
  });
});
