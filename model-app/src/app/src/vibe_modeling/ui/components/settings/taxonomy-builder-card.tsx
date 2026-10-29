import { useState } from "react";
import { useQueryClient } from "@tanstack/react-query";
import { FlaskConical, RotateCcw, Save, X } from "lucide-react";
import {
  getTaxonomyConfigKey,
  useListTaxonomyModelServices,
  useTestTaxonomyModelService,
  useUpdateTaxonomyConfig,
  type TaxonomyCheckOut,
  type TaxonomyConfigOut,
} from "@/lib/api";
import { apiErrorMessage } from "@/lib/api-error";
import { formatDateTime } from "@/lib/date";
import { Button } from "@/components/ui/button";
import { FreeTextCombobox } from "@/components/ui/free-text-combobox";
import { Input } from "@/components/ui/input";
import { SavedNotice, SaveErrorBox, StatusLine, type StatusTone } from "@/components/settings/status-line";

export const MIN_TAXONOMY_CONCURRENCY = 1;
export const MAX_TAXONOMY_CONCURRENCY = 16;

const CHECK_TONE: Record<TaxonomyCheckOut["status"], StatusTone> = {
  ok: "ok",
  busy: "warn",
  denied: "error",
  not_found: "error",
  error: "error",
};

const CHECK_LABEL: Record<TaxonomyCheckOut["status"], string> = {
  ok: "Working",
  busy: "Busy",
  denied: "Access denied",
  not_found: "Not found",
  error: "Test call failed",
};

/** The last test call's result for the stored model service. */
export function TaxonomyCheckLine({ check }: { check: TaxonomyCheckOut }) {
  return (
    <StatusLine tone={CHECK_TONE[check.status]} testId="taxonomy-last-check">
      <span className="font-medium">{CHECK_LABEL[check.status]}:</span> {check.message}{" "}
      <span className="text-muted-foreground">({formatDateTime(check.checked_at)})</span>
    </StatusLine>
  );
}

/**
 * The Domain Taxonomy Builder's settings, inside its card in Settings →
 * Platform, Optional features (`optional-features.tsx`, rendered only when
 * the feature is installed). Every save of a non-empty service runs a test
 * call as the app's service principal on the server; a refusal comes back as
 * a 400 `model_service_refused` whose message is shown inline and nothing is
 * saved.
 */
