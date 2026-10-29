"""Consistency checker between Lakebase (app state) and the fake UC side.

:func:`assert_lakebase_metamodel_consistent` checks four invariants and lists
every violation in one ``AssertionError``:

1. Every completed ``ModelVersion`` has exactly one registry ``business`` row,
   with domain, product and attribute counts equal to its Lakebase rows, in
   its home catalog: the files catalog the app resolves for it
   (``core/_catalogs.resolve_version_volume_catalog``), or for an import from
   a Volume path the catalog the import seeded
   (``core/_catalogs.resolve_import_registry_catalog``). Rows are matched as
   the app's readers match them: ``LOWER(business)`` against the agent's
   segment of ``Business.name``, the bare version, the short scope. When the
   key's business rows name more than one catalog in their ``catalog`` column
   (agent 5.3.3 keeps one registration per install catalog), each such
   catalog has exactly one business row and its own domain rows, against one
   set of product and attribute rows, and a domain row naming none of them
   (or no catalog) is reported. A registration in a catalog the version has
   an install row in (open or closed) is checked the same way when present.
2. Every registry key in the checked catalogs maps to a Lakebase version
   whose home catalog it is or that has an install row (open or closed) there
   (the agent registers an install in the install catalog's ``_metamodel``
   and an uninstall keeps those rows), to an unfinished ``MetamodelCleanup`` row
   (``pending`` or ``failed``), or to a key the test declared as an expected
   orphan (``allow_orphans``). Allowed orphans are returned in the report.
3. ``deployed`` implies a non-empty ``uc_catalog`` equal to the catalog of the
   latest open ``ModelVersionInstall`` row; ``uninstalled`` implies no open
   row (the B5 invariant); a ``draft`` version has no open row (a draft is
   never installed).
4. The Volume folder of every completed version exists: the nested or legacy
   flat version folder in its files catalog (the app's reader order), or the
   folder of an import's ``import_source_path``.

``catalogs`` limits every check to versions that resolve to, and registry rows
in, those catalogs.
"""
from __future__ import annotations

from dataclasses import dataclass, field
from typing import Iterable, Optional

from sqlmodel import Session, func, select

from vibe_modeling.backend.core._catalogs import resolve_import_registry_catalog, resolve_version_volume_catalog
from vibe_modeling.backend.core._names import agent_business_segment, normalize_scope
from vibe_modeling.backend.db_models import (
    Attribute, Business, Domain, MetamodelCleanup, ModelVersion, ModelVersionInstall, Product,
)
from vibe_modeling.backend.model_sync import _version_root_candidates

from .fake_uc import FakeUC, RegistryKey

UNFINISHED_CLEANUP = ("pending", "failed")


@dataclass(frozen=True)
class Problem:
    item: int
    message: str

    def __str__(self) -> str:
        return f"({self.item}) {self.message}"


@dataclass
class ConsistencyReport:
    problems: list[Problem] = field(default_factory=list)
    orphans: list[RegistryKey] = field(default_factory=list)

    @property
    def ok(self) -> bool:
        return not self.problems

    def items(self) -> set[int]:
        return {p.item for p in self.problems}


def _key_of(mv: ModelVersion, business: Business, catalog: str) -> RegistryKey:
    return RegistryKey(
        catalog, agent_business_segment(business.name), str(mv.version), normalize_scope(mv.scope),
    )


def _lakebase_counts(session: Session, version_id: str) -> tuple[int, int, int]:
    domains = session.exec(select(func.count()).select_from(Domain).where(Domain.version_id == version_id)).one()
    products = session.exec(select(func.count()).select_from(Product).where(Product.version_id == version_id)).one()
    attributes = session.exec(
        select(func.count()).select_from(Attribute).join(Product, Attribute.product_id == Product.id)
        .where(Product.version_id == version_id)
    ).one()
    return int(domains), int(products), int(attributes)


def _in_key(key: RegistryKey):
    def match(row: dict) -> bool:
        return (
            str(row.get("business") or "").lower() == key.business
            and str(row.get("version") or "") == key.version
            and str(row.get("model_scope") or "") == key.scope
        )
    return match


def _catalog_of(row: dict) -> str:
    return str(row.get("catalog") or "").strip().lower()


