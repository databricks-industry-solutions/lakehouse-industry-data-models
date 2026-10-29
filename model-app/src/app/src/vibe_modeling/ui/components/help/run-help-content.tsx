/**
 * The Runs help group: the run-types table and one page per run intent.
 * Each run page has the same four sections (`RUN_PAGE_HEADINGS`) and a
 * Related footer. The copy describes what the app does today; where a rule
 * is the agent's, the code that applies it names the notebook lines.
 */
import type { ReactNode } from "react";
import { HelpPage } from "@/components/help/help-page";
import { HelpTable, OL, P, Section, TopicLink, UL } from "@/components/help/help-prose";
import { ALWAYS_LOCKED_LABELS } from "@/components/help/run-parameters-content";
import { andList } from "@/lib/comma-list";
import { DRY_RUN_CONSEQUENCE } from "@/lib/vibe-scope";
import { MIN_AGENT_MARKER_FOR_SCOPE } from "@/lib/run-options";
import { promotionRuleText } from "@/lib/version-lifecycle";
import { useRunChangeReviewEnabled } from "@/lib/features";

export const RUN_PAGE_HEADINGS = [
  "What it does",
  "How it works",
  "What it needs",
  "What it changes in your deployment",
] as const;

function RunPage({
  title,
  intro,
  related,
  does,
  works,
  needs,
  changes,
}: {
  title: string;
  intro: string;
  related: string[];
  does: ReactNode;
  works: ReactNode;
  needs: ReactNode;
  changes: ReactNode;
}) {
  const [h1, h2, h3, h4] = RUN_PAGE_HEADINGS;
  return (
    <HelpPage title={title} intro={intro} related={related}>
      <div className="space-y-8">
        <Section heading={h1}>{does}</Section>
        <Section heading={h2}>{works}</Section>
        <Section heading={h3}>{needs}</Section>
        <Section heading={h4}>{changes}</Section>
      </div>
    </HelpPage>
  );
}

/** One row per run intent (`backend/models.py` `Intent`), plus Delete version. */
export const RUN_TYPE_ROWS: readonly {
  run: string;
  model: string;
  catalog: string;
  needs: string;
  slug: string;
}[] = [
  {
    run: "New Base Model",
    model: "Yes. Adds the first ECM and MVM versions.",
    catalog: "Yes. Creates the schemas and tables of both, and registers both in _metamodel. With One Catalog only the MVM stays installed: its step drops the ECM's schemas.",
    needs: "A business with no versions and a business description.",
    slug: "run-new-base-model",
  },
  {
    run: "Vibe Modeling, Dry Run (All or Some domains)",
    model: "Yes. Adds a draft version. The latest version stays as it is.",
    catalog: "No schemas or tables. Registers the draft in _metamodel and writes its files to the volume.",
    needs: "A base version and selected feedback.",
    slug: "run-vibe",
  },
  {
    run: "Vibe Modeling, Full Run (All or Some domains)",
    model: "Yes. Adds a version that becomes the latest.",
    catalog: "Yes. Deploys the new version to the deployment catalog and registers it in _metamodel.",
    needs: "A base version and selected feedback. Some domains needs the latest version as the base.",
    slug: "run-vibe",
  },
  {
    run: "Vibe ECM + MVM",
    model: "Yes. Adds a new ECM and a new MVM shrunk from it.",
    catalog: "Yes. Creates the schemas and tables of both. With One Catalog only the new MVM stays installed: its step drops the new ECM's schemas.",
    needs: "An ECM version and selected feedback.",
    slug: "run-vibe-ecm-mvm",
  },
  {
    run: "Install",
    model: "Only which version is the latest: a Dry Run draft always becomes the latest, an older version only in the catalog the latest is installed in.",
    catalog: "Yes. Creates the version's schemas and tables. Over another version, uninstalls it first.",
    needs: "A finished version or a Dry Run draft, and a catalog.",
    slug: "run-install",
  },
  {
    run: "Uninstall",
    model: "No. The version stays in the app.",
    catalog: "Yes. Drops the version's schemas and every table in them, and the catalog's shared _metrics schema.",
    needs: "An installed version.",
    slug: "run-uninstall",
  },
  {
    run: "Delete version",
    model: "Yes. Removes the version for good.",
    catalog: "Removes the version's rows from the agent's _metamodel registry. No model tables.",
    needs: "A version that is not installed. A finished version also needs its newer versions deleted first.",
    slug: "run-delete-version",
  },
  {
    run: "Import",
    model: "Yes. Adds a version, or a new business with its first version.",
    catalog: "No schemas or tables. Writes the version's registry rows to _metamodel of the installation catalog.",
    needs: "A model.json in a Unity Catalog volume.",
    slug: "import",
  },
  {
    run: "Revert",
    model: "Retired. The app no longer starts it.",
    catalog: "No. Install the older version instead.",
    needs: "Nothing.",
    slug: "runs",
  },
  {
    run: "Generate Samples",
    model: "Retired. The app no longer starts it.",
    catalog: "No.",
    needs: "Nothing.",
    slug: "runs",
  },
];

