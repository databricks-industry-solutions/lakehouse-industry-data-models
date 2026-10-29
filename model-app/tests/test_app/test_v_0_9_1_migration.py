"""``v_0_9_1``: the no-op migration of the 0.9.1 release.

Registered right after 0.9.0.4; a reconcile from 0.9.0.4 records 0.9.1 and
changes no table.
"""

from __future__ import annotations

import os
import sys

from sqlalchemy import create_engine
from sqlalchemy.pool import StaticPool
from sqlmodel import SQLModel

from vibe_modeling.backend import migrations as runtime_migrations
from vibe_modeling.backend.migrations import registry as reg
from vibe_modeling.backend.migrations.v_0_9_1 import MIGRATION

sys.path.insert(0, os.path.dirname(__file__))

from _assess_helpers import table_digests  # noqa: E402


def _engine_at_0_9_0_4():
    engine = create_engine("sqlite://", connect_args={"check_same_thread": False}, poolclass=StaticPool)
    SQLModel.metadata.create_all(engine)
    reg._write_installed_version(engine, "0.9.0.4")
    return engine


def test_registered_right_after_0_9_0_4():
    versions = [m.version for m in runtime_migrations.MIGRATIONS]
    at = versions.index("0.9.1")
    assert versions[at - 1] == "0.9.0.4"
    assert runtime_migrations.MIGRATIONS[at] is MIGRATION


def test_reconcile_from_0_9_0_4_records_0_9_1_and_changes_no_table(monkeypatch):
    monkeypatch.setattr(reg, "PRE_PROD_DESTRUCTIVE_RESET", False)
    up_to_this = [m for m in runtime_migrations.MIGRATIONS if reg._vkey(m.version) <= reg._vkey(MIGRATION.version)]
    monkeypatch.setattr(reg, "MIGRATIONS", up_to_this)
    engine = _engine_at_0_9_0_4()
    before = {k: v for k, v in table_digests(engine).items() if k != "_lakebase_schema_version"}
    reg.reconcile_schema(engine)
    assert reg._read_installed_version(engine) == "0.9.1"
    assert {k: v for k, v in table_digests(engine).items() if k != "_lakebase_schema_version"} == before
