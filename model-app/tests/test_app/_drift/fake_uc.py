"""A recording fake of the Unity Catalog side the app reads and writes.

Per catalog it holds:

- the agent's ``_metamodel`` registry tables (``business``, ``domain``,
  ``product``, ``attribute``) as rows. Each writer seam stores its writer's
  column list in its order, with the values that writer emits, as strings
  (``None`` for SQL ``NULL``), the way a warehouse returns them;
- Volume files under ``/Volumes/...`` (directories are implied by file paths
  or created explicitly);
- schemas with their table names and volumes.

Two ways in:

- **The app's seams.** :meth:`FakeUC.patched` replaces
  ``ModelSyncService.write_model_to_delta``, ``delete_metamodel_rows`` and
  ``_query_delta_table`` (the Delta read under ``load_model_from_delta_tables``),
  ``InitialSyncService._query_businesses`` and ``_query_dry_run_keys``,
  ``OobDetector._query_completed_versions`` and every module binding of
  ``seed_metamodel_one`` and of ``metamodel_registry.set_deploy_status``. Each replacement keeps the real method's guards and
  matching rules: ``LOWER(business) = LOWER(<name>)``, the query's version
  stripped of a leading ``v`` and compared to the stored value as is, the
  short scope compared exactly, ``NULL`` matching nothing. A caller that passes
  the wrong business string, version or catalog misses the rows as it would
  against a warehouse. ``test_drift_foundation.TestMatchingFidelity`` runs the
  real SQL's WHERE clauses in SQLite against the same rows to keep this true.
- **A fake ``WorkspaceClient``** (:attr:`FakeUC.ws`): ``files``, ``schemas``,
  ``tables``, ``volumes`` and ``catalogs`` (``list``, ``get``) act on the stored state;
  ``statement_execution`` runs the registry DDL ``metamodel_registry.ensure_metamodel_registry``
  issues (``CREATE TABLE IF NOT EXISTS``, ``ALTER TABLE ... ADD COLUMN``,
  ``DESCRIBE TABLE`` on a ``_metamodel`` registry table, recorded as ``sql.ddl``)
  and the run pre-flight's parent ``COUNT(*)`` on ``business`` (``sql.parent_count``),
  and raises :class:`UnrecordedSQLError` on any other statement, so a write
  that bypasses the seams fails loudly. :attr:`FakeUC.ddl_error` makes the DDL
  fail (a warehouse answering FAILED).

The registry tables carry their columns: :meth:`FakeUC.add_metamodel` gives
them the agent's (``metamodel_registry_schema.json``), and ``tables.get``
returns them. The fake seeds (``seed_metamodel_one`` and
``write_model_to_delta``) run the real ``ensure_metamodel_registry`` first, as
the real writers do, so a catalog with no registry gets one from the seed.

Calls to the seams and to the fake ``files``, ``schemas``, ``tables``,
``volumes``, ``catalogs`` and ``statement_execution`` APIs are appended to
:attr:`FakeUC.calls`. Every other ``ws`` attribute (``jobs``, ``grants``,
``permissions``, ``api_client``, ``config``, ``current_user``) falls through to
a ``MagicMock``: those calls are neither recorded nor refused, so a test that
cares about them asserts on the mock (``fake.ws.jobs.run_now.assert_called...``).

:meth:`FakeUC.patched` patches the ``seed_metamodel_one`` binding of every
already imported ``vibe_modeling`` module. On exit it restores every
``vibe_modeling`` module binding of the fake, including one a module took when
it was first imported inside the block. A module outside ``vibe_modeling``
(a test module) that binds ``seed_metamodel_one`` inside the block keeps the
fake.
"""
from __future__ import annotations

import io
import json
import re
import sys
from contextlib import ExitStack, contextmanager
from dataclasses import dataclass, field
from types import SimpleNamespace
from typing import Any, Callable, Iterator, Optional
from unittest.mock import MagicMock, patch

from databricks.sdk.errors import AlreadyExists, BadRequest, NotFound, ResourceAlreadyExists
from databricks.sdk.service.catalog import CatalogInfo, ColumnInfo, SchemaInfo, TableInfo, VolumeInfo
from databricks.sdk.service.files import DirectoryEntry, DownloadResponse, GetMetadataResponse

from vibe_modeling.backend.core._names import metamodel_display_business, normalize_scope
from vibe_modeling.backend.core._paths import version_dir_candidates
from vibe_modeling.backend._query_helpers import metamodel_row_key
from vibe_modeling.backend.import_model import model_payload as unwrap_model_payload
from vibe_modeling.backend.initial_sync import InitialSyncService
from vibe_modeling.backend.model_sync import ModelSyncService
from vibe_modeling.backend.oob_detector import OobDetector
from vibe_modeling.backend.services import (  # noqa: F401 - loaded so their bindings get patched
    import_metamodel_writer,
    industry_download,
    industry_kickstart,
    metamodel_registry,
)
from vibe_modeling.backend.services.operations import uninstall as _uninstall  # noqa: F401 - binds set_deploy_status
from vibe_modeling.backend.services.import_metamodel_writer import _conventions_to_json
from vibe_modeling.backend.services.metamodel_registry import ensure_metamodel_registry, registry_schema
from vibe_modeling.backend.services.metamodel_setup import MetamodelSetupError

METAMODEL_SCHEMA = "_metamodel"
VOL_ROOT = "vol_root"
REGISTRY_TABLES = ("business", "domain", "product", "attribute")
TABLE_NOT_FOUND = "TABLE_OR_VIEW_NOT_FOUND"
DEFAULT_HOST = "https://test-workspace.databricks.com"
FAKE_NOW = "2024-01-01 00:00:00.000000"
"""What the fake stores where a writer emits the current time."""

IMPORT_WRITER_COLUMNS = {
    "business": (
        "business", "version", "model_scope", "industry_alignment", "description", "catalog",
        "location", "core_business_processes", "orgnaization_divisions", "data_domains",
        "common_business_jargons", "operational_systems_of_records", "industry_governing_body",
        "vibe_modelling_instructions", "model_conventions", "completion_date", "session_id",
        "processing_status", "completed_percent", "session_started_at", "last_updated_at",
        "session_json", "results_json", "deploy_status",
    ),
    "domain": (
        "business", "version", "model_scope", "domain", "division", "description",
        "database_name", "catalog", "reference", "tags",
    ),
    "product": (
        "business", "version", "model_scope", "domain", "subdomain", "product", "description",
        "type", "division", "function", "data_type", "source_domains", "association_edges",
        "primary_key", "reference", "table_name", "sample_path", "tags",
    ),
    "attribute": (
        "business", "version", "model_scope", "domain", "product", "attribute", "column_name",
        "type", "tags", "value_regex", "foreign_key_to", "business_glossary_term", "description",
        "reference",
    ),
}
"""``write_metamodel``'s INSERT column lists, in order."""

