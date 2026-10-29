"""Version lifecycle: head, install state, promotion and delete of a version.

The one home for the state changes a version goes through after it exists:

- **Head.** At most one ``completed`` version per ``(business, scope)``
  (:func:`supersede_same_scope_priors`). That row is the scope head
  (``core._vibe_scope.scope_head``).
- **Install state.** The ``model_version_installs`` rows, one per catalog a
  version is installed in, and their mirror ``deployment_status`` /
  ``uc_catalog``. :func:`mark_version_deployed` and
  :func:`mark_version_uninstalled` open and close a catalog's row;
  :func:`evict_deployed_siblings` closes the rows of the versions an agent
  run displaced in its catalog, and :func:`restore_evicted_deployments`
  reopens them on rollback. They never touch ``files_catalog`` (where the
  agent wrote the version's files, set once at creation). No other module
  writes these columns (``tests/test_app/test_install_state_drift_lock.py``).
- **Promotion.** :func:`promote_installed_version` makes an installed version
  the head: a Dry Run draft always, an older or replaced version when it is
  installed where the head is installed (or the head is installed nowhere).
  The newer versions it drops (:func:`dropped_versions`) are stamped
  replaced. :func:`reopen_then_consume` moves the feedback in the same
  terminal transaction.
- **Delete.** :func:`delete_version` is the one delete path (the delete
  route and the post-install deletes of an install run): one version at a
  time, never an installed one; deleting the head makes its predecessor the
  head again, reopens the feedback the version applied, and records the
  ``_metamodel`` cleanup durably (``core/_metamodel_cleanups``).
  :func:`delete_business` applies the same lock, installed refusal and
  durable cleanup to every version of a business at once.

Why promotion follows the agent: the agent's "latest installed" is a max over
every registered ``installed`` version, and a replaced version can stay
registered as installed (an eviction, a release still pending), so the app
records which versions an install replaced rather than deriving it.
"""

from __future__ import annotations

import logging
from dataclasses import dataclass, field
from datetime import datetime, timezone
from typing import Any, Iterable, Optional

from sqlmodel import col, func, select

from ...core._json import json_object
from ...core._intents import AGENT_OP_ENLARGE_MVM, AGENT_OP_INSTALL, AGENT_OP_SHRINK_ECM, AGENT_OP_VIBE
from ...core._runs import BusinessBusy, lock_business_for_run
from ...core._vibe_scope import scope_head
from ...error_sanitization import offending_relation
from ...db_models import (
    ModelVersion,
    ModelVersionInstall,
    Run,
    RunInputLink,
    RunOperation,
    RunPostInstallDelete,
    VibeInput,
    VibeInputContextLink,
)
from ...core._uc_privileges import SINGLE_CATALOG_STYLE
from ...run_report import producing_run

logger = logging.getLogger(__name__)

_DEPLOYED = "deployed"
_UNINSTALLED = "uninstalled"
_DRAFT_STATUS = "draft"
# Statuses of a version that exists as a real model (not a draft, not a
# failed or generating row).
_MODEL_STATUSES = ("completed", "superseded")

# Keys of the install op's ``rollback_state`` that record a promotion, read by
# :func:`promotion_of_run` when the install run finishes.
PROMOTED_VERSION_KEY = "promoted_version_id"
REPLACED_VERSIONS_KEY = "replaced_version_ids"

_INSTALL_OP = "install"
_UNINSTALL_OP = "uninstall"

# Keys of a succeeded uninstall op's ``rollback_state``: the registry release
# went through (``uninstall.Uninstall._finish``, or a later
# ``uninstall.retry_registry_releases``), or it is still pending.
REGISTRY_RELEASED_KEY = "registry_released"
REGISTRY_RELEASE_PENDING_KEY = "registry_release_pending"


def _now() -> datetime:
    return datetime.now(timezone.utc)


def is_draft(mv: ModelVersion) -> bool:
    """A draft version (``status="draft"``), not made current yet: today
    only a Dry Run writes one, and legacy drafts the ``dry_run`` backfill
    missed count too. Installing one promotes it; nothing else marks it
    deployed."""
    return mv.status == _DRAFT_STATUS


# --- Head -----------------------------------------------------------------


def supersede_same_scope_priors(
    session: Any,
    business_id: str,
    scope: str,
    exclude_id: str,
) -> list[str]:
    """Flip every other ``completed`` ModelVersion of ``(business_id, scope)`` to ``superseded``.

    At most one ``completed`` ModelVersion exists per ``(business_id,
    scope)``: making a version ``completed`` retires every other one of the
    same scope. Different-scope rows are untouched (an ECM and an MVM coexist
    as the current pair).

    Returns the ids that were flipped, for rollback. Rows in another state
    (``superseded``, ``failed``, ``cancelled``, ``draft``) are left alone.

    Raises ``ValueError`` if ``scope`` is empty: legacy unscoped rows are not
    swept, because their scope is unknown.
    """
    if not scope or not scope.strip():
        raise ValueError(
            "supersede_same_scope_priors: scope must be a non-empty string; "
            "refusing to sweep legacy unscoped ModelVersion rows"
        )
    rows = session.exec(
        select(ModelVersion).where(
            ModelVersion.business_id == business_id,
            ModelVersion.scope == scope,
            ModelVersion.id != exclude_id,
            ModelVersion.status == "completed",
        )
    ).all()
    flipped: list[str] = []
    for row in rows:
        row.status = "superseded"
        session.add(row)
        flipped.append(row.id)
    return flipped


def restore_superseded_priors(session: Any, auto_superseded_ids: list[str]) -> None:
    """Reverse :func:`supersede_same_scope_priors` for rollback.

    Each listed row still ``superseded`` goes back to ``completed``. Rows
    deleted or moved to another status since are left alone.
    """
    for vid in auto_superseded_ids or []:
        if not vid:
            continue
        row = session.get(ModelVersion, vid)
        if row is not None and row.status == "superseded":
            row.status = "completed"
            session.add(row)


# --- Install state --------------------------------------------------------
#
# Where a version is installed is its open ``model_version_installs`` rows
# (one per catalog, ``uninstalled_at`` NULL). ``deployment_status`` and
# ``uc_catalog`` mirror them: ``deployed`` with ``uc_catalog`` = the catalog of
# the latest open row, else ``uninstalled`` with ``uc_catalog`` kept as the last
# install location. Only the helpers below write any of the three.


def _open_rows(session: Any, version_id: str, catalog: Optional[str] = None) -> list[ModelVersionInstall]:
    stmt = select(ModelVersionInstall).where(
        ModelVersionInstall.version_id == version_id,
        col(ModelVersionInstall.uninstalled_at).is_(None),
    )
    if catalog is not None:
        stmt = stmt.where(ModelVersionInstall.catalog == catalog)
    return list(session.exec(stmt.order_by(col(ModelVersionInstall.installed_at).desc())).all())


def _adopt_legacy_install(session: Any, mv: ModelVersion) -> None:
    """A version recorded ``deployed`` in ``uc_catalog`` with no open row (a
    row written before install rows existed) gets its row, as the
    ``v_0_9_0_1`` backfill would have written it."""
    catalog = (mv.uc_catalog or "").strip()
    if mv.deployment_status != _DEPLOYED or not catalog or mv.id is None:
        return
    if _open_rows(session, mv.id):
        return
    session.add(ModelVersionInstall(
        version_id=mv.id, catalog=catalog,
        installed_at=mv.promoted_at or mv.completion_date or mv.created_at or _now(),
    ))
    session.flush()


