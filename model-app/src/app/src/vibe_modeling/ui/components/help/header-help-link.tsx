import { Link, useLocation } from "@tanstack/react-router";
import { HelpCircle } from "lucide-react";
import { helpTopicForRoute } from "@/components/help/help-context";
import { useFeaturesReady } from "@/lib/features";

const CLASS_NAME =
  "flex h-8 w-8 items-center justify-center rounded-md text-muted-foreground transition-colors hover:bg-accent hover:text-foreground";

/** The top bar's Help icon: the top-level help page of the area the user is in, else the main help page. */
export function HeaderHelpLink() {
  const location = useLocation();
  const featureReady = useFeaturesReady();
  const topic = helpTopicForRoute(
    { pathname: location.pathname, search: location.search as Record<string, unknown> },
    featureReady,
  );
  const label = topic ? `Help: ${topic.title}` : "Help";
  const icon = <HelpCircle className="h-4 w-4" />;
  return topic ? (
    <Link
      to="/help/$topic"
      params={{ topic: topic.slug }}
      title={label}
      aria-label={label}
      data-testid="header-help-link"
      className={CLASS_NAME}
    >
      {icon}
    </Link>
  ) : (
    <Link to="/help" title={label} aria-label={label} data-testid="header-help-link" className={CLASS_NAME}>
      {icon}
    </Link>
  );
}
