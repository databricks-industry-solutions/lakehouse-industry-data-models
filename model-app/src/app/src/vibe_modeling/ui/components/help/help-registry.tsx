/**
 * The body of each written help topic, keyed by slug. `help.$topic.tsx`
 * renders `HELP_CONTENT[slug]`; a topic of `help-topics.ts` without a body
 * renders the coming-soon template. Kept apart from `help-topics.ts` so the
 * topic list (read by every page's Related footer) does not import the pages.
 */
import type { ComponentType } from "react";
import { FeatureGate } from "@/components/feature-gate";
import {
  AssessmentContent,
  FlowContent,
  ShortcutsContent,
  TaxonomyBuilderContent,
  VibesContent,
} from "@/components/help/help-content";
import { HelpPage } from "@/components/help/help-page";
import {
  ImportContent,
  RunDeleteVersionContent,
  RunInstallContent,
  RunNewBaseModelContent,
  RunsContent,
  RunUninstallContent,
  RunVibeContent,
  RunVibeEcmMvmContent,
} from "@/components/help/run-help-content";
import { RunParametersContent } from "@/components/help/run-parameters-content";
import { useFeatureReady, type OptionalFeature } from "@/lib/features";
import { getHelpTopic } from "@/components/help/help-topics";

/**
 * Like the help-index card: a feature's page shows once the feature is ready;
 * before that, the feature gate's notice says why not.
 */
function featureTopic(feature: OptionalFeature, slug: string, Content: ComponentType): ComponentType {
  function FeatureTopic() {
    const { ready } = useFeatureReady(feature);
    if (ready) return <Content />;
    return (
      <HelpPage title={getHelpTopic(slug)?.title ?? slug} related={["flow", "shortcuts"]}>
        <FeatureGate feature={feature} requireReady>{null}</FeatureGate>
      </HelpPage>
    );
  }
  return FeatureTopic;
}

export const HELP_CONTENT: Readonly<Record<string, ComponentType>> = {
  flow: FlowContent,
  assessment: featureTopic("assessment", "assessment", AssessmentContent),
  "taxonomy-builder": featureTopic("taxonomy", "taxonomy-builder", TaxonomyBuilderContent),
  vibes: VibesContent,
  runs: RunsContent,
  "run-new-base-model": RunNewBaseModelContent,
  "run-vibe": RunVibeContent,
  "run-vibe-ecm-mvm": RunVibeEcmMvmContent,
  "run-install": RunInstallContent,
  "run-uninstall": RunUninstallContent,
  "run-delete-version": RunDeleteVersionContent,
  import: ImportContent,
  "run-parameters": RunParametersContent,
  shortcuts: ShortcutsContent,
};
