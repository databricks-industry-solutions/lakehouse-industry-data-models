"""Model-version read-side endpoints (`/api/businesses/.../versions/...`,
`/api/model-versions/...`).

Covers listing versions, the run form's pre-fill for a vibe of a version
(``getRunDefaults``), the next-vibes inspection surface, the
delete-version flow and its ``_metamodel`` cleanups (list and Retry
cleanup), manual sync / resync
into Lakebase, the admin-recovery `import-from-volume` endpoint, the
uninstall impact, and the per-version artifact listing the UI surfaces on the
model-version page.
Anything that operates on a single ModelVersion row but is NOT a
`/runs/...` endpoint lives here.

Per-version artifact endpoints nest under
`/businesses/{business_id}/model-versions/{model_version_id}/artifacts...`
so the business id in the URL gates tenancy the same way it does for the
per-run sibling endpoints — see :func:`get_model_version_in_business`.
"""

from __future__ import annotations

import json
import logging
import time
from datetime import datetime, timezone
from types import SimpleNamespace
from typing import Literal, Optional

from fastapi import APIRouter, HTTPException, Query
from fastapi.responses import StreamingResponse
from sqlmodel import select

from ..._metadata import api_prefix
from .._artifact_io import (
    build_artifact_content_response,
    build_artifact_download_response,
    build_artifacts_zip_bytes,
)
from .._query_helpers import (
    next_version_for_scope,
    resolve_model_version,
)
from ..agent_compat import (
    gate_model_json,
    latest_supported_tag,
)
from ..core import (
    Dependencies,
    resolve_uninstall_target_catalog,
    resolve_version_volume_catalog,
)
from ..core._metamodel_cleanups import retry_cleanup, unfinished_cleanups
from ..core._names import agent_business_segment
from ..core._runs import lock_business_for_run
from ..core._time import as_utc
from ..core._vibe_scope import scope_head
from ..import_model import ImportScopeError, import_scope
from ..error_sanitization import recorded_error_text
from ..db_models import (
    Business,
    Domain,
    MetamodelCleanup,
    ModelVersion,
    Run,
    RunArtifact,
)
from ..model_export import (
    bundle_layout,
    build_bundle_zip_bytes,
    export_model_json,
    resolve_bundle_root,
)
from ..model_sync import ModelSyncService, _SyncEmptyError, _version_root_in_volume
from ..run_link import import_sources, link_after_import, linked_run_ids
from ..models import (
    DeleteVersionOut,
    InstallationStatusOut,
    MetamodelCleanupOut,
    MetamodelCleanupSummaryOut,
    ModelVersionOut,
    NextVibesOut,
    ReconcileInstallationOut,
    RunArtifactOut,
    RunDefaultsOut,
    UninstallImpactOut,
)
from ..services.run_defaults import run_defaults
from ..services.orchestrator.dag_factories import dag_for_import_from_volume
from ..services.orchestrator.dag_factories._recovery import ImportFromVolumeRequest
from ..services.orchestrator.validate import validate_dag
from ..services.schema_names import (
    expected_schema_candidates_for_version,
    resolve_expected_and_found_schemas,
)
from ..services.import_metamodel_writer import seed_error_text, seed_warnings
from ..services.uninstall_impact import ScanRateLimited, uninstall_impact
from ..services import operations as _operations_pkg
from ..services.operations._version_lifecycle import (
    VersionDeleteRefused,
    delete_version as delete_version_rows,
    evict_deployed_siblings,
    installed_catalogs,
    is_draft,
    mark_version_deployed,
    mark_version_uninstalled,
)
from ._helpers import (
    _get_or_create_agent_config,
    _next_vibes_from_inputs,
    require_catalog_name,
    require_config,
    resolve_warehouse_id,
    scan_rate_limited,
)

logger = logging.getLogger(__name__)

router = APIRouter(prefix=api_prefix)


def get_model_version_in_business(
    session, business_id: str, model_version_id: str
) -> ModelVersion:
    """Load a ``ModelVersion`` by id and assert it belongs to ``business_id``.

    Raises ``HTTPException(404, "ModelVersion not found")`` when:
      * no row exists for ``model_version_id``, or
      * the row exists but its ``business_id`` does not match.

    Both cases collapse to 404 (not 403) so the API does not leak the
    existence of model versions across businesses — a caller probing
    ``/businesses/{wrong}/model-versions/{mvid}/...`` should see the
    same response as if ``mvid`` did not exist at all. Mirrors
    :func:`router.get_run_in_business` for the per-run surface.
    """
    mv = session.get(ModelVersion, model_version_id)
    if not mv or mv.business_id != business_id:
        raise HTTPException(status_code=404, detail="ModelVersion not found")
    return mv


# --- Model Versions ---


@router.get(
    "/businesses/{business_id}/versions",
    response_model=list[ModelVersionOut],
    operation_id="listVersions",
)
def list_versions(business_id: str, session: Dependencies.Session):
    """The business's versions, newest first, each with ``is_head`` (the
    scope head, ``core._vibe_scope.scope_head``), ``is_imported`` (the
    ``run_link`` rule), ``linked_run_id`` for an imported version linked to
    its run and, for a Dry Run draft,
    ``draft_state``: ``ready`` when it builds on the head, ``older_base``
    otherwise (installing it would replace newer versions)."""
    versions = session.exec(
        select(ModelVersion)
        .where(ModelVersion.business_id == business_id)
        .order_by(ModelVersion.version.desc())
    ).all()
    heads = {
        scope: scope_head(session, business_id, scope)
        for scope in {mv.scope for mv in versions}
    }
    linked = linked_run_ids(session, [mv.id for mv in versions])
    imported = import_sources(session, versions)
    out: list[ModelVersionOut] = []
    for mv in versions:
        head = heads.get(mv.scope)
        draft_state = None
        if is_draft(mv):
            draft_state = "ready" if head is not None and mv.base_version_id == head.id else "older_base"
        out.append(ModelVersionOut.model_validate(mv, from_attributes=True).model_copy(update={
            "is_head": head is not None and mv.id == head.id,
            "draft_state": draft_state,
            "linked_run_id": linked.get(mv.id),
            "is_imported": mv.id in imported,
        }))
    return out


