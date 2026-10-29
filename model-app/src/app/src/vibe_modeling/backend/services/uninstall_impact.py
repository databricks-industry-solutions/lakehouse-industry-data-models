"""What uninstalling a model version from a catalog destroys.

The agent's uninstall drops, with ``DROP DATABASE ... CASCADE``, each domain
schema of the version, the schema part of every dotted product
``table_name``, and the ``_metrics`` schema of every catalog it touches
(the metric views of every model in that catalog). :func:`uninstall_impact`
lists those objects and checks, within fixed bounds, which tables hold rows,
so the UI can warn and ask for an explicit confirmation before data is lost.
The rule is that the impact may overstate what is dropped, never understate
it: what cannot be read is ``unknown``, which needs the confirmation.

- Schema names come from :func:`services.schema_names.uninstall_schema_candidates`;
  every candidate that exists in ``ws.schemas.list`` is listed, plus
  ``_metrics`` when it exists (marked ``shared``, with the other versions
  the app records as installed in the catalog: their metric views go too).
- One catalog per check. A version installed in several catalogs (its
  ``model_version_installs`` rows) has one impact per catalog; the result
  names them all (``installed_catalogs``). A catalog the version is not
  recorded in is still scanned: the uninstall drops what it finds there.
- Catalog per Division and Catalog per Domain installs put schemas in other
  catalogs; this check reads one catalog, so such a version is ``unknown``.
- Names are compared in lower case (Unity Catalog folds schema names). A
  version recorded as installed in the catalog with any domain schema not
  found, or with no schema names at all, is ``unknown``: its names may
  differ from what the app expects.
- Tables, views and volumes: one ``information_schema`` statement per check.
  Volumes are listed and make the result at least ``unknown`` (files are not
  checked).
- Rows: chunks of up to :data:`DATA_CHECK_CHUNK` tables per statement, each
  table a scalar subquery in the projection
  (``(SELECT COUNT(*) FROM (SELECT 1 FROM t LIMIT 1))``, at most one row
  read). At most :data:`DATA_CHECK_TABLE_CAP` tables are checked.
- The whole check, listing included, shares one budget of
  :data:`IMPACT_BUDGET_S` seconds; each statement gets what is left as its
  timeout. A table not checked (over the cap, out of time, a failed
  statement, a name that is not a plain identifier) has ``has_data=None``
  and counts as holding data.
- Views, materialized views and metric views are listed without a check.

:func:`schema_set_impact` runs the same listing and data check on a given
set of schemas with no version, for the orphan-schema drop
(``services/orphan_schemas.py``); :func:`cached_impact` is the one cache and
scan limit both go through.

Results are cached per ``(version_id, catalog, cataloging style)`` for
:data:`CACHE_TTL_S` seconds, and a caller that passes ``user`` may start at
most :data:`SCANS_PER_USER` scans per :data:`SCAN_WINDOW_S` seconds
(:class:`ScanRateLimited` otherwise). All SQL goes through ``core._sql``.
"""

from __future__ import annotations

import logging
import threading
import time
from collections import deque
from typing import Any, Callable, Optional

from ..core import _sql
from ..db_models import Business, ModelVersion
from ..models import (
    UninstallImpactOut,
    UninstallImpactSchemaOut,
    UninstallImpactTableOut,
    UninstallImpactVersionOut,
)
from .dispatched_widgets import latest_install_widgets
from .operations._version_lifecycle import installed_catalogs, versions_installed_in
from .schema_names import METRICS_SCHEMA, uninstall_schema_candidates

logger = logging.getLogger(__name__)

IMPACT_BUDGET_S = 40.0
DATA_CHECK_CHUNK = 100
DATA_CHECK_TABLE_CAP = 500
LISTING_ROW_CAP = 5000
CACHE_TTL_S = 60.0
CACHE_MAX_ENTRIES = 256
SCANS_PER_USER = 6
SCAN_WINDOW_S = 60.0

_POLL_INTERVAL_S = 2.0
# A statement started with less time than this left cannot come back in time:
# one poll sleep plus one get_statement round trip (about 5 s on a serverless
# warehouse, the estimate ``core._sql`` uses before it has measured one).
_MIN_STATEMENT_S = _POLL_INTERVAL_S + _sql._FIRST_READ_ESTIMATE_S

ONE_CATALOG = "One Catalog"

VIEW_KINDS = frozenset({"VIEW", "MATERIALIZED_VIEW", "METRIC_VIEW"})
_VOLUME_KIND = "VOLUME"

CONFIRM_SUBJECT_PREFIX = "uninstall_destroys_data"


