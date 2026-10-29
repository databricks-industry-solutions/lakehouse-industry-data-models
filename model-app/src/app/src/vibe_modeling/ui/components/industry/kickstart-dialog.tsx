import { useState } from "react";
import { useNavigate } from "@tanstack/react-router";
import { useQueryClient } from "@tanstack/react-query";
import { toast } from "sonner";
import {
  ApiError,
  useGetExplorerVersions,
  useKickstartFromIndustry,
} from "@/lib/api";
import { invalidateBusinessLists } from "@/lib/business-cache";
import { apiErrorMessage } from "@/lib/api-error";
import {
  isTransientGatewayError,
  retryOnTransientGateway,
} from "@/lib/retry-transient";
import { reportClientGatewayError } from "@/lib/client-telemetry";
import { Button } from "@/components/ui/button";
import { Checkbox } from "@/components/ui/checkbox";
import { Input } from "@/components/ui/input";
import { Textarea } from "@/components/ui/textarea";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { Skeleton } from "@/components/ui/skeleton";

interface KickstartDialogProps {
  /** The industry's business id (path param ``industry_business_id``). */
  industryBusinessId: string;
  /** Industry display name, used in the dialog title/copy. */
  industryName: string;
  /**
   * The source industry's own description. When blank, ``new_description``
   * has no fallback to land on (the backend rejects blank+blank with 422 -
   * see ``KickstartDescriptionRequired``) so the field becomes required here
   * too, matching the description-required contract on every other
   * Business-write surface.
   */
  industryDescription?: string | null;
  trigger: React.ReactNode;
}

/**
 * Kickstart a new business from an industry's published model version
 * (ADR D-046 / D-048, Story 8). Collects a required ``new_name``, a
 * ``new_description`` and a ``source_version`` (one of the industry's model
 * versions). ``new_description`` is normally optional - it falls back to
 * the source industry's own description - but becomes REQUIRED client-side
 * when the industry itself has no description to fall back on (the backend
 * rejects blank+blank with a 422, ``KickstartDescriptionRequired``). The
 * kickstart is always WHOLE-MODEL - the backend rejects ``whole_model=false``
 * with 400 - so the UI sends ``whole_model: true`` and offers no scope
 * narrowing.
 *
 * On success it navigates to the new business's explorer; the copy continues
 * in the background and ``KickstartProgressBanner`` shows its progress. A 409
 * (``business_name_taken``) surfaces inline on the name field; a 404 (the
 * source industry/version is gone) shows a top-level message.
 */
export function KickstartDialog({
  industryBusinessId,
  industryName,
  industryDescription,
  trigger,
}: KickstartDialogProps) {
  const [open, setOpen] = useState(false);

  return (
    <Dialog open={open} onOpenChange={setOpen}>
      <span onClick={() => setOpen(true)}>{trigger}</span>
      {open && (
        <DialogContent>
          <KickstartForm
            industryBusinessId={industryBusinessId}
            industryName={industryName}
            industryDescription={industryDescription}
            onClose={() => setOpen(false)}
          />
        </DialogContent>
      )}
    </Dialog>
  );
}

