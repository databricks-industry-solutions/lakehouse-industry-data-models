import { useState, useMemo, useRef, useCallback, useEffect } from "react";
import { useSuspenseQuery } from "@tanstack/react-query";
import { Button } from "@/components/ui/button";
import { Maximize2, Minimize2, ZoomIn, ZoomOut } from "lucide-react";
import {
  getDomainPalette,
  getProductTypeColors,
} from "@/components/diagram/constants";
import { diagramColors } from "@/components/diagram/diagram-colors";
import { DomainSelect } from "@/components/diagram/domain-select";
import { ProductTypeLegend } from "@/components/diagram/product-type-legend";
import { getDomainDetail, getModelSummary } from "@/lib/api";
import { liveDomainOptions, type DomainOption } from "@/lib/domain-options";

interface GraphNode {
  id: string;
  domain: string;
  name: string;
  productType: string;
  fkCount: number;
  attrCount: number;
  x: number;
  y: number;
}

interface GraphEdge {
  source: string;
  target: string;
  column: string;
  crossDomain: boolean;
}

interface DomainInfo {
  name: string;
  division?: string;
  products: Array<{
    name: string;
    table_name: string;
    type?: string;
    attribute_count: number;
    fk_count: number;
    fk_targets: string[];
    change_status?: string;
    attributes?: Array<{
      name: string;
      type: string;
      is_primary_key?: boolean;
      foreign_key_to?: string;
    }>;
  }>;
}

const domainLabel = (name: string, division?: string) =>
  division ? `${name} (${division})` : name;

async function fetchDomainDetail(
  businessId: string,
  version: string,
  scope: string,
  domainName: string
): Promise<DomainInfo> {
  const resp = await getDomainDetail({
    business_id: businessId,
    version_int: Number(version),
    scope,
    domain_name: domainName,
  });
  const data = resp.data as unknown as DomainInfo & { division?: string };
  return { ...data, division: data.division ?? "" };
}

async function fetchModelSummary(
  businessId: string,
  version: string,
  scope: string
): Promise<{
  name: string;
  domain_count: number;
  product_count: number;
  attribute_count: number;
  fk_count: number;
  domains: Array<{ name: string; product_count: number; division?: string | null; change_status?: string | null }>;
}> {
  const resp = await getModelSummary({
    business_id: businessId,
    version_int: Number(version),
    scope,
  });
  return resp.data as unknown as {
    name: string;
    domain_count: number;
    product_count: number;
    attribute_count: number;
    fk_count: number;
    domains: Array<{ name: string; product_count: number; division?: string | null; change_status?: string | null }>;
  };
}

export function OntologyGraph({
  businessId,
  version,
  scope,
  domainFilter,
  onDomainChange,
  onDomainPick,
}: {
  businessId: string;
  version: string;
  scope: string;
  domainFilter?: string;
  /** Reports the domain the graph shows (null for every domain), so the
   *  page's Add-feedback can capture it. */
  onDomainChange?: (domain: string | null) => void;
  /** When set, the host owns the domain dropdown: it shows `domainFilter`
   *  and a pick calls this (the domain page opens the picked domain's page)
   *  instead of filtering in place. */
  onDomainPick?: (domain: string | null) => void;
}) {
  const { data: summary } = useSuspenseQuery({
    queryKey: ["ontology-summary", businessId, version, scope],
    queryFn: () => fetchModelSummary(businessId, version, scope),
  });

  // Fetch all domain details for FK data (skip deleted domains from diff)
  const domainNames = summary.domains
    .filter((d: any) => d.change_status !== "deleted")
    .map((d) => d.name);
  const { data: domainDetails } = useSuspenseQuery({
    queryKey: ["ontology-domains", businessId, version, scope],
    queryFn: async () => {
      const results = await Promise.all(
        domainNames.map((name) => fetchDomainDetail(businessId, version, scope, name))
      );
      return results;
    },
  });

  return (
    <OntologyGraphInner
      domains={domainDetails}
      businessName={summary.name}
      stats={{
        domain_count: summary.domain_count,
        product_count: summary.product_count,
        attribute_count: summary.attribute_count,
        fk_count: summary.fk_count ?? 0,
      }}
      domainOptions={liveDomainOptions(summary.domains)}
      domainFilter={domainFilter}
      onDomainChange={onDomainChange}
      onDomainPick={onDomainPick}
    />
  );
}

