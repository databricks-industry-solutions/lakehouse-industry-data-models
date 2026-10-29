"""Capture the shapes a bundled agent notebook leaves behind in ``_metamodel``.

Reads the agent's own writers out of a notebook and runs them, so the
captured rows are what the agent emits and not what the app expects:

* ``VibeWriter._build_insert_sql`` builds the ``business`` INSERT of a run's
  first row (the dict passed to ``insert_business_row``) and of an install's
  deployed row (the dict passed to ``insert_deployed_business_row``);
* ``_metamodel_registry_records`` (5.x) builds the domain, product and
  attribute rows the install registrar writes;
* the ``StructType`` blocks of the run's final merge give the columns of the
  domain, product and attribute rows a run writes;
* ``TABLE_*_SCHEMA`` and ``_METAMODEL_BUSINESS_MIGRATION_COLUMNS`` give the
  table columns.

Nothing here needs Spark: the functions are lifted out of the notebook with
``ast`` and run against plain Python. ``python capture.py <notebook> <out.json>``
rewrites a fixture; ``tests/test_app/test_drift_agent_upgrade.py`` recaptures
the vendored notebook and compares it with the committed JSON, so vendoring a
new agent fails that test until the fixture is regenerated and reviewed.
"""
from __future__ import annotations

import ast
import hashlib
import json
import re
import sys
from pathlib import Path
from typing import Any, Optional

TABLES = ("business", "domain", "product", "attribute")

SAMPLE_BUSINESS = {
    "business": "Acme_Co",
    "version": "1",
    "model_scope": "mvm",
    "industry_alignment": "Retail",
    "description": "Acme Co sells goods.",
    "catalog": "drift_cat",
    "location": "/Volumes/drift_cat/_metamodel/vol_root/business/acme_co/v1/mvm",
    "core_business_processes": "Order to cash",
    "orgnaization_divisions": "Operations, Business and Corporate",
    "data_domains": "Customer, Sales",
    "common_business_jargons": "SKU",
    "operational_systems_of_records": "ERP",
    "industry_governing_body": "None",
    "vibe_modelling_instructions": "",
    "model_conventions": '{"data_asset_naming_convention": "snake_case"}',
    "completion_date": "2026-05-08 02:27:55",
    "completed_percent": 100.0,
    "processing_status": "done",
}
"""Values for the keys the notebook passes. Which keys are passed comes from
the notebook; the values are sample data."""

RUN_START_VALUES = {"completed_percent": 0.0, "processing_status": "pending"}
"""The run's first row is inserted ``pending`` at 0 percent (``insert_business_row``)."""

SAMPLE_MODEL = {
    "domains": [{
        "name": "Customer", "division": "business", "description": "Customers.",
        "database_name": "customer", "references": "", "tags": "",
        "products": [{
            "name": "Customer Master", "table_name": "customer_master", "primary_key": "customer_id",
            "subdomain": "core", "description": "One row per customer.", "type": "master",
            "division": "business", "function": "", "data_type": "", "source_domains": "",
            "association_edges": "", "reference": "", "tags": "",
            "attributes": [{
                "name": "customer_id", "column_name": "customer_id", "type": "bigint",
                "business_glossary_term": "", "description": "Key.", "value_regex": "",
                "tags": "", "foreign_key_to": "", "references": "",
            }],
        }],
    }],
}

STATE_UPDATES = {
    "initialized": ["processing_status = 'done'", "session_json = '{{}}'", "results_json = '{{}}'"],
    "progress": ["processing_status = '{_status}'", "completed_percent = LEAST(99.0"],
    "finalized": [
        "completed_percent = 100.0", "completion_date = TIMESTAMP('{ts}')",
        "results_json = '{safe_results}'",
    ],
}
"""Fragments of the ``VibeWriter`` UPDATE statements that move a run's business
row between states. They are checked against the notebook source; the values
they produce are in :func:`transitions`."""


EMULATED_FUNCTIONS = (
    "_register_model_json_in_metamodel", "_registry_other_deployments", "_ensure_metamodel_registry",
    "_set_metamodel_deploy_status",
)
EMULATED_VIBE_WRITER_METHODS = ("initialize_session", "_update_session_ready", "_finalize_session")
"""Agent code the tests do not run but reproduce by hand (the Spark SQL of a run's row updates and of
the install registration). ``capture`` records a hash of each one's source, so a re-vendor that
changes one names what to re-review."""


def sha256(path: Path) -> str:
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()


def load_cells(path: Path) -> list[str]:
    """Source of every cell, markdown cells empty, so a list index is the cell number."""
    nb = json.loads(Path(path).read_text())
    return ["".join(c["source"]) if c["cell_type"] == "code" else "" for c in nb["cells"]]


