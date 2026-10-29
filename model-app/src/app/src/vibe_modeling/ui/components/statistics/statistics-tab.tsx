import { Suspense, useEffect, useState } from "react";
import { ChevronLeft } from "lucide-react";
import { QueryErrorResetBoundary } from "@tanstack/react-query";
import { ErrorBoundary } from "react-error-boundary";
import type { ModelSummaryOut } from "@/lib/api";
import { Button } from "@/components/ui/button";
import { Skeleton } from "@/components/ui/skeleton";
import { ScopeTree, isModelScope, type Scope } from "./scope-tree";
import { ModelReport, DomainReport } from "./report-sections";
import { ExportReportButton } from "@/components/report-export/export-report-button";
import type { DegradationFlags } from "./area-section";
import {
  useEvolutionMetrics,
  useReviewProgressByDomain,
  reviewPctTo100,
  type StatsScope,
} from "./use-stats-data";

/**
 * The Statistics tab: a persistent two-level scope tree (Model + one leaf per
 * domain) on the left, and a report pane on the right that REBINDS to the
 * selected scope (model view ⇄ domain view) — not a separate route.
 *
 * T6/T7 bind the real sections to the metrics endpoints. Degradation is
 * data-driven from the evolution-metrics flags (`has_confidence`,
 * `has_predecessor`); ECM hides confidence, a base version collapses Change.
 */
export function StatisticsTab({
  model,
  scope: modelScope,
  businessId,
  versionInt,
  onDomainChange,
}: {
  model: ModelSummaryOut;
  /** The model's scope from the route ("ecm" | "mvm"). */
  scope: string;
  businessId: string;
  versionInt: number;
  /** Reports the domain the report pane is bound to (null for the full
   *  model), so the page's Add-feedback can capture it. */
  onDomainChange?: (domain: string | null) => void;
}) {
  const [scope, setScope] = useState<Scope>("model");

  const statsScope: StatsScope = { businessId, versionInt, scope: modelScope };

  // Real per-domain review % (reviewed ÷ review-needed), keyed by domain name.
  // Null for a domain whose products all need no review → the tree shows "—".
  const reviewPctByDomain = useReviewProgressByDomain(statsScope);

  const liveDomains = (model.domains ?? []).filter(
    (d) => d.change_status !== "deleted",
  );

  const treeDomains = liveDomains.map((d) => ({
    name: d.name,
    change_status: d.change_status,
    reviewPct: reviewPctTo100(reviewPctByDomain.get(d.name)),
  }));

  const activeDomain = isModelScope(scope) ? null : scope.domain;
  useEffect(() => {
    onDomainChange?.(activeDomain);
  }, [activeDomain, onDomainChange]);
  // The model summary's domain rows carry the DB ids + per-subdomain ids +
  // product counts the breakdown's domain/subdomain cascade controls key on.
  const activeDomainSummary = activeDomain
    ? liveDomains.find((d) => d.name === activeDomain) ?? null
    : null;

  return (
    <div
      data-testid="statistics-tab"
      className="mt-4 grid h-[calc(100vh-220px)] grid-cols-[244px_1fr] overflow-hidden rounded-md border border-border"
    >
      <ScopeTree
        domains={treeDomains}
        scope={scope}
        onSelect={setScope}
        navContext={{ businessId, versionInt, scope: modelScope }}
      />

      <div className="flex h-full flex-col overflow-y-auto">
        <div className="sticky top-0 z-10 flex items-center gap-2 border-b border-border bg-background px-4 py-2 text-sm">
          <button
            type="button"
            onClick={() => setScope("model")}
            className="text-muted-foreground transition-colors hover:text-foreground hover:underline"
          >
            Full model
          </button>
          {activeDomain && (
            <>
              <span className="text-muted-foreground">›</span>
              <span className="font-mono text-[13px]">{activeDomain}</span>
            </>
          )}
          <div className="ml-auto flex items-center gap-2">
            {activeDomain && (
              <Button
                variant="ghost"
                size="sm"
                className="h-7"
                onClick={() => setScope("model")}
              >
                <ChevronLeft className="mr-1 h-4 w-4" />
                Back to model
              </Button>
            )}
            <ExportReportButton
              businessId={businessId}
              version={versionInt}
              scope={modelScope}
              size="sm"
            />
          </div>
        </div>

        <div className="flex flex-col gap-3.5 p-4 pb-12">
          <FlagsGate scope={statsScope} routeScope={modelScope}>
            {(flags) =>
              activeDomain ? (
                <DomainReport
                  scope={statsScope}
                  domain={activeDomain}
                  domainSummary={activeDomainSummary}
                  flags={flags}
                />
              ) : (
                <ModelReport
                  scope={statsScope}
                  model={model}
                  flags={flags}
                  onDrill={(d) => setScope({ domain: d })}
                />
              )
            }
          </FlagsGate>
        </div>
      </div>
    </div>
  );
}

/**
 * Resolves the degradation flags from the evolution-metrics endpoint once, then
 * hands them to the report. `has_confidence` is additionally gated on the route
 * scope (ECM never has confidence regardless of what the endpoint reports).
 */
function FlagsGate({
  scope,
  routeScope,
  children,
}: {
  scope: StatsScope;
  routeScope: string;
  children: (flags: DegradationFlags) => React.ReactNode;
}) {
  return (
    <QueryErrorResetBoundary>
      {({ reset }) => (
        <ErrorBoundary
          onReset={reset}
          fallbackRender={({ resetErrorBoundary }) => (
            <button
              type="button"
              onClick={resetErrorBoundary}
              className="text-sm text-muted-foreground hover:text-foreground hover:underline"
            >
              Couldn't load the report — retry
            </button>
          )}
        >
          <Suspense fallback={<Skeleton className="h-64 w-full" />}>
            <FlagsResolver scope={scope} routeScope={routeScope}>
              {children}
            </FlagsResolver>
          </Suspense>
        </ErrorBoundary>
      )}
    </QueryErrorResetBoundary>
  );
}

function FlagsResolver({
  scope,
  routeScope,
  children,
}: {
  scope: StatsScope;
  routeScope: string;
  children: (flags: DegradationFlags) => React.ReactNode;
}) {
  const evo = useEvolutionMetrics(scope);
  const flags: DegradationFlags = {
    hasConfidence: routeScope.toLowerCase() !== "ecm" && (evo.has_confidence ?? true),
    hasPredecessor: evo.has_predecessor ?? true,
  };
  return <>{children(flags)}</>;
}