DELTA_WRITER_COLUMNS = {
    "business": (
        "business", "version", "model_scope", "description", "industry_alignment", "catalog",
        "location", "completion_date", "processing_status", "completed_percent",
        "session_started_at", "last_updated_at",
    ),
    "domain": IMPORT_WRITER_COLUMNS["domain"],
    "product": IMPORT_WRITER_COLUMNS["product"],
    "attribute": IMPORT_WRITER_COLUMNS["attribute"],
}
"""``ModelSyncService.write_model_to_delta``'s INSERT column lists, in order."""


def agent_registry_columns(table: str) -> list[tuple[str, str]]:
    """The columns the agent leaves on a registry table after its first run:
    the ``TABLE_*_SCHEMA`` columns, plus the business migration columns."""
    schema = registry_schema()
    cols = list(schema.tables[table])
    if table == "business":
        names = {c for c, _ in cols}
        cols += [(c, t) for c, t in schema.business_migration_columns if c not in names]
    return cols


class UnrecordedSQLError(RuntimeError):
    """SQL reached ``ws.statement_execution``: no seam covers that write or read."""


@dataclass(frozen=True)
class Call:
    """One recorded call: ``seam`` names the method, ``args`` its arguments."""

    seam: str
    args: dict


@dataclass(frozen=True)
class RegistryKey:
    """Where a version's registry rows live and how a reader matches them.

    ``business`` is the lowercased ``business`` column, which is what the
    app's ``LOWER(business) = LOWER(...)`` filters compare. ``version`` is the
    stored value as is: a reader asking for version 2 finds ``"2"`` and not
    ``"v2"``.
    """

    catalog: str
    business: str
    version: str
    scope: str


@dataclass
class RegistryEntry:
    """The registry rows of one key, grouped."""

    key: RegistryKey
    business_values: list[Optional[str]]
    session_ids: list[Optional[str]]
    business_rows: int
    domains: int
    products: int
    attributes: int


def _bare_version(version: Any) -> str:
    """The query-side version the real readers and writers use."""
    return str(version or "").lstrip("vV") or str(version or "")


def _sql_str(v: Any) -> Optional[str]:
    """A value ``write_metamodel`` quotes with ``_sql_str``: ``None`` is NULL."""
    return None if v is None else str(v)


def _esc_str(v: Any) -> str:
    """A value ``write_model_to_delta`` quotes with ``_esc``: ``None`` is ``''``."""
    return "" if v is None else str(v)


def _joined_tags(item: dict) -> str:
    tags = item.get("tags")
    return ",".join(tags or []) if isinstance(tags, list) else (tags or "")


def _norm_path(path: str) -> str:
    return "/" + str(path).strip("/")


def _parents(path: str) -> Iterator[str]:
    parts = _norm_path(path).strip("/").split("/")
    for i in range(1, len(parts)):
        yield "/" + "/".join(parts[:i])


def _volume_of(path: str) -> Optional[tuple[str, str, str]]:
    """``(catalog, schema, volume)`` for a ``/Volumes/c/s/v/...`` path."""
    parts = _norm_path(path).strip("/").split("/")
    if len(parts) >= 4 and parts[0] == "Volumes":
        return parts[1], parts[2], parts[3]
    return None


def _as_bytes(contents: Any) -> bytes:
    if isinstance(contents, (bytes, bytearray)):
        return bytes(contents)
    if isinstance(contents, str):
        return contents.encode()
    if isinstance(contents, (dict, list)):
        return json.dumps(contents).encode()
    if hasattr(contents, "read"):
        data = contents.read()
        return data.encode() if isinstance(data, str) else bytes(data)
    raise TypeError(f"unsupported file contents {type(contents)!r}")


def _row(columns: tuple[str, ...], values: list) -> dict:
    assert len(columns) == len(values), (columns, values)
    return dict(zip(columns, values))


def import_writer_rows(
    catalog: str, *, business_name: str, scope: str, version: Any, model_json: dict,
    location: Optional[str] = None,
) -> dict[str, list[dict]]:
    """The rows ``write_metamodel`` INSERTs, per table, in its column order."""
    model = unwrap_model_payload(model_json)
    biz = metamodel_display_business(business_name) or business_name
    ver, sc = str(version), scope.lower()
    head = [_sql_str(biz), _sql_str(ver), _sql_str(sc)]
    cols = IMPORT_WRITER_COLUMNS
    rows: dict[str, list[dict]] = {t: [] for t in REGISTRY_TABLES}
    rows["business"].append(_row(cols["business"], head + [
        _sql_str(model.get("industry_alignment", "")), _sql_str(model.get("description", "")),
        _sql_str(catalog), _sql_str(model.get("location", "") if location is None else location),
        _sql_str(model.get("core_business_processes", "")), _sql_str(model.get("orgnaization_divisions", "")),
        _sql_str(model.get("data_domains", "")), _sql_str(model.get("common_business_jargons", "")),
        _sql_str(model.get("operational_systems_of_records", "")),
        _sql_str(model.get("industry_governing_body", "")),
        _sql_str(model.get("vibe_modelling_instructions", "")),
        _sql_str(_conventions_to_json(model.get("model_conventions"))),
        FAKE_NOW, "0", "done", "100.0", FAKE_NOW, FAKE_NOW, "{}", "{}", "dry_run",
    ]))
    for d in model.get("domains") or []:
        if not isinstance(d, dict):
            continue
        d_name = d.get("name", "")
        rows["domain"].append(_row(cols["domain"], head + [
            _sql_str(d_name), _sql_str(d.get("division", "")), _sql_str(d.get("description", "")),
            _sql_str(d.get("database_name", "")), _sql_str(catalog),
            _sql_str(d.get("references", "") or d.get("reference", "")), "",
        ]))
        for p in d.get("products") or []:
            if not isinstance(p, dict):
                continue
            p_name = p.get("name") or p.get("product") or ""
            rows["product"].append(_row(cols["product"], head + [
                _sql_str(d_name), _sql_str(p.get("subdomain", "")), _sql_str(p_name),
                _sql_str(p.get("description", "")), _sql_str(p.get("type", "")),
                _sql_str(p.get("division", "")), _sql_str(p.get("function", "")),
                _sql_str(p.get("data_type", "")), _sql_str(p.get("source_domains", "")),
                _sql_str(p.get("association_edges", "")), _sql_str(p.get("primary_key", "")),
                _sql_str(p.get("references", "") or p.get("reference", "")),
                _sql_str(p.get("table_name", "") or p_name), _sql_str(p.get("sample_path", "")), "",
            ]))
            for a in p.get("attributes") or []:
                if not isinstance(a, dict):
                    continue
                a_name = a.get("name") or a.get("attribute") or ""
                rows["attribute"].append(_row(cols["attribute"], head + [
                    _sql_str(d_name), _sql_str(p_name), _sql_str(a_name),
                    _sql_str(a.get("column_name", "") or a_name), _sql_str(a.get("type", "")), "",
                    _sql_str(a.get("value_regex", "")), _sql_str(a.get("foreign_key_to", "")),
                    _sql_str(a.get("business_glossary_term", "")), _sql_str(a.get("description", "")),
                    _sql_str(a.get("references", "") or a.get("reference", "")),
                ]))
    return rows


