"""Migration 0.9.1 - no schema change.

The migration of the 0.9.1 release, applied on top of ``v_0_9_0_4``. The
0.9.1 schema is the 0.9.0 schema, so ``apply`` does nothing; the migration
exists so the database records 0.9.1, the release's version (the tag,
``pyproject`` and the newest migration name the same release).
"""

from __future__ import annotations

from sqlalchemy.engine import Engine

from .registry import Migration


def apply(engine: Engine) -> None:
    """Nothing to change."""


MIGRATION = Migration(
    version="0.9.1",
    apply=apply,
    description="No schema change.",
)