function OntologyGraphInner({
  domains,
  businessName,
  stats,
  domainOptions,
  domainFilter,
  onDomainChange,
  onDomainPick,
}: {
  domains: DomainInfo[];
  /** The domain dropdown's options: the model's live domains, in the same
   *  order and set as every other domain dropdown. */
  domainOptions: DomainOption[];
  businessName: string;
  stats: {
    domain_count: number;
    product_count: number;
    attribute_count: number;
    fk_count: number;
  };
  domainFilter?: string;
  onDomainChange?: (domain: string | null) => void;
  onDomainPick?: (domain: string | null) => void;
}) {
  const [view, setView] = useState<"network" | "circular" | "concentric" | "sunburst">("network");
  const [hoveredNode, setHoveredNode] = useState<string | null>(null);
  const [localFilter, setLocalFilter] = useState<string | null>(domainFilter ?? null);
  // The chosen domain (null = every domain) scopes every layout.
  const chosenDomain = onDomainPick ? (domainFilter ?? null) : localFilter;
  const setChosenDomain = onDomainPick ?? setLocalFilter;
  useEffect(() => {
    onDomainChange?.(chosenDomain);
  }, [chosenDomain, onDomainChange]);
  const [hoveredSlice, setHoveredSlice] = useState<string | null>(null);
  const [expandedDomain, setExpandedDomain] = useState<string | null>(null);
  const [hideCrossDomain, setHideCrossDomain] = useState(false);
  const [isFullscreen, setIsFullscreen] = useState(false);
  const containerRef = useRef<HTMLDivElement>(null);
  const palette = diagramColors();

  const toggleFullscreen = useCallback(() => {
    if (!containerRef.current) return;
    if (!document.fullscreenElement) {
      containerRef.current.requestFullscreen().then(() => setIsFullscreen(true));
    } else {
      document.exitFullscreen().then(() => setIsFullscreen(false));
    }
  }, []);

  useEffect(() => {
    const handler = () => setIsFullscreen(!!document.fullscreenElement);
    document.addEventListener("fullscreenchange", handler);
    return () => document.removeEventListener("fullscreenchange", handler);
  }, []);

  // `getDomainDetail` appends the previous version's DELETED products so the
  // diff/change UI can show them. The ontology graph reflects the CURRENT
  // model only, so drop them here — they must not become nodes/edges (and
  // must not feed any FK total; that already comes from `stats.fk_count`).
  const hierarchy = useMemo(
    () =>
      domains.map((d) => {
        const products = d.products
          .filter((p) => p.change_status !== "deleted")
          .map((p) => ({
            name: p.table_name || p.name,
            product_type: p.type ?? "",
            attribute_count: p.attribute_count,
            fk_count: p.fk_count,
            fk_targets: p.fk_targets || [],
          }));
        return {
          domain: d.name,
          division: d.division ?? "",
          product_count: products.length,
          products,
        };
      }),
    [domains]
  );

  const divisionMap = useMemo(() => {
    const m: Record<string, string> = {};
    domains.forEach((d) => {
      m[d.name] = d.division ?? "";
    });
    return m;
  }, [domains]);

  // Domain color function — uses the same domain palette as the ER diagram,
  // assigned by alphabetical index so colors match across visualizations.
  const dc = useMemo(() => {
    const palette = getDomainPalette();
    const fallback = diagramColors().defaultDomain;
    const sorted = [...domains].map((d) => d.name).sort();
    const map: Record<string, string> = {};
    sorted.forEach((name, i) => {
      map[name] = palette[i % palette.length].label;
    });
    return (name: string) => map[name] ?? fallback;
  }, [domains]);

  const { nodes, nodeMap, edges } = useMemo(() => {
    const nodes: GraphNode[] = [];
    const nodeMap: Record<string, GraphNode> = {};
    const edges: GraphEdge[] = [];
    const seen = new Set<string>();

    hierarchy.forEach((d) => {
      d.products.forEach((p) => {
        const id = `${d.domain}__${p.name}`;
        const node: GraphNode = {
          id, domain: d.domain, name: p.name,
          productType: p.product_type,
          fkCount: p.fk_count, attrCount: p.attribute_count,
          x: 0, y: 0,
        };
        nodes.push(node);
        nodeMap[id] = node;
      });
    });

    // Build edges from fk_targets (format: "domain.table")
    hierarchy.forEach((d) => {
      d.products.forEach((p) => {
        const srcId = `${d.domain}__${p.name}`;
        p.fk_targets.forEach((target) => {
          const parts = target.split(".");
          if (parts.length < 2) return;
          const targetId = `${parts[0]}__${parts[1]}`;
          if (targetId && nodeMap[targetId] && targetId !== srcId && !seen.has(`${srcId}->${targetId}`)) {
            seen.add(`${srcId}->${targetId}`);
            edges.push({
              source: srcId, target: targetId, column: "",
              crossDomain: parts[0] !== d.domain,
            });
          }
        });
      });
    });

    return { nodes, nodeMap, edges };
  }, [hierarchy]);

  const visibleEdges = useMemo(
    () => (hideCrossDomain ? edges.filter((e) => !e.crossDomain) : edges),
    [edges, hideCrossDomain]
  );

  // Canonical FK count = the model-summary total (path A), identical to the
  // Overview/Review Progress/Relationships tabs. We do NOT re-sum the per-domain
  // `getDomainDetail` products here: that list appends the previous version's
  // DELETED products, which would inflate the total by their historical FKs.
  // `visibleEdges.length` is a different, legitimate metric — distinct
  // table-pair connections (multi-FK pairs collapsed, self/dangling dropped) —
  // surfaced alongside, not as if it should equal the FK count.
  const totalFkCount = stats.fk_count;

  const adjacency = useMemo(() => {
    const adj: Record<string, Set<string>> = {};
    visibleEdges.forEach((e) => {
      if (!adj[e.source]) adj[e.source] = new Set();
      if (!adj[e.target]) adj[e.target] = new Set();
      adj[e.source].add(e.target);
      adj[e.target].add(e.source);
    });
    return adj;
  }, [visibleEdges]);

  // What every layout draws for the chosen domain: its tables, the FKs that
  // touch them and, unless cross-domain edges are hidden, the tables on the
  // other end. The Sunburst (a size hierarchy, no edges) shows the domain's
  // own tables; the center labels count the chosen domain.
  const scoped = useMemo(() => {
    if (!chosenDomain) return { nodes, edges: visibleEdges, hierarchy, stats };
    const scopedNodes = nodes.filter((n) => n.domain === chosenDomain);
    const ids = new Set(scopedNodes.map((n) => n.id));
    const scopedEdges = visibleEdges.filter((e) => ids.has(e.source) || ids.has(e.target));
    if (!hideCrossDomain) {
      scopedEdges.forEach((e) => {
        [e.source, e.target].forEach((id) => {
          if (!ids.has(id) && nodeMap[id]) {
            scopedNodes.push(nodeMap[id]);
            ids.add(id);
          }
        });
      });
    }
    const scopedHierarchy = hierarchy.filter((d) => d.domain === chosenDomain);
    return {
      nodes: scopedNodes,
      edges: scopedEdges,
      hierarchy: scopedHierarchy,
      stats: {
        ...stats,
        domain_count: scopedHierarchy.length,
        product_count: scopedHierarchy.reduce((n, d) => n + d.product_count, 0),
      },
    };
  }, [chosenDomain, nodes, nodeMap, visibleEdges, hierarchy, hideCrossDomain, stats]);

  const isConn = (id: string) =>
    !hoveredNode || id === hoveredNode || adjacency[hoveredNode]?.has(id);
  const nodeR = (n: GraphNode) => Math.max(6, 4 + n.fkCount * 0.7);

  const views = [
    { key: "network" as const, label: "Clustered" },
    { key: "circular" as const, label: "Circular" },
    { key: "concentric" as const, label: "Concentric" },
    { key: "sunburst" as const, label: "Sunburst" },
  ];

  return (
    <div
      ref={containerRef}
      className={`space-y-3 mt-4 ${isFullscreen ? "bg-background p-4" : ""}`}
      style={isFullscreen ? { height: "100vh", overflow: "auto" } : undefined}
    >
      {!chosenDomain && (
        <p className="text-xs text-muted-foreground">
          {stats.domain_count} domains, {stats.product_count} tables,{" "}
          {stats.attribute_count.toLocaleString()} columns,{" "}
          <span
            title="Foreign-key attributes in the current model (matches Overview, Review Progress, and Relationships)."
          >
            {totalFkCount.toLocaleString()} FKs
          </span>{" "}
          across{" "}
          <span
            title="Distinct table-pair connections drawn in the graph. Multiple FKs between the same pair collapse to one; self-references and FKs to tables outside the model are excluded — so this is normally lower than the FK count."
          >
            {visibleEdges.length.toLocaleString()} table-pair connection
            {visibleEdges.length === 1 ? "" : "s"}
            {hideCrossDomain ? " (intra-domain only)" : ""}
          </span>
        </p>
      )}

      <div className="flex items-center gap-2 flex-wrap">
        <DomainSelect
          domains={domainOptions}
          value={chosenDomain}
          onChange={setChosenDomain}
          portalContainer={isFullscreen ? containerRef.current : null}
        />
        <div className="h-5 w-px bg-border mx-1" />
        {views.map(({ key, label }) => (
          <Button
            key={key}
            variant={view === key ? "default" : "outline"}
            size="sm"
            onClick={() => setView(key)}
          >
            {label}
          </Button>
        ))}
        <div className="h-5 w-px bg-border mx-1" />
        <Button
          variant="outline"
          size="sm"
          onClick={toggleFullscreen}
          title={isFullscreen ? "Exit fullscreen" : "Fullscreen"}
        >
          {isFullscreen ? <Minimize2 className="h-4 w-4" /> : <Maximize2 className="h-4 w-4" />}
        </Button>
        <div className="h-5 w-px bg-border mx-1" />
        <Button
          variant={hideCrossDomain ? "secondary" : "outline"}
          size="sm"
          onClick={() => setHideCrossDomain(!hideCrossDomain)}
        >
          {hideCrossDomain ? "Intra-Domain Only" : "Hide Cross-Domain"}
        </Button>
      </div>

      <div className="text-[10px] text-muted-foreground flex gap-4">
        <span>Node size = FK count</span>
        {!hideCrossDomain && <span style={{ color: palette.edgeCross }}>--- cross-domain</span>}
        <span style={{ color: palette.edgeIntra }}>--- intra-domain</span>
        <span>Hover to highlight connections</span>
      </div>

      {hoveredSlice && view === "sunburst" && (
        <div className="px-4 py-2 bg-card border rounded-lg text-xs font-mono">
          {hoveredSlice}
        </div>
      )}

      {view === "network" && (
        <NetworkView
          nodes={scoped.nodes}
          nodeMap={nodeMap}
          edges={scoped.edges}
          hoveredNode={hoveredNode}
          setHoveredNode={setHoveredNode}
          isConn={isConn}
          nodeR={nodeR}
          dc={dc}
          divisionMap={divisionMap}
        />
      )}
      {view === "circular" && (
        <CircularView
          nodes={scoped.nodes}
          nodeMap={nodeMap}
          edges={scoped.edges}
          hoveredNode={hoveredNode}
          setHoveredNode={setHoveredNode}
          isConn={isConn}
          nodeR={nodeR}
          dc={dc}
          divisionMap={divisionMap}
          businessName={businessName}
          stats={scoped.stats}
        />
      )}
      {view === "concentric" && (
        <ConcentricView
          nodes={scoped.nodes}
          nodeMap={nodeMap}
          edges={scoped.edges}
          hoveredNode={hoveredNode}
          setHoveredNode={setHoveredNode}
          isConn={isConn}
          nodeR={nodeR}
          dc={dc}
          divisionMap={divisionMap}
          businessName={businessName}
          stats={scoped.stats}
        />
      )}
      {view === "sunburst" && (
        <SunburstView
          hierarchy={scoped.hierarchy}
          stats={scoped.stats}
          businessName={businessName}
          dc={dc}
          hoveredSlice={hoveredSlice}
          setHoveredSlice={setHoveredSlice}
          expandedDomain={expandedDomain}
          setExpandedDomain={setExpandedDomain}
        />
      )}
    </div>
  );
}

