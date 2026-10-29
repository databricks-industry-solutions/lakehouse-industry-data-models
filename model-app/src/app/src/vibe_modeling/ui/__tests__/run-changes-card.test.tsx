import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";
import { fireEvent, screen, waitFor } from "@testing-library/react";

import {
  RunChangesCard,
  VersionChangesSummary,
  derivedOutputVersionId,
  rollbackCopy,
  vibeOutputVersionId,
} from "@/components/runs/run-changes-card";
import type { RunChangeOut, RunChangesOut, RunOperationOut } from "@/lib/api";
import type { LifecycleVersion } from "@/lib/version-lifecycle";
import { RunVibeContent } from "@/components/help/run-help-content";
import { renderWithRouter } from "./helpers/router-wrapper";

const VIBE_OP = {
  id: "op-1",
  run_id: "r1",
  step_index: 0,
  operation_name: "vibe_iterate",
  status: "succeeded",
  parent_version_id: "v1",
  output_version_id: "v2",
  created_at: "2026-10-20T12:00:00Z",
} as unknown as RunOperationOut;

const VERSIONS = [
  { id: "v1", business_id: "b1", version: 1, scope: "ecm", status: "superseded", deployment_status: "draft" },
  { id: "v2", business_id: "b1", version: 2, scope: "ecm", status: "completed", deployment_status: "draft" },
];

function change(path: string, cls: RunChangeOut["change_class"], extra: Partial<RunChangeOut> = {}): RunChangeOut {
  return {
    element_kind: path.split(".").length === 3 ? "attribute" : path.includes(".") ? "product" : "domain",
    element_path: path,
    change_kind: "added",
    change_class: cls,
    decision: null,
    decided_by: null,
    decided_at: null,
    feedback_input_id: null,
    ...extra,
  };
}

function changesBody(changes: RunChangeOut[], open = true): RunChangesOut {
  return { run_id: "r1", version_id: "v2", base_version_id: "v1", decisions_open: open, changes };
}

interface Stub {
  changes?: RunChangesOut | { status: number; detail: unknown };
  /** Bodies for successive GETs of the changes (after the first, which is `changes`). */
  laterChanges?: RunChangesOut[];
  putError?: { status: number; detail: unknown };
  afterPut?: RunChangesOut;
  afterFeedback?: RunChangesOut;
  report?: unknown;
  versionReport?: unknown;
  /** `GET /config/run-change-review`: the review is on unless a test turns it off. */
  reviewEnabled?: boolean;
}

const CONFIG_URL = "/config/run-change-review";

/** Fetches other than the flag read (`CONFIG_URL`). */
function featureCalls(fn: ReturnType<typeof vi.fn>): string[] {
  return fn.mock.calls.map(([u]) => String(u)).filter((u) => !u.endsWith(CONFIG_URL));
}

function stub({
  changes, laterChanges = [], putError, afterPut, afterFeedback, report, versionReport, reviewEnabled = true,
}: Stub) {
  let gets = 0;
  const fn = vi.fn(async (url: RequestInfo, init?: RequestInit) => {
    const u = String(url);
    const method = init?.method ?? "GET";
    if (u.endsWith(CONFIG_URL)) {
      return { ok: true, status: 200, json: async () => ({ enabled: reviewEnabled }) };
    }
    if (u.endsWith("/changes/decisions") && method === "PUT") {
      if (putError) {
        const body = JSON.stringify({ detail: putError.detail });
        return { ok: false, status: putError.status, statusText: "Conflict", text: async () => body };
      }
      return { ok: true, status: 200, json: async () => afterPut };
    }
    if (u.endsWith("/changes/rejected-feedback") && method === "POST") {
      return { ok: true, status: 200, json: async () => afterFeedback };
    }
    if (u.endsWith("/changes")) {
      gets += 1;
      if (gets > 1 && laterChanges.length > 0) {
        const body = laterChanges[Math.min(gets - 2, laterChanges.length - 1)];
        return { ok: true, status: 200, json: async () => body };
      }
      if (changes && "status" in changes) {
        const body = JSON.stringify({ detail: changes.detail });
        return { ok: false, status: changes.status, statusText: "Conflict", text: async () => body };
      }
      return { ok: true, status: 200, json: async () => changes };
    }
    if (u.includes("/versions/") && u.endsWith("/report")) {
      return { ok: true, status: 200, json: async () => versionReport };
    }
    if (u.endsWith("/report")) {
      return { ok: true, status: 200, json: async () => report ?? { items: [] } };
    }
    if (u.endsWith("/versions")) {
      return { ok: true, status: 200, json: async () => VERSIONS };
    }
    return { ok: true, status: 200, json: async () => ({}) };
  });
  vi.stubGlobal("fetch", fn);
  return fn;
}

