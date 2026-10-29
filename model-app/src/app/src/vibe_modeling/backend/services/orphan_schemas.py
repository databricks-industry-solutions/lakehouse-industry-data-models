"""Orphan schemas: a business's schemas in a catalog that no installed version claims.

A version deleted from Lakebase while it was installed (or a business whose
versions are all gone) leaves its schemas in Unity Catalog. No agent
operation can address them: the agent's uninstall needs a version. This
module finds them and drops the ones the app may drop.

**Candidates** (lower case; Unity Catalog folds schema names):

- From Lakebase: each version of the business, with the prefix and suffix its
  install into the catalog recorded, else the ones it was dispatched with
  (:func:`schema_names.recorded_schema_names`). Match ``exact``.
- From the agent's registry in the catalog, ``<catalog>._metamodel.domain``,
  for registry versions of the business Lakebase does not know. The agent
  writes one row per domain with ``database_name`` and the domain's physical
  ``catalog`` (record columns nb 53483; row nb 53559-53560:
  ``database_name`` as the model file has it, else ``sanitize_name`` of the
  domain name, and ``catalog_of(d)``). An install whose conventions differ
  from the file's rewrites ``database_name`` as the deploy prefix plus the
  snake-cased domain name before it registers (nb 107060-107063), with
  ``catalog`` from the deploy's ``CatalogResolver.resolve_catalog``
  (nb 107064-107067); a run's own rows leave ``catalog`` NULL. Agent 5.3.3
  generation stores the prefix already (``ecm_sales``, ``mvm_ecm_sales``).
  So the stored name is the schema without the suffix, which
  ``CatalogResolver.resolve_schema`` adds at write time (nb 7559-7560) and
  the registry does not keep. The stored name is matched ``exact``; the
  name with the scope's One Catalog prefix (``ecm_`` / ``mvm_``) when it
  lacks it is ``inferred``. Rows whose ``catalog`` is another catalog are
  skipped. A schema with a suffix of a version Lakebase does not know is not
  found.

**Claimed** (never orphans, whatever else says so): every name form
(:func:`schema_names.uninstall_schema_candidates`) of every version
installed in the catalog, of any business; every form of every version of
any other app business (also one with the same agent segment); and the
stored and prefixed names of other segments' registry rows. ``_metamodel``,
``_metrics``, ``information_schema`` and ``default`` are never candidates.

**Made by the app**: a registry version Lakebase does not know is a deleted
app version only when ``oob_detector.OobRowRule`` says none of its
``_metamodel.business`` rows came from a run the app did not launch (an app
or zero ``session_id``, or an open cleanup). A version made outside the app
is out-of-band (the business page offers to import it), and one with no
business row cannot be told apart: their schemas are listed with a
``blocked_reason`` and are not droppable.

**Droppable**: an orphan the app service principal owns (the owner the
catalog listing reports, compared with ``core._app_identity``) with no
``blocked_reason``. The app grants nothing on the rest.

**Drop** (:func:`drop_orphan_schemas`): an app-only audit Run with intent
:data:`ORPHAN_DROP_INTENT`, committed ``running`` with one
``run_schema_drops`` row per schema, then ``DROP SCHEMA ... CASCADE`` per
schema (the agent's uninstall drops the same way, nb 108401), each outcome
committed. A failed or timed-out statement is decided from a fresh listing.
Then the registry rows of each version Lakebase does not know whose schemas
here are all gone are removed through ``core._metamodel_cleanups`` (reason
``orphan_drop``), unless some of its rows name another catalog. Rows of
versions Lakebase knows stay, as the agent's own uninstall leaves them.
"""

from __future__ import annotations

import hashlib
import json
import logging
from dataclasses import dataclass, field
from datetime import datetime, timezone
from typing import Any, Literal, Optional

from fastapi import HTTPException

from sqlmodel import col, select

