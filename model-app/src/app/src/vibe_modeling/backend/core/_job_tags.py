"""Tag keys and values shared by every job the app creates and by the Databricks App.

Standard library only: ``install/tag_app.py`` loads this file by path (the
operator env has no ``vibe_modeling`` package), so the App and the jobs carry
the same keys and the same sanitized values.

- Operational tags (``managed_by``, the app name and version, the launcher
  source, operation, model scope, counts) are always on.
- Identity tags (:data:`IDENTITY_TAG_KEYS`) are added only when Settings ->
  Agent -> "Annotate jobs with run tags" (``AgentConfig.collect_vibe_run_statistics``)
  is on.
"""

from __future__ import annotations

import re

TAG_MANAGED_BY = "managed_by"
MANAGED_BY_APP = "vibe_modeling_app"
TAG_APP = "dbx_vibe_modelling_app"
TAG_APP_VERSION = "dbx_vibe_modelling_app_version"
TAG_LAUNCHER_SOURCE = "dbx_vibe_modelling_launcher_source"
LAUNCHER_SOURCE_APP = "vibe_modeling_app"

TAG_BUSINESS = "dbx_vibe_modelling_business"
TAG_SESSION_ID = "dbx_vibe_modelling_session_id"
TAG_NOTEBOOK = "dbx_vibe_modelling_notebook"
IDENTITY_TAG_KEYS = (TAG_BUSINESS, TAG_SESSION_ID, TAG_NOTEBOOK)

# Tag value: A-Za-z0-9 plus -, _, . internal. Starts/ends with alphanumeric.
_TAG_RE = re.compile(r"[^A-Za-z0-9._-]")
_MULTI_UNDERSCORE = re.compile(r"_+")


def sanitize_tag(value: str) -> str:
    """Sanitize a string for use as a Databricks job tag value.

    Per the Integration Guide: alphanumeric start/end, only A-Za-z0-9, -, _, . in between.
    Spaces and special chars are replaced with ``_``, consecutive ``_`` collapsed,
    leading/trailing ``_``, ``.``, ``-`` stripped. Truncated to 256 chars, and
    stripped again so a cut never leaves one of them at the end.
    """
    result = _TAG_RE.sub("_", value)
    result = _MULTI_UNDERSCORE.sub("_", result)
    result = result.strip("_.-")
    return result[:256].rstrip("_.-")


def app_identity_tags(app_name: str, app_version: str) -> dict[str, str]:
    """``managed_by`` plus the app's name and version, sanitized.

    The name key is left out when ``app_name`` is empty (outside the Databricks
    Apps runtime), so a job never carries an empty app tag.
    """
    tags = {TAG_MANAGED_BY: MANAGED_BY_APP}
    name = sanitize_tag(app_name or "")
    if name:
        tags[TAG_APP] = name
    tags[TAG_APP_VERSION] = sanitize_tag(app_version or "")
    return tags
