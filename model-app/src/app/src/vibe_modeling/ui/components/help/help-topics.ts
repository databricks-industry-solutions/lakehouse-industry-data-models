import type { ComponentType } from "react";
import type { OptionalFeature } from "@/lib/features";
import {
  BookOpen,
  ClipboardCheck,
  Download,
  FileUp,
  Keyboard,
  Layers,
  MessagesSquare,
  Network,
  PackageMinus,
  Rocket,
  SlidersHorizontal,
  Sparkles,
  Table,
  Trash2,
  Workflow,
} from "lucide-react";

/**
 * The in-app help catalogue. One entry per help page; the help index and the
 * "Related" footers both read from this single list so a new page is added in
 * exactly one place. `status: "ready"` pages are fully written and have a
 * body in `help-registry.tsx`; `"soon"` pages render the coming-soon template.
 */
export interface HelpTopic {
  /** Route path segment under /help (e.g. "flow" → /help/flow). */
  slug: string;
  title: string;
  description: string;
  Icon: ComponentType<{ className?: string }>;
  group: HelpGroup;
  status: "ready" | "soon";
  /** Optional install-time feature the page documents; the help index and topic page show it only once the feature is ready. */
  feature?: OptionalFeature;
}

export type HelpGroup = "Getting started" | "Runs" | "Reference";

/** The order the help index shows the groups in. */
export const HELP_GROUPS: readonly HelpGroup[] = ["Getting started", "Runs", "Reference"];

export const HELP_TOPICS: HelpTopic[] = [
  {
    slug: "flow",
    title: "How the modeling flow works",
    description: "The iterate loop end to end, from a first model to publishing to Unity Catalog.",
    Icon: Workflow,
    group: "Getting started",
    status: "ready",
  },
  {
    slug: "assessment",
    title: "Assessing a model against your data",
    description: "Check an installed model against your bronze sources, review the results, and hand off to Genie Code.",
    Icon: ClipboardCheck,
    group: "Getting started",
    status: "ready",
    feature: "assessment",
  },
  {
    slug: "taxonomy-builder",
    title: "Building a business from your domains",
    description: "Describe your company, let the model draft its domains and context, and correct the draft before you create the business.",
    Icon: Network,
    group: "Getting started",
    status: "ready",
    feature: "taxonomy",
  },
  {
    slug: "vibes",
    title: "What you can ask in a vibe",
    description: "Example requests, how to write a good one, and how the agent uses your feedback.",
    Icon: MessagesSquare,
    group: "Getting started",
    status: "ready",
  },
  {
    slug: "runs",
    title: "Run types and what they change",
    description: "Every kind of run on one page: what it changes in the model and in Unity Catalog, and what it needs.",
    Icon: Table,
    group: "Runs",
    status: "ready",
  },
  {
    slug: "run-new-base-model",
    title: "New Base Model",
    description: "Build the first model of a business from its description: an ECM, then an MVM shrunk from it.",
    Icon: Rocket,
    group: "Runs",
    status: "ready",
  },
  {
    slug: "run-vibe",
    title: "Vibe Modeling",
    description: "Change a model version from your feedback: scope, Dry Run or Full Run, and reviewing what changed.",
    Icon: Sparkles,
    group: "Runs",
    status: "ready",
  },
  {
    slug: "run-vibe-ecm-mvm",
    title: "Vibe ECM + MVM",
    description: "Change an ECM from your feedback, then shrink the result to a new MVM in the same run.",
    Icon: Layers,
    group: "Runs",
    status: "ready",
  },
  {
    slug: "run-install",
    title: "Install a version",
    description: "Create a version's schemas and tables in a catalog, and what happens when the catalog already holds one.",
    Icon: Download,
    group: "Runs",
    status: "ready",
  },
  {
    slug: "run-uninstall",
    title: "Uninstall a version",
    description: "Drop a version's schemas and tables from a catalog. The version stays in the app.",
    Icon: PackageMinus,
    group: "Runs",
    status: "ready",
  },
  {
    slug: "run-delete-version",
    title: "Delete a version",
    description: "Remove a version from the app for good: the order versions are deleted in, and what is reopened.",
    Icon: Trash2,
    group: "Runs",
    status: "ready",
  },
  {
    slug: "import",
    title: "Importing an existing model",
    description: "Bring a model.json from a Unity Catalog volume into the app as a new business or a new version.",
    Icon: FileUp,
    group: "Runs",
    status: "ready",
  },
  {
    slug: "run-parameters",
    title: "Run parameters",
    description: "Every Advanced Options field of the New Run form: its values, its default and which runs use it.",
    Icon: SlidersHorizontal,
    group: "Runs",
    status: "ready",
  },
  {
    slug: "shortcuts",
    title: "Keyboard shortcuts",
    description: "Every shortcut in the app, grouped by where it works.",
    Icon: Keyboard,
    group: "Reference",
    status: "ready",
  },
  {
    slug: "glossary",
    title: "Glossary",
    description: "Key terms: ECM, MVM, domain, product, attribute, vibe input, and more.",
    Icon: BookOpen,
    group: "Reference",
    status: "soon",
  },
];

export function getHelpTopic(slug: string): HelpTopic | undefined {
  return HELP_TOPICS.find((t) => t.slug === slug);
}

/** Whether the topic's optional feature (if any) is ready: the rule the help index lists by and the header Help link follows. */
export function helpTopicFeatureReady(topic: HelpTopic, featureReady: Record<OptionalFeature, boolean>): boolean {
  return !topic.feature || featureReady[topic.feature];
}