// --- Shared ZoomPan SVG wrapper ---

const ZOOM_MIN = 0.1;
const ZOOM_MAX = 3;
const ZOOM_DEFAULT = 0.6;

function useZoomPan(initialZoom = ZOOM_DEFAULT) {
  const [zoom, setZoom] = useState(initialZoom);
  const [pan, setPan] = useState({ x: 0, y: 0 });
  const [drag, setDrag] = useState(false);
  const dsRef = useRef({ x: 0, y: 0 });

  const reset = useCallback(() => {
    setZoom(initialZoom);
    setPan({ x: 0, y: 0 });
  }, [initialZoom]);

  const zoomIn = useCallback(() => setZoom((z) => Math.min(ZOOM_MAX, z + 0.1)), []);
  const zoomOut = useCallback(() => setZoom((z) => Math.max(ZOOM_MIN, z - 0.1)), []);

  const onWheel = useCallback(
    (e: React.WheelEvent<Element>) => {
      e.preventDefault();
      const newZoom = Math.max(ZOOM_MIN, Math.min(ZOOM_MAX, zoom - e.deltaY * 0.001));
      if (newZoom === zoom) return;
      const ratio = newZoom / zoom;
      const rect = e.currentTarget.getBoundingClientRect();
      const cx = e.clientX - rect.left;
      const cy = e.clientY - rect.top;
      setPan({ x: cx - ratio * (cx - pan.x), y: cy - ratio * (cy - pan.y) });
      setZoom(newZoom);
    },
    [zoom, pan.x, pan.y],
  );

  const onMouseDown = useCallback(
    (e: React.MouseEvent<Element>) => {
      if (e.button !== 0) return;
      setDrag(true);
      dsRef.current = { x: e.clientX - pan.x, y: e.clientY - pan.y };
    },
    [pan.x, pan.y],
  );

  const onMouseMove = useCallback(
    (e: React.MouseEvent<Element>) => {
      if (!drag) return;
      setPan({ x: e.clientX - dsRef.current.x, y: e.clientY - dsRef.current.y });
    },
    [drag],
  );

  const stopDrag = useCallback(() => setDrag(false), []);

  return { zoom, pan, drag, zoomIn, zoomOut, reset, onWheel, onMouseDown, onMouseMove, stopDrag };
}

