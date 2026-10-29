"""Tests for deployment_verifier.py — logical vs deployed model comparison."""

import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "..", "src", "app", "src"))

import pytest
from unittest.mock import MagicMock

from sqlalchemy.pool import StaticPool
from sqlmodel import Session, SQLModel, create_engine

from vibe_modeling.backend.db_models import (
    Attribute, Business, Domain, ModelVersion, Product,
)
from vibe_modeling.backend.deployment_verifier import DeploymentVerifier

from _sql_fakes import response, ws_returning


@pytest.fixture
def engine():
    engine = create_engine(
        "sqlite://",
        connect_args={"check_same_thread": False},
        poolclass=StaticPool,
    )
    SQLModel.metadata.create_all(engine)
    return engine


@pytest.fixture
def mock_ws():
    return MagicMock()


def _make_sql_result(rows):
    return response(rows)


def _make_empty_result():
    return response([])


def _seed_model(session):
    """Seed a business with a version, domain, product, and attributes."""
    b = Business(name="test_biz")
    session.add(b)
    session.flush()

    mv = ModelVersion(business_id=b.id, version=1, status="completed", uc_catalog="test_cat")
    session.add(mv)
    session.flush()

    d = Domain(
        version_id=mv.id, name="core", database_name="core_db",
        division="Eng", description="Core domain",
    )
    session.add(d)
    session.flush()

    p = Product(
        version_id=mv.id, domain_id=d.id, name="widget",
        table_name="widget", description="Widget records",
        type="Master", primary_key="widget_id",
    )
    session.add(p)
    session.flush()

    session.add(Attribute(
        product_id=p.id, name="widget_id", column_name="widget_id",
        type="BIGINT", description="PK",
    ))
    session.add(Attribute(
        product_id=p.id, name="name", column_name="name",
        type="STRING", description="Widget name",
    ))
    session.flush()

    return b, mv, d, p


class TestCatalogCheck:
    def test_catalog_exists(self, engine, mock_ws):
        mock_ws.statement_execution.execute_statement.return_value = (
            _make_sql_result([["test_cat"]])
        )
        with Session(engine) as session:
            v = DeploymentVerifier(session, mock_ws, "wh-123")
            result = v.check_catalog("test_cat")

        assert result["exists"] is True
        assert result["catalog"] == "test_cat"
        assert result["error"] is None

    def test_catalog_not_found(self, engine, mock_ws):
        mock_ws.statement_execution.execute_statement.return_value = _make_empty_result()
        with Session(engine) as session:
            v = DeploymentVerifier(session, mock_ws, "wh-123")
            result = v.check_catalog("missing_cat")

        assert result["exists"] is False

    def test_catalog_check_fallback(self, engine, mock_ws):
        """Falls back to information_schema if SHOW CATALOGS fails."""
        call_count = 0

        def side_effect(**kwargs):
            nonlocal call_count
            call_count += 1
            if call_count == 1:
                raise RuntimeError("SHOW CATALOGS not supported")
            return _make_sql_result([["test_cat"]])

        mock_ws.statement_execution.execute_statement.side_effect = side_effect
        with Session(engine) as session:
            v = DeploymentVerifier(session, mock_ws, "wh-123")
            result = v.check_catalog("test_cat")

        assert result["exists"] is True
        assert result["verification_error"] is None
        assert call_count == 2

    @pytest.mark.parametrize("first", [
        response(error="[INSUFFICIENT_PERMISSIONS] User does not have USE CATALOG on test_cat"),
        response(state="RUNNING", statement_id="s1"),
    ], ids=["failed", "timeout"])
    def test_unverifiable_catalog_carries_the_reason(self, engine, first):
        """Both reads fail: the catalog is unverified and verification_error
        says why, sanitized (an email in the error is redacted)."""
        second = response(error="[NO_SUCH_CATALOG_EXCEPTION] reader@example.com cannot see test_cat")
        ws = ws_returning(first, second)
        with Session(engine) as session:
            result = DeploymentVerifier(session, ws, "wh-123").check_catalog("test_cat")

        assert result["exists"] is False
        assert result["error"] == "Could not verify catalog"
        assert result["verification_error"].startswith("Could not verify catalog 'test_cat': ")
        assert "NO_SUCH_CATALOG_EXCEPTION" in result["verification_error"]
        assert "reader@example.com" not in result["verification_error"]
        assert len(ws.statements) == 2