export function TaxonomyBuilderForm({ config }: { config: TaxonomyConfigOut }) {
  const queryClient = useQueryClient();
  const services = useListTaxonomyModelServices({
    params: {},
    query: { retry: false, staleTime: 60_000 },
  });
  const { mutateAsync: save } = useUpdateTaxonomyConfig();
  const { mutateAsync: runTest } = useTestTaxonomyModelService();

  const [service, setService] = useState(config.model_service);
  const [concurrency, setConcurrency] = useState(config.max_concurrency);
  const [busy, setBusy] = useState<"save" | "test" | null>(null);
  const [saveError, setSaveError] = useState<string | null>(null);
  const [saved, setSaved] = useState(false);

  const installDefault = config.install_default_model_service;
  const options = services.data?.data.services ?? [];
  const listMessage = services.data?.data.message ?? null;
  const trimmed = service.trim();
  const concurrencyInvalid =
    !Number.isInteger(concurrency) ||
    concurrency < MIN_TAXONOMY_CONCURRENCY ||
    concurrency > MAX_TAXONOMY_CONCURRENCY;
  const dirty = trimmed !== config.model_service || concurrency !== config.max_concurrency;

  const persist = async (modelService: string) => {
    setBusy("save");
    setSaveError(null);
    setSaved(false);
    try {
      const r = await save({ params: {}, data: { model_service: modelService, max_concurrency: concurrency } });
      queryClient.setQueryData(getTaxonomyConfigKey(), r);
      setService(r.data.model_service);
      setConcurrency(r.data.max_concurrency);
      setSaved(true);
      setTimeout(() => setSaved(false), 2000);
    } catch (err: unknown) {
      setSaveError(apiErrorMessage(err, "Save failed"));
      // A refused save still recorded a test result on the server.
      void queryClient.invalidateQueries({ queryKey: getTaxonomyConfigKey() });
    } finally {
      setBusy(null);
    }
  };

  const test = async () => {
    setBusy("test");
    setSaveError(null);
    try {
      await runTest({ params: {} });
    } catch (err: unknown) {
      setSaveError(apiErrorMessage(err, "Test failed"));
    } finally {
      await queryClient.invalidateQueries({ queryKey: getTaxonomyConfigKey() });
      setBusy(null);
    }
  };

  return (
    <form
      data-testid="taxonomy-builder-form"
      className="space-y-4"
      onSubmit={(e) => {
        e.preventDefault();
        if (!concurrencyInvalid) void persist(trimmed);
      }}
    >
      <div className="space-y-2">
        <label className="text-sm font-medium">Model service</label>
        <FreeTextCombobox
          value={service}
          onChange={setService}
          options={options}
          loading={services.isLoading}
          error={services.isError || (!services.isLoading && options.length === 0)}
          disabled={busy !== null}
          ariaLabel="Model service"
          placeholder="Pick a model service"
          searchPlaceholder="Filter or type catalog.schema.service…"
          emptyText="No model services match."
          loadingText="Loading model services…"
          fallbackPlaceholder="catalog.schema.service, e.g. system.ai.claude-sonnet-5-5"
          testIdPrefix="taxonomy-model-service"
        />
        {listMessage && <p className="text-xs text-muted-foreground">{listMessage}</p>}
        {config.last_check && <TaxonomyCheckLine check={config.last_check} />}
        <p className="text-xs text-muted-foreground">
          The Unity Catalog model service that drafts domains and descriptions, called through the AI
          Gateway as the app's service principal. It needs USE CATALOG, USE SCHEMA and EXECUTE.
          {installDefault && (
            <>
              {" "}Install default: <span className="font-mono">{installDefault}</span>.
            </>
          )}
        </p>
      </div>

      <div className="space-y-2">
        <label className="text-sm font-medium" htmlFor="taxonomy-max-concurrency">
          Concurrent model calls
        </label>
        <Input
          id="taxonomy-max-concurrency"
          type="number"
          min={MIN_TAXONOMY_CONCURRENCY}
          max={MAX_TAXONOMY_CONCURRENCY}
          step={1}
          className="w-32"
          value={concurrency}
          onChange={(e) => {
            const next = parseInt(e.target.value, 10);
            setConcurrency(Number.isNaN(next) ? 0 : next);
          }}
          aria-invalid={concurrencyInvalid}
        />
        {concurrencyInvalid && (
          <StatusLine tone="error">
            Between {MIN_TAXONOMY_CONCURRENCY} and {MAX_TAXONOMY_CONCURRENCY}.
          </StatusLine>
        )}
        <p className="text-xs text-muted-foreground">
          App-wide limit on calls running at once. One draft uses up to 6. What the service can
          take depends on its rate limits.
        </p>
      </div>

      {saveError && <SaveErrorBox testId="taxonomy-save-error">{saveError}</SaveErrorBox>}
      {saved && <SavedNotice>Saved</SavedNotice>}

      <div className="flex flex-wrap gap-2">
        <Button type="submit" disabled={busy !== null || concurrencyInvalid || !dirty}>
          <Save className="h-4 w-4 mr-2" />
          {busy === "save" ? "Testing and saving..." : "Save"}
        </Button>
        <Button
          type="button"
          variant="outline"
          onClick={() => void test()}
          disabled={busy !== null || !config.model_service}
        >
          <FlaskConical className="h-4 w-4 mr-2" />
          {/* Test probes the STORED service; say so while the form differs from it. */}
          {busy === "test" ? "Testing..." : dirty ? "Test saved service" : "Test"}
        </Button>
        {installDefault ? (
          <Button
            type="button"
            variant="outline"
            onClick={() => void persist(installDefault)}
            disabled={busy !== null || concurrencyInvalid}
          >
            <RotateCcw className="h-4 w-4 mr-2" />
            Reset to install default
          </Button>
        ) : (
          <Button
            type="button"
            variant="outline"
            onClick={() => void persist("")}
            disabled={busy !== null || concurrencyInvalid || !config.model_service}
          >
            <X className="h-4 w-4 mr-2" />
            Clear
          </Button>
        )}
      </div>
    </form>
  );
}
