import { Component, Suspense, useState, type ReactNode } from "react";
import { Link, useParams } from "@tanstack/react-router";
import { Badge } from "@/components/ui/badge";
import { Skeleton } from "@/components/ui/skeleton";
import { cn } from "@/lib/utils";
import { versionBrandLabel } from "@/lib/version-label";
import {
  useGetExplorerVersions,
  useGetModelSummary,
  useGetDomainDetail,
  useGetBusinessSuspense,
} from "@/lib/api";
import { selector } from "@/lib/selector";
import {
  ChevronDown,
  ChevronRight,
  Database,
  FolderOpen,
  GitBranch,
  Layers,
  Table2,
} from "lucide-react";

/**
 * Left-sidebar business tree: Business → Versions → Domains → Products.
 * Rendered inside the sidebar when a business route is active.
 */
export function BusinessTree({ businessId }: { businessId: string }) {
  // The sidebar mounts BusinessTree for every /businesses/<id>/* URL,
  // including stale URLs whose business no longer exists. A throw from
  // useGetBusinessSuspense would bubble past the route's errorComponent
  // and trigger the global default ("Something went wrong!"), hiding
  // the page-level 404 copy. Catch silently here so the page's own
  // errorComponent renders the friendly 404.
  return (
    <SilentBoundary>
      <Suspense fallback={<Skeleton className="h-6 w-full" />}>
        <BusinessHeader businessId={businessId} />
      </Suspense>
    </SilentBoundary>
  );
}

class SilentBoundary extends Component<
  { children: ReactNode },
  { hasError: boolean }
> {
  state = { hasError: false };
  static getDerivedStateFromError() {
    return { hasError: true };
  }
  render() {
    if (this.state.hasError) return null;
    return this.props.children;
  }
}

function BusinessHeader({ businessId }: { businessId: string }) {
  const { data: business } = useGetBusinessSuspense({
    params: { business_id: businessId },
    ...selector(),
  });

  return (
    <div className="space-y-1">
      <Link
        to="/businesses/$businessId/explorer"
        params={{ businessId }}
        className="flex items-center gap-2 px-2 py-1.5 text-sm font-semibold truncate hover:bg-sidebar-accent rounded-md"
      >
        {business.name}
      </Link>
      <VersionsList businessId={businessId} />
    </div>
  );
}

function VersionsList({ businessId }: { businessId: string }) {
  const params = useParams({ strict: false }) as Record<string, string>;
  const activeVersion = params.version;
  const activeScope = params.scope;

  const { data: result, isLoading } = useGetExplorerVersions({
    params: { business_id: businessId },
  });
  const versions = result?.data ?? [];

  if (isLoading) return <Skeleton className="h-20 w-full mx-2" />;
  if (versions.length === 0) {
    return (
      <p className="px-2 text-xs text-muted-foreground">No model versions</p>
    );
  }

  // Sort: version descending; tie-broken by scope ascending (ECM before MVM
  // alphabetically, but spec asks "MVM and ECM at same version adjacent" —
  // either ordering keeps them grouped, alpha is stable).
  const sorted = [...versions].sort((a, b) => {
    if (b.version !== a.version) return b.version - a.version;
    return ((a as any).scope || "").localeCompare((b as any).scope || "");
  });

  return (
    <div className="space-y-0.5">
      {sorted.map((v) => (
        <VersionItem
          key={v.id}
          businessId={businessId}
          version={v}
          isActive={
            activeVersion === String(v.version)
            && (!activeScope || activeScope === ((v as any).scope || ""))
          }
        />
      ))}
    </div>
  );
}

