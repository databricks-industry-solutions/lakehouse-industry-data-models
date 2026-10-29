"""Give an industry downloaded before 0.9.0 the scope prefixes a download adds now.

From 0.9.0 the industry download rewrites the app's copy of the model.json
(:mod:`services.scope_prefix`): a blank schema prefix becomes ``ecm_`` /
``mvm_`` on the schemas, metric view sources and metric view names, and the
version records what was added. Industries downloaded earlier keep bare names.
``POST /api/industries/{business_id}/scope-prefixes`` (``install/
fix_industry_prefixes.py`` calls it) applies the same rewrite to them.

:func:`plan_prefix_fix` reads and checks every version and writes nothing (the
dry run is that plan). Per version:

- a version the app did not download (its ``import_source_path`` is not the
  industry repository's ``github://`` path: the agent or a user wrote it) is
  ``unchanged``: the import rule keeps such files as written;
- a version installed in any catalog is ``skipped``, naming the catalogs: the
  fix never renames schemas that exist in Unity Catalog;
- otherwise the version's model.json is read (``version_files``, bounded, the
  install's budget), rewritten with ``apply_import_prefix`` + ``stamp_scope``,
  and is ``changed`` when the rewrite differs from the file. A file the fix
  already rewrote, or a 0.9.0 download, rewrites to itself: ``unchanged``.

:func:`apply_prefix_fix` writes the ``changed`` versions, one at a time, each
on its own: the model file is uploaded last, so until it is, the file is still
bare and a rerun repeats every step (each one is idempotent). Per version:

1. with no transaction open: the original as ``model.json.pre090`` next to it
   (``core/_paths.MODEL_JSON_BACKUP_SUFFIX``; the copier, the indexer and the
   agent's ``*.json`` discovery leave it out), the version's ``_metamodel``
   rows deleted (``ModelSyncService.delete_metamodel_rows``) and seeded again
   from the rewritten model (``seed_metamodel_one``: a non-owning ``dry_run``
   row, the file's folder as location);
2. a short transaction: ``lock_business_for_run``, :func:`recheck_version`,
   the ``Domain`` rows (``apply_import_prefix_to_rows``) and the markers,
   commit;
3. the rewritten model.json.

A version whose file already has its prefixes but whose markers are unset, or
whose Domain rows lack the file's schema names, is ``changed`` too: steps 1
and 2 finish it (no backup, no upload). A failed step makes the version ``failed`` with what completed; the other
versions still run.
"""

from __future__ import annotations

import io
import json
import logging
from dataclasses import dataclass, field
from typing import Any, Optional

from fastapi import HTTPException
from sqlmodel import Session, col, select

from ..core import resolve_version_volume_catalog
from ..core._names import agent_business_segment
from ..core._paths import MODEL_JSON_BACKUP_SUFFIX
from ..core._runs import BusinessBusy, lock_business_for_run
from ..db_models import Business, Domain, ModelVersion
from ..error_sanitization import recorded_error_text
from ..import_model import model_payload
from ..model_sync import ModelSyncService
from ..models import ScopePrefixAction
from .import_metamodel_writer import seed_metamodel_one, seed_warnings
from .operations._version_lifecycle import installed_catalogs
from .operations._install_conventions import REQUIRED_READ_TIMEOUT_S
from .scope_prefix import (
    apply_import_prefix,
    apply_import_prefix_to_rows,
    file_schema_prefix,
    import_schema_prefix,
    stamp_scope,
)
from .version_files import first_readable_model_json, version_model_json_candidates

logger = logging.getLogger(__name__)

CHANGED: ScopePrefixAction = "changed"
UNCHANGED: ScopePrefixAction = "unchanged"
SKIPPED: ScopePrefixAction = "skipped"
FAILED: ScopePrefixAction = "failed"
_DOWNLOAD_SOURCE = "github://"


