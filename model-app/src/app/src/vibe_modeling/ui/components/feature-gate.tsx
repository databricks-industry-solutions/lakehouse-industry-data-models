/**
 * The one gate for the app's optional features (the Domain Taxonomy Builder
 * and the bronze assessment), and the pieces it is made of: the retry line
 * with its countdown (also the taxonomy busy countdown), the not-installed and
 * not-ready notices, the Settings button, and the inline notice for an error a
 * Settings change fixes.
 */
import { useState, type ReactNode } from "react";
import { Link } from "@tanstack/react-router";
import { AlertTriangle, Settings as SettingsIcon } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Skeleton } from "@/components/ui/skeleton";
import { ConfigMissingNotice } from "@/components/config-missing-notice";
import { StatusLine } from "@/components/settings/status-line";
import { apiErrorMessage, parseSettingsError } from "@/lib/api-error";
import { FEATURE_INFO, useFeatureReady, type OptionalFeature } from "@/lib/features";
import { useUserRole } from "@/lib/hooks";
import { nextTryIn, sentence } from "@/lib/retry-time";
import { useBusyAutoRetry, type BusyAutoRetry } from "@/lib/taxonomy/busy-retry";

/**
 * A retry line: what went wrong, when the next automatic try is, and the
 * buttons. Once the automatic tries are used up it shows `exhaustedText` and
 * the manual retry only. `onCancel` adds a Cancel button.
 */
export function RetryCountdown({
  lead,
  state,
  exhaustedText,
  retryLabel,
  cancelable = false,
  testId,
}: {
  lead: string;
  state: BusyAutoRetry;
  exhaustedText: string;
  /** Overrides the retry button's label ("Retry domains" where the step names it). */
  retryLabel?: string;
  cancelable?: boolean;
  testId: string;
}) {
  const message = state.exhausted
    ? exhaustedText
    : state.remainingS === null
      ? `${lead} Trying again…`
      : `${lead} ${sentence(nextTryIn(state.remainingS))}.`;
  return (
    <div className="flex flex-wrap items-center gap-2" data-testid={testId} data-exhausted={state.exhausted}>
      <StatusLine tone="warn">{message}</StatusLine>
      <Button type="button" size="sm" variant="outline" className="h-7" onClick={state.retryNow} disabled={state.retrying}>
        {retryLabel ?? (state.exhausted ? "Retry" : "Retry now")}
      </Button>
      {cancelable && (
        <Button type="button" size="sm" variant="ghost" className="h-7" onClick={state.cancel} disabled={state.retrying}>
          Cancel
        </Button>
      )}
    </div>
  );
}

const noop = () => undefined;

/**
 * The feature's config could not be read, so whether it is installed is
 * unknown: the error, retried on the shared busy schedule with a countdown,
 * and Try again.
 */
export function FeatureConfigError({
  feature,
  error,
  onRetry,
}: {
  feature: OptionalFeature;
  error: unknown;
  onRetry: () => Promise<unknown> | void;
}) {
  const state = useBusyAutoRetry(error ? "busy" : undefined, { retry: onRetry, cancel: noop });
  const reason = apiErrorMessage(error).replace(/[.\s]+$/, "");
  const lead = `Couldn't check whether the ${FEATURE_INFO[feature].nameInSentence} is available: ${reason}.`;
  return (
    <div className="space-y-2 text-sm" data-testid="feature-config-error" data-feature={feature}>
      <RetryCountdown
        lead={lead}
        state={state}
        exhaustedText={lead}
        retryLabel="Try again"
        testId={`feature-config-retry-${feature}`}
      />
    </div>
  );
}

/** The page shown in place of a feature the installation doesn't include. */
export function FeatureNotInstalled({ feature }: { feature: OptionalFeature }) {
  return (
    <p className="text-sm text-muted-foreground" data-testid="feature-not-installed" data-feature={feature}>
      {FEATURE_INFO[feature].notInstalledText}
    </p>
  );
}

/** The button to the feature's card in Settings → Platform. */
export function FeatureSettingsButton({ feature }: { feature: OptionalFeature }) {
  const { tab, hash } = FEATURE_INFO[feature].settings;
  return (
    <Button variant="outline" size="sm" asChild>
      <Link to="/settings" search={{ tab }} hash={hash} data-testid={`feature-settings-link-${feature}`}>
        <SettingsIcon className="mr-1.5 h-3.5 w-3.5" />
        Open Settings
      </Link>
    </Button>
  );
}

/**
 * The "not set up yet" notice of an installed feature. Everyone sees the
 * feature's sentence; app admins also see why (`missing`) and the Settings
 * button.
 */
export function FeatureNotReady({ feature }: { feature: OptionalFeature }) {
  const { missing, notReadyText } = useFeatureReady(feature);
  const isAdmin = useUserRole() === "app_admin";
  return (
    <div className="space-y-2 rounded-md border bg-muted/30 p-3 text-sm" data-testid="feature-not-ready" data-feature={feature}>
      <p>{notReadyText}</p>
      {isAdmin && (
        <>
          {missing.map((reason) => (
            <StatusLine key={reason} tone="warn">
              {reason}
            </StatusLine>
          ))}
          <FeatureSettingsButton feature={feature} />
        </>
      )}
    </div>
  );
}

/**
 * Inline notice for an error a Settings change fixes (`parseSettingsError`:
 * `config_missing`, `model_service_refused`, `setting_refused`): the sentence
 * and the Settings links, in the error colours. Anything else renders its
 * message alone.
 */
export function SettingsErrorNotice({ error, fallback, testId }: { error: unknown; fallback: string; testId?: string }) {
  const parsed = parseSettingsError(error);
  return (
    <div className="rounded-md border border-destructive/40 bg-destructive/5 p-3 text-destructive" role="alert" data-testid={testId}>
      {parsed ? (
        <ConfigMissingNotice missing={parsed.missing} message={parsed.message} />
      ) : (
        <p className="flex items-start gap-2 text-sm">
          <AlertTriangle className="mt-0.5 h-4 w-4 shrink-0" />
          {apiErrorMessage(error, fallback)}
        </p>
      )}
    </div>
  );
}

/**
 * Gate for an optional feature's page: a skeleton while its config loads, the
 * config error with a counted-down retry, the not-installed page, and with
 * `requireReady` the not-ready notice. With `keepMounted`, once the children
 * have shown they stay mounted, so a refusal later never throws away the
 * user's work. `frame` wraps the gate's own states (page chrome);
 * `className` is the default wrapper.
 */
export function FeatureGate({
  feature,
  requireReady = false,
  keepMounted = false,
  className,
  frame,
  children,
}: {
  feature: OptionalFeature;
  requireReady?: boolean;
  keepMounted?: boolean;
  className?: string;
  frame?: (state: ReactNode) => ReactNode;
  children: ReactNode;
}) {
  const { installed, ready, loading, error, refetch } = useFeatureReady(feature);
  const [entered, setEntered] = useState(false);
  const open = installed && (!requireReady || ready);
  if (keepMounted && open && !entered) setEntered(true);
  if (open || entered) return <>{children}</>;
  let state: ReactNode;
  if (loading) state = <Skeleton className="h-24 w-full" />;
  else if (error) state = <FeatureConfigError feature={feature} error={error} onRetry={refetch} />;
  else if (!installed) state = <FeatureNotInstalled feature={feature} />;
  else state = <FeatureNotReady feature={feature} />;
  return <>{frame ? frame(state) : <div className={className}>{state}</div>}</>;
}
