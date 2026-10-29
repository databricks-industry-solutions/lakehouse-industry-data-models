/**
 * The deployment catalog picker offers only catalogs the app can use for the
 * run (design 4.1): unusable ones are hidden, unchecked ones marked, a saved
 * or typed name is checked and a refusal shows the GRANT to ask for.
 */
import { beforeEach, describe, expect, it, vi } from "vitest";
import { act, fireEvent, render, screen, waitFor, within } from "@testing-library/react";
import { useState } from "react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";

import type { CatalogCapabilityOut } from "@/lib/api";
import { getCatalogCapabilities, listCatalogs } from "@/lib/api";
import fixture from "../../../../../../tests/fixtures/catalog_capability_rule_fixture.json";
import {
  AUTO_CHECK_BUDGET,
  CAPABILITY_CHECK_CAP,
  DeploymentCatalogPicker,
  type CatalogOption,
} from "@/components/runs/deployment-catalog-picker";

vi.mock("@/lib/api", async (importOriginal) => ({
  ...(await importOriginal<typeof import("@/lib/api")>()),
  getCatalogCapabilities: vi.fn(),
  listCatalogs: vi.fn(),
}));

const capsMock = vi.mocked(getCatalogCapabilities);
const listMock = vi.mocked(listCatalogs);

const FIX = "GRANT CREATE SCHEMA ON CATALOG `no_create` TO `app-sp`;";

let table: Record<string, Omit<CatalogCapabilityOut, "name">>;

function answer() {
  capsMock.mockImplementation(async (params) => ({
    data: (params?.names ?? []).map((name) => ({
      name,
      ...(table[name] ?? { create_schema: false, use_metamodel: false }),
    })),
  }));
}

beforeEach(() => {
  capsMock.mockReset();
  listMock.mockReset();
  table = {
    good: { create_schema: true, use_metamodel: true },
    no_create: { create_schema: false, use_metamodel: true, create_schema_fix: FIX },
    unknown: { create_schema: null, use_metamodel: null },
  };
  answer();
});

const CATALOGS: CatalogOption[] = [{ name: "good" }, { name: "no_create" }, { name: "unknown" }];

function Harness({
  initial = "",
  catalogs = CATALOGS,
  createsSchemas,
  listFailed = false,
  fetchList = false,
}: {
  initial?: string;
  catalogs?: CatalogOption[];
  createsSchemas?: boolean;
  listFailed?: boolean;
  fetchList?: boolean;
}) {
  const [value, setValue] = useState(initial);
  return (
    <>
      <DeploymentCatalogPicker
        value={value}
        onChange={setValue}
        catalogsOverride={listFailed || fetchList ? undefined : catalogs}
        errorOverride={listFailed || undefined}
        loadingOverride={listFailed ? false : undefined}
        createsSchemas={createsSchemas}
      />
      <output data-testid="value">{value}</output>
    </>
  );
}

function renderPicker(props: Parameters<typeof Harness>[0] = {}) {
  const qc = new QueryClient({ defaultOptions: { queries: { retry: false } } });
  return render(
    <QueryClientProvider client={qc}>
      <Harness {...props} />
    </QueryClientProvider>,
  );
}

function openPopover() {
  act(() => {
    fireEvent.click(screen.getByRole("combobox"));
  });
}

function optionLabels(): string[] {
  return screen
    .queryAllByRole("option")
    .filter((el) => el.getAttribute("data-testid") !== "deployment-catalog-use-custom")
    .map((el) => el.textContent?.trim() ?? "");
}

async function settled() {
  await waitFor(() => expect(capsMock).toHaveBeenCalled());
  // The list check and the merge land on the next renders.
  await act(async () => {
    await new Promise((r) => setTimeout(r, 0));
  });
}