@dataclass
class VersionFix:
    """One version's plan: what the fix does with it and why. ``markers`` are
    the version's import markers when the plan read it (:func:`recheck`)."""

    version_id: str
    version: int
    scope: str
    action: ScopePrefixAction
    reason: str
    warnings: list[str] = field(default_factory=list)
    markers: tuple[Optional[str], Optional[str]] = (None, None)
    candidates: list[str] = field(default_factory=list)
    business_name: str = ""
    catalog: str = ""
    path: Optional[str] = None
    original: str = ""
    rewritten: Any = None
    schema_prefix_added: str = ""
    view_prefix_added: str = ""
    # The version's ``Domain.database_name`` values when the plan read it.
    domain_names: set[str] = field(default_factory=set)
    # The prefix step 2 gives the Domain rows ("" leaves them).
    rows_prefix: str = ""
    # The file already has its prefixes: only the registry, the Domain rows
    # and the markers are written (no backup, no upload).
    finish_only: bool = False

    @property
    def label(self) -> str:
        return f"v{self.version} {self.scope.upper()}"


def _check_version(session: Session, mv: ModelVersion, business_name: str) -> VersionFix:
    """The database checks of one version; a version that passes them gets
    its model.json candidates for :func:`_read_and_rewrite`."""
    row = VersionFix(
        version_id=mv.id, version=int(mv.version), scope=mv.scope or "", action=UNCHANGED, reason="",
        markers=(mv.import_schema_prefix_added, mv.import_view_prefix_added),
    )
    if not (mv.import_source_path or "").startswith(_DOWNLOAD_SOURCE):
        row.reason = "Not downloaded from the industry repository; kept as it was written."
        return row
    if row.scope not in ("ecm", "mvm"):
        row.action, row.reason = SKIPPED, f"v{row.version} has no ECM or MVM scope."
        return row
    catalogs = installed_catalogs(session, mv)
    if catalogs:
        row.action = SKIPPED
        row.reason = (
            f"{row.label} is installed in {', '.join(catalogs)}. The fix never renames installed "
            "schemas; uninstall it there first to give it the prefixes."
        )
        return row
    row.business_name = business_name
    row.domain_names = {
        d.database_name or "" for d in session.exec(select(Domain).where(Domain.version_id == mv.id)).all()
    }
    row.catalog = resolve_version_volume_catalog(mv, session)
    row.candidates = version_model_json_candidates(session, mv, business_name)
    return row


def _read_and_rewrite(ws: Any, row: VersionFix) -> None:
    """Read the version's model.json and rewrite it in memory, the way a
    0.9.0 download rewrites the app's copy."""
    path, root = first_readable_model_json(ws, row.candidates, timeout_s=REQUIRED_READ_TIMEOUT_S)
    if path is None or not isinstance(root, dict):
        row.action = SKIPPED
        row.reason = f"Could not read the model.json of {row.label} from its folder; nothing was changed."
        return
    original = json.dumps(root)
    report = apply_import_prefix(root, row.scope, import_schema_prefix(row.scope, file_schema_prefix(root)))
    stamp_scope(root, row.version, row.scope)
    row.path, row.warnings = path, list(report.warnings)
    if json.dumps(root) == original:
        _plan_finish(ws, row, root)
        return
    row.action, row.original, row.rewritten = CHANGED, original, root
    row.schema_prefix_added, row.view_prefix_added = report.schema_prefix_added, report.view_prefix_added
    row.rows_prefix = report.schema_prefix_added
    parts = []
    if report.schema_prefix_added:
        parts.append(f"its schemas get {report.schema_prefix_added}")
    if report.views:
        parts.append(f"{len(report.views)} metric view(s) get {report.view_prefix_added}")
    parts.append(f"its version is stamped v{row.version}_{row.scope}")
    text = "; ".join(parts)
    row.reason = text[0].upper() + text[1:] + "."


