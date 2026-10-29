"""The one writer of the assessment job's workspace folder, job and runs-volume grants.

``sync_assessment_job`` runs at boot (``core/_assess_init.py``) and on Settings
Save. It is check-then-act throughout, so a sync with everything already in
place makes no writes, and it never commits: the caller commits a clean sync,
or rolls back and calls ``config_service.record_sync_failure``.

0. Check the inputs (a reader that resolves in this workspace, and a deployment catalog) before touching anything.
1. Upload the vendored tree to ``<app SP home>/vibe-assess/<app version>/``
   unless the folder's manifest (sha256 per bundled file, written last)
   already matches; give the reader CAN_READ on the folder unless it already
   has read or better.
2. Ensure ``<catalog>._metamodel`` and its ``vol_root`` and ``assess_runs``
   volumes through the canonical ``ensure_metamodel_schema_and_volume`` (the
   sync can be the first to create ``_metamodel``), then grant the reader
   READ/WRITE VOLUME on ``assess_runs`` and USE SCHEMA on ``_metamodel``, each only where the reader's
   effective privileges lack it. Nothing is granted on any catalog.
3. Read the ``vibe-assess`` job; reset it only when a field the app sets
   differs, create it when missing (a reset error is raised, not replaced).
4. Record ``workspace_path``, ``job_id``, ``synced_version``, ``job_reader`` and the reader's
   ``reader_display_name`` (from the step-0 lookup; empty when that lookup failed) on the session.
5. Prune old version folders (``prune_job_folders``), best-effort.

On a failure in steps 0-3 the job is re-read so the stored id, reader and
folder reflect what Databricks actually has; nothing is pruned.
"""
from __future__ import annotations

import logging
import re
from dataclasses import dataclass

from databricks.sdk import WorkspaceClient
from databricks.sdk.errors.base import DatabricksError
from databricks.sdk.errors.platform import NotFound
from databricks.sdk.service.catalog import PermissionsChange, Privilege
from databricks.sdk.service.iam import AccessControlRequest, PermissionLevel
from databricks.sdk.service.workspace import ObjectType
from sqlmodel import Session, select

from ..core._app_identity import app_sp_home
from ..core._uc_privileges import effective_privileges, missing_privileges
from ..db_models import AssessConfig, AssessDomainRun
from ..error_sanitization import sanitize_error_message
from ..migrations.registry import _vkey
from ..services.metamodel_setup import METAMODEL_SCHEMA, VOL_ROOT, ensure_metamodel_schema_and_volume
from .assets import upload_assessment_assets
from .constants import JOB_FOLDER, RUNS_VOLUME, TERMINAL_STATUSES
from .job import setup_assessment_job
from .reader_sp import find_reader_sp, reader_not_found_message

logger = logging.getLogger(__name__)

NOTEBOOK_NAME = "assess_domain"


@dataclass
class JobState:
    """What Databricks has for the job, re-read after a failed sync."""
    job_id: int | None
    job_reader: str
    workspace_path: str


@dataclass
class SyncResult:
    ok: bool
    error: str = ""
    job_id: int | None = None
    job_reader: str = ""
    workspace_path: str = ""
    reread: JobState | None = None


def job_root(ws: WorkspaceClient) -> str:
    return f"{app_sp_home(ws)}/{JOB_FOLDER}"


def _grant_missing(ws: WorkspaceClient, securable_type: str, full_name: str, reader: str,
                   wanted: tuple[Privilege, ...]) -> None:
    """Grant ``reader`` the privileges in ``wanted`` that its effective privileges lack.

    Unreadable effective privileges count as missing (the grant is idempotent).
    """
    have = effective_privileges(ws, securable_type, full_name, reader)
    lacking = missing_privileges(have or set(), (p.value for p in wanted))
    missing = [p for p in wanted if p.value in lacking]
    if missing:
        ws.grants.update(securable_type, full_name, changes=[PermissionsChange(principal=reader, add=missing)])


