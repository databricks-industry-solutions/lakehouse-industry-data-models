import { useGetAssessConfig, type AssessDomainRunOut } from "@/lib/api";
import type { AdminHelp } from "@/lib/api-error";
import { nextTryAt } from "@/lib/retry-time";

/**
 * Whether the optional bronze assessment skill is installed and ready to
 * launch (`GET /assess/config` -> `installed`/`ready`/`missing`). Both flags
 * are false while loading and on error, so an Assess entry point never shows
 * when it can't be used; `loading` lets a page wait instead of flashing its
 * not-installed state.
 */
export function useAssessReady(): {
  installed: boolean;
  ready: boolean;
  loading: boolean;
  missing: string[];
  /** The config fetch failed: whether the skill is installed is unknown (not "not installed"). */
  error: unknown;
  refetch: () => Promise<unknown>;
} {
  const { data, isLoading, error, refetch } = useGetAssessConfig({ query: { retry: false } });
  return {
    installed: data?.data.installed === true,
    ready: data?.data.ready === true,
    loading: isLoading,
    missing: data?.data.missing ?? [],
    error: data ? null : (error ?? null),
    refetch: () => refetch(),
  };
}

/** Model the assessment job calls; must match `genie_model` in src/app/vendored/assessment/VERSIONS.json. */
export const ASSESS_MODEL = "gpt-5.6-sol";
/** Model service the reader needs EXECUTE on; must match `genie_model_service` in VERSIONS.json. */
export const ASSESS_MODEL_SERVICE = "system.ai.gpt-5-6-sol";

/** Display labels for assessment domain-run statuses. */
export const STATUS_LABEL: Record<string, string> = {
  queued: "Queued",
  starting: "Starting",
  assessing: "Assessing",
  rate_limited: "Model busy",
  completed: "Completed",
  results_invalid: "Results invalid",
  failed: "Failed",
  cancelled: "Cancelled",
};

const TERMINAL = new Set(["completed", "results_invalid", "failed", "cancelled"]);

/** True once a domain run can no longer change status. */
export const isTerminal = (s: string) => TERMINAL.has(s);

const RELAUNCHABLE = new Set(["failed", "cancelled", "results_invalid"]);

/** True for a domain-run status that the Relaunch action applies to. */
export const isRelaunchable = (s: string) => RELAUNCHABLE.has(s);

/** A run whose job finished but whose results failed to save and will be retried (it can't be cancelled). */
export function isIngestRetrying(run: Pick<AssessDomainRunOut, "status" | "ingest_attempts">): boolean {
  return run.status === "assessing" && (run.ingest_attempts ?? 0) > 0;
}

/**
 * "Saving results (attempt n of N), next try in 5 min (14:30)" from the structured retry
 * fields (`lib/retry-time.nextTryAt`); without `ingest_max_attempts` it reads "attempt n".
 */
export function ingestRetryText(
  run: Pick<AssessDomainRunOut, "ingest_attempts" | "ingest_max_attempts" | "ingest_next_at">,
  now: number = Date.now(),
): string {
  const attempt = `attempt ${run.ingest_attempts ?? 0}${run.ingest_max_attempts ? ` of ${run.ingest_max_attempts}` : ""}`;
  return `Saving results (${attempt}), ${nextTryAt(run.ingest_next_at, now)}`;
}

/** Default lead of an admin-help block (run, launch, hand-off and feedback failures). */
export const ADMIN_HELP_LEAD = "This assessment step failed.";
/** Lead of an admin-help block on a readiness check the app's setup owns. */
export const ADMIN_HELP_LEAD_CHECK = "This check needs your administrator.";
/** Lead of the admin-help block on a results_invalid run. */
export const ADMIN_HELP_LEAD_INGEST = "The assessment finished but its results couldn't be saved.";
/** Lead of the admin-help block when the run's documents can't be listed or read. */
export const ADMIN_HELP_LEAD_DOCS = "The run's documents couldn't be read.";
/** Lead of the admin-help block under a failed Settings save. */
export const ADMIN_HELP_LEAD_SAVE = "Saving these settings failed.";
/** Sentence after the lead on every admin-help block and in its copied text. */
export const ADMIN_HELP_CONTACT = "Please contact your administrator with these details.";

