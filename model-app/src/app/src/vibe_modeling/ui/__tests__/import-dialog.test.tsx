/**
 * `ImportModelDialog` coverage — happy path + execute/analyze error branches.
 *
 * The dialog runs a two-step Volume-import flow:
 *   1. analyzeImport — parses the model.json
 *   2. executeImport — actually creates a draft version
 *
 * Combined here (was split across import-dialog-happy.test.tsx).
 */
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";
import { act, fireEvent, render, screen, waitFor } from "@testing-library/react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";

vi.mock("@/lib/api", async () => {
  const actual = await vi.importActual<typeof import("@/lib/api")>("@/lib/api");
  return {
    ...actual,
    analyzeImport: vi.fn(),
    executeImport: vi.fn(),
  };
});

vi.mock("sonner", () => ({
  toast: { error: vi.fn(), success: vi.fn(), warning: vi.fn(), info: vi.fn() },
}));

import { toast } from "sonner";
import { analyzeImport, executeImport, ApiError } from "@/lib/api";
import { ImportModelDialog } from "@/components/import/import-dialog";

const mockedAnalyze = vi.mocked(analyzeImport);
const mockedExecute = vi.mocked(executeImport);

function withQuery(ui: React.ReactNode) {
  const qc = new QueryClient({
    defaultOptions: {
      queries: { retry: false },
      mutations: { retry: false },
    },
  });
  return <QueryClientProvider client={qc}>{ui}</QueryClientProvider>;
}

beforeEach(() => {
  mockedAnalyze.mockReset();
  mockedExecute.mockReset();
});

afterEach(() => {
  vi.restoreAllMocks();
});

describe("ImportModelDialog — happy path", () => {
  it("renders the Volume-path form when the dialog is opened", async () => {
    render(
      withQuery(
        <ImportModelDialog
          businessId="biz-1"
          trigger={<button type="button">Open Import</button>}
        />,
      ),
    );
    fireEvent.click(screen.getByRole("button", { name: /Open Import/i }));
    await waitFor(() =>
      expect(
        screen.getByText(/Import pre-vibed model/i),
      ).toBeInTheDocument(),
    );
    expect(
      screen.getByPlaceholderText(/\/Volumes\/.*model\.json/i),
    ).toBeInTheDocument();
    // Analyze button starts disabled (no path entered yet).
    expect(screen.getByRole("button", { name: /^Analyze$/i })).toBeDisabled();
  });

  it("kicks off analyzeImport with the entered Volume path on submit", async () => {
    mockedAnalyze.mockResolvedValue({
      data: {
        action: "import",
        valid: true,
        message: "Looks good — 2 domains, 5 tables.",
        domain_count: 2,
        product_count: 5,
        attribute_count: 25,
        fk_count: 3,
        inferred_version: "v0.5.8",
        inferred_scope: "ecm",
        scope_settled: true,
        warnings: [],
      },
    } as Awaited<ReturnType<typeof analyzeImport>>);

    render(
      withQuery(
        <ImportModelDialog
          businessId="biz-1"
          trigger={<button type="button">Open Import</button>}
        />,
      ),
    );
    fireEvent.click(screen.getByRole("button", { name: /Open Import/i }));
    const input = await screen.findByPlaceholderText(
      /\/Volumes\/.*model\.json/i,
    );
    fireEvent.change(input, {
      target: { value: "/Volumes/main/vibes/model.json" },
    });
    const analyze = screen.getByRole("button", { name: /^Analyze$/i });
    expect(analyze).not.toBeDisabled();
    await act(async () => {
      fireEvent.click(analyze);
    });
    await waitFor(() => {
      expect(mockedAnalyze).toHaveBeenCalledWith(
        { business_id: "biz-1" },
        { volume_path: "/Volumes/main/vibes/model.json" },
      );
    });
    await waitFor(() =>
      expect(
        screen.getByRole("button", { name: /Import as new version/i }),
      ).toBeInTheDocument(),
    );
    expect(screen.getAllByText(/2 domains/i).length).toBeGreaterThan(0);
    expect(screen.getByText(/5 products/i)).toBeInTheDocument();
  });
});

