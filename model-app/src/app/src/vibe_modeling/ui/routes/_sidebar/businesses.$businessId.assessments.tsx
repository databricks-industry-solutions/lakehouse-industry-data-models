import { createFileRoute, Outlet } from "@tanstack/react-router";
import { FeatureGate } from "@/components/feature-gate";

export const Route = createFileRoute("/_sidebar/businesses/$businessId/assessments")({
  component: () => (
    <FeatureGate feature="assessment" className="p-6">
      <Outlet />
    </FeatureGate>
  ),
});
