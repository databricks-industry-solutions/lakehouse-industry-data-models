/**
 * Add-feedback wiring through the real components:
 *   - a draft (open state, text, priority) survives every tab switch, though
 *     the one button moves between the diagram toolbar (Diagram tab) and the
 *     tab bar (other tabs) and so remounts; Artifacts disables only the trigger
 *   - ModelView passes the Ontology graph's shown domain up
 *   - the input-review route hands the shell the reviewed input's element
 */
import { describe, expect, it, vi } from "vitest";
import { useState } from "react";
import { fireEvent, render, screen, waitFor } from "@testing-library/react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";

let lastShellProps: Record<string, unknown> = {};
let anchorForRoute: Record<string, unknown> = {};

vi.mock("@/components/model/model-tabs-shell", () => ({
  ModelTabsShell: (props: Record<string, unknown>) => {
    lastShellProps = props;
    return <div data-testid="shell-stub" />;
  },
}));
vi.mock("@/components/diagram/diagram-viewer", () => ({
  DiagramViewer: ({ feedbackSlot }: { feedbackSlot?: React.ReactNode }) => (
    <div data-testid="diagram-viewer-stub">{feedbackSlot}</div>
  ),
}));
vi.mock("@/components/explorer/relationship-analysis", () => ({
  RelationshipAnalysis: () => <div data-testid="relationship-analysis-stub" />,
}));
vi.mock("@/components/explorer/ontology-graph", async () => {
  const React = await import("react");
  return {
    OntologyGraph: ({ onDomainChange }: { onDomainChange?: (d: string | null) => void }) => {
      React.useEffect(() => {
        onDomainChange?.("Sales");
      }, [onDomainChange]);
      return <div data-testid="ontology-graph-stub" />;
    },
  };
});
vi.mock("@/components/feedback/feedback-list", () => ({ FeedbackList: () => <div /> }));
vi.mock("@/components/artifacts/artifacts-tab", () => ({
  ArtifactsTab: () => <div data-testid="artifacts-tab-stub" />,
}));
vi.mock("@/lib/api", async () => {
  const actual = await vi.importActual<typeof import("@/lib/api")>("@/lib/api");
  return {
    ...actual,
    useListVibeInputsSuspense: () => ({ data: [] }),
    useGetVibeInputSuspense: () => ({
      data: { id: "vi-1", text: "note", origin: "user", priority: "medium", status: "active", anchor: anchorForRoute },
    }),
  };
});
vi.mock("@tanstack/react-router", async () => {
  const actual = await vi.importActual<typeof import("@tanstack/react-router")>("@tanstack/react-router");
  return { ...actual, useNavigate: () => vi.fn() };
});

import { ModelView, type ModelViewTab } from "@/components/vibe-inputs/model-view";
import { DetailsContent } from "@/routes/_sidebar/businesses.$businessId.model.$version.$scope.inputs.$inputId";
import { AddFeedbackButton } from "@/components/feedback/add-feedback-button";
import { ARTIFACTS_FEEDBACK_DISABLED_REASON } from "@/components/feedback/feedback-context";

function qc() {
  return new QueryClient({ defaultOptions: { queries: { retry: false } } });
}

const baseProps = {
  businessId: "biz-1",
  version: "3",
  scope: "ecm",
  domains: [{ name: "Sales", division: "GTM" }],
  modelVersionId: "ver-1",
};

/** The shell's placement: one button element, in the diagram toolbar on the
 *  Diagram tab and in the tab bar elsewhere. */
function Host({ start }: { start: ModelViewTab }) {
  const [tab, setTab] = useState<ModelViewTab>(start);
  const addFeedback = (
    <AddFeedbackButton
      businessId="biz-1"
      versionId="ver-1"
      getContext={() => ({})}
      disabledReason={tab === "artifacts" ? ARTIFACTS_FEEDBACK_DISABLED_REASON : undefined}
    />
  );
  return (
    <ModelView {...baseProps} value={tab} onTabChange={setTab} feedbackSlot={addFeedback} tabBarTrailing={addFeedback} />
  );
}

function goTo(name: RegExp) {
  const tab = screen.getByRole("tab", { name });
  fireEvent.mouseDown(tab);
  fireEvent.click(tab);
}

describe("Add-feedback draft across tab switches", () => {
  it.each([
    ["diagram", /Diagram/],
    ["relationships", /Relationships/],
    ["overview", /Overview/],
  ] as const)("keeps a draft opened on %s through Relationships, Diagram and Artifacts", async (start, label) => {
    render(
      <QueryClientProvider client={qc()}>
        <Host start={start} />
      </QueryClientProvider>,
    );
    fireEvent.click(screen.getByRole("button", { name: /add feedback/i }));
    fireEvent.change(await screen.findByRole("textbox"), { target: { value: "my draft" } });
    fireEvent.click(screen.getByLabelText(/priority/i));
    fireEvent.click(await screen.findByRole("option", { name: /high/i }));

    for (const next of [/Relationships/, /Diagram/, /Artifacts/, label]) {
      goTo(next);
      expect(screen.getByRole("textbox")).toHaveValue("my draft");
      expect(screen.getByRole("combobox", { name: /priority/i })).toHaveTextContent(/high/i);
    }
    goTo(/Artifacts/);
    expect(screen.getByRole("button", { name: /add feedback/i })).toBeDisabled();
  });
});

describe("ModelView -> OntologyGraph", () => {
  it("bubbles the graph's shown domain to onOntologyDomainChange", async () => {
    const spy = vi.fn();
    render(<ModelView {...baseProps} defaultTab="ontology" onOntologyDomainChange={spy} />);
    await waitFor(() => expect(spy).toHaveBeenCalledWith("Sales"));
  });
});

describe("input-review route -> shell feedbackSubject", () => {
  function renderDetails(anchor: Record<string, unknown>) {
    anchorForRoute = anchor;
    lastShellProps = {};
    render(
      <QueryClientProvider client={qc()}>
        <DetailsContent businessId="biz-1" version="1" scope="ecm" inputId="vi-1" tab="diagram" onTabChange={vi.fn()} />
      </QueryClientProvider>,
    );
  }

  it("passes a relationship anchor as the relationship", () => {
    const edge = "fk:sales.order.c>crm.customer.id";
    renderDetails({ level: "element", fk_edge_id: edge, fk_link_id: "x", path: [] });
    expect(lastShellProps.feedbackSubject).toMatchObject({ relationship: edge });
  });

  it("passes nothing for a model-wide input", () => {
    renderDetails({ level: "model_wide", path: [] });
    expect(lastShellProps.feedbackSubject).toBeUndefined();
  });

  it("passes a product anchor as domain + product", () => {
    renderDetails({ level: "element", domain_name: "Sales", product_name: "Orders", path: [] });
    expect(lastShellProps.feedbackSubject).toMatchObject({ domain: "Sales", product: "Orders" });
  });
});
