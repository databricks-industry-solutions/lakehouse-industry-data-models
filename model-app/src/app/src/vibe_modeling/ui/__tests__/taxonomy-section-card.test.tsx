import { afterEach, describe, it, expect, vi } from "vitest";
import { act, render, screen, fireEvent } from "@testing-library/react";
import { useState } from "react";
import { SectionCard } from "@/components/taxonomy/section-card";

const section = { claims: [
  { text: "A CIS owns billing.", provenance: "industry" as const },
  { text: "Runs Oracle CC&B.", provenance: "confirm" as const },
] };

describe("SectionCard", () => {
  it("shows a spinner while drafting", () => {
    render(<SectionCard sectionKey="company" partStatus="running" exampleText="ex" onChange={() => {}} onRetry={() => {}} />);
    expect(screen.getByText(/drafting/i)).toBeTruthy();
  });

  it("shows Retry on failure", () => {
    const onRetry = vi.fn();
    render(<SectionCard sectionKey="company" partStatus="failed" partError="boom" exampleText="ex" onChange={() => {}} onRetry={onRetry} />);
    fireEvent.click(screen.getByRole("button", { name: /retry/i }));
    expect(onRetry).toHaveBeenCalled();
  });

  it.each(["timed_out", "cancelled"])("shows Retry for %s", (s) => {
    render(<SectionCard sectionKey="company" partStatus={s} exampleText="ex" onChange={() => {}} onRetry={() => {}} />);
    expect(screen.getByRole("button", { name: /retry/i })).toBeTruthy();
  });

  it.each(["failed", "timed_out", "cancelled"])("still shows the error and Retry for a %s part that already has a section", (st) => {
    const onRetry = vi.fn();
    render(<SectionCard sectionKey="company" section={section} partStatus={st} partError="boom" exampleText="ex" onChange={() => {}} onRetry={onRetry} />);
    expect(screen.getByText("boom")).toBeTruthy();
    fireEvent.click(screen.getByRole("button", { name: /retry/i }));
    expect(onRetry).toHaveBeenCalled();
  });

  it("never shows Retry for a done part", () => {
    render(<SectionCard sectionKey="company" section={section} partStatus="done" exampleText="ex" onChange={() => {}} onRetry={() => {}} />);
    expect(screen.queryByRole("button", { name: /retry/i })).toBeNull();
  });

  const mk = (onChange = vi.fn(), sec: any = section, key = "systems_of_record") =>
    render(<SectionCard sectionKey={key} section={sec} partStatus="done" exampleText="ex" onChange={onChange} onRetry={() => {}} />);

  it("shows a blurb for what the section is for", () => {
    mk();
    expect(screen.getByText(/which systems are the source of truth/i)).toBeTruthy();
  });

  it("groups industry claims in ONE From the model textarea, one per line", () => {
    mk(vi.fn(), { claims: [
      { text: "A CIS owns billing.", provenance: "industry" },
      { text: "Meters feed an MDM.", provenance: "industry" },
      { text: "Runs Oracle CC&B.", provenance: "confirm" },
    ] });
    const box = screen.getByLabelText(/from the model/i) as HTMLTextAreaElement;
    expect(box.value).toBe("A CIS owns billing.\nMeters feed an MDM.");
    expect(screen.getByText(/typical for your industry/i)).toBeTruthy();
    expect(box.className).not.toMatch(/overflow-y-auto|overflow-auto/);
  });

  it("editing the model block re-splits on newlines, drops blanks, keeps the industry tag", () => {
    const onChange = vi.fn();
    mk(onChange);
    fireEvent.change(screen.getByLabelText(/from the model/i), { target: { value: "One.\n\nTwo.\nThree." } });
    expect(onChange.mock.calls[0][0].claims).toEqual([
      { text: "One.", provenance: "industry" },
      { text: "Two.", provenance: "industry" },
      { text: "Three.", provenance: "industry" },
      { text: "Runs Oracle CC&B.", provenance: "confirm" },
    ]);
  });

  it("lists confirm claims as a checklist; editing keeps the confirm tag", () => {
    const onChange = vi.fn();
    mk(onChange);
    expect(screen.getByText(/the model guessed/i)).toBeTruthy();
    fireEvent.change(screen.getByDisplayValue("Runs Oracle CC&B."), { target: { value: "Runs SAP IS-U." } });
    expect(onChange.mock.calls[0][0].claims[1]).toEqual({ text: "Runs SAP IS-U.", provenance: "confirm" });
  });

  it("checking a confirm claim converts it to a user claim in Your notes", () => {
    const onChange = vi.fn();
    mk(onChange, { claims: [...section.claims, { text: "Mine.", provenance: "user" }] });
    fireEvent.click(screen.getByRole("checkbox"));
    expect(onChange.mock.calls[0][0].claims).toEqual([
      { text: "A CIS owns billing.", provenance: "industry" },
      { text: "Mine.", provenance: "user" },
      { text: "Runs Oracle CC&B.", provenance: "user" },
    ]);
  });

  it("removes a confirm claim", () => {
    const onChange = vi.fn();
    mk(onChange);
    fireEvent.click(screen.getByRole("button", { name: /remove claim/i }));
    expect(onChange.mock.calls[0][0].claims).toEqual([{ text: "A CIS owns billing.", provenance: "industry" }]);
  });

  it("hides the checklist when there are no confirm claims", () => {
    mk(vi.fn(), { claims: [{ text: "A.", provenance: "industry" }] });
    expect(screen.queryByText(/the model guessed/i)).toBeNull();
  });

  it("Your notes is one textarea with a placeholder; typing makes user claims", () => {
    const onChange = vi.fn();
    mk(onChange);
    const notes = screen.getByLabelText(/your notes/i) as HTMLTextAreaElement;
    expect(notes.placeholder).toMatch(/add anything the model missed/i);
    fireEvent.change(notes, { target: { value: "Ours.\nAlso ours." } });
    expect(onChange.mock.calls[0][0].claims.slice(2)).toEqual([
      { text: "Ours.", provenance: "user" },
      { text: "Also ours.", provenance: "user" },
    ]);
  });

  it("toggles the Ridgeline example", () => {
    render(<SectionCard sectionKey="company" section={section} partStatus="done" exampleText="Ridgeline is a utility." onChange={() => {}} onRetry={() => {}} />);
    fireEvent.click(screen.getByRole("button", { name: /see a finished example/i }));
    expect(screen.getByText("Ridgeline is a utility.")).toBeTruthy();
  });

  const Harness = ({ onSpy }: { onSpy?: (c: any[]) => void }) => {
    const [sec, setSec] = useState<any>({ claims: [{ text: "Only one.", provenance: "industry" }] });
    return <SectionCard sectionKey="company" section={sec} partStatus="done" exampleText="ex"
      onChange={(s) => { onSpy?.(s.claims); setSec(s); }} onRetry={() => {}} />;
  };

  it("keeps the From the model block mounted after it is cleared, and it accepts new text", () => {
    render(<Harness />);
    fireEvent.change(screen.getByLabelText(/from the model/i), { target: { value: "" } });
    const box = screen.getByLabelText(/from the model/i) as HTMLTextAreaElement;
    expect(box.value).toBe("");
    fireEvent.change(box, { target: { value: "Back again." } });
    expect((screen.getByLabelText(/from the model/i) as HTMLTextAreaElement).value).toBe("Back again.");
  });

  it("keeps a trailing newline, emits no blank claim, and the next line becomes a second claim",  () => {
    let last: any[] = [];
    render(<Harness onSpy={(c) => { last = c; }} />);
    const notes = screen.getByLabelText(/your notes/i) as HTMLTextAreaElement;
    fireEvent.change(notes, { target: { value: "First\n" } }); // what typing First then Enter produces
    expect(notes.value.endsWith("\n")).toBe(true);
    expect(last.every((c) => c.text.trim() !== "")).toBe(true);
    fireEvent.change(notes, { target: { value: "First\nSecond" } });
    expect(last.filter((c) => c.provenance === "user").map((c) => c.text)).toEqual(["First", "Second"]);
  });

  describe("busy", () => {
    afterEach(() => {
      vi.useRealTimers();
      vi.restoreAllMocks();
    });

    it("counts down and retries this section on its own", async () => {
      vi.useFakeTimers();
      vi.spyOn(Math, "random").mockReturnValue(0.5);
      const onRetry = vi.fn(() => Promise.resolve());
      const onCancel = vi.fn(() => Promise.resolve());
      render(<SectionCard sectionKey="company" partStatus="busy" partError="The model is busy" exampleText="ex"
        onChange={() => {}} onRetry={onRetry} onCancel={onCancel} draftId="d1" />);
      expect(screen.getByTestId("busy-countdown-company").textContent).toContain("Next try in 00:15");
      await act(async () => { await vi.advanceTimersByTimeAsync(15_000); });
      expect(onRetry).toHaveBeenCalledTimes(1);
      fireEvent.click(screen.getByRole("button", { name: "Cancel" }));
      expect(onCancel).toHaveBeenCalledTimes(1);
    });

    it("only waits while the tree is busy: no countdown, no retry", async () => {
      vi.useFakeTimers();
      const onRetry = vi.fn();
      render(<SectionCard sectionKey="company" partStatus="busy" partError="waiting for the domains" exampleText="ex"
        onChange={() => {}} onRetry={onRetry} waitingForTree draftId="d1" />);
      expect(screen.getByText(/waiting for the domains/i)).toBeTruthy();
      expect(screen.queryByTestId("busy-countdown-company")).toBeNull();
      await act(async () => { await vi.advanceTimersByTimeAsync(60 * 60 * 1000); });
      expect(onRetry).not.toHaveBeenCalled();
    });

    it("doesn't count down for a section the user already has", () => {
      render(<SectionCard sectionKey="company" section={section} partStatus="busy" exampleText="ex"
        onChange={() => {}} onRetry={() => {}} draftId="d1" />);
      expect(screen.queryByTestId("busy-countdown-company")).toBeNull();
    });
  });
});
