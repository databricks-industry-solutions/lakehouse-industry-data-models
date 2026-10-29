/**
 * Settings → Platform, "Optional features": one card per install-time
 * feature (the Domain Taxonomy Builder, the bronze assessment). Each card
 * says whether the feature is installed and ready and who saved its settings
 * last, in the agent status row's form (`agent-status-row.tsx`), and holds
 * the feature's settings while it is installed.
 */
import type { ReactNode } from "react";
import { AlertTriangle, Check, CircleSlash } from "lucide-react";
import { Badge } from "@/components/ui/badge";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Skeleton } from "@/components/ui/skeleton";
import { AssessBoundary } from "@/components/assessment/assess-boundary";
import { AssessSettings } from "@/components/assessment/assess-settings";
import { FeatureConfigError } from "@/components/feature-gate";
import { HelpLink } from "@/components/help/help-link";
import { TaxonomyBuilderForm } from "@/components/settings/taxonomy-builder-card";
import { useGetAssessConfig } from "@/lib/api";
import { formatDateTime, formatRelative } from "@/lib/date";
import {
  FEATURE_INFO,
  useAssessFeatureReady,
  useTaxonomyReady,
  type FeatureReady,
  type OptionalFeature,
} from "@/lib/features";

type Tone = "ok" | "warn" | "off";

/** The status row's text for a loaded feature (pure, for tests). */
export function featureStatus(
  feature: OptionalFeature,
  state: Pick<FeatureReady, "installed" | "ready">,
  saved: { by?: string | null; at?: string | null },
): { tone: Tone; text: string; saved: string | null } {
  const info = FEATURE_INFO[feature];
  if (!state.installed) {
    return {
      tone: "off",
      text: `Not installed. To turn it on, re-run the installer with ${info.installFlag}.`,
      saved: null,
    };
  }
  const by = saved.by?.trim();
  return {
    tone: state.ready ? "ok" : "warn",
    text: state.ready ? "Installed and ready." : "Installed, not set up yet. The settings below say what is missing.",
    saved:
      by && saved.at
        ? `Last saved by ${by} on ${formatDateTime(saved.at)} (${formatRelative(saved.at)}).`
        : "Not saved in the app yet.",
  };
}

const TONE_ICON: Record<Tone, { Icon: typeof Check; className: string }> = {
  ok: { Icon: Check, className: "text-success" },
  warn: { Icon: AlertTriangle, className: "text-warning" },
  off: { Icon: CircleSlash, className: "text-muted-foreground" },
};

function FeatureStatusRow({ feature, tone, text, saved }: { feature: OptionalFeature; tone: Tone; text: string; saved: string | null }) {
  const { Icon, className } = TONE_ICON[tone];
  return (
    <div
      data-testid={`feature-status-${feature}`}
      data-tone={tone}
      className={`flex items-start gap-3 rounded-md border px-3 py-2 text-xs ${
        tone === "warn" ? "border-warning/40 bg-warning/5" : "border-border"
      }`}
    >
      <Icon className={`mt-0.5 h-4 w-4 shrink-0 ${className}`} aria-hidden />
      <p className="min-w-0 flex-1 text-foreground">
        {text}
        {saved && <span className="text-muted-foreground" data-testid={`feature-saved-${feature}`}> {saved}</span>}
      </p>
    </div>
  );
}

/** One feature's card: name, installed and ready badges, help link, status row, then its settings. */
function FeatureCard({
  feature,
  state,
  saved,
  children,
}: {
  feature: OptionalFeature;
  state: FeatureReady;
  saved: { by?: string | null; at?: string | null };
  children: ReactNode;
}) {
  const info = FEATURE_INFO[feature];
  let body: ReactNode;
  if (state.loading) body = <Skeleton className="h-16 w-full" />;
  else if (state.error) body = <FeatureConfigError feature={feature} error={state.error} onRetry={state.refetch} />;
  else {
    const status = featureStatus(feature, state, saved);
    body = (
      <>
        <FeatureStatusRow feature={feature} {...status} />
        {state.installed && children}
      </>
    );
  }
  const loaded = !state.loading && !state.error;
  return (
    <Card id={info.settings.hash} className="max-w-4xl scroll-mt-4" data-testid={`feature-card-${feature}`}>
      <CardHeader className="pb-2">
        <CardTitle className="flex flex-wrap items-center gap-2 text-base">
          {info.name}
          {loaded && (
            <Badge variant={state.installed ? "secondary" : "outline"}>
              {state.installed ? "Installed" : "Not installed"}
            </Badge>
          )}
          {loaded && state.installed && (
            <Badge variant={state.ready ? "default" : "outline"}>{state.ready ? "Ready" : "Not ready"}</Badge>
          )}
          <HelpLink topic={info.helpSlug} label={`Help: ${info.nameInSentence}`} className="ml-auto" />
        </CardTitle>
      </CardHeader>
      <CardContent className="space-y-4">{body}</CardContent>
    </Card>
  );
}

export function TaxonomyFeatureCard() {
  const state = useTaxonomyReady();
  const { config } = state;
  return (
    <FeatureCard feature="taxonomy" state={state} saved={{ by: config?.updated_by, at: config?.updated_at }}>
      {config && <TaxonomyBuilderForm config={config} />}
    </FeatureCard>
  );
}

export function AssessmentFeatureCard() {
  const state = useAssessFeatureReady();
  const { data } = useGetAssessConfig({ query: { retry: false } });
  const config = data?.data;
  return (
    <FeatureCard feature="assessment" state={state} saved={{ by: config?.updated_by, at: config?.updated_at }}>
      <AssessBoundary>
        <AssessSettings />
      </AssessBoundary>
    </FeatureCard>
  );
}

export function OptionalFeaturesSection() {
  return (
    <section id="optional-features" aria-labelledby="optional-features-heading" className="space-y-3">
      <div className="max-w-4xl space-y-1">
        <h2 id="optional-features-heading" className="text-lg font-semibold tracking-tight">
          Optional features
        </h2>
        <p className="text-sm text-muted-foreground">
          These features are turned on when the app is installed. The settings of an installed feature are on its card.
        </p>
      </div>
      <TaxonomyFeatureCard />
      <AssessmentFeatureCard />
    </section>
  );
}
