/**
 * The run-parameters help page: every field of the New Run form's Advanced
 * Options in form order, with its values, its default, the runs that send it
 * and what Install does with it.
 *
 * The value lists are the form's own (`lib/run-options.ts`,
 * `lib/org-divisions.ts`), which `__tests__/run-options.test.ts` pins to the
 * agent's widget lists in `tests/fixtures/agent_widget_options.json`; the
 * help test checks the rendered lists against the same fixture. Agent facts
 * quoted here: its widget reference table (nb 57-90), in particular "in
 * `vibe modeling of version`, the base model's conventions win over widgets
 * 12, 13, 15, 16 and 17 to 21" (nb 88; the keys are `MODEL_CONVENTION_KEYS`,
 * nb 52097-52108) and the retired sample data (nb 89). The lock rule is
 * `_vov_base_conventions_win` (nb 52132-52149): every key on a Some domains
 * run, the keys the base sets otherwise. Schema Suffix and Tag Suffix are not
 * in that list but the agent ignored an edit of both on a live Dry Run, so
 * the server locks them on every vibe (`services/run_defaults.py`). Install and Uninstall carry no run
 * time budget (`core/_widgets.py`). Vibe ECM + MVM sends Schema Prefix as its
 * ECM prefix (`lib/run-defaults.vibeConventionBody`, `_vibe_new_ecm_mvm.py`).
 */
import type { ReactNode } from "react";
import { useGetAgentConfig } from "@/lib/api";
import { HelpPage } from "@/components/help/help-page";
import { P, Section, TopicLink, UL } from "@/components/help/help-prose";
import { andList } from "@/lib/comma-list";
import { ORG_DIVISIONS_PRESETS } from "@/lib/org-divisions";
import {
  BOOLEAN_FORMATS,
  CATALOGING_STYLES,
  DATE_FORMATS,
  NAMING_CONVENTIONS,
  NO_YES,
  TABLE_ID_TYPES,
  TIMESTAMP_FORMATS,
} from "@/lib/run-options";
import { RUNTIME_BUDGET_SETTINGS_HINT, runtimeBudgetBoundsText } from "@/lib/runtime-budget";
import { HISTORY_TRACKING_HINT, HOUSEKEEPING_COLUMNS_HINT } from "@/lib/tracking-columns";

const ALL_THREE = "New Base Model, Vibe Modeling, Vibe ECM + MVM.";
const BASE_WINS = `${ALL_THREE} A vibe pre-fills the base version's value and locks it: the agent keeps the base's value when the base sets one, and always on Some domains.`;
const BASE_ALWAYS = `${ALL_THREE} A vibe pre-fills the base version's value and locks it, whether or not the base sets one: the agent ignores a change to it.`;
const FROM_BASE_RUN = `${ALL_THREE} A vibe pre-fills the value of the run that made the base version; you can change it.`;
const INSTALL_NO = "No.";
const INSTALL_FROM_FILE = (fallback: string) =>
  `No. Install sends ${fallback}. For a Dry Run draft or a scoped version it uses the value saved in the version's model file.`;
export const INSTALL_OWN_PREFIX =
  "No. Install sends the schema prefix saved in its model file, even an empty one. A model you import, download or kickstart from 0.9.0 on gets ecm_ or mvm_, from its scope, when its file has no prefix, so its ECM and MVM do not share schemas; a file the agent wrote keeps its prefix. Installed again into the catalog it is installed in, a version keeps the prefix of that install. A typed Schema Prefix other than the file's is refused: the agent would rename the schemas and drop the metric views.";

/** One row of the page. `widget` names the agent widget the field sets (its list is `values`, when `values` is a list). */
export interface ParameterField {
  label: string;
  group: string;
  widget?: string;
  values: readonly string[] | string;
  defaultValue: string;
  usedBy: string;
  install: string;
  note?: string;
}