def delta_writer_rows(
    catalog: str, *, business_name: str, version: Any, model_scope: str, volume_path: str,
    model_payload: dict,
) -> dict[str, list[dict]]:
    """The rows ``ModelSyncService.write_model_to_delta`` INSERTs, per table,
    in its column order."""
    ver, sc = _bare_version(version), normalize_scope(model_scope)
    head = [_esc_str(business_name), ver, sc]
    cols = DELTA_WRITER_COLUMNS
    rows: dict[str, list[dict]] = {t: [] for t in REGISTRY_TABLES}
    rows["business"].append(_row(cols["business"], head + [
        (model_payload.get("description") or "")[:4000], model_payload.get("industry_alignment") or "",
        _esc_str(catalog), _esc_str(volume_path), FAKE_NOW, "done", "100.0", FAKE_NOW, FAKE_NOW,
    ]))
    for d in model_payload.get("domains", []) or []:
        d_name = d.get("name", "")
        rows["domain"].append(_row(cols["domain"], head + [
            _esc_str(d_name), _esc_str(d.get("division", "")), (d.get("description") or "")[:4000],
            _esc_str(d.get("database_name", "")), _esc_str(catalog),
            d.get("references") or d.get("reference") or "", _joined_tags(d),
        ]))
    for d in model_payload.get("domains", []) or []:
        d_name = d.get("name", "")
        for p in d.get("products", []):
            p_name = p.get("name") or p.get("product", "")
            rows["product"].append(_row(cols["product"], head + [
                _esc_str(d_name), _esc_str(p.get("subdomain", "")), _esc_str(p_name),
                (p.get("description") or "")[:4000], _esc_str(p.get("type", "")),
                _esc_str(p.get("division", "")), _esc_str(p.get("function", "")),
                _esc_str(p.get("data_type", "")), _esc_str(p.get("source_domains", "")),
                _esc_str(p.get("association_edges", "")), _esc_str(p.get("primary_key", "")),
                _esc_str(p.get("reference", "")), _esc_str(p.get("table_name", "")),
                _esc_str(p.get("sample_path", "")), _joined_tags(p),
            ]))
            for a in p.get("attributes", []) or []:
                rows["attribute"].append(_row(cols["attribute"], head + [
                    _esc_str(d_name), _esc_str(p_name), a.get("attribute") or a.get("name") or "",
                    _esc_str(a.get("column_name", "")), _esc_str(a.get("type", "")), _joined_tags(a),
                    _esc_str(a.get("value_regex", "")), _esc_str(a.get("foreign_key_to", "")),
                    _esc_str(a.get("business_glossary_term", "")), (a.get("description") or "")[:4000],
                    a.get("references") or a.get("reference") or "",
                ]))
    return rows


@dataclass
class _Schema:
    tables: set[str] = field(default_factory=set)
    volumes: set[str] = field(default_factory=set)


