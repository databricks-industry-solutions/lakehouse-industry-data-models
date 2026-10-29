"""Initial sync — discovers businesses and model versions from Delta metamodel tables.

When the admin configures a deployment catalog, this module scans the
_metamodel.business table to discover all businesses and their completed
versions. Rows are grouped by the agent's business segment
(``agent_business_segment``) and an existing business is the one whose name
has that segment. For a segment with no business it creates the Business
with the catalog industry its model.json's industry alignment resolves to
(its name when the model.json names none; no industry when nothing
matches); a segment that several businesses share is skipped with an error. Each completed version the
business does not have yet is created and synced, with its lineage parent
when model.json names one that exists. Install state goes through
``_version_lifecycle``: a version the agent registered with
``deploy_status = 'dry_run'`` (agent 5.3.3) created no UC objects and stays a
draft; the newest version of a scope is installed in each catalog its
registry rows name (their ``catalog`` column, the agent's installation
catalog; the scanned catalog when none is named); an older one is not
installed.
"""

import logging
from collections.abc import Iterable
from dataclasses import dataclass, field
from typing import Any, Optional

from databricks.sdk import WorkspaceClient
from sqlalchemy.exc import IntegrityError
from sqlmodel import Session, select

from ._query_helpers import (
    businesses_by_segment,
    metamodel_row_key,
    parse_version_number,
    resolve_model_json_parent,
    resolve_model_version,
)
from .agent_compat import gate_model_json
from .core._defaults import SUPPORTED_AGENT_VERSION
from .core._names import agent_business_segment, normalize_scope
from .core._runs import BusinessBusy, lock_business_for_run
from .core._sql import SqlStatementError, rows
from .db_models import Business, ModelVersion
from .error_sanitization import (
    MAX_APP_MESSAGE_LENGTH,
    is_opaque_error,
    offending_relation,
    sanitize_error_message,
)
from .industry_resolve import resolve_industry
from .model_sync import ModelSyncService, _count_source_elements
from .services.business_digest import extract_business_digest
from .services.import_metamodel_writer import APP_SEED_SESSION_ID
from .services.operations._version_lifecycle import (
    evict_deployed_siblings,
    mark_version_deployed,
    mark_version_uninstalled,
    supersede_same_scope_priors,
)

logger = logging.getLogger(__name__)

# A registry only agents before 5.3.3 wrote has no ``deploy_status`` column.
_UNRESOLVED_COLUMN = "UNRESOLVED_COLUMN"


NO_DOMAINS = "The agent's model.json has no domains."
NO_MODEL_DATA = "No model.json in the Volume and no rows in the registry tables for this version."

WAITING_FOR_MIGRATION = (
    "Waiting for the agent's registry migration. An older agent finished this "
    "version, and its completion is recorded only after the next run of the "
    "current agent upgrades the registry; it can be imported then."
)


@dataclass
class _Planned:
    """One completed registry version that passed the checks, with its sources."""

    version: int
    scope: str
    model_scope: str
    version_str: str
    label: str
    # Where the agent installed it: the ``catalog`` of each completed row.
    install_catalogs: list[str] = field(default_factory=list)
    model_data: Any = None
    next_vibes: Any = None
    next_vibes_path: Optional[str] = None


def _existing_version(session: Session, business_id: str, version: int, scope: str) -> bool:
    if scope:
        return resolve_model_version(session, business_id, version, scope) is not None
    return session.exec(
        select(ModelVersion.id).where(
            ModelVersion.business_id == business_id,
            ModelVersion.version == version,
            ModelVersion.scope == "",
        )
    ).first() is not None


def _install_catalogs(rows: list[dict], scanned_catalog: str) -> list[str]:
    """The catalogs a version's completed registry rows name, in first-seen
    order; the scanned catalog when none names one (rows of agents before
    5.3.3, or a run with no installation catalog).

    The agent writes the installation catalog on its run row and on each
    install's row; the registry itself can sit in another catalog (widget
    "10. Metamodel Catalog")."""
    named = list(dict.fromkeys((r.get("catalog") or "").strip() for r in rows))
    named = [c for c in named if c]
    return named or [scanned_catalog]