@router.get(
    "/model-versions/{model_version_id}/next-vibes",
    response_model=NextVibesOut,
    operation_id="getNextVibes",
)
def get_next_vibes(model_version_id: str, session: Dependencies.Session):
    """Return agent-proposed follow-up operations for a model version.

    Items are read from the structured ``VibeInput(origin=agent_next_vibe)``
    rows the sync-time materializer creates (the same rows the Model Evolution
    Metrics count) — ALL findings (static-analysis, priority-remediation, and
    other) surface as cards. Returns an empty list when the version has no
    captured next-vibes — callers should hide the UI section in that case
    rather than rendering an empty card.
    """
    mv = session.get(ModelVersion, model_version_id)
    if not mv:
        raise HTTPException(status_code=404, detail="Model version not found")

    return _next_vibes_from_inputs(session, model_version_id)


@router.delete(
    "/businesses/{business_id}/versions/{version_id}",
    response_model=DeleteVersionOut,
    operation_id="deleteVersion",
)
def delete_version(
    business_id: str,
    version_id: str,
    session: Dependencies.Session,
    ws: Dependencies.Client,
    config: Dependencies.Config,
    _role: Dependencies.BusinessAdminOnly,
):
    """Delete one version (``_version_lifecycle.delete_version``).

    Refused with 409 (nothing changed) while the business has an active run
    or another request holds it, when the version is installed anywhere
    (``{"error": "installed", "catalogs", "message"}``: uninstall it first),
    or when newer real versions of its scope sit above it ("Delete the newer
    versions first"), so a scope is peeled from the top. Deleting the scope
    head makes the newest
    superseded, not replaced, older version the head again
    (``previous_version``); the feedback the version applied is open again
    (``reopened_input_count``). The agent's ``_metamodel`` rows are removed
    per catalog after the commit, recorded in ``metamodel_cleanup``; a
    failed one stays listed until Retry cleanup.
    """
    business = session.get(Business, business_id)
    if not business:
        raise HTTPException(status_code=404, detail="Business not found")

    version = session.get(ModelVersion, version_id)
    if not version or version.business_id != business_id:
        raise HTTPException(status_code=404, detail="Version not found")

    try:
        outcome = delete_version_rows(
            session, ws, resolve_warehouse_id(session, config), version,
            discard_change_feedback=config.run_change_review_enabled,
        )
    except VersionDeleteRefused as refused:
        raise HTTPException(status_code=refused.status_code, detail=refused.detail)
    return DeleteVersionOut(
        deleted_version=outcome.deleted_version,
        previous_version=outcome.previous_version,
        metamodel_rows_cleaned=outcome.metamodel_rows_cleaned,
        metamodel_cleanup=MetamodelCleanupSummaryOut(
            done=outcome.cleanup_done, pending=outcome.cleanup_pending, failed=outcome.cleanup_failed,
        ),
        reopened_input_count=outcome.reopened_input_count,
        message=f"Deleted version {outcome.deleted_version}",
    )


def _cleanup_out(row: MetamodelCleanup) -> MetamodelCleanupOut:
    out = MetamodelCleanupOut.model_validate(row, from_attributes=True)
    return out.model_copy(update={"updated_at": as_utc(row.updated_at)})


@router.get(
    "/businesses/{business_id}/metamodel-cleanups",
    response_model=list[MetamodelCleanupOut],
    operation_id="listMetamodelCleanups",
)
def list_metamodel_cleanups(business_id: str, session: Dependencies.Session):
    """The business's unfinished ``_metamodel`` cleanups (``pending`` or
    ``failed``), newest first. While one is unfinished in a catalog, the
    agent still sees the deleted version there."""
    business = session.get(Business, business_id)
    if not business:
        raise HTTPException(status_code=404, detail="Business not found")
    return [_cleanup_out(r) for r in unfinished_cleanups(session, agent_business_segment(business.name))]


@router.post(
    "/businesses/{business_id}/metamodel-cleanups/{cleanup_id}/retry",
    response_model=MetamodelCleanupOut,
    operation_id="retryMetamodelCleanup",
)
def retry_metamodel_cleanup(
    business_id: str,
    cleanup_id: str,
    session: Dependencies.Session,
    ws: Dependencies.Client,
    config: Dependencies.Config,
    _role: Dependencies.BusinessAdminOnly,
):
    """Retry cleanup: attempt the removal again under the business lock,
    with the attempt count reset. 409 while a run is active or another
    request holds the business. A ``done`` row is returned unchanged."""
    business = session.get(Business, business_id)
    if not business:
        raise HTTPException(status_code=404, detail="Business not found")
    row = session.get(MetamodelCleanup, cleanup_id)
    if row is None or row.business_segment != agent_business_segment(business.name):
        raise HTTPException(status_code=404, detail="Cleanup not found")
    warehouse_id = resolve_warehouse_id(session, config)
    lock_business_for_run(session, business.id)
    session.refresh(row)
    return _cleanup_out(retry_cleanup(session, ws, warehouse_id, row))


@router.get(
    "/businesses/{business_id}/model-versions/{model_version_id}/run-defaults",
    response_model=RunDefaultsOut,
    operation_id="getRunDefaults",
)
def get_run_defaults(
    business_id: str,
    model_version_id: str,
    session: Dependencies.Session,
    ws: Dependencies.Client,
):
    """The Advanced Options a vibe of this version starts from, and which of
    them the agent keeps at the version's own value
    (``services/run_defaults.run_defaults``). Reads the version's
    ``model.json`` once (bounded); an unreadable file answers 200 with
    ``file_read`` False."""
    mv = get_model_version_in_business(session, business_id, model_version_id)
    business = session.get(Business, business_id)
    return run_defaults(session, ws, business, mv)


# --- Per-version artifact listing (read-side, distinct from runs/.../artifacts) ---