class FakeUC:
    """The UC side of one test: registry rows, Volume files, schemas."""

    def __init__(self) -> None:
        self.calls: list[Call] = []
        self.unrecorded_sql: list[str] = []
        self._registry: dict[str, dict[str, list[dict]]] = {}
        self._columns: dict[str, dict[str, list[tuple[str, str]]]] = {}
        self.ddl_error: Optional[str] = None
        self.release_error: Optional[Exception] = None
        self._files: dict[str, bytes] = {}
        self._dirs: set[str] = set()
        self._catalogs: set[str] = set()
        self._schemas: dict[str, dict[str, _Schema]] = {}
        self.ws = FakeWorkspace(self)

    # ------------------------------------------------------------------
    # Test-side setup (not recorded)
    # ------------------------------------------------------------------

    def add_catalog(self, catalog: str) -> None:
        self._catalogs.add(catalog)
        self._schemas.setdefault(catalog, {})

    def add_schema(
        self, catalog: str, schema: str, tables: tuple[str, ...] = (), volumes: tuple[str, ...] = (),
    ) -> None:
        self.add_catalog(catalog)
        state = self._schemas[catalog].setdefault(schema, _Schema())
        state.tables.update(tables)
        state.volumes.update(volumes)

    def add_metamodel(self, catalog: str, *, drop_business_columns: tuple[str, ...] = ()) -> None:
        """``<catalog>._metamodel`` with ``vol_root`` and the registry tables,
        as the agent leaves them after its first run. ``drop_business_columns``
        leaves those columns off ``business`` (a table an older agent made)."""
        self.add_schema(catalog, METAMODEL_SCHEMA, volumes=(VOL_ROOT,))
        tables = self._registry.setdefault(catalog, {})
        columns = self._columns.setdefault(catalog, {})
        for name in REGISTRY_TABLES:
            tables.setdefault(name, [])
            columns.setdefault(name, [
                (c, t) for c, t in agent_registry_columns(name)
                if not (name == "business" and c in drop_business_columns)
            ])

    def columns(self, catalog: str, table: str) -> Optional[list[tuple[str, str]]]:
        """``(column, type)`` of ``<catalog>._metamodel.<table>``; None when absent."""
        cols = self._columns.get(catalog, {}).get(table)
        return None if cols is None else list(cols)

    def add_rows(self, catalog: str, table: str, rows: list[dict]) -> None:
        """Append raw registry rows (any columns) to ``<catalog>._metamodel.<table>``."""
        self.add_metamodel(catalog)
        self._registry[catalog][table].extend(dict(r) for r in rows)

    def edit_rows(self, catalog: str, table: str, edit: Callable[[list[dict]], list[dict]]) -> None:
        """Replace the stored rows of ``<catalog>._metamodel.<table>`` with
        ``edit(copies of the rows)``. Test-side and unrecorded: the agent's own
        DELETE, UPDATE and ALTER TABLE statements, which are not app calls. A
        catalog or table that does not exist is left alone, as :meth:`rows` reads it empty."""
        tables = self._registry.get(catalog)
        if tables is not None and table in tables:
            tables[table] = [dict(r) for r in edit(self.rows(catalog, table))]

    def rows(self, catalog: str, table: str) -> list[dict]:
        """Copies of the stored rows of ``<catalog>._metamodel.<table>``."""
        return [dict(r) for r in self._registry.get(catalog, {}).get(table, [])]

    def put_file(self, path: str, contents: Any) -> str:
        """Store a file (bytes, str, or a dict/list written as JSON); creates
        its volume when the path is under ``/Volumes``."""
        path = _norm_path(path)
        vol = _volume_of(path)
        if vol:
            self.add_schema(vol[0], vol[1], volumes=(vol[2],))
        self._files[path] = _as_bytes(contents)
        return path

    def add_agent_version(
        self,
        catalog: str,
        business_name: str,
        version: int,
        scope: str,
        model: dict,
        *,
        session_id: Optional[int] = 1,
        completed: bool = True,
        completion_date: str = "2024-01-01 00:00:00",
        write_model_json: bool = True,
        deploy_status: Optional[str] = "installed",
    ) -> Optional[str]:
        """Registry rows and, by default, ``model.json`` in the nested version
        folder for one version.

        The rows have the app import writer's shape (``write_metamodel``:
        display-cased ``business``, bare version, short scope), with the
        business row's run columns set as a finished or running agent run sets
        them (``deploy_status`` ``installed`` by default, as the agent's
        install registers it, nb 51729). They are not a captured agent row shape; tests that depend on
        the agent's own columns build those from a captured real row.
        Returns the model.json path."""
        self.add_metamodel(catalog)
        rows = import_writer_rows(
            catalog, business_name=business_name, scope=normalize_scope(scope), version=version,
            model_json=model,
        )
        rows["business"][0].update(
            session_id=None if session_id is None else str(session_id),
            processing_status="done" if completed else "running",
            completed_percent="100.0" if completed else "50.0",
            completion_date=completion_date if completed else None,
            deploy_status=deploy_status,
        )
        self._append(catalog, rows)
        if not write_model_json:
            return None
        nested, _flat = version_dir_candidates(catalog, business_name, int(version), normalize_scope(scope))
        return self.put_file(f"{nested}/model.json", model)

    # ------------------------------------------------------------------
    # Reads for assertions and the checker (not recorded)
    # ------------------------------------------------------------------

    def catalogs_with_registry(self) -> list[str]:
        return sorted(self._registry)

    def registry(self, catalog: Optional[str] = None) -> list[RegistryEntry]:
        """Registry rows grouped by :class:`RegistryKey`, sorted."""
        catalogs = [catalog] if catalog is not None else self.catalogs_with_registry()
        entries: dict[RegistryKey, RegistryEntry] = {}
        for cat in catalogs:
            for table in REGISTRY_TABLES:
                for row in self._registry.get(cat, {}).get(table, []):
                    key = RegistryKey(
                        cat, str(row.get("business") or "").lower(),
                        str(row.get("version") or ""), str(row.get("model_scope") or ""),
                    )
                    entry = entries.setdefault(key, RegistryEntry(key, [], [], 0, 0, 0, 0))
                    if table == "business":
                        entry.business_rows += 1
                        entry.business_values.append(row.get("business"))
                        entry.session_ids.append(row.get("session_id"))
                    else:
                        attr = {"domain": "domains", "product": "products", "attribute": "attributes"}[table]
                        setattr(entry, attr, getattr(entry, attr) + 1)
        return [entries[k] for k in sorted(entries, key=lambda k: (k.catalog, k.business, k.version, k.scope))]

    def registry_entry(
        self, catalog: str, business_segment: str, version: Any, scope: str,
    ) -> Optional[RegistryEntry]:
        """The entry whose stored version is ``str(version)``."""
        key = RegistryKey(catalog, business_segment.lower(), str(version), normalize_scope(scope))
        return next((e for e in self.registry(catalog) if e.key == key), None)

    def is_dir(self, path: str) -> bool:
        path = _norm_path(path)
        if path in self._dirs:
            return True
        prefix = path + "/"
        return any(f.startswith(prefix) for f in self._files)

    def read_json(self, path: str) -> Any:
        return json.loads(self._files[_norm_path(path)])

    def calls_to(self, seam: str) -> list[Call]:
        return [c for c in self.calls if c.seam == seam]

    def assert_no_unrecorded_sql(self) -> None:
        assert not self.unrecorded_sql, (
            "SQL reached ws.statement_execution with no seam covering it "
            f"(write or read the fake does not model): {self.unrecorded_sql}"
        )

    # ------------------------------------------------------------------
    # Seams
    # ------------------------------------------------------------------

    @contextmanager
    def patched(self) -> Iterator["FakeUC"]:
        """Route the app's ``_metamodel`` seams to this fake for the block."""
        fake = self

        def write_model_to_delta(self, catalog, business_name, version, model_scope,
                                 volume_path, model_payload):
            return fake._write_model_to_delta(self, catalog, business_name, version,
                                              model_scope, volume_path, model_payload)

        def delete_metamodel_rows(self, catalog, business_name, version, model_scope):
            return fake._delete_metamodel_rows(self, catalog, business_name, version, model_scope)

        def _query_delta_table(self, catalog, schema, table, business_name, version, model_scope=""):
            return fake._query_delta_table(catalog, schema, table, business_name, version, model_scope)

        def _query_businesses(self, catalog):
            return fake._query_businesses(catalog)

        def _query_completed_versions(self, catalog):
            return fake._query_completed_versions(catalog)

        def _query_dry_run_keys(self, catalog):
            return fake._query_dry_run_keys(catalog)

        original_seed = import_metamodel_writer.seed_metamodel_one
        binders = [
            mod for name, mod in list(sys.modules.items())
            if name.startswith("vibe_modeling.") and getattr(mod, "seed_metamodel_one", None) is original_seed
        ]
        original_release = metamodel_registry.set_deploy_status
        release_binders = [
            mod for name, mod in list(sys.modules.items())
            if name.startswith("vibe_modeling.") and getattr(mod, "set_deploy_status", None) is original_release
        ]
        try:
            with ExitStack() as stack:
                stack.enter_context(patch.object(ModelSyncService, "write_model_to_delta", write_model_to_delta))
                stack.enter_context(patch.object(ModelSyncService, "delete_metamodel_rows", delete_metamodel_rows))
                stack.enter_context(patch.object(ModelSyncService, "_query_delta_table", _query_delta_table))
                stack.enter_context(patch.object(InitialSyncService, "_query_businesses", _query_businesses))
                stack.enter_context(patch.object(InitialSyncService, "_query_dry_run_keys", _query_dry_run_keys))
                stack.enter_context(
                    patch.object(OobDetector, "_query_completed_versions", _query_completed_versions)
                )
                for mod in binders:
                    stack.enter_context(patch.object(mod, "seed_metamodel_one", self._seed_metamodel_one))
                for mod in release_binders:
                    stack.enter_context(patch.object(mod, "set_deploy_status", self._set_deploy_status))
                yield self
        finally:
            for name, mod in list(sys.modules.items()):
                if name.startswith("vibe_modeling.") and (
                    getattr(mod, "seed_metamodel_one", None) == self._seed_metamodel_one
                ):
                    mod.seed_metamodel_one = original_seed

    def _record(self, seam: str, **args: Any) -> None:
        self.calls.append(Call(seam, args))

    def _append(self, catalog: str, rows: dict[str, list[dict]]) -> dict[str, int]:
        for table, new in rows.items():
            self._registry[catalog][table].extend(new)
        return {table: len(new) for table, new in rows.items()}

    def _matching(
        self, catalog: str, table: str, business_name: str, version: Any, scope: str,
        *, exact_scope: bool,
    ) -> list[dict]:
        """Rows ``LOWER(business) = LOWER('<name>') AND version = '<bare>'``
        selects: the stored version is compared as is, ``NULL`` never matches.
        ``exact_scope`` mirrors the writers' and the delete's
        ``model_scope = '<scope>'`` (an empty scope matches only ``''``); the
        Delta reader adds the scope term only when the scope is non-empty."""
        biz, ver, sc = str(business_name or "").lower(), _bare_version(version), normalize_scope(scope)

        def selected(r: dict) -> bool:
            b, v, s = r.get("business"), r.get("version"), r.get("model_scope")
            if b is None or str(b).lower() != biz or v is None or str(v) != ver:
                return False
            if exact_scope or sc:
                return s is not None and str(s) == sc
            return True

        return [r for r in self._registry.get(catalog, {}).get(table, []) if selected(r)]

    def _write_model_to_delta(self, svc, catalog, business_name, version, model_scope,
                              volume_path, model_payload) -> bool:
        self._record(
            "write_model_to_delta", catalog=catalog, business_name=business_name,
            version=version, model_scope=model_scope, volume_path=volume_path,
        )
        if not svc._ws or not svc._warehouse_id:
            return False
        ensure_metamodel_registry(svc._ws, catalog, svc._warehouse_id)
        if catalog not in self._registry:
            raise RuntimeError(f"Delta write failed: [{TABLE_NOT_FOUND}] `{catalog}`.`_metamodel`.business")
        if self._matching(catalog, "business", business_name, version, model_scope, exact_scope=True):
            return False
        self._append(catalog, delta_writer_rows(
            catalog, business_name=business_name, version=version, model_scope=model_scope,
            volume_path=volume_path, model_payload=model_payload,
        ))
        return True

    def _delete_metamodel_rows(self, svc, catalog, business_name, version, model_scope) -> bool:
        self._record(
            "delete_metamodel_rows", catalog=catalog, business_name=business_name,
            version=version, model_scope=model_scope,
        )
        if not svc._ws or not svc._warehouse_id or not catalog:
            return False
        if catalog not in self._registry:
            return False
        if not self._matching(catalog, "business", business_name, version, model_scope, exact_scope=True):
            return False
        for table in REGISTRY_TABLES:
            doomed = self._matching(catalog, table, business_name, version, model_scope, exact_scope=True)
            self._registry[catalog][table] = [
                r for r in self._registry[catalog][table] if not any(r is d for d in doomed)
            ]
        return True

    def _query_delta_table(self, catalog, schema, table, business_name, version, model_scope=""):
        self._record(
            "query_delta_table", catalog=catalog, schema=schema, table=table,
            business_name=business_name, version=version, model_scope=model_scope,
        )
        if catalog not in self._registry:
            return None
        return [
            dict(r) for r in self._matching(catalog, table, business_name, version, model_scope, exact_scope=False)
        ]

    def _distinct_business_rows(self, catalog: str, cols: tuple[str, ...], where=None) -> list[dict]:
        """``SELECT DISTINCT <cols> FROM business [WHERE] ORDER BY business,
        version``; ``NULL`` sorts first, as in Databricks SQL."""
        seen: list[dict] = []
        for row in self._registry[catalog]["business"]:
            if where is not None and not where(row):
                continue
            picked = {c: row.get(c) for c in cols}
            if picked not in seen:
                seen.append(picked)

        def null_first(v: Any) -> tuple[bool, str]:
            return v is not None, "" if v is None else str(v)

        return sorted(seen, key=lambda r: (null_first(r["business"]), null_first(r["version"])))

    def _query_businesses(self, catalog) -> Optional[list[dict]]:
        self._record("query_businesses", catalog=catalog)
        if catalog not in self._registry:
            return None
        return self._distinct_business_rows(catalog, (
            "business", "version", "model_scope", "processing_status", "completed_percent",
            "completion_date", "catalog",
        ))

    def _query_completed_versions(self, catalog) -> Optional[list[dict]]:
        """The out-of-band scan: ``(CAST(completed_percent AS DOUBLE) >= 100 OR
        completed_percent IS NULL) AND completion_date IS NOT NULL``, with each
        row's ``session_id`` and ``completed_percent``. A non-numeric percent
        selects nothing (a warehouse in ANSI mode raises on it instead)."""
        self._record("query_completed_versions", catalog=catalog)
        if catalog not in self._registry:
            return None

        def completed(row: dict) -> bool:
            if row.get("completion_date") is None:
                return False
            if row.get("completed_percent") is None:
                return True
            try:
                return float(row.get("completed_percent")) >= 100
            except (TypeError, ValueError):
                return False

        return self._distinct_business_rows(
            catalog, ("business", "version", "model_scope", "completion_date", "session_id", "completed_percent"),
            completed,
        )

    def _query_dry_run_keys(self, catalog) -> set:
        """Keys of the business rows whose ``deploy_status`` is ``dry_run``
        (trimmed, any case) and whose ``session_id`` is not the app seed's
        ``0`` (``COALESCE(session_id, -1) <> 0``); empty when the table or the
        column is missing."""
        self._record("query_dry_run_keys", catalog=catalog)
        return {
            key for key in (
                metamodel_row_key(r) for r in self._registry.get(catalog, {}).get("business", [])
                if str(r.get("deploy_status") or "").strip().lower() == "dry_run"
                and str(r.get("session_id")) != "0"
            ) if key is not None
        }

    def _set_deploy_status(self, ws, warehouse_id, catalog, business, version, scope, status, *, wait="30s") -> None:
        """``metamodel_registry.set_deploy_status``: the business rows of
        ``LOWER(business) = LOWER(<name>) AND version = '<N>' AND
        (model_scope = '<scope>' OR model_scope IS NULL) AND
        (LOWER(catalog) = LOWER('<catalog>') OR catalog IS NULL OR catalog =
        '')`` get ``deploy_status``. :attr:`release_error` makes it raise."""
        self._record(
            "set_deploy_status", catalog=catalog, business=business, version=version, scope=scope, status=status,
            wait=wait,
        )
        if self.release_error is not None:
            raise self.release_error
        biz, ver, sc, cat = str(business).lower(), str(int(version)), str(scope).lower(), catalog.lower()
        for r in self._registry.get(catalog, {}).get("business", []):
            b, v, s, c = r.get("business"), r.get("version"), r.get("model_scope"), r.get("catalog")
            if b is None or str(b).lower() != biz or v is None or str(v) != ver:
                continue
            if s is not None and str(s) != sc:
                continue
            if c is not None and c != "" and str(c).lower() != cat:
                continue
            r["deploy_status"] = status

    def _seed_metamodel_one(self, ws, *, catalog, warehouse_id, model_json, business_name,
                            scope, version, log_prefix, wait_mode, location=None):
        """Every statement finishes at once on the fake, so ``still_running``
        is always empty; ``wait_mode`` and ``location`` are recorded for the
        caller's assertions."""
        self._record(
            "seed_metamodel_one", catalog=catalog, warehouse_id=warehouse_id,
            business_name=business_name, scope=scope, version=version, log_prefix=log_prefix,
            wait_mode=wait_mode, location=location,
        )
        if not (catalog and warehouse_id):
            return None
        summary = {"business": 0, "domain": 0, "product": 0, "attribute": 0, "errors": [], "still_running": []}
        if not ws or not business_name or not scope:
            summary["errors"].append("missing required arg: ws/catalog/warehouse_id/business_name/scope")
            return summary
        try:
            ensure_metamodel_registry(ws, catalog, warehouse_id)
        except MetamodelSetupError as exc:
            summary["errors"].append(str(exc))
            return summary
        if catalog not in self._registry:
            summary["errors"].append(f"[{TABLE_NOT_FOUND}] `{catalog}`.`_metamodel`.`business`")
            return summary
        summary.update(self._append(catalog, import_writer_rows(
            catalog, business_name=business_name, scope=scope, version=version, model_json=model_json,
            location=location,
        )))
        return summary


