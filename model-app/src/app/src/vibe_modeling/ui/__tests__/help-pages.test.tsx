/**
 * Help center: the index, the written pages, the registry dispatch of
 * `help.$topic.tsx`, the Runs group and its pages (one per run intent, each
 * with the same four headings), and the shared coming-soon template. Fails on
 * any DOM-nesting warning (key caps and links sit inside text runs).
 */
import { describe, it, expect, vi } from "vitest";
import { ReactNode } from "react";
import { render, screen, within } from "@testing-library/react";
import {
  createMemoryHistory,
  createRootRoute,
  createRoute,
  createRouter,
  Outlet,
  RouterProvider,
} from "@tanstack/react-router";

vi.mock("@/lib/api", async (importOriginal) => ({
  ...(await importOriginal<typeof import("@/lib/api")>()),
  useGetRunChangeReviewConfig: () => ({ data: { data: { enabled: true } } }),
  useGetAssessConfig: () => ({ data: { data: { installed: true, ready: true } } }),
  useGetTaxonomyConfig: () => ({ data: { data: { installed: true, ready: true, model_service: "a.b.c" } } }),
  useGetAgentConfig: () => ({
    data: { runtime_budget_hours: 6, runtime_budget_min_hours: 4, runtime_budget_max_hours: 48 },
  }),
}));

import { Intent } from "@/lib/api";
import { HelpIndexPage } from "@/routes/_sidebar/help.index";
import { HelpTopicBody } from "@/routes/_sidebar/help.$topic";
import {
  FlowContent,
  ShortcutsContent,
  ComingSoonContent,
  AssessmentContent,
  TaxonomyBuilderContent,
  VibesContent,
  VIBE_EXAMPLES,
} from "@/components/help/help-content";
import { HELP_CONTENT } from "@/components/help/help-registry";
import { RUN_PAGE_HEADINGS, RUN_TYPE_ROWS } from "@/components/help/run-help-content";
import { ASSESS_MODEL } from "@/lib/assessment";
import { HELP_GROUPS, HELP_TOPICS, getHelpTopic } from "@/components/help/help-topics";
import { helpSlug, INTENT_HELP_SLUGS } from "@/lib/operations";
import { useStrictConsole } from "./helpers/strict-console";

function withRouter(ui: ReactNode) {
  const rootRoute = createRootRoute({ component: () => <Outlet /> });
  const subject = createRoute({
    getParentRoute: () => rootRoute,
    path: "/",
    component: () => <>{ui}</>,
  });
  const helpIndex = createRoute({
    getParentRoute: () => rootRoute,
    path: "/help",
    component: () => <div data-testid="help-index-stub" />,
  });
  const helpTopic = createRoute({
    getParentRoute: () => rootRoute,
    path: "/help/$topic",
    component: () => <div data-testid="help-topic-stub" />,
  });
  const settings = createRoute({
    getParentRoute: () => rootRoute,
    path: "/settings",
    component: () => <div data-testid="settings-stub" />,
  });
  const router = createRouter({
    routeTree: rootRoute.addChildren([subject, helpIndex, helpTopic, settings]),
    history: createMemoryHistory({ initialEntries: ["/"] }),
  });
  return <RouterProvider router={router} />;
}

async function renderTopic(slug: string) {
  render(withRouter(<HelpTopicBody slug={slug} />));
  return screen.findByRole("heading", { level: 1 });
}

const RUN_PAGES = HELP_TOPICS.filter((t) => t.group === "Runs" && t.slug !== "runs" && t.slug !== "run-parameters");

describe("Help index", () => {
  const dom = useStrictConsole();

  it("lists every topic under its group, marking unwritten ones", async () => {
    render(withRouter(<HelpIndexPage />));
    await screen.findByText(HELP_TOPICS[0].title);
    for (const topic of HELP_TOPICS) {
      expect(screen.getByText(topic.title)).toBeInTheDocument();
    }
    for (const group of HELP_GROUPS) {
      expect(screen.getByRole("heading", { name: group })).toBeInTheDocument();
    }
    const soon = HELP_TOPICS.filter((t) => t.status === "soon").length;
    expect(soon).toBeGreaterThanOrEqual(1);
    expect(screen.getAllByText(/coming soon/i)).toHaveLength(soon);
    expect(dom.messages).toEqual([]);
  });

  it("shows the Runs group between Getting started and Reference", () => {
    expect(HELP_GROUPS).toEqual(["Getting started", "Runs", "Reference"]);
    const runs = HELP_TOPICS.filter((t) => t.group === "Runs").map((t) => t.slug);
    expect(runs).toEqual([
      "runs",
      "run-new-base-model",
      "run-vibe",
      "run-vibe-ecm-mvm",
      "run-install",
      "run-uninstall",
      "run-delete-version",
      "import",
      "run-parameters",
    ]);
  });
});