@router.get(
    "/businesses/{business_id}/model-versions/{model_version_id}/artifacts",
    response_model=list[RunArtifactOut],
    operation_id="listArtifactsByVersion",
)
def list_artifacts_by_version(
    business_id: str,
    model_version_id: str,
    session: Dependencies.Session,
):
    """Artifacts the agent wrote for this model version.

    Unlike `/runs/{run_id}/artifacts` — which returns every file a run
    produced across *all* versions (the unified pipeline emits two) —
    this endpoint is scoped to the version the user is viewing, so the
    UI can surface artifacts on the model version page without mixing
    ECM and MVM outputs.
    """
    get_model_version_in_business(session, business_id, model_version_id)
    artifacts = session.exec(
        select(RunArtifact)
        .where(RunArtifact.model_version_id == model_version_id)
        .order_by(RunArtifact.created_at.desc())
    ).all()
    return artifacts


@router.get(
    "/businesses/{business_id}/model-versions/{model_version_id}/artifacts/download",
    operation_id="downloadAllArtifactsByVersion",
)
def download_all_artifacts_by_version(
    business_id: str,
    model_version_id: str,
    session: Dependencies.Session,
    ws: Dependencies.Client,
):
    """Stream a zip of every artifact indexed for this model version."""
    get_model_version_in_business(session, business_id, model_version_id)
    artifacts = session.exec(
        select(RunArtifact)
        .where(RunArtifact.model_version_id == model_version_id)
        .order_by(RunArtifact.created_at.desc())
    ).all()
    if not artifacts:
        raise HTTPException(status_code=404, detail="No artifacts to download")

    body = build_artifacts_zip_bytes(ws, artifacts)
    filename = f"model-version-{model_version_id[:8]}-artifacts.zip"
    return StreamingResponse(
        iter([body]),
        media_type="application/zip",
        headers={"Content-Disposition": f'attachment; filename="{filename}"'},
    )


# --- Model export (inverse of import) --------------------------------------
#
# Reconstruct a ``model.json`` from a version's Lakebase rows so a model /
# industry version can later be published to GitHub. Read-only: no mutation.
# The serializer lives in ``model_export`` (mirrors ``sync_from_model_json``'s
# field map); the bundle layout (``<industry>/<scope>_vN/``) is a single
# code-level descriptor there.


@router.get(
    "/businesses/{business_id}/model-versions/{model_version_id}/export",
    response_model=dict,
    operation_id="exportModelJson",
)
def export_model_version_json(
    business_id: str,
    model_version_id: str,
    session: Dependencies.Session,
):
    """Reconstruct the ``model.json`` for a version from its Lakebase rows.

    The inverse of import: returns the agent-envelope ``model.json`` shape
    (``{"model": {...}}``) the import flow accepts, so the version round-trips.
    """
    get_model_version_in_business(session, business_id, model_version_id)
    return export_model_json(session, model_version_id)


@router.get(
    "/businesses/{business_id}/model-versions/{model_version_id}/export/bundle",
    operation_id="exportModelBundle",
)
def export_model_version_bundle(
    business_id: str,
    model_version_id: str,
    session: Dependencies.Session,
    ws: Dependencies.Client,
):
    """Stream a zip bundle (``<industry>/<scope>_vN/model.json`` + companion
    artifacts) for a version — the publishable inverse-of-import layout."""
    mv = get_model_version_in_business(session, business_id, model_version_id)
    business = session.get(Business, business_id)
    root = resolve_bundle_root(
        override=None, business=business, scope=mv.scope or "", version=mv.version
    )
    model_json = export_model_json(session, model_version_id)
    layout = bundle_layout(
        mv.scope or "", mv.scope or "", mv.version, dir_override=root
    )

    artifacts = session.exec(
        select(RunArtifact)
        .where(RunArtifact.model_version_id == model_version_id)
        .order_by(RunArtifact.created_at.desc())
    ).all()

    body = build_bundle_zip_bytes(ws, layout, model_json, artifacts)
    filename = f"{layout.industry}-{layout.scope}-v{layout.version}-bundle.zip"
    return StreamingResponse(
        iter([body]),
        media_type="application/zip",
        headers={"Content-Disposition": f'attachment; filename="{filename}"'},
    )


# Per-version, per-artifact preview + download.
#
# These mirror the run-scoped endpoints in router.py (``/runs/.../artifacts/
# {artifact_id}/{content,download}``) but key on ``model_version_id`` instead
# of ``run_id``. The import-from-Volume path writes RunArtifact rows with
# ``run_id=NULL`` (since v_0_5_0; imports are syncs, not runs), so the
# run-scoped endpoints can't surface preview/download for imported artifacts.
# Both surfaces share the helpers in ``_artifact_io`` so behaviour stays
# identical between run-produced and import-produced rows.


@router.get(
    "/businesses/{business_id}/model-versions/{model_version_id}/artifacts/{artifact_id}/content",
    response_model=dict,
    operation_id="getArtifactContentByVersion",
)
def get_artifact_content_by_version(
    business_id: str,
    model_version_id: str,
    artifact_id: str,
    session: Dependencies.Session,
    ws: Dependencies.Client,
    content_format: Literal["text", "hex"] = Query(
        "text",
        alias="format",
        description='Use "text" for UTF-8 text bodies, "hex" for a short hex dump of any file.',
    ),
):
    """Read artifact bytes from its Volume path. See :func:`build_artifact_content_response`."""
    get_model_version_in_business(session, business_id, model_version_id)
    artifact = session.exec(
        select(RunArtifact).where(
            RunArtifact.id == artifact_id,
            RunArtifact.model_version_id == model_version_id,
        )
    ).first()
    if not artifact:
        raise HTTPException(status_code=404, detail="Artifact not found")
    return build_artifact_content_response(ws, artifact, content_format)


