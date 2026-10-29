/**
 * `<ComposeSurface/>` integration. Review banner shows iff the live queue has
 * items; segmented switch toggles preview/subgraph; deprecated section appears
 * only when non-empty; server-backed selection (default deselected) drives the
 * compiled preview count, the Start-run CTA, and the Selected filter; toggling a
 * card persists via the selection mutation; deprecated inputs list under the
 * Deprecated facet and a manual delete can be restored.
 */
import { afterEach, describe, expect, it, vi, beforeEach } from "vitest";
import { act, fireEvent, render, screen, waitFor } from "@testing-library/react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { vibeInputSelectionMutationKey } from "@/components/vibe-inputs/use-vibe-input-selection";
import type { VibeInputOut, ReviewQueueOut } from "@/lib/api";

// localStorage shim for the review dialog (Node 25).
function installLocalStorageShim() {
  const store = new Map<string, string>();
  vi.stubGlobal("localStorage", {
    get length() {
      return store.size;
    },
    clear: () => store.clear(),
    getItem: (k: string) => (store.has(k) ? store.get(k)! : null),
    setItem: (k: string, v: string) => store.set(k, String(v)),
    removeItem: (k: string) => store.delete(k),
    key: (i: number) => Array.from(store.keys())[i] ?? null,
  } satisfies Storage);
}
installLocalStorageShim();

let inputsData: VibeInputOut[] = [];
let queueData: ReviewQueueOut = { total: 0, items: [] };
let modelDomains: { name: string; division: string }[] = [{ name: "Sales", division: "GTM" }];
const compileMock = vi.fn();
const notifyErrorMock = vi.fn();
const selectionMutate = vi.fn();
const createMutate = vi.fn();
const restoreMutate = vi.fn();

vi.mock("@/lib/api", async () => {
  const actual = await vi.importActual<typeof import("@/lib/api")>("@/lib/api");
  return {
    ...actual,
    useListVibeInputsSuspense: () => ({ data: inputsData }),
    useGetModelSummarySuspense: () => ({ data: { domains: modelDomains } }),
    compileVibeInputs: (...args: unknown[]) => compileMock(...args),
    useGetReviewQueueSuspense: () => ({ data: queueData }),
    useCreateVibeInput: () => ({ mutate: createMutate, isPending: false }),
    useUpdateVibeInput: () => ({ mutate: vi.fn(), isPending: false }),
    useRestoreVibeInput: () => ({ mutate: restoreMutate, isPending: false, variables: undefined }),
    useSetVibeInputSelection: () => ({ mutate: selectionMutate, isPending: false }),
    useAcceptReviewLink: () => ({ mutate: vi.fn(), isPending: false }),
    useReanchorReviewLink: () => ({ mutate: vi.fn(), isPending: false }),
    useDismissReviewLink: () => ({ mutate: vi.fn(), isPending: false }),
  };
});

vi.mock("@/lib/notify", async () => {
  const actual = await vi.importActual<typeof import("@/lib/notify")>("@/lib/notify");
  return { ...actual, notifyError: (...args: unknown[]) => notifyErrorMock(...args) };
});

const navigateMock = vi.fn();
vi.mock("@tanstack/react-router", async () => {
  const actual = await vi.importActual<typeof import("@tanstack/react-router")>(
    "@tanstack/react-router",
  );
  return { ...actual, useNavigate: () => navigateMock };
});

vi.mock("@/components/diagram/diagram-viewer", () => ({
  DiagramViewer: () => <div data-testid="diagram-viewer-stub" />,
}));

import { ComposeSurface } from "@/components/vibe-inputs/compose-surface";

