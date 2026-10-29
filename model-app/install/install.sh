#!/usr/bin/env bash
# End-to-end install for the Vibe Data Modeling app.
#
# Runs the full sequence:
#   1. python install/bundle_state.py deploy (the app's bundle state, then
#                                             `bundle plan`, a refusal of any
#                                             delete or recreate of the App, and
#                                             `bundle deploy --plan` of that plan:
#                                             creates or updates the App + its SP;
#                                             the artifacts hook in databricks.yml
#                                             renders src/app/.build/app.yml from
#                                             the VIBE_MODELING_* env vars this
#                                             script exports)
#   2. python install/provision_lakebase.py  (Lakebase project, endpoint, DB,
#                                             roles, autoscaling range)
#   3. python install/grant_catalog.py       (UC privileges for app SP — best-effort)
#      python install/check_model_service.py (only with --enable-taxonomy-builder:
#                                             read-only check that the app SP can
#                                             use the model service; never grants.
#                                             With --enable-assessment and a reader:
#                                             warn-only check of the reader SP)
#   4. databricks apps start                 (bring compute up)
#   5. databricks apps deploy                (push the built source to the running app,
#                                             after any deployment `apps start` began,
#                                             and wait until it is RUNNING)
#   [tag] python install/tag_app.py          (warn-only: tags the App with managed_by,
#                                             its name and the app version)
#
# The bundled vibe-modelling-agent notebook is installed by the App itself
# during its lifespan startup (see backend/core/_bundled_agent_init.py), so
# no separate post-deploy HTTP step is needed and there is no dependency on
# the operator's machine resolving the App's public URL.
#
# Settings (install/deploy_settings.py, which prints where each value came
# from): nothing left by an earlier run is read. install.sh looks the app up
# after authenticating (install/_install_common.py app-exists): a new app gets
# the defaults in install/_feature_defaults.sh; an existing app's settings are
# read from the running app (deploy_settings.py --read-deployed: its active
# deployment's app.yml, the bundle target from its resources, the Lakebase range
# from its endpoint), shown as (deployed), and deployed only after a y/N
# confirmation on every run (--yes takes them; no terminal refuses); a flag
# changes a value. A setting that can't be read stops (exit 2, naming its flag;
# a stopped app can't be read: pass the flags or start it); a failed lookup
# stops. A Lakebase project or catalog that is new for the app is checked
# against the other apps on the workspace. --dry-run stops after the settings,
# doing the same lookup, readback and check read-only and reporting "unknown"
# when the lookup fails.
#
# Each app has its own bundle root, ~/.bundle/vibe-modeling/<app-name>, so a
# second app installs next to the first, and a re-run with the other
# github-publish flag updates the same app. An app installed before that layout
# has its state copied from ~/.bundle/vibe-modeling/<target>; an existing app
# with no state anywhere is refused unless --adopt-existing-app.
#
# Steps 1 and 2 are in that order on purpose: provision needs the app's
# service principal, which doesn't exist until `bundle deploy` has registered
# the app. All steps are idempotent — safe to re-run on an already-installed
# workspace to pick up code or schema changes.
#
# Pre-requisites (all verified at step [0/5]; a missing critical one aborts,
# a databricks CLI below the minimum is refused, a python below it warns):
#   - `databricks` CLI (>= 1.20.0) authenticated under the target profile
#   - `python` (>= 3.11), `jq` on PATH
#   - `apx`, `uv`, `bun` on PATH — the bundle build hook
#     (install/build_and_render.sh -> `apx build`) drives uv (wheel) and
#     bun (frontend); a missing one fails `bundle deploy` at step [1/5].
#   - **databricks-sdk and psycopg Python packages** in the active env
#     (provision_lakebase.py imports both; grant_catalog.py imports the SDK):
#       python -m pip install 'databricks-sdk>=0.74' 'psycopg[binary]'
#       uv pip install 'databricks-sdk>=0.74' 'psycopg[binary]'
#     install.sh fail-fasts at step 0 if either is missing.
#
# Usage:
#   install/install.sh [--profile <cli-profile>] \
#       [--app-name vibe-modeling] \
#       [--project vibe-modeling] \
#       [--catalog vibe_modeling] [--database <postgres-db>] \
#       [--warehouse-id <sql-warehouse-id>] \
#       [--enable-taxonomy-builder [--taxonomy-model-service <catalog.schema.service>] | --disable-taxonomy-builder] \
#       [--enable-assessment [--assess-reader-sp <application_id>] | --disable-assessment] \
#       [--no-run-tags | --run-tags] \
#       [--enable-github-publish | --disable-github-publish] \
#       [--lakebase-min-cu <cu>] [--lakebase-max-cu <cu>] [--lakebase-resize] \
#       [--adopt-existing-app] [--allow-shared-resources] [--apply-without-plan-file] \
#       [--yes] [--dry-run]

