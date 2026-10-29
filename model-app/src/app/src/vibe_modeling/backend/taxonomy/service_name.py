"""Unity Catalog model-service names (``catalog.schema.service``).

Canonical for the app (Settings validation, the model-services list) and the
installer: ``install/deploy_settings.py`` (the install-time validation of
``--taxonomy-model-service``) and ``install/check_model_service.py`` load this
file by path, so it imports only the standard library.

The rule mirrors the AI Gateway's own check (observed on a test workspace 2026-10-18):
three non-empty parts, each at most 255 characters, containing no ``.``,
space, ``/`` or ASCII control characters.
"""

from __future__ import annotations

import re

_PART = r"[^.\s/\x00-\x1f\x7f]{1,255}"
MODEL_SERVICE_NAME_RE = re.compile(rf"{_PART}\.{_PART}\.{_PART}")
# UC returns ``name`` as ``model-services/<full_name>`` (GET and list).
_RESOURCE_PREFIX = "model-services/"


def split_model_service_name(name: str) -> tuple[str, str, str]:
    """Return ``(catalog, schema, service)``; ``ValueError`` if not a valid
    three-part name."""
    if not MODEL_SERVICE_NAME_RE.fullmatch(name):
        raise ValueError(
            f"'{name}' is not a model service full name (catalog.schema.service)"
        )
    catalog, schema, service = name.split(".")
    return catalog, schema, service


def strip_resource_prefix(name: str) -> str:
    """``model-services/a.b.c`` -> ``a.b.c``; other values pass through."""
    return name[len(_RESOURCE_PREFIX):] if name.startswith(_RESOURCE_PREFIX) else name
