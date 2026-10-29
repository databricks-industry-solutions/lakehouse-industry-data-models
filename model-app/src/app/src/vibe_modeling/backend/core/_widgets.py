"""Single source of truth for the agent widget map.

The agent's notebook accepts ~30 widget parameters per run. Both
``job_launcher.map_run_params_to_widgets`` (the legacy/dispatch path) and
``services.operations._generation_common.build_generation_widgets`` (the
unified-DAG path) delegate here. Don't duplicate this dict — fix it once,
here.

Two thin wrappers exist for historical reasons (different caller shapes:
one takes ``model_size``, the other already takes the literal
``data_model_scopes`` label). Both translate their inputs and call
``build_widget_map``. A regression test in
``tests/test_app/test_widget_unification.py`` asserts both wrappers
produce identical output for the same logical input.
"""

from __future__ import annotations

from typing import Any

from ..models import normalize_boolean_format
from ..runtime_budget import RUNTIME_BUDGET_HOURS_KEY, runtime_budget_seconds as _seconds
from ._ids import session_id_to_bigint
from ._intents import AGENT_OP_GENERATE_SAMPLES, AGENT_OP_INSTALL, AGENT_OP_REVERT, AGENT_OP_UNINSTALL, AGENT_OP_VIBE, MODEL_PRODUCING_AGENT_OPS
from ._names import agent_business_segment

# Every map this module builds (:func:`build_widget_map`) or refreshes
# (:func:`refresh_stored_widgets`) carries the ``runtime_budget_seconds`` job
# base parameter: the run's budget, resolved by ``backend/runtime_budget.py``.
# The agent reads it first, then ``DATABRICKS_TASK_TIMEOUT_SECONDS`` (which
# Databricks never sets), then 14400 (nb 105565-105584; "a job base parameter
# (not a widget)", nb 90).
# Only generation paces itself by it: the VOV pipeline, the per-request
# verifier and the architect reviews (nb 22157, 46279, 46590, 66270, 67861);
# install and uninstall never read it (``_run_deploy_model`` nb 106573,
# ``_run_undeploy_model`` nb 108175), so the install and uninstall primitives'
# own maps don't carry it.

_DEFAULT_BOOLEAN_FORMAT = "Boolean (True/False)"


def _boolean_format_widget(value: str) -> str:
    """The agent's ``boolean_format`` label for ``value``; blank is the default.

    The agent turns any value it does not know into "Boolean (True/False)"
    without a warning (``_normalize_boolean_format_label``, nb 53854-53871), so
    an unknown value raises ``ValueError`` here instead.
    """
    if not str(value or "").strip():
        return _DEFAULT_BOOLEAN_FORMAT
    return normalize_boolean_format(value)


def refresh_stored_widgets(
    widgets: dict[str, Any], *, runtime_budget_hours: int
) -> dict[str, Any]:
    """A stored widget map brought to what :func:`build_widget_map` sends today.

    For replaying a map saved by an older app (the legacy retry): drops the
    retired ``generate_samples`` widget, rewrites ``boolean_format`` with the
    same rule (``ValueError`` for an unknown value) and sets
    ``runtime_budget_seconds`` from ``runtime_budget_hours`` (the caller reads
    them with ``runtime_budget.stored_runtime_budget_hours``). The stored
    ``runtime_budget_hours`` key is dropped: it is not a widget. Other keys are
    kept as stored.
    """
    out = dict(widgets)
    out.pop("generate_samples", None)
    out.pop(RUNTIME_BUDGET_HOURS_KEY, None)
    if "boolean_format" in out:
        out["boolean_format"] = _boolean_format_widget(out["boolean_format"])
    out["runtime_budget_seconds"] = str(_seconds(runtime_budget_hours))
    return out


# Operations that produce model artifacts via VibeWriter.
MODEL_PRODUCING_OPS: frozenset[str] = MODEL_PRODUCING_AGENT_OPS


def is_model_producing(operation: str) -> bool:
    return operation in MODEL_PRODUCING_OPS


def empty_catalog_message(operation: str) -> str:
    """The refusal of a model-producing op with no ``deployment_catalog``.

    The agent never refuses one: a blank widget makes it derive the business
    catalog from the business name (``business_catalog = sanitized_business``,
    nb 55985-55992), so the run writes ``_metamodel`` and schemas into a
    catalog nobody chose.
    """
    return (
        f"Operation {operation!r} needs a deployment catalog; got none. Set the "
        "metamodel catalog in Settings or pick a catalog on the run form."
    )


