/**
 * The app's optional, install-time features (the Domain Taxonomy Builder and
 * the bronze assessment) behind one readiness shape, so the feature gate, the
 * Settings "Optional features" section, the help index and the entry points
 * read them the same way.
 */
import type { QueryKey } from "@tanstack/react-query";
import {
  getAssessConfigKey,
  getTaxonomyConfigKey,
  useGetRunChangeReviewConfig,
  useGetTaxonomyConfig,
  type TaxonomyConfigOut,
} from "@/lib/api";
import { useAssessReady } from "@/lib/assessment";

export type OptionalFeature = "taxonomy" | "assessment";

/** Whether an optional feature is installed and ready, from its ungated config route. */
export interface FeatureReady {
  installed: boolean;
  ready: boolean;
  loading: boolean;
  /** The config fetch failed: whether the feature is installed is unknown (not "not installed"). */
  error: unknown;
  /** Why it is not ready, for admins (empty when ready or when there is nothing specific to say). */
  missing: string[];
  /** The sentence everyone sees while it is installed but not ready. */
  notReadyText: string;
  refetch: () => Promise<unknown>;
}

/** Where a feature's settings live: the Platform tab, at the feature's card. */
export interface SettingsTarget {
  tab: "platform";
  hash: string;
}

export interface FeatureInfo {
  /** The name users see, as a title (card heading). */
  name: string;
  /** The same name inside a sentence. */
  nameInSentence: string;
  /** The page shown in place of the feature when the installation doesn't include it. */
  notInstalledText: string;
  /** The `install.sh` flag that turns it on. */
  installFlag: string;
  /** Help topic slug. */
  helpSlug: string;
  settings: SettingsTarget;
}

export const FEATURE_INFO: Record<OptionalFeature, FeatureInfo> = {
  taxonomy: {
    name: "Domain Taxonomy Builder",
    nameInSentence: "Domain Taxonomy Builder",
    notInstalledText:
      "This installation doesn't include the Domain Taxonomy Builder. It is enabled at install time.",
    installFlag: "--enable-taxonomy-builder",
    helpSlug: "taxonomy-builder",
    settings: { tab: "platform", hash: "feature-taxonomy" },
  },
  assessment: {
    name: "Bronze assessment",
    nameInSentence: "bronze assessment",
    notInstalledText:
      "This installation doesn't include the bronze assessment skill. It is enabled at install time.",
    installFlag: "--enable-assessment",
    helpSlug: "assessment",
    settings: { tab: "platform", hash: "feature-assessment" },
  },
};

/** The Settings link to a feature's card: `/settings?tab=platform#feature-<feature>`. */
export function featureSettingsUrl(feature: OptionalFeature): string {
  const { tab, hash } = FEATURE_INFO[feature].settings;
  return `/settings?tab=${tab}#${hash}`;
}

/**
 * The feature each feature setting key belongs to: the keys a 400 refusal or
 * a `config_missing` item names (`taxonomy_llm` from the backend's
 * `core/_errors.CONFIG_REQUIREMENTS`, the assessment Save's field keys).
 */
export const SETTING_FEATURE: Readonly<Record<string, OptionalFeature>> = {
  taxonomy_llm: "taxonomy",
  reader_application_id: "assessment",
  warehouse_id: "assessment",
};

/** The query key of each feature's config (its readiness). */
export const FEATURE_CONFIG_KEY: Record<OptionalFeature, () => QueryKey> = {
  taxonomy: () => getTaxonomyConfigKey(),
  assessment: () => getAssessConfigKey(),
};

export const TAXONOMY_NO_SERVICE_TEXT = "An admin must choose a model service in Settings → Platform.";
export const TAXONOMY_UNAVAILABLE_TEXT =
  "The Domain Taxonomy Builder is unavailable right now. It is checked again automatically.";
export const ASSESS_NOT_READY_TEXT = "Assessment isn't set up yet. Ask your administrator.";

/**
 * The taxonomy builder's readiness (`GET /config/taxonomy`). Not ready means
 * no model service is chosen, or its last test call was refused; the server
 * re-probes a refusal older than 5 minutes, so non-admins are told it is
 * checked again automatically and admins see the refusal itself.
 */
export function useTaxonomyReady(): FeatureReady & { config: TaxonomyConfigOut | undefined } {
  const { data, isLoading, error, refetch } = useGetTaxonomyConfig({ query: { retry: false } });
  const config = data?.data;
  const refused = config?.model_service ? config.last_check?.message : undefined;
  return {
    config,
    installed: config?.installed === true,
    ready: config?.ready === true,
    loading: isLoading,
    error: config ? null : (error ?? null),
    missing: refused ? [refused] : [],
    notReadyText: config?.model_service ? TAXONOMY_UNAVAILABLE_TEXT : TAXONOMY_NO_SERVICE_TEXT,
    refetch: () => refetch(),
  };
}

/** The assessment's readiness in the shared shape (`useAssessReady` plus its not-ready sentence). */
export function useAssessFeatureReady(): FeatureReady {
  return { ...useAssessReady(), notReadyText: ASSESS_NOT_READY_TEXT };
}

const READY_HOOKS: Record<OptionalFeature, () => FeatureReady> = {
  taxonomy: useTaxonomyReady,
  assessment: useAssessFeatureReady,
};

/** The readiness of `feature`. A component passes one feature for its whole life, so the hook order is stable. */
export function useFeatureReady(feature: OptionalFeature): FeatureReady {
  return READY_HOOKS[feature]();
}

/** Whether each optional feature is ready, for a screen that gates on all of them (the help index, the header Help link). */
export function useFeaturesReady(): Record<OptionalFeature, boolean> {
  const { ready: assessment } = useAssessReady();
  const { ready: taxonomy } = useTaxonomyReady();
  return { assessment, taxonomy };
}

/**
 * Whether the run change review is on (`GET /config/run-change-review`,
 * `AppConfig.run_change_review_enabled`): the Changes card on the run page,
 * the version Overview summary line and the help about them. Hidden until its
 * redesign, so it is no `OptionalFeature`: no install flag, no Settings card,
 * no help topic. False while the read is pending or failed, so none of the
 * review renders or fetches until the server says it is on.
 */
export function useRunChangeReviewEnabled(): boolean {
  const { data } = useGetRunChangeReviewConfig({ query: { retry: false, staleTime: Infinity } });
  return data?.data?.enabled === true;
}