/** The Advanced Options fields, in form order. */
export const PARAMETER_FIELDS: readonly ParameterField[] = [
  {
    label: "Organization Divisions",
    group: "Organization",
    widget: "org_divisions",
    values: ORG_DIVISIONS_PRESETS,
    defaultValue:
      "Operations. The first New Base Model starts with the divisions saved for the business. A vibe starts with the divisions of the run that made the base version; when that run did not record them, Vibe Modeling follows the base version's size until you change it: all three divisions for an ECM, Operations for an MVM.",
    usedBy: ALL_THREE,
    install: INSTALL_NO,
  },
  {
    label: "Business Domains",
    group: "Organization",
    values: "Domain names, one per tag.",
    defaultValue: "Empty: the agent picks the domains. The first New Base Model starts with the domains saved for the business.",
    usedBy:
      "New Base Model, Vibe ECM + MVM. Vibe Modeling works on the base version's own domains; on Some domains the scope control sets the domain list it sends.",
    install: INSTALL_NO,
  },
  {
    label: "Catalog Prefix",
    group: "Namespace Style",
    values: "Text.",
    defaultValue: "Empty.",
    usedBy: `${FROM_BASE_RUN} Only with Catalog per Division or Catalog per Domain.`,
    install: INSTALL_NO,
  },
  {
    label: "Catalog Suffix",
    group: "Namespace Style",
    values: "Text.",
    defaultValue: "Empty.",
    usedBy: `${FROM_BASE_RUN} Only with Catalog per Division or Catalog per Domain.`,
    install: INSTALL_NO,
  },
  {
    label: "ECM Schema Prefix and MVM Schema Prefix",
    group: "Namespace Style",
    values: "Text.",
    defaultValue: "ecm_ and mvm_.",
    usedBy:
      "New Base Model, with One Catalog only: they keep the ECM and MVM schemas apart. Vibe ECM + MVM sends the MVM one at its default and takes the ECM one from Schema Prefix.",
    install: INSTALL_OWN_PREFIX,
  },
  {
    label: "Schema Prefix",
    group: "Namespace Style",
    values: "Text.",
    defaultValue: "Empty.",
    usedBy:
      "Vibe Modeling and Vibe ECM + MVM, which sends it as the new ECM's prefix. A vibe pre-fills the base version's prefix and locks it: the agent keeps it when the base has one, and always on Some domains.",
    install: INSTALL_OWN_PREFIX,
  },
  {
    label: "Schema Suffix",
    group: "Namespace Style",
    widget: "schema_suffix",
    values: "Text.",
    defaultValue: "Empty.",
    usedBy: BASE_ALWAYS,
    install: INSTALL_FROM_FILE("no value, so the agent uses its own default"),
  },
  {
    label: "Naming Convention",
    group: "Naming & Format",
    widget: "naming_convention",
    values: NAMING_CONVENTIONS,
    defaultValue: "snake_case.",
    usedBy: BASE_WINS,
    install: INSTALL_FROM_FILE("snake_case"),
  },
  {
    label: "PK Suffix",
    group: "Naming & Format",
    values: "Text. Used for every primary key and foreign key column name.",
    defaultValue: "_id.",
    usedBy: BASE_WINS,
    install: INSTALL_FROM_FILE("_id"),
  },
  {
    label: "Tag Prefix",
    group: "Naming & Format",
    values: "Text.",
    defaultValue: "dbx_.",
    usedBy: BASE_WINS,
    install: INSTALL_FROM_FILE("no value, so the agent uses its own default"),
  },
  {
    label: "Tag Suffix",
    group: "Naming & Format",
    widget: "tag_suffix",
    values: "Text.",
    defaultValue: "Empty.",
    usedBy: BASE_ALWAYS,
    install: INSTALL_NO,
  },
  {
    label: "Table ID Type",
    group: "Data Types",
    widget: "table_id_type",
    values: TABLE_ID_TYPES,
    defaultValue: "BIGINT.",
    usedBy: BASE_WINS,
    install: INSTALL_FROM_FILE("BIGINT"),
    note: "The agent also accepts LONG; the form leaves it out.",
  },
  {
    label: "Boolean Format",
    group: "Data Types",
    widget: "boolean_format",
    values: BOOLEAN_FORMATS,
    defaultValue: "Boolean (True/False).",
    usedBy: BASE_ALWAYS,
    install: INSTALL_NO,
    note: "A base version that sets no boolean format keeps Boolean (True/False): the agent reads an empty one as that.",
  },
  {
    label: "Date Format",
    group: "Data Types",
    widget: "date_format",
    values: DATE_FORMATS,
    defaultValue: "yyyy-MM-dd.",
    usedBy: BASE_WINS,
    install: INSTALL_NO,
  },
  {
    label: "Timestamp Format",
    group: "Data Types",
    widget: "timestamp_format",
    values: TIMESTAMP_FORMATS,
    defaultValue: "yyyy-MM-dd HH:mm:ss.",
    usedBy: BASE_WINS,
    install: INSTALL_NO,
  },
  {
    label: "Housekeeping Columns",
    group: "Tracking & Governance",
    widget: "housekeeping_columns",
    values: NO_YES,
    defaultValue: "No.",
    usedBy: FROM_BASE_RUN,
    install: INSTALL_NO,
    note: HOUSEKEEPING_COLUMNS_HINT,
  },
  {
    label: "History Tracking",
    group: "Tracking & Governance",
    widget: "history_tracking_columns",
    values: NO_YES,
    defaultValue: "No.",
    usedBy: FROM_BASE_RUN,
    install: INSTALL_NO,
    note: HISTORY_TRACKING_HINT,
  },
  {
    label: "Classification Levels",
    group: "Tracking & Governance",
    values: "key=label pairs, for example restricted=restricted.",
    defaultValue: "Empty.",
    usedBy: BASE_WINS,
    install: INSTALL_NO,
  },
];