set -euo pipefail

# shellcheck source=_feature_defaults.sh
source "$(dirname "$0")/_feature_defaults.sh"

APP_NAME="$DEFAULT_APP_NAME"
PROFILE=""
DRY_RUN="false"
LAKEBASE_RESIZE="false"
# Flags given on this run, as NAME=VALUE for install/deploy_settings.py; every
# setting not given keeps the running app's value (or the default on a first install).
SET_ARGS=()
TAXONOMY_FLAG=""
ASSESS_FLAG=""
RUN_TAGS_FLAG=""
GITHUB_FLAG=""
DATABASE_ARG=""
ASSUME_YES=""
ADOPT_FLAG=()
APPLY_FLAG=()

usage() {
  cat <<EOF
Usage: $0 [--profile <cli-profile>] [options]

For an app that exists, every setting is read from the running app and shown
before the installer asks to deploy it (the defaults below apply to a first
install); pass a flag only to change its value.

Options:
  --profile <name>        Databricks CLI profile (optional; omit for ambient/DEFAULT auth)
  --app-name <name>       Databricks App resource name (default: $DEFAULT_APP_NAME)
  --project <id>          Lakebase project ID (default: the app name)
  --catalog <name>        Unity Catalog name + Postgres database name (default: the app name
                          with '-' as '_', e.g. $DEFAULT_VIBE_MODELING_DEPLOYMENT_CATALOG for $DEFAULT_APP_NAME)
  --database <name>       Postgres database name when it differs from --catalog (a deployed
                          database that differs is kept when only --catalog is passed)
  --warehouse-id <id>     SQL warehouse ID for Delta polling (optional;
                          omit to configure via the first-run UI)
  --enable-taxonomy-builder
                          Install the optional Domain Taxonomy Builder (default: off)
  --disable-taxonomy-builder
                          Turn a deployed Domain Taxonomy Builder off
  --taxonomy-model-service <catalog.schema.service>
                          UC model service the builder drafts with (requires the
                          builder on; default: $DEFAULT_VIBE_MODELING_TAXONOMY_MODEL_SERVICE)
  --enable-assessment     Install the optional bronze assessment skill (default: off)
  --disable-assessment    Turn a deployed bronze assessment skill off
  --assess-reader-sp <application_id>
                          Reader service principal the assessment job runs as:
                          its application id (a UUID, not the display name;
                          requires the assessment on). Without it the
                          feature stays disabled until set in Settings ->
                          Platform (Optional features).
  --no-run-tags           Start with Settings -> "Annotate jobs with run tags" off
                          (default: on). Applied when the settings row is created and
                          on the first upgrade to 0.9.0 or later; Settings own it after that.
  --run-tags              Turn a deployed --no-run-tags back on (the seed is on by default)
  --enable-github-publish Deploy the github-publish bundle target, which grants the app
                          USE CONNECTION on the github_pr UC connection (create it first;
                          see INSTALL.md "Enabling publish-to-GitHub"). Re-runs keep it
                          (read from the app). On an installed app it updates the same app.
  --disable-github-publish
                          Deploy the default dev target (no github_pr grant); on an app
                          on github-publish it drops that grant. Without either flag an
                          existing app keeps the target read from it (github-publish
                          when it declares the github_pr connection).
  --lakebase-min-cu <cu>  Lakebase autoscaling minimum, in CU (default: $DEFAULT_VIBE_MODELING_LAKEBASE_MIN_CU)
  --lakebase-max-cu <cu>  Lakebase autoscaling maximum, in CU (default: $DEFAULT_VIBE_MODELING_LAKEBASE_MAX_CU;
                          0.5 <= min <= max <= 32, max - min <= 16). Applied when the
                          Lakebase project is created.
  --lakebase-resize       Also apply the min/max CU to an existing Lakebase project
                          (without it, a different range is only reported)
  --adopt-existing-app    Bind an existing app that no bundle state manages to this bundle
                          when the installer does not recognise it as a vibe-modeling app it
                          read (one it recognises and you created is bound without it). Prints
                          the app's creator and description first; without it the installer
                          refuses. When another identity created the app, it asks y/N (--yes skips).
  --allow-shared-resources
                          Keep a catalog that another app on the workspace also uses, when
                          this run points the app at it (apps installed before 0.9.0 that
                          already share the default need nothing). Without it the installer
                          refuses the share. A shared Lakebase project always refuses.
  --apply-without-plan-file
                          After the deploy plan check, apply with a plain `bundle deploy`
                          (for a CLI where `bundle deploy --plan` fails).
  --yes                   Deploy an existing app's settings without asking, and deploy
                          without asking when the in-flight runs check can't tell whether
                          runs are in flight, or when an app another identity created is
                          taken into this bundle with --adopt-existing-app (it asks y/N
                          otherwise, and refuses with no terminal). Runs in flight still refuse.
  --dry-run               Look the app up (read only), print the settings this run would
                          deploy and where each comes from (for an existing app, read from
                          it), check a new Lakebase project or catalog, then stop
  -h | --help             Show this message
EOF
}

