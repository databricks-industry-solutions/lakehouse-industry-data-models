/**
 * `<FiltersBar/>` + `filtersToQueryParams` (commit b). Each control updates the
 * filter state; state maps to server query params; "import" group; shown/total.
 */
import { describe, expect, it, vi } from "vitest";
import { fireEvent, render, screen } from "@testing-library/react";
import {
  FiltersBar,
  DEFAULT_FILTERS,
  filtersToQueryParams,
  applyFilters,
  collectDomainOptions,
  inputDomain,
  MODEL_WIDE_DOMAIN,
} from "@/components/vibe-inputs/filters-bar";
import type { VibeInputOut } from "@/lib/api";

function makeInput(over: Partial<VibeInputOut>): VibeInputOut {
  return {
    id: "i1",
    text: "instruction",
    origin: "user",
    priority: "medium",
    status: "active",
    consumed: false,
    selected_for_run: false,
    ...over,
  } as VibeInputOut;
}

describe("filtersToQueryParams", () => {
  it("maps active → status active + consumed false", () => {
    expect(filtersToQueryParams({ ...DEFAULT_FILTERS, state: "active" })).toEqual({
      status: "active",
      consumed: false,
    });
  });
  it("maps consumed → status active + consumed true", () => {
    expect(filtersToQueryParams({ ...DEFAULT_FILTERS, state: "consumed" })).toEqual({
      status: "active",
      consumed: true,
    });
  });
  it("maps needs_link_review → status active + needs_link_review", () => {
    expect(
      filtersToQueryParams({ ...DEFAULT_FILTERS, state: "needs_link_review" }),
    ).toEqual({ status: "active", needs_link_review: true });
  });
  it("maps deprecated → status deprecated", () => {
    expect(filtersToQueryParams({ ...DEFAULT_FILTERS, state: "deprecated" })).toEqual({
      status: "deprecated",
    });
  });
  it("passes through user/agent origin and priority and trimmed q", () => {
    expect(
      filtersToQueryParams({
        q: "  rename  ",
        origin: "agent_next_vibe",
        state: "all",
        priority: "high",
        selected: "all",
        domain: "all",
      }),
    ).toEqual({ q: "rename", origin: "agent_next_vibe", priority: "high" });
  });
  it("passes the change_rejection origin through", () => {
    expect(filtersToQueryParams({ ...DEFAULT_FILTERS, origin: "change_rejection" })).toEqual({
      origin: "change_rejection",
    });
  });
  it("filters a list by the change_rejection origin client-side", () => {
    const rejected = makeInput({ id: "r", origin: "change_rejection" });
    const user = makeInput({ id: "u", origin: "user" });
    expect(
      applyFilters([rejected, user], { ...DEFAULT_FILTERS, origin: "change_rejection" }, new Set()).map((i) => i.id),
    ).toEqual(["r"]);
  });
  it("does not send a concrete origin for the import group (handled client-side)", () => {
    expect(filtersToQueryParams({ ...DEFAULT_FILTERS, origin: "import" })).toEqual({});
  });
});

describe("applyFilters — deprecated exclusivity (U-04)", () => {
  const active = makeInput({ id: "a", status: "active" });
  const consumed = makeInput({ id: "c", status: "active", consumed: true });
  const deprecated1 = makeInput({ id: "d1", status: "deprecated" });
  const deprecated2 = makeInput({ id: "d2", status: "deprecated" });
  const all = [active, consumed, deprecated1, deprecated2];
  const noSelection = new Set<string>();

  it("shows ONLY deprecated inputs when the Deprecated state filter is active", () => {
    const out = applyFilters(all, { ...DEFAULT_FILTERS, state: "deprecated" }, noSelection);
    expect(out.map((i) => i.id).sort()).toEqual(["d1", "d2"]);
    // No active-status item leaks through.
    expect(out.some((i) => i.status !== "deprecated")).toBe(false);
  });

  it("excludes deprecated inputs for the 'all' state", () => {
    const out = applyFilters(all, { ...DEFAULT_FILTERS, state: "all" }, noSelection);
    expect(out.some((i) => i.status === "deprecated")).toBe(false);
  });

  it("excludes deprecated inputs for the 'active' state", () => {
    const out = applyFilters(all, { ...DEFAULT_FILTERS, state: "active" }, noSelection);
    expect(out.map((i) => i.id)).toEqual(["a"]);
  });
});