class FakeWorkspace:
    """The ``WorkspaceClient`` surface the app's UC code uses."""

    def __init__(self, fake: FakeUC) -> None:
        self.files = _Files(fake)
        self.schemas = _Schemas(fake)
        self.tables = _Tables(fake)
        self.volumes = _Volumes(fake)
        self.catalogs = _Catalogs(fake)
        self.statement_execution = _StatementExecution(fake)
        self._rest = MagicMock()
        self._rest.config.host = DEFAULT_HOST

    def __getattr__(self, name: str) -> Any:
        return getattr(self._rest, name)


class _Api:
    def __init__(self, fake: FakeUC) -> None:
        self._fake = fake


class _Files(_Api):
    def download(self, file_path: str) -> DownloadResponse:
        self._fake._record("files.download", file_path=file_path)
        path = _norm_path(file_path)
        if path not in self._fake._files:
            raise NotFound(f"fake UC: no such file {path}")
        data = self._fake._files[path]
        return DownloadResponse(contents=io.BytesIO(data), content_length=len(data))

    def upload(self, file_path: str, contents: Any, *, overwrite: Optional[bool] = None) -> None:
        self._fake._record("files.upload", file_path=file_path, overwrite=overwrite)
        path = _norm_path(file_path)
        vol = _volume_of(path)
        if vol and vol[2] not in self._fake._schemas.get(vol[0], {}).get(vol[1], _Schema()).volumes:
            raise NotFound(f"fake UC: volume {'.'.join(vol)} does not exist")
        if overwrite is False and path in self._fake._files:
            raise AlreadyExists(f"fake UC: {path} exists")
        self._fake._files[path] = _as_bytes(contents)

    def get_metadata(self, file_path: str) -> GetMetadataResponse:
        self._fake._record("files.get_metadata", file_path=file_path)
        path = _norm_path(file_path)
        if path not in self._fake._files:
            raise NotFound(f"fake UC: no such file {path}")
        return GetMetadataResponse(content_length=len(self._fake._files[path]))

    def get_directory_metadata(self, directory_path: str) -> None:
        self._fake._record("files.get_directory_metadata", directory_path=directory_path)
        if not self._fake.is_dir(directory_path):
            raise NotFound(f"fake UC: no such directory {directory_path}")

    def create_directory(self, directory_path: str) -> None:
        self._fake._record("files.create_directory", directory_path=directory_path)
        path = _norm_path(directory_path)
        self._fake._dirs.add(path)
        self._fake._dirs.update(_parents(path))

    def list_directory_contents(self, directory_path: str, *, page_size=None, page_token=None):
        self._fake._record("files.list_directory_contents", directory_path=directory_path)
        path = _norm_path(directory_path)
        if not self._fake.is_dir(path):
            raise NotFound(f"fake UC: no such directory {path}")
        prefix = path + "/"
        children: dict[str, bool] = {}
        for f in self._fake._files:
            if f.startswith(prefix):
                rest = f[len(prefix):]
                children.setdefault(rest.split("/", 1)[0], "/" in rest)
        for d in self._fake._dirs:
            if d.startswith(prefix) and "/" not in d[len(prefix):]:
                children[d[len(prefix):]] = True
        entries = []
        for name in sorted(children):
            full = prefix + name
            is_dir = children[name]
            entries.append(DirectoryEntry(
                name=name, path=full, is_directory=is_dir,
                file_size=None if is_dir else len(self._fake._files[full]),
            ))
        return iter(entries)

    def delete(self, file_path: str) -> None:
        self._fake._record("files.delete", file_path=file_path)
        path = _norm_path(file_path)
        if path not in self._fake._files:
            raise NotFound(f"fake UC: no such file {path}")
        del self._fake._files[path]

    def delete_directory(self, directory_path: str) -> None:
        self._fake._record("files.delete_directory", directory_path=directory_path)
        path = _norm_path(directory_path)
        if not self._fake.is_dir(path):
            raise NotFound(f"fake UC: no such directory {path}")
        prefix = path + "/"
        if any(f.startswith(prefix) for f in self._fake._files) or any(
            d.startswith(prefix) for d in self._fake._dirs
        ):
            raise BadRequest(f"fake UC: directory {path} is not empty")
        self._fake._dirs.discard(path)