export function RunsContent() {
  return (
    <HelpPage
      title="Run types and what they change"
      intro="A run sends a job to the modeling agent. This table lists every kind of run: whether it changes the model in the app, whether it changes Unity Catalog, and what it needs before it can start."
      related={["run-parameters", "vibes", "flow"]}
    >
      <div className="space-y-8">
        <HelpTable
          label="Run types"
          columns={["Run", "Changes the model?", "Changes Unity Catalog?", "Needs", "More"]}
          rows={RUN_TYPE_ROWS.map((r) => [
            r.run,
            r.model,
            r.catalog,
            r.needs,
            r.slug === "runs" ? "" : (
              <TopicLink slug={r.slug} label={`Read more about ${r.run}`}>
                Read more
              </TopicLink>
            ),
          ])}
        />
        <Section heading="Where each run starts">
          <ul className={UL}>
            <li>New Base Model, Vibe Modeling and Vibe ECM + MVM: the New Run form of a business.</li>
            <li>Install, Uninstall and Delete: the page of the version they act on.</li>
            <li>Import: Import a model on the home page, or Import pre-vibed model on a business.</li>
            <li>Delete version is not a run: it changes the app at once and starts no job.</li>
          </ul>
        </Section>
      </div>
    </HelpPage>
  );
}

export function RunNewBaseModelContent() {
  return (
    <RunPage
      title="New Base Model"
      intro="The first run of a business. It builds a model from your description of the business."
      related={["run-parameters", "run-vibe", "runs"]}
      does={
        <p className={P}>
          It generates an Expanded Coverage Model (ECM) from your business description, then
          shrinks it to a Minimum Viable Model (MVM). Both become the first version of their
          scope, and both are installed.
        </p>
      }
      works={
        <ol className={OL}>
          <li>
            Describe the business in Business Context, or give the path of a model file in a
            volume.
          </li>
          <li>
            Add Run Instructions if you have hard constraints. The agent reads them after the
            description. The description is kept for later runs; the instructions are for this run
            only.
          </li>
          <li>
            Under Advanced Options, Business Domains and Organization Divisions seed the domains
            the agent builds. The first run starts with the domains and divisions saved for
            the business, for example by the Domain Taxonomy Builder.
          </li>
          <li>
            The run is two agent jobs: the first builds the ECM, the second shrinks it to the MVM.
            Each job gets the full run time budget.
          </li>
        </ol>
      }
      needs={
        <ul className={UL}>
          <li>A business with no model versions. To start over, create a new business.</li>
          <li>A business description.</li>
          <li>A deployment catalog the app can create schemas in.</li>
        </ul>
      }
      changes={
        <p className={P}>
          It creates the schemas and tables of the ECM, then of the MVM, and registers both
          versions in the _metamodel schema and writes their files to its volume. With One
          Catalog, the shrink to the MVM first drops this business&apos;s schemas in the
          deployment catalog, the new ECM&apos;s included: the MVM is the version left installed,
          the ECM stays registered with its files, and installing it brings its tables back. With
          Catalog per Division or Catalog per Domain, the catalog names come from the Catalog
          Prefix and Catalog Suffix; both models use the same schema names, so the MVM
          overwrites the ECM&apos;s tables and the ECM is recorded as uninstalled too.
        </p>
      }
    />
  );
}

