import { createFileRoute, Link } from "@tanstack/react-router";
import { ArrowLeft } from "lucide-react";
import { Button } from "@/components/ui/button";
import { useGetBusinessSuspense } from "@/lib/api";
import { selector } from "@/lib/selector";
import { useBreadcrumbs } from "@/components/explorer/breadcrumb-context";
import { AssessBoundary } from "@/components/assessment/assess-boundary";
import { AssessmentWizard } from "@/components/assessment/assessment-wizard";
import { FeatureGate } from "@/components/feature-gate";

type NewAssessmentSearch = { versionId?: string; domainId?: string };

export const Route = createFileRoute("/_sidebar/businesses/$businessId/assessments/new")({
  validateSearch: (search: Record<string, unknown>): NewAssessmentSearch => ({
    versionId: typeof search.versionId === "string" && search.versionId ? search.versionId : undefined,
    domainId: typeof search.domainId === "string" && search.domainId ? search.domainId : undefined,
  }),
  component: NewAssessmentPage,
});

function NewAssessmentContent({ businessId }: { businessId: string }) {
  const { versionId, domainId } = Route.useSearch();
  const { data: business } = useGetBusinessSuspense({
    params: { business_id: businessId },
    ...selector(),
  });
  useBreadcrumbs([
    { label: business.name, to: "/businesses/$businessId", params: { businessId } },
    { label: "Assessments", to: "/businesses/$businessId/assessments", params: { businessId } },
    { label: "New" },
  ]);
  return <AssessmentWizard businessId={businessId} versionId={versionId} domainId={domainId} />;
}

function NewAssessmentPage() {
  const { businessId } = Route.useParams();
  return (
    <div className="p-6 space-y-6">
      <div className="flex items-center gap-4">
        <Button variant="ghost" size="icon" asChild>
          <Link to="/businesses/$businessId/assessments" params={{ businessId }}>
            <ArrowLeft className="h-4 w-4" />
          </Link>
        </Button>
        <h1 className="text-2xl font-semibold tracking-tight">New assessment</h1>
      </div>
      <FeatureGate feature="assessment" requireReady>
        <AssessBoundary>
          <NewAssessmentContent businessId={businessId} />
        </AssessBoundary>
      </FeatureGate>
    </div>
  );
}
