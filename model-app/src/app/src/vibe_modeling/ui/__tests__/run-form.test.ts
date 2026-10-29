/**
 * Unit tests for the New Run form blockers helper.
 *
 * The drift bug (the model-versioning work, Phase 5): two booleans were derived inline in
 * `runs.new.tsx` and re-tested in the Submit `disabled` prop, with copy-paste
 * comments. Adding a third gate meant remembering both call sites; risking a
 * disabled button whose inline reason banner didn't actually trigger.
 */
import { describe, expect, it } from "vitest";
import {
  baseDeepLinkNotice,
  baseVersionCandidates,
  baseVersionLabel,
  deriveRunFormBlockers,
  runDropsOwnSchemas,
  type BaseVersionRow,
  type RunFormState,
} from "../lib/run-form";

const baseState: RunFormState = {
  isBase: false,
  isVibe: false,
  contextMode: "text",
  businessContextText: "",
  businessContextPath: "",
  inputCount: 0,
};

describe("deriveRunFormBlockers", () => {
  it("returns no blockers for an irrelevant intent (neither base nor vibe)", () => {
    const out = deriveRunFormBlockers(baseState);
    expect(out).toEqual({
      baseContextMissing: false,
      vibeContentMissing: false,
      hasBlocker: false,
    });
  });

  describe("new-base-model", () => {
    it("blocks when text mode + empty text", () => {
      const out = deriveRunFormBlockers({ ...baseState, isBase: true });
      expect(out.baseContextMissing).toBe(true);
      expect(out.hasBlocker).toBe(true);
    });

    it("treats whitespace-only text as empty", () => {
      const out = deriveRunFormBlockers({
        ...baseState,
        isBase: true,
        businessContextText: "   \n  ",
      });
      expect(out.baseContextMissing).toBe(true);
    });

    it("clears when text mode has non-empty content", () => {
      const out = deriveRunFormBlockers({
        ...baseState,
        isBase: true,
        businessContextText: "We sell widgets",
      });
      expect(out.baseContextMissing).toBe(false);
    });

    it("blocks when path mode + empty path", () => {
      const out = deriveRunFormBlockers({
        ...baseState,
        isBase: true,
        contextMode: "path",
      });
      expect(out.baseContextMissing).toBe(true);
    });

    it("clears when path mode has a path even if text is empty", () => {
      const out = deriveRunFormBlockers({
        ...baseState,
        isBase: true,
        contextMode: "path",
        businessContextPath: "/Volumes/.../context.md",
      });
      expect(out.baseContextMissing).toBe(false);
    });
  });

  describe("vibe runs", () => {
    it("blocks when no Vibe Inputs are selected", () => {
      const out = deriveRunFormBlockers({ ...baseState, isVibe: true });
      expect(out.vibeContentMissing).toBe(true);
      expect(out.hasBlocker).toBe(true);
    });

    it("clears when at least one Vibe Input is selected", () => {
      const out = deriveRunFormBlockers({
        ...baseState,
        isVibe: true,
        inputCount: 1,
      });
      expect(out.vibeContentMissing).toBe(false);
    });
  });
});

function ver(over: Partial<BaseVersionRow> & { id: string; version: number }): BaseVersionRow {
  return { scope: "mvm", status: "completed", replaced_at: null, replaced_by_version_id: null, ...over };
}

describe("baseVersionCandidates", () => {
  it("keeps completed and superseded versions, in order, and drops drafts, failed and generating", () => {
    const rows = [
      ver({ id: "a", version: 5, status: "generating" }),
      ver({ id: "b", version: 4, status: "draft" }),
      ver({ id: "c", version: 3, status: "failed" }),
      ver({ id: "d", version: 2 }),
      ver({ id: "e", version: 1, status: "superseded" }),
    ];
    expect(baseVersionCandidates(rows).map((v) => v.id)).toEqual(["d", "e"]);
  });
});

