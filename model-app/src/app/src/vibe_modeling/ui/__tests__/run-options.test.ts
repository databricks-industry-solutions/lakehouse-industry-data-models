/**
 * FE half of the agent widget-options contract
 * (`tests/fixtures/agent_widget_options.json`); the BE half,
 * `tests/test_app/test_agent_widget_options.py`, pins the fixture to the
 * vendored notebook.
 */
import { describe, expect, it } from "vitest";
import fixture from "../../../../../../tests/fixtures/agent_widget_options.json";
import {
  agentTooOldForScope,
  BOOLEAN_FORMATS,
  CATALOGING_STYLES,
  DATE_FORMATS,
  isNewerTag,
  MIN_AGENT_MARKER_FOR_SCOPE,
  NAMING_CONVENTIONS,
  NO_YES,
  TABLE_ID_TYPES,
  TIMESTAMP_FORMATS,
} from "@/lib/run-options";
import { ORG_DIVISIONS_PRESETS } from "@/lib/org-divisions";

const options = fixture.options as Record<string, string[]>;
const omits = fixture.form_omits as Record<string, string[]>;

function offered(widget: string): string[] {
  const omitted = new Set(omits[widget] ?? []);
  return options[widget].filter((v) => !omitted.has(v));
}

describe("the form's option lists are the agent's", () => {
  it.each([
    ["naming_convention", NAMING_CONVENTIONS],
    ["table_id_type", TABLE_ID_TYPES],
    ["boolean_format", BOOLEAN_FORMATS],
    ["date_format", DATE_FORMATS],
    ["timestamp_format", TIMESTAMP_FORMATS],
    ["cataloging_style", CATALOGING_STYLES],
    ["org_divisions", ORG_DIVISIONS_PRESETS],
    ["housekeeping_columns", NO_YES],
    ["history_tracking_columns", NO_YES],
  ] as const)("%s", (widget, list) => {
    expect([...list]).toEqual(offered(widget));
  });

  it("leaves out only LONG", () => {
    expect(omits).toEqual({ table_id_type: ["LONG"] });
  });

  it("uses the backend's minimum agent version for scoped and Dry runs", () => {
    expect(MIN_AGENT_MARKER_FOR_SCOPE).toBe(fixture.min_agent_marker_for_scope);
  });
});

describe("isNewerTag (mirrors agent_compat.is_newer_tag)", () => {
  it.each([
    ["5.3.3", "4.9.9", true],
    ["5.3.3", "5.3.3", false],
    ["5.3.3", "5.3", true],
    ["5.3", "5.3.3", false],
    ["5.10.0", "5.9.9", true],
    ["v5.3.3", "5.3.2", true],
    ["5.3.3-rc1", "5.3.3", false],
    ["garbage", "0.0.1", false],
  ])("isNewerTag(%s, %s) is %s", (candidate, baseline, expected) => {
    expect(isNewerTag(candidate, baseline)).toBe(expected);
  });
});

describe("agentTooOldForScope", () => {
  it("names an agent older than the minimum", () => {
    expect(agentTooOldForScope("4.9.9")).toBe("4.9.9");
    expect(agentTooOldForScope("v5.3.2")).toBe("5.3.2");
  });

  it("is null for a new enough, unknown or unparseable agent", () => {
    expect(agentTooOldForScope("5.3.3")).toBeNull();
    expect(agentTooOldForScope("5.4.0")).toBeNull();
    expect(agentTooOldForScope(null)).toBeNull();
    expect(agentTooOldForScope(undefined)).toBeNull();
    expect(agentTooOldForScope("  ")).toBeNull();
    expect(agentTooOldForScope("unknown")).toBeNull();
    expect(agentTooOldForScope("garbage")).toBeNull();
  });
});
