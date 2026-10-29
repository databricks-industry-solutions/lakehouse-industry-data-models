# Model App

AI-assisted data modeling app for Databricks; part of the Databricks industry
data models initiative. It is a Databricks App control plane (React + FastAPI)
for generating, iterating on, and deploying business data models to Unity
Catalog.

## Contents

- [What the app does](#what-the-app-does)
- [Installing in your workspace](#installing-in-your-workspace)
- [What's here](#whats-here)
- [Local development](#local-development)
- [Publishing to GitHub (optional)](#publishing-to-github-optional)
- [Related](#related)

## What the app does

Model Foundry (the app's product name) is a graphical front-end to the Vibe Data
Modeling agent. It takes you from a plain-English description of a business to a
governed, versioned data model deployed to Unity Catalog, iterating in natural
language, with no notebook required.

The app covers modeling and deployment of the model - designing the schema,
iterating on it, and materializing it to Unity Catalog. With the optional bronze
assessment enabled, it also checks an installed model against your own source
(bronze) data and grades how well the sources cover it (see
[step 7](#7-assess-against-your-data-optional)). Building the pipelines that load
your data into the model is a separate process (the `model-genie-skills`
data-integration flow). The assessment can hand its results off to that flow.

![Model Foundry home page](docs/images/app-landing.png)

The home page lays out the loop. Below it, **Jump back in** lists the businesses,
industries and model versions you visited most recently, so you can pick up where
you left off. **Start something new** gives the ways to start a model.

![The modeling loop](docs/images/flow.png)

The workflow strip on the landing page names the loop end to end: **01 Start your
model** (from a template, an import, or a business description) - **02 Review and
give feedback** (navigate the model and give anchored feedback) - **03 Curate
vibes** (pick the inputs for the next run) - **04 Re-run** (the agent produces a
new version) - **05 Review what changed** (see the diff; mark domains reviewed) -
**Publish** (to Unity Catalog).

### 1. Start a model

Start from an industry template, import an existing `model.json`, or describe a
business in your own words. The agent generates a base model (version 1) from that
starting point. For how to write a good business description, see
[Describing a business](docs/Describing-a-business.md).

Every model you bring in is an ECM or an MVM. When it has no schema prefix, the
app gives its own copy the prefix of its scope: ECM schemas are named
`ecm_<domain>` and MVM schemas `mvm_<domain>`, and the metric views `ecm_<view>`
and `mvm_<view>`, so the two scopes of one model can be installed in one catalog.
Your file is not changed, and a model the agent wrote is imported as the agent
wrote it.

If the optional **Domain Taxonomy Builder** is enabled, a wizard uses an LLM to
draft the business's domains and description. You edit the draft before the first
run, and the app checks the domain names against the agent's naming rules.

![Start a new business](docs/images/new-business.png)

### 2. Explore the model

Every version is navigable from several angles. The **diagram** renders the
entity-relationship graph. To keep it readable, the shot below shows a single
domain (`customer`) in **Show keys (PK/FK)** mode: its 15 tables with their
primary and foreign keys and the foreign-key edges between them, colored by table
category (master, transactional, reference, association). The other domains are
hidden.

![Model diagram](docs/images/diagram.png)

The **ontology** view shows the same `customer` domain as a force-directed graph,
in **Intra-Domain Only** scope. Each node is an entity, sized by its foreign-key
count and colored by category, with edges for the relationships between them.

![Ontology view](docs/images/ontology.png)

The **explorer** starts at the all-domains top view. The size panel summarizes the
whole model at a glance - here 18 domains, 61 subdomains, 416 products, 15,002
columns, and 2,458 foreign keys - above a card per domain.

![Explorer - all domains](docs/images/explorer-domains.png)

From there you drill into a single domain - its sub-domains, products (tables),
attributes, primary keys, and foreign keys.

![Explorer](docs/images/explorer.png)

### 3. Review and give anchored feedback

The review surface summarises quality (a computed confidence and quality score,
plus open issues), what changed versus the previous version, and where to focus
next. You mark domains reviewed and attach feedback anchored to specific elements
of the model, rather than losing it in a chat log.

![Review and statistics](docs/images/statistics.png)

To add feedback, navigate to the element you want to change - a domain, a table,
an attribute, or a relationship in the diagram - then open the **Add feedback** box
there. The box names that element in one "About:" line (for example "About:
customer.counterparty", or "About: the whole model" when nothing narrower is in
view), and has a text input for the change you want, a Priority selector, and Save
and Cancel. Feedback is always about the model, never about the view you were on.
Because the feedback is anchored to that element, the agent knows exactly what it
refers to on the next run.

![Adding feedback](docs/images/feedback-box.png)

### 4. Curate the next run's inputs

All feedback is always viewable in the **Feedback** tab. You can add, edit, and
remove feedback at any point in the review, curate, and re-run cycle - not only
before a run.

When you compose the next run, you pick exactly which feedback and agent-suggested
changes go in. Filters at the top of the curate surface narrow the list - for
example by the state of an item, its source, and its priority - so you can focus
the selection. The app compiles what you pick into the instructions the agent will
act on.

![Curate the vibe inputs](docs/images/vibe-compose.png)

### 5. Re-run and see what changed

Runs are launched from the **New Run** screen. You pick the **Operation Type**
(here **Vibe Modeling**), the base version, and the vibe inputs, and for Vibe
Modeling the scope and the run type. You can expand **Advanced Options** to tune
the run - **Organization** (divisions and business domains), **Namespace style**
(the catalog/schema prefix and suffix), and **Naming & format**. A **Compiled
instructions preview** on the right shows exactly what the agent will receive.

![New run](docs/images/new-run.png)

The operation types are:

- **New Base Model** - generate a fresh model (version 1, an ECM and its matching
  MVM) from a business description or template. It needs a business with no model
  versions. It deploys the MVM to Unity Catalog; the ECM is kept with its files and
  can be installed from its page (see the caution below).
- **Vibe Modeling** - apply natural-language feedback to an existing version and
  produce the next version. You choose the scope (**All domains** or **Some
  domains**) and the run type: **Dry Run** (the default) or **Full Run**. A vibe
  keeps the base version's conventions, so the form locks them.
- **Vibe ECM + MVM** - apply feedback to an ECM version and produce a new ECM and
  its matching MVM in one run. It deploys the new MVM, like New Base Model.

Install and uninstall are not run types on this screen. You start them from a
version's page: **Install** (named **Install this Dry Run** for a draft and **Make
this version current** for an older or replaced version) and **Uninstall**.

Each model-producing run produces a new, complete version - the previous one is
never overwritten. The version tree keeps every iteration, and each vibed version
shows a diff against its predecessor: what was added, changed, and removed, and
how much of the model was touched.

![Version diff](docs/images/version-diff.png)

The **Run details** page shows what happened. The example below is a completed
run: the progress bar reads 100% with the elapsed time (hh:mm:ss), **Lineage**
records the source and generated versions (here v1 ECM into v2 ECM), and the
expanded **Phase 1 - vibe_iterate** section lists each step (Setup, Interpreting
Instructions, Logical Schema Generation, QA, Model Finalization, FK Integrity
Gates, Next Vibes Generation).

![Run details](docs/images/run-details.png)

Each step is expandable, so you can focus on the one you care about, and a link
takes you straight to the underlying Databricks job run for the low-level logs. A
run normally takes from a few to many **hours**, depending on the size of the
inputs and the size of the base model.

**Caution: deploying runs can drop this business's schemas in the target
catalog.**

- A Vibe Modeling **Full Run** drops the schemas this business owns in the catalog
  and re-creates them. When its base is the version installed there, it keeps them
  and replaces only the tables the run changes.
- **New Base Model** and **Vibe ECM + MVM** build the ECM, then shrink it to the
  MVM. With One Catalog, the shrink first drops this business's schemas in the
  catalog, the new ECM's included, so the MVM is the version left installed.
- A business kickstarted from an industry shares that industry's schema names. A
  Full Run or install of the business into a catalog where the industry is
  installed under the same names uninstalls the industry version first, and the
  app warns about it before the run starts.

Schemas of other businesses are left as they are. The New Run screen says what the
run drops, and the launch dialog of a Full Run warns before it starts. A Dry Run
creates no schemas or tables. To keep an existing deployment apart, point the run
at an empty catalog, or set the **Namespace style** advanced options (a catalog
prefix and/or suffix) on the New Run screen - these change the target catalog name
so the run lands under a distinct catalog.

### 6. Deploy to Unity Catalog

Steps 2 through 5 are the iterate loop: explore, review, curate, and re-run in
natural language until the model reflects your business. Deploying to Unity Catalog
is the terminal step. A deployed version becomes schemas, tables, foreign keys,
governance tags, and metric views, straight from the app.

![Deploy to Unity Catalog](docs/images/deploy.png)

A **Dry Run** is the default for Vibe Modeling. It builds the new version and its
files but deploys nothing: the result is a draft that is not yet the latest
version, and no feedback is marked as done. Review the draft - the run report lists
what the agent did with each feedback item. When the draft is right, install it with **Install this
Dry Run** on its version page (or **Install this draft** on the run report). The
install creates its tables, makes it the latest version, and marks the feedback it
applied as done. A **Full Run** deploys the new version as part of the run.

New Base Model and Vibe ECM + MVM runs deploy the MVM they produce when they
finish. **Install** deploys an existing version, and **Uninstall** removes a version
from Unity Catalog; both start from the version's page.

Under the hood the agent runs a two-step, LLM-driven process. The base model seeds
the schema from a business context (business info, model conventions, optional vibe
instructions), decomposing Organization into Divisions, Domains, Products (tables),
and Attributes (columns), linking tables, enforcing a DAG constraint on foreign
keys, and running quality checks. Vibe modeling then classifies each natural-language
request into one of three modes - **surgical** (fix specific things, leave the rest
alone), **holistic** (apply a rule everywhere, preserve structure), or **generative**
(create or rebuild parts) - and re-validates through the same quality pipeline. Each
version also carries an RDFS ontology alongside the physical schema.

### 7. Assess against your data (optional)

With the optional in-app bronze assessment enabled, the loop continues after you
deploy. You pick an installed model version and the source (bronze) schemas to
map. For each domain, a Databricks job profiles the sources, maps each model
column to a source column, and grades each entity Full, Partial or Blocked. The
job runs as a read-only service principal.

You then review the scorecard and the gaps, and answer the open decisions in the
app. The assessment also suggests next vibes, which you can add as inputs to your
next run. A hand-off step copies the project to a folder in your workspace, with
ready prompts to continue the work in Genie Code.

## Installing in your workspace

See **[INSTALL.md](INSTALL.md)** for end-to-end install instructions on any
Databricks workspace (AWS or Azure). High-level flow:

```bash
# From this directory (model-app/), on a pre-authenticated CLI profile:
bash install/install.sh \
  --profile      <your-profile> \
  --app-name     vibe-modeling  \
  --project      vibe-modeling  \
  --catalog      vibe_modeling  \
  --warehouse-id <sql-warehouse-id>
```

The installer deploys the bundle, provisions Lakebase, grants the Unity Catalog
privileges the app needs, starts the app, and pushes the built source. It is
idempotent. Lakebase is generally available on both AWS and Azure, so no preview
enrollment is needed.

Two features are optional and off by default. Turn each on with an install flag:

- `--enable-taxonomy-builder` - the Domain Taxonomy Builder. See
  [Enabling the Domain Taxonomy Builder](INSTALL.md#enabling-the-domain-taxonomy-builder-optional).
- `--enable-assessment` - the in-app bronze assessment. See
  [Enabling the in-app bronze assessment skill](INSTALL.md#enabling-the-in-app-bronze-assessment-skill-optional).

Every user granted Databricks Apps access has full access to the app; scope that
access to the users who should use it. See the
[Access model](INSTALL.md#access-model) section of INSTALL.md.

## What's here

| Path | Description |
|------|-------------|
| `src/app/` | The Databricks App: React + FastAPI control plane, built with [`apx`](https://github.com/databricks-solutions/apx) |
| `src/app/src/vibe_modeling/backend/` | FastAPI backend (routes, run orchestration, model export, Unity Catalog integration) |
| `src/app/src/vibe_modeling/ui/` | React + TypeScript frontend and its `__tests__` |
| `src/app/vendored/agent/` | The bundled modeling agent notebook, its naming-rules CSV, `VERSIONS.json` and the agent's registry table columns (`metamodel_registry_schema.json`); the app uploads the notebook to the workspace at boot |
| `src/app/vendored/assessment/` | The bundled bronze assessment: the per-domain job notebook (`assess_domain.py`), its prompt and result schemas, the pinned skills, and `VERSIONS.json` (pinned CLI and skills versions) |
| `install/` | Installer scripts (`install.sh`, Lakebase provisioning, catalog grants, model-service check, build/render) |
| `examples/` | Example model outputs (NCDOT) and a business context input (`examples/maf.json`) |
| `docs/` | Setup guides (GitHub publish, source read access) and [Describing a business](docs/Describing-a-business.md) |
| `tests/test_app/`, `tests/fixtures/` | App backend test suite and its fixtures (no Spark or workspace required) |
| `databricks.yml`, `src/app/app.yml` | Databricks Asset Bundle and App configuration |

## Local development

The app is built with [`apx`](https://github.com/databricks-solutions/apx)
(Python + FastAPI backend, React + shadcn/ui frontend). Setup and the checks
a change must pass are in [CONTRIBUTING.md](CONTRIBUTING.md) ("Running the checks").

## Publishing to GitHub (optional)

The app can publish a model version to a GitHub repository as a pull request.
Publishing removes the schema and metric view prefixes the app added at import, so
the repository keeps the model's own names. This is optional and off by default. See
[docs/github-integration-setup.md](docs/github-integration-setup.md) and the
"Enabling publish-to-GitHub" section of [INSTALL.md](INSTALL.md).

## Related

- **Industry models repository**: [databricks-industry-solutions/lakehouse-industry-data-models](https://github.com/databricks-industry-solutions/lakehouse-industry-data-models)
  - reference industry data models for customers, deployable via Databricks
  Asset Bundles. Models there may be generated and maintained with this app, but
  it is an independent resource.
- **Excel template**: a standardized spreadsheet that auto-generates README,
  JSON, DDL statements, tags, comments, and ontology - a primary input format
  for contributing industry models.