const FULL_RUN_ROLLBACK =
  "After a Full Run: uninstall the new version if it is installed, delete any newer versions, then delete it. " +
  "The base becomes the latest version again; install it to restore its tables. The feedback the run applied is open again.";
const DRY_RUN_ROLLBACK = "After a Dry Run: delete the draft. Nothing was installed, and the base stays the latest version.";

/** "After the run" of the vibe page while the run change review is off. */
function AfterTheRun() {
  return (
    <>
      <p className={P}>
        <span className="font-medium text-foreground">After the run.</span> The run report
        lists what the agent did with each feedback item. To undo the whole run:
      </p>
      <ul className={UL}>
        <li>{FULL_RUN_ROLLBACK}</li>
        <li>{DRY_RUN_ROLLBACK}</li>
      </ul>
    </>
  );
}

/** "After the run" of the vibe page while the run change review is on: the Changes card too. */
function AfterTheRunWithChangeReview() {
  return (
    <>
      <p className={P}>
        <span className="font-medium text-foreground">After the run.</span> The run report
        lists what the agent did with each feedback item. The Changes card lists the domains,
        products and attributes added or removed, and changes to an attribute&apos;s type,
        foreign key or description. It does not show changes to tags, glossary terms, value
        patterns, primary keys, table or column names, or product and domain descriptions. A
        rename shows as a removal and an addition. Each change has a hint: Asked, Not asked,
        Outside the run&apos;s scope, or Unclear.
        The hint is a guess: a request anchored on a domain counts every change in that domain
        as asked.
      </p>
      <ul className={UL}>
        <li>Accept or reject each change. Accept all asked accepts every change hinted Asked.</li>
        <li>
          Add rejected as feedback turns each rejected change into a feedback item, anchored on
          the changed element. It is not selected; select it for the next run.
        </li>
        <li>
          Your decisions are final once a newer model run starts from this version.
        </li>
        <li>To undo the whole run, follow the roll back steps at the foot of the card. {FULL_RUN_ROLLBACK}</li>
        <li>{DRY_RUN_ROLLBACK}</li>
        <li>
          Either way, the open &quot;Rejected change&quot; feedback items made from the new
          version are deleted with it.
        </li>
      </ul>
    </>
  );
}

