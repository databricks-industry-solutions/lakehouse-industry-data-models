import { describe, expect, it } from "vitest";
import { versionBrandLabel, versionScopeLabel } from "@/lib/version-label";

describe("versionScopeLabel", () => {
  it("returns v{version} {SCOPE} when scope is provided", () => {
    expect(versionScopeLabel(3, "mvm")).toBe("v3 MVM");
    expect(versionScopeLabel("3", "ecm")).toBe("v3 ECM");
  });

  it("returns v{version} when scope is empty string", () => {
    expect(versionScopeLabel(3, "")).toBe("v3");
  });

  it("returns v{version} when scope is null", () => {
    expect(versionScopeLabel(3, null)).toBe("v3");
  });

  it("returns v{version} when scope is undefined", () => {
    expect(versionScopeLabel(3, undefined)).toBe("v3");
    expect(versionScopeLabel(3)).toBe("v3");
  });

  it("uppercases the scope and handles string version numbers", () => {
    expect(versionScopeLabel(10, "ecm")).toBe("v10 ECM");
    expect(versionScopeLabel("42", "mvm")).toBe("v42 MVM");
  });
});

describe("versionBrandLabel", () => {
  it("labels a base version Base", () => {
    expect(versionBrandLabel({ is_base: true })).toBe("Base");
  });

  it("labels a non-base version Vibed", () => {
    expect(versionBrandLabel({ is_base: false })).toBe("Vibed");
    expect(versionBrandLabel({})).toBe("Vibed");
  });

  it("labels a version whose parent was deleted", () => {
    expect(versionBrandLabel({ is_base: false, parent_deleted: true })).toBe(
      "Vibed (parent deleted)",
    );
  });
});