from ..core import _sql
from ..core._app_identity import app_application_id
from ..core._errors import needs_confirmation_error
from ..core._metamodel_cleanups import (
    DONE,
    REASON_ORPHAN_DROP,
    record_cleanups,
    run_cleanups,
    unfinished_cleanups,
)
from ..core._names import agent_business_segment, normalize_scope
from ..db_models import Business, Domain, MetamodelCleanup, ModelVersion, Product, Run, RunSchemaDrop
from ..error_sanitization import sanitize_error_message
from ..oob_detector import OobKey, OobRowRule
from .._query_helpers import metamodel_row_key
from ..models import (
    DropOrphanSchemasOut,
    IssueOut,
    MetamodelCleanupSummaryOut,
    OrphanSchemaDropOut,
    OrphanSchemaOut,
    UninstallImpactOut,
)
from ..run_state_transitions import transition_run
from .operations._version_lifecycle import versions_installed_in
from .schema_names import (
    RESERVED_SCHEMAS,
    agent_snake_case,
    failed_install_schema_names,
    physical_schema_name,
    recorded_schema_names,
    scope_schema_prefix,
    uninstall_schema_candidates,
)
from .uninstall_impact import (
    cached_impact,
    impact_needs_confirmation,
    schema_set_impact,
)

logger = logging.getLogger(__name__)

ORPHAN_DROP_INTENT = "uninstall-orphan-schemas"
RETRY_REFUSED = (
    "A schema drop is not retried. Check the catalog again on the business's Edit page, "
    "under Deployment, Orphan schemas, and drop what is still there."
)
CONFIRM_SUBJECT_PREFIX = "drop_destroys_data"
MAX_DROP_SCHEMAS = 50
REGISTRY_ROW_CAP = 20000
REGISTRY_TIMEOUT_S = 30.0
DROP_TIMEOUT_S = 60.0

Match = Literal["exact", "inferred"]
RegistryKey = tuple[int, str]


class OrphanDiscoveryError(RuntimeError):
    """The catalog could not be listed, or its registry is too large to read
    whole; ``message`` is for users."""

    def __init__(self, message: str) -> None:
        self.message = message
        super().__init__(message)


class RegistryReadError(OrphanDiscoveryError):
    """A registry statement failed; ``sql_message`` is the sanitized
    ``SqlStatementError.message`` (for ``core/_errors.registry_scan_failed_error``)."""

    def __init__(self, catalog: str, sql_message: str) -> None:
        self.sql_message = sql_message
        super().__init__(f"The agent's registry in {catalog} could not be read: {sql_message}")


@dataclass(frozen=True)
class RegistryDomain:
    """One ``_metamodel.domain`` row, keyed like ``metamodel_row_key``:
    ``business`` is the agent's business segment, ``scope`` ``ecm`` or
    ``mvm``, ``catalog`` the domain's physical catalog, lower-cased (``""``
    on a run's own rows)."""

    business: str
    version: int
    scope: str
    database_name: str
    catalog: str


@dataclass
class Registry:
    """The agent's registry in one catalog: its domain rows, and the
    ``session_id`` of every ``_metamodel.business`` row per
    ``(segment, version, scope)``, for :class:`oob_detector.OobRowRule`."""

    domains: list[RegistryDomain] = field(default_factory=list)
    sessions: dict[OobKey, list[str]] = field(default_factory=dict)


@dataclass
class Discovery:
    """The orphans of one business in one catalog.

    ``key_names``: per registry version Lakebase does not know, its present
    candidate names that no one claims; its registry rows may go once all of
    them are dropped, unless the version is in ``keep_registry`` (some of
    its domain rows name another catalog, whose schemas this check does not
    see)."""

    catalog: str
    schemas: list[OrphanSchemaOut] = field(default_factory=list)
    key_names: dict[RegistryKey, set[str]] = field(default_factory=dict)
    keep_registry: set[RegistryKey] = field(default_factory=set)

    def droppable(self) -> set[str]:
        return {s.name for s in self.schemas if s.owned_by_app and not s.blocked_reason}

    def owners(self) -> dict[str, str]:
        return {s.name: s.owner for s in self.schemas}


def _read(ws: Any, warehouse_id: str, catalog: str, sql: str, what: str) -> Optional[list[list]]:
    try:
        data = _sql.rows(ws, warehouse_id, sql, timeout_s=REGISTRY_TIMEOUT_S, missing_table="none")
    except _sql.SqlStatementError as exc:
        logger.warning("orphan schemas: registry %s of %r unreadable: %s", what, catalog, exc)
        raise RegistryReadError(catalog, exc.message) from exc
    if data is not None and len(data) > REGISTRY_ROW_CAP:
        raise OrphanDiscoveryError(
            f"The agent's registry in {catalog} has more than {REGISTRY_ROW_CAP} {what} rows; "
            "the app does not look for orphan schemas there."
        )
    return data