_set() { SET_ARGS+=(--set "$1=$2"); }
_one_way() {  # $1 = the flag seen so far for this feature, $2 = this flag
  if [[ -n "$1" && "$1" != "$2" ]]; then
    echo "ERROR: $1 and $2 cannot be combined" >&2
    exit 2
  fi
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --profile) PROFILE="$2"; shift 2 ;;
    --app-name) APP_NAME="$2"; shift 2 ;;
    --project) _set VIBE_MODELING_LAKEBASE_PROJECT "$2"; shift 2 ;;
    --catalog) _set VIBE_MODELING_DEPLOYMENT_CATALOG "$2"; shift 2 ;;
    --database)
      [[ -n "${2:-}" ]] || { echo "ERROR: --database needs a name" >&2; exit 2; }
      DATABASE_ARG="$2"; shift 2 ;;
    --warehouse-id) _set VIBE_MODELING_WAREHOUSE_ID "$2"; shift 2 ;;
    --enable-taxonomy-builder|--disable-taxonomy-builder)
      _one_way "$TAXONOMY_FLAG" "$1"; TAXONOMY_FLAG="$1"
      _set VIBE_MODELING_TAXONOMY_BUILDER_ENABLED "$([[ "$1" == --enable-* ]] && echo true || echo false)"
      shift ;;
    --taxonomy-model-service) _set VIBE_MODELING_TAXONOMY_MODEL_SERVICE "${2:-}"; shift 2 ;;
    --enable-assessment|--disable-assessment)
      _one_way "$ASSESS_FLAG" "$1"; ASSESS_FLAG="$1"
      _set VIBE_MODELING_ASSESSMENT_ENABLED "$([[ "$1" == --enable-* ]] && echo true || echo false)"
      shift ;;
    --assess-reader-sp) _set VIBE_MODELING_ASSESS_READER_SP "${2:-}"; shift 2 ;;
    --no-run-tags|--run-tags)
      _one_way "$RUN_TAGS_FLAG" "$1"; RUN_TAGS_FLAG="$1"
      _set VIBE_MODELING_RUN_TAGS_DEFAULT "$([[ "$1" == --run-tags ]] && echo true || echo false)"
      shift ;;
    --enable-github-publish|--disable-github-publish)
      _one_way "$GITHUB_FLAG" "$1"; GITHUB_FLAG="$1"
      _set VIBE_MODELING_BUNDLE_TARGET "$([[ "$1" == --enable-* ]] && echo github-publish || echo dev)"
      shift ;;
    --lakebase-min-cu) _set VIBE_MODELING_LAKEBASE_MIN_CU "$2"; shift 2 ;;
    --lakebase-max-cu) _set VIBE_MODELING_LAKEBASE_MAX_CU "$2"; shift 2 ;;
    --lakebase-resize) LAKEBASE_RESIZE="true"; shift ;;
    --dry-run) DRY_RUN="true"; shift ;;
    --yes) ASSUME_YES="1"; shift ;;
    --adopt-existing-app) ADOPT_FLAG=(--adopt-existing-app); shift ;;
    --allow-shared-resources) _set VIBE_MODELING_ALLOW_SHARED_RESOURCES true; shift ;;
    --apply-without-plan-file) APPLY_FLAG=(--apply-without-plan-file); shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "ERROR: unknown argument: $1" >&2; usage >&2; exit 2 ;;
  esac
done
# Without --database, --catalog also names the Postgres database, unless the
# running app's database differs from its catalog (deploy_settings.py
# --database-follows-catalog keeps that one and says so).
[[ -n "$DATABASE_ARG" ]] && _set VIBE_MODELING_DATABASE_NAME "$DATABASE_ARG"

PROFILE_FLAGS=()
[[ -n "$PROFILE" ]] && PROFILE_FLAGS=(--profile "$PROFILE")

# The settings resolve needs only python (the stdlib), so flag and settings errors and
# --dry-run come before the tool and package checks below.
command -v python >/dev/null 2>&1 || { echo "ERROR: required tool 'python' not found in PATH" >&2; exit 2; }

