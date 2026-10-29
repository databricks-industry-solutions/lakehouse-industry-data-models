import { describe, it, expect, vi, beforeEach } from "vitest";
import { render, screen, fireEvent, waitFor, act, within } from "@testing-library/react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";

const m = vi.hoisted(() => ({
  navigate: vi.fn(),
  compileTaxonomy: vi.fn(),
  condenseTaxonomy: vi.fn(),
  createBusiness: vi.fn(),
  retryTaxonomyDraftPart: vi.fn(),
  cancelTaxonomyDraft: vi.fn(),
  hook: { draft: null as any, lost: false },
}));
vi.mock("@tanstack/react-router", async (orig) => ({
  ...(await orig<any>()),
  useNavigate: () => m.navigate,
  Link: ({ children, to, search, hash, ...rest }: any) => (
    <a href={`${to}${search?.tab ? `?tab=${search.tab}` : ""}${hash ? `#${hash}` : ""}`} {...rest}>{children}</a>
  ),
}));
vi.mock("@/lib/api", async (orig) => ({
  ...(await orig<any>()),
  compileTaxonomy: m.compileTaxonomy, condenseTaxonomy: m.condenseTaxonomy, createBusiness: m.createBusiness,
  retryTaxonomyDraftPart: m.retryTaxonomyDraftPart, cancelTaxonomyDraft: m.cancelTaxonomyDraft,
}));
vi.mock("@/lib/taxonomy/use-taxonomy-draft", async (orig) => ({
  ...(await orig<any>()),
  useTaxonomyDraft: () => ({ draft: m.hook.draft, error: null, lost: m.hook.lost }),
}));

import { ReviewStep } from "@/components/taxonomy/review-step";
import { ApiError } from "@/lib/api";

const COMPILED = {
  clamp: "## Conformance clamp", business_vibes: "## Company and segments\nX\n\n## Conformance clamp",
  business_domains: "customer, billing", csv: "Domain,Sub Domain,Category\n", issues: [],
};
const doneDraft = (description: string, error?: string) => ({
  draft_id: "c1", status: "done", parts: { description: { status: "done", description, ...(error ? { error } : {}) } },
});
const props = {
  intake: { company_name: "Ridgeline Energy", industry: "Utility" } as any,
  sectorId: "sec-1",
  tree: { domains: [{ name: "Customer & Premise", schema_name: "", subdomains: [] }], shared_masters: [], relationships: [], division_names: [], coverage: "Operations, Business and Corporate" } as any,
  strictness: "strict" as const,
  sections: {},
};
const wrap = (ui: any) =>
  render(<QueryClientProvider client={new QueryClient({ defaultOptions: { queries: { retry: false } } })}>{ui}</QueryClientProvider>);
const createBtn = () => screen.getByRole("button", { name: /create & configure first run/i }) as HTMLButtonElement;

beforeEach(() => {
  m.navigate.mockReset();
  m.compileTaxonomy.mockReset().mockResolvedValue({ data: COMPILED });
  m.condenseTaxonomy.mockReset().mockResolvedValue({ data: { draft_id: "c1" } });
  m.createBusiness.mockReset().mockResolvedValue({ data: { id: "biz1" } });
  m.hook.draft = doneDraft("Short summary.");
  m.hook.lost = false;
});

describe("ReviewStep", () => {
  it("shows a message and re-enables the button when the condense draft is lost", async () => {
    m.hook.draft = undefined;
    m.compileTaxonomy.mockImplementation(() => new Promise((r) => setTimeout(() => r({ data: COMPILED }), 150)));
    wrap(<ReviewStep {...props} />);
    await waitFor(() => expect(m.condenseTaxonomy).toHaveBeenCalled());
    // The editor renders only after the compile query resolves, which the call above does not wait for.
    const textbox = await screen.findByRole("textbox");
    m.hook.lost = true; // the poll 404s after the click
    fireEvent.change(textbox, { target: { value: "x" } }); // force a re-render
    expect(await screen.findByText(/description draft was lost/i)).toBeTruthy();
    expect((screen.getByRole("button", { name: /rewrite with the model/i }) as HTMLButtonElement).disabled).toBe(false);
  });

  it("creates the business with its proposed domains + coverage, then opens New Base Model", async () => {
    wrap(<ReviewStep {...props} />);
    await waitFor(() => expect(m.condenseTaxonomy).toHaveBeenCalled());
    await waitFor(() => expect(screen.getByDisplayValue("Short summary.")).toBeTruthy());
    expect(screen.getByText("Organization divisions:")).toBeTruthy();
    expect(screen.queryByText("Coverage:")).toBeNull();
    fireEvent.click(createBtn());
    await waitFor(() => expect(m.createBusiness).toHaveBeenCalled());
    expect(m.createBusiness.mock.calls[0][0]).toMatchObject({
      name: "Ridgeline Energy", description: "Short summary.", sector_id: "sec-1",
      business_vibes: expect.stringContaining("Conformance clamp"),
      business_domains: "customer, billing",
      org_divisions: "Operations, Business and Corporate",
    });
    // The run form pre-fills from the business, so nothing rides in the URL.
    expect(m.navigate).toHaveBeenCalledWith({
      to: "/businesses/$businessId/runs/new",
      params: { businessId: "biz1" },
      search: { operationType: "new base model" },
    });
  });

  it("runs onCreated after the business exists and before opening New Base Model; its failure does not block", async () => {
    const order: string[] = [];
    m.createBusiness.mockImplementation(async () => { order.push("create"); return { data: { id: "biz1" } }; });
    m.navigate.mockImplementation(() => { order.push("navigate"); });
    const onCreated = vi.fn(async () => {
      await new Promise((r) => setTimeout(r, 20));
      order.push("onCreated");
      throw new Error("discard failed");
    });
    wrap(<ReviewStep {...props} onCreated={onCreated} />);
    await waitFor(() => expect(screen.getByDisplayValue("Short summary.")).toBeTruthy());
    fireEvent.click(createBtn());
    await waitFor(() => expect(m.navigate).toHaveBeenCalled());
    expect(order).toEqual(["create", "onCreated", "navigate"]);
  });

  it("does not run onCreated when createBusiness fails", async () => {
    m.createBusiness.mockRejectedValueOnce(new Error("Business name already exists"));
    const onCreated = vi.fn(async () => {});
    wrap(<ReviewStep {...props} onCreated={onCreated} />);
    await waitFor(() => expect(screen.getByDisplayValue("Short summary.")).toBeTruthy());
    fireEvent.click(createBtn());
    await waitFor(() => expect(screen.getByText(/already exists/i)).toBeTruthy());
    expect(onCreated).not.toHaveBeenCalled();
  });

  it("blocks Create when the description is over 2,000 characters", async () => {
    m.hook.draft = doneDraft("x".repeat(2001), "over");
    wrap(<ReviewStep {...props} />);
    await waitFor(() => expect(m.condenseTaxonomy).toHaveBeenCalled());
    await waitFor(() => expect(screen.getByText(/2,001 \/ 2,000/)).toBeTruthy());
    expect(createBtn().disabled).toBe(true);
  });

  it("stays on the step and keeps the draft when createBusiness fails", async () => {
    m.createBusiness.mockRejectedValueOnce(new Error("Business name already exists"));
    wrap(<ReviewStep {...props} />);
    await waitFor(() => expect(m.condenseTaxonomy).toHaveBeenCalled());
    await waitFor(() => expect(screen.getByDisplayValue("Short summary.")).toBeTruthy());
    fireEvent.click(createBtn());
    await waitFor(() => expect(screen.getByText(/already exists/i)).toBeTruthy());
    expect(m.navigate).not.toHaveBeenCalled();
    expect(screen.getByDisplayValue("Short summary.")).toBeTruthy();
  });

  it("renders a failed compile request and blocks Create", async () => {
    m.compileTaxonomy.mockRejectedValue(new Error("Compile service unavailable"));
    wrap(<ReviewStep {...props} />);
    expect(await screen.findByText("Compile service unavailable")).toBeTruthy();
    expect(createBtn().disabled).toBe(true);
  });

  it("lists blank-name problems, skips compile + condense, and blocks Create", async () => {
    const tree = { ...props.tree, domains: [{ name: "   ", schema_name: "", subdomains: [] }] };
    wrap(<ReviewStep {...props} tree={tree} />);
    expect(await screen.findByText("Domain 1 needs a name.")).toBeTruthy();
    expect(m.compileTaxonomy).not.toHaveBeenCalled();
    expect((screen.getByRole("button", { name: /rewrite with the model/i }) as HTMLButtonElement).disabled).toBe(true);
    expect(createBtn().disabled).toBe(true);
  });

  it("sends sanitized sections (no empty claims / empty sections) to compile and condense", async () => {
    const sections = {
      company: { claims: [{ text: " Ridgeline. ", provenance: "user" }, { text: "", provenance: "user" }] },
      channels: { claims: [{ text: "   ", provenance: "user" }] },
    } as any;
    wrap(<ReviewStep {...props} sections={sections} />);
    await waitFor(() => expect(m.condenseTaxonomy).toHaveBeenCalled());
    const want = { company: { claims: [{ text: "Ridgeline.", provenance: "user" }] } };
    expect(m.compileTaxonomy.mock.calls[0][0].sections).toEqual(want);
    expect(m.condenseTaxonomy.mock.calls[0][0].sections).toEqual(want);
  });

  it("blocks Create and shows the message when compile returns an error issue", async () => {
    m.compileTaxonomy.mockResolvedValue({ data: { ...COMPILED, issues: [{ severity: "error", message: "Domain 'x' has no sub-domains." }] } });
    wrap(<ReviewStep {...props} />);
    expect(await screen.findByText("Domain 'x' has no sub-domains.")).toBeTruthy();
    fireEvent.change(screen.getByRole("textbox"), { target: { value: "A real description." } });
    expect(createBtn().disabled).toBe(true);
  });

  it("blocks Create while the description is empty and enables it once text is typed", async () => {
    m.hook.draft = null;
    wrap(<ReviewStep {...props} />);
    await screen.findByText("Business domains:");
    expect(createBtn().disabled).toBe(true);
    fireEvent.change(screen.getByRole("textbox"), { target: { value: "Typed description." } });
    expect(createBtn().disabled).toBe(false);
  });

  it.each(["failed", "timed_out", "cancelled"])("shows the condense error for a %s description part", async (st) => {
    m.hook.draft = { draft_id: "c1", status: st, parts: { description: { status: st, error: `condense ${st}` } } };
    wrap(<ReviewStep {...props} />);
    await waitFor(() => expect(m.condenseTaxonomy).toHaveBeenCalled());
    expect(await screen.findByText(`condense ${st}`)).toBeTruthy();
  });

  it("a double click creates only one business", async () => {
    wrap(<ReviewStep {...props} />);
    await screen.findByText("Business domains:");
    fireEvent.change(screen.getByRole("textbox"), { target: { value: "Typed description." } });
    const b = createBtn();
    act(() => { b.click(); b.click(); }); // both land before React re-renders the disabled state
    await waitFor(() => expect(m.navigate).toHaveBeenCalled());
    expect(m.createBusiness).toHaveBeenCalledTimes(1);
  });

  it("auto-drafts the description exactly once on entry when empty", async () => {
    const r = wrap(<ReviewStep {...props} />);
    await waitFor(() => expect(m.condenseTaxonomy).toHaveBeenCalledTimes(1));
    r.rerender(<QueryClientProvider client={new QueryClient()}><ReviewStep {...props} /></QueryClientProvider>);
    await screen.findByText("Business domains:");
    expect(m.condenseTaxonomy).toHaveBeenCalledTimes(1);
  });

  it("shows a writing placeholder while the draft runs", async () => {
    m.hook.draft = { draft_id: "c1", status: "running", parts: { description: { status: "running" } } };
    wrap(<ReviewStep {...props} />);
    expect(await screen.findAllByText(/the model is writing the description/i)).toBeTruthy();
  });

  it("does not auto-draft when an initialDescription is supplied, and pre-fills it", async () => {
    m.hook.draft = null;
    wrap(<ReviewStep {...props} initialDescription="Ridgeline example description." />);
    await screen.findByText("Business domains:");
    expect(screen.getByDisplayValue("Ridgeline example description.")).toBeTruthy();
    expect(m.condenseTaxonomy).not.toHaveBeenCalled();
    expect(createBtn().disabled).toBe(false);
  });

  it("asks before Rewrite replaces edited text", async () => {
    m.hook.draft = null;
    wrap(<ReviewStep {...props} initialDescription="Mine." />);
    await screen.findByText("Business domains:");
    fireEvent.change(screen.getByRole("textbox"), { target: { value: "Mine, edited." } });
    fireEvent.click(screen.getByRole("button", { name: /rewrite with the model/i }));
    expect(await screen.findByText(/replace your edits with a new draft/i)).toBeTruthy();
    expect(m.condenseTaxonomy).not.toHaveBeenCalled();
    fireEvent.click(screen.getByRole("button", { name: /^replace$/i }));
    await waitFor(() => expect(m.condenseTaxonomy).toHaveBeenCalledTimes(1));
  });

  it("Rewrite on untouched text runs without asking", async () => {
    m.hook.draft = null;
    wrap(<ReviewStep {...props} initialDescription="Untouched." />);
    await screen.findByText("Business domains:");
    fireEvent.click(screen.getByRole("button", { name: /rewrite with the model/i }));
    await waitFor(() => expect(m.condenseTaxonomy).toHaveBeenCalledTimes(1));
  });

  it("shows the error and does not re-fire when the auto-draft request fails", async () => {
    m.hook.draft = null;
    m.condenseTaxonomy.mockRejectedValue(new Error("llm down"));
    const r = wrap(<ReviewStep {...props} />);
    expect(await screen.findByText(/llm down/i)).toBeTruthy();
    r.rerender(<QueryClientProvider client={new QueryClient()}><ReviewStep {...props} /></QueryClientProvider>);
    await new Promise((res) => setTimeout(res, 50));
    expect(m.condenseTaxonomy).toHaveBeenCalledTimes(1);
  });

  it("a refused model service shows its message with the link to the setting", async () => {
    m.hook.draft = null;
    m.condenseTaxonomy.mockRejectedValue(new ApiError(400, "Bad Request", {
      detail: { error: "model_service_refused", key: "taxonomy_llm", status: "denied", message: "The app's service principal may not use it." },
    }));
    wrap(<ReviewStep {...props} />);
    const notice = await screen.findByTestId("description-settings-error");
    expect(notice).toHaveTextContent("The app's service principal may not use it.");
    expect(notice).toHaveTextContent("Domain Taxonomy Builder model service");
    expect(within(notice).getByRole("link", { name: "Configure" })).toHaveAttribute("href", "/settings?tab=platform#feature-taxonomy");
  });

  it("keeps the compiled preview collapsed by default", async () => {
    wrap(<ReviewStep {...props} />);
    const summary = await screen.findByText(/preview what the agent will receive/i);
    const details = summary.closest("details")!;
    expect(details.open).toBe(false);
    expect(details.querySelector("pre")!.className).not.toMatch(/max-h|overflow/);
  });

  describe("busy description", () => {
    const busyDraft = { draft_id: "c1", status: "busy", parts: { description: { status: "busy", error: "The model is busy" } } };

    it("counts down in place of the spinner, keeps the textarea editable and disables Rewrite", async () => {
      m.hook.draft = busyDraft;
      wrap(<ReviewStep {...props} />);
      await waitFor(() => expect(m.condenseTaxonomy).toHaveBeenCalled());
      const countdown = await screen.findByTestId("description-busy-countdown");
      expect(countdown.textContent).toMatch(/The model is busy\. Next try in 00:1[2-8]/);
      expect(screen.queryByText(/The model is writing the description/i)).toBeNull();
      expect((screen.getByRole("button", { name: /rewrite with the model/i }) as HTMLButtonElement).disabled).toBe(true);
      const box = screen.getByRole("textbox") as HTMLTextAreaElement;
      fireEvent.change(box, { target: { value: "I'll write it myself." } });
      expect(box.value).toBe("I'll write it myself.");
    });

    it("stops counting down once the user has written their own description", async () => {
      m.hook.draft = busyDraft;
      wrap(<ReviewStep {...props} />);
      await waitFor(() => expect(m.condenseTaxonomy).toHaveBeenCalled());
      await screen.findByTestId("description-busy-countdown");
      fireEvent.change(screen.getByRole("textbox"), { target: { value: "Our own words." } });
      expect(screen.queryByTestId("description-busy-countdown")).toBeNull();
    });

    it("Retry now retries the description part of the condense draft", async () => {
      m.hook.draft = busyDraft;
      m.retryTaxonomyDraftPart.mockResolvedValue({ data: busyDraft });
      wrap(<ReviewStep {...props} />);
      await waitFor(() => expect(m.condenseTaxonomy).toHaveBeenCalled());
      fireEvent.click(await screen.findByRole("button", { name: "Retry now" }));
      await waitFor(() => expect(m.retryTaxonomyDraftPart).toHaveBeenCalledWith({ draft_id: "c1", part: "description" }));
    });

    it("Cancel cancels the condense draft", async () => {
      m.hook.draft = busyDraft;
      m.cancelTaxonomyDraft.mockResolvedValue({ data: { ...busyDraft, status: "cancelled" } });
      wrap(<ReviewStep {...props} />);
      await waitFor(() => expect(m.condenseTaxonomy).toHaveBeenCalled());
      fireEvent.click(await screen.findByRole("button", { name: "Cancel" }));
      await waitFor(() => expect(m.cancelTaxonomyDraft).toHaveBeenCalledWith({ draft_id: "c1" }));
    });
  });
});