def uninstall_confirm_subject(version_id: str, catalog: str) -> str:
    """The confirm-issue subject a plain uninstall needs when data may be lost."""
    return f"{CONFIRM_SUBJECT_PREFIX}:{version_id}:{catalog}"


def impact_needs_confirmation(impact: UninstallImpactOut) -> bool:
    """Data held or not known to be absent: the user must confirm the loss."""
    return impact.has_data != "no"


class ScanRateLimited(RuntimeError):
    """The caller started too many scans; ``retry_after_s`` until the next one."""

    def __init__(self, retry_after_s: int) -> None:
        self.retry_after_s = retry_after_s
        super().__init__(f"uninstall impact scan limit reached; retry in {retry_after_s}s")


class ImpactCache:
    """Impacts by key for ``ttl_s`` seconds, lock-guarded: ``(version_id,
    catalog, style)`` for an uninstall, ``("orphan-drop", catalog, *names)``
    for an orphan-schema drop."""

    def __init__(self, ttl_s: float = CACHE_TTL_S, max_entries: int = CACHE_MAX_ENTRIES) -> None:
        self._ttl = ttl_s
        self._max = max_entries
        self._lock = threading.Lock()
        self._items: dict[tuple[str, ...], tuple[float, UninstallImpactOut]] = {}

    def _prune(self, now: float) -> None:
        for key in [k for k, (at, _) in self._items.items() if now - at >= self._ttl]:
            del self._items[key]
        while len(self._items) >= self._max:
            oldest = min(self._items, key=lambda k: self._items[k][0])
            del self._items[oldest]

    def get(self, key: tuple[str, ...]) -> Optional[UninstallImpactOut]:
        now = time.monotonic()
        with self._lock:
            item = self._items.get(key)
            if item is None or now - item[0] >= self._ttl:
                return None
            return item[1].model_copy(deep=True)

    def put(self, key: tuple[str, ...], impact: UninstallImpactOut) -> None:
        now = time.monotonic()
        with self._lock:
            self._prune(now)
            self._items[key] = (now, impact.model_copy(deep=True))

    def clear(self) -> None:
        with self._lock:
            self._items.clear()


class ScanLimiter:
    """At most ``limit`` scans per user in any ``window_s`` seconds."""

    def __init__(self, limit: int = SCANS_PER_USER, window_s: float = SCAN_WINDOW_S) -> None:
        self._limit = limit
        self._window = window_s
        self._lock = threading.Lock()
        self._starts: dict[str, deque[float]] = {}

    def acquire(self, user: str) -> None:
        """Record a scan for ``user`` or raise :class:`ScanRateLimited`."""
        now = time.monotonic()
        with self._lock:
            for key in [k for k, q in self._starts.items() if not q or now - q[-1] >= self._window]:
                del self._starts[key]
            starts = self._starts.setdefault(user, deque())
            while starts and now - starts[0] >= self._window:
                starts.popleft()
            if len(starts) >= self._limit:
                wait = self._window - (now - starts[0])
                raise ScanRateLimited(max(1, int(wait + 0.999)))
            starts.append(now)

    def clear(self) -> None:
        with self._lock:
            self._starts.clear()


IMPACT_CACHE = ImpactCache()
SCAN_LIMITER = ScanLimiter()


def uninstall_impact(
    session: Any,
    ws: Any,
    warehouse_id: str,
    version: ModelVersion,
    catalog: str,
    *,
    cataloging_style: Optional[str] = None,
    user: Optional[str] = None,
    fresh: bool = False,
) -> UninstallImpactOut:
    """The impact of uninstalling ``version`` from ``catalog``, through the cache.

    ``cataloging_style`` is the style the uninstall will run with (the run
    form's); ``None`` means the style of the version's last install.
    ``fresh=True`` skips the cache read (the result is still stored), for a
    caller that must see the current state, such as a run create that was
    not confirmed. With ``user``, a scan counts against that user's limit and
    may raise :class:`ScanRateLimited`; a cache hit never does.
    """
    return cached_impact(
        uninstall_impact_key(version.id, catalog, cataloging_style),
        lambda: compute_uninstall_impact(
            session, ws, warehouse_id, version, catalog, cataloging_style=cataloging_style,
        ),
        user=user,
        fresh=fresh,
    )


def uninstall_impact_key(version_id: str, catalog: str, cataloging_style: Optional[str]) -> tuple[str, ...]:
    """The cache key of an uninstall impact: version, catalog, style."""
    return (version_id, catalog, _style_key(cataloging_style))


