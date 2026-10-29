import { describe, it, expect, vi } from "vitest";
import { render, screen, fireEvent } from "@testing-library/react";
import { readdirSync, readFileSync } from "node:fs";
import { resolve } from "node:path";

vi.mock("@/components/business/sector-select", () => ({ SectorSelect: () => <div data-testid="sector-select" /> }));
import { IntakeForm } from "@/components/taxonomy/intake-form";

describe("IntakeForm", () => {
  it("requires company + industry and submits the intake", () => {
    const onDraft = vi.fn();
    render(<IntakeForm onDraft={onDraft} onSkip={() => {}} submitting={false} />);
    const draftBtn = screen.getByRole("button", { name: /draft with the model/i });
    expect((draftBtn as HTMLButtonElement).disabled).toBe(true);
    fireEvent.change(screen.getByLabelText(/company name/i), { target: { value: "Ridgeline Energy" } });
    fireEvent.change(screen.getByLabelText(/^industry/i), { target: { value: "Electric & gas utility" } });
    fireEvent.click(draftBtn);
    expect(onDraft.mock.calls[0][0]).toMatchObject({ company_name: "Ridgeline Energy", industry: "Electric & gas utility" });
  });

  it("rejects a company name the business API would reject", () => {
    render(<IntakeForm onDraft={() => {}} onSkip={() => {}} submitting={false} />);
    fireEvent.change(screen.getByLabelText(/company name/i), { target: { value: "Ridgeline / Gas" } });
    fireEvent.change(screen.getByLabelText(/^industry/i), { target: { value: "Utility" } });
    expect(screen.getByText(/letters, numbers, spaces/i)).toBeTruthy();
    expect((screen.getByRole("button", { name: /draft with the model/i }) as HTMLButtonElement).disabled).toBe(true);
  });

  it("offers Start blank and Start from the Ridgeline example as skip options", () => {
    const onSkip = vi.fn();
    render(<IntakeForm onDraft={() => {}} onSkip={onSkip} submitting={false} />);
    fireEvent.change(screen.getByLabelText(/company name/i), { target: { value: "Acme" } });
    fireEvent.change(screen.getByLabelText(/^industry/i), { target: { value: "Utility" } });
    fireEvent.click(screen.getByRole("button", { name: "Start blank" }));
    fireEvent.click(screen.getByRole("button", { name: "Start from the Ridgeline example" }));
    expect(onSkip.mock.calls.map((c) => c[2])).toEqual(["blank", "example"]);
    expect(onSkip.mock.calls[0][0]).toMatchObject({ company_name: "Acme", industry: "Utility" });
  });
});

describe("Domain Taxonomy Builder copy", () => {
  // The drafter is whichever model service the admin configured, so no vendor name in the wizard.
  const dir = resolve(__dirname, "../components/taxonomy");
  it.each(readdirSync(dir).filter((f) => f.endsWith(".tsx")))("%s does not mention Claude", (file) => {
    expect(readFileSync(resolve(dir, file), "utf8")).not.toMatch(/claude/i);
  });
});
