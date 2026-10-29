/**
 * `lib/run-defaults.ts`: what a vibe's Advanced Options show and send from
 * `getRunDefaults`. A locked field shows the base value over any edit, an
 * edit to an unlocked field stands, untouched fields take the pre-fill, a
 * Some domains vibe locks the fields the base leaves empty, and the body
 * carries blanks but never an unknown value.
 */
import { describe, expect, it } from "vitest";
import type { RunDefaultsOut } from "@/lib/api";
import {
  effectiveConventions,
  lockedPlaceholder,
  PREFILL_FIELDS,
  sourceLabel,
  UNREAD_NOTE,
  vibeConventionBody,
  type PrefillField,
} from "@/lib/run-defaults";

const FORM: Record<PrefillField, string> = {
  naming_convention: "snake_case",
  primary_key_suffix: "_id",
  schema_prefix: "",
  schema_suffix: "",
  tag_prefix: "dbx_",
  tag_suffix: "",
  table_id_type: "BIGINT",
  boolean_format: "Boolean (True/False)",
  date_format: "yyyy-MM-dd",
  timestamp_format: "yyyy-MM-dd HH:mm:ss",
  classification_levels: "",
  catalog_prefix: "",
  catalog_suffix: "",
  org_divisions: "Operations",
  housekeeping_columns: "No",
  history_tracking_columns: "No",
};

/** The A2 base ECM (agent 5.3.3): SCREAMING_CASE, Int (0/1), dd/MM/yyyy, _wt. */
const A2: RunDefaultsOut = {
  base_version_id: "v-1-ecm",
  file_read: true,
  fields: {
    naming_convention: { value: "SCREAMING_CASE", source: "base_file", locked: true, locked_scoped: true },
    primary_key_suffix: { value: "_id", source: "base_file", locked: true, locked_scoped: true },
    schema_prefix: { value: "ecm_", source: "base_file", locked: true, locked_scoped: true },
    schema_suffix: { value: "", source: "base_file", locked: true, locked_scoped: true },
    tag_prefix: { value: "dbx_", source: "base_file", locked: true, locked_scoped: true },
    tag_suffix: { value: "_wt", source: "base_file", locked: true, locked_scoped: true },
    table_id_type: { value: "BIGINT", source: "base_file", locked: true, locked_scoped: true },
    boolean_format: { value: "Int (0/1)", source: "base_file", locked: true, locked_scoped: true },
    date_format: { value: "dd/MM/yyyy", source: "base_file", locked: true, locked_scoped: true },
    timestamp_format: { value: "yyyy-MM-dd HH:mm:ss", source: "base_file", locked: true, locked_scoped: true },
    classification_levels: { value: "", source: "base_file", locked: false, locked_scoped: true },
    catalog_prefix: { value: "", source: "default", locked: false, locked_scoped: false },
    catalog_suffix: { value: "", source: "default", locked: false, locked_scoped: false },
    org_divisions: { value: "Operations", source: "default", locked: false, locked_scoped: false },
    housekeeping_columns: { value: "Yes", source: "base_run", locked: false, locked_scoped: false },
    history_tracking_columns: { value: "No", source: "default", locked: false, locked_scoped: false },
  },
};

