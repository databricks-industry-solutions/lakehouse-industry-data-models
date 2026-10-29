import { createFileRoute, Link, useNavigate } from "@tanstack/react-router";
import { Suspense, useState } from "react";
import { ArrowLeft } from "lucide-react";
import { Skeleton } from "@/components/ui/skeleton";
import { Checkbox } from "@/components/ui/checkbox";
import { useQueryClient } from "@tanstack/react-query";
import {
  useGetVibeInputSuspense,
  useUpdateVibeInput,
  type VibeInputOut,
} from "@/lib/api";
import { selector } from "@/lib/selector";
import { ModelTabsShell } from "@/components/model/model-tabs-shell";
import { MODEL_VIEW_TABS, type ModelViewTab } from "@/components/vibe-inputs/model-view";
import { OriginBadge, PriorityIndicator } from "@/components/vibe-inputs/chips";
import { InputMarkdownEditorDialog } from "@/components/vibe-inputs/input-markdown-editor-dialog";
import { anchorFromInput } from "@/components/vibe-inputs/state";
import { feedbackSubjectFromAnchor } from "@/components/feedback/feedback-context";
import { invalidateVibeInputQueries } from "@/components/vibe-inputs/query-keys";

type InputSearch = { from?: "feedback"; tab: ModelViewTab };

export const Route = createFileRoute(
  "/_sidebar/businesses/$businessId/model/$version/$scope/inputs/$inputId",
)({
  // `from` records which surface opened this card so "Back" returns there
  // (default compose surface when absent; "feedback" when opened from the
  // Feedback tab). `tab` is the router-owned active model tab, defaulting to
  // the anchor-focused Diagram; it must be MERGED with `from` on change (see
  // setTab) so switching tabs never drops the back-link destination.
  validateSearch: (search: Record<string, unknown>): InputSearch => ({
    ...(search.from === "feedback" ? { from: "feedback" as const } : {}),
    tab: MODEL_VIEW_TABS.includes(search.tab as ModelViewTab)
      ? (search.tab as ModelViewTab)
      : "diagram",
  }),
  component: InputDetailsRoute,
});

function InputDetailsRoute() {
  const { businessId, version, scope, inputId } = Route.useParams();
  const { from, tab } = Route.useSearch();
  const navigate = useNavigate();
  // MERGE the tab into the existing search so `from` survives a tab switch -
  // replacing with `{ tab }` would silently drop it and break the back link.
  const setTab = (value: ModelViewTab) =>
    navigate({ to: ".", search: (prev) => ({ ...prev, tab: value }), replace: true });
  return (
    <div className="flex h-[calc(100vh-3.5rem)] flex-col">
      <div className="flex items-center gap-3 border-b border-border px-4 py-2">
        {from === "feedback" ? (
          <Link
            to="/businesses/$businessId/model/$version/$scope"
            params={{ businessId, version, scope }}
            search={{ tab: "feedback" }}
            className="inline-flex items-center gap-1 text-sm text-primary hover:underline"
          >
            <ArrowLeft className="h-4 w-4" /> Back to feedback
          </Link>
        ) : (
          <Link
            to="/businesses/$businessId/model/$version/$scope/inputs"
            params={{ businessId, version, scope }}
            className="inline-flex items-center gap-1 text-sm text-primary hover:underline"
          >
            <ArrowLeft className="h-4 w-4" /> Back to inputs
          </Link>
        )}
        <span className="text-sm font-semibold">Vibe Input</span>
        <span className="font-mono text-xs text-muted-foreground">{inputId}</span>
      </div>
      <Suspense fallback={<Skeleton className="m-4 h-[70vh]" />}>
        <DetailsContent
          businessId={businessId}
          version={version}
          scope={scope}
          inputId={inputId}
          tab={tab}
          onTabChange={setTab}
        />
      </Suspense>
    </div>
  );
}

