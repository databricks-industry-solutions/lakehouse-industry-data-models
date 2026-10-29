#!/usr/bin/env bash
# Build the apx artifacts and render src/app/.build/app.yml with the
# install-time settings. Invoked by databricks.yml's artifacts.default.build
# hook (and therefore by `databricks bundle deploy`), and by install/install.sh
# before it runs `bundle deploy`.
#
# The settings come from install/deploy_settings.py: the exported VIBE_MODELING_*
# values only (install.sh reads them from the running app and exports every
# one of them, plus VIBE_MODELING_APP_NAME); nothing is read from
# the workspace or from a file of an earlier run. The app name comes from
# VIBE_MODELING_APP_NAME or BUNDLE_VAR_app_name; the bundle hook also passes the
# app name and target the CLI deploys (`--app-name ${var.app_name} --target
# ${bundle.target} --profile ${workspace.profile}` in databricks.yml), and an
# exported name or target that differs refuses. It refuses (exit 2, before apx
# build) instead of resetting the app's settings: without an app name, or when
# any value rendered into app.yml or the bundle target is not exported (the
# message lists them, and points at `install.sh --dry-run`, which prints the
# values the app runs with). VIBE_MODELING_ALLOW_DEFAULT_SETTINGS=1 overrides that.
#
# Source src/app/app.yml is never modified: only the build output
# src/app/.build/app.yml is rewritten. The same assessment flag also renders
# install/.generated/app_scopes.yml (deleted when off), the databricks.yml
# include that gives the App its `workspace.workspace` user scope only when the
# assessment is on. `databricks bundle deploy` reads includes before it runs this
# build hook, so every deploy path runs this script first (install.sh and the
# other deploy scripts do); the hook run (`--bundle-hook`) fails the deploy with
# a re-run message when the fragment changed under it.

set -euo pipefail

# `--bundle-hook` (only databricks.yml's build hook passes it): fail the deploy
# when the user-scopes fragment changed, since the bundle already loaded the old one.
# With it, `--app-name` and `--target` are what the CLI deploys.
HOOK_FLAG=()
BUNDLE_ARGS=()
while [[ $# -gt 0 ]]; do
  case "$1" in
    --bundle-hook) HOOK_FLAG=(--bundle-hook); shift ;;
    --app-name) BUNDLE_ARGS+=(--bundle-app-name "${2:-}"); shift 2 ;;
    --target) BUNDLE_ARGS+=(--bundle-target "${2:-}"); shift 2 ;;
    # The CLI's profile (the hook can't see `--profile`).
    --profile) BUNDLE_ARGS+=(--profile "${2:-}"); shift 2 ;;
    *) echo "ERROR: build_and_render.sh: unknown argument: $1" >&2; exit 2 ;;
  esac
done

# Repo root is the parent of install/.
cd "$(dirname "$0")/.."

# Resolve (and print the source of) every setting before the build, so a
# refused deploy costs no apx build.
SETTINGS_SH="$(python install/deploy_settings.py resolve ${BUNDLE_ARGS[@]:+"${BUNDLE_ARGS[@]}"} --shell)" || exit $?
eval "$SETTINGS_SH"

# apx build re-runs `bun add --dev` for its own entrypoint packages; the guard
# fails the build when that moved package.json / bun.lock off the committed pins.
python install/frontend_lock_guard.py src/app -- apx build

python install/render_app_yaml.py \
  --in  src/app/app.yml \
  --out src/app/.build/app.yml \
  --project                "$VIBE_MODELING_LAKEBASE_PROJECT" \
  --database               "$VIBE_MODELING_DATABASE_NAME" \
  --deployment-catalog     "$VIBE_MODELING_DEPLOYMENT_CATALOG" \
  --warehouse-id           "$VIBE_MODELING_WAREHOUSE_ID" \
  --taxonomy-builder       "$VIBE_MODELING_TAXONOMY_BUILDER_ENABLED" \
  --taxonomy-model-service "$VIBE_MODELING_TAXONOMY_MODEL_SERVICE" \
  --assessment             "$VIBE_MODELING_ASSESSMENT_ENABLED" \
  --assess-reader-sp       "$VIBE_MODELING_ASSESS_READER_SP" \
  --run-tags               "$VIBE_MODELING_RUN_TAGS_DEFAULT" \
  --bundle-scopes-out      install/.generated/app_scopes.yml \
  ${HOOK_FLAG[@]:+"${HOOK_FLAG[@]}"}
