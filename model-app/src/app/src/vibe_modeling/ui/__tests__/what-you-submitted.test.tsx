/**
 * WhatYouSubmitted component tests.
 *
 * Verifies:
 * 1. All populated user-facing fields render.
 * 2. Empty-state message renders when ALL fields are absent.
 * 3. The collapsible "Run configuration" block is still accessible in the
 *    run-detail page (runs.$runId.tsx) after the parameters block was
 *    wrapped in a <details> element.
 * 4. business_context_text, vibe_instructions_text, volume path, and
 *    sample-data each render independently.
 */

import { describe, expect, it, vi, beforeEach, afterEach } from "vitest";
import { render, screen, waitFor } from "@testing-library/react";
import type { RunOperationOut, RunOut } from "@/lib/api";

// react-markdown uses ES module syntax that vitest's jsdom transformer can't
// handle by default. Stub it so the markdown content is rendered as plain
// text — sufficient for the assertions below which check text presence, not
// HTML tags. The artifacts-tab uses the same pattern.
vi.mock("react-markdown", () => ({
  default: ({ children }: { children: string }) => <span>{children}</span>,
}));

import { WhatYouSubmitted } from "@/components/runs/what-you-submitted";

// Minimal RunOut shape with all user-facing fields absent.
function makeRun(overrides: Partial<RunOut> = {}): RunOut {
  return {
    id: "run-1",
    business_id: "biz-1",
    version_id: null,
    intent: "new-base-model",
    status: "completed",
    databricks_run_id: null,
    vibe_session_id: null,
    run_page_url: null,
    progress_percent: 100,
    progress_message: "",
    error_message: "",
    parameters_json: "{}",
    vibe_instructions_text: "",
    vibe_instructions_volume_path: "",
    business_context_text: "",
    started_at: "2026-04-20T12:00:00Z",
    completed_at: "2026-04-20T13:00:00Z",
    created_at: "2026-04-20T11:59:00Z",
    ...overrides,
  };
}

// Minimal RunOperationOut factory for dispatched_widgets tests.
function makeOperation(overrides: Partial<RunOperationOut> = {}): RunOperationOut {
  return {
    id: "op-1",
    run_id: "run-1",
    step_index: 0,
    operation_name: "generate_samples",
    status: "completed",
    created_at: "2026-04-20T12:00:00Z",
    ...overrides,
  };
}

describe("WhatYouSubmitted - dispatched widgets", () => {
  it("renders every key from a non-empty dispatched_widgets map, not just known ones", () => {
    render(
      <WhatYouSubmitted
        run={makeRun()}
        operations={[
          makeOperation({
            operation_name: "generate_samples",
            dispatched_widgets: {
              data_model_scopes: "ecm,mvm",
              deployment_catalog: "my_catalog",
              sample_count: 250,
            },
          }),
        ]}
      />,
    );
    expect(screen.getByText(/dispatched widgets/i)).toBeInTheDocument();
    expect(screen.getByText("data_model_scopes")).toBeInTheDocument();
    expect(screen.getByText("ecm,mvm")).toBeInTheDocument();
    expect(screen.getByText("deployment_catalog")).toBeInTheDocument();
    expect(screen.getByText("my_catalog")).toBeInTheDocument();
    expect(screen.getByText("sample_count")).toBeInTheDocument();
    expect(screen.getByText("250")).toBeInTheDocument();
  });

  it("does NOT render a dispatched widgets section when the map is empty", () => {
    render(
      <WhatYouSubmitted
        run={makeRun()}
        operations={[makeOperation({ dispatched_widgets: {} })]}
      />,
    );
    expect(screen.queryByText(/dispatched widgets/i)).not.toBeInTheDocument();
  });

  it("does NOT render a dispatched widgets section when the field is absent", () => {
    render(
      <WhatYouSubmitted run={makeRun()} operations={[makeOperation()]} />,
    );
    expect(screen.queryByText(/dispatched widgets/i)).not.toBeInTheDocument();
  });

  it("does NOT render a dispatched widgets section when no operations are passed at all", () => {
    render(<WhatYouSubmitted run={makeRun()} />);
    expect(screen.queryByText(/dispatched widgets/i)).not.toBeInTheDocument();
  });

  it("renders a section per operation, skipping the ones without a populated map", () => {
    render(
      <WhatYouSubmitted
        run={makeRun()}
        operations={[
          makeOperation({ id: "op-1", operation_name: "install", dispatched_widgets: {} }),
          makeOperation({
            id: "op-2",
            operation_name: "generate_samples",
            dispatched_widgets: { sample_count: 10 },
          }),
        ]}
      />,
    );
    const sections = screen.getAllByText(/dispatched widgets/i);
    expect(sections).toHaveLength(1);
    expect(screen.getByText(/generate_samples/i)).toBeInTheDocument();
  });
});