export function RunVibeContent() {
  const reviewEnabled = useRunChangeReviewEnabled();
  return (
    <RunPage
      title="Vibe Modeling"
      intro="Change a model version from your feedback. The run builds a new version; the version it starts from stays as it is."
      related={["vibes", "run-install", "run-delete-version", "run-parameters"]}
      does={
        <p className={P}>
          It sends the feedback you selected to the agent, which applies it to a base version and
          writes a new version. The new version keeps the base's size: an ECM stays an ECM and an
          MVM stays an MVM.
        </p>
      }
      works={
        <div className="space-y-3">
          <p className={P}>
            <span className="font-medium text-foreground">Scope.</span> All domains lets the agent
            change any domain. Some domains asks it to change only the domains you tick. Items
            anchored in other domains, and items about the whole model, are not sent.
          </p>
          <p className={P}>
            <span className="font-medium text-foreground">Scope from your feedback.</span> When you
            click Start run on the compose surface, the form opens on Some domains with the domains
            of the selected feedback ticked, and says so above the scope. When they cover every
            domain, it opens on All domains. A note says how many selected items are about the
            whole model and are left out of a scoped run. When the base is not the latest version,
            the form opens on All domains, because scoped runs need the latest version. On All
            domains, a "Scope to ..." link offers the domains the selection fits in.
          </p>
          <p className={P}>
            <span className="font-medium text-foreground">Conventions.</span> Advanced Options
            start from the base version: its naming, key, prefix, type and format conventions, and
            the other options of the run that made it. The agent keeps the base&apos;s naming
            convention, PK suffix, schema prefix, tag prefix, table ID type, boolean, date and
            timestamp formats and classification levels, so the form locks them. On All domains
            it locks only the ones the base sets; on Some domains it locks all of them. It locks{" "}
            {andList(ALWAYS_LOCKED_LABELS)} on every vibe: the agent reads an empty boolean format
            as Boolean (True/False), and it ignores a changed schema suffix or tag suffix. Your
            changes to the other options are sent. See{" "}
            <TopicLink slug="run-parameters">Run parameters</TopicLink>.
          </p>
          <p className={P}>
            <span className="font-medium text-foreground">Run type.</span> Dry Run is the default,
            for either scope. {DRY_RUN_CONSEQUENCE} A Full Run deploys the new version to the
            deployment catalog and makes it the latest.
          </p>
          <p className={P}>
            <span className="font-medium text-foreground">Dry Run, then install.</span> Review the
            draft. When it is right, click Install this draft on the run report, or Install this
            Dry Run on the version page. The install creates its tables, makes it the latest
            version and marks the feedback it applied done. When versions newer than the
            draft&apos;s base exist, the install replaces them, and the dialog asks you to confirm
            that first.
          </p>
          {reviewEnabled ? <AfterTheRunWithChangeReview /> : <AfterTheRun />}
        </div>
      }
      needs={
        <ul className={UL}>
          <li>A finished base version.</li>
          <li>At least one selected feedback item.</li>
          <li>
            Some domains and Dry Run need agent {MIN_AGENT_MARKER_FOR_SCOPE} or later. With an older
            agent the form offers only All domains and Full Run.
          </li>
          <li>
            Some domains needs the latest version as its base. It also waits until every newer
            Dry Run draft, and every newer replaced version still in the agent&apos;s registry in
            the run&apos;s catalog, is deleted: the agent refuses a scoped run on a base older
            than the newest version there. A replaced version the app uninstalled from that
            catalog, as Make this version current does, is released from the registry and does
            not block. The form names the ones that block and offers to delete them.
          </li>
        </ul>
      }
      changes={
        <ul className={UL}>
          <li>
            Dry Run: no schemas or tables. The agent registers the draft in the _metamodel schema
            of the deployment catalog and writes its files, model.json and the table DDL, to the
            _metamodel volume.
          </li>
          <li>
            Full Run: the new version is deployed to the deployment catalog. With Some domains, the
            agent is asked to change only those domains, but it can still change tables in other
            domains. A table whose structure changes may be replaced and lose its rows. With All
            domains, if the base is not the version installed there, the agent drops and rebuilds
            every schema this business owns. The agent also registers the version in _metamodel
            and writes its files to the volume.
          </li>
        </ul>
      }
    />
  );
}

export function RunVibeEcmMvmContent() {
  return (
    <RunPage
      title="Vibe ECM + MVM"
      intro="Change an ECM from your feedback, then shrink the result to a new MVM, in one run."
      related={["run-vibe", "run-new-base-model", "run-parameters"]}
      does={
        <p className={P}>
          It applies the selected feedback to an ECM version and writes a new ECM. Then it shrinks
          the new ECM to a new MVM, as a New Base Model does.
        </p>
      }
      works={
        <ul className={UL}>
          <li>Pick the ECM version to change. The form uses the same feedback as Vibe Modeling.</li>
          <li>The run always covers all domains and is always a Full Run.</li>
          <li>
            Advanced Options start from the base ECM and lock the conventions it sets, as on
            Vibe Modeling. Schema Prefix is the new ECM&apos;s prefix. The new MVM takes the new
            ECM&apos;s conventions; its schema prefix is mvm_.
          </li>
          <li>
            Business Domains and Organization Divisions under Advanced Options seed the domains of
            the new model.
          </li>
          <li>The run is two agent jobs, each with the full run time budget.</li>
        </ul>
      }
      needs={
        <ul className={UL}>
          <li>A finished ECM version. An MVM can&apos;t be the base.</li>
          <li>At least one selected feedback item.</li>
        </ul>
      }
      changes={
        <p className={P}>
          It creates the schemas and tables of the new ECM, then of the new MVM, in the deployment
          catalog, registers both in the _metamodel schema and writes their files to its volume.
          With One Catalog, the shrink to the MVM first drops this business&apos;s schemas in the
          catalog, the new ECM&apos;s included: the ECM stays registered with its files, and
          installing it brings its tables back.
        </p>
      }
    />
  );
}

