import { createFileRoute, Link } from "@tanstack/react-router";
import { Button } from "@/components/ui/button";
import { useGetBusinessSuspense, useListAssessmentsSuspense } from "@/lib/api";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { StatusBadge } from "@/components/assessment/status-badge";
import { formatDateTime } from "@/lib/date";
import { selector } from "@/lib/selector";
import { useBreadcrumbs } from "@/components/explorer/breadcrumb-context";
import { RelaunchButton } from "@/components/assessment/relaunch-button";
import { AssessBoundary } from "@/components/assessment/assess-boundary";
import { AssessedDomains } from "@/components/assessment/assessed-domains";
import { FeatureNotReady } from "@/components/feature-gate";
import { useAssessReady } from "@/lib/assessment";

export const Route = createFileRoute("/_sidebar/businesses/$businessId/assessments/")({
  component: AssessmentsPage,
});

function AssessmentsContent({ businessId }: { businessId: string }) {
  const { data: business } = useGetBusinessSuspense({
    params: { business_id: businessId },
    ...selector(),
  });
  const { data: batches } = useListAssessmentsSuspense({
    params: { business_id: businessId },
    ...selector(),
  });
  const { ready } = useAssessReady();
  useBreadcrumbs([
    { label: business.name, to: "/businesses/$businessId", params: { businessId } },
    { label: "Assessments" },
  ]);
  return (
    <div className="p-6 space-y-6">
      <div className="flex items-center justify-between">
        <h1 className="text-2xl font-semibold tracking-tight">Assessments</h1>
        {ready && (
          <Button asChild>
            <Link to="/businesses/$businessId/assessments/new" params={{ businessId }}>
              New assessment
            </Link>
          </Button>
        )}
      </div>
      {!ready && <FeatureNotReady feature="assessment" />}
      {batches.length === 0 ? (
        <p className="text-sm text-muted-foreground">No assessments yet.</p>
      ) : (
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead>Created</TableHead>
              <TableHead>Version</TableHead>
              <TableHead>Domains</TableHead>
              <TableHead>Status</TableHead>
              <TableHead>Created by</TableHead>
              <TableHead />
            </TableRow>
          </TableHeader>
          <TableBody>
            {batches.map((b) => (
              <TableRow key={b.id}>
                <TableCell>
                  <Link
                    to="/businesses/$businessId/assessments/$batchId"
                    params={{ businessId, batchId: b.id }}
                    className="text-primary hover:underline"
                  >
                    {formatDateTime(b.created_at)}
                  </Link>
                </TableCell>
                <TableCell>v{b.version} {b.scope}</TableCell>
                <TableCell>
                  <AssessedDomains names={b.domain_runs.map((r) => r.domain_name)} />
                </TableCell>
                <TableCell><StatusBadge status={b.status} /></TableCell>
                <TableCell>{b.created_by}</TableCell>
                <TableCell>
                  <RelaunchButton businessId={businessId} batch={b} />
                </TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      )}
    </div>
  );
}

function AssessmentsPage() {
  const { businessId } = Route.useParams();
  return (
    <AssessBoundary>
      <AssessmentsContent businessId={businessId} />
    </AssessBoundary>
  );
}
