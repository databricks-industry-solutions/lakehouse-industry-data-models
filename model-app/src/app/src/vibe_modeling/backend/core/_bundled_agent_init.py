"""Lifespan: install or upgrade the bundled agent notebook on every boot.

* **No notebook configured** (fresh install, manual reset, or a Lakebase
  reprovision wiped the row): install the bundled notebook into the app's
  agent folder and create the persistent Databricks Job, so the app is
  usable from the first request with no external installer step.
* **App-owned notebook** (a path in the app's own agent folder,
  ``core/_agent_identity.is_app_owned``): when the bundled (release, marker)
  is newer than the notebook's, or the notebook's identity cannot be read,
  upload the bundled notebook, point ``AgentConfig.notebook_path`` and the
  job at it, and log one line. The app always upgrades its own notebook;
  there is no opt-out.
* **Admin-owned notebook** (any other path): never touched. Its identity is
  still read, so Settings can show the gap and offer "Switch to bundled".
  That read happens even when the build has no bundled notebook.

Defensive checks: the deploy guard (``install/in_flight_guard.sh``) refuses
a deploy while a run is active, but it lets the deploy through when it
cannot read the App's health, and an Apps restart boots without any guard.
So the upgrade skips, with a log line, while ``core/_runs.count_in_flight_runs``
is not zero; the next boot upgrades.

The work runs on a daemon thread with a deadline ``BOOT_AGENT_BUDGET_SECONDS``
after boot starts, so a stuck workspace or Jobs call cannot hold the
lifespan (the app does not serve until it finishes) or delay process exit.
Once the deadline has passed the thread changes neither the notebook path
nor the job: it logs and stops, and the next boot retries. Right before the
job is moved it re-checks the deadline, the in-flight runs and that the
stored notebook path is still the one it read (compare-and-set), so a run
started meanwhile is never moved to another agent and an admin's Settings
save always wins. Every failure is logged; Settings stays usable for
recovery.

After the upgrade step (also when it failed, not when it was aborted),
``sync_agent_job_tags`` gives the agent job the app identity tags when they
are missing or differ, so a job whose notebook did not move carries them
right after an upgrade.
"""

from __future__ import annotations

import asyncio
import threading
import time
from contextlib import asynccontextmanager
from datetime import datetime, timedelta, timezone
from typing import AsyncGenerator, Optional

from fastapi import FastAPI
from sqlalchemy import update
from sqlmodel import Session, select

from ..db_models import AgentConfig
from ._agent_identity import (
    compare_to_bundled,
    installed_identity,
    is_app_owned,
    record_installed_identity,
)
from ._app_identity import app_sp_home
from ._base import LifespanDependency
from ._config import logger
from ._runs import count_in_flight_runs

BOOT_AGENT_BUDGET_SECONDS = 60


class _BundledAgentInitDependency(LifespanDependency):
    @asynccontextmanager
    async def lifespan(self, app: FastAPI) -> AsyncGenerator[None, None]:
        await run_boot_agent_install(
            app.state.engine, app.state.workspace_client, app.state.config
        )
        yield

    @staticmethod
    def __call__() -> None:
        # Boot-time only — no per-request resource to inject.
        return None


def _boot_agent_install_in_session(engine, ws, config, deadline: Optional[float] = None) -> None:
    """The boot step on its own session; never raises (the thread may outlive the lifespan wait)."""
    try:
        # expire_on_commit=False: the steps commit between workspace and Jobs
        # API calls and read AgentConfig attributes again afterwards. Under the
        # default expire_on_commit=True that read would re-open a transaction
        # that idles across the slow call.
        with Session(bind=engine, expire_on_commit=False) as session:
            _ensure_bundled_agent_installed(session, ws, config, deadline=deadline)
    except AgentChangeAborted as e:
        logger.warning("Bundled agent install/upgrade stopped: %s", e)
    except Exception:
        logger.exception(
            "Bundled agent install/upgrade failed; the app still serves. "
            "Check Settings -> Agent Configuration."
        )


