"""Job launcher — session ID generation, parameter mapping, and Databricks job management."""

import io
import json
import logging
import unicodedata
import uuid
from typing import Any, Optional

from databricks.sdk import WorkspaceClient
from databricks.sdk.errors import NotFound
from databricks.sdk.service.jobs import JobSettings, NotebookTask, Task

from .core._intents import AGENT_OP_GENERATE_SAMPLES, AGENT_OP_INSTALL, AGENT_OP_UNINSTALL
from .. import __version__
from .core._headers import databricks_app_name
from .core._ids import session_id_to_bigint
from .core._job_tags import (
    IDENTITY_TAG_KEYS,
    LAUNCHER_SOURCE_APP,
    TAG_LAUNCHER_SOURCE,
    app_identity_tags,
)
from .core._names import agent_business_segment, normalize_scope, sanitize_tag
from .core._widgets import build_widget_map, empty_catalog_message, is_model_producing
from .db_models import AgentConfig, Business
from .error_sanitization import sanitize_error_message
from .progress_schema import ensure_progress_schema

logger = logging.getLogger(__name__)

# Re-export for backward compatibility with existing callers/tests.
__all__ = ["sanitize_tag", "session_id_to_bigint"]

# Databricks Jobs `run_now` rejects any individual notebook_params value over
# 2048 chars. Keep headroom below that so UTF-8 multi-byte content and any
# trailing server-side escaping never push a payload over the wire limit.
VIBE_INSTRUCTIONS_INLINE_LIMIT = 1800

# Aggregate cap on the JSON-encoded notebook_params payload Databricks Jobs
# `run_now` accepts. The platform refuses anything past 10,000 bytes; we keep
# a 500-byte safety margin for serialization quirks (escaping, surrogate
# pairs, server-side quoting) and to leave room for the run-time tags that
# get appended by the SDK.
WIDGET_PAYLOAD_HARD_LIMIT_BYTES = 10_000
WIDGET_PAYLOAD_SAFETY_MARGIN_BYTES = 500
WIDGET_PAYLOAD_LIMIT_BYTES = (
    WIDGET_PAYLOAD_HARD_LIMIT_BYTES - WIDGET_PAYLOAD_SAFETY_MARGIN_BYTES
)

# UI labels used in the rejection message when a payload exceeds the limit.
# Keys are the agent widget names; values are what the user sees on the
# Business edit page or the New Run form.
_WIDGET_UI_LABELS: dict[str, str] = {
    "business_description": "Business description",
    "industry_alignment": "Industry alignment",
    "business_domains": "Business domains",
    "model_vibes": "Vibe instructions",
    "classification_levels": "Classification levels",
    "org_divisions": "Organization divisions",
    "context_file": "Business context file path",
    "schema_prefix": "Schema prefix",
    "schema_suffix": "Schema suffix",
    "tag_prefix": "Tag prefix",
    "tag_suffix": "Tag suffix",
    "catalog_prefix": "Catalog prefix",
    "catalog_suffix": "Catalog suffix",
    "deployment_catalog": "Deployment catalog",
    "naming_convention": "Naming convention",
    "primary_key_suffix": "Primary key suffix",
    "table_id_type": "Table ID type",
    "boolean_format": "Boolean format",
    "date_format": "Date format",
    "timestamp_format": "Timestamp format",
    "cataloging_style": "Cataloging style",
    "operation": "Operation",
    "data_model_scopes": "Model scopes",
    "model_version": "Model version",
    "vibe_session_id": "Session ID",
    "business_name": "Business name",
    "housekeeping_columns": "Housekeeping columns",
    "history_tracking_columns": "History tracking columns",
    "vibe_scope": "Vibe scope",
    "run_type": "Run type",
    "runtime_budget_seconds": "Runtime budget",
}


