"""Application configuration endpoints (`/api/config/*`).

Owns the agent notebook config + version compatibility surface, the
deployment-catalog setting, the warehouse picker, the initial-sync trigger,
and the out-of-band detection / import endpoints. All of these write or
read the singleton `AgentConfig` row (or its near neighbours), so they sit
in one module.
"""

from __future__ import annotations

import logging
import time
from datetime import datetime, timedelta, timezone

from typing import Annotated

from fastapi import APIRouter, Depends, HTTPException
from sqlmodel import select
from starlette.concurrency import run_in_threadpool

from ..._metadata import api_prefix
from ..agent_compat import (
    KNOWN_UPSTREAM_CHANGES,
    is_newer_tag,
    latest_known_upstream_tag,
)
from ..bundled_agent import resolve_bundled_agent
from ..core import Dependencies, resolve_metamodel_catalog
from ..core._agent_identity import (
    agent_owner,
    cached_identity_for_current_path,
    compare_to_bundled,
    record_read_identity,
    supports_scope,
)
from ..core._app_identity import app_sp_home_for_display
from ..core._bundled_agent_init import converge_agent_job_to_row
from ..core._errors import (
    CONFIG_REQUIREMENTS,
    model_service_refused_error,
    registry_scan_failed_error,
    setting_refused_error,
)
from ..core._identity import actor_label
from ..core._sql import SqlStatementError
from ..core._time import as_utc
from ..db_models import AgentConfig
from ..models import (
    AgentCompatChange,
    AgentCompatOut,
    AgentConfigIn,
    AgentConfigOut,
    DeploymentCatalogIn,
    GithubConfigIn,
    GithubConfigOut,
    MetamodelCatalogIn,
    SourceAuthConfigIn,
    SourceAuthConfigOut,
    WarehouseOut,
)
from ..job_launcher import setup_agent_job
from ..taxonomy.access import MODEL_SERVICE_ACCESS, REFUSED_CHECKS
from ..taxonomy.llm import error_text, llm_workspace_client, make_taxonomy_llm
from ..taxonomy.models import (
    TaxonomyCheckOut,
    TaxonomyConfigIn,
    TaxonomyConfigOut,
    TaxonomyModelServicesOut,
)
from ..taxonomy.service_name import split_model_service_name, strip_resource_prefix
from ..taxonomy.slots import DEFAULT_CAPACITY, TAXONOMY_SLOTS
from . import _helpers as _helpers_module
from ._helpers import (
    CATALOG_NAME_RULE,
    _build_dbx_job_url,
    _get_or_create_agent_config,
    _preflight_notebook_access,
    _check_notebook_release,
    fetch_upstream_agent_identity,
    is_catalog_name,
    require_config,
)
from .taxonomy import (
    TaxonomyLLMSettings,
    read_taxonomy_llm_settings,
    require_taxonomy_installed,
)

# Canonical upstream repo the release monitor compares against. The compat
# surface reads the agent notebook from here (the previous agent repo is
# retired).
_UPSTREAM_REPO_URL = (
    "https://github.com/databricks-industry-solutions/lakehouse-industry-data-models"
)

# How long a live upstream-identity read is cached on the AgentConfig singleton
# before the next request re-fetches (Surface 2). Seven days keeps the Settings
# page off the GitHub round-trip on the common path while still catching an
# upstream release within a week.
_UPSTREAM_CACHE_TTL = timedelta(days=7)

logger = logging.getLogger(__name__)

router = APIRouter(prefix=api_prefix)


# Tags whose vendored notebooks ship without an embedded `__AGENT_VERSION__` /
# `AGENT_VERSION` / `__version__` marker. For these the reachability check
# downgrades from "warning, can't verify" to "OK, assuming pinned tag" — the
# user has no way to add a marker themselves and we already shipped the exact
# notebook in `src/app/vendored/agent/`. Currently empty: every supported tag
# from v0.6.9 onward (and v0.7.1 in particular) stamps `__AGENT_VERSION__`,
# so the no-marker fallback is unused. Add a tag here only after confirming
# a future upstream release truly has no embedded marker.
_NO_MARKER_TAGS: frozenset[str] = frozenset()


# --- Agent Config ---


@router.get("/config/agent", response_model=AgentConfigOut, operation_id="getAgentConfig")
def get_agent_config(
    session: Dependencies.Session,
    ws: Dependencies.Client,
    config: Dependencies.Config,
):
    """Get current agent configuration. Lazily seeds the row from env vars on
    first read, so the Settings page sees the install-time defaults even
    before the user has saved anything."""
    cfg = _get_or_create_agent_config(session, config)
    return AgentConfigOut(
        **cfg.model_dump(),
        job_url=_build_dbx_job_url(ws, cfg.job_id),
    )


