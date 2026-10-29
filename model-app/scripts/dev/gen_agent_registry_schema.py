#!/usr/bin/env python3
"""Generate the agent registry tables' columns from the vendored agent notebook.

The agent creates its registry, ``<catalog>._metamodel.{business, domain,
product, attribute}``, in ``_ensure_metamodel_registry``: one
``CREATE TABLE IF NOT EXISTS`` per ``TABLE_*_SCHEMA`` dict with
``map_data_type`` column types, then ``ALTER TABLE ... ADD COLUMN`` for each
missing ``_METAMODEL_BUSINESS_MIGRATION_COLUMNS`` entry on ``business``. The
app creates the same tables in a catalog the agent never ran in
(``services/metamodel_registry.ensure_metamodel_registry``), reading the columns
from ``src/app/vendored/agent/metamodel_registry_schema.json``, which this
script writes.

The notebook's literals are read with ``ast.literal_eval``; nothing in the
notebook runs. The script refuses (exit 1) when the agent code it mirrors has
changed shape: the registry loop or its ``CREATE TABLE IF NOT EXISTS``, the
``map_data_type`` lookup, or a DECIMAL column (``map_data_type`` gives it a
precision this mirror does not read). Any other type the lookup does not know
maps to STRING, as in the agent.

The JSON also records the sha256 of the source of ``_ensure_metamodel_registry``
and ``map_data_type``, so any edit to either (a new statement, another column
expression, a changed type rule) changes the file and fails the pin until the
app's mirror (``metamodel_registry._ensure_registry_tables``) is checked.

``tests/test_app/test_agent_registry_schema_pin.py`` regenerates the JSON from
the vendored notebook and fails on any difference, so an agent upgrade that
changes the tables fails the build until this is re-run and the diff reviewed.

Usage:
  python3 scripts/dev/gen_agent_registry_schema.py           # write the JSON
  python3 scripts/dev/gen_agent_registry_schema.py --check   # exit 3 on drift

Pure stdlib.
"""

from __future__ import annotations

import argparse
import ast
import hashlib
import json
import re
import sys
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[2]
AGENT_VENDOR_DIR = REPO_ROOT / "src" / "app" / "vendored" / "agent"
SCHEMA_FILE = "metamodel_registry_schema.json"
EXIT_DRIFT = 3

# The lines of the agent's code this generator mirrors; a change to any of
# them means the mirror may be wrong, so generation stops.
_REGISTRY_FN = "def _ensure_metamodel_registry("
_REGISTRY_COLUMN_EXPR = "map_data_type(p.get('type', 'string'))"
_MAP_FN = "def map_data_type("
_MAP_BASE = """_base_t = str(logical_type or "").strip().lower().split('(')[0].strip()"""
_MAP_LOOKUP = """name = _PHYSICAL_TYPE_NAMES.get(_base_t, "STRING")"""
_MAP_DECIMAL = ("decimal", "numeric", "dec")


class GenerationError(Exception):
    pass


def notebook_source(vendor_dir: Path = AGENT_VENDOR_DIR) -> tuple[str, str]:
    """``(notebook file name, its cell sources joined one cell per block)``
    for the notebook ``VERSIONS.json`` names."""
    versions = json.loads((vendor_dir / "VERSIONS.json").read_text())
    name = versions["notebook_file"]
    nb = json.loads((vendor_dir / name).read_text())
    return name, "\n".join("".join(cell.get("source", [])) for cell in nb["cells"])


def _literal(source: str, name: str):
    """The value of the top-level ``name = <literal>`` assignment (it may span lines)."""
    matches = list(re.finditer(rf"^{re.escape(name)}\s*=\s*", source, re.MULTILINE))
    if len(matches) != 1:
        raise GenerationError(f"expected one top-level `{name} = ...`, found {len(matches)}")
    lines = source[matches[0].end():].splitlines()
    for n in range(1, min(len(lines), 200) + 1):
        try:
            return ast.literal_eval("\n".join(lines[:n]))
        except (SyntaxError, ValueError):
            continue
    raise GenerationError(f"`{name}` is not a literal")


def _function(source: str, header: str) -> str:
    start = source.find(header)
    if start < 0 or source.find(header, start + 1) >= 0:
        raise GenerationError(f"expected one `{header}`")
    end = re.compile(r"^\S", re.MULTILINE).search(source, start + len(header))
    return source[start:end.start() if end else len(source)]


