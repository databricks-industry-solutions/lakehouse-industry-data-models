import { describe, it, expect, vi, beforeEach, afterEach } from "vitest";
import { act, renderHook } from "@testing-library/react";
import { ApiError } from "@/lib/api";

const m = vi.hoisted(() => ({
  getSavedTaxonomyWizard: vi.fn(),
  saveTaxonomyWizard: vi.fn(),
  discardTaxonomyWizard: vi.fn(),
}));
vi.mock("@/lib/api", async (orig) => ({
  ...(await orig<any>()),
  getSavedTaxonomyWizard: m.getSavedTaxonomyWizard,
  saveTaxonomyWizard: m.saveTaxonomyWizard,
  discardTaxonomyWizard: m.discardTaxonomyWizard,
}));

import { AUTOSAVE_DEBOUNCE_MS, SAVE_FAILED_COPY, docKey, docOf, savableParts, useSavedWizard, type WizardDoc } from "@/lib/taxonomy/use-saved-wizard";
import { draftCreateBody } from "@/lib/taxonomy/use-taxonomy-draft";
import { finishedParts } from "@/lib/taxonomy/tree";

const INTAKE = { company_name: "Acme", industry: "Utility" } as any;
const TREE = {
  domains: [{ name: " Customer ", schema_name: "", subdomains: [] }],
  shared_masters: [], relationships: [], division_names: [], coverage: "Operations, Business and Corporate",
} as any;
const CLEAN_TREE = { ...TREE, domains: [{ name: "Customer", schema_name: "", subdomains: [] }] };
const BLANK_TREE = { ...TREE, domains: [{ name: "", schema_name: "", subdomains: [] }] };
const SECTIONS = {
  company: { claims: [{ text: " We sell power. ", provenance: "user" }, { text: "  ", provenance: "user" }] },
  channels: { claims: [{ text: "", provenance: "user" }] },
} as any;
const doc = (step: number): WizardDoc => ({ step, intake: INTAKE, sections: {} });
const out = (revision: number, extra: any = {}) => ({
  data: { revision, step: 1, intake: INTAKE, sections: {}, strictness: "strict", updated_at: "2026-10-23T09:00:00Z", expires_at: "2026-10-30T09:00:00Z", ...extra },
});
const stale = (revision: number) =>
  new ApiError(409, "Conflict", { detail: { error: "stale_revision", revision, message: "Saved in another tab." } });

async function mounted(saved: any = null) {
  m.getSavedTaxonomyWizard.mockResolvedValueOnce({ data: { saved } });
  const hook = renderHook(() => useSavedWizard());
  await act(async () => {});
  return hook;
}

const tick = async (ms = AUTOSAVE_DEBOUNCE_MS) => { await act(async () => { await vi.advanceTimersByTimeAsync(ms); }); };

beforeEach(() => {
  vi.useFakeTimers({ shouldAdvanceTime: true });
  m.getSavedTaxonomyWizard.mockReset();
  m.saveTaxonomyWizard.mockReset();
  m.discardTaxonomyWizard.mockReset().mockResolvedValue({ data: { discarded: true } });
});
afterEach(() => { vi.useRealTimers(); });

describe("finished parts and draft seeds", () => {
  it("sanitizes a clean tree and drops empty claims and sections", () => {
    const parts = finishedParts(TREE, SECTIONS);
    expect(parts.tree).toEqual(CLEAN_TREE);
    expect(parts.sections).toEqual({ company: { claims: [{ text: "We sell power.", provenance: "user" }] } });
  });

  it("a tree with problems or no tree is not finished", () => {
    expect(finishedParts(BLANK_TREE, {}).tree).toBeNull();
    expect(finishedParts({ ...TREE, domains: [] }, {}).tree).toBeNull();
    expect(finishedParts(null, SECTIONS).tree).toBeNull();
  });

  it("savableParts keeps the last clean tree while a name is blank", () => {
    expect(savableParts(BLANK_TREE, {}, CLEAN_TREE)).toMatchObject({ tree: CLEAN_TREE, clean: null });
    expect(savableParts(TREE, {}, null)).toMatchObject({ tree: CLEAN_TREE, clean: CLEAN_TREE });
    expect(savableParts(null, {}, CLEAN_TREE).tree).toBeNull();
  });

  it("draftCreateBody sends seeds only when asked, and no seed tree with problems", () => {
    expect(draftCreateBody(INTAKE)).toEqual(INTAKE);
    expect(draftCreateBody(INTAKE, { tree: TREE, sections: SECTIONS })).toEqual({
      ...INTAKE, seed_tree: CLEAN_TREE, seed_sections: { company: { claims: [{ text: "We sell power.", provenance: "user" }] } },
    });
    expect(draftCreateBody(INTAKE, { tree: BLANK_TREE, sections: {} })).toEqual({ ...INTAKE, seed_tree: null, seed_sections: {} });
  });
});

