/**
 * `apiErrorMessage` helper tests.
 *
 * The helper extracts a useful, user-facing message from an `ApiError`
 * thrown by the auto-generated API client. The default `err.message`
 * is just `"HTTP 422: Unprocessable Entity"`; we want the FastAPI
 * detail string or the Pydantic msg(s) instead.
 */
import { describe, expect, it } from "vitest";
import {
  apiErrorMessage,
  parse409,
  parseAdminHelp,
  parseConfigMissing,
  parseNeedsConfirmation,
  parsePlainConflict,
  parseSettingRefused,
  parseSettingsError,
} from "@/lib/api-error";
import { ApiError } from "@/lib/api";

interface SampleConflict {
  error: "industry_already_exists";
  dependent_business_count?: number;
}

describe("parse409", () => {
  it("unwraps a conflict body nested under detail", () => {
    const err = new ApiError(409, "Conflict", {
      detail: { error: "industry_already_exists", dependent_business_count: 3 },
    });
    const parsed = parse409<SampleConflict>(err, "industry_already_exists");
    expect(parsed?.dependent_business_count).toBe(3);
  });

  it("unwraps a conflict body passed directly (no detail wrapper)", () => {
    const err = new ApiError(409, "Conflict", {
      error: "business_already_exists",
      business_id: "biz-1",
    });
    const parsed = parse409<{ error: string; business_id: string }>(
      err,
      "business_already_exists",
    );
    expect(parsed?.business_id).toBe("biz-1");
  });

  it("returns null for non-409, mismatched error literal, or non-ApiError", () => {
    expect(
      parse409(new ApiError(500, "boom", { error: "x" }), "x"),
    ).toBeNull();
    expect(
      parse409(
        new ApiError(409, "Conflict", { detail: { error: "other" } }),
        "industry_already_exists",
      ),
    ).toBeNull();
    expect(parse409(new Error("nope"), "x")).toBeNull();
    expect(parse409(new ApiError(409, "Conflict", null), "x")).toBeNull();
  });
});

describe("apiErrorMessage", () => {
  it("returns FastAPI detail string when provided", () => {
    const err = new ApiError(400, "Bad Request", { detail: "catalog already in use" });
    expect(apiErrorMessage(err)).toBe("catalog already in use");
  });

  it("joins Pydantic validation msgs from a detail array", () => {
    const err = new ApiError(422, "Unprocessable Entity", {
      detail: [
        { type: "string_too_short", loc: ["body", "name"], msg: "String should have at least 1 character" },
        { type: "missing", loc: ["body", "industry_alignment"], msg: "Field required" },
      ],
    });
    expect(apiErrorMessage(err)).toBe(
      "String should have at least 1 character; Field required",
    );
  });

  it("caps joined Pydantic msgs at 3 entries to keep toast compact", () => {
    const err = new ApiError(422, "Unprocessable Entity", {
      detail: [
        { msg: "first" },
        { msg: "second" },
        { msg: "third" },
        { msg: "fourth" },
      ],
    });
    expect(apiErrorMessage(err)).toBe("first; second; third");
  });

  it("falls back to the HTTP-level message when body has no detail", () => {
    const err = new ApiError(500, "Internal Server Error", null);
    expect(apiErrorMessage(err)).toBe("HTTP 500: Internal Server Error");
  });

  it("falls back to err.message for non-ApiError Error instances", () => {
    const err = new Error("network unreachable");
    expect(apiErrorMessage(err)).toBe("network unreachable");
  });

  it("falls back to the supplied default for non-Error throws", () => {
    expect(apiErrorMessage("not an error", "Save failed")).toBe("Save failed");
    expect(apiErrorMessage(null, "Save failed")).toBe("Save failed");
    expect(apiErrorMessage(undefined, "Save failed")).toBe("Save failed");
  });

  it("ignores empty-string detail and falls back", () => {
    const err = new ApiError(400, "Bad Request", { detail: "" });
    expect(apiErrorMessage(err)).toBe("HTTP 400: Bad Request");
  });

  it("ignores Pydantic array entries without a string msg", () => {
    const err = new ApiError(422, "Unprocessable Entity", {
      detail: [{ type: "missing", loc: ["body"] }],
    });
    expect(apiErrorMessage(err)).toBe("HTTP 422: Unprocessable Entity");
  });

  it("prefers detail.message for an object-shaped 409 (sector-in-use)", () => {
    const err = new ApiError(409, "Conflict", {
      detail: { message: "Sector in use by 3 businesses", error: "sector_in_use" },
    });
    expect(apiErrorMessage(err)).toBe("Sector in use by 3 businesses");
  });

  it("falls back to detail.error when there is no message", () => {
    const err = new ApiError(409, "Conflict", {
      detail: { error: "industry_already_exists" },
    });
    expect(apiErrorMessage(err)).toBe("industry_already_exists");
  });

  it("prefers message over error on an unwrapped (non-detail) object body", () => {
    const err = new ApiError(409, "Conflict", {
      message: "Version delete blocked",
      error: "version_in_use",
    });
    expect(apiErrorMessage(err)).toBe("Version delete blocked");
  });
});

