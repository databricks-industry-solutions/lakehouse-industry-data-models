"""Drift-test foundation: the recording UC fake (``_drift/fake_uc.py``) and the
Lakebase/UC consistency checker (``_drift/consistency.py``).

The fake must behave like the real side where the app depends on it (row
matching, SDK error types, writer row shapes); the checker must pass on a
consistent state and name each kind of drift.
"""
from __future__ import annotations

import inspect
import os
import re
import sqlite3
import subprocess
import sys
import textwrap
import types
from datetime import datetime, timedelta, timezone
from pathlib import Path
from unittest.mock import MagicMock

import pytest
from databricks.sdk.errors import AlreadyExists, BadRequest, NotFound, ResourceAlreadyExists
from sqlmodel import Session, select

from vibe_modeling.backend.core._paths import version_dir_candidates
from vibe_modeling.backend.core._sql import SqlStatementError, run as sql_run
from vibe_modeling.backend.db_models import (
    AgentConfig, Attribute, Business, MetamodelCleanup, ModelVersion, ModelVersionInstall, Product,
)
from vibe_modeling.backend.initial_sync import InitialSyncService
from vibe_modeling.backend.model_sync import ModelSyncService
from vibe_modeling.backend.oob_detector import OobDetector
from vibe_modeling.backend.services import import_metamodel_writer, industry_download, industry_kickstart, metamodel_registry
from vibe_modeling.backend.services.operations import uninstall as uninstall_op
from vibe_modeling.backend.services.import_metamodel_writer import write_metamodel
from vibe_modeling.backend.services.metamodel_setup import MetamodelSetupError, ensure_metamodel_schema_and_volume

from ._drift.consistency import assert_lakebase_metamodel_consistent, check_lakebase_metamodel_consistency
from ._drift.fake_uc import REGISTRY_TABLES, FakeUC, RegistryKey, UnrecordedSQLError
from ._drift.fixtures import WAREHOUSE_ID, fake_uc, mock_model, seed_synced_version  # noqa: F401

CAT = "drift_cat"
MODEL_COUNTS = (2, 3, 10)
TEST_APP = Path(__file__).resolve().parent


def _svc(session, fake_uc, warehouse_id=WAREHOUSE_ID):
    return ModelSyncService(session, fake_uc.ws, warehouse_id)


# ---------------------------------------------------------------------------
# The fake workspace
# ---------------------------------------------------------------------------