@router.get("/config/github", response_model=GithubConfigOut, operation_id="getGithubConfig")
def get_github_config(session: Dependencies.Session, config: Dependencies.Config):
    """Get the installation's GitHub publish/browse config (ADR D-049).

    Reads the github_* columns off the AgentConfig singleton. The token is
    never returned (it lives in the UC connection or a secret scope); only the
    pointers (connection name / secret scope+key) are surfaced."""
    from ..sources.github import DEFAULT_REPO_NAME, DEFAULT_REPO_OWNER

    cfg = _get_or_create_agent_config(session, config)
    # OUTPUT-layer effective value: a fresh row is seeded with the defaults, but
    # pre-existing rows may have empty github fields. Fall back to the public
    # industry-models repo (the same repo build_github_connector uses) so the
    # Settings page + source explorer show the source that browsing actually
    # uses, without a read-path write.
    return GithubConfigOut(
        repo_owner=cfg.github_repo_owner or DEFAULT_REPO_OWNER,
        repo_name=cfg.github_repo_name or DEFAULT_REPO_NAME,
        auth_mode=cfg.github_auth_mode,
        connection_name=cfg.github_connection_name,
        secret_scope=cfg.github_secret_scope,
        secret_key=cfg.github_secret_key,
    )


@router.put("/config/github", response_model=GithubConfigOut, operation_id="updateGithubConfig")
def update_github_config(
    data: GithubConfigIn,
    session: Dependencies.Session,
    config: Dependencies.Config,
    _role: Dependencies.BusinessAdminOnly,
):
    """Update the installation's GitHub publish/browse config (admin only)."""
    cfg = _get_or_create_agent_config(session, config)
    cfg.github_repo_owner = data.repo_owner
    cfg.github_repo_name = data.repo_name
    cfg.github_auth_mode = data.auth_mode
    cfg.github_connection_name = data.connection_name
    cfg.github_secret_scope = data.secret_scope
    cfg.github_secret_key = data.secret_key
    cfg.updated_at = datetime.now(timezone.utc)
    session.add(cfg)
    session.commit()
    session.refresh(cfg)
    return GithubConfigOut(
        repo_owner=cfg.github_repo_owner,
        repo_name=cfg.github_repo_name,
        auth_mode=cfg.github_auth_mode,
        connection_name=cfg.github_connection_name,
        secret_scope=cfg.github_secret_scope,
        secret_key=cfg.github_secret_key,
    )


def _source_auth_out(cfg, config, ws) -> SourceAuthConfigOut:
    """Assemble the SourceAuthConfigOut for the current ``AgentConfig`` row.

    Surfaces the persisted mode + non-secret ids + secret scope/key REFERENCES
    (never secret values) and computes the effective mode + degrade reason by
    resolving the transport the way a real read would (the secret read is
    short-TTL cached). Resolution never leaks scope/key/secret material into
    ``error``."""
    from ..sources.github import build_source_connector

    caps = build_source_connector(cfg, config, ws).capabilities()
    return SourceAuthConfigOut(
        auth_mode=cfg.source_auth_mode,
        github_app_id=cfg.source_github_app_id,
        github_app_installation_id=cfg.source_github_app_installation_id,
        github_app_secret_scope=cfg.source_github_app_secret_scope,
        github_app_secret_key=cfg.source_github_app_secret_key,
        token_secret_scope=cfg.source_token_secret_scope,
        token_secret_key=cfg.source_token_secret_key,
        effective_mode=caps.auth_mode,
        error=caps.auth_error,
    )


@router.get(
    "/config/source-auth",
    response_model=SourceAuthConfigOut,
    operation_id="getSourceAuthConfig",
)
def get_source_auth_config(
    session: Dependencies.Session,
    config: Dependencies.Config,
    ws: Dependencies.Client,
):
    """Get the installation's source READ-auth config (0.7.1).

    Reads the ``source_*`` columns off the AgentConfig singleton. Secret values
    are never returned — only the mode, the non-secret App ids, and the secret
    scope/key REFERENCES, plus the computed effective mode + degrade error."""
    cfg = _get_or_create_agent_config(session, config)
    return _source_auth_out(cfg, config, ws)


@router.put(
    "/config/source-auth",
    response_model=SourceAuthConfigOut,
    operation_id="updateSourceAuthConfig",
)
def update_source_auth_config(
    data: SourceAuthConfigIn,
    session: Dependencies.Session,
    config: Dependencies.Config,
    ws: Dependencies.Client,
    _role: Dependencies.BusinessAdminOnly,
):
    """Update the installation's source READ-auth config (admin only).

    Round-trips all fields so a partial save never NULLs a sibling reference
    (same rule the publish form follows). Secret material never crosses this
    boundary — only scope/key references are persisted."""
    cfg = _get_or_create_agent_config(session, config)
    cfg.source_auth_mode = data.auth_mode
    cfg.source_github_app_id = data.github_app_id
    cfg.source_github_app_installation_id = data.github_app_installation_id
    cfg.source_github_app_secret_scope = data.github_app_secret_scope
    cfg.source_github_app_secret_key = data.github_app_secret_key
    cfg.source_token_secret_scope = data.token_secret_scope
    cfg.source_token_secret_key = data.token_secret_key
    cfg.updated_at = datetime.now(timezone.utc)
    session.add(cfg)
    session.commit()
    session.refresh(cfg)
    return _source_auth_out(cfg, config, ws)


