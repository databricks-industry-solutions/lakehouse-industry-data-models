/**
 * `<VibeInputCard/>` (commit c) — chips, inline vs rich edit, checkbox
 * include/exclude, and the TEXTAREA-FILL REGRESSION (an internal tracker item):
 * the inline editor's controlled value must reflect every keystroke.
 */
import { describe, expect, it, vi } from "vitest";
import { fireEvent, render, screen } from "@testing-library/react";
import type { VibeInputOut } from "@/lib/api";
import { VibeInputCard } from "@/components/vibe-inputs/vibe-input-card";

const mk = (over: Partial<VibeInputOut> = {}): VibeInputOut => ({
  id: "vi-1",
  business_id: "biz-1",
  origin: "user",
  author: "a@b.c",
  text: "short rule",
  priority: "high",
  confidence_score: null,
  consumed: false,
  status: "active",
  selected_for_run: false,
  deprecated_by: null,
  created_at: "2026-01-01T00:00:00",
  updated_at: "2026-01-01T00:00:00",
  anchor: { level: "model_wide", path: [] },
  ...over,
});

function renderCard(over: Partial<VibeInputOut> = {}, props: Partial<Parameters<typeof VibeInputCard>[0]> = {}) {
  const handlers = {
    onToggleInclude: vi.fn(),
    onCommitText: vi.fn(),
    onOpenInModel: vi.fn(),
    onExpand: vi.fn(),
    onResolveReview: vi.fn(),
    onFocus: vi.fn(),
  };
  render(
    <VibeInputCard input={mk(over)} included {...handlers} {...props} />,
  );
  return handlers;
}

describe("VibeInputCard chips", () => {
  it("renders origin, priority, and (active → no) state chip", () => {
    renderCard();
    expect(screen.getByText("User")).toBeInTheDocument();
    expect(screen.getByText("High")).toBeInTheDocument();
    expect(screen.queryByText("Consumed")).not.toBeInTheDocument();
  });

  it("renders the AI origin chip for agent_next_vibe", () => {
    renderCard({ origin: "agent_next_vibe" });
    expect(screen.getByText("AI suggestion")).toBeInTheDocument();
  });

  it("renders the rejected-change origin chip for change_rejection", () => {
    renderCard({ origin: "change_rejection" });
    expect(screen.getByText("Rejected change")).toBeInTheDocument();
  });

  it("renders a defensive import origin label (unknown union member)", () => {
    renderCard({ origin: "uc_import" as VibeInputOut["origin"] });
    expect(screen.getByText("UC import")).toBeInTheDocument();
  });

  it("shows a Consumed chip when consumed and no flagged links", () => {
    renderCard({ consumed: true });
    expect(screen.getByText("Consumed")).toBeInTheDocument();
  });

  it("renders the review chip-button when a link needs review", () => {
    const handlers = renderCard({}, {
      links: [{ needs_link_review: true } as any],
    });
    const chip = screen.getByRole("button", { name: /Needs link review/ });
    fireEvent.click(chip);
    expect(handlers.onResolveReview).toHaveBeenCalled();
  });
});

describe("VibeInputCard editing", () => {
  it("short text → inline editable; ⌘↵ commits", () => {
    const handlers = renderCard({ text: "short rule" });
    fireEvent.click(screen.getByText("short rule"));
    const ta = screen.getByRole("textbox") as HTMLTextAreaElement;
    fireEvent.change(ta, { target: { value: "edited rule" } });
    fireEvent.keyDown(ta, { key: "Enter", metaKey: true });
    expect(handlers.onCommitText).toHaveBeenCalledWith("edited rule");
  });

  it("TEXTAREA-FILL REGRESSION: controlled value reflects every keystroke", () => {
    renderCard({ text: "abc" });
    fireEvent.click(screen.getByText("abc"));
    const ta = screen.getByRole("textbox") as HTMLTextAreaElement;
    fireEvent.change(ta, { target: { value: "a" } });
    expect((screen.getByRole("textbox") as HTMLTextAreaElement).value).toBe("a");
    fireEvent.change(ta, { target: { value: "a long multi word edit" } });
    expect((screen.getByRole("textbox") as HTMLTextAreaElement).value).toBe(
      "a long multi word edit",
    );
  });

  it("Esc reverts the inline edit without committing", () => {
    const handlers = renderCard({ text: "keep me" });
    fireEvent.click(screen.getByText("keep me"));
    const ta = screen.getByRole("textbox") as HTMLTextAreaElement;
    fireEvent.change(ta, { target: { value: "discard" } });
    fireEvent.keyDown(ta, { key: "Escape" });
    expect(handlers.onCommitText).not.toHaveBeenCalled();
    expect(screen.getByText("keep me")).toBeInTheDocument();
  });

  it("rich text → clamped preview + Rich text badge; click opens editor", () => {
    const long = "line one\nline two\nline three";
    const handlers = renderCard({ text: long });
    expect(screen.getByText("Rich text")).toBeInTheDocument();
    expect(screen.queryByRole("textbox")).not.toBeInTheDocument();
    fireEvent.click(screen.getByText("Click to open the full editor"));
    expect(handlers.onExpand).toHaveBeenCalled();
  });
});

describe("VibeInputCard include/exclude", () => {
  it("toggling the checkbox calls onToggleInclude and dims when excluded", () => {
    const onToggleInclude = vi.fn();
    const { rerender } = render(
      <VibeInputCard
        input={mk()}
        included
        onToggleInclude={onToggleInclude}
        onCommitText={vi.fn()}
        onOpenInModel={vi.fn()}
        onExpand={vi.fn()}
        onResolveReview={vi.fn()}
      />,
    );
    fireEvent.click(screen.getByRole("checkbox"));
    expect(onToggleInclude).toHaveBeenCalledWith(false);

    rerender(
      <VibeInputCard
        input={mk()}
        included={false}
        onToggleInclude={onToggleInclude}
        onCommitText={vi.fn()}
        onOpenInModel={vi.fn()}
        onExpand={vi.fn()}
        onResolveReview={vi.fn()}
      />,
    );
    // Text is kept even when excluded.
    expect(screen.getByText("short rule")).toBeInTheDocument();
    expect(screen.getByText("short rule").closest("[data-input-id]")).toHaveAttribute(
      "data-excluded",
      "true",
    );
  });
});

describe("VibeInputCard delete dialog", () => {
  it("tells the user where to restore the feedback", () => {
    renderCard({}, { onDelete: vi.fn() });
    fireEvent.click(screen.getByLabelText("Delete"));
    expect(screen.getByRole("alertdialog")).toHaveTextContent(/restore it from the Deprecated list on the inputs surface/);
  });
});