def _registrations_by_install_catalog(
    fake_uc: FakeUC, key: RegistryKey,
) -> tuple[dict[str, tuple[int, int]], int]:
    """``({install catalog: (business rows, domain rows)}, stray domain rows)``
    of ``key``, read from the rows' ``catalog`` column, when its business rows
    name more than one catalog; else ``({}, 0)``. Stray domain rows have a
    blank catalog or one no business row names.

    Agent 5.3.3 (``install-registry-keeps-deployment``) keeps a version's
    business row and domain rows for each catalog it is installed in, in one
    ``_metamodel``; product and attribute rows stay one set."""
    in_key = _in_key(key)
    business = [r for r in fake_uc.rows(key.catalog, "business") if in_key(r)]
    named = {_catalog_of(r) for r in business}
    if len(named) < 2 or "" in named:
        return {}, 0
    domains = [r for r in fake_uc.rows(key.catalog, "domain") if in_key(r)]
    per_catalog = {
        c: (sum(_catalog_of(r) == c for r in business), sum(_catalog_of(r) == c for r in domains))
        for c in named
    }
    return per_catalog, sum(_catalog_of(r) not in named for r in domains)


def _check_registration(
    report: ConsistencyReport, fake_uc: FakeUC, what: str, key: RegistryKey, entry,
    lakebase: tuple[int, int, int],
) -> None:
    """Item 1 on the registry rows of ``key``: one business row (per install
    catalog when the rows name several) and the Lakebase counts."""
    where = repr(key.catalog)
    per_install, stray = _registrations_by_install_catalog(fake_uc, key)
    if per_install:
        for install_catalog, (business_rows, domains) in sorted(per_install.items()):
            if business_rows > 1:
                report.problems.append(Problem(
                    1, f"{what}: {business_rows} registry business rows in {where} for {key} "
                       f"registered as installed in {install_catalog!r}",
                ))
            registry = (domains, entry.products, entry.attributes)
            if lakebase != registry:
                report.problems.append(Problem(
                    1, f"{what}: Lakebase (domains, products, attributes) = {lakebase}, "
                       f"registry in {where} for install catalog {install_catalog!r} = {registry}",
                ))
        if stray:
            report.problems.append(Problem(
                1, f"{what}: {stray} registry domain rows in {where} for {key} name no registered "
                   f"install catalog ({sorted(per_install)})",
            ))
        return
    if entry.business_rows > 1:
        report.problems.append(Problem(
            1, f"{what}: {entry.business_rows} registry business rows in {where} for {key}",
        ))
    registry = (entry.domains, entry.products, entry.attributes)
    if lakebase != registry:
        report.problems.append(Problem(
            1, f"{what}: Lakebase (domains, products, attributes) = {lakebase}, "
               f"registry in {where} = {registry}",
        ))


def _registry_home(mv: ModelVersion, session: Session) -> str:
    """Where a version's home registry rows are: an import from a Volume path
    seeded them into the installation metamodel catalog
    (``resolve_import_registry_catalog``), not the path's catalog; an
    agent-produced version has them in its files catalog."""
    if mv.import_source_path:
        return resolve_import_registry_catalog(session)
    return resolve_version_volume_catalog(mv, session)


def _install_catalogs(session: Session, mv: ModelVersion) -> list[str]:
    rows = session.exec(select(ModelVersionInstall.catalog).where(ModelVersionInstall.version_id == mv.id)).all()
    return sorted({(c or "").strip() for c in rows} - {""})


def _describe(mv: ModelVersion, business: Business) -> str:
    return f"{business.name!r} v{mv.version} {mv.scope or '(no scope)'} [{mv.status}/{mv.deployment_status}]"