function VersionItem({
  businessId,
  version: v,
  isActive,
}: {
  businessId: string;
  version: {
    id: string;
    version: number;
    scope?: string;
    status: string;
    is_base?: boolean;
    parent_deleted?: boolean;
    confidence_score?: number | null;
  };
  isActive: boolean;
}) {
  const [expanded, setExpanded] = useState(isActive);

  // Default scope to "mvm" so the link is well-formed even on legacy rows
  // missing a scope value. The route guard validates scope ∈ {ecm, mvm}.
  const versionScope = v.scope || "mvm";

  return (
    <div>
      <div className="flex items-center">
        <button
          onClick={() => setExpanded((e) => !e)}
          className="p-1 hover:bg-sidebar-accent rounded shrink-0"
        >
          {expanded ? (
            <ChevronDown className="h-3 w-3" />
          ) : (
            <ChevronRight className="h-3 w-3" />
          )}
        </button>
        <Link
          to="/businesses/$businessId/model/$version/$scope"
          params={{ businessId, version: String(v.version), scope: versionScope }}
          search={{ tab: "overview" }}
          className={cn(
            "flex items-center gap-1.5 px-1.5 py-1 rounded-md text-sm flex-1 min-w-0 transition-colors",
            isActive
              ? "bg-sidebar-accent text-sidebar-accent-foreground font-medium"
              : "hover:bg-sidebar-accent/50 text-sidebar-foreground"
          )}
        >
          <GitBranch className="h-3.5 w-3.5 shrink-0" />
          <span className="truncate">v{v.version}</span>
          {v.scope && (
            <Badge
              className={cn(
                "text-[10px] px-1 py-0 shrink-0",
                v.scope === "ecm"
                  ? "bg-muted text-foreground border-border"
                  : "bg-info/10 text-info border-info/30"
              )}
              variant="outline"
            >
              {v.scope.toUpperCase()}
            </Badge>
          )}
          <Badge
            variant={v.is_base ? "default" : "secondary"}
            className="text-[10px] px-1 py-0 shrink-0"
          >
            {versionBrandLabel(v)}
          </Badge>
        </Link>
      </div>

      {expanded && (
        <DomainsList
          businessId={businessId}
          version={String(v.version)}
          scope={versionScope}
        />
      )}
    </div>
  );
}

function DomainsList({
  businessId,
  version,
  scope,
}: {
  businessId: string;
  version: string;
  scope: string;
}) {
  const params = useParams({ strict: false }) as Record<string, string>;
  const activeDomain = params.domainName;

  const { data: result, isLoading } = useGetModelSummary({
    params: { business_id: businessId, version_int: Number(version), scope },
  });
  const model = result?.data;
  const domains = (model?.domains ?? []).filter(
    (d) => d.change_status !== "deleted"
  );

  if (isLoading) return <Skeleton className="h-12 w-full ml-6 mr-2" />;

  return (
    <div className="ml-4 pl-2 border-l border-border/40 space-y-0.5 mt-0.5">
      {/* All domains link */}
      <Link
        to="/businesses/$businessId/model/$version/$scope"
        params={{ businessId, version, scope }}
        search={{ tab: "overview" }}
        className={cn(
          "flex items-center gap-1.5 px-1.5 py-1 rounded-md text-xs transition-colors",
          !activeDomain
            ? "bg-sidebar-accent/60 text-sidebar-accent-foreground font-medium"
            : "hover:bg-sidebar-accent/50 text-muted-foreground"
        )}
      >
        <Layers className="h-3 w-3 shrink-0" />
        <span>All Domains</span>
        <Badge variant="outline" className="ml-auto text-[9px] px-1 py-0">
          {domains.length}
        </Badge>
      </Link>

      {domains.map((d) => (
        <DomainItem
          key={d.name}
          businessId={businessId}
          version={version}
          scope={scope}
          domain={d}
          isActive={activeDomain === d.name}
        />
      ))}
    </div>
  );
}

function DomainItem({
  businessId,
  version,
  scope,
  domain,
  isActive,
}: {
  businessId: string;
  version: string;
  scope: string;
  domain: {
    name: string;
    product_count?: number;
    subdomains?: { name: string; product_count?: number }[];
  };
  isActive: boolean;
}) {
  const [expanded, setExpanded] = useState(isActive);

  return (
    <div>
      <div className="flex items-center">
        <button
          onClick={() => setExpanded((e) => !e)}
          className="p-0.5 hover:bg-sidebar-accent rounded shrink-0"
        >
          {expanded ? (
            <ChevronDown className="h-2.5 w-2.5" />
          ) : (
            <ChevronRight className="h-2.5 w-2.5" />
          )}
        </button>
        <Link
          to="/businesses/$businessId/model/$version/$scope/$domainName"
          params={{ businessId, version, scope, domainName: domain.name }}
          search={{ tab: "products" }}
          className={cn(
            "flex items-center gap-1.5 px-1.5 py-1 rounded-md text-xs flex-1 min-w-0 transition-colors",
            isActive
              ? "bg-sidebar-accent/60 text-sidebar-accent-foreground font-medium"
              : "hover:bg-sidebar-accent/50 text-muted-foreground"
          )}
        >
          <Database className="h-3 w-3 shrink-0" />
          <span className="truncate">{domain.name}</span>
          {domain.product_count != null && (
            <Badge
              variant="outline"
              className="ml-auto text-[9px] px-1 py-0 shrink-0"
            >
              {domain.product_count}
            </Badge>
          )}
        </Link>
      </div>

      {expanded && (
        <ProductsList
          businessId={businessId}
          version={version}
          scope={scope}
          domainName={domain.name}
          subdomains={domain.subdomains}
        />
      )}
    </div>
  );
}

