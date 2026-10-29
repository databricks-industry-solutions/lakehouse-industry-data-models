"""Workspace clients with their own time budgets.

The shared app client (``core/_defaults.py``: ``WorkspaceClient()``) keeps the
SDK's 60 s HTTP timeout and 300 s retry budget. A feature whose calls must
finish sooner builds its own client here: the same default (service-principal)
auth, with the HTTP timeout and retry budget it needs. Callers build it lazily
and cache it, so importing them never touches auth or the network. Users:
``taxonomy/llm.llm_workspace_client``, ``core/_uc_privileges.capability_workspace_client``.
It sits outside ``core/`` so ``taxonomy/llm.py`` can import it without
loading the ``core`` package (which imports the routers, which import llm).
"""

from __future__ import annotations

from databricks.sdk import WorkspaceClient
from databricks.sdk.config import Config


def short_budget_workspace_client(http_timeout_seconds: float, retry_timeout_seconds: float) -> WorkspaceClient:
    """A new app SP client whose calls give up after ``http_timeout_seconds``
    each and stop retrying after ``retry_timeout_seconds``."""
    return WorkspaceClient(config=Config(
        http_timeout_seconds=http_timeout_seconds,
        retry_timeout_seconds=retry_timeout_seconds,
    ))