async def run_boot_agent_install(
    engine, ws, config, *, budget_seconds: float = BOOT_AGENT_BUDGET_SECONDS
) -> None:
    """Run the boot install/upgrade on a daemon thread, waiting at most ``budget_seconds``.

    The thread gets the same deadline: past it, it moves neither the
    notebook path nor the job. A daemon thread never delays process exit.
    """
    deadline = time.monotonic() + budget_seconds
    done = threading.Event()

    def target() -> None:
        try:
            _boot_agent_install_in_session(engine, ws, config, deadline)
        finally:
            done.set()

    threading.Thread(target=target, name="boot-agent", daemon=True).start()
    while not done.is_set() and time.monotonic() < deadline:
        await asyncio.sleep(0.05)
    if not done.is_set():
        logger.warning(
            "Bundled agent install/upgrade did not finish within %ss; the app boots "
            "without waiting and the step will not move the agent now. The next "
            "boot retries. Check Settings -> Agent Configuration.",
            budget_seconds,
        )


class AgentJobSetupError(RuntimeError):
    """The bundled notebook was uploaded but the agent job could not be updated."""


class AgentChangeAborted(Exception):
    """The agent was left as it is: the boot deadline passed, a run is in
    flight, or the configured notebook changed since it was read."""


def _deadline_passed(deadline: Optional[float]) -> bool:
    return deadline is not None and time.monotonic() >= deadline


def _stored_notebook_path(session: Session, cfg_id: str) -> str:
    return session.exec(select(AgentConfig.notebook_path).where(AgentConfig.id == cfg_id)).one()


def _check_still_safe(session: Session, cfg_id: str, expected_path: str, deadline: Optional[float]) -> None:
    """Raise ``AgentChangeAborted`` unless the agent may be moved now."""
    if _deadline_passed(deadline):
        raise AgentChangeAborted("the boot time budget has passed; the next boot retries")
    stored = _stored_notebook_path(session, cfg_id)
    if stored != expected_path:
        raise AgentChangeAborted(
            f"the configured notebook changed to {stored or '(none)'} meanwhile; left as it is"
        )
    in_flight = count_in_flight_runs(session)
    # Close the read transaction so none idles across the Jobs call that follows.
    session.rollback()
    if in_flight:
        raise AgentChangeAborted(f"{in_flight} run(s) in flight; the agent is not moved under a run")


def _check_after_job_move(
    session: Session, ws, cfg_id: str, deadline: Optional[float], *, converge: bool = True
) -> None:
    """After the job moved: when the deadline passed or a run started
    meanwhile, point the job back at the stored notebook (``converge``) and stop."""
    reason = None
    if _deadline_passed(deadline):
        reason = "the boot time budget passed while the job was updated; the next boot retries"
    else:
        in_flight = count_in_flight_runs(session)
        if in_flight:
            reason = f"{in_flight} run(s) started while the job was updated; the agent is not moved under a run"
    if reason:
        if converge:
            converge_agent_job_to_row(session, ws, cfg_id)
        raise AgentChangeAborted(reason)


def _job_notebook_path(ws, job_id: Optional[int]) -> Optional[str]:
    if not job_id:
        return None
    job = ws.jobs.get(job_id=job_id)
    tasks = getattr(getattr(job, "settings", None), "tasks", None) or []
    for task in tasks:
        notebook_task = getattr(task, "notebook_task", None)
        if notebook_task is not None:
            return notebook_task.notebook_path
    return None