def _mirror_open_rows(session: Any, mv: ModelVersion) -> None:
    """Set ``deployment_status`` / ``uc_catalog`` from ``mv``'s open rows."""
    rows = _open_rows(session, mv.id)
    if rows:
        mv.deployment_status = _DEPLOYED
        mv.uc_catalog = rows[0].catalog
    elif mv.deployment_status == _DEPLOYED:
        mv.deployment_status = _UNINSTALLED
    session.add(mv)


def installed_catalogs(session: Any, mv: ModelVersion) -> list[str]:
    """The catalogs ``mv`` is installed in now, latest install first: its
    open install rows, or ``uc_catalog`` for a ``deployed`` version without
    rows."""
    catalogs = [r.catalog for r in _open_rows(session, mv.id)] if mv.id else []
    own = (mv.uc_catalog or "").strip()
    if not catalogs and mv.deployment_status == _DEPLOYED and own:
        catalogs = [own]
    return catalogs


def _installed_in(catalog: str, *, fold_case: bool = False):
    """Versions installed in ``catalog`` now: an open install row there, or
    ``deployed`` with that ``uc_catalog`` (a row written before install rows
    existed). Catalogs compare exactly unless ``fold_case`` (initial sync,
    import and legacy rows can store a mixed-case catalog)."""
    def _same(column):
        return func.lower(column) == catalog.lower() if fold_case else column == catalog

    open_here = select(ModelVersionInstall.version_id).where(
        _same(ModelVersionInstall.catalog),
        col(ModelVersionInstall.uninstalled_at).is_(None),
    )
    return col(ModelVersion.id).in_(open_here) | (
        (ModelVersion.deployment_status == _DEPLOYED) & _same(ModelVersion.uc_catalog)
    )


def versions_installed_in(session: Any, catalog: str) -> list[ModelVersion]:
    """Every version, of any business, installed in ``catalog`` now, the
    catalog compared in any case (:func:`_installed_in`), by business, scope
    and version."""
    if not catalog:
        return []
    return list(session.exec(
        select(ModelVersion)
        .where(_installed_in(catalog, fold_case=True))
        .order_by(ModelVersion.business_id, ModelVersion.scope, ModelVersion.version)
    ).all())


def mark_version_deployed(
    session: Any, mv: ModelVersion, catalog: str, *, run_id: Optional[str] = None,
) -> None:
    """Record ``mv`` as installed in ``catalog`` by ``run_id``.

    Opens the ``(mv, catalog)`` install row (an install into a catalog it is
    already installed in refreshes that row), then ``deployment_status``
    becomes ``deployed`` and ``uc_catalog`` the catalog. Other open rows
    stand: a version can be installed in several catalogs. ``files_catalog``
    is never changed. An empty ``catalog`` writes no row and logs a warning,
    because the installation-status probe cannot check it.
    """
    session.add(mv)
    if not catalog:
        logger.warning(
            "mark_version_deployed: version_id=%s marked deployed with an empty "
            "catalog; the installation-status probe cannot check it",
            mv.id,
        )
        mv.deployment_status = _DEPLOYED
        return
    # The version row first: its install row references it.
    session.flush()
    _adopt_legacy_install(session, mv)
    now = _now()
    existing = _open_rows(session, mv.id, catalog)
    if existing:
        existing[0].installed_at = now
        existing[0].installed_by_run_id = run_id or existing[0].installed_by_run_id
        session.add(existing[0])
    else:
        session.add(ModelVersionInstall(
            version_id=mv.id, catalog=catalog, installed_by_run_id=run_id, installed_at=now,
        ))
    session.flush()
    _mirror_open_rows(session, mv)


def mark_version_uninstalled(
    session: Any, mv: ModelVersion, catalog: Optional[str] = None, *, run_id: Optional[str] = None,
) -> None:
    """Record ``mv`` as no longer installed in ``catalog`` (default: its
    ``uc_catalog``) by ``run_id``.

    Closes that catalog's open row. ``mv`` stays ``deployed`` while another
    row is open, with ``uc_catalog`` that row's catalog; otherwise it is
    ``uninstalled`` and ``uc_catalog`` keeps the last install location (the
    delete cleanup and the drift probe read it).
    """
    target = (catalog or mv.uc_catalog or "").strip()
    session.add(mv)
    if not target:
        if mv.deployment_status != _UNINSTALLED:
            mv.deployment_status = _UNINSTALLED
        return
    _adopt_legacy_install(session, mv)
    now = _now()
    closed = _open_rows(session, mv.id, target)
    for row in closed:
        row.uninstalled_at = now
        row.uninstalled_by_run_id = run_id
        session.add(row)
    session.flush()
    remaining = _open_rows(session, mv.id)
    if remaining:
        mv.deployment_status = _DEPLOYED
        mv.uc_catalog = remaining[0].catalog
    else:
        mv.deployment_status = _UNINSTALLED
        if closed:
            mv.uc_catalog = target


def evict_deployed_siblings(
    session: Any, mv: ModelVersion, *, same_scope: bool, run_id: Optional[str] = None,
    catalog: Optional[str] = None,
) -> list[str]:
    """Record the other versions of ``mv``'s business installed in its
    install catalog (``uc_catalog``, or ``catalog`` when given: a version the
    agent installed in several catalogs evicts in each) as no longer
    installed there; return their ids.

    ``same_scope`` follows what the agent run did to the catalog
    (:func:`deploy_evicts_every_scope`). In One Catalog an install and a new
    base model leave the other scope's schemas in place (different schema
    prefixes), so only the same scope is evicted; a shrink, an enlarge and an
    unscoped Full Run vibe that rebuilds drop every schema of the business in
    the catalog first, so every scope is evicted. In Catalog per Division /
    Domain every deploying run overwrites the other scope's same-named
    tables, so every scope is evicted. Import and initial sync keep
    ``same_scope=False``. Each evicted version's install row in the catalog
    closes; one still installed elsewhere stays deployed there. Versions
    with an empty ``uc_catalog`` count as one catalog.
    """
    catalog = (catalog if catalog is not None else mv.uc_catalog or "").strip()
    stmt = select(ModelVersion).where(
        ModelVersion.business_id == mv.business_id,
        ModelVersion.id != mv.id,
    )
    if catalog:
        stmt = stmt.where(_installed_in(catalog))
    else:
        stmt = stmt.where(ModelVersion.deployment_status == _DEPLOYED, ModelVersion.uc_catalog == "")
    if same_scope:
        stmt = stmt.where(ModelVersion.scope == mv.scope)
    siblings = session.exec(stmt).all()
    for sib in siblings:
        mark_version_uninstalled(session, sib, catalog or None, run_id=run_id)
    if siblings:
        logger.info(
            "Evicted %d installed version(s) of business=%s from catalog=%r",
            len(siblings), mv.business_id, catalog,
        )
    return [s.id for s in siblings]