describe("ImportModelDialog — execute error path", () => {
  it("surfaces the error, keeps the dialog open, and re-enables Import on a 500", async () => {
    // Step 1: analyze succeeds and returns a valid analysis envelope.
    mockedAnalyze.mockResolvedValue({
      data: {
        valid: true,
        message: "Looks good — 3 domains, 7 tables.",
        domain_count: 3,
        product_count: 7,
        attribute_count: 42,
        fk_count: 5,
        warnings: [],
        action: "import_as_is",
        inferred_version: "v1_ecm",
        inferred_scope: "ecm",
        scope_settled: true,
      },
    } as unknown as Awaited<ReturnType<typeof analyzeImport>>);
    // Step 2: execute fails with a plain Error, whose message
    // `apiErrorMessage` shows as is.
    const httpErr = Object.assign(new Error("HTTP 500: Import failed on server"), {
      status: 500,
    });
    mockedExecute.mockRejectedValue(httpErr);

    render(
      withQuery(
        <ImportModelDialog
          businessId="b-1"
          trigger={<button type="button">Open import</button>}
        />,
      ),
    );

    // Open the dialog.
    fireEvent.click(screen.getByRole("button", { name: /open import/i }));

    // Type a Volume path and analyze.
    const input = await screen.findByPlaceholderText(/\/Volumes\/catalog/);
    fireEvent.change(input, {
      target: { value: "/Volumes/cat/sch/vibes/model.json" },
    });

    const analyzeBtn = await screen.findByRole("button", { name: /Analyze/ });
    await act(async () => {
      fireEvent.click(analyzeBtn);
    });

    // Wait for analysis card to render — the Import button only appears
    // once `analysis.valid` is true.
    const importBtn = await screen.findByRole("button", {
      name: /Import as new version/i,
    });
    expect(importBtn).not.toBeDisabled();

    await act(async () => {
      fireEvent.click(importBtn);
    });

    // The error message from the rejected execute should surface.
    await waitFor(() => {
      expect(
        screen.getByText(/HTTP 500: Import failed on server/i),
      ).toBeInTheDocument();
    });

    // Dialog must stay open — both the input and the Import button should
    // still be present after the failure.
    expect(
      screen.getByPlaceholderText(/\/Volumes\/catalog/),
    ).toBeInTheDocument();

    // Import button is re-enabled (mutation no longer pending) so the
    // user can retry.
    const importBtnAfter = await screen.findByRole("button", {
      name: /Import as new version/i,
    });
    expect(importBtnAfter).not.toBeDisabled();
    expect(mockedExecute).toHaveBeenCalledTimes(1);
  });

  it("routes a 422 config_missing through the shared renderer instead of an inline banner", async () => {
    mockedAnalyze.mockResolvedValue({
      data: {
        valid: true,
        message: "Looks good - 1 domain, 2 tables.",
        domain_count: 1,
        product_count: 2,
        attribute_count: 5,
        fk_count: 0,
        warnings: [],
        action: "import_as_is",
        inferred_version: "v1_ecm",
        inferred_scope: "ecm",
        scope_settled: true,
      },
    } as unknown as Awaited<ReturnType<typeof analyzeImport>>);
    mockedExecute.mockRejectedValue(
      new ApiError(422, "Unprocessable Entity", {
        detail: {
          error: "config_missing",
          missing: [
            {
              key: "warehouse",
              label: "SQL warehouse",
              settings_url: "/settings?tab=platform",
            },
          ],
          message: "Finish setup before importing.",
        },
      }),
    );

    render(
      withQuery(
        <ImportModelDialog
          businessId="b-1"
          trigger={<button type="button">Open import</button>}
        />,
      ),
    );

    fireEvent.click(screen.getByRole("button", { name: /open import/i }));
    const input = await screen.findByPlaceholderText(/\/Volumes\/catalog/);
    fireEvent.change(input, {
      target: { value: "/Volumes/cat/sch/vibes/model.json" },
    });
    await act(async () => {
      fireEvent.click(await screen.findByRole("button", { name: /^Analyze$/i }));
    });
    const importBtn = await screen.findByRole("button", {
      name: /Import as new version/i,
    });
    await act(async () => {
      fireEvent.click(importBtn);
    });

    // Shared renderer fires; the inline "Finish setup" text does NOT render in
    // the dialog (it lives in the toast body instead).
    await waitFor(() => expect(toast.error).toHaveBeenCalledTimes(1));
    expect(screen.queryByText(/Finish setup before importing/i)).toBeNull();
  });

  it("renders the diff warning panel + blocks import until the user opts in", async () => {
    mockedAnalyze.mockResolvedValue({
      data: {
        valid: true,
        message: "Looks good - 1 domain, 2 tables.",
        domain_count: 1,
        product_count: 2,
        attribute_count: 5,
        fk_count: 0,
        warnings: [],
        action: "import_as_is",
        inferred_version: "v1_ecm",
        inferred_scope: "ecm",
        scope_settled: true,
        business_digest_diff: {
          digest: {
            business_name: "Gaming",
            industry_alignment: "Gaming",
            description: "",
            core_business_processes: "",
            orgnaization_divisions: "",
            common_business_jargons: "",
            operational_systems_of_records: "",
            industry_governing_body: "",
          },
          mismatch_fields: [
            {
              field: "business_name",
              source_value: "Gaming",
              current_value: "Gaming Reference Model",
            },
          ],
        },
      },
    } as unknown as Awaited<ReturnType<typeof analyzeImport>>);
    mockedExecute.mockResolvedValue({
      data: {
        version: 1,
        version_id: "v-1",
        domains: 1,
        products: 2,
        attributes: 5,
        fk_links: 0,
        warnings: ["Seeding the agent's registry (_metamodel) failed."],
      },
    } as unknown as Awaited<ReturnType<typeof executeImport>>);

    render(
      withQuery(
        <ImportModelDialog
          businessId="biz-mismatch"
          trigger={<button type="button">Open import</button>}
        />,
      ),
    );

    fireEvent.click(screen.getByRole("button", { name: /open import/i }));
    const input = await screen.findByPlaceholderText(/\/Volumes\/catalog/);
    fireEvent.change(input, {
      target: { value: "/Volumes/cat/sch/vibes/model.json" },
    });
    await act(async () => {
      fireEvent.click(screen.getByRole("button", { name: /^Analyze$/i }));
    });

    // Warning panel renders.
    const warning = await screen.findByTestId("business-mismatch-warning");
    expect(warning).toBeInTheDocument();
    expect(warning).toHaveTextContent(/Gaming Reference Model/);

    // Import button is disabled until checkbox is ticked.
    const importBtn = screen.getByRole("button", {
      name: /Import as new version/i,
    });
    expect(importBtn).toBeDisabled();

    const checkbox = screen.getByRole("checkbox", {
      name: /Ignore field mismatches/i,
    });
    fireEvent.click(checkbox);
    expect(importBtn).not.toBeDisabled();

    await act(async () => {
      fireEvent.click(importBtn);
    });

    await waitFor(() => {
      expect(mockedExecute).toHaveBeenCalledWith(
        { business_id: "biz-mismatch" },
        {
          volume_path: "/Volumes/cat/sch/vibes/model.json",
          accept_business_mismatch: true,
          scope: null,
        },
      );
    });
    // The response's warnings reach the user.
    await waitFor(() =>
      expect(toast.warning).toHaveBeenCalledWith("Imported with warnings", {
        description: "Seeding the agent's registry (_metamodel) failed.",
      }),
    );
  });

  it("surfaces the error and offers a retry path when analyze rejects with 500", async () => {
    const analyzeErr = new Error("HTTP 500: model.json parse failed");
    mockedAnalyze.mockRejectedValue(analyzeErr);

    render(
      withQuery(
        <ImportModelDialog
          businessId="b-1"
          trigger={<button type="button">Open import</button>}
        />,
      ),
    );

    fireEvent.click(screen.getByRole("button", { name: /open import/i }));

    const input = await screen.findByPlaceholderText(/\/Volumes\/catalog/);
    fireEvent.change(input, {
      target: { value: "/Volumes/cat/sch/vibes/bad.json" },
    });

    const analyzeBtn = await screen.findByRole("button", { name: /Analyze/ });
    await act(async () => {
      fireEvent.click(analyzeBtn);
    });

    // Error text from the rejected analyze call.
    await waitFor(() => {
      expect(
        screen.getByText(/HTTP 500: model.json parse failed/i),
      ).toBeInTheDocument();
    });

    // The "Try again" button is the recovery affordance the dialog offers.
    expect(
      screen.getByRole("button", { name: /Try again/i }),
    ).toBeInTheDocument();
    expect(mockedExecute).not.toHaveBeenCalled();
  });
});