class _Schemas(_Api):
    def list(self, catalog_name: str, **_: Any):
        self._fake._record("schemas.list", catalog_name=catalog_name)
        if catalog_name not in self._fake._catalogs:
            raise NotFound(f"fake UC: catalog {catalog_name} does not exist")
        return iter([
            SchemaInfo(name=s, catalog_name=catalog_name, full_name=f"{catalog_name}.{s}")
            for s in sorted(self._fake._schemas[catalog_name])
        ])

    def get(self, full_name: str, **_: Any) -> SchemaInfo:
        self._fake._record("schemas.get", full_name=full_name)
        catalog, _, schema = full_name.partition(".")
        if schema not in self._fake._schemas.get(catalog, {}):
            raise NotFound(f"fake UC: schema {full_name} does not exist")
        return SchemaInfo(name=schema, catalog_name=catalog, full_name=full_name)

    def create(self, name: str, catalog_name: str, **_: Any) -> SchemaInfo:
        self._fake._record("schemas.create", name=name, catalog_name=catalog_name)
        if catalog_name not in self._fake._catalogs:
            raise NotFound(f"fake UC: catalog {catalog_name} does not exist")
        if name in self._fake._schemas[catalog_name]:
            raise BadRequest(f"[SCHEMA_ALREADY_EXISTS] fake UC: {catalog_name}.{name}")
        self._fake._schemas[catalog_name][name] = _Schema()
        return SchemaInfo(name=name, catalog_name=catalog_name, full_name=f"{catalog_name}.{name}")

    def delete(self, full_name: str, *, force: Optional[bool] = None) -> None:
        self._fake._record("schemas.delete", full_name=full_name, force=force)
        catalog, _, schema = full_name.partition(".")
        state = self._fake._schemas.get(catalog, {}).get(schema)
        if state is None:
            raise NotFound(f"fake UC: schema {full_name} does not exist")
        if (state.tables or state.volumes) and not force:
            raise BadRequest(f"fake UC: schema {full_name} is not empty")
        del self._fake._schemas[catalog][schema]


