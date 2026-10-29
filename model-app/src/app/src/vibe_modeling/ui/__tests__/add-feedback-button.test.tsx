import { describe, it, expect, vi } from "vitest";
import { render, screen, fireEvent } from "@testing-library/react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import type { ReactNode } from "react";

vi.mock("@/lib/api", async () => {
  return {
    createVibeInput: vi.fn().mockResolvedValue({ data: { id: "vi1", text: "mock" } }),
    listVibeInputsKey: (params: unknown) => ["/api/businesses/{business_id}/inputs", params],
    VibeInputOrigin: { user: "user", agent_next_vibe: "agent_next_vibe" },
    VibeInputPriority: { high: "high", medium: "medium", low: "low" },
  };
});

import { AddFeedbackButton } from "@/components/feedback/add-feedback-button";
import { resetFeedbackDrafts } from "@/components/feedback/feedback-draft";

function withQuery(ui: ReactNode) {
  const qc = new QueryClient({ defaultOptions: { queries: { retry: false } } });
  return <QueryClientProvider client={qc}>{ui}</QueryClientProvider>;
}

describe("AddFeedbackButton — F underline + F shortcut", () => {
  const button = () => withQuery(<AddFeedbackButton businessId="b1" getContext={() => ({})} />);
  const dialogOpen = () => screen.queryByRole("button", { name: /save feedback/i }) !== null;

  it("underlines the F in the default label", () => {
    const { container } = render(button());
    // Visible underline. The `<u>` element is rendered inside the trigger
    // button so the F shortcut is discoverable.
    const u = container.querySelector("button u");
    expect(u).not.toBeNull();
    expect(u?.textContent).toBe("F");
  });

  it("opens the dialog on click", () => {
    render(button());
    fireEvent.click(screen.getByRole("button", { name: /add feedback/i }));
    expect(dialogOpen()).toBe(true);
  });

  it("opens the dialog when 'f' or 'F' is pressed", () => {
    const { unmount } = render(button());
    fireEvent.keyDown(window, { key: "f" });
    expect(dialogOpen()).toBe(true);
    unmount();
    resetFeedbackDrafts();
    render(button());
    fireEvent.keyDown(window, { key: "F" });
    expect(dialogOpen()).toBe(true);
  });

  it("ignores 'f' with a modifier, in an INPUT or TEXTAREA, or inside a [role=dialog]", () => {
    render(
      withQuery(
        <>
          <textarea data-testid="ta" defaultValue="" />
          <input data-testid="inp" />
          <div role="dialog">
            <button data-testid="dialog-btn">inside</button>
          </div>
          <AddFeedbackButton businessId="b1" getContext={() => ({})} />
        </>,
      ),
    );
    fireEvent.keyDown(window, { key: "f", metaKey: true });
    fireEvent.keyDown(window, { key: "f", ctrlKey: true });
    fireEvent.keyDown(window, { key: "F", shiftKey: true });
    (screen.getByTestId("ta") as HTMLTextAreaElement).focus();
    fireEvent.keyDown(window, { key: "f" });
    (screen.getByTestId("inp") as HTMLInputElement).focus();
    fireEvent.keyDown(window, { key: "f" });
    (screen.getByTestId("dialog-btn") as HTMLButtonElement).focus();
    fireEvent.keyDown(window, { key: "f" });
    expect(dialogOpen()).toBe(false);
  });
});

describe("AddFeedbackButton — disabled where there is no model content", () => {
  const reason = "Feedback is about the model and its contents.";

  it("renders disabled, shows the reason as a tooltip, and never opens", async () => {
    const getContext = vi.fn().mockReturnValue({});
    render(
      withQuery(
        <AddFeedbackButton businessId="b1" versionId="v1" getContext={getContext} disabledReason={reason} />,
      ),
    );
    const button = screen.getByRole("button", { name: /add feedback/i });
    expect(button).toBeDisabled();
    fireEvent.click(button);
    fireEvent.keyDown(window, { key: "f" });
    expect(getContext).not.toHaveBeenCalled();
    expect(screen.queryByRole("button", { name: /save feedback/i })).not.toBeInTheDocument();

    fireEvent.focus(screen.getByTestId("add-feedback-disabled"));
    expect((await screen.findAllByText(reason)).length).toBeGreaterThan(0);
  });
});

describe("AddFeedbackButton — a draft survives a surface without model content", () => {
  it("keeps the open dialog and its text while the trigger is disabled", () => {
    const ui = (reason?: string) =>
      withQuery(
        <AddFeedbackButton businessId="b1" versionId="v1" getContext={() => ({})} disabledReason={reason} />,
      );
    const { rerender } = render(ui());
    fireEvent.click(screen.getByRole("button", { name: /add feedback/i }));
    fireEvent.change(screen.getByRole("textbox"), { target: { value: "a draft" } });

    rerender(ui("Feedback is about the model and its contents."));
    expect(screen.getByRole("button", { name: /add feedback/i })).toBeDisabled();
    expect(screen.getByRole("textbox")).toHaveValue("a draft");

    rerender(ui());
    expect(screen.getByRole("textbox")).toHaveValue("a draft");
  });
});
