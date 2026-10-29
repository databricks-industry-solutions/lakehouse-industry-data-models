import { useState } from "react";
import { useQueryClient } from "@tanstack/react-query";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Separator } from "@/components/ui/separator";
import { Textarea } from "@/components/ui/textarea";
import {
  answerAssessmentDecision,
  clearAssessmentDecisionAnswer,
  getAssessmentResultsKey,
  type PendingDecisionOut,
} from "@/lib/api";
import { decisionAnchor, decisionLabel } from "@/lib/assessment";
import { formatDateTime } from "@/lib/date";
import { notifyError } from "@/lib/notify";
import { AgentText, plainAgentText } from "./agent-text";

const KIND_LABEL: Record<string, string> = { structure: "Structure", source: "Source", scope: "Scope" };

interface DecisionListProps {
  decisions: PendingDecisionOut[];
  domainRunId: string;
  vibeForDecision?: Record<string, string>;
  onJumpToRef?: (ref: string) => void;
}

/** Pending decisions grouped by kind and answer status, with optional linking to vibes. */
export function DecisionList({
  decisions,
  domainRunId,
  vibeForDecision = {},
  onJumpToRef,
}: DecisionListProps) {
  // Group all decisions (open and answered) into sections by kind
  const structure = decisions.filter((d) => d.kind === "structure");
  const source = decisions.filter((d) => d.kind === "source");
  const scope = decisions.filter((d) => d.kind === "scope");
  const other = decisions.filter((d) => !d.kind || !["structure", "source", "scope"].includes(d.kind));

  const sections = [
    {
      title: "Answered by running the next vibes",
      explainer: "These change the model. Accepting the matching next vibe answers them: review them in Next vibes, run the vibe, then re-assess.",
      items: structure,
      show: structure.length > 0,
    },
    {
      title: "Answer at the build gate",
      explainer: "These don't change the model, so iterating won't resolve them. Answer them once the re-assessment shows every entity Structure: Sound.",
      items: source,
      show: source.length > 0,
    },
    {
      title: "For the owning domain",
      explainer: "Cross-domain ownership questions. They don't hold up iterating the model.",
      items: scope,
      show: scope.length > 0,
    },
    {
      title: "Other",
      explainer: "",
      items: other,
      show: other.length > 0,
    },
  ];

  return (
    <div className="space-y-6">
      {sections.map(
        (section) =>
          section.show && (
            <div key={section.title} className="space-y-3">
              <div>
                <h3 className="font-semibold">{section.title}</h3>
                {section.explainer && <p className="text-sm text-muted-foreground">{section.explainer}</p>}
              </div>
              <div className="space-y-3">
                {section.items.map((d) => (
                  <DecisionCard
                    key={d.id}
                    decision={d}
                    domainRunId={domainRunId}
                    vibeRef={vibeForDecision[decisionLabel(d.ordinal ?? 0)]}
                    onJumpToRef={onJumpToRef}
                  />
                ))}
              </div>
            </div>
          ),
      )}
    </div>
  );
}

/**
 * One pending decision: context, option comparison, recommendation, then the answer controls
 * (pick an option and/or write free text, save or clear). The recommended option is preselected
 * only while the decision is unanswered. Old runs without context/pros/cons render the plain layout.
 * If linked to a vibe, shows "Resolved by Vibe n" with a jump button.
 */