/**
 * The plain text the admin-help block copies: the lead and contact line, the
 * error, then the not-ready reasons and one labelled line per known detail
 * (job, job run, reader, files). Absent details are left out.
 */
export function adminHelpText(help: AdminHelp, lead: string = ADMIN_HELP_LEAD): string {
  const lines = [`${lead} ${ADMIN_HELP_CONTACT}`, help.message];
  for (const reason of help.not_ready ?? []) lines.push(`- ${reason}`);
  if (help.job_url) lines.push(`Job: ${help.job_url}`);
  if (help.run_url) lines.push(`Job run: ${help.run_url}`);
  if (help.job_reader) lines.push(`Ran as: ${help.job_reader}`);
  if (help.runs_path) lines.push(`Files: ${help.runs_path}`);
  return lines.join("\n");
}

const RUN_FAILED_FALLBACK: Record<string, string> = {
  failed: "The assessment run failed.",
  results_invalid: "The assessment results could not be saved.",
};

/** The admin-help details of a failed or results-invalid domain run, from its own links and reader. */
export function runAdminHelp(run: AssessDomainRunOut): AdminHelp {
  return {
    message: run.error_message || RUN_FAILED_FALLBACK[run.status] || RUN_FAILED_FALLBACK.failed,
    job_url: run.job_url || undefined,
    run_url: run.run_url || undefined,
    job_reader: run.job_reader || undefined,
    runs_path: run.runs_path || undefined,
  };
}

const READER_ID_PLACEHOLDER = "<reader-application-id>";
const WAREHOUSE_PLACEHOLDER = "<warehouse-id>";

/** One step of the reader setup checklist; `code` is absent for steps with nothing to run. */
export interface ReaderSetupStep {
  title: string;
  detail: string;
  code?: string;
}

/**
 * The reader service principal setup checklist: the admin steps INSTALL.md
 * lists under "Enabling the in-app bronze assessment skill", then Save. The
 * installer already grants the app CREATE VOLUME and MANAGE on `_metamodel`,
 * and Save creates the runs volume and grants the reader on it, so neither is
 * a step here. A typed Application ID / warehouse ID and the app's own
 * Application ID are substituted into every snippet; catalog placeholders are
 * left for the user.
 */
export function readerSetupSteps(
  readerApplicationId = "",
  warehouseId = "",
  appApplicationId = "",
): ReaderSetupStep[] {
  const reader = readerApplicationId.trim() || READER_ID_PLACEHOLDER;
  const warehouse = warehouseId.trim() || WAREHOUSE_PLACEHOLDER;
  const appId = appApplicationId.trim();
  const pickApp = appId
    ? `pick the app's service principal (Application ID ${appId})`
    : "pick the app's service principal (look for the app's name, e.g. vibe-modeling, or ask whoever deployed the app)";
  const readOn = (catalog: string) =>
    `GRANT USE CATALOG, USE SCHEMA, SELECT ON CATALOG \`${catalog}\` TO \`${reader}\`;`;
  return [
    {
      title: "Create the reader service principal and let the app use it",
      detail: `A workspace admin creates it and notes the Application ID it returns. Assessment jobs run as the reader, so on the reader's Permissions tab (Settings → Identity and access → Service principals → vibe-assess-reader) click Grant access, ${pickApp} and give it the Service Principal: User role.`,
      code: "databricks service-principals create --display-name vibe-assess-reader",
    },
    {
      title: "Grant read on the model and source catalogs",
      detail:
        "At catalog level, on every catalog the app deploys models into and on every approved source (bronze) catalog. Catalog-level grants cover schemas created later; if you grant per schema instead, users see the missing GRANT when they launch.",
      code: [readOn("<model_catalog>"), readOn("<source_catalog>")].join("\n"),
    },
    {
      title: "Grant USE CATALOG on the deployment catalog",
      detail: "The catalog the app was installed with (--catalog). The app sets up the rest of _metamodel itself.",
      code: `GRANT USE CATALOG ON CATALOG \`<deployment_catalog>\` TO \`${reader}\`;`,
    },
    {
      title: "Let the reader use the SQL warehouse and the model service",
      detail: `CAN USE on the warehouse (or its Permissions tab → Can use), and EXECUTE on the Genie Code model service ${ASSESS_MODEL_SERVICE}.`,
      code: [
        `databricks warehouses update-permissions ${warehouse} --json '{"access_control_list":[{"service_principal_name":"${reader}","permission_level":"CAN_USE"}]}'`,
        `databricks grants update model_service ${ASSESS_MODEL_SERVICE} --json '{"changes":[{"principal":"${reader}","add":["EXECUTE"]}]}'`,
      ].join("\n"),
    },
    {
      title: "Allow github.com egress from serverless jobs",
      detail: "The job downloads the pinned Genie Code and Databricks CLIs from github.com.",
    },
    {
      title: "Paste the reader's Application ID below and Save",
      detail:
        "Or pass it at install time with --assess-reader-sp. Saving uploads the assessment notebook, creates the runs volume and grants the reader access to it and to _metamodel, and creates the vibe-assess job running as the reader.",
    },
  ];
}