def cached_uninstall_impact(
    version: ModelVersion, catalog: str, cataloging_style: Optional[str] = None,
) -> Optional[UninstallImpactOut]:
    """The impact :func:`uninstall_impact` last computed for ``version`` in
    ``catalog`` while it is still cached, else None. Never scans."""
    return IMPACT_CACHE.get(uninstall_impact_key(version.id, catalog, cataloging_style))


def cached_impact(
    key: tuple[str, ...],
    compute: Callable[[], UninstallImpactOut],
    *,
    user: Optional[str] = None,
    fresh: bool = False,
) -> UninstallImpactOut:
    """``compute()`` through :data:`IMPACT_CACHE` under ``key``, a scan
    counted against ``user``'s limit (:class:`ScanRateLimited`); a cache hit
    never counts. ``fresh=True`` skips the cache read; the result is still
    stored."""
    if not fresh:
        hit = IMPACT_CACHE.get(key)
        if hit is not None:
            return hit
    if user is not None:
        SCAN_LIMITER.acquire(user)
    impact = compute()
    IMPACT_CACHE.put(key, impact)
    return impact


def _style_key(style: Optional[str]) -> str:
    return " ".join(str(style or "").replace("_", " ").split()).lower()


def _is_one_catalog(style: Optional[str]) -> bool:
    return _style_key(style) in ("", _style_key(ONE_CATALOG))


_STYLE_LABELS = {
    _style_key(label): label
    for label in (ONE_CATALOG, "Catalog per Division", "Catalog per Domain")
}


def _style_label(style: Optional[str]) -> str:
    """The display label of a style in any spelling (``catalog_per_domain``)."""
    return _STYLE_LABELS.get(_style_key(style), str(style or ""))


def other_versions_installed_in(session: Any, version: ModelVersion, catalog: str) -> list[UninstallImpactVersionOut]:
    """The other versions, of any business, installed in ``catalog`` (in any
    case). Roles are app-wide today, so every business is listed; once access
    is per business, filter this to the businesses the caller may see (or
    count the rest)."""
    names: dict[str, str] = {}
    out: list[UninstallImpactVersionOut] = []
    for mv in versions_installed_in(session, catalog):
        if mv.id == version.id:
            continue
        if mv.business_id not in names:
            business = session.get(Business, mv.business_id)
            names[mv.business_id] = business.name if business is not None else ""
        out.append(UninstallImpactVersionOut(
            version_id=mv.id, business_id=mv.business_id, business_name=names[mv.business_id],
            scope=mv.scope or "", version=int(mv.version),
        ))
    return out


def compute_uninstall_impact(
    session: Any,
    ws: Any,
    warehouse_id: str,
    version: ModelVersion,
    catalog: str,
    *,
    cataloging_style: Optional[str] = None,
    budget_s: float = IMPACT_BUDGET_S,
) -> UninstallImpactOut:
    """Scan ``catalog`` for what uninstalling ``version`` drops. Uncached.

    Raises ``ValueError`` when ``catalog`` is not a plain identifier. Never
    raises for a workspace or SQL failure: what could not be read is reported
    as unknown, with a reason, which callers treat as holding data.
    """
    _sql.safe_identifier(catalog)
    deadline = time.monotonic() + budget_s
    reasons: list[str] = []
    installed = installed_catalogs(session, version)
    recorded_here = catalog in {c.strip().lower() for c in installed}

    installed_style = (latest_install_widgets(session, version.id, catalog) or {}).get(
        "cataloging_style"
    )
    for style in (cataloging_style, installed_style):
        if not _is_one_catalog(style):
            reasons.append(
                f"This version uses {_style_label(style)}, so its schemas are in other "
                f"catalogs. This check reads only {catalog}."
            )
            break

    candidates = uninstall_schema_candidates(session, version.id, version.scope, catalog)
    try:
        listed = {s.name: s for s in ws.schemas.list(catalog_name=catalog) if s.name}
    except Exception as exc:  # noqa: BLE001 - an unreadable catalog is reported as unknown
        logger.warning("uninstall impact: could not list schemas in %r: %s", catalog, exc)
        reasons.append(f"The schemas in {catalog} could not be listed.")
        return _result(version.id, catalog, installed, [], reasons, truncated=True)

    by_lower = {name.lower(): name for name in listed}
    found: list[str] = []
    domains = [g for g in candidates if g.domain]
    domains_missing = 0
    for group in candidates:
        present = [by_lower[f] for f in group.forms if f in by_lower and f != METRICS_SCHEMA]
        if group.domain and not present:
            domains_missing += 1
        found.extend(n for n in present if n not in found)
    if recorded_here:
        if not domains:
            reasons.append(
                f"The app records this version as installed in {catalog}, but has no "
                "schema names for it."
            )
        elif domains_missing:
            reasons.append(
                f"The app records this version as installed in {catalog}, but "
                f"{domains_missing} of {len(domains)} domain schemas were not found under "
                "the names the app expects."
            )
    targets = sorted(found)
    metrics = by_lower.get(METRICS_SCHEMA)
    if metrics is not None:
        targets.append(metrics)

    schemas = {
        name: UninstallImpactSchemaOut(
            name=name,
            owner=getattr(listed[name], "owner", None) or "",
            shared=name.lower() == METRICS_SCHEMA,
        )
        for name in targets
    }
    if metrics is not None:
        schemas[metrics].other_versions = other_versions_installed_in(session, version, catalog)
    if not targets:
        return _result(version.id, catalog, installed, [], reasons)
    truncated, has_data = scan_schemas(ws, warehouse_id, catalog, schemas, reasons, deadline)
    return _result(
        version.id, catalog, installed, list(schemas.values()), reasons,
        truncated=truncated, has_data=has_data,
    )


