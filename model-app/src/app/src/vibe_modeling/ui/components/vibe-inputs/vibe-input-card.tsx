import { useEffect, useRef, useState } from "react";
import ReactMarkdown from "react-markdown";
import { Maximize2, ExternalLink, Trash2 } from "lucide-react";
import { Checkbox } from "@/components/ui/checkbox";
import { Badge } from "@/components/ui/badge";
import { Textarea } from "@/components/ui/textarea";
import {
  AlertDialog,
  AlertDialogAction,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
  AlertDialogTrigger,
} from "@/components/ui/alert-dialog";
import { cn } from "@/lib/utils";
import { isRichText } from "@/lib/instructions";
import type { VibeInputOut, VibeInputContextLinkOut } from "@/lib/api";
import { OriginBadge, PriorityIndicator, StateChip, ReviewChipButton } from "./chips";
import { deriveInputState } from "./state";

export interface VibeInputCardProps {
  input: VibeInputOut;
  /** Whether this input is checked for inclusion in the next run. */
  included: boolean;
  /** The input's context links (drives needs_link_review). Optional — when not
   *  loaded the review state simply can't fire. */
  links?: readonly VibeInputContextLinkOut[];
  /** Tooltip detail for the review chip (old → new anchor + reason). */
  reviewTitle?: string;
  onToggleInclude: (included: boolean) => void;
  /** Commit edited text (short inline edit). */
  onCommitText: (text: string) => void;
  onOpenInModel: () => void;
  onExpand: () => void;
  onResolveReview: () => void;
  /** Sets this card as the focused card (drives the following pane). */
  onFocus?: () => void;
  /** When false, hides the run-inclusion checkbox + its dimming — the card is a
   *  plain review/edit row (the Feedback tab). Defaults to true (compose). */
  selectable?: boolean;
  /** When provided, renders a delete action (with confirm) that soft-deletes
   *  the input. Omitted on the compose surface. */
  onDelete?: () => void;
}

/**
 * The editable Vibe Input card. The selection toggle marks this input for the
 * next run (persisted; never deletes text). Short text → inline click-to-edit;
 * rich text (newline or >150 chars) → clamped markdown preview that opens the
 * editor.
 */
export function VibeInputCard({
  input,
  included,
  links,
  reviewTitle,
  onToggleInclude,
  onCommitText,
  onOpenInModel,
  onExpand,
  onResolveReview,
  onFocus,
  selectable = true,
  onDelete,
}: VibeInputCardProps) {
  const state = deriveInputState(input, links);
  const isReview = state === "needs_link_review";
  const isDeprecated = state === "deprecated";
  const rich = isRichText(input.text);

  return (
    <div
      data-input-id={input.id}
      data-excluded={(selectable && !included) || undefined}
      onClick={onFocus}
      className={cn(
        "rounded-md border border-border bg-card p-3",
        selectable && !included && "bg-muted opacity-60",
        isReview && "border-warning/40",
        isDeprecated && "opacity-70",
      )}
    >
      <div className="flex gap-3">
        {selectable && (
          <Checkbox
            checked={included}
            onCheckedChange={(v) => onToggleInclude(v === true)}
            onClick={(e) => e.stopPropagation()}
            aria-label="Include in next run"
            className="mt-0.5 data-[state=checked]:bg-tertiary data-[state=checked]:border-tertiary data-[state=checked]:text-tertiary-foreground"
          />
        )}
        <div className="min-w-0 flex-1">
          <div className="flex flex-wrap items-center gap-2">
            <OriginBadge origin={input.origin} />
            {isReview ? (
              <ReviewChipButton title={reviewTitle} onClick={onResolveReview} />
            ) : (
              <StateChip state={state} />
            )}
            <PriorityIndicator priority={input.priority} />
            <div className="ml-auto flex items-center gap-2">
              <button
                type="button"
                title="Open full editor"
                aria-label="Open full editor"
                onClick={(e) => {
                  e.stopPropagation();
                  onExpand();
                }}
                className="text-muted-foreground transition-colors hover:text-foreground"
              >
                <Maximize2 className="h-3.5 w-3.5" />
              </button>
              <button
                type="button"
                onClick={(e) => {
                  e.stopPropagation();
                  onOpenInModel();
                }}
                className="inline-flex items-center gap-1 text-xs text-primary hover:underline"
              >
                Open in model
                <ExternalLink className="h-3 w-3" />
              </button>
              {onDelete && <DeleteAction onConfirm={onDelete} />}
            </div>
          </div>

          <div className="mt-2">
            {rich ? (
              <RichPreview text={input.text} onOpen={onExpand} />
            ) : (
              <InlineEditableText
                value={input.text}
                onCommit={onCommitText}
                disabled={isDeprecated}
              />
            )}
          </div>
        </div>
      </div>
    </div>
  );
}