class WidgetPayloadTooLargeError(RuntimeError):
    """Raised when the widget JSON exceeds Databricks Jobs' run_now budget
    even after offloading vibe instructions to Volume.

    Carries enough structured detail (`total_bytes`, `top_fields`) for the
    HTTP layer to translate into a 400 with an actionable message.
    """

    def __init__(self, total_bytes: int, top_fields: list[tuple[str, int]]):
        self.total_bytes = total_bytes
        self.top_fields = top_fields
        ranked = ", ".join(f"{name} ({size:,} bytes)" for name, size in top_fields)
        super().__init__(
            f"Run parameters total {total_bytes:,} bytes; the Databricks Jobs "
            f"limit is {WIDGET_PAYLOAD_LIMIT_BYTES:,} bytes. Largest fields: "
            f"{ranked}. Reduce these on the Business edit page or move "
            f"content into the Vibe instructions field."
        )


def _widget_payload_bytes(widgets: dict[str, str]) -> int:
    return len(json.dumps(widgets).encode("utf-8"))


def _top_widget_fields(
    widgets: dict[str, str], n: int = 3,
) -> list[tuple[str, int]]:
    sized = [
        (
            _WIDGET_UI_LABELS.get(k, k.replace("_", " ").title()),
            len(str(v).encode("utf-8")),
        )
        for k, v in widgets.items()
    ]
    sized.sort(key=lambda item: -item[1])
    return sized[:n]


def generate_session_id() -> str:
    """Generate a UUID v4 session ID string."""
    return str(uuid.uuid4())


# Lifecycle operations — no VibeWriter, Jobs API polling only
LIFECYCLE_OPS = frozenset({
    AGENT_OP_INSTALL,
    AGENT_OP_UNINSTALL,
    AGENT_OP_GENERATE_SAMPLES,
})


# Agent ``data_model_scopes`` widget labels keyed by the short scope
# ('ecm'/'mvm') stored on ModelVersion. The inverse of the model_size->label
# ``scope_map`` below; used when the scope is fixed by an existing version
# (a vibe-iterate targets a specific version whose scope cannot be re-chosen).
_SCOPE_SHORT_TO_LABEL: dict[str, str] = {
    "mvm": "Minimum Viable Model - MVM",
    "ecm": "Expanded Coverage Model - ECM",
}


def scope_label_for(scope_short: str) -> str:
    """Map a short scope ('ecm'/'mvm') to the agent's ``data_model_scopes``
    label. Unknown/empty falls back to ECM (the base scope)."""
    return _SCOPE_SHORT_TO_LABEL.get(
        (scope_short or "").lower(), _SCOPE_SHORT_TO_LABEL["ecm"]
    )


