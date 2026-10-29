import { useEffect, useState } from "react";
import { Badge } from "@/components/ui/badge";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { useGetAssessmentResultsSuspense, type AssessResultsOut } from "@/lib/api";
import { decisionAnchor, linkDecisionsToVibes } from "@/lib/assessment";
import { selector } from "@/lib/selector";
import { AssessBoundary } from "./assess-boundary";
import { DecisionList } from "./decision-card";
import { DocsPane } from "./doc-viewer";
import { EntityDrilldown } from "./entity-drilldown";
import { GapTable } from "./gap-table";
import { HandoffPanel } from "./handoff-panel";
import { NextVibesList } from "./next-vibes-list";
import { Scorecard } from "./scorecard";

function ResultsTabs({
  domainRunId,
  feedbackTarget,
}: {
  domainRunId: string;
  feedbackTarget?: { businessId: string; version: number; scope: string };
}) {
  const { data: results } = useGetAssessmentResultsSuspense({
    params: { domain_run_id: domainRunId },
    ...selector<AssessResultsOut>(),
  });
  const [tab, setTab] = useState("scorecard");
  const [jumpTo, setJumpTo] = useState<string | null>(null);

  // Link structure decisions to vibes
  const { vibeForDecision, decisionsForVibe } = linkDecisionsToVibes(results.pending_decisions, results.next_vibes);

  // A structure ref ("D3" / "Vibe 2") opens its tab; a decision then scrolls to its card once the tab has rendered.
  const jump = (ref: string) => {
    if (/^D\d+$/.test(ref)) {
      setJumpTo(ref);
      setTab("decisions");
    } else setTab("vibes");
  };
  useEffect(() => {
    if (tab !== "decisions" || !jumpTo) return;
    // The pane mounts after the tab switch commits, so look the card up on the next frame.
    const raf = requestAnimationFrame(() => {
      document.getElementById(decisionAnchor(jumpTo))?.scrollIntoView?.({ behavior: "smooth", block: "start" });
      setJumpTo(null);
    });
    return () => cancelAnimationFrame(raf);
  }, [tab, jumpTo]);
  const openCount = results.pending_decisions.filter((d) => d.answer_status === "open").length;
  return (
    // Inline-size containment keeps wide tab content (the gap table, long prompt blocks) from widening the
    // page: the panel takes the page's width and those blocks scroll inside it.
    <Tabs value={tab} onValueChange={setTab} className="[contain:inline-size]" data-testid="results-tabs">
      <TabsList>
        <TabsTrigger value="scorecard">Scorecard</TabsTrigger>
        <TabsTrigger value="entities">Entities</TabsTrigger>
        <TabsTrigger value="gaps">Gaps</TabsTrigger>
        <TabsTrigger value="decisions">
          Decisions <Badge variant="secondary" className="ml-1">{openCount}</Badge>
        </TabsTrigger>
        <TabsTrigger value="vibes">Next vibes</TabsTrigger>
        <TabsTrigger value="docs">Docs</TabsTrigger>
        <TabsTrigger value="handoff">Hand-off</TabsTrigger>
      </TabsList>
      <TabsContent value="scorecard">
        <Scorecard results={results} onJumpToTab={setTab as (tab: any) => void} />
      </TabsContent>
      <TabsContent value="entities">
        <EntityDrilldown entities={results.entities} onJumpToRef={jump} />
      </TabsContent>
      <TabsContent value="gaps">
        <GapTable gaps={results.gaps} />
      </TabsContent>
      <TabsContent value="decisions" className="space-y-3">
        {results.pending_decisions.length === 0 ? (
          <p className="text-sm text-muted-foreground">No decisions are pending.</p>
        ) : (
          <DecisionList
            decisions={results.pending_decisions}
            domainRunId={domainRunId}
            vibeForDecision={vibeForDecision}
            onJumpToRef={jump}
          />
        )}
      </TabsContent>
      <TabsContent value="vibes">
        <NextVibesList
          vibes={results.next_vibes}
          verdict={results.summary?.verdict}
          decisionsForVibe={decisionsForVibe}
          onJumpToRef={jump}
          domainRunId={domainRunId}
          feedbackTarget={feedbackTarget}
        />
      </TabsContent>
      <TabsContent value="docs">
        <DocsPane domainRunId={domainRunId} />
      </TabsContent>
      <TabsContent value="handoff">
        <HandoffPanel domainRunId={domainRunId} />
      </TabsContent>
    </Tabs>
  );
}

/** Per-domain results review for a completed run: scorecard, entities, gaps, decisions, next vibes, docs, hand-off. */
export function DomainResults({
  domainRunId,
  feedbackTarget,
}: {
  domainRunId: string;
  feedbackTarget?: { businessId: string; version: number; scope: string };
}) {
  return (
    <AssessBoundary>
      <ResultsTabs domainRunId={domainRunId} feedbackTarget={feedbackTarget} />
    </AssessBoundary>
  );
}
