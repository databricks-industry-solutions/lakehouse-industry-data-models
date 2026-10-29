/**
 * FE half of the catalog capability rule (shared fixture; the BE half is
 * tests/test_app/test_uc_privileges.py against core/_uc_privileges).
 */
import { describe, expect, it } from "vitest";
import fixture from "../../../../../../tests/fixtures/catalog_capability_rule_fixture.json";
import { SINGLE_CATALOG_STYLE, capabilityFix, catalogUsable, runCreatesSchemas } from "@/lib/catalog-capability";

describe("runCreatesSchemas parity with the backend", () => {
  it("the single-catalog style is in the fixture", () => {
    expect(fixture.creates_schemas.some((c) => c.cataloging_style === SINGLE_CATALOG_STYLE)).toBe(true);
  });

  it.each(fixture.creates_schemas)("$intent dry_run=$dry_run $cataloging_style -> $expected", (c) => {
    expect(runCreatesSchemas(c.intent, c.dry_run, c.cataloging_style)).toBe(c.expected);
  });
});

describe("catalogUsable parity with the backend", () => {
  it.each(fixture.usable)(
    "create_schema=$create_schema use_metamodel=$use_metamodel creates=$creates_schemas -> $expected",
    (c) => {
      expect(
        catalogUsable({ create_schema: c.create_schema, use_metamodel: c.use_metamodel }, c.creates_schemas),
      ).toBe(c.expected);
    },
  );
});

describe("capabilityFix", () => {
  const cap = {
    name: "c",
    create_schema: false,
    use_metamodel: false,
    create_schema_fix: "GRANT CREATE SCHEMA ON CATALOG `c` TO `sp`;",
    use_metamodel_fix: "GRANT CREATE SCHEMA ON CATALOG `c` TO `sp`;\nGRANT SELECT ON SCHEMA `c`.`_metamodel` TO `sp`;",
  };

  it("lists each needed GRANT once", () => {
    expect(capabilityFix(cap, true)).toBe(
      "GRANT CREATE SCHEMA ON CATALOG `c` TO `sp`;\nGRANT SELECT ON SCHEMA `c`.`_metamodel` TO `sp`;",
    );
  });

  it("merges the privileges of grants on one securable", () => {
    const both = {
      name: "c",
      create_schema: false,
      use_metamodel: false,
      create_schema_fix: "GRANT CREATE SCHEMA, USE CATALOG ON CATALOG `c` TO `sp`;",
      use_metamodel_fix: "GRANT USE CATALOG ON CATALOG `c` TO `sp`;\nGRANT CREATE TABLE ON SCHEMA `c`.`_metamodel` TO `sp`;",
    };
    expect(capabilityFix(both, true)).toBe(
      "GRANT CREATE SCHEMA, USE CATALOG ON CATALOG `c` TO `sp`;\nGRANT CREATE TABLE ON SCHEMA `c`.`_metamodel` TO `sp`;",
    );
    expect(capabilityFix(both, false)).toBe(
      "GRANT USE CATALOG ON CATALOG `c` TO `sp`;\nGRANT CREATE TABLE ON SCHEMA `c`.`_metamodel` TO `sp`;",
    );
  });

  it("leaves out CREATE SCHEMA for a run that creates no schemas", () => {
    expect(capabilityFix({ ...cap, use_metamodel: true, use_metamodel_fix: "" }, false)).toBe("");
  });
});