def converge_agent_job_to_row(session: Session, ws, cfg_id: str) -> None:
    """Point the agent job at the stored notebook when it names another one.

    Used after a failed or lost move and after every Settings save. Decides
    from the real state: re-reads the row and the job, resets the job only
    when it differs (creating it when the row has no job), and saves a new
    job id with a compare-and-set on the path. Best effort: a failure is
    logged, the caller's own error stays the one raised, and the next boot or
    Settings save repairs it.
    """
    from ..job_launcher import setup_agent_job

    try:
        session.rollback()
        stored = session.get(AgentConfig, cfg_id, populate_existing=True)
        if stored is None or not stored.notebook_path:
            session.rollback()
            return
        snapshot = AgentConfig.model_validate(stored.model_dump())
        # Close the read transaction so none idles across the Jobs calls.
        session.rollback()
        if _job_notebook_path(ws, snapshot.job_id) == snapshot.notebook_path:
            return
        job_id = setup_agent_job(ws, snapshot)
        if job_id != snapshot.job_id:
            session.execute(
                update(AgentConfig)
                .where(AgentConfig.id == cfg_id, AgentConfig.notebook_path == snapshot.notebook_path)
                .values(job_id=job_id)
            )
            session.commit()
        logger.warning(
            "Agent job pointed at the configured notebook %s (job_id=%s).",
            snapshot.notebook_path,
            job_id,
        )
    except Exception:
        logger.exception(
            "Could not confirm the agent job points at the configured notebook; "
            "re-save Settings -> Agent Configuration."
        )


def point_agent_at_bundled(
    session: Session,
    ws,
    cfg: AgentConfig,
    *,
    expected_path: str,
    deadline: Optional[float] = None,
):
    """Upload the bundled notebook into the app's agent folder, then point the
    configuration and its job at it in one compare-and-set save.

    ``expected_path`` is the notebook path the caller read. Right before the
    job moves, the deadline, the in-flight runs and the stored path are
    checked again (``AgentChangeAborted``). The row is then updated only if
    it still holds ``expected_path``. When the job update fails, or the save
    loses to a concurrent Settings save or fails itself, the job is
    re-read and pointed back at the stored notebook (``converge_agent_job_to_row``).
    The same happens when the deadline passes or a run starts while the job
    is being updated.

    Raises ``AgentChangeAborted``, ``BundledAgentNotPackagedError`` (no
    notebook in the wheel), ``AgentJobSetupError`` (the Jobs API call failed,
    chained to its cause) or ``RuntimeError`` (identity or upload failure).
    Returns the ``InstallResult``.
    """
    from ..bundled_agent_install import install_bundled_agent_into_workspace
    from ..job_launcher import setup_agent_job

    if _deadline_passed(deadline):
        raise AgentChangeAborted("the boot time budget has passed; the next boot retries")
    result = install_bundled_agent_into_workspace(ws)
    cfg_id = cfg.id
    target = AgentConfig.model_validate(cfg.model_dump())
    target.notebook_path = result.path
    _check_still_safe(session, cfg_id, expected_path, deadline)
    try:
        job_id = setup_agent_job(ws, target)
    except Exception as e:
        converge_agent_job_to_row(session, ws, cfg_id)
        raise AgentJobSetupError(
            f"Failed to update the Databricks job: {e}"
        ) from e
    _check_after_job_move(session, ws, cfg_id, deadline)

    record_installed_identity(
        target, path=result.path, release=result.version, marker=result.agent_version
    )
    try:
        saved = session.execute(
            update(AgentConfig)
            .where(AgentConfig.id == cfg_id, AgentConfig.notebook_path == expected_path)
            .values(
                notebook_path=result.path,
                job_id=job_id,
                installed_release_version=target.installed_release_version,
                installed_agent_version=target.installed_agent_version,
                installed_check_error=None,
                installed_checked_path=result.path,
                installed_checked_at=target.installed_checked_at,
                updated_at=datetime.now(timezone.utc),
            )
        ).rowcount
        if saved != 1:
            raise AgentChangeAborted("the configured notebook changed meanwhile; left as it is")
        session.commit()
    except Exception:
        converge_agent_job_to_row(session, ws, cfg_id)
        raise
    session.refresh(cfg)
    return result


