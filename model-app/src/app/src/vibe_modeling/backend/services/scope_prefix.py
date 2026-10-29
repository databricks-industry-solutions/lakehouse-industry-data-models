"""The scope prefix a model gets when the app brings it in.

Every model the app imports is an ECM or an MVM. A model without a schema
prefix gets its scope's (``ecm_`` / ``mvm_``), on its schemas and on its
metric view names, so the ECM and MVM of one industry or business never
share schema or view names in a catalog. The app rewrites its own copy of
the model.json once, before the Lakebase sync and the ``_metamodel`` seed;
the user's file is never changed. Agent output is kept as the agent wrote
it (only :func:`stamp_scope`).

- :func:`import_schema_prefix` - the one rule for the schema prefix an
  import uses: ``None`` keeps the file's, a blank file prefix becomes the
  scope default. The single hook for a later "let users choose".
- :func:`file_schema_prefix` - the file's ``model_conventions.schema_prefix``.
- :func:`apply_import_prefix` - rewrite a model.json in place: conventions,
  every domain's ``database_name``, every metric view ``source:`` schema
  (main source and joins), every metric view name and its ``CREATE VIEW``
  header. Idempotent. Returns a :class:`PrefixReport`.
- :func:`strip_import_prefix` / :func:`strip_import_prefix_sql` - the exact
  reverse, for publishing to the industry repository: only names that start
  with the recorded marker change, and none whose stripped name is already
  taken. :func:`schema_strip_map` and :func:`metric_view_names` give the
  names a strip works from.
- :func:`apply_import_prefix_to_rows` - the Lakebase side (``Domain`` rows).
- :func:`stamp_scope` - ``model.version = v<N>_<scope>``.

What the agent does with these names:

- the install creates each domain schema from ``database_name``
  (nb 104090-104098) and creates metric views from their SQL with only the
  catalog swapped (``replace_catalog_in_sql``, nb 50406-50416; the catalog
  comes from the ``CREATE VIEW`` header, nb 50418-50430), so a ``source:``
  left on an old schema would point at a schema the install never made;
- a metric view names its main table in ``source:`` and each join in a
  nested ``source:`` line (``_emit_mv_joins_yaml``, nb 47066-47102);
- the view name lives only in ``view_name`` and the header.
"""

from __future__ import annotations

import json
import logging
import re
from dataclasses import dataclass, field
from typing import Any, Iterable, Optional

from sqlmodel import Session, select

from ..db_models import Domain
from ..import_model import model_conventions, model_payload
from .schema_names import agent_snake_case, physical_schema_name, scope_schema_prefix

logger = logging.getLogger(__name__)


@dataclass
class PrefixReport:
    """What :func:`apply_import_prefix` changed.

    ``schema_prefix_added`` / ``view_prefix_added`` are the markers the
    version records (``""`` when nothing was added). ``views`` maps each
    renamed view to its new name. ``warnings`` name the metric views whose
    ``source:`` was left as is.
    """

    schema_prefix_added: str = ""
    view_prefix_added: str = ""
    views: dict[str, str] = field(default_factory=dict)
    warnings: list[str] = field(default_factory=list)


def import_schema_prefix(scope: str, file_prefix: Optional[str]) -> Optional[str]:
    """The schema prefix an imported copy of ``scope`` uses, or ``None`` to
    keep the file's.

    ``file_prefix`` is the file's ``model_conventions.schema_prefix``
    (:func:`file_schema_prefix`; ``None`` when there is no file to read). A
    blank one becomes the scope default (``ecm_`` / ``mvm_``); a non-blank
    one is kept.
    """
    if file_prefix is None or file_prefix:
        return None
    return scope_schema_prefix(scope)


def file_schema_prefix(root: Any) -> Optional[str]:
    """The model.json's ``model_conventions.schema_prefix`` (``""`` when the
    conventions name none), or ``None`` when ``root`` is not a model.json
    dict. Read where the agent reads it (``model``, else the flat root)."""
    if not isinstance(root, dict):
        return None
    conventions = model_conventions(root) or {}
    return str(conventions.get("schema_prefix") or "")