function ProductsList({
  businessId,
  version,
  scope,
  domainName,
  subdomains,
}: {
  businessId: string;
  version: string;
  scope: string;
  domainName: string;
  subdomains?: { name: string; product_count?: number }[];
}) {
  const params = useParams({ strict: false }) as Record<string, string>;
  const activeProduct = params.productName;

  const { data: result, isLoading } = useGetDomainDetail({
    params: {
      business_id: businessId,
      version_int: Number(version),
      scope,
      domain_name: domainName,
    },
  });
  const products = result?.data?.products ?? [];

  if (isLoading) return <Skeleton className="h-8 w-full ml-4" />;

  // Group by subdomain if any exist
  const hasSubdomains = (subdomains ?? []).length > 0;

  if (hasSubdomains) {
    const grouped = new Map<string, typeof products>();
    for (const p of products) {
      const sd = (p as any).subdomain || "";
      if (!grouped.has(sd)) grouped.set(sd, []);
      grouped.get(sd)!.push(p);
    }

    const ungrouped = grouped.get("") ?? [];
    grouped.delete("");
    const sortedGroups = [...grouped.entries()].sort((a, b) =>
      a[0].localeCompare(b[0])
    );

    return (
      <div className="ml-3 pl-2 border-l border-border/30 space-y-0.5 mt-0.5">
        {ungrouped.map((p) => (
          <ProductLink
            key={p.name}
            businessId={businessId}
            version={version}
            scope={scope}
            domainName={domainName}
            product={p}
            isActive={activeProduct === p.name}
          />
        ))}
        {sortedGroups.map(([sd, items]) => (
          <SubdomainGroup
            key={sd}
            name={sd}
            products={items}
            businessId={businessId}
            version={version}
            scope={scope}
            domainName={domainName}
            activeProduct={activeProduct}
          />
        ))}
      </div>
    );
  }

  return (
    <div className="ml-3 pl-2 border-l border-border/30 space-y-0.5 mt-0.5">
      {products.map((p) => (
        <ProductLink
          key={p.name}
          businessId={businessId}
          version={version}
          scope={scope}
          domainName={domainName}
          product={p}
          isActive={activeProduct === p.name}
        />
      ))}
    </div>
  );
}

function SubdomainGroup({
  name,
  products,
  businessId,
  version,
  scope,
  domainName,
  activeProduct,
}: {
  name: string;
  products: any[];
  businessId: string;
  version: string;
  scope: string;
  domainName: string;
  activeProduct?: string;
}) {
  const [expanded, setExpanded] = useState(
    products.some((p) => p.name === activeProduct)
  );

  return (
    <div>
      <button
        onClick={() => setExpanded((e) => !e)}
        className="flex items-center gap-1.5 px-1.5 py-0.5 text-[10px] text-muted-foreground hover:bg-sidebar-accent/50 rounded w-full"
      >
        {expanded ? (
          <ChevronDown className="h-2.5 w-2.5" />
        ) : (
          <ChevronRight className="h-2.5 w-2.5" />
        )}
        <FolderOpen className="h-2.5 w-2.5" />
        <span className="truncate">{name}</span>
        <Badge variant="outline" className="ml-auto text-[9px] px-1 py-0">
          {products.length}
        </Badge>
      </button>
      {expanded &&
        products.map((p) => (
          <ProductLink
            key={p.name}
            businessId={businessId}
            version={version}
            scope={scope}
            domainName={domainName}
            product={p}
            isActive={activeProduct === p.name}
          />
        ))}
    </div>
  );
}

function ProductLink({
  businessId,
  version,
  scope,
  domainName,
  product,
  isActive,
}: {
  businessId: string;
  version: string;
  scope: string;
  domainName: string;
  product: { name: string };
  isActive: boolean;
}) {
  return (
    <Link
      to="/businesses/$businessId/model/$version/$scope/$domainName/$productName"
      params={{ businessId, version, scope, domainName, productName: product.name }}
      className={cn(
        "flex items-center gap-1.5 px-1.5 py-0.5 rounded text-[11px] transition-colors",
        isActive
          ? "bg-sidebar-accent/60 text-sidebar-accent-foreground font-medium"
          : "hover:bg-sidebar-accent/50 text-muted-foreground"
      )}
    >
      <Table2 className="h-2.5 w-2.5 shrink-0" />
      <span className="truncate">{product.name}</span>
    </Link>
  );
}
