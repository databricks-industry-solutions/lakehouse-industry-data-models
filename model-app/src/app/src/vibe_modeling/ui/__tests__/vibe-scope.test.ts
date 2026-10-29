import { describe, expect, it } from "vitest";
import {
  derivedRunMode,
  feedbackScopeDomains,
  feedbackScopePrefill,
  matchScopeDomains,
  modelWideExcludedCount,
  modelWideScopeNote,
  parseScopeFromParam,
  scopedNeedsLatestNote,
  scopePrefillBanner,
  parseRunModeParam,
  parseRunVibeScope,
  parseScopeDomainsParam,
  scopeKey,
  scopeLabel,
  stripVibeMarkers,
  vibeScopeRequestFields,
} from "@/lib/vibe-scope";

describe("scopeKey (parity with backend core/_vibe_scope.scope_key)", () => {
  it("lowercases and keeps only letters and digits", () => {
    expect(scopeKey("Customer Service")).toBe("customerservice");
    expect(scopeKey("meter_to_cash")).toBe("metertocash");
    expect(scopeKey("Meter-To-Cash")).toBe("metertocash");
    expect(scopeKey("Q2 2026!")).toBe("q22026");
    expect(scopeKey("")).toBe("");
  });

  it("does not equate a prefix with the longer name", () => {
    expect(scopeKey("customer")).not.toBe(scopeKey("customer_service"));
  });
});

describe("deep-link parsing", () => {
  it("splits, trims and dedupes scopeDomains by scopeKey", () => {
    expect(parseScopeDomainsParam("meter_to_cash")).toEqual(["meter_to_cash"]);
    expect(parseScopeDomainsParam(" meter_to_cash , billing,, Meter To Cash ")).toEqual([
      "meter_to_cash",
      "billing",
    ]);
    expect(parseScopeDomainsParam(undefined)).toEqual([]);
    expect(parseScopeDomainsParam("")).toEqual([]);
    expect(parseScopeDomainsParam([" billing", "", "Billing", "meter_to_cash"])).toEqual([
      "billing",
      "meter_to_cash",
    ]);
  });

  it("accepts only dry/full for runMode", () => {
    expect(parseRunModeParam("dry")).toBe("dry");
    expect(parseRunModeParam("FULL")).toBe("full");
    expect(parseRunModeParam("other")).toBeUndefined();
    expect(parseRunModeParam(undefined)).toBeUndefined();
  });
});

describe("matchScopeDomains", () => {
  it("returns canonical names for matches and keeps unknown names", () => {
    expect(
      matchScopeDomains(["Meter To Cash", "meter2cash", "billing"], ["meter_to_cash", "Billing"]),
    ).toEqual({ matched: ["meter_to_cash", "Billing"], unknown: ["meter2cash"] });
  });

  it("dedupes matches that normalize to the same domain", () => {
    expect(matchScopeDomains(["meter_to_cash", "MeterToCash"], ["meter_to_cash"])).toEqual({
      matched: ["meter_to_cash"],
      unknown: [],
    });
  });
});

describe("stripVibeMarkers (D16)", () => {
  it("removes a trailing marker and the space before it", () => {
    expect(
      stripVibeMarkers("- (high) [sales.order] Add a column <!-- vi:abc-1 target=sales.order -->"),
    ).toBe("- (high) [sales.order] Add a column");
  });

  it("removes a standalone marker line entirely", () => {
    const text = ["## Domain: sales", "<!-- vi:abc-2 target=sales -->", "> Priority: high", "Body"].join(
      "\n",
    );
    expect(stripVibeMarkers(text)).toBe(["## Domain: sales", "> Priority: high", "Body"].join("\n"));
  });

  it("leaves text without markers unchanged, including other HTML comments", () => {
    const text = "Line one  \n<!-- keep me -->\nLine two";
    expect(stripVibeMarkers(text)).toBe(text);
  });

  it("does not let an unterminated `<!-- vi:` swallow text up to a later marker", () => {
    const line = "User wrote <!-- vi: oops and more text <!-- vi:abc-1 target=sales.order -->";
    expect(stripVibeMarkers(line)).toBe("User wrote <!-- vi: oops and more text");
    const line2 = "Note <!-- vi:x target=broken then <!-- vi:abc-1 target=sales -->";
    expect(stripVibeMarkers(line2)).toBe("Note <!-- vi:x target=broken then");
  });

  it("keeps lines with a malformed `<!-- vi:` byte-for-byte, trailing spaces included", () => {
    const text = "Keep <!-- vi: not a marker -->  \nNext line";
    expect(stripVibeMarkers(text)).toBe(text);
    const unterminated = "Trailing <!-- vi:abc target=x  ";
    expect(stripVibeMarkers(unterminated)).toBe(unterminated);
  });

  it("handles empty input", () => {
    expect(stripVibeMarkers("")).toBe("");
    expect(stripVibeMarkers(null)).toBe("");
    expect(stripVibeMarkers(undefined)).toBe("");
  });
});

