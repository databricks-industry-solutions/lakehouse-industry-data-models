/**
 * OobBanner - versions the agent wrote outside the app, on the business page
 * (one business) and the businesses list (every segment). Real query hooks
 * over a stubbed `fetch`.
 */
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";
import { fireEvent, screen, waitFor } from "@testing-library/react";
import { QueryClient } from "@tanstack/react-query";

import {
  OobBanner,
  entriesForBusiness,
  importable,
  oobDismissKey,
  oobFingerprint,
  undismissed,
  versionCount,
} from "@/components/oob/oob-banner";
import type { OobBusinessOut, OobSummaryOut } from "@/lib/api";
import { renderWithRouter } from "./helpers/router-wrapper";

const existing = (versions: [number, string][], id = "b1"): OobBusinessOut => ({
  business_segment: "wt_base",
  status: "existing",
  business_id: id,
  candidate_business_ids: [],
  versions: versions.map(([version, scope]) => ({ version, scope })),
});

const brandNew: OobBusinessOut = {
  business_segment: "brand_new",
  status: "new",
  business_id: null,
  candidate_business_ids: [],
  versions: [{ version: 1, scope: "ecm" }],
};

const ambiguous: OobBusinessOut = {
  business_segment: "acme",
  status: "ambiguous",
  business_id: null,
  candidate_business_ids: ["b1", "b9"],
  versions: [{ version: 1, scope: "mvm" }],
};

let role = "app_admin";
let summary: OobSummaryOut;
let prefs: { key: string; value: string; updated_at: string }[] = [];
let checkStatus = 200;
let calls: { method: string; url: string; body?: string }[] = [];

function respond(method: string, url: string, body?: string): [number, unknown] {
  if (url.endsWith("/api/user/role")) return [200, { role }];
  if (url.endsWith("/api/oob/summary")) return [200, summary];
  if (url.endsWith("/api/user/preferences") && method === "GET") return [200, prefs];
  const pref = url.match(/\/api\/user\/preferences\/(.+)$/);
  if (pref && method === "PUT") {
    const key = decodeURIComponent(pref[1]);
    const value = JSON.parse(body ?? "{}").value;
    prefs = [...prefs.filter((p) => p.key !== key), { key, value, updated_at: "2026-10-01T00:00:00Z" }];
    return [200, { key, value, updated_at: "2026-10-01T00:00:00Z" }];
  }
  if (url.endsWith("/api/oob/check")) {
    if (checkStatus === 429) {
      return [429, { detail: { error: "rate_limited", message: "A check ran less than a minute ago. Try again in 40 s.", retry_after_s: 40 } }];
    }
    return [200, { ...summary, businesses: [existing([[2, "mvm"]])], checked_at: new Date().toISOString() }];
  }
  if (url.match(/\/api\/businesses\/[^/]+\/oob\/import$/)) {
    summary = { ...summary, businesses: [] };
    return [200, { imported_versions: 1, created_business_ids: [], warnings: [] }];
  }
  if (url.endsWith("/api/oob/import-new-businesses")) {
    return [200, { imported_versions: 1, created_business_ids: ["b2"], warnings: [] }];
  }
  if (url.match(/\/api\/businesses(\?.*)?$/)) return [200, [{ id: "b1", name: "WT-Base" }]];
  if (url.includes("/versions") || url.includes("/explorer")) return [200, []];
  throw new Error(`unexpected fetch ${method} ${url}`);
}

beforeEach(() => {
  role = "app_admin";
  prefs = [];
  checkStatus = 200;
  calls = [];
  summary = {
    checked_at: new Date(Date.now() - 5 * 60_000).toISOString(),
    catalog: "cat",
    skipped_reason: null,
    businesses: [existing([[2, "mvm"]])],
    checking: false,
  };
  vi.stubGlobal(
    "fetch",
    vi.fn(async (input: RequestInfo | URL, init?: RequestInit) => {
      const url = String(input);
      const method = (init?.method ?? "GET").toUpperCase();
      const body = typeof init?.body === "string" ? init.body : undefined;
      calls.push({ method, url, body });
      const [status, payload] = respond(method, url, body);
      return new Response(JSON.stringify(payload), {
        status,
        headers: { "Content-Type": "application/json" },
      });
    }),
  );
});