def restore_evicted_deployments(
    session: Any, version_ids: Iterable[str], *, catalog: Optional[str] = None,
) -> None:
    """Reverse :func:`evict_deployed_siblings` for rollback: each listed row
    that still exists is installed in ``catalog`` again (default: its
    ``uc_catalog``). The install row the eviction closed is reopened when
    there is one."""
    for vid in version_ids or []:
        row = session.get(ModelVersion, vid) if vid else None
        if row is None:
            continue
        target = (catalog or row.uc_catalog or "").strip()
        if not target:
            row.deployment_status = _DEPLOYED
            session.add(row)
            continue
        if not _open_rows(session, row.id, target):
            closed = session.exec(
                select(ModelVersionInstall)
                .where(ModelVersionInstall.version_id == row.id, ModelVersionInstall.catalog == target)
                .order_by(col(ModelVersionInstall.uninstalled_at).desc())
            ).first()
            if closed is not None:
                closed.uninstalled_at = None
                closed.uninstalled_by_run_id = None
                session.add(closed)
            else:
                session.add(ModelVersionInstall(version_id=row.id, catalog=target, installed_at=_now()))
            session.flush()
        _mirror_open_rows(session, row)


def _is_installed_base(session: Any, occupant: ModelVersion, mv: ModelVersion, catalog: str) -> bool:
    """Would the agent install ``mv`` over ``occupant`` as its base?

    The agent keeps the installed tables only on its ``base_match`` path: the
    file has a ``_vibe_scope`` block whose base is the catalog's latest
    installed version, a max over every registered ``installed`` row
    (``_latest_installed_version``). So ``occupant`` counts as the base only
    when

    * ``mv`` carries the block's facts (``scope_fence_mode`` set) and they
      name ``occupant``: by ``base_version_id`` when the lineage pointer is
      set (and the facts' base number, when recorded, agrees), else by the
      facts' base number and scope; and
    * no newer non-draft version of the scope, ``mv`` included, still
      counts as installed in ``catalog`` for the agent
      (:func:`_newer_recorded`), since the agent would see that one as the
      latest installed.

    A version without the facts takes the agent's ordinary install, which
    for a version above 1 replaces every table (``CREATE OR REPLACE TABLE``),
    so the rows are lost either way: the app keeps the base as an occupant
    and routes the install through uninstall-then-install under the
    confirmation.
    """
    if mv.scope_fence_mode is None:
        return False
    if mv.base_version_id:
        if occupant.id != mv.base_version_id:
            return False
        if mv.scope_base_version is not None and int(mv.scope_base_version) != int(occupant.version):
            return False
    elif not (
        mv.scope_base_version is not None
        and int(occupant.version) == int(mv.scope_base_version)
        and (mv.scope_base_scope or mv.scope) == occupant.scope
    ):
        return False
    return not _newer_recorded(session, occupant, catalog, exclude_ids=(occupant.id,))


def _ever_installed_in(catalog: str, *, fold_case: bool = False):
    """Versions installed in ``catalog`` now or before: any install row
    there, closed ones included, or ``uc_catalog`` naming it (deployed there,
    or its last install location). Catalogs compare exactly unless
    ``fold_case``."""
    def _same(column):
        return func.lower(column) == catalog.lower() if fold_case else column == catalog

    ever_installed = select(ModelVersionInstall.version_id).where(_same(ModelVersionInstall.catalog))
    return _same(ModelVersion.uc_catalog) | col(ModelVersion.id).in_(ever_installed)


def _recorded_in(catalog: str, *, fold_case: bool = False):
    """Versions with rows in the agent's registry in ``catalog``: installed
    there now or before (:func:`_ever_installed_in`; the agent's uninstall
    writes nothing to its registry, and the app's release only sets the rows
    ``dry_run``), or with their files there. Catalogs compare exactly unless
    ``fold_case`` (a request may name the catalog in another case; Unity
    Catalog folds catalog names). Whether the agent still counts such a
    version is :func:`agent_counts_in`."""
    return _ever_installed_in(catalog, fold_case=fold_case) | _files_in(catalog, fold_case=fold_case)


def _files_in(catalog: str, *, fold_case: bool = False):
    return (
        func.lower(ModelVersion.files_catalog) == catalog.lower() if fold_case
        else ModelVersion.files_catalog == catalog
    )


def _agent_recorded_in(catalog: str, *, fold_case: bool = False):
    """Versions with rows in the agent's registry in ``catalog`` that the
    agent wrote itself: installed there now or before, or with their files
    there from an agent run. A version the app imported, downloaded or
    kickstarted (its import markers set, ``version_files.is_app_copy``) has
    files there only from the app's seed, whose rows are ``dry_run``
    (``import_metamodel_writer``), which the agent skips; it is recorded
    there for the agent only once it is installed there."""
    agent_files = _files_in(catalog, fold_case=fold_case) & col(ModelVersion.import_schema_prefix_added).is_(None)
    return _ever_installed_in(catalog, fold_case=fold_case) | agent_files


def released_from(session: Any, version_ids: Iterable[str], catalog: str, *, fold_case: bool = False) -> set[str]:
    """The versions among ``version_ids`` whose rows in the agent's registry
    in ``catalog`` are released: set ``dry_run`` by the app after an
    uninstall from there, so the agent no longer counts them as installed
    (``_latest_installed_version``) or as completed
    (``_get_latest_completed_version`` with ``_RUN_LINEAGE_NOT_DRY_RUN_SQL``).

    A version is released when it has an install row in ``catalog``, none is
    open, and the newest one was closed by a succeeded uninstall step of
    that version and catalog whose release went through
    (:data:`REGISTRY_RELEASED_KEY`). The release covers every registry row of
    the version there, so older rows do not matter. Not released: an
    eviction (the agent replaced its tables, its rows stay ``installed``), a
    release still pending, an uninstall recorded before the release existed,
    and a version with no install row there. Whether a version that is not
    released counts for the agent is :func:`agent_counts_in`."""
    ids = list(dict.fromkeys(v for v in version_ids if v))
    if not ids or not catalog:
        return set()
    same = (
        func.lower(ModelVersionInstall.catalog) == catalog.lower() if fold_case
        else ModelVersionInstall.catalog == catalog
    )
    newest: dict[str, ModelVersionInstall] = {}
    for row in session.exec(
        select(ModelVersionInstall)
        .where(col(ModelVersionInstall.version_id).in_(ids), same)
        .order_by(col(ModelVersionInstall.installed_at))
    ).all():
        if newest.get(row.version_id) is not None and newest[row.version_id].uninstalled_at is None:
            continue
        newest[row.version_id] = row
    closing = {
        row.uninstalled_by_run_id for row in newest.values()
        if row.uninstalled_at is not None and row.uninstalled_by_run_id
    }
    if not closing:
        return set()
    released: set[tuple[str, str, str]] = set()
    for op in session.exec(
        select(RunOperation).where(
            col(RunOperation.run_id).in_(list(closing)),
            RunOperation.operation_name == _UNINSTALL_OP,
            RunOperation.status == "succeeded",
        )
    ).all():
        state = json_object(op.rollback_state_json)
        if not state.get(REGISTRY_RELEASED_KEY) or REGISTRY_RELEASE_PENDING_KEY in state:
            continue
        params = json_object(op.params_json)
        released.add((
            op.run_id,
            str(params.get("version_id") or ""),
            str(params.get("deployment_catalog") or "").lower(),
        ))
    return {
        vid for vid, row in newest.items()
        if row.uninstalled_at is not None
        and (row.uninstalled_by_run_id, vid, row.catalog.lower()) in released
    }


