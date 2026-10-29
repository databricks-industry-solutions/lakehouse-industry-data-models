"""Unity Catalog browse endpoints.

``/api/uc/volumes/browse`` — powers the Volume picker in the bulk-import dialog.
``/api/uc/catalogs/{catalog_name}/schema-warning`` — counts non-protected schemas in
a catalog so the new-run form can warn before the agent drops them.

Path grammar for ``volumes/browse`` (URL query param ``path``):

- ``""`` / ``"/"`` → list catalogs visible to the app SP (``kind="catalog"``)
- ``"/<catalog>"`` → list schemas in that catalog (``kind="schema"``)
- ``"/<catalog>/<schema>"`` → list volumes in that schema (``kind="volume"``)
- ``"/Volumes/<catalog>/<schema>/<volume>[/sub/path]"`` → list directory
  contents via ``ws.files.list_directory_contents`` (``kind="dir"``/``"file"``)

Trade-off: we do **not** pre-filter catalogs/schemas to only those that
contain at least one volume — that would require an O(catalogs × schemas)
sweep of ``volumes.list`` on every root call. Empty schemas / volume-free
catalogs render as clickable but empty. Common UC browsers behave the same.
"""

from __future__ import annotations

import logging
from datetime import datetime
from typing import Optional

from fastapi import APIRouter, HTTPException, Query
from pydantic import BaseModel

from databricks.sdk.errors.platform import (
    NotFound,
    PermissionDenied,
)

from ..._metadata import api_prefix
from ..core import Dependencies

logger = logging.getLogger(__name__)

router = APIRouter(prefix=api_prefix)

# Cap entries per response. Anything larger and we set truncated=true.
_MAX_ENTRIES = 500

# Schemas the agent creates and owns; never treated as "prior deployment" debris.
_PROTECTED_SCHEMAS: frozenset[str] = frozenset(
    {"_metamodel", "default", "information_schema"}
)


class VolumeBrowseEntry(BaseModel):
    name: str
    is_dir: bool
    kind: str  # "catalog" | "schema" | "volume" | "dir" | "file"
    size_bytes: Optional[int] = None
    modified_at: Optional[datetime] = None


class VolumeBrowseOut(BaseModel):
    path: str
    parent: Optional[str]
    entries: list[VolumeBrowseEntry]
    truncated: bool = False


def _parent_of(path: str) -> Optional[str]:
    """Return the parent path for breadcrumb navigation.

    - "" / "/" has no parent.
    - "/<catalog>" → ""
    - "/<catalog>/<schema>" → "/<catalog>"
    - "/Volumes/<c>/<s>/<v>[/...]" → trim one segment, until back to
      "/Volumes/<c>/<s>" then collapse to "/<c>/<s>".
    """
    if not path or path == "/":
        return None
    parts = [p for p in path.split("/") if p]
    if not parts:
        return None
    # Walking up inside a /Volumes/ subtree
    if parts[0] == "Volumes":
        if len(parts) <= 3:
            # /Volumes/<c> or /Volumes/<c>/<s> shouldn't really happen,
            # but if it does, walk up to the catalog/schema view.
            return "/" + "/".join(parts[1:-1]) if len(parts) > 1 else ""
        if len(parts) == 4:
            # /Volumes/<c>/<s>/<v> → catalog/schema view
            return "/" + parts[1] + "/" + parts[2]
        # /Volumes/<c>/<s>/<v>/.../sub → drop one segment
        return "/" + "/".join(parts[:-1])
    # Plain catalog/schema view
    if len(parts) == 1:
        return ""
    return "/" + "/".join(parts[:-1])


def _norm(path: str) -> str:
    """Trim trailing slash but keep leading semantics.

    "" and "/" both mean "list catalogs"; everything else keeps a leading "/"
    and no trailing "/".
    """
    if not path:
        return ""
    stripped = path.rstrip("/")
    if stripped == "":
        return ""
    if not stripped.startswith("/"):
        stripped = "/" + stripped
    return stripped


def _entry_kind_for_file(is_directory: bool) -> str:
    return "dir" if is_directory else "file"


def _list_catalogs(ws) -> list[VolumeBrowseEntry]:
    catalogs = list(ws.catalogs.list())
    return [
        VolumeBrowseEntry(name=c.name, is_dir=True, kind="catalog")
        for c in catalogs
        if c.name
    ]


def _list_schemas(ws, catalog_name: str) -> list[VolumeBrowseEntry]:
    schemas = list(ws.schemas.list(catalog_name=catalog_name))
    return [
        VolumeBrowseEntry(name=s.name, is_dir=True, kind="schema")
        for s in schemas
        if s.name
    ]


def _list_volumes(ws, catalog_name: str, schema_name: str) -> list[VolumeBrowseEntry]:
    volumes = list(ws.volumes.list(catalog_name=catalog_name, schema_name=schema_name))
    return [
        VolumeBrowseEntry(name=v.name, is_dir=True, kind="volume")
        for v in volumes
        if v.name
    ]