/** Soft-delete action with a confirm dialog. Self-contained so any card host
 *  (the Feedback tab) gets delete by passing `onDelete`, without threading
 *  dialog state through the tree. */
function DeleteAction({ onConfirm }: { onConfirm: () => void }) {
  return (
    <AlertDialog>
      <AlertDialogTrigger asChild>
        <button
          type="button"
          title="Delete"
          aria-label="Delete"
          onClick={(e) => e.stopPropagation()}
          className="text-muted-foreground transition-colors hover:text-destructive"
        >
          <Trash2 className="h-3.5 w-3.5" />
        </button>
      </AlertDialogTrigger>
      <AlertDialogContent onClick={(e) => e.stopPropagation()}>
        <AlertDialogHeader>
          <AlertDialogTitle>Delete this feedback?</AlertDialogTitle>
          <AlertDialogDescription>
            The feedback will be marked deleted and hidden from the list. You can
            restore it from the Deprecated list on the inputs surface; links to
            prior runs are preserved for audit.
          </AlertDialogDescription>
        </AlertDialogHeader>
        <AlertDialogFooter>
          <AlertDialogCancel>Cancel</AlertDialogCancel>
          <AlertDialogAction
            onClick={onConfirm}
            className="bg-destructive text-destructive-foreground hover:bg-destructive/90"
          >
            Delete
          </AlertDialogAction>
        </AlertDialogFooter>
      </AlertDialogContent>
    </AlertDialog>
  );
}

/** Clamped rendered-markdown preview with a bottom fade; clicking opens the
 *  full editor (rich inputs are never inline-edited). */
function RichPreview({ text, onOpen }: { text: string; onOpen: () => void }) {
  return (
    <div
      onClick={(e) => {
        e.stopPropagation();
        onOpen();
      }}
      title="Open full editor"
      className="cursor-pointer"
    >
      <div className="relative max-h-[116px] overflow-hidden">
        <div className="prose prose-sm dark:prose-invert max-w-none text-sm">
          <ReactMarkdown>{text}</ReactMarkdown>
        </div>
        <div className="pointer-events-none absolute inset-x-0 bottom-0 h-8 bg-gradient-to-t from-card to-transparent" />
      </div>
      <div className="mt-1 flex items-center gap-2">
        <Badge variant="outline" className="text-[10px]">
          Rich text
        </Badge>
        <span className="text-xs text-muted-foreground">Click to open the full editor</span>
      </div>
    </div>
  );
}

/** Inline click-to-edit text. Controlled draft (textarea-fill bug fix): ⌘↵ /
 *  blur commits, Esc reverts. */
function InlineEditableText({
  value,
  onCommit,
  disabled,
}: {
  value: string;
  onCommit: (text: string) => void;
  disabled?: boolean;
}) {
  const [editing, setEditing] = useState(false);
  const [draft, setDraft] = useState(value);
  const ref = useRef<HTMLTextAreaElement>(null);

  useEffect(() => {
    setDraft(value);
  }, [value]);

  useEffect(() => {
    if (editing && ref.current) ref.current.focus();
  }, [editing]);

  const commit = () => {
    setEditing(false);
    const next = draft.trim();
    if (next && next !== value) onCommit(next);
    else setDraft(value);
  };

  if (editing) {
    return (
      <Textarea
        ref={ref}
        value={draft}
        onClick={(e) => e.stopPropagation()}
        onChange={(e) => setDraft(e.target.value)}
        onBlur={commit}
        onKeyDown={(e) => {
          if (e.key === "Enter" && (e.metaKey || e.ctrlKey)) {
            e.preventDefault();
            commit();
          }
          if (e.key === "Escape") {
            setDraft(value);
            setEditing(false);
          }
        }}
        rows={2}
        className="text-sm"
      />
    );
  }

  return (
    <div
      onClick={(e) => {
        if (disabled) return;
        e.stopPropagation();
        setEditing(true);
      }}
      title={disabled ? undefined : "Click to edit"}
      className={cn("whitespace-pre-wrap text-sm", !disabled && "cursor-text")}
    >
      {value}
    </div>
  );
}
