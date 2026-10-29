import { Suspense, useCallback, useState, type ReactNode } from "react";
import { Tabs, TabsTrigger, TabsContent } from "@/components/ui/tabs";
import { ToolbarActions, ToolbarTabsList } from "@/components/model/toolbar";
import { Skeleton } from "@/components/ui/skeleton";
import { Badge } from "@/components/ui/badge";
import { useListVibeInputsSuspense } from "@/lib/api";
import { selector } from "@/lib/selector";
import {
  Layers,
  GitGraph,
  Link2,
  Globe,
  Download,
  MessageSquare,
  BarChart2,
} from "lucide-react";
import { DiagramViewer } from "@/components/diagram/diagram-viewer";
import { TabDomainSelect } from "@/components/diagram/domain-select";
import type { ColumnDisplayMode } from "@/components/diagram/types";
import { RelationshipAnalysis } from "@/components/explorer/relationship-analysis";
import { OntologyGraph } from "@/components/explorer/ontology-graph";
import { FeedbackList } from "@/components/feedback/feedback-list";
import { ArtifactsTab } from "@/components/artifacts/artifacts-tab";

/** The model-visualization tabs, in display order. */
export const MODEL_VIEW_TABS = [
  "overview",
  "diagram",
  "relationships",
  "ontology",
  "artifacts",
  "feedback",
  "statistics",
] as const;

export type ModelViewTab = (typeof MODEL_VIEW_TABS)[number];

/** Where the diagram should pre-focus. Card-details passes the input's anchor
 *  leaf so the viz scopes to a single domain (never all-domains — ELK perf).
 *  Undefined on the plain model route. */
export interface ModelViewFocusAnchor {
  domain?: string;
  product?: string;
  attribute?: string;
  fkLabel?: string;
}

export interface ModelViewProps {
  businessId: string;
  /** Human version int as string (URL form). */
  version: string;
  /** "ecm" | "mvm" (or "" for legacy fixtures). */
  scope: string;
  /** Domains for the diagram domain-picker, already deletion-filtered by the
   *  caller (the model route maps these off the model summary). */
  domains: { name: string; division: string }[];
  /** Which tabs to render. Defaults to all. The "overview" tab has no body
   *  here — the model route supplies it via `overviewSlot` (it carries page
   *  chrome: command strip, metrics band, domain cards). Card-details omits overview. */
  tabs?: readonly ModelViewTab[];
  /** Initial active tab. */
  defaultTab?: ModelViewTab;
  /** Controlled active tab (model route drives this from the URL ?tab). */
  value?: ModelViewTab;
  /** Called when the active tab changes. */
  onTabChange?: (tab: ModelViewTab) => void;
  /** The one domain the diagram draws (its single-domain layout, in place):
   *  an input review's focus-anchor domain, else the domain picked in the
   *  Diagram tab's own dropdown. Undefined draws all domains. */
  diagramDomain?: string;
  /** Model route: the Overview tab's domain dropdown opens the picked
   *  domain's page (Products tab). Omit it and the Overview shows none. */
  onOpenDomain?: (domain: string) => void;
  /** When provided, the diagram's domain selection navigates via this
   *  callback instead of the viewer's own internal state (item 3A). Omit to
   *  keep DiagramViewer's internal-state behavior unchanged. */
  onDomainNavigate?: (domain: string | null) => void;
  /** Hide the diagram toolbar's own domain dropdown on surfaces that only
   *  follow a focused input. Defaults to true. */
  showDomainSelect?: boolean;
  /** Seeds the diagram's initial column-display mode from the caller's
   *  resolved per-user preference (Settings > Diagram, item 4). Omit to
   *  keep DiagramViewer's own hardcoded fallback. */
  initialColumnMode?: ColumnDisplayMode;
  /** True while the caller's preference lookup for `initialColumnMode` is
   *  still in flight. `DiagramViewer` seeds its column mode via a
   *  `useState` initializer read ONCE at mount, so mounting it before the
   *  preference resolves would permanently lock it onto the hardcoded
   *  fallback - a later-resolving `initialColumnMode` can't retroactively
   *  fix an already-mounted `useState`. ModelView defers mounting the
   *  diagram tab's `DiagramViewer` (a skeleton instead) while this is
   *  true, so the mount never races the preference fetch. Defaults to
   *  `false` (mount immediately) for callers that don't pass a
   *  preference at all. */
  columnModePending?: boolean;
  /** Bubbles the diagram's node/edge selection (feedback scoping). */
  onSelectionChange?: (sel: { nodeId: string | null; edgeId: string | null }) => void;
  /** Bubbles the Ontology tab's domain filter (feedback scoping). */
  onOntologyDomainChange?: (domain: string | null) => void;
  /** Model route: the Ontology dropdown is host-owned. It shows
   *  `ontologyDomain` (the picked `?domain=`, shared with the Diagram) and a
   *  pick calls this. Omit both and the Ontology filters locally. */
  ontologyDomain?: string;
  onOntologyDomainPick?: (domain: string | null) => void;
  /** Overview tab body. Only consulted when "overview" is in `tabs`. */
  overviewSlot?: ReactNode;
  /** Statistics tab body. Only consulted when "statistics" is in `tabs`.
   *  Supplied by the model route (the tab owns its own scope tree + report
   *  pane, so it lives outside the shared visualization tabs). */
  statisticsSlot?: ReactNode;
  /** Rendered in its own row above the tab list (the model route's title,
   *  badges and search); it owns its own wrapping. Domain selection is
   *  per tab and never goes here. */
  headerSlot?: ReactNode;
  /** Rendered as the right-aligned cluster beside the tab list, wrapping onto
   *  its own line when the tabs leave no room (e.g. focus scope label on
   *  card-details). Suppressed while the diagram tab is active -
   *  the diagram toolbar's feedbackSlot is the single home for feedback
   *  there (item 5B); reappears on every other tab. */
  tabBarTrailing?: ReactNode;
  /** The diagram view's Add-feedback trigger + dialog, built by the host
   *  with the diagram feedback context it already assembles. Rendered
   *  inside the diagram toolbar (item 5B) instead of the page-level tab
   *  bar / domain header while the diagram tab is shown. */
  feedbackSlot?: ReactNode;
  /** Rendered between the tab bar and the tab content, on every tab (the model
   *  route's version-sync banner lives here). */
  betweenSlot?: ReactNode;
}