def _list_directory(ws, abs_path: str) -> list[VolumeBrowseEntry]:
    entries_iter = ws.files.list_directory_contents(abs_path)
    out: list[VolumeBrowseEntry] = []
    for entry in entries_iter:
        name = getattr(entry, "name", None)
        if not name:
            continue
        is_dir = bool(getattr(entry, "is_directory", False))
        size = getattr(entry, "file_size", None)
        modified = getattr(entry, "last_modified", None)
        modified_at: Optional[datetime] = None
        if isinstance(modified, datetime):
            modified_at = modified
        elif isinstance(modified, (int, float)):
            # Databricks SDK exposes last_modified as an epoch-millis int.
            try:
                modified_at = datetime.fromtimestamp(modified / 1000.0)
            except (OSError, OverflowError, ValueError):
                modified_at = None
        out.append(
            VolumeBrowseEntry(
                name=name,
                is_dir=is_dir,
                kind=_entry_kind_for_file(is_dir),
                size_bytes=None if is_dir else (int(size) if size is not None else None),
                modified_at=modified_at,
            )
        )
    return out


@router.get(
    "/uc/volumes/browse",
    response_model=VolumeBrowseOut,
    operation_id="browseVolumes",
)
def browse_volumes(
    ws: Dependencies.Client,
    path: str = Query(default="", description="UC browse path (see module docstring)"),
):
    """Browse Unity Catalog volumes scoped to the app service principal.

    The single endpoint covers four levels (catalog → schema → volume →
    directory) so the UI only needs one hook. The shape of ``entries`` and
    ``parent`` is the same across all levels; ``kind`` disambiguates.

    On ``PermissionDenied`` from the SDK we return HTTP 403 with a generic
    detail to avoid leaking workspace structure to unauthorized callers.
    """
    norm = _norm(path)

    try:
        # Level 0: catalogs root
        if norm == "":
            entries = _list_catalogs(ws)
        else:
            parts = [p for p in norm.split("/") if p]
            if parts[0] == "Volumes":
                # /Volumes/<c>/<s>/<v>[/sub/path] → directory listing
                if len(parts) < 4:
                    raise HTTPException(
                        status_code=400,
                        detail="Volume path must include /Volumes/<catalog>/<schema>/<volume>",
                    )
                entries = _list_directory(ws, norm)
            elif len(parts) == 1:
                # /<catalog> → schemas
                entries = _list_schemas(ws, parts[0])
            elif len(parts) == 2:
                # /<catalog>/<schema> → volumes
                entries = _list_volumes(ws, parts[0], parts[1])
            else:
                # /<catalog>/<schema>/<extra...> → invalid (use /Volumes/ form)
                raise HTTPException(
                    status_code=400,
                    detail=(
                        "Drill into a volume using "
                        "/Volumes/<catalog>/<schema>/<volume>"
                    ),
                )
    except HTTPException:
        raise
    except PermissionDenied:
        # Don't echo the path or SDK message — generic 403 only.
        raise HTTPException(status_code=403, detail="Access denied") from None
    except NotFound:
        raise HTTPException(status_code=404, detail="Path not found") from None
    except Exception as e:
        logger.exception("browseVolumes failed for path=%r", norm)
        raise HTTPException(status_code=500, detail=f"Browse failed: {e}") from e

    truncated = False
    if len(entries) > _MAX_ENTRIES:
        entries = entries[:_MAX_ENTRIES]
        truncated = True

    # Sort: directories first, then alphabetical. Stable across all kinds.
    entries.sort(key=lambda e: (not e.is_dir, e.name.lower()))

    return VolumeBrowseOut(
        path=norm,
        parent=_parent_of(norm),
        entries=entries,
        truncated=truncated,
    )


class CatalogSchemaWarningOut(BaseModel):
    """Non-protected schema count for a UC catalog.

    ``schema_count`` is the number of schemas that are NOT in
    ``_PROTECTED_SCHEMAS`` (``_metamodel``, ``default``, ``information_schema``).
    When non-zero the new-run form shows an informational warning on the runs
    where the agent tears down the business's own schemas at its start. The
    count includes schemas of other businesses, which the agent leaves alone.

    Returns zeroed/empty on catalog-not-found or permission errors so the
    new-run form never 500s waiting for this advisory signal.
    """

    catalog: str
    schema_count: int
    schemas: list[str]


@router.get(
    "/uc/catalogs/{catalog_name}/schema-warning",
    response_model=CatalogSchemaWarningOut,
    operation_id="getCatalogSchemaWarning",
)
def get_catalog_schema_warning(
    catalog_name: str,
    ws: Dependencies.Client,
) -> CatalogSchemaWarningOut:
    """Return the count and names of non-protected schemas in a UC catalog.

    Protected schemas (``_metamodel``, ``default``, ``information_schema``)
    are excluded — they are owned by the agent or by UC itself and are not
    debris from prior deployments.

    Returns ``schema_count=0`` and ``schemas=[]`` when the catalog is not
    found or the service principal cannot access it, so the calling UI
    never needs to special-case the error path.
    """
    try:
        all_schemas = list(ws.schemas.list(catalog_name=catalog_name))
    except (NotFound, PermissionDenied):
        return CatalogSchemaWarningOut(
            catalog=catalog_name, schema_count=0, schemas=[]
        )
    except Exception:
        logger.warning("getCatalogSchemaWarning: failed to list schemas for %r", catalog_name, exc_info=True)
        return CatalogSchemaWarningOut(
            catalog=catalog_name, schema_count=0, schemas=[]
        )

    non_protected = sorted(
        s.name
        for s in all_schemas
        if s.name and s.name.lower() not in _PROTECTED_SCHEMAS
    )
    return CatalogSchemaWarningOut(
        catalog=catalog_name,
        schema_count=len(non_protected),
        schemas=non_protected,
    )