def stamp_scope(root: Any, version_int: int, scope: str) -> Any:
    """Set ``model.version`` to ``v<version_int>_<scope>``: the scope the
    agent reads at install (the ``_ecm`` / ``_mvm`` suffix, nb 103450-103462)
    and the version the app gave the copy. Returns ``root``."""
    if isinstance(root, dict):
        model_payload(root)["version"] = f"v{int(version_int)}_{scope}"
    return root


# --- names in metric view SQL -------------------------------------------------

_SOURCE_LINE = re.compile(r'(?m)^(\s*(?:-\s*)?source:\s*"?)([^"\n]+)')
_PART = r'(?:`[^`]+`|[^.`\s"]+)'
_THREE_PART = re.compile(rf"({_PART})\.({_PART})\.({_PART})")
_VIEW_HEADER = re.compile(
    r"(?i)(CREATE\s+(?:OR\s+REPLACE\s+)?(?:MATERIALIZED\s+)?VIEW\s+(?:IF\s+NOT\s+EXISTS\s+)?"
    rf"{_PART}\.{_PART}\.)({_PART})"
)


def _bare(part: str) -> str:
    return part[1:-1] if part.startswith("`") and part.endswith("`") else part


def _quoted_like(original: str, name: str) -> str:
    return f"`{name}`" if original.startswith("`") else name


def _rename_sources(sql: str, schemas: dict[str, str]) -> tuple[str, bool]:
    """``sql`` with every ``source:`` schema found in ``schemas`` (lower-case
    keys) renamed, and whether every source line was one it understood."""
    understood = True

    def _one(m: re.Match) -> str:
        nonlocal understood
        value = m.group(2).rstrip()
        parts = _THREE_PART.fullmatch(value.strip())
        if parts is None:
            understood = False
            return m.group(0)
        catalog, schema, table = parts.groups()
        new = schemas.get(_bare(schema).lower())
        if new is None:
            understood = False
            return m.group(0)
        trailing = m.group(2)[len(value):]
        lead = value[: len(value) - len(value.lstrip())]
        return f"{m.group(1)}{lead}{catalog}.{_quoted_like(schema, new)}.{table}{trailing}"

    return _SOURCE_LINE.sub(_one, sql), understood


def _rename_view_headers(sql: str, rename) -> str:
    """``sql`` with the view name of every ``CREATE VIEW`` header passed
    through ``rename`` (bare name in, bare name out)."""

    def _one(m: re.Match) -> str:
        part = m.group(2)
        return f"{m.group(1)}{_quoted_like(part, rename(_bare(part)))}"

    return _VIEW_HEADER.sub(_one, sql)


# --- conventions ----------------------------------------------------------------


def _holders(root: dict) -> list[dict]:
    """The dicts that carry a model (``domains`` / ``metric_views``) in the
    agent's reading order: ``model``, ``business_context``, the flat root."""
    out = [h for h in (root.get("model"), root.get("business_context")) if isinstance(h, dict)]
    if isinstance(root.get("domains"), list):
        out.append(root)
    return out


def _set_conventions_prefix(holder: dict, prefix: str, *, only_if: Optional[str] = None) -> None:
    """Set ``holder.model_conventions.schema_prefix``; a JSON-string block
    stays a string. With ``only_if``, only when the current value equals it."""
    conventions = holder.get("model_conventions")
    if isinstance(conventions, str):
        try:
            parsed = json.loads(conventions) if conventions.strip() else {}
        except ValueError:
            return
        if not isinstance(parsed, dict):
            return
        if only_if is not None and str(parsed.get("schema_prefix") or "") != only_if:
            return
        holder["model_conventions"] = json.dumps({**parsed, "schema_prefix": prefix})
    elif isinstance(conventions, dict):
        if only_if is not None and str(conventions.get("schema_prefix") or "") != only_if:
            return
        conventions["schema_prefix"] = prefix