@router.get(
    "/config/agent/supported-version",
    response_model=dict,
    operation_id="getSupportedAgentVersion",
)
def get_supported_agent_version():
    """Return the exact agent release tag this app targets.

    See core/_defaults.SUPPORTED_AGENT_VERSION.
    """
    from ..core._defaults import SUPPORTED_AGENT_VERSION
    return {
        "version": SUPPORTED_AGENT_VERSION,
        "repo": "https://github.com/databricks-industry-solutions/lakehouse-industry-data-models",
        "repo_tag_url": (
            f"https://github.com/databricks-industry-solutions/lakehouse-industry-data-models/releases/tag/"
            f"{SUPPORTED_AGENT_VERSION}"
        ),
    }


def _fetch_upstream_agent_identity(config, cfg, ws) -> tuple[str | None, str | None]:
    """Live-read the canonical upstream agent notebook, returning
    ``(release_version, agent_marker)``.

    Module-level seam: the endpoint calls this by name so tests monkeypatch it
    rather than hitting GitHub. Builds the connector with the DEFAULT repo
    (``databricks-industry-solutions/lakehouse-industry-data-models`` @ ``main``)
    using the installation's resolved source read-auth (App / token / anonymous,
    env fallback when unconfigured); any referenced secret is read via the app
    service principal ``ws``. Reads the notebook via the repo-root fetch path.
    """
    from ..sources.github import build_source_connector

    connector = build_source_connector(cfg, config, ws)
    return fetch_upstream_agent_identity(connector)


def _same_release(a: str | None, b: str | None) -> bool:
    """True when two release identities name the same release (v-prefix agnostic)."""
    return a is not None and a.lstrip("v").strip() == (b or "").lstrip("v").strip()


@router.get(
    "/config/agent-compat",
    response_model=AgentCompatOut,
    operation_id="getAgentCompat",
)
def get_agent_compat(
    session: Dependencies.Session,
    config: Dependencies.Config,
    ws: Dependencies.Client,
) -> AgentCompatOut:
    """Upstream agent-availability monitor (Surface 2).

    Checks BOTH version numbers of the latest upstream agent against what the
    app pins and produces a three-way verdict:

    * upstream ``release_version`` NEWER than ``SUPPORTED_AGENT_VERSION`` →
      ``release_incompatible`` (``update_app_required=True``): the app's API
      calls target the pinned release and can't adapt, so the user must update
      the APP. No install offered.
    * same release, upstream ``agent_version`` NEWER than
      ``SUPPORTED_AGENT_MARKER`` → ``build_update_available``: same contract,
      newer build. Informational only.
    * otherwise → ``up_to_date``.

    The upstream identity is live-read from the canonical repo notebook and
    cached 7 days on the AgentConfig singleton. A stale/absent cache triggers a
    best-effort re-fetch: on any error the previously cached version values are
    kept and the error text is recorded, never a 500.

    The legacy ``latest_known_upstream`` / ``has_breaking_change`` /
    ``known_breaking_changes`` fields stay populated for back-compat consumers.

    The ``installed_*`` fields describe the configured notebook itself, as
    stored by the last identity read (boot, the Settings save, the switch
    route): this GET never exports the notebook or writes the identity,
    because the New Run form polls it. They are empty when the stored values
    were read from another path. ``installed_vs_bundled`` compares them with
    the bundled agent, ``scope_supported`` says whether scoped and Dry runs
    are available, and ``agent_owner`` says whether the app upgrades the
    notebook on boot (``app``) or the admin owns it (``admin``, Settings
    offers "Switch to bundled").
    """
    from ..core._defaults import SUPPORTED_AGENT_MARKER, SUPPORTED_AGENT_VERSION

    cfg = _get_or_create_agent_config(session, config)
    now = datetime.now(timezone.utc)

    checked_at = as_utc(cfg.upstream_checked_at)
    stale = checked_at is None or (now - checked_at) > _UPSTREAM_CACHE_TTL

    if stale:
        try:
            release, marker = _fetch_upstream_agent_identity(config, cfg, ws)
            if release is None and marker is None:
                # A successful fetch that yields NO markers (empty body, or the
                # upstream notebook renamed/moved its version constants) must not
                # clobber a known-good cache: that would silently flip a cached
                # release_incompatible to up_to_date for the whole TTL. Keep the
                # prior values and record why, so the miss is visible.
                cfg.upstream_check_error = (
                    "Fetched the upstream notebook but found no "
                    "__RELEASE_VERSION__ / __AGENT_VERSION__ markers; kept the "
                    "previous cached values."
                )
            else:
                cfg.upstream_release_version = release
                cfg.upstream_agent_version = marker
                cfg.upstream_check_error = None
        except Exception as e:  # best-effort: keep cached values, record error
            cfg.upstream_check_error = f"{type(e).__name__}: {str(e)[:400]}"
        cfg.upstream_checked_at = now
        session.add(cfg)
        session.commit()
        session.refresh(cfg)

    pinned_release = SUPPORTED_AGENT_VERSION
    pinned_marker = SUPPORTED_AGENT_MARKER
    up_release = cfg.upstream_release_version
    up_marker = cfg.upstream_agent_version

    verdict = "up_to_date"
    update_app_required = False
    if up_release and is_newer_tag(up_release, pinned_release):
        verdict = "release_incompatible"
        update_app_required = True
    elif (
        up_marker
        and _same_release(up_release, pinned_release)
        and is_newer_tag(up_marker, pinned_marker)
    ):
        verdict = "build_update_available"

    newer = verdict != "up_to_date"

    # Back-compat: the legacy latest-upstream tag + known-breaking-change walk.
    # ``latest_known_upstream`` reflects the live upstream release when known,
    # else the in-tree matrix's latest tag.
    latest_up = up_release or latest_known_upstream_tag()
    breaking: list[AgentCompatChange] = []
    any_breaking = False
    for tag, entries in KNOWN_UPSTREAM_CHANGES.items():
        if not is_newer_tag(tag, pinned_release):
            continue
        if is_newer_tag(tag, latest_up):
            continue
        for e in entries:
            if e.get("severity") == "breaking":
                any_breaking = True
                breaking.append(
                    AgentCompatChange(
                        tag=tag,
                        severity=str(e.get("severity", "info")),
                        area=str(e.get("area", "")),
                        summary=str(e.get("summary", "")),
                    )
                )

    compare_url = ""
    if verdict == "release_incompatible" and up_release:
        compare_url = f"{_UPSTREAM_REPO_URL}/compare/{pinned_release}...{up_release}"

    bundled = resolve_bundled_agent()
    identity = cached_identity_for_current_path(cfg)
    configured = bool(cfg.notebook_path)

    return AgentCompatOut(
        pinned_version=pinned_release,
        latest_known_upstream=latest_up,
        newer_available=newer,
        has_breaking_change=any_breaking,
        known_breaking_changes=breaking,
        repo_compare_url=compare_url,
        pinned_release=pinned_release,
        pinned_agent_marker=pinned_marker,
        latest_upstream_release=up_release,
        latest_upstream_marker=up_marker,
        verdict=verdict,
        update_app_required=update_app_required,
        install_offered=False,
        checked_at=cfg.upstream_checked_at,
        check_error=cfg.upstream_check_error,
        installed_release_version=identity.release,
        installed_agent_version=identity.marker,
        installed_checked_at=identity.checked_at,
        installed_checked_path=identity.path,
        installed_check_error=identity.error,
        bundled_agent_marker=bundled.agent_version if bundled else None,
        installed_vs_bundled=(
            compare_to_bundled(identity.release, identity.marker, bundled) if configured else None
        ),
        agent_owner=agent_owner(cfg.notebook_path, app_sp_home_for_display(ws)),
        scope_supported=supports_scope(identity.marker),
    )


