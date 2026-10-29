"""The structured HTTP errors the optional features and the config gates share.

One builder per error class, each with one status, so a route never picks a
status for a shape on its own:

- an unset setting: 422 ``config_missing`` (:func:`config_missing_error`);
- a setting whose value a Save check refused: 400 ``model_service_refused``
  for a model service (:func:`model_service_refused_error`), 400
  ``setting_refused`` for any other setting (:func:`setting_refused_error`);
- a run-time failure only an admin can fix: 409 ``admin_help``
  (:func:`admin_help_error`);
- a caller without identity or without the workspace email a route needs:
  401 ``identity_missing`` (:func:`identity_missing_error`, raised through
  ``core/_identity``);
- a scan of the agent's model registry (``_metamodel.business``) that failed:
  503 ``oob_scan_failed`` (:func:`registry_scan_failed_error`), also for the
  orphan-schema check's registry read;
- a request that changes something it did not confirm: 422
  ``needs_confirmation`` (:func:`needs_confirmation_error`), the run create
  and the orphan-schema drop;
- a write to a business's versions outside a run while a run of it is
  active or another request holds its lock: 409 ``run_active`` /
  ``business_busy`` (:func:`business_locked_error`).

Every detail is ``{error, message, ...}``: ``error`` is the discriminator the
UI keys on, ``message`` is the sentence it shows. The other keys are
structural and pass the error handler unchanged (``error_sanitization``).
"""

from __future__ import annotations

from fastapi import HTTPException

CONFIG_MISSING = "config_missing"
MODEL_SERVICE_REFUSED = "model_service_refused"
SETTING_REFUSED = "setting_refused"
ADMIN_HELP = "admin_help"
IDENTITY_MISSING = "identity_missing"
REGISTRY_SCAN_FAILED = "oob_scan_failed"
NEEDS_CONFIRMATION = "needs_confirmation"
RUN_ACTIVE = "run_active"
BUSINESS_BUSY = "business_busy"

# One entry per configuration requirement key (``routes/_helpers.require_config``).
# ``label`` + ``settings_url`` drive the UI's config-missing deep-link;
# ``field_path`` keys the run-form blocker; ``message`` is the blocker text.
CONFIG_REQUIREMENTS: dict[str, dict[str, str]] = {
    "agent_job": {
        "label": "Agent notebook & job",
        "settings_url": "/settings?tab=agent",
        "field_path": "(agent_config.notebook_path)",
        "message": (
            "Agent is not configured. Set the notebook path in "
            "Settings → Agent before running this operation."
        ),
    },
    "metamodel_catalog": {
        "label": "Metamodel catalog",
        "settings_url": "/settings?tab=platform",
        "field_path": "(agent_config.deployment_catalog)",
        "message": (
            "No metamodel catalog is configured. The agent writes its "
            "`_metamodel` schema and `vol_root` Volume there. Set one in "
            "Settings → Platform."
        ),
    },
    "warehouse": {
        "label": "SQL warehouse",
        "settings_url": "/settings?tab=platform",
        "field_path": "(agent_config.warehouse_id)",
        "message": (
            "No SQL warehouse is configured. Progress polling and model sync "
            "need it. Set one in Settings → Platform."
        ),
    },
    "taxonomy_llm": {
        "label": "Domain Taxonomy Builder model service",
        "settings_url": "/settings?tab=platform",
        "field_path": "(agent_config.taxonomy_model_service)",
        "message": (
            "No model service is configured for the Domain Taxonomy Builder. "
            "An admin must choose one in Settings → Platform."
        ),
    },
    "source_repo": {
        "label": "Industry-models source repo",
        "settings_url": "/settings?tab=sources",
        "field_path": "(agent_config.github_repo_owner)",
        "message": (
            "No industry-models source repository is configured. Set the "
            "owner/name in Settings → Sources."
        ),
    },
}