def _ensure_bundled_agent_installed(session: Session, ws, config, *, deadline: Optional[float] = None) -> None:
    """Install the bundled agent when none is configured, or upgrade an app-owned one."""
    from ..routes._helpers import _get_or_create_agent_config

    cfg = _get_or_create_agent_config(session, config)
    if not cfg.notebook_path:
        _install_fresh(session, ws, cfg, deadline)
        return
    cfg_id = cfg.id
    try:
        _upgrade_app_owned(session, ws, cfg, deadline)
    except AgentChangeAborted:
        raise
    except Exception:
        # A failed upgrade (an upload error) still leaves a job to tag.
        session.rollback()
        sync_agent_job_tags(session, ws, cfg_id, deadline)
        raise
    sync_agent_job_tags(session, ws, cfg_id, deadline)


def sync_agent_job_tags(session: Session, ws, cfg_id: str, deadline: Optional[float] = None) -> None:
    """Give the agent job the app identity tags (``job_launcher.app_job_tags``) when it
    lacks them or carries other values, as after an upgrade whose notebook did not move.

    Check, then act: reads the job's tags and writes only when they differ, merging
    the identity tags into the job's tag map (the last run's tags and every other
    setting stay). Skipped past the deadline or while a run is in flight; the next
    run's tags carry them too. Best effort: a failure is logged. Runs after the
    upgrade step, also when that step failed (not when it was aborted).

    The in-flight check and the write are not atomic: a run launched while the
    tags are written may see the previous run's tags until its next launch.
    """
    from databricks.sdk.service.jobs import JobSettings

    from ..job_launcher import app_job_tags

    try:
        stored = session.get(AgentConfig, cfg_id, populate_existing=True)
        job_id = stored.job_id if stored is not None else None
        session.rollback()
        if not job_id:
            return
        want = app_job_tags()
        current = getattr(getattr(ws.jobs.get(job_id=job_id), "settings", None), "tags", None)
        current = dict(current) if isinstance(current, dict) else {}
        if all(current.get(k) == v for k, v in want.items()):
            return
        if _deadline_passed(deadline):
            logger.warning("Agent job tags not updated: the boot time budget passed; the next boot retries.")
            return
        in_flight = count_in_flight_runs(session)
        session.rollback()
        if in_flight:
            logger.warning(
                "Agent job tags not updated: %d run(s) in flight; the next boot or run adds them.", in_flight
            )
            return
        ws.jobs.update(job_id=job_id, new_settings=JobSettings(tags={**current, **want}))
        logger.info("Agent job %s tagged with the app identity tags: %s", job_id, want)
    except Exception:
        logger.exception("Could not update the agent job's app identity tags; the next run adds them.")