class TestFakeWorkspace:

    def test_statement_execution_raises_and_records(self):
        fake = FakeUC()
        with pytest.raises(UnrecordedSQLError, match="unrecorded SQL"):
            fake.ws.statement_execution.execute_statement(warehouse_id="w", statement="SELECT 1")
        with pytest.raises(UnrecordedSQLError):
            fake.ws.statement_execution.get_statement("abc")
        assert fake.unrecorded_sql[0] == "SELECT 1"
        with pytest.raises(AssertionError, match="no seam covering it"):
            fake.assert_no_unrecorded_sql()

    def test_sql_through_the_strict_helper_is_refused_and_recorded(self):
        """``core/_sql`` wraps the raise in ``SqlStatementError``; the statement
        is still recorded, so the ``fake_uc`` fixture fails the test."""
        fake = FakeUC()
        with pytest.raises(SqlStatementError, match="unrecorded SQL"):
            sql_run(fake.ws, "w", "DELETE FROM `c`.`_metamodel`.`business`")
        assert fake.unrecorded_sql == ["DELETE FROM `c`.`_metamodel`.`business`"]

    def test_files_round_trip_and_listing(self):
        fake = FakeUC()
        root = f"/Volumes/{CAT}/_metamodel/vol_root/business/acme/v1/mvm"
        fake.put_file(f"{root}/model.json", {"domains": []})
        fake.put_file(f"{root}/docs/readme.md", "hi")

        assert fake.ws.files.download(f"{root}/model.json").contents.read() == b'{"domains": []}'
        assert fake.ws.files.get_metadata(f"{root}/docs/readme.md").content_length == 2
        entries = {e.name: e.is_directory for e in fake.ws.files.list_directory_contents(root)}
        assert entries == {"docs": True, "model.json": False}
        fake.ws.files.get_directory_metadata(root)
        assert fake.is_dir(f"/Volumes/{CAT}/_metamodel/vol_root/business")
        with pytest.raises(NotFound):
            fake.ws.files.download(f"{root}/missing.json")
        with pytest.raises(NotFound):
            list(fake.ws.files.list_directory_contents(f"{root}/nope"))
        assert [c.seam for c in fake.calls][:3] == ["files.download", "files.get_metadata", "files.list_directory_contents"]

    def test_upload_needs_the_volume_and_honours_overwrite(self):
        fake = FakeUC()
        path = f"/Volumes/{CAT}/_metamodel/vol_root/x.json"
        with pytest.raises(NotFound, match="volume"):
            fake.ws.files.upload(path, b"{}")
        fake.add_metamodel(CAT)
        fake.ws.files.upload(path, b"{}")
        fake.ws.files.upload(path, b"[]")
        with pytest.raises(AlreadyExists):
            fake.ws.files.upload(path, b"{}", overwrite=False)
        assert fake.read_json(path) == []

    def test_delete_directory_refuses_non_empty(self):
        fake = FakeUC()
        fake.put_file(f"/Volumes/{CAT}/_metamodel/vol_root/a/b.json", "{}")
        with pytest.raises(BadRequest):
            fake.ws.files.delete_directory(f"/Volumes/{CAT}/_metamodel/vol_root/a")
        fake.ws.files.delete(f"/Volumes/{CAT}/_metamodel/vol_root/a/b.json")
        fake.ws.files.create_directory(f"/Volumes/{CAT}/_metamodel/vol_root/a")
        fake.ws.files.delete_directory(f"/Volumes/{CAT}/_metamodel/vol_root/a")
        assert not fake.is_dir(f"/Volumes/{CAT}/_metamodel/vol_root/a")

    def test_schema_and_volume_errors_match_unity_catalog(self):
        fake = FakeUC()
        fake.add_catalog(CAT)
        fake.ws.schemas.create(name="s", catalog_name=CAT)
        with pytest.raises(BadRequest, match="SCHEMA_ALREADY_EXISTS"):
            fake.ws.schemas.create(name="s", catalog_name=CAT)
        fake.ws.volumes.create(catalog_name=CAT, schema_name="s", name="v", volume_type="MANAGED")
        with pytest.raises(ResourceAlreadyExists):
            fake.ws.volumes.create(catalog_name=CAT, schema_name="s", name="v", volume_type="MANAGED")
        with pytest.raises(NotFound):
            fake.ws.schemas.get(f"{CAT}.missing")
        with pytest.raises(BadRequest, match="not empty"):
            fake.ws.schemas.delete(f"{CAT}.s")
        fake.ws.schemas.delete(f"{CAT}.s", force=True)
        assert [s.name for s in fake.ws.schemas.list(catalog_name=CAT)] == []

    def test_app_metamodel_setup_runs_on_the_fake(self):
        fake = FakeUC()
        fake.add_catalog(CAT)
        created = ensure_metamodel_schema_and_volume(fake.ws, CAT)
        assert created == [f"schema {CAT}._metamodel", f"managed volume {CAT}._metamodel.vol_root"]
        assert ensure_metamodel_schema_and_volume(fake.ws, CAT) == []
        assert fake.ws.volumes.read(f"{CAT}._metamodel.vol_root").name == "vol_root"

    def test_tables_list_shows_registry_and_model_tables(self):
        fake = FakeUC()
        fake.add_metamodel(CAT)
        fake.add_schema(CAT, "acme_sales", tables=("orders", "returns"))
        assert [t.name for t in fake.ws.tables.list(catalog_name=CAT, schema_name="_metamodel")] == [
            "attribute", "business", "domain", "product",
        ]
        assert [t.name for t in fake.ws.tables.list(catalog_name=CAT, schema_name="acme_sales")] == ["orders", "returns"]
        assert [c.name for c in fake.ws.catalogs.list()] == [CAT]

    def test_other_attributes_fall_through_to_a_mock(self):
        fake = FakeUC()
        assert fake.ws.config.host.startswith("https://")
        fake.ws.jobs.run_now.return_value = MagicMock(run_id=7)
        assert fake.ws.jobs.run_now(job_id=1).run_id == 7
        assert fake.calls == []

    def test_fixture_fails_a_test_that_swallows_unrecorded_sql(self, tmp_path):
        """The ``fake_uc`` fixture errors a test whose code caught the
        ``UnrecordedSQLError``; a test without stray SQL passes."""
        test_file = tmp_path / "test_swallowed_sql.py"
        test_file.write_text(textwrap.dedent(f"""
            import sys
            sys.path.insert(0, {str(TEST_APP)!r})
            from _drift.fixtures import fake_uc  # noqa: F401

            def test_swallows(fake_uc):
                try:
                    fake_uc.ws.statement_execution.execute_statement(warehouse_id="w", statement="DROP SCHEMA x")
                except Exception:
                    pass

            def test_clean(fake_uc):
                fake_uc.add_metamodel("c")
        """))
        out = subprocess.run(
            [sys.executable, "-m", "pytest", "-q", "-p", "no:cacheprovider", str(test_file)],
            cwd=tmp_path, capture_output=True, text=True, timeout=300, env=dict(os.environ),
        )
        report = out.stdout + out.stderr
        assert out.returncode == 1, report
        assert "2 passed, 1 error" in report, report
        assert "ERROR at teardown of test_swallows" in report, report
        assert "no seam covering it" in report and "DROP SCHEMA x" in report, report


# ---------------------------------------------------------------------------
# The patched seams, through the real services
# ---------------------------------------------------------------------------