def agent_counts_in(session: Any, version_ids: Iterable[str], catalog: str, *, fold_case: bool = False) -> set[str]:
    """The versions among ``version_ids`` the agent's registry in ``catalog``
    still counts (as installed, and in its newest completed version): rows
    the agent wrote there (:func:`_agent_recorded_in`: an app seed alone does
    not count; an agent Dry Run draft, registered with ``deploy_status``
    NULL, does) and not released (:func:`released_from`)."""
    ids = list(dict.fromkeys(v for v in version_ids if v))
    if not ids or not catalog:
        return set()
    recorded = set(session.exec(
        select(ModelVersion.id).where(col(ModelVersion.id).in_(ids), _agent_recorded_in(catalog, fold_case=fold_case))
    ).all())
    return recorded - released_from(session, recorded, catalog, fold_case=fold_case)


def _newer_recorded(session: Any, base: ModelVersion, catalog: str, *, exclude_ids: Iterable[str]) -> bool:
    """Does a non-draft version of ``base``'s scope newer than ``base`` still
    count as installed in ``catalog`` for the agent (:func:`agent_counts_in`)?
    An evicted or replaced version that was never released stays
    ``installed`` in the agent's registry. The catalog compares in any case
    (Unity Catalog folds catalog names; legacy rows can store mixed case)."""
    newer = session.exec(
        select(ModelVersion.id).where(
            ModelVersion.business_id == base.business_id,
            ModelVersion.scope == base.scope,
            col(ModelVersion.id).not_in(list(exclude_ids)),
            col(ModelVersion.status).in_(_MODEL_STATUSES),
            col(ModelVersion.version) > int(base.version),
        )
    ).all()
    return bool(agent_counts_in(session, newer, catalog, fold_case=True))


def base_is_latest_installed(session: Any, base: ModelVersion, catalog: str, *, new_version_id: str) -> bool:
    """The app's view of the agent's ``_vov_keeps_installed_tables`` test
    (``installed == base``): the agent's registry in ``catalog`` still counts
    the vibe's base (:func:`agent_counts_in`) and no newer version of its
    scope (:func:`_newer_recorded`), the catalog compared in any case.
    ``new_version_id`` (the run's own output, already flushed) is not
    counted."""
    return bool(agent_counts_in(session, (base.id,), catalog, fold_case=True)) and not _newer_recorded(
        session, base, catalog, exclude_ids=(base.id, new_version_id),
    )


# Agent operations whose setup runs ``_staging_catalog_teardown`` on the
# target catalog (``_early_clash_detection``, nb 8538-8546).
_TEARDOWN_OPS = (AGENT_OP_SHRINK_ECM, AGENT_OP_ENLARGE_MVM, AGENT_OP_VIBE)
_INSTALL_AGENT_OP = AGENT_OP_INSTALL


def deploy_evicts_every_scope(
    operation: str,
    *,
    cataloging_style: str,
    scoped: bool = False,
    keeps_installed: bool = False,
) -> bool:
    """Does a deploying agent run (not a Dry Run) leave the business's other
    scope uninstalled in its target catalog (agent 5.3.3)?

    One Catalog: ``_staging_catalog_teardown`` (nb 8462-8536) drops each
    schema in the target catalog owned by the business through any
    non-Dry-Run registry row, whatever its scope (nb 8327-8386 builds that
    ownership), unless the run is scoped (nb 8493-8497) or a vibe whose base
    is the latest installed version there (``_vov_keeps_installed_tables``,
    nb 8505-8507). It runs for shrink, enlarge and vibe only. A new base
    model takes the clash check instead (nb 8547-8676 has no DROP), and
    ``install model`` deploys through ``_run_deploy_model`` (nb
    110014-110026), which replaces its own scope's tables; the other scope's
    schemas, under a different prefix, are untouched.

    Catalog per Division / Domain: both scopes resolve to the same catalogs
    and schema names (no schema prefix), so every deploying run writes
    ``CREATE OR REPLACE TABLE`` (nb 84984, 107368) over the other scope's
    tables in place: shrink, enlarge, vibe, and ``install model`` too, whose
    path (nb 110014-110026 to ``_run_deploy_model``) soft-replaces present
    schemas (nb 7955-7964, 8060-8091) and does not take the clash check.
    That scope is no longer faithfully installed, and uninstalling it would
    drop the shared schemas, so every scope is evicted.

    "Scoped" is the Some domains fence, set at setup (nb 56975) before the
    teardown runs (nb 57169); an unscoped vibe's requested-entities fence is
    set later, inside the VOV engine (nb 22087, 22394), so it does not stop
    the teardown.
    """
    if (cataloging_style or SINGLE_CATALOG_STYLE) != SINGLE_CATALOG_STYLE:
        return True
    if operation not in _TEARDOWN_OPS:
        return False
    return not (scoped or keeps_installed)


def catalog_occupant(session: Any, mv: ModelVersion, catalog: str) -> Optional[ModelVersion]:
    """The other version of ``mv``'s business and scope recorded as deployed
    in ``catalog``, or None. Installing ``mv`` there replaces it.

    ``mv``'s installed base is not an occupant when the agent will take its
    ``base_match`` path (:func:`_is_installed_base`): that is a plain install
    keeping the out-of-scope tables, and :func:`record_install` evicts the
    base. Any other occupant is uninstalled first.
    """
    if not catalog:
        return None
    occupant = session.exec(
        select(ModelVersion)
        .where(
            ModelVersion.business_id == mv.business_id,
            ModelVersion.scope == mv.scope,
            ModelVersion.id != mv.id,
            _installed_in(catalog),
        )
        .order_by(col(ModelVersion.version).desc())
    ).first()
    if occupant is None or _is_installed_base(session, occupant, mv, catalog):
        return None
    return occupant


# --- Promotion ------------------------------------------------------------


def _drop_threshold(session: Any, mv: ModelVersion) -> int:
    """Versions above this number are dropped when ``mv`` is promoted: its own
    number, or its base's for a draft (a draft builds on its base)."""
    if is_draft(mv) and mv.base_version_id:
        base = session.get(ModelVersion, mv.base_version_id)
        if base is not None and base.scope == mv.scope:
            return int(base.version)
    return int(mv.version)


def dropped_versions(session: Any, mv: ModelVersion) -> list[ModelVersion]:
    """The set D promoting ``mv`` drops: every non-draft version of its scope
    newer than ``mv`` (or than its base, for a draft) not already replaced,
    newest first."""
    return list(session.exec(
        select(ModelVersion)
        .where(
            ModelVersion.business_id == mv.business_id,
            ModelVersion.scope == mv.scope,
            ModelVersion.id != mv.id,
            col(ModelVersion.status).in_(_MODEL_STATUSES),
            col(ModelVersion.version) > _drop_threshold(session, mv),
            col(ModelVersion.replaced_at).is_(None),
        )
        .order_by(col(ModelVersion.version).desc())
    ).all())


def will_promote(session: Any, mv: ModelVersion, catalog: str) -> bool:
    """Does installing ``mv`` into ``catalog`` make it the scope head?

    A Dry Run draft: always. The head itself: no (re-installing it changes
    nothing). An older or replaced version: only into a catalog the head is
    installed in, or when the head is installed nowhere. Installing it
    anywhere else is a plain install that leaves the head alone.
    """
    if is_draft(mv):
        return True
    if mv.status not in _MODEL_STATUSES:
        return False
    head = scope_head(session, mv.business_id, mv.scope)
    if head is None:
        return True
    if head.id == mv.id:
        return False
    head_catalogs = installed_catalogs(session, head)
    if not head_catalogs:
        return True
    return (catalog or "") in head_catalogs