def _install_fresh(session: Session, ws, cfg, deadline: Optional[float]) -> None:
    """First install: keep the uploaded path even when the job cannot be
    created, so a Settings save (which re-runs only the job setup) finishes
    the wiring. A path saved meanwhile in Settings wins: the path and the
    job id are each saved with a compare-and-set, and nothing is saved once
    the deadline passed (re-save Settings -> Agent Configuration then)."""
    from ..bundled_agent_install import (
        BundledAgentNotPackagedError,
        install_bundled_agent_into_workspace,
    )
    from ..job_launcher import setup_agent_job

    if _deadline_passed(deadline):
        raise AgentChangeAborted("the boot time budget has passed; the next boot retries")
    try:
        result = install_bundled_agent_into_workspace(ws)
    except BundledAgentNotPackagedError as e:
        logger.warning("Bundled-agent auto-install: %s", e)
        return
    cfg_id = cfg.id
    _check_still_safe(session, cfg_id, "", deadline)
    saved = session.execute(
        update(AgentConfig)
        .where(AgentConfig.id == cfg_id, AgentConfig.notebook_path == "")
        .values(
            notebook_path=result.path,
            installed_release_version=result.version,
            installed_agent_version=result.agent_version,
            installed_check_error=None,
            installed_checked_path=result.path,
            installed_checked_at=datetime.now(timezone.utc),
            updated_at=datetime.now(timezone.utc),
        )
    ).rowcount
    if saved != 1:
        session.rollback()
        raise AgentChangeAborted("a notebook was configured meanwhile; left as it is")
    session.commit()
    session.refresh(cfg)
    target = AgentConfig.model_validate(cfg.model_dump())
    # Close the read transaction so none idles across the Jobs call.
    session.rollback()

    try:
        job_id = setup_agent_job(ws, target)
    except Exception as e:  # noqa: BLE001 — best-effort
        logger.warning(
            "Bundled-agent auto-install: notebook uploaded to %s but job creation failed: %s",
            result.path,
            e,
        )
        return
    # A first install has no earlier job to point back at, so a late finish
    # leaves the new job unsaved; the Settings save wires it.
    _check_after_job_move(session, ws, cfg_id, deadline, converge=False)

    saved = session.execute(
        update(AgentConfig)
        .where(AgentConfig.id == cfg_id, AgentConfig.notebook_path == result.path)
        .values(job_id=job_id)
    ).rowcount
    if saved != 1:
        converge_agent_job_to_row(session, ws, cfg_id)
        raise AgentChangeAborted("the configured notebook changed meanwhile; left as it is")
    session.commit()
    logger.info(
        "Bundled-agent auto-install: %s notebook=%s job_id=%s",
        "overwrote" if result.overwritten else "installed",
        result.path,
        job_id,
    )


def _upgrade_app_owned(session: Session, ws, cfg, deadline: Optional[float]) -> None:
    """Upgrade the app's own notebook when the bundled agent is newer."""
    from ..bundled_agent import resolve_bundled_agent

    path = cfg.notebook_path
    cfg_id = cfg.id
    identity = installed_identity(
        session,
        ws,
        cfg,
        max_age=timedelta(0),
        store_if=lambda: not _deadline_passed(deadline)
        and _stored_notebook_path(session, cfg_id) == path,
    )
    if _deadline_passed(deadline):
        raise AgentChangeAborted("the boot time budget has passed; the next boot retries")
    if _stored_notebook_path(session, cfg_id) != path:
        raise AgentChangeAborted("the configured notebook changed meanwhile; left as it is")
    bundled = resolve_bundled_agent()
    if bundled is None:
        logger.warning("Bundled-agent upgrade skipped: no agent notebook is packaged with this build.")
        return
    if not is_app_owned(cfg.notebook_path, app_sp_home(ws)):
        logger.info(
            "Bundled-agent upgrade skipped: %s is outside the app's agent folder "
            "(admin-owned; Settings offers Switch to bundled).",
            cfg.notebook_path,
        )
        return

    verdict = compare_to_bundled(identity.release, identity.marker, bundled)
    if verdict in ("same", "newer"):
        logger.debug("Bundled-agent upgrade not needed: %s is %s", cfg.notebook_path, verdict)
        return

    in_flight = count_in_flight_runs(session)
    if in_flight:
        logger.warning(
            "Bundled-agent upgrade skipped: %d run(s) in flight; %s stays on agent %s. "
            "The next boot upgrades once no run is active.",
            in_flight,
            cfg.notebook_path,
            identity.marker or identity.release or "unknown",
        )
        return

    old_path, old_marker = cfg.notebook_path, identity.marker or identity.release or "unknown"
    result = point_agent_at_bundled(
        session, ws, cfg, expected_path=old_path, deadline=deadline
    )
    logger.info(
        "Bundled agent upgraded %s -> %s at %s (was %s); job_id=%s",
        old_marker,
        result.agent_version,
        result.path,
        old_path,
        cfg.job_id,
    )
