import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";
import { act, fireEvent, screen, waitFor, within } from "@testing-library/react";

vi.mock("sonner", () => ({
  toast: {
    success: vi.fn(),
    error: vi.fn(),
  },
}));

const mockedNotifyError = vi.fn();
vi.mock("@/lib/notify", () => ({
  notifyError: (...args: unknown[]) => mockedNotifyError(...args),
}));

vi.mock("@/lib/api", async () => {
  const actual =
    await vi.importActual<typeof import("@/lib/api")>("@/lib/api");
  return {
    ...actual,
    cancelRunWithRollback: vi.fn(),
    retryRun: vi.fn(),
    resumeRun: vi.fn(),
  };
});

import {
  cancelRunWithRollback,
  resumeRun,
  retryRun,
  type RunOut,
} from "@/lib/api";
import { toast } from "sonner";
import { RunDetail } from "@/routes/_sidebar/businesses.$businessId.runs.$runId";
import { renderWithRouter } from "./helpers/router-wrapper";

const mockedCancelRollback = vi.mocked(cancelRunWithRollback);
const mockedResume = vi.mocked(resumeRun);
const mockedRetry = vi.mocked(retryRun);
const mockedToastError = vi.mocked(toast.error);

type FetchMock = ReturnType<typeof vi.fn>;

// Stub every fetch call the page might make. `useGetRunSuspense` hits
// `/api/runs/{id}` and expects a RunOut envelope; the LineageCard hits
// `/api/runs/{id}/lineage` (operates-on), `/api/runs/{id}/operations`
// (source/generated derivation — the model-versioning work #52), and
// `/api/businesses/{id}/versions` (id → (version, scope) lookup); the
// ProgressPipeline hits `/api/runs/{id}/progress`; ArtifactsTab pulls
// `/api/runs/{id}/artifacts`. Route based on URL path so one stub
// covers them all.
function stubAllFetch(run: RunOut): FetchMock {
  const fn = vi.fn(async (url: RequestInfo) => {
    const u = String(url);
    if (u.includes("/lineage")) {
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
    }
    if (u.includes("/artifacts")) {
      return { ok: true, status: 200, json: async () => [] };
    }
    if (u.includes("/operations")) {
      return { ok: true, status: 200, json: async () => [] };
    }
    if (u.includes("/progress")) {
      return { ok: true, status: 200, json: async () => [] };
    }
    if (u.includes("/schema-drops")) {
      return {
        ok: true,
        status: 200,
        json: async () => [
          { name: "ecm_intake", status: "failed", table_count: 2, error: "[PERMISSION_DENIED] cannot drop" },
          { name: "ecm_sales", status: "dropped", table_count: 1, error: null },
        ],
      };
    }
    if (u.includes("/businesses/") && u.includes("/versions")) {
      return { ok: true, status: 200, json: async () => [] };
    }
    // Default: /api/runs/{id}
    return { ok: true, status: 200, json: async () => run };
  }) as FetchMock;
  vi.stubGlobal("fetch", fn);
  return fn;
}

function makeRun(overrides: Partial<RunOut> = {}): RunOut {
  return {
    id: "run-1",
    business_id: "biz-1",
    version_id: null,
    intent: "new-base-model",
    status: "running",
    databricks_run_id: 42,
    vibe_session_id: null,
    run_page_url: null,
    progress_percent: 30,
    progress_message: "Working...",
    error_message: "",
    parameters_json: JSON.stringify({
      operation: "new base model",
      ecm_mvm_unified: true,
      ecm_mvm_phase: "ecm",
    }),
    vibe_instructions_text: "",
    vibe_instructions_volume_path: "",
    started_at: "2026-04-20T12:00:00Z",
    completed_at: null,
    created_at: "2026-04-20T11:59:00Z",
    ...overrides,
  };
}