afterEach(() => {
  vi.unstubAllGlobals();
});

function mount(businessId?: string) {
  const queryClient = new QueryClient({ defaultOptions: { queries: { retry: false } } });
  return renderWithRouter(<OobBanner businessId={businessId} />, { queryClient });
}

const posted = (suffix: string) => calls.filter((c) => c.method !== "GET" && c.url.endsWith(suffix));

describe("oob helpers", () => {
  it("fingerprints the sorted set of versions", () => {
    expect(oobFingerprint(existing([[3, "mvm"], [1, "ecm"], [3, "ecm"], [2, "mvm"]]))).toBe(
      "1:ecm,2:mvm,3:ecm,3:mvm",
    );
    expect(oobFingerprint(existing([]))).toBe("");
  });

  it("leaves refused versions out of the importable ones", () => {
    const e = existing([[1, "mvm"], [2, "mvm"]]);
    e.versions![0].refused_reason = "not imported. Agent tag 'v0.0.1' is unknown.";
    expect(importable(e).map((v) => v.version)).toEqual([2]);
  });

  it("keys a dismissal on the business, or the segment without one", () => {
    expect(oobDismissKey(existing([[1, "mvm"]]))).toBe("oob_dismissed:b1");
    expect(oobDismissKey(brandNew)).toBe("oob_dismissed:segment:brand_new");
  });

  it("hides a dismissed entry until a newer version appears", () => {
    const at = (value: string) => [{ key: "oob_dismissed:b1", value, updated_at: "" }];
    expect(undismissed([existing([[2, "mvm"]])], at("2:mvm"))).toEqual([]);
    expect(undismissed([existing([[2, "mvm"], [3, "mvm"]])], at("2:mvm"))).toHaveLength(1);
    expect(undismissed([existing([[1, "mvm"], [2, "mvm"]])], at("2:mvm"))).toHaveLength(1);
    expect(undismissed([existing([[2, "mvm"]])], undefined)).toHaveLength(1);
  });

  it("picks a business's own entries and the segments it shares", () => {
    const all = [existing([[2, "mvm"]]), existing([[1, "ecm"]], "b2"), brandNew, ambiguous];
    expect(entriesForBusiness(all, "b1").map((e) => e.business_segment)).toEqual(["wt_base", "acme"]);
    expect(entriesForBusiness(all, "b9").map((e) => e.status)).toEqual(["ambiguous"]);
    expect(versionCount(all)).toBe(4);
  });
});

