/**
 * `useVibeInputSelection`: selection writes reach the server one at a time, in
 * click order, across every caller of the hook, and the screen follows the
 * clicks while the requests drain. The server here is a fake that applies each
 * POST at the moment it receives it (last writer wins), so a reordered request
 * shows up as the wrong final selection.
 */
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";
import { act, renderHook, waitFor } from "@testing-library/react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import type { ReactNode } from "react";
import { useListVibeInputs, type VibeInputOut } from "@/lib/api";
import {
  useIsSelectionSaving,
  useVibeInputSelection,
  vibeInputSelectionScope,
} from "@/components/vibe-inputs/use-vibe-input-selection";

const BIZ = "biz-1";
const VER = "ver-1";

const mk = (id: string, selected = false): VibeInputOut => ({
  id,
  business_id: BIZ,
  origin: "user",
  author: "",
  text: id,
  priority: "medium",
  confidence_score: null,
  consumed: false,
  status: "active",
  selected_for_run: selected,
  deprecated_by: null,
  created_at: "2026-01-01T00:00:00Z",
  updated_at: "2026-01-01T00:00:00Z",
  anchor: { level: "model_wide", path: [] },
});

interface PostCall {
  ids: string[];
  selected: boolean;
  release: () => void;
}

let server: Map<string, boolean>;
let posts: PostCall[];
let listGets: number;
let holdGets: Promise<void> | null;

function installFakeServer(delayPost: (index: number) => boolean) {
  server = new Map([
    ["a", false],
    ["b", false],
    ["c", false],
  ]);
  posts = [];
  listGets = 0;
  holdGets = null;
  vi.stubGlobal(
    "fetch",
    vi.fn(async (url: string, init?: RequestInit) => {
      if (init?.method === "POST" && url.endsWith("/inputs/selection")) {
        const body = JSON.parse(String(init.body)) as { input_ids: string[]; selected: boolean };
        const index = posts.length;
        let release: () => void = () => {};
        const held = delayPost(index) ? new Promise<void>((r) => (release = r)) : Promise.resolve();
        posts.push({ ids: body.input_ids, selected: body.selected, release });
        for (const id of body.input_ids) server.set(id, body.selected);
        await held;
        return new Response(JSON.stringify([]), { status: 200 });
      }
      listGets += 1;
      if (holdGets) await holdGets;
      const rows = [...server.entries()].map(([id, sel]) => mk(id, sel));
      return new Response(JSON.stringify(rows), { status: 200 });
    }),
  );
}

function setup() {
  const queryClient = new QueryClient({ defaultOptions: { queries: { retry: false, staleTime: Infinity } } });
  const wrapper = ({ children }: { children: ReactNode }) => (
    <QueryClientProvider client={queryClient}>{children}</QueryClientProvider>
  );
  return { queryClient, wrapper };
}

const selectedInCache = (rows: VibeInputOut[] | undefined) =>
  (rows ?? []).filter((r) => r.selected_for_run).map((r) => r.id).sort();
const selectedOnServer = () =>
  [...server.entries()].filter(([, v]) => v).map(([k]) => k).sort();
const post = (ids: string[], selected: boolean) => ({
  params: { business_id: BIZ },
  data: { input_ids: ids, selected },
});

beforeEach(() => vi.useRealTimers());
afterEach(() => vi.unstubAllGlobals());