@dataclass
class InstallOutcome:
    """What an install did to the version state."""

    promoted: bool
    replaced_ids: list[str] = field(default_factory=list)


def record_install(
    session: Any,
    mv: ModelVersion,
    *,
    run_id: Optional[str],
    catalog: str,
    cataloging_style: str = SINGLE_CATALOG_STYLE,
) -> InstallOutcome:
    """Apply a successful install of ``mv`` into ``catalog``.

    Always: :func:`mark_version_deployed` and the same-scope eviction in that
    catalog. When :func:`will_promote` (decided before anything changes),
    also :func:`promote_installed_version`.
    """
    promote = will_promote(session, mv, catalog)
    replaced = dropped_versions(session, mv) if promote else []
    mark_version_deployed(session, mv, catalog, run_id=run_id)
    evict_deployed_siblings(
        session, mv,
        same_scope=not deploy_evicts_every_scope(_INSTALL_AGENT_OP, cataloging_style=cataloging_style),
        run_id=run_id,
    )
    if promote:
        promote_installed_version(session, mv, run_id=run_id, replaced=replaced)
    return InstallOutcome(promoted=promote, replaced_ids=[r.id for r in replaced])


def promote_installed_version(
    session: Any, mv: ModelVersion, *, run_id: Optional[str], replaced: list[ModelVersion]
) -> None:
    """Make the installed ``mv`` the head of its scope.

    ``mv`` becomes ``completed`` with ``promoted_at`` / ``promoted_by_run_id``
    and loses any replaced mark; every other completed version of the scope
    is superseded; each version in ``replaced`` (the set D, from
    :func:`dropped_versions` read before the install changed anything) is
    stamped replaced by ``mv``.
    """
    now = _now()
    mv.status = "completed"
    mv.promoted_at = now
    mv.promoted_by_run_id = run_id
    mv.replaced_at = None
    mv.replaced_by_version_id = None
    session.add(mv)
    supersede_same_scope_priors(session, mv.business_id, mv.scope, mv.id)
    for row in replaced:
        row.replaced_by_version_id = mv.id
        row.replaced_at = now
        session.add(row)


@dataclass(frozen=True)
class Promotion:
    """A promotion an install run made: the version and the set it replaced."""

    version_id: str
    replaced_ids: tuple[str, ...]


def promotion_of_run(session: Any, run_id: str) -> Optional[Promotion]:
    """The promotion recorded on ``run_id``'s succeeded install op, if any."""
    ops = session.exec(
        select(RunOperation)
        .where(RunOperation.run_id == run_id)
        .where(RunOperation.operation_name == _INSTALL_OP)
        .where(RunOperation.status == "succeeded")
        .order_by(col(RunOperation.step_index).desc())
    ).all()
    for op in ops:
        state = json_object(op.rollback_state_json)
        if state.get(PROMOTED_VERSION_KEY):
            return Promotion(
                version_id=str(state[PROMOTED_VERSION_KEY]),
                replaced_ids=tuple(str(v) for v in state.get(REPLACED_VERSIONS_KEY) or ()),
            )
    return None


# --- Feedback on promotion ------------------------------------------------


def _producing_run_id(session: Any, version_id: str) -> Optional[str]:
    run = producing_run(session, version_id)
    return run.id if run is not None else None


def _in_scope(session: Any, inputs: Iterable[VibeInput], scope: str) -> list[VibeInput]:
    """The ``inputs`` that belong to ``scope``: anchored to a version of that
    scope, or anchored nowhere. A unified run consumes its inputs once for
    both outputs, and they are anchored to its base's scope, so replacing
    the run's other-scope output must not move them."""
    inputs = list(inputs)
    if not inputs:
        return []
    anchored: dict[str, set[str]] = {}
    for input_id, version_scope in session.exec(
        select(VibeInputContextLink.input_id, ModelVersion.scope)
        .join(ModelVersion, ModelVersion.id == VibeInputContextLink.version_id)
        .where(col(VibeInputContextLink.input_id).in_([vi.id for vi in inputs]))
    ).all():
        anchored.setdefault(input_id, set()).add(version_scope)
    return [vi for vi in inputs if vi.id not in anchored or scope in anchored[vi.id]]


def inputs_to_reopen(session: Any, versions: Iterable[ModelVersion]) -> list[VibeInput]:
    """The feedback ``versions`` applied: inputs of their scope consumed by
    one of their producing or promoting runs. Versions from before 0.9.0
    have no ``consumed_by_run_id`` and give none."""
    found: dict[str, VibeInput] = {}
    for mv in versions:
        run_ids = {r for r in (_producing_run_id(session, mv.id), mv.promoted_by_run_id) if r}
        if not run_ids:
            continue
        consumed = session.exec(
            select(VibeInput)
            .where(col(VibeInput.consumed).is_(True))
            .where(col(VibeInput.consumed_by_run_id).in_(sorted(run_ids)))
        ).all()
        for vi in _in_scope(session, consumed, mv.scope):
            found[vi.id] = vi
    return sorted(found.values(), key=lambda vi: (vi.created_at, vi.id))


def reopen_inputs(session: Any, inputs: Iterable[VibeInput]) -> list[VibeInput]:
    """Open each input again: not consumed, no consuming run. Whether it is
    selected for the next run is left as it is (a consumed input was
    deselected when it was consumed)."""
    now = _now()
    reopened = list(inputs)
    for vi in reopened:
        vi.consumed = False
        vi.consumed_by_run_id = None
        vi.updated_at = now
        session.add(vi)
    return reopened


def _upsert_link(session: Any, run_id: str, input_id: str, status: str, reason: str) -> None:
    link = session.get(RunInputLink, (run_id, input_id))
    if link is None:
        link = RunInputLink(run_id=run_id, input_id=input_id)
    link.outcome_status = status
    link.outcome_reason = reason
    session.add(link)


def reopen_then_consume(session: Any, run_id: str, promotion: Promotion) -> None:
    """Move the feedback of a promotion made by install run ``run_id``.

    1. Reopen what every replaced version applied: open, not consumed, and
       not selected again (``selected_for_run`` is left as it is).
    2. Consume what the promoted version applied: the open, active inputs of
       its scope its producing run reported ``applied``, consumed by
       ``run_id``. An item applied in both ends consumed.
    3. Both sets become ``run_input_links`` of the install run, ``reopened``
       or ``applied``, with the reason.

    Flushes; the caller commits with the run's terminal transition.
    """
    from ...run_report import OUTCOME_APPLIED, OUTCOME_REOPENED

    now = _now()
    replaced = [
        mv for mv in (session.get(ModelVersion, vid) for vid in promotion.replaced_ids) if mv is not None
    ]
    for vi in reopen_inputs(session, inputs_to_reopen(session, replaced)):
        _upsert_link(session, run_id, vi.id, OUTCOME_REOPENED, "applied in a version this install replaced")
    session.flush()

    promoted = session.get(ModelVersion, promotion.version_id)
    producing = _producing_run_id(session, promotion.version_id)
    if producing and promoted is not None:
        applied_ids = session.exec(
            select(RunInputLink.input_id)
            .where(RunInputLink.run_id == producing)
            .where(RunInputLink.outcome_status == OUTCOME_APPLIED)
        ).all()
        inputs = session.exec(
            select(VibeInput)
            .where(col(VibeInput.id).in_(list(applied_ids)))
            .where(col(VibeInput.consumed).is_(False))
            .where(VibeInput.status == "active")
        ).all() if applied_ids else []
        for vi in _in_scope(session, inputs, promoted.scope):
            vi.consumed = True
            vi.consumed_by_run_id = run_id
            vi.selected_for_run = False
            vi.updated_at = now
            session.add(vi)
            _upsert_link(session, run_id, vi.id, OUTCOME_APPLIED, "applied in the version this install made current")
    session.flush()


