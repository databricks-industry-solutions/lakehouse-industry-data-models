import { useCallback, useEffect, useRef, useState } from "react";
import {
  ApiError, discardTaxonomyWizard, getSavedTaxonomyWizard, saveTaxonomyWizard,
  type TaxonomySection, type TaxonomyTree, type TaxonomyWizardStateIn, type TaxonomyWizardStateOut,
} from "@/lib/api";
import { finishedParts } from "@/lib/taxonomy/tree";

export const AUTOSAVE_DEBOUNCE_MS = 1000;
export const STALE_REVISION_FALLBACK = "This wizard was saved more recently in another tab or window.";
export const SAVE_FAILED_COPY = "Couldn't save your progress. It is tried again on your next change.";

/** The wizard document without the revision, which the hook tracks. */
export type WizardDoc = Omit<TaxonomyWizardStateIn, "revision">;
export type SaveStatus = "idle" | "saving" | "saved" | "error";
export type SaveConflict = { message: string; revision: number };

/**
 * The tree and sections to save: `finishedParts`, except that a tree with
 * problems (a name blanked mid-typing) saves as `lastClean`, the last tree
 * that had none, so it resumes as it was before.
 */
export function savableParts(
  tree: TaxonomyTree | null, sections: Record<string, TaxonomySection>, lastClean: TaxonomyTree | null,
): { tree: TaxonomyTree | null; sections: Record<string, TaxonomySection>; clean: TaxonomyTree | null } {
  const parts = finishedParts(tree, sections);
  return { tree: parts.tree ?? (tree ? lastClean : null), sections: parts.sections, clean: parts.tree };
}

/** The document a saved state holds, in the shape the wizard saves. */
export function docOf(saved: TaxonomyWizardStateOut): WizardDoc {
  return {
    step: saved.step, intake: saved.intake, sector_id: saved.sector_id ?? null, strictness: saved.strictness,
    tree: saved.tree ?? null, sections: saved.sections,
  };
}

/** Key-order-independent JSON, so a document rebuilt from the editor compares equal to the loaded one. */
export function docKey(doc: WizardDoc): string {
  return JSON.stringify(doc, (_k, v: unknown) =>
    v && typeof v === "object" && !Array.isArray(v)
      ? Object.fromEntries(Object.entries(v).filter(([, x]) => x !== undefined).sort(([a], [b]) => (a < b ? -1 : 1)))
      : v);
}

const errorText = (err: unknown): string => {
  if (err instanceof ApiError && err.status === 413) {
    const detail = (err.body as { detail?: unknown } | null)?.detail;
    if (typeof detail === "string" && detail) return detail;
  }
  return SAVE_FAILED_COPY;
};

const staleOf = (err: unknown): SaveConflict | null => {
  if (!(err instanceof ApiError) || err.status !== 409) return null;
  const detail = (err.body as { detail?: { error?: string; revision?: number; message?: string } } | null)?.detail;
  if (detail?.error !== "stale_revision") return null;
  return { revision: detail.revision ?? 0, message: detail.message || STALE_REVISION_FALLBACK };
};

/**
 * The saved Domain Taxonomy wizard (GET / PUT / DELETE /api/taxonomy/saved).
 *
 * - `loaded`: undefined while the first read runs, then the saved state or
 *   null. A failed read counts as nothing saved: the wizard opens, and a save
 *   that meets an existing row answers 409, which shows as a conflict.
 * - `schedule(doc)`: autosave, debounced 1 s; saves run one at a time, each on
 *   the revision the previous one returned. A 409 `stale_revision` stops
 *   autosave until `keepMine` (save this tab's doc over the newer one) or
 *   `loadNewer` (read the newer save; null when the other tab discarded it).
 * - The first change that leaves the document as it was loaded (Resume puts
 *   it back on screen) is not saved, so resuming writes nothing.
 * - `discard()`: Start over; when the delete fails it throws and changes
 *   nothing. `close()`: after the business exists, discard and never save
 *   again.
 * - On unmount or when the page is hidden, a pending change is saved at once.
 */