class TestUcSchema:
    def test_returns_structured_data(self, engine, mock_ws):
        """Returns tables, columns, PKs, FKs from information_schema queries."""
        call_count = 0

        def side_effect(**kwargs):
            nonlocal call_count
            call_count += 1
            sql = kwargs.get("statement", "")
            if "information_schema`.`tables" in sql:
                return _make_sql_result([
                    ["core_db", "widget", "BASE TABLE"],
                ])
            if "information_schema`.`columns" in sql:
                return _make_sql_result([
                    ["core_db", "widget", "widget_id", "BIGINT", "1"],
                    ["core_db", "widget", "name", "STRING", "2"],
                ])
            # PKs and FKs return empty
            return _make_empty_result()

        mock_ws.statement_execution.execute_statement.side_effect = side_effect

        with Session(engine) as session:
            v = DeploymentVerifier(session, mock_ws, "wh-123")
            result = v.get_uc_schema("test_cat", ["core_db"])

        assert len(result["tables"]) == 1
        assert result["tables"][0]["table"] == "widget"
        assert len(result["columns"]) == 2
        assert result["primary_keys"] == []
        assert result["foreign_keys"] == []

    def test_empty_schemas_returns_empty(self, engine, mock_ws):
        with Session(engine) as session:
            v = DeploymentVerifier(session, mock_ws, "wh-123")
            result = v.get_uc_schema("test_cat", [])

        assert result == {
            "tables": [], "columns": [], "primary_keys": [], "foreign_keys": [], "verification_error": None,
        }


class TestUcSchemaFailures:
    """A failed, timed-out or missing information_schema read never reads as
    an empty deployment: every list is empty and verification_error is set."""

    @pytest.mark.parametrize("bad", [
        response(error="[INSUFFICIENT_PERMISSIONS] no USE SCHEMA on information_schema"),
        response(state="PENDING", statement_id="s9"),
        response(error="[TABLE_OR_VIEW_NOT_FOUND] `test_cat`.`information_schema`.`columns`"),
    ], ids=["failed", "timeout", "missing_table"])
    def test_a_failed_read_sets_verification_error(self, engine, bad):
        tables = response([["core_db", "widget", "BASE TABLE"]])
        ws = ws_returning(tables, bad)
        with Session(engine) as session:
            result = DeploymentVerifier(session, ws, "wh-123").get_uc_schema("test_cat", ["core_db"])

        assert result["tables"] == result["columns"] == result["primary_keys"] == result["foreign_keys"] == []
        assert result["verification_error"].startswith(
            "Could not read the deployed schema in catalog 'test_cat': "
        )
        if bad.status.state.value == "PENDING":
            ws.statement_execution.cancel_execution.assert_called_once_with("s9")

    def test_compare_with_an_unreadable_schema_lists_nothing_as_model_only(self, engine):
        with Session(engine) as session:
            _seed_model(session)
            session.commit()
        ws = ws_returning(response(error="[INSUFFICIENT_PERMISSIONS] denied"))
        with Session(engine) as session:
            mv = session.exec(
                __import__("sqlmodel", fromlist=["select"]).select(ModelVersion)
            ).first()
            result = DeploymentVerifier(session, ws, "wh-123").compare(mv.id, "test_cat")

        assert result["tables"] == {"model_only": [], "uc_only": [], "both": []}
        assert result["summary"]["model_tables"] == 1
        assert result["summary"]["model_only"] == 0
        assert "INSUFFICIENT_PERMISSIONS" in result["verification_error"]


class TestCompare:
    def test_matching_tables(self, engine, mock_ws):
        """Tables in both logical and UC are reported in 'both'."""
        with Session(engine) as session:
            _seed_model(session)
            session.commit()

        def side_effect(**kwargs):
            sql = kwargs.get("statement", "")
            if "information_schema`.`tables" in sql:
                return _make_sql_result([["core_db", "widget", "BASE TABLE"]])
            if "information_schema`.`columns" in sql:
                return _make_sql_result([
                    ["core_db", "widget", "widget_id", "BIGINT", "1"],
                    ["core_db", "widget", "name", "STRING", "2"],
                ])
            return _make_empty_result()

        mock_ws.statement_execution.execute_statement.side_effect = side_effect

        with Session(engine) as session:
            mv = session.exec(
                __import__("sqlmodel", fromlist=["select"]).select(ModelVersion)
            ).first()
            v = DeploymentVerifier(session, mock_ws, "wh-123")
            result = v.compare(mv.id, "test_cat")

        assert result["summary"]["matching"] == 1
        assert result["verification_error"] is None
        assert result["summary"]["model_only"] == 0
        assert result["summary"]["uc_only"] == 0
        assert len(result["tables"]["both"]) == 1
        # No column diffs since types match
        assert result["tables"]["both"][0]["column_diffs"] == []

    def test_model_only_table(self, engine, mock_ws):
        """Table in logical model but not deployed is reported as model_only."""
        with Session(engine) as session:
            _seed_model(session)
            session.commit()

        # UC returns no tables
        mock_ws.statement_execution.execute_statement.return_value = _make_empty_result()

        with Session(engine) as session:
            mv = session.exec(
                __import__("sqlmodel", fromlist=["select"]).select(ModelVersion)
            ).first()
            v = DeploymentVerifier(session, mock_ws, "wh-123")
            result = v.compare(mv.id, "test_cat")

        assert result["summary"]["model_only"] == 1
        assert result["summary"]["uc_only"] == 0
        assert result["tables"]["model_only"][0]["table"] == "widget"

    def test_column_type_mismatch(self, engine, mock_ws):
        """Column type differences are detected."""
        with Session(engine) as session:
            _seed_model(session)
            session.commit()

        def side_effect(**kwargs):
            sql = kwargs.get("statement", "")
            if "information_schema`.`tables" in sql:
                return _make_sql_result([["core_db", "widget", "BASE TABLE"]])
            if "information_schema`.`columns" in sql:
                return _make_sql_result([
                    ["core_db", "widget", "widget_id", "BIGINT", "1"],
                    # name has a different type in UC
                    ["core_db", "widget", "name", "VARCHAR(255)", "2"],
                ])
            return _make_empty_result()

        mock_ws.statement_execution.execute_statement.side_effect = side_effect

        with Session(engine) as session:
            mv = session.exec(
                __import__("sqlmodel", fromlist=["select"]).select(ModelVersion)
            ).first()
            v = DeploymentVerifier(session, mock_ws, "wh-123")
            result = v.compare(mv.id, "test_cat")

        diffs = result["tables"]["both"][0]["column_diffs"]
        assert len(diffs) == 1
        assert diffs[0]["column"] == "name"
        assert diffs[0]["status"] == "type_mismatch"
        assert result["summary"]["with_diffs"] == 1

    def test_uc_only_table(self, engine, mock_ws):
        """Table deployed in UC but not in logical model is reported as uc_only."""
        with Session(engine) as session:
            _seed_model(session)
            session.commit()

        def side_effect(**kwargs):
            sql = kwargs.get("statement", "")
            if "information_schema`.`tables" in sql:
                return _make_sql_result([
                    ["core_db", "widget", "BASE TABLE"],
                    ["core_db", "extra_table", "BASE TABLE"],
                ])
            if "information_schema`.`columns" in sql:
                return _make_sql_result([
                    ["core_db", "widget", "widget_id", "BIGINT", "1"],
                    ["core_db", "widget", "name", "STRING", "2"],
                    ["core_db", "extra_table", "id", "INT", "1"],
                ])
            return _make_empty_result()

        mock_ws.statement_execution.execute_statement.side_effect = side_effect

        with Session(engine) as session:
            mv = session.exec(
                __import__("sqlmodel", fromlist=["select"]).select(ModelVersion)
            ).first()
            v = DeploymentVerifier(session, mock_ws, "wh-123")
            result = v.compare(mv.id, "test_cat")

        assert result["summary"]["uc_only"] == 1
        assert result["tables"]["uc_only"][0]["table"] == "extra_table"