class _Tables(_Api):
    def list(self, catalog_name: str, schema_name: str, **_: Any):
        self._fake._record("tables.list", catalog_name=catalog_name, schema_name=schema_name)
        state = self._fake._schemas.get(catalog_name, {}).get(schema_name)
        if state is None:
            raise NotFound(f"fake UC: schema {catalog_name}.{schema_name} does not exist")
        names = set(state.tables)
        if schema_name == METAMODEL_SCHEMA:
            names |= set(self._fake._registry.get(catalog_name, {}))
        return iter([
            TableInfo(name=t, catalog_name=catalog_name, schema_name=schema_name,
                      full_name=f"{catalog_name}.{schema_name}.{t}")
            for t in sorted(names)
        ])


    def get(self, full_name: str, **_: Any) -> TableInfo:
        self._fake._record("tables.get", full_name=full_name)
        catalog, schema, table = (full_name.split(".") + ["", "", ""])[:3]
        info = TableInfo(name=table, catalog_name=catalog, schema_name=schema, full_name=full_name)
        if schema == METAMODEL_SCHEMA and table in self._fake._registry.get(catalog, {}):
            info.columns = [
                ColumnInfo(name=c, type_text=t.lower(), type_name=None)
                for c, t in self._fake._columns.get(catalog, {}).get(table, [])
            ]
            return info
        if table in self._fake._schemas.get(catalog, {}).get(schema, _Schema()).tables:
            return info
        raise NotFound(f"fake UC: table {full_name} does not exist")


class _Volumes(_Api):
    def list(self, catalog_name: str, schema_name: str, **_: Any):
        self._fake._record("volumes.list", catalog_name=catalog_name, schema_name=schema_name)
        state = self._fake._schemas.get(catalog_name, {}).get(schema_name)
        if state is None:
            raise NotFound(f"fake UC: schema {catalog_name}.{schema_name} does not exist")
        return iter([
            VolumeInfo(name=v, catalog_name=catalog_name, schema_name=schema_name,
                       full_name=f"{catalog_name}.{schema_name}.{v}")
            for v in sorted(state.volumes)
        ])

    def read(self, name: str, **_: Any) -> VolumeInfo:
        self._fake._record("volumes.read", name=name)
        catalog, schema, volume = (name.split(".") + ["", "", ""])[:3]
        if volume not in self._fake._schemas.get(catalog, {}).get(schema, _Schema()).volumes:
            raise NotFound(f"fake UC: volume {name} does not exist")
        return VolumeInfo(name=volume, catalog_name=catalog, schema_name=schema, full_name=name)

    def create(self, catalog_name: str, schema_name: str, name: str, volume_type: Any, **_: Any) -> VolumeInfo:
        self._fake._record(
            "volumes.create", catalog_name=catalog_name, schema_name=schema_name,
            name=name, volume_type=volume_type,
        )
        state = self._fake._schemas.get(catalog_name, {}).get(schema_name)
        if state is None:
            raise NotFound(f"fake UC: schema {catalog_name}.{schema_name} does not exist")
        if name in state.volumes:
            raise ResourceAlreadyExists(f"fake UC: volume {catalog_name}.{schema_name}.{name} exists")
        state.volumes.add(name)
        return VolumeInfo(name=name, catalog_name=catalog_name, schema_name=schema_name,
                          full_name=f"{catalog_name}.{schema_name}.{name}")


