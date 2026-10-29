/**
 * Vibe-Input review route ($inputId) domain-navigate wiring (item 3B,
 * 0.6.6).
 *
 * This review surface has no domain picker, but its focal diagram can still show a RELATED domain group with a clickable
 * header. Item 3B deleted `DiagramViewer`'s internal domain-state fallback,
 * so this route must supply `onDomainNavigate` (routing to the clicked
 * domain's own page) and `showDomainSelect={false}` (no free-floating
 * "jump anywhere" picker on a single-input review) to keep that click
 * working instead of going inert.
 */
import { describe, expect, it, vi } from "vitest";
import { render } from "@testing-library/react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";

const navigateSpy = vi.fn();

let lastShellProps: Record<string, unknown> = {};
vi.mock("@/components/model/model-tabs-shell", () => ({
  ModelTabsShell: (props: Record<string, unknown>) => {
    lastShellProps = props;
    return <div data-testid="shell-stub" />;
  },
}));

vi.mock("@/lib/api", async () => {
  const actual = await vi.importActual<typeof import("@/lib/api")>("@/lib/api");
  return {
    ...actual,
    useGetVibeInputSuspense: () => ({
      data: {
        id: "vi-1",
        text: "note",
        origin: "user",
        priority: "medium",
        status: "active",
        anchor: { level: "element", domain_name: "Sales", path: ["Domain: Sales"] },
      },
    }),
  };
});

vi.mock("@tanstack/react-router", async () => {
  const actual = await vi.importActual<typeof import("@tanstack/react-router")>(
    "@tanstack/react-router",
  );
  return {
    ...actual,
    useNavigate: () => navigateSpy,
  };
});

import { DetailsContent } from "@/routes/_sidebar/businesses.$businessId.model.$version.$scope.inputs.$inputId";

const baseProps = {
  businessId: "biz-1",
  version: "1",
  scope: "ecm",
  inputId: "vi-1",
  tab: "diagram" as const,
  onTabChange: vi.fn(),
};

function renderDetails() {
  const qc = new QueryClient({ defaultOptions: { queries: { retry: false } } });
  return render(
    <QueryClientProvider client={qc}>
      <DetailsContent {...baseProps} />
    </QueryClientProvider>,
  );
}

describe("Input-review route - domain-navigate wiring (item 3B)", () => {
  it("passes showDomainSelect=false to the shell", () => {
    lastShellProps = {};
    renderDetails();
    expect(lastShellProps.showDomainSelect).toBe(false);
  });

  it("wires onDomainNavigate to route to the clicked domain's own page", () => {
    navigateSpy.mockClear();
    lastShellProps = {};
    renderDetails();
    expect(typeof lastShellProps.onDomainNavigate).toBe("function");
    (lastShellProps.onDomainNavigate as (d: string | null) => void)("Inventory");
    expect(navigateSpy).toHaveBeenCalledWith(
      expect.objectContaining({
        to: "/businesses/$businessId/model/$version/$scope/$domainName",
        params: { businessId: "biz-1", version: "1", scope: "ecm", domainName: "Inventory" },
        search: { tab: "diagram" },
      }),
    );
  });

  it("is a no-op when called with null", () => {
    navigateSpy.mockClear();
    lastShellProps = {};
    renderDetails();
    (lastShellProps.onDomainNavigate as (d: string | null) => void)(null);
    expect(navigateSpy).not.toHaveBeenCalled();
  });
});
