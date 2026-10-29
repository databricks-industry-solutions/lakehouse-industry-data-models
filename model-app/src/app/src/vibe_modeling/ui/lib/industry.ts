import type { IndustryOut } from "@/lib/api";

/** The fields industry resolution reads; ``IndustryOut`` rows carry them. */
export type IndustryLike = Pick<
  IndustryOut,
  "name" | "short_name" | "is_active" | "is_auto_created"
>;

/**
 * The industry slug rule of ``backend/industry_resolve.py``: lowercase, every
 * run of non-alphanumerics becomes one hyphen, hyphens trimmed.
 * ``"Energy - Utilities"`` and ``"energy_utilities"`` both give
 * ``"energy-utilities"``. Both sides test against
 * ``tests/fixtures/industry_slug_fixture.json``.
 */
export function industrySlug(value: string | null | undefined): string {
  return (value ?? "")
    .trim()
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/^-+|-+$/g, "");
}

/**
 * The backend's ``matching_industries``: every active industry whose ``name``
 * or ``short_name`` slug equals the slug of ``text``; empty for an empty slug.
 */
export function matchingIndustries<T extends IndustryLike>(
  industries: readonly T[] | null | undefined,
  text: string | null | undefined,
): T[] {
  const slug = industrySlug(text);
  if (!slug) return [];
  return (industries ?? []).filter(
    (i) =>
      i.is_active &&
      (industrySlug(i.name) === slug || industrySlug(i.short_name) === slug),
  );
}

/**
 * The backend's ``pick_industry``: the one industry of ``matchingIndustries``.
 * A curated industry wins over an auto-created one; two matches of the same
 * kind are ambiguous and give ``undefined``, as do no match and an empty slug.
 */
export function pickIndustry<T extends IndustryLike>(
  industries: readonly T[] | null | undefined,
  text: string | null | undefined,
): T | undefined {
  const matches = matchingIndustries(industries, text);
  const curated = matches.filter((i) => !i.is_auto_created);
  const best = curated.length > 0 ? curated : matches;
  return best.length === 1 ? best[0] : undefined;
}

const LOWER_WORDS = new Set([
  "a",
  "an",
  "and",
  "or",
  "of",
  "the",
  "to",
  "for",
  "in",
  "on",
  "&",
]);

/**
 * Title-case a raw kebab/underscore slug for display. Splits on hyphens,
 * underscores and whitespace; capitalizes each word except a small set of
 * connector words (which stay lowercase unless they lead). Single-letter
 * tokens and the first word are always capitalized.
 *
 * ``"food-and-beverage"`` → ``"Food and Beverage"``
 * ``"digital-fashion-commerce"`` → ``"Digital Fashion Commerce"``
 */
function titleCaseSlug(value: string): string {
  const words = value
    .trim()
    .split(/[-_\s]+/)
    .filter(Boolean);
  return words
    .map((word, i) => {
      const lower = word.toLowerCase();
      if (i > 0 && LOWER_WORDS.has(lower)) return lower;
      return lower.charAt(0).toUpperCase() + lower.slice(1);
    })
    .join(" ");
}

/**
 * A raw kebab/snake slug: all-lowercase, no whitespace, joined by hyphens
 * or underscores (``"food-and-beverage"``, ``"energy_utilities"``). Used to
 * decide whether a string still needs humanizing for display vs. is already
 * a curated display name (``"Food and Beverage"``, ``"Retail & E-Commerce"``).
 */
function looksLikeSlug(value: string): boolean {
  const v = value.trim();
  return /[-_]/.test(v) && !/\s/.test(v) && v === v.toLowerCase();
}

/**
 * Resolve a stored ``industry_alignment`` value to a user-facing display
 * name. Render-time only; never mutates stored data.
 *
 *  1. The catalog industry ``pickIndustry`` resolves it to gives its
 *     ``name``, humanized when that name is itself a raw slug.
 *  2. Otherwise the raw hyphenated/underscored slug is title-cased
 *     (``"food-and-beverage"`` -> ``"Food and Beverage"``).
 *
 * Falsy / blank input is returned as-is so callers can guard rendering.
 */
export function industryDisplayName(
  value: string | null | undefined,
  industries: readonly IndustryLike[] | null | undefined,
): string {
  if (!value || !value.trim()) return value ?? "";

  const match = pickIndustry(industries, value);
  if (match) {
    return looksLikeSlug(match.name) ? titleCaseSlug(match.name) : match.name;
  }

  return titleCaseSlug(value);
}

/**
 * "<industry> v<n>" for the industry a business was kickstarted from, or
 * "an industry" when its row is gone (``source_industry_id`` is cleared when
 * the industry is deleted, and the list may not have loaded yet).
 */
export function kickstartSourceLabel(
  sourceName: string | null | undefined,
  sourceVersion: number | null | undefined,
): string {
  if (!sourceName) return "an industry";
  return sourceVersion != null ? `${sourceName} v${sourceVersion}` : sourceName;
}
