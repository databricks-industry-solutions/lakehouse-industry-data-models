import { createFileRoute } from "@tanstack/react-router";
import { ComingSoonContent } from "@/components/help/help-content";
import { getHelpTopic } from "@/components/help/help-topics";
import { HELP_CONTENT } from "@/components/help/help-registry";
import { HelpPage } from "@/components/help/help-page";

export const Route = createFileRoute("/_sidebar/help/$topic")({
  component: HelpTopicPage,
});

function HelpTopicPage() {
  const { topic } = Route.useParams();
  return <HelpTopicBody slug={topic} />;
}

/** The page for `slug`: its registered body, the coming-soon template for a
 *  known topic without one, or a not-found page that keeps the reading chrome. */
export function HelpTopicBody({ slug }: { slug: string }) {
  const Content = Object.prototype.hasOwnProperty.call(HELP_CONTENT, slug) ? HELP_CONTENT[slug] : undefined;
  if (Content) return <Content />;
  if (getHelpTopic(slug)) return <ComingSoonContent slug={slug} />;
  return (
    <HelpPage title="Topic not found" related={["flow", "shortcuts"]}>
      <p className="text-sm text-muted-foreground">
        We couldn't find that help topic. It may have moved or been renamed.
      </p>
    </HelpPage>
  );
}
