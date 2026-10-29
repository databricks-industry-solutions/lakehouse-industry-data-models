import { useMemo, useState } from "react";
import { useNavigate } from "@tanstack/react-router";
import { useQueryClient } from "@tanstack/react-query";
import { notifyError } from "@/lib/notify";
import {
  useListVibeInputsSuspense,
  createVibeInput,
  updateVibeInput,
  deleteVibeInput,
  VibeInputPriority,
  type VibeInputOut,
} from "@/lib/api";
import { selector } from "@/lib/selector";
import { useDebouncedValue } from "@/lib/hooks";
import { useRunChangeReviewEnabled } from "@/lib/features";
import { SectionTree } from "@/components/vibe-inputs/section-tree";
import { InputMarkdownEditorDialog } from "@/components/vibe-inputs/input-markdown-editor-dialog";
import {
  FiltersBar,
  DEFAULT_FILTERS,
  applyFilters,
  collectDomainOptions,
  type InputFilters,
} from "@/components/vibe-inputs/filters-bar";
import { invalidateVibeInputQueries } from "@/components/vibe-inputs/query-keys";
import { invalidateEntityLists } from "@/lib/delete-invalidation";
import type { SectionAnchorIds } from "@/components/vibe-inputs/section-tree-model";

interface FeedbackListProps {
  businessId: string;
  /** Human version int as string (URL form) - for "Open in model" navigation. */
  version: string;
  /** "ecm" | "mvm". */
  scope: string;
  /** Resolved DB version id - scopes the list + anchors new feedback. */
  versionId?: string;
}

const EMPTY_SELECTION: ReadonlySet<string> = new Set();

/**
 * The Feedback tab: a review surface over ALL inputs (user feedback + agent
 * next-vibes + imports) for a version. Renders the canonical Edit-Inputs
 * `SectionTree` over the same `VibeInput` store the compose surface reads - but
 * as a review-only list: the run-inclusion checkbox is hidden
 * (`selectable={false}`) and each card carries a delete action. Origin is a
 * filter here, not a hard scope, so this tab and the inputs surface read the
 * same set and can never diverge.
 */
export function FeedbackList({ businessId, version, scope, versionId }: FeedbackListProps) {
  const navigate = useNavigate();
  const queryClient = useQueryClient();
  const reviewEnabled = useRunChangeReviewEnabled();
  const [editorInput, setEditorInput] = useState<VibeInputOut | null>(null);
  const [filters, setFilters] = useState<InputFilters>(DEFAULT_FILTERS);
  const debouncedQ = useDebouncedValue(filters.q, 250);

  // The Feedback tab is the review surface over ALL inputs (user feedback +
  // agent next-vibes + imports) - same store the compose surface reads, minus
  // the run-composition chrome. Origin is a filter, not a hard scope.
  const { data: allInputs } = useListVibeInputsSuspense({
    params: versionId
      ? { business_id: businessId, version_id: versionId }
      : { business_id: businessId },
    ...selector(),
  });

  // Active inputs only - deprecated == soft-deleted. This tab is the review
  // surface for live feedback, so it has no Deprecated state; the Deprecated
  // list with Restore is on the inputs surface, where the delete dialog points.
  const feedback = useMemo(
    () => allInputs.filter((i) => i.status !== "deprecated"),
    [allInputs],
  );

  // Same client-side filter the compose surface uses (shared applyFilters).
  // No run selection here, so the selected facet is hidden + selectedIds empty.
  const filtered = useMemo(
    () => applyFilters(feedback, { ...filters, q: debouncedQ }, EMPTY_SELECTION),
    [feedback, filters, debouncedQ],
  );
  const domainOptions = useMemo(() => collectDomainOptions(feedback), [feedback]);
  const filterActive =
    debouncedQ.trim() !== "" ||
    filters.origin !== "all" ||
    filters.state !== "all" ||
    filters.priority !== "all" ||
    filters.domain !== "all";

  const invalidate = () => invalidateVibeInputQueries(queryClient, businessId);
  const fail = (e: unknown, what: string) =>
    notifyError(e, { fallback: `Failed to ${what}` });

  const commitText = (input: VibeInputOut, text: string) =>
    updateVibeInput({ business_id: businessId, input_id: input.id }, { text })
      .then(invalidate)
      .catch((e) => fail(e, "save edit"));

  const remove = (input: VibeInputOut) =>
    deleteVibeInput({ business_id: businessId, input_id: input.id })
      .then(() => invalidateEntityLists(queryClient, "vibeInput", { businessId }))
      .catch((e) => fail(e, "delete feedback"));

  const addInput = (anchorIds: SectionAnchorIds, text: string, priority: VibeInputPriority) => {
    if (!versionId) return;
    createVibeInput(
      { business_id: businessId },
      { text, priority, version_id: versionId, ...anchorIds },
    )
      .then(invalidate)
      .catch((e) => fail(e, "add feedback"));
  };

  const openInModel = (input: VibeInputOut) =>
    navigate({
      to: "/businesses/$businessId/model/$version/$scope/inputs/$inputId",
      params: { businessId, version, scope, inputId: input.id },
      // `tab` is router-owned on the input route (defaults to the anchor-focused
      // Diagram); open on it explicitly. `from` drives the card's back link.
      search: { from: "feedback", tab: "diagram" },
    });

  // Link-review resolution lives on the inputs surface (the review queue).
  const resolveReview = () =>
    navigate({ to: `/businesses/${businessId}/model/${version}/${scope}/inputs` });

  if (!feedback.length) {
    return (
      <div className="text-center py-16 text-muted-foreground">
        <p className="mb-2">No feedback yet.</p>
        <p className="text-sm">
          Open the model's diagram, ontology, or overview and click "Add feedback" to start.
        </p>
      </div>
    );
  }

  return (
    <>
      <FiltersBar
        filters={filters}
        onChange={setFilters}
        shown={filtered.length}
        total={feedback.length}
        showSelected={false}
        showDeprecated={false}
        domains={domainOptions}
        noun="inputs"
        offerRejectedOrigin={reviewEnabled}
      />
      {filtered.length === 0 ? (
        <div className="py-12 text-center text-sm text-muted-foreground">
          No feedback matches the current filters.
        </div>
      ) : (
        <SectionTree
          inputs={filtered}
          includedIds={EMPTY_SELECTION}
          selectable={false}
          filterActive={filterActive}
          onToggleInclude={() => {}}
          onCommitText={commitText}
          onOpenInModel={openInModel}
          onExpand={setEditorInput}
          onResolveReview={resolveReview}
          onAddInput={addInput}
          onDelete={remove}
        />
      )}
      <InputMarkdownEditorDialog
        businessId={businessId}
        input={editorInput}
        open={editorInput != null}
        onOpenChange={(o) => !o && setEditorInput(null)}
        anchorLabel={editorInput?.anchor?.path?.join(" › ")}
      />
    </>
  );
}
