import { useMemo, useState } from "react";
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { useNavigate } from "@tanstack/react-router";
import {
  CheckCircle2, AlertTriangle, Loader2, X, FolderOpen, Plus, ChevronsUpDown, Check,
} from "lucide-react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Textarea } from "@/components/ui/textarea";
import { Badge } from "@/components/ui/badge";
import { Checkbox } from "@/components/ui/checkbox";
import { MarkdownEditor } from "@/components/ui/markdown-editor";
import {
  Command,
  CommandEmpty,
  CommandGroup,
  CommandInput,
  CommandItem,
  CommandList,
} from "@/components/ui/command";
import {
  Popover,
  PopoverContent,
  PopoverTrigger,
} from "@/components/ui/popover";
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from "@/components/ui/dialog";
import { VolumePicker } from "@/components/import/volume-picker";
import { ImportPreviewCard } from "@/components/import/import-dialog";
import {
  ImportScopeChoice,
  importScope,
  importScopeBody,
  initialScopeChoice,
  type ImportScope,
} from "@/components/import/import-scope-choice";
import {
  analyzeImportRoot,
  createBusinessAndExecuteImport,
  getImportPreview,
  getImportPreviewKey,
  listIndustriesKey,
  useListIndustries,
  type ImportAnalyzeOut,
  type ImportPreviewOut,
  type IndustryOut,
} from "@/lib/api";
import { invalidateBusinessLists } from "@/lib/business-cache";
import { apiErrorMessage, parse409 } from "@/lib/api-error";
import { notifyConfigMissing, notifyWarnings } from "@/lib/notify";
import { industrySlug, matchingIndustries, pickIndustry } from "@/lib/industry";

interface Props {
  trigger: React.ReactNode;
}

const SUMMARY_MAX_LENGTH = 2000;

/** The 409 body when the alignment would share its slug with catalog industries. */
interface IndustryAmbiguousBody {
  error: "industry_ambiguous";
  industries: { id: string; name: string }[];
  message: string;
}

/** Shape of the 409 conflict body the backend returns on a name clash. */
interface BusinessAlreadyExistsBody {
  error: "business_already_exists";
  business_id: string;
  business_name: string;
  message: string;
}

function parseConflict(err: unknown): BusinessAlreadyExistsBody | null {
  return parse409<BusinessAlreadyExistsBody>(err, "business_already_exists");
}

/**
 * volume-picker → analyze → digest confirmation → create-business-and-execute.
 * On success, navigate to the new business's explorer. A name clash (409)
 * surfaces inline next to the Business name field and keeps the dialog state
 * intact so the user can rename and retry without re-analyzing.
 */