/** Letter grades best to worst (no E). */
export const LETTER_ORDER = ["A", "B", "C", "D", "F"] as const;

/** Display labels for the run-level verdict. */
export const VERDICT_LABEL: Record<string, string> = {
  ready_to_build: "Ready to build",
  iterate_first: "Iterate first",
  blocked: "Blocked",
};

/** Structure axis display order (worst first) and labels. */
export const STRUCTURE_RANK: Record<string, number> = { rework: 0, review: 1, sound: 2 };
export const STRUCTURE_LABEL: Record<string, string> = { sound: "Sound", review: "Review", rework: "Rework" };
export const STRUCTURE_CLASS: Record<string, string> = {
  sound: "bg-green-100 text-green-800 border-green-300",
  review: "bg-amber-100 text-amber-800 border-amber-300",
  rework: "bg-red-100 text-red-800 border-red-300",
};

/** Decision label shared with the backend's structure_refs: ordinal is 0-based document order, D-number is ordinal + 1. */
export const decisionLabel = (ordinal: number) => `D${ordinal + 1}`;
/** DOM id of a decision card, targeted by structure-ref jumps. */
export const decisionAnchor = (label: string) => `decision-${label}`;

/**
 * Vibe reference label (same rule as backend): Vibe {priority} if prioritized, else Vibe {sequential_index+1} for unprioritized.
 * Unprioritized vibes are numbered by position because the API returns vibes in the backend's sorted order
 * and the `ordinal` field is not exposed in the API response.
 */
export function vibeRef(vibe: { priority: number | null }, vibes: Array<{ priority: number | null }>): string {
  if (vibe.priority !== null) {
    return `Vibe ${vibe.priority}`;
  }
  // For unprioritized vibes, count prioritized vibes before this one to get a sequential index
  const vibeIndex = vibes.indexOf(vibe);
  const prioritizedCount = vibes.slice(0, vibeIndex).filter((v) => v.priority !== null).length;
  const unprioritizedIndex = vibeIndex - prioritizedCount;
  return `Vibe ${unprioritizedIndex + 1}`;
}

/** Normalize entity name: lowercase, trim, take last dot-segment (e.g., "meter_to_cash.bill" → "bill"). */
function normalizeEntity(name: string): string {
  const trimmed = (name || "").trim().toLowerCase();
  if (!trimmed) return "";
  const lastSegment = trimmed.split(".").pop();
  return lastSegment || "";
}

/** Link structure decisions to vibes based on entity match and explicit mention. */
export interface DecisionVibeLink {
  vibeForDecision: Record<string, string>; // "D1" -> "Vibe 1"
  decisionsForVibe: Record<string, string[]>; // vibe.id -> ["D1", "D2"]
}