describe("RunChangesCard", () => {
  beforeEach(() => vi.unstubAllGlobals());
  afterEach(() => {
    vi.restoreAllMocks();
    vi.unstubAllGlobals();
  });

  it("renders nothing for a run without a vibe output", async () => {
    const fetchFn = stub({});
    const { container } = renderWithRouter(
      <RunChangesCard businessId="b1" runId="r1" runStatus="completed" operations={[{ ...VIBE_OP, operation_name: "install" }]} />,
    );
    await new Promise((r) => setTimeout(r, 20));
    expect(container.textContent).toBe("");
    expect(featureCalls(fetchFn)).toEqual([]);
  });

  it("waits for the run to end, so the report card above it does not push it down", async () => {
    const fetchFn = stub({ changes: changesBody([change("Ops", "not_asked")]) });
    const { container } = renderWithRouter(
      <RunChangesCard businessId="b1" runId="r1" runStatus="running" operations={[VIBE_OP]} />,
    );
    await new Promise((r) => setTimeout(r, 30));
    expect(container.innerHTML).toBe("");
    expect(fetchFn.mock.calls.some(([u]) => String(u).endsWith("/changes"))).toBe(false);
  });

  it("waits for the run report, so a late report does not push the changes down", async () => {
    let answerReport: () => void = () => {};
    const reportGate = new Promise<void>((r) => (answerReport = r));
    const base = stub({ changes: changesBody([change("Ops", "not_asked")]) });
    vi.stubGlobal("fetch", vi.fn(async (url: RequestInfo, init?: RequestInit) => {
      const u = String(url);
      if (u.endsWith("/runs/r1/report")) {
        await reportGate;
        return { ok: true, status: 200, json: async () => ({ items: [] }) };
      }
      return base(url, init);
    }));
    renderWithRouter(<RunChangesCard businessId="b1" runId="r1" runStatus="completed" operations={[VIBE_OP]} />);
    await new Promise((r) => setTimeout(r, 30));
    expect(screen.queryByText("Ops")).toBeNull();
    expect(screen.queryByRole("list", { name: "Changes" })).toBeNull();
    answerReport();
    expect(await screen.findByText("Ops")).toBeTruthy();
  });

  it("still shows the changes when the run report fails", async () => {
    const base = stub({ changes: changesBody([change("Ops", "not_asked")]) });
    vi.stubGlobal("fetch", vi.fn(async (url: RequestInfo, init?: RequestInit) => {
      if (String(url).endsWith("/runs/r1/report")) {
        const body = JSON.stringify({ detail: "boom" });
        return { ok: false, status: 500, statusText: "Server Error", text: async () => body };
      }
      return base(url, init);
    }));
    renderWithRouter(<RunChangesCard businessId="b1" runId="r1" runStatus="completed" operations={[VIBE_OP]} />);
    expect(await screen.findByText("Ops")).toBeTruthy();
  });

  it("lists changes with hints, unasked first, and the counts", async () => {
    stub({
      changes: changesBody([
        change("Sales.Order.note", "asked"),
        change("Ops", "outside_scope", { change_kind: "removed" }),
        change("Sales.Lead", "not_asked", { decision: "rejected", decided_by: "m@x.com", decided_at: "2026-10-21T10:00:00Z" }),
      ]),
    });
    renderWithRouter(<RunChangesCard businessId="b1" runId="r1" runStatus="completed" operations={[VIBE_OP]} />);
    expect(await screen.findByText("Changes in v2 ECM")).toBeTruthy();
    expect(screen.getByText(/3 changes compared with v1 ECM: 2 you did not ask for, 1 rejected/)).toBeTruthy();
    const paths = screen.getAllByText(/^(Sales|Ops)/).map((n) => n.textContent);
    expect(paths).toEqual(["Ops", "Sales.Lead", "Sales.Order.note"]);
    expect(screen.getByText("Outside the run's scope")).toBeTruthy();
    expect(screen.getByText("Not asked")).toBeTruthy();
    expect(screen.getByText(/Rejected by m@x.com/)).toBeTruthy();
    expect(screen.getByText(/counts every change in that domain as asked/)).toBeTruthy();
  });

  it("sends one decision and shows the server's answer", async () => {
    const fetchFn = stub({
      changes: changesBody([change("Ops", "not_asked", { change_kind: "removed" })]),
      afterPut: changesBody([
        change("Ops", "not_asked", { change_kind: "removed", decision: "rejected", decided_by: "m@x.com", decided_at: "2026-10-21T10:00:00Z" }),
      ]),
    });
    renderWithRouter(<RunChangesCard businessId="b1" runId="r1" runStatus="completed" operations={[VIBE_OP]} />);
    fireEvent.click(await screen.findByRole("button", { name: "Reject the change to Ops" }));
    await waitFor(() =>
      expect(screen.getByRole("button", { name: "Reject the change to Ops" }).getAttribute("aria-pressed")).toBe("true"),
    );
    const put = fetchFn.mock.calls.find(([, init]) => (init as RequestInit | undefined)?.method === "PUT");
    expect(JSON.parse(String((put![1] as RequestInit).body))).toEqual({
      decisions: [{ element_kind: "domain", element_path: "Ops", decision: "rejected" }],
    });
  });

  it("accepts every undecided asked change in one call, leaving decided ones alone", async () => {
    const fetchFn = stub({
      changes: changesBody([
        change("Sales.Lead", "asked"),
        change("Sales.Order.note", "asked"),
        change("Sales.Order.amount", "asked", { decision: "rejected", decided_by: "m@x.com", decided_at: "2026-10-21T10:00:00Z" }),
        change("Ops", "not_asked"),
      ]),
      afterPut: changesBody([change("Ops", "not_asked")]),
    });
    renderWithRouter(<RunChangesCard businessId="b1" runId="r1" runStatus="completed" operations={[VIBE_OP]} />);
    fireEvent.click(await screen.findByRole("button", { name: "Accept all asked" }));
    await waitFor(() => expect(fetchFn.mock.calls.some(([, i]) => (i as RequestInit | undefined)?.method === "PUT")).toBe(true));
    const put = fetchFn.mock.calls.find(([, init]) => (init as RequestInit | undefined)?.method === "PUT");
    const body = JSON.parse(String((put![1] as RequestInit).body));
    expect(body.decisions.map((d: { element_path: string }) => d.element_path)).toEqual(["Sales.Lead", "Sales.Order.note"]);
    expect(body.decisions.every((d: { decision: string }) => d.decision === "accepted")).toBe(true);
  });

  it("adds rejected changes as feedback once", async () => {
    const fetchFn = stub({
      changes: changesBody([change("Ops", "not_asked", { decision: "rejected", decided_by: "m@x.com", decided_at: "2026-10-21T10:00:00Z" })]),
      afterFeedback: changesBody([
        change("Ops", "not_asked", { decision: "rejected", decided_by: "m@x.com", decided_at: "2026-10-21T10:00:00Z", feedback_input_id: "in-1" }),
      ]),
    });
    renderWithRouter(<RunChangesCard businessId="b1" runId="r1" runStatus="completed" operations={[VIBE_OP]} />);
    fireEvent.click(await screen.findByRole("button", { name: /Add rejected as feedback \(1\)/ }));
    await waitFor(() => expect(screen.getByText(/\(feedback added\)/)).toBeTruthy());
    expect(fetchFn.mock.calls.some(([u, i]) => String(u).endsWith("/rejected-feedback") && (i as RequestInit).method === "POST")).toBe(true);
    expect((screen.getByRole("button", { name: /Add rejected as feedback/ }) as HTMLButtonElement).disabled).toBe(true);
  });

  it("refetches and turns read-only after a decisions_closed answer", async () => {
    stub({
      changes: changesBody([change("Ops", "not_asked")]),
      laterChanges: [changesBody([change("Ops", "not_asked")], false)],
      putError: { status: 409, detail: { error: "decisions_closed", message: "A newer model run has started." } },
    });
    renderWithRouter(<RunChangesCard businessId="b1" runId="r1" runStatus="completed" operations={[VIBE_OP]} />);
    fireEvent.click(await screen.findByRole("button", { name: "Reject the change to Ops" }));
    expect(await screen.findByText(/these decisions are final/)).toBeTruthy();
    expect(screen.queryByRole("button", { name: /^Reject the change/ })).toBeNull();
  });

  it("says No changes and offers no rollback for an empty run", async () => {
    stub({ changes: changesBody([]) });
    renderWithRouter(<RunChangesCard businessId="b1" runId="r1" runStatus="completed" operations={[VIBE_OP]} />);
    expect(await screen.findByText("No changes compared with v1 ECM.")).toBeTruthy();
    expect(screen.getAllByText(/No changes/)).toHaveLength(1);
    expect(screen.queryByText(/The list shows domains/)).toBeNull();
    expect(screen.queryByText(/Roll back/)).toBeNull();
    expect(screen.queryByRole("button", { name: "Accept all asked" })).toBeNull();
  });

  it("is read-only once decisions are closed", async () => {
    stub({ changes: changesBody([change("Ops", "not_asked")], false) });
    renderWithRouter(<RunChangesCard businessId="b1" runId="r1" runStatus="completed" operations={[VIBE_OP]} />);
    expect(await screen.findByText(/these decisions are final/)).toBeTruthy();
    expect(screen.queryByRole("button", { name: /^Reject the change/ })).toBeNull();
    expect(screen.queryByRole("button", { name: "Accept all asked" })).toBeNull();
    expect(screen.getByText("No decision")).toBeTruthy();
  });

  it("shows the server's reason when the changes are unavailable", async () => {
    stub({
      changes: {
        status: 409,
        detail: { error: "changes_unavailable", reason: "no_base_version", message: "The version this run started from is gone." },
      },
    });
    renderWithRouter(<RunChangesCard businessId="b1" runId="r1" runStatus="completed" operations={[VIBE_OP]} />);
    expect(await screen.findByText("The version this run started from is gone.")).toBeTruthy();
  });
});