def _file_schemas(root: Any) -> set[str]:
    return {
        str(d.get("database_name") or "")
        for d in model_payload(root).get("domains") or []
        if isinstance(d, dict)
    }


def _plan_finish(ws: Any, row: VersionFix, root: Any) -> None:
    """The file already has its prefixes. When the version records no
    markers, or its Domain rows don't carry the file's schema names (a fix
    that stopped after the file was written), plan the rest: the registry,
    the Domain rows (the file's prefix) and the markers, which come from
    rewriting the ``model.json.pre090`` backup when it reads (else ``""``:
    nothing is known to have been added)."""
    bare_rows = bool(row.domain_names - _file_schemas(root))
    if row.markers[0] is not None and not bare_rows:
        row.reason = "Already has its scope prefixes."
        return
    markers = ("", "")
    assert row.path is not None
    _, backup = first_readable_model_json(
        ws, [f"{row.path}{MODEL_JSON_BACKUP_SUFFIX}"], timeout_s=REQUIRED_READ_TIMEOUT_S,
    )
    if isinstance(backup, dict):
        report = apply_import_prefix(backup, row.scope, import_schema_prefix(row.scope, file_schema_prefix(backup)))
        markers = (report.schema_prefix_added, report.view_prefix_added)
    row.action, row.rewritten, row.finish_only = CHANGED, root, True
    row.schema_prefix_added, row.view_prefix_added = markers
    row.rows_prefix = (file_schema_prefix(root) or "") if bare_rows else ""
    row.reason = (
        "Its model file already has its scope prefixes; its registry rows, database rows "
        "and markers are finished."
    )


def industry_or_404(session: Session, business_id: str) -> Business:
    """The industry ``business_id``: 404 when there is none, 400 for a business."""
    business = session.get(Business, business_id)
    if business is None:
        raise HTTPException(status_code=404, detail="Industry not found")
    if business.kind != "industry":
        raise HTTPException(
            status_code=400,
            detail=(
                f"{business.name} is a business, not an industry. The scope-prefix fix changes "
                "industries downloaded before 0.9.0 only."
            ),
        )
    return business


def _versions(session: Session, business_id: str) -> list[ModelVersion]:
    return list(session.exec(
        select(ModelVersion)
        .where(ModelVersion.business_id == business_id)
        .order_by(col(ModelVersion.scope), col(ModelVersion.version))
    ).all())


def plan_prefix_fix(session: Session, ws: Any, business: Business) -> list[VersionFix]:
    """Every version's plan; writes nothing. The database checks run first and
    their read transaction is closed before the file reads, so none is held
    across them."""
    business_name = business.name
    plans = [_check_version(session, mv, business_name) for mv in _versions(session, business.id)]
    session.commit()
    for row in plans:
        if row.candidates:
            _read_and_rewrite(ws, row)
    return plans


def recheck_version(session: Session, row: VersionFix) -> Optional[str]:
    """Why ``row`` can't be written now (deleted, installed, or its markers
    changed since the plan read it), or ``None``."""
    mv = session.get(ModelVersion, row.version_id)
    if mv is None:
        return f"{row.label} was deleted while the fix ran."
    catalogs = installed_catalogs(session, mv)
    if catalogs:
        return f"{row.label} was installed in {', '.join(catalogs)} while the fix ran; nothing more was changed."
    if (mv.import_schema_prefix_added, mv.import_view_prefix_added) != row.markers:
        return f"{row.label} changed while the fix ran. Run the fix again."
    return None


def recheck(session: Session, plans: list[VersionFix]) -> None:
    """Under the business lock, before any write: refuse (409, after a
    rollback) when a planned version changed since the plan read it."""
    for row in plans:
        reason = recheck_version(session, row) if row.action == CHANGED else None
        if reason:
            session.rollback()
            raise HTTPException(status_code=409, detail=reason)


