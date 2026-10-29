import { useEffect, useId, useMemo, useState } from "react";
import { Check as CheckIcon, ChevronsUpDown, Plus as PlusIcon } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Popover, PopoverContent, PopoverTrigger } from "@/components/ui/popover";
import { Command, CommandEmpty, CommandInput, CommandItem, CommandList } from "@/components/ui/command";

export type FreeTextComboboxProps = {
  value: string;
  onChange: (v: string) => void;
  /** Options in display order (the caller sorts). */
  options: string[];
  loading?: boolean;
  /** Listing failed: render a plain text input so the field never blocks. */
  error?: boolean;
  disabled?: boolean;
  ariaLabel: string;
  /** Trigger text when nothing is chosen. */
  placeholder: string;
  searchPlaceholder: string;
  emptyText: string;
  loadingText: string;
  fallbackPlaceholder: string;
  /** Prefix for the fallback / loading / use-custom test ids. */
  testIdPrefix: string;
  /** Short muted note shown next to an option (e.g. why it is unverified). */
  optionHint?: (option: string) => string | undefined;
  /** Called with the filter text as the user types. */
  onSearchChange?: (search: string) => void;
};

/**
 * A picker over a fetched list that also accepts a typed value. Filters the
 * list client-side, case-insensitively anywhere in the name (cmdk's own
 * filter was unreliable, #111), and offers "Use '<input>'" when the typed
 * text matches no option exactly. Falls back to a plain input when the
 * listing failed, so a broken list never blocks the field.
 *
 * Items sit directly under `CommandList` (no `CommandGroup`): inside a
 * portalled Radix popover Chrome attached grouped options to the inner group
 * instead of the listbox, leaving an "empty listbox" for keyboard and
 * screen-reader users (the model-versioning work F4).
 */
export function FreeTextCombobox({
  value,
  onChange,
  options,
  loading,
  error,
  disabled,
  ariaLabel,
  placeholder,
  searchPlaceholder,
  emptyText,
  loadingText,
  fallbackPlaceholder,
  testIdPrefix,
  optionHint,
  onSearchChange,
}: FreeTextComboboxProps) {
  const [open, setOpen] = useState(false);
  const [search, setSearchState] = useState("");
  const setSearch = (s: string) => {
    setSearchState(s);
    onSearchChange?.(s);
  };
  const reactId = useId();
  const triggerId = `${reactId}-${testIdPrefix}-trigger`;

  const trimmedSearch = search.trim();
  const searchLower = trimmedSearch.toLowerCase();

  const filtered = useMemo(() => {
    if (!trimmedSearch) return options;
    return options.filter((o) => o.toLowerCase().includes(searchLower));
  }, [options, searchLower, trimmedSearch]);

  const exactMatch = useMemo(
    () => Boolean(trimmedSearch) && options.some((o) => o.toLowerCase() === searchLower),
    [options, searchLower, trimmedSearch],
  );
  const showCustomOption = Boolean(trimmedSearch) && !exactMatch;
  const customValue = `__use_custom__::${trimmedSearch}`;

  // The highlighted item, controlled so that when the list changes under it
  // (an option drops out) the highlight moves to the first item left and
  // Enter still picks something.
  const [highlighted, setHighlighted] = useState("");
  const itemValues = useMemo(
    () => [...filtered, ...(showCustomOption ? [customValue] : [])],
    [filtered, showCustomOption, customValue],
  );
  useEffect(() => {
    if (!itemValues.includes(highlighted)) setHighlighted(itemValues[0] ?? "");
  }, [itemValues, highlighted]);

  if (error) {
    return (
      <Input
        value={value}
        onChange={(e) => onChange(e.target.value)}
        placeholder={fallbackPlaceholder}
        disabled={disabled}
        aria-label={ariaLabel}
        data-testid={`${testIdPrefix}-fallback-input`}
      />
    );
  }
  if (loading) {
    return (
      <Button
        type="button"
        variant="outline"
        disabled
        className="w-full justify-between font-normal"
        data-testid={`${testIdPrefix}-loading`}
      >
        <span className="text-muted-foreground">{loadingText}</span>
        <ChevronsUpDown className="h-4 w-4 opacity-50 shrink-0 ml-2" />
      </Button>
    );
  }

  const choose = (v: string) => {
    onChange(v);
    setOpen(false);
    setSearch("");
  };

  return (
    <Popover open={open} onOpenChange={setOpen}>
      <PopoverTrigger asChild>
        <Button
          id={triggerId}
          type="button"
          variant="outline"
          role="combobox"
          aria-expanded={open}
          aria-haspopup="listbox"
          aria-label={ariaLabel}
          disabled={disabled}
          className="w-full justify-between font-normal"
        >
          <span className={value ? "" : "text-muted-foreground"}>{value || placeholder}</span>
          <ChevronsUpDown className="h-4 w-4 opacity-50 shrink-0 ml-2" />
        </Button>
      </PopoverTrigger>
      <PopoverContent className="p-0 w-[var(--radix-popover-trigger-width)]" align="start">
        <Command shouldFilter={false} label={ariaLabel} value={highlighted} onValueChange={setHighlighted}>
          <CommandInput placeholder={searchPlaceholder} value={search} onValueChange={setSearch} />
          <CommandList>
            {filtered.length === 0 && !showCustomOption && <CommandEmpty>{emptyText}</CommandEmpty>}
            {filtered.map((o) => {
              const hint = optionHint?.(o);
              return (
                <CommandItem
                  key={o}
                  value={o}
                  onSelect={() => choose(o)}
                  className="flex items-center justify-between"
                >
                  <span className="truncate">{o}</span>
                  <span className="flex items-center shrink-0 ml-2 gap-2">
                    {hint && <span className="text-xs text-muted-foreground">{hint}</span>}
                    {value === o && <CheckIcon className="h-4 w-4 shrink-0" />}
                  </span>
                </CommandItem>
              );
            })}
            {showCustomOption && (
              <CommandItem
                // Unique value so cmdk doesn't conflate it with a real option
                // when the typed text is a prefix of one.
                value={customValue}
                onSelect={() => choose(trimmedSearch)}
                className="flex items-center gap-2"
                data-testid={`${testIdPrefix}-use-custom`}
              >
                <PlusIcon className="h-4 w-4 shrink-0" />
                <span className="truncate">Use &ldquo;{trimmedSearch}&rdquo;</span>
              </CommandItem>
            )}
          </CommandList>
        </Command>
      </PopoverContent>
    </Popover>
  );
}
