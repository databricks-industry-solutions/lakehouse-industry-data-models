import { useCallback, useEffect, useState, type ReactNode } from "react";
import {
  useGetBusinessSuspense,
  useGetModelSummarySuspense,
  useListVersionsSuspense,
  useGetUserPreferences,
  getDiagramLayout,
} from "@/lib/api";
import type { FeedbackContext } from "@/lib/api";
import type { ColumnDisplayMode } from "@/components/diagram/types";
import { selector } from "@/lib/selector";
import { liveDomainOptions } from "@/lib/domain-options";
import { Badge } from "@/components/ui/badge";
import { VersionSyncStateBanner } from "@/components/versions/version-sync-state-banner";
import { ModelView, type ModelViewTab, type ModelViewFocusAnchor } from "@/components/vibe-inputs/model-view";
import { AddFeedbackButton } from "@/components/feedback/add-feedback-button";
import {
  ARTIFACTS_FEEDBACK_DISABLED_REASON,
  buildFeedbackContext,
  type FeedbackSubject,
} from "@/components/feedback/feedback-context";
import { StatisticsTab } from "@/components/statistics/statistics-tab";
import { makeDefaultTargetPath } from "@/lib/source-selection";
import { ModelOverview } from "@/components/model/model-overview";
import { useToolbarNoteSlot } from "@/components/model/toolbar-note-slot";
import { VersionLifecycleBadges } from "@/components/versions/version-lifecycle-badges";

// Per-user default column-display mode preference keys (item 4, 0.6.6). The
// all-domains view (index route, no focusAnchor) and the focal single-domain
// view (input route, focusAnchor.domain set) each have their own default, kept
// in sync with Settings > Diagram (settings.tsx) and the domain route.
const DIAGRAM_ALL_DOMAINS_MODE_KEY = "diagram.default_column_mode";
const DIAGRAM_FOCAL_MODE_KEY = "diagram.default_column_mode_focal";

/**
 * The full model-page orchestration around the shared `ModelView` tab bar:
 * the three suspense fetches (business, model summary, versions) + current
 * version resolution, the diagram-selection feedback context, the standard tab
 * bodies (Overview, Statistics, sync banner), the column-mode preference gate,
 * the ELK cache warm, and the single-home Add-feedback affordance. Both the
 * model-version route and the input-review route render this, so the input
 * surface inherits the FULL tab set (Overview / Diagram / Relationships /
 * Ontology / Artifacts / Feedback / Statistics) for free instead of a
 * hand-wired subset.
 *
 * What this does NOT own (stays per-route): the `?tab=` param (router-owned,
 * passed in as `tab` + `onTabChange`), `useBreadcrumbs`, and the destructive
 * `DeleteVersionButton` (injected via `versionActions` so the button and its
 * invalidation logic stay in the model-version route).
 *
 * Single-home Add-feedback (app-wide principle): ONE Add-feedback affordance
 * per surface. The shell builds it once (bound to the feedback context it
 * assembles) and places it by the active tab - into the diagram toolbar via
 * `ModelView.feedbackSlot` on the Diagram tab (where `ModelView` suppresses
 * `tabBarTrailing`), and into `tabBarTrailing` on every other tab. This is the
 * reference implementation of the single-home rule for non-diagram tabs.
 */
