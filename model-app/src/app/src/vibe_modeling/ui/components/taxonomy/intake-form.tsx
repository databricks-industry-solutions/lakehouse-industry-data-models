import { Suspense, useState } from "react";
import type { TaxonomyIntake } from "@/lib/api";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Textarea } from "@/components/ui/textarea";
import { Skeleton } from "@/components/ui/skeleton";
import { SectorSelect } from "@/components/business/sector-select";

// Mirrors BusinessIn.name / TaxonomyIntake.company_name.
export const BUSINESS_NAME_RE = /^[A-Za-z0-9][A-Za-z0-9 _\-&.,'()]{0,127}$/;

export type SkipStart = "blank" | "example";

type Props = {
  initial?: Partial<TaxonomyIntake>;
  initialSectorId?: string | null;
  submitting: boolean;
  onDraft: (intake: TaxonomyIntake, sectorId: string | null) => void;
  onSkip: (intake: TaxonomyIntake, sectorId: string | null, start: SkipStart) => void;
};

export function IntakeForm({ initial, initialSectorId = null, submitting, onDraft, onSkip }: Props) {
  const [v, setV] = useState<TaxonomyIntake>({
    company_name: "", industry: "", one_liner: "", known_domains: "", key_systems: "", regulators: "", pasted_doc: "", ...initial,
  });
  const [sectorId, setSectorId] = useState<string | null>(initialSectorId);
  const set = (k: keyof TaxonomyIntake) => (e: { target: { value: string } }) => setV((p) => ({ ...p, [k]: e.target.value }));
  const nameBad = v.company_name.length > 0 && !BUSINESS_NAME_RE.test(v.company_name);
  const ready = BUSINESS_NAME_RE.test(v.company_name) && v.industry.trim().length > 0;

  return (
    <form className="max-w-3xl space-y-4" onSubmit={(e) => { e.preventDefault(); if (ready) onDraft(v, sectorId); }}>
      <div className="grid gap-4 md:grid-cols-2">
        <label className="space-y-1 text-sm font-medium">Company name *
          <Input value={v.company_name} onChange={set("company_name")} placeholder="e.g. Ridgeline Energy" />
          {nameBad && <span className="block text-xs text-destructive">Use letters, numbers, spaces and _ - &amp; . , ' ( ) only; start with a letter or number.</span>}
        </label>
        <label className="space-y-1 text-sm font-medium">Industry *
          <Input value={v.industry} onChange={set("industry")} placeholder="e.g. Electric & gas utility" />
        </label>
      </div>
      <div className="space-y-1 text-sm font-medium">Sector
        <Suspense fallback={<Skeleton className="h-9 w-full" />}><SectorSelect value={sectorId} onChange={setSectorId} /></Suspense>
      </div>
      <label className="block space-y-1 text-sm font-medium">One-line description
        <Input value={v.one_liner} onChange={set("one_liner")} placeholder="What the company does, in a sentence" />
      </label>
      <p className="text-xs text-muted-foreground">Optional. Anything you enter here is kept as-is; the model fills in the rest.</p>
      <div className="grid gap-4 md:grid-cols-3">
        <label className="space-y-1 text-sm font-medium">Domains you already use
          <Textarea rows={3} value={v.known_domains} onChange={set("known_domains")} placeholder="billing, asset management, …" />
        </label>
        <label className="space-y-1 text-sm font-medium">Key systems
          <Textarea rows={3} value={v.key_systems} onChange={set("key_systems")} placeholder="SAP S/4HANA, Salesforce, Maximo, …" />
        </label>
        <label className="space-y-1 text-sm font-medium">Regulators
          <Textarea rows={3} value={v.regulators} onChange={set("regulators")} placeholder="PUC, FERC, PHMSA, …" />
        </label>
      </div>
      <label className="block space-y-1 text-sm font-medium">Paste an existing document (capability map, org chart, strategy page)
        <Textarea rows={6} value={v.pasted_doc} onChange={set("pasted_doc")} maxLength={60000} />
      </label>
      <div className="flex flex-wrap items-center gap-2">
        <Button type="submit" disabled={!ready || submitting}>{submitting ? "Starting…" : "Draft with the model"}</Button>
        <span className="text-xs text-muted-foreground">or skip drafting:</span>
        <Button type="button" variant="outline" disabled={!ready || submitting} onClick={() => onSkip(v, sectorId, "blank")}>
          Start blank
        </Button>
        <Button type="button" variant="outline" disabled={!ready || submitting} onClick={() => onSkip(v, sectorId, "example")}>
          Start from the Ridgeline example
        </Button>
      </div>
    </form>
  );
}