function ZoomControls({
  onZoomIn,
  onZoomOut,
  onReset,
}: {
  onZoomIn: () => void;
  onZoomOut: () => void;
  onReset: () => void;
}) {
  return (
    <div className="absolute bottom-4 left-4 flex flex-col gap-1 z-10">
      <Button
        variant="outline"
        size="icon"
        onClick={onZoomIn}
        title="Zoom in"
        aria-label="Zoom in"
      >
        <ZoomIn className="h-4 w-4" />
      </Button>
      <Button
        variant="outline"
        size="icon"
        onClick={onZoomOut}
        title="Zoom out"
        aria-label="Zoom out"
      >
        <ZoomOut className="h-4 w-4" />
      </Button>
      <Button
        variant="outline"
        size="icon"
        onClick={onReset}
        title="Reset view"
        aria-label="Reset view"
      >
        <Maximize2 className="h-4 w-4" />
      </Button>
    </div>
  );
}

function ZoomPanSvg({
  children,
  height = "calc(100vh - 300px)",
}: {
  children: React.ReactNode;
  height?: string;
}) {
  const zp = useZoomPan();
  return (
    <div className="relative">
      <div
        className="bg-card rounded-md border overflow-hidden"
        style={{ height, cursor: zp.drag ? "grabbing" : "grab" }}
        onWheel={zp.onWheel}
        onMouseDown={zp.onMouseDown}
        onMouseMove={zp.onMouseMove}
        onMouseUp={zp.stopDrag}
        onMouseLeave={zp.stopDrag}
      >
        <svg width="100%" height="100%">
          <g transform={`translate(${zp.pan.x},${zp.pan.y}) scale(${zp.zoom})`}>{children}</g>
        </svg>
      </div>
      <ZoomControls onZoomIn={zp.zoomIn} onZoomOut={zp.zoomOut} onReset={zp.reset} />
    </div>
  );
}

// --- Network Layout ---

