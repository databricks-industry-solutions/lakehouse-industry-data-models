"""Volume and Unity Catalog path builders.

Centralised so the layout doesn't diverge between the agent's contract
(what the notebook writes) and the app's read paths (what the backend
fetches/lists). All helpers are pure functions — no I/O.

The ``deployment_catalog`` argument every builder takes is concern A (the
metamodel catalog): callers MUST pass a resolver result from
:mod:`core._catalogs` (:func:`resolve_metamodel_catalog` for
installation-wide reads, or :func:`resolve_version_volume_catalog` for
per-version artifact reads), never an inline ``x or y`` fallback. These
builders stay pure and take the already-resolved string.

The business segment is derived with :func:`core._names.agent_business_segment`,
which mirrors the agent's ``sanitize_name(strip_stop_words=False)`` rule -
the exact transform the agent applies when it writes the business folder.
Routing every path builder through it guarantees the app's READ paths land
on the same folder the agent WROTE, including for digit-prefixed business
names (which get a leading ``_`` so the segment is a legal UC identifier).
"""

from __future__ import annotations

import re
from typing import NamedTuple, Optional

from ._names import agent_business_segment

# Short scope tokens the agent uses in folder names. The widget value
# can be the long form (e.g. "Expanded Coverage Model - ECM"), but the
# Volume sub-folder is always the short form below.
_VALID_SCOPES = ("ecm", "mvm")


def _validate_scope(scope: str) -> str:
    """Lowercase + validate a scope token. Returns the canonical short form."""
    s = (scope or "").lower()
    if s not in _VALID_SCOPES:
        raise ValueError(
            f"scope must be one of {_VALID_SCOPES!r}, got {scope!r}"
        )
    return s


def metamodel_root_for_business(deployment_catalog: str, business_name: str) -> str:
    """Return the ``/Volumes/.../business/{biz}/`` root for a business.

    Used by listing/import flows that need to enumerate version folders
    under a single business. ``business_name`` is normalized via
    :func:`agent_business_segment` so the segment matches the folder the
    agent actually wrote (see module docstring).

    Raises ``ValueError`` when ``business_name`` normalizes to the empty
    segment (e.g. all-punctuation input): a blank segment would compose a
    malformed ``/business//…`` double-slash path that silently resolves to
    the wrong folder. Fail loud at the builder rather than emit it.
    """
    biz = agent_business_segment(business_name)
    if not biz:
        raise ValueError(
            f"business_name={business_name!r} normalizes to an empty Volume "
            "segment; cannot build a metamodel root path"
        )
    return f"/Volumes/{deployment_catalog}/_metamodel/vol_root/business/{biz}"


def file_in_folder(file_path: str, folder: str) -> bool:
    """Whether ``file_path`` sits directly in ``folder``, compared
    case-insensitively and without a trailing slash. The one test for an
    import whose file is already in the app's folder for the version (kept in
    place, never copied, never deleted with the version)."""
    return file_path.rsplit("/", 1)[0].rstrip("/").lower() == folder.rstrip("/").lower()


def version_dir_in_volume(
    deployment_catalog: str,
    business_name: str,
    version_int: int,
    scope: str,
) -> str:
    """Return the canonical (nested) per-version directory for a
    (business, version, scope).

    The agent writes ``model.json`` and the ``schemas/docs/vibes/ontology/
    sandbox/diagram/metrics`` subfolders under this directory. ``scope``
    must be ``"ecm"`` or ``"mvm"`` — the agent's short forms even when the
    ``data_model_scopes`` widget value is the long descriptive label.

    Layout (agent 4.9.8+, nested): ``v{version_int}/{scope}``. This is the
    PRIMARY / WRITE path. Pre-upgrade 0.7.x rows point at the legacy flat
    ``{scope}_v{version_int}`` layout; readers resolve both via
    :func:`version_dir_candidates` (nested-first, flat-fallback) rather than
    calling this builder alone.
    """
    scope_short = _validate_scope(scope)
    root = metamodel_root_for_business(deployment_catalog, business_name)
    return f"{root}/v{version_int}/{scope_short}"


