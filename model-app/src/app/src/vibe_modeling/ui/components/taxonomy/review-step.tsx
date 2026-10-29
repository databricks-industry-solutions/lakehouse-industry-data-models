import { useEffect, useMemo, useRef, useState } from "react";
import { useNavigate } from "@tanstack/react-router";
import { useQuery } from "@tanstack/react-query";
import { Loader2 } from "lucide-react";
import {
  compileTaxonomy, condenseTaxonomy, createBusiness,
  type TaxonomyIntake, type TaxonomySection, type TaxonomyTree,
} from "@/lib/api";
import { apiErrorMessage, parseSettingsError } from "@/lib/api-error";
import { SettingsErrorNotice } from "@/components/feature-gate";
import { useTaxonomyDraft, useTaxonomyDraftActions } from "@/lib/taxonomy/use-taxonomy-draft";
import { useBusyAutoRetry } from "@/lib/taxonomy/busy-retry";
import { RETRYABLE_PART_STATUSES } from "@/lib/taxonomy/part-status";
import { sanitize } from "@/lib/taxonomy/tree";
import { Button } from "@/components/ui/button";
import { Textarea } from "@/components/ui/textarea";
import {
  AlertDialog, AlertDialogAction, AlertDialogCancel, AlertDialogContent,
  AlertDialogDescription, AlertDialogFooter, AlertDialogHeader, AlertDialogTitle,
} from "@/components/ui/alert-dialog";
import { BusyCountdown } from "./busy-countdown";
import { CompileIssues } from "./compile-issues";

const LIMIT = 2000;

type Props = {
  intake: TaxonomyIntake;
  sectorId: string | null;
  tree: TaxonomyTree;
  strictness: "strict" | "guided";
  sections: Record<string, TaxonomySection>;
  /** Pre-filled description (the Ridgeline example path); skips the auto-draft. */
  initialDescription?: string;
  /** After the business is created, before navigating (the wizard discards its saved state). Errors are ignored. */
  onCreated?: () => Promise<void>;
};

function download(name: string, text: string, type: string) {
  const url = URL.createObjectURL(new Blob([text], { type }));
  const a = Object.assign(document.createElement("a"), { href: url, download: name });
  a.click();
  URL.revokeObjectURL(url);
}