def _reread_job(ws: WorkspaceClient, job_id: int | None) -> JobState | None:
    """The job as Databricks has it; ``None`` when it can't be read (keep what is stored)."""
    if not job_id:
        return JobState(job_id=None, job_reader="", workspace_path="")
    try:
        job = ws.jobs.get(job_id)
    except NotFound:
        return JobState(job_id=None, job_reader="", workspace_path="")
    except Exception as e:  # noqa: BLE001 — the sync error is already being recorded
        logger.warning("Could not re-read assessment job %s after a failed sync: %s", job_id, e)
        return None
    settings = job.settings
    run_as = getattr(settings, "run_as", None)
    reader = (getattr(run_as, "service_principal_name", None) or getattr(job, "run_as_user_name", None) or "")
    tasks = getattr(settings, "tasks", None) or []
    nb = getattr(getattr(tasks[0], "notebook_task", None), "notebook_path", "") if tasks else ""
    return JobState(job_id=job_id, job_reader=reader, workspace_path=(nb or "").rsplit("/", 1)[0])


def norm_workspace_path(path: str) -> str:
    """Workspace paths with and without the ``/Workspace`` prefix name the same object."""
    p = path.rstrip("/")
    return p[len("/Workspace"):] if p.startswith("/Workspace/") else p


# X.Y.Z(.N)* plus an optional post/rc/dev release with a numeric counter (``0.7.3.post2``, ``0.8.0rc1``).
_VERSION_RE = re.compile(r"(\d+(?:\.\d+){2,})(?:\.?(post|rc|dev)(\d+))?")
_PHASE_RANK = {"dev": 0, "rc": 1, None: 2, "post": 3}


def _folder_key(version: str) -> tuple[tuple[int, ...], int, int] | None:
    """A sort key for a version folder name, or ``None`` when the name is not a version.

    ``_vkey`` orders the numeric part (``0.8.0.9`` < ``0.8.0.10``); then
    ``devN`` < ``rcN`` < the final release < ``postN``, each by its numeric
    counter (``post9`` < ``post10``). A name that doesn't fully match
    (``2024-backup``, ``v0.8``, ``notes``) is not ours and is never pruned.
    """
    m = _VERSION_RE.fullmatch(version)
    if not m:
        return None
    return _vkey(m.group(1)), _PHASE_RANK[m.group(2)], int(m.group(3) or 0)


def prune_job_folders(session: Session, ws: WorkspaceClient, root: str, current: str) -> list[str]:
    """Delete ``root/<v>`` folders no run needs; returns the deleted paths.

    Keeps every version at or above ``current``, the newest one below it, and
    any folder a non-terminal run still reads. Keeping newer folders makes a
    downgrade safe: after rolling back to an older app, the newer version's
    folder stays (a later upgrade reuses it) and is pruned only once the
    running version passes it. Nothing is pruned when ``current`` is not a
    version. Best-effort: any error is logged and the sync still succeeds.
    """
    try:
        return _prune(session, ws, root, current)
    except Exception as e:  # noqa: BLE001 — the job is already repointed; pruning is housekeeping
        logger.warning("Pruning old assessment folders under %s failed: %s", root, e)
        return []


def _prune(session: Session, ws: WorkspaceClient, root: str, current: str) -> list[str]:
    cur = _folder_key(current)
    if cur is None:
        return []
    folders: dict[str, tuple[tuple, str]] = {}
    for e in ws.workspace.list(root):
        if getattr(e, "object_type", None) != ObjectType.DIRECTORY or not e.path:
            continue
        name = e.path.rstrip("/").rsplit("/", 1)[-1]
        key = _folder_key(name)
        if key is not None:
            folders[name] = (key, e.path)
    older = [n for n, (k, _) in folders.items() if k < cur]
    keep = {n for n, (k, _) in folders.items() if k >= cur}
    if older:
        keep.add(max(older, key=lambda n: folders[n][0]))
    pinned = [norm_workspace_path(nf) for nf in session.exec(
        select(AssessDomainRun.notebook_folder).where(AssessDomainRun.status.not_in(TERMINAL_STATUSES),
                                                     AssessDomainRun.notebook_folder != "")).all()]
    deleted: list[str] = []
    for name, (_, path) in sorted(folders.items(), key=lambda kv: kv[1][0]):
        p = norm_workspace_path(path)
        if name in keep or any(nf == p or nf.startswith(p + "/") for nf in pinned):
            continue
        try:
            ws.workspace.delete(path, recursive=True)
            deleted.append(path)
        except Exception as e:  # noqa: BLE001 — one undeletable folder doesn't stop the rest
            logger.warning("Could not prune old assessment folder %s: %s", path, e)
    return deleted