export function linkDecisionsToVibes(
  decisions: Array<{ ordinal: number; kind?: string | null; entity?: string | null; affected?: Array<{ entity?: string }> }>,
  vibes: Array<{ id: string; priority: number | null; text?: string; problem?: string; proposed_change?: string; affected_entities?: string[] }>,
): DecisionVibeLink {
  const vibeForDecision: Record<string, string> = {};
  const decisionsForVibe: Record<string, string[]> = {};
  const claimedVibeIds = new Set<string>();

  // Only link structure decisions, process in ordinal order
  const structureDecisions = decisions.filter((d) => d.kind === "structure").sort((a, b) => (a.ordinal ?? 0) - (b.ordinal ?? 0));

  // PASS 1: Resolve explicit D{n} mentions first, mark those vibes as claimed
  structureDecisions.forEach((decision) => {
    const dLabel = decisionLabel(decision.ordinal);

    // Check for explicit mention of D{n} in any vibe
    const mentionedVibeIndex = vibes.findIndex((vibe) => {
      const text = [vibe.text, vibe.problem, vibe.proposed_change].filter(Boolean).join(" ");
      return new RegExp(`\\bD${decision.ordinal + 1}\\b`).test(text);
    });

    if (mentionedVibeIndex >= 0) {
      const selectedVibe = vibes[mentionedVibeIndex];
      const ref = vibeRef(selectedVibe, vibes);
      vibeForDecision[dLabel] = ref;
      claimedVibeIds.add(selectedVibe.id);
      if (!decisionsForVibe[selectedVibe.id]) {
        decisionsForVibe[selectedVibe.id] = [];
      }
      decisionsForVibe[selectedVibe.id].push(dLabel);
    }
  });

  // PASS 2: Entity matching for decisions not yet linked (explicit mention takes precedence)
  structureDecisions.forEach((decision) => {
    const dLabel = decisionLabel(decision.ordinal);

    // Skip if already linked via explicit mention
    if (vibeForDecision[dLabel]) return;

    const decisionEntity = normalizeEntity(decision.entity || "");
    const decisionAffected = new Set(
      (decision.affected || []).map((a) => normalizeEntity(a.entity || "")).filter(Boolean),
    );
    if (decisionEntity) {
      decisionAffected.add(decisionEntity);
    }

    // Score vibes by entity match: first entity match highest, then overlap count
    const vibeScores = vibes.map((vibe) => {
      const vibeEntities = (vibe.affected_entities || []).map(normalizeEntity);

      const firstEntityMatch = vibeEntities[0] === decisionEntity ? 100 : 0;
      const overlapCount = vibeEntities.filter((e) => decisionAffected.has(e)).length;
      const score = firstEntityMatch + overlapCount;

      return { vibe, score, isClaimed: claimedVibeIds.has(vibe.id) };
    });

    // Find best matching vibe: unclaimed preferred, but fall back to claimed if all candidates are claimed
    let bestUnclaimedScore = -1;
    let bestUnclaimedIndex = -1;
    let bestClaimedScore = -1;
    let bestClaimedIndex = -1;

    vibeScores.forEach((s, i) => {
      if (s.score > 0) {
        if (!s.isClaimed && s.score > bestUnclaimedScore) {
          bestUnclaimedScore = s.score;
          bestUnclaimedIndex = i;
        }
        if (s.isClaimed && s.score > bestClaimedScore) {
          bestClaimedScore = s.score;
          bestClaimedIndex = i;
        }
      }
    });

    // Pick unclaimed if available, otherwise pick claimed
    const selectedIndex = bestUnclaimedIndex >= 0 ? bestUnclaimedIndex : bestClaimedIndex;

    if (selectedIndex >= 0) {
      const selectedVibe = vibes[selectedIndex];
      const ref = vibeRef(selectedVibe, vibes);
      vibeForDecision[dLabel] = ref;
      claimedVibeIds.add(selectedVibe.id);
      if (!decisionsForVibe[selectedVibe.id]) {
        decisionsForVibe[selectedVibe.id] = [];
      }
      decisionsForVibe[selectedVibe.id].push(dLabel);
    }
  });

  return { vibeForDecision, decisionsForVibe };
}