def _parse(src: str) -> Optional[ast.Module]:
    try:
        return ast.parse(src)
    except SyntaxError:
        return None


def _find(cells: list[str], needle: str) -> list[int]:
    return [i for i, s in enumerate(cells) if needle in s]


def _compile_node(node: ast.stmt) -> Any:
    return compile(ast.Module(body=[node], type_ignores=[]), "<notebook>", "exec")


def _top_level(tree: ast.Module, name: str) -> Optional[ast.stmt]:
    for node in tree.body:
        if isinstance(node, (ast.FunctionDef, ast.ClassDef)) and node.name == name:
            return node
        if isinstance(node, ast.Assign) and any(isinstance(t, ast.Name) and t.id == name for t in node.targets):
            return node
    return None


def _lift(cells: list[str], names: list[str], class_methods: dict[str, list[str]]) -> tuple[dict, dict]:
    """Run the named top-level definitions of the notebook in one namespace.

    ``class_methods`` lifts methods out of a class (``VibeWriter``) onto a stub
    class of the same name, so the class's other dependencies stay out.
    Returns ``(namespace, cell index per name)``."""
    ns: dict[str, Any] = {"re": re, "json": json}
    where: dict[str, int] = {}
    wanted = set(names) | set(class_methods)
    for i, src in enumerate(cells):
        if not any(w in src for w in wanted):
            continue
        tree = _parse(src)
        if tree is None:
            continue
        for name in names:
            node = _top_level(tree, name)
            if node is not None and name not in where:
                exec(_compile_node(node), ns)
                where[name] = i
        for cls, methods in class_methods.items():
            node = _top_level(tree, cls)
            if not isinstance(node, ast.ClassDef):
                continue
            stub = ns.setdefault(cls, type(cls, (), {}))
            for item in node.body:
                if isinstance(item, ast.FunctionDef) and item.name in methods:
                    item.decorator_list = []
                    local: dict[str, Any] = dict(ns)
                    exec(_compile_node(item), local)
                    setattr(stub, item.name, staticmethod(local[item.name]))
                    where[f"{cls}.{item.name}"] = i
    return ns, where


def parse_values(sql: str) -> dict[str, Optional[str]]:
    """``INSERT INTO t (`a`, `b`) VALUES (v1, v2)`` as ``{column: stored string}``.

    ``NULL`` is ``None``; ``TIMESTAMP('x')`` is ``x``; numbers keep their text
    (``0.0``). A backslash escape is undone. The sample values hold no quote, so the
    4.9.9 doubled-quote escape never occurs."""
    cols = re.search(r"\(([^)]*)\)\s*VALUES", sql, re.S)
    assert cols, sql[:120]
    names = [c.strip().strip("`") for c in cols.group(1).split(",")]
    return dict(zip(names, _tokens(sql[cols.end():].strip().removeprefix("(").removesuffix(")"))))


def _tokens(text: str) -> list[Optional[str]]:
    out: list[Optional[str]] = []
    i, n = 0, len(text)
    while i < n:
        c = text[i]
        if c in " ,\n":
            i += 1
            continue
        if text.startswith("TIMESTAMP(", i):
            end = text.index(")", i)
            out.append(_tokens(text[i + len("TIMESTAMP("):end])[0])
            i = end + 1
        elif c == "'":
            i += 1
            buf = []
            while i < n:
                if text[i] == "\\" and i + 1 < n:
                    buf.append(text[i + 1])
                    i += 2
                elif text[i] == "'":
                    i += 1
                    break
                else:
                    buf.append(text[i])
                    i += 1
            out.append("".join(buf))
        else:
            j = i
            while j < n and text[j] not in ",)":
                j += 1
            token = text[i:j].strip()
            out.append(None if token == "NULL" else token)
            i = j
    return out


def _dict_keys(node: ast.Dict) -> list[str]:
    return [k.value for k in node.keys if isinstance(k, ast.Constant) and isinstance(k.value, str)]


