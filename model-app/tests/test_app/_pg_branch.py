"""Engine on a new, empty Postgres database on an ephemeral Lakebase branch.

Shared by the real-Postgres tests (``test_*_pg.py``). The branch comes from the
``VIBE_MODELING_LAKEBASE_*`` env the runner (``scripts/smoke/run_pg_branch_test.sh``)
sets; the database is created on it when missing and must be empty, so the
production data the fork cloned is never read or written.
"""
from __future__ import annotations

import re

from sqlalchemy import inspect, text
from sqlalchemy.engine import Engine


def fresh_database_engine(database: str) -> Engine:
    from databricks.sdk import WorkspaceClient

    from vibe_modeling.backend.core.lakebase import DatabaseConfig, create_db_engine

    assert re.fullmatch(r"[a-z_][a-z0-9_]{0,62}", database), database
    ws = WorkspaceClient()
    branch_db = create_db_engine(DatabaseConfig(), ws)
    assert branch_db.dialect.name == "postgresql"
    with branch_db.connect().execution_options(isolation_level="AUTOCOMMIT") as conn:
        if not conn.execute(text("SELECT 1 FROM pg_database WHERE datname = :d"), {"d": database}).first():
            conn.execute(text(f'CREATE DATABASE "{database}"'))
    branch_db.dispose()
    engine = create_db_engine(DatabaseConfig(database_name=database), ws)
    with engine.connect() as conn:
        assert conn.execute(text("SELECT current_database()")).scalar() == database
        assert not inspect(conn).get_table_names()  # a fresh database, nothing cloned
    return engine
