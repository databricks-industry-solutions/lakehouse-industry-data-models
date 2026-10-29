"""AssessConfig: readiness rule, reader seed, Settings Save (checks → apply → sync → commit)."""
from __future__ import annotations

import logging
from datetime import datetime, timezone

from databricks.sdk import WorkspaceClient
from databricks.sdk.errors.base import DatabricksError
from sqlalchemy.engine import Engine
from sqlmodel import Session, select

from ... import __version__ as APP_VERSION
from ..core._settings_seed import get_or_create_settings_row, seed_blank
from ..db_models import AssessConfig
from ..error_sanitization import sanitize_error_message
from .job_sync import SyncResult, sync_assessment_job
from .reader_sp import find_reader_sp, reader_not_found_message
from .schemas import AssessConfigIn

logger = logging.getLogger(__name__)


NOT_INSTALLED_DETAIL = "The bronze assessment skill is not installed"


def assess_ready(cfg: AssessConfig, installed: bool) -> tuple[bool, list[str]]:
    """Whether assessments can launch, and the plain reasons when they can't.

    Computed from the stored setup state only; nothing is probed. Ready means:
    installed, a reader set, the job created, synced for this app version with
    no recorded error, and running as the configured reader.
    """
    if not installed:
        return False, [NOT_INSTALLED_DETAIL]
    if not cfg.reader_application_id:
        return False, ["No reader service principal"]
    if cfg.job_setup_error:
        return False, [f"Job sync failed: {cfg.job_setup_error}"]
    missing: list[str] = []
    if not cfg.job_id:
        missing.append("The assessment job has not been created yet")
    if cfg.synced_version != APP_VERSION:
        missing.append(f"The assessment job has not been synced for app version {APP_VERSION}")
    if cfg.job_reader != cfg.reader_application_id:
        missing.append("The assessment job does not run as the configured reader")
    return not missing, missing


def get_or_create_assess_config(session: Session, config=None) -> AssessConfig:
    """The singleton row; a new row's reader is seeded from ``AppConfig.assess_reader_sp`` when given."""
    reader = (getattr(config, "assess_reader_sp", "") or "").strip()
    return get_or_create_settings_row(session, AssessConfig, {"reader_application_id": reader})


def seed_reader_from_install(session: Session, config) -> int:
    """Boot: fill an existing row's blank reader from the install default. A Settings value is kept.
    The caller commits."""
    return seed_blank(session, AssessConfig.reader_application_id, getattr(config, "assess_reader_sp", ""))


class AssessConfigRejected(ValueError):
    """A read-only Save check refused the value of the ``AssessConfigIn`` field ``key``; nothing was written."""

    def __init__(self, key: str, message: str):
        super().__init__(message)
        self.key = key


class AssessConfigMissing(Exception):
    """A setting the Save needs is unset (``key`` is its ``require_config`` key); nothing was written."""

    def __init__(self, key: str):
        super().__init__(key)
        self.key = key


class AssessReaderLookupFailed(Exception):
    """Looking up the reader service principal failed (a SCIM error, not a verdict); nothing was written."""


class AssessSyncFailed(Exception):
    """The job sync failed; the Save was rolled back and the error recorded."""

    def __init__(self, result: SyncResult, stored_job_id: int | None = None):
        super().__init__(result.error)
        self.result = result
        self.stored_job_id = stored_job_id

    @property
    def job_id(self) -> int | None:
        """The job the admin should open: the re-read one, else the one stored before the Save."""
        return self.result.reread.job_id if self.result.reread is not None else self.stored_job_id


def check_assess_config(ws: WorkspaceClient, body: AssessConfigIn, *, deployment_catalog: str):
    """Save's read-only checks: the deployment catalog is set, the reader and warehouse exist.

    Returns the resolved reader service principal, which Save hands to the sync so the reader is
    looked up once. Raises ``AssessConfigMissing`` when the deployment catalog is unset (checked
    first, before any workspace call), ``AssessConfigRejected`` on a refused value,
    ``AssessReaderLookupFailed`` when the reader lookup itself fails.
    """
    # The same predicate as routes/_helpers.require_config's ``metamodel_catalog`` requirement.
    if not deployment_catalog:
        raise AssessConfigMissing("metamodel_catalog")
    try:
        sp = find_reader_sp(ws, body.reader_application_id)
    except DatabricksError as e:
        raise AssessReaderLookupFailed(sanitize_error_message(str(e))) from e
    if sp is None:
        raise AssessConfigRejected("reader_application_id", reader_not_found_message(body.reader_application_id))
    if body.warehouse_id:
        try:
            ws.warehouses.get(body.warehouse_id)
        except DatabricksError as e:
            raise AssessConfigRejected(
                "warehouse_id",
                f"SQL warehouse {body.warehouse_id!r} not found or not visible to the app: "
                f"{sanitize_error_message(str(e))}") from e
    return sp


def record_sync_failure(engine: Engine, result: SyncResult) -> None:
    """Commit ``job_setup_error`` plus the re-read job id, reader and folder in its own transaction."""
    with Session(bind=engine) as s:
        cfg = s.exec(select(AssessConfig)).first()
        if cfg is None:
            return
        cfg.job_setup_error = result.error or "Job sync failed"
        if result.reread is not None:
            cfg.job_id, cfg.job_reader = result.reread.job_id, result.reread.job_reader
            cfg.workspace_path = result.reread.workspace_path
        s.add(cfg)
        s.commit()


def sync_and_commit(session: Session, ws: WorkspaceClient, cfg: AssessConfig, *, deployment_catalog: str,
                    app_version: str, reader_sp=None) -> SyncResult:
    """Sync, then commit a clean sync, or roll back and record the failure (boot and Save share this).

    ``reader_sp`` is the reader Save already resolved; boot passes none and the sync looks it up.
    """
    result = sync_assessment_job(session, ws, cfg, app_version, deployment_catalog=deployment_catalog,
                                 reader_sp=reader_sp)
    if result.ok:
        session.commit()
        session.refresh(cfg)
    else:
        session.rollback()
        record_sync_failure(session.get_bind(), result)
    return result


def save_assess_config(session: Session, ws: WorkspaceClient, body: AssessConfigIn, *,
                       deployment_catalog: str, user: str, app_version: str, config=None,
                       reader_sp=None) -> AssessConfig:
    """Apply ``body`` and sync; commits only a clean sync. Raises ``AssessSyncFailed`` otherwise.

    The row is locked (``SELECT ... FOR UPDATE``) for the whole Save, so a
    second Save waits and then sees the job the first one created instead of
    creating another. SQLite ignores the lock.
    """
    row_id = get_or_create_assess_config(session, config).id
    cfg = session.exec(select(AssessConfig).where(AssessConfig.id == row_id).with_for_update()
                       .execution_options(populate_existing=True)).one()
    stored_job_id = cfg.job_id
    cfg.reader_application_id = body.reader_application_id
    cfg.max_concurrent_runs = body.max_concurrent_runs
    cfg.default_reasoning_effort = body.default_reasoning_effort
    cfg.warehouse_id = body.warehouse_id
    cfg.updated_by = user
    cfg.updated_at = datetime.now(timezone.utc)
    result = sync_and_commit(session, ws, cfg, deployment_catalog=deployment_catalog, app_version=app_version,
                             reader_sp=reader_sp)
    if not result.ok:
        raise AssessSyncFailed(result, stored_job_id)
    return cfg