describe("ImportModelDialog - the server's message reaches the user", () => {
  const VALID_ANALYSIS = {
    data: {
      valid: true,
      message: "Looks good - 1 domain, 2 tables.",
      domain_count: 1,
      product_count: 2,
      attribute_count: 5,
      fk_count: 0,
      warnings: [],
      action: "import_as_is",
      inferred_version: "v1_ecm",
      inferred_scope: "ecm",
      scope_settled: true,
    },
  } as unknown as Awaited<ReturnType<typeof analyzeImport>>;

  async function openAndAnalyze() {
    render(
      withQuery(
        <ImportModelDialog
          businessId="b-1"
          trigger={<button type="button">Open import</button>}
        />,
      ),
    );
    fireEvent.click(screen.getByRole("button", { name: /open import/i }));
    fireEvent.change(await screen.findByPlaceholderText(/\/Volumes\/catalog/), {
      target: { value: "/Volumes/cat/sch/vibes/model.json" },
    });
    await act(async () => {
      fireEvent.click(screen.getByRole("button", { name: /^Analyze$/i }));
    });
  }

  it.each([
    [
      "the occupied-folder 409",
      new ApiError(409, "Conflict", {
        detail: {
          error: "import_folder_occupied",
          message: "The app's folder for this business's v3 ECM, business/acme/v3/ecm in the volume meta._metamodel.vol_root, already holds files. Delete that folder in Catalog Explorer, then import again.",
          path: "/Volumes/meta/_metamodel/vol_root/business/acme/v3/ecm",
        },
      }),
      "The app's folder for this business's v3 ECM, business/acme/v3/ecm in the volume meta._metamodel.vol_root, already holds files. Delete that folder in Catalog Explorer, then import again.",
    ],
    [
      "a failed copy (502)",
      new ApiError(502, "Bad Gateway", {
        detail: "2 of the model's 5 file(s) could not be copied into the app's folder, so nothing was imported. Import again.",
      }),
      "2 of the model's 5 file(s) could not be copied into the app's folder, so nothing was imported. Import again.",
    ],
    [
      "a copy past its budget (504)",
      new ApiError(504, "Gateway Timeout", {
        detail: "The model's folder holds 900 file(s), too many to copy into the app's folder within 120 s, so nothing was imported.",
      }),
      "The model's folder holds 900 file(s), too many to copy into the app's folder within 120 s, so nothing was imported.",
    ],
    [
      "a scope refusal (400)",
      new ApiError(400, "Bad Request", {
        detail: "The import's scope is not known: choose ECM or MVM.",
      }),
      "The import's scope is not known: choose ECM or MVM.",
    ],
  ])("shows %s on execute", async (_label, err, message) => {
    mockedAnalyze.mockResolvedValue(VALID_ANALYSIS);
    mockedExecute.mockRejectedValue(err);
    await openAndAnalyze();
    const importBtn = await screen.findByRole("button", { name: /Import as new version/i });
    await act(async () => {
      fireEvent.click(importBtn);
    });
    expect(await screen.findByText(message)).toBeInTheDocument();
    expect(screen.queryByText(/^HTTP \d{3}/)).not.toBeInTheDocument();
  });

  it("shows the server's message when analyze is refused", async () => {
    mockedAnalyze.mockRejectedValue(
      new ApiError(400, "Bad Request", { detail: "No model.json at /Volumes/cat/sch/vibes/model.json." }),
    );
    await openAndAnalyze();
    expect(await screen.findByText("No model.json at /Volumes/cat/sch/vibes/model.json.")).toBeInTheDocument();
    expect(screen.queryByText(/HTTP 400/)).not.toBeInTheDocument();
  });
});
