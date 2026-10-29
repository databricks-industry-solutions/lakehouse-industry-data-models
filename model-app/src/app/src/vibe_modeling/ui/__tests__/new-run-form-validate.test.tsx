/**
 * Phase 4 wirer adversarial tests — New Run form live validation.
 *
 * Per docs/orchestrator-design.md §2.4 + §2.4.1:
 *   - The form POSTs to /runs/validate after a 300ms debounce on input.
 *   - Blockers render inline next to the offending field; submit disabled.
 *   - Warnings render but submit stays enabled (with a confirmation gate).
 *
 * STUB-FOR-INTEGRATION: this file imports
 *   `@/components/runs/new-run-form` (or wherever the integrator places it).
 * On `main` (8e48394) the component / debounce wiring does not yet exist
 * and these tests fail at module-resolve / behavior time — intended.
 */

import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";
import { act, fireEvent, render, screen, waitFor } from "@testing-library/react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { jsonResponse } from "./helpers/first-run";

vi.mock("sonner", () => ({
  toast: { error: vi.fn(), success: vi.fn() },
}));

vi.mock("@/lib/notify", () => ({
  notifyError: vi.fn(),
}));

// Phase 4 component path. ``NewRunForm`` is the lightweight embeddable
// shell defined in ``components/runs/new-run-form.tsx`` (the heavy
// ``runs.new`` route still owns the full New Run page).
import { NewRunForm } from "@/components/runs/new-run-form";
import { toast } from "sonner";
import { notifyError } from "@/lib/notify";

type ValidateResponse = {
  warnings: Array<{ field_path: string; step_index: number; message: string; severity: string }>;
  blockers: Array<{ field_path: string; step_index: number; message: string; severity: string }>;
};

let validateResponse: ValidateResponse = { warnings: [], blockers: [] };
let validateCallCount = 0;
const validateBodies: any[] = [];

beforeEach(() => {
  validateResponse = { warnings: [], blockers: [] };
  validateCallCount = 0;
  validateBodies.length = 0;
  vi.useFakeTimers();
  // @ts-expect-error happy path
  global.fetch = vi.fn((url: string, init?: RequestInit) => {
    if (typeof url !== "string") url = (url as URL).toString();
    if (url.includes("/runs/validate")) {
      validateCallCount += 1;
      try {
        validateBodies.push(JSON.parse(String(init?.body ?? "{}")));
      } catch {
        validateBodies.push({});
      }
      return Promise.resolve({
        ok: true,
        json: () => Promise.resolve(validateResponse),
      } as Response);
    }
    if (url.endsWith("/runs") || url.match(/\/runs$/)) {
      return Promise.resolve({
        ok: true,
        json: () => Promise.resolve({ id: "run-1", status: "pending" }),
      } as Response);
    }
    return Promise.resolve({
      ok: true,
      json: () => Promise.resolve({}),
    } as Response);
  });
});

afterEach(() => {
  vi.useRealTimers();
  vi.restoreAllMocks();
});

function renderForm(props: any = {}) {
  const qc = new QueryClient({
    defaultOptions: { queries: { retry: false, refetchOnWindowFocus: false } },
  });
  return render(
    <QueryClientProvider client={qc}>
      <NewRunForm businessId="b-1" {...props} />
    </QueryClientProvider>,
  );
}

async function flushTimers() {
  await act(async () => {
    await Promise.resolve();
  });
}