export function ImportNewBusinessDialog({ trigger }: Props) {
  const [open, setOpen] = useState(false);
  const [pickerOpen, setPickerOpen] = useState(false);
  const [volumePath, setVolumePath] = useState("");
  const [analysis, setAnalysis] = useState<ImportAnalyzeOut | null>(null);
  const [businessName, setBusinessName] = useState("");
  const [industryAlignment, setIndustryAlignment] = useState("");
  const [description, setDescription] = useState("");
  const [businessVibes, setBusinessVibes] = useState("");
  const [error, setError] = useState<string | null>(null);
  const [nameConflict, setNameConflict] = useState<string | null>(null);
  const [industryOpen, setIndustryOpen] = useState(false);
  const [addIndustry, setAddIndustry] = useState(false);
  // The industry the backend resolved or the user picked from the list; typing
  // clears it, so the typed text resolves again.
  const [selectedIndustryId, setSelectedIndustryId] = useState<string | null>(null);
  const [chosenScope, setChosenScope] = useState<ImportScope | null>(null);
  const navigate = useNavigate();
  const queryClient = useQueryClient();

  // Preview query — same machinery as the import-into-existing dialog
  // (``ImportModelDialog``). Walks the Volume folder and reports
  // model.json presence + which companion / next-vibes sidecars are
  // present vs. missing, so the user sees what the import will (and
  // won't) pull in BEFORE committing to the long create+import call.
  const previewEnabled = volumePath.startsWith("/Volumes/");
  const previewQuery = useQuery({
    queryKey: getImportPreviewKey({ volume_path: volumePath }),
    queryFn: () => getImportPreview({ volume_path: volumePath }),
    enabled: previewEnabled,
    retry: false,
    staleTime: 30_000,
  });
  const preview: ImportPreviewOut | undefined = previewQuery.data?.data;

  // Non-suspense so the dialog itself never suspends; only fetch once the
  // dialog is open. Empty list is a fine fallback (free-typing still works).
  const { data: industriesResp } = useListIndustries({
    query: { enabled: open },
  });
  const activeIndustries: IndustryOut[] = useMemo(
    () => (industriesResp?.data ?? []).filter((i) => i.is_active),
    [industriesResp],
  );
  // The picked industry, else the backend's rule (``industry_resolve``) over
  // the typed alignment. Sending the id keeps a pick whose name is ambiguous.
  const matchedIndustry =
    activeIndustries.find((i) => i.id === selectedIndustryId) ??
    pickIndustry(activeIndustries, industryAlignment);
  // Several active industries share the alignment's slug: the user picks one;
  // adding another would match nothing either.
  const ambiguousIndustries = matchedIndustry
    ? []
    : matchingIndustries(activeIndustries, industryAlignment);
  const canAddIndustry =
    !matchedIndustry && ambiguousIndustries.length === 0 && industrySlug(industryAlignment) !== "";
  const pickIndustryFromList = (ind: { id: string; name: string }) => {
    setIndustryAlignment(ind.name);
    setSelectedIndustryId(ind.id);
    setAddIndustry(false);
    setError(null);
  };
  const typeIndustry = (value: string) => {
    setIndustryAlignment(value);
    setSelectedIndustryId(null);
    if (industrySlug(value) === "") setAddIndustry(false);
  };

  const analyzeMutation = useMutation({
    mutationFn: () => analyzeImportRoot({ volume_path: volumePath }),
    onSuccess: (response) => {
      const out = response.data;
      setAnalysis(out);
      setError(null);
      setNameConflict(null);
      setChosenScope(initialScopeChoice(out));
      const digest = out.business_digest;
      setBusinessName(digest?.business_name ?? "");
      // The backend resolved the alignment; show its catalog name when the
      // list has it, the raw alignment otherwise.
      const resolved = activeIndustries.find((i) => i.id === digest?.industry_id);
      setIndustryAlignment(resolved?.name ?? digest?.industry_alignment ?? "");
      setSelectedIndustryId(digest?.industry_id ?? null);
      setAddIndustry(false);
      setDescription(digest?.description ?? "");
      setBusinessVibes(digest?.business_vibes ?? "");
    },
    onError: (err: unknown) => {
      setError(apiErrorMessage(err, "Failed to analyze"));
      setAnalysis(null);
    },
  });

  const createMutation = useMutation({
    mutationFn: () =>
      createBusinessAndExecuteImport({
        volume_path: volumePath,
        business_name_override: businessName || null,
        industry_alignment_override: industryAlignment,
        industry_id: matchedIndustry?.id ?? null,
        create_industry: addIndustry && canAddIndustry,
        description_override: description,
        business_vibes_override: businessVibes,
        scope: importScopeBody(analysis, chosenScope),
      }),
    onSuccess: (response) => {
      notifyWarnings("Imported with warnings", response.data.warnings);
      invalidateBusinessLists(queryClient);
      reset();
      setOpen(false);
      navigate({
        to: "/businesses/$businessId/explorer",
        params: { businessId: response.data.business_id },
      });
    },
    onError: (err: unknown) => {
      const conflict = parseConflict(err);
      if (conflict) {
        // Keep the dialog state intact; show an inline error by the name
        // field so the user can rename and retry without re-analyzing.
        setNameConflict(
          conflict.message ||
            `A business named "${conflict.business_name}" already exists — rename it or use the per-business import.`,
        );
        return;
      }
      // Config-missing 422 -> the shared config_missing renderer (Settings
      // deep-links), same as the download + per-business import dialogs.
      if (notifyConfigMissing(err)) {
        return;
      }
      const ambiguous = parse409<IndustryAmbiguousBody>(err, "industry_ambiguous");
      if (ambiguous) {
        // The catalog changed since the list loaded: refresh it so the
        // candidates show up to pick from.
        setAddIndustry(false);
        setError(ambiguous.message);
        queryClient.invalidateQueries({ queryKey: listIndustriesKey() });
        return;
      }
      setError(apiErrorMessage(err, "Create + import failed"));
    },
  });

  const reset = () => {
    setVolumePath("");
    setAnalysis(null);
    setBusinessName("");
    setIndustryAlignment("");
    setSelectedIndustryId(null);
    setAddIndustry(false);
    setDescription("");
    setBusinessVibes("");
    setError(null);
    setNameConflict(null);
    setChosenScope(null);
  };

  const digest = analysis?.business_digest;

  const industryMatches = useMemo(() => {
    const q = industryAlignment.trim().toLowerCase();
    if (!q) return activeIndustries;
    return activeIndustries.filter(
      (i) =>
        i === matchedIndustry ||
        ambiguousIndustries.includes(i) ||
        i.name.toLowerCase().includes(q),
    );
  }, [industryAlignment, activeIndustries, matchedIndustry, ambiguousIndustries]);

  return (
    <Dialog
      open={open}
      onOpenChange={(v) => {
        setOpen(v);
        if (!v) reset();
      }}
    >
      <DialogTrigger asChild>{trigger}</DialogTrigger>
      <DialogContent className="max-w-3xl max-h-[90vh] flex flex-col">
        <DialogHeader>
          <DialogTitle>Import a business</DialogTitle>
        </DialogHeader>

        <div className="space-y-4 overflow-y-auto pr-1 flex-1 min-h-0">
          <div className="space-y-1.5">
            <label className="text-sm font-medium">Volume path to model.json</label>
            <div className="flex gap-2">
              <Input
                value={volumePath}
                onChange={(e) => setVolumePath(e.target.value)}
                placeholder="/Volumes/catalog/schema/vibes/model.json"
                disabled={analyzeMutation.isPending || createMutation.isPending}
              />
              <Button
                type="button"
                variant="outline"
                onClick={() => setPickerOpen(true)}
                disabled={analyzeMutation.isPending || createMutation.isPending}
              >
                <FolderOpen className="h-4 w-4 mr-1" />
                Browse Volumes…
              </Button>
            </div>
          </div>

          <VolumePicker
            open={pickerOpen}
            onOpenChange={setPickerOpen}
            onSelect={(path) => {
              setVolumePath(path);
              setAnalysis(null);
              setError(null);
            }}
          />

          {preview && !analysis && <ImportPreviewCard preview={preview} />}

          {!analysis && !error && (
            <div className="flex justify-end">
              <Button
                onClick={() => analyzeMutation.mutate()}
                disabled={
                  !volumePath.startsWith("/Volumes/") ||
                  analyzeMutation.isPending ||
                  (preview != null && !preview.model_json_found)
                }
              >
                {analyzeMutation.isPending && <Loader2 className="h-4 w-4 mr-2 animate-spin" />}
                Analyze
              </Button>
            </div>
          )}

          {error && (
            <div className="rounded-md border border-destructive/50 bg-destructive/10 p-3 text-sm space-y-2">
              <div className="flex items-start gap-2">
                <AlertTriangle className="h-4 w-4 mt-0.5 text-destructive shrink-0" />
                <p className="text-destructive">{error}</p>
              </div>
              <Button variant="outline" size="sm" onClick={reset}>Try again</Button>
            </div>
          )}

          {analysis && analysis.valid && !digest && (
            <div className="rounded-md border border-destructive/50 bg-destructive/10 p-3 text-sm">
              <p className="text-destructive">
                model.json doesn't carry a business name. Create the
                business manually first and use "Import model.json"
                from the business page.
              </p>
            </div>
          )}

          {analysis && analysis.valid && digest && (
            <div className="rounded-md border border-green-500/30 bg-green-500/5 p-3 space-y-3">
              <div className="flex items-start gap-2">
                <CheckCircle2 className="h-4 w-4 mt-0.5 text-green-600 dark:text-green-400 shrink-0" />
                <p className="text-sm">{analysis.message}</p>
              </div>

              <div className="flex flex-wrap items-center gap-1.5">
                <Badge variant="secondary" className="text-[10px]">
                  {analysis.domain_count} domains
                </Badge>
                <Badge variant="secondary" className="text-[10px]">
                  {analysis.product_count} products
                </Badge>
                <Badge variant="secondary" className="text-[10px]">
                  {analysis.attribute_count} attributes
                </Badge>
                <Badge variant="secondary" className="text-[10px]">
                  {analysis.fk_count} FKs
                </Badge>
                {digest.agent_version && (
                  <Badge
                    variant="outline"
                    className="text-[10px]"
                    data-testid="agent-version-badge"
                  >
                    agent v{digest.agent_version}
                  </Badge>
                )}
              </div>

              <div className="space-y-3 border-t border-border pt-3">
                <p className="text-xs font-medium">Business identity</p>

                <div className="space-y-1.5">
                  <label className="text-xs">Business name *</label>
                  <Input
                    value={businessName}
                    onChange={(e) => {
                      setBusinessName(e.target.value);
                      if (nameConflict) setNameConflict(null);
                    }}
                    placeholder="Business name"
                    aria-invalid={nameConflict ? true : undefined}
                    className={nameConflict ? "border-destructive" : undefined}
                  />
                  {nameConflict && (
                    <p
                      data-testid="business-name-conflict"
                      className="text-[10px] text-destructive"
                    >
                      {nameConflict}
                    </p>
                  )}
                </div>

                <div className="space-y-1.5">
                  <label className="text-xs">Industry *</label>
                  <Popover open={industryOpen} onOpenChange={setIndustryOpen}>
                    <PopoverTrigger asChild>
                      <Button
                        type="button"
                        variant="outline"
                        role="combobox"
                        aria-expanded={industryOpen}
                        className="w-full justify-between font-normal"
                      >
                        <span className={industryAlignment ? "" : "text-muted-foreground"}>
                          {industryAlignment || "Select or type an industry…"}
                        </span>
                        <ChevronsUpDown className="h-4 w-4 opacity-50 shrink-0" />
                      </Button>
                    </PopoverTrigger>
                    <PopoverContent className="w-[--radix-popover-trigger-width] p-0" align="start">
                      <Command shouldFilter={false}>
                        <CommandInput
                          placeholder="Search or type an industry…"
                          value={industryAlignment}
                          onValueChange={typeIndustry}
                        />
                        <CommandList>
                          {industryMatches.length === 0 && (
                            <CommandEmpty>
                              No catalog industry matches "{industryAlignment}".
                            </CommandEmpty>
                          )}
                          {industryMatches.length > 0 && (
                            <CommandGroup>
                              {industryMatches.map((ind) => (
                                <CommandItem
                                  key={ind.id}
                                  value={ind.name}
                                  onSelect={() => {
                                    pickIndustryFromList(ind);
                                    setIndustryOpen(false);
                                  }}
                                >
                                  <Check
                                    className={`mr-2 h-4 w-4 ${
                                      matchedIndustry?.id === ind.id
                                        ? "opacity-100"
                                        : "opacity-0"
                                    }`}
                                  />
                                  {ind.name}
                                </CommandItem>
                              ))}
                            </CommandGroup>
                          )}
                        </CommandList>
                      </Command>
                    </PopoverContent>
                  </Popover>
                  {ambiguousIndustries.length > 0 && (
                    <div data-testid="industry-ambiguous" className="space-y-1">
                      <p className="text-xs text-muted-foreground">
                        "{industryAlignment}" matches {ambiguousIndustries.length} catalog
                        industries. Pick the one this business belongs to:
                      </p>
                      <div className="flex flex-wrap gap-1.5">
                        {ambiguousIndustries.map((ind) => (
                          <Button
                            key={ind.id}
                            type="button"
                            variant="outline"
                            size="sm"
                            className="h-7 text-xs"
                            onClick={() => pickIndustryFromList(ind)}
                          >
                            {ind.name}
                          </Button>
                        ))}
                      </div>
                    </div>
                  )}
                  {canAddIndustry && (
                    <div data-testid="industry-not-in-catalog" className="space-y-1">
                      <p className="text-xs text-muted-foreground">
                        "{industryAlignment}" is not in the industry catalog. The
                        business is created without an industry unless you add it.
                      </p>
                      <label className="flex items-center gap-2 text-xs">
                        <Checkbox
                          data-testid="add-industry-checkbox"
                          checked={addIndustry}
                          onCheckedChange={(v) => setAddIndustry(v === true)}
                        />
                        Add "{industryAlignment}" to the industry catalog
                      </label>
                    </div>
                  )}
                </div>

                <div className="space-y-1.5">
                  <label className="text-xs flex items-center justify-between">
                    <span>Business summary *</span>
                    <span className={`text-[10px] ${description.length > SUMMARY_MAX_LENGTH ? "text-destructive" : "text-muted-foreground"}`}>
                      {description.length} chars{description.length > SUMMARY_MAX_LENGTH ? ` — exceeds ${SUMMARY_MAX_LENGTH}-char cap` : ""}
                    </span>
                  </label>
                  <Textarea
                    value={description}
                    onChange={(e) => setDescription(e.target.value)}
                    placeholder="Short summary (2000 chars max recommended)"
                    rows={6}
                    className="max-h-[200px] resize-y"
                  />
                </div>

                <div className="space-y-1.5">
                  <label className="text-xs">Detailed description</label>
                  <MarkdownEditor
                    value={businessVibes}
                    onChange={setBusinessVibes}
                    placeholder="Process, key entities, differentiators, critical business components… (Markdown, any length)"
                    rows={12}
                    textareaTestId="business-vibes"
                  />
                  <p className="text-[10px] text-muted-foreground">
                    Rebuilt from the model.json's business context — please
                    review.
                  </p>
                </div>

                <p className="text-[10px] text-muted-foreground">* required</p>
              </div>

              <ImportScopeChoice
                analysis={analysis}
                chosen={chosenScope}
                onChoose={setChosenScope}
                disabled={createMutation.isPending}
              />

              {preview && <ImportPreviewCard preview={preview} compact />}

              <div className="flex justify-end gap-2 pt-1">
                <Button
                  variant="outline"
                  size="sm"
                  onClick={reset}
                  disabled={createMutation.isPending}
                >
                  Cancel
                </Button>
                <Button
                  size="sm"
                  onClick={() => createMutation.mutate()}
                  disabled={
                    !businessName.trim() ||
                    !description.trim() ||
                    importScope(analysis, chosenScope) == null ||
                    createMutation.isPending
                  }
                >
                  {createMutation.isPending ? (
                    <>
                      <Loader2 className="h-4 w-4 mr-2 animate-spin" />
                      Creating business &amp; importing…
                    </>
                  ) : (
                    <>
                      <Plus className="h-3 w-3 mr-1" />
                      Create business and import
                    </>
                  )}
                </Button>
              </div>
              {createMutation.isPending && (
                <p className="text-[10px] text-muted-foreground text-right">
                  Importing domains, products &amp; attributes and indexing
                  artifacts — this can take a minute on large models.
                </p>
              )}
            </div>
          )}

          {analysis && !analysis.valid && (
            <div className="rounded-md border border-destructive/50 bg-destructive/10 p-3 text-sm space-y-2">
              <div className="flex items-start gap-2">
                <X className="h-4 w-4 mt-0.5 text-destructive shrink-0" />
                <p className="text-destructive">{analysis.message}</p>
              </div>
              <Button variant="outline" size="sm" onClick={reset}>Try another file</Button>
            </div>
          )}
        </div>
      </DialogContent>
    </Dialog>
  );
}