export function RunInstallContent() {
  return (
    <RunPage
      title="Install a version"
      intro="Create a version's schemas and tables in a catalog. You start it from the version's page."
      related={["run-uninstall", "run-delete-version", "run-parameters", "runs"]}
      does={
        <p className={P}>
          It creates the version&apos;s schemas and tables in the catalog you pick. The button reads
          Install, Re-install, Install this Dry Run for a draft, or Make this version current for
          an older or replaced version.
        </p>
      }
      works={
        <div className="space-y-3">
          <p className={P}>
            The dialog starts on the catalog the version is installed in, else the catalog its
            files are in. It checks the install before you start it and asks you to confirm each
            thing that changes more than the version itself:
          </p>
          <ul className={UL}>
            <li>
              <span className="font-medium text-foreground">The catalog holds another version.</span>{" "}
              To install there, the app first uninstalls that version, then installs yours in full.
              Every table of this model in the catalog is recreated and loses its rows. If the
              install fails after the uninstall, the catalog is left without this model until you
              install a version again. When those tables hold data, you type the catalog name to
              confirm. To keep the catalog as it is, click Pick another catalog and install there
              instead.
            </li>
            <li>
              <span className="font-medium text-foreground">The version is older than the latest.</span>{" "}
              {promotionRuleText("an older or replaced version")} In any other catalog it is a
              plain install and the latest version stays. When it becomes the latest, it replaces
              the newer versions, and their changes that are not in your version are dropped. The feedback
              applied in them is reopened, but not selected: Select these on the run report selects
              it again. You can also ask to delete the replaced versions after the install.
            </li>
            <li>
              <span className="font-medium text-foreground">The schemas are not this business&apos;s.</span>{" "}
              This covers schemas another business owns and schemas no business recorded. The
              dialog names each one. If you confirm, the agent replaces this model&apos;s tables in
              them (CREATE OR REPLACE TABLE), so their rows are lost, or it refuses the install.
              For a scoped version the app refuses the install, because the agent refuses it.
            </li>
          </ul>
          <p className={P}>
            When the version is also installed in other catalogs, the dialog says it stays
            installed there.
          </p>
          <p className={P}>
            Making a version current uninstalls the newer version installed in that catalog
            first, and the app releases its rows in the agent&apos;s registry there, so it does not
            block a scoped run on the version you made current. A newer Dry Run draft, or a newer
            replaced version still in the registry of the run&apos;s catalog (still installed
            there, or its release failed), blocks it until it is deleted. Versions with a lower
            number do not block it.
          </p>
          <p className={P}>
            Install does not reuse the New Run form&apos;s Advanced Options. See{" "}
            <TopicLink slug="run-parameters">Run parameters</TopicLink> for what it sends.
          </p>
        </div>
      }
      needs={
        <ul className={UL}>
          <li>A finished version or a Dry Run draft.</li>
          <li>A catalog. With none picked, the app installs into the configured catalog.</li>
          <li>Every confirmation the dialog asks for.</li>
        </ul>
      }
      changes={
        <ul className={UL}>
          <li>Creates the version&apos;s schemas and tables in the catalog.</li>
          <li>Over another version: drops that version&apos;s tables first, with their rows.</li>
          <li>
            When it becomes the latest: replaces the newer versions and reopens the feedback
            applied in them.
          </li>
          <li>A Dry Run draft: makes it the latest and marks the feedback it applied done.</li>
          <li>Registers the install in the _metamodel schema of the catalog.</li>
        </ul>
      }
    />
  );
}