export function ReviewStep({ intake, sectorId, tree, strictness, sections, initialDescription, onCreated }: Props) {
  const navigate = useNavigate();
  // Never send raw editor state: the backend models are min_length=1 and would 422.
  const clean = useMemo(() => sanitize(tree, sections), [tree, sections]);
  const blocked = clean.problems.length > 0;
  const compiled = useQuery({
    queryKey: ["taxonomy-compile", clean.tree, strictness, clean.sections],
    queryFn: async () => (await compileTaxonomy({ tree: clean.tree, strictness, sections: clean.sections })).data,
    enabled: !blocked,
    retry: false, // pure code: a 422 won't fix itself
  });
  const [condenseId, setCondenseId] = useState<string | null>(null);
  const { draft: condense, lost: condenseLost } = useTaxonomyDraft(condenseId);
  const condenseActions = useTaxonomyDraftActions(condenseId);
  const [lostMsg, setLostMsg] = useState(false);
  const [description, setDescription] = useState(initialDescription ?? "");
  const [confirmRewrite, setConfirmRewrite] = useState(false);
  const [dirty, setDirty] = useState(false);
  const [creating, setCreating] = useState(false);
  const [error, setError] = useState<string | null>(null);
  // A refused or unset model service: shown with its Settings link.
  const [settingsError, setSettingsError] = useState<unknown>(null);

  // A restarted app drops in-memory drafts (404): say so and clear the id so the button works again.
  useEffect(() => {
    if (condenseLost) { setLostMsg(true); setCondenseId(null); }
  }, [condenseLost]);

  const part = condense?.parts.description;
  // Like a section card: once the user has written their own description, a
  // busy draft stops counting down (its result would never replace their text).
  const ownText = dirty && description.trim().length > 0;
  const descriptionRetry = useBusyAutoRetry(ownText ? undefined : part?.status, {
    retry: () => condenseActions.retry("description"), cancel: condenseActions.cancel, resetKey: condenseId,
  });
  useEffect(() => {
    if (part?.status === "done" && part.description && !dirty) setDescription(part.description);
  }, [part?.status, part?.description, dirty]);

  const errors = useMemo(() => (compiled.data?.issues ?? []).filter((i) => i.severity === "error"), [compiled.data]);
  const compileError = compiled.error ? apiErrorMessage(compiled.error, "Couldn't compile the taxonomy") : null;
  const over = description.length > LIMIT;
  const canCreate =
    !blocked && !compileError && Boolean(compiled.data) && errors.length === 0 &&
    description.trim().length > 0 && !over && !creating;

  const writeDescription = async () => {
    setError(null);
    setSettingsError(null);
    setLostMsg(false);
    try {
      const r = await condenseTaxonomy({ intake, tree: clean.tree, sections: clean.sections });
      setCondenseId(r.data.draft_id);
      setDirty(false);
    } catch (err) {
      if (parseSettingsError(err)) setSettingsError(err);
      else setError(apiErrorMessage(err, "Couldn't start writing the description"));
    }
  };

  // Auto-start the draft once per entry when there is nothing to keep; a failure never re-fires it.
  const autoStarted = useRef(false);
  useEffect(() => {
    if (autoStarted.current || initialDescription || blocked || dirty || description) return;
    autoStarted.current = true;
    void writeDescription();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [blocked]);

  const rewrite = () => (dirty ? setConfirmRewrite(true) : void writeDescription());
  const writing = part?.status === "running";
  // The textarea stays editable while busy, so the user can write it themselves.
  const countingDown = descriptionRetry.busy && !descriptionRetry.exhausted;

  const inFlight = useRef(false);
  const create = async () => {
    if (!compiled.data || inFlight.current) return;
    inFlight.current = true;
    setCreating(true);
    setError(null);
    setSettingsError(null);
    try {
      const biz = await createBusiness({
        name: intake.company_name,
        description,
        business_vibes: compiled.data.business_vibes,
        sector_id: sectorId,
        // Stored on the business (normalized server-side) so New Base Model
        // pre-fills from it, also after the user leaves and comes back.
        business_domains: compiled.data.business_domains,
        org_divisions: clean.tree.coverage ?? "",
      });
      await onCreated?.().catch(() => {});
      navigate({
        to: "/businesses/$businessId/runs/new",
        params: { businessId: biz.data.id },
        search: { operationType: "new base model" },
      });
    } catch (err) {
      setError(apiErrorMessage(err, "Failed to create business"));
      setCreating(false);
      inFlight.current = false;
    }
  };

  if (compiled.isLoading) return <Loader2 className="h-5 w-5 animate-spin" />;
  return (
    <div className="space-y-4">
      <CompileIssues problems={clean.problems} issues={compiled.data?.issues ?? []} error={compileError} />

      <section className="space-y-2">
        <div className="flex items-center gap-2">
          <h3 className="text-sm font-medium">Business description (≤2,000 characters)</h3>
          <Button type="button" size="sm" variant="outline" onClick={rewrite} disabled={blocked || writing || countingDown}>
            {writing ? <><Loader2 className="mr-1 h-3 w-3 animate-spin" /> The model is writing…</> : "Rewrite with the model"}
          </Button>
        </div>
        {part && RETRYABLE_PART_STATUSES.has(part.status) && <p className="text-xs text-destructive">{part.error}</p>}
        {descriptionRetry.busy && <BusyCountdown state={descriptionRetry} testId="description-busy-countdown" />}
        {lostMsg && <p className="text-xs text-destructive">The description draft was lost (the app restarted). Click Rewrite with the model again.</p>}
        {writing && !description && (
          <p className="flex items-center gap-2 text-sm text-muted-foreground"><Loader2 className="h-4 w-4 animate-spin" /> The model is writing the description…</p>
        )}
        <Textarea rows={8} placeholder={writing ? "The model is writing the description…" : undefined} value={description} onChange={(e) => { setDescription(e.target.value); setDirty(true); }} />
        <p className={`text-xs ${over ? "text-destructive" : "text-muted-foreground"}`}>
          {description.length.toLocaleString()} / {LIMIT.toLocaleString()}
        </p>
      </section>

      {compiled.data && (
        <section className="space-y-3">
          <div className="space-y-2 text-sm">
            <div><span className="font-medium">Business domains:</span> <span className="font-mono text-xs">{compiled.data.business_domains}</span></div>
            <div><span className="font-medium">Organization divisions:</span> {clean.tree.coverage}</div>
            <div className="flex gap-2">
              <Button type="button" size="sm" variant="outline" onClick={() => download(`${intake.company_name}-taxonomy.csv`, compiled.data!.csv, "text/csv")}>Download CSV</Button>
              <Button type="button" size="sm" variant="outline" onClick={() => download(`${intake.company_name}-business-vibes.md`, compiled.data!.business_vibes, "text/markdown")}>Download vibes</Button>
            </div>
          </div>
          <details className="rounded border bg-muted/40 p-2">
            <summary className="cursor-pointer text-sm font-medium">Preview what the agent will receive</summary>
            <pre className="mt-2 text-[11px] whitespace-pre-wrap">{compiled.data.business_vibes}</pre>
          </details>
        </section>
      )}

      <AlertDialog open={confirmRewrite} onOpenChange={setConfirmRewrite}>
        <AlertDialogContent>
          <AlertDialogHeader>
            <AlertDialogTitle>Replace your edits with a new draft?</AlertDialogTitle>
            <AlertDialogDescription>The model will write a fresh description and your current text will be lost.</AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter>
            <AlertDialogCancel>Keep my edits</AlertDialogCancel>
            <AlertDialogAction onClick={() => void writeDescription()}>Replace</AlertDialogAction>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>

      {error && <p className="text-sm text-destructive">{error}</p>}
      {settingsError != null && (
        <SettingsErrorNotice error={settingsError} fallback="Couldn't start writing the description" testId="description-settings-error" />
      )}
      <Button type="button" disabled={!canCreate} onClick={create}>
        {creating ? "Creating…" : "Create & configure first run"}
      </Button>
    </div>
  );
}