def read_registry(ws: Any, warehouse_id: str, catalog: str) -> Registry:
    """The agent's registry in ``catalog`` (domain rows and business-row
    session ids); empty when the tables do not exist. Raises
    :class:`OrphanDiscoveryError` when a table cannot be read or holds more
    than :data:`REGISTRY_ROW_CAP` rows (an incomplete read would miss other
    businesses' claims or a version made outside the app)."""
    cat = _sql.safe_identifier(catalog)
    out = Registry()
    domains = _read(ws, warehouse_id, catalog, (
        f"SELECT business, version, model_scope, database_name, catalog "
        f"FROM {cat}.`_metamodel`.`domain` LIMIT {REGISTRY_ROW_CAP + 1}"
    ), "domain") or []
    for business, version, scope, database_name, domain_catalog in domains:
        key = metamodel_row_key({"business": business, "version": version, "model_scope": scope})
        name = str(database_name or "").strip().lower()
        if key is None or not name:
            continue
        out.domains.append(RegistryDomain(
            business=key[0], version=key[1], scope=key[2], database_name=name,
            catalog=str(domain_catalog or "").strip().lower(),
        ))
    businesses = _read(ws, warehouse_id, catalog, (
        f"SELECT business, version, model_scope, CAST(session_id AS STRING) AS session_id "
        f"FROM {cat}.`_metamodel`.`business` LIMIT {REGISTRY_ROW_CAP + 1}"
    ), "business") or []
    for business, version, scope, session_id in businesses:
        key = metamodel_row_key({"business": business, "version": version, "model_scope": scope})
        if key is not None:
            out.sessions.setdefault(key, []).append(str(session_id or ""))
    return out


_NO_BUSINESS_ROW = (
    "The agent's registry has no business record of this version, so the app cannot tell "
    "whether it made it. The app does not drop it."
)
_MADE_OUTSIDE_APP = (
    "The app has no record of starting the run that made this version: it was made outside "
    "the app, or deleted by an earlier release of the app. Import it and uninstall it, or "
    "drop it by hand."
)


def _provenance_block(registry: Registry, rule: OobRowRule, key: OobKey) -> Optional[str]:
    """Why an unknown registry version's schemas are not droppable, or None
    for a version the app made and deleted (app or zero session id, or an
    open cleanup)."""
    sessions = registry.sessions.get(key)
    if not sessions:
        return _NO_BUSINESS_ROW
    if any(rule.outside_app(key, sid) for sid in sessions):
        return _MADE_OUTSIDE_APP
    return None


def _registry_forms(row: RegistryDomain) -> list[tuple[str, Match]]:
    bare = physical_schema_name(row.database_name)
    prefixed = physical_schema_name(row.database_name, scope_schema_prefix(row.scope))
    return [(bare, "exact")] + ([(prefixed, "inferred")] if prefixed != bare else [])


def _claimed_names(session: Any, mv: ModelVersion, catalog: str) -> set[str]:
    names = {f for group in uninstall_schema_candidates(session, mv.id, mv.scope) for f in group.forms}
    return names | recorded_schema_names(session, mv.id, mv.scope, catalog)