def config_missing_error(keys: str | list[str], message: str | None = None) -> HTTPException:
    """The 422 ``config_missing`` error for the requirement ``keys``.

    ``message`` defaults to one sentence naming every missing setting.
    ``require_config`` and the run pre-flight build their error here too, so
    the payload has one definition.
    """
    keys = [keys] if isinstance(keys, str) else list(keys)
    if message is None:
        labels = ", ".join(CONFIG_REQUIREMENTS[k]["label"] for k in keys)
        message = f"Missing required configuration: {labels}. Configure it in Settings, then retry."
    return HTTPException(
        status_code=422,
        detail={
            "error": CONFIG_MISSING,
            "missing": [
                {
                    "key": k,
                    "label": CONFIG_REQUIREMENTS[k]["label"],
                    "settings_url": CONFIG_REQUIREMENTS[k]["settings_url"],
                }
                for k in keys
            ],
            "message": message,
        },
    )


def config_requirement_key(field_path: str) -> str | None:
    """The requirement key of a ``require_config`` collect-mode blocker."""
    for key, spec in CONFIG_REQUIREMENTS.items():
        if spec["field_path"] == field_path:
            return key
    return None


def model_service_refused_error(key: str, status: str, message: str) -> HTTPException:
    """400 ``model_service_refused``: the model service set for ``key`` failed
    its test call (``status`` is the test call's ``denied`` / ``not_found`` /
    ``error``)."""
    return HTTPException(
        status_code=400,
        detail={"error": MODEL_SERVICE_REFUSED, "key": key, "status": status, "message": message},
    )


def setting_refused_error(key: str, message: str) -> HTTPException:
    """400 ``setting_refused``: a Save check refused the value given for the
    setting ``key`` (for example a reader that does not exist). Nothing was
    written."""
    return HTTPException(status_code=400, detail={"error": SETTING_REFUSED, "key": key, "message": message})


def admin_help(message: str, *, job_url: str = "", run_url: str = "", runs_path: str = "",
               job_reader: str = "", **extra) -> dict:
    """The ``admin_help`` detail: ``message`` plus the links the admin needs,
    each added only when known. ``extra`` keys (``not_ready``, ``readiness``)
    are added as given."""
    links = {"job_url": job_url, "run_url": run_url, "runs_path": runs_path, "job_reader": job_reader}
    return {"error": ADMIN_HELP, "message": message, **{k: v for k, v in links.items() if v}, **extra}


def admin_help_error(message: str, **kwargs) -> HTTPException:
    """409 ``admin_help``: a run-time failure only an admin can fix. The UI
    copies the whole detail (:func:`admin_help`) into its admin-help block."""
    return HTTPException(status_code=409, detail=admin_help(message, **kwargs))


def identity_missing_error(message: str) -> HTTPException:
    """401 ``identity_missing``: the request carries no caller identity, or
    not the workspace email the route needs."""
    return HTTPException(status_code=401, detail={"error": IDENTITY_MISSING, "message": message})


def registry_scan_failed_error(sanitized_message: str) -> HTTPException:
    """``sanitized_message``: a ``SqlStatementError.message``."""
    return HTTPException(
        status_code=503,
        detail={
            "error": REGISTRY_SCAN_FAILED,
            "message": f"Could not read the agent's model registry: {sanitized_message}",
        },
    )


def needs_confirmation_error(issues: list[dict], message: str, **extra) -> HTTPException:
    """422 ``needs_confirmation``: the request changes something it did not
    confirm. ``issues`` are ``IssueOut``-shaped ``confirm`` issues, every one
    the action needs, so a dialog re-renders from them and sends their
    ``subject`` back in ``confirmed_issues``; ``message`` is cut by the error
    handler, so the UI renders ``issues``. ``extra`` keys (the orphan drop's
    ``impact``) are added as given."""
    return HTTPException(
        status_code=422,
        detail={"error": NEEDS_CONFIRMATION, "issues": issues, "message": message, **extra},
    )


def business_locked_error(message: str, *, run_active: bool) -> HTTPException:
    """409 ``run_active`` (a run of the business is active) or
    ``business_busy`` (another request holds the business lock): a route
    that writes the business's versions outside a run refuses, and writes
    nothing."""
    return HTTPException(
        status_code=409,
        detail={"error": RUN_ACTIVE if run_active else BUSINESS_BUSY, "message": message},
    )