class TestSeams:

    def test_seam_signatures_match_the_real_methods(self):
        real = {
            "write_model_to_delta": inspect.signature(ModelSyncService.write_model_to_delta),
            "delete_metamodel_rows": inspect.signature(ModelSyncService.delete_metamodel_rows),
            "_query_delta_table": inspect.signature(ModelSyncService._query_delta_table),
        }
        real_query_businesses = inspect.signature(InitialSyncService._query_businesses)
        real_dry_runs = inspect.signature(InitialSyncService._query_dry_run_keys)
        real_oob = inspect.signature(OobDetector._query_completed_versions)
        real_seed = inspect.signature(import_metamodel_writer.seed_metamodel_one)
        real_release = inspect.signature(metamodel_registry.set_deploy_status)
        with FakeUC().patched():
            for name, sig in real.items():
                assert list(inspect.signature(getattr(ModelSyncService, name)).parameters) == list(sig.parameters), name
            assert list(inspect.signature(InitialSyncService._query_businesses).parameters) == list(
                real_query_businesses.parameters
            )
            assert list(inspect.signature(InitialSyncService._query_dry_run_keys).parameters) == list(
                real_dry_runs.parameters
            )
            assert list(inspect.signature(OobDetector._query_completed_versions).parameters) == list(
                real_oob.parameters
            )
            assert list(inspect.signature(import_metamodel_writer.seed_metamodel_one).parameters) == ["ws"] + [
                p for p in real_seed.parameters if p != "ws"
            ]
            assert list(inspect.signature(uninstall_op.set_deploy_status).parameters) == list(
                real_release.parameters
            )

    def test_patches_every_seed_binding_and_restores_them(self):
        original = import_metamodel_writer.seed_metamodel_one
        fake = FakeUC()
        with fake.patched():
            for mod in (import_metamodel_writer, industry_download, industry_kickstart):
                assert mod.seed_metamodel_one == fake._seed_metamodel_one, mod.__name__
        for mod in (import_metamodel_writer, industry_download, industry_kickstart):
            assert mod.seed_metamodel_one is original

    def test_patched_restores_a_binding_taken_inside_the_block(self):
        original = import_metamodel_writer.seed_metamodel_one
        name = "vibe_modeling._drift_late_binder"
        late = types.ModuleType(name)
        fake = FakeUC()
        try:
            with fake.patched():
                sys.modules[name] = late
                exec("from vibe_modeling.backend.services.import_metamodel_writer import seed_metamodel_one",
                     late.__dict__)
                assert late.seed_metamodel_one == fake._seed_metamodel_one
            assert late.seed_metamodel_one is original
        finally:
            sys.modules.pop(name, None)

    def test_a_v_prefixed_stored_version_is_missed(self, engine, fake_uc):
        """The readers and the delete strip ``v`` from the query only, so a
        stored ``"v2"`` is an orphan to them, as against a warehouse."""
        fake_uc.add_metamodel(CAT)
        import_metamodel_writer.seed_metamodel_one(
            fake_uc.ws, catalog=CAT, warehouse_id="w", model_json=mock_model(), business_name="acme",
            scope="mvm", version="v2", log_prefix="t", wait_mode="request",
        )
        with Session(engine) as session:
            svc = _svc(session, fake_uc)
            assert svc.load_model_from_delta_tables(CAT, "acme", "2", "mvm") is None
            assert svc.load_model_from_delta_tables(CAT, "acme", "v2", "mvm") is None
            assert svc.delete_metamodel_rows(CAT, "acme", "v2", "mvm") is False
        assert [e.key.version for e in fake_uc.registry(CAT)] == ["v2"]
        assert fake_uc.registry_entry(CAT, "acme", 2, "mvm") is None

    def test_write_model_to_delta_lands_rows_and_is_idempotent(self, engine, fake_uc):
        fake_uc.add_metamodel(CAT)
        with Session(engine) as session:
            svc = _svc(session, fake_uc)
            assert svc.write_model_to_delta(CAT, "Acme_Co", "v1", "mvm", "/Volumes/x", mock_model()) is True
            assert svc.write_model_to_delta(CAT, "acme_co", "1", "MVM", "/Volumes/x", mock_model()) is False
        entry = fake_uc.registry_entry(CAT, "acme_co", 1, "mvm")
        assert (entry.business_rows, entry.domains, entry.products, entry.attributes) == (1, *MODEL_COUNTS)
        assert entry.business_values == ["Acme_Co"]
        assert len(fake_uc.calls_to("write_model_to_delta")) == 2

    def test_write_model_to_delta_without_warehouse_writes_nothing(self, engine, fake_uc):
        fake_uc.add_metamodel(CAT)
        with Session(engine) as session:
            assert _svc(session, fake_uc, warehouse_id="").write_model_to_delta(
                CAT, "acme", "1", "mvm", "", mock_model()) is False
        assert fake_uc.registry(CAT) == []

    def test_write_model_to_delta_creates_the_registry_in_a_catalog_the_agent_never_ran_in(self, engine, fake_uc):
        fake_uc.add_catalog("other")
        with Session(engine) as session:
            assert _svc(session, fake_uc).write_model_to_delta("other", "acme", "1", "mvm", "", mock_model())
        assert [e.key for e in fake_uc.registry("other")] == [RegistryKey("other", "acme", "1", "mvm")]
        assert fake_uc.columns("other", "business")[-1] == ("deploy_status", "STRING")

    def test_write_model_to_delta_into_a_missing_catalog_refuses_and_writes_nothing(self, engine, fake_uc):
        with Session(engine) as session, pytest.raises(MetamodelSetupError):
            _svc(session, fake_uc).write_model_to_delta("other", "acme", "1", "mvm", "", mock_model())
        assert fake_uc.registry("other") == []
        assert fake_uc.calls_to("sql.ddl") == []

    def test_delete_metamodel_rows_matches_like_lower(self, engine, fake_uc):
        fake_uc.add_agent_version(CAT, "Acme Co", 1, "mvm", mock_model())
        fake_uc.add_agent_version(CAT, "Acme Co", 1, "ecm", mock_model())
        with Session(engine) as session:
            svc = _svc(session, fake_uc)
            assert svc.delete_metamodel_rows(CAT, "acme_co", "2", "mvm") is False
            assert svc.delete_metamodel_rows(CAT, "acme_co", "1", "mvm") is True
            assert svc.delete_metamodel_rows(CAT, "acme_co", "1", "mvm") is False
            assert svc.delete_metamodel_rows("no_registry", "acme_co", "1", "ecm") is False
        assert [e.key.scope for e in fake_uc.registry(CAT)] == ["ecm"]

    def test_delta_fallback_read_assembles_the_model(self, engine, fake_uc):
        fake_uc.add_agent_version(CAT, "acme", 3, "ecm", mock_model(), write_model_json=False)
        with Session(engine) as session:
            svc = _svc(session, fake_uc)
            assert svc.load_model_json_from_volumes(CAT, "acme", "3", "ecm") is None
            model = svc.load_model_from_delta_tables(CAT, "acme", "v3", "Expanded Coverage Model - ECM")
            assert svc.load_model_from_delta_tables("unknown", "acme", "3", "ecm") is None
        products = [p for d in model["domains"] for p in d["products"]]
        assert (len(model["domains"]), len(products), sum(len(p["attributes"]) for p in products)) == MODEL_COUNTS
        assert {c.args["table"] for c in fake_uc.calls_to("query_delta_table")} == {"domain", "product", "attribute"}

    def test_seed_metamodel_one_mirrors_the_writer(self, fake_uc):
        fake_uc.add_metamodel(CAT)
        args = dict(model_json={"model": mock_model()}, business_name="acme co", scope="MVM", version=2,
                    log_prefix="t", wait_mode="background")
        assert industry_kickstart.seed_metamodel_one(fake_uc.ws, catalog=CAT, warehouse_id="", **args) is None
        summary = industry_download.seed_metamodel_one(fake_uc.ws, catalog=CAT, warehouse_id="w", **args)
        assert summary == {"business": 1, "domain": 2, "product": 3, "attribute": 10, "errors": [], "still_running": []}
        import_metamodel_writer.seed_metamodel_one(fake_uc.ws, catalog=CAT, warehouse_id="w", **args)
        entry = fake_uc.registry_entry(CAT, "acme_co", 2, "mvm")
        assert entry.business_values == ["Acme_Co", "Acme_Co"]
        assert entry.session_ids == ["0", "0"]
        missing = import_metamodel_writer.seed_metamodel_one(fake_uc.ws, catalog="nope", warehouse_id="w", **args)
        assert missing["errors"] and missing["business"] == 0
        assert [c.args["wait_mode"] for c in fake_uc.calls_to("seed_metamodel_one")] == ["background"] * 4

    def test_query_businesses_returns_distinct_rows(self, fake_uc):
        fake_uc.add_agent_version(CAT, "acme", 1, "mvm", mock_model())
        fake_uc.add_agent_version(CAT, "acme", 2, "mvm", mock_model(), completed=False)
        rows = InitialSyncService(None, fake_uc.ws, WAREHOUSE_ID)._query_businesses(CAT)
        assert [(r["business"], r["version"], r["completed_percent"]) for r in rows] == [
            ("Acme", "1", "100.0"), ("Acme", "2", "50.0"),
        ]
        assert InitialSyncService(None, fake_uc.ws, WAREHOUSE_ID)._query_businesses("other") is None