@router.get(
    "/config/agent/ready",
    response_model=dict,
    operation_id="getAgentReady",
)
def get_agent_ready(
    session: Dependencies.Session,
    ws: Dependencies.Client,
    config: Dependencies.Config,
):
    """Summarise whether the app can launch runs right now. The UI uses this to
    gate the "New Run" button and show why it's disabled.

    Returns `{ready: bool, reason?: str}`. Intentionally consolidates three
    failure modes into a single boolean so the button can be disabled uniformly:
      1. No notebook saved yet (the bootstrapped AgentConfig row exists but
         ``notebook_path`` is empty)
      2. AgentConfig has no job_id (save completed but job creation failed)
      3. The app SP can no longer access the configured notebook path
    """
    cfg = _get_or_create_agent_config(session, config)
    if not cfg.notebook_path:
        return {"ready": False, "reason": "No agent notebook is configured. Go to Settings → Agent Configuration."}
    if not cfg.job_id:
        return {"ready": False, "reason": "Agent is configured but no Databricks job exists yet. Re-save the agent configuration."}
    if not resolve_metamodel_catalog(session, config):
        return {
            "ready": False,
            "reason": (
                "No metamodel catalog is configured. The agent writes its "
                "`_metamodel` schema and `vol_root` volume there. Set one in "
                "Settings → Platform before launching a run."
            ),
        }
    try:
        ws.workspace.get_status(cfg.notebook_path)
    except Exception as e:
        return {
            "ready": False,
            "reason": (
                f"The app service principal can no longer access the notebook "
                f"'{cfg.notebook_path}' ({str(e)[:120]}). Restore access or "
                f"point at a different notebook in Settings."
            ),
        }
    return {"ready": True}