describe("applyFilters - domain facet", () => {
  const byName = makeInput({
    id: "n",
    anchor: { level: "element", domain_name: "Sales", path: ["Domain: Sales"] },
  } as Partial<VibeInputOut>);
  const byPath = makeInput({
    id: "p",
    anchor: { level: "element", path: ["Domain: Finance", "Product: Ledger"] },
  } as Partial<VibeInputOut>);
  const pathBeatsName = makeInput({
    id: "pb",
    anchor: { level: "element", domain_name: "Stale", path: ["Domain: Ops"] },
  } as Partial<VibeInputOut>);
  const nameOnly = makeInput({
    id: "no",
    anchor: { level: "element", domain_name: "Legal", path: ["Product: Contracts"] },
  } as Partial<VibeInputOut>);
  const modelWide = makeInput({
    id: "m",
    anchor: { level: "model_wide", path: [] },
  } as Partial<VibeInputOut>);
  const modelWideWithName = makeInput({
    id: "mn",
    anchor: { level: "model_wide", domain_name: "Sales", path: [] },
  } as Partial<VibeInputOut>);
  const emptyPath = makeInput({
    id: "e",
    anchor: { level: "element", domain_name: "Sales", path: [] },
  } as Partial<VibeInputOut>);
  const noAnchor = makeInput({ id: "x", anchor: null } as Partial<VibeInputOut>);
  const all = [byName, byPath, pathBeatsName, nameOnly, modelWide, modelWideWithName, emptyPath, noAnchor];
  const ids = (f: string) =>
    applyFilters(all, { ...DEFAULT_FILTERS, domain: f }, new Set()).map((i) => i.id);

  it("matches the 'Domain: X' path label", () => {
    expect(ids("Sales")).toEqual(["n"]);
    expect(ids("Finance")).toEqual(["p"]);
  });
  it("prefers the path label over anchor.domain_name", () => {
    expect(ids("Ops")).toEqual(["pb"]);
    expect(ids("Stale")).toEqual([]);
  });
  it("falls back to anchor.domain_name only when the path has no Domain label", () => {
    expect(ids("Legal")).toEqual(["no"]);
  });
  it("model-wide covers model_wide level and empty path, even with domain_name", () => {
    expect(ids(MODEL_WIDE_DOMAIN)).toEqual(["m", "mn", "e"]);
  });
  it("a null anchor matches only 'all'", () => {
    expect(ids("all")).toContain("x");
    expect(ids(MODEL_WIDE_DOMAIN)).not.toContain("x");
    expect(ids("Sales")).not.toContain("x");
  });
  it("is not sent as a server query param", () => {
    expect(filtersToQueryParams({ ...DEFAULT_FILTERS, domain: "Sales" })).toEqual({});
  });
  it("classifies inputs and collects unique sorted domain names", () => {
    expect(inputDomain(noAnchor)).toEqual({ kind: "none" });
    expect(inputDomain(modelWideWithName)).toEqual({ kind: "model_wide" });
    expect(inputDomain(byPath)).toEqual({ kind: "domain", name: "Finance" });
    expect(collectDomainOptions(all)).toEqual(["Finance", "Legal", "Ops", "Sales"]);
  });
});