# ---------------------------------------------------------------------------
# Fidelity: the fake stores what the real writers INSERT and selects what the
# real WHERE clauses select
# ---------------------------------------------------------------------------


def _capturing_ws(scalar: str = "0", with_result: bool = True):
    """A ``WorkspaceClient`` mock that records every statement; scalar reads
    return ``scalar``, other reads return no rows."""
    ws = MagicMock()
    statements: list[str] = []

    def execute(**kwargs):
        statements.append(kwargs["statement"])
        result = MagicMock()
        result.status.error = None
        result.status.state.value = "SUCCEEDED"
        result.result.data_array = [[scalar]]
        if not with_result:
            result.manifest = None
            result.result.data_array = None
        return result

    ws.statement_execution.execute_statement.side_effect = execute
    return ws, statements


_INSERT = re.compile(r"INSERT INTO `[^`]+`\.`_metamodel`\.`?(\w+)`?\s*\(([^)]*)\)\s*VALUES\s*(.*)\Z", re.S)
_BARE = re.compile(r"TIMESTAMP '[^']*'|CURRENT_TIMESTAMP\(\)|NULL|-?\d+(?:\.\d+)?")
VOLATILE = {"completion_date", "session_started_at", "last_updated_at"}


def _values(text: str) -> list[list]:
    """The tuples of a ``VALUES (...), (...)`` clause: quoted strings
    unescaped, ``NULL`` as ``None``, other literals as their text."""
    rows: list[list] = []
    row: list | None = None
    i = 0
    while i < len(text):
        c = text[i]
        if row is None:
            if c == "(":
                row = []
            i += 1
        elif c in " ,\n":
            i += 1
        elif c == ")":
            rows.append(row)
            row = None
            i += 1
        elif c == "'":
            buf, j = [], i + 1
            while True:
                ch = text[j]
                if ch == "\\":
                    buf.append(text[j + 1])
                    j += 2
                elif ch == "'" and text[j + 1:j + 2] == "'":
                    buf.append("'")
                    j += 2
                elif ch == "'":
                    break
                else:
                    buf.append(ch)
                    j += 1
            row.append("".join(buf))
            i = j + 1
        else:
            m = _BARE.match(text, i)
            assert m, f"unparsed SQL literal at {text[i:i + 40]!r}"
            row.append(None if m.group(0) == "NULL" else m.group(0))
            i = m.end()
    return rows


def _inserted(statements: list[str]) -> dict[str, list[dict]]:
    """The rows the captured INSERTs write, per table, keyed by the INSERT's
    own column list in its order."""
    tables: dict[str, list[dict]] = {t: [] for t in REGISTRY_TABLES}
    for sql in statements:
        m = _INSERT.match(sql)
        if not m:
            continue
        cols = [c.strip().strip("`") for c in m.group(2).split(",")]
        for values in _values(m.group(3)):
            assert len(values) == len(cols), (cols, values)
            tables[m.group(1)].append(dict(zip(cols, values)))
    return tables


def _comparable(rows: list[dict]) -> list[list[tuple]]:
    return [[(k, v) for k, v in r.items() if k not in VOLATILE] for r in rows]


