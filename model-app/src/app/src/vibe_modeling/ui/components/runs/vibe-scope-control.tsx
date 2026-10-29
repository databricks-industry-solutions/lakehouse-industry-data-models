/**
 * VibeScopeControl — scope + run-type controls for a vibe iteration
 * (design §9.1). Shown on the New Run form for `vibe modeling of version`.
 *
 * - Scope: All domains | Some domains. Some Subdomains is not offered (phase 2).
 * - Domains (Some domains only): a plain checkbox list of the base version's
 *   domains. Requested names that match no domain (for example from a deep
 *   link) show as error chips, with the server's message when it has one.
 * - Run type: Dry Run | Full Run, with the plain-language consequence of the
 *   current choice.
 * - `fullRunOnly` (an agent older than the scope marker) disables Some domains
 *   and Dry Run.
 *
 * The control is dumb: the parent owns all state and the request bodies.
 */

import { X } from "lucide-react";
import { Checkbox } from "@/components/ui/checkbox";
import { cn } from "@/lib/utils";
import { HelpLink } from "@/components/help/help-link";
import {
  DRY_RUN_CONSEQUENCE,
  fullRunConsequence,
  scopeKey,
  type AgentRunMode,
  type VibeScopeMode,
} from "@/lib/vibe-scope";

export interface VibeScopeControlProps {
  scope: VibeScopeMode;
  onScopeChange: (scope: VibeScopeMode) => void;
  /** Domain names of the base version. `undefined` while loading. */
  domainNames?: readonly string[];
  /** Requested scope names (canonical once matched). */
  selectedDomains: readonly string[];
  onToggleDomain: (name: string, checked: boolean) => void;
  /** Requested names that match no domain of the base version. */
  unknownDomains?: readonly string[];
  /** Server message per unknown name (from the validate blockers). */
  unknownMessages?: Readonly<Record<string, string>>;
  onRemoveUnknown?: (name: string) => void;
  runMode: AgentRunMode;
  onRunModeChange: (mode: AgentRunMode) => void;
  /** Deployment catalog, named in the Full Run consequence. */
  catalog: string;
  /** The agent runs only unscoped Full Runs: Some domains and Dry Run are disabled. */
  fullRunOnly?: boolean;
  /** Id of the element that explains `fullRunOnly`; both groups point at it. */
  fullRunOnlyNoteId?: string;
}

interface SegmentOption<T extends string> {
  value: T;
  label: string;
  disabled?: boolean;
}

function Segmented<T extends string>({
  label,
  value,
  options,
  onChange,
  describedBy,
}: {
  label: string;
  value: T;
  options: readonly SegmentOption<T>[];
  onChange: (v: T) => void;
  describedBy?: string;
}) {
  return (
    <div role="radiogroup" aria-label={label} aria-describedby={describedBy} className="flex gap-1">
      {options.map((opt) => {
        const active = opt.value === value;
        return (
          <button
            key={opt.value}
            type="button"
            role="radio"
            aria-checked={active}
            disabled={opt.disabled}
            onClick={() => onChange(opt.value)}
            className={cn(
              "px-3 py-1 text-xs rounded-md transition-colors disabled:cursor-not-allowed disabled:opacity-50",
              active
                ? "bg-primary text-primary-foreground"
                : "bg-muted text-muted-foreground hover:bg-muted/80",
            )}
          >
            {opt.label}
          </button>
        );
      })}
    </div>
  );
}

const SCOPE_OPTIONS: readonly SegmentOption<VibeScopeMode>[] = [
  { value: "all_domains", label: "All domains" },
  { value: "some_domains", label: "Some domains" },
];

const RUN_MODE_OPTIONS: readonly SegmentOption<AgentRunMode>[] = [
  { value: "dry", label: "Dry Run" },
  { value: "full", label: "Full Run" },
];

