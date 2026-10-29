import type { ReactNode } from "react";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { Button } from "@/components/ui/button";
import { Maximize2, Minimize2, Table2, Link2 } from "lucide-react";
import { DomainSelect } from "./domain-select";
import { RelatedDomainsSelect } from "./related-domains-select";
import { ProductTypeLegend } from "./product-type-legend";
import { diagramColors, hexToRgba } from "./diagram-colors";
import type { ColumnDisplayMode } from "./types";

interface DiagramControlsProps {
  domains: { name: string; division: string }[];
  selectedDomain: string | null;
  onDomainChange: (domain: string | null) => void;
  columnMode: ColumnDisplayMode;
  onColumnModeChange: (mode: ColumnDisplayMode) => void;
  totalProducts: number;
  totalEdges: number;
  visibleProducts: number;
  visibleEdges: number;
  relatedDomains: { name: string; division: string }[];
  hiddenRelated: Set<string>;
  onHiddenRelatedChange: (next: Set<string>) => void;
  isFullscreen: boolean;
  onToggleFullscreen: () => void;
  /** Portal container for Select dropdowns (needed in fullscreen) */
  portalContainer?: HTMLElement | null;
  /** Text description of currently selected relationship, or null */
  selectedRelationship?: string | null;
  /** Currently selected table name, e.g. "store.location", or null */
  selectedTable?: string | null;
  /** The diagram view's Add-feedback trigger + dialog, rendered in the
   *  toolbar so it's reachable both in and out of fullscreen (item 5B). The
   *  diagram is the single home for feedback on this view; page-level
   *  callers suppress their own button while the diagram tab is active. */
  feedbackSlot?: ReactNode;
  /** Hide the toolbar's own domain dropdown on surfaces that only follow a
   *  focused input. Defaults to true. */
  showDomainSelect?: boolean;
}

export function DiagramControls({
  domains,
  selectedDomain,
  onDomainChange,
  columnMode,
  onColumnModeChange,
  totalProducts,
  totalEdges,
  visibleProducts,
  visibleEdges,
  relatedDomains,
  hiddenRelated,
  onHiddenRelatedChange,
  isFullscreen,
  onToggleFullscreen,
  portalContainer,
  selectedRelationship,
  selectedTable,
  feedbackSlot,
  showDomainSelect = true,
}: DiagramControlsProps) {
  const selectionColor = diagramColors().selection;
  const selectionChipStyle = {
    color: selectionColor,
    backgroundColor: hexToRgba(selectionColor, 0.1),
    borderColor: hexToRgba(selectionColor, 0.2),
  };
  return (
    <div className="flex items-center gap-3 py-2 flex-wrap">
      {/* Domain selector - hidden on surfaces that only follow a focused
          input (input review, following pane). */}
      {showDomainSelect && (
        <DomainSelect
          domains={domains}
          value={selectedDomain}
          onChange={onDomainChange}
          portalContainer={portalContainer}
        />
      )}

      {/* Column mode toggle (3-state cycle) */}
      <Select
        value={columnMode}
        onValueChange={(v) => onColumnModeChange(v as ColumnDisplayMode)}
      >
        <SelectTrigger className="w-[170px] h-8 text-sm">
          <SelectValue />
        </SelectTrigger>
        <SelectContent container={portalContainer}>
          <SelectItem value="hide">Hide columns</SelectItem>
          <SelectItem value="keys">Show keys (PK/FK)</SelectItem>
          <SelectItem value="all">Show all columns</SelectItem>
        </SelectContent>
      </Select>

      {/* Fullscreen toggle */}
      <Button
        variant="outline"
        size="sm"
        onClick={onToggleFullscreen}
        className="h-8"
        title={isFullscreen ? "Exit fullscreen" : "Fullscreen"}
      >
        {isFullscreen ? (
          <Minimize2 className="h-3.5 w-3.5" />
        ) : (
          <Maximize2 className="h-3.5 w-3.5" />
        )}
      </Button>

      {/* Related-domains multi-select (single-domain view only) */}
      {relatedDomains.length > 0 && (
        <RelatedDomainsSelect
          relatedDomains={relatedDomains}
          hiddenRelated={hiddenRelated}
          onHiddenRelatedChange={onHiddenRelatedChange}
          portalContainer={portalContainer}
        />
      )}

      {/* Legend */}
      <ProductTypeLegend />

      {/* Add-feedback trigger + dialog - inside the toolbar so it's reachable
          both in and out of fullscreen (item 5B). Rendered always, not
          gated on isFullscreen: this is the diagram view's single home for
          the affordance. */}
      {feedbackSlot}

      {/* Selected table */}
      {selectedTable && (
        <div
          className="flex items-center gap-1.5 text-xs font-medium px-2.5 py-1 rounded-md border"
          style={selectionChipStyle}
        >
          <Table2 className="h-3.5 w-3.5" />
          <span className="font-mono">{selectedTable}</span>
        </div>
      )}

      {/* Selected relationship */}
      {selectedRelationship && (
        <div
          className="flex items-center gap-1.5 text-xs font-medium px-2.5 py-1 rounded-md border"
          style={selectionChipStyle}
        >
          <Link2 className="h-3.5 w-3.5" />
          <span className="font-mono">{selectedRelationship}</span>
        </div>
      )}

      {/* Stats */}
      <div className="ml-auto flex items-center gap-3 text-xs text-muted-foreground">
        <span className="flex items-center gap-1">
          <Table2 className="h-3.5 w-3.5" />
          {hiddenRelated.size > 0 && visibleProducts !== totalProducts
            ? <>{visibleProducts} <span className="opacity-50">/ {totalProducts}</span> tables</>
            : <>{totalProducts} tables</>
          }
        </span>
        <span className="flex items-center gap-1">
          <Link2 className="h-3.5 w-3.5" />
          {hiddenRelated.size > 0 && visibleEdges !== totalEdges
            ? <>{visibleEdges} <span className="opacity-50">/ {totalEdges}</span> relationships</>
            : <>{totalEdges} relationships</>
          }
        </span>
      </div>
    </div>
  );
}
