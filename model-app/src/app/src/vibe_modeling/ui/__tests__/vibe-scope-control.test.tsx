import { describe, expect, it, vi } from "vitest";
import { fireEvent, render, screen } from "@testing-library/react";

import { VibeScopeControl, type VibeScopeControlProps } from "@/components/runs/vibe-scope-control";
import { renderWithRouter } from "./helpers/router-wrapper";
import { ICON_ONLY_HIT_TARGET } from "@/components/help/help-link";

async function setup(overrides: Partial<VibeScopeControlProps> = {}) {
  const props: VibeScopeControlProps = {
    scope: "all_domains",
    onScopeChange: vi.fn(),
    domainNames: ["meter_to_cash", "billing"],
    selectedDomains: [],
    onToggleDomain: vi.fn(),
    unknownDomains: [],
    onRemoveUnknown: vi.fn(),
    runMode: "dry",
    onRunModeChange: vi.fn(),
    catalog: "utility_cat",
    ...overrides,
  };
  renderWithRouter(<VibeScopeControl {...props} />);
  await screen.findByTestId("vibe-scope-control");
  return props;
}

describe("VibeScopeControl", () => {
  it("offers All domains and Some domains only (no Some Subdomains)", async () => {
    await setup();
    const scope = screen.getByRole("radiogroup", { name: "Scope" });
    expect(scope).toBeInTheDocument();
    expect(screen.getByRole("radio", { name: "All domains" })).toHaveAttribute("aria-checked", "true");
    expect(screen.getByRole("radio", { name: "Some domains" })).toHaveAttribute("aria-checked", "false");
    expect(screen.queryByText(/subdomain/i)).not.toBeInTheDocument();
    // No domain list under All domains.
    expect(screen.queryByTestId("vibe-scope-domains")).not.toBeInTheDocument();
  });

  it("calls onScopeChange when Some domains is clicked", async () => {
    const props = await setup();
    fireEvent.click(screen.getByRole("radio", { name: "Some domains" }));
    expect(props.onScopeChange).toHaveBeenCalledWith("some_domains");
  });

  it("renders a checkbox per domain under Some domains, checked by scopeKey", async () => {
    await setup({ scope: "some_domains", selectedDomains: ["Meter To Cash"] });
    expect(screen.getByRole("checkbox", { name: "meter_to_cash" })).toBeChecked();
    expect(screen.getByRole("checkbox", { name: "billing" })).not.toBeChecked();
  });

  it("fires onToggleDomain with the domain name and checked state", async () => {
    const props = await setup({ scope: "some_domains", selectedDomains: ["meter_to_cash"] });
    fireEvent.click(screen.getByRole("checkbox", { name: "billing" }));
    expect(props.onToggleDomain).toHaveBeenCalledWith("billing", true);
    fireEvent.click(screen.getByRole("checkbox", { name: "meter_to_cash" }));
    expect(props.onToggleDomain).toHaveBeenCalledWith("meter_to_cash", false);
  });

  it("shows a loading line while the domains load", async () => {
    await setup({ scope: "some_domains", domainNames: undefined });
    expect(screen.getByText(/Loading domains/)).toBeInTheDocument();
  });

  it("shows unknown names as error chips with the server message, removable", async () => {
    const props = await setup({
      scope: "some_domains",
      unknownDomains: ["meter2cash"],
      unknownMessages: { meter2cash: "'meter2cash' is not a domain of v7 ECM. Did you mean: meter_to_cash?" },
    });
    const chips = screen.getByTestId("vibe-scope-unknown");
    expect(chips).toHaveTextContent("Did you mean: meter_to_cash?");
    fireEvent.click(screen.getByRole("button", { name: "Remove meter2cash" }));
    expect(props.onRemoveUnknown).toHaveBeenCalledWith("meter2cash");
  });

  it("shows the Dry Run consequence by default", async () => {
    await setup();
    expect(screen.getByRole("radio", { name: "Dry Run" })).toHaveAttribute("aria-checked", "true");
    expect(screen.getByTestId("vibe-run-mode-consequence")).toHaveTextContent(
      /deploys no tables/,
    );
  });

  it("shows the Full Run consequence naming the catalog", async () => {
    const props = await setup({ runMode: "full" });
    const text = screen.getByTestId("vibe-run-mode-consequence");
    expect(text).toHaveTextContent(/Deploys to utility_cat\./);
    expect(text).toHaveTextContent(/it can still change tables in other domains/);
    expect(text).toHaveTextContent(/A table whose structure changes may be replaced and lose its rows/);
    expect(text).toHaveTextContent(/drops and rebuilds every schema this business owns/);
    fireEvent.click(screen.getByRole("radio", { name: "Dry Run" }));
    expect(props.onRunModeChange).toHaveBeenCalledWith("dry");
  });

  it("fullRunOnly disables Some domains and Dry Run, and clicks do nothing", async () => {
    const props = await setup({ runMode: "full", fullRunOnly: true, fullRunOnlyNoteId: "why" });
    const some = screen.getByRole("radio", { name: "Some domains" });
    const dry = screen.getByRole("radio", { name: "Dry Run" });
    expect(some).toBeDisabled();
    expect(dry).toBeDisabled();
    expect(screen.getByRole("radio", { name: "All domains" })).not.toBeDisabled();
    expect(screen.getByRole("radio", { name: "Full Run" })).not.toBeDisabled();
    fireEvent.click(some);
    fireEvent.click(dry);
    expect(props.onScopeChange).not.toHaveBeenCalled();
    expect(props.onRunModeChange).not.toHaveBeenCalled();
  });

  it("fullRunOnly links both groups to the explaining note", async () => {
    render(<p id="why">Full Run only. Agent too old.</p>);
    await setup({ runMode: "full", fullRunOnly: true, fullRunOnlyNoteId: "why" });
    for (const name of ["Scope", "Run type"]) {
      expect(screen.getByRole("radiogroup", { name })).toHaveAccessibleDescription(
        "Full Run only. Agent too old.",
      );
    }
  });

  it("without fullRunOnly the groups carry no description", async () => {
    await setup({ fullRunOnlyNoteId: "why" });
    expect(screen.getByRole("radiogroup", { name: "Scope" })).not.toHaveAttribute("aria-describedby");
    expect(screen.getByRole("radio", { name: "Some domains" })).not.toBeDisabled();
  });

  it("links the scope and run type labels to the Vibe Modeling help page", async () => {
    await setup();
    for (const name of ["How scope works", "Dry Run and Full Run"]) {
      const link = screen.getByRole("link", { name });
      expect(link).toHaveAttribute("href", "/help/run-vibe");
      // 14 px icon + 5 px padding each side = a 24 px hit target, offset by -5 px margins.
      for (const cls of ICON_ONLY_HIT_TARGET.split(" ")) expect(link).toHaveClass(cls);
    }
  });
});
