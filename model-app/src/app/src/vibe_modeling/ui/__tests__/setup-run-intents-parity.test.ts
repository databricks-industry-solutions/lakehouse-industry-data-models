/**
 * The run page's setup-run rule (`lib/intent.isSetupRunIntent`) and the
 * backend's `routes/_helpers.AUDIT_INTENTS` read one fixture
 * (`tests/fixtures/setup_run_intents.json`; backend side in
 * `test_version_delete_gc.test_audit_intents_membership`).
 */
import { describe, expect, it } from "vitest";
import fixture from "../../../../../../tests/fixtures/setup_run_intents.json";
import { SETUP_RUN_INTENTS, isSetupRunIntent } from "@/lib/intent";

describe("setup-run intents parity", () => {
  it("matches the backend's audit intents", () => {
    expect([...SETUP_RUN_INTENTS].sort()).toEqual([...fixture.intents].sort());
    for (const intent of fixture.intents) expect(isSetupRunIntent(intent)).toBe(true);
    expect(isSetupRunIntent("install")).toBe(false);
  });
});
