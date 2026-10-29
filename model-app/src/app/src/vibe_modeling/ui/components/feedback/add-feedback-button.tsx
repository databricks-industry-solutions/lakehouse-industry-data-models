import { useCallback, useEffect, type ReactNode } from "react";
import { MessageSquarePlus } from "lucide-react";
import { Button } from "@/components/ui/button";
import {
  Tooltip,
  TooltipContent,
  TooltipProvider,
  TooltipTrigger,
} from "@/components/ui/tooltip";
import { cn } from "@/lib/utils";
import { FeedbackDialog } from "./feedback-dialog";
import { useFeedbackDraft } from "./feedback-draft";
import type { FeedbackContext } from "@/lib/api";

interface AddFeedbackButtonProps {
  businessId: string;
  versionId?: string;
  /** Called at click time to snapshot the model element the surface is
   *  about (build it with `buildFeedbackContext`). */
  getContext: () => FeedbackContext;
  variant?: "default" | "outline" | "ghost";
  size?: "default" | "sm" | "icon";
  /** Optional override for the button label. Defaults to "Add <u>F</u>eedback". */
  label?: ReactNode;
  className?: string;
  /** When set, the surface has no model content to give feedback on: the
   *  button renders disabled with this text as its tooltip, and the F
   *  shortcut does nothing. */
  disabledReason?: string;
}

/**
 * Button that opens a feedback dialog pre-populated with the model element the
 * surface is about.
 *
 * The context is captured lazily at click time via `getContext` so the button
 * doesn't need to re-render on every selection change in its parent.
 */
export function AddFeedbackButton({
  businessId,
  versionId,
  getContext,
  variant = "outline",
  size = "sm",
  label,
  className,
  disabledReason,
}: AddFeedbackButtonProps) {
  // Open state and captured context live in the draft store, so a remount
  // (the button moves between the diagram toolbar and the tab bar) keeps them.
  const [draft, updateDraft] = useFeedbackDraft(businessId, versionId);

  const handleOpenChange = useCallback(
    (next: boolean) => updateDraft({ open: next }),
    [updateDraft],
  );

  const handleClick = useCallback(() => {
    updateDraft({ context: getContext(), open: true });
  }, [getContext, updateDraft]);

  useEffect(() => {
    if (disabledReason) return;
    function onKeyDown(e: KeyboardEvent) {
      if (e.key !== "f" && e.key !== "F") return;
      if (e.metaKey || e.ctrlKey || e.altKey || e.shiftKey) return;
      const active = document.activeElement as HTMLElement | null;
      if (active) {
        const tag = active.tagName;
        if (tag === "INPUT" || tag === "TEXTAREA") return;
        if (active.isContentEditable) return;
        if (active.closest('[role="dialog"]')) return;
      }
      e.preventDefault();
      handleClick();
    }
    window.addEventListener("keydown", onKeyDown);
    return () => window.removeEventListener("keydown", onKeyDown);
  }, [handleClick, disabledReason]);

  const renderedLabel = label ?? (
    <span>Add <u>F</u>eedback</span>
  );

  // Disabled covers the trigger and the F shortcut only: the dialog stays
  // mounted, so an open draft stays visible on a surface without model
  // content (the draft itself lives in the draft store).
  const trigger = disabledReason ? (
    <TooltipProvider delayDuration={200}>
      <Tooltip>
        <TooltipTrigger asChild>
          <span className={cn("inline-flex", className)} tabIndex={0} data-testid="add-feedback-disabled">
            <Button variant={variant} size={size} disabled aria-label="Add feedback">
              <MessageSquarePlus className="h-4 w-4 mr-1.5" />
              {renderedLabel}
            </Button>
          </span>
        </TooltipTrigger>
        <TooltipContent>
          <p className="max-w-xs text-sm">{disabledReason}</p>
        </TooltipContent>
      </Tooltip>
    </TooltipProvider>
  ) : (
    <Button variant={variant} size={size} onClick={handleClick} className={className}>
      <MessageSquarePlus className="h-4 w-4 mr-1.5" />
      {renderedLabel}
    </Button>
  );

  return (
    <>
      {trigger}
      <FeedbackDialog
        open={draft.open}
        onOpenChange={handleOpenChange}
        businessId={businessId}
        versionId={versionId}
        context={draft.context}
      />
    </>
  );
}