describe("WhatYouSubmitted — empty state", () => {
  it("renders a quiet 'No additional inputs' message when all fields are empty", () => {
    render(<WhatYouSubmitted run={makeRun()} />);
    expect(
      screen.getByText(/no additional inputs/i),
    ).toBeInTheDocument();
  });
});

describe("WhatYouSubmitted — business_context_text", () => {
  it("renders the label and verbatim text when business_context_text is set", () => {
    render(
      <WhatYouSubmitted
        run={makeRun({ business_context_text: "We focus on retail loyalty analytics." })}
      />,
    );
    expect(screen.getByText(/business context/i)).toBeInTheDocument();
    expect(
      screen.getByText(/retail loyalty analytics/i),
    ).toBeInTheDocument();
  });

  it("does NOT render the business context section when business_context_text is empty", () => {
    render(<WhatYouSubmitted run={makeRun({ business_context_text: "" })} />);
    // The heading "Business context" must not appear (empty-state message appears instead).
    expect(screen.queryByText(/^Business context$/i)).not.toBeInTheDocument();
  });
});

describe("WhatYouSubmitted — vibe_instructions_text", () => {
  it("renders the run instructions when vibe_instructions_text is set", () => {
    render(
      <WhatYouSubmitted
        run={makeRun({ vibe_instructions_text: "Align everything with ISO 27001." })}
      />,
    );
    expect(screen.getByText(/run instructions/i)).toBeInTheDocument();
    expect(screen.getByText(/ISO 27001/i)).toBeInTheDocument();
  });

  it("strips K1 markers from the run instructions and dispatched model_vibes (D16)", () => {
    const agentText = [
      "## Domain: meter_to_cash",
      "- (high) [meter_to_cash.invoice] Add a due date <!-- vi:abc-1 target=meter_to_cash.invoice -->",
      "<!-- vi:abc-2 target=meter_to_cash -->",
      "> Priority: medium",
      "Rich block body",
    ].join("\n");
    const { container } = render(
      <WhatYouSubmitted
        run={makeRun({ intent: "vibe-iterate", vibe_instructions_text: agentText })}
        operations={[
          makeOperation({
            operation_name: "vibe_iterate",
            dispatched_widgets: { model_vibes: agentText, run_type: "Dry Run" },
          }),
        ]}
      />,
    );
    expect(container.textContent).not.toContain("<!--");
    expect(container.textContent).not.toContain("vi:abc");
    expect(screen.getAllByText(/Add a due date/).length).toBeGreaterThan(0);
    expect(screen.getAllByText(/Rich block body/).length).toBeGreaterThan(0);
  });
});

describe("WhatYouSubmitted — volume path", () => {
  it("renders the volume path section when vibe_instructions_volume_path is set", () => {
    const path = "/Volumes/catalog/schema/vol/instructions.txt";
    render(
      <WhatYouSubmitted
        run={makeRun({ vibe_instructions_volume_path: path })}
      />,
    );
    expect(screen.getByText(/instructions file/i)).toBeInTheDocument();
    expect(screen.getByText(path)).toBeInTheDocument();
  });
});