def map_run_params_to_widgets(
    operation: str,
    business: Business,
    catalog: str,
    session_id: str,
    *,
    runtime_budget_seconds: int,
    vibe_instructions: str = "",
    model_size: str = "small model",
    data_model_scopes: str = "",
    business_context_path: str = "",
    business_description_override: str = "",
    model_version: str = "",
    # Convention overrides (sensible defaults; exposed in UI later)
    naming_convention: str = "snake_case",
    primary_key_suffix: str = "_id",
    schema_prefix: str = "",
    schema_suffix: str = "",
    tag_prefix: str = "dbx_",
    tag_suffix: str = "",
    table_id_type: str = "BIGINT",
    boolean_format: str = "Boolean (True/False)",
    date_format: str = "yyyy-MM-dd",
    timestamp_format: str = "yyyy-MM-dd HH:mm:ss",
    cataloging_style: str = "One Catalog",
    catalog_prefix: str = "",
    catalog_suffix: str = "",
    org_divisions: str = "Operations",
    business_domains: str = "",
    classification_levels: str = "",
    housekeeping_columns: str = "No",
    history_tracking_columns: str = "No",
    vibe_scope: str = "All Domains",
    run_type: str = "Full Run",
) -> dict[str, str]:
    """Map app run parameters to monolith notebook widget values.

    Returns all ~28 widgets per the Integration Guide. Translates the
    caller's ``model_size`` ("small model"/"large model") into the agent's
    full ``data_model_scopes`` label, then delegates to the canonical
    ``core._widgets.build_widget_map``.

    ``data_model_scopes`` overrides the model_size-derived label when the
    caller already knows the scope (a vibe-iterate must run in the PARENT
    version's scope, which model_size cannot re-choose).

    ``runtime_budget_seconds`` is required: the caller passes the run's budget
    (see ``backend/runtime_budget.py``).
    """
    scope_map = {
        "small model": "Minimum Viable Model - MVM",
        "large model": "Expanded Coverage Model - ECM",
    }
    data_model_scopes = data_model_scopes or scope_map.get(model_size, model_size)

    return build_widget_map(
        operation=operation,
        data_model_scopes=data_model_scopes,
        business=business,
        catalog=catalog,
        session_id=session_id,
        runtime_budget_seconds=runtime_budget_seconds,
        vibe_instructions=vibe_instructions,
        business_context_path=business_context_path,
        business_description_override=business_description_override,
        model_version=model_version,
        naming_convention=naming_convention,
        primary_key_suffix=primary_key_suffix,
        schema_prefix=schema_prefix,
        schema_suffix=schema_suffix,
        tag_prefix=tag_prefix,
        tag_suffix=tag_suffix,
        table_id_type=table_id_type,
        boolean_format=boolean_format,
        date_format=date_format,
        timestamp_format=timestamp_format,
        cataloging_style=cataloging_style,
        catalog_prefix=catalog_prefix,
        catalog_suffix=catalog_suffix,
        org_divisions=org_divisions,
        business_domains=business_domains,
        classification_levels=classification_levels,
        housekeeping_columns=housekeeping_columns,
        history_tracking_columns=history_tracking_columns,
        vibe_scope=vibe_scope,
        run_type=run_type,
    )


def app_job_tags() -> dict[str, str]:
    """The app identity tags every job the app creates carries, always on.

    ``managed_by``, the deployed App's name (``DATABRICKS_APP_NAME``; left out
    outside the Apps runtime) and the app version (``vibe_modeling.__version__``).
    """
    return app_identity_tags(databricks_app_name(), __version__)


def build_job_tags(
    business_name: str = "",
    model_scope: str = "",
    version: str = "",
    operation: str = "",
    notebook_path: str = "",
    session_id: str = "",
    collect_statistics: bool = False,
) -> dict[str, str]:
    """Build the job tags applied to the persistent agent job per run.

    ``launch_run`` replaces the job's whole tag map with this set, so every
    always-on tag must be here.

    Always emitted (operational metadata only):
        the app identity tags (:func:`app_job_tags`: ``managed_by``,
        ``dbx_vibe_modelling_app``, ``dbx_vibe_modelling_app_version``),
        ``dbx_vibe_modelling_launcher_source``,
        ``dbx_vibe_modelling_model``, ``dbx_vibe_modelling_operation``,
        and the six count tags (domains, products, attributes,
        foreign_keys, tags, metrics) which start at ``"0"`` and are
        updated by the agent on completion.

    Identity-bearing (only when ``collect_statistics`` is True):
        ``dbx_vibe_modelling_business``, ``dbx_vibe_modelling_session_id``,
        ``dbx_vibe_modelling_notebook`` (filename only — the workspace
        folder path is stripped even when opted in).

    ``collect_statistics`` is Settings -> Agent -> "Annotate jobs with run
    tags" (``AgentConfig.collect_vibe_run_statistics``, on by default); read it
    through :func:`job_tags_for_config`.
    """
    scope_abbr = "mvm" if normalize_scope(model_scope) == "mvm" else "ecm"
    model_tag = f"{scope_abbr}_v{version}" if version else scope_abbr
    notebook_filename = notebook_path.rsplit("/", 1)[-1] if notebook_path else ""

    tags = {
        **app_job_tags(),
        TAG_LAUNCHER_SOURCE: LAUNCHER_SOURCE_APP,
        "dbx_vibe_modelling_model": sanitize_tag(model_tag),
        "dbx_vibe_modelling_operation": sanitize_tag(operation),
        "dbx_vibe_modelling_domains": "0",
        "dbx_vibe_modelling_products": "0",
        "dbx_vibe_modelling_attributes": "0",
        "dbx_vibe_modelling_foreign_keys": "0",
        "dbx_vibe_modelling_tags": "0",
        "dbx_vibe_modelling_metrics": "0",
    }
    if collect_statistics:
        identity = (business_name, session_id, notebook_filename)  # IDENTITY_TAG_KEYS order
        tags.update(zip(IDENTITY_TAG_KEYS, (sanitize_tag(v) if v else "" for v in identity), strict=True))
    return tags