def _prefixed_database_name(database_name: str, prefix: str, domain_name: str) -> str:
    """A domain's ``database_name`` with ``prefix``: kept when it already
    starts with it, any schema suffix on it kept
    (:func:`schema_names.physical_schema_name`); from the snake-cased domain
    name when nothing is stored."""
    base = database_name or agent_snake_case(domain_name)
    return physical_schema_name(base, prefix) or database_name


# --- metric views -----------------------------------------------------------------


def _rename_views(holder: dict, rename, sources=None) -> dict[str, str]:
    """Rename every metric view of ``holder`` with ``rename`` (bare name in,
    bare name out): its ``view_name`` and each ``CREATE VIEW`` header of its
    SQL. ``sources``, when given, is applied to each view's SQL first as
    ``sources(sql, label) -> sql``. Both shapes the agent writes: a list of
    ``{view_name, sql}`` and the legacy ``{view_name: sql}`` dict (rebuilt in
    the same order). Returns ``old -> new`` for each renamed view."""
    renamed: dict[str, str] = {}

    def _sql(sql: str, label: str) -> str:
        if sources is not None:
            sql = sources(sql, label)
        return _rename_view_headers(sql, rename)

    views = holder.get("metric_views")
    if isinstance(views, list):
        for view in views:
            if not (isinstance(view, dict) and isinstance(view.get("sql"), str)):
                continue
            old = str(view.get("view_name") or "")
            view["sql"] = _sql(view["sql"], old)
            if old and rename(old) != old:
                view["view_name"] = renamed[old] = rename(old)
    elif isinstance(views, dict):
        rebuilt: dict[str, Any] = {}
        for old, sql in views.items():
            if not isinstance(sql, str):
                rebuilt[old] = sql
                continue
            new = rename(old)
            if new != old:
                renamed[old] = new
            rebuilt[new] = _sql(sql, old)
        holder["metric_views"] = rebuilt
    return renamed


# --- apply / strip ----------------------------------------------------------------


def apply_import_prefix(root: Any, scope: str, schema_prefix: Optional[str]) -> PrefixReport:
    """Rewrite ``root`` (an agent model.json, changed in place) for an import
    of ``scope`` with ``schema_prefix`` (:func:`import_schema_prefix`).

    - ``schema_prefix`` set: every conventions holder (``model``,
      ``business_context``, the flat root, ``model_requirements``) gets it; every
      domain's ``database_name`` gets it (:func:`_prefixed_database_name`);
      every metric view ``source:`` schema that names a domain follows its
      domain. A source that cannot be parsed, or names another schema, is
      left as is with one warning naming the view.
    - ``None``: schemas and sources are kept.
    - Always: every metric view name gets ``<scope>_`` unless it already has
      it, and every ``CREATE VIEW`` header of its SQL is renamed the same way.

    Running it twice changes nothing more.
    """
    report = PrefixReport()
    if not isinstance(root, dict):
        return report
    view_prefix = scope_schema_prefix(scope)

    def _with_view_prefix(name: str) -> str:
        return name if name.lower().startswith(view_prefix) else f"{view_prefix}{name}"

    holders = _holders(root)
    if schema_prefix:
        report.schema_prefix_added = schema_prefix
        # The prefix is recorded where the agent reads it, a block created
        # when the file has none (its install then sends this prefix).
        primary = model_payload(root)
        if not isinstance(primary.get("model_conventions"), (dict, str)):
            primary["model_conventions"] = {}
        for holder in holders + [h for h in [root.get("model_requirements")] if isinstance(h, dict)]:
            _set_conventions_prefix(holder, schema_prefix)
    for holder in holders:
        schemas: dict[str, str] = {}
        if schema_prefix:
            for domain in holder.get("domains") or []:
                if not isinstance(domain, dict):
                    continue
                old = str(domain.get("database_name") or "")
                name = str(domain.get("name") or "")
                new = _prefixed_database_name(old, schema_prefix, name)
                domain["database_name"] = new
                for key in (old, agent_snake_case(name), new):
                    if key:
                        schemas[key.lower()] = new
        def _sources(sql: str, label: str, schemas=schemas) -> str:
            if not schema_prefix:
                return sql
            sql, understood = _rename_sources(sql, schemas)
            if not understood:
                message = f"Metric view {label!r}: a source names no domain of this model; left as is."
                logger.warning("scope_prefix: %s", message)
                report.warnings.append(message)
            return sql

        report.views.update(_rename_views(holder, _with_view_prefix, _sources))
    if report.views:
        report.view_prefix_added = view_prefix
    return report