describe("WhatYouSubmitted — sample data", () => {
  it("shows sample badge when generate_samples is true", () => {
    render(
      <WhatYouSubmitted
        run={makeRun({
          parameters_json: JSON.stringify({ generate_samples: true }),
        })}
      />,
    );
    expect(screen.getByText(/sample data/i)).toBeInTheDocument();
    // Badge text: "Enabled" when no count, or "<N> records" with one.
    expect(screen.getByText(/enabled/i)).toBeInTheDocument();
  });

  it("shows record count in the badge when sample_count is provided", () => {
    render(
      <WhatYouSubmitted
        run={makeRun({
          parameters_json: JSON.stringify({ generate_samples: true, sample_count: 250 }),
        })}
      />,
    );
    expect(screen.getByText(/250 records/i)).toBeInTheDocument();
  });

  it("does NOT show sample section when generate_samples is false", () => {
    render(
      <WhatYouSubmitted
        run={makeRun({
          parameters_json: JSON.stringify({ generate_samples: false }),
        })}
      />,
    );
    expect(screen.queryByText(/sample data/i)).not.toBeInTheDocument();
  });
});

describe("WhatYouSubmitted — advanced overrides", () => {
  it("shows naming_convention override when user picked a non-default value", () => {
    render(
      <WhatYouSubmitted
        run={makeRun({
          // snake_case is the default; camelCase is a real override.
          parameters_json: JSON.stringify({ naming_convention: "camelCase" }),
        })}
      />,
    );
    expect(screen.getByText(/advanced overrides/i)).toBeInTheDocument();
    expect(screen.getByText("Naming convention")).toBeInTheDocument();
    expect(screen.getByText("camelCase")).toBeInTheDocument();
  });

  it("always shows the run's stored run time budget, even at the Settings default", () => {
    render(
      <WhatYouSubmitted
        run={makeRun({
          parameters_json: JSON.stringify({ intent: "new-base-model", runtime_budget_hours: 6 }),
        })}
      />,
    );
    expect(screen.getByText("Run time budget (hours)")).toBeInTheDocument();
    expect(screen.getByText("6")).toBeInTheDocument();
  });

  it("does NOT show advanced overrides section when no override fields are set", () => {
    render(
      <WhatYouSubmitted
        run={makeRun({
          // Only orchestrator-internal params; no user-typed override fields.
          parameters_json: JSON.stringify({
            intent: "new-base-model",
            deployment_catalog: "my_catalog",
            ecm_mvm_unified: true,
          }),
        })}
      />,
    );
    expect(screen.queryByText(/advanced overrides/i)).not.toBeInTheDocument();
  });

  // Bug #43: router stamps canonical defaults into parameters_json even when
  // the user never touched the Advanced Options panel. The "What you
  // submitted" surface must NOT show those router-derived defaults.
  it("hides the entire advanced overrides section when every field equals its default", () => {
    render(
      <WhatYouSubmitted
        run={makeRun({
          parameters_json: JSON.stringify({
            // All values match CONVENTION_DEFAULTS in routes/_sidebar/runs.new.tsx.
            naming_convention: "snake_case",
            primary_key_suffix: "_id",
            schema_prefix: "",
            ecm_schema_prefix: "ecm_",
            mvm_schema_prefix: "mvm_",
            schema_suffix: "",
            tag_prefix: "dbx_",
            tag_suffix: "",
            table_id_type: "BIGINT",
            boolean_format: "Boolean (True/False)",
            date_format: "yyyy-MM-dd",
            timestamp_format: "yyyy-MM-dd HH:mm:ss",
            cataloging_style: "One Catalog",
            catalog_prefix: "",
            catalog_suffix: "",
            org_divisions: "Operations",
            business_domains: "",
            classification_levels: "",
            housekeeping_columns: "No",
            history_tracking_columns: "No",
            // Plus the orchestrator-internal noise that always rides along.
            intent: "new-base-model",
            deployment_catalog: "my_catalog",
            ecm_mvm_unified: true,
          }),
        })}
      />,
    );
    // Section heading must be absent — no "ADVANCED OVERRIDES" with no rows.
    expect(screen.queryByText(/advanced overrides/i)).not.toBeInTheDocument();
    // Specific defaults that bug #43 reported must NOT appear.
    expect(screen.queryByText(/^Schema prefix$/i)).not.toBeInTheDocument();
    expect(screen.queryByText(/^ECM schema prefix$/i)).not.toBeInTheDocument();
    expect(screen.queryByText(/^MVM schema prefix$/i)).not.toBeInTheDocument();
    expect(screen.queryByText(/^Cataloging style$/i)).not.toBeInTheDocument();
  });

  // E-02: the router stamps the legacy `schema_prefix` = the effective ECM
  // prefix (`ecm_`) for base-model runs, even though the legacy field's own
  // default is "". That mirror must NOT leak as a fake "Schema prefix: ecm_"
  // override.
  it("hides schema_prefix when it mirrors the ECM prefix (ecm_)", () => {
    render(
      <WhatYouSubmitted
        run={makeRun({
          parameters_json: JSON.stringify({
            intent: "new-base-model",
            ecm_mvm_unified: true,
            ecm_schema_prefix: "ecm_",
            mvm_schema_prefix: "mvm_",
            // Router mirror of the ECM prefix — not a user override.
            schema_prefix: "ecm_",
          }),
        })}
      />,
    );
    expect(screen.queryByText(/advanced overrides/i)).not.toBeInTheDocument();
    expect(screen.queryByText(/^Schema prefix$/i)).not.toBeInTheDocument();
  });

  // …but when the ECM prefix itself was customised, schema_prefix mirrors the
  // customised value and still must not show as a separate override row.
  it("hides schema_prefix when it mirrors a customised ECM prefix", () => {
    render(
      <WhatYouSubmitted
        run={makeRun({
          parameters_json: JSON.stringify({
            intent: "new-base-model",
            ecm_schema_prefix: "core_",
            schema_prefix: "core_",
          }),
        })}
      />,
    );
    // The customised ECM prefix DOES show (genuine override); the mirrored
    // legacy schema_prefix does not add a duplicate row.
    expect(screen.getByText("ECM schema prefix")).toBeInTheDocument();
    expect(screen.queryByText(/^Schema prefix$/i)).not.toBeInTheDocument();
  });

  // A genuinely user-set legacy schema_prefix (vibe-iterate path, no ECM
  // per-scope prefixes present) must still surface.
  it("shows schema_prefix when the user genuinely set it (no ECM mirror)", () => {
    render(
      <WhatYouSubmitted
        run={makeRun({
          parameters_json: JSON.stringify({
            intent: "vibe-iterate",
            schema_prefix: "stg_",
          }),
        })}
      />,
    );
    expect(screen.getByText(/advanced overrides/i)).toBeInTheDocument();
    expect(screen.getByText("Schema prefix")).toBeInTheDocument();
    expect(screen.getByText("stg_")).toBeInTheDocument();
  });

  // Intent-gated suppression: `vibe-iterate` does NOT stamp the ECM mirror, so
  // a schema_prefix of "ecm_" on a vibe-iterate run is a GENUINE user value and
  // must show — the mirror-suppression only applies to ECM-producing intents.
  it("shows schema_prefix='ecm_' on a vibe-iterate run (not a mirror intent)", () => {
    render(
      <WhatYouSubmitted
        run={makeRun({
          parameters_json: JSON.stringify({
            intent: "vibe-iterate",
            schema_prefix: "ecm_",
          }),
        })}
      />,
    );
    expect(screen.getByText(/advanced overrides/i)).toBeInTheDocument();
    expect(screen.getByText("Schema prefix")).toBeInTheDocument();
    expect(screen.getByText("ecm_")).toBeInTheDocument();
  });

  it("shows only the field the user actually overrode, even when other defaults are present", () => {
    render(
      <WhatYouSubmitted
        run={makeRun({
          parameters_json: JSON.stringify({
            // All defaults except cataloging_style.
            naming_convention: "snake_case",
            schema_prefix: "",
            ecm_schema_prefix: "ecm_",
            mvm_schema_prefix: "mvm_",
            cataloging_style: "Catalog per Domain", // user override
            tag_prefix: "dbx_",
            housekeeping_columns: "No",
          }),
        })}
      />,
    );
    expect(screen.getByText(/advanced overrides/i)).toBeInTheDocument();
    expect(screen.getByText("Cataloging style")).toBeInTheDocument();
    expect(screen.getByText("Catalog per Domain")).toBeInTheDocument();
    // Defaults must remain hidden.
    expect(screen.queryByText(/^Schema prefix$/i)).not.toBeInTheDocument();
    expect(screen.queryByText(/^ECM schema prefix$/i)).not.toBeInTheDocument();
    expect(screen.queryByText(/^MVM schema prefix$/i)).not.toBeInTheDocument();
    expect(screen.queryByText(/^Naming convention$/i)).not.toBeInTheDocument();
    expect(screen.queryByText(/^Tag prefix$/i)).not.toBeInTheDocument();
    expect(screen.queryByText(/^Housekeeping columns$/i)).not.toBeInTheDocument();
  });
});