cd "$(dirname "$0")/.."

# Merge this run's flags with the settings of the running app (else, for a new
# app, the defaults) and export the result: VIBE_MODELING_APP_NAME and every
# VIBE_MODELING_* value the artifacts hook (databricks.yml ->
# install/build_and_render.sh) renders into src/app/.build/app.yml; source
# src/app/app.yml is never modified. Ambient VIBE_MODELING_* variables are
# ignored: only flags change a value. Refuses (exit 2) a flag whose feature is
# off, an invalid value, and a Lakebase project (always) or catalog another app
# on the workspace uses; notes a bundle target switch.
#
# DATABASE_NAME drives the Postgres connection (the app's own state DB);
# DEPLOYMENT_CATALOG seeds AgentConfig.deployment_catalog on first boot.
# --catalog sets both because by convention the Postgres DB name matches the UC
# catalog name, but they're distinct downstream. The taxonomy model service and
# the assessment reader SP seed their settings while those are empty; the
# run-tags value seeds Settings -> Agent -> "Annotate jobs with run tags".
_load_settings() {  # $1 = the resolver's --shell output
  eval "$1"
  PROJECT="$VIBE_MODELING_LAKEBASE_PROJECT"
  DATABASE="$VIBE_MODELING_DATABASE_NAME"
  CATALOG="$VIBE_MODELING_DEPLOYMENT_CATALOG"
  WAREHOUSE_ID="$VIBE_MODELING_WAREHOUSE_ID"
  TAXONOMY_ENABLED="$VIBE_MODELING_TAXONOMY_BUILDER_ENABLED"
  TAXONOMY_MODEL_SERVICE="$VIBE_MODELING_TAXONOMY_MODEL_SERVICE"
  ASSESS_ENABLED="$VIBE_MODELING_ASSESSMENT_ENABLED"
  ASSESS_READER_SP="$VIBE_MODELING_ASSESS_READER_SP"
  RUN_TAGS="$VIBE_MODELING_RUN_TAGS_DEFAULT"
  TARGET="$VIBE_MODELING_BUNDLE_TARGET"
  LAKEBASE_MIN_CU="$VIBE_MODELING_LAKEBASE_MIN_CU"
  LAKEBASE_MAX_CU="$VIBE_MODELING_LAKEBASE_MAX_CU"
}

# Whether the app exists (install/_install_common.py app-exists: the app list's
# exit code and membership): prints `exists:<the app's JSON>`, `absent` or
# `error:<message>`.
_app_state() {
  local out rc=0
  out="$(python install/_install_common.py app-exists "$APP_NAME" ${PROFILE_FLAGS[@]:+"${PROFILE_FLAGS[@]}"} 2>&1)" \
    || rc=$?
  case "$rc" in
    0) echo "exists:$(printf '%s' "$out" | tr '\n' ' ')" ;;
    3) echo absent ;;
    *) echo "error:$(printf '%s' "${out:-exit $rc}" | tr '\n' ' ' | cut -c1-300)" ;;
  esac
}

# An app that exists: resolve without defaults, reading the settings from the
# running app (a flag still wins). A real run asks y/N every time (--yes takes
# the settings; no terminal refuses); a setting that can't be read refuses
# (exit 2) naming its flag. Only stdout is captured, so the question reaches the
# terminal on stderr and the answer comes from stdin.
_resolve_existing_app() {  # $1 = the app's JSON
  EXISTING="true"
  echo "    app '$APP_NAME' already exists: reading its settings from the running app"
  local confirm=()
  if [[ "$DRY_RUN" != "true" ]]; then
    confirm=(--confirm)
    [[ "$ASSUME_YES" == "1" ]] && confirm+=(--yes)
  fi
  SETTINGS_SH="$(python install/deploy_settings.py resolve --app-name "$APP_NAME" --profile "$PROFILE" \
    --ignore-env --install-flags --read-deployed ${confirm[@]:+"${confirm[@]}"} --database-follows-catalog \
    ${SET_ARGS[@]:+"${SET_ARGS[@]}"} --shell)" || exit $?
  _load_settings "$SETTINGS_SH"
  # A github_pr connection resource on the app means it runs the github-publish
  # target; --disable-github-publish would drop that grant. (No resource does not
  # prove dev: the grant can be applied outside the bundle.)
  if [[ "$TARGET" == "dev" ]] && printf '%s' "$1" | python install/_install_common.py uses-github-connection; then
    echo "ERROR: app '$APP_NAME' declares the github_pr UC connection resource, so it runs the github-publish" >&2
    echo "       target; pass --enable-github-publish instead of --disable-github-publish." >&2
    exit 2
  fi
}