# --- Post-install deletes -------------------------------------------------


def run_requests_post_install_delete(run: Optional[Run]) -> bool:
    """Did the install run ask to delete the versions it replaces
    (``also_delete_replaced`` in its parameters)?"""
    return run is not None and json_object(run.parameters_json).get("also_delete_replaced") is True


def queue_post_install_deletes(session: Any, run_id: str, promotion: Promotion) -> None:
    """Write a ``pending`` ``run_post_install_deletes`` row per replaced
    version when the install run asked for ``also_delete_replaced``. Runs in
    the install's terminal transaction; :func:`run_post_install_deletes`
    performs them after the commit."""
    if not run_requests_post_install_delete(session.get(Run, run_id)):
        return
    for vid in promotion.replaced_ids:
        mv = session.get(ModelVersion, vid)
        if mv is None or session.get(RunPostInstallDelete, (run_id, vid)) is not None:
            continue
        session.add(RunPostInstallDelete(
            run_id=run_id, version_id=vid, version=int(mv.version), scope=mv.scope or "",
        ))
    session.flush()


def _not_run_reason(session: Any, mv: Optional[ModelVersion]) -> Optional[str]:
    """Why a pending post-install delete no longer applies, or None."""
    if mv is None:
        return "the version is already gone"
    if mv.replaced_at is None:
        return "the version is no longer replaced"
    catalogs = installed_catalogs(session, mv)
    if catalogs or mv.deployment_status == _DEPLOYED:
        return f"v{mv.version} is installed in {', '.join(catalogs) or 'a catalog'}; uninstall it first"
    return None


def _finish_delete_row(session: Any, row: RunPostInstallDelete, status: str, reason: str) -> None:
    row.status = status
    row.reason = reason[:500]
    row.completed_at = _now()
    session.add(row)
    session.commit()


def run_post_install_deletes(
    session: Any,
    ws: Any,
    warehouse_id: str,
    *,
    run_id: Optional[str] = None,
    recheck: bool = False,
    discard_change_feedback: bool = False,
) -> None:
    """Perform pending post-install deletes, each through :func:`delete_version`.

    ``run_id`` limits it to one install run (the tracker's post-commit hook);
    without it every pending row is handled (the boot sweep). ``recheck``
    (the sweep) marks a row ``not_run`` when the version changed since the
    install (installed again, no longer replaced, already gone). A delete
    refused because another run or request holds the business stays
    ``pending`` with the reason, for the next sweep. Any other failed delete
    is ``failed`` with the reason; nothing here changes the install's result.
    """
    from ...core._metamodel_cleanups import REASON_POST_INSTALL_DELETE

    stmt = select(RunPostInstallDelete).where(RunPostInstallDelete.status == "pending")
    if run_id is not None:
        stmt = stmt.where(RunPostInstallDelete.run_id == run_id)
    rows = session.exec(stmt.order_by(col(RunPostInstallDelete.version).desc())).all()
    for row in rows:
        mv = session.get(ModelVersion, row.version_id)
        reason = _not_run_reason(session, mv)
        if reason is not None:
            _finish_delete_row(session, row, "not_run" if recheck or mv is None else "failed", reason)
            continue
        try:
            delete_version(
                session, ws, warehouse_id, mv,
                finishing_run_id=row.run_id, reason=REASON_POST_INSTALL_DELETE,
                discard_change_feedback=discard_change_feedback,
            )
        except VersionDeleteRefused as refused:
            session.rollback()
            if isinstance(refused, ActiveRunRefused):
                # Another run or request holds the business: try again later
                # (the next boot sweep), and say why it is still pending.
                row.reason = refused.message[:500]
                session.add(row)
                session.commit()
                continue
            _finish_delete_row(session, row, "failed", refused.message)
            continue
        except Exception as exc:  # noqa: BLE001 - recorded on the row
            from ...error_sanitization import sanitize_error_message

            session.rollback()
            logger.exception("post-install delete of %s failed (run %s)", row.version_id, row.run_id)
            _finish_delete_row(session, row, "failed", sanitize_error_message(str(exc)))
            continue
        _finish_delete_row(session, row, "deleted", "")


# --- Delete ---------------------------------------------------------------


class VersionDeleteRefused(Exception):
    """A delete the rules refuse; nothing was changed. ``detail`` is the
    HTTP detail (a string, or the ``installed`` shape)."""

    def __init__(self, status_code: int, message: str, *, detail: Any = None) -> None:
        super().__init__(message)
        self.status_code = status_code
        self.message = message
        self.detail = detail if detail is not None else message


class ActiveRunRefused(VersionDeleteRefused):
    """The delete waits: another run is active on the business, or another
    request holds its lock."""

    def __init__(self, message: str) -> None:
        super().__init__(409, message)


@dataclass(frozen=True)
class DeleteOutcome:
    deleted_version: int
    # The scope head after deleting the head (its restored predecessor).
    previous_version: Optional[int]
    metamodel_rows_cleaned: bool
    cleanup_done: int = 0
    cleanup_pending: int = 0
    cleanup_failed: int = 0
    reopened_input_count: int = 0


def _scope_label(mv: ModelVersion) -> str:
    return f"v{mv.version} {(mv.scope or '').upper()}".rstrip()


def _newer_live_versions(session: Any, mv: ModelVersion) -> list[ModelVersion]:
    """Versions of ``mv``'s scope above it that are real models (completed or
    superseded) and not replaced: a version below one of them is in the
    middle of the scope."""
    return list(session.exec(
        select(ModelVersion)
        .where(
            ModelVersion.business_id == mv.business_id,
            ModelVersion.scope == mv.scope,
            ModelVersion.id != mv.id,
            col(ModelVersion.status).in_(_MODEL_STATUSES),
            col(ModelVersion.replaced_at).is_(None),
            col(ModelVersion.version) > int(mv.version),
        )
        .order_by(col(ModelVersion.version))
    ).all())


def _head_after_delete(session: Any, mv: ModelVersion, restored: Optional[int]) -> Optional[int]:
    """The scope head's number once the head ``mv`` is gone: the restored
    predecessor, or a remaining completed row. None when ``mv`` is not a
    head or the scope is left without one."""
    if mv.status != "completed":
        return None
    if restored is not None:
        return restored
    return session.exec(
        select(ModelVersion.version)
        .where(
            ModelVersion.business_id == mv.business_id,
            ModelVersion.scope == mv.scope,
            ModelVersion.id != mv.id,
            ModelVersion.status == "completed",
        )
        .order_by(col(ModelVersion.version).desc())
    ).first()