def _business_row_dicts(cells: list[str]) -> dict[str, tuple[int, list[str]]]:
    """Keys of the dict a run passes to ``insert_business_row`` and of the dict
    an install passes to ``insert_deployed_business_row``. Each has one call
    site; a notebook with two or none raises, so a second writer is not missed."""
    found: dict[str, list[tuple[int, list[str]]]] = {"run_start": [], "installed": []}
    for i, src in enumerate(cells):
        if "insert_business_row" not in src and "insert_deployed_business_row" not in src:
            continue
        tree = _parse(src)
        if tree is None:
            continue
        assigned = {
            t.id: n.value for n in ast.walk(tree) if isinstance(n, ast.Assign) and isinstance(n.value, ast.Dict)
            for t in n.targets if isinstance(t, ast.Name)
        }
        for call in (n for n in ast.walk(tree) if isinstance(n, ast.Call) and isinstance(n.func, ast.Attribute)):
            kind = {"insert_business_row": "run_start", "insert_deployed_business_row": "installed"}.get(call.func.attr)
            if kind is None:
                continue
            arg = call.args[-1]
            if isinstance(arg, ast.Name):
                arg = assigned.get(arg.id)
            if isinstance(arg, ast.Dict):
                found[kind].append((i, _dict_keys(arg)))
    for kind, sites in found.items():
        if len(sites) != 1:
            raise LookupError(f"{kind}: {len(sites)} call sites with a dict literal, expected 1")
    return {kind: sites[0] for kind, sites in found.items()}


def _literal(cells: list[str], name: str) -> tuple[int, Any]:
    for i in _find(cells, name):
        tree = _parse(cells[i])
        node = _top_level(tree, name) if tree else None
        if isinstance(node, ast.Assign):
            return i, ast.literal_eval(node.value)
    raise LookupError(name)


def _merge_columns(cells: list[str]) -> tuple[int, dict[str, list[str]]]:
    """Columns of the ``domain_schema`` / ``product_schema`` / ``attribute_schema``
    ``StructType`` blocks in the cell that appends the final merge."""
    for i in _find(cells, 'domains_df.write.mode("append")'):
        cols = {}
        for table in ("domain", "product", "attribute"):
            block = re.search(rf"{table}_schema = StructType\(\[(.*?)\]\)", cells[i], re.S)
            cols[table] = re.findall(r'StructField\("(\w+)"', block.group(1)) if block else []
        return i, cols
    raise LookupError("final merge")


def _split_keys(node: ast.Dict) -> tuple[list[str], list[str]]:
    """Keys of a dict literal: ``(always, only when a ``**`` spread adds them)``."""
    always, optional = [], []
    for key, value in zip(node.keys, node.values):
        if key is None:
            optional.extend(
                k.value for sub in ast.walk(value) if isinstance(sub, ast.Dict)
                for k in sub.keys if isinstance(k, ast.Constant)
            )
        else:
            always.append(key.value)
    return always, optional


def _model_json_shapes(cells: list[str]) -> tuple[int, dict[str, dict[str, list[str]]]]:
    """Key sets of the dicts the model.json writer builds: the file root, the
    ``model`` block, a domain, a product, an attribute."""
    targets = {
        "model_json_root": "root", "data_model": "model", "domain_obj": "domain",
        "product_obj": "product", "attr_obj": "attribute",
    }
    for i in _find(cells, "model_json_root = {"):
        tree = _parse(cells[i])
        shapes: dict[str, dict[str, list[str]]] = {}
        for node in ast.walk(tree):
            if isinstance(node, ast.Assign) and isinstance(node.value, ast.Dict):
                for t in node.targets:
                    if isinstance(t, ast.Name) and t.id in targets and targets[t.id] not in shapes:
                        always, optional = _split_keys(node.value)
                        shapes[targets[t.id]] = {"always": always, "when_present": optional}
            if isinstance(node, ast.FunctionDef) and node.name == "_modeljson_attr_obj":
                ret = next(n for n in ast.walk(node) if isinstance(n, ast.Return))
                always, optional = _split_keys(ret.value)
                shapes["attribute"] = {"always": always, "when_present": optional}
        return i, shapes
    raise LookupError("model_json_root")


def emulated_source_hashes(cells: list[str]) -> dict[str, str]:
    """sha256 of the source of each function in :data:`EMULATED_FUNCTIONS` and each
    ``VibeWriter`` method in :data:`EMULATED_VIBE_WRITER_METHODS` the notebook has."""
    found: dict[str, str] = {}
    wanted = EMULATED_FUNCTIONS + EMULATED_VIBE_WRITER_METHODS
    for src in cells:
        if not any(name in src for name in wanted):
            continue
        tree = _parse(src)
        if tree is None:
            continue
        for node in tree.body:
            if isinstance(node, ast.FunctionDef) and node.name in EMULATED_FUNCTIONS:
                found[node.name] = hashlib.sha256(ast.get_source_segment(src, node).encode()).hexdigest()
            elif isinstance(node, ast.ClassDef) and node.name == "VibeWriter":
                for item in node.body:
                    if isinstance(item, ast.FunctionDef) and item.name in EMULATED_VIBE_WRITER_METHODS:
                        segment = ast.get_source_segment(src, item)
                        found[f"VibeWriter.{item.name}"] = hashlib.sha256(segment.encode()).hexdigest()
    return found


