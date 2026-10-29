"""Install the bundled vibe-modelling-agent notebook into the workspace.

The agent notebook ships inside the wheel (see ``bundled_agent.py``).
Databricks Jobs cannot reference a notebook from inside a Python wheel,
so the App copies the wheel-internal ``.ipynb`` into a real workspace
path under the App service principal's home directory and points
``AgentConfig.notebook_path`` at that copy.

This module is the single source of truth for that copy and for the
folder it lands in (``app_agent_folder``): a notebook there is owned by
the app and upgraded on boot (``core/_bundled_agent_init.py``); any other
path is the admin's. Callers: the boot install and upgrade, the Settings
"Switch to bundled" route, and the manual install route
(``routes/platform.py``).
"""

from __future__ import annotations

import logging
from dataclasses import dataclass

from databricks.sdk import WorkspaceClient
from databricks.sdk.service.workspace import ImportFormat

from .bundled_agent import resolve_bundled_agent
from .core._app_identity import app_sp_home

logger = logging.getLogger(__name__)


@dataclass(frozen=True)
class InstallResult:
    """Where the bundled notebook landed and what it is: ``version`` is its
    release (``pinned_tag``), ``agent_version`` its agent-logic marker."""

    path: str
    version: str
    overwritten: bool
    agent_version: str


class BundledAgentNotPackagedError(RuntimeError):
    """Raised when the wheel was built without a vendored agent notebook."""


AGENT_FOLDER_NAME = "vibe-modelling-agent"


def app_agent_folder(sp_home: str) -> str:
    """The app's own agent folder under the app SP's home (``core._app_identity.app_sp_home``)."""
    return f"{sp_home}/{AGENT_FOLDER_NAME}"


def install_bundled_agent_into_workspace(ws: WorkspaceClient) -> InstallResult:
    """Copy the bundled notebook from the wheel into the App SP's workspace home.

    Target: ``/Users/<sp-user-name>/vibe-modelling-agent/<file>.ipynb``.

    Raises:
        BundledAgentNotPackagedError: the wheel has no vendored notebook.
        RuntimeError: the App SP identity could not be resolved or the
            workspace upload failed.
    """
    agent = resolve_bundled_agent()
    if agent is None:
        raise BundledAgentNotPackagedError(
            "No bundled agent notebook is packaged with this app build. "
            "Check that src/app/vendored/agent/ holds the agent notebook, "
            "then re-run install/install.sh to rebuild and redeploy the app."
        )

    folder = app_agent_folder(app_sp_home(ws))
    target = f"{folder}/{agent.file_name}"

    try:
        ws.workspace.mkdirs(folder)
    except Exception as e:  # noqa: BLE001 — best-effort
        logger.info("workspace.mkdirs(%s) raised %s — continuing", folder, e)

    overwritten = False
    try:
        ws.workspace.get_status(target)
        overwritten = True
    except Exception:  # noqa: BLE001 — NotFound is the expected first-install case
        overwritten = False

    fmt = ImportFormat.JUPYTER if agent.file_name.endswith(".ipynb") else ImportFormat.SOURCE
    try:
        with agent.file_path.open("rb") as fh:
            ws.workspace.upload(
                path=target,
                content=fh,
                format=fmt,
                overwrite=True,
            )
    except Exception as e:
        raise RuntimeError(f"Failed to upload bundled agent to {target}: {e}") from e

    return InstallResult(
        path=target,
        version=agent.pinned_tag,
        overwritten=overwritten,
        agent_version=agent.agent_version,
    )
