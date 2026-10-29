/**
 * Tests for `lib/operations.ts` — the operation-metadata catalog used by the
 * run-launch confirmation dialog. The audit flagged it as untested.
 */
import { describe, it, expect } from "vitest";
import {
  OPERATION_METADATA,
  getOperationMetadata,
} from "@/lib/operations";

describe("OPERATION_METADATA", () => {
  it("includes every operation the unified pipeline depends on", () => {
    const required = [
      "new base model",
      "vibe modeling of version",
      "vibe new ecm + mvm",
      "vibe-new-ecm-mvm",
      "shrink ecm",
      "enlarge mvm",
      "install model",
      "uninstall model version",
      "generate sample data",
    ];
    for (const op of required) {
      expect(OPERATION_METADATA[op]).toBeDefined();
      expect(OPERATION_METADATA[op].label).toBeTruthy();
    }
  });

  it("gives every entry a non-empty description", () => {
    for (const meta of Object.values(OPERATION_METADATA)) {
      expect(meta.description).toBeTruthy();
    }
  });
});

describe("getOperationMetadata", () => {
  it("returns the registered metadata for a known op", () => {
    const meta = getOperationMetadata("new base model");
    expect(meta.label).toBe("New Base Model");
    expect(meta.description).toMatch(/ECM/);
  });

  it("returns a generic fallback for unknown ops so the dialog still renders", () => {
    const meta = getOperationMetadata("totally made up");
    expect(meta.label).toBe("totally made up");
    expect(meta.description).toMatch(/databricks compute/i);
  });

  it("does not mutate the registered metadata when a fallback is returned", () => {
    const before = OPERATION_METADATA["install model"];
    getOperationMetadata("brand new op");
    expect(OPERATION_METADATA["install model"]).toBe(before);
  });
});