def _claimed_among(session: Any, catalog: str, candidates: set[str], business_id: str) -> set[str]:
    """The ``candidates`` a version installed in ``catalog`` (any business)
    or any version of another business uses.

    Every name form of a version contains one of its bases: a domain's
    ``database_name``, the snake-cased domain name an install with another
    prefix rebuilds it from, or a dotted product table's schema part
    (:func:`physical_schema_name` only adds affixes). So only versions with a
    base inside some candidate are expanded."""
    if not candidates:
        return set()
    versions = {mv.id: mv for mv in versions_installed_in(session, catalog)}
    others = {
        mv.id: mv for mv in session.exec(
            select(ModelVersion).where(ModelVersion.business_id != business_id)
        ).all()
    }
    bases: dict[str, set[str]] = {}
    if others:
        for vid, db, name in session.exec(
            select(Domain.version_id, Domain.database_name, Domain.name)
            .where(col(Domain.version_id).in_(list(others)))
        ).all():
            bases.setdefault(vid, set()).update(
                b for b in ((db or "").strip().lower(), agent_snake_case(name or "")) if b
            )
        for vid, table_name in session.exec(
            select(Product.version_id, Product.table_name)
            .where(col(Product.version_id).in_(list(others)))
        ).all():
            if "." in (table_name or ""):
                bases.setdefault(vid, set()).add(table_name.split(".", 1)[0].strip().lower())
    for vid, mv in others.items():
        if any(b in n for b in bases.get(vid, ()) for n in candidates):
            versions.setdefault(vid, mv)
    claimed: set[str] = set()
    for mv in versions.values():
        claimed |= _claimed_names(session, mv, catalog) & candidates
    return claimed


def _list_schemas(ws: Any, catalog: str) -> dict[str, str]:
    """``{name: owner}`` of the schemas in ``catalog``, names lower-cased."""
    try:
        return {
            s.name.lower(): str(getattr(s, "owner", None) or "")
            for s in ws.schemas.list(catalog_name=catalog)
            if s.name
        }
    except Exception as exc:  # noqa: BLE001 - reported to the caller
        logger.warning("orphan schemas: could not list schemas in %r: %s", catalog, exc)
        raise OrphanDiscoveryError(
            f"The schemas in {catalog} could not be listed: {sanitize_error_message(str(exc))}"
        ) from exc


def discover_orphans(
    session: Any, ws: Any, business: Business, catalog: str, registry: Registry,
) -> Discovery:
    """The orphan schemas of ``business`` in ``catalog`` (see the module
    docstring), from a fresh listing of the catalog and the Lakebase state
    now. ``registry`` is :func:`read_registry` of ``catalog``."""
    listed = _list_schemas(ws, catalog)
    segment = agent_business_segment(business.name)
    segment_ids = {
        b.id for b in session.exec(select(Business)).all()
        if agent_business_segment(b.name) == segment
    }
    known: set[RegistryKey] = {
        (int(mv.version), normalize_scope(mv.scope or "") or "ecm")
        for mv in session.exec(
            select(ModelVersion).where(col(ModelVersion.business_id).in_(list(segment_ids)))
        ).all()
    }

    matches: dict[str, Match] = {}
    keys_of: dict[str, set[RegistryKey]] = {}

    def _add(name: str, match: Match, key: Optional[RegistryKey] = None) -> None:
        if not name or name not in listed or name in RESERVED_SCHEMAS:
            return
        if matches.get(name) != "exact":
            matches[name] = match
        if key is not None:
            keys_of.setdefault(name, set()).add(key)

    own = session.exec(select(ModelVersion).where(ModelVersion.business_id == business.id)).all()
    for mv in own:
        for name in recorded_schema_names(session, mv.id, mv.scope, catalog) | failed_install_schema_names(
            session, mv.id, catalog,
        ):
            _add(name, "exact")
    rule = OobRowRule.load(session, catalog)
    blocked: dict[str, str] = {}
    keep_registry: set[RegistryKey] = set()
    for row in registry.domains:
        key = (row.version, row.scope)
        if row.business != segment or key in known:
            continue
        if row.catalog not in ("", catalog):
            keep_registry.add(key)
            continue
        reason = _provenance_block(registry, rule, (segment, row.version, row.scope))
        for name, match in _registry_forms(row):
            _add(name, match, key)
            if reason and name in matches:
                blocked.setdefault(name, reason)

    claimed = _claimed_among(session, catalog, set(matches), business.id)
    for row in registry.domains:
        if row.business != segment:
            claimed |= {name for name, _ in _registry_forms(row)}

    app_id = app_application_id(ws).lower()
    out = Discovery(catalog=catalog, keep_registry=keep_registry)
    for name in sorted(set(matches) - claimed):
        owner = listed[name]
        out.schemas.append(OrphanSchemaOut(
            name=name, owner=owner, match=matches[name],
            owned_by_app=bool(app_id) and owner.lower() == app_id,
            blocked_reason=blocked.get(name),
        ))
        if name in blocked:
            continue
        for key in keys_of.get(name, ()):
            out.key_names.setdefault(key, set()).add(name)
    return out