def _divergent_model() -> dict:
    """A model whose fields tell the writers' precedences and fallbacks apart:
    ``name`` and ``product``/``attribute`` both set, ``references`` and
    ``reference`` both set, list tags, a NULL field, no table or column name."""
    return {
        "description": "It's a model", "industry_alignment": "Retail",
        "domains": [{
            "name": "sales", "division": None, "description": "Sales", "database_name": "sales_db",
            "references": "d-refs", "reference": "d-ref", "tags": ["core", "pii"],
            "products": [{
                "name": "orders", "product": "order_p", "subdomain": "web", "type": "Fact",
                "references": "p-refs", "reference": "p-ref", "tags": ["gold"], "primary_key": "id",
                "attributes": [
                    {"name": "id_name", "attribute": "id_attr", "type": "BIGINT", "tags": ["pk"],
                     "value_regex": "^\\d+$", "reference": "a-ref"},
                    {"attribute": "amount", "column_name": "amount_col", "type": "DECIMAL",
                     "description": "O'Brien's total"},
                ],
            }],
        }],
    }


MODELS = pytest.mark.parametrize("model", [mock_model(), _divergent_model()], ids=["mock_model", "divergent"])


class TestWriterFidelity:
    """The fake stores, per table, the column list and values the real
    writers' INSERTs carry (current-time columns aside)."""

    @MODELS
    def test_seed_rows_match_write_metamodel(self, model):
        ws, statements = _capturing_ws()
        summary = write_metamodel(ws, catalog=CAT, warehouse_id="w", model_json={"model": model},
                                  business_name="acme co", scope="mvm", version=4,
                                  wait_mode="request")
        assert summary["errors"] == []
        fake = FakeUC()
        fake.add_metamodel(CAT)
        with fake.patched():
            import_metamodel_writer.seed_metamodel_one(
                fake.ws, catalog=CAT, warehouse_id="w", model_json={"model": model},
                business_name="acme co", scope="mvm", version=4, log_prefix="t", wait_mode="request",
            )
        real = _inserted(statements)
        for table in REGISTRY_TABLES:
            assert _comparable(fake.rows(CAT, table)) == _comparable(real[table]), table
        assert fake.rows(CAT, "business")[0]["business"] == "Acme_Co"

    @MODELS
    def test_delta_rows_match_write_model_to_delta(self, engine, model):
        ws, statements = _capturing_ws()
        with Session(engine) as session:
            assert ModelSyncService(session, ws, "w").write_model_to_delta(
                CAT, "Acme Co", "v5", "ecm", "/Volumes/p", model) is True
        fake = FakeUC()
        fake.add_metamodel(CAT)
        with fake.patched(), Session(engine) as session:
            ModelSyncService(session, fake.ws, "w").write_model_to_delta(
                CAT, "Acme Co", "v5", "ecm", "/Volumes/p", model)
        real = _inserted(statements)
        for table in REGISTRY_TABLES:
            assert _comparable(fake.rows(CAT, table)) == _comparable(real[table]), table
        assert fake.rows(CAT, "business")[0]["business"] == "Acme Co"

    def test_the_two_writers_name_attributes_differently(self, engine):
        """``write_metamodel`` prefers ``name`` and fills empty table and
        column names; ``write_model_to_delta`` prefers ``attribute`` and
        writes them as given."""
        fake = FakeUC()
        fake.add_metamodel(CAT)
        with fake.patched(), Session(engine) as session:
            import_metamodel_writer.seed_metamodel_one(
                fake.ws, catalog=CAT, warehouse_id="w", model_json=_divergent_model(),
                business_name="seeded", scope="mvm", version=1, log_prefix="t", wait_mode="request",
            )
            ModelSyncService(session, fake.ws, "w").write_model_to_delta(
                CAT, "delta", "1", "mvm", "", _divergent_model())
        by_business = {}
        for r in fake.rows(CAT, "attribute"):
            by_business.setdefault(r["business"], []).append((r["attribute"], r["column_name"]))
        assert by_business == {
            "Seeded": [("id_name", "id_name"), ("amount", "amount_col")],
            "delta": [("id_attr", ""), ("amount", "amount_col")],
        }
        products = {r["business"]: (r["product"], r["table_name"], r["reference"]) for r in fake.rows(CAT, "product")}
        assert products == {"Seeded": ("orders", "orders", "p-refs"), "delta": ("orders", "", "p-ref")}


STORED = [
    ("Acme_Co", "1", "mvm"), ("Acme_Co", "1", "mvm"), ("acme_co", "1", "mvm"), ("ACME_CO", "1", "ecm"),
    ("Acme_Co", "v1", "mvm"), ("Acme_Co", "1", "Minimum Viable Model - MVM"), ("Acme_Co", "1", None),
    ("Acme_Co", "1", ""), ("Acme_Co", "2", "mvm"), ("Other", "1", "mvm"), (None, "1", "mvm"),
    ("Acme_Co", None, "mvm"),
]
"""Stored registry keys: mixed case, a duplicate, a ``v``-prefixed version,
a long-form scope, NULL and empty scopes, NULL business and version."""

QUERIES = [
    ("acme_co", "1", "mvm"), ("Acme_Co", "v1", "mvm"), ("acme_co", "1", ""),
    ("acme_co", "1", "Minimum Viable Model - MVM"), ("ACME_CO", "2", "ecm"), ("acme_co", "v2", ""),
    ("acme_co", "1", "ecm"), ("acme_co", "", "mvm"),
]
COLUMNS = ("rid", "business", "version", "model_scope", "processing_status", "completed_percent",
           "completion_date", "session_id", "catalog")


