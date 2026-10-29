# Installing Vibe Data Modeling

Install the Vibe Data Modeling app on a Databricks workspace (AWS or Azure). End-to-end time: **~10 minutes**.

The canonical install path is [`install/install.sh`](install/install.sh). It runs `bundle deploy`, provisions Lakebase, grants Unity Catalog privileges, starts the app, and pushes the built source. It is idempotent, so it is safe to re-run.

## Quick install

Once the prerequisites below are in place:

```bash
git clone https://github.com/databricks-industry-solutions/lakehouse-industry-data-models.git
cd lakehouse-industry-data-models/model-app

bash install/install.sh \
  --profile        my-workspace      \
  --app-name       vibe-modeling     \
  --project        vibe-modeling     \
  --catalog        vibe_modeling     \
  --warehouse-id   <sql-warehouse-id>
```

Substitute your CLI profile name and SQL warehouse ID. Skip `--warehouse-id` to choose the warehouse in Settings after the app starts.

Every flag is listed in [Parameter reference](#parameter-reference). A re-run keeps the values of the previous install, so pass only what you change.

## Privileges required

Pick **one** of the two paths below.

### Path A: Workspace Admin (simplest)

Workspace Admin on the target workspace covers every grant the installer needs by default. No extra setup. **Recommended for first installs.**

### Path B: Non-admin grant matrix

If you install as a non-admin identity, you need **all** of the following on the target workspace:

- **Create Databricks Apps:** [AWS](https://docs.databricks.com/aws/en/dev-tools/databricks-apps/get-started) · [Azure](https://learn.microsoft.com/en-us/azure/databricks/dev-tools/databricks-apps/get-started)
- **Create Lakebase Postgres projects:** [AWS](https://docs.databricks.com/aws/en/oltp/projects/get-started) · [Azure](https://learn.microsoft.com/en-us/azure/databricks/oltp/projects/get-started)
- **Deploy Databricks Asset Bundles** to your `/Workspace/Users/<you>` tree: [AWS](https://docs.databricks.com/aws/en/dev-tools/bundles/) · [Azure](https://learn.microsoft.com/en-us/azure/databricks/dev-tools/bundles/)
- **Grant authority on the target Unity Catalog.** `install/install.sh` issues these grants automatically to the new App service principal:
  - `USE CATALOG`, `CREATE SCHEMA`, `BROWSE` on the catalog passed via `--catalog`. `BROWSE` lets the modeling agent check whether the `_metrics` schema exists by reading catalog metadata.
  - On the `_metamodel` schema in that catalog, on every install: the installer creates the schema and its `vol_root` volume if absent, then grants `USE SCHEMA`, `CREATE TABLE`, `MODIFY`, `SELECT`, `READ VOLUME`, `WRITE VOLUME`, `CREATE VOLUME` and `MANAGE`. The `*_VOLUME` privileges cascade to current and future volumes. `CREATE VOLUME` and `MANAGE` are granted whether or not you enable the bronze assessment.

  To issue those, the installer's identity needs one of: **catalog ownership**, **`MANAGE` on the catalog**, or **metastore-admin**.
- **Permission to create UC catalogs** if `--catalog` points at one that doesn't exist yet: [AWS](https://docs.databricks.com/aws/en/catalogs/create-catalog) · [Azure](https://learn.microsoft.com/en-us/azure/databricks/catalogs/create-catalog).

If your identity lacks grant authority on the catalog, `install/install.sh` **logs the equivalent SQL to stdout and continues**. The install finishes, but a privileged user must run those `GRANT` statements before the app can use the catalog. See [App SP catalog privileges](#app-sp-catalog-privileges) below for the canonical SQL.

## Prerequisites

### On your machine

| Tool | Min version | Purpose |
|------|-------------|---------|
| **Databricks CLI** | 1.20.0+ | Bundle plan and deploy (the installer applies the exact plan it checked, with `bundle deploy --plan`, and refuses an older CLI), app lifecycle, current-user lookup. [Install](https://docs.databricks.com/aws/en/dev-tools/cli/install) |
| **Python** | 3.11+ | Runs `provision_lakebase.py` and `grant_catalog.py` |
| **apx** | latest | Builds the app artifacts (`apx build`, driven by the bundle artifacts hook); orchestrates bun + uv. [apx](https://github.com/databricks-solutions/apx) |
| **Bun** | 1.2+ | Frontend build (via `apx build`). [bun.sh](https://bun.sh) |
| **uv** | latest | Python build for the wheel artifact (via `apx build`). [uv](https://github.com/astral-sh/uv) |
| **jq** | 1.6+ | `install.sh` parses CLI JSON output (SP UUID, current user, app status) |
| **curl** | any | In-flight runs guard and post-install verification |
| **git** | latest | Clone the repo |

`install.sh` verifies these at step `[0/5]`: it aborts if any of `databricks`, `python`, `jq`, `curl`, `apx`, `uv`, or `bun` is missing from PATH, refuses a Databricks CLI below 1.20.0, and warns (does not block) if Python is below its minimum.

> **Node.js is not required to install.** The frontend is built with Bun (via `apx build`), so a fresh install needs only the tools above. Node.js and npm are needed only to *develop* the frontend. See [CONTRIBUTING.md](CONTRIBUTING.md).

Install the Python packages the install scripts import:

```bash
python -m pip install 'databricks-sdk>=0.74' 'psycopg[binary]'
```

`install.sh` fails fast at step `[0/5]` if `databricks-sdk` or `psycopg` is not importable in the active Python env.

### SQL warehouse

The app reads its run progress through a SQL warehouse. **Provision a SQL warehouse before installing**, then either:

- Pass its ID with `--warehouse-id`, **or**
- Skip `--warehouse-id` and pick the warehouse in the app's Settings after it starts.

Serverless SQL warehouses are recommended: the app issues short, frequent statements and benefits from cold-start avoidance.

### Cloud and workspace

- **Lakebase is generally available on both AWS and Azure.** No preview enrollment required.
- The modeling agent notebook is **bundled inside the app wheel** (`src/app/vendored/agent/`, shipped in this repo). The app uploads it to `/Users/<app-sp>/vibe-modelling-agent/` on first boot and creates its persistent Databricks job (`dbx_vibe_modelling`, tagged `managed_by=vibe_modeling_app`). No manual notebook import.

> **Metastores that use Default Storage:** if the target metastore uses Default Storage (no metastore-level storage root), the installer cannot create the UC catalog via API/CLI. Catalog creation there is UI-only and requires metastore-admin rights. Create the catalog through the workspace UI (or ask a workspace/metastore admin) with the same name as your `--catalog` value (default: the app name with `-` as `_`, `vibe_modeling` for the default app), in the same region as the workspace, then re-run the installer or `python install/grant_catalog.py --profile <p> --catalog <name> --app-sp <sp>` to apply the grants. The app starts without the catalog, and the installer's post-install check warns until it exists.

## Parameter reference

All flags below are accepted by [`install/install.sh`](install/install.sh). The order matches the script's `usage` block. The defaults apply to the first install of an app; for an app that exists, the installer reads every value from the running app and a flag changes it (see [Re-running the installer](#re-running-the-installer)). The environment variable each flag sets is in the table under [Deploying without `install.sh`](#deploying-without-installsh).

| Flag | Required | Default | What it controls | When to override |
|------|----------|---------|------------------|------------------|
| `--profile <name>` | no | _(CLI default auth)_ | Databricks CLI profile name (must be pre-authenticated with `databricks auth login --profile <name>`). Drives every `databricks` CLI call and Python install step inside `install.sh`. Without it, the CLI and SDK use their default authentication (the `DEFAULT` profile or `DATABRICKS_*` environment variables). | Pass it whenever your default authentication does not point at the target workspace. |
| `--app-name <name>` | no | `vibe-modeling` | Databricks App resource name shown in the workspace **Apps** UI. The bundle deploys the App under this name; the App's service principal is bound to this name's lifecycle. Each app name has its own bundle folder, `/Workspace/Users/<you>/.bundle/vibe-modeling/<app-name>`, and its own deployment state. | Use another name (e.g. `vibe-modeling-staging`) to install a second app next to an existing one; see [Installing a second app next to an existing one](#installing-a-second-app-next-to-an-existing-one). |
| `--project <id>` | no | _(the app name)_ | Lakebase project ID. Must be unique in the workspace. The installer creates the project, its compute endpoint, and a database whose name matches `--catalog`. | If the default name is taken (or recently deleted: the name is locked for ~2 hours after delete), pick another. |
| `--catalog <name>` | no | _(the app name with `-` as `_`, `vibe_modeling` for the default app)_ | Unity Catalog name AND Postgres database name. Underscores, not hyphens. The app uses this catalog for the agent's `_metamodel.*` artifacts (Delta tables, the `vol_root` volume) and the same name for its Lakebase Postgres state DB. The installer creates the catalog if absent (**not possible on a metastore that uses Default Storage**: create the catalog via the workspace UI first, see the note under [Cloud and workspace](#cloud-and-workspace)), creates the `_metamodel` schema and its `vol_root` volume if absent, and grants the App SP the privileges listed in [App SP catalog privileges](#app-sp-catalog-privileges). | Override if your workspace governance reserves catalog naming, or if you want a non-default isolation domain for the agent's artifacts. |
| `--database <name>` | no | _(the `--catalog` value)_ | Postgres database name in the Lakebase project, when it differs from `--catalog`. On an existing app whose database differs from its catalog, `--catalog` alone keeps the app's database (the installer says so); pass `--database` to change it. An empty name is a usage error. | Pass for an install whose database name is not its catalog name. |
| `--warehouse-id <id>` | no | _(unset)_ | SQL warehouse ID the app uses to read run progress. | Pass at install time to skip choosing the warehouse in Settings. |
| `--enable-taxonomy-builder` | no | _(off)_ | Installs the optional Domain Taxonomy Builder (an LLM-assisted wizard that drafts a business's domains and description) and runs a read-only check that the App SP can use the model service. See [Enabling the Domain Taxonomy Builder](#enabling-the-domain-taxonomy-builder-optional). | Pass to turn the feature on. Omit and the feature stays off; the rest of the app does not depend on it. |
| `--disable-taxonomy-builder` | no | - | Turns off a Domain Taxonomy Builder that a previous install turned on. | Pass to turn the feature off on a re-run. Can't be combined with `--enable-taxonomy-builder`. |
| `--taxonomy-model-service <catalog.schema.service>` | no | `system.ai.claude-sonnet-5-5` | The Unity Catalog model service the builder drafts with, as a three-part name. Seeds the app's setting on first boot; after that, Settings → Platform (Optional features) owns it. | Pass a custom model service (recommended). Requires the builder on (`--enable-taxonomy-builder` on this run, or a previous install that turned it on), otherwise the installer exits with a usage error (exit 2), as it does for a name that isn't three-part. |
| `--enable-assessment` | no | _(off)_ | Installs the optional in-app bronze assessment skill. See [Enabling the in-app bronze assessment skill](#enabling-the-in-app-bronze-assessment-skill-optional). | Pass to turn the feature on. Omit and the feature stays off: its pages are hidden and its API answers 404. |
| `--disable-assessment` | no | - | Turns off an assessment that a previous install turned on. | Pass to turn the feature off on a re-run. Can't be combined with `--enable-assessment`. |
| `--assess-reader-sp <application_id>` | no | _(unset)_ | The reader service principal the assessment job runs as (its application id, a UUID). Seeds the app's setting on first boot; after that, Settings → Platform (Optional features) owns it. With it, the installer runs a warn-only check of the reader. | Pass when the reader already exists. Without it the feature stays disabled until an admin sets the reader in Settings. Requires the assessment on (this run or a previous install); a value that isn't a UUID is a usage error (exit 2). |
| `--no-run-tags` | no | _(on)_ | Starts the Settings → Agent → "Annotate jobs with run tags" setting off. The setting is seeded when the app first creates its settings row (for an upgrade, see [Upgrading in place](#upgrading-in-place)). After that, Settings own it and re-running the installer does not change it. See [Job and app tags](#job-and-app-tags). | Pass it if business names and notebook file names must not appear as tags on the agent job. |
| `--run-tags` | no | - | Turns the run-tags seed back on after an install with `--no-run-tags`. Can't be combined with `--no-run-tags`. | Pass on a re-run to undo `--no-run-tags`. |
| `--enable-github-publish` | no | _(off)_ | Deploys the bundle's `github-publish` target, which grants the App `USE CONNECTION` on the `github_pr` Unity Catalog connection. The installer stops before deploying if it cannot read that connection. See [Enabling publish-to-GitHub](#enabling-publish-to-github-optional). | Pass after creating the connection. Re-runs keep the target without the flag. On an app installed without it, the flag switches the same app to this target. |
| `--disable-github-publish` | no | - | Deploys the default `dev` target, which declares no app resources. On an app on the `github-publish` target, it switches the same app back and removes its `USE CONNECTION` grant. | Without either github-publish flag, an existing app keeps the target read from it: `github-publish` when it declares the `github_pr` connection resource, `dev` otherwise. Can't be combined with `--enable-github-publish`. |
| `--lakebase-min-cu <cu>` | no | `1` | Minimum compute of the Lakebase project's autoscaling range, in capacity units (CU, about 2 GB of memory each). | Raise it for larger models or many concurrent users. |
| `--lakebase-max-cu <cu>` | no | `4` | Maximum of that range. The range must satisfy 0.5 ≤ min ≤ max ≤ 32 and max − min ≤ 16; the installer checks this before deploying (exit 2). | Raise it to absorb load peaks. |
| `--lakebase-resize` | no | _(off)_ | The range applies when the installer creates the Lakebase project. For an existing project, the installer prints the current range; with this flag it changes it to `--lakebase-min-cu`..`--lakebase-max-cu`. | Pass to resize an existing install's Lakebase compute. |
| `--adopt-existing-app` | no | _(off)_ | Takes over an App that already exists but that no bundle deployment state manages (not under the app's bundle folder, and not under the folder of an install made before 0.9.0) and that the installer does not recognise as a vibe-modeling app it read. An app it recognises (this bundle's description, and a running `app.yml` with its Lakebase project, database and catalog) and that you created is bound after the plan check without the flag; one another identity created is bound after you confirm on a terminal. The installer prints the App's creator and description, then binds it to the bundle. Without the flag it stops (exit 2) with that information. | Pass only for an app you installed yourself whose deployment state is gone (for example, it was installed by another identity or the bundle folder was deleted). Never for another team's app. When another identity created the app, the installer warns and asks to confirm (y/N; `--yes` skips the question, and without a terminal it refuses unless `--yes`). An app with no deployment yet has no health to check, so without a terminal the in-flight check refuses first; `--yes` answers both questions. The installer checks the deploy plan before it binds the app and again after; if the run stops after the bind for any reason (a refused or failed check, an interrupt), it unbinds the app and removes the state the bind wrote. |
| `--allow-shared-resources` | no | _(off)_ | Keeps a catalog that another app on the workspace also uses, on the run that points the app at it. The installer checks a catalog or Lakebase project only when the run changes it (or for a new app), against the other vibe-modeling apps on the workspace: a catalog their running `app.yml` sets or their service principal holds privileges on. Without the flag it refuses the share. It never lifts the refusal of a shared Lakebase project. | Only when two apps must share a catalog. Apps that already share one (two apps installed before 0.9.0 with the default names) keep it on a re-run without the flag. Never for a new app. |
| `--apply-without-plan-file` | no | _(off)_ | After the deploy plan check, applies with a plain `bundle deploy` (which plans again) instead of applying the checked plan file. | Only if `databricks bundle deploy --plan` fails on your CLI; see [Troubleshooting](#troubleshooting). |
| `--yes` | no | _(off)_ | Before deploying, the installer checks the existing App for runs in flight and refuses while any are. When it can't tell (the app list or the App's health can't be read, the App has no URL yet, or `jq` or `python` is missing), it prints a warning with the reason and asks to confirm (y/N). `--yes` deploys without asking; without a terminal to ask on, the installer refuses unless `--yes` is given. Runs in flight always refuse. A first install of a new app needs no confirmation. `--yes` also skips the question the installer asks before it takes an app another identity created into this bundle (an earlier deployment state it copies, or `--adopt-existing-app`), and the one it asks before every deploy of an existing app's settings (see [Re-running the installer](#re-running-the-installer)). | Pass for an unattended run, deliberately: a run in flight that the check could not see would lose its progress. |
| `--dry-run` | no | - | Looks the app up (read only), prints the settings the run would deploy and where each one comes from (flag, deployed, default), checks a new Lakebase project or catalog against the other apps, then stops before deploying anything. For an existing app it shows the settings the app runs with, as a real run would before asking to confirm them; when the lookup fails it shows a new app's defaults and says it can't tell. | Check what a re-run will deploy. |
| `-h`, `--help` | no | - | Print the usage block and exit. | - |

`install/install.sh` passes the install-time values to the build as `VIBE_MODELING_*` environment variables before it runs `databricks bundle deploy`. The bundle's `artifacts.default.build` hook (`install/build_and_render.sh`) renders them into `src/app/.build/app.yml` during the build. The installer never edits the checked-in source `src/app/app.yml`.

### Re-running the installer

The installer keeps nothing from one run to the next: no file in your checkout, and no local bundle cache (it deletes `.databricks/bundle/<target>/` before every deploy). It looks the app up after authenticating. A new app gets the defaults and your flags. For an app that already exists, the installer reads every setting from the app as it runs now, so nothing falls back to a default: the values in the `app.yml` of the app's active deployment (with any environment variables set on that deployment on top), the bundle target from the app's resources, and the Lakebase capacity from its project's endpoint. It prints them marked `(deployed)`, with where it read them, and asks `Deploy app '<app-name>' with these settings? [y/N]` on every run, also when you pass every setting as a flag. Only `y` deploys. A flag you pass changes its value (the installer notes the value it replaces); to turn an optional feature off, pass its `--disable-*` flag. Without a terminal it refuses unless you pass `--yes`; check the values with `--dry-run` first.

If a setting can't be read, the installer stops before deploying (exit 2), says why, and lists the flags for only those settings. The `app.yml` of the running deployment is readable by the identity that created that deployment and by workspace admins; run the installer as one of them, or pass the listed flags. A stopped app has no active deployment to read: pass the listed flags, or start the app (`databricks apps start <app-name>`) and re-run so they are read. If the installer can't tell whether the app exists, it stops (exit 1). If you installed 0.9.0 from this checkout, it left a settings file in `install/.generated/deploy_settings/`; the installer no longer reads it, and you can delete it.

### Deploying without `install.sh`

To change or redeploy an install, re-run `install/install.sh`. It is idempotent and sets everything below for you.

If you run `install/build_and_render.sh` or `databricks bundle deploy` yourself:

- **App name.** Export `VIBE_MODELING_APP_NAME=<app-name>` or `BUNDLE_VAR_app_name=<app-name>`, and pass `--var "app_name=<app-name>"` (the bundle variable has no default). An exported `VIBE_MODELING_APP_NAME` must name the same app.
- **Values.** The build uses the exported `VIBE_MODELING_*` values below, and nothing else: it reads nothing from the workspace or from an earlier run.
- **Fail closed.** The build stops rather than deploy defaults when there is no app name ("This deploy would reset the app's settings to defaults"), or when any variable below other than the Lakebase range and `VIBE_MODELING_ALLOW_SHARED_RESOURCES` is not exported (the model service and the reader only while their feature is on). The message lists the values to export, and `install/install.sh --dry-run --app-name <app-name>` prints the values the app runs with. To deploy the defaults on purpose, set `VIBE_MODELING_ALLOW_DEFAULT_SETTINGS=1`.
- **Target.** Deploy the app's own bundle target. The build stops when `--target` differs from the exported `VIBE_MODELING_BUNDLE_TARGET`.
- **Plan first.** Check `databricks bundle plan` before you deploy, and do not deploy a plan that deletes or recreates the app. `install.sh` makes that check for you.

| Variable | Install flag | Meaning | Default when unset |
|----------|--------------|---------|--------------------|
| `VIBE_MODELING_LAKEBASE_PROJECT` | `--project` | Lakebase project ID the app connects to | the app name |
| `VIBE_MODELING_DATABASE_NAME` | `--database`, `--catalog` | Postgres database name in that project | the app name with `-` as `_` |
| `VIBE_MODELING_DEPLOYMENT_CATALOG` | `--catalog` | Deployment catalog, which holds `_metamodel`; seeds the app's setting on first boot | the app name with `-` as `_` |
| `VIBE_MODELING_WAREHOUSE_ID` | `--warehouse-id` | SQL warehouse ID for run progress | empty (pick it in Settings) |
| `VIBE_MODELING_TAXONOMY_BUILDER_ENABLED` | `--enable-taxonomy-builder`, `--disable-taxonomy-builder` | `true` turns the Domain Taxonomy Builder on | `false` |
| `VIBE_MODELING_TAXONOMY_MODEL_SERVICE` | `--taxonomy-model-service` | Model service the builder drafts with (`catalog.schema.service`); fills an empty setting only | `system.ai.claude-sonnet-5-5` when the builder is on, else empty |
| `VIBE_MODELING_ASSESSMENT_ENABLED` | `--enable-assessment`, `--disable-assessment` | `true` turns the in-app bronze assessment on | `false` |
| `VIBE_MODELING_ASSESS_READER_SP` | `--assess-reader-sp` | Application ID of the assessment reader service principal; fills an empty setting only | empty (set it in Settings) |
| `VIBE_MODELING_RUN_TAGS_DEFAULT` | `--no-run-tags`, `--run-tags` | Initial value of the run-tags setting (`false` with `--no-run-tags`) | `true` |
| `VIBE_MODELING_BUNDLE_TARGET` | `--enable-github-publish`, `--disable-github-publish` | Bundle target of the app (`dev` or `github-publish`) | `dev` |
| `VIBE_MODELING_LAKEBASE_MIN_CU`, `VIBE_MODELING_LAKEBASE_MAX_CU` | `--lakebase-min-cu`, `--lakebase-max-cu` | Lakebase autoscaling range used when the project is created | `1`, `4` |
| `VIBE_MODELING_ALLOW_SHARED_RESOURCES` | `--allow-shared-resources` | `true` keeps, on this run, a catalog another app on the workspace also uses (`install.sh` checks it; a hand-run deploy does not); a shared Lakebase project always refuses | `false` |

`install.sh` exports every variable in this table before it builds. For a hand-run deploy of an app named `my-app`, export each value (`install/install.sh --dry-run --app-name my-app` prints the ones the app runs with), then:

```bash
export VIBE_MODELING_APP_NAME=my-app
bash install/build_and_render.sh --profile <your-profile>
databricks bundle plan --profile <your-profile> --var "app_name=my-app"
databricks bundle deploy --profile <your-profile> --var "app_name=my-app"
```

Run `install/build_and_render.sh` before `databricks bundle deploy`. The deploy reads the rendered user-scopes file before its own build step runs. If you skip it, the deploy's build step may stop with "The app's user API scopes changed"; re-run the deploy.

## Pre-install: authenticate the CLI

```bash
databricks auth login --host <workspace-url> --profile my-workspace
databricks current-user me --profile my-workspace   # confirm
```

The profile name you pass to `databricks auth login` is the same name you pass to `install.sh --profile`.

## Run the installer

```bash
bash install/install.sh --profile my-workspace
```

> Run repo scripts with a `bash <script>` prefix as shown. A fresh checkout may not carry the executable bit, so invoking `./install.sh` directly can fail with "permission denied". To run a script directly instead, `chmod +x` it first.

The five-phase script prints `[N/5]` markers and stops on the first failure:

1. `[0/5]` Check the flags. Verify the prerequisites: critical tools (`databricks`, `python`, `jq`, `curl`, `apx`, `uv`, `bun`) and Python packages (`databricks-sdk`, `psycopg`) must be present or the script aborts; a `databricks` CLI below 1.20.0 aborts; `python` below its minimum version warns but does not block. Verify the CLI profile, look the app up, resolve the deploy settings (for an existing app, read from it and confirmed) and print each value with its source, and run the in-flight runs guard (see `--yes` in [Parameter reference](#parameter-reference)).
2. `[1/5]` `python install/bundle_state.py deploy`: finds the app's deployment state, runs `databricks bundle plan`, stops if the plan would delete or recreate the App, then applies exactly that plan with `databricks bundle deploy --plan`. Creates or updates the App resource and its service principal.
3. `[2/5]` `python install/provision_lakebase.py`: Lakebase project, endpoint, database, role grants.
4. `[3/5]` `python install/grant_catalog.py`: UC privileges for the App SP (best-effort, logs SQL on permission failure). With `--enable-taxonomy-builder`, `python install/check_model_service.py` then checks the model service (read-only; see [Enabling the Domain Taxonomy Builder](#enabling-the-domain-taxonomy-builder-optional)). With `--enable-assessment --assess-reader-sp`, the same script checks the reader, warn-only (see [Enabling the in-app bronze assessment skill](#enabling-the-in-app-bronze-assessment-skill-optional)).
5. `[4/5]` Start app compute and wait for `ACTIVE`, then wait for any deployment that starting the app began.
6. `[5/5]` `databricks apps deploy` from `src/app/.build`, and wait for `RUNNING`.
7. `[tag]` `python install/tag_app.py`: tags the App, warn-only (see [Job and app tags](#job-and-app-tags)).

After `[tag]`, install.sh runs a warn-only `[verify]` block (homepage `200`, `/api/industries` == 40, the catalog exists in Unity Catalog). These are eventually-consistent and best-effort, so a gap warns rather than fails. The final block prints the App URL, Lakebase project, UC catalog, database, warehouse, and SP. Copy this for later reference.

## App SP catalog privileges

The app's service principal (SP) needs to use the catalog, create schemas, and read and write the tables and volumes in `_metamodel`. At step `[3/5]`, `install/install.sh` creates the catalog, the `_metamodel` schema, and its `vol_root` MANAGED volume if absent (the app downloads industry models into `/Volumes/<catalog>/_metamodel/vol_root/...` before any modeling run, so they must exist at install time), then issues the grants below automatically. This section is what you (or someone with grant authority) needs to run **only if** that step logged a permission warning.

Find the SP client ID:

```bash
databricks apps get <app-name> --profile <your-profile> --output json | jq -r .service_principal_client_id
```

Then issue:

```sql
GRANT USE CATALOG, CREATE SCHEMA, BROWSE ON CATALOG <catalog> TO `<sp-client-id>`;
```

The installer also creates `_metamodel` + `vol_root` and grants the SP at the schema level. If you are issuing grants by hand, also run:

```sql
CREATE SCHEMA IF NOT EXISTS <catalog>._metamodel;
CREATE VOLUME IF NOT EXISTS <catalog>._metamodel.vol_root;
GRANT USE SCHEMA, CREATE TABLE, MODIFY, SELECT, READ VOLUME, WRITE VOLUME, CREATE VOLUME, MANAGE
  ON SCHEMA <catalog>._metamodel TO `<sp-client-id>`;
```

`READ VOLUME` and `WRITE VOLUME` cascade to current and future volumes in the schema (including `_metamodel.vol_root`), so no separate per-volume grant is required.

`CREATE VOLUME` and `MANAGE` on `_metamodel` are granted on every install, whether or not the bronze assessment skill is enabled, so enabling the skill later needs no admin step.

Re-running the grants is idempotent:

```bash
python install/grant_catalog.py --profile <your-profile> --catalog <catalog> --app-sp <sp-uuid>
```

**Redeploy note:** the App SP is tied to the App resource's lifetime, not to each deploy. A source-only push (`databricks apps deploy …`, install.sh step `[5/5]`) reuses the existing SP, so there are no grant changes. The SP rotates only when you delete and recreate the App; re-running `install/install.sh` against the recreated app re-issues the grants automatically.

## Verify the install

Wait ~30 seconds after `install.sh` finishes (this gives the app time to upload the bundled notebook and create its job), then:

```bash
PROFILE=my-workspace
APP_NAME=vibe-modeling

TOKEN=$(databricks auth token --profile "$PROFILE" | jq -r .access_token)
APP_URL=$(databricks apps get "$APP_NAME" --profile "$PROFILE" --output json | jq -r .url)

# App status should be RUNNING:
databricks apps get "$APP_NAME" --profile "$PROFILE" --output json | jq -r '.app_status.state'

# Homepage returns 200:
curl -s -o /dev/null -w '%{http_code}\n' -H "Authorization: Bearer $TOKEN" "$APP_URL/"

# Industries were seeded (expect 40):
curl -s -H "Authorization: Bearer $TOKEN" "$APP_URL/api/industries" | jq 'length'

# Businesses list loads (empty on a fresh install):
curl -s -H "Authorization: Bearer $TOKEN" "$APP_URL/api/businesses" | jq
```

Expected:

- `app_status.state` → `"RUNNING"`
- `/` → HTTP `200`
- `/api/industries` → `40`
- `/api/businesses` → `[]`

If any check fails, see [Troubleshooting](#troubleshooting).

## Open the app

```bash
databricks apps get <app-name> --profile <your-profile> --output json | jq -r .url
```

The install values (`--catalog`, `--warehouse-id` and the optional features' settings) seed the app's settings on first boot; change the catalog and the warehouse later in the app's Settings. Turning an optional feature on or off needs the installer: re-run `install.sh` with `--enable-*` or `--disable-*`. Once a feature is on, Settings → Platform (Optional features) holds its settings.

## Job and app tags

- On every run, `install.sh` tags the Databricks App with `managed_by=vibe_modeling_app`, `dbx_vibe_modelling_app=<app name>` and `dbx_vibe_modelling_app_version=<app version>`. Every job the app creates carries the same three tags.
- Tagging needs CAN MANAGE on the app (the installing user has it once `bundle deploy` has created the app), plus ASSIGN on any governed tag key. A tagging failure prints a warning and the install continues.
- App tags show on the app's page and through the API. They don't reach billing.
- `--no-run-tags` starts the Settings → Agent → "Annotate jobs with run tags" setting off (see [Parameter reference](#parameter-reference)).

## Access model

Every user granted Databricks Apps access to the app has full access, including Settings. Scope the app's access in Databricks Apps (**Permissions** on the app) to the users who should use it.

## Installing a second app next to an existing one

Each app name has its own bundle folder (`/Workspace/Users/<you>/.bundle/vibe-modeling/<app-name>`) and its own deployment state, so a second app installs next to an existing one from the same checkout and the same identity. Use it to try a new release before you upgrade the app your users work in:

```bash
bash install/install.sh --profile <your-profile> --app-name vibe-modeling-next
```

- A new app gets its own Lakebase project (the app name) and its own catalog and Postgres database (the app name with `-` replaced by `_`, here `vibe_modeling_next`). Pass `--project` and `--catalog` to pick others. The catalog must exist or be creatable, as for any install (see `--catalog` in [Parameter reference](#parameter-reference)).
- Each app needs its own Lakebase project. Two apps on one project don't work: provisioning makes the newer app's service principal the owner of the app's tables, and the other app then fails at boot with "permission denied for table _lakebase_schema_version". The installer always refuses a project that another vibe-modeling app on the workspace has a role on.
- Two apps on one catalog share its `_metamodel` and act on each other's models, so the installer refuses a shared catalog too. Apps that already share one (two apps installed before 0.9.0 with the default names) can keep it with `--allow-shared-resources`.
- The share checks read the workspace: the other apps with this bundle's description that your identity can see. When it can't tell for some apps (their running `app.yml` is unreadable and so are the catalog's grants), the installer names them in a warning and goes on, so check those names yourself.
- Each app has its own settings (read from it) and its own deployment state. Installing or re-running one app never changes the other.
- To remove the second app later, delete it in the workspace **Apps** UI (or `databricks apps delete <app-name>`), delete its Lakebase project, and delete its bundle folder.

## Upgrading in place

A fresh install needs nothing beyond the steps above: the schema migrations run on first boot.

To upgrade a deployment that already holds data:

1. **Make sure you can restore the database.** Take a snapshot of the Lakebase project's production branch, or note the current time so you can use point-in-time restore within the project's restore window. The app never downgrades its schema, so going back to an older app version after an upgrade means restoring the database.
2. **Use Databricks CLI 1.20.0 or later.** The installer refuses an older one before it deploys anything (see [Prerequisites](#prerequisites)).
3. **Wait for in-flight runs to finish**, or cancel them. The installer refuses to deploy while runs are active (see [Troubleshooting](#troubleshooting)).
4. **Re-run `install/install.sh` from the new release** with `--profile` and `--app-name`. The installer reads the settings from the running app, prints them marked `(deployed)` and asks you to confirm them; this is the same on every re-run and from any checkout. Run with `--dry-run` first to see them; pass a flag only to change a value. If a setting can't be read (for example, another identity created the running deployment and you are not a workspace admin, or the app is stopped), the installer stops and lists the flags for those settings only:
   - `--project`, `--catalog` (and `--database` if the Postgres database name differs), `--warehouse-id` (`--warehouse-id ''` for none);
   - `--enable-taxonomy-builder` with `--taxonomy-model-service`, or `--disable-taxonomy-builder`;
   - `--enable-assessment` with `--assess-reader-sp`, or `--disable-assessment`;
   - `--run-tags` or `--no-run-tags`.

   Without a github-publish flag, the bundle target comes from the app: `github-publish` when the app declares the `github_pr` connection resource. The installer refuses `--disable-github-publish` for an app that has it.

The first upgrade to 0.9.0 or later turns Settings → Agent → "Annotate jobs with run tags" on: an app installed before 0.9.0 has no run-tags value to read, so the default (on) applies, and the installer says so before it asks to confirm. To keep it off, pass `--no-run-tags` on that upgrade. After that upgrade, also fix the industries downloaded before 0.9.0: see [Upgrading from 0.8.x](#upgrading-from-08x).

The upgrade updates the same app; it never deletes or recreates it. Before it applies anything, the installer checks the deploy plan and stops if the plan would delete or recreate the app.

An app installed before 0.9.0 deployed from `/Workspace/Users/<you>/.bundle/vibe-modeling/dev` (or `.../github-publish`). On the first upgrade the installer copies that deployment state to the app's own folder, `.../vibe-modeling/<app-name>`, and leaves the old folder in place; you can delete the old folder once the upgrade works. If the plan check refuses, the installer removes the copy again. If both `.../dev` and `.../github-publish` hold a state for the app, the installer stops and names both; keep the one the app runs from (`databricks apps get <app-name>` shows its source path) and move the other away. When the app was created by another identity, the installer asks to confirm the copy (y/N, or `--yes`). If the app runs from its own folder already, an earlier folder's state is not copied.

The upgrade restarts the app once, at the final `apps deploy` step; the bundle deploy only changes the app's settings. If the app's compute was stopped, starting it at `[4/5]` redeploys its previous deployment first; the installer waits for that (up to 10 minutes), then deploys the new code, so a stopped app goes through two deployments. For a stopped app the bundle deploy has nothing to change, so the deployment state keeps the earlier source folder until the next upgrade or re-run updates it; the app itself runs from its own folder. Run the upgrade as the identity that installed the app. If its deployment state is gone (the bundle folder was deleted, or another identity installs), the installer binds a vibe-modeling app it recognised after the plan check: without a question when you created it, after a y/N on a terminal when another identity did (`--yes` does not answer that one; use `--adopt-existing-app`).

On boot, the app applies the schema migrations the new release adds, in place. Your businesses, model versions and runs are kept. It also upgrades the agent notebook in its own folder (`/Users/<app service principal>/vibe-modelling-agent/`) to the one the new release bundles, on the first boot with no run in flight. A notebook you configured outside that folder is left as it is.

## Upgrading from 0.8.x

From 0.9.0 the app gives every industry it downloads scope prefixes: `ecm_<domain>` and `mvm_<domain>` schemas, `ecm_<view>` and `mvm_<view>` metric views. Industries downloaded before 0.9.0 keep their bare names until you fix them. After the upgrade, run `install/fix_industry_prefixes.py` as an app Admin, first without `--apply` to see what it would change:

```bash
python install/fix_industry_prefixes.py --profile <your-profile> --app-name <app-name> --all
python install/fix_industry_prefixes.py --profile <your-profile> --app-name <app-name> --all --apply
```

Pass `--industry <name or id>` instead of `--all` to fix one industry. The script needs only Python and the Databricks CLI. It prints one row per industry version: `changed`, `unchanged`, `skipped` or `failed` with the reason. A second run reports `unchanged`, and finishes a version that failed.

- It renames no schema, table or metric view in Unity Catalog; it rewrites the app's copies of the model files (the original is kept next to each as `model.json.pre090`) and the app's registry rows.
- It skips every installed industry version, since it never renames installed schemas. To rename one, uninstall it first, then run the script again.
- Businesses kickstarted from an industry before 0.9.0 are not changed.

Exit codes: 0 done, 2 done with a version skipped, 1 an error (no token, no app, a refused or failed request, a version that failed), 3 a usage error.

## Authenticating source reads (recommended)

The app reads the public industry-model repo (and the upstream-agent monitor) from GitHub over HTTP. Unauthenticated reads are capped at 60 requests per hour per egress IP, and on Databricks Apps that IP is shared. Configure a read credential (a GitHub App, recommended, or a personal access token) in **Settings → Sources → Source read access** to raise the limit to 5,000 per hour. The secret material lives in a Databricks secret scope and the app service principal needs READ on that scope. See [`docs/github-app-source-auth.md`](docs/github-app-source-auth.md) for all three modes and the required grant.

## Enabling publish-to-GitHub (optional)

The app can publish a model version to a GitHub repository as a pull request. This feature is **optional and off by default**; the core install does not need it. It is separate from source reads (above).

Publishing goes through a Unity Catalog HTTP connection named `github_pr`, on behalf of the acting user. That connection uses per-user OAuth (U2M), which is interactive, so it **cannot be created by `install/install.sh`, Terraform, or SQL**: you create it once by hand in Catalog Explorer. Because the bundle's default (`dev`) target declares no app resources, a fresh install deploys cleanly on any workspace whether or not `github_pr` exists.

To enable publish on a workspace:

1. Create the `github_pr` UC HTTP connection and grant it, following [`docs/github-integration-setup.md`](docs/github-integration-setup.md) (register a GitHub OAuth app, create the connection, grant `USE CONNECTION`, enable OBO on the app).
2. Install with `--enable-github-publish`, which deploys the `github-publish` bundle target so the bundle re-applies the `USE_CONNECTION` grant on `github_pr` each deploy:

   ```bash
   bash install/install.sh --profile <your-profile> --app-name <app-name> --enable-github-publish
   ```

   The grant is the only difference from the default target. The flag, how re-runs keep the target, and `--disable-github-publish` are in [Parameter reference](#parameter-reference).
3. Configure the GitHub tab in the app's Settings (connection name, repo owner/name) per Step E of the integration guide.

## Enabling the Domain Taxonomy Builder (optional)

The Domain Taxonomy Builder is a wizard that uses an LLM to draft a business's domains and description. It is **optional and off by default**. Turn it on at install time:

```bash
bash install/install.sh --profile my-workspace \
  --enable-taxonomy-builder \
  --taxonomy-model-service <catalog.schema.service>
```

Without `--taxonomy-model-service`, the builder uses `system.ai.claude-sonnet-5-5`. We recommend a custom model service per workload. A workspace admin can deny the shared `system.ai` services, so a custom service is the safer choice.

The app calls the model service through the Unity AI Gateway as its service principal. The App SP needs three privileges. Grant them with the Databricks CLI, which handles Unity Gateway model services:

```bash
databricks grants update catalog <catalog> \
  --json '{"changes":[{"principal":"<app-sp-application-id>","add":["USE_CATALOG"]}]}'
databricks grants update schema <catalog>.<schema> \
  --json '{"changes":[{"principal":"<app-sp-application-id>","add":["USE_SCHEMA"]}]}'
databricks grants update model_service <catalog>.<schema>.<service> \
  --json '{"changes":[{"principal":"<app-sp-application-id>","add":["EXECUTE"]}]}'
```

Or grant the same privileges in Catalog Explorer → the catalog, schema and model service → **Permissions**.

Grants on `system.ai` need a metastore admin or the `MANAGE` privilege. The installer never grants these. It checks them, read-only, after the App SP exists:

- If the model service does not exist, the install stops with "Model service '<name>' not found."
- If a privilege is missing, the install stops and prints the exact `databricks grants update` commands. An admin runs them, then you re-run `install.sh` (every step is idempotent).
- If the installer cannot read the SP's privileges, it warns and continues.

After install, an admin can change the model service and the concurrency limit in **Settings → Platform**, under Optional features.

To turn the builder on for an existing install, re-run `install.sh` with `--enable-taxonomy-builder`; the other settings, read from the app, stay as they are (see [Re-running the installer](#re-running-the-installer)). To turn the builder off, re-run with `--disable-taxonomy-builder`. Business data the wizard wrote stays in place.

## Enabling the in-app [bronze assessment skill](https://github.com/databricks-industry-solutions/lakehouse-industry-data-models/tree/main/model-genie-skills) (optional)

The assessment profiles the source (bronze) schemas you pick against a model version and grades how well they cover it. Each domain runs as a Databricks job that runs as a reader service principal you create. It is **optional and off by default**.

Each release bundles the published version of those skills that it was built and tested with.

The feature stays disabled until a reader service principal is set. An admin sets it at install time (`--assess-reader-sp`) or later in **Settings → Platform**, under Optional features.

The reader needs no write privilege on model, source or `_metamodel` tables.

Steps:

1. Create the reader service principal, and give the App SP the **Service Principal User** role on it (Service principals → the reader → Permissions).
2. Grant the reader `USE CATALOG`, `USE SCHEMA` and `SELECT` at catalog level on the catalogs the app deploys models into and on the approved source catalogs. Catalog-level grants cover schemas created later.
3. Grant the reader `USE CATALOG` on the deployment catalog (`--catalog`).
4. Grant the reader `CAN USE` on the SQL warehouse, and `EXECUTE` on the Genie Code model service (`system.ai.gpt-5-6-sol`).
5. Allow `github.com` egress from serverless jobs (the job downloads the pinned Genie Code and Databricks CLIs).
6. Install with the flags:

```bash
bash install/install.sh --profile my-workspace \
  --enable-assessment \
  --assess-reader-sp <reader-application-id>
```

With a reader, step `[3/5]` runs `install/check_model_service.py --principal <reader>`. It is warn-only and never stops the install. It warns when the reader does not exist and when the reader lacks `EXECUTE` on the model service, and it reminds you to give the App SP the Service Principal User role on the reader (step 1), which it does not check.

The app grants the reader access to its runs volume (`<catalog>._metamodel.assess_runs`) and to `_metamodel` itself; the App SP's `CREATE VOLUME` and `MANAGE` on `_metamodel` (see [App SP catalog privileges](#app-sp-catalog-privileges)) are what let it do this. The app grants nothing on the deployment catalog itself or on any model or source catalog; steps 2 and 3 are yours.

With `--enable-assessment`, the app also requests the `workspace.workspace` user scope. Without the flag the app requests no user scopes. If your workspace restricts the scopes apps may request, allow `workspace.workspace` for this app.

To turn the skill on for an existing install, re-run `install.sh` with `--enable-assessment`; the other settings, read from the app, stay as they are (see [Re-running the installer](#re-running-the-installer)). To turn the skill off, re-run with `--disable-assessment`. Existing assessment results stay in place.

## Troubleshooting

### Redeploy appears to run old code

Databricks Apps installs the app wheel by version and skips reinstalling an unchanged one. Bump `version` in `src/app/pyproject.toml` before redeploying so the wheel reinstalls. The deploy log should read `Successfully installed vibe-modeling-<new-version>`, not `Requirements have not changed. Skipping installation`.

### `refusing to deploy: N in-flight run(s) on ...`

The installer refuses to (re-)deploy while runs are active, because replacing the app's container would lose their progress. Wait for the run to finish, or cancel it on its run page (stale runs too), then re-run the installer. There is no override.

### `refusing to deploy without confirmation, and there is no terminal to ask on`

The installer could not tell whether runs are in flight (it prints the reason above this line) and has no terminal to ask you on. Fix the cause and re-run, or re-run with `--yes` to deploy anyway.

### `permission denied for schema public` on app startup

Re-run `install/install.sh --profile <your-profile>`. The provision step re-applies Lakebase schema grants idempotently.

### `Cannot deploy app … as it is not in RUNNING state`

`install/install.sh` handles compute startup; you only hit this running the steps manually. Run `databricks apps start <app-name> --profile <profile>` and wait 15 seconds before re-deploying.

### `project with such id already exists`

A Lakebase project with that name already exists, or was recently deleted (project names are locked for ~2 hours after deletion). Re-run with `--project <other-id>`.

### `Lakebase Autoscaling connection validation failed`

The `VIBE_MODELING_LAKEBASE_PROJECT` env var rendered into `src/app/.build/app.yml` doesn't match the `--project` value. Re-run `install/install.sh --profile <your-profile> --project <correct-id>`; the artifacts hook re-renders the file from the corrected value.

### `Connection 'github_pr' does not exist` during bundle deploy

You deployed the `github-publish` target on a workspace where the `github_pr` UC connection has not been created yet. The default install (`dev` target) does not declare this resource and is unaffected. `install.sh --enable-github-publish` checks for the connection before it deploys. Create the connection first (see [Enabling publish-to-GitHub](#enabling-publish-to-github-optional)), then re-run.

### `refusing to deploy the settings read from the running app without confirmation`

The app exists and the installer read its settings from the running app, but it has no terminal to ask you to confirm them (it asks on every run). Check them with `install/install.sh --dry-run --profile <your-profile> --app-name <app-name>`, then re-run with `--yes`. Pass a flag for any value you want to change. If you redirect the installer's output to a file while it runs on a terminal, the question goes to that file and the installer waits for your answer: pass `--yes` after checking with `--dry-run` instead.

### `These settings could not be read from it`

The installer could not read some settings of an existing app. The message says why for each one. Common causes: the app is stopped, so it has no active deployment (pass the listed flags, or start it with `databricks apps start <app-name>` and re-run so they are read), or another identity created the running deployment and only that identity or a workspace admin can read its `app.yml` (run the installer as one of them). Otherwise pass the flags the message lists, with the values the app runs with.

### `This deploy would reset the app's settings to defaults` or `This deploy of app '<app-name>' does not export ...`

A `databricks bundle deploy` or `install/build_and_render.sh` ran without an app name, or without a value the message names exported. Re-run `install/install.sh`, or export the app name as shown in [Deploying without `install.sh`](#deploying-without-installsh).

### `Databricks CLI X is below 1.20.0`

The installer checks the deploy plan and then applies exactly that plan (`databricks bundle deploy --plan`), which needs CLI 1.20.0 or later. Upgrade the CLI ([install](https://docs.databricks.com/aws/en/dev-tools/cli/install)) and re-run. Nothing was deployed.

### `permission denied for table _lakebase_schema_version` at boot

Two apps use one Lakebase project (for example, two apps installed before 0.9.0 with the default names). Provisioning one app makes its service principal the owner of the app's tables, so the other app can no longer reach them and fails at boot. Each app needs its own project: re-install the app that should move with its own `--project`. It starts with an empty database. The installer refuses a project another vibe-modeling app on the workspace has a role on, and no flag lifts that.

### `databricks bundle plan` failed with a panic during an upgrade

The earlier deployment state the installer copied names an app that was deleted outside the installer. CLI 1.20.0 stops with a panic (a nil pointer in its app planning) instead of planning a recreate. Nothing was deployed, and the installer removed the copied state; the earlier folder is unchanged. If the app is gone for good, move that earlier folder's `state` subfolder away, then re-run to install the app fresh.

### `The deploy plan for app '<app-name>' would delete ...` or `... would recreate ...`

The installer stopped before deploying because the deploy would delete or replace the App, which would also delete the App's service principal and the grants made to it. This happens when the deployment state belongs to another app name, or when the App was deleted outside the installer. Check which apps `databricks apps list --profile <your-profile>` shows, re-run with the app name you installed, and run the installer as the identity that installed the app. The plan it checked is in `install/.generated/plans/<app-name>.json`. A deployment state the installer copied from an earlier folder in this run is removed again; the earlier folder is unchanged.

If the CLI fails while it applies the checked plan, re-run with `--apply-without-plan-file`: it applies with a plain `bundle deploy` after the same check.

### `App '<app-name>' already exists, and no bundle state manages it`

No deployment state for the app exists: not in the app's bundle folder, and not in the folder of an install made before 0.9.0, and the installer did not recognise it as a vibe-modeling app (its description or its running `app.yml` differ, or the `app.yml` can't be read). The app may belong to another user or team; the message shows its creator and description. If it is your app (for example, installed by another identity of yours), re-run with `--adopt-existing-app`. Otherwise pick another `--app-name`.

### `could not check whether another app uses Lakebase project ...`

A new Lakebase project for the app exists, and the installer could not read its roles (or there were too many to look up one by one), so it can't tell whether another app uses it. It refuses (nothing was deployed). Check the project's roles yourself (`databricks postgres list-roles projects/<project>/branches/production`) and run as an identity that can read them, or pass another `--project`.

### `This deploy runs the '<target>' bundle target, but app '<app-name>' is set to '<other>'`

A `databricks bundle deploy` without `install.sh` used a `--target` other than the exported `VIBE_MODELING_BUNDLE_TARGET` (a deploy without `--target` uses `dev`). Deploy with the app's target, or switch the target with `install/install.sh --enable-github-publish` or `--disable-github-publish`.

### `App '<other>' already uses the Lakebase project` or `The catalog ... looks used by app '<other>'`

Another vibe-modeling app on the workspace uses that Lakebase project (its service principal has a role on it) or catalog (its running `app.yml` sets it, or its service principal holds privileges on it); the message names the evidence. For a project, pass another `--project` (or, for a hand-run deploy, export another `VIBE_MODELING_LAKEBASE_PROJECT`): two apps can't share one (see the entry above), and no flag lifts it. Moving an installed app starts it with an empty database; moving the other app instead works too. For a catalog, pass another `--catalog`; if both apps already run on it (for example, two apps installed before 0.9.0 with the default names), re-run with `--allow-shared-resources`.

### `Both earlier bundle roots hold a state that manages app '<app-name>'`

Both `.../vibe-modeling/dev` and `.../vibe-modeling/github-publish` hold a deployment state for the app, and the installer can't tell which is current. `databricks apps get <app-name> --profile <your-profile>` shows the folder the app runs from. Move the other folder's `state` subfolder away, then re-run.

### `App '<app-name>' was created by <someone>, not by <you>`

The installer is about to take an app another identity created into this bundle (copying its earlier deployment state, or `--adopt-existing-app`). Answer `y` only if it is your app. Without a terminal, the installer refuses unless you pass `--yes`. For a vibe-modeling app it recognised whose deployment state is gone, `--yes` does not answer this question: answer it on a terminal, or pass `--adopt-existing-app` (with `--yes` when there is no terminal).

### The grant step at `[3/5]` logged a permission warning

Your identity lacks grant authority on the catalog. Have a user with catalog ownership, `MANAGE` on the catalog, or metastore-admin run the SQL in [App SP catalog privileges](#app-sp-catalog-privileges), or re-run `python install/grant_catalog.py` from a privileged identity.

### `lineage mismatch in state files` from a hand-run `bundle deploy` or `bundle plan`

The local bundle cache in `.databricks/bundle/<target>/` belongs to another app deployed from this checkout, and the CLI found the app's own deployment state in the workspace with a different history. `install.sh` clears such a cache for you. For a hand-run deploy, delete `.databricks/bundle/<target>/` (the cache only; the authoritative state stays in the workspace) and re-run.

### `bundle deploy` fails with `workspace_id mismatch ... in provider_config`

The local DAB terraform state under `.databricks/bundle/dev/` is a cache that pins the workspace this bundle was last deployed to from this machine. Installing to a **different** workspace trips this mismatch. `install.sh` deletes the local cache before every deploy, so it never hits this; if you hit it running `databricks bundle deploy` directly, clear it yourself with `rm -rf .databricks/bundle/dev` and redeploy. The authoritative state lives in the target workspace, so clearing the local cache is safe.
