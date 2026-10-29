"""The import dialogs' shared steps: bring a model.json from a Volume into the app.

Both dialog routes (import into an existing business,
``routes/businesses.execute_import``; create a business by importing,
``routes/import_root.create_business_and_execute_import``) run the same steps
around their own checks and rows:

1. :func:`prepare_dialog_import` - every check, no write: the scope
   (``import_model.import_scope``), whether the file is agent output
   (``import_model.is_agent_output``), the app's folder for the version
   (``core/_paths.version_dir_in_volume`` in the metamodel catalog), which
   must be empty (409) unless it is the folder the file is in, and the app's
   copy of the model.json: agent output only stamped
   (``scope_prefix.stamp_scope``), any other file also prefixed
   (``scope_prefix.apply_import_prefix``).
2. The route sets up ``_metamodel`` and ``vol_root`` in the metamodel
   catalog (``metamodel_registry.ensure_metamodel_or_refuse``, a 400 on
   failure), writes the version (:func:`version_fields` gives the import
   columns) and syncs the app's copy into Lakebase, then commits.
3. :func:`copy_import_files` - write the app's copy as the folder's
   ``model.json`` (whatever the chosen file is called) and copy the rest of
   the file's folder next to it, outside any transaction, within
   :data:`COPY_BUDGET_S`. A failed or late copy raises
   :class:`ImportCopyFailed`; the route then calls :func:`undo_import`.
4. :func:`finish_dialog_import` - index the copied artifacts and next vibes
   in a short transaction, then seed ``_metamodel`` with the app's copy and
   its folder as ``location``.

The user's file is never changed. A file already in the app's folder for the
version (an agent version folder imported into the same business, version
and scope) is kept as the version's file, as the agent's own copy step does
(nb 104527-104680): no copy, no upload.
"""

from __future__ import annotations

import copy
import io
import json
import logging
import time
from dataclasses import dataclass, field
from typing import Any, Callable, Optional

from fastapi import HTTPException
from sqlmodel import Session

from ..core._paths import file_in_folder, version_dir_in_volume
from ..db_models import ModelVersion
from ..import_model import ImportScopeError, import_scope, import_scope_source, is_agent_output, model_payload
from ..model_sync import ModelSyncService, ingest_next_vibes
from .artifact_indexer import index_artifacts_at_path, walk_volume_dir
from .import_metamodel_writer import seed_metamodel_one, seed_warnings
from .scope_prefix import (
    PrefixReport,
    apply_import_prefix,
    file_schema_prefix,
    import_schema_prefix,
    stamp_scope,
)
from .volume_copy import copy_volume_folder, remove_volume_folder

logger = logging.getLogger(__name__)

# The copy's share of the import request. The ``_metamodel`` seed that
# follows waits at most 90 s (``import_metamodel_writer._REQUEST_BUDGET_S``)
# and then leaves its statements running, so a request takes at most about
# 210 s; the agriculture ECM (47 files, 37 MB) copies well inside this.
COPY_BUDGET_S = 120.0


@dataclass
class PreparedImport:
    """What :func:`prepare_dialog_import` decided, before any write."""

    root: dict
    scope: str
    version: int
    source_dir: str
    dest_dir: str
    source_files: list[str] = field(default_factory=list)
    in_place: bool = False
    report: PrefixReport = field(default_factory=PrefixReport)

    @property
    def model(self) -> dict:
        """The app's copy of the model, for the Lakebase sync."""
        return model_payload(self.root)


class ImportCopyFailed(Exception):
    """The copy into the app's folder did not finish; ``status`` and the
    message are what the user sees."""

    def __init__(self, status: int, message: str):
        super().__init__(message)
        self.status = status


def scope_error(exc: ImportScopeError) -> HTTPException:
    """The 400 for a scope the import cannot settle."""
    return HTTPException(status_code=400, detail=str(exc))


def resolve_scope(model_json: dict, volume_path: str, requested: Optional[str]) -> str:
    """``import_model.import_scope``, refused as a 400."""
    try:
        return import_scope(model_json, volume_path, requested)
    except ImportScopeError as exc:
        raise scope_error(exc) from exc