PERCENTS = ("100.0", "100.0", "50.0", None, "100", "abc")
DATES = ("2024-01-01 00:00:00", "2024-01-01 00:00:00", None, "2024-02-01 00:00:00")
SESSIONS = ("17", "17", None, "0", "42")
ROW_CATALOGS = ("cat_a", "cat_a", None, "", "cat_b")


def _stored_rows() -> list[dict]:
    """``STORED`` with run columns that vary: finished, partial, NULL and
    non-numeric percents, NULL completion dates. The duplicate first two rows
    stay identical."""
    return [
        dict(zip(COLUMNS, (str(i), b, v, s, "done", PERCENTS[i % len(PERCENTS)], DATES[i % len(DATES)],
                           SESSIONS[i % len(SESSIONS)], ROW_CATALOGS[i % len(ROW_CATALOGS)])))
        for i, (b, v, s) in enumerate(STORED)
    ]


def _sqlite(rows: list[dict]) -> sqlite3.Connection:
    con = sqlite3.connect(":memory:")
    con.execute(f"CREATE TABLE t ({', '.join(f'{c} TEXT' for c in COLUMNS)})")
    con.executemany(f"INSERT INTO t VALUES ({', '.join('?' for _ in COLUMNS)})",
                    [[r[c] for c in COLUMNS] for r in rows])
    return con


def _selected_by(where: str) -> set[str]:
    """The ``rid`` of every stored row the real WHERE clause selects in SQLite."""
    return {rid for (rid,) in _sqlite(_stored_rows()).execute(f"SELECT rid FROM t WHERE {where}")}


def _where(sql: str) -> str:
    return sql.split(" WHERE ", 1)[1]


def _fake_with_rows(*tables: str) -> FakeUC:
    fake = FakeUC()
    for table in tables:
        fake.add_rows(CAT, table, _stored_rows())
    return fake


ON_QUERIES = pytest.mark.parametrize("business,version,scope", QUERIES)


class TestMatchingFidelity:
    """Each seam selects the rows the real method's SQL selects: its captured
    WHERE clause runs in SQLite against the rows the fake holds."""

    @ON_QUERIES
    def test_delta_reader(self, business, version, scope):
        ws, statements = _capturing_ws(with_result=False)
        assert ModelSyncService(None, ws, "w")._query_delta_table(
            CAT, "_metamodel", "domain", business, version, scope) == []
        fake = _fake_with_rows("domain")
        with fake.patched():
            rows = ModelSyncService(None, fake.ws, "w")._query_delta_table(
                CAT, "_metamodel", "domain", business, version, scope)
        assert {r["rid"] for r in rows} == _selected_by(_where(statements[0]))

    @ON_QUERIES
    def test_delete(self, business, version, scope):
        ws, statements = _capturing_ws(scalar="1")
        ModelSyncService(None, ws, "w").delete_metamodel_rows(CAT, business, version, scope)
        assert _where(statements[0]) == _where(statements[1])
        expected = _selected_by(_where(statements[0]))
        fake = _fake_with_rows("business", "domain")
        with fake.patched():
            deleted = ModelSyncService(None, fake.ws, "w").delete_metamodel_rows(CAT, business, version, scope)
        assert deleted is bool(expected)
        left = {r["rid"] for r in fake.rows(CAT, "domain")}
        assert {r["rid"] for r in _stored_rows()} - left == expected

    @ON_QUERIES
    def test_write_idempotency_guard(self, business, version, scope, monkeypatch):
        ws, statements = _capturing_ws()
        with monkeypatch.context() as m:
            # The capture is the guard's WHERE; the registry setup is covered on the fake.
            m.setattr("vibe_modeling.backend.model_sync.ensure_metamodel_registry", lambda *a, **k: [])
            ModelSyncService(None, ws, "w").write_model_to_delta(CAT, business, version, scope, "", {"domains": []})
        exists = bool(_selected_by(_where(statements[0])))
        fake = _fake_with_rows("business")
        with fake.patched():
            wrote = ModelSyncService(None, fake.ws, "w").write_model_to_delta(
                CAT, business, version, scope, "", {"domains": []})
        assert wrote is not exists

    @pytest.mark.parametrize("business,version,scope,catalog", [
        ("acme_co", 1, "mvm", "cat_a"), ("ACME_CO", 1, "ecm", "cat_b"), ("acme_co", 2, "mvm", "CAT_A"),
        ("other", 1, "mvm", "cat_a"), ("acme_co", 1, "mvm", "cat_c"),
    ])
    def test_registry_release(self, business, version, scope, catalog):
        """``set_deploy_status``'s WHERE selects the rows the fake updates."""
        ws, statements = _capturing_ws()
        metamodel_registry.set_deploy_status(ws, "w", catalog, business, version, scope, "dry_run")
        expected = _selected_by(_where(statements[0]))
        fake = FakeUC()
        fake.add_rows(catalog, "business", _stored_rows())
        with fake.patched():
            uninstall_op.set_deploy_status(fake.ws, "w", catalog, business, version, scope, "dry_run")
        assert {r["rid"] for r in fake.rows(catalog, "business") if r.get("deploy_status") == "dry_run"} == expected

    def _select_in_sqlite(self, sql: str) -> list[dict]:
        sql = re.sub(r"`[^`]+`\.`_metamodel`\.`business`", "t", sql).replace(" AS STRING)", " AS TEXT)")
        cur = _sqlite(_stored_rows()).execute(sql)
        names = [d[0] for d in cur.description]
        return [dict(zip(names, row)) for row in cur.fetchall()]

    def _assert_same_rows(self, got: list[dict], expected: list[dict]) -> None:
        assert [(r["business"], r["version"]) for r in got] == [(r["business"], r["version"]) for r in expected]
        assert sorted(map(repr, got)) == sorted(map(repr, expected))

    def test_query_businesses(self):
        ws, statements = _capturing_ws(with_result=False)
        InitialSyncService(None, ws, "w")._query_businesses(CAT)
        expected = self._select_in_sqlite(statements[0])
        fake = _fake_with_rows("business")
        with fake.patched():
            got = InitialSyncService(None, fake.ws, "w")._query_businesses(CAT)
        self._assert_same_rows(got, expected)
        assert 0 < len(got) < len(STORED)

    def test_out_of_band_scan(self):
        ws, statements = _capturing_ws(with_result=False)
        OobDetector(None, ws, "w")._query_completed_versions(CAT)
        expected = self._select_in_sqlite(statements[0])
        fake = _fake_with_rows("business")
        with fake.patched():
            got = OobDetector(None, fake.ws, "w")._query_completed_versions(CAT)
        self._assert_same_rows(got, expected)
        assert 0 < len(got) < len(STORED) - 1