def schema_strip_map(database_names: Iterable[str], schema_prefix_added: Optional[str]) -> dict[str, str]:
    """``prefixed -> original`` (lower-case keys) for each of
    ``database_names`` that starts with ``schema_prefix_added``. A name whose
    stripped form is already one of ``database_names`` keeps its prefix, so a
    strip never makes two schemas share a name."""
    marker = (schema_prefix_added or "").lower()
    names = [str(n) for n in database_names if n]
    if not marker:
        return {}
    taken = {n.lower() for n in names}
    out: dict[str, str] = {}
    for name in names:
        stripped = name[len(marker):]
        if name.lower().startswith(marker) and stripped and stripped.lower() not in taken:
            out[name.lower()] = stripped
    return out


def _strip_map(root: dict, schema_prefix_added: str) -> dict[str, str]:
    """:func:`schema_strip_map` over every ``database_name`` in ``root``."""
    return schema_strip_map(
        (
            str(domain.get("database_name") or "")
            for holder in _holders(root)
            for domain in holder.get("domains") or []
            if isinstance(domain, dict)
        ),
        schema_prefix_added,
    )


def metric_view_names(root: Any) -> list[str]:
    """Every metric view name in a model.json (both shapes the agent writes)."""
    if not isinstance(root, dict):
        return []
    out: list[str] = []
    for holder in _holders(root):
        views = holder.get("metric_views")
        if isinstance(views, list):
            out.extend(str(v.get("view_name") or "") for v in views if isinstance(v, dict))
        elif isinstance(views, dict):
            out.extend(str(k) for k in views)
    return [n for n in out if n]


def _view_stripper(view_prefix_added: str, view_names: Iterable[str]):
    """Strip the view marker from a name, unless the stripped name is already
    one of ``view_names`` (it would replace that view)."""
    marker = (view_prefix_added or "").lower()
    taken = {n.lower() for n in view_names}

    def _strip(name: str) -> str:
        stripped = name[len(marker):]
        if marker and name.lower().startswith(marker) and stripped and stripped.lower() not in taken:
            return stripped
        return name

    return _strip


def strip_import_prefix(
    root: Any,
    schema_prefix_added: Optional[str],
    view_prefix_added: Optional[str],
    schema_map: Optional[dict[str, str]] = None,
    view_names: Optional[Iterable[str]] = None,
) -> Any:
    """The reverse of :func:`apply_import_prefix` for the markers a version
    recorded. Changes ``root`` in place and returns it.

    Only names that start with a marker change: ``database_name`` values in
    ``schema_map`` (``prefixed -> original``, lower-case keys; built from
    ``root``'s domains with :func:`schema_strip_map` when ``None``), the
    conventions' ``schema_prefix`` when it equals the schema marker,
    ``source:`` schemas in the map, and view names and ``CREATE VIEW``
    headers that start with the view marker. A view keeps its prefix when
    its stripped name is one of ``view_names`` (``root``'s own when ``None``).
    """
    if not isinstance(root, dict):
        return root
    schema_marker = schema_prefix_added or ""
    if schema_map is None:
        schema_map = _strip_map(root, schema_marker)
    schema_map = {k.lower(): v for k, v in schema_map.items()}
    strip_view = _view_stripper(
        view_prefix_added or "", metric_view_names(root) if view_names is None else view_names
    )
    holders = _holders(root)
    if schema_marker:
        for holder in holders + [h for h in [root.get("model_requirements")] if isinstance(h, dict)]:
            _set_conventions_prefix(holder, "", only_if=schema_marker)
    for holder in holders:
        for domain in holder.get("domains") or []:
            if isinstance(domain, dict):
                name = str(domain.get("database_name") or "")
                if name.lower() in schema_map:
                    domain["database_name"] = schema_map[name.lower()]
        _rename_views(
            holder, strip_view,
            (lambda sql, _label: _rename_sources(sql, schema_map)[0]) if schema_map else None,
        )
    return root


