"""Deployment verifier — compares logical model in Lakebase against live UC schema.

Provides three operations:
1. Catalog check — verify the UC catalog exists and is accessible
2. UC schema introspection — query information_schema for deployed tables/columns/PKs/FKs
3. Compare — diff logical (Lakebase) vs deployed (UC) at table and column level

Every result carries ``verification_error``: ``None`` when every query
succeeded, else the sanitized reason a query failed. A failed read never
reads as "nothing deployed": the result then carries no deployed objects
and no diffs, only the error.
"""

import logging
from typing import Optional

from databricks.sdk import WorkspaceClient
from sqlmodel import Session, select

from .core._sql import SqlStatementError, rows
from .db_models import Attribute, Domain, ForeignKeyLink, ModelVersion, Product
from .services.schema_names import domain_schema_name

logger = logging.getLogger(__name__)


class DeploymentVerifier:
    """Compares logical model structure in Lakebase against deployed UC schema."""

    def __init__(self, session: Session, ws: WorkspaceClient, warehouse_id: str):
        self._session = session
        self._ws = ws
        self._warehouse_id = warehouse_id

    # ------------------------------------------------------------------
    # 1. Catalog check
    # ------------------------------------------------------------------

    def check_catalog(self, catalog: str) -> dict:
        """Check if the UC catalog exists and is accessible.

        Returns {"exists": bool, "catalog": str, "error": str | None,
        "verification_error": str | None}. ``SHOW CATALOGS`` first, then
        ``information_schema.schemata``; only when both fail is the catalog
        unverified, with the last failure as ``verification_error``.
        """
        sql = f"SHOW CATALOGS LIKE '{catalog}'"
        try:
            result = self._execute_sql(sql)
        except SqlStatementError as exc:
            logger.warning("SHOW CATALOGS for %r failed: %s", catalog, exc)
        else:
            return {"exists": len(result) > 0, "catalog": catalog, "error": None, "verification_error": None}

        # Fallback: try information_schema.schemata
        fallback_sql = (
            f"SELECT DISTINCT catalog_name "
            f"FROM `{catalog}`.`information_schema`.`schemata` LIMIT 1"
        )
        try:
            result = self._execute_sql(fallback_sql)
        except SqlStatementError as exc:
            return {
                "exists": False, "catalog": catalog, "error": "Could not verify catalog",
                "verification_error": _failure(f"Could not verify catalog '{catalog}'", exc),
            }
        return {"exists": len(result) > 0, "catalog": catalog, "error": None, "verification_error": None}

    # ------------------------------------------------------------------
    # 2. UC schema introspection
    # ------------------------------------------------------------------

    def get_uc_schema(self, catalog: str, schemas: list[str]) -> dict:
        """Query information_schema for deployed tables, columns, PKs.

        Returns (``verification_error`` set and every list empty when a query
        failed):
        {
            "tables": [{"schema": str, "table": str, "type": str}],
            "columns": [{"schema": str, "table": str, "column": str, "type": str, "ordinal": int}],
            "primary_keys": [{"schema": str, "table": str, "column": str}],
            "foreign_keys": [{"schema": str, "table": str, "column": str,
                              "ref_schema": str, "ref_table": str, "ref_column": str}],
            "verification_error": str | None,
        }
        """
        empty = {"tables": [], "columns": [], "primary_keys": [], "foreign_keys": [], "verification_error": None}
        schema_filter = ", ".join(f"'{s}'" for s in schemas)
        if not schema_filter:
            return empty

        try:
            tables = self._query_tables(catalog, schema_filter)
            columns = self._query_columns(catalog, schema_filter)
            pks = self._query_primary_keys(catalog, schema_filter)
            fks = self._query_foreign_keys(catalog, schema_filter)
        except SqlStatementError as exc:
            return {**empty, "verification_error": _failure(
                f"Could not read the deployed schema in catalog '{catalog}'", exc,
            )}

        return {
            "tables": tables,
            "columns": columns,
            "primary_keys": pks,
            "foreign_keys": fks,
            "verification_error": None,
        }

    def _query_tables(self, catalog: str, schema_filter: str) -> list[dict]:
        sql = (
            f"SELECT table_schema, table_name, table_type "
            f"FROM `{catalog}`.`information_schema`.`tables` "
            f"WHERE table_schema IN ({schema_filter}) "
            f"ORDER BY table_schema, table_name"
        )
        found = self._execute_sql(sql)
        return [
            {"schema": r[0], "table": r[1], "type": r[2]}
            for r in found
        ]

    def _query_columns(self, catalog: str, schema_filter: str) -> list[dict]:
        sql = (
            f"SELECT table_schema, table_name, column_name, data_type, ordinal_position "
            f"FROM `{catalog}`.`information_schema`.`columns` "
            f"WHERE table_schema IN ({schema_filter}) "
            f"ORDER BY table_schema, table_name, ordinal_position"
        )
        found = self._execute_sql(sql)
        return [
            {"schema": r[0], "table": r[1], "column": r[2], "type": r[3], "ordinal": r[4]}
            for r in found
        ]

    def _query_primary_keys(self, catalog: str, schema_filter: str) -> list[dict]:
        sql = (
            f"SELECT tc.table_schema, tc.table_name, kcu.column_name "
            f"FROM `{catalog}`.`information_schema`.`table_constraints` tc "
            f"JOIN `{catalog}`.`information_schema`.`key_column_usage` kcu "
            f"ON tc.constraint_name = kcu.constraint_name "
            f"AND tc.table_schema = kcu.table_schema "
            f"AND tc.table_name = kcu.table_name "
            f"WHERE tc.constraint_type = 'PRIMARY KEY' "
            f"AND tc.table_schema IN ({schema_filter})"
        )
        found = self._execute_sql(sql)
        return [
            {"schema": r[0], "table": r[1], "column": r[2]}
            for r in found
        ]

    def _query_foreign_keys(self, catalog: str, schema_filter: str) -> list[dict]:
        sql = (
            f"SELECT rc.constraint_schema, kcu.table_name, kcu.column_name, "
            f"kcu2.table_schema AS ref_schema, kcu2.table_name AS ref_table, "
            f"kcu2.column_name AS ref_column "
            f"FROM `{catalog}`.`information_schema`.`referential_constraints` rc "
            f"JOIN `{catalog}`.`information_schema`.`key_column_usage` kcu "
            f"ON rc.constraint_name = kcu.constraint_name "
            f"AND rc.constraint_schema = kcu.constraint_schema "
            f"JOIN `{catalog}`.`information_schema`.`key_column_usage` kcu2 "
            f"ON rc.unique_constraint_name = kcu2.constraint_name "
            f"AND rc.unique_constraint_schema = kcu2.constraint_schema "
            f"WHERE rc.constraint_schema IN ({schema_filter})"
        )
        found = self._execute_sql(sql)
        return [
            {
                "schema": r[0], "table": r[1], "column": r[2],
                "ref_schema": r[3], "ref_table": r[4], "ref_column": r[5],
            }
            for r in found
        ]

    # ------------------------------------------------------------------
    # 3. Compare logical vs deployed
    # ------------------------------------------------------------------

    def compare(self, version_id: str, catalog: str) -> dict:
        """Compare logical model (Lakebase) against deployed UC schema.

        Returns:
        {
            "tables": {
                "model_only": [{"schema": str, "table": str}],
                "uc_only": [{"schema": str, "table": str}],
                "both": [{"schema": str, "table": str, "column_diffs": [...]}],
            },
            "summary": {"model_tables": int, "uc_tables": int, "matching": int,
                         "model_only": int, "uc_only": int, "with_diffs": int},
            "verification_error": str | None,
        }

        When the deployed schema could not be read, ``verification_error``
        says why and nothing is compared: no table is listed as model-only.
        """
        # Load logical model from Lakebase
        logical = self._load_logical_model(version_id)
        if not logical:
            return _empty_comparison(0, None)

        # Collect schemas from the logical model
        schemas = list({t["schema"] for t in logical})

        # Get deployed schema
        uc = self.get_uc_schema(catalog, schemas)

        # Build lookup sets: (schema, table)
        logical_set = {(t["schema"], t["table"]) for t in logical}
        if uc["verification_error"]:
            return _empty_comparison(len(logical_set), uc["verification_error"])
        uc_set = {(t["schema"], t["table"]) for t in uc["tables"]}

        # Build column lookups
        logical_cols = self._logical_columns(version_id)
        uc_cols = {}
        for c in uc["columns"]:
            key = (c["schema"], c["table"])
            uc_cols.setdefault(key, []).append(c)

        model_only = [
            {"schema": s, "table": t}
            for s, t in sorted(logical_set - uc_set)
        ]
        uc_only = [
            {"schema": s, "table": t}
            for s, t in sorted(uc_set - logical_set)
        ]
        both = []
        with_diffs = 0
        for s, t in sorted(logical_set & uc_set):
            l_cols = {c["column"]: c["type"] for c in logical_cols.get((s, t), [])}
            u_cols = {c["column"]: c["type"] for c in uc_cols.get((s, t), [])}
            diffs = self._column_diff(l_cols, u_cols)
            if diffs:
                with_diffs += 1
            both.append({"schema": s, "table": t, "column_diffs": diffs})

        return {
            "tables": {"model_only": model_only, "uc_only": uc_only, "both": both},
            "summary": {
                "model_tables": len(logical_set),
                "uc_tables": len(uc_set),
                "matching": len(logical_set & uc_set),
                "model_only": len(model_only),
                "uc_only": len(uc_only),
                "with_diffs": with_diffs,
            },
            "verification_error": None,
        }

    def _load_logical_model(self, version_id: str) -> list[dict]:
        """Load logical table list from Lakebase: [(schema, table)]."""
        domains = self._session.exec(
            select(Domain).where(Domain.version_id == version_id)
        ).all()
        tables = []
        for domain in domains:
            products = self._session.exec(
                select(Product).where(Product.domain_id == domain.id)
            ).all()
            for product in products:
                tables.append({
                    "schema": domain_schema_name(domain.database_name, domain.name),
                    "table": product.table_name or product.name,
                })
        return tables

    def _logical_columns(self, version_id: str) -> dict:
        """Build {(schema, table): [{"column": str, "type": str}]} from Lakebase."""
        result = {}
        domains = self._session.exec(
            select(Domain).where(Domain.version_id == version_id)
        ).all()
        for domain in domains:
            schema_name = domain_schema_name(domain.database_name, domain.name)
            products = self._session.exec(
                select(Product).where(Product.domain_id == domain.id)
            ).all()
            for product in products:
                table_name = product.table_name or product.name
                attrs = self._session.exec(
                    select(Attribute).where(Attribute.product_id == product.id)
                ).all()
                result[(schema_name, table_name)] = [
                    {"column": a.column_name or a.name, "type": a.type}
                    for a in attrs
                ]
        return result

    @staticmethod
    def _column_diff(
        logical: dict[str, str], deployed: dict[str, str]
    ) -> list[dict]:
        """Compare column sets. Returns list of diffs."""
        diffs = []
        all_cols = set(logical.keys()) | set(deployed.keys())
        for col in sorted(all_cols):
            l_type = logical.get(col)
            d_type = deployed.get(col)
            if l_type and not d_type:
                diffs.append({"column": col, "status": "model_only", "model_type": l_type})
            elif d_type and not l_type:
                diffs.append({"column": col, "status": "uc_only", "uc_type": d_type})
            elif l_type and d_type and l_type.upper() != d_type.upper():
                diffs.append({
                    "column": col, "status": "type_mismatch",
                    "model_type": l_type, "uc_type": d_type,
                })
        return diffs

    # ------------------------------------------------------------------
    # SQL helper
    # ------------------------------------------------------------------

    def _execute_sql(self, sql: str) -> list[list]:
        """Rows of an ``information_schema`` / ``SHOW`` query: one 30 s wait,
        no polls. Every failure raises ``SqlStatementError``."""
        return rows(self._ws, self._warehouse_id, sql, wait_timeout="30s")


def _failure(what: str, exc: SqlStatementError) -> str:
    return f"{what}: {exc.message}"


def _empty_comparison(model_tables: int, verification_error: Optional[str]) -> dict:
    return {
        "tables": {"model_only": [], "uc_only": [], "both": []},
        "summary": {
            "model_tables": model_tables, "uc_tables": 0, "matching": 0,
            "model_only": 0, "uc_only": 0, "with_diffs": 0,
        },
        "verification_error": verification_error,
    }