def _flat_version_dir_in_volume(
    deployment_catalog: str,
    business_name: str,
    version_int: int,
    scope: str,
) -> str:
    """Return the LEGACY flat per-version directory ``{scope}_v{version_int}``.

    Pre-4.9.8 agents wrote here. Only the reader candidate helpers compose
    it; new writes always use the nested :func:`version_dir_in_volume`.
    """
    scope_short = _validate_scope(scope)
    root = metamodel_root_for_business(deployment_catalog, business_name)
    return f"{root}/{scope_short}_v{version_int}"


def version_dir_candidates(
    deployment_catalog: str,
    business_name: str,
    version_int: int,
    scope: str,
) -> list[str]:
    """Return the reader lookup order for a version dir: nested first, flat next.

    Every Volume READER probes these in order and takes the first that
    resolves. The nested ``v{N}/{scope}`` layout is what agent 4.9.8+ writes;
    the flat ``{scope}_v{N}`` fallback covers pre-upgrade 0.7.x rows whose
    artifacts the current agent wrote in the old shape. Single source of
    truth so nested/flat probing never gets re-implemented inline.
    """
    return [
        version_dir_in_volume(deployment_catalog, business_name, version_int, scope),
        _flat_version_dir_in_volume(deployment_catalog, business_name, version_int, scope),
    ]


def model_json_volume_path(
    deployment_catalog: str,
    business_name: str,
    version_int: int,
    scope: str,
) -> str:
    """Return the canonical (nested) ``model.json`` path the agent writes.

    Layout::

        /Volumes/{deployment_catalog}/_metamodel/vol_root/business/
            {sanitized_biz}/v{version_int}/{scope}/model.json

    This is the PRIMARY / WRITE path. Readers that must also resolve legacy
    flat artifacts use :func:`model_json_volume_candidates`.
    """
    return f"{version_dir_in_volume(deployment_catalog, business_name, version_int, scope)}/model.json"


# The app's backup of a model.json it rewrote in place (the industry prefix
# fix: ``model.json.pre090``). It stays next to the file it backs up; the
# folder copier and the artifact indexer leave it out, and the agent's
# ``*.json`` discovery ignores it (nb 50503-50520).
MODEL_JSON_BACKUP_SUFFIX = ".pre090"


def is_app_backup(path: str) -> bool:
    """Whether ``path`` is a backup the app wrote (:data:`MODEL_JSON_BACKUP_SUFFIX`)."""
    return str(path or "").endswith(MODEL_JSON_BACKUP_SUFFIX)


def model_json_volume_candidates(
    deployment_catalog: str,
    business_name: str,
    version_int: int,
    scope: str,
) -> list[str]:
    """Return the reader lookup order for ``model.json``: nested first, flat next.

    ``model.json`` sits at the TOP LEVEL of the scope dir in both layouts
    (nested ``v{N}/{scope}/model.json``, flat ``{scope}_v{N}/model.json``).
    """
    return [
        f"{d}/model.json"
        for d in version_dir_candidates(
            deployment_catalog, business_name, version_int, scope
        )
    ]


class VersionDirKey(NamedTuple):
    """What a version folder path says: its catalog, business segment,
    version and short scope."""

    catalog: str
    business_segment: str
    version: int
    scope: str


_VERSION_DIR_RE = re.compile(
    r"^/Volumes/(?P<catalog>[^/]+)/_metamodel/vol_root/business/(?P<biz>[^/]+)/"
    r"(?:v(?P<nested_v>\d+)/(?P<nested_s>ecm|mvm)|(?P<flat_s>ecm|mvm)_v(?P<flat_v>\d+))"
    r"(?:/model\.json)?/?$"
)


def version_dir_key(path: Optional[str]) -> Optional[VersionDirKey]:
    """The inverse of :func:`version_dir_candidates`: the key of a version
    folder (nested or flat), or of the ``model.json`` at its top, or None for
    any other path."""
    m = _VERSION_DIR_RE.match(path or "")
    if m is None:
        return None
    version = m.group("nested_v") or m.group("flat_v")
    scope = m.group("nested_s") or m.group("flat_s")
    return VersionDirKey(m.group("catalog"), m.group("biz"), int(version), scope)