def schema_set_impact(
    ws: Any,
    warehouse_id: str,
    catalog: str,
    names: list[str],
    *,
    owners: Optional[dict[str, str]] = None,
) -> UninstallImpactOut:
    """What dropping the schemas ``names`` (as listed in ``catalog``)
    deletes, in the uninstall-impact shape with no version
    (``version_id`` ``""``, no ``installed_catalogs``). Uncached; same bounds
    and verdict as :func:`compute_uninstall_impact`. Raises ``ValueError``
    when ``catalog`` is not a plain identifier."""
    _sql.safe_identifier(catalog)
    deadline = time.monotonic() + IMPACT_BUDGET_S
    reasons: list[str] = []
    schemas = {
        name: UninstallImpactSchemaOut(name=name, owner=(owners or {}).get(name, ""))
        for name in sorted(dict.fromkeys(names))
    }
    if not schemas:
        return _result("", catalog, [], [], reasons)
    truncated, has_data = scan_schemas(ws, warehouse_id, catalog, schemas, reasons, deadline)
    return _result(
        "", catalog, [], list(schemas.values()), reasons, truncated=truncated, has_data=has_data,
    )


def scan_schemas(
    ws: Any,
    warehouse_id: str,
    catalog: str,
    schemas: dict[str, UninstallImpactSchemaOut],
    reasons: list[str],
    deadline: float,
) -> tuple[bool, Optional[str]]:
    """Fill ``schemas`` (by name, as listed in the catalog) with their tables,
    views and volumes and check which tables hold rows, within ``deadline``.
    Appends to ``reasons`` what could not be read. Returns ``(truncated,
    has_data)`` for :func:`_result`: ``has_data`` is ``"yes"`` when a table
    holds a row, else None (the verdict then follows the reasons)."""

    def _unlisted(reason: str) -> tuple[bool, Optional[str]]:
        for out in schemas.values():
            out.objects_listed = False
        reasons.append(reason)
        return True, None

    if not warehouse_id:
        logger.warning("uninstall impact: no SQL warehouse configured; tables of %r unknown", catalog)
        return _unlisted("No SQL warehouse is configured, so the tables in these schemas could not be listed.")

    objects = _list_objects(ws, warehouse_id, catalog, list(schemas), deadline)
    if objects is None:
        return _unlisted("The tables, views and volumes in these schemas could not be listed.")
    rows, truncated = objects
    if truncated:
        reasons.append(f"More than {LISTING_ROW_CAP} objects: only the first ones are listed.")

    schema_of = {name.lower(): name for name in schemas}
    base_tables: list[tuple[str, str, str]] = []
    for schema, name, kind in rows:
        schema = schema_of.get(schema.lower(), schema)
        target = schemas.get(schema)
        if target is None:
            continue
        if kind == _VOLUME_KIND:
            target.volumes.append(name)
        elif kind in VIEW_KINDS:
            target.views.append(name)
        else:
            base_tables.append((schema, name, kind))

    checked, check_truncated = _check_data(ws, warehouse_id, catalog, base_tables, deadline)
    truncated = truncated or check_truncated
    for (schema, name, kind), has_data in zip(base_tables, checked):
        schemas[schema].tables.append(
            UninstallImpactTableOut(name=name, kind=kind, has_data=has_data)
        )

    unchecked = sum(1 for v in checked if v is None)
    if unchecked:
        reasons.append(f"{unchecked} of {len(checked)} tables could not be checked for rows.")
    volumes = sum(len(out.volumes) for out in schemas.values())
    if volumes:
        reasons.append(
            f"{volumes} volume{'s' if volumes != 1 else ''} will be dropped; "
            "the files in volumes are not checked."
        )
    return truncated, ("yes" if any(v is True for v in checked) else None)