describe("derivedRunMode and vibeScopeRequestFields", () => {
  it("defaults to Dry Run", () => {
    expect(derivedRunMode()).toBe("dry");
  });

  it("sends nothing for an unscoped Full Run, only dry_run for an unscoped Dry Run", () => {
    expect(vibeScopeRequestFields("all_domains", ["ignored"], "full")).toEqual({});
    expect(vibeScopeRequestFields("all_domains", [], "dry")).toEqual({ dry_run: true });
  });

  it("sends all three fields for a scoped run", () => {
    expect(vibeScopeRequestFields("some_domains", ["meter_to_cash"], "full")).toEqual({
      vibe_scope: "some_domains",
      vibe_scope_domains: ["meter_to_cash"],
      dry_run: false,
    });
  });
});

describe("scopeLabel and parseRunVibeScope", () => {
  it("formats the dialog scope label", () => {
    expect(scopeLabel("all_domains", ["x"])).toBe("All domains");
    expect(scopeLabel("some_domains", ["meter_to_cash"])).toBe("Some domains: meter_to_cash");
    expect(scopeLabel("some_domains", [])).toBe("Some domains");
  });

  it("reads Dry Run and scope from parameters_json", () => {
    expect(
      parseRunVibeScope({
        vibe_scope: "some_domains",
        vibe_scope_domains: ["meter_to_cash"],
        dry_run: true,
      }),
    ).toEqual({ dryRun: true, scopeDomains: ["meter_to_cash"] });
    expect(parseRunVibeScope({ vibe_scope: "all_domains", dry_run: false })).toEqual({
      dryRun: false,
      scopeDomains: null,
    });
    expect(parseRunVibeScope({})).toEqual({ dryRun: false, scopeDomains: null });
  });
});

describe("feedback scope pre-fill", () => {
  it("parses scopeFrom: only feedback counts", () => {
    expect(parseScopeFromParam("feedback")).toBe("feedback");
    expect(parseScopeFromParam(" Feedback ")).toBe("feedback");
    expect(parseScopeFromParam("other")).toBeUndefined();
    expect(parseScopeFromParam(undefined)).toBeUndefined();
    expect(parseScopeFromParam(["feedback"])).toBeUndefined();
  });

  it("lists the distinct domains of the selected ids, in selection order", () => {
    const map = { a: "billing", b: null, c: "Metering", d: "BILLING", e: undefined, f: "Other" };
    expect(feedbackScopeDomains(map, ["c", "a", "b", "d", "e", "missing"])).toEqual([
      "Metering",
      "billing",
    ]);
    expect(feedbackScopeDomains(undefined, ["a"])).toEqual([]);
    expect(feedbackScopeDomains(map, [])).toEqual([]);
  });

  const base = ["Billing", "Metering", "Meter To Cash"];

  it("opens Some domains with the base's spelling when the feedback covers some", () => {
    expect(feedbackScopePrefill(["billing", "meter_to_cash"], base)).toEqual([
      "Billing",
      "Meter To Cash",
    ]);
  });

  it("opens All domains when every domain is covered, none is named or none exists", () => {
    expect(feedbackScopePrefill(["metering", "billing", "metertocash"], base)).toEqual([]);
    expect(feedbackScopePrefill([], base)).toEqual([]);
    expect(feedbackScopePrefill(["retired"], base)).toEqual([]);
    expect(feedbackScopePrefill(["billing"], [])).toEqual([]);
  });

  it("keeps the matching names when one is unknown to the base", () => {
    expect(feedbackScopePrefill(["billing", "retired"], base)).toEqual(["Billing"]);
  });

  it("a one-domain base is always covered", () => {
    expect(feedbackScopePrefill(["billing"], ["Billing"])).toEqual([]);
  });

  it("counts the items a scoped compile leaves out as model-wide", () => {
    expect(
      modelWideExcludedCount({
        a: "model_wide_in_scoped_run",
        b: "out_of_scope",
        c: "model_wide_in_scoped_run",
      }),
    ).toBe(2);
    expect(modelWideExcludedCount(undefined)).toBe(0);
  });

  it("words the banner and notes", () => {
    expect(scopePrefillBanner(5, ["billing", "metering"])).toBe(
      "Scope pre-filled from your 5 selected feedback items: billing, metering. Change it below.",
    );
    expect(scopePrefillBanner(1, ["billing"])).toBe(
      "Scope pre-filled from your 1 selected feedback item: billing. Change it below.",
    );
    expect(modelWideScopeNote(2)).toBe(
      "2 selected items are model-wide and are not sent in a scoped run. Switch to All domains to include them.",
    );
    expect(modelWideScopeNote(1)).toBe(
      "1 selected item is model-wide and is not sent in a scoped run. Switch to All domains to include it.",
    );
    expect(scopedNeedsLatestNote("v4")).toBe("Scoped runs need the latest version (v4).");
  });
});