@router.get(
    "/config/agent/check-notebook",
    response_model=dict,
    operation_id="checkAgentNotebook",
)
def check_agent_notebook(path: str, ws: Dependencies.Client):
    """Live check: can the app SP see the notebook at `path`? And does its
    declared version match the agent version the app targets?

    Returns one of:
    - `{ok: true, version: "v0.5.2"}` — reachable and version matches
    - `{ok: true, warning: "…"}` — reachable but no version marker (user should
      verify with agent maintainers that the notebook is the right tag)
    - `{ok: false, reason: "…"}` — unreachable, or version mismatch
    """
    from ..core._defaults import SUPPORTED_AGENT_VERSION
    if not path:
        return {"ok": False, "reason": "Notebook path is required."}
    try:
        ws.workspace.get_status(path)
    except Exception as e:
        return {"ok": False, "reason": str(e)[:200]}

    try:
        release, marker = _helpers_module._detect_notebook_identity(ws, path)
    except Exception as e:
        # Surface the read-side error verbatim so the user knows what
        # actually failed (e.g. SDK API misuse, transient export error,
        # permission edge case). The previous bare-except inside the
        # detector swallowed these as "no marker", masking real bugs.
        return {
            "ok": False,
            "reason": (
                f"Could not read the notebook source to verify the "
                f"version marker: {type(e).__name__}: {str(e)[:300]}"
            ),
        }
    if release is None:
        # Some upstream tags ship without an embedded version marker — for
        # those we know about, treat reachability + the pinned release as
        # enough rather than asking the user to "confirm with the agent
        # maintainers" (a dead-end action when we already shipped that exact
        # notebook in `src/app/vendored/agent/`).
        if SUPPORTED_AGENT_VERSION in _NO_MARKER_TAGS:
            return {
                "ok": True,
                "version": SUPPORTED_AGENT_VERSION,
                "message": (
                    f"Reachable; assuming {SUPPORTED_AGENT_VERSION} "
                    f"(no embedded marker)."
                ),
            }
        return {
            "ok": True,
            "warning": (
                f"Notebook is reachable, but has no `__RELEASE_VERSION__` / "
                f"`__AGENT_VERSION__` marker — the app can't verify it matches "
                f"release {SUPPORTED_AGENT_VERSION}. Confirm with the agent "
                f"maintainers."
            ),
        }
    # Gate on the release version (tracks the app-agent interface); the agent
    # marker is a per-fix build counter reported for display only.
    if release.lstrip("v") != SUPPORTED_AGENT_VERSION.lstrip("v"):
        build = f" (agent build {marker})" if marker else ""
        return {
            "ok": False,
            "reason": (
                f"Notebook declares release '{release}'{build} but this app "
                f"targets agent release '{SUPPORTED_AGENT_VERSION}'."
            ),
        }
    return {"ok": True, "version": SUPPORTED_AGENT_VERSION, "marker": marker}


@router.put("/config/agent", response_model=AgentConfigOut, operation_id="setAgentConfig")
def set_agent_config(
    data: AgentConfigIn,
    session: Dependencies.Session,
    ws: Dependencies.Client,
    config: Dependencies.Config,
    _role: Dependencies.AdminOnly,
):
    """Configure the agent notebook path and create the persistent Databricks job.

    The notebook is exported once: its identity both gates the release and is
    stored in the identity cache with the save. After the commit the job is
    re-read and pointed at the saved path if it names another notebook.
    """
    _preflight_notebook_access(ws, data.notebook_path)
    release, marker = _helpers_module._detect_notebook_identity(ws, data.notebook_path)
    _check_notebook_release(release)

    cfg = _get_or_create_agent_config(session, config)
    cfg.notebook_path = data.notebook_path
    cfg.max_concurrent_runs = data.max_concurrent_runs
    if data.collect_vibe_run_statistics is not None:
        cfg.collect_vibe_run_statistics = data.collect_vibe_run_statistics
    if data.runtime_budget_hours is not None:
        cfg.runtime_budget_hours = data.runtime_budget_hours
    cfg.updated_at = datetime.now(timezone.utc)
    session.add(cfg)

    # Create or update the Databricks job. The reset/create flow inside
    # setup_agent_job reads agent_config.max_concurrent_runs so a settings
    # change here takes effect on the persistent job in the same request.
    try:
        job_id = setup_agent_job(ws, cfg)
        cfg.job_id = job_id
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to create Databricks job: {e}")

    record_read_identity(cfg, path=data.notebook_path, release=release, marker=marker)
    session.add(cfg)
    session.commit()
    # A Settings save racing another save, or the boot upgrade, could leave
    # the job on another notebook; re-read it and point it at the saved path.
    converge_agent_job_to_row(session, ws, cfg.id)
    session.refresh(cfg)
    return AgentConfigOut(
        **cfg.model_dump(),
        job_url=_build_dbx_job_url(ws, cfg.job_id),
    )


@router.post("/config/agent/verify", response_model=dict, operation_id="verifyAgentConfig")
def verify_agent_config(
    data: AgentConfigIn,
    ws: Dependencies.Client,
    _role: Dependencies.AdminOnly,
):
    """Verify the notebook path exists in the workspace (as seen by the app SP)."""
    _preflight_notebook_access(ws, data.notebook_path)
    return {"valid": True, "message": f"Notebook reachable at {data.notebook_path}"}


# --- Metamodel catalog (concern A) ---
#
# The setting formerly labeled "deployment catalog" is the METAMODEL catalog:
# the UC catalog holding the agent's `_metamodel` Delta schema + `vol_root`
# Volume, and the default target of a run's `deployment_catalog` widget (see
# core._catalogs). The DB column keeps its name (`deployment_catalog`); the
# API/UI vocabulary is `metamodel_catalog`. The `/config/metamodel-catalog`
# endpoints are canonical; the `/config/deployment-catalog` endpoints are kept
# one release as thin delegates for older clients and are deprecated.