@router.get(
    "/businesses/{business_id}/model-versions/{model_version_id}/artifacts/{artifact_id}/download",
    operation_id="downloadArtifactByVersion",
)
def download_artifact_by_version(
    business_id: str,
    model_version_id: str,
    artifact_id: str,
    session: Dependencies.Session,
    ws: Dependencies.Client,
    inline: bool = Query(
        False,
        description="If true, use Content-Disposition: inline and a browser-friendly Content-Type (PDF, images) for embedding in the UI.",
    ),
):
    """Stream a single artifact's raw bytes as a file download (or inline preview)."""
    get_model_version_in_business(session, business_id, model_version_id)
    artifact = session.exec(
        select(RunArtifact).where(
            RunArtifact.id == artifact_id,
            RunArtifact.model_version_id == model_version_id,
        )
    ).first()
    if not artifact:
        raise HTTPException(status_code=404, detail="Artifact not found")
    return build_artifact_download_response(ws, artifact, inline=inline)


# --- Manual model sync ---


@router.post(
    "/businesses/{business_id}/versions/{version_id}/sync",
    response_model=dict,
    operation_id="syncModelVersion",
)
def sync_model_version(
    business_id: str,
    version_id: str,
    session: Dependencies.Session,
    ws: Dependencies.Client,
    config: Dependencies.Config,
    _role: Dependencies.BusinessAdminOnly,
):
    """Manually trigger model sync into Lakebase for a version.

    Tries model.json from Volumes first, falls back to the Delta metamodel tables.
    """

    mv = session.get(ModelVersion, version_id)
    if not mv or mv.business_id != business_id:
        raise HTTPException(status_code=404, detail="Version not found")

    business = session.get(Business, business_id)
    if not business:
        raise HTTPException(status_code=404, detail="Business not found")

    bname = agent_business_segment(business.name)
    vstr = f"v{mv.version}"

    # Where the version's files are (resolve_version_volume_catalog), so a
    # draft or a version installed elsewhere still syncs from its own folder.
    catalog = resolve_version_volume_catalog(mv, session, config)
    sync = ModelSyncService(session, ws, resolve_warehouse_id(session, config))
    try:
        success = sync.sync_model(version_id, catalog, bname, vstr)
    except _SyncEmptyError:
        # G2: a 0-domain artifact was found — the post-sync gate raised.
        # sync_from_model_json cleared the version's rows before writing 0,
        # so roll back the uncommitted teardown to avoid data loss, then
        # return the same 404 as the G1 (no-data) case for consistency.
        session.rollback()
        raise HTTPException(
            status_code=404,
            detail="Model output is empty (0 domains) — nothing to sync",
        )
    if not success:
        raise HTTPException(status_code=404, detail="No model data found in Delta tables or Volumes")

    session.commit()
    return {"ok": True, "message": f"Synced model data for version {mv.version}"}


@router.post(
    "/businesses/{business_id}/versions/{version_id}/resync",
    response_model=dict,
    operation_id="forceResyncVersion",
)
def force_resync_version(
    business_id: str,
    version_id: str,
    session: Dependencies.Session,
    ws: Dependencies.Client,
    config: Dependencies.Config,
    _role: Dependencies.BusinessAdminOnly,
):
    """Force re-sync a model version (model.json primary, Delta fallback), clearing existing data first."""

    # Resync reads Delta/Volume via the warehouse; hard-fail with an actionable
    # 422 before doing work when it is unset (the metamodel-catalog case is
    # handled version-specifically below via resolve_version_volume_catalog).
    require_config(session, config, ["warehouse"], mode="raise")

    mv = session.get(ModelVersion, version_id)
    if not mv or mv.business_id != business_id:
        raise HTTPException(status_code=404, detail="Version not found")

    business = session.get(Business, business_id)
    if not business:
        raise HTTPException(status_code=404, detail="Business not found")

    bname = agent_business_segment(business.name)
    vstr = f"v{mv.version}"
    # Where the version's files are (resolve_version_volume_catalog).
    catalog = resolve_version_volume_catalog(mv, session, config)
    if not catalog:
        # No per-version catalog AND no installation metamodel catalog: this is
        # the config-missing case. Emit the structured 422 config_missing
        # (before any destructive teardown - never start a clear we can't
        # finish) rather than a bare 400.
        require_config(session, config, ["metamodel_catalog"], mode="raise")
        raise HTTPException(status_code=400, detail="No catalog configured for this version")

    sync = ModelSyncService(session, ws, resolve_warehouse_id(session, config))
    mv_scope = mv.scope or ""
    mv_version = mv.version

    # Close the preflight read transaction (mv/business/catalog/warehouse
    # lookups above) BEFORE the Volume/warehouse read below. Leaving it open
    # across that read means the network round-trip + JSON parse sits inside
    # an idle-open Postgres transaction for its whole duration — the same
    # read-then-release discipline applied to the seed/artifact-copy paths
    # elsewhere in this codebase. Nothing has been written yet, so this is a
    # no-op commit, purely to release the connection.
    session.commit()

    volume_started = time.monotonic()
    # Pass model_scope so the next_vibes loader looks in the right
    # ``v{N}/{scope}`` Volume folder instead of falling back to the
    # scopeless ``v{N}`` layout (which has no next_vibes artifact).
    model_data, next_vibes_payload, next_vibes_path = sync.load_resync_sources(
        catalog, bname, vstr, mv_scope
    )
    volume_elapsed = time.monotonic() - volume_started
    logger.info(
        "[resync] version=%s model.json/next-vibes Volume+warehouse read took %.2fs",
        version_id, volume_elapsed,
    )
    if not model_data:
        raise HTTPException(status_code=404, detail="No model data found in Delta tables or Volumes")

    # Write phase: teardown + rebuild + next-vibes capture, all with the
    # payloads already in hand — no further Volume/warehouse I/O below, so
    # this transaction is never idle waiting on a network read.
    write_started = time.monotonic()
    sync.clear_version_data(version_id)
    try:
        sync.sync_model(
            version_id, catalog, bname, vstr, model_scope=mv_scope,
            preloaded_model_data=model_data,
            next_vibes_preload=(next_vibes_payload, next_vibes_path),
        )
    except _SyncEmptyError:
        # G2: load_resync_sources returned a non-empty dict that parsed to 0
        # domains, so the post-sync gate raised. clear_version_data already
        # ran but nothing is committed — roll it back so the version keeps its
        # existing rows (no data loss), then return the same 404 as the G1
        # no-data case above rather than a 500.
        session.rollback()
        raise HTTPException(
            status_code=404,
            detail="Model output is empty (0 domains) — nothing to sync",
        )
    # A successful resync repairs the model, so clear any stale failure state
    # (incomplete_metadata / finalize_failed) — nothing else resets it, so the
    # warning banner would otherwise persist forever on a recovered version.
    mv_row = session.get(ModelVersion, version_id)
    if mv_row is not None and mv_row.sync_state != "ok":
        mv_row.sync_state = "ok"
        mv_row.sync_error_text = None
        session.add(mv_row)
    session.commit()
    write_elapsed = time.monotonic() - write_started
    logger.info(
        "[resync] version=%s DB write phase (clear+rebuild+capture) took %.2fs",
        version_id, write_elapsed,
    )

    # Drop the in-memory explorer cache so the next `/versions/{N}/model`
    # call reads the freshly-synced Lakebase state. Without this, resync
    # looks like a no-op from the UI for the lifetime of the process.
    from ..explorer import invalidate_model_cache
    invalidate_model_cache(business_id, mv_version)
    return {"ok": True, "message": f"Re-synced model data for version {mv_version}"}