# ---------------------------------------------------------------------------
# The consistency checker
# ---------------------------------------------------------------------------


class TestChecker:

    def test_clean_state_passes(self, engine, fake_uc):
        with Session(engine) as session:
            seed_synced_version(session, fake_uc, catalog=CAT, business_name="Acme Co")
            report = assert_lakebase_metamodel_consistent(session, fake_uc)
        assert report.orphans == []

    def test_missing_registry_row_and_volume_folder(self, engine, fake_uc):
        with Session(engine) as session:
            mv = seed_synced_version(session, fake_uc, catalog=CAT, business_name="Acme Co")
            mv.uc_catalog = mv.files_catalog = "elsewhere"
            session.add(mv)
            session.commit()
            report = check_lakebase_metamodel_consistency(session, fake_uc)
        # The rows left in CAT are not orphans (item 2): the open install row there explains them.
        assert report.items() == {1, 3, 4}
        assert "no registry business row in 'elsewhere'" in str(report.problems[0])

    def test_duplicate_business_rows(self, engine, fake_uc):
        with Session(engine) as session:
            seed_synced_version(session, fake_uc, catalog=CAT, business_name="Acme Co")
            fake_uc.add_agent_version(CAT, "Acme Co", 1, "mvm", mock_model())
            report = check_lakebase_metamodel_consistency(session, fake_uc)
        assert [p.item for p in report.problems] == [1, 1]
        assert "2 registry business rows" in report.problems[0].message
        assert "(2, 3, 10)" in report.problems[1].message and "(4, 6, 20)" in report.problems[1].message

    def test_count_mismatch(self, engine, fake_uc):
        with Session(engine) as session:
            mv = seed_synced_version(session, fake_uc, catalog=CAT, business_name="Acme Co")
            attr = session.exec(
                select(Attribute).join(Product, Attribute.product_id == Product.id).where(Product.version_id == mv.id)
            ).first()
            session.delete(attr)
            session.commit()
            report = check_lakebase_metamodel_consistency(session, fake_uc)
        assert [str(p) for p in report.problems] == [
            f"(1) 'Acme Co' v1 mvm [completed/deployed]: Lakebase (domains, products, attributes) = "
            f"(2, 3, 9), registry in '{CAT}' = (2, 3, 10)"
        ]

    def test_orphan_registry_rows_fail_unless_declared(self, engine, fake_uc):
        fake_uc.add_agent_version(CAT, "Ghost", 7, "ecm", mock_model())
        key = RegistryKey(CAT, "ghost", "7", "ecm")
        with Session(engine) as session:
            report = check_lakebase_metamodel_consistency(session, fake_uc)
            assert [p.item for p in report.problems] == [2]
            allowed = assert_lakebase_metamodel_consistent(session, fake_uc, allow_orphans=[key])
            assert assert_lakebase_metamodel_consistent(session, fake_uc, catalogs=["other"]).orphans == []
        assert allowed.orphans == [key]

    def test_draft_version_maps_its_registry_rows(self, engine, fake_uc):
        """A seeded import draft has rows in the metamodel catalog; the draft
        resolves there through the installation's catalog."""
        fake_uc.add_agent_version(CAT, "Acme Co", 2, "mvm", mock_model())
        with Session(engine) as session:
            session.add(AgentConfig(deployment_catalog=CAT))
            biz = Business(name="Acme Co")
            session.add(biz)
            session.flush()
            session.add(ModelVersion(business_id=biz.id, version=2, scope="mvm", status="draft"))
            session.commit()
            assert_lakebase_metamodel_consistent(session, fake_uc)

    def test_deployed_with_empty_uc_catalog(self, engine, fake_uc):
        with Session(engine) as session:
            session.add(AgentConfig(deployment_catalog=CAT))
            seed_synced_version(session, fake_uc, catalog=CAT, business_name="Acme Co", uc_catalog="")
            report = check_lakebase_metamodel_consistency(session, fake_uc)
        assert [str(p) for p in report.problems] == [
            "(3) 'Acme Co' v1 mvm [completed/deployed]: deployed with an empty uc_catalog"
        ]

    def test_legacy_flat_volume_folder_counts(self, engine, fake_uc):
        with Session(engine) as session:
            mv = seed_synced_version(session, fake_uc, catalog=CAT, business_name="Acme Co")
            nested, flat = version_dir_candidates(CAT, "Acme Co", 1, "mvm")
            model = fake_uc.read_json(f"{nested}/model.json")
            fake_uc.ws.files.delete(f"{nested}/model.json")
            assert [p.item for p in check_lakebase_metamodel_consistency(session, fake_uc).problems] == [4]
            fake_uc.put_file(f"{flat}/model.json", model)
            assert check_lakebase_metamodel_consistency(session, fake_uc).ok, mv.id

    def test_install_rows_must_agree_with_the_version(self, engine, fake_uc):
        now = datetime.now(timezone.utc)
        with Session(engine) as session:
            mv = seed_synced_version(session, fake_uc, catalog=CAT, business_name="Acme Co")
            assert check_lakebase_metamodel_consistency(session, fake_uc).ok
            newer = ModelVersionInstall(version_id=mv.id, catalog="old", installed_at=now + timedelta(days=1))
            session.add(newer)
            session.commit()
            report = check_lakebase_metamodel_consistency(session, fake_uc)
            assert [str(p) for p in report.problems] == [
                f"(3) 'Acme Co' v1 mvm [completed/deployed]: uc_catalog '{CAT}' but the latest open "
                "install row is in 'old'"
            ]
            newer.uninstalled_at = now + timedelta(days=2)
            session.add(newer)
            session.commit()
            assert check_lakebase_metamodel_consistency(session, fake_uc).ok
            mv.deployment_status = "uninstalled"
            session.add(mv)
            session.commit()
            report = check_lakebase_metamodel_consistency(session, fake_uc)
            assert [p.item for p in report.problems] == [3]
            assert f"uninstalled but has open install rows in ['{CAT}']" in report.problems[0].message
            for row in session.exec(select(ModelVersionInstall)).all():
                session.delete(row)
            mv.deployment_status = "deployed"
            session.add(mv)
            session.commit()
            report = check_lakebase_metamodel_consistency(session, fake_uc)
        assert "latest open install row is in None" in str(report.problems)

    def test_install_checks_honour_the_catalog_filter(self, engine, fake_uc):
        with Session(engine) as session:
            session.add(AgentConfig(deployment_catalog=CAT))
            seed_synced_version(session, fake_uc, catalog=CAT, business_name="Acme Co", uc_catalog="")
            assert check_lakebase_metamodel_consistency(session, fake_uc, catalogs=[CAT]).items() == {3}
            assert check_lakebase_metamodel_consistency(session, fake_uc, catalogs=["other"]).ok

    def test_a_draft_with_an_open_install_row(self, engine, fake_uc):
        fake_uc.add_agent_version(CAT, "Acme Co", 2, "mvm", mock_model())
        with Session(engine) as session:
            session.add(AgentConfig(deployment_catalog=CAT))
            biz = Business(name="Acme Co")
            session.add(biz)
            session.flush()
            mv = ModelVersion(business_id=biz.id, version=2, scope="mvm", status="draft")
            session.add(mv)
            session.commit()
            assert check_lakebase_metamodel_consistency(session, fake_uc).ok
            session.add(ModelVersionInstall(version_id=mv.id, catalog=CAT))
            session.commit()
            report = check_lakebase_metamodel_consistency(session, fake_uc)
        assert [str(p) for p in report.problems] == [
            f"(3) 'Acme Co' v2 mvm [draft/{mv.deployment_status}]: a draft with open install rows in ['{CAT}']"
        ]

    def test_unfinished_cleanup_explains_registry_rows(self, engine, fake_uc):
        fake_uc.add_agent_version(CAT, "Gone Co", 5, "ecm", mock_model())
        with Session(engine) as session:
            cleanup = MetamodelCleanup(
                business_segment="gone_co", version=5, scope="ecm", catalog=CAT, reason="version_delete",
                status="done",
            )
            session.add(cleanup)
            session.commit()
            assert [p.item for p in check_lakebase_metamodel_consistency(session, fake_uc).problems] == [2]
            cleanup.status = "failed"
            session.add(cleanup)
            session.commit()
            assert check_lakebase_metamodel_consistency(session, fake_uc).ok
            cleanup.status = "pending"
            session.add(cleanup)
            session.commit()
            assert check_lakebase_metamodel_consistency(session, fake_uc).ok

    def test_assert_lists_every_problem(self, engine, fake_uc):
        fake_uc.add_agent_version(CAT, "Ghost", 1, "mvm", mock_model())
        fake_uc.add_agent_version(CAT, "Ghost", 2, "mvm", mock_model())
        with Session(engine) as session, pytest.raises(AssertionError) as exc:
            assert_lakebase_metamodel_consistent(session, fake_uc)
        assert str(exc.value).count("map to no Lakebase version") == 2