class _Catalogs(_Api):
    def list(self, **_: Any):
        self._fake._record("catalogs.list")
        return iter([CatalogInfo(name=c, full_name=c) for c in sorted(self._fake._catalogs)])

    def get(self, name: str, **_: Any) -> CatalogInfo:
        self._fake._record("catalogs.get", name=name)
        if name not in self._fake._catalogs:
            raise NotFound(f"fake UC: catalog {name} does not exist")
        return CatalogInfo(name=name, full_name=name)


_DDL_TABLE = r"`(?P<catalog>[^`]+)`\.`_metamodel`\.`(?P<table>[^`]+)`"
_CREATE_RE = re.compile(rf"^CREATE TABLE IF NOT EXISTS {_DDL_TABLE} \((?P<cols>.*)\)$", re.DOTALL)
_ALTER_RE = re.compile(rf"^ALTER TABLE {_DDL_TABLE} ADD COLUMN `(?P<col>[^`]+)` (?P<type>\w+)$")
_DESCRIBE_RE = re.compile(rf"^DESCRIBE TABLE {_DDL_TABLE}$")
_COLUMN_DEF_RE = re.compile(r"`([^`]+)` (\w+)")
_PARENT_COUNT_RE = re.compile(
    rf"^SELECT COUNT\(\*\) AS n FROM {_DDL_TABLE} "
    r"WHERE LOWER\(business\) = LOWER\('(?P<business>[^']*)'\) AND version = '(?P<version>[^']*)'$"
)


def _sql_response(statement_id: str, *, error: Optional[str] = None, data: Optional[list] = None,
                  columns: tuple[str, ...] = ()) -> SimpleNamespace:
    """A Statement Execution response as ``core._sql`` reads it."""
    data = data or []
    return SimpleNamespace(
        statement_id=statement_id,
        status=SimpleNamespace(
            state="FAILED" if error else "SUCCEEDED",
            error=SimpleNamespace(message=error) if error else None,
        ),
        result=SimpleNamespace(data_array=data, chunk_index=0, next_chunk_index=None),
        manifest=SimpleNamespace(
            truncated=False, total_row_count=len(data),
            schema=SimpleNamespace(columns=[SimpleNamespace(name=c) for c in columns]),
        ),
    )


class _StatementExecution(_Api):
    def execute_statement(self, *args: Any, **kwargs: Any):
        statement = kwargs.get("statement") or (args[0] if args else "")
        modeled = self._ddl(statement.strip()) or self._parent_count(statement.strip())
        if modeled is not None:
            return modeled
        self._fake._record("statement_execution.execute_statement", statement=statement)
        self._fake.unrecorded_sql.append(statement)
        raise UnrecordedSQLError(f"unrecorded SQL: {statement}")

    def _parent_count(self, statement: str) -> Optional[SimpleNamespace]:
        """The run pre-flight's parent check: ``COUNT(*)`` of the business rows
        ``LOWER(business) = LOWER(<segment>) AND version = <version>`` selects,
        recorded as ``sql.parent_count``; a missing table fails as on a warehouse."""
        match = _PARENT_COUNT_RE.match(statement)
        if match is None or match.group("table") != "business":
            return None
        fake = self._fake
        fake._record("sql.parent_count", statement=statement)
        statement_id = f"fake-count-{len(fake.calls_to('sql.parent_count'))}"
        catalog = match.group("catalog")
        if "business" not in fake._registry.get(catalog, {}):
            return _sql_response(statement_id, error=f"[{TABLE_NOT_FOUND}] `{catalog}`.`_metamodel`.`business`")
        n = sum(
            1 for r in fake._registry[catalog]["business"]
            if str(r.get("business") or "").lower() == match.group("business").lower()
            and r.get("version") is not None and str(r.get("version")) == match.group("version")
        )
        return _sql_response(statement_id, data=[[str(n)]], columns=("n",))

    def _ddl(self, statement: str) -> Optional[SimpleNamespace]:
        """Run one registry DDL statement on the stored state; None when the
        statement is not one."""
        fake = self._fake
        match = next((m for m in (r.match(statement) for r in (_CREATE_RE, _ALTER_RE, _DESCRIBE_RE)) if m), None)
        if match is None or match.group("table") not in REGISTRY_TABLES:
            return None
        fake._record("sql.ddl", statement=statement)
        statement_id = f"fake-ddl-{len(fake.calls_to('sql.ddl'))}"
        if fake.ddl_error:
            return _sql_response(statement_id, error=fake.ddl_error)
        catalog, table = match.group("catalog"), match.group("table")
        columns = fake._columns.setdefault(catalog, {})
        present = table in fake._registry.get(catalog, {})
        if match.re is _CREATE_RE:
            if METAMODEL_SCHEMA not in fake._schemas.get(catalog, {}):
                return _sql_response(statement_id, error=f"[SCHEMA_NOT_FOUND] `{catalog}`.`_metamodel`")
            if not present:
                fake._registry.setdefault(catalog, {})[table] = []
                columns[table] = [(c, t) for c, t in _COLUMN_DEF_RE.findall(match.group("cols"))]
            return _sql_response(statement_id)
        if not present:
            return _sql_response(statement_id, error=f"[{TABLE_NOT_FOUND}] `{catalog}`.`_metamodel`.`{table}`")
        if match.re is _ALTER_RE:
            if any(c == match.group("col") for c, _ in columns[table]):
                return _sql_response(statement_id, error=f"[FIELD_ALREADY_EXISTS] {match.group('col')}")
            columns[table].append((match.group("col"), match.group("type")))
            return _sql_response(statement_id)
        return _sql_response(
            statement_id, data=[[c, t.lower(), None] for c, t in columns[table]],
            columns=("col_name", "data_type", "comment"),
        )

    def __getattr__(self, name: str) -> Any:
        def _refuse(*args: Any, **kwargs: Any):
            self._fake.unrecorded_sql.append(f"{name}({args!r}, {kwargs!r})")
            raise UnrecordedSQLError(f"unrecorded SQL call: statement_execution.{name}")
        return _refuse