def _industry_alignment(planned: list[_Planned]) -> str:
    """The industry alignment of the newest planned model.json that names one."""
    for p in reversed(planned):
        digest = extract_business_digest(p.model_data)
        if digest is not None and digest.industry_alignment:
            return digest.industry_alignment
    return ""


def _refuse(summary: dict, segment: str, p: _Planned, reason: str, *, lasting: bool) -> None:
    """Record a version that was not imported, with the reason a user reads.

    ``lasting``: the same input is refused again on every retry (the compat
    gate, the migration wait, an empty model), so the out-of-band cache keeps
    the label. A failure that may pass on retry (a database error, missing
    model data) is reported for this import only.
    """
    # The reason can carry text from the agent's rows or model.json (the
    # compat gate names the file's own release tag), and both summary lists
    # reach the browser.
    reason = sanitize_error_message(reason, max_length=MAX_APP_MESSAGE_LENGTH)
    summary["errors"].append(f"{p.label}: not imported: {reason}")
    summary["refused"].append({
        "business_segment": segment, "version": p.version, "scope": p.scope,
        "reason": reason, "lasting": lasting,
    })


def _is_version_key_conflict(exc: IntegrityError) -> bool:
    """Whether the error is a duplicate of the version's natural key: the
    unique constraint by name (Postgres), or SQLite's message for it."""
    if offending_relation(exc) == "uq_model_versions_business_version_scope":
        return True
    return "UNIQUE constraint failed: model_versions." in str(getattr(exc, "orig", "") or "")


def _write_failure_reason(exc: Exception) -> str:
    """A short reason for a failed write, without the driver's SQL text.

    Only a duplicate of the version's natural key is a concurrent import of
    the same version; any other database error, an integrity error included,
    gets the generic sentence.
    """
    if isinstance(exc, IntegrityError) and _is_version_key_conflict(exc):
        return "Another import saved this version at the same time. Check again to see it."
    if is_opaque_error(exc):
        return "A database error stopped this import. Try again."
    return sanitize_error_message(str(exc))