@router.get(
    "/config/deployment-catalog",
    response_model=dict,
    operation_id="getDeploymentCatalog",
)
def get_deployment_catalog(
    session: Dependencies.Session,
    config: Dependencies.Config,
):
    """DEPRECATED alias of getMetamodelCatalog. Get the configured metamodel
    catalog under the legacy `deployment_catalog` key. Lazily seeded from the
    env var on first read. Prefer GET /config/metamodel-catalog."""
    cfg = _get_or_create_agent_config(session, config)
    return {
        "deployment_catalog": cfg.deployment_catalog,
        "is_configured": bool(cfg.deployment_catalog),
    }


@router.put(
    "/config/deployment-catalog",
    response_model=dict,
    operation_id="setDeploymentCatalog",
)
def set_deployment_catalog(
    data: DeploymentCatalogIn,
    session: Dependencies.Session,
    config: Dependencies.Config,
    _role: Dependencies.AdminOnly,
):
    """DEPRECATED alias of setMetamodelCatalog. Set the metamodel catalog via
    the legacy `deployment_catalog` key. Prefer PUT /config/metamodel-catalog.
    A name the agent can't take (``CATALOG_NAME_PATTERN``, the rule the
    Settings form and every run check) is refused with 400 ``setting_refused``
    and nothing is saved; an empty value clears the setting."""
    catalog = data.deployment_catalog
    if catalog and not is_catalog_name(catalog):
        raise setting_refused_error(
            "metamodel_catalog",
            f"The catalog name '{catalog[:255]}' isn't a Unity Catalog name the app can use: {CATALOG_NAME_RULE}.",
        )
    cfg = _get_or_create_agent_config(session, config)
    cfg.deployment_catalog = catalog
    cfg.updated_at = datetime.now(timezone.utc)
    session.add(cfg)
    session.commit()
    session.refresh(cfg)
    return {
        "deployment_catalog": cfg.deployment_catalog,
        "is_configured": bool((cfg.deployment_catalog or "").strip()),
    }


@router.get(
    "/config/metamodel-catalog",
    response_model=dict,
    operation_id="getMetamodelCatalog",
)
def get_metamodel_catalog(
    session: Dependencies.Session,
    config: Dependencies.Config,
):
    """Get the configured metamodel catalog (concern A). Lazily seeded from the
    env var on first read. Delegates to the legacy deployment-catalog reader and
    re-keys the response under the concern-A vocabulary."""
    legacy = get_deployment_catalog(session, config)
    return {
        "metamodel_catalog": legacy["deployment_catalog"],
        "is_configured": legacy["is_configured"],
    }


@router.put(
    "/config/metamodel-catalog",
    response_model=dict,
    operation_id="setMetamodelCatalog",
)
def set_metamodel_catalog(
    data: MetamodelCatalogIn,
    session: Dependencies.Session,
    config: Dependencies.Config,
    _role: Dependencies.AdminOnly,
):
    """Set the metamodel catalog (concern A). Delegates to the legacy
    deployment-catalog writer (same underlying column) and re-keys the
    response under the concern-A vocabulary."""
    legacy = set_deployment_catalog(
        DeploymentCatalogIn(deployment_catalog=data.metamodel_catalog),
        session,
        config,
        _role,
    )
    return {
        "metamodel_catalog": legacy["deployment_catalog"],
        "is_configured": legacy["is_configured"],
    }


# --- Warehouse ---


@router.get(
    "/config/warehouses",
    response_model=list[WarehouseOut],
    operation_id="listWarehouses",
)
def list_warehouses(ws: Dependencies.Client):
    """List available SQL warehouses in the workspace."""
    warehouses = ws.warehouses.list()
    return [
        WarehouseOut(
            id=wh.id,
            name=wh.name,
            state=wh.state.value if wh.state else "UNKNOWN",
            cluster_size=wh.cluster_size or "",
            warehouse_type=wh.warehouse_type.value if wh.warehouse_type else "",
        )
        for wh in warehouses
        if wh.id and wh.name
    ]


@router.get("/config/warehouse", response_model=dict, operation_id="getWarehouse")
def get_warehouse(session: Dependencies.Session, config: Dependencies.Config):
    """Get the configured warehouse ID. Lazily seeded from the env var on first read."""
    cfg = _get_or_create_agent_config(session, config)
    return {"warehouse_id": cfg.warehouse_id, "is_configured": bool(cfg.warehouse_id)}


@router.put("/config/warehouse", response_model=dict, operation_id="setWarehouse")
def set_warehouse(
    data: dict,
    session: Dependencies.Session,
    config: Dependencies.Config,
    _role: Dependencies.AdminOnly,
):
    """Set the SQL warehouse for Delta table polling and sync."""
    wh_id = data.get("warehouse_id", "")
    cfg = _get_or_create_agent_config(session, config)
    cfg.warehouse_id = wh_id
    cfg.updated_at = datetime.now(timezone.utc)
    session.add(cfg)
    session.commit()
    session.refresh(cfg)
    return {
        "warehouse_id": cfg.warehouse_id,
        "is_configured": bool((cfg.warehouse_id or "").strip()),
    }


