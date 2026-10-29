"""Print the industry dedup plan of migration ``v_0_9_0_1`` for one database. Read-only.

The plan is computed by the migration's own ``plan_industry_dedup`` inside a read-only
transaction that is rolled back, so nothing is written. Point it at a database with either
``--url`` (any SQLAlchemy URL, e.g. ``sqlite:////tmp/app.db``) or, without ``--url``, the
Lakebase branch the standard app config names:

  DATABRICKS_CONFIG_PROFILE=<profile> \\
    VIBE_MODELING_LAKEBASE_PROJECT=<project> \\
    VIBE_MODELING_LAKEBASE_BRANCH=<fork branch> \\
    VIBE_MODELING_DATABASE_NAME=<database> \\
    python scripts/smoke/industry_dedup_dry_run.py [--json]

The Lakebase form refuses the ``production`` branch: run it on a fork of the project (a Lakebase branch you
create and delete yourself).
Exit 0 with the plan printed, 2 on a refused target.
"""
from __future__ import annotations

import argparse
import json
import os
import sys
from dataclasses import asdict

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "..", "src", "app", "src"))

from sqlalchemy import create_engine, text  # noqa: E402
from sqlalchemy.engine import Engine  # noqa: E402

from vibe_modeling.backend.migrations.v_0_9_0_1 import IndustryDedupPlan, plan_industry_dedup  # noqa: E402


def _lakebase_engine() -> Engine:
    from databricks.sdk import WorkspaceClient

    from vibe_modeling.backend.core.lakebase import DatabaseConfig, create_db_engine

    config = DatabaseConfig()
    if config.lakebase_branch == "production":
        print("REFUSING: the production branch. Set VIBE_MODELING_LAKEBASE_BRANCH to a fork.", file=sys.stderr)
        raise SystemExit(2)
    print(f"target: projects/{config.lakebase_project}/branches/{config.lakebase_branch} "
          f"database {config.database_name}", file=sys.stderr)
    return create_db_engine(config, WorkspaceClient())


def read_plan(engine: Engine) -> IndustryDedupPlan:
    with engine.connect() as conn:
        if engine.dialect.name == "postgresql":
            conn.execute(text("SET TRANSACTION READ ONLY"))
        elif engine.dialect.name == "sqlite":
            conn.execute(text("PRAGMA query_only = ON"))
        try:
            return plan_industry_dedup(conn)
        finally:
            conn.rollback()


def render(plan: IndustryDedupPlan) -> str:
    lines = [f"merges ({len(plan.merges)}):"]
    for m in plan.merges:
        lines.append(f"  {m.duplicate_name!r} [{m.duplicate_id}] -> {m.target_name!r} [{m.target_id}]; "
                     "businesses repointed: "
                     f"{', '.join(f'{n!r} [{i}]' for n, i in zip(m.business_names, m.business_ids)) or '(none)'}")
    lines.append(f"skipped ({len(plan.skipped)}):")
    for s in plan.skipped:
        lines.append(f"  {s.name!r} [{s.industry_id}] {s.reason}: {', '.join(s.detail)}")
    return "\n".join(lines)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--url", help="SQLAlchemy URL; default: the Lakebase branch from the app env")
    parser.add_argument("--json", action="store_true", help="print the plan as JSON")
    args = parser.parse_args()
    engine = create_engine(args.url) if args.url else _lakebase_engine()
    try:
        plan = read_plan(engine)
    finally:
        engine.dispose()
    print(json.dumps(asdict(plan), indent=2) if args.json else render(plan))
    return 0


if __name__ == "__main__":
    sys.exit(main())