def _marker(cells: list[str], name: str) -> str:
    i = _find(cells, f"{name} = ")[0]
    return re.search(rf'^{name} = "([^"]+)"', cells[i], re.M).group(1)


def _sample_row(keys: list[str], kind: str) -> dict[str, Any]:
    values = {**SAMPLE_BUSINESS, **(RUN_START_VALUES if kind == "run_start" else {})}
    return {k: values[k] for k in keys if k in values}


class AgentWriters:
    """The writers lifted out of one notebook, ready to call."""

    def __init__(self, path: Path) -> None:
        self.cells = load_cells(path)
        self.ns, self.where = _lift(
            self.cells,
            ["sanitize_name", "_sql_string_escape", "_metamodel_sql_literal", "_metamodel_registry_records"],
            {"VibeWriter": ["_escape_sql_str", "_build_insert_sql"]},
        )
        self.schemas = {t: _literal(self.cells, f"TABLE_{t.upper()}_SCHEMA")[1] for t in TABLES}

    @property
    def has_installer(self) -> bool:
        return "_metamodel_registry_records" in self.where

    def business_values(self, row: dict) -> dict[str, Optional[str]]:
        """The stored value of every ``business`` column after the agent INSERTs ``row``."""
        sql = self.ns["VibeWriter"]._build_insert_sql("business", row, self.schemas["business"])
        return parse_values(sql)

    def installer_rows(
        self, model: dict, business: str, version: str, scope: str, catalog: str,
    ) -> dict[str, list[dict[str, Optional[str]]]]:
        """The domain, product and attribute rows the install registrar INSERTs for ``model``."""
        record_columns = _literal(self.cells, "_METAMODEL_RECORD_COLUMNS")[1]
        records = dict(zip(("domain", "product", "attribute"), self.ns["_metamodel_registry_records"](
            model, business, version, scope, catalog=catalog,
        )))
        return {
            t: [dict(zip(record_columns[t].split(", "), _tokens(r.strip()[1:-1]))) for r in rows]
            for t, rows in records.items()
        }


def capture(path: Path) -> dict:
    """The shapes ``path``'s writers produce, as a JSON-ready dict."""
    writers = AgentWriters(path)
    cells = writers.cells
    schema_cell, _ = _literal(cells, "TABLE_BUSINESS_SCHEMA")
    columns = {t: list(writers.schemas[t]["properties"]) for t in TABLES}
    rows: dict[str, dict] = {}
    origin: dict[str, Any] = {
        "tables": {"cell": schema_cell, "names": [f"TABLE_{t.upper()}_SCHEMA" for t in TABLES]},
        "insert_builder": {"cell": writers.where["VibeWriter._build_insert_sql"], "name": "VibeWriter._build_insert_sql"},
    }
    for kind, (cell, keys) in _business_row_dicts(cells).items():
        rows[kind] = {"keys_passed": keys, "values": writers.business_values(_sample_row(keys, kind))}
        origin[f"{kind}_row"] = {"cell": cell}
    merge_cell, merge_columns = _merge_columns(cells)
    origin["run_merge_columns"] = {"cell": merge_cell}
    root_cell, model_json_shapes = _model_json_shapes(cells)
    origin["model_json_writer"] = {"cell": root_cell}
    result: dict[str, Any] = {
        "notebook_sha256": sha256(path),
        "agent_version": _marker(cells, "__AGENT_VERSION__"),
        "release_version": _marker(cells, "__RELEASE_VERSION__"),
        "business_columns": columns["business"],
        "other_table_columns": {t: columns[t] for t in TABLES[1:]},
        "run_merge_columns": merge_columns,
        "business_rows": rows,
        "model_json_keys": model_json_shapes,
        "emulated_sources": emulated_source_hashes(cells),
        "origin": origin,
    }
    if writers.has_installer:
        migration_cell, migration = _literal(cells, "_METAMODEL_BUSINESS_MIGRATION_COLUMNS")
        record_cell, record_columns = _literal(cells, "_METAMODEL_RECORD_COLUMNS")
        result["migration_columns"] = [c for c, _t in migration]
        result["installer_columns"] = {t: c.split(", ") for t, c in record_columns.items()}
        result["installer_rows"] = writers.installer_rows(SAMPLE_MODEL, "Acme_Co", "1", "mvm", "drift_cat")
        origin["migration_columns"] = {"cell": migration_cell}
        origin["installer"] = {"cell": writers.where["_metamodel_registry_records"], "record_columns_cell": record_cell}
    return result


def main(argv: list[str]) -> None:
    notebook, out = Path(argv[1]), Path(argv[2])
    out.write_text(json.dumps(capture(notebook), indent=2, sort_keys=True) + "\n")


if __name__ == "__main__":
    main(sys.argv)