describe("Help page width", () => {
  const CAPS = /(^|\s)(max-w-\S+|mx-auto)(\s|$)/;

  function expectUncapped(root: HTMLElement) {
    expect(root).toHaveClass("p-6");
    expect(root.className).not.toMatch(CAPS);
    expect(root.querySelectorAll('[class*="max-w-"], [class*="mx-auto"]')).toHaveLength(0);
  }

  it("lets the index fill the window like the other pages", async () => {
    render(withRouter(<HelpIndexPage />));
    expectUncapped(await screen.findByTestId("help-page"));
  });

  it.each([...HELP_TOPICS.map((t) => t.slug), "nope"])("lets the %s page fill the window", async (slug) => {
    render(withRouter(<HelpTopicBody slug={slug} />));
    expectUncapped(await screen.findByTestId("help-page"));
  });
});

describe("Registry dispatch", () => {
  const dom = useStrictConsole();

  it("has a body for exactly the ready topics", () => {
    const ready = HELP_TOPICS.filter((t) => t.status === "ready").map((t) => t.slug).sort();
    expect(Object.keys(HELP_CONTENT).sort()).toEqual(ready);
  });

  it.each(HELP_TOPICS.filter((t) => t.status === "ready").map((t) => [t.slug, t.title]))(
    "renders the registered page for %s",
    async (slug, title) => {
      expect(await renderTopic(slug)).toHaveTextContent(title);
      expect(dom.messages).toEqual([]);
    },
  );

  it("renders the coming-soon template for a known topic without a body", async () => {
    const soon = HELP_TOPICS.find((t) => t.status === "soon")!;
    expect(await renderTopic(soon.slug)).toHaveTextContent(soon.title);
    expect(screen.getByText(/This page is coming soon/)).toBeInTheDocument();
  });

  it("renders a not-found page for an unknown slug, including object keys", async () => {
    for (const slug of ["no-such-topic", "constructor"]) {
      const { unmount } = render(withRouter(<HelpTopicBody slug={slug} />));
      expect(await screen.findByRole("heading", { level: 1 })).toHaveTextContent("Topic not found");
      unmount();
    }
  });
});