export function DetailsContent({
  businessId,
  version,
  scope,
  inputId,
  tab,
  onTabChange,
}: {
  businessId: string;
  version: string;
  scope: string;
  inputId: string;
  tab: ModelViewTab;
  onTabChange: (tab: ModelViewTab) => void;
}) {
  const { data: input } = useGetVibeInputSuspense({
    params: { business_id: businessId, input_id: inputId },
    ...selector(),
  });

  const focusAnchor = anchorFromInput(input);
  const anchorLabel = input.anchor?.path?.join(" › ") || "Model-wide";

  // This review surface has no domain picker, but its focal diagram can still
  // show a RELATED domain group with a clickable header (diagram-viewer.tsx's
  // onDomainClick). Item 3B deleted DiagramViewer's internal domain-state
  // fallback, so without this callback that click would go inert. Wire it to
  // navigate to the clicked domain's own page instead - hiding the toolbar's
  // own dropdown (showDomainSelect=false) since a free-floating "jump
  // anywhere" picker doesn't belong on a single-input review surface.
  const navigate = useNavigate();
  const handleDomainNavigate = (domain: string | null) => {
    if (!domain) return;
    navigate({
      to: "/businesses/$businessId/model/$version/$scope/$domainName",
      params: { businessId, version, scope, domainName: domain },
      search: { tab: "diagram" },
    });
  };

  return (
    <div className="flex min-h-0 flex-1 flex-col">
      <InstructionMetaBlock
        businessId={businessId}
        input={input}
        anchorLabel={anchorLabel}
      />
      <div className="min-h-0 flex-1 px-4 pb-4">
        {/* Full model tab chrome (Overview / Diagram / Relationships / Ontology
            / Artifacts / Feedback / Statistics), defaulting to an anchor-focused
            Diagram. showLifecycleActions=false: a review surface offers no
            run/install actions, and no versionActions means no delete button.
            The shell owns the model/versions fetches and the column-mode gate. */}
        <ModelTabsShell
          businessId={businessId}
          version={version}
          scope={scope}
          tab={tab}
          onTabChange={onTabChange}
          focusAnchor={focusAnchor}
          feedbackSubject={feedbackSubjectFromAnchor(input.anchor)}
          showLifecycleActions={false}
          onDomainNavigate={handleDomainNavigate}
          showDomainSelect={false}
        />
      </div>
    </div>
  );
}

function InstructionMetaBlock({
  businessId,
  input,
  anchorLabel,
}: {
  businessId: string;
  input: VibeInputOut;
  anchorLabel: string;
}) {
  const queryClient = useQueryClient();
  const update = useUpdateVibeInput();
  const [editorOpen, setEditorOpen] = useState(false);
  const [draft, setDraft] = useState(input.text);

  const commit = () => {
    const text = draft.trim();
    if (text && text !== input.text) {
      update.mutate(
        { params: { business_id: businessId, input_id: input.id }, data: { text } },
        { onSuccess: () => invalidateVibeInputQueries(queryClient, businessId) },
      );
    } else {
      setDraft(input.text);
    }
  };

  return (
    <div className="space-y-3 border-b border-border px-4 py-3">
      <div className="flex flex-wrap items-center gap-x-7 gap-y-2 text-sm">
        <MetaItem label="Anchor">
          <span className="font-mono text-xs">{anchorLabel}</span>
        </MetaItem>
        <MetaItem label="Origin">
          <OriginBadge origin={input.origin} />
        </MetaItem>
        <MetaItem label="Priority">
          <PriorityIndicator priority={input.priority} />
        </MetaItem>
        <MetaItem label="Included next run">
          <span className="inline-flex items-center gap-1.5">
            <Checkbox checked disabled />
            {input.status === "deprecated" ? "Excluded" : "Included"}
          </span>
        </MetaItem>
      </div>
      <div>
        <div className="mb-1 flex items-center justify-between">
          <span className="text-xs font-semibold uppercase tracking-wide text-muted-foreground">
            Instruction
          </span>
          <button
            type="button"
            onClick={() => setEditorOpen(true)}
            className="text-xs text-primary hover:underline"
          >
            Open full editor
          </button>
        </div>
        <textarea
          value={draft}
          onChange={(e) => setDraft(e.target.value)}
          onBlur={commit}
          rows={3}
          className="w-full rounded-md border border-input bg-background p-2 text-sm focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-ring"
        />
        <p className="mt-1 text-xs text-muted-foreground">
          Saved durably to this input. The checkbox on the compose surface controls
          inclusion in the next run.
        </p>
      </div>
      <InputMarkdownEditorDialog
        businessId={businessId}
        input={editorOpen ? input : null}
        open={editorOpen}
        onOpenChange={setEditorOpen}
        anchorLabel={anchorLabel}
      />
    </div>
  );
}

function MetaItem({ label, children }: { label: string; children: React.ReactNode }) {
  return (
    <div className="flex flex-col gap-1">
      <span className="text-[11px] font-semibold uppercase tracking-wide text-muted-foreground">
        {label}
      </span>
      {children}
    </div>
  );
}