const mk = (over: Partial<VibeInputOut> & { id: string }): VibeInputOut => ({
  business_id: "biz-1",
  origin: "user",
  author: "",
  text: "a rule",
  priority: "medium",
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

function renderSurface(qc = new QueryClient()) {
  render(
    <QueryClientProvider client={qc}>
      <ComposeSurface businessId="biz-1" version="2" scope="ecm" versionId="ver-1" />
    </QueryClientProvider>,
  );
}

describe("ComposeSurface", () => {
  beforeEach(() => {
    inputsData = [mk({ id: "a", text: "first rule" })];
    queueData = { total: 0, items: [] };
    selectionMutate.mockClear();
    createMutate.mockClear();
    restoreMutate.mockClear();
    navigateMock.mockClear();
    compileMock.mockReset();
    compileMock.mockResolvedValue({ data: { input_scope_domains: {} } });
    notifyErrorMock.mockClear();
    modelDomains = [{ name: "Sales", division: "GTM" }];
  });

  it("Add Instruction with a non-default priority creates with that priority", () => {
    renderSurface();
    fireEvent.click(screen.getByText("Add instruction"));
    fireEvent.click(screen.getByLabelText("Priority"));
    fireEvent.click(screen.getByRole("option", { name: "High" }));
    const ta = screen.getByPlaceholderText(/New model-wide instruction/) as HTMLTextAreaElement;
    fireEvent.change(ta, { target: { value: "urgent instruction" } });
    fireEvent.click(screen.getByRole("button", { name: "Add" }));
    expect(createMutate).toHaveBeenCalledWith(
      expect.objectContaining({
        data: expect.objectContaining({ text: "urgent instruction", priority: "high" }),
      }),
      expect.anything(),
    );
  });

  it("hides the review banner when the queue is empty", () => {
    renderSurface();
    expect(screen.queryByText(/need link review/)).not.toBeInTheDocument();
  });

  it("shows the review banner when the live queue has items", () => {
    queueData = { total: 2, items: [] };
    renderSurface();
    expect(screen.getByText(/2 inputs need link review/)).toBeInTheDocument();
  });

  it("segmented switch toggles preview ↔ subgraph", () => {
    renderSurface();
    expect(screen.getByTestId("compiled-preview-count")).toBeInTheDocument();
    fireEvent.click(screen.getByRole("button", { name: "Model subgraph" }));
    expect(screen.queryByTestId("compiled-preview-count")).not.toBeInTheDocument();
    expect(screen.getByText(/Focus a domain or product card/)).toBeInTheDocument();
  });

  it("starts deselected: compiled preview counts only selected inputs", () => {
    inputsData = [
      mk({ id: "a" }),
      mk({ id: "b", selected_for_run: true }),
      mk({ id: "c", status: "deprecated" }),
    ];
    renderSurface();
    // Only b is selected_for_run; a is default-deselected, c deprecated.
    expect(screen.getByTestId("compiled-preview-count")).toHaveTextContent("1 selected");
  });

  it("toggling a card persists the selection via the mutation", () => {
    inputsData = [mk({ id: "a", text: "first rule" })];
    renderSurface();
    fireEvent.click(screen.getByLabelText("Include in next run"));
    expect(selectionMutate).toHaveBeenCalledWith({
      params: { business_id: "biz-1" },
      data: { input_ids: ["a"], selected: true },
    });
  });

  it("Start-run CTA is disabled at zero selected and enabled with a selection", async () => {
    inputsData = [mk({ id: "a" })];
    renderSurface();
    const cta = screen.getByTestId("start-run-cta");
    expect(cta).toBeDisabled();
    expect(cta).toHaveTextContent("0 selected");

    inputsData = [mk({ id: "a", selected_for_run: true })];
    renderSurface();
    const enabled = screen.getAllByTestId("start-run-cta").at(-1)!;
    expect(enabled).not.toBeDisabled();
    expect(enabled).toHaveTextContent("1 selected");
    fireEvent.click(enabled);
    await waitFor(() => expect(navigateMock).toHaveBeenCalled());
    expect(navigateMock).toHaveBeenCalledWith(
      expect.objectContaining({
        to: "/businesses/$businessId/runs/new",
        params: { businessId: "biz-1" },
        search: expect.objectContaining({ sourceVersion: 2, sourceScope: "ecm" }),
      }),
    );
  });

  it("keeps Start run disabled while selection writes are queued, then enables it", async () => {
    inputsData = [mk({ id: "a", selected_for_run: true })];
    const qc = new QueryClient();
    let finish: () => void = () => {};
    const write = qc
      .getMutationCache()
      .build(qc, {
        mutationKey: vibeInputSelectionMutationKey("biz-1"),
        mutationFn: () => new Promise<void>((r) => (finish = r)),
      })
      .execute(undefined);
    renderSurface(qc);
    const cta = screen.getByTestId("start-run-cta");
    await waitFor(() => expect(cta).toBeDisabled());
    expect(cta).toHaveAttribute("title", expect.stringContaining("Saving your selection"));
    fireEvent.click(cta);
    expect(compileMock).not.toHaveBeenCalled();
    await act(async () => {
      finish();
      await write;
    });
    await waitFor(() => expect(cta).not.toBeDisabled());
    fireEvent.click(cta);
    await waitFor(() => expect(navigateMock).toHaveBeenCalled());
  });

  describe("Start run pre-fills the scope from the selected feedback", () => {
    const anchored = (id: string, domain: string | null) =>
      mk({
        id,
        selected_for_run: true,
        anchor: domain
          ? { level: "element", domain_name: domain, path: [`Domain: ${domain}`] }
          : { level: "model_wide", path: [] },
      });
    const startRun = async () => {
      renderSurface();
      fireEvent.click(screen.getAllByTestId("start-run-cta").at(-1)!);
      await waitFor(() => expect(navigateMock).toHaveBeenCalled());
      return navigateMock.mock.calls[0][0].search as Record<string, unknown>;
    };

    it("compiles the selected ids on the viewed version and passes their domains", async () => {
      modelDomains = [
        { name: "Sales", division: "" },
        { name: "Billing", division: "" },
        { name: "Metering", division: "" },
      ];
      inputsData = [anchored("a", "Sales"), anchored("b", "Billing"), anchored("c", null), mk({ id: "d" })];
      compileMock.mockResolvedValue({
        data: { input_scope_domains: { a: "Sales", b: "billing", c: null, d: "Metering" } },
      });
      const search = await startRun();
      expect(compileMock).toHaveBeenCalledWith(
        { business_id: "biz-1", version_id: "ver-1" },
        { input_ids: ["a", "b", "c"] },
        { signal: expect.any(AbortSignal) },
      );
      expect(search).toEqual({
        operationType: "vibe modeling of version",
        sourceVersion: 2,
        sourceScope: "ecm",
        scopeDomains: "Sales, Billing",
        scopeFrom: "feedback",
      });
    });

    it("repeats a domain once, in the base's spelling", async () => {
      modelDomains = [{ name: "Sales", division: "" }, { name: "Billing", division: "" }];
      inputsData = [anchored("a", "Billing"), anchored("b", "Billing")];
      compileMock.mockResolvedValue({ data: { input_scope_domains: { a: "BILLING", b: "billing" } } });
      expect((await startRun()).scopeDomains).toBe("Billing");
    });

    it("opens on All domains when every domain of the base is covered", async () => {
      modelDomains = [{ name: "Sales", division: "" }, { name: "Billing", division: "" }];
      inputsData = [anchored("a", "Sales"), anchored("b", "Billing")];
      compileMock.mockResolvedValue({ data: { input_scope_domains: { a: "Sales", b: "Billing" } } });
      const search = await startRun();
      expect(search).not.toHaveProperty("scopeDomains");
      expect(search).not.toHaveProperty("scopeFrom");
    });

    it("opens on All domains when no selected item has a domain", async () => {
      inputsData = [anchored("a", null)];
      compileMock.mockResolvedValue({ data: { input_scope_domains: { a: null } } });
      expect(await startRun()).not.toHaveProperty("scopeFrom");
    });

    it("opens on All domains for a domain the base does not have", async () => {
      modelDomains = [{ name: "Sales", division: "" }, { name: "Billing", division: "" }];
      inputsData = [anchored("a", "Retired")];
      compileMock.mockResolvedValue({ data: { input_scope_domains: { a: "Retired" } } });
      expect(await startRun()).not.toHaveProperty("scopeDomains");
    });

    it("still opens the run form, on All domains, and says so when the compile fails", async () => {
      modelDomains = [{ name: "Sales", division: "" }, { name: "Billing", division: "" }];
      inputsData = [anchored("a", "Sales")];
      compileMock.mockRejectedValue(new Error("boom"));
      const search = await startRun();
      expect(search).not.toHaveProperty("scopeDomains");
      expect(notifyErrorMock).toHaveBeenCalledTimes(1);
      expect(notifyErrorMock.mock.calls[0][1]).toEqual(
        expect.objectContaining({ fallback: expect.stringContaining("pre-fill") }),
      );
    });

    it("ignores a second click while the compile is running", async () => {
      inputsData = [anchored("a", null)];
      let release: (v: unknown) => void = () => {};
      compileMock.mockReturnValue(new Promise((r) => (release = r)));
      renderSurface();
      const cta = screen.getAllByTestId("start-run-cta").at(-1)!;
      fireEvent.click(cta);
      fireEvent.click(cta);
      release({ data: { input_scope_domains: {} } });
      await waitFor(() => expect(navigateMock).toHaveBeenCalledTimes(1));
      expect(compileMock).toHaveBeenCalledTimes(1);
    });

    it("ignores a second click that lands in the same task as the first", async () => {
      inputsData = [anchored("a", null)];
      compileMock.mockResolvedValue({ data: { input_scope_domains: {} } });
      renderSurface();
      const cta = screen.getAllByTestId("start-run-cta").at(-1)!;
      await act(async () => {
        cta.click();
        cta.click();
      });
      await waitFor(() => expect(navigateMock).toHaveBeenCalledTimes(1));
      expect(compileMock).toHaveBeenCalledTimes(1);
    });

    it("can start again after a run was started and the surface stayed mounted", async () => {
      inputsData = [anchored("a", null)];
      compileMock.mockResolvedValue({ data: { input_scope_domains: {} } });
      renderSurface();
      const cta = screen.getAllByTestId("start-run-cta").at(-1)!;
      await act(async () => cta.click());
      await waitFor(() => expect(navigateMock).toHaveBeenCalledTimes(1));
      await act(async () => cta.click());
      await waitFor(() => expect(navigateMock).toHaveBeenCalledTimes(2));
    });

    describe("when the compile does not answer", () => {
      afterEach(() => vi.useRealTimers());

      it("gives up after the bounded wait and opens the run form on All domains with a toast", async () => {
        modelDomains = [{ name: "Sales", division: "" }, { name: "Billing", division: "" }];
        inputsData = [anchored("a", "Sales")];
        compileMock.mockReturnValue(new Promise(() => {}));
        renderSurface();
        const cta = screen.getAllByTestId("start-run-cta").at(-1)!;
        vi.useFakeTimers();
        fireEvent.click(cta);
        await act(async () => {
          await vi.advanceTimersByTimeAsync(9_999);
        });
        expect(navigateMock).not.toHaveBeenCalled();
        expect(compileMock.mock.calls[0][2].signal.aborted).toBe(false);
        await act(async () => {
          await vi.advanceTimersByTimeAsync(1);
        });
        expect(compileMock.mock.calls[0][2].signal.aborted).toBe(true);
        expect(navigateMock).toHaveBeenCalledTimes(1);
        const search = navigateMock.mock.calls[0][0].search as Record<string, unknown>;
        expect(search).not.toHaveProperty("scopeDomains");
        expect(search).not.toHaveProperty("scopeFrom");
        expect(notifyErrorMock).toHaveBeenCalledTimes(1);
        expect((notifyErrorMock.mock.calls[0][0] as Error).message).toMatch(/took too long/);
      });

      it("does not toast when the compile answers in time", async () => {
        inputsData = [anchored("a", null)];
        compileMock.mockResolvedValue({ data: { input_scope_domains: {} } });
        renderSurface();
        const cta = screen.getAllByTestId("start-run-cta").at(-1)!;
        vi.useFakeTimers();
        fireEvent.click(cta);
        await act(async () => {
          await vi.advanceTimersByTimeAsync(20_000);
        });
        expect(navigateMock).toHaveBeenCalledTimes(1);
        expect(notifyErrorMock).not.toHaveBeenCalled();
      });
    });
  });

  it("Selected filter narrows the tree to selected inputs", () => {
    inputsData = [
      mk({
        id: "a",
        text: "selected rule",
        selected_for_run: true,
        anchor: { level: "element", domain_name: "Sales", path: ["Domain: Sales"] },
      }),
      mk({
        id: "b",
        text: "unselected rule",
        anchor: { level: "element", domain_name: "Sales", path: ["Domain: Sales"] },
      }),
    ];
    renderSurface();
    expect(screen.getByText("unselected rule")).toBeInTheDocument();
    fireEvent.click(screen.getByLabelText("Filter by selection"));
    fireEvent.click(screen.getByRole("option", { name: "Selected" }));
    expect(screen.getByText("selected rule")).toBeInTheDocument();
    expect(screen.queryByText("unselected rule")).not.toBeInTheDocument();
  });

  it("deprecated section appears only when non-empty", () => {
    renderSurface();
    expect(screen.queryByText(/^Deprecated/)).not.toBeInTheDocument();
    inputsData = [mk({ id: "a" }), mk({ id: "d", status: "deprecated", text: "old rule" })];
    renderSurface();
    expect(screen.getByText(/Deprecated \(1\)/)).toBeInTheDocument();
  });

  describe("Deprecated facet and Restore", () => {
    const pickDeprecatedFacet = () => {
      fireEvent.click(screen.getByLabelText("Filter by state"));
      fireEvent.click(screen.getByRole("option", { name: "Deprecated" }));
    };

    it("lists the deprecated inputs under the facet, matching the count", () => {
      inputsData = [
        mk({ id: "a", text: "live rule" }),
        mk({ id: "d1", status: "deprecated", deprecated_by: "me@x.com", text: "old rule one" }),
        mk({ id: "d2", status: "deprecated", deprecated_by: "me@x.com", text: "old rule two" }),
      ];
      renderSurface();
      pickDeprecatedFacet();
      expect(screen.getAllByTestId("deprecated-item")).toHaveLength(2);
      expect(screen.getByText("old rule one")).toBeInTheDocument();
      expect(screen.getByText("old rule two")).toBeInTheDocument();
      expect(screen.getByText(/Deprecated \(2\)/)).toBeInTheDocument();
      expect(screen.queryByText("live rule")).not.toBeInTheDocument();
    });

    it("says so when the facet and the other filters match nothing", () => {
      inputsData = [mk({ id: "d1", status: "deprecated", deprecated_by: "me@x.com", text: "old rule" })];
      renderSurface();
      pickDeprecatedFacet();
      fireEvent.change(screen.getByPlaceholderText(/Search/i), { target: { value: "zzz" } });
      return waitFor(() => expect(screen.getByTestId("deprecated-empty")).toBeInTheDocument());
    });

    it("outside the facet the section is collapsed and opens on click", () => {
      inputsData = [mk({ id: "a" }), mk({ id: "d", status: "deprecated", deprecated_by: "me@x.com", text: "old rule" })];
      renderSurface();
      expect(screen.queryByText("old rule")).not.toBeInTheDocument();
      fireEvent.click(screen.getByRole("button", { name: /Deprecated \(1\)/ }));
      expect(screen.getByText("old rule")).toBeInTheDocument();
    });

    it("Restore calls the restore endpoint for a manual delete", () => {
      inputsData = [mk({ id: "d", status: "deprecated", deprecated_by: "me@x.com", text: "old rule" })];
      renderSurface();
      pickDeprecatedFacet();
      fireEvent.click(screen.getByRole("button", { name: "Restore" }));
      expect(restoreMutate).toHaveBeenCalledWith({ params: { business_id: "biz-1", input_id: "d" } });
    });

    it("offers no Restore for an input the app deprecated and says what to do instead", () => {
      inputsData = [mk({ id: "d", status: "deprecated", deprecated_by: null, text: "old rule" })];
      renderSurface();
      pickDeprecatedFacet();
      expect(screen.queryByRole("button", { name: "Restore" })).not.toBeInTheDocument();
      expect(screen.getByText(/can't be restored; add it again as new feedback/)).toBeInTheDocument();
    });
  });

  it("domain options come from non-deprecated inputs only", () => {
    const anchor = (d: string) => ({ level: "element", domain_name: d, path: [`Domain: ${d}`] });
    inputsData = [
      mk({ id: "a", anchor: anchor("Sales") as VibeInputOut["anchor"] }),
      mk({ id: "d", status: "deprecated", anchor: anchor("Retired") as VibeInputOut["anchor"] }),
    ];
    renderSurface();
    fireEvent.click(screen.getByLabelText("Filter by domain"));
    expect(screen.getByRole("option", { name: "Sales" })).toBeInTheDocument();
    expect(screen.queryByRole("option", { name: "Retired" })).not.toBeInTheDocument();
  });
});