def job_tags_for_config(
    cfg: Optional[AgentConfig],
    *,
    business_name: str = "",
    model_scope: str = "",
    version: str = "",
    operation: str = "",
    session_id: str = "",
) -> dict[str, str]:
    """The run's job tags, with the run-tags setting and notebook path read off ``cfg``.

    Every dispatch site goes through this (or :func:`build_job_tags_from_session`),
    so the setting has the same effect on every entry point.

    Tolerant of test doubles: a ``cfg`` whose fields are not a real bool/str
    (a ``MagicMock``) reads as setting off and no notebook. ``None`` (no row)
    is also off; production always has the row (it is created at boot).
    """
    collect = False
    notebook_path = ""
    if cfg is not None:
        cs = getattr(cfg, "collect_vibe_run_statistics", False)
        if isinstance(cs, bool):
            collect = cs
        nb = getattr(cfg, "notebook_path", "")
        if isinstance(nb, str):
            notebook_path = nb
    return build_job_tags(
        business_name=business_name,
        model_scope=model_scope,
        version=version,
        operation=operation,
        notebook_path=notebook_path,
        session_id=session_id,
        collect_statistics=collect,
    )


def build_job_tags_from_session(
    session: Any,
    *,
    business_name: str = "",
    model_scope: str = "",
    version: str = "",
    operation: str = "",
    session_id: str = "",
) -> dict[str, str]:
    """:func:`job_tags_for_config` for the singleton ``AgentConfig`` loaded through ``session``.

    For dispatch sites that have a Session but not the row. A lookup that
    raises (a bare ``MagicMock`` session in tests) reads as no row.
    """
    from sqlmodel import select

    try:
        cfg = session.exec(select(AgentConfig).limit(1)).first()
    except Exception:
        cfg = None
    return job_tags_for_config(
        cfg,
        business_name=business_name,
        model_scope=model_scope,
        version=version,
        operation=operation,
        session_id=session_id,
    )


def reset_or_create_job(ws: WorkspaceClient, *, job_id: Optional[int], settings: dict[str, Any],
                        raise_on_reset_error: bool = False) -> int:
    """Reset the stored job to ``settings``, or create it; returns the job id.

    ``settings`` holds ``JobSettings`` fields (also the ``jobs.create`` kwargs).
    A stored job that no longer exists (``NotFound``) is recreated. Any other
    reset failure is recreated too by default (the agent job: a Settings save
    must not fail on it), or re-raised with ``raise_on_reset_error=True`` (the
    assessment job: a failed sync is recorded rather than replaced).
    """
    if job_id:
        try:
            ws.jobs.reset(job_id=job_id, new_settings=JobSettings(**settings))
            return job_id
        except NotFound:
            pass
        except Exception:
            if raise_on_reset_error:
                raise
    return ws.jobs.create(**settings).job_id