describe("RunDetail — Resume button visibility", () => {
  beforeEach(() => {
    vi.unstubAllGlobals();
    mockedCancelRollback.mockReset();
    mockedResume.mockReset();
  });
  afterEach(() => {
    vi.restoreAllMocks();
    vi.unstubAllGlobals();
  });

  it("hides Resume when the run is running", async () => {
    stubAllFetch(makeRun({ status: "running" }));
    renderWithRouter(<RunDetail businessId="biz-1"
          runId="run-1" />);
    await waitFor(() =>
      expect(screen.getByText(/Run:/i)).toBeInTheDocument(),
    );
    expect(screen.queryByRole("button", { name: /Resume/ })).not.toBeInTheDocument();
  });

  it("hides Resume for a non-unified failed run", async () => {
    stubAllFetch(
      makeRun({
        status: "failed",
        parameters_json: JSON.stringify({ operation: "new base model" }),
      }),
    );
    renderWithRouter(<RunDetail businessId="biz-1"
          runId="run-1" />);
    await waitFor(() =>
      expect(screen.getByText(/Run:/i)).toBeInTheDocument(),
    );
    expect(screen.queryByRole("button", { name: /Resume/ })).not.toBeInTheDocument();
  });

  it("shows Resume on a unified failed run", async () => {
    stubAllFetch(makeRun({ status: "failed" }));
    renderWithRouter(<RunDetail businessId="biz-1"
          runId="run-1" />);

    await waitFor(() =>
      expect(
        screen.getByRole("button", { name: /Resume/ }),
      ).toBeInTheDocument(),
    );
  });

  it("shows Resume on a unified stale run", async () => {
    stubAllFetch(makeRun({ status: "stale" }));
    renderWithRouter(<RunDetail businessId="biz-1"
          runId="run-1" />);

    await waitFor(() =>
      expect(
        screen.getByRole("button", { name: /Resume/ }),
      ).toBeInTheDocument(),
    );
  });

  it("fires resumeRun on dialog confirm", async () => {
    mockedResume.mockResolvedValue({
      data: { ok: true, next_phase: "mvm", status: "running" },
    } as Awaited<ReturnType<typeof resumeRun>>);
    stubAllFetch(makeRun({ status: "failed" }));

    renderWithRouter(<RunDetail businessId="biz-1"
          runId="run-1" />);
    const resume = await screen.findByRole("button", { name: /Resume/ });

    await act(async () => {
      fireEvent.click(resume);
    });

    // Dialog confirmation
    const confirm = await screen.findByRole("button", { name: /^Resume$/ });
    await act(async () => {
      fireEvent.click(confirm);
    });

    await waitFor(() => {
      expect(mockedResume).toHaveBeenCalledWith({ business_id: "biz-1", run_id: "run-1" });
    });
  });
});