@router.post(
    "/businesses/{business_id}/versions/import-from-volume",
    response_model=dict,
    operation_id="importVersionFromVolume",
)
def import_version_from_volume(
    business_id: str,
    session: Dependencies.Session,
    ws: Dependencies.Client,
    config: Dependencies.Config,
    tracker: Dependencies.Tracker,
    _role: Dependencies.AdminOnly,
    volume_path: str,
    new_version_number: Optional[int] = None,
    scope: Optional[Literal["ecm", "mvm"]] = None,
    catalog: Optional[str] = None,
    base_version_id: Optional[str] = None,
    vibe_instructions: str = "",
    databricks_run_id: Optional[int] = None,
):
    """Admin recovery: create a new ModelVersion on `business_id` populated
    from a model.json at `volume_path` (e.g.
    `/Volumes/vibe_model_test/_metamodel/vol_root/business/test_ecommerce/v3_mvm/model.json`).

    Useful when a vibe run produced a valid model in the Volume but the
    subsequent sync / job termination failed, leaving Lakebase without a
    corresponding ModelVersion row. Avoids re-running the pipeline.

    Phase 4 (Group B — recovery runs): the core read → ModelVersion
    insert → Lakebase sync now runs through the
    :class:`Orchestrator` (1-op DAG with the ``import_from_volume``
    primitive). The route still owns the surrounding admin features
    (agent-compat verdict, Delta write for cross-store consistency)
    since those are not part of the primitive's contract.

    - `new_version_number`: if omitted, uses max(existing version) + 1.
    - `databricks_run_id`: the run that produced the file, linked after the
      import commits (``run_link.link_after_import``); a refused link keeps
      the import and returns its reason in ``warnings``.
    """
    business = session.get(Business, business_id)
    if not business:
        raise HTTPException(status_code=404, detail="Business not found")

    # Defence-in-depth: admin is already trusted, but a bad typo or a
    # copy-paste of an unrelated path shouldn't silently import into the
    # wrong business. Enforce a path shape that matches the agent's Volume
    # convention: must be an absolute UC Volume path ending in model.json,
    # and must not contain `..` traversal segments. The primitive's
    # ``params_model`` enforces a subset of these (``/Volumes/`` prefix +
    # no ``..`` segments); the route adds the ``model.json`` suffix gate.
    if (
        not volume_path.startswith("/Volumes/")
        or not volume_path.endswith("/model.json")
        or ".." in volume_path.split("/")
    ):
        raise HTTPException(
            status_code=422,
            detail=(
                "volume_path must be an absolute UC Volume path ending in "
                "/model.json (e.g. /Volumes/<catalog>/_metamodel/vol_root/"
                "business/<name>/v<N>_<scope>/model.json) with no `..` segments."
            ),
        )

    # Load model.json once for the agent-compat pre-check + the Delta
    # mirror later. The primitive will re-read inside dispatch — these
    # two reads see the same Volume snapshot in practice; the recovery
    # path is rare and not in any hot loop.
    try:
        resp = ws.files.download(volume_path)
        raw = resp.contents.read()
        doc = json.loads(raw)
    except Exception as e:
        raise HTTPException(status_code=502, detail=f"Could not read the file at volume_path: {e}")

    # Accept either a flat model.json (domains at top level) or the
    # nested `{model: {...}}` wrapper that the current agent writes.
    model_payload = doc.get("model") if isinstance(doc, dict) and "model" in doc else doc
    if not isinstance(model_payload, dict) or "domains" not in model_payload:
        raise HTTPException(
            status_code=422,
            detail="model.json is missing a `domains` array (neither at top level nor under `model`).",
        )

    from ..core._defaults import SUPPORTED_AGENT_VERSION
    gate = gate_model_json(doc, fallback=SUPPORTED_AGENT_VERSION)
    if gate.refused:
        raise HTTPException(status_code=422, detail=gate.refusal_detail())
    if gate.needs_adapter:
        logger.warning("import_version_from_volume: %s", gate.adapter_warning)

    # The scope the import lands in (``import_model.import_scope``: the file's
    # version, else ``scope``, else its requirements, else its folder). When
    # nothing answers, or ``scope`` contradicts the file, the primitive fails
    # its step with the reason and the route answers 502 below.
    try:
        resolved_scope: Optional[str] = import_scope(doc, volume_path, scope)
    except ImportScopeError:
        resolved_scope = None

    # Resolve the new version number for the conflict pre-check. The
    # primitive will allocate ``next_version_for_scope`` itself (per the
    # post-refactor natural key (business, version, scope)), so when a
    # caller supplies an explicit number that doesn't match, we reject
    # early. Siblings in the OTHER scope don't influence the ordinal.
    auto_new_version = (
        next_version_for_scope(session, business_id, resolved_scope) if resolved_scope else None
    )
    if new_version_number is not None and auto_new_version is not None and new_version_number != auto_new_version:
        raise HTTPException(
            status_code=400,
            detail=(
                f"new_version_number={new_version_number} does not match the "
                f"next available number ({auto_new_version}) for scope={resolved_scope!r}. "
                f"The orchestrator-driven import allocates per-scope; remove the "
                f"override or set it to {auto_new_version}."
            ),
        )
    new_version_number = auto_new_version

    # Conflict if that (version, scope) somehow already exists (race
    # between the latest-lookup and the primitive's insert).
    existing = resolve_model_version(
        session, business_id, new_version_number, resolved_scope,
    ) if resolved_scope and new_version_number is not None else None
    if existing:
        raise HTTPException(
            status_code=409,
            detail=(
                f"ModelVersion v{new_version_number} (scope={resolved_scope!r}) already "
                f"exists for this business."
            ),
        )

    # Resolve catalog — default to whatever the latest version (in any
    # scope) used. The latest row is the best signal of the catalog the
    # business is currently deployed into.
    if not catalog:
        latest_any = session.exec(
            select(ModelVersion)
            .where(ModelVersion.business_id == business_id)
            .order_by(ModelVersion.version.desc())
        ).first()
        catalog = None
        if latest_any:
            catalog = latest_any.uc_catalog or None

    # Build + validate the 1-op DAG.
    biz_name_slug = agent_business_segment(business.name)
    import_req = ImportFromVolumeRequest(
        volume_path=volume_path,
        deployment_catalog=catalog or "",
        business_name=biz_name_slug,
        scope=scope,
    )
    dag = dag_for_import_from_volume(import_req)
    validation = validate_dag(dag, registry_get=_operations_pkg.get)
    if validation.blockers:
        raise HTTPException(
            status_code=400,
            detail={
                "error": "invalid import-from-volume DAG",
                "blockers": [
                    {
                        "field_path": iss.field_path,
                        "step_index": iss.step_index,
                        "message": iss.message,
                    }
                    for iss in validation.blockers
                ],
            },
        )

    # Synthesize the Run row. The primitive is synchronous (does the
    # whole import in dispatch), so we drive start + advance inline and
    # return only after the version exists. ``parameters_json`` carries
    # the volume_path / scope / source markers the legacy admin endpoint
    # set — keeps the run history readable.
    now = datetime.now(timezone.utc)
    synthetic_run = Run(
        business_id=business_id,
        intent="import-from-volume",
        status="pending",
        progress_message="Importing from Volume",
        parameters_json=json.dumps({
            "volume_path": volume_path,
            "scope": resolved_scope or scope or "",
            "source": "import_from_volume",
            "deployment_catalog": catalog or "",
        }),
        started_at=now,
    )
    session.add(synthetic_run)
    session.commit()
    session.refresh(synthetic_run)

    try:
        tracker.orchestrator.start(synthetic_run, dag, session)
        # The primitive runs entirely inside dispatch; one advance tick
        # observes its terminal-success and stamps run.version_id +
        # status="completed".
        tracker.orchestrator.advance(synthetic_run, session)
        session.commit()
        session.refresh(synthetic_run)
    except Exception as e:
        # Wiring audit (versions.py import orchestrator failure):
        #   Previous: direct synthetic_run.status write.
        #   New: transition_run stamps all five layers atomically.
        from ..run_state_transitions import transition_run
        reason = f"Import orchestrator failed: {recorded_error_text(e, 'Import orchestrator', str(e))}"
        synthetic_run.error_message = reason
        session.add(synthetic_run)
        transition_run(session, synthetic_run, target_status="failed", reason=reason)
        session.commit()
        raise HTTPException(
            status_code=500,
            detail=f"Import failed: {synthetic_run.error_message}",
        )

    if synthetic_run.status != "completed" or not synthetic_run.version_id:
        # Primitive reported a soft failure (file-read / parse / schema
        # errors are surfaced as terminal-failed observations).
        raise HTTPException(
            status_code=502,
            detail=f"Import did not complete: {synthetic_run.error_message or 'unknown error'}",
        )

    mv = session.get(ModelVersion, synthetic_run.version_id)
    if mv is None:  # defensive — version_id pointed somewhere stale
        raise HTTPException(
            status_code=500,
            detail="Import completed but ModelVersion is missing",
        )

    # Post-process: the primitive lays down the bare ModelVersion +
    # Lakebase rows. The route still owns the catalog/scope rewrite +
    # supersession + Delta mirror — features that aren't part of the
    # primitive's contract but the legacy admin endpoint shipped.
    landed_scope = mv.scope or ""
    if base_version_id:
        mv.base_version_id = base_version_id
    if vibe_instructions:
        mv.vibe_instructions = vibe_instructions
    session.add(mv)

    if catalog:
        # The import primitive recorded the version installed in ``catalog``.
        evict_deployed_siblings(session, mv, same_scope=False, run_id=synthetic_run.id)

    # Drop the explorer cache for this version so a subsequent model fetch
    # reads fresh data rather than a pre-import snapshot.
    from ..explorer import invalidate_model_cache
    invalidate_model_cache(business_id, mv.version)

    # Mirror into Delta so a future `vibe modeling of version` run
    # targeting this version doesn't die on the agent's
    # `_version_exists` check.
    delta_written = False
    delta_warnings: list[str] = []
    warehouse_id = resolve_warehouse_id(session, config)
    if warehouse_id and catalog:
        sync = ModelSyncService(session, ws, warehouse_id=warehouse_id)
        # Nested (agent 4.9.8+) canonical layout; the builder normalizes the
        # business segment the same way ``biz_name_slug`` does.
        delta_volume_path = _version_root_in_volume(
            catalog, business.name, str(mv.version), landed_scope
        )
        try:
            delta_written = sync.write_model_to_delta(
                catalog=catalog,
                business_name=business.name,
                version=str(mv.version),
                model_scope=landed_scope,
                volume_path=delta_volume_path,
                model_payload=model_payload,
            )
        except Exception as exc:
            logger.exception(
                "import_version_from_volume: Delta write failed; Lakebase was still populated"
            )
            delta_warnings = seed_warnings({"errors": [seed_error_text(exc)]})

    session.commit()
    linked_run_id, link_warning = (None, None)
    if databricks_run_id is not None:
        linked_run_id, link_warning = link_after_import(session, ws, business, mv, databricks_run_id)
    return {
        "ok": True,
        "version_id": mv.id,
        "version": mv.version,
        "run_id": synthetic_run.id,
        "linked_run_id": linked_run_id,
        "warnings": delta_warnings + ([link_warning] if link_warning else []),
        "delta_written": delta_written,
        "detected_agent_tag": gate.tag,
        "compat_verdict": gate.verdict,
        "latest_supported_tag": latest_supported_tag(),
    }


