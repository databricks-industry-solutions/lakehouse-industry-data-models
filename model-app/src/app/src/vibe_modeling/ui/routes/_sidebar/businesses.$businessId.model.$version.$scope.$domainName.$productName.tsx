import { createFileRoute, Link, useNavigate } from "@tanstack/react-router";
import { Suspense, useEffect, useRef } from "react";
import { ErrorBoundary } from "react-error-boundary";
import { usePrefetchQuery } from "@tanstack/react-query";
import {
  useGetBusinessSuspense,
  getModelSummary,
  getModelSummaryKey,
  useGetExplorerVersionsSuspense,
  useGetModelSummarySuspense,
  useGetProductDetailSuspense,
} from "@/lib/api";
import { isNotFoundError } from "@/lib/api-error";
import { selector } from "@/lib/selector";
import { liveDomainOptions } from "@/lib/domain-options";
import { TabDomainSelect } from "@/components/diagram/domain-select";
import { versionScopeLabel } from "@/lib/version-label";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Skeleton } from "@/components/ui/skeleton";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import { useBreadcrumbs } from "@/components/explorer/breadcrumb-context";
import {
  Tooltip,
  TooltipContent,
  TooltipProvider,
  TooltipTrigger,
} from "@/components/ui/tooltip";
import { Table2, Key } from "lucide-react";
import { ChangeBadge, changeRowClassName } from "@/components/explorer/change-badge";
import { FkLink } from "@/components/explorer/fk-link";
import { AddFeedbackButton } from "@/components/feedback/add-feedback-button";
import { buildFeedbackContext } from "@/components/feedback/feedback-context";
import { splitCommaList } from "@/lib/comma-list";

export const Route = createFileRoute(
  "/_sidebar/businesses/$businessId/model/$version/$scope/$domainName/$productName"
)({
  // `highlightColumn` (optional) is set by model-wide search when landing on a
  // column hit: the matching attribute row is highlighted + scrolled into view.
  validateSearch: (
    search: Record<string, unknown>,
  ): { highlightColumn?: string } =>
    typeof search.highlightColumn === "string" && search.highlightColumn
      ? { highlightColumn: search.highlightColumn }
      : {},
  component: () => {
    const { businessId, version, scope, domainName, productName } =
      Route.useParams();
    const { highlightColumn } = Route.useSearch();
    return (
      <div className="p-4 space-y-3">
        <ErrorBoundary
          // Own the "product doesn't exist in this version/scope/domain"
          // empty-state; re-throw everything else so the generic boundary
          // still surfaces real errors. Reset when the route params change
          // so navigating to another product clears the card.
          resetKeys={[businessId, version, scope, domainName, productName]}
          fallbackRender={({ error }) => {
            if (isNotFoundError(error)) {
              return (
                <ProductMissing
                  businessId={businessId}
                  version={version}
                  scope={scope}
                  domainName={domainName}
                  productName={productName}
                />
              );
            }
            throw error;
          }}
        >
          <Suspense fallback={<PageSkeleton />}>
            <ProductDetail
              businessId={businessId}
              version={version}
              scope={scope}
              domainName={domainName}
              productName={productName}
              highlightColumn={highlightColumn}
            />
          </Suspense>
        </ErrorBoundary>
      </div>
    );
  },
});

function ProductMissing({
  businessId,
  version,
  scope,
  domainName,
  productName,
}: {
  businessId: string;
  version: string;
  scope: string;
  domainName: string;
  productName: string;
}) {
  return (
    <Card>
      <CardHeader>
        <CardTitle>Product not found</CardTitle>
      </CardHeader>
      <CardContent className="space-y-4">
        <p className="text-sm text-muted-foreground">
          "{productName}" doesn't exist in domain "{domainName}" ({versionScopeLabel(version, scope)}). It
          may have been renamed or removed in this version.
        </p>
        <Button asChild variant="outline" size="sm">
          <Link
            to="/businesses/$businessId/model/$version/$scope/$domainName"
            params={{ businessId, version, scope, domainName }}
            search={{ tab: "products" }}
          >
            Back to {domainName}
          </Link>
        </Button>
      </CardContent>
    </Card>
  );
}

