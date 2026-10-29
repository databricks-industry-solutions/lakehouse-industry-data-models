/**
 * The one wording for "when is the next try": the taxonomy busy countdown,
 * the feature gates' retry, the assessment ingest retry and the busy
 * assessment run all say "next try ...". A live countdown in seconds reads
 * "next try in 00:42"; a time the server scheduled reads
 * "next try in 5 min (14:30)", with the local clock time so it stays true
 * when the page is left open.
 */
import { ensureUtcIso, formatElapsedSeconds, formatUntil } from "@/lib/date";

/** "next try in 00:42" for a countdown of `remainingS` seconds; "next try now" at zero. */
export function nextTryIn(remainingS: number): string {
  if (!isFinite(remainingS) || remainingS <= 0) return "next try now";
  return `next try in ${formatElapsedSeconds(remainingS)}`;
}

/** Local wall-clock time of a scheduled try ("14:30"), or "" when unset or unparseable. */
export function retryClock(at: string | null | undefined): string {
  if (!at) return "";
  const d = new Date(ensureUtcIso(at));
  if (isNaN(d.getTime())) return "";
  return d.toLocaleTimeString([], { hour: "2-digit", minute: "2-digit" });
}

/** "next try in 5 min (14:30)" for a scheduled time; "next try soon" when it is unset or past. */
export function nextTryAt(at: string | null | undefined, now: number = Date.now()): string {
  const until = formatUntil(at, now);
  if (until === "soon") return "next try soon";
  return `next try ${until} (${retryClock(at)})`;
}

/** Capitalise the first letter, for a "next try" phrase that starts a sentence. */
export function sentence(phrase: string): string {
  return phrase ? phrase[0].toUpperCase() + phrase.slice(1) : phrase;
}