export function useSavedWizard() {
  const [loaded, setLoaded] = useState<TaxonomyWizardStateOut | null | undefined>(undefined);
  const [status, setStatus] = useState<SaveStatus>("idle");
  const [conflict, setConflict] = useState<SaveConflict | null>(null);
  const [error, setError] = useState<string | null>(null);
  const revision = useRef(0);
  // The loaded document, until the first change that differs from it.
  const baseline = useRef<string | null>(null);
  const pending = useRef<WizardDoc | null>(null);
  const inflight = useRef<Promise<void> | null>(null);
  const timer = useRef<ReturnType<typeof setTimeout> | null>(null);
  const blocked = useRef(false); // a conflict is open
  const closed = useRef(false);

  useEffect(() => {
    let alive = true;
    getSavedTaxonomyWizard()
      .then((r) => {
        if (!alive) return;
        revision.current = r.data.saved?.revision ?? 0;
        baseline.current = r.data.saved ? docKey(docOf(r.data.saved)) : null;
        setLoaded(r.data.saved ?? null);
      })
      .catch(() => { if (alive) setLoaded(null); });
    return () => { alive = false; };
  }, []);

  const clearTimer = () => {
    if (timer.current !== null) clearTimeout(timer.current);
    timer.current = null;
  };

  const run = useCallback((options?: RequestInit): Promise<void> => {
    if (inflight.current) return inflight.current;
    const doc = pending.current;
    if (!doc || blocked.current || closed.current) return Promise.resolve();
    pending.current = null;
    setStatus("saving");
    let failed = false;
    const p = (async () => {
      try {
        const r = await saveTaxonomyWizard({ ...doc, revision: revision.current }, undefined, options);
        revision.current = r.data.revision;
        setError(null);
        setStatus("saved");
      } catch (err) {
        failed = true;
        pending.current ??= doc;
        const stale = staleOf(err);
        if (stale) {
          blocked.current = true;
          setConflict(stale);
          setStatus("idle");
        } else {
          // Kept in `pending`: the next change saves it again.
          setError(errorText(err));
          setStatus("error");
        }
      } finally {
        inflight.current = null;
      }
    })();
    inflight.current = p;
    return p.then(() => {
      // A change made while this save ran is saved next; after a failure the
      // next change retries, so a lasting outage does not loop.
      if (!failed && pending.current && !blocked.current && !closed.current && timer.current === null) {
        timer.current = setTimeout(() => { timer.current = null; void run(); }, AUTOSAVE_DEBOUNCE_MS);
      }
    });
  }, []);

  const schedule = useCallback((doc: WizardDoc) => {
    if (closed.current) return;
    if (baseline.current !== null) {
      if (docKey(doc) === baseline.current) return;
      baseline.current = null;
    }
    pending.current = doc;
    clearTimer();
    timer.current = setTimeout(() => { timer.current = null; void run(); }, AUTOSAVE_DEBOUNCE_MS);
  }, [run]);

  const flushNow = useCallback((options?: RequestInit) => {
    if (timer.current === null || !pending.current) return;
    clearTimer();
    void run(options);
  }, [run]);

  useEffect(() => {
    const onHide = () => flushNow({ keepalive: true });
    window.addEventListener("pagehide", onHide);
    return () => {
      window.removeEventListener("pagehide", onHide);
      flushNow();
    };
  }, [flushNow]);

  const stopSaving = async () => {
    clearTimer();
    pending.current = null;
    if (inflight.current) await inflight.current;
  };

  const discard = useCallback(async () => {
    await stopSaving();
    await discardTaxonomyWizard();
    revision.current = 0;
    baseline.current = null;
    blocked.current = false;
    setConflict(null);
    setError(null);
    setLoaded(null);
    setStatus("idle");
  }, []);

  const close = useCallback(async () => {
    closed.current = true;
    await stopSaving();
    try { await discardTaxonomyWizard(); } catch { /* expires on its own after 7 days */ }
  }, []);

  const keepMine = useCallback(() => {
    if (!conflict) return;
    revision.current = conflict.revision;
    blocked.current = false;
    setConflict(null);
    clearTimer();
    void run();
  }, [conflict, run]);

  const loadNewer = useCallback(async (): Promise<TaxonomyWizardStateOut | null> => {
    clearTimer();
    pending.current = null;
    const r = await getSavedTaxonomyWizard();
    const saved = r.data.saved ?? null;
    revision.current = saved?.revision ?? 0;
    baseline.current = saved ? docKey(docOf(saved)) : null;
    blocked.current = false;
    setConflict(null);
    setStatus("idle");
    return saved;
  }, []);

  return { loaded, status, error, conflict, schedule, discard, close, keepMine, loadNewer };
}