describe("effectiveConventions", () => {
  it("locked fields show the base value whatever the user typed", () => {
    const eff = effectiveConventions(A2, { naming_convention: "camelCase" }, false, FORM);
    expect(eff.naming_convention).toMatchObject({ value: "SCREAMING_CASE", locked: true, source: "base_file" });
    expect(eff.boolean_format.value).toBe("Int (0/1)");
  });

  it("the suffixes are locked unscoped and scoped, an empty base value included", () => {
    for (const scoped of [false, true]) {
      const eff = effectiveConventions(A2, { tag_suffix: "_x", schema_suffix: "_y" }, scoped, FORM);
      expect(eff.tag_suffix).toMatchObject({ value: "_wt", locked: true, source: "base_file", baseUnset: false });
      expect(eff.schema_suffix).toMatchObject({ value: "", locked: true, source: "base_file", baseUnset: false });
    }
  });

  it("an edit to an unlocked field stands; untouched ones take the pre-fill", () => {
    const eff = effectiveConventions(A2, { catalog_suffix: "_x" }, false, FORM);
    expect(eff.catalog_suffix).toMatchObject({ value: "_x", locked: false, source: "form" });
    expect(eff.housekeeping_columns).toMatchObject({ value: "Yes", source: "base_run" });
  });

  it("an empty base value is open unscoped and locked on Some domains", () => {
    const open = effectiveConventions(A2, { classification_levels: "public=public" }, false, FORM);
    expect(open.classification_levels).toMatchObject({ value: "public=public", locked: false, baseUnset: true });
    const scoped = effectiveConventions(A2, { classification_levels: "public=public" }, true, FORM);
    expect(scoped.classification_levels).toMatchObject({ value: "", locked: true, baseUnset: true });
    expect(lockedPlaceholder(scoped.classification_levels)).toBe("Not set in the base model");
    expect(lockedPlaceholder(open.classification_levels)).toBeUndefined();
  });

  it("without defaults every field is the form's", () => {
    const eff = effectiveConventions(undefined, { tag_suffix: "_y" }, false, FORM);
    for (const f of PREFILL_FIELDS) expect(eff[f].locked).toBe(false);
    expect(eff.tag_suffix.value).toBe("_y");
    expect(eff.naming_convention.value).toBe("snake_case");
  });

  it("an unreadable base file leaves locked fields unknown", () => {
    const unread: RunDefaultsOut = {
      ...A2,
      file_read: false,
      fields: {
        ...A2.fields,
        naming_convention: { value: null, source: "unknown", locked: true, locked_scoped: true },
      },
    };
    const eff = effectiveConventions(unread, { naming_convention: "camelCase" }, false, FORM);
    expect(eff.naming_convention).toMatchObject({ value: null, locked: true, source: "unknown" });
    expect(lockedPlaceholder(eff.naming_convention)).toBe("Kept from the base model");
    expect(sourceLabel(eff.naming_convention)).toBe(UNREAD_NOTE);
  });
});

describe("vibeConventionBody", () => {
  it("sends every known field, blanks included, and no org divisions", () => {
    const body = vibeConventionBody(effectiveConventions(A2, {}, false, FORM), "schema_prefix");
    expect(body).toMatchObject({
      naming_convention: "SCREAMING_CASE",
      schema_prefix: "ecm_",
      schema_suffix: "",
      tag_suffix: "_wt",
      classification_levels: "",
    });
    expect(body).not.toHaveProperty("org_divisions");
    expect(body).not.toHaveProperty("ecm_schema_prefix");
  });

  it("Vibe ECM + MVM sends the base prefix as the ECM prefix", () => {
    const body = vibeConventionBody(effectiveConventions(A2, {}, false, FORM), "ecm_schema_prefix");
    expect(body.ecm_schema_prefix).toBe("ecm_");
    expect(body).not.toHaveProperty("schema_prefix");
  });

  it("leaves the Schema Prefix box out when told to (Vibe ECM + MVM with no pre-fill)", () => {
    const body = vibeConventionBody(effectiveConventions(undefined, {}, false, FORM), null);
    expect(body).not.toHaveProperty("schema_prefix");
    expect(body).not.toHaveProperty("ecm_schema_prefix");
    expect(body.naming_convention).toBe("snake_case");
  });

  it("leaves unknown values out and sends classification levels verbatim", () => {
    const defaults: RunDefaultsOut = {
      ...A2,
      fields: {
        ...A2.fields,
        naming_convention: { value: null, source: "unknown", locked: true, locked_scoped: true },
        classification_levels: { value: "a=b,c=d", source: "base_file", locked: true, locked_scoped: true },
      },
    };
    const body = vibeConventionBody(effectiveConventions(defaults, {}, false, FORM), "schema_prefix");
    expect(body).not.toHaveProperty("naming_convention");
    expect(body.classification_levels).toBe("a=b,c=d");
  });
});