def check_lakebase_metamodel_consistency(
    session: Session,
    fake_uc: FakeUC,
    catalogs: Optional[Iterable[str]] = None,
    *,
    allow_orphans: Iterable[RegistryKey] = (),
) -> ConsistencyReport:
    """Run the four checks and return the report (no raise)."""
    report = ConsistencyReport()
    scope_catalogs = set(catalogs) if catalogs is not None else None
    allowed = set(allow_orphans)
    entries = {e.key: e for e in fake_uc.registry()}

    rows = session.exec(select(ModelVersion, Business).join(Business, ModelVersion.business_id == Business.id)).all()
    resolved: list[tuple[ModelVersion, Business, str]] = [
        (mv, biz, _registry_home(mv, session)) for mv, biz in rows
    ]

    for mv, biz, catalog in resolved:
        if mv.status != "completed" or (scope_catalogs is not None and catalog not in scope_catalogs):
            continue
        what = _describe(mv, biz)
        key = _key_of(mv, biz, catalog)
        entry = entries.get(key)
        lakebase = _lakebase_counts(session, mv.id)
        if entry is None or entry.business_rows == 0:
            report.problems.append(Problem(1, f"{what}: no registry business row in {catalog!r} for {key}"))
        else:
            _check_registration(report, fake_uc, what, key, entry, lakebase)
        for install_catalog in _install_catalogs(session, mv):
            installed_key = _key_of(mv, biz, install_catalog)
            installed_entry = entries.get(installed_key)
            if installed_key != key and installed_entry is not None and (
                scope_catalogs is None or install_catalog in scope_catalogs
            ):
                _check_registration(report, fake_uc, what, installed_key, installed_entry, lakebase)
        if mv.import_source_path:
            folders = [mv.import_source_path.rsplit("/", 1)[0]]
        else:
            folders = _version_root_candidates(
                resolve_version_volume_catalog(mv, session), biz.name, str(mv.version), mv.scope or "",
            )
        if not any(fake_uc.is_dir(f) for f in folders):
            report.problems.append(Problem(4, f"{what}: no Volume folder at any of {folders}"))

    known = {_key_of(mv, biz, catalog) for mv, biz, catalog in resolved}
    known |= {
        _key_of(mv, biz, install_catalog)
        for mv, biz, _ in resolved
        for install_catalog in _install_catalogs(session, mv)
    }
    pending = {
        RegistryKey(c.catalog, c.business_segment.lower(), str(c.version), normalize_scope(c.scope))
        for c in session.exec(select(MetamodelCleanup).where(MetamodelCleanup.status.in_(UNFINISHED_CLEANUP)))
    }
    for key in entries:
        if scope_catalogs is not None and key.catalog not in scope_catalogs:
            continue
        if key in known or key in pending:
            continue
        if key in allowed:
            report.orphans.append(key)
            continue
        report.problems.append(Problem(2, f"registry rows for {key} map to no Lakebase version"))

    for mv, biz, catalog in resolved:
        if scope_catalogs is not None and catalog not in scope_catalogs:
            continue
        what = _describe(mv, biz)
        uc = (mv.uc_catalog or "").strip()
        if mv.deployment_status == "deployed" and not uc:
            report.problems.append(Problem(3, f"{what}: deployed with an empty uc_catalog"))
        open_rows = session.exec(
            select(ModelVersionInstall)
            .where(ModelVersionInstall.version_id == mv.id, ModelVersionInstall.uninstalled_at.is_(None))
            .order_by(ModelVersionInstall.installed_at.desc())
        ).all()
        open_catalogs = [r.catalog for r in open_rows]
        if mv.deployment_status == "deployed":
            latest = open_catalogs[0] if open_catalogs else None
            if uc and latest != uc:
                report.problems.append(Problem(
                    3, f"{what}: uc_catalog {uc!r} but the latest open install row is in {latest!r}",
                ))
        elif mv.deployment_status == "uninstalled" and open_rows:
            report.problems.append(Problem(
                3, f"{what}: uninstalled but has open install rows in {open_catalogs}",
            ))
        if mv.status == "draft" and open_rows:
            report.problems.append(Problem(
                3, f"{what}: a draft with open install rows in {open_catalogs}",
            ))
    return report


def assert_lakebase_metamodel_consistent(
    session: Session,
    fake_uc: FakeUC,
    catalogs: Optional[Iterable[str]] = None,
    *,
    allow_orphans: Iterable[RegistryKey] = (),
) -> ConsistencyReport:
    """Raise ``AssertionError`` listing every violation; return the report."""
    report = check_lakebase_metamodel_consistency(session, fake_uc, catalogs, allow_orphans=allow_orphans)
    assert report.ok, "Lakebase and the UC side disagree:\n" + "\n".join(f"  {p}" for p in report.problems)
    return report