describe("parseAdminHelp", () => {
  it("reads every field of an admin_help detail", () => {
    const err = new ApiError(502, "Bad Gateway", {
      detail: {
        error: "admin_help", message: "Hand-off failed: PERMISSION_DENIED", job_url: "https://ws/jobs/7",
        run_url: "https://ws/jobs/7/runs/9", runs_path: "/Volumes/c/_metamodel/assess_runs/b/d",
        job_reader: "reader-app-id",
      },
    });
    expect(parseAdminHelp(err)).toEqual({
      message: "Hand-off failed: PERMISSION_DENIED", job_url: "https://ws/jobs/7",
      run_url: "https://ws/jobs/7/runs/9", runs_path: "/Volumes/c/_metamodel/assess_runs/b/d",
      job_reader: "reader-app-id",
    });
  });

  it("unwraps a body passed directly (no detail wrapper), at any status", () => {
    const err = new ApiError(500, "Internal Server Error", { error: "admin_help", message: "Couldn't add" });
    expect(parseAdminHelp(err)).toEqual({ message: "Couldn't add" });
  });

  it("carries the not_ready reasons of a launch 409", () => {
    const err = new ApiError(409, "Conflict", {
      detail: { error: "admin_help", message: "not ready", job_url: "https://ws/jobs/7", not_ready: ["No reader service principal", ""] },
    });
    expect(parseAdminHelp(err)?.not_ready).toEqual(["No reader service principal"]);
  });

  it("drops empty links", () => {
    const err = new ApiError(409, "Conflict", { detail: { error: "admin_help", message: "m", job_url: "", run_url: "  " } });
    const help = parseAdminHelp(err)!;
    expect(help.job_url).toBeUndefined();
    expect(help.run_url).toBeUndefined();
  });

  it("falls back to the HTTP message, not the discriminator, for an empty message", () => {
    const err = new ApiError(502, "Bad Gateway", { detail: { error: "admin_help", message: "" } });
    expect(parseAdminHelp(err)?.message).toBe("HTTP 502: Bad Gateway");
  });

  it("returns null for other errors", () => {
    expect(parseAdminHelp(new ApiError(422, "Unprocessable", { detail: "bad reader" }))).toBeNull();
    expect(parseAdminHelp(new ApiError(422, "Unprocessable", { detail: { error: "config_missing", missing: [] } }))).toBeNull();
    expect(parseAdminHelp(new Error("boom"))).toBeNull();
    expect(parseAdminHelp(undefined)).toBeNull();
  });
});

describe("parsePlainConflict", () => {
  const race = new ApiError(409, "Conflict", {
    detail: { message: "Another request changed this next vibe's feedback link at the same time; try again." },
  });

  it("reads a plain {message} 409 without an error key", () => {
    expect(parsePlainConflict(race)).toBe("Another request changed this next vibe's feedback link at the same time; try again.");
  });

  it("is not admin help", () => {
    expect(parseAdminHelp(race)).toBeNull();
  });

  it("returns null for admin_help, other statuses and empty messages", () => {
    expect(parsePlainConflict(new ApiError(409, "Conflict", { detail: { error: "admin_help", message: "m" } }))).toBeNull();
    expect(parsePlainConflict(new ApiError(500, "Error", { detail: { message: "m" } }))).toBeNull();
    expect(parsePlainConflict(new ApiError(409, "Conflict", { detail: { message: " " } }))).toBeNull();
    expect(parsePlainConflict(new Error("m"))).toBeNull();
  });
});