export function RunUninstallContent() {
  return (
    <RunPage
      title="Uninstall a version"
      intro="Drop a version's schemas and tables from a catalog. You start it from the version's page."
      related={["run-install", "run-delete-version", "runs"]}
      does={
        <p className={P}>
          It drops the version&apos;s schemas and every table in them from the catalog. The version
          stays in the app, and you can install it again.
        </p>
      }
      works={
        <ul className={UL}>
          <li>When the version is installed in more than one catalog, pick the one to uninstall from.</li>
          <li>
            The dialog shows the schemas and tables the uninstall drops and whether they hold rows.
          </li>
          <li>
            When the tables hold data, or could not be checked, you type the catalog name to
            confirm.
          </li>
          <li>
            When the agent cannot drop a schema, the run still finishes and the version is marked
            uninstalled. The run page warns and names the schemas still there; their owner, or
            someone with the right privileges, can drop them.
          </li>
        </ul>
      }
      needs={<p className={P}>A version installed in the catalog.</p>}
      changes={
        <p className={P}>
          Drops the version&apos;s schemas and every table in them, with their rows. It also drops
          the catalog&apos;s shared _metrics schema, which holds the metric views of every model
          installed in that catalog; the dialog names the other models that lose theirs. The
          agent keeps the version&apos;s rows in its registry.
        </p>
      }
    />
  );
}

export function RunDeleteVersionContent() {
  return (
    <RunPage
      title="Delete a version"
      intro="Remove a version from the app for good. You start it from the version's page."
      related={["run-uninstall", "run-install", "runs"]}
      does={
        <p className={P}>
          It deletes the version with its domains, products, attributes, relationships and
          artifacts, and its rows in the agent&apos;s registry. It is permanent. The agent reuses
          the version number for the next run.
        </p>
      }
      works={
        <ul className={UL}>
          <li>Versions are deleted one by one, the newest first.</li>
          <li>
            An installed version can&apos;t be deleted. Uninstall it first; the page links to
            Uninstall.
          </li>
          <li>
            A finished version (the latest, or an older one that was not replaced) can&apos;t be
            deleted while newer finished versions sit above it. Delete those first.
          </li>
          <li>Replaced versions and Dry Run drafts can be deleted at any time.</li>
          <li>
            Deleting the latest version makes the newest older version the latest again, unless it
            was replaced.
          </li>
          <li>The feedback the version applied becomes open again.</li>
          <li>
            When removing the registry rows from a catalog fails, the business page lists it with
            Retry cleanup. Until it is done, the next run on that scope there would fail.
          </li>
        </ul>
      }
      needs={
        <ul className={UL}>
          <li>A version that is not installed anywhere.</li>
          <li>For a finished version that was not replaced: no newer finished version above it.</li>
          <li>No run in progress for the business.</li>
        </ul>
      }
      changes={
        <p className={P}>
          No tables: the version is not installed. The agent&apos;s registry rows for the version
          are removed from each catalog it was recorded in.
        </p>
      }
    />
  );
}

export function ImportContent() {
  return (
    <RunPage
      title="Importing an existing model"
      intro="Bring a model the agent built outside the app into it, from a model.json in a Unity Catalog volume."
      related={["run-install", "runs"]}
      does={
        <p className={P}>
          It reads a model.json and adds it to the app: as a new business with its first version,
          or as a new version of a business you already have. It runs no agent job.
        </p>
      }
      works={
        <div className="space-y-3">
          <ul className={UL}>
            <li>
              A new business: Import a model on the home page. Give the volume path, click
              Analyze, check the business details, then Create business and import.
            </li>
            <li>
              A new version: Import pre-vibed model on a business. Give the path, click Analyze,
              then Import as new version. When the file&apos;s business details differ from the
              business, the dialog lists the differences, and you can import anyway.
            </li>
            <li>
              Versions the agent wrote outside the app, for example from a job started by hand,
              show in a banner on the businesses list and the business page. Import adds them;
              Dismiss hides them.
            </li>
          </ul>
          <p className={P}>
            Analyze counts the domains, products, attributes and relationships, and lists the files
            next to the model. It warns when there is no next-vibes file.
          </p>
        </div>
      }
      needs={
        <ul className={UL}>
          <li>
            A model.json in a volume, with a <code>domains</code> list at the top or under{" "}
            <code>model</code>.
          </li>
          <li>For a new business: a business name in the file, and no business with that name.</li>
        </ul>
      }
      changes={
        <p className={P}>
          No schemas or tables are created. The import writes the version&apos;s registry rows to
          the _metamodel schema of the installation catalog, so the agent can use it as a base.
          The version is not installed: install it from its page to create its tables.
        </p>
      }
    />
  );
}
