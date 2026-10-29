/**
 * The ECM / MVM choice and the prefix note of the import dialogs
 * (`components/import/import-scope-choice.tsx`).
 */
import { beforeEach, describe, expect, it, vi } from "vitest";
import { act, fireEvent, render, screen, waitFor } from "@testing-library/react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";

vi.mock("@/lib/api", async () => {
  const actual = await vi.importActual<typeof import("@/lib/api")>("@/lib/api");
  return { ...actual, analyzeImport: vi.fn(), executeImport: vi.fn() };
});
vi.mock("sonner", () => ({
  toast: { error: vi.fn(), success: vi.fn(), warning: vi.fn(), info: vi.fn() },
}));

import { analyzeImport, executeImport, type ImportAnalyzeOut } from "@/lib/api";
import { ImportModelDialog } from "@/components/import/import-dialog";
import { importPrefixNote } from "@/components/import/import-scope-choice";

const mockedAnalyze = vi.mocked(analyzeImport);
const mockedExecute = vi.mocked(executeImport);
const PATH = "/Volumes/main/landing/agri/model.json";

function analysis(extra: Partial<ImportAnalyzeOut>): ImportAnalyzeOut {
  return {
    action: "import_as_is",
    valid: true,
    message: "Schema is supported for importing.",
    domain_count: 18,
    product_count: 0,
    attribute_count: 0,
    fk_count: 0,
    inferred_version: "modern",
    warnings: [],
    agent_output: false,
    file_schema_prefix: "",
    ...extra,
  };
}

async function analyzeWith(out: ImportAnalyzeOut) {
  mockedAnalyze.mockResolvedValue({ data: out } as Awaited<ReturnType<typeof analyzeImport>>);
  const qc = new QueryClient({ defaultOptions: { queries: { retry: false }, mutations: { retry: false } } });
  render(
    <QueryClientProvider client={qc}>
      <ImportModelDialog businessId="biz-1" trigger={<button type="button">Open Import</button>} />
    </QueryClientProvider>,
  );
  fireEvent.click(screen.getByRole("button", { name: /Open Import/i }));
  const input = await screen.findByPlaceholderText(/\/Volumes\/.*model\.json/i);
  fireEvent.change(input, { target: { value: PATH } });
  expect((input as HTMLInputElement).value).toBe(PATH);
  await act(async () => {
    fireEvent.click(screen.getByRole("button", { name: /^Analyze$/i }));
  });
  return screen.findByRole("button", { name: /Import as new version/i });
}

beforeEach(() => {
  mockedAnalyze.mockReset();
  mockedExecute.mockReset();
});

describe("ImportScopeChoice", () => {
  it("requires a choice when the file doesn't say, and sends it", async () => {
    mockedExecute.mockResolvedValue({ data: { warnings: [] } } as unknown as Awaited<ReturnType<typeof executeImport>>);
    const importBtn = await analyzeWith(analysis({ inferred_scope: null }));
    expect(importBtn).toBeDisabled();
    expect(screen.getByText("Is this model an ECM or an MVM?")).toBeInTheDocument();
    expect(screen.queryByTestId("import-prefix-note")).toBeNull();

    const mvm = screen.getByRole("radio", { name: /MVM/ }) as HTMLInputElement;
    fireEvent.click(mvm);
    expect(mvm.checked).toBe(true);
    expect(mvm.value).toBe("mvm");
    expect((screen.getByRole("radio", { name: /ECM/ }) as HTMLInputElement).checked).toBe(false);
    expect(importBtn).not.toBeDisabled();
    expect(screen.getByTestId("import-prefix-note")).toHaveTextContent(
      "The file has no schema prefix; the app names its schemas mvm_<domain> and its metric views mvm_<view>. Your file is not changed.",
    );

    await act(async () => {
      fireEvent.click(importBtn);
    });
    await waitFor(() =>
      expect(mockedExecute).toHaveBeenCalledWith(
        { business_id: "biz-1" },
        { volume_path: PATH, accept_business_mismatch: false, scope: "mvm" },
      ),
    );
  });

  it("shows no choice when the file settles the scope", async () => {
    const importBtn = await analyzeWith(analysis({ inferred_scope: "ecm", scope_settled: true }));
    expect(importBtn).not.toBeDisabled();
    expect(screen.queryByRole("radio")).toBeNull();
    expect(screen.getByTestId("import-prefix-note")).toHaveTextContent(
      "the app names its schemas ecm_<domain> and its metric views ecm_<view>",
    );
  });

  it("says agent output is imported as written", async () => {
    await analyzeWith(analysis({ inferred_scope: "mvm", scope_settled: true, agent_output: true }));
    expect(screen.getByTestId("import-prefix-note")).toHaveTextContent(
      "Agent output: imported as the agent wrote it.",
    );
  });

  it("preselects the scope the requirements suggest and lets the user change it", async () => {
    mockedExecute.mockResolvedValue({ data: { warnings: [] } } as unknown as Awaited<ReturnType<typeof executeImport>>);
    const importBtn = await analyzeWith(analysis({ inferred_scope: "ecm", scope_settled: false }));
    expect(importBtn).not.toBeDisabled();
    expect(screen.getByText(/requirements suggest ECM/)).toBeInTheDocument();
    const ecm = screen.getByRole("radio", { name: /ECM/ }) as HTMLInputElement;
    expect(ecm.checked).toBe(true);
    fireEvent.click(screen.getByRole("radio", { name: /MVM/ }));
    await act(async () => {
      fireEvent.click(importBtn);
    });
    await waitFor(() =>
      expect(mockedExecute).toHaveBeenCalledWith(
        { business_id: "biz-1" },
        { volume_path: PATH, accept_business_mismatch: false, scope: "mvm" },
      ),
    );
  });

  it("names the kept file prefix", () => {
    expect(importPrefixNote(analysis({ file_schema_prefix: "farm_" }), "ecm")).toBe(
      "The file's schemas keep its prefix farm_; the app names its metric views ecm_<view>. Your file is not changed.",
    );
  });
});