describe("parseNeedsConfirmation", () => {
  const issues = [
    { field_path: "version_id", step_index: -1, severity: "confirm", message: "v5 is the latest ECM version...", subject: "install_over_newer:mv-5" },
    { field_path: "catalog", step_index: -1, severity: "confirm", message: "Catalog x holds v5...", subject: "install_replaces_in_catalog:mv-5" },
  ];
  const err = new ApiError(422, "Unprocessable", {
    detail: { error: "needs_confirmation", issues, message: "Confirm what this run changes before it starts: ".padEnd(500, ".") },
  });

  it("reads every issue with its subject and message (not the cut message)", () => {
    const parsed = parseNeedsConfirmation(err);
    expect(parsed?.issues.map((i) => i.subject)).toEqual([
      "install_over_newer:mv-5",
      "install_replaces_in_catalog:mv-5",
    ]);
    expect(parsed?.issues[1].message).toBe("Catalog x holds v5...");
  });

  it("is distinct from config_missing", () => {
    expect(parseConfigMissing(err)).toBeNull();
    const missing = new ApiError(422, "Unprocessable", { detail: { error: "config_missing", missing: [], message: "m" } });
    expect(parseNeedsConfirmation(missing)).toBeNull();
  });

  it("drops issues without a subject and ignores other errors", () => {
    const partial = new ApiError(422, "Unprocessable", {
      detail: { error: "needs_confirmation", issues: [{ message: "x", subject: null }, issues[0]] },
    });
    expect(parseNeedsConfirmation(partial)?.issues).toHaveLength(1);
    expect(parseNeedsConfirmation(new Error("x"))).toBeNull();
    expect(parseNeedsConfirmation(new ApiError(422, "U", { detail: "plain" }))).toBeNull();
  });
});

describe("parseSettingRefused / parseSettingsError", () => {
  const refused = (error: string, key: string, extra: Record<string, unknown> = {}) =>
    new ApiError(400, "Bad Request", { detail: { error, key, message: "Refused.", ...extra } });

  it("reads a model_service_refused with its key and test-call status", () => {
    expect(parseSettingRefused(refused("model_service_refused", "taxonomy_llm", { status: "denied" }))).toEqual({
      error: "model_service_refused", key: "taxonomy_llm", message: "Refused.", status: "denied",
    });
  });

  it("reads a setting_refused with its key", () => {
    expect(parseSettingRefused(refused("setting_refused", "warehouse_id"))).toEqual({
      error: "setting_refused", key: "warehouse_id", message: "Refused.",
    });
  });

  it("is null for other errors and other discriminators", () => {
    expect(parseSettingRefused(new Error("x"))).toBeNull();
    expect(parseSettingRefused(new ApiError(409, "Conflict", { detail: { error: "admin_help", message: "m" } }))).toBeNull();
    expect(parseSettingsError(new ApiError(401, "Unauthorized", { detail: { error: "identity_missing", message: "m" } }))).toBeNull();
  });

  it("gives every settings error its message and Settings links", () => {
    expect(parseSettingsError(refused("setting_refused", "reader_application_id"))).toEqual({
      message: "Refused.",
      missing: [{ key: "reader_application_id", label: "Assessment reader service principal", settings_url: "/settings?tab=platform#feature-assessment" }],
      refusedKey: "reader_application_id",
    });
    const cm = new ApiError(422, "Unprocessable Entity", {
      detail: { error: "config_missing", missing: [{ key: "warehouse", label: "SQL warehouse", settings_url: "/settings?tab=platform" }], message: "Set it." },
    });
    expect(parseSettingsError(cm)).toEqual({
      message: "Set it.",
      missing: [{ key: "warehouse", label: "SQL warehouse", settings_url: "/settings?tab=platform" }],
      refusedKey: null,
    });
  });

  it("a config_missing item of a feature setting links to its card; others keep their URL", () => {
    const cm = new ApiError(422, "Unprocessable Entity", {
      detail: {
        error: "config_missing",
        missing: [
          { key: "taxonomy_llm", label: "Domain Taxonomy Builder model service", settings_url: "/settings?tab=platform" },
          { key: "warehouse", label: "SQL warehouse", settings_url: "/settings?tab=platform" },
        ],
        message: "Set them.",
      },
    });
    expect(parseSettingsError(cm)?.missing.map((m) => m.settings_url)).toEqual([
      "/settings?tab=platform#feature-taxonomy",
      "/settings?tab=platform",
    ]);
  });

  it("an unknown refused key still links to Settings", () => {
    expect(parseSettingsError(refused("setting_refused", "something_new"))?.missing).toEqual([
      { key: "something_new", label: "something_new", settings_url: "/settings" },
    ]);
  });
});

describe("identity_missing", () => {
  it("reads as its message", () => {
    const err = new ApiError(401, "Unauthorized", {
      detail: { error: "identity_missing", message: "Sign in to the workspace to copy the hand-off." },
    });
    expect(apiErrorMessage(err)).toBe("Sign in to the workspace to copy the hand-off.");
  });
});
