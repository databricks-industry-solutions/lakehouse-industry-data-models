import { describe, it, expect } from "vitest";
import {
  buildFeedbackContext,
  describeFeedbackContext,
  feedbackSubjectFromAnchor,
} from "@/components/feedback/feedback-context";

describe("buildFeedbackContext — the lowest model element, no view state", () => {
  it("is the whole model with nothing in view", () => {
    expect(buildFeedbackContext()).toEqual({});
    expect(buildFeedbackContext({ selection: { nodeId: null, edgeId: null } })).toEqual({});
  });

  it("orders the page subject attribute > product > domain", () => {
    expect(
      buildFeedbackContext({ subject: { domain: "crop", product: "field", attribute: "area" } }),
    ).toEqual({ selected_node_id: "crop.field", selected_attribute: "area" });
    expect(buildFeedbackContext({ subject: { domain: "crop", product: "field" } })).toEqual({
      selected_node_id: "crop.field",
    });
    expect(buildFeedbackContext({ subject: { domain: "crop" } })).toEqual({ domain_filter: "crop" });
  });

  it("puts a relationship between the product and the domain", () => {
    const edge = "fk:crop.field.farm_id>crop.farm.id";
    expect(buildFeedbackContext({ subject: { domain: "crop", relationship: edge } })).toEqual({
      selected_edge_id: edge,
    });
    expect(
      buildFeedbackContext({ subject: { domain: "crop", product: "field", relationship: edge } }),
    ).toEqual({ selected_node_id: "crop.field" });
  });

  it("prefers a live diagram selection over the page subject", () => {
    const subject = { domain: "crop" };
    expect(
      buildFeedbackContext({ selection: { nodeId: "crop.field", edgeId: null }, subject }),
    ).toEqual({ selected_node_id: "crop.field" });
    const edgeId = "fk:crop.field.farm_id>crop.farm.id";
    expect(buildFeedbackContext({ selection: { nodeId: null, edgeId }, subject })).toEqual({
      selected_edge_id: edgeId,
    });
  });

  it("never carries view keys", () => {
    const ctx = buildFeedbackContext({
      selection: { nodeId: "crop.field", edgeId: null },
      subject: { domain: "crop", product: "field" },
    });
    for (const key of ["view_mode", "column_mode", "hide_cross_domain", "context_version"]) {
      expect(ctx).not.toHaveProperty(key);
    }
  });
});

describe("describeFeedbackContext", () => {
  it("names the element plainly", () => {
    expect(describeFeedbackContext({ selected_node_id: "crop.field" })).toBe("crop.field");
    expect(describeFeedbackContext({ domain_filter: "crop" })).toBe("the crop domain");
    expect(describeFeedbackContext({})).toBe("the whole model");
  });
});

describe("feedbackSubjectFromAnchor", () => {
  it("maps an input's anchor to its element, and none for model-wide", () => {
    expect(feedbackSubjectFromAnchor(null)).toBeUndefined();
    expect(feedbackSubjectFromAnchor({ level: "model_wide", path: [] })).toBeUndefined();
    const edge = "fk:sales.orders.cust_id>party.customers.id";
    expect(
      buildFeedbackContext({
        subject: feedbackSubjectFromAnchor({ level: "element", fk_edge_id: edge, path: [] }),
      }),
    ).toEqual({ selected_edge_id: edge });
    expect(
      buildFeedbackContext({
        subject: feedbackSubjectFromAnchor({
          level: "element", domain_name: "sales", subdomain_name: "retail", path: [],
        }),
      }),
    ).toEqual({ domain_filter: "sales" });
  });
});
