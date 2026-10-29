import { createFileRoute, Link } from "@tanstack/react-router";
import { keepPreviousData, useQuery } from "@tanstack/react-query";
import { useEffect, useMemo, useRef, useState, type ReactNode } from "react";
import { ArrowLeft } from "lucide-react";
import {
  compileTaxonomy, createTaxonomyDraft, getTaxonomyExample,
  type TaxonomyExampleOut, type TaxonomyIntake, type TaxonomySection, type TaxonomyTree,
  type TaxonomyWizardStateOut,
} from "@/lib/api";
import { formatRelative } from "@/lib/date";
import { apiErrorMessage } from "@/lib/api-error";
import { useDebouncedValue } from "@/lib/hooks";
import { notifyError } from "@/lib/notify";
import { draftCreateBody, useTaxonomyDraft, useTaxonomyDraftActions } from "@/lib/taxonomy/use-taxonomy-draft";
import { SAVE_FAILED_COPY, savableParts, useSavedWizard } from "@/lib/taxonomy/use-saved-wizard";
import { useBusyAutoRetry } from "@/lib/taxonomy/busy-retry";
import { TREE_FALLBACK_STATUSES } from "@/lib/taxonomy/part-status";
import { emptyTree, finishedParts, sanitize } from "@/lib/taxonomy/tree";
import { Button } from "@/components/ui/button";
import { BusyCountdown } from "@/components/taxonomy/busy-countdown";
import { CompileIssues } from "@/components/taxonomy/compile-issues";
import { DraftProgress, PART_ORDER, SECTION_LABELS } from "@/components/taxonomy/draft-progress";
import { IntakeForm, type SkipStart } from "@/components/taxonomy/intake-form";
import { OutlineEditor } from "@/components/taxonomy/outline-editor";
import { MastersRelationshipsEditor } from "@/components/taxonomy/masters-relationships-editor";
import { SectionCard } from "@/components/taxonomy/section-card";
import { ReviewStep } from "@/components/taxonomy/review-step";
import { Skeleton } from "@/components/ui/skeleton";
import { FeatureGate } from "@/components/feature-gate";
import { HelpLink } from "@/components/help/help-link";
import { ORG_DIVISIONS_PRESETS } from "@/lib/org-divisions";
import { joinCommaList, splitCommaList } from "@/lib/comma-list";

export const Route = createFileRoute("/_sidebar/businesses/new_/from-domains")({ component: WizardGate });

/** The page header of the builder: back to home, the title and its help link. */
function WizardHeader() {
  return (
    <div className="flex items-center gap-4">
      <Button variant="ghost" size="icon" asChild><Link to="/"><ArrowLeft className="h-4 w-4" /></Link></Button>
      <h1 className="text-2xl font-semibold tracking-tight">Build from your domains</h1>
      <HelpLink topic="taxonomy-builder" label="Help: building a business from your domains" />
    </div>
  );
}

function GateFrame({ children }: { children: ReactNode }) {
  return (
    <div className="space-y-6 p-6">
      <WizardHeader />
      <div className="max-w-2xl" data-testid="taxonomy-gate">{children}</div>
    </div>
  );
}

/**
 * Entry check for the optional builder (`FeatureGate`): not installed, or
 * installed but not ready (no model service, or its last test call was
 * refused), shows the shared notice instead of the wizard. Once the wizard
 * has been shown it stays mounted, so a refusal later (a draft start or retry
 * refused with 422 `config_missing` or 400 `model_service_refused`, shown by
 * `notifyError` with a Settings link) never throws away the user's edits.
 */
function WizardGate() {
  return (
    <FeatureGate feature="taxonomy" requireReady keepMounted frame={(state) => <GateFrame>{state}</GateFrame>}>
      <Wizard />
    </FeatureGate>
  );
}

const STEPS = ["Tell us about you", "Domains", "Everything else", "Review & create"];
const SECTION_PARTS = PART_ORDER.filter((k) => k !== "tree");
const INLINE_COMPILE_DEBOUNCE_MS = 400;