describe("NewRunForm — debounced /runs/validate", () => {
  it("calls POST /runs/validate after 300ms debounce on input", async () => {
    renderForm();
    // Find any text-input-like field; the catalog field is the most
    // commonly-named one in the existing form. The component MUST
    // expose user input that triggers validation.
    const inputs = document.querySelectorAll("input, textarea, [contenteditable=true]");
    if (inputs.length === 0) {
      throw new Error(
        "NewRunForm rendered no input elements; cannot exercise debounce",
      );
    }
    const target = inputs[0] as HTMLInputElement;
    fireEvent.change(target, { target: { value: "test_catalog_value" } });

    // Before 300ms: no validate call yet.
    await flushTimers();
    expect(validateCallCount).toBe(0);

    // Advance just past the debounce window.
    await act(async () => {
      vi.advanceTimersByTime(310);
      await Promise.resolve();
    });

    await waitFor(() => {
      expect(validateCallCount).toBeGreaterThanOrEqual(1);
    });
  });

  it("renders blocker text inline next to the offending field", async () => {
    validateResponse = {
      warnings: [],
      blockers: [
        {
          field_path: "deployment_catalog",
          step_index: 0,
          message: "Catalog name has invalid characters",
          severity: "blocker",
        },
      ],
    };
    renderForm();
    // Trigger any change to fire the validate call.
    const inputs = document.querySelectorAll("input, textarea");
    if (inputs.length > 0) {
      fireEvent.change(inputs[0] as HTMLInputElement, {
        target: { value: "BAD CATALOG" },
      });
    }
    await act(async () => {
      vi.advanceTimersByTime(400);
      await Promise.resolve();
    });

    await waitFor(() => {
      expect(
        screen.getByText(/Catalog name has invalid characters/i),
      ).toBeInTheDocument();
    });
  });

  it("disables the Submit button when blockers are present", async () => {
    validateResponse = {
      warnings: [],
      blockers: [
        {
          field_path: "deployment_catalog",
          step_index: 0,
          message: "Catalog name has invalid characters",
          severity: "blocker",
        },
      ],
    };
    renderForm();
    const inputs = document.querySelectorAll("input, textarea");
    if (inputs.length > 0) {
      fireEvent.change(inputs[0] as HTMLInputElement, {
        target: { value: "BAD" },
      });
    }
    await act(async () => {
      vi.advanceTimersByTime(400);
      await Promise.resolve();
    });

    // Find the submit/launch button.
    const submitBtn = await screen.findByRole("button", {
      name: /submit|launch|start|create run/i,
    });
    expect(submitBtn).toBeDisabled();
  });

  it("re-enables Submit and does not clear the form when /runs returns 400", async () => {
    // Validate is happy (no blockers) but the eventual POST /runs returns
    // a 4xx server validation error — e.g. an audit field that was racing
    // a server-side state change. The form must not get stuck in a
    // disabled state and must not silently wipe the user's catalog input.
    validateResponse = { warnings: [], blockers: [] };
    let createRunCalls = 0;
    // Override the default fetch handler set up in beforeEach. The
    // `/runs` POST returns 400 with a JSON detail; the validate endpoint
    // continues to behave normally.
    // @ts-expect-error happy path
    global.fetch = vi.fn((url: string, init?: RequestInit) => {
      if (typeof url !== "string") url = (url as URL).toString();
      if (url.includes("/runs/validate")) {
        validateCallCount += 1;
        try {
          validateBodies.push(JSON.parse(String(init?.body ?? "{}")));
        } catch {
          validateBodies.push({});
        }
        return Promise.resolve({
          ok: true,
          json: () => Promise.resolve(validateResponse),
        } as Response);
      }
      if (url.endsWith("/runs") || url.match(/\/runs$/)) {
        createRunCalls += 1;
        // The Orval-generated `createRun` helper reads errors via
        // `res.text()` (then JSON.parses), not `res.json()`. Surface
        // both so the test stub matches both fetch contracts.
        return Promise.resolve(
          jsonResponse(400, { detail: "catalog already in use" }, "Bad Request") as Response,
        );
      }
      return Promise.resolve({
        ok: true,
        json: () => Promise.resolve({}),
      } as Response);
    });

    const onCreated = vi.fn();
    renderForm({ onCreated });

    const inputs = document.querySelectorAll("input, textarea");
    const target = inputs[0] as HTMLInputElement;
    fireEvent.change(target, { target: { value: "ecm_demo" } });

    // Drain the validate debounce so blockers settle to empty.
    await act(async () => {
      vi.advanceTimersByTime(400);
      await Promise.resolve();
    });

    const submitBtn = await screen.findByRole("button", {
      name: /submit|launch|start|create run/i,
    });
    expect(submitBtn).not.toBeDisabled();

    await act(async () => {
      fireEvent.click(submitBtn);
      // Let the promise chain resolve.
      await Promise.resolve();
      await Promise.resolve();
    });

    // POST /runs was attempted exactly once.
    expect(createRunCalls).toBe(1);

    // Form not cleared — the input still holds the user's text.
    expect((target as HTMLInputElement).value).toBe("ecm_demo");

    // Submit re-enabled — the in-flight `submitting` flag flipped back
    // off in the `finally` block, so the user can fix the catalog and
    // try again.
    await waitFor(() => {
      expect(submitBtn).not.toBeDisabled();
    });

    // Success callback must NOT have fired.
    expect(onCreated).not.toHaveBeenCalled();

    // Failure surfaces via notifyError so the user knows why submit failed.
    await waitFor(() => {
      expect(vi.mocked(notifyError)).toHaveBeenCalled();
    });
    expect(vi.mocked(notifyError).mock.calls[0][0]).toMatchObject({
      body: { detail: "catalog already in use" },
    });
    expect(vi.mocked(toast.error)).not.toHaveBeenCalled();
  });

  it("shows warnings inline but keeps Submit enabled", async () => {
    validateResponse = {
      warnings: [
        {
          field_path: "schema_prefix",
          step_index: 0,
          message: "Should end in _ for readability",
          severity: "warning",
        },
      ],
      blockers: [],
    };
    renderForm();
    const inputs = document.querySelectorAll("input, textarea");
    if (inputs.length > 0) {
      fireEvent.change(inputs[0] as HTMLInputElement, {
        target: { value: "ecm" },
      });
    }
    await act(async () => {
      vi.advanceTimersByTime(400);
      await Promise.resolve();
    });

    await waitFor(() => {
      expect(
        screen.getByText(/Should end in _ for readability/i),
      ).toBeInTheDocument();
    });

    const submitBtn = screen.getByRole("button", {
      name: /submit|launch|start|create run/i,
    });
    expect(submitBtn).not.toBeDisabled();
  });
});