export function ProductDetail({
  businessId,
  version,
  scope,
  domainName,
  productName,
  highlightColumn,
}: {
  businessId: string;
  version: string;
  scope: string;
  domainName: string;
  productName: string;
  highlightColumn?: string;
}) {
  const navigate = useNavigate();
  // The domain dropdown's model summary starts loading now, alongside the
  // page's own queries, instead of after them.
  const summaryParams = { business_id: businessId, version_int: Number(version), scope };
  usePrefetchQuery({
    queryKey: getModelSummaryKey(summaryParams),
    queryFn: () => getModelSummary(summaryParams),
  });
  const { data: business } = useGetBusinessSuspense({
    params: { business_id: businessId },
    ...selector(),
  });
  const { data: product } = useGetProductDetailSuspense({
    params: {
      business_id: businessId,
      version_int: Number(version),
      scope,
      domain_name: domainName,
      product_name: productName,
    },
    ...selector(),
  });
  // Resolve the ModelVersion UUID for the current `(version, scope)` so
  // feedback captured here is version-filterable on the Feedback tab.
  const { data: _allVersions } = useGetExplorerVersionsSuspense({
    params: { business_id: businessId },
    ...selector(),
  });
  const currentVersionId =
    _allVersions.find(
      (v) => v.version === Number(version) && ((v as any).scope || "") === scope,
    )?.id ?? _allVersions.find((v) => v.version === Number(version))?.id;

  // Jump to another domain: a pick opens that domain's page on its Products
  // tab (push, so Back returns to this product).
  const { data: model } = useGetModelSummarySuspense({
    params: summaryParams,
    ...selector(),
  });
  const domainList = liveDomainOptions(model.domains);
  const openDomain = (next: string | null) => {
    if (!next || next === domainName) return;
    navigate({
      to: "/businesses/$businessId/model/$version/$scope/$domainName",
      params: { businessId, version, scope, domainName: next },
      search: { tab: "products" },
    });
  };

  // Scroll the search-highlighted column into view once the product loads.
  const highlightRef = useRef<HTMLTableRowElement>(null);
  useEffect(() => {
    if (highlightColumn && highlightRef.current) {
      highlightRef.current.scrollIntoView({ block: "center", behavior: "smooth" });
    }
  }, [highlightColumn, product]);

  useBreadcrumbs([
    {
      label: business.name,
      to: "/businesses/$businessId",
      params: { businessId },
    },
    {
      label: "Explorer",
      to: "/businesses/$businessId/explorer",
      params: { businessId },
    },
    {
      label: versionScopeLabel(version, scope),
      to: "/businesses/$businessId/model/$version/$scope",
      params: { businessId, version, scope },
    },
    {
      label: domainName,
      to: "/businesses/$businessId/model/$version/$scope/$domainName",
      params: { businessId, version, scope, domainName },
      search: { tab: "products" },
    },
    { label: productName },
  ]);

  return (
    <>

      <div>
        <div className="flex items-center gap-3">
          <Table2 className="h-6 w-6" />
          <h1 className="text-2xl font-semibold tracking-tight">
            {domainName}.{product.table_name || product.name}
          </h1>
          {product.type && <Badge variant="secondary">{product.type}</Badge>}
          {product.data_type && (
            <Badge variant="outline">{product.data_type}</Badge>
          )}
          <AddFeedbackButton
            businessId={businessId}
            versionId={currentVersionId}
            getContext={() =>
              buildFeedbackContext({ subject: { domain: domainName, product: product.name } })
            }
            className="ml-auto"
          />
        </div>
        {product.description && (
          <p className="text-muted-foreground mt-2 max-w-3xl">
            {product.description}
          </p>
        )}
        <div className="flex gap-4 mt-2 text-sm text-muted-foreground">
          {product.primary_key && (
            <span className="inline-flex items-center gap-1">
              <Key className="h-3 w-3 text-warning" />
              PK: {product.primary_key}
            </span>
          )}
          {product.reference && <span>Ref: {product.reference}</span>}
        </div>
      </div>

      <TabDomainSelect
        domains={domainList}
        value={domainName}
        onChange={openDomain}
        allowAll={false}
      />

      <Card>
        <CardHeader>
          <CardTitle className="text-base">
            Attributes ({(product.attributes ?? []).length})
          </CardTitle>
        </CardHeader>
        <CardContent>
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead className="w-8"></TableHead>
                <TableHead>Column Name</TableHead>
                <TableHead>Type</TableHead>
                <TableHead>Description</TableHead>
                <TableHead>Glossary Term</TableHead>
                <TableHead>Tags</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {(product.attributes ?? []).map((attr) => {
                const isDeleted = attr.change_status === "deleted";
                const changeClass = changeRowClassName(attr.change_status);
                const pkFkClass = !changeClass
                  ? attr.is_primary_key
                    ? "bg-warning/5"
                    : attr.is_foreign_key
                      ? "bg-info/5"
                      : ""
                  : changeClass;
                const isHighlighted =
                  !!highlightColumn &&
                  (attr.name === highlightColumn || attr.column_name === highlightColumn);
                return (
                <TableRow
                  key={attr.column_name}
                  ref={isHighlighted ? highlightRef : undefined}
                  className={`${pkFkClass} ${isHighlighted ? "ring-2 ring-inset ring-primary bg-primary/5" : ""}`}
                >
                  <TableCell className="text-center">
                    <span className="inline-flex items-center gap-1">
                      {attr.is_primary_key && (
                        <Key className="h-4 w-4 text-warning" />
                      )}
                      {attr.is_foreign_key && !attr.is_primary_key && attr.foreign_key_to && (
                        <FkLink
                          variant="icon"
                          foreignKeyTo={attr.foreign_key_to}
                          businessId={businessId}
                          version={version}
                          scope={scope}
                        />
                      )}
                      <ChangeBadge status={attr.change_status} />
                    </span>
                  </TableCell>
                  <TableCell className={`font-mono text-sm font-medium ${isDeleted ? "line-through text-muted-foreground" : ""}`}>
                    {attr.column_name}
                  </TableCell>
                  <TableCell className="text-sm text-muted-foreground font-mono">
                    {attr.type}
                  </TableCell>
                  <TableCell className="text-sm max-w-sm">
                    {attr.description && (
                      <TooltipProvider delayDuration={300}>
                        <Tooltip>
                          <TooltipTrigger asChild>
                            <div className="max-h-16 overflow-y-auto cursor-default">
                              {attr.description}
                            </div>
                          </TooltipTrigger>
                          <TooltipContent side="bottom" className="max-w-md">
                            <p className="text-xs">{attr.description}</p>
                          </TooltipContent>
                        </Tooltip>
                      </TooltipProvider>
                    )}
                  </TableCell>
                  <TableCell className="text-sm text-muted-foreground">
                    {attr.business_glossary_term}
                  </TableCell>
                  <TableCell>
                    {splitCommaList(attr.tags).map((tag) => (
                      <Badge key={tag} variant="outline" className="mr-1 text-xs">
                        {tag}
                      </Badge>
                    ))}
                  </TableCell>
                </TableRow>
                );
              })}
            </TableBody>
          </Table>
        </CardContent>
      </Card>
    </>
  );
}

function PageSkeleton() {
  return (
    <div className="space-y-6">
      <Skeleton className="h-8 w-64" />
      <Skeleton className="h-10 w-96" />
      <Skeleton className="h-96 w-full" />
    </div>
  );
}
