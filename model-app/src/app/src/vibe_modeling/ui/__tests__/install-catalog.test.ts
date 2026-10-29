/**
 * FE half of the install-target catalog contract: installTargetCatalog gives the
 * fixture's answer for every case (the BE half is
 * tests/test_app/test_install_target_catalog_parity.py).
 */
import { describe, expect, it } from "vitest";
import fixture from "../../../../../../tests/fixtures/install_target_catalog_fixture.json";
import { installTargetCatalog } from "@/lib/install-catalog";

describe("installTargetCatalog parity with the backend resolver", () => {
  it.each(fixture.cases)("$name", ({ version, expected }) => {
    expect(
      installTargetCatalog(version as Parameters<typeof installTargetCatalog>[0]),
    ).toBe(expected);
  });

  it("is empty without a version", () => {
    expect(installTargetCatalog(undefined)).toBe("");
  });
});
