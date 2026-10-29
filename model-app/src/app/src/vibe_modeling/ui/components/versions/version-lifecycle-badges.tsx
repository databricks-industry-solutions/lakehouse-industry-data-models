/**
 * The lifecycle badges of a version: "Dry Run", "Dry Run (older base)",
 * "Replaced by v3" (with its date on the version header), and a muted
 * "from Dry Run" on a promoted draft. Shared by the version header and the
 * explorer's version list (`lib/version-lifecycle.versionLifecycleBadges`).
 */
import { Badge } from "@/components/ui/badge";
import {
  replacedHeader,
  versionLifecycleBadges,
  type LifecycleVersion,
  type VersionBadge,
} from "@/lib/version-lifecycle";

// Theme tokens only: warning and muted-foreground both reach AA on the card
// and background tokens in light and dark (styles/globals.css).
const TONE_CLASS: Record<VersionBadge["tone"], string> = {
  draft: "border-warning/50 bg-warning/5 text-warning",
  replaced: "border-border bg-muted text-foreground",
  muted: "border-transparent text-muted-foreground font-normal",
};

export function VersionLifecycleBadges({
  version,
  versions,
  withDate = false,
}: {
  version: LifecycleVersion;
  versions: readonly LifecycleVersion[];
  /** Spell out "Replaced by v3 on <date>" (version header). */
  withDate?: boolean;
}) {
  const badges = versionLifecycleBadges(version, versions);
  if (badges.length === 0) return null;
  const header = withDate ? replacedHeader(version, versions) : null;
  return (
    <span className="flex flex-wrap items-center gap-1.5" data-testid="version-lifecycle-badges">
      {badges.map((b) => (
        <Badge key={b.label} variant="outline" className={TONE_CLASS[b.tone]}>
          {b.tone === "replaced" && header ? header : b.label}
        </Badge>
      ))}
    </span>
  );
}