describe("useVibeInputSelection", () => {
  it("scopes the mutations per business", () => {
    expect(vibeInputSelectionScope("biz-1")).toEqual({ id: "vibe-input-selection-biz-1" });
  });

  it("a slow select-all does not overtake the deselects fired after it", async () => {
    installFakeServer((i) => i === 0);
    const { wrapper } = setup();
    const { result } = renderHook(
      () => ({
        list: useListVibeInputs({ params: { business_id: BIZ, version_id: VER } }),
        selection: useVibeInputSelection(BIZ),
      }),
      { wrapper },
    );
    await waitFor(() => expect(result.current.list.data?.data).toHaveLength(3));

    act(() => {
      result.current.selection.mutate(post(["a", "b", "c"], true));
      result.current.selection.mutate(post(["a"], false));
      result.current.selection.mutate(post(["b"], false));
    });

    await waitFor(() => expect(selectedInCache(result.current.list.data?.data)).toEqual(["c"]));
    expect(posts).toHaveLength(1);
    expect(posts[0].ids).toEqual(["a", "b", "c"]);

    await act(async () => posts[0].release());
    await waitFor(() => expect(posts).toHaveLength(3));
    expect(posts.map((p) => [p.ids, p.selected])).toEqual([
      [["a", "b", "c"], true],
      [["a"], false],
      [["b"], false],
    ]);

    await waitFor(() => expect(result.current.selection.isPending).toBe(false));
    expect(selectedOnServer()).toEqual(["c"]);
    await waitFor(() => expect(selectedInCache(result.current.list.data?.data)).toEqual(["c"]));
  });

  it("does not refetch the list until the last queued request has settled", async () => {
    installFakeServer((i) => i === 0);
    const { wrapper } = setup();
    const { result } = renderHook(
      () => ({
        list: useListVibeInputs({ params: { business_id: BIZ, version_id: VER } }),
        selection: useVibeInputSelection(BIZ),
      }),
      { wrapper },
    );
    await waitFor(() => expect(result.current.list.data?.data).toHaveLength(3));
    const getsBefore = listGets;

    act(() => {
      result.current.selection.mutate(post(["a", "b", "c"], true));
      result.current.selection.mutate(post(["a"], false));
    });
    await waitFor(() => expect(selectedInCache(result.current.list.data?.data)).toEqual(["b", "c"]));
    await act(async () => posts[0].release());
    await waitFor(() => expect(posts).toHaveLength(2));
    await waitFor(() => expect(result.current.selection.isPending).toBe(false));
    await waitFor(() => expect(listGets).toBe(getsBefore + 1));
    expect(selectedInCache(result.current.list.data?.data)).toEqual(["b", "c"]);
  });

  it("reports saving until the settled list is in the cache", async () => {
    installFakeServer((i) => i === 0);
    const { wrapper } = setup();
    const { result } = renderHook(
      () => ({
        list: useListVibeInputs({ params: { business_id: BIZ, version_id: VER } }),
        selection: useVibeInputSelection(BIZ),
        saving: useIsSelectionSaving(BIZ),
        other: useIsSelectionSaving("biz-2"),
      }),
      { wrapper },
    );
    await waitFor(() => expect(result.current.list.data?.data).toHaveLength(3));
    expect(result.current.saving).toBe(false);

    act(() => {
      result.current.selection.mutate(post(["a", "b", "c"], true));
      result.current.selection.mutate(post(["a"], false));
    });
    await waitFor(() => expect(result.current.saving).toBe(true));
    expect(result.current.other).toBe(false);

    const getsBefore = listGets;
    let openGets: () => void = () => {};
    holdGets = new Promise<void>((r) => (openGets = r));
    await act(async () => posts[0].release());
    await waitFor(() => expect(posts).toHaveLength(2));
    await waitFor(() => expect(listGets).toBe(getsBefore + 1));
    expect(result.current.saving).toBe(true);
    expect(selectedOnServer()).toEqual(["b", "c"]);

    await act(async () => openGets());
    await waitFor(() => expect(result.current.saving).toBe(false));
    expect(result.current.list.isFetching).toBe(false);
    expect(selectedInCache(result.current.list.data?.data)).toEqual(["b", "c"]);
  });

  it("serializes writes from two callers of the hook (compose surface and run report)", async () => {
    installFakeServer((i) => i === 0);
    const { wrapper } = setup();
    const { result } = renderHook(
      () => ({ compose: useVibeInputSelection(BIZ), report: useVibeInputSelection(BIZ) }),
      { wrapper },
    );
    act(() => {
      void result.current.report.mutateAsync(post(["a", "b", "c"], true));
      result.current.compose.mutate(post(["b"], false));
    });
    await waitFor(() => expect(posts).toHaveLength(1));
    await act(async () => posts[0].release());
    await waitFor(() => expect(posts).toHaveLength(2));
    expect(selectedOnServer()).toEqual(["a", "c"]);
  });

  it("does not serialize across businesses", async () => {
    installFakeServer((i) => i === 0);
    const { wrapper } = setup();
    const { result } = renderHook(
      () => ({ one: useVibeInputSelection("biz-1"), two: useVibeInputSelection("biz-2") }),
      { wrapper },
    );
    act(() => {
      result.current.one.mutate(post(["a"], true));
      result.current.two.mutate({ params: { business_id: "biz-2" }, data: { input_ids: ["b"], selected: true } });
    });
    await waitFor(() => expect(posts).toHaveLength(2));
    await act(async () => posts[0].release());
  });

  it("a failed request lets the queue continue and the list reconcile with the server", async () => {
    installFakeServer(() => false);
    const realFetch = globalThis.fetch as unknown as (u: string, i?: RequestInit) => Promise<Response>;
    let n = 0;
    vi.stubGlobal(
      "fetch",
      vi.fn(async (url: string, init?: RequestInit) => {
        if (init?.method === "POST" && n++ === 0) return new Response("boom", { status: 500, statusText: "x" });
        return realFetch(url, init);
      }),
    );
    const { wrapper } = setup();
    const { result } = renderHook(
      () => ({
        list: useListVibeInputs({ params: { business_id: BIZ, version_id: VER } }),
        selection: useVibeInputSelection(BIZ),
      }),
      { wrapper },
    );
    await waitFor(() => expect(result.current.list.data?.data).toHaveLength(3));
    act(() => {
      result.current.selection.mutate(post(["a"], true));
      result.current.selection.mutate(post(["b"], true));
    });
    await waitFor(() => expect(result.current.selection.isPending).toBe(false));
    await waitFor(() => expect(selectedInCache(result.current.list.data?.data)).toEqual(["b"]));
    expect(selectedOnServer()).toEqual(["b"]);
  });
});
