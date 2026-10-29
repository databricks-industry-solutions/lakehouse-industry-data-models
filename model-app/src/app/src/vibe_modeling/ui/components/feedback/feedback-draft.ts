import { useCallback, useEffect, useSyncExternalStore } from "react";
import { useRouterState } from "@tanstack/react-router";
import type { FeedbackContext, VibeInputPriority } from "@/lib/api";

/**
 * The open Add-feedback draft, per business + model version, kept outside the
 * button and dialog components so it survives tab switches on ONE page. A
 * surface mounts its one Add-feedback button in different slots (the diagram
 * toolbar on the Diagram tab, the tab bar elsewhere; fullscreen re-portals
 * it), so the button remounts on a tab change and reads the draft back.
 *
 * Lifetime: Cancel, the X and Escape discard it, a save clears it, and
 * leaving the page (a pathname change; a `?tab=` change keeps the pathname)
 * discards it, so a dialog never reopens on another page with the first
 * page's context.
 */
export interface FeedbackDraft {
  open: boolean;
  context: FeedbackContext;
  text: string;
  priority: VibeInputPriority;
}

interface StoredDraft extends FeedbackDraft {
  /** The pathname the draft was written on. */
  path: string;
}

const EMPTY_DRAFT: FeedbackDraft = {
  open: false,
  context: {},
  text: "",
  priority: "medium",
};

const drafts = new Map<string, StoredDraft>();
const listeners = new Set<() => void>();

function draftKey(businessId: string, versionId: string | undefined): string {
  return `${businessId}\u0000${versionId ?? ""}`;
}

function currentPath(): string {
  return window.location.pathname;
}

/** The draft for `key` if it belongs to the page in view. */
function liveDraft(key: string): StoredDraft | undefined {
  const d = drafts.get(key);
  return d && d.path === currentPath() ? d : undefined;
}

function subscribe(listener: () => void): () => void {
  listeners.add(listener);
  return () => listeners.delete(listener);
}

function notify(): void {
  listeners.forEach((l) => l());
}

/** The draft for this business + version, a patch setter, and a discard. */
export function useFeedbackDraft(
  businessId: string,
  versionId: string | undefined,
): [FeedbackDraft, (patch: Partial<FeedbackDraft>) => void, () => void] {
  const key = draftKey(businessId, versionId);
  const draft = useSyncExternalStore(subscribe, () => liveDraft(key) ?? EMPTY_DRAFT);
  const update = useCallback((patch: Partial<FeedbackDraft>) => {
    drafts.set(key, { ...(liveDraft(key) ?? EMPTY_DRAFT), ...patch, path: currentPath() });
    notify();
  }, [key]);
  const discard = useCallback(() => {
    drafts.delete(key);
    notify();
  }, [key]);
  return [draft, update, discard];
}

/** Drop every draft written on another page than `path`. */
export function discardFeedbackDraftsOffPage(path: string): void {
  let dropped = false;
  for (const [key, d] of drafts) {
    if (d.path !== path) {
      drafts.delete(key);
      dropped = true;
    }
  }
  if (dropped) notify();
}

/** Mounted once at the app root: leaving a page discards its draft, so it
 *  doesn't come back when the user later returns to that page. */
export function FeedbackDraftPageScope(): null {
  const pathname = useRouterState({ select: (s) => s.location.pathname });
  useEffect(() => {
    discardFeedbackDraftsOffPage(pathname);
  }, [pathname]);
  return null;
}

/** Drop every draft without notifying (tests start from an empty store;
 *  their components are unmounted right after). */
export function resetFeedbackDrafts(): void {
  drafts.clear();
}
