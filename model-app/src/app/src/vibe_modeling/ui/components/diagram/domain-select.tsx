import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";

interface DomainSelectProps {
  domains: { name: string; division?: string }[];
  value: string | null;
  onChange: (next: string | null) => void;
  /** Portal container for the dropdown content (needed in fullscreen). */
  portalContainer?: HTMLElement | null;
  className?: string;
  /** Offer the "All domains" choice. Defaults to true; a pick that opens a
   *  domain's page (Overview, Products, the product page) turns it off. */
  allowAll?: boolean;
  /** Shown while no domain is picked and "All domains" is not offered
   *  (e.g. "Go to domain" on the version page's Overview). */
  placeholder?: string;
}

const ALL_SENTINEL = "__all__";

/**
 * The one domain dropdown, rendered inside each tab that has a per-domain
 * view (Overview, Diagram, Ontology, Products, the product page), always
 * below the tab strip, never above it.
 *
 * The first option ("All domains") maps to a `null` value via the
 * `__all__` sentinel — keeping the value type as `string | null` lets
 * callers branch on a real domain name vs. the unfiltered case.
 */
export function DomainSelect({
  domains,
  value,
  onChange,
  portalContainer,
  className,
  allowAll = true,
  placeholder,
}: DomainSelectProps) {
  return (
    <Select
      value={value ?? (allowAll ? ALL_SENTINEL : "")}
      onValueChange={(v) => onChange(v === ALL_SENTINEL ? null : v)}
    >
      <SelectTrigger className={className ?? "w-[220px] h-8 text-sm"} aria-label="Domain">
        <SelectValue placeholder={placeholder ?? "All domains"} />
      </SelectTrigger>
      <SelectContent container={portalContainer}>
        {allowAll && <SelectItem value={ALL_SENTINEL}>All domains</SelectItem>}
        {domains.map((d) => (
          <SelectItem key={d.name} value={d.name}>
            {d.name}
            {d.division && (
              <span className="text-muted-foreground ml-1">({d.division})</span>
            )}
          </SelectItem>
        ))}
      </SelectContent>
    </Select>
  );
}

/** A tab's own toolbar row holding the domain dropdown, for tabs whose body
 *  has no toolbar of its own (Overview, Products, the product page). The
 *  Diagram and Ontology put `DomainSelect` in their toolbars. */
export function TabDomainSelect(props: DomainSelectProps) {
  return (
    <div className="flex items-center gap-3 py-2">
      <DomainSelect {...props} />
    </div>
  );
}