def setup_agent_job(ws: WorkspaceClient, agent_config: AgentConfig) -> int:
    """Create or update the persistent Databricks job for the agent notebook.

    Idempotent: if `agent_config.job_id` already points at a reachable job,
    the notebook path and tags are reset on that job via `ws.jobs.reset`.
    Only creates a new Databricks Job on first save (or when the previously
    stored job has since been deleted from the workspace). This prevents a
    pile of orphan `dbx_vibe_modelling` jobs from accumulating every time
    Settings is saved.
    """
    tasks = [
        Task(
            task_key="run_agent",
            notebook_task=NotebookTask(notebook_path=agent_config.notebook_path),
        )
    ]
    tags = app_job_tags()

    # D-012 blocks concurrent user-launched runs. The app still needs a small
    # budget above 1 to cover two benign overlaps: (a) during unified-pipeline
    # phase transitions the finalizing run can briefly coexist with the next
    # phase's run_now, and (b) cancel-with-rollback can launch an uninstall
    # cleanup run while the cancelled run is still moving to TERMINATED.
    # 3 is the floor (AgentConfigIn enforces ge=3 server-side) — operators
    # can raise it via Settings -> Agent Configuration. Both reset() and
    # create() read this so a Settings save re-resets the job inside the
    # same PUT /api/config/agent request.
    max_concurrent_runs = agent_config.max_concurrent_runs

    # A reset failure re-creates the job rather than leave the stored job_id
    # dangling or crash the Settings save.
    return reset_or_create_job(
        ws,
        job_id=agent_config.job_id,
        settings=dict(
            name=agent_config.job_name,
            tasks=tasks,
            tags=tags,
            max_concurrent_runs=max_concurrent_runs,
        ),
    )


def _business_folder(name: str) -> str:
    return agent_business_segment(name)


def vibe_instructions_volume_path(catalog: str, business_name: str, session_id: str) -> str:
    """Return the canonical per-session Volume path for a run's vibe instructions.

    Lives as a sibling of version folders under the business:
    `/Volumes/{catalog}/_metamodel/vol_root/business/{name}/_vibe_inputs/{session_id}.txt`.
    """
    return (
        f"/Volumes/{catalog}/_metamodel/vol_root/business/"
        f"{_business_folder(business_name)}/_vibe_inputs/{session_id}.txt"
    )


def write_vibe_instructions_to_volume(
    ws: WorkspaceClient,
    catalog: str,
    business_name: str,
    session_id: str,
    instructions: str,
) -> str:
    """Upload vibe instructions to a per-session Volume file and return its path."""
    path = vibe_instructions_volume_path(catalog, business_name, session_id)
    payload = instructions.encode("utf-8")
    ws.files.upload(path, io.BytesIO(payload), overwrite=True)
    return path


def resolve_vibe_instructions_widget(
    ws: WorkspaceClient,
    catalog: str,
    business_name: str,
    session_id: str,
    instructions: str,
) -> tuple[str, str]:
    """Return `(widget_value, volume_path)` for the `model_vibes` widget.

    The agent's `model_vibes` widget accepts either inline text or a path
    starting with `/` (verified in vibe_modelling_agent v0.5.2:
    `_resolve_vibes_from_file` loads the file when the widget value starts
    with `/`). Short instructions are passed inline to avoid a Volume write;
    anything above `VIBE_INSTRUCTIONS_INLINE_LIMIT` is offloaded so we stay
    under the 2048-char run_now ceiling. `volume_path` is empty when we
    stay inline.
    """
    if not instructions or len(instructions) <= VIBE_INSTRUCTIONS_INLINE_LIMIT:
        return instructions, ""
    if not catalog:
        # No catalog means no Volume to write to. Fall back to inline and
        # let the run_now call surface the limit error itself — the caller
        # should have refused the run earlier on the "One Catalog" gate.
        return instructions, ""
    path = write_vibe_instructions_to_volume(
        ws, catalog, business_name, session_id, instructions
    )
    return path, path