// ----- Integration: run-detail page wires the component and collapses params

// The tests below mount RunDetail (the full page component) to verify that
// the WhatYouSubmitted block appears AND the legacy "Run configuration"
// block is still reachable (just collapsed by default). We re-use the same
// fetch-mock pattern as run-detail.test.tsx.

vi.mock("sonner", () => ({
  toast: { success: vi.fn(), error: vi.fn() },
}));

vi.mock("@/lib/api", async () => {
  const actual = await vi.importActual<typeof import("@/lib/api")>("@/lib/api");
  return {
    ...actual,
    // No base-model pre-fill: the form keeps its own values.
    useGetRunDefaults: () => ({ data: undefined, isLoading: false, isError: false }),
    cancelRun: vi.fn(),
    cancelRunWithRollback: vi.fn(),
    retryRun: vi.fn(),
    resumeUnifiedRun: vi.fn(),
  };
});

import { RunDetail } from "@/routes/_sidebar/businesses.$businessId.runs.$runId";
import { renderWithRouter } from "./helpers/router-wrapper";

function stubFetch(run: RunOut) {
  vi.stubGlobal(
    "fetch",
    vi.fn(async (url: RequestInfo) => {
      const u = String(url);
      if (u.includes("/lineage"))
        return {
          ok: true,
          status: 200,
          json: async () => ({
            run_id: run.id,
            intent: run.intent,
            business_id: run.business_id,
            source_version: null,
            generated_version: null,
            operates_on_version: null,
          }),
        };
      if (u.includes("/artifacts"))
        return { ok: true, status: 200, json: async () => [] };
      if (u.includes("/operations"))
        return { ok: true, status: 200, json: async () => [] };
      if (u.includes("/progress"))
        return { ok: true, status: 200, json: async () => [] };
      return { ok: true, status: 200, json: async () => run };
    }),
  );
}