function NetworkView({
  nodes, nodeMap, edges, hoveredNode, setHoveredNode, isConn, nodeR, dc,
  divisionMap,
}: {
  nodes: GraphNode[];
  nodeMap: Record<string, GraphNode>;
  edges: GraphEdge[];
  hoveredNode: string | null;
  setHoveredNode: (id: string | null) => void;
  isConn: (id: string) => boolean;
  nodeR: (n: GraphNode) => number;
  dc: (name: string) => string;
  divisionMap: Record<string, string>;
}) {
  const palette = diagramColors();
  // Writes each node's x/y in place; returns the domain order.
  const layout = useMemo(() => {
    const W = 1800, H = 1400, cx = W / 2, cy = H / 2;
    const domainNames = [...new Set(nodes.map((n) => n.domain))];
    const clusterR = Math.min(W, H) * 0.35;
    const dCenters: Record<string, { x: number; y: number }> = {};

    domainNames.forEach((d, i) => {
      const a = (i / domainNames.length) * Math.PI * 2 - Math.PI / 2;
      dCenters[d] = { x: cx + clusterR * Math.cos(a), y: cy + clusterR * Math.sin(a) };
    });

    domainNames.forEach((dn) => {
      const dns = nodes.filter((n) => n.domain === dn);
      const c = dCenters[dn];
      const cols = Math.ceil(Math.sqrt(dns.length));
      dns.forEach((n, i) => {
        n.x = c.x + (i % cols - cols / 2) * 55;
        n.y = c.y + (Math.floor(i / cols) - Math.ceil(dns.length / cols) / 2) * 50;
      });
    });

    // Simple repulsion
    for (let it = 0; it < 25; it++) {
      for (let i = 0; i < nodes.length; i++) {
        for (let j = i + 1; j < nodes.length; j++) {
          const a = nodes[i], b = nodes[j];
          const dx = b.x - a.x, dy = b.y - a.y;
          const d = Math.sqrt(dx * dx + dy * dy) || 1;
          if (d < 50) {
            const f = (50 - d) * 0.3;
            a.x -= (dx / d) * f;
            a.y -= (dy / d) * f;
            b.x += (dx / d) * f;
            b.y += (dy / d) * f;
          }
        }
      }
    }

    return { domainNames };
  }, [nodes]);

  return (
    <div>
      <div className="flex items-center gap-3 mb-3 flex-wrap">
        <ProductTypeLegend />
      </div>
      <ZoomPanSvg>
        {/* Domain background rects */}
        {layout.domainNames.map((dn) => {
          const dns = nodes.filter((n) => n.domain === dn);
          if (!dns.length) return null;
          const mnX = Math.min(...dns.map((n) => n.x)) - 35;
          const mnY = Math.min(...dns.map((n) => n.y)) - 35;
          const mxX = Math.max(...dns.map((n) => n.x)) + 35;
          const mxY = Math.max(...dns.map((n) => n.y)) + 35;
          const color = dc(dn);
          return (
            <g key={`bg-${dn}`}>
              <rect x={mnX} y={mnY} width={mxX - mnX} height={mxY - mnY} rx={12}
                fill={color} opacity={0.10} stroke={color} strokeWidth={2} strokeOpacity={0.45} />
              <text x={mnX + 8} y={mnY + 14} fontSize={10} fill={color} opacity={0.7} fontWeight={600}>
                {domainLabel(dn, divisionMap[dn])}
              </text>
            </g>
          );
        })}
        {/* Edges */}
        {edges.map((e, i) => {
          const s = nodeMap[e.source], t = nodeMap[e.target];
          if (!s || !t) return null;
          const hl = hoveredNode && (e.source === hoveredNode || e.target === hoveredNode);
          const mx = (s.x + t.x) / 2 + (s.y - t.y) * 0.1;
          const my = (s.y + t.y) / 2 + (t.x - s.x) * 0.1;
          return (
            <g key={i}>
              <path d={`M${s.x},${s.y} Q${mx},${my} ${t.x},${t.y}`} fill="none"
                stroke={hl ? palette.edgeHighlight : e.crossDomain ? palette.edgeCross : palette.edgeIntra}
                strokeWidth={hl ? 2.5 : 1}
                opacity={hoveredNode ? (hl ? 0.9 : 0.08) : e.crossDomain ? 0.45 : 0.3}
                data-testid={e.crossDomain ? "ontology-edge-cross" : "ontology-edge-intra"} />
              {hl && <text x={mx} y={my - 4} fontSize={8} fill={palette.edgeHighlight} textAnchor="middle">{e.column}</text>}
            </g>
          );
        })}
        {/* Nodes */}
        {nodes.map((n) => {
          const r = nodeR(n);
          const color = getProductTypeColors(n.productType).hex;
          const conn = isConn(n.id), isH = hoveredNode === n.id;
          return (
            <g key={n.id} onMouseEnter={() => setHoveredNode(n.id)} onMouseLeave={() => setHoveredNode(null)}
              style={{ cursor: "pointer" }} opacity={conn ? 1 : 0.12}>
              {isH && <circle cx={n.x} cy={n.y} r={r + 6} fill={color} opacity={0.2} />}
              <circle cx={n.x} cy={n.y} r={r} fill={color} opacity={isH ? 1 : 0.75}
                stroke={isH ? palette.nodeStrokeSelected : color} strokeWidth={isH ? 2 : 1} />
              <text x={n.x} y={n.y + r + 12} textAnchor="middle" fontSize={8}
                fill={conn ? "currentColor" : "transparent"} className="text-muted-foreground" fontFamily="monospace">
                {n.name.length > 20 ? n.name.slice(0, 18) + ".." : n.name}
              </text>
              {n.fkCount > 0 && (
                <text x={n.x} y={n.y + 3} textAnchor="middle" fontSize={7} fill={palette.nodeStrokeSelected} fontWeight={700}>{n.fkCount}</text>
              )}
            </g>
          );
        })}
        {/* Hover tooltip — painted last so it always sits above neighbouring nodes. */}
        {hoveredNode && nodeMap[hoveredNode] && (() => {
          const n = nodeMap[hoveredNode];
          const r = nodeR(n);
          return (
            <g key="ontology-hover-tooltip" pointerEvents="none">
              <rect x={n.x + r + 6} y={n.y - 28} width={Math.max(160, n.name.length * 7)} height={40}
                rx={6} className="fill-card stroke-border" />
              <text x={n.x + r + 12} y={n.y - 12} fontSize={10} fill="currentColor" fontWeight={600} fontFamily="monospace">{n.name}</text>
              <text x={n.x + r + 12} y={n.y + 2} fontSize={9} className="fill-muted-foreground">
                {n.attrCount} attrs, {n.fkCount} FKs — {domainLabel(n.domain, divisionMap[n.domain])}
              </text>
            </g>
          );
        })()}
      </ZoomPanSvg>
    </div>
  );
}

// --- Circular Layout ---