class TestColumnDiff:
    def test_identical(self):
        diffs = DeploymentVerifier._column_diff(
            {"id": "BIGINT", "name": "STRING"},
            {"id": "BIGINT", "name": "STRING"},
        )
        assert diffs == []

    def test_case_insensitive(self):
        diffs = DeploymentVerifier._column_diff(
            {"id": "bigint"},
            {"id": "BIGINT"},
        )
        assert diffs == []

    def test_model_only_column(self):
        diffs = DeploymentVerifier._column_diff(
            {"id": "BIGINT", "extra": "STRING"},
            {"id": "BIGINT"},
        )
        assert len(diffs) == 1
        assert diffs[0]["status"] == "model_only"

    def test_uc_only_column(self):
        diffs = DeploymentVerifier._column_diff(
            {"id": "BIGINT"},
            {"id": "BIGINT", "extra": "STRING"},
        )
        assert len(diffs) == 1
        assert diffs[0]["status"] == "uc_only"

    def test_type_mismatch(self):
        diffs = DeploymentVerifier._column_diff(
            {"id": "BIGINT"},
            {"id": "INT"},
        )
        assert len(diffs) == 1
        assert diffs[0]["status"] == "type_mismatch"


class TestVerificationErrorRoutes:
    """verification_error round-trips through the three deployment routes:
    a failed read answers 200 with the sanitized reason; a good read None."""

    def _seed(self, engine):
        with Session(engine) as session:
            b, mv, _, _ = _seed_model(session)
            mv.deployment_status = "deployed"
            session.add(mv)
            session.commit()
            return b.id, mv.id

    @pytest.mark.parametrize("path", ["catalog-check", "uc-schema", "compare"])
    def test_a_failed_read_round_trips_verification_error(self, engine, client, mock_ws, path):
        biz, vid = self._seed(engine)
        failing = ws_returning(response(error="[INSUFFICIENT_PERMISSIONS] reader@example.com lacks USE CATALOG"))
        mock_ws.statement_execution = failing.statement_execution

        r = client.get(f"/api/businesses/{biz}/versions/{vid}/deployment/{path}")

        assert r.status_code == 200, r.text
        body = r.json()
        assert "INSUFFICIENT_PERMISSIONS" in body["verification_error"]
        assert "reader@example.com" not in body["verification_error"]
        if path == "compare":
            assert body["tables"]["model_only"] == []
        if path == "uc-schema":
            assert body["tables"] == []

    @pytest.mark.parametrize("path", ["catalog-check", "uc-schema", "compare"])
    def test_a_good_read_has_no_verification_error(self, engine, client, mock_ws, path):
        biz, vid = self._seed(engine)
        found = [["test_cat"]] if path == "catalog-check" else []
        mock_ws.statement_execution = ws_returning(response(found)).statement_execution

        r = client.get(f"/api/businesses/{biz}/versions/{vid}/deployment/{path}")

        assert r.status_code == 200, r.text
        assert r.json()["verification_error"] is None
