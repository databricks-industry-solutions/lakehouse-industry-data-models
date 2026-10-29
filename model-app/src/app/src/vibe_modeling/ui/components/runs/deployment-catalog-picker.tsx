import { useEffect, useMemo, useState } from "react";
import { useQuery } from "@tanstack/react-query";
import { FreeTextCombobox } from "@/components/ui/free-text-combobox";
import { Button } from "@/components/ui/button";
import { CopyBlock } from "@/components/assessment/copy-block";
import {
  getCatalogCapabilities,
  listCatalogs,
  type CatalogCapabilityOut,
  type CatalogOut,
} from "@/lib/api";
import { capabilityFix, catalogUsable } from "@/lib/catalog-capability";
import { useDebouncedValue } from "@/lib/hooks";

/** `can_create_schema` is true when the server holds a recent positive check. */
export type CatalogOption = CatalogOut;

/** The backend checks at most this many catalogs per call
 *  (`core/_uc_privileges.CAPABILITY_CHECK_CAP`; parity via the shared fixture). */
export const CAPABILITY_CHECK_CAP = 25;

/** Automatic checks of listed options stop after this many names per filter
 *  text; the chosen or typed value and a new filter are still checked. */
export const AUTO_CHECK_BUDGET = 2 * CAPABILITY_CHECK_CAP;

const UNCHECKED_HINT = "Couldn't check the app's access";

export type DeploymentCatalogPickerProps = {
  value: string;
  onChange: (v: string) => void;
  disabled?: boolean;
  /** Whether the run creates schemas in this catalog (`runCreatesSchemas`);
   *  such runs need CREATE SCHEMA, the others only `_metamodel` access. */
  createsSchemas?: boolean;
  /** Escape hatch for tests — lets us inject catalogs directly and skip the
   *  `/api/catalogs` fetch so component tests don't depend on MSW or network
   *  mocking. Undefined means "fetch normally". */
  catalogsOverride?: CatalogOption[];
  /** If set (tests), skips the fetch entirely and forces the given state. */
  loadingOverride?: boolean;
  errorOverride?: boolean;
};

async function fetchCatalogs(): Promise<CatalogOption[]> {
  const r = await listCatalogs();
  return r.data;
}

async function fetchCapabilities(names: string[]): Promise<CatalogCapabilityOut[]> {
  try {
    return (await getCatalogCapabilities({ names })).data;
  } catch {
    // A failed call leaves its names unchecked, so they are not retried in a loop.
    return names.map((name) => ({ name, create_schema: null, use_metamodel: null }));
  }
}

function matches(name: string, search: string): boolean {
  const s = search.trim().toLowerCase();
  return !s || name.toLowerCase().includes(s);
}

/**
 * Catalog picker for the Deployment Catalog field. Lists catalogs the app SP
 * can see, sorted alphabetically, with an inline filter that matches
 * case-insensitively anywhere in the catalog name.
 *
 * Only catalogs the app can use for this run are offered. The list arrives
 * without waiting on checks; the picker then asks `getCatalogCapabilities`
 * about the chosen value and the first options shown under the current
 * filter, hides the ones the app can't use, and marks the ones it couldn't
 * check. A typed or saved name is checked too; a refusal shows the GRANT an
 * admin runs (the app never grants on a catalog it doesn't own).
 *
 * Falls back to a plain text input if the listing fails so a broken listing
 * endpoint doesn't block a run, and offers "Use '<input>'" so a catalog that
 * isn't listed can be committed (`FreeTextCombobox`).
 */
