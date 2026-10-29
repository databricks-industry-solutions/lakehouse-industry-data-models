import { describe, it, expect, vi } from "vitest";
import { act, fireEvent, render, screen, within } from "@testing-library/react";
import { useState } from "react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";

import {
  DeploymentCatalogPicker,
  type CatalogOption,
} from "@/components/runs/deployment-catalog-picker";

// These tests cover the listing and filtering; the access checks are in
// deployment-catalog-picker-capabilities.test.tsx. A check that never answers
// keeps every option unmarked here.
vi.mock("@/lib/api", async (importOriginal) => ({
  ...(await importOriginal<typeof import("@/lib/api")>()),
  getCatalogCapabilities: vi.fn(() => new Promise(() => {})),
}));

/**
 * Tests for the Deployment Catalog picker (#111).
 *
 * Covers the bug where typing a matching substring in the combobox surfaced
 * "No catalogs match" even when the matching `[role="option"]` was in the
 * DOM. Root cause: cmdk's built-in `filter` scoring was flagging matches as
 * hidden in the a11y tree under certain input patterns. The fix delegates
 * filtering to us (`shouldFilter={false}`) and filters the list ourselves.
 */

const CATALOGS: CatalogOption[] = [
  { name: "vibe_modeling_test" },
  { name: "Vibe_Modeling_Prod" }, // mixed case — checks case-insensitivity
  { name: "finance_prod" },
  { name: "marketing_dev" },
];

function Harness({
  initial = "",
  catalogs = CATALOGS,
  loading = false,
  error = false,
}: {
  initial?: string;
  catalogs?: CatalogOption[];
  loading?: boolean;
  error?: boolean;
}) {
  const [value, setValue] = useState(initial);
  return (
    <DeploymentCatalogPicker
      value={value}
      onChange={setValue}
      catalogsOverride={loading || error ? undefined : catalogs}
      loadingOverride={loading}
      errorOverride={error}
    />
  );
}

// jsdom polyfills for scrollIntoView / pointer-capture (Radix Popover + cmdk
// CommandItem need these) live in ``__tests__/setup.ts`` and apply globally.

function renderWithClient(ui: React.ReactElement) {
  const qc = new QueryClient({
    defaultOptions: { queries: { retry: false, staleTime: Infinity } },
  });
  return render(<QueryClientProvider client={qc}>{ui}</QueryClientProvider>);
}

function openPopover() {
  // The trigger has role="combobox".
  const trigger = screen.getByRole("combobox");
  act(() => {
    fireEvent.click(trigger);
  });
}

function getFilterInput(): HTMLInputElement {
  return screen.getByPlaceholderText(
    /Filter or type a new catalog name/i,
  ) as HTMLInputElement;
}