/** Comma-separated division names. Keeps its own text so typing ", " isn't eaten by re-joining. */
function DivisionsInput({ value, onChange }: { value: string[]; onChange: (v: string[]) => void }) {
  const [text, setText] = useState(joinCommaList(value));
  useEffect(() => {
    // Resync only when the tree changed from outside (draft landed, example loaded).
    if (splitCommaList(text).join("\u0000") !== value.join("\u0000")) setText(joinCommaList(value));
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [value]);
  return (
    <label className="flex items-center gap-1">Division names
      <input className="h-7 w-80 rounded border bg-background px-2 text-xs" value={text}
        placeholder="Customer Operations, Grid & Gas Operations, Corporate"
        onChange={(e) => { setText(e.target.value); onChange(splitCommaList(e.target.value)); }} />
    </label>
  );
}

/** "Resume where you left off": the saved wizard found on opening, with Resume and Start over. */
function ResumeCard({ saved, busy, onResume, onStartOver }: {
  saved: TaxonomyWizardStateOut; busy: boolean; onResume: () => void; onStartOver: () => void;
}) {
  return (
    <div className="max-w-2xl space-y-3 rounded-md border p-4 text-sm" data-testid="taxonomy-resume">
      <p className="font-medium">
        Resume where you left off ({STEPS[saved.step] ?? STEPS[0]} step, saved {formatRelative(saved.updated_at, "earlier")})
      </p>
      <p className="text-muted-foreground">
        Your saved work for {saved.intake.company_name}. Starting over deletes it. Parts that were still drafting are not saved.
        {saved.step >= 3 && " The description is written again when you resume."}
      </p>
      <div className="flex gap-2">
        <Button size="sm" onClick={onResume} disabled={busy}>Resume</Button>
        <Button size="sm" variant="outline" onClick={onStartOver} disabled={busy}>Start over</Button>
      </div>
    </div>
  );
}

const SAVE_STATUS_COPY = {
  idle: "",
  saving: "Saving…",
  saved: "Progress saved",
  error: SAVE_FAILED_COPY,
} as const;
const NAME_DOMAINS_FIRST = "Name every domain first.";

function Wizard() {
  const saved = useSavedWizard();
  // The resume card was answered (or there was nothing saved). Autosave runs only after that.
  const [decided, setDecided] = useState(false);
  const [discarding, setDiscarding] = useState(false);
  // Restored from a save, and no draft started since: offer to draft the missing parts.
  const [resumed, setResumed] = useState(false);
  const lastCleanTree = useRef<TaxonomyTree | null>(null);
  const [step, setStep] = useState(0);
  const [intake, setIntake] = useState<TaxonomyIntake | null>(null);
  const [sectorId, setSectorId] = useState<string | null>(null);
  const [draftId, setDraftId] = useState<string | null>(null);
  const [starting, setStarting] = useState(false);
  const [tree, setTree] = useState<TaxonomyTree | null>(null);
  const [sections, setSections] = useState<Record<string, TaxonomySection>>({});
  const [strictness, setStrictness] = useState<"strict" | "guided">("strict");
  const [sorConfirmed, setSorConfirmed] = useState(false);
  const [example, setExample] = useState<TaxonomyExampleOut | null>(null);
  const [initialDescription, setInitialDescription] = useState<string | undefined>(undefined);
  const { draft, lost } = useTaxonomyDraft(draftId);
  const { retry, cancel } = useTaxonomyDraftActions(draftId);
  // Only the tree counts down while it is busy (the sections wait for it), and
  // only while its countdown is on screen: Step 1's fallback without a tree, or
  // DraftProgress on Steps 1-2 with one.
  const treeCountdownShown = step === 1 || (step === 2 && tree !== null);
  const treeRetry = useBusyAutoRetry(treeCountdownShown ? draft?.parts.tree?.status : undefined, {
    retry: () => retry("tree"), cancel, resetKey: draftId,
  });

  useEffect(() => { getTaxonomyExample().then((r) => setExample(r.data)).catch(() => {}); }, []);

  if (!decided && saved.loaded === null) setDecided(true);
  const autosave = decided && saved.loaded !== undefined;

  // Autosave the whole wizard once there is an intake; the hook debounces it.
  const { schedule } = saved;
  useEffect(() => {
    if (!autosave || !intake) return;
    const parts = savableParts(tree, sections, lastCleanTree.current);
    lastCleanTree.current = parts.clean ?? (tree ? lastCleanTree.current : null);
    schedule({ step, intake, sector_id: sectorId, strictness, tree: parts.tree, sections: parts.sections });
  }, [autosave, schedule, step, intake, sectorId, strictness, tree, sections]);

  /** Put a saved wizard back on screen. Parts that were drafting when it was
   *  saved are missing; the not-drafted notice offers to draft them. */
  const restore = (s: TaxonomyWizardStateOut) => {
    const at = s.tree ? s.step : Math.min(s.step, 1);
    setIntake(s.intake); setSectorId(s.sector_id ?? null); setStrictness(s.strictness);
    setTree(s.tree ?? null); setSections(s.sections); setStep(at); setSorConfirmed(at >= 3);
    setDraftId(null); setInitialDescription(undefined);
    lastCleanTree.current = s.tree ?? null;
    setResumed(true);
  };

  const resetWizard = () => {
    setIntake(null); setSectorId(null); setTree(null); setSections({}); setStep(0); setStrictness("strict");
    setSorConfirmed(false); setDraftId(null); setInitialDescription(undefined); setResumed(false);
    lastCleanTree.current = null;
  };

  const startOver = async () => {
    setDiscarding(true);
    try {
      await saved.discard();
      setDecided(true);
    } catch (err) {
      notifyError(err, { fallback: "Couldn't delete the saved work" });
    } finally {
      setDiscarding(false);
    }
  };

  const loadNewer = async () => {
    try {
      const newer = await saved.loadNewer();
      if (newer) restore(newer); else resetWizard();
    } catch (err) {
      notifyError(err, { fallback: "Couldn't load the newer save" });
    }
  };

  // Copy drafted parts into local (editable) state once each lands; never overwrite user edits.
  useEffect(() => {
    if (!draft) return;
    const t = draft.parts.tree;
    if (t?.status === "done" && t.tree && !tree) setTree(t.tree);
    setSections((prev) => {
      const next = { ...prev };
      for (const k of SECTION_PARTS) {
        const p = draft.parts[k];
        if (p?.status === "done" && p.section && !next[k]) next[k] = p.section;
      }
      return next;
    });
  }, [draft, tree]);

  // Step 2 inline check: debounced compile of the sanitized tree (warnings + errors under the editor).
  const debouncedTree = useDebouncedValue(tree, INLINE_COMPILE_DEBOUNCE_MS);
  const inlineClean = useMemo(() => (debouncedTree ? sanitize(debouncedTree, {}) : null), [debouncedTree]);
  const inlineBlocked = !inlineClean || inlineClean.problems.length > 0;
  const inline = useQuery({
    queryKey: ["taxonomy-compile-inline", inlineClean?.tree, strictness],
    queryFn: async () => (await compileTaxonomy({ tree: inlineClean!.tree, strictness, sections: {} })).data,
    enabled: step === 1 && !inlineBlocked,
    retry: false,
    placeholderData: keepPreviousData,
  });
  // Per-card attribution uses issue indices, so only issues for exactly the
  // current tree: none while the debounce is pending, while the shown result is
  // the previous tree's (placeholder data), or while blank names block the
  // compile (local problems show instead).
  const cardIssues = debouncedTree === tree && !inline.isPlaceholderData && !inlineBlocked ? inline.data?.issues : undefined;

  /** Start a draft. From the intake form it starts fresh. "Draft again" after a
   *  lost draft, and drafting what a resumed wizard is missing, pass
   *  `keepEdits`: the user's tree and sections go along as seeds, so the
   *  server drafts only the missing parts; the step stays, and the
   *  copy-only-if-empty effect above fills only what is missing. */
  const startDraft = async (i: TaxonomyIntake, sec: string | null, { keepEdits = false } = {}) => {
    setIntake(i); setSectorId(sec); setStarting(true);
    try {
      const r = await createTaxonomyDraft(draftCreateBody(i, keepEdits ? { tree: seedTree, sections } : undefined));
      if (!keepEdits) { setTree(null); setSections({}); setStep(1); }
      setResumed(false);
      setDraftId(r.data.draft_id);
    } catch (err) {
      notifyError(err, { fallback: "Couldn't start drafting" });
    } finally {
      setStarting(false);
    }
  };

  const loadExample = async () => {
    try {
      const ex = example ?? (await getTaxonomyExample()).data;
      setExample(ex);
      setTree(ex.tree);
      setSections(ex.sections);
      setInitialDescription(ex.description);
    } catch (err) {
      notifyError(err, { fallback: "Couldn't load the Ridgeline example" });
      setTree(emptyTree());
      setSections({});
    }
  };

  const skip = async (i: TaxonomyIntake, sec: string | null, start: SkipStart) => {
    setIntake(i); setSectorId(sec); setDraftId(null); setInitialDescription(undefined); setResumed(false);
    if (start === "example") {
      await loadExample();
    } else {
      setTree(emptyTree());
      setSections({});
    }
    setStep(1);
  };

  const partStatus = (k: string) => draft?.parts[k]?.status ?? (draftId ? "pending" : "done");
  // A resumed wizard whose domains were still drafting when it was saved.
  const treeNotDrafted = resumed && !draftId && !tree;
  const missingSections = resumed && !draftId && tree ? SECTION_PARTS.filter((k) => !sections[k]) : [];
  const draftMissing = () => intake && startDraft(intake, sectorId, { keepEdits: true });
  // The tree a redraft seeds: the live tree when it has no problems, else the
  // last one that had none. With neither (a name blank since the tree arrived)
  // a redraft would draft a new tree the editor then ignores, so it is blocked.
  const seedTree = tree ? (finishedParts(tree, {}).tree ?? lastCleanTree.current) : null;
  const seedBlocked = tree !== null && seedTree === null;

  if (!decided && saved.loaded) {
    return (
      <div className="space-y-6 p-6">
        <WizardHeader />
        <ResumeCard saved={saved.loaded} busy={discarding}
          onResume={() => { restore(saved.loaded!); setDecided(true); }} onStartOver={startOver} />
      </div>
    );
  }

  return (
    <div className="space-y-6 p-6">
      <WizardHeader />
      <div className="flex flex-wrap items-center gap-x-6 gap-y-1">
        <ol className="flex gap-4 text-sm">
          {STEPS.map((s, i) => (
            <li key={s} className={i === step ? "font-semibold" : "text-muted-foreground"}>{i + 1}. {s}</li>
          ))}
        </ol>
        {SAVE_STATUS_COPY[saved.status] && (
          <p className={saved.status === "error" ? "text-xs text-destructive" : "text-xs text-muted-foreground"}
            role="status" data-testid="taxonomy-save-status">{saved.status === "error" ? saved.error ?? SAVE_FAILED_COPY : SAVE_STATUS_COPY[saved.status]}</p>
        )}
      </div>

      {!autosave && <Skeleton className="h-64 w-full max-w-4xl" />}
      {saved.conflict && (
        <div className="flex flex-wrap items-center gap-2 rounded border border-destructive/40 p-2 text-sm" data-testid="taxonomy-save-conflict">
          {saved.conflict.message} Saving is paused.
          {/* Revision 0: the save was cleared elsewhere, so there is nothing newer to load. */}
          <Button size="sm" variant="outline" onClick={loadNewer}>{saved.conflict.revision === 0 ? "Start over" : "Load the newer save"}</Button>
          <Button size="sm" variant="outline" onClick={saved.keepMine}>Keep this tab's version</Button>
        </div>
      )}
      {missingSections.length > 0 && step >= 1 && step <= 2 && (
        <div className="flex flex-wrap items-center gap-2 rounded border p-2 text-sm" data-testid="taxonomy-not-drafted">
          Not drafted yet: {missingSections.map((k) => SECTION_LABELS[k]).join(", ")}.
          <Button size="sm" variant="outline" onClick={draftMissing} disabled={starting || seedBlocked}>Draft the missing parts</Button>
          {seedBlocked && <span className="text-muted-foreground">{NAME_DOMAINS_FIRST}</span>}
        </div>
      )}

      {lost && intake && (
        <div className="flex items-center gap-2 rounded border border-destructive/40 p-2 text-sm">
          This draft was lost (the app restarted or it expired).
          <Button size="sm" variant="outline" onClick={() => startDraft(intake, sectorId, { keepEdits: true })} disabled={starting || seedBlocked}>Draft again</Button>
          {seedBlocked && <span className="text-muted-foreground">{NAME_DOMAINS_FIRST}</span>}
        </div>
      )}
      {draft && step > 0 && step < 3 && (
        // With no tree yet, step 1 shows the tree countdown itself.
        <DraftProgress draft={draft} onCancel={cancel} treeRetry={tree ? treeRetry : undefined} />
      )}

      {autosave && step === 0 && <IntakeForm initial={intake ?? undefined} initialSectorId={sectorId} submitting={starting} onDraft={startDraft} onSkip={skip} />}

      {step === 1 && (
        <div className="space-y-4">
          {!tree && !treeNotDrafted && !TREE_FALLBACK_STATUSES.has(partStatus("tree")) && <p className="text-sm text-muted-foreground">Waiting for the domain draft…</p>}
          {!tree && (treeNotDrafted || TREE_FALLBACK_STATUSES.has(partStatus("tree"))) && (
            <div className="flex flex-wrap items-center gap-2">
              {treeNotDrafted && <p className="w-full text-sm text-muted-foreground">The domains were still drafting when your work was saved.</p>}
              {treeNotDrafted
                ? <Button variant="outline" onClick={draftMissing} disabled={starting}>Draft the domains</Button>
                : treeRetry.busy
                ? <BusyCountdown state={treeRetry} retryLabel="Retry domains" testId="tree-busy-countdown" />
                : <Button variant="outline" onClick={() => retry("tree")}>Retry domains</Button>}
              {/* Dropping the draft id makes the section cards behave as on the skip path (no draft errors/Retry). */}
              <Button variant="outline" onClick={() => { setDraftId(null); setResumed(false); setTree(emptyTree()); setSections({}); }}>Start blank</Button>
              <Button variant="outline" onClick={() => { setDraftId(null); setResumed(false); setInitialDescription(undefined); void loadExample(); }}>Start from the Ridgeline example</Button>
            </div>
          )}
          {tree && (
            <>
              <OutlineEditor tree={tree} onChange={setTree} issues={cardIssues} />
              <MastersRelationshipsEditor tree={tree} onChange={setTree} />
              <div className="flex flex-wrap items-center gap-4 text-sm">
                <label className="flex items-center gap-1"><input type="radio" checked={strictness === "strict"} onChange={() => setStrictness("strict")} /> Strict — exactly these domains</label>
                <label className="flex items-center gap-1"><input type="radio" checked={strictness === "guided"} onChange={() => setStrictness("guided")} /> Guided — suggest missing domains</label>
                <label className="flex items-center gap-1">Organization divisions
                  <select className="rounded border bg-background text-xs" value={tree.coverage} onChange={(e) => setTree({ ...tree, coverage: e.target.value as TaxonomyTree["coverage"] })}>
                    {ORG_DIVISIONS_PRESETS.map((p) => <option key={p}>{p}</option>)}
                  </select>
                </label>
                <DivisionsInput value={tree.division_names ?? []} onChange={(division_names) => setTree({ ...tree, division_names })} />
              </div>
              <CompileIssues
                problems={inlineClean?.problems ?? []}
                issues={inlineBlocked ? [] : inline.data?.issues ?? []}
                error={inline.error ? apiErrorMessage(inline.error, "Couldn't check the taxonomy") : null}
              />
              <div className="flex gap-2">
                <Button variant="outline" onClick={() => setStep(0)}>Back</Button>
                <Button onClick={() => setStep(2)} disabled={tree.domains.length === 0}>Continue</Button>
              </div>
            </>
          )}
          {!tree && <Button variant="outline" onClick={() => setStep(0)}>Back</Button>}
        </div>
      )}

      {step === 2 && (
        <div className="space-y-3">
          {SECTION_PARTS.map((k) => (
            <SectionCard key={k} sectionKey={k} section={sections[k]} partStatus={partStatus(k)} partError={draft?.parts[k]?.error}
              exampleText={example?.sections[k]?.claims.map((c) => c.text).join(" ") ?? ""}
              onChange={(s) => setSections((p) => ({ ...p, [k]: s }))} onRetry={() => retry(k)}
              onCancel={cancel} waitingForTree={partStatus("tree") === "busy"} draftId={draftId} />
          ))}
          <label className="flex items-center gap-2 text-sm">
            <input type="checkbox" checked={sorConfirmed} onChange={(e) => setSorConfirmed(e.target.checked)} />
            I've checked the systems of record — they're right for us.
          </label>
          <div className="flex gap-2">
            <Button variant="outline" onClick={() => setStep(1)}>Back</Button>
            <Button onClick={() => setStep(3)} disabled={!sorConfirmed}>Continue</Button>
          </div>
        </div>
      )}

      {step === 3 && intake && tree && (
        <div className="space-y-4">
          <ReviewStep intake={intake} sectorId={sectorId} tree={tree} strictness={strictness} sections={sections}
            initialDescription={initialDescription} onCreated={saved.close} />
          <Button variant="outline" onClick={() => setStep(2)}>Back</Button>
        </div>
      )}
    </div>
  );
}