def finalize_widgets_or_raise(
    ws: Any,
    widgets: dict[str, str],
    *,
    catalog: str,
    business_name: str,
    session_id: str,
    raw_vibes: str,
) -> dict[str, str]:
    """Apply per-value vibe offload + aggregate-payload check before
    handing widgets to ``run_now``.

    Order of operations:

    1. Compute the inline payload size.
    2. If vibe instructions exceed the per-value safe limit
       (``VIBE_INSTRUCTIONS_INLINE_LIMIT``), they MUST be offloaded — the
       Databricks platform rejects any single notebook_params value over
       2048 chars. We offload regardless of total payload size.
    3. Otherwise, if the inline total exceeds
       ``WIDGET_PAYLOAD_LIMIT_BYTES``, check whether offloading vibes
       would bring it under. If yes, offload. If no, skip the Volume
       write and fall through to the rejection path.
    4. Measure the map it would send (with the Volume path when it
       offloads) before writing anything. If the total still exceeds the
       limit, raise ``WidgetPayloadTooLargeError`` naming the three
       largest fields (using their UI labels) so the user can act; nothing
       is written (``plan_widget_payload``).

    No catalog or no vibes → no offload (no Volume to write to). In
    that case if the inline total is over the limit we go straight to
    rejection.
    """
    planned, offload = plan_widget_payload(
        widgets, catalog=catalog, business_name=business_name,
        session_id=session_id, raw_vibes=raw_vibes,
    )
    if offload:
        path = write_vibe_instructions_to_volume(ws, catalog, business_name, session_id, raw_vibes)
        planned = {**planned, "model_vibes": path}
    return planned


def plan_widget_payload(
    widgets: dict[str, str],
    *,
    catalog: str,
    business_name: str,
    session_id: str,
    raw_vibes: str,
) -> tuple[dict[str, str], bool]:
    """The widget map ``finalize_widgets_or_raise`` sends and whether it
    offloads the vibe instructions, without writing anything. Raises
    ``WidgetPayloadTooLargeError`` when the map is over the limit even after
    the offload, so a caller can refuse before it prepares the Volume."""
    total = _widget_payload_bytes(widgets)
    can_offload = bool(raw_vibes) and bool(catalog)
    must_offload_for_per_value = len(raw_vibes) > VIBE_INSTRUCTIONS_INLINE_LIMIT
    offloaded = {
        **widgets,
        "model_vibes": vibe_instructions_volume_path(catalog, business_name, session_id),
    }
    # Offload for the aggregate limit only when it brings the map under it.
    aggregate_offload_would_help = (
        total > WIDGET_PAYLOAD_LIMIT_BYTES
        and _widget_payload_bytes(offloaded) <= WIDGET_PAYLOAD_LIMIT_BYTES
    )
    offload = can_offload and (must_offload_for_per_value or aggregate_offload_would_help)
    planned = offloaded if offload else widgets
    total = _widget_payload_bytes(planned)
    if total > WIDGET_PAYLOAD_LIMIT_BYTES:
        raise WidgetPayloadTooLargeError(
            total_bytes=total,
            top_fields=_top_widget_fields(planned, n=3),
        )
    return planned, offload


_WIDGET_ASCII_TRANSLATIONS = str.maketrans({
    "\u2013": "-",   # en dash
    "\u2014": "-",   # em dash
    "\u2212": "-",   # minus sign
    "\u2018": "'",   # left single quote
    "\u2019": "'",   # right single quote
    "\u201c": '"',   # left double quote
    "\u201d": '"',   # right double quote
    "\u2026": "...", # horizontal ellipsis
    "\u00a0": " ",   # non-breaking space
    "\u2022": "*",   # bullet
    "\u00b7": "*",   # middle dot
})


def widget_value_to_ascii(value: str) -> str:
    """The exact ASCII form ``launch_run`` sends for one widget string value
    (see :func:`_sanitize_widget_params_to_ascii`). Preflight uses it to
    predict what the agent will receive."""
    translated = value.translate(_WIDGET_ASCII_TRANSLATIONS)
    return unicodedata.normalize("NFKD", translated).encode(
        "ascii", errors="ignore"
    ).decode("ascii")


def _sanitize_widget_params_to_ascii(
    widget_params: dict[str, str],
) -> dict[str, str]:
    """Replace non-Latin1 characters with ASCII equivalents.

    Databricks Jobs API `run_now` rejects notebook_params containing any
    non-Latin1 characters with an opaque "Only Latin1 (ASCII) characters are
    currently supported. Any international characters must be removed or
    replaced in notebook parameters" error. Pasted business contexts
    routinely include en/em dashes, typographic quotes, ellipses, and other
    smart-punctuation from copy/paste — sanitizing them transparently here
    is much friendlier than failing the launch.

    Translation uses a small explicit map for common typographic characters
    (preserves meaning — en-dash becomes hyphen, typographic quotes become
    ASCII quotes) then falls back to NFKD-normalize-then-ASCII-encode for
    everything else. Non-representable characters drop out rather than
    fail the run — this matches the "best-effort transport" semantics of
    widget parameters.
    """
    return {
        k: widget_value_to_ascii(v) if isinstance(v, str) else v
        for k, v in widget_params.items()
    }