_READ_OR_BETTER = {"CAN_READ", "CAN_RUN", "CAN_EDIT", "CAN_MANAGE"}


def _ensure_reader_can_read(ws: WorkspaceClient, folder: str, reader: str) -> None:
    """Give ``reader`` CAN_READ on ``folder`` unless it already has read or better (incl. inherited)."""
    object_id = str(ws.workspace.get_status(folder).object_id)
    perms = ws.permissions.get("directories", object_id)
    for acl in getattr(perms, "access_control_list", None) or []:
        if getattr(acl, "service_principal_name", None) != reader:
            continue
        levels = {getattr(p.permission_level, "value", p.permission_level) for p in (acl.all_permissions or [])}
        if levels & _READ_OR_BETTER:
            return
    ws.permissions.update("directories", object_id, access_control_list=[
        AccessControlRequest(service_principal_name=reader, permission_level=PermissionLevel.CAN_READ)])


def sync_assessment_job(session: Session, ws: WorkspaceClient, cfg: AssessConfig, app_version: str, *,
                        deployment_catalog: str, reader_sp=None) -> SyncResult:
    """Bring the folder, runs volume, grants and job in line with ``cfg``; see the module docstring.

    ``reader_sp`` is the reader Save already resolved (used only when it is ``cfg``'s reader);
    without it, step 0 looks the reader up.
    """
    cfg.job_setup_error = ""
    reader = cfg.reader_application_id
    step = "Checking the assessment settings"
    try:
        if not reader:
            raise RuntimeError("No reader service principal is configured.")
        if not deployment_catalog:
            raise RuntimeError("The deployment catalog is not configured (Settings → Platform).")
        sp = reader_sp if getattr(reader_sp, "application_id", None) == reader else None
        if sp is None:
            try:
                sp = find_reader_sp(ws, reader)
                if sp is None:
                    raise RuntimeError(reader_not_found_message(reader))
            except DatabricksError:  # an unreadable lookup is no verdict; the job reset reports a real problem
                sp = None
        root = job_root(ws)
        folder = f"{root}/{app_version}"
        schema_full = f"{deployment_catalog}.{METAMODEL_SCHEMA}"
        step = "Uploading the assessment notebook"
        upload_assessment_assets(ws, folder)
        step = "Giving the reader CAN READ on the notebook folder"
        _ensure_reader_can_read(ws, folder, reader)
        step = f"Creating {schema_full} and its volumes {VOL_ROOT} and {RUNS_VOLUME}"
        ensure_metamodel_schema_and_volume(ws, deployment_catalog, volumes=(VOL_ROOT, RUNS_VOLUME))
        step = f"Granting the reader READ VOLUME and WRITE VOLUME on {schema_full}.{RUNS_VOLUME}"
        _grant_missing(ws, "volume", f"{schema_full}.{RUNS_VOLUME}", reader,
                       (Privilege.READ_VOLUME, Privilege.WRITE_VOLUME))
        step = f"Granting the reader USE SCHEMA on {schema_full}"
        _grant_missing(ws, "schema", schema_full, reader, (Privilege.USE_SCHEMA,))
        step = "Resetting or creating the assessment job"
        job_id = setup_assessment_job(ws, job_id=cfg.job_id, notebook_path=f"{folder}/{NOTEBOOK_NAME}",
                                      reader_application_id=reader, max_concurrent_runs=cfg.max_concurrent_runs)
    except Exception as e:  # noqa: BLE001 — every failure is recorded for the admin, never raised
        error = f"{step} failed: {type(e).__name__}: {sanitize_error_message(str(e))}"[:2000]
        logger.warning("Assessment job sync failed: %s", error)
        return SyncResult(ok=False, error=error, reread=_reread_job(ws, cfg.job_id))
    cfg.workspace_path, cfg.job_id, cfg.synced_version, cfg.job_reader = folder, job_id, app_version, reader
    cfg.reader_display_name = (sp.display_name or "") if sp is not None else ""
    session.add(cfg)
    prune_job_folders(session, ws, root, app_version)
    return SyncResult(ok=True, job_id=job_id, job_reader=reader, workspace_path=folder)
