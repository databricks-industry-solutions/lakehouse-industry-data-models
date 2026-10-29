import type { FeedbackContext, VibeInputAnchorOut } from "@/lib/api";

/**
 * Feedback is always about the model and its contents, so an Add-feedback
 * surface captures the lowest model element it is about and nothing of the
 * view (tab, column mode, filters): the agent knows the model, not the app's
 * views. Every surface builds its context here so they cannot drift.
 */

/** Tooltip of the disabled button on a version's Artifacts tab: run
 *  artifacts are files a run produced, not model content. */
export const ARTIFACTS_FEEDBACK_DISABLED_REASON =
  "Feedback is about the model and its contents, and run artifacts are not part of the model. Add feedback from any other tab.";

/** A diagram selection: a table node id (`domain.product`) or an FK edge id. */
export interface DiagramSelection {
  nodeId: string | null;
  edgeId: string | null;
}

/** The model element a page is about, by name. */
export interface FeedbackSubject {
  domain?: string | null;
  product?: string | null;
  attribute?: string | null;
  /** A relationship, as its diagram edge id. */
  relationship?: string | null;
}

/**
 * The element an input is anchored to, as a feedback subject (the
 * input-review page). Model-wide or unanchored inputs give none. A subdomain
 * anchor gives its domain: the feedback context has no subdomain axis.
 */
export function feedbackSubjectFromAnchor(
  anchor: VibeInputAnchorOut | null | undefined,
): FeedbackSubject | undefined {
  if (!anchor || anchor.level === "model_wide") return undefined;
  return {
    domain: anchor.domain_name,
    product: anchor.product_name,
    attribute: anchor.attribute_name,
    relationship: anchor.fk_edge_id,
  };
}

/**
 * Build the context for one capture. A live diagram selection (what the user
 * picked) wins over the page's subject; within the subject the lowest
 * element wins: attribute > product > relationship > domain. Nothing set is
 * the whole model.
 */
export function buildFeedbackContext({
  selection,
  subject,
}: {
  selection?: DiagramSelection | null;
  subject?: FeedbackSubject | null;
} = {}): FeedbackContext {
  if (selection?.nodeId) return { selected_node_id: selection.nodeId };
  if (selection?.edgeId) return { selected_edge_id: selection.edgeId };
  const domain = subject?.domain || null;
  if (domain && subject?.product) {
    const node = `${domain}.${subject.product}`;
    return subject.attribute
      ? { selected_node_id: node, selected_attribute: subject.attribute }
      : { selected_node_id: node };
  }
  if (subject?.relationship) return { selected_edge_id: subject.relationship };
  if (domain) return { domain_filter: domain };
  return {};
}

/**
 * Render a foreign-key edge id in human-readable form. Diagram edge ids have
 * the shape `fk:<src_domain>.<src_product>.<src_col>><tgt_domain>.<tgt_product>.<tgt_col>`;
 * this gives `<src> → <tgt>`, or the raw id when it does not parse.
 */
function formatEdgeLabel(edgeId: string): string {
  const stripped = edgeId.startsWith("fk:") ? edgeId.slice(3) : edgeId;
  const arrowIdx = stripped.indexOf(">");
  if (arrowIdx === -1) return edgeId;
  return `${stripped.slice(0, arrowIdx)} → ${stripped.slice(arrowIdx + 1)}`;
}

/** Plain description of what a captured context is about. */
export function describeFeedbackContext(ctx: FeedbackContext): string {
  if (ctx.selected_node_id) {
    return ctx.selected_attribute
      ? `${ctx.selected_node_id}.${ctx.selected_attribute}`
      : ctx.selected_node_id;
  }
  if (ctx.selected_edge_id) return `the relationship ${formatEdgeLabel(ctx.selected_edge_id)}`;
  if (ctx.domain_filter) return `the ${ctx.domain_filter} domain`;
  return "the whole model";
}