/**
 * The fields a vibe locks whether or not the base sets them, in form order
 * (backend `services/run_defaults.ALWAYS_LOCKED_FIELDS`; both are pinned to
 * `tests/fixtures/vibe_always_locked_fields.json`).
 */
export const ALWAYS_LOCKED_LABELS: readonly string[] = PARAMETER_FIELDS.filter(
  (f) => f.usedBy === BASE_ALWAYS,
).map((f) => f.label);

function Values({ field }: { field: ParameterField }) {
  if (typeof field.values === "string") return <>{field.values}</>;
  return (
    <ul className="list-disc pl-4" data-testid={field.widget ? `param-values-${field.widget}` : undefined}>
      {field.values.map((v) => (
        <li key={v}>
          <code>{v}</code>
        </li>
      ))}
    </ul>
  );
}

function FieldBlock({ field, children }: { field: ParameterField; children?: ReactNode }) {
  return (
    <div className="space-y-1 rounded-sm border border-border p-3" data-testid="param-field">
      <h3 className="text-sm font-semibold text-foreground">{field.label}</h3>
      <dl className="grid grid-cols-[8rem_1fr] gap-x-3 gap-y-1 text-xs text-muted-foreground">
        <dt className="font-medium text-foreground">Values</dt>
        <dd>
          <Values field={field} />
          {field.note && <p className="mt-1">{field.note}</p>}
        </dd>
        <dt className="font-medium text-foreground">Default</dt>
        <dd>{field.defaultValue}</dd>
        <dt className="font-medium text-foreground">Sent by</dt>
        <dd>{field.usedBy}</dd>
        <dt className="font-medium text-foreground">Install reuses it?</dt>
        <dd>{field.install}</dd>
      </dl>
      {children}
    </div>
  );
}

/** The run time budget row reads its default and bounds from Settings. */
function RuntimeBudgetBlock() {
  const { data: cfg } = useGetAgentConfig({ query: { retry: false, select: (resp) => resp.data } });
  const hours = cfg?.runtime_budget_hours;
  const min = cfg?.runtime_budget_min_hours;
  const max = cfg?.runtime_budget_max_hours;
  const field: ParameterField = {
    label: "Run time budget (hours)",
    group: "Agent",
    values:
      min !== undefined && max !== undefined
        ? runtimeBudgetBoundsText(min, max)
        : "Whole hours, within the bounds Settings shows.",
    defaultValue:
      hours !== undefined
        ? `The Settings default, now ${hours} hours. An admin changes it in Settings.`
        : "The Settings default. An admin changes it in Settings.",
    usedBy: `${ALL_THREE} A run of two agent jobs gives each job the full budget.`,
    install: "No. Install and Uninstall do not use it.",
  };
  return (
    <FieldBlock field={field}>
      <p className="text-xs text-muted-foreground" data-testid="runtime-budget-help">
        {RUNTIME_BUDGET_SETTINGS_HINT} It is a pacing clock: the agent plans its work to fit, and
        it never stops the job when the time is up. Raise it for large models.
      </p>
    </FieldBlock>
  );
}