_SQL_ID = r"(?:`[^`\n]+`|[A-Za-z_]\w*)"
# ``catalog.schema`` or ``catalog.schema.table``, not part of a longer chain.
_SQL_REF = re.compile(rf"(?<![\w`.])({_SQL_ID})\.({_SQL_ID})((?:\.{_SQL_ID})?)(?![\w`]|\.[\w`])")
# A one-part schema name after the statements that name a schema.
_SQL_SCHEMA_STMT = re.compile(
    rf"(?i)\b((?:CREATE|ALTER|DROP)\s+(?:DATABASE|SCHEMA)\s+(?:IF\s+(?:NOT\s+)?EXISTS\s+)?|USE\s+(?:SCHEMA\s+|DATABASE\s+)?)"
    rf"({_SQL_ID})(?![\w`.])"
)


def _rename_sql_schemas(sql: str, schemas: dict[str, str]) -> str:
    """``sql`` with the schema of every ``catalog.schema[.table]`` reference
    (backticked or bare) and every one-part ``CREATE / ALTER / DROP
    DATABASE|SCHEMA`` / ``USE`` name renamed when it is a key of ``schemas``
    (lower-case keys, exact name)."""

    def _ref(m: re.Match) -> str:
        new = schemas.get(_bare(m.group(2)).lower())
        if new is None:
            return m.group(0)
        return f"{m.group(1)}.{_quoted_like(m.group(2), new)}{m.group(3)}"

    def _stmt(m: re.Match) -> str:
        new = schemas.get(_bare(m.group(2)).lower())
        return m.group(0) if new is None else f"{m.group(1)}{_quoted_like(m.group(2), new)}"

    return _SQL_SCHEMA_STMT.sub(_stmt, _SQL_REF.sub(_ref, sql))


def strip_import_prefix_sql(
    text: str,
    schema_map: dict[str, str],
    view_prefix_added: Optional[str],
    view_names: Iterable[str] = (),
) -> str:
    """:func:`strip_import_prefix` for a companion ``.sql`` file (metric
    views and the schema DDL): every schema in ``schema_map`` named in a
    ``source:`` line, a ``catalog.schema[.table]`` reference or a
    ``CREATE DATABASE|SCHEMA`` statement, and ``CREATE VIEW`` names that
    start with the view marker, unless the stripped name is one of
    ``view_names`` (the model's views) or of the file's own ``CREATE VIEW``
    names."""
    schema_map = {k.lower(): v for k, v in (schema_map or {}).items()}
    if schema_map:
        text = _rename_sql_schemas(_rename_sources(text, schema_map)[0], schema_map)
    taken = [*view_names, *(_bare(m.group(2)) for m in _VIEW_HEADER.finditer(text))]
    return _rename_view_headers(text, _view_stripper(view_prefix_added or "", taken))


def apply_import_prefix_to_rows(session: Session, version_id: str, prefix: str) -> None:
    """The Lakebase side of :func:`apply_import_prefix`: every ``Domain`` row
    of ``version_id`` gets the same ``database_name``."""
    for domain in session.exec(select(Domain).where(Domain.version_id == version_id)).all():
        domain.database_name = _prefixed_database_name(domain.database_name or "", prefix, domain.name or "")
        session.add(domain)


__all__ = [
    "PrefixReport",
    "apply_import_prefix",
    "apply_import_prefix_to_rows",
    "file_schema_prefix",
    "import_schema_prefix",
    "metric_view_names",
    "schema_strip_map",
    "stamp_scope",
    "strip_import_prefix",
    "strip_import_prefix_sql",
]
