import { useCallback, useEffect, useMemo, useRef, useState, type ReactNode } from "react";
import {
  ReactFlow,
  ReactFlowProvider,
  Controls,
  useReactFlow,
  type Node,
  type Edge,
} from "@xyflow/react";
import "@xyflow/react/dist/style.css";
import "./diagram.css";

import { Skeleton } from "@/components/ui/skeleton";
import { DiagramControls } from "./diagram-controls";
import { DomainSelect } from "./domain-select";
import { TableNode, type TableNodeData } from "./table-node";
import { DomainGroupNode, type DomainGroupData } from "./domain-group-node";
import { CrowsFootEdge, CrowsFootMarkerDefs } from "./crows-foot-edge";
import { getDomainPalette, MIN_ZOOM, MAX_ZOOM, FIT_VIEW_PADDING, getSelectionColor, getCrossDomainHighlightColor } from "./constants";
import type {
  DiagramLayoutResponse,
  DiagramPendingResponse,
  ColumnDisplayMode,
  DiagramEdge as DiagramEdgeType,
} from "./types";
import { fetchDiagramLayoutOnce } from "@/lib/diagram-layout";

const nodeTypes = {
  tableNode: TableNode,
  domainGroup: DomainGroupNode,
};

/**
 * Render a ms-epoch timestamp as a relative string like "2s ago" or "just
 * now". Used on the 202 "still computing" overlay to show how stale the
 * last heartbeat is (task #104). Keep this tiny - don't pull in a full
 * date library for one label.
 */
export function formatRelativeTime(
  tsMs: number,
  nowMs: number = Date.now(),
): string {
  const deltaSec = Math.max(0, Math.round((nowMs - tsMs) / 1000));
  if (deltaSec < 2) return "just now";
  if (deltaSec < 60) return `${deltaSec}s ago`;
  const deltaMin = Math.floor(deltaSec / 60);
  if (deltaMin < 60) return `${deltaMin}m ago`;
  const deltaHr = Math.floor(deltaMin / 60);
  return `${deltaHr}h ago`;
}

const edgeTypes = {
  crowsFoot: CrowsFootEdge,
};

/** Info about the currently selected relationship */
interface SelectedRelationship {
  edgeId: string;
  sourceNodeId: string;
  targetNodeId: string;
  sourceColumn: string;
  targetColumn: string;
  /** Human-readable label, e.g. "store.purchase.store_id → store.location.store_id" */
  label: string;
}

interface DiagramViewerProps {
  businessId: string;
  version: string;
  scope: string;
  domains: { name: string; division: string }[];
  initialDomain?: string;
  /** Seeds the initial column-display mode from the caller's resolved
   *  per-user preference (Settings > Diagram, item 4). Falls back to the
   *  historical hardcoded defaults ("keys" for a focal domain, "hide" for
   *  the all-domains view) when omitted, so unset users see today's
   *  behavior unchanged. */
  initialColumnMode?: ColumnDisplayMode;
  /** Pre-focus a product node once the layout resolves (model-wide search
   *  "table" hit). Matched by product name within the loaded layout; seeds the
   *  node selection + centers on it. Unresolvable names are a no-op, so the
   *  single-domain landing still holds (ELK-timing domain-only fallback). */
  focusProduct?: string;
  /** Called when the user selects a node or edge (or clears the selection).
   *  Enables the parent page to feed that selection into feedback context
   *  so "Add feedback" while the diagram is focused captures the specific
   *  table or relationship, not just the domain. */
  onSelectionChange?: (sel: { nodeId: string | null; edgeId: string | null }) => void;
  /** The diagram view's Add-feedback trigger + dialog, built by the host
   *  with the diagram feedback context it already assembles. Rendered
   *  inside the toolbar (inside the fullscreened subtree) so it's the
   *  single home for feedback on this view (item 5B). */
  feedbackSlot?: ReactNode;
  /** Domain selection navigates via this callback (item 3). The caller is
   *  expected to change the URL and re-mount/re-seed via `initialDomain`.
   *  Every in-tree embedder passes this now (item 3B); when a host has no
   *  meaningful "navigate" (e.g. it never shows the domain picker), it can
   *  omit this and domain-change interactions are simply inert. */
  onDomainNavigate?: (domain: string | null) => void;
  /** Hide the toolbar's own domain dropdown on surfaces that only follow a
   *  focused input (input review, following pane). Defaults to true: the
   *  model and domain pages keep the diagram's domain selection inside the
   *  diagram tab. */
  showDomainSelect?: boolean;
}