describe("RunDetail — Cancel dialog", () => {
  beforeEach(() => {
    vi.unstubAllGlobals();
    mockedCancelRollback.mockReset();
  });
  afterEach(() => {
    vi.restoreAllMocks();
    vi.unstubAllGlobals();
  });

  it.each(["kickstart-from-industry", "download-industry", "uninstall-orphan-schemas"])(
    "offers 'Mark as cancelled' on a %s run, saying what it does and does not do",
    async (intent) => {
      stubAllFetch(makeRun({ status: "stale", intent, parameters_json: "{}" }));
      renderWithRouter(<RunDetail businessId="biz-1" runId="run-1" />);
      const button = await screen.findByTestId("cancel-run");
      expect(button).toHaveTextContent("Mark as cancelled");
      await act(async () => {
        fireEvent.click(button);
      });
      expect(await screen.findByTestId("cancel-run-copy")).toHaveTextContent(
        /frees the business for other runs\. It does not stop a step that is still going or undo what was done/,
      );
      mockedCancelRollback.mockResolvedValue({ data: { ok: true, status: "cancelled", ops_applied: [], op_failures: [] } } as never);
      await act(async () => {
        fireEvent.click(within(screen.getByRole("alertdialog")).getByRole("button", { name: "Mark as cancelled" }));
      });
      await waitFor(() => expect(mockedCancelRollback).toHaveBeenCalledWith({ business_id: "biz-1", run_id: "run-1" }));
    },
  );

  it("renders the single rollback-by-default cancel button on any running run", async () => {
    // v0.4.0 update: the dialog no longer offers a "Just cancel"
    // variant — every cancel now rolls back partial state per
    // feedback_state_atomicity + v0.4.0 #2b's uniform rollback fix.
    stubAllFetch(makeRun({ status: "running" }));

    renderWithRouter(<RunDetail businessId="biz-1"
          runId="run-1" />);

    const cancelToolbar = await screen.findByRole("button", { name: /^Cancel$/ });
    await act(async () => {
      fireEvent.click(cancelToolbar);
    });

    // Single confirm button + the warning copy reflects the new behaviour.
    await waitFor(() =>
      expect(
        screen.getByText(/Any partial work will be rolled back, and the run marked as canceled\./i),
      ).toBeInTheDocument(),
    );
    expect(screen.getByRole("button", { name: /Cancel run/ })).toBeInTheDocument();
    expect(
      screen.queryByRole("button", { name: /just cancel/i }),
    ).not.toBeInTheDocument();
    expect(
      screen.queryByRole("button", { name: /roll back partial state/i }),
    ).not.toBeInTheDocument();
  });

  // an internal tracker item — pre-fix the dialog said "Any partial work
  // will NOT be rolled back" which contradicted v0.4.0 #2b's behaviour
  // (cancel does in fact roll back). A loose `/will be rolled back/i`
  // regex matches the substring inside "will not be rolled back" too, so
  // the existing positive assertion alone wouldn't guard against
  // re-regression. Pin both the positive ("will be rolled back") AND
  // negative ("will not be rolled back") strings explicitly.
  it("dialog copy does NOT claim partial work will not be rolled back", async () => {
    stubAllFetch(makeRun({ status: "running" }));

    renderWithRouter(<RunDetail businessId="biz-1" runId="run-1" />);
    const cancelToolbar = await screen.findByRole("button", { name: /^Cancel$/ });
    await act(async () => {
      fireEvent.click(cancelToolbar);
    });

    await waitFor(() =>
      expect(screen.getByText(/Cancel run\?/i)).toBeInTheDocument(),
    );

    // Read the description body's textContent so we can make an exact-
    // substring assertion that doesn't accidentally match the negation form.
    const desc = screen.getByText(
      /Any partial work will be rolled back, and the run marked as canceled\./i,
    );
    const body = desc.textContent ?? "";
    expect(body).toContain("will be rolled back");
    expect(body).not.toMatch(/will not be rolled back/i);
    expect(body).not.toMatch(/won['’]t be rolled back/i);
  });

  it("calls cancelRunWithRollback when the confirm button is clicked", async () => {
    mockedCancelRollback.mockResolvedValue({
      data: { ok: true, status: "cancelled", ops_applied: [{ kind: "delete_model_version" }] },
    } as Awaited<ReturnType<typeof cancelRunWithRollback>>);
    stubAllFetch(makeRun({ status: "running" }));

    renderWithRouter(<RunDetail businessId="biz-1"
          runId="run-1" />);

    const cancelToolbar = await screen.findByRole("button", { name: /^Cancel$/ });
    await act(async () => {
      fireEvent.click(cancelToolbar);
    });

    const confirm = await screen.findByRole("button", { name: /^Cancel run$/ });
    await act(async () => {
      fireEvent.click(confirm);
    });

    await waitFor(() => {
      expect(mockedCancelRollback).toHaveBeenCalledWith({ business_id: "biz-1", run_id: "run-1" });
    });
  });
});

describe("RunDetail — Mutation error paths", () => {
  beforeEach(() => {
    vi.unstubAllGlobals();
    mockedCancelRollback.mockReset();
    mockedResume.mockReset();
    mockedRetry.mockReset();
    mockedToastError.mockReset();
    mockedNotifyError.mockReset();
  });
  afterEach(() => {
    vi.restoreAllMocks();
    vi.unstubAllGlobals();
  });

  it("fires toast.error and re-enables the cancel button when cancelRunWithRollback returns an error", async () => {
    // v0.4.0 update: single cancel path → cancelRunWithRollback is the
    // only path. 4xx and 5xx both surface as toast.error with the
    // server message; the toolbar Cancel button re-enables via the
    // `finally` block.
    const rollbackErr = new Error("Rollback step crashed: delete_volume");
    mockedCancelRollback.mockRejectedValue(rollbackErr);
    stubAllFetch(makeRun({ status: "running" }));

    renderWithRouter(<RunDetail businessId="biz-1"
          runId="run-1" />);

    const cancelToolbar = await screen.findByRole("button", { name: /^Cancel$/ });
    await act(async () => {
      fireEvent.click(cancelToolbar);
    });

    const confirm = await screen.findByRole("button", { name: /^Cancel run$/ });
    await act(async () => {
      fireEvent.click(confirm);
    });

    await waitFor(() => {
      expect(mockedNotifyError).toHaveBeenCalledWith(
        rollbackErr,
        { title: "Cancel-with-rollback failed" },
      );
    });
    expect(mockedToastError).not.toHaveBeenCalled();

    // Cancel button must be back to enabled.
    await waitFor(() => {
      const cancelAfter = screen.getByRole("button", { name: /^Cancel$/ });
      expect(cancelAfter).not.toBeDisabled();
    });
  });

  it("fires toast.error and re-enables Resume when resumeRun returns 500", async () => {
    const resumeErr = new Error("Dispatcher unavailable");
    mockedResume.mockRejectedValue(resumeErr);
    stubAllFetch(makeRun({ status: "failed" }));

    renderWithRouter(<RunDetail businessId="biz-1"
          runId="run-1" />);

    const resume = await screen.findByRole("button", { name: /Resume/ });
    await act(async () => {
      fireEvent.click(resume);
    });

    // Click the dialog's confirm button.
    const confirm = await screen.findByRole("button", { name: /^Resume$/ });
    await act(async () => {
      fireEvent.click(confirm);
    });

    await waitFor(() => {
      expect(mockedNotifyError).toHaveBeenCalledWith(
        resumeErr,
        expect.objectContaining({ fallback: expect.stringMatching(/resume/i) }),
      );
    });
    expect(mockedToastError).not.toHaveBeenCalled();

    // Toolbar Resume button is re-enabled.
    await waitFor(() => {
      const resumeAfter = screen.getByRole("button", { name: /Resume/ });
      expect(resumeAfter).not.toBeDisabled();
    });
  });

  it("re-enables Retry when retryRun returns 422 (validation failed)", async () => {
    // After the silent-error fix, `handleRetry` now wraps `retryRun` in a
    // try/catch. The rejection no longer escapes as an unhandledrejection;
    // it produces a `toast.error(...)` call. Test asserts the new behavior.
    const validationErr = new Error("Validation failed: catalog missing");
    Object.assign(validationErr, { status: 422 });
    mockedRetry.mockRejectedValue(validationErr);
    // The Retry button is only shown for failed/cancelled runs.
    stubAllFetch(
      makeRun({
        status: "failed",
        parameters_json: JSON.stringify({ operation: "new base model" }),
      }),
    );

    renderWithRouter(<RunDetail businessId="biz-1"
          runId="run-1" />);

    const retry = await screen.findByRole("button", { name: /Retry/ });
    await act(async () => {
      fireEvent.click(retry);
    });

    // The mutation must have been invoked.
    await waitFor(() => {
      expect(mockedRetry).toHaveBeenCalledWith({ business_id: "biz-1", run_id: "run-1" });
    });

    // notifyError fires with the error and a "Retry failed" title.
    await waitFor(() => {
      expect(mockedNotifyError).toHaveBeenCalledWith(
        validationErr,
        { title: "Retry failed" },
      );
    });
    expect(mockedToastError).not.toHaveBeenCalled();

    // Retry button re-enabled (acting flag flipped off in finally).
    const retryAfter = screen.getByRole("button", { name: /Retry/ });
    expect(retryAfter).not.toBeDisabled();
  });
});

describe("RunDetail — Dry Run and scope badges", () => {
  beforeEach(() => {
    vi.unstubAllGlobals();
  });
  afterEach(() => {
    vi.restoreAllMocks();
    vi.unstubAllGlobals();
  });

  it("shows Dry Run and Scope badges from parameters_json", async () => {
    stubAllFetch(
      makeRun({
        intent: "vibe-iterate",
        status: "completed",
        parameters_json: JSON.stringify({
          intent: "vibe-iterate",
          vibe_scope: "some_domains",
          vibe_scope_domains: ["meter_to_cash", "billing"],
          dry_run: true,
        }),
      }),
    );
    renderWithRouter(<RunDetail businessId="biz-1" runId="run-1" />);
    await waitFor(() => expect(screen.getByText(/Run:/i)).toBeInTheDocument());
    expect(screen.getByTestId("run-dry-run-badge")).toHaveTextContent("Dry Run");
    expect(screen.getByTestId("run-scope-badge")).toHaveTextContent(
      "Scope: meter_to_cash, billing",
    );
  });

  it("shows no badges for an unscoped Full Run", async () => {
    stubAllFetch(
      makeRun({
        intent: "vibe-iterate",
        status: "completed",
        parameters_json: JSON.stringify({
          intent: "vibe-iterate",
          vibe_scope: "all_domains",
          vibe_scope_domains: [],
          dry_run: false,
        }),
      }),
    );
    renderWithRouter(<RunDetail businessId="biz-1" runId="run-1" />);
    await waitFor(() => expect(screen.getByText(/Run:/i)).toBeInTheDocument());
    expect(screen.queryByTestId("run-dry-run-badge")).not.toBeInTheDocument();
    expect(screen.queryByTestId("run-scope-badge")).not.toBeInTheDocument();
  });
});

describe("RunDetail — orphan-schema drop run", () => {
  afterEach(() => {
    vi.restoreAllMocks();
    vi.unstubAllGlobals();
  });

  it("shows its label and each schema's outcome, and offers no Retry", async () => {
    const fetchMock = stubAllFetch(makeRun({
      status: "failed", intent: "uninstall-orphan-schemas", databricks_run_id: null,
      parameters_json: JSON.stringify({ catalog: "home_cat", schemas: ["ecm_intake", "ecm_sales"] }),
    }));
    renderWithRouter(<RunDetail businessId="biz-1" runId="run-1" />);
    expect(await screen.findByRole("heading", { name: "Run: Drop orphan schemas" })).toBeInTheDocument();
    const card = await screen.findByTestId("run-schema-drops");
    await waitFor(() => expect(within(card).getAllByTestId("run-schema-drop")).toHaveLength(2));
    expect(card).toHaveTextContent("1 of 2 schemas dropped.");
    expect(card).toHaveTextContent("[PERMISSION_DENIED] cannot drop");
    expect(fetchMock.mock.calls.some(([u]) => String(u) === "/api/businesses/biz-1/runs/run-1/schema-drops")).toBe(true);
    expect(screen.queryByRole("button", { name: /Retry/ })).toBeNull();
  });
});

describe("RunDetail - warnings of a finished run", () => {
  beforeEach(() => {
    vi.unstubAllGlobals();
  });
  afterEach(() => {
    vi.restoreAllMocks();
    vi.unstubAllGlobals();
  });

  const LEFT_BEHIND =
    "v1 ECM is uninstalled from business_1, but these schemas could not be dropped and are still there: " +
    "ecm_intake, ecm_sales. Their owner, or someone with the right privileges, can drop them.";

  it("shows the warning of a completed uninstall", async () => {
    stubAllFetch(
      makeRun({
        status: "completed",
        intent: "uninstall",
        progress_percent: 100,
        warnings: [{ field_path: "(uninstall)", step_index: 0, message: LEFT_BEHIND, severity: "warning" }],
      }),
    );
    renderWithRouter(<RunDetail businessId="biz-1" runId="run-1" />);
    const card = await screen.findByTestId("run-warnings");
    expect(within(card).getByTestId("run-warning")).toHaveTextContent(LEFT_BEHIND);
    expect(screen.getByText("Done")).toBeInTheDocument();
  });

  it("shows the statement of a registry release that may not have run, with a copy button", async () => {
    const RELEASE =
      "v1 MVM is uninstalled from business_1, but the app may not have marked it as not installed in " +
      "business_1's _metamodel.";
    const SQL = "UPDATE `business_1`.`_metamodel`.`business` SET deploy_status = 'dry_run' WHERE version = '1'";
    stubAllFetch(
      makeRun({
        status: "completed",
        intent: "uninstall",
        progress_percent: 100,
        warnings: [
          { field_path: "(uninstall)", step_index: 0, message: LEFT_BEHIND, severity: "warning" },
          { field_path: "(uninstall)", step_index: 0, message: RELEASE, severity: "warning", sql: SQL },
        ],
      }),
    );
    renderWithRouter(<RunDetail businessId="biz-1" runId="run-1" />);
    const card = await screen.findByTestId("run-warnings");
    expect(within(card).getAllByTestId("run-warning").map((p) => p.textContent)).toEqual([LEFT_BEHIND, RELEASE]);
    expect(within(card).getByText(SQL).tagName).toBe("PRE");
    expect(within(card).getAllByRole("button", { name: "Copy SQL" })).toHaveLength(1);
  });

  it("shows no warning card when the run has none", async () => {
    stubAllFetch(makeRun({ status: "completed", progress_percent: 100, warnings: [] }));
    renderWithRouter(<RunDetail businessId="biz-1" runId="run-1" />);
    await screen.findByText("Done");
    expect(screen.queryByTestId("run-warnings")).not.toBeInTheDocument();
  });
});