describe("rollbackCopy", () => {
  const base = { version: 5, scope: "ecm" };
  const v = (over: Partial<LifecycleVersion>): LifecycleVersion => ({
    id: "v6", version: 6, scope: "ecm", status: "completed", deployment_status: "draft",
    uc_catalog: null, files_catalog: null, dry_run: false, promoted_at: null, replaced_at: null,
    replaced_by_version_id: null, draft_state: null, is_head: true, ...over,
  } as LifecycleVersion);
  it("a Dry Run draft deletes directly", () => {
    const out = v({ status: "draft", dry_run: true });
    expect(rollbackCopy(out, base, [out], { applied: 2 })).toBe(
      "Roll back: delete v6 ECM. It is a Dry Run draft, so nothing is installed and v5 ECM stays the latest version.",
    );
  });
  it("an installed output is uninstalled first and its feedback reopens", () => {
    const out = v({ deployment_status: "deployed", uc_catalog: "main" });
    expect(rollbackCopy(out, base, [out], { applied: 2 })).toBe(
      "Roll back: uninstall v6 ECM, then delete v6 ECM. v5 ECM becomes the latest version again; install v5 ECM to restore its tables. The 2 feedback items applied in v6 ECM become open again.",
    );
  });
  it("a completed, not installed output deletes directly", () => {
    const out = v({});
    expect(rollbackCopy(out, base, [out], { applied: 1 })).toBe(
      "Roll back: delete v6 ECM. v5 ECM becomes the latest version again. The 1 feedback item applied in v6 ECM becomes open again.",
    );
  });
  it("names the newer versions to delete first, as the version page does", () => {
    const out = v({ status: "superseded", is_head: false });
    const newer = v({ id: "v7", version: 7 });
    expect(rollbackCopy(out, base, [out, newer])).toBe(
      "Roll back: delete the newer versions (v7), then delete v6 ECM. v5 ECM becomes the latest version again.",
    );
  });
  it("an installed output with newer versions: uninstall, the newer versions, then the output", () => {
    const out = v({ status: "superseded", is_head: false, deployment_status: "deployed", uc_catalog: "other" });
    const newer = v({ id: "v7", version: 7, deployment_status: "deployed", uc_catalog: "main" });
    expect(rollbackCopy(out, base, [out, newer])).toBe(
      "Roll back: uninstall v6 ECM, then delete the newer versions (v7), then delete v6 ECM. v5 ECM becomes the latest version again; install v5 ECM to restore its tables.",
    );
  });
  it("a replaced output deletes directly, whatever is newer", () => {
    const out = v({ status: "superseded", is_head: false, replaced_at: "2026-10-20T12:00:00Z", replaced_by_version_id: "v7" });
    const newer = v({ id: "v7", version: 7 });
    expect(rollbackCopy(out, base, [out, newer])).toBe(
      "Roll back: delete v6 ECM. v5 ECM becomes the latest version again.",
    );
  });
  it("a unified run deletes its derived MVM first, then the vibe output", () => {
    const out = v({ deployment_status: "deployed", uc_catalog: "main" });
    const mvm = v({ id: "m2", version: 2, scope: "mvm", deployment_status: "deployed", uc_catalog: "main" });
    expect(rollbackCopy(out, base, [out, mvm], { derived: mvm })).toBe(
      "Roll back: uninstall v2 MVM, then delete v2 MVM, then uninstall v6 ECM, then delete v6 ECM. v5 ECM becomes the latest version again; install v5 ECM to restore its tables.",
    );
  });
  it("a unified Dry Run deletes both drafts", () => {
    const out = v({ status: "draft", dry_run: true });
    const mvm = v({ id: "m2", version: 2, scope: "mvm", status: "draft", dry_run: true });
    expect(rollbackCopy(out, base, [out, mvm], { derived: mvm })).toBe(
      "Roll back: delete v2 MVM, then delete v6 ECM. They are Dry Run drafts, so nothing is installed and v5 ECM stays the latest version.",
    );
  });
  it("says the open Rejected change feedback goes with the version", () => {
    const out = v({});
    expect(rollbackCopy(out, base, [out], { rejectedFeedback: 1 })).toBe(
      'Roll back: delete v6 ECM. v5 ECM becomes the latest version again. The open "Rejected change" feedback item made from v6 ECM is deleted with it.',
    );
    expect(rollbackCopy(out, base, [out], { rejectedFeedback: 3 })).toContain(
      'The 3 open "Rejected change" feedback items made from v6 ECM are deleted with it.',
    );
  });
});