export function ModelTabsShell({
  businessId,
  version,
  scope,
  tab,
  onTabChange,
  focusAnchor,
  feedbackSubject,
  pickedDomain: requestedPickedDomain,
  onOntologyDomainPick,
  onOpenDomain,
  versionActions,
  searchTrigger,
  onDomainNavigate,
  showDomainSelect,
  tabs,
  showLifecycleActions = true,
}: {
  businessId: string;
  version: string;
  scope: string;
  /** Router-owned `?tab=` value + setter. Each route wires its own so the
   *  shared shell never hardcodes a `from` route id. */
  tab: ModelViewTab;
  onTabChange: (tab: ModelViewTab) => void;
  /** Input route: single-domain focus. Index route: undefined (all-domains). */
  focusAnchor?: ModelViewFocusAnchor;
  /** Input route: the reviewed input's element, what Add-feedback captures on
   *  tabs without their own domain control. Index route: undefined. */
  feedbackSubject?: FeedbackSubject;
  /** Index route: the domain picked in the Diagram or Ontology tab's
   *  dropdown (one `?domain=` for both), drawn in place by both tabs: the
   *  diagram's single-domain layout, the ontology scoped to that domain.
   *  Undefined = all domains. */
  pickedDomain?: string;
  /** Index route: the Ontology dropdown is owned by the route; a pick calls
   *  this (it writes `?domain=`). Omit it and the Ontology filters locally. */
  onOntologyDomainPick?: (domain: string | null) => void;
  /** Index route: forwarded to `ModelView`; the Overview tab carries a
   *  domain dropdown that opens the picked domain's page. */
  onOpenDomain?: (domain: string) => void;
  /** Index route injects `DeleteVersionButton`; the input route omits it (a
   *  review surface offers no version deletion). Rendered in `tabBarTrailing`
   *  next to Add-feedback. */
  versionActions?: ReactNode;
  /** Item 2: the model-wide search trigger, mounted in the header region. */
  searchTrigger?: ReactNode;
  /** Forwarded to `ModelView` -> `DiagramViewer` (item 3B): domain selection
   *  navigates via this callback instead of internal state. */
  onDomainNavigate?: (domain: string | null) => void;
  /** Forwarded to `ModelView` -> `DiagramViewer`: hides the diagram
   *  toolbar's own domain dropdown on surfaces that only follow a focused
   *  input. Domain selection lives inside each tab, never in this header. */
  showDomainSelect?: boolean;
  /** Which tabs to render. Defaults to the full set. */
  tabs?: readonly ModelViewTab[];
  /** Threaded to `ModelOverview`: the input surface passes `false` to suppress
   *  the run/install `CommandStrip`. */
  showLifecycleActions?: boolean;
}) {
  // Capture the diagram's current node/edge selection so the single Add-feedback
  // affordance can scope to a specific table or relationship on the diagram tab.
  const [diagramSelection, setDiagramSelection] = useState<{
    nodeId: string | null;
    edgeId: string | null;
  }>({ nodeId: null, edgeId: null });
  // The line under the tab bar where a tab-bar action's note (the Delete
  // reason) wraps at the page width instead of widening the tab bar.
  const toolbarNote = useToolbarNoteSlot();
  const handleDiagramSelection = useCallback(
    (sel: { nodeId: string | null; edgeId: string | null }) => setDiagramSelection(sel),
    [],
  );

  // The domain each tab with its own domain control shows (null = all).
  const [statisticsDomain, setStatisticsDomain] = useState<string | null>(null);
  const [ontologyDomain, setOntologyDomain] = useState<string | null>(null);

  const { data: business } = useGetBusinessSuspense({
    params: { business_id: businessId },
    ...selector(),
  });
  const { data: model } = useGetModelSummarySuspense({
    params: { business_id: businessId, version_int: Number(version), scope },
    ...selector(),
  });
  const { data: versions } = useListVersionsSuspense({
    params: { business_id: businessId },
    ...selector(),
  });

  const domainList = liveDomainOptions(model.domains);
  // A `?domain=` that names no domain of this model is "All domains": no
  // single-domain layout request, no warm-up, the dropdowns show All domains.
  const pickedDomain =
    requestedPickedDomain && domainList.some((d) => d.name === requestedPickedDomain)
      ? requestedPickedDomain
      : undefined;

  // Feedback is about the lowest model element in view: the diagram's live
  // selection (diagram tab only, elsewhere it is stale); on Review Progress,
  // Ontology and a Diagram drawn for one picked domain, the domain their own
  // control shows (none = the whole model); elsewhere the page's subject (the
  // reviewed input's element), else the whole model.
  const getContext = useCallback((): FeedbackContext => {
    const tabDomain =
      tab === "statistics"
        ? statisticsDomain
        : tab === "ontology"
          ? ontologyDomain
          : tab === "diagram" && pickedDomain
            ? pickedDomain
            : undefined;
    return buildFeedbackContext({
      selection: tab === "diagram" ? diagramSelection : null,
      subject: tabDomain === undefined ? feedbackSubject : { domain: tabDomain },
    });
  }, [tab, diagramSelection, statisticsDomain, ontologyDomain, pickedDomain, feedbackSubject]);

  // Non-suspense preference lookup gates the DiagramViewer mount (ModelView
  // defers the diagram tab while `columnModePending`), so its useState-once
  // column-mode seed reads the resolved preference instead of the fallback.
  // The focal single-domain view and the all-domains view use different keys.
  const diagramFocusDomain = focusAnchor?.domain ?? pickedDomain;
  const focal = Boolean(diagramFocusDomain);
  const { data: userPrefs, isLoading: columnModePending } = useGetUserPreferences();
  const columnModePref = userPrefs?.data.find(
    (p) => p.key === (focal ? DIAGRAM_FOCAL_MODE_KEY : DIAGRAM_ALL_DOMAINS_MODE_KEY),
  )?.value as ColumnDisplayMode | undefined;

  // Two MV rows can share `version` if their `scope` differs (the model-versioning work),
  // so use `(version, scope)` as the natural key. Fall back to the
  // version-only match if scope is unknown (legacy callers).
  const currentVersion =
    versions.find(
      (v: any) => v.version === Number(version) && (v.scope || "") === scope,
    ) ?? versions.find((v: any) => v.version === Number(version));
  const currentVersionId = (currentVersion as any)?.id as string | undefined;
  const scopeLabel = scope ? scope.toUpperCase() : "";

  // Warm the diagram cache so the first Diagram tab open is fast. Gate the
  // scope: when the diagram is scoped to one domain (an input review's
  // focusAnchor, or the Diagram tab's picked domain), warm ONLY that domain's
  // single-domain layout - never the all-domains layout, or a large model
  // (TerraNova) would trigger an all-domains ELK compute for a one-domain
  // view. Otherwise (all-domains diagram), warm the all-domains layout.
  // The all-domains warm always primes the "hide" variant (not the resolved
  // preference): warming a single fixed variant avoids a per-column-mode ELK
  // fan-out that starves the single-threaded worker, and every variant
  // computes cheaply on first request off a warm base.
  const warmDomain = diagramFocusDomain;
  const warmColumnMode = focal ? (columnModePref ?? "keys") : "hide";
  useEffect(() => {
    getDiagramLayout({
      business_id: businessId,
      version_int: Number(version),
      scope,
      ...(warmDomain ? { domain: warmDomain } : {}),
      column_mode: warmColumnMode,
      prefetch: true,
    }).catch(() => {});
  }, [businessId, version, scope, warmDomain, warmColumnMode]);

  const addFeedback = (
    <AddFeedbackButton
      businessId={businessId}
      versionId={currentVersionId}
      getContext={getContext}
      disabledReason={tab === "artifacts" ? ARTIFACTS_FEEDBACK_DISABLED_REASON : undefined}
    />
  );

  return toolbarNote.provide(
    <ModelView
      businessId={businessId}
      version={version}
      scope={scope}
      domains={domainList}
      tabs={tabs}
      value={tab}
      onTabChange={onTabChange}
      diagramDomain={diagramFocusDomain}
      onOpenDomain={onOpenDomain}
      initialColumnMode={columnModePref}
      columnModePending={columnModePending}
      onDomainNavigate={onDomainNavigate}
      showDomainSelect={showDomainSelect}
      onSelectionChange={handleDiagramSelection}
      onOntologyDomainChange={setOntologyDomain}
      ontologyDomain={pickedDomain}
      onOntologyDomainPick={onOntologyDomainPick}
      modelVersionId={currentVersionId ?? ""}
      feedbackSlot={addFeedback}
      headerSlot={
        <div className="flex flex-wrap items-center gap-x-3 gap-y-2 min-w-0">
          <div className="flex flex-wrap items-center gap-2 min-w-0">
            <h1 className="text-2xl font-semibold tracking-tight flex flex-wrap items-center gap-x-2 gap-y-1 min-w-0">
              <span className="min-w-0 break-words">
                {model.name} v{model.version}
              </span>
              {scopeLabel && (
                <Badge
                  className={scope === "ecm" ? "bg-muted text-foreground border-border" : "bg-info/10 text-info border-info/30"}
                  variant="outline"
                >
                  {scopeLabel}
                </Badge>
              )}
            </h1>
            {currentVersion && <VersionLifecycleBadges version={currentVersion} versions={versions} withDate />}
          </div>
          {searchTrigger && (
            <div className="ml-auto flex flex-wrap items-center gap-2" data-testid="model-toolbar-filters">
              {searchTrigger}
            </div>
          )}
        </div>
      }
      tabBarTrailing={
        <>
          {addFeedback}
          {versionActions}
        </>
      }
      betweenSlot={
        <>
          {toolbarNote.slot}
          {currentVersion ? <VersionSyncStateBanner version={currentVersion} /> : null}
        </>
      }
      overviewSlot={
        <ModelOverview
          businessId={businessId}
          version={version}
          scope={scope}
          currentVersion={currentVersion}
          versions={versions}
          model={model}
          modelVersionId={currentVersionId ?? ""}
          defaultTargetPath={makeDefaultTargetPath(
            business.source_repo_path,
            scope,
            Number(version),
          )}
          showLifecycleActions={showLifecycleActions}
        />
      }
      statisticsSlot={
        <StatisticsTab
          model={model}
          scope={scope}
          businessId={businessId}
          versionInt={Number(version)}
          onDomainChange={setStatisticsDomain}
        />
      }
    />,
  );
}