function CircularView({
  nodes, nodeMap, edges, hoveredNode, setHoveredNode, isConn, nodeR, dc, divisionMap, businessName, stats,
}: {
  nodes: GraphNode[];
  nodeMap: Record<string, GraphNode>;
  edges: GraphEdge[];
  hoveredNode: string | null;
  setHoveredNode: (id: string | null) => void;
  isConn: (id: string) => boolean;
  nodeR: (n: GraphNode) => number;
  dc: (name: string) => string;
  divisionMap: Record<string, string>;
  businessName: string;
  stats: { product_count: number };
}) {
  const palette = diagramColors();
  const cx = 800, cy = 800, R = 600;

  const { sorted, sectors } = useMemo(() => {
    const W = 1600, H = 1600, cxInner = W / 2, cyInner = H / 2;
    const s = [...nodes].sort((a, b) => a.domain.localeCompare(b.domain));
    s.forEach((n, i) => {
      const angle = (i / s.length) * Math.PI * 2 - Math.PI / 2;
      n.x = cxInner + R * Math.cos(angle);
      n.y = cyInner + R * Math.sin(angle);
    });

    const total = s.length || 1;
    const sectorMap: Record<string, { startIdx: number; endIdx: number }> = {};
    s.forEach((n, i) => {
      const cur = sectorMap[n.domain];
      if (!cur) sectorMap[n.domain] = { startIdx: i, endIdx: i };
      else cur.endIdx = i;
    });
    const sectors = Object.entries(sectorMap).map(([domain, { startIdx, endIdx }]) => {
      // Half-step pad so the wedge brackets the cluster instead of cutting into the edge nodes.
      const startA = ((startIdx - 0.5) / total) * Math.PI * 2 - Math.PI / 2;
      const endA = ((endIdx + 0.5) / total) * Math.PI * 2 - Math.PI / 2;
      const midA = (startA + endA) / 2;
      return { domain, startA, endA, midA };
    });

    return { sorted: s, sectors };
  }, [nodes]);

  // Wedge from center to the outer ring + a small overshoot so labels sit clear of nodes.
  const wedgePath = (start: number, end: number, rOuter: number) => {
    const x1 = cx + rOuter * Math.cos(start);
    const y1 = cy + rOuter * Math.sin(start);
    const x2 = cx + rOuter * Math.cos(end);
    const y2 = cy + rOuter * Math.sin(end);
    const large = end - start > Math.PI ? 1 : 0;
    return `M${cx},${cy} L${x1},${y1} A${rOuter},${rOuter} 0 ${large} 1 ${x2},${y2} Z`;
  };

  return (
    <ZoomPanSvg>
      {/* Domain wedges — drawn first so edges and nodes paint above them. */}
      {sectors.map((s) => {
        const color = dc(s.domain);
        return (
          <path
            key={`wedge-${s.domain}`}
            d={wedgePath(s.startA, s.endA, R + 30)}
            fill={color}
            fillOpacity={0.10}
            stroke={color}
            strokeOpacity={0.25}
            strokeWidth={1}
          />
        );
      })}
      {edges.map((e, i) => {
        const s = nodeMap[e.source], t = nodeMap[e.target];
        if (!s || !t) return null;
        const hl = hoveredNode && (e.source === hoveredNode || e.target === hoveredNode);
        return (
          <path key={i} d={`M${s.x},${s.y} Q${cx},${cy} ${t.x},${t.y}`} fill="none"
            stroke={hl ? palette.edgeHighlight : e.crossDomain ? palette.edgeCross : palette.edgeIntra}
            strokeWidth={hl ? 2.5 : 1}
            opacity={hoveredNode ? (hl ? 0.9 : 0.06) : 0.25}
            data-testid={e.crossDomain ? "ontology-edge-cross" : "ontology-edge-intra"} />
        );
      })}
      {sorted.map((n) => {
        const r = nodeR(n);
        const color = getProductTypeColors(n.productType).hex;
        const conn = isConn(n.id), isH = hoveredNode === n.id;
        return (
          <g key={n.id} onMouseEnter={() => setHoveredNode(n.id)} onMouseLeave={() => setHoveredNode(null)}
            style={{ cursor: "pointer" }} opacity={conn ? 1 : 0.1}>
            {isH && <circle cx={n.x} cy={n.y} r={r + 5} fill={color} opacity={0.3} />}
            <circle cx={n.x} cy={n.y} r={r} fill={color} opacity={isH ? 1 : 0.8}
              stroke={isH ? palette.nodeStrokeSelected : "none"} strokeWidth={2} />
            <text x={n.x} y={n.y + r + 10} textAnchor="middle" fontSize={7}
              fill={conn ? "currentColor" : "transparent"} className="text-muted-foreground" fontFamily="monospace">
              {n.name.length > 16 ? n.name.slice(0, 14) + ".." : n.name}
            </text>
          </g>
        );
      })}
      {/* Domain labels at the outer edge of each wedge. */}
      {sectors.map((s) => {
        const labelR = R + 50;
        const lx = cx + labelR * Math.cos(s.midA);
        const ly = cy + labelR * Math.sin(s.midA);
        const color = dc(s.domain);
        return (
          <text
            key={`label-${s.domain}`}
            x={lx}
            y={ly}
            textAnchor="middle"
            fontSize={11}
            fill={color}
            fontWeight={600}
            opacity={0.85}
            style={{ pointerEvents: "none" }}
          >
            {domainLabel(s.domain, divisionMap[s.domain])}
          </text>
        );
      })}
      <text x={cx} y={cy - 8} textAnchor="middle" fontSize={13} className="fill-muted-foreground" fontWeight={600}>{businessName}</text>
      <text x={cx} y={cy + 10} textAnchor="middle" fontSize={10} className="fill-muted-foreground">{stats.product_count} tables</text>
    </ZoomPanSvg>
  );
}