# Agent operations whose notebook widget validator requires a non-empty
# ``model_version`` value ("04. Version"). Dispatching one of these without
# the widget set causes the agent to abort at
# ``main.<locals>.get_widget_values`` with
# ``ValueError: ❌ MISSING REQUIRED VALUES``, BEFORE any progress event is
# written — so the App's run row sits as ``running`` forever while the job
# task has already terminated. Catching the empty value here, at the App
# boundary, surfaces the bug as a 4xx at submit-time instead.
#
# Source: the agent's per-op required-widget table (monolith line ~66099 in
# the v0.7.1-fold agent). When a new version-bound op is added agent-side,
# add it here too. See ``uninstall-diagnosis-2026-05-18.md``.
_AGENT_OPS_REQUIRING_MODEL_VERSION: frozenset[str] = frozenset({
    AGENT_OP_VIBE,
    AGENT_OP_INSTALL,
    AGENT_OP_UNINSTALL,
    AGENT_OP_GENERATE_SAMPLES,
    AGENT_OP_REVERT,
})


def build_widget_map(
    *,
    operation: str,
    data_model_scopes: str,
    business: Any,
    catalog: str,
    session_id: str,
    runtime_budget_seconds: int,
    vibe_instructions: str = "",
    business_context_path: str = "",
    business_description_override: str = "",
    model_version: str = "",
    naming_convention: str = "snake_case",
    primary_key_suffix: str = "_id",
    schema_prefix: str = "",
    schema_suffix: str = "",
    tag_prefix: str = "dbx_",
    tag_suffix: str = "",
    table_id_type: str = "BIGINT",
    boolean_format: str = _DEFAULT_BOOLEAN_FORMAT,
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
    """Build the canonical ~28-widget map a generation-group agent op expects.

    ``business`` may be a ``db_models.Business`` row or any object exposing
    ``.name``, ``.description``, and ``.industry_alignment``. We use
    ``getattr(...)`` defensively so test doubles (SimpleNamespace) and
    primitives invoked outside a request scope both work.

    Raises ``ValueError`` when ``operation`` is in
    :data:`_AGENT_OPS_REQUIRING_MODEL_VERSION` and ``model_version`` is empty
    or absent — these ops would otherwise dispatch a doomed run that the
    agent's notebook widget validator rejects on launch. The caller (route
    handler / orchestrator factory) must resolve the version first or 4xx.

    ``boolean_format`` goes out as the agent's label (blank means the
    default); an unknown value raises ``ValueError`` (see
    :func:`_boolean_format_widget`).

    ``runtime_budget_seconds`` has no default, so a caller that does not pass
    the run's budget fails loudly.

    Raises ``ValueError`` for a model-producing ``operation`` with an empty
    ``catalog`` (:func:`empty_catalog_message`).
    """
    if is_model_producing(operation) and not (catalog or "").strip():
        raise ValueError(empty_catalog_message(operation))
    if operation in _AGENT_OPS_REQUIRING_MODEL_VERSION and not model_version:
        raise ValueError(
            f"Operation {operation!r} requires a non-empty "
            f"`model_version`; got {model_version!r}. The App could not "
            "resolve a target ModelVersion for this run — pass `version_id` "
            "explicitly, or run new-base-model first."
        )
    widgets: dict[str, str] = {
        # Core operation params
        "operation": operation,
        "business_name": agent_business_segment(getattr(business, "name", "") or ""),
        "business_description": (
            business_description_override
            or (getattr(business, "description", "") or "")
        ),
        "context_file": business_context_path,
        "deployment_catalog": catalog,
        "data_model_scopes": data_model_scopes,
        "model_vibes": vibe_instructions,
        # Agent expects a BIGINT-as-string here. If we pass a UUID, the agent's
        # ``int(_raw_sid)`` parse fails and it generates its OWN session_id
        # internally, which means the app's progress_tracker (which queries
        # ``_business``/``_vibe_progress`` by the BIGINT we computed at launch
        # time) finds zero rows for the entire run. Convert via the SHA-256
        # truncation helper so the app's BIGINT and the agent's BIGINT match.
        "vibe_session_id": str(session_id_to_bigint(session_id)),
        "industry_alignment": getattr(business, "industry_alignment", "") or "",
        # Organization
        "business_domains": business_domains,
        "org_divisions": org_divisions,
        # Catalog layout
        "cataloging_style": cataloging_style,
        "catalog_prefix": catalog_prefix,
        "catalog_suffix": catalog_suffix,
        # Naming conventions
        "naming_convention": naming_convention,
        "primary_key_suffix": primary_key_suffix,
        "schema_prefix": schema_prefix,
        "schema_suffix": schema_suffix,
        "tag_prefix": tag_prefix,
        "tag_suffix": tag_suffix,
        # Type conventions
        "table_id_type": table_id_type,
        "boolean_format": _boolean_format_widget(boolean_format),
        "date_format": date_format,
        "timestamp_format": timestamp_format,
        # Governance
        "classification_levels": classification_levels,
        "housekeeping_columns": housekeeping_columns,
        "history_tracking_columns": history_tracking_columns,
        # Vibe scope and run type (agent widgets 06a and 03a)
        "vibe_scope": vibe_scope,
        "run_type": run_type,
        "runtime_budget_seconds": str(runtime_budget_seconds),
    }
    if model_version:
        widgets["model_version"] = model_version
    return widgets