def predecessor_to_restore(session: Any, mv: ModelVersion) -> Optional[ModelVersion]:
    """The version that becomes the head when ``mv`` is deleted: for a head
    (``completed``) with no other completed version of its scope, the newest
    superseded, not replaced version older than it. None otherwise."""
    if mv.status != "completed":
        return None
    other_completed = session.exec(
        select(ModelVersion.id).where(
            ModelVersion.business_id == mv.business_id,
            ModelVersion.scope == mv.scope,
            ModelVersion.id != mv.id,
            ModelVersion.status == "completed",
        )
    ).first()
    if other_completed is not None:
        return None
    return session.exec(
        select(ModelVersion)
        .where(
            ModelVersion.business_id == mv.business_id,
            ModelVersion.scope == mv.scope,
            ModelVersion.status == "superseded",
            col(ModelVersion.replaced_at).is_(None),
            col(ModelVersion.version) < int(mv.version),
        )
        .order_by(col(ModelVersion.version).desc())
    ).first()


def delete_refusal(session: Any, mv: ModelVersion) -> Optional[VersionDeleteRefused]:
    """None when the rules let ``mv`` be deleted, else the refusal.

    * Installed anywhere: 409 ``{"error": "installed", "catalogs", "message"}``.
    * A real, not replaced version (superseded, or a legacy second
      completed row) with a newer real, not replaced version above it: 409
      "Delete the newer versions first (...)", so a scope is peeled from the
      top.
    * Otherwise deletable: the head, a Dry Run draft, a replaced version, a
      superseded version at the top of its scope, and a failed, cancelled or
      generating row (an active run is refused before these rules).
    """
    catalogs = installed_catalogs(session, mv)
    if catalogs or mv.deployment_status == _DEPLOYED:
        where = ", ".join(catalogs) or "a catalog"
        message = (
            f"{_scope_label(mv)} is installed in {where}. "
            "Uninstall it first (Uninstall on its page), then delete it."
        )
        return VersionDeleteRefused(
            409, message, detail={"error": "installed", "catalogs": catalogs, "message": message},
        )
    if mv.status in _MODEL_STATUSES and mv.replaced_at is None:
        newer = _newer_live_versions(session, mv)
        if newer:
            listed = ", ".join(f"v{v.version}" for v in newer)
            return VersionDeleteRefused(409, f"Delete the newer versions first ({listed})")
    return None


def _repoint_replaced_by(session: Any, mv: ModelVersion) -> None:
    """Before ``mv`` is deleted, point the versions it replaced at whatever
    replaced ``mv`` (its own ``replaced_by_version_id``), so a chain v5 ->
    v4 -> v3 keeps naming the version that replaced them once v4 is gone.
    With no replacer the pointer would be cleared by ON DELETE SET NULL
    anyway; ``replaced_at`` stays the flag the delete and promotion rules
    read."""
    for row in session.exec(
        select(ModelVersion).where(ModelVersion.replaced_by_version_id == mv.id)
    ).all():
        row.replaced_by_version_id = mv.replaced_by_version_id
        session.add(row)
    session.flush()


def metamodel_cleanup_catalogs(session: Any, mv: ModelVersion) -> list[str]:
    """The catalogs whose ``_metamodel`` registry may hold ``mv``: its home
    rows, its install catalog ``uc_catalog``, and every catalog it was ever
    installed in (open and closed install rows: the agent's uninstall keeps
    registry rows).

    The home rows of an agent-produced version are in its files catalog. An
    import from a Volume path (``import_source_path``) seeded its rows into
    the installation metamodel catalog
    (``core._catalogs.resolve_import_registry_catalog``), not the path's
    catalog, which the app may not own: that catalog is never cleaned unless
    it is one of the others.
    """
    from ...core._catalogs import resolve_import_registry_catalog, resolve_version_volume_catalog

    catalogs: list[str] = []
    if mv.import_source_path:
        home = resolve_import_registry_catalog(session)
    else:
        home = resolve_version_volume_catalog(mv, session)
    for catalog in (home, mv.uc_catalog, *session.exec(
        select(ModelVersionInstall.catalog)
        .where(ModelVersionInstall.version_id == mv.id)
        .order_by(col(ModelVersionInstall.installed_at))
    ).all()):
        catalog = (catalog or "").strip()
        if catalog and catalog not in catalogs:
            catalogs.append(catalog)
    return catalogs


def _discard_change_rejections(session: Any, mv: ModelVersion) -> None:
    """Delete the open feedback items the change review of ``mv`` created
    (``origin=change_rejection`` anchored to ``mv``): they describe changes
    of a version that no longer exists."""
    from ...models import VibeInputOrigin

    ids = list(session.exec(
        select(VibeInput.id)
        .join(VibeInputContextLink, VibeInputContextLink.input_id == VibeInput.id)
        .where(VibeInputContextLink.version_id == mv.id)
        .where(VibeInput.origin == VibeInputOrigin.CHANGE_REJECTION.value)
        .where(col(VibeInput.consumed).is_(False))
    ).all())
    for input_id in dict.fromkeys(ids):
        for link in session.exec(
            select(VibeInputContextLink).where(VibeInputContextLink.input_id == input_id)
        ).all():
            session.delete(link)
        vi = session.get(VibeInput, input_id)
        if vi is not None:
            session.delete(vi)
    session.flush()


def _remove_app_folders(ws: Any, folders: Iterable[Optional[str]]) -> None:
    """Best-effort, bounded removal of the folders the app wrote for deleted
    versions (``volume_copy.remove_volume_folder``); a failure is logged and
    the delete stands."""
    from ..volume_copy import remove_volume_folder

    if ws is None:
        return
    for folder in folders:
        if folder:
            remove_volume_folder(ws, folder, log_prefix="version delete")