describe("useSavedWizard", () => {
  it("loads the saved wizard, or null when nothing is saved or the read fails", async () => {
    const { result } = await mounted(out(4).data);
    expect(result.current.loaded?.revision).toBe(4);
    expect((await mounted(null)).result.current.loaded).toBeNull();
    m.getSavedTaxonomyWizard.mockRejectedValueOnce(new Error("down"));
    const failed = renderHook(() => useSavedWizard());
    await act(async () => {});
    expect(failed.result.current.loaded).toBeNull();
  });

  it("debounces changes into one save 1 s after the last one", async () => {
    m.saveTaxonomyWizard.mockResolvedValue(out(1));
    const { result } = await mounted();
    act(() => { result.current.schedule(doc(0)); });
    await tick(600);
    act(() => { result.current.schedule(doc(1)); });
    await tick(600);
    expect(m.saveTaxonomyWizard).not.toHaveBeenCalled();
    await tick(400);
    expect(m.saveTaxonomyWizard).toHaveBeenCalledTimes(1);
    expect(m.saveTaxonomyWizard.mock.calls[0][0]).toEqual({ ...doc(1), revision: 0 });
    expect(result.current.status).toBe("saved");
  });

  it("each save carries the revision the previous one returned, starting from the loaded one", async () => {
    m.saveTaxonomyWizard.mockResolvedValueOnce(out(5)).mockResolvedValueOnce(out(6));
    const { result } = await mounted(out(4).data);
    act(() => { result.current.schedule(doc(1)); });
    await tick();
    act(() => { result.current.schedule(doc(2)); });
    await tick();
    expect(m.saveTaxonomyWizard.mock.calls.map((c) => c[0].revision)).toEqual([4, 5]);
  });

  it("a change made while a save runs is saved after it, on the new revision", async () => {
    let finish!: (v: any) => void;
    m.saveTaxonomyWizard.mockImplementationOnce(() => new Promise((r) => { finish = r; })).mockResolvedValueOnce(out(2));
    const { result } = await mounted();
    act(() => { result.current.schedule(doc(1)); });
    await tick();
    act(() => { result.current.schedule(doc(2)); });
    await tick();
    expect(m.saveTaxonomyWizard).toHaveBeenCalledTimes(1);
    await act(async () => { finish(out(1)); });
    await tick();
    expect(m.saveTaxonomyWizard).toHaveBeenCalledTimes(2);
    expect(m.saveTaxonomyWizard.mock.calls[1][0]).toEqual({ ...doc(2), revision: 1 });
  });

  it("a 409 stale_revision opens a conflict and pauses saving; keepMine saves over the newer revision", async () => {
    m.saveTaxonomyWizard.mockRejectedValueOnce(stale(7)).mockResolvedValueOnce(out(8));
    const { result } = await mounted();
    act(() => { result.current.schedule(doc(2)); });
    await tick();
    expect(result.current.conflict).toEqual({ revision: 7, message: "Saved in another tab." });
    act(() => { result.current.schedule(doc(3)); });
    await tick();
    expect(m.saveTaxonomyWizard).toHaveBeenCalledTimes(1);
    await act(async () => { result.current.keepMine(); });
    expect(m.saveTaxonomyWizard).toHaveBeenCalledTimes(2);
    expect(m.saveTaxonomyWizard.mock.calls[1][0]).toEqual({ ...doc(3), revision: 7 });
    expect(result.current.conflict).toBeNull();
  });

  it("loadNewer returns the newer save and continues from its revision", async () => {
    m.saveTaxonomyWizard.mockRejectedValueOnce(stale(7)).mockResolvedValueOnce(out(8));
    const { result } = await mounted();
    act(() => { result.current.schedule(doc(2)); });
    await tick();
    m.getSavedTaxonomyWizard.mockResolvedValueOnce({ data: { saved: out(7, { step: 3 }).data } });
    let newer: any;
    await act(async () => { newer = await result.current.loadNewer(); });
    expect(newer.step).toBe(3);
    act(() => { result.current.schedule(doc(3)); });
    await tick();
    expect(m.saveTaxonomyWizard.mock.calls[1][0].revision).toBe(7);
  });

  it("a failed save is not retried in a loop; the next change retries it", async () => {
    m.saveTaxonomyWizard.mockRejectedValueOnce(new Error("network")).mockResolvedValueOnce(out(1));
    const { result } = await mounted();
    act(() => { result.current.schedule(doc(1)); });
    await tick();
    expect(result.current.status).toBe("error");
    await tick(10 * AUTOSAVE_DEBOUNCE_MS);
    expect(m.saveTaxonomyWizard).toHaveBeenCalledTimes(1);
    act(() => { result.current.schedule(doc(2)); });
    await tick();
    expect(m.saveTaxonomyWizard).toHaveBeenCalledTimes(2);
    expect(result.current.status).toBe("saved");
  });

  it("discard (Start over) deletes, drops the pending change and starts again from revision 0", async () => {
    m.saveTaxonomyWizard.mockResolvedValue(out(1));
    const { result } = await mounted(out(4).data);
    act(() => { result.current.schedule(doc(1)); });
    await act(async () => { await result.current.discard(); });
    expect(m.discardTaxonomyWizard).toHaveBeenCalledTimes(1);
    expect(result.current.loaded).toBeNull();
    await tick();
    expect(m.saveTaxonomyWizard).not.toHaveBeenCalled();
    act(() => { result.current.schedule(doc(2)); });
    await tick();
    expect(m.saveTaxonomyWizard.mock.calls[0][0].revision).toBe(0);
  });

  it("close (business created) waits for a running save, deletes, and never saves again", async () => {
    let finish!: (v: any) => void;
    m.saveTaxonomyWizard.mockImplementationOnce(() => new Promise((r) => { finish = r; }));
    const { result } = await mounted();
    act(() => { result.current.schedule(doc(3)); });
    await tick();
    let closed = false;
    act(() => { void result.current.close().then(() => { closed = true; }); });
    await act(async () => {});
    expect(m.discardTaxonomyWizard).not.toHaveBeenCalled();
    await act(async () => { finish(out(1)); });
    await act(async () => {});
    expect(closed).toBe(true);
    expect(m.discardTaxonomyWizard).toHaveBeenCalledTimes(1);
    act(() => { result.current.schedule(doc(3)); });
    await tick();
    expect(m.saveTaxonomyWizard).toHaveBeenCalledTimes(1);
  });

  it("a pending change is saved at once on unmount", async () => {
    m.saveTaxonomyWizard.mockResolvedValue(out(1));
    const { result, unmount } = await mounted();
    act(() => { result.current.schedule(doc(2)); });
    unmount();
    expect(m.saveTaxonomyWizard).toHaveBeenCalledTimes(1);
    expect(m.saveTaxonomyWizard.mock.calls[0][0]).toEqual({ ...doc(2), revision: 0 });
  });

  it("a pending change is saved with keepalive when the page is hidden", async () => {
    m.saveTaxonomyWizard.mockResolvedValue(out(1));
    const { result } = await mounted();
    act(() => { result.current.schedule(doc(2)); });
    act(() => { window.dispatchEvent(new Event("pagehide")); });
    expect(m.saveTaxonomyWizard).toHaveBeenCalledTimes(1);
    expect(m.saveTaxonomyWizard.mock.calls[0][2]).toEqual({ keepalive: true });
  });

  it("the loaded document put back on screen is not saved; the first real change is, and so is a change back", async () => {
    m.saveTaxonomyWizard.mockResolvedValueOnce(out(5)).mockResolvedValueOnce(out(6));
    const saved = out(4, { tree: TREE, sector_id: null }).data;
    const { result } = await mounted(saved);
    // Same document, keys in another order (as the editor rebuilds it).
    const same = { sections: {}, tree: TREE, strictness: "strict", sector_id: null, intake: INTAKE, step: 1 } as WizardDoc;
    act(() => { result.current.schedule(same); });
    await tick();
    expect(m.saveTaxonomyWizard).not.toHaveBeenCalled();
    act(() => { result.current.schedule({ ...same, step: 2 }); });
    await tick();
    act(() => { result.current.schedule(same); });
    await tick();
    expect(m.saveTaxonomyWizard.mock.calls.map((c) => [c[0].step, c[0].revision])).toEqual([[2, 4], [1, 5]]);
  });

  it("docKey ignores key order and undefined fields", () => {
    expect(docKey({ step: 1, intake: INTAKE, sections: {} })).toBe(docKey({ sections: {}, intake: INTAKE, step: 1, tree: undefined } as any));
    expect(docOf(out(1).data as any)).toEqual({ step: 1, intake: INTAKE, sector_id: null, strictness: "strict", tree: null, sections: {} });
  });

  it("a failed Start over throws and leaves the loaded save in place", async () => {
    m.discardTaxonomyWizard.mockRejectedValueOnce(new Error("down"));
    const { result } = await mounted(out(4).data);
    await act(async () => { await expect(result.current.discard()).rejects.toThrow("down"); });
    expect(result.current.loaded?.revision).toBe(4);
  });

  it("a 413 shows the server's message; other failures the generic one", async () => {
    m.saveTaxonomyWizard
      .mockRejectedValueOnce(new ApiError(413, "Too Large", { detail: "This wizard is too large to save (over 1 MB)." }))
      .mockRejectedValueOnce(new Error("network"));
    const { result } = await mounted();
    act(() => { result.current.schedule(doc(1)); });
    await tick();
    expect(result.current.error).toBe("This wizard is too large to save (over 1 MB).");
    act(() => { result.current.schedule(doc(2)); });
    await tick();
    expect(result.current.error).toBe(SAVE_FAILED_COPY);
  });
});