describe("RunDetail integration — WhatYouSubmitted wired in", () => {
  beforeEach(() => vi.unstubAllGlobals());
  afterEach(() => {
    vi.restoreAllMocks();
    vi.unstubAllGlobals();
  });

  it("renders 'What you submitted' heading on the page", async () => {
    stubFetch(
      makeRun({
        status: "completed",
        business_context_text: "Retail platform context",
        parameters_json: JSON.stringify({ ecm_mvm_unified: true }),
      }),
    );
    renderWithRouter(<RunDetail businessId="biz-1"
          runId="run-1" />);
    await waitFor(() =>
      expect(screen.getByText(/what you submitted/i)).toBeInTheDocument(),
    );
  });

  it("'Run configuration' block is present in the DOM (collapsed by default)", async () => {
    const run = makeRun({
      status: "completed",
      parameters_json: JSON.stringify({ ecm_mvm_unified: true, schema_prefix: "ecm_" }),
    });
    stubFetch(run);
    renderWithRouter(<RunDetail businessId="biz-1"
          runId="run-1" />);

    await waitFor(() =>
      expect(screen.getByText(/what you submitted/i)).toBeInTheDocument(),
    );

    // The "Run configuration" summary text must be in the DOM (inside the
    // <details> element) even when collapsed.
    expect(screen.getByText(/run configuration/i)).toBeInTheDocument();
  });
});