def confirm_subject(catalog: str, names: list[str]) -> str:
    """The confirm subject a drop of ``names`` from ``catalog`` needs when it
    may delete data: bound to the exact set, so a confirmation for one
    selection never covers another."""
    digest = hashlib.sha256(",".join(sorted({n.lower() for n in names})).encode()).hexdigest()[:16]
    return f"{CONFIRM_SUBJECT_PREFIX}:{catalog}:{digest}"


def orphan_impact(
    ws: Any,
    warehouse_id: str,
    catalog: str,
    names: list[str],
    owners: dict[str, str],
    *,
    user: Optional[str] = None,
    fresh: bool = False,
) -> UninstallImpactOut:
    """What dropping ``names`` deletes, through the uninstall-impact cache and
    the caller's scan limit (``ScanRateLimited``)."""
    selected = sorted({n.lower() for n in names})
    return cached_impact(
        ("orphan-drop", catalog, *selected),
        lambda: schema_set_impact(ws, warehouse_id, catalog, selected, owners=owners),
        user=user,
        fresh=fresh,
    )


def subject_needed(impact: UninstallImpactOut, catalog: str, names: list[str]) -> Optional[str]:
    """The confirm subject the drop needs, or None when nothing may be lost."""
    return confirm_subject(catalog, names) if impact_needs_confirmation(impact) else None


def needs_confirmation(catalog: str, names: list[str], impact: UninstallImpactOut) -> HTTPException:
    """The 422 ``needs_confirmation`` of an unconfirmed drop that may delete
    data: one ``confirm`` issue (the ``IssueOut`` shape) and the ``impact``
    the dialog renders."""
    tables = [t for s in impact.schemas for t in s.tables]
    holding = sum(1 for t in tables if t.has_data is True)
    parts = [
        f"Dropping {len(names)} schema{'s' if len(names) != 1 else ''} from {catalog} deletes "
        "every table in them."
    ]
    if holding:
        parts.append(f"{holding} of {len(tables)} tables hold data, and their rows are lost.")
    parts.extend(impact.reasons)
    message = " ".join(parts)
    issue = IssueOut(
        field_path="schemas", step_index=-1, severity="confirm",
        subject=confirm_subject(catalog, names), message=message,
    )
    return needs_confirmation_error(
        [issue.model_dump()], f"Confirm what this drop deletes: {message}", impact=impact.model_dump(),
    )


def _now() -> datetime:
    return datetime.now(timezone.utc)


def _still_listed(ws: Any, catalog: str, name: str) -> bool:
    """Whether ``name`` is still in ``catalog``; True when the listing fails
    (an unreadable state is not a drop)."""
    try:
        return name in _list_schemas(ws, catalog)
    except OrphanDiscoveryError:
        return True


def _drop_one(ws: Any, warehouse_id: str, catalog: str, row: RunSchemaDrop) -> None:
    sql = f"DROP SCHEMA {_sql.safe_identifier(catalog)}.{_sql.safe_identifier(row.schema_name)} CASCADE"
    try:
        _sql.run(ws, warehouse_id, sql, timeout_s=DROP_TIMEOUT_S, on_timeout="detach")
        row.status, row.error = "dropped", None
        return
    except _sql.SqlStatementError as exc:
        failure = exc
    if not _still_listed(ws, catalog, row.schema_name):
        row.status, row.error = "dropped", None
        return
    row.status = "failed"
    if failure.state == "STILL_RUNNING":
        row.error = (
            f"The drop did not finish within {int(DROP_TIMEOUT_S)} s and may still be running "
            "in the warehouse. Check the catalog again later."
        )
    else:
        row.error = failure.message[:500]


def _close_earlier_cleanups(session: Any, cleanups: list[MetamodelCleanup], run_id: str) -> None:
    """Mark ``done`` the older unfinished cleanups of the same version key and
    catalog as each of ``cleanups`` that finished: their registry rows are
    the ones it removed, so they would only linger in the list."""
    for done in cleanups:
        session.refresh(done)
        if done.status != DONE:
            continue
        for row in unfinished_cleanups(
            session, done.business_segment, scope=done.scope, catalog=done.catalog,
        ):
            if row.id != done.id and int(row.version) == int(done.version):
                row.status = DONE
                row.last_error = f"Done by the orphan-schema drop run {run_id}"
                row.updated_at = _now()
                session.add(row)
    session.commit()