// --- Concentric Layout ---

function ConcentricView({
  nodes, nodeMap, edges, hoveredNode, setHoveredNode, isConn, nodeR, dc, divisionMap, businessName, stats,
}: {
  nodes: GraphNode[];
  nodeMap: Record<string, GraphNode>;
  edges: GraphEdge[];
  hoveredNode: string | null;
  setHoveredNode: (id: string | null) => void;
  isConn: (id: string) => boolean;
  nodeR: (n: GraphNode) => number;
  dc: (name: string) => string;
  divisionMap: Record<string, string>;
  businessName: string;
  stats: { domain_count: number; product_count: number };
}) {
  const palette = diagramColors();
  const { sortedDomains } = useMemo(() => {
    const W = 1800, H = 1800, cx = W / 2, cy = H / 2;
    const dNames = [...new Set(nodes.map((n) => n.domain))];
    const ringGap = 120;
    const sorted = [...dNames].sort((a, b) => {
      const ca = nodes.filter((n) => n.domain === a).length;
      const cb = nodes.filter((n) => n.domain === b).length;
      return cb - ca;
    });
    sorted.forEach((dname, ri) => {
      const dNodes = nodes.filter((n) => n.domain === dname);
      const R = 100 + ri * ringGap;
      dNodes.forEach((n, i) => {
        const angle = (i / dNodes.length) * Math.PI * 2 - Math.PI / 2;
        n.x = cx + R * Math.cos(angle);
        n.y = cy + R * Math.sin(angle);
      });
    });
    return { sortedDomains: sorted };
  }, [nodes]);

  const cx = 900, cy = 900;

  return (
    <ZoomPanSvg>
      {/* Domain annulus backgrounds — fillRule=evenodd carves an inner hole using two
          concentric circle subpaths in a single <path>. */}
      {sortedDomains.map((dname, ri) => {
        const R = 100 + ri * 120;
        const color = dc(dname);
        const inner = R - 40;
        const outer = R + 40;
        const annulus = `M ${cx - outer},${cy} a ${outer},${outer} 0 1,0 ${outer * 2},0 a ${outer},${outer} 0 1,0 ${-outer * 2},0 M ${cx - inner},${cy} a ${inner},${inner} 0 1,0 ${inner * 2},0 a ${inner},${inner} 0 1,0 ${-inner * 2},0`;
        return (
          <g key={`ring-${dname}`}>
            {inner > 0 && (
              <path d={annulus} fill={color} fillOpacity={0.06} fillRule="evenodd" stroke="none" />
            )}
            <circle cx={cx} cy={cy} r={R} fill="none" stroke={color} strokeWidth={1} strokeOpacity={0.40} strokeDasharray="4,4" />
            <text x={cx + R + 8} y={cy - 4} fontSize={11} fill={color} fontWeight={600} opacity={0.85}>
              {domainLabel(dname, divisionMap[dname])}
            </text>
          </g>
        );
      })}
      {edges.map((e, i) => {
        const s = nodeMap[e.source], t = nodeMap[e.target];
        if (!s || !t) return null;
        const hl = hoveredNode && (e.source === hoveredNode || e.target === hoveredNode);
        const mx = (s.x + t.x) / 2 + (s.y - t.y) * 0.05;
        const my = (s.y + t.y) / 2 + (t.x - s.x) * 0.05;
        return (
          <path key={i} d={`M${s.x},${s.y} Q${mx},${my} ${t.x},${t.y}`} fill="none"
            stroke={hl ? palette.edgeHighlight : e.crossDomain ? palette.edgeCross : palette.edgeIntra}
            strokeWidth={hl ? 2.5 : 1}
            opacity={hoveredNode ? (hl ? 0.9 : 0.06) : 0.25}
            data-testid={e.crossDomain ? "ontology-edge-cross" : "ontology-edge-intra"} />
        );
      })}
      {nodes.map((n) => {
        const r = nodeR(n);
        const color = getProductTypeColors(n.productType).hex;
        const conn = isConn(n.id), isH = hoveredNode === n.id;
        return (
          <g key={n.id} onMouseEnter={() => setHoveredNode(n.id)} onMouseLeave={() => setHoveredNode(null)}
            style={{ cursor: "pointer" }} opacity={conn ? 1 : 0.1}>
            {isH && <circle cx={n.x} cy={n.y} r={r + 5} fill={color} opacity={0.3} />}
            <circle cx={n.x} cy={n.y} r={r} fill={color} opacity={isH ? 1 : 0.8}
              stroke={isH ? palette.nodeStrokeSelected : "none"} strokeWidth={2} />
            <text x={n.x} y={n.y + r + 10} textAnchor="middle" fontSize={7}
              fill={conn ? "currentColor" : "transparent"} className="text-muted-foreground" fontFamily="monospace">
              {n.name.length > 16 ? n.name.slice(0, 14) + ".." : n.name}
            </text>
          </g>
        );
      })}
      <text x={cx} y={cy - 8} textAnchor="middle" fontSize={14} className="fill-muted-foreground" fontWeight={700}>{businessName}</text>
      <text x={cx} y={cy + 10} textAnchor="middle" fontSize={10} className="fill-muted-foreground">
        {stats.domain_count} domains, {stats.product_count} tables
      </text>
    </ZoomPanSvg>
  );
}

// --- Sunburst Layout ---