describe("Run pages", () => {
  const dom = useStrictConsole();

  it.each(RUN_PAGES.map((t) => [t.slug]))("%s has the four run headings and Related", async (slug) => {
    await renderTopic(slug);
    const headings = screen.getAllByRole("heading", { level: 2 }).map((h) => h.textContent);
    expect(headings).toEqual([...RUN_PAGE_HEADINGS, "Related"]);
    expect(dom.messages).toEqual([]);
  });

  it("every run intent has a written page", () => {
    for (const intent of Object.values(Intent)) {
      const slug = helpSlug(intent);
      expect(getHelpTopic(slug)?.status, intent).toBe("ready");
      expect(HELP_CONTENT[slug], intent).toBeDefined();
    }
    expect(Object.keys(INTENT_HELP_SLUGS).sort()).toEqual(Object.values(Intent).sort());
  });

  it("maps the New Run form's operations to their pages", () => {
    expect(helpSlug("new base model")).toBe("run-new-base-model");
    expect(helpSlug("vibe modeling of version")).toBe("run-vibe");
    expect(helpSlug("vibe new ecm + mvm")).toBe("run-vibe-ecm-mvm");
    expect(helpSlug("install model")).toBe("run-install");
    expect(helpSlug("uninstall")).toBe("run-uninstall");
    expect(helpSlug("totally made up")).toBe("runs");
    expect(helpSlug("constructor")).toBe("runs");
  });

  it("the run-types table has a row for every intent page, linked", async () => {
    await renderTopic("runs");
    const table = screen.getByRole("table", { name: "Run types" });
    expect(within(table).getAllByRole("row")).toHaveLength(RUN_TYPE_ROWS.length + 1);
    const links = within(table).getAllByRole("link", { name: /^Read more about / });
    const names = links.map((a) => a.getAttribute("aria-label"));
    expect(new Set(names).size).toBe(names.length);
    expect(within(table).getByRole("link", { name: "Read more about Install" })).toHaveAttribute(
      "href",
      "/help/run-install",
    );
    const linked = links.map((a) => a.getAttribute("href"));
    for (const slug of new Set(Object.values(INTENT_HELP_SLUGS))) {
      if (slug === "runs") continue;
      expect(linked, slug).toContain(`/help/${slug}`);
    }
    expect(linked).toContain("/help/run-delete-version");
    expect(within(table).getByText("Generate Samples")).toBeInTheDocument();
    expect(dom.messages).toEqual([]);
  });

  it("the install page covers the confirm subjects and the delete rules", async () => {
    await renderTopic("run-install");
    expect(screen.getByText(/first uninstalls that version/)).toBeInTheDocument();
    expect(screen.getByText(/loses its rows/)).toBeInTheDocument();
    expect(screen.getByText(/Pick another catalog/)).toBeInTheDocument();
    expect(screen.getByText(/Select these/)).toBeInTheDocument();
    expect(screen.getByText(/schemas another business owns and schemas no business recorded/)).toBeInTheDocument();
    expect(screen.getByText(/CREATE OR REPLACE TABLE/)).toBeInTheDocument();
    expect(
      screen.getAllByText(/the app releases its rows in the agent's registry there, so it does not\s+block a scoped run on the version you made current/),
    ).toHaveLength(1);
    expect(screen.getAllByText(/still in the registry of the run's catalog/)).toHaveLength(1);
    expect(screen.getAllByText(/Versions with a lower\s+number do not block it/)).toHaveLength(1);
    expect(document.body.textContent).not.toMatch(/keeps replaced versions in\s+its registry/);
    expect(
      screen.getByText(/Where the latest version is installed \(or when it is installed nowhere\), an older or replaced version becomes the latest version\. In any other catalog it is a plain install/),
    ).toBeInTheDocument();
    expect(screen.queryByText(/Installing an older or replaced version makes it the latest/)).toBeNull();
  });

  it("states the _metamodel writes of Import and Dry Run", async () => {
    const { unmount } = render(withRouter(<HelpTopicBody slug="import" />));
    expect(
      await screen.findByText(/writes the version's registry rows to\s+the _metamodel schema of the installation catalog/),
    ).toBeInTheDocument();
    expect(screen.queryByText(/Nothing in Unity Catalog/)).toBeNull();
    unmount();
    await renderTopic("run-vibe");
    expect(screen.getByText(/registers the draft in the _metamodel schema/)).toBeInTheDocument();
    expect(screen.getByText(/replaces them, and the dialog asks you to confirm/)).toBeInTheDocument();
    const rows = Object.fromEntries(RUN_TYPE_ROWS.map((r) => [r.run, r]));
    expect(rows["Import"].catalog).toMatch(/_metamodel of the installation catalog/);
    expect(rows["Vibe Modeling, Dry Run (All or Some domains)"].catalog).toMatch(/^No schemas or tables\. Registers the draft in _metamodel/);
  });

  it("the vibe page says what the Changes card leaves out and both roll back paths", async () => {
    await renderTopic("run-vibe");
    expect(screen.getByText(/It does not show changes to tags, glossary terms/)).toBeInTheDocument();
    expect(screen.getByText(/After a Dry Run: delete the draft/)).toBeInTheDocument();
    expect(screen.getByText(/Rejected change.*are deleted with it/)).toBeInTheDocument();
  });

  it("the uninstall page names the shared _metrics schema", async () => {
    await renderTopic("run-uninstall");
    expect(screen.getByText(/shared _metrics schema/)).toBeInTheDocument();
  });

  it("the Vibe ECM + MVM page says where the conventions come from and what One Catalog drops", async () => {
    await renderTopic("run-vibe-ecm-mvm");
    expect(screen.getByText(/Schema Prefix is the new ECM's prefix/)).toBeInTheDocument();
    expect(screen.getByText(/The new MVM takes the new\s+ECM's conventions/)).toBeInTheDocument();
    expect(screen.getByText(/the shrink to the MVM first drops this business's schemas/)).toBeInTheDocument();
  });

  it("the New Base Model page says One Catalog leaves only the MVM installed", async () => {
    await renderTopic("run-new-base-model");
    expect(screen.getByText(/the shrink to the MVM first drops this business's schemas/)).toBeInTheDocument();
    expect(screen.getByText(/the MVM is the version left installed/)).toBeInTheDocument();
    expect(screen.getByText(/the ECM is recorded as uninstalled too/)).toBeInTheDocument();
    const rows = Object.fromEntries(RUN_TYPE_ROWS.map((r) => [r.run, r]));
    expect(rows["New Base Model"].catalog).toMatch(/With One Catalog only the MVM stays installed/);
    expect(rows["Vibe ECM + MVM"].catalog).toMatch(/With One Catalog only the new MVM stays installed/);
  });

  it("the vibe page says which conventions a vibe locks", async () => {
    await renderTopic("run-vibe");
    expect(screen.getByText(/On All domains\s+it locks only the ones the base sets/)).toBeInTheDocument();
    expect(screen.getByText(/ignores a changed schema suffix or tag suffix/)).toBeInTheDocument();
    expect(
      screen.getByText(/It locks\s+Schema Suffix, Tag Suffix and Boolean Format on every vibe/),
    ).toBeInTheDocument();
  });

  it("the vibe page says a version made current over a newer one does not block a scoped run", async () => {
    await renderTopic("run-vibe");
    expect(screen.getByText(/released from the registry and does\s+not block/)).toBeInTheDocument();
    expect(document.body.textContent).not.toMatch(/keeps them in its\s+registry/);
  });

  it("the vibe page covers Dry Run first, the scope pre-fill and the change review", async () => {
    await renderTopic("run-vibe");
    expect(screen.getByText(/Dry Run is the default/)).toBeInTheDocument();
    expect(screen.getByText(/Scope from your feedback/)).toBeInTheDocument();
    expect(screen.getByText(/Add rejected as feedback/)).toBeInTheDocument();
    expect(screen.getByText(/roll back steps/)).toBeInTheDocument();
  });

  it("the delete page lists the one-by-one rules", async () => {
    await renderTopic("run-delete-version");
    expect(screen.getByText(/one by one, the newest first/)).toBeInTheDocument();
    expect(screen.getByText(/Uninstall it first/)).toBeInTheDocument();
    expect(screen.getByText("Replaced versions and Dry Run drafts can be deleted at any time.")).toBeInTheDocument();
    expect(screen.getByText(/feedback the version applied becomes open again/)).toBeInTheDocument();
  });
});

describe("Help copy", () => {
  it.each(Object.keys(HELP_CONTENT).map((slug) => [slug]))("%s has no em-dash", async (slug) => {
    await renderTopic(slug);
    expect(document.body.textContent).not.toContain("—");
  });
});

describe("Vibes page", () => {
  const dom = useStrictConsole();

  it("gives 8-10 examples, how to write one and how feedback is used", async () => {
    render(withRouter(<VibesContent />));
    for (const h of ["Examples", "How to write a good request", "How the agent uses your feedback"]) {
      expect(await screen.findByRole("heading", { name: h })).toBeInTheDocument();
    }
    expect(VIBE_EXAMPLES.length).toBeGreaterThanOrEqual(8);
    expect(VIBE_EXAMPLES.length).toBeLessThanOrEqual(10);
    for (const e of VIBE_EXAMPLES) expect(screen.getByText(e)).toBeInTheDocument();
    expect(screen.getByText(/marked done only when/)).toBeInTheDocument();
    expect(dom.messages).toEqual([]);
  });
});

describe("Shortcuts page", () => {
  const dom = useStrictConsole();

  it("renders the real shortcuts, grouped, with a context-sensitivity note", async () => {
    render(withRouter(<ShortcutsContent />));
    expect(await screen.findByText("Global")).toBeInTheDocument();
    expect(
      screen.getByText(/Open model search/i),
    ).toBeInTheDocument();
    expect(screen.getByText(/Toggle the sidebar/i)).toBeInTheDocument();
    expect(screen.getByText(/Cancel \/ close the dialog/i)).toBeInTheDocument();
    // Key caps rendered.
    expect(screen.getAllByText("K").length).toBeGreaterThanOrEqual(1);
    expect(screen.getByText("Esc")).toBeInTheDocument();
    expect(screen.getAllByText(/context-sensitive/i).length).toBeGreaterThanOrEqual(1);
    expect(dom.messages).toEqual([]);
  });
});

describe("Flow page", () => {
  const dom = useStrictConsole();

  it("renders the intro and the expanded stage prose", async () => {
    render(withRouter(<FlowContent />));
    expect(
      await screen.findByText(/Here's the loop, end to end/i),
    ).toBeInTheDocument();
    expect(screen.getByText(/Review and give feedback/i)).toBeInTheDocument();
    expect(screen.getByText(/mark domains as reviewed/i)).toBeInTheDocument();
    expect(dom.messages).toEqual([]);
  });
});

describe("Assessment page", () => {
  const dom = useStrictConsole();

  it("is listed in the help catalogue right after the flow topic", () => {
    const slugs = HELP_TOPICS.map((t) => t.slug);
    expect(slugs.indexOf("assessment")).toBe(slugs.indexOf("flow") + 1);
    const topic = HELP_TOPICS.find((t) => t.slug === "assessment")!;
    expect(topic.title).toBe("Assessing a model against your data");
    expect(topic.status).toBe("ready");
    expect(topic.group).toBe("Getting started");
  });

  it("renders its six sections and the settings link", async () => {
    render(withRouter(<AssessmentContent />));
    for (const h of [
      "What an assessment does",
      "Before you start",
      "Running one",
      "What you get",
      "After the assessment",
      "Time and cost",
    ]) {
      expect(await screen.findByRole("heading", { name: h })).toBeInTheDocument();
    }
    expect(screen.getAllByText(/read-only/i).length).toBeGreaterThanOrEqual(1);
    expect(screen.getByText(/etl-development-framework/)).toBeInTheDocument();
    expect(screen.getByText(/Hybrid output has seven/)).toBeInTheDocument();
    expect(screen.getByText(/gold layer is derived later, in the hand-off/)).toBeInTheDocument();
    expect(screen.getByText(/30.60 minutes per domain/i)).toBeInTheDocument();
    expect(screen.getByText(new RegExp(ASSESS_MODEL))).toBeInTheDocument();
    expect(screen.getByText(/Databricks account team/)).toBeInTheDocument();
    const links = screen.getAllByRole("link", { name: /Settings → Platform, Optional features/ });
    expect(links).toHaveLength(2);
    for (const link of links) {
      expect(link).toHaveAttribute("href", "/settings?tab=platform#feature-assessment");
    }
    expect(screen.queryByText(/Settings → Assessment/)).toBeNull();
    expect(dom.messages).toEqual([]);
  });
});

describe("Domain Taxonomy Builder page", () => {
  const dom = useStrictConsole();

  it("is listed under Getting started after the assessment, gated on its feature", () => {
    const slugs = HELP_TOPICS.map((t) => t.slug);
    expect(slugs.indexOf("taxonomy-builder")).toBe(slugs.indexOf("assessment") + 1);
    const topic = getHelpTopic("taxonomy-builder")!;
    expect(topic.status).toBe("ready");
    expect(topic.group).toBe("Getting started");
    expect(topic.feature).toBe("taxonomy");
  });

  it("renders its four sections, the busy schedule and the settings link", async () => {
    render(withRouter(<TaxonomyBuilderContent />));
    for (const h of ["Before you start", "The four steps", "When the model is busy", "Your progress is saved"]) {
      expect(await screen.findByRole("heading", { name: h })).toBeInTheDocument();
    }
    expect(screen.getByText(/up to 6 times, waiting about 15 s, 30 s, 1 min, 2 min, 5 min, 10 min/)).toBeInTheDocument();
    expect(screen.getByText(/at most 2,000\s+characters/)).toBeInTheDocument();
    const link = screen.getByRole("link", { name: /Settings → Platform, Optional features/ });
    expect(link).toHaveAttribute("href", "/settings?tab=platform#feature-taxonomy");
    expect(screen.getAllByRole("link", { name: /New Base Model/ })[0]).toHaveAttribute("href", "/help/run-new-base-model");
    expect(dom.messages).toEqual([]);
  });
});

describe("Coming-soon template", () => {
  const dom = useStrictConsole();

  it("renders a known-but-unwritten topic without looking broken", async () => {
    render(withRouter(<ComingSoonContent slug="glossary" />));
    expect(await screen.findByText("Glossary")).toBeInTheDocument();
    expect(screen.getByText(/coming soon/i)).toBeInTheDocument();
    expect(dom.messages).toEqual([]);
  });
});