def _map_data_type(type_names: dict, logical_type: str) -> str:
    base = str(logical_type or "").strip().lower().split("(")[0].strip()
    if base in _MAP_DECIMAL:
        raise GenerationError(f"registry column type {logical_type!r} is a DECIMAL; the mirror does not cover it")
    return type_names.get(base, "STRING")


def extract(notebook_file: str, source: str) -> dict:
    """The registry tables' ``[column, SQL type]`` lists, in the agent's order,
    and the business migration columns."""
    registry = _function(source, _REGISTRY_FN)
    for needed in (_REGISTRY_COLUMN_EXPR, "CREATE TABLE IF NOT EXISTS", "_METAMODEL_BUSINESS_MIGRATION_COLUMNS"):
        if needed not in registry:
            raise GenerationError(f"`_ensure_metamodel_registry` no longer contains {needed!r}")
    loop = re.search(r"for table, schema in \((.*?)\):", registry)
    if loop is None:
        raise GenerationError("`_ensure_metamodel_registry` has no `for table, schema in (...)` loop")
    pairs = re.findall(r'\(\s*"(\w+)"\s*,\s*(TABLE_\w+_SCHEMA)\s*\)', loop.group(1))
    if not pairs:
        raise GenerationError("`_ensure_metamodel_registry` loop names no tables")

    mapper = _function(source, _MAP_FN)
    for needed in (_MAP_BASE, _MAP_LOOKUP):
        if needed not in mapper:
            raise GenerationError(f"`map_data_type` no longer contains {needed!r}")
    type_names = _literal(source, "_PHYSICAL_TYPE_NAMES")

    tables = {}
    for table, schema_name in pairs:
        properties = _literal(source, schema_name)["properties"]
        tables[table] = [[c, _map_data_type(type_names, p.get("type", "string"))] for c, p in properties.items()]

    migration = [[c, t] for c, t in _literal(source, "_METAMODEL_BUSINESS_MIGRATION_COLUMNS")]
    return {
        "generated_by": "scripts/dev/gen_agent_registry_schema.py",
        "notebook_file": notebook_file,
        "source_sha256": {
            "_ensure_metamodel_registry": hashlib.sha256(registry.encode()).hexdigest(),
            "map_data_type": hashlib.sha256(mapper.encode()).hexdigest(),
        },
        "tables": tables,
        "business_migration_columns": migration,
    }


def render(schema: dict) -> str:
    """JSON with one ``[column, type]`` pair per line, so a diff names the column."""
    def pairs(items: list, indent: str) -> str:
        return "[\n" + ",\n".join(f"{indent}  {json.dumps(p)}" for p in items) + f"\n{indent}]"

    shas = ",\n".join(f"    {json.dumps(k)}: {json.dumps(v)}" for k, v in schema["source_sha256"].items())
    tables = ",\n".join(f'    {json.dumps(t)}: {pairs(cols, "    ")}' for t, cols in schema["tables"].items())
    return (
        "{\n"
        f'  "generated_by": {json.dumps(schema["generated_by"])},\n'
        f'  "notebook_file": {json.dumps(schema["notebook_file"])},\n'
        f'  "source_sha256": {{\n{shas}\n  }},\n'
        f'  "tables": {{\n{tables}\n  }},\n'
        f'  "business_migration_columns": {pairs(schema["business_migration_columns"], "  ")}\n'
        "}\n"
    )


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--check", action="store_true", help="exit 3 when the committed JSON differs")
    parser.add_argument("--vendor-dir", type=Path, default=AGENT_VENDOR_DIR)
    args = parser.parse_args(argv)
    try:
        text = render(extract(*notebook_source(args.vendor_dir)))
    except (GenerationError, OSError, KeyError, json.JSONDecodeError) as exc:
        print(f"ERROR: {exc}", file=sys.stderr)
        return 1
    target = args.vendor_dir / SCHEMA_FILE
    if args.check:
        current = target.read_text() if target.is_file() else ""
        if current != text:
            print(f"DRIFT: {target} is out of date; re-run without --check and review the diff", file=sys.stderr)
            return EXIT_DRIFT
        print(f"ok: {target} matches the vendored notebook")
        return 0
    target.write_text(text)
    print(f"wrote {target}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