def analysis_fields(model_json: dict, volume_path: str) -> dict:
    """What an analyze reports about the import's scope and prefix: the scope
    the file and path settle (``None`` when the user must choose), whether it
    is agent output (kept as written; a run id given at import also makes it
    one), whether the scope is settled (by the file's version, its agent
    folder or agent output) or only suggested by its requirements, the
    file's schema prefix, and the one the app's copy uses
    (``None`` when the file's is kept or the scope is not known yet)."""
    try:
        scope, source = import_scope_source(model_json, volume_path, None)
    except ImportScopeError:
        scope, source = None, None
    agent_output = is_agent_output(model_json, volume_path, None)
    file_prefix = file_schema_prefix(model_json)
    chosen = None if agent_output or scope is None else import_schema_prefix(scope, file_prefix)
    return {
        "inferred_scope": scope,
        # Only the file's requirements answered: the user's choice still wins
        # (``import_scope``), so the dialog offers it, preselected.
        "scope_settled": source in ("version", "folder") or (scope is not None and agent_output),
        "agent_output": agent_output,
        "file_schema_prefix": file_prefix,
        "import_schema_prefix": chosen,
    }


def occupied_folder_error(business_name: str, version: int, scope: str, dest_dir: str) -> HTTPException:
    """The 409 for an app folder that already holds files. The message names
    the folder by its volume and its path in it: the error handler redacts a
    ``/Volumes/...`` path in a message, so the full path is under ``path``."""
    parts = dest_dir.strip("/").split("/")
    volume, folder = ".".join(parts[1:4]), "/".join(parts[4:])
    return HTTPException(
        status_code=409,
        detail={
            "error": "import_folder_occupied",
            "message": (
                f"The app's folder for this business's v{version} {scope.upper()}, {folder} in the "
                f"volume {volume}, already holds files from a deleted version or from an agent run "
                "the app did not record. Delete that folder in Catalog Explorer, then import again."
            ),
            "path": dest_dir,
        },
    )


def prepare_dialog_import(
    ws: Any,
    *,
    model_json: dict,
    volume_path: str,
    scope: str,
    version: int,
    catalog: str,
    business_name: str,
    databricks_run_id: Optional[int],
) -> PreparedImport:
    """Check what a dialog import will write, and build the app's copy of the
    model.json. Writes nothing. Raises the 400 / 409 the route returns."""
    try:
        dest_dir = version_dir_in_volume(catalog, business_name, version, scope)
    except ValueError as exc:
        raise HTTPException(status_code=400, detail=str(exc)) from exc
    source_dir = volume_path.rsplit("/", 1)[0]
    in_place = file_in_folder(volume_path, dest_dir)
    source_files: list[str] = []
    if not in_place:
        if walk_volume_dir(ws, dest_dir):
            raise occupied_folder_error(business_name, version, scope, dest_dir)
        # The chosen file becomes the folder's model.json (the app's copy,
        # uploaded apart); a model.json next to it is not the model.
        skip = {volume_path, f"{source_dir}/model.json"}
        source_files = [p for p in walk_volume_dir(ws, source_dir) if p not in skip]
    agent_output = is_agent_output(model_json, volume_path, databricks_run_id)
    root = copy.deepcopy(model_json)
    report = PrefixReport()
    if not agent_output:
        report = apply_import_prefix(root, scope, import_schema_prefix(scope, file_schema_prefix(root)))
    stamp_scope(root, version, scope)
    return PreparedImport(
        root=root,
        scope=scope,
        version=version,
        source_dir=source_dir,
        dest_dir=dest_dir,
        source_files=source_files,
        in_place=in_place,
        report=report,
    )


def version_fields(prepared: PreparedImport, *, volume_path: str) -> dict:
    """The import columns of the new ``ModelVersion`` (the route passes
    ``files_catalog``, the metamodel catalog). Every dialog import
    records its markers, ``""`` for agent output: a non-NULL marker means the
    version's file is the app's copy (``version_files`` reads it first)."""
    return {
        "scope": prepared.scope,
        "version": prepared.version,
        "import_source_path": volume_path,
        "import_schema_prefix_added": prepared.report.schema_prefix_added,
        "import_view_prefix_added": prepared.report.view_prefix_added,
    }