export function DeploymentCatalogPicker({
  value,
  onChange,
  disabled,
  createsSchemas = true,
  catalogsOverride,
  loadingOverride,
  errorOverride,
}: DeploymentCatalogPickerProps) {
  const query = useQuery({
    queryKey: ["catalogs"],
    queryFn: fetchCatalogs,
    staleTime: 60_000,
    retry: false,
    // When an override is provided (tests) we don't want the real fetch to
    // run — gate the query with `enabled`.
    enabled: catalogsOverride === undefined,
  });

  const data = catalogsOverride ?? query.data;
  const isLoading = loadingOverride ?? (catalogsOverride === undefined && query.isLoading);
  const isError = errorOverride ?? (catalogsOverride === undefined && query.isError);

  const names = useMemo(
    () =>
      (data ?? [])
        .map((c) => c.name)
        .sort((a, b) => a.localeCompare(b, undefined, { sensitivity: "base" })),
    [data],
  );

  // Capabilities by catalog name: list entries with a cached positive, then
  // every check this picker made. "Check again" asks again and replaces the answer.
  const [checked, setChecked] = useState<Record<string, CatalogCapabilityOut>>({});
  const caps = useMemo(() => {
    const out: Record<string, CatalogCapabilityOut> = {};
    for (const c of data ?? []) {
      if (c.can_create_schema === true) out[c.name] = { name: c.name, create_schema: true, use_metamodel: true };
    }
    return { ...out, ...checked };
  }, [data, checked]);

  const fallback = isError || (!isLoading && !data);
  const [search, setSearch] = useState("");
  const debouncedSearch = useDebouncedValue(search, 300);
  // The plain input checks only once typing pauses for a while: every
  // keystroke there changes the value itself.
  const debouncedValue = useDebouncedValue(value.trim(), fallback ? 1000 : 300);
  // Listed names checked automatically, per filter text (AUTO_CHECK_BUDGET).
  const [spent, setSpent] = useState<Record<string, number>>({});
  // The name "Check again" was pressed for, until its new answer lands. The
  // old answer stays on screen meanwhile.
  const [rechecking, setRechecking] = useState<string | null>(null);

  const usableOf = (name: string): boolean | null | undefined =>
    caps[name] ? catalogUsable(caps[name], createsSchemas) : undefined;
  const options = useMemo(
    () => names.filter((n) => !caps[n] || catalogUsable(caps[n], createsSchemas) !== false),
    [names, caps, createsSchemas],
  );

  // The saved or typed value plus the first page of options shown under the
  // filter. Hidden options drop out and the page refills, until the filter
  // text has used AUTO_CHECK_BUDGET names, so a long list of unusable
  // catalogs is not walked.
  const { toCheck, pageCount } = useMemo(() => {
    const value = debouncedValue && !(debouncedValue in caps) ? [debouncedValue] : [];
    if (rechecking && !value.includes(rechecking)) value.unshift(rechecking);
    const room = Math.max(0, AUTO_CHECK_BUDGET - (spent[debouncedSearch] ?? 0));
    const page = options
      .filter((n) => matches(n, debouncedSearch))
      .slice(0, CAPABILITY_CHECK_CAP - 1)
      .filter((n) => !(n in caps) && !value.includes(n))
      .slice(0, room);
    return { toCheck: [...value, ...page], pageCount: page.length };
  }, [debouncedValue, rechecking, options, debouncedSearch, caps, spent]);

  const capQuery = useQuery({
    queryKey: ["catalogCapabilities", debouncedSearch, toCheck],
    queryFn: async () => ({ term: debouncedSearch, pageCount, caps: await fetchCapabilities(toCheck) }),
    // Wait for the listing so a preset value and the first page go out as one
    // request; a failed listing still reaches the plain-input check.
    enabled: toCheck.length > 0 && !isLoading,
    retry: false,
    staleTime: 0,
    gcTime: 0,
  });

  useEffect(() => {
    const result = capQuery.data;
    if (!result) return;
    setChecked((prev) => {
      const next = { ...prev };
      for (const c of result.caps) next[c.name] = c;
      return next;
    });
    if (result.pageCount) {
      setSpent((prev) => ({ ...prev, [result.term]: (prev[result.term] ?? 0) + result.pageCount }));
    }
    setRechecking((prev) => (prev && result.caps.some((c) => c.name === prev) ? null : prev));
  }, [capQuery.data]);

  const optionHint = (n: string) => (usableOf(n) === null ? UNCHECKED_HINT : undefined);

  const current = value.trim();
  const currentCap = current ? caps[current] : undefined;
  const currentUsable = currentCap ? catalogUsable(currentCap, createsSchemas) : undefined;
  const fix = currentCap && currentUsable === false ? capabilityFix(currentCap, createsSchemas) : "";

  const checkAgainButton = (
    <Button
      type="button"
      variant="outline"
      size="sm"
      disabled={rechecking === current}
      onClick={() => setRechecking(current)}
    >
      {rechecking === current ? "Checking…" : "Check again"}
    </Button>
  );

  return (
    <div className="space-y-2">
      <FreeTextCombobox
        value={value}
        onChange={onChange}
        options={options}
        loading={isLoading}
        // Error or unset -> plain input fallback; the live value is still the parent's.
        error={fallback}
        disabled={disabled}
        ariaLabel="Deployment catalog"
        placeholder="Pick a catalog"
        searchPlaceholder="Filter or type a new catalog name…"
        emptyText="No catalogs match."
        loadingText="Loading catalogs…"
        fallbackPlaceholder="e.g. my_catalog"
        testIdPrefix="deployment-catalog"
        optionHint={optionHint}
        onSearchChange={setSearch}
      />
      {currentUsable === false && (
        <div
          role="alert"
          className="space-y-2 rounded-md border border-destructive/50 bg-destructive/5 p-2 text-xs"
          data-testid="deployment-catalog-refused"
        >
          <p className="text-destructive">
            {!fix
              ? `${current} may not exist, or the app can't see it.`
              : createsSchemas && currentCap?.create_schema === false
                ? `The app can't create schemas in ${current}, which this run needs.`
                : `The app can't use or create ${current}._metamodel, which every run writes to.`}
          </p>
          {fix && (
            <>
              <p className="text-foreground">Ask a workspace admin to run:</p>
              <CopyBlock text={fix} />
            </>
          )}
          {checkAgainButton}
        </div>
      )}
      {currentUsable === null && (
        <div className="flex items-center gap-2" data-testid="deployment-catalog-unchecked">
          <p className="text-xs text-muted-foreground">
            {UNCHECKED_HINT} to {current}.
          </p>
          {checkAgainButton}
        </div>
      )}
    </div>
  );
}