class InitialSyncService:
    """Discovers and imports businesses from a deployment catalog's metamodel tables."""

    def __init__(self, session: Session, ws: WorkspaceClient, warehouse_id: str):
        self._session = session
        self._ws = ws
        self._warehouse_id = warehouse_id

    def discover_and_sync(
        self,
        catalog: str,
        business_segments: Optional[Iterable[str]] = None,
        only_versions: Optional[set[tuple[str, int, str]]] = None,
        new_businesses_only: bool = False,
    ) -> dict:
        """Scan _metamodel.business for businesses and sync them.

        ``business_segments`` limits the sync to those agent segments;
        ``only_versions`` to those ``(segment, version, scope)`` keys (the
        out-of-band import passes what the detector reported, so a version
        the app deleted and whose rows are still being cleaned is not
        imported again). ``new_businesses_only`` skips a segment that resolves
        to an existing business (the new-business import, when a business with
        that name was created after its scan).

        Each existing business is locked (``lock_business_for_run``, in a
        savepoint) right before its versions are written, so no run of it
        starts meanwhile; a business that is busy is skipped with an error.

        Every check runs before anything is written: a business is created
        only when at least one of its versions passes them, and each version
        is written in its own savepoint, so a failing version leaves nothing
        behind and the others still import.

        Returns a summary dict:
        {
            "businesses_discovered": int,
            "businesses_created": int,
            "businesses_existing": int,
            "versions_synced": int,
            "created_business_ids": list[str],
            "imported": list[[segment, version, scope]],
            "refused": list[{business_segment, version, scope, reason, lasting}],
            "errors": list[str],
        }
        """
        summary = {
            "businesses_discovered": 0,
            "businesses_created": 0,
            "businesses_existing": 0,
            "versions_synced": 0,
            "created_business_ids": [],
            "imported": [],
            "refused": [],
            "errors": [],
        }

        # Discover all unique businesses from _metamodel.business
        business_rows = self._query_businesses(catalog)
        if business_rows is None:
            summary["errors"].append(
                f"Table `{catalog}`._metamodel.business not found"
            )
            return summary

        wanted = None if business_segments is None else {agent_business_segment(s) for s in business_segments}

        # Group by agent segment: "Retail_Corp" and "retail_corp" rows are one business.
        businesses: dict[str, list[dict]] = {}
        for row in business_rows:
            segment = agent_business_segment(row.get("business") or "")
            if not segment or (wanted is not None and segment not in wanted):
                continue
            if only_versions is not None and metamodel_row_key(row) not in only_versions:
                continue
            businesses.setdefault(segment, []).append(row)

        summary["businesses_discovered"] = len(businesses)
        dry_runs = self._query_dry_run_keys(catalog) if businesses else set()

        for segment, versions in businesses.items():
            # SQL orders the version column as text ("10" before "9").
            versions.sort(key=lambda r: (
                parse_version_number(r.get("version")) or 0, normalize_scope(r.get("model_scope") or ""),
            ))
            try:
                self._sync_business(catalog, segment, versions, dry_runs, summary, new_businesses_only)
            except Exception as e:
                logger.exception(f"Error syncing business {segment}")
                summary["errors"].append(f"{segment}: {_write_failure_reason(e)}")

        return summary

    def _query_businesses(self, catalog: str) -> Optional[list[dict]]:
        """Query _metamodel.business for all rows (distinct businesses/versions).

        ``None`` when the table does not exist; any other failure raises
        ``SqlStatementError``.
        """
        sql = (
            f"SELECT DISTINCT business, version, model_scope, processing_status, "
            f"completed_percent, CAST(completion_date AS STRING) as completion_date, catalog "
            f"FROM `{catalog}`.`_metamodel`.`business` "
            f"ORDER BY business, version"
        )
        # One 30 s wait, no polls: the scan runs inside the import request.
        return rows(
            self._ws, self._warehouse_id, sql,
            wait_timeout="30s", missing_table="none", as_dicts=True,
        )

    def _query_dry_run_keys(self, catalog: str) -> set[tuple[str, int, str]]:
        """``(segment, version, scope)`` of the versions the agent registered
        as a Dry Run. An app seed (``session_id`` 0,
        ``import_metamodel_writer.APP_SEED_SESSION_ID``) is also ``dry_run``
        but is no Dry Run, so it is left out. Empty when the table or its
        ``deploy_status`` column does not exist."""
        sql = (
            f"SELECT DISTINCT business, version, model_scope "
            f"FROM `{catalog}`.`_metamodel`.`business` "
            f"WHERE LOWER(TRIM(deploy_status)) = 'dry_run' "
            f"AND COALESCE(session_id, -1) <> {APP_SEED_SESSION_ID}"
        )
        try:
            found = rows(
                self._ws, self._warehouse_id, sql,
                wait_timeout="30s", missing_table="none", as_dicts=True,
            )
        except SqlStatementError as exc:
            if _UNRESOLVED_COLUMN in exc.message:
                return set()
            raise
        return {key for key in map(metamodel_row_key, found or []) if key is not None}

    def _sync_business(
        self,
        catalog: str,
        segment: str,
        versions: list[dict],
        dry_runs: set[tuple[str, int, str]],
        summary: dict,
        new_businesses_only: bool,
    ) -> None:
        existing = businesses_by_segment(self._session).get(segment, [])
        if len(existing) > 1:
            summary["errors"].append(
                f"{segment}: several businesses share this name segment; "
                f"rename one of them, then import again"
            )
            return
        business = existing[0] if existing else None
        if business is not None and new_businesses_only:
            summary["errors"].append(
                f"{business.name}: this business was created after the check; "
                f"import its versions from its own page"
            )
            return
        # A new business takes the name the agent stored (display-cased segment).
        display = business.name if business else next(
            (r.get("business") for r in versions if r.get("business")), segment,
        )

        planned = self._plan_versions(catalog, business, segment, display, versions, summary)
        if not planned:
            return
        if business is not None:
            try:
                with self._session.begin_nested():
                    lock_business_for_run(self._session, business.id, rollback=False)
            except BusinessBusy as exc:
                summary["errors"].append(f"{display}: not imported: {exc.message}")
                return

        nested = self._session.begin_nested()
        try:
            created = False
            if business is None:
                business = self._create_business(display, _industry_alignment(planned))
                created = True
            written = self._sync_versions(catalog, business, segment, planned, dry_runs, summary)
        except Exception:
            nested.rollback()
            raise
        if created and written == 0:
            nested.rollback()
            return
        nested.commit()
        if created:
            summary["businesses_created"] += 1
            summary["created_business_ids"].append(business.id)
        else:
            summary["businesses_existing"] += 1

    def _plan_versions(
        self,
        catalog: str,
        business: Optional[Business],
        segment: str,
        display: str,
        versions: list[dict],
        summary: dict,
    ) -> list[_Planned]:
        """The completed versions to import, with their loaded sources, after
        every check that writes nothing. Refusals go to ``summary``.

        Rows are grouped by ``(version, scope)``: a finished run and the
        install that follows it leave two rows of one key. A key Lakebase
        already has is skipped before anything else, and a completed row wins
        over one still waiting for the agent's migration, as in the detector.
        """
        by_key: dict[tuple[int, str], list[dict]] = {}
        for row in versions:
            key = (parse_version_number(row.get("version")) or 1, normalize_scope(row.get("model_scope") or ""))
            by_key.setdefault(key, []).append(row)

        planned: list[_Planned] = []
        for (version_num, scope), key_rows in by_key.items():
            if business is not None and _existing_version(self._session, business.id, version_num, scope):
                continue
            completed = [
                r for r in key_rows
                if r.get("completion_date") and float(r.get("completed_percent") or "0") >= 100
            ]
            row = completed[0] if completed else key_rows[0]
            p = _Planned(version=version_num, scope=scope, model_scope=row.get("model_scope") or "",
                         version_str=str(row.get("version") or version_num),
                         label=f"{display} v{version_num} {scope.upper()}".rstrip(),
                         install_catalogs=_install_catalogs(completed, catalog))
            if not completed:
                if any(r.get("completed_percent") is None and r.get("completion_date") for r in key_rows):
                    _refuse(summary, segment, p, WAITING_FOR_MIGRATION, lasting=True)
                continue

            sync = ModelSyncService(self._session, self._ws, self._warehouse_id)
            p.model_data, p.next_vibes, p.next_vibes_path = sync.load_resync_sources(
                catalog, segment, p.version_str, p.model_scope
            )
            # An empty model must not displace the installed version below.
            if not p.model_data:
                _refuse(summary, segment, p, NO_MODEL_DATA, lasting=False)
                continue
            gate = gate_model_json(p.model_data, fallback=SUPPORTED_AGENT_VERSION)
            if gate.refused:
                _refuse(summary, segment, p, gate.refusal_message, lasting=True)
                continue
            if _count_source_elements(p.model_data)["domains"] == 0:
                _refuse(summary, segment, p, NO_DOMAINS, lasting=True)
                continue
            planned.append(p)
        return planned

    def _create_business(self, business_name: str, industry_alignment: str) -> Business:
        """A new Business with the catalog industry ``industry_alignment``
        resolves to, or the one its name resolves to when the model.json
        names no industry. No match leaves it without one."""
        industry = resolve_industry(self._session, industry_alignment or business_name)
        business = Business(
            name=business_name,
            industry_alignment=industry_alignment or (industry.name if industry else ""),
            industry_id=industry.id if industry else None,
        )
        self._session.add(business)
        self._session.flush()
        return business

    def _sync_versions(
        self,
        catalog: str,
        business: Business,
        segment: str,
        planned: list[_Planned],
        dry_runs: set[tuple[str, int, str]],
        summary: dict,
    ) -> int:
        """Create and sync each planned version in its own savepoint. Returns
        how many versions were written.

        Planned rows are in version order, so a parent created in this pass is
        found as the lineage parent of a later version. A version is
        installed only when it is the newest of its scope, in each of its
        install catalogs, evicting the business's other versions there: an
        older one the app did not have arrives superseded and uninstalled, and
        evicts nothing. A Dry Run stays a draft with no install catalog and
        never becomes the head.
        """
        written = 0
        for p in planned:
            try:
                with self._session.begin_nested():
                    self._write_version(catalog, business, segment, p, dry_runs)
            except Exception as exc:
                logger.exception("Out-of-band import of %s failed", p.label)
                _refuse(summary, segment, p, _write_failure_reason(exc), lasting=False)
                continue
            written += 1
            if p.scope:
                summary["imported"].append([segment, p.version, p.scope])
            summary["versions_synced"] += 1
        return written

    def _write_version(
        self, catalog: str, business: Business, segment: str, p: _Planned, dry_runs: set,
    ) -> None:
        dry_run = (segment, p.version, p.scope) in dry_runs
        # Only a version that was ever the scope's current one counts as newer;
        # a failed or draft row leaves the scope without a completed version.
        newer = self._session.exec(
            select(ModelVersion.id).where(
                ModelVersion.business_id == business.id,
                ModelVersion.scope == p.scope,
                ModelVersion.version > p.version,
                ModelVersion.dry_run == False,  # noqa: E712
                ModelVersion.status.in_(("completed", "superseded")),
            )
        ).first()
        parent = resolve_model_json_parent(self._session, business.id, p.model_data)

        # Install state goes through the lifecycle helpers, which keep the
        # install rows and the version's columns in step. Every version is
        # born a draft with no install catalog; ``files_catalog`` holds the
        # catalog its files and registry rows are in.
        if dry_run:
            status = "draft"
        elif newer is not None:
            status = "superseded"
        else:
            status = "completed"
        mv = ModelVersion(
            business_id=business.id,
            version=p.version,
            status=status,
            dry_run=dry_run,
            deployment_status="draft",
            scope=p.scope,
            files_catalog=catalog,
            base_version_id=parent.id if parent else None,
        )
        self._session.add(mv)
        self._session.flush()

        if status == "completed":
            # The newest version of its scope is installed where the agent's
            # registry rows say it installed it (their ``catalog`` column),
            # which is not always the catalog whose registry was scanned.
            if p.scope:
                supersede_same_scope_priors(self._session, business.id, p.scope, mv.id)
            for install_catalog in p.install_catalogs:
                mark_version_deployed(self._session, mv, install_catalog)
                evict_deployed_siblings(self._session, mv, same_scope=False, catalog=install_catalog)
        elif status == "superseded":
            # A newer version of its scope replaced it, so it is not installed.
            mark_version_uninstalled(self._session, mv)

        # The planner refused empty and missing models, so with the preloaded
        # model sync_model either writes it or raises; a raise rolls this
        # version back in the caller's savepoint.
        ModelSyncService(self._session, self._ws, self._warehouse_id).sync_model(
            mv.id, catalog, segment, p.version_str, p.model_scope,
            preloaded_model_data=p.model_data,
            next_vibes_preload=(p.next_vibes, p.next_vibes_path),
        )
