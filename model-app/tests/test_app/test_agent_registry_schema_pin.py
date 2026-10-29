"""Pin: the registry columns the app creates are the vendored agent's.

``src/app/vendored/agent/metamodel_registry_schema.json`` is generated from the
vendored notebook by ``scripts/dev/gen_agent_registry_schema.py`` (the
``TABLE_*_SCHEMA`` dicts through ``map_data_type``, and
``_METAMODEL_BUSINESS_MIGRATION_COLUMNS``, plus the source sha256 of
``_ensure_metamodel_registry`` and ``map_data_type``). Regenerating it must give the
committed file byte for byte, so an agent upgrade that changes the registry
tables fails here until the file is regenerated and the diff reviewed. The
app's two registry writers must only name columns those tables have.
"""
from __future__ import annotations

import importlib.util
import re
import sys
from unittest.mock import MagicMock

import pytest

from vibe_modeling.backend.model_sync import ModelSyncService
from vibe_modeling.backend.services import import_metamodel_writer
from vibe_modeling.backend.services.metamodel_registry import REGISTRY_SCHEMA_FILE, registry_schema

from ._source_scan import REPO, VENDORED, agent_notebook_source
from ._sql_fakes import response

GENERATOR = REPO / "scripts/dev/gen_agent_registry_schema.py"
SCHEMA_JSON = VENDORED / "agent" / REGISTRY_SCHEMA_FILE


@pytest.fixture(scope="module")
def gen():
    spec = importlib.util.spec_from_file_location("gen_agent_registry_schema", GENERATOR)
    module = importlib.util.module_from_spec(spec)
    sys.modules[spec.name] = module
    spec.loader.exec_module(module)
    yield module
    sys.modules.pop(spec.name, None)


def test_committed_json_is_what_the_vendored_notebook_generates(gen):
    name, source = gen.notebook_source(VENDORED / "agent")
    assert source == agent_notebook_source()
    assert SCHEMA_JSON.read_text() == gen.render(gen.extract(name, source)), (
        f"{SCHEMA_JSON.name} is out of date: run `python3 scripts/dev/gen_agent_registry_schema.py` "
        "and review the diff (the agent's registry tables changed)"
    )


def test_the_app_reads_the_committed_json():
    schema = registry_schema()
    assert list(schema.tables) == ["business", "domain", "product", "attribute"]
    assert ("deploy_status", "STRING") in schema.business_migration_columns
    assert ("completion_date", "TIMESTAMP") in schema.tables["business"]


def test_the_types_are_map_data_type_of_the_agents_logical_types(gen):
    # Flat 46810-46813: the logical -> physical name table map_data_type reads.
    source = agent_notebook_source()
    names = gen._literal(source, "_PHYSICAL_TYPE_NAMES")
    business = gen._literal(source, "TABLE_BUSINESS_SCHEMA")["properties"]
    assert names["timestamp"] == "TIMESTAMP" and names["bigint"] == "BIGINT" and names["double"] == "DOUBLE"
    assert dict(registry_schema().tables["business"]) == {
        c: names[p["type"]] for c, p in business.items()
    }


@pytest.mark.parametrize("mutation, error", [
    (lambda s: s.replace("for table, schema in (", "for tbl, sch in ("), "loop"),
    (lambda s: s.replace('_PHYSICAL_TYPE_NAMES.get(_base_t, "STRING")', '_TYPES.get(_base_t, "STRING")'),
     "map_data_type"),
    (lambda s: s.replace('"completion_date": {"type": "timestamp"}', '"completion_date": {"type": "decimal(10,2)"}'),
     "DECIMAL"),
    (lambda s: s.replace("CREATE TABLE IF NOT EXISTS {db}", "CREATE OR REPLACE TABLE {db}"),
     "CREATE TABLE IF NOT EXISTS"),
])
def test_the_generator_refuses_agent_code_it_does_not_mirror(gen, mutation, error):
    source = agent_notebook_source()
    mutated = mutation(source)
    assert mutated != source
    with pytest.raises(gen.GenerationError, match=error):
        gen.extract("nb.ipynb", mutated)


@pytest.mark.parametrize("function, edit", [
    ("_ensure_metamodel_registry", ('spark.sql(f"CREATE SCHEMA IF NOT EXISTS {db}")',
                                    'spark.sql(f"CREATE SCHEMA IF NOT EXISTS {db} MANAGED LOCATION \'x\'")')),
    ("map_data_type", ('    name = _PHYSICAL_TYPE_NAMES.get(_base_t, "STRING")\n    if not to_pyspark:',
                       '    name = _PHYSICAL_TYPE_NAMES.get(_base_t, "STRING")\n    if not to_pyspark and name:')),
])
def test_an_edit_to_the_mirrored_agent_code_changes_the_json(gen, function, edit):
    """The DDL shape is pinned too: the source sha256 of the two functions the
    app mirrors is in the JSON, so an edit that keeps the columns still fails."""
    source = agent_notebook_source()
    mutated = source.replace(*edit, 1)
    assert mutated != source
    before, after = gen.extract("nb.ipynb", source), gen.extract("nb.ipynb", mutated)
    assert after["tables"] == before["tables"]
    assert after["source_sha256"][function] != before["source_sha256"][function]
    assert gen.render(after) != SCHEMA_JSON.read_text()


def _columns_of(statement: str) -> tuple[str, list[str]]:
    m = re.match(r"INSERT INTO `[^`]+`\.`_metamodel`\.`?(\w+)`?\s*\(([^)]*)\)", statement)
    assert m, statement
    return m.group(1), [c.strip().strip("`") for c in m.group(2).split(",")]


def _capturing_ws(scalar: str = "0"):
    ws = MagicMock()
    statements: list[str] = []

    def execute(*_a, statement=None, **_kw):
        statements.append(statement)
        return response([[scalar]])

    ws.statement_execution.execute_statement.side_effect = execute
    return ws, statements


def _model() -> dict:
    return {"domains": [{"name": "d", "products": [{"name": "p", "attributes": [{"name": "a"}]}]}]}


def test_the_import_writer_names_only_registry_columns(monkeypatch):
    monkeypatch.setattr(import_metamodel_writer, "ensure_metamodel_registry", lambda *a, **k: [])
    ws, statements = _capturing_ws()
    out = import_metamodel_writer.write_metamodel(
        ws, catalog="cat", warehouse_id="wh", model_json=_model(), business_name="Acme",
        scope="ecm", version=1, wait_mode="request",
    )
    assert out["errors"] == []
    _assert_registry_columns(statements, {"business", "domain", "product", "attribute"})


def test_the_delta_writer_names_only_registry_columns(monkeypatch):
    monkeypatch.setattr("vibe_modeling.backend.model_sync.ensure_metamodel_registry", lambda *a, **k: [])
    ws, statements = _capturing_ws()
    assert ModelSyncService(None, ws, "wh").write_model_to_delta("cat", "acme", "1", "ecm", "", _model())
    _assert_registry_columns([s for s in statements if s.startswith("INSERT")],
                             {"business", "domain", "product", "attribute"})


def _assert_registry_columns(statements: list[str], tables: set[str]) -> None:
    schema = registry_schema()
    seen = set()
    for statement in statements:
        table, cols = _columns_of(statement)
        allowed = {c for c, _ in schema.tables[table]} | {c for c, _ in schema.business_migration_columns}
        assert set(cols) <= allowed, (table, set(cols) - allowed)
        seen.add(table)
    assert seen == tables