def launch_run(
    ws: WorkspaceClient,
    job_id: int,
    widget_params: dict[str, str],
    job_tags: Optional[dict[str, str]] = None,
    warehouse_id: Optional[str] = None,
    progress_migrate_strategy: str = "drop",
) -> int:
    """Launch a run via run_now with notebook widget parameters. Returns databricks_run_id.

    widget_params are passed as notebook_params (the Jobs API field for notebook widget values).
    job_tags, if provided, are set on the job before launching for monitoring.
    Widget values are sanitized to ASCII before submission (see
    `_sanitize_widget_params_to_ascii`).

    For model-producing ops (see `is_model_producing`), best-effort repairs a
    legacy STRING `_vibe_progress.result_json` schema so the agent's v0.5.x
    VARIANT INSERTs don't fail (see backend.progress_schema). Requires
    `warehouse_id` — omitted or empty disables the hook.

    Raises ``ValueError`` before any workspace call for a model-producing op
    with an empty ``deployment_catalog`` (``core._widgets.empty_catalog_message``).
    """
    operation = widget_params.get("operation", "") if widget_params else ""
    catalog = (widget_params.get("deployment_catalog", "") if widget_params else "").strip()
    if is_model_producing(operation) and not catalog:
        raise ValueError(empty_catalog_message(operation))

    # Update job tags if provided (for per-run tag values). databricks-sdk
    # 0.112.0 rejects raw-dict `new_settings`; needs the typed JobSettings
    # object — the bare `except` below was masking that for the entire app's
    # lifetime, so tags never actually landed on the job. Use the typed form
    # and log failures so the next regression is loud, not silent.
    if job_tags:
        try:
            ws.jobs.update(
                job_id=job_id,
                new_settings=JobSettings(tags=job_tags),
            )
        except Exception as e:
            logger.warning(
                "launch_run: ws.jobs.update for tags failed (job_id=%s): %s",
                job_id, e,
            )

    # Pre-launch schema compat hook — model-producing ops only. Best-effort:
    # any failure is already swallowed inside ensure_progress_schema, and we
    # also guard here so a new bug in this path never blocks a launch.
    if warehouse_id and is_model_producing(operation):
        try:
            ensure_progress_schema(
                ws, warehouse_id, catalog,
                strategy=progress_migrate_strategy,
            )
        except Exception as e:
            logger.warning(
                "launch_run: ensure_progress_schema raised unexpectedly for "
                "catalog=%s: %s — continuing to launch.",
                catalog, e,
            )

    safe_params = _sanitize_widget_params_to_ascii(widget_params)
    try:
        result = ws.jobs.run_now(
            job_id=job_id,
            notebook_params=safe_params,
        )
    except Exception as exc:
        # The SDK error text can carry paths, emails and tokens, and callers
        # store this message on the run.
        logger.error("launch_run: run_now failed (job_id=%s): %r", job_id, exc)
        raise RuntimeError(
            f"Could not start the job ({type(exc).__name__}): {sanitize_error_message(str(exc))}"
        ) from exc
    # Extract run_id from Wait[Run] or direct response
    try:
        rid = result.response.run_id
        if isinstance(rid, int):
            return rid
    except (AttributeError, TypeError):
        pass
    rid = getattr(result, "run_id", None)
    if isinstance(rid, int):
        return rid
    logger.error(
        "launch_run: no run_id in the run_now result (job_id=%s): %r", job_id, result,
    )
    raise RuntimeError(
        f"Could not extract run_id from the job launch result (type {type(result).__name__})"
    )