class TestCheckerOnAgentLayouts:
    """The checker on the state an agent run plus an install leave behind."""

    def test_one_catalog_install_is_consistent(self, engine, fake_uc):
        with Session(engine) as session:
            session.add(AgentConfig(deployment_catalog=CAT))
            seed_synced_version(session, fake_uc, catalog=CAT, business_name="Acme Co")
            assert_lakebase_metamodel_consistent(session, fake_uc)

    def test_catalog_per_domain_install_resolves_the_metamodel_catalog(self, engine, fake_uc):
        """Defect 2 of epic 6hm3RqXGchvGQG4H: a Catalog per Division/Domain
        install sets ``uc_catalog`` to ``{base}_mvm_v{N}``, while the agent
        keeps the version's ``_metamodel`` rows and files in the metamodel
        catalog. ``resolve_version_volume_catalog`` reads ``files_catalog``,
        so the registry rows (item 1) and the Volume folder (item 4) are
        found there."""
        with Session(engine) as session:
            session.add(AgentConfig(deployment_catalog=CAT))
            seed_synced_version(
                session, fake_uc, catalog=CAT, business_name="Acme Co", uc_catalog=f"{CAT}_mvm_v1",
            )
            report = check_lakebase_metamodel_consistency(session, fake_uc)
        symptom = [str(p) for p in report.problems if p.item in (1, 4)]
        assert not symptom, symptom
