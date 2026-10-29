from __future__ import annotations
from typing import Annotated, AsyncGenerator, TypeAlias
from contextlib import asynccontextmanager

from databricks.sdk import WorkspaceClient
from fastapi import Depends, FastAPI, Request

from ._base import LifespanDependency
from ._config import AppConfig, logger
from ._headers import HeadersDependency


SUPPORTED_AGENT_VERSION = "v0.8.0"
"""Git **release** tag of the vibe-modelling-agent this app targets.

From v0.8.0 the agent carries two independent identities:

  * the **release** identity — the git tag (`v0.8.0`), stamped into the
    notebook's top-cell ``__RELEASE_VERSION__`` constant and into every
    model.json as ``release_version`` ("0.8.0"). This is what the app
    displays, records against imported versions, looks up in the
    compatibility matrix, AND gates on: the notebook-version preflight
    compares the notebook's release against `SUPPORTED_AGENT_VERSION`,
    because the release version tracks the app-agent interface.
  * the **agent-logic marker** — an independent counter (`4.x.y`) stamped
    in the notebook's top-cell ``__AGENT_VERSION__`` constant and in the
    model.json ``agent_version`` field. `SUPPORTED_AGENT_MARKER` is that
    value. It is a per-fix build counter used for traceability/display
    only; it does NOT gate compatibility, so it can move within a release
    (e.g. 4.9.9 → 4.9.10 under release 0.8.0) without a re-pin.

Before v0.8.0 the two were the same string (the agent stamped its release
semver as ``agent_version``); the split means the notebook marker (`4.9.9`)
no longer matches the release tag (`v0.8.0`). Pre-v0.8.0 notebooks that carry
no ``__RELEASE_VERSION__`` fall back to the marker as their release identity.
Shipped as the bundled default via
`src/app/vendored/agent/vibe_modelling_agent_v5.3.3.ipynb`.
"""

SUPPORTED_AGENT_MARKER = "5.3.3"
"""Agent-logic marker for the pinned release (notebook ``__AGENT_VERSION__``).

Decoupled from `SUPPORTED_AGENT_VERSION` (the release tag) at v0.8.0. This is a
per-fix build counter stamped into model.json as ``agent_version`` and logged at
startup. For most operations, it is for traceability only and does NOT gate
compatibility. Scoped vibe runs and Dry runs are gated separately: the
configured notebook's marker must be at least
``core._vibe_scope.MIN_AGENT_MARKER_FOR_SCOPE``, because older agents ignore
the ``vibe_scope`` and ``run_type`` widgets and produce unfenced or deployed
results. See D14 in the vibe-scope design.
"""


class _ConfigDependency(LifespanDependency):
    @asynccontextmanager
    async def lifespan(self, app: FastAPI) -> AsyncGenerator[None, None]:
        app.state.config = AppConfig()
        logger.info(f"Starting app with configuration:\n{app.state.config}")
        logger.info(
            f"targeting vibe-modelling-agent release {SUPPORTED_AGENT_VERSION} "
            f"(agent marker {SUPPORTED_AGENT_MARKER}) "
            f"(https://github.com/databricks-industry-solutions/lakehouse-industry-data-models)"
        )
        yield

    @staticmethod
    def __call__(request: Request) -> AppConfig:
        return request.app.state.config


class _WorkspaceClientDependency(LifespanDependency):
    @asynccontextmanager
    async def lifespan(self, app: FastAPI) -> AsyncGenerator[None, None]:
        app.state.workspace_client = WorkspaceClient()
        yield

    @staticmethod
    def __call__(request: Request) -> WorkspaceClient:
        return request.app.state.workspace_client


def _get_user_ws(
    headers: HeadersDependency,
) -> WorkspaceClient:
    """
    Returns a Databricks Workspace client with authentication behalf of user.
    If the request contains an X-Forwarded-Access-Token header, on behalf of user authentication is used.

    Example usage: `user_ws: Dependencies.UserClient`
    """

    if not headers.token:
        raise ValueError(
            "OBO token is not provided in the header X-Forwarded-Access-Token"
        )

    return WorkspaceClient(
        token=headers.token.get_secret_value(), auth_type="pat"
    )  # set pat explicitly to avoid issues with SP client


def _get_user_ws_optional(
    headers: HeadersDependency,
) -> WorkspaceClient | None:
    """OBO Workspace client when a token is present, else ``None``.

    The soft sibling of :func:`_get_user_ws`: read-only endpoints that can run
    with degraded (anonymous) behaviour when no OBO token is forwarded use this
    so the request still succeeds instead of 500-ing on a missing header. The
    caller decides how to degrade (e.g. the source connector falls back to
    anonymous GitHub browsing).

    Example usage: `user_ws: Dependencies.OptionalUserClient`
    """
    if not headers.token:
        return None
    return WorkspaceClient(
        token=headers.token.get_secret_value(), auth_type="pat"
    )


ConfigDependency: TypeAlias = Annotated[AppConfig, _ConfigDependency.depends()]

ClientDependency: TypeAlias = Annotated[
    WorkspaceClient, _WorkspaceClientDependency.depends()
]

UserWorkspaceClientDependency: TypeAlias = Annotated[
    WorkspaceClient, Depends(_get_user_ws)
]

OptionalUserWorkspaceClientDependency: TypeAlias = Annotated[
    WorkspaceClient | None, Depends(_get_user_ws_optional)
]
