import type { ModelVersionOut } from "@/lib/api";

/** A complete `ModelVersionOut` for tests: a completed, not installed MVM v1. */
export function makeModelVersion(over: Partial<ModelVersionOut> = {}): ModelVersionOut {
  return {
    id: "mv-1",
    version: 1,
    scope: "mvm",
    status: "completed",
    business_id: "b1",
    base_version_id: null,
    completion_date: null,
    confidence_score: null,
    context_id: null,
    created_at: "2026-10-20T12:00:00Z",
    deployment_status: "draft",
    uc_catalog: "",
    files_catalog: "cat_a",
    vibe_instructions: "",
    dry_run: false,
    promoted_at: null,
    replaced_at: null,
    replaced_by_version_id: null,
    draft_state: null,
    is_head: true,
    ...over,
  };
}