function SunburstView({
  hierarchy, stats, businessName, dc, hoveredSlice, setHoveredSlice, expandedDomain, setExpandedDomain,
}: {
  hierarchy: Array<{ domain: string; division?: string; product_count: number; products: Array<{ name: string; attribute_count: number }> }>;
  stats: { domain_count: number; product_count: number };
  businessName: string;
  dc: (name: string) => string;
  hoveredSlice: string | null;
  setHoveredSlice: (s: string | null) => void;
  expandedDomain: string | null;
  setExpandedDomain: (d: string | null) => void;
}) {
  const palette = diagramColors();
  const cx = 400, cy = 400, innerR = 60, domainR = 160, productR = 320;
  const total = stats.product_count || 1;
  let angleOff = 0;
  const arcs = hierarchy.map((d) => {
    const sweep = (d.product_count / total) * Math.PI * 2;
    const a = { d, start: angleOff, end: angleOff + sweep, color: dc(d.domain) };
    angleOff += sweep;
    return a;
  });

  const arcPath = (cx: number, cy: number, r1: number, r2: number, s: number, e: number) => {
    const gap = 0.005;
    s += gap;
    e -= gap;
    if (e <= s) return "";
    const c = Math.cos, si = Math.sin, hp = Math.PI / 2;
    const large = e - s > Math.PI ? 1 : 0;
    return `M${cx + r1 * c(s - hp)},${cy + r1 * si(s - hp)} L${cx + r2 * c(s - hp)},${cy + r2 * si(s - hp)} A${r2},${r2} 0 ${large} 1 ${cx + r2 * c(e - hp)},${cy + r2 * si(e - hp)} L${cx + r1 * c(e - hp)},${cy + r1 * si(e - hp)} A${r1},${r1} 0 ${large} 0 ${cx + r1 * c(s - hp)},${cy + r1 * si(s - hp)} Z`;
  };

  const zp = useZoomPan(0.8);

  return (
    <div className="relative">
      <div
        className="bg-card rounded-md border overflow-hidden"
        style={{ height: "calc(100vh - 300px)", cursor: zp.drag ? "grabbing" : "grab" }}
        onWheel={zp.onWheel}
        onMouseDown={zp.onMouseDown}
        onMouseMove={zp.onMouseMove}
        onMouseUp={zp.stopDrag}
        onMouseLeave={zp.stopDrag}
      >
        <svg width="100%" height="100%">
          <g transform={`translate(${zp.pan.x},${zp.pan.y}) scale(${zp.zoom})`}>
            <circle cx={cx} cy={cy} r={innerR} className="fill-card stroke-border" strokeWidth={2} />
            <text x={cx} y={cy - 10} textAnchor="middle" fontSize={14} fontWeight={700} fill="currentColor">{businessName}</text>
            <text x={cx} y={cy + 10} textAnchor="middle" fontSize={11} className="fill-muted-foreground">{stats.domain_count} domains</text>
            <text x={cx} y={cy + 26} textAnchor="middle" fontSize={10} className="fill-muted-foreground">{stats.product_count} tables</text>

            {arcs.map(({ d, start, end, color }) => {
              const mid = (start + end) / 2 - Math.PI / 2;
              const lr = (innerR + domainR) / 2 + 10;
              const isHL = hoveredSlice === d.domain || expandedDomain === d.domain;
              const label = domainLabel(d.domain, d.division).slice(0, 24);
              return (
                <g key={d.domain} style={{ cursor: "pointer" }}
                  onMouseEnter={() => setHoveredSlice(d.domain)}
                  onMouseLeave={() => setHoveredSlice(null)}
                  onClick={() => setExpandedDomain(expandedDomain === d.domain ? null : d.domain)}>
                  <path d={arcPath(cx, cy, innerR + 4, domainR, start, end)} fill={color}
                    opacity={isHL ? 0.9 : 0.6} stroke={isHL ? palette.nodeStrokeSelected : "none"} strokeWidth={isHL ? 2 : 0} />
                  {end - start > 0.3 && (
                    <text x={cx + lr * Math.cos(mid)} y={cy + lr * Math.sin(mid)} textAnchor="middle" fontSize={8}
                      fontWeight={600} fill={palette.nodeStrokeSelected}
                      transform={`rotate(${(mid * 180) / Math.PI},${cx + lr * Math.cos(mid)},${cy + lr * Math.sin(mid)})`}
                      style={{ pointerEvents: "none" }}>
                      {label}
                    </text>
                  )}
                </g>
              );
            })}

            {arcs.map(({ d, start, end, color }) => {
              const sw = (end - start) / (d.product_count || 1);
              return d.products.map((p, pi) => {
                const ps = start + pi * sw, pe = ps + sw;
                const isHL = hoveredSlice === `${d.domain}.${p.name}` || expandedDomain === d.domain;
                return (
                  <path key={`${d.domain}.${p.name}`} d={arcPath(cx, cy, domainR + 4, productR, ps, pe)}
                    fill={color} opacity={isHL ? 0.55 : 0.2} stroke={isHL ? color : "none"} strokeWidth={1}
                    onMouseEnter={() => setHoveredSlice(`${d.domain}.${p.name}`)}
                    onMouseLeave={() => setHoveredSlice(null)}
                    style={{ cursor: "pointer" }}>
                    <title>{p.name} ({p.attribute_count} attrs)</title>
                  </path>
                );
              });
            })}
          </g>
        </svg>
      </div>
      <ZoomControls onZoomIn={zp.zoomIn} onZoomOut={zp.zoomOut} onReset={zp.reset} />
    </div>
  );
}