def delete_version(
    session: Any,
    ws: Any,
    warehouse_id: Optional[str],
    mv: ModelVersion,
    *,
    finishing_run_id: Optional[str] = None,
    reason: Optional[str] = None,
    discard_change_feedback: bool = False,
) -> DeleteOutcome:
    """Delete one version: its Lakebase rows, then its ``_metamodel`` rows.

    1. Under :func:`core._runs.lock_business_for_run` (a run other than
       ``finishing_run_id`` active, or another request holding the lock:
       :class:`ActiveRunRefused`), check :func:`delete_refusal`. A refusal
       rolls back and changes nothing.
    2. Snapshot the cleanup catalogs (:func:`metamodel_cleanup_catalogs`).
    3. In one transaction: reopen the feedback the version applied
       (:func:`inputs_to_reopen`), delete the change-review feedback made
       from it when ``discard_change_feedback`` (the run change review is
       on; while it is off those items are ordinary feedback), write one ``pending`` ``metamodel_cleanups`` row per catalog,
       delete the version (never touching other versions' lineage pointers),
       and make its predecessor the head again
       (:func:`predecessor_to_restore`). Commit.
    4. After the commit, attempt each cleanup (``done`` or ``failed``); the
       boot sweep and Retry cleanup take the rest. Then remove the folder the
       app wrote for the version (``version_files.app_written_folder``: a
       0.9.0 import's copy), so the same number can be imported again.
    """
    from sqlalchemy.exc import IntegrityError, SQLAlchemyError

    from ...core._metamodel_cleanups import REASON_VERSION_DELETE, record_cleanups, run_cleanups
    from ..version_files import app_written_folder
    from ...core._names import agent_business_segment
    from ...db_models import Business
    from ...explorer import invalidate_model_cache
    from ...routes._helpers import delete_model_version

    version_id = mv.id
    try:
        lock_business_for_run(session, mv.business_id, allow_run_id=finishing_run_id)
    except BusinessBusy as busy:
        raise ActiveRunRefused(busy.message) from busy
    # Read again under the lock: the caller's instance may predate a delete
    # another request committed while this one waited.
    mv = session.exec(
        select(ModelVersion).where(ModelVersion.id == version_id).execution_options(populate_existing=True)
    ).first()
    if mv is None:
        session.rollback()
        raise VersionDeleteRefused(404, "Version not found")
    refusal = delete_refusal(session, mv)
    if refusal is not None:
        session.rollback()
        raise refusal

    business = session.get(Business, mv.business_id)
    business_id = business.id if business else mv.business_id
    deleted_number = int(mv.version)
    catalogs = metamodel_cleanup_catalogs(session, mv)
    restore = predecessor_to_restore(session, mv)
    restore_id = restore.id if restore is not None else None
    head_after = _head_after_delete(session, mv, int(restore.version) if restore is not None else None)
    app_folder = app_written_folder(session, mv, business.name) if business else None

    try:
        reopened = reopen_inputs(session, inputs_to_reopen(session, [mv]))
        if discard_change_feedback:
            _discard_change_rejections(session, mv)
        cleanups = record_cleanups(
            session,
            business_segment=agent_business_segment(business.name) if business else "",
            version=deleted_number,
            scope=(mv.scope or "").lower(),
            catalogs=catalogs,
            reason=reason or REASON_VERSION_DELETE,
        )
        cleanup_ids = [c.id for c in cleanups]
        _repoint_replaced_by(session, mv)
        delete_model_version(session, mv)
        if restore_id:
            restore_superseded_priors(session, [restore_id])
        invalidate_model_cache(business_id, deleted_number)
        session.commit()
    except IntegrityError as exc:
        session.rollback()
        rel = offending_relation(exc)
        raise VersionDeleteRefused(
            409, "Could not delete version: it still has dependent records" + (f" ({rel})" if rel else ""),
        )
    except SQLAlchemyError:
        session.rollback()
        raise VersionDeleteRefused(409, "Could not delete version due to a database error")

    summary = run_cleanups(session, ws, warehouse_id, cleanup_ids)
    _remove_app_folders(ws, [app_folder])
    return DeleteOutcome(
        deleted_version=deleted_number,
        previous_version=head_after,
        metamodel_rows_cleaned=summary.rows_removed,
        cleanup_done=summary.done,
        cleanup_pending=summary.pending,
        cleanup_failed=summary.failed,
        reopened_input_count=len(reopened),
    )


def business_delete_refusal(session: Any, versions: Iterable[ModelVersion]) -> Optional[VersionDeleteRefused]:
    """None when no version of the business is installed anywhere, else the
    409 ``{"error": "installed", "catalogs", "versions", "message"}`` naming
    each installed version and its catalogs (the version delete's message,
    one clause per version)."""
    installed: list[tuple[ModelVersion, list[str]]] = []
    for mv in versions:
        catalogs = installed_catalogs(session, mv)
        if catalogs or mv.deployment_status == _DEPLOYED:
            installed.append((mv, catalogs))
    if not installed:
        return None
    clauses = [f"{_scope_label(mv)} is installed in {', '.join(c) or 'a catalog'}" for mv, c in installed]
    message = (
        "; ".join(clauses)
        + ". Uninstall each one first (Uninstall on its version page), then delete the business."
    )
    catalogs = list(dict.fromkeys(c for _, cs in installed for c in cs))
    return VersionDeleteRefused(409, message, detail={
        "error": "installed",
        "catalogs": catalogs,
        "versions": [
            {"version": int(mv.version), "scope": (mv.scope or "").lower(), "catalogs": cs}
            for mv, cs in installed
        ],
        "message": message,
    })


@dataclass(frozen=True)
class BusinessDeleteOutcome:
    cleanup_done: int = 0
    cleanup_pending: int = 0
    cleanup_failed: int = 0


def delete_business(session: Any, ws: Any, warehouse_id: Optional[str], business_id: str) -> BusinessDeleteOutcome:
    """Delete a business and everything under it, then its versions'
    ``_metamodel`` rows.

    1. Under :func:`core._runs.lock_business_for_run` (an active run, or
       another request holding the lock: :class:`ActiveRunRefused`), refuse
       while any version is installed (:func:`business_delete_refusal`). A
       refusal rolls back and changes nothing.
    2. Snapshot each version's cleanup catalogs
       (:func:`metamodel_cleanup_catalogs`) while its install rows exist.
    3. In one transaction: write one ``pending`` ``metamodel_cleanups`` row
       per version and catalog (reason ``business_delete``), delete the
       business (versions, runs, feedback, business contexts and the rest go
       by ON DELETE CASCADE). Commit.
    4. After the commit, attempt each cleanup (``done`` or ``failed``); the
       boot sweep and Retry cleanup take the rest. The rows outlive the
       business by design: a business created again with the same name sees
       the unfinished ones (same agent segment) and can retry them. Then
       remove the folders the app wrote for its versions
       (``version_files.app_written_folder``).
    """
    from sqlalchemy.exc import IntegrityError, SQLAlchemyError

    from ..version_files import app_written_folder

    from ...core._metamodel_cleanups import REASON_BUSINESS_DELETE, record_cleanups, run_cleanups
    from ...core._names import agent_business_segment
    from ...db_models import Business
    from ...explorer import invalidate_model_cache

    try:
        lock_business_for_run(session, business_id)
    except BusinessBusy as busy:
        raise ActiveRunRefused(busy.message) from busy
    business = session.exec(
        select(Business).where(Business.id == business_id).execution_options(populate_existing=True)
    ).first()
    if business is None:
        session.rollback()
        raise VersionDeleteRefused(404, "Business not found")
    versions = list(session.exec(
        select(ModelVersion)
        .where(ModelVersion.business_id == business_id)
        .order_by(ModelVersion.scope, col(ModelVersion.version))
        .execution_options(populate_existing=True)
    ).all())
    refusal = business_delete_refusal(session, versions)
    if refusal is not None:
        session.rollback()
        raise refusal

    segment = agent_business_segment(business.name)
    snapshots = [
        (int(mv.version), (mv.scope or "").lower(), metamodel_cleanup_catalogs(session, mv)) for mv in versions
    ]
    app_folders = [app_written_folder(session, mv, business.name) for mv in versions]
    try:
        cleanup_ids: list[str] = []
        for number, scope, catalogs in snapshots:
            cleanup_ids += [c.id for c in record_cleanups(
                session, business_segment=segment, version=number, scope=scope,
                catalogs=catalogs, reason=REASON_BUSINESS_DELETE,
            )]
        session.delete(business)
        session.commit()
    except IntegrityError as exc:
        session.rollback()
        rel = offending_relation(exc)
        raise VersionDeleteRefused(
            409, "Could not delete business: it still has dependent records" + (f" ({rel})" if rel else ""),
        )
    except SQLAlchemyError:
        session.rollback()
        raise VersionDeleteRefused(409, "Could not delete business due to a database error")
    invalidate_model_cache(business_id)

    summary = run_cleanups(session, ws, warehouse_id, cleanup_ids)
    _remove_app_folders(ws, app_folders)
    return BusinessDeleteOutcome(
        cleanup_done=summary.done, cleanup_pending=summary.pending, cleanup_failed=summary.failed,
    )