# An app that does not exist yet: this run's flags over the defaults, and the
# check that a new Lakebase project or catalog is not another app's ($1:
# --no-guard skips that check, for a dry run that could not look the app up).
_resolve_new_app() {
  SETTINGS_SH="$(python install/deploy_settings.py resolve --app-name "$APP_NAME" --profile "$PROFILE" \
    --ignore-env --fresh-ok --database-follows-catalog ${1:+"$1"} ${SET_ARGS[@]:+"${SET_ARGS[@]}"} --shell)" \
    || exit $?
  _load_settings "$SETTINGS_SH"
}

echo "==> [0/5] Checking the flags"
python install/deploy_settings.py resolve --check --app-name "$APP_NAME" ${SET_ARGS[@]:+"${SET_ARGS[@]}"} || exit $?
EXISTING="false"

if [[ "$DRY_RUN" == "true" ]]; then
  # Look the app up (read only), and report "unknown" rather than fail when that is not possible.
  echo "==> [0/5] Resolving deploy settings"
  STATE="error:the databricks CLI is not on PATH"
  if command -v databricks >/dev/null 2>&1; then STATE="$(_app_state)"; fi
  case "$STATE" in
    exists:*) _resolve_existing_app "${STATE#exists:}" ;;
    absent)
      _resolve_new_app
      echo "    app '$APP_NAME' does not exist yet: a first install with the values above" ;;
    *)
      _resolve_new_app --no-guard
      echo "    could not tell whether app '$APP_NAME' exists (${STATE#error:}). The values above are a new" \
           "app's; if it exists, a real run reads its settings from it and asks to confirm them." ;;
  esac
  echo
  if [[ "$EXISTING" == "true" ]]; then
    echo "Dry run: would deploy app '$APP_NAME' with bundle target '$TARGET'. A real run shows these settings and" \
         "asks to confirm them (--yes takes them without asking). Nothing was deployed."
  else
    echo "Dry run: would deploy app '$APP_NAME' with bundle target '$TARGET'. Nothing was deployed."
  fi
  exit 0
fi

# CRITICAL tools. install.sh itself needs databricks/python/jq/curl; the bundle
# build hook (install/build_and_render.sh -> `apx build`) needs apx/uv/bun.
# A missing one fails the deploy, so abort up front rather than mid-install.
for cmd in databricks python jq curl apx uv bun; do
  command -v "$cmd" >/dev/null 2>&1 || { echo "ERROR: required tool '$cmd' not found in PATH" >&2; exit 2; }
done

# CRITICAL Python deps. provision_lakebase.py imports databricks.sdk AND psycopg;
# grant_catalog.py imports databricks.sdk. Verify both before we waste a bundle
# deploy on an env that will crash at step [2/5].
for mod in databricks.sdk psycopg; do
  if ! python -c "import $mod" >/dev/null 2>&1; then
    cat >&2 <<EOF
ERROR: required Python package providing '$mod' is not installed in the active env.

Install the install-time deps (one of the following, per your env manager):
  python -m pip install 'databricks-sdk>=0.74' 'psycopg[binary]'
  uv pip install 'databricks-sdk>=0.74' 'psycopg[binary]'

Then re-run install.sh.
EOF
    exit 2
  fi
done

# The deploy plans to JSON and applies that plan (`bundle deploy --plan`), which
# needs a minimum CLI: refuse below it (install/bundle_state.py MIN_CLI).
python install/bundle_state.py check-cli || exit $?

# NON-CRITICAL version check: warn (don't block) below the INSTALL.md minimum.
_below() { [[ "$(printf '%s\n%s\n' "$1" "$2" | sort -V | head -1)" != "$1" ]]; }  # true if $2 < $1
PY_VER=$(python -c 'import sys;print("%d.%d.%d"%sys.version_info[:3])' 2>/dev/null)
[[ -n "$PY_VER" ]] && _below "3.11.0" "$PY_VER" && \
  echo "WARN: python $PY_VER is below the required 3.11.0 (INSTALL.md)." >&2

echo
echo "==> [0/5] Verifying credentials (profile: ${PROFILE:-<ambient>})"
ME=$(databricks current-user me ${PROFILE_FLAGS[@]:+"${PROFILE_FLAGS[@]}"} --output json | jq -r .userName)
echo "    authenticated as: $ME"