const GROUP_ORDER = ["Agent", "Organization", "Namespace Style", "Naming & Format", "Data Types", "Tracking & Governance"];

export function RunParametersContent() {
  return (
    <HelpPage
      title="Run parameters"
      intro="The New Run form's Advanced Options, in the order the form shows them: the values each field takes, its default, the runs that send it, and whether Install uses it."
      related={["runs", "run-install", "run-vibe"]}
    >
      <div className="space-y-8">
        <Section heading="Before Advanced Options">
          <ul className={UL}>
            <li>
              Namespace Style: <span data-testid="param-values-cataloging_style">{CATALOGING_STYLES.join(", ")}</span>.
              Default One Catalog: every table lands in the deployment catalog. The other two give
              each division or domain its own catalog, named from the Catalog Prefix and Suffix;
              the catalog field then names the catalog that holds the agent&apos;s registry.
            </li>
            <li>
              Deployment Catalog: where the run creates its schemas and registers the version in
              _metamodel. A Dry Run creates no schemas; it only registers the draft and writes its
              files.
            </li>
          </ul>
        </Section>

        <Section heading="Vibe runs start from the base version">
          <p className={P}>
            On Vibe Modeling and Vibe ECM + MVM, Advanced Options start from the base version: its
            conventions from its model file, and the other options from the run that made it. The
            run time budget and Business Domains keep the form&apos;s values.
          </p>
          <p className={P}>
            The agent keeps the base version&apos;s Naming Convention, PK Suffix, Schema Prefix,
            Tag Prefix, Table ID Type, boolean, date and timestamp formats, and Classification
            Levels, and logs a warning that lists each form value it ignored. The form shows those
            values and locks them: on All domains and Vibe ECM + MVM, the ones the base sets; on
            Some domains, all of them. It locks {andList(ALWAYS_LOCKED_LABELS)} on every vibe,
            whether or not the base sets them: the agent reads an empty boolean format as Boolean
            (True/False), and it ignores a changed Schema Suffix or Tag Suffix. When the app
            can&apos;t read the base version&apos;s file, it locks all of them and sends no value;
            the agent still keeps the base&apos;s.
          </p>
          <p className={P}>
            Vibe ECM + MVM builds the new MVM with the new ECM&apos;s conventions.
          </p>
        </Section>

        <Section heading="What Install sends">
          <p className={P}>
            Install starts from the version&apos;s page and sends only the catalog. It does not
            reuse a run&apos;s Advanced Options. It installs with One Catalog, snake_case, the
            primary key suffix _id, BIGINT ids and the schema prefix saved in its model file. A
            Dry Run draft or a scoped version is installed with the naming
            convention, primary key suffix, schema prefix, schema suffix, tag prefix and table ID
            type saved in its model file, so its tables match the draft you reviewed. See{" "}
            <TopicLink slug="run-install">Install a version</TopicLink>.
          </p>
        </Section>

        {GROUP_ORDER.map((group) => (
          <Section key={group} heading={group}>
            <div className="space-y-3">
              {group === "Agent" && <RuntimeBudgetBlock />}
              {PARAMETER_FIELDS.filter((f) => f.group === group).map((f) => (
                <FieldBlock key={f.label} field={f} />
              ))}
            </div>
          </Section>
        ))}

        <Section heading="Retired">
          <p className={P}>
            Generate Samples is retired. The agent no longer generates sample data, so the form no
            longer offers it.
          </p>
        </Section>
      </div>
    </HelpPage>
  );
}