function KickstartForm({
  industryBusinessId,
  industryName,
  industryDescription,
  onClose,
}: {
  industryBusinessId: string;
  industryName: string;
  industryDescription?: string | null;
  onClose: () => void;
}) {
  const navigate = useNavigate();
  const queryClient = useQueryClient();
  const kickstart = useKickstartFromIndustry();

  const [name, setName] = useState("");
  const [description, setDescription] = useState("");
  const [sourceVersion, setSourceVersion] = useState<string>("");
  // Default ON: a kickstart inherits the industry's curation (feedback +
  // agent next-vibe backlog). Uncheck for a clean slate.
  const [copyInputs, setCopyInputs] = useState(true);
  const [nameError, setNameError] = useState<string | null>(null);
  const [descriptionError, setDescriptionError] = useState<string | null>(null);
  const [formError, setFormError] = useState<string | null>(null);
  // True while a transient gateway error (502/503/504) is being auto-retried,
  // so the button can show "Retrying…" instead of leaving the user staring at
  // a spinner that briefly clears between attempts.
  const [retrying, setRetrying] = useState(false);

  // The industry has no description to fall back on (an industry seeded
  // from a description-less model.json) - the backend rejects blank+blank
  // with 422 (KickstartDescriptionRequired), so require it here too.
  const descriptionRequired = !(industryDescription ?? "").trim();

  // The source-version picker lists the INDUSTRY's own versions. Mirror
  // business-tree.tsx: useGetExplorerVersions nests rows under ``result.data``.
  const { data: result, isLoading: versionsLoading } = useGetExplorerVersions({
    params: { business_id: industryBusinessId },
  });
  const versions = [...(result?.data ?? [])].sort((a, b) => {
    if (b.version !== a.version) return b.version - a.version;
    return (a.scope || "").localeCompare(b.scope || "");
  });

  const trimmedName = name.trim();
  const trimmedDescription = description.trim();
  const canSubmit =
    trimmedName.length >= 1 &&
    (!descriptionRequired || trimmedDescription.length >= 1) &&
    sourceVersion !== "" &&
    !kickstart.isPending &&
    !retrying;

  const handleSubmit = async () => {
    setNameError(null);
    setDescriptionError(null);
    setFormError(null);
    if (trimmedName.length < 1) {
      setNameError("Name is required.");
      return;
    }
    if (descriptionRequired && trimmedDescription.length < 1) {
      setDescriptionError("Description is required.");
      return;
    }
    if (sourceVersion === "") {
      setFormError("Select a source version.");
      return;
    }
    // A transient gateway error (502/503/504) on the kickstart POST clears on
    // an immediate retry (E-04). Auto-retry it a bounded number of times so a
    // proxy hiccup never dumps a raw "HTTP 502:" on the user. `sawTransient`
    // tracks whether a retry fired, so a 409 that follows one can be read as
    // "the first (502'd) attempt may actually have created the business"
    // rather than a genuine name clash.
    let sawTransient = false;
    try {
      const { data } = await retryOnTransientGateway(
        () =>
          kickstart.mutateAsync({
            params: { industry_business_id: industryBusinessId },
            data: {
              new_name: trimmedName,
              new_description: description.trim() || undefined,
              source_version: Number(sourceVersion),
              whole_model: true,
              copy_inputs: copyInputs,
            },
          }),
        {
          onTransientError: (attempt, err, willRetry) => {
            sawTransient = true;
            if (willRetry) setRetrying(true);
            // Record every 502/503/504 in the app logs (not just the browser),
            // even when a later retry recovers it, so a real recurrence stays
            // diagnosable in `databricks apps logs`.
            reportClientGatewayError({
              status: err.status,
              path: `/api/industry-models/${industryBusinessId}/kickstart`,
              attempt,
              willRetry,
              context: `kickstart industry=${industryBusinessId} name=${JSON.stringify(trimmedName)}`,
            });
          },
        },
      );
      await invalidateBusinessLists(queryClient);
      toast.success("Kickstart started", {
        description: `"${data.business.name}" is being set up from ${industryName}.`,
      });
      onClose();
      navigate({
        to: "/businesses/$businessId/explorer",
        params: { businessId: data.business.id },
      });
    } catch (err) {
      if (err instanceof ApiError) {
        const detail = (err.body as { detail?: unknown } | null)?.detail as
          | { error?: string }
          | string
          | undefined;
        const errorCode =
          detail && typeof detail === "object" ? detail.error : undefined;
        if (err.status === 409 || errorCode === "business_name_taken") {
          if (sawTransient) {
            // The kickstart create is unique-name-guarded, so this retry did
            // not double-create; the original attempt likely committed before
            // the transient error. Point the user at their list instead of a
            // misleading "name already exists" on the field.
            setFormError(
              "A network hiccup interrupted the response, but this kickstart " +
                "may already have been created. Check your businesses list " +
                "before trying again.",
            );
          } else {
            setNameError("A business with this name already exists.");
          }
          return;
        }
        if (err.status === 404) {
          setFormError("That industry version no longer exists.");
          return;
        }
        if (isTransientGatewayError(err)) {
          // Retries exhausted and still transient — friendly message, never
          // the raw "HTTP 502: Bad Gateway".
          setFormError(
            "The server was temporarily unavailable. Please try again in a " +
              "moment.",
          );
          return;
        }
      }
      setFormError(apiErrorMessage(err, "Failed to kickstart business"));
    } finally {
      setRetrying(false);
    }
  };

  return (
    <>
      <DialogHeader>
        <DialogTitle>Kickstart a business from {industryName}</DialogTitle>
        <DialogDescription>
          Creates a new business seeded from a published version of this
          industry's whole model. You can vibe and refine it independently
          afterwards.
        </DialogDescription>
      </DialogHeader>

      <div className="space-y-4 py-2">
        <div className="space-y-1.5">
          <label htmlFor="kickstart-name" className="text-sm font-medium">
            Business name
          </label>
          <Input
            id="kickstart-name"
            value={name}
            onChange={(e) => {
              setName(e.target.value);
              if (nameError) setNameError(null);
            }}
            placeholder="e.g. Acme Retail"
            aria-invalid={nameError ? true : undefined}
          />
          {nameError && (
            <p role="alert" className="text-sm text-destructive">
              {nameError}
            </p>
          )}
        </div>

        <div className="space-y-1.5">
          <label htmlFor="kickstart-description" className="text-sm font-medium">
            Description{" "}
            <span className="text-muted-foreground font-normal">
              {descriptionRequired ? "(required)" : "(optional)"}
            </span>
          </label>
          <Textarea
            id="kickstart-description"
            data-testid="kickstart-description"
            value={description}
            onChange={(e) => {
              setDescription(e.target.value);
              if (descriptionError) setDescriptionError(null);
            }}
            placeholder="What is this business?"
            aria-invalid={descriptionError ? true : undefined}
          />
          {descriptionRequired && (
            <p
              className="text-xs text-muted-foreground"
              data-testid="kickstart-description-helper"
            >
              Required - {industryName} has no description to fall back on;
              add a short summary so the kickstarted business has one.
            </p>
          )}
          {descriptionError && (
            <p role="alert" className="text-sm text-destructive">
              {descriptionError}
            </p>
          )}
        </div>

        <div className="space-y-1.5">
          <label htmlFor="kickstart-version" className="text-sm font-medium">
            Source version
          </label>
          {versionsLoading ? (
            <Skeleton className="h-8 w-full" />
          ) : versions.length === 0 ? (
            <p className="text-sm text-muted-foreground">
              This industry has no model versions to kickstart from yet.
            </p>
          ) : (
            <Select value={sourceVersion} onValueChange={setSourceVersion}>
              <SelectTrigger id="kickstart-version">
                <SelectValue placeholder="Select a version..." />
              </SelectTrigger>
              <SelectContent>
                {versions.map((v) => (
                  <SelectItem key={v.id} value={String(v.version)}>
                    v{v.version}
                    {v.scope ? ` (${v.scope.toUpperCase()})` : ""}
                    {v.is_base ? " · Base" : ""}
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>
          )}
        </div>

        <div className="flex items-start gap-2">
          <Checkbox
            id="kickstart-copy-inputs"
            checked={copyInputs}
            onCheckedChange={(v) => setCopyInputs(v === true)}
            className="mt-0.5"
          />
          <label
            htmlFor="kickstart-copy-inputs"
            className="text-sm leading-snug"
          >
            Bring this industry's inputs and feedback
            <span className="block text-muted-foreground font-normal">
              Carries the industry's shaping feedback and open backlog,
              re-anchored to your new model. Uncheck for a clean slate.
            </span>
          </label>
        </div>

        {formError && (
          <p role="alert" className="text-sm text-destructive">
            {formError}
          </p>
        )}
      </div>

      <DialogFooter>
        <Button
          variant="outline"
          onClick={onClose}
          disabled={kickstart.isPending || retrying}
        >
          Cancel
        </Button>
        <Button onClick={handleSubmit} disabled={!canSubmit}>
          {retrying
            ? "Retrying…"
            : kickstart.isPending
              ? "Kickstarting…"
              : "Kickstart"}
        </Button>
      </DialogFooter>
    </>
  );
}
