from __future__ import annotations

import logging
from importlib import resources
from pathlib import Path
from typing import ClassVar, Literal

from dotenv import load_dotenv
from pydantic import Field
from pydantic_settings import BaseSettings, SettingsConfigDict

from ..._metadata import app_name, app_slug

project_root = Path(__file__).parent.parent.parent.parent.parent
env_file = project_root / ".env"

if env_file.exists():
    load_dotenv(dotenv_path=env_file)

class AppConfig(BaseSettings):
    model_config: ClassVar[SettingsConfigDict] = SettingsConfigDict(
        env_file=env_file,
        env_prefix=f"{app_slug.upper()}_",
        extra="ignore",
        env_nested_delimiter="__",
    )
    app_name: str = Field(default=app_name)
    warehouse_id: str = Field(default="", description="SQL warehouse ID for Delta table polling")
    # Used as the seed for AgentConfig.deployment_catalog when the row is
    # first created by the lazy get-or-create helper; thereafter the DB
    # column is authoritative and this env var is not consulted.
    deployment_catalog: str = Field(
        default="",
        description="UC catalog the agent uses for _metamodel + per-business deploys",
    )
    poll_interval_seconds: int = Field(
        default=10,
        description=(
            "Seconds between full orchestrator-advance ticks (Jobs API check + "
            "phase logic + handshake ack). Tighter cadence here costs cold-warehouse "
            "warm-ups; looser cadence delays terminal-state detection."
        ),
    )
    drain_interval_seconds: int = Field(
        default=5,
        description=(
            "Seconds between cheap event-drain ticks that mirror new "
            "_metamodel._vibe_progress rows into Lakebase. Decoupled from "
            "poll_interval_seconds because the drain is just one SELECT and "
            "should not be blocked behind a slow advance tick."
        ),
    )
    # Pre-launch compat hook for legacy STRING `_vibe_progress.result_json` vs
    # the v0.5.x agent's VARIANT INSERT (see backend.progress_schema).
    # - "drop"  (default): DROP a legacy STRING table, agent recreates as VARIANT.
    # - "alter": reserved for in-place ALTER COLUMN (not implemented).
    # - "off":   skip the repair entirely.
    progress_migrate_strategy: Literal["drop", "alter", "off"] = Field(
        default="drop",
        description="Strategy for repairing legacy _vibe_progress.result_json STRING schemas.",
    )
    # GitHub App read-auth credentials (deployment-wide, one App per install).
    # Authenticated source reads run at 5,000 req/hr and are immune to the target
    # org's SAML SSO (an installation token is a server-to-server token). App id
    # and installation id are non-secret plain env; the PEM is populated from a
    # Databricks app secret via app.yml `valueFrom` and is NEVER a literal.
    # When any of the three is empty, source reads fall back to anonymous
    # (60 req/hr, degraded auth_mode=anonymous) - the app still functions.
    github_app_id: str = Field(
        default="", description="GitHub App ID (VIBE_MODELING_GITHUB_APP_ID)."
    )
    github_app_installation_id: str = Field(
        default="",
        description="GitHub App installation ID (VIBE_MODELING_GITHUB_APP_INSTALLATION_ID).",
    )
    github_app_private_key: str = Field(
        default="",
        description=(
            "GitHub App RSA private key PEM (VIBE_MODELING_GITHUB_APP_PRIVATE_KEY), "
            "sourced from a Databricks app secret - never a literal."
        ),
    )
    # Domain Taxonomy Builder install-time switches, written into app.yml by
    # install/install.sh --enable-taxonomy-builder. Off by default, so the rest
    # of the app never depends on the feature. The model service is a SEED
    # only: it fills AgentConfig.taxonomy_model_service while that column is
    # empty, after which Settings owns the value and this is not consulted.
    taxonomy_builder_enabled: bool = Field(
        default=False,
        description="Whether the Domain Taxonomy Builder is installed (VIBE_MODELING_TAXONOMY_BUILDER_ENABLED)",
    )
    taxonomy_model_service: str = Field(
        default="",
        description=(
            "Install-default UC model service (catalog.schema.service) for the "
            "Domain Taxonomy Builder (VIBE_MODELING_TAXONOMY_MODEL_SERVICE)"
        ),
    )

    # Settings -> Agent -> "Annotate jobs with run tags", written into app.yml
    # by install/install.sh (--no-run-tags renders "false"). A SEED only: it
    # fills AgentConfig.collect_vibe_run_statistics when the row is created,
    # and migration v_0_9_0_2 applies it once to existing rows (its own frozen
    # copy of this bool parse); after that Settings own the value.
    run_tags_default: bool = Field(
        default=True,
        description=(
            "Seed for Settings -> Agent -> 'Annotate jobs with run tags' "
            "(VIBE_MODELING_RUN_TAGS_DEFAULT)"
        ),
    )

    # Headless Domain-Model Assessment install-time switches, written into
    # app.yml by install/install.sh --enable-assessment. Off by default: the
    # routes answer 404 and the poller does not start. The reader SP is a SEED
    # only: it fills AssessConfig.reader_application_id while that column is
    # empty, after which Settings -> Platform (Optional features) owns the value.
    assessment_enabled: bool = Field(
        default=False,
        description="Whether the bronze assessment skill is installed (VIBE_MODELING_ASSESSMENT_ENABLED)",
    )
    # Run change review (per-change Accept / Reject on a vibe run, Add rejected
    # as feedback, the version Overview summary). Hidden until its redesign:
    # off by default, no install flag; maintainers set the env var. While off,
    # its routes answer 404 and the UI shows none of it.
    run_change_review_enabled: bool = Field(
        default=False,
        description="Whether the run change review is shown (VIBE_MODELING_RUN_CHANGE_REVIEW_ENABLED)",
    )
    assess_reader_sp: str = Field(
        default="",
        description=("Install-default reader service principal: its application id, a UUID, not the display name "
                     "(VIBE_MODELING_ASSESS_READER_SP)"),
    )

    @property
    def taxonomy_install_default_model_service(self) -> str:
        """The install-time model service, ``""`` when the feature is not
        installed or no default was given. Seeds
        ``AgentConfig.taxonomy_model_service`` (on row creation, and for
        existing empty rows at boot) and backs Settings' Reset."""
        if not self.taxonomy_builder_enabled:
            return ""
        return self.taxonomy_model_service.strip()

    @property
    def static_assets_path(self) -> Path:
        return Path(str(resources.files(app_slug))).joinpath("__dist__")

    @property
    def github_app_credentials(self):
        """The deployment's :class:`GithubAppCredentials`, or ``None`` when any of
        the three fields is empty (drives the anonymous read fallback). Lazily
        imported to keep this config module import-light."""
        from ..sources.github import GithubAppCredentials

        if self.github_app_id and self.github_app_installation_id and self.github_app_private_key:
            return GithubAppCredentials(
                app_id=self.github_app_id,
                installation_id=self.github_app_installation_id,
                private_key_pem=self.github_app_private_key,
            )
        return None

    def __hash__(self) -> int:
        return hash(self.app_name)

# --- Logger ---

logger = logging.getLogger(app_name)


# PLAN #53 — make %(request_id)s available on every LogRecord, defaulting
# to "" so format strings work outside request scope. Attach the filter to
# the root logger and to the app-named logger so handlers in either chain
# pick it up. Idempotent: re-importing the module won't double-register.
def _install_request_id_log_filter() -> None:
    from ._request_id import RequestIdLogFilter

    flt = RequestIdLogFilter()
    for lg in (logging.getLogger(), logger):
        already = any(isinstance(f, RequestIdLogFilter) for f in lg.filters)
        if not already:
            lg.addFilter(flt)


_install_request_id_log_filter()