export function VibeScopeControl({
  scope,
  onScopeChange,
  domainNames,
  selectedDomains,
  onToggleDomain,
  unknownDomains = [],
  unknownMessages = {},
  onRemoveUnknown,
  runMode,
  onRunModeChange,
  catalog,
  fullRunOnly = false,
  fullRunOnlyNoteId,
}: VibeScopeControlProps) {
  const describedBy = fullRunOnly ? fullRunOnlyNoteId : undefined;
  const selectedKeys = new Set(selectedDomains.map(scopeKey));
  const scopeOptions = SCOPE_OPTIONS.map((o) => ({
    ...o,
    disabled: fullRunOnly && o.value === "some_domains",
  }));
  const runModeOptions = RUN_MODE_OPTIONS.map((o) => ({
    ...o,
    disabled: fullRunOnly && o.value === "dry",
  }));

  return (
    <div className="space-y-4" data-testid="vibe-scope-control">
      <div className="space-y-2">
        <div className="flex items-center gap-2">
          <label className="text-sm font-medium">Scope</label>
          <HelpLink topic="run-vibe" label="How scope works" />
        </div>
        <Segmented
          label="Scope"
          value={scope}
          options={scopeOptions}
          onChange={onScopeChange}
          describedBy={describedBy}
        />
      </div>

      {scope === "some_domains" && (
        <div className="space-y-2" data-testid="vibe-scope-domains">
          <label className="text-sm font-medium">Domains</label>
          {domainNames === undefined ? (
            <p className="text-xs text-muted-foreground">Loading domains…</p>
          ) : domainNames.length === 0 ? (
            <p className="text-xs text-muted-foreground">This version has no domains.</p>
          ) : (
            <div className="grid grid-cols-2 gap-x-4 gap-y-1.5 rounded-md border border-input p-3 max-h-56 overflow-auto">
              {domainNames.map((name) => {
                const id = `vibe-scope-domain-${scopeKey(name) || name}`;
                return (
                  <div key={name} className="flex items-center gap-2">
                    <Checkbox
                      id={id}
                      checked={selectedKeys.has(scopeKey(name))}
                      onCheckedChange={(v) => onToggleDomain(name, v === true)}
                    />
                    <label htmlFor={id} className="text-sm">
                      {name}
                    </label>
                  </div>
                );
              })}
            </div>
          )}
          {unknownDomains.length > 0 && (
            <ul className="flex flex-wrap gap-2" data-testid="vibe-scope-unknown">
              {unknownDomains.map((name) => (
                <li
                  key={name}
                  className="inline-flex items-center gap-1 rounded-md border border-destructive/50 bg-destructive/5 px-2 py-0.5 text-xs text-destructive"
                  title={unknownMessages[name]}
                >
                  <span>
                    {unknownMessages[name] ?? `'${name}' is not a domain of this version.`}
                  </span>
                  {onRemoveUnknown && (
                    <button
                      type="button"
                      aria-label={`Remove ${name}`}
                      onClick={() => onRemoveUnknown(name)}
                      className="hover:opacity-70"
                    >
                      <X className="h-3 w-3" />
                    </button>
                  )}
                </li>
              ))}
            </ul>
          )}
        </div>
      )}

      <div className="space-y-2">
        <div className="flex items-center gap-2">
          <label className="text-sm font-medium">Run type</label>
          <HelpLink topic="run-vibe" label="Dry Run and Full Run" />
        </div>
        <Segmented
          label="Run type"
          value={runMode}
          options={runModeOptions}
          onChange={onRunModeChange}
          describedBy={describedBy}
        />
        <p
          className={cn(
            "rounded-md border px-3 py-2 text-xs",
            runMode === "full"
              ? "border-warning/40 bg-warning/10 text-warning"
              : "border-input bg-muted/30 text-muted-foreground",
          )}
          data-testid="vibe-run-mode-consequence"
        >
          {runMode === "dry" ? DRY_RUN_CONSEQUENCE : fullRunConsequence(catalog)}
        </p>
      </div>
    </div>
  );
}