def _fail(row: VersionFix, step: str, exc: BaseException) -> None:
    logger.exception("industry_prefix_fix: %s failed at %s", row.label, step)
    row.action = FAILED
    row.reason = f"{step} {recorded_error_text(exc, f'industry prefix fix of {row.label}').rstrip('. ')}. Run the fix again."


def _write_registry(ws: Any, sync: ModelSyncService, row: VersionFix, warehouse_id: str) -> None:
    """Step 1, no transaction open: backup, registry delete, seed."""
    assert row.path is not None
    if not row.finish_only:
        ws.files.upload(f"{row.path}{MODEL_JSON_BACKUP_SUFFIX}", io.BytesIO(row.original.encode("utf-8")), overwrite=True)
    sync.delete_metamodel_rows(
        catalog=row.catalog, business_name=agent_business_segment(row.business_name),
        version=str(row.version), model_scope=row.scope,
    )
    seed = seed_metamodel_one(
        ws,
        catalog=row.catalog,
        warehouse_id=warehouse_id,
        model_json=model_payload(row.rewritten),
        business_name=row.business_name,
        scope=row.scope,
        version=row.version,
        log_prefix="industry_prefix_fix",
        wait_mode="request",
        location=row.path.rsplit("/", 1)[0],
    )
    if seed is not None and seed.get("errors"):
        raise RuntimeError("; ".join(seed_warnings(seed)))
    row.warnings.extend(seed_warnings(seed))


def _write_rows(session: Session, business_id: str, row: VersionFix) -> Optional[str]:
    """Step 2: the Domain rows and the markers under the business lock.
    Returns why it refused (nothing written), or ``None`` after the commit."""
    try:
        lock_business_for_run(session, business_id)
    except BusinessBusy as exc:
        return exc.message
    reason = recheck_version(session, row)
    if reason:
        session.rollback()
        return reason
    mv = session.get(ModelVersion, row.version_id)
    assert mv is not None
    if row.rows_prefix:
        apply_import_prefix_to_rows(session, mv.id, row.rows_prefix)
    mv.import_schema_prefix_added = row.schema_prefix_added
    mv.import_view_prefix_added = row.view_prefix_added
    session.add(mv)
    session.commit()
    return None


def apply_prefix_fix(
    session: Session, ws: Any, business_id: str, plans: list[VersionFix], warehouse_id: str,
) -> None:
    """Write every ``changed`` plan (see the module docstring). The caller
    has no transaction open; every row that fails ends ``failed``, its
    reason naming what completed."""
    sync = ModelSyncService(session, ws, warehouse_id=warehouse_id)
    for row in plans:
        if row.action != CHANGED:
            continue
        try:
            _write_registry(ws, sync, row, warehouse_id)
        except Exception as exc:  # noqa: BLE001 - reported on the row
            _fail(row, "Its model file and database rows are unchanged; rewriting its registry rows failed, so it may have none until the fix runs again:", exc)
            continue
        try:
            refused = _write_rows(session, business_id, row)
        except Exception as exc:  # noqa: BLE001 - reported on the row
            session.rollback()
            _fail(row, "Its registry rows are rewritten and its model file is unchanged; saving its database rows failed:", exc)
            continue
        if refused:
            row.action = FAILED
            row.reason = f"Its registry rows are rewritten and its model file is unchanged; {refused}"
            continue
        assert row.path is not None
        if row.finish_only:
            continue
        try:
            ws.files.upload(row.path, io.BytesIO(json.dumps(row.rewritten).encode("utf-8")), overwrite=True)
        except Exception as exc:  # noqa: BLE001 - reported on the row
            _fail(row, "Its registry and database rows are fixed; uploading its rewritten model file failed:", exc)


__all__ = [
    "CHANGED",
    "FAILED",
    "SKIPPED",
    "UNCHANGED",
    "VersionFix",
    "apply_prefix_fix",
    "industry_or_404",
    "plan_prefix_fix",
    "recheck",
    "recheck_version",
]