describe("baseVersionLabel", () => {
  const rows = [
    ver({ id: "v2", version: 2 }),
    ver({ id: "v1", version: 1, status: "superseded", replaced_at: "2026-04-22T12:00:00Z", replaced_by_version_id: "v2" }),
  ];

  it("says (vibed) only when the brand is known to be vibed", () => {
    expect(baseVersionLabel(rows[0], rows, false)).toBe("v2 MVM (vibed)");
    expect(baseVersionLabel(rows[0], rows, true)).toBe("v2 MVM");
    expect(baseVersionLabel(rows[0], rows, undefined)).toBe("v2 MVM");
  });

  it("says (superseded) from the status and the explorer's Replaced by only for a replaced version", () => {
    expect(baseVersionLabel(rows[1], rows, true)).toBe("v1 MVM (superseded) (Replaced by v2)");
    expect(baseVersionLabel(rows[1], [rows[1]], true)).toBe("v1 MVM (superseded) (Replaced)");
    const unreplaced = ver({ id: "v1", version: 1, status: "superseded", replaced_by_version_id: "v2" });
    expect(baseVersionLabel(unreplaced, rows, true)).toBe("v1 MVM (superseded)");
  });

  it("reads an empty scope as MVM like the rest of the form", () => {
    expect(baseVersionLabel(ver({ id: "x", version: 3, scope: "" }), [], true)).toBe("v3 MVM");
  });
});

describe("baseDeepLinkNotice", () => {
  const all = [
    ver({ id: "d3", version: 3, status: "draft" }),
    ver({ id: "e2", version: 2, scope: "ecm" }),
    ver({ id: "m2", version: 2 }),
    ver({ id: "m1", version: 1, status: "failed" }),
  ];
  const eligible = [all[1], all[2]];
  const call = (over: Partial<Parameters<typeof baseDeepLinkNotice>[0]>) =>
    baseDeepLinkNotice({
      sourceVersion: 3,
      sourceScope: "mvm",
      versions: all,
      eligible,
      selected: all[2],
      needsEcm: false,
      ...over,
    });

  it("is silent without a linked version or when the linked version is offered", () => {
    expect(call({ sourceVersion: undefined })).toBeNull();
    expect(call({ sourceVersion: 2, sourceScope: "ecm" })).toBeNull();
    expect(call({ sourceVersion: 2, sourceScope: undefined })).toBeNull();
  });

  it.each([
    [{ sourceVersion: 3 }, "The link points to v3 MVM, which is a Dry Run draft. v2 MVM is selected instead."],
    [{ sourceVersion: 1 }, "The link points to v1 MVM, which failed. v2 MVM is selected instead."],
    [{ sourceVersion: 7 }, "The link points to v7 MVM, which does not exist. v2 MVM is selected instead."],
    [{ sourceVersion: 7, sourceScope: undefined }, "The link points to v7, which does not exist. v2 MVM is selected instead."],
    [{ sourceVersion: 2, needsEcm: true, eligible: [all[1]], selected: all[1] }, "The link points to v2 MVM, which is not an ECM; this run needs an ECM as its base. v2 ECM is selected instead."],
    [{ selected: undefined }, "The link points to v3 MVM, which is a Dry Run draft. No other version is available to select."],
  ])("explains a version the picker does not offer (%j)", (over, expected) => {
    expect(call(over)).toBe(expected);
  });
});

describe("runDropsOwnSchemas", () => {
  const s = { isVibeIterate: true, isVibeCombined: false, dryRun: false, scoped: false };

  it("is true for an unscoped Vibe Modeling Full Run and for Vibe ECM + MVM", () => {
    expect(runDropsOwnSchemas(s)).toBe(true);
    expect(runDropsOwnSchemas({ ...s, isVibeIterate: false, isVibeCombined: true })).toBe(true);
  });

  it("is false on a Dry Run, on a Some domains run and for New Base Model", () => {
    expect(runDropsOwnSchemas({ ...s, dryRun: true })).toBe(false);
    expect(runDropsOwnSchemas({ ...s, scoped: true })).toBe(false);
    expect(runDropsOwnSchemas({ ...s, isVibeIterate: false })).toBe(false);
  });
});
