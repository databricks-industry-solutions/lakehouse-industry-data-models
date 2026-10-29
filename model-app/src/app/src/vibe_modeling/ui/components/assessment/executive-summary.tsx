import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { MarkdownView } from "@/components/ui/markdown-view";
import { useGetAssessmentDocContent, type SummaryOut } from "@/lib/api";
import { parseAdminHelp } from "@/lib/api-error";
import { ADMIN_HELP_LEAD_DOCS, VERDICT_LABEL } from "@/lib/assessment";
import { cn } from "@/lib/utils";
import { AdminHelpBlock } from "./admin-help-block";
import { AgentText } from "./agent-text";

const VERDICT_CLASS: Record<string, string> = {
  ready_to_build: "bg-green-100 text-green-800 border-green-300",
  iterate_first: "bg-amber-100 text-amber-800 border-amber-300",
  blocked: "bg-red-100 text-red-800 border-red-300",
};

const SUMMARY_DOC = "docs/design/domain_readiness_summary.md";

function BulletList({ title, items }: { title: string; items: string[] }) {
  if (!items.length) return null;
  return (
    <div>
      <h4 className="text-sm font-semibold">{title}</h4>
      <ul className="list-disc pl-5 text-sm space-y-0.5">
        {items.map((t, i) => (
          <li key={`${i}-${t}`}><AgentText text={t} /></li>
        ))}
      </ul>
    </div>
  );
}

function SummaryFallback({ domainRunId }: { domainRunId: string }) {
  const { data, error } = useGetAssessmentDocContent({
    params: { domain_run_id: domainRunId, path: SUMMARY_DOC },
    query: { retry: false },
  });
  const help = parseAdminHelp(error);
  if (help) return <AdminHelpBlock help={help} testId="summary-admin-help" lead={ADMIN_HELP_LEAD_DOCS} />;
  if (error || !data?.data?.content) return null;
  return (
    <Card>
      <CardContent className="pt-6 text-sm">
        <MarkdownView content={data.data.content} />
      </CardContent>
    </Card>
  );
}

/** Top-of-scorecard card: verdict, headline, findings, risks and a highlighted next step; old runs fall back to the readiness-summary doc. */
export function ExecutiveSummary({ summary, domainRunId }: { summary: SummaryOut | null; domainRunId: string }) {
  if (!summary) return <SummaryFallback domainRunId={domainRunId} />;
  const verdict = summary.verdict;
  return (
    <Card>
      <CardHeader className="space-y-2">
        {verdict && (
          <div className="flex items-center gap-2">
            <Badge variant="outline" className={cn("font-semibold", VERDICT_CLASS[verdict])}>
              {VERDICT_LABEL[verdict] ?? verdict}
            </Badge>
            {summary.verdict_reason && <span className="text-sm text-muted-foreground"><AgentText text={summary.verdict_reason} /></span>}
          </div>
        )}
        <CardTitle className="text-base leading-snug"><AgentText text={summary.headline} /></CardTitle>
      </CardHeader>
      <CardContent className="space-y-3">
        <BulletList title="Key findings" items={summary.key_findings} />
        <BulletList title="Top risks" items={summary.top_risks} />
        {summary.recommended_next_step && (
          <div className="rounded-md border-l-4 border-primary bg-primary/5 p-3">
            <h4 className="text-sm font-semibold">Do this next</h4>
            <p className="text-sm"><AgentText text={summary.recommended_next_step} /></p>
          </div>
        )}
      </CardContent>
    </Card>
  );
}
