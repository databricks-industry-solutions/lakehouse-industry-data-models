import { Link } from "@tanstack/react-router";
import { ClipboardCheck } from "lucide-react";
import { Button } from "@/components/ui/button";
import { useAssessReady } from "@/lib/assessment";
import {
  Tooltip,
  TooltipContent,
  TooltipProvider,
  TooltipTrigger,
} from "@/components/ui/tooltip";

const NOT_INSTALLED_HINT =
  "This version isn't installed yet. Install it into a catalog first; Assess reads the installed tables.";

/**
 * Entry point into the assessment wizard from a model version / domain page.
 * Hidden unless the optional assessment skill is ready (`useAssessReady`).
 * Disabled until the version is installed (deployed with a catalog), since the
 * assessment reads the installed tables.
 */
export function AssessButton({
  businessId,
  versionId,
  domainId,
  installed,
}: {
  businessId: string;
  versionId: string;
  domainId?: string;
  installed: boolean;
}) {
  const { ready } = useAssessReady();
  if (!ready) return null;
  if (!installed) {
    return (
      <TooltipProvider delayDuration={200}>
        <Tooltip>
          <TooltipTrigger asChild>
            <span className="inline-flex" tabIndex={0}>
              <Button variant="outline" size="sm" disabled>
                <ClipboardCheck className="mr-1.5 h-4 w-4" />
                Assess
              </Button>
            </span>
          </TooltipTrigger>
          <TooltipContent>
            <p className="max-w-xs text-sm">{NOT_INSTALLED_HINT}</p>
          </TooltipContent>
        </Tooltip>
      </TooltipProvider>
    );
  }
  return (
    <Button variant="outline" size="sm" asChild>
      <Link
        to="/businesses/$businessId/assessments/new"
        params={{ businessId }}
        search={{ versionId, domainId }}
      >
        <ClipboardCheck className="mr-1.5 h-4 w-4" />
        Assess
      </Link>
    </Button>
  );
}