# --- Uninstall impact ------------------------------------------------------

@router.get(
    "/businesses/{business_id}/versions/{version_id}/uninstall-impact",
    response_model=UninstallImpactOut,
    operation_id="getUninstallImpact",
)
def get_uninstall_impact(
    business_id: str,
    version_id: str,
    session: Dependencies.Session,
    ws: Dependencies.Client,
    config: Dependencies.Config,
    user: Dependencies.UserIdentity,
    _role: Dependencies.ModelerOnly,
    catalog: Optional[str] = None,
    cataloging_style: Optional[
        Literal["One Catalog", "Catalog per Division", "Catalog per Domain"]
    ] = None,
):
    """What uninstalling the version from ``catalog`` drops: its schemas with
    their tables (and which hold rows), views and volumes, and the catalog's
    shared ``_metrics`` schema.

    ``catalog`` defaults the way the uninstall run resolves it
    (``resolve_uninstall_target_catalog``: the run's catalog, else where the
    version was last installed, else the installation's metamodel catalog)
    and is lower-cased. A version installed in several catalogs has one
    impact per catalog; the response lists them in ``installed_catalogs``.
    ``cataloging_style`` is the style the uninstall will run with; without
    it, the style of the version's last install. Results are cached for 60 s;
    each caller may start a limited number of scans per minute (429 with
    ``Retry-After``).
    """
    mv = get_model_version_in_business(session, business_id, version_id)
    agent_cfg = _get_or_create_agent_config(session, config)
    target = resolve_uninstall_target_catalog(
        SimpleNamespace(deployment_catalog=catalog or ""), mv, agent_cfg
    ).lower()
    if not target:
        raise HTTPException(
            status_code=422,
            detail={"message": "No catalog is configured. Choose the catalog to check."},
        )
    require_catalog_name(target)
    try:
        return uninstall_impact(
            session, ws, resolve_warehouse_id(session, config), mv, target,
            cataloging_style=cataloging_style, user=user,
        )
    except ScanRateLimited as exc:
        raise scan_rate_limited(exc.retry_after_s, "uninstall checks") from exc