describe("DeploymentCatalogPicker (#111)", () => {
  it("shows a disabled 'Loading catalogs…' button while loading", () => {
    // Phase 4.5 walkthrough: the previous behaviour rendered a plain
    // <Input> during loading, which made the picker look like it had
    // disappeared. Now it shows a disabled popover-style button so the
    // user knows the dropdown is still arriving.
    renderWithClient(<Harness loading />);
    const loadingBtn = screen.getByTestId("deployment-catalog-loading");
    expect(loadingBtn).toBeInTheDocument();
    expect(loadingBtn).toBeDisabled();
    expect(loadingBtn).toHaveTextContent(/Loading catalogs/i);
  });

  it("falls back to a plain text input on fetch error", () => {
    renderWithClient(<Harness error />);
    expect(
      screen.getByTestId("deployment-catalog-fallback-input"),
    ).toBeInTheDocument();
  });

  it("lists all catalogs, sorted case-insensitively, when opened with no filter", () => {
    renderWithClient(<Harness />);
    openPopover();

    // Each catalog name appears as an option.
    for (const c of CATALOGS) {
      expect(screen.getByText(c.name)).toBeInTheDocument();
    }

    // No "No catalogs match" message when there's no filter.
    expect(screen.queryByText(/No catalogs match/i)).not.toBeInTheDocument();

    // Sorted case-insensitively: "finance_prod" before "marketing_dev" before
    // "Vibe_Modeling_Prod" / "vibe_modeling_test". Verify by scanning rendered
    // option text in document order.
    const optionTexts = screen
      .getAllByRole("option")
      .map((el) => el.textContent?.trim());
    const idxFinance = optionTexts.findIndex((t) => t === "finance_prod");
    const idxMarketing = optionTexts.findIndex((t) => t === "marketing_dev");
    const idxVibe1 = optionTexts.findIndex((t) => t === "Vibe_Modeling_Prod");
    const idxVibe2 = optionTexts.findIndex((t) => t === "vibe_modeling_test");
    expect(idxFinance).toBeGreaterThanOrEqual(0);
    expect(idxMarketing).toBeGreaterThan(idxFinance);
    // Both Vibe_* entries must follow finance/marketing alphabetically.
    expect(Math.min(idxVibe1, idxVibe2)).toBeGreaterThan(idxMarketing);
  });

  it("filters case-insensitively — typing 'vibe' matches 'vibe_modeling_test' and 'Vibe_Modeling_Prod'", () => {
    renderWithClient(<Harness />);
    openPopover();
    const input = getFilterInput();
    act(() => {
      fireEvent.change(input, { target: { value: "vibe" } });
    });

    expect(screen.getByText("vibe_modeling_test")).toBeInTheDocument();
    expect(screen.getByText("Vibe_Modeling_Prod")).toBeInTheDocument();

    // Non-matching entries should NOT be rendered as options.
    expect(screen.queryByText("finance_prod")).not.toBeInTheDocument();
    expect(screen.queryByText("marketing_dev")).not.toBeInTheDocument();

    // And, critically, "No catalogs match" must not be shown when matches exist.
    expect(screen.queryByText(/No catalogs match/i)).not.toBeInTheDocument();
  });

  it("shows 'No catalogs match' ONLY when the fetch has resolved AND zero matches", () => {
    renderWithClient(<Harness />);
    openPopover();

    // Fetch resolved, list non-empty, no filter → no empty state.
    expect(screen.queryByText(/No catalogs match/i)).not.toBeInTheDocument();

    // Type a filter that matches something → no empty state.
    act(() => {
      fireEvent.change(getFilterInput(), { target: { value: "vibe" } });
    });
    expect(screen.queryByText(/No catalogs match/i)).not.toBeInTheDocument();

    // Type a completely-matching-nothing filter. We also need the "use custom"
    // affordance to be suppressed, so exhaust that code path separately.
    // Here we filter with text that would normally trigger custom; the custom
    // option shows up, so the empty-state stays hidden. That's the whole
    // point of the new UX: there's always SOMETHING actionable.
    act(() => {
      fireEvent.change(getFilterInput(), {
        target: { value: "totallyunknowncatalog" },
      });
    });
    expect(screen.queryByText(/No catalogs match/i)).not.toBeInTheDocument();
    expect(screen.getByTestId("deployment-catalog-use-custom")).toBeInTheDocument();
  });

  it("empty-state is shown when the fetched list is genuinely empty AND no input typed", () => {
    renderWithClient(<Harness catalogs={[]} />);
    openPopover();
    expect(screen.getByText(/No catalogs match/i)).toBeInTheDocument();
  });

  it("does NOT show 'Use \"<input>\"' when the typed value exactly matches an existing catalog (case-insensitive)", () => {
    renderWithClient(<Harness />);
    openPopover();
    act(() => {
      fireEvent.change(getFilterInput(), { target: { value: "vibe_modeling_test" } });
    });
    expect(
      screen.queryByTestId("deployment-catalog-use-custom"),
    ).not.toBeInTheDocument();

    // Same name but different case — still considered an exact match.
    act(() => {
      fireEvent.change(getFilterInput(), { target: { value: "VIBE_MODELING_PROD" } });
    });
    expect(
      screen.queryByTestId("deployment-catalog-use-custom"),
    ).not.toBeInTheDocument();
  });

  it("clicking an existing catalog fires onChange with the catalog name and closes the popover", () => {
    const onChange = vi.fn();
    const qc = new QueryClient({
      defaultOptions: { queries: { retry: false, staleTime: Infinity } },
    });
    render(
      <QueryClientProvider client={qc}>
        <DeploymentCatalogPicker
          value=""
          onChange={onChange}
          catalogsOverride={CATALOGS}
        />
      </QueryClientProvider>,
    );
    openPopover();
    act(() => {
      fireEvent.change(getFilterInput(), { target: { value: "vibe" } });
    });
    act(() => {
      fireEvent.click(screen.getByText("vibe_modeling_test"));
    });
    expect(onChange).toHaveBeenCalledWith("vibe_modeling_test");
  });

  // the model-versioning work F4 / F2 a11y regression: when the popover was open, the
  // Chrome a11y tree showed an empty listbox even though `[role="option"]`
  // nodes existed in the DOM.
  //
  // First root cause (F4): cmdk's `CommandGroup` rendered a nested
  // `<div role="group">` inside the listbox. Fixed by dropping CommandGroup
  // and rendering items directly under `CommandList`.
  //
  // Second root cause (F2, this re-open): cmdk's `CommandList` primitive
  // still renders an intermediate `<div cmdk-list-sizer>` (no role) between
  // the `role="listbox"` element and the `role="option"` children. Per
  // ARIA spec, a listbox's owned options must be direct children OR be
  // referenced via `aria-owns`. Fixed in `components/ui/command.tsx` by
  // having our `CommandList` wrapper sync `aria-owns` to the option ids
  // on every subtree mutation.
  it("exposes options as children of the listbox in the a11y tree (#5594 F2/F4)", () => {
    renderWithClient(<Harness />);
    openPopover();

    // The popover is portalled to document.body, so we query through
    // `screen` rather than the render container.
    const listbox = screen.getByRole("listbox");

    // No intervening `role="group"` wrapper between the listbox and its
    // options. (cmdk's CommandGroup used to introduce this; we removed it.)
    const groupsInsideListbox = listbox.querySelectorAll('[role="group"]');
    expect(groupsInsideListbox.length).toBe(0);

    // The a11y-correct contract: querying inside the listbox via the a11y
    // tree (`within(...).getAllByRole`) must surface ALL rendered options.
    // Before the fix this still worked because RTL queries by DOM descendant,
    // but it cements the contract for AT-equivalent queries.
    const optionsInListbox = within(listbox).getAllByRole("option");
    expect(optionsInListbox.length).toBe(CATALOGS.length);

    // The CRITICAL F2 assertion: options must be wired to the listbox via
    // `aria-owns` so the browser a11y tree (and screen readers) see them
    // as listbox children even though the DOM has the `cmdk-list-sizer`
    // wrapper between them.
    const ariaOwns = listbox.getAttribute("aria-owns");
    expect(ariaOwns).toBeTruthy();
    const ownedIds = (ariaOwns ?? "").split(/\s+/).filter(Boolean);
    const optionIds = optionsInListbox.map((el) => el.id).filter(Boolean);
    expect(optionIds.length).toBe(optionsInListbox.length);
    // Every option id must be referenced by aria-owns and vice versa.
    expect(new Set(ownedIds)).toEqual(new Set(optionIds));

    // And the option labels survive into the a11y tree.
    const optionTexts = optionsInListbox.map((el) => el.textContent?.trim() ?? "");
    expect(optionTexts).toEqual(
      expect.arrayContaining([
        "vibe_modeling_test",
        "Vibe_Modeling_Prod",
        "finance_prod",
        "marketing_dev",
      ]),
    );
  });

  // F2 regression — aria-owns must stay in sync as the option set changes
  // (filtering, custom-option affordance toggling). A stale aria-owns
  // pointing at unmounted ids breaks the same a11y tree contract as having
  // no aria-owns at all.
  it("keeps aria-owns in sync with the rendered option set as the filter changes (#5594 F2)", async () => {
    renderWithClient(<Harness />);
    openPopover();
    const listbox = screen.getByRole("listbox");

    // Initial: all four catalogs owned.
    await Promise.resolve();
    {
      const opts = within(listbox).getAllByRole("option");
      const owned = (listbox.getAttribute("aria-owns") ?? "").split(/\s+/).filter(Boolean);
      expect(new Set(owned)).toEqual(new Set(opts.map((o) => o.id)));
    }

    // Filter down to "vibe_modeling_test" (exact-match → no custom-option
    // affordance; one substring-matching catalog plus the exact match).
    act(() => {
      fireEvent.change(getFilterInput(), { target: { value: "vibe_modeling_test" } });
    });
    await Promise.resolve();
    {
      const opts = within(listbox).getAllByRole("option");
      expect(opts).toHaveLength(1);
      const owned = (listbox.getAttribute("aria-owns") ?? "").split(/\s+/).filter(Boolean);
      expect(new Set(owned)).toEqual(new Set(opts.map((o) => o.id)));
    }

    // Filter to something that triggers the custom-option affordance.
    act(() => {
      fireEvent.change(getFilterInput(), { target: { value: "totallyunknown" } });
    });
    await Promise.resolve();
    {
      const opts = within(listbox).getAllByRole("option");
      // Only the "Use '<input>'" option.
      expect(opts).toHaveLength(1);
      const owned = (listbox.getAttribute("aria-owns") ?? "").split(/\s+/).filter(Boolean);
      expect(new Set(owned)).toEqual(new Set(opts.map((o) => o.id)));
    }
  });

  it("trigger button advertises listbox semantics for AT users (#5594 F4)", () => {
    renderWithClient(<Harness />);
    const trigger = screen.getByRole("combobox", { name: /deployment catalog/i });
    // aria-haspopup must be "listbox" so screen readers announce the
    // dropdown correctly. Without it, the trigger reads as a plain combobox
    // with no hint that pressing Enter / Down opens a list of options.
    expect(trigger).toHaveAttribute("aria-haspopup", "listbox");
    // aria-expanded reflects the open state.
    expect(trigger).toHaveAttribute("aria-expanded", "false");
    openPopover();
    expect(trigger).toHaveAttribute("aria-expanded", "true");
  });

  // an internal tracker item — minimal substring repro. With three single-
  // character catalogs (a, ab, b), typing "a" must surface exactly the two
  // names that contain "a" (case-insensitive). Pre-fix (the model-versioning work F4) the
  // listbox could render empty even though `[role="option"]` nodes existed
  // in the DOM. This locks the canonical case from the ticket repro.
  it("typing 'a' against [a, ab, b] renders exactly the two matching options", () => {
    renderWithClient(
      <Harness catalogs={[{ name: "a" }, { name: "ab" }, { name: "b" }]} />,
    );
    openPopover();
    act(() => {
      fireEvent.change(getFilterInput(), { target: { value: "a" } });
    });

    // Options under the listbox: exactly the two matching catalogs. We
    // filter out the "Use '<input>'" custom-option row (which would only
    // appear when no exact match exists; "a" matches exactly so it won't).
    const options = screen.getAllByRole("option").filter(
      (el) =>
        el.getAttribute("data-testid") !== "deployment-catalog-use-custom",
    );
    const labels = options.map((el) => el.textContent?.trim() ?? "");
    expect(labels).toEqual(expect.arrayContaining(["a", "ab"]));
    expect(labels).not.toContain("b");
    // Two — no more, no fewer — real catalog options.
    expect(options).toHaveLength(2);
  });

  it("clicking 'Use \"<input>\"' fires onChange with the trimmed typed value", () => {
    const onChange = vi.fn();
    const qc = new QueryClient({
      defaultOptions: { queries: { retry: false, staleTime: Infinity } },
    });
    render(
      <QueryClientProvider client={qc}>
        <DeploymentCatalogPicker
          value=""
          onChange={onChange}
          catalogsOverride={CATALOGS}
        />
      </QueryClientProvider>,
    );
    openPopover();
    act(() => {
      fireEvent.change(getFilterInput(), { target: { value: "  freshly_typed  " } });
    });
    const useCustom = screen.getByTestId("deployment-catalog-use-custom");
    act(() => {
      fireEvent.click(useCustom);
    });
    expect(onChange).toHaveBeenCalledWith("freshly_typed");
  });

});
