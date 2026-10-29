# Install-time defaults, one per deploy setting: the value a new app gets when
# no flag or environment variable supplies one.
#
# Sourced by install/install.sh (its --help text) and parsed by
# install/deploy_settings.py, which resolves every deploy (install.sh and the
# bundle build hook). Keep every line a plain
# double-quoted assignment with no expansion: deploy_settings.py reads this file
# without a shell and rejects any other form.
#
# The Lakebase project, database and catalog below are the default app's: a new
# app named <app> defaults to project <app> and to catalog and database <app>
# with '-' as '_' (deploy_settings.isolation_defaults).

DEFAULT_APP_NAME="vibe-modeling"
DEFAULT_VIBE_MODELING_LAKEBASE_PROJECT="vibe-modeling"
DEFAULT_VIBE_MODELING_DATABASE_NAME="vibe_modeling"
DEFAULT_VIBE_MODELING_DEPLOYMENT_CATALOG="vibe_modeling"
DEFAULT_VIBE_MODELING_WAREHOUSE_ID=""
DEFAULT_VIBE_MODELING_TAXONOMY_BUILDER_ENABLED="false"
DEFAULT_VIBE_MODELING_TAXONOMY_MODEL_SERVICE="system.ai.claude-sonnet-5-5"
DEFAULT_VIBE_MODELING_ASSESSMENT_ENABLED="false"
DEFAULT_VIBE_MODELING_ASSESS_READER_SP=""
DEFAULT_VIBE_MODELING_RUN_TAGS_DEFAULT="true"
DEFAULT_VIBE_MODELING_BUNDLE_TARGET="dev"
DEFAULT_VIBE_MODELING_LAKEBASE_MIN_CU="1"
DEFAULT_VIBE_MODELING_LAKEBASE_MAX_CU="4"
DEFAULT_VIBE_MODELING_ALLOW_SHARED_RESOURCES="false"