const TAB_META: Record<ModelViewTab, { label: string; icon: ReactNode }> = {
  overview: { label: "Overview", icon: <Layers className="h-4 w-4 mr-1.5" /> },
  diagram: { label: "Diagram", icon: <GitGraph className="h-4 w-4 mr-1.5" /> },
  relationships: { label: "Relationships", icon: <Link2 className="h-4 w-4 mr-1.5" /> },
  ontology: { label: "Ontology", icon: <Globe className="h-4 w-4 mr-1.5" /> },
  artifacts: { label: "Artifacts", icon: <Download className="h-4 w-4 mr-1.5" /> },
  feedback: { label: "Feedback", icon: <MessageSquare className="h-4 w-4 mr-1.5" /> },
  statistics: { label: "Review Progress", icon: <BarChart2 className="h-4 w-4 mr-1.5" /> },
};

/**
 * Reusable host for the model-visualization tabs (diagram / relationships /
 * ontology / artifacts / feedback). Extracted from the model-version route so
 * both that route and the Vibe-Input card-details page mount ONE diagram host,
 * not two (drift-unification).
 *
 * The diagram is scoped via `diagramDomain` → `DiagramViewer.initialDomain`;
 * it never renders all-domains from card-details (ELK perf constraint).
 */
export function ModelView({
  businessId,
  version,
  scope,
  domains,
  tabs = MODEL_VIEW_TABS,
  defaultTab,
  value,
  onTabChange,
  diagramDomain,
  onOpenDomain,
  onDomainNavigate,
  showDomainSelect,
  initialColumnMode,
  columnModePending = false,
  onSelectionChange,
  onOntologyDomainChange,
  ontologyDomain,
  onOntologyDomainPick,
  overviewSlot,
  statisticsSlot,
  headerSlot,
  tabBarTrailing,
  feedbackSlot,
  betweenSlot,
  modelVersionId,
}: ModelViewProps & { modelVersionId?: string }) {
  const firstTab = tabs[0] ?? "diagram";
  const [internalTab, setInternalTab] = useState<ModelViewTab>(defaultTab ?? firstTab);
  const activeTab = value ?? internalTab;

  const handleTabChange = useCallback(
    (v: string) => {
      const next = v as ModelViewTab;
      setInternalTab(next);
      onTabChange?.(next);
    },
    [onTabChange],
  );

  return (
    <Tabs value={activeTab} onValueChange={handleTabChange}>
      <div className="flex flex-col gap-2" data-testid="model-toolbar">
        {headerSlot}
        <div className="flex flex-wrap items-center gap-x-4 gap-y-2">
          <ToolbarTabsList>
            {tabs.map((t) => (
              <TabsTrigger key={t} value={t}>
                {TAB_META[t].icon}
                {TAB_META[t].label}
                {t === "feedback" && (
                  <Suspense fallback={null}>
                    <FeedbackCountBadge businessId={businessId} versionId={modelVersionId} />
                  </Suspense>
                )}
              </TabsTrigger>
            ))}
          </ToolbarTabsList>
          {activeTab !== "diagram" && tabBarTrailing && (
            <ToolbarActions data-testid="model-toolbar-actions">{tabBarTrailing}</ToolbarActions>
          )}
        </div>
      </div>

      {betweenSlot}

      {tabs.includes("overview") && (
        <TabsContent value="overview">
          {onOpenDomain && (
            <TabDomainSelect
              domains={domains}
              value={null}
              onChange={(d) => d && onOpenDomain(d)}
              allowAll={false}
              placeholder="Go to domain"
            />
          )}
          {overviewSlot}
        </TabsContent>
      )}
      {tabs.includes("diagram") && (
        <TabsContent value="diagram">
          {columnModePending ? (
            <Skeleton className="h-96 w-full" />
          ) : (
            <DiagramViewer
              // The focal domain changes in place (a new input's domain on the
              // input-review route, a picked domain on the model route).
              // DiagramViewer seeds `selectedDomain` via a useState initializer
              // read ONCE at mount, so an in-place prop change would leave the
              // diagram on the old domain. Keying on the focal domain (empty
              // string for all-domains) forces a fresh mount, matching the
              // $domainName route (key={domainName}).
              key={diagramDomain ?? ""}
              businessId={businessId}
              version={version}
              scope={scope}
              domains={domains}
              initialDomain={diagramDomain}
              initialColumnMode={initialColumnMode}
              onSelectionChange={onSelectionChange}
              feedbackSlot={feedbackSlot}
              onDomainNavigate={onDomainNavigate}
              showDomainSelect={showDomainSelect}
            />
          )}
        </TabsContent>
      )}
      {tabs.includes("relationships") && (
        <TabsContent value="relationships">
          <Suspense fallback={<Skeleton className="h-64 w-full" />}>
            <RelationshipAnalysis businessId={businessId} version={version} scope={scope} />
          </Suspense>
        </TabsContent>
      )}
      {tabs.includes("ontology") && (
        <TabsContent value="ontology">
          <Suspense fallback={<Skeleton className="h-96 w-full" />}>
            <OntologyGraph
              businessId={businessId}
              version={version}
              scope={scope}
              onDomainChange={onOntologyDomainChange}
              domainFilter={onOntologyDomainPick ? ontologyDomain : undefined}
              onDomainPick={onOntologyDomainPick}
            />
          </Suspense>
        </TabsContent>
      )}
      {tabs.includes("artifacts") && (
        <TabsContent value="artifacts" className="mt-4">
          {modelVersionId ? (
            <ArtifactsTab businessId={businessId} modelVersionId={modelVersionId} />
          ) : (
            <Skeleton className="h-48 w-full" />
          )}
        </TabsContent>
      )}
      {tabs.includes("feedback") && (
        <TabsContent value="feedback" className="mt-4">
          <Suspense fallback={<Skeleton className="h-64 w-full" />}>
            <FeedbackList
              businessId={businessId}
              version={version}
              scope={scope}
              versionId={modelVersionId}
            />
          </Suspense>
        </TabsContent>
      )}
      {tabs.includes("statistics") && (
        <TabsContent value="statistics">{statisticsSlot}</TabsContent>
      )}
    </Tabs>
  );
}

/** Small count badge next to the Feedback tab. Imported into ModelView so the
 *  count moves with the tab, wherever ModelView is hosted. */
function FeedbackCountBadge({ businessId, versionId }: { businessId: string; versionId?: string }) {
  const { data } = useListVibeInputsSuspense({
    params: versionId
      ? { business_id: businessId, version_id: versionId }
      : { business_id: businessId },
    ...selector(),
  });
  const count = data.filter((i) => i.status !== "deprecated").length;
  if (!count) return null;
  return (
    <Badge variant="secondary" className="ml-1.5 h-4 min-w-4 px-1 text-[10px]">
      {count}
    </Badge>
  );
}