export function DiagramViewer({
  businessId,
  version,
  scope,
  domains,
  initialDomain,
  initialColumnMode,
  focusProduct,
  onSelectionChange,
  feedbackSlot,
  onDomainNavigate,
  showDomainSelect = true,
}: DiagramViewerProps) {
  // `initialDomain` re-seeds this on every mount (a fresh page load after
  // `onDomainNavigate` changes the URL); there is no local setter anymore
  // (item 3B) - domain selection is a navigation, not a state mutation, so
  // the only way `selectedDomain` changes is a re-mount with a new prop.
  const [selectedDomain] = useState<string | null>(initialDomain ?? null);
  const [columnMode, setColumnMode] = useState<ColumnDisplayMode>(
    initialColumnMode ?? (initialDomain ? "keys" : "hide"),
  );
  const [isFullscreen, setIsFullscreen] = useState(false);
  const containerRef = useRef<HTMLDivElement>(null);

  // Item 3B: the internal `setSelectedDomain` fallback and the hide->keys
  // auto-flip that used to fire on a local domain change are both deleted.
  // Every in-tree embedder now navigates on domain change, which re-mounts
  // this component with a fresh `initialDomain` + `initialColumnMode`
  // already seeded correctly, so neither mechanism has anything left to do.
  const handleDomainChange = useCallback((domain: string | null) => {
    onDomainNavigate?.(domain);
  }, [onDomainNavigate]);

  const handleToggleFullscreen = useCallback(() => {
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

  return (
    <div
      ref={containerRef}
      className={`flex flex-col ${isFullscreen ? "bg-background p-3" : ""}`}
      style={{ height: isFullscreen ? "100vh" : undefined }}
    >
      <ReactFlowProvider>
        <DiagramCanvas
          businessId={businessId}
          version={version}
          scope={scope}
          domains={domains}
          selectedDomain={selectedDomain}
          columnMode={columnMode}
          onDomainChange={handleDomainChange}
          onColumnModeChange={setColumnMode}
          isFullscreen={isFullscreen}
          onToggleFullscreen={handleToggleFullscreen}
          portalContainer={isFullscreen ? containerRef.current : null}
          focusProduct={focusProduct}
          onSelectionChange={onSelectionChange}
          feedbackSlot={feedbackSlot}
          showDomainSelect={showDomainSelect}
        />
      </ReactFlowProvider>
    </div>
  );
}

interface DiagramCanvasProps {
  businessId: string;
  version: string;
  scope: string;
  domains: { name: string; division: string }[];
  selectedDomain: string | null;
  columnMode: ColumnDisplayMode;
  onDomainChange: (domain: string | null) => void;
  onColumnModeChange: (mode: ColumnDisplayMode) => void;
  isFullscreen: boolean;
  onToggleFullscreen: () => void;
  portalContainer: HTMLElement | null;
  focusProduct?: string;
  onSelectionChange?: (sel: { nodeId: string | null; edgeId: string | null }) => void;
  feedbackSlot?: ReactNode;
  showDomainSelect?: boolean;
}

function DiagramCanvas({
  businessId,
  version,
  scope,
  domains,
  selectedDomain,
  columnMode,
  onDomainChange,
  onColumnModeChange,
  isFullscreen,
  onToggleFullscreen,
  portalContainer,
  focusProduct,
  onSelectionChange,
  feedbackSlot,
  showDomainSelect,
}: DiagramCanvasProps) {
  const { fitView, setCenter, getNode } = useReactFlow();
  const [layout, setLayout] = useState<DiagramLayoutResponse | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const abortRef = useRef<AbortController | null>(null);
  const [selectedRel, setSelectedRel] = useState<SelectedRelationship | null>(null);
  const [selectedNodeId, setSelectedNodeId] = useState<string | null>(null);
  // Related domains the user has HIDDEN. Empty = show all (the default).
  const [hiddenRelated, setHiddenRelated] = useState<Set<string>>(new Set());
  const [retryCount, setRetryCount] = useState(0);
  const [computeElapsedMs, setComputeElapsedMs] = useState(0);
  // Pending-state heartbeat info from the last 202 response (task #104).
  // ``null`` when the first 202 hasn't landed yet or the server didn't
  // include queue info (backwards-compatibility with older deployments).
  const [pendingInfo, setPendingInfo] = useState<DiagramPendingResponse | null>(
    null,
  );
  const edgeClickedAt = useRef(0);
  const nodeClickedAt = useRef(0);

  const showingColumns = columnMode !== "hide";

  // Related (cross-domain) domains available to filter - derived from the
  // external groups the backend returns alongside the focal domain.
  const relatedDomains = useMemo(
    () =>
      (layout?.groups ?? [])
        .filter((g) => g.is_external)
        .map((g) => ({ name: g.domain, division: g.division ?? "" })),
    [layout],
  );

  // Reset the curated subset whenever the focal domain changes - a fresh
  // focal view starts at show-all. (Deliberately NOT keyed on columnMode:
  // flipping columns must not wipe the user's chosen related subset.)
  useEffect(() => {
    setHiddenRelated(new Set());
  }, [selectedDomain]);

  // Build edge lookup for relationship labels
  const edgeLookup = useMemo(() => {
    const map = new Map<string, DiagramEdgeType>();
    for (const e of layout?.edges ?? []) {
      map.set(e.id, e);
    }
    return map;
  }, [layout]);

  // Build adjacency map: nodeId -> [{nodeId, isSameDomain}]
  const adjacencyMap = useMemo(() => {
    const map = new Map<string, Set<string>>();
    const nodeDomain = new Map<string, string>();
    for (const n of layout?.nodes ?? []) {
      nodeDomain.set(n.id, n.domain);
    }
    for (const e of layout?.edges ?? []) {
      if (!map.has(e.source_node)) map.set(e.source_node, new Set());
      if (!map.has(e.target_node)) map.set(e.target_node, new Set());
      map.get(e.source_node)!.add(e.target_node);
      map.get(e.target_node)!.add(e.source_node);
    }
    return { adjacency: map, nodeDomain };
  }, [layout]);

  // Surface current selection (node OR edge) to the parent so "Add feedback"
  // can capture the selected table / relationship as context.
  useEffect(() => {
    if (!onSelectionChange) return;
    onSelectionChange({
      nodeId: selectedNodeId,
      edgeId: selectedRel?.edgeId ?? null,
    });
  }, [onSelectionChange, selectedNodeId, selectedRel]);

  // Compute highlight colors for nodes: nodeId -> color string
  const nodeHighlights = useMemo(() => {
    const highlights = new Map<string, string>();
    const selectionColor = getSelectionColor();
    const crossDomainColor = getCrossDomainHighlightColor();

    // From edge selection (red for both)
    if (selectedRel) {
      highlights.set(selectedRel.sourceNodeId, selectionColor);
      highlights.set(selectedRel.targetNodeId, selectionColor);
    }

    // From node selection (clicked = red, same domain neighbors = red, cross domain = yellow)
    if (selectedNodeId) {
      highlights.set(selectedNodeId, selectionColor);
      const neighbors = adjacencyMap.adjacency.get(selectedNodeId);
      const clickedDomain = adjacencyMap.nodeDomain.get(selectedNodeId);
      if (neighbors) {
        for (const neighborId of neighbors) {
          const neighborDomain = adjacencyMap.nodeDomain.get(neighborId);
          const color = neighborDomain === clickedDomain ? selectionColor : crossDomainColor;
          highlights.set(neighborId, color);
        }
      }
    }

    return highlights;
  }, [selectedRel, selectedNodeId, adjacencyMap]);

  // Fetch layout from backend
  useEffect(() => {
    abortRef.current?.abort();
    const controller = new AbortController();
    abortRef.current = controller;

    setLoading(true);
    setError(null);
    setSelectedRel(null);

    // Track elapsed compute time so the UI can show progress info. Large
    // all-domains graphs can take several minutes; we cap polling well above
    // observed worst-case to avoid user frustration on truly hung backends.
    const startedAt = Date.now();
    const POLL_HARD_LIMIT_MS = 15 * 60_000;
    setComputeElapsedMs(0);
    setPendingInfo(null);

    const poll = async () => {
      try {
        const result = await fetchDiagramLayoutOnce({
          businessId,
          version: Number(version),
          scope,
          domain: selectedDomain,
          columnMode,
          signal: controller.signal,
        });
        if (result.kind === "pending") {
          const elapsed = Date.now() - startedAt;
          setComputeElapsedMs(elapsed);
          setPendingInfo(result.info);
          if (elapsed > POLL_HARD_LIMIT_MS) {
            setError(
              "Layout computation took longer than 15 minutes. The graph " +
                "may be too large or the layout worker is wedged. Try a " +
                "single domain, or reload to retry.",
            );
            setLoading(false);
            return;
          }
          await new Promise((r) => setTimeout(r, 2000));
          if (!controller.signal.aborted) poll();
          return;
        }
        setLayout(result.layout);
        setLoading(false);
      } catch (err: any) {
        if (err.name !== "AbortError") {
          setError(err.message);
          setLoading(false);
        }
      }
    };
    poll();

    return () => controller.abort();
  }, [businessId, version, scope, selectedDomain, columnMode, retryCount]);

  // Fit view after layout changes
  useEffect(() => {
    if (layout && !loading) {
      const timer = setTimeout(() => fitView({ padding: FIT_VIEW_PADDING }), 150);
      return () => clearTimeout(timer);
    }
  }, [layout, loading, fitView]);

  useEffect(() => {
    if (layout && !loading) {
      const timer = setTimeout(() => fitView({ padding: FIT_VIEW_PADDING }), 250);
      return () => clearTimeout(timer);
    }
  }, [isFullscreen]);

  const domainColorMap = useMemo(() => {
    const paletteSize = getDomainPalette().length;
    const map = new Map<string, number>();
    domains.forEach((d, i) => map.set(d.name, i % paletteSize));
    return map;
  }, [domains]);

  const handleDomainClick = useCallback(
    (domain: string) => onDomainChange(domain),
    [onDomainChange]
  );

  const handleNavigateToNode = useCallback(
    (nodeId: string) => {
      const node = getNode(nodeId);
      if (!node) return;
      const x = node.position.x + (node.measured?.width ?? 200) / 2;
      const y = node.position.y + (node.measured?.height ?? 40) / 2;
      setCenter(x, y, { zoom: 1.2, duration: 600 });
    },
    [getNode, setCenter]
  );

  // Pre-focus a product node from model-wide search (a "table" hit). Once the
  // layout resolves, resolve the product name to its node, select + center it.
  // Applied once per focusProduct value so it doesn't fight later user
  // interaction or re-fire on a column-mode toggle. Unresolvable names leave
  // the single-domain landing untouched (ELK-timing domain-only fallback).
  const focusAppliedRef = useRef<string | null>(null);
  useEffect(() => {
    focusAppliedRef.current = null;
  }, [focusProduct]);
  useEffect(() => {
    if (!layout || loading || !focusProduct) return;
    if (focusAppliedRef.current === focusProduct) return;
    const node = (layout.nodes ?? []).find(
      (n) => n.product === focusProduct || n.table_name === focusProduct,
    );
    if (!node) return;
    focusAppliedRef.current = focusProduct;
    setSelectedNodeId(node.id);
    // Let the fit-view + node mount settle first, then center on the node.
    const timer = setTimeout(() => handleNavigateToNode(node.id), 300);
    return () => clearTimeout(timer);
  }, [layout, loading, focusProduct, handleNavigateToNode]);

  // Edge click: fit both nodes + select relationship
  const handleEdgeClick = useCallback(
    (sourceNodeId: string, targetNodeId: string, edgeId: string) => {
      edgeClickedAt.current = Date.now();
      setSelectedNodeId(null); // clear node selection

      const edgeData = edgeLookup.get(edgeId);
      const label = edgeData
        ? `${edgeData.source_node}.${edgeData.source_column} → ${edgeData.target_node}.${edgeData.target_column}`
        : `${sourceNodeId} → ${targetNodeId}`;

      setSelectedRel({
        edgeId,
        sourceNodeId,
        targetNodeId,
        sourceColumn: edgeData?.source_column ?? "",
        targetColumn: edgeData?.target_column ?? "",
        label,
      });

      // Delay fitView slightly so React Flow processes the selection state first
      setTimeout(() => {
        fitView({
          nodes: [{ id: sourceNodeId }, { id: targetNodeId }],
          padding: 0.3,
          duration: 600,
        });
      }, 50);
    },
    [edgeLookup, fitView]
  );

  // Table click: select node and highlight neighbors
  const handleTableNodeClick = useCallback(
    (nodeId: string) => {
      nodeClickedAt.current = Date.now();
      setSelectedNodeId((prev) => (prev === nodeId ? null : nodeId)); // toggle
      setSelectedRel(null); // clear edge selection
    },
    []
  );

  // Clear all selection on pane click
  const handlePaneClick = useCallback(() => {
    if (Date.now() - edgeClickedAt.current < 300) return;
    if (Date.now() - nodeClickedAt.current < 300) return;
    setSelectedRel(null);
    setSelectedNodeId(null);
  }, []);

  // Transform layout into React Flow nodes and edges
  const { nodes, edges, visibleProductCount, visibleEdgeCount } = useMemo(() => {
    if (!layout) return { nodes: [] as Node[], edges: [] as Edge[], visibleProductCount: 0, visibleEdgeCount: 0 };

    const rfNodes: Node[] = [];
    const layoutNodes = layout.nodes ?? [];
    const layoutEdges = layout.edges ?? [];
    const layoutGroups = layout.groups ?? [];

    // Related-domain filtering: a group/node/edge belonging to a hidden
    // related domain is dropped (unless peeked). `hiddenRelated` empty =
    // show all (default).

    // Peek-through: when some related domains are hidden and a node is
    // selected, temporarily reveal its cross-domain connections.
    const peekEdgeIds = new Set<string>();
    const peekNodeIds = new Set<string>();
    const peekDomains = new Set<string>();
    if (hiddenRelated.size > 0 && selectedNodeId) {
      for (const e of layoutEdges) {
        const srcDomain = e.source_node.split(".")[0];
        const tgtDomain = e.target_node.split(".")[0];
        if (srcDomain !== tgtDomain && (e.source_node === selectedNodeId || e.target_node === selectedNodeId)) {
          peekEdgeIds.add(e.id);
          peekNodeIds.add(e.source_node);
          peekNodeIds.add(e.target_node);
          peekDomains.add(srcDomain);
          peekDomains.add(tgtDomain);
        }
      }
    }

    for (const g of layoutGroups) {
      // Skip groups in hidden related domains (unless peek-through).
      if (hiddenRelated.has(g.domain) && !peekDomains.has(g.domain)) continue;

      rfNodes.push({
        id: g.id,
        type: "domainGroup",
        position: { x: g.x, y: g.y },
        data: {
          label: g.is_external ? `${g.domain} (related)` : g.domain,
          domain: g.domain,
          division: g.division ?? "",
          isExternal: g.is_external,
          width: g.width,
          height: g.height,
          colorIndex: domainColorMap.get(g.domain) ?? 0,
          onDomainClick: handleDomainClick,
        } satisfies DomainGroupData,
        style: { width: g.width, height: g.height },
        selectable: false,
        draggable: false,
        zIndex: -1,
      });
    }

    for (const n of layoutNodes) {
      // Skip nodes in hidden related domains (unless peek-through).
      if (hiddenRelated.has(n.domain) && !peekNodeIds.has(n.id)) continue;

      const highlightColor = nodeHighlights.get(n.id) ?? null;
      const isSelected = n.id === selectedNodeId;
      rfNodes.push({
        id: n.id,
        type: "tableNode",
        position: { x: n.x, y: n.y },
        data: {
          label: n.product,
          tableName: n.table_name,
          productType: n.product_type ?? "",
          description: n.description ?? "",
          columns: showingColumns ? (n.columns ?? []) : [],
          columnCount: n.column_count ?? 0,
          fkCount: n.fk_count ?? 0,
          domain: n.domain,
          columnMode,
          onFkNavigate: handleNavigateToNode,
          highlighted: !!highlightColor,
          onNodeClick: handleTableNodeClick,
          changeStatus: n.change_status,
        } satisfies TableNodeData,
        style: {
          width: n.width,
          height: n.height,
          ...(highlightColor
            ? { outline: `3px solid ${highlightColor}`, outlineOffset: "2px", borderRadius: "6px" }
            : isSelected
              ? { outline: `2px solid hsl(var(--foreground))`, outlineOffset: "2px", borderRadius: "6px" }
              : {}),
        },
        zIndex: highlightColor || isSelected ? 10 : 1,
      });
    }

    const selectedEdgeId = selectedRel?.edgeId ?? null;

    // Drop edges touching a hidden related domain (keep peek-through edges).
    const visibleLayoutEdges =
      hiddenRelated.size > 0
        ? layoutEdges.filter((e) => {
            const srcDomain = e.source_node.split(".")[0];
            const tgtDomain = e.target_node.split(".")[0];
            return (
              (!hiddenRelated.has(srcDomain) && !hiddenRelated.has(tgtDomain)) ||
              peekEdgeIds.has(e.id)
            );
          })
        : layoutEdges;

    const rfEdges: Edge[] = visibleLayoutEdges.map((e) => {
      const hasWaypoints = (e.waypoints?.length ?? 0) > 0;

      // Handle binding:
      //  - columns shown (keys/all): per-column PK/FK handles + smoothstep.
      //  - columns hidden WITH backend waypoints: the floating edge draws its
      //    own absolute polyline, so we omit the handle ids and let React Flow
      //    bind to a default handle on the node.
      //  - columns hidden WITHOUT waypoints (e.g. overview): fall back to the
      //    node's left/right floating handles for a smoothstep edge.
      let sourceHandle: string | undefined;
      let targetHandle: string | undefined;
      if (showingColumns) {
        sourceHandle = `${e.source_node}.${e.source_column}`;
        targetHandle = `${e.target_node}.${e.target_column}`;
      } else if (!hasWaypoints) {
        sourceHandle = `${e.source_node}__source__right`;
        targetHandle = `${e.target_node}__target__left`;
      }

      const isSelected = e.id === selectedEdgeId;

      return {
        id: e.id,
        source: e.source_node,
        target: e.target_node,
        sourceHandle,
        targetHandle,
        type: "crowsFoot",
        selected: isSelected,
        zIndex: isSelected ? 10 : 0,
        data: {
          onEdgeClick: handleEdgeClick,
          sourceNodeId: e.source_node,
          targetNodeId: e.target_node,
          edgeId: e.id,
          waypoints: e.waypoints,
        },
      };
    });

    const visibleProductCount = rfNodes.filter((n) => n.type === "tableNode").length;
    return { nodes: rfNodes, edges: rfEdges, visibleProductCount, visibleEdgeCount: rfEdges.length };
  }, [layout, showingColumns, columnMode, domainColorMap, handleDomainClick, handleNavigateToNode, handleEdgeClick, handleTableNodeClick, nodeHighlights, selectedRel, selectedNodeId, hiddenRelated]);

  if (error) {
    const isTimeout = error.toLowerCase().includes("timed out");
    // The domain dropdown stays reachable when a layout fails (e.g. the
    // all-domains layout times out on a large model), so the user can still
    // open a single domain's diagram instead of only retrying.
    return (
      <div className="flex flex-col flex-1">
        {showDomainSelect !== false && (
          <div className="flex items-center gap-3 py-2">
            <DomainSelect
              domains={domains}
              value={selectedDomain}
              onChange={onDomainChange}
              portalContainer={portalContainer}
            />
          </div>
        )}
        <div className="flex flex-1 items-center justify-center text-muted-foreground min-h-[400px]">
          <div className="text-center space-y-3">
            <p>Failed to load diagram</p>
            <p className="text-sm text-destructive">
              {isTimeout
                ? "Layout computation timed out - the model may be too large for the current compute."
                : error}
            </p>
            <button
              onClick={() => setRetryCount((c) => c + 1)}
              className="px-4 py-1.5 text-sm rounded-md bg-primary text-primary-foreground hover:bg-primary/90 transition-colors"
            >
              Retry
            </button>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="flex flex-col flex-1">
      <DiagramControls
        domains={domains}
        selectedDomain={selectedDomain}
        onDomainChange={onDomainChange}
        columnMode={columnMode}
        onColumnModeChange={onColumnModeChange}
        totalProducts={layout?.total_products ?? 0}
        totalEdges={layout?.total_edges ?? 0}
        visibleProducts={visibleProductCount}
        visibleEdges={visibleEdgeCount}
        relatedDomains={relatedDomains}
        hiddenRelated={hiddenRelated}
        onHiddenRelatedChange={setHiddenRelated}
        isFullscreen={isFullscreen}
        onToggleFullscreen={onToggleFullscreen}
        portalContainer={portalContainer}
        selectedRelationship={selectedRel?.label ?? null}
        selectedTable={selectedNodeId ?? null}
        feedbackSlot={feedbackSlot}
        showDomainSelect={showDomainSelect}
      />

      <div
        className="border rounded-lg bg-background overflow-hidden"
        style={{
          height: isFullscreen
            ? "calc(100vh - 60px)"
            // ~220px budget for sidebar header + breadcrumb + page header + tabs
            // + diagram toolbar + page padding. Grows with the viewport and gives
            // the diagram the majority of the available height on laptop + desktop.
            : "calc(100vh - 220px)",
          minHeight: 400,
        }}
      >
        {loading ? (
          <div
            className="flex items-center justify-center h-full"
            data-testid="diagram-loading"
          >
            <div className="space-y-3 text-center max-w-md px-4">
              <Skeleton className="h-8 w-48 mx-auto" />
              <p className="text-sm text-muted-foreground">
                {pendingInfo && pendingInfo.queue_position != null ? (
                  <>
                    Computing layout - #{pendingInfo.queue_position} of{" "}
                    {pendingInfo.total_in_queue} in queue
                    {pendingInfo.last_heartbeat_ms > 0 && (
                      <>
                        , last update{" "}
                        {formatRelativeTime(pendingInfo.last_heartbeat_ms)}
                      </>
                    )}
                  </>
                ) : (
                  <>
                    Computing layout...
                    {computeElapsedMs > 0 && (
                      <> ({Math.round(computeElapsedMs / 1000)}s elapsed)</>
                    )}
                  </>
                )}
              </p>
              {computeElapsedMs > 30_000 && (
                <p className="text-xs text-muted-foreground">
                  Large models can take several minutes on first view; the
                  result is then cached so subsequent loads are instant.
                </p>
              )}
            </div>
          </div>
        ) : layout && (layout.nodes ?? []).length === 0 ? (
          <div className="flex items-center justify-center h-full text-muted-foreground">
            No tables to display
          </div>
        ) : (
          <ReactFlow
            nodes={nodes}
            edges={edges}
            nodeTypes={nodeTypes}
            edgeTypes={edgeTypes}
            fitView
            fitViewOptions={{ padding: FIT_VIEW_PADDING }}
            minZoom={MIN_ZOOM}
            maxZoom={MAX_ZOOM}
            proOptions={{ hideAttribution: true }}
            nodesDraggable={false}
            nodesConnectable={false}
            elementsSelectable
            panOnDrag
            zoomOnScroll
            zoomOnDoubleClick={false}
            defaultEdgeOptions={{ type: "crowsFoot" }}
            onPaneClick={handlePaneClick}
          >
            <CrowsFootMarkerDefs />
            <Controls showInteractive={false} position="bottom-left" />
          </ReactFlow>
        )}
      </div>
    </div>
  );
}
