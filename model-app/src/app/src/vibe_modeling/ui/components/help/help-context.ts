import type { OptionalFeature } from "@/lib/features";
import { formOperationFromParam, helpSlug } from "@/lib/operations";
import { getHelpTopic, helpTopicFeatureReady, type HelpTopic } from "@/components/help/help-topics";

/** The part of the current URL that picks a help topic. */
export interface HelpLocation {
  pathname: string;
  search?: Record<string, unknown>;
}

interface HelpContextRoute {
  /** Route path as in `routes/_sidebar/`; `$name` matches any one segment. A path covers every page beneath it. */
  path: string;
  /** The help topic slug, or a function of the URL search. */
  topic: string | ((search: Record<string, unknown>) => string);
}

/**
 * The top-level help topic of each area of the app. The most specific path
 * wins, so a page not listed here and not beneath a listed path (home,
 * businesses, industries, settings, profile) gets the main help page. Add a
 * page by adding a line.
 */
export const HELP_CONTEXT_ROUTES: readonly HelpContextRoute[] = [
  { path: "/businesses/$businessId/explorer", topic: "flow" },
  { path: "/businesses/$businessId/model", topic: "flow" },
  { path: "/businesses/$businessId/model/$version/$scope/inputs", topic: "vibes" },
  { path: "/businesses/$businessId/runs", topic: "runs" },
  { path: "/businesses/$businessId/runs/new", topic: runFormTopic },
  { path: "/businesses/$businessId/assessments", topic: "assessment" },
  { path: "/businesses/new/from-domains", topic: "taxonomy-builder" },
];

/** The New Run form's page for the operation its URL names, else the run types page. */
function runFormTopic(search: Record<string, unknown>): string {
  const op = typeof search.operationType === "string" ? formOperationFromParam(search.operationType) : "";
  return op ? helpSlug(op) : "runs";
}

function segments(path: string): string[] {
  return path.split("/").filter(Boolean);
}

/** How many leading segments of `pathname` the route covers (literal segments count double), or -1 when it does not cover it. */
function specificity(route: HelpContextRoute, pathSegments: string[]): number {
  const own = segments(route.path);
  if (own.length > pathSegments.length) return -1;
  let score = 0;
  for (let i = 0; i < own.length; i++) {
    if (own[i].startsWith("$")) score += 1;
    else if (own[i] === pathSegments[i]) score += 2;
    else return -1;
  }
  return score;
}

/**
 * The help topic for the page at `location`: the topic of the most specific
 * route in `HELP_CONTEXT_ROUTES`, only when that topic is ready and its
 * optional feature (if any) is ready, the same rule the help index lists by.
 * `undefined` means the main help page.
 */
export function helpTopicForRoute(
  location: HelpLocation,
  featureReady: Record<OptionalFeature, boolean>,
): HelpTopic | undefined {
  const pathSegments = segments(location.pathname);
  let best: HelpContextRoute | undefined;
  let bestScore = -1;
  for (const route of HELP_CONTEXT_ROUTES) {
    const score = specificity(route, pathSegments);
    if (score > bestScore) {
      best = route;
      bestScore = score;
    }
  }
  if (!best) return undefined;
  const slug = typeof best.topic === "string" ? best.topic : best.topic(location.search ?? {});
  const topic = getHelpTopic(slug);
  if (!topic || topic.status !== "ready" || !helpTopicFeatureReady(topic, featureReady)) return undefined;
  return topic;
}