def copy_import_files(ws: Any, prepared: PreparedImport, *, budget_s: float = COPY_BUDGET_S) -> None:
    """Write the app's copy as the folder's ``model.json`` (whatever the
    chosen file is called) and copy the rest of the file's folder next to it.
    Raises :class:`ImportCopyFailed` when a file fails or the copy runs past
    ``budget_s``. Nothing to do for a file already in the app's folder."""
    if prepared.in_place:
        return
    deadline = time.monotonic() + budget_s
    try:
        ws.files.upload(
            f"{prepared.dest_dir}/model.json", io.BytesIO(json.dumps(prepared.root).encode()), overwrite=True,
        )
    except Exception as exc:  # noqa: BLE001 - reported as the copy's failure
        logger.warning("dialog_import: could not write the app's model.json to %s: %s", prepared.dest_dir, exc)
        raise ImportCopyFailed(
            502, "The model file could not be written into the app's folder, so nothing was imported. Import again.",
        ) from exc
    result = copy_volume_folder(
        ws, prepared.source_files, prepared.source_dir, prepared.dest_dir,
        deadline=deadline, log_prefix="dialog_import",
    )
    if result.timed_out:
        raise ImportCopyFailed(
            504,
            f"The model's folder holds {result.total + 1} file(s), too many to copy into the app's "
            f"folder within {int(budget_s)} s, so nothing was imported. Import the model.json from a "
            "folder with only the files the model needs.",
        )
    if not result.complete:
        raise ImportCopyFailed(
            502,
            f"{len(result.failed)} of the model's {result.total} file(s) could not be copied into "
            "the app's folder, so nothing was imported. Import again.",
        )


def undo_import(
    session: Session,
    ws: Any,
    prepared: PreparedImport,
    version_id: str,
    *,
    also_delete: Callable[[Session], None] = lambda _s: None,
) -> None:
    """After a failed copy: delete the version (and what ``also_delete``
    removes, the created business for the create route) and, best-effort,
    the files copied so far. The ``_metamodel`` seed has not run."""
    try:
        ModelSyncService(session).clear_version_data(version_id)
        mv = session.get(ModelVersion, version_id)
        if mv is not None:
            session.delete(mv)
        session.flush()
        also_delete(session)
        session.commit()
    except Exception:
        session.rollback()
        logger.exception("dialog_import: could not delete version %s after a failed copy", version_id)
    if not prepared.in_place:
        remove_volume_folder(ws, prepared.dest_dir, log_prefix="dialog_import")


def finish_dialog_import(
    ws: Any,
    session: Session,
    prepared: PreparedImport,
    *,
    version_id: str,
    business_id: str,
    business_name: str,
    catalog: str,
    warehouse_id: Optional[str],
    log_prefix: str,
) -> list[str]:
    """Index the artifacts and next vibes of the app's folder, commit, then
    seed ``_metamodel``. Returns the user-facing warnings."""
    warnings = list(prepared.report.warnings)
    try:
        index_artifacts_at_path(
            ws, session, run_id=None, model_version_id=version_id, volume_root_path=prepared.dest_dir,
        )
    except Exception:
        logger.exception("%s: artifact indexing failed for version %s (non-fatal)", log_prefix, version_id)
    ingest_next_vibes(ws, session, version_dir=prepared.dest_dir, version_id=version_id, business_id=business_id)
    session.commit()
    seed = seed_metamodel_one(
        ws,
        catalog=catalog,
        warehouse_id=warehouse_id or "",
        model_json=prepared.root,
        business_name=business_name,
        scope=prepared.scope,
        version=prepared.version,
        log_prefix=log_prefix,
        wait_mode="request",
        location=prepared.dest_dir,
    )
    warnings.extend(seed_warnings(seed))
    return warnings


def sync_prepared(session: Session, version_id: str, prepared: PreparedImport) -> None:
    """Sync the app's copy of the model into Lakebase."""
    ModelSyncService(session).sync_from_model_json(version_id, prepared.model)


__all__ = [
    "COPY_BUDGET_S",
    "analysis_fields",
    "ImportCopyFailed",
    "PreparedImport",
    "copy_import_files",
    "finish_dialog_import",
    "occupied_folder_error",
    "prepare_dialog_import",
    "resolve_scope",
    "sync_prepared",
    "undo_import",
    "version_fields",
]