describe("DeploymentCatalogPicker access checks", () => {
  it("hides catalogs the app can't create schemas in and marks unchecked ones", async () => {
    renderPicker();
    await settled();
    openPopover();
    await waitFor(() => expect(optionLabels()).toEqual(["good", "unknownCouldn't check the app's access"]));
  });

  it("offers a catalog without CREATE SCHEMA for a run that creates no schemas", async () => {
    renderPicker({ createsSchemas: false });
    await settled();
    openPopover();
    await waitFor(() => expect(optionLabels()).toContain("no_create"));
  });

  it("checks the saved value and shows the GRANT to ask for", async () => {
    renderPicker({ initial: "no_create" });
    const alert = await screen.findByTestId("deployment-catalog-refused");
    expect(within(alert).getByText(/can't create schemas in no_create/)).toBeInTheDocument();
    expect(within(alert).getByText(FIX)).toBeInTheDocument();
    expect(capsMock.mock.calls[0][0]?.names?.[0]).toBe("no_create");
  });

  it("Check again asks the server again, and a new grant clears the refusal", async () => {
    renderPicker({ initial: "no_create" });
    const alert = await screen.findByTestId("deployment-catalog-refused");
    const calls = capsMock.mock.calls.length;
    table.no_create = { create_schema: true, use_metamodel: true };
    act(() => {
      fireEvent.click(within(alert).getByRole("button", { name: "Check again" }));
    });
    await waitFor(() => expect(screen.queryByTestId("deployment-catalog-refused")).not.toBeInTheDocument());
    expect(capsMock.mock.calls.length).toBeGreaterThan(calls);
    expect(capsMock.mock.calls.at(-1)?.[0]?.names).toEqual(["no_create"]);
  });

  it("checks a typed name live", async () => {
    renderPicker();
    await settled();
    openPopover();
    act(() => {
      fireEvent.change(screen.getByPlaceholderText(/Filter or type a new catalog name/i), {
        target: { value: "typed_cat" },
      });
    });
    act(() => {
      fireEvent.click(screen.getByTestId("deployment-catalog-use-custom"));
    });
    expect(screen.getByTestId("value")).toHaveTextContent("typed_cat");
    const alert = await screen.findByTestId("deployment-catalog-refused");
    expect(within(alert).getByText("typed_cat may not exist, or the app can't see it.")).toBeInTheDocument();
    expect(within(alert).queryByText(/can't create schemas/)).not.toBeInTheDocument();
    expect(capsMock.mock.calls.some((c) => c[0]?.names?.includes("typed_cat"))).toBe(true);
  });

  it("marks an unchecked saved value without blocking it", async () => {
    renderPicker({ initial: "unknown" });
    expect(await screen.findByTestId("deployment-catalog-unchecked")).toHaveTextContent(
      "Couldn't check the app's access to unknown.",
    );
    expect(screen.queryByTestId("deployment-catalog-refused")).not.toBeInTheDocument();
  });

  it("asks about at most the per-call cap, the saved value first", async () => {
    const many = Array.from({ length: 40 }, (_, i) => ({ name: `cat_${String(i).padStart(2, "0")}` }));
    renderPicker({ initial: "zz_saved", catalogs: many });
    await waitFor(() => expect(capsMock).toHaveBeenCalled());
    const names = capsMock.mock.calls[0][0]?.names ?? [];
    expect(names).toHaveLength(CAPABILITY_CHECK_CAP);
    expect(names[0]).toBe("zz_saved");
  });

  it("checks only the first page shown, not the whole list", async () => {
    const many = Array.from({ length: 60 }, (_, i) => ({ name: `cat_${String(i).padStart(2, "0")}` }));
    for (const c of many) table[c.name] = { create_schema: true, use_metamodel: true };
    renderPicker({ catalogs: many });
    await settled();
    await act(async () => {
      await new Promise((r) => setTimeout(r, 400));
    });
    expect(capsMock).toHaveBeenCalledTimes(1);
    expect(capsMock.mock.calls[0][0]?.names).toHaveLength(CAPABILITY_CHECK_CAP - 1);
  });

  it("checks the matches when the user filters", async () => {
    const many = Array.from({ length: 60 }, (_, i) => ({ name: `cat_${String(i).padStart(2, "0")}` }));
    for (const c of many) table[c.name] = { create_schema: true, use_metamodel: true };
    renderPicker({ catalogs: many });
    await settled();
    openPopover();
    act(() => {
      fireEvent.change(screen.getByPlaceholderText(/Filter or type a new catalog name/i), {
        target: { value: "cat_5" },
      });
    });
    await waitFor(() => expect(capsMock).toHaveBeenCalledTimes(2));
    expect(capsMock.mock.calls[1][0]?.names).toEqual(
      ["cat_50", "cat_51", "cat_52", "cat_53", "cat_54", "cat_55", "cat_56", "cat_57", "cat_58", "cat_59"],
    );
  });

  it("does not ask about a catalog the list already reports as checked", async () => {
    renderPicker({ catalogs: [{ name: "cached", can_create_schema: true }, { name: "good" }] });
    await waitFor(() => expect(capsMock).toHaveBeenCalled());
    expect(capsMock.mock.calls.flatMap((c) => c[0]?.names ?? [])).not.toContain("cached");
  });

  it("a failed check marks the names unchecked and is not retried in a loop", async () => {
    capsMock.mockRejectedValue(new Error("502"));
    renderPicker({ initial: "good" });
    expect(await screen.findByTestId("deployment-catalog-unchecked")).toBeInTheDocument();
    await act(async () => {
      await new Promise((r) => setTimeout(r, 400));
    });
    expect(capsMock).toHaveBeenCalledTimes(1);
  });
  it("the per-call cap is the backend's", () => {
    expect(CAPABILITY_CHECK_CAP).toBe(fixture.check_cap);
  });

  it("stops refilling after the budget when most catalogs are unusable", async () => {
    const many = Array.from({ length: 301 }, (_, i) => ({ name: `bad_${String(i).padStart(3, "0")}` }));
    table = {};
    renderPicker({ catalogs: many });
    await waitFor(() => expect(capsMock).toHaveBeenCalled());
    await act(async () => {
      await new Promise((r) => setTimeout(r, 600));
    });
    const asked = capsMock.mock.calls.flatMap((c) => c[0]?.names ?? []);
    expect(asked.length).toBeLessThanOrEqual(AUTO_CHECK_BUDGET);
    expect(capsMock.mock.calls.length).toBeLessThanOrEqual(3);
  });

  it("a new filter text gets its own checks after the budget is spent", async () => {
    const many = Array.from({ length: 120 }, (_, i) => ({ name: `bad_${String(i).padStart(3, "0")}` }));
    table = { bad_119: { create_schema: true, use_metamodel: true } };
    renderPicker({ catalogs: many });
    await waitFor(() =>
      expect(capsMock.mock.calls.flatMap((c) => c[0]?.names ?? [])).toHaveLength(AUTO_CHECK_BUDGET),
    );
    await act(async () => {
      await new Promise((r) => setTimeout(r, 400));
    });
    const before = capsMock.mock.calls.length;
    openPopover();
    act(() => {
      fireEvent.change(screen.getByPlaceholderText(/Filter or type a new catalog name/i), {
        target: { value: "bad_119" },
      });
    });
    await waitFor(() => expect(capsMock.mock.calls.length).toBe(before + 1));
    expect(capsMock.mock.calls.at(-1)?.[0]?.names).toEqual(["bad_119"]);
    await waitFor(() => expect(optionLabels()).toEqual(["bad_119"]));
  });

  it("Enter picks the typed name when the highlighted option was hidden by a check", async () => {
    renderPicker();
    openPopover();
    act(() => {
      fireEvent.change(screen.getByPlaceholderText(/Filter or type a new catalog name/i), {
        target: { value: "no_cre" },
      });
    });
    await waitFor(() => expect(optionLabels()).toEqual([]));
    act(() => {
      fireEvent.keyDown(screen.getByPlaceholderText(/Filter or type a new catalog name/i), { key: "Enter" });
    });
    expect(screen.getByTestId("value")).toHaveTextContent("no_cre");
  });

  it("in the plain-input fallback, slow typing checks only once it pauses", async () => {
    renderPicker({ listFailed: true });
    const input = screen.getByTestId("deployment-catalog-fallback-input");
    for (const v of ["n", "no", "no_", "no_c"]) {
      act(() => {
        fireEvent.change(input, { target: { value: v } });
      });
      await act(async () => {
        await new Promise((r) => setTimeout(r, 450));
      });
    }
    await waitFor(() => expect(capsMock).toHaveBeenCalledTimes(1), { timeout: 2000 });
    expect(capsMock.mock.calls[0][0]?.names).toEqual(["no_c"]);
  });

  it("Check again disables its button and says Checking… until the answer lands", async () => {
    renderPicker({ initial: "no_create" });
    const alert = await screen.findByTestId("deployment-catalog-refused");
    let answerNow: (() => void) | undefined;
    capsMock.mockImplementationOnce(
      (params) =>
        new Promise((resolve) => {
          answerNow = () =>
            resolve({
              data: (params?.names ?? []).map((name) => ({ name, create_schema: true, use_metamodel: true })),
            });
        }),
    );
    act(() => {
      fireEvent.click(within(alert).getByRole("button", { name: "Check again" }));
    });
    const busy = await within(screen.getByTestId("deployment-catalog-refused")).findByRole("button", {
      name: "Checking…",
    });
    expect(busy).toBeDisabled();
    expect(screen.getByTestId("deployment-catalog-refused")).toHaveTextContent(FIX);
    await waitFor(() => expect(answerNow).toBeDefined());
    await act(async () => {
      answerNow?.();
    });
    await waitFor(() => expect(screen.queryByTestId("deployment-catalog-refused")).not.toBeInTheDocument());
  });

  it("an unchecked value shows Checking… while Check again is pending", async () => {
    renderPicker({ initial: "unknown" });
    const note = await screen.findByTestId("deployment-catalog-unchecked");
    capsMock.mockImplementationOnce(() => new Promise(() => {}));
    act(() => {
      fireEvent.click(within(note).getByRole("button", { name: "Check again" }));
    });
    expect(await within(note).findByRole("button", { name: "Checking…" })).toBeDisabled();
  });

  it("sends one request on mount for a preset value once the listing arrives", async () => {
    listMock.mockImplementation(
      () => new Promise((resolve) => setTimeout(() => resolve({ data: CATALOGS } as never), 30)),
    );
    renderPicker({ initial: "good", fetchList: true });
    await waitFor(() => expect(capsMock).toHaveBeenCalled());
    await act(async () => {
      await new Promise((r) => setTimeout(r, 500));
    });
    expect(capsMock).toHaveBeenCalledTimes(1);
    expect(capsMock.mock.calls[0][0]?.names).toEqual(["good", "no_create", "unknown"]);
  });

  it("still checks a preset value when the listing fails", async () => {
    listMock.mockRejectedValue(new Error("500"));
    renderPicker({ initial: "good", fetchList: true });
    await waitFor(() => expect(capsMock).toHaveBeenCalledTimes(1));
    expect(capsMock.mock.calls[0][0]?.names).toEqual(["good"]);
    expect(screen.getByTestId("deployment-catalog-fallback-input")).toHaveValue("good");
  });

  it("an unchecked value offers Check again", async () => {
    renderPicker({ initial: "unknown" });
    const note = await screen.findByTestId("deployment-catalog-unchecked");
    table.unknown = { create_schema: true, use_metamodel: true };
    act(() => {
      fireEvent.click(within(note).getByRole("button", { name: "Check again" }));
    });
    await waitFor(() => expect(screen.queryByTestId("deployment-catalog-unchecked")).not.toBeInTheDocument());
  });

  it("merges GRANTs on the same securable into one line", async () => {
    table.nopriv = {
      create_schema: false,
      use_metamodel: false,
      create_schema_fix: "GRANT CREATE SCHEMA, USE CATALOG ON CATALOG `nopriv` TO `app-sp`;",
      use_metamodel_fix:
        "GRANT USE CATALOG ON CATALOG `nopriv` TO `app-sp`;\nGRANT SELECT ON SCHEMA `nopriv`.`_metamodel` TO `app-sp`;",
    };
    renderPicker({ initial: "nopriv" });
    const alert = await screen.findByTestId("deployment-catalog-refused");
    expect(alert.querySelector("pre")?.textContent).toBe(
      "GRANT CREATE SCHEMA, USE CATALOG ON CATALOG `nopriv` TO `app-sp`;\nGRANT SELECT ON SCHEMA `nopriv`.`_metamodel` TO `app-sp`;",
    );
  });
});