export function DecisionCard({
  decision,
  domainRunId,
  vibeRef,
  onJumpToRef,
}: {
  decision: PendingDecisionOut;
  domainRunId: string;
  vibeRef?: string;
  onJumpToRef?: (ref: string) => void;
}) {
  const queryClient = useQueryClient();
  const [optionId, setOptionId] = useState(
    decision.answer_option_id ??
      (decision.answer_status === "answered" ? "" : (decision.options.find((o) => o.recommended)?.id ?? "")),
  );
  const [text, setText] = useState(decision.answer_text);
  const [pending, setPending] = useState(false);
  const answered = decision.answer_status === "answered";
  const rich = decision.options.some((o) => (o.pros?.length ?? 0) > 0 || (o.cons?.length ?? 0) > 0 || o.impact);
  const recommended = decision.options.find((o) => o.recommended);
  const label = typeof decision.ordinal === "number" ? decisionLabel(decision.ordinal) : "";

  const refresh = () =>
    queryClient.invalidateQueries({ queryKey: getAssessmentResultsKey({ domain_run_id: domainRunId }) });

  const save = async () => {
    setPending(true);
    try {
      await answerAssessmentDecision({ decision_id: decision.id }, { option_id: optionId || null, text });
      await refresh();
    } catch (err) {
      notifyError(err, { fallback: "Couldn't save the answer" });
    } finally {
      setPending(false);
    }
  };
  const clear = async () => {
    setPending(true);
    try {
      await clearAssessmentDecisionAnswer({ decision_id: decision.id });
      setOptionId("");
      setText("");
      await refresh();
    } catch (err) {
      notifyError(err, { fallback: "Couldn't clear the answer" });
    } finally {
      setPending(false);
    }
  };

  const radio = (o: PendingDecisionOut["options"][number]) => (
    <input
      type="radio"
      name={`decision-${decision.id}`}
      value={o.id}
      aria-label={plainAgentText(o.label)}
      checked={optionId === o.id}
      onChange={() => setOptionId(o.id)}
    />
  );

  return (
    <Card id={label ? decisionAnchor(label) : undefined} className="scroll-mt-4">
      <CardHeader className="space-y-1">
        <div className="flex flex-wrap items-center gap-2 text-xs text-muted-foreground">
          {label && <span className="font-mono font-semibold">{label}</span>}
          {decision.kind && <Badge variant="outline">{KIND_LABEL[decision.kind] ?? decision.kind}</Badge>}
          {decision.blocks_build && <Badge variant="destructive">Blocks build</Badge>}
          {vibeRef && (
            <button
              type="button"
              className="text-xs font-medium text-primary hover:underline"
              aria-label={`Go to ${vibeRef}`}
              onClick={(ev) => {
                ev.stopPropagation();
                onJumpToRef?.(vibeRef);
              }}
            >
              Resolved by {vibeRef}
            </button>
          )}
          <span>{decision.gate}</span>
          {decision.entity && <span>· {decision.entity}</span>}
        </div>
        <CardTitle className="text-base leading-snug">
          <h3><AgentText text={decision.question} /></h3>
        </CardTitle>
      </CardHeader>
      <CardContent className="space-y-3 text-sm">
        {decision.context && (
          <div>
            <h4 className="text-xs font-semibold uppercase text-muted-foreground">Context</h4>
            <p><AgentText text={decision.context} /></p>
          </div>
        )}
        {decision.why_it_matters && (
          <div>
            <h4 className="text-xs font-semibold uppercase text-muted-foreground">Why it matters</h4>
            <p><AgentText text={decision.why_it_matters} /></p>
          </div>
        )}
        {rich ? (
          <div className="grid gap-3 md:grid-cols-[repeat(auto-fit,minmax(14rem,1fr))]" role="radiogroup" aria-label={plainAgentText(decision.question)}>
            {decision.options.map((o) => (
              <div
                key={o.id}
                data-testid={`option-${o.id}`}
                className={`min-w-0 break-words space-y-2 rounded-md border p-3 ${optionId === o.id ? "border-primary" : ""}`}
              >
                <label className="flex items-center gap-2 font-medium">
                  {radio(o)}
                  <span><AgentText text={o.label} /></span>
                  {o.recommended && <Badge variant="secondary">Recommended</Badge>}
                </label>
                {(o.pros?.length ?? 0) > 0 && (
                  <ul className="space-y-0.5">
                    {(o.pros ?? []).map((p, i) => (
                      <li key={i} className="flex gap-1.5">
                        <span aria-hidden className="text-green-600">✓</span>
                        <span><AgentText text={p} /></span>
                      </li>
                    ))}
                  </ul>
                )}
                {(o.cons?.length ?? 0) > 0 && (
                  <ul className="space-y-0.5">
                    {(o.cons ?? []).map((c, i) => (
                      <li key={i} className="flex gap-1.5">
                        <span aria-hidden className="text-red-600">✗</span>
                        <span><AgentText text={c} /></span>
                      </li>
                    ))}
                  </ul>
                )}
                {o.impact && <p className="text-xs text-muted-foreground"><AgentText text={o.impact} /></p>}
              </div>
            ))}
          </div>
        ) : (
          <div className="space-y-1" role="radiogroup" aria-label={plainAgentText(decision.question)}>
            {decision.options.map((o) => (
              <label key={o.id} className="flex items-center gap-2">
                {radio(o)}
                <AgentText text={o.label} />
              </label>
            ))}
          </div>
        )}
        {recommended && (
          <p className="font-medium">
            Recommended: <AgentText text={recommended.label} />
            {decision.recommendation_rationale && (
              <>
                {" — "}
                <AgentText text={decision.recommendation_rationale} />
              </>
            )}
          </p>
        )}
        {decision.default_taken && (
          <p className="text-muted-foreground">Default the run took: <AgentText text={decision.default_taken} /></p>
        )}
        {decision.evidence && (
          <p className="rounded-md bg-muted p-2 text-xs text-muted-foreground">Evidence: <AgentText text={decision.evidence} /></p>
        )}
        {(decision.affected?.length ?? 0) > 0 && (
          <div className="flex flex-wrap gap-1">
            {(decision.affected ?? []).map((a, i) => (
              <Badge key={i} variant="outline" className="font-mono text-xs">
                {a.column ? `${a.entity}.${a.column}` : a.entity}
              </Badge>
            ))}
          </div>
        )}
        <Separator />
        <Textarea
          value={text}
          onChange={(e) => setText(e.target.value)}
          placeholder="Add a note or write your own answer"
          aria-label="Answer text"
        />
        <div className="flex items-center gap-2">
          <Button size="sm" onClick={save} disabled={pending || (!optionId && !text.trim())}>
            Save
          </Button>
          {answered && (
            <>
              <Button size="sm" variant="outline" onClick={clear} disabled={pending}>
                Clear
              </Button>
              <span className="text-xs text-muted-foreground">
                Answered by {decision.answered_by}
                {decision.answered_at ? ` · ${formatDateTime(decision.answered_at)}` : ""}
              </span>
            </>
          )}
        </div>
      </CardContent>
    </Card>
  );
}