def _result(
    version_id: str,
    catalog: str,
    installed: list[str],
    schemas: list[UninstallImpactSchemaOut],
    reasons: list[str],
    *,
    truncated: bool = False,
    has_data: Optional[str] = None,
) -> UninstallImpactOut:
    """``has_data`` is ``yes`` when given, else ``unknown`` when anything could
    not be read (a reason or truncation), else ``no``."""
    verdict = has_data or ("unknown" if reasons or truncated else "no")
    return UninstallImpactOut(
        version_id=version_id,
        catalog=catalog,
        schemas=schemas,
        has_data=verdict,
        truncated=truncated,
        reasons=reasons,
        installed_catalogs=installed,
    )


def _remaining(deadline: float) -> float:
    return deadline - time.monotonic()


def _list_objects(
    ws: Any, warehouse_id: str, catalog: str, schemas: list[str], deadline: float,
) -> Optional[tuple[list[tuple[str, str, str]], bool]]:
    """``(schema, name, kind)`` of every table, view and volume in ``schemas``,
    sorted, and whether the listing hit :data:`LISTING_ROW_CAP`. ``None``
    when the statement failed or there was no time to run it."""
    remaining = _remaining(deadline)
    if remaining < _MIN_STATEMENT_S:
        return None
    cat = _sql.safe_identifier(catalog)
    params = {f"s{i}": s for i, s in enumerate(schemas)}
    in_list = ", ".join(f":{k}" for k in params)
    sql = (
        f"SELECT * FROM ("
        f"SELECT table_schema, table_name, table_type FROM {cat}.information_schema.tables "
        f"WHERE table_schema IN ({in_list}) "
        f"UNION ALL "
        f"SELECT volume_schema, volume_name, '{_VOLUME_KIND}' FROM {cat}.information_schema.volumes "
        f"WHERE volume_schema IN ({in_list})"
        f") LIMIT {LISTING_ROW_CAP + 1}"
    )
    try:
        data = _sql.rows(
            ws, warehouse_id, sql, params, timeout_s=remaining, poll_interval_s=_POLL_INTERVAL_S,
        )
    except _sql.SqlStatementError as exc:
        logger.warning("uninstall impact: listing objects in %r failed: %s", catalog, exc)
        return None
    out = sorted(
        (str(r[0] or ""), str(r[1] or ""), str(r[2] or "").upper()) for r in (data or [])
    )
    if len(out) > LISTING_ROW_CAP:
        return out[:LISTING_ROW_CAP], True
    return out, False


def _check_data(
    ws: Any, warehouse_id: str, catalog: str, tables: list[tuple[str, str, str]], deadline: float,
) -> tuple[list[Optional[bool]], bool]:
    """Per table in ``tables``: True (has a row), False (empty) or None (not
    checked). The flag is True when the cap or the budget left tables out."""
    result: list[Optional[bool]] = [None] * len(tables)
    truncated = len(tables) > DATA_CHECK_TABLE_CAP
    queryable: list[tuple[int, str]] = []
    for i, (schema, name, _kind) in enumerate(tables[:DATA_CHECK_TABLE_CAP]):
        try:
            ref = ".".join(_sql.safe_identifier(p) for p in (catalog, schema, name))
        except ValueError:
            continue
        queryable.append((i, ref))

    for start in range(0, len(queryable), DATA_CHECK_CHUNK):
        chunk = queryable[start:start + DATA_CHECK_CHUNK]
        remaining = _remaining(deadline)
        if remaining < _MIN_STATEMENT_S:
            truncated = True
            break
        sql = " UNION ALL ".join(
            f"SELECT {i} AS i, (SELECT COUNT(*) FROM (SELECT 1 FROM {ref} LIMIT 1)) AS n"
            for i, ref in chunk
        )
        try:
            data = _sql.rows(
                ws, warehouse_id, sql, timeout_s=remaining, poll_interval_s=_POLL_INTERVAL_S,
            )
        except _sql.SqlStatementError as exc:
            logger.warning(
                "uninstall impact: data check of %d table(s) in %r failed: %s",
                len(chunk), catalog, exc,
            )
            if exc.state in ("TIMEOUT", "STILL_RUNNING"):
                truncated = True
                break
            continue
        wanted = {i for i, _ in chunk}
        for row in data or []:
            try:
                i, n = int(row[0]), int(row[1])
            except (TypeError, ValueError, IndexError):
                continue
            if i in wanted:
                result[i] = n > 0
    return result, truncated
