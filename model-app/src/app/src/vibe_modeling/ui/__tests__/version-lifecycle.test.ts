/**
 * Lifecycle labels of a model version (design §1 UI, add §6.1): badges,
 * install action, default install catalog, delete rules, and the versions a
 * B10 blocker names for its "Delete v4 and v5" action.
 */
import { describe, expect, it } from "vitest";
import {
  blockerVersionsToDelete,
  defaultInstallCatalog,
  deleteState,
  installActionLabel,
  isModelVersion,
  replacedHeader,
  versionLifecycleBadges,
  versionsPhrase,
} from "@/lib/version-lifecycle";
import { makeModelVersion } from "./helpers/model-version";

const v3 = makeModelVersion({ id: "mv-3", version: 3, scope: "ecm" });
const draft = makeModelVersion({ id: "mv-4", version: 4, scope: "ecm", status: "draft", dry_run: true, draft_state: "ready", is_head: false });
const olderDraft = makeModelVersion({ ...draft, id: "mv-6", version: 6, draft_state: "older_base" });
const replaced = makeModelVersion({
  id: "mv-5", version: 5, scope: "ecm", status: "superseded", is_head: false,
  replaced_at: "2026-10-21T10:00:00Z", replaced_by_version_id: "mv-3",
});
const promoted = makeModelVersion({ id: "mv-7", version: 7, scope: "ecm", dry_run: true, promoted_at: "2026-10-22T00:00:00Z" });
const all = [v3, draft, olderDraft, replaced, promoted];

describe("versionLifecycleBadges", () => {
  it("labels drafts, replaced and promoted versions", () => {
    expect(versionLifecycleBadges(draft, all).map((b) => b.label)).toEqual(["Dry Run"]);
    expect(versionLifecycleBadges(olderDraft, all).map((b) => b.label)).toEqual(["Dry Run (older base)"]);
    expect(versionLifecycleBadges(replaced, all)).toEqual([{ label: "Replaced by v3", tone: "replaced" }]);
    expect(versionLifecycleBadges(promoted, all)).toEqual([{ label: "from Dry Run", tone: "muted" }]);
    expect(versionLifecycleBadges(v3, all)).toEqual([]);
  });

  it("keeps the replaced flag when the replacer is gone", () => {
    expect(versionLifecycleBadges(replaced, [replaced]).map((b) => b.label)).toEqual(["Replaced"]);
    expect(replacedHeader(replaced, [replaced])).toMatch(/^Replaced on /);
    expect(replacedHeader(replaced, all)).toMatch(/^Replaced by v3 on /);
  });
});

describe("installActionLabel", () => {
  it("names the action for each state", () => {
    expect(installActionLabel(draft)).toBe("Install this Dry Run");
    expect(installActionLabel(v3)).toBe("Install");
    expect(installActionLabel({ ...v3, deployment_status: "deployed", uc_catalog: "x" })).toBe("Re-install");
    expect(installActionLabel(replaced)).toBe("Make this version current");
    expect(installActionLabel({ ...v3, status: "superseded" })).toBe("Make this version current");
    expect(installActionLabel({ ...v3, status: "failed" })).toBeNull();
  });
});

describe("defaultInstallCatalog (B3)", () => {
  it("prefers the install catalog, then the files catalog", () => {
    expect(defaultInstallCatalog({ ...v3, deployment_status: "deployed", uc_catalog: "inst", files_catalog: "files" })).toBe("inst");
    expect(defaultInstallCatalog({ ...v3, uc_catalog: "", files_catalog: "files" })).toBe("files");
    expect(defaultInstallCatalog({ ...v3, uc_catalog: "", files_catalog: null })).toBe("");
  });
});

describe("deleteState (add §6.1)", () => {
  it("refuses an installed version with the uninstall hint", () => {
    const s = deleteState({ ...v3, deployment_status: "deployed", uc_catalog: "cat_x" }, [v3, draft, replaced]);
    expect(s).toMatchObject({ allowed: false, installed: true });
    expect(s.reason).toBe("v3 ECM is installed in cat_x. Uninstall it first, then delete it.");
  });

  it("an installed version with newer ones names both steps, since uninstalling does not lift the newer rule", () => {
    const v1 = makeModelVersion({
      id: "mv-1", version: 1, scope: "ecm", status: "superseded", is_head: false,
      deployment_status: "deployed", uc_catalog: "cat_x",
    });
    const s = deleteState(v1, [v1, v3, replaced, draft]);
    expect(s).toMatchObject({ allowed: false, installed: true, newerVersions: [3] });
    expect(s.reason).toBe(
      "v1 ECM is installed in cat_x. Uninstall it first, then delete the newer versions (v3), then delete it.",
    );
  });

  it("refuses a superseded version in the middle and names the newer ones", () => {
    const v1 = makeModelVersion({ id: "mv-1", version: 1, scope: "ecm", status: "superseded", is_head: false });
    const s = deleteState(v1, [v1, v3, replaced, draft]);
    expect(s.allowed).toBe(false);
    expect(s.reason).toBe("Delete the newer versions first (v3).");
  });

  it("refuses a legacy second completed row below a newer live version, like delete_refusal", () => {
    const old = makeModelVersion({ id: "mv-2", version: 2, scope: "ecm", status: "completed", is_head: false });
    expect(deleteState(old, [old, v3]).reason).toBe("Delete the newer versions first (v3).");
  });

  it("counts any status=draft row as a draft, like is_draft", () => {
    const legacy = makeModelVersion({ id: "mv-9", version: 9, scope: "ecm", status: "draft", dry_run: false, draft_state: null });
    expect(deleteState(legacy, all).label).toBe("Delete draft");
  });

  it("allows drafts and replaced versions with their labels", () => {
    expect(deleteState(draft, all)).toEqual({ label: "Delete draft", allowed: true });
    expect(deleteState(replaced, all)).toEqual({ label: "Delete replaced version", allowed: true });
    expect(deleteState(v3, [v3, draft, replaced])).toEqual({ label: "Delete this version", allowed: true });
  });
});

describe("blockerVersionsToDelete (B10, IssueOut.versions)", () => {
  it("returns the named replaced versions and drafts of the scope, newest first", () => {
    expect(blockerVersionsToDelete([4, 5], all, "ecm").map((v) => v.version)).toEqual([5, 4]);
  });

  it("returns none for another scope or no named versions", () => {
    expect(blockerVersionsToDelete([4, 5], all, "mvm")).toEqual([]);
    expect(blockerVersionsToDelete([], all, "ecm")).toEqual([]);
  });

  it("never returns a version the blocker did not name, nor a live one it named", () => {
    expect(blockerVersionsToDelete([5], all, "ecm").map((v) => v.version)).toEqual([5]);
    expect(blockerVersionsToDelete([3], all, "ecm")).toEqual([]);
  });
});

describe("versionsPhrase", () => {
  it("joins like the server", () => {
    expect(versionsPhrase([5])).toBe("v5");
    expect(versionsPhrase([5, 4])).toBe("v4 and v5");
    expect(versionsPhrase([3, 4, 5])).toBe("v3, v4 and v5");
  });
});

describe("isModelVersion", () => {
  it("is true for completed and superseded versions only", () => {
    const status = (st: string) => makeModelVersion({ id: `s-${st}`, version: 1, status: st as never });
    expect(["completed", "superseded"].every((st) => isModelVersion(status(st)))).toBe(true);
    expect(["draft", "generating", "failed"].some((st) => isModelVersion(status(st)))).toBe(false);
  });
});