# --- Installation drift detection (#69) -----------------------------------


@router.get(
    "/model-versions/{model_version_id}/installation-status",
    response_model=InstallationStatusOut,
    operation_id="getInstallationStatus",
)
def get_installation_status(
    model_version_id: str,
    session: Dependencies.Session,
    ws: Dependencies.Client,
):
    """Lightweight catalog-vs-Lakebase drift probe for a model version.

    Compares the schemas Lakebase recorded for ALL of this version's
    domains against the catalog's actual schema list. Used by the
    model-version Overview page to detect cases where Lakebase says
    "Installed" but the underlying physical schemas have been dropped
    or overwritten externally.

    Returns ``in_sync=False`` when Lakebase claims installed but ≥1
    expected schema is missing. The UI pops a non-dismissible reconcile
    dialog in that case. Returns ``in_sync=None`` when the probe could
    not run at all (no catalog recorded, no domains, or the catalog
    listing call itself failed) — an honest "unknown", never a false
    "healthy" (``True``) or a false-alarm forced reconcile (``False``).
    """
    mv = session.get(ModelVersion, model_version_id)
    if mv is None:
        raise HTTPException(status_code=404, detail="ModelVersion not found")

    install_catalog = (mv.uc_catalog or "").strip()
    lakebase_says = mv.deployment_status == "deployed"
    also_installed_in = [c for c in installed_catalogs(session, mv) if c != install_catalog]
    candidates = expected_schema_candidates_for_version(
        session, model_version_id, mv.scope, install_catalog
    )

    # No catalog recorded means we never tried to install (or we have no
    # domains to check against) — we genuinely don't know whether this
    # version is in sync. ``in_sync=None`` says "unknown" honestly instead
    # of the previous ``True``, which read as a healthy signal to any
    # caller of this endpoint even though no probe ever ran (the FE
    # dialog treats anything other than an explicit ``False`` as "don't
    # force a reconcile", so this is also safe for that consumer).
    if not install_catalog or not candidates:
        return InstallationStatusOut(
            version_id=model_version_id,
            deployment_catalog=install_catalog,
            lakebase_says_installed=lakebase_says,
            expected_schemas=[default for default, _ in candidates],
            found_schemas=[],
            missing_schemas=[],
            catalog_present=False,
            in_sync=None,
            checked_at=datetime.now(timezone.utc),
            skipped_reason=(
                "no deployment_catalog or no domains recorded; cannot probe"
            ),
            also_installed_in=also_installed_in,
        )

    try:
        expected, found = resolve_expected_and_found_schemas(
            ws, install_catalog, candidates
        )
    except Exception as exc:  # noqa: BLE001
        # SDK error — don't lie about drift, surface the skip cleanly.
        # Same "unknown, not healthy" reasoning as the skip branch above:
        # the probe never actually ran against a live catalog listing.
        fallback_expected = [default for default, _ in candidates]
        return InstallationStatusOut(
            version_id=model_version_id,
            deployment_catalog=install_catalog,
            lakebase_says_installed=lakebase_says,
            expected_schemas=fallback_expected,
            found_schemas=[],
            missing_schemas=fallback_expected,
            catalog_present=False,
            in_sync=None,
            checked_at=datetime.now(timezone.utc),
            skipped_reason=f"could not list schemas: {exc}",
            also_installed_in=also_installed_in,
        )

    missing = sorted(s for s in expected if s not in set(found))
    catalog_present = len(found) > 0
    # Every other catalog the version is installed in must hold its schemas too.
    other_missing: list[str] = []
    skipped_reason: Optional[str] = None
    for other in also_installed_in:
        other_candidates = expected_schema_candidates_for_version(
            session, model_version_id, mv.scope, other
        )
        try:
            other_expected, other_found = resolve_expected_and_found_schemas(
                ws, other, other_candidates
            )
        except Exception as exc:  # noqa: BLE001
            skipped_reason = f"could not list schemas in {other}: {exc}"
            continue
        other_missing.extend(f"{other}.{s}" for s in sorted(set(other_expected) - set(other_found)))
    # Drift = Lakebase says installed but a catalog disagrees.
    in_sync: Optional[bool] = (not lakebase_says) or not (missing or other_missing)
    if in_sync and skipped_reason:
        in_sync = None

    return InstallationStatusOut(
        version_id=model_version_id,
        deployment_catalog=install_catalog,
        lakebase_says_installed=lakebase_says,
        expected_schemas=expected,
        found_schemas=found,
        missing_schemas=missing + other_missing,
        catalog_present=catalog_present,
        in_sync=in_sync,
        checked_at=datetime.now(timezone.utc),
        skipped_reason=skipped_reason,
        also_installed_in=also_installed_in,
    )


