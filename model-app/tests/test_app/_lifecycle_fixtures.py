"""Opt-in guard that every agent-produced version is created with a ``files_catalog``.

Import the fixture into the test module that drives a real creation path::

    from ._lifecycle_fixtures import require_files_catalog  # noqa: F401

and wrap the creation call::

    with require_files_catalog:
        ...  # the real finalize / import / sync that inserts ModelVersion rows

While armed, a ``before_insert`` listener on ``ModelVersion`` records every
insert of an agent-produced row (``import_source_path`` NULL) whose
``files_catalog`` is NULL, and the block fails when it ends. Rows inserted
outside the block (hand-built fixtures, which set neither field) are not
checked, so the guard is not autouse.
"""
from __future__ import annotations

from unittest.mock import MagicMock

import pytest
from sqlalchemy import event

from vibe_modeling.backend.db_models import ModelVersion


class FilesCatalogGuard:
    def __init__(self) -> None:
        self.armed = False
        self.violations: list[str] = []
        self.checked = 0

    def __enter__(self) -> "FilesCatalogGuard":
        self.armed = True
        self.violations = []
        self.checked = 0
        return self

    def __exit__(self, exc_type, exc, tb) -> None:
        self.armed = False
        if exc_type is None:
            assert not self.violations, (
                "agent-produced ModelVersion rows inserted without files_catalog: "
                + ", ".join(self.violations)
            )

    def on_insert(self, _mapper, _connection, target: ModelVersion) -> None:
        if not self.armed:
            return
        self.checked += 1
        if target.import_source_path is None and not target.files_catalog:
            self.violations.append(f"v{target.version} {target.scope or '(no scope)'}")


@pytest.fixture
def require_files_catalog():
    guard = FilesCatalogGuard()
    event.listen(ModelVersion, "before_insert", guard.on_insert)
    try:
        yield guard
    finally:
        event.remove(ModelVersion, "before_insert", guard.on_insert)


# The agent's ``install model`` exit JSON for a registered install (nb
# 108138-108150), as ``jobs.get_run_output(<task run>).notebook_output``
# returns it (``result`` string, ``truncated`` flag).
INSTALL_EXIT_OK = {
    "status": "success", "operation": "install model", "business_name": "acme_co", "version": "1",
    "catalog": "test_catalog", "scope": "ecm", "duration_seconds": 60.0,
    "physical": {"success": True, "domains": 2, "tables": 3, "fks": 1}, "metamodel": {"success": True},
    "warnings": [], "warning_count": 0,
}


def install_output(result=INSTALL_EXIT_OK, *, truncated=False):
    """A ``get_run_output`` response carrying ``result`` (a dict is dumped to
    JSON; a string is passed as is; None means no result)."""
    import json
    from types import SimpleNamespace

    raw = json.dumps(result) if isinstance(result, dict) else result
    return SimpleNamespace(notebook_output=SimpleNamespace(result=raw, truncated=truncated))


def agent_exits_ok(ws) -> None:
    """Make every install read on ``ws`` (a MagicMock workspace) see a
    registered install."""
    ws.jobs.get_run_output.return_value = install_output()


def model_json_readable(ws, schema_prefix: str = "") -> None:
    """Make every ``model.json`` read on ``ws`` (a MagicMock workspace)
    parse, its conventions carrying ``schema_prefix``. An install fails its
    step when no candidate path of the version parses, and sends the
    prefix of the file it reads (``Install.dispatch``)."""
    import json

    file_resp = MagicMock()
    file_resp.contents.read.return_value = json.dumps(
        {"model": {"model_conventions": {"schema_prefix": schema_prefix}, "domains": []}}
    ).encode()
    ws.files.download.return_value = file_resp


# The agent's ``uninstall model version`` exit JSON (nb 108480-108492). Built
# from that dict literal with the values the T2 walkthrough reported for
# Wt_Linked v1 ECM in business_1 (run 546d2f82: "dropped 1, failed 4, 4
# database(s) failed to drop"); the dict is not a verbatim capture. It carries
# a count, no database names.
UNINSTALL_EXIT_OK = {
    "status": "success", "operation": "uninstall model version", "business_name": "wt_linked", "version": "1",
    "scope": "ecm", "catalog": "business_1", "dropped": 5, "failed": 0, "duration_seconds": 31.4,
    "warnings": [], "warning_count": 0,
}
UNINSTALL_EXIT_PARTIAL = {
    **UNINSTALL_EXIT_OK, "status": "success_with_warnings", "dropped": 1, "failed": 4,
    "warnings": ["⚠️ 4 database(s) failed to drop"], "warning_count": 1,
}
