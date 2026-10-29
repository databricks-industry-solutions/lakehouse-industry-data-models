import { createFileRoute, Outlet, useMatchRoute } from "@tanstack/react-router";
import { KickstartProgressBanner } from "@/components/industry/kickstart-progress-banner";
import { OobBanner } from "@/components/oob/oob-banner";
import { businessVisitKey, useRecordVisit } from "@/components/home/recent-items";

export const Route = createFileRoute("/_sidebar/businesses/$businessId")({
  component: () => {
    const { businessId } = Route.useParams();
    const matchRoute = useMatchRoute();
    const onVersionRoute = Boolean(
      matchRoute({ to: "/businesses/$businessId/model/$version/$scope", fuzzy: true }),
    );

    // Record a per-entity visit so the home "Jump back in" list can order by
    // recency. A visit inside a model version belongs to that version (the
    // version layout records it) and must not bump the parent business, so the
    // key is null there; leaving the version records the business again.
    useRecordVisit(onVersionRoute ? null : businessVisitKey(businessId));

    // Page-wide strips stack in one container above the child route; each
    // renders nothing when it has nothing to say.
    return (
      <>
        <div className="flex flex-col" data-testid="business-banners">
          <KickstartProgressBanner businessId={businessId} />
          <OobBanner businessId={businessId} />
        </div>
        <Outlet />
      </>
    );
  },
});