describe("FiltersBar component", () => {
  it("search input updates q", () => {
    const onChange = vi.fn();
    render(
      <FiltersBar filters={DEFAULT_FILTERS} onChange={onChange} shown={3} total={9} />,
    );
    fireEvent.change(screen.getByLabelText("Search instructions"), {
      target: { value: "audit" },
    });
    expect(onChange).toHaveBeenCalledWith({ ...DEFAULT_FILTERS, q: "audit" });
  });

  it("shows the shown-of-total count", () => {
    render(
      <FiltersBar filters={DEFAULT_FILTERS} onChange={vi.fn()} shown={3} total={9} />,
    );
    expect(screen.getByTestId("filters-count")).toHaveTextContent("3 of 9 inputs");
  });

  it("selection filter updates the selected facet", () => {
    const onChange = vi.fn();
    render(
      <FiltersBar filters={DEFAULT_FILTERS} onChange={onChange} shown={3} total={9} />,
    );
    fireEvent.click(screen.getByLabelText("Filter by selection"));
    fireEvent.click(screen.getByRole("option", { name: "Selected" }));
    expect(onChange).toHaveBeenCalledWith({ ...DEFAULT_FILTERS, selected: "selected" });
  });

  it("offers the Deprecated state unless the caller hides it", () => {
    const { rerender } = render(
      <FiltersBar filters={DEFAULT_FILTERS} onChange={vi.fn()} shown={3} total={9} />,
    );
    fireEvent.click(screen.getByLabelText("Filter by state"));
    expect(screen.getByRole("option", { name: "Deprecated" })).toBeInTheDocument();
    fireEvent.keyDown(screen.getByRole("listbox"), { key: "Escape" });
    rerender(
      <FiltersBar filters={DEFAULT_FILTERS} onChange={vi.fn()} shown={3} total={9} showDeprecated={false} />,
    );
    fireEvent.click(screen.getByLabelText("Filter by state"));
    expect(screen.queryByRole("option", { name: "Deprecated" })).not.toBeInTheDocument();
  });

  it("renders the domain select only when domains are given", () => {
    const { rerender } = render(
      <FiltersBar filters={DEFAULT_FILTERS} onChange={vi.fn()} shown={3} total={9} />,
    );
    expect(screen.queryByLabelText("Filter by domain")).not.toBeInTheDocument();
    rerender(
      <FiltersBar
        filters={DEFAULT_FILTERS}
        onChange={vi.fn()}
        shown={3}
        total={9}
        domains={[]}
      />,
    );
    expect(screen.queryByLabelText("Filter by domain")).not.toBeInTheDocument();
    rerender(
      <FiltersBar
        filters={DEFAULT_FILTERS}
        onChange={vi.fn()}
        shown={3}
        total={9}
        domains={["Sales"]}
      />,
    );
    expect(screen.getByLabelText("Filter by domain")).toBeInTheDocument();
  });

  it("domain select offers All, Model-wide and each domain, and updates the facet", () => {
    const onChange = vi.fn();
    render(
      <FiltersBar
        filters={DEFAULT_FILTERS}
        onChange={onChange}
        shown={3}
        total={9}
        domains={["Finance", "Sales"]}
      />,
    );
    fireEvent.click(screen.getByLabelText("Filter by domain"));
    expect(screen.getByRole("option", { name: "All domains" })).toBeInTheDocument();
    expect(screen.getByRole("option", { name: "Model-wide" })).toBeInTheDocument();
    expect(screen.getByRole("option", { name: "Finance" })).toBeInTheDocument();
    fireEvent.click(screen.getByRole("option", { name: "Sales" }));
    expect(onChange).toHaveBeenCalledWith({ ...DEFAULT_FILTERS, domain: "Sales" });
  });

  it("keeps the domain select when a stale domain is active, so it can be cleared", () => {
    const onChange = vi.fn();
    const stale = { ...DEFAULT_FILTERS, domain: "Gone" };
    const { rerender } = render(
      <FiltersBar filters={stale} onChange={onChange} shown={0} total={9} />,
    );
    const trigger = screen.getByLabelText("Filter by domain");
    expect(trigger).toHaveTextContent("Gone");
    rerender(
      <FiltersBar filters={stale} onChange={onChange} shown={0} total={9} domains={["Sales"]} />,
    );
    expect(screen.getByLabelText("Filter by domain")).toHaveTextContent("Gone");
    fireEvent.click(screen.getByLabelText("Filter by domain"));
    fireEvent.click(screen.getByRole("option", { name: "All domains" }));
    expect(onChange).toHaveBeenCalledWith({ ...stale, domain: "all" });
  });
});
