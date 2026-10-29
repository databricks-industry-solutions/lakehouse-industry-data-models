import { BusinessKind } from "@/lib/api";

/**
 * Label helpers for the ``businesses.kind`` discriminator (ADR D-046).
 *
 * An *industry* is a ``businesses`` row with ``kind='industry'`` — it shares
 * the entire business pipeline (same id space, same explorer/runs routes) but
 * is surfaced to the user as an "Industry", NEVER as a "meta-business" or as a
 * plain "Business". These helpers are the single source of truth for the
 * user-facing noun so every surface (list, explorer, deployments) stays in
 * sync; don't inline ``kind === 'industry' ? ... : ...`` ternaries.
 */

/** Singular noun, capitalized — e.g. "Industry" / "Business". */
export function entityKindLabel(kind: BusinessKind | undefined | null): string {
  return kind === BusinessKind.industry ? "Industry" : "Business";
}

/** Singular noun with its indefinite article, lowercase - "an industry" / "a business". */
export function entityKindWithArticle(
  kind: BusinessKind | undefined | null,
): string {
  return `${kind === BusinessKind.industry ? "an" : "a"} ${entityKindLabelLower(kind)}`;
}

/** Singular noun, lowercase — for mid-sentence use. */
export function entityKindLabelLower(
  kind: BusinessKind | undefined | null,
): string {
  return kind === BusinessKind.industry ? "industry" : "business";
}
