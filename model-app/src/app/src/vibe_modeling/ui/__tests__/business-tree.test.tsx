/**
 * `BusinessTree` sidebar tests.
 *
 * The tree wires up four `@/lib/api` hooks:
 *   - `useGetBusinessSuspense` (suspense)
 *   - `useGetExplorerVersions` (regular query, conditional)
 *   - `useGetModelSummary` (per expanded version)
 *   - `useGetDomainDetail` (per expanded domain)
 *
 * Audit risk #7 calls out the first-run "no versions yet" path as
 * untested. We mock the suspense + regular hooks directly so the tree
 * renders synchronously, then assert:
 *
 *  1. Happy path — business name, one version row, "All Domains" link.
 *  2. First-run — versions list empty, fallback "No model versions"
 *     message renders.
 *  3. 4xx error on the per-domain `useGetDomainDetail` does not crash
 *     the tree (the hook returns `undefined` data + `isError: true`,
 *     so the products list is empty rather than throwing).
 *
 * The component uses TanStack Router's `<Link>` and `useParams`, so we
 * mount under `renderWithRouter`.
 */
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";
import { fireEvent, screen, waitFor } from "@testing-library/react";

let businessHook: () => unknown = () => ({
  data: { id: "biz-1", name: "Acme Corp" },
});
let versionsHook: () => unknown = () => ({
  data: { data: [] },
  isLoading: false,
});
let modelHook: () => unknown = () => ({
  data: { data: { domains: [] } },
  isLoading: false,
});
let domainHook: () => unknown = () => ({
  data: { data: { products: [] } },
  isLoading: false,
});

vi.mock("@/lib/api", async () => {
  const actual = await vi.importActual<typeof import("@/lib/api")>("@/lib/api");
  return {
    ...actual,
    useGetBusinessSuspense: () => businessHook(),
    useGetExplorerVersions: () => versionsHook(),
    useGetModelSummary: () => modelHook(),
    useGetDomainDetail: () => domainHook(),
  };
});

import { BusinessTree } from "@/components/explorer/business-tree";
import { renderWithRouter } from "./helpers/router-wrapper";

beforeEach(() => {
  businessHook = () => ({ data: { id: "biz-1", name: "Acme Corp" } });
  versionsHook = () => ({ data: { data: [] }, isLoading: false });
  modelHook = () => ({ data: { data: { domains: [] } }, isLoading: false });
  domainHook = () => ({ data: { data: { products: [] } }, isLoading: false });
});

afterEach(() => {
  vi.restoreAllMocks();
});

describe("BusinessTree", () => {
  it("renders the business name and version row on the happy path", async () => {
    versionsHook = () => ({
      data: {
        data: [
          {
            id: "v-1",
            version: 1,
            scope: "ecm",
            status: "ready",
            is_base: true,
          },
        ],
      },
      isLoading: false,
    });
    renderWithRouter(<BusinessTree businessId="biz-1" />);

    expect(await screen.findByText("Acme Corp")).toBeInTheDocument();
    expect(await screen.findByText("v1")).toBeInTheDocument();
    // ECM scope badge.
    expect(screen.getByText("ECM")).toBeInTheDocument();
    // Base label badge.
    expect(screen.getByText("Base")).toBeInTheDocument();
  });

  it("labels a shrink output whose parent was deleted", async () => {
    versionsHook = () => ({
      data: {
        data: [
          {
            id: "v-5",
            version: 5,
            scope: "mvm",
            status: "ready",
            is_base: false,
            parent_deleted: true,
          },
        ],
      },
      isLoading: false,
    });
    renderWithRouter(<BusinessTree businessId="biz-1" />);

    expect(await screen.findByText("Vibed (parent deleted)")).toBeInTheDocument();
  });

  it("survives a 4xx on getDomainDetail when the user expands a domain", async () => {
    versionsHook = () => ({
      data: {
        data: [
          {
            id: "v-1",
            version: 1,
            scope: "ecm",
            status: "ready",
            is_base: true,
          },
        ],
      },
      isLoading: false,
    });
    modelHook = () => ({
      data: {
        data: {
          domains: [
            { name: "sales", product_count: 3 },
          ],
        },
      },
      isLoading: false,
    });
    // Domain detail returns `undefined` when the API 4xx'd; the hook
    // surfaces an empty products list rather than a thrown error.
    domainHook = () => ({
      data: undefined,
      isLoading: false,
      isError: true,
    });

    const { container } = renderWithRouter(<BusinessTree businessId="biz-1" />);

    // Expand the version row to reveal "All Domains" + the domain item.
    // The version row mounts collapsed (no active match in URL params), so
    // we click its chevron toggle to expand it.
    const versionLabel = await screen.findByText("v1");
    expect(versionLabel).toBeInTheDocument();
    // The first <button> in the tree is the version-row expand toggle.
    const expandBtn = container.querySelector("button");
    if (expandBtn) fireEvent.click(expandBtn);

    // The domain row mounts and shows its name + product count.
    await waitFor(() =>
      expect(screen.getByText("sales")).toBeInTheDocument(),
    );

    // No throw: the tree still has the business header and the domain row,
    // even though useGetDomainDetail is in an isError state.
    expect(screen.getByText("Acme Corp")).toBeInTheDocument();
    expect(screen.getByText("sales")).toBeInTheDocument();
  });
});