@router.post(
    "/config/initial-sync",
    response_model=dict,
    operation_id="triggerInitialSync",
)
def trigger_initial_sync(
    session: Dependencies.Session,
    ws: Dependencies.Client,
    config: Dependencies.Config,
    _role: Dependencies.AdminOnly,
):
    """Trigger initial sync — discovers businesses from the deployment catalog."""
    from ..initial_sync import InitialSyncService

    require_config(session, config, ["metamodel_catalog", "warehouse"], mode="raise")
    cfg = _get_or_create_agent_config(session, config)

    svc = InitialSyncService(session, ws, cfg.warehouse_id)
    try:
        summary = svc.discover_and_sync(resolve_metamodel_catalog(session, config))
    except SqlStatementError as exc:
        session.rollback()
        raise registry_scan_failed_error(exc.message) from exc
    session.commit()
    return summary


# --- Domain Taxonomy Builder ---
#
# Settings for the optional wizard (/api/taxonomy/*). GET is open to every
# role (the landing page and the wizard read ``ready``) and answers even when
# the feature is not installed; the rest are AdminOnly and 404 when it is not.
# Values live on the AgentConfig singleton. A non-empty model service must
# pass a test call as the app SP before it is saved (taxonomy/access.py).

TaxonomyInstalled = Annotated[None, Depends(require_taxonomy_installed)]
StoredTaxonomySettings = Annotated[TaxonomyLLMSettings, Depends(read_taxonomy_llm_settings)]

# The UC list ignores ``max_results``; ``page_size`` is honoured, at most 200
# (test workspace, 2026-10-19). It counts services scanned, not returned, so pages come
# back with only the services the caller can see and the list must follow
# ``next_page_token``. Unfiltered on purpose: ``catalog_name``/``schema_name``
# are ignored too, and the SP may see services in any schema. Each page goes
# through the LLM's bounded client (``taxonomy/llm.llm_workspace_client``: 90 s
# per call, 1 s retry budget), the same one the probe's service lookup uses,
# so a slow page cannot hold the request for the SDK's 300 s retry budget.
MODEL_SERVICES_LIST_PATH = "/api/2.1/unity-catalog/model-services"
MODEL_SERVICES_PAGE_SIZE = 200
MODEL_SERVICES_MAX_PAGES = 50
# The deadline is checked between pages: once it has passed, no further page
# is requested and the list returns what it has with the partial-list
# message. The worst case is about this long plus one page (90 s).
MODEL_SERVICES_DEADLINE_SECONDS = 120
# The wizard calls chat completions; services that declare other API types
# only (embeddings) are left out of the picker. A service that declares none
# is kept.
CHAT_API_TYPE = "mlflow/v1/chat/completions"


def _taxonomy_config_out(session, config) -> TaxonomyConfigOut:
    """The one place ``ready`` is computed: installed, a model service is set,
    and its last test call (this process) was not refused. Never checked and
    ``busy`` count as ready. A refusal - in Settings or when a draft is
    refused - hides the wizard until a test call succeeds: a Test or Save, or
    the background re-probe ``get_taxonomy_config`` starts once the refusal
    is older than ``REFUSED_RECHECK_AFTER``."""
    cfg = _get_or_create_agent_config(session, config)
    installed = bool(config.taxonomy_builder_enabled)
    service = (cfg.taxonomy_model_service or "").strip()
    last_check = MODEL_SERVICE_ACCESS.last_check(service) if service else None
    refused = bool(service) and MODEL_SERVICE_ACCESS.is_refused(service)
    return TaxonomyConfigOut(
        installed=installed,
        model_service=service,
        install_default_model_service=config.taxonomy_install_default_model_service,
        max_concurrency=cfg.taxonomy_llm_max_concurrency,
        ready=installed and bool(service) and not refused,
        last_check=last_check,
        updated_by=cfg.taxonomy_updated_by,
        updated_at=as_utc(cfg.taxonomy_updated_at),
    )


def _save_taxonomy_config(session, config, model_service: str, max_concurrency: int, user: str) -> TaxonomyConfigOut:
    """Write the taxonomy settings and their audit pair (``taxonomy_updated_by`` /
    ``taxonomy_updated_at``, as ``assess_config`` records ``updated_by`` / ``updated_at``)."""
    cfg = _get_or_create_agent_config(session, config)
    cfg.taxonomy_model_service = model_service
    cfg.taxonomy_llm_max_concurrency = max_concurrency
    cfg.taxonomy_updated_by = user
    cfg.taxonomy_updated_at = datetime.now(timezone.utc)
    session.add(cfg)
    session.commit()
    session.refresh(cfg)
    return _taxonomy_config_out(session, config)