describe("vibeOutputVersionId", () => {
  it("picks the latest succeeded vibe op output", () => {
    expect(vibeOutputVersionId([VIBE_OP, { ...VIBE_OP, step_index: 1, status: "failed", output_version_id: "v9" }])).toBe("v2");
    expect(vibeOutputVersionId([{ ...VIBE_OP, status: "running" }])).toBeNull();
  });
});

describe("derivedOutputVersionId", () => {
  it("picks a unified run's succeeded shrink or enlarge output", () => {
    const shrink = { ...VIBE_OP, step_index: 1, operation_name: "shrink_to_mvm", output_version_id: "m2" };
    const enlarge = { ...VIBE_OP, step_index: 1, operation_name: "enlarge_to_ecm", output_version_id: "e3" };
    expect(derivedOutputVersionId([VIBE_OP, shrink])).toBe("m2");
    expect(derivedOutputVersionId([VIBE_OP, enlarge])).toBe("e3");
    expect(derivedOutputVersionId([VIBE_OP, { ...shrink, status: "failed" }])).toBeNull();
    expect(derivedOutputVersionId([VIBE_OP])).toBeNull();
  });
});

describe("VersionChangesSummary", () => {
  beforeEach(() => vi.unstubAllGlobals());
  afterEach(() => vi.unstubAllGlobals());

  it("counts unasked and rejected changes of the producing run and links to it", async () => {
    stub({
      versionReport: { version_id: "v2", report: { run_id: "r1", output_version_id: "v2" } },
      changes: changesBody([
        change("Ops", "not_asked", { decision: "rejected" }),
        change("Billing", "outside_scope"),
        change("Sales", "asked"),
      ]),
    });
    renderWithRouter(<VersionChangesSummary businessId="b1" versionId="v2" />);
    const line = await screen.findByTestId("version-changes-summary");
    expect(line.textContent).toContain("2 changes you did not ask for, 1 rejected.");
    expect(screen.getByRole("link", { name: "Review the changes" }).getAttribute("href")).toBe("/businesses/b1/runs/r1");
  });

  it.each([
    ["the MVM a unified run shrank", "m3"],
    ["the ECM a unified run enlarged", "e3"],
  ])("does not fetch or show the vibe output's changes on %s", async (_label, derivedId) => {
    const fetchFn = stub({
      versionReport: { version_id: derivedId, report: { run_id: "r1", output_version_id: "v2" } },
      changes: changesBody([change("Ops", "not_asked", { decision: "rejected" })]),
    });
    const { container } = renderWithRouter(<VersionChangesSummary businessId="b1" versionId={derivedId} />);
    await waitFor(() => expect(fetchFn.mock.calls.some(([u]) => String(u).endsWith("/report"))).toBe(true));
    await new Promise((r) => setTimeout(r, 20));
    expect(container.querySelector("[data-testid=version-changes-summary]")).toBeNull();
    expect(fetchFn.mock.calls.some(([u]) => String(u).endsWith("/changes"))).toBe(false);
  });

  it("renders nothing for a version no vibe run produced", async () => {
    const fetchFn = stub({ versionReport: { version_id: "v1", report: null } });
    const { container } = renderWithRouter(<VersionChangesSummary businessId="b1" versionId="v1" />);
    await waitFor(() => expect(fetchFn).toHaveBeenCalled());
    expect(container.querySelector("[data-testid=version-changes-summary]")).toBeNull();
    expect(fetchFn.mock.calls.some(([u]) => String(u).endsWith("/changes"))).toBe(false);
  });
});

describe("the run change review flag", () => {
  afterEach(() => vi.unstubAllGlobals());

  it("off: the card, the Overview line and the help about them render and fetch nothing", async () => {
    const fetchFn = stub({
      changes: changesBody([change("Ops", "not_asked", { decision: "rejected" })]),
      versionReport: { version_id: "v2", report: { run_id: "r1", output_version_id: "v2" } },
      reviewEnabled: false,
    });
    renderWithRouter(
      <>
        <RunChangesCard businessId="b1" runId="r1" runStatus="completed" operations={[VIBE_OP]} />
        <VersionChangesSummary businessId="b1" versionId="v2" />
        <RunVibeContent />
      </>,
    );
    expect(await screen.findByText(/After a Dry Run: delete the draft/)).toBeInTheDocument();
    await waitFor(() => expect(fetchFn.mock.calls.some(([u]) => String(u).endsWith(CONFIG_URL))).toBe(true));
    await new Promise((r) => setTimeout(r, 30));
    expect(featureCalls(fetchFn)).toEqual([]);
    expect(screen.queryByTestId("version-changes-summary")).toBeNull();
    expect(screen.queryByText(/Changes card|Accept all asked|Add rejected as feedback|Rejected change|did not ask for/)).toBeNull();
  });
});