# The defaults hold only for a first install: an existing app would be reset
# by them, so its settings are read from the running app.
echo
echo "==> [0/5] Resolving deploy settings"
STATE="$(_app_state)"
case "$STATE" in
  exists:*) _resolve_existing_app "${STATE#exists:}" ;;
  absent)
    _resolve_new_app
    echo "    app '$APP_NAME' does not exist yet: first install" ;;
  *)
    echo "ERROR: could not tell whether app '$APP_NAME' exists: ${STATE#error:}" >&2
    echo "       Fix the CLI authentication or network and re-run; nothing was deployed." >&2
    exit 1 ;;
esac

if [[ "$TARGET" == "github-publish" ]]; then
  # The github-publish target grants the app USE CONNECTION on github_pr; the
  # deploy fails without the connection, so stop before deploying anything.
  if ! databricks connections get github_pr ${PROFILE_FLAGS[@]:+"${PROFILE_FLAGS[@]}"} >/dev/null 2>&1; then
    echo "ERROR: the github-publish target needs the 'github_pr' UC connection, which this profile cannot" >&2
    echo "       read. Create it first (INSTALL.md 'Enabling publish-to-GitHub'), then re-run." >&2
    exit 1
  fi
  echo "    github_pr connection: found (github-publish target)"
fi

echo
echo "==> [0/5] in-flight runs guard"
# install.sh is idempotent — operators re-run it to pick up code or
# schema changes. If the App already exists AND has in-flight runs,
# refuse to proceed: an atomic-replace App container swap can't hand
# off in-memory pollers cleanly, so the next deploy would silently
# orphan those runs until the new container's lifespan re-attaches.
# Delegates to install/in_flight_guard.sh.
APP="$APP_NAME" PROFILE="$PROFILE" ASSUME_YES="$ASSUME_YES" bash install/in_flight_guard.sh

echo
echo "==> [1/5] databricks bundle plan + deploy (install/bundle_state.py)"
echo "    app_name=$APP_NAME, target=$TARGET, project=$PROJECT, UC catalog=$CATALOG, Lakebase DB=$DATABASE, warehouse_id=${WAREHOUSE_ID:-<unset, configure via UI>}"

# Pre-build src/app/.build before bundle deploy.
# databricks CLI v1.10.0 resolves sync.include paths before running the
# artifacts.default.build hook; if .build is absent the deploy fails with
# "stat src/app/.build: no such file or directory".
bash install/build_and_render.sh