@router.get("/config/taxonomy", response_model=TaxonomyConfigOut, operation_id="getTaxonomyConfig")
def get_taxonomy_config(session: Dependencies.Session, config: Dependencies.Config):
    """Whether the Domain Taxonomy Builder is installed and ready, its model
    service and concurrency limit, and the last test call's result. When the
    last check is refused and stale, starts one background re-probe and
    answers with the current state at once; the next read shows the result.
    Not installed: answers ``installed=false`` without touching the
    AgentConfig row (no read, no lazy create)."""
    if not config.taxonomy_builder_enabled:
        return TaxonomyConfigOut(
            installed=False,
            model_service="",
            install_default_model_service="",
            max_concurrency=DEFAULT_CAPACITY,
            ready=False,
            last_check=None,
        )
    out = _taxonomy_config_out(session, config)
    if out.installed and out.model_service:
        MODEL_SERVICE_ACCESS.maybe_recheck(
            out.model_service, lambda: make_taxonomy_llm(out.model_service), TAXONOMY_SLOTS,
        )
    return out


@router.put("/config/taxonomy", response_model=TaxonomyConfigOut, operation_id="updateTaxonomyConfig")
async def update_taxonomy_config(
    data: TaxonomyConfigIn,
    session: Dependencies.Session,
    config: Dependencies.Config,
    headers: Dependencies.Headers,
    _installed: TaxonomyInstalled,
    _role: Dependencies.AdminOnly,
):
    """Save the model service and concurrency limit. A non-empty service must
    be ``catalog.schema.service`` (422) and pass the test call: ``denied``,
    ``not_found`` and ``error`` refuse with 400 ``model_service_refused`` and
    save nothing; ``busy`` saves, and ``last_check`` carries the warning.
    Clearing is allowed only when there is no install default (Reset writes
    the default instead). Records who saved and when."""
    service = data.model_service.strip()
    if service:
        try:
            split_model_service_name(service)
        except ValueError as e:
            raise HTTPException(status_code=422, detail=str(e)) from e
    elif config.taxonomy_install_default_model_service:
        raise HTTPException(
            status_code=422,
            detail=(
                f"This installation has a default model service "
                f"('{config.taxonomy_install_default_model_service}'). Reset to it instead of clearing."
            ),
        )
    if service:
        check = await MODEL_SERVICE_ACCESS.probe(make_taxonomy_llm(service), TAXONOMY_SLOTS)
        if check.status in REFUSED_CHECKS:
            raise model_service_refused_error("taxonomy_llm", check.status, check.message)
    return await run_in_threadpool(
        _save_taxonomy_config, session, config, service, data.max_concurrency, actor_label(headers),
    )


@router.post("/config/taxonomy/test", response_model=TaxonomyCheckOut, operation_id="testTaxonomyModelService")
async def run_taxonomy_model_service_test(
    _installed: TaxonomyInstalled,
    _role: Dependencies.AdminOnly,
    settings: StoredTaxonomySettings,
):
    """Run the test call against the stored model service and record it as
    ``last_check``. With no service stored, returns an ``error`` result and
    records nothing."""
    if not settings.model_service:
        return TaxonomyCheckOut(
            status="error",
            message=CONFIG_REQUIREMENTS["taxonomy_llm"]["message"],
            checked_at=MODEL_SERVICE_ACCESS.now(),
        )
    return await MODEL_SERVICE_ACCESS.probe(make_taxonomy_llm(settings.model_service), TAXONOMY_SLOTS)


def _model_service_sort_key(name: str) -> tuple[bool, str]:
    return (name.startswith("system.ai."), name.lower())


@router.get(
    "/config/taxonomy/model-services",
    response_model=TaxonomyModelServicesOut,
    operation_id="listTaxonomyModelServices",
)
def list_taxonomy_model_services(
    _installed: TaxonomyInstalled,
    _role: Dependencies.AdminOnly,
):
    """The UC model services the app service principal can see, for the
    Settings picker. On failure returns ``[]`` plus a message, and Settings
    falls back to free text."""
    names: set[str] = set()
    token: str | None = None
    deadline = time.monotonic() + MODEL_SERVICES_DEADLINE_SECONDS
    try:
        ws = llm_workspace_client()
        for page in range(MODEL_SERVICES_MAX_PAGES):
            if page and time.monotonic() >= deadline:
                break
            query: dict[str, object] = {"page_size": MODEL_SERVICES_PAGE_SIZE}
            if token:
                query["page_token"] = token
            resp = ws.api_client.do("GET", MODEL_SERVICES_LIST_PATH, query=query)
            if not isinstance(resp, dict):
                raise TypeError(f"unexpected list response: {type(resp).__name__}")
            for item in resp.get("model_services") or []:
                api_types = item.get("supported_api_types")
                if api_types and CHAT_API_TYPE not in api_types:
                    continue
                name = strip_resource_prefix(str(item.get("name") or ""))
                try:
                    split_model_service_name(name)
                except ValueError:
                    continue
                names.add(name)
            token = resp.get("next_page_token")
            if not token:
                break
    except Exception as e:  # noqa: BLE001 - any failure falls back to free text
        logger.warning("Listing model services failed: %s", e)
        return TaxonomyModelServicesOut(services=[], message=f"Couldn't list model services: {error_text(e)}")
    message = None
    if token:
        message = "Not every model service could be listed. Type the full name if yours is missing."
    return TaxonomyModelServicesOut(services=sorted(names, key=_model_service_sort_key), message=message)