describe("OobBanner on a business page", () => {
  it("shows the business's versions and imports them", async () => {
    mount("b1");
    const banner = await screen.findByTestId("oob-banner");
    expect(banner).toHaveTextContent("Detected 1 model version created outside this app");
    expect(banner).toHaveTextContent("v2 MVM");
    expect(banner).toHaveTextContent("Last checked 5m ago");

    fireEvent.click(screen.getByRole("button", { name: "Import" }));

    await waitFor(() => expect(posted("/api/businesses/b1/oob/import")).toHaveLength(1));
    await waitFor(() => expect(screen.queryByTestId("oob-banner")).not.toBeInTheDocument());
  });

  it("renders nothing for a business without out-of-band versions", async () => {
    mount("b7");
    await waitFor(() => expect(calls.some((c) => c.url.endsWith("/api/oob/summary"))).toBe(true));
    expect(screen.queryByTestId("oob-banner")).not.toBeInTheDocument();
    expect(screen.queryByTestId("oob-last-checked")).not.toBeInTheDocument();
  });

  it("is hidden from viewers, who never ask for the summary", async () => {
    role = "viewer";
    mount("b1");
    await waitFor(() => expect(calls.some((c) => c.url.endsWith("/api/user/role"))).toBe(true));
    await new Promise((r) => setTimeout(r, 20));
    expect(calls.some((c) => c.url.endsWith("/api/oob/summary"))).toBe(false);
    expect(screen.queryByTestId("oob-banner")).not.toBeInTheDocument();
  });

  it("dismisses per user at the newest version", async () => {
    mount("b1");
    await screen.findByTestId("oob-banner");

    fireEvent.click(screen.getByRole("button", { name: "Dismiss" }));

    await waitFor(() => expect(screen.queryByTestId("oob-banner")).not.toBeInTheDocument());
    const put = calls.find((c) => c.method === "PUT")!;
    expect(decodeURIComponent(put.url)).toMatch(/\/api\/user\/preferences\/oob_dismissed:b1$/);
    expect(JSON.parse(put.body!)).toEqual({ value: "2:mvm" });
  });

  it("labels a refused version and disables Import when nothing is importable", async () => {
    const e = existing([[1, "mvm"]]);
    e.versions![0].refused_reason = "Waiting for the agent's registry migration.";
    summary = { ...summary, businesses: [e] };
    mount("b1");
    const banner = await screen.findByTestId("oob-banner");
    expect(banner).toHaveTextContent("v1 MVM - not importable: Waiting for the agent's registry migration.");
    expect(screen.getByRole("button", { name: "Import" })).toBeDisabled();
  });

  it("shows a shared segment without an Import button", async () => {
    summary = { ...summary, businesses: [ambiguous] };
    mount("b1");
    const banner = await screen.findByTestId("oob-banner");
    expect(banner).toHaveTextContent("Several businesses share this name");
    expect(screen.queryByRole("button", { name: "Import" })).not.toBeInTheDocument();
  });
});

describe("OobBanner on the businesses list", () => {
  it("lists every segment and offers to create the new businesses", async () => {
    summary = { ...summary, businesses: [existing([[2, "mvm"]]), brandNew, ambiguous] };
    mount();
    const banner = await screen.findByTestId("oob-banner");
    expect(banner).toHaveTextContent("Detected 3 model versions created outside this app");
    await waitFor(() => expect(screen.getByRole("link", { name: "WT-Base" })).toBeInTheDocument());
    expect(banner).toHaveTextContent("brand_new");
    expect(banner).toHaveTextContent("(new business)");

    fireEvent.click(screen.getByRole("button", { name: "Import as new businesses" }));

    await waitFor(() => expect(posted("/api/oob/import-new-businesses")).toHaveLength(1));
  });

  it("disables Import as new businesses when every new version is refused", async () => {
    const refused = { ...brandNew, versions: [{ version: 1, scope: "ecm", refused_reason: "not imported." }] };
    summary = { ...summary, businesses: [refused] };
    mount();
    await screen.findByTestId("oob-banner");
    expect(screen.getByRole("button", { name: "Import as new businesses" })).toBeDisabled();
  });

  it("does not offer business creation to modelers", async () => {
    role = "modeler";
    summary = { ...summary, businesses: [brandNew] };
    mount();
    await screen.findByTestId("oob-banner");
    await waitFor(() => expect(calls.some((c) => c.url.endsWith("/api/user/role"))).toBe(true));
    expect(screen.queryByRole("button", { name: "Import as new businesses" })).not.toBeInTheDocument();
  });

  it("shows the check line when nothing was found and checks now", async () => {
    summary = { ...summary, businesses: [], checked_at: null, skipped_reason: "warehouse_not_running" };
    mount();
    const line = await screen.findByTestId("oob-last-checked");
    expect(line).toHaveTextContent("Not checked: the SQL warehouse is stopped");
    expect(line).toHaveTextContent("may start the SQL warehouse");

    fireEvent.click(screen.getByRole("button", { name: /Check now/ }));

    await waitFor(() => expect(posted("/api/oob/check")).toHaveLength(1));
    expect(await screen.findByTestId("oob-banner")).toHaveTextContent("v2 MVM");
  });

  it("disables Check now while a check runs", async () => {
    summary = { ...summary, businesses: [], checking: true };
    mount();
    const line = await screen.findByTestId("oob-last-checked");
    expect(line).toHaveTextContent("Checking now");
    expect(screen.getByRole("button", { name: /Check now/ })).toBeDisabled();
  });
});