@router.post(
    "/model-versions/{model_version_id}/reconcile-installation",
    response_model=ReconcileInstallationOut,
    operation_id="reconcileInstallation",
)
def reconcile_installation(
    model_version_id: str,
    session: Dependencies.Session,
    ws: Dependencies.Client,
    _role: Dependencies.BusinessAdminOnly,
):
    """Make Lakebase agree with the catalog for one model version.

    The user lands on this endpoint when the drift dialog detects
    Lakebase ↔ catalog disagreement. We re-probe the catalog and apply
    the same rule ``get_installation_status`` uses for ``in_sync``, so a
    reconciled version never re-triggers the dialog:

    - Every expected schema present → ``deployment_status='deployed'``.
    - Any expected schema missing on a ``deployed`` row →
      ``'uninstalled'``. A partial install is not an install; keeping
      ``deployed`` here left the probe reporting drift on every visit.
      Bare-name candidates can also match another business's schemas in a
      shared catalog, so "some found" is not evidence of this install.
    - Any expected schema missing on a non-deployed row → unchanged.
    - A Dry Run draft is never marked deployed: it shares its base's schema
      names, so the probe cannot tell its install from the base's.
    - Every other catalog the version is installed in (an open install row)
      is probed too; one missing a schema closes that catalog's row only.

    We do NOT touch the agent's ``_metamodel`` rows here — that's an
    upstream cleanup the user can drive via a fresh ``uninstall`` run
    once they want to reclaim those rows. The point of this endpoint
    is to make the *app's* view honest, fast.
    """
    mv = session.get(ModelVersion, model_version_id)
    if mv is None:
        raise HTTPException(status_code=404, detail="ModelVersion not found")

    install_catalog = (mv.uc_catalog or "").strip()
    candidates = expected_schema_candidates_for_version(
        session, model_version_id, mv.scope, install_catalog
    )
    notes: list[str] = []

    if not install_catalog or not candidates:
        notes.append(
            "no deployment_catalog or no domains recorded; nothing to reconcile"
        )
        return ReconcileInstallationOut(
            version_id=model_version_id,
            previous_deployment_status=mv.deployment_status,
            new_deployment_status=mv.deployment_status,
            schemas_present=[],
            schemas_missing=[],
            notes=notes,
        )

    try:
        expected, found = resolve_expected_and_found_schemas(
            ws, install_catalog, candidates
        )
    except Exception as exc:  # noqa: BLE001
        raise HTTPException(
            status_code=502,
            detail=f"Could not list schemas in {install_catalog!r}: {exc}",
        )

    missing = sorted(s for s in expected if s not in set(found))
    previous = mv.deployment_status
    others = [c for c in installed_catalogs(session, mv) if c != install_catalog]

    notes.append(
        f"{len(found)}/{len(expected)} expected schemas present in catalog"
    )
    for other in others:
        other_candidates = expected_schema_candidates_for_version(
            session, model_version_id, mv.scope, other
        )
        try:
            other_expected, other_found = resolve_expected_and_found_schemas(
                ws, other, other_candidates
            )
        except Exception as exc:  # noqa: BLE001
            notes.append(f"could not list schemas in {other}: {exc}; left as it is")
            continue
        if set(other_expected) - set(other_found):
            mark_version_uninstalled(session, mv, other)
            notes.append(f"not all expected schemas found in {other}; no longer recorded installed there")
    if not missing:
        if is_draft(mv):
            # A Dry Run draft shares its base's schema names, so the base's
            # installed schemas look like the draft's. Only an install
            # (which makes the draft current) records it deployed.
            notes.append("a Dry Run draft is not marked deployed; install it to deploy it")
        elif install_catalog not in installed_catalogs(session, mv):
            mark_version_deployed(session, mv, install_catalog)
    elif install_catalog in installed_catalogs(session, mv):
        mark_version_uninstalled(session, mv, install_catalog)
        notes.append(
            "not all expected schemas found; marked uninstalled"
            if mv.deployment_status != "deployed"
            else f"not all expected schemas found in {install_catalog}; still installed in {mv.uc_catalog}"
        )

    session.commit()
    session.refresh(mv)

    return ReconcileInstallationOut(
        version_id=model_version_id,
        previous_deployment_status=previous,
        new_deployment_status=mv.deployment_status,
        schemas_present=found,
        schemas_missing=missing,
        notes=notes,
    )