# The app's bundle state (moved from an earlier layout, or adopted only with
# --adopt-existing-app), then `bundle plan` -> refuse a delete or recreate of
# the App -> `bundle deploy --plan` of that same plan.
YES_FLAG=()
[[ "$ASSUME_YES" == "1" ]] && YES_FLAG=(--yes)
# An app the readback recognised as this bundle's is bound when its bundle state is gone (--adopt-if-ours).
[[ "${DEPLOY_SETTINGS_RECOGNIZED:-false}" == "true" && ${#ADOPT_FLAG[@]} -eq 0 ]] && ADOPT_FLAG=(--adopt-if-ours)
python install/bundle_state.py deploy --app-name "$APP_NAME" --target "$TARGET" --profile "$PROFILE" \
  --ignore-env ${ADOPT_FLAG[@]:+"${ADOPT_FLAG[@]}"} ${APPLY_FLAG[@]:+"${APPLY_FLAG[@]}"} \
  ${YES_FLAG[@]:+"${YES_FLAG[@]}"} || exit $?

echo
echo "    Capturing app service principal"
APP_SP=$(databricks apps get "$APP_NAME" ${PROFILE_FLAGS[@]:+"${PROFILE_FLAGS[@]}"} --output json | jq -r .service_principal_client_id)
if [[ -z "$APP_SP" || "$APP_SP" == "null" ]]; then
  echo "ERROR: could not read service_principal_client_id from app '$APP_NAME'" >&2
  exit 1
fi
echo "    app SP: $APP_SP"

echo
echo "==> [2/5] python install/provision_lakebase.py"
RESIZE_FLAG=()
[[ "$LAKEBASE_RESIZE" == "true" ]] && RESIZE_FLAG=(--resize)
python install/provision_lakebase.py \
  ${PROFILE_FLAGS[@]:+"${PROFILE_FLAGS[@]}"} \
  --project "$PROJECT" \
  --catalog "$CATALOG" \
  --database "$DATABASE" \
  --app-sp  "$APP_SP" \
  --grant-user "$ME" \
  --min-cu "$LAKEBASE_MIN_CU" \
  --max-cu "$LAKEBASE_MAX_CU" \
  ${RESIZE_FLAG[@]:+"${RESIZE_FLAG[@]}"}

echo
echo "==> [3/5] python install/grant_catalog.py"
python install/grant_catalog.py \
  ${PROFILE_FLAGS[@]:+"${PROFILE_FLAGS[@]}"} \
  --catalog "$CATALOG" \
  --app-sp  "$APP_SP"

if [[ "$TAXONOMY_ENABLED" == "true" ]]; then
  echo
  echo "==> [3/5] python install/check_model_service.py (Domain Taxonomy Builder)"
  python install/check_model_service.py \
    ${PROFILE_FLAGS[@]:+"${PROFILE_FLAGS[@]}"} \
    --model-service "$TAXONOMY_MODEL_SERVICE" \
    --app-sp "$APP_SP"
fi

if [[ "$ASSESS_ENABLED" == "true" ]]; then
  echo
  if [[ -n "$ASSESS_READER_SP" ]]; then
    echo "==> [3/5] python install/check_model_service.py (bronze assessment reader, warn-only)"
    # The model service the assessment job's Genie Code CLI calls as the reader (pinned with the CLIs).
    ASSESS_MODEL_SERVICE=$(jq -r .genie_model_service src/app/vendored/assessment/VERSIONS.json)
    python install/check_model_service.py \
      ${PROFILE_FLAGS[@]:+"${PROFILE_FLAGS[@]}"} \
      --model-service "$ASSESS_MODEL_SERVICE" \
      --principal "$ASSESS_READER_SP" \
      --app-sp "$APP_SP" \
      || echo "    [warn] the reader check could not run; see INSTALL.md 'Enabling the in-app bronze assessment skill'."
  else
    echo "==> [3/5] bronze assessment: no --assess-reader-sp; the feature stays disabled until an"
    echo "    admin sets the reader in Settings -> Platform (Optional features)."
  fi
fi

echo
echo "==> [4/5] Starting app compute (if stopped)"
STATE=$(databricks apps get "$APP_NAME" ${PROFILE_FLAGS[@]:+"${PROFILE_FLAGS[@]}"} --output json | jq -r .compute_status.state)
if [[ "$STATE" != "ACTIVE" ]]; then
  databricks apps start "$APP_NAME" ${PROFILE_FLAGS[@]:+"${PROFILE_FLAGS[@]}"} >/dev/null
  for _ in {1..24}; do
    STATE=$(databricks apps get "$APP_NAME" ${PROFILE_FLAGS[@]:+"${PROFILE_FLAGS[@]}"} --output json | jq -r .compute_status.state)
    [[ "$STATE" == "ACTIVE" ]] && break
    echo "    compute state: $STATE (waiting 10s)"
    sleep 10
  done
fi
[[ "$STATE" == "ACTIVE" ]] || { echo "ERROR: compute did not reach ACTIVE (last: $STATE)" >&2; exit 1; }
echo "    compute state: ACTIVE"

# `apps start` on a stopped app redeploys its last deployment, and an `apps
# deploy` while that runs fails ("active deployment in progress"). The start's
# deployment shows first as `pending_deployment`, then within seconds as an
# `active_deployment` that is still IN_PROGRESS. Wait while either is (bounded,
# 10 minutes), then deploy the new source: the start's deployment serves the
# previous source path, so only the explicit deploy below runs the new code.
PENDING=""
for _ in {1..60}; do
  PENDING=$(databricks apps get "$APP_NAME" ${PROFILE_FLAGS[@]:+"${PROFILE_FLAGS[@]}"} --output json \
    | jq -r 'if ((.pending_deployment.status.state // "") == "IN_PROGRESS"
                 or (.active_deployment.status.state // "") == "IN_PROGRESS") then "IN_PROGRESS" else "" end')
  [[ "$PENDING" != "IN_PROGRESS" ]] && break
  echo "    a deployment of the app is in progress (waiting 10s)"
  sleep 10
done
if [[ "$PENDING" == "IN_PROGRESS" ]]; then
  echo "ERROR: a deployment of app '$APP_NAME' was still in progress after 10 minutes; re-run the installer" >&2
  echo "       once it has finished." >&2
  exit 1
fi

echo
echo "==> [5/5] databricks apps deploy"
BUNDLE_PATH="$(python install/bundle_state.py source-path --user "$ME" --app-name "$APP_NAME")"
databricks apps deploy "$APP_NAME" \
  --source-code-path "$BUNDLE_PATH" \
  ${PROFILE_FLAGS[@]:+"${PROFILE_FLAGS[@]}"} >/dev/null

echo "    waiting for app to reach RUNNING..."
for _ in {1..30}; do
  APP_STATE=$(databricks apps get "$APP_NAME" ${PROFILE_FLAGS[@]:+"${PROFILE_FLAGS[@]}"} --output json | jq -r .app_status.state)
  if [[ "$APP_STATE" == "RUNNING" ]]; then
    break
  fi
  if [[ "$APP_STATE" == "CRASHED" ]]; then
    echo "ERROR: app crashed. Last 60 lines of app logs:" >&2
    databricks apps logs "$APP_NAME" ${PROFILE_FLAGS[@]:+"${PROFILE_FLAGS[@]}"} --tail-lines 60 --source APP >&2 || true
    exit 1
  fi
  echo "    app_status: $APP_STATE"
  sleep 10
done

if [[ "$APP_STATE" != "RUNNING" ]]; then
  echo "ERROR: app did not reach RUNNING (last: $APP_STATE)" >&2
  exit 1
fi

echo
echo "==> [tag] tagging the app (warn-only)"
python install/tag_app.py ${PROFILE_FLAGS[@]:+"${PROFILE_FLAGS[@]}"} --app-name "$APP_NAME" \
  || echo "    [warn] app tagging did not run; see INSTALL.md 'Job and app tags'."

APP_URL=$(databricks apps get "$APP_NAME" ${PROFILE_FLAGS[@]:+"${PROFILE_FLAGS[@]}"} --output json | jq -r .url)

# Post-install verification of the things INSTALL.md promises a fresh install
# yields. WARN-ONLY: the app is already RUNNING (hard-checked above); these are
# eventually-consistent (the lifespan hook seeds industries + the catalog grant
# is best-effort), so surface gaps without failing a deploy that did its job.
echo
echo "==> [verify] post-install checks (warn-only)"
# `auth token` fails for some auth types (e.g. service-principal OAuth); under
# set -e -o pipefail that would end a successful install, so fall through to the warning.
VTOKEN="$(databricks auth token ${PROFILE_FLAGS[@]:+"${PROFILE_FLAGS[@]}"} --output json 2>/dev/null | jq -r '.access_token // empty' 2>/dev/null || true)"
if [[ -n "$VTOKEN" ]]; then
  CODE=$(curl -s -o /dev/null -w '%{http_code}' -H "Authorization: Bearer $VTOKEN" "$APP_URL/") || CODE=000
  [[ "$CODE" == "200" ]] && echo "    [ok]   homepage 200" \
    || echo "    [warn] homepage returned $CODE (expected 200)"
  INDC=$(curl -s -H "Authorization: Bearer $VTOKEN" "$APP_URL/api/industries" | jq 'length' 2>/dev/null || echo "?")
  [[ "$INDC" == "40" ]] && echo "    [ok]   industries seeded (40)" \
    || echo "    [warn] /api/industries returned '$INDC' (expected 40); the lifespan seed may still be running — re-check in ~30s"
  # Check actual Unity Catalog existence via the control plane, not the app's
  # /api/catalogs view: the deployment_catalog is a configured *name* that the
  # app reports as present regardless of whether the catalog exists, so an
  # app-side check gives a false "visible" on a fresh workspace where the
  # catalog has not been provisioned yet.
  if databricks catalogs get "$CATALOG" ${PROFILE_FLAGS[@]:+"${PROFILE_FLAGS[@]}"} >/dev/null 2>&1; then
    echo "    [ok]   catalog '$CATALOG' exists in Unity Catalog"
  else
    echo "    [warn] catalog '$CATALOG' does not exist yet — model-producing runs will fail until it"
    echo "           is provisioned (see [3/5] output and the Default Storage note under INSTALL.md 'Cloud and workspace')."
  fi
else
  echo "    [warn] could not mint a token for post-install checks; verify manually (INSTALL.md 'Verify the install')."
fi

cat <<EOF

Install complete.
  App name:          $APP_NAME
  Bundle target:     $TARGET
  App URL:           $APP_URL
  Lakebase project:  $PROJECT (autoscaling $LAKEBASE_MIN_CU-$LAKEBASE_MAX_CU CU requested)
  UC catalog:        $CATALOG
  Database name:     $DATABASE
  Warehouse ID:      ${WAREHOUSE_ID:-<unset — configure via first-run UI>}
  Taxonomy builder:  $TAXONOMY_ENABLED${TAXONOMY_MODEL_SERVICE:+ (model service: $TAXONOMY_MODEL_SERVICE)}
  Assessment:        $ASSESS_ENABLED${ASSESS_READER_SP:+ (reader SP: $ASSESS_READER_SP)}
  Run tags:          $RUN_TAGS (initial setting)
  App SP:            $APP_SP

Next: open the app URL. The app installs the bundled agent notebook on its
own during boot (see backend/core/_bundled_agent_init.py). To swap in a
different notebook, go to Settings -> Agent Configuration.
EOF