def drop_orphan_schemas(
    session: Any,
    ws: Any,
    warehouse_id: str,
    business: Business,
    catalog: str,
    names: list[str],
    discovery: Discovery,
    impact: Optional[UninstallImpactOut],
    *,
    requested_by: str,
) -> DropOrphanSchemasOut:
    """Drop ``names`` (every one droppable in ``discovery``) from ``catalog``.

    The caller holds the business lock (``lock_business_for_run``) and read
    ``discovery`` under it. The first commit writes the audit Run as
    ``running`` with its ``run_schema_drops`` rows and releases the lock; the
    active run then keeps other runs of the business out. Each schema's
    outcome is committed as it lands; a cancelled run stops before the next
    schema. The run ends ``completed`` when every schema was dropped, else
    ``failed``."""
    selected = sorted(dict.fromkeys(n.lower() for n in names))
    tables = {s.name: len(s.tables) for s in (impact.schemas if impact else [])}
    now = _now()
    run = Run(
        business_id=business.id,
        version_id=None,
        intent=ORPHAN_DROP_INTENT,
        status="running",
        progress_message=f"Dropping {len(selected)} orphan schema(s) in {catalog}",
        parameters_json=json.dumps(
            {"catalog": catalog, "schemas": selected, "requested_by": requested_by}
        ),
        created_at=now,
        started_at=now,
    )
    session.add(run)
    session.flush()
    rows = [
        RunSchemaDrop(run_id=run.id, catalog=catalog, schema_name=name, table_count=tables.get(name, 0))
        for name in selected
    ]
    for row in rows:
        session.add(row)
    session.commit()

    summary = MetamodelCleanupSummaryOut()
    try:
        for row in rows:
            session.refresh(run)
            if run.status != "running":
                row.status, row.error = "failed", "Not dropped: the run was cancelled."
            else:
                _drop_one(ws, warehouse_id, catalog, row)
            session.add(row)
            session.commit()

        dropped = {r.schema_name for r in rows if r.status == "dropped"}
        segment = agent_business_segment(business.name)
        cleanups = []
        for (version, scope), key_names in sorted(discovery.key_names.items()):
            if key_names and key_names <= dropped and (version, scope) not in discovery.keep_registry:
                cleanups += record_cleanups(
                    session, business_segment=segment, version=version, scope=scope,
                    catalogs=[catalog], reason=REASON_ORPHAN_DROP,
                )
        session.commit()
        if cleanups:
            result = run_cleanups(session, ws, warehouse_id, [c.id for c in cleanups])
            summary = MetamodelCleanupSummaryOut(
                done=result.done, pending=result.pending, failed=result.failed,
            )
            _close_earlier_cleanups(session, cleanups, run.id)
    finally:
        session.refresh(run)
        failed = [r for r in rows if r.status != "dropped"]
        if run.status == "running":
            if failed:
                transition_run(
                    session, run, target_status="failed",
                    reason=f"{len(failed)} of {len(rows)} schemas were not dropped",
                )
                run.error_message = "; ".join(
                    f"{r.schema_name}: {r.error or 'not dropped'}" for r in failed
                )[:2000]
            else:
                transition_run(session, run, target_status="completed")
            run.progress_percent = 100
            session.add(run)
        session.commit()

    return DropOrphanSchemasOut(
        run_id=run.id,
        catalog=catalog,
        schemas=schema_drops_of_run(session, run.id),
        metamodel_cleanup=summary,
    )


def schema_drops_of_run(session: Any, run_id: str) -> list[OrphanSchemaDropOut]:
    """The ``run_schema_drops`` rows of an orphan-drop run, by schema name."""
    rows = session.exec(
        select(RunSchemaDrop).where(RunSchemaDrop.run_id == run_id).order_by(col(RunSchemaDrop.schema_name))
    ).all()
    return [
        OrphanSchemaDropOut(name=r.schema_name, status=r.status, table_count=r.table_count, error=r.error)
        for r in rows
    ]
