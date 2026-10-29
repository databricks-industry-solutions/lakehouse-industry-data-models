import { Link } from "@tanstack/react-router";
import { Factory, Plus, FileUp, ArrowRight, Network } from "lucide-react";
import { ImportNewBusinessDialog } from "@/components/import/import-new-business-dialog";
import { useTaxonomyReady } from "@/lib/features";

// Static class strings so Tailwind keeps them; indexed by the card count.
// Three cards keep the original single-row layout from `sm` up; four go
// two-by-two at `sm` and one row at `lg`.
const GRID_COLS: Record<number, string> = {
  3: "sm:grid-cols-3",
  4: "sm:grid-cols-2 lg:grid-cols-4",
};

/**
 * The primary ways to start something new — shown quietly under "Jump back
 * in" for a returning user, and elevated in the empty state. `emphasis`
 * bumps the visual weight for the newcomer case.
 *
 * "Build from your domains" (the optional Domain Taxonomy Builder) shows only
 * when the backend reports it `ready` - installed, a model service set, and
 * its last test call not refused. Hidden while loading and on error, so a
 * button never appears that can't be used.
 */
export function EntryPoints({ emphasis = false }: { emphasis?: boolean }) {
  const base =
    "group flex items-center gap-3 rounded-md border bg-card p-4 text-left transition-colors hover:bg-accent";
  const border = emphasis ? "border-input" : "border-border hover:border-input";

  const iconWrap =
    "flex h-9 w-9 shrink-0 items-center justify-center rounded-sm border border-border bg-muted text-muted-foreground";

  const showTaxonomy = useTaxonomyReady().ready;
  const cards = showTaxonomy ? 4 : 3;

  return (
    <div className={`grid gap-3 ${GRID_COLS[cards]}`}>
      <Link to="/industries" className={`${base} ${border}`}>
        <span className={iconWrap}>
          <Factory className="h-4 w-4" />
        </span>
        <span className="min-w-0 flex-1">
          <span className="block text-sm font-medium">Browse industries</span>
          <span className="block text-xs text-muted-foreground">
            Start from a template
          </span>
        </span>
        <ArrowRight className="h-4 w-4 shrink-0 text-muted-foreground opacity-0 transition-opacity group-hover:opacity-100" />
      </Link>

      {showTaxonomy && (
        <Link to="/businesses/new/from-domains" className={`${base} ${border}`}>
          <span className={iconWrap}>
            <Network className="h-4 w-4" />
          </span>
          <span className="min-w-0 flex-1">
            <span className="block text-sm font-medium">Build from your domains</span>
            <span className="block text-xs text-muted-foreground">The model drafts it, you shape it</span>
          </span>
          <ArrowRight className="h-4 w-4 shrink-0 text-muted-foreground opacity-0 transition-opacity group-hover:opacity-100" />
        </Link>
      )}

      <Link to="/businesses/new" className={`${base} ${border}`}>
        <span className={iconWrap}>
          <Plus className="h-4 w-4" />
        </span>
        <span className="min-w-0 flex-1">
          <span className="block text-sm font-medium">New business</span>
          <span className="block text-xs text-muted-foreground">
            Describe it in your own words
          </span>
        </span>
        <ArrowRight className="h-4 w-4 shrink-0 text-muted-foreground opacity-0 transition-opacity group-hover:opacity-100" />
      </Link>

      <ImportNewBusinessDialog
        trigger={
          <button type="button" className={`${base} ${border} w-full`}>
            <span className={iconWrap}>
              <FileUp className="h-4 w-4" />
            </span>
            <span className="min-w-0 flex-1">
              <span className="block text-sm font-medium">Import a model</span>
              <span className="block text-xs text-muted-foreground">
                Bring a pre-vibed model.json
              </span>
            </span>
            <ArrowRight className="h-4 w-4 shrink-0 text-muted-foreground opacity-0 transition-opacity group-hover:opacity-100" />
          </button>
        }
      />
    </div>
  );
}

export default EntryPoints;
